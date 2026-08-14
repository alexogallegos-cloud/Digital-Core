CREATE PROCEDURE "informix".sp_tef_generararchivo62(cNombreArchivo CHAR(20), cUsuario CHAR(8))
RETURNING CHAR(5) AS CodRet;

--DEFINICION DE VARIABLES.
DEFINE dFechaHoy				DATE;
DEFINE dFechaHabil				DATE;
DEFINE cFechaPresentacionGen	CHAR(8);

DEFINE cCodRet					CHAR(5);
DEFINE cCodRet2					CHAR(5);
DEFINE cCodRet3					CHAR(5);
DEFINE cStatus_tar				CHAR(2);
DEFINE cPrefijoTarjeta			CHAR(6);

DEFINE cCuenta					CHAR(12);
DEFINE cStatus_Cta				CHAR(1);
DEFINE cProducto				CHAR(4);
DEFINE cNombreArch				CHAR(20);
DEFINE cFechaPresentacion		CHAR(8);
DEFINE cTipoRegistro			CHAR(2);
DEFINE cNumSecuencia			CHAR(7);
DEFINE cCodOperacion			CHAR(2);
DEFINE cCodDivisa				CHAR(2);
DEFINE cFechaTrans				CHAR(8);
DEFINE cBancoPresentador		CHAR(3);
DEFINE cBancoReceptor			CHAR(3);
DEFINE cImporte					CHAR(15);
DEFINE cUsoFuturoCcen			CHAR(16);
DEFINE cTipoOperacion			CHAR(2);
DEFINE cFechaAplica				CHAR(8);
DEFINE cTipoCtaOrd				CHAR(2);
DEFINE cNumCtaOrd				CHAR(20);
DEFINE cNombreOrd				CHAR(40);
DEFINE cRfcOrd					CHAR(18);
DEFINE cTipoCtaRec				CHAR(2);
DEFINE cNumCtaRec				CHAR(20);
DEFINE cNombreRec				CHAR(40);
DEFINE cRfcRec					CHAR(18);
DEFINE cRefServicio				CHAR(40);
DEFINE cNombreTitularServ		CHAR(40);
DEFINE cImporteIva				CHAR(15);
DEFINE cRefNumerica				CHAR(7);
DEFINE cRefLeyenda				CHAR(40);
DEFINE cClaveRastreo			CHAR(30);
DEFINE cMotivoDev				CHAR(2);
DEFINE cFechaPresIni			CHAR(8);
DEFINE cSolicitudConfirmacion	CHAR(1);
DEFINE cUsoFuturoBanco			CHAR(11);
DEFINE cRefConfirmacion			CHAR(30);
DEFINE cUsoFuturoCce			CHAR(1);
DEFINE cTasaTiieProm			CHAR(7);
DEFINE cDiasRetraso				CHAR(3);
DEFINE cImpTotInt				CHAR(15);
DEFINE cCveEstatus				CHAR(11);
DEFINE cFolioSuc				CHAR(30);

DEFINE cClaveBancaria			CHAR(3);
DEFINE cPrefijoTarjetaDebito	CHAR(100);
DEFINE cSucursalContable		CHAR(4);
DEFINE cNumeroFolioAbono		CHAR(16);
DEFINE cTransaccAbono			CHAR(4);

DEFINE mSaldoAPagar				MONEY(16,2);
DEFINE cTransacAbonoCred		CHAR(4);

DEFINE iContadorSecuencia62		INTEGER;
DEFINE iImporteTotalArchivo62	INT8;
--*
DEFINE cNumCte 					CHAR(20);
DEFINE sCanal					SMALLINT;
DEFINE cEsTransfer				CHAR(1);
DEFINE cUserInsert				CHAR(8);
DEFINE dtFechaHoraInsert		DATETIME YEAR TO SECOND;
--*

--ENCABEZADO
DEFINE cCveBancoE				CHAR(3);
DEFINE cServicioE				CHAR(1);
DEFINE cNumBloqueE				CHAR(7);
DEFINE cCodDivisaE				CHAR(2);
DEFINE cCveRechazoblE			CHAR(2);
DEFINE cModalidadE				CHAR(1);
DEFINE cUsoFuturoCcenE			CHAR(41);
DEFINE cUsoFuturoBancoE		CHAR(370);

--SUMARIO
DEFINE cNumBloqueS				CHAR(7);
DEFINE cUsoFuturoCcenS			CHAR(40);
DEFINE cUsoFuturoBancoS			CHAR(364);


DEFINE cNombreArchivoAUX		CHAR(20);
DEFINE iContadorSecuenciaAUX	INTEGER;

--REVERSOS
DEFINE cTransaccCargo			CHAR(4);
DEFINE cTranRet					CHAR(4);


DEFINE mSaldoDisponible			MONEY(16,2);
DEFINE mMontoRetenido			MONEY(16,2);

--TRANSACCIONES
DEFINE cFlagEnTransaccion		CHAR (1);
DEFINE iContadorRegistros		INTEGER;

DEFINE iSQLerr					INTEGER;

--RETORNO DEL PRINCIPAL
DEFINE mRemanente				MONEY(14,2);
DEFINE mIntMoraCob				MONEY(14,2);
DEFINE mIntVencCob				MONEY(14,2);
DEFINE mCapVencCob				MONEY(14,2);
DEFINE mIntVigCob				MONEY(14,2);
DEFINE mCapVigCob				MONEY(14,2);
DEFINE mImpuesto				MONEY(14,2);
DEFINE mComision				MONEY(14,2);
DEFINE mSeguro					MONEY(14,2);

--NOMBRES DE LOS ARCHIVOS
DEFINE cNomArchivo62			CHAR(20);
DEFINE iNumArchivos				INTEGER;

--FLAG ARCHIVO 62
DEFINE cFlagArch62				CHAR(1);

--TIPO DE PROCESO MANUAL O AUTOMATICO
DEFINE cFlagTipoProceso 		CHAR (1);

--DESCRIPCION DEL PROCESO
DEFINE cDescripcionProceso		CHAR (60);

--CONSTANTES
DEFINE cPROCESANDO				CHAR(1);
DEFINE cERROR 					CHAR(1);
DEFINE cFINALIZADO				CHAR(1);

--SET DEBUG FILE TO '/tmp/josea/sp_generararchivo62.out';
--TRACE ON;

--INICIALIZACION DE VARIABLES.
LET cCodRet					= '';
LET cCodRet2				= '';
LET cCodRet3				= '';

LET cPrefijoTarjeta			= '';

LET cCuenta					= '';
LET cStatus_Cta				= '';
LET cProducto				= '';
LET dFechaHoy				= CURRENT;
LET dFechaHabil				= CURRENT;
LET cStatus_tar				= '';
LET cFechaPresentacionGen 	= '';

LET cNombreArch				= '';
LET cFechaPresentacion		= '';
LET cTipoRegistro			= '';
LET cNumSecuencia			= '';
LET cCodOperacion			= '';
LET cCodDivisa				= '';
LET cFechaTrans				= '';
LET cBancoPresentador		= '';
LET cBancoReceptor			= '';
LET cImporte				= '';
LET cUsoFuturoCcen			= '';
LET cTipoOperacion			= '';
LET cFechaAplica			= '';
LET cTipoCtaOrd				= '';
LET cNumCtaOrd				= '';
LET cNombreOrd				= '';
LET cRfcOrd					= '';
LET cTipoCtaRec				= '';
LET cNumCtaRec				= '';
LET cNombreRec				= '';
LET cRfcRec					= '';
LET cRefServicio			= '';
LET cNombreTitularServ		= '';
LET cImporteIva				= '';
LET cRefNumerica			= '';
LET cRefLeyenda				= '';
LET cClaveRastreo			= '';
LET cMotivoDev				= '';
LET cFechaPresIni			= '';
LET cSolicitudConfirmacion = '';
LET cUsoFuturoBanco			= '';
LET cRefConfirmacion		= '';
LET cUsoFuturoCce			= '';
LET cTasaTiieProm			= '';
LET cDiasRetraso			= '';
LET cImpTotInt				= '';
LET cCveEstatus				= '';
LET cFolioSuc				= '';

LET cClaveBancaria			= '';
LET cPrefijoTarjetaDebito	= '';
LET cSucursalContable		= '';
LET cNumeroFolioAbono		= '';
LET cTransaccAbono			= '';
LET mSaldoAPagar			= 0.0;
LET cTransacAbonoCred		= '';


LET iContadorSecuencia62	= 0;
LET iImporteTotalArchivo62	= 0;
--*
LET cNumCte 				= "";
LET sCanal					= 0;
LET cEsTransfer				= "";
LET cUserInsert				= "";
LET dtFechaHoraInsert		= DATE(1);
--*

--ENCABEZADO
LET cCveBancoE				= '';
LET cServicioE				= '';
LET cNumBloqueE				= '';
LET cCodDivisaE				= '';
LET cCveRechazoblE			= '';
LET cModalidadE				= '';
LET cUsoFuturoCcenE			= '';
LET cUsoFuturoBancoE		= '';


--SUMARIO
LET cNumBloqueS				= '';
LET cUsoFuturoCcenS			= '';
LET cUsoFuturoBancoS		= '';

LET cNombreArchivoAUX		= '';
LET iContadorSecuenciaAUX	= '';

--REVERSOS
LET cTransaccCargo			= '';
LET cTranRet				= '';
LET dFechaHoy				= CURRENT;
LET mSaldoDisponible		= 0.0;
LET mMontoRetenido			= 0.0;

