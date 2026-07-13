CREATE PROCEDURE "informix".sp_nominaplantillaempleados_bpi(pNumCliente CHAR(9), pCvePlantilla INTEGER, pNumEmpleado CHAR(30), pImporte MONEY)
	returning char(5) ;

	--DeclaraciÃ³n de variables
	DEFINE vCodRet char(5);
	DEFINE sql_err INTEGER;

  


	--Inicializar variables
	LET vCodRet  = "00000";


	--****************************************************************************************************
	-- DESCRIPCION: Guardar empleados asociadops a una plantila de nomina
	-- AUTOR: Solser
	-- BD: bdicheq
	-- SOLICITO: BanCoppel
	-- Fecha: Diciembre 2021
	--***************************************************************************************************

	BEGIN
	   	ON EXCEPTION SET sql_err
	    	IF sql_err <> 0 THEN
	        	let vCodRet = sql_err;
                RETURN vCodRet;
	      	END IF ;
	   	END EXCEPTION ;


	    IF(LENGTH(TRIM(NVL(pNumCliente,''))) = 0 OR LENGTH(TRIM(NVL(pCvePlantilla,''))) = 0) THEN
	        LET vCodRet="00001";
             RETURN vCodRet;
	    END IF;
     

	   	SET LOCK MODE TO WAIT 4;
           

 	
		INSERT INTO bdicheq:sc_nominaplantillaempleados_bpi
			(num_cte, cve_plantilla, num_empleado, importe)
		VALUES 	(pNumCliente, pCvePlantilla, pNumEmpleado, pImporte);
            

	 	RETURN vCodRet;

	END
END PROCEDURE;