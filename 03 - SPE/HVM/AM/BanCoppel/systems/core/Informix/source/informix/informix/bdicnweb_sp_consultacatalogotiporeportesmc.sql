CREATE PROCEDURE "informix".sp_consultacatalogotiporeportesmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoCampania SMALLINT, pNumParametro INTEGER, pGrupoParametro CHAR(10))
	RETURNING CHAR(5) AS codret,
			CHAR(100) AS valor_texto,
			DECIMAL(18,2) AS valor_numero;
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cMensajeSp CHAR(100);
	DEFINE cValorTexto CHAR(100);
	DEFINE dValorNumero DECIMAL(18,2);
	DEFINE iCodRetorno INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cMensajeSp = '';
	LET cValorTexto = '';
	LET dValorNumero = NULL;
	LET iCodRetorno = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cValorTexto, dValorNumero;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultacatalogotiporeportesmc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoCampania IS NULL OR pGrupoParametro = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cValorTexto, dValorNumero;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cValorTexto, dValorNumero;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdicobranza:'informix'.sp_consultacampaniasctrl(cEmpresa, pTipoCampania, pNumParametro, pGrupoParametro)
					INTO cCodRetSp, cMensajeSp, cValorTexto, dValorNumero
					
			LET iCodRetorno = cCodRetSp::INTEGER;
			IF iCodRetorno < 0 THEN
				RAISE EXCEPTION iCodRetorno, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultacampaniasctrl';
			ELIF iCodRetorno = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cValorTexto, dValorNumero;
			ELIF iCodRetorno = 2 THEN
				LET cCodRet = '00030'; -- NO SE ENCONTRARON REGITROS CON LOS CITERIOS SELECCIONADOS
				RETURN cCodRet, cValorTexto, dValorNumero;
			ELSE
				RETURN cCodRet, cValorTexto, dValorNumero WITH RESUME;
			END IF;
			
		END FOREACH;
		
	END;
			
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 04/03/2014',
'DESCRIPCION: Consulta informaciÃ³n estÃ¡ndard para las aplicaciones de Cobranzas, usado en Mesa de Control',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultadesdocumentosctemc(pUsuario CHAR(8), pIdFuncion CHAR(10), pClienteCoppel CHAR(20))
	RETURNING CHAR(5) AS codret,
			CHAR(35) AS descripcion;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cDescripcion CHAR(35);
	DEFINE iNoRegs INTEGER;
	
	LET cCodRet = '';
	LET iSqlErr = 0;
	LET cDescripcion = '';
	LET iNoRegs = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultadesdocumentosctemc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pClienteCoppel = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT DISTINCT tipo.descripcion 
				INTO cDescripcion
				FROM bdidigital@coppelimg_tcp:dg_tipodocumento AS tipo 
				LEFT OUTER JOIN bdidigital@coppelimg_tcp:dg_expediente AS exp ON (tipo.cod_docto = exp.cod_docto)
				WHERE exp.cliente = pClienteCoppel
				
				RETURN cCodRet, UPPER(cDescripcion) WITH RESUME;
		END FOREACH;
		
		LET iNoRegs = DBINFO('sqlca.sqlerrd2');
		IF iNoRegs = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cDescripcion;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 04/03/2014',
