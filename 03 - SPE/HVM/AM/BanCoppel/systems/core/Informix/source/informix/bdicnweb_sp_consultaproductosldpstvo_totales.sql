CREATE PROCEDURE "informix".sp_consultaproductosldpstvo_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pClave_Producto CHAR (4),  pFecha_Inicio DATE, pFecha_Fin DATE)
		RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr    
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaproductosldpstvo_totaleses.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pClave_Producto = ''   THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
			
		-- Por Producto
		IF pClave_Producto <> '0000' THEN
		
			IF pFecha_Inicio IS NOT NULL AND pFecha_Fin IS NOT NULL THEN
			
				SELECT count(*)
				INTO iNoRegistros	
				FROM bdicheq:"informix".sc_conciliachqglob
				WHERE producto = pClave_Producto 
				AND fecha >= pFecha_Inicio AND fecha <= pFecha_Fin;
					RETURN cCodRet, iNoRegistros;
							
			ELSE
					SELECT count(*)
					INTO iNoRegistros
					FROM bdicheq:"informix".sc_conciliachqglob
					WHERE producto = pClave_Producto;
				RETURN cCodRet, iNoRegistros;
			END IF;
			
		ELIF pClave_Producto = '0000' THEN
		
		    IF pFecha_Inicio IS NULL OR pFecha_Fin IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iNoRegistros;
			END IF;
			
				SELECT count(*)
				INTO iNoRegistros
				FROM bdicheq:"informix".sc_conciliachqglob
				WHERE fecha >= pFecha_Inicio AND fecha <= pFecha_Fin;	

				RETURN cCodRet, iNoRegistros;
					
		END IF;		
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;
		END IF;
	
	END;
	
END PROCEDURE

DOCUMENT 'AUTOR: Ing Guadalupe Angelica Hernandez Perez  ',
'FECHA: 07/08/2015',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD: PRODUCTOS CON SALDO POSITIVO',
'DESCRIPCION: Consultar total de Productos con Saldo Positivo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultausuarioscedulasccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaCcl DATE,  pTipo SMALLINT)
		RETURNING CHAR(5) AS codret,
		CHAR(104) AS nombre, 
		SMALLINT AS funcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombre CHAR(104);
    DEFINE sfuncion SMALLINT;
    DEFINE iNoRegistros INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cNombre = '';
    LET sfuncion  = 0;
	LET iNoRegistros = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombre, sfuncion;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consultausuarioscedulasccl.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaCcl = '' OR pTipo IS NULL  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombre, sfuncion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombre, sfuncion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		FOREACH
			EXECUTE PROCEDURE bdicnweb:'informix'.sp_usuarioscedulas(pFechaCcl, pTipo )
			INTO cCodRetSp,  cNombre, sfuncion		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicnweb:sp_usuarioscedulas ";
			ELIF cCodRetSp::INTEGER = 110  THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 100  THEN
				LET cCodRet = '00017';
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, UPPER(TRIM(cNombre)), sfuncion WITH RESUME;		
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNombre, sfuncion;
		END IF;		
		END;		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 05/10/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: CONCILIACIÓN SALDOS CAPTACIÓN',
'DESCRIPCION:SPL que consulta los usuarios para la administracion de  pantallas de cedulas contables',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreportecedulasccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaCcl DATE,  pTipo SMALLINT, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(40) AS nombre, 
		CHAR(14) AS cta_contable, 
		DECIMAL(16,2) AS saldo_cheques, 
		DECIMAL(16,2) AS saldo_contable, 
		DECIMAL(16,2) AS diferencia_saldo, 
		CHAR(255)  AS observaciones;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombre CHAR(40);
    DEFINE cCtaContable CHAR(14);
    DEFINE dSdoCheques DECIMAL(16,2);
    DEFINE dSdoContab DECIMAL(16,2);
    DEFINE dDifSaldos DECIMAL(16,2);
    DEFINE cObservaciones CHAR(255);
	DEFINE iNoRegistros INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cNombre = '';
    LET cCtaContable = '';
    LET dSdoCheques = 0.00;
    LET dSdoContab = 0.00;
    LET dDifSaldos = 0.00;
    LET cObservaciones = '';
	LET iNoRegistros = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombre,cCtaContable,dSdoCheques,dSdoContab,dDifSaldos,cObservaciones;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_genreportecedulasccl.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaCcl = '' OR pTipo IS NULL  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombre,cCtaContable,dSdoCheques,dSdoContab,dDifSaldos,cObservaciones;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombre,cCtaContable,dSdoCheques,dSdoContab,dDifSaldos,cObservaciones;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		FOREACH
			EXECUTE PROCEDURE bdicnweb:'informix'.sp_imprimecedulas(pFechaCcl, pTipo )
			INTO cCodRetSp, cNombre,cCtaContable,dSdoCheques,dSdoContab,dDifSaldos,cObservaciones
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicnweb:sp_imprimecedulas ";
			ELIF cCodRetSp::INTEGER = 110  THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 100  THEN
				LET cCodRet = '00017';
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, UPPER(TRIM(cNombre)),cCtaContable,dSdoCheques,dSdoContab,dDifSaldos,UPPER(TRIM(cObservaciones)) WITH RESUME;		
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNombre,cCtaContable,dSdoCheques,dSdoContab,dDifSaldos,cObservaciones;
		END IF;		
		END;		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 06/10/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD:CONCILIACIÓN SALDOS CAPTACIÓN',
'DESCRIPCION:SPL que genera el reporte de Conciliación de Saldos de Captación, Conciliación de Saldos de Intereses, Conciliación de Saldos (Sobregiros) y Conciliación de Saldos Pagaré ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_registractualizacelulasccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pEmpleado CHAR(8), pNombre CHAR(104), pStatus CHAR(1), pFuncion SMALLINT, pCedula SMALLINT,  pTipo SMALLINT, pFuncionAnt SMALLINT, pCedulaAnt SMALLINT, pStatusAnt SMALLINT)
		RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET pNombre = UPPER(TRIM(pNombre));

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_registractualizacelulasccl.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEmpleado = '' OR pNombre = '' OR pStatus = '' OR pFuncion IS NULL OR  pCedula IS NULL OR  pTipo  IS NULL OR pFuncionAnt IS NULL OR pCedulaAnt IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		
		EXECUTE PROCEDURE bdicnweb:'informix'.sp_usuarioscedulasmantto(pEmpleado, pNombre, pStatus, pFuncion, pCedula, pTipo, pFuncionAnt, pCedulaAnt, pStatusAnt)
		INTO cCodRetSp;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
		RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicnweb:sp_usuarioscedulasmantto ";
		ELIF cCodRetSp::INTEGER = 110  THEN
			LET cCodRet = '00582';
		ELIF cCodRetSp::INTEGER = 200  THEN
			LET cCodRet = '00004';
		END IF;
		LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet;		
		END;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;				
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 05/10/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: CATALOGO FIRMAS CEDULA CONTABLE',
'DESCRIPCION:SPL para registrar o actualizar los usuarios de la revisión de las Cedulas Contables',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_notificar_evento_impresora(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoError INT, pPlantilla CHAR(25), pTituloPlantilla CHAR(255))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dFechaMail DATE;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET dFechaMail = NULL;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_notificar_evento_impresora.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoError IS NULL OR pPlantilla = '' OR pTituloPlantilla = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		LET dFechaMail = current;
		EXECUTE FUNCTION bdimnsj:"informix".sp_registra_evento
			('1'
			, TRIM(pPlantilla)
			, TRIM(pPlantilla)			
			, pUsuario
			, ''
			, ''
			, '1'
			, pTipoError
			, ''
			, ''
			, ''
			, ''
			, ''
			, ''
			, ''
			, ''
			, TRIM(pTituloPlantilla)
			, ''
			, ''
			, '0'
			, '0'
			, '0'
			, '0'
			, '0'
			, dFechaMail
			, dFechaMail) INTO cCodRet;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 07/08/2015',
