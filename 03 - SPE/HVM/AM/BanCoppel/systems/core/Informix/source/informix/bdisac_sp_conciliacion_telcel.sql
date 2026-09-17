CREATE PROCEDURE "informix".sp_conciliacion_telcel(pFecha_Proceso DATE DEFAULT NULL)
RETURNING CHAR(5) AS cCodRet, 
		  CHAR(100) AS cMensajeRet;
	
	
	--Variables de retorno
	DEFINE cCodRet 						CHAR(5);
	DEFINE cMensajeRet					CHAR(100);
	--Variables de control de excepciones
	DEFINE iSqlErr						INTEGER;
	DEFINE iIsamErr				 		INTEGER;
	DEFINE cInfoErr						CHAR(100);
	--Variables generales		
	DEFINE dFecha_Ant					DATE;
	DEFINE cEmpresa						CHAR(3);
	DEFINE cUsuario						CHAR(10);
	DEFINE mTotalTelcel 				MONEY(18,2);
	DEFINE mTotalTapi					MONEY(18,2);
	--Variables para transferencia spei
    DEFINE cSucursalSPEI 				CHAR(4);
    DEFINE cFolioSucursalSPEI 			CHAR(16);
    DEFINE iBancoDestinoSPEI 			INTEGER;
    DEFINE dFechaCapturaSPEI 			DATE;
    DEFINE iTipoPagoSPEI 				INTEGER;
    DEFINE iTipoOperacionSPEI 			INTEGER;
    DEFINE cNombreOrdenSPEI 			CHAR(40);
    DEFINE cCuentaOrdenSPEI 			CHAR(20);
	DEFINE cCuentaOrden 				CHAR(20);
    DEFINE cRFCOrdenSPEI 				CHAR(18);
    DEFINE cNombreBeneficiarioSPEI 		CHAR(40);
    DEFINE cCuentaBeneficiarioSPEI 		CHAR(20);
    DEFINE cRFCBeneficiarioSPEI 		CHAR(18);
    DEFINE mImporteIVASPEI 				MONEY(18,2);
    DEFINE dReferenciaNumero 			DECIMAL(7,0);
    DEFINE cReferenciaCobranza1SPEI 	CHAR(40);
    DEFINE cConceptoPagoSPEI 			CHAR(210);
    DEFINE cClavePagoSPEI 				CHAR(10);
    DEFINE cNombreBeneficiario2SPEI 	CHAR(40);
    DEFINE cCuentaBeneficiario2SPEI 	CHAR(20);
    DEFINE cRFCBeneficiario2SPEI 		CHAR(18);
    DEFINE cTransaccionSPEI 			CHAR(4);
    DEFINE iTipoCuentaOrdenSPEI 		INTEGER;
    DEFINE iTipoCuentaBeneficiarioSPEI 	INTEGER;
    DEFINE iSerialFolioSPEI 			INTEGER;
    DEFINE cCodRetSp 					CHAR(5);
    DEFINE cMensajeError 				CHAR(100);
    DEFINE cCveRastreo 					CHAR(30);
	DEFINE cNumCte						CHAR(15);
	--Variables para procesamiento de archivo
	DEFINE cRutaArchivo					CHAR(50);
	DEFINE cNombreArchivo				CHAR(35);
	DEFINE cSystem						CHAR(500);
	DEFINE cSQL							CHAR(500);
	DEFINE cResultado					INT;
	--Variables para el retorno de Cargo_ref
	DEFINE cCodRetCgo					CHAR(5);	
	DEFINE cTrxCgo                      CHAR(4);
	DEFINE dFechaCgo  					DATE;
	DEFINE mSdoDispCgo					MONEY(14,2);
	DEFINE mMontoCgo  					MONEY(14,2);
	DEFINE rCodRet						CHAR(5);	       --- Codigo de retorno reverso
	DEFINE cResultadoShell 				CHAR(20);
	
	--SET DEBUG FILE TO '/home/e10000161/sp_conciliacion_tae_tapi.out';
	--TRACE ON;

	--Variables de retorno
	LET cCodRet 						= '00000';
	LET cMensajeRet                     = 'Proceso finalizado con exito';
	--Variables de control de excepciones
	LET iSqlErr							= 0;
	LET iIsamErr					    = 0;
	LET cInfoErr					    = '';
	--Variables generales
	LET dFecha_Ant						= TODAY;
	LET cEmpresa						= '001';
	LET cUsuario						= 'informix';
	LET mTotalTelcel 					= 0.00;
	LET mTotalTapi	 					= 0.00;
	--Variables para transferencia spei
	LET cSucursalSPEI 					= '5011';
	LET iBancoDestinoSPEI 				= 40012;
	LET dFechaCapturaSPEI 				= TODAY;
	LET iTipoPagoSPEI 					= 1;
	LET iTipoOperacionSPEI 				= 0;
	LET mImporteIVASPEI 				= 0.0;
	LET dReferenciaNumero 				= 0;
	LET cReferenciaCobranza1SPEI 		= '';
	LET cClavePagoSPEI 					= '';
	LET cNombreBeneficiario2SPEI 		= '';
	LET cCuentaBeneficiario2SPEI 		= '';
	LET cRFCBeneficiario2SPEI 			= '';
	LET iTipoCuentaOrdenSPEI 			= 40;
	LET iTipoCuentaBeneficiarioSPEI 	= 40;
    LET cFolioSucursalSPEI 		        = '';
    LET cNombreOrdenSPEI 		        = '';
    LET cCuentaOrdenSPEI 		        = '';
	LET cCuentaOrden 			        = '';
    LET cRFCOrdenSPEI 			        = '';
    LET cNombreBeneficiarioSPEI         = '';
    LET cCuentaBeneficiarioSPEI         = '';
    LET cRFCBeneficiarioSPEI            = '';
    LET cConceptoPagoSPEI               = '';
    LET cTransaccionSPEI                = '';
    LET iSerialFolioSPEI                = 0 ;
    LET cCodRetSp                       = '';
    LET cMensajeError 					= '';
    LET cCveRastreo 					= '';
	LET cNumCte							= '';
	--Variables para procesamiento de archivo
	LET cRutaArchivo					= '';
	LET cNombreArchivo 					= '';
	LET cSystem							= '';
	LET cSQL							= '';
	LET cResultado						= 0;
	--Variables para el retorno de Cargo_ref
	LET cCodRetCgo						= '000';
	LET cTrxCgo                         = '';
	LET dFechaCgo                       = TODAY;
	LET mSdoDispCgo                     = 0.00;
	LET mMontoCgo                       = 0.00;
	LET rCodRet			='';                    --- Codigo de retorno reverso
	let cResultadoShell 				= '';

	BEGIN
		--Manejo de excepciones
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
				IF iSqlErr <> 0 THEN
					LET cCodRet = iSqlErr;
					
					EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_conciliacion_telcel");
					RETURN cCodRet,cInfoErr;
				END IF;
		END EXCEPTION;
		
		IF pFecha_Proceso IS NOT NULL THEN
			LET dFecha_Ant = pFecha_Proceso;
		ELSE
			SELECT fecha_ant INTO dFecha_Ant
			FROM "informix".sac_fechas
			WHERE empresa = cEmpresa;
		END IF;
		
		--Validamos que la fecha este disponible.
		IF ( dFecha_Ant == "" OR dFecha_Ant IS NULL ) THEN
            LET cCodRet = "00001";
            LET cMensajeRet = 'La fecha no se encuentra disponible';
            RETURN cCodRet, cMensajeRet;
        END IF;
		
		--Realizamos la consulta del parametro que contiene 
		SELECT  {+INDEX(sc_param idx_param1 )} valor 
		INTO cRutaArchivo
		FROM bdisac:sac_param
		WHERE empresa = cEmpresa
		AND cod_param = 165;
		
		--Armado del nombre del archivo.
		
		let cNombreArchivo = 'TLC' || TO_CHAR(dFecha_Ant, '%y%m%d') || '.txt';
		
		IF (SELECT COUNT(*) FROM bdisac:sac_proceso_conciliacion_telcel WHERE nombre_archivo = cNombreArchivo and clave_rastreo <> '' and estatus = '1') > 0 THEN
			LET cCodRet = "00002";
            LET cMensajeRet = 'El archivo ya fue procesado el dia de hoy';
            RETURN cCodRet, cMensajeRet;		
		END IF;
		
		LET cSQL = ' sh '||(TRIM(cRutaArchivo))||'conciliacion_telcel.sh'||' '||TO_CHAR(dFecha_Ant, '%y%m%d')||' '||cRutaArchivo;
		SYSTEM cSQL;
		
		
        select FIRST 1 monto_tot_telcel 
        INTO mTotalTelcel
        from bdisac:"informix".sac_proceso_conciliacion_telcel
        where nombre_archivo = cNombreArchivo and clave_rastreo = '' and estatus = '0';
        
		--Consulta y asignacion de valores para realizar el cargo y el envio del SPEI de TELCEL.
		SELECT {+INDEX(sc_param idx_param1 )} valor INTO cCuentaOrden FROM bdisac:sac_param WHERE cod_param = 169;
		SELECT num_cte,cuenta_clabe INTO cNumCte,cCuentaOrdenSPEI FROM bdicheq:sc_maechq WHERE cuenta = cCuentaOrden;
		SELECT razon_social,rfc INTO cNombreOrdenSPEI,cRFCOrdenSPEI FROM bdinteg:si_cliente WHERE numcte = cNumCte;
		SELECT {+INDEX(sc_param idx_param1 )} valor INTO cNombreBeneficiarioSPEI FROM bdisac:sac_param WHERE cod_param = 158;
		SELECT {+INDEX(sc_param idx_param1 )} valor INTO cCuentaBeneficiarioSPEI FROM bdisac:sac_param WHERE cod_param = 160;
		SELECT {+INDEX(sc_param idx_param1 )} valor INTO cRFCBeneficiarioSPEI FROM bdisac:sac_param WHERE cod_param = 162;
		SELECT {+INDEX(sc_param idx_param1 )} valor INTO cConceptoPagoSPEI FROM bdisac:sac_param WHERE cod_param = 163;
		SELECT vchrvalor INTO cTransaccionSPEI FROM bdispei:tblparametros WHERE vchrcveparametro = 'TRANSACC_CARGO';
						
		EXECUTE PROCEDURE bdispei:sp_obtfoliosuc(cUsuario) INTO cCodRetSp, iSerialFolioSPEI, cFolioSucursalSPEI;
		
		IF cCodRetSp = '000' THEN
				-- // REALIZA EL CARGO A LA CUENTA DE CHEQUES--
		  EXECUTE PROCEDURE bdicheq:cargo_ref(cEmpresa, cSucursalSPEI, cUsuario, cTransaccionSPEI, '0000', cFolioSucursalSPEI, cCuentaOrden, 0, mTotalTelcel, '01', cCveRastreo, '', cUsuario)
		  INTO cCodRetCgo, cTrxCgo, dFechaCgo, mSdoDispCgo, mMontoCgo;
				
		  IF cCodRetCgo <> '000' THEN
			LET cCodRet = "00004";
            LET cMensajeRet = 'Error en el cargo a la cuenta concentradora de TELCEL';
			
            RETURN cCodRet, cMensajeRet;
	      END IF;
		
		
		ELSE 
			LET cCodRet = "00005";
            LET cMensajeRet = 'Error al obtener el folio_suc para cargo a cuenta concentradora de TELCEL';
            RETURN cCodRet, cMensajeRet;
		END IF;

		EXECUTE PROCEDURE bdispei:sp_regordenpagospei_pp( cEmpresa, cUsuario, cSucursalSPEI, cFolioSucursalSPEI, iBancoDestinoSPEI, dFechaCapturaSPEI, iTipoPagoSPEI, 
														iTipoOperacionSPEI, mTotalTelcel, cNombreOrdenSPEI, cCuentaOrdenSPEI, cRFCOrdenSPEI, cNombreBeneficiarioSPEI, 
														cCuentaBeneficiarioSPEI, cRFCBeneficiarioSPEI, mImporteIVASPEI, dReferenciaNumero, cReferenciaCobranza1SPEI, 
														cConceptoPagoSPEI, cClavePagoSPEI, cNombreBeneficiario2SPEI, cCuentaBeneficiario2SPEI, cRFCBeneficiario2SPEI,
														cConceptoPagoSPEI, cTransaccionSPEI, iTipoCuentaOrdenSPEI, iTipoCuentaBeneficiarioSPEI )
		INTO cCodRetSp, cInfoErr, cCveRastreo;
		
		IF cCodRetSp <> '000' THEN 
			LET cCodRet = "00006";
            LET cMensajeRet = 'Error al realizar el SPEI a la cuenta de TELCEL';
			EXECUTE PROCEDURE bdicheq:reversion_web(cEmpresa,cSucursalSPEI,cUsuario,cFolioSucursalSPEI,'A') INTO rCodRet;
            RETURN cCodRet, cMensajeRet;
		END IF;
		
		UPDATE bdicheq:sc_movdia SET referencia = cCveRastreo
		WHERE folio_suc = cFolioSucursalSPEI;
		
		UPDATE bdisac:"informix".sac_proceso_conciliacion_telcel
		SET  estatus='1', clave_rastreo = cCveRastreo
		WHERE nombre_archivo = cNombreArchivo and clave_rastreo = '' and estatus = '0';
			
	RETURN cCodRet, cMensajeRet;

	END;
