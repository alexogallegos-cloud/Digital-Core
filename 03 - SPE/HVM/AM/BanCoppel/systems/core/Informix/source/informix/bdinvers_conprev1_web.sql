create procedure "informix".conprev1_web(pempresa char(3),
										 psucursal  char(4),
										 pinstrumento    char(4),
										 pcapital        money(14,2),
										 pnum_autorizac  char(13),
										 pplazo          smallint,
										 ptp_persona     char(2),
										 pptos_adicional decimal(4,2),
										 pcobraisr       char(1))

   returning char(5), char(5), date, money(14,2), money(14,2),
	     decimal(9,6),decimal(9,6), decimal(9,6), decimal (9,6);
-- **************************************************************************
-- Define variables
-- **************************************************************************
   define v_codret char(5);
   define v_puntos_isr char(1);
   define v_ajustar, v_es_fisica, v_aplicado, v_exento_isr char(1);
   define v_capital money(14,2);
   define v_cod_instrum  char(4);
   define v_sucursal char(4);
   define v_plaza char(3);
   define v_plazo char(5);
   define v_rend_neto, v_imp_isr, v_mto_minimo, v_tot_int, v_isr money(14,2);
   define v_rowid integer;
   define v_numdiasint smallint;
   define v_tasa_instrum char(8);
   define v_tasa_bruta, v_tasa_isr, v_tasa_isr2, v_tasa_neta, valor_tasa, val,
	  v_tasa_base, v_tasa, v_sobretasa, val_tasa_esp decimal(9,6);
   define v_fecha_venc, v_fecha, v_prox_fecha, v_fecha_hoy date;
   define sql_err integer;
   define isam_err integer;
   define v_ptos_adicional decimal(4,2);
   define vplazomin, vplazomax smallint;
   define vanio integer;
   define vresiduo integer;
   define vaniobase integer;


   set lock mode to wait 15;

begin
   on exception set sql_err
      if sql_err < 0 then
	 let  v_codret = sql_err;
         return  v_codret, v_plazo, v_fecha_venc, v_imp_isr,
	     v_rend_neto, v_tasa_bruta, v_tasa_isr, v_tasa_neta,v_tasa_base;
      end if;
   end exception;

-- **************************************************************************
-- Inicializa variables
-- **************************************************************************
   let v_codret     = "00000";
   let v_rend_neto  = 0;
   let v_tasa_bruta = 0;
   let v_tasa_isr   = 0;
   let v_tasa_neta  = 0;
   let v_plazo      = 0;
   let v_tot_int    = 0;
   let v_imp_isr    = 0;
   let v_isr        = 0;
   let val          = 0;
   let valor_tasa   = 0;
   let v_sobretasa  = 0;
   let sql_err      = 0;
   let isam_err     = 0;
   let v_fecha_venc = "";
   let v_tasa_base  = 0;
   let vaniobase      = 365;


--SET DEBUG FILE TO "conprev1.out";
--TRACE ON;
-- **************************************************************************
-- Verifica parametros de entrada
-- **************************************************************************
   if pinstrumento     is null or
      psucursal        is null or
      pnum_autorizac   is null or
      pcapital         is null then
      let  v_codret = "00110";
      return  v_codret,  v_plazo, v_fecha_venc, v_imp_isr,
	     v_rend_neto, v_tasa_bruta, v_tasa_isr, v_tasa_neta,v_tasa_base;
   end if

