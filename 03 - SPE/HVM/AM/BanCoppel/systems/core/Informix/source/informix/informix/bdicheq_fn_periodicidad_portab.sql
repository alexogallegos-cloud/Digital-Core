CREATE FUNCTION  "informix".fn_periodicidad_portab(pcuenta char(18),cfechini date,cfechafin date )

  returning char(5), char(20);
  
  define cod_ret char(5);
  define cCadena char(20); 
  define cCadenaTotal char(60);
  
-- ********************************************************************
-- Inicializa variables
-- ********************************************************************

	let cod_ret = "000";
	let cCadena = ''; 
	let cCadenaTotal = '';
  
		  --SET DEBUG FILE TO "/informix/oper-prod/periodicidad_portab.out";
		  --TRACE ON;
   
	FOREACH 
  
		select day(dtfechavalor)
		into cCadena
		from bdispei:tblhistpago 
		where vchrconceptopago like '%PORTABILIDAD DE NOMINA%'		
		and dtfechavalor BETWEEN cfechini and cfechafin
		and vchrcuentabenef= pcuenta
		and intcvetipopago='1'
			
		let cCadenaTotal =  trim(cCadenaTotal) || trim(cCadena) || ",";
		
	END FOREACH;
		

	return cod_ret, cCadenaTotal;
	END FUNCTION;