create procedure "informix".liberasalret(pempresa char(3),pejecutivo char(10))
returning char(5);

define vdias_ret integer;
define vdia_res integer;
define vmonto    money(14,2);
define vfecha_alta date;
define vnum_chq integer;
define vtransacc char(4);
define vmonto_ori money(14,2);
define vnumero    char(4);
define vfecha_hoy date;
define vfechab_ant date;
define vcuenta    char(20);
define vcancelado char(1);
define vrowid     integer;
define vcodret    char(5);
define vsqlerr    integer;
define vproceso   char(20);
define vexiste    integer;
define vexiste2   integer;
define vexistefin integer;
define vsistema   char(2);
define vmensaje   char(80);

let vcodret  = "000";
let vproceso = "libsalretcre";
let vsistema = "06";



select fecha_hoy
  into vfecha_hoy
  from sd_fechas
  where empresa = pempresa;


select count(*)
  into vexiste
from bdinteg:sx_contproc
where empresa = pempresa
and   proceso = vproceso
and   fecha   = vfecha_hoy
and   sistema = vsistema;




if vexiste = 0 then

   insert into bdinteg:sx_contproc
          values (pempresa,vproceso,vfecha_hoy,vsistema,"I",pejecutivo,
                  current hour to fraction,null,null);
else

   select count(*)
     into vexistefin
   from bdinteg:sx_contproc
   where empresa = pempresa
   and   proceso = vproceso
   and   fecha   = vfecha_hoy
   and   sistema = vsistema
   and   status_proc = "F";

   if vexistefin = 0 then

      update bdinteg:sx_contproc
         set  hora_ini = current hour to fraction,
              ejecutivo = pejecutivo,
              status_proc = "I"
      where  empresa = pempresa
      and    proceso = vproceso
      and    fecha   = vfecha_hoy
      and    sistema = vsistema;

   else


      let vcodret = "958";

      update bdinteg:sx_contproc
         set hora_fin = current hour to fraction,
             ejecutivo = pejecutivo,
             status_proc = "C",
             codret      = vcodret
       where  empresa = pempresa
       and    proceso = vproceso
       and    fecha   = vfecha_hoy
       and    sistema = vsistema;


      return vcodret;

   end if


end if;


BEGIN WORK;
BEGIN

on exception set vsqlerr
      if vsqlerr <> 0  then
         let vcodret = vsqlerr;
         ROLLBACK WORK;
      update bdinteg:sx_contproc
         set hora_fin = current hour to fraction,
             ejecutivo = pejecutivo,
             status_proc = "C",
             codret      = vcodret
       where  empresa = pempresa
       and    proceso = vproceso
       and    fecha   = vfecha_hoy
       and    sistema = vsistema;

         return vcodret;
      end if;
end exception;

execute procedure cal_habil_ant(vfecha_hoy) into vcodret, vfechab_ant;

if vcodret <> "000" then
   ROLLBACK WORK;

      update bdinteg:sx_contproc
         set hora_fin = current hour to fraction,
             ejecutivo = pejecutivo,
             status_proc = "C",
             codret      = vcodret
       where  empresa = pempresa
       and    proceso = vproceso
       and    fecha   = vfecha_hoy
       and    sistema = vsistema;

    return vcodret;
end if;


foreach principal with hold for
   select numero
     into vnumero
     from bdinteg:si_transacc
     where empresa = pempresa
     and sistema = vsistema
     and numero like "68%"
     and tipo_tran in ("20","21","22")
     and naturaleza = "C"
     order by numero


    foreach
       select rowid,num_credito,transacc,dias_ret,
              monto,fecha,estatus
         into vrowid,vcuenta,vtransacc,vdias_ret,
              vmonto,vfecha_alta,vcancelado
         from sd_maeretenido
         where empresa=pempresa
         and transacc = vnumero
         and estatus <> "S" and estatus <> "L"
         and fecha < vfecha_hoy


       if vdias_ret = 0 then

         update sd_maesdos
            set sdo_retenido = sdo_retenido - vmonto
          where empresa = pempresa
          and   cuenta = vcuenta;

         update sd_maeretenido
	    set estatus= "L"
         where rowid = vrowid;

          continue foreach;

       end if;

       let vdia_res = vfecha_hoy - vfechab_ant;


       let vdias_ret = vdias_ret - vdia_res;

       update sd_maeretenido
          set dias_ret = vdias_ret
       where rowid = vrowid;

    end foreach;



end foreach;

COMMIT WORK;


update bdinteg:sx_contproc
   set hora_fin = current hour to fraction,
       ejecutivo = pejecutivo,
       status_proc = "F",
       codret      = vcodret
where  empresa = pempresa
and    proceso = vproceso
and    fecha   = vfecha_hoy
and    sistema = vsistema;

return vcodret;


END
end procedure;