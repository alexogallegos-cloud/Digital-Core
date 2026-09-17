create procedure "informix".genedos()

define vcred char(20);
define vcodret char(3);

	foreach select num_credito into vcred
		  from sd_maecred


	EXECUTE PROCEDURE bdicred:ugenera_edocuenta('001',vcred,'06-20-2007')
	into vcodret;

	 if vcodret <> "000" then
		insert into sd_valcierre (empresa, num_credito, cod_ret, desc_err) 
		values
		("001",vcred, vcodret, "edo cta");
	end if
	end foreach




end procedure
;