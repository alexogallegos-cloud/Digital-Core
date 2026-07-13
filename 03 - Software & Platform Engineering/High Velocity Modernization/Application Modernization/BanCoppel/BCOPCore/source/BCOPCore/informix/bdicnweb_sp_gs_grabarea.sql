CREATE PROCEDURE "informix".sp_gs_grabarea(pUsuario CHAR(8), pIdFuncion CHAR(10), pClaveArea CHAR(10), pDescripcion CHAR(50), pTipoOperacion SMALLINT, pStatus CHAR(1), pIpUsuario CHAR(15), pMacAddress CHAR(12))
		RETURNING CHAR(5) AS codret,
				INTEGER AS id_area;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE bActivo BOOLEAN;
	DEFINE iIdArea INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET bActivo = 'f';
	LET iIdArea = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdArea;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_grabarea.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pClaveArea = '' OR pDescripcion = '' OR pTipoOperacion IS NULL OR pStatus = '' OR pIpUsuario = '' OR pMacAddress = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdArea;
		END IF;
		
		IF pTipoOperacion NOT IN (1,2) THEN
			LET cCodRet = '00148';
			RETURN cCodRet, iIdArea;
		END IF;
		
		IF pStatus NOT IN ('0', '1') THEN
			LET cCodRet = '00102';
			RETURN cCodRet, iIdArea;
		ELSE
			LET bActivo = DECODE(pStatus, '0', 'f', '1', 't', 'f');
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdArea;
		END IF;
		
		IF pTipoOperacion = 1 THEN -- ALTA
			IF NOT EXISTS (SELECT clave_area FROM bdicnweb:sw_gs_area WHERE clave_area = pClaveArea) THEN
				INSERT INTO bdicnweb:sw_gs_area(clave_area, descripcion_area, status, user_insert, ip_insert, mac_insert)
				VALUES(pClaveArea, pDescripcion, bActivo, pUsuario, pIpUsuario, pMacAddress);
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN -- NO SE REALIZO LA INSERCION
					LET cCodRet = '00282';
					RETURN cCodRet, iIdArea;
				END IF;
				
				SELECT id_area
				INTO iIdArea
				FROM bdicnweb:sw_gs_area
				WHERE clave_area = pClaveArea;
				
				RETURN cCodRet, iIdArea;
			ELSE -- EL REGISTRO YA EXISTE
				LET cCodRet = '00004';
				RETURN cCodRet, iIdArea;
			END IF;
		ELIF pTipoOperacion = 2 THEN -- ACTUALIZACION
		
			IF NOT EXISTS (SELECT clave_area FROM bdicnweb:sw_gs_area WHERE clave_area = pClaveArea) THEN
				LET cCodRet = '00001';
				RETURN cCodRet, iIdArea;
			ELSE -- EL REGISTRO YA EXISTE
				SELECT id_area
				INTO iIdArea
				FROM bdicnweb:sw_gs_area
				WHERE clave_area = pClaveArea;
				
				UPDATE bdicnweb:sw_gs_area
				SET descripcion_area = pDescripcion,
					status = bActivo,
					user_update = pUsuario,
					fecha_update = CURRENT,
					ip_update = pIpUsuario,
				    mac_update = pMacAddress
				WHERE id_area = iIdArea;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN -- NO SE ACTUALIZO REGISTRO ALGUNO
					LET cCodRet = '00283';
					RETURN cCodRet, iIdArea;
				END IF;
				
				RETURN cCodRet, iIdArea;
			END IF;
		
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 02/05/2014',
'DESCRIPCION: Guarda/Actualiza un area en el catalogo para el Gestor de solicitudes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_grabarsolicitudesarea(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdArea INTEGER, pTipoOperacion SMALLINT, pPermisosPlantilla CHAR(250), pIpUsuario CHAR(15), pMacAddress CHAR(12))
		RETURNING CHAR(5) AS codret,
				INTEGER AS registros_procesados;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCadenaValores CHAR(15);
	DEFINE cCadena CHAR(15);
	DEFINE iIdSolicitud INTEGER;
	DEFINE bEsResponsable BOOLEAN;
	DEFINE bEsSolicitante BOOLEAN;
	DEFINE iNoRegsProcesados INTEGER;
	DEFINE iParams SMALLINT;
	DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCadenaValores = '';
	LET cCadena = '';
	LET iIdSolicitud = 0;
	LET bEsResponsable = 'f';
	LET bEsSolicitante = 'f';
	LET iNoRegsProcesados = 0;
	LET iParams = 0;
	LET bInTransaction = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegsProcesados;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-691)
			ROLLBACK;
			LET cCodRet = '00284';
			
			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;
			
			RETURN cCodRet, iNoRegsProcesados;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_grabarsolicitudesarea.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdArea IS NULL OR pTipoOperacion IS NULL OR pPermisosPlantilla = '' OR pIpUsuario = '' OR pMacAddress = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		IF pTipoOperacion NOT IN (1,2) THEN
			LET cCodRet = '00148';
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		IF pTipoOperacion = 1 AND EXISTS (SELECT id_area FROM bdicnweb:sw_gs_area_permisos where id_area = pIdArea) THEN
			LET cCodRet = '00004';
			RETURN cCodRet, iNoRegsProcesados;
		ELIF pTipoOperacion = 2 AND NOT EXISTS (SELECT id_area FROM bdicnweb:sw_gs_area_permisos where id_area = pIdArea) THEN
			LET cCodRet = '00001';
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		BEGIN WORK;
			SET ISOLATION TO DIRTY READ;
			FOREACH EXECUTE PROCEDURE bdicnweb:sp_split_cadena(pPermisosPlantilla, '|')
					INTO cCadenaValores
					
					LET iParams = 0;
					FOREACH EXECUTE PROCEDURE bdicnweb:sp_split_cadena(cCadenaValores, ',')
						INTO cCadena
						
						IF iParams = 0 THEN
							LET iIdSolicitud = cCadena::INTEGER;
							LET iParams = iParams + 1;
						ELIF iParams = 1 THEN
							LET bEsResponsable = DECODE(cCadena, '0', 'f', '1', 't', 'f');
							LET iParams = iParams + 1;
						ELIF iParams = 2 THEN
							LET bEsSolicitante = DECODE(cCadena, '0', 'f', '1', 't', 'f');
							EXIT FOREACH;
						END IF;
					END FOREACH;
					
					SET LOCK MODE TO WAIT 3;
					IF pTipoOperacion = 1 THEN -- INSERCIÃN DE LOS VALORES
						INSERT INTO bdicnweb:sw_gs_area_permisos(id_area, id_solicitud, ind_responsable, ind_solicitante, user_insert, ip_insert, mac_insert)
						VALUES (pIdArea, iIdSolicitud, bEsResponsable, bEsSolicitante, pUsuario, pIpUsuario, pMacAddress);
						
						LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
					ELIF pTipoOperacion = 2 THEN -- ACTUALIZACIÃN, QUE PUEDE INCLUIR LA INSERCIÃN DE UN REGISTRO
						UPDATE bdicnweb:sw_gs_area_permisos
							SET ind_responsable = bEsResponsable,
								ind_solicitante = bEsSolicitante,
								user_update = pUsuario,
								fecha_update = CURRENT,
								ip_update = pIpUsuario,
								mac_update = pMacAddress
						WHERE id_area = pIdArea
							AND id_solicitud = iIdSolicitud;
							
						IF DBINFO('sqlca.sqlerrd2')	= 0 THEN
							INSERT INTO bdicnweb:sw_gs_area_permisos(id_area, id_solicitud, ind_responsable, ind_solicitante, user_insert, ip_insert, mac_insert, user_update, ip_update, mac_update, fecha_update)
							VALUES (pIdArea, iIdSolicitud, bEsResponsable, bEsSolicitante, pUsuario, pIpUsuario, pMacAddress, pUsuario, pIpUsuario, pMacAddress, CURRENT);
						END IF;
						
						LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
					END IF;
					
			END FOREACH;
		COMMIT;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet, iNoRegsProcesados;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 02/05/2014',
