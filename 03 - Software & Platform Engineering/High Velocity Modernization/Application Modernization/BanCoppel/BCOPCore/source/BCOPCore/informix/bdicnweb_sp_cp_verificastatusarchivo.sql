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