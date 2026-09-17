CREATE PROCEDURE "informix".sp_hojafirmactamec_complementoinfo(pCuenta CHAR(20))

RETURNING CHAR(5)   AS cCodRet,
		  CHAR(100) AS cMensaje,
		  CHAR(20)  AS numcliente,
		  CHAR(50)   AS tipofirma;
		  


--****************************************************************************************************
-- Objetivo:Spl que obtiene informaciÃ³n de clientes y tipo se firma
-- Autor: Nadia Ordaz
-- FECHA : 24/07/2024
-- SOLICITO : Ismael Hernandez
-- BD: bdicnweb
--***************************************************************************************************

--DEFINICIONES
	DEFINE iSql_Err                     INTEGER;
	DEFINE cCodRet         			    CHAR(5);
	DEFINE cMensaje                     CHAR(50);
	
	DEFINE numcliente         			CHAR(20);
	DEFINE tipofirma                    CHAR(50);
            
--INICIALIZACIONES			  
    LET iSql_Err           	= 0;
    LET cCodRet           	= '00000';
    LET cMensaje          	= 'SE EJECUTO CORRECTAMENTE';
	
    LET numcliente          = '';
    LET tipofirma           = '';
	
BEGIN

    ON EXCEPTION SET iSql_Err
        LET cCodRet = iSql_Err;
        LET cMensaje = '';
		RETURN cCodRet, cMensaje, numcliente, tipofirma;
    END EXCEPTION;
	
	-- SET DEBUG FILE TO "/home/sysifx/vlv/hojafirmaCtaMEC.out";
	-- TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF TRIM(NVL(pCuenta,'')) = '' THEN
		LET cCodRet = '00001';
		LET cMensaje = 'FALTAN PARAMETROS PARA SU EJECUCION';
		RETURN cCodRet, cMensaje, numcliente, tipofirma;
	END IF;

	FOREACH cur for							
		SELECT numcte, tipo_firma
		INTO numcliente, tipofirma
		FROM bdicheq:"informix".sc_firmantes
		WHERE empresa = '001'
			AND cuenta = pCuenta
		ORDER BY secuencia ASC
		
		RETURN cCodRet, cMensaje, numcliente, tipofirma WITH RESUME;
		
	END FOREACH;	
END;

END PROCEDURE;