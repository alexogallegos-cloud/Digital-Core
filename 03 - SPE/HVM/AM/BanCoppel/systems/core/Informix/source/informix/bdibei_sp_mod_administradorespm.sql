CREATE PROCEDURE "informix".sp_mod_administradorespm(pNumCteEmp CHAR(9), pAdminTipo CHAR(3), pIdAdmin CHAR(30), pApellidoPater CHAR(30), pApellidoMater CHAR(30), pNombre1 CHAR(30), pNombre2 CHAR(30), pRepLegal CHAR(1))

RETURNING CHAR(6) AS cCodRet,
		  CHAR(100) AS mensaje,
		  CHAR(20) AS num_cte,		
		  CHAR(12) AS nvo_folio_token;


--DEFINICIONES
DEFINE iSql_Err                     INTEGER;
DEFINE cCodRet         			    CHAR(6);
DEFINE cMensaje                     CHAR(50);
DEFINE cFolioSolToken    			CHAR(12);
DEFINE cMancomunado					SMALLINT;
DEFINE cApellidoPater				CHAR(30);
DEFINE cApellidoMater				CHAR(30);
DEFINE cNombre1						CHAR(30);
DEFINE cNombre2						CHAR(30);
DEFINE sStatus						SMALLINT;
DEFINE cFolioSolTokenAnt   			CHAR(12);
DEFINE cCodigoIdent		   			CHAR(3);
DEFINE cId_usuario					INTEGER;
            
--INICIALIZACIONES			  
	LET iSql_Err          = 0;
	LET cCodRet           	= '000000';
	LET cMensaje          	= 'SE EJECUTO CORRECTAMENTE';
	LET cFolioSolToken      ='';
	LET cMancomunado		= 0;
	LET cApellidoPater		= '';
	LET cApellidoMater		= '';
	LET cNombre1		= '';
	LET cNombre2		= '';
	LET sStatus			= 0;
	Let cFolioSolTokenAnt = '';
	LET cCodigoIdent		= '';
	LET cId_usuario		= 0;