-- **************************************************************************
-- Verifica el instrumento de la inversion
-- **************************************************************************
   select cod_instrum, ajustar_vencim, mto_min_recom,
          ptos_adicional,num_dias_int,plazomin,plazomax
      into v_cod_instrum,v_ajustar,v_mto_minimo,v_ptos_adicional,
           v_numdiasint,vplazomin,vplazomax
      from sv_instrum
      where empresa = pempresa and cod_instrum = pinstrumento;

   if v_cod_instrum is null then
      let v_codret = "00105";
      return v_codret,  v_plazo, v_fecha_venc, v_imp_isr,
	     v_rend_neto, v_tasa_bruta, v_tasa_isr, v_tasa_neta,v_tasa_base;
   end if

   if pplazo < vplazomin or pplazo > vplazomax then
      let v_codret = "00115";
      return v_codret,  v_plazo, v_fecha_venc, v_imp_isr,
	     v_rend_neto, v_tasa_bruta, v_tasa_isr, v_tasa_neta,v_tasa_base;
   end if

   select plaza  into v_plaza
      from bdinteg:si_sucursales
      where empresa = pempresa and sucursal = psucursal;

   if v_plaza is null then
      let v_codret = "00112";
      return v_codret,  v_plazo, v_fecha_venc, v_imp_isr,
	     v_rend_neto, v_tasa_bruta, v_tasa_isr, v_tasa_neta,v_tasa_base;
   end if

   select UNIQUE(tasa) into v_tasa_instrum from sv_plazotasa
      where empresa = pempresa and cod_instrum = pinstrumento and
            plaza = v_plaza and
            plazo_min <= pplazo and plazo_max >= pplazo;

   if v_tasa_instrum is null then
      let v_codret = "00138";
      return v_codret,  v_plazo, v_fecha_venc, v_imp_isr,
	     v_rend_neto, v_tasa_bruta, v_tasa_isr, v_tasa_neta,v_tasa_base;
   end if

   --- Verifica los puntos adicionales
   if v_ptos_adicional is null then
      let v_ptos_adicional = 0;
   end if
   if pptos_adicional > v_ptos_adicional then
      let v_codret = "00250";
      return v_codret,  v_plazo, v_fecha_venc, v_imp_isr,
	     v_rend_neto, v_tasa_bruta, v_tasa_isr, v_tasa_neta,v_tasa_base;
   end if

-- **************************************************************************
-- Extrae las fechas del sistema
-- **************************************************************************
   select fecha_hoy, prox_fecha into v_fecha_hoy, v_prox_fecha
      from sv_fechas
      where empresa = pempresa;
   if v_fecha_hoy is null then
      let v_codret = "00129";
      return v_codret,  v_plazo, v_fecha_venc, v_imp_isr,
	     v_rend_neto, v_tasa_bruta, v_tasa_isr, v_tasa_neta,v_tasa_base;
   end if

   let vanio = year(v_fecha_hoy);
   let vresiduo = mod(vanio, 4);
   if vresiduo = 0 then
      let vaniobase = 366;
   end if

-- **************************************************************************
-- Verifica si es tasa especial y si es valida
-- **************************************************************************
   if pnum_autorizac != "0000000000000" and pnum_autorizac <> " " then
      select rowid, tasa, sobretasa, capital, aplicado
	 into v_rowid, v_tasa, v_sobretasa, v_capital, v_aplicado
         from sv_autorizacion
         where empresa = pempresa and clave = pnum_autorizac and
	       instrumento = pinstrumento;

      -- Numero de autorizacion de tasa especial no existe
      if v_rowid is null then
	 let v_codret = "00130";
	 return v_codret,  v_plazo, v_fecha_venc, v_imp_isr,
		v_rend_neto, v_tasa_bruta, v_tasa_isr, v_tasa_neta,v_tasa_base;
      else
	 -- Numero de autorizacion de tasa especial ya fue aplicado
	 if v_aplicado = "S" then
	    let v_codret = "00131";
	    return v_codret,  v_plazo, v_fecha_venc, v_imp_isr, v_rend_neto,
                   v_tasa_bruta, v_tasa_isr, v_tasa_neta,v_tasa_base;
	 else
	     -- Capital no es igual al autorizado
	     if  pcapital != v_capital then
		let v_codret = "00136";
		return v_codret, v_plazo, v_fecha_venc, v_imp_isr,v_rend_neto,
                       v_tasa_bruta, v_tasa_isr, v_tasa_neta,v_tasa_base;
	     else
		 let val_tasa_esp = v_tasa + v_sobretasa;
	     end if
	 end if
      end if
   end if