'DESCRIPCION: Inserta/actualiza los registros de detalles de una plantilla de permisos por area para el gestor de solicitudes en SOCWEB',
'La cadena de entrada para la variable pPermisosPlantilla son: idSolicitud,esResponsable,esSolicitante|idSolicitud,esResponsable,esSolicitante|...|idSolicitud,esResponsable,esSolicitante',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_grabarsolicitudusuarioarea(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion SMALLINT, pIdAreaUsuario INTEGER, pPermisosUsuario CHAR(250), pIpUsuario CHAR(15), pMacAddress CHAR(12))
		RETURNING CHAR(5) AS codret,
				INTEGER AS registros_procesados;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCadenaValores CHAR(15);
	DEFINE cCadena CHAR(15);
	DEFINE iIdSolicitud INTEGER;
	DEFINE bEsResponsable BOOLEAN;
	DEFINE bEsSolicitante BOOLEAN;
	DEFINE iNoRegsProcesados INTEGER;
	DEFINE iParams SMALLINT;
	DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCadenaValores = '';
	LET cCadena = '';
	LET iIdSolicitud = 0;
	LET bEsResponsable = 'f';
	LET bEsSolicitante = 'f';
	LET iNoRegsProcesados = 0;
	LET iParams = 0;
	LET bInTransaction = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegsProcesados;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-691)
			ROLLBACK;
			LET cCodRet = '00284';
			
			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;
			
			RETURN cCodRet, iNoRegsProcesados;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_grabarsolicitudusuarioarea.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdAreaUsuario IS NULL OR pTipoOperacion IS NULL OR pPermisosUsuario = '' OR pIpUsuario = '' OR pMacAddress = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		IF pTipoOperacion NOT IN (1,2) THEN
			LET cCodRet = '00148';
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		IF pTipoOperacion = 1 AND EXISTS (SELECT id_area_usuario FROM bdicnweb:sw_gs_area_solicitudes where id_area_usuario = pIdAreaUsuario) THEN
			LET cCodRet = '00004';
			RETURN cCodRet, iNoRegsProcesados;
		ELIF pTipoOperacion = 2 AND NOT EXISTS (SELECT id_area_usuario FROM bdicnweb:sw_gs_area_solicitudes where id_area_usuario = pIdAreaUsuario) THEN
			LET cCodRet = '00001';
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		BEGIN WORK;
			SET ISOLATION TO DIRTY READ;
			FOREACH EXECUTE PROCEDURE bdicnweb:sp_split_cadena(pPermisosUsuario, '|')
					INTO cCadenaValores
					
					LET iParams = 0;
					FOREACH EXECUTE PROCEDURE bdicnweb:sp_split_cadena(cCadenaValores, ',')
						INTO cCadena
						
						IF iParams = 0 THEN
							LET iIdSolicitud = cCadena::INTEGER;
							LET iParams = iParams + 1;
						ELIF iParams = 1 THEN
							LET bEsResponsable = DECODE(cCadena, '0', 'f', '1', 't', 'f');
							LET iParams = iParams + 1;
						ELIF iParams = 2 THEN
							LET bEsSolicitante = DECODE(cCadena, '0', 'f', '1', 't', 'f');
							EXIT FOREACH;
						END IF;
					END FOREACH;
					
					SET LOCK MODE TO WAIT 3;
					IF pTipoOperacion = 1 THEN -- INSERCIÃN DE LOS VALORES
						INSERT INTO bdicnweb:sw_gs_area_solicitudes(id_area_usuario, id_solicitud, ind_responsable, ind_solicitante, user_insert, ip_insert, mac_insert)
						VALUES (pIdAreaUsuario, iIdSolicitud, bEsResponsable, bEsSolicitante, pUsuario, pIpUsuario, pMacAddress);
						
						LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
					ELIF pTipoOperacion = 2 THEN -- ACTUALIZACIÃN, QUE PUEDE INCLUIR LA INSERCIÃN DE UN REGISTRO
						UPDATE bdicnweb:sw_gs_area_solicitudes
							SET ind_responsable = bEsResponsable,
								ind_solicitante = bEsSolicitante,
								user_update = pUsuario,
								fecha_update = CURRENT,
								ip_update = pIpUsuario,
								mac_update = pMacAddress
						WHERE id_area_usuario = pIdAreaUsuario
							AND id_solicitud = iIdSolicitud;
							
						IF DBINFO('sqlca.sqlerrd2')	= 0 THEN
							INSERT INTO bdicnweb:sw_gs_area_solicitudes(id_area_usuario, id_solicitud, ind_responsable, ind_solicitante, user_insert, ip_insert, mac_insert, user_update, ip_update, mac_update, fecha_update)
							VALUES (pIdAreaUsuario, iIdSolicitud, bEsResponsable, bEsSolicitante, pUsuario, pIpUsuario, pMacAddress, pUsuario, pIpUsuario, pMacAddress, CURRENT);
						END IF;
						
						LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
					END IF;
					
			END FOREACH;
		COMMIT;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet, iNoRegsProcesados;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 15/05/2014',
