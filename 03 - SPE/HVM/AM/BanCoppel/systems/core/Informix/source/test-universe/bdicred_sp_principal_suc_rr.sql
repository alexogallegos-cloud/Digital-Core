CREATE PROCEDURE "informix".sp_principal_suc_rr(pEmpresa                  CHAR(3),
												pNumCredito               CHAR(20),
												pProducto 				  CHAR(4),
												pMontoOperacionEfec       DECIMAL(18,2),
												pMontoOperacionCargCuenta DECIMAL(18,2),
												pUsuario 				  CHAR(8),
												pSucursal 				  CHAR(4),
												pFolio 					  CHAR(16),
												pTransaccion 			  CHAR(4),
												pTipoReducePagoAnticipado INTEGER )
RETURNING CHAR(5) AS Cod_Ret,
	CHAR(80)      AS mensaje_Retorno,
	CHAR(20) 	  AS Num_Credito,
	CHAR(20) 	  AS Cuenta_eje,
	CHAR(40) 	  AS Producto,
	CHAR(20) 	  AS Num_Cliente,
	CHAR(150) 	  AS Nom_Cliente,
	DECIMAL(18,2) AS Pago_Efectivo,
	DECIMAL(18,2) AS Pago_Cuenta,
	DECIMAL(18,2) AS Monto_Operacion,
	DECIMAL(18,2) AS Saldo_Actual,
	CHAR(60)      AS Status_Actual,
	SMALLINT      AS flgPagoAnticipado,
	DECIMAL(18,2) AS Saldo_Insoluto;

---DECLARACIONES
DEFINE iSqlErr                      INTEGER;
DEFINE iIsamErr                     INTEGER;
DEFINE cErrorInfo                   CHAR(80);
DEFINE cMensajeRet                  CHAR(80);
DEFINE cCodRet                      CHAR(6);
DEFINE cSucursal             	    CHAR(4);
DEFINE dMontoOperacion        		DECIMAL(18,2);
DEFINE cBanderarespaldo      	    CHAR(1);
DEFINE GLOBAL gRespaldoActivo 		CHAR(1) DEFAULT '1';
DEFINE cTransacc_rel          		CHAR(4);
DEFINE dMontoFinanciado      	    DECIMAL(18,2);
DEFINE dIvaSuc                		DECIMAL(5,3);
DEFINE dMontoInt              		DECIMAL(18,2);
DEFINE dPagoMensualidades     		DECIMAL(18,2);
DEFINE dMontoOperacionEfecAux   	DECIMAL(18,2);
DEFINE dMontoOperacionCargCuentaAux DECIMAL(18,2);
DEFINE GLOBAL g_Transacc    		CHAR(4)        DEFAULT '';
DEFINE GLOBAL g_TransaccSuc 		CHAR(4)        DEFAULT '';
DEFINE g_CodigoFun    				INTEGER;


---VARIABLES DEL PROCESO DE sp_principal_rr
DEFINE cCod_Ret		      CHAR(5);
DEFINE cMensaje_Ret       CHAR(125);
DEFINE dSdo_Ant		      DECIMAL(18,2);
DEFINE dComision	      DECIMAL(18,2);
DEFINE dIva_Com		      DECIMAL(18,2);
DEFINE dInt_Mora	      DECIMAL(18,2);
DEFINE dIva_Int_Mora      DECIMAL(18,2);
DEFINE dInt_Vdo		      DECIMAL(18,2);
DEFINE dIva_Int_Vdo       DECIMAL(18,2);
DEFINE dInt_Ordi          DECIMAL(18,2);
DEFINE dIva_Int_Ordi      DECIMAL(18,2);
DEFINE dCapital		      DECIMAL(18,2);
DEFINE dMonto_Pago        DECIMAL(18,2);
DEFINE cCuenta_Eje        CHAR(20);
DEFINE dSdo_Actual        DECIMAL(18,2);
DEFINE dPago_Min     	  DECIMAL(18,2);
DEFINE cFecha_Limite_Pago CHAR(17);

-- VARIABLES sp_principal_pp
DEFINE cCodigoRetorno_P    CHAR(5);
DEFINE cMensajeRetorno_P   CHAR(125);
DEFINE dSdo_Anterior_P     DECIMAL(18,2);
DEFINE dComision_P         DECIMAL(18,2);
DEFINE dIva_Com_P          DECIMAL(18,2);
DEFINE dInt_Mora_P         DECIMAL(18,2);
DEFINE dIva_Int_Mora_P     DECIMAL(18,2);
DEFINE dInt_Vdo_P          DECIMAL(18,2);
DEFINE dIva_Int_Vdo_P      DECIMAL(18,2);
DEFINE dInt_Ordi_P         DECIMAL(18,2);
DEFINE dIva_Int_Ordi_P     DECIMAL(18,2);
DEFINE dCapital_P          DECIMAL(18,2);
DEFINE dMonto_Pago_P       DECIMAL(18,2);
DEFINE cCuenta_Eje_P       CHAR(20);
DEFINE dSdoActual_P        DECIMAL(18,2);
DEFINE dPago_Min_P         DECIMAL(18,2);
DEFINE cFecha_LimitePago_P CHAR(17);

-- VARIABLES  sp_pago_anticipado_pp
DEFINE cCod_Retorno_Ap       CHAR(5);
DEFINE cMens_Ret          	 CHAR(125);
DEFINE dSdo_Anterior         DECIMAL(18,2);
DEFINE dComision_Ap          DECIMAL(18,2);
DEFINE dIva_Com_Ap           DECIMAL(18,2);
DEFINE dInt_Mora_Ap          DECIMAL(18,2);
DEFINE dIva_Int_Mora_Ap      DECIMAL(18,2);
DEFINE dInt_Vdo_Ap           DECIMAL(18,2);
DEFINE dIva_Int_Vdo_Ap       DECIMAL(18,2);
DEFINE dInt_Ordi_Ap          DECIMAL(18,2);
DEFINE dIva_Int_Ordi_Ap      DECIMAL(18,2);
DEFINE dCapital_Ap           DECIMAL(18,2);
DEFINE dMonto_Pago_Ap        DECIMAL(18,2);
DEFINE cCuenta_Eje_Ap        CHAR(20);
DEFINE dSdo_Act_Ap           DECIMAL(18,2);
DEFINE dPago_Min_Ap          DECIMAL(18,2);
DEFINE cFecha_Limite_Pago_Ap CHAR(17);

DEFINE cCodRetCD	  CHAR(6);
DEFINE cMensajeCD 	  CHAR(80);
DEFINE cNumCredCD 	  CHAR(20);
DEFINE cNumCteCD 	  CHAR(20);
DEFINE cNomProductoCD CHAR(40);
DEFINE cNumTarjetaCD  CHAR(20);
DEFINE cNomCteCD      CHAR(150);

--VARIABLES para sp_consulta_saldos_general
DEFINE cCodRetSP			 CHAR(6);
DEFINE cMensajeSP			 CHAR(80);
DEFINE cNumCredito      	 CHAR(20);
DEFINE cCodTipCred      	 CHAR(2);
DEFINE cDescStatusCred  	 CHAR(60);
DEFINE iIdUnidadProd     	 INTEGER;
DEFINE cCodCaract2       	 CHAR(3);
DEFINE dtFechaOrigen    	 DATE;
DEFINE dtFechaProxPago  	 DATE;
DEFINE dPagoMinimo      	 DECIMAL(18,2);
DEFINE dtFechaUltPago    	 DATE;
DEFINE iPlazo           	 INTEGER;
DEFINE iPagosRealizados 	 INTEGER;
DEFINE dLineaOtorgada    	 DECIMAL(18,2);
DEFINE dTasaInteres      	 DECIMAL(9,6);
DEFINE dTasaMoratorios  	 DECIMAL(9,6);
DEFINE dMontoSBC        	 DECIMAL(14,2);
DEFINE dCapVig           	 DECIMAL(18,2);
DEFINE dCapTrans         	 DECIMAL(18,2);
DEFINE dCapVdoExig       	 DECIMAL(18,2);
DEFINE dCapVdoNoExig    	 DECIMAL(18,2);
DEFINE dSdoActCap        	 DECIMAL(18,2);
DEFINE dIntVig           	 DECIMAL(18,2);
DEFINE dIntVdo           	 DECIMAL(18,2);
DEFINE dIntMoratorio     	 DECIMAL(18,2);
DEFINE dIntMes          	 DECIMAL(18,2);
DEFINE dSdoActInt        	 DECIMAL(18,2);
DEFINE dIvaIntVig        	 DECIMAL(18,2);
DEFINE dIvaIntVdo        	 DECIMAL(18,2);
DEFINE dIvaIntMoratorio  	 DECIMAL(18,2);
DEFINE dIvaIntMes        	 DECIMAL(18,2);
DEFINE dSdoActIvaInt     	 DECIMAL(18,2);
DEFINE dComPend          	 DECIMAL(18,2);
DEFINE dIvaCom            	 DECIMAL(18,2);
DEFINE dSdoRetenido     	 DECIMAL(18,2);
DEFINE dSdoTotalLiq     	 DECIMAL(18,2);
DEFINE dIntDevengado         DECIMAL(18,2);
DEFINE dIvaIntDevengado      DECIMAL(18,2);
DEFINE dLineaDisponible      DECIMAL(18,2);
DEFINE dPagosVdos            DECIMAL(18,2);
DEFINE cDescBloqueoCta       CHAR(60);
DEFINE cDescCausaBloqueoCta  CHAR(50);
DEFINE cSitCte               CHAR(1);
DEFINE iCausaCte             INTEGER;
DEFINE cDescSitEspCte        CHAR(75);
DEFINE cSitCred              CHAR(1);
DEFINE iCausaCred            INTEGER;
DEFINE cDescSitEspCred       CHAR(75);
DEFINE iAplicoPago           INTEGER;

-- DSB  - TH - EM -2017-03-16
DEFINE dMontoAux 			 DECIMAL(18,2);
DEFINE dtFechaActual	  	 DATE;
DEFINE dFechaAmortiza    	 DATE;
DEFINE mMensualidad          DECIMAL(18,2);
DEFINE iFlaPagoAnticipado    INTEGER;
DEFINE cCodigoFunth      	 CHAR(3);
DEFINE g_TransaccAnt		 CHAR(4);
DEFINE cCodRetAux		CHAR(6);
DEFINE dNumCredito      CHAR(20);
DEFINE mMontoEfec     MONEY(14,2);
DEFINE mMontoCargo    MONEY(14,2);
DEFINE mMonto		  MONEY(14,2);
DEFINE v_iva_cs       DECIMAL(14,2);
DEFINE cfolio_mov     CHAR(16);
DEFINE c_Folio_Suc		  CHAR(16);
--AAME Quita Validacion If exits select por variables 21052018
DEFINE cnumcredisol   CHAR(20);
DEFINE ccapital_status CHAR(1);
DEFINE vNumCte         CHAR(20); --RQM 10 915-4
DEFINE vNumCel         CHAR(13); --RQM 10 915-4
DEFINE vFecha          CHAR(10); --RQM 10 915-4
DEFINE vstcred         CHAR(2); --RQM 10 915-4
DEFINE vMontoPago      DECIMAL(18,2); --RQM 10 915-4
DEFINE banderaApoyo		SMALLINT;
---- CONDONACIONES Y QUITAS 
DEFINE indicaQuitaCondona	CHAR (1);
DEFINE montoQuita			DECIMAL(18,2);
DEFINE montoCondona			DECIMAL(18,2);
DEFINE bandera_quita_restante	SMALLINT;
DEFINE monto_condona			DECIMAL(18,2);
DEFINE monto_qc				DECIMAL(18,2);
DEFINE totalquitacapvenc    DECIMAL(18,2);
DEFINE status_cred_quita	CHAR(2);
DEFINE p_Divisa             CHAR(2);
DEFINE dFechaCuota			DATE;
DEFINE monto_balanza		DECIMAL(18,2);
DEFINE monto_orden			DECIMAL(18,2);
DEFINE condona_accesorios 	DECIMAL(18,2);
DEFINE GLOBAL gprocesa 		INT        DEFAULT 0;
DEFINE vFechaVencCred		DATE;
DEFINE cTranPFSI_aux		CHAR(4);
DEFINE cEnvioSMSRespMultic	CHAR(1);
DEFINE cbanfamilia			 CHAR(3); -- RQM 10 1177
DEFINE ATR_Cred    INTEGER;
DEFINE iPagosVencidos    INTEGER;

