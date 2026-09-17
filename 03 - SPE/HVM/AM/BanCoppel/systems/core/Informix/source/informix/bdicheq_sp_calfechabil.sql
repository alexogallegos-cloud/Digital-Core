CREATE PROCEDURE "informix".sp_calfechabil( pPriDiaNaturalMes  DATE, pDiasBloque integer)
    RETURNING  VARCHAR(5),        
               DATE;              

    DEFINE cVarDataErr   VARCHAR(64);
    DEFINE iSqlErr       INTEGER;
    DEFINE iSamErr       INTEGER;
    
    DEFINE cCodret       CHAR(5);
    DEFINE dFechaActual  DATE   ;
    DEFINE i,j           INTEGER;
    DEFINE siFeriado     INTEGER;
	
	LET cCodret = '000';
	
    BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET cCodret=iSqlErr;
            RETURN cCodret, cVarDataErr;
        END IF;
    END EXCEPTION;

	--SET   DEBUG FILE TO '/RESPALDOSNEW/rsv/portabilidad/sp_calFechAbil.txt';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
    LET i = 0;
    LET j = 0;	
    WHILE i <= pDiasBloque 
	LET dFechaActual = pPriDiaNaturalMes + j;
	LET siFeriado = 0;

	IF (WEEKDAY(dFechaActual) >= 1 AND WEEKDAY(dFechaActual) <= 5) THEN
        SELECT COUNT(*) 
	    INTO   siFeriado       
	    FROM   bdinteg:si_feriado
	    WHERE  fecha = dFechaActual;

	    IF siFeriado IS NULL OR siFeriado = 0 THEN
	       LET i = i + 1;
	    END IF;
	END IF;
	LET j = j + 1;
    END WHILE

   RETURN cCodret,dFechaActual;
END
END PROCEDURE;