--RETORNO DEL PRINCIPAL
LET mRemanente				=0;
LET mIntMoraCob				=0;
LET mIntVencCob				=0;
LET mCapVencCob				=0;
LET mIntVigCob				=0;
LET mCapVigCob				=0;
LET mImpuesto				=0;
LET mComision				=0;
LET mSeguro					=0;


--TRANSACCIONES
LET cFlagEnTransaccion		='F';
LET iContadorRegistros		=0;

--NOMBRES ARCHIVOS
--LET cNomArchivo61			='';
LET cNomArchivo62			='';
LET iNumArchivos			=0;

--FLAG ARCHIVO 62
LET cFlagArch62				='F';

--TIPO DE PROCESO MANUAL O AUTOMATICO
LET cFlagTipoProceso 		='';

--DESCRIPCION DEL PROCESO
LET cDescripcionProceso		='';

--CONSTANTES
LET cPROCESANDO 			='0';
LET cFINALIZADO				='1';
LET cERROR					='3';

LET iSQLerr					=0;

BEGIN
ON EXCEPTION SET iSQLerr
	IF iSQLerr <> 0 THEN
		LET cDescripcionProceso = 'Error en el proceso';
		EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, 'RECARCH_' || 62 || '.' || SUBSTRING (TRIM(cNombreArchivo) FROM 15 FOR 2), cDescripcionProceso,
		cERROR, iSqlErr, cUsuario, 'ERROR NO CONTROLADO', TRIM(cNombreArchivo), cFechaPresentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO cCodRet;
	
		-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
		IF ((iContadorRegistros > 0) OR (cFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET cFlagEnTransaccion = 'F';
		END IF;

		LET cFlagEnTransaccion = 'F';
		LET iContadorRegistros = 0;

		--EN CASO DE ERROR NO CONTROLADO SE REVERSAN LOS ABONOS
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--OBTIENE LOS REGISTROS VALIDOS DEL ARCHIVO 60 PARA PROCESAR
		FOREACH WITH HOLD
			SELECT
			Nombre_Arch, Fecha_Presentacion, Tipo_Registro, Num_Secuencia, Cod_Operacion, Cod_Divisa, Fecha_Trans,
			Banco_Presentador, Banco_Receptor, Importe, Uso_Futuro_ccen, Tipo_Operacion, Fecha_Aplica, Tipo_Cta_Ord,
			Num_Cta_Ord, Nombre_Ord, Rfc_Ord, Tipo_Cta_Rec, Num_Cta_Rec, Nombre_Rec, Rfc_Rec, Ref_Servicio,
			Nombre_Titular_Serv, Importe_Iva, Ref_Numerica, Ref_Leyenda, Clave_Rastreo, Motivo_Dev, Fecha_Pres_Ini,
			Solicitud_Confirmacion, Uso_Futuro_Banco, Ref_Confirmacion, Uso_Futuro_Cce, Tasa_Tiie_Prom, Dias_Retraso,
			Imp_Tot_Int, Cve_Status, Folio_Suc
			INTO
			cNombreArch, cFechaPresentacion, cTipoRegistro, cNumSecuencia, cCodOperacion, cCodDivisa, cFechaTrans,
			cBancoPresentador, cBancoReceptor, cImporte, cUsoFuturoCcen, cTipoOperacion, cFechaAplica, cTipoCtaOrd,
			cNumCtaOrd, cNombreOrd, cRfcOrd, cTipoCtaRec, cNumCtaRec, cNombreRec, cRfcRec, cRefServicio,
			cNombreTitularServ, cImporteIva, cRefNumerica, cRefLeyenda, cClaveRastreo, cMotivoDev, cFechaPresIni,
			cSolicitudConfirmacion, cUsoFuturoBanco, cRefConfirmacion, cUsoFuturoCce, cTasaTiieProm, cDiasRetraso,
			cImpTotInt, cCveEstatus, cFolioSuc
			FROM BdiTef:"informix".Tef_Cce_Detalle_Paso
			WHERE Nombre_Arch = cNomArchivo62 AND Cod_operacion = '62'
			
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (cFlagEnTransaccion = 'F') THEN
				 BEGIN WORK;
				 LET cFlagEnTransaccion = 'V';
			END IF;
			LET cCodRet = '00000';
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT FIRST 1 Valor INTO cSucursalContable FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '77'; --SUCURSAL CONTABLE
			IF ( TRIM(cTipoCtaRec)='11') THEN   --VALIDACION PARA SABER SI ES CREDITO, SE OBTIENE EL NUMERO DE CREDITO
				LET cCuenta = SUBSTR(cNumCtaRec,9,12);
				--LA CUENTA ES DE CREDITO
				IF ( EXISTS ( SELECT Num_Credito FROM BdiCred:Sd_MaeCred
					WHERE Empresa = '001' AND Num_Credito = cCuenta ) )  THEN --VALIDA NUMERO DE CREDITO
					IF ( EXISTS ( SELECT NUM_CREDITO FROM BDICRED:"informix".Sd_MaeCred
						WHERE EMPRESA = '001' AND NUM_CREDITO = cCuenta AND status_cred IN ('AA','BT','BA') ) ) THEN
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
						SELECT NVL(VALOR,'') INTO cTransacAbonoCred FROM BDITEF:"informix".tef_parametros WHERE cod_param='83';
						LET cNumeroFolioAbono = '';
						LET mSaldoAPagar = ((cImporte::INTEGER)/100);
						--REALIZA EL CARGO REVERSADO
						EXECUTE PROCEDURE bdicred:"informix".reversion ('001', cSucursalContable, cUsuario,cFolioSuc, "M") INTO cCodRet;
					ELSE
						LET cMotivoDev = '02'; --LA CUENTA DE CREDITO NO ESTA ACTIVA
					END IF;
				ELSE
					LET cMotivoDev = '01'; --LA CUENTA DE CREDITO NO EXISTE
				END IF;
			ELSE
				
				IF (TRIM(NVL(cTipoCtaRec, '')) = '10') THEN -- VALIDAMOS TIPO CUENTA MOVIL
				-- EJECUTAMOS EL PROCEDIMIENTO NUEVO 
				--*
				EXECUTE PROCEDURE bdicheq:"informix".sp_tef_constelctacte (SUBSTR(cNumCtaRec, 11,10)) -- OBTENEMOS LA CUENTA DEL NUMERO MOVIL 
				INTO cCodRet, cNumCte, cCuenta, sCanal, cEsTransfer, cUserInsert, dtFechaHoraInsert; -- REGRESA CUENTA DEL TELEFONO MOVIL
				
				-- SI NO HAY CUENTA PARA EL  MOVIL, ASIGNAMOS MOTIVO DEVOLUCIÃÂÃÂN.
				IF NVL(cCuenta, '') = '' THEN	
					LET cMotivoDev = '01'; -- CUENTA INEXISTENTE.
				END IF;
				--*
				ELIF ( TRIM(cTipoCtaRec)='40') THEN    --VALIDACION PARA CONOCER SI ES CREDITO O DEBITO
					LET cCuenta = SUBSTR(cNumCtaRec,9,11);
				ELIF ( TRIM(cTipoCtaRec)='03') THEN
					SELECT FIRST 1 NVL(Cuenta,''),status_tar INTO cCuenta,cStatus_tar FROM BdiCheq:"informix".Sc_Tarjeta 
					WHERE Empresa = '001' AND Num_Tarjeta = SUBSTR(TRIM(cNumCtaRec),5,16);
				ELSE
					LET cMotivoDev = '06'; --CUENTA NO PERTENECE AL BANCO RECEPTOR
				END IF;
				
				IF (cStatus_tar = 'C') THEN
					LET cMotivoDev = '03';
				END IF;
				
				LET cStatus_tar = ' ';
				LET cNumeroFolioAbono = '';
				LET mSaldoAPagar = ((cImporte::INTEGER)/100);
				
				--OBTIENE FOLIO DEL CARGO
				EXECUTE PROCEDURE BdiCheq:"informix".Sp_GeneraFolioNomina(cUsuario) INTO cCodRet, cNumeroFolioAbono;
				LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
				
				IF (cCodRet <> '00000') THEN --ERROR AL OBTENER EL FOLIO DEL ABONO
					LET cCodRet = '02304';
				ELSE --OK
					--REALIZA EL CARGO
					EXECUTE PROCEDURE BdiCheq:"informix".Cargo_Ref ("001", cSucursalContable, cUsuario,  cTransaccCargo, 
									"0000", cNumeroFolioAbono, cCuenta,0, mSaldoAPagar, '01', cRefLeyenda, '', cUsuario) INTO cCodRet, cTranRet, 
									dFechaHoy, mSaldoDisponible, mMontoRetenido;
				END IF;
			END IF;
			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (iContadorRegistros = 1000) THEN --VERIFICA SI ALCANZO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET cFlagEnTransaccion = 'F';
				LET iContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;
		END FOREACH;
		-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
		IF ((iContadorRegistros > 0) OR (cFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET cFlagEnTransaccion = 'F';
		END IF;
		--USAR SP DE BORRADO PARA LOS 2 ARCHIVOS.
		--BORRA LOS REGISTROS DE LOS ARCHIVOS 62
		LET cDescripcionProceso = 'BORRA LOS REGISTROS DE LOS ARCHIVOS 62';
		EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist(cNomArchivo62, cFechaPresentacionGen, 'B', '') INTO cCodRet;
		LET cCodRet = iSQLerr;
		RETURN cCodRet;
	END IF;
END EXCEPTION;
	
	ON EXCEPTION IN (-535)
		COMMIT WORK;
	END EXCEPTION WITH RESUME;
	
	-------SE OBTIENEN LOS PARAMETROS----
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO cClaveBancaria FROM BdiTef:"informix".Tef_Parametros WHERE cod_param = '75';
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO cPrefijoTarjetaDebito FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '76'; -- PREFIJO TARJETA DEBITO
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO cSucursalContable FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '77'; --SUCURSAL CONTABLE
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO cTransaccCargo FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '78'; --TRANSACCION CARGO TEF
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO cTransaccAbono FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '79'; --TRANSACCION ABONO TEF
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--EXTRAE LA FECHA HOY EN EL SISTEMA
	SELECT FIRST 1 Fecha_hoy INTO dFechaHoy FROM BdiCheq:"informix".sc_fechas;
	
	--ASIGNA UN FORMATO DE FECHA PARA FUTURA FECHA DE PRESENTACION
	LET cFechaPresentacionGen = YEAR(dFechaHoy)|| LPAD(MONTH (dFechaHoy),2,'0') || LPAD(DAY (dFechaHoy),2,'0');
	
	--VALIDA LA FECHA ACTUAL
	EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Fecha(cFechaPresentacionGen) INTO cCodRet3;
	
	--VALIDA QUE LA FECHA ACTUAL SEA DIA HABIL
	EXECUTE PROCEDURE BdInteg:"informix".sp_Valfecha_Banca('001', dFechaHoy, 0 ) INTO cCodRet2,dFechaHabil;
	
	IF cNombreArchivo = '' THEN --AUTOMATICO 
		LET cFlagTipoProceso = 'A';
	ELSE 
		LET cFlagTipoProceso = 'M';
	END IF;
	
	IF (NOT EXISTS (SELECT Sucursal FROM BdInteg:"informix".Si_Sucursales WHERE Sucursal = cSucursalContable)) THEN --VALIDAR SI EXISTE EN EL CATÃÂÃÂLOGO LA SUCURSAL CONTABLE.
		LET cCodRet = '02300';
	--ELIF (cCodRet2 <> '000') THEN -- VALIDA KE LA FECHA HOY SEA UN DIA HABIL
	ELIF (dFechaHoy <> dFechaHabil) THEN -- VALIDA KE LA FECHA HOY SEA UN DIA HABIL
		LET cCodRet = '02302';
	ELIF (cCodRet3 <> '00000') THEN -- VALIDA KE LA FECHA HOY SEA VALIDA
		LET cCodRet = '02303';
	ELSE
		LET cFlagEnTransaccion = 'F';
		LET iContadorRegistros = 0;
		LET iContadorSecuencia62 = 1; --A PARTIR DE 2 ES PARA EL DETALLE
		LET iImporteTotalArchivo62 = 0;
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF cNombreArchivo = '' THEN --AUTOMATICO 
			LET cFlagTipoProceso = 'A';
			IF EXISTS(SELECT Nombre_Arch 
			FROM BdiTef:"informix".Tef_Cce_Detalle dhist
			WHERE dhist.Fecha_aplica = cFechaPresentacionGen AND dhist.Cod_operacion = '60' 
			AND dhist.Cve_Status = '00') THEN
				IF EXISTS (SELECT 1 FROM tef_cce_detalle_paso WHERE fecha_aplica = cFechaPresentacionGen AND cod_operacion = '60' AND cve_Status = '00') THEN
					DELETE FROM tef_cce_detalle_paso WHERE fecha_aplica = cFechaPresentacionGen AND cod_operacion = '60' AND cve_Status = '00';
				END IF;
				INSERT INTO BdiTef:"informix".tef_cce_detalle_paso 
				(Nombre_Arch, Fecha_Presentacion, Tipo_Registro, Num_Secuencia, Cod_Operacion, Cod_Divisa, Fecha_Trans, Banco_Presentador, 
				Banco_Receptor, Importe, Uso_Futuro_Ccen, Tipo_Operacion, Fecha_Aplica, Tipo_Cta_Ord, Num_Cta_Ord, Nombre_Ord, Rfc_Ord, 
				Tipo_Cta_Rec, Num_Cta_Rec, Nombre_Rec, Rfc_Rec, Ref_Servicio, Nombre_Titular_Serv, Importe_Iva, Ref_Numerica, Ref_Leyenda, 
				Clave_Rastreo, Motivo_Dev, Fecha_Pres_Ini, Solicitud_Confirmacion, Uso_Futuro_Banco, Ref_Confirmacion, Uso_Futuro_Cce, 
				Tasa_Tiie_Prom, Dias_Retraso, Imp_Tot_Int, Cve_Status, Folio_Suc, User_Insert, Fecha_Insert) 
				SELECT dhist.Nombre_Arch, dhist.Fecha_Presentacion, dhist.Tipo_Registro, dhist.Num_Secuencia, dhist.Cod_Operacion, dhist.Cod_Divisa, dhist.Fecha_Trans, dhist.Banco_Presentador, 
				dhist.Banco_Receptor, dhist.Importe, dhist.Uso_Futuro_Ccen, dhist.Tipo_Operacion, dhist.Fecha_Aplica, dhist.Tipo_Cta_Ord, dhist.Num_Cta_Ord, dhist.Nombre_Ord, dhist.Rfc_Ord, 
				dhist.Tipo_Cta_Rec, dhist.Num_Cta_Rec, dhist.Nombre_Rec, dhist.Rfc_Rec, dhist.Ref_Servicio, dhist.Nombre_Titular_Serv, dhist.Importe_Iva, dhist.Ref_Numerica, dhist.Ref_Leyenda, 
				dhist.Clave_Rastreo, dhist.Motivo_Dev, dhist.Fecha_Pres_Ini, dhist.Solicitud_Confirmacion, dhist.Uso_Futuro_Banco, dhist.Ref_Confirmacion, dhist.Uso_Futuro_Cce, 
				dhist.Tasa_Tiie_Prom, dhist.Dias_Retraso, dhist.Imp_Tot_Int, dhist.Cve_Status, dhist.Folio_Suc, dhist.User_Insert, Fecha_Insert 
				FROM BdiTef:"informix".Tef_Cce_Detalle dhist
				WHERE dhist.Fecha_aplica = cFechaPresentacionGen AND dhist.Cod_operacion = '60' 
				AND dhist.Cve_Status = '00';
			END IF;
		ELSE--MANUAL
			LET cFlagTipoProceso = 'M';
			LET cNombreArchivo = cNombreArchivo;
			IF EXISTS (SELECT 1 FROM tef_cce_detalle_paso WHERE nombre_arch = cNombreArchivo AND cod_operacion = '60' AND cve_Status = '00') THEN
				DELETE FROM tef_cce_detalle_paso WHERE nombre_arch = cNombreArchivo AND cod_operacion = '60' AND cve_Status = '00';
			END IF;
			
			INSERT INTO tef_cce_detalle_paso 
			(Nombre_Arch, Fecha_Presentacion, Tipo_Registro, Num_Secuencia, Cod_Operacion, Cod_Divisa, Fecha_Trans, Banco_Presentador, 
			Banco_Receptor, Importe, Uso_Futuro_Ccen, Tipo_Operacion, Fecha_Aplica, Tipo_Cta_Ord, Num_Cta_Ord, Nombre_Ord, Rfc_Ord, 
			Tipo_Cta_Rec, Num_Cta_Rec, Nombre_Rec, Rfc_Rec, Ref_Servicio, Nombre_Titular_Serv, Importe_Iva, Ref_Numerica, Ref_Leyenda, 
			Clave_Rastreo, Motivo_Dev, Fecha_Pres_Ini, Solicitud_Confirmacion, Uso_Futuro_Banco, Ref_Confirmacion, Uso_Futuro_Cce, 
			Tasa_Tiie_Prom, Dias_Retraso, Imp_Tot_Int, Cve_Status, Folio_Suc, User_Insert, Fecha_Insert) 
			SELECT dhist.Nombre_Arch, dhist.Fecha_Presentacion, dhist.Tipo_Registro, dhist.Num_Secuencia, dhist.Cod_Operacion, dhist.Cod_Divisa, dhist.Fecha_Trans, dhist.Banco_Presentador, 
			dhist.Banco_Receptor, dhist.Importe, dhist.Uso_Futuro_Ccen, dhist.Tipo_Operacion, dhist.Fecha_Aplica, dhist.Tipo_Cta_Ord, dhist.Num_Cta_Ord, dhist.Nombre_Ord, dhist.Rfc_Ord, 
			dhist.Tipo_Cta_Rec, dhist.Num_Cta_Rec, dhist.Nombre_Rec, dhist.Rfc_Rec, dhist.Ref_Servicio, dhist.Nombre_Titular_Serv, dhist.Importe_Iva, dhist.Ref_Numerica, dhist.Ref_Leyenda, 
			dhist.Clave_Rastreo, dhist.Motivo_Dev, dhist.Fecha_Pres_Ini, dhist.Solicitud_Confirmacion, dhist.Uso_Futuro_Banco, dhist.Ref_Confirmacion, dhist.Uso_Futuro_Cce, 
			dhist.Tasa_Tiie_Prom, dhist.Dias_Retraso, dhist.Imp_Tot_Int, dhist.Cve_Status, dhist.Folio_Suc, dhist.User_Insert, dhist.Fecha_Insert 
			FROM BdiTef:"informix".Tef_Cce_Detalle dhist
			WHERE dhist.Cod_operacion = '60' 
			AND dhist.Cve_Status = '00' AND dhist.Nombre_Arch = cNombreArchivo;
		END IF;
		
		LET cDescripcionProceso		= 'Validacion inicial en tabla de detalle ';
		IF DBINFO('sqlca.sqlerrd2') > 0 THEN		
		
			FOREACH WITH HOLD
				SELECT DISTINCT nombre_arch INTO cNombreArchivo
				FROM BdiTef:"informix".Tef_Cce_Detalle_Paso
				WHERE Cod_operacion = '60' AND Cve_Status = '00'
				LET cDescripcionProceso = 'Validacion de procesamientos previos.';
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				--EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, 'RECARCH_' || 62 || '.' || SUBSTRING (TRIM(cNombreArchivo) FROM 15 FOR 2), cDescripcionProceso,
				--cPROCESANDO, cCodRet, cUsuario, 'sp_tef_generararchivo62', TRIM(cNombreArchivo), cFechaPresentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO cCodRet;
				
				LET cCodRet = '00000';
				--NUMERO DE ARCHIVO
				LET iNumArchivos = 1;
				
				LET cNomArchivo62 = 'E'
					|| TRIM(cClaveBancaria) --ID BANCARIA BANCOPPEL 137
					|| LPAD(DAY(dFechaHoy),2,'0') --dd
					|| LPAD(MONTH(dFechaHoy),2,'0') --mm
					|| YEAR(dFechaHoy)  --aaaa
					|| '.62'--oo
					|| LPAD (iNumArchivos, 2, '0'); --cc
				
				
				--OBTIENE LOS REGISTROS VALIDOS DEL ARCHIVO 60 PARA PROCESAR
				FOREACH WITH HOLD
					SELECT
					Nombre_Arch, Fecha_Presentacion, Tipo_Registro, Num_Secuencia, Cod_Operacion, Cod_Divisa, Fecha_Trans,
					Banco_Presentador, Banco_Receptor, Importe, Uso_Futuro_ccen, Tipo_Operacion, Fecha_Aplica, Tipo_Cta_Ord,
					Num_Cta_Ord, Nombre_Ord, Rfc_Ord, Tipo_Cta_Rec, Num_Cta_Rec, Nombre_Rec, Rfc_Rec, Ref_Servicio,
					Nombre_Titular_Serv, Importe_Iva, Ref_Numerica, Ref_Leyenda, Clave_Rastreo, Motivo_Dev, Fecha_Pres_Ini,
					Solicitud_Confirmacion, Uso_Futuro_Banco, Ref_Confirmacion, Uso_Futuro_Cce, Tasa_Tiie_Prom, Dias_Retraso,
					Imp_Tot_Int, Cve_Status, Folio_Suc
					INTO
					cNombreArch, cFechaPresentacion, cTipoRegistro, cNumSecuencia, cCodOperacion, cCodDivisa, cFechaTrans,
					cBancoPresentador, cBancoReceptor, cImporte, cUsoFuturoCcen, cTipoOperacion, cFechaAplica, cTipoCtaOrd,
					cNumCtaOrd, cNombreOrd, cRfcOrd, cTipoCtaRec, cNumCtaRec, cNombreRec, cRfcRec, cRefServicio,
					cNombreTitularServ, cImporteIva, cRefNumerica, cRefLeyenda, cClaveRastreo, cMotivoDev, cFechaPresIni,
					cSolicitudConfirmacion, cUsoFuturoBanco, cRefConfirmacion, cUsoFuturoCce, cTasaTiieProm, cDiasRetraso,
					cImpTotInt, cCveEstatus, cFolioSuc
					FROM BdiTef:"informix".Tef_Cce_Detalle_Paso
					WHERE Nombre_Arch = cNombreArchivo AND Cod_operacion = '60'
					AND Cve_Status = '00'
					ORDER BY Num_Secuencia ASC
					
					--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
					IF (cFlagEnTransaccion = 'F') THEN
						 BEGIN WORK;
						 LET cFlagEnTransaccion = 'V';
					END IF;
					
					LET cMotivoDev = '00';
					LET cStatus_Cta = '';
					LET cCodRet = '00000';
					
					--VALIDACION DE CUENTAS
					-- 1.- Motivo 06 "CUENTA NO PERTENECE AL BANCO RECEPTOR" 
					IF ( TRIM(cTipoCtaRec) IN ('11','12','13') ) THEN    --VALIDACION PARA CONOCER SI ES CREDITO O DEBITO
						--LA CUENTA ES DE CREDITO
						LET cCuenta = SUBSTR(cNumCtaRec,9,12);
						
						IF ( EXISTS ( SELECT Num_Credito FROM BdiCred:Sd_MaeCred
							WHERE Empresa = '001' AND Num_Credito = cCuenta ) )  THEN --VALIDA NUMERO DE CREDITO
							IF ( EXISTS ( SELECT NUM_CREDITO FROM BDICRED:"informix".Sd_MaeCred
								WHERE EMPRESA = '001' AND NUM_CREDITO = cCuenta AND status_cred IN ('AA','BT','BA') ) ) THEN
								
								SET LOCK MODE TO WAIT 3;
								SET ISOLATION TO DIRTY READ;
								SELECT NVL(VALOR,'') INTO cTransacAbonoCred FROM BDITEF:"informix".tef_parametros WHERE cod_param='83';
								LET cNumeroFolioAbono = '';
								LET mSaldoAPagar = ((cImporte::INTEGER)/100);
								
								--OBTIENE FOLIO DEL ABONO
								EXECUTE PROCEDURE BdiCheq:"informix".Sp_GeneraFolioNomina(cUsuario) INTO cCodRet, cNumeroFolioAbono;
								LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
								
								IF (cCodRet <> '00000') THEN --ERROR AL OBTENER EL FOLIO DEL ABONO
									LET cCodRet = '02304';
								ELSE --OK
									--REALIZA EL ABONO
									EXECUTE PROCEDURE bdicred:"informix".principal(
									'001',					--Empresa
									cNumCtaRec,				--numcredito
									2,						--Tipo de pago
									mSaldoAPagar,			--Monto
									cUsuario, 				--Usuario
									cSucursalContable,		--Sucursal
									cNumeroFolioAbono, 		--Folio
									cTransacAbonoCred		--Transaccion
									) INTO
									cCodRet, mRemanente, mIntMoraCob, mIntVencCob, mCapVencCob,
									mIntVigCob, mCapVigCob, mImpuesto, mComision, mSeguro;
								END IF;
							ELSE
								LET cMotivoDev = '02'; --LA CUENTA DE CREDITO NO ESTA ACTIVA
							END IF;
						ELSE
							LET cMotivoDev = '01'; --LA CUENTA DE CREDITO NO EXISTE
						END IF;
					ELSE
						--*
						IF (TRIM(NVL(cTipoCtaRec, '')) = '10') THEN -- VALIDAMOS TIPO CUENTA MOVIL
							-- EJECUTAMOS EL PROCEDIMIENTO NUEVO 
							EXECUTE PROCEDURE bdicheq:"informix".sp_tef_constelctacte (SUBSTR(cNumCtaRec, 11,10)) -- OBTENEMOS LA CUENTA DEL NUMERO MOVIL 
							INTO cCodRet, cNumCte, cCuenta, sCanal, cEsTransfer, cUserInsert, dtFechaHoraInsert;
		
							-- SI NO HAY CUENTA PARA EL  MOVIL, ASIGNAMOS MOTIVO DEVOLUCIÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂN.
							IF TRIM(cCuenta) = '' THEN	
								LET cMotivoDev = '01'; -- CUENTA INEXISTENTE.
							END IF;
							--*
						ELIF ( TRIM(cTipoCtaRec) = '40') THEN    --ES UNA NUEVA CLABE
							LET cCuenta = SUBSTR(cNumCtaRec,9,11);
						ELIF ( TRIM(cTipoCtaRec) = '03') THEN  --
							SELECT FIRST 1 NVL(Cuenta,''), status_tar INTO cCuenta, cStatus_tar FROM BdiCheq:"informix".Sc_Tarjeta WHERE Empresa = '001' AND Num_Tarjeta = SUBSTR(TRIM(cNumCtaRec),5,16);
						ELSE
							LET cMotivoDev = '06'; --CUENTA NO PERTENECE AL BANCO RECEPTOR
						END IF;
						
						IF (cStatus_tar = 'C') THEN
							LET cMotivoDev = '03';
						END IF;
						LET cStatus_tar = ' ';     
						
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
						
						--OBTIENE DATOS DE LA CUENTA
						SELECT FIRST 1 NVL(Status_Cta, ''), NVL(Producto, '') INTO cStatus_Cta, cProducto FROM BdiCheq:"informix".Sc_MaeChq WHERE Empresa = '001' AND Cuenta = cCuenta;
						
						IF (NOT EXISTS (SELECT Cve_Producto FROM BdiTef:"informix".Tef_Prod_Permitidos WHERE Cve_Producto = cProducto) ) THEN --VALIDA QUE SEA UN PRODUCTO PERMITIDO
							LET cMotivoDev = '06'; --CLIENTE NO TIENE AUTORIZADO EL SERVICIO
						ELIF (NVL(cStatus_Cta, '') = '') THEN --VALIDA KE EXISTA LA CUENTA
							LET cMotivoDev = '01'; --CUENTA INEXISTENTE
						ELIF (cStatus_Cta = '3') THEN --VALIDA KE  LA CUENTA NO ESTE BLOQUEADA
							LET cMotivoDev = '02';
						ELIF (cStatus_Cta = '2') THEN --VALIDA KE  LA CUENTA NO ESTE CANCELADA
							LET cMotivoDev = '03';
						ELIF (NOT EXISTS (SELECT Divisa FROM BdiCheq:"informix".Sc_Producto WHERE Empresa = '001' AND Producto = cProducto AND Divisa = '01')) THEN
							LET cMotivoDev = '05';
						END IF;
						
						IF ((cMotivoDev = '00') AND --VALIDA SI NO HA SIDO RECHAZADO POR ALGUN MOTIVO
						(EXISTS (SELECT Num_Secuencia
						FROM BdiTef:"informix".Tef_Cce_Detalle_Paso
						WHERE Nombre_Arch = cNombreArchivo AND Cod_operacion = '60'
						AND Banco_Presentador = cBancoPresentador
						AND Banco_Receptor = cBancoReceptor
						AND Importe = cImporte
						AND Fecha_Aplica = cFechaAplica
						AND Num_Cta_Ord = cNumCtaOrd
						AND Rfc_Ord = cRfcOrd
						AND Tipo_Cta_Rec = cTipoCtaRec
						AND nombre_ord = cNombreOrd
						AND Ref_Leyenda = cRefLeyenda
						AND Ref_Numerica = cRefNumerica
						AND num_cta_rec = cNumCtaRec
						AND clave_rastreo = cClaveRastreo
						AND Num_Secuencia::INTEGER < cNumSecuencia::INTEGER))) THEN --VALIDA KE NO SE REPITA EL REGISTRO
							LET cMotivoDev = '07';
						END IF;
						
						IF (cMotivoDev = '00') THEN --REGISTRO OK
							--APLICAR ABONO
							LET cNumeroFolioAbono = '';
							LET mSaldoAPagar = ((cImporte::INTEGER)/100);
							--OBTIENE FOLIO DEL ABONO
							EXECUTE PROCEDURE BdiCheq:"informix".Sp_GeneraFolioNomina(cUsuario) INTO cCodRet, cNumeroFolioAbono;
							LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
							IF (cCodRet <> '00000') THEN --ERROR AL OBTENER EL FOLIO DEL ABONO
							
								INSERT INTO Tef_Errores(fecha_error,hora_error,cod_error,Nombre_Arch,sp_llamado,mensaje_error,User_Insert,Fecha_Insert)
								VALUES (CURRENT,CURRENT HOUR TO FRACTION,NVL(cCodRet,''),NVL(cNombreArchivo,''),'Sp_GeneraFolioNomina','Error al obtener folio de abono',cUsuario,CURRENT);

								LET cCodRet = '02304';
							ELSE --OK
								--REALIZA EL ABONO
								EXECUTE PROCEDURE BdiCheq:"informix".Abono_Ref ("001", cSucursalContable, cUsuario,  cTransaccAbono, "0000", cNumeroFolioAbono, cCuenta,
								0, mSaldoAPagar, mSaldoAPagar, 0, 0, 0, "01",TRIM(cNumCtaOrd)||" "||TRIM(cRefLeyenda), '', cUsuario) INTO cCodRet;
							END IF;
						END IF;
					END IF;				
					LET cSolicitudConfirmacion = cSolicitudConfirmacion;
					IF ((cCodRet::INTEGER <> 0) OR (cMotivoDev <> '00')) THEN -- ERROR AL REALIZAR EL ABONO  / REGISTRO RECHAZADO 63
						--PASA A GENERACION ARCHIVO 63
						LET cMotivoDev = DECODE (cCodRet::INTEGER, 0, cMotivoDev, '06');
						LET cNombreArchivoAUX = '';
						LET cCveEstatus = '03';
						INSERT INTO Tef_Errores(fecha_error,hora_error,cod_error,Nombre_Arch,sp_llamado,mensaje_error,User_Insert,Fecha_Insert)
						VALUES (CURRENT,CURRENT HOUR TO FRACTION,NVL(cCodRet,''),NVL(cNombreArchivo,''),'Abono_Ref','Error al realizar abono a cuenta',cUsuario,CURRENT);
						
					ELIF (cCodRet::INTEGER = 0 AND cMotivoDev = '00')THEN --OK  62
						--GUARDA EL REGISTRO  CON  DE ABONO CORRECTO  EN EL ARCHIVO 62
						IF (cSolicitudConfirmacion = '1') THEN
							LET iContadorSecuencia62 = iContadorSecuencia62 + 1;
							LET iImporteTotalArchivo62 = iImporteTotalArchivo62 + NVL(cImporte,0)::INTEGER ;
							LET cMotivoDev = '00';
						END IF;
						LET cNombreArchivoAUX = cNomArchivo62;
						LET iContadorSecuenciaAUX = iContadorSecuencia62;
						LET cCveEstatus = '01';
					END IF;
					
					IF ((cCodRet::INTEGER = 0) AND (cSolicitudConfirmacion = '1'))THEN
						--INSERTA EL REGISTRO RECHAZADO EN EL ARCHIVO 62 o INSERTA EL REGISTRO 62 EN CASO DE CONFIRMACION
						INSERT INTO BdiTef:"informix".Tef_Cce_Detalle_Paso
						(	Nombre_Arch, Fecha_Presentacion, Tipo_Registro,Num_Secuencia,Cod_Operacion,Cod_Divisa,Fecha_Trans,Banco_Presentador,
							Banco_Receptor,Importe,Uso_Futuro_Ccen,Tipo_Operacion,Fecha_Aplica,Tipo_Cta_Ord,Num_Cta_Ord,Nombre_Ord,Rfc_Ord,
							Tipo_Cta_Rec,Num_Cta_Rec,Nombre_Rec,Rfc_Rec,Ref_Servicio,Nombre_Titular_Serv,Importe_Iva,Ref_Numerica,Ref_Leyenda,
							Clave_Rastreo,Motivo_Dev,Fecha_Pres_Ini,Solicitud_Confirmacion,Uso_Futuro_Banco,Ref_Confirmacion,Uso_Futuro_Cce,
							Tasa_Tiie_Prom,Dias_Retraso,Imp_Tot_Int,Cve_Status,Folio_Suc,User_Insert,Fecha_Insert
						)
						VALUES
						(
							NVL(cNombreArchivoAUX,''),
							NVL(cFechaPresentacionGen,''), -- cFechaPresentacionGen
							NVL(cTipoRegistro,''),
							NVL(LPAD(iContadorSecuenciaAUX,7,'0'),''),--NUM_SECUENCIA
							62, --CODIGO DE OPERACION / ARCHIVO
							NVL(cCodDivisa,''),
							NVL(cFechaTrans,''),
							NVL(cBancoReceptor,''),  --BANCO PRESENTADOR
							NVL(cBancoPresentador,''),  --BANCO RECEPTOR
							NVL(cImporte,''),
							NVL(cUsoFuturoCcen,''),
							NVL(cTipoOperacion,''),
							NVL(cFechaAplica,''),
							NVL(cTipoCtaOrd,''),
							NVL(cNumCtaOrd,''),
							NVL(cNombreOrd,''),
							NVL(cRfcOrd,''),
							NVL(cTipoCtaRec,''),
							NVL(cNumCtaRec,''),
							NVL(cNombreRec,''),
							NVL(cRfcRec,''),
							NVL(cRefServicio,''),
							NVL(cNombreTitularServ,''),
							NVL(cImporteIva,''),
							NVL(cRefNumerica,''),
							NVL(cRefLeyenda,''),
							NVL(cClaveRastreo,''),
							NVL(cMotivoDev,''), --MOTIVO DEVOLUCION
							NVL(cFechaPresIni,''),
							NVL(cSolicitudConfirmacion,''),
							NVL(cUsoFuturoBanco,''),
							NVL(DECODE (cNombreArchivoAUX, cNomArchivo62, (DECODE(cSolicitudConfirmacion,'1',cNumeroFolioAbono,cRefConfirmacion)), cRefConfirmacion),''),--REF_CONFIRMACION
							NVL(cUsoFuturoCce,''),
							NVL(cTasaTiieProm,''),
							NVL(cDiasRetraso,''),
							NVL(cImpTotInt,''),
							NVL(cCveEstatus,''),
							NVL(DECODE (cNombreArchivoAUX, cNomArchivo62, cNumeroFolioAbono, cFolioSuc),''), -- FOLIO_SUC
							cUsuario, --USUARIO_INSERT
							CURRENT::DATE --FECHA_INSERT
						);
					END IF;
					
					LET cDescripcionProceso = 'ACTUALIZA LA TABLA Tef_Cce_Detalle';
					LET cNomArchivo62 = cNomArchivo62;
					
					--dbs-02/07/2012 se cambia error por 03 para que se vaya por el archivo 63
					--ACTUALIZA EL REGISTRO DEL  ARCHIVO 60
					UPDATE BdiTef:"informix".Tef_Cce_Detalle
					SET Cve_Status = DECODE (cNombreArchivoAUX, cNomArchivo62, '01'/*OK*/, '03'/*ERROR*/),
					Folio_Suc = DECODE (cNombreArchivoAUX, cNomArchivo62, cNumeroFolioAbono, cFolioSuc),
					motivo_dev = cMotivoDev
					WHERE Nombre_Arch = cNombreArchivo
					AND Cod_operacion = '60'
					AND Banco_Presentador = cBancoPresentador
					AND Banco_Receptor = cBancoReceptor
					AND Importe = cImporte
					AND Fecha_Aplica = cFechaAplica
					AND Num_Cta_Ord = cNumCtaOrd
					AND Rfc_Ord = cRfcOrd
					AND Tipo_Cta_Rec = cTipoCtaRec
					AND Ref_Leyenda = cRefLeyenda
					AND Num_Secuencia = cNumSecuencia;
					
					--dbs-02/07/2012 se cambia error por 03 para que se vaya por el archivo 63
					--ACTUALIZA EL REGISTRO DEL  ARCHIVO 60 EN LA TABLA DE PASO
					UPDATE BdiTef:"informix".Tef_Cce_Detalle_Paso
					SET Cve_Status = DECODE (cNombreArchivoAUX, cNomArchivo62, '01'/*OK*/, '03'/*ERROR*/),
					Folio_Suc = DECODE (cNombreArchivoAUX, cNomArchivo62, cNumeroFolioAbono, cFolioSuc),
					motivo_dev = cMotivoDev
					WHERE Nombre_Arch = cNombreArchivo
					AND Cod_operacion = '60'
					AND Banco_Presentador = cBancoPresentador
					AND Banco_Receptor = cBancoReceptor
					AND Importe = cImporte
					AND Fecha_Aplica = cFechaAplica
					AND Num_Cta_Ord = cNumCtaOrd
					AND Rfc_Ord = cRfcOrd
					AND Tipo_Cta_Rec = cTipoCtaRec
					AND Ref_Leyenda = cRefLeyenda
					AND Num_Secuencia = cNumSecuencia;
					
					LET iContadorRegistros = iContadorRegistros + 1;
					
					--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
					COMMIT WORK;
					LET cFlagEnTransaccion = 'F';
					
				END FOREACH;
			END FOREACH;
			
			-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
			IF ((iContadorRegistros > 0) OR (cFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
				LET cFlagEnTransaccion = 'F';
			END IF;

			IF iNumArchivos > 0 THEN
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				--OBTIENE LOS DATOS DEL REGISTRO DE ENCABEZADO ORIGINAL 60
				SELECT FIRST 1 Cve_Banco, Servicio, Num_Bloque, Cod_Divisa, Cve_Rechazo_bl,
				Modalidad, Uso_Futuro_Ccen, Uso_Futuro_Banco
				INTO cCveBancoE, cServicioE, cNumBloqueE, cCodDivisaE, cCveRechazoblE,
				cModalidadE, cUsoFuturoCcenE, cUsoFuturoBancoE
				FROM BdiTef:"informix".Tef_Cce_Encabezado --ES TOMADO DEL HISTORICO
				WHERE Nombre_Arch = cNombreArchivo AND Cod_operacion = '60';
				
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				--OBTIENE LOS DATOS DEL REGISTRO DE SUMARIO ORIGINAL 60
				SELECT FIRST 1 Num_Bloque, Uso_Futuro_ccen, Uso_Futuro_banco
				INTO cNumBloqueS, cUsoFuturoCcenS, cUsoFuturoBancoS
				FROM BdiTef:"informix".Tef_Cce_Sumario --ES TOMADO DEL HISTORICO
				WHERE Nombre_Arch = cNombreArchivo AND Cod_operacion = '60';
				
				IF (iContadorSecuencia62 > 1) THEN --VALIDA SI EXISTEN REGISTROS PARA EL ARCHIVO 62
					--FORMA EL REGISTRO DE ENCABEZADO
					--ENCABEZADO
					INSERT INTO BdiTef:"informix".Tef_Cce_Encabezado_Paso
					(
						Nombre_Arch,
						Fecha_Presentacion,
						Tpo_Registro,
						Num_Secuencia,
						Cod_Operacion,
						Cve_Banco,
						Sentido,
						Servicio,
						Num_Bloque,
						Cod_Divisa,
						Cve_Rechazo_bl,
						Modalidad,
						Uso_Futuro_Ccen,
						Uso_Futuro_Banco,
						User_Insert,
						Fecha_Insert
					)
					VALUES
					(
						NVL(cNomArchivo62,'') ,
						NVL(cFechaPresentacionGen,''),
						'01', --TIPO REGISTRO
						NVL(LPAD('1',7,'0'),''), --'0000001', --SECUENCIA
						'62', --ARCHIVO
						NVL(cCveBancoE,''), --BANCOPEL 137
						'E', --SENTIDO
						NVL(cServicioE,''), --SERVICIO
						NVL(SUBSTR(cFechaPresentacionGen, 7, 2) || LPAD((SUBSTR(cNomArchivo62,(LENGTH(TRIM(cNomArchivo62)) - 1), 2)),5,'0'),''), --NUM BLOQUE
						NVL(cCodDivisaE,''), --DIVISA
						NVL(cCveRechazoblE,''),--CVE_RECHAZO_BL
						NVL(cModalidadE,''),--MODALIDAD
						NVL(cUsoFuturoCcenE,''), --USO_FUTURO_CCEN
						NVL(cUsoFuturoBancoE,''),--USO_FUTURO_BANCO
						cUsuario,
						CURRENT::DATE
					);
					
					--FORMA EL REGISTRO DE SUMARIO
					--SUMARIO
					INSERT INTO BdiTef:"informix".Tef_Cce_Sumario_Paso
					(
						Nombre_Arch,
						Fecha_Presentacion,
						Tipo_Registro,
						Num_Secuencia,
						Cod_Operacion,
						Num_Bloque,
						Num_Operaciones,
						Imp_Operaciones,
						Uso_Futuro_ccen,
						Uso_Futuro_banco,
						User_Insert,
						Fecha_Insert
					)
					VALUES
					(
						NVL(cNomArchivo62,''), --NOMBRE_ARCH
						NVL(cFechaPresentacionGen,''), --FECHA_PRESENTACION
						'09', --TIPO_REGISTRO
						NVL(LPAD((iContadorSecuencia62+1),7,'0'),''), --SECUENCIA
						'62', --COD_OPERACION
						NVL(SUBSTR(cFechaPresentacionGen, 7, 2) || LPAD((SUBSTR(cNomArchivo62,(LENGTH(TRIM(cNomArchivo62)) - 1), 2)),5,'0'),''), --NUM BLOQUE
						NVL(LPAD((iContadorSecuencia62-1),7,'0'),''),--NUM_OPERACIONES -- REGISTROS EN EL DETALLE
						NVL(LPAD(iImporteTotalArchivo62,18,'0'),''),--IMPORTE TOTAL DE OPERACIONES
						NVL(cUsoFuturoCcenS,''),--USO_FUTURO_CCEN
						NVL(cUsoFuturoBancoS,''),--USO_FUTURO_BANCO
						cUsuario, --USUARIO_INSERT
						CURRENT::DATE --FECHA_INSERT
					);
				END IF;
				
				LET cCodRet = '00000';
				LET cDescripcionProceso = 'CREAR EL ARCHIVO 62.';
			
				IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_cce_Encabezado_Paso WHERE nombre_arch = TRIM(cNomArchivo62))THEN 
					IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Detalle_Paso WHERE nombre_arch = TRIM(cNomArchivo62))THEN
						IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Sumario_Paso WHERE nombre_arch = TRIM(cNomArchivo62))THEN
							LET cFlagArch62 = 'V';
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							SELECT LIMIT 1 Fecha_Presentacion INTO cFechaPresentacion FROM BdiTef:"informix".Tef_cce_Encabezado_Paso WHERE Nombre_Arch = TRIM(cNomArchivo62) ;
							EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GeneraArchivo (62, TRIM (cNomArchivo62), cFechaPresentacion, '72'/*RUTA ARCHIVO RESPUESTA*/ ) INTO cCodRet;
						END IF;
					END IF;
				END IF;
				
				LET cDescripcionProceso = 'Mover Registros Procesados a la Tabla de Historico.';
				IF (cCodRet = '00000') THEN -- VALIDA QUE EL ARCHIVO SE HA GENERADO CORRECTAMENTE
					IF (cFlagArch62 = 'V') THEN 
						EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GuardarCCEArchivos (cUsuario, TRIM (cNomArchivo62), cFechaPresentacion, '01') INTO cCodRet;
						
						IF (cCodRet = '00000') THEN --VALIDA KE SE GUARDO CORRECTAMENTE EL REGISTRO EN CCE_ARCHIVO
							LET cDescripcionProceso = 'VALIDA KE SE GUARDO CORRECTAMENTE EL REGISTRO EN CCE_ARCHIVO';
							EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist (TRIM (cNomArchivo62), cFechaPresentacion, 'T', '') INTO cCodRet;
						ELSE --ERROR
						END IF;
					END IF;
					IF (cCodRet = '00000') THEN --VALIDA QUE EL REGISTRO SE PASO ADECUADAMENTE AL HISTORICO
						--BORRAR DEL HISTORICO EL REGISTRO DEL ARCHIVO
						LET cDescripcionProceso = 'BORRAR DEL HISTORICO EL REGISTRO DEL ARCHIVO';
						EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist(TRIM(cNombreArchivo), '', 'B', '') INTO cCodRet;
					END IF;
				ELSE 
				END IF;
			ELSE 
				--NO SE ENCONTRARON REGISTROS POR PROCESAR
				LET cCodRet = '00325';
			END IF --IF DE ARCHIVOS PROCESADOS		
		ELSE
			--NO SE ENCONTRARON REGISTROS EN TABLAS DE DETALLE
			LET cCodRet = '02305';
		END IF;
	END IF; --	IF DE SUCURSAL
	
	IF (cCodRet = '00000') THEN
		LET cDescripcionProceso = 'TEF Finalizado Exitosamente.';
		EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE,'RECARCH_' || 62 || '.' || SUBSTRING (TRIM(cNombreArchivo) FROM 15 FOR 2), cDescripcionProceso,cFINALIZADO, cCodRet, cUsuario, 'sp_tef_generararchivo62.sql', TRIM(cNomArchivo62) , cFechaPresentacion, '02'/*EXITO*/ ) INTO cCodRet;
	ELSE 
		EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, 'RECARCH_' || 62 || '.' || SUBSTRING (TRIM(cNombreArchivo) FROM 15 FOR 2), cDescripcionProceso,cERROR, cCodRet, cUsuario, 'sp_tef_generararchivo62.sql', TRIM(cNomArchivo62) , cFechaPresentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO cCodRet;
	END IF
	RETURN cCodRet;

END
END PROCEDURE
DOCUMENT
'Autor: Victor Hugo NuÃÂÃÂ±ez',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Javier Vazquez',
'Descripcion: Procesa los abonos y generacion del archivo 62',
'Fecha: 02/05/2012',
'Version: 20120502.0913',
'BD: BdiTef',
'Modifico: Victor Hugo NuÃÂÃÂ±ez',
'Modificacion: Se modifica para que valida que el archivo 61 no haya sido generado anteriormente y no lo mueva al hstorico nuevamente',
'Solicito: Javier Vazquez',
'Fecha: 01/06/2012',
'Version: 20120601.1900',
'BD: BdiTef',
'Modifico: Victor Hugo NuÃÂÃÂ±ez',
'Modificacion: Se elimina generacion del archivo 61 se pasa el estado a 03 para generacion de archivo 63 en caso de error',
'Solicito: Javier Vazquez',
'Fecha: 02/07/2012',
'Version: 20120702.1900',
'BD: BdiTef',
'',
'Modificado: Francisco Eduardo Benitez Baez',
'Proyecto: NÃÂÃÂºmero mÃÂÃÂ³vil en transferencias TEF',
'Solicito: MartÃÂÃÂ­n Pineda',
'Descripcion: Se agrega nuevo procedimiento de busqueda de telefono',
'		y se valida en caso de que no haya despliega mensaje', 
'Fecha: 24/09/2014',
'Version: 20140924.0937',
'AUTOR : Viridiana PR',
'DESCRIPCION: se concateno el valor de la cuenta origen con la 	referencia leyenda',
'FECHA : MAYO 2015',
'VERSION: 20150528',
'BD    : bditef',
'Modificado: Francisco Eduardo Benitez Baez',
'Proyecto: RQI 64 125 - Mantenimiento Generacion Archivo 62 TEF',
'Modifico: Jose Angel Lopez Adams',
'Descripcion: Se agrega registro en la tabla tef_errores en caso de que la respuesta del SP abono_ref no sea exitosa',
'Fecha: 06/11/2015',
'********************************************************************************************************************',
'Proyecto: RQI 64 157 - Mantenimiento generacion 62 TEF',
'Descripcion: Se modifica validacion para que el proceso no se ejecute en dias inhabiles segun respuesta del SP sp_Valfecha_Banca',
'Fecha: 31/03/2016',
'********************************************************************************************************************',
'MODIFICACION',
'MODIFICO: Trinidad HernÃÂÃÂ¡ndez',
'folio: 73',
'DESCRIPCION: "HomologaciÃÂÃÂ³n de caja appriza con RQM 10-239-5 Y RQM 10-495 y cambio BTS_parametro sucursal"; HomologaciÃÂÃÂ³n con Vers. Prod., Pago de remesas Appriza',
'FECHA : 22/06/2016',
'VERSION: 20160622.1019',
'BD    : BdiTef';

CREATE PROCEDURE "informix".sp_obtenerchequescce_pba3(pEmpresa CHAR(3),pBanco CHAR(3),pNumCta CHAR(20), pNumChq CHAR(7),pFormato CHAR(3), pFechaAlta DATE)
            RETURNING 
			CHAR(5),		-- CODIGO RETORNO
            CHAR(3),        -- BANCO
            CHAR(40),       -- DESCRIPCION BANCO           
			CHAR(20),		-- CUENTA
			CHAR(7),		-- NUMERO CHEQUE
			CHAR(1),   		-- LADO
			DATE,  		    -- FECHA ALTA
			DATE,			--FECHA PRESENTA
			CHAR(8);		--USUARIO ALTA
			
DEFINE iSqlErr       	INT;
DEFINE cCodret       	CHAR(5);  
DEFINE cBanco		 	CHAR(3);
DEFINE cDescripcion		CHAR(40);
DEFINE cNumcta		 	CHAR(20);
DEFINE cNumchq		 	CHAR(7);
DEFINE cLado 		 	CHAR(1);
DEFINE dFechaAlta	 	DATE;
DEFINE dFechaPresenta	DATE;
DEFINE cUsuarioAlta		CHAR(8);

LET cCodret			= '00000';  
LET cBanco			= '';
LET cDescripcion	= '';
LET cNumcta			= '';
LET cNumchq			= '';
LET cLado 			= '';
LET dFechaAlta		= '';
LET dFechaPresenta	= '';
LET cUsuarioAlta	= '';
LET iSqlErr         = 0;


BEGIN
   ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
            RETURN cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta;   
        END IF;
   END EXCEPTION;

--	SET DEBUG FILE TO "/tmp/sp_ConsultarChequesDevueltos.out";
--	TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF pFechaAlta IS NULL OR pFechaAlta = '' THEN

	
		FOREACH

			--OBTIENE CHEQUES ORDENADOS POR BANCO Y NUMERO DE CHEQUE
			SELECT {+MULTI_INDEX(bditef:cce_cheques_img)}
				a.cvebanco,b.descripcion,a.numcuenta,a.numcheque,a.lado_ft,a.fecha_alta,a.fechapresenta,a.usuario_alta 
				INTO cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta
				FROM bditef:cce_cheques_img a, bdinteg:si_bancos b 
				WHERE empresa = pEmpresa
				AND a.cvebanco = b.banco
				AND a.cvebanco = CASE WHEN pBanco = '' THEN a.cvebanco ELSE pBanco END  
				AND a.numcuenta = CASE WHEN pNumCta = '' THEN a.numcuenta ELSE pNumCta END  
				AND a.numcheque = CASE WHEN pNumChq = '' THEN a.numcheque ELSE pNumChq END  
				AND a.imagen_formato = CASE WHEN pFormato = '' THEN a.imagen_formato ELSE pFormato END 
				ORDER BY a.cvebanco ASC, a.numcheque::INTEGER ASC, a.fecha_alta ASC 	
				
			RETURN  cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta WITH RESUME;
		
		END FOREACH

	ELSE 

		FOREACH

			--OBTIENE CHEQUES ORDENADOS POR BANCO Y NUMERO DE CHEQUE

			SELECT {+INDEX(bditef:cce_cheques_img idx_cce_cheques_img2)}
				a.cvebanco,b.descripcion,a.numcuenta,a.numcheque,a.lado_ft,a.fecha_alta,a.fechapresenta,a.usuario_alta 
				INTO cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta
				FROM bditef:cce_cheques_img a, bdinteg:si_bancos b 
				WHERE empresa = pEmpresa
				AND a.cvebanco = b.banco
				AND a.cvebanco = CASE WHEN pBanco = '' THEN a.cvebanco ELSE pBanco END  
				AND a.numcuenta = CASE WHEN pNumCta = '' THEN a.numcuenta ELSE pNumCta END  
				AND a.numcheque = CASE WHEN pNumChq = '' THEN a.numcheque ELSE pNumChq END  
				AND a.imagen_formato = CASE WHEN pFormato = '' THEN a.imagen_formato ELSE pFormato END 
				AND a.fecha_alta = pFechaAlta 
				ORDER BY a.cvebanco ASC, a.numcheque::INTEGER ASC	
				
			RETURN  cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta WITH RESUME;
		
		END FOREACH
	END IF;
END;    
END PROCEDURE
DOCUMENT
'AUTOR:ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION:  PROCEDIMIENTO QUE OBTIENE LOS PARAMETROS PARA SISTEMA TEF ',
'FECHA : MARZO 2010',
'BD    : BDITEF',
'VERSION: 20100305.0831';

CREATE PROCEDURE "informix".sp_obtenerchequescce_pbas2(pEmpresa CHAR(3),pBanco CHAR(3),pNumCta CHAR(20), pNumChq CHAR(7),pFormato CHAR(3), pFechaAlta DATE)
            RETURNING 
			CHAR(5),		-- CODIGO RETORNO
            CHAR(3),        -- BANCO
            CHAR(40),       -- DESCRIPCION BANCO           
			CHAR(20),		-- CUENTA
			CHAR(7),		-- NUMERO CHEQUE
			CHAR(1),   		-- LADO
			DATE,  		    -- FECHA ALTA
			DATE,			--FECHA PRESENTA
			CHAR(8);		--USUARIO ALTA
			
DEFINE iSqlErr       	INT;
DEFINE cCodret       	CHAR(5);  
DEFINE cBanco		 	CHAR(3);
DEFINE cDescripcion		CHAR(40);
DEFINE cNumcta		 	CHAR(20);
DEFINE cNumchq		 	CHAR(7);
DEFINE cLado 		 	CHAR(1);
DEFINE dFechaAlta	 	DATE;
DEFINE dFechaPresenta	DATE;
DEFINE cUsuarioAlta		CHAR(8);

LET cCodret			= '00000';  
LET cBanco			= '';
LET cDescripcion	= '';
LET cNumcta			= '';
LET cNumchq			= '';
LET cLado 			= '';
LET dFechaAlta		= '';
LET dFechaPresenta	= '';
LET cUsuarioAlta	= '';
LET iSqlErr         = 0;


BEGIN
   ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
            RETURN cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta;   
        END IF;
   END EXCEPTION;

--	SET DEBUG FILE TO "/tmp/sp_ConsultarChequesDevueltos.out";
--	TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF pFechaAlta IS NULL OR pFechaAlta = '' THEN

	
		FOREACH

			--OBTIENE CHEQUES ORDENADOS POR BANCO Y NUMERO DE CHEQUE
			SELECT -- {+INDEX(bditef:cce_cheques_img idx_cce_cheques_img)}
				a.cvebanco,b.descripcion,a.numcuenta,a.numcheque,a.lado_ft,a.fecha_alta,a.fechapresenta,a.usuario_alta 
				INTO cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta
				FROM bditef:cce_cheques_img a, bdinteg:si_bancos b 
				WHERE empresa = pEmpresa
				AND a.cvebanco = b.banco
				AND a.cvebanco = CASE WHEN pBanco = '' THEN a.cvebanco ELSE pBanco END  
				AND a.numcuenta = CASE WHEN pNumCta = '' THEN a.numcuenta ELSE pNumCta END  
				AND a.numcheque = CASE WHEN pNumChq = '' THEN a.numcheque ELSE pNumChq END  
				AND a.imagen_formato = CASE WHEN pFormato = '' THEN a.imagen_formato ELSE pFormato END 
				ORDER BY a.cvebanco ASC, a.numcheque::INTEGER ASC, a.fecha_alta ASC 	

			RETURN  cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta WITH RESUME;
		
		END FOREACH

	ELSE 

		FOREACH

			--OBTIENE CHEQUES ORDENADOS POR BANCO Y NUMERO DE CHEQUE

			SELECT -- {+INDEX(bditef:cce_cheques_img idx_cce_cheques_img)}
				a.cvebanco,b.descripcion,a.numcuenta,a.numcheque,a.lado_ft,a.fecha_alta,a.fechapresenta,a.usuario_alta 
				INTO cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta
				FROM bditef:cce_cheques_img a, bdinteg:si_bancos b 
				WHERE empresa = pEmpresa
				AND a.cvebanco = b.banco
				AND a.cvebanco = CASE WHEN pBanco = '' THEN a.cvebanco ELSE pBanco END  
				AND a.numcuenta = CASE WHEN pNumCta = '' THEN a.numcuenta ELSE pNumCta END  
				AND a.numcheque = CASE WHEN pNumChq = '' THEN a.numcheque ELSE pNumChq END  
				AND a.imagen_formato = CASE WHEN pFormato = '' THEN a.imagen_formato ELSE pFormato END 
				AND a.fecha_alta = pFechaAlta 
				ORDER BY a.cvebanco ASC, a.numcheque::INTEGER ASC	
				
			RETURN  cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta WITH RESUME;
		
		END FOREACH
	END IF;
END;    
END PROCEDURE
DOCUMENT
'AUTOR:ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION:  PROCEDIMIENTO QUE OBTIENE LOS PARAMETROS PARA SISTEMA TEF ',
'FECHA : MARZO 2010',
'BD    : BDITEF',
'VERSION: 20100305.0831';

CREATE PROCEDURE "informix".sp_obtenerchequescce(pEmpresa CHAR(3),pBanco CHAR(3),pNumCta CHAR(20), pNumChq CHAR(7),pFormato CHAR(3), pFechaAlta DATE)
            RETURNING 
			CHAR(5),		-- CODIGO RETORNO
            CHAR(3),        -- BANCO
            CHAR(40),       -- DESCRIPCION BANCO           
			CHAR(20),		-- CUENTA
			CHAR(7),		-- NUMERO CHEQUE
			CHAR(1),   		-- LADO
			DATE,  		    -- FECHA ALTA
			DATE,			--FECHA PRESENTA
			CHAR(8);		--USUARIO ALTA
			
DEFINE iSqlErr       	INT;
DEFINE cCodret       	CHAR(5);  
DEFINE cBanco		 	CHAR(3);
DEFINE cDescripcion		CHAR(40);
DEFINE cNumcta		 	CHAR(20);
DEFINE cNumchq		 	CHAR(7);
DEFINE cLado 		 	CHAR(1);
DEFINE dFechaAlta	 	DATE;
DEFINE dFechaPresenta	DATE;
DEFINE cUsuarioAlta		CHAR(8);

LET cCodret			= '00000';  
LET cBanco			= '';
LET cDescripcion	= '';
LET cNumcta			= '';
LET cNumchq			= '';
LET cLado 			= '';
LET dFechaAlta		= '';
LET dFechaPresenta	= '';
LET cUsuarioAlta	= '';
LET iSqlErr         = 0;


BEGIN
   ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
            RETURN cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta;   
        END IF;
   END EXCEPTION;

--	SET DEBUG FILE TO "/tmp/sp_ConsultarChequesDevueltos.out";
--	TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF pFechaAlta IS NULL OR pFechaAlta = '' THEN

	
		FOREACH

			--OBTIENE CHEQUES ORDENADOS POR BANCO Y NUMERO DE CHEQUE
			SELECT --{+INDEX(bditef:cce_cheques_img idx_cce_cheques_img)}
				a.cvebanco,b.descripcion,a.numcuenta,a.numcheque,a.lado_ft,a.fecha_alta,a.fechapresenta,a.usuario_alta 
				INTO cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta
				FROM bditef:cce_cheques_img a, bdinteg:si_bancos b 
				WHERE empresa = pEmpresa
				AND a.cvebanco = b.banco
				AND a.cvebanco = CASE WHEN pBanco = '' THEN a.cvebanco ELSE pBanco END  
				AND a.numcuenta = CASE WHEN pNumCta = '' THEN a.numcuenta ELSE pNumCta END  
				AND a.numcheque = CASE WHEN pNumChq = '' THEN a.numcheque ELSE pNumChq END  
				AND a.imagen_formato = CASE WHEN pFormato = '' THEN a.imagen_formato ELSE pFormato END 
				ORDER BY a.cvebanco ASC, a.numcheque::INTEGER ASC, a.fecha_alta ASC 	

			RETURN  cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta WITH RESUME;
		
		END FOREACH

	ELSE 

		FOREACH

			--OBTIENE CHEQUES ORDENADOS POR BANCO Y NUMERO DE CHEQUE

			SELECT -- {+INDEX(bditef:cce_cheques_img idx_cce_cheques_img)}
				a.cvebanco,b.descripcion,a.numcuenta,a.numcheque,a.lado_ft,a.fecha_alta,a.fechapresenta,a.usuario_alta 
				INTO cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta
				FROM bditef:cce_cheques_img a, bdinteg:si_bancos b 
				WHERE empresa = pEmpresa
				AND a.cvebanco = b.banco
				AND a.cvebanco = CASE WHEN pBanco = '' THEN a.cvebanco ELSE pBanco END  
				AND a.numcuenta = CASE WHEN pNumCta = '' THEN a.numcuenta ELSE pNumCta END  
				AND a.numcheque = CASE WHEN pNumChq = '' THEN a.numcheque ELSE pNumChq END  
				AND a.imagen_formato = CASE WHEN pFormato = '' THEN a.imagen_formato ELSE pFormato END 
				AND a.fecha_alta = pFechaAlta 
				ORDER BY a.cvebanco ASC, a.numcheque::INTEGER ASC	
				
			RETURN  cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta WITH RESUME;
		
		END FOREACH
	END IF;
END;    
END PROCEDURE
DOCUMENT
'AUTOR:ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION:  PROCEDIMIENTO QUE OBTIENE LOS PARAMETROS PARA SISTEMA TEF ',
'FECHA : MARZO 2010',
'BD    : BDITEF',
'VERSION: 20100305.0831';

create procedure "informix".cons_img_nula(pempresa       char(3),
                                          pcvebanco   	 char(3),
                                          pnumcuenta   	 char(20),
                                          pnumcheque   	 char(7),
                                          plado_ft       char(1),
                                          pfechapresenta char(10))
RETURNING char(5);  

    DEFINE v_codret char(5);
    DEFINE sql_err,isam_err int;   
    --DEFINE v_existe char(1);
	DEFINE iimagen  int;

    -- // Inicializa variables
    LET v_codret    = "000";
    --LET v_existe    = "0";
	LET iimagen     = "0";
    
    -- // Valida la informacion de entrada
    IF pempresa    	  is null or
       pcvebanco      is null or
       pnumcuenta     is null or
       pnumcheque     is null or
       plado_ft       is null or
       pfechapresenta is null THEN
        LET v_codret = 110; -- // datos de entrada incompletos
        RETURN v_codret; 
    END IF;
    
    BEGIN

		on exception set sql_err,isam_err
			if sql_err <> 0 or isam_err <> 0 then
				let v_codret = sql_err;
				return v_codret;
			end if;
		end exception;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	

		select length(imagen::lvarchar) 
		INTO iimagen
		from "informix".cce_cheques_img
		 where empresa = pempresa
		   and cvebanco = pcvebanco
		   and numcuenta = pnumcuenta
		   and numcheque = pnumcheque
		   and lado_ft = plado_ft
		   and fechapresenta = pfechapresenta;

        IF iimagen is null or iimagen = '' THEN
            LET v_codret = 130; 
            RETURN v_codret;                 
        END IF;
    
    END;    

    RETURN v_codret;

END PROCEDURE;