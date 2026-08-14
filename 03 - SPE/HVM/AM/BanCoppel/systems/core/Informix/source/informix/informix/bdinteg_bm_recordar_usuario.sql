CREATE PROCEDURE "informix".bm_recordar_usuario( pPassword   CHAR(50),  --- Contraseña
                                                 pFolio      CHAR(12),  --- Folio
                                                 pCelular    DECIMAL(10,0),   --- No. Celular
                                                 pUsuarioNvo CHAR(10) ) --- Usuario Nuevo
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
    DEFINE vusuario         CHAR(50);
    DEFINE vnumcte          CHAR(20);
    DEFINE vexiste_passwd   SMALLINT;
    DEFINE vnumintacce      SMALLINT;
    DEFINE vsecmax          INTEGER;
    DEFINE vtoken           INTEGER;
    DEFINE vid_oper         CHAR(4);
    DEFINE vmaxaccesos      INTEGER;
    DEFINE vnumaccesos      INTEGER;
    DEFINE vtransaccion     INTEGER;
     
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '00000';
    LET vCodRet2     = '00000';
    LET vCodRet3     = '';
    LET vStatus      = '00';
    LET vStatusDesc  = '';
    LET vSesionToken = 0;
    LET vGeneralInfo = '';
    
    LET vexiste_usuario = 0;
    LET vusuario = '';
    LET vnumcte = '';
    LET vexiste_passwd = 0;
    LET vnumintacce = 0;
    LET vsecmax = 0;
    LET vtoken = 0;
    LET vid_oper = '';
    LET vmaxaccesos = 0;
    LET vnumaccesos = 0;
    LET vtransaccion = 0;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_recordar_usuario.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_recordar_usuario.out";
    --- TRACE ON;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pPassword is null OR pPassword = '') OR 
       (pFolio is null OR pFolio = '') OR 
       (pCelular is null OR pCelular = 0) OR
       (pUsuarioNvo is null OR pUsuarioNvo = '') THEN
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
    
    IF LENGTH(pUsuarioNvo) <> 8 THEN
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
    
    -- // VALIDA QUE EL NUEVO USUARIO NO EXISTA
    SELECT COUNT(*)
      INTO vexiste_usuario
      FROM bdinteg:"informix".si_bm_usuarios
     WHERE usuario = pUsuarioNvo;
     
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
     
    -- // OBTIENE EL NUMERO DE CLIENTE
    SELECT usuario, numcte
      INTO vusuario, vnumcte
      FROM bdinteg:"informix".si_bm_usuarios
     WHERE folio_contrato = pFolio
       AND numcel = pCelular;
    
    -- // VALIDA EL PASSWORD
    SELECT COUNT(*)
      INTO vexiste_passwd
      FROM bdinteg:"informix".si_bm_usuarios
     WHERE usuario = vusuario
       AND folio_contrato = pFolio
       AND numcte = vnumcte
       AND numcel = pCelular
       AND password = pPassword;
     
    IF vexiste_passwd = 0 THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vSesionToken = 0;
        
        SELECT numintacce
          INTO vnumintacce
          FROM bdinteg:"informix".si_bm_usuarios
         WHERE usuario = vusuario;
         
        LET vnumintacce = vnumintacce + 1;
         
        IF vnumintacce = 1 THEN
            LET vStatusDesc = 'Contrasena incorrecta, verifique.';
            LET vGeneralInfo = 'Contrasena incorrecta, verifique.';
            
            UPDATE bdinteg:"informix".si_bm_usuarios
               SET numintacce = vnumintacce
             WHERE usuario = vusuario;
        ELIF vnumintacce = 2 THEN
            LET vStatusDesc = 'Contrasena incorrecta, verifique o entre a Olvide mi contrasena.';
            LET vGeneralInfo = 'Contrasena incorrecta, verifique o entre a Olvide mi contrasena.';
            
            UPDATE bdinteg:"informix".si_bm_usuarios
               SET numintacce = vnumintacce
             WHERE usuario = vusuario;
        ELIF vnumintacce >= 3 THEN
            LET vStatusDesc = 'Bloqueo por seguridad, acuda a sucursal o ingrese al servicio avanzado de bancoppel.com.';
            LET vGeneralInfo = 'Bloqueo por seguridad, acuda a sucursal o ingrese al servicio avanzado de bancoppel.com.';
            
            UPDATE bdinteg:"informix".si_bm_usuarios
               SET numintacce = vnumintacce
             WHERE usuario = vusuario;
        END IF;
        
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;
        
        RETURN vCodRet1, vStatus, vStatusDesc, vSesionToken, vGeneralInfo; 
    END IF;
    
    -- // VALIDA SI EL USUARIO ESTA BLOQUEADO
    SELECT numintacce
      INTO vnumintacce
      FROM bdinteg:"informix".si_bm_usuarios
     WHERE numcte = vnumcte
       AND numcel = pCelular;
       
    IF vnumintacce >= 3 THEN
        LET vStatusDesc = 'Bloqueo por seguridad, acuda a sucursal o ingrese al servicio avanzado de bancoppel.com.';
        LET vGeneralInfo = 'Bloqueo por seguridad, acuda a sucursal o ingrese al servicio avanzado de bancoppel.com.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vSesionToken, vGeneralInfo; 
    ELSE
        IF vnumintacce > 0 THEN
            UPDATE bdinteg:"informix".si_bm_usuarios
               SET numintacce = 0
             WHERE numcte = vnumcte
               AND numcel = pCelular;
        END IF;
    END IF;
    
    -- // OBTIENE NUMERO DE ACCESOS PERMITIDOS AL DIA
    SELECT valor::int
      INTO vmaxaccesos
      FROM bdibpi:"informix".tkn_parametros
     WHERE id_param = '51';
     
    IF vnumaccesos > vmaxaccesos THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Accesos del dia agotados.';
        LET vSesionToken = 0;
        LET vGeneralInfo = 'Accesos del dia agotados.';
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
       AND numcte = vnumcte
       AND numcel = pCelular;
       
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
       SET usuario = pUsuarioNvo,
           numaccesos = numaccesos + 1,
           fech_ultacces = current
     WHERE folio_contrato = pFolio
       AND usuario = vusuario
       AND numcte = vnumcte
       AND numcel = pCelular
       AND password = pPassword;
       
    IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
        LET vCodRet1 = '00110';
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
    VALUES(vnumcte, '30', '95', pCelular, current, '5002', 'informix');
    
    LET vStatusDesc = 'Usted ha cambiado su usuario.';
    LET vGeneralInfo = 'Usted ha cambiado su usuario.';
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;

    RETURN vCodRet1, vStatus, vStatusDesc, vSesionToken, vGeneralInfo;
    
    END;

END PROCEDURE;