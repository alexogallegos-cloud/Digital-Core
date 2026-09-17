CREATE PROCEDURE "informix".bm_logout( pSessionToken INTEGER ) --- Session Token
RETURNING CHAR(5)  AS vCodRet1,     --- Codigo de Retorno
          CHAR(2)  AS vStatus,      --- Status
          CHAR(25) AS vStatusDesc;  --- Descripcion del Status
    
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vStatus          CHAR(2);
    DEFINE vStatusDesc      CHAR(25);
    DEFINE vnumcte          CHAR(20);
    DEFINE vnumcel          CHAR(15);
    DEFINE vsecmax          INTEGER;
    DEFINE vid_oper         CHAR(4);
    DEFINE vtransaccion     INTEGER;
    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '00000';
    LET vCodRet2     = '00000';
    LET vCodRet3     = '';
    LET vStatus      = '00';
    LET vStatusDesc  = '';
    LET vnumcte = '';
    LET vnumcel = '';
    LET vsecmax = 0;
    LET vid_oper = '';
    LET vtransaccion = 0;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_logout.err";
        --- TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vStatus, vStatusDesc;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_logout.out";
    --- TRACE ON;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    IF pSessionToken is null OR pSessionToken = 0 THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Error en aplicativo.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc;
    END IF;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE MAXIMA SECUENCIA DEL CLIENTE EN LA BITACORA
    SELECT MAX(secuencia)
      INTO vsecmax
      FROM bdinteg:"informix".si_bm_bitacora
     WHERE DATE(fech_oper) = CURRENT::DATE
       AND id_session = pSessionToken;
       
    IF vsecmax is null THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc;
    END IF;
    
    SELECT id_oper, numcte, numcel
      INTO vid_oper, vnumcte, vnumcel
      FROM bdinteg:"informix".si_bm_bitacora
     WHERE DATE(fech_oper) = CURRENT::DATE
       AND id_session = pSessionToken
       AND secuencia = vsecmax;
    
    IF vid_oper is null OR vid_oper = '' THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc;
    END IF;
    
    IF vid_oper = '1001' THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc;
    END IF;
    
    IF vid_oper IN('1000', '1002', '1003', '1004', '1005') THEN
        -- // GENERA REGISTRO EN BITACORA COMO PASSWORD-USUARIO
        LET vsecmax = vsecmax + 1;
        
        INSERT INTO bdinteg:"informix".si_bm_bitacora(id_session, fech_oper, numcte, secuencia, id_oper, numcel, cuenta, foliosol)
        VALUES(pSessionToken, current, vnumcte, vsecmax, '1001', vnumcel, null, null);
        
        IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
            LET vCodRet1 = '11111';
            LET vStatus = '';
            LET vStatusDesc = 'Error en aplicativo.';
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vStatus, vStatusDesc;
        END IF;
    ELSE
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc;
    END IF;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
    
    RETURN vCodRet1, vStatus, vStatusDesc;
    
    END;
    
END PROCEDURE;