create procedure "informix".consnomcte(pempresa char(3),pnumcte char(20))
       returning char(5),char(60),char(13),char(20);

define vcodret char(5);
define vesfisica char(1);
define vpaterno char(15);
define vmaterno char(15);
define vnombre1 char(15);
define vnombre2 char(15);
define vrazon_social char(60);
define vnomcte char(60);
define vsqlerr integer;
define vtpo_persona char(2);
define vrfc char(13);
define vcurp char(20);

let vnomcte = " ";
let vcodret = "000";
let vrfc = " ";
let vcurp = " ";

set lock mode  to wait 3;
set  isolation to dirty read;
begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         RETURN vcodret, vnomcte, vrfc, vcurp;
      end if
   end exception;

   SELECT tpo_persona,nvl(apell_paterno," "),nvl(apell_materno," "),
          nvl(nombre1," "),nvl(nombre2," "),nvl(razon_social," "),
          rfc
      into vtpo_persona,vpaterno,vmaterno,vnombre1,vnombre2,vrazon_social,vrfc
      FROM bdinteg:si_cliente
      WHERE empresa = pempresa and numcte = pnumcte;

   if vtpo_persona = " " or vtpo_persona is null then
      let vcodret = "800";
      RETURN vcodret, vnomcte, vrfc, vcurp;
   else
      select es_fisica into vesfisica from bdinteg:si_tipper
         where tpo_persona = vtpo_persona;
      if vesfisica <> "S" then
         let vnomcte = trim(vrazon_social);
      else
         let vnomcte = trim(vnombre1)||" "||trim(vnombre2)||" "||
                       trim(vpaterno)||" "||trim(vmaterno);
      end if;
   end if

   IF vesfisica="S" then
   	SELECT nvl(curp," ")
   	INTO vcurp
      	FROM bdinteg:si_ctepf
      	WHERE empresa = pempresa and numcte = pnumcte;
   END IF

   RETURN vcodret, vnomcte, vrfc, vcurp;

end
end procedure;