DEFINE vMesesVencidos		SMALLINT;
DEFINE vMesesHistoria		INTEGER;
DEFINE dMontoOtorgado   	DECIMAL(18,2);
DEFINE vIntVencido          MONEY(18,2);
DEFINE vIvaIntVigente		DECIMAL(14,2);
DEFINE vIvaIntVencido		DECIMAL(14,2); --RQM 09 459
DEFINE vCapitalMtoCuota		DECIMAL(14,2);
DEFINE vSdoCredito			DECIMAL(18,2);
DEFINE vIntMoratorio        MONEY(18,2); --RQM 09 459
DEFINE dSdoCapInsoluto      DECIMAL(14,2); 

DEFINE dFechapago   		DATE;  
DEFINE dFechaUltMov 		DATE; 
DEFINE dFechanegociacion    DATE;
DEFINE dPagorealizado       DECIMAL(14,2);
DEFINE dPagoParcial         DECIMAL(14,2);

DEFINE vSaldoInsoluto         DECIMAL(14,2);
DEFINE vflgpagoanticipado   SMALLINT;
DEFINE vsaldoins DECIMAL(14,2);
DEFINE flgpagoanticipado SMALLINT;

DEFINE wBegin           CHAR(1);

--INICIALIZACIONES
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = '';
LET cMensajeRet     = 'PROCESO EXITOSO';
LET cCodRet         = '00000';
LET cSucursal       = '';
LET dMontoOperacion = 0;
LET g_Transacc      = pTransaccion;
LET cTransacc_rel   = '';

LET dMontoFinanciado     		 = 0;
LET dIvaSuc              		 = 0;
LET dMontoInt            		 = 0;
LET dPagoMensualidades           = 0;
LET dMontoOperacionEfecAux       = pMontoOperacionEfec;
LET dMontoOperacionCargCuentaAux = pMontoOperacionCargCuenta;
LET g_CodigoFun					 = 0;

--VARIABLES DEL PROCESO DE sp_principal_rr
LET cCod_Ret		   = '';
LET cMensaje_Ret       = '';
LET dSdo_Ant		   = 0.0;
LET dComision		   = 0.0;
LET dIva_Com		   = 0.0;
LET dInt_Mora		   = 0.0;
LET dIva_Int_Mora      = 0.0;
LET dInt_Vdo		   = 0.0;
LET dIva_Int_Vdo       = 0.0;
LET dInt_Ordi          = 0.0;
LET dIva_Int_Ordi      = 0.0;
LET dCapital		   = 0.0;
LET dMonto_Pago        = 0.0;
LET cCuenta_Eje        = '';
LET dSdo_Actual        = 0.0;
LET dPago_Min          = 0.0;
LET cFecha_Limite_Pago = '';

--VARIABLES sp_principal_pp
LET cCodigoRetorno_P    = '00000';
LET cMensajeRetorno_P   = '';
LET dSdo_Anterior_P     = 0;
LET dComision_P         = 0;
LET dIva_Com_P          = 0;
LET dInt_Mora_P         = 0;
LET dIva_Int_Mora_P     = 0;
LET dInt_Vdo_P          = 0;
LET dIva_Int_Vdo_P      = 0;
LET dInt_Ordi_P         = 0;
LET dIva_Int_Ordi_P     = 0;
LET dCapital_P          = 0;
LET dMonto_Pago_P       = 0;
LET cCuenta_Eje_P       = 0;
LET dSdoActual_P        = 0;
LET dPago_Min_P         = 0;
LET cFecha_LimitePago_P = '';

-- VARIABLES sp_pago_anticipado_ppsr y sp_pago_anticipado_pp
LET cCod_Retorno_Ap          = '00000';
LET cMens_Ret             = '';
LET dSdo_Anterior         = 0;
LET dComision_Ap          = 0;
LET dIva_Com_Ap           = 0;
LET dInt_Mora_Ap          = 0;
LET dIva_Int_Mora_Ap      = 0;
LET dInt_Vdo_Ap           = 0;
LET dIva_Int_Vdo_Ap       = 0;
LET dInt_Ordi_Ap          = 0;
LET dIva_Int_Ordi_Ap      = 0;
LET dCapital_Ap           = 0;
LET dMonto_Pago_Ap        = 0;
LET cCuenta_Eje_Ap        = '';
LET dSdo_Act_Ap           = 0;
LET dPago_Min_Ap          = 0;
LET cFecha_Limite_Pago_Ap = '';

LET cCodRetCD			= '';
LET cMensajeCD 			= '';
LET cNumCredCD 			= '';
LET cNumCteCD 			= '';
LET cNomProductoCD		= '';
LET cNumTarjetaCD    	= '';
LET cNomCteCD     		= '';
LET gRespaldoActivo    	= '0';
LET cBanderarespaldo	= '1';

--INICIALIZACIONES PARA sp_consulta_saldos_general
LET cCodRetSP             = '';
LET cMensajeSP			  = '';
LET cNumCredito      	  = '';
LET cCodTipCred      	  = '';
LET cDescStatusCred  	  = '';
LET iIdUnidadProd     	  = 0;
LET cCodCaract2       	  = '';
LET dtFechaOrigen    	  = DATE(1);
LET dtFechaProxPago  	  = DATE(1);
LET dPagoMinimo      	  = 0;
LET dtFechaUltPago    	  = DATE(1);
LET iPlazo           	  = 0;
LET iPagosRealizados 	  = 0;
LET dLineaOtorgada    	  = 0;
LET dTasaInteres      	  = 0;
LET dTasaMoratorios  	  = 0;
LET dMontoSBC        	  = 0;
LET dCapVig           	  = 0;
LET dCapTrans         	  = 0;
LET dCapVdoExig       	  = 0;
LET dCapVdoNoExig    	  = 0;
LET dSdoActCap        	  = 0;
LET dIntVig           	  = 0;
LET dIntVdo           	  = 0;
LET dIntMoratorio     	  = 0;
LET dIntMes          	  = 0;
LET dSdoActInt        	  = 0;
LET dIvaIntVig        	  = 0;
LET dIvaIntVdo        	  = 0;
LET dIvaIntMoratorio  	  = 0;
LET dIvaIntMes        	  = 0;
LET dSdoActIvaInt     	  = 0;
LET dComPend          	  = 0;
LET dIvaCom            	  = 0;
LET dSdoRetenido     	  = 0;
LET dSdoTotalLiq     	  = 0;
LET dIntDevengado         = 0;
LET dIvaIntDevengado      = 0;
LET dLineaDisponible      = 0;
LET dPagosVdos            = 0;
LET cDescBloqueoCta       = '';
LET cDescCausaBloqueoCta  = '';
LET cSitCte               = '';
LET iCausaCte             = 0;
LET cDescSitEspCte        = '';
LET cSitCred              = '';
LET iCausaCred            = 0;
LET cDescSitEspCred       = '';
LET iAplicoPago           = 0;

-- DSB - TH - EM - 2017-03-16
LET dMontoAux 			= pMontoOperacionEfec + pMontoOperacionCargCuenta;
LET dtFechaActual  	 	= DATE(1);
LET dFechaAmortiza    	= DATE(1);
LET mMensualidad        = 0;
LET iFlaPagoAnticipado  = 0;
LET g_TransaccAnt       = '';
LET cCodRetAux			= '';
LET mMontoEfec          = 0;
LET mMontoCargo         = 0;
LET mMonto		        = 0;
LET v_iva_cs            = 0;
LET cfolio_mov          = "";
LET c_Folio_Suc     ='';
--AAME Quita Validacion If exits select por variables 21052018
LET cnumcredisol        = '';
LET ccapital_status 	= '';
LET vNumCte             = ''; --RQM 10 915-4
LET vNumCel             = ''; --RQM 10 915-4
LET vFecha              = ''; --RQM 10 915-4
LET vstcred             = ''; --RQM 10 915-4
LET vMontoPago          = 0; --RQM 10 915-4

LET banderaApoyo		= 0;
---- CONDONACIONES Y QUITAS 
LET indicaQuitaCondona	= '';
LET montoQuita			= 0;
LET montoCondona		= 0;
LET bandera_quita_restante = 0;
LET monto_condona			= 0;
LET monto_qc			= 0;
LET totalquitacapvenc   = 0;
LET status_cred_quita	= 0;
LET p_Divisa			= '';
LET dFechaCuota			= DATE(1);
LET monto_balanza		= 0;
LET monto_orden			= 0;
LET condona_accesorios	= 0;
LET vFechaVencCred		= DATE (1);
-- LET gprocesa				= 0;	--- variable global que valida si procesa capital para quitas
LET cTranPFSI_aux		= '';
LET cEnvioSMSRespMultic	= '';
LET cbanfamilia				= ''; -- RQM 10 1177
LET ATR_Cred  =0;
LET iPagosVencidos = 0;
--RQM 09 459
LET vMesesVencidos		= 0;
LET vMesesHistoria		= 0;
LET dMontoOtorgado  	= 0;
LET vIntVencido 		= 0;
LET vIvaIntVigente		= 0;
LET vIvaIntVencido		= 0;
LET vCapitalMtoCuota	= 0;
LET vSdoCredito			= 0;
LET vIntMoratorio 		= 0; --RQM 09 459
LET dSdoCapInsoluto     = 0;

LET dFechapago          = DATE (1);
LET dFechaUltMov        = DATE (1);
LET dFechanegociacion   = DATE (1);
LET dPagorealizado      = 0;
LET dPagoParcial        = 0;

