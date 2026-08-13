CREATE PROCEDURE "informix".sp_mindstelefono_diario()
RETURNING CHAR(6) AS cod_ret,
		  CHAR(80) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(80);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						CHAR(200);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_TEL		VARCHAR(50);

--VARIABLE LAYOUT TELEFONO
DEFINE v_telefono				CHAR(13);
DEFINE v_idtipotelefono			INTEGER;
DEFINE v_idestatuscargaminds	INTEGER;
DEFINE v_fecharegistro			CHAR(10);
DEFINE v_fechaactualizacion		CHAR(10);
DEFINE v_nic 					CHAR(20);

--VARIABLE DE PASO
DEFINE temp_fecharegistro		DATE;
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_ant				DATE;
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE vconteo					INTEGER;

--SE INICIALIZAN VARIABLES
LET v_idestatuscargaminds = 0;
LET vcommit = 0;
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vconteo = 0;

BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
		IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
        LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_mindstelefono_diario en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_TEL,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_mindstelefono_diario');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/jarias/sp_mindscliente_his.out';
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET vpaso = 1;
	
	--OBTIENE LA FECHA DEL DIA ANTERIOR DE LA FECHA ACTUAL
	SELECT fecha_hoy, fecha_ant 
	INTO v_fecha_hoy, v_fecha_ant
	FROM bdinteg:si_fechas;
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_ant), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_ant), 2, '0');
	LET cAno = YEAR(v_fecha_ant);
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO	 	 = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA_TEL	 = 'CargaTelMinds_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	---Borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".tbl_telefono_minds;
	COMMIT;

	LET vpaso = 4;
	
	
	FOREACH WITH HOLD 
		SELECT {+AVOID_FULL(bdinteg:si_telefonos_actual)} T.telefono,T.tipo_tel,DATE(fecha_hora),T.numcte
		INTO v_telefono,v_idtipotelefono,temp_fecharegistro,v_nic
		FROM bdinteg:si_telefonos_actual T 
		join bdinteg:si_cliente cli on (T.numcte = cli.numcte)
		WHERE cli.tipo_cliente = '1' and T.status_tel = 'A'
		AND DATE(T.fecha_hora) = v_fecha_ant
		
		LET vpaso = 5;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		--se ajusta el tipotelefono al cat_tipotelefono minds
		IF v_idtipotelefono = 1 THEN
			LET v_idtipotelefono = 2;
		ELIF v_idtipotelefono = 2 THEN
			LET v_idtipotelefono = 3;
		ELIF v_idtipotelefono = 3 THEN
			LET v_idtipotelefono = 1;
		END IF		
		
		LET v_fechaactualizacion = to_char(temp_fecharegistro, '%Y-%m-%d');
		LET v_fecharegistro = to_char(temp_fecharegistro, '%Y-%m-%d');
		LET vconteo = vconteo + 1;
		
		LET vpaso = 6;
		
		INSERT INTO "informix".tbl_telefono_minds (idregistro,nic,telefono,idtipotelefono,fechaactualizacion,idestatuscargaminds,fecharegistro)
		VALUES (vconteo,v_nic,v_telefono,v_idtipotelefono,v_fechaactualizacion,v_idestatuscargaminds,v_fecharegistro);	
		
		LET vpaso = 7;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			let vcommit = 0;			
		END IF	
		
	END FOREACH;
	
	LET vpaso = 8;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF	
	
	LET vpaso = 9;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE TELEFONOS
	LET vsql = '';
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_TEL||'.txt select * FROM bdiauditor:tbl_telefono_minds;">'||RUTA_DESTINO||TIPO_PLANTILLA_TEL||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 10;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_TEL||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_TEL||'_01.sql';
	system vsql;
	
	LET vpaso = 11;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_TEL||'_01.sql';
	system vsql; 
	
	LET vpaso = 12;
	LET cod_ret = '000000';
    LET vmensaje = 'PROCESO EXITOSO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_TEL);
	
	INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_mindstelefono_diario');
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE
DOCUMENT 'AUTOR: Jorge Luis Arias Nu#ez',
'FECHA: 22/08/2019',
'DESCRIPCION: Generación de información telefonos para sistemas MINDS PLD',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_ope_bitacoraxml(pUsuario CHAR(8), pFecha DATE, pHora CHAR(8), pAccion CHAR(350), pVal_ant CHAR(80), pVal_new CHAR(80))
	RETURNING CHAR(5) AS codret,
			CHAR(90) AS mensaje;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cMensaje CHAR(90);
	DEFINE cCodRetSp CHAR(8);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;	
	LET cMensaje = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cMensaje;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_bitacoraxml.out';
		--TRACE ON;
		
		IF pFecha = '' OR pHora = '' OR pAccion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cMensaje;
		END IF;		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE "informix".sp_chq_crg_bitacora(pFecha, pHora, pUsuario, pAccion, pVal_ant, pVal_new) 
		INTO cCodRetSp,cMensaje;
		
		IF cCodRetSp::INTEGER < 0 THEN
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiauditor:sp_chq_crg_bitacora';
		END IF;
		
		RETURN cCodRet,cMensaje;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 18/07/2022',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE CHEQUES TXT',
'DESCRIPCION: SPL encargado de ejecutar el SP productivo bdiauditor:sp_chq_crg_bitacora encargado de realizar el bitacoreo',
'sobre las acciones realizadas en la generaciÃ³n del archivo XML';

CREATE PROCEDURE "informix".sp_ope_cargainfo_xml(pUsuario CHAR(8), pPeriodo CHAR(20))
	RETURNING CHAR(5) AS codret,
			  INTEGER AS totRegistros;
	
	DEFINE cCodRet	CHAR(5);
	DEFINE iSqlErr	INTEGER;	
	DEFINE iRecuperacion INTEGER;
	DEFINE cCodRetSp	CHAR(8);
	DEFINE cMensaje	CHAR(120);
	DEFINE dPechaProceso	DATETIME YEAR TO FRACTION(3);
	DEFINE cPeriodo	CHAR(20);
	DEFINE cCveAutoridad	CHAR(6);
	DEFINE cCveEntidad		CHAR(6);
	DEFINE cFolioConsecOper CHAR(14);
	DEFINE cFolioPrevOper	CHAR(14);
	DEFINE cFechaOper		CHAR(8);
	DEFINE cCveSucursal		CHAR(8);
	DEFINE cNumCheque		CHAR(18);
	DEFINE cCveMoneda		CHAR(3);
	DEFINE cMontoCheque		CHAR(17);
	DEFINE cMontoLiq		CHAR(17);
	DEFINE cCveBancoEmisor	CHAR(200);
	DEFINE cCveMedioLiq		CHAR(2);
	DEFINE cCuentaAbono		CHAR(18);
	DEFINE cCve_moneda_liq	CHAR(3);
	DEFINE cNombresPF		CHAR(60);
	DEFINE cApellParternoPF	CHAR(60);
	DEFINE cApellMaternoPF	CHAR(60);
	DEFINE vFechaNacPF		CHAR(8);
	DEFINE vCurpPF			CHAR(20);
	DEFINE vRfcPF			CHAR(13);
	DEFINE vCveNacionalidadPF	CHAR(2);
	DEFINE vCveActEconPF	CHAR(7);
	DEFINE vRazonSocialPM	CHAR(60);
	DEFINE vFechaConstitucionPM	CHAR(8);
	DEFINE vRfcPM 			CHAR(13);
	DEFINE vCveNacionalidadPM	CHAR(2);
	DEFINE vGiroPM			CHAR(60);
	DEFINE vCorreoElectPM	CHAR(60);
	DEFINE vNombreApoderadoPM	CHAR(60);
	DEFINE vDomicilioUnific	CHAR(200);
	DEFINE vCiudadDomUnif	CHAR(60);
	DEFINE vColoniaDomUnif	CHAR(60);
	DEFINE vCodpostDomUnif	CHAR(5);
	DEFINE vCvePaisTelefono	CHAR(2);
	DEFINE vTelefono		CHAR(12);
	DEFINE vExtension		CHAR(6);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iRecuperacion = 0;
	LET cCodRetSp	= '';
	LET cMensaje	= '';
	LET dPechaProceso	= '';
	LET cPeriodo	= '';
	LET cCveAutoridad	= '';
	LET cCveEntidad		= '';
	LET cFolioConsecOper	= '';
	LET cFolioPrevOper	= '';
	LET cFechaOper		= '';
	LET cCveSucursal	= '';
	LET cNumCheque	= '';
	LET cCveMoneda	= '';
	LET cMontoCheque	= '';
	LET cMontoLiq	= '';
	LET cCveBancoEmisor	= '';
	LET cCveMedioLiq	= '';
	LET cCuentaAbono	= '';
	LET cCve_moneda_liq	= '';
	LET cNombresPF	= '';
	LET cApellParternoPF	= '';
	LET cApellMaternoPF	= '';
	LET vFechaNacPF	= '';
	LET vCurpPF		= '';
	LET vRfcPF		= '';
	LET vCveNacionalidadPF	= '';
	LET vCveActEconPF	= '';
	LET vRazonSocialPM	= '';
	LET vFechaConstitucionPM	= '';
	LET vRfcPM		= '';
	LET vCveNacionalidadPM	= '';
	LET vGiroPM		= '';
	LET vCorreoElectPM	= '';
	LET vNombreApoderadoPM	= '';
	LET vDomicilioUnific	= '';
	LET vCiudadDomUnif	= '';
	LET vColoniaDomUnif	= '';
	LET vCodpostDomUnif	= '';
	LET vCvePaisTelefono	= '';
	LET vTelefono	= '';
	LET vExtension	= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".sw_verificastatuscargaxml
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iRecuperacion;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_cargainfo_xml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pPeriodo = '' THEN
			LET cCodRet = '00003';
			UPDATE "informix".sw_verificastatuscargaxml
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iRecuperacion;
		END IF;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".sw_verificastatuscargaxml WHERE usuario_insert = TRIM(pUsuario);
		INSERT INTO "informix".sw_verificastatuscargaxml(usuario_insert,status,error_proceso,error,total_registros) 
		VALUES (pUsuario,'I','',cCodRet,0);
		DELETE FROM "informix".sw_ope_cargainfo_xml WHERE id_usuario = TRIM(pUsuario);
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE "informix".sp_pld_chq_crg_xml(pPeriodo)
			INTO cCodRetSp, cMensaje, dPechaProceso, cPeriodo, cCveAutoridad, cCveEntidad, cFolioConsecOper, cFolioPrevOper, cFechaOper, 
			cCveSucursal, cNumCheque, cCveMoneda, cMontoCheque, cMontoLiq, cCveBancoEmisor, cCveMedioLiq, cCuentaAbono, cCve_moneda_liq, 
			cNombresPF, cApellParternoPF, cApellMaternoPF, vFechaNacPF, vCurpPF, vRfcPF, vCveNacionalidadPF, vCveActEconPF, vRazonSocialPM, 
			vFechaConstitucionPM, vRfcPM, vCveNacionalidadPM, vGiroPM, vCorreoElectPM, vNombreApoderadoPM, vDomicilioUnific, vCiudadDomUnif, 
			vColoniaDomUnif, vCodpostDomUnif, vCvePaisTelefono, vTelefono, vExtension
			
			IF cCodRetSp::INTEGER < 0 THEN
				UPDATE "informix".sw_verificastatuscargaxml
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiauditor:sp_pld_chq_crg_xml';
			ELIF cCodRetSp::INTEGER = 2 THEN	
				LET cCodRet = '00017';
				UPDATE "informix".sw_verificastatuscargaxml
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet, iRecuperacion;
			ELSE
				LET iRecuperacion = iRecuperacion + 1;
				INSERT INTO "informix".sw_ope_cargainfo_xml (id_usuario, fecha_proceso, periodo, cve_autoridad, cve_entidad, folio_consec_oper, 
				folio_prev_oper, fecha_oper, cve_sucursal, numcheque, cve_moneda, monto_cheque, monto_liq, cve_banco_emisor, cve_medio_liq, 
				cuenta_abono, cve_moneda_liq, nombres_pf, apell_parterno_pf, apell_materno_pf, fecha_nac_pf, curp_pf, rfc_pf, cve_nacionalidad_pf, 
				cve_act_econ_pf, razon_social_pm, fecha_constitucion_pm, rfc_pm, cve_nacionalidad_pm, giro_pm, correo_elect_pm, nombreapoderado_pm, 
				domicilio_unific, ciudad_dom_unif, colonia_dom_unif, codpost_dom_unif, cve_pais_telefono, telefono, extension)
				VALUES (pUsuario, dPechaProceso, cPeriodo, cCveAutoridad, cCveEntidad, cFolioConsecOper, cFolioPrevOper, cFechaOper, 
				cCveSucursal, cNumCheque, cCveMoneda, cMontoCheque, cMontoLiq, cCveBancoEmisor, cCveMedioLiq, cCuentaAbono, cCve_moneda_liq, 
				cNombresPF, cApellParternoPF, cApellMaternoPF, vFechaNacPF, vCurpPF, vRfcPF, vCveNacionalidadPF, vCveActEconPF, vRazonSocialPM, 
				vFechaConstitucionPM, vRfcPM, vCveNacionalidadPM, vGiroPM, vCorreoElectPM, vNombreApoderadoPM, vDomicilioUnific, vCiudadDomUnif, 
				vColoniaDomUnif, vCodpostDomUnif, vCvePaisTelefono, vTelefono, vExtension);
			END IF;	
		END FOREACH;
		
		UPDATE "informix".sw_verificastatuscargaxml
		SET status = 'T', error_proceso = 'N', total_registros = iRecuperacion WHERE usuario_insert = pUsuario;
		
		RETURN cCodRet, iRecuperacion;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 18/07/2022',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE CHEQUES TXT',
