create procedure "informix".instrucc(pempresa char(3),
                          pplaza        char(3),
			  psucursal     char(4),
			  pcuenta       char(20),
			  pcapital      money(14,2),
			  pinteres      money(14,2),
			  pcap_int      char(1),
			  pinst_vento   char(2),
			  pimporte      money(14,2),
			  pnro_cuenta   char(20),
			  pfecha_venc   date)
   returning char(5);

-- **************************************************************************
-- Define variables
-- **************************************************************************
   define v_sistemas    char(2);
   define v_motivo,v_siglas char(2);
   define pnro_cuenta1  char(20);
   define v_plaza       char(3);
   define cod_ret char(5);
   define v_req_cuenta, v_status,
	  v_per_acred_int,
	  v_requiere_cuenta,
	  v_mismo_cliente,
	  v_provision_int,
	  v_stachq, v_staaho, v_aceabo char(1);
   define v_codigo, v_sistema,v_monchq, v_monaho,
	  v_tp_moneda, v_moneda char(2);
   define v_producto char(4);
   define v_cod_instrum char(4);
   define v_porcentaje like sv_maeinstrucc.porcentaje;
   define v_ctechq, v_cteaho, v_cteinv char(20);
   define v_cuenta char(20);
   define v_sec_capint, longitud smallint;
   define v_mto_min_recom, v_importe,v_importe_cap,
	  v_totreinv, v_importe_int money(14,2);
   define sql_err integer;
   define isam_err integer;
   define v_long_param char(2);
   define v_long_param_sc char(2);
   define v_long_param_sa char(2);
   define v_long_param_st char(2);
   define v_numcte char(20);
   define v_totreg smallint;
-- **************************************************************************
-- Inicializa variables
-- **************************************************************************
   let cod_ret   = "000";
   let v_importe = 0;
   let sql_err   = 0;
   let isam_err  = 0;
   let v_totreg  = 0;
   let v_porcentaje = 0;



   select count(*) into v_totreg from sv_maeinstrucc
      where empresa = pempresa and cuenta = pcuenta;
   if v_totreg is null then
      let v_totreg = 0;
   end if
-- **************************************************************************
-- Verifica parametros de entrada
-- **************************************************************************
   if pplaza         is null or
      psucursal      is null or
      pcuenta        is null or
      pcapital       is null or
      pinteres       is null or
      pcap_int       is null or
      pcap_int=" " or
      pinst_vento    is null or
      pimporte       is null or
      pfecha_venc    is null then
      let cod_ret = "110";
   end if

 begin
   on exception set sql_err, isam_err
      if sql_err <> 0 or isam_err <> 0 then
	 let cod_ret = sql_err;
	 return cod_ret;
      end if
   end exception

-- **************************************************************************
-- Valida si el numero de inversion existe
-- **************************************************************************
   select cuenta, mv.cod_instrum, moneda, mv.num_cte, mv.plaza,mv.per_acred_int
      into v_cuenta, v_cod_instrum, v_moneda, v_cteinv, pplaza,v_per_acred_int
      from sv_maeinv mv, sv_instrum pr
      where mv.empresa = pempresa and cuenta = pcuenta and status_cta = "0"
            and mv.empresa = pr.empresa and mv.cod_instrum = pr.cod_instrum;
   if v_cuenta is null then
      let cod_ret = "100";
      return cod_ret;
   end if

   select sistema_relac,requiere_cuenta,mismo_cliente into
      v_sistemas ,v_requiere_cuenta, v_mismo_cliente
      from sv_instrucc
      where empresa = pempresa and codigo = pinst_vento;

   if v_requiere_cuenta = "S" then
        if pnro_cuenta is null or pnro_cuenta = " " or pnro_cuenta = "0" then
	   let cod_ret = "123";
	   if v_totreg > 0 then
	      delete from sv_maeinstrucc
		 where cuenta = pcuenta;
	   end if
	   return cod_ret;
	end if
        select siglas into v_siglas from bdinteg:si_sistema
           where sistema = v_sistemas;
        if v_siglas = "SC" then
	   -- Valida exista cuenta de cheques
	   select num_cte,producto,plaza,motivo,status_cta into
	      v_ctechq,v_producto,v_plaza,v_motivo,v_stachq
	      from bdicheq:sc_maechq
	      where empresa = pempresa and cuenta = pnro_cuenta and
                    status_cta <> "2";
           if v_ctechq is null then
	      let cod_ret = "153";
	      if v_totreg > 0 then
	         delete from sv_maeinstrucc
		    where empresa = pempresa and cuenta = pcuenta;
	      end if
	      return cod_ret;
	   end if
	   -- Valida si la cuenta esta bloqueada y permite abonos
	   if v_stachq = "3" then
	      select abono into v_aceabo from bdinteg:si_bloqueo
		 where cod_bloqueo = v_motivo;
	      if v_aceabo <> "S" then
		 let cod_ret = "156";
	         if v_totreg > 0 then
	            delete from sv_maeinstrucc
		       where empresa = pempresa and cuenta = pcuenta;
	         end if
		 return cod_ret;
	      end if
	   end if
{
	   -- Valida cliente
	   if v_ctechq <> v_cteinv then
	      let cod_ret = "310";
	      if v_totreg > 0 then
	         delete from sv_maeinstrucc
		    where cuenta = pcuenta;
	      end if
	      return cod_ret;
	   end if
}
	   -- Valida moneda
	   select divisa into v_monchq from bdicheq:sc_producto
	      where empresa = pempresa and producto = v_producto ;
 	   if v_monchq <> v_moneda then
	      let cod_ret = "135";
	      if v_totreg > 0 then
	         delete from sv_maeinstrucc
		    where empresa = pempresa and cuenta = pcuenta;
	      end if
	      return cod_ret;
	   end if
        end if
     end if