LET vSaldoInsoluto       = 0;
LET vflgpagoanticipado   = 0;
LET vsaldoins = 0;
LET flgpagoanticipado = 0;
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
		  LET cMensajeRet  = cErrorInfo;
          RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
       END IF;
    END EXCEPTION;
  
    SELECT fecha_hoy
	INTO dtFechaActual
	FROM  bdicred:"informix".sd_fechas;
		
	SELECT status_cred,divisa,fecha_vencim
	INTO status_cred_quita,p_Divisa,vFechaVencCred
	FROM bdicred:sd_maecredcrd
	WHERE num_credito = pNumCredito;	
	---- realiza consulta para validar si es quita, condonacion o quita por operaciones
	SELECT indicador_proceso,mto_quita,monto_condonado,fecha_negociacion --,NVL(saldo_tot_liquidar,0)
		INTO indicaQuitaCondona,montoQuita,montoCondona,dFechanegociacion --, totalquitacapvenc
	FROM bdicred:sd_bitacora_quitacondonacion
	WHERE num_credito = pNumCredito
	AND estatus_proceso = 'PR';	
	--AND fecha_negociacion >= dtFechaActual;

	IF indicaQuitaCondona IS NULL OR indicaQuitaCondona = '' THEN
		LET indicaQuitaCondona = '';
	END IF;
	
	IF montoQuita IS NULL OR montoQuita = '' THEN
		LET montoQuita = 0;
	END IF;
	
	IF montoCondona IS NULL OR montoCondona = '' THEN
		LET montoCondona = 0;
	END IF;
	IF dFechanegociacion IS NULL OR dFechanegociacion ='' THEN
		LET dFechanegociacion   = DATE (1);
	END IF;
	
    LET monto_qc = montoQuita + montoCondona;
	-- VALIDA LOS PARAMETROS DE ENTRADA
	--- se agrega validacion para que no mande error cuando es quita operativa, pueda mandar pago cero	
	IF NVL(pEmpresa,'') = '' OR NVL(pNumCredito,'') = '' OR NVL(pUsuario,'') = ''
	OR NVL(pSucursal,'') = ''   OR NVL(pFolio,'') = ''  OR NVL(g_Transacc,'') = ''
	OR (NVL(pMontoOperacionEfec,0) = 0 AND NVL(pMontoOperacionCargCuenta,0) = 0 AND indicaQuitaCondona NOT IN ('O','U')) THEN
		LET cCodRet = '00361';
		LET cMensajeRet  = 'PARAMETROS INVALIDOS';
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
	END IF;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pTransaccion = '8654' THEN	-- Banderas para cargo sdo a favor en tdc para PG Sdo Inmediato
		LET cTranPFSI_aux = 'PFSI';
	END IF;

	LET g_TransaccSuc = LPAD(pTransaccion,4,'0');
    
	SELECT NVL(transacc,''),cod_fun --,NVL(transacc_rel,"")
	INTO g_Transacc,g_CodigoFun --, cTransacc_rel
	FROM bdicred:"informix".sd_conceptospagomanualcrd
	WHERE transacc_suc = g_TransaccSuc
	AND num_producto = pProducto;
	
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
	   LET cCodRet     = '00189';
	   LET cMensajeRet = 'Transaccion incorrecta';
	   RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,0,0;
	END IF;
	
	-- --AAME RQM 10 1177 Se modifica para consultar por parametro los productos por familia en caso de ser mas de 1 SE OBTIENE LA FAMILIA DEL PRODUCTO
	SELECT familia
	INTO cbanfamilia
	FROM  "informix".sd_definicion 
	WHERE empresa = pEmpresa AND num_producto = pProducto;
	
	LET vMontoPago = pMontoOperacionEfec+pMontoOperacionCargCuenta; --RQM 10 915-4

	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
	   LET cCodRet     = '00189';
	   LET cMensajeRet = 'Transaccion incorrecta';
	   RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
	END IF;


	SELECT mensualidad INTO mMensualidad
	FROM bdicred:"informix".sd_promocion_credito
	WHERE num_sol_prestamo = pNumCredito
	AND empresa = pEmpresa;


	LET g_Transacc = g_Transacc;
	LET vMontoPago = vMontoPago;
	LET indicaQuitaCondona = indicaQuitaCondona;
	LET status_cred_quita = status_cred_quita;
	
	IF pProducto = '6800' THEN		-- Identifica el envio de sms o no
		IF g_Transacc = '7590' THEN
			--SELECT FIRST 1 trim(valor_alfabetico) INTO cEnvioSMSRespMultic 
			  --FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 6 AND grupo_parametro = 'PFLEX_MLTC' AND num_parametro = 2; -- atm
			LET cEnvioSMSRespMultic = '0';
			 
		ELIF g_Transacc = '8738' THEN
			--SELECT FIRST 1 trim(valor_alfabetico) INTO cEnvioSMSRespMultic 
			  --FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 6 AND grupo_parametro = 'PFLEX_MLTC' AND num_parametro = 3; -- whats
			  LET cEnvioSMSRespMultic = '0';

		ELIF g_Transacc = '8317'	THEN
			--SELECT FIRST 1 trim(valor_alfabetico) INTO cEnvioSMSRespMultic 
			  --FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 6 AND grupo_parametro = 'PFLEX_MLTC' AND num_parametro = 1; -- sms
			  LET cEnvioSMSRespMultic = '0';
		ELIF g_Transacc	= '5025' THEN
			--SELECT FIRST 1 trim(valor_alfabetico) INTO cEnvioSMSRespMultic 
			  --FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 6 AND grupo_parametro = 'PFLEX_MLTC' AND num_parametro = 4; -- app
			  LET cEnvioSMSRespMultic = '0';
		ELIF g_Transacc	= '7506' THEN
			  LET cEnvioSMSRespMultic = '0';		
		ELSE	   
			  LET cEnvioSMSRespMultic = '1';
		END IF;
	END IF;

		SELECT NVL(atr,0),mto_fin_ven_trasp
			INTO ATR_Cred ,iPagosVencidos
			FROM bdicred:"informix".sd_maesdoscrd 
			WHERE num_credito = pNumCredito
			AND empresa       = pEmpresa;
			

	--- Validacion para Quita, Condonacion, O = Quita de Operaciones sin cancelcion de linea de PD, U = Quita Operacion con cancelacion si es PD
	IF g_Transacc NOT IN ('8671','8701') AND vMontoPago >= monto_qc  AND dFechanegociacion >= dtFechaActual
		--AND  ((indicaQuitaCondona = 'Q' AND status_cred_quita in ('BT')) OR (indicaQuitaCondona = 'C' AND status_cred_quita in ('BT','BA')))
		AND  ((indicaQuitaCondona = 'Q' AND (status_cred_quita in ('BT') OR status_cred_quita in ('E3')) ) 
		OR (indicaQuitaCondona = 'C' AND ((status_cred_quita in ('BT','BA')) OR (status_cred_quita in ('E1','E2','E3') and ATR_Cred>0))  )
		OR ((pProducto = '6011' AND indicaQuitaCondona = 'C' AND iPagosVencidos >= 1) 
		OR ( pProducto = '6011' AND indicaQuitaCondona = 'Q' AND iPagosVencidos >= 5) )) -- se agrega validacion por IFRS AEH
		OR (g_Transacc NOT IN ('8671','8701') AND (indicaQuitaCondona IN ('O','U') )) THEN 
	 --	IF pProducto IN ('6300','7600','7700','6800','6011') THEN --PRESTAMO 12 18 y 24, PRESTAMO DIGITAL
		
		EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa,pNumCredito)
		INTO cCodRetSP,cMensajeSP,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,
			dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans,dCapVdoExig,dCapVdoNoExig,dSdoActCap,dIntVig,dIntVdo,dIntMoratorio,dIntMes,dSdoActInt,dIvaIntVig,dIvaIntVdo,dIvaIntMoratorio, dIvaIntMes,dSdoActIvaInt,
			dComPend,dIvaCom,dSdoRetenido,dSdoTotalLiq,dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,cDescStatusCred,iIdUnidadProd,cDescBloqueoCta,cCodCaract2,cDescCausaBloqueoCta, cSitCte,
			iCausaCte,cDescSitEspCte,cSitCred,iCausaCred,cDescSitEspCred;
		IF cCodRetSP <> '000000' THEN
			LET cCodRet = cCodRetSP;
			LET cMensajeRet= cMensajeSP;
		END IF;

		UPDATE "informix".sd_bitacora_quitacondonacion 
			SET pago_realizado = vMontoPago,int_vencido = dIntVdo,iva_int_vencido = dIvaIntVdo, cap_vigente = dCapVig, iva_int_vigente = dIvaIntVig,
			cap_vigente_cq = NVL(dCapVig,0), iva_int_vigente_cq =  dIvaIntVig,
			int_moratorio = dIntMoratorio, iva_int_mora = dIvaIntMoratorio,int_vigente_cq =  dIntVig,
			int_vencido_cq = dIntVdo,iva_int_vencido_cq = dIvaIntVdo,
			int_moratorio_cq = dIntMoratorio, iva_int_mora_cq = dIvaIntMoratorio,
			cap_vencido = dCapVdoExig, int_vigente = dIntVig, cap_vencido_cq = dCapVdoExig,
            -----------------------------------------------------------------------	 		
			meses_vencidos = dPagosVdos, copete_moratorio = NVL(dIntMoratorio,0) + NVL(dIvaIntMoratorio,0), 
			saldo_tot_liquidar = dSdoTotalLiq WHERE num_credito = pNumCredito and estatus_proceso='PR';
			-----------------------------------------------------------------------	