BEGIN

    ON EXCEPTION SET iSql_Err
        LET cCodRet = iSql_Err;
        LET cMensaje = '';
        RETURN 	 cCodRet,cMensaje,pNumCteEmp,cFolioSolToken;
    END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/mfinis/sp_mod_administradorespm.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	
	IF TRIM(NVL(pNumCteEmp,'')) = '' THEN
		LET cCodRet = '00001';
		LET cMensaje = 'FALTAN PARAMETROS PARA SU EJECUCION';
		RETURN 	 cCodRet,cMensaje,pNumCteEmp,cFolioSolToken;
	END IF;
	
	--EJECUTA SPL QUE GENERA EL FOLIO DE LA SOLICITUD	
    EXECUTE PROCEDURE bdinteg:"informix".sp_generafoliosolicitudtoken()  INTO cCodRet,cFolioSolToken;

	IF cCodRet <> '000000' THEN
		LET cMensaje = 'ERROR EN LA GENERACION DEL FOLIO DE ACTIVACION';
		LET pNumCteEmp = '';
		RETURN 	 cCodRet,cMensaje,pNumCteEmp,cFolioSolToken;
	END IF;
	
	SELECT apell_paterno, apell_materno, nombre1, nombre2, id_status, folio_activa, codidentif, id_usuario
	INTO cApellidoPater, cApellidoMater, cNombre1, cNombre2, sStatus, cFolioSolTokenAnt, cCodigoIdent, cId_usuario
	FROM bdibei:"informix".bei_servicio
	WHERE num_cliente = TRIM(pNumCteEmp) AND es_replegal = pRepLegal;
	
	-- ACTUALIZACION DE LOS ADIMISTRADORES
	IF TRIM(cNombre1) <> pNombre1 OR TRIM(cNombre2) <> pNombre2 OR TRIM(cApellidoPater) <> pApellidoPater OR TRIM(cApellidoMater) <> pApellidoMater THEN
		UPDATE bdibei:"informix".bei_servicio SET folio_contrato = '', folio_activa = cFolioSolTokenAnt, id_status = (CASE sStatus WHEN 99 THEN 10 ELSE id_status END), 
		codidentif = TRIM(pAdminTipo), 
		identificacion_admin = TRIM(pIdAdmin), f_status = TODAY, f_registro = TODAY, f_unico_reg = CURRENT, status_manco = cMancomunado, f_reg_manco = TODAY, 
		apell_paterno = pApellidoPater, apell_materno = pApellidoMater, nombre1 = pNombre1, nombre2 = pNombre2
		WHERE num_cliente = TRIM(pNumCteEmp) AND es_replegal = pRepLegal;
		
		
		UPDATE bdibei:"informix".bei_datos_usuario 
		SET nombre = TRIM(pNombre1) || ' ' ||  TRIM(pNombre2) || ' ' || TRIM(pApellidoPater) || ' ' || TRIM(pApellidoMater)
		WHERE id_usuario = cId_usuario;
		
		
	ELIF TRIM(cCodigoIdent) <> pAdminTipo THEN 
		UPDATE bdibei:"informix".bei_servicio SET folio_contrato = '', folio_activa = cFolioSolToken, id_status = (CASE sStatus WHEN 99 THEN 10 ELSE id_status END), 
		codidentif = TRIM(pAdminTipo), 
		identificacion_admin = TRIM(pIdAdmin), f_status = TODAY, f_registro = TODAY, f_unico_reg = CURRENT, status_manco = cMancomunado, f_reg_manco = TODAY, 
		apell_paterno = pApellidoPater, apell_materno = pApellidoMater, nombre1 = pNombre1, nombre2 = pNombre2
		WHERE num_cliente = TRIM(pNumCteEmp) AND es_replegal = pRepLegal;
	ELSE
		IF sStatus = 99 THEN
			UPDATE bdibei:"informix".bei_servicio SET id_status = '10', folio_activa = cFolioSolToken 
			WHERE num_cliente = TRIM(pNumCteEmp) AND es_replegal = pRepLegal;
		ELSE
			LET cFolioSolToken = cFolioSolTokenAnt;
		END IF;
	END IF;
	--
	IF pRepLegal = 1 THEN
		UPDATE bdibei:"informix".bei_servicio SET id_status = '60'
		WHERE num_cliente = TRIM(pNumCteEmp) AND es_replegal = '0';
	END IF;
	
 	--VALIDA SI EXISTE YA ALGUN ADMINISTRADOR PARA CAMBIAR MANCOMUNIDAD
	IF (SELECT COUNT(*) FROM bdibei:bei_servicio WHERE num_cliente = pNumCteEmp ) > 1 THEN
		UPDATE bdibei:"informix".bei_servicio
		  SET status_manco = 1, f_mod_manco = TODAY
		WHERE num_cliente = TRIM(pNumCteEmp);  
	END IF;	
	--SE RETORNA INFORMACION.
	RETURN 	 cCodRet,cMensaje,pNumCteEmp,cFolioSolToken;
  END;
       
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se desarrolla SP para realizar la actualizaciÃ³n de informaciÃ³n sobre los administradores',
'AUTOR:  Veronica Sanchez Tlacomulco',   
'FECHA DE CREACION: 08/07/2022',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_soe_cancelartoken(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pNumSerieToken CHAR(10), pIdStatusTokenActual SMALLINT, pIdNuevoStatusToken SMALLINT, pCanal CHAR(2))
		RETURNING CHAR(5) AS codret;

