CREATE PROCEDURE "informix".sp_consulta_nominaplantilla_bpi(pNumCliente CHAR(9), numPosicion SMALLINT)
	returning char(5),INTEGER, CHAR(10) ;

	--Declaracion de variables
	DEFINE vCodRet char(5);
	DEFINE sql_err INTEGER;

  
    DEFINE sNombre               CHAR(10);
    DEFINE sClave               INTEGER;

	--Inicializar variables
	LET vCodRet  = "00000";
    LET sNombre  = "";
    LET sClave      = 0;

	--****************************************************************************************************
	-- DESCRIPCION: Consulta lista  de plantillas 
	-- AUTOR: Solser
	-- BD: bdicheq
	-- SOLICITO: BanCoppel
	-- Fecha: Enero 2022
	--***************************************************************************************************

	BEGIN
	   	ON EXCEPTION SET sql_err
	    	IF sql_err <> 0 THEN
	        	let vCodRet = sql_err;
                RETURN vCodRet, sClave,sNombre;
	      	END IF ;
	   	END EXCEPTION ;


	    IF(LENGTH(TRIM(NVL(pNumCliente,''))) = 0) THEN
	        LET vCodRet="00001";
             RETURN vCodRet, sClave,sNombre;
	    END IF;
     

	   	SET LOCK MODE TO WAIT 4;
           

    FOREACH
        SELECT skip numPosicion limit 10 cve_plantilla,nombre
        INTO  sClave,sNombre
        FROM bdicheq:sc_nominaplantilla_bpi
        WHERE num_cte=pNumCliente
       

	  RETURN vCodRet,sClave,sNombre WITH RESUME;
    END FOREACH;
	END
END PROCEDURE;