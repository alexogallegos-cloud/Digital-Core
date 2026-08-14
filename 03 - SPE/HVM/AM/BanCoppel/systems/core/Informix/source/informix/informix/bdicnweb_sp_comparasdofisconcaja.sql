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