'DESCRIPCION: SPL encargado de ejecutar el SP productivo bdiauditor:sp_pld_chq_crg_xml',
'encargado de recuperar la informaciÃ³n para el archivo XML';

CREATE PROCEDURE "informix".sp_ope_consulta_infoxml(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
			DATETIME YEAR TO FRACTION(3) AS dPechaProceso,
			CHAR(20) AS periodo,
			CHAR(6) AS cveAutoridad,
			CHAR(6) AS cveEntidad,
			CHAR(14) AS folioConsecOper,
			CHAR(14) AS folioPrevOper, 
			CHAR(8) AS fechaOper,
			CHAR(8) AS cveSucursal,
			CHAR(18) AS numCheque,
			CHAR(3) AS cveMoneda, 
			CHAR(17) AS montoCheque,
			CHAR(17) AS montoLiq,
			CHAR(200) AS cveBancoEmisor,
			CHAR(2) AS cveMedioLiq,
			CHAR(18) AS cuentaAbono,
			CHAR(3) AS cve_moneda_liq,
			CHAR(60) AS nombresPF, 
			CHAR(60) AS apellParternoPF,
			CHAR(60) AS apellMaternoPF,
			CHAR(8) AS fechaNacPF,
			CHAR(20) AS curpPF,
			CHAR(13) AS rfcPF, 
			CHAR(2) AS cveNacionalidadPF,
			CHAR(7) AS cveActEconPF,
			CHAR(60) AS razonSocialPM, 
			CHAR(8) AS fechaConstitucionPM,
			CHAR(13) AS rfcPM,
			CHAR(2) AS cveNacionalidadPM, 
			CHAR(60) AS giroPM,
			CHAR(60) AS correoElectPM,
			CHAR(60) AS nombreApoderadoPM, 
			CHAR(200) AS domicilioUnific, 
			CHAR(60) AS ciudadDomUnif,
			CHAR(60) AS coloniaDomUnif, 
			CHAR(5) AS codpostDomUnif, 
			CHAR(2) AS cvePaisTelefono, 
			CHAR(12) AS telefono,
			CHAR(6) AS extension;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE iNoRegistros	INTEGER;
	DEFINE dPechaProceso	DATETIME YEAR TO FRACTION(3);
	DEFINE cPeriodo	CHAR(20);
	DEFINE cCveAutoridad	CHAR(6);
	DEFINE cCveEntidad		CHAR(6);
	DEFINE cFolioConsecOper CHAR(14);
	DEFINE cFolioPrevOper	CHAR(14);
	DEFINE cFechaOper		CHAR(8);
	DEFINE cCveSucursal		CHAR(8);
	DEFINE cNumCheque		CHAR(18);
	DEFINE cCveMoneda		CHAR(3);
	DEFINE cMontoCheque		CHAR(17);
	DEFINE cMontoLiq		CHAR(17);
	DEFINE cCveBancoEmisor	CHAR(200);
	DEFINE cCveMedioLiq		CHAR(2);
	DEFINE cCuentaAbono		CHAR(18);
	DEFINE cCve_moneda_liq	CHAR(3);
	DEFINE cNombresPF		CHAR(60);
	DEFINE cApellParternoPF	CHAR(60);
	DEFINE cApellMaternoPF	CHAR(60);
	DEFINE vFechaNacPF		CHAR(8);
	DEFINE vCurpPF			CHAR(20);
	DEFINE vRfcPF			CHAR(13);
	DEFINE vCveNacionalidadPF	CHAR(2);
	DEFINE vCveActEconPF	CHAR(7);
	DEFINE vRazonSocialPM	CHAR(60);
	DEFINE vFechaConstitucionPM	CHAR(8);
	DEFINE vRfcPM 			CHAR(13);
	DEFINE vCveNacionalidadPM	CHAR(02);
	DEFINE vGiroPM			CHAR(60);
	DEFINE vCorreoElectPM	CHAR(60);
	DEFINE vNombreApoderadoPM	CHAR(60);
	DEFINE vDomicilioUnific	CHAR(200);
	DEFINE vCiudadDomUnif	CHAR(60);
	DEFINE vColoniaDomUnif	CHAR(60);
	DEFINE vCodpostDomUnif	CHAR(5);
	DEFINE vCvePaisTelefono	CHAR(2);
	DEFINE vTelefono		CHAR(12);
	DEFINE vExtension		CHAR(6);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET iNoRegistros = 0;
	LET dPechaProceso	= '';
	LET cPeriodo	= '';
	LET cCveAutoridad	= '';
	LET cCveEntidad		= '';
	LET cFolioConsecOper	= '';
	LET cFolioPrevOper	= '';
	LET cFechaOper		= '';
	LET cCveSucursal	= '';
	LET cNumCheque	= '';
	LET cCveMoneda	= '';
	LET cMontoCheque	= '';
	LET cMontoLiq	= '';
	LET cCveBancoEmisor	= '';
	LET cCveMedioLiq	= '';
	LET cCuentaAbono	= '';
	LET cCve_moneda_liq	= '';
	LET cNombresPF	= '';
	LET cApellParternoPF	= '';
	LET cApellMaternoPF	= '';
	LET vFechaNacPF	= '';
	LET vCurpPF		= '';
	LET vRfcPF		= '';
	LET vCveNacionalidadPF	= '';
	LET vCveActEconPF	= '';
	LET vRazonSocialPM	= '';
	LET vFechaConstitucionPM	= '';
	LET vRfcPM		= '';
	LET vCveNacionalidadPM	= '';
	LET vGiroPM		= '';
	LET vCorreoElectPM	= '';
	LET vNombreApoderadoPM	= '';
	LET vDomicilioUnific	= '';
	LET vCiudadDomUnif	= '';
	LET vColoniaDomUnif	= '';
	LET vCodpostDomUnif	= '';
	LET vCvePaisTelefono	= '';
	LET vTelefono	= '';
	LET vExtension	= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dPechaProceso, cPeriodo, cCveAutoridad, cCveEntidad, cFolioConsecOper, cFolioPrevOper, cFechaOper, 
			cCveSucursal, cNumCheque, cCveMoneda, cMontoCheque, cMontoLiq, cCveBancoEmisor, cCveMedioLiq, cCuentaAbono, cCve_moneda_liq, 
			cNombresPF, cApellParternoPF, cApellMaternoPF, vFechaNacPF, vCurpPF, vRfcPF, vCveNacionalidadPF, vCveActEconPF, vRazonSocialPM, 
			vFechaConstitucionPM, vRfcPM, vCveNacionalidadPM, vGiroPM, vCorreoElectPM, vNombreApoderadoPM, vDomicilioUnific, vCiudadDomUnif, 
			vColoniaDomUnif, vCodpostDomUnif, vCvePaisTelefono, vTelefono, vExtension;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consulta_infoxml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dPechaProceso, cPeriodo, cCveAutoridad, cCveEntidad, cFolioConsecOper, cFolioPrevOper, cFechaOper, 
			cCveSucursal, cNumCheque, cCveMoneda, cMontoCheque, cMontoLiq, cCveBancoEmisor, cCveMedioLiq, cCuentaAbono, cCve_moneda_liq, 
			cNombresPF, cApellParternoPF, cApellMaternoPF, vFechaNacPF, vCurpPF, vRfcPF, vCveNacionalidadPF, vCveActEconPF, vRazonSocialPM, 
			vFechaConstitucionPM, vRfcPM, vCveNacionalidadPM, vGiroPM, vCorreoElectPM, vNombreApoderadoPM, vDomicilioUnific, vCiudadDomUnif, 
			vColoniaDomUnif, vCodpostDomUnif, vCvePaisTelefono, vTelefono, vExtension;
		END IF;		
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet,dPechaProceso, cPeriodo, cCveAutoridad, cCveEntidad, cFolioConsecOper, cFolioPrevOper, cFechaOper, 
				cCveSucursal, cNumCheque, cCveMoneda, cMontoCheque, cMontoLiq, cCveBancoEmisor, cCveMedioLiq, cCuentaAbono, cCve_moneda_liq, 
				cNombresPF, cApellParternoPF, cApellMaternoPF, vFechaNacPF, vCurpPF, vRfcPF, vCveNacionalidadPF, vCveActEconPF, vRazonSocialPM, 
				vFechaConstitucionPM, vRfcPM, vCveNacionalidadPM, vGiroPM, vCorreoElectPM, vNombreApoderadoPM, vDomicilioUnific, vCiudadDomUnif, 
				vColoniaDomUnif, vCodpostDomUnif, vCvePaisTelefono, vTelefono, vExtension;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		/*EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dPechaProceso, cPeriodo, cCveAutoridad, cCveEntidad, cFolioConsecOper, cFolioPrevOper, cFechaOper, 
			cCveSucursal, cNumCheque, cCveMoneda, cMontoCheque, cMontoLiq, cCveBancoEmisor, cCveMedioLiq, cCuentaAbono, cCve_moneda_liq, 
			cNombresPF, cApellParternoPF, cApellMaternoPF, vFechaNacPF, vCurpPF, vRfcPF, vCveNacionalidadPF, vCveActEconPF, vRazonSocialPM, 
			vFechaConstitucionPM, vRfcPM, vCveNacionalidadPM, vGiroPM, vCorreoElectPM, vNombreApoderadoPM, vDomicilioUnific, vCiudadDomUnif, 
			vColoniaDomUnif, vCodpostDomUnif, vCvePaisTelefono, vTelefono, vExtension;
		END IF;*/
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion fecha_proceso, periodo, cve_autoridad, cve_entidad, folio_consec_oper, 
			folio_prev_oper, fecha_oper, cve_sucursal, numcheque, cve_moneda, monto_cheque, monto_liq, cve_banco_emisor, cve_medio_liq, 
			cuenta_abono, cve_moneda_liq, nombres_pf, apell_parterno_pf, apell_materno_pf, fecha_nac_pf, curp_pf, rfc_pf, cve_nacionalidad_pf, 
			cve_act_econ_pf, razon_social_pm, fecha_constitucion_pm, rfc_pm, cve_nacionalidad_pm, giro_pm, correo_elect_pm, nombreapoderado_pm, 
			domicilio_unific, ciudad_dom_unif, colonia_dom_unif, codpost_dom_unif, cve_pais_telefono, telefono, extension
			INTO dPechaProceso, cPeriodo, cCveAutoridad, cCveEntidad, cFolioConsecOper, cFolioPrevOper, cFechaOper, 
			cCveSucursal, cNumCheque, cCveMoneda, cMontoCheque, cMontoLiq, cCveBancoEmisor, cCveMedioLiq, cCuentaAbono, cCve_moneda_liq, 
			cNombresPF, cApellParternoPF, cApellMaternoPF, vFechaNacPF, vCurpPF, vRfcPF, vCveNacionalidadPF, vCveActEconPF, vRazonSocialPM, 
			vFechaConstitucionPM, vRfcPM, vCveNacionalidadPM, vGiroPM, vCorreoElectPM, vNombreApoderadoPM, vDomicilioUnific, vCiudadDomUnif, 
			vColoniaDomUnif, vCodpostDomUnif, vCvePaisTelefono, vTelefono, vExtension
			FROM "informix".sw_ope_cargainfo_xml
			WHERE id_usuario = trim(pUsuario)
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet,dPechaProceso, cPeriodo, cCveAutoridad, cCveEntidad, cFolioConsecOper, cFolioPrevOper, cFechaOper, 
			cCveSucursal, cNumCheque, cCveMoneda, cMontoCheque, cMontoLiq, cCveBancoEmisor, cCveMedioLiq, cCuentaAbono, cCve_moneda_liq, 
			cNombresPF, cApellParternoPF, cApellMaternoPF, vFechaNacPF, vCurpPF, vRfcPF, vCveNacionalidadPF, vCveActEconPF, vRazonSocialPM, 
			vFechaConstitucionPM, vRfcPM, vCveNacionalidadPM, vGiroPM, vCorreoElectPM, vNombreApoderadoPM, vDomicilioUnific, vCiudadDomUnif, 
			vColoniaDomUnif, vCodpostDomUnif, vCvePaisTelefono, vTelefono, vExtension WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,dPechaProceso, cPeriodo, cCveAutoridad, cCveEntidad, cFolioConsecOper, cFolioPrevOper, cFechaOper, 
			cCveSucursal, cNumCheque, cCveMoneda, cMontoCheque, cMontoLiq, cCveBancoEmisor, cCveMedioLiq, cCuentaAbono, cCve_moneda_liq, 
			cNombresPF, cApellParternoPF, cApellMaternoPF, vFechaNacPF, vCurpPF, vRfcPF, vCveNacionalidadPF, vCveActEconPF, vRazonSocialPM, 
			vFechaConstitucionPM, vRfcPM, vCveNacionalidadPM, vGiroPM, vCorreoElectPM, vNombreApoderadoPM, vDomicilioUnific, vCiudadDomUnif, 
			vColoniaDomUnif, vCodpostDomUnif, vCvePaisTelefono, vTelefono, vExtension;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,dPechaProceso, cPeriodo, cCveAutoridad, cCveEntidad, cFolioConsecOper, cFolioPrevOper, cFechaOper, 
			cCveSucursal, cNumCheque, cCveMoneda, cMontoCheque, cMontoLiq, cCveBancoEmisor, cCveMedioLiq, cCuentaAbono, cCve_moneda_liq, 
			cNombresPF, cApellParternoPF, cApellMaternoPF, vFechaNacPF, vCurpPF, vRfcPF, vCveNacionalidadPF, vCveActEconPF, vRazonSocialPM, 
			vFechaConstitucionPM, vRfcPM, vCveNacionalidadPM, vGiroPM, vCorreoElectPM, vNombreApoderadoPM, vDomicilioUnific, vCiudadDomUnif, 
			vColoniaDomUnif, vCodpostDomUnif, vCvePaisTelefono, vTelefono, vExtension;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 18/07/2022',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE CHEQUES TXT',
'DESCRIPCION: SPL encargado de recuperar la informaciÃ³n que se proceso para armar archivo xml';

CREATE PROCEDURE "informix".sp_ope_crgxml_head(pBandera CHAR(1))
	RETURNING CHAR(5) AS codret,
			CHAR(90) AS mensaje,
			CHAR(10) AS version,
			CHAR(6) AS orgRegulatoria,
			CHAR(6) AS cveEntidad,
			CHAR(60) AS folioConsecutivo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(8);
	DEFINE cMensaje CHAR(90);
	DEFINE cVersion CHAR(10);
	DEFINE cOrgRegulatoria CHAR(6);
	DEFINE cCveEntidad CHAR(6);
	DEFINE cFolioConsecutivo CHAR(60);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cCodRetSp = '';
	LET cMensaje = '';
	LET cVersion = '';
	LET cOrgRegulatoria = '';
	LET cCveEntidad = '';
	LET cFolioConsecutivo = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cMensaje, cVersion, cOrgRegulatoria, cCveEntidad, cFolioConsecutivo;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_crgxml_head.out';
		--TRACE ON;
		
		IF pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMensaje, cVersion, cOrgRegulatoria, cCveEntidad, cFolioConsecutivo;
		END IF;		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = 1 THEN
			EXECUTE PROCEDURE "informix".sp_pld_chq_crg_xml_head() 
			INTO cCodRetSp, cMensaje, cVersion, cOrgRegulatoria, cCveEntidad;
			
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiauditor:sp_pld_chq_crg_xml_head';
			ELIF cCodRetSp::INTEGER = 2 OR cCodRetSp::INTEGER = 3 THEN
				LET cCodRet = '00017'; --NO EXISTE VALOR ORGANISMO REGULADOR O CLAVE DE ENTIDAD
				RETURN cCodRet, cMensaje, cVersion, cOrgRegulatoria, cCveEntidad, cFolioConsecutivo;
			ELSE
				RETURN cCodRet, cMensaje, cVersion, cOrgRegulatoria, cCveEntidad, cFolioConsecutivo;
			END IF;
		ELSE
			SELECT valor INTO cFolioConsecutivo
			FROM bdiauditor:"informix".param
			WHERE llave = 'FOLIO_CONSEC_OPERAC';
			
			IF NVL(cFolioConsecutivo, '') = '' THEN
				LET cCodRet = '00017'; --NO EXISTE FOLIO CONSECUTIVO
				RETURN cCodRet, cMensaje, cVersion, cOrgRegulatoria, cCveEntidad, cFolioConsecutivo;
			ELSE
				RETURN cCodRet, cMensaje, cVersion, cOrgRegulatoria, cCveEntidad, cFolioConsecutivo;
			END IF
		END IF;		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 18/07/2022',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE CHEQUES TXT',
'DESCRIPCION: SPL encargado de ejecutar el SP productivo bdiauditor:sp_pld_chq_crg_xml_head encargado de recuperar los valores de los parametros',
'que irÃ¡n en el encabezado del archiov xml';

CREATE PROCEDURE "informix".sp_ope_validafoli_xml(pPeriodo CHAR(20))
	RETURNING CHAR(5) AS codret,
			INTEGER AS folioOperacion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iFolioOper INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET iFolioOper = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iFolioOper;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_validafoli_xml.out';
		--TRACE ON;
		
		IF pPeriodo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iFolioOper;
		END IF;		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE "informix".fn_pld_chqc_valfolper(pPeriodo) INTO iFolioOper;
			
		RETURN cCodRet,iFolioOper;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 18/07/2022',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE CHEQUES TXT',
'DESCRIPCION: SPL encargado de ejecutar el SP productivo bdiauditor:fn_pld_chqc_valfolper encargado de validar el folio de operacion';

CREATE PROCEDURE "informix".sp_ope_verificastatusxml(pUsuario CHAR(8))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,
		INTEGER AS totRegistros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,cErrorProceso,cError,iRegistros;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_verificastatusxml.out';
		--TRACE ON;
		
		IF pUsuario = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cErrorProceso,cError,iRegistros;
		END IF;		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status, error_proceso, error, total_registros
		INTO cStatus, cErrorProceso, cError, iRegistros
		FROM "informix".sw_verificastatuscargaxml WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,cErrorProceso,cError,iRegistros;
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 18/07/2022',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE CHEQUES TXT',
'DESCRIPCION: SPL encargado verificar el status del proceso';

CREATE PROCEDURE "informix".sp_pld_chq_addfolio_clon(pnumcheque CHAR(18), pcuenta_abono CHAR(18), pperiodo CHAR(20),pfolio CHAR(14))
RETURNING 	 CHAR(08) 	AS cod_ret 
			,CHAR(80)	AS mensaje;

--variables de retorno
	DEFINE	cod_ret		CHAR(08);
	DEFINE	mensaje		CHAR(80);
	
--variables de control de errores
	DEFINE	iSqlErr 		INTEGER;
	DEFINE	iIsamErr		INTEGER;
	DEFINE	vErrorInfo		VARCHAR(80);
	

BEGIN	
	ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cod_ret = iSqlErr;
			LET mensaje = vErrorInfo;
			UPDATE	tblpld_chqc_crg SET  folio_consec_oper = '' WHERE periodo = pperiodo;
			RETURN cod_ret, 'iIsamErr: '|| iIsamErr || 'ERR_DES ' || vErrorInfo ;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	LET cod_ret		= "00000000";
	LET	mensaje		= "PROCESO EXITOSO";
	
	UPDATE	"informix".tblpld_chqc_crg 
	SET 	folio_consec_oper = pfolio 
	WHERE	periodo		= pperiodo
	AND	cuenta_abono 	= pcuenta_abono
	AND	numcheque		= pnumcheque;
	
	RETURN cod_ret, mensaje;
	
END	
END PROCEDURE 
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 11/08/2022',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE CHEQUES TXT',
'DESCRIPCION: Se clona SPL encargado de ejecutar de realizar la actualizaciÃ³n de datos';

CREATE PROCEDURE "informix".sp_pld_chqc_crg_txt_validainf(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pPeriodo CHAR(20), pReporte CHAR(30))
    RETURNING CHAR(5) AS codret,
		CHAR(1) AS hay_datos,
		CHAR(3) AS estatus,
		CHAR(5) AS periodo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cHayDatos CHAR(1);
	DEFINE cEstatus CHAR(3);
	DEFINE cPeriodo CHAR(5);
	DEFINE cReporte CHAR(30);
	DEFINE iTotalRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cHayDatos = 'f';
	LET cEstatus = '';
	LET cPeriodo = '';
	LET cReporte = '';
	LET iTotalRegistros = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cHayDatos, cEstatus, cPeriodo;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_pld_chqc_crg_txt_validainf.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pPeriodo = '' OR pReporte = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cHayDatos, cEstatus, cPeriodo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;	
		SET LOCK MODE TO WAIT 3;
		
		--Estado Inicial de los Botones
		IF pIdConsulta = '1' THEN
			
			SELECT COUNT(*)
			INTO iTotalRegistros
			FROM bdiauditor:"informix".tblpld_chqc_txt;
			
			IF NVL(iTotalRegistros,0) > 0 THEN
				
				SELECT estatus, periodo, reporte INTO cEstatus, cPeriodo, cReporte
				FROM bdiauditor:"informix".tblpld_bit_ejec 
				WHERE reporte = pReporte AND periodo = pPeriodo
				AND fecha_hora_inicio = (SELECT MAX(fecha_hora_inicio) 
										 FROM bdiauditor:"informix".tblpld_bit_ejec);
				
				IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
					LET cHayDatos = 't';
				
				ELSE
					SELECT estatus, periodo, reporte INTO cEstatus, cPeriodo, cReporte
					FROM bdiauditor:"informix".tblpld_bit_ejec 
					WHERE fecha_hora_inicio = (SELECT MAX(fecha_hora_inicio) 
											   FROM bdiauditor:"informix".tblpld_bit_ejec);
				END IF;
				
			END IF;
			
			RETURN cCodRet, cHayDatos, cEstatus, cPeriodo; 
		
		--Botón Ejecutar
		ELIF pIdConsulta = '2' THEN
			
			SELECT estatus, periodo, reporte INTO cEstatus, cPeriodo, cReporte
			FROM bdiauditor:"informix".tblpld_bit_ejec
			WHERE reporte = pReporte AND estatus IN ('P','R')
			AND fecha_hora_inicio = (SELECT MAX(fecha_hora_inicio) 
									 FROM bdiauditor:"informix".tblpld_bit_ejec);
									 
			IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
				LET cCodRet = '00000'; --NO ES POSIBLE PROCESAR EL REPORTE [pReporte], DEBIDO A QUE ACTUALMENTE HAY OTRO PROCESO EN EJECUCIÓN PARA EL TRIMESTRE [cPeriodo]
			ELSE
			
				SELECT COUNT(*)
				INTO iTotalRegistros
				FROM bdiauditor:"informix".tblpld_chqc_crg 
				WHERE periodo = pPeriodo;
				
				IF NVL(iTotalRegistros,0) > 0 THEN
					LET cHayDatos = 't';
				ELSE
					LET cCodRet = '90001'; --NO ES POSIBLE GENERAR EL REPORTE [pReporte] DEBIDO A QUE NO EXISTE INFORMACIÓN PARA EL PERIODO INDICADO
				END IF;
				
			END IF;
			
			RETURN cCodRet, cHayDatos, cEstatus, cPeriodo; 
		
		--Botón Ejecutar TXT
		ELIF pIdConsulta = '3' THEN
			
			SELECT estatus, periodo, reporte INTO cEstatus, cPeriodo, cReporte
			FROM bdiauditor:"informix".tblpld_bit_ejec
			WHERE reporte = pReporte AND periodo = pPeriodo AND procedimiento = 'sp_pld_chqc_crg_txt_geninf'
			AND	fecha_hora_inicio = (SELECT MAX(fecha_hora_inicio) 
									 FROM bdiauditor:"informix".tblpld_bit_ejec
									 WHERE procedimiento = 'sp_pld_chqc_crg_txt_geninf');
									 
			IF NVL(cEstatus,'') = 'S' THEN
			
				SELECT COUNT(*)
				INTO iTotalRegistros
				FROM bdiauditor:"informix".tblpld_chqc_txt;
			
				IF NVL(iTotalRegistros,0) > 0 THEN
					LET cHayDatos = 't';
				ELSE
					LET cCodRet = '90002'; --NO ES POSIBLE GENERAR EL REPORTE [pReporte] DEBIDO A QUE NO EXISTE INFORMACIÓN PROCESADA PARA EL PERIODO INDICADO
				END IF;
				
			ELSE
				
				LET cCodRet = '90002'; --NO ES POSIBLE GENERAR EL REPORTE [pReporte] DEBIDO A QUE NO EXISTE INFORMACIÓN PROCESADA PARA EL PERIODO INDICADO
					
			END IF;
			
			RETURN cCodRet, cHayDatos, cEstatus, cPeriodo;
			
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 15/02/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE TRIMESTRAL DE CHEQUES DE CAJA EN FORMATO TXT',
'DESCRIPCION: SPL encargado de validar que exista información sobre la tabla consultada.',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_pld_chqc_crg_txt_geninf(pUsuario CHAR(8), pIdFuncion CHAR(10), pPeriodo CHAR(20), pReporte CHAR(30))
    RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cBanDetError CHAR(1);
	DEFINE cDesCodRet CHAR(250);
	DEFINE dFechaHoraInicio DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaHoraFin DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaHoy DATE;
	DEFINE cMes CHAR(2);
	DEFINE cAnio CHAR(4);
	DEFINE cNombreArchivo CHAR(50);
	DEFINE iTotalReg INTEGER;
	DEFINE iContCheque INTEGER;
	DEFINE iBloque INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	
	DEFINE mMontoCheque DECIMAL(17,2);
	DEFINE cFechaPago CHAR(8);
	DEFINE dFechaPago DATE;
	DEFINE cCuentaAbono CHAR(18);
	DEFINE cNombrePf CHAR(180);
	DEFINE cRazonSocial CHAR(60);
	DEFINE mValorCambio DECIMAL(10,4);
	DEFINE mMontoChequeUsd DECIMAL(17,2);
	DEFINE cNumeroCliente CHAR(20);
	DEFINE cNombreRazon CHAR(180);
	DEFINE iIdBitEjec INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIsamErr = 0;
	LET cDescErr = '';	
	LET cCodRetSp = '000000';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cBanDetError = 'f';
	LET cDesCodRet = 'EJECUCIÓN EXITOSA DEL PROCEDIMIENTO';
	LET dFechaHoraInicio = '';
	LET dFechaHoraFin = '';
	LET dFechaHoy = '';
	LET cMes = '';
	LET cAnio = '';
	LET cNombreArchivo = '';
	LET iTotalReg = 0;
	LET iContCheque = 0;
	LET iBloque = 0;
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	
	LET mMontoCheque = 0.00;
	LET cFechaPago = '';
	LET dFechaPago = '';
	LET cCuentaAbono = '';
	LET cNombrePf = '';
	LET cRazonSocial = '';
	LET mValorCambio = 0.0000;
	LET mMontoChequeUsd = 0.00;
	LET cNumeroCliente = '';
	LET cNombreRazon = '';
	LET iIdBitEjec = 0;
	
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
			IF iSqlErr <> 0 THEN
			
				IF ven_transacc = 1 THEN
					--ROLLBACK WORK;		
				END IF;
				
				SELECT DBINFO('utc_to_datetime', sh_curtime) INTO dFechaHoraFin	FROM sysmaster:sysshmvals;
				
				-- SE ACTUALIZA PROCESO (ERR)
				UPDATE bdiauditor:"informix".tblpld_bit_ejec
				SET estatus = 'ERR', fecha_hora_fin = dFechaHoraFin
				WHERE reporte = pReporte AND periodo = pPeriodo AND usuario = pUsuario AND fecha_hora_inicio = dFechaHoraInicio 
				AND procedimiento = 'sp_pld_chqc_crg_txt_geninf' AND movimiento = '1' AND nombre_archivo = cNombreArchivo AND estatus <> 'S';
			
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
					LET cCodRetSp = '001035';
					LET cDesCodRet = 'ERROR AL ACTUALIZAR EL ESTATUS DEL PROCESO EN LA TABLA tblpld_bit_ejec';
				END IF;
				
				LET cCodRetSp = '999999';
				LET cDesCodRet = 'ERROR NO CONTROLADO: sp_pld_chqc_crg_txt_geninf '|| DATE(CURRENT)||' '||iSqlErr||' '||cDescErr;
				
				UPDATE bdiauditor:"informix".tblpld_status_chqc
				SET status = 'E', error_spl = cCodRetSp, descripcion_error_spl = cDesCodRet, fecha_hora_fin = dFechaHoraFin
				WHERE nombre_archivo = cNombreArchivo AND procedimiento = 'sp_pld_chqc_crg_txt_geninf'
				AND usuario_insert = pUsuario AND fecha_hora_inicio = dFechaHoraInicio;
				
				LET cCodRet = '01036'; --OCURRIÓ UN ERROR DURANTE LA TRANSFORMACIÓN DE LA INFORMACIÓN. INTENTE NUEVAMENTE
				RETURN cCodRet;
				
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (688,-535,255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_pld_chqc_crg_txt_geninf.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pPeriodo = '' OR pReporte = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- ASIGNACIONES
		LET dFechaHoraInicio = CURRENT YEAR TO FRACTION(5);
		LET dFechaHoy = DATE(CURRENT);
		
		IF SUBSTR(pPeriodo,5,1) = '1' THEN
			LET cMes = '03';
		ELIF SUBSTR(pPeriodo,5,1) = '2' THEN
			LET cMes = '06';
		ELIF SUBSTR(pPeriodo,5,1) = '3' THEN
			LET cMes = '09';
		ELIF SUBSTR(pPeriodo,5,1) = '4' THEN
			LET cMes = '12';
		END IF;
		
		LET cAnio = SUBSTR(pPeriodo,1,4);
		LET cNombreArchivo = 'CHCAJA_'||cMes||cAnio||'.TXT';
		LET cNombreArchivo = TRIM(cNombreArchivo);
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO bdiauditor:"informix".tblpld_status_chqc(id_bit_ejec,nombre_archivo,status,procedimiento,error_spl,descripcion_error_spl,usuario_insert,fecha_hora_inicio,fecha_hora_fin)
		VALUES(null,cNombreArchivo,'I','sp_pld_chqc_crg_txt_geninf','','',pUsuario,dFechaHoraInicio,null);
				
		SET ISOLATION TO DIRTY READ;	
		SET LOCK MODE TO WAIT 3;
		
		-- SE REGISTRA PROCESO
		IF EXISTS (SELECT 1 FROM bdiauditor:"informix".tblpld_bit_ejec WHERE reporte = pReporte AND periodo = pPeriodo AND procedimiento = 'sp_pld_chqc_crg_txt_geninf') THEN
			
			INSERT INTO bdiauditor:"informix".tblpld_bit_ejec(reporte,periodo,usuario,fecha_hora_inicio,fecha_hora_fin,procedimiento,movimiento,nombre_archivo,estatus)
			VALUES(pReporte,pPeriodo,pUsuario,dFechaHoraInicio,null,'sp_pld_chqc_crg_txt_geninf','1',cNombreArchivo,'R');
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
			
				LET cCodRetSp = '001034';
				LET cDesCodRet = 'ERROR AL REGISTRAR EL PROCESO EN LA TABLA tblpld_bit_ejec';
				
				SELECT DBINFO('utc_to_datetime', sh_curtime) INTO dFechaHoraFin	FROM sysmaster:sysshmvals;
				
				UPDATE bdiauditor:"informix".tblpld_status_chqc
				SET status = 'E', error_spl = cCodRetSp, descripcion_error_spl = cDesCodRet, fecha_hora_fin = dFechaHoraFin
				WHERE nombre_archivo = cNombreArchivo AND procedimiento = 'sp_pld_chqc_crg_txt_geninf'
				AND usuario_insert = pUsuario AND fecha_hora_inicio = dFechaHoraInicio;
			
				LET cCodRet = '01036'; --OCURRIÓ UN ERROR DURANTE LA TRANSFORMACIÓN DE LA INFORMACIÓN. INTENTE NUEVAMENTE
				RETURN cCodRet;
		
			END IF;
			
		ELSE
			
			INSERT INTO bdiauditor:"informix".tblpld_bit_ejec(reporte,periodo,usuario,fecha_hora_inicio,fecha_hora_fin,procedimiento,movimiento,nombre_archivo,estatus)
			VALUES(pReporte,pPeriodo,pUsuario,dFechaHoraInicio,null,'sp_pld_chqc_crg_txt_geninf','1',cNombreArchivo,'P');
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			
				LET cCodRetSp = '001034';
				LET cDesCodRet = 'ERROR AL REGISTRAR EL PROCESO EN LA TABLA tblpld_bit_ejec';
				
				SELECT DBINFO('utc_to_datetime', sh_curtime) INTO dFechaHoraFin	FROM sysmaster:sysshmvals;
				
				UPDATE bdiauditor:"informix".tblpld_status_chqc
				SET status = 'E', error_spl = cCodRetSp, descripcion_error_spl = cDesCodRet, fecha_hora_fin = dFechaHoraFin
				WHERE nombre_archivo = cNombreArchivo AND procedimiento = 'sp_pld_chqc_crg_txt_geninf'
				AND usuario_insert = pUsuario AND fecha_hora_inicio = dFechaHoraInicio;
				
				LET cCodRet = '01036'; --OCURRIÓ UN ERROR DURANTE LA TRANSFORMACIÓN DE LA INFORMACIÓN. INTENTE NUEVAMENTE
				RETURN cCodRet;
				
			END IF;
			
		END IF;
		
		-- SE ACTUALIZA ID REGISTRO 
		SELECT id INTO iIdBitEjec
		FROM bdiauditor:"informix".tblpld_bit_ejec 
		WHERE reporte = pReporte AND periodo = pPeriodo	AND usuario = usuario 
		AND fecha_hora_inicio = dFechaHoraInicio AND procedimiento = 'sp_pld_chqc_crg_txt_geninf';

		UPDATE bdiauditor:"informix".tblpld_status_chqc SET id_bit_ejec = iIdBitEjec 
		WHERE nombre_archivo = cNombreArchivo AND procedimiento = 'sp_pld_chqc_crg_txt_geninf'
		AND usuario_insert = pUsuario AND fecha_hora_inicio = dFechaHoraInicio;
		
		-- SE VALIDA LA INFORMACIÓN DEL PERIODO CONSULTADO
		IF EXISTS(SELECT 1 FROM bdiauditor:"informix".tblpld_chqc_crg WHERE periodo = pPeriodo) THEN
		
			BEGIN;
				TRUNCATE TABLE bdiauditor:"informix".tblpld_chqc_txt;
			COMMIT;
			
		ELSE
		
			SELECT DBINFO('utc_to_datetime', sh_curtime) INTO dFechaHoraFin	FROM sysmaster:sysshmvals;
			
			-- SE ACTUALIZA PROCESO (ERR)
			UPDATE bdiauditor:"informix".tblpld_bit_ejec
			SET estatus = 'ERR', fecha_hora_fin = dFechaHoraFin
			WHERE reporte = pReporte AND periodo = pPeriodo AND usuario = pUsuario AND fecha_hora_inicio = dFechaHoraInicio 
			AND procedimiento = 'sp_pld_chqc_crg_txt_geninf' AND movimiento = '1' AND nombre_archivo = cNombreArchivo AND estatus <> 'S';
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
				LET cCodRetSp = '001035';
				LET cDesCodRet = 'ERROR AL ACTUALIZAR EL ESTATUS DEL PROCESO EN LA TABLA tblpld_bit_ejec';
			END IF;
				
			LET cCodRetSp = '000002';
			LET cDesCodRet = 'PROCESO DE TRANSFORMACIÓN NO INICIADO. EL TRIMESTRE NO HA CONCLUIDO PARA EL PERIODO SELECCIONADO';
			
			UPDATE bdiauditor:"informix".tblpld_status_chqc
			SET status = 'E', error_spl = cCodRetSp, descripcion_error_spl = cDesCodRet, fecha_hora_fin = dFechaHoraFin
			WHERE nombre_archivo = cNombreArchivo AND procedimiento = 'sp_pld_chqc_crg_txt_geninf'
			AND usuario_insert = pUsuario AND fecha_hora_inicio = dFechaHoraInicio;
			
			LET cCodRet = '01036'; --OCURRIÓ UN ERROR DURANTE LA TRANSFORMACIÓN DE LA INFORMACIÓN. INTENTE NUEVAMENTE
			RETURN cCodRet;
			
		END IF;
		
		-- SE CONSULTA EL NÚMERO TOTAL DE REGISTROS A TRANSFORMAR
		SELECT COUNT(*)
		INTO iTotalReg
		FROM bdiauditor:"informix".tblpld_chqc_crg
		WHERE periodo = pPeriodo;
		
		IF NVL(iTotalReg,0) = 0 THEN
		
			SELECT DBINFO('utc_to_datetime', sh_curtime) INTO dFechaHoraFin	FROM sysmaster:sysshmvals;
			
			-- SE ACTUALIZA PROCESO (ERR)
			UPDATE bdiauditor:"informix".tblpld_bit_ejec
			SET estatus = 'ERR', fecha_hora_fin = dFechaHoraFin
			WHERE reporte = pReporte AND periodo = pPeriodo AND usuario = pUsuario AND fecha_hora_inicio = dFechaHoraInicio 
			AND procedimiento = 'sp_pld_chqc_crg_txt_geninf' AND movimiento = '1' AND nombre_archivo = cNombreArchivo AND estatus <> 'S';
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
				LET cCodRetSp = '001035';
				LET cDesCodRet = 'ERROR AL ACTUALIZAR EL ESTATUS DEL PROCESO EN LA TABLA tblpld_bit_ejec';
			END IF;
				
			LET cCodRetSp = '001037';
			LET cDesCodRet = 'NO HAY REGISTROS POR PROCESAR PARA EL PERIODO INDICADO, VERIFIQUE';
			
			UPDATE bdiauditor:"informix".tblpld_status_chqc
			SET status = 'E', error_spl = cCodRetSp, descripcion_error_spl = cDesCodRet, fecha_hora_fin = dFechaHoraFin 
			WHERE nombre_archivo = cNombreArchivo AND procedimiento = 'sp_pld_chqc_crg_txt_geninf'
			AND usuario_insert = pUsuario AND fecha_hora_inicio = dFechaHoraInicio;
			
			LET cCodRet = '01036'; --OCURRIÓ UN ERROR DURANTE LA TRANSFORMACIÓN DE LA INFORMACIÓN. INTENTE NUEVAMENTE
			RETURN cCodRet;
		END IF;	
		
		BEGIN WORK;
			LET ven_transacc = 1;
		
			FOREACH WITH HOLD
				
				SELECT monto_cheque, fecha_oper, cuenta_abono, 
				TRIM(nombres_pf)||' '||TRIM(apell_parterno_pf)||' '||TRIM(apell_materno_pf) AS nombre_pf, razon_social_pm
				INTO mMontoCheque, cFechaPago, cCuentaAbono, cNombrePf, cRazonSocial
				FROM bdiauditor:"informix".tblpld_chqc_crg
				WHERE periodo = pPeriodo ORDER BY fecha_oper ASC
				
				LET dFechaPago = MDY(SUBSTR(TRIM(cFechaPago), 5, 2), SUBSTR(TRIM(cFechaPago), 7, 2), SUBSTR(TRIM(cFechaPago), 1, 4));
				
				SELECT precio
				INTO mValorCambio
				FROM bdiauditor:"informix".tipo_cambio
				WHERE fecha_tc = dFechaPago;
								  
				LET mMontoChequeUsd = mMontoCheque/mValorCambio;
				
				IF NVL(mMontoChequeUsd,0) >= 10000.00 THEN
				
					SELECT num_cte 
					INTO cNumeroCliente
					FROM bdicheq:"informix".sc_maechq
					WHERE cuenta = cCuentaAbono;
					
					IF NVL(cNombrePf,'') <> '' THEN
						LET cNombreRazon = TRIM(cNombrePf);
					ELSE
						LET cNombreRazon = TRIM(cRazonSocial);
					END IF;				
							
					LET iContCheque = iContCheque + 1;
					
					INSERT INTO bdiauditor:"informix".tblpld_chqc_txt(fecha,numero_cliente,numero_cuenta,nombre_razon,monto_usd,monto_mxn) 
					VALUES(cFechaPago,cNumeroCliente,cCuentaAbono,cNombreRazon,ROUND(mMontoChequeUsd),ROUND(mMontoCheque));
					
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					
						SELECT DBINFO('utc_to_datetime', sh_curtime) INTO dFechaHoraFin	FROM sysmaster:sysshmvals;
						
						-- SE ACTUALIZA PROCESO (ERR)
						UPDATE bdiauditor:"informix".tblpld_bit_ejec
						SET estatus = 'ERR', fecha_hora_fin = dFechaHoraFin
						WHERE reporte = pReporte AND periodo = pPeriodo AND usuario = pUsuario AND fecha_hora_inicio = dFechaHoraInicio 
						AND procedimiento = 'sp_pld_chqc_crg_txt_geninf' AND movimiento = '1' AND nombre_archivo = cNombreArchivo AND estatus <> 'S';
					
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
							LET cCodRetSp = '001035';
							LET cDesCodRet = 'ERROR AL ACTUALIZAR EL ESTATUS DEL PROCESO EN LA TABLA tblpld_bit_ejec';
						END IF;
				
						LET cCodRetSp = '000001';
						LET cDesCodRet = 'ERROR AL INSERTAR EN LA TABLA DESTINO: tblpld_chqc_txt '|| DATE(CURRENT);
						
						UPDATE bdiauditor:"informix".tblpld_status_chqc
						SET status = 'E', error_spl = cCodRetSp, descripcion_error_spl = cDesCodRet, fecha_hora_fin = dFechaHoraFin
						WHERE nombre_archivo = cNombreArchivo AND procedimiento = 'sp_pld_chqc_crg_txt_geninf'
						AND usuario_insert = pUsuario AND fecha_hora_inicio = dFechaHoraInicio;
						
						LET cCodRet = '01036'; --OCURRIÓ UN ERROR DURANTE LA TRANSFORMACIÓN DE LA INFORMACIÓN. INTENTE NUEVAMENTE
						RETURN cCodRet;
						
					ELSE
						
						LET iBloque = iBloque + 1;
						IF iBloque = 5000 THEN
							LET iBloque = 0;
							COMMIT WORK;
							BEGIN WORK;
						END IF;
						
					END IF;	
				
				END IF;
				
			END FOREACH;
		
		COMMIT WORK;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		SELECT DBINFO('utc_to_datetime', sh_curtime) INTO dFechaHoraFin	FROM sysmaster:sysshmvals;
		
		-- SE ACTUALIZA PROCESO
		UPDATE bdiauditor:"informix".tblpld_bit_ejec
		SET estatus = 'S', fecha_hora_fin = dFechaHoraFin
		WHERE reporte = pReporte AND periodo = pPeriodo AND usuario = pUsuario AND fecha_hora_inicio = dFechaHoraInicio 
		AND procedimiento = 'sp_pld_chqc_crg_txt_geninf' AND movimiento = '1' AND nombre_archivo = cNombreArchivo AND estatus <> 'S';
	
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
			LET cCodRetSp = '001035';
			LET cDesCodRet = 'ERROR AL ACTUALIZAR EL ESTATUS DEL PROCESO EN LA TABLA tblpld_bit_ejec';
		END IF;
		
		LET cCodRetSp = '000000';
		LET cDesCodRet = 'EL PROCESO DE TRANSFORMACIÓN CONCLUYÓ EXITOSAMENTE';
		
		UPDATE bdiauditor:"informix".tblpld_status_chqc
		SET status = 'T', error_spl = cCodRetSp, descripcion_error_spl = cDesCodRet, fecha_hora_fin = dFechaHoraFin
		WHERE nombre_archivo = cNombreArchivo AND procedimiento = 'sp_pld_chqc_crg_txt_geninf'
		AND usuario_insert = pUsuario AND fecha_hora_inicio = dFechaHoraInicio;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 16/02/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CHEQUES DE CAJA TXT',
'DESCRIPCION: Spl encargado de consultar la información de la tabla origen (bdiauditor:"informix".tblpld_chqc_crg),',
'para posteriormente ser transformada y guardada en la tabla destino (bdiauditor:"informix".tblpld_chqc_txt).',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_pld_chqc_crg_txt_catperiodo(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codret,
		CHAR(20) AS periodo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE dFechaHoy DATE;
	DEFINE iMes INT;
	DEFINE iAnio INT;
	DEFINE cTrimestreAnio CHAR(1);
	DEFINE cTrimestreActual CHAR(5);
	DEFINE cPeriodo CHAR(20);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET dFechaHoy = DATE(CURRENT);
	LET iMes = 0;
	LET iAnio = 0;
	LET cTrimestreAnio = '';
	LET cTrimestreActual = '';
	LET cPeriodo = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cPeriodo;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_pld_chqc_crg_txt_catperiodo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cPeriodo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- ASIGNACIONES
		LET iMes = MONTH(dFechaHoy);
		LET iAnio = YEAR(dFechaHoy);
		
		IF iMes IN (1,2,3) THEN
			LET cTrimestreAnio = '1';
		ELIF iMes IN (4,5,6) THEN
			LET cTrimestreAnio = '2';
		ELIF iMes IN (7,8,9) THEN
			LET cTrimestreAnio = '3';
		ELIF iMes IN (10,11,12) THEN
			LET cTrimestreAnio = '4';
		END IF;
		
		LET cTrimestreActual = iAnio||cTrimestreAnio;
		LET cTrimestreActual = TRIM(cTrimestreActual);
		
		FOREACH
			SELECT DISTINCT(TRIM(periodo))
			INTO cPeriodo
			FROM bdiauditor:"informix".tblpld_chqc_crg 
			WHERE periodo < cTrimestreActual ORDER BY 1 ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, TRIM(cPeriodo) WITH RESUME;	
		END FOREACH;
	
		IF NVL(iRecuperacion,0) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cPeriodo;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 15/02/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE TRIMESTRAL DE CHEQUES DE CAJA EN FORMATO TXT',
'DESCRIPCION: SPL encargado de consultar los periodos disponibles para la generación del reporte trimestral.',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_mindsdomicilio_diario()
RETURNING CHAR(6) AS cod_ret,
		  CHAR(80) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(80);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						CHAR(200);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_DOM 		VARCHAR(50);

--VARIABLE LAYOUT DOMICILIO
DEFINE v_idtipodomicilio		CHAR(1);
DEFINE v_idpais					CHAR(3);
DEFINE v_pais					CHAR(3);
DEFINE v_idestado				INTEGER;
DEFINE v_idplaza				INTEGER;
DEFINE v_idmunicipio 			INTEGER;
DEFINE v_ciudad					CHAR(3);
DEFINE v_calle					CHAR(30);
DEFINE v_numeroext				CHAR(10);
DEFINE v_numeroint				CHAR(10);
DEFINE v_colonia				CHAR(32);
DEFINE v_cp						CHAR(5);
DEFINE v_idestatuscargaminds	INTEGER;DEFINE v_fecharegistro			CHAR(10);
DEFINE v_estado					CHAR(2);
DEFINE v_fechaactualizacion		CHAR(10);
DEFINE v_nic 					CHAR(20);
DEFINE v_txtmunicipio 			CHAR(250);
DEFINE v_txtplaza				CHAR(250);
--VARIABLE DE PASO
DEFINE temp_fecharegistro		DATE;
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_ant				DATE;
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE vconteo					INTEGER;
DEFINE v_numcalle				INTEGER;

--SE INICIALIZAN VARIABLES
LET v_idestatuscargaminds = 0;
LET vcommit = 0;
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vconteo = 0;
LET v_numcalle = 0;
LET v_idmunicipio = 99999999;

BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
		IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
        LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_mindsdomicilio_diario en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_DOM,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_mindsdomicilio_diario');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/jarias/sp_mindscliente_his.out';
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET vpaso = 1;
	
	--OBTIENE LA FECHA DEL DIA ANTERIOR DE LA FECHA ACTUAL
	SELECT fecha_hoy, fecha_ant 
	INTO v_fecha_hoy, v_fecha_ant
	FROM bdinteg:si_fechas;
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_ant), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_ant), 2, '0');
	LET cAno = YEAR(v_fecha_ant);
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO	 	 = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA_DOM	 = 'CargaDomMinds_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	---Borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".tbl_domicilio_minds;
	COMMIT;
	
	LET vpaso = 4;
	
	
	FOREACH WITH HOLD 
		SELECT sda.numcte,sda.tipo_dir,sda.pais,sda.estado,sda.ciudad,sda.numeroextcalle,sda.numerointcalle,scz.nombrezona,
		sda.cod_postal,sda.fecha_insert,sda.numerocalle
		INTO v_nic,v_idtipodomicilio,v_pais,v_estado,v_ciudad,v_numeroext,v_numeroint,v_colonia,v_cp,temp_fecharegistro,v_numcalle
		FROM bdinteg:si_direcciones_actual sda,
			bdinteg:si_cliente clie,
			bdinteg:si_catzonas scz
			--bdinteg:si_catcalles scc
		WHERE sda.fecha_insert = v_fecha_ant
		AND clie.numcte = sda.numcte
		AND clie.tipo_cliente = '1'
		AND sda.numerocolonia = scz.numerocolonia
		AND sda.numerociudad = scz.numerociudad 
		--AND sda.numerocalle = scc.numerocalle
		
		
		LET vpaso = 5;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		LET vpaso = 6;
		
		SELECT scc.nombrecalle
		INTO v_calle
		From bdinteg:si_catcalles scc
		where numerocalle = v_numcalle;
		
		SELECT clave_pais
		INTO v_idpais
		FROM bdinteg:si_paises
		WHERE pais = v_pais;
		
		IF (v_idpais IS NULL) OR (v_idpais = '') THEN
			LET v_idpais = 'ZZ';
		END IF
		
		LET vpaso = 7;
		
		SELECT estado 
		INTO v_idestado
		FROM bdinteg:si_estados 
		WHERE estado = v_estado;
		
		IF (v_idestado < 1) OR (v_idestado > 32) OR (v_idestado IS NULL) THEN
			LET v_idestado = 99999999;
		END IF
		
		LET vpaso = 8;
		
		SELECT nombre,localidad_banxico
		INTO v_txtmunicipio,v_idplaza
		FROM bdinteg:si_ciudades 
		WHERE ciudad = v_ciudad AND estado = v_estado;
		
		LET v_txtplaza = v_txtmunicipio;
		
		/*
		IF (v_idmunicipio = 0) OR (v_idmunicipio IS NULL) OR (v_idmunicipio = '') THEN
			LET v_idmunicipio = 99999999;
		END IF
		*/
		
		IF (v_idplaza = 48407017) THEN 
			LET v_idplaza = 717009; 
		ELIF (v_idplaza = 48415013) THEN
			LET v_idplaza = 1738007; 
		ELIF (v_idplaza = 48415106) THEN
			LET v_idplaza = 1808002; 
		ELIF (v_idplaza = 48415109) THEN
			LET v_idplaza = 1811008; 
		ELIF (v_idplaza = 48415120) THEN
			LET v_idplaza = 1811008; 
		ELIF (v_idplaza = 48419048) THEN
			LET v_idplaza = 2349009; 
		ELIF (v_idplaza = 48421094) THEN
			LET v_idplaza = 3094009; 
		ELIF (v_idplaza = 48426029) THEN
			LET v_idplaza = 3799003; 
		ELIF (v_idplaza = 0) OR (v_idplaza IS NULL) OR (v_idplaza = '') THEN
			LET v_idplaza = 99999999;
		END IF
		
		IF (v_cp = '') OR (v_cp IS NULL) OR (v_cp IN ('0','00','00000','CP563','MZ69','O','S-CP4')) THEN
			LET v_cp = '99999';
		END IF
		
		LET v_calle 	= REPLACE(v_calle,'|','');
		LET v_numeroext = REPLACE(v_numeroext,'|','');
		LET v_numeroint = REPLACE(v_numeroint,'|','');
		LET v_colonia 	= REPLACE(v_colonia,'|','');

		LET v_fechaactualizacion = to_char(temp_fecharegistro, '%Y-%m-%d');
		LET v_fecharegistro = to_char(temp_fecharegistro, '%Y-%m-%d');
		LET vconteo = vconteo + 1;
		LET vpaso = 9;
		
		--INSERTA LOS VALORES EN LOS PARAMETROS DE LA TABLA DE PASO.
		INSERT INTO "informix".tbl_domicilio_minds (idregistro,idtipodomicilio,idpais,idestado,idmunicipio,idplaza,nic,calle,numeroext,numeroint,colonia,cp,idestatuscargaminds,fechaactualizacion,txtmunicipio,txtplaza,fecharegistro)
		VALUES (vconteo,v_idtipodomicilio,v_idpais,v_idestado,v_idmunicipio,v_idplaza,v_nic,v_calle,v_numeroext,v_numeroint,v_colonia,v_cp,v_idestatuscargaminds,v_fechaactualizacion,v_txtmunicipio,v_txtplaza,v_fecharegistro);
		
		LET vpaso = 10;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			let vcommit = 0;			
		END IF	
		
	END FOREACH;
	
	LET vpaso = 11;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF	
	
	LET vpaso = 12;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE DOMICILIOS
	LET vsql = '';
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_DOM||'.txt select * FROM bdiauditor:tbl_domicilio_minds;">'||RUTA_DESTINO||TIPO_PLANTILLA_DOM||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 13;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_DOM||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_DOM||'_01.sql';
	system vsql;
	
	LET vpaso = 14;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_DOM||'_01.sql';
	system vsql; 
	
	LET vpaso = 15;
	LET cod_ret = '000000';
    LET vmensaje = 'PROCESO EXITOSO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_DOM);
	
	INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_mindsdomicilio_diario');
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE
DOCUMENT 'AUTOR: Jorge Luis Arias Nu#ez',
'FECHA: 22/08/2019',
'DESCRIPCION: GeneraciÃ³n de informaciÃ³n domicilios para sistemas MINDS PLD',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_mindsfigrelacionada_diario()
RETURNING CHAR(6) AS cod_ret,
		  CHAR(80) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(80);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						CHAR(200);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_FIGRELACIONADA	VARCHAR(50);