'MODULO: KIOSKO DE INFORMACION',
'FUNCIONALIDAD: Impresion de saldos/movimientos',
'DESCRIPCION: Envio de correo electronico para la notificacion en fallo de la impresora termina',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consulta_desactualizadas_buro(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha CHAR(4), pStatus CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(2)  AS duplicada,
				  CHAR(3)  AS nivel_desactualizada,
				  CHAR(10) AS member_code,
				  CHAR(2)  AS member_kob,
				  CHAR(20) AS num_credito,
				  CHAR(8)  AS fecha_reporte,
				  CHAR(10) AS id_expediente,
				  CHAR(20) AS rfc,
				  CHAR(30) AS apellido_paterno,
				  CHAR(30) AS apellido_materno,
				  CHAR(30) AS apellido_adicional,
				  CHAR(30) AS primer_nombre,
				  CHAR(30) AS segundo_nombre,
				  CHAR(8)  AS fecha_apertura,
				  CHAR(2)  AS tipo_contrato,
				  CHAR(1)  AS tipo_cuenta,
				  CHAR(20) AS limite_credito,
				  CHAR(128)  AS historico_pago,
				  CHAR(20) AS id_interno,
				  CHAR(10) AS clave_observacion,
				  CHAR(2)  AS forma_pago,
				  CHAR(20) AS saldo_actual,
				  CHAR(20) AS saldo_vencido,
				  CHAR(20) AS importe_pago,
				  CHAR(8)  AS fecha_cierre,
				  CHAR(18) AS saldo_actual_1,
				  CHAR(18) AS saldo_vencido_1,
				  CHAR(18) AS importe_pago_1,
				  CHAR(2)  AS forma_pago_1,
				  CHAR(2)  AS clave_observa_1,
				  CHAR(20) AS num_credito_ext;			
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE cDuplicada CHAR(2);
	DEFINE cNivelDesactualizada CHAR(3);
	DEFINE cMemberCode CHAR(10);
	DEFINE cMemberKob CHAR(2);
	DEFINE cNumCredito CHAR(20);
	DEFINE cFechaReporte CHAR(8);
	DEFINE cIdExpediente CHAR(10);
	DEFINE cRfc CHAR(20);
	DEFINE cApellidoPaterno CHAR(30);
	DEFINE cApellidoMaterno CHAR(30);
	DEFINE cApellidoAdicional CHAR(30);
	DEFINE cPrimerNombre CHAR(30);
	DEFINE cSegundoNombre CHAR(30);
	DEFINE cFechaApertura CHAR(8);
	DEFINE cTipoContrato CHAR(2);
	DEFINE cTipoCuenta CHAR(1);
	DEFINE cLimiteCredito CHAR(20);
	DEFINE cHistoricoPago CHAR(128);
	DEFINE cIdInterno CHAR(20) ;
	DEFINE cClaveObservacion CHAR(10);
	DEFINE cFormaPago CHAR(2);
	DEFINE cSaldoActual CHAR(20);
	DEFINE cSaldoVencido CHAR(20);
	DEFINE cImportePago CHAR(20);
	DEFINE cFechaCierre CHAR(8);
	DEFINE cSaldoActual1 CHAR(18);
	DEFINE cSaldoVencido1 CHAR(18);
	DEFINE cImportePago1 CHAR(18);
	DEFINE cFormaPago1 CHAR(2);
	DEFINE cClaveObserva1 CHAR(2);
	DEFINE cNumCreditoExt CHAR(20);
	
	DEFINE iRecuperacion INTEGER;	
	DEFINE cMemberKobAux CHAR(2);
	DEFINE cNumCreditoAux CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET cDuplicada = '';
	LET cNivelDesactualizada = '';
	LET cMemberCode = '';
	LET cMemberKob = '';
	LET cNumCredito = '';
	LET cFechaReporte = '';
	LET cIdExpediente = '';
	LET cRfc = '';
	LET cApellidoPaterno = '';
	LET cApellidoMaterno = '';
	LET cApellidoAdicional = '';
	LET cPrimerNombre = '';
	LET cSegundoNombre = '';
	LET cFechaApertura = '';
	LET cTipoContrato = '';
	LET cTipoCuenta = '';
	LET cLimiteCredito = '';
	LET cHistoricoPago = '';
	LET cIdInterno = '';
	LET cClaveObservacion = '';
	LET cFormaPago = '';
	LET cSaldoActual = '';
	LET cSaldoVencido = '';
	LET cImportePago = '';
	LET cFechaCierre = '';
	LET cSaldoActual1 = '';
	LET cSaldoVencido1 = '';
	LET cImportePago1 = '';
	LET cFormaPago1 = '';
	LET cClaveObserva1 = '';
	LET cNumCreditoExt = '';
	
	LET cMemberKobAux = '';
	LET cNumCreditoAux = '';
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cDuplicada,cNivelDesactualizada,cMemberCode,cMemberKob,cNumCredito,cFechaReporte,cIdExpediente,
				   cRfc,cApellidoPaterno,cApellidoMaterno,cApellidoAdicional,cPrimerNombre,cSegundoNombre,cFechaApertura,
				   cTipoContrato,cTipoCuenta,cLimiteCredito,cHistoricoPago,cIdInterno,cClaveObservacion,cFormaPago,
				   cSaldoActual,cSaldoVencido,cImportePago,cFechaCierre,cSaldoActual1,cSaldoVencido1,cImportePago1,
				   cFormaPago1,cClaveObserva1,cNumCreditoExt;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_desactualizadas_buro.out';
		--TRACE ON;
		
		---VALIDACIÃN DE DATOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' OR pStatus = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cDuplicada,cNivelDesactualizada,cMemberCode,cMemberKob,cNumCredito,cFechaReporte,cIdExpediente,
				   cRfc,cApellidoPaterno,cApellidoMaterno,cApellidoAdicional,cPrimerNombre,cSegundoNombre,cFechaApertura,
				   cTipoContrato,cTipoCuenta,cLimiteCredito,cHistoricoPago,cIdInterno,cClaveObservacion,cFormaPago,
				   cSaldoActual,cSaldoVencido,cImportePago,cFechaCierre,cSaldoActual1,cSaldoVencido1,cImportePago1,
				   cFormaPago1,cClaveObserva1,cNumCreditoExt;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cDuplicada,cNivelDesactualizada,cMemberCode,cMemberKob,cNumCredito,cFechaReporte,cIdExpediente,
				   cRfc,cApellidoPaterno,cApellidoMaterno,cApellidoAdicional,cPrimerNombre,cSegundoNombre,cFechaApertura,
				   cTipoContrato,cTipoCuenta,cLimiteCredito,cHistoricoPago,cIdInterno,cClaveObservacion,cFormaPago,
				   cSaldoActual,cSaldoVencido,cImportePago,cFechaCierre,cSaldoActual1,cSaldoVencido1,cImportePago1,
				   cFormaPago1,cClaveObserva1,cNumCreditoExt;
		END IF;
		
		---VALIDACIÃN DE TIPO DE OPERACIÃN
		IF pStatus NOT IN ('1', '2') THEN
			LET cCodRet = '00102';
			RETURN cCodRet,cDuplicada,cNivelDesactualizada,cMemberCode,cMemberKob,cNumCredito,cFechaReporte,cIdExpediente,
				   cRfc,cApellidoPaterno,cApellidoMaterno,cApellidoAdicional,cPrimerNombre,cSegundoNombre,cFechaApertura,
				   cTipoContrato,cTipoCuenta,cLimiteCredito,cHistoricoPago,cIdInterno,cClaveObservacion,cFormaPago,
				   cSaldoActual,cSaldoVencido,cImportePago,cFechaCierre,cSaldoActual1,cSaldoVencido1,cImportePago1,
				   cFormaPago1,cClaveObserva1,cNumCreditoExt;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cDuplicada,cNivelDesactualizada,cMemberCode,cMemberKob,cNumCredito,cFechaReporte,cIdExpediente,
				   cRfc,cApellidoPaterno,cApellidoMaterno,cApellidoAdicional,cPrimerNombre,cSegundoNombre,cFechaApertura,
				   cTipoContrato,cTipoCuenta,cLimiteCredito,cHistoricoPago,cIdInterno,cClaveObservacion,cFormaPago,
				   cSaldoActual,cSaldoVencido,cImportePago,cFechaCierre,cSaldoActual1,cSaldoVencido1,cImportePago1,
				   cFormaPago1,cClaveObserva1,cNumCreditoExt;
		END IF;
		
		IF pStatus = '1' THEN ---Consulta cuentas desactualizadas en tabla temporal sd_desactualizadas_temp
			FOREACH SELECT skip pRegistros FIRST pRecuperacion duplicada, nivel_desactualizada, member_code, member_kob, num_credito,
							   fecha_reporte, id_expediente, rfc, apellido_paterno, apellido_materno, apellido_adicional, primer_nombre,
							   segundo_nombre, fecha_apertura, tipo_contrato, tipo_cuenta, limite_credito, historico_pago, id_interno, 
							   clave_observacion, forma_pago, saldo_actual, saldo_vencido, importe_pago
						INTO cDuplicada,cNivelDesactualizada,cMemberCode,cMemberKob,cNumCredito,cFechaReporte,cIdExpediente,
							 cRfc,cApellidoPaterno,cApellidoMaterno,cApellidoAdicional,cPrimerNombre,cSegundoNombre,cFechaApertura,
							 cTipoContrato,cTipoCuenta,cLimiteCredito,cHistoricoPago,cIdInterno,cClaveObservacion,cFormaPago,
							 cSaldoActual,cSaldoVencido,cImportePago
						FROM bdicred:'informix'.sd_desactualizadas_temp
									
				LET iRecuperacion = iRecuperacion + 1;
				
				RETURN cCodRet,cDuplicada,cNivelDesactualizada,cMemberCode,cMemberKob,cNumCredito,cFechaReporte,cIdExpediente,
					   cRfc,cApellidoPaterno,cApellidoMaterno,cApellidoAdicional,cPrimerNombre,cSegundoNombre,cFechaApertura,
					   cTipoContrato,cTipoCuenta,cLimiteCredito,cHistoricoPago,cIdInterno,cClaveObservacion,cFormaPago,
					   cSaldoActual,cSaldoVencido,cImportePago,cFechaCierre,cSaldoActual1,cSaldoVencido1,cImportePago1,
					   cFormaPago1,cClaveObserva1,cNumCreditoExt WITH RESUME;
					   
			END FOREACH;
			
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet,cDuplicada,cNivelDesactualizada,cMemberCode,cMemberKob,cNumCredito,cFechaReporte,cIdExpediente,
					   cRfc,cApellidoPaterno,cApellidoMaterno,cApellidoAdicional,cPrimerNombre,cSegundoNombre,cFechaApertura,
					   cTipoContrato,cTipoCuenta,cLimiteCredito,cHistoricoPago,cIdInterno,cClaveObservacion,cFormaPago,
					   cSaldoActual,cSaldoVencido,cImportePago,cFechaCierre,cSaldoActual1,cSaldoVencido1,cImportePago1,
					   cFormaPago1,cClaveObserva1,cNumCreditoExt;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,cDuplicada,cNivelDesactualizada,cMemberCode,cMemberKob,cNumCredito,cFechaReporte,cIdExpediente,
					   cRfc,cApellidoPaterno,cApellidoMaterno,cApellidoAdicional,cPrimerNombre,cSegundoNombre,cFechaApertura,
					   cTipoContrato,cTipoCuenta,cLimiteCredito,cHistoricoPago,cIdInterno,cClaveObservacion,cFormaPago,
					   cSaldoActual,cSaldoVencido,cImportePago,cFechaCierre,cSaldoActual1,cSaldoVencido1,cImportePago1,
					   cFormaPago1,cClaveObserva1,cNumCreditoExt;
			END IF;
				   
		ELIF pStatus = '2' THEN ---Consulta cuentas desactualizadas en tabla maestra sd_desactualizadas_buro
			
			FOREACH SELECT skip pRegistros FIRST pRecuperacion duplicada, nivel_desactualizada, member_code, member_kob, num_credito,
							   fecha_reporte, id_expediente, rfc, apellido_paterno, apellido_materno, apellido_adicional, primer_nombre,
							   segundo_nombre, fecha_apertura, tipo_contrato, tipo_cuenta, limite_credito, historico_pago, id_interno, 
							   clave_observacion, forma_pago, saldo_actual, saldo_vencido, importe_pago, fecha_cierre, saldo_actual_1,
							   saldo_vencido_1, importe_pago_1,forma_pago_1, clave_observa_1, num_credito_ext
						INTO cDuplicada,cNivelDesactualizada,cMemberCode,cMemberKob,cNumCredito,cFechaReporte,cIdExpediente,
							 cRfc,cApellidoPaterno,cApellidoMaterno,cApellidoAdicional,cPrimerNombre,cSegundoNombre,cFechaApertura,
							 cTipoContrato,cTipoCuenta,cLimiteCredito,cHistoricoPago,cIdInterno,cClaveObservacion,cFormaPago,
							 cSaldoActual,cSaldoVencido,cImportePago,cFechaCierre,cSaldoActual1,cSaldoVencido1,cImportePago1,
					         cFormaPago1,cClaveObserva1,cNumCreditoExt
						FROM bdicred:'informix'.sd_desactualizadas_buro
						WHERE fecha_proceso = TRIM(pFecha)
									
				LET iRecuperacion = iRecuperacion + 1;
				
				RETURN cCodRet,cDuplicada,cNivelDesactualizada,cMemberCode,cMemberKob,cNumCredito,cFechaReporte,cIdExpediente,
					   cRfc,cApellidoPaterno,cApellidoMaterno,cApellidoAdicional,cPrimerNombre,cSegundoNombre,cFechaApertura,
					   cTipoContrato,cTipoCuenta,cLimiteCredito,cHistoricoPago,cIdInterno,cClaveObservacion,cFormaPago,
					   cSaldoActual,cSaldoVencido,cImportePago,cFechaCierre,cSaldoActual1,cSaldoVencido1,cImportePago1,
					   cFormaPago1,cClaveObserva1,cNumCreditoExt WITH RESUME;
					   
			END FOREACH;
			
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet,cDuplicada,cNivelDesactualizada,cMemberCode,cMemberKob,cNumCredito,cFechaReporte,cIdExpediente,
					   cRfc,cApellidoPaterno,cApellidoMaterno,cApellidoAdicional,cPrimerNombre,cSegundoNombre,cFechaApertura,
					   cTipoContrato,cTipoCuenta,cLimiteCredito,cHistoricoPago,cIdInterno,cClaveObservacion,cFormaPago,
					   cSaldoActual,cSaldoVencido,cImportePago,cFechaCierre,cSaldoActual1,cSaldoVencido1,cImportePago1,
					   cFormaPago1,cClaveObserva1,cNumCreditoExt;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,cDuplicada,cNivelDesactualizada,cMemberCode,cMemberKob,cNumCredito,cFechaReporte,cIdExpediente,
					   cRfc,cApellidoPaterno,cApellidoMaterno,cApellidoAdicional,cPrimerNombre,cSegundoNombre,cFechaApertura,
					   cTipoContrato,cTipoCuenta,cLimiteCredito,cHistoricoPago,cIdInterno,cClaveObservacion,cFormaPago,
					   cSaldoActual,cSaldoVencido,cImportePago,cFechaCierre,cSaldoActual1,cSaldoVencido1,cImportePago1,
					   cFormaPago1,cClaveObserva1,cNumCreditoExt;
			END IF;
		
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 01/12/2015',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: Cuentas Desactualizadas de BurÃ³ de CrÃ©dito',
'DESCRIPCION: Genera reporte para contestacion a burÃ³ de crÃ©dito',
'pStatus:  1. Consulta registros a la tabla sd_desactualizadas_temp',
'          2. Consulta registros a la tabla sd_desactualizadas_buro',
'FECHA: 25/02/2016',
'DESCRIPCION: Se modifica tamaÃ±o de columna historico_pago de 8 a 80 caracteres',
'FECHA: 08/03/2016',
'DESCRIPCION: Se modifica tamaÃ±o de columna historico_pago de 80 a 128 caracteres',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultafechasrep_desactualizadasbc(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(10) AS fecha;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cFecha CHAR(10);
	DEFINE iNoRegistros INT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cFecha = '';
	LET iNoRegistros = 0;
	
	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cFecha;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultafechasrep_desactualizadasbc.out';
		--TRACE ON;
		
		---VALIDACIÃN DE DATOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cFecha;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cFecha;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
		FOREACH SELECT DISTINCT fecha_proceso
				INTO cFecha
				FROM bdicred:'informix'.sd_desactualizadas_buro
				ORDER BY 1
				
				LET iNoRegistros = iNoRegistros + 1;
				
				RETURN cCodRet,cFecha WITH RESUME;				
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cFecha;
		END IF;	
		
	END;

END PROCEDURE
DOCUMENT "AUTOR: Rodolfo Conde Flores",
"FECHA: 01/12/2015",
'MODULO: CrÃ©dito',
'FUNCIONALIDAD: Consulta Cuentas Desactualizadas de BurÃ³ de CrÃ©dito',
"DESCRIPCIÃN: Consulta fechas de proceso de las cuentas cargadas a tabla maesta sd_desactualizadas_buro",
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_desactualizadasbc_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha CHAR(4), pStatus CHAR(1))
		RETURNING CHAR(5) AS codret,
				  INT  AS total_registros;			
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_desactualizadasbc_totales.out';
		--TRACE ON;
		
		---VALIDACIÃN DE DATOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' OR pStatus = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
				
		---VALIDACIÃN DE TIPO DE OPERACIÃN
		IF pStatus NOT IN ('1', '2', '3') THEN
			LET cCodRet = '00102';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		IF pStatus = '1' THEN ---Consulta totales cuentas desactualizadas en tabla temporal sd_desactualizadas_temp

			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
		
			SELECT COUNT(*)	INTO iNoRegistros
			FROM bdicred:'informix'.sd_desactualizadas_temp;
						
			RETURN cCodRet,iNoRegistros;
				   
		ELIF pStatus = '2' THEN ---Consulta totales cuentas desactualizadas en tabla maestra sd_desactualizadas_buro
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			SELECT COUNT(*)	INTO iNoRegistros
			FROM bdicred:'informix'.sd_desactualizadas_buro
			WHERE fecha_proceso = TRIM(pFecha);
			
			RETURN cCodRet,iNoRegistros;

		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 01/12/2015',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: Cuentas Desactualizadas de BurÃ³ de CrÃ©dito',
'DESCRIPCION: Obtiene total de registros de un archivo cargado',
'pStatus:  1. Consulta totales registros a la tabla sd_desactualizadas_temp',
'          2. Consulta totales registros a la tabla sd_desactualizadas_buro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_eliminadesactualizadasbc(pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha CHAR(4), pOpcion CHAR(1))
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
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_eliminadesactualizadasbc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' OR pOpcion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION OPERACION
		IF pOpcion NOT IN ('1', '2') THEN
			LET cCodRet = '00102';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		IF pOpcion = '1' THEN---Se eliminan registros cargados a tabla maestra
		
			SET LOCK MODE TO WAIT 3; 
			DELETE FROM bdicred:'informix'.sd_desactualizadas_temp;
			
			SET LOCK MODE TO WAIT 3;
			DELETE FROM bdicred:'informix'.sd_desactualizadas_buro
			WHERE fecha_proceso = TRIM(pFecha);
			
			RETURN cCodRet;
		
		ELIF pOpcion = '2' THEN ---Se eliminan registros cargados a tabla temporal
			
			SET LOCK MODE TO WAIT 3;
			DELETE FROM bdicred:'informix'.sd_desactualizadas_temp;
			
			RETURN cCodRet;
			
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Rodolfo Conde Flores",
"FECHA: 01/12/2015",
'MODULO: CrÃ©dito',
'FUNCIONALIDAD: Cuentas Desactualizadas de BurÃ³ de CrÃ©dito',
"DESCRIPCIÃN: Elimina registros previamente cargados si el usuario en funcionalidad elige  sobreescribir los datos",
"	pOpcion = 1 - usuario no genero reporte ",
"	pOpcion = 2 - usuario sobre escribe informacion",
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validacarga_desactualizadasbc(pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha CHAR(4))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS archivo_encontrado;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEncontrado CHAR(1);
	DEFINE iNoRegistros INT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEncontrado = '0';
	LET iNoRegistros = 0;
	
	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cEncontrado;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_validacarga_desactualizadasbc.out';
		--TRACE ON;
		
		---VALIDACIÃN DE DATOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cEncontrado;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cEncontrado;
		END IF;
		
		---VERIFICA SI HAY REGISTROS CARGADOS
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*)	INTO iNoRegistros
		FROM bdicred:'informix'.sd_desactualizadas_buro
		WHERE fecha_proceso = TRIM(pFecha) ;
		
		IF iNoRegistros > 0 THEN
			LET cEncontrado = '1';
		END IF;
		
		RETURN cCodRet,cEncontrado;
		
	END;