COMMIT;
BEGIN;	
		IF pProducto NOT IN ('6011','8600') THEN

			---- total balanza
			SELECT SUM(interes_debe - interes_pagado + iva_debe - iva_pagado) 
			into monto_orden
			---into monto_balanza
			FROM  bdicred:sd_amortiza_creditocrd
			WHERE campo_trabajo3 = 'V'		---- V es Orden
			and capital_status = '2'
			AND num_credito = pNumCredito;
				
			---- total orden
			SELECT SUM(interes_debe - interes_pagado + iva_debe - iva_pagado) 
			into monto_balanza
			--- into monto_orden
			FROM  bdicred:sd_amortiza_creditocrd
			WHERE campo_trabajo3 <> 'V'		--- diferente de V es balanza
			and capital_status = '2'
			AND num_credito = pNumCredito;

			IF monto_balanza IS NULL THEN LET monto_balanza = 0; END IF;
			IF monto_orden IS NULL THEN LET monto_orden = 0; END IF;
							
	 --			LET condona_accesorios = dIntMoratorio + dIvaIntMoratorio + monto_balanza;
			LET condona_accesorios = dIntMoratorio + dIvaIntMoratorio + monto_orden;
		
			IF vMontoPago < dSdoTotalLiq THEN
					--- si el monto efectivo es mayor a capital e interes de orden, solo se condonana moratorios y lo que alcance de vencidos.
				IF vMontoPago > dSdoActCap + monto_balanza THEN

					LET condona_accesorios = dSdoTotalLiq - vMontoPago;	 -- 	- (vMontoPago - (dSdoActCap + monto_balanza));
					IF condona_accesorios > 0 THEN	---- aplica pago de accesorios que logre pagar
						LET gprocesa = 1;
						
						EXECUTE PROCEDURE bdicred:"informix".sp_principal_pp (pEmpresa,pNumCredito,1,condona_accesorios,pUsuario,pSucursal,pFolio,'8671')
							INTO cCodigoRetorno_P,cMensajeRetorno_P,dSdo_Anterior_P,dComision_P,dIva_Com_P,dInt_Mora_P,dIva_Int_Mora_P,dInt_Vdo_P,dIva_Int_Vdo_P,dInt_Ordi_P,dIva_Int_Ordi_P,dCapital_P,dMonto_Pago_P, cCuenta_Eje_P,dSdoActual_P,dPago_Min_P,cFecha_LimitePago_P;

					END IF;
				ELSE	
					--- Cuando no cubre capitales e int balanza, entonces no alcanza.. se condona al 100%				
					IF condona_accesorios > 0 THEN
						LET gprocesa = 1;
						EXECUTE PROCEDURE bdicred:"informix".sp_principal_pp (pEmpresa,pNumCredito,1,condona_accesorios,pUsuario,pSucursal,pFolio,'8671')
							INTO cCodigoRetorno_P,cMensajeRetorno_P,dSdo_Anterior_P,dComision_P,dIva_Com_P,dInt_Mora_P,dIva_Int_Mora_P,dInt_Vdo_P,dIva_Int_Vdo_P,dInt_Ordi_P,dIva_Int_Ordi_P,dCapital_P,dMonto_Pago_P, cCuenta_Eje_P,dSdoActual_P,dPago_Min_P,cFecha_LimitePago_P;

					END IF;	
				
				END IF;
			END IF;
		ELSE

			LET condona_accesorios = dSdoTotalLiq - dSdoActCap;
			----- QUITA DE REESTRUCTURAS  
			IF vMontoPago < dSdoTotalLiq THEN
					--- si el monto efectivo es mayor a capital e interes de orden, solo se condonana moratorios y lo que alcance de vencidos.
				IF vMontoPago > dSdoActCap THEN
				
					LET condona_accesorios = dSdoTotalLiq - vMontoPago;
					
					IF condona_accesorios > 0 THEN	---- aplica pago de accesorios y capital que logre pagar
						LET gprocesa = 1;
						EXECUTE PROCEDURE bdicred:"informix".sp_principal_rr
						(pEmpresa,pNumCredito,1,condona_accesorios,pUsuario,pSucursal,pFolio,'8701')
						INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

					END IF;
				ELSE	
					--- Cuando no cubre capitales e int balanza, entonces no alcanza.. se condona al 100%	
					IF condona_accesorios > 0 THEN
						LET gprocesa = 1;
						EXECUTE PROCEDURE bdicred:"informix".sp_principal_rr
						(pEmpresa,pNumCredito,1,condona_accesorios,pUsuario,pSucursal,pFolio,'8701')
						INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

					END IF;	
				END IF;
			END IF;

		END IF;
				LET g_TransaccSuc = LPAD(pTransaccion,4,'0');
				SELECT NVL(transacc,''),cod_fun --,NVL(transacc_rel,"")
				INTO g_Transacc,g_CodigoFun --, cTransacc_rel
				FROM bdicred:"informix".sd_conceptospagomanualcrd
				WHERE transacc_suc = g_TransaccSuc
				AND num_producto = pProducto;
				
				--- Apaga respaldo
				IF condona_accesorios > 0  THEN
					LET gRespaldoActivo = '1';
					LET gprocesa = 2;
				END IF;
	     --Si el pago es menor al monto quita/condonado y la fecha de pago sea menor o igual a la fecha negociacion se actualiza el pago en la bitacora
	    ELIF g_Transacc NOT IN ('8671','8701') AND vMontoPago < monto_qc  AND dFechanegociacion >= dtFechaActual
		   AND  ((indicaQuitaCondona = 'Q' AND (status_cred_quita in ('BT') OR status_cred_quita in ('E3')) ) 
		   OR (indicaQuitaCondona = 'C' AND ((status_cred_quita in ('BT','BA')) OR (status_cred_quita in ('E1','E2','E3')))  ) 
		   OR ((pProducto = '6011' AND indicaQuitaCondona = 'C' AND iPagosVencidos >= 1) 
		   OR (pProducto = '6011' AND indicaQuitaCondona = 'Q' AND iPagosVencidos >= 5) ))    THEN
		 
             UPDATE "informix".sd_bitacora_quitacondonacion 
			  SET pago_realizado = vMontoPago
             WHERE num_credito = pNumCredito and estatus_proceso='PR';
		  COMMIT;	
		  BEGIN; 
		
			LET indicaQuitaCondona = '';
		
		ELIF dFechanegociacion < dtFechaActual AND g_Transacc NOT IN ('8671','8701') AND ((indicaQuitaCondona = 'Q' AND (status_cred_quita in ('BT') OR status_cred_quita in ('E3')) ) 
		     OR (indicaQuitaCondona = 'C' AND ((status_cred_quita in ('BT','BA')) OR (status_cred_quita in ('E1','E2','E3')))  ) 		
		     OR ((pProducto = '6011' AND indicaQuitaCondona = 'C' AND iPagosVencidos >= 1) 
			 OR (pProducto = '6011' AND indicaQuitaCondona = 'Q' AND iPagosVencidos >= 5))) THEN
		
		    UPDATE "informix".sd_bitacora_quitacondonacion 
			  SET estatus_proceso = 'CN',fecha_status = dtFechaActual
            WHERE num_credito = pNumCredito and estatus_proceso='PR';
		COMMIT;	
		BEGIN; 
			LET indicaQuitaCondona = '';
		   
	ELSE
		-- Si no pasa por el flujo y variable global esta activa no realiza respaldo, prepara el anticipo de quita
			LET indicaQuitaCondona = '';
			IF gprocesa = 2 THEN
				LET gRespaldoActivo = '1';
			END IF;
	END IF;

	--AAME Quita Validacion If exits select por variables 21052018
		SELECT limit 1 NVL(a.capital_status,'')
		INTO ccapital_status
		FROM bdicred:"informix".sd_amortiza_creditocrd a
		WHERE a.empresa = pEmpresa
		AND a.num_credito = pNumCredito
		AND a.capital_status IN ('1','2','7','6');
		
		IF NVL(ccapital_status,'') = '' THEN
			SELECT limit 1 NVL(a.capital_status,'')
			INTO ccapital_status
			FROM bdicred:"informix".sd_amortiza_creditocrd a
			WHERE a.empresa     = pEmpresa
			AND a.num_credito = pNumCredito
			AND a.capital_status IN ('3');
		END IF;

	 --se valida si se va realizar un pago normal.
	IF ccapital_status IN ('1','2','7','6') THEN --AAME Quita Validacion If exits select por variables 21052018

		--se obtiene la informacion del  cliente
		SELECT  a.sucursal, b.monto_financiado, round((today - a.fecha_apertura)/30.4)
		INTO  cSucursal, dMontoFinanciado, vMesesHistoria
		FROM bdicred:"informix".sd_maecredcrd a,
		bdicred:"informix".sd_maesdoscrd b,
		bdicred:"informix".sd_maecredanexocrd c
		WHERE a.num_credito = pNumCredito
		AND a.empresa       = pEmpresa
		AND b.empresa       = a.empresa
		AND b.num_credito   = a.num_credito
		AND c.num_credito   = b.num_credito
		AND c.empresa       = b.empresa;

		SELECT iva
		INTO dIvaSuc
		FROM bdinteg:"informix".si_sucursales
		WHERE empresa = pEmpresa
		AND sucursal  = cSucursal;

		-- 2011-11-30 Se cambia metodo de calculo de moratorio
		SELECT SUM(interes_debe - interes_pagado + iva_debe - iva_pagado + mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag) +	(SUM(round((mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag)*dIvaSuc,2)))
		INTO dMontoInt
		FROM bdicred:"informix".sd_amortiza_creditocrd
		WHERE empresa = pEmpresa
		AND num_credito = pNumCredito
		AND capital_status IN ('2','7','1','6');

		LET dMontoFinanciado = dMontoFinanciado + dMontoInt;
		---- se agrega transacciones de quitas solo para pago en efectivo
		IF g_Transacc IN ('7970','8205','8160','8286', '7990','8335','8671','8701','8654','4320')  THEN--pago en efectivo --DSB 20/11/2015 se Agrega la Transaccion 8160 --- 8335 SPEI

			IF pMontoOperacionEfec <= dMontoFinanciado THEN
				LET dPagoMensualidades = pMontoOperacionEfec;
				LET dMontoFinanciado = dMontoFinanciado - pMontoOperacionEfec;
				LET pMontoOperacionEfec = 0;
			ELSE
				LET dPagoMensualidades = dMontoFinanciado;
				LET pMontoOperacionEfec = pMontoOperacionEfec - dPagoMensualidades;
				LET dMontoFinanciado =0;
			END IF;

			IF pProducto IN ('6011','8600') THEN --REESTRUCTURAS
				EXECUTE PROCEDURE bdicred:"informix".sp_principal_rr
				(pEmpresa,pNumCredito,1,dPagoMensualidades,pUsuario,pSucursal,pFolio,g_Transacc)
				INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

				IF cCod_Ret::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A')
					INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
					END IF;
					LET cCodRet      = cCod_Ret;
					LET cMensajeRet  = cMensaje_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
				END IF;
				LET dSdo_Actual = dSdo_Actual;
				LET cCuenta_Eje = cCuenta_Eje;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
				LET dPagoMensualidades = 0;
			--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
			--- Se agrega variable para indicar si el pago es mayor a cero de lo contrario mandara error el sp principal pp
			--ELIF pProducto IN ('6300','6400','7600','7700','6800','6900') AND dPagoMensualidades > 0 THEN --PRESTAMO,NOMINA,FLEXIBLE,MONTOS_DIFERIDOS
																								  
			ELIF (cbanfamilia IN ('002','003') OR pProducto='6900') AND dPagoMensualidades > 0 THEN --PRESTAMO,NOMINA,FLEXIBLE,MONTOS_DIFERIDOS	
				EXECUTE PROCEDURE bdicred:"informix".sp_principal_pp (pEmpresa,pNumCredito,1,dPagoMensualidades,pUsuario,pSucursal,pFolio,g_Transacc)
				INTO cCodigoRetorno_P,cMensajeRetorno_P,dSdo_Anterior_P,dComision_P,dIva_Com_P,dInt_Mora_P,dIva_Int_Mora_P,dInt_Vdo_P,dIva_Int_Vdo_P,dInt_Ordi_P,dIva_Int_Ordi_P,dCapital_P,dMonto_Pago_P, cCuenta_Eje_P,dSdoActual_P,dPago_Min_P,cFecha_LimitePago_P;

				IF cCodigoRetorno_P::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A')
					INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
					END IF;
					LET cCodRet      = cCodigoRetorno_P;
					LET cMensajeRet  = cMensajeRetorno_P;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
				END IF;

				LET dSdo_Actual = dSdoActual_P;
				LET cCuenta_Eje = cCuenta_Eje_P;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
				LET dPagoMensualidades = 0;
			END IF;			
			--IF pProducto IN ('6900') THEN
			--	LET pMontoOperacionEfec = dPagoMensualidades;
			--END IF;
			
			IF pMontoOperacionEfec > 0 THEN
				IF pProducto IN ('6011','8600') THEN
					-- REALIZA EL PAGO ANTICIPADO
					EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_rr
					(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionEfec,cBanderarespaldo,pTipoReducePagoAnticipado)
					INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,
					dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

					IF cCod_Ret::INTEGER <> 0 THEN
					   EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A')   INTO cCodRet;
						IF cCodRet::INTEGER NOT IN(0,1) THEN
							LET cCodRet      = '00368';
							LET cMensajeRet  = 'Error al realizar la reversion del pago';
							RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
						END IF;
						LET cCodRet      = cCod_Ret;
						LET cMensajeRet  = cMensaje_Ret;
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
					END IF;
					LET dSdo_Actual = dSdo_Actual;
					LET cCuenta_Eje = cCuenta_Eje;
					
				/*LABR*/
				--IF EXISTS(SELECT * FROM bdicred: sd_amortiza_creditocrd_pagos_anticipados 
				--WHERE num_credito=pNumCredito and foliosuc=pFolio  )THEN
				LET vflgPagoAnticipado = 1;
				SELECT  sdo_cap_insoluto  INTO vSaldoInsoluto
				FROM bdicred: sd_maesdoscrd 
				WHERE num_credito = pNumCredito;
				LET vsaldoins = vSaldoInsoluto;
				--END IF;
				--ELIF pProducto IN ('6300','6400','7600','7700','6900','6800') THEN	
				--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
																		
																								   
				ELIF (cbanfamilia IN ('002','003') OR pProducto='6900')  THEN
				-- REALIZA EL PAGO ANTICIPADO
					EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_pp
					(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionEfec,cBanderarespaldo,pTipoReducePagoAnticipado)
					INTO cCod_Retorno_Ap,cMens_Ret,dSdo_Anterior,dComision_Ap,dIva_Com_Ap,dInt_Mora_Ap,dIva_Int_Mora_Ap,dInt_Vdo_Ap,dIva_Int_Vdo_Ap,dInt_Ordi_Ap,dIva_Int_Ordi_Ap,dCapital_Ap,dMonto_Pago_Ap,cCuenta_Eje_Ap,dSdo_Act_Ap,dPago_Min_Ap,cFecha_Limite_Pago_Ap;

					IF cCod_Retorno_Ap::INTEGER <> 0 THEN
					   EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
						IF cCodRet::INTEGER NOT IN(0,1) THEN
							LET cCodRet      = '00368';
							LET cMensajeRet  = 'Error al realizar la reversion del pago';
							RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
						END IF;
						LET cCodRet      = cCod_Retorno_Ap;
						LET cMensajeRet  = cMens_Ret;
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
					END IF;

					LET dSdo_Actual=dSdo_Act_Ap;
					LET cCuenta_Eje= cCuenta_Eje_Ap;
			    /*LABR*/
				--IF EXISTS(SELECT * FROM bdicred: sd_amortiza_creditocrd_pagos_anticipados 
				--WHERE num_credito=pNumCredito and foliosuc=pFolio  )THEN
				LET vflgPagoAnticipado = 1;
				SELECT  sdo_cap_insoluto  INTO vSaldoInsoluto
				FROM bdicred: sd_maesdoscrd 
				WHERE num_credito = pNumCredito;
				LET vsaldoins = vSaldoInsoluto;
				--END IF;

				END IF;
			END IF;
		END IF;

					
		--IF g_Transacc in ('7998') OR cTransacc_rel = '7998' OR g_Transacc = '8150' THEN -- pago  con cargo a cuenta --DSB 20/11/2015 se agrega transaccion 8150
		IF g_Transacc in ('7998','8317','7590','8738','5025','9888') OR cTransacc_rel IN ('7998','8317','7590','8738','5025') OR g_Transacc = '8150' THEN -- pago  con cargo a cuenta --DSB 20/11/2015 se agrega transaccion 8150
			IF cTransacc_rel <> '' THEN
				LET g_Transacc = cTransacc_rel;
			END IF;

			IF dMontoFinanciado > 0 THEN
				IF pMontoOperacionCargCuenta <= dMontoFinanciado THEN
				  LET dPagoMensualidades = pMontoOperacionCargCuenta;
				  LET dMontoFinanciado = dMontoFinanciado - pMontoOperacionCargCuenta;
				  LET pMontoOperacionCargCuenta = 0;
				ELSE
				  LET dPagoMensualidades = dMontoFinanciado;
				  LET pMontoOperacionCargCuenta = pMontoOperacionCargCuenta - dPagoMensualidades;
				  LET dMontoFinanciado =0;
				END IF;
			END IF;

			--pago con cargo a cuenta     
			IF pProducto IN ('6011','8600') AND dPagoMensualidades > 0 THEN
				EXECUTE PROCEDURE bdicred:"informix".sp_principal_rr
				(pEmpresa,pNumCredito,1,dPagoMensualidades,pUsuario,pSucursal,pFolio,g_Transacc)
				INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

				IF cCod_Ret::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
					END IF;
					LET cCodRet      = cCod_Ret;
					LET cMensajeRet  = cMensaje_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
				END IF;
				LET dSdo_Actual=dSdo_Actual;
				LET cCuenta_Eje= cCuenta_Eje;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
				LET dPagoMensualidades = 0;
			--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
			--ELIF pProducto IN ('6300','6400','7600','7700','6800','6900') AND dPagoMensualidades > 0 THEN
			--AAME RQM 10 1177 Se valida la familia de productos PrÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ©stamos y LÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ­nea CrÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ©dito a Plazo
			ELIF (cbanfamilia IN ('002','003') OR pProducto='6900') AND dPagoMensualidades > 0 THEN
				EXECUTE PROCEDURE bdicred:"informix".sp_principal_pp
				(pEmpresa,pNumCredito,1,dPagoMensualidades,pUsuario,pSucursal,pFolio,g_Transacc)
				INTO cCodigoRetorno_P,cMensajeRetorno_P,dSdo_Anterior_P,dComision_P,dIva_Com_P,dInt_Mora_P,dIva_Int_Mora_P,dInt_Vdo_P,dIva_Int_Vdo_P,dInt_Ordi_P,dIva_Int_Ordi_P,dCapital_P,dMonto_Pago_P, cCuenta_Eje_P,dSdoActual_P,dPago_Min_P,cFecha_LimitePago_P;

				IF cCodigoRetorno_P::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
					END IF;
					LET cCodRet      = cCodigoRetorno_P;
					LET cMensajeRet  = cMensajeRetorno_P;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
				END IF;

				LET dSdo_Actual=dSdoActual_P;
				LET cCuenta_Eje= cCuenta_Eje_P;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
				LET dPagoMensualidades = 0;
			
			END IF;
			--IF pProducto IN ('6900') THEN
			--	LET pMontoOperacionCargCuenta = dPagoMensualidades;
			--END IF;
			
			IF pMontoOperacionCargCuenta > 0  THEN
				IF pProducto IN  ('6011','8600') THEN
					EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_rr
					(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionCargCuenta,cBanderarespaldo,pTipoReducePagoAnticipado)
					INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,
					dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;
						 
					IF cCod_Ret::INTEGER <> 0 THEN
						EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
						IF cCodRet::INTEGER NOT IN(0,1) THEN
							LET cCodRet      = '00368';
							LET cMensajeRet  = 'Error al realizar la reversion del pago';
							RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
						END IF;
						LET cCodRet      = cCod_Ret;
						LET cMensajeRet  = cMensaje_Ret;
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
					END IF;
					LET dSdo_Actual=dSdo_Actual;
					LET cCuenta_Eje= cCuenta_Eje;
				/*LABR*/
				--IF EXISTS(SELECT * FROM bdicred: sd_amortiza_creditocrd_pagos_anticipados 
				--WHERE num_credito=pNumCredito and foliosuc=pFolio  )THEN
				LET vflgPagoAnticipado = 1;
				SELECT  sdo_cap_insoluto  INTO vSaldoInsoluto
				FROM bdicred: sd_maesdoscrd 
				WHERE num_credito = pNumCredito;
				LET vsaldoins = vSaldoInsoluto;
				--END IF;
				--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
				--ELIF pProducto IN ('6300','6400','7600','7700','6900','6800') THEN
				--AAME RQM 10 1177 Se valida la familia de productos PrÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ©stamos y LÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ­nea CrÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ©dito a Plazo
				ELIF (cbanfamilia IN ('002','003') OR pProducto='6900')  THEN

					-- REALIZA EL PAGO ANTICIPADO (VIGENTE)+
					EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_pp
					(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionCargCuenta,cBanderarespaldo,pTipoReducePagoAnticipado )
					INTO cCod_Retorno_Ap,cMens_Ret,dSdo_Anterior,dComision_Ap,dIva_Com_Ap,dInt_Mora_Ap,dIva_Int_Mora_Ap,dInt_Vdo_Ap,dIva_Int_Vdo_Ap,dInt_Ordi_Ap,dIva_Int_Ordi_Ap,dCapital_Ap,dMonto_Pago_Ap,cCuenta_Eje_Ap,dSdo_Act_Ap,dPago_Min_Ap,cFecha_Limite_Pago_Ap;
		 
					IF cCod_Retorno_Ap::INTEGER <> 0 THEN
						EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
						IF cCodRet::INTEGER NOT IN(0,1) THEN
							LET cCodRet      = '00368';
							LET cMensajeRet  = 'Error al realizar la reversion del pago';
							RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
						END IF;
						LET cCodRet      = cCod_Retorno_Ap;
						LET cMensajeRet  = cMens_Ret;
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
					END IF;
					/*LABR*/
					--IF EXISTS(SELECT * FROM bdicred: sd_amortiza_creditocrd_pagos_anticipados 
					--WHERE num_credito=pNumCredito and foliosuc=pFolio  )THEN
					LET vflgPagoAnticipado = 1;
					SELECT  sdo_cap_insoluto  INTO vSaldoInsoluto
					FROM bdicred: sd_maesdoscrd 
					WHERE num_credito = pNumCredito;
					LET vsaldoins = vSaldoInsoluto;
					--END IF;
 					
					LET dSdo_Actual = dSdo_Act_Ap;
					LET cCuenta_Eje = cCuenta_Eje_Ap;
				END IF;
			END IF;
		END IF;

		--cuando entra por este flujo se realiza un pago anticipado
	ELIF ccapital_status IN ('3') THEN --AAME Quita Validacion If exits select por variables 21052018
	---- se agregan transacciones de quitas para pago anticipado solo en pago efectivo	
		IF g_Transacc IN ('7970','8205','8160','8286','7990','8335','8671','8701','8654','4320')  THEN --pago en efectivo --- 8335 SPEI

			IF pProducto IN  ('6011','8600') THEN
				EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_rr
				(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionEfec,cBanderarespaldo,pTipoReducePagoAnticipado)
				INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,
				dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

				IF cCod_Ret::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
					END IF;
					LET cCodRet      = cCod_Ret;
					LET cMensajeRet  = cMensaje_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
				END IF;
				LET dSdo_Actual = dSdo_Actual;
				LET cCuenta_Eje = cCuenta_Eje;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
				/*LABR*/
				--IF EXISTS(SELECT * FROM bdicred: sd_amortiza_creditocrd_pagos_anticipados 
				--WHERE num_credito=pNumCredito and foliosuc=pFolio  )THEN
				LET vflgPagoAnticipado = 1;
				SELECT  sdo_cap_insoluto  INTO vSaldoInsoluto
				FROM bdicred: sd_maesdoscrd 
				WHERE num_credito = pNumCredito;
				LET vsaldoins = vSaldoInsoluto;
				--END IF;
			--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
			--ELIF pProducto IN ('6300','6400','7600','7700','6900','6800') THEN
			--AAME RQM 10 1177 Se valida la familia de productos prestamos y linea credito a Plazo
			ELIF (cbanfamilia IN ('002','003') OR pProducto='6900') THEN
				-- REALIZA EL PAGO ANTICIPADO (VIGENTE)
						
				EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_pp
				(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionEfec,cBanderarespaldo,pTipoReducePagoAnticipado )
				INTO cCod_Retorno_Ap,cMens_Ret,dSdo_Anterior,dComision_Ap,dIva_Com_Ap,dInt_Mora_Ap,dIva_Int_Mora_Ap,dInt_Vdo_Ap,dIva_Int_Vdo_Ap,dInt_Ordi_Ap,dIva_Int_Ordi_Ap,dCapital_Ap,dMonto_Pago_Ap,cCuenta_Eje_Ap,dSdo_Act_Ap,dPago_Min_Ap,cFecha_Limite_Pago_Ap;
									
				IF cCod_Retorno_Ap::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
					END IF;
					LET cCodRet      = cCod_Retorno_Ap;
					LET cMensajeRet  = cMens_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
				END IF;
				
				/*LABR*/
				--IF EXISTS(SELECT * FROM bdicred: sd_amortiza_creditocrd_pagos_anticipados 
				--WHERE num_credito=pNumCredito and foliosuc=pFolio  )THEN
				LET vflgPagoAnticipado = 1;
				SELECT  sdo_cap_insoluto  INTO vSaldoInsoluto
				FROM bdicred: sd_maesdoscrd 
				WHERE num_credito = pNumCredito;
				LET vsaldoins = vSaldoInsoluto;
				--END IF;
				
				LET vSaldoIns = vSaldoInsoluto;
				LET dSdo_Actual=dSdo_Act_Ap;
				LET cCuenta_Eje= cCuenta_Eje_Ap;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
				
								
			END IF;
		END IF;

		--IF g_Transacc ='7998' OR cTransacc_rel = '7998' OR g_Transacc = '8150' THEN  -- pago  con cargo a cuenta  --EM-17/03/2017'
		IF g_Transacc IN ('7998','8317','7590','8738','5025','9888') OR cTransacc_rel IN ('7998','8317','7590','8738','5025') OR g_Transacc = '8150' THEN  -- pago  con cargo a cuenta  --EM-17/03/2017'

			IF cTransacc_rel <> '' THEN
				LET g_Transacc = cTransacc_rel;
			END IF;

			IF pProducto IN  ('6011','8600') THEN
				EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_rr
				(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionCargCuenta,cBanderarespaldo,pTipoReducePagoAnticipado)
				INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,
				dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

				IF cCod_Ret::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
					END IF;
					LET cCodRet      = cCod_Ret;
					LET cMensajeRet  = cMensaje_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
				END IF;
				
				/*LABR*/
				--IF EXISTS(SELECT * FROM bdicred: sd_amortiza_creditocrd_pagos_anticipados 
				--WHERE num_credito=pNumCredito and foliosuc=pFolio  )THEN
				LET vflgPagoAnticipado = 1;
				SELECT  sdo_cap_insoluto  INTO vSaldoInsoluto
				FROM bdicred: sd_maesdoscrd 
				WHERE num_credito = pNumCredito;
				LET vsaldoins = vSaldoInsoluto;
				--END IF;
				/*SALDO INSOLUTO Y FLG PANTCPD*/
				
				LET vSaldoIns = vSaldoInsoluto;
				
				LET dSdo_Actual=dSdo_Actual;
				LET cCuenta_Eje= cCuenta_Eje;
				LET gRespaldoActivo = '1';
			--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
			--ELIF pProducto IN ('6300','6400','7600','7700','6900','6800') THEN
			--AAME RQM 10 1177 Se valida la familia de productos prestamo y linea credito a Plazo
			ELIF (cbanfamilia IN ('002','003') OR pProducto='6900') THEN

				-- REALIZA EL PAGO ANTICIPADO (VIGENTE)
				EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_pp (pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionCargCuenta,cBanderarespaldo,pTipoReducePagoAnticipado )
				INTO cCod_Retorno_Ap,cMens_Ret,dSdo_Anterior,dComision_Ap,dIva_Com_Ap,dInt_Mora_Ap,dIva_Int_Mora_Ap,dInt_Vdo_Ap,dIva_Int_Vdo_Ap,dInt_Ordi_Ap,dIva_Int_Ordi_Ap,dCapital_Ap,dMonto_Pago_Ap,cCuenta_Eje_Ap,dSdo_Act_Ap,dPago_Min_Ap,cFecha_Limite_Pago_Ap;

				IF cCod_Retorno_Ap::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
					END IF;
					LET cCodRet      = cCod_Retorno_Ap;
					LET cMensajeRet  = cMens_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
				END IF;
				LET dSdo_Actual=dSdo_Act_Ap;
				LET cCuenta_Eje= cCuenta_Eje_Ap;
				LET gRespaldoActivo = '1';
				
				/*LABR*/
				--IF EXISTS(SELECT * FROM bdicred: sd_amortiza_creditocrd_pagos_anticipados 
				--WHERE num_credito=pNumCredito and foliosuc=pFolio  )THEN
				LET vflgPagoAnticipado = 1;
				SELECT  sdo_cap_insoluto  INTO vSaldoInsoluto
				FROM bdicred: sd_maesdoscrd 
				WHERE num_credito = pNumCredito;
				LET vsaldoins = vSaldoInsoluto;
				--END IF;
				
			END IF;
		END IF;
	ELSE
		-- Cuando el credito ya esta saldado... y no es posible aplicar el pago
		LET cCodRet = '00374';
		LET cMensajeRet= 'El credito ya esta saldado';
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
	END IF;
	
	IF pProducto = '6900' AND g_Transacc IN ("8150","8160","8654") THEN	
		IF g_Transacc ="8150" THEN
			LET mMontoCargo = dMontoAux;
		END IF;

		IF g_Transacc in ("8160","8654") THEN
			LET mMontoEfec = dMontoAux;
			--AAME Quita Validacion If exits select por variables 21052018
			Select limit 1 numcredisol 
			INTO cnumcredisol
			from  bdicred: "informix".sd_verif_cuentas_crd  
			where empresa = pempresa AND numcredisol = pNumCredito;
			
			IF cnumcredisol <> '' Then
				DELETE FROM bdicred: "informix".sd_verif_cuentas_crd WHERE empresa = pempresa AND numcredisol=pNumCredito;
			END IF
		END IF;

		IF cTranPFSI_aux = 'PFSI' THEN
			CALL "informix".sp_actualizasaldos_cred(pempresa,pNumCredito,'PFSI',mMontoEfec,mMontoCargo,pFolio,pSucursal, pUsuario) RETURNING cCodRetAux, cMensajeRet;
		ELSE
			CALL "informix".sp_actualizasaldos_cred(pempresa,pNumCredito,pProducto,mMontoEfec,mMontoCargo,pFolio,pSucursal, pUsuario) RETURNING cCodRetAux, cMensajeRet;
		END IF;

	   IF (cCodRetAux <> "000000") THEN
		   LET cCodRet      = "00053";
		   LET cMensajeRet  = "Ocurrio un error al registrar el movimiento de Pago del credisolucion";

			/*IF (wBegin = "S") THEN
			   BEGIN WORK;
			END IF;*/
			RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
		END IF;	
	END IF;
	-- OBTIENE LOS DATOS DEL PRESTAMO/REESTRUCTURA/CREDINOMINA
	EXECUTE PROCEDURE bdicred:"informix".sp_consulta_datos_general(pEmpresa, '',pNumCredito,'','','','')
	INTO cCodRetCD,cMensajeCD,cNumCredCD,cNumCteCD,cNomProductoCD,cNumTarjetaCD,cNomCteCD;
	IF cCodRetCD::INTEGER <> 0 THEN
		LET cCodRet = cCodRetCD;
		LET cMensajeRet= cMensajeCD;
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
	END IF;

	LET dMontoOperacion = dMontoOperacionEfecAux + dMontoOperacionCargCuentaAux;
	
	--Se ejecuta sp para poder obtener el status del credito
	EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa,pNumCredito)
	INTO cCodRetSP,cMensajeSP,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans,dCapVdoExig,dCapVdoNoExig,dSdoActCap,dIntVig,dIntVdo,dIntMoratorio,dIntMes,dSdoActInt,dIvaIntVig,dIvaIntVdo,dIvaIntMoratorio, dIvaIntMes,dSdoActIvaInt,dComPend,dIvaCom,dSdoRetenido,dSdoTotalLiq,dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,cDescStatusCred,iIdUnidadProd,cDescBloqueoCta,cCodCaract2,cDescCausaBloqueoCta, cSitCte,iCausaCte,cDescSitEspCte,cSitCred,iCausaCred,cDescSitEspCred;
	IF cCodRetSP <> '000000' THEN
		LET cCodRet = cCodRetSP;
		LET cMensajeRet= cMensajeSP;
	END IF;
	
	IF dSdoActCap <= 0 THEN
		IF pProducto = '6900' AND g_Transacc IN("8150","8160","8654") THEN
				--Seccion para Quitar Retenido Excedente
				SELECT monto_actual,monto_int_iva,folio_movto,num_credito INTO mMonto,v_iva_cs,cfolio_mov,dNumCredito
				FROM "informix".sd_promocion_credito
				WHERE empresa = '001'
				 AND num_sol_prestamo = pNumCredito;

				  UPDATE bdicred: "informix".sd_maesdos
					SET sdo_retenido = sdo_retenido - (mMonto + v_iva_cs)
				   WHERE empresa = '001'
					 AND num_credito = dNumCredito;

				  UPDATE bdicred: "informix".sd_promocion_credito
					 SET monto_actual=0,monto_int_iva = 0, status = 6
				   WHERE empresa = '001'
					 AND num_sol_prestamo = pNumCredito;

				UPDATE bdicred: "informix".sd_maeretenido
				 SET monto = 0
				WHERE empresa = '001'
				 AND num_credito = dNumCredito
				  AND nvl(substr(referencia,1,16),'') = cfolio_mov
				  AND nvl(substr(referencia,18,3),'')= 'RET'
				  AND estatus = 'R';

				UPDATE bdicred: "informix".sd_maeretenido
				  SET monto = 0
				WHERE empresa = '001'
				  AND num_credito = dNumCredito
				  AND nvl(substr(referencia,1,16),'') = c_Folio_Suc
				  AND nvl(substr(referencia,18,3),'')= 'PAG'
				  AND estatus = 'R';	
		END IF;
	END IF;
	
	-- RQM 09 473: TRIAD INI
	EXECUTE PROCEDURE "informix".sp_graba_indicador_cnr(pEmpresa,pNumCredito,dMontoAux,g_Transacc,g_CodigoFun,1,dtFechaActual,pFolio,0,0,2)
	INTO cCodRet;
	
	--IF pProducto = '6800' and pTransaccion not in ('611','620') THEN  -- RQM 10 915-4 
	--AAME RQM 10 1177 Se valida la familia de Linea Credito a Plazo
	IF (cbanfamilia IN ('003') AND pProducto NOT IN('6400')) and pTransaccion not in ('611','620')  THEN	 -- RQM 10 915-4
		SELECT NVL(a.telefono,''), b.status_cred INTO vNumCel,vstcred								
		FROM bdinteg:si_telefonos a
		JOIN bdicred:sd_maecredcrd b on a.numcte = b.numcte
		WHERE a.tipo_tel = 2 AND a.verificado = 'V' AND a.status_tel = 'A' AND b.num_credito = pNumCredito; 
		
		SELECT COUNT (*)
			INTO banderaApoyo
		FROM bdicred:sd_diferir
		WHERE numcte = cNumCteCD
		AND canal_baja = 21;
		
		IF banderaApoyo = 0 THEN
			IF vNumCel <> '' OR vNumCel IS NOT NULL THEN
				LET vFecha = DAY(dtFechaActual) || '/' || MONTH(dtFechaActual) || '/' || YEAR(dtFechaActual);						
					IF vstcred = 'FF'  THEN
						----Envio de mensaje de Liquidacion del prestamo						 								 
						IF cEnvioSMSRespMultic = '1' THEN
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('2','CRED_SMS','PPF_SMS_FF','000000000','', '','1', vFecha, '', '', '', '', '', '', '', '', '', '',TRIM(vNumCel), vMontoPago, 0, 0, 0, 0, current, current) INTO cCodRetSP;						
						END IF;
					ELSE
						IF cEnvioSMSRespMultic = '1' THEN  
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('2','CRED_SMS','PPF_SMS_CAUT','000000000','', '','1', vFecha, '', '', '', '', '', '', '', '', '', '',TRIM(vNumCel), vMontoPago, 0, 0, 0, 0, current, current) INTO cCodRetSP;						
						END IF;
					END IF;
			END IF;
		END IF;
	END IF; 
	
	IF  (indicaQuitaCondona IN ('Q','C','O','U') AND  g_Transacc NOT IN ('8671','8701'))   THEN	
		
		SELECT 
		SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),
        SUM((mora_provi_ordi + mora_provi_cope + mora_sdo_ordi) - (mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag)),
        NVL(SUM(interes_debe - interes_pagado),0),
		SUM(NVL(iva_debe,0) - NVL(iva_pagado,0))
		INTO vIntVencido,
			vIntMoratorio,
			vIvaIntVigente, 
			vIvaIntVencido
		FROM "informix".sd_amortiza_creditocrd WHERE empresa = '001' AND num_credito = pNumCredito;
		
		SELECT capital_mto_cuota INTO vCapitalMtoCuota
		FROM sd_amortiza_creditocrd WHERE num_credito = pNumCredito
		AND fecha_cuota = dtFechaActual;
		
		IF  indicaQuitaCondona IN ('Q','O','U') AND dSdoTotalLiq > 0 THEN
			
			LET gprocesa = 2;
			
			IF pProducto NOT IN ('6011','8600') THEN
				---- se manda a llamar el principal_suc_rr por el total a liquidar, con la nueva transaccion de PP
				execute procedure bdicred:sp_principal_suc_rr (pEmpresa,pNumCredito,pProducto,dSdoTotalLiq,0,pUsuario,pSucursal,pFolio,'8671')
					INTO cCodRet,cMensajeRet,pNumCredito,cCuenta_Eje,cNomProductoCD,cNumCteCD,cNomCteCD,dMontoOperacionEfecAux,
					dMontoOperacionCargCuentaAux,dMontoOperacion,dSdo_Actual,cDescStatusCred;
			ELSE 
				---- se manda a llamar el principal_suc_rr por el total a liquidar, con la nueva transaccion de Rees
				execute procedure bdicred:sp_principal_suc_rr (pEmpresa,pNumCredito,pProducto,dSdoTotalLiq,0,pUsuario,pSucursal,pFolio,'8701')
					INTO cCodRet,cMensajeRet,pNumCredito,cCuenta_Eje,cNomProductoCD,cNumCteCD,cNomCteCD,dMontoOperacionEfecAux,
					dMontoOperacionCargCuentaAux,dMontoOperacion,dSdo_Actual,cDescStatusCred;			
			END IF;
		END IF;
		----- Se omite la O Quita de operaciones ya que no requieren se cancele
		IF  pProducto = '6800' AND indicaQuitaCondona IN ('Q','U') THEN
			--Se genera movimiento de cancelacion de linea solo para Prestamo Digital, cuando el capital se salda con el pago y se debe cancelar el credito
			CALL "informix".genmovcrd(pEmpresa,pNumCredito, '6800', 2, '002', dtFechaActual,dLineaOtorgada,pFolio,pSucursal, '01', '7480', 'Cancelacion Linea Prestamo Digital' , '' ) 
			RETURNING cCodigoRetorno_P, cMensajeRetorno_P;

			UPDATE bdicred:"informix".sd_linea_prestamo SET fecha_cancela = dtFechaActual, cancel_pf = '1', fecha_ult_pf = vFechaVencCred WHERE num_credito = pNumCredito;
			
		END IF;
		
		--Se consulta el saldo capital insoluto y la fecha pago
		SELECT A.sdo_cap_insoluto,B.fecha_proceso,A.monto_otorgado,A.fecha_ult_mov
		INTO dSdoCapInsoluto, dFechapago, dMontoOtorgado,dFechaUltMov
		FROM bdicred:"informix".sd_maesdoscrd A
		INNER JOIN bdicred:"informix".sd_maecredanexocrd B ON B.num_credito = A.num_credito
		WHERE A.num_credito = pNumCredito
		AND A.empresa = pEmpresa;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa,pNumCredito)
		INTO cCodRetSP,cMensajeSP,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,
			dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans,dCapVdoExig,dCapVdoNoExig,dSdoActCap,dIntVig,dIntVdo,dIntMoratorio,dIntMes,dSdoActInt,dIvaIntVig,dIvaIntVdo,dIvaIntMoratorio, dIvaIntMes,dSdoActIvaInt,
			dComPend,dIvaCom,dSdoRetenido,dSdoTotalLiq,dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,cDescStatusCred,iIdUnidadProd,cDescBloqueoCta,cCodCaract2,cDescCausaBloqueoCta, cSitCte,
			iCausaCte,cDescSitEspCte,cSitCred,iCausaCred,cDescSitEspCred;
		IF cCodRetSP <> '000000' THEN
			LET cCodRet = cCodRetSP;
			LET cMensajeRet= cMensajeSP;
		END IF;
		
		LET vSdoCredito = dMontoOtorgado-dSdoCapInsoluto-dSdoRetenido;


		----------------------------------------------------------------------------
		UPDATE "informix".sd_bitacora_quitacondonacion 
			SET meses_historia = vMesesHistoria, sdo_credito = vSdoCredito, 
			fecha_pago = today, abono_mensual_al_quita = NVL(vCapitalMtoCuota,0),
			fecha_ult_mov = dFechaUltMov, fecha_liquidacion = today,
			fecha_status = today, estatus_proceso = 'FI',saldo_tot_liquidar = dSdoTotalLiq,
			copete_moratorio = NVL(dIntMoratorio,0) + NVL(dIvaIntMoratorio,0),
			int_moratorio = dIntMoratorio,
        ----------------------------------------------------------------------------
			cap_vigente_dq = NVL(dCapVig,0), 
			cap_vencido_dq = dCapVdoExig, 
			int_vigente_dq = dIntVig, 
			int_vencido_dq = dIntVdo,
			int_moratorio_dq = dIntMoratorio,		
			iva_int_vigente_dq = dIvaIntVig, 
			iva_int_vencido_dq = dIvaIntVdo,
			iva_int_mora_dq = dIvaIntMoratorio
			WHERE num_credito = pNumCredito and estatus_proceso='PR';
		----------------------------------------------------------------------------
		--COMMIT;
		LET gprocesa = 0;
	END IF;
	
	RETURN cCodRet,cMensajeRet,pNumCredito,cCuenta_Eje,cNomProductoCD,cNumCteCD,cNomCteCD,dMontoOperacionEfecAux,
	dMontoOperacionCargCuentaAux,dMontoOperacion,dSdo_Actual,cDescStatusCred,vflgPagoAnticipado,vsaldoins;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para realizar pagos normales y anticipados de prestamos a plazo, en efectivo, con cargo a cuenta o mixto',
