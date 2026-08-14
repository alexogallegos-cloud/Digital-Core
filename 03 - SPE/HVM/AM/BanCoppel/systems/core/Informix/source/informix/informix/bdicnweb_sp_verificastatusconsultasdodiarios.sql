CREATE PROCEDURE "informix".sp_verificastatusconsultasdodiarios(pUsuario CHAR(8), pIdFuncion CHAR(10))
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
			LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusconsultasdodiarios.out';
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
		FROM bdicnweb:"informix".sw_verificaconsultasaldosdiarioscap WHERE usuario = TRIM(pUsuario);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
			RETURN cCodRet,'I',cErrorProceso,cError; 
		ELSE 			
			RETURN cCodRet,cStatus,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA 27/03/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA SALDOS DIARIOS',
'DESCRIPCION: SPL que verifica el status de la ejecucion del spl encargado de consultar el Detalle de los Saldos Diarios de una Cuenta.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificaconsultasaldoshistcap(pUsuario CHAR(8), pIdFuncion CHAR(10))
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
			LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_verificaconsultasaldoshistcap.out';
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
		FROM bdicnweb:"informix".sw_verificaconsultasaldoshistcap WHERE usuario = TRIM(pUsuario);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
			RETURN cCodRet,'I',cErrorProceso,cError; 
		ELSE 			
			RETURN cCodRet,cStatus,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA 27/03/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA SALDOS HISTORICOS',
'DESCRIPCION: SPL que verifica el status de la ejecucion del spl encargado de consultar el Detalle de los Saldos Historicos de una Cuenta.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_constransferbancos(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codRet,		
		CHAR(3) AS id_banco,
		CHAR(35) AS nom_banco;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMnsjeRespuesta CHAR(150);
	DEFINE cIdBanco CHAR(3);
	DEFINE cNomBanco CHAR(100);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;	
	LET cMnsjeRespuesta = '';
	LET cIdBanco = '';
	LET cNomBanco = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cIdBanco,cNomBanco;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_constransferbancos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdBanco,cNomBanco;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdBanco,cNomBanco;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bditransfer:"informix".sp_transfer_bancos()
			INTO cCodRetSp, cMnsjeRespuesta, cIdBanco, cNomBanco
		
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditransfer:sp_transfer_bancos';
			END IF;
		
			LET iRecuperacion = iRecuperacion + 1;				
			RETURN cCodRet, TRIM(cIdBanco),TRIM(UPPER(cNomBanco)) WITH RESUME;	
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdBanco,cNomBanco;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 27/02/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE TRANSACCIONES INTERBANCARIAS TRANSFER',
'DESCRIPCION: Spl encargado de consultar el catalogo de Bancos con relaciÃ³n a la plataforma de Transfer.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_tf_transfermsettlement_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoEjecucion CHAR(1), pFechaInicio DATE, pFechaFin DATE, 
pBancOrigen CHAR(3), pBancDestino CHAR(3), pRutaDescarga CHAR(150))
		RETURNING CHAR(5) AS codret,
			INTEGER AS total_registros;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);	
	DEFINE cEmpresa CHAR(3);		
	DEFINE iTotalRegistros INTEGER;	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';	
	LET cEmpresa = '001';	
	LET iTotalRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalRegistros;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_tf_transfermsettlement_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotalRegistros;
		END IF;				
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalRegistros;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	
	
		EXECUTE PROCEDURE bditransfer:"informix".sp_transfer_msettlement2_totales(pFechaInicio, pFechaFin, pBancOrigen, pBancDestino)
		INTO cCodRetSp, iTotalRegistros;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditransfer:sp_transfer_msettlement2_totales';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00154'; --FECHA INICIAL NO PUEDE SER MAYOR A LA FINAL--
			RETURN cCodRet, iTotalRegistros;
		END IF;
		
		IF NVL(iTotalRegistros, 0) = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iTotalRegistros;

	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 27/02/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE TRANSACCIONES INTERBANCARIAS TRANSFER', 