END PROCEDURE
DOCUMENT "AUTOR: Rodolfo Conde Flores",
"FECHA: 01/12/2015",
'MODULO: CrÃ©dito',
'FUNCIONALIDAD: Cuentas Desactualizadas de BurÃ³ de CrÃ©dito',
"DESCRIPCIÃN: Verifica si ya se ha cargado el archivo previamente",
"	          Retorna cEncontrado = 0 si no se ha encontrado el archivo",
"	          Retorna cEncontrado = 1 si se ha encontrado el archivo",
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_ro_bloqueactacre(pIdUsuario CHAR(8),
													pIdFunciON CHAR(10),
													pIdOficio INT,
													pIdBusqueda INT,
													pIdCliente INT,
													pNumCliente CHAR(20),
													pNumCuenta CHAR(20),
													pCveBloqueo INT,
													pCveCausa CHAR(2),
													pTipo INT,
													pIp CHAR(15),
													pMac CHAR(12),
													pOficios CHAR(1),
													pAreaPersonaSolicita CHAR(150),
													pMotivoBloqueo CHAR(150))
        RETURNING CHAR(5) AS cod_ret,
                        CHAR(16) AS folio_operacion

                DEFINE cCodRetSp CHAR(6);
        DEFINE cCodRet CHAR(5);
        DEFINE cMensajeRet CHAR(16);
        DEFINE iSqlErr INT;
        DEFINE cEmpresa CHAR(3);
        DEFINE cSistemaCta CHAR(2);
        DEFINE cFolioMask CHAR(16);
        DEFINE iLenFolio INT;
        DEFINE cDescCausa CHAR(40);
        DEFINE iRegsAfectados INT;
        LET cEmpresa = '001';
        LET cCodRet = '00000';
        LET cCodRetSp = '';
        LET cMensajeRet = '0000000000000000';
        LET cSistemaCta = '06';
        LET iSqlErr = 0;
        LET iLenFolio = 0;
        LET cFolioMask = '0000000000000000';
        LET cDescCausa = '';
        LET iRegsAfectados = 0;

        BEGIN
                        ON EXCEPTION SET iSqlErr
                                        IF iSqlErr <> 0 THEN
                                                        LET cCodRet = iSqlErr;
                                                        RETURN cCodRet, cMensajeRet;
                                        END IF;
                        END EXCEPTION;

                        --SET DEBUG FILE TO '/tmp/mfinis/sp_sw_ro_bloqueactacre.out';
                        --TRACE ON;

                        IF pIdUsuario = '' OR pIdFunciON = '' OR pNumCliente = '' OR pNumCuenta = '' OR pOficios = '' OR
								pAreaPersonaSolicita = '' OR pMotivoBloqueo = '' THEN
                                        LET cCodRet = '00003';
                                        RETURN cCodRet, cMensajeRet;
                        END IF;

                        -- Validaciones del tipo de operaciÃ³n
                        -- 1=Manual, 2=Masivo
                        IF pTipo is NULL OR pTipo NOT IN(1,2) THEN
                                        LET cCodRet = '00005';
                                        RETURN cCodRet, cMensajeRet;
                        END IF;
                        --VALIDACION PERMISO
                        EXECUTE PROCEDURE bdinteg:sp_cnsif_permisosejecutivo(pIdUsuario, pIdFuncion, pNumCuenta, cSistemaCta, '1') INTO cCodRet;
                        IF cCodRet <> '00000' THEN
                                        RETURN cCodRet, cMensajeRet;
                        END IF;
						
                        EXECUTE PROCEDURE bdicred:sp_bloqueocuenta(cEmpresa, pNumCuenta, pCveBloqueo, pCveCausa, pIdUsuario, pTipo) INTO cCodRetSp, cMensajeRet;
						--EXECUTE PROCEDURE bdicred:sp_bloqueocuenta(cEmpresa, pNumCuenta, pCveBloqueo, pCveCausa, pIdUsuario, pTipo, pAreaPersonaSolicita, pMotivoBloqueo) INTO cCodRetSp, cMensajeRet;
                        IF cCodRetSp = '000001' THEN
                                        LET cCodRet = '00003'; -- Faltan parametros de entrada
                                        RETURN cCodRet, cMensajeRet;
                        END IF;
                        IF cCodRetSp = '000006' THEN
                                        LET cCodRet = '00106'; -- El tipo de bloqueo no es vÃ¡lido
                                        RETURN cCodRet, cMensajeRet;
                        END IF;
                        IF cCodRetSp = '000007' THEN
                                        LET cCodRet = '00041'; -- El numero de cuenta no existe
                                        RETURN cCodRet, cMensajeRet;
                        END IF;
                        IF cCodRetSp = '000008' THEN
                                        LET cCodRet = '00018'; -- Credito bloqueado manualmente
                                        RETURN cCodRet, cMensajeRet;
                        END IF;
                        IF cCodRetSp = '000009' THEN
                                        LET cCodRet = '00019'; -- El credito ya ha sido bloqueado
                                        RETURN cCodRet, cMensajeRet;
                        END IF;
                        IF cCodRetSp = '000012' THEN
                                        LET cCodRet = '00104'; -- La cuenta esta cancelada
                                        RETURN cCodRet, cMensajeRet;
                        END IF;
                        IF cCodRetSp = '000010' THEN
                                        LET cCodRet = '00033'; -- La cuenta esta en cartera vendida
                                        RETURN cCodRet, cMensajeRet;
                        END IF;

                        IF pOficios <> '1' THEN
                                IF cCodRetSp in ('000000', '000011') THEN
                                        RETURN cCodRet, cMensajeRet;
                                END IF;
                        ELSE
                                IF cCodRetSp in ('000000', '000011')  THEN
                                                LET cCodRet = '00000'; -- Bloqueo exitoso
                                                --GERNERAMOS EL FOLIO
                                                INSERT INTO sw_ro_foliador(folio_operacion) VALUES(0);
                                                LET cMensajeRet = dbinfo('bigserial');
                                                LET iLenFolio = LENGTH(cMensajeRet);
                                                LET cMensajeRet = SUBSTR(cFolioMask, 0, (LENGTH(cFolioMask) - iLenFolio)) || cMensajeRet;
                                                IF pOficios = '1' THEN
                                                                SET ISOLATION TO DIRTY READ;
                                                                SELECT causa_bloq
                                                                INTO cDescCausa
                                                                FROM bdicred:sd_causa_bloqueo
                                                                WHERE cod_causa = pCveCausa;
                                                                EXECUTE PROCEDURE sp_sw_ro_guardabloqueoctas(pIdUsuario,
                                                                                                                                                        pIdFuncion,
                                                                                                                                                        pIdOficio,
                                                                                                                                                        pIdBusqueda,
                                                                                                                                                        pIdCliente,
                                                                                                                                                        pTipo,
                                                                                                                                                        pNumCliente,
                                                                                                                                                        cSistemaCta,
                                                                                                                                                        pNumCuenta,
                                                                                                                                                        0.0,
                                                                                                                                                        pCveCausa,
                                                                                                                                                        cDescCausa,
                                                                                                                                                        cMensajeRet,
                                                                                                                                                        pIp,
                                                                                                                                                        pMac)
                                                                                INTO cCodRetSp, iRegsAfectados;
                                                                IF cCodRetSp <> '00000' THEN
                                                                                RETURN cCodRetSp, iRegsAfectados;
                                                                END IF;
                                                                RETURN cCodRet, cMensajeRet;
                                                END IF;
                                                RETURN cCodRet, cMensajeRet;
                                END IF;
                        END IF;
        END
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 10/02/2015',
'DESCRIPCION: Se agregan el area que solicita el bloqueo y la el motivo de bloqueo (justificaciÃ³n)';

CREATE PROCEDURE "informix".sp_consultaencabezadoxml(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER)
		RETURNING CHAR(5) AS codret,
			INTEGER AS folio,
			CHAR(4) AS anio_oficio,
			CHAR(60) AS num_oficio,
			CHAR(60) AS num_expediente,
			DATE AS fecha_publicacion,
			CHAR(100) AS area,
			SMALLINT AS dias_plazo,
			DATE AS fecha_vencimiento;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iFolio INTEGER;
	DEFINE cAnioOficio CHAR(4);
	DEFINE cNumOficio CHAR(60);
	DEFINE cNumExpediente CHAR(60);
	DEFINE dFechaPublicacion DATE;
	DEFINE cArea CHAR(100);
	DEFINE iDiasPlazo SMALLINT;
	DEFINE dFechaVencimiento DATE;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iFolio = 0;
	LET cAnioOficio = '';
	LET cNumOficio = '';
	LET cNumExpediente = '';
	LET dFechaPublicacion = NULL;
	LET cArea = '';
	LET iDiasPlazo = 0;
	LET dFechaVencimiento = NULL;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iFolio, cAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, iDiasPlazo, dFechaVencimiento;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaencabezadoxml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iFolio, cAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, iDiasPlazo, dFechaVencimiento;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iFolio, cAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, iDiasPlazo, dFechaVencimiento;
		END IF;
		
		SELECT folio, anio_oficio, num_oficio, num_expediente
			, MDY(SUBSTR(fecha_publicacion, 6, 2), SUBSTR(fecha_publicacion, 9, 2), SUBSTR(fecha_publicacion, 1, 4)) as fecha_publicacion
			, c.desc_tipooficio as area
			, a.dias_plazo
			, EXTEND(MDY(SUBSTR(fecha_publicacion, 6, 2), SUBSTR(fecha_publicacion, 9, 2), SUBSTR(fecha_publicacion, 1, 4)), YEAR TO DAY) + dias_plazo::INTEGER UNITS DAY as fecha_vencimiento
		INTO iFolio, cAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, iDiasPlazo, dFechaVencimiento
		FROM (bdicnweb:"informix".sw_ro_encabezadoexparchxml a INNER JOIN bdicnweb:"informix".sw_ro_maeoficios b ON b.id_oficio = a.id_oficio)
			LEFT JOIN bdicnweb:"informix".sw_ro_tipooficios c ON c.id_tipooficio = b.id_tipooficio
		WHERE a.id_expediente = pIdExpediente;
		
		RETURN cCodRet, iFolio, cAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, iDiasPlazo, dFechaVencimiento;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 29/12/2015',
