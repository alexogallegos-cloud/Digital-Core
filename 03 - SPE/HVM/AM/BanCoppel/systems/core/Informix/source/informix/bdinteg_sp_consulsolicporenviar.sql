CREATE PROCEDURE "informix".sp_consulsolicporenviar(pEmpresa CHAR(3))

	RETURNING CHAR(5),    --Código Retorno
	          CHAR(20),   --Número de Cliente 
              CHAR(20),   --Número de Solicitud
              CHAR(1050); --Trama de envió de cliente 
	
	--Declaracion de variables
	DEFINE iSqlErr          INTEGER;
	DEFINE vCodRet          CHAR(5);    --Código Retorno
	DEFINE vNumCte          CHAR(20);   --Número Cliente
	DEFINE vNumSolicitud    CHAR(20);   --Número Solicitud
	DEFINE vTrama           CHAR(1050); --Trama Alta Cliente
	DEFINE vCodRet2         CHAR(5);    --Código Retorno 2
	DEFINE iClave       	SMALLINT;   --Clave
	DEFINE cSubClave    	CHAR(5);    --SubClave
	DEFINE cIP          	CHAR(1);    --IP
	DEFINE cMac    	        CHAR(1);    --MAC
	DEFINE cOperador  	    CHAR(8);    --Operador
	
	--Inicializacion de variables
	LET vCodRet         = '00000'; --CONSULTA REGISTROS POR ENVIAR.
	LET vNumCte         = '';
	LET vNumSolicitud   = '';
	LET vTrama          = '';
	LET vCodRet2        = '00000';
	LET iClave          = 90;
	LET cSubClave       = "0015";
	LET cIP    	        = " ";
	LET cMac            = " ";
	LET cOperador       = "informix";
	
	SET ISOLATION TO DIRTY READ;
	
	--SET debug FILE TO '/tmp/sp_consulsolicporenviar.out';
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
		   IF iSqlErr != 0 THEN
				LET vCodret = iSqlErr;
				RETURN vCodret, vNumCte, vNumSolicitud, vTrama;
		   END IF;
		END EXCEPTION;
		
		IF pEmpresa = '' OR pEmpresa IS NULL THEN
			LET vCodRet = '00001'; --PARAMETRO DE ENTRADA VACIO.
			RETURN vCodret, vNumCte, vNumSolicitud, vTrama;
		ELSE
			IF EXISTS (SELECT 1 FROM bdinteg: "informix".si_clientescoppelporenviar WHERE empresa = pEmpresa AND status = 0) THEN
				FOREACH
					
					SELECT	numcte, num_solicitud 
					INTO	vNumCte, vNumSolicitud
					FROM	bdinteg: "informix".si_clientescoppelporenviar
					WHERE	empresa = pEmpresa
					AND		status = 0
					
					EXECUTE PROCEDURE "informix".sp_altactecoppelnuevoparametrico(pEmpresa, vNumCte, vNumSolicitud)
					INTO vCodRet2, vTrama;
					
					LET vCodRet = '00000';
					
					IF vCodRet2 <> '00000' THEN
						LET vCodRet = '00003'; --ERROR EN EL TRAMA DE ENVIO DEL CLIENTE.
					END IF;
					
					LET vTrama = iClave ||"|"|| TRIM(cSubClave) ||"|"|| TRIM(vTrama) ||"|"|| cIP ||"|"|| cMac ||"|"|| cOperador ||"|";
					
					RETURN vCodret, vNumCte, vNumSolicitud, vTrama WITH RESUME;
					
				END FOREACH;
			ELSE
				LET vCodRet = '00002'; --NO HAY REGISTROS PARA ENVIAR A COPPEL.
				RETURN vCodret, vNumCte, vNumSolicitud, vTrama;
			END IF;
		END IF;
	END;
END PROCEDURE
DOCUMENT
"CREO  : Rodolfo Tortolero Varela",
"FECHA : 05/Septiembre/2012",
"Ver.  : 1.1",
"BD    : bdinteg";

