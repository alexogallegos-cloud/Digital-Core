create procedure "informix".calc_int(pempresa char(3),
                                     pcta_chq char(20))

returning char(5),money(14,2),decimal(9,6),
          money(14,2),money(14,2),
          money(14,2),money(14,2),
          char(3),char(2);

define vstatus_cta,vfisica,vcobraisr,vexento_isr char(1);
define v_pag_int_canc,v_cal_int_chq,v_pagint char(1);
define vtip_per char(2);
define vcod,vcodret char(5);
define vsuc_cta char(4);
define vtasa char(8);
define v_plaza char(3);
define v_producto char(4);
define v_moneda,v_long_cta char(2);
define vnum_cte char(20);
define vcuenta char(20);
define vvalor_tasa decimal(9,6);
define vacum_sdo_pos ,vsdo_actual,vsdo_retenido,vsdo_cong,v_mtopag,
       vsdo_prom,vmto_min_isr,vtot_int,visr,vtot_canc money(14,2);
define vdia_sdo_pos,longitud smallint;
define sql_err integer;
define hoy date;


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************
let vsdo_prom = 0;
let vvalor_tasa = 0;
let vsdo_actual = 0;
let vtot_int = 0;
let visr = 0;
let vtot_canc = 0;
let vcodret = "000";

begin
on exception set sql_err
   if sql_err <> 0 then
      let vcodret = sql_err;
      return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vtot_int,
          visr,vtot_canc,vsuc_cta,v_moneda;
   end if;
end exception;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

select mc.cuenta,sucursal,mc.plaza,mc.producto,num_cte,
       dia_sdo_pos,acum_sdo_pos,sdo_actual,status_cta,sdo_retenido,sdo_cong,
       pr.divisa,mc.cobraisr 
   into vcuenta,vsuc_cta,v_plaza,v_producto,vnum_cte,vdia_sdo_pos,
        vacum_sdo_pos,vsdo_actual,vstatus_cta,vsdo_retenido,
        vsdo_cong,v_moneda,vcobraisr
   from sc_maechq mc,sc_maenoc mn,sc_producto pr
   where mc.empresa = pempresa and mc.cuenta = pcta_chq and
         mn.empresa = mc.empresa and mn.cuenta = mc.cuenta and
         mc.empresa = pr.empresa and mc.producto = pr.producto;   

if vcuenta is null then
   let vcodret = "100";
   return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vtot_int,
          visr,vtot_canc,vsuc_cta,v_moneda;
end if

-- *****************************************************************************
-- Asignacion de Variables
-- *****************************************************************************

      select valor into v_pag_int_canc
         from sc_param
         where empresa = pempresa and descripcion = "pagintcancta";

      select fecha_hoy into hoy from sc_fechas where empresa = pempresa;

-- Determina si el Producto paga intereses
      select paga_interes,mto_pag_int,tasa into v_pagint,v_mtopag,vtasa
         from sc_producto
         where empresa = pempresa and producto = v_producto;

-- Determina el Saldo Promedio de la cuenta
      if vdia_sdo_pos > 0 then
         let vsdo_prom = vacum_sdo_pos / vdia_sdo_pos;
      else
         let vsdo_prom = 0;
      end if

-- Determina el tipo de persona
   select tpo_persona into vtip_per
      from bdinteg:si_cliente where numcte = vnum_cte;
	  
   select es_fisica,exento_isr into vfisica,vexento_isr
      from bdinteg:si_tipper where tpo_persona = vtip_per;
  
  if vfisica = "S" then
      let vtip_per = "F ";
   else
      let vtip_per = "M ";
   end if
      
    IF vexento_isr  NOT IN ("N","S") THEN 
       IF vcobraisr <> "" then
           IF vcobraisr = "S" then
              let vexento_isr = "N";
           ELSE
              let vexento_isr = "S";
           END IF
        END IF
	END IF  
	 
   if v_pag_int_canc = "S" and v_pagint = "S" and vsdo_prom >= v_mtopag then
      call calc_tasa(pempresa,vtasa,vtip_per,vsdo_prom)
           returning vcod,vvalor_tasa;
      if vcod = "000" then
         let vtot_int = vacum_sdo_pos * vvalor_tasa / 100 / 360;

         -- Verificar el sdo promedio para si/no retener ISR
         if vexento_isr = "N" then        
            call calc_isr(pempresa,pcta_chq,hoy,vvalor_tasa,vtot_int,
                          vsdo_prom,vdia_sdo_pos,vfisica)
                 returning vcod,visr;
         end if
      end if
   end if

let vtot_canc = vsdo_actual + vtot_int - visr;

return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vtot_int,
       visr,vtot_canc,vsuc_cta,v_moneda;
end
end procedure;