'MODULO: CONTESTACION A OFICIOS',
'FUNCIONALIDAD: Reporte de status de oficios',
'DESCRIPCION: Consulta los datos del encabezado del oficio que se iran en los reportes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_buscarpersonas_xml(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER, pIpUsuario CHAR(15), pMac CHAR(12), pIdPlantilla CHAR(25), pTituloPlantilla char(255))
		RETURNING CHAR(5) AS codret,
				INTEGER AS id_oficio,
				INTEGER AS total_solic_partes,
				INTEGER AS total_solic_cuentas,
				INTEGER AS total_solic_especificas;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cNumOficio CHAR(60);
	DEFINE cNumExpediente CHAR(60);
	DEFINE iTipoOficio INTEGER;
	DEFINE iInst1Enlace INTEGER;
	DEFINE iInst2Enlace INTEGER;
	DEFINE dFechaRecepcion DATE;
	DEFINE dFechaOficio DATE;
	DEFINE iIdOficio INTEGER;
	DEFINE iTipoOperacion INTEGER;
	
	DEFINE cNombre1 CHAR(60);
	DEFINE cNombre2 CHAR(26);
	DEFINE cApPaterno CHAR(26);
	DEFINE cApMaterno CHAR(26);
	DEFINE cRfc CHAR(15);
	DEFINE sTipoPersona SMALLINT;
	DEFINE iNoRegistrosSolicPartes INTEGER;
	DEFINE iNoRegistrosSolicCuentas INTEGER;
	DEFINE iNoRegistrosSolicEspecificas INTEGER;
	DEFINE sTipoBusqueda SMALLINT;
	DEFINE dFechaNacimiento DATE;
	DEFINE cDescripcionArea CHAR(30);
	DEFINE cNombreAutoridad CHAR(60);
	
	-- Argumentos de salida del SPL de busqueda de personas
	DEFINE cSpNumeroCliente CHAR(20);
	DEFINE cSpRfc CHAR(15);
	DEFINE cSpNombre1 CHAR(26);
	DEFINE cSpNombre2 CHAR(26);
	DEFINE cSpApPaterno CHAR(26);
	DEFINE cSpApMaterno CHAR(26);
	DEFINE cSpRazonSocial CHAR(60);
	DEFINE cSpNoCuenta CHAR(20);
	DEFINE cSpNoTarjeta CHAR(20);
	DEFINE cSpTipoPersona CHAR(2);
	DEFINE cSpTipoCliente CHAR(1);
	DEFINE iSpStatus INT;
	DEFINE cSpDescStatusBusqueda CHAR(20);
	DEFINE cSpIndOmitido CHAR(1);
	DEFINE cSpIndBloqueocta CHAR(1);
	DEFINE cSpIndTerminado CHAR(1);
	DEFINE iSpIdBusqueda INT;
	DEFINE iSpIdResulcte INT;
	DEFINE cSpTipoCuenta CHAR(2);
	DEFINE cSpIndRfc CHAR(1);
	DEFINE cSpIndDir_empleo CHAR(1);
	DEFINE cSpIndDomicilio CHAR(1);
	DEFINE cSpIndNacionalidad CHAR(1);
	DEFINE iIdSolicitudEspecifica INTEGER;
	DEFINE iIdPersona INTEGER;
	DEFINE dHoy DATETIME YEAR TO FRACTION(3);
	
	DEFINE iIdxPersona INTEGER;
	DEFINE iIdxSolicitudEspecifica INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cNumOficio = '';
	LET cNumExpediente = '';
	LET iTipoOficio = 1; -- POR DEFAULT ES LA CNBV
	LET iInst1Enlace = 0;
	LET iInst2Enlace = 0;
	LET dFechaRecepcion = NULL;
	LET dFechaOficio = NULL;
	LET iIdOficio = 0;
	LET iTipoOperacion = 0; 
	LET cDescripcionArea = '';
	LET cNombreAutoridad = '';
	
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cApPaterno = '';
	LET cApMaterno = '';
	LET cRfc = '';
	LET sTipoPersona = 0;
	LET iNoRegistrosSolicPartes = 0;
	LET iNoRegistrosSolicCuentas = 0;
	LET iNoRegistrosSolicEspecificas = 0;
	LET sTipoBusqueda = 0;
	LET dFechaNacimiento = '';
	
	-- Argumentos de salida del SPL de busqueda de personas
	LET cSpNumeroCliente = '';
	LET cSpRfc = '';
	LET cSpNombre1 = '';
	LET cSpNombre2 = '';
	LET cSpApPaterno = '';
	LET cSpApMaterno = '';
	LET cSpRazonSocial = '';
	LET cSpNoCuenta = '';
	LET cSpNoTarjeta = '';
	LET cSpTipoPersona = '';
	LET cSpTipoCliente = '';
	LET iSpStatus = 0;
	LET cSpDescStatusBusqueda = '';
	LET cSpIndOmitido = '';
	LET cSpIndBloqueocta = '';
	LET cSpIndTerminado = '';
	LET iSpIdBusqueda = 0;
	LET iSpIdResulcte = 0;
	LET cSpTipoCuenta = '';
	LET cSpIndRfc = '';
	LET cSpIndDir_empleo = '';
	LET cSpIndDomicilio = '';
	LET cSpIndNacionalidad = '';
	LET iIdSolicitudEspecifica = 0;
	LET iIdPersona = 0;
	
	LET iIdxPersona = 0;
	LET iIdxSolicitudEspecifica = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdOficio, iNoRegistrosSolicPartes, iNoRegistrosSolicCuentas, iNoRegistrosSolicEspecificas;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_buscarpersonas_xml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL OR pIpUsuario = '' OR pMac = '' OR pIdPlantilla = '' OR pTituloPlantilla = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdOficio, iNoRegistrosSolicPartes, iNoRegistrosSolicCuentas, iNoRegistrosSolicEspecificas;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdOficio, iNoRegistrosSolicPartes, iNoRegistrosSolicCuentas, iNoRegistrosSolicEspecificas;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		-- BUSQUEDA DEL INDICE DE LA INSTITUCION ENLACE (INSTITUCION 1ER NIVEL)
		SELECT id_institucion1n
		INTO iInst1Enlace
		FROM bdicnweb:"informix".sw_ro_insenlace1nivel
		WHERE LOWER(REPLACE(TRIM(desc_i1n_nombrecorto), '.', '')) = LOWER(REPLACE('CNBV', '.', ''));
		
		-- BUSQUEDA DEL TIPO DE OFICIO
		SELECT desc_area
		INTO cDescripcionArea
		FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml
		WHERE id_expediente = pIdExpediente;
		
		SELECT id_tipooficio
		INTO iTipoOficio
		FROM (SELECT id_tipooficio, INSTR(TRIM(desc_tipooficio), TRIM(cDescripcionArea)) as exist
				FROM bdicnweb:"informix".sw_ro_tipooficios
				WHERE status = '1')
		WHERE exist > 0;
		
		IF iTipoOficio IS NULL THEN
			LET iTipoOficio = 1;
		END IF;
		
		-- BUSQUEDA DEL INDICE DE LA INSTITUCION SOLICITANTE (INSTITUCION 2DO NIVEL)
		SELECT nombre_autoridad
		INTO cNombreAutoridad
		FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml
		WHERE id_expediente = pIdExpediente;
		
		SELECT id_institucion2n
		INTO iInst2Enlace
		FROM (SELECT id_institucion2n,
			INSTR(LOWER(REPLACE(TRIM(cNombreAutoridad), '.', '')), TRIM(LOWER(desc_i2n_nombrecorto))) AS exist
			FROM bdicnweb:"informix".sw_ro_inssolic2nivel
			WHERE status = '1')
		WHERE exist > 0;
		
		SELECT MDY(SUBSTR(fecha_publicacion, 6, 2), SUBSTR(fecha_publicacion, 9, 2), SUBSTR(fecha_publicacion, 1, 4)) AS fecha_recepcion
			, DATE(CURRENT) AS fecha_oficio
			, num_oficio
			, num_expediente
		INTO dFechaRecepcion, dFechaOficio, cNumOficio, cNumExpediente
		FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml
		WHERE id_expediente = pIdExpediente;
		
		-- 1. Registramos el oficio en la tabla maestra
		LET iTipoOperacion = 1;  -- Inserción de nuevo registro
		EXECUTE FUNCTION bdicnweb:"informix".sp_sw_ro_ofiocioalta(pUsuario, pIdFuncion, TO_CHAR(dFechaRecepcion, '%Y-%m-%d'), TO_CHAR(dFechaOficio, '%Y-%m-%d'), iTipoOficio, cNumOficio, cNumExpediente, iInst1Enlace, iInst2Enlace, iTipoOperacion, '0', pIpUsuario, pMac)
		INTO cCodRetSp, iIdOficio;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:"informix".sp_sw_ro_ofiocioalta';
		ELIF iCodRetSp > 0 THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, iIdOficio, iNoRegistrosSolicPartes, iNoRegistrosSolicCuentas, iNoRegistrosSolicEspecificas;
		END IF;
		
		-- Se actualiza el id de oficio en la tabla de encabezados
		UPDATE bdicnweb:"informix".sw_ro_encabezadoexparchxml
		SET id_oficio = iIdOficio
		WHERE id_expediente = pIdExpediente;
		
		SET ISOLATION TO DIRTY READ;
		-- Se buscan a las personas de la seccion Solicitud Partes
		
		LET iRegistros = 0;
		LET iRecuperacion = 10000;
		
		FOREACH SELECT ap_paterno, ap_materno, nombre, rfc, DECODE(UPPER(des_tipo_persona), 'FISICA', 1, 'MORAL', 2), id_persona
			INTO cApPaterno, cApMaterno, cNombre1, cRfc, sTipoPersona, iIdxPersona
			FROM bdicnweb:"informix".sw_ro_solicitudpartes
			WHERE id_expediente = pIdExpediente
			
			IF sTipoPersona = 1 THEN
				LET sTipoBusqueda = 1;
				LET cNombre2 = SUBSTR(cNombre1, CHARINDEX(' ', cNombre1) + 1);
				LET cNombre1 = SUBSTR(cNombre1, 0, CHARINDEX(' ', cNombre1));
			ELIF sTipoPersona = 2 THEN
				LET sTipoBusqueda = 2;
			END IF;
			
			FOREACH EXECUTE PROCEDURE bdicnweb:"informix".sp_sw_ro_buscapersona(pUsuario, pIdFuncion, sTipoBusqueda, iIdOficio, cNombre1, cNombre2, cApPaterno, cApMaterno, dFechaNacimiento, iRegistros, iRecuperacion, pIpUsuario, pMac)
				INTO cCodRetSp, cSpNumeroCliente, cSpRfc, cSpNombre1, cSpNombre2, cSpApPaterno, cSpApMaterno, cSpRazonSocial, cSpNoCuenta
						, cSpNoTarjeta, cSpTipoPersona, cSpTipoCliente, iSpStatus, cSpDescStatusBusqueda, cSpIndOmitido, cSpIndBloqueocta
						, cSpIndTerminado, iSpIdBusqueda, iSpIdResulcte, cSpTipoCuenta, cSpIndRfc, cSpIndDir_empleo, cSpIndDomicilio, cSpIndNacionalidad
				
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:"informix".sp_sw_ro_buscapersona';
				ELIF iCodRetSp > 0 THEN
					LET cCodRet = cCodRetSp;
					RETURN cCodRet, iIdOficio, iNoRegistrosSolicPartes, iNoRegistrosSolicCuentas, iNoRegistrosSolicEspecificas;
				END IF;
				
				EXIT FOREACH;
			END FOREACH;
			
			LET iNoRegistrosSolicPartes = iNoRegistrosSolicPartes + 1;
			
			-- SE ACTUALIZAN LOS INDICES DE REFERENCIA
			UPDATE bdicnweb:"informix".sw_ro_solicitudpartes
			SET id_busqueda = iSpIdBusqueda
			WHERE id_expediente = pIdExpediente AND id_persona = iIdxPersona;
        
		END FOREACH;
		
		-- Busqueda por cuentas en las solicitudes especificas
		LET sTipoBusqueda = 5;
		FOREACH SELECT cuenta, id_solicitud_especifica, id_persona
			INTO cNombre1, iIdxSolicitudEspecifica, iIdxPersona
			FROM bdicnweb:"informix".sw_ro_cuentasconocidas
			WHERE id_expediente = pIdExpediente
			
			FOREACH EXECUTE PROCEDURE bdicnweb:"informix".sp_sw_ro_buscapersona(pUsuario, pIdFuncion, sTipoBusqueda, iIdOficio, cNombre1, cNombre2, cApPaterno, cApMaterno, dFechaNacimiento, iRegistros, iRecuperacion, pIpUsuario, pMac)
				INTO cCodRetSp, cSpNumeroCliente, cSpRfc, cSpNombre1, cSpNombre2, cSpApPaterno, cSpApMaterno, cSpRazonSocial, cSpNoCuenta
						, cSpNoTarjeta, cSpTipoPersona, cSpTipoCliente, iSpStatus, cSpDescStatusBusqueda, cSpIndOmitido, cSpIndBloqueocta
						, cSpIndTerminado, iSpIdBusqueda, iSpIdResulcte, cSpTipoCuenta, cSpIndRfc, cSpIndDir_empleo, cSpIndDomicilio, cSpIndNacionalidad
				
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:"informix".sp_sw_ro_buscapersona';
				ELIF iCodRetSp > 0 THEN
					LET cCodRet = cCodRetSp;
					RETURN cCodRet, iIdOficio, iNoRegistrosSolicPartes, iNoRegistrosSolicCuentas, iNoRegistrosSolicEspecificas;
				END IF;
				
				EXIT FOREACH;
			END FOREACH;
			
			LET iNoRegistrosSolicCuentas = iNoRegistrosSolicCuentas + 1;
			
			-- SE ACTUALIZAN INDICES DE REFERENCIA
			UPDATE bdicnweb:"informix".sw_ro_cuentasconocidas
			SET id_busqueda = iSpIdBusqueda
			WHERE id_expediente = pIdExpediente 
				AND id_solicitud_especifica = iIdxSolicitudEspecifica
				AND id_persona = iIdxPersona;
			
		END FOREACH;
		
		-- Busqueda por las solicitudes especificas que no tienen cuentas
		FOREACH SELECT ap_paterno, ap_materno, nombre, rfc, DECODE(UPPER(des_tipo_persona), 'FISICA', 1, 'MORAL', 2), id_solicitud_especifica, id_persona
			INTO cApPaterno, cApMaterno, cNombre1, cRfc, sTipoPersona, iIdSolicitudEspecifica, iIdPersona
			FROM bdicnweb:"informix".sw_ro_personassolicitud
			WHERE id_expediente = pIdExpediente
			
			IF sTipoPersona = 1 THEN
				LET sTipoBusqueda = 1;
				LET cNombre2 = SUBSTR(cNombre1, CHARINDEX(' ', cNombre1) + 1);
				LET cNombre1 = SUBSTR(cNombre1, 0, CHARINDEX(' ', cNombre1));
			ELIF sTipoPersona = 2 THEN
				LET sTipoBusqueda = 2;
			END IF;
			
			IF NOT EXISTS (SELECT 1 FROM bdicnweb:"informix".sw_ro_cuentasconocidas WHERE id_expediente = pIdExpediente and id_solicitud_especifica = iIdSolicitudEspecifica and id_persona = iIdPersona) THEN
			
				FOREACH EXECUTE PROCEDURE bdicnweb:"informix".sp_sw_ro_buscapersona(pUsuario, pIdFuncion, sTipoBusqueda, iIdOficio, cNombre1, cNombre2, cApPaterno, cApMaterno, dFechaNacimiento, iRegistros, iRecuperacion, pIpUsuario, pMac)
					INTO cCodRetSp, cSpNumeroCliente, cSpRfc, cSpNombre1, cSpNombre2, cSpApPaterno, cSpApMaterno, cSpRazonSocial, cSpNoCuenta
							, cSpNoTarjeta, cSpTipoPersona, cSpTipoCliente, iSpStatus, cSpDescStatusBusqueda, cSpIndOmitido, cSpIndBloqueocta
							, cSpIndTerminado, iSpIdBusqueda, iSpIdResulcte, cSpTipoCuenta, cSpIndRfc, cSpIndDir_empleo, cSpIndDomicilio, cSpIndNacionalidad
					
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:"informix".sp_sw_ro_buscapersona';
					ELIF iCodRetSp > 0 THEN
						LET cCodRet = cCodRetSp;
						RETURN cCodRet, iIdOficio, iNoRegistrosSolicPartes, iNoRegistrosSolicCuentas, iNoRegistrosSolicEspecificas;
					END IF;
					
					EXIT FOREACH;
				END FOREACH;
				
				LET iNoRegistrosSolicEspecificas = iNoRegistrosSolicEspecificas + 1;
				
				UPDATE bdicnweb:"informix".sw_ro_personassolicitud
				SET id_busqueda = iSpIdBusqueda
				WHERE id_expediente = pIdExpediente 
					AND id_solicitud_especifica = iIdSolicitudEspecifica
					AND id_persona = iIdPersona;
				
			END IF;
        
		END FOREACH;
		
		-- Notificación vía correo electronico
		-- Se llama al procedimiento del registro del event
		LET dHoy = current;
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(
				'1', 
				TRIM(pIdPlantilla),
				TRIM(pIdPlantilla), 
				pUsuario, 
				'',
				'', 
				'1', 
				'',
				'',
				'',
				'',
				'',
				'',
				'',
				'',
				'',
				TRIM(pTituloPlantilla),
				'',
				'',
				'0',
				'0',
				'0',
				'0',
				'0',
				dHoy,
				dHoy) INTO cCodRetSp;
        
		RETURN cCodRet, iIdOficio, iNoRegistrosSolicPartes, iNoRegistrosSolicCuentas, iNoRegistrosSolicEspecificas;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 27/11/2015',