-- *************************************************************************
-- Extrae de la tabla de instrumentos el periodo de acreditamiento de los
-- intereses y el periodo de la provision
-- *************************************************************************
   select provision_int, mto_min_recom
      into v_provision_int, v_mto_min_recom
    from sv_instrum
    where empresa = pempresa and cod_instrum = v_cod_instrum;

-- ************************************************************************
-- Valida que no se reinviertan los intereses si se trata de CEDES
-- ************************************************************************
   if pcap_int = "I" and v_per_acred_int = "M" and pinst_vento = "01" then
      let cod_ret = "145";
      if v_totreg > 0 then
	 delete from sv_maeinstrucc
	    where empresa = pempresa and cuenta = pcuenta;
      end if
      return cod_ret;
   end if

-- **************************************************************************
-- Verifica la sumatoria del cap/int mas el nuevo importe indicado
-- **************************************************************************
   select sum(importe) into v_importe
      from sv_maeinstrucc
      where empresa = pempresa and cuenta = pcuenta and cap_int = pcap_int;
   if v_importe is null then
      let v_importe = 0;
   end if
   let v_importe = v_importe + pimporte;
   if pcap_int = "C" then
       if v_importe > pcapital then
	 let cod_ret = "124";
	 return cod_ret;
      end if
   end if
   if pcap_int = "I" then
      if v_importe > pinteres then
	 let cod_ret = "125";
	 return cod_ret;
      end if
   end if

-- **************************************************************************
-- Determina el porcentaje asignado a la instruccion
-- **************************************************************************
   if pcap_int = "C" then
      let v_porcentaje = pimporte / pcapital;
   end if

   if pcap_int = "I" then
      let v_porcentaje = pimporte / pinteres;
   end if

-- **************************************************************************
-- Determina la secuencia de  apital o interes a grabar
-- **************************************************************************
   select max(sec_capint) into v_sec_capint
   from sv_maeinstrucc
   where empresa = pempresa and cuenta = pcuenta and cap_int = pcap_int;
   if v_sec_capint is null then
      let v_sec_capint = 1;
   else
      let v_sec_capint = v_sec_capint + 1;
   end if

-- **************************************************************************
-- Graba en el maestro de instrucciones las referentes a capital
-- **************************************************************************
   insert into sv_maeinstrucc
   values(pempresa,pcuenta, pcap_int, v_sec_capint,
	  pinst_vento, pimporte, v_sistemas, pnro_cuenta, "N",
	  pfecha_venc, v_porcentaje);

-- **************************************************************************
-- Determina que el monto a reinvertir sea mayor o igual al minimo recom.
-- **************************************************************************
   if v_totreg  > 0 then
      select sum(importe) into v_totreinv
         from sv_maeinstrucc
         where empresa = pempresa and cuenta = pcuenta and inst_vento = "01";
      if v_totreinv is null then
 	 let v_totreinv = 0;
      end if
      if v_totreinv < v_mto_min_recom  and v_totreinv > 0 then
	 delete from sv_maeinstrucc
	    where empresa = pempresa and cuenta = pcuenta;
         let cod_ret = "311";
         return cod_ret;
      end if
   end if

-- **************************************************************************
-- Valida que ya se haya registrado el importe total de capital e interes
-- **************************************************************************
   select sum(importe) into v_importe_cap
   from sv_maeinstrucc
   where empresa = pempresa and cuenta = pcuenta and cap_int = "C";
   if v_importe_cap is null then
      let v_importe_cap = 0;
   end  if
   if v_importe_cap < pcapital then
      let cod_ret = "132";
      return cod_ret;
   end if

   select sum(importe) into v_importe_int
   from sv_maeinstrucc
   where empresa = pempresa and cuenta = pcuenta and cap_int = "I";
   if v_importe_int is null then
      let v_importe_int = 0;
   end if
   if v_importe_int < pinteres then
      let cod_ret = "133";
      return cod_ret;
   end if
   update sv_maeinstrucc set importe = 0
     where empresa = pempresa and cuenta = pcuenta and cap_int = "I";   
 end

   return cod_ret;
end procedure;