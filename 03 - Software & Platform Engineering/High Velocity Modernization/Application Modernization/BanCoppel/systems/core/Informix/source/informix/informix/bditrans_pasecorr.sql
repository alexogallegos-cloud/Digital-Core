create procedure "informix".pasecorr(pfecha_hoy date)
returning char(5);

define cod_ret char(5);
define vw_mca_aplic char(1);
define vw_ccsub, vw_ccsubsub, vw_ccssubsub, vw_ccsssubsub, vw_sector,
       vw_moneda, moneda_ant char(2);
define vw_ciudad, vw_sucursal, vw_suc_usuario, v_empresa char(3);
define vw_ccmayor char(4);
define vw_usuario char(8);
define vw_usuar char(8);
define vw_auxiliar char(9);
define vw_descripcion char(50);
define vw_totcar, vw_totabo,vw_valor_cambio, vw_valor_div, 
       vw_capt_cargo, vw_capt_abono,
       vw_cifra_control money(14,2);
define v_valor money(14,7);
define vw_control_poliza, vw_secuencia smallint;
define vw_fecha_hoy date;
define sql_err integer;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
let cod_ret         = "000";
let vw_secuencia    = 0;
let vw_descripcion  = "Corresponsalia y Financiamiento (Transfe)";
let vw_valor_cambio = 0;
let vw_valor_div    = 0;
let vw_mca_aplic    = "0";
let moneda_ant      = "  ";


begin
   on exception set sql_err
      if sql_err <> 0 then
	 let cod_ret = sql_err;
         return cod_ret;
      end if;
   end exception;

-- ***************************************************************************
-- Extrae el usuario a asignar en el Pase Contable
-- ***************************************************************************
select ejecutivo, sucursal into vw_usuario, vw_suc_usuario
from bdicent:si_ejecut
where ejecutivo = user;
if vw_usuario is null or vw_suc_usuario is null then
   let cod_ret = "158";
   return cod_ret;
end if
let vw_usuario = "tracorr";
-- ***************************************************************************
-- Asigna la fecha de hoy dada como parametro
-- ***************************************************************************
let vw_fecha_hoy = pfecha_hoy;

-- ***************************************************************************
-- Extrae el numero de Control de Poliza por asignar por usuario
-- ***************************************************************************
select max(control_poliza) into vw_control_poliza
from bdicont:co_poliza
where usuario = vw_usuario;
if vw_control_poliza is null then
   let vw_control_poliza = 0;
end if

-- ***************************************************************************
-- Cada registro de la Tabla Contable lo graba en Detalle de Poliza
-- ***************************************************************************
Foreach
   select sucursal, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector,
	  tot_cargo, tot_abono, moneda, empresa, auxiliar
	  into vw_sucursal, vw_ccmayor, vw_ccsub, vw_ccsubsub, vw_ccssubsub,
	  vw_ccsssubsub, vw_sector, vw_totcar, vw_totabo, vw_moneda,
          v_empresa, vw_auxiliar
   from st_contcorr
   where sucursal <> "TOT"
   order by moneda, empresa, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub,
            sector
   let vw_ciudad = vw_sucursal;
 if vw_ciudad = "159" then
      let vw_sucursal = "050";
   end if
   if vw_ciudad = "143" then
      let vw_sucursal = "100";
   end if
   if vw_ciudad = "162" then
      let vw_sucursal = "150";
   end if
   if vw_ciudad = "148" then
      let vw_sucursal = "200";
   end if
   if vw_ciudad = "145" then
      let vw_sucursal = "250";
   end if
   if vw_ciudad = "142" then
      let vw_sucursal = "300";
   end if
   if vw_ciudad = "144" then
      let vw_sucursal = "350";
   end if
   if vw_ciudad = "165" then
      let vw_sucursal = "400";
  end if
   if vw_ciudad = "147" then
      let vw_sucursal = "450";
   end if
   if vw_ciudad = "146" then
   let vw_sucursal = "485";
   end if
   if vw_ciudad = "160" then
      let vw_sucursal = "550";
   end if
   if vw_ciudad = "158" then
      let vw_sucursal = "600";
   end if
   if vw_ciudad = "149" then
      let vw_sucursal = "650";
   end if
   if vw_ciudad = "650" then
      let vw_ciudad = "149";
   end if
   -- Genera el encabezado de la poliza
   if moneda_ant <> vw_moneda then
      let vw_control_poliza = vw_control_poliza + 1;
      let vw_cifra_control = 0;
      let vw_capt_cargo = 0;
      let vw_capt_abono = 0;
      -- Actualiza el control de polizas en Sistema de Contabilidad
      execute procedure bdicont:contpolizas(vw_usuario, vw_control_poliza,
					    vw_fecha_hoy, vw_moneda, "ST");
      -- Graba el encabezado de la poliza
      insert into bdicont:co_poliza
      values(vw_usuario, vw_control_poliza, vw_fecha_hoy, vw_cifra_control,
	     vw_capt_cargo, vw_capt_abono, vw_moneda, vw_descripcion);
      -- inicializa control y secuencia de cada poliza
      let vw_secuencia = 0;
   end if
   if vw_totcar > 0 then
      let vw_secuencia = vw_secuencia + 1;
      insert into bdicont:co_detpol
         values(vw_usuario, vw_control_poliza, vw_fecha_hoy, vw_secuencia,
	    v_empresa, vw_ccmayor, vw_ccsub, vw_ccsubsub, vw_ccssubsub,
	    vw_ccsssubsub, vw_sector, vw_ciudad, vw_sucursal, vw_auxiliar,
            "D", vw_totcar, vw_descripcion, vw_fecha_hoy, vw_moneda,
            0,0,vw_mca_aplic,vw_usuario," ");
   end if
   if vw_totabo > 0 then
      let vw_secuencia = vw_secuencia + 1;
      insert into bdicont:co_detpol
         values(vw_usuario, vw_control_poliza, vw_fecha_hoy, vw_secuencia,
	    v_empresa, vw_ccmayor, vw_ccsub, vw_ccsubsub, vw_ccssubsub,
            vw_ccsssubsub, vw_sector, vw_ciudad, vw_sucursal, vw_auxiliar,
            "C", vw_totabo, vw_descripcion, vw_fecha_hoy, vw_moneda,
            0,0,vw_mca_aplic,vw_usuario," ");
   end if
   let moneda_ant = vw_moneda;
end foreach;

-- Actualiza el numero de poliza 
update bdicont:co_ctrlpoliza
   set numero = vw_control_poliza 
   where num_sec = "1";

-- Actualiza total de cargos, abonos y cifra de control por Poliza
foreach
   select control_poliza, moneda into
      vw_control_poliza, moneda_ant from bdicont:co_poliza
      where fecha_captura = vw_fecha_hoy and usuario = vw_usuario
 
   -- Extrae el monto capturado al cargo por la poliza
   select sum(monto) into vw_capt_cargo from bdicont:co_detpol
      where usuario   = vw_usuario and control_poliza = vw_control_poliza and
      fecha_captura = vw_fecha_hoy and naturaleza = "D" and  -- Debito
      moneda = moneda_ant;
   if vw_capt_cargo is null then 
      let vw_capt_cargo = 0;
   end if 
 
   -- Extrae el monto capturado al abono por la poliza
   select sum(monto) into vw_capt_abono from bdicont:co_detpol
      where usuario   = vw_usuario and control_poliza = vw_control_poliza and
      fecha_captura = vw_fecha_hoy and naturaleza = "C" and  -- Credito
      moneda = moneda_ant;
   if vw_capt_abono is null then
      let vw_capt_abono = 0;
   end if 

   if vw_capt_cargo = vw_capt_abono then
      let vw_cifra_control = vw_capt_cargo;
   else
      let vw_cifra_control = 0;
   end if

   update bdicont:co_poliza
      set (cifra_control,capturado_cargo,capturado_abono) =
	  (vw_cifra_control,vw_capt_cargo,vw_capt_abono)
      where usuario = vw_usuario and control_poliza = vw_control_poliza and
      fecha_captura = vw_fecha_hoy;
end foreach;
return cod_ret;
end
end procedure;