'DESCRIPCION: Inserta/actualiza los registros de detalles de permisos de un usuario para el gestor de solicitudes en SOCWEB',
'La cadena de entrada para la variable pPermisosUsuario son: idSolicitud,esResponsable,esSolicitante|idSolicitud,esResponsable,esSolicitante|...|idSolicitud,esResponsable,esSolicitante',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_registrocomentariosolicitud(pUsuario CHAR(8),	pIdFuncion CHAR(10), pIdReg INTEGER, pComentario CHAR(200), pTipoGestor CHAR(1))
	RETURNING CHAR(5) AS codret,
				INTEGER AS idxReg;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE iIdx INTEGER;
	DEFINE iConsecutivo INTEGER;
	DEFINE iFolio BIGINT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET bInTransaction='f';
	LET iIdx = 0;
	LET iConsecutivo = 0;
	LET iFolio = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdx;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-691)
			ROLLBACK;
			LET cCodRet = '00284';
			
			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;
			
			RETURN cCodRet, iIdx;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_registrocomentariosolicitud.out';
		--TRACE ON;
		
		---VALIDACION DE DATOS REQUERIDOS 
		IF pUsuario = '' OR pIdFuncion = '' OR pIdReg IS NULL OR pTipoGestor = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdx;
		END IF;
		
		IF pTipoGestor NOT IN ('S','R') THEN
			LET cCodRet = '00148';
			RETURN cCodRet, iIdx;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdx;
		END IF;
		
		-- CALCULAMOS CONSECUTIVO
		IF((SELECT MAX(consecutivo) FROM bdicnweb:sw_gs_comentarios WHERE id_registro_solicitud = pIdReg)IS NULL) THEN
			LET iConsecutivo=1;
		ELSE 
			SELECT MAX(consecutivo)
			INTO iConsecutivo
			FROM bdicnweb:sw_gs_comentarios WHERE id_registro_solicitud = pIdReg;	
			LET iConsecutivo=iConsecutivo+1;
		END IF	
		
		-- OBTENEMOS FOLIO DEL REGISTRO
		SET ISOLATION TO DIRTY READ;
		SELECT folio_solicitud 
		INTO iFolio 
		FROM bdicnweb:sw_gs_registrosolicitud WHERE id_registro_solicitud = pIdReg;

		
		BEGIN WORK;

		SET LOCK MODE TO WAIT 3;
		INSERT INTO bdicnweb:sw_gs_comentarios(id_registro_solicitud,folio_solicitud, tipo_gestor, consecutivo, comentario, usuario) 
		VALUES(pIdReg,iFolio, DECODE(pTipoGestor,'R','RESPONSABLE','S','SOLICITANTE'), iConsecutivo, pComentario, pUsuario);
		
		IF DBINFO('sqlca.sqlerrd2')	= 0 THEN
			LET cCodRet = '00236';			ROLLBACK WORK;
			RETURN cCodRet, iIdx;
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 1 THEN
			LET iIdx = DBINFO('sqlca.sqlerrd1');
		END IF;
		
		COMMIT;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet, iIdx;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 02/06/2014',
