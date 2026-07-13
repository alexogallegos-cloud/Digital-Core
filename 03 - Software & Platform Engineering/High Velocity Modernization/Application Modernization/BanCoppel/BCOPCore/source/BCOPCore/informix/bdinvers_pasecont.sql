CREATE PROCEDURE "informix".pasecont(pempresa char(3),
                                     pfecha_hoy date,
									 pfecha_valida date,
									 pusuario      char(8))
returning char(5);

define cod_ret char(5);
define vmca_aplic char(1);
define vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector char(10);
define vmoneda,moneda_ant char(2);
define vciudad,vsuc_usuario,v_empresa char(3);
define vsucursal,vsuccta char(4);
define vccmayor char(10);
define vusuario char(8);
define vusuar char(8);
define vauxiliar char(9);
define vdescripcion char(50);
define vtotcar,vtotabo,vvalor_cambio,vvalor_div,
       vcapt_cargo,vcapt_abono,
       vcifra_control money(14,2);
define v_valor money(14,7);
define vcontrol_poliza,vsecuencia integer;
define vfecha_hoy date;
define vfecha_valida date;
define w_descripcion char(30);
define sql_err integer;
define vmensaje char(80);

-- Inicializa variables
let cod_ret         = "000";
let vsecuencia    = 0;
let vdescripcion  = "Movimiento de Inversiones";
let vvalor_cambio = 0;
let vvalor_div    = 0;
let vmca_aplic    = "0";
let moneda_ant      = "  ";

--set debug file to "pasecont.out";
--trace on;

begin
   on exception set sql_err
      if sql_err <> 0 then
         let cod_ret = sql_err;
         return cod_ret;
      end if;
   end exception;

IF pusuario = '' THEN
	-- Extrae el usuario a asignar en el Pase Contable
	select ejecutivo,sucursal into vusuario,vsuc_usuario
	from bdinteg:si_ejecut
	where ejecutivo = user;
	
	if vusuario is null or vsuc_usuario is null then
	   let cod_ret = "158";
	   return cod_ret;
	end if
	
	let vusuario = "inv"||vusuario[1,5];
ELSE
	let vusuario = pusuario ;
END IF
	
-- Asigna la fecha de hoy dada como parametro
let vfecha_hoy = pfecha_hoy;
let vfecha_valida = pfecha_valida;

-- Cada registro de la Tabla Contable de Cheques lo graba en Detalle de Poliza
delete from bdicont:co_poldet
   where empresa = pempresa and usuario = vusuario and
         fecha_captura = vfecha_hoy;


Foreach
   select sucursal,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,
          tot_cargo,tot_abono,moneda,empresa,auxiliar,descripcion,succta
      into vsucursal,vccmayor,vccsub,vccsubsub,vccssubsub,
          vccsssubsub,vsector,vtotcar,vtotabo,vmoneda,
          v_empresa,vauxiliar,w_descripcion,vsuccta
   from sv_contab
   where empresa = pempresa and sucursal <> "TOT"
   order by moneda,empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
            sector

   select regional into vciudad
      from bdinteg:si_sucursales s,bdinteg:si_plazas p
      where s.empresa = pempresa and sucursal = vsucursal and
            p.empresa = s.empresa and p.plaza = s.plaza;

   if vtotcar > 0 then
      let vsecuencia = vsecuencia + 1;
      insert into bdicont:co_poldet
         values(vusuario,vfecha_hoy,vsecuencia,
            v_empresa,vccmayor,vccsub,vccsubsub,vccssubsub,
            vccsssubsub,vsector,vciudad,vsuccta,vauxiliar,
            "D",vtotcar,w_descripcion,vfecha_valida,vmoneda,vsucursal);
   end if
   if vtotabo > 0 then
      let vsecuencia = vsecuencia + 1;
      insert into bdicont:co_poldet
         values(vusuario,vfecha_hoy,vsecuencia,
            v_empresa,vccmayor,vccsub,vccsubsub,vccssubsub,
            vccsssubsub,vsector,vciudad,vsuccta,vauxiliar,
            "C",vtotabo,w_descripcion,vfecha_valida,vmoneda,vsucursal);
   end if
   let vmca_aplic = "1";
end foreach;
if vmca_aplic = "1" then
   execute procedure bdicont:auditapase(vfecha_hoy,v_empresa,vusuario)
           into cod_ret;
end if
return cod_ret;
end
end procedure;