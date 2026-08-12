CREATE PROCEDURE "informix".apercred1_pp(
			 pEmpresa       VARCHAR(3), 	-- EMPRESA
             pSolicitud     VARCHAR(20), 	-- NUMERO DE SOLICITUD
		 	 pEjecutivo     CHAR(8),		-- EJECUTIVO
			 pPlazo			INTEGER,		-- PLAZO EN MESES PARA PAGAR EL CREDITO
			 pNombrePres	CHAR(50),		-- NOMBRE DEL PRESTAMO
			 pMonto			DECIMAL(18,2),	-- MONTO APROBADO
			 pCuentaCap		CHAR(20),		-- CUENTA DE CAPTACION
			 pMensualidad	MONEY(18,2),		-- IMPORTE MENSUAL
			 pFrecuencia    INTEGER --Frecuencia de pago   										
										--1.- Mensual credinomina
										--2.- Quincenal credinomina
			 )
RETURNING CHAR(6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),CHAR(1);

--*****************************************************
--DECLARACION DE VARIABLES
--*****************************************************
DEFINE cCodRet				VARCHAR(6);		-- CODIGO DE RETORNO
DEFINE cCodRet3				VARCHAR(6);		-- CODIGO DE RETORNO ABONOREF BDICHEQ
DEFINE cCodRetTDif			CHAR(6);		-- CODIGO DE RETORNO OBTIENE TASAS DE INTERES DIFERENCIADAS
DEFINE cErrorInfo           VARCHAR(80);	-- MENSAJE DE ERROR
DEFINE mTasaInteres         DECIMAL(18,2);	-- TASA DE INTERES
DEFINE mTasaMora            DECIMAL(18,2);	-- TASA MORATORIA
DEFINE mSobreTasa           DECIMAL(18,2);	-- SOBRETASA
DEFINE mSobreTasa_MORA      DECIMAL(18,2);	-- SOBRETASA MORA
DEFINE mTasaFavor           DECIMAL(18,2);	-- TASA A FAVOR
DEFINE mSobreTasaFAV        DECIMAL(18,2);	-- SOBRETASA A FAVOR DEL CLIENTE
DEFINE cFactor	            CHAR(1);		-- FACTOR
DEFINE cFactor_Mora	            CHAR(1);		-- FACTOR MORA
DEFINE dFechaApert          DATE;			-- FECHA DE INICIO DEL PRESTAMO
DEFINE dFechaVenc           DATE;			-- FECHA DE TERMINACION DEL PRESTAMO
DEFINE iSqlErr              INTEGER;		-- CODIGO DE ERROR
DEFINE iIsamError           INTEGER;		-- CODIGO DE ERROR
DEFINE cNumCte              CHAR(20);		-- NUMERO DE CLIENTE
DEFINE cTpCte               CHAR(1);		-- TIPO DE CLIENTE
DEFINE mIngreso             DECIMAL(18,2);	-- INGRESO DEL CLIENTE
DEFINE cFactorFAV           CHAR(1);		-- FACTOR A FAVOR DEL CLIENTE
DEFINE cProducto            CHAR(4);		-- CODIGO DE PRODUCTO
DEFINE cDivisa              CHAR(2);		-- DIVISA
DEFINE cSucursal            CHAR(4);		-- CODIGO DE SUCURSAL
DEFINE cFolio	            CHAR(16);		-- FOLIO PARA GENERACION DE MOVIMIENTOS DIARIOS
DEFINE cMensaje             CHAR(200);		-- MENSAJE MAS NOMBRE DE EJECUTIVO
DEFINE dFechaT              DATE;			-- FECHA DEL MES POSTERIOR A LA APERTURA
DEFINE sDiaCorte            SMALLINT;		-- DIA DE CORTE
DEFINE i		     		SMALLINT;		-- VARIABLE PARA ITERACION
DEFINE mCatIva		    	DECIMAL(18,2);	-- VALOR DEL CAT DEL IVA
DEFINE cMercadeo            CHAR(1);		-- PUBLICACION
DEFINE sSecIngreso 			SMALLINT;		-- SECUENCIA DE INGRESOS