'AUTOR: Mohamed Carreon, Jesus Aguilar ',
'FECHA: 22 de Junio 2011',
'BD: BDICRED',
'VERSION: 20110624.1808',
'DESCRIPCION: Se Modifica codigo de mensaje para cuando el credito ya este saldado.',
'AUTOR: Mohamed Carreon, Jesus Aguilar ',
'FECHA: 18 de Agosto 2011',
'BD: BDICRED',
'VERSION: 20110818.1808',
'DESCRIPCION: Se modifica metodo de calculo del IVA moratorio.',
'AUTOR: Diego Guerra Atienzo ',
'FECHA: 30 de Noviembre 2011',
'Folio: 1580',
'AUTOR : 95594213',
'FECHA : 29/01/2014',
'MODIFICACION: Se modifica sp_principal_suc_rr agregandole la ejecucion del sp_consulta_saldos_general para Retornar el status actual del credito ',
'SUSTENTO: RQM_09-338_Deposito_personal_cobranzav3.1.pdf',
'SOLICITA: Rodolfo Gomez',
'BD: bdicred',
'DESCRIPCION: Se Agregan las Transacciones 8150 y 8160 Para los Producto 6900 ',
'FECHA: 28/11/2015',
'Modifico: 92597688 - Yadira Morales Zazueta',
'----------------------------------------------------------------------------',
'Descripcion : Se modifica para filtrar dtFechaProxPago >= dtFechaActual ademasagregan las transacciones 8160 y 81150. ',
'Modifico    : 95451706 - Efrain Miranda',
'Fecha       : 17/03/2017',
'BD          : bdicred',
'-------------------------------------------------------------------------',
'Modifico: 95992243 - Trinidad Hernadez',
'Folio: 188',
'Modificacion: Se quitan movimientos a la sd_movdia',
'BD: bdicred',
'Fecha: 25/04/2017',
'=======================================================',
'AUTOR: 98640909 - LUIS ALBERTO BELTRAN RODRIGUEZ',
'Descripcion:  REDUCE MONTO DE PAGO O PLAZO EN LINEAS DE CREDITOS NO REVOLVENTES',
'Fecha: 2024/01/09',
'Version: 20240109.1242';

