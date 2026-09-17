CREATE PROCEDURE "informix".spsldecmensual_gen() 
RETURNING CHAR (5), CHAR(500);

		--variables de exception
		DEFINE iSqlErr					  INTEGER;
		DEFINE cCodret                    CHAR(5);
		DEFINE cVarDataErr1               CHAR(500);
		--periodo de fecha 
		DEFINE dFormatoFechaPeriodo 	DATE;
		DEFINE dFechaUltimodia 			DATE;
		DEFINE vVnumEmp 				VARCHAR(8);
		DEFINE vTipoDeclaracion 		CHAR(1);
	
		LET vVnumEmp = '91967503';
		LET vTipoDeclaracion = 'N';
		
		BEGIN
	   	ON EXCEPTION
			
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret=iSqlErr;
				
				RETURN cCodret, cVarDataErr1 ;
			END IF;
		END EXCEPTION;	
		
		LET dFormatoFechaPeriodo='';
		LET dFechaUltimodia='';
		
	    --SET DEBUG FILE TO "/ifxsif03/ilopez/RQM_04_130/spsldecmensual_gen.out";
	    --TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Obtengo la fecha a procesar 	
		LET dFormatoFechaPeriodo = MONTH(TODAY)||'/'||'01'||'/'||YEAR(TODAY);
		LET dFechaUltimodia = dFormatoFechaPeriodo -1 UNITS MONTH;
		LET dFechaUltimodia = MONTH(dFechaUltimodia)||'/'||DAY(LAST_DAY(dFechaUltimodia))||'/'||YEAR(dFechaUltimodia);

		--EXECUTE PROCEDIMIENTO spsldecmensual
		EXECUTE PROCEDURE "informix".spsldecmensual(dFechaUltimodia,vVnumEmp,vTipoDeclaracion,dFechaUltimodia,'')  
		INTO cCodret,cVarDataErr1;
		
		IF cCodret = '00000' THEN
		   
		   LET cCodret = '00000';
		   LET cVarDataErr1 = 'PROCESO EXITOSO';
		    
		ELSE
			
			LET cVarDataErr1 = 'FALLO EN: spsldecmensual'||trim(cVarDataErr1);
			
		END IF;
		
	RETURN cCodret, cVarDataErr1;
	END
END PROCEDURE

;