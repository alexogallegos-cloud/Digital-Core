CREATE PROCEDURE "informix".sp_layout_in_triad_cnr(pEjecucion smallint)

RETURNING CHAR(6), char(80);
  -- ver 1.0.2 20190409, 1.0.1 20180521
  DEFINE vDataErr			VARCHAR(64);
  DEFINE iSqlErr			INTEGER;
  DEFINE iSamErr			INTEGER;
  DEFINE cCodRet			CHAR(6);
  DEFINE dtFecha			DATE;
  DEFINE vsql         CHAR(20700);
  DEFINE vNomarchivo  CHAR(70); 
  DEFINE cRuta        CHAR(20);
  define cMensaje     char(80);
    
define vEmpresa               char(3);
define v_numcte_ref           char(20); 
define vSitesp                integer;
define vCuentaTels            integer;
define vCuentaEmails          integer;
define vMoraMaxHist           integer;
define vFechahoy              date;
define vPriDiaMes             date;
define vFechaDiaAnt			  date;
define vfecha_fin_mes_ant     date;
define vFechacorte            date;
DEFINE cFechacorte			  CHAR(8);
define vFechacorteant         date;
define vFechacorteant_1       date;
define vFechacorteant_2       date;
define vFechacorteant_3       date;
define vFechacorteant_4       date;
define vFechacorteant_5       date;
define vFechacorteant_6       date;
define vFechacorteant_7       date;
define vFechacorteant_8       date;
define vFechacorteant_9       date;
define vFechacorteant_10      date;
define vFechacorteant_11      date;
define vFechacorteant_12      date;
define vFechacorteant_13      date;
define vFechacorteant_14      date;
define vFechacorteant_15      date;
define vFechacorteant_16      date;
define vFechacorteant_17      date;
define vFechacorteant_18      date;
define vFechacorteant_19      date;
define vFechacorteant_20      date;
define vFechacorteant_21      date;
define vFechacorteant_22      date;
define vFechacorteant_23      date;
define vFechacorte_24MsAntes  date;
define v_evalua_cc            char(1);
define iIdUnidadProd          integer;
define vNumvencidos           integer;
define cContadorTarjetas      char(3);
DEFINE pNumCredIni		CHAR(20);
DEFINE pNumCredFin		CHAR(20);

--Variables para pago minimo
 define vPago_minimo      decimal(18,2);
 define vPago_minimo_2    decimal(18,2);
 define vIntVdo           decimal(18,2);
 define dIntMoratorio     decimal(18,2);
 define dIvaIntVdo        decimal(18,2);
 define dPagosVdos        decimal(18,2);
 define dIvaIntMoratorio  decimal(18,2);
 define dIntMes           decimal(18,2);
 define dIvaIntMes        decimal(18,2);
 define dIntVig           decimal(18,2);
 define dIvaIntVig        decimal(18,2);
 define dSdoRetenido      decimal(18,2);
 define dSdoActCap        decimal(18,2);
 define dMontoFinanciado  decimal(18,2);
 define cLineaDisponible  char(9);
 define iLineaDisponible  integer;
 define cLineaDisponible_2 char(10);
 define vRetCs_acumLN       decimal(18,2); 
 --define cSucursal         char(4);
 --define dIvaSuc           decimal(5,3);
 define dIntVdo           decimal(18,2);
 
 --define dIntMoraIva	      decimal(18,2);
 --define dIntMoraProvi	    decimal(18,2);
 define cPagoMinimo       char(9);

 define dSdoTotalLiq      decimal(18,2);
 define dSdoTotalLiq_2    decimal(18,2);
 define cSdoTotalLiq      char(9);
 define dIntsCobrados     decimal(18,2);
 define cIntsCobrados     char(9);
 define vCod_retorno      char(6);
 define vMsj_retorno      char(80);
 define vDiacorte         smallint;
 define cSuma             char(9);
 define vMonto_pos        decimal(18,2);
 define vNum_pos          char(3);  
 define vNum_atm          char(3);
 define vMonto_atm        decimal(18,2);
 define cMonto_pos        char(9);  
 define cMonto_atm        char(9); 
 define cLimite_credito_ini char(9);
 define cSumaDevoluciones char(9);
 define cNumpagos_dev     char(4);
 define iScoreProp        integer;
 define iScoreBc          integer;
 define iScoreBc_2        integer;
 define cScoreBc          char(3);   
 define cCadena1          char(40);
 define iContGral         integer;

 define cScoreBehavior    char(4);
 define iScoreBehavior    integer;
 define cNumRegion        char(4);
   
 define vNumcuentas       integer;
 define vTipo_prod        CHAR(3);
 define vCuenta           char(20);
 define cSegmento         char(20);
 define iRandomNumber1    integer;
 define iRandomNumber2    integer;
 define iRandomNumber3    integer;
 define iRandomNumber4    integer;
 define cRandomNumber1    char(4);
 define cRandomNumber2    char(4);
 define cRandomNumber3   char(4);
 define cRandomNumber4    char(4);
 define fValor            float;
 define cValor            char(30);
 define cProceso          char(4);
 define cCod_ret_2        CHAR(6);
 define cContGral         char(10);
 define vEmpresa_2        CHAR(3);
 define vEmpresa_3        CHAR(3);
 define pNumCredIni_temp    CHAR(30);
 
--vCod_retorno  vMsj_retorno vPago_minimo vIntVdo dIntMoratorio dIvaIntVdo dPagosVdos dIvaIntMoratorio dIntMes dIvaIntMes dIntVig dIvaIntVig
--       dSdoRetenido dIntVig  dSdoActCap dMontoFinanciado cLineaDisponible
--dSdoTotalLiq cSdoTotalLiq

DEFINE vTI_LN_CUSTOMER_ID  				CHAR(20);
DEFINE vTI_LN_ACCOUNT_ID  				CHAR(20);
DEFINE vTI_LN_DATE_OPEN  				DATE;
DEFINE vTI_LN_ACCOUNT_TYPE 				INTEGER;
DEFINE vTI_LN_ORIGINAL_TERM  			CHAR(4);
DEFINE vTI_LN_REMAINING_TERM 			INTEGER;
DEFINE vTI_LN_ORIGINAL_LOAN_AMOUNT  	DECIMAL(18,2);
DEFINE vTI_LN_DATE_START_ARREARS  		DATE;
DEFINE vTI_LN_DATE_FIRST_INSTALLMENT  	DATE;
DEFINE vTI_LN_DATE_LAST_PAY  			DATE;
DEFINE vTI_LN_STNDRD_INSTALLMENT_AMT  	DECIMAL(18,2);
DEFINE vTI_LN_TRIAD_CAT  			CHAR(2);
DEFINE vTI_LN_DATE_DUE_1  				DATE;
DEFINE vTI_LN_BLOCK_CODE_1  			CHAR(2);
DEFINE vTI_LN_BALANCE_1  				DECIMAL(18,2);
DEFINE vTI_LN_INSTALLMENT_DUE_1  		DECIMAL(18,2); 
DEFINE vTI_LN_VAL_PAYMENTS_1  			DECIMAL(18,2); 
DEFINE vTI_LN_VAL_ARREARS_1  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_INTEREST_1  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_TOTAL_FEES_1 			INTEGER;
DEFINE vTI_LN_DATE_DUE_2  				DATE;
DEFINE vTI_LN_BLOCK_CODE_2  			CHAR(2);
DEFINE vTI_LN_BALANCE_2  				DECIMAL(18,2);
DEFINE vTI_LN_INSTALLMENT_DUE_2  		DECIMAL(18,2);
DEFINE vTI_LN_VAL_PAYMENTS_2  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_ARREARS_2  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_INTEREST_2  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_TOTAL_FEES_2  		INTEGER;
DEFINE vTI_LN_DATE_DUE_3  				DATE;
DEFINE vTI_LN_BLOCK_CODE_3  			CHAR(2);
DEFINE vTI_LN_BALANCE_3  				DECIMAL(18,2);
DEFINE vTI_LN_INSTALLMENT_DUE_3  		DECIMAL(18,2);
DEFINE vTI_LN_VAL_PAYMENTS_3  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_ARREARS_3  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_INTEREST_3  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_TOTAL_FEES_3  		DECIMAL(18,2);
DEFINE vTI_LN_DATE_DUE_4  				DATE;
DEFINE vTI_LN_BLOCK_CODE_4  			CHAR(2);
DEFINE vTI_LN_BALANCE_4  				DECIMAL(18,2);
DEFINE vTI_LN_INSTALLMENT_DUE_4  		DECIMAL(18,2);
DEFINE vTI_LN_VAL_PAYMENTS_4  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_ARREARS_4  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_INTEREST_4  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_TOTAL_FEES_4  		INTEGER;
DEFINE vTI_LN_DATE_DUE_5  				DATE;
DEFINE vTI_LN_BLOCK_CODE_5  			CHAR(2);
DEFINE vTI_LN_BALANCE_5  				DECIMAL(18,2);
DEFINE vTI_LN_INSTALLMENT_DUE_5  		DECIMAL(18,2);
DEFINE vTI_LN_VAL_PAYMENTS_5  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_ARREARS_5  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_INTEREST_5  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_TOTAL_FEES_5  			DECIMAL(18,2);
DEFINE vTI_LN_DATE_DUE_6  				DATE;
DEFINE vTI_LN_BLOCK_CODE_6  			CHAR(2);
DEFINE vTI_LN_BALANCE_6  				DECIMAL(18,2);
DEFINE vTI_LN_INSTALLMENT_DUE_6  		DECIMAL(18,2);
DEFINE vTI_LN_VAL_PAYMENTS_6  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_ARREARS_6  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_INTEREST_6  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_TOTAL_FEES_6  		INTEGER;
DEFINE vTI_LN_DATE_DUE_7  				DATE;
DEFINE vTI_LN_BLOCK_CODE_7  			CHAR(2);
DEFINE vTI_LN_BALANCE_7  				DECIMAL(18,2);
DEFINE vTI_LN_INSTALLMENT_DUE_7  		DECIMAL(18,2);
DEFINE vTI_LN_VAL_PAYMENTS_7  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_ARREARS_7  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_INTEREST_7  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_TOTAL_FEES_7  		INTEGER;
DEFINE vTI_LN_DATE_DUE_8  				DATE;
DEFINE vTI_LN_BLOCK_CODE_8  			CHAR(2);
DEFINE vTI_LN_BALANCE_8 				DECIMAL(18,2);
DEFINE vTI_LN_INSTALLMENT_DUE_8  		DECIMAL(18,2);
DEFINE vTI_LN_VAL_PAYMENTS_8  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_ARREARS_8  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_INTEREST_8 			DECIMAL(18,2);
DEFINE vTI_LN_VAL_TOTAL_FEES_8  		INTEGER;
DEFINE vTI_LN_DATE_DUE_9  				DATE;
DEFINE vTI_LN_BLOCK_CODE_9  			CHAR(2);
DEFINE vTI_LN_BALANCE_9  				DECIMAL(18,2);
DEFINE vTI_LN_INSTALLMENT_DUE_9  		DECIMAL(18,2);
DEFINE vTI_LN_VAL_PAYMENTS_9  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_ARREARS_9  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_INTEREST_9  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_TOTAL_FEES_9  		INTEGER;
DEFINE vTI_LN_DATE_DUE_10  				DATE;
DEFINE vTI_LN_BLOCK_CODE_10		  		CHAR(2);
DEFINE vTI_LN_BALANCE_10 				DECIMAL(18,2);
DEFINE vTI_LN_INSTALLMENT_DUE_10  		DECIMAL(18,2);
DEFINE vTI_LN_VAL_PAYMENTS_10  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_ARREARS_10  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_INTEREST_10  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_TOTAL_FEES_10  		INTEGER;
DEFINE vTI_LN_DATE_DUE_11	  			DATE;
DEFINE vTI_LN_BLOCK_CODE_11  			CHAR(2);
DEFINE vTI_LN_BALANCE_11   				DECIMAL(18,2);
DEFINE vTI_LN_INSTALLMENT_DUE_11  		DECIMAL(18,2);
DEFINE vTI_LN_VAL_PAYMENTS_11  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_ARREARS_11  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_INTEREST_11  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_TOTAL_FEES_11  		INTEGER;
DEFINE vTI_LN_DATE_DUE_12	  			DATE;
DEFINE vTI_LN_BLOCK_CODE_12  			CHAR(2);
DEFINE vTI_LN_BALANCE_12  				DECIMAL(18,2);
DEFINE vTI_LN_INSTALLMENT_DUE_12  		DECIMAL(18,2);
DEFINE vTI_LN_VAL_PAYMENTS_12  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_ARREARS_12  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_INTEREST_12  			DECIMAL(18,2);
DEFINE vTI_LN_VAL_TOTAL_FEES_12  		DECIMAL(18,2);
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_1  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_2  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_3  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_4  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_5  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_6  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_7  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_8  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_9  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_10  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_11  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_12  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_13  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_14  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_15  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_16  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_17  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_18  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_19  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_20  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_21  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_22  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_23  	INTEGER;
DEFINE vTI_LN_NUM_MTHS_IN_ARREARS_24  	INTEGER;



