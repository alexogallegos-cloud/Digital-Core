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