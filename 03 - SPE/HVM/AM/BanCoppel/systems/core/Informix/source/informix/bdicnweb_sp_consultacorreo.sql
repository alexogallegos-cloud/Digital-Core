CREATE PROCEDURE "informix".sp_consultacorreo(pUsuario CHAR(8), pIdFuncion CHAR(10), cNumApoderado CHAR(20))
    RETURNING CHAR(5) AS codRet,
		CHAR(100) AS correo_e;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCorreoE CHAR(100);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cCorreoE = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cCorreoE;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultacorreo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR cNumApoderado = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCorreoE;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCorreoE;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT correo_elec
		INTO cCorreoE
		FROM bdinteg:"informix".si_correos
		WHERE numcte = TRIM(cNumApoderado) 
		AND status_correo = 'A' 
		AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos WHERE numcte = TRIM(cNumApoderado));
		
		RETURN cCodRet, NVL(TRIM(cCorreoE),'');
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 01/03/2017',
'MODULO: ',
'FUNCIONALIDAD: MANTENIMIENTO CORREO ELECTRÓNICO',
'DESCRIPCION: SPL encargado de consultar el correo electrónico.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_guardadatoslegalesctemoral(pUsuario CHAR(8), 
														  pIdFuncion 	 CHAR(10),
														  pNumCte        CHAR(20),
														  pEscConstitu   CHAR(30),
														  pNombNotario   CHAR(30),
														  pNumNotaria    CHAR(5),
														  pCdNotaria     CHAR(30),
														  pFecInscrip    DATE,
														  pFecConstitu   DATE,
														  pNumFolMerca   CHAR(30),
														  pCdFolMerca    CHAR(30),
														  pEscriPoder    CHAR(30),
														  pNombNotpd     CHAR(30),
														  pNumNotariopd  CHAR(30),
														  pCdNotariopd   CHAR(30),
														  pFecInscripd   DATE,
														  pFecEscritupd  DATE,
														  pFolMercapd    CHAR(30),
														  pCdFolMercaPd  CHAR(30),
														  pNomSociedad   CHAR(30),
														  pEmail         CHAR(100),
														  pSat_fea       CHAR(25),
														  pDoc_legal     CHAR(100),
														  pTpo_Poder     CHAR(3),
														  pTpo_Admin     CHAR(3),
														  pTpo_Org       CHAR(3))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE bInTrasaction BOOLEAN;
	DEFINE pTipoCorreo CHAR(1);
    DEFINE pCanal CHAR(1);
	DEFINE cExisteEmail INTEGER;
	DEFINE cNumCteApoder CHAR(20);
	DEFINE cNomApoder CHAR(60);
	DEFINE iExisteCorreo INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET bInTrasaction = 'f';
	LET pTipoCorreo = 1;
	LET pCanal = 7;
	LET cExisteEmail = 0;
	LET cNumCteApoder = '';
	LET cNomApoder = '';
	LET iExisteCorreo = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			COMMIT WORK;
			LET bInTrasaction = 't';
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_guardadatoslegalesctemoral.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;

		--OBTIENE EL NUMERO DE CTE APODERADO ASI COMO SU NOMBRE
		SELECT numcteapoderado,nombreapoderado 
		INTO cNumCteApoder, cNomApoder
		FROM bdinteg:"informix".si_apoderado
		WHERE empresa = '001'
		AND numcte = TRIM(pNumCte)
		AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_apoderado WHERE empresa = '001');
		
		LET  pEmail = LOWER(pEmail);
		BEGIN;
		EXECUTE PROCEDURE bdinteg:"informix".ctemoraldatoslegales(cEmpresa, pNumCte, pEscConstitu, pNombNotario, pNumNotaria, pCdNotaria, pFecInscrip, pFecConstitu, pNumFolMerca, pCdFolMerca,
															pEscriPoder, pNombNotpd, pNumNotariopd, pCdNotariopd, pFecInscripd, pFecEscritupd, pFolMercapd, pCdFolMercaPd, pNomSociedad,
															pEmail, pSat_fea, pDoc_legal, pTpo_Poder, pTpo_Admin, pTpo_Org)
		INTO cCodRetSp;	
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ctemoraldatoslegales';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '000001';
		END IF;
		
		IF bInTrasaction = 't' THEN
			BEGIN;
		END IF;
		
		IF (pEmail = '' OR pEmail IS NULL) THEN
			SELECT NVL(COUNT(correo_elec),0)
			INTO cExisteEmail
			FROM bdinteg:"informix".si_correos
			WHERE numcte = TRIM(cNumCteApoder) 
			AND status_correo = 'A' 
			AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos WHERE numcte = TRIM(cNumCteApoder));
			
			IF (cExisteEmail > 0) THEN
				UPDATE bdinteg:"informix".si_correos
				SET status_correo = 'C'
				WHERE numcte = TRIM(cNumCteApoder) 
				AND status_correo = 'A' 
				AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos WHERE numcte = TRIM(cNumCteApoder));
		    END IF;
		ELSE
		
			SELECT COUNT(*)
			INTO iExisteCorreo
			FROM bdinteg:"informix".si_correos
			WHERE correo_elec = pEmail AND status_correo = 'A' 
			AND numcte = cNumCteApoder AND tipo_correo = pTipoCorreo;

			IF NVL(iExisteCorreo,0) > 0 THEN

				UPDATE bdinteg:"informix".si_correos
				SET status_correo = 'C'
				WHERE correo_elec = pEmail AND status_correo = 'A' 
				AND numcte = cNumCteApoder AND tipo_correo = pTipoCorreo;
				
			END IF;
		
			EXECUTE PROCEDURE bdinteg:"informix".sp_registra_correos(cEmpresa,cNumCteApoder,pEmail,pTipoCorreo,pCanal,pUsuario)    
			INTO cCodRetSp;
            
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_registra_correos';
			END IF;
			
			IF cCodRetSp = '110' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
			ELIF cCodRetSp = '104' THEN
				LET cCodRet = '00022';
				RETURN cCodRet;
			ELIF cCodRetSp = '999' THEN
				LET cCodRet = '00866';
				RETURN cCodRet;
			END IF;
            
			LET cCodRetSp = '';
		END IF;
		
		RETURN cCodRet;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 28/05/2014',