--------------------------------------------------------------------------------------------------------------------
	--LOAN
	DEFINE cNumCteLN				CHAR(20);
	DEFINE cNumCteLNAnt				CHAR(20);
	DEFINE cNumCredLN 				CHAR(20);
	DEFINE cProductoLN				CHAR(4);
	DEFINE dFecha_apertura_LN 		DATE;
	DEFINE cFecha_apertura_LN 		CHAR(2);
	DEFINE dFechaVencLN				DATE;
	DEFINE cTipoProd		        CHAR(1);
	DEFINE cStatusLN				CHAR(8);
	DEFINE iPlazoLN					INTEGER;
	DEFINE iIdOrigen				INTEGER;
	DEFINE dSdoCapitalInsLN			DECIMAL(18,2);
	DEFINE cSdoCapitalLN			CHAR(10);
	DEFINE iDiaCorteLN				INTEGER;
	DEFINE cSdoInsolutoLN			CHAR(10);
	DEFINE iNumPlazoRestLN			INTEGER;
	DEFINE iCalculaPagoMax			INTEGER;
	DEFINE dMontoLN					DECIMAL(18,2);
	DEFINE iDiasMoraLN				INTEGER;
	DEFINE cSaldoMorLN				CHAR(10);
	DEFINE cDiasMoraLN				CHAR(8);
	DEFINE dDMoraLN					DATE;
	DEFINE dMontoVencidoLN			DECIMAL(18,2);
	DEFINE cMontoVencidoLN			CHAR(8);
	DEFINE cFechaUltMovLN			CHAR(8);
	DEFINE dFechaUltMovLN			DATE;
	DEFINE dFechaPrimerVencLN		DATE;
	DEFINE cFechaVencLN				CHAR(8);
	DEFINE dFechaPlazoRestLN		DATE;
	DEFINE cFechaPlazoRestFinalLN   CHAR(8);	
	DEFINE dFechaUltPagoLN			DATE;
	DEFINE dMontoMensualLN			DECIMAL(18,2);
	DEFINE cMontoMensualLN			CHAR(2);
	DEFINE dFechaVencidoLN			DATE;
	DEFINE cBlockCode				CHAR(2);
	DEFINE dVencidosLN_1			DECIMAL(18,2);
	DEFINE dVencidosLN_2			DECIMAL(18,2);
	DEFINE dVencidosLN_3			DECIMAL(18,2);
	DEFINE dVencidosLN_4			DECIMAL(18,2);
	DEFINE dVencidosLN_5			DECIMAL(18,2);
	DEFINE dVencidosLN_6			DECIMAL(18,2);
	DEFINE dVencidosLN_7			DECIMAL(18,2);
	DEFINE dVencidosLN_8			DECIMAL(18,2);
	DEFINE dVencidosLN_9			DECIMAL(18,2);
	DEFINE dVencidosLN_10			DECIMAL(18,2);
	DEFINE dVencidosLN_11			DECIMAL(18,2);
	DEFINE dVencidosLN_12			DECIMAL(18,2);
	DEFINE dVencidosLN_13			DECIMAL(18,2);
	DEFINE dVencidosLN_14			DECIMAL(18,2);
	DEFINE dVencidosLN_15			DECIMAL(18,2);
	DEFINE dVencidosLN_16			DECIMAL(18,2);
	DEFINE dVencidosLN_17			DECIMAL(18,2);
	DEFINE dVencidosLN_18			DECIMAL(18,2);
	DEFINE dVencidosLN_19			DECIMAL(18,2);
	DEFINE dVencidosLN_20			DECIMAL(18,2);
	DEFINE dVencidosLN_21			DECIMAL(18,2);
	DEFINE dVencidosLN_22			DECIMAL(18,2);
	DEFINE dVencidosLN_23			DECIMAL(18,2);
	DEFINE iExisteCuenta			INTEGER;
	DEFINE cSitLN		 			CHAR(3);
	DEFINE cCausaLN					CHAR(3);
	DEFINE dPagoCicloLN 			DECIMAL(18,2);
    DEFINE cPagoCicloLN 			CHAR(10);
	DEFINE d_sdo_tot_liq_ciclos		DECIMAL(18,2);
	DEFINE d_pago_minimo_ciclos		DECIMAL(18,2);
	DEFINE d_monto_pagos_ciclos		DECIMAL(18,2);
	DEFINE d_sdo_total_venc_ciclos	DECIMAL(18,2);
	DEFINE c_sdo_tot_liq_ciclos		CHAR(10);
	DEFINE d_sdo_tot_liq_ciclos_2   DECIMAL(18,2);
	DEFINE cIntMesLN				CHAR(2);
	DEFINE dSdoTotalLiqLN			DECIMAL(18,2);
	DEFINE dPagoMinant				DECIMAL(18,2);
	DEFINE dMontoPagos				DECIMAL(18,2);
	DEFINE dSdoVencant				DECIMAL(18,2);
	DEFINE dIntCobrados				DECIMAL(18,2);
	DEFINE dSumaMontos_1			DECIMAL(18,2);
	DEFINE dPago_minimo_AlCorte_2	DECIMAL(18,2);
	DEFINE dLimiteCred_AlCorte		DECIMAL(18,2);
	DEFINE dSaldoVencido_AlCorte	DECIMAL(18,2);
	DEFINE cSaldoVencido_AlCorte	CHAR(10);
	DEFINE dSaldoVencido_AlCorte_2	DECIMAL(18,2);

	--Pago Minimo
	DEFINE dPagoMinimoLN			DECIMAL(18,2); 
	DEFINE cPagoMinimoLN			CHAR(10);

	DEFINE dIntMesLN				DECIMAL(18,2);
	
----------------------------------------------
	--PROCESOS	
	DEFINE PR20_LN_CAT					CHAR(2);
	
--------------------------------------------------------------------------------------------------------------------
	--INICIALIZACION DE VARIABLES--
	    
let vEmpresa      = '001';
let v_numcte_ref  = '';
let vSitesp       = 0;
let vCuentaTels   = 0;
let vCuentaEmails = 0;
let vMoraMaxHist  = 0;
let vFechahoy     = date(1);
let vPriDiaMes    = date(1);
let vFechaDiaAnt  = date(1);
let vfecha_fin_mes_ant    = date(1);
let vFechacorte           = date(1);
LET cFechacorte			  = '';
let vFechacorteant        = date(1);
let vFechacorteant_1      = date(1);
let vFechacorteant_2      = date(1);
let vFechacorteant_3      = date(1);
let vFechacorteant_4      = date(1);
let vFechacorteant_5      = date(1);
let vFechacorteant_6      = date(1);
let vFechacorteant_7      = date(1);
let vFechacorteant_8      = date(1);
let vFechacorteant_9      = date(1);
let vFechacorteant_10     = date(1);
let vFechacorteant_11     = date(1);
let vFechacorteant_12     = date(1);
let vFechacorteant_13     = date(1);
let vFechacorteant_14     = date(1);
let vFechacorteant_15     = date(1);
let vFechacorteant_16     = date(1);
let vFechacorteant_17     = date(1);
let vFechacorteant_18     = date(1);
let vFechacorteant_19     = date(1);
let vFechacorteant_20     = date(1);
let vFechacorteant_21     = date(1);
let vFechacorteant_22     = date(1);
let vFechacorteant_23     = date(1);
let vFechacorte_24MsAntes = date(1); 
let v_evalua_cc           = '';
let iIdUnidadProd         = 0;	    
let vNumvencidos          = 0;
let cContadorTarjetas     = '000';
let dSdoTotalLiq          = 0;
let dSdoTotalLiq_2        = 0;

LET pNumCredIni			  ='';
LET pNumCredFin			  ='';
  
  LET cCodRet				= "000000";
  LET dtFecha				= '01-01-1900';
  LET vsql          = '';
  --LET vNomarchivo   = 'Layout_in_triad.txt';
  LET vNomarchivo   = 'Bancoppel_Layout_entrada_Triad_RQI.txt';
  LET cRuta         = '/RESPALDOS/aacano/';

--Variables para pago minimo
 let vPago_minimo      = 0;
 let vPago_minimo_2    = 0;
 let vIntVdo           = 0;
 let dIntMoratorio     = 0;
 let dIvaIntVdo        = 0;
 let dPagosVdos        = 0;
 let dIvaIntMoratorio  = 0;
 let dIntMes           = 0;
 let dIvaIntMes        = 0;
 let dIntVig           = 0;
 let dIvaIntVig        = 0;
 let dSdoRetenido      = 0;
 let dSdoActCap        = 0;
 let dMontoFinanciado  = 0;
 let cLineaDisponible  = '';
 let iLineaDisponible  = 0;
 let cLineaDisponible_2  = '';
 let vRetCs_acumLN       = 0; 
 --let cSucursal       = '';
 --let dIvaSuc         = 0;
 let dIntVdo           = 0; 
 
 --define dIntMoraIva	      decimal(18,2);
 --define dIntMoraProvi	    decimal(18,2);
 let cPagoMinimo         = '';

 let cSdoTotalLiq        = '';
 let dIntsCobrados       = 0;
 let cIntsCobrados       = ''; 
 let vCod_retorno        = '';
 let vMsj_retorno        = '';
 let vDiacorte           = 0;
 let cSuma               = ''; 
 let vMonto_pos          = 0;
 let vNum_pos            = '';
 let vNum_atm            = '';
 let vMonto_atm          = 0;
 let cLimite_credito_ini = '';
 let cSumaDevoluciones   = '';
 let cNumpagos_dev       = '';
 let iScoreProp          = 0;
 let iScoreBc            = 0;
 let iScoreBc_2          = 0;
 let cScoreBc            = '';
 let cTipoProd           = '';
 LET cStatusLN			 = '';
 let cCadena1            = '';
 let iContGral           = 0;
 let cScoreBehavior      = '';
 let iScoreBehavior      = 0;
 let cNumRegion          = '';
 let cMensaje            = 'FIN DEL PROCESO CORRECTO';
 let vNumcuentas         = 0;
 let vTipo_prod          = '';
 let vCuenta             = '';
 let cSegmento           = '';
 let iRandomNumber1      = 0;
 let iRandomNumber2      = 0;
 let iRandomNumber3      = 0;
 let iRandomNumber4      = 0;
 let cRandomNumber1      = '0000';
 let cRandomNumber2      = '0000';
 let cRandomNumber3      = '0000';
 let cRandomNumber4      = '0000';
 let fValor              = 0;
 let cValor              = '';
 let cProceso            = '0109';	--No.PROCESO ASIGNADO 
 let cCod_ret_2          = ''; 
 let cContGral           = '';
 let vEmpresa_2          = '';
 let vEmpresa_3          = '';
 let pNumCredIni_temp    = '';
 
	LET vTI_LN_CUSTOMER_ID   			= '                    ';
	LET vTI_LN_ACCOUNT_ID 				= '                    ';
	LET vTI_LN_DATE_OPEN 				= DATE(1);
	LET vTI_LN_ACCOUNT_TYPE				= 0;	
	LET vTI_LN_ORIGINAL_TERM 			= '';
	LET vTI_LN_REMAINING_TERM 			= 0;
	LET vTI_LN_ORIGINAL_LOAN_AMOUNT 	= 0;
	LET vTI_LN_DATE_START_ARREARS 		= DATE(1);
	LET vTI_LN_DATE_FIRST_INSTALLMENT 	= DATE(1);
	LET vTI_LN_DATE_LAST_PAY 			= DATE(1);
	LET vTI_LN_STNDRD_INSTALLMENT_AMT 	= 0.00;
	LET vTI_LN_TRIAD_CAT 				= '00';
	LET vTI_LN_DATE_DUE_1 				= DATE(1);
	LET vTI_LN_BLOCK_CODE_1 			= '00';
	LET vTI_LN_BALANCE_1 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_1 		= 0;
	LET vTI_LN_VAL_PAYMENTS_1 			= 0;
	LET vTI_LN_VAL_ARREARS_1 			= 0;
	LET vTI_LN_VAL_INTEREST_1 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_1			= 0;
	LET vTI_LN_DATE_DUE_2 				= DATE(1);
	LET vTI_LN_BLOCK_CODE_2 			= '00';
	LET vTI_LN_BALANCE_2 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_2 		= 0;
	LET vTI_LN_VAL_PAYMENTS_2 			= 0;
	LET vTI_LN_VAL_ARREARS_2 			= 0;
	LET vTI_LN_VAL_INTEREST_2 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_2 		= 0;
	LET vTI_LN_DATE_DUE_3 				= DATE(1);
	LET vTI_LN_BLOCK_CODE_3 			= '00';
	LET vTI_LN_BALANCE_3 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_3 		= 0;
	LET vTI_LN_VAL_PAYMENTS_3 			= 0;
	LET vTI_LN_VAL_ARREARS_3 			= 0;
	LET vTI_LN_VAL_INTEREST_3 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_3 		= 0;
	LET vTI_LN_DATE_DUE_4 				= DATE(1);
	LET vTI_LN_BLOCK_CODE_4 			= '00';
	LET vTI_LN_BALANCE_4 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_4 		= 0;
	LET vTI_LN_VAL_PAYMENTS_4 			= 0;
	LET vTI_LN_VAL_ARREARS_4 			= 0;
	LET vTI_LN_VAL_INTEREST_4 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_4 		= 0;
	LET vTI_LN_DATE_DUE_5 				= DATE(1);
	LET vTI_LN_BLOCK_CODE_5 			= '00';
	LET vTI_LN_BALANCE_5 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_5		= 0;
	LET vTI_LN_VAL_PAYMENTS_5 			= 0;
	LET vTI_LN_VAL_ARREARS_5 			= 0;
	LET vTI_LN_VAL_INTEREST_5 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_5 			= 0;
	LET vTI_LN_DATE_DUE_6 				= DATE(1);
	LET vTI_LN_BLOCK_CODE_6 			= '00';
	LET vTI_LN_BALANCE_6 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_6 		= 0;
	LET vTI_LN_VAL_PAYMENTS_6 			= 0;
	LET vTI_LN_VAL_ARREARS_6 			= 0;
	LET vTI_LN_VAL_INTEREST_6 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_6 		= 0;
	LET vTI_LN_DATE_DUE_7 				= DATE(1);
	LET vTI_LN_BLOCK_CODE_7 			= '00';
	LET vTI_LN_BALANCE_7 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_7 		= 0;
	LET vTI_LN_VAL_PAYMENTS_7 			= 0;
	LET vTI_LN_VAL_ARREARS_7 			= 0;
	LET vTI_LN_VAL_INTEREST_7 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_7 		= 0;
	LET vTI_LN_DATE_DUE_8 				= DATE(1);
	LET vTI_LN_BLOCK_CODE_8 			= '00';
	LET vTI_LN_BALANCE_8 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_8 		= 0;
	LET vTI_LN_VAL_PAYMENTS_8 			= 0;
	LET vTI_LN_VAL_ARREARS_8 			= 0;
	LET vTI_LN_VAL_INTEREST_8 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_8 		= 0;
	LET vTI_LN_DATE_DUE_9 				= DATE(1);
	LET vTI_LN_BLOCK_CODE_9 			= '00';
	LET vTI_LN_BALANCE_9 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_9 		= 0;
	LET vTI_LN_VAL_PAYMENTS_9 			= 0;
	LET vTI_LN_VAL_ARREARS_9 			= 0;
	LET vTI_LN_VAL_INTEREST_9 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_9 		= 0;
	LET vTI_LN_DATE_DUE_10 	 			= DATE(1);
	LET vTI_LN_BLOCK_CODE_10	 		= '00';
	LET vTI_LN_BALANCE_10 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_10 		= 0;
	LET vTI_LN_VAL_PAYMENTS_10 			= 0;
	LET vTI_LN_VAL_ARREARS_10 			= 0;
	LET vTI_LN_VAL_INTEREST_10 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_10 		= 0;
	LET vTI_LN_DATE_DUE_11		 		= DATE(1);
	LET vTI_LN_BLOCK_CODE_11 			= '00';
	LET vTI_LN_BALANCE_11 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_11 		= 0;
	LET vTI_LN_VAL_PAYMENTS_11 			= 0;
	LET vTI_LN_VAL_ARREARS_11 			= 0;
	LET vTI_LN_VAL_INTEREST_11 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_11 		= 0;
	LET vTI_LN_DATE_DUE_12		 		= DATE(1);
	LET vTI_LN_BLOCK_CODE_12 			= '00';
	LET vTI_LN_BALANCE_12 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_12 		= 0;
	LET vTI_LN_VAL_PAYMENTS_12 			= 0;
	LET vTI_LN_VAL_ARREARS_12 			= 0;
	LET vTI_LN_VAL_INTEREST_12 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_12 		= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_1 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_2 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_3 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_4 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_5 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_6 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_7 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_8 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_9 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_10 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_11 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_12 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_13 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_14 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_15 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_16 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_17 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_18 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_19 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_20 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_21 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_22 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_23 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_24	= 0;