CREATE PROCEDURE "informix".sp_cobro_automatico_pp(pempresa  char(3), pturno Char(1))
RETURNING  CHAR(5)        AS cod_ret,       
           CHAR(125)      AS mens_ret

DEFINE iSqlErr                       INTEGER;
DEFINE iIsamErr                      INTEGER;
DEFINE cErrorInfo                    CHAR(80);
DEFINE cCodRet                       CHAR(5);
DEFINE cCodRetCtrl                   CHAR(5);
DEFINE cCodRetAux                    CHAR(6);
DEFINE cMensajeRet                   CHAR(125);
DEFINE cMensaje                      CHAR(125);
DEFINE DecAux                        DECIMAL(18,2);
DEFINE ChaAux                        CHAR(20);
DEFINE dMontoInt                     DECIMAL(18,2);
DEFINE dCuentaCap                    CHAR(20);

DEFINE dAplicaReverso                INTEGER;
DEFINE dSeAplicoReverso              INTEGER;
DEFINE dMontoPag                     DECIMAL(18,2); 

DEFINE credcontproc                  CHAR(1);
DEFINE intecontproc                  CHAR(1);
DEFINE dtFechaHoy                    DATE;

DEFINE vcproceso                    CHAR(15); --FMV 29-FEB-2012
DEFINE vcprocesoM1                  CHAR(15); 
--------------------------------------------------------------------------------------------