--VARIABLE LAYOUT FIGURA RELACIONADA
DEFINE v_idactividadeconomica	CHAR(10);
DEFINE v_idtipopersona			INTEGER;
DEFINE v_idsexo					CHAR(1);
DEFINE v_idparentesco			CHAR(20);
DEFINE v_idpaisnacimiento		CHAR(3);
DEFINE v_nic					CHAR(20);
DEFINE v_porcentaje				DECIMAL(14,2);
DEFINE v_nocuenta				CHAR(20);
DEFINE v_fechanacimiento		CHAR(10);
DEFINE v_nombre					CHAR(60);
DEFINE v_apaterno				CHAR(26);
DEFINE v_amaterno 				CHAR(26);
DEFINE v_idestado				CHAR(8);
DEFINE v_idestadonacimiento		INTEGER;
DEFINE v_idplaza				INTEGER;
DEFINE v_calle					CHAR(30);
DEFINE v_numeroext				CHAR(10);
DEFINE v_numeroint				CHAR(10);
DEFINE v_colonia				CHAR(32);
DEFINE v_cp						CHAR(5);
DEFINE v_nic_figura				CHAR(2);
DEFINE v_fecharegistro			CHAR(10);
DEFINE v_estatus				INTEGER;
DEFINE v_idestatuscargaminds	INTEGER;
DEFINE v_idtipofiguralegal		CHAR(1);
DEFINE v_idmunicipio 			CHAR(8);
DEFINE v_idnacionalidad			CHAR(3);
DEFINE v_rfc					CHAR(13);
DEFINE v_curp					CHAR(20);
DEFINE v_email					CHAR(50);
DEFINE v_idpaisnacionalidad		CHAR(3);
DEFINE v_trust_contribution		CHAR(1);
DEFINE v_fechaactualizacion		CHAR(10);
DEFINE v_idpaisasignacionfiscal	CHAR(3);
DEFINE v_id_act					INTEGER;
DEFINE v_id_subact  			INTEGER;
DEFINE v_id_secuencia			INTEGER;