'DESCRIPCION: Se actualiza para que reciba 4 nuevos parametros: 1.-pTipoPoder CHAR(3), 2.-pTipoAdmon CHAR(3), 3.-pTipoOrg CHAR(3)',
'AUTOR: M.D.S.Sandra Cano',
'FECHA: 03/10/2016',
'DESCRIPCION: Se actualiza para invocar al spl que almacena email en la tabla si_correos',
'AUTOR: L. Montserrat León Amador',
'FECHA: 28/02/2017',
'DESCRIPCION: Se actualiza para cambiar el orden de ejecución, además de modificar que la extracción de correo electronico sea asociado al apoderado legal.',
'ID REQUERIMIENTO TASF: CLI-01-12-03-B-0452',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualizamonitorprocesos(pUsuario CHAR(8), pIdFuncion CHAR(10), pOpcion CHAR(1), pEstatusProceso CHAR(1), pCodError CHAR(5), pGenerico VARCHAR(255), pMac CHAR(18), pIp VARCHAR(16))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_actualizamonitorprocesos.out';
		--TRACE ON;
		
		IF pOpcion = '1' THEN --- Inserta proceso
		
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdicnweb:"informix".sw_monitorprocesos(id_funcion,usuario,status,codigo_error_sp,generico,mac_adress,ip)
			VALUES(pIdFuncion, pUsuario, 'P', '', '', pMac, pIp);  	

			RETURN cCodRet;
		
		ELIF pOpcion = '2' THEN --- Actualiza proceso
		
			IF pEstatusProceso = 'E' THEN 
			
				SET LOCK MODE TO WAIT 3;
				UPDATE bdicnweb:"informix".sw_monitorprocesos
				SET status = 'E', codigo_error_sp = TRIM(pCodError), generico = TRIM(pGenerico)
				WHERE id_funcion = TRIM(pIdFuncion)
				AND usuario= TRIM(pUsuario)
				AND mac_adress = TRIM(pMac)
				AND ip = TRIM(pIp);
				
				RETURN cCodRet;
				
			ELIF pEstatusProceso = 'T' THEN 
			
				SET LOCK MODE TO WAIT 3;
				UPDATE bdicnweb:"informix".sw_monitorprocesos
				SET status = 'T', codigo_error_sp = TRIM(pCodError), generico = TRIM(pGenerico)
				WHERE id_funcion = TRIM(pIdFuncion)
				AND usuario= TRIM(pUsuario)
				AND mac_adress = TRIM(pMac)
				AND ip = TRIM(pIp);
				
				RETURN cCodRet;
				
			END IF;
		
		ELIF pOpcion = '3' THEN -- Elimina proceso
		
			SET LOCK MODE TO WAIT 3;
			DELETE FROM bdicnweb:"informix".sw_monitorprocesos
			WHERE id_funcion = TRIM(pIdFuncion)
			AND usuario= TRIM(pUsuario)
			AND mac_adress = TRIM(pMac)
			AND ip = TRIM(pIp);
			
			RETURN cCodRet;
		
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 20/04/2016',
'MODULO: Domiciliacion',
'FUNCIONALIDAD: Carga de Archivos',
'DESCRIPCION: SP que realiza la insercion, modificacion y eliminacion de estatus de proceso en ejecucion',
'pOpcion = 1 Inserta proceso, pOpcion = 2 Modifica proceso, pOpcion = 3 Elimina proceso',
'pEstatusProceso = E Actualizacion de proceso con error, pEstatusProceso = T Actualizacion de proceso con exito',
'AUTOR: Julio Martinez',
'FECHA: 06/04/2017',
'DESCRIPCION: en la opcion 2 Modifica proceso se actualiza codigo de error y generico.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_bccc_catcomentario(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codRet,
		CHAR(2) AS id_comentario,
		CHAR(100) AS desc_comentario;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(40);
	DEFINE cEmpresa CHAR(3);
	DEFINE cIdComentario CHAR(2);
	DEFINE cDescComentario CHAR(100);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cIdComentario = '';
	LET cDescComentario = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cIdComentario,cDescComentario;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_bccc_catcomentario.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cIdComentario,cDescComentario;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cIdComentario,cDescComentario;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".sp_mon_buro_conscaterrores()
			INTO cCodRetSp,cDescComentario,cIdComentario
		
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdicred:sp_mon_buro_conscaterrores';
			END IF;
		
			LET iRecuperacion = iRecuperacion + 1;				
			RETURN cCodRet,TRIM(cIdComentario),TRIM(UPPER(cDescComentario)) WITH RESUME;	
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cIdComentario,cDescComentario;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 15/11/2016',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: MONITOR DE LA SITUACIÓN DE LOS ENVÍOS A BC Y CC',
'DESCRIPCION: Spl encargado de consultar el detalle del catálogo comentario.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_bccc_catproducto(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codRet,
		CHAR(4) AS id_producto,
		CHAR(40) AS desc_producto;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cIdProducto CHAR(4);
	DEFINE cDescProducto CHAR(40);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cIdProducto = '';
	LET cDescProducto = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cIdProducto,cDescProducto;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_bccc_catproducto.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cIdProducto,cDescProducto;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cIdProducto,cDescProducto;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".sp_cac_consulta_productos()
			INTO cCodRetSp,cDescCodRet,cDescProducto,cIdProducto
		
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdicred:sp_cac_consulta_productos';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,cIdProducto,cDescProducto;
			END IF;
		
			LET iRecuperacion = iRecuperacion + 1;				
			RETURN cCodRet,TRIM(cIdProducto),TRIM(UPPER(cDescProducto)) WITH RESUME;	
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cIdProducto,cDescProducto;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 15/11/2016',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: MONITOR DE LA SITUACIÓN DE LOS ENVÍOS A BC Y CC',
'DESCRIPCION: Spl encargado de consultar el detalle del catálogo producto.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_bccc_conserroresreenviosol(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(30) AS tipo_solicitud,
			CHAR(20) AS num_solicitud,
			CHAR(100) AS mensaje_error;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cTipoSolicitud CHAR(30);
	DEFINE cNumSolicitud CHAR(20);
	DEFINE cDescMensaje CHAR(100);
	DEFINE dFechaHoy DATE;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cTipoSolicitud = '';
	LET cNumSolicitud = '';
	LET cDescMensaje = '';
	LET dFechaHoy = DATE(CURRENT);
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cTipoSolicitud,cNumSolicitud,cDescMensaje;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_bccc_conserroresreenviosol.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cTipoSolicitud,cNumSolicitud,cDescMensaje;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cTipoSolicitud,cNumSolicitud,cDescMensaje;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cTipoSolicitud,cNumSolicitud,cDescMensaje;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion tipo_solicitud,num_solicitud,mensaje_error
			INTO cTipoSolicitud,cNumSolicitud,cDescMensaje
			FROM bdicnweb:"informix".sw_buro_bitacoraerror 
			WHERE user_insert = pUsuario AND fecha_insert = dFechaHoy

			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,UPPER(TRIM(cTipoSolicitud)),TRIM(cNumSolicitud),UPPER(TRIM(cDescMensaje)) WITH RESUME;
		END FOREACH;		
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cTipoSolicitud,cNumSolicitud,cDescMensaje;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cTipoSolicitud,cNumSolicitud,cDescMensaje;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 28/11/2016',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: MONITOR DE LA SITUACIÓN DE LOS ENVÍOS A BC Y CC',
'DESCRIPCION: SPL encargado de consultar el detalle de los errores encontrados al realizar el reenvio de solicitudes.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_bccc_consinforeenvio(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSolicitud CHAR(2), pNumSolicitud CHAR(20))
    RETURNING CHAR(5) AS codRet,
		CHAR(20)  AS num_cliente,
		CHAR(13)  AS rfc,
		CHAR(104) AS nom_cliente,
		CHAR(4)	  AS sucursal,
		CHAR(20)  AS num_credito,
		CHAR(45)  AS num_producto,
		CHAR(40)  AS estatus_solicitud,
		CHAR(30)  AS calle,
		CHAR(30)  AS zona,
		CHAR(30)  AS ciudad,
		CHAR(27)  AS municipio,
		CHAR(30)  AS estado,
		CHAR(10)  AS num_ext,
		CHAR(5)   AS cp,
		CHAR(30)  AS edificio,
		CHAR(6)   AS departamento,
		CHAR(80)  AS complemento,
		CHAR(10)  AS num_int;
		
	DEFINE cCodRet 			 CHAR(5);
	DEFINE iSqlErr 			 INT;
	DEFINE cCodRetSp 		 CHAR(5);
	DEFINE iCodRetSp 		 INTEGER;
	DEFINE cEmpresa 		 CHAR(3);
	DEFINE cNomCliente 		 CHAR(104);
	DEFINE cRfc 			 CHAR(13);
	DEFINE cNumCliente 		 CHAR(20);
	DEFINE cSucursal 		 CHAR(4);
	DEFINE cNumCredito 		 CHAR(20);
	DEFINE cNumProducto 	 CHAR(45);
	DEFINE cEstatusSolicitud CHAR(40);
	
	DEFINE iSecuencia        INT;
	DEFINE cTipoDir          CHAR(1);
	DEFINE cCalle            CHAR(40);
	DEFINE cColonia          CHAR(60);
	DEFINE cEntreCalles      CHAR(40);
	DEFINE cPais             CHAR(3);
	DEFINE cEstado           CHAR(2);
	DEFINE cCiudad           CHAR(3);
	DEFINE cMunicipio        CHAR(5);
	DEFINE cCodPostal        CHAR(5);
	DEFINE cApartPostal      CHAR(11);
	DEFINE cTipoTelef1       CHAR(1);
	DEFINE cTelefono1        CHAR(13);
	DEFINE cTipoTelef2       CHAR(1);
	DEFINE cTelefono2        CHAR(13);
	DEFINE cTipoTelef3       CHAR(1);
	DEFINE cTelefono3        CHAR(13);
	DEFINE cExtension        CHAR(5);
	DEFINE cEstadoInegi      CHAR(2);
	DEFINE cMunicipioInegi   CHAR(3);
	DEFINE cLocalidadInegi   CHAR(4);
	DEFINE sNumeroCiudad     SMALLINT;
	DEFINE cNumeroExtCalle   CHAR(10);
	DEFINE cNumeroIntCalle   CHAR(10);
	DEFINE cDepartamento     CHAR(6);
	DEFINE iNumeroCalle      INT;
	DEFINE iNumeroColonia    INT;
	DEFINE cPuntoCardinal    CHAR(1);
	DEFINE cUnidadHabitac    CHAR(1);
	DEFINE sManzana          SMALLINT;
	DEFINE sOtros            SMALLINT;
	DEFINE sAndador          SMALLINT;
	DEFINE sEtapa            SMALLINT;
	DEFINE sLote             SMALLINT;
	DEFINE sEdificio         SMALLINT;
	DEFINE sEntrada          SMALLINT;
	DEFINE cObservaciones    CHAR(80);
	DEFINE cNomEdo           CHAR(30);
	DEFINE cNomCiudad        CHAR(30);
	DEFINE cNomColonia       CHAR(30);
	DEFINE cNomCalle         CHAR(30);
	DEFINE cNomMunicipio     CHAR(27);
	DEFINE cNomLote          CHAR(30);
	DEFINE cNomEntrada       CHAR(30);
	DEFINE cNomEdificio      CHAR(30);
	DEFINE cNomEtapa         CHAR(30);
	DEFINE cNomAndador       CHAR(30);
	DEFINE cNomOtros         CHAR(30);
	DEFINE cNomManzana       CHAR(30);
	DEFINE iNumRegistros 	 INTEGER;
	
	LET cCodRet              = '00000';
	LET iSqlErr 			 = 0;
	LET cCodRetSp 			 = '';
	LET iCodRetSp 			 = 0;
	LET cEmpresa 			 = '001';
	LET cNomCliente 		 = '';
	LET cRfc 				 = '';
	LET cNumCliente 		 = '';
	LET cSucursal 			 = '';
	LET cNumCredito 		 = '';
	LET cNumProducto 		 = '';
	LET cEstatusSolicitud 	 = '';
	
	LET iSecuencia           = 0;
	LET cTipoDir             = '';
	LET cCalle               = '';
	LET cColonia             = '';
	LET cEntreCalles         = '';
	LET cPais                = '';
	LET cEstado              = '';
	LET cCiudad              = '';
	LET cMunicipio           = '';
	LET cCodPostal           = '';
	LET cApartPostal         = '';
	LET cTipoTelef1          = '';
	LET cTelefono1           = '';
	LET cTipoTelef2          = '';
	LET cTelefono2           = '';
	LET cTipoTelef3          = '';
	LET cTelefono3           = '';
	LET cExtension           = '';
	LET cEstadoInegi         = '';
	LET cMunicipioInegi      = '';
	LET cLocalidadInegi      = '';
	LET sNumeroCiudad        = 0;
	LET cNumeroExtCalle      = '';
	LET cNumeroIntCalle      = '';
	LET cDepartamento        = '';
	LET iNumeroCalle         = 0;
	LET iNumeroColonia       = 0;
	LET cPuntoCardinal       = '';
	LET cUnidadHabitac       = '';
	LET sManzana             = 0;
	LET sOtros               = 0;
	LET sAndador             = 0;
	LET sEtapa               = 0;
	LET sLote                = 0;
	LET sEdificio            = 0;
	LET sEntrada             = 0;
	LET cObservaciones       = '';
	LET cNomEdo              = '';
	LET cNomCiudad           = '';
	LET cNomColonia          = '';
	LET cNomCalle            = '';
	LET cNomMunicipio        = '';
	LET cNomLote             = '';
	LET cNomEntrada          = '';
	LET cNomEdificio         = '';
	LET cNomEtapa            = '';
	LET cNomAndador          = '';
	LET cNomOtros            = '';
	LET cNomManzana          = '';
	LET iNumRegistros 		 = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cNumCliente, cRfc, cNomCliente, cSucursal, cNumCredito, cNumProducto, cEstatusSolicitud,
				cNomCalle, cNomColonia, cNomCiudad, cNomMunicipio, cNomEdo, cNumeroExtCalle, cCodPostal, cNomEdificio,
				cDepartamento, cObservaciones, cNumeroIntCalle;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_bccc_consinforeenvio.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoSolicitud = '' OR pNumSolicitud = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCliente, cRfc, cNomCliente, cSucursal, cNumCredito, cNumProducto, cEstatusSolicitud,
			cNomCalle, cNomColonia, cNomCiudad, cNomMunicipio, cNomEdo, cNumeroExtCalle, cCodPostal, cNomEdificio,
			cDepartamento, cObservaciones, cNumeroIntCalle;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumCliente, cRfc, cNomCliente, cSucursal, cNumCredito, cNumProducto, cEstatusSolicitud,
			cNomCalle, cNomColonia, cNomCiudad, cNomMunicipio, cNomEdo, cNumeroExtCalle, cCodPostal, cNomEdificio,
			cDepartamento, cObservaciones, cNumeroIntCalle;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
			EXECUTE PROCEDURE bdicred:"informix".sp_mon_buro_coninfoctestatus(pTipoSolicitud, pNumSolicitud)
			INTO cCodRetSp, cNomCliente, cRfc, cNumCliente, cSucursal, cNumCredito, cNumProducto, cEstatusSolicitud
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdicred:sp_mon_buro_coninfoctestatus';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cNumCliente, cRfc, cNomCliente, cSucursal, cNumCredito, cNumProducto, cEstatusSolicitud,
				cNomCalle, cNomColonia, cNomCiudad, cNomMunicipio, cNomEdo, cNumeroExtCalle, cCodPostal, cNomEdificio,
				cDepartamento, cObservaciones, cNumeroIntCalle;
			ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00913'; --EL CLIENTE NO POSEE DATOS PERSONALES
				RETURN cCodRet, cNumCliente, cRfc, cNomCliente, cSucursal, cNumCredito, cNumProducto, cEstatusSolicitud,
				cNomCalle, cNomColonia, cNomCiudad, cNomMunicipio, cNomEdo, cNumeroExtCalle, cCodPostal, cNomEdificio,
				cDepartamento, cObservaciones, cNumeroIntCalle;
			END IF;
			
			IF cCodRetSp::INTEGER = 0 THEN
			
				EXECUTE PROCEDURE bdinteg:"informix".sp_consdirec(cEmpresa,cNumCliente,1)
				INTO cCodRetSp, iSecuencia, cTipoDir, cCalle, cColonia, cEntreCalles, cPais, cEstado,
                cCiudad, cMunicipio, cCodPostal, cApartPostal, cTipoTelef1, cTelefono1, cTipoTelef2, cTelefono2,
                cTipoTelef3, cTelefono3, cExtension, cEstadoInegi, cMunicipioInegi, cLocalidadInegi, sNumeroCiudad, cNumeroExtCalle,
                cNumeroIntCalle, cDepartamento, iNumeroCalle, iNumeroColonia, cPuntoCardinal, cUnidadHabitac, sManzana, sOtros,
                sAndador, sEtapa, sLote, sEdificio, sEntrada, cObservaciones, cNomEdo, cNomCiudad,
                cNomColonia, cNomCalle, cNomMunicipio, cNomLote, cNomEntrada, cNomEdificio, cNomEtapa, cNomAndador, cNomOtros, cNomManzana;
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdinteg:sp_consdirec';
				END IF;
				
			END IF;
		
			LET iNumRegistros = iNumRegistros + 1;
			RETURN cCodRet, cNumCliente, UPPER(cRfc), UPPER(TRIM(cNomCliente)), cSucursal, cNumCredito, UPPER(TRIM(cNumProducto)), UPPER(TRIM(cEstatusSolicitud)),
			NVL(cNomCalle,''), NVL(cNomColonia,''), NVL(cNomCiudad,''), NVL(cNomMunicipio,''),
			NVL(cNomEdo,''), NVL(cNumeroExtCalle,''), NVL(cCodPostal,''), NVL(cNomEdificio,''),
			NVL(cDepartamento,''), NVL(cObservaciones,''), NVL(cNumeroIntCalle,'') WITH RESUME;
			
		END FOREACH;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00913'; --EL CLIENTE NO POSEE DATOS PERSONALES
			RETURN cCodRet, cNumCliente, cRfc, cNomCliente, cSucursal, cNumCredito, cNumProducto, cEstatusSolicitud,
			cNomCalle, cNomColonia, cNomCiudad, cNomMunicipio, cNomEdo, cNumeroExtCalle, cCodPostal, cNomEdificio,
			cDepartamento, cObservaciones, cNumeroIntCalle;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 28/11/2016',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: MONITOR DE LA SITUACIÓN DE LOS ENVÍOS A BC Y CC',