--------------------------------------------------------------------------------------------------------------------
	--LOAN
	LET cNumCteLN				= '';
	LET cNumCteLNAnt			= '';
	LET cNumCredLN				= '';
	LET dFecha_apertura_LN		= DATE(1);
	LET cFecha_apertura_LN		= '';
	LET dFechaVencLN			= DATE(1);
	LET cProductoLN				= '';
	LET iPlazoLN				= 0;
	LET iIdOrigen				= 0;
	LET iNumPlazoRestLN			= 0;
	LET iCalculaPagoMax			= 0;
	LET dMontoLN				= 0;
	LET iDiasMoraLN				= 0;

	LET cDiasMoraLN				= '';
	LET dDMoraLN				= DATE(1);
	LET dMontoVencidoLN	= 0;
	LET cMontoVencidoLN		= '';
	LET cFechaUltMovLN		= '';
	LET dFechaUltMovLN		= DATE(1);
	LET dFechaPrimerVencLN		= DATE(1);
	LET cFechaVencLN			= '';
	LET dFechaPlazoRestLN		= date(1);
	let cFechaPlazoRestFinalLN	= '';	
	LET dFechaUltPagoLN			= DATE(1);
	LET dMontoMensualLN			= 0;
	LET cMontoMensualLN			= '';
	LET dFechaVencidoLN			= DATE(1);
	LET cBlockCode				= '00';
	LET dVencidosLN_1			= 0;
	LET dVencidosLN_2			= 0;
	LET dVencidosLN_3			= 0;
	LET dVencidosLN_4			= 0;
	LET dVencidosLN_5			= 0;
	LET dVencidosLN_6			= 0;
	LET dVencidosLN_7			= 0;
	LET dVencidosLN_8			= 0;
	LET dVencidosLN_9			= 0;
	LET dVencidosLN_10			= 0;
	LET dVencidosLN_11			= 0;
	LET dVencidosLN_12			= 0;
	LET dVencidosLN_13			= 0;
	LET dVencidosLN_14			= 0;
	LET dVencidosLN_15			= 0;
	LET dVencidosLN_16			= 0;
	LET dVencidosLN_17			= 0;
	LET dVencidosLN_18			= 0;
	LET dVencidosLN_19			= 0;
	LET dVencidosLN_20			= 0;
	LET dVencidosLN_21			= 0;
	LET dVencidosLN_22			= 0;
	LET dVencidosLN_23			= 0;
	LET iExisteCuenta			= 0;
	LET cSitLN	 				= '';
	LET cCausaLN 				= '';
	LET dSdoCapitalInsLN		= 0;
	LET cSdoCapitalLN			= '+000000000';
	LET iDiaCorteLN				= 0;
	LET cSdoInsolutoLN			= '';
	LET dPagoCicloLN 			= 0;
	LET cPagoCicloLN 			= '+000000000';
	LET d_sdo_tot_liq_ciclos	= 0;
	LET d_pago_minimo_ciclos	= 0;
	LET d_monto_pagos_ciclos	= 0;
	LET d_sdo_total_venc_ciclos	= 0;
	LET c_sdo_tot_liq_ciclos	= '';
	LET d_sdo_tot_liq_ciclos_2  = 0;
	LET cSaldoMorLN 			= '+000000000';
	LET cIntMesLN				= '';
	LET dSdoTotalLiqLN			= 0;
	LET dPagoMinant				= 0;
	LET dMontoPagos				= 0;
	LET dSdoVencant				= 0;
	LET dIntCobrados			= 0;
	LET dSumaMontos_1			= 0;
	LET dPago_minimo_AlCorte_2	= 0;
	LET dLimiteCred_AlCorte		= 0;
	LET dSaldoVencido_AlCorte	= 0;
	LET cSaldoVencido_AlCorte	= 0;
	LET dSaldoVencido_AlCorte_2	= 0;

	--Pago Minimo
	LET dPagoMinimoLN			= 0;
	LET cPagoMinimoLN			= '';
	
	LET dIntMesLN				= 0;

	---------------------------------------------------------------	
	--PROCESOS
	LET PR20_LN_CAT				= '00';
	---------------------------------------------------------------
	
BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDataErr
        IF iSqlErr <> 0 THEN
            LET cCodRet=iSqlErr ;
			LET cMensaje = pEjecucion || '-' || trim(cCodRet) || ' ' || cNumCredLN;
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '02') RETURNING cCod_ret_2;
			 
            RETURN cCodRet, trim(cMensaje);
        END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/ifxsif01/macf/sp_layout_in_triad_cnr.trc";
	--TRACE ON;
  
  LET cMensaje = pEjecucion;   
  --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
  CALL bdicobranza:sp_inserta_bitacora_cob_2(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
   
	/*SELECT fecha_hoy,fecha_ant,pri_dia_mes 
	INTO vFechahoy,vFechaDiaAnt,vPriDiaMes 
	FROM bdicred:sd_fechas
	WHERE empresa = vEmpresa; 
    */
	
	let vFechahoy = today -1;
	let vFechaDiaAnt = today -2;
	
	--let vFechahoy = mdy(5,1,2019);   -- SOLO TEST MACF
	--let vFechaDiaAnt = date(vFechahoy -1 units day);  -- SOLO TEST MACF
	
	
	
	IF pEjecucion IS NULL OR pEjecucion = '' THEN
		LET cCodRet     = "000005";
		LET cMensaje = "Parametro de proceso invalido";
		RETURN cCodRet, cMensaje;
	END IF;

	--  Se determina el rango de prestamos 
	--SELECT SUBSTR(valor,1,12),SUBSTR(valor,14,25) INTO pNumCredIni,pNumCredFin
	SELECT valor into pNumCredIni_temp
	FROM bdicred:sd_param  WHERE cod_param = (971 + pEjecucion)::CHAR(3);       -- cod_param between '972' and '977'     
	
    LET pNumCredIni = SUBSTR(pNumCredIni_temp,1,12); 
	LET pNumCredFin = SUBSTR(pNumCredIni_temp,14,25);
	
	IF pNumCredIni IS NULL OR pNumCredFin IS NULL OR pNumCredIni = '' OR pNumCredFin = '' THEN
		LET cCodRet     = "000006";
		LET cMensaje = "Sin cuentas a procesar";
		RETURN cCodRet, cMensaje;
	END IF;
  		
	/*	--FECHA DE CORTE
		IF vFechacorte IS NULL THEN 
			--LET cFechacorte = '-1'; 			--CAMBIAR ANTES DE LIBERAR
			LET vFechacorte = vFechahoy;
			LET vDiacorte	= DAY(vFechahoy);
		END IF;

		IF DAY(vFechahoy) <= vDiacorte THEN 					
			LET cFechacorte = TO_CHAR(vFechacorte,'%Y%m%d');
		ELSE 
			LET vFechacorte =  mdy(month(vFechahoy),vDiacorte,year(vFechahoy));
			LET cFechacorte = TO_CHAR(vFechacorte,'%Y%m%d');
		END IF;*/
         
               
		SELECT b.numcte cNumCteLN1,b.num_credito cNumCredLN1, 'CRD' vTipo_prod1
		  FROM bdicred:sd_maecredcrd b
		 WHERE b.num_producto in('6011','6300','7600','7700','6400') 
		   AND b.status_cred in('BA','BT','VP')	--VENCIDOS
		   AND b.num_credito >= pNumCredIni AND b.num_credito  < pNumCredFin
		 into temp paso_cnr with no log;
		 
		 create unique index inx_paso_cnr on paso_cnr(cNumCredLN1);
		 update statistics medium for table paso_cnr;
		 
		-- 2: CUENTAS A PLAZO: DIARIO/CORTE	VIGENTES PAGO UN DIA ANTERIOR
		insert into paso_cnr
		SELECT b.numcte, b.num_credito, 'CRD' 
		  FROM bdicred:sd_maecredcrd b
		  JOIN bdicred:sd_maecredanexocrd d ON d.empresa = b.empresa AND d.num_credito = b.num_credito AND d.fecha_ult_pago = vFechaDiaAnt 
		 WHERE b.num_producto in('6011','6300','7600','7700','6400') 
		   AND b.status_cred = 'AA'
		   AND b.num_credito not in (select cNumCredLN1 from paso_cnr)
		   AND b.num_credito >= pNumCredIni AND b.num_credito  < pNumCredFin;		

	
		-- 3: CUENTAS A PLAZO: CORTE  (Saldo > 0)
		insert into paso_cnr
		SELECT b.numcte, b.num_credito, 'CRD' 
		  FROM bdicred:sd_maecredcrd b
		  JOIN bdicred:sd_maesdoscrd c ON c.num_credito = b.num_credito AND c.sdo_cap_insoluto>0
		  JOIN bdicred:sd_maecredanexocrd d ON d.empresa = b.empresa AND d.num_credito = b.num_credito AND d.prox_fecha_pago = vFechahoy --FECHA DE CORTE
		WHERE b.num_producto in('6011','6300','7600','7700','6400')  
		  AND b.status_cred = 'AA'
		  AND b.num_credito not in (select cNumCredLN1 from paso_cnr)
		  AND b.num_credito >= pNumCredIni AND b.num_credito  < pNumCredFin;		
		

		-- 4: CUENTAS PLAZO: DIARIO/CORTE	|	VALIDA CAMPO DE ARCHIVO SALIDA: OUT_CO_ACCOUNT_ID
		insert into paso_cnr
		SELECT b.numcte, b.num_credito, 'CRD'
		  FROM bdicred:sd_maecredcrd b
		  JOIN bdicred:sd_maecredanexocrd d ON d.empresa = b.empresa AND d.num_credito = b.num_credito 
		  --JOIN bdicobranza:cb_triad_salida f ON f.out_co_account_id='00000000'||b.num_credito 
		  JOIN bdicobranza:cb_triad_salida f ON f.num_credito = b.num_credito 
		 WHERE b.num_producto in('6011','6300','7600','7700','6400')  
		   AND b.status_cred = 'AA'
		   AND b.num_credito not in (select cNumCredLN1 from paso_cnr)
		   AND b.num_credito >= pNumCredIni AND b.num_credito  < pNumCredFin 
		   AND d.prox_fecha_pago+f.out_coll_next_call_days = vFechahoy; --VIGENTES EN EL CAMPO OUT-COLL-NEXT-CALL-DAYS*		

         update statistics medium for table paso_cnr;		
		
		SELECT limit 1 empresa into vEmpresa_2
		FROM bdicobranza:cb_triad_plazo 
		WHERE ti_ln_account_id >= '600000000001' AND fecha_proceso = vFechahoy;
		
		IF nvl(vEmpresa_2,'') <> '' then
			begin;
			  delete from paso_cnr
			  where cNumCredLN1 in (SELECT ti_ln_account_id from bdicobranza:cb_triad_plazo WHERE fecha_proceso = vFechahoy);
			commit;
		END IF;
		
		begin; 
          delete from paso_cnr
          where cNumCredLN1 in (SELECT num_credito FROM bdicred:sd_inactivos_12meses WHERE num_credito > '600000000001');
		commit;

        update statistics medium for table paso_cnr;
		
	FOREACH WITH HOLD
	
		SELECT cNumCteLN1, cNumCredLN1, vTipo_prod1
		  INTO cNumCteLN,cNumCredLN, vTipo_prod
		from paso_cnr
		
		LET iContGral = iContGral + 1;
		
		
        --SELECT b.num_producto , b.status_cred ,to_char(b.fecha_apertura,"%Y%m%d"), b.fecha_vencim , b.plazo, b.id_origen, c.monto_otorgado, c.sdo_cap_insoluto,
		SELECT b.num_producto , b.status_cred ,b.fecha_apertura, b.fecha_vencim , b.plazo, b.id_origen, c.monto_otorgado, c.sdo_cap_insoluto,
		       c.sdo_moratorio, c.mto_fin_ven_trasp, round(c.monto_vencido,0), c.fecha_ult_mov, d.dia_corte, d.prox_fecha_pago , d.fecha_vencto 
		 INTO cProductoLN, cStatusLN, dFecha_apertura_LN, dFechaVencLN, iPlazoLN,  iIdOrigen, dMontoLN,  dSdoCapitalInsLN,  cSaldoMorLN, iDiasMoraLN,
		      dMontoVencidoLN, dFechaUltMovLN,  vDiacorte, vFechacorte, dFechaVencidoLN
		FROM bdicred:sd_maecredcrd b 
		    JOIN bdicred:sd_maesdoscrd c ON c.num_credito=b.num_credito
		    JOIN bdicred:sd_maecredanexocrd d ON d.empresa=c.empresa AND d.num_credito=c.num_credito
        WHERE b.num_credito = cNumCredLN;			

		
		--TI-LN-CUSTOMER-ID: Identificador unico del cliente 	- 	Corregido
		LET vTI_LN_CUSTOMER_ID = trim(cNumCteLN);
		
		--TI-LN-ACCOUNT-ID: Identificador unico de cuenta* 		- 	Corregido
		LET vTI_LN_ACCOUNT_ID = trim(cNumCredLN);	
	
		--TI-LN-DATE-OPEN: Fecha de apertura de la cuenta*		- 	Corregido
		LET vTI_LN_DATE_OPEN = nvl(dFecha_apertura_LN,'01/01/1900');
	
		--TI-LN-ACCOUNT-TYPE: Tipo de la cuenta. Para prestamos: 1: PrÃ?Â?Ã?Â?Ã?Â?Ã?Â©stamo 2: Nomina 3: Reestructura.
		--Productos NO considerados:'6800','6900'
		--1 - Prestamo
		IF cProductoLN IN ('6300','7600','7700') THEN LET vTI_LN_ACCOUNT_TYPE = 1; 	END IF; 
		--2 - Nomina
		IF cProductoLN IN ('6400') 				 THEN LET vTI_LN_ACCOUNT_TYPE = 2; 	END IF;
		--3 Nomina Reestructura
		IF cProductoLN IN ('6011') 				 THEN LET vTI_LN_ACCOUNT_TYPE = 3; 	END IF;
		
		--TI-LN-ORIGINAL-TERM: El plazo original del prestamo (en meses)
		LET vTI_LN_ORIGINAL_TERM = iPlazoLN;
		
		--TI-LN-REMAINING-TERM: El plazo restante del prestamo (en meses)	
		SELECT MONTH(fecha_vencim)-MONTH(vFechahoy) INTO iNumPlazoRestLN FROM bdicred:sd_maecredcrd WHERE empresa=vEmpresa AND num_credito = cNumCredLN;
		
		LET vTI_LN_REMAINING_TERM = iNumPlazoRestLN;
		
		--TI-LN-ORIGINAL-LOAN-AMOUNT: Monto del prestamo
		LET vTI_LN_ORIGINAL_LOAN_AMOUNT = dMontoLN; 
		
		--TI-LN-DATE-START-ARREARS: Si la cuenta esta en mora la fecha de inicio de esta condicion (que puede ser en un mes diferente). Cero cuando la cuenta no esta en mora. - INDEX
		LET vTI_LN_DATE_START_ARREARS = dFechaVencidoLN;
			
		--TI-LN-DATE-FIRST-INSTALLMENT: La fecha de la primera cuota vencida en la cuenta.			- 		INDEX		-		INDICADOR	
		Select NVL(sdo_tot_liquidar_ch,0),NVL(pago_minimo_ch,0),NVL(sdo_tot_vencido_ch,0),NVL(monto_pagos_ch,0),NVL(intereses_periodo_ch,0),NVL(fecha_primera_mora,0),NVL(fecha_ultimo_pago,0),NVL(monto_mensual,0)
		INTO dSdoTotalLiq,dPagoMinimoLN,dSaldoVencido_AlCorte,dPagoCicloLN,dIntMesLN,dFechaPrimerVencLN,dFechaUltPagoLN,dMontoMensualLN 
		FROM bdicred:sd_indicador_cred_crd WHERE empresa=vEmpresa AND num_credito= cNumCredLN;
		
		LET vTI_LN_DATE_FIRST_INSTALLMENT = dFechaPrimerVencLN;									
						
		--TI-LN-DATE-LAST-PAY: Fecha mas reciente en la que se ha contabilizado un pago en la cuenta.
		LET vTI_LN_DATE_LAST_PAY = dFechaUltPagoLN;

		--TI-LN-STNDRD-INSTALLMENT-AMT: Monto de la cuota mensual. 			-			INDEX		- 		NUEVO INDICADOR CRD
		LET vTI_LN_STNDRD_INSTALLMENT_AMT = dMontoMensualLN;
		
		--PROCESO: TI-LN-TRIAD-CAT: Se inicializa en 00 y posteriormente se tomara el valor del campo PR20-LN-CAT del layout de salida para futuras llamadas de TRIAD. 
		SELECT out_ln_cat INTO PR20_LN_CAT FROM bdicobranza:"informix".cb_triad_salida WHERE out_cu_customer_id=cNumCteLN AND out_co_account_id='00000000'||cNumCredLN;
		
		IF PR20_LN_CAT IS NULL OR PR20_LN_CAT=' ' OR PR20_LN_CAT='00' THEN 
			LET vTI_LN_TRIAD_CAT = '00';	
		ELSE
			LET vTI_LN_TRIAD_CAT = PR20_LN_CAT;	
		END IF;

		--TI-LN-DATE-DUE(1): Fecha de vencimiento del pago de cada mes. Ciclo actual.
		LET vTI_LN_DATE_DUE_1 = dFechaVencidoLN;
			
		--TI-LN-BLOCK-CODE(1):
		SELECT LIMIT 1 NVL(cve_causa,0) INTO cBlockCode FROM bdicred:sd_bitacorabloqueocta WHERE cuenta=cNumCredLN AND cve_causa IN ('04','06','10','01','02','03','05','07','08','09') 
		AND fecha = (SELECT MAX(fecha) FROM bdicred:sd_bitacorabloqueocta WHERE cuenta=cNumCredLN and cve_causa IN ('04','06','10','01','02','03','05','07','08','09'));
		
		LET vTI_LN_BLOCK_CODE_1 = cBlockCode;
	
		--TI-LN-BALANCE(1): Saldo en la fecha de vencimiento (mesiversario actual)
		LET vTI_LN_BALANCE_1 = dSdoTotalLiq;
			
		--TI-LN-INSTALLMENT-DUE(1): Pago minimo solicitado en el mesiversario para estar al corriente.
		LET vTI_LN_INSTALLMENT_DUE_1 = dPagoMinimoLN;
		
		--TI-LN-VAL-PAYMENTS(1): El valor de pagos durante el mes. Monto de pagos durante el ciclo actual. 				
		LET vTI_LN_VAL_PAYMENTS_1 = dPagoCicloLN;
		
		--TI-LN-VAL-ARREARS(1): Saldo vencido de la cuenta en la fecha de vencimiento (mesiversario correspondiente)				
		LET vTI_LN_VAL_ARREARS_1 = dSaldoVencido_AlCorte;
										
		--TI-LN-VAL-INTEREST(1): El monto de los intereses cargados en la cuenta durante el periodo. 
		LET vTI_LN_VAL_INTEREST_1 = dIntMesLN;
		
		--TI-LN-VAL-TOTAL-FEES(1): Total de comisiones cargadas durante el periodo.			-		ACTUALMENTE PRESTAMO NO TIENE NINGUNA COMISION
		LET vTI_LN_VAL_TOTAL_FEES_1 = 0;
		
		--TI-LN-DATE-DUE(2): Fecha de vencimiento del pago de cada mes. Ciclo actual - 1
		LET vTI_LN_DATE_DUE_2 = bdicred:monthadd(dFechaVencidoLN,-1);

		--TI-LN-BLOCK-CODE(2): Codigo de Bloqueo	 		-		Ciclo actual - 1
		SELECT NVL(cod_bloqueo_cta1,0),NVL(sdo_tot_liquidar1,0),NVL(pago_minimo1,0),NVL(monto_pagos1,0),NVL(sdo_tot_vencido1,0),NVL(intereses_periodo1,0)    
		INTO cBlockCode,dSdoTotalLiqLN,dPagoMinant,dMontoPagos,dSdoVencant,dIntCobrados 
		FROM bdicobranza:cb_triad_sdos_inds_cnr 
		WHERE fecha_proceso =(SELECT date(max(fecha_proceso) - 1 units month) FROM bdicobranza:cb_triad_sdos_inds_cnr WHERE empresa= vEmpresa AND num_credito=cNumCredLN)
		AND empresa= vEmpresa AND num_credito=cNumCredLN;
		
		LET vTI_LN_BLOCK_CODE_2 = cBlockCode;
		
		--TI-LN-BALANCE(2): El saldo en la fecha de vencimiento actual - 1 									-    Primary Key		
		LET vTI_LN_BALANCE_2 = dSdoTotalLiqLN;
		
		--TI-LN-INSTALLMENT-DUE(2): Pago minimo solicitado en el mesiversario - 1 para estar al corriente. 
		LET vTI_LN_INSTALLMENT_DUE_2 = dPagoMinant;

		--TI-LN-VAL-PAYMENTS(2): El valor de pagos durante el mes. Monto de pagos durante el ciclo actual - 1.
		LET vTI_LN_VAL_PAYMENTS_2 = dMontoPagos;
	
		--TI-LN-VAL-ARREARS(2):El valor de los atrasos en la cuenta en el ciclo, Saldo vencido de la cuenta en la fecha de vencimiento (mesiversario correspondiente).
		LET vTI_LN_VAL_ARREARS_2 = dSdoVencant;
		
		--TI-LN-VAL-INTEREST(2): El monto de los intereses cargados en la cuenta durante el periodo. Ciclo actual - 1
		LET vTI_LN_VAL_INTEREST_2 = dIntCobrados;

		--TI-LN-VAL-TOTAL-FEES(2):Suma de los siguientes valores del mesiversario - 1 (los que apliquen y existan). 
		LET vTI_LN_VAL_TOTAL_FEES_2 = 0;
--3
		--TI-LN-DATE-DUE(3): Fecha de vencimiento del pago de cada mes. Ciclo actual - 2
		LET vTI_LN_DATE_DUE_3 = bdicred:monthadd(dFechaVencidoLN,-2);
	
		SELECT NVL(cod_bloqueo_cta2,0),NVL(sdo_tot_liquidar2,0),NVL(pago_minimo2,0),NVL(monto_pagos2,0),NVL(sdo_tot_vencido2,0),NVL(intereses_periodo2,0)
		INTO cBlockCode,dSdoTotalLiqLN,dPagoMinant,dMontoPagos,dSdoVencant,dIntCobrados 
		FROM bdicobranza:cb_triad_sdos_inds_cnr 
		WHERE fecha_proceso =(SELECT date(max(fecha_proceso) - 2 units month) FROM bdicobranza:cb_triad_sdos_inds_cnr WHERE empresa= vEmpresa AND num_credito=cNumCredLN)
		AND empresa= vEmpresa AND num_credito=cNumCredLN;
		
		LET vTI_LN_BLOCK_CODE_3 = cBlockCode;
		
		--TI-LN-BALANCE(3):Saldo en la fecha de vencimiento (mesiversario actual - 2)				
		LET vTI_LN_BALANCE_3 = dSdoTotalLiqLN;
		
		--TI-LN-INSTALLMENT-DUE(3): Pago minimo solicitado en el mesiversario - 2 para estar al corriente. 
		LET vTI_LN_INSTALLMENT_DUE_3 = dPagoMinant;

		--TI-LN-VAL-PAYMENTS(3): El valor de pagos durante el mes. Ciclo actual - 2
		LET vTI_LN_VAL_PAYMENTS_3 = dMontoPagos;
	
		--TI-LN-VAL-ARREARS(3):El valor de los atrasos en la cuenta en el ciclo, Saldo vencido de la cuenta en la fecha de vencimiento (mesiversario correspondiente).
		LET vTI_LN_VAL_ARREARS_3 = dSdoVencant;
		
		--TI-LN-VAL-INTEREST(3): El monto de los intereses cargados en la cuenta durante el periodo. Ciclo actual - 2		
		LET vTI_LN_VAL_INTEREST_3 = dIntCobrados;
		
		--TI-LN-VAL-TOTAL-FEES(3):Total de comisiones cargadas durante el periodo.
		LET vTI_LN_VAL_TOTAL_FEES_3 = 0;
--4
		--TI-LN-DATE-DUE(4): Fecha de vencimiento del pago de cada mes. Ciclo actual - 3
		LET vTI_LN_DATE_DUE_4 = bdicred:monthadd(dFechaVencidoLN,-3);

		--TI-LN-BLOCK-CODE(4): En blanco porque no especificaron para LN		 		-		Ciclo actual - 3
		IF vFechacorte <> '' OR vFechacorte IS NOT NULL THEN 
			SELECT NVL(cod_bloqueo_cta3,0),NVL(sdo_tot_liquidar3,0),NVL(pago_minimo3,0),NVL(monto_pagos3,0),NVL(sdo_tot_vencido3,0),NVL(intereses_periodo3,0) 
			INTO cBlockCode,dSdoTotalLiqLN,dPagoMinant,dMontoPagos,dSdoVencant,dIntCobrados 
			FROM bdicobranza:cb_triad_sdos_inds_cnr 
			WHERE fecha_proceso = (SELECT date(max(fecha_proceso) - 3 units month) FROM bdicobranza:cb_triad_sdos_inds_cnr WHERE empresa= vEmpresa AND num_credito=cNumCredLN)
			AND empresa= vEmpresa AND num_credito=cNumCredLN;
		END IF;
		
		LET vTI_LN_BLOCK_CODE_4 = cBlockCode;

		--TI-LN-BALANCE(4): El saldo en la fecha de vencimiento actual - 3				
		LET vTI_LN_BALANCE_4 = dSdoTotalLiqLN;
		
		--TI-LN-INSTALLMENT-DUE(4): Pago minimo solicitado en el mesiversario - 3 para estar al corriente. 
		LET vTI_LN_INSTALLMENT_DUE_4 = dPagoMinant;

		--TI-LN-VAL-PAYMENTS(4): El valor de pagos durante el mes. Ciclo actual - 3
		LET vTI_LN_VAL_PAYMENTS_4 = dMontoPagos;
	
		--TI-LN-VAL-ARREARS(4):El valor de los atrasos en la cuenta en el ciclo, Saldo vencido de la cuenta en la fecha de vencimiento (mesiversario correspondiente).	
		LET vTI_LN_VAL_ARREARS_4 = dSdoVencant;
	
		--TI-LN-VAL-INTEREST(4): El monto de los intereses cargados en la cuenta durante el periodo. Ciclo actual - 3		
		LET vTI_LN_VAL_INTEREST_4 = dIntCobrados;
		
		--TI-LN-VAL-TOTAL-FEES(4): Total de comisiones cargadas durante el periodo.
		LET vTI_LN_VAL_TOTAL_FEES_4 = 0;
--5
		--TI-LN-DATE-DUE(5): Fecha de vencimiento del pago de cada mes. Ciclo actual - 4
		LET vTI_LN_DATE_DUE_5 = bdicred:monthadd(dFechaVencidoLN,-4);

		--TI-LN-BLOCK-CODE(5): En blanco porque no especificaron para LN 		-		Ciclo actual - 4
		SELECT NVL(cod_bloqueo_cta4,0),NVL(sdo_tot_liquidar4,0),NVL(pago_minimo4,0),NVL(monto_pagos4,0),NVL(sdo_tot_vencido4,0),NVL(intereses_periodo4,0)  
		INTO cBlockCode,dSdoTotalLiqLN,dPagoMinant,dMontoPagos,dSdoVencant,dIntCobrados 
		FROM bdicobranza:cb_triad_sdos_inds_cnr 
		WHERE fecha_proceso =(SELECT date(max(fecha_proceso) - 4 units month) FROM bdicobranza:cb_triad_sdos_inds_cnr WHERE empresa= vEmpresa AND num_credito=cNumCredLN)
		AND empresa= vEmpresa AND num_credito=cNumCredLN;
		
		LET vTI_LN_BLOCK_CODE_5 = cBlockCode;
		
		--TI-LN-BALANCE(5): El saldo en la fecha de vencimiento actual - 4
		LET vTI_LN_BALANCE_5 = dSdoTotalLiqLN;
		
		--TI-LN-INSTALLMENT-DUE(5): Pago minimo solicitado en el mesiversario para estar al corriente. 	
		LET vTI_LN_INSTALLMENT_DUE_5 = dPagoMinant;

		--TI-LN-VAL-PAYMENTS(5): El valor de pagos durante el mes. Ciclo actual - 4			
		LET vTI_LN_VAL_PAYMENTS_5 = dMontoPagos;
	
		--TI-LN-VAL-ARREARS(5):El valor de los atrasos en la cuenta en el ciclo, Saldo vencido de la cuenta en la fecha de vencimiento (mesiversario correspondiente).		
		LET vTI_LN_VAL_ARREARS_5 = dSdoVencant;
	
		--TI-LN-VAL-INTEREST(5): El monto de los intereses cargados en la cuenta durante el periodo. 
		LET vTI_LN_VAL_INTEREST_5 = dIntCobrados;
			
		--TI-LN-VAL-TOTAL-FEES(5): Total de comisiones cargadas durante el periodo.
		LET vTI_LN_VAL_TOTAL_FEES_5 = 0;
--6
		--TI-LN-DATE-DUE(6): Fecha de vencimiento del pago de cada mes. Ciclo actual - 5
		LET vTI_LN_DATE_DUE_6 = bdicred:monthadd(dFechaVencidoLN,-5);
		
		--TI-LN-BLOCK-CODE(6): En blanco porque no especificaron para LN 		-		Ciclo actual - 5
		SELECT NVL(cod_bloqueo_cta5,0),NVL(sdo_tot_liquidar5,0),NVL(pago_minimo5,0),NVL(monto_pagos5,0),NVL(sdo_tot_vencido5,0),NVL(intereses_periodo5,0)
		INTO cBlockCode,dSdoTotalLiqLN,dPagoMinant,dMontoPagos,dSdoVencant,dIntCobrados 
		FROM bdicobranza:cb_triad_sdos_inds_cnr 
		WHERE fecha_proceso =(SELECT date(max(fecha_proceso) - 5 units month) FROM bdicobranza:cb_triad_sdos_inds_cnr WHERE empresa= vEmpresa AND num_credito=cNumCredLN)
		AND empresa= vEmpresa AND num_credito=cNumCredLN;

		LET vTI_LN_BLOCK_CODE_6 = cBlockCode;
		
		--TI-LN-BALANCE(6): El saldo en la fecha de vencimiento actual - 5				
		LET vTI_LN_BALANCE_6 = dSdoTotalLiqLN;
		
		--TI-LN-INSTALLMENT-DUE(6): Pago minimo solicitado en el mesiversario para estar al corriente. 		
		LET vTI_LN_INSTALLMENT_DUE_6 = dPagoMinant;

		--TI-LN-VAL-PAYMENTS(6): El valor de pagos durante el mes. Ciclo actual - 5
		LET vTI_LN_VAL_PAYMENTS_6 = dMontoPagos;
	
		--TI-LN-VAL-ARREARS(6): El valor de los atrasos en la cuenta en el ciclo, Saldo vencido de la cuenta en la fecha de vencimiento (mesiversario correspondiente).
		LET vTI_LN_VAL_ARREARS_6 = dSdoVencant;
	
		--TI-LN-VAL-INTEREST(6): El monto de los intereses cargados en la cuenta durante el periodo. 	
		LET vTI_LN_VAL_INTEREST_6 = dIntCobrados;
		
		--TI-LN-VAL-TOTAL-FEES(6): Total de comisiones cargadas durante el periodo.
		LET vTI_LN_VAL_TOTAL_FEES_6 = 0;
--7
		--TI-LN-DATE-DUE(7)): Fecha de vencimiento del pago de cada mes. Ciclo actual - 6
		LET vTI_LN_DATE_DUE_7 = bdicred:monthadd(dFechaVencidoLN,-6);
			
		--TI-LN-BLOCK-CODE(7): En blanco porque no especificaron para LN 		-		Ciclo actual - 6
		SELECT NVL(cod_bloqueo_cta6,0),NVL(sdo_tot_liquidar6,0),NVL(pago_minimo6,0),NVL(monto_pagos6,0),NVL(sdo_tot_vencido6,0),NVL(intereses_periodo6,0) 
		INTO cBlockCode,dSdoTotalLiqLN,dPagoMinant,dMontoPagos,dSdoVencant,dIntCobrados 
		FROM bdicobranza:cb_triad_sdos_inds_cnr 
		WHERE fecha_proceso =(SELECT date(max(fecha_proceso) - 6 units month) FROM bdicobranza:cb_triad_sdos_inds_cnr WHERE empresa= vEmpresa AND num_credito=cNumCredLN)
		AND empresa= vEmpresa AND num_credito=cNumCredLN;
		
		LET vTI_LN_BLOCK_CODE_7 = cBlockCode;
		
		--TI-LN-BALANCE(7): El saldo en la fecha de vencimiento actual - 6 				
		LET vTI_LN_BALANCE_7 = dSdoTotalLiqLN;
		
		--TI-LN-INSTALLMENT-DUE(7): Pago minimo solicitado en el mesiversario para estar al corriente. 
		LET vTI_LN_INSTALLMENT_DUE_7 = dPagoMinant;

		--TI-LN-VAL-PAYMENTS(7): El valor de pagos durante el mes. Ciclo actual - 6		
		LET vTI_LN_VAL_PAYMENTS_7 = dMontoPagos;
	
		--TI-LN-VAL-ARREARS(7): El valor de los atrasos en la cuenta en el ciclo, Saldo vencido de la cuenta en la fecha de vencimiento (mesiversario correspondiente).
		LET vTI_LN_VAL_ARREARS_7 = dSdoVencant;
		
		--TI-LN-VAL-INTEREST(7): El monto de los intereses cargados en la cuenta durante el periodo. 
		LET vTI_LN_VAL_INTEREST_7 = dIntCobrados;
		
		--TI-LN-VAL-TOTAL-FEES(7): Total de comisiones cargadas durante el periodo.
		LET vTI_LN_VAL_TOTAL_FEES_7 = 0;