'MODULO: Oficios',
'FUNCIONALIDAD: Carga de archivos XML',
'DESCRIPCION: Realiza la busqueda de las personas qu vienen en el archivo XML. Las opciones de buesqueda son:',
'1 = Nombre',
'2 = razon social',
'3 = RFC',
'4 = no cliente',
'5 = no cuena',
'6 = no tarjeta',
'FECHA: 06/06/2016',
'DESCRIPCION: Se realiza ajuste para busqueda de pesonas físicas con dos nombres',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_catalogooficios(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaConsulta DATE)
		RETURNING CHAR(5) AS codret,
			INTEGER AS id_expediente,
			CHAR(60) AS no_oficio;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdExpediente INTEGER;
	DEFINE cNoOficio CHAR(60);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdExpediente = '';
	LET cNoOficio = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdExpediente, cNoOficio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_catalogooficios.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaConsulta IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdExpediente, cNoOficio;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdExpediente, cNoOficio;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH
			
			SELECT a.id_expediente,a.num_oficio
			INTO iIdExpediente,cNoOficio
			FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml AS a INNER JOIN bdicnweb:"informix".sw_ro_maeoficios AS b
			ON a.id_oficio = b.id_oficio
			AND b.fecha_oficio = pFechaConsulta
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iIdExpediente, UPPER(cNoOficio) WITH RESUME;
			
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdExpediente, cNoOficio;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 01/12/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE DE STATUS DE OFICIOS',
'DESCRIPCION: SPL que consulta el numero de oficio para el llenado del catÃ¡logo No. Oficios.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_consencabezadoarchivoxml(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(60) AS num_oficio,
            CHAR(60) AS num_expediente,
			CHAR(60) AS solicitud_siara,
			INTEGER AS folio,
			CHAR(4) AS anio_oficio,
			CHAR(32) AS area,
			CHAR(25) AS fecha_publicacion,
			CHAR(2) AS dias_plazo,
			CHAR(60) AS nombre_autoridad,
			CHAR(60) AS nombre_autoridad_especifica,
			CHAR(60) AS nombre_solicitante,
			CHAR(60) AS referencia,
			CHAR(60) AS referencia1,
			CHAR(60) AS referencia2,
			CHAR(2) AS tiene_aseguramiento,
			INTEGER AS total_registros,
			CHAR(8) AS usuario_insert,
			CHAR(25) AS fecha_insert,
			INTEGER AS total_partes,
			INTEGER AS total_especifica;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdExpediente INTEGER;
	DEFINE cNumOficio CHAR(60);
	DEFINE cNumExpediente CHAR(60);
	DEFINE cSolicitudSiara CHAR(60);
	DEFINE iFolio INTEGER;
	DEFINE dAnioOficio CHAR(4);
	DEFINE cArea CHAR(32);
	DEFINE iIdArea CHAR(2);
	DEFINE cDescArea CHAR(30);
	DEFINE dFechaPublicacion CHAR(25);
	DEFINE iDiasPlazo CHAR(2);
	DEFINE cNombreAutoridad CHAR(60);
	DEFINE cNombreAutoridadEspecifica CHAR(60);
	DEFINE cNombreSolicitante CHAR(60);
	DEFINE cReferencia CHAR(60);
	DEFINE cReferencia1 CHAR(60);
	DEFINE cReferencia2 CHAR(60);
	DEFINE cAseguramiento CHAR(5);
	DEFINE cTieneAseguramiento CHAR(2);
	DEFINE iTotalRegistros INTEGER;
	DEFINE cUsuarioInsert CHAR(8);
	DEFINE dFechaInsert CHAR(25);
	DEFINE iTotalPartes INTEGER;
	DEFINE iTotalEspecifica INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdExpediente = 0;
	LET cNumOficio = '';
	LET cNumExpediente = '';
	LET cSolicitudSiara = '';
	LET iFolio = 0;
	LET dAnioOficio = '';
	LET cArea = '';
	LET iIdArea = '';
	LET cDescArea = '';
	LET dFechaPublicacion = '';
	LET iDiasPlazo = '';
	LET cNombreAutoridad = '';
	LET cNombreAutoridadEspecifica = '';
	LET cNombreSolicitante = '';
	LET cReferencia = '';
	LET cReferencia1 = '';
	LET cReferencia2 = '';
	LET cAseguramiento = '';
	LET cTieneAseguramiento = '';
	LET iTotalRegistros = 0;
	LET cUsuarioInsert = '';
	LET dFechaInsert = '';
	LET iTotalPartes = 0;
	LET iTotalEspecifica = 0;
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumOficio, cNumExpediente, cSolicitudSiara, iFolio, dAnioOficio, cArea, dFechaPublicacion,
			iDiasPlazo, cNombreAutoridad, cNombreAutoridadEspecifica, cNombreSolicitante, cReferencia, cReferencia1, cReferencia2, 
			cTieneAseguramiento, iTotalRegistros, cUsuarioInsert, dFechaInsert, iTotalPartes, iTotalEspecifica;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_consencabezadoarchivoxml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumOficio, cNumExpediente, cSolicitudSiara, iFolio, dAnioOficio, cArea, dFechaPublicacion,
			iDiasPlazo, cNombreAutoridad, cNombreAutoridadEspecifica, cNombreSolicitante, cReferencia, cReferencia1, cReferencia2, 
			cTieneAseguramiento, iTotalRegistros, cUsuarioInsert, dFechaInsert, iTotalPartes, iTotalEspecifica;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumOficio, cNumExpediente, cSolicitudSiara, iFolio, dAnioOficio, cArea, dFechaPublicacion,
			iDiasPlazo, cNombreAutoridad, cNombreAutoridadEspecifica, cNombreSolicitante, cReferencia, cReferencia1, cReferencia2, 
			cTieneAseguramiento, iTotalRegistros, cUsuarioInsert, dFechaInsert, iTotalPartes, iTotalEspecifica;
		END IF;
	
		SET ISOLATION TO DIRTY READ;
			
		SELECT num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,
		dias_plazo,nombre_autoridad,nombre_autoridad_especifica,nombre_solicitante,referencia,referencia1,referencia2,
		aseguramiento,total_registros,usuario_insert,fecha_insert
		INTO cNumOficio, cNumExpediente, cSolicitudSiara, iFolio, dAnioOficio, iIdArea, cDescArea, dFechaPublicacion,
		iDiasPlazo, cNombreAutoridad, cNombreAutoridadEspecifica, cNombreSolicitante, cReferencia, cReferencia1, cReferencia2, 
		cAseguramiento, iTotalRegistros, cUsuarioInsert, dFechaInsert 
		FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml 
		WHERE id_expediente = pIdExpediente;
		
		LET cArea = TRIM(NVL(iIdArea,'')) ||' '|| TRIM(UPPER(NVL(cDescArea,'')));
		
		IF UPPER(cAseguramiento) = 'FALSE' THEN
			LET cTieneAseguramiento = 'NO';
		ELIF UPPER(cAseguramiento) = 'TRUE' THEN
			LET cTieneAseguramiento = 'SI';
		END IF;
		
		-- Calculamos el numero total de registros
		SELECT FIRST 1
			((SELECT COUNT(*) FROM bdicnweb:"informix".sw_ro_solicitudpartes WHERE id_expediente = pIdExpediente) +
			(SELECT COUNT(*) FROM bdicnweb:"informix".sw_ro_personassolicitud WHERE id_expediente = pIdExpediente))
		INTO iTotalRegistros
		FROM bdicnweb:"informix".sw_ro_solicitudpartes;

		SELECT COUNT(*) 
		INTO iTotalPartes
		FROM bdicnweb:"informix".sw_ro_solicitudpartes WHERE id_expediente = pIdExpediente;
		
		SELECT COUNT(*) 
		INTO iTotalEspecifica
		FROM bdicnweb:"informix".sw_ro_personassolicitud WHERE id_expediente = pIdExpediente;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, UPPER(cNumOficio), UPPER(cNumExpediente), UPPER(cSolicitudSiara), iFolio, dAnioOficio, cArea, dFechaPublicacion,
		iDiasPlazo, UPPER(cNombreAutoridad), UPPER(cNombreAutoridadEspecifica), UPPER(cNombreSolicitante), UPPER(cReferencia), UPPER(cReferencia1), UPPER(cReferencia2), 
		cTieneAseguramiento, iTotalRegistros, cUsuarioInsert, dFechaInsert, iTotalPartes, iTotalEspecifica;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 24/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CARGA DE ARCHIVOS XML', 
