create procedure "informix".consultarp(pempresa char(3),
					pnumcte char(20))

returning char(5),char(60),char(10),char(80),char(20),char(30);

define codret char(5);
define vparentesco           char(10);
define vnombre               char(60);
define vdireccion            char(80);
define vtelefono             char(20);
define vexiste               char(2);
define vnum_credito          char(20);
define vactividad            char(30);

define sql_err integer;
let sql_err = 0;
LET vparentesco = "";
LET vnombre     = "";
LET vdireccion  = "";
LET vtelefono   = "";
LET vexiste     = 0;
let vnum_credito = trim(pnumcte);
let vactividad = "";

set isolation to dirty read;
let codret = "000";
begin
   on exception set sql_err
      if sql_err <> 0 then
         let codret = sql_err;
        return codret,vnombre,vparentesco,vdireccion,
               vtelefono,vactividad;
      end if;
   end exception;




 select valor into vexiste from si_param
 where cod_param = "7";
 -- Saca el Cliente del Credito

 select numcte into pnumcte
 from bdicred:sd_maecred
 where num_credito = vnum_credito;
let vexiste = 0;
foreach
  select parentesco,nombre,direccion,telefono,actividad
   into vparentesco,vnombre,vdireccion,vtelefono,vactividad
   from si_refper
   where numcte = pnumcte
   order by 1
   if vparentesco is null then
      let vparentesco = 0;
   end if;
   if vnombre is null then
      let vnombre = " ";
   end if;
   if vdireccion is null then
      let vdireccion = " ";
   end if;
   if vtelefono is null then
      let vtelefono = " ";
   end if;
   return codret,vnombre,vparentesco,vdireccion,
               vtelefono,vactividad
          with resume;
end foreach;
end
end procedure;