'DESCRIPCION: Inserta comentario de la solicitud al gestor de operaciones en SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_totalregbusquedasolicitudes(pUsuario CHAR(8),pIdFuncion CHAR(10), pTipoGestor CHAR(1),pFechaDesde DATE, pFechaHasta DATE,
													  pTipoCta CHAR(2), pSolicitud INTEGER, pAreaResSol INTEGER, pUsuarioResSol CHAR(8), pStatus INTEGER,
													  pCliente CHAR(20),pCuenta CHAR(20),pIsArea CHAR(1))
	RETURNING CHAR(5) AS codret,
			  INTEGER AS total;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	DEFINE iArea INTEGER;
	
	DEFINE cCmd1 CHAR(5000);
	DEFINE cCmd2 CHAR(2500);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	
	LET iNoRegistros = 0;
	
	LET iArea = 0;
	
	LET cCmd1 = '';
	LET cCmd2 = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_totalregbusquedasolicitudes.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoGestor = '' OR pFechaDesde = '' OR pFechaHasta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		IF pTipoGestor NOT IN ('S','R') THEN
			LET cCodRet = '00148';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros;
		END IF;
				
		IF pTipoGestor = 'S' THEN
			--- CONSTRUCCCION DE CONDICIONES
			IF pIsArea = 't' THEN
				---VERIFICAMOS A QUE AREA PERTENECE EL USUARIO
				SET ISOLATION TO DIRTY READ;
				SELECT id_area
				INTO iArea
				FROM bdicnweb:sw_gs_area_usuario
				WHERE id_usuario = pUsuario;
				LET cCmd2="a.id_area_solicitante = "||iArea||" AND a.status = 't' AND (DATE(a.fecha_solicitud) BETWEEN '"||pFechaDesde||"' AND '"||pFechaHasta||"')";
			ELSE
				LET cCmd2="a.usuario_solicitante = "||pUsuario||" AND a.status = 't' AND (DATE(a.fecha_solicitud) BETWEEN '"||pFechaDesde||"' AND '"||pFechaHasta||"')";
			END IF;
			
			IF pTipoCta <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND c.id_sistema_cuenta = '"|| TRIM(pTipoCta) ||"'";
			END IF;
			
			IF pSolicitud IS NOT NULL THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_solicitud = "|| pSolicitud ||"";
			END IF;
			
			IF pAreaResSol IS NOT NULL THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_area_responsable = "|| pAreaResSol ||"";
			END IF;
			
			IF pUsuarioResSol <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.usuario_responsable = '"|| TRIM(pUsuarioResSol) ||"'";
			END IF;
			
			IF pStatus IS NOT NULL THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_status_solicitud = "|| pStatus ||"";
			END IF;
			
			IF pCliente <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.cliente = '"|| TRIM(pCliente) ||"'";
			END IF;
			
			IF pCuenta <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.cuenta = '"|| TRIM(pCuenta) ||"'";
			END IF;
			
			--- CONSULTA
			LET cCmd1="SELECT COUNT(*) ";
			LET cCmd1=""||TRIM(cCmd1)||" FROM ";
			LET cCmd1=""||TRIM(cCmd1)||" (SELECT a.id_registro_solicitud";
			LET cCmd1=""||TRIM(cCmd1)||"  FROM (((((bdicnweb:sw_gs_registrosolicitud a LEFT JOIN bdicnweb:sw_gs_catstatussolicitud b ON a.id_status_solicitud = b.id_status_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_solicitudes c ON a.id_solicitud=c.id_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_area d ON a.id_area_responsable=d.id_area)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_motivos_cancelacion e ON a.id_motivo_cancelacion=e.id_motivo_cancelacion)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:si_ejecut f ON f.ejecutivo=a.usuario_responsable)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:si_cliente g ON g.numcte=a.cliente";
			LET cCmd1=""||TRIM(cCmd1)||"  WHERE "||TRIM(cCmd2)||"";
			LET cCmd1=""||TRIM(cCmd1)||"  UNION ";
			LET cCmd1=""||TRIM(cCmd1)||"  SELECT a.id_registro_solicitud";
			LET cCmd1=""||TRIM(cCmd1)||"  FROM (((((bdicnweb:sw_gs_registrosolicitud_hist a LEFT JOIN bdicnweb:sw_gs_catstatussolicitud b ON a.id_status_solicitud = b.id_status_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_solicitudes c ON a.id_solicitud=c.id_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_area d ON a.id_area_responsable=d.id_area)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_motivos_cancelacion e ON a.id_motivo_cancelacion=e.id_motivo_cancelacion)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:si_ejecut f ON f.ejecutivo=a.usuario_responsable)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:si_cliente g ON g.numcte=a.cliente";
			LET cCmd1=""||TRIM(cCmd1)||"  WHERE "||TRIM(cCmd2)||")";
			
			PREPARE stmtId FROM TRIM(cCmd1);
			DECLARE selectQryCur CURSOR FOR stmtId;
			OPEN selectQryCur;
			
			FETCH selectQryCur INTO iNoRegistros;
			
			CLOSE selectQryCur;
			FREE selectQryCur;
			FREE stmtId;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,iNoRegistros;
			END IF;
			
			RETURN cCodRet,iNoRegistros;
				
		END IF;
		
		IF pTipoGestor = 'R' THEN
			--- CONSTRUCCCION DE CONDICIONES
			IF pIsArea = 't' THEN
				---VERIFICAMOS A QUE AREA PERTENECE EL USUARIO
				SET ISOLATION TO DIRTY READ;
				SELECT id_area
				INTO iArea
				FROM bdicnweb:sw_gs_area_usuario
				WHERE id_usuario = pUsuario;
				LET cCmd2="a.id_area_responsable = "||iArea||" AND a.status = 't' AND (DATE(a.fecha_solicitud) BETWEEN '"||pFechaDesde||"' AND '"||pFechaHasta||"')";
			ELSE
				LET cCmd2="a.usuario_responsable = "||pUsuario||" AND a.status = 't' AND (DATE(a.fecha_solicitud) BETWEEN '"||pFechaDesde||"' AND '"||pFechaHasta||"')";
			END IF;
			
			IF pTipoCta <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND c.id_sistema_cuenta = '"|| TRIM(pTipoCta) ||"'";
			END IF;
			
			IF pSolicitud IS NOT NULL THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_solicitud = "|| pSolicitud ||"";
			END IF;
			
			IF pAreaResSol IS NOT NULL THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_area_solicitante = "|| pAreaResSol ||"";
			END IF;
			
			IF pUsuarioResSol <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.usuario_solicitante = '"|| TRIM(pUsuarioResSol) ||"'";
			END IF;
			
			IF pStatus IS NOT NULL THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_status_solicitud = "|| pStatus ||"";
			END IF;
			
			IF pCliente <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.cliente = '"|| TRIM(pCliente) ||"'";
			END IF;
			
			IF pCuenta <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.cuenta = '"|| TRIM(pCuenta) ||"'";
			END IF;
			
			--- CONSULTA
			LET cCmd1="SELECT COUNT(*) ";
			LET cCmd1=""||TRIM(cCmd1)||" FROM ";
			LET cCmd1=""||TRIM(cCmd1)||" (SELECT a.id_registro_solicitud";
			LET cCmd1=""||TRIM(cCmd1)||"  FROM (((((bdicnweb:sw_gs_registrosolicitud a LEFT JOIN bdicnweb:sw_gs_catstatussolicitud b ON a.id_status_solicitud = b.id_status_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_solicitudes c ON a.id_solicitud=c.id_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_area d ON a.id_area_solicitante=d.id_area)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_motivos_cancelacion e ON a.id_motivo_cancelacion=e.id_motivo_cancelacion)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:si_ejecut f ON f.ejecutivo=a.usuario_solicitante)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:si_cliente g ON g.numcte=a.cliente";
			LET cCmd1=""||TRIM(cCmd1)||"  WHERE "||TRIM(cCmd2)||"";
			LET cCmd1=""||TRIM(cCmd1)||"  UNION ";
			LET cCmd1=""||TRIM(cCmd1)||"  SELECT a.id_registro_solicitud";
			LET cCmd1=""||TRIM(cCmd1)||"  FROM (((((bdicnweb:sw_gs_registrosolicitud_hist a LEFT JOIN bdicnweb:sw_gs_catstatussolicitud b ON a.id_status_solicitud = b.id_status_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_solicitudes c ON a.id_solicitud=c.id_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_area d ON a.id_area_solicitante=d.id_area)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_motivos_cancelacion e ON a.id_motivo_cancelacion=e.id_motivo_cancelacion)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:si_ejecut f ON f.ejecutivo=a.usuario_solicitante)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:si_cliente g ON g.numcte=a.cliente";
			LET cCmd1=""||TRIM(cCmd1)||"  WHERE "||TRIM(cCmd2)||")";
			
			PREPARE stmtId FROM TRIM(cCmd1);
			DECLARE selectQryCur CURSOR FOR stmtId;
			OPEN selectQryCur;
			
			FETCH selectQryCur INTO iNoRegistros;
			
			CLOSE selectQryCur;
			FREE selectQryCur;
			FREE stmtId;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,iNoRegistros;
			END IF;
			
			RETURN cCodRet,iNoRegistros;
				
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 10/06/2014',
'DESCRIPCION: Obtiene el total de registros de busqueda de solicitudes para gestor de operaciones en SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_abono_ref(pUsuario     char(10),
                                         pIdFuncion   char(10),
                                         pTransacc    CHAR(4),
                                         pCuenta      CHAR(20),
                                         pDocto       INTEGER,
                                         pMto_tot     MONEY(14,2),
                                         pReferencia  CHAR(40))
        RETURNING CHAR(5) as codret,
                  CHAR(16) as Folio_usu;