'DESCRIPCION: Consulta la descripcion de los documentos presentados por el cliente para Mesa de Control',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainforeportebc_alertahawk(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumcte CHAR(20))
	RETURNING CHAR(5) AS codret,
			CHAR(2) AS institucion,
			CHAR(20) AS num_cliente,
			DATE AS fecha_reportehi,
			CHAR(3) AS clave_hi,
			CHAR(16) AS otorgante_hi,
			CHAR(48) AS mensaje_hi,
			DATE AS fecha_reportehr,
			CHAR(3) AS clave_hr,
			CHAR(16) AS otorgante_hr,
			CHAR(48) AS mensaje_hr;
	
	--DEFINICION DE VARIABLES
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cInstitucion CHAR(2); 
	DEFINE cNumCliente CHAR(20);
	DEFINE dFechaReportehi DATE;	
	DEFINE cClaveHi CHAR(3);	
	DEFINE cOtorganteHi CHAR(16);		
	DEFINE cMensajeHi CHAR(48);		
	DEFINE dFechaReportehr DATE;		
	DEFINE cClaveHr CHAR(3);			
	DEFINE cOtorganteHr CHAR(16);			
	DEFINE cMensajeHr CHAR(48);
	
	--INICIALIZACION DE VARIABLES
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET iSqlErr = 0;
	LET cInstitucion = ''; 
	LET cNumCliente = '';
	LET dFechaReportehi = NULL; 
    LET	cClaveHi = '';	
	LET	cOtorganteHi = '';		
	LET	cMensajeHi = '';			
	LET	dFechaReportehr = NULL;	
	LET	cClaveHr = '';		
	LET	cOtorganteHr = '';		
	LET	cMensajeHr = '';

	BEGIN
	  
	    ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cInstitucion, cNumCliente, dFechaReportehi, cClaveHi, cOtorganteHi, 
				cMensajeHi,	dFechaReportehr, cClaveHr, cOtorganteHr, cMensajeHr;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultainforeportebc_alertahawk.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumcte = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cInstitucion, cNumCliente, dFechaReportehi, cClaveHi, cOtorganteHi, 
				cMensajeHi,	dFechaReportehr, cClaveHr, cOtorganteHr, cMensajeHr;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cInstitucion, cNumCliente, dFechaReportehi, cClaveHi, cOtorganteHi, 
				cMensajeHi,	dFechaReportehr, cClaveHr, cOtorganteHr, cMensajeHr;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		SELECT 
		    a.institucion, 
	        a.num_cliente, 
	        a.hihi, 
	        a.hi00, 
	        a.hi01, 
	        a.hi02, 
	        b.hrhr, 
	        b.hr00, 
	        b.hr01,
	        b.hr02
		INTO cInstitucion, cNumCliente, dFechaReportehi, cClaveHi, cOtorganteHi, cMensajeHi, dFechaReportehr, cClaveHr, cOtorganteHr, cMensajeHr
        FROM bdiburo:br_hi a LEFT OUTER JOIN bdiburo:br_hr b ON a.institucion = b.institucion AND a.num_cliente = b.num_cliente
        WHERE a.institucion = 'BC' AND a.num_cliente = pNumcte
        GROUP BY 1,2,3,4,5,6,7,8,9,10;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, cInstitucion, cNumCliente, dFechaReportehi, cClaveHi, cOtorganteHi, 
				cMensajeHi,	dFechaReportehr, cClaveHr, cOtorganteHr, cMensajeHr;
					
	END;	
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 11/03/2014',
'DESCRIPCION: Genera un reporte que muestra los mensajes de alerta hawk del cliente, Mesa de Control',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainforeportebc_datosgenerales(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumcte CHAR(20))
	RETURNING CHAR(5) AS codret,
			CHAR(2) AS institucion,
			CHAR(20) AS num_cliente,
			DATE AS fecha_consulta,
			CHAR(26) AS apellido1,
			CHAR(26) AS apellido2,
			CHAR(26) AS nombre1,
			CHAR(26) AS nombre2,
			DATE AS fecha_nacimiento,
			CHAR(13) AS rfc,
			DATE AS registro_bc;
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cInstitucion CHAR(2); 
	DEFINE cNumCliente CHAR(20);
	DEFINE dFechaConsulta DATE; 
	DEFINE cApellido1 CHAR(26);
	DEFINE cApellido2 CHAR(26);
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE dFechaNacimiento DATE; 
	DEFINE cRfc CHAR(13);
	DEFINE dRegistroBc DATE;
		
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET iSqlErr = 0;
	LET cInstitucion = ''; 
	LET cNumCliente = '';
	LET dFechaConsulta = NULL; 
	LET cApellido1 = '';
	LET cApellido2 = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET dFechaNacimiento = NULL; 
	LET cRfc = '';
	LET dRegistroBc = NULL;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cInstitucion, cNumCliente, dFechaConsulta,
				cApellido1, cApellido2, cNombre1, cNombre2, dFechaNacimiento, 
				cRfc, dRegistroBc;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultainforeportebc_datosgenerales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumcte = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cInstitucion, cNumCliente, dFechaConsulta,
				cApellido1, cApellido2, cNombre1, cNombre2, dFechaNacimiento, 
				cRfc, dRegistroBc;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cInstitucion, cNumCliente, dFechaConsulta,
				cApellido1, cApellido2, cNombre1, cNombre2, dFechaNacimiento, 
				cRfc, dRegistroBc;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		SELECT institucion, num_cliente, fecha_consulta, pnpn, pn00, pn02, pn03, pn04, pn05, rsrs
		INTO cInstitucion, cNumCliente, dFechaConsulta, cApellido1, cApellido2, cNombre1, cNombre2, dFechaNacimiento, cRfc, dRegistroBc
		FROM 
			(SELECT FIRST 1 a.institucion, 
				a.num_cliente, 
				a.fecha_consulta, 
				a.pnpn, 
				a.pn00, 
				a.pn02, 
				a.pn03, 
				a.pn04, 
				a.pn05,
				b.rsrs
			FROM bdiburo:br_pn a LEFT OUTER JOIN bdiburo:br_rs b ON a.institucion = b.institucion AND a.num_cliente = b.num_cliente
			WHERE a.institucion = 'BC' AND a.num_cliente = pNumcte
			GROUP BY 1,2,3,4,5,6,7,8,9,10
			ORDER BY 10 DESC);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, cInstitucion, cNumCliente, dFechaConsulta,
				cApellido1, cApellido2, cNombre1, cNombre2, dFechaNacimiento, 
				cRfc, dRegistroBc;
	
	END;	
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 06/03/2014',
'DESCRIPCION: Genera un reporte de los datos generales del cliente, Mesa de Control',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainforeportebc_detalle_creditos(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
			CHAR(2) AS institucion,
			CHAR(20) AS numcliente,
			DATE AS fechaactualizado,
			CHAR(16) AS otorgamientocuenta,
			CHAR(2) AS moneda,
			MONEY(14,2) AS montopagar,
			DATE AS fechaapertura,
			DATE AS fechaultimopago,
			DATE AS fechaultimacompra,
			DATE AS fechacierre,
			DATE AS fechaultimavezsaldo,
			MONEY(14,6) AS importecreditomaximo,
			MONEY(14,6) AS importesaldoactual,
			MONEY(14,6) AS importelimitecredito,
			MONEY(14,6) AS importemonto,
			CHAR(2) AS formapagofechaactualizacion,
			CHAR(2) AS claveobservacion,
			MONEY(14,2) AS mopimporte,
			DATE AS mopfecha,
			CHAR(2) AS maxmoratorios,
			CHAR(40) AS responsabilidad,
			CHAR(40) AS tipocredito,
			CHAR(40) AS tipopago,
			CHAR(40) AS descforma_pago,
			CHAR(40) AS observaciones,
			INTEGER AS fanios,
			INTEGER AS afin,
			INTEGER AS aini,
			CHAR(2) AS fini2,
			CHAR(15) AS finter,
			CHAR(15) AS faini,
			CHAR(12) AS fmes1,
			CHAR(12) AS fmes2,
			CHAR(12) AS fmes3;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cInstitucion CHAR(2);
	DEFINE cNumCliente CHAR(20);
	DEFINE dFechaActualizado DATE;
	DEFINE cOtorgamientoCuenta CHAR(16);
	DEFINE cMoneda CHAR(2);
	DEFINE mMontoPagar MONEY(14,2);
	DEFINE dFechaApertura DATE;
	DEFINE dFechaUltimoPago DATE;
	DEFINE dFechaUltimaCompra DATE;
	DEFINE dFechaCierre DATE;
	DEFINE dFechaUltimaVezSaldo DATE;
	DEFINE mImporteCreditoMaximo MONEY(14,6);
	DEFINE mImporteSaldoActual MONEY(14,6);
	DEFINE mImporteLimiteCredito MONEY(14,6);
	DEFINE mImporteMonto MONEY(14,6);
	DEFINE cFormaPagoFechaActualizacion CHAR(2);
	DEFINE cValorX CHAR(24);
	DEFINE dFecha2 DATE;
	DEFINE cClaveObservacion CHAR(2);
	DEFINE mMopImporte MONEY(14,2);
	DEFINE dMopFecha DATE;
	DEFINE cMaxMoratorios CHAR(2);
	DEFINE cResponsabilidad CHAR(40);
	DEFINE cTipoCredito CHAR(40);
	DEFINE cTipoPago CHAR(40);
	DEFINE cDescFormaPago CHAR(40);
	DEFINE cObservaciones CHAR(40);
	DEFINE fanios INTEGER;
	DEFINE afin INTEGER;
	DEFINE aini INTEGER;
	DEFINE fini2 CHAR(2);
	DEFINE finter CHAR(15);
	DEFINE faini CHAR(15);
	DEFINE fmes1 CHAR(12);
	DEFINE fmes2 CHAR(12);
	DEFINE fmes3 CHAR(12);
	DEFINE iRegistros INTEGER;
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cInstitucion = '';
	LET cNumCliente = '';
	LET dFechaActualizado = NULL;
	LET cOtorgamientoCuenta = '';
	LET cMoneda = '';
	LET mMontoPagar = NULL;
	LET dFechaApertura = NULL;
	LET dFechaUltimoPago = NULL;
	LET dFechaUltimaCompra = NULL;
	LET dFechaCierre = NULL;
	LET dFechaUltimaVezSaldo = NULL;
	LET mImporteCreditoMaximo = NULL;
	LET mImporteSaldoActual = NULL;
	LET mImporteLimiteCredito = NULL;
	LET mImporteMonto = NULL;
	LET cFormaPagoFechaActualizacion = '';
	LET cValorX = '';
	LET dFecha2 = NULL;
	LET cClaveObservacion = '';
	LET mMopImporte = NULL;
	LET dMopFecha = NULL;
	LET cMaxMoratorios = '';
	LET cResponsabilidad = '';
	LET cTipoCredito = '';
	LET cTipoPago = '';
	LET cDescFormaPago = '';
	LET cObservaciones = '';
	LET fanios = NULL;
	LET afin = NULL;
	LET aini = NULL;
	LET fini2 = '';
	LET finter = '';
	LET faini = '';
	LET fmes1 = '';
	LET fmes2 = '';
	LET fmes3 = '';
	LET iRegistros = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cInstitucion, cNumCliente, dFechaActualizado, cOtorgamientoCuenta, cMoneda, 
				mMontoPagar, dFechaApertura, dFechaUltimoPago, dFechaUltimaCompra, dFechaCierre, dFechaUltimaVezSaldo, 
				mImporteCreditoMaximo, mImporteSaldoActual, mImporteLimiteCredito, mImporteMonto, 
				cFormaPagoFechaActualizacion, cClaveObservacion, mMopImporte, dMopFecha, 
				cMaxMoratorios, cResponsabilidad, cTipoCredito, cTipoPago, cDescFormaPago, cObservaciones, 
				fanios, afin, aini, fini2, finter, faini, fmes1, fmes2, fmes3;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultainforeportebc_detalle_creditos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cInstitucion, cNumCliente, dFechaActualizado, cOtorgamientoCuenta, cMoneda, 
				mMontoPagar, dFechaApertura, dFechaUltimoPago, dFechaUltimaCompra, dFechaCierre, dFechaUltimaVezSaldo, 
				mImporteCreditoMaximo, mImporteSaldoActual, mImporteLimiteCredito, mImporteMonto, 
				cFormaPagoFechaActualizacion, cClaveObservacion, mMopImporte, dMopFecha, 
				cMaxMoratorios, cResponsabilidad, cTipoCredito, cTipoPago, cDescFormaPago, cObservaciones, 
				fanios, afin, aini, fini2, finter, faini, fmes1, fmes2, fmes3;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cInstitucion, cNumCliente, dFechaActualizado, cOtorgamientoCuenta, cMoneda, 
				mMontoPagar, dFechaApertura, dFechaUltimoPago, dFechaUltimaCompra, dFechaCierre, dFechaUltimaVezSaldo, 
				mImporteCreditoMaximo, mImporteSaldoActual, mImporteLimiteCredito, mImporteMonto, 
				cFormaPagoFechaActualizacion, cClaveObservacion, mMopImporte, dMopFecha, 
				cMaxMoratorios, cResponsabilidad, cTipoCredito, cTipoPago, cDescFormaPago, cObservaciones, 
				fanios, afin, aini, fini2, finter, faini, fmes1, fmes2, fmes3;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cInstitucion, cNumCliente, dFechaActualizado, cOtorgamientoCuenta, cMoneda, 
				mMontoPagar, dFechaApertura, dFechaUltimoPago, dFechaUltimaCompra, dFechaCierre, dFechaUltimaVezSaldo, 
				mImporteCreditoMaximo, mImporteSaldoActual, mImporteLimiteCredito, mImporteMonto, 
				cFormaPagoFechaActualizacion, cClaveObservacion, mMopImporte, dMopFecha, 
				cMaxMoratorios, cResponsabilidad, cTipoCredito, cTipoPago, cDescFormaPago, cObservaciones, 
				fanios, afin, aini, fini2, finter, faini, fmes1, fmes2, fmes3;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion a.institucion,
				a.num_cliente, a.tltl as fecha_actualizado, a.tl02 as otorgamiento_cuenta, a.tl08 as moneda,
				a.tl12 as monto_pagar, a.tl13 as fecha_apertura, a.tl14 as fecha_ultimo_pago, a.tl15 as fecha_ultima_compra,
				a.tl16 as fecha_cierre, a.tl19 as fecha_ultima_vez_saldo, a.tl21 as importe_credito_maximo, a.tl22 as importe_saldo_actual,
				a.tl23 as importe_limite_credito, a.tl24 as importe_monto, a.tl26 as fecha_actualizacion_forma_pago, 
				a.tl27 as x, a.tl28 as y, a.tl30 as clave_observacion, a.tl36 as mop_importe, a.tl37 as mop_fecha,
				a.tl38 as max_moratorios, b.descripcion as responsabilidad, c.descripcion as tipo_credito, d.descripcion as tipo_pago,
				e.descripcion as desc_forma_pago, f.descripcion as observaciones
			INTO cInstitucion, cNumCliente, dFechaActualizado, cOtorgamientoCuenta, 
				cMoneda, mMontoPagar, dFechaApertura, dFechaUltimoPago, 
				dFechaUltimaCompra, dFechaCierre, dFechaUltimaVezSaldo, mImporteCreditoMaximo, 
				mImporteSaldoActual, mImporteLimiteCredito, mImporteMonto, cFormaPagoFechaActualizacion, 
				cValorX, dFecha2, cClaveObservacion, mMopImporte, dMopFecha, cMaxMoratorios, 
				cResponsabilidad, cTipoCredito, cTipoPago, cDescFormaPago, cObservaciones
			FROM ((((bdiburo:br_tl a left join bdiburo:br_tlres b ON b.codigo = a.tl05)
				LEFT JOIN bdiburo:br_tlcta c ON c.codigo = a.tl06)
				LEFT JOIN bdiburo:br_tlfpg d ON d.codigo = a.tl11)
				LEFT JOIN bdiburo:br_tlmop e ON e.codigo = a.tl26)
				LEFT JOIN bdiburo:br_tlobs f ON f.codigo = a.tl30
			WHERE a.institucion = 'BC' AND a.num_cliente = pNumCliente
			
			LET fanios = YEAR(dFecha2) - 1;
			LET afin = YEAR(dFecha2);
			LET aini = YEAR(dFecha2) - 2;
			
			IF afin IS NOT NULL THEN
				LET fini2 = SUBSTR(TRIM(cValorX), 0, LENGTH(MONTH(dFecha2)||''));
			END IF;
			
			IF LENGTH(fini2) > 0 THEN
				LET finter = SUBSTR(cValorX, LENGTH(fini2) + 1, 12);
				LET faini = SUBSTR(cValorX, LENGTH(fini2) + LENGTH(finter) + 1, 12);
			END IF;
			
			LET fmes1 = DECODE(LENGTH(TRIM(fini2)), 1, 'E', 
								2, 'FE',
								3, 'MFE',
								4, 'AMFE',
								5, 'MAMFE',
								6, 'JMAMFE',
								7, 'JJMAMFE',
								8, 'AJJMAMFE',
								9, 'SAJJMAMFE',
								10, 'OSAJJMAMFE',
								11, 'NOSAJJMAMFE',
								12, 'DNOSAJJMAMFE', '');
			LET fmes2 = DECODE(LENGTH(TRIM(finter)), 1, 'E', 
								2, 'FE',
								3, 'MFE',
								4, 'AMFE',
								5, 'MAMFE',
								6, 'JMAMFE',
								7, 'JJMAMFE',
								8, 'AJJMAMFE',
								9, 'SAJJMAMFE',
								10, 'OSAJJMAMFE',
								11, 'NOSAJJMAMFE',
								12, 'DNOSAJJMAMFE', '');
			LET fmes3 = DECODE(LENGTH(TRIM(faini)), 1, 'E', 
								2, 'FE',
								3, 'MFE',
								4, 'AMFE',
								5, 'MAMFE',
								6, 'JMAMFE',
								7, 'JJMAMFE',
								8, 'AJJMAMFE',
								9, 'SAJJMAMFE',
								10, 'OSAJJMAMFE',
								11, 'NOSAJJMAMFE',
								12, 'DNOSAJJMAMFE', '');
								
			RETURN cCodRet, cInstitucion, cNumCliente, dFechaActualizado, cOtorgamientoCuenta, cMoneda, 
				mMontoPagar, dFechaApertura, dFechaUltimoPago, dFechaUltimaCompra, dFechaCierre, dFechaUltimaVezSaldo, 
				mImporteCreditoMaximo, mImporteSaldoActual, mImporteLimiteCredito, mImporteMonto, 
				cFormaPagoFechaActualizacion, cClaveObservacion, mMopImporte, dMopFecha, 
				cMaxMoratorios, cResponsabilidad, cTipoCredito, cTipoPago, cDescFormaPago, cObservaciones, 
				fanios, afin, aini, fini2, finter, faini, fmes1, fmes2, fmes3 WITH RESUME;
			
			LET iRegistros = iRegistros + 1;
			
		END FOREACH;
		
		IF iRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cInstitucion, cNumCliente, dFechaActualizado, cOtorgamientoCuenta, cMoneda, 
				mMontoPagar, dFechaApertura, dFechaUltimoPago, dFechaUltimaCompra, dFechaCierre, dFechaUltimaVezSaldo, 
				mImporteCreditoMaximo, mImporteSaldoActual, mImporteLimiteCredito, mImporteMonto, 
				cFormaPagoFechaActualizacion, cClaveObservacion, mMopImporte, dMopFecha, 
				cMaxMoratorios, cResponsabilidad, cTipoCredito, cTipoPago, cDescFormaPago, cObservaciones, 
				fanios, afin, aini, fini2, finter, faini, fmes1, fmes2, fmes3;
		ELIF iRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cInstitucion, cNumCliente, dFechaActualizado, cOtorgamientoCuenta, cMoneda, 
				mMontoPagar, dFechaApertura, dFechaUltimoPago, dFechaUltimaCompra, dFechaCierre, dFechaUltimaVezSaldo, 
				mImporteCreditoMaximo, mImporteSaldoActual, mImporteLimiteCredito, mImporteMonto, 
				cFormaPagoFechaActualizacion, cClaveObservacion, mMopImporte, dMopFecha, 
				cMaxMoratorios, cResponsabilidad, cTipoCredito, cTipoPago, cDescFormaPago, cObservaciones, 
				fanios, afin, aini, fini2, finter, faini, fmes1, fmes2, fmes3;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 11/03/2014',
'DOCUMENT: Consulta los detalles de los creditos para el reporte de burÃ³ de crÃ©dito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainforeportebc_domiciliosreportados(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20))
	RETURNING CHAR(5) AS codret,
			CHAR(2) AS institucion,
			CHAR(20) AS num_cliente,
			CHAR(40) AS calle,
			CHAR(40) AS calle2,
			CHAR(40) AS colonia,
			CHAR(40) AS delegacion_municipio,
			CHAR(40) AS ciudad,
			CHAR(4) AS estado,
			CHAR(5) AS cp,
			CHAR(11) AS telefono,
			DATE AS fecha_registro_en_bc;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cInstitucion CHAR(2);
	DEFINE cNumCliente CHAR(20);
	DEFINE cCalle CHAR(40);
	DEFINE cCalle2 CHAR(40);
	DEFINE cColonia CHAR(40);
	DEFINE cDelegacionMunicipio CHAR(40);
	DEFINE cCiudad CHAR(40);
	DEFINE cEstado CHAR(4);
	DEFINE cCp CHAR(5);
	DEFINE cTelefono CHAR(11);
	DEFINE dFechaRegistroBc DATE;
	DEFINE iNoRegs INTEGER;
	
	LET cCodRet = '';
	LET iSqlErr = 0;
	LET cInstitucion = '';
	LET cNumCliente = '';
	LET cCalle = '';
	LET cCalle2 = '';
	LET cColonia = '';
	LET cDelegacionMunicipio = '';
	LET cCiudad = '';
	LET cEstado = '';
	LET cCp = '';
	LET cTelefono = '';
	LET dFechaRegistroBc = NULL;
	LET iNoRegs = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cInstitucion, cNumCliente, cCalle, cCalle2, cColonia, cDelegacionMunicipio, 
			       cCiudad, cEstado, cCp, cTelefono, dFechaRegistroBc;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultainforeportebc_domiciliosreportados.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cInstitucion, cNumCliente, cCalle, cCalle2, cColonia, cDelegacionMunicipio, 
			       cCiudad, cEstado, cCp, cTelefono, dFechaRegistroBc;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cInstitucion, cNumCliente, cCalle, cCalle2, cColonia, cDelegacionMunicipio, 
			       cCiudad, cEstado, cCp, cTelefono, dFechaRegistroBc;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH SELECT a.institucion, a.num_cliente, papa as calle, pa00 as calle2, pa01 as colonia, pa02 as delmun
					, pa03 as ciudad, pa04 as estado, pa05 as cp, pa07 as telefono, pa12 as registro_en_bc
				INTO cInstitucion, cNumCliente, cCalle, cCalle2, cColonia, cDelegacionMunicipio, 
			       cCiudad, cEstado, cCp, cTelefono, dFechaRegistroBc
				FROM bdiburo:br_pa a
				WHERE a.institucion = 'BC' AND a.num_cliente = pNumCliente
				
			RETURN cCodRet, cInstitucion, cNumCliente, cCalle, cCalle2, cColonia, cDelegacionMunicipio, 
			       cCiudad, cEstado, cCp, cTelefono, dFechaRegistroBc WITH RESUME;	
		END FOREACH;
		
		LET iNoRegs = DBINFO('sqlca.sqlerrd2');
		IF iNoRegs = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cInstitucion, cNumCliente, cCalle, cCalle2, cColonia, cDelegacionMunicipio, 
			       cCiudad, cEstado, cCp, cTelefono, dFechaRegistroBc;	
		END IF;

	END;
			
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 07/03/2014',
'DESCRIPCION: Consulta los datos de los domicilios reportados en BC, Mesa de Control',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainforeportebc_ingresos(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20))
	RETURNING CHAR(5) AS codret, 
			CHAR(2) AS institucion,
			CHAR(20) AS numCliente,
			CHAR(40) AS compania,
			CHAR(40) AS calle1,
			CHAR(40) AS calle2,
			CHAR(40) AS colonia,
			CHAR(40) AS delmun,
			CHAR(40) AS ciudad,
			CHAR(4) AS estado,
			CHAR(5) AS cp,
			CHAR(11) AS telefono,
			CHAR(30) AS puesto,
			DATE AS fechaContratacion,
			MONEY(14,2) AS salario,
			CHAR(1) AS base,
			DATE AS ultimoDiaEmpleo,
			DATE AS registroBc;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cInstitucion CHAR(2);
	DEFINE cNumCliente CHAR(20);
	DEFINE cCompania CHAR(40);
	DEFINE cCalle1 CHAR(40);
	DEFINE cCalle2 CHAR(40);
	DEFINE cColonia CHAR(40);
	DEFINE cDelmun CHAR(40);
	DEFINE cCiudad CHAR(40);
	DEFINE cEstado CHAR(4);
	DEFINE cCp CHAR(5);
	DEFINE cTelefono CHAR(11);
	DEFINE cPuesto CHAR(30);
	DEFINE dFechaContratacion DATE;
	DEFINE mSalario MONEY(14,2);
	DEFINE cBase CHAR(1);
	DEFINE dUltimoDiaEmpleo DATE;
	DEFINE dRegistroBc DATE;
	DEFINE iNoRegs INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cInstitucion = '';
	LET cNumCliente = '';
	LET cCompania = '';
	LET cCalle1 = '';
	LET cCalle2 = '';
	LET cColonia = '';
	LET cDelmun = '';
	LET cCiudad = '';
	LET cEstado = '';
	LET cCp = '';
	LET cTelefono = '';
	LET cPuesto = '';
	LET dFechaContratacion = NULL;
	LET mSalario = NULL;
	LET cBase = '';
	LET dUltimoDiaEmpleo = NULL;
	LET dRegistroBc = NULL;
	LET iNoRegs = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cInstitucion, cNumCliente, cCompania, cCalle1, cCalle2, cColonia, cDelmun, cCiudad, cEstado, 
					cCp, cTelefono, cPuesto, dFechaContratacion, mSalario, cBase, dUltimoDiaEmpleo, dRegistroBc;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultainforeportebc_ingresos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cInstitucion, cNumCliente, cCompania, cCalle1, cCalle2, cColonia, cDelmun, cCiudad, cEstado, 
					cCp, cTelefono, cPuesto, dFechaContratacion, mSalario, cBase, dUltimoDiaEmpleo, dRegistroBc;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cInstitucion, cNumCliente, cCompania, cCalle1, cCalle2, cColonia, cDelmun, cCiudad, cEstado, 
					cCp, cTelefono, cPuesto, dFechaContratacion, mSalario, cBase, dUltimoDiaEmpleo, dRegistroBc;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH SELECT a.institucion,
					a.num_cliente,
					a.pepe as compania,
					a.pe00 as calle1,
					a.pe01 as calle2,
					a.pe02 as colonia,
					a.pe03 as delmun,
					a.pe04 as ciudad,
					a.pe05 as estado,
					a.pe06 as cp,
					a.pe07 as telefono,
					a.pe10 as puesto,
					a.pe11 as fecha_contratacion,
					a.pe13 as salario,
					a.pe14 as base,
					a.pe16 as ultimo_dia_empleo,
					a.pe17 as registro_en_bc
				INTO cInstitucion, cNumCliente, cCompania, cCalle1, cCalle2, cColonia, cDelmun, cCiudad, cEstado, 
					cCp, cTelefono, cPuesto, dFechaContratacion, mSalario, cBase, dUltimoDiaEmpleo, dRegistroBc
				FROM bdiburo:br_pe a
				WHERE a.institucion = 'BC' AND a.num_cliente = pNumCliente
				
			RETURN cCodRet, cInstitucion, cNumCliente, cCompania, cCalle1, cCalle2, cColonia, cDelmun, cCiudad, cEstado, 
					cCp, cTelefono, cPuesto, dFechaContratacion, mSalario, cBase, dUltimoDiaEmpleo, dRegistroBc WITH RESUME;	
		END FOREACH;
		
		LET iNoRegs = DBINFO('sqlca.sqlerrd2');
		IF iNoRegs = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cInstitucion, cNumCliente, cCompania, cCalle1, cCalle2, cColonia, cDelmun, cCiudad, cEstado, 
					cCp, cTelefono, cPuesto, dFechaContratacion, mSalario, cBase, dUltimoDiaEmpleo, dRegistroBc;
		END IF;

	END;
			
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 07/03/2014',
'DESCRIPCION: Consulta los datos de los domicilios reportados en BC, Mesa de Control',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainforeportebc_resumencreditos(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumcte CHAR(20))
	RETURNING CHAR(5) AS codret,
			CHAR(2) AS institucion,
			CHAR(20) AS num_cliente,
			INTEGER AS ctas_abiertas,
			MONEY(9,2) AS lim_abiertas,
			MONEY(9,2) AS max_abiertas,
			MONEY(10,2) AS saldo_act,
			MONEY(9,2) AS monto_abiertas,
			MONEY(9,2) AS pago_realizar,
			INTEGER AS ctas_cerradas,
			INTEGER AS ctas_mob00,
			INTEGER AS ctas_mob01,
			INTEGER AS ctas_mob02,
			INTEGER AS ctas_mob03,
			INTEGER AS ctas_mob04,
			INTEGER AS ctas_mob05,
            INTEGER AS ctas_mob06,
            INTEGER AS ctas_mob07,
			INTEGER AS ctas_mobur,
			INTEGER AS total_ctas;
			
	--DEFINICION DE VARIABLES
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cInstitucion CHAR(2); 
	DEFINE cNumCliente CHAR(20);
	DEFINE iCtasAbiertas INTEGER;
	DEFINE iLimAbiertas MONEY(9,2);
	DEFINE iMaxAbiertas MONEY(9,2);
	DEFINE iSaldoAct MONEY(10,2);
	DEFINE iMontoAbiertas MONEY(9,2);
	DEFINE iPagoRealizar MONEY(9,2);
	DEFINE iCtasCerradas INTEGER;
	DEFINE iCtasMob00 INTEGER;
	DEFINE iCtasMob01 INTEGER;
	DEFINE iCtasMob02 INTEGER;
	DEFINE iCtasMob03 INTEGER;
	DEFINE iCtasMob04 INTEGER;
	DEFINE mCtasMob05 INTEGER;	 	
	DEFINE mCtasMob06 INTEGER;		
	DEFINE mCtasMob07 INTEGER;		
	DEFINE mCtasMobur INTEGER;		
	DEFINE mTotalCtas INTEGER;

    --INICIALIZACION DE VARIABLES
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET iSqlErr = 0;
	LET cInstitucion = ''; 
	LET cNumCliente = '';
	LET iCtasAbiertas = 0;
	LET iLimAbiertas = 0;
	LET iMaxAbiertas = 0;
	LET iSaldoAct = 0;
	LET iMontoAbiertas = 0;
	LET iPagoRealizar = 0;
	LET iCtasCerradas = 0;
	LET iCtasMob00 = 0;
	LET iCtasMob01 = 0;
	LET iCtasMob02 = 0;
	LET iCtasMob03 = 0;
	LET iCtasMob04 = 0;
	LET mCtasMob05 = 0;
	LET mCtasMob06 = 0;
	LET mCtasMob07 = 0;
	LET mCtasMobur = 0;
	LET mTotalCtas = 0;
	
	BEGIN
	  
	    ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cInstitucion, cNumCliente, iCtasAbiertas, iLimAbiertas, iMaxAbiertas, iSaldoAct, iMontoAbiertas,
				iPagoRealizar, iCtasCerradas, iCtasMob00, iCtasMob01, iCtasMob02, iCtasMob03, iCtasMob04, mCtasMob05,
				mCtasMob06, mCtasMob07, mCtasMobur, mTotalCtas;				
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultainforeportebc_resumencreditos.out';
		--TRACE ON;
		
		--IF pUsuario = '' OR pIdFuncion = '' OR pInstitucion IS NULL OR pNumcte IS NULL THEN
		IF pUsuario = '' OR pIdFuncion = '' OR pNumcte = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cInstitucion, cNumCliente, iCtasAbiertas, iLimAbiertas, iMaxAbiertas, iSaldoAct, iMontoAbiertas,
				iPagoRealizar, iCtasCerradas, iCtasMob00, iCtasMob01, iCtasMob02, iCtasMob03, iCtasMob04, mCtasMob05,
				mCtasMob06, mCtasMob07, mCtasMobur, mTotalCtas;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cInstitucion, cNumCliente, iCtasAbiertas, iLimAbiertas, iMaxAbiertas, iSaldoAct, iMontoAbiertas,
				iPagoRealizar, iCtasCerradas, iCtasMob00, iCtasMob01, iCtasMob02, iCtasMob03, iCtasMob04, mCtasMob05,
				mCtasMob06, mCtasMob07, mCtasMobur, mTotalCtas;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		FOREACH SELECT
					a.institucion, 
					a.num_cliente, 
					a.rs11, 
					a.rs22, 
					a.rs21, 
					a.rs23, 
					a.rs24, 
					a.rs25, 
					a.rs12, 
					a.rs07, 
					a.rs06, 
					a.rs05, 
					a.rs04, 
					a.rs03, 
					a.rs02, 
					a.rs01, 
					a.rs00, 
					a.rs08, 
					a.rs09 
				INTO cInstitucion, cNumCliente, iCtasAbiertas, iLimAbiertas, iMaxAbiertas, iSaldoAct, iMontoAbiertas,
						iPagoRealizar, iCtasCerradas, iCtasMob00, iCtasMob01, iCtasMob02, iCtasMob03, iCtasMob04, mCtasMob05,
						mCtasMob06, mCtasMob07, mCtasMobur, mTotalCtas
				FROM bdiburo:br_rs a WHERE a.institucion = 'BC' AND a.num_cliente = pNumcte
				GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
				
				
			RETURN cCodRet, cInstitucion, cNumCliente, iCtasAbiertas, iLimAbiertas, iMaxAbiertas, iSaldoAct, iMontoAbiertas,
				iPagoRealizar, iCtasCerradas, iCtasMob00, iCtasMob01, iCtasMob02, iCtasMob03, iCtasMob04, mCtasMob05,
				mCtasMob06, mCtasMob07, mCtasMobur, mTotalCtas WITH RESUME;	
				
		END FOREACH;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cInstitucion, cNumCliente, iCtasAbiertas, iLimAbiertas, iMaxAbiertas, iSaldoAct, iMontoAbiertas,
				iPagoRealizar, iCtasCerradas, iCtasMob00, iCtasMob01, iCtasMob02, iCtasMob03, iCtasMob04, mCtasMob05,
				mCtasMob06, mCtasMob07, mCtasMobur, mTotalCtas;
		END IF;
	END;
	
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 11/03/2014',
'DESCRIPCION: Genera un reporte que muestra un resumen de creditos de cuentas abiertas y cerradas del cliente, Mesa de Control',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultareporteautorizasolicitudesmc(pUsuario CHAR(8), pIdFuncion CHAR(8), pNumSolicitud CHAR(20))
        RETURNING CHAR(5) AS codret, 
                        CHAR(20) AS no_solicitud, 
                        CHAR(20) AS num_cliente, 
                        CHAR(4) AS sucursal, 
                        CHAR(40) AS nombre_sucursal, 
                        CHAR(45) AS ejecutivo_autoriza, 
                        DATE AS fecha_insercion, 
                        CHAR(500) AS justificacion, 
                        CHAR(52) AS nombrecliente, 
                        CHAR(26) AS apepaterno, 
                        CHAR(26) AS apematerno, 
                        CHAR(13) AS rfc,
                        CHAR(45) as ejecutivo_elabora,
                        CHAR(5) AS cambio_estatus;
                        
        DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(3);
        DEFINE iCodRet INTEGER;
        DEFINE iSqlErr INTEGER;
        DEFINE cNoSolicitud CHAR(20);
        DEFINE cNumCliente CHAR(20);
        DEFINE cSucursal CHAR(4);
        DEFINE cNombreSucursal CHAR(40);
        DEFINE cEjecutivoAutoriza CHAR(45);
        DEFINE dFechaInsercion DATE;
        DEFINE cJustificacion CHAR(500);
        DEFINE cNombrecliente CHAR(52);
        DEFINE cApepaterno CHAR(26);
        DEFINE cApematerno CHAR(26);
        DEFINE cRfc CHAR(13);
        DEFINE cEjecutivoElabora CHAR(45);
        DEFINE cCambioEstatus CHAR(5);
        
        LET cCodRet = '00000';
        LET cCodRetSp = '';
        LET iCodRet = 0;
        LET iSqlErr = 0;
        LET cNoSolicitud = '';
        LET cNumCliente = '';
        LET cSucursal = '';
        LET cNombreSucursal = '';
        LET cEjecutivoAutoriza = '';
        LET dFechaInsercion = NULL;
        LET cJustificacion = '';
        LET cNombrecliente = '';
        LET cApepaterno = '';
        LET cApematerno = '';
        LET cRfc = '';
        LET cEjecutivoElabora = '';
        LET cCambioEstatus = '';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cNoSolicitud, cNumCliente, cSucursal, cNombreSucursal, cEjecutivoAutoriza, 
                               dFechaInsercion, cJustificacion, cNombrecliente, cApepaterno, cApematerno, cRfc, cEjecutivoElabora, cCambioEstatus;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_consultareporteautorizasolicitudesmc.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pNumSolicitud = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cNoSolicitud, cNumCliente, cSucursal, cNombreSucursal, cEjecutivoAutoriza, 
                               dFechaInsercion, cJustificacion, cNombrecliente, cApepaterno, cApematerno, cRfc, cEjecutivoElabora, cCambioEstatus;
                END IF;
                
                -- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cNoSolicitud, cNumCliente, cSucursal, cNombreSucursal, cEjecutivoAutoriza, 
                               dFechaInsercion, cJustificacion, cNombrecliente, cApepaterno, cApematerno, cRfc, cEjecutivoElabora, cCambioEstatus;
                END IF;
                
                SET ISOLATION TO DIRTY READ;
                
                EXECUTE PROCEDURE bdicred:"informix".sp_generareporteautorizasolicitudes(pNumSolicitud)
                INTO cCodRetSp, cNoSolicitud, cNumCliente, cSucursal, cNombreSucursal, cEjecutivoAutoriza, 
                     dFechaInsercion, cJustificacion, cNombrecliente, cApepaterno, cApematerno, cRfc, cEjecutivoElabora, cCambioEstatus;
                         
                LET iCodRet = cCodRetSp::INTEGER;
                IF iCodRet < 0 THEN
                        RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP sp_generareporteautorizasolicitudes';
                ELIF iCodRet = 111 THEN
                        LET cCodRet = '00003';
                ELSE
                        IF cNumCliente IS NULL OR cNumCliente = '' THEN
                                LET cCodRet = '00017';
                        END IF;
                END IF;
                
                RETURN cCodRet, cNoSolicitud, cNumCliente, cSucursal, cNombreSucursal, cEjecutivoAutoriza, 
                           dFechaInsercion, UPPER(cJustificacion), cNombrecliente, cApepaterno, cApematerno, cRfc, cEjecutivoElabora, cCambioEstatus;
                
        END;

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 06/03/2014',
'DESCRIPCION: Obtiene los datos para el reporte de autorizaciÃÂ³n de solicitud',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultareporteoperacionesmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pProducto CHAR(4), pFechaInicial DATE, pFechaFinal DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
			CHAR(10) AS fecha, 
			CHAR(50) AS nombre_producto,
			INTEGER AS solicitudes_mc, 
			INTEGER AS no_analizadas_a_tiempo,
			INTEGER AS analizadas_a_tiempo,
			INTEGER AS revaluadas, 
			INTEGER AS no_revaluadas, 
			INTEGER AS sigue_proceso, 
			DECIMAL(18,2) AS porcentaje_sp,
			INTEGER AS rechazadas,
			DECIMAL(18,2) AS porcentaje_rt,
			INTEGER AS canceladas,
			DECIMAL(18,2) AS porcentaje_cn,
			INTEGER AS mixta,
			INTEGER AS unica;
		
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cMensaje CHAR(80);
	DEFINE dFecha CHAR(10);
	DEFINE cFecha CHAR(10);
	DEFINE cNombreProducto CHAR(50);
	DEFINE iSolicitudesMc INTEGER;
	DEFINE iNoAnalizadasATiempo INTEGER;
	DEFINE iAnalizadasATiempo INTEGER;
	DEFINE iRevaluadas INTEGER;
	DEFINE iNoRevaluadas INTEGER;
	DEFINE iSigueProceso INTEGER;
	DEFINE dPorcentajeSp DECIMAL(18,2);
	DEFINE iRechazadas INTEGER;
	DEFINE dPorcentajeRt DECIMAL(18,2);
	DEFINE iCanceladas INTEGER;
	DEFINE dPorcentajeCn DECIMAL(18,2);
	DEFINE iMixta INTEGER;
	DEFINE iUnica INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
			
	LET cCodRet = '00000';
    LET cCodRetSp = '';
	LET iCodRetSp = 0;
    LET iSqlErr = 0;
    LET cMensaje = '';
    LET dFecha = NULL;
	LET cFecha = '';
    LET cNombreProducto = '';
    LET iSolicitudesMc = 0;
    LET iNoAnalizadasATiempo = 0;
    LET iAnalizadasATiempo = 0;
    LET iRevaluadas = 0;
    LET iNoRevaluadas = 0;
    LET iSigueProceso = 0;
    LET dPorcentajeSp = NULL;
    LET iRechazadas = 0;
    LET dPorcentajeRt = NULL;
    LET iCanceladas = 0;
    LET dPorcentajeCn = NULL;
    LET iMixta = 0;
    LET iUnica = 0;
    LET iRegistros = 0;
    LET iRecuperacion = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha, cNombreProducto, iSolicitudesMc, iNoAnalizadasATiempo, 
					iAnalizadasATiempo, iRevaluadas, iNoRevaluadas, iSigueProceso, dPorcentajeSp, 
					iRechazadas, dPorcentajeRt, iCanceladas, dPorcentajeCn, iMixta, iUnica;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultareporteoperacionesmc.out';
		--TRACE ON;
		
		--IF pUsuario = '' OR pIdFuncion = '' OR pProducto = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN	
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, cNombreProducto, iSolicitudesMc, iNoAnalizadasATiempo, 
					iAnalizadasATiempo, iRevaluadas, iNoRevaluadas, iSigueProceso, dPorcentajeSp, 
					iRechazadas, dPorcentajeRt, iCanceladas, dPorcentajeCn, iMixta, iUnica;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dFecha, cNombreProducto, iSolicitudesMc, iNoAnalizadasATiempo, 
					iAnalizadasATiempo, iRevaluadas, iNoRevaluadas, iSigueProceso, dPorcentajeSp, 
					iRechazadas, dPorcentajeRt, iCanceladas, dPorcentajeCn, iMixta, iUnica;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFecha, cNombreProducto, iSolicitudesMc, iNoAnalizadasATiempo, 
					iAnalizadasATiempo, iRevaluadas, iNoRevaluadas, iSigueProceso, dPorcentajeSp, 
					iRechazadas, dPorcentajeRt, iCanceladas, dPorcentajeCn, iMixta, iUnica;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_consultaoperacionesmc(pProducto, pFechainicial, pFechafinal)
			INTO cCodRetSp, cMensaje, dFecha, cNombreProducto, iSolicitudesMc, iNoAnalizadasATiempo, 
					iAnalizadasATiempo, iRevaluadas, iNoRevaluadas, iSigueProceso, dPorcentajeSp, 
					iRechazadas, dPorcentajeRt, iCanceladas, dPorcentajeCn, iMixta, iUnica
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultaoperacionesmc';
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dFecha, cNombreProducto, iSolicitudesMc, iNoAnalizadasATiempo, 
						iAnalizadasATiempo, iRevaluadas, iNoRevaluadas, iSigueProceso, dPorcentajeSp, 
						iRechazadas, dPorcentajeRt, iCanceladas, dPorcentajeCn, iMixta, iUnica;
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '00030';
				RETURN cCodRet, dFecha, cNombreProducto, iSolicitudesMc, iNoAnalizadasATiempo, 
						iAnalizadasATiempo, iRevaluadas, iNoRevaluadas, iSigueProceso, dPorcentajeSp, 
						iRechazadas, dPorcentajeRt, iCanceladas, dPorcentajeCn, iMixta, iUnica;
			ELSE
				IF iRegistros >= pRegistros THEN
					IF iRecuperacion < pRecuperacion THEN
						RETURN cCodRet, dFecha, cNombreProducto, iSolicitudesMc, iNoAnalizadasATiempo, 
								iAnalizadasATiempo, iRevaluadas, iNoRevaluadas, iSigueProceso, dPorcentajeSp, 
								iRechazadas, dPorcentajeRt, iCanceladas, dPorcentajeCn, iMixta, iUnica WITH RESUME;
						LET iRecuperacion = iRecuperacion + 1;
					ELSE
						EXIT FOREACH;
					END IF;
				END IF;
				LET iRegistros = iRegistros + 1;
			END IF;
			
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFecha, cNombreProducto, iSolicitudesMc, iNoAnalizadasATiempo, 
					iAnalizadasATiempo, iRevaluadas, iNoRevaluadas, iSigueProceso, dPorcentajeSp, 
					iRechazadas, dPorcentajeRt, iCanceladas, dPorcentajeCn, iMixta, iUnica;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFecha, cNombreProducto, iSolicitudesMc, iNoAnalizadasATiempo, 
					iAnalizadasATiempo, iRevaluadas, iNoRevaluadas, iSigueProceso, dPorcentajeSp, 
					iRechazadas, dPorcentajeRt, iCanceladas, dPorcentajeCn, iMixta, iUnica;
		END IF;
		
	END;
	