'DESCRIPCION: SPL encargado de consultar el detalle de la solicitud que se desea reenviar.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_bccc_consultasolicitud(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pNumSolicitud CHAR(20))
    RETURNING CHAR(5) AS codRet,
		CHAR(45) AS nombre_operador;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cOperador CHAR(8);
	DEFINE cNombreEjecutivo CHAR(45);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cOperador = '';
	LET cNombreEjecutivo = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cNombreEjecutivo;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_bccc_consultasolicitud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pNumSolicitud = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreEjecutivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreEjecutivo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT user_insert INTO cOperador
		FROM bdicnweb:"informix".sw_buro_cteprocesando 
		WHERE num_cliente = pNumCliente AND num_solicitud = pNumSolicitud AND user_insert <> pUsuario;
		
		IF NVL(cOperador,'') <> '' THEN
			SELECT nombre INTO cNombreEjecutivo
			FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = cOperador;
			
			LET cCodRet = '90000';
		END IF;
		
		RETURN cCodRet, UPPER(cNombreEjecutivo);
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 01/12/2016',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: MONITOR DE LA SITUACIÓN DE LOS ENVÍOS A BC Y CC',
'DESCRIPCION: Spl encargado de consultar si la solicitud ya está siendo atendida por otro operador.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_bccc_procesasolicitud(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdOperacion SMALLINT, pNumCliente CHAR(20), pNumSolicitud CHAR(20))
    RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_bccc_procesasolicitud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdOperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pIdOperacion NOT IN (1, 2, 3) THEN
			LET cCodRet = '00450'; --'VALOR DE PARAMETRO INVALIDO
			RETURN cCodRet;
		ELSE
			IF pIdOperacion = 1 THEN	
			
				INSERT INTO "informix".sw_buro_cteprocesando(num_cliente,num_solicitud,user_insert,fecha_insert,hora_insert)
				VALUES(pNumCliente, pNumSolicitud, pUsuario, CURRENT, CURRENT HOUR TO SECOND);
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00282';
					RETURN cCodRet;
				END IF;
				
			ELIF pIdOperacion = 2 THEN
			
				DELETE FROM "informix".sw_buro_cteprocesando 
				WHERE num_cliente = pNumCliente AND num_solicitud = pNumSolicitud AND user_insert = pUsuario;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00862';
					RETURN cCodRet;
				END IF;
			
			ELIF pIdOperacion = 3 THEN
			
				IF EXISTS(SELECT 1 FROM bdicnweb:"informix".sw_buro_cteprocesando WHERE user_insert = pUsuario) THEN
				
					DELETE FROM "informix".sw_buro_cteprocesando 
					WHERE user_insert = pUsuario;
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = '00862';
						RETURN cCodRet;
					END IF;
				
				END IF;
			
			END IF;
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 01/12/2016',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: MONITOR DE LA SITUACIÓN DE LOS ENVÍOS A BC Y CC',
'DESCRIPCION: Spl encargado de bloquear o desbloquear una solicitud en proceso.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_bccc_reenviosrep(pUsuario CHAR(8), pIdFuncion CHAR(10), pModo SMALLINT, pTipoSolicitud CHAR(1), 
pNumSolicitud CHAR(20), pNumCte CHAR(20),pEstatus CHAR(2), pFechaIni DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5)		AS codigo_ret,
			CHAR(20)      AS tiposol_numanalista, --tiposol / numanalista
			CHAR(104)     AS producto_nomanalista, --producto /  nomanalista
			CHAR(25)      AS numsol_perfilus, --numsolic / perfilusuario
			CHAR(20)      AS numcte_errcve01, --numcte / errorcve01
			CHAR(4)       AS numsuc_errcve02, --numsuc / errorcve02 
			CHAR(104)     AS nomcte_errcve03, --nomcte / errorcve03
			CHAR(10)      AS fecha_errcve04, --fechasol / errorcve04
			CHAR(12)      AS hr_errcve05, --hora / errorcve05
			CHAR(4)       AS estatus_errcve06, --estatus / errorcve06
			CHAR(4)       AS reenvio_errcve07, --reenvio_exit SI o NO / errorcve07
			CHAR(10)      AS fechareenvio_errcve08, --fecha_reenvio / errorcve08
			CHAR(4)		  AS estatusfin_errcve09, --estatus fin / errorcve09
			CHAR(80)      AS motreenvio_totalbc, --motivo_reenvio/ totalbc
			CHAR(104)     AS nomanalista_totalcc, --nombre_analista / totalcc
			CHAR(10)      AS totalglobal; -- totalglobal
		
	DEFINE iFolio     INTEGER;
	DEFINE iSqlErr    INTEGER;
	DEFINE cCodRet    CHAR(5);
	DEFINE iNoRegistros INTEGER;
	DEFINE cTipoSolNumAnalista CHAR(20); --tiposol / numanalista
	DEFINE cProductoNomAnalista CHAR(104); --producto /  nomanalista
	DEFINE cNumSolPerfilUs CHAR(25); --numsolic / perfilusuario
	DEFINE cNumCteErrCve01 CHAR(20); --numcte / errorcve01
	DEFINE cNumSucErrCve02 CHAR(4); --numsuc / errorcve02 
	DEFINE cNomCteErrCve03 CHAR(104); --nomcte / errorcve03
	DEFINE cFechaErrCve04 CHAR(10); --fechasol / errorcve04
	DEFINE cHrErrCve05 CHAR(12); --hora / errorcve05
	DEFINE cEstatusErrCve06 CHAR(4); --estatus / errorcve06
	DEFINE cReenvioErrCve07 CHAR(4); --reenvio_exit SI o NO / errorcve07
	DEFINE cFechaReenvioErrCve08 CHAR(10); --fecha_reenvio / errorcve08
	DEFINE cEstatusFinErrCve09 CHAR(4); --estatus fin / errorcve09
	DEFINE cMotReenvioTotalBc CHAR(80); --motivo_reenvio/ totalbc
	DEFINE cNomAnalistaTotalCc CHAR(104); --nombre_analista / totalcc
	DEFINE cTotalGlobal CHAR(10); -- totalglobal	

	LET iFolio = 0;
	LET iSqlErr = 0;
	LET cCodRet = '00000';
	LET iNoRegistros = 0;
	LET cTipoSolNumAnalista = ''; --tiposol / numanalista
	LET cProductoNomAnalista = ''; --producto /  nomanalista
	LET cNumSolPerfilUs = ''; --numsolic / perfilusuario
	LET cNumCteErrCve01 = ''; --numcte / errorcve01
	LET cNumSucErrCve02 = ''; --numsuc / errorcve02 
	LET cNomCteErrCve03 = ''; --nomcte / errorcve03
	LET cFechaErrCve04 = ''; --fechasol / errorcve04
	LET cHrErrCve05 = ''; --hora / errorcve05
	LET cEstatusErrCve06 = ''; --estatus / errorcve06
	LET cReenvioErrCve07 = ''; --reenvio_exit SI o NO / errorcve07
	LET cFechaReenvioErrCve08 = ''; --fecha_reenvio / errorcve08
	LET cEstatusFinErrCve09 = '' ; --estatus fin / errorcve09
	LET cMotReenvioTotalBc = ''; --motivo_reenvio/ totalbc
	LET cNomAnalistaTotalCc = ''; --nombre_analista / totalcc
	LET cTotalGlobal = ''; -- totalglobal	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTipoSolNumAnalista, cProductoNomAnalista, cNumSolPerfilUs, cNumCteErrCve01, cNumSucErrCve02, cNomCteErrCve03, cFechaErrCve04, cHrErrCve05, cEstatusErrCve06, cReenvioErrCve07, cFechaReenvioErrCve08, cEstatusFinErrCve09, cMotReenvioTotalBc, cNomAnalistaTotalCc, cTotalGlobal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_bccc_reenviosrep.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTipoSolNumAnalista, cProductoNomAnalista, cNumSolPerfilUs, cNumCteErrCve01, cNumSucErrCve02, cNomCteErrCve03, cFechaErrCve04, cHrErrCve05, cEstatusErrCve06, cReenvioErrCve07, cFechaReenvioErrCve08, cEstatusFinErrCve09, cMotReenvioTotalBc, cNomAnalistaTotalCc, cTotalGlobal;
		END IF;
		
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cTipoSolNumAnalista, cProductoNomAnalista, cNumSolPerfilUs, cNumCteErrCve01, cNumSucErrCve02, cNomCteErrCve03, cFechaErrCve04, cHrErrCve05, cEstatusErrCve06, cReenvioErrCve07, cFechaReenvioErrCve08, cEstatusFinErrCve09, cMotReenvioTotalBc, cNomAnalistaTotalCc, cTotalGlobal;
		END IF;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTipoSolNumAnalista, cProductoNomAnalista, cNumSolPerfilUs, cNumCteErrCve01, cNumSucErrCve02, cNomCteErrCve03, cFechaErrCve04, cHrErrCve05, cEstatusErrCve06, cReenvioErrCve07, cFechaReenvioErrCve08, cEstatusFinErrCve09, cMotReenvioTotalBc, cNomAnalistaTotalCc, cTotalGlobal;
		END IF;
	
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion retorno_01,retorno_02,retorno_03,retorno_04,retorno_05,retorno_06,retorno_07,retorno_08,retorno_09,retorno_10,retorno_11,retorno_12,retorno_13,retorno_14,retorno_15
			INTO cTipoSolNumAnalista, cProductoNomAnalista, cNumSolPerfilUs, cNumCteErrCve01, cNumSucErrCve02, cNomCteErrCve03, cFechaErrCve04, cHrErrCve05, cEstatusErrCve06, cReenvioErrCve07, cFechaReenvioErrCve08, cEstatusFinErrCve09, cMotReenvioTotalBc, cNomAnalistaTotalCc, cTotalGlobal
			FROM bdicnweb:"informix".sw_mon_buro_reenviosrep
			WHERE usuario_inserta = pUsuario
			ORDER BY retorno_11 DESC
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cTipoSolNumAnalista, cProductoNomAnalista, cNumSolPerfilUs, cNumCteErrCve01, cNumSucErrCve02, cNomCteErrCve03, cFechaErrCve04, cHrErrCve05, cEstatusErrCve06, cReenvioErrCve07, cFechaReenvioErrCve08, cEstatusFinErrCve09, cMotReenvioTotalBc, cNomAnalistaTotalCc, cTotalGlobal WITH RESUME; 
			
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN			
			LET cCodRet = '00017';
			RETURN cCodRet, cTipoSolNumAnalista, cProductoNomAnalista, cNumSolPerfilUs, cNumCteErrCve01, cNumSucErrCve02, cNomCteErrCve03, cFechaErrCve04, cHrErrCve05, cEstatusErrCve06, cReenvioErrCve07, cFechaReenvioErrCve08, cEstatusFinErrCve09, cMotReenvioTotalBc, cNomAnalistaTotalCc, cTotalGlobal;			
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cTipoSolNumAnalista, cProductoNomAnalista, cNumSolPerfilUs, cNumCteErrCve01, cNumSucErrCve02, cNomCteErrCve03, cFechaErrCve04, cHrErrCve05, cEstatusErrCve06, cReenvioErrCve07, cFechaReenvioErrCve08, cEstatusFinErrCve09, cMotReenvioTotalBc, cNomAnalistaTotalCc, cTotalGlobal;			
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 25/11/2016',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: REPORTE SOLICITUDES EN BC Y CC',
'DESCRIPCION:SPL que consulta los datos del Reporte de Solicitudes en BC y CC',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_constarjetasadmin_totales(pUsuario CHAR(8), pIdFuncion CHAR(10),pEstatus CHAR(20))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS num_registros,
				  INTEGER AS num_porasignar;
					
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iNoRegPorAsignar INTEGER;
	DEFINE cStatus CHAR(3);
    DEFINE cNumeroTarjeta CHAR(16);	
	DEFINE dFecha DATE;
	DEFINE cBin CHAR(10);
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iNoRegPorAsignar = 0;
	LET cBin = '';	
	
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros, iNoRegPorAsignar;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_constarjetasadmin_totales.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = '' OR pEstatus = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros, iNoRegPorAsignar;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros, iNoRegPorAsignar;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		--OBTENER VALOR DE CODIGO BIN
		SELECT valor
		INTO cBin
		--FROM  bdiatmist:"informix".atm_param
		FROM  bdiatmist@stag_ids1170:"informix".atm_param 
		WHERE cod_param = 1;
		
		IF LENGTH(TRIM(pEstatus)) = 9 THEN			
            
			---SELECT COUNT(*),(SELECT COUNT(*) FROM bdiatmist:atm_tarjeta_admin WHERE estatus='ENT')
			SELECT COUNT(*),(SELECT COUNT(*) FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin WHERE estatus='ENT')
            INTO iNoRegistros, iNoRegPorAsignar
            --FROM bdiatmist:atm_tarjeta_admin;	
              FROM bdiatmist@stag_ids1170:atm_tarjeta_admin;			
		
		ELIF LENGTH(TRIM(pEstatus)) = 3 THEN	
		
            --SELECT COUNT(*),(SELECT COUNT(*) FROM bdiatmist:atm_tarjeta_admin WHERE estatus='ENT')
			SELECT COUNT(*),(SELECT COUNT(*) FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin WHERE estatus='ENT')
            INTO iNoRegistros, iNoRegPorAsignar
            --FROM bdiatmist:atm_tarjeta_admin
			FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin
			WHERE estatus = TRIM(pEstatus);
			
		ELIF LENGTH(TRIM(pEstatus)) = 13 THEN			
			
			LET pEstatus = SUBSTRING(pEstatus FROM 3 FOR 13);
			LET pEstatus = TRIM(cBin) || pEstatus;
			
            --SELECT COUNT(*),(SELECT COUNT(*) FROM bdiatmist:atm_tarjeta_admin WHERE estatus='ENT')
			  SELECT COUNT(*),(SELECT COUNT(*) FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin WHERE estatus='ENT')
            INTO iNoRegistros, iNoRegPorAsignar
            ---FROM bdiatmist:atm_tarjeta_admin
			 FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin
			WHERE numtarjetadmin = TRIM(pEstatus);
			
		ELIF LENGTH(TRIM(pEstatus)) = 10 THEN	
            
			--SELECT COUNT(*),(SELECT COUNT(*) FROM bdiatmist:atm_tarjeta_admin WHERE estatus='ENT')
			SELECT COUNT(*),(SELECT COUNT(*) FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin WHERE estatus='ENT')
            INTO iNoRegistros, iNoRegPorAsignar
            --FROM bdiatmist:atm_tarjeta_admin
			FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin
			WHERE DATE(fechasolicitud)  = DATE(TRIM(pEstatus));
			
		END IF;				
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00000';
			LET iNoRegistros = 0;
			LET iNoRegPorAsignar = 0;
		END IF;			
		
		RETURN cCodRet, iNoRegistros, iNoRegPorAsignar;		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 04/10/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Gestor Tarjetas Administrativas',