DEFINE cCodRet CHAR(5);

DEFINE iSqlErr INT;

DEFINE cEmpresa       CHAR(3);
DEFINE cSucursal      CHAR(4);
DEFINE cUsuario       CHAR(8);
DEFINE cTransuc       CHAR(4);
DEFINE cFolio_suc     CHAR(16);
DEFINE mMto_firme     MONEY(14,2);
DEFINE mMto_sbc       MONEY(14,2);
DEFINE mMto_rem       MONEY(14,2);
DEFINE sDias_ret      SMALLINT;
DEFINE cDivisa        CHAR(2);
DEFINE cNum_tarjeta   CHAR(16);
DEFINE cUsuautoriza   CHAR(8);

DEFINE dHora          DATETIME HOUR TO SECOND;
DEFINE cHora          CHAR(6);

LET cCodRet = '00000';
LET iSqlErr = 0;

LET cEmpresa = '001';
LET cTransuc = "0000";
LET cFolio_suc = pUsuario;

LET mMto_firme = pMto_tot;
LET mMto_sbc = 0;
LET mMto_rem = 0;
LET sDias_ret = 0;
LET cDivisa = "01";
LET cNum_tarjeta = "";
LET cUsuautoriza = "";

LET cHora = CAST(SUBSTR(CURRENT,12,2) AS CHAR(2)) ||
            CAST(SUBSTR(CURRENT,15,2) AS CHAR(2)) ||
            CAST(SUBSTR(CURRENT,18,2) AS CHAR(2));
