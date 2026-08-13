create procedure "informix".cambiatrancred()

define vTran char(4);
define vTpTran char(2);
define vNat    char(1);
define vRelac char(4);
define vLib   char(4);
define vDias  smallint;
define vIva   char(4);
define vSi    smallint;

foreach select numero, tipo_tran, naturaleza, tran_relac, tranlibprot,
	       dias_ret, trancivaesp
	  into vTran, vTpTran, vNat, vRelac, vLib, vDias, vIva
	  from si_transaccax
	
	select count(*) INTO vSi
	  from si_transacc
	 where numero = vTran
	   and sistema = "06";

	IF vSi IS NULL OR vSi = 0 THEN
		INSERT INTO si_transacc SELECT * FROM si_transaccax
					 WHERE numero = vTran;
	ELSE
		UPDATE si_transacc
		   SET tipo_tran = vTpTran,
		       naturaleza = vNat,
		       tran_relac = vRelac,
		       tranlibprot = vLib,
		       dias_ret = vDias,
		       trancivaesp = vIva
		 WHERE numero = vTran
		   AND sistema = "06";
	END IF




end foreach


end procedure
;