--****************************************************************************************************
--Modificacion: Se agrega el update a tablas del token tkn_nseries e inserts a tablas de cambio de estatus de token tkn_status_token
--Modifico: Marco Tinajero - BanCoppel - Internet.
--FechaMod: 23 Octubre 2023
--****************************************************************************************************

	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMesnajeRetorno CHAR(50);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdUsuario INTEGER;
	DEFINE cSucRegistro CHAR(4);
	DEFINE cFolioToken CHAR(25);
	DEFINE dFechaStatus DATETIME YEAR TO FRACTION(3);
	DEFINE dFechaRegistro DATE;
	DEFINE iExisteRegistro SMALLINT;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMesnajeRetorno = '';
	LET iSqlErr = 0;
	LET iIdUsuario = 0;
	LET cSucRegistro = '';
	LET cFolioToken = '';
	LET dFechaStatus = NULL;
	LET dFechaRegistro = NULL;
	LET iExisteRegistro = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_cancelartoken.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pNumSerieToken = '' OR pIdStatusTokenActual IS NULL 
			OR pIdNuevoStatusToken IS NULL OR pCanal = '' THEN
			
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SELECT a.id_usuario, a.suc_registro, a.folio_token, a.f_status, a.f_registro
		INTO iIdUsuario, cSucRegistro, cFolioToken, dFechaStatus, dFechaRegistro
		FROM bdibei:"informix".bei_token a, bdibei:"informix".bei_tokensolicitud b
		WHERE a.num_cliente = pNumCliente
			AND a.ns_token = pNumSerieToken
			AND b.numcte = a.num_cliente
			AND b.ns_token = a.ns_token;
			
		LET iExisteRegistro = DBINFO('sqlca.sqlerrd2');
		IF iExisteRegistro = 1 THEN -- NO SE ENCONTRARON REGISTROS
		
			--Se cancela token de la tabla bei_tokensolicitud 
			UPDATE bdibei:"informix".bei_tokensolicitud
			SET id_status = pIdNuevoStatusToken
			WHERE numcte = pNumCliente
				AND ns_token = pNumSerieToken;
			
			SET LOCK MODE TO WAIT 3;
			
			--INSERT INTO bdibei:'informix'.bei_tokenhis (num_cliente, ns_token, suc_registro, folio_token, id_status_token, f_status, f_registro)
			--VALUES (pNumCliente, pNumSerieToken, cSucRegistro, cFolioToken, pIdNuevoStatusToken, dFechaStatus, dFechaRegistro);
			INSERT INTO bdibei:"informix".bei_tokenhis (num_cliente, ns_token, suc_registro, folio_token, id_status_token, f_status, f_registro, id_usuario)
			VALUES (pNumCliente, pNumSerieToken, cSucRegistro, cFolioToken, pIdNuevoStatusToken, CURRENT, dFechaRegistro, iIdUsuario);

			-- Tabla de tokens de bpi
			UPDATE bdibpi:"informix".tkn_nseries SET id_status = pIdNuevoStatusToken, f_status = CURRENT WHERE ns_token = pNumSerieToken; 

			-- Tabla historica de cambio de estatus del token
			INSERT INTO bdibpi:"informix".tkn_status_token (ns_token, anterior, actual, f_cambio_status, usr_cambio_status, canal) 
			VALUES(pNumSerieToken, pIdStatusTokenActual, pIdNuevoStatusToken, CURRENT, pUsuario, pCanal);

		ELSE
			LET cCodRet = '00394'; -- OCURRIO UN ERROR AL TRATAR DE CANCELAR EL TOKEN
			RETURN cCodRet;
		END IF;
		
		-- SE ELIMINAN LOS REGISTROS DE TABLA
		DELETE FROM bdibei:"informix".bei_token
		WHERE num_cliente = pNumCliente AND ns_token = pNumSerieToken;
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 29/10/2014',
'DESCRIPCION: Procedimiento que cancela un token',
'FECHA: 09/01/2015',
'DESCRIPCION: se anexa actualizacion para el token en la tabla bei_tokensolicitud',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_actualiza_datoscontacto_empnet(
                                           pIdCliente  CHAR(9),
                                           pIdUsuario INTEGER,
                                           pRepresentanteLegal CHAR(100),
                                           pTelFijo CHAR(15),
										   pTelCel CHAR(15),
										   pEmail CHAR(35),
                                           pEmailAlternativo CHAR(35),
                                           pPagInternet CHAR(35)
)
RETURNING CHAR (5);

	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
  	
    LET vCod_ret = '00000';
        

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vCod_ret = sql_err;
				RETURN vCod_ret;
			END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;
        

		IF NVL(pIdCliente,'') =='' OR NVL(pIdUsuario,'') =='' OR NVL(pRepresentanteLegal,'') ==''  OR NVL(pTelFijo,'') =='' OR NVL(pTelCel,'') =='' OR NVL(pEmail,'') =='' THEN
            LET vCod_ret = '00001'; -- Datos incompletos
            RETURN vCod_ret;
        END IF;
        
        IF EXISTS (SELECT 1 FROM bdibei:"informix".bei_datos_empnet  WHERE id_cliente = pIdCliente AND  id_usuario = pIdUsuario) THEN
            UPDATE bdibei:"informix".bei_datos_empnet SET representante_legal = pRepresentanteLegal, 
            tel_fijo = pTelFijo,tel_celular= pTelCel, correo = pEmail, correo_alternativo = pEmailAlternativo,
             pagina_internet = pPagInternet, fecha_actualizacion = CURRENT YEAR TO SECOND
            WHERE id_cliente= pIdCliente AND  id_usuario = pIdUsuario;
          
           
            
        ELSE          
            INSERT INTO bdibei:"informix".bei_datos_empnet(id_cliente,id_usuario,representante_legal,tel_fijo,tel_celular,correo,correo_alternativo,pagina_internet,fecha_registro)
            VALUES (pIdCliente,pIdUsuario,pRepresentanteLegal, pTelFijo,pTelCel,pEmail,pEmailAlternativo,pPagInternet,CURRENT YEAR TO SECOND);
           
        END IF;

		RETURN vCod_ret;
	END;
END PROCEDURE;