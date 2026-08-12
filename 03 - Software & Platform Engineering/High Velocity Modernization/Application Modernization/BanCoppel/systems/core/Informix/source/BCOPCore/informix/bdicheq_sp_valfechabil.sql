CREATE PROCEDURE "informix".sp_valfechabil( pFecha DATE, pSentido CHAR(1) )

RETURNING VARCHAR(5), DATE; -- // CodigoRetorno, Fecha Habil del bloque

    -- *******************************************************************
    -- sp_valfechabil
    -- Version              1.0.0
    -- Obejtivo:            Calcula si la fecha es habil
    -- Creado por:          Alejandro Rueda Sanchez
    -- ModIFicado por:
    -- Ultima ModIFicacion: Abril-2008
    --                      Creación de SPL
    -- *******************************************************************

    DEFINE cVarDataErr      VARCHAR(64);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cCodRet          CHAR(5);
    DEFINE dFechaActual     DATE;
    DEFINE i, j             INTEGER;
    DEFINE vexiste          SMALLINT;

    BEGIN
    
    ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET cCodret = iSqlErr;
            RETURN cCodret, cVarDataErr;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/tmp/sp_valfechabil.out";
    --- TRACE ON;

set isolation to dirty read;
    
    -- // Calcula si es habil, hasta completar el bloque
    LET i = 0;
    LET j = 0;
    
    WHILE j <= i
    
        IF pSentido = "-" THEN
            LET dFechaActual = pFecha - i;
        ELSE
            LET dFechaActual = pFecha + i;
        END IF;
        
        SELECT {+INDEX(bdinteg:si_feriado idx_feriado)} COUNT(*)
          INTO vexiste
          FROM bdinteg:si_feriado
         WHERE fecha = dFechaActual
           AND empresa = '001'
           AND laborable = 'N';
           
        IF vexiste > 0 THEN
            LET i = i + 1;
        ELSE
            EXIT WHILE;
        END IF;
        
        { **************************************
        IF EXISTS (SELECT laborable
                     FROM bdinteg:si_feriado
                    WHERE fecha = dFechaActual
                      AND laborable = "N") THEN
            LET i = i + 1;
        ELSE
            EXIT WHILE;
        END IF;
        **************************************** }
        
        LET j = i;
        
    END WHILE

    RETURN '000', dFechaActual;
    
    END
    
END PROCEDURE;