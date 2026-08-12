create procedure "informix".fechas( pempresa      char(3),
                         pfecha_hoy    date,
                         pfecha_ant    date,
                         pprox_fecha   date,
                         ppri_dia_mes  date,
                         ppri_hab_mes  date,
                         pult_dia_mes  date,
                         pult_hab_mes  date)
returning char(5);

define vcodret char(5);
define vsqlerr integer;
define vcuantos integer;



let vcodret = "000";
let vsqlerr = 0 ;
let vcuantos = 0;

begin
   on exception
     set vsqlerr
     let vcodret = vsqlerr;
     return vcodret;
   end exception;


-- Validaciones para el Cambio de Fechas Distribuidores

select count(*) into vcuantos
from   bdapbuild:so_usuariostatus
where  cajerofirmado = 1 
and    tipousuario  <> "ADMIN"
and    empresaid = pempresa;

if vcuantos is not null and vcuantos > 0 then
   let vcodret = "134";     -- Usuario dentro del sistema 
   return vcodret;
end if

select count(*) into vcuantos
from   bdapbuild:so_usuariostatus
where  cajeroapertura = 1 
and    cajerocierrediario = 0
and    empresaid = pempresa;

if not vcuantos is null and vcuantos > 0 then
   let vcodret = "135";     -- Usuario No han Cerrado y Trabajaron
   return vcodret;
end if


   -- Inicializa Base de Datos
   delete from so_transacmov;
   delete from so_dettransacmov;
   delete from so_desgloseefect;
   delete from so_desglosedocum;
   delete from so_desgloseserv;
   delete from so_desgefectdet;
  
   update bdapbuild:so_usuariostatus set cajeroapertura = 0,
          cajerocierreest = 0, cajerocierrediario = 0;
 
   --INSERTA FECHAS EN DISTRIBUIDOR

   update so_fechas
   set  fechahoy   = pfecha_hoy,
        fechaant   = pfecha_ant,
        fechaprox  = pprox_fecha,
        pridiames  = ppri_dia_mes,
        prihabmes  = ppri_hab_mes,
        ultdiames  = pult_dia_mes,
        ulthabmes  = pult_hab_mes
   where empresaid = pempresa;    
   return vcodret; 
end
end procedure


 

 

 

 

 

 ;