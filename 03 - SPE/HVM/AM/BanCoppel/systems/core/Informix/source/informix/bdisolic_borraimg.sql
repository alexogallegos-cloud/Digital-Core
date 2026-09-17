create procedure "informix".borraimg()

define v_sol CHAR(20);
foreach select numcte
	   into v_sol
	from ss_solicitudes
	where sucursal ="0002"
	  
	delete from bdidigital:dg_expediente
	where cliente = v_sol;

	delete from bdidigital:dg_expediente_img
	where cliente = v_sol;

end foreach

end procedure

;