'DESCRIPCION: SPL que hace la consulta para el llenado del panel Encabezado Archivo XML.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_consreportes_estatusoficios(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER, pTipoBusqueda SMALLINT, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(1) AS fisica,
				CHAR(1) AS moral,
				CHAR(1) AS homonimo,
				CHAR(60) AS referencia,
				CHAR(160) AS nombre;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cFisica CHAR(1);
	DEFINE cMoral CHAR(1);
	DEFINE cHomonimo CHAR(1);
	DEFINE cReferencia CHAR(60);
	DEFINE cNombre CHAR(160);
	DEFINE iIdOficio INTEGER;
	DEFINE cCuenta CHAR(20);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cFisica = '';
	LET cMoral = '';
	LET cHomonimo = '';
	LET cReferencia = '';
	LET cNombre = '';
	LET iIdOficio = 0;
	LET cCuenta = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cFisica, cMoral, cHomonimo, cReferencia, cNombre;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_consreportesoficiosdirigidosbancoppel.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL OR pTipoBusqueda IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFisica, cMoral, cHomonimo, cReferencia, cNombre;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cFisica, cMoral, cHomonimo, cReferencia, cNombre;
		END IF;
		
		IF pTipoBusqueda NOT IN (0, 1, 2) THEN
			LET cCodRet = '00044';
			RETURN cCodRet, cFisica, cMoral, cHomonimo, cReferencia, cNombre;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFisica, cMoral, cHomonimo, cReferencia, cNombre;
		END IF;
		
		-- BUSQUEDA DEL ID DE OFICIO
		SET ISOLATION TO DIRTY READ;
		SELECT id_oficio
		INTO iIdOficio
		FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml
		WHERE id_expediente = pIdExpediente;
		
		IF iIdOficio IS NULL THEN
			LET cCodRet = '00110';
			RETURN cCodRet, cFisica, cMoral, cHomonimo, cReferencia, cNombre;
		END IF;

		IF pTipoBusqueda IN (0, 1) THEN -- DIRIGIDOS A BANCOPPEL, 0 NEGATIVOS, 1 POSITIVOS
			IF pTipoBusqueda = 0 THEN
				
				FOREACH SELECT SKIP pRegistros FIRST pRecuperacion 
							CASE WHEN TRIM(LOWER(e.des_tipo_persona)) = 'fisica' THEN '1' ELSE '0' END AS persona_fisica
							, CASE WHEN TRIM(LOWER(e.des_tipo_persona)) = 'moral' THEN '1' ELSE '0' END AS persona_moral
							, TRIM(TRIM(e.nombre)||' '||TRIM(e.ap_paterno)||' '||TRIM(e.ap_materno))
							, b.cuenta
						INTO cFisica, cMoral, cNombre, cReferencia
						FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml a, bdicnweb:"informix".sw_ro_cuentasconocidas b,
							bdicnweb:"informix".sw_ro_maeoficios c, bdicnweb:"informix".sw_ro_resulper d,
							bdicnweb:"informix".sw_ro_personassolicitud e
						WHERE a.id_expediente = pIdExpediente
							AND b.id_expediente = a.id_expediente 
							AND c.id_oficio = a.id_oficio
							AND d.id_oficio = c.id_oficio
							AND d.id_busqueda = b.id_busqueda
							AND d.status_busqueda = 0
							AND e.id_expediente = a.id_expediente
							AND e.id_solicitud_especifica = b.id_solicitud_especifica
							AND e.id_persona = b.id_persona

					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, cFisica, cMoral, cHomonimo, cReferencia, cNombre WITH RESUME;
					
				END FOREACH;
				
				IF iNoRegistros = 0 THEN
					IF pRegistros = 0 THEN
						LET cCodRet = '00017';
					ELIF pRegistros > 0 THEN
						LET cCodRet = '1001';
					END IF;
					
					RETURN cCodRet, cFisica, cMoral, cHomonimo, cReferencia, cNombre;
				END IF;
			
			ELIF pTipoBusqueda = 1 THEN
				
				FOREACH SELECT SKIP pRegistros FIRST pRecuperacion 
							CASE WHEN TRIM(LOWER(e.des_tipo_persona)) = 'fisica' THEN '1' ELSE '0' END AS persona_fisica
							, CASE WHEN TRIM(LOWER(e.des_tipo_persona)) = 'moral' THEN '1' ELSE '0' END AS persona_moral
							, d.cuenta
						INTO cFisica, cMoral, cReferencia
						FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml a, bdicnweb:"informix".sw_ro_cuentasconocidas b,
							bdicnweb:"informix".sw_ro_maeoficios c, bdicnweb:"informix".sw_ro_resulper d,
							bdicnweb:"informix".sw_ro_personassolicitud e
						WHERE a.id_expediente = pIdExpediente
							AND b.id_expediente = a.id_expediente 
							AND c.id_oficio = a.id_oficio
							AND d.id_oficio = c.id_oficio
							AND d.id_busqueda = b.id_busqueda
							AND d.status_busqueda = 1
							AND e.id_expediente = a.id_expediente
							AND e.id_solicitud_especifica = b.id_solicitud_especifica
							AND e.id_persona = b.id_persona
						
					IF SUBSTR(cReferencia, 1, 1) = '1' THEN
						SELECT TRIM(TRIM(TRIM(TRIM(nombre1)||' '||TRIM(nombre2))||' '||TRIM(TRIM(apell_paterno)||' '||TRIM(apell_materno)))||' '||TRIM(razon_social))
						INTO cNombre
						FROM bdinteg:"informix".si_cliente
						WHERE numcte = (SELECT num_cte FROM bdicheq:"informix".sc_maechq WHERE cuenta = cReferencia);
					ELIF SUBSTR(cReferencia, 1, 1) = '3' THEN
						SELECT TRIM(TRIM(TRIM(TRIM(nombre1)||' '||TRIM(nombre2))||' '||TRIM(TRIM(apell_paterno)||' '||TRIM(apell_materno)))||' '||TRIM(razon_social))
						INTO cNombre
						FROM bdinteg:"informix".si_cliente
						WHERE numcte = (SELECT num_cte FROM bdinvers:"informix".sv_maeinv WHERE cuenta = cReferencia);
					ELIF SUBSTR(cReferencia, 1, 1) = '6' OR SUBSTR(cReferencia, 1, 1) = '7' THEN
						SELECT TRIM(TRIM(TRIM(TRIM(nombre1)||' '||TRIM(nombre2))||' '||TRIM(TRIM(apell_paterno)||' '||TRIM(apell_materno)))||' '||TRIM(razon_social))
						INTO cNombre
						FROM bdinteg:"informix".si_cliente
						WHERE numcte = (SELECT numcte FROM bdicred:"informix".sd_maecred WHERE num_credito = cReferencia);
						
						IF NVL(cNombre, '') = '' THEN
							SELECT TRIM(TRIM(TRIM(nombre1)||' '||TRIM(nombre2))||' '||TRIM(TRIM(apell_paterno)||' '||TRIM(apell_materno)))
							INTO cNombre
							FROM bdinteg:"informix".si_cliente
							WHERE numcte = (SELECT numcte FROM bdicred:"informix".sd_maecredcrd WHERE num_credito = cReferencia);
						END IF;
					END IF;
					
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, cFisica, cMoral, cHomonimo, cReferencia, cNombre WITH RESUME;

				END FOREACH;
				
				IF iNoRegistros = 0 THEN
					IF pRegistros = 0 THEN
						LET cCodRet = '00017';
					ELIF pRegistros > 0 THEN
						LET cCodRet = '1001';
					END IF;
					
					RETURN cCodRet, cFisica, cMoral, cHomonimo, cReferencia, cNombre;
				END IF;
				
			END IF;
			
		ELIF pTipoBusqueda = 2 THEN -- CONSULTA DE OFICIOS POSITIVOS
		
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion persona_fisica, persona_moral, nombre, homonimo, referencia
					INTO cFisica, cMoral, cNombre, cHomonimo, cReferencia
					FROM (
						SELECT CASE WHEN TRIM(LOWER(c.des_tipo_persona)) = 'fisica' THEN '1' ELSE '0' END AS persona_fisica
							, CASE WHEN TRIM(LOWER(c.des_tipo_persona)) = 'moral' THEN '1' ELSE '0' END AS persona_moral
							, TRIM(TRIM(c.nombre)||' '||TRIM(c.ap_paterno)||' '||TRIM(c.ap_materno)) AS nombre
							, DECODE(d.status_busqueda, 2, '1', '') AS homonimo
							, '' AS referencia
							, d.id_busqueda
						FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml a,  bdicnweb:"informix".sw_ro_maeoficios b,
							bdicnweb:"informix".sw_ro_solicitudpartes c, bdicnweb:"informix".sw_ro_resulper d
						WHERE a.id_expediente = pIdExpediente
							AND b.id_oficio = a.id_oficio
							AND c.id_expediente = a.id_expediente
							AND d.id_oficio = b.id_oficio
							AND d.id_busqueda = c.id_busqueda
							AND d.status_busqueda IN (1, 2)
						UNION
						SELECT CASE WHEN TRIM(LOWER(c.des_tipo_persona)) = 'fisica' THEN '1' ELSE '0' END AS persona_fisica
							, CASE WHEN TRIM(LOWER(c.des_tipo_persona)) = 'moral' THEN '1' ELSE '0' END AS persona_moral
							, TRIM(TRIM(c.nombre)||' '||TRIM(c.ap_paterno)||' '||TRIM(c.ap_materno)) AS nombre
							, DECODE(d.status_busqueda, 2, '1', '') AS homonimo
							, d.numcte AS referencia
							, d.id_busqueda
						FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml a,  bdicnweb:"informix".sw_ro_maeoficios b,
							bdicnweb:"informix".sw_ro_personassolicitud c, bdicnweb:"informix".sw_ro_resulper d
						WHERE a.id_expediente = pIdExpediente
							AND b.id_oficio = a.id_oficio
							AND c.id_expediente = a.id_expediente
							AND d.id_oficio = b.id_oficio
							AND d.id_busqueda = c.id_busqueda
							AND d.status_busqueda IN (1, 2)
						)
					ORDER BY id_busqueda
		
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cFisica, cMoral, cHomonimo, cReferencia, cNombre WITH RESUME;
			
			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				IF pRegistros = 0 THEN
					LET cCodRet = '00017';
				ELIF pRegistros > 0 THEN
					LET cCodRet = '1001';
				END IF;
				
				RETURN cCodRet, cFisica, cMoral, cHomonimo, cReferencia, cNombre;
			END IF;
		
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 30/12/2015',
'MODULO: CONTESTACIÓN A OFICIOS',
'FUNCIONALIDAD: Reportes de estatus de oficios',
'DESCRIPCION: Consulta los reportes dirigidos a bancoppel (negativos y positivos) y los positivos no dirigidos a bancoppel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_consreportes_estatusoficios_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER, pTipoBusqueda SMALLINT)
		RETURNING CHAR(5) AS codret,
				INTEGER AS totales;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdOficio INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdOficio = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_consreportes_estatusoficios_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL OR pTipoBusqueda IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		IF pTipoBusqueda NOT IN (0, 1, 2) THEN
			LET cCodRet = '00044';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- BUSQUEDA DEL ID DE OFICIO
		SET ISOLATION TO DIRTY READ;
		SELECT id_oficio
		INTO iIdOficio
		FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml
		WHERE id_expediente = pIdExpediente;
		
		IF iIdOficio IS NULL THEN
			LET cCodRet = '00110';
			RETURN cCodRet, iNoRegistros;
		END IF;

		IF pTipoBusqueda IN (0, 1) THEN -- DIRIGIDOS A BANCOPPEL, 0 NEGATIVOS, 1 POSITIVOS
			IF pTipoBusqueda = 0 THEN
				
				SELECT COUNT(*)
				INTO iNoRegistros
				FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml a, bdicnweb:"informix".sw_ro_cuentasconocidas b,
					bdicnweb:"informix".sw_ro_maeoficios c, bdicnweb:"informix".sw_ro_resulper d,
					bdicnweb:"informix".sw_ro_personassolicitud e
				WHERE a.id_expediente = pIdExpediente
					AND b.id_expediente = a.id_expediente 
					AND c.id_oficio = a.id_oficio
					AND d.id_oficio = c.id_oficio
					AND d.id_busqueda = b.id_busqueda
					AND d.status_busqueda = 0
					AND e.id_expediente = a.id_expediente
					AND e.id_solicitud_especifica = b.id_solicitud_especifica
					AND e.id_persona = b.id_persona;

				IF iNoRegistros = 0 THEN
					LET cCodRet = '00017';
				END IF;
					
				RETURN cCodRet, iNoRegistros;
					
			ELIF pTipoBusqueda = 1 THEN
				
				SELECT COUNT(*)
				INTO iNoRegistros
				FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml a, bdicnweb:"informix".sw_ro_cuentasconocidas b,
					bdicnweb:"informix".sw_ro_maeoficios c, bdicnweb:"informix".sw_ro_resulper d,
					bdicnweb:"informix".sw_ro_personassolicitud e
				WHERE a.id_expediente = pIdExpediente
					AND b.id_expediente = a.id_expediente 
					AND c.id_oficio = a.id_oficio
					AND d.id_oficio = c.id_oficio
					AND d.id_busqueda = b.id_busqueda
					AND d.status_busqueda = 1
					AND e.id_expediente = a.id_expediente
					AND e.id_solicitud_especifica = b.id_solicitud_especifica
					AND e.id_persona = b.id_persona;
					
				IF iNoRegistros = 0 THEN
					LET cCodRet = '00017';
				END IF;
						
				RETURN cCodRet, iNoRegistros;
				
			END IF;
			
		ELIF pTipoBusqueda = 2 THEN -- CONSULTA DE OFICIOS POSITIVOS
		
			SELECT COUNT(*)
			INTO iNoRegistros
			FROM (
				SELECT CASE WHEN TRIM(LOWER(c.des_tipo_persona)) = 'fisica' THEN '1' ELSE '0' END AS persona_fisica
					, CASE WHEN TRIM(LOWER(c.des_tipo_persona)) = 'moral' THEN '1' ELSE '0' END AS persona_moral
					, TRIM(TRIM(c.nombre)||' '||TRIM(c.ap_paterno)||' '||TRIM(c.ap_materno)) AS nombre
					, DECODE(d.status_busqueda, 2, '1', '') AS homonimo
					, '' AS referencia
					, d.id_busqueda
				FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml a,  bdicnweb:"informix".sw_ro_maeoficios b,
					bdicnweb:"informix".sw_ro_solicitudpartes c, bdicnweb:"informix".sw_ro_resulper d
				WHERE a.id_expediente = pIdExpediente
					AND b.id_oficio = a.id_oficio
					AND c.id_expediente = a.id_expediente
					AND d.id_oficio = b.id_oficio
					AND d.id_busqueda = c.id_busqueda
					AND d.status_busqueda IN (1, 2)
				UNION
				SELECT CASE WHEN TRIM(LOWER(c.des_tipo_persona)) = 'fisica' THEN '1' ELSE '0' END AS persona_fisica
					, CASE WHEN TRIM(LOWER(c.des_tipo_persona)) = 'moral' THEN '1' ELSE '0' END AS persona_moral
					, TRIM(TRIM(c.nombre)||' '||TRIM(c.ap_paterno)||' '||TRIM(c.ap_materno)) AS nombre
					, '' AS homonimo
					, d.numcte AS referencia
					, d.id_busqueda
				FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml a,  bdicnweb:"informix".sw_ro_maeoficios b,
					bdicnweb:"informix".sw_ro_personassolicitud c, bdicnweb:"informix".sw_ro_resulper d
				WHERE a.id_expediente = pIdExpediente
					AND b.id_oficio = a.id_oficio
					AND c.id_expediente = a.id_expediente
					AND d.id_oficio = b.id_oficio
					AND d.id_busqueda = c.id_busqueda
					AND d.status_busqueda IN (1, 2)
				);
		
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
			END IF;
				
			RETURN cCodRet, iNoRegistros;
		
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 30/12/2015',
'MODULO: CONTESTACIÓN A OFICIOS',
'FUNCIONALIDAD: Reportes de estatus de oficios',
'DESCRIPCION: Consulta el total de registros de los reportes dirigidos a bancoppel (negativos y positivos) y los positivos no dirigidos a bancoppel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_consreportestatusoficioneg(pUsuario CHAR(8), pIdFuncion CHAR(10),	pIdExpediente INTEGER, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			INTEGER AS folio,
			CHAR(4) AS anio_oficio,
			CHAR(60) AS num_oficio,
			CHAR(60) AS num_expediente,
			CHAR(10) AS fecha_publicacion,	
			CHAR(32) AS area,			
			CHAR(2) AS dias_plazo,
			DATE AS fecha_vencimiento,	
			INTEGER AS persona_fisica,      
			INTEGER AS persona_moral;	 
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE iIdExpediente INTEGER;
	DEFINE iIdSolicitudEsp INTEGER;
	DEFINE iIdOficio INTEGER;
	DEFINE iFolio INTEGER;
	DEFINE dAnioOficio CHAR(4);
	DEFINE cNumOficio CHAR(60);
	DEFINE cNumExpediente CHAR(60);
	DEFINE dFechaPublicacion CHAR(25);
	DEFINE cArea CHAR(32);
	DEFINE iIdArea CHAR(2);
	DEFINE cDescArea CHAR(30);
	DEFINE iDiasPlazo CHAR(2);
	DEFINE dFecha_Ven DATE;
	DEFINE cFechaVencimiento DATE;
	DEFINE iPersonaFisica INTEGER;
	DEFINE iPersonaMoral INTEGER;
	DEFINE iPerFisicaPartes INTEGER;
	DEFINE iPerMoralPartes INTEGER;
	DEFINE iPerFisicaSol INTEGER;
	DEFINE iPerMoralSol INTEGER;
	DEFINE iHayDatos INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdExpediente = 0;
	LET iIdSolicitudEsp = 0;
	LET iIdOficio = 0;
	LET iFolio = 0;
	LET dAnioOficio = '';
	LET cNumOficio = '';
	LET cNumExpediente = '';
	LET dFechaPublicacion = '';	
	LET cArea = '';
	LET iIdArea = '';
	LET cDescArea = '';
	LET iDiasPlazo = '';
	LET dFecha_Ven = '';
	LET cFechaVencimiento = '';
	LET iPersonaFisica = 0;              
	LET iPersonaMoral = 0;               
	LET iPerFisicaPartes = 0;
	LET iPerMoralPartes = 0;
	LET iPerFisicaSol = 0;
	LET iPerMoralSol = 0;	
	LET iHayDatos = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iFolio, dAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, 
			iDiasPlazo, cFechaVencimiento, iPersonaFisica, iPersonaMoral;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_consreportestatusoficioneg.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iFolio, dAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, 
			iDiasPlazo, cFechaVencimiento, iPersonaFisica, iPersonaMoral;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iFolio, dAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, 
			iDiasPlazo, cFechaVencimiento, iPersonaFisica, iPersonaMoral;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iFolio, dAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, 
			iDiasPlazo, cFechaVencimiento, iPersonaFisica, iPersonaMoral;
		END IF;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH			
		
			SELECT SKIP pRegistros FIRST pRecuperacion folio, anio_oficio, a.num_oficio, num_expediente
				, MDY(SUBSTR(fecha_publicacion, 6, 2), SUBSTR(fecha_publicacion, 9, 2), SUBSTR(fecha_publicacion, 1, 4)) AS fecha_publicacion
				, c.desc_tipooficio AS area, a.dias_plazo
				, EXTEND(MDY(SUBSTR(fecha_publicacion, 6, 2), SUBSTR(fecha_publicacion, 9, 2), SUBSTR(fecha_publicacion, 1, 4)), YEAR TO DAY) + dias_plazo::INTEGER UNITS DAY AS fecha_vencimiento
			INTO iFolio, dAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, iDiasPlazo, cFechaVencimiento
			FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml a,  bdicnweb:"informix".sw_ro_maeoficios b,
			bdicnweb:"informix".sw_ro_tipooficios c, bdicnweb:"informix".sw_ro_resulper d
			WHERE a.id_expediente = pIdExpediente
			AND b.id_oficio = a.id_oficio
			AND c.id_tipooficio = b.id_tipooficio
			AND d.id_oficio = b.id_oficio
			AND d.status_busqueda = 0
			
			SELECT COUNT(id_persona)
			INTO iPerMoralPartes
			FROM bdicnweb:"informix".sw_ro_solicitudpartes
			WHERE id_expediente = pIdExpediente
			AND LOWER(des_tipo_persona) = 'moral';

			SELECT COUNT(id_persona)
			INTO iPerFisicaPartes
			FROM bdicnweb:"informix".sw_ro_solicitudpartes
			WHERE id_expediente = pIdExpediente
			AND LOWER(des_tipo_persona) = 'fisica';

			SELECT COUNT(id_persona)
			INTO iPerMoralSol
			FROM bdicnweb:"informix".sw_ro_personassolicitud
			WHERE id_expediente = pIdExpediente
			AND LOWER(des_tipo_persona) = 'moral';

			SELECT COUNT(id_persona)
			INTO iPerFisicaSol
			FROM bdicnweb:"informix".sw_ro_personassolicitud
			WHERE id_expediente = pIdExpediente
			AND LOWER(des_tipo_persona) = 'fisica';
		
			LET iPersonaFisica = NVL(iPerFisicaPartes, 0) + NVL(iPerFisicaSol, 0);
			LET iPersonaMoral = NVL(iPerMoralPartes, 0) + NVL(iPerMoralSol, 0);
		
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, iFolio, dAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, 
			iDiasPlazo, cFechaVencimiento, iPersonaFisica, iPersonaMoral WITH RESUME;
		
		END FOREACH;
	
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, iFolio, dAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, 
			iDiasPlazo, cFechaVencimiento, iPersonaFisica, iPersonaMoral;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iFolio, dAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, 
			iDiasPlazo, cFechaVencimiento, iPersonaFisica, iPersonaMoral;
		END IF;		
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 27/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE DE STATUS DE OFICIOS', 
'DESCRIPCION: SPL que hace la consulta para el llenado del detalle de los reportes oficios negativos.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 17/05/2016',
'DESCRIPCION: Se agregÃ³ el filtro para consultar el status_busqueda igual a 0 en la tabla bdicnweb:sw_ro_resulper.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_consreportestatusoficioneg_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER)
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros;	 
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE iIdExpediente INTEGER;
	DEFINE iIdSolicitudEsp INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdExpediente = 0;
	LET iIdSolicitudEsp = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_consreportestatusoficioneg_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
	
		SET ISOLATION TO DIRTY READ;
		
		SELECT COUNT(a.id_expediente)
		INTO iNoRegistros
		FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml a,  bdicnweb:"informix".sw_ro_maeoficios b,
		bdicnweb:"informix".sw_ro_tipooficios c, bdicnweb:"informix".sw_ro_resulper d
		WHERE a.id_expediente = pIdExpediente
		AND b.id_oficio = a.id_oficio
		AND c.id_tipooficio = b.id_tipooficio
		AND d.id_oficio = b.id_oficio
		AND d.status_busqueda = 0;
			
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017'; 
		END IF;
		
		RETURN cCodRet, iNoRegistros;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 27/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE DE STATUS DE OFICIOS', 