END PROCEDURE 
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 06/03/2014',
'DESCRIPCION: Contabiliza y genera una relaciÃ³n de distintos tipos de solicitudes dentro de un rango de fecha dado',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultarhistestatussolmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumeroSolicitud CHAR(20))
	RETURNING CHAR(5) AS codret,
			CHAR(2) AS estatus_anterior,
			CHAR(2) AS estatus_nuevo,
			CHAR(200) AS justificacion,
			CHAR(104) AS nombre_usuario;

	-- dbschema -q -f sp_consultarhistestatussol -d bdisolic
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	-- VARIABLES DEL SP
	DEFINE cCodRetSp CHAR(6);
	DEFINE cMensajeError CHAR(100);
	DEFINE cEstatusAnterior CHAR(2);
	DEFINE cEstatusActual CHAR(2);
	DEFINE cJustificacion CHAR(200);
	DEFINE cNombreUsuario CHAR(104);
	DEFINE cEmpresa CHAR(3);
	

	-- INICIALIZACIÃN DE VARIABLES
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	
	-- VARIABLES DEL SP
	LET cCodRetSp = '';
	LET cMensajeError = '';
	LET cEstatusAnterior = '';
	LET cEstatusActual = '';
	LET cJustificacion = '';
	LET cNombreUsuario = '';
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEstatusAnterior, cEstatusActual, cJustificacion, cNombreUsuario;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consultarhistestatussolmc.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumeroSolicitud = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEstatusAnterior, cEstatusActual, cJustificacion, cNombreUsuario;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEstatusAnterior, cEstatusActual, cJustificacion, cNombreUsuario;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdisolic:'informix'.sp_consultarhistestatussol(cEmpresa, pNumeroSolicitud)
			INTO cCodRetSp, cMensajeError, cEstatusAnterior, cEstatusActual, cJustificacion, cNombreUsuario
			
			IF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cEstatusAnterior, cEstatusActual, cJustificacion, cNombreUsuario;
			ELIF cCodRetSp::INTEGER = 3 THEN -- La solicitud indicada no presenta historial de cambio de estatus
				LET cCodRet = '00231';
				RETURN cCodRet, cEstatusAnterior, cEstatusActual, cJustificacion, cNombreUsuario;
			ELIF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisolic:sp_consultarhistestatussol';
			ELSE
				RETURN cCodRet, cEstatusAnterior, cEstatusActual, cJustificacion, cNombreUsuario WITH RESUME;
			END IF
		END FOREACH;
	
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 15/01/2013',
'DESCRIPCION: Consulta el historial de los cambios de estatus realizados a una solicitud',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultarinforeporteanalistamc(pUsuario CHAR(8), pIdFuncion CHAR(10), pProducto CHAR(4), pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5)     AS codret,
			CHAR(8)       AS ejecutivo,
			CHAR(80)      AS nombre,
			INTEGER       AS no_analizadas,
			DECIMAL(14,2) AS porcentaje_analizadas,
			INTEGER       AS num_reevaluadas,
			DECIMAL(14,2) AS porcentaje_revaluadas,
			INTEGER       AS num_revaluadas,
			DECIMAL(14,2) AS porcentaje_num_revaluadas,
			INTEGER       AS num_siguen_proceso,
			DECIMAL(14,2) AS porcentaje_sigue_proc,
			INTEGER       AS num_rechazadas,
			DECIMAL(14,2) AS porcentaje_rechazadas,
			INTEGER       AS canceladas,
			DECIMAL(14,2) AS porcentaje_canceladas,      
			INTEGER       AS num_mixta,
			DECIMAL(14,2) AS porcentaje_mixta,
			INTEGER       AS num_unica,
			DECIMAL(14,2) AS porcentaje_unica,   
			CHAR(80)      AS nombre_producto;
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEjecutivo CHAR(8);
	DEFINE cNombre CHAR(80);
	DEFINE iNoAnalizadas INTEGER;
	DEFINE dPorcentajeAnalizadas DECIMAL(14,2);
	DEFINE iNumReevaluadas INTEGER;      
	DEFINE dPorcentajeRevaluadas DECIMAL(14,2);
	DEFINE iNumRevaluadas INTEGER;
	DEFINE dPorcentajeNumRevaluadas DECIMAL(14,2);
	DEFINE iNumSiguenProceso INTEGER;      
	DEFINE dPorcentajeSigueProc DECIMAL(14,2);
	DEFINE iNumRechazadas INTEGER;
	DEFINE dPorcentajeRechazadas DECIMAL(14,2);
	DEFINE iCanceladas INTEGER;
	DEFINE dPorcentajeCanceladas DECIMAL(14,2);
	DEFINE iNumMixta INTEGER;
	DEFINE dPorcentajeMixta DECIMAL(14,2);
	DEFINE iNumUnica INTEGER;
	DEFINE dPorcentajeUnica DECIMAL(14,2);
	DEFINE cNombreProducto CHAR(80);
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET iSqlErr = 0;
	LET cEjecutivo = '';
	LET cNombre = '';
	LET iNoAnalizadas = 0;
	LET dPorcentajeAnalizadas = NULL;
	LET iNumReevaluadas = 0;      
	LET dPorcentajeRevaluadas = NULL;
	LET iNumRevaluadas = 0;
	LET dPorcentajeNumRevaluadas = NULL;
	LET iNumSiguenProceso = 0;      
	LET dPorcentajeSigueProc = NULL;
	LET iNumRechazadas = 0;
	LET dPorcentajeRechazadas = NULL;
	LET iCanceladas = 0;
	LET dPorcentajeCanceladas = NULL;
	LET iNumMixta = 0;
	LET dPorcentajeMixta = NULL;
	LET iNumUnica = 0;
	LET dPorcentajeUnica = NULL;
	LET cNombreProducto = '';
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEjecutivo, cNombre, iNoAnalizadas, 
				dPorcentajeAnalizadas, iNumReevaluadas, dPorcentajeRevaluadas, iNumRevaluadas, 
				dPorcentajeNumRevaluadas, iNumSiguenProceso, dPorcentajeSigueProc, iNumRechazadas, 
				dPorcentajeRechazadas, iCanceladas, dPorcentajeCanceladas, iNumMixta, 
				dPorcentajeMixta, iNumUnica, dPorcentajeUnica, cNombreProducto;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultarinforeporteanalistamc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEjecutivo, cNombre, iNoAnalizadas, 
				dPorcentajeAnalizadas, iNumReevaluadas, dPorcentajeRevaluadas, iNumRevaluadas, 
				dPorcentajeNumRevaluadas, iNumSiguenProceso, dPorcentajeSigueProc, iNumRechazadas, 
				dPorcentajeRechazadas, iCanceladas, dPorcentajeCanceladas, iNumMixta, 
				dPorcentajeMixta, iNumUnica, dPorcentajeUnica, cNombreProducto;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cEjecutivo, cNombre, iNoAnalizadas, 
				dPorcentajeAnalizadas, iNumReevaluadas, dPorcentajeRevaluadas, iNumRevaluadas, 
				dPorcentajeNumRevaluadas, iNumSiguenProceso, dPorcentajeSigueProc, iNumRechazadas, 
				dPorcentajeRechazadas, iCanceladas, dPorcentajeCanceladas, iNumMixta, 
				dPorcentajeMixta, iNumUnica, dPorcentajeUnica, cNombreProducto;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEjecutivo, cNombre, iNoAnalizadas, 
				dPorcentajeAnalizadas, iNumReevaluadas, dPorcentajeRevaluadas, iNumRevaluadas, 
				dPorcentajeNumRevaluadas, iNumSiguenProceso, dPorcentajeSigueProc, iNumRechazadas, 
				dPorcentajeRechazadas, iCanceladas, dPorcentajeCanceladas, iNumMixta, 
				dPorcentajeMixta, iNumUnica, dPorcentajeUnica, cNombreProducto;
		END IF;
		
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_consultaporanalistamc(pFechaInicio, pFechaFin, pProducto)
				INTO cCodRetSp, cEjecutivo, cNombre, iNoAnalizadas, 
						dPorcentajeAnalizadas, iNumReevaluadas, dPorcentajeRevaluadas, iNumRevaluadas, 
						dPorcentajeNumRevaluadas, iNumSiguenProceso, dPorcentajeSigueProc, iNumRechazadas, 
						dPorcentajeRechazadas, iCanceladas, dPorcentajeCanceladas, iNumMixta, 
						dPorcentajeMixta, iNumUnica, dPorcentajeUnica, cNombreProducto
			
			LET iCodRet = cCodRetSp::INTEGER;
			IF iCodRet < 0 THEN
				RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultaporanalistamc';
			ELIF iCodRet = 0 THEN
				IF iRegistros >= pRegistros THEN
					IF iRecuperacion < pRecuperacion THEN
						RETURN cCodRet, cEjecutivo, cNombre, iNoAnalizadas, 
							dPorcentajeAnalizadas, iNumReevaluadas, dPorcentajeRevaluadas, iNumRevaluadas, 
							dPorcentajeNumRevaluadas, iNumSiguenProceso, dPorcentajeSigueProc, iNumRechazadas, 
							dPorcentajeRechazadas, iCanceladas, dPorcentajeCanceladas, iNumMixta, 
							dPorcentajeMixta, iNumUnica, dPorcentajeUnica, cNombreProducto WITH RESUME;
						LET iRecuperacion = iRecuperacion + 1;
					ELSE
						EXIT FOREACH;
					END IF;
				END IF;
				LET iRegistros = iRegistros + 1;
			END IF;
				
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cEjecutivo, cNombre, iNoAnalizadas, 
				dPorcentajeAnalizadas, iNumReevaluadas, dPorcentajeRevaluadas, iNumRevaluadas, 
				dPorcentajeNumRevaluadas, iNumSiguenProceso, dPorcentajeSigueProc, iNumRechazadas, 
				dPorcentajeRechazadas, iCanceladas, dPorcentajeCanceladas, iNumMixta, 
				dPorcentajeMixta, iNumUnica, dPorcentajeUnica, cNombreProducto;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cEjecutivo, cNombre, iNoAnalizadas, 
				dPorcentajeAnalizadas, iNumReevaluadas, dPorcentajeRevaluadas, iNumRevaluadas, 
				dPorcentajeNumRevaluadas, iNumSiguenProceso, dPorcentajeSigueProc, iNumRechazadas, 
				dPorcentajeRechazadas, iCanceladas, dPorcentajeCanceladas, iNumMixta, 
				dPorcentajeMixta, iNumUnica, dPorcentajeUnica, cNombreProducto;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 05/03/2014',
