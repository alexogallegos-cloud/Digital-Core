CREATE PROCEDURE "informix".sp_ope_consultametassaldos(pUsuario CHAR(8), pIdFuncion CHAR(10),  pTipoSuc INTEGER, pAnioMes CHAR(6))
		RETURNING CHAR(5) AS codret,
				DECIMAL(18,2) AS monto_cap,
				DECIMAL(18,2) AS monto_col;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE dMonto_cap DECIMAL(18,2);
	DEFINE dMonto_col DECIMAL(18,2);
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET dMonto_cap = 0;
	LET dMonto_col = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dMonto_cap, dMonto_col;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultametassaldos.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pAnioMes = '' OR pTipoSuc IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dMonto_cap, dMonto_col;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dMonto_cap, dMonto_col;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT COUNT(*)
		INTO iNoRegistros
		FROM bdmis:"informix".mi_tiposuc 
		WHERE id_tiposuc = pTipoSuc 
		AND aniomes = pAnioMes;
		
		IF iNoRegistros=0 THEN
			LET cCodRet = '00981';		
		ELSE
			SELECT meta_monto_cap, meta_monto_col 
			INTO dMonto_cap, dMonto_col
			FROM bdmis:"informix".mi_tiposuc 
			WHERE id_tiposuc = pTipoSuc 
			AND aniomes = pAnioMes;
		END IF;
		
		RETURN cCodRet, dMonto_cap, dMonto_col;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 17/05/2017',
