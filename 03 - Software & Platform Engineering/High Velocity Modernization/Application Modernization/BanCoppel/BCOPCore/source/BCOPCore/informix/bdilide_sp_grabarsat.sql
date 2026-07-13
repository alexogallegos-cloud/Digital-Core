CREATE PROCEDURE "informix".sp_grabarsat(pNumCte CHAR(20),
                                         pRFC CHAR(13),
                                         pFechaCons DATE,
                                         pUserInsert CHAR(8))
RETURNING CHAR(6);
    
    --*************************************************
    -- Creado por: Anselmo Verdugo                  --*
    -- Actividad: Realiza registro a la tabla bdilide:sl_constat.
    --  Solicitó: Aymme Osuna                       --*
    --     Fecha: 02/SEP/2008                       --*
    --*************************************************

    -- // DEFINICIÓN DE LAS VARIABLES.
    DEFINE cCodRet       CHAR(6);
    DEFINE isql_err      INTEGER;
    DEFINE dFechaInsert  DATE;
    DEFINE vexiste       INTEGER;

    BEGIN
    -- // MANEJADOR DE EXEPCIONES
    ON EXCEPTION SET isql_err
        LET cCodRet = isql_err;
        RETURN cCodRet;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/dbexportb/vlv/sp_grabarsat.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // INICIALIZACIÓN DE VARIABLES
    LET cCodRet      = '000';
    LET isql_err     = '0';
    LET dFechaInsert = '01-01-2000';
    LET vexiste      = 0;

    -- // Verifica si se estan enviando todos los parametros.
    IF (pNumCte = '' OR pNumCte IS NULL) OR (pRFC = '' OR pRFC IS NULL) OR (pFechaCons = '' OR pFechaCons IS NULL) OR (pUserInsert = '' OR pUserInsert IS NULL) THEN 
        LET cCodRet = '001';
        RETURN cCodRet;
    END IF;

    SELECT COUNT(*)
      INTO vexiste
      FROM bdilide:"informix".sl_consat 
     WHERE rfc = pRFC 
       AND fecha_sol = pFechaCons;

    IF vexiste > 0 THEN
    --- IF EXISTS (SELECT rfc FROM bdilide:"informix".sl_consat WHERE rfc = pRFC AND fecha_sol = pFechaCons ) THEN
        LET cCodRet = '002';  -- Ya se corrio el proceso el dia de hoy.
        RETURN cCodRet;
    END IF;

    INSERT INTO bdilide:"informix".sl_consat(Num_cte,rfc, fecha_sol, estado, fecha_res, nombre_arch, user_insert)
    VALUES(pNumCte, pRFC, pFechaCons, 'P', dFechaInsert, '', pUserInsert);

    RETURN cCodRet;
    
    END;
    
END PROCEDURE
