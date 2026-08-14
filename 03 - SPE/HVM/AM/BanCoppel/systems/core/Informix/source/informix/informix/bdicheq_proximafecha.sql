create procedure "informix".proximafecha()
   returning char(5), date;

define vfecprox date;
define vcodret  char(5);
define vsqlerr  integer;
define vempresa char(3);

let vcodret = "000";
let vfecprox = "";


begin
   on exception set vsqlerr
      if vsqlerr <> 0  then
         let vcodret = vsqlerr;
         return vcodret,vfecprox;
      end if;
   end exception;

   select empresa into vempresa
      from bdinteg:si_ejecut
      where ejecutivo = user;

   select prox_fecha into vfecprox
      from sc_fechas
      where empresa = vempresa;
   return vcodret, vfecprox;
end
end procedure;