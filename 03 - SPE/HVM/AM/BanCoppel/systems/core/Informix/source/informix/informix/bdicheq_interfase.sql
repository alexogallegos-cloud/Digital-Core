create procedure "informix".interfase(pempresa  char(3),
                                      parchivo  char(30))
       returning char(5);

define vcodret char(5);
define vsqlerr integer;
define vfecha_hoy date;
define vejecutivo char(8);
define vsucursal char(4);
define vtipomov char(1);
define vcuenta char(20);
define vtransacc char(4);
define vmonto money(14,2);
define vdivisa char(2);
define vreferencia char(40);
define vfecha_apli date;
define vprocesado char(1);

   let vcodret="000";


begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret;
      end if;
   end exception;

   select procesado into vprocesado
      from sc_archivos
      where empresa = pempresa and archivo = parchivo;
   if vprocesado is null then
      let vcodret = "972";
      return vcodret;
   end if
   if vprocesado = "S" then
      let vcodret = "973";
      return vcodret;
   end if

   select fecha_hoy into vfecha_hoy
      from sc_fechas where empresa = pempresa;

   select ejecutivo,sucursal into vejecutivo,vsucursal
      from bdinteg:si_ejecut
      where ejecutivo = user;

   foreach
      select tipomov,cuenta,transacc,monto,divisa,referencia,fecha_apli
         into vtipomov,vcuenta,vtransacc,vmonto,vdivisa,vreferencia,
              vfecha_apli
         from sc_detarchivo
         where empresa = pempresa and archivo = parchivo and
               tiporeg = "3"
      insert into sc_movinver
         values(pempresa,vtipomov,vsucursal,vcuenta,vmonto,vdivisa,"N",
                vfecha_hoy,vtransacc,vreferencia,vejecutivo," ",
                vfecha_apli,"");
   end foreach

   update sc_archivos
      set procesado = "S"
      where empresa = pempresa and archivo = parchivo;

   return vcodret;
end
end procedure;