DEFINE mTasaInteresProd		DECIMAL(18,2);	-- TASA DE INTERES DEL PRODUCTO
DEFINE mTasaMoraProd		DECIMAL(18,2);	-- TASA DE INTERES DEL PRODUCTO
DEFINE cPeriodoPag			CHAR(1);		-- PERIODICIDAD DEL PAGO
DEFINE iDiasTraspCap		INTEGER;		-- DIAS PARA TRASPASO DE CAPITAL
DEFINE iDiasTraspInt		INTEGER;		-- DIAS PARA TRASPASO DE INTERESES
DEFINE cNumeroFolio 		CHAR(16);		-- FOLIO PARA REGISTRAR EL ABONO
DEFINE cTransacc 			CHAR(4);	 	-- FOLIO DE TRANSACCION DEL ABONO
DEFINE iNumReg				INTEGER;		-- NUMERO DE REGISTROS DE UNA OPERACION
DEFINE dIvaSuc              DECIMAL(5,3);   -- IVA DE LA SUCURSAL DONDE SE GENERO LA SOLICITUD
DEFINE idAbono              CHAR(1);
DEFINE sDiasPeriodo         SMALLINT;
DEFINE dtDiaprimero         DATE;

DEFINE dtFecha_cargo  DATE;
DEFINE mDispo         MONEY(14,2);
DEFINE mCargo         MONEY(14,2);
DEFINE mIvaComisionApertura   MONEY(14,2);
DEFINE mComisionApertura      MONEY(14,2);
DEFINE dPorcComisionAper      DECIMAL(9,6);
DEFINE cTransaccIvaCargo      CHAR(4);
DEFINE cTransaccCargo         CHAR(4);
DEFINE iContador         	SMALLINT;
DEFINE mTotalPagar			DECIMAL(18,2);

-----------------proyeccion
DEFINE iNum_periodos    INTEGER;
DEFINE dtFecha_cuota    DATE;
DEFINE dSdo_inicial     MONEY(14,2);
DEFINE dPago_mensual    MONEY(14,2);
DEFINE dMto_Interes     MONEY(14,2);
DEFINE dIva_interes     MONEY(14,2);
DEFINE dCapital         MONEY(14,2);
DEFINE dSdo_final       MONEY(14,2);
DEFINE sDias_periodo    SMALLINT;
DEFINE dtFecha_Aper		DATE;
DEFINE iDiaPago      	INTEGER;
DEFINE cNumMesesPagos   CHAR(3);
DEFINE cCodRet2         CHAR(6);
DEFINE cMensajeRet      VARCHAR(80,1);
DEFINE vCatFinal        DECIMAL(21,10);
DEFINE dPagoReq      	DECIMAL(18,2);

DEFINE pNumCel       	CHAR(13);
DEFINE sCodRetEvento 	CHAR(5);

DEFINE pMontoSolOtorga	DECIMAL(18,2);	-- MONTO APROBADO PRODUCTO 6800,7100

--- Cuenta Clabe
DEFINE vcod_ret				CHAR (6);
DEFINE cta_Clabe			CHAR (18);

DEFINE count_maecrd			SMALLINT;
DEFINE count_mdoscrd		SMALLINT;
DEFINE count_maeanexcrd		SMALLINT;
DEFINE count_ctascarg		SMALLINT;
DEFINE count_amortcrd		SMALLINT;
DEFINE count_ssautoriz		SMALLINT;
DEFINE cbanfamilia			 CHAR(3);
DEFINE cbanderaactydesact	 CHAR (1); 		
DEFINE cnumobligados         CHAR (1); 		
DEFINE ccapturaobligada      CHAR (1); 		
DEFINE sidgarantia           SMALLINT; 		
DEFINE daforogarantia        DECIMAL(16); 	
DEFINE ccuenta_concentradora CHAR(20); 	
DEFINE cbancobrocomapert SMALLINT; 
DEFINE ccod_comision_apertura CHAR(4);	
DEFINE g_Leyenda              CHAR(40);
DEFINE g_TranRet              CHAR(4);
DEFINE g_FechaCargo           DATE;
DEFINE g_SdoDisp              DECIMAL(14,2);
DEFINE g_MtoRet               DECIMAL(14,2);
DEFINE ciddomiciliacion 	  CHAR(1);
DEFINE cNumSolObligado CHAR(20);
DEFINE vAuxNuevoStatus	CHAR(2);
DEFINE vAuxMensaje			CHAR(40);
DEFINE cCausa_sol			CHAR(3);
DEFINE cContSolObligado	INTEGER;
DEFINE iPlazo_pago          INTEGER;
DEFINE vCancelVig           INTEGER;
DEFINE vFechaVig 			DATE;

-- IFSR
DEFINE val_ifrs char(1);
DEFINE stat_aper char(2);

--***********************
--INICIALIZA VARIABLES
--***********************

