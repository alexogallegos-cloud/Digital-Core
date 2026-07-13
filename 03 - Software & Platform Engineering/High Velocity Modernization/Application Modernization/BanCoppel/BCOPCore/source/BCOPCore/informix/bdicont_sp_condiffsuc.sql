CREATE PROCEDURE "informix".sp_condiffsuc(pempresa char(3),
                               pusuario char(8),
                               psucursal char(4),
                               pfecha date)
returning char(5),char(30),char(30),money(14,2),money(14,2),char(2);

define vcodret       char(5);
define vsucursal     char(4);
define vsucursaldesc char(30);
define vcuentacon    char(30);
define vcargos       money(14,2);
define vabonos       money(14,2);
define vsistema      char(2);

let vcodret = "000";
let vsucursal = "";
let vsucursaldesc = "";
let vcuentacon = "";
let vcargos = 0;
let vabonos = 0;
let vsistema = 0;

begin

set isolation to dirty read;

if psucursal = "" then -- Regresa todas la Sucursales con Diferencia
 foreach
   select a.sucursal||" "||b.nombre,
       Trim(ccmayor)||Trim(ccsub)||Trim(ccsubsub)||
       Trim(ccssubsub)||Trim(ccsssubsub)||Trim(sector) Cuenta,
       sum(nvl(a.creditos,0) - nvl(a.debitos,0)) Cargos,
       sum(nvl(a.creditos_suc,0) - nvl(a.debitos_suc,0)) Abonos,
	   sistema
   into vsucursal,vcuentacon,vcargos,vabonos,vsistema
   from co_auditerr_cint a,bdinteg:si_sucursales b
   where a.fecha_proceso = pfecha
     and a.currentuser = pusuario
     and a.sucursal = b.sucursal
   and (debitos > 0 or creditos > 0 or creditos_suc > 0 or debitos_suc > 0)
   group by 2,1,5
   order by 1,2

   select b.nombre
   into vsucursaldesc
   from bdinteg:si_sucursales b
   where b.empresa = pempresa
     and b.sucursal = vsucursal;

   if vcargos + vabonos = 0 then
      continue foreach;
   end if

   return vcodret,vsucursal ||" "|| vsucursaldesc ,vcuentacon,vcargos,vabonos,vsistema with resume;
 end foreach
else
 foreach
   select a.sucursal||" "||b.nombre,
       Trim(ccmayor)||Trim(ccsub)||Trim(ccsubsub)||
       Trim(ccssubsub)||Trim(ccsssubsub)||Trim(sector) Cuenta,
       sum(nvl(a.creditos,0) - nvl(a.debitos,0)) Cargos,
       sum(nvl(a.creditos_suc,0) - nvl(a.debitos_suc,0)) Abonos,
	   sistema
   into vsucursal,vcuentacon,vcargos,vabonos,vsistema
   from co_auditerr_cint a,bdinteg:si_sucursales b
   where a.fecha_proceso = pfecha
     and a.currentuser = pusuario
     and a.sucursal = b.sucursal
     and a.sucursal= psucursal
     and (debitos > 0 or creditos > 0 or creditos_suc > 0 or debitos_suc > 0)
   group by 2,1,5
   order by 2
   if vcargos + vabonos = 0 then
      continue foreach;
   end if
   return vcodret,vsucursal,vcuentacon,vcargos,vabonos,vsistema with resume;
 end foreach
end if
end
end procedure;