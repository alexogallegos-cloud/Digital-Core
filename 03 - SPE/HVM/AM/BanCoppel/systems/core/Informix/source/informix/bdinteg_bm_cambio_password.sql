CREATE PROCEDURE "informix".bm_cambio_password( pUsuario     CHAR(10),  --- Usuario
                                                pPasswordAnt CHAR(50),  --- Contraseña Anterior
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
    
    DEFINE vnumcte          CHAR(20);
    DEFINE vnumcel          CHAR(15);
    DEFINE vsecmax          INTEGER;
    DEFINE vexiste_usuario  SMALLINT;
    DEFINE vnumintacce      SMALLINT;
    DEFINE vid_oper         CHAR(4);
    DEFINE vtoken           INTEGER;
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
    
    LET vnumcte = '';
    LET vnumcel = '';
    LET vsecmax = 0;
    LET vexiste_usuario = 0;
    LET vnumintacce = 0;
    LET vid_oper = '';
    LET vtoken = 0;
    LET vtransaccion = 0;    
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_cambio_password.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_cambio_password.out";
    --- TRACE ON;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pUsuario is null OR pUsuario = '') OR 
       (pPasswordAnt is null OR pPasswordAnt = '') OR 
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
    
    IF LENGTH (pUsuario) <> 8 THEN
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
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE EL NUMERO DE CLIENTE
    SELECT numcte, numcel
      INTO vnumcte, vnumcel
      FROM bdinteg:"informix".si_bm_usuarios
     WHERE usuario = pUsuario;
    
    -- // VALIDA SI EL USUARIO Y PASSWORD EXISTEN
    SELECT COUNT(*)
      INTO vexiste_usuario
      FROM bdinteg:"informix".si_bm_usuarios
     WHERE usuario = pUsuario
       AND numcte = vnumcte
       AND numcel = vnumcel
       AND password = pPasswordAnt;
     
    IF vexiste_usuario = 0 THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Contrasena incorrecta, verifique.';
        LET vSesionToken = 0;
        LET vGeneralInfo = 'Contrasena incorrecta, verifique.';
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
       AND numcel = vnumcel;
       
    IF vsecmax is null THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        LET vSesionToken = 0;
        LET vGeneralInfo = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vSesionToken, vGeneralInfo; 
    END IF;
    
    SELECT id_oper, id_session
      INTO vid_oper, vSesionToken
      FROM bdinteg:"informix".si_bm_bitacora
     WHERE DATE(fech_oper) = CURRENT::DATE
       AND numcte = vnumcte
       AND numcel = vnumcel
       AND secuencia = vsecmax;
       
    IF vid_oper is null OR vid_oper = '' THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        LET vSesionToken = 0;
        LET vGeneralInfo = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vSesionToken, vGeneralInfo; 
    END IF;
    
    IF vid_oper = '1001' THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        LET vSesionToken = 0;
        LET vGeneralInfo = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vSesionToken, vGeneralInfo; 
    END IF;
    
    IF vid_oper IN('1000', '1002', '1003', '1004', '1005') THEN
        -- // ACTUALIZA PASSWORDS
        UPDATE bdinteg:"informix".si_bm_usuarios
           SET password = pPasswordNvo,
               fech_pass = current,
               password1 = password,
               fech_pass1 = fech_pass,
               password2 = password1,
               fech_pass2 = fech_pass1,
               password3 = password2,
               fech_pass3 = fech_pass2
         WHERE usuario = pUsuario
           AND numcte = vnumcte
           AND numcel = vnumcel;
           
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
        VALUES(vnumcte, '30', '35', vnumcel, current, '5002', 'informix');
    ELSE
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        LET vSesionToken = 0;
        LET vGeneralInfo = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vSesionToken, vGeneralInfo; 
    END IF;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;

    RETURN vCodRet1, vStatus, vStatusDesc, vSesionToken, vGeneralInfo;
    
    END;

END PROCEDURE;