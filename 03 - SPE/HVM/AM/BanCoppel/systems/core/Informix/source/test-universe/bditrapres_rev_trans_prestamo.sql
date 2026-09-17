CREATE PROCEDURE "informix".rev_trans_prestamo( psucursal char(4), 
                                                pusuario char(8), 
                                                pfolio char(16) )
RETURNING CHAR(5);

    DEFINE sql_err             integer;
    DEFINE isam_err            integer;
    DEFINE cod_ret1            char(5);
    DEFINE cod_ret2            char(5);
    DEFINE vtransaccion 	   integer;
    DEFINE vexiste_folio       smallint;

    LET sql_err = 0;
    LET isam_err = 0;
    LET cod_ret1 = "000";
    LET cod_ret2 = "000";
    LET vtransaccion = 0;
    LET vexiste_folio = 0;

    -- SET DEBUG FILE TO "/resplogifx/conciliachq/rev_trans_prestamo.out";
    -- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err
        IF (sql_err <> 0) THEN
            -- SET DEBUG FILE TO "/resplogifx/conciliachq/rev_trans_prestamo.err";
            -- TRACE ON;
            LET cod_ret1 = sql_err;
            LET cod_ret2 = isam_err;
            IF vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            RETURN cod_ret1;
        END IF;
    END EXCEPTION;

    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH resume;

    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF (psucursal is null OR psucursal = '' OR LENGTH(psucursal) <> 4) OR
       (pusuario is null OR pusuario = '' OR LENGTH(pusuario) <> 8) OR
       (pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16) THEN
        
        LET cod_ret1 = '005';
        
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        
        RETURN cod_ret1;
    ELSE
        EXECUTE PROCEDURE bdicheq:reversion( '001',     -- empresa
                                             psucursal, -- sucursal
                                             pusuario,  -- usuario
                                             pfolio,    -- folio
                                             'A')       -- tipo reversion
        INTO cod_ret1;
        
        IF cod_ret1 = '000' THEN
            SELECT COUNT(*)
              INTO vexiste_folio
              FROM bdicheq:sc_acumtrapres
             WHERE folio_suc = pfolio;
             
            IF vexiste_folio > 0 THEN
                DELETE FROM bdicheq:sc_acumtrapres
                 WHERE folio_suc = pfolio;
            END IF;
        ELSE
            IF cod_ret1 = '413' THEN
                LET cod_ret1 = '413';
            END IF;
            
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            
            RETURN cod_ret1;
        END IF;
    END IF;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK; 
    END IF;
    
    RETURN cod_ret1;

    END;

END PROCEDURE;