LET cCodRet      		= '000000';
LET cCodRet3			= '000';
LET cCodRetTDif			= '';
LET cErrorInfo    		= 'PROCESO EXITOSO';
LET mTasaInteres 		= 0;
LET mTasaMora 			= 0;
LET mSobreTasa   		= 0;
LET mSobreTasa_MORA		= 0;
LET mTasaFavor   		= 0;
LET mSobreTasaFAV		= 0;
LET cFactor	  			= "";
LET cFactor_Mora		= "";
LET dFechaApert 		= DATE(1);
LET dFechaVenc 			= DATE(1);
LET iSqlErr    			= 0;
LET iIsamError 			= 0;
LET cErrorInfo 			= "";
LET cNumCte    			= "";
LET cTpCte     			= "";
LET mIngreso   			= 0;
LET cFactorFAV 			= "";
LET cProducto  			= "";
LET cDivisa    			= "";
LET cSucursal			= "";
LET cFolio				= "";
LET cMensaje 			= "";
LET dFechaT  			= DATE(1);
LET sDiaCorte			= 0;
LET i 					= 0;
LET mCatIva				= 0;
LET cMercadeo 			= "";
LET sSecIngreso			= 0;

LET mTasaInteresProd	= 0;
LET cPeriodoPag			= "";
LET iDiasTraspCap		= 0;
LET iDiasTraspInt		= 0;
LET cNumeroFolio		= "";
LET cTransacc			= "";
LET iNumReg				= 0;

LET dIvaSuc             = 0;
LET idAbono             = "N";
LET sDiasPeriodo        = 0;
LET dtDiaprimero  	 	= DATE(1);

LET dtFecha_cargo  	   = DATE(1);
LET mDispo             = 0;
LET mCargo      	   = 0;
LET mIvaComisionApertura = 0;
LET mComisionApertura	= 0;
LET dPorcComisionAper   = 0;
LET cTransaccIvaCargo   = "";
LET cTransaccCargo      = "";
LET iContador      	    = 0;
LET mTotalPagar			= 0;


LET iNum_periodos		= 0;
LET dtFecha_cuota      	= DATE(1);
LET dSdo_inicial      	= 0;
LET dPago_mensual      	= 0;
LET dMto_Interes      	= 0;
LET dIva_interes      	= "";
LET dCapital      	   	= "";
LET dSdo_final      	= 0;
LET sDias_periodo      	= 0;
LET dtFecha_Aper      	= DATE(1);
LET iDiaPago       		= 0; 
LET cNumMesesPagos  	= "";

LET cCodRet2            = "000000";
LET cMensajeRet         = "Se realizo el calculo correctamente";
LET vCatFinal 			= 0;
LET dPagoReq 			= 0;

LET pNumCel  			= '';
LET sCodRetEvento		= '';

LET pMontoSolOtorga = 0; 

--- Cuenta Clabe
LET vcod_ret			= '000';
LET cta_Clabe			= '';	
LET count_maecrd		= 0;
LET count_mdoscrd		= 0;
LET count_maeanexcrd	= 0;
LET count_ctascarg		= 0;
LET count_amortcrd		= 0;
LET count_ssautoriz		= 0;
LET cbanfamilia			= '';
LET cbanderaactydesact	 = ''; 		
LET cnumobligados         = ''; 		
LET ccapturaobligada      = '';		
LET sidgarantia           = 0; 		
LET daforogarantia        = 0; 	
LET ccuenta_concentradora = ''; 
LET cbancobrocomapert	  = 0;
LET ccod_comision_apertura = '';
LET g_Leyenda 			   = "ABONO PRESTAMO";
LET g_TranRet              = "";
LET g_FechaCargo           = "";
LET g_SdoDisp              = 0;
LET g_MtoRet               = 0;
LET ciddomiciliacion	   = '0';
LET cNumSolObligado		= '';
LET cCausa_sol				= '';
LET cContSolObligado	= '';
LET iPlazo_pago         = 0;
LET vCancelVig          = 0;
LET vFechaVig           = '';

--IFRS
LET val_ifrs ='';
LET stat_aper ='';

--SET DEBUG FILE TO  '/RESPALDOS/PruebasIFSR/CNR/AperturasPP/apercred1_pp.out';
--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
			LET cErrorInfo = cErrorInfo;
			LET cCodRet    = iSqlErr;
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END EXCEPTION;
		
		EXECUTE PROCEDURE "informix".apercred1_pp_web(pEmpresa,pSolicitud,pEjecutivo,pPlazo,pNombrePres,pMonto,pCuentaCap,pMensualidad,pFrecuencia)
		INTO cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		--LET cCodRet = LPAD(cCodRet,6,'0');	 
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END;
END PROCEDURE;