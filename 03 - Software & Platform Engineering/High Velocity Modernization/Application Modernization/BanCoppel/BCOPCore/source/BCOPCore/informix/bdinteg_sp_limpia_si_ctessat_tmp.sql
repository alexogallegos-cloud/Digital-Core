CREATE PROCEDURE "informix".sp_limpia_si_ctessat_tmp()

RETURNING CHAR(5) AS CodRet;

DEFINE iSql_err 	INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE cNumcte		CHAR(50);
DEFINE cCalle		CHAR(40);
DEFINE cNumext		CHAR(10);
DEFINE cNumint		CHAR(10);
DEFINE iContador 	INTEGER;

LET iSql_err		= 0;
LET cCodRet 		= '00000';
LET cNumcte			= '';
LET cCalle			= '';
LET cNumext			= '';
LET cNumint			= '';
LET iContador       = 0;

BEGIN

	ON EXCEPTION
		SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			ROLLBACK WORK;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/emm/sp_limpia_si_ctessat_tmp.out';
	--TRACE ON;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN WORK;
	
	FOREACH WITH HOLD
	
		SELECT {+INDEX (si_ctessat_tmp idx_si_ctessat_tmp_numcte)}
			numcte,replace(calle,'|','') calle,replace(num_ext,'|','') num_ext,replace(num_int,'|','') num_int 
		INTO cNumcte,cCalle,cNumext,cNumint FROM "informix".si_ctessat_tmp
		
		LET iContador = iContador + 1;
	
		UPDATE "informix".si_ctessat_tmp SET calle=cCalle, num_int=cNumext, num_ext=cNumint WHERE numcte=cNumcte;
	
		IF( iContador = 500 ) THEN
            COMMIT WORK;
            LET iContador = 0;
			BEGIN WORK;
        END IF;
	
	END FOREACH;
	
	COMMIT WORK;	
	RETURN cCodRet;
	
END;
END PROCEDURE;