CREATE PROCEDURE "informix".bm_valida_password( pUsuario  CHAR(10),  --- Usuario
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
    
    DEFINE vnumcte          CHAR(20);
    DEFINE vnumcel          CHAR(15);
    DEFINE vnumaccesos      INTEGER;
    DEFINE vid_status       CHAR(2);
    DEFINE vexiste_passwd   SMALLINT;
    DEFINE vnumintacce      SMALLINT;
    DEFINE vmaxaccesos      INTEGER;
    DEFINE vsecmax          INTEGER;
    DEFINE vid_oper         CHAR(4);
    DEFINE vid              CHAR(4);
    DEFINE vdesc            CHAR(50);
    DEFINE vfech_ult_ope    datetime year to second;
    DEFINE vmaxfechoper     datetime year to second;
    DEFINE vmaxsecuencia    SMALLINT;    
    DEFINE vfech_ult_ope2   CHAR(19);
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
    LET vnumaccesos = 0;
    LET vid_status = '';
    LET vexiste_passwd = 0;
    LET vnumintacce = 0;
    LET vmaxaccesos = 0;
    LET vsecmax = 0;
    LET vid_oper = '';
    LET vid = '';
    LET vdesc = '';
    LET vfech_ult_ope = '';
    LET vmaxfechoper = '';
    LET vmaxsecuencia = 0;
    LET vfech_ult_ope2 = '';
    LET vtransaccion = 0;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_valida_password.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_valida_password.out";
    --- TRACE ON;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pUsuario is null OR pUsuario = '') OR 
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
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE DATOS DEL USUARIO
    SELECT numcte, numcel, numaccesos, id_status
      INTO vnumcte, vnumcel, vnumaccesos, vid_status
      FROM bdinteg:"informix".si_bm_usuarios
     WHERE usuario = pUsuario;
       
    -- // VALIDA EL PASSWORD DEL USUARIO
    SELECT COUNT(*)
      INTO vexiste_passwd
      FROM bdinteg:"informix".si_bm_usuarios
     WHERE numcte = vnumcte
       AND numcel = vnumcel
       AND usuario = pUsuario
       AND password = pPassword;
       
    IF vexiste_passwd = 0 THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vSesionToken = 0;
        
        SELECT numintacce
          INTO vnumintacce
          FROM bdinteg:"informix".si_bm_usuarios
         WHERE usuario = pUsuario;
         
        LET vnumintacce = vnumintacce + 1;
         
        IF vnumintacce = 1 THEN
            LET vStatusDesc = 'Contrasena incorrecta, verifique.';
            LET vGeneralInfo = 'Contrasena incorrecta, verifique.';
            
            UPDATE bdinteg:"informix".si_bm_usuarios
               SET numintacce = vnumintacce
             WHERE usuario = pUsuario;
        ELIF vnumintacce = 2 THEN
            LET vStatusDesc = 'Contrasena incorrecta, verifique o entre a Olvide mi contrasena.';
            LET vGeneralInfo = 'Contrasena incorrecta, verifique o entre a Olvide mi contrasena.';
            
            UPDATE bdinteg:"informix".si_bm_usuarios
               SET numintacce = vnumintacce
             WHERE usuario = pUsuario;
        ELIF vnumintacce >= 3 THEN
            LET vStatusDesc = 'Bloqueo por seguridad, acuda a sucursal o ingrese al servicio avanzado de bancoppel.com.';
            LET vGeneralInfo = 'Bloqueo por seguridad, acuda a sucursal o ingrese al servicio avanzado de bancoppel.com.';
            
            UPDATE bdinteg:"informix".si_bm_usuarios
               SET numintacce = vnumintacce
             WHERE usuario = pUsuario;
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
       AND numcel = vnumcel
       AND usuario = pUsuario;
       
    IF vnumintacce >= 3 THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Bloqueo por seguridad, acuda a sucursal o ingrese al servicio avanzado de bancoppel.com.';
        LET vSesionToken = 0;
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
               AND numcel = vnumcel
               AND usuario = pUsuario;
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
       
    IF (vid_oper is null OR vid_oper = '') OR (vid_oper <> '2201') THEN
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
    
    -- // BUSCA ULTIMA TRANSACCION
    SELECT MAX(fech_oper)
      INTO vmaxfechoper
      FROM bdinteg:"informix".si_bm_bitacora
     WHERE numcte = vnumcte
       AND numcel = vnumcel
       AND id_oper NOT IN('2201','1001');
       
    SELECT MAX(secuencia)
      INTO vmaxsecuencia
      FROM bdinteg:"informix".si_bm_bitacora
     WHERE numcte = vnumcte
       AND numcel = vnumcel
       AND id_oper NOT IN('2201','1001')
       AND fech_oper = vmaxfechoper;
    
    SELECT fech_oper
      INTO vfech_ult_ope
      FROM bdinteg:"informix".si_bm_bitacora
     WHERE numcte = vnumcte
       AND numcel = vnumcel
       AND fech_oper = vmaxfechoper
       AND secuencia = vmaxsecuencia;
       
    --- LET vGeneralInfo = vfech_ult_ope;
    LET vfech_ult_ope2 = vfech_ult_ope;
    LET vGeneralInfo = SUBSTR(vfech_ult_ope2,9,2)||'/'||SUBSTR(vfech_ult_ope2,6,2)||'/'||SUBSTR(vfech_ult_ope2,1,4)||' '||SUBSTR(vfech_ult_ope2,12,8);
    
    LET vsecmax = vsecmax + 1;
    
    -- // GENERA REGISTRO EN BITACORA COMO PASSWORD-USUARIO
    INSERT INTO bdinteg:"informix".si_bm_bitacora(id_session, fech_oper, numcte, secuencia, id_oper, numcel, cuenta, foliosol)
    VALUES(vSesionToken, current, vnumcte, vsecmax, '1000', vnumcel, null, null);
    
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
    
    -- // ACTUALIZA USUARIO 
    UPDATE bdinteg:"informix".si_bm_usuarios
       SET numaccesos = numaccesos + 1,
           fech_ultacces = current
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
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
    
    RETURN vCodRet1, vStatus, vStatusDesc, vSesionToken, vGeneralInfo;
    
    END;
    
END PROCEDURE;