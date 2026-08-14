CREATE PROCEDURE "informix".sp_obtsigfolioop(chrTipoFolio varchar(20))
RETURNING CHAR(5), integer;

    --// ***************************************************************************
    --// sp_obtsigfolioop
    --// Version              1.0.0
    --// Obejtivo:            Obtiene el siguiente folio registrado en tblparametros
    --// Creado por:          Alejandro Rueda Sanchez
    --// ModIFicado por:
    --// Ultima Modificacion: Febrero - 2009
    --// ***************************************************************************

    -- // Definicion de variables
    DEFINE chrCodRet        CHAR(5);
    DEFINE chrCodRet2       CHAR(5);
    DEFINE chrCodRet3       CHAR(50);
    DEFINE vsqlerr	        INTEGER;
    DEFINE visamerr	        INTEGER;
    DEFINE vdescerr	        CHAR(50);
    DEFINE vtransaccion     INTEGER;
    DEFINE intFolio         INTEGER;
    
    LET chrCodRet    = '000';
    LET vsqlerr      = 0;
    LET vtransaccion = 0;
    LET intFolio     = 0;

    BEGIN

    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtsigfolioop.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET chrCodRet = vsqlerr;
            LET chrCodRet2 = visamerr;
            LET chrCodRet3 = vdescerr;
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            RETURN chrCodRet,0;
        END IF
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT vchrValor
      INTO intFolio
      FROM tblParametros
     WHERE vchrCveParametro = chrTipoFolio;

    IF intFolio IS NULL THEN
        INSERT INTO tblParametros(vchrcveparametro, vchrvalor) 
        VALUES(chrTipoFolio, 1);
        
        LET intFolio = 1;
    ELSE
        LET intFolio = intFolio + 1;

        IF chrTipoFolio = 'FOLIO_CVERASTREO' AND intFolio > 9999900 THEN
            LET intFolio = 1;
        END IF

        UPDATE tblParametros
           SET vchrValor = intFolio
         WHERE vchrCveParametro = chrTipoFolio;
    END IF
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;

    RETURN chrCodRet, intFolio;

    END;
    
END PROCEDURE;