'DESCRIPCION: SPL encargado de consultar el total de las transacciones Interbancarias Transfer.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_kiosko_consultamovprestamos(pUsuario CHAR(8), pIdFuncion CHAR(10), cNUMCUENTA CHAR(20), dPERIODOI DATE, dPERIODOF DATE , pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			DATE     	AS Fecha,
			DATETIME HOUR to FRACTION(3) AS Hora,
			CHAR(4)  	AS CveTransaccion,
			CHAR(120) 	AS Desc_Transaccion,
			CHAR(16) 	AS Folio,
			DATE     	AS Periodo_Inicial,
			MONEY(18,2) AS Monto,
			DATE     	AS Periodo_Final,
			CHAR(1)  	AS Naturaleza,
			CHAR(40) 	AS Referencia,
			CHAR(1)  	AS Reversos,
			CHAR(4)  	AS Sucursal,
			CHAR(20) 	AS Numero_Tarjeta,
			CHAR(1)  	AS Reversados,
			CHAR(8)  	AS Usuario,
			CHAR(23) 	AS Referencia23;
		
		
	DEFINE cCodRet 			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cEmpresa 		CHAR(3);
	DEFINE iNoRegistros 	INTEGER;
	DEFINE iRegistros 		INTEGER;
	DEFINE iRecuperacion 	INTEGER;
	DEFINE dFecha           DATE;
	DEFINE dHora            DATETIME HOUR to FRACTION(3);
	DEFINE cTransaccion     CHAR(4);
	DEFINE cD_Transaccion   CHAR(120);
	DEFINE mMonto           MONEY(18,2);
	DEFINE cNaturaleza      CHAR(1);
	DEFINE cReferencia      CHAR(40);
	DEFINE cRfcComer        CHAR(10);
	DEFINE cReversos        CHAR(1);
	DEFINE cReversados      CHAR(1);
	DEFINE cSucursal        CHAR(4);
	DEFINE cFolio           CHAR(16);
	DEFINE dPeriodoI_1      DATE;
	DEFINE dPeriodoF_1      DATE;
	DEFINE sNUMSERIAL       INT8;
	DEFINE sNumSecuencia    INT8;
	DEFINE cUsuario         CHAR(8);
	DEFINE cReferencia23    CHAR(23);
	DEFINE cNumtarjeta      CHAR(20);
	DEFINE iCont            INT;
	DEFINE cCodfun          CHAR(3);
	DEFINE cCodref          INTEGER;
	
	LET cCodRet 			= '00000';
	LET iSqlErr 			= 0;
	LET cEmpresa 			= '001';
	LET iNoRegistros 		= 0;
	LET iRegistros 			= 0;
	LET iRecuperacion 		= 0;
	LET dFecha              = "";
	LET dHora               = "";
	LET cTransaccion     	= "";
	LET cD_Transaccion     	= "";
	LET mMonto              = 0;
	LET cNaturaleza         = "";
	LET cReferencia         = "";
	LET cReversos          	= "";
	LET cReversados         = "";
	LET cSucursal           = "";
	LET cFolio              = "";
	LET dPeriodoI_1         = "";
	LET dPeriodoF_1         = "";
	LET sNUMSERIAL      	=  0;
	LET sNumSecuencia     	=  0;
	LET cUsuario        	= "";
	LET cReferencia23   	= "";
	LET cNumtarjeta     	= "";
	LET iCont       		= 0;
	LET cCodfun             = '';
	LET cCodref             = 0;
	LET cRfcComer 			= '';

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cNaturaleza,
			cReferencia,cReversos,cSucursal,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_kiosko_consultamovprestamos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR cNUMCUENTA = '' OR dPERIODOI IS NULL OR dPERIODOF IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cNaturaleza,
			cReferencia,cReversos,cSucursal,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cNaturaleza,
			cReferencia,cReversos,cSucursal,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cNaturaleza,
			cReferencia,cReversos,cSucursal,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		END IF;
		
		FOREACH
            SELECT SKIP pRegistros FIRST pRecuperacion {+INDEX(bdicred:"informix".sd_movdiacrd inx_movdia)}
			MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,MO.transacc_suc,TR.descripcion,MO.rfc_comer,
			MO.referencia,MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
			INTO cCodfun,cCodref,dFecha,dHora,cNumtarjeta,cFolio,cTransaccion,cD_Transaccion,cRfcComer,cReferencia,mMonto,cNaturaleza,cReversos,cSucursal,
			dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cUsuario,cReferencia23
			FROM bdicred:"informix".sd_movdiacrd MO
			LEFT JOIN bdicred:"informix".sd_transfun TR
			ON TR.empresa = cEmpresa AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
			WHERE MO.empresa= cEmpresa AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
		UNION
            SELECT {+INDEX(bdicred:"informix".sd_movhiscrd inx_movhis)}
			MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,MO.transacc_suc,TR.descripcion,MO.rfc_comer,
			MO.referencia,MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
			FROM bdicred:"informix".sd_movhiscrd MO
			LEFT JOIN bdicred:"informix".sd_transfun TR
			ON TR.empresa = cEmpresa AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
			WHERE MO.empresa= cEmpresa AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
			ORDER BY MO.secuencia DESC
			
			LET iCont=iCont+1;
			RETURN cCodRet,dFecha,dHora,NVL(cTransaccion,""),NVL(cD_Transaccion,""),cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,NVL(cNaturaleza,""),
			NVL(cReferencia,""),cReversos,cSucursal,NVL(cNumtarjeta,""),cReversados,NVL(cUsuario,""),NVL(cReferencia23,0) WITH RESUME;
		END FOREACH;
		
		IF iCont = 0 AND pRegistros=0 THEN
			LET cCodRet = '00039';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cNaturaleza,
			cReferencia,cReversos,cSucursal,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		ELIF iCont = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cNaturaleza,
			cReferencia,cReversos,cSucursal,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		END IF
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 26/02/2016',
'MODULO: KIOSKO',
'FUNCIONALIDAD: CONSULTA MOVIMIENTOS CREDITO (PRESTAMOS)',
'DESCRIPCION: REALIZA LA CONSULTA DE MOVIIENTOS DE LOS PRODUCTOS DE CREDITO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_kiosko_consultasdos_prestamo(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumCredito CHAR(20),pSucursal CHAR(4))
		RETURNING CHAR(5) AS Cod_Ret, 
			CHAR(20) 	  AS Num_credito,
			CHAR(4) 	  AS Nun_Producto,
			DECIMAL(18,2) AS Linea_Otorgada,
			DATE      	  AS Fecha_Ini_Prestamo,
			DECIMAL(18,2) AS Saldo_Ultimo_Corte,
			MONEY(18,2)   AS Interes_Moratorio,
			MONEY(18,2)   AS Iva_Interes_Moratorio,
			DECIMAL(18,2) AS Interes_Vigente,
			DECIMAL(18,2) AS Iva_Interes_Vigente,
			MONEY(18,2)   AS Comision,
			MONEY(18,2)   AS Iva_Comision,
			DECIMAL(18,2) AS Sus_Pagos,
			DECIMAL(18,2) AS Debe_Hoy,
			DECIMAL(18,2) AS Pago_Minimo,
			INTEGER       AS No_Pagos,
			DATE   		  AS Fecha_ProximoPago,
			DECIMAL(18,2) AS Total_Liquidacion,
			DECIMAL(18,2) AS Ahorro_Pago,
			INTEGER       AS No_Pago_actual,
			DECIMAL(18,2) AS Importe;
	
	DEFINE cCodRet				 CHAR(5);
	DEFINE iSqlErr 				 INTEGER;
	DEFINE cCodRetSp2 			 CHAR(5);
	DEFINE cCodRetSp 			 CHAR(6);
	DEFINE iCodRetSp 			 INTEGER;
	DEFINE cEmpresa 			 CHAR(3);
	DEFINE cMensajeRet   		 CHAR(80);
	DEFINE dSdoUltCorte			 DECIMAL(18,2);
	DEFINE dAhorroPago			 DECIMAL(18,2);
	DEFINE cNumCteCD 			 CHAR(20);  
	DEFINE cNomProductoCD		 CHAR(40);
	DEFINE cNomCteCD     		 CHAR(150);
	DEFINE dFecha_Origen		 DATE;
	DEFINE dFecha_Prox_Pago		 DATE;
	DEFINE mPago_Minimo			 MONEY(18,2);
	DEFINE iPlazo_Sg			 INTEGER;
	DEFINE iPagos_Realizados	 INTEGER;
	DEFINE mLinea_Otorgada		 MONEY(18,2);
	DEFINE mCap_Vdo_Exig		 MONEY(18,2);
	DEFINE mInt_Moratorios		 MONEY(18,2);
	DEFINE mIva_Int_Moratorios	 MONEY(18,2);
	DEFINE mCom_Pend			 MONEY(18,2);
	DEFINE mIva_Com				 MONEY(18,2);
	DEFINE mTotal_Liquidacion	 MONEY(18,2);
	DEFINE mInt_Devengado		 MONEY(18,2);
	DEFINE mIva_Int_Devengado	 MONEY(18,2);
	DEFINE cDesc_Status_Cred	 CHAR(60);
	DEFINE dMto_Prox_Pago        DECIMAL(18,2);
	DEFINE cMensajeRet_vc		 CHAR(80);
	DEFINE cNumProducto_vc  	 CHAR(4);
	DEFINE dtFechaOrigen     	 DATE;
	DEFINE dtFechaProxPago   	 DATE;
	DEFINE cDescStatusCred   	 CHAR(60);
	DEFINE iIdUnidadProd     	 INTEGER;
	DEFINE cCodCaract2       	 CHAR(3);
	DEFINE dPagoMinimo       	 DECIMAL(18,2);
	DEFINE dtFechaUltPago    	 DATE;
	DEFINE iPlazo            	 INTEGER;
	DEFINE iPagosRealizados  	 INTEGER;
	DEFINE dLineaOtorgada    	 DECIMAL(18,2);
	DEFINE dTasaInteres      	 DECIMAL(9,6);
	DEFINE dTasaMoratorios   	 DECIMAL(9,6);
	DEFINE dMontoSBC         	 DECIMAL(14,2);
	DEFINE dCapVig           	 DECIMAL(18,2);
	DEFINE dCapTrans         	 DECIMAL(18,2);
	DEFINE dCapVdoExig       	 DECIMAL(18,2);
	DEFINE dCapVdoNoExig     	 DECIMAL(18,2);
	DEFINE dSdoActCap        	 DECIMAL(18,2);
	DEFINE dIntVig           	 DECIMAL(18,2);
	DEFINE dIntVdo           	 DECIMAL(18,2);
	DEFINE dIntMoratorio     	 DECIMAL(18,2);
	DEFINE dIntMes           	 DECIMAL(18,2);
	DEFINE dSdoActInt        	 DECIMAL(18,2);
	DEFINE dIvaIntVig        	 DECIMAL(18,2);
	DEFINE dIvaIntVdo        	 DECIMAL(18,2);
	DEFINE dIvaIntMoratorio  	 DECIMAL(18,2);
	DEFINE dIvaIntMes        	 DECIMAL(18,2);
	DEFINE dSdoActIvaInt     	 DECIMAL(18,2);	
	DEFINE dComPend          	 DECIMAL(18,2);
	DEFINE dIvaCom           	 DECIMAL(18,2);
	DEFINE dSdoRetenido      	 DECIMAL(18,2);
	DEFINE dSdoTotalLiq      	 DECIMAL(18,2);
	DEFINE dtFechaCuota          DATE;
	DEFINE dIntDevengado         DECIMAL(18,2);
	DEFINE dIvaIntDevengado      DECIMAL(18,2);
	DEFINE dLineaDisponible      DECIMAL(18,2);
	DEFINE dPagosVdos            DECIMAL(18,2);
	DEFINE cDescBloqueoCta       CHAR(60);
	DEFINE cDescCausaBloqueoCta  CHAR(50);
	DEFINE cSitCte               CHAR(1);
	DEFINE cCausaCte             INTEGER;
	DEFINE cDescSitEspCte        CHAR(75);
	DEFINE cSitCred              CHAR(1);
	DEFINE cCausaCred            INTEGER;
	DEFINE cDescSitEspCred       CHAR(75);
	DEFINE dAbonos_His           DECIMAL(18,2);
	DEFINE cCodTipCred       	 CHAR(2);
	
	--INICIALIZACIONES
	LET cCodRet           	  = '00000';
	LET iSqlErr           	  = 0;
	LET cMensajeRet       	  = 'PROCESO EXITOSO';
	LET dSdoUltCorte	   	  = 0.0;
	LET dAhorroPago		   	  = 0.0;
	LET cNumCteCD 			  = '';
	LET cNomProductoCD		  = '';
	LET cCodRetSp 			  = '';
	LET cCodRetSp2 			  = '';
	LET iCodRetSp 			  = 0;
	LET cEmpresa 			  = '001';
	LET dFecha_Origen		  = MDY(1,1,1900);
	LET dFecha_Prox_Pago	  = MDY(1,1,1900);
	LET mPago_Minimo		  = 0.0;
	LET iPlazo_Sg			  = 0;
	LET iPagos_Realizados	  = 0;
	LET mLinea_Otorgada		  = 0.0;
	LET mCap_Vdo_Exig		  = 0.0;
	LET mInt_Moratorios		  = 0.0;
	LET mIva_Int_Moratorios	  = 0.0;
	LET mCom_Pend			  = 0.0;
	LET mIva_Com			  = 0.0;
	LET mTotal_Liquidacion	  = 0.0;
	LET mInt_Devengado		  = 0.0;
	LET mIva_Int_Devengado	  = 0.0;
	LET cDesc_Status_Cred	  = '';
	LET dMto_Prox_Pago     	  = 0;
	LET cNumProducto_vc	  	  = '';
	LET dAbonos_His           = 0;
	LET cCodTipCred           = '';
	LET dtFechaOrigen         = DATE(1);
	LET dtFechaProxPago       = DATE(1);
	LET cDescStatusCred       = '';
	LET iIdUnidadProd         = 0;
	LET cCodCaract2           = '';
	LET dPagoMinimo           = 0;
	LET dtFechaUltPago        = DATE(1);
	LET iPlazo                = 0;
	LET iPagosRealizados      = 0;
	LET dLineaOtorgada        = 0;
	LET dTasaInteres          = 0;
	LET dTasaMoratorios       = 0;
	LET dMontoSBC             = 0;
	LET dCapVig               = 0;
	LET dCapTrans             = 0;
	LET dCapVdoExig           = 0;
	LET dCapVdoNoExig         = 0;
	LET dSdoActCap            = 0;
	LET dIntVig               = 0;
	LET dIntVdo               = 0;
	LET dIntMoratorio         = 0;
	LET dIntMes               = 0;
	LET dSdoActInt            = 0;
	LET dIvaIntVig            = 0;
	LET dIvaIntVdo            = 0;
	LET dIvaIntMoratorio      = 0;
	LET dIvaIntMes            = 0;
	LET dSdoActIvaInt         = 0;
	LET dComPend              = 0;
	LET dIvaCom               = 0;
	LET dSdoRetenido          = 0;
	LET dSdoTotalLiq          = 0;
	LET dIntDevengado         = 0;
	LET dIvaIntDevengado      = 0;
	LET dLineaDisponible      = 0;
	LET dPagosVdos            = 0;
	LET cDescBloqueoCta       = '';
	LET cDescCausaBloqueoCta  = '';
	LET cSitCte               = '';
	LET cCausaCte             = 0;
	LET cDescSitEspCte        = '';
	LET cSitCred              = '';
	LET cCausaCred            = 0;
	LET cDescSitEspCred       = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,pNumCredito,cNumProducto_vc,dLineaOtorgada,dtFechaOrigen,dSdoUltCorte,mInt_Moratorios, mIva_Int_Moratorios,
			dIntVig,dIvaIntVig,mCom_Pend,mIva_Com,dAbonos_His,dSdoActCap,dPagoMinimo,iPlazo, dtFechaProxPago,dSdoTotalLiq,dAhorroPago,iPagosRealizados,mCap_Vdo_Exig;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_kiosko_consultasdos_prestamo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCredito = ''   OR pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,pNumCredito,cNumProducto_vc,dLineaOtorgada,dtFechaOrigen,dSdoUltCorte,mInt_Moratorios, mIva_Int_Moratorios,
			dIntVig,dIvaIntVig,mCom_Pend,mIva_Com,dAbonos_His,dSdoActCap,dPagoMinimo,iPlazo, dtFechaProxPago,dSdoTotalLiq,dAhorroPago,iPagosRealizados,mCap_Vdo_Exig;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,pNumCredito,cNumProducto_vc,dLineaOtorgada,dtFechaOrigen,dSdoUltCorte,mInt_Moratorios, mIva_Int_Moratorios,
			dIntVig,dIvaIntVig,mCom_Pend,mIva_Com,dAbonos_His,dSdoActCap,dPagoMinimo,iPlazo, dtFechaProxPago,dSdoTotalLiq,dAhorroPago,iPagosRealizados,mCap_Vdo_Exig;
		END IF;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_ofi_consultasdos(cEmpresa, pNumCredito, pSucursal)
		INTO cCodRetSp2, cMensajeRet,pNumCredito,cNumProducto_vc,cNomProductoCD,cNumCteCD,cNomCteCD,mLinea_Otorgada, dFecha_Origen,
		dSdoUltCorte,mInt_Moratorios,mIva_Int_Moratorios,mTotal_Liquidacion,mCap_Vdo_Exig,iPagos_Realizados,
		iPlazo_Sg,dFecha_Prox_Pago,mPago_Minimo,mTotal_Liquidacion, dAhorroPago,mTotal_Liquidacion, dAbonos_His,
		mInt_Devengado,mIva_Int_Devengado,mCom_Pend,mIva_Com,dMto_Prox_Pago,cDesc_Status_Cred;
		
		LET iCodRetSp = cCodRetSp2::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicred:sp_ofi_consultasdos";
		ELIF iCodRetSp = 361 THEN
			LET cCodRet = '00393';
			RETURN cCodRet,pNumCredito,cNumProducto_vc,dLineaOtorgada,dtFechaOrigen,dSdoUltCorte,mInt_Moratorios, mIva_Int_Moratorios,
			dIntVig,dIvaIntVig,mCom_Pend,mIva_Com,dAbonos_His,dSdoActCap,dPagoMinimo,iPlazo, dtFechaProxPago,dSdoTotalLiq,dAhorroPago,iPagosRealizados,mCap_Vdo_Exig;
		ELIF iCodRetSp = 362 THEN
			LET cCodRet = '00394';
			RETURN cCodRet,pNumCredito,cNumProducto_vc,dLineaOtorgada,dtFechaOrigen,dSdoUltCorte,mInt_Moratorios, mIva_Int_Moratorios,
			dIntVig,dIvaIntVig,mCom_Pend,mIva_Com,dAbonos_His,dSdoActCap,dPagoMinimo,iPlazo, dtFechaProxPago,dSdoTotalLiq,dAhorroPago,iPagosRealizados,mCap_Vdo_Exig;
		ELIF iCodRetSp = 363 THEN
			LET cCodRet = '00395';
			RETURN cCodRet,pNumCredito,cNumProducto_vc,dLineaOtorgada,dtFechaOrigen,dSdoUltCorte,mInt_Moratorios, mIva_Int_Moratorios,
			dIntVig,dIvaIntVig,mCom_Pend,mIva_Com,dAbonos_His,dSdoActCap,dPagoMinimo,iPlazo, dtFechaProxPago,dSdoTotalLiq,dAhorroPago,iPagosRealizados,mCap_Vdo_Exig;
		ELIF iCodRetSp = 364 THEN
			LET cCodRet = '00396';
			RETURN cCodRet,pNumCredito,cNumProducto_vc,dLineaOtorgada,dtFechaOrigen,dSdoUltCorte,mInt_Moratorios, mIva_Int_Moratorios,
			dIntVig,dIvaIntVig,mCom_Pend,mIva_Com,dAbonos_His,dSdoActCap,dPagoMinimo,iPlazo, dtFechaProxPago,dSdoTotalLiq,dAhorroPago,iPagosRealizados,mCap_Vdo_Exig;
		END IF;
		
		
		EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(cEmpresa, pNumCredito)
		INTO cCodRetSp, cMensajeRet, pNumCredito, cCodTipCred,dtFechaOrigen, dtFechaProxPago,
          dPagoMinimo, dtFechaUltPago, iPlazo, iPagosRealizados, dLineaOtorgada,
          dTasaInteres, dTasaMoratorios, dMontoSBC, dCapVig, dCapTrans, dCapVdoExig,
          dCapVdoNoExig, dSdoActCap, dIntVig, dIntVdo, dIntMoratorio, dIntMes,
          dSdoActInt, dIvaIntVig, dIvaIntVdo, dIvaIntMoratorio, dIvaIntMes, dSdoActIvaInt,
          dComPend, dIvaCom, dSdoRetenido, dSdoTotalLiq, dIntDevengado,dIvaIntDevengado, dLineaDisponible,
          dPagosVdos, cDescStatusCred, iIdUnidadProd, cDescBloqueoCta, cCodCaract2,
          cDescCausaBloqueoCta, cSitCte, cCausaCte, cDescSitEspCte, cSitCred,
          cCausaCred, cDescSitEspCred;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicred:sp_consulta_saldos_general";
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00397';
			RETURN cCodRet,pNumCredito,cNumProducto_vc,dLineaOtorgada,dtFechaOrigen,dSdoUltCorte,mInt_Moratorios, mIva_Int_Moratorios,
			dIntVig,dIvaIntVig,mCom_Pend,mIva_Com,dAbonos_His,dSdoActCap,dPagoMinimo,iPlazo, dtFechaProxPago,dSdoTotalLiq,dAhorroPago,iPagosRealizados,mCap_Vdo_Exig;
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00397';
			RETURN cCodRet,pNumCredito,cNumProducto_vc,dLineaOtorgada,dtFechaOrigen,dSdoUltCorte,mInt_Moratorios, mIva_Int_Moratorios,
			dIntVig,dIvaIntVig,mCom_Pend,mIva_Com,dAbonos_His,dSdoActCap,dPagoMinimo,iPlazo, dtFechaProxPago,dSdoTotalLiq,dAhorroPago,iPagosRealizados,mCap_Vdo_Exig;
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '00398';
			RETURN cCodRet,pNumCredito,cNumProducto_vc,dLineaOtorgada,dtFechaOrigen,dSdoUltCorte,mInt_Moratorios, mIva_Int_Moratorios,
			dIntVig,dIvaIntVig,mCom_Pend,mIva_Com,dAbonos_His,dSdoActCap,dPagoMinimo,iPlazo, dtFechaProxPago,dSdoTotalLiq,dAhorroPago,iPagosRealizados,mCap_Vdo_Exig;
		ELIF iCodRetSp = 4 THEN
			LET cCodRet = '00398';
			RETURN cCodRet,pNumCredito,cNumProducto_vc,dLineaOtorgada,dtFechaOrigen,dSdoUltCorte,mInt_Moratorios, mIva_Int_Moratorios,
			dIntVig,dIvaIntVig,mCom_Pend,mIva_Com,dAbonos_His,dSdoActCap,dPagoMinimo,iPlazo, dtFechaProxPago,dSdoTotalLiq,dAhorroPago,iPagosRealizados,mCap_Vdo_Exig;
		ELIF iCodRetSp = 5 THEN
			LET cCodRet = '00399';
			RETURN cCodRet,pNumCredito,cNumProducto_vc,dLineaOtorgada,dtFechaOrigen,dSdoUltCorte,mInt_Moratorios, mIva_Int_Moratorios,
			dIntVig,dIvaIntVig,mCom_Pend,mIva_Com,dAbonos_His,dSdoActCap,dPagoMinimo,iPlazo, dtFechaProxPago,dSdoTotalLiq,dAhorroPago,iPagosRealizados,mCap_Vdo_Exig;
		ELIF iCodRetSp = 6 THEN
			LET cCodRet = '00400';
			RETURN cCodRet,pNumCredito,cNumProducto_vc,dLineaOtorgada,dtFechaOrigen,dSdoUltCorte,mInt_Moratorios, mIva_Int_Moratorios,
			dIntVig,dIvaIntVig,mCom_Pend,mIva_Com,dAbonos_His,dSdoActCap,dPagoMinimo,iPlazo, dtFechaProxPago,dSdoTotalLiq,dAhorroPago,iPagosRealizados,mCap_Vdo_Exig;
		ELIF iCodRetSp = 7 THEN
			LET cCodRet = '00401';
			RETURN cCodRet,pNumCredito,cNumProducto_vc,dLineaOtorgada,dtFechaOrigen,dSdoUltCorte,mInt_Moratorios, mIva_Int_Moratorios,
			dIntVig,dIvaIntVig,mCom_Pend,mIva_Com,dAbonos_His,dSdoActCap,dPagoMinimo,iPlazo, dtFechaProxPago,dSdoTotalLiq,dAhorroPago,iPagosRealizados,mCap_Vdo_Exig;
		ELIF iCodRetSp = 8 THEN
			LET cCodRet = '00401';
			RETURN cCodRet,pNumCredito,cNumProducto_vc,dLineaOtorgada,dtFechaOrigen,dSdoUltCorte,mInt_Moratorios, mIva_Int_Moratorios,
			dIntVig,dIvaIntVig,mCom_Pend,mIva_Com,dAbonos_His,dSdoActCap,dPagoMinimo,iPlazo, dtFechaProxPago,dSdoTotalLiq,dAhorroPago,iPagosRealizados,mCap_Vdo_Exig;
		END IF;
	
		RETURN cCodRet,pNumCredito,cNumProducto_vc,dLineaOtorgada,dtFechaOrigen,dSdoUltCorte,mInt_Moratorios, mIva_Int_Moratorios,
			dIntVig,dIvaIntVig,mCom_Pend,mIva_Com,dAbonos_His,dSdoActCap,dPagoMinimo,iPlazo, dtFechaProxPago,dSdoTotalLiq,dAhorroPago,iPagosRealizados,mCap_Vdo_Exig;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 21/01/2017',
