CREATE PROCEDURE "informix".bm_nuevo_usuario( pUsuario  CHAR(10),  --- Usuario
                                              pFolio    CHAR(12),  --- Folio 
                                              pCelular  DECIMAL(10,0),   --- No. Celular
                                              pPassword CHAR(50) ) --- Contraseña
RETURNING CHAR(5)  AS vCodRet1,     --- Codigo de Retorno
          CHAR(2)  AS vStatus,      --- Status
          CHAR(25) AS vStatusDesc,  --- Descripcion del Status
          INTEGER  AS vSesionToken, --- Session Token
          CHAR(35) AS vGeneralInfo; --- Informacion General
    
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vStatus          CHAR(2);
    DEFINE vStatusDesc      CHAR(25);
    DEFINE vSesionToken     INTEGER;
    DEFINE vGeneralInfo     CHAR(35);
    
    DEFINE vexiste_usuario  SMALLINT;
    DEFINE vnumcte          CHAR(20);
    DEFINE vfolio_contrato  CHAR(12);
    DEFINE vnumcel          DECIMAL(10,0);
    DEFINE vid_status       CHAR(2);    
    DEFINE vtoken           INTEGER;
    DEFINE vtransaccion     INTEGER;
    
    LET Sql_Err	 = 0;
    LET Isam_Err = 0;
    LET Desc_Err = '';
    LET vCodRet1 = '00000';
    LET vCodRet2 = '00000';
    LET vCodRet3 = '';
    LET vStatus  = '00';
    LET vStatusDesc = '';
    LET vSesionToken = 0;
    LET vGeneralInfo = '';
    
    LET vexiste_usuario = 0;
    LET vnumcte = '';
    LET vfolio_contrato = '';
    LET vnumcel = 0;
    LET vid_status = '';    
    LET vtoken = 0;
    LET vtransaccion = 0;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_nuevo_usuario.err";
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
            RETURN vCodRet1, vStatus, vStatusDesc, vSesionToken, vGeneralInfo;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_nuevo_usuario.out";
    --- TRACE ON;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;

    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pUsuario is null OR pUsuario = '') OR
       (pFolio is null OR pFolio = '') OR
       (pCelular is null OR pCelular = 0) OR
       (pPassword is null OR pPassword = '') THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Error en aplicativo.';
        LET vSesionToken = 0;
        LET vGeneralInfo = 'Error en aplicativo.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vSesionToken, vGeneralInfo; 
    END IF;
    
    IF LENGTH(pUsuario) != 8 THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario incorrecto, intente de nuevo.';
        LET vSesionToken = 0;
        LET vGeneralInfo = 'Usuario incorrecto, intente de nuevo.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vSesionToken, vGeneralInfo; 
    END IF;
    
    IF LENGTH(pCelular::CHAR(10)) < 10 THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Celular incorrecto, intente de nuevo.';
        LET vSesionToken = 0;
        LET vGeneralInfo = 'Celular incorrecto, intente de nuevo.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vSesionToken, vGeneralInfo; 
    END IF;
        
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA QUE EL USUARIO NO EXISTA
    SELECT COUNT(*)
      INTO vexiste_usuario
      FROM bdinteg:"informix".si_bm_usuarios
     WHERE usuario = pUsuario;
     
    IF vexiste_usuario > 0 THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario ya existe.';
        LET vSesionToken = 0;
        LET vGeneralInfo = 'Usuario ya existe.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vSesionToken, vGeneralInfo; 
    END IF;
    
    -- // OBTIENE EL NUMERO DE CLIENTE Y EL STATUS DE LA SOLICITUD
    SELECT numcte, folio_contrato, numcel, id_status
      INTO vnumcte, vfolio_contrato, vnumcel, vid_status
      FROM bdinteg:"informix".si_bm_usuarios
     WHERE folio_contrato = pFolio
       AND numcel = pCelular;
       
    IF (vnumcte is null OR vnumcte = '') OR
       (vfolio_contrato is null OR vfolio_contrato = '' OR vfolio_contrato <> pFolio) OR
       (vnumcel is null OR vnumcel = '' OR vnumcel <> pCelular) OR 
       (vid_status <> '20') THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Datos incorrectos, verifique.';
        LET vSesionToken = 0;
        LET vGeneralInfo = 'Datos incorrectos, verifique.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vSesionToken, vGeneralInfo; 
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
    
    -- // ACTUALIZA USUARIO
    UPDATE bdinteg:"informix".si_bm_usuarios
       SET usuario = pUsuario,
           password = pPassword,
           fech_pass = current,
           id_status = '30',
           fech_registro = current
     WHERE numcte = vnumcte
       AND folio_contrato = pFolio
       AND numcel = pCelular;
       
    IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Error en aplicativo.';
        LET vSesionToken = 0;
        LET vGeneralInfo = 'Error en aplicativo.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vSesionToken, vGeneralInfo; 
    END IF;
    
    INSERT INTO bdinteg:"informix".si_bm_camestcte(numcte, id_statant, id_statact, numcel, fecha_mod, suc_mod, user_mod)
    VALUES(vnumcte, vid_status, '30', pCelular, current, '5002', 'informix');
    
    LET vStatusDesc = 'Usted se ha dado de alta correctamente.';
    LET vGeneralInfo = 'Usted se ha dado de alta correctamente.';
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
    
    RETURN vCodRet1, vStatus, vStatusDesc, vSesionToken, vGeneralInfo;
    
    END;
    
END PROCEDURE;