'DESCRIPCION: SPL que consulta Totales de Tarjetas Administrativas',
'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 18/11/2016',
'DESCRIPCION: Se Modifica sp por error por consulta por fecha',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreportedetallesucursales(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1), pFechaInicio DATE, pFechaFinal DATE,pTransaccion1 CHAR(4), pTransaccion2 CHAR(4), pSucursal CHAR(4), pCategoria CHAR(2), pConvenio CHAR(5), pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5) AS codret,
                CHAR (44) AS sucursal,
                CHAR (45) AS caja_general,
                CHAR (30) AS entidad,
                INTEGER AS total_operacion,
                MONEY(14,2) AS monto;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iNoRegistros INTEGER;
        DEFINE iRegistros INTEGER;
        DEFINE iRecuperacion INTEGER;
        DEFINE cSucursal CHAR(44);
        DEFINE cCajaGeneral CHAR(45);
        DEFINE cEntidad CHAR(30);
        DEFINE iTotalOperacion INTEGER;
        DEFINE mMonto MONEY(14,2);
		DEFINE iTotalOperacion1 INTEGER;
        DEFINE mMonto1 MONEY(14,2);

		DEFINE cCodRet2 CHAR(5);
        DEFINE vIdptf VARCHAR(5);
        DEFINE vTipos VARCHAR(1);
        DEFINE cClavesit CHAR(3);
        DEFINE fechasit DATE;
        DEFINE vCalles VARCHAR(100);
        DEFINE vNumext VARCHAR(6);
        DEFINE vNumint VARCHAR(5);
        DEFINE cCvecol CHAR(8);
        DEFINE vColonias VARCHAR(100);
        DEFINE cCvemun CHAR(5);
		DEFINE VMunicipio VARCHAR(60);
	    DEFINE cCvelocalidades CHAR(14);
        DEFINE vLocalidades VARCHAR(60);
        DEFINE cCps CHAR(5);
        DEFINE vPlazas VARCHAR(5);
        DEFINE cCiudades CHAR(3);
        DEFINE clave_estado CHAR(5);
        DEFINE vLatitudes VARCHAR(10);
        DEFINE vLongitudes VARCHAR(11);
        DEFINE vTels1 VARCHAR(14);
        DEFINE vTels2 VARCHAR(14);

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cSucursal ='';
        LET cCajaGeneral ='';
        LET cEntidad ='';
        LET iTotalOperacion = 0;
        LET mMonto = 0.00;
        LET iNoRegistros = 0;
        LET iRegistros = 0;
        LET iRecuperacion = 0;
		LET iTotalOperacion1 = 0;
        LET mMonto1 = 0.00;

		LET cCodRet2 ='00000';
        LET vIdptf ='0';
        LET vTipos ='0';
        LET cClavesit ='0';
        LET fechasit =EXTEND(MDY(9,09,1999), YEAR to SECOND);
        LET vCalles ='0';
        LET vNumext ='0';
        LET vNumint ='0';
        LET cCvecol ='0';
        LET vColonias ='';
        LET cCvemun ='0';
		LET VMunicipio ='';
		LET cCvelocalidades ='';
        LET vLocalidades ='';
        LET cCps ='0';
        LET vPlazas ='0';
        LET cCiudades ='0';
        LET clave_estado ='0';
        LET vLatitudes ='0';
        LET vLongitudes ='0';
        LET vTels1 ='0';
        LET vTels2 ='0';

        BEGIN

			ON EXCEPTION SET iSqlErr
					LET cCodRet = iSqlErr;
					RETURN cCodRet, cSucursal, cCajaGeneral, cEntidad, iTotalOperacion,  mMonto;
			END EXCEPTION;

			--SET DEBUG FILE TO '/tmp/mfinis/sp_genreportedetallesucursales.out';
			--TRACE ON;

			IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' OR  pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
					RETURN cCodRet, cSucursal, cCajaGeneral, cEntidad, iTotalOperacion,  mMonto;
			END IF;

			-- VALIDACION DE LA PAGINACION
			IF pRegistros < 0 OR pRecuperacion < 0 THEN
					LET cCodRet = '00098';
					RETURN cCodRet, cSucursal,cCajaGeneral, cEntidad, iTotalOperacion,  mMonto;
			END IF;

			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
					RETURN cCodRet, cSucursal,cCajaGeneral, cEntidad, iTotalOperacion,  mMonto;
			END IF;


			IF pBandera = '1' THEN
			
				IF pFechaInicio IS NULL OR pFechaFinal IS NULL OR  pTransaccion1 = '' OR pTransaccion2 = '' THEN
					LET cCodRet = '00003';
					RETURN cCodRet, cSucursal, cCajaGeneral, cEntidad, iTotalOperacion,  mMonto;
				END IF;

				FOREACH 
				
					SELECT SKIP pRegistros FIRST pRecuperacion sucursal, caja_general, entidad, total_operaciones, monto 
					INTO cSucursal, cCajaGeneral, cEntidad, iTotalOperacion, mMonto
					FROM bdicnweb:"informix".sw_cg_generacionreportedetallessuc WHERE usuario = TRIM(pUsuario)						
				
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, UPPER(TRIM(cSucursal)) , UPPER(TRIM(cCajaGeneral)), UPPER(TRIM(cEntidad)), iTotalOperacion, mMonto WITH RESUME;
				END FOREACH;
				
			ELIF pBandera = '2' THEN
			
				IF pFechaInicio IS NULL OR pFechaFinal IS NULL OR  pTransaccion1 = '' OR pTransaccion2 = '' THEN
					LET cCodRet = '00003';
					RETURN cCodRet, cSucursal, cCajaGeneral, cEntidad, iTotalOperacion,  mMonto;
				END IF;

				SELECT (TRIM(d.sucursal)||' '||TRIM(d.nombre)) AS SUCURSAL, (TRIM(e.cod_proveedor)||' '||TRIM(e.descripcion)) AS cajageneral, f.nombre AS entidad, c.total_operaciones, c.monto
				INTO cSucursal, cCajaGeneral, cEntidad, iTotalOperacion, mMonto
				FROM
				(SELECT SUM(a.monto_tot) as monto, COUNT(*) as total_operaciones, a.sucursal
				 FROM
				(SELECT *
				 FROM bdicheq:sc_movhis
				 WHERE fech_alt  BETWEEN pFechaInicio AND pFechaFinal
				 AND transacc IN (pTransaccion1,pTransaccion2)
				 AND cancelad <> 'S'
				 AND sucursal = pSucursal
				 UNION
				 SELECT *
				 FROM bdicheq:sc_movhis_old
				 WHERE fech_alt  BETWEEN pFechaInicio AND pFechaFinal
				 AND transacc IN (pTransaccion1,pTransaccion2)
				 AND cancelad <> 'S'
				 AND sucursal = pSucursal) AS a
				 INNER JOIN bdisac:"informix".sac_movimientoshistorial AS b
				 ON  a.folio_suc = b.folio_suc
				 WHERE a.cancelad <>'S' AND b.status_cancelado <>'S'
				 AND a.monto_tot = b.importe_pago
				 AND b.fecha_pago BETWEEN pFechaInicio AND pFechaFinal
				 AND b.numcategoria = pCategoria AND b.numconvenio = pConvenio
				 GROUP BY a.sucursal) c
				INNER JOIN bdinteg:"informix".si_sucursales d ON c.sucursal = d.sucursal
				INNER JOIN bdisuc:"informix".ss_proveedores e ON d.plaza_cajagen = e.plaza
				INNER JOIN bdinteg:"informix".si_estados f ON clave_estado = f.estado;

				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, UPPER(TRIM(cSucursal)) , UPPER(TRIM(cCajaGeneral)), UPPER(TRIM(cEntidad)), iTotalOperacion, mMonto;
				
			END IF;

			IF iNoRegistros = 0 AND pRegistros = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet, cSucursal, cCajaGeneral, cEntidad, iTotalOperacion,  mMonto;
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
					LET cCodRet = '1001';
					RETURN cCodRet, cSucursal, cCajaGeneral, cEntidad, iTotalOperacion,  mMonto;
			END IF;

        END;