'MODULO: KIOSKO',
'FUNCIONALIDAD: Consulta de Saldos de Prestamos',
'DESCRIPCION: Proporciona informacion para la generaciÃ³n de la pantalla y la impresion de ticket de la consulta de Movimientos de Prestamo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_kiosko_consultatotalmovprestamos(pUsuario CHAR(8), pIdFuncion CHAR(10), cNUMCUENTA CHAR(20), dPERIODOI DATE, dPERIODOF DATE)
		returning CHAR(5)  AS Cod_Retorno,
			INTEGER AS numero_registros;
		
		
	DEFINE iexiste	INT;
	DEFINE cCodRet	CHAR(5);
	DEFINE iSqlErr	INT;     
	DEFINE cEmpresa CHAR(3);
	DEFINE iCont    INT;
	
	LET iexiste 	= 0;
	LET iSqlErr 	= 0 ;  
	LET cCodRet 	= "00000";
	LET cEmpresa 	= '001';
	LET iCont       = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iexiste;
			RETURN cCodRet, iexiste;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_kiosko_consultatotalmovprestamos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR cNUMCUENTA = '' OR dPERIODOI IS NULL OR dPERIODOF IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iCont;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iCont;
		END IF;
		
		
		SET ISOLATION TO DIRTY READ;
        SELECT COUNT(MO.num_credito) 
		INTO iexiste
		FROM bdicred:"informix".sd_movdiacrd MO
		LEFT JOIN bdicred:"informix".sd_transfun TR
		ON TR.empresa = cEmpresa AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
		WHERE MO.empresa= cEmpresa AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF;
		
		LET iCont= iCont + iexiste;

		SET ISOLATION TO DIRTY READ;
        SELECT COUNT(MO.num_credito) 
		INTO iexiste
		FROM bdicred:"informix".sd_movhiscrd MO
		LEFT JOIN bdicred:"informix".sd_transfun TR
		ON TR.empresa = cEmpresa AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
		WHERE MO.empresa= cEmpresa AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF;
		
		LET iCont= iCont + iexiste;
		
		IF iCont  = 0 THEN
		   LET cCodRet = "00039";
		   RETURN cCodRet, iCont;
		END IF;
		
		RETURN cCodRet, iCont;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 26/02/2016',