'DESCRIPCION: Hace un reporte de las solicitudes que fueron analizadas por analista para Mesa de Control, SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultartotalinforeporteanalistamc(pUsuario CHAR(8), pIdFuncion CHAR(10), pProducto CHAR(4), pFechaInicio DATE, pFechaFin DATE)
	RETURNING CHAR(5)     AS codret,
			INTEGER AS total_registros;
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEjecutivo CHAR(8);
	DEFINE cNombre CHAR(80);
	DEFINE iNoAnalizadas INTEGER;
	DEFINE dPorcentajeAnalizadas DECIMAL(14,2);
	DEFINE iNumReevaluadas INTEGER;      
	DEFINE dPorcentajeRevaluadas DECIMAL(14,2);
	DEFINE iNumRevaluadas INTEGER;
	DEFINE dPorcentajeNumRevaluadas DECIMAL(14,2);
	DEFINE iNumSiguenProceso INTEGER;      
	DEFINE dPorcentajeSigueProc DECIMAL(14,2);
	DEFINE iNumRechazadas INTEGER;
	DEFINE dPorcentajeRechazadas DECIMAL(14,2);
	DEFINE iCanceladas INTEGER;
	DEFINE dPorcentajeCanceladas DECIMAL(14,2);
	DEFINE iNumMixta INTEGER;
	DEFINE dPorcentajeMixta DECIMAL(14,2);
	DEFINE iNumUnica INTEGER;
	DEFINE dPorcentajeUnica DECIMAL(14,2);
	DEFINE cNombreProducto CHAR(80);
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET iSqlErr = 0;
	LET cEjecutivo = '';
	LET cNombre = '';
	LET iNoAnalizadas = 0;
	LET dPorcentajeAnalizadas = NULL;
	LET iNumReevaluadas = 0;      
	LET dPorcentajeRevaluadas = NULL;
	LET iNumRevaluadas = 0;
	LET dPorcentajeNumRevaluadas = NULL;
	LET iNumSiguenProceso = 0;      
	LET dPorcentajeSigueProc = NULL;
	LET iNumRechazadas = 0;
	LET dPorcentajeRechazadas = NULL;
	LET iCanceladas = 0;
	LET dPorcentajeCanceladas = NULL;
	LET iNumMixta = 0;
	LET dPorcentajeMixta = NULL;
	LET iNumUnica = 0;
	LET dPorcentajeUnica = NULL;
	LET cNombreProducto = '';
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultartotalinforeporteanalistamc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRegistros;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iRegistros;
		END IF;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_consultaporanalistamc(pFechaInicio, pFechaFin, pProducto)
				INTO cCodRetSp, cEjecutivo, cNombre, iNoAnalizadas, 
						dPorcentajeAnalizadas, iNumReevaluadas, dPorcentajeRevaluadas, iNumRevaluadas, 
						dPorcentajeNumRevaluadas, iNumSiguenProceso, dPorcentajeSigueProc, iNumRechazadas, 
						dPorcentajeRechazadas, iCanceladas, dPorcentajeCanceladas, iNumMixta, 
						dPorcentajeMixta, iNumUnica, dPorcentajeUnica, cNombreProducto
			
			LET iCodRet = cCodRetSp::INTEGER;
			IF iCodRet < 0 THEN
				RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultaporanalistamc';
			ELIF iCodRet = 0 THEN
				LET iRegistros = iRegistros + 1;
			END IF;
				
		END FOREACH;
		
		IF iRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iRegistros;
		END IF;
		
		RETURN cCodRet, iRegistros;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 05/03/2014',