'MODULO: Operaciones',
'FUNCIONALIDAD: Mantenimiento Tipo Sucursal',
'DESCRIPCION: Procedimiento que realiza el la consulta de las Metas de Saldos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_guardamanttometassaldos(pUsuario CHAR(8), pIdFuncion CHAR(10), pMontoCap DECIMAL(18,2), pMontoColocacion DECIMAL(18,2), pTipoSuc INTEGER, pAnioMes CHAR(6))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNombre CHAR(45);
	DEFINE iNoRegistroBitacora INTEGER;
	DEFINE iIdRegistroBitacora INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdRegistro INTEGER;
	DEFINE cCambio CHAR(500);
	DEFINE cMovimiento CHAR(500);
	DEFINE cCambioBitacora CHAR(500);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNombre = '';
	LET iNoRegistroBitacora = 0;
	LET iIdRegistroBitacora = 0;
	LET iNoRegistros = 0;
	LET iIdRegistro = 0;
	LET cCambio = "";
	LET cMovimiento = "";
	LET cCambioBitacora = "";
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_guardamanttometassaldos.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pMontoCap IS NULL OR pMontoColocacion IS NULL OR pTipoSuc IS NULL OR pAnioMes = '' THEN
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
		
		SELECT COUNT(*) 
		INTO iNoRegistros
		FROM bdmis:"informix".mi_movimientosmetas;
		
		IF iNoRegistros = 0 THEN
			LET iIdRegistro = 1;
		ELSE
			SELECT MAX(id) 
			INTO iIdRegistro
			FROM bdmis:"informix".mi_movimientosmetas;
			
			LET iIdRegistro = iIdRegistro + 1;
		END IF;
		
		
		SELECT COUNT(*) 
		INTO iNoRegistroBitacora
		FROM bdmis:"informix".mi_bitacora_metas;
		
		IF iNoRegistros = 0 THEN
			LET iIdRegistro = 1;
		ELSE
			SELECT MAX(id) 
			INTO iIdRegistroBitacora
			FROM bdmis:"informix".mi_bitacora_metas;
			
			LET iIdRegistroBitacora = iIdRegistroBitacora + 1;
		END IF;		
		
		SELECT nombre
		INTO cNombre
		FROM bdinteg:"informix".si_ejecut
		WHERE ejecutivo= pUsuario;
		
		
		
		LET cCambio = "Actividad realizada: update bdmis:mi_tiposuc set meta_monto_cap = *" || pMontoCap || "*, meta_monto_col = *" || pMontoColocacion || "* where id_tiposuc = *" || pTipoSuc || "* and aniomes = *" || pAnioMes ||"*";
		LET cMovimiento = "Actualización Modulo Metas Saldo, Monto Captacion: " || pMontoCap || ", Monto Colocacion: " || pMontoColocacion || ", Año/Mes: " || pAnioMes || ", Tipo de Sucursal = " || pTipoSuc;
		LET cCambioBitacora = "Actividad realizada: update bdmis:mi_tiposuc set meta_monto_cap = " || pMontoCap || ", meta_monto_col = " || pMontoColocacion || " where id_tiposuc = " || pTipoSuc || " and aniomes = " || pAnioMes;
		IF EXISTS (SELECT * FROM bdmis:"informix".mi_movimientosmetas WHERE cambio = cCambio) THEN
			LET cCodRet = "00980";
		ELSE
		
		INSERT INTO bdmis:"informix".mi_movimientosmetas(id, empleado, nombre, fecha, hora, cambio, movimiento) 
		VALUES(iIdRegistro, pUsuario, cNombre, CURRENT, TO_CHAR(CURRENT, '%H:%M:%S'), cCambio, cMovimiento);
		
		INSERT INTO bdmis:"informix".mi_bitacora_metas(id, empleado, nombre, fecha, hora, cambio) 
		VALUES(iIdRegistroBitacora, pUsuario, cNombre, CURRENT, TO_CHAR(CURRENT, '%H:%M:%S'), cCambioBitacora);
		
		END IF;
		 
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 17/05/2017',
'MODULO: Operaciones',
'FUNCIONALIDAD: Mantenimiento Tipo Sucursal',
'DESCRIPCION: Procedimiento que realiza el cambio a las Metas de Saldos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_guardametacumplimiento(pUsuario CHAR(8), pIdFuncion CHAR(10), pParametro INTEGER , pValor DECIMAL(16,2), pDescripcion CHAR(60))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNombre CHAR(45);
	DEFINE iNoRegistroBitacora INTEGER;
	DEFINE iIdRegistroBitacora INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdRegistro INTEGER;
	DEFINE cCambio CHAR(500);
	DEFINE cMovimiento CHAR(500);
	DEFINE cCambioBitacora CHAR(500);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNombre = '';
	LET iNoRegistroBitacora = 0;
	LET iIdRegistroBitacora = 0;
	LET iNoRegistros = 0;
	LET iIdRegistro = 0;
	LET cCambio = "";
	LET cMovimiento = "";
	LET cCambioBitacora = "";
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_guardametacumplimiento.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pValor IS NULL OR pParametro IS NULL OR pDescripcion = '' THEN
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
		
		SELECT COUNT(*) 
		INTO iNoRegistros
		FROM bdmis:"informix".mi_movimientosmetas;
		
		IF iNoRegistros = 0 THEN
			LET iIdRegistro = 1;
		ELSE
			SELECT MAX(id) 
			INTO iIdRegistro
			FROM bdmis:"informix".mi_movimientosmetas;
			
			LET iIdRegistro = iIdRegistro + 1;
		END IF;
		
		
		SELECT COUNT(*) 
		INTO iNoRegistroBitacora
		FROM bdmis:"informix".mi_bitacora_metas;
		
		IF iNoRegistros = 0 THEN
			LET iIdRegistro = 1;
		ELSE
			SELECT MAX(id) 
			INTO iIdRegistroBitacora
			FROM bdmis:"informix".mi_bitacora_metas;
			
			LET iIdRegistroBitacora = iIdRegistroBitacora + 1;
		END IF;		
		
		SELECT nombre
		INTO cNombre
		FROM bdinteg:"informix".si_ejecut
		WHERE ejecutivo= pUsuario;
		
		
		
		LET cCambio = "Actividad realizada: update bdmis:mi_paramcump set valor = *" || pValor || "* where parametro = *" || pParametro || "*";
		LET cMovimiento = "Actualización Cumplimiento, Parámetro: " || pDescripcion ||", Valor: " || pValor;
		LET cCambioBitacora = "Actividad realizada: update bdmis:mi_paramcump set valor = " || pValor || " where parametro = " || pParametro;
		IF EXISTS (SELECT * FROM bdmis:"informix".mi_movimientosmetas WHERE cambio = cCambio) THEN
			LET cCodRet = "00980";
		ELSE
		
		INSERT INTO bdmis:"informix".mi_movimientosmetas(id, empleado, nombre, fecha, hora, cambio, movimiento) 
		VALUES(iIdRegistro, pUsuario, cNombre, CURRENT, TO_CHAR(CURRENT, '%H:%M:%S'), cCambio, cMovimiento);
		
		INSERT INTO bdmis:"informix".mi_bitacora_metas(id, empleado, nombre, fecha, hora, cambio) 
		VALUES(iIdRegistroBitacora, pUsuario, cNombre, CURRENT, TO_CHAR(CURRENT, '%H:%M:%S'), cCambioBitacora);
		
		END IF;
		 
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 15/05/2017',
'MODULO: Operaciones',
'FUNCIONALIDAD: Mantenimiento Metas Productos',
'DESCRIPCION: Procedimiento que almacena los cambios generados en la funcionalidad',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_lecturarchivosmelb(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion INTEGER, pDireccionMac CHAR(12), pRutaArchivo CHAR(100), pNombreArchivo CHAR(40))
		RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;		
	DEFINE cSQL CHAR(500);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE cCampos CHAR(1024);
	DEFINE cTablaDst CHAR(150);
	DEFINE cBaseDatos CHAR(50);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cCmd2 CHAR(2000);
	DEFINE cUsrBin CHAR(15);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';	
	LET cCodRetSp = '';
	LET iCodRetSp = 0;		
	LET cSQL = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET cCampos = '';
	LET cTablaDst = '';
	LET cBaseDatos = '';
	LET cCmd1 = '';
	LET cCmd2 = '';
	LET cUsrBin = '/usr/bin/';

	BEGIN
		ON EXCEPTION SET iSqlErr, cIsamErr, cDescErr
			IF iSqlErr <> 0 THEN
			
				IF ven_transacc = 1 THEN
					ROLLBACK WORK;		
				END IF;
				
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535, -668, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_lecturarchivosmelb.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pDireccionMac = '' OR pRutaArchivo = '' OR pNombreArchivo = '' OR pTipoOperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--Concentraciones
		IF pTipoOperacion = 1 THEN
				
			DELETE FROM bdisuc:"informix".ss_recibe_datosconcentracionws WHERE usuario = pUsuario AND direccion_mac = pDireccionMac;
			
			BEGIN WORK;
			LET ven_transacc = 1;
			
			LET cBaseDatos = 'bdisuc';
			LET cTablaDst = 'ss_recibe_datosconcentracionws';
			LET cCampos = 'id_banco,id_solicitud,fecha_aplicacion,motivo_visita,folio_comprobante,dice_contener,real_verificado,tipo_domicilio,tipo_movimiento,urb_for,estado_transito,estado_visita,estado_boveda,estado_verificada,estado_otro,sucursal_banco,misc1,misc2,misc3,misc4,misc5,usuario,direccion_mac';
			
			LET cCmd1 = TRIM(cUsrBin)||"echo "||'"'||"LOAD FROM "||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||" DELIMITER '&' INSERT INTO "||TRIM(cBaseDatos)||":"||TRIM(cTablaDst)||"(";
			LET cCmd2 = TRIM(cCmd1)||TRIM(cCampos)||")"||'"'||" | /ifxsif01/bin/dbaccess bdicnweb > /dev/null 2>&1";
			SYSTEM TRIM(cCmd2);
			COMMIT WORK;										

		END IF;	
		--Dotaciones
		IF pTipoOperacion = 2 THEN
			
			DELETE FROM bdisuc:"informix".ss_recibe_datosdotacionws WHERE usuario = pUsuario AND direccion_mac = pDireccionMac;
			
			BEGIN WORK;
			LET ven_transacc = 1;
			
			LET cBaseDatos = 'bdisuc';
			LET cTablaDst = 'ss_recibe_datosdotacionws';
			LET cCampos = 'id_banco,id_solicitud,fecha_aplicacion,motivo_cambio,motivo_devolucion,folio_comprobante,monto_comprobante,tipo_domicilio,urb_for,estado_rechazada,';
			LET cCampos = TRIM(cCampos)||'estado_aprobada,estado_preparada,estado_boveda,estado_transito,estado_entregada_banco,estado_devolucion,estado_cerrada,estado_cerrada_dev,motivo_rechazo,sucursal_banco,';
			LET cCampos = TRIM(cCampos)||'billete_1,billete_2,billete_5,billete_10,billete_20,billete_50,billete_100,billete_200,billete_500,billete_1000,moneda_001,moneda_005,moneda_010,';
			LET cCampos = TRIM(cCampos)||'moneda_020,moneda_025,moneda_050,moneda_1,moneda_2,moneda_5,moneda_10,moneda_20,moneda_50,moneda_100,misc1,misc2,misc3,misc4,misc5,usuario,direccion_mac';

			LET cCmd1 = TRIM(cUsrBin)||"echo "||'"'||"LOAD FROM "||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||" DELIMITER '&' INSERT INTO "||TRIM(cBaseDatos)||":"||TRIM(cTablaDst)||"(";
			LET cCmd2 = TRIM(cCmd1)||TRIM(cCampos)||")"||'"'||" | /ifxsif01/bin/dbaccess bdicnweb > /dev/null 2>&1";
			SYSTEM TRIM(cCmd2);
			COMMIT WORK;							
			
		END IF;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		-- SE ELIMINA EL ARCHIVO ORIGINAL
		LET cSQL = '';
		LET cSQL = '/usr/bin/rm -rf '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo);
		SYSTEM TRIM(cSQL);
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 15/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MONITOR EFECTIVO EN LÍNEA BANCOPPEL',
'DESCRIPCION: Spl encargado de insertar los datos provenientes del web service de panamericano.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultas_movcaptacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20))
        RETURNING CHAR(5) AS codret,
        INTEGER AS existe_cuenta;
		
	DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE iExiste   INTEGER;
	    
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET iExiste = 0;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	 BEGIN
	 
		
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iExiste;
		END EXCEPTION;
                
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultas_movcaptacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iExiste;
		END IF;
                
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iExiste;
		END IF;
		
			
		SELECT COUNT(cuenta) INTO iExiste FROM "informix".sw_consultas_movcaptacion  WHERE cuenta = pCuenta;
		
		RETURN cCodRet, iExiste;
		
    END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 21/01/2019',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA MOVIMIENTOS CAPTACION',
