create procedure "informix".consapoderado(pempresa char(3),
                           pnumcte char(20))

       returning 	char(5),smallint, char(20),char(60), char(8), date;

define vcodret char(5);
define vciclo smallint;
define vsqlerr integer;

define vsecuencia smallint;
define vnumcteapoderado char(20);
define vnombreapoderado char(60);
define vuser_insert 	char(8);
define vfecha_insert	date;



let vciclo = 0;
let vcodret = "000";
let  vsqlerr = 0;

let vsecuencia = 0;
let vnumcteapoderado = "";
let vnombreapoderado = "";
let vuser_insert = "";
let vfecha_insert = "";




begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret, vsecuencia , vnumcteapoderado, vnombreapoderado, vuser_insert, vfecha_insert;

      end if;
   end exception;

   foreach
      SELECT   secuencia, numcteapoderado ,nombreapoderado, user_insert, fecha_insert

      INTO      vsecuencia, vnumcteapoderado,vnombreapoderado, vuser_insert, vfecha_insert

      FROM si_apoderado
         WHERE numcte = pnumcte


      return    vcodret, vsecuencia, vnumcteapoderado,vnombreapoderado, vuser_insert, vfecha_insert with resume;

   end foreach;

end
end procedure
;