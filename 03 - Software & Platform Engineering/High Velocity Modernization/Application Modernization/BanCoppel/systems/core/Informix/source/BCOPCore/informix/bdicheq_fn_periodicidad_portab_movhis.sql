CREATE FUNCTION "informix".fn_periodicidad_portab_movhis(dcuenta char(18),cfechini date,cfechafin date )

  returning char(5), char(20);

  define cod_ret char(5);
  define cCadena char(20);
  define cCadenaTotal char(20);

-- ********************************************************************
-- Inicializa variables
-- ********************************************************************

	let cod_ret = "000";
	let cCadena = '';
	let cCadenaTotal = '';

		  --SET DEBUG FILE TO "/informix/oper-prod/periodicidad_portab_movhis.out";
		  --TRACE ON;

	FOREACH

		select {+INDEX(sc_movhis idx_movhisnew4)} day(fech_alt)
		into cCadena
		from bdicheq: sc_movhis
		where transacc in ('0287','0293')
		and cuenta= dcuenta
		and fech_alt BETWEEN cfechini and cfechafin


		let cCadenaTotal =  trim(cCadenaTotal) || trim(cCadena) || ",";

	END FOREACH;

	return cod_ret, cCadenaTotal;
	END FUNCTION;