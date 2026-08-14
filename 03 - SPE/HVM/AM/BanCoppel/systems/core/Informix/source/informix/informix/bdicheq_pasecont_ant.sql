create procedure "informix".pasecont_ant(pempresa char(3),
                                     pfecha_hoy date)
returning char(5);

define cod_ret char(5);
define vmca_aplic char(1);
define vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector char(10);
define vmoneda,moneda_ant char(2);
define vsucursal,vsuccta,vsuc_usuario char(4);
define vciudad,vempresa char(3);
define vccmayor char(4);
define vusuario char(8);
define vusuar char(8);
define vauxiliar char(9);
define vdescripcion char(50);
define vtotcar,vtotabo,vvalor_cambio,vvalor_div,
       vcapt_cargo,vcapt_abono,
       vcifra_control money(14,2);
define vvalor money(14,7);
define vcontrol_poliza,vsecuencia integer;
define vfecha_hoy date;
define sql_err integer;
define vmensaje char(80);

-- Inicializa variables
let cod_ret         = "000";
let vsecuencia    = 0;
let vdescripcion  = "Movimientos de Cheques";
let vvalor_cambio = 0;
let vvalor_div    = 0;
let vmca_aplic    = "0";
let moneda_ant      = "  ";

begin
   on exception set sql_err
      if sql_err <> 0 then
         let cod_ret = sql_err;
         return cod_ret;
      end if;
   end exception;

-- Extrae el usuario a asignar en el Pase Contable
select {+INDEX(bdinteg:si_ejecut idx_si_ejecut)} ejecutivo,sucursal into vusuario,vsuc_usuario
from bdinteg:si_ejecut
where ejecutivo = user
and empresa = pempresa;

if vusuario is null or vsuc_usuario is null then
   let cod_ret = "158";
   return cod_ret;
end if
let vusuario = "chq"||vusuario[1,5];

-- Asigna la fecha de hoy dada como parametro
let vfecha_hoy = pfecha_hoy;

-- Cada registro de la Tabla Contable de Cheques lo graba en Detalle de Poliza
delete {+INDEX(bdicont:co_poldet ix_copoldet2new)} from bdicont:co_poldet
   where empresa = pempresa and usuario = vusuario and
         fecha_captura = vfecha_hoy;

Foreach
   ---select {+INDEX(sc_contab idx_sc_contab) +INDEX(sc_contab idx_sc_contab2)} sucursal,succta,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,
   select {+INDEX(sc_contab idx_sc_contab2)} sucursal,succta,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,
   ----select {+INDEX(sc_contab idx_sc_contab)} sucursal,succta,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,
          SUM(tot_cargo),SUM(tot_abono),moneda,empresa,auxiliar,descripcion
      into vsucursal,vsuccta,vccmayor,vccsub,vccsubsub,vccssubsub,
          vccsssubsub,vsector,vtotcar,vtotabo,vmoneda,
          vempresa,vauxiliar,vdescripcion
   from sc_contab
   where empresa = pempresa and sucursal <> "TOT"
   group by 1,2,3,4,5,6,7,8,11,12,13,14
   order by moneda,empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
            sector

   select regional into vciudad
      from bdinteg:si_sucursales su,bdinteg:si_plazas pl
      where su.empresa = pempresa and sucursal = vsucursal and
            pl.empresa = su.empresa and pl.plaza = su.plaza;

   if vtotcar > 0 then
      let vsecuencia = vsecuencia + 1;
      insert into bdicont:co_poldet
         values(vusuario,vfecha_hoy,vsecuencia,
            vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,
            vccsssubsub,vsector,vciudad,vsuccta,vauxiliar,
            "D",vtotcar,vdescripcion,vfecha_hoy,vmoneda,vsucursal);
   end if
   if vtotabo > 0 then
      let vsecuencia = vsecuencia + 1;
      insert into bdicont:co_poldet
         values(vusuario,vfecha_hoy,vsecuencia,
            vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,
            vccsssubsub,vsector,vciudad,vsuccta,vauxiliar,
            "C",vtotabo,vdescripcion,vfecha_hoy,vmoneda,vsucursal);
   end if
   let vmca_aplic = "1";
end foreach;

if vmca_aplic = "1" then
   execute procedure bdicont:auditapase_ant(vfecha_hoy,vempresa,vusuario)
           into cod_ret;
end if

return cod_ret;

end

end procedure;