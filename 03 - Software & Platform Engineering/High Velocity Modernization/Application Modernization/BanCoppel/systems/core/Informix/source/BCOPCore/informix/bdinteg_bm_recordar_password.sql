CREATE PROCEDURE "informix".bm_recordar_password( pUsuario     CHAR(10),  --- Usuario
                                                  pFolio       CHAR(12),  --- Folio
                                                  pCelular     DECIMAL(10,0),   --- No. Celular
                                                  pPasswordNvo CHAR(50) ) --- Contraseña Nueva
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
    
    DEFINE vpassword        CHAR(50);
    DEFINE vnumcte          CHAR(20);
    DEFINE vfolio_contrato  CHAR(12);
    DEFINE vnumcel          DECIMAL(10,0);
    DEFINE vexiste_usuario  SMALLINT;
    DEFINE vsecmax          INTEGER;
    DEFINE vtoken           INTEGER;
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
    LET vSesionToken = 1234567890;
    LET vGeneralInfo = '';
    
    LET vpassword = '';
    LET vnumcte = '';
    LET vfolio_contrato = '';
    LET vnumcel = 0;
    LET vexiste_usuario = 0;
    LET vsecmax = 0;
    LET vtoken = 0;
    LET vid_oper = '';
    LET vtransaccion = 0;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_recordar_password.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_recordar_password.out";
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
       (pPasswordNvo is null OR pPasswordNvo = '') THEN
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
    
    IF LENGTH(pUsuario) <> 8 THEN
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
    
    -- // OBTIENE EL NUMERO DE CLIENTE
    SELECT numcte, folio_contrato, numcel
      INTO vnumcte, vfolio_contrato, vnumcel
      FROM bdinteg:"informix".si_bm_usuarios
     WHERE usuario = pUsuario
       AND folio_contrato = pFolio
       AND numcel = pCelular;
     
    IF (vnumcte is null OR vnumcte = '') OR
       (vfolio_contrato is null OR vfolio_contrato = '' OR vfolio_contrato <> pFolio) OR
       (vnumcel is null OR vnumcel = '' OR vnumcel <> pCelular) THEN
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
     
    -- // OBTIENE MAXIMA SECUENCIA DEL CLIENTE EN LA BITACORA
    SELECT MAX(secuencia)
      INTO vsecmax
      FROM bdinteg:"informix".si_bm_bitacora
     WHERE DATE(fech_oper) = CURRENT::DATE
       AND numcte = vnumcte;
       
    IF vsecmax is null THEN
        LET vsecmax = 0;
    END IF;
    
    IF vsecmax > 0 THEN
        SELECT id_oper
          INTO vid_oper
          FROM bdinteg:"informix".si_bm_bitacora
         WHERE DATE(fech_oper) = CURRENT::DATE
           AND numcte = vnumcte
           AND numcel = pCelular
           AND secuencia = vsecmax;
           
        IF vid_oper IN('2201', '1000', '1002', '1003', '1004', '1005') THEN
            LET vCodRet1 = '11111';
            LET vStatus = '';
            LET vStatusDesc = 'Acceso denegado, usuario activo.';
            LET vSesionToken = 0;
            LET vGeneralInfo = 'Acceso denegado, usuario activo.';
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vStatus, vStatusDesc, vSesionToken, vGeneralInfo; 
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
    
    -- // ACTUALIZA REGISTRO DEL USUARIO
    UPDATE bdinteg:"informix".si_bm_usuarios
       SET password = pPasswordNvo,
           fech_pass = current,
           password1 = password,
           fech_pass1 = fech_pass,
           password2 = password1,
           fech_pass2 = fech_pass1,
           password3 = password2,
           fech_pass3 = fech_pass2,
           numaccesos = numaccesos + 1,
           fech_ultacces = current
     WHERE numcte = vnumcte
       AND usuario = pUsuario
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
    
    -- // GENERA REGISTRO EN BITACORA COMO PASSWORD-USUARIO
    LET vsecmax = vsecmax + 1;
    
    INSERT INTO bdinteg:"informix".si_bm_bitacora(id_session, fech_oper, numcte, secuencia, id_oper, numcel, cuenta, foliosol)
    VALUES(vSesionToken, current, vnumcte, vsecmax, '1000', pCelular, null, null);
    
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
    VALUES(vnumcte, '30', '35', pCelular, current, '5002', 'informix');
    
    LET vStatusDesc = 'Usted ha cambiado su contrasena.';
    LET vGeneralInfo = 'Usted ha cambiado su contrasena.';
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;

    RETURN vCodRet1, vStatus, vStatusDesc, vSesionToken, vGeneralInfo;
    
    END;

END PROCEDURE;