'DESCRIPCION: Hace un conteo de las solicitudes que fueron analizadas por analista para Mesa de Control, SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultas_cac_central_ctemc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombre1 CHAR(30), pNombre2 CHAR(30), 
			pApellidoPaterno CHAR(30), pApellidoMaterno CHAR(30), pNumCliente CHAR(20), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(80) AS mensaje_error,
			CHAR(20) AS num_solicitud,
			CHAR(20) AS num_cliente,
			CHAR(104) AS nombre_cliente,
			CHAR(13) AS rfc,
			CHAR(4) AS sucursal,
			DATE AS fecha_solicitud,
			DATE AS fecha_cambio,
			DECIMAL(18,2) AS importe_linea,
			DECIMAL(5,2) AS eficiencia,
			INTEGER AS historial,
			DECIMAL(5,2) AS puntos_1a_seccion,
			DECIMAL(5,2) AS puntos_2a_seccion,
			CHAR(2) AS status,
			CHAR(511) AS observaciones,
			DECIMAL(8,2) AS sum_secciones,
			CHAR(3) AS causa_solicitud;
		
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cEmpresa CHAR(3);
	
	-- VARIABLES DEL SP PRODUCTIVO
	DEFINE cMensajeError CHAR(80);
	DEFINE cNumSolicitud CHAR(20);
	DEFINE cNumCliente CHAR(20);
	DEFINE cNombreCliente CHAR(104);
	DEFINE cRfc CHAR(13);
	DEFINE cSucursal CHAR(4);
	DEFINE dFechaSolicitud DATE;
	DEFINE dFechaCambio DATE;
	DEFINE dImporteLinea DECIMAL(18,2);
	DEFINE dEficiencia DECIMAL(5,2);
	DEFINE iHistorial INTEGER;
	DEFINE dPuntos1Seccion DECIMAL(5,2);
	DEFINE dPuntos2Seccion DECIMAL(5,2);
	DEFINE cStatus CHAR(2);
	DEFINE cObservaciones CHAR(511);
	DEFINE dSumaSecciones DECIMAL(8,2);
	DEFINE cCausaSolicitud CHAR(3);
	
	LET cCodRet = '';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cEmpresa = '001';
	
	-- VARIABLES DEL SP PRODUCTIVO
	LET cMensajeError = '';
	LET cNumSolicitud = '';
	LET cNumCliente = '';
	LET cNombreCliente = '';
	LET cRfc = '';
	LET cSucursal = '';
	LET dFechaSolicitud = NULL;
	LET dFechaCambio = NULL;
	LET dImporteLinea = NULL;
	LET dEficiencia = NULL;
	LET iHistorial = 0;
	LET dPuntos1Seccion = NULL;
	LET dPuntos2Seccion = NULL;
	LET cStatus = '';
	LET cObservaciones = '';
	LET dSumaSecciones = NULL;
	LET cCausaSolicitud = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cMensajeError, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, 
				dFechaCambio, dImporteLinea, dEficiencia, iHistorial, dPuntos1Seccion, dPuntos2Seccion, 
				cStatus, cObservaciones, dSumaSecciones, cCausaSolicitud;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultas_cac_central_ctemc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMensajeError, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, 
				dFechaCambio, dImporteLinea, dEficiencia, iHistorial, dPuntos1Seccion, dPuntos2Seccion, 
				cStatus, cObservaciones, dSumaSecciones, cCausaSolicitud;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cMensajeError, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, 
				dFechaCambio, dImporteLinea, dEficiencia, iHistorial, dPuntos1Seccion, dPuntos2Seccion, 
				cStatus, cObservaciones, dSumaSecciones, cCausaSolicitud;
		END IF;
		
		-- ValidacciÃ³n de acceso a la funcionalidad
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cMensajeError, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, 
				dFechaCambio, dImporteLinea, dEficiencia, iHistorial, dPuntos1Seccion, dPuntos2Seccion, 
				cStatus, cObservaciones, dSumaSecciones, cCausaSolicitud;
		END IF;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_consultas_cac_central_cte(cEmpresa, pNombre1, pNombre2, pApellidoPaterno, pApellidoMaterno, pNumCliente)
			INTO cCodRetSp, cMensajeError, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, dFechaCambio, 
					dImporteLinea, dEficiencia, iHistorial, dPuntos1Seccion, dPuntos2Seccion, cStatus, cObservaciones, dSumaSecciones, cCausaSolicitud
			
			IF cCodRetSp::INTEGER = 0 THEN
				
				IF iRegistros >= pRegistros THEN
					IF iRecuperacion < pRecuperacion THEN						
						RETURN cCodRet, cMensajeError, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, 
							dFechaCambio, dImporteLinea, dEficiencia, iHistorial, dPuntos1Seccion, dPuntos2Seccion, 
							cStatus, cObservaciones, dSumaSecciones, cCausaSolicitud WITH RESUME;
						LET iRecuperacion = iRecuperacion + 1;
					END IF;
				END IF;
				LET iRegistros = iRegistros + 1;
				
			ELIF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER;
			END IF;
		
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cMensajeError, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, 
							dFechaCambio, dImporteLinea, dEficiencia, iHistorial, dPuntos1Seccion, dPuntos2Seccion, 
							cStatus, cObservaciones, dSumaSecciones, cCausaSolicitud;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cMensajeError, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, 
							dFechaCambio, dImporteLinea, dEficiencia, iHistorial, dPuntos1Seccion, dPuntos2Seccion, 
							cStatus, cObservaciones, dSumaSecciones, cCausaSolicitud;
		END IF;
		
	END;
		
END PROCEDURE;