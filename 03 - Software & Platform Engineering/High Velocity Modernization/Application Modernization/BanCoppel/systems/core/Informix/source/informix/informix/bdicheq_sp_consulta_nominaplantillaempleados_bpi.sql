CREATE PROCEDURE "informix".sp_consulta_nominaplantillaempleados_bpi(pNumCliente CHAR(9), pCvePlantilla INTEGER, numPosicion SMALLINT)
	returning CHAR(5),INTEGER, CHAR(30),MONEY;
	
	DEFINE vCodRet char(5);
	DEFINE sql_err INTEGER;

    DEFINE sClave INTEGER;
    DEFINE sNumEmpleado CHAR(30);

    DEFINE sImporte MONEY;
	--Inicializar variables
	LET vCodRet  = "00000";
	LET sClave      = 0;
    LET sNumEmpleado  = "";
    LET sImporte = 0;

	--****************************************************************************************************
	-- DESCRIPCION: Consulta empleados  asociados a  una plantilla Nomina por num cliente
	-- AUTOR: Solser
	-- BD: bdicheq
	-- SOLICITO: BanCoppel
	-- Fecha: Diciembre 2021
	--***************************************************************************************************

	BEGIN
	   	ON EXCEPTION SET sql_err
	    	IF sql_err <> 0 THEN
	        	let vCodRet = sql_err;
                RETURN vCodRet, sClave,sNumEmpleado, sImporte;
	      	END IF ;
	   	END EXCEPTION ;


	    IF(LENGTH(TRIM(NVL(pNumCliente,''))) = 0) THEN
	        LET vCodRet="00001";
            RETURN vCodRet, sClave,sNumEmpleado, sImporte;
	    END IF;
     

	   	SET LOCK MODE TO WAIT 4;
           

    FOREACH
        SELECT skip numPosicion limit 10 cve_plantilla,num_empleado, importe
        INTO  sClave,sNumEmpleado, sImporte
        FROM bdicheq:sc_nominaplantillaempleados_bpi
        WHERE num_cte=pNumCliente and cve_plantilla = pCvePlantilla
       

	  RETURN vCodRet,sClave,sNumEmpleado,sImporte WITH RESUME;
    END FOREACH;
	END
END PROCEDURE;