END PROCEDURE
DOCUMENT 'AUTOR: Lic. Uriel CaamaÃÂ±o Mejia',
'FECHA: 25/02/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTES DE CONVENIOS SAC. ',
'DESCRIPCION: SPL que realiza la consulta del detalle de sucursales para la generacion de reporte de convenios sac.',
'BD: bdicnweb',
'AUTOR: Lic. Uriel CaamaÃÂ±o Mejia',
'FECHA: 23/03/2016',
'DESCRIPCION: Se realizo la modificacion en consulta  del detalle de sucursales para la generacion de reporte de convenios sac.',
'BD: bdicnweb',
'AUTOR: Ing. Guadalupe AngÃÂ¨lica HÃÂ©rnandez PÃÂ©rez',
'FECHA: 08/04/2016',
'DESCRIPCION: Se realizo la modificacion en consulta  de las plazas de caja general para el reporte de convenios sac.',
'BD: bdicnweb',
'AUTOR: M.D.S. Sandra Cano',
'FECHA: 12/04/2016',
'DESCRIPCION: Se realizo la modificacion en consulta para controlar consultas con fechas mayores a un mes.',
'BD: bdicnweb',
'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 15/03/2017',
'DESCRIPCION: Se realizo la modificacion en consulta para tratar los timeout de interact debido al tiempo que tarda en realizar la consulta.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreportedetallesucursales_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFinal DATE,pTransaccion1 CHAR(4), pTransaccion2 CHAR(4), pCategoria CHAR(2), pConvenio CHAR(5), pBandera CHAR(1))
        RETURNING CHAR(5) AS codret,
        INTEGER AS num_registros;
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iNoRegistros INTEGER;
		DEFINE cSucursal CHAR(44);
        DEFINE cCajaGeneral CHAR(45);
        DEFINE cEntidad CHAR(30);
        DEFINE iTotalOperacion INTEGER;
        DEFINE mMonto MONEY(14,2);
		DEFINE cCodRet2 CHAR(5);
        DEFINE vIdptf VARCHAR(5);
        DEFINE vTipos VARCHAR(1);
        DEFINE cClavesit CHAR(3);
        DEFINE fechasit DATE;
        DEFINE vCalles VARCHAR(100);
        DEFINE vNumext VARCHAR(6);
        DEFINE vNumint VARCHAR(5);
        DEFINE cCvecol CHAR(8);
        DEFINE vColonias VARCHAR(100);
        DEFINE cCvemun CHAR(5);
		DEFINE VMunicipio VARCHAR(60);
	    DEFINE cCvelocalidades CHAR(14);
        DEFINE vLocalidades VARCHAR(60);
        DEFINE cCps CHAR(5);
        DEFINE vPlazas VARCHAR(5);
        DEFINE cCiudades CHAR(3);
        DEFINE clave_estado CHAR(5);
        DEFINE vLatitudes VARCHAR(10);
        DEFINE vLongitudes VARCHAR(11);
        DEFINE vTels1 VARCHAR(14);
        DEFINE vTels2 VARCHAR(14);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iNoRegistros = 0;
		LET cSucursal ='';
        LET cCajaGeneral ='';
        LET cEntidad ='';
        LET iTotalOperacion = 0;
        LET mMonto = 0.00;
        LET cCodRet2 = '00000';
        LET vIdptf ='0';
        LET vTipos ='0';
        LET cClavesit ='0';
        LET fechasit =EXTEND(MDY(9,09,1999), YEAR to SECOND);
        LET vCalles ='0';
        LET vNumext ='0';
        LET vNumint ='0';
        LET cCvecol ='0';
        LET vColonias ='';
        LET cCvemun ='0';
		LET VMunicipio ='';
		LET cCvelocalidades ='';
        LET vLocalidades ='';
        LET cCps ='0';
        LET vPlazas ='0';
        LET cCiudades ='0';
        LET clave_estado ='0';
        LET vLatitudes ='0';
        LET vLongitudes ='0';
        LET vTels1 ='0';
        LET vTels2 ='0';
		
        BEGIN        
		ON EXCEPTION SET iSqlErr    
			LET cCodRet = iSqlErr;
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_verificageneracionreportedetallessuc
			SET status = 'E', error_proceso = 'S', error_code = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;          

		--SET DEBUG FILE TO '/tmp/mfinis/sp_genreportedetallesucursales_totales.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		SET LOCK MODE TO WAIT 3;
		DELETE FROM bdicnweb:"informix".sw_verificageneracionreportedetallessuc WHERE usuario = TRIM(pUsuario);
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		SET LOCK MODE TO WAIT 3; 
		INSERT INTO bdicnweb:"informix".sw_verificageneracionreportedetallessuc(usuario,status,error_proceso,error_code)
		VALUES(pUsuario,'I','',TRIM(cCodRet));  
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_verificageneracionreportedetallessuc
			SET status = 'E', error_proceso = 'S', error_code = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_verificageneracionreportedetallessuc
			SET status = 'E', error_proceso = 'S', error_code = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		IF pBandera = '1' THEN
			-- SE LIMPIA TABLA POR USUARIO
			SET LOCK MODE TO WAIT 3;
			DELETE FROM bdicnweb:"informix".sw_cg_generacionreportedetallessuc WHERE usuario = TRIM(pUsuario);
	
			FOREACH 
				SELECT (TRIM(d.sucursal)||' '||TRIM(d.nombre)) AS SUCURSAL, (TRIM(e.cod_proveedor)||' '||TRIM(e.descripcion)) AS cajageneral, f.nombre AS entidad, c.total_operaciones, c.monto
				INTO cSucursal, cCajaGeneral, cEntidad, iTotalOperacion, mMonto FROM
				(SELECT SUM(a.monto_tot) as monto, COUNT(*) as total_operaciones, a.sucursal FROM
				(SELECT * FROM bdicheq:sc_movhis WHERE fech_alt  BETWEEN pFechaInicio AND pFechaFinal AND transacc IN (pTransaccion1,pTransaccion2) AND cancelad <> 'S'
				UNION
				SELECT * FROM bdicheq:sc_movhis_old WHERE fech_alt  BETWEEN pFechaInicio AND pFechaFinal AND transacc IN (pTransaccion1,pTransaccion2) AND cancelad <> 'S') AS a
				INNER JOIN bdisac:"informix".sac_movimientoshistorial AS b ON  a.folio_suc = b.folio_suc WHERE a.cancelad <>'S' AND b.status_cancelado <>'S'
				AND a.monto_tot = b.importe_pago AND b.fecha_pago BETWEEN pFechaInicio AND pFechaFinal AND b.numcategoria = pCategoria AND b.numconvenio = pConvenio
				GROUP BY a.sucursal ORDER BY a.sucursal) c
				INNER JOIN bdinteg:"informix".si_sucursales d ON c.sucursal = d.sucursal
				INNER JOIN bdisuc:"informix".ss_proveedores e ON d.plaza_cajagen = e.plaza -----SI D ESTADOS DE LA TABLA SI_SUCURSALES = A F ESTADOS DE LA TABLA SI_ESTADOS
				INNER JOIN bdinteg:"informix".si_estados f ON d.estado = f.estado
							
				INSERT INTO bdicnweb:"informix".sw_cg_generacionreportedetallessuc(sucursal, caja_general, entidad, total_operaciones, monto, usuario) 
				VALUES(cSucursal, cCajaGeneral, cEntidad, iTotalOperacion, mMonto, pUsuario);
			END FOREACH;						
		ELIF pBandera = '2' THEN						
			SELECT  COUNT(*)
			INTO iNoRegistros
			FROM bdicnweb:"informix".sw_cg_generacionreportedetallessuc where usuario = pUsuario; 		
		
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
			END IF;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		UPDATE bdicnweb:"informix".sw_verificageneracionreportedetallessuc
		SET status = 'T', error_proceso = '', error_code = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
		
		RETURN cCodRet, iNoRegistros;