'DESCRIPCION: SPL que consulta el numero total de registros correspondientes a los reportes oficios negativos.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 17/05/2016',
'DESCRIPCION: Se agregÃ³ el filtro para consultar el status_busqueda igual a 0 en la tabla bdicnweb:sw_ro_resulper.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_conssolicitudespecificaarchivoxml(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER, 
	pIdSolEspecifica INTEGER, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			INTEGER AS id_persona,
            CHAR(30) AS caracter,
			CHAR(10) AS tipo_persona,
			CHAR(150) AS nombre,
			CHAR(26) AS apell_paterno,
			CHAR(26) AS apell_materno,
			CHAR(15) AS rfc,
			CHAR(50) AS relacion,
			CHAR(150) AS domicilio,
			CHAR(150) AS complementarios,
			CHAR(1) AS indicador;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdExpediente INTEGER;
	DEFINE iIdPersona INTEGER;
	DEFINE cCaracter CHAR(30);
	DEFINE cDescTipoPersona CHAR(10);
	DEFINE cNombre CHAR(150);
	DEFINE cApellPaterno CHAR(26);
	DEFINE cApellMaterno CHAR(26);
	DEFINE cRFC CHAR(15);
	DEFINE cRelacion CHAR(50);
	DEFINE cDomicilio CHAR(150);
	DEFINE cComplementarios CHAR(150);
	DEFINE iExiste INTEGER;
	DEFINE cIndicador CHAR(1);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdExpediente = 0;
	LET iIdPersona = 0;
	LET cCaracter = '';
	LET cDescTipoPersona = '';
	LET cNombre = '';
	LET cApellPaterno = '';
	LET cApellMaterno = '';
	LET cRFC = '';
	LET cRelacion = '';
	LET cDomicilio = '';
	LET cComplementarios = '';
	LET iExiste = 0;
	LET cIndicador = '';
	LET iRecuperacion = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC, 
			cRelacion, cDomicilio, cComplementarios, cIndicador;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_conssolicitudespecificaarchivoxml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL OR pIdSolEspecifica IS NULL 
		OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC, 
			cRelacion, cDomicilio, cComplementarios, cIndicador;
		END IF;
			
		-- VALIDACIÃN DE LOS DATOS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC, 
			cRelacion, cDomicilio, cComplementarios, cIndicador;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC, 
			cRelacion, cDomicilio, cComplementarios, cIndicador;
		END IF;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		FOREACH	
			SELECT SKIP pRegistros FIRST pRecuperacion id_persona, caracter, des_tipo_persona, ap_paterno, ap_materno, nombre, rfc,
			relacion, domicilio, complementarios
			INTO iIdPersona, cCaracter, cDescTipoPersona, cApellPaterno, cApellMaterno, cNombre, cRFC,
			cRelacion, cDomicilio, cComplementarios
			FROM bdicnweb:"informix".sw_ro_personassolicitud 
			WHERE id_expediente = pIdExpediente 
			AND id_solicitud_especifica = pIdSolEspecifica
			
			SELECT COUNT(*)
			INTO  iExiste
			FROM bdicnweb:"informix".sw_ro_cuentasconocidas 
			WHERE id_expediente = pIdExpediente 
			AND id_solicitud_especifica = pIdSolEspecifica
			AND id_persona = iIdPersona;
			
			IF NVL(iExiste,0) = 0 THEN
				LET cIndicador = '0';
			ELIF NVL(iExiste,0) <> 0 THEN
				LET cIndicador = '1';
			END IF;
		
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, iIdPersona, TRIM(UPPER(cCaracter)), TRIM(UPPER(cDescTipoPersona)), TRIM(UPPER(cNombre)), TRIM(UPPER(cApellPaterno)), TRIM(UPPER(cApellMaterno)), TRIM(UPPER(cRFC)),
			TRIM(UPPER(cRelacion)), TRIM(UPPER(cDomicilio)), TRIM(UPPER(cComplementarios)), cIndicador WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC, 
			cRelacion, cDomicilio, cComplementarios, cIndicador;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC, 
			cRelacion, cDomicilio, cComplementarios, cIndicador;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 24/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CARGA DE ARCHIVOS XML', 
'DESCRIPCION: SPL que hace la consulta para el llenado del Detalle Solicitud Especifica Archivo XML.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_conssolicitudpartesarchivoxml(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER, 
	pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			INTEGER AS id_persona,
            CHAR(30) AS caracter,
			CHAR(10) AS tipo_persona,
			CHAR(150) AS nombre,
			CHAR(26) AS apell_paterno,
			CHAR(26) AS apell_materno,
			CHAR(15) AS rfc;
			
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdExpediente INTEGER;
	DEFINE iIdPersona INTEGER;
	DEFINE cCaracter CHAR(30);
	DEFINE cDescTipoPersona CHAR(10);
	DEFINE cNombre CHAR(150);
	DEFINE cApellPaterno CHAR(26);
	DEFINE cApellMaterno CHAR(26);
	DEFINE cRFC CHAR(15);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdExpediente = 0;
	LET iIdPersona = 0;
	LET cCaracter = '';
	LET cDescTipoPersona = '';
	LET cNombre = '';
	LET cApellPaterno = '';
	LET cApellMaterno = '';
	LET cRFC = '';
	LET iRecuperacion = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_conssolicitudpartesarchivoxml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC;
		END IF;
			
		-- VALIDACIÃN DE LOS DATOS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC;
		END IF;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		FOREACH	
			SELECT SKIP pRegistros FIRST pRecuperacion id_persona, caracter, des_tipo_persona, ap_paterno, ap_materno, nombre, rfc
			INTO iIdPersona, cCaracter, cDescTipoPersona, cApellPaterno, cApellMaterno, cNombre, cRFC
			FROM bdicnweb:"informix".sw_ro_solicitudpartes 
			WHERE id_expediente = pIdExpediente 
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, iIdPersona, TRIM(UPPER(cCaracter)), TRIM(UPPER(cDescTipoPersona)), TRIM(UPPER(cNombre)), TRIM(UPPER(cApellPaterno)), TRIM(UPPER(cApellMaterno)), TRIM(UPPER(cRFC)) WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 24/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CARGA DE ARCHIVOS XML', 
'DESCRIPCION: SPL que hace la consulta para el llenado del Detalle Solicitud Partes Archivo XML.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_cuentasconocidasarchivoxml(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER, 
	pIdSolEspecifica INTEGER, pIdPersona INTEGER)
		RETURNING CHAR(5) AS codret,
            CHAR(50) AS entidad_cc,
			CHAR(20) AS cuenta_cc,
			CHAR(9000) AS instrucciones_cc;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdExpediente INTEGER;
	DEFINE iIdPersona INTEGER;
	DEFINE cEntidad CHAR(50);
	DEFINE cCuenta CHAR(20);
	DEFINE cInstrucciones CHAR(9000);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdExpediente = 0;
	LET iIdPersona = 0;
	LET cEntidad = '';
	LET cCuenta = '';
	LET cInstrucciones = '';
	LET iRecuperacion = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEntidad, cCuenta, cInstrucciones;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_cuentasconocidasarchivoxml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL OR pIdSolEspecifica IS NULL OR pIdPersona IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEntidad, cCuenta, cInstrucciones;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEntidad, cCuenta, cInstrucciones;
		END IF;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT entidad, cuenta, intrucciones
		INTO cEntidad, cCuenta, cInstrucciones
		FROM bdicnweb:"informix".sw_ro_cuentasconocidas 
		WHERE id_expediente = pIdExpediente 
		AND id_solicitud_especifica = pIdSolEspecifica
		AND id_persona = pIdPersona;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, TRIM(UPPER(cEntidad)), TRIM(cCuenta), TRIM(cInstrucciones);
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 01/12/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CARGA DE ARCHIVOS XML', 
'DESCRIPCION: SPL que hace la consulta para obtener el detalle de cuentas conocidas de la Solicitud Especifica Archivo XML.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_extraevalor_tagxml(pIdRow INTEGER, pEtiqueta VARCHAR(50))
                RETURNING CHAR(5) AS cod_ret,
                        LVARCHAR(32739) AS valor_tag;
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cValor LVARCHAR(32739);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cValor = '';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cValor;
                END EXCEPTION;
                
                -- SET DEBUG FILE TO '/tmp/mfinis/sp_ro_extraevalor_tagxml.out';
                -- TRACE ON;
                
                IF pIdRow IS NULL OR pEtiqueta = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cValor;
                END IF;
                
                SET ISOLATION TO DIRTY READ;

                SELECT REPLACE(REPLACE(TRIM(REPLACE(REPLACE(REPLACE(xmlfile_data, pEtiqueta, ''), '/>', '>'), '<>', '')),chr(13) || chr(10),''),chr(9),'')
                INTO cValor
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE id_registro = pIdRow;

                RETURN cCodRet, cValor;

        END;

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 24/11/2015',
'MODULO: Oficios',
'FUNCIONALIDAD: Carga de archivos XML',
'DESCRIPCION: Busca una etiqueta dentro de la cadena XML regresa el valor',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_instruccionescuentasxconocerarchivoxml(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			INTEGER AS id_solicitud_especifica,
            CHAR (9000) AS instrucciones_cxc;
			
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdExpediente INTEGER;
	DEFINE iIdSolicitudEsp INTEGER;
	DEFINE cInstruccionesCxC CHAR (9000);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdExpediente = 0;
	LET iIdSolicitudEsp = 0;
	LET cInstruccionesCxC = '';
	LET iRecuperacion = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdSolicitudEsp, cInstruccionesCxC;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_instruccionescuentasxconocerarchivoxml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdSolicitudEsp, cInstruccionesCxC;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iIdSolicitudEsp, cInstruccionesCxC;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdSolicitudEsp, cInstruccionesCxC;
		END IF;
	
		SET ISOLATION TO DIRTY READ;
			
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion id_solicitud_especifica, instrucciones_cuentas_x_conocer
			INTO iIdSolicitudEsp, cInstruccionesCxC
			FROM bdicnweb:"informix".sw_ro_solicitudespecifica 
			WHERE id_expediente = pIdExpediente
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, iIdSolicitudEsp, TRIM(UPPER(cInstruccionesCxC)) WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			IF pRecuperacion = 0 THEN
				LET cCodRet = '00017';
			ELIF pRecuperacion > 0 THEN
				LET cCodRet = '1001';
			END IF;
			
			RETURN cCodRet, iIdSolicitudEsp, TRIM(UPPER(cInstruccionesCxC));
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 24/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CARGA DE ARCHIVOS XML', 
'DESCRIPCION: SPL que hace la consulta de las instruciones cuentas por conocer del Detalle Solicitud Especifica Archivo XML.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_procesaencabezadoxml(pUsuario CHAR(8), pIdFuncion CHAR(10))
                RETURNING CHAR(5) AS codret,
                        CHAR(60) AS num_oficio,
                        INTEGER AS id_oficio;
                
        DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(5);
        DEFINE iSqlErr INTEGER;
        
        --Declaro Encabezado
        DEFINE iNumIndiceEnc INTEGER;
        DEFINE iTopeEnc INTEGER;
        DEFINE cNumOficio CHAR(60);
        DEFINE cNumExpediente CHAR(60);
        DEFINE cSolSiara CHAR(60);
        DEFINE iNumFolio INTEGER;
        DEFINE cAnioOficio CHAR(4);
        DEFINE cIdArea CHAR(2);
        DEFINE cDescArea CHAR(30);
        DEFINE dFechaPublicacion CHAR(10);
        DEFINE cDiazPlazo CHAR(2);
        DEFINE cNomAutoridad CHAR(60);
        DEFINE cNomAutoridadEsp CHAR(60);
        DEFINE cNomSolicitante CHAR(60);
        DEFINE cReferencia CHAR(60);
        DEFINE cReferencia1 CHAR(60);
        DEFINE cReferencia2 CHAR(60);
        DEFINE cAseguramiento CHAR(5);
        DEFINE iTotalRegistros INTEGER; 
        DEFINE iIdOficio INTEGER;
        
        LET cCodRet = '00000';
        LET cCodRetSp = '';
        LET iSqlErr = 0;
        
        --Inicializo Encabezado
        LET iNumIndiceEnc = 0;
        LET iTopeEnc = 0;
        LET cNumOficio = '';
        LET cNumExpediente = '';
        LET cSolSiara = '';
        LET iNumFolio = 0;
        LET cAnioOficio = '';
        LET cIdArea = '';
        LET cDescArea = '';
        LET dFechaPublicacion = '';
        LET cDiazPlazo = '';
        LET cNomAutoridad = '';
        LET cNomAutoridadEsp = '';
        LET cNomSolicitante = '';
        LET cReferencia = '';
        LET cReferencia1 = '';
        LET cReferencia2 = '';
        LET cAseguramiento = '';
        LET iTotalRegistros = 0;
        LET iIdOficio = 0;
        
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet,cNumOficio,iIdOficio;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_ro_procesaencabezadoxml.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet,cNumOficio,iIdOficio;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet,cNumOficio,iIdOficio;
                END IF;
                
                SET ISOLATION TO DIRTY READ;
                
                -- Numero de oficio
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Cnbv_NumeroOficio>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Cnbv_NumeroOficio') INTO cCodRetSp, cNumOficio;
                
                -- Numero de expediente
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Cnbv_NumeroExpediente>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Cnbv_NumeroExpediente') INTO cCodRetSp, cNumExpediente;
                
                -- Numero de oslicitud siara
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Cnbv_SolicitudSiara>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Cnbv_SolicitudSiara') INTO cCodRetSp, cSolSiara;

                -- Numero de folio
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Cnbv_Folio>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Cnbv_Folio') INTO cCodRetSp, iNumFolio;
                
                -- Anio de oficio
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Cnbv_OficioYear>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Cnbv_OficioYear') INTO cCodRetSp, cAnioOficio;
                
                -- Clave de area
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Cnbv_AreaClave>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Cnbv_AreaClave') INTO cCodRetSp, cIdArea;
                
                -- Descripcion de area
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Cnbv_AreaDescripcion>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Cnbv_AreaDescripcion') INTO cCodRetSp, cDescArea;
                
                -- Fecha de publicación
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Cnbv_FechaPublicacion>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Cnbv_FechaPublicacion') INTO cCodRetSp, dFechaPublicacion;
                
                -- Dias plazo
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Cnbv_DiasPlazo>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Cnbv_DiasPlazo') INTO cCodRetSp, cDiazPlazo;
                
                -- Nombre de autoridad
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<AutoridadNombre>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'AutoridadNombre') INTO cCodRetSp, cNomAutoridad;
                
                -- Nombre de autoridad especifica
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<AutoridadEspecificaNombre>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'AutoridadEspecificaNombre') INTO cCodRetSp, cNomAutoridadEsp;
                
                -- Nombre Solicitante
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<NombreSolicitante>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'NombreSolicitante') INTO cCodRetSp, cNomSolicitante;
                
                -- Referencia
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Referencia>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Referencia') INTO cCodRetSp, cReferencia;
                
                -- Referencia 1 
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Referencia1>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Referencia1') INTO cCodRetSp, cReferencia1;
                
                -- Referencia 2
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Referencia2>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Referencia2') INTO cCodRetSp, cReferencia2;
                
                -- Tiene aseguramiento
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<TieneAseguramiento>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'TieneAseguramiento') INTO cCodRetSp, cAseguramiento;
                
                -- Guardado de los datos
                INSERT INTO bdicnweb:"informix".sw_ro_encabezadoexparchxml(num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,
                        fecha_publicacion,dias_plazo,nombre_autoridad,nombre_autoridad_especifica,nombre_solicitante,referencia,referencia1,referencia2,
                        aseguramiento,total_registros,usuario_insert,fecha_insert)
                VALUES(NVL(cNumOficio,''),NVL(cNumExpediente,''),NVL(cSolSiara,''),NVL(iNumFolio,''),NVL(cAnioOficio,''),NVL(cIdArea,''),NVL(cDescArea,''),
                        NVL(dFechaPublicacion,''),NVL(cDiazPlazo,''),NVL(cNomAutoridad,''),NVL(cNomAutoridadEsp,''),NVL(cNomSolicitante,''),
                        NVL(cReferencia,''),NVL(cReferencia1,''),NVL(cReferencia2,''),NVL(cAseguramiento,''),NVL(iTotalRegistros,''),NVL(pUsuario,''),CURRENT);
                
                
                SELECT MAX(id_expediente)
                INTO iIdOficio 
                FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml
                WHERE num_oficio = TRIM(cNumOficio);
                
                RETURN cCodRet, TRIM(cNumOficio), iIdOficio;
                
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat León Amador',
'FECHA: 11/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CARGA DE ARCHIVOS XML', 
'DESCRIPCION: SPL que se encarga del llenado de las tablas, de acuerdo al contenido del archivo xml procesado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_procesararchivoxml(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(60) AS num_oficio,
			INTEGER AS id_oficio;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNumOficio CHAR(60);
	DEFINE iIdOficio INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cNumOficio = '';
	LET iIdOficio = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumOficio, iIdOficio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_procesararchivoxml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumOficio, iIdOficio;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumOficio, iIdOficio;
		END IF;
		
		-- 1. Procesar el encabezado del archivo
		EXECUTE PROCEDURE "informix".sp_ro_procesaencabezadoxml(pUsuario, pIdFuncion) INTO cCodRetSp, cNumOficio, iIdOficio;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ''informix''.sp_ro_procesaencabezadoxml';
		ELIF iCodRetSp > 0 THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, cNumOficio, iIdOficio;
		END IF;
		
		-- 2. Procesamiento de las solicitudes partes
		EXECUTE PROCEDURE "informix".sp_ro_procesarsolic_partes(pUsuario, pIdFuncion, iIdOficio) INTO cCodRetSp;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP "informix".sp_ro_procesarsolic_partes';
		ELIF iCodRetSp > 0 THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, cNumOficio, iIdOficio;
		END IF;
		
		-- 3. Procesamiento de las solicitudes especificas
		EXECUTE PROCEDURE "informix".sp_ro_procesarsolic_especifica(pUsuario, pIdFuncion, iIdOficio) INTO cCodRetSp;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP "informix".sp_ro_procesarsolic_especifica';
		ELIF iCodRetSp > 0 THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, cNumOficio, iIdOficio;
		END IF;
		
		DELETE FROM "informix".oficios_xml_tmp;
		
		RETURN cCodRet, cNumOficio, iIdOficio;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 24/11/2015',
