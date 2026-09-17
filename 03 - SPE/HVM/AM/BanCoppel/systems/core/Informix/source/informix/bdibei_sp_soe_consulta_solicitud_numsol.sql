CREATE PROCEDURE "informix".sp_soe_consulta_solicitud_numsol(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pNumSolicitud CHAR(10))
		RETURNING CHAR(5) AS codret,
				  CHAR(10) AS cSolicitud, 
				  DATE AS dFechaSolicitud,
				  CHAR(9) AS cNumSerieToken,
				  CHAR(3) AS iIdStatus, 
				  CHAR(30) AS cNumGuia, 
				  SMALLINT AS iNumEnvio,
				  CHAR(1) AS cDomicilio,
				  DECIMAL(18,2) AS iCostoIVA,
				  CHAR(200) AS cComentario;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);

	DEFINE cSolicitud CHAR(10);
	DEFINE dFechaSolicitud DATE;
	DEFINE iIdStatus INTEGER;
	DEFINE cNumGuia	CHAR(30);
	DEFINE iNumEnvio SMALLINT;
	DEFINE iCostoIVA DECIMAL(18,2);
	DEFINE iConsto INTEGER;
	DEFINE cNumSerieToken CHAR(9);
	DEFINE cDomicilio CHAR(1);
	DEFINE cComentario CHAR(200);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';

	LET cSolicitud = '';
	LET dFechaSolicitud = '';
	LET iIdStatus = 0;
	LET cNumGuia = '';
	LET iNumEnvio = 0;
	LET iCostoIVA = 0;
	LET iConsto = 0;
	LET cNumSerieToken = '';
	LET cDomicilio = '';
	LET cComentario = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cSolicitud, dFechaSolicitud, cNumSerieToken, iIdStatus, cNumGuia, iNumEnvio, cDomicilio, iCostoIVA, cComentario;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_consulta_solicitud_numsol.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pNumSolicitud = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSolicitud, dFechaSolicitud, cNumSerieToken, iIdStatus, cNumGuia, iNumEnvio, cDomicilio, iCostoIVA, cComentario;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSolicitud, dFechaSolicitud, cNumSerieToken, iIdStatus, cNumGuia, iNumEnvio, cDomicilio, iCostoIVA, cComentario;
		END IF;
				
		SET LOCK MODE TO WAIT 3;
			
		SET ISOLATION TO DIRTY READ;
		
		/*FOREACH
			SELECT tablaA.solicitud, tablaA.f_solicitud, tablaB.id_status, tablaC.num_guia, tablaC.num_envio, tablaA.comentarios, tablaB.ns_token, tablaA.sec_domicilio
			INTO cSolicitud, dFechaSolicitud, iIdStatus, cNumGuia, iNumEnvio, cComentario, cNumSerieToken, cDomicilio
			FROM bdibei:'informix'.bei_solicitudtoken tablaA
			INNER JOIN bdibei:'informix'.bei_envios tablaC ON 
				tablaC.numcte = tablaA.numcte AND 
				tablaA.solicitud = tablaC.solicitud AND 
				tablaA.solicitud = pNumSolicitud AND
				tablaA.numcte = pNumCte
			INNER JOIN bdibei:'informix'.bei_tokensolicitud tablaB ON tablaB.numcte = tablaA.numcte
			*/
			SELECT solicitud, id_status, sec_domicilio
			INTO cSolicitud, iIdStatus, cDomicilio
			FROM bdibei:"informix".bei_solicitudtoken 
			WHERE numcte = pNumCte AND solicitud = pNumSolicitud;
			
			IF iIdStatus = 130 THEN
				LET cCodRet = '00395'; --EL TOKEN YA FUE ENTREGADO AL CLIENTE. SE CANCELARÃ LA OPERACIÃN (000130 codigo interno)
				RETURN cCodRet, cSolicitud, dFechaSolicitud, cNumSerieToken, iIdStatus, cNumGuia, iNumEnvio, cDomicilio, iCostoIVA, cComentario;
			ELIF iIdStatus = 199 THEN  --LA SOLICITUD SE CANCELA SOLO CUANDO SE CANCELA EL SERVICIO DE EMPRESANET.
				LET cCodRet = '00396'; --LA SOLICITUD HA SIDO CANCELADA (000199 codigo interno)
				RETURN cCodRet, cSolicitud, dFechaSolicitud, cNumSerieToken, iIdStatus, cNumGuia, iNumEnvio, cDomicilio, iCostoIVA, cComentario;
			ELIF iIdStatus = 120 THEN
				LET cCodRet = '00397'; --EL PAQUETE HA SIDO ENVIADO, SOLICITAR QUE ESPERE SU ENTREGA EN EL DOMICILIO DE LA EMPRESA (000120 codigo interno)
				RETURN cCodRet, cSolicitud, dFechaSolicitud, cNumSerieToken, iIdStatus, cNumGuia, iNumEnvio, cDomicilio, iCostoIVA, cComentario;
			ELIF iIdStatus = 100 OR iIdStatus = 110 OR iIdStatus = 180 THEN
				LET cCodRet = '00398'; --LA SOLICITUD AÃN ESTÃ EN PROCESO DE ATENCIÃN SOLICITAR QUE VERIFIQUE POSTERIORMENTE (000100 Ã³ 000110 codigos internos)
				RETURN cCodRet, cSolicitud, dFechaSolicitud, cNumSerieToken, iIdStatus, cNumGuia, iNumEnvio, cDomicilio, iCostoIVA, cComentario;
			ELIF iIdStatus < 100 OR iIdStatus > 130 AND iIdStatus < 170 /*OR iIdStatus = 180 OR iIdStatus = 190*/ OR iIdStatus >= 190 THEN
				LET cCodRet = '00399'; --EL ESTADO DE LA SOLICITUD ES INVÃLIDO
				RETURN cCodRet, cSolicitud, dFechaSolicitud, cNumSerieToken, iIdStatus, cNumGuia, iNumEnvio, cDomicilio, iCostoIVA, cComentario;
			ELIF iIdStatus = 170 THEN
				SELECT valor INTO iConsto FROM bdibpi:"informix".tkn_parametros WHERE id_param = 8;
				LET iCostoIVA = iConsto * 1.16;
				RETURN cCodRet, cSolicitud, dFechaSolicitud, cNumSerieToken, iIdStatus, cNumGuia, iNumEnvio, cDomicilio, iCostoIVA, cComentario WITH RESUME;
			END IF;
			 
		--END FOREACH;
		
		IF DBINFO('sqlca.sqlerrd2')= 0 THEN
			LET cCodRet = '00089'; --EL NUMERO DE SOLICITUD NO EXISTE
			RETURN cCodRet, '', '', '', '', '', '', '', '', '';
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 30/10/2014',
'DESCRIPCION: Consulta el numero de solicitud para el reenvÃ­o de token SOE',
'BD: bdibei',
'MODIFICA: Viridiana Rosas',
'FECHA: 20/11/2014',
'DESCRIPCION: SE MODIFICA LA CONSULTA DE LA SOLICITUD Y EL ESTATUS PARA QUE SOLO CONSULTE EN LA TABLA bei_solicitudtoken',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_soe_consultanombreusuario(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(9), pNumSerTkn CHAR(9), pIdUsuario INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(100) AS cNombreCompleto;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNombreCompleto	CHAR(150);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNombreCompleto	= '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreCompleto;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_consultanombreusuario.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR  pNumSerTkn = '' OR pIdUsuario = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreCompleto;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreCompleto;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF pIdUsuario = 0 THEN
			SELECT tablaDatos.nombre
			INTO cNombreCompleto
			FROM bdibei:"informix".bei_datos_usuario tablaDatos
			INNER JOIN bdibei:"informix".bei_token tablaToken
			ON tablaToken.num_cliente = pNumCte
			AND tablaToken.ns_token = pNumSerTkn
			AND tablaToken.id_usuario = pIdUsuario 
			AND tablaDatos.id_usuario = tablaToken.id_usuario;
			
			IF cNombreCompleto = '' THEN
				LET cCodRet = '00408'; --EL NÃMERO DE SERIE TOKEN NO CORRESPONDE, POR FAVOR VERIFIQUE
			END IF;
		ELSE
			SELECT tablaDatos.nombre
			INTO cNombreCompleto
			FROM bdibei:"informix".bei_datos_usuario tablaDatos
			INNER JOIN bdibei:"informix".bei_token tablaToken
			ON tablaToken.num_cliente = pNumCte
			AND tablaToken.ns_token = pNumSerTkn
			AND tablaToken.id_usuario = pIdUsuario 
			AND tablaDatos.id_usuario = tablaToken.id_usuario;
			
			IF cNombreCompleto = '' THEN
				LET cCodRet = '00408'; --EL NÃMERO DE SERIE TOKEN NO CORRESPONDE, POR FAVOR VERIFIQUE
			END IF;
		END IF;

		RETURN cCodRet, cNombreCompleto;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando MartÃ­n',
'FECHA: 12/11/2014',
'DESCRIPCION: Procedimiento que consulta el nombre el usuario dependiendo el numero de usuario y de su numero de token en SOE',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_soe_consultatipoidentifpm(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  CHAR(2) AS codigoIdentificacion,
				  CHAR(50) AS descripcion;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCodigo CHAR(2); 
	DEFINE cDescripcion CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cCodigo = '';
	LET cDescripcion = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodigo, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_consultatipoidentifpm.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodigo, cDescripcion;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodigo, cDescripcion;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		FOREACH
			SELECT codidentif, descripcion 
			INTO cCodigo, cDescripcion
			FROM bdinteg:"informix".si_tipoidentif
			RETURN cCodRet, cCodigo, cDescripcion WITH RESUME;
		END FOREACH;
		
		IF DBINFO('sqlca.sqlerrd2')= 0 THEN
			LET cCodRet = '00017'; --NO SE OBTUVIERON RESULTADOS
			RETURN cCodRet, cCodigo, cDescripcion;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando MartÃ­n',
'FECHA: 13/11/2014',
'DESCRIPCION: Procedimiento que consulta el tipo de identificaciÃ³n en SOE',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_soe_generarreporteactividades(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(9), pFechaInic DATE, pFechaFin DATE, pCatOperacion CHAR(500))
		RETURNING CHAR(5) AS codret,
				  DATE AS dFechOperacion,
				  CHAR(50) AS cDescripOper,
				  INTEGER AS iIdUsuario,
				  CHAR(150) AS cNombre,
				  CHAR(4) AS cIdOperacion;

	DEFINE cCodRet          CHAR(5);
	DEFINE iSqlErr          INTEGER;
	DEFINE dFechOperacion	DATE;
	DEFINE cDescripOper		CHAR(50);
	DEFINE iIdUsuario		INTEGER ;
	DEFINE cNombre			CHAR(150);
	DEFINE iNoRegistros 	INTEGER;
	DEFINE cIdOperacion 	CHAR (4); 
	DEFINE cSecTransaccion  CHAR(16); 

	LET cCodRet         = '00000';
	LET iSqlErr         = 0;
	LET dFechOperacion	= '';
	LET cDescripOper	= '';
	LET iIdUsuario		= 0;
	LET cNombre 		= '';
	LET iNoRegistros    = 0;
	LET cIdOperacion    = ''; 
	LET cSecTransaccion = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFechOperacion, UPPER(cDescripOper), iIdUsuario, UPPER(cNombre), cIdOperacion;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_soe_generarreporteactividades.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pFechaInic = '' OR pFechaFin = '' OR pCatOperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechOperacion, UPPER(cDescripOper), iIdUsuario, UPPER(cNombre), cIdOperacion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechOperacion, UPPER(cDescripOper), iIdUsuario, UPPER(cNombre), cIdOperacion;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
				
		FOREACH 
			                 	                                        	                                        	                                        
			SELECT a.fecha_oper, a.id_operacion, b.desc_oper, a.sec_transaccion, a.id_usuario, c.nombre
			INTO dFechOperacion, cIdOperacion, cDescripOper, cSecTransaccion, iIdUsuario, cNombre
			FROM bdibei:"informix".bei_bitacora a, bdibei:"informix".bei_cat_operaciones b, bdibei:"informix".bei_datos_usuario c 		 
			WHERE a.num_cliente = pNumCte 
				AND DATE(a.fecha_oper) BETWEEN pFechaInic AND pFechaFin
				AND a.id_operacion IN (select id_operacion from table (bdicnweb:"informix".sp_split_cadena(pCatOperacion, ',')) AS tmp_t(id_operacion))
				AND a.id_operacion = b.id_cat_oper
				AND a.id_usuario = c.id_usuario			
			ORDER BY a.fecha_oper
			RETURN cCodRet, dFechOperacion, UPPER(cDescripOper), iIdUsuario, UPPER(cNombre), cIdOperacion WITH RESUME;
			LET iNoRegistros = iNoRegistros + 1;
				
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFechOperacion, UPPER(cDescripOper), iIdUsuario, UPPER(cNombre), cIdOperacion;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 01/12/2014',
'DESCRIPCION: SPL que realiza la generacion del reporte de actividades',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_soe_nuevo_admin(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumCte CHAR(9), pNumIdentif CHAR(30), pNumSerTkn CHAR(9), 
										pNombre1 CHAR(50), pNombre2 CHAR(50), pApePat CHAR(50), pApeMat CHAR(50), pCodIdentif CHAR(2), pNumIdentifBaja CHAR(30), pEsReplegal CHAR(1))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet 			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE iIdUsuario		INTEGER;
	DEFINE iIdStatus		INTEGER;
	DEFINE cNumSerieToken	CHAR(9);
	DEFINE iFolioContrato	INTEGER;
	DEFINE cFolioActiva		CHAR(12);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdUsuario		= 0;
	LET iIdStatus		= 0;
	LET cNumSerieToken	= '';
	LET iFolioContrato	= 0;
	LET cFolioActiva	= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_nuevo_admin.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pNumIdentif = '' OR pNumSerTkn = '' OR pNombre1 = '' OR
			pApePat = '' OR pApeMat = '' OR pCodIdentif = '' OR pNumIdentifBaja = '' OR pEsReplegal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ; 

		SELECT NVL(id_usuario,0) INTO iIdUsuario 
		FROM bdibei:"informix".bei_token WHERE num_cliente = pNumCte AND ns_token = pNumSerTkn;

		SELECT NVL(id_status,0) INTO iIdStatus
		FROM bdibei:"informix".bei_usuario WHERE num_cliente = pNumCte AND id_usuario = iIdUsuario;
		
		SELECT NVL(folio_contrato,0), NVL(folio_activa,'') INTO iFolioContrato, cFolioActiva
		FROM bdibei:"informix".bei_servicio WHERE num_cliente = pNumCte AND identificacion_admin = pNumIdentifBaja;
		
		UPDATE bdibei:"informix".bei_usuario
		SET id_tipo_usuario = 1
		WHERE num_cliente = pNumCte AND id_usuario = iIdUsuario;
		
		INSERT INTO bdibei:"informix".bei_servicio
			(num_cliente, id_servicio, folio_contrato, folio_activa, id_status, codidentif, identificacion_admin, f_status, f_registro, f_unico_reg, ns_token, 
			status_manco, f_mod_manco, f_reg_manco, id_usuario, apell_paterno, apell_materno, nombre1, nombre2, es_replegal)
		VALUES
			(pNumCte, 0, iFolioContrato, cFolioActiva, iIdStatus, pCodIdentif, pNumIdentif, CURRENT, CURRENT, CURRENT, pNumSerTkn,
			0, CURRENT, CURRENT, iIdUsuario, pApePat, pApeMat, pNombre1, pNombre2, pEsReplegal);
		
		UPDATE bdibei:"informix".bei_usuario_perfil
		SET id_perfil = 10
		WHERE id_usuario = iIdUsuario;
		
		RETURN cCodRet;
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 14/11/2014',
'DESCRIPCION: Procedimiento que realiza la creaciÃ³n de un nuevo Administrador en SOE',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_soe_obtener_solicitud_token(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pSolicitud CHAR(10), pIdStatusSolicitud SMALLINT)
		RETURNING CHAR(5) AS codret,
				CHAR(10) AS no_solicitud,
				DATETIME YEAR TO SECOND AS fecha_solicitud,
				SMALLINT AS unidades;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNoSolicitud CHAR(10);
	DEFINE dFechaSolicitud DATETIME YEAR TO SECOND;
	DEFINE iUnidades SMALLINT;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNoSolicitud = '';
	LET dFechaSolicitud = NULL;
	LET iUnidades = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNoSolicitud, dFechaSolicitud, iUnidades;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_obtener_solicitud_token.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pIdStatusSolicitud IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNoSolicitud, dFechaSolicitud, iUnidades;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNoSolicitud, dFechaSolicitud, iUnidades;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT solicitud, f_solicitud, unidades
				INTO cNoSolicitud, dFechaSolicitud, iUnidades
				FROM bdibei:"informix".bei_solicitudtoken
				WHERE numcte = pNumCliente
					AND solicitud = CASE WHEN pSolicitud = '' THEN solicitud ELSE pSolicitud END
					AND id_status = pIdStatusSolicitud
				ORDER BY f_solicitud
		
			RETURN cCodRet, cNoSolicitud, dFechaSolicitud, iUnidades WITH RESUME;
			LET iNoRegistros = iNoRegistros + 1;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			--LET cCodRet = '00017';
			IF pIdStatusSolicitud = 170 THEN ---REENVIO TOKEN
				LET cCodRet = '00421';
			ELSE --- PREACTIVACION DE TOKEN
				LET cCodRet = '00422';
			END IF;
			RETURN cCodRet, cNoSolicitud, dFechaSolicitud, iUnidades;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 24/11/2014',
'DESCRIPCION: Consulta las solicitudes de un cliente con el estatus dado de entrada',
'La variable pSolicitud puede ser opcional',
'FECHA: 15/01/2015',
'DESCRIPCION: Se modifica procedimiento para codigos de retorno correctos dependiendo de la funcionalidad cuando no existen datos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_soe_obtenerdatosgenreasigroladmin(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(9), pNumSerTkn CHAR(9))
		RETURNING CHAR(5) AS codret,
				  CHAR(100) AS cNombreCompleto,
				  INTEGER AS iIdUsuario;
				  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iIdUsuario	INTEGER;  
	DEFINE cNombreCompleto CHAR(100);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iIdUsuario	= 0;
	LET cNombreCompleto	= '';	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreCompleto, iIdUsuario;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_obtenerdatosgenreasigroladmin.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pNumSerTkn = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreCompleto, iIdUsuario;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreCompleto, iIdUsuario;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT nvl(id_usuario,0) INTO iIdUsuario FROM bdibei:"informix".bei_token WHERE num_cliente = pNumCte AND ns_token = pNumSerTkn;
		
		IF EXISTS(SELECT id_status FROM bdibei:"informix".bei_usuario WHERE num_cliente = pNumCte AND id_usuario = iIdUsuario AND id_status = 30) THEN
			IF EXISTS(SELECT id_status FROM bdibpi:"informix".tkn_nseries WHERE ns_token = pNumSerTkn 
					AND id_status = 140 OR id_status = 150 OR id_status = 151 OR id_status = 152 OR id_status = 153 OR id_status = 160) THEN

				EXECUTE PROCEDURE bdibei:"informix".sp_soe_consultanombreusuario(pUsuario, pIdFuncion, pNumCte, pNumSerTkn, iIdUsuario)
				INTO cCodRetSp, cNombreCompleto;
				
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_soe_consultanombreusuario';
				ELIF iCodRetSp = 00003 THEN
					LET cCodRet = '00003'; --FALTA ALGUN PARAMETRO DE ENTRADA
				ELIF iCodRetSp = 00408 THEN
					LET cCodRet = '00408'; --EL NÃMERO DE SERIE TOKEN NO CORRESPONDE, POR FAVOR VERIFIQUE
				END IF;
			ELSE
				LET cCodRet = '00185'; --USUARIO SIN TOKEN ASIGNADO
			END IF;
		ELSE
			LET cCodRet = '00410'; --EL USUARIO NO TIENE EL SERVICIO ACTIVO, POR FAVOR VERIFIQUE
		END IF;
		
		RETURN cCodRet, cNombreCompleto, iIdUsuario;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 12/11/2014',
'DESCRIPCION: Procedimiento que consulta los datos Generales de un Cliente en SOE',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_soe_obtenertoken(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(9), pNumSerTkn CHAR(9))
		RETURNING CHAR(5) AS codret,
				  CHAR(9) AS cNsToken,
				  SMALLINT AS cIdStatus;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCodRetSp INTEGER;
	DEFINE cNsToken CHAR(9); 
	DEFINE cIdStatus SMALLINT;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iCodRetSp = 0;
	LET cNsToken  = '';
	LET cIdStatus = 0;

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNsToken, cIdStatus;
		END EXCEPTION;      
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_obtenertoken.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pNumSerTkn = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNsToken, cIdStatus;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNsToken, cIdStatus;
		END IF;

		SELECT tablaA.ns_token, tablaB.id_status
		INTO cNsToken, cIdStatus
		FROM bdibei:"informix".bei_tokensolicitud tablaA
		INNER JOIN bdibpi:"informix".tkn_nseries tablaB
			ON	tablaA.numcte = pNumCte
			AND tablaA.ns_token = pNumSerTkn
			AND tablaA.ns_token = tablaB.ns_token;
				
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00408'; --EL NÃMERO DE SERIE TOKEN NO CORRESPONDE, POR FAVOR VERIFIQUE
			RETURN cCodRet, cNsToken, cIdStatus;
		END IF;
		
		IF cIdStatus = 199 THEN
			LET cCodRet = '00409'; --TOKEN CON ESTATUS CANCELADO
			RETURN cCodRet, cNsToken, cIdStatus;
		END IF;
		RETURN cCodRet, cNsToken, cIdStatus;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 11/11/2014',
'DESCRIPCION: Procedimiento que regresa el numero de serie token y el id del estatus en SOE',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_soe_obtstatus_cancserv(pUsuario CHAR(8), pIdFuncion CHAR(10), pStatus CHAR(6), pDescribeStatus CHAR(40), pUsuarioAutenticado CHAR(30), pNumCliente CHAR(9))
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
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_bitacoracancelaservicio.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pStatus = '' OR pDescribeStatus = '' OR pUsuarioAutenticado = '' OR pNumCliente = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		INSERT INTO bdinteg:"informix".soe_bitacora_cancelaservicio
			(status, fecha, describe_status, num_empleado, usuario_autenticado, num_cliente)
		VALUES
			(TRIM(pStatus), CURRENT, TRIM(pDescribeStatus), TRIM(pUsuario), TRIM(pUsuarioAutenticado), TRIM(pNumCliente));
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 27/10/2014',
'DESCRIPCION: SE BITACOREA LA CANCELACION DE UN SERVICIO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_soe_set_solicitudstatus(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pNumSerieToken CHAR(10), pStatusNuevo SMALLINT)
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
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_set_solicitudstatus.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pNumSerieToken = '' OR pStatusNuevo IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		IF EXISTS (SELECT numcte FROM bdibei:"informix".bei_tokensolicitud WHERE numcte = pNumCliente AND ns_token = pNumSerieToken) THEN
			
			UPDATE bdibei:"informix".bei_tokensolicitud
			SET id_status = pStatusNuevo
			WHERE numcte = pNumCliente AND ns_token = pNumSerieToken;
			
			UPDATE bdibei:"informix".bei_servicio
			SET ns_token = ''
			WHERE num_cliente = pNumCliente AND ns_token = pNumSerieToken;
			
		ELSE
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 29/10/2014',
'DESCRIPCION: Actualiza el estatus de la solicitud de un numero de serie de token de un cliente',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_soe_validasolicitud(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(9), pNumSerTkn CHAR(10))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE sIdStatus SMALLINT;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET sIdStatus = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_validasolicitud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pNumSerTkn = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
				
		FOREACH SELECT NVL (id_status, 0) -- '0' en caso que sea nulo
			INTO sIdStatus FROM bdibei:"informix".bei_solicitudtoken
			WHERE numcte = pNumCte
			AND solicitud = pNumSerTkn
			LET iNoRegistros = iNoRegistros + 1;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00413';			RETURN cCodRet;
		END IF;
		
		IF sIdStatus < 120 THEN
			LET cCodRet = '00414';		ELIF sIdStatus > 120 THEN
			LET cCodRet = '00415';		ELIF sIdStatus = 0 THEN
			LET cCodRet = '00416';		ELIF sIdStatus = 120 THEN
			RETURN cCodRet;
		END IF;
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 02/12/2014',
'DESCRIPCION: Procedimiento que valida que la solicitud se igual a 120 en SOE',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_soe_consultacomentario(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pReferencia CHAR(30), pIdOperacion CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(50) AS mensaje,
		CHAR(60) AS folio,
		CHAR(8) AS empleado,
		DATETIME YEAR TO SECOND AS fecha_registro,
		CHAR(4) AS id_operacion,
		CHAR(9) AS num_cliente,
		CHAR(500) AS comentario;
		
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cMensaje VARCHAR(255);
	DEFINE iExiste SMALLINT;
	DEFINE cFolio CHAR(60);
	DEFINE cEmpleado CHAR(8);
	DEFINE cFecRegistro DATETIME YEAR TO SECOND;
	DEFINE cIdOperacion CHAR(4);
	DEFINE cNumCliente CHAR(9);
	DEFINE cComentario CHAR(500);
	DEFINE iNoRegs INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cMensaje = '';
	LET iExiste = 0;
	LET cFolio = '';
	LET cEmpleado = '';
	LET cFecRegistro = NULL;
	LET cIdOperacion = '';
	LET cNumCliente = '';
	LET cComentario = '';
	LET iNoRegs = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cMensaje = 'ERROR INTERNO EN BASE DE DATOS';
			RETURN cCodRet, cMensaje, cFolio, cEmpleado, cFecRegistro, cIdOperacion, cNumCliente, cComentario;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_consultacomentario.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pReferencia = '' OR pRegistros = '' OR pRecuperacion = '' THEN
			LET cCodRet = '00003';
			LET cMensaje = 'PARAMETROS INCORRECTOS';
			RETURN cCodRet, cMensaje, cFolio, cEmpleado, cFecRegistro, cIdOperacion, cNumCliente, cComentario;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cMensaje, cFolio, cEmpleado, cFecRegistro, cIdOperacion, cNumCliente, cComentario;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT COUNT(num_cliente)
		INTO iExiste
		FROM bdibei:soe_comentarios
		WHERE num_cliente = pNumCliente
			AND referencia = pReferencia;
			
		IF iExiste <> 0 THEN
			
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion folio, num_empleado, f_registro, id_operacion, num_cliente, comentario
				INTO cFolio, cEmpleado, cFecRegistro, cIdOperacion, cNumCliente, cComentario
				FROM bdibei:soe_comentarios
				WHERE num_cliente = pNumCliente AND referencia = pReferencia AND id_operacion = pIdOperacion
				ORDER BY f_registro DESC
				
				LET iNoRegs = iNoRegs + 1;
				
				RETURN cCodRet, cMensaje, cFolio, cEmpleado, cFecRegistro, cIdOperacion, cNumCliente, cComentario WITH RESUME;
				
			END FOREACH;
			
			IF iNoRegs = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cMensaje, cFolio, cEmpleado, cFecRegistro, cIdOperacion, cNumCliente, cComentario;
			ELIF iNoRegs = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001'; -- No existen mas registros
				LET cMensaje = 'NO EXISTEB MAS REGISTROS';
				
				RETURN cCodRet, cMensaje, cFolio, cEmpleado, cFecRegistro, cIdOperacion, cNumCliente, cComentario;
			END IF;
		
		ELIF iExiste = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cMensaje, cFolio, cEmpleado, cFecRegistro, cIdOperacion, cNumCliente, cComentario;
		END IF;
				
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 04/09/2013",
"DESCRIPCION: Procedimiento que consulta los mensajes de un cliente",
"BD:bdibei",
"MODIFICACIÃN: Se modifica tamaÃ±o de retorno del campo folio",
"FECHA: 13/11/2014";

CREATE PROCEDURE "informix".sp_soe_insertacomentario(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pcFolio char(10), pcNumEmpleado char(8),
                                                     pcIdOperacion char(4), pcNumCte char(9), pcReferencia varchar(30), pcComentario char(500))

        RETURNING       CHAR(5) AS cCodRetChar,
                        VARCHAR(50) AS vMensajeErr;

        DEFINE v_cod_ret            CHAR(5);
        DEFINE vMensajeErr          VARCHAR(50);
        DEFINE iExiste              SMALLINT;
        DEFINE iSqlErr              INTEGER;
        DEFINE iSamErr              INTEGER;
		----------------------------------------
		DEFINE vcmes                CHAR(2);
		DEFINE vcanio               CHAR(2);
        DEFINE cFolioMax            CHAR(60);
		----------------------------------------
        LET vMensajeErr = '';
        LET iExiste     =0;
        LET vcmes       ='';
        LET vcanio      ='';
        LET cFolioMax   ='';

        BEGIN

                ON EXCEPTION
                        SET iSqlErr, iSamErr
                        IF iSqlErr <> 0 THEN
                                LET v_cod_ret = iSqlErr;
                                LET vMensajeErr= 'ERROR INTERNO EN BASE DE DATOS';
                        END IF;
                        RETURN v_cod_ret,vMensajeErr;
                END EXCEPTION;

        --SET DEBUG FILE TO "/tmp/sp_soe_insertacomentario.out";
		--TRACE ON;

			IF pIdUsuario = '' OR pIdFuncion = '' THEN
					LET v_cod_ret = '00003';
					RETURN v_cod_ret,NULL;
			END IF;

			EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO v_cod_ret;
			IF v_cod_ret <> '00000' THEN
					RETURN v_cod_ret,vMensajeErr;
			END IF;


			IF pcFolio = '' OR pcNumEmpleado = '' OR pcIdOperacion = '' OR pcNumCte = '' OR pcReferencia = '' OR pcComentario = '' THEN
					LET v_cod_ret = '00003';
					LET vMensajeErr= 'PARAMETROS INCORRECTOS';
					RETURN v_cod_ret,vMensajeErr;
			END IF;

			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;

			--Se Agrega para validar y crear el folio para Bloqueo y Desbloqueo de Token--
			LET cFolioMax = pcFolio;
			--SELECT SUBSTRING(fecha_hoy FROM 9 FOR 10)
			SELECT substring((year(fecha_hoy)) FROM 3 FOR 2), lpad(month(fecha_hoy),2,"0")
			INTO vcanio, vcmes
			FROM bdinteg:"informix".si_fechas;

            --SELECT CASE SUBSTRING(fecha_hoy FROM 1 FOR 2)
            SELECT CASE vcmes
            WHEN '01' THEN 'A'--ENERO
                        WHEN '02' THEN 'B'--FEBRERO
                        WHEN '03' THEN 'C'--MARZO
                        WHEN '04' THEN 'D'--ABRIL
                        WHEN '05' THEN 'E'--MAYO
                        WHEN '06' THEN 'F'--JUNIO
                        WHEN '07' THEN 'G'--JULIO
                        WHEN '08' THEN 'H'--AGOSTO
                        WHEN '09' THEN 'I'--SEPTIEMBRE
                        WHEN '10' THEN 'J'--OCTUBRE
                        WHEN '11' THEN 'K'--NOVIEMBRE
                        WHEN '12' THEN 'L'--DICIEMBRE
                        ELSE 'UN' END
                        INTO vcmes
            FROM bdinteg:"informix".si_fechas;

        IF (pcIdOperacion = "1020") THEN --BLOKEO TKN
            LET cFolioMax = 'BT' || TRIM(cFolioMax) || TRIM(vcmes) || vcanio;
                ELIF (pcIdOperacion = "1025") THEN --BLOQUEO DE USUARIO.La letra del mes y el anio ya viene desde el programa, solo se concatena la inicial.
            LET cFolioMax = 'BU' || TRIM(cFolioMax);
                ELIF (pcIdOperacion = "1026") THEN --RESET DE USUARIO.La letra del mes y el anio ya viene desde el programa, solo se concatena la inicial.
            LET cFolioMax = 'RU' || TRIM(cFolioMax);
        ELIF (pcIdOperacion = "1033") THEN --DESBLOKEO TKN
            LET cFolioMax = 'DT' || TRIM(cFolioMax) || TRIM(vcmes) || vcanio;
                ELIF (pcIdOperacion = "1037") THEN --DESBLOQUEO DE USUARIO. La letra del mes y el anio ya viene desde el programa, solo se concatena la inicial.
                        LET cFolioMax = 'DU' || TRIM(cFolioMax);
        END IF;

                SELECT COUNT(*) INTO iExiste FROM bdibei:"informix".soe_comentarios WHERE folio=TRIM(cFolioMax);

                IF(iExiste > 0) THEN
                        LET v_cod_ret = '00183';
                        LET vMensajeErr= 'VERIFICAR FOLIO YA EXISTE EN TABLA.';
                        RETURN v_cod_ret,vMensajeErr;
                END IF;

                INSERT INTO bdibei:"informix".soe_comentarios (folio, num_empleado, f_registro, id_operacion, num_cliente, referencia, comentario)
                VALUES(TRIM(cFolioMax), pcNumEmpleado, current, pcIdOperacion, pcNumCte, pcReferencia, pcComentario);

                RETURN v_cod_ret, vMensajeErr;

        END
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'DESCRIPCION: Inserta comentarios en SOE',
'FECHA: 10/12/2014',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_altamod_limites_cuenta_oper_bei (
    pcliente  CHAR(9),  prestricc CHAR(2),  pcuenta CHAR(16),
    poperacion CHAR(2), plimite DECIMAL(16,2),  pcanal CHAR(2), 
    pusuario  CHAR(10) )
    RETURNING CHAR(3), CHAR(80);  

    --------------------------------------------------------------------
    --DOCUMENTACION
    --Guarda/Actualiza los limites de las empresas personalizados.
    --ya sea por operacion o por cuenta.
    --Realizo: Berenice Noriega Guevara
    --Fecha: 29/Agosto/2014
    --Modificado: 28/Enero/2015
    --Descripcion: Se ajusta para que no regrese error si se intenta 
    --              Borrar y ya no existe.
    --Modifico:Berenice Noriega - BanCoppel
    --LIBERADO A PRODUCCION: 30 ENERO 2015
    --------------------------------------------------------------------


--Se definen variables----
DEFINE iSql_Err INT;
DEFINE cCodRet CHAR(3);
DEFINE cErrorInfo CHAR(80);	--MENSAJE DE CODIGO DE RETORNO

--INICIALIZACION DE VARIABLES--
LET iSql_Err = 0;
LET cCodRet = '000';
LET cErrorInfo="PROCESO EXITOSO";

--SET DEBUG FILE TO "/home/informix/BereniceOut/sp_altamod_limites_cuenta_oper_bei.out";
--TRACE ON;


BEGIN

    ON EXCEPTION SET iSql_Err
        IF iSql_Err <> 0 THEN
            LET cCodRet = iSql_Err;
            RETURN cCodRet,cErrorInfo;
        END IF;
    END EXCEPTION;

----------------------------------------------------------------
---Valida que no tenga datos vacios o nulos---------------------

    IF nvl(pcliente,'') = ''  OR pcliente IS NULL THEN
        LET cCodRet='001';
        LET cErrorInfo='CLIENTE NO VALIDO';
        RETURN cCodRet, cErrorInfo;
    END IF;

    IF nvl(prestricc,'') = '' OR prestricc IS NULL THEN
        LET cCodRet='002';
        LET cErrorInfo='CODIGO DE RESTRICCION VACIO';
        RETURN cCodRet, cErrorInfo;
    END IF;

    IF nvl(poperacion,'') = '' OR poperacion IS NULL THEN
        LET cCodRet='003';
        LET cErrorInfo='CODIGO DE OPERACION VACIO';
        RETURN cCodRet, cErrorInfo;
    END IF;

    IF nvl(pcanal,'') = '' OR pcanal IS NULL THEN
        LET cCodRet='004';
        LET cErrorInfo='CANAL VACIO';
        RETURN cCodRet, cErrorInfo;
    END IF;

    IF nvl(pusuario,'') = '' OR pusuario IS NULL THEN
        LET cCodRet='005';
		LET cErrorInfo='USUARIO VACIO';
        RETURN cCodRet, cErrorInfo;
    END IF;

	IF nvl(plimite,'') = '' OR plimite IS NULL THEN
        LET cCodRet='006';
        LET cErrorInfo='LIMITE VACIO';
        RETURN cCodRet, cErrorInfo;
    END IF;

    IF prestricc = '01' THEN --POR CUENTA
        IF nvl(pcuenta,'') = '' OR pcuenta IS NULL THEN
            LET cCodRet='007';
            LET cErrorInfo='CUENTA VACIO NO VALIDO PARA RESTRICCION';
            RETURN cCodRet, cErrorInfo;
        END IF;
    END IF;

-------------------------------------------------------------------------------
    IF NOT EXISTS(select num_cliente from bdinteg:"informix".si_plimites_empresas 
                  where num_cliente = pcliente and id_restriccion=prestricc
                  and num_cta=pcuenta and id_operacion=poperacion
                  and id_canal=pcanal) then
		
		IF plimite>0 then
			--Si no existe lo registramos
			INSERT INTO bdinteg:"informix".si_plimites_empresas(num_cliente, id_restriccion, num_cta, id_operacion, id_canal, activo, tope_max_pesos, tope_max_udis, id_periodo, envio_mensaje, id_tipo_mensaje, id_medio, id_mensaje, f_registro, usuario_alta, f_modifica, 
			usuario_modifica)
			VALUES(pcliente, prestricc, pcuenta, poperacion, pcanal, '1', plimite, 0, '01', 'F', '  ', '  ', 'NO_DISP   ', current, pusuario, current, pusuario);
		
		ElSE --El limite no existe, pero se ejecuta el SPL con valor 0, lo ignoramos
			LET cCodRet='000';
            LET cErrorInfo='EL REGISTRO NO EXISTE Y SE INTENTA BORRAR';
            RETURN cCodRet, cErrorInfo;
		END IF;
		

    ELSE --Ya existe un registro
		IF plimite>0 then 	--Si ya existe y el limiete es mayor a cero se trata de una actualización.	
			update bdinteg:"informix".si_plimites_empresas 
			set tope_max_pesos=plimite, f_modifica=current, usuario_modifica=pusuario
			where num_cliente = pcliente and id_restriccion=prestricc
			and num_cta=pcuenta and id_operacion=poperacion
			and id_canal=pcanal;
		Else 	--Si ya existe y el limite es 0, estonses se elimina el registro
			DELETE bdinteg:"informix".si_plimites_empresas 
			WHERE num_cliente = pcliente and id_restriccion=prestricc
			and num_cta=pcuenta and id_operacion=poperacion
			and id_canal=pcanal;
		END IF;
    
	END IF;

    RETURN cCodRet, cErrorInfo;

END
END PROCEDURE;