END;    
END PROCEDURE
DOCUMENT 'AUTOR: Lic. Uriel Caamaño Mejia',
'FECHA: 09/02/2016',
'MODULO: DÉBITO',
'FUNCIONALIDAD: REPORTES DE CONVENIOS SAC',
'DESCRIPCION:SPL que realiza el total del detalle de sucursales para la generacion de reporte de convenios sac.',
'BD: bdicnweb',
'AUTOR: Lic. Uriel Caamaño Mejia',
'FECHA: 23/03/2016',
'DESCRIPCION: Se realizo la modificacion en la consulta del detalle de sucursales para la generacion de reporte de convenios sac.',
'BD: bdicnweb',
'AUTOR: Ing. Guadalupe Angélica Hérnandez Pérez',
'FECHA: 08/04/2016',
'DESCRIPCION: Se realizo la modificacion en consulta del total de las plazas de caja general para el reporte de convenios sac.',
'BD: bdicnweb',
'AUTOR: M.D.S. Sandra Cano',
'FECHA: 12/04/2016',
'DESCRIPCION: Se realizo la modificacion en consulta para controlar consultas con fechas mayores a un mes.',
'BD: bdicnweb',
'AUTOR: Johnattan Esquivel Sánchez',
'FECHA: 15/03/2017',
'DESCRIPCION: Se realizo la modificacion en consulta para tratar los timeout de interact debido al tiempo que tarda en realizar la consulta.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusreportedetallessuc(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cPathFile CHAR(100);
	DEFINE cNomFile CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET cPathFile = '';
	LET cNomFile = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = iSqlErr;
			LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusreportedetallessuc.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT status,error_proceso,error_code
		INTO cStatus,cErrorProceso,cError
		FROM bdicnweb:"informix".sw_verificageneracionreportedetallessuc 
		WHERE usuario = TRIM(pUsuario);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
			RETURN cCodRet,'I',cErrorProceso,cError; 
		ELSE 			
			RETURN cCodRet,cStatus,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA 15/03/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTES DE CONVENIOS SAC',
'DESCRIPCION: SPL que verifica el status de la ejecucion del spl encargado de consultar el Detalle de sucursales para la Generacion de Reporte de Convenios SAC.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_comparasdofisconcaja(pUsuario CHAR(8), pIdFuncion CHAR(10), 
pTipoSaldo CHAR(1), pFechaInicio DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret, 
		CHAR(4) AS id_sucursal,
		CHAR(40) AS desc_sucursal,
		CHAR(4) AS id_cajagen,
		CHAR(40) AS desc_cajagen,
		MONEY(14,2) AS sdo_fisico,     
		MONEY(14,2) AS sdo_contable,     
		MONEY(14,2) AS sdo_diferencia;  		  
		
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cIdSucursal CHAR(4);
	DEFINE cNomSucursal CHAR(40); 
	DEFINE cIdCajaGen CHAR(4);
	DEFINE cNomCajaGen CHAR(40);
	DEFINE mSdoFisico MONEY(14,2);
	DEFINE mSdoContable MONEY(14,2);
	DEFINE mSdoDiferencia MONEY(14,2);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cIdSucursal = '';
	LET cNomSucursal = '';
	LET cIdCajaGen = '';
	LET cNomCajaGen = '';
	LET mSdoFisico = '';
	LET mSdoContable = '';
	LET mSdoDiferencia = '';
	LET iRecuperacion = 0;
	

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet,cIdSucursal,cNomSucursal,cIdCajaGen,cNomCajaGen,mSdoFisico,mSdoContable,mSdoDiferencia; 
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_comparasdofisconcaja.out';
		--TRACE ON;				
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoSaldo = '' OR pFechaInicio IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';			
			RETURN cCodRet,cIdSucursal,cNomSucursal,cIdCajaGen,cNomCajaGen,mSdoFisico,mSdoContable,mSdoDiferencia; 
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';			
			RETURN cCodRet,cIdSucursal,cNomSucursal,cIdCajaGen,cNomCajaGen,mSdoFisico,mSdoContable,mSdoDiferencia;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN			
			RETURN cCodRet,cIdSucursal,cNomSucursal,cIdCajaGen,cNomCajaGen,mSdoFisico,mSdoContable,mSdoDiferencia; 
		END IF;
			
		FOREACH			
			SELECT SKIP pregistros FIRST precuperacion sucursal, nombre, id_caja, nom_caja, sdo_fisico, sdo_contable, sdo_diferencia
			INTO cIdSucursal,cNomSucursal,cIdCajaGen,cNomCajaGen,mSdoFisico,mSdoContable,mSdoDiferencia	
			FROM bdicnweb:"informix".sw_compara_sdo_fis_con 
			WHERE usuario = pUsuario
			
			LET iRecuperacion = iRecuperacion + 1;					
			RETURN cCodRet,NVL(cIdSucursal,''),NVL(UPPER(cNomSucursal),''),NVL(cIdCajaGen,''),NVL(UPPER(cNomCajaGen),''),NVL(mSdoFisico,0),NVL(mSdoContable,0),NVL(mSdoDiferencia,0) WITH RESUME; 			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 			
			RETURN cCodRet,cIdSucursal,cNomSucursal,cIdCajaGen,cNomCajaGen,mSdoFisico,mSdoContable,mSdoDiferencia; 
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';			
			RETURN cCodRet,cIdSucursal,cNomSucursal,cIdCajaGen,cNomCajaGen,mSdoFisico,mSdoContable,mSdoDiferencia; 		
		END IF;	

	END;
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 08/04/2015',
'DESCRIPCION: SPL que obtiene el detalle de los saldos fÃ­sicos y contables tanto de caja general como de sucursales.',
'FUNCIONALIDAD: Saldos FÃ­sicos vs Contables Caja General', 
'MODULO: Caja General',
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 05/04/2017',
'DESCRIPCION: Se modifica SPL para implementar tratado de volumetrÃ­a.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_totalescomparasdofisconcaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSaldo CHAR(1), pFechaInicio DATE)
	RETURNING CHAR(5) AS codret,  
		INTEGER AS totalRegistros; 		  
		
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	
	DEFINE cIdSucursal CHAR(4);
	DEFINE cNomSucursal CHAR(40); 
	DEFINE cIdCajaGen CHAR(4);
	DEFINE cNomCajaGen CHAR(40);
	DEFINE mSdoFisico MONEY(14,2);
	DEFINE mSdoContable MONEY(14,2);
	DEFINE mSdoDiferencia MONEY(14,2);
	
	DEFINE iTotalRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	
	LET cIdSucursal = '';
	LET cNomSucursal = '';
	LET cIdCajaGen = '';
	LET cNomCajaGen = '';
	LET mSdoFisico = '';
	LET mSdoContable = '';
	LET mSdoDiferencia = '';

	LET iTotalRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_verificaprocesosaldos
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RETURN cCodRet, iTotalRegistros; 
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_totalescomparasdofisconcaja.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		SET LOCK MODE TO WAIT 3;
		DELETE FROM bdicnweb:"informix".sw_verificaprocesosaldos WHERE usuario = TRIM(pUsuario);
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		SET LOCK MODE TO WAIT 3; 
		INSERT INTO bdicnweb:"informix".sw_verificaprocesosaldos(usuario,status,error_proceso,error)
		VALUES(pUsuario,'I','',TRIM(cCodRet)); 
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoSaldo = '' OR pFechaInicio IS NULL THEN
			LET cCodRet = '00003';
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_verificaprocesosaldos
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RETURN cCodRet, iTotalRegistros; 
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_verificaprocesosaldos
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RETURN cCodRet, iTotalRegistros;  
		END IF;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM bdicnweb:"informix".sw_compara_sdo_fis_con WHERE usuario = TRIM(pUsuario);
		
		FOREACH
			EXECUTE PROCEDURE bdisuc:"informix".sp_sel_compara_sdo_fis_con2(cEmpresa, pFechaInicio, pTipoSaldo,0,0)
			INTO cCodRetSp,cIdSucursal,cNomSucursal,cIdCajaGen,cNomCajaGen,mSdoFisico,mSdoContable,mSdoDiferencia	
			
			--Se llena tabla 
			INSERT INTO bdicnweb:"informix".sw_compara_sdo_fis_con(usuario, sucursal, nombre, id_caja, nom_caja, sdo_fisico, sdo_contable, sdo_diferencia)
			VALUES (pUsuario, cIdSucursal, cNomSucursal, cIdCajaGen, cNomCajaGen, mSdoFisico, mSdoContable, mSdoDiferencia);							
			
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisuc:sp_sel_compara_sdo_fis_con2_totales';
			ELIF cCodRetSp::INTEGER = 101 THEN
				LET cCodRet = '00472'; --LA FECHA DE CONSULTA ES MAYOR O IGUAL A LA FECHA DE CONTABILIDAD
				SET LOCK MODE TO WAIT 3;
				UPDATE bdicnweb:"informix".sw_verificaprocesosaldos
				SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
				RETURN cCodRet, iTotalRegistros; 
			END IF;
		END FOREACH;
		
		SELECT COUNT(*)
		INTO iTotalRegistros
		FROM bdicnweb:"informix".sw_compara_sdo_fis_con  WHERE usuario = TRIM(pUsuario);		
		
		IF iTotalRegistros = 0 THEN
			LET cCodRet = '00017';
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_verificaprocesosaldos
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RETURN cCodRet, iTotalRegistros;
		ELSE
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_verificaprocesosaldos
			SET status = 'T', error_proceso = '', error = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RETURN cCodRet, iTotalRegistros;
		END IF;	

	END;
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 08/04/2015',
'DESCRIPCION: SPL que obtiene el nÃºmero total de registros de saldos fÃ­sicos y contables tanto de caja general como de sucursales.',
'FUNCIONALIDAD: Saldos FÃ­sicos vs Contables Caja General', 
'MODULO: Caja General',
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 05/04/2017',
'DESCRIPCION: Se modifica SPL para implementar tratado de volumetrÃ­a.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatussaldos(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error,
			  INTEGER AS totalRegistros;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cPathFile CHAR(100);
	DEFINE cNomFile CHAR(50);
	DEFINE iTotalRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET cPathFile = '';
	LET cNomFile = '';
	LET iTotalRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = iSqlErr;
			LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,cErrorProceso,cError,iTotalRegistros;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatussaldos.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cErrorProceso,cError,iTotalRegistros;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cErrorProceso,cError,iTotalRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT status,error_proceso,error
		INTO cStatus,cErrorProceso,cError
		FROM bdicnweb:"informix".sw_verificaprocesosaldos WHERE usuario = TRIM(pUsuario);
		
		IF cStatus = 'T' THEN
			SELECT COUNT(*)
			INTO iTotalRegistros
			FROM bdicnweb:"informix".sw_compara_sdo_fis_con WHERE usuario = TRIM(pUsuario);
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
			RETURN cCodRet,'I',cErrorProceso,cError,iTotalRegistros; 
		ELSE 			
			RETURN cCodRet,cStatus,cErrorProceso,cError,iTotalRegistros;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 05/04/2017',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: SALDOS FÃSICOS VS CONTABLES CAJA GENERAL',
