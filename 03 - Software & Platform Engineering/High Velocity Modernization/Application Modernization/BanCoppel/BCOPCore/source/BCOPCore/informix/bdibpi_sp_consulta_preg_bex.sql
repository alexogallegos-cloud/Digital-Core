CREATE PROCEDURE "informix".sp_consulta_preg_bex()
	RETURNING 	CHAR(2), CHAR(200);
--DEFINICION DE VARIABLES
DEFINE iSqlErr 		INTEGER;
DEFINE idPreg 		CHAR(2);
DEFINE desPreg 		CHAR(200);
DEFINE iCont		INTEGER;

--INICIALIZACION DE VARIABLES
LET iSqlErr 	 = 0;
LET idPreg 		 = '';
LET desPreg 	 = '';
LET iCont 		= 0;


--SET DEBUG FILE TO '/tmp/sp_valtel_ctedupout.SQL';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET idPreg = iSqlErr;			
			RETURN idPreg,desPreg;
		END IF;
	END EXCEPTION;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	FOREACH 
		SELECT {+INDEX(bpi_cat_encuenta_bex idx_encuenta_bex)} trim(id_pregunta),trim(pregunta) INTO idPreg,desPreg FROM bpi_cat_encuenta_bex WHERE estatus='1' ORDER BY id_pregunta
		
		LET iCont = iCont + 1;
		IF(iCont < 100 ) THEN
			RETURN trim(idPreg),trim(desPreg) WITH RESUME;
		END IF
		
    END FOREACH;

--RETURN idPreg,desPreg;
END;
END PROCEDURE;