END PROCEDURE
DOCUMENT
'-----------------------------------------------------------------------------------------------------------------------',
'-- FOLIO.........: Iniciativa: TempTA07-Pago de Servicios',
'-- AUTOR.........: 99807959 - Leon Fernando Chavez Murillo / 90155378 - Ruben Valdes.',
'-- FECHA.........: 28/04/2025',
'-- CREACION......: Realiza el SPEI para la conciliacion entre BanCoppel y TELCEL de las recargas realizadas de tiempo aire a travez de la app',
'-- SOLICITA......: Luis Enrique Trujillo Juarez',
'-- BD............: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE OR REPLACE PROCEDURE "informix".sp_pago_wu_abmt(pEmpresa	   CHAR(3),
									  pNombre1		   	   CHAR(40),
									  pNombre2             CHAR(40),
									  pApellidoPaterno     CHAR(40),
									  pApellidoMaterno     CHAR(40),
									  pFechaHoy            CHAR(10),
									  pEstado              CHAR(2),
									  pMontoAPagar         CHAR(20),
									  pSucursal            CHAR(4),
									  pMoneda              CHAR(3),
									  pMontoMoneda         MONEY(16,2),
									  pRefUno              CHAR(11),
									  pRetCode             CHAR(5),
									  pDescError           CHAR(250),
									  pMtcn                CHAR(11),
									  pNewMtcn             CHAR(16),
									  pFolSucEmp           CHAR(16),
									  pEmisorNameType      CHAR(1),
									  pBenefNameType       CHAR(1),
									  pMoneyTransKey       CHAR(10),
									  pNumRefRp            CHAR(16),
									  pFusionStatus        CHAR(4),
									  pEmisorCodMoneda     CHAR(3),
									  pBenefEdo            CHAR(40),
									  pSystemIdRp          CHAR(11),
									  pTelefonoCasa        CHAR(10),
									  pTelefonoCelular     CHAR(10),
									  pCategoria           CHAR(2),
									  pConvenio            CHAR(5),
									  pRefDos              CHAR(20),
									  pFormaPago           CHAR(1),
									  peMontoTotal         DECIMAL(10,2),
									  peImpComConv         DECIMAL(6,2),
									  peIvaComConv         DECIMAL(6,2),
									  peImpComCte          DECIMAL(6,2),
									  peIvaComCte          DECIMAL(6,2),
									  pNumEmp              CHAR(8),
									  pFolsuc              CHAR(16),
									  pTransSuc            CHAR(4),
									  pFechaPag            DATE,
									  pTranEquivCargo      CHAR(4),
									  pTransSucRef         CHAR(4),
									  pCuentaCargo         CHAR(20),
									  pCheque              INTEGER,
									  pMontoTotalRef       MONEY(14,2),
									  pDivisa              CHAR(2),
									  pReferenciaCargo     CHAR(40),
									  pNumTarjeta          CHAR(16),
									  pUsuAutoriza         CHAR(8),
									  pTranEquivAbono      CHAR(4),
									  pCuentaAbono         CHAR(20),
									  pDocto               INTEGER,
									  pMontoFirme          MONEY(14,2),
									  pMtoSBC              MONEY(14,2),
									  pMtoRem              MONEY(14,2),
									  pDiasRet             INTEGER,
									  pReferenciaAbono     CHAR(40),
									  pMtcnConf            CHAR(10),
									  pCiudad              CHAR(24),
									  pEstadoConf          CHAR(40),
									  pForeignRefNumRq     CHAR(16),
									  pForeingRefNumRp     CHAR(16),
									  pConfPago            CHAR(1),
									  pNumCte		   	   CHAR(20),
									  pValorCargo	   	   MONEY(16,2),
									  pValorAbono	   	   MONEY(16,2),
									  pFechaNacimiento     CHAR(10),
									  pMarca			   CHAR(2),
									  pCodigoPostalBenef1  VARCHAR(9),
									  pDirLinea1Benef	   VARCHAR(40),
									  pDirLinea2Benef	   VARCHAR(40),
									  pTelCasaBenef		   VARCHAR(20),
									  pTelCelBenef		   VARCHAR(20),
                                      pCampoGenerico1      CHAR(20),
                                      pCampoGenerico2      CHAR(20),
                                      pCampoGenerico3      CHAR(20)
									  )
	RETURNING 
	CHAR (5) AS RetCode, 
	CHAR (2) AS IdentificadorProceso,
	CHAR (5) AS RetCode2,
	CHAR(30) AS partnerId,
	CHAR(30) AS systemId,
	CHAR(30) AS systemName,
	CHAR(6) AS systemVersion,
	CHAR(18) AS systemIpAddress,
	CHAR(30) AS connectorId,
	CHAR(4) AS deviceId,
	CHAR(15) AS deviceType,
	CHAR(20) AS campoGenericoUno,
	CHAR(20) AS campoGenericoDos,
	CHAR(20) AS campoGenericoTres;

	-- Definicion de variables --                                                          		
	DEFINE cCodErr 					CHAR (5);                                                 		
	DEFINE cIdentificadorProceso 	CHAR (2);                                                 		
	DEFINE cRetCode2 				CHAR (5);
	DEFINE cRetCode3 				CHAR (5);
	DEFINE iSqlErr 					INTEGER;
	DEFINE cError_Desc 				CHAR(30);
	DEFINE vtransaccion 			SMALLINT;
	DEFINE cFlagTelCel 				CHAR (1);
	DEFINE cFlagTelCasa 			CHAR (1);
	DEFINE cFlagTelOficina 			CHAR (1);
	DEFINE mMontoServ 				MONEY(16,2);
	DEFINE mMontoCargoServ 			MONEY(16,2);	
	DEFINE iMovtoServ 				INTEGER;
	DEFINE iMovtoCargoServ 			INTEGER;
    DEFINE cDescripcion 			CHAR(40); 
    DEFINE cMoneda 					CHAR(3);
	DEFINE mPaisImporte 			MONEY;
	DEFINE vfec_nac 				CHAR(10);
	DEFINE vcuenta 					INTEGER;	
	DEFINE cTranret 				CHAR(4);
	DEFINE dFechahoy 				DATE;
	DEFINE mSdodisp 				MONEY(14,2);
	DEFINE mMontoret 				MONEY(14,2);
	DEFINE cDescripcionRev 			CHAR(80);	
    DEFINE cPartnerId 				CHAR(30);
    DEFINE cSystemId 				CHAR(30);
    DEFINE cSystemName 				CHAR(30);
    DEFINE cSystemVersion 			CHAR(6);
    DEFINE cSystemIpAddress 		CHAR(18);
    DEFINE cConnectorId 			CHAR(30);
    DEFINE cDeviceId 				CHAR(4);
    DEFINE cDeviceType				CHAR(15);	
	DEFINE cErrorDesc 				CHAR(30);
	DEFINE cTempleteId 				CHAR(10);
	DEFINE cNoreintentos 			CHAR(1);
	DEFINE cUsuario 				CHAR(8);
	DEFINE fechahorainsertCURRENT 	CHAR(22);	
	DEFINE cSegIdentFlag 			CHAR(1);
	DEFINE cContador 				SMALLINT;	
	DEFINE cMes 					CHAR(2);
	DEFINE cDia 					CHAR(2);
	DEFINE cAnio 					CHAR(4);
	DEFINE pMarca1 					VARCHAR(3);
	DEFINE cValidaPLDteldom 		INTEGER;
	DEFINE cCodErrAux 				CHAR(6);
	DEFINE pHoraOrigen 				CHAR(6); 
	DEFINE vCajeroWU 				CHAR(8);
	DEFINE vCentroCostosHrem 		CHAR(4);
	DEFINE vUsuarioHrem 			CHAR(8);
	DEFINE cOrigen 					CHAR (3);   
	DEFINE cCampoGenericoUno 		CHAR(20);
	DEFINE cCampoGenericoDos 		CHAR(20);
	DEFINE cCampoGenericoTres 		CHAR(20);
	DEFINE cNameType 				CHAR(1);
	
	DEFINE cPrimerNombre 				CHAR(40);
	DEFINE cSegundoNombre 				CHAR(40);
	DEFINE cApellidoPaterno 			CHAR(40);
	DEFINE cApellidoMaterno 			CHAR(40);
	DEFINE cFechaNacimiento 			CHAR(10);
	DEFINE cIdNacionalidad 				CHAR(3);
	DEFINE cIdPaisNacimiento 			CHAR(3);
	DEFINE cIdEstadoNacimiento 			CHAR(2);
	DEFINE cSexo 						CHAR(1);
	DEFINE cTipoIdentificacion 			CHAR(2);
	DEFINE cNoIdentificacion 			CHAR(30);
	DEFINE cIdPaisEmision 				CHAR(3);
	DEFINE cFechaVencimiento 			CHAR(10);
	DEFINE cTipoCte 					CHAR(2);
	DEFINE cIdEstado 					CHAR(2);
	DEFINE cIdCiudad 					CHAR(3);
	DEFINE cIdMunicipio 				CHAR(5);
	DEFINE cNumColonia 					CHAR(10);
	DEFINE cNumCalle 					CHAR(10);
	DEFINE cNumeroCiudad 				CHAR(10);
	DEFINE cNumExterior 				CHAR(10);
	DEFINE cNumInterior 				CHAR(10);
	DEFINE cDepartamento 				CHAR(10);
	DEFINE cCodPostal 					CHAR(5);
	DEFINE cTelefono					CHAR(13);
	DEFINE cTelefonoCelular 			CHAR(13);
	DEFINE cIdPaisDomExt 				CHAR(3);
	DEFINE cCorreoElectronico 			CHAR(100);
	DEFINE cClavePuesto 				CHAR(10);
	DEFINE cClaveSubPuesto 				CHAR(10);
	DEFINE cIdOcupacion 				CHAR(3);
	DEFINE cCodRetRes					CHAR(5);
	DEFINE cForeignSystemId				CHAR(11); 
	DEFINE cForeignRsCntRq  			CHAR(11);
	DEFINE cBenefTieneFechVenc 			CHAR(1);
	
	-- Inicializacion de variables --
	LET cCodErr = "00000";	
	LET cIdentificadorProceso = "00";
    LET cRetCode2 = "00000";
	LET cRetCode3 = "00000";
	LET iSqlErr = 0;
	LET vtransaccion = 0;
    LET mMontoServ = 0;
	LET mMontoCargoServ = 0;
	LET iMovtoServ = 0;
	LET iMovtoCargoServ = 0;
	LET cDescripcion = '';
	LET cMoneda = '';
	LET cDescripcionRev = '';	
	LET cPartnerId = '';
    LET cSystemId = '';
    LET cSystemName = '';
    LET cSystemVersion = '';
    LET cSystemIpAddress = '';
    LET cConnectorId = '';
    LET cDeviceId = '';
    LET cDeviceType = '';	
	LET cErrorDesc = '';
	LET cTempleteId = '';
	LET cNoreintentos = '';
	LET cUsuario = '';
	LET fechahorainsertCURRENT = '';
	LET cSegIdentFlag = '';
	LET cContador = 0;
	LET cError_Desc = '';
	LET cOrigen = '';
    LET cForeignSystemId =""; 
	LET cForeignRsCntRq  ="" ;
	

	--SET DEBUG FILE TO '/home/e90154184/trace.sql';
    --TRACE ON;	
	
	-- Validar que ningun parametro obligatorio este vacio --
	LET pEmpresa			= NVL(pEmpresa			,"");
	LET pNombre1			= NVL(pNombre1			,"");
	LET pNombre2            = NVL(pNombre2          ,"");
	LET pApellidoPaterno    = NVL(pApellidoPaterno  ,"");
	LET pApellidoMaterno    = NVL(pApellidoMaterno  ,"");
	LET pFechaHoy           = NVL(pFechaHoy         ,"");
	LET pEstado             = NVL(pEstado           ,"");
	LET pMontoAPagar        = NVL(pMontoAPagar      ,"");
	LET pSucursal           = NVL(pSucursal         ,"");
	LET pMoneda             = NVL(pMoneda           ,"");
	LET pMontoMoneda        = NVL(pMontoMoneda      ,0);
	LET pRefUno             = NVL(pRefUno           ,"");
	LET pRetCode            = NVL(pRetCode          ,"");
	LET pDescError          = NVL(pDescError        ,"");
	LET pMtcn               = NVL(pMtcn             ,"");
	LET pNewMtcn            = NVL(pNewMtcn          ,"");
	LET pFolSucEmp          = NVL(pFolSucEmp        ,"");
	LET pEmisorNameType     = NVL(pEmisorNameType   ,"");
	LET pBenefNameType      = NVL(pBenefNameType    ,"");
	LET pMoneyTransKey      = NVL(pMoneyTransKey    ,"");
	LET pNumRefRp           = NVL(pNumRefRp         ,"");
	LET pFusionStatus       = NVL(pFusionStatus     ,"");
	LET pEmisorCodMoneda    = NVL(pEmisorCodMoneda  ,"");
	LET pBenefEdo           = NVL(pBenefEdo         ,"");
	LET pSystemIdRp         = NVL(pSystemIdRp       ,"");
	LET pTelefonoCasa       = NVL(pTelefonoCasa     ,"");
	LET pTelefonoCelular    = NVL(pTelefonoCelular  ,"");
	LET pCategoria          = NVL(pCategoria        ,"");
	LET pConvenio           = NVL(pConvenio         ,"");
	LET pRefDos             = NVL(pRefDos           ,"");
	LET pFormaPago          = NVL(pFormaPago        ,"");
	LET peMontoTotal        = NVL(peMontoTotal      ,0);
	LET peImpComConv        = NVL(peImpComConv      ,0);
	LET peIvaComConv        = NVL(peIvaComConv      ,0);
	LET peImpComCte         = NVL(peImpComCte       ,0);
	LET peIvaComCte         = NVL(peIvaComCte       ,0);
	LET pNumEmp             = NVL(pNumEmp           ,"");
	LET pFolsuc             = NVL(pFolsuc           ,"");
	LET pTransSuc           = NVL(pTransSuc         ,"");
	LET pTranEquivCargo     = NVL(pTranEquivCargo   ,"");
	LET pTransSucRef        = NVL(pTransSucRef      ,"");
	LET pCuentaCargo        = NVL(pCuentaCargo      ,"");
	LET pCheque             = NVL(pCheque           ,"");
	LET pMontoTotalRef      = NVL(pMontoTotalRef    ,0);
	LET pDivisa             = NVL(pDivisa           ,"");
	LET pReferenciaCargo    = NVL(pReferenciaCargo  ,"");
	LET pNumTarjeta         = NVL(pNumTarjeta       ,"");
	LET pUsuAutoriza        = NVL(pUsuAutoriza      ,"");
	LET pTranEquivAbono     = NVL(pTranEquivAbono   ,"");
	LET pCuentaAbono        = NVL(pCuentaAbono      ,"");
	LET pDocto              = NVL(pDocto            ,0);
	LET pMontoFirme         = NVL(pMontoFirme       ,0);
	LET pMtoSBC             = NVL(pMtoSBC           ,0);
	LET pMtoRem             = NVL(pMtoRem           ,0);
	LET pDiasRet            = NVL(pDiasRet          ,0);
	LET pReferenciaAbono    = NVL(pReferenciaAbono  ,"");
	LET pMtcnConf           = NVL(pMtcnConf         ,"");
	LET pCiudad             = NVL(pCiudad           ,"");
	LET pEstadoConf         = NVL(pEstadoConf       ,"");
	LET pForeignRefNumRq    = NVL(pForeignRefNumRq  ,"");
	LET pForeingRefNumRp    = NVL(pForeingRefNumRp  ,"");
	LET pConfPago           = NVL(pConfPago         ,"");
	LET pNumCte		   		= NVL(pNumCte			,"");
	LET pMarca		   		= NVL(pMarca			,"");
	LET pFechaPag			= NVL(pFechaPag			,"");
	LET vcuenta             = 0;
	LET pCodigoPostalBenef1  = NVL(pCodigoPostalBenef1,"");
	LET pDirLinea1Benef     = NVL(pDirLinea1Benef   ,"");
	LET pDirLinea2Benef     = NVL(pDirLinea2Benef   ,"");
	LET pTelCasaBenef       = NVL(pTelCasaBenef     ,"");
	LET pTelCelBenef        = NVL(pTelCelBenef		,"");
	
	
	LET cDia = '';
    LET cMes = '';
    LET cAnio = '';
	LET pMarca1 = '';
	LET cValidaPLDteldom = 0;
	LET cCodErrAux = "000000";
	
	LET cCampoGenericoUno = '';
	LET cCampoGenericoDos = '';
	LET cCampoGenericoTres = '';	
	
	LET pHoraOrigen =(SELECT replace(substr(current,12,8),':','') FROM bdisac:sac_fechas);

	LET vCajeroWU = (SELECT first 1 ejecutivo FROM bdinteg:"informix".si_ejecut WHERE empresa = '001' AND sucursal=pSucursal and password <> 'BAJA' and nombramiento like 'CAJERO%');
	LET vCentroCostosHrem = (SELECT trim(valor) FROM "informix".sac_param WHERE cod_param =87121);
	LET vUsuarioHrem = (SELECT trim(valor) FROM "informix".sac_param WHERE cod_param =87122);

	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodErr = iSqlErr;
			RETURN NVL(cCodErr,''), NVL(cIdentificadorProceso,''), NVL(cRetCode2,''),NVL(cPartnerId,''), NVL(cSystemId,''), NVL(cSystemName,''), NVL(cSystemVersion,''), NVL(cSystemIpAddress,''), NVL(cConnectorId,''), NVL(cDeviceId,''), NVL(cDeviceType,''),NVL(cCampoGenericoUno,''),NVL(cCampoGenericoDos,''),NVL(cCampoGenericoTres,'');
		END IF;
	END EXCEPTION;
	
	--Manejo de transacciones
	ON EXCEPTION IN (-535)
        let vtransaccion = 1;
    END EXCEPTION WITH resume;
	IF vtransaccion = 1 THEN
		COMMIT WORK;
		BEGIN WORK;
	ELSE
		BEGIN WORK;
	END IF;


	
	IF pCampoGenerico1 = 'TransactionInquiry' THEN
   --SP que obtiene los parametros para el servicio de WU/VG/OV			
		
		SELECT partnerId , systemId , systemName, systemVersion ,systemIpAddress, connectorId, deviceId, deviceType
			INTO cPartnerId, cSystemId, cSystemName, cSystemVersion, cSystemIpAddress, cConnectorId, cDeviceId, cDeviceType
			FROM bdisac:"informix".sac_wu_abmt
			WHERE empresa = pEmpresa AND sucursal = pSucursal AND convenio = pConvenio;
				
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cRetCode2 = '00002';
				
			END IF;
	ELSE
		IF pCampoGenerico1 = 'GuardarespSearch' THEN
					
			SELECT fsid ,counter_id
			INTO cForeignSystemId ,cForeignRsCntRq
			FROM bdisac:"informix".sac_wu_identificadores
			WHERE empresa = pEmpresa AND marca = pMarca AND sucursal = pSucursal;		
					
			EXECUTE PROCEDURE bdisac:"informix".sp_sac_wu_guardarespuesta_search_web(pEmpresa, pNumEmp,pMarca,pForeignRefNumRq,	pRefUno,CURRENT,pRetCode,pEmisorNameType,pNombre1,pNombre2,pApellidoPaterno,pApellidoMaterno,pCiudad,pEstadoConf, pEmisorCodMoneda,pMoneda,	pCodigoPostalBenef1, pDirLinea1Benef, pTelCelBenef, pConfPago, pReferenciaCargo, pCampoGenerico3, pReferenciaAbono,  pBenefEdo, '', '', 'MX','MXN', '', '', '','', pRefDos,	pNumTarjeta, pDirLinea2Benef,pCuentaAbono,pCiudad, '',pFechaHoy,pCampoGenerico2, pMoneyTransKey, pConvenio, '',pConvenio,pCategoria,pCategoria, pCategoria, cForeignSystemId, pForeignRefNumRq, cForeignRsCntRq,	pDescError,'', CURRENT, pNumEmp, CURRENT,	pSucursal) INTO	cRetCode2,cError_Desc;
			
			LET cCodErr = "01223";
	
		ELSE
		
			IF pCampoGenerico1 = 'GuardarespPay' THEN
			
				EXECUTE PROCEDURE  "informix".sp_consulta_datoscteremesa(pNumCte)
							INTO cCodRetRes, cPrimerNombre, cSegundoNombre, cApellidoPaterno,  cApellidoMaterno, cFechaNacimiento, cIdNacionalidad, cIdPaisNacimiento, cIdEstadoNacimiento,
							cSexo, cTipoIdentificacion, cNoIdentificacion, cIdPaisEmision, cFechaVencimiento, cIdOcupacion, cTipoCte, cIdEstado, cIdCiudad, cIdMunicipio, cNumColonia,
							cNumCalle, cNumeroCiudad, cNumExterior, cNumInterior, cDepartamento, cCodPostal, cTelefono, cTelefonoCelular, cIdPaisDomExt, cCorreoElectronico, cClavePuesto,
							cClaveSubPuesto;
							
	
				SELECT fsid ,counter_id
				INTO cForeignSystemId ,cForeignRsCntRq
				FROM bdisac:"informix".sac_wu_identificadores
				WHERE empresa = pEmpresa AND marca = pMarca AND sucursal = pSucursal;				

				IF pSystemIdRp = '' THEN
					LET cBenefTieneFechVenc = 'N';
				ELSE
					LET cBenefTieneFechVenc = 'Y';
				END IF;
				
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_wu_guardarespuesta_pay_web(pEmpresa,pMarca,pNumEmp,pBenefNameType,pNombre1,pNombre2,pApellidoPaterno,pApellidoMaterno,pCiudad,pEstadoConf ,pCodigoPostalBenef1,pEmisorNameType, pNewMtcn,cNoIdentificacion,cBenefTieneFechVenc ,pSystemIdRp,pFechaNacimiento, '',pDirLinea1Benef,pDirLinea2Benef,pReferenciaAbono,pTelCasaBenef,cTelefonoCelular,'', cIdPaisNacimiento,pCuentaCargo,cSexo,'','','MX','MXN', pCuentaAbono, pMontoAPagar,pMoneyTransKey,'',pRefUno,pConfPago,pForeignRefNumRq,CURRENT, pRetCode,'','','',pCampoGenerico2, cForeignSystemId,pForeingRefNumRp,cForeignRsCntRq,pDescError,'',CURRENT, pNumEmp, CURRENT, '', '', '',  pNumCte) INTO	cRetCode2,cCampoGenericoUno;		
				
				LET cCodErr = "01224";
			
			ELSE

				--Se obtiene el valor de identificador del pago para saber si es la segunda ejecucion para la SEGUNDA IDENTIFICACION, PAGO o DESPAGO
				LET cSegIdentFlag = SUBSTRING(pRefDos FROM 2 FOR 1);
				LET pRefDos = SUBSTRING(pRefDos FROM 1 FOR 1);
				
				IF cSegIdentFlag = 'D' THEN
					--falta un parametro para poder ejecutar el sp de parametros para el servicio para desbloquear la remesa
					IF pEmpresa = "" OR pNumEmp = "" OR pMarca = "" THEN
						LET cCodErr = "00003";
					ELSE 
						/*Select para credenciales de la marcas de wester union*/					
						SELECT partnerId , systemId , systemName, systemVersion ,systemIpAddress, connectorId, deviceId, deviceType
						INTO cPartnerId, cSystemId, cSystemName, cSystemVersion, cSystemIpAddress, cConnectorId, cDeviceId, cDeviceType
						FROM bdisac:"informix".sac_wu_abmt
						WHERE empresa = pEmpresa AND sucursal = pSucursal AND convenio = pConvenio;

						IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cRetCode2 = '00002';
						
						END IF;
					END IF;
				
				--Se valida que ninguna variable de entrada este vacia 
				ELIF pEmpresa = "" OR pNombre1 = "" OR pApellidoPaterno = "" OR pFechaHoy = "" OR pEstado = "" OR pMontoAPagar = "" OR pSucursal = "" OR pMoneda = "" OR pMontoMoneda = 0 OR pRefUno = "" OR pRetCode = "" OR pDescError = "" OR pMtcn = "" OR pFolSucEmp = "" OR pEmisorNameType = "" OR pBenefNameType = "" OR pMoneyTransKey = "" OR pNumRefRp = "" OR pEmisorCodMoneda = "" OR pBenefEdo = "" OR pSystemIdRp = "" OR pTelefonoCasa = "" OR pCategoria = "" OR pConvenio = "" OR pRefDos = "" OR (pFormaPago <> "1" AND pNumTarjeta = "" AND pCuentaAbono = "") OR peMontoTotal = 0 OR pNumEmp = "" OR pFolsuc = "" OR pTransSuc = "" OR pFechaPag = "" OR (pTranEquivCargo = "" AND pTranEquivAbono = "") OR (pFormaPago <> "1" AND pTransSucRef = "") OR pCuentaCargo = "" OR pCheque = "" OR pMontoTotalRef = 0 OR pDivisa = "" OR pReferenciaCargo = "" OR (pFormaPago <> "1" AND pTranEquivAbono = "") OR (pFormaPago <> "1" AND pCuentaAbono = "") OR pMontoFirme = "" OR pMtoSBC = "" OR pMtoRem = "" OR pDiasRet = "" OR (pFormaPago <> "1" AND pReferenciaAbono = "") OR pMtcnConf = "" OR pCiudad = "" OR pEstadoConf = "" OR pForeignRefNumRq = "" OR pForeingRefNumRp = "" OR pConfPago = "" OR pMarca = "" THEN
						
						LET cCodErr = "00001";	
				ELSE
					
					--Validacion solicitada por PLD para limites de Direcciones y Telefonos ingresados en el cobro de remesas sp_sac_pldlim_teldom
						--cIdentificadorProceso = "12"
						
					LET cDia = LPAD(SUBSTRING(pFechaHoy FROM 5 FOR 2), 2, '0');
					LET cMEs = LPAD(SUBSTRING(pFechaHoy FROM 7 FOR 2), 2, '0');
					--LET cMEs = LPAD(SUBSTRING(pFechaHoy FROM 5 FOR 2), 2, '0');
					LET cAnio = LPAD(SUBSTRING(pFechaHoy FROM 1 FOR 4), 4, '0');	
					
					IF pMarca = 'OV' THEN 
						LET pMarca1 = 'OVA';
					ELIF pMarca = 'VG' THEN
						LET pMarca1 = 'VIG';
					ELSE 
						LET pMarca1 = 'WUN';
					END IF;		

					EXECUTE PROCEDURE "informix".sp_sac_pldlim_teldom(pMarca1,pDirLinea1Benef,pDirLinea2Benef,pBenefEdo,pCodigoPostalBenef1,cAnio||cMEs,pNumEmp,pTelCasaBenef,pTelCelBenef,pFolsuc,pSucursal,pRefUno,'NORMAL') INTO cRetCode2;


					IF cRetCode2 <> '00000' THEN
						--MENSAJE EN CAJA "Remesa excede limite, 1245" REMESA EXCEDE LIMITE DE DOMICILIO O TELEFONO PLD
						LET cRetCode2 = "01245";
						LET cIdentificadorProceso = "02";
						LET cCodErrAux = '999999';
					ELSE
						--cValidaPLDteldom es un flag qe comprueba si se ejecuto sp_sac_pldlim_teldom en caso de reversion de la operacion
						LET cValidaPLDteldom = 1;					
												
						/*Select para credenciales de la marcas de wester union*/					
						SELECT partnerId , systemId , systemName, systemVersion ,systemIpAddress, connectorId, deviceId, deviceType
						INTO cPartnerId, cSystemId, cSystemName, cSystemVersion, cSystemIpAddress, cConnectorId, cDeviceId, cDeviceType
						FROM bdisac:"informix".sac_wu_abmt
						WHERE empresa = pEmpresa AND sucursal = pSucursal AND convenio = pConvenio;

						IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cRetCode2 = '00002';
						LET cIdentificadorProceso = "11";
						
						ELSE
							--Verificar si existe el registro en la tabla sac_movimientos
							SELECT COUNT(*)
							INTO cContador
							FROM bdisac:"informix".sac_movimientos
							WHERE id_sucursal = pSucursal 
							AND numcategoria = pCategoria 
							AND numconvenio = pConvenio
							AND referencia1 = pRefUno 
							AND referencia2 = pRefDos 
							AND folio_suc = pFolsuc
							AND status_cancelado = 'N';
							
							IF cContador = 0 THEN
								--Se validan los numeros de telefono
								CALL bdinteg:"informix".sp_validatelefono(pEmpresa, pTelefonoCasa, pTelefonoCelular, "")
								RETURNING cRetCode2, cFlagTelCasa, cFlagTelCel, cFlagTelOficina;
								IF cFlagTelCasa <> "1" AND (cFlagTelCel <> "1" AND pTelefonoCelular <> "") THEN
									LET cRetCode2 = "00003";
									LET cIdentificadorProceso = "08";
								ELIF cFlagTelCasa <> "1" THEN
									LET cRetCode2 = "00001";
									LET cIdentificadorProceso = "08";
								ELIF cFlagTelCel <> "1" AND pTelefonoCelular <> "" THEN
									LET cRetCode2 = "00002";
									LET cIdentificadorProceso = "08";
								ELSE
									--Se validan los montos
									LET pFechaHoy = SUBSTRING(pFechaHoy FROM 5 FOR 2)||SUBSTRING(pFechaHoy FROM 7 FOR 2)||SUBSTRING(pFechaHoy FROM 1 FOR 4);
									EXECUTE PROCEDURE "informix".sp_validamontoremesawu_web(pEmpresa, pNombre1, pNombre2, pApellidoPaterno, pApellidoMaterno, pFechaNacimiento, pFechaHoy, pEstado, pMontoAPagar, pSucursal, pMoneda, pMontoMoneda, pRefUno, pRetCode, pDescError, pMtcn, pNewMtcn, pForeignRefNumRq, pEmisorNameType, pBenefNameType, pMoneyTransKey, pForeingRefNumRp, pFusionStatus, pMoneda, pBenefEdo, pSystemIdRp) INTO cRetCode2;
									
									IF cRetCode2 <> "00000" THEN
										LET cIdentificadorProceso = "02";
									ELSE
									
										IF(pSucursal = '5011') THEN
											LET cOrigen = 'BEX';
										ELSE
											LET cOrigen = 'ATM';
										END IF;

										CALL "informix".sp_grabapagoservicio_hs(pSucursal, pCategoria, pConvenio, pRefUno, pRefDos, pFormaPago, peMontoTotal, peImpComConv, peIvaComConv, peImpComCte, peIvaComCte, pCuentaAbono, pNumEmp, pFolsuc, pTransSuc, pFechaPag, cOrigen, pSucursal, '00', pTransSuc, pHoraOrigen, '', pCampoGenerico1, '')
										RETURNING cRetCode2;
										
										
										IF vtransaccion = 1 THEN
											COMMIT WORK;
											BEGIN WORK;
										ELSE
											BEGIN WORK;
										END IF;
										
										IF cRetCode2 <> "00000" THEN
											LET cIdentificadorProceso = "03";
										ELSE
											--Busco datos de query
											EXECUTE PROCEDURE "informix".sp_obtieneremadic(pCategoria, '999', pMtcn)
											INTO cRetCode2, cMoneda, mPaisImporte;
				
											--Actualizo tabla de datos para limites de remesas mensuales
											LET vfec_nac = SUBSTRING(pFechaNacimiento FROM 3 FOR 2) || SUBSTRING(pFechaNacimiento FROM 1 FOR 2) || SUBSTRING(pFechaNacimiento FROM 5 FOR 4);
											EXECUTE PROCEDURE "informix".sp_actualizaremesa(pCategoria, pConvenio, pMtcn, pNombre1, pNombre2, pApellidoPaterno, pApellidoMaterno, vfec_nac, cMoneda, mPaisImporte)
											INTO cRetCode2, vcuenta;
											
											IF cRetCode2 <> "00000" THEN
												LET cIdentificadorProceso = "09";
											ELSE
												
												IF pFormaPago = "1" THEN
													LET pTransSucRef = pTransSuc;
												END IF;	


												CALL bdicheq:"informix".cargo_ref(pEmpresa, pSucursal, pNumEmp, pTranEquivCargo, pTransSucRef, pFolsuc, pCuentaCargo, pCheque, pMontoTotalRef, pDivisa, pReferenciaCargo, pNumTarjeta, pUsuAutoriza)	
												RETURNING cRetCode2, cTranret, dFechahoy, mSdodisp, mMontoret;

												
												
												IF cRetCode2 <> "000" THEN
													LET cIdentificadorProceso = "07";
												ELSE
													--Se valida que la forma de pago fue en efectivo para evitar el llamado a el sp abono_ref
													IF pFormaPago <> "1" THEN
														--Llamado a sp para el cargo a la cuenta

														CALL bdicheq:"informix".abono_ref(pEmpresa, pSucursal, pNumEmp, pTranEquivAbono, pTransSucRef, pFolsuc, pCuentaAbono, pDocto, pMontoTotalRef, pMontoFirme, pMtoSBC, pMtoRem, pDiasRet, pDivisa, pReferenciaAbono, pNumTarjeta, pUsuAutoriza)
														RETURNING cRetCode2;
														
													END IF;
													IF cRetCode2 <> "000" THEN
														LET cIdentificadorProceso = "05";
													ELSE
														-- Llamado al sp para validar los montos
														SELECT * INTO cRetCode2,cMoneda, mMontoServ, mMontoCargoServ, cDescripcion, iMovtoServ,iMovtoCargoServ 
														FROM TABLE(bdicheq:"informix".sp_mini21(pEmpresa,pNumEmp,pSucursal,pFolsuc));

														IF cRetCode2 <> "00000" THEN
															LET cIdentificadorProceso = "06";
														ELSE
															--Verificar que no hay descuadre en caja
															IF mMontoCargoServ = pValorCargo AND mMontoServ = pValorAbono THEN
																-- Llamado para confirmar el pago
																CALL "informix".sp_confpagoservicio(pSucursal, pCategoria, pConvenio, pRefUno, pRefDos, pFolsuc)
																RETURNING cRetCode2, cDescripcion;
																
																IF cRetCode2 <> "00000" THEN
																	LET cIdentificadorProceso = "04";
																END IF;
															ELSE
																-- Hay descuadre en caja
																LET cCodErr = '00002';
															END IF;
														END IF;
													END IF;
												END IF;
											END IF;
										END IF;
									END IF;
								END IF;							
							ELSE
								LET cCampoGenericoUno = pCampoGenerico1;
							END IF;
						END IF;
					END IF;
				END IF;	
			END IF;	
		END IF;
	END IF;
	
	
	IF cIdentificadorProceso != '00' THEN
		IF cCodErrAux != '999999' THEN 
			IF cValidaPLDteldom = 1 THEN
				EXECUTE PROCEDURE "informix".sp_sac_pldlim_teldom(pMarca1,pDirLinea1Benef,pDirLinea2Benef,pBenefEdo,pCodigoPostalBenef1,cAnio||cMEs,pNumEmp,pTelCasaBenef,pTelCelBenef,pFolsuc,pSucursal,pRefUno,'REVERSO') INTO cCodErrAux;
			END IF;	
		END IF;
	END IF;
	
	RETURN NVL(cCodErr,''), NVL(cIdentificadorProceso,''), NVL(cRetCode2,''),NVL(cPartnerId,''), NVL(cSystemId,''), NVL(cSystemName,''), NVL(cSystemVersion,''), NVL(cSystemIpAddress,''), NVL(cConnectorId,''), NVL(cDeviceId,''), NVL(cDeviceType,''),NVL(cCampoGenericoUno,''),NVL(cCampoGenericoDos,''),NVL(cCampoGenericoTres,'');
