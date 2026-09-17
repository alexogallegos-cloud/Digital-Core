CREATE PROCEDURE "informix".bm_valida_usuario( pUsuario CHAR(10) ) --- Usuario
RETURNING CHAR(5)  AS vCodRet1,     --- Codigo de Retorno
          CHAR(2)  AS vStatus,      --- Status
          CHAR(25) AS vStatusDesc,  --- Descripcion del Status
          CHAR(35) AS vGeneralInfo; --- Informacion General
     
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vStatus          CHAR(2);
    DEFINE vStatusDesc      CHAR(25);
    DEFINE vGeneralInfo     CHAR(35);
    
    DEFINE vusuario         CHAR(20);
    DEFINE vid_status       CHAR(2);
    DEFINE vnumcte          CHAR(20);
    DEFINE vnumcel          CHAR(15);
    DEFINE vsecmax          INTEGER;
    DEFINE vid_oper         CHAR(4);
    DEFINE vtoken           INTEGER;
    DEFINE vSesionToken     INTEGER;
    DEFINE vtransaccion     INTEGER;
    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '00000';
    LET vCodRet2     = '00000';
    LET vCodRet3     = '';
    LET vStatus      = '00';
    LET vStatusDesc  = '';
    LET vGeneralInfo = '';
    
    LET vusuario = '';
    LET vid_status = '';
    LET vnumcte = '';
    LET vnumcel = '';
    LET vsecmax = 0;
    LET vid_oper = '';
    LET vtoken = 0;
    LET vSesionToken = 0;
    LET vtransaccion = 0;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_valida_usuario.err";
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
            RETURN vCodRet1, vStatus, vStatusDesc, vGeneralInfo;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;
    
    --- SET DEBUG FILE TO "/informix/jivan/bancamovil/bm_valida_usuario.out";
    --- TRACE ON;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF pUsuario is null OR pUsuario = '' THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Error en aplicativo.';
        LET vGeneralInfo = 'Error en aplicativo.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vGeneralInfo; 
    END IF;
    
    IF LENGTH(pUsuario) != 8 THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario incorrecto, intente de nuevo.';
        LET vGeneralInfo = 'Usuario incorrecto, intente de nuevo.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vGeneralInfo; 
    END IF;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE DATOS DEL USUARIO
    SELECT usuario, id_status, numcte, numcel
      INTO vusuario, vid_status, vnumcte, vnumcel
      FROM bdinteg:"informix".si_bm_usuarios
     WHERE usuario = pUsuario;
     
    IF (vusuario is null OR vusuario = '' OR vusuario <> pUsuario) THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario incorrecto, intente de nuevo.';
        LET vGeneralInfo = 'Usuario incorrecto, intente de nuevo.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vGeneralInfo; 
    END IF;
    
    IF (vid_status <> '30') OR 
       (vnumcte is null OR vnumcte = '' ) OR 
       (vnumcel is null OR vnumcel = '') THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Datos incorrectos, verifique.';
        LET vGeneralInfo = 'Datos incorrectos, verifique.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vGeneralInfo; 
    END IF;
    
    -- // OBTIENE MAXIMA SECUENCIA DEL CLIENTE EN LA BITACORA
    SELECT MAX(secuencia)
      INTO vsecmax
      FROM bdinteg:"informix".si_bm_bitacora
     WHERE DATE(fech_oper) = CURRENT::DATE
       AND numcte = vnumcte
       AND numcel = vnumcel;
       
    IF vsecmax is null THEN
        LET vsecmax = 0;
    END IF;
       
    -- // VALIDA QUE EL ULTIMO REGISTRO EN BITACORA SEA FIN DE SESION
    IF vsecmax > 0 THEN
        SELECT id_oper
          INTO vid_oper
          FROM bdinteg:"informix".si_bm_bitacora
         WHERE DATE(fech_oper) = CURRENT::DATE
           AND numcte = vnumcte
           AND numcel = vnumcel
           AND secuencia = vsecmax;
           
        IF vid_oper <> '1001' THEN
            LET vCodRet1 = '11111';
            LET vStatus = '';
            LET vStatusDesc = 'Error en aplicativo.';
            LET vGeneralInfo = 'Error en aplicativo.';
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vStatus, vStatusDesc, vGeneralInfo; 
        END IF;
    END IF;
    
    -- // GENERA EL NUMERO DE SESSION 
    SELECT valor::int
      INTO vtoken
      FROM bdibpi:"informix".tkn_parametros
     WHERE id_param = '52';
     
    IF vtoken is null THEN
        LET vtoken = 1;
    ELSE
        LET vtoken = vtoken + 1;
    END IF;
    
    UPDATE bdibpi:"informix".tkn_parametros
       SET valor = vtoken
     WHERE id_param = '52';
     
    LET vSesionToken = vtoken;
    LET vsecmax = vsecmax + 1;
       
    -- // GENERA REGISTRO EN BITACORA COMO LOGIN-USUARIO
    INSERT INTO bdinteg:"informix".si_bm_bitacora(id_session, fech_oper, numcte, secuencia, id_oper, numcel, cuenta, foliosol)
    VALUES(vSesionToken, current, vnumcte, vsecmax, '2201', vnumcel, null, null);
    
    IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Error en aplicativo.';
        LET vGeneralInfo = 'Error en aplicativo.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vGeneralInfo; 
    END IF;
    
    -- // OBTIENE EL NOMBRE CORTO DEL CLIENTE
    SELECT TRIM(nombre1)||' '||TRIM(apell_paterno)
      INTO vGeneralInfo
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = vnumcte;
     
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;

    RETURN vCodRet1, vStatus, vStatusDesc, vGeneralInfo;
    
    END;

END PROCEDURE;