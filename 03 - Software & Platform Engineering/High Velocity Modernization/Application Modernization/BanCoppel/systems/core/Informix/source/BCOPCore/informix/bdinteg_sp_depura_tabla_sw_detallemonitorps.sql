CREATE PROCEDURE "informix".sp_depura_tabla_sw_detallemonitorps() RETURNING CHAR(5) AS cod_retorno;



--DEFINICION DE VARIABLES
DEFINE vcodRet 		    VARCHAR(6); 	-- CODIGO DE RETORNO
DEFINE iSqlErr      	integer;
DEFINE cMensaje		    VARCHAR(100);
DEFINE nContador        INT;


--INICIALIZACION DE VARIABLES
LET vcodRet 			= '00000';
LET iSqlErr             = 0;
LET cMensaje		    = 'ERROR EN PASO: ';
LET nContador       	= 0;


	
BEGIN 
			ON EXCEPTION SET iSqlErr
						IF iSqlErr <> 0 THEN
							LET vcodRet = iSqlErr;
						END IF;
			END EXCEPTION;
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/tmp/masv/sp_depura_tabla_sw_detallemonitorps.out";
		--TRACE ON;
	
	
	SELECT COUNT(*) INTO nContador FROM "informix".sw_detallemonitorps;
	
	IF nContador <> 0 THEN 
	
	TRUNCATE TABLE "informix".sw_detallemonitorps;
	
	LET vCodRet ='00000';
	
	
	
		
	END IF;
	return vCodRet;
END;
END PROCEDURE ;