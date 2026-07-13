CREATE PROCEDURE "informix".sp_cp_rep_prod_upgrade2(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaIni DATE, pFechaFin DATE, pTipo CHAR(1), pStatus CHAR(1), pArchivo CHAR(50), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,		
		CHAR(20) AS num_credito,
		CHAR(20) AS num_tarjeta,		  
        CHAR(10) AS tipo_tarjeta,
		CHAR(100) AS nombre,
		DATE AS fecha,
        CHAR(15) AS resultado,
		CHAR(3) AS marcaje,
		CHAR(2) AS sol_plastico,
		CHAR(100) AS mensaje_error;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	DEFINE cNombreEmbozado CHAR(100);
	DEFINE cNumCredito   CHAR(20);
	DEFINE cTipoTarjeta  CHAR(10);
	DEFINE cMiembro       CHAR(2);
	DEFINE dFecha		  DATE;
	DEFINE cResultado     CHAR(15);
	DEFINE cDescripcion   CHAR(100);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cMarcaje CHAR(3);
	DEFINE cSolPlastico CHAR(2);
	DEFINE cMensajeError CHAR(100);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;
	LET cNombreEmbozado = '';
	LET cNumCredito = '';
	LET cTipoTarjeta = '';
	LET cMiembro = '';
	LET dFecha = date(1);
	LET cResultado = '';
	LET cDescripcion = '';
	LET cNumTarjeta = '';
	LET cMarcaje = '';
	LET cSolPlastico = '';
	LET cMensajeError = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_rep_prod_upgrade2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaIni = '' OR pFechaFin = '' OR pTipo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".sp_rep_prod_upgrade2(cEmpresa, pFechaIni, pFechaFin, pTipo, pStatus, pArchivo, pRegistros, pRecuperacion)
			--INTO cCodRetSp,cDescripcion,cNombreEmbozado,cNumCredito,cTipoTarjeta,cMiembro,dFecha,cResultado
			INTO cCodRetSp,cDescripcion,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError		  
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP:bdicred:sp_rep_prod_upgrade2";		
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '00973';
				RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError;
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			--RETURN cCodRet, NVL(UPPER(cNombreEmbozado),''), NVL(UPPER(cNumCredito),''), NVL(UPPER(cTipoTarjeta),''), NVL(UPPER(cMiembro),''), NVL(dFecha,''), NVL(UPPER(cResultado),'') WITH RESUME;
			RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,NVL(UPPER(cNombreEmbozado),''),dFecha,NVL(UPPER(cResultado),''),cMarcaje,cSolPlastico,NVL(UPPER(cMensajeError),'') WITH RESUME;
			
		END FOREACH;
		
		IF NVL(iRecuperacion,0) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError;
		END IF;
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 30/03/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO PRODUCTO MANUAL',
'DESCRIPCION: ESTE PROCEDIMIENTO EJECUTA UN SP CLONADO QUE LLENA EL COMBO PARA LA PANTALLA DE REPORTES Y LLENA EL GRID DE ESTA MISMA',
'AUTOR: L. Montserrat León Amador',
'FECHA: 03/05/2019',
'DESCRIPCION: Se modifica spl para agregar nuevas reglas de negocio RQM 10 682-4.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_updatedatoscuentastdc(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(12), pNombreArchivo CHAR(35))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS bandera_det_error; 
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDesCodRetSp CHAR(100);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cRenglon CHAR(400);
	DEFINE iLinea INTEGER;
	DEFINE cCampo CHAR(35);
	DEFINE cDesMensajeError CHAR(120);
	DEFINE iContador INTEGER;
	DEFINE cBanDetError CHAR(1);
	
	DEFINE cNumCredito_Sol CHAR(20);
	
	DEFINE cNumCredito_Up CHAR(20);
	DEFINE cNumTarjeta_Up CHAR(20);
	DEFINE cMaster_Up CHAR(1);
	DEFINE cDomicilio_Up CHAR(1);
	DEFINE cSucursal_Up CHAR(4);
	DEFINE cProdDestino_Up CHAR(4);
	DEFINE cDescProdDestino_Up CHAR(40);
	DEFINE cNumCredito_sp CHAR(20);
	DEFINE cStatusCred_sp CHAR(2);		  
	DEFINE cTipoTarjeta_sp CHAR(3);
	DEFINE cNomCliente_sp CHAR(30);
	DEFINE cNomEmbozado_sp CHAR(21);
	DEFINE cNumTarjeta_sp CHAR(20);
	DEFINE cNumCliente_sp CHAR(20);	
	DEFINE cNumTarjeta CHAR(20);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDesCodRetSp = '';
	LET iSqlErr = 0;
	LET cIdCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cRenglon = '';
	LET iLinea = 0;
	LET cCampo = '';
	LET cDesMensajeError = '';
	LET iContador = 0;
	LET cBanDetError = 'f';
	
	LET cNumCredito_Sol = '';
	
	LET cNumCredito_Up = '';
	LET cNumTarjeta_Up = '';
	LET cMaster_Up = '';
	LET cDomicilio_Up = '';
	LET cSucursal_Up = '';
	LET cProdDestino_Up = '';
	LET cDescProdDestino_Up = '';
	
	LET cNumCredito_sp = '';
	LET cStatusCred_sp = '';		  
	LET cTipoTarjeta_sp = '';
	LET cNomCliente_sp = '';
	LET cNomEmbozado_sp = '';
	LET cNumTarjeta_sp = '';
	LET cNumCliente_sp = '';	
	LET cNumTarjeta = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
			    
				SET LOCK MODE TO WAIT 3;
				UPDATE bdicnweb:"informix".sw_cp_statuslecturadatosctastdc
				SET  status = 'E', error_proceso = 'S', error = TRIM(cCodRet) 
				WHERE usuario = TRIM(pUsuario) AND tipo_proceso = 'LECTURA' AND nombre_archivo = TRIM(pNombreArchivo);
				
				RETURN cCodRet,cBanDetError; 
			END IF;
		END EXCEPTION;			
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_updatedatoscuentastdc.out';
		--TRACE ON;
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;		
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pDireccionMac = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';

			UPDATE bdicnweb:"informix".sw_cp_statuslecturadatosctastdc
			SET  status = 'E', error_proceso = 'S', error = TRIM(cCodRet) 
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
			
			RETURN cCodRet,cBanDetError; 
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN

			UPDATE bdicnweb:"informix".sw_cp_statuslecturadatosctastdc
			SET  status = 'E', error_proceso = 'S', error = TRIM(cCodRet) 
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
			
			RETURN cCodRet,cBanDetError; 
		END IF;
		
		-- SE LIMPIA TABLA POR USUARIO Y PROCESO
		DELETE FROM bdicnweb:"informix".sw_cp_statuslecturadatosctastdc
		WHERE usuario = TRIM(pUsuario) AND tipo_proceso = 'LECTURA' AND nombre_archivo = TRIM(pNombreArchivo);
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO bdicnweb:"informix".sw_cp_statuslecturadatosctastdc(usuario,nombre_archivo,status,bandera_det_error,error_proceso,tipo_proceso,error)
		VALUES(pUsuario,TRIM(pNombreArchivo),'I','','','LECTURA','');

		-- LIMPIA TABLA PRINCIPAL
		DELETE FROM bdicnweb:"informix".sw_cp_datosctastdc WHERE usuario = pUsuario AND direccion_mac = pDireccionMac;
		-- AAME 12062019 RQM 10 682-4 LIMPIA TABLA DE CONTEO DE REGISTROS EXITOSOS Y NO EXITOSOS
		DELETE FROM bdicnweb:"informix".sw_cred_cambioproducto WHERE us_insert = pUsuario AND fecha_insert = DATE(CURRENT);
		   
		
		FOREACH
		
			SELECT DISTINCT num_credito INTO cNumCredito_Sol
			FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdc
			WHERE tipo_tarjeta = 'T' AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac
			
			FOREACH
				/* AAME 24062019 RQM 10 682-4 SE QUITA INSERT- SELECT A PETICION DE BD
				INSERT INTO bdicnweb:"informix".sw_cp_datosctastdc(num_tarjeta,status_cred,num_credito,tipo_tarjeta,nombre_cliente,
				nombre_embozado,master,domicilio_envio,sucursal,num_cliente,prod_destino,desc_prod_destino,origen_reg,usuario,
				nombre_archivo,direccion_mac,fecha_insert)
				--SELECT cNumTarjeta_sp,cStatusCred_sp,cNumCredito_sp,cTipoTarjeta_sp,cNomCliente_sp,
				SELECT cNumTarjeta_sp,cStatusCred_sp,cNumCredito_Sol,cTipoTarjeta_sp,cNomCliente_sp,
				cNomEmbozado_sp,'','','',cNumCliente_sp,'','','B',pUsuario,pNombreArchivo,pDireccionMac,DATE(CURRENT)
				FROM TABLE (PROCEDURE bdicred:"informix".sp_mostrar_grid_upgrade('001',cNumCredito_Sol,'0',''))
				AS sp_mostrar_grid_upgrade(cCodRetSp, cNumCredito_sp, cStatusCred_sp, cTipoTarjeta_sp, cNomCliente_sp, cNomEmbozado_sp, cNumTarjeta_sp, cNumCliente_sp);*/
				
				EXECUTE PROCEDURE bdicred:"informix".sp_mostrar_grid_upgrade('001',cNumCredito_Sol,'0','')
				INTO cCodRetSp, cNumCredito_sp, cStatusCred_sp, cTipoTarjeta_sp, cNomCliente_sp, cNomEmbozado_sp, cNumTarjeta_sp, cNumCliente_sp

				INSERT INTO bdicnweb:"informix".sw_cp_datosctastdc(num_tarjeta,status_cred,num_credito,tipo_tarjeta,nombre_cliente,
				nombre_embozado,master,domicilio_envio,sucursal,num_cliente,prod_destino,desc_prod_destino,origen_reg,usuario,
				nombre_archivo,direccion_mac,fecha_insert)
				VALUES(cNumTarjeta_sp, cStatusCred_sp, cNumCredito_Sol, cTipoTarjeta_sp, cNomCliente_sp, cNomEmbozado_sp,'','','',cNumCliente_sp,'','','B',pUsuario,pNombreArchivo,pDireccionMac,DATE(CURRENT));
			
			END FOREACH;
						
		END FOREACH;
		
		FOREACH
			SELECT num_credito,num_tarjeta,aceptacion,domicilio_envio,sucursal,prod_destino 
			INTO cNumCredito_Up,cNumTarjeta_Up,cMaster_Up,cDomicilio_Up,cSucursal_Up,cProdDestino_Up 
			FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdc 
			WHERE usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac
			ORDER BY id_registro ASC
			
			SELECT num_tarjeta 
			INTO cNumTarjeta
			FROM bdicnweb:"informix".sw_cp_datosctastdc 
			WHERE num_credito = cNumCredito_Up AND num_tarjeta = cNumTarjeta_Up
			AND usuario = pUsuario AND direccion_mac = pDireccionMac AND nombre_archivo = pNombreArchivo;
			--AAME 25062019 Se quita if exists a peticion de BD.
			IF cNumTarjeta <> '' THEN
			
				SELECT nombre_prod
				INTO cDescProdDestino_Up
				FROM bdicred:"informix".sd_definicion WHERE empresa = '001' AND num_producto = cProdDestino_Up;
	
				UPDATE bdicnweb:"informix".sw_cp_datosctastdc
				SET master = cMaster_Up, domicilio_envio = cDomicilio_Up, sucursal = cSucursal_Up, 
				prod_destino = cProdDestino_Up, desc_prod_destino = cDescProdDestino_Up, origen_reg = 'A'
				WHERE num_credito = cNumCredito_Up AND num_tarjeta = cNumTarjeta_Up
				AND usuario = pUsuario AND direccion_mac = pDireccionMac AND nombre_archivo = pNombreArchivo;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
					LET cBanDetError = 't';
					LET cCodRet = '00283';
					
					UPDATE bdicnweb:"informix".sw_cp_statuslecturadatosctastdc
					SET  status = 'E', error_proceso = 'S', error = cCodRet
					WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
					
					RETURN cCodRet,cBanDetError;
				END IF;	
	
			--ELSE
			
			END IF;
		END FOREACH;
		
		LET cBanDetError = TRIM(UPPER(cBanDetError));
		UPDATE bdicnweb:"informix".sw_cp_statuslecturadatosctastdc
		SET status = 'T', error_proceso = 'N', bandera_det_error = cBanDetError
		WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
		
		RETURN cCodRet,cBanDetError; 
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/04/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÓN MASIVA', 
'DESCRIPCION: SPL encargado de consultar y agregar el detalle de todas las tarjetas adicionales que tienen las cuentas titulares',
'y que no se encontraron en el archivo de carga.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 23/05/2019',
'DESCRIPCION: Se modifica spl para asegurar el número de credito en la tabla sw_cp_datosctastdc de cada registro (cNumCredito_Sol).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_verificastatusarchivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(35))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(1) AS bandera_det_error,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,
		INTEGER AS total,
		INTEGER AS procesados,
		INTEGER AS no_procesados;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cBanDetError CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iTotal INTEGER;
	DEFINE iProcesados INTEGER;
	DEFINE iNoProcesados INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cBanDetError = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iTotal = 0;
	LET iProcesados = 0;
	LET iNoProcesados = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError,iTotal,iProcesados,iNoProcesados;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_verificastatusarchivo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError,iTotal,iProcesados,iNoProcesados;	
		END IF;		
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError,iTotal,iProcesados,iNoProcesados;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status,bandera_det_error,error_proceso,error,total_registros,total_procesados,total_noprocesados
		INTO cStatus,cBanDetError,cErrorProceso,cError,iTotal,iProcesados,iNoProcesados
		FROM bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
		WHERE usuario = TRIM(pUsuario) AND nombre_archivo = TRIM(pNombreArchivo);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			RETURN cCodRet,'I','','','',0,0,0;			
		ELSE 			
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError,iTotal,iProcesados,iNoProcesados;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 24/04/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÓN MASIVA', 
'DESCRIPCION: SPL encargado de hacer la validación inicio/fin para el proceso de lectura de archivos.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 30/04/2019',
'DESCRIPCION: Se modifica spl para agregar nuevas reglas de negocio RQM 10 682-4.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_usuario_movil_ws(pEjecutivoAlta CHAR(8), pPassword  CHAR(20), pImei CHAR(20),pImeiAnt CHAR(20),
                                                                                        pActivo CHAR(1), pNombre CHAR(60), pCentro_costos CHAR(8), pSucursal CHAR(4),
                                                                                        pNo_telefono CHAR(10), pGenerico1 CHAR(20), pGenerico2 CHAR(30), 
                                                                                        pGenerico3 CHAR(40), ptipoOperacion INTEGER)
                RETURNING CHAR(5) AS codret,INTEGER AS iNoRegistros;
                
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iCodRetSp INTEGER;
        DEFINE iNoRegistros INTEGER;
        DEFINE bExisteUsuario BOOLEAN;
		DEFINE inoImei INTEGER;
		DEFINE bInTransaction BOOLEAN;
		DEFINE pUsuario CHAR(8);
		DEFINE vEjecutivo CHAR(8);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iCodRetSp = 0;
        LET iNoRegistros = 0;
        LET bExisteUsuario = 'f';
        LET inoImei = 0;
		LET bInTransaction = 'f';
		LET pUsuario = 'admonusr';
		LET vEjecutivo = '';
		
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, iNoRegistros;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/informix/LIP/sp_usuario_movil_ws.out';
                --TRACE ON;
        
				IF pPassword = '' OR   pImei = '' OR pActivo= '' OR pNombre = '' OR
                   pSucursal = '' OR pNo_telefono = '' OR ptipoOperacion IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, iNoRegistros;
                END IF;
		
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
		
                IF ptipoOperacion = 1 THEN
					-- Se valida que el ejecutivo no exista en la tabla
					
					SELECT ejecutivo
					INTO vEjecutivo
					FROM bdinteg:"informix".si_usuario_movil
					WHERE  ejecutivo = pEjecutivoAlta
					AND imei = pImei;
					
					IF (vEjecutivo IS NOT NULL AND vEjecutivo <> '')THEN
						LET cCodRet = '00479';
					ELSE	
						INSERT INTO bdinteg:"informix".si_usuario_movil (ejecutivo, password, imei, activo, nombre,centro_costos,
									no_telefono, generico1, generico2, generico3, fecha_insert,	user_insert, fecha_baja, user_baja, sucursal) 
						VALUES (pEjecutivoAlta, pPassword, pImei, pActivo, pNombre, pCentro_costos, pNo_telefono, pGenerico1,
									pGenerico2, pGenerico3, CURRENT, pUsuario, NULL, NULL,pSucursal);
																					
								LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
								IF iNoRegistros = 0 THEN -- 
									LET cCodRet = '00282';
								END IF;
                                                        
					END IF;
					RETURN cCodRet, iNoRegistros;
                
                END IF;

                IF  ptipoOperacion = 2 THEN 		
					IF pImei = pImeiAnt THEN
						UPDATE bdinteg:"informix".si_usuario_movil SET
                        password= pPassword,
                        imei= pImei,
                        activo= pActivo,
                        nombre = pNombre,
                        centro_costos=pCentro_costos,
                        no_telefono= pNo_telefono, 
                        generico1= pGenerico1, 
                        generico2= pGenerico2, 
                        generico3= pGenerico3, 
                        sucursal=pSucursal
                        WHERE ejecutivo=pEjecutivoAlta
						AND imei= pImeiAnt;
						
						IF(pActivo = '0') THEN
							UPDATE bdinteg:"informix".si_usuario_movil SET
							fecha_baja= CURRENT, 
							user_baja= pUsuario
							WHERE ejecutivo=pEjecutivoAlta
							AND imei= pImeiAnt;
						END IF
                        
                        LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
                        IF iNoRegistros = 0 THEN
                                LET cCodRet = '00001';
                        ELIF iNoRegistros > 1 THEN
                                LET cCodRet = '00283'; -- Se actulizaron mas de 1 registro
                        END IF;
						RETURN cCodRet, iNoRegistros;
					ELSE
						BEGIN
							ON EXCEPTION IN (-535)
								COMMIT; -- Transaccion del interact
								BEGIN WORK;
								LET bInTransaction = 't';
							END EXCEPTION WITH RESUME;
						
							BEGIN WORK;
							UPDATE bdinteg:"informix".si_usuario_movil SET
							password= pPassword,
							imei= pImei,
							activo= pActivo,
							nombre = pNombre,
							centro_costos=pCentro_costos,
							no_telefono= pNo_telefono, 
							generico1= pGenerico1, 
							generico2= pGenerico2, 
							generico3= pGenerico3, 
							sucursal=pSucursal
							WHERE ejecutivo=pEjecutivoAlta
							AND imei= pImeiAnt;
							
							IF(pActivo = '0') THEN
								UPDATE bdinteg:"informix".si_usuario_movil SET
								fecha_baja= CURRENT, 
								user_baja= pUsuario
								WHERE ejecutivo=pEjecutivoAlta
								AND imei= pImeiAnt;
							END IF
							
							SELECT COUNT(imei) INTO inoImei FROM bdinteg:"informix".si_usuario_movil WHERE imei= pImei AND ejecutivo = pEjecutivoAlta;
							IF inoImei = 1 THEN
								COMMIT WORK;
							ELSE
								ROLLBACK WORK;
								LET cCodRet = '00480'; -- El imei ya fue asignado anteriormente a este usuario
							END IF;
							
							IF bInTransaction THEN
								BEGIN WORK; -- APERTURA DE LA TRANSACCION DEL INTERACT
							END IF;
							
							RETURN cCodRet, iNoRegistros;
						END;
					END IF;
					
                END IF;
        END;
        
END PROCEDURE;