--8
		--TI-LN-DATE-DUE(8): Fecha de vencimiento del pago de cada mes. Ciclo actual - 7
		LET vTI_LN_DATE_DUE_8 = bdicred:monthadd(dFechaVencidoLN,-7);		
		
		--TI-LN-BLOCK-CODE(8): En blanco porque no especificaron para LN 		-		Ciclo actual - 7
		SELECT NVL(cod_bloqueo_cta7,0),NVL(sdo_tot_liquidar7,0),NVL(pago_minimo7,0),NVL(monto_pagos7,0),NVL(sdo_tot_vencido7,0),NVL(intereses_periodo7,0) 
		INTO cBlockCode,dSdoTotalLiqLN,dPagoMinant,dMontoPagos,dSdoVencant,dIntCobrados 
		FROM bdicobranza:cb_triad_sdos_inds_cnr 
		WHERE fecha_proceso =(SELECT date(max(fecha_proceso) - 7 units month) FROM bdicobranza:cb_triad_sdos_inds_cnr WHERE empresa= vEmpresa AND num_credito=cNumCredLN)
		AND empresa= vEmpresa AND num_credito=cNumCredLN; 
		
		LET vTI_LN_BLOCK_CODE_8 = cBlockCode;

		--TI-LN-BALANCE(8):El saldo en la fecha de vencimiento acutal - 7			
		LET vTI_LN_BALANCE_8 = dSdoTotalLiqLN;
		
		--TI-LN-INSTALLMENT-DUE(8): Pago minimo solicitado en el mesiversario para estar al corriente. 		
		LET vTI_LN_INSTALLMENT_DUE_8 = dPagoMinant;

		--TI-LN-VAL-PAYMENTS(8): El valor de pagos durante el mes. Ciclo actual - 7
		LET vTI_LN_VAL_PAYMENTS_8 = dMontoPagos;
	
		--TI-LN-VAL-ARREARS(8): El valor de los atrasos en la cuenta en el ciclo, Saldo vencido de la cuenta en la fecha de vencimiento (mesiversario correspondiente).		
		LET vTI_LN_VAL_ARREARS_8 = dSdoVencant;
	
		--TI-LN-VAL-INTEREST(8): El monto de los intereses cargados en la cuenta durante el periodo. 		
		LET vTI_LN_VAL_INTEREST_8 = dIntCobrados;
		
		--TI-LN-VAL-TOTAL-FEES(8): Total de comisiones cargadas durante el periodo.
		LET vTI_LN_VAL_TOTAL_FEES_8 = 0;