'DESCRIPCION: SPL que verifica el status de la ejecucion del spl encargado de consultar el detalle de los saldos fÃ­sicos y contables.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualizamontosautorizados(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEmpleado CHAR(8),
pMontoMaxDebCargo MONEY(16,2), pMontoMaxDebAbono MONEY(16,2), pMontoMaxDebReverso MONEY(16,2),
pMontoMaxCredCargo MONEY(16,2), pMontoMaxCredAbono MONEY(16,2), pMontoMaxCredReverso MONEY(16,2))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_actualizamontosautorizados.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEmpleado = '' OR
		pMontoMaxDebCargo IS NULL OR pMontoMaxDebAbono IS NULL OR pMontoMaxDebReverso IS NULL OR 
		pMontoMaxCredCargo IS NULL OR pMontoMaxCredAbono IS NULL OR pMontoMaxCredReverso IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	
		
		--ACTUALIZA
		IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_seg_montos_autorizados WHERE id_usuario = pIdEmpleado) THEN
		
			--Respalda registro antes de sufrir cambio
			INSERT INTO bdinteg:"informix".si_seg_montos_autorizados_log
			SELECT id_usuario, monto_max_deb_cargo, monto_max_deb_abono, monto_max_deb_reverso, monto_max_cred_cargo, monto_max_cred_abono, monto_max_cred_reverso, id_usuario_autoriza, CURRENT AS fecha_hora_modificacion
			FROM bdinteg:"informix".si_seg_montos_autorizados
			WHERE id_usuario = pIdEmpleado;
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00282';
				RETURN cCodRet;
			ELSE
			
				UPDATE bdinteg:"informix".si_seg_montos_autorizados
				SET monto_max_deb_cargo = pMontoMaxDebCargo, 
					monto_max_deb_abono = pMontoMaxDebAbono,
					monto_max_deb_reverso = pMontoMaxDebReverso,
					monto_max_cred_cargo = pMontoMaxCredCargo,
					monto_max_cred_abono = pMontoMaxCredAbono,
					monto_max_cred_reverso = pMontoMaxCredReverso,
					id_usuario_autoriza = pUsuario
				WHERE id_usuario = pIdEmpleado;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00282';
					RETURN cCodRet;
				END IF;
			
			END IF;
		
		--INSERTA
		ELSE
		
			INSERT INTO bdinteg:"informix".si_seg_montos_autorizados (id_usuario, monto_max_deb_cargo, monto_max_deb_abono, monto_max_deb_reverso, monto_max_cred_cargo, monto_max_cred_abono, monto_max_cred_reverso, id_usuario_autoriza)
			VALUES (pIdEmpleado, pMontoMaxDebCargo, pMontoMaxDebAbono, pMontoMaxDebReverso, pMontoMaxCredCargo, pMontoMaxCredAbono, pMontoMaxCredReverso, pUsuario);
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00282';
				RETURN cCodRet;
			END IF;
			
		END IF;
		
		RETURN cCodRet;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 21/03/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MONTOS AUTORIZADOS OPERACIONES',
'DESCRIPCION: SPL encargado de insertar y/o actualizar los montos autorizados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultamontosautorizados(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEmpleado CHAR(8))
	RETURNING CHAR(5) AS codret,
		MONEY(16,2) AS monto_max_debito_cargo, 
		MONEY(16,2) AS monto_max_debito_abono, 
		MONEY(16,2) AS monto_max_debito_reverso, 
		MONEY(16,2) AS monto_max_credito_cargo, 
		MONEY(16,2) AS monto_max_credito_abono, 
		MONEY(16,2) AS monto_max_credito_reverso,
		CHAR(8) AS id_usuario_autoriza;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE mMontoMaxDebCargo MONEY(16,2);
	DEFINE mMontoMaxDebAbono MONEY(16,2);
	DEFINE mMontoMaxDebReverso MONEY(16,2);
	DEFINE mMontoMaxCredCargo MONEY(16,2);
	DEFINE mMontoMaxCredAbono MONEY(16,2);
	DEFINE mMontoMaxCredReverso MONEY(16,2);
	DEFINE cUsuarioAutoriza CHAR(8);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET mMontoMaxDebCargo = 0.00;
	LET mMontoMaxDebAbono = 0.00;
	LET mMontoMaxDebReverso = 0.00;
	LET mMontoMaxCredCargo = 0.00;
	LET mMontoMaxCredAbono = 0.00;
	LET mMontoMaxCredReverso = 0.00;
	LET cUsuarioAutoriza = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, mMontoMaxDebCargo, mMontoMaxDebAbono, mMontoMaxDebReverso, mMontoMaxCredCargo, mMontoMaxCredAbono, mMontoMaxCredReverso, cUsuarioAutoriza;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultamontosautorizados.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEmpleado = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, mMontoMaxDebCargo, mMontoMaxDebAbono, mMontoMaxDebReverso, mMontoMaxCredCargo, mMontoMaxCredAbono, mMontoMaxCredReverso, cUsuarioAutoriza;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		SELECT monto_max_deb_cargo, monto_max_deb_abono, monto_max_deb_reverso, monto_max_cred_cargo, monto_max_cred_abono, monto_max_cred_reverso, id_usuario_autoriza
		INTO mMontoMaxDebCargo, mMontoMaxDebAbono, mMontoMaxDebReverso, mMontoMaxCredCargo, mMontoMaxCredAbono, mMontoMaxCredReverso, cUsuarioAutoriza
		FROM bdinteg:"informix".si_seg_montos_autorizados
		WHERE id_usuario = pIdEmpleado;
	
		RETURN cCodRet, NVL(mMontoMaxDebCargo,0), NVL(mMontoMaxDebAbono,0), NVL(mMontoMaxDebReverso,0), NVL(mMontoMaxCredCargo,0), NVL(mMontoMaxCredAbono,0), NVL(mMontoMaxCredReverso,0), cUsuarioAutoriza;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 21/03/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MONTOS AUTORIZADOS OPERACIONES',
'DESCRIPCION: SPL encargado de consulta los montos autorizados del usuario consultado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ccl_actintisrxprodcedula(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, pProducto CHAR(4), pObservaciones CHAR(255))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;

	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ccl_actintisrxprodcedula.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha IS NULL OR pProducto = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_actintisrxprodcedula(pFecha, pProducto, pObservaciones)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:sp_actintisrxprodcedula";
		ELIF iCodRetSp = 110  THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 100  THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 06/03/2017',
'MODULO: Conciliaciones',
'FUNCIONALIDAD: CÃ©dula Contable de Intereses Pagados en Cuentas de Captacion',
'DESCRIPCION: Actualiza el campo observaciones de la cedula contable',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ccl_consintisrxprodcedula(pUsuario CHAR(8), pIdFuncion CHAR(10), pfechaCedula DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				DATE			AS fechaConsultada,
				CHAR(4) 		AS producto, 
				CHAR(40)		AS nombreProducto, 
				DECIMAL(18,2)	AS interesCalculado, 
				DECIMAL(18,2)	AS interesPagado, 
				DECIMAL(18,2)	AS diferenciaInteres, 
				DECIMAL(18,2)	AS isrCalculado,
				DECIMAL(18,2)	AS isrPagado,
				DECIMAL(18,2)	AS ifernciaIsr,
				CHAR(255)		AS observaciones,
				CHAR(1)			AS editable;
		
	DEFINE cCodRet 		CHAR(5);	
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRetSp 	CHAR(5);
	DEFINE iCodRetSp 	INTEGER;
	DEFINE dFecha       DATE;
    DEFINE cProducto    CHAR(4);
    DEFINE cNombre      CHAR(40);
    DEFINE mInteresCalc DECIMAL(18,2);
    DEFINE mInteresPag  DECIMAL(18,2);
    DEFINE mDifInteres  DECIMAL(18,2);
    DEFINE mIsrCalc     DECIMAL(18,2);
    DEFINE mIsrPagado  	DECIMAL(18,2);
    DEFINE mDifIsr      DECIMAL(18,2);
	DEFINE cObservaciones   CHAR(255);
    DEFINE cEditable        CHAR(1);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET cCodRetSp 		= '';
	LET iCodRetSp 		= 0;
	LET dFecha       	= '';
    LET cProducto    	= '';
    LET cNombre      	= '';
    LET mInteresCalc 	= 0.00;
    LET mInteresPag  	= 0.00;
    LET mDifInteres  	= 0.00;
    LET mIsrCalc     	= 0.00;
    LET mIsrPagado  	= 0.00;
    LET mDifIsr      	= 0.00;
	LET cObservaciones = '';
    LET cEditable = '';
	LET iNoRegistros	= 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr, cObservaciones, cEditable;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ccl_consintisrxprodcedula.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pfechaCedula IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr, cObservaciones, cEditable;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr, cObservaciones, cEditable;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr, cObservaciones, cEditable;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdicheq:"informix".sp_consintisrxprodcedula2(pfechaCedula, pRegistros, pRecuperacion)
			INTO cCodRetSp, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr, cObservaciones, cEditable
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:sp_consintisrxprodcedula2";
			ELIF iCodRetSp = 110  THEN
				LET cCodRet = '00003';
			ELIF iCodRetSp = 100  THEN
				LET cCodRet = '00017';
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, dFecha, NVL(cProducto,""), NVL(UPPER(TRIM(cNombre)),""), NVL(mInteresCalc,0), NVL(mInteresPag,0), NVL(mDifInteres,0), NVL(mIsrCalc,0), NVL(mIsrPagado,0), NVL(mDifIsr,0), NVL(cObservaciones,""), NVL(cEditable,"") WITH RESUME;
		END FOREACH;

		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr, cObservaciones, cEditable;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr, cObservaciones, cEditable;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 01/03/2017',
'MODULO: Conciliaciones',
'FUNCIONALIDAD: CÃ©dula Contable de Intereses Pagados en Cuentas de CaptaciÃ³n',
'DESCRIPCION: Realiza la consulta de los datos para el llenado del grid pricipal de la funcionalidad',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ccl_consintisrxprodcedula_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaConciliacion DATE)
		RETURNING CHAR(5) AS codret,
		INTEGER AS totalRegistros;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iExiste = 0;

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iExiste;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ccl_consintisrxprodcedula_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaConciliacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iExiste;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iExiste;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_consintisrxprodcedula2_totales(pFechaConciliacion)
		INTO cCodRetSp, iExiste;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
		RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:sp_consintisrxprodcedula2_totales";
		ELIF iCodRetSp = 110  THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 100  THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iExiste;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 01/03/2017',