END
END PROCEDURE
DOCUMENT
'FOLIO.........: Remesas ABMT',
'AUTOR.........: Ingrid Garcia',
'FECHA.........: Enero 2023',
'MODIFICACION..: Se crea procedimiento que realiza los llamados a procedimientos para el cobro de remesa WU',
'SUSTENTO......: ',
'BD............: BDISAC';

CREATE PROCEDURE "informix".sp_reverso_msw(pOrigen CHAR(4),pCategoria CHAR(2),pConvenio CHAR(3),pUsuario CHAR(8),pFolio CHAR(16),pFecha CHAR(8),pHora CHAR(6))
	RETURNING
	CHAR(5)		AS codigo,	
	CHAR(30)	AS mensaje;	
	
	DEFINE iSqlErr       INTEGER;
    DEFINE iIsamErr      INTEGER;
    DEFINE cInfoErr      CHAR(100);
	DEFINE cCodRet       CHAR(5);
	DEFINE cMensaje		 CHAR(30);
	DEFINE cReversable	 CHAR(1);
	DEFINE iExiste		 INTEGER;
	DEFINE cSucursal     CHAR(4);
	DEFINE dFecha_actual DATE;
	DEFINE cFechaFormat	 CHAR(8);
	DEFINE cHora_Reverso 	CHAR(6);
	DEFINE cNumero_Cuenta 	CHAR(12);
	
	LET cCodRet       = "00000";
	LET cMensaje      = "Exitoso";
	LET cReversable   = '';
	LET iExiste		  = 0;
	LET cSucursal	  = '';
	LET dFecha_actual = '';
	LET cFechaFormat  = '';
	LET cHora_Reverso 	= '';
	LET cNumero_Cuenta 	= '';
	
	--SET DEBUG FILE TO  '/home/e10000161/sp_reverso_msw.out'; 
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "Error: sp_reverso_msw";
				UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
			     WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
				       fecha = pFecha and hora = pHora;
                EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_reverso_msw_epg");
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
	    SET LOCK MODE TO WAIT 3;

	    -- HoraReverso
		IF pCategoria = '03' AND pConvenio = '001' AND SUBSTR(pHora, 1, 1) = 'R' THEN
			LET cHora_Reverso = pHora;
			LET pHora = TO_CHAR(CURRENT HOUR TO SECOND, '%H%M%S');
		END IF;
		
         INSERT INTO "informix".bitacora_reverso_msw 
         VALUES (pOrigen,pCategoria,pConvenio,pUsuario,pFolio,pFecha,pHora,'','',CURRENT);
        
		SELECT fecha_hoy into dFecha_actual FROM "informix".sac_fechas;
		LET cFechaFormat = YEAR(dFecha_actual) || LPAD(MONTH(dFecha_actual),2,0) || LPAD(DAY(dFecha_actual),2,0);	
		
		IF pOrigen = "" OR pCategoria = "" OR pConvenio = "" OR pFolio = "" OR cFechaFormat <> pFecha THEN
			LET cCodRet = '00400';
			LET cMensaje = 'Error:sp_reverso_msw';
			UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
			 WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
				   fecha = pFecha and hora = pHora;
            RETURN cCodRet, cMensaje;
		END IF;

		IF pOrigen = "CPL"  THEN
                
			  SELECT reversable 
                INTO cReversable
			    FROM "informix".sac_controlconvenios
			   WHERE estatus = 'A' 
                 AND status_cpl = 'A'
			     AND numcategoria = pCategoria 
                 AND numconvenio = pConvenio;
			
			   SELECT id_sucursal, count(*)
				 INTO cSucursal,iExiste
				 FROM "informix".sac_movimientos
			    WHERE numcategoria = pCategoria 
                  AND numconvenio = pConvenio
				  AND folio_suc = pFolio
				  AND origen = pOrigen group by id_sucursal;
				  
			IF  dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00401';
				LET cMensaje = 'Error:No existe Folio';
				UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
				 WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
					   fecha = pFecha and hora = pHora;
				RETURN cCodRet, cMensaje;
			END IF;
			
			IF cReversable = 1 AND iExiste = 1 THEN 			
					
				IF pCategoria||pConvenio = '02003' OR pCategoria||pConvenio = '04001' OR pCategoria||pConvenio = '06004' OR pCategoria||pConvenio = '09011' THEN 	
					
					EXECUTE PROCEDURE "informix".sp_reversionsac('001', cSucursal, pUsuario, pFolio) INTO cCodRet;
					IF cCodRet = '001' THEN
						LET cCodRet = '00000';
					  UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
					   WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
							 fecha = pFecha and hora = pHora;
					ELSE
						LET cCodRet = '00402';
						LET cMensaje = 'Error: sp_reverso_msw';
						UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
						 WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
							   fecha = pFecha and hora = pHora;
					END IF;
				
				ELSE	
				
					EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucursal, pUsuario, pFolio, '') INTO cCodRet;
					IF cCodRet = '000' THEN
						LET cCodRet = '00000';
					  UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
					   WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
							 fecha = pFecha and hora = pHora;
					ELSE
						LET cCodRet = '00402';
						LET cMensaje = 'Error: sp_reverso_msw';
						UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
						 WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
							   fecha = pFecha and hora = pHora;
					END IF;	
				
				END IF;	
				
			ELSE
				LET cCodRet = '00403';
				LET cMensaje = 'Servicio no permite reverso';
				UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
				 WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
					   fecha = pFecha and hora = pHora;
			END IF;
						
			RETURN cCodRet, cMensaje;
		ELIF pOrigen = "BEX" OR pOrigen = "bex"  THEN
			SELECT reversable 
                INTO cReversable
			    FROM "informix".sac_controlconvenios
			   WHERE estatus = 'A' 
                 AND status_bex = 'A'
			     AND numcategoria = pCategoria 
                 AND numconvenio = pConvenio;
			
				--HoraReverso			
				IF pCategoria = '03' AND pConvenio = '001' AND SUBSTR(cHora_Reverso, 1, 1) = 'R' THEN
					LET cNumero_Cuenta = SUBSTR(pFolio,1,11);
					--OBTIENE NUMERO DE CLIENTE DE LA CUENTA EJE
			        SELECT TRIM(num_cte)|| SUBSTR(pFolio,12,5) || SUBSTR(cHora_Reverso,5,2)
					INTO pFolio
					FROM bdicheq:"informix".sc_maechq 
					WHERE cuenta = cNumero_Cuenta;
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = "00309";
						LET cMensaje = 'Cuenta eje invalida';
						RETURN cCodRet, cMensaje;
					END IF;
					
					LET cMensaje = pFolio;
				END IF;
			
			   SELECT id_sucursal, count(*)
				 INTO cSucursal,iExiste
				 FROM "informix".sac_movimientos
			    WHERE numcategoria = pCategoria 
                  AND numconvenio = pConvenio
				  AND folio_suc = pFolio
				  AND origen = pOrigen group by id_sucursal;
				  
			IF  dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00401';
				LET cMensaje = 'Error:No existe Folio';
				UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
				 WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
					   fecha = pFecha and hora = pHora;
				RETURN cCodRet, cMensaje;
			END IF;
			
			IF cReversable = 1 AND iExiste = 1 THEN 		
				EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucursal, pUsuario, pFolio, '') INTO cCodRet;
				IF cCodRet = '000' THEN
					LET cCodRet = '00000';
					UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
					WHERE 	categoria = pCategoria and convenio = pConvenio and folio = pFolio and
							fecha = pFecha and hora = pHora;
				ELSE
					LET cCodRet = '00402';
					LET cMensaje = 'Error: sp_reverso_msw';
					UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
					WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
						fecha = pFecha and hora = pHora;
				END IF;
				--Se reversa  bitacora_aplicapago_hs cConfirma_pago a 0
				UPDATE "informix".bitacora_aplicapago_hs SET confirma_pago = 0
				WHERE categoria = pCategoria and convenio = pConvenio and folio_operacion = pFolio;
			ELSE
				LET cCodRet = '00403';
				LET cMensaje = 'Servicio no permite reverso';
				UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
				 WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
					   fecha = pFecha and hora = pHora;
			END IF;
						
			RETURN cCodRet, cMensaje;
		ELSE
		    LET cCodRet = '00404';
			LET cMensaje = 'Origen Desconocido';
			UPDATE "informix".bitacora_reverso_msw SET codret = cCodRet, Mensaje = cMensaje 
			 WHERE categoria = pCategoria and convenio = pConvenio and folio = pFolio and
				   fecha = pFecha and hora = pHora;
            RETURN cCodRet, cMensaje;
		END IF;
		
	END;
END PROCEDURE;