'DESCRIPCION:SPL Intermedio que consulta si existe la cuenta empresarial en la tabla sw_consultas_movcaptacion',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_reportediarioremesasac(pUsuario CHAR(8), pIdFuncion CHAR(10), pPeriodo DATE, pConvenio CHAR(5), pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING  CHAR(5) AS codigoretorno,
	DATE AS Dia, 
	CHAR(16) AS Num_confirmacion, 
	MONEY(16,2) AS Importe, 
	CHAR (20) AS Forma_pago, 
	CHAR (16) AS Folio_op, 
	CHAR (5) AS Sucursal, 
	CHAR (8) AS Cajero, 
	CHAR (120) AS Nom_benef;

/*  DEFINICION DE VARIABLES */
	DEFINE cCodRet CHAR(5);
	DEFINE dDia DATE;
	DEFINE cNum_confirmacion CHAR(16);
	DEFINE mImporte MONEY(16,2);
	DEFINE cForma_pago CHAR (20);
	DEFINE cFolio_op CHAR (16);
	DEFINE cSucursal CHAR (5);
	DEFINE cCajero CHAR (8);
	DEFINE cNom_benef CHAR (120);
	DEFINE iSqlerr INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iNoRegs INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iNumRows INTEGER;

/* INICIALIZACION DE VARIABLES */
	LET cCodRet = '00000';
	LET dDia = NULL;
	LET cNum_confirmacion = '';
	LET mImporte = 0.0;
	LET cForma_pago = '';
	LET cFolio_op = '';
	LET cSucursal = '';
	LET cCajero = '';
	LET cNom_benef = '';
	LET iSqlerr = 0 ;
	LET iRegistros = 0;
	LET iNoRegs = 0;
	LET iRecuperacion = 0;
	LET iNumRows = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef;
		END EXCEPTION;	
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_reportediarioremesasac.out';
		--TRACE ON;

		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


		IF pUsuario = '' OR pIdFuncion = '' OR pPeriodo = '' OR pConvenio = '' OR pRegistros = '' OR pRecuperacion = ''  THEN 
			LET cCodRet = '00003';
			RETURN cCodRet, dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef;
		END IF;
		
		IF pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef;
		END IF;
			
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef;
			END IF;
		SELECT COUNT(*)
		INTO iNumRows
		FROM bdisac:sac_movimientoshistorial
		WHERE  Fecha_Pago = pPeriodo
		AND status_cancelado = 'N';
		
		IF iNumRows <> 0 THEN
			IF pConvenio = '07004' THEN
				FOREACH EXECUTE PROCEDURE bdisac:sp_reportebts_diario(pPeriodo)
				INTO dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef
					IF iRegistros >= pRegistros THEN
						IF iRecuperacion < pRecuperacion THEN
							LET iRecuperacion = iRecuperacion + 1;				
							RETURN cCodRet, dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef WITH RESUME;
							LET iNoRegs = iNoRegs + 1;
						END IF;
					END IF;
						LET iRegistros = iRegistros + 1;
				END FOREACH;
			ELIF pConvenio = '07006' OR pConvenio = '07007' OR pConvenio = '07008' THEN
				FOREACH EXECUTE PROCEDURE bdisac:sp_reportewu_diario(pPeriodo,pConvenio)
				INTO dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef
					IF iRegistros >= pRegistros THEN
						IF iRecuperacion < pRecuperacion THEN
							LET iRecuperacion = iRecuperacion + 1;				
							RETURN cCodRet, dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef WITH RESUME;
							LET iNoRegs = iNoRegs + 1;
						END IF;
					END IF;
						LET iRegistros = iRegistros + 1;
				END FOREACH;
			ELIF pConvenio = '07009' THEN
				FOREACH EXECUTE PROCEDURE bdisac:sp_reporteapp_diario(pPeriodo)
				INTO dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef
					IF iRegistros >= pRegistros THEN
						IF iRecuperacion < pRecuperacion THEN
							LET iRecuperacion = iRecuperacion + 1;				
							RETURN cCodRet, dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef WITH RESUME;
							LET iNoRegs = iNoRegs + 1;
						END IF;
					END IF;
						LET iRegistros = iRegistros + 1;
				END FOREACH;
			END IF;
		ELSE
			LET cCodRet = '00017';
			RETURN cCodRet, dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef;
		END IF;
		IF iNoRegs = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef;
		ELIF iNoRegs = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, 0, '', 0, '', '', '', '', '';
		END IF;
	END;
END PROCEDURE;