LET cFolio_suc = TRIM(cFolio_suc) || cHora;

SET ISOLATION TO DIRTY READ;

BEGIN

        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cFolio_suc;
                END IF;
        END EXCEPTION;

        IF  pDocto = ''
        THEN
                LET pDocto = 0;
        END IF;
        IF  pUsuario = ''
         OR pIdFuncion = ''
         OR ptransacc = ''
         OR pCuenta = ''
---------OR pDocto = ''
         OR pMto_tot = 0
---------OR pReferencia = ''
        THEN
                LET cCodRet = '00003';
                RETURN cCodRet, cFolio_suc;
        END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario,
                                                                        pIdFuncion)
                INTO cCodRet;
        IF cCodRet <> '00000' THEN
                RETURN cCodRet, cFolio_suc;
        END IF;

	SET ISOLATION TO DIRTY READ;
        SELECT sucursal
          INTO cSucursal
          FROM bdinteg:"informix".si_ejecut
         WHERE ejecutivo = pUsuario;

        SELECT divisa
          INTO cDivisa
          FROM bdicheq:"informix".sc_maechq mc, bdicheq:"informix".sc_producto pr
         WHERE mc.empresa = cEmpresa
           AND cuenta = pCuenta
           AND mc.empresa = pr.empresa
           AND mc.producto = pr.producto;

        EXECUTE PROCEDURE bdicheq:"informix".abono_ref(cEmpresa,
                                                        cSucursal,
                                                        pUsuario,
                                                        pTransacc,
                                                        cTransuc,
                                                        cFolio_suc,
                                                        pCuenta,
                                                        pDocto,
                                                        pMto_tot,
                                                        mMto_firme,
                                                        mMto_sbc,
                                                        mMto_rem,
                                                        sDias_ret,
                                                        cDivisa,
                                                        pReferencia,
                                                        cNum_tarjeta,
                                                        cUsuautoriza)
                INTO cCodRet;

        IF cCodRet = '000' THEN
                LET cCodRet = '00000';
        END IF;
        IF cCodRet = '110' THEN
                LET cCodRet = '00003';
        END IF;
        IF cCodRet = '301' THEN
                LET cCodRet = '00389'; --  La cuenta esta bloqueada no permite realizar abonos. Favor de verificar
        END IF;

        RETURN cCodRet, cFolio_suc;

END;

END PROCEDURE
DOCUMENT 'MODIFICO: Rodolfo Conde Flores',
'FECHA: 13/10/2014',
'DESCRIPCION: Se anexa mapeo de codigos de retorno para la aplicaciÃ³n SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cargo_ref(pUsuario     char(10),
                                         pIdFuncion   char(10),
                                         pTransacc    CHAR(4),
                                         pCuenta      CHAR(20),
                                         pCheque      INTEGER,
                                         pMto_tot     MONEY(14,2),
                                         pReferencia  CHAR(40))
        RETURNING CHAR(5) as codret,
                  CHAR(16) as Folio_usu;