-- **************************************************************************
-- Verifica/Determina la fecha de vencimiento de la inversion
-- **************************************************************************
      let v_fecha_venc=v_fecha_hoy + pplazo;
      execute procedure val_fecha(pempresa,v_fecha_venc, v_ajustar)
          into  v_codret, v_fecha;
let v_codret = "00000";
      let v_fecha_venc = v_fecha;
      let v_plazo = v_fecha_venc - v_fecha_hoy;

-- **************************************************************************
-- Verifica el capital de la inversion contra parametros establecidos
-- **************************************************************************
   if pcapital < v_mto_minimo then
      let v_codret = "00117";
      return v_codret,  v_plazo, v_fecha_venc, v_imp_isr,
	     v_rend_neto, v_tasa_bruta, v_tasa_isr, v_tasa_neta,v_tasa_base;
   end if

-- **************************************************************************
-- Determina el calculo de intereses de acuerdo al instrumento
-- **************************************************************************
   -- Determina el tipo de persona
   select es_fisica, exento_isr into v_es_fisica, v_exento_isr
      from bdinteg:si_tipper where tpo_persona = ptp_persona;

   if pcobraisr <> "" then
      if pcobraisr = "S" then
         let v_exento_isr = "N";
      else
         let v_exento_isr = "S";
      end if
   end if

   select valor into v_tasa_isr
      from bdinteg:si_fechavalor
      where empresa = pempresa and tasa = "I.S.R." and
            fecha in ( select max(fecha) from bdinteg:si_fechavalor
                          where empresa = pempresa and tasa = "I.S.R.");

   -- Valida si es Tasa Especial
   if pnum_autorizac != "0000000000000" and pnum_autorizac <> " " then
	 let  v_codret = "00000";
	 let val = v_tasa + v_sobretasa;
   else
      let v_sobretasa=0;
      if v_es_fisica = "S" then
         let ptp_persona = "F ";
      else
         let ptp_persona = "M ";
      end if
      -- Realiza el calculo de intereses de acuerdo a la tasa del plazo
         execute procedure calc_tasa(pempresa,v_tasa_instrum, ptp_persona,
                                     pcapital)
	       into  v_codret, val;
      if  v_codret = "000" then
let  v_codret = "00000";
          let val = val + pptos_adicional;
      else
          return v_codret,  v_plazo, v_fecha_venc, v_imp_isr,
	     v_rend_neto, v_tasa_bruta, v_tasa_isr, v_tasa_neta,v_tasa_base;
      end if
   end if

   let valor_tasa = val /100;
   let v_tot_int = ((pcapital * valor_tasa) / v_numdiasint) * v_plazo;

   -- Verifica si no es exento de ISR
   if v_exento_isr = "n" or v_exento_isr = "N" then
      let v_isr = pcapital * v_tasa_isr / 100 / vaniobase * v_plazo;
      if v_isr is null then
         let v_isr = 0;
      end if
      let v_imp_isr    = v_isr;
      let v_tasa_neta  = val - v_tasa_isr;
      let val          = val;
      let v_tasa_bruta = val;
   else
      let v_tasa_isr   = 0;
      let v_isr        = 0;
      let v_imp_isr    = 0;
      let v_tasa_neta  = val;
      let v_sobretasa  = 0;
      let v_tasa_bruta = val;
   end if
   -- Determina rendimiento neto
   let v_rend_neto = v_tot_int - v_isr;
   let v_tasa_bruta = val - pptos_adicional;
end;
   return v_codret,  v_plazo, v_fecha_venc, v_imp_isr, v_rend_neto,
	  v_tasa_bruta, v_tasa_isr, v_tasa_neta,v_tasa_base;

end procedure;