--9
		--TI-LN-DATE-DUE(9): Fecha de vencimiento del pago de cada mes. Ciclo actual - 8
		LET vTI_LN_DATE_DUE_9 = bdicred:monthadd(dFechaVencidoLN,-8);
		
		--TI-LN-BLOCK-CODE(9): En blanco porque no especificaron para LN 		-		Ciclo actual - 8
		SELECT NVL(cod_bloqueo_cta8,0),NVL(sdo_tot_liquidar8,0),NVL(pago_minimo8,0),NVL(monto_pagos8,0),NVL(sdo_tot_vencido8,0),NVL(intereses_periodo8,0)
		INTO cBlockCode,dSdoTotalLiqLN,dPagoMinant,dMontoPagos,dSdoVencant,dIntCobrados 
		FROM bdicobranza:cb_triad_sdos_inds_cnr 
		WHERE fecha_proceso =(SELECT date(max(fecha_proceso) - 8 units month) FROM bdicobranza:cb_triad_sdos_inds_cnr WHERE empresa= vEmpresa AND num_credito=cNumCredLN)
		AND empresa= vEmpresa AND num_credito=cNumCredLN;
		
		LET vTI_LN_BLOCK_CODE_9 = cBlockCode;
		
		--TI-LN-BALANCE(9):El saldo en la fecha de vencimiento actual - 8				
		LET vTI_LN_BALANCE_9 = dSdoTotalLiqLN;
		
		--TI-LN-INSTALLMENT-DUE(9): Pago minimo solicitado en el mesiversario para estar al corriente. 		
		LET vTI_LN_INSTALLMENT_DUE_9 = dPagoMinant;

		--TI-LN-VAL-PAYMENTS(9): El valor de pagos durante el mes. Ciclo actual - 8		
		LET vTI_LN_VAL_PAYMENTS_9 = dMontoPagos;
	
		--TI-LN-VAL-ARREARS(9): El valor de los atrasos en la cuenta en el ciclo, Saldo vencido de la cuenta en la fecha de vencimiento (mesiversario correspondiente).
		LET vTI_LN_VAL_ARREARS_9 = dSdoVencant;
		
		--TI-LN-VAL-INTEREST(9): El monto de los intereses cargados en la cuenta durante el periodo. 
		LET vTI_LN_VAL_INTEREST_9 = dIntCobrados;
		
		--TI-LN-VAL-TOTAL-FEES(9): Total de comisiones cargadas durante el periodo.
		LET vTI_LN_VAL_TOTAL_FEES_9 = 0;
--10
		--TI-LN-DATE-DUE(10): Fecha de vencimiento del pago de cada mes. Ciclo actual - 9
		LET vTI_LN_DATE_DUE_10 = bdicred:monthadd(dFechaVencidoLN,-9);
		
		--TI-LN-BLOCK-CODE(10): En blanco porque no especificaron para LN 		-		Ciclo actual - 9
		SELECT NVL(cod_bloqueo_cta9,0),NVL(sdo_tot_liquidar9,0),NVL(pago_minimo9,0),NVL(monto_pagos9,0),NVL(sdo_tot_vencido9,0),NVL(intereses_periodo9,0) 
		INTO cBlockCode,dSdoTotalLiqLN,dPagoMinant,dMontoPagos,dSdoVencant,dIntCobrados 
		FROM bdicobranza:cb_triad_sdos_inds_cnr 
		WHERE fecha_proceso =(SELECT date(max(fecha_proceso) - 9 units month) FROM bdicobranza:cb_triad_sdos_inds_cnr WHERE empresa= vEmpresa AND num_credito=cNumCredLN)
		AND empresa= vEmpresa AND num_credito=cNumCredLN;

		LET vTI_LN_BLOCK_CODE_10 = cBlockCode;
		
		--TI-LN-BALANCE(10): El saldo en la fecha de vencimiento actual - 9
		LET vTI_LN_BALANCE_10 = dSdoTotalLiqLN;
		
		--TI-LN-INSTALLMENT-DUE(10): Pago minimo solicitado en el mesiversario para estar al corriente. 
		LET vTI_LN_INSTALLMENT_DUE_10 = dPagoMinant;

		--TI-LN-VAL-PAYMENTS(10): El valor de pagos durante el mes. Ciclo actual - 9		
		LET vTI_LN_VAL_PAYMENTS_10 = dMontoPagos;
	
		--TI-LN-VAL-ARREARS(10): El valor de los atrasos en la cuenta en el ciclo, Saldo vencido de la cuenta en la fecha de vencimiento (mesiversario correspondiente).		
		LET vTI_LN_VAL_ARREARS_10 = dSdoVencant;
				
		--TI-LN-VAL-INTEREST(10): El monto de los intereses cargados en la cuenta durante el periodo. 
		LET vTI_LN_VAL_INTEREST_10 = dIntCobrados;
		
		--TI-LN-VAL-TOTAL-FEES(10): Total de comisiones cargadas durante el periodo.
		LET vTI_LN_VAL_TOTAL_FEES_10 = 0;
--11
		--TI-LN-DATE-DUE(11): Fecha de vencimiento del pago de cada mes. Ciclo actual - 10
		LET vTI_LN_DATE_DUE_11 = bdicred:monthadd(dFechaVencidoLN,-10);
		
		--TI-LN-BLOCK-CODE(11): En blanco porque no especificaron para LN 		-		Ciclo actual - 10
		SELECT NVL(cod_bloqueo_cta10,0),NVL(sdo_tot_liquidar10,0),NVL(pago_minimo10,0),NVL(monto_pagos10,0),NVL(sdo_tot_vencido10,0),NVL(intereses_periodo10,0)
		INTO cBlockCode,dSdoTotalLiqLN,dPagoMinant,dMontoPagos,dSdoVencant,dIntCobrados 
		FROM bdicobranza:cb_triad_sdos_inds_cnr 
		WHERE fecha_proceso =(SELECT date(max(fecha_proceso) - 10 units month) FROM bdicobranza:cb_triad_sdos_inds_cnr WHERE empresa= vEmpresa AND num_credito=cNumCredLN)
		AND empresa= vEmpresa AND num_credito=cNumCredLN;

		LET vTI_LN_BLOCK_CODE_11 = cBlockCode;
		
		--TI-LN-BALANCE(11):El saldo en la fecha de vencimiento actual - 10
		LET vTI_LN_BALANCE_11 = dSdoTotalLiqLN;
		
		--TI-LN-INSTALLMENT-DUE(11): Pago minimo solicitado en el mesiversario para estar al corriente. 		
		LET vTI_LN_INSTALLMENT_DUE_11 = dPagoMinant;

		--TI-LN-VAL-PAYMENTS(11): El valor de pagos durante el mes. Ciclo actual - 10	
		LET vTI_LN_VAL_PAYMENTS_11 = dMontoPagos;
	
		--TI-LN-VAL-ARREARS(11): El valor de los atrasos en la cuenta en el ciclo, Saldo vencido de la cuenta en la fecha de vencimiento (mesiversario correspondiente).		
		LET vTI_LN_VAL_ARREARS_11 = dSdoVencant;

		--TI-LN-VAL-INTEREST(11): El monto de los intereses cargados en la cuenta durante el periodo. 		
		LET vTI_LN_VAL_INTEREST_11 = dIntCobrados;
		
		--TI-LN-VAL-TOTAL-FEES(11): Total de comisiones cargadas durante el periodo.
		LET vTI_LN_VAL_TOTAL_FEES_11 = 0;

--12
		--TI-LN-DATE-DUE(12): Fecha de vencimiento del pago de cada mes. Ciclo actual - 11
		LET vTI_LN_DATE_DUE_12 = bdicred:monthadd(dFechaVencidoLN,-11);
		
		--TI-LN-BLOCK-CODE(12): En blanco porque no especificaron para LN 		-		Ciclo actual - 11
		SELECT NVL(cod_bloqueo_cta11,0),NVL(sdo_tot_liquidar11,0),NVL(pago_minimo11,0),NVL(monto_pagos11,0),NVL(sdo_tot_vencido11,0),NVL(intereses_periodo11,0)
		INTO cBlockCode,dSdoTotalLiqLN,dPagoMinant,dMontoPagos,dSdoVencant,dIntCobrados 
		FROM bdicobranza:cb_triad_sdos_inds_cnr 
		WHERE fecha_proceso =(SELECT date(max(fecha_proceso) - 11 units month) FROM bdicobranza:cb_triad_sdos_inds_cnr WHERE empresa = vEmpresa AND num_credito=cNumCredLN)
		AND empresa= vEmpresa AND num_credito=cNumCredLN; 
		
		LET vTI_LN_BLOCK_CODE_12 = cBlockCode;
			
		--TI-LN-BALANCE(12): El saldo en la fecha de vencimiento actual - 11			
		LET vTI_LN_BALANCE_12 = dSdoTotalLiqLN;
		
		--TI-LN-INSTALLMENT-DUE(12): Pago minimo solicitado en el mesiversario para estar al corriente. 		
		LET vTI_LN_INSTALLMENT_DUE_12 = dPagoMinant;
		
		--TI-LN-VAL-PAYMENTS(12): El valor de pagos durante el mes. Ciclo actual - 11		
		LET vTI_LN_VAL_PAYMENTS_12 = dMontoPagos;
	
		--TI-LN-VAL-ARREARS(12): El valor de los atrasos en la cuenta en el ciclo, Saldo vencido de la cuenta en la fecha de vencimiento (mesiversario correspondiente).
		LET vTI_LN_VAL_ARREARS_12 = dSdoVencant;
		
		--TI-LN-VAL-INTEREST(12): El monto de los intereses cargados en la cuenta durante el periodo. 
		LET vTI_LN_VAL_INTEREST_12 = dIntCobrados;
		
		--TI-LN-VAL-TOTAL-FEES(12): Total de comisiones cargadas durante el periodo.
		LET vTI_LN_VAL_TOTAL_FEES_12 = 0;
