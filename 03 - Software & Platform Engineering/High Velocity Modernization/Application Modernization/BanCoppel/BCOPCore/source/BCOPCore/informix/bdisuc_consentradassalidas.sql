create procedure "informix".consentradassalidas(pempresa char(3), ptipo smallint, pcodproveedor char(8), pplaza char(3), psucursal char(4), pstatus char(2), pfechaini date, pfechafin date)
                           

       returning char(3),char(4),char(8),char(4),char(16),date,char(8),date,char(8),date,char(8),char(2),decimal(14,2),date,char(8);

define vcodret char(5);
define vciclo smallint;
define vsqlerr integer;

define vempresa char(3);
define vcodproveedor char(4);
define vfoliooper char(8);
define vsucursal char(4);
define vfoliosucursal char(16);
define vfechasolicitud date;
define vusuariosolicitud char(8);
define vfechaenvio date;
define vusuarioenvio char(8);
define vfecharecepcion date;
define vusuariorecepcion char(8);
define vstatus char(2);
define vmonto decimal(14,2);
define vfechareversion date;
define vusuarioreversion char(8);

let vciclo = 0;                        
let vcodret = "000";
let  vsqlerr = 0;

let vempresa = "";
let vcodproveedor = "";
let vfoliooper = "";
let vsucursal = "";
let vfoliosucursal = "";
let vusuariosolicitud = "";
let vusuarioenvio = "";
let vusuariorecepcion = "";
let vstatus = "";
let vmonto = 0;
let vusuarioreversion = "";

--set debug file to "condirec.out";
--trace on;

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vempresa,vcodproveedor,vfoliooper,vsucursal,vfoliosucursal,vfechasolicitud,vusuariosolicitud,
                     vfechaenvio,vusuarioenvio,vfecharecepcion,vusuariorecepcion,vstatus,vmonto,vfechareversion,
                     vusuarioreversion;

      end if;
   end exception;

   foreach
      SELECT   empresa, cod_proveedor, folio_oper, sucursal, folio_sucursal, fecha_solicitud, usuario_solicitud, 
                        fecha_envio, usuario_envio, fecha_recepcion, usuario_recepcion, status, monto, fecha_reversion, 
                        usuario_reversion
         INTO      vempresa,vcodproveedor,vfoliooper,vsucursal,vfoliosucursal,vfechasolicitud,vusuariosolicitud,
                        vfechaenvio,vusuarioenvio,vfecharecepcion,vusuariorecepcion,vstatus,vmonto,vfechareversion,
                        vusuarioreversion
         FROM ss_mae_entradasalida
         WHERE sucursal in (Select sucursal From bdinteg:si_sucursales Where plaza = pplaza)
         
      --let vciclo = vciclo+1;

      return    vempresa,vcodproveedor,vfoliooper,vsucursal,vfoliosucursal,vfechasolicitud,vusuariosolicitud,
                     vfechaenvio,vusuarioenvio,vfecharecepcion,vusuariorecepcion,vstatus,vmonto,vfechareversion,
                     vusuarioreversion with resume;
   end foreach;
end
end procedure
;