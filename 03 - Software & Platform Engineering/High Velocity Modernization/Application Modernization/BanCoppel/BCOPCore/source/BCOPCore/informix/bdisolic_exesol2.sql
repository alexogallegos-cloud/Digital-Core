create procedure "informix".exesol2()

define vnumsol char(20);
define vcodret char(5);


	foreach select num_solicitud
		  into vnumsol
		  FROM ss_solicitudes
		 where status_solicitud ="CC"


		call califica_scoring2("001", vnumsol)
		returning vcodret;


	end foreach


end procedure 
;