DEFINE cCodRet CHAR(5);

DEFINE iSqlErr INT;

DEFINE cEmpresa       CHAR(3);
DEFINE cSucursal      CHAR(4);
DEFINE cUsuario       CHAR(8);
DEFINE cTransuc       CHAR(4);
DEFINE cFolio_suc     CHAR(16);
DEFINE mMto_firme     MONEY(14,2);
DEFINE mMto_sbc       MONEY(14,2);
DEFINE mMto_rem       MONEY(14,2);
DEFINE sDias_ret      SMALLINT;
DEFINE cDivisa        CHAR(2);
DEFINE cNum_tarjeta   CHAR(16);
DEFINE cUsuautoriza   CHAR(8);

DEFINE dHora          DATETIME HOUR TO SECOND;
DEFINE cHora          CHAR(6);

DEFINE vTranret         CHAR(4);
DEFINE vFechoy          DATE;
DEFINE vSdodisp         MONEY(14,2);
DEFINE vMontoret        MONEY(14,2);

LET vTranret = "";
LET vFechoy = TODAY;
LET vSdodisp = 0;
LET vMontoret = 0;

LET cCodRet = '00000';
LET iSqlErr = 0;

LET cEmpresa = '001';
LET cTransuc = "0000";
LET cFolio_suc = pUsuario;

LET mMto_firme = pMto_tot;
LET mMto_sbc = 0;
LET mMto_rem = 0;
LET sDias_ret = 0;
LET cDivisa = "01";
LET cNum_tarjeta = "";
LET cUsuautoriza = "";

LET cHora = CAST(SUBSTR(CURRENT,12,2) AS CHAR(2)) ||
            CAST(SUBSTR(CURRENT,15,2) AS CHAR(2)) ||
            CAST(SUBSTR(CURRENT,18,2) AS CHAR(2));
LET cFolio_suc = TRIM(cFolio_suc) || cHora;

SET ISOLATION TO DIRTY READ;

BEGIN

        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cFolio_suc;
                END IF;
        END EXCEPTION;

        IF  pCheque = ''
        THEN
                LET pCheque = 0;
        END IF;
        IF  pUsuario = ''
         OR pIdFuncion = ''
         OR ptransacc = ''
         OR pCuenta = ''
---------OR pCheque = ''
         OR pMto_tot = 0
---------OR pReferencia = ''
        THEN
                LET cCodRet = '00003';
                RETURN cCodRet, cFolio_suc;
        END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario,
                                                                        pIdFuncion)
                INTO cCodRet;
        IF cCodRet <> '00000' THEN
                RETURN cCodRet, cFolio_suc;
        END IF;

        SELECT sucursal
          INTO cSucursal
          FROM bdinteg:"informix".si_ejecut
         WHERE ejecutivo = pUsuario;

        SELECT divisa
          INTO cDivisa
          FROM bdicheq:"informix".sc_maechq mc, bdicheq:"informix".sc_producto pr
         WHERE mc.empresa = cEmpresa
           AND cuenta = pCuenta
           AND mc.empresa = pr.empresa
           AND mc.producto = pr.producto;

        EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(cEmpresa,
                                                        cSucursal,
                                                        pUsuario,
                                                        pTransacc,
                                                        cTransuc,
                                                        cFolio_suc,
                                                        pCuenta,
                                                        pCheque,
                                                        pMto_tot,
                                                        cDivisa,
                                                        pReferencia,
                                                        cNum_tarjeta,
                                                        cUsuautoriza)
                INTO    cCodRet,
                        vTranret,
                        vFechoy,
                        vSdodisp,
                        vMontoret;

        IF cCodRet = '000' THEN
                LET cCodRet = '00000';
        END IF;
        IF cCodRet = '110' THEN
                LET cCodRet = '00003';
        END IF;
		IF cCodRet = '200' THEN
                LET cCodRet = '00390'; -- LA CUENTA NO PERMITE REALIZAR CARGOS. FAVOR DE VERIFICAR
        END IF;
		IF cCodRet = '400' THEN
                LET cCodRet = '00391'; -- LA CUENTA TIENE FONDOS INSUFICIENTES
        END IF;
		IF cCodRet = '300' THEN
                LET cCodRet = '00392'; -- LA CUENTA ESTA BLOQUEADA NO PERMITE REALIZAR CARGOS. FAVOR DE VERIFICAR
        END IF;

        RETURN cCodRet, cFolio_suc;

END;