'MODULO: Oficios',
'FUNCIONALIDAD: Carga de archivos XML de oficios',
'DESCRIPCION: Procesa un archivo XML cargado en una tabla temporal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_procesarsolic_especifica(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER)
                RETURNING CHAR(5) AS codret;
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(5);
        DEFINE iCodRetSp INTEGER;
        DEFINE iIdSolicitudEspecifica INTEGER;
        DEFINE iIdRowMinEspecifica INTEGER;
        DEFINE iIdRowMaxEspecifica INTEGER;
        DEFINE iIdRowMin INTEGER;
        DEFINE iIdRowMax INTEGER;
        DEFINE iIdRow INTEGER;
        DEFINE iIdMinRowInstruccionesXConocer INTEGER;
        DEFINE iIdMaxRowInstruccionesXConocer INTEGER;
        DEFINE iPersonaId INTEGER;
        DEFINE cCaracter CHAR(30);
        DEFINE cDescTipoPersona CHAR(10);
        DEFINE cApellidoPaterno CHAR(26);
        DEFINE cApellidoMaterno CHAR(26);
        DEFINE cNombre CHAR(150);
        DEFINE cRfc CHAR(15);
        DEFINE cRelacion CHAR(50);
        DEFINE cDomicilio CHAR(150);
        DEFINE cComplementarios CHAR(50);
        DEFINE cInstruccionesCuentasPorConocer LVARCHAR(2000);
        
        DEFINE cEntidad CHAR(50);
        DEFINE cCuenta CHAR(20);
        DEFINE cInstrucciones LVARCHAR(2500);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET iIdSolicitudEspecifica = 0;
        LET iIdRowMinEspecifica = 0;
        LET iIdRowMaxEspecifica = 0;
        LET iIdRowMin = 0;
        LET iIdRowMax = 0;
        LET iIdRow = 0;
        LET iIdMinRowInstruccionesXConocer = 0;
        LET iIdMaxRowInstruccionesXConocer = 0;
        
        LET cInstruccionesCuentasPorConocer = '';
        LET iPersonaId = 0;
        LET cCaracter = '';
        LET cDescTipoPersona = '';
        LET cApellidoPaterno = '';
        LET cApellidoMaterno = '';
        LET cNombre = '';
        LET cRfc = '';
        LET cRelacion = '';
        LET cDomicilio = '';
        LET cComplementarios = '';
        
        LET cEntidad = '';
        LET cCuenta = '';
        LET cInstrucciones = '';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_ro_procesarsolic_especifica.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet;
                END IF;
                
                SET ISOLATION TO DIRTY READ;
                
                FOREACH SELECT id_registro
                        INTO iIdRowMinEspecifica
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<SolicitudEspecifica>%'
                        
                        SELECT first 1 id_registro
                        INTO iIdRowMaxEspecifica
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '</SolicitudEspecifica>%'
                        AND id_registro > iIdRowMin;
                                
                        -- Id. solicitud
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<SolicitudEspecificaId>%'
                        AND id_registro > iIdRowMinEspecifica AND id_registro < iIdRowMaxEspecifica;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'SolicitudEspecificaId') INTO cCodRetSp, iIdSolicitudEspecifica;
                        
                        -- Instrucciones cuentas por conocer
                        SELECT id_registro
                        INTO iIdMinRowInstruccionesXConocer
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<InstruccionesCuentasPorConocer>%'
                        AND id_registro > iIdRowMinEspecifica AND id_registro < iIdRowMaxEspecifica;
                                
                        SELECT FIRST 1 id_registro
                        INTO iIdMaxRowInstruccionesXConocer
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '%</InstruccionesCuentasPorConocer>%'
                        AND id_registro >= iIdMinRowInstruccionesXConocer;
                                
                        
                        FOREACH SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE id_registro BETWEEN iIdMinRowInstruccionesXConocer AND iIdMaxRowInstruccionesXConocer
                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'InstruccionesCuentasPorConocer') INTO cCodRetSp, cInstruccionesCuentasPorConocer;
                                
                                INSERT INTO bdicnweb:"informix".sw_ro_solicitudespecifica(id_expediente, id_solicitud_especifica, instrucciones_cuentas_x_conocer)
                                VALUES (pIdExpediente, iIdSolicitudEspecifica, TRIM(cInstruccionesCuentasPorConocer));
                        
                        END FOREACH;
                        
                        -- Esta parte de abajo ya funciona
                        FOREACH SELECT id_registro
                                INTO iIdRowMin
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<PersonasSolicitud>%'
                                AND id_registro > iIdRowMinEspecifica AND id_registro < iIdRowMaxEspecifica
                                
                                SELECT first 1 id_registro
                                INTO iIdRowMax
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '</PersonasSolicitud>%'
                                AND id_registro > iIdRowMin;
                                        
                                --      Id. Persona
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<PersonaId>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'PersonaId') INTO cCodRetSp, iPersonaId;
                                
                                --      Caracter
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Caracter>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Caracter') INTO cCodRetSp, cCaracter;
                                
                                --      Persona
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Persona>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Persona') INTO cCodRetSp, cDescTipoPersona;
                                
                                --      Paterno
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Paterno>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Paterno') INTO cCodRetSp, cApellidoPaterno;
                                
                                --      Materno
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Materno>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Materno') INTO cCodRetSp, cApellidoMaterno;
                                
                                --      Nombre
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Nombre>%'
								AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Nombre') INTO cCodRetSp, cNombre;
                                
                                --      RFC
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Rfc>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Rfc') INTO cCodRetSp, cRfc;
                                
                                --      Relacion
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Relacion>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Relacion') INTO cCodRetSp, cRelacion;
                                
                                --      Domicilio
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Domicilio>%'
								AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Domicilio') INTO cCodRetSp, cDomicilio;
                                
                                --      Complementarios
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Complementarios>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Complementarios') INTO cCodRetSp, cComplementarios;
                                
                                -- INSERCIÃN EN TABLA
                                INSERT INTO bdicnweb:"informix".sw_ro_personassolicitud(id_expediente, id_solicitud_especifica, id_persona, caracter, des_tipo_persona, 
                                        ap_paterno, ap_materno, nombre, rfc, relacion, domicilio, complementarios)
                                VALUES (pIdExpediente, iIdSolicitudEspecifica, iPersonaId, cCaracter, cDescTipoPersona, cApellidoPaterno, cApellidoMaterno, cNombre, cRfc, 
                                                cRelacion, cDomicilio, cComplementarios);
                                
                                -- CUENTAS CONOCIDAS
                                FOREACH SELECT id_registro
                                        INTO iIdRowMin
                                        FROM bdicnweb:"informix".oficios_xml_tmp
                                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<CuentasConocidas>%'
                                        AND id_registro > iIdRowMin AND id_registro < iIdRowMax
                                        
                                        SELECT first 1 id_registro
                                        INTO iIdRowMax
                                        FROM bdicnweb:"informix".oficios_xml_tmp
                                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '</CuentasConocidas>%'
                                        AND id_registro > iIdRowMin;
                                
                                        --      Entidad
                                        SELECT id_registro
                                        INTO iIdRow
                                        FROM bdicnweb:"informix".oficios_xml_tmp
                                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Entidad>%'
                                        AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                                
                                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Entidad') INTO cCodRetSp, cEntidad;
                                        
                                        --      Cuenta
                                        SELECT id_registro
                                        INTO iIdRow
                                        FROM bdicnweb:"informix".oficios_xml_tmp
                                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Cuenta>%'
                                        AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                                
                                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Cuenta') INTO cCodRetSp, cCuenta;
                                        
                                        --Instrucciones
                                        SELECT id_registro
                                        INTO iIdRow
                                        FROM bdicnweb:"informix".oficios_xml_tmp
                                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Instrucciones>%'
                                        AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                                
                                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Instrucciones') INTO cCodRetSp, cInstrucciones;
                                        
                                        -- INSERCIÃN EN TABLA
                                        INSERT INTO bdicnweb:"informix".sw_ro_cuentasconocidas(id_expediente, id_solicitud_especifica, id_persona, entidad, cuenta, intrucciones)
                                        VALUES (pIdExpediente, iIdSolicitudEspecifica, iPersonaId, cEntidad, cCuenta, cInstrucciones);
                                
                                END FOREACH;
                                
                        END FOREACH;
                END FOREACH;
                
                RETURN cCodRet;
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 24/11/2015',
'MODULO: Oficios',
'FUNCIONALIDAD: Carga de archivos XML de oficios',
'DESCRIPCION: Prodcesa la parte de solicitudes especificas del archivo xml cargado',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_procesarsolic_partes(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER)
                RETURNING CHAR(5) AS codret;
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(5);
        DEFINE iCodRetSp INTEGER;
        DEFINE iIdSolicitudEspecifica INTEGER;
        DEFINE iIdRowMin INTEGER;
        DEFINE iIdRowMax INTEGER;
        DEFINE iIdRow INTEGER;
        DEFINE iParteId INTEGER;
        DEFINE cCaracter CHAR(30);
        DEFINE cDescTipoPersona CHAR(10);
        DEFINE cApellidoPaterno CHAR(26);
        DEFINE cApellidoMaterno CHAR(26);
        DEFINE cNombre CHAR(150);
        DEFINE cRfc CHAR(15);
        DEFINE cRelacion CHAR(50);
        DEFINE cDomicilio CHAR(150);
        DEFINE cComplementarios CHAR(50);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET iIdSolicitudEspecifica = 0;
        LET iIdRowMin = 0;
        LET iIdRowMax = 0;
        LET iIdRow = 0;
        
        
        LET iParteId = 0;
        LET cCaracter = '';
        LET cDescTipoPersona = '';
        LET cApellidoPaterno = '';
        LET cApellidoMaterno = '';
        LET cNombre = '';
        LET cRfc = '';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_ro_procesarsolic_partes.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet;
                END IF;
                
                SET ISOLATION TO DIRTY READ;
                FOREACH SELECT id_registro
                        INTO iIdRowMin
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<SolicitudPartes>%'
                        
                        SELECT first 1 id_registro
                        INTO iIdRowMax
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '</SolicitudPartes>%'
                                AND id_registro > iIdRowMin;
                        
                        --      Id. Parte
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<ParteId>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'ParteId') INTO cCodRetSp, iParteId;
                        
                        --      Caracter
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<Caracter>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Caracter') INTO cCodRetSp, cCaracter;
                        
                        --      Persona
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<Persona>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Persona') INTO cCodRetSp, cDescTipoPersona;
                        
                        --      Paterno
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<Paterno>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Paterno') INTO cCodRetSp, cApellidoPaterno;
                        
                        --      Materno
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<Materno>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Materno') INTO cCodRetSp, cApellidoMaterno;
                        
                        --      Nombre
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<Nombre>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Nombre') INTO cCodRetSp, cNombre;
                        
                        --      RFC
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<Rfc>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Rfc') INTO cCodRetSp, cRfc;
                        
                        -- INSERCIÓN EN TABLA
                        INSERT INTO bdicnweb:"informix".sw_ro_solicitudpartes(id_expediente, id_persona, caracter, des_tipo_persona, ap_paterno, ap_materno, nombre, rfc)
                        VALUES (pIdExpediente, iParteId, cCaracter, cDescTipoPersona, cApellidoPaterno, cApellidoMaterno, cNombre, cRfc);
                        
                END FOREACH;
                
                RETURN cCodRet;
        END;
        
END PROCEDURE;