--VARIABLES DE PASO
DEFINE temp_fechafechanacimiento DATE;
DEFINE temp_fecharegistro		DATE;
DEFINE nombrepf1 				CHAR(26);
DEFINE nombrepf2 				CHAR(26);
DEFINE nombrepm 				CHAR(60);
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_ant				DATE;
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE vconteo					INTEGER;
DEFINE v_estado					CHAR(2);
DEFINE v_clave_pais				CHAR(3);
DEFINE v_ciudad					CHAR(3);

--SE INICIALIZAN VARIABLES
LET v_idestatuscargaminds = 0;
LET vcommit = 0;
LET v_estatus = 1;
LET v_nic_figura = '01';
LET v_idtipofiguralegal = ' ';
LET v_idmunicipio = '99999999';
LET v_trust_contribution = '0';
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vconteo = 0;
LET v_idpaisasignacionfiscal = 'MX';


BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_mindsfigrelacionada_diario en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_FIGRELACIONADA,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_mindsfigrelacionada_diario');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/jarias/sp_mindsfigrelacionada_diario.out';
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET vpaso = 1;
	
	--OBTIENE LA FECHA DEL DIA ANTERIOR DE LA FECHA ACTUAL
	SELECT fecha_hoy, fecha_ant 
	INTO v_fecha_hoy, v_fecha_ant
	FROM bdinteg:si_fechas;
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_ant), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_ant), 2, '0');
	LET cAno = YEAR(v_fecha_ant);
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO	 			  = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA_FIGRELACIONADA = 'CargaFigRelMinds_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	---Borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".tbl_figrelacionada_minds;
	COMMIT;
	
	LET vpaso = 4;
	
	FOREACH WITH HOLD--SOLO BENEFICIARIOS
		SELECT ben.parentesco,ben.numcte,ben.porcentaje,ben.cuenta,noc.fecha_alta
		INTO v_idparentesco,v_nic,v_porcentaje,v_nocuenta,temp_fecharegistro
		FROM bdicheq:sc_beneficiario ben, bdicheq:sc_maenoc noc, bdinteg:si_cliente cli
		WHERE ben.cuenta = noc.cuenta 
		AND ben.numcte = cli.numcte
		AND cli.tipo_cliente = '1'
		AND noc.fecha_alta = v_fecha_ant
		
		LET vpaso = 5;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		LET vpaso = 6;
		
		SELECT tpo_persona,nombre1,nombre2,razon_social,apell_paterno,apell_materno,rfc
		INTO v_idtipopersona,nombrepf1,nombrepf2,nombrepm,v_apaterno,v_amaterno,v_rfc
		FROM bdinteg:si_cliente 
		WHERE numcte = v_nic;
		
		IF v_idtipopersona IN(1,3) THEN --PERSONA FISICA
			
			LET vpaso = 7;
			
			
			SELECT fecha_nac,sexo,lugar_nac,nacionalidad,curp,id_pais
			INTO temp_fechafechanacimiento,v_idsexo,v_estado,v_idnacionalidad,v_curp,v_clave_pais
			FROM bdinteg:si_ctepf 
			WHERE numcte = v_nic;
			
			IF v_idsexo = 'F' THEN
				LET v_idsexo = '2';
			ELIF v_idsexo = 'M' THEN
				LET v_idsexo = '1';
			END IF
						
			-- ACTIVIDAD ECONOMICA
			SELECT MAX(id_secuencia)
			INTO v_id_secuencia
			FROM bdinteg:si_bitacoraapertura
			WHERE numcte = v_nic
			AND id_pregunta = 6;
			
			IF v_id_secuencia IS NULL THEN
				LET v_id_secuencia = 0;
			END IF
			
			SELECT FIRST 1 id_act, id_subact
			INTO v_id_act, v_id_subact
			FROM bdinteg:si_bitacoraapertura
			WHERE numcte = v_nic
			AND id_pregunta = 6
			AND id_secuencia = v_id_secuencia;
			
			SELECT idcnbv
			INTO v_idactividadeconomica
			FROM bdinteg:si_actsubact
			WHERE id_act = v_id_act
			AND id_subact = v_id_subact;
			
			IF (v_idactividadeconomica = '0000000') OR (v_idactividadeconomica IS NULL) OR (v_idactividadeconomica = '') THEN
			LET v_idactividadeconomica = '9999999';
		END IF
			
			LET vpaso = 8;
			
			SELECT estado 
			INTO v_idestadonacimiento
			FROM bdinteg:si_estados
			WHERE estado = v_estado;
			
			IF (v_idestadonacimiento < 1) OR (v_idestadonacimiento > 32) OR (v_idestadonacimiento IS NULL) THEN
				LET v_idestadonacimiento = 99999999;
			END IF
			
			LET v_nombre = TRIM(nombrepf1) || " " || TRIM(nombrepf2);
			LET v_fechanacimiento = to_char(temp_fechafechanacimiento, '%Y-%m-%d');
			
			IF (v_idparentesco IS NULL or v_idparentesco = '0' or v_idparentesco = '01' or v_idparentesco = 'S' 
			or v_idparentesco = 'O' or v_idparentesco = 'M' or v_idparentesco = 'K' or v_idparentesco = '') THEN
			LET v_idparentesco = '1';
		    ELIF (v_idparentesco = 'A' ) THEN
		    	LET v_idparentesco = '2';
		    ELIF (v_idparentesco = 'B' ) THEN
		    	LET v_idparentesco = '11';
		    ELIF (v_idparentesco = 'C' ) THEN
		    	LET v_idparentesco = '12';
		    ELIF (v_idparentesco = 'E' ) THEN
		    	LET v_idparentesco = '10';
		    ELIF (v_idparentesco = 'H' ) THEN
		    	LET v_idparentesco = '6';
		    ELIF (v_idparentesco = 'I' ) THEN
		    	LET v_idparentesco = '13';
		    ELIF (v_idparentesco = 'J' ) THEN
		    	LET v_idparentesco = '5';
		    ELIF (v_idparentesco = 'N' ) THEN
		    	LET v_idparentesco = '7';
		    ELIF (v_idparentesco = 'R' ) THEN
		    	LET v_idparentesco = '9';
		    ELIF (v_idparentesco = 'T' ) THEN
		    	LET v_idparentesco = '8';
		    ELIF (v_idparentesco = 'U' ) THEN
		    	LET v_idparentesco = '14';
		    ELIF (v_idparentesco = 'P' and v_idsexo = '1' ) THEN
		    	LET v_idparentesco = '3';
		    ELIF (v_idparentesco = 'P' and v_idsexo = '2' ) THEN
		    	LET v_idparentesco = '4';
		    END IF
			
			LET vpaso = 9;
			
			SELECT clave_pais
			INTO v_idpaisnacimiento
			FROM bdinteg:si_paises
			WHERE clave_pais = v_clave_pais;
			
			IF (v_idpaisnacimiento IS NULL) OR (v_idpaisnacimiento = '') THEN
				LET v_idpaisnacimiento = 'ZZ';
			END IF
			
			LET v_idpaisnacionalidad = v_idpaisnacimiento;			
			LET vpaso = 10;
			
			SELECT FIRST 1 {+INDEX(bdinteg:si_correos idx_corr_cte_cons)} correo_elec
			INTO v_email
			FROM bdinteg:si_correos
			WHERE status_correo = 'A' 
			AND tipo_correo = '1'
			AND numcte = v_nic;
			
			LET vpaso = 11;
			
		ELIF v_idtipopersona IN(2,4,5) THEN --PERSONA MORAL
			
			LET vpaso = 12;
			
			SELECT fecha_constitct,nacionalidad,emailpm
			INTO temp_fechafechanacimiento,v_idnacionalidad,v_email
			FROM bdinteg:si_ctepm 
			WHERE numcte = v_nic;
			
			LET v_nombre = TRIM(nombrepm);
			LET v_apaterno = NULL;
			LET v_amaterno = NULL;
			LET v_fechanacimiento = to_char(temp_fechafechanacimiento, '%Y-%m-%d');
			LET v_idsexo = '3';
			LET v_idpaisnacimiento = 'ZZ';
			LET v_idpaisnacionalidad = 'ZZ';
			LET v_idestadonacimiento = 99999999;
			LET v_curp = NULL;
			
			LET vpaso = 13;
			
		END IF
		
		LET vpaso = 14;
		
		IF v_fechanacimiento < '1900-01-01' THEN
			LET v_fechanacimiento = '1900-01-01';
		END IF
		
		IF v_idnacionalidad = '001' THEN
			LET v_idnacionalidad = '1';		ELSE
			LET v_idnacionalidad = '2';		END IF
		
		LET v_fechaactualizacion = to_char(temp_fecharegistro, '%Y-%m-%d');
		LET v_fecharegistro = to_char(temp_fecharegistro, '%Y-%m-%d');
		
		LET vpaso = 15;
		
		SELECT FIRST 1 sda.ciudad,scc.nombrecalle, sda.numeroextcalle, sda.numerointcalle,scz.nombrezona,sda.cod_postal,sda.estado
		INTO v_ciudad,v_calle,v_numeroext,v_numeroint,v_colonia,v_cp,v_estado
		FROM bdinteg:si_direcciones_actual sda, 
			bdinteg:si_catzonas scz, 
			bdinteg:si_catcalles scc
		WHERE sda.numcte = v_nic
		AND sda.numerocolonia = scz.numerocolonia
		AND sda.numerociudad = scz.numerociudad 
		AND sda.numerocalle = scc.numerocalle
		AND sda.tipo_dir = '1';
		
		LET vpaso = 16;
		
		SELECT estado 
		INTO v_idestado
		FROM bdinteg:si_estados 
		WHERE estado = v_estado;
		
		IF (v_idestado < 1) OR (v_idestado > 32) OR (v_idestado IS NULL) THEN
			LET v_idestado = 99999999;
		END IF
		
		LET vpaso = 17;
		
		SELECT localidad_banxico 
		INTO v_idplaza
		FROM bdinteg:si_ciudades 
		WHERE ciudad = v_ciudad AND estado = v_estado;
		
		-- MAPEO DE PLAZAS QUE NO SE ENCUENTRAN EN EL CATALOGO DE MINDS
		-- CUMPLIMIENTO PROPORCIONO EL SIGUIENTE MAPEO
		IF (v_idplaza = 48407017) THEN 
			LET v_idplaza = 717009; 
		ELIF (v_idplaza = 48415013) THEN
			LET v_idplaza = 1738007; 
		ELIF (v_idplaza = 48415106) THEN
			LET v_idplaza = 1808002; 
		ELIF (v_idplaza = 48415109) THEN
			LET v_idplaza = 1811008; 
		ELIF (v_idplaza = 48415120) THEN
			LET v_idplaza = 1811008; 
		ELIF (v_idplaza = 48419048) THEN
			LET v_idplaza = 2349009; 
		ELIF (v_idplaza = 48421094) THEN
			LET v_idplaza = 3094009; 
		ELIF (v_idplaza = 48426029) THEN
			LET v_idplaza = 3799003; 
		ELIF (v_idplaza = 0) OR (v_idplaza IS NULL) OR (v_idplaza = '') THEN
			LET v_idplaza = 99999999;
		END IF
		
		IF (v_cp = '') OR (v_cp IS NULL) OR (v_cp IN ('0','00','00000','CP563','MZ69','O','S-CP4')) THEN
			LET v_cp = '99999';
		END IF
		
		LET vpaso = 18;
		
		LET v_nombre 	= REPLACE(v_nombre,'|','');
		LET v_apaterno 	= REPLACE(v_apaterno,'|','');
		LET v_amaterno 	= REPLACE(v_amaterno,'|','');
		LET v_rfc 		= REPLACE(v_rfc,'|','');
		LET v_curp 		= REPLACE(v_curp,'|','');
		LET v_calle 	= REPLACE(v_calle,'|','');
		LET v_numeroext = REPLACE(v_numeroext,'|','');
		LET v_numeroint = REPLACE(v_numeroint,'|','');
		LET v_colonia 	= REPLACE(v_colonia,'|','');
		LET v_cp 		= REPLACE(v_cp,'|','');
		LET v_email 	= REPLACE(v_email,'|','');
		LET vconteo = vconteo + 1;
		
		LET vpaso = 19;
		
		IF v_idtipopersona = 1 THEN -- PERSONA FISICA
			LET v_idtipopersona = 2;
		ELIF v_idtipopersona IN (2, 4, 5) THEN -- PERSONA MORAL
			LET v_idtipopersona = 1;
		END IF
		
		LET vpaso = 20;
		
		INSERT INTO "informix".tbl_figrelacionada_minds (idregistro,idactividadeconomica,idtipopersona,idsexo,idtipofiguralegal,idparentesco,idpais,idpaisnacimiento,idestado,idestadonacimiento,idmunicipio,idplaza,idnacionalidad,nic,nombre,apellidopaterno,apellidomaterno,fechanacimiento,rfc,curp,calle,
														numeroext,numeroint,colonia,cp,email,porcentaje,estatus,idpaisnacionalidad,trust_contribution,fechaactualizacion,idestatuscargaminds,nocuenta,nic_figura,idpaisasignacionfiscal,fecharegistro)
		VALUES (vconteo,v_idactividadeconomica,v_idtipopersona,v_idsexo,v_idtipofiguralegal,v_idparentesco,v_idpaisnacimiento,v_idpaisnacimiento,v_idestado,v_idestadonacimiento,v_idmunicipio,v_idplaza,v_idnacionalidad,v_nic,v_nombre,v_apaterno,v_amaterno,v_fechanacimiento,v_rfc,v_curp,v_calle,
				v_numeroext,v_numeroint,v_colonia,v_cp,v_email,v_porcentaje,v_estatus,v_idpaisnacionalidad,v_trust_contribution,v_fechaactualizacion,v_idestatuscargaminds,v_nocuenta,v_nic_figura,v_idpaisasignacionfiscal,v_fecharegistro);	
		
		LET vpaso = 20;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;			
		END IF
	END FOREACH
	
	LET vpaso = 21;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 22;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE CUENTAS
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_FIGRELACIONADA||'.txt select * FROM bdiauditor:tbl_figrelacionada_minds;">'||RUTA_DESTINO||TIPO_PLANTILLA_FIGRELACIONADA||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 23;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_FIGRELACIONADA||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_FIGRELACIONADA||'_01.sql';
	system vsql;
	
	LET vpaso = 24;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_FIGRELACIONADA||'_01.sql';
	system vsql;
	
	LET vpaso = 25;
	LET cod_ret = '000000';
    LET vmensaje = 'PROCESO EXITOSO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_FIGRELACIONADA);
	
	INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_mindsfigrelacionada_diario');
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE;