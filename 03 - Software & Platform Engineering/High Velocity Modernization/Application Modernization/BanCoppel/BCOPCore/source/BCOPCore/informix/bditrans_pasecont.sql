create procedure "informix".pasecont(fecha_hoy date)
   returning char(5);

-- ************************* Definicion de Variables **************************
define cod_ret char(5);
define vt_divisa_cambio  char(2);
define vt_cargo_abono,vt_mca_aplic char(1);
define vt_ccsub,vt_ccsubsub,vt_ccssubsub,vt_ccsssubsub,vt_sector,
       vt_moneda,moneda_ant char(2);
define vt_ciudad,vt_sucursal,vt_suc_usuario char(3);
define vt_empresa char(3);
define vt_ccmayor char(4);
define vt_usuario char(8);
define vt_usuar char(8);
define vt_auxiliar char(9);
define vt_descripcion char(50);
define vt_totcar,vt_valor_cambio,vt_valor_div,vt_capt_cargo,vt_capt_abono,
       vt_cifra_control, vt_totabo money(14,2);
define vt_valor money(14,7);
define vt_control_poliza,vt_secuencia smallint;
define vt_fecha_hoy date;
define sql_err,isam_err  integer;

-- ************************* Inicializa variables *****************************
let cod_ret         = "000";
let vt_secuencia    = 0;
let vt_auxiliar     = "000000000";
let vt_descripcion  = "Movimientos de Transferencias del dia de Hoy";
let vt_valor_cambio = 0;
let vt_valor_div    = 0;
let vt_mca_aplic    = "0";
let moneda_ant      = "00";


   begin
      on exception set sql_err,isam_err
         if sql_err <> 0 or isam_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret;
         end if;
      end exception;

-- Extrae el usuario a asignar en el Pase Contable
select ejecutivo,sucursal into vt_usuario,vt_suc_usuario
from bdicent:si_ejecut
where ejecutivo = USER;
if vt_usuario is null or vt_suc_usuario is null then
   let cod_ret = "158";
   return cod_ret;
end if
let vt_usuario = "tra"||vt_usuario[1,5];
-- Asigna la fecha de hoy dada como parametro
let vt_fecha_hoy = fecha_hoy;

-- Extrae el valor de la moneda extranjera al dia
   select divisa_cambio into vt_divisa_cambio from bdicent:si_param;
   select precio_venta into vt_valor from bdicent:si_tpcambio
      where divisa   = vt_divisa_cambio
      and clase_tpcambio = "I";

-- ***************************************************************************
-- Extrae el ultimo numero de Control de Poliza por el usuario
-- ***************************************************************************
select max(control_poliza) into vt_control_poliza
from bdicont:co_poliza
where usuario = vt_usuario;
if vt_control_poliza is null then
   let vt_control_poliza = 0;
end if

-- Cada registro de la Tabla Contable de Cheques lo graba en Detalle de Poliza
foreach
   select sucursal,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,
	  tot_cargo,tot_abono,moneda,empresa
      into vt_sucursal,vt_ccmayor,vt_ccsub,vt_ccsubsub,vt_ccssubsub,
	  vt_ccsssubsub,vt_sector,vt_totcar,vt_totabo,vt_moneda,
	  vt_empresa
      from st_contab
      where sucursal <> "TOT"
      order by moneda,empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector

   select regional into vt_ciudad from bdicent:si_sucursales,bdicent:si_plazas
      where bdicent:si_sucursales.plaza = bdicent:si_plazas.plaza and
	    bdicent:si_sucursales.sucursal = vt_sucursal;

   -- Genera el encabezado de la poliza
   if moneda_ant <> vt_moneda then
      let vt_control_poliza = vt_control_poliza + 1;
      let vt_descripcion = "MOVIMIENTO DE TRANFERENCIAS";
      let vt_capt_cargo = 0;
      let vt_capt_abono = 0;
      let vt_cifra_control = 0;
      -- Actualiza el Control de Polizas en el Sistema de Contabilidad
      execute procedure bdicont:contpolizas(vt_usuario,vt_control_poliza,
                                            vt_fecha_hoy,vt_moneda,"ST");
      -- Graba el encabezado de la poliza
      insert into bdicont:co_poliza
         values(vt_usuario,vt_control_poliza,vt_fecha_hoy,vt_cifra_control,
	        vt_capt_cargo,vt_capt_abono,vt_moneda,vt_descripcion);
      -- inicializa control y secuencia de cada poliza
      let vt_secuencia = 0;
   end if
   if vt_totcar > 0 then
      let vt_secuencia = vt_secuencia + 1;
      insert into bdicont:co_detpol
         values(vt_usuario,vt_control_poliza,vt_fecha_hoy,vt_secuencia,
	        vt_empresa,vt_ccmayor,vt_ccsub,vt_ccsubsub,vt_ccssubsub,
	        vt_ccsssubsub,vt_sector,vt_ciudad,vt_sucursal,vt_auxiliar,
	        "D",vt_totcar,vt_descripcion,vt_fecha_hoy,vt_moneda,
	        0,0,vt_mca_aplic,vt_usuario," ");
   end if
   if vt_totabo > 0 then
      let vt_secuencia = vt_secuencia + 1;
      insert into bdicont:co_detpol
         values(vt_usuario,vt_control_poliza,vt_fecha_hoy,vt_secuencia,
	        vt_empresa,vt_ccmayor,vt_ccsub,vt_ccsubsub,vt_ccssubsub,
	        vt_ccsssubsub,vt_sector,vt_ciudad,vt_sucursal,vt_auxiliar,
	        "C",vt_totabo,vt_descripcion,vt_fecha_hoy,vt_moneda,
	        0,0,vt_mca_aplic,vt_usuario," ");
   end if
   let moneda_ant = vt_moneda;
end foreach;

-- Actualiza el numero de poliza
update bdicont:co_ctrlpoliza
   set numero = vt_control_poliza
   where num_sec = "1";

-- Actualiza total de cargos, abonos y cifra de control por Poliza
foreach
   select control_poliza,moneda
      into vt_control_poliza, moneda_ant
      from bdicont:co_poliza
      where fecha_captura = vt_fecha_hoy and usuario = vt_usuario
   -- Extra el total de cargos por poliza
   select sum(monto) into vt_capt_cargo from bdicont:co_detpol
      where usuario        = vt_usuario and
	    control_poliza = vt_control_poliza and
            fecha_captura  = vt_fecha_hoy and
	    naturaleza     = "D" and  -- Debito
            moneda         = moneda_ant;
   if vt_capt_cargo is null then
      let vt_capt_cargo = 0;
   end if

   -- Extrae el monto capturado al abono por la poliza
   select sum(monto) into vt_capt_abono from bdicont:co_detpol
      where usuario        = vt_usuario and
	    control_poliza = vt_control_poliza and
            fecha_captura  = vt_fecha_hoy and
	    naturaleza     = "C" and  -- Credito
            moneda         = moneda_ant;
   if vt_capt_abono is null then
      let vt_capt_abono = 0;
   end if

   if vt_capt_cargo = vt_capt_abono then
      let vt_cifra_control = vt_capt_cargo;
   else
      let vt_cifra_control = 0;
   end if

   -- Actualiza total de cargos, abonos y cifra de control por Poliza
   update  bdicont:co_poliza
      set (cifra_control,capturado_cargo,capturado_abono) =
	  (vt_cifra_control,vt_capt_cargo,vt_capt_abono)
	  where usuario = vt_usuario and control_poliza = vt_control_poliza
		and fecha_captura = vt_fecha_hoy;
end foreach;
end;    --fin del on exception
return cod_ret;
end procedure;