'MODULO: Conciliaciones',
'FUNCIONALIDAD: CÃ©dula Contable de Intereses Pagados en Cuentas de CaptaciÃ³n',
'DESCRIPCION: Realiza la consulta del total de los datos para el llenado del grid de la funcionalidad',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ccl_consintisrxproddetalle(pUsuario CHAR(8), pIdFuncion CHAR(10), pfechaCedula DATE, pProducto CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				DATE			AS fechaConsultada,
				CHAR(4) 		AS producto, 
				CHAR(40)		AS nombreProducto,
				CHAR(20)		AS cuenta,
				CHAR(20)		AS cliente,
				DECIMAL(18,2)	AS saldoPromedio,
				INTEGER			AS dias,
				DECIMAL(9,6)	AS tasa,				
				DECIMAL(18,2)	AS interesCalculado, 
				DECIMAL(18,2)	AS interesPagado, 
				DECIMAL(18,2)	AS diferenciaInteres, 
				DECIMAL(18,2)	AS isrCalculado,
				DECIMAL(18,2)	AS isrPagado,
				DECIMAL(18,2)	AS ifernciaIsr;
		
	DEFINE cCodRet 		CHAR(5);	
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRetSp 	CHAR(5);
	DEFINE iCodRetSp 	INTEGER;
	DEFINE dFecha       DATE;
    DEFINE cProducto    CHAR(4);
    DEFINE cNombre      CHAR(40);
	DEFINE cCuenta      CHAR(20);
    DEFINE cCliente     CHAR(20);
    DEFINE mSdoPromedio DECIMAL(18,2);
    DEFINE iDias        SMALLINT;
    DEFINE dTasa        DECIMAL(9,6);
    DEFINE mInteresCalc DECIMAL(18,2);
    DEFINE mInteresPag  DECIMAL(18,2);
    DEFINE mDifInteres  DECIMAL(18,2);
    DEFINE mIsrCalc     DECIMAL(18,2);
    DEFINE mIsrPagado  	DECIMAL(18,2);
    DEFINE mDifIsr      DECIMAL(18,2);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET cCodRetSp 		= '';
	LET iCodRetSp 		= 0;
	LET dFecha       	= '';
    LET cProducto    	= '';
    LET cNombre      	= '';
	LET cCuenta      = '';
    LET cCliente     = '';
    LET mSdoPromedio = 0.00;
    LET iDias        = 0;
    LET dTasa        = 0.000000;
    LET mInteresCalc 	= 0.00;
    LET mInteresPag  	= 0.00;
    LET mDifInteres  	= 0.00;
    LET mIsrCalc     	= 0.00;
    LET mIsrPagado  	= 0.00;
    LET mDifIsr      	= 0.00;
	LET iNoRegistros	= 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha, cProducto, cNombre, cCuenta, cCliente, mSdoPromedio, iDias, dTasa, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ccl_consintisrxproddetalle.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pfechaCedula IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, cProducto, cNombre, cCuenta, cCliente, mSdoPromedio, iDias, dTasa, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dFecha, cProducto, cNombre, cCuenta, cCliente, mSdoPromedio, iDias, dTasa, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFecha, cProducto, cNombre, cCuenta, cCliente, mSdoPromedio, iDias, dTasa, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdicheq:"informix".sp_consintisrxproddetalle2(pfechaCedula, pProducto, pRegistros, pRecuperacion)
			INTO cCodRetSp, dFecha, cProducto, cNombre, cCuenta, cCliente, mSdoPromedio, iDias, dTasa, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:sp_consintisrxproddetalle2";
			ELIF iCodRetSp = 110  THEN
				LET cCodRet = '00003';
			ELIF iCodRetSp = 100  THEN
				LET cCodRet = '00017';
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, dFecha, NVL(cProducto,""), NVL(UPPER(TRIM(cNombre)),""), NVL(cCuenta,""), NVL(cCliente,""), NVL(mSdoPromedio,0), NVL(iDias,0), NVL(dTasa,0), NVL(mInteresCalc,0), NVL(mInteresPag,0), NVL(mDifInteres,0), NVL(mIsrCalc,0), NVL(mIsrPagado,0), NVL(mDifIsr,0) WITH RESUME;
		END FOREACH;

		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFecha, cProducto, cNombre, cCuenta, cCliente, mSdoPromedio, iDias, dTasa, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFecha, cProducto, cNombre, cCuenta, cCliente, mSdoPromedio, iDias, dTasa, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 01/03/2017',
'MODULO: Conciliaciones',
'FUNCIONALIDAD: Conciliacion de Intereses Pagados en Cuentas de Captacian',
'DESCRIPCION: Realiza la consulta de los datos para el llenado del grid de la pantalla modal de la funcionalidad',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ccl_consintisrxproddetalle_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaConciliacion DATE, pProducto CHAR(4))
		RETURNING CHAR(5) AS codret,
		INTEGER AS totalRegistros;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iExiste = 0;

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iExiste;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ccl_consintisrxproddetalle_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaConciliacion IS NULL OR pProducto = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iExiste;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iExiste;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_consintisrxproddetalle2_totales(pFechaConciliacion, pProducto)
		INTO cCodRetSp, iExiste;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
		RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:sp_consintisrxproddetalle2_totales";
		ELIF iCodRetSp = 110  THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 100  THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iExiste;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 01/03/2017',
'MODULO: Conciliaciones',
'FUNCIONALIDAD: ConciliaciÃ³n de Intereses Pagados en Cuentas de CaptaciÃ³n',
'DESCRIPCION: Realiza la consulta de los total de los datos para el llenado del grid de la pantalla modal de la funcionalidad',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ccl_consultainteresisr(pUsuario CHAR(8), pIdFuncion CHAR(10), pfechaCedula DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				DATE			AS fechaConsultada,
				CHAR(4) 		AS producto, 
				CHAR(40)		AS nombreProducto, 
				DECIMAL(18,2)	AS interesCalculado, 
				DECIMAL(18,2)	AS interesPagado, 
				DECIMAL(18,2)	AS diferenciaInteres, 
				DECIMAL(18,2)	AS isrCalculado,
				DECIMAL(18,2)	AS isrPagado,
				DECIMAL(18,2)	AS ifernciaIsr;
		
	DEFINE cCodRet 		CHAR(5);	
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRetSp 	CHAR(5);
	DEFINE iCodRetSp 	INTEGER;
	DEFINE dFecha       DATE;
    DEFINE cProducto    CHAR(4);
    DEFINE cNombre      CHAR(40);
    DEFINE mInteresCalc DECIMAL(18,2);
    DEFINE mInteresPag  DECIMAL(18,2);
    DEFINE mDifInteres  DECIMAL(18,2);
    DEFINE mIsrCalc     DECIMAL(18,2);
    DEFINE mIsrPagado  	DECIMAL(18,2);
    DEFINE mDifIsr      DECIMAL(18,2);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET cCodRetSp 		= '';
	LET iCodRetSp 		= 0;
	LET dFecha       	= '';
    LET cProducto    	= '';
    LET cNombre      	= '';
    LET mInteresCalc 	= 0.00;
    LET mInteresPag  	= 0.00;
    LET mDifInteres  	= 0.00;
    LET mIsrCalc     	= 0.00;
    LET mIsrPagado  	= 0.00;
    LET mDifIsr      	= 0.00;
	LET iNoRegistros	= 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ccl_consultainteresisr.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pfechaCedula IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdicheq:"informix".sp_consintisrxprod2(pfechaCedula, pRegistros, pRecuperacion)
			INTO cCodRetSp, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:sp_consintisrxprod2";
			ELIF iCodRetSp = 110  THEN
				LET cCodRet = '00003';
			ELIF iCodRetSp = 100  THEN
				LET cCodRet = '00017';
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, dFecha, NVL(cProducto,""), NVL(UPPER(TRIM(cNombre)),""), NVL(mInteresCalc,0), NVL(mInteresPag,0), NVL(mDifInteres,0), NVL(mIsrCalc,0), NVL(mIsrPagado,0), NVL(mDifIsr,0) WITH RESUME;
		END FOREACH;

		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 01/03/2017',
'MODULO: Conciliaciones',
'FUNCIONALIDAD: ConciliaciÃ³n de Intereses Pagados en Cuentas de CaptaciÃ³n',
'DESCRIPCION: Realiza la consulta de los datos para el llenado del grid pricipal de la funcionalidad',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ccl_consultainteresisr_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaConciliacion DATE)
		RETURNING CHAR(5) AS codret,
		INTEGER AS totalRegistros;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iExiste = 0;

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iExiste;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ccl_consultainteresisr_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaConciliacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iExiste;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iExiste;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_consintisrxprod2_totales(pFechaConciliacion)
		INTO cCodRetSp, iExiste;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
		RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:sp_consintisrxprod2_totales";
		ELIF iCodRetSp = 110  THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 100  THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iExiste;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 01/03/2017',
'MODULO: Conciliaciones',
'FUNCIONALIDAD: ConciliaciÃ³n de Intereses Pagados en Cuentas de CaptaciÃ³n',
'DESCRIPCION: Realiza la consulta de los total de los datos para el llenado del grid pricipal de la funcionalidad',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ccl_finalizacedulainterescap(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE)
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ccl_finalizacedulainterescap.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_finintisrxprodcedula(pFecha)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:sp_finintisrxprodcedula";
		ELIF iCodRetSp = 110  THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 100  THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 06/03/2017',
'MODULO: Conciliaciones',
'FUNCIONALIDAD: CÃ©dula Contable de Intereses Pagados en Cuentas de CaptaciÃ³n',
'DESCRIPCION: Finaliza la cedula impidiendo la modificacion de esta',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_usuarioscedulas( pFechaConcil DATE, pTipo SMALLINT ) 
RETURNING CHAR(5), CHAR(104), SMALLINT;
    
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iExiste          SMALLINT;
    DEFINE cNombre          CHAR(104);
    DEFINE iFuncion         SMALLINT;
    
    LET cCodRet1         = '000';
    LET cCodRet2         = '';
    LET cCodRet3         = '';
    LET iSqlErr	         = 0;
    LET iSamErr          = 0;
    LET cDesErr          = '';
    LET iExiste          = 0;
    LET cNombre          = '';
    LET iFuncion         = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_usuarioscedulas.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_usuarioscedulas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pFechaConcil is null OR pFechaConcil = '' ) OR
         ( pTipo is null OR pTipo NOT IN(1, 2, 3, 4, 5, 6) ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1, cNombre, iFuncion;
    END IF;
    
    IF pTipo = 1 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontableusuarios
         WHERE concepto = 'CAPITAL'
           AND status = '1';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, funcion
                  INTO cNombre, iFuncion
                  FROM bdicheq:sc_cedulacontableusuarios
                 WHERE concepto = 'CAPITAL'
                   AND status = '1'
                 
                RETURN cCodRet1, cNombre, iFuncion WITH RESUME;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    ELIF pTipo = 2 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontableusuarios
         WHERE concepto = 'INTERES'
           AND status = '1';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, funcion
                  INTO cNombre, iFuncion
                  FROM bdicheq:sc_cedulacontableusuarios
                 WHERE concepto = 'INTERES'
                   AND status = '1'
                 
                RETURN cCodRet1, cNombre, iFuncion WITH RESUME;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    ELIF pTipo = 3 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontableusuarios
         WHERE concepto = 'SOBREGIRO'
           AND status = '1';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, funcion
                  INTO cNombre, iFuncion
                  FROM bdicheq:sc_cedulacontableusuarios
                 WHERE concepto = 'SOBREGIRO'
                   AND status = '1'
                 
                RETURN cCodRet1, cNombre, iFuncion WITH RESUME;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    ELIF pTipo = 4 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontableusuarios
         WHERE concepto = 'PAGARE'
           AND status = '1';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, funcion
                  INTO cNombre, iFuncion
                  FROM bdicheq:sc_cedulacontableusuarios
                 WHERE concepto = 'PAGARE'
                   AND status = '1'
                 
                RETURN cCodRet1, cNombre, iFuncion WITH RESUME;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    ELIF pTipo = 5 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontableusuarios
         WHERE concepto = 'INT PAGARE'
           AND status = '1';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, funcion
                  INTO cNombre, iFuncion
                  FROM bdicheq:sc_cedulacontableusuarios
                 WHERE concepto = 'INT PAGARE'
                   AND status = '1'
                 
                RETURN cCodRet1, cNombre, iFuncion WITH RESUME;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    ELIF pTipo = 6 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontableusuarios
         WHERE concepto = 'INTS E ISR'
           AND status = '1';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, funcion
                  INTO cNombre, iFuncion
                  FROM bdicheq:sc_cedulacontableusuarios
                 WHERE concepto = 'INTS E ISR'
                   AND status = '1'
                 
                RETURN cCodRet1, cNombre, iFuncion WITH RESUME;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    END IF;
    
    END;
    
END PROCEDURE;