'MODULO: KIOSKO',
'FUNCIONALIDAD: CONSULTA MOVIMIENTOS CREDITO (PRESTAMOS)',
'DESCRIPCION: REALIZA LA CONSULTA DEL TOTAL MOVIIENTOS DE LOS PRODUCTOS DE CREDITO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cat_puntoscompromisosrespuesta(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		CHAR(5) AS cve_respuesta,
		CHAR(100) AS desc_respuesta;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCveRespuesta CHAR(5);
	DEFINE cDescRespuesta CHAR(100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCveRespuesta = '';
	LET cDescRespuesta = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCveRespuesta, cDescRespuesta;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cat_puntoscompromisosrespuesta.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCveRespuesta, cDescRespuesta;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCveRespuesta, cDescRespuesta;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH
			SELECT cve_respuesta, descripcion
			INTO cCveRespuesta, cDescRespuesta
			FROM "informix".cat_pcompromisos_respuesta
			
			RETURN cCodRet, cCveRespuesta, cDescRespuesta WITH RESUME;
		END FOREACH;	
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCveRespuesta, cDescRespuesta;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 20/02/2017',
'MODULO: CONSULTAS > APOYO',
'FUNCIONALIDAD: CONSULTAS DE PUNTOS COMPROMISOS',
'DESCRIPCION:SPL que consulta el catalo de respuesta',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_puntoscompro_metodocaptura(pUsuario CHAR(8), pIdFuncion CHAR(10))
        RETURNING CHAR(5) AS codret,
        CHAR(2) AS cve_metodo,
		CHAR(30) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
    DEFINE iCodRetSp INTEGER;
	DEFINE iErr INTEGER;
    DEFINE cCveMetodo CHAR(2);
    DEFINE cDescripcion CHAR(30);      
    DEFINE iRecuperacion INTEGER;
        
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '000000';
    LET iCodRetSp = 0;
	LET iErr =0;
    LET cCveMetodo = '';
    LET cDescripcion = '';
    LET iRecuperacion = 0;
   
	BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCveMetodo, cDescripcion;
		END EXCEPTION;
        
		--SET DEBUG FILE TO '/tmp/mfinis/sp_puntoscompro_metodocaptura.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCveMetodo, cDescripcion;
		END IF;
        
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN  cCodRet, cCveMetodo, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH
            EXECUTE PROCEDURE intercard:"informix".sp_metodocaptura()  
            INTO iErr, cCveMetodo, cDescripcion
			
			IF iErr < 0 THEN 
				RAISE EXCEPTION iErr, 0, 'ERROR EN LA EJECUCIÓN DEL SP intercard:sp_metodocaptura';
			END IF;
			
            LET iRecuperacion = iRecuperacion + 1;
            RETURN cCodRet, cCveMetodo,  UPPER(TRIM(cDescripcion)) WITH RESUME;           
        END FOREACH;
		
		LET iRecuperacion = DBINFO('sqlca.sqlerrd2');
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCveMetodo, cDescripcion;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 13/02/2016',
'MODULO: CONSULTAS APOYO',
'FUNCIONALIDAD: CONSULTAS DE PUNTOS COMPROMISOS',
'DESCRIPCION:SPL Intermedio que consulta el catalogo de metodos de Captura',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_generacedulaintsisr( pEmpresa CHAR(3), pFecha DATE ) 
RETURNING CHAR(5);
    
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iTransacc        SMALLINT;
    DEFINE dFecha           DATE;
    DEFINE cProducto        CHAR(4);
    DEFINE cNombreProd      CHAR(40);
    DEFINE mIntsCalculados  DECIMAL(18,2);
    DEFINE mIntsPagados     DECIMAL(18,2);
    DEFINE mDifIntereses    DECIMAL(18,2);
    DEFINE mISRCalculado    DECIMAL(14,2);
    DEFINE mIsrCobrado      DECIMAL(18,2);
    DEFINE mDiferenciaISR   DECIMAL(14,2);
    DEFINE cObservaciones   CHAR(255);
    DEFINE cEditable        CHAR(1);
    
    LET cCodRet1        = '000';
    LET cCodRet2        = '';
    LET cCodRet3        = '';
    LET iSqlErr	        = 0;
    LET iSamErr         = 0;
    LET cDesErr         = '';
    LET iTransacc       = 0;
    LET dFecha          = '';
    LET cProducto       = '';
    LET cNombreProd     = '';
    LET mIntsCalculados = 0.00;
    LET mIntsPagados    = 0.00;
    LET mDifIntereses   = 0.00;
    LET mISRCalculado   = 0.00;
    LET mIsrCobrado     = 0.00;
    LET mDiferenciaISR  = 0.00;
    LET cObservaciones  = '';
    LET cEditable       = '0';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_generacedulaintsisr.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            IF iTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;  
    
    on exception in (-535)
        let iTransacc = 1;
    end exception with resume;
	
	IF iTransacc = 1 THEN
       COMMIT WORK;
	   LET iTransacc = 0;
    END IF;
	
	--- SET DEBUG FILE TO "/tmp/sp_generacedulaintsisr.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pEmpresa is null OR pEmpresa = '' ) OR
         ( pFecha is null OR pFecha = '' ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1;
    END IF;
    
    FOREACH WITH HOLD
        SELECT fecha, producto, nombre, 
               SUM(interes_calculado), SUM(interes_pagado), SUM(diferencia_interes), 
               SUM(isr_calculado), SUM(isr_cobrado), SUM(diferencia_isr)
          INTO dFecha, cProducto, cNombreProd, 
               mIntsCalculados, mIntsPagados, mDifIntereses, 
               mISRCalculado, mIsrCobrado, mDiferenciaISR
          FROM bdicheq:sc_pagoints_cobroisr
         WHERE fecha = pFecha
         GROUP BY 1, 2, 3
         ORDER BY 1, 2
            
        BEGIN WORK;
        LET iTransacc = 1;
               
        INSERT INTO bdicheq:sc_intisrxprodcedula
        ( fecha, producto, nombre, interes_calculado, interes_pagado, diferencia_interes, isr_calculado, isr_cobrado, diferencia_isr, observaciones, editable )
        VALUES
        ( dFecha, cProducto, cNombreProd, mIntsCalculados, mIntsPagados, mDifIntereses, mISRCalculado, mIsrCobrado, mDiferenciaISR, cObservaciones, cEditable );
        
        COMMIT WORK;
        LET iTransacc = 0;
        
        LET dFecha = '';
        LET cProducto = '';
        LET cNombreProd = '';
        LET mIntsCalculados = 0.00;
        LET mIntsPagados = 0.00;
        LET mDifIntereses = 0.00;
        LET mISRCalculado = 0.00;
        LET mIsrCobrado = 0.00;
        LET mDiferenciaISR = 0.00;
    ENd FOREACH;
    
    END;
    
    RETURN cCodRet1;
    
END PROCEDURE;