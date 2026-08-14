create procedure "informix".stpasecon(fecha_hoy date)
   returning char(5);

-- ************************* Definicion de Variables **************************
define cod_ret char(5);
define vt_cargo_abono, vt_mca_aplic char(1);
define vt_ccsub, vt_ccsubsub, vt_ccssubsub, vt_ccsssubsub, vt_sector,
       vt_ciudad, vt_moneda, moneda_ant char(2);
define vt_sucursal, vt_suc_usuario char(3);
define vt_ccmayor char(4);
define vt_usuario char(8);
define vt_usuar char(8);
define vt_auxiliar char(9);
define vt_descripcion char(50);
define vt_monto, vt_valor_cambio, vt_valor_div, vt_capt_cargo, vt_capt_abono,
       vt_cifra_control money(14,2);
define vt_valor money(14,7);
define vt_control_poliza, vt_secuencia smallint;
define vt_fecha_hoy date;
define vt_divisa_cambio char(2);
define sql_err, isam_err integer;

-- ************************* Inicializa variables *****************************
let cod_ret         = "000";
let vt_secuencia    = 0;
let vt_auxiliar     = "0";
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
select ejecutivo, sucursal into vt_usuario, vt_suc_usuario
from bdicent:si_ejecut
where ejecutivo = USER;
if vt_usuario is null or vt_suc_usuario is null then
   let cod_ret = "002";
   return cod_ret;
end if

-- Asigna la fecha de hoy dada como parametro
let vt_fecha_hoy = fecha_hoy;

-- Extrae el valor de la moneda extranjera al dia 
   select divisa_cambio into vt_divisa_cambio from bdicent:si_param;

   select precio_venta into vt_valor from bdicent:si_hisdiv 
   where divisa = vt_divisa_cambio 
   and fecha_tc = fecha_hoy;
   if vt_valor is null then
      -- let cod_ret = "105";
      -- return cod_ret;
   end if 

-- Extrae el ultimo numero de Control de Poliza por el usuario
select max(control_poliza) into vt_control_poliza
   from bdicont:co_poliza
   where usuario = vt_usuario;
if vt_control_poliza is null then
   let vt_control_poliza = 1;
else
   let vt_control_poliza = vt_control_poliza + 1;
end if

-- Cada registro de la Tabla Contable de Cheques lo graba en Detalle de Poliza
foreach
   select sucursal, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector,
	  cargo_abono, monto, moneda
	  into vt_sucursal, vt_ccmayor, vt_ccsub, vt_ccsubsub, vt_ccssubsub,
	  vt_ccsssubsub, vt_sector, vt_cargo_abono, vt_monto, vt_moneda 
      from st_contab
      where sucursal <> "TOT"
      order by moneda, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector
   let vt_secuencia = vt_secuencia + 1;
   select estado into vt_ciudad from bdicent:si_sucursales
   where sucursal = vt_sucursal;

   -- Genera el encabezado de la poliza
   if moneda_ant <> vt_moneda then
      -- Extrae el monto capturado al cargo por la poliza
      select sum(monto) into vt_capt_cargo from bdicont:co_detpol
         where usuario = vt_usuario and
	       control_poliza = vt_control_poliza and
	       fecha_captura = vt_fecha_hoy and
	       naturaleza = "D" and  -- Debito
               moneda = moneda_ant;
      if vt_capt_cargo is null then 
	 let vt_capt_cargo = 0;
      end if

      -- Extrae el monto capturado al abono por la poliza
      select sum(monto) into vt_capt_abono from bdicont:co_detpol
         where usuario = vt_usuario and
	       control_poliza = vt_control_poliza and
	       fecha_captura = vt_fecha_hoy and
	       naturaleza = "C" and  -- Credito
               moneda = moneda_ant;
      if vt_capt_abono is null then
	 let vt_capt_abono = 0;
      end if

      -- Extrae el nombre de la sucursal
      select nombre into vt_descripcion from bdicent:si_sucursales
      where sucursal = vt_suc_usuario;
      let vt_descripcion = "MOVIMIENTO DE TRANFERENCIAS"; 

      if vt_capt_cargo = vt_capt_abono then
         let vt_cifra_control = vt_capt_cargo;
      else
         let vt_cifra_control = 0;
      end if
      -- Graba el encabezado de la poliza 
      insert into bdicont:co_poliza
         values(vt_usuario, vt_control_poliza, vt_fecha_hoy, vt_cifra_control,
	        vt_capt_cargo, vt_capt_abono, moneda_ant, vt_descripcion);
      -- iniicaliza control y secuencia de cada poliza
      let vt_secuencia = 0;
      let vt_control_poliza = vt_control_poliza + 1;
   end if 

   -- Determina si la moneda es extranjera para valorizarla a M.N.
   if vt_moneda = "02" then
      --let vt_monto = vt_monto * vt_valor;
   end if
   insert into bdicont:co_detpol
      values(vt_usuario, vt_control_poliza, vt_fecha_hoy, vt_secuencia,
	     vt_ccmayor, vt_ccsub, vt_ccsubsub, vt_ccssubsub, vt_ccsssubsub,
	     vt_sector, vt_ciudad, vt_sucursal, vt_cargo_abono, vt_auxiliar,
	     vt_monto, vt_descripcion, vt_fecha_hoy, vt_moneda, vt_valor_cambio,
	     vt_valor_div, vt_mca_aplic);
   let moneda_ant = vt_moneda;
end foreach;

-- Genera el encabezado de la ultima poliza 
select sum(monto) into vt_capt_cargo from bdicont:co_detpol
   where usuario = vt_usuario and
	 control_poliza = vt_control_poliza and
         fecha_captura = vt_fecha_hoy and
	 naturaleza = "D" and  -- Debito
         moneda = moneda_ant;
if vt_capt_cargo is null then 
   let vt_capt_cargo = 0;
end if 

-- Extrae el monto capturado al abono por la poliza
select sum(monto) into vt_capt_abono from bdicont:co_detpol
   where usuario = vt_usuario and
	 control_poliza = vt_control_poliza and
         fecha_captura = vt_fecha_hoy and
	 naturaleza = "C" and  -- Credito
         moneda = moneda_ant;
if vt_capt_abono is null then 
   let vt_capt_abono = 0;
end if 

-- Extrae el nombre de la sucursal
select nombre into vt_descripcion from bdicent:si_sucursales
where sucursal = vt_suc_usuario;
let vt_descripcion = "MOVIMIENTO DE TRANSFERENCIAS"; 

if vt_capt_cargo = vt_capt_abono then
   let vt_cifra_control = vt_capt_cargo;
else
   let vt_cifra_control = 0;
end if
-- Graba el encabezado de la poliza 
insert into bdicont:co_poliza
   values(vt_usuario, vt_control_poliza, vt_fecha_hoy, vt_cifra_control,
          vt_capt_cargo, vt_capt_abono, moneda_ant, vt_descripcion);
end;    --fin del on exception
return cod_ret;
end procedure;