DEFINE TOTdMontoIntMora 			DECIMAL(18,2);
DEFINE dMontoIntMoraIva 			DECIMAL(18,2);
DEFINE TOTdMontoIntMoraIVA 			DECIMAL(18,2);
DEFINE TOTdMontoInt 				DECIMAL(18,2);
DEFINE dMontoIntMora				DECIMAL(18,2);

--------------------------------------------------------------------------------------------
--Juan RomÃÂ¡n VelÃÂ¡zquez Toledo 05/01/2021
DEFINE vExiste              SMALLINT;
--------------------------------------------------------------------------------------------
----------------------- Datos General --------------------------------
DEFINE GLOBAL g_Empresa              CHAR(3)        DEFAULT "001";
DEFINE GLOBAL g_NumCred              CHAR(20)       DEFAULT "";
DEFINE GLOBAL g_Sucursal             CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_NumProd              CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_Divisa               CHAR(2)        DEFAULT "";
DEFINE GLOBAL g_dtFechaHoy           DATE           DEFAULT "";
DEFINE GLOBAL g_CodFun               CHAR(3)        DEFAULT "";
DEFINE GLOBAL g_Folio                CHAR(16)       DEFAULT "";
DEFINE GLOBAL g_TransaccSuc          CHAR(4)        DEFAULT "0000";

DEFINE GLOBAL g_StatusCred           CHAR(2)        DEFAULT "";
DEFINE GLOBAL g_montofinanciado      MONEY(14,2)  DEFAULT 0;
DEFINE GLOBAL g_FechaApertura        DATE           DEFAULT "";
DEFINE GLOBAL g_FechaProxPago        DATE           DEFAULT "";
DEFINE GLOBAL g_MontoVencido         MONEY(14,2)  DEFAULT 0;
DEFINE GLOBAL g_SdoTrasp             DECIMAL(18,2)  DEFAULT 0;
DEFINE GLOBAL g_IvaSuc               DECIMAL(5,3)   DEFAULT 0;
DEFINE GLOBAL g_Cuentamens           INTEGER        DEFAULT 0;
DEFINE GLOBAL g_ProvIntFinMes        DECIMAL(18,2)  DEFAULT 0;
DEFINE GLOBAL g_ProvIvaFinMes        DECIMAL(18,2)  DEFAULT 0;
DEFINE  dtFVenta                     DATE;
DEFINE g_campo_trab3                 CHAR(10);
DEFINE  vlFechaBaja                  DATE;
DEFINE v_existeM1                   INTEGER;

DEFINE wbandera_apoyo				INT;
DEFINE numcte_apoyo					CHAR(9);
--------------------------------------------------------------------------------------------


LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = "";
LET cCodRet               = "00000";
LET cCodRetCtrl           = "00000";
LET cMensajeRet           = "Se realizo el pago correctamente";
LET cMensaje           	  = "Se realizo el Proceso correctamente";
LET cCodRetAux            = "000000";
LET dCuentaCap            = "";
LET dCuentaCap            = "";
LET dAplicaReverso        = 0;
LET dSeAplicoReverso      = 0;
LET dMontoPag             = 0;
LET credcontproc          = " ";
LET intecontproc          = " ";
LET g_ProvIntFinMes       = 0;
LET g_ProvIvaFinMes       = 0;
LET dtFVenta              = DATE(1);
LET g_campo_trab3         = '';
LET vlFechaBaja           = DATE(1);

LET vcproceso = 'CobroautoPP'|| '-' || trim(pturno);  -- FMV 29-FEB-12
LET vcprocesoM1 = trim(vcproceso)|| '1';	
-----------------------------------------------------------------------
LET TOTdMontoIntMora = 0;
LET dMontoIntMoraIva = 0;
LET TOTdMontoIntMoraIVA = 0;
LET TOTdMontoInt = 0;
LET dMontoIntMora=0;
LET v_existeM1 = 0;

LET wbandera_apoyo = 0;
LET numcte_apoyo = '';
LET vExiste = 0;


-- pturno   FMV 29Feb12: EJECUCION DEL PROCESO EN TURNO  M.- Matutino  N.-Nocturno

BEGIN



ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensaje = cErrorInfo;
   END IF;
          UPDATE "informix".sd_contproc
             SET status_proc = "C",
                 hora_fin    = CURRENT,
                 cod_ret     = cCodRet,
                 mensaje     = cMensaje
           WHERE empresa     = pempresa
             AND proceso     = vcproceso
             AND fecha       = dtFechaHoy;

          UPDATE bdinteg:sx_contproc
             SET status_proc = "C",
                 hora_fin    = CURRENT,
                 codret      = cCodRet
           WHERE empresa     = pempresa
             AND proceso     = vcproceso
             AND fecha       = dtFechaHoy;
		
		IF EXISTS (select  tabname  from systables where tabname = "tmp_creditos_cobr_aut" and tabtype="T") THEN 
			DROP TABLE tmp_creditos_cobr_aut;
		END IF;

      RETURN cCodRet,cMensaje;

END EXCEPTION;

--	SET DEBUG FILE TO "/ifxsif01/sp_cobro_automatico_pp.out";
 
--	TRACE ON;
 

    set isolation to dirty read;
    SET LOCK MODE TO WAIT 3;

    select fecha_hoy 
      into dtFechaHoy
      from sd_fechas
     where empresa=pempresa;
     
     --LET dtFechaHoy='11032019';
