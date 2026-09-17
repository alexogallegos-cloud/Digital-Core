create procedure "informix".conscteppesfamilia(pempresa char(3),
                           pnumcte char(20))

       returning 	char(5), char(3), char(20), smallint, char(20),char(60), char(3), char(8), date;

define vcodret char(5);
define vciclo smallint;
define vsqlerr integer;

define vempresa char(3);
define vnumcte char(20);
define vsecuencia smallint;
define vnumctefamiliar  char(20);
define vnombrefamiliar  char(60);
define vparentesco char(3);
define vuser_insert 	char(8);
define vfecha_insert	date;



let vciclo = 0;                        
let vcodret = "000";
let  vsqlerr = 0;

let vempresa = "";
let vnumcte = "";
let vsecuencia = 0;
let vnumctefamiliar  = "";
let vnombrefamiliar  = "";
let vparentesco = "";
let vuser_insert = "";
let vfecha_insert = "";




begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret, vempresa, vnumcte, vsecuencia , vnumctefamiliar, vnombrefamiliar, vparentesco, vuser_insert, vfecha_insert;

      end if;
   end exception;

SET LOCK MODE TO WAIT 3;
SET ISOLATION  TO DIRTY READ;

   foreach
   
		SELECT empresa, numcte, secuencia, numctefamiliar, nombrefamiliar, parentesco, usuario_insert, fecha_insert 
		INTO vempresa, vnumcte, vsecuencia, vnumctefamiliar, vnombrefamiliar, vparentesco, vuser_insert, vfecha_insert	 	
		FROM si_ppefamilia 
		WHERE numcte = pnumcte 
		order by secuencia
        
         

      return    vcodret, vempresa, vnumcte, vsecuencia, vnumctefamiliar, vnombrefamiliar, vparentesco, vuser_insert, vfecha_insert with resume;

   end foreach;
      
end
end procedure
;