END PROCEDURE
DOCUMENT 'MODIFICO: Rodolfo Conde Flores',
'FECHA: 13/10/2014',
'DESCRIPCION: Se anexa mapeo de codigos de retorno para la aplicaciÃ³n SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_ro_borraimagenes(pUsuarioC CHAR(8),
                                                                                pIdFuncionC CHAR(10), 
                                                                                pIdOficio INT,
                                                                                pIdBusqueda INT,
                                                                                pIdCte INT, 
                                                                                pNumCliente CHAR(20), 
                                                                                pTipoCuenta CHAR(2),
                                                                                pNumCuenta CHAR(20))
        RETURNING CHAR(5) AS codret,
                INT AS regs_borrados
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INT;
        DEFINE iNoRegistros INT;
        DEFINE cStatus CHAR(1);
        DEFINE cStatus2 CHAR(1);
		DEFINE cNumCtaAux CHAR(20);
		DEFINE iNoRegistrosAux INT;
		
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iNoRegistros = -1;
		LET cNumCtaAux = '';
		LET iNoRegistrosAux = -1;
		
        BEGIN
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                LET cCodRet = iSqlErr;
                                RETURN cCodRet, iNoRegistros;
                        END IF;
                END EXCEPTION;
				
				--SET DEBUG FILE TO '/tmp/mfinis/sp_sw_ro_borraimagenes.sql';
				--TRACE ON;
				
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuarioC, pIdFuncionC) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iNoRegistros;
                END IF;
                --VALIDACION DE CAMPOS REQUERIDOS
                IF pUsuarioC = ''OR 
                        pIdFuncionC = ''OR 
                        pIdOficio = ''OR 
                        pIdBusqueda = ''OR 
                        pIdCte = ''OR 
                        pTipoCuenta = ''OR 
                        pNumCliente = ''OR 
                        pNumCuenta = '' 
                        then LET cCodRet = '00003';
                                RETURN cCodRet, iNoRegistros;
                END IF;
				
                IF pTipoCuenta NOT IN('01', '03', '06', '00') THEN
                        LET cCodRet = '00048'; -- El tipo de sistema busqueda es incorrecto
                        RETURN cCodRet, iNoRegistros;
                END IF;
				
				DELETE FROM sw_ro_cteexp
				WHERE id_oficio = pIdOficio
					AND id_busqueda = pIdBusqueda
					AND id_resulcte = pIdCte
					AND tipo_cuenta = pTipoCuenta
					AND numcte = pNumCliente
					AND cuenta = pNumCuenta;
						
                IF pNumCuenta = '99999999999' THEN
					UPDATE sw_ro_resulcte SET ind_expdig = '0' 
					WHERE id_resulcte = pIdCte AND id_busqueda = pIdBusqueda AND id_oficio = pIdOficio;
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(certifica_imagenes) > 0 THEN '1' ELSE '0' end
					INTO cStatus
					FROM sw_ro_ctecta
					WHERE id_oficio = pIdOficio 
							AND id_busqueda = pIdBusqueda 
							AND id_resulcte = pIdCte 
							AND certifica_imagenes = '1';
				   
					-- Se actualiza en estatus en la tabla de clientes
					UPDATE sw_ro_resulcte SET certifica_imagenes = cStatus
					WHERE id_resulcte = pIdCte 
							AND id_busqueda = pIdBusqueda 
							AND id_oficio = pIdOficio;              
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(ind_expdig) > 0 THEN '1' ELSE '0' end
					INTO cStatus2
					FROM sw_ro_resulcte
					WHERE id_oficio = pIdOficio 
							AND ind_expdig = '1';
					LET cStatus = cStatus + cStatus2;
					IF cStatus > 0 THEN
							LET cStatus = '1';
					END IF;
					
					-- ActualizaciÃ³n en maeoficios
					UPDATE sw_ro_maeoficios
					SET certifica_imagenes = cStatus
					WHERE id_oficio = pIdOficio;
                ELSE
					-- Se actualiza en estatus en la tabla de cuentas
					UPDATE sw_ro_ctecta SET certifica_imagenes = '0' 
					WHERE id_resulcte = pIdCte AND id_busqueda = pIdBusqueda AND id_oficio = pIdOficio AND cuenta = pNumCuenta;
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(certifica_imagenes) > 0 THEN '1' ELSE '0' end
					INTO cStatus
					FROM sw_ro_ctecta
					WHERE id_oficio = pIdOficio AND id_busqueda = pIdBusqueda AND id_resulcte = pIdCte AND certifica_imagenes = '1';
					
					-- Se actualiza en estatus en la tabla de clientes
					UPDATE sw_ro_resulcte SET certifica_imagenes = cStatus
					WHERE id_resulcte = pIdCte AND id_busqueda = pIdBusqueda AND id_oficio = pIdOficio;             
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(certifica_imagenes) > 0 THEN '1' ELSE '0' END 
					INTO cStatus
					FROM sw_ro_resulcte
					WHERE id_oficio = pIdOficio AND certifica_imagenes = '1';
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(ind_expdig) > 0 THEN '1' ELSE '0' end
					INTO cStatus2
					FROM sw_ro_resulcte
					WHERE id_oficio = pIdOficio AND ind_expdig = '1';
					LET cStatus = cStatus + cStatus2;
					IF cStatus > 0 THEN
							LET cStatus = '1';
					END IF;
					
					-- ActualizaciÃ³n en maeoficios
					UPDATE sw_ro_maeoficios
					SET certifica_imagenes = cStatus
					WHERE id_oficio = pIdOficio;
                END IF;
                LET iNoRegistros = dbinfo('sqlca.sqlerrd2');
                RETURN cCodRet, iNoRegistros;
        END
END PROCEDURE;