-- Creo: Cristina Acosta Sotelo
-- Fecha: 20/04/2010
-- Comentario: Se crea para separar el cobro normal del cobro automatico
-- *******************************************************
--  INSERTA PARA EJECUCIÃÂ?ÃÂ?ÃÂ?ÃÂ?ÃÂ?ÃÂ?ÃÂ?ÃÂ?ÃÂ?ÃÂ?ÃÂ?ÃÂ?ÃÂ?ÃÂ?ÃÂ?ÃÂ?N DE PROCESO                 *
-- *******************************************************
--INI CAS
    SELECT status_proc 
    INTO intecontproc
    FROM bdinteg:sx_contproc
    WHERE fecha= dtFechaHoy 
      and proceso = vcproceso;

    if (intecontproc = 'I') then
        LET cMensaje="EXISTE UN PROCESO PREVIO EN EJECUCION";
        RETURN cCodRet,cMensaje;
     end if;	 

    SELECT status_proc  
    INTO credcontproc
    FROM bdicred:sd_contproc
    WHERE fecha= dtFechaHoy 
      and proceso = vcproceso;
              
    IF (intecontproc IS NULL) THEN
      INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
      VALUES ('001',vcproceso,dtFechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
	ELSE 
		UPDATE bdinteg:sx_contproc 
			SET status_proc='I'
		WHERE fecha= dtFechaHoy 
		and proceso =vcproceso;
    END IF;  
    
    IF (credcontproc IS NULL) THEN
      INSERT INTO  sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
      VALUES ('001',vcproceso,dtFechaHoy,'I','informix',CURRENT,CURRENT,'000','Iniciamos');
    ELSE
		UPDATE bdicred:sd_contproc 
			SET status_proc='I' ,mensaje = 'Iniciamos'
		WHERE fecha= dtFechaHoy 
			and proceso =vcproceso;
	END IF;		
--FIN CAS

    set isolation to dirty read;
    SET LOCK MODE TO WAIT 3;


	
     SELECT
         'cobroapp'||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(current,3,2)||
         SUBSTR(CURRENT,12,2)||substr(current,15,2)
         ||SUBSTR(current,18,2)
      INTO g_Folio
      FROM dual;

      LET g_Empresa = pempresa;

      DELETE FROM sd_log_cobroaut WHERE fecha_proceso=dtFechaHoy AND proceso='CobroAutPP';

	
    SELECT {+INDEX (bdinteg:si_sucursales)}
		empresa,sucursal,iva FROM bdinteg:si_sucursales
     WHERE tpo_sucursal = "S"
      INTO TEMP pa_sucursales with no log;

    CREATE INDEX pasucursal on pa_sucursales (empresa, sucursal);
	
	IF EXISTS (select  tabname  from systables where tabname = "tmp_creditos_cobr_aut" and tabtype="T") THEN 
		DROP TABLE tmp_creditos_cobr_aut;
	END IF;	
	
	SELECT --{+INDEX (sd_maesdoscrd)}
			a.num_credito, a.status_cred, a.sucursal, a.num_producto, a.divisa, 
			b.monto_financiado, a.fecha_apertura, (b.monto_vencido + b.mto_venc_trasp) MontoVencido, b.cap_tras_no_venci,
			b.provision_normal, b.sdo_global_int, a.campo_trab3, a.numcte, a.empresa
	FROM "informix".sd_maecredcrd a
		INNER JOIN "informix".sd_maesdoscrd b ON a.num_credito = b.num_credito
	--    INNER JOIN "informix".sd_maecredanexocrd c ON a.num_credito = c.num_credito
	--    INNER JOIN "informix".sd_ctascarg d ON a.num_credito = d.num_credito and d.naturaleza='A'
	--    INNER JOIN bdicheq:"informix".sc_maechq e ON d.num_cta = e.cuenta and e.sdo_actual > 0
	WHERE a.num_producto NOT IN ('6011','6900','8600','8900','6400')
		AND a.status_cred NOT IN ('FF','FC','CV')  
		AND ((b.monto_financiado > 0 OR (b.monto_vencido + b.mto_venc_trasp) > 0)	
	   		OR (a.status_cred in ('E1','E2','E3') AND a.num_producto IN ('7600','7700','6300') AND b.sdo_cap_insoluto=0 ))
	INTO TEMP tmp_creditos_cobr_aut with no log;
	
	CREATE INDEX numcredito_auto_pp on tmp_creditos_cobr_aut (num_credito,empresa);
	
	UPDATE STATISTICS MEDIUM FOR TABLE tmp_creditos_cobr_aut;
	
	
FOREACH WITH HOLD
	SELECT	a.num_credito, a.status_cred, a.sucursal, a.num_producto, a.divisa, c.fecha_proceso,
			a.monto_financiado, a.fecha_apertura, c.prox_fecha_pago, a.MontoVencido, a.cap_tras_no_venci,
			a.provision_normal, a.sdo_global_int, a.campo_trab3, a.numcte
		INTO g_NumCred, g_StatusCred, g_Sucursal, g_NumProd, g_Divisa, g_dtFechaHoy,
            g_montofinanciado,g_FechaApertura,g_FechaProxPago,g_MontoVencido,g_SdoTrasp,
            g_ProvIntFinMes, g_ProvIvaFinMes, g_campo_trab3, numcte_apoyo
	FROM tmp_creditos_cobr_aut a
		INNER JOIN "informix".sd_maecredanexocrd c ON a.num_credito = c.num_credito and a.empresa=c.empresa
		INNER JOIN "informix".sd_ctascarg d ON a.num_credito = d.num_credito and d.naturaleza='A'
		INNER JOIN bdicheq:"informix".sc_maechq e ON d.num_cta = e.cuenta and e.sdo_actual > 0
		
		
    /*SELECT {+INDEX (sd_maesdoscrd)}
		   a.num_credito,a.status_cred,a.sucursal,a.num_producto, a.divisa, c.fecha_proceso,
           b.monto_financiado,a.fecha_apertura,c.prox_fecha_pago,(b.monto_vencido + b.mto_venc_trasp),cap_tras_no_venci,
           provision_normal,sdo_global_int, a.campo_trab3,a.numcte
      INTO g_NumCred, g_StatusCred, g_Sucursal, g_NumProd, g_Divisa, g_dtFechaHoy,
             g_montofinanciado,g_FechaApertura,g_FechaProxPago,g_MontoVencido,g_SdoTrasp,
           g_ProvIntFinMes, g_ProvIvaFinMes, g_campo_trab3, numcte_apoyo
      FROM "informix".sd_maecredcrd a,
           "informix".sd_maesdoscrd b,
           "informix".sd_maecredanexocrd c,
           "informix".sd_ctascarg d,
            bdicheq:"informix".sc_maechq e
     WHERE a.empresa       = '001'
       AND a.status_cred   NOT IN ('FF','FC','CV')
       AND b.empresa       = a.empresa
       AND b.num_credito   = a.num_credito
       AND c.num_credito   = b.num_credito
       AND c.empresa       = b.empresa
       AND a.num_producto  NOT IN ('6011','6900','8600','8900')
       AND a.num_credito = d.num_credito
       AND d.naturaleza='A'
       AND e.cuenta = d.num_cta
       AND ((monto_financiado > 0 OR (b.monto_vencido + b.mto_venc_trasp) > 0)	
	   		OR (a.status_cred in ('E1','E2','E3') AND a.num_producto IN ('7600','7700','6300') AND b.sdo_cap_insoluto=0 )) ---- casos con deuda de int o retenido
       AND e.sdo_actual > 0 */
	   
	   
	   --Se agrega la siguiente validaciÃÂ³n 05/01/2021 Juan RomÃÂ¡n VelÃÂ¡zquez Toledo
	   select COUNT(b.num_credito) 
	   into vExiste
	   from sd_bitacora_quitacondonacion as b 
	   where b.estatus_proceso = 'PR' and b.num_credito = g_NumCred;
	   
	if vExiste > 0 then
		CONTINUE FOREACH;
	end if;
			--   --- PROGRAMA DE APOYO 2020
			--   SELECT count (*) INTO wbandera_apoyo
			--	FROM sd_diferir
			--   WHERE numcte = numcte_apoyo;
			--   
			--	--- SE EXLUYE DEL COBRO SI EXISTE EN sd_programa_apoyo2020crd 
			--   	IF wbandera_apoyo > 0 THEN 
			--
			--	   SELECT count (*) INTO wbandera_apoyo
			--		FROM sd_programa_apoyo2020crd
			--	   WHERE num_credito = g_NumCred
			--		AND bandera = 'A';
			--
			--		IF wbandera_apoyo > 0 THEN 
			--			CONTINUE FOREACH;
			--		END IF;
			--			
			--	END IF;
				
			   
				IF g_campo_trab3 = 'BAJA' THEN 
				  SELECT max(fecha_baja)
					INTO vlFechaBaja
					FROM bdicobranza:cb_rep_cart_quebrantar
				   WHERE num_credito = g_NumCred
					 AND Fecha_baja is not null;  --fmv 26feb14
				  IF ( nvl(vlFechaBaja, date(1)) = dtFechaHoy   ) THEN
					CONTINUE FOREACH;
				  END IF;
				END IF;

				LET dAplicaReverso = 0;
				
						SELECT iva INTO g_IvaSuc
						  FROM pa_sucursales
						 WHERE empresa=g_Empresa
						   AND sucursal=g_Sucursal;

						   
				LET g_Cuentamens = 0;
				LET TOTdMontoIntMora = 0;
				LET dMontoIntMoraIva = 0; 
				LET TOTdMontoIntMoraIVA = 0; 
				LET TOTdMontoInt = 0; 
				LET dMontoInt=0;
				LET dMontoIntMora=0;
			  
				
				FOREACH
					SELECT nvl((interes_debe - interes_pagado + iva_debe - iva_pagado),0), 
						   nvl((mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag),0)
					  INTO dMontoInt, dMontoIntMora
					  FROM "informix".sd_amortiza_creditocrd
					 WHERE empresa     = g_Empresa
					   AND num_credito = g_NumCred
					   AND capital_status IN ('2','7','1','6')
					   
					   LET g_Cuentamens = g_Cuentamens + 1;
					   LET TOTdMontoIntMora = TOTdMontoIntMora + dMontoIntMora;
					   LET dMontoIntMoraIva = dMontoIntMora * g_IvaSuc;
					   LET TOTdMontoIntMoraIVA = TOTdMontoIntMoraIVA + dMontoIntMoraIva;
					   LET TOTdMontoInt = TOTdMontoInt + dMontoInt;
					   
				END FOREACH   
				
				   LET g_montofinanciado = g_montofinanciado + TOTdMontoInt + TOTdMontoIntMora + TOTdMontoIntMoraIVA;

				   IF g_montofinanciado > 0 and g_Cuentamens > 0 THEN

						EXECUTE PROCEDURE "informix".sp_principal_pp(g_Empresa, g_NumCred, 2, g_montofinanciado, 'informix', '9290', g_Folio, '7506')
						INTO cCodRetCtrl,cMensajeRet,DecAux,DecAux,DecAux,DecAux, DecAux, DecAux, DecAux, DecAux, DecAux, DecAux, dMontoPag,dCuentaCap, DecAux, DecAux, ChaAux;

						IF cCodRetCtrl <> "00000" THEN 

						   select aplica_reverso
							 into dAplicaReverso
							 from sd_reversa_error
							 where num_producto=g_NumProd
							   and codigo=cCodRetCtrl;

							IF dAplicaReverso is null THEN
								LET dAplicaReverso = 0;
							END IF;
							   
		--                    IF dAplicaReverso>0 THEN
		--                       EXECUTE PROCEDURE bdicheq:reversion (g_Empresa,'9290','informix', g_Folio,"A")
		--                       INTO cCodRetAux;
		--                       IF cCodRetAux<>"000" THEN
		--                          LET dSeAplicoReverso = 0;
		--                       ELSE
		--
		--                          LET dSeAplicoReverso = 1;
		--                       END IF;
		--                    END IF;
						END IF;
					   
					   Insert into "informix".sd_log_cobroaut 
					   (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
					   values ('06','CobroAutPP',dtFechaHoy,current,'informix',g_NumCred,dCuentaCap,dSeAplicoReverso,g_Folio,dMontoPag,cCodRetCtrl,cCodRetAux,cMensajeRet);
				   END IF;
	--end if;
END FOREACH;
	

-- Se respalda informacion de la tabla sd_log_cobroaut para el envio de SMS para producto 6800. ELS
	INSERT INTO bdicred:sd_creditos_envio_sms
	SELECT sd_log.sistema, sd_log.proceso, sd_log.fecha_proceso , sd_log.hora_proceso, sd_log.num_credito, sd_log.cuenta, sd_log.monto, sd_log.descripcion,
		sd_log.codretcred, maecred.num_producto, maecred.id_origen, maecred.numcte, maecred.status_cred, '0' as status_envio_sms
	FROM sd_log_cobroaut sd_log
	INNER JOIN sd_maecredcrd maecred ON sd_log.num_credito=maecred.num_credito
	--WHERE fecha_proceso BETWEEN mdy('10','01','2022') AND mdy('10','31','2022')
	WHERE fecha_proceso = dtFechaHoy
	AND proceso = 'CobroAutPP'
	AND num_producto = '6800'
	AND descripcion LIKE '%correcta%';
	-- AND codretcred = '00000'
	
		IF pturno='M' THEN
			
			SELECT COUNT(*) INTO v_existeM1
			FROM "informix".sd_contproc
			WHERE empresa     = pempresa
			   AND proceso     = vcprocesoM1
			   AND status_proc = "F"
			   AND fecha       = dtFechaHoy;
				   
			IF v_existeM1>0 THEN
			   UPDATE "informix".sd_contproc
				   SET status_proc = "F",
					   hora_fin    = CURRENT,
					   cod_ret     = cCodRet,
					   mensaje     = cMensaje
				 WHERE empresa     = pempresa
				   AND proceso     = vcproceso
				   AND fecha       = dtFechaHoy;

				UPDATE bdinteg:sx_contproc
				   SET status_proc = "F",
					   hora_fin    = CURRENT,
					   codret      = cCodRet
				 WHERE empresa     = pempresa
				   AND proceso     = vcproceso
				   AND fecha       = dtFechaHoy;
			ELSE
				UPDATE "informix".sd_contproc
				   SET status_proc = "F",
					   hora_fin    = CURRENT,
					   cod_ret     = cCodRet,
					   mensaje     = cMensaje,
					   proceso     = vcprocesoM1
				 WHERE empresa     = pempresa
				   AND proceso     = vcproceso
				   AND fecha       = dtFechaHoy;

				UPDATE bdinteg:sx_contproc
				   SET status_proc = "F",
					   hora_fin    = CURRENT,
					   codret      = cCodRet,
					   proceso     = vcprocesoM1
				 WHERE empresa     = pempresa
				   AND proceso     = vcproceso
				   AND fecha       = dtFechaHoy;
			END IF;
		ELSE
			UPDATE "informix".sd_contproc
				   SET status_proc = "F",
					   hora_fin    = CURRENT,
					   cod_ret     = cCodRet,
					   mensaje     = cMensaje
				 WHERE empresa     = pempresa
				   AND proceso     = vcproceso
				   AND fecha       = dtFechaHoy;

				UPDATE bdinteg:sx_contproc
				   SET status_proc = "F",
					   hora_fin    = CURRENT,
					   codret      = cCodRet
				 WHERE empresa     = pempresa
				   AND proceso     = vcproceso
				   AND fecha       = dtFechaHoy;
		END IF;
		
	IF EXISTS (select  tabname  from systables where tabname = "tmp_creditos_cobr_aut" and tabtype="T") THEN 
		DROP TABLE tmp_creditos_cobr_aut;
	END IF;

  RETURN cCodRet,cMensaje;

END
END PROCEDURE;