--		
		--TI-LN-NUM-MTHS-IN-ARREARS(1):Numero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente)
		LET vTI_LN_NUM_MTHS_IN_ARREARS_1 = iDiasMoraLN;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(2): NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 2Ã?Â?Ã?Â?Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â?Ã?Â?Ã?Â³rico de morosidad, Ciclo actual - 1. 
		SELECT num_vencidos1,num_vencidos2,num_vencidos3,num_vencidos4,num_vencidos5,num_vencidos6,num_vencidos7,num_vencidos8,num_vencidos9,num_vencidos10,
		num_vencidos11,num_vencidos12,num_vencidos13,num_vencidos14,num_vencidos15,num_vencidos16,num_vencidos17,num_vencidos18,num_vencidos19,num_vencidos20,
		num_vencidos21,num_vencidos22,num_vencidos23 
		INTO dVencidosLN_1, dVencidosLN_2,dVencidosLN_3,dVencidosLN_4,dVencidosLN_5,dVencidosLN_6,dVencidosLN_7,dVencidosLN_8,dVencidosLN_9,dVencidosLN_10,
		dVencidosLN_11,dVencidosLN_12,dVencidosLN_13,dVencidosLN_14,dVencidosLN_15,dVencidosLN_16,dVencidosLN_17,dVencidosLN_18,dVencidosLN_19,dVencidosLN_20,
		dVencidosLN_21,dVencidosLN_22,dVencidosLN_23
		FROM bdicobranza:informix.cb_triad_sdos_inds_cnr WHERE num_credito=cNumCredLN;
		
		LET vTI_LN_NUM_MTHS_IN_ARREARS_2 = dVencidosLN_1;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(3):NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 3Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 2. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_3 = dVencidosLN_2;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(4):NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 4Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 3. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_4 = dVencidosLN_3;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(5):NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 5Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 4. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_5 = dVencidosLN_4;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(6):NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 6Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 5. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_6 = dVencidosLN_5;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(7): :NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 7Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 6. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_7 = dVencidosLN_6;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(8): :NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 8Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 7. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_8 = dVencidosLN_7;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(9): NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 9Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 8. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_9 = dVencidosLN_8;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(10):NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 10Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 9. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_10 = dVencidosLN_9;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(11):NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 11Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 10. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_11 = dVencidosLN_10;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(12):NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 12Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 11. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_12 = dVencidosLN_11;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(13):NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 13Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 12. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_13 = dVencidosLN_12;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(14):NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 14Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 13. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_14 = dVencidosLN_13;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(15):NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 15Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 14. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_15 = dVencidosLN_14;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(16):NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 16Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 15. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_16 = dVencidosLN_15;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(17):NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 17Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 16. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_17 = dVencidosLN_16;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(18):NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 18Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 17. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_18 = dVencidosLN_17;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(19):NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 19Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 18. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_19 = dVencidosLN_18;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(20):NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 20Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 19. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_20 = dVencidosLN_19;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(21):NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 21Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 20. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_21 = dVencidosLN_20;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(22):NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 22Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 21. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_22 = dVencidosLN_21;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(23):NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 23Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 22. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_23 = dVencidosLN_22;
		
		--TI-LN-NUM-MTHS-IN-ARREARS(24):NÃ?Â?Ã?Âºmero de meses vencidos de la cuenta en la fecha de vencimiento (mesiversario correspondiente). 24Ã?Â?Ã?Â° acontecimiento histÃ?Â?Ã?Â³rico de morosidad, Ciclo actual - 23. 
		LET vTI_LN_NUM_MTHS_IN_ARREARS_24 = dVencidosLN_23;
		
		--SELECT COUNT(*) into iExisteCuenta
		SELECT empresa into vEmpresa_3
		FROM bdicobranza:cb_triad_plazo
		WHERE empresa=vEmpresa 
		  AND ti_ln_account_id = vTI_LN_ACCOUNT_ID;
		
        IF NVL(vEmpresa_3,'') <> '' and vEmpresa_3 <> '' THEN  let iExisteCuenta = 1; END IF; 
 		
		IF iExisteCuenta > 0 THEN
			begin; 		
				UPDATE bdicobranza:"informix".cb_triad_plazo
				SET 
					ti_ln_date_open = vTI_LN_DATE_OPEN,
					ti_ln_account_type = vTI_LN_ACCOUNT_TYPE, 
					ti_ln_original_term = vTI_LN_ORIGINAL_TERM,
					ti_ln_remaining_term = vTI_LN_REMAINING_TERM,
					ti_ln_original_loan_amount = vTI_LN_ORIGINAL_LOAN_AMOUNT,
					ti_ln_date_start_arrears = vTI_LN_DATE_START_ARREARS,
					ti_ln_date_first_installment = vTI_LN_DATE_FIRST_INSTALLMENT,
					ti_ln_date_last_pay = vTI_LN_DATE_LAST_PAY,
					ti_ln_stndrd_installment_amt = vTI_LN_STNDRD_INSTALLMENT_AMT,
					ti_ln_triad_cat = vTI_LN_TRIAD_CAT,

					ti_ln_date_due_1 = vTI_LN_DATE_DUE_1,
					ti_ln_block_code_1 = vTI_LN_BLOCK_CODE_1,
					ti_ln_balance_1 = vTI_LN_BALANCE_1,
					ti_ln_installment_due_1 = vTI_LN_INSTALLMENT_DUE_1,
					ti_ln_val_payments_1 = vTI_LN_VAL_PAYMENTS_1,
					ti_ln_val_arrears_1 = vTI_LN_VAL_ARREARS_1,
					ti_ln_val_interest_1 = vTI_LN_VAL_INTEREST_1,

					ti_ln_date_due_2 = vTI_LN_DATE_DUE_2,
					ti_ln_block_code_2 = vTI_LN_BLOCK_CODE_2,
					ti_ln_balance_2 = vTI_LN_BALANCE_2,
					ti_ln_installment_due_2 = vTI_LN_INSTALLMENT_DUE_2,
					ti_ln_val_payments_2 = vTI_LN_VAL_PAYMENTS_2,
					ti_ln_val_arrears_2 = vTI_LN_VAL_ARREARS_2,
					ti_ln_val_interest_2 = vTI_LN_VAL_INTEREST_2,

					ti_ln_date_due_3 = vTI_LN_DATE_DUE_3,
					ti_ln_block_code_3 = vTI_LN_BLOCK_CODE_3,
					ti_ln_balance_3 = vTI_LN_BALANCE_3,
					ti_ln_installment_due_3 = vTI_LN_INSTALLMENT_DUE_3,
					ti_ln_val_payments_3 = vTI_LN_VAL_PAYMENTS_3,
					ti_ln_val_arrears_3 = vTI_LN_VAL_ARREARS_3,
					ti_ln_val_interest_3 = vTI_LN_VAL_INTEREST_3,

					ti_ln_date_due_4 = vTI_LN_DATE_DUE_4,
					ti_ln_block_code_4 = vTI_LN_BLOCK_CODE_4,
					ti_ln_balance_4 = vTI_LN_BALANCE_4,
					ti_ln_installment_due_4 = vTI_LN_INSTALLMENT_DUE_4,
					ti_ln_val_payments_4 = vTI_LN_VAL_PAYMENTS_4,
					ti_ln_val_arrears_4 = vTI_LN_VAL_ARREARS_4,
					ti_ln_val_interest_4 = vTI_LN_VAL_INTEREST_4,

					ti_ln_date_due_5 = vTI_LN_DATE_DUE_5,
					ti_ln_block_code_5 = vTI_LN_BLOCK_CODE_5,
					ti_ln_balance_5 = vTI_LN_BALANCE_5,
					ti_ln_installment_due_5 = vTI_LN_INSTALLMENT_DUE_5,
					ti_ln_val_payments_5 = vTI_LN_VAL_PAYMENTS_5,
					ti_ln_val_arrears_5 = vTI_LN_VAL_ARREARS_5,
					ti_ln_val_interest_5 = vTI_LN_VAL_INTEREST_5,

					ti_ln_date_due_6 = vTI_LN_DATE_DUE_6,
					ti_ln_block_code_6 = vTI_LN_BLOCK_CODE_6,
					ti_ln_balance_6 = vTI_LN_BALANCE_6,
					ti_ln_installment_due_6 = vTI_LN_INSTALLMENT_DUE_6,
					ti_ln_val_payments_6 = vTI_LN_VAL_PAYMENTS_6,
					ti_ln_val_arrears_6 = vTI_LN_VAL_ARREARS_6,
					ti_ln_val_interest_6 = vTI_LN_VAL_INTEREST_6,

					ti_ln_date_due_7 = vTI_LN_DATE_DUE_7,
					ti_ln_block_code_7 = vTI_LN_BLOCK_CODE_7,
					ti_ln_balance_7 = vTI_LN_BALANCE_7,
					ti_ln_installment_due_7 = vTI_LN_INSTALLMENT_DUE_7,
					ti_ln_val_payments_7 = vTI_LN_VAL_PAYMENTS_7,
					ti_ln_val_arrears_7 = vTI_LN_VAL_ARREARS_7,
					ti_ln_val_interest_7 = vTI_LN_VAL_INTEREST_7,

					ti_ln_date_due_8 = vTI_LN_DATE_DUE_8,
					ti_ln_block_code_8 = vTI_LN_BLOCK_CODE_8,
					ti_ln_balance_8 = vTI_LN_BALANCE_8,
					ti_ln_installment_due_8 = vTI_LN_INSTALLMENT_DUE_8,
					ti_ln_val_payments_8 = vTI_LN_VAL_PAYMENTS_8,
					ti_ln_val_arrears_8 = vTI_LN_VAL_ARREARS_8,
					ti_ln_val_interest_8 = vTI_LN_VAL_INTEREST_8,

					ti_ln_date_due_9 = vTI_LN_DATE_DUE_9,
					ti_ln_block_code_9 = vTI_LN_BLOCK_CODE_9,
					ti_ln_balance_9 = vTI_LN_BALANCE_9,
					ti_ln_installment_due_9 = vTI_LN_INSTALLMENT_DUE_9,
					ti_ln_val_payments_9 = vTI_LN_VAL_PAYMENTS_9,
					ti_ln_val_arrears_9 = vTI_LN_VAL_ARREARS_9,
					ti_ln_val_interest_9 = vTI_LN_VAL_INTEREST_9,

					ti_ln_date_due_10 = vTI_LN_DATE_DUE_10,
					ti_ln_block_code_10 = vTI_LN_BLOCK_CODE_10,
					ti_ln_balance_10 = vTI_LN_BALANCE_10,
					ti_ln_installment_due_10 = vTI_LN_INSTALLMENT_DUE_10,
					ti_ln_val_payments_10 = vTI_LN_VAL_PAYMENTS_10,
					ti_ln_val_arrears_10 = vTI_LN_VAL_ARREARS_10,
					ti_ln_val_interest_10 = vTI_LN_VAL_INTEREST_10,
					
					ti_ln_date_due_11 = vTI_LN_DATE_DUE_11,
					ti_ln_block_code_11 = vTI_LN_BLOCK_CODE_11,
					ti_ln_balance_11 = vTI_LN_BALANCE_11,
					ti_ln_installment_due_11 = vTI_LN_INSTALLMENT_DUE_11,
					ti_ln_val_payments_11 = vTI_LN_VAL_PAYMENTS_11,
					ti_ln_val_arrears_11 = vTI_LN_VAL_ARREARS_11,
					ti_ln_val_interest_11 = vTI_LN_VAL_INTEREST_11,
					
					ti_ln_date_due_12 = vTI_LN_DATE_DUE_12,
					ti_ln_block_code_12 = vTI_LN_BLOCK_CODE_12,	
					ti_ln_balance_12 = vTI_LN_BALANCE_12,
					ti_ln_installment_due_12 = vTI_LN_INSTALLMENT_DUE_12,
					ti_ln_val_payments_12 = vTI_LN_VAL_PAYMENTS_12,
					ti_ln_val_arrears_12 = vTI_LN_VAL_ARREARS_12,
					ti_ln_val_interest_12 = vTI_LN_VAL_INTEREST_12,
					
					ti_ln_num_mths_in_arrears_1 = vTI_LN_NUM_MTHS_IN_ARREARS_1,
					ti_ln_num_mths_in_arrears_2 = vTI_LN_NUM_MTHS_IN_ARREARS_2,
					ti_ln_num_mths_in_arrears_3 = vTI_LN_NUM_MTHS_IN_ARREARS_3,
					ti_ln_num_mths_in_arrears_4 = vTI_LN_NUM_MTHS_IN_ARREARS_4,
					ti_ln_num_mths_in_arrears_5 = vTI_LN_NUM_MTHS_IN_ARREARS_5,
					ti_ln_num_mths_in_arrears_6 = vTI_LN_NUM_MTHS_IN_ARREARS_6,
					ti_ln_num_mths_in_arrears_7 = vTI_LN_NUM_MTHS_IN_ARREARS_7,
					ti_ln_num_mths_in_arrears_8 = vTI_LN_NUM_MTHS_IN_ARREARS_8,
					ti_ln_num_mths_in_arrears_9 = vTI_LN_NUM_MTHS_IN_ARREARS_9,
					ti_ln_num_mths_in_arrears_10 = vTI_LN_NUM_MTHS_IN_ARREARS_10,
					ti_ln_num_mths_in_arrears_11 = vTI_LN_NUM_MTHS_IN_ARREARS_11,
					ti_ln_num_mths_in_arrears_12 = vTI_LN_NUM_MTHS_IN_ARREARS_12,
					ti_ln_num_mths_in_arrears_13 = vTI_LN_NUM_MTHS_IN_ARREARS_13,
					ti_ln_num_mths_in_arrears_14 = vTI_LN_NUM_MTHS_IN_ARREARS_14,
					ti_ln_num_mths_in_arrears_15 = vTI_LN_NUM_MTHS_IN_ARREARS_15,
					ti_ln_num_mths_in_arrears_16 = vTI_LN_NUM_MTHS_IN_ARREARS_16,
					ti_ln_num_mths_in_arrears_17 = vTI_LN_NUM_MTHS_IN_ARREARS_17,
					ti_ln_num_mths_in_arrears_18 = vTI_LN_NUM_MTHS_IN_ARREARS_18,
					ti_ln_num_mths_in_arrears_19 = vTI_LN_NUM_MTHS_IN_ARREARS_19,
					ti_ln_num_mths_in_arrears_20 = vTI_LN_NUM_MTHS_IN_ARREARS_20,
					ti_ln_num_mths_in_arrears_21 = vTI_LN_NUM_MTHS_IN_ARREARS_21,
					ti_ln_num_mths_in_arrears_22 = vTI_LN_NUM_MTHS_IN_ARREARS_22,
					ti_ln_num_mths_in_arrears_23 = vTI_LN_NUM_MTHS_IN_ARREARS_23,
					ti_ln_num_mths_in_arrears_24 = vTI_LN_NUM_MTHS_IN_ARREARS_24,
					fecha_proceso = vFechahoy
					
					WHERE empresa=vEmpresa AND ti_ln_account_id = cNumCredLN;
			commit;
		ELSE 
		
			--------------------------------------------------------------------------------------------------------------------
			begin;
				 insert into bdicobranza:"informix".cb_triad_plazo(empresa, ti_ln_customer_id, ti_ln_account_id, ti_ln_date_open, ti_ln_account_type, ti_ln_original_term,ti_ln_remaining_term,
				 ti_ln_original_loan_amount, ti_ln_date_start_arrears, ti_ln_date_first_installment,ti_ln_date_last_pay,ti_ln_stndrd_installment_amt,ti_ln_triad_cat,
				 ti_ln_date_due_1,ti_ln_block_code_1, ti_ln_balance_1, ti_ln_installment_due_1, ti_ln_val_payments_1,ti_ln_val_arrears_1, ti_ln_val_interest_1, ti_ln_val_total_fees_1,
				 ti_ln_date_due_2, ti_ln_block_code_2, ti_ln_balance_2, ti_ln_installment_due_2, ti_ln_val_payments_2, ti_ln_val_arrears_2, ti_ln_val_interest_2, 
				 ti_ln_val_total_fees_2, ti_ln_date_due_3, ti_ln_block_code_3, ti_ln_balance_3, ti_ln_installment_due_3, ti_ln_val_payments_3, ti_ln_val_arrears_3,
				 ti_ln_val_interest_3, ti_ln_val_total_fees_3, ti_ln_date_due_4, ti_ln_block_code_4, ti_ln_balance_4, ti_ln_installment_due_4, ti_ln_val_payments_4,
				 ti_ln_val_arrears_4, ti_ln_val_interest_4, ti_ln_val_total_fees_4, ti_ln_date_due_5, ti_ln_block_code_5, ti_ln_balance_5, ti_ln_installment_due_5,
				 ti_ln_val_payments_5, ti_ln_val_arrears_5, ti_ln_val_interest_5, ti_ln_val_total_fees_5, ti_ln_date_due_6, ti_ln_block_code_6, ti_ln_balance_6,
				 ti_ln_installment_due_6, ti_ln_val_payments_6, ti_ln_val_arrears_6, ti_ln_val_interest_6, ti_ln_val_total_fees_6, ti_ln_date_due_7, ti_ln_block_code_7,
				 ti_ln_balance_7, ti_ln_installment_due_7, ti_ln_val_payments_7, ti_ln_val_arrears_7, ti_ln_val_interest_7, ti_ln_val_total_fees_7, ti_ln_date_due_8,
				 ti_ln_block_code_8, ti_ln_balance_8, ti_ln_installment_due_8, ti_ln_val_payments_8, ti_ln_val_arrears_8, ti_ln_val_interest_8, ti_ln_val_total_fees_8,
				 ti_ln_date_due_9, ti_ln_block_code_9, ti_ln_balance_9, ti_ln_installment_due_9, ti_ln_val_payments_9, ti_ln_val_arrears_9, ti_ln_val_interest_9, 
				 ti_ln_val_total_fees_9, ti_ln_date_due_10, ti_ln_block_code_10, ti_ln_balance_10, ti_ln_installment_due_10, ti_ln_val_payments_10, ti_ln_val_arrears_10,
				 ti_ln_val_interest_10, ti_ln_val_total_fees_10, ti_ln_date_due_11, ti_ln_block_code_11, ti_ln_balance_11, ti_ln_installment_due_11, 
				 ti_ln_val_payments_11, ti_ln_val_arrears_11, ti_ln_val_interest_11, ti_ln_val_total_fees_11, ti_ln_date_due_12, ti_ln_block_code_12, ti_ln_balance_12,
				 ti_ln_installment_due_12, ti_ln_val_payments_12, ti_ln_val_arrears_12, ti_ln_val_interest_12, ti_ln_val_total_fees_12, ti_ln_num_mths_in_arrears_1, 
				 ti_ln_num_mths_in_arrears_2, ti_ln_num_mths_in_arrears_3, ti_ln_num_mths_in_arrears_4, ti_ln_num_mths_in_arrears_5, ti_ln_num_mths_in_arrears_6,
				 ti_ln_num_mths_in_arrears_7, ti_ln_num_mths_in_arrears_8, ti_ln_num_mths_in_arrears_9, ti_ln_num_mths_in_arrears_10, ti_ln_num_mths_in_arrears_11, 
				 ti_ln_num_mths_in_arrears_12, ti_ln_num_mths_in_arrears_13, ti_ln_num_mths_in_arrears_14, ti_ln_num_mths_in_arrears_15, ti_ln_num_mths_in_arrears_16,
				 ti_ln_num_mths_in_arrears_17, ti_ln_num_mths_in_arrears_18, ti_ln_num_mths_in_arrears_19, ti_ln_num_mths_in_arrears_20, ti_ln_num_mths_in_arrears_21,
				 ti_ln_num_mths_in_arrears_22, ti_ln_num_mths_in_arrears_23, ti_ln_num_mths_in_arrears_24, fecha_proceso 	 
				 )
				 values(vEmpresa, vti_ln_customer_id, vTI_LN_ACCOUNT_ID, vti_ln_date_open,vti_ln_account_type,vti_ln_original_term, vti_ln_remaining_term, 
				 vti_ln_original_loan_amount, vti_ln_date_start_arrears, vti_ln_date_first_installment,vti_ln_date_last_pay, vti_ln_stndrd_installment_amt, vti_ln_triad_cat, 
				 vti_ln_date_due_1, vti_ln_block_code_1, vti_ln_balance_1, vti_ln_installment_due_1, vti_ln_val_payments_1, vti_ln_val_arrears_1, vti_ln_val_interest_1, vti_ln_val_total_fees_1,
				 vti_ln_date_due_2, vti_ln_block_code_2, vti_ln_balance_2, vti_ln_installment_due_2, vti_ln_val_payments_2, vti_ln_val_arrears_2, vti_ln_val_interest_2, 
				 vti_ln_val_total_fees_2, vti_ln_date_due_3, vti_ln_block_code_3, vti_ln_balance_3, vti_ln_installment_due_3, vti_ln_val_payments_3, vti_ln_val_arrears_3,
				 vti_ln_val_interest_3, vti_ln_val_total_fees_3, vti_ln_date_due_4, vti_ln_block_code_4, vti_ln_balance_4, vti_ln_installment_due_4, vti_ln_val_payments_4,
				 vti_ln_val_arrears_4, vti_ln_val_interest_4, vti_ln_val_total_fees_4, vti_ln_date_due_5, vti_ln_block_code_5, vti_ln_balance_5, vti_ln_installment_due_5,
				 vti_ln_val_payments_5, vti_ln_val_arrears_5, vti_ln_val_interest_5, vti_ln_val_total_fees_5, vti_ln_date_due_6, vti_ln_block_code_6, vti_ln_balance_6,
				 vti_ln_installment_due_6, vti_ln_val_payments_6, vti_ln_val_arrears_6, vti_ln_val_interest_6, vti_ln_val_total_fees_6, vti_ln_date_due_7, vti_ln_block_code_7,
				 vti_ln_balance_7, vti_ln_installment_due_7, vti_ln_val_payments_7, vti_ln_val_arrears_7, vti_ln_val_interest_7, vti_ln_val_total_fees_7, vti_ln_date_due_8,
				 vti_ln_block_code_8, vti_ln_balance_8, vti_ln_installment_due_8, vti_ln_val_payments_8, vti_ln_val_arrears_8, vti_ln_val_interest_8, vti_ln_val_total_fees_8,
				 vti_ln_date_due_9, vti_ln_block_code_9, vti_ln_balance_9, vti_ln_installment_due_9, vti_ln_val_payments_9, vti_ln_val_arrears_9, vti_ln_val_interest_9, 
				 vti_ln_val_total_fees_9, vti_ln_date_due_10, vti_ln_block_code_10, vti_ln_balance_10, vti_ln_installment_due_10, vti_ln_val_payments_10, vti_ln_val_arrears_10,
				 vti_ln_val_interest_10, vti_ln_val_total_fees_10, vti_ln_date_due_11, vti_ln_block_code_11, vti_ln_balance_11, vti_ln_installment_due_11, 
				 vti_ln_val_payments_11, vti_ln_val_arrears_11, vti_ln_val_interest_11, vti_ln_val_total_fees_11, vti_ln_date_due_12, vti_ln_block_code_12, vti_ln_balance_12,
				 vti_ln_installment_due_12, vti_ln_val_payments_12, vti_ln_val_arrears_12, vti_ln_val_interest_12, vti_ln_val_total_fees_12, vti_ln_num_mths_in_arrears_1, 
				 vti_ln_num_mths_in_arrears_2, vti_ln_num_mths_in_arrears_3, vti_ln_num_mths_in_arrears_4, vti_ln_num_mths_in_arrears_5, vti_ln_num_mths_in_arrears_6,
				 vti_ln_num_mths_in_arrears_7, vti_ln_num_mths_in_arrears_8, vti_ln_num_mths_in_arrears_9, vti_ln_num_mths_in_arrears_10, vti_ln_num_mths_in_arrears_11, 
				 vti_ln_num_mths_in_arrears_12, vti_ln_num_mths_in_arrears_13, vti_ln_num_mths_in_arrears_14, vti_ln_num_mths_in_arrears_15, vti_ln_num_mths_in_arrears_16,
				 vti_ln_num_mths_in_arrears_17, vti_ln_num_mths_in_arrears_18, vti_ln_num_mths_in_arrears_19, vti_ln_num_mths_in_arrears_20, vti_ln_num_mths_in_arrears_21,
				 vti_ln_num_mths_in_arrears_22, vti_ln_num_mths_in_arrears_23, vti_ln_num_mths_in_arrears_24, vFechahoy
				 );
			 commit;
		END IF;
---------------------------------------------------------------------------------------------------------------------		 

	LET iExisteCuenta					= 0;
	LET vTI_LN_CUSTOMER_ID 				= '                    ';
	LET vTI_LN_ACCOUNT_ID 				= '                    ';
	LET vTI_LN_DATE_OPEN 				= DATE(1);
	LET vTI_LN_ACCOUNT_TYPE 			= 0;
	LET vTI_LN_ORIGINAL_TERM 			= '+000';
	LET vTI_LN_REMAINING_TERM 			= 0;
	LET vTI_LN_ORIGINAL_LOAN_AMOUNT 	= 0;
	LET vTI_LN_DATE_START_ARREARS 		= DATE(1);
	LET vTI_LN_DATE_FIRST_INSTALLMENT	= DATE(1);
	LET vTI_LN_DATE_LAST_PAY 			= DATE(1);
	LET vTI_LN_STNDRD_INSTALLMENT_AMT 	= 0.00;	
	LET vTI_LN_TRIAD_CAT 				= '00';
	LET vTI_LN_DATE_DUE_1 				= DATE(1);
	LET vTI_LN_BLOCK_CODE_1 			= '00';
	LET vTI_LN_BALANCE_1 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_1 		= 0;
	LET vTI_LN_VAL_PAYMENTS_1 			= 0;
	LET vTI_LN_VAL_ARREARS_1 			= 0;
	LET vTI_LN_VAL_INTEREST_1 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_1 		= 0;
	LET vTI_LN_DATE_DUE_2 				= 0;
	LET vTI_LN_BLOCK_CODE_2 			= '00';
	LET vTI_LN_BALANCE_2 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_2 		= 0;
	LET vTI_LN_VAL_PAYMENTS_2 			= 0;
	LET vTI_LN_VAL_ARREARS_2 			= 0;
	LET vTI_LN_VAL_INTEREST_2 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_2 		= 0;
	LET vTI_LN_DATE_DUE_3 				= DATE(1);
	LET vTI_LN_BLOCK_CODE_3 			= '00';
	LET vTI_LN_BALANCE_3 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_3 		= 0;
	LET vTI_LN_VAL_PAYMENTS_3 			= 0;
	LET vTI_LN_VAL_ARREARS_3 			= 0;
	LET vTI_LN_VAL_INTEREST_3 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_3 		= 0;
	LET vTI_LN_DATE_DUE_4 				= DATE(1);
	LET vTI_LN_BLOCK_CODE_4 			= '00';
	LET vTI_LN_BALANCE_4 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_4 		= 0;
	LET vTI_LN_VAL_PAYMENTS_4 			= 0;
	LET vTI_LN_VAL_ARREARS_4 			= 0;
	LET vTI_LN_VAL_INTEREST_4 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_4 		= 0;
	LET vTI_LN_DATE_DUE_5 				= DATE(1);
	LET vTI_LN_BLOCK_CODE_5 			= '00';
	LET vTI_LN_BALANCE_5 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_5 		= 0;
	LET vTI_LN_VAL_PAYMENTS_5 			= 0;
	LET vTI_LN_VAL_ARREARS_5 			= 0;
	LET vTI_LN_VAL_INTEREST_5 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_5 			= 0;
	LET vTI_LN_DATE_DUE_6 				= DATE(1);
	LET vTI_LN_BLOCK_CODE_6 			= '00';
	LET vTI_LN_BALANCE_6 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_6 		= 0;
	LET vTI_LN_VAL_PAYMENTS_6 			= 0;
	LET vTI_LN_VAL_ARREARS_6 			= 0;
	LET vTI_LN_VAL_INTEREST_6 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_6 		= 0;
	LET vTI_LN_DATE_DUE_7 				= DATE(1);
	LET vTI_LN_BLOCK_CODE_7 			= '00';
	LET vTI_LN_BALANCE_7	 			= 0;
	LET vTI_LN_INSTALLMENT_DUE_7 		= 0;
	LET vTI_LN_VAL_PAYMENTS_7 			= 0;
	LET vTI_LN_VAL_ARREARS_7 			= 0;
	LET vTI_LN_VAL_INTEREST_7	 		= 0;
	LET vTI_LN_VAL_TOTAL_FEES_7 		= 0;
	LET vTI_LN_DATE_DUE_8 				= DATE(1);
	LET vTI_LN_BLOCK_CODE_8 			= '00';
	LET vTI_LN_BALANCE_8 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_8 		= 0;
	LET vTI_LN_VAL_PAYMENTS_8 			= 0;
	LET vTI_LN_VAL_ARREARS_8 			= 0;
	LET vTI_LN_VAL_INTEREST_8 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_8 		= 0;
	LET vTI_LN_DATE_DUE_9 				= DATE(1);
	LET vTI_LN_BLOCK_CODE_9 			= '00';
	LET vTI_LN_BALANCE_9 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_9 		= 0;
	LET vTI_LN_VAL_PAYMENTS_9 			= 0;
	LET vTI_LN_VAL_ARREARS_9 			= 0;
	LET vTI_LN_VAL_INTEREST_9 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_9 		= 0;
	LET vTI_LN_DATE_DUE_10		 		= DATE(1);
	LET vTI_LN_BLOCK_CODE_10 			= '00';
	LET vTI_LN_BALANCE_10 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_10 		= 0;
	LET vTI_LN_VAL_PAYMENTS_10 			= 0;
	LET vTI_LN_VAL_ARREARS_10 			= 0;
	LET vTI_LN_VAL_INTEREST_10 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_10 		= 0;
	LET vTI_LN_DATE_DUE_11 				= DATE(1);
	LET vTI_LN_BLOCK_CODE_11 			= '00';
	LET vTI_LN_BALANCE_11 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_11	 	= 0;
	LET vTI_LN_VAL_PAYMENTS_11 			= 0;
	LET vTI_LN_VAL_ARREARS_11 			= 0;
	LET vTI_LN_VAL_INTEREST_11 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_11 		= 0;
	LET vTI_LN_DATE_DUE_12 		 		= DATE(1);
	LET vTI_LN_BLOCK_CODE_12 			= '00';
	LET vTI_LN_BALANCE_12 				= 0;
	LET vTI_LN_INSTALLMENT_DUE_12 		= 0;
	LET vTI_LN_VAL_PAYMENTS_12 			= 0;
	LET vTI_LN_VAL_ARREARS_12 			= 0;
	LET vTI_LN_VAL_INTEREST_12 			= 0;
	LET vTI_LN_VAL_TOTAL_FEES_12 		= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_1 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_2 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_3 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_4 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_5 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_6 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_7 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_8 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_9 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_10 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_11 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_12 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_13 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_14 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_15 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_16 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_17 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_18 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_19 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_20 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_21 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_22 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_23 	= 0;
	LET vTI_LN_NUM_MTHS_IN_ARREARS_24 	= 0;
	LET iExisteCuenta = 0;
	LET vEmpresa_3 = '';
	
	--COMMIT WORK;
  
  end foreach
  
 LET cContGral = iContGral;
 CALL bdicobranza:sp_inserta_bitacora_cob_2(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2; 
 
 LET cMensaje = trim(cMensaje) || '. ' || trim(cContGral) || ' registros procesados.';
 --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2; 
 
	RETURN cCodRet, trim(cMensaje);
END
END PROCEDURE;