CREATE PROCEDURE "informix".ss_insert_ss_cte_evaluacion_pmb (pNumcte CHAR (20), pAceptoEvaluacion CHAR(1))
RETURNING
	CHAR(6) AS cCodRet;

    --DEFINICION DE VARIABLES DE ERROR
    DEFINE iSqlErr         INTEGER;
    DEFINE iIsamErr        INTEGER;
    DEFINE cCodRet         CHAR(6);

    --DECLARACION DE VARIABLES DE ERROR
    LET iSqlErr  = 0;
    LET iIsamErr = 0;
    LET cCodRet  ="000000";

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet;
       END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    --SET debug file to '/home/sysifx/OscarOjeda/ss_insert_ss_cte_evaluacion_pmb.out';
    --TRACE ON; 

    IF NVL(pNumcte,"") = "" OR NVL(pAceptoEvaluacion,"") = ""  THEN

		  LET cCodRet = "000001"; -- Parametros de entrada insuficiontes

    ELSE
	
		IF NOT EXISTS(select numcte from bdisolic:ss_cte_evaluacion_pmb where numcte = pNumcte ) THEN
			INSERT INTO  bdisolic:ss_cte_evaluacion_pmb (numcte, acepto_evaluacion)
			VALUES  (pNumcte , pAceptoEvaluacion );
		END IF;
    END IF;	

	RETURN cCodRet; 
END
END PROCEDURE
