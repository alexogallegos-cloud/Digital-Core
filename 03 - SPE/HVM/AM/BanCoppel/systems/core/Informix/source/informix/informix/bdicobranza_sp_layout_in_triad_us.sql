CREATE PROCEDURE "informix".sp_layout_in_triad_us(pEjecucion smallint)

RETURNING CHAR(6), char(80);
  -- vers 1.0.6 20200626, 1.0.5. 20200227, 1.0.4 20200213, 1.0.3 20190822, 1.0.2 20190409, 1.0.1 20171229 
  DEFINE vDataErr			VARCHAR(64);
  DEFINE iSqlErr			INTEGER;
  DEFINE iSamErr			INTEGER;
  DEFINE cCodRet			CHAR(6);
  DEFINE dtFecha			DATE;
  DEFINE vNomarchivo  CHAR(70); 
  DEFINE cRuta        CHAR(20);
  define cMensaje     char(80);

	define vEmpresa               char(3);
	define v_numcte_ref           char(20); 
	define vSitesp                integer;
	define vCuentaTels            integer;
	define vCuentaEmails          integer;
	define vFechahoy              date;
	define vFechaDiaAnt			  date;
	define vPriDiaMes             date;
	define vfecha_fin_mes_ant     date;
	define vFechacorte            date;
	DEFINE cFechacorte			  CHAR(8);
	define vFechacorteant         date;
	define vFechacorte_24MsAntes  date;
	define v_evalua_cc            char(1);
	define iIdUnidadProd          integer;
	define vNumvencidos           integer;
	define cContadorTarjetas      char(3);
	 
	 
	 define vCod_retorno      char(6);
	 define vMsj_retorno      char(80);
	 define vDiacorte         INT;
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
	 define cTipoProd         char(1);
	 define cFechaIniMora     char(8); 
	 define cCadena1          char(40);
	 define iContGral         integer;
	 DEFINE cTotalCuentas	  CHAR(1);
	 DEFINE iExisteCuenta	  INTEGER;
	 DEFINE iTotalCuentas 	  INTEGER;
	 DEFINE vContador		  INTEGER;
	 define iScoreBehavior    INTEGER;
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
	 define dFechaMax_CleanBehav     DATE;
     define dFechaMax_Dirty          DATE;

	 DEFINE pNumCredIni		CHAR(20);
	 DEFINE pNumCredFin		CHAR(20);
	 DEFINE cred_ini		CHAR(20);
	 DEFINE cred_fin		CHAR(20);
	 DEFINE vEmpresa_2      CHAR(3);
	 DEFINE cEmpresa_10		CHAR(3);
	 DEFINE cScoreBehavior  CHAR(4);
	 
	---------------------------------------------------
	--REVISAR MARCO, NO DECLARADOS EN EL PRINCIPAL
	DEFINE TI_LN_CYCLES_DELQ_1 CHAR(1);
	DEFINE TI_LN_CYCLES_DELQ_2 CHAR(1);
	DEFINE ti_us_user_d_key_n_1 CHAR (1);
	DEFINE ti_us_user_d_key_n_27 CHAR (1);

	--SOLO ESTAN INICIALIZADAS EN EL SP PRINCIPAL
	DEFINE TI_RV_CYCLES_DELQ_1 CHAR(1);
	DEFINE TI_RV_CYCLES_DELQ_2 CHAR(1);
	---------------------------------------------------
	--US 
	DEFINE vTI_US_ACCOUNT_ID CHAR(20);
	DEFINE vTI_US_CUSTOMER_ID CHAR(20);
	DEFINE vTI_US_USER_DEFINED_KEY_N_67  INTEGER;
	DEFINE vTI_US_USER_DEFINED_KEY_N_68  INTEGER;
	DEFINE vTI_US_USER_DEFINED_KEY_N_69  INTEGER;
	DEFINE vTI_US_USER_DEFINED_KEY_N_70  INTEGER;
	DEFINE vTI_US_USER_DEFINED_KEY_N_71  INTEGER;
	DEFINE vTI_US_USER_DEFINED_KEY_N_72  INTEGER;
	DEFINE vTI_US_USER_DEFINED_KEY_N_73  INTEGER;
	DEFINE vTI_US_USER_DEFINED_KEY_N_74  INTEGER;
	DEFINE vTI_US_USER_DEFINED_KEY_N_75  DECIMAL(18,2);
	DEFINE vTI_US_USER_DEFINED_KEY_N_76  INTEGER;
	DEFINE vTI_US_USER_DEFINED_KEY_N_77  INTEGER;
	DEFINE vTI_US_USER_DEFINED_KEY_N_78  INTEGER;
	DEFINE vTI_US_USER_DEFINED_KEY_N_79  INTEGER;
	DEFINE vTI_US_USER_DEFINED_KEY_N_80  INTEGER;
	DEFINE vTI_US_USER_DEFINED_KEY_N_81  INTEGER;
	DEFINE vTI_US_USER_DEFINED_KEY_N_82  INTEGER;
	DEFINE vTI_US_USER_DEFINED_KEY_N_83  INTEGER;
	DEFINE vTI_US_USER_DEFINED_KEY_N_84  INTEGER;
	DEFINE vTI_US_USER_DEFINED_KEY_N_85  INTEGER;
	DEFINE vTI_US_USER_DEFINED_KEY_N_86  INTEGER;
	-----------------------------------------------
	
	DEFINE vTI_US_CANTIDAD_CUENTA  			INTEGER;
	DEFINE vTI_US_CT_CICLO_MOR_1  			INTEGER;
	DEFINE vTI_US_CT_CICLO_MOR_MES_ANT_1  	INTEGER;
	DEFINE vTI_US_CT_ID_1  					CHAR(20);
	DEFINE vTI_US_CT_TIPO_1  				INTEGER;
	DEFINE vTI_US_CT_FECHA_APERTURA_1  		DATE;
	DEFINE vTI_US_CT_FRECUENCIA_PAGO_1  	INTEGER;
	DEFINE vTI_US_CT_LIMITE_1  				DECIMAL(18,2);
	DEFINE vTI_US_CT_PEOR_CICLO_MOR_U12M_1  INTEGER;
	DEFINE vTI_US_CT_PLAZO_1  				INTEGER;
	DEFINE vTI_US_CT_SALDO_1  				DECIMAL(18,2);
	DEFINE vTI_US_CT_SALDO_VENCIDO_1  char(9);
	DEFINE vTI_US_CT_SCORE_1  				INTEGER;
	DEFINE vTI_US_CT_SCORE_ID_1  			INTEGER;
	DEFINE vTI_US_CT_TIPO_PROD_1  			INTEGER;
	DEFINE TI_US_CT_CICLO_MOR_2  char(1);
	DEFINE TI_US_CT_CICLO_MOR_MES_ANT_2  char(1);
	DEFINE TI_US_CT_ID_2  char(20);
	DEFINE TI_US_CT_TIPO_2  char(3);
	DEFINE TI_US_CT_FECHA_APERTURA_2  char(8);
	DEFINE TI_US_CT_FRECUENCIA_PAGO_2  char(1);
	DEFINE TI_US_CT_LIMITE_2  char(9);
	DEFINE TI_US_CT_PEOR_CICLO_MOR_U12M_2  char(1);
	DEFINE TI_US_CT_PLAZO_2  char(3);
	DEFINE TI_US_CT_SALDO_2  char(9);
	DEFINE TI_US_CT_SALDO_VENCIDO_2  char(9);
	DEFINE TI_US_CT_SCORE_2  char(9);
	DEFINE TI_US_CT_SCORE_ID_2  char(4);
	DEFINE TI_US_CT_TIPO_PROD_2  char(1);
	DEFINE TI_US_CT_CICLO_MOR_3  char(1);
	DEFINE TI_US_CT_CICLO_MOR_MES_ANT_3  char(1);
	DEFINE TI_US_CT_ID_3  char(20);
	DEFINE TI_US_CT_TIPO_3  char(3);
	DEFINE TI_US_CT_FECHA_APERTURA_3  char(8);
	DEFINE TI_US_CT_FRECUENCIA_PAGO_3  char(1);
	DEFINE TI_US_CT_LIMITE_3  char(9);
	DEFINE TI_US_CT_PEOR_CICLO_MOR_U12M_3  char(1);
	DEFINE TI_US_CT_PLAZO_3  char(3);
	DEFINE TI_US_CT_SALDO_3  char(9);
	DEFINE TI_US_CT_SALDO_VENCIDO_3  char(9);
	DEFINE TI_US_CT_SCORE_3  char(9);
	DEFINE TI_US_CT_SCORE_ID_3  char(4);
	DEFINE TI_US_CT_TIPO_PROD_3  char(1);
	DEFINE TI_US_CT_CICLO_MOR_4  char(1);
	DEFINE TI_US_CT_CICLO_MOR_MES_ANT_4  char(1);
	DEFINE TI_US_CT_ID_4  char(20);
	DEFINE TI_US_CT_TIPO_4  char(3);
	DEFINE TI_US_CT_FECHA_APERTURA_4  char(8);
	DEFINE TI_US_CT_FRECUENCIA_PAGO_4  char(1);
	DEFINE TI_US_CT_LIMITE_4  char(9);
	DEFINE TI_US_CT_PEOR_CICLO_MOR_U12M_4  char(1);
	DEFINE TI_US_CT_PLAZO_4  char(3);
	DEFINE TI_US_CT_SALDO_4  char(9);
	DEFINE TI_US_CT_SALDO_VENCIDO_4  char(9);
	DEFINE TI_US_CT_SCORE_4  char(9);
	DEFINE TI_US_CT_SCORE_ID_4  char(4);
	DEFINE TI_US_CT_TIPO_PROD_4  char(1);
	DEFINE TI_US_CT_CICLO_MOR_5  char(1);
	DEFINE TI_US_CT_CICLO_MOR_MES_ANT_5  char(1);
	DEFINE TI_US_CT_ID_5  char(20);
	DEFINE TI_US_CT_TIPO_5  char(3);
	DEFINE TI_US_CT_FECHA_APERTURA_5  char(8);
	DEFINE TI_US_CT_FRECUENCIA_PAGO_5  char(1);
	DEFINE TI_US_CT_LIMITE_5  char(9);
	DEFINE TI_US_CT_PEOR_CICLO_MOR_U12M_5  char(1);
	DEFINE TI_US_CT_PLAZO_5  char(3);
	DEFINE TI_US_CT_SALDO_5  char(9);
	DEFINE TI_US_CT_SALDO_VENCIDO_5  char(9);
	DEFINE TI_US_CT_SCORE_5  char(9);
	DEFINE TI_US_CT_SCORE_ID_5  char(4);
	DEFINE TI_US_CT_TIPO_PROD_5  char(1);
	DEFINE TI_US_CT_CICLO_MOR_6  char(1);
	DEFINE TI_US_CT_CICLO_MOR_MES_ANT_6  char(1);
	DEFINE TI_US_CT_ID_6  char(20);
	DEFINE TI_US_CT_TIPO_6  char(3);
	DEFINE TI_US_CT_FECHA_APERTURA_6  char(8);
	DEFINE TI_US_CT_FRECUENCIA_PAGO_6  char(1);
	DEFINE TI_US_CT_LIMITE_6  char(9);
	DEFINE TI_US_CT_PEOR_CICLO_MOR_U12M_6  char(1);
	DEFINE TI_US_CT_PLAZO_6  char(3);
	DEFINE TI_US_CT_SALDO_6  char(9);
	DEFINE TI_US_CT_SALDO_VENCIDO_6  char(9);
	DEFINE TI_US_CT_SCORE_6  char(9);
	DEFINE TI_US_CT_SCORE_ID_6  char(4);
	DEFINE TI_US_CT_TIPO_PROD_6  char(1);
	DEFINE TI_US_CT_CICLO_MOR_7  char(1);
	DEFINE TI_US_CT_CICLO_MOR_MES_ANT_7  char(1);
	DEFINE TI_US_CT_ID_7  char(20);
	DEFINE TI_US_CT_TIPO_7  char(3);
	DEFINE TI_US_CT_FECHA_APERTURA_7  char(8);
	DEFINE TI_US_CT_FRECUENCIA_PAGO_7  char(1);
	DEFINE TI_US_CT_LIMITE_7  char(9);
	DEFINE TI_US_CT_PEOR_CICLO_MOR_U12M_7  char(1);
	DEFINE TI_US_CT_PLAZO_7  char(3);
	DEFINE TI_US_CT_SALDO_7  char(9);
	DEFINE TI_US_CT_SALDO_VENCIDO_7  char(9);
	DEFINE TI_US_CT_SCORE_7  char(9);
	DEFINE TI_US_CT_SCORE_ID_7  char(4);
	DEFINE TI_US_CT_TIPO_PROD_7  char(1);
	DEFINE TI_US_CT_CICLO_MOR_8  char(1);
	DEFINE TI_US_CT_CICLO_MOR_MES_ANT_8  char(1);
	DEFINE TI_US_CT_ID_8  char(20);
	DEFINE TI_US_CT_TIPO_8  char(3);
	DEFINE TI_US_CT_FECHA_APERTURA_8  char(8);
	DEFINE TI_US_CT_FRECUENCIA_PAGO_8  char(1);
	DEFINE TI_US_CT_LIMITE_8  char(9);
	DEFINE TI_US_CT_PEOR_CICLO_MOR_U12M_8  char(1);
	DEFINE TI_US_CT_PLAZO_8  char(3);
	DEFINE TI_US_CT_SALDO_8  char(9);
	DEFINE TI_US_CT_SALDO_VENCIDO_8  char(9);
	DEFINE TI_US_CT_SCORE_8  char(9);
	DEFINE TI_US_CT_SCORE_ID_8  char(4);
	DEFINE TI_US_CT_TIPO_PROD_8  char(1);
	DEFINE TI_US_CT_CICLO_MOR_9  char(1);
	DEFINE TI_US_CT_CICLO_MOR_MES_ANT_9  char(1);
	DEFINE TI_US_CT_ID_9  char(20);
	DEFINE TI_US_CT_TIPO_9  char(3);
	DEFINE TI_US_CT_FECHA_APERTURA_9  char(8);
	DEFINE TI_US_CT_FRECUENCIA_PAGO_9  char(1);
	DEFINE TI_US_CT_LIMITE_9  char(9);
	DEFINE TI_US_CT_PEOR_CICLO_MOR_U12M_9  char(1);
	DEFINE TI_US_CT_PLAZO_9  char(3);
	DEFINE TI_US_CT_SALDO_9  char(9);
	DEFINE TI_US_CT_SALDO_VENCIDO_9  char(9);
	DEFINE TI_US_CT_SCORE_9  char(9);
	DEFINE TI_US_CT_SCORE_ID_9  char(4);
	DEFINE TI_US_CT_TIPO_PROD_9  char(1);
	DEFINE vTI_US_CT_CICLO_MOR_10  char(1);
	DEFINE vTI_US_CT_CICLO_MOR_MES_ANT_10  char(1);
	DEFINE vTI_US_CT_ID_10  						CHAR(20);
	DEFINE vTI_US_CT_TIPO_10  char(3);
	DEFINE vTI_US_CT_FECHA_APERTURA_10  char(8);
	DEFINE vTI_US_CT_FRECUENCIA_PAGO_10  char(1);
	DEFINE vTI_US_CT_LIMITE_10  char(9);
	DEFINE vTI_US_CT_PEOR_CICLO_MOR_U12M_10  char(1);
	DEFINE vTI_US_CT_PLAZO_10  char(3);
	DEFINE vTI_US_CT_SALDO_10  char(9);
	DEFINE vTI_US_CT_SALDO_VENCIDO_10  char(9);
	DEFINE vTI_US_CT_SCORE_10  char(9);
	DEFINE vTI_US_CT_SCORE_ID_10  char(4);
	DEFINE vTI_US_CT_TIPO_PROD_10  char(1);
	DEFINE vTI_US_CT_CICLO_MOR_11  char(1);
	DEFINE vTI_US_CT_CICLO_MOR_MES_ANT_11  char(1);
	DEFINE vTI_US_CT_ID_11  char(20);
	DEFINE vTI_US_CT_TIPO_11  char(3);
	DEFINE vTI_US_CT_FECHA_APERTURA_11  char(8);
	DEFINE vTI_US_CT_FRECUENCIA_PAGO_11  char(1);
	DEFINE vTI_US_CT_LIMITE_11  char(9);
	DEFINE vTI_US_CT_PEOR_CICLO_MOR_U12M_11  char(1);
	DEFINE vTI_US_CT_PLAZO_11  char(3);
	DEFINE vTI_US_CT_SALDO_11  char(9);
	DEFINE vTI_US_CT_SALDO_VENCIDO_11  char(9);
	DEFINE vTI_US_CT_SCORE_11  char(9);
	DEFINE vTI_US_CT_SCORE_ID_11  char(4);
	DEFINE vTI_US_CT_TIPO_PROD_11  char(1);
	DEFINE vTI_US_CT_CICLO_MOR_12  char(1);
	DEFINE vTI_US_CT_CICLO_MOR_MES_ANT_12  char(1);
	DEFINE vTI_US_CT_ID_12  char(20);
	DEFINE vTI_US_CT_TIPO_12  char(3);
	DEFINE vTI_US_CT_FECHA_APERTURA_12  char(8);
	DEFINE vTI_US_CT_FRECUENCIA_PAGO_12  char(1);
	DEFINE vTI_US_CT_LIMITE_12  char(9);
	DEFINE vTI_US_CT_PEOR_CICLO_MOR_U12M_12  char(1);
	DEFINE vTI_US_CT_PLAZO_12  char(3);
	DEFINE vTI_US_CT_SALDO_12  char(9);
	DEFINE vTI_US_CT_SALDO_VENCIDO_12  char(9);
	DEFINE vTI_US_CT_SCORE_12  char(9);
	DEFINE vTI_US_CT_SCORE_ID_12  char(4);
	DEFINE vTI_US_CT_TIPO_PROD_12  char(1);
	
		---------------------------------------------------	
	--US 
	DEFINE dFechaBehavior 					DATE;
	DEFINE cNumCteUS 						CHAR(20); 
	DEFINE cNumCteAnt						CHAR(20);
	DEFINE cNumCredUS 						CHAR(20); 
	DEFINE cProductoUS 						CHAR(10);
	DEFINE dFechaAperUS 					DATE;
	DEFINE cPeriodoPlazoUS 					CHAR(1);
	DEFINE vPlazoUS 						INTEGER; 
	DEFINE cPlazoUS 						CHAR(3); 
	DEFINE dMontoUS 						DECIMAL(18,2);
	DEFINE cSaldoCapUS CHAR(8); 
	DEFINE cSaldoMorUS CHAR(8);
	DEFINE vVencidosUS 						INTEGER;
	DEFINE vVencidosUS1 					INTEGER;
	DEFINE cVencidosUS CHAR(2);
	DEFINE cVencidosUS1 CHAR(2);
	DEFINE vMontoVencidoUS INTEGER;
	DEFINE cMontoVencidoUS CHAR(9);
	DEFINE cPago_minimo_AlCorte CHAR(9);
	DEFINE dPago_minimo_AlCorte decimal(14,2); 
	DEFINE dPago_minimo_AlCorte_2 decimal(14,2); 
	DEFINE dSumaMontos_1 decimal(14,2); 
	DEFINE dLimiteCred_AlCorte decimal(14,2); 
	
	DEFINE dSdoTotalLiq      	DECIMAL(18,2);
	DEFINE cSdoTotalLiq      	CHAR(2);
	DEFINE dSaldoVencido 		DECIMAL(18,2); 
	DEFINE cSaldoVencido 		CHAR(2);
	DEFINE cStatusUS			CHAR(2);
	DEFINE cGrupoUS 			CHAR(1);
	DEFINE cFlagUS 				CHAR(1);
	DEFINE cFlagUSNull			CHAR(2);
	DEFINE iFicoScoreUS 		INTEGER;
	DEFINE iEvaluacionUS		INTEGER;
	DEFINE cEvaluacionUS		CHAR(8);
	DEFINE iPlazo 				INTEGER;
	DEFINE cPlazo				CHAR(2);
	DEFINE cFechaVctoConv1		CHAR(10);
	DEFINE cFechaVctoConv2 		CHAR(10);
	DEFINE iActivo 				INTEGER;
	DEFINE cActivo				CHAR(2);
	DEFINE cDiasTransUltConv 	CHAR(8);
	DEFINE iDiasTransUltConv	INTEGER;
	DEFINE cDiasRestConv		CHAR(2);
	DEFINE iDiasRestConv		INTEGER;
	DEFINE cMontoUltConvenio 	CHAR(8);
	DEFINE vMontoUltConvenio 	DECIMAL(14,2);
	
	-----------------------------------
	DEFINE iCantidadConv3 		INTEGER;
	DEFINE iCantidadConv6 		INTEGER;
	DEFINE iCantidadConv12 		INTEGER;
	-----------------------------------
	
	--Cumplio Convenios 
	DEFINE iCantCumplio1		INTEGER;
	DEFINE iCantCumplio2		INTEGER;
	DEFINE iCantCumplio3		INTEGER;
	DEFINE iCantCumplio4		INTEGER;
	DEFINE iCantCumplio5		INTEGER;
	DEFINE iCantCumplio6		INTEGER;
	DEFINE iCantCumplio7		INTEGER;
	DEFINE iCantCumplio8		INTEGER;
	DEFINE iCantCumplio9		INTEGER;
	DEFINE iCantCumplio10		INTEGER;
	DEFINE iCantCumplio11		INTEGER;
	DEFINE iCantCumplio12		INTEGER;
	
	DEFINE iCantCumplioConv3	INTEGER;
	DEFINE iCantCumplioConv6 	INTEGER;
	DEFINE iCantCumplioConv12 	INTEGER;
	-----------------------------------
	
	--No Cumplio
	DEFINE iCantNoCumplio1	 	INTEGER;
	DEFINE iCantNoCumplio2	 	INTEGER;
	DEFINE iCantNoCumplio3	 	INTEGER;
	DEFINE iCantNoCumplio4	 	INTEGER;
	DEFINE iCantNoCumplio5	 	INTEGER;
	DEFINE iCantNoCumplio6	 	INTEGER;
	DEFINE iCantNoCumplio7	 	INTEGER;
	DEFINE iCantNoCumplio8	 	INTEGER;
	DEFINE iCantNoCumplio9	 	INTEGER;
	DEFINE iCantNoCumplio10	 	INTEGER;
	DEFINE iCantNoCumplio11	 	INTEGER;
	DEFINE iCantNoCumplio12	 	INTEGER;
	
	DEFINE iCantNoCumplioConv3 	INTEGER;
	DEFINE iCantNoCumplioConv6 	INTEGER;
	DEFINE iCantNoCumplioConv12 INTEGER;
	-----------------------------------
	
	DEFINE iContacto 			INTEGER;
	DEFINE iContacto1M 			INTEGER;
	DEFINE cPeorCicloMora 		CHAR(2);
	DEFINE vPeorCicloMora 		INTEGER;
	DEFINE cSdoCapitalUS 		CHAR(9);
	DEFINE cSaldoMorLN 			CHAR(9);
	DEFINE pNumCredIni_temp     CHAR(30);
	DEFINE cred_ini_temp	    CHAR(30);
	DEFINE iDia_corte           INTEGER;
	DEFINE cGrupoUS_2 			CHAR(1);
	DEFINE cFlagUS_2            CHAR(1);
	DEFINE iFicoScoreUS_2       INTEGER;
	DEFINE iEvaluacionUS_2      INTEGER; 
	
	DEFINE dFechaVctoConv1		DATE;
	
	---------------------------------------------------	
	--SOLO ESTAN INICIALIZADAS EN EL SP PRINCIPAL
	LET TI_RV_CYCLES_DELQ_1 = '0';
	LET TI_RV_CYCLES_DELQ_2 = '0';
	
	--REVISAR MARCO, NO DECLARADOS EN EL PRINCIPAL
	LET TI_LN_CYCLES_DELQ_1 = '0';
	LET TI_LN_CYCLES_DELQ_2 = '0';
	LET ti_us_user_d_key_n_1	= '';
	---------------------------------------------------
	let vEmpresa      = '001';
	let v_numcte_ref  = '';
	let vSitesp       = 0;
	let vCuentaTels   = 0;
	let vCuentaEmails = 0;
	let vFechahoy     = date(1);
	let vFechaDiaAnt  = date(1);
	let vPriDiaMes    = date(1);
	let vfecha_fin_mes_ant    = date(1);
	let vFechacorte           = date(1);
	LET cFechacorte			  = '';
	let vFechacorteant        = date(1);
	let vFechacorte_24MsAntes = date(1); 
	let v_evalua_cc           = '';
	let iIdUnidadProd         = 0;	    
	let vNumvencidos          = 0;
	let cContadorTarjetas     = '000';
	  
	  LET cCodRet				= "000000";
	  LET dtFecha				= '01-01-1900';
	  --LET vNomarchivo   = 'Layout_in_triad.txt';
	  LET vNomarchivo   = 'Bancoppel_Layout_entrada_Triad_RQI.txt';
	  LET cRuta         = '/RESPALDOS/aacano/';


	 
			
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
	 let cFechaIniMora       = '';
	 let cCadena1            = '';
	 let iContGral           = 0;
	 LET iTotalCuentas		 = 0;
	 LET vContador			 = 0;
	 LET cTotalCuentas		 = '0';
	 LET iExisteCuenta		 = 0;
	 let iScoreBehavior      = 0;
	 let cNumRegion          = '';
	 let cMensaje            = 'PROCESO CONCLUYO CORRECTAMENTE';
	 let vNumcuentas         = 0;
	 let vTipo_prod          = '';
	 let vCuenta             = '';
	 let cSegmento           = '';
	 let iRandomNumber1      = 0;
	 let iRandomNumber2      = 0;
	 let iRandomNumber3      = 0;
	 let iRandomNumber4      = 0;
	 let cRandomNumber1      = '';
	 let cRandomNumber2      = '';
	 let cRandomNumber3     = '';
	 let cRandomNumber4      = '';
	 let fValor              = 0;
	 let cValor              = '';
	 let cProceso            = '0114';		--No.PROCESO ASIGNADO 
	 let cCod_ret_2          = ''; 
	 let cContGral           = '';
	 
	 LET pNumCredIni		 ='';
	 LET pNumCredFin		 ='';
	 LET cred_ini			 ='';
	 LET cred_fin			 ='';
	 LET pNumCredIni_temp    = '';
	 LET cred_ini_temp       = '';
	 LET iDia_corte          = 0;
	 LET vEmpresa_2          = '';
	 LET cEmpresa_10		 = '';
	 LET dFechaMax_CleanBehav    = date(1);
     LET dFechaMax_Dirty         = date(1);
	 LET dFechaVctoConv1      = date(1);
 
	LET vTI_US_ACCOUNT_ID = '                    ';
	LET vTI_US_CUSTOMER_ID = '                    ';
		
	LET vTI_US_USER_DEFINED_KEY_N_67 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_68 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_69 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_70 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_71 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_72 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_73 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_74 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_75 = 0.0;
	LET vTI_US_USER_DEFINED_KEY_N_76 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_77 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_78 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_79 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_80 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_81 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_82 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_83 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_84 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_85 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_86 = 0;
	
	---------------------------------------------
	
	LET vTI_US_CANTIDAD_CUENTA 			= 0;
	LET vTI_US_CT_CICLO_MOR_1 			= 0;
	LET vTI_US_CT_CICLO_MOR_MES_ANT_1 	= 0;
	LET vTI_US_CT_ID_1 					= '                    ';
	LET vTI_US_CT_TIPO_1 				= 0;
	LET vTI_US_CT_FECHA_APERTURA_1 		= DATE(1);
	LET vTI_US_CT_FRECUENCIA_PAGO_1 	= 0;
	LET vTI_US_CT_LIMITE_1 				= 0.0;
	LET vTI_US_CT_PEOR_CICLO_MOR_U12M_1 = 0;
	LET vTI_US_CT_PLAZO_1 				= 0;
	LET vTI_US_CT_SALDO_1 				= 0.0;
	LET vTI_US_CT_SALDO_VENCIDO_1 = '000000000';
	LET vTI_US_CT_SCORE_1 				= 0;
	LET vTI_US_CT_SCORE_ID_1 			= 0;
	LET vTI_US_CT_TIPO_PROD_1 			= 0;
	LET TI_US_CT_CICLO_MOR_2 = '0';
	LET TI_US_CT_CICLO_MOR_MES_ANT_2 = '0';
	LET TI_US_CT_ID_2 = '                    ';
	LET TI_US_CT_TIPO_2 = '000';
	LET TI_US_CT_FECHA_APERTURA_2 = '00000000';
	LET TI_US_CT_FRECUENCIA_PAGO_2 = '0';
	LET TI_US_CT_LIMITE_2 = '000000000';
	LET TI_US_CT_PEOR_CICLO_MOR_U12M_2 = '0';
	LET TI_US_CT_PLAZO_2 = '000';
	LET TI_US_CT_SALDO_2 = '000000000';
	LET TI_US_CT_SALDO_VENCIDO_2 = '000000000';
	LET TI_US_CT_SCORE_2 = '000000000';
	LET TI_US_CT_SCORE_ID_2 = '0000';
	LET TI_US_CT_TIPO_PROD_2 = '0';
	LET TI_US_CT_CICLO_MOR_3 = '0';
	LET TI_US_CT_CICLO_MOR_MES_ANT_3 = '0';
	LET TI_US_CT_ID_3 = '                    ';
	LET TI_US_CT_TIPO_3 = '000';
	LET TI_US_CT_FECHA_APERTURA_3 = '00000000';
	LET TI_US_CT_FRECUENCIA_PAGO_3 = '0';
	LET TI_US_CT_LIMITE_3 = '000000000';
	LET TI_US_CT_PEOR_CICLO_MOR_U12M_3 = '0';
	LET TI_US_CT_PLAZO_3 = '000';
	LET TI_US_CT_SALDO_3 = '000000000';
	LET TI_US_CT_SALDO_VENCIDO_3 = '000000000';
	LET TI_US_CT_SCORE_3 = '000000000';
	LET TI_US_CT_SCORE_ID_3 = '0000';
	LET TI_US_CT_TIPO_PROD_3 = '0';
	LET TI_US_CT_CICLO_MOR_4 = '0';
	LET TI_US_CT_CICLO_MOR_MES_ANT_4 = '0';
	LET TI_US_CT_ID_4 = '                    ';
	LET TI_US_CT_TIPO_4 = '000';
	LET TI_US_CT_FECHA_APERTURA_4 = '00000000';
	LET TI_US_CT_FRECUENCIA_PAGO_4 = '0';
	LET TI_US_CT_LIMITE_4 = '000000000';
	LET TI_US_CT_PEOR_CICLO_MOR_U12M_4 = '0';
	LET TI_US_CT_PLAZO_4 = '000';
	LET TI_US_CT_SALDO_4 = '000000000';
	LET TI_US_CT_SALDO_VENCIDO_4 = '000000000';
	LET TI_US_CT_SCORE_4 = '000000000';
	LET TI_US_CT_SCORE_ID_4 = '0000';
	LET TI_US_CT_TIPO_PROD_4 = '0';
	LET TI_US_CT_CICLO_MOR_5 = '0';
	LET TI_US_CT_CICLO_MOR_MES_ANT_5 = '0';
	LET TI_US_CT_ID_5 = '                    ';
	LET TI_US_CT_TIPO_5 = '000';
	LET TI_US_CT_FECHA_APERTURA_5 = '00000000';
	LET TI_US_CT_FRECUENCIA_PAGO_5 = '0';
	LET TI_US_CT_LIMITE_5 = '000000000';
	LET TI_US_CT_PEOR_CICLO_MOR_U12M_5 = '0';
	LET TI_US_CT_PLAZO_5 = '000';
	LET TI_US_CT_SALDO_5 = '000000000';
	LET TI_US_CT_SALDO_VENCIDO_5 = '000000000';
	LET TI_US_CT_SCORE_5 = '000000000';
	LET TI_US_CT_SCORE_ID_5 = '0000';
	LET TI_US_CT_TIPO_PROD_5 = '0';
	LET TI_US_CT_CICLO_MOR_6 = '0';
	LET TI_US_CT_CICLO_MOR_MES_ANT_6 = '0';
	LET TI_US_CT_ID_6 = '                    ';
	LET TI_US_CT_TIPO_6 = '000';
	LET TI_US_CT_FECHA_APERTURA_6 = '00000000';
	LET TI_US_CT_FRECUENCIA_PAGO_6 = '0';
	LET TI_US_CT_LIMITE_6 = '000000000';
	LET TI_US_CT_PEOR_CICLO_MOR_U12M_6 = '0';
	LET TI_US_CT_PLAZO_6 = '000';
	LET TI_US_CT_SALDO_6 = '000000000';
	LET TI_US_CT_SALDO_VENCIDO_6 = '000000000';
	LET TI_US_CT_SCORE_6 = '000000000';
	LET TI_US_CT_SCORE_ID_6 = '0000';
	LET TI_US_CT_TIPO_PROD_6 = '0';
	LET TI_US_CT_CICLO_MOR_7 = '0';
	LET TI_US_CT_CICLO_MOR_MES_ANT_7 = '0';
	LET TI_US_CT_ID_7 = '                    ';
	LET TI_US_CT_TIPO_7 = '000';
	LET TI_US_CT_FECHA_APERTURA_7 = '00000000';
	LET TI_US_CT_FRECUENCIA_PAGO_7 = '0';
	LET TI_US_CT_LIMITE_7 = '000000000';
	LET TI_US_CT_PEOR_CICLO_MOR_U12M_7 = '0';
	LET TI_US_CT_PLAZO_7 = '000';
	LET TI_US_CT_SALDO_7 = '000000000';
	LET TI_US_CT_SALDO_VENCIDO_7 = '000000000';
	LET TI_US_CT_SCORE_7 = '000000000';
	LET TI_US_CT_SCORE_ID_7 = '0000';
	LET TI_US_CT_TIPO_PROD_7 = '0';
	LET TI_US_CT_CICLO_MOR_8 = '0';
	LET TI_US_CT_CICLO_MOR_MES_ANT_8 = '0';
	LET TI_US_CT_ID_8 = '                    ';
	LET TI_US_CT_TIPO_8 = '000';
	LET TI_US_CT_FECHA_APERTURA_8 = '00000000';
	LET TI_US_CT_FRECUENCIA_PAGO_8 = '0';
	LET TI_US_CT_LIMITE_8 = '000000000';
	LET TI_US_CT_PEOR_CICLO_MOR_U12M_8 = '0';
	LET TI_US_CT_PLAZO_8 = '000';
	LET TI_US_CT_SALDO_8 = '000000000';
	LET TI_US_CT_SALDO_VENCIDO_8 = '000000000';
	LET TI_US_CT_SCORE_8 = '000000000';
	LET TI_US_CT_SCORE_ID_8 = '0000';
	LET TI_US_CT_TIPO_PROD_8 = '0';
	LET TI_US_CT_CICLO_MOR_9 = '0';
	LET TI_US_CT_CICLO_MOR_MES_ANT_9 = '0';
	LET TI_US_CT_ID_9 = '                    ';
	LET TI_US_CT_TIPO_9 = '000';
	LET TI_US_CT_FECHA_APERTURA_9 = '00000000';
	LET TI_US_CT_FRECUENCIA_PAGO_9 = '0';
	LET TI_US_CT_LIMITE_9 = '000000000';
	LET TI_US_CT_PEOR_CICLO_MOR_U12M_9 = '0';
	LET TI_US_CT_PLAZO_9 = '000';
	LET TI_US_CT_SALDO_9 = '000000000';
	LET TI_US_CT_SALDO_VENCIDO_9 = '000000000';
	LET TI_US_CT_SCORE_9 = '000000000';
	LET TI_US_CT_SCORE_ID_9 = '0000';
	LET TI_US_CT_TIPO_PROD_9 = '0';
	LET vTI_US_CT_CICLO_MOR_10 = '0';
	LET vTI_US_CT_CICLO_MOR_MES_ANT_10 = '0';
	LET vTI_US_CT_ID_10 = '                    ';
	LET vTI_US_CT_TIPO_10 = '000';
	LET vTI_US_CT_FECHA_APERTURA_10 = '00000000';
	LET vTI_US_CT_FRECUENCIA_PAGO_10 = '0';
	LET vTI_US_CT_LIMITE_10 = '000000000';
	LET vTI_US_CT_PEOR_CICLO_MOR_U12M_10 = '0';
	LET vTI_US_CT_PLAZO_10 = '000';
	LET vTI_US_CT_SALDO_10 = '000000000';
	LET vTI_US_CT_SALDO_VENCIDO_10 = '000000000';
	LET vTI_US_CT_SCORE_10 = '000000000';
	LET vTI_US_CT_SCORE_ID_10 = '0000';
	LET vTI_US_CT_TIPO_PROD_10 = '0';
	LET vTI_US_CT_CICLO_MOR_11 = '0';
	LET vTI_US_CT_CICLO_MOR_MES_ANT_11 = '0';
	LET vTI_US_CT_ID_11 = '                    ';
	LET vTI_US_CT_TIPO_11 = '000';
	LET vTI_US_CT_FECHA_APERTURA_11 = '00000000';
	LET vTI_US_CT_FRECUENCIA_PAGO_11 = '0';
	LET vTI_US_CT_LIMITE_11 = '000000000';
	LET vTI_US_CT_PEOR_CICLO_MOR_U12M_11 = '0';
	LET vTI_US_CT_PLAZO_11 = '000';
	LET vTI_US_CT_SALDO_11 = '000000000';
	LET vTI_US_CT_SALDO_VENCIDO_11 = '000000000';
	LET vTI_US_CT_SCORE_11 = '000000000';
	LET vTI_US_CT_SCORE_ID_11 = '0000';
	LET vTI_US_CT_TIPO_PROD_11 = '0';
	LET vTI_US_CT_CICLO_MOR_12 = '0';
	LET vTI_US_CT_CICLO_MOR_MES_ANT_12 = '0';
	LET vTI_US_CT_ID_12 = '                    ';
	LET vTI_US_CT_TIPO_12 = '000';
	LET vTI_US_CT_FECHA_APERTURA_12 = '00000000';
	LET vTI_US_CT_FRECUENCIA_PAGO_12 = '0';
	LET vTI_US_CT_LIMITE_12 = '000000000';
	LET vTI_US_CT_PEOR_CICLO_MOR_U12M_12 = '0';
	LET vTI_US_CT_PLAZO_12 = '000';
	LET vTI_US_CT_SALDO_12 = '000000000';
	LET vTI_US_CT_SALDO_VENCIDO_12 = '000000000';
	LET vTI_US_CT_SCORE_12 = '000000000';
	LET vTI_US_CT_SCORE_ID_12 = '0000';
	LET vTI_US_CT_TIPO_PROD_12 = '0';
	
	LET dFechaBehavior = DATE(1);
	LET cNumCteUS = ''; 
	LET cNumCteAnt	= '';
	LET cNumCredUS = ''; 
	LET cProductoUS = '';
	LET dFechaAperUS 			= DATE(1);
	LET cPeriodoPlazoUS = '';
	LET vPlazoUS 				= 0;
	LET cPlazoUS = ''; 
	LET dMontoUS 				= 0.0;
	LET cSaldoCapUS = ''; 
	LET cSaldoMorUS = '';
	LET vVencidosUS 			= 0;
	LET vVencidosUS1 			= 0;
	LET cVencidosUS = '';
	LET cVencidosUS1 = '';
	LET vMontoVencidoUS = 0;
	LET cMontoVencidoUS = '';
	LET cPago_minimo_AlCorte 	= '';
	LET dPago_minimo_AlCorte 	= 0;
	LET dPago_minimo_AlCorte_2 	= 0;
	LET dSumaMontos_1 			= 0;

	LET dSdoTotalLiq          	= 0.0;
	LET cSdoTotalLiq        	= '';
	LET dSaldoVencido 			= 0.0;
	LET cSaldoVencido 			= '';
	
	LET dLimiteCred_AlCorte 	= 0;
	LET cStatusUS 				= '';
	LET cGrupoUS 				= '';
	LET cFlagUS 				= '';
	LET cFlagUSNull				= '';
	LET iFicoScoreUS 			= 0;
	LET iEvaluacionUS			= 0;
	LET cEvaluacionUS 			= '';
	LET iPlazo 					= 0;
	LET cPlazo 					= '';
	LET cFechaVctoConv1 		= '';
	LET cFechaVctoConv2 		= '';
	LET iActivo 				= 0;
	LET cActivo					= '';
	LET cDiasTransUltConv 		= '';
	LET iDiasTransUltConv 		= 0;
	LET cDiasRestConv	  		=	'';
	LET iDiasRestConv	  		= 0;
	LET cMontoUltConvenio		= '';
	LET vMontoUltConvenio 		= 0;
	-----------------------------------
	LET iCantidadConv3 			= 0;
	LET iCantidadConv6 			= 0;
	LET iCantidadConv12 		= 0;
	-----------------------------------
	
	-- Cumplio Convenio
	LET iCantCumplio1 		= 0;		
	LET iCantCumplio2 		= 0;
	LET iCantCumplio3 		= 0;
	LET iCantCumplio4 		= 0;
	LET iCantCumplio5 		= 0;
	LET iCantCumplio6 		= 0;
	LET iCantCumplio7 		= 0;
	LET iCantCumplio8 		= 0;
	LET iCantCumplio9 		= 0;
	LET iCantCumplio10 		= 0;
	LET iCantCumplio11 		= 0;
	LET iCantCumplio12 		= 0;
	
	LET iCantCumplioConv3 	= 0;
	LET iCantCumplioConv6 	= 0;
	LET iCantCumplioConv12 	= 0;
	-----------------------------------
	
	-- No Cumplio
	LET iCantNoCumplio1		= 0;		
	LET iCantNoCumplio2		= 0;			
	LET iCantNoCumplio3		= 0;
	LET iCantNoCumplio4		= 0;
	LET iCantNoCumplio5		= 0;
	LET iCantNoCumplio6		= 0;
	LET iCantNoCumplio7		= 0;
	LET iCantNoCumplio8		= 0;
	LET iCantNoCumplio9		= 0;
	LET iCantNoCumplio10	= 0;
	LET iCantNoCumplio11	= 0;
	LET iCantNoCumplio12	= 0;
	
	LET iCantNoCumplioConv3 = 0;
	LET iCantNoCumplioConv6 = 0;
	LET iCantNoCumplioConv12 = 0;
	
	-----------------------------------
	LET iContacto 			= 0;
	LET iContacto1M 		= 0;
	LET cPeorCicloMora 		= '';
	LET vPeorCicloMora 		= 0;
	LET cSdoCapitalUS 		= '';
	LET cSaldoMorLN 		= ''; 

	LET cGrupoUS_2          = ''; 
	LET cFlagUS_2           = '';
	LET iFicoScoreUS_2      = 0;
	LET iEvaluacionUS_2     = 0;
	---------------------------------------------------


BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDataErr
        IF iSqlErr <> 0 THEN
            LET cCodRet=iSqlErr ;
			let cMensaje = pEjecucion || '-' || trim(cCodRet) || ' ' || cNumCredUS;
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '02') RETURNING cCod_ret_2;
			 
            RETURN cCodRet, trim(cMensaje);
        END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/ifxsif01/macf/sp_layout_in_triad_us.trc";
	--TRACE ON;
   
    LET cMensaje = pEjecucion;
	--CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
	CALL bdicobranza:sp_inserta_bitacora_cob_2(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
   
	/*SELECT fecha_hoy,fecha_ant,pri_dia_mes INTO vFechahoy,vFechaDiaAnt,vPriDiaMes 
	FROM bdicred:sd_fechas
	WHERE empresa = vEmpresa; 
	*/
	
	let vFechahoy = today -1;
	let vFechaDiaAnt = today -2;
	
	--let vFechahoy = mdy(5,5,2020);                   -- SOLO TEST MACF
	--let vFechaDiaAnt = date(vFechahoy -1 units day);  -- SOLO TEST MACF
	
	let iDia_corte = DAY(vFechahoy);
	
	IF pEjecucion IS NULL OR pEjecucion = '' THEN
		LET cCodRet     = "000005";
		LET cMensaje = "Parametro de proceso invalido";
		RETURN cCodRet, cMensaje;
	END IF;
	
	--  Se determina el rango de creditos 
	--SELECT SUBSTR(valor,1,12),SUBSTR(valor,14,25) INTO pNumCredIni,pNumCredFin		-- cod_param between '931' and '977'
	--FROM bdicred:sd_param  WHERE cod_param = (980 + pEjecucion)::CHAR(3);  

	SELECT valor INTO pNumCredIni_temp
	FROM bdicred:sd_param  WHERE cod_param = (980 + pEjecucion)::CHAR(3);  

	LET pNumCredIni = SUBSTR(pNumCredIni_temp,1,12); 
	LET pNumCredFin = SUBSTR(pNumCredIni_temp,14,25);
	
	
	IF pNumCredIni IS NULL OR pNumCredFin IS NULL OR pNumCredIni = '' OR pNumCredFin = '' THEN
		LET cCodRet     = "000006";
		LET cMensaje	= "Sin cuentas a procesar";
		RETURN cCodRet, cMensaje;
	END IF;
	
	IF pEjecucion < 7 THEN
		--  Se determina el rango de prestamos 
		--SELECT SUBSTR(valor,1,12),SUBSTR(valor,14,25) INTO cred_ini,cred_fin
		--FROM bdicred:sd_param  WHERE cod_param = (971 + pEjecucion)::CHAR(3);       -- cod_param between '972' and '977'     
		SELECT valor INTO cred_ini_temp
		FROM bdicred:sd_param  WHERE cod_param = (971 + pEjecucion)::CHAR(3);       -- cod_param between '972' and '977'     
		
        let cred_ini = SUBSTR(cred_ini_temp,1,12);
		let cred_fin = SUBSTR(cred_ini_temp,14,25);
		
		IF cred_ini IS NULL OR cred_fin IS NULL OR cred_ini='' OR cred_fin='' THEN
			LET cCodRet     = "000007";
			LET cMensaje 	= "Sin cuentas a procesar";
			RETURN cCodRet, cMensaje;
		END IF;
	ELSE
		LET  cred_ini = '600000000000';
		LET  cred_fin = '600000000001';
	END IF;
	

		IF iDia_corte = 18 or iDia_corte = 20 then

			SELECT a.numcte cNumCteUS1, a.num_credito cNumCredUS1, 'REV' vTipo_prod1
			  FROM bdicred:sd_maecred a 
				   JOIN bdicred:sd_maesdos c ON c.empresa = a.empresa AND c.num_credito = a.num_credito AND c.sdo_cap_insoluto > 0  --SALDO MAYOR A CERO
			 WHERE a.num_producto <> '7800'   
			   AND a.num_credito >= pNumCredIni AND a.num_credito < pNumCredFin
			   AND a.status_cred in('AA','BA','BT')
			 INTO TEMP paso_us WITH NO LOG;
			
			create unique index inx_paso_us on paso_us(cNumCredUS1);
			update statistics medium for table paso_us;
			
			insert into paso_us 
			SELECT a.numcte, a.num_credito, 'REV' 
			  FROM bdicred:sd_maecred a 
				   JOIN bdicred:sd_maecredanexo d ON d.empresa = a.empresa AND d.num_credito = a.num_credito 
				   --JOIN bdicobranza:cb_triad_salida f ON f.out_co_account_id='00000000'||a.num_credito 
				   JOIN bdicobranza:cb_triad_salida f ON f.num_credito = a.num_credito 
			 WHERE a.num_producto <> '7800' AND a.status_cred = 'AA' --VIGENTES 
			   AND a.num_credito not in (select cNumCredUS1 from paso_us)
			   AND a.num_credito >= pNumCredIni AND a.num_credito < pNumCredFin 
			   AND d.prox_fecha_pago+f.out_coll_next_call_days = vFechahoy;  --VIGENTES EN EL CAMPO OUT-COLL-NEXT-CALL-DAYS*
		
		ELSE
		
			-- 1 DIARIO: VENCIDOS 
			SELECT a.numcte cNumCteUS1, a.num_credito cNumCredUS1, 'REV' vTipo_prod1
			  FROM bdicred:sd_maecred a 
			 WHERE a.num_producto <> '7800' AND a.status_cred in('BA','BT') --VENCIDOS
			   AND a.num_credito >= pNumCredIni AND a.num_credito < pNumCredFin  			   
			   
				INTO TEMP paso_us WITH NO LOG;
			
			create unique index inx_paso_us on paso_us(cNumCredUS1);
			update statistics medium for table paso_us;
			
			-- 2 DIARIO:  VIGENTES PAGO UN DIA ANTERIOR   
			insert into paso_us 
			SELECT a.numcte, a.num_credito, 'REV' 
			  FROM bdicred:sd_maecred a
			  JOIN bdicred:sd_maecredanexo d ON d.empresa = a.empresa AND d.num_credito = a.num_credito AND d.fecha_ult_pago = vFechaDiaAnt --PAGO UN DIA ANTERIOR
			 WHERE a.num_producto <> '7800' AND a.status_cred = 'AA' --VIGENTES
			   AND a.num_credito not in (select cNumCredUS1 from paso_us)
			   AND a.num_credito >= pNumCredIni AND a.num_credito  < pNumCredFin;

			   
			-- 4: DIARIO/CORTE	 VIGENTES	VALIDA CAMPO DE ARCHIVO SALIDA: OUT_CO_ACCOUNT_ID		
			insert into paso_us 
			SELECT a.numcte, a.num_credito, 'REV' 
			  FROM bdicred:sd_maecred a 
				   JOIN bdicred:sd_maecredanexo d ON d.empresa = a.empresa AND d.num_credito = a.num_credito 
				   --JOIN bdicobranza:cb_triad_salida f ON f.out_co_account_id='00000000'||a.num_credito 
				   JOIN bdicobranza:cb_triad_salida f ON f.num_credito = a.num_credito 
			 WHERE a.num_producto <> '7800' AND a.status_cred = 'AA' --VIGENTES 
			   AND a.num_credito not in (select cNumCredUS1 from paso_us)
			   AND a.num_credito >= pNumCredIni AND a.num_credito < pNumCredFin 
			   AND d.prox_fecha_pago+f.out_coll_next_call_days = vFechahoy;  --VIGENTES EN EL CAMPO OUT-COLL-NEXT-CALL-DAYS*

		end if;
		
		-- 1: CUENTAS A PLAZO: DIARIO/CORTE	 VENCIDOS
		insert into paso_us 
		SELECT b.numcte, b.num_credito, 'CRD' 
		  FROM bdicred:sd_maecredcrd b
		 WHERE b.num_producto <> '6800'  --in('6011','6300','7600','7700','6400') 
		   AND b.status_cred in('BA','BT','VP')	--VENCIDOS
		   AND b.num_credito >= cred_ini AND b.num_credito  < cred_fin;
		
		-- 2: CUENTAS A PLAZO: DIARIO/CORTE	VIGENTES PAGO UN DIA ANTERIOR
		insert into paso_us
		SELECT b.numcte, b.num_credito, 'CRD' 
		  FROM bdicred:sd_maecredcrd b
		  JOIN bdicred:sd_maecredanexocrd d ON d.empresa = b.empresa AND d.num_credito = b.num_credito AND d.fecha_ult_pago = vFechaDiaAnt 
		 WHERE b.num_producto <> '6800' 
		   AND b.status_cred = 'AA'
		   AND b.num_credito not in (select cNumCredUS1 from paso_us)
		   AND b.num_credito >= cred_ini AND b.num_credito  < cred_fin;		
		
		-- 3: CUENTAS A PLAZO: CORTE  (Saldo > 0)
		insert into paso_us
		SELECT b.numcte, b.num_credito, 'CRD' 
		  FROM bdicred:sd_maecredcrd b
		  JOIN bdicred:sd_maesdoscrd c ON c.num_credito = b.num_credito AND c.sdo_cap_insoluto>0
		  --JOIN bdicred:sd_maecredanexocrd d ON d.empresa = b.empresa AND d.num_credito = b.num_credito AND d.dia_corte = iDia_corte --FECHA DE CORTE
		  JOIN bdicred:sd_maecredanexocrd d ON d.empresa = b.empresa AND d.num_credito = b.num_credito AND d.prox_fecha_pago = vFechahoy --FECHA DE CORTE
		WHERE b.num_producto <> '6800' 
		  AND b.status_cred = 'AA'
		  AND b.num_credito not in (select cNumCredUS1 from paso_us)
		  AND b.num_credito >= cred_ini AND b.num_credito  < cred_fin;		
		
		-- 4: CUENTAS PLAZO: DIARIO/CORTE	|	VALIDA CAMPO DE ARCHIVO SALIDA: OUT_CO_ACCOUNT_ID
		insert into paso_us
		SELECT b.numcte, b.num_credito, 'CRD'
		  FROM bdicred:sd_maecredcrd b
		  JOIN bdicred:sd_maecredanexocrd d ON d.empresa = b.empresa AND d.num_credito = b.num_credito 
		  --JOIN bdicobranza:cb_triad_salida f ON f.out_co_account_id='00000000'||b.num_credito 
		  JOIN bdicobranza:cb_triad_salida f ON f.num_credito = b.num_credito 
		 WHERE b.num_producto <> '6800' 
		   AND b.status_cred = 'AA'
		   AND b.num_credito not in (select cNumCredUS1 from paso_us)
		   AND b.num_credito >= cred_ini AND b.num_credito  < cred_fin 
		   AND d.prox_fecha_pago+f.out_coll_next_call_days = vFechahoy; --VIGENTES EN EL CAMPO OUT-COLL-NEXT-CALL-DAYS*		
		
		update statistics medium for table paso_us;
		
		SELECT limit 1 empresa into vEmpresa_2
		  FROM bdicobranza:cb_triad_us
		 WHERE ti_us_account_id >= '600000000001' and fecha_proceso = vFechahoy;
		
		IF nvl(vEmpresa_2,'') <> '' and vEmpresa_2 <> '' then
			begin;
			  delete from paso_us
			  where cNumCredUS1 in (SELECT ti_us_account_id from bdicobranza:cb_triad_us WHERE fecha_proceso = vFechahoy);
			commit;
		END IF;
		
		begin; 
          delete from paso_us
          where cNumCredUS1 in (SELECT num_credito FROM bdicred:sd_inactivos_12meses WHERE num_credito > '600000000001');
		commit;

        update statistics medium for table paso_us;
	
    SELECT max(fecha_reporte) INTO dFechaMax_CleanBehav
	  FROM bdicred:sd_clientes_clean_behavior 
	  WHERE status_bit is null;
				
	SELECT max(fecha_reporte) INTO dFechaMax_Dirty
	  FROM bdicred:sd_clientes_dirty_behavior 
	  WHERE status_bit is null;
	
	FOREACH WITH HOLD
	
		/*SELECT cNumCteUS1,cNumCredUS1,cProductoUS1,vTipo_prod1,cStatusUS1,dFechaAperUS1,
		cPeriodoPlazoUS1,vPlazoUS1,dMontoUS1,cSaldoCapUS1,cSaldoMorUS1,vVencidosUS1, 
		vMontoVencidoUS1,vDiacorte1,vFechacorte1
		INTO cNumCteUS,cNumCredUS,cProductoUS,vTipo_prod,cStatusUS,dFechaAperUS,
		cPeriodoPlazoUS,vPlazoUS,dMontoUS,cSaldoCapUS,cSaldoMorUS,vVencidosUS, 
		vMontoVencidoUS,vDiacorte,vFechacorte
		from paso_us
	    */ 
	    
		SELECT cNumCteUS1, cNumCredUS1, vTipo_prod1
		  INTO cNumCteUS, cNumCredUS, vTipo_prod
		  FROM paso_us
	
		LET iContGral = iContGral + 1;		
		
		LET vTI_US_CUSTOMER_ID 	= trim(cNumCteUS);
		LET vTI_US_ACCOUNT_ID 	= trim(cNumCredUS);
	
	
		IF vTipo_prod = 'REV' THEN

			SELECT a.num_producto, a.status_cred, a.fecha_apertura, a.periodo_plazo, a.plazo,
					  b.monto_otorgado, b.sdo_capital, b.sdo_moratorio, b.mto_fin_ven_trasp, b.monto_vencido, c.dia_corte, c.prox_fecha_pago
			  INTO cProductoUS, cStatusUS, dFechaAperUS, cPeriodoPlazoUS, vPlazoUS, dMontoUS, cSaldoCapUS, cSaldoMorUS, vVencidosUS,  
				   vMontoVencidoUS, vDiacorte, vFechacorte    
			  FROM bdicred:sd_maecred a, bdicred:sd_maesdos b, bdicred:sd_maecredanexo c 
			 WHERE a.num_credito = b.num_credito and a.num_credito = c.num_credito  
			   AND a.num_credito = cNumCredUS;
	
		ELSE
		
			SELECT a.num_producto, a.status_cred, a.fecha_apertura, a.periodo_plazo, a.plazo,
					  b.monto_otorgado, b.sdo_capital, b.sdo_moratorio, b.mto_fin_ven_trasp, b.monto_vencido, c.dia_corte, c.prox_fecha_pago
			  INTO cProductoUS, cStatusUS, dFechaAperUS, cPeriodoPlazoUS, vPlazoUS, dMontoUS, cSaldoCapUS, cSaldoMorUS, vVencidosUS,  
				   vMontoVencidoUS, vDiacorte, vFechacorte    
			  FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c 
			 WHERE a.num_credito = b.num_credito and a.num_credito = c.num_credito  
			   AND a.num_credito = cNumCredUS;
		
		END IF;

		--FECHA DE CORTE: 
		IF vFechacorte IS NULL THEN 
			--LET cFechacorte = '-1'; 			--CAMBIAR ANTES DE LIBERAR
			LET vFechacorte = vFechahoy;
			LET vDiacorte	= DAY(vFechahoy);
		END IF;		
		
		IF day(vFechahoy) <= vDiacorte THEN 					
				LET cFechacorte = TO_CHAR(vFechacorte,'%Y%m%d');
		ELSE 
			LET vFechacorte =  mdy(month(vFechahoy),vDiacorte,year(vFechahoy));
			LET cFechacorte = TO_CHAR(vFechacorte,'%Y%m%d');
		END IF;
			
		--TI-US-USER-DEFINED-KEY-N(67):Grupo de originacion - Index
		--SELECT NVL(grupo,''),NVL(evalua_cc,'') INTO cGrupoUS,cFlagUS 
		SELECT grupo, evalua_cc INTO cGrupoUS_2,cFlagUS_2 
		  FROM bdisolic:ss_resum_scor_fin WHERE empresa=vEmpresa AND num_solicitud=cNumCredUS;
		
		LET cGrupoUS = NVL(cGrupoUS_2,'');
		LET cFlagUS =  NVL(cFlagUS_2,'');
		
		--IF cGrupoUS IS NULL OR cGrupoUS = '' OR cGrupoUS = '0' THEN 
		IF cGrupoUS = '' OR cGrupoUS = '0' THEN 
			LET vTI_US_USER_DEFINED_KEY_N_67 = 0; 
		ELIF  cGrupoUS = '1' THEN
			LET vTI_US_USER_DEFINED_KEY_N_67 = 1;
		ELIF  cGrupoUS = '2' THEN
			LET vTI_US_USER_DEFINED_KEY_N_67 = 2;
		ELIF  cGrupoUS = '3' THEN
			LET vTI_US_USER_DEFINED_KEY_N_67 = 3;
		ELIF  cGrupoUS = '4' THEN
			LET vTI_US_USER_DEFINED_KEY_N_67 = 4;
		ELIF  cGrupoUS = '5' THEN
			LET vTI_US_USER_DEFINED_KEY_N_67 = 5;
		ELIF  cGrupoUS = '6' THEN
			LET vTI_US_USER_DEFINED_KEY_N_67 = 6;
		ELIF  cGrupoUS = 'A' THEN
			LET vTI_US_USER_DEFINED_KEY_N_67 = 7;
		ELIF  cGrupoUS = '8' THEN
			LET vTI_US_USER_DEFINED_KEY_N_67 = 8;
		END IF;	
			
		--TI-US-USER-DEFINED-KEY-N(68):Frecuencia de pago prestamo nomina: 		+0000001 - Quincenal		|	+0000002  Mensual
		IF cProductoUS='6400' THEN
			IF cPeriodoPlazoUS IS NULL OR cPeriodoPlazoUS='' OR cPeriodoPlazoUS='0' THEN 
				LET vTI_US_USER_DEFINED_KEY_N_68 = 0;
			ELIF cPeriodoPlazoUS = 'Q' THEN
				LET vTI_US_USER_DEFINED_KEY_N_68 = 1;
			ELIF cPeriodoPlazoUS = 'M' THEN
				LET vTI_US_USER_DEFINED_KEY_N_68 = 2;
			END IF;
		ELSE
			LET vTI_US_USER_DEFINED_KEY_N_68 = 0;
		END IF;
		
		--TI-US-USER-DEFINED-KEY-N(69): FICO Score: Seccion:3 (FICO SCORE) - Index
		--SELECT NVL(seccion,''), ROUND(NVL(evaluacion,'')) INTO iFicoScoreUS, iEvaluacionUS 
		SELECT seccion, evaluacion INTO iFicoScoreUS_2, iEvaluacionUS_2 
		  FROM bdisolic:ss_resumen_scoring WHERE empresa=vEmpresa AND num_solicitud=cNumCredUS AND seccion='3';
		
		LET iFicoScoreUS = NVL(iFicoScoreUS_2,'');
		-- LET iEvaluacionUS =  ROUND(NVL(iEvaluacionUS_2,''));
		LET iEvaluacionUS =  ROUND(NVL(iEvaluacionUS_2,0));   -- 20200624 Macf
		
		/* -- Cambiar fuente debe ser campo evaluacion
		--IF iFicoScoreUS IS NULL OR iFicoScoreUS='' OR iFicoScoreUS=0 THEN 
		IF iFicoScoreUS='' OR iFicoScoreUS=0 THEN 
			LET vTI_US_USER_DEFINED_KEY_N_69 = 0;
		ELSE
			IF iFicoScoreUS = 3 THEN
				LET vTI_US_USER_DEFINED_KEY_N_69 = iFicoScoreUS;	
			ELSE
				LET vTI_US_USER_DEFINED_KEY_N_69 = 0;
			END IF;	
		END IF;	
		*/
		
		IF iFicoScoreUS='' OR iFicoScoreUS=0 THEN    -- 20200624 Macf
			LET vTI_US_USER_DEFINED_KEY_N_69 = 0;
		ELSE
		    LET vTI_US_USER_DEFINED_KEY_N_69 = iEvaluacionUS;
		END IF;	
		
		--TI-US-USER-DEFINED-KEY-N(70):Flag Informacion:No Hit,Hit sin Informacion,Hit con Informacion.         	--REVISAR CON MARCO & JUAN
		IF cFlagUS IS NULL THEN LET cFlagUSNull = '-1'; END IF;
		IF iEvaluacionUS IS NULL THEN LET cEvaluacionUS = '-1'; END IF;
		
		IF cFlagUS = 'X' OR cFlagUS = '' OR cFlagUSNull = '-1' THEN  
			LET vTI_US_USER_DEFINED_KEY_N_70 = 0;
		ELIF cFlagUS IN ('0','1') AND cEvaluacionUS = '-1' AND iFicoScoreUS = 1 THEN
		--ELIF cFlagUS = '0' AND cEvaluacionUS = '-1' AND iFicoScoreUS = 1 THEN               -- 20200624 Macf
			LET vTI_US_USER_DEFINED_KEY_N_70 = 1;
		ELIF cFlagUS IN ('0','1') AND iEvaluacionUS IN (0,1) AND iFicoScoreUS = 1 THEN
		--ELIF cFlagUS NOT IN ('0','X','') AND iEvaluacionUS = 0 AND iFicoScoreUS = 1 THEN    -- 20200624 Macf
			LET vTI_US_USER_DEFINED_KEY_N_70 = 2;
		ELSE 
			LET vTI_US_USER_DEFINED_KEY_N_70 = 0;
		END IF;
		
		--TI-US-USER-DEFINED-KEY-N(71):Flag Hit:No Hit,Hit	
		IF cFlagUS = '' OR cFlagUSNull = '-1'OR cFlagUS = 'X' THEN  
			LET vTI_US_USER_DEFINED_KEY_N_71 = 0;
		ELIF cFlagUS IN ('0','1') THEN
		--ELIF cFlagUS IN ('0','1','2','4') THEN                      -- 20200624 Macf
			LET vTI_US_USER_DEFINED_KEY_N_71 = 1;
		ELSE
			LET vTI_US_USER_DEFINED_KEY_N_71 = 0;
		END IF;

		--TI-US-USER-DEFINED-KEY-N(72): Flag Convenio: 		+0000000 - Sin Convenio vigente (activo)		|		+0000001 - Con Convenio vigente (activo)	- 	Index
		SELECT LIMIT 1 plazo, importe, TODAY-fecha_compac, fecha_compac+(plazo*7), fecha_compac+(plazo*14), activo 
		  --INTO iPlazo, vMontoUltConvenio, iDiasTransUltConv, cFechaVctoConv1, cFechaVctoConv2, iActivo 
		  INTO iPlazo, vMontoUltConvenio, iDiasTransUltConv, dFechaVctoConv1, cFechaVctoConv2, iActivo        --- 20200624 Macf
		  FROM bdicobranza:cb_compac 
		  WHERE numcuenta = cNumCredUS AND activo = '1';

		 --WHERE empresa=vEmpresa AND numcuenta=cNumCredUS 
		   --AND fecha_compac=(SELECT MAX(fecha_compac) FROM bdicobranza:cb_compac WHERE empresa=vEmpresa AND numcuenta=cNumCredUS);
		
		--IF iActivo IS NULL THEN LET cActivo='-1'; END IF;
		
		--IF cActivo='-1' OR iActivo = '' OR iActivo = 0 THEN  
		--IF nvl(iPlazo,'') = '' or iPlazo = '' THEN
		IF nvl(iPlazo,'') = '' or iPlazo = '' or iPlazo = 0 THEN   -- 20200624 Macf
		   LET vTI_US_USER_DEFINED_KEY_N_72 = 0;
		ELSE 
			LET vTI_US_USER_DEFINED_KEY_N_72 = 1;
		END IF;
		
		--TI-US-USER-DEFINED-KEY-N(73): Numero de dias transcurridos desde el convenio
		IF iDiasTransUltConv IS NULL THEN LET cDiasTransUltConv='-1'; END IF;
		
		IF iDiasTransUltConv = '' OR cDiasTransUltConv='-1' OR iDiasTransUltConv = 0 THEN  
			LET vTI_US_USER_DEFINED_KEY_N_73 = 0;
		ELSE 
			LET vTI_US_USER_DEFINED_KEY_N_73 = iDiasTransUltConv;
		END IF;
		
		--TI-US-USER-DEFINED-KEY-N(74):Numero de dias restantes para vencimiento de convenio
		IF iPlazo IS NULL THEN LET cPlazo='-1'; END IF;
		
		IF cPlazo='-1' OR iPlazo = '' OR iPlazo <= 0 OR cActivo='-1' OR iActivo = 0 OR iActivo = '' THEN  
		   LET vTI_US_USER_DEFINED_KEY_N_74 = 0;
		ELSE 
			/*IF iPlazo = 1 AND iActivo = 1 THEN
				LET iDiasRestConv = vFechahoy - date(cFechaVctoConv1); 
				LET vTI_US_USER_DEFINED_KEY_N_74 = iDiasRestConv;
			ELIF iPlazo = 2 AND iActivo = 1 THEN
				LET iDiasRestConv = vFechahoy - date(cFechaVctoConv2);
				LET vTI_US_USER_DEFINED_KEY_N_74 = iDiasRestConv;
			END IF;*/
			
			--LET iDiasRestConv = date(dFechaVctoConv1 - vFechahoy) units DAY;   -- 20200624 Macf
			--LET iDiasRestConv = (dFechaVctoConv1 - vFechahoy) units DAY;   -- 20200624 Macf 
			--LET iDiasRestConv = dFechaVctoConv1 - vFechahoy units DAY;   -- 20200624 Macf error
			--LET vTI_US_USER_DEFINED_KEY_N_74 = iDiasRestConv;          -- 20200701 error en la asignación			
			--LET vTI_US_USER_DEFINED_KEY_N_74 = (dFechaVctoConv1 - vFechahoy) units DAY;
			LET vTI_US_USER_DEFINED_KEY_N_74 = dFechaVctoConv1 - vFechahoy;

		END IF;
		--date(vFechahoy -1 units day);
		--TI-US-USER-DEFINED-KEY-N(75): Monto convenio vigente
		IF vMontoUltConvenio IS NULL THEN LET cMontoUltConvenio = '-1'; END IF;
		
		IF cMontoUltConvenio = '-1' OR vMontoUltConvenio = '' OR vMontoUltConvenio = 0 THEN  
			LET vTI_US_USER_DEFINED_KEY_N_75 = 0.0;
		ELSE
		    IF iActivo = 1 THEN
				LET vTI_US_USER_DEFINED_KEY_N_75 = vMontoUltConvenio;
			ELSE 
				LET vTI_US_USER_DEFINED_KEY_N_75 = 0.0;
			END IF;
		END IF;
		
		--TI-US-USER-DEFINED-KEY-N(76): Cantidad convenio U3M: Numero de convenios en los ultimos 3 meses
		IF vTipo_prod = 'REV' THEN
			--INTO iCantidadConv3,iCantidadConv6,iCantidadConv12,iCantCumplioConv3,iCantCumplioConv6,iCantCumplioConv12,iCantNoCumplioConv3,iCantNoCumplioConv6,iCantNoCumplioConv12
			SELECT num_convenio_cumplido_1m,num_convenio_cumplido_2m,num_convenio_cumplido_3m,num_convenio_cumplido_4m,num_convenio_cumplido_5m,num_convenio_cumplido_6m,num_convenio_cumplido_7m,num_convenio_cumplido_8m,num_convenio_cumplido_9m,num_convenio_cumplido_10m,num_convenio_cumplido_11m, 
			num_convenio_nocumplido_1m, num_convenio_nocumplido_2m,num_convenio_nocumplido_3m,num_convenio_nocumplido_4m,num_convenio_nocumplido_5m,num_convenio_nocumplido_6m,num_convenio_nocumplido_7m,num_convenio_nocumplido_8m,num_convenio_nocumplido_9m,num_convenio_nocumplido_10m,num_convenio_nocumplido_11m,
			num_vencidos1
			INTO iCantCumplio1,iCantCumplio2,iCantCumplio3,iCantCumplio4,iCantCumplio5,iCantCumplio6,iCantCumplio7,iCantCumplio8,iCantCumplio9,iCantCumplio10,iCantCumplio11,
				 iCantNoCumplio1,iCantNoCumplio2,iCantNoCumplio3,iCantNoCumplio4,iCantNoCumplio5,iCantNoCumplio6,iCantNoCumplio7,iCantNoCumplio8,iCantNoCumplio9,iCantNoCumplio10,iCantNoCumplio11, 
				 vVencidosUS1
			--FROM bdicobranza:cb_triad_sdos_inds_cnr 
			FROM bdicobranza:cb_triad_sdos_inds_tdc 
			WHERE num_credito=cNumCredUS;
		ELSE --INTO iCantidadConv3,iCantidadConv6,iCantidadConv12,iCantCumplioConv3,iCantCumplioConv6,iCantCumplioConv12,iCantNoCumplioConv3,iCantNoCumplioConv6,iCantNoCumplioConv12
			SELECT num_convenio_cumplido_1m,num_convenio_cumplido_2m,num_convenio_cumplido_3m,num_convenio_cumplido_4m,num_convenio_cumplido_5m,num_convenio_cumplido_6m,num_convenio_cumplido_7m,num_convenio_cumplido_8m,num_convenio_cumplido_9m,num_convenio_cumplido_10m,num_convenio_cumplido_11m,
			num_convenio_nocumplido_1m, num_convenio_nocumplido_2m,num_convenio_nocumplido_3m,num_convenio_nocumplido_4m,num_convenio_nocumplido_5m,num_convenio_nocumplido_6m,num_convenio_nocumplido_7m,num_convenio_nocumplido_8m,num_convenio_nocumplido_9m,num_convenio_nocumplido_10m,num_convenio_nocumplido_11m,
			num_vencidos1
			INTO iCantCumplio1,iCantCumplio2,iCantCumplio3,iCantCumplio4,iCantCumplio5,iCantCumplio6,iCantCumplio7,iCantCumplio8,iCantCumplio9,iCantCumplio10,iCantCumplio11,
				 iCantNoCumplio1,iCantNoCumplio2,iCantNoCumplio3,iCantNoCumplio4,iCantNoCumplio5,iCantNoCumplio6,iCantNoCumplio7,iCantNoCumplio8,iCantNoCumplio9,iCantNoCumplio10,iCantNoCumplio11,
				 vVencidosUS1
			--FROM bdicobranza:cb_triad_sdos_inds_tdc 
			FROM bdicobranza:cb_triad_sdos_inds_cnr 
			WHERE num_credito=cNumCredUS;
		END IF;
		
		--LET iCantidadConv3 = (iCantNoCumplio1+iCantNoCumplio2+iCantNoCumplio3)+(iCantNoCumplio1+iCantNoCumplio2+iCantNoCumplio3);
		LET iCantidadConv3 = (iCantCumplio1+iCantCumplio2+iCantCumplio3)+(iCantNoCumplio1+iCantNoCumplio2+iCantNoCumplio3); --Modif Macf 20200608
		IF iCantidadConv3 = '' OR iCantidadConv3 IS NULL or iCantidadConv3 = 0 THEN  
		   LET vTI_US_USER_DEFINED_KEY_N_76 = 0;
		ELSE 
			LET vTI_US_USER_DEFINED_KEY_N_76 = iCantidadConv3;
		END IF;
		
		--TI-US-USER-DEFINED-KEY-N(77): Cantidad convenio U6M: Numero de convenios en los ultimos 6 meses			
		--LET iCantidadConv6 = (iCantCumplio1+iCantCumplio2+iCantCumplio3+iCantNoCumplio4+iCantNoCumplio5+iCantNoCumplio6)+(iCantNoCumplio1+iCantNoCumplio2+iCantNoCumplio3+iCantNoCumplio4+iCantNoCumplio5+iCantNoCumplio6);
		LET iCantidadConv6 = (iCantCumplio1+iCantCumplio2+iCantCumplio3+iCantCumplio4+iCantCumplio5+iCantCumplio6)+(iCantNoCumplio1+iCantNoCumplio2+iCantNoCumplio3+iCantNoCumplio4+iCantNoCumplio5+iCantNoCumplio6);
		
		IF iCantidadConv6 = '' OR iCantidadConv6 IS NULL or iCantidadConv6 = 0 THEN  
		   LET vTI_US_USER_DEFINED_KEY_N_77 = 0;
		ELSE 
			LET vTI_US_USER_DEFINED_KEY_N_77 = iCantidadConv6;
		END IF;
		
		--TI-US-USER-DEFINED-KEY-N(78): Cantidad convenio U12M: Numero de convenios en los ultimos 12 meses		
		LET iCantidadConv12 = (iCantCumplio1+iCantCumplio2+iCantCumplio3+iCantCumplio4+iCantCumplio5+iCantCumplio6+iCantCumplio7+iCantCumplio8+iCantCumplio9+iCantCumplio10+iCantCumplio11+iCantCumplio12)+
							  (iCantNoCumplio1+iCantNoCumplio2+iCantNoCumplio3+iCantNoCumplio4+iCantNoCumplio5+iCantNoCumplio6+iCantNoCumplio7+iCantNoCumplio8+iCantNoCumplio9+iCantNoCumplio10+iCantNoCumplio11+iCantNoCumplio12);
							  
		IF iCantidadConv12 = '' OR iCantidadConv12 IS NULL or iCantidadConv12 = 0 THEN  
		   LET vTI_US_USER_DEFINED_KEY_N_78 = 0;
		ELSE 
			LET vTI_US_USER_DEFINED_KEY_N_78 = iCantidadConv12 ;
		END IF;
		
		--TI-US-USER-DEFINED-KEY-N(79): Convenios cumplidos U3M		
		LET iCantCumplioConv3 = (iCantCumplio1+iCantCumplio2+iCantCumplio3);
		
		IF iCantCumplioConv3 = '' OR iCantCumplioConv3 IS NULL or iCantCumplioConv3 = 0 THEN  
		   LET vTI_US_USER_DEFINED_KEY_N_79 = 0;
		ELSE
			LET vTI_US_USER_DEFINED_KEY_N_79 = iCantCumplioConv3;
		END IF;

		--TI-US-USER-DEFINED-KEY-N(80): Convenios cumplidos U6M
		--LET iCantCumplioConv6 = (iCantCumplio1+iCantCumplio2+iCantCumplio3+iCantNoCumplio4+iCantNoCumplio5+iCantNoCumplio6);
		LET iCantCumplioConv6 = (iCantCumplio1+iCantCumplio2+iCantCumplio3+iCantCumplio4+iCantCumplio5+iCantCumplio6);
		
		IF iCantCumplioConv6 = '' OR iCantCumplioConv6 IS NULL or iCantCumplioConv6 = 0 THEN  
		   LET vTI_US_USER_DEFINED_KEY_N_80 = 0;
		ELSE
			LET vTI_US_USER_DEFINED_KEY_N_80 = iCantCumplioConv6;
		END IF;
		
		--TI-US-USER-DEFINED-KEY-N(81): Convenios cumplidos U12M
		LET iCantCumplioConv12 = (iCantCumplio1+iCantCumplio2+iCantCumplio3+iCantCumplio4+iCantCumplio5+iCantCumplio6+iCantCumplio7+iCantCumplio8+iCantCumplio9+iCantCumplio10+iCantCumplio11+iCantCumplio12);
		
		IF iCantCumplioConv12 = '' OR iCantCumplioConv12 IS NULL or iCantCumplioConv12 = 0 THEN  
		   LET vTI_US_USER_DEFINED_KEY_N_81 = 0;
		ELSE
			LET vTI_US_USER_DEFINED_KEY_N_81 = iCantCumplioConv12;
		END IF;
		
		--TI-US-USER-DEFINED-KEY-N(82): Convenios no cumplidos U3M
		LET iCantNoCumplioConv3 = (iCantNoCumplio1+iCantNoCumplio2+iCantNoCumplio3);
		
		IF iCantNoCumplioConv3 = '' OR iCantNoCumplioConv3 IS NULL or iCantNoCumplioConv3 = 0 THEN  
		   LET vTI_US_USER_DEFINED_KEY_N_82 = 0;
		ELSE
			LET vTI_US_USER_DEFINED_KEY_N_82 = iCantNoCumplioConv3;
		END IF;
		
		--TI-US-USER-DEFINED-KEY-N(83):Convenios no cumplidos U6M
		LET iCantNoCumplioConv6 = (iCantNoCumplio1+iCantNoCumplio2+iCantNoCumplio3+iCantNoCumplio4+iCantNoCumplio5+iCantNoCumplio6);
		
		IF iCantNoCumplioConv6 = '' OR iCantNoCumplioConv6 IS NULL or iCantNoCumplioConv6 = 0 THEN  
		   LET vTI_US_USER_DEFINED_KEY_N_83 = 0;
		ELSE
			LET vTI_US_USER_DEFINED_KEY_N_83 = iCantNoCumplioConv6;
		END IF;
		
		--TI-US-USER-DEFINED-KEY-N(84):Convenios no cumplidos U12M
		LET iCantNoCumplioConv12 = (iCantNoCumplio1+iCantNoCumplio2+iCantNoCumplio3+iCantNoCumplio4+iCantNoCumplio5+iCantNoCumplio6+iCantNoCumplio7+iCantNoCumplio8+iCantNoCumplio9+iCantNoCumplio10+iCantNoCumplio11+iCantNoCumplio12);
		
		IF iCantNoCumplioConv12 = '' OR iCantNoCumplioConv12 IS NULL or iCantNoCumplioConv12 = 0 THEN  
		   LET vTI_US_USER_DEFINED_KEY_N_84 = 0;
		ELSE
			LET vTI_US_USER_DEFINED_KEY_N_84 = iCantNoCumplioConv12;
		END IF;
	
		--TI-US-USER-DEFINED-KEY-N(85): Cantidad de contactos en CAT: Numero de contactos en el CAT dia anterior al proceso		-	INDEX
		--MACF METERLE FECHA
		--SELECT COUNT(contacto) INTO iContacto FROM bdicobranza:cb_cat_movimientos WHERE cliente=TRIM(vTI_US_CUSTOMER_ID);	--old	
		--SELECT COUNT(contacto) INTO iContacto FROM bdicobranza:cb_cat_movimientos WHERE cliente = vTI_US_CUSTOMER_ID and date(fechahorallamada) = vFechahoy-1;  -- Macf
		
		SELECT cant_contacto_ayer, cant_contacto_ultmes into iContacto, iContacto1M --cant_contacto_ultmes, fecha_proceso 
        FROM bdicobranza:cb_triad_catmovimientos
		WHERE numcte = vTI_US_CUSTOMER_ID;
		
		let iContacto = nvl(iContacto,0);
		let iContacto1M = nvl(iContacto1M,0);
		
		IF iContacto = '' OR iContacto IS NULL or iContacto <= 0 THEN  
		   LET vTI_US_USER_DEFINED_KEY_N_85 = 0;
		ELSE 
			LET vTI_US_USER_DEFINED_KEY_N_85 = iContacto;
		END IF;

		--TI-US-USER-DEFINED-KEY-N(86): Cantidad llamadas U1M: Numero de llamadas en el ultimo mes -		 contacto:0, C, F, H, M, N, P, X  | tipotelefono:0,1,2,3    | cobranzacat: 3   | aclaracion: 0,1,2,3,4,5
		/*SELECT count(contacto) INTO iContacto1M  --old 
		  FROM bdicobranza:cb_cat_movimientos 
		 WHERE cliente= vTI_US_CUSTOMER_ID 
		   AND fechacartera BETWEEN bdicred:monthadd(vFechahoy,-1) AND vFechahoy; */

		/*SELECT cant_contacto_ultmes INTO iContacto1M
          FROM bdicobranza:cb_triad_catmovimientos
		 WHERE numcte = vTI_US_CUSTOMER_ID;  */
		   
		IF iContacto1M = '' OR iContacto1M IS NULL or iContacto1M <= 0 THEN  
		   LET vTI_US_USER_DEFINED_KEY_N_86 = 0;
		ELSE 
			LET vTI_US_USER_DEFINED_KEY_N_86 = iContacto1M;
		END IF;

		--TI-US-CANTIDAD-CUENTA: Cantidad total de cuentas que el cliente tiene (no considerar las cuentas que son exclusiones generales)	- 	ABAJO CUENTA
		
		------------------------------------------------------------------------------------------------------------------------------------
		-- CUENTA 1
		------------------------------------------------------------------------------------------------------------------------------------
		--TI-US-CT-CICLO-MOR(1): Ciclo moroso actual. Numero de meses vencidos del ciclo actual. Mismo valor que TI-RV-CYCLES-DELQ(1) o TI-LN-CYCLES-DELQ(1) de la cuenta correspondiente. 
		IF vVencidosUS IS NULL THEN  LET cVencidosUS = '-1'; END IF;
		
		IF vVencidosUS = '' OR vVencidosUS = 0 OR cVencidosUS = '-1' THEN  
			LET vTI_US_CT_CICLO_MOR_1 = 0;
		ELSE
			LET vTI_US_CT_CICLO_MOR_1 = vVencidosUS;						--TI_LN_CYCLES_DELQ_1:NO esta declarada en el SP principal, YURI envia correo para tomar TI-LN-NUM-MTHS-IN-ARREARS(1)
		END IF;
		
		--TI-US-CT-CICLO-MOR-MES-ANT(1):Ciclo moroso ciclo anterior. Numero de meses vencidos del ciclo anterior.				
		IF vVencidosUS1 IS NULL THEN  LET cVencidosUS1 = '-1'; END IF;
		
		IF vVencidosUS1 = '' OR vVencidosUS1 = 0 OR cVencidosUS1 = '-1' THEN
			LET vTI_US_CT_CICLO_MOR_MES_ANT_1 = 0;
		ELSE
			LET vTI_US_CT_CICLO_MOR_MES_ANT_1 = vVencidosUS1;		--TI_LN_CYCLES_DELQ_1:NO esta declarada en el SP principal, YURI envia correo para tomar TI-LN-NUM-MTHS-IN-ARREARS(1)
		END IF;
		
		
		--TI-US-CT-ID(1): Identificador de la cuenta. Numero de Credito. Mismo valor que TI-RV-ACCOUNT-ID o TI-LN-ACCOUNT-ID de la cuenta correspondiente. TI_RV_ACCOUNT_ID	|	TI_LN_ACCOUNT_ID
		LET vTI_US_CT_ID_1= cNumCredUS;
		
		--TI-US-CT-TIPO(1): Tipo de la cuenta. Para tarjetas: 1: Clasica 2: Oro 3: Platino Para prestamos: 1: Prestamo 2: Nomina 3: Reestructura
		IF cProductoUS IN ('6001','6300','7600','7700') THEN 
			LET vTI_US_CT_TIPO_1 = 1;										
		ELIF cProductoUS IN ('8100','6400') THEN 
			LET vTI_US_CT_TIPO_1 = 2; 
		ELIF cProductoUS IN ('7000','6011') THEN 
			LET vTI_US_CT_TIPO_1 = 3; 
		END IF;
		
		--TI-US-CT-FECHA-APERTURA(1): Mismo valor que TI-RV-DATE-OPEN o TI-LN-DATE-OPEN. CCYYMMDD. 
		IF dFechaAperUS = '' OR dFechaAperUS IS NULL THEN
			LET vTI_US_CT_FECHA_APERTURA_1 = '01/01/1900';
		ELSE
			LET vTI_US_CT_FECHA_APERTURA_1 = dFechaAperUS;		--TI_LN_DATE_OPEN;     --TI_RV_DATE_OPEN;	
		END IF;
		
		--TI-US-CT-FRECUENCIA-PAGO(1):Frecuencia de pago del prestamo, M: mensual, Q:quincenal
		IF cPeriodoPlazoUS IS NULL OR cPeriodoPlazoUS = '' OR cPeriodoPlazoUS = '0' THEN 
			LET vTI_US_CT_FRECUENCIA_PAGO_1 = 0;
		ELIF cPeriodoPlazoUS='M' THEN
			LET vTI_US_CT_FRECUENCIA_PAGO_1 = 1;
		ELIF cPeriodoPlazoUS='Q' THEN
			LET vTI_US_CT_FRECUENCIA_PAGO_1 = 2;
		END IF;	

		--TI-US-CT-LIMITE(1): Limite de la tarjeta, en caso del prestamo el monto original del credito.   
		IF dMontoUS IS NULL OR dMontoUS='' OR dMontoUS = 0 THEN 
			LET vTI_US_CT_LIMITE_1 = 0.0;
		ELSE 
			LET vTI_US_CT_LIMITE_1 = dMontoUS;
		END IF;	
		
		--TI-US-CT-PEOR-CICLO-MOR-U12M(1): Peor ciclo moroso en los ultimos 12 meses, topa como maximo a 9
		IF vTipo_prod = 'REV' THEN
			
			SELECT peor_mora_12m,sdo_tot_liquidar,sdo_tot_vencido INTO vPeorCicloMora,dSdoTotalLiq,dSaldoVencido 
			  FROM bdicred:sd_indicador_cred WHERE empresa=vEmpresa AND num_credito=cNumCredUS;				

			IF vPeorCicloMora IS NULL THEN  LET cPeorCicloMora = '-1'; END IF;
			LET dSaldoVencido = NVL(dSaldoVencido,0);
			
			IF dSaldoVencido < 0 THEN
			   LET dSaldoVencido = 0;
			END IF;
			
			IF cPeorCicloMora = '-1' OR vPeorCicloMora='' OR vPeorCicloMora=0 THEN 
				LET vTI_US_CT_PEOR_CICLO_MOR_U12M_1 = 0;
			ELSE
				LET vTI_US_CT_PEOR_CICLO_MOR_U12M_1 = vPeorCicloMora;
			END IF;
			
		ELIF vTipo_prod = 'CRD' THEN			
			SELECT peor_mora_12m,sdo_tot_liquidar,sdo_tot_vencido INTO vPeorCicloMora,dSdoTotalLiq,dSaldoVencido 
			  FROM bdicred:sd_indicador_cred_crd WHERE empresa=vEmpresa AND num_credito=cNumCredUS;
				
			IF vPeorCicloMora IS NULL THEN  LET cPeorCicloMora = '-1'; END IF;
			
			IF cPeorCicloMora = '-1' OR vPeorCicloMora='' OR vPeorCicloMora=0 THEN 
				LET vTI_US_CT_PEOR_CICLO_MOR_U12M_1 = 0;
			ELSE
				LET vTI_US_CT_PEOR_CICLO_MOR_U12M_1 = vPeorCicloMora;
			END IF; 
		END IF;
		
		--TI-US-CT-PLAZO(1): Plazo del prestamo. En el caso de tarjeta 000. 
		IF vPlazoUS IS NULL THEN LET cPlazoUS='-1'; END IF;
		
		IF vPlazoUS = ''OR vPlazoUS = 0 OR cPlazoUS = '-1' THEN
			LET vTI_US_CT_PLAZO_1 = 0;
		ELSE
			IF vTipo_prod = 'REV' THEN
				LET vTI_US_CT_PLAZO_1 = 0;
			ELIF vTipo_prod = 'CRD' THEN	
				LET vTI_US_CT_PLAZO_1=vPlazoUS;
			END IF;
		END IF;

		--TI-US-CT-SALDO(1): Saldo de la cuenta al corte (Mismo valor que TI-RV-CURR-BALANCE o TI-LN-BALANCE(1) de la cuenta correspondiente) 
		IF dSdoTotalLiq IS NULL THEN LET cSdoTotalLiq='-1'; END IF;
		
		IF dSdoTotalLiq = 0 OR dSdoTotalLiq ='' OR cSdoTotalLiq='-1' THEN
			let vTI_US_CT_SALDO_1 = 0;
		ELSE
			LET	vTI_US_CT_SALDO_1 = dSdoTotalLiq;
		END IF;

		--TI-US-CT-SALDO-VENCIDO(1):Saldo vencido de la cuenta al corte(Mismo valor que TI-RV-VAL-ARREARS(1) o TI-LN-VAL-ARREARS(1) de la cuenta correspondiente)		
		IF dSaldoVencido IS NULL THEN LET cSaldoVencido='-1'; END IF;
			
		IF cSaldoVencido = '-1' OR dSaldoVencido='' OR dSaldoVencido = 0 THEN
			LET vTI_US_CT_SALDO_VENCIDO_1 = 0;
		ELSE
			LET vTI_US_CT_SALDO_VENCIDO_1 = dSaldoVencido;
		END IF; 			
			
		--TI-US-CT-SCORE(1): Score de comportamiento de la cuenta(Valor del Score de Comportamiento (Behaviour Score) de la cuenta correspondiente) - Index
		/*SELECT MAX(fecha_insert) INTO dFechaBehavior FROM bdicred:sd_ctes_behavior;
		select score, segmento INTO iScoreBehavior, cSegmento from bdicred:sd_ctes_behavior where num_credito = cNumCredUS AND fecha_insert = dFechaBehavior;
		*/
		
		/*select score, segmento into iScoreBehavior, cSegmento
		  from bdicred:sd_ctes_behavior where num_credito = cNumCredUS
           and fecha_insert = ( select max(a.fecha_insert) from bdicred:sd_ctes_behavior a where a.num_credito = cNumCredUS);
		*/

		-- 2020-02-11 Se cambia el origen de obtención del Behaviour Score
		IF vTipo_prod = 'REV' THEN
				
				SELECT NVL(score,'') INTO cScoreBehavior 
				  FROM bdicred:sd_clientes_clean_behavior
				 WHERE fecha_reporte = dFechaMax_CleanBehav
				   AND num_credito = cNumCredUS 
				   AND status_bit is null;
				   
				IF cScoreBehavior <> '' THEN
				   LET iScoreBehavior = cScoreBehavior;
				   LET vTI_US_CT_SCORE_ID_1 = 1;
				ELSE
						SELECT NVL(score,'') INTO cScoreBehavior 
						  FROM bdicred:sd_clientes_dirty_behavior
						 WHERE fecha_reporte = dFechaMax_Dirty
						   AND num_credito = cNumCredUS 
						   AND status_bit is null;   
						   
						   IF cScoreBehavior <> '' THEN
							  LET iScoreBehavior = cScoreBehavior;
							  LET vTI_US_CT_SCORE_ID_1 = 3;
						   ELSE 
					          LET iScoreBehavior = 0;	   
							  LET vTI_US_CT_SCORE_ID_1 = 0;
						   END IF;
				END IF;
		ELIF vTipo_prod = 'CRD' THEN
 		     LET vTI_US_CT_SCORE_ID_1 = 4;
			 LET iScoreBehavior = 0;
		END IF;
		
		LET vTI_US_CT_SCORE_1 = iScoreBehavior;

		/*IF iScoreBehavior IS NULL OR iScoreBehavior = '' OR iScoreBehavior = 0 THEN 
			LET vTI_US_CT_SCORE_1 = 0; 
		ELSE 
			LET vTI_US_CT_SCORE_1 = iScoreBehavior;
		END IF;
		*/
		
		
		-- 2020-02-11 Se cambia el origen de obtención del Behaviour Score
		--TI-US-CT-SCORE-ID(1): Mismo valor que TI-CU-SCRD-ID(1) para la cuenta correspondiente.
		/*IF cSegmento IS NULL OR cSegmento='' OR cSegmento='0' THEN 
			LET vTI_US_CT_SCORE_ID_1 = 0; 
		ELIF  cSegmento = 'Clean_thick' THEN
			LET vTI_US_CT_SCORE_ID_1 = 1;		
		ELIF  cSegmento = 'Clean_thin' THEN
			LET vTI_US_CT_SCORE_ID_1 = 2;
		ELIF  cSegmento = 'Dirty' THEN
			LET vTI_US_CT_SCORE_ID_1 = 3;
		ELIF  cSegmento = 'Prestamo' THEN
			LET vTI_US_CT_SCORE_ID_1 = 4;
		END IF;
		*/
		
		--TI-US-CT-TIPO-PROD(1): Mismo valor de TI-CO-PROD-TYPE de la cuenta correspondiente. 
		IF vTipo_prod = 'REV' THEN
			LET vTI_US_CT_TIPO_PROD_1 = 3;
		ELIF vTipo_prod = 'CRD' THEN	
			LET vTI_US_CT_TIPO_PROD_1 = 5;
		END IF;		
	
		--TI-US-CANTIDAD-CUENTA: Cantidad total de cuentas que el cliente tiene (no considerar las cuentas que son exclusiones generales)	- 	ABAJO CUENTA		
		IF cNumCteAnt = '' THEN
			LET iTotalCuentas = 1;
			LET vTI_US_CANTIDAD_CUENTA = 1;
		ELIF cNumCteAnt = cNumCteUS THEN
				LET iTotalCuentas = iTotalCuentas + 1;
				
				IF iTotalCuentas>=9 THEN 
					LET vTI_US_CANTIDAD_CUENTA = 9;
				ELSE
					LET vTI_US_CUSTOMER_ID=TRIM(vTI_US_CUSTOMER_ID);
					LET cTotalCuentas=iTotalCuentas;
					begin;
						UPDATE bdicobranza:cb_triad_us SET ti_us_cantidad_cuenta = iTotalCuentas 
						 WHERE empresa = vEmpresa AND ti_us_customer_id = vTI_US_CUSTOMER_ID;
					commit;
					LET vTI_US_CANTIDAD_CUENTA = iTotalCuentas;
				END IF;
		ELSE
			LET iTotalCuentas= 1;
			LET vTI_US_CANTIDAD_CUENTA = 1;
		END IF;
		
		LET cNumCteAnt = cNumCteUS;		
	---------------------------------------------------------------------------------------------------------------------	
		--SELECT COUNT(ti_us_account_id) INTO iExisteCuenta
		SELECT empresa INTO cEmpresa_10
		FROM bdicobranza:cb_triad_us 
		WHERE empresa = vEmpresa AND ti_us_account_id = vTI_US_ACCOUNT_ID;
		
		IF NVL(cEmpresa_10,'') <> '' THEN  let iExisteCuenta = 1; END IF;

		 		
		IF iExisteCuenta > 0 THEN
			begin;
				UPDATE  bdicobranza:cb_triad_us 
				SET  
				ti_us_user_defined_key_n_67		= 	vTI_US_USER_DEFINED_KEY_N_67,
				ti_us_user_defined_key_n_68 	= 	vTI_US_USER_DEFINED_KEY_N_68,
				ti_us_user_defined_key_n_69 	= 	vTI_US_USER_DEFINED_KEY_N_69,
				ti_us_user_defined_key_n_70 	= 	vTI_US_USER_DEFINED_KEY_N_70,
				ti_us_user_defined_key_n_71 	= 	vTI_US_USER_DEFINED_KEY_N_71,
				ti_us_user_defined_key_n_72 	= 	vTI_US_USER_DEFINED_KEY_N_72,
				ti_us_user_defined_key_n_73 	= 	vTI_US_USER_DEFINED_KEY_N_73,
				ti_us_user_defined_key_n_74 	= 	vTI_US_USER_DEFINED_KEY_N_74,
				ti_us_user_defined_key_n_75 	= 	vTI_US_USER_DEFINED_KEY_N_75,
				ti_us_user_defined_key_n_76		= 	vTI_US_USER_DEFINED_KEY_N_76,
				ti_us_user_defined_key_n_77 	= 	vTI_US_USER_DEFINED_KEY_N_77,
				ti_us_user_defined_key_n_78 	= 	vTI_US_USER_DEFINED_KEY_N_78,
				ti_us_user_defined_key_n_79 	= 	vTI_US_USER_DEFINED_KEY_N_79,
				ti_us_user_defined_key_n_80 	= 	vTI_US_USER_DEFINED_KEY_N_80,
				ti_us_user_defined_key_n_81 	= 	vTI_US_USER_DEFINED_KEY_N_81,
				ti_us_user_defined_key_n_82 	= 	vTI_US_USER_DEFINED_KEY_N_82,
				ti_us_user_defined_key_n_83 	= 	vTI_US_USER_DEFINED_KEY_N_83,
				ti_us_user_defined_key_n_84 	= 	vTI_US_USER_DEFINED_KEY_N_84,
				ti_us_user_defined_key_n_85 	= 	vTI_US_USER_DEFINED_KEY_N_85,
				ti_us_user_defined_key_n_86 	= 	vTI_US_USER_DEFINED_KEY_N_86,
				
				ti_us_ct_ciclo_mor_1  			= 	vTI_US_CT_CICLO_MOR_1,
				ti_us_ct_ciclo_mor_mes_ant_1	=	vTI_US_CT_CICLO_MOR_MES_ANT_1,
				ti_us_ct_id_1					=	vTI_US_CT_ID_1,
				ti_us_ct_tipo_1					=	vTI_US_CT_TIPO_1,
				ti_us_ct_fecha_apertura_1		=	vTI_US_CT_FECHA_APERTURA_1,
				ti_us_ct_frecuencia_pago_1		=	vTI_US_CT_FRECUENCIA_PAGO_1,
				ti_us_ct_limite_1				=	vTI_US_CT_LIMITE_1,
				ti_us_ct_peor_ciclo_mor_u12m_1	=	vTI_US_CT_PEOR_CICLO_MOR_U12M_1,
				ti_us_ct_plazo_1				=	vTI_US_CT_PLAZO_1,
				ti_us_ct_saldo_1				=	vTI_US_CT_SALDO_1,
				ti_us_ct_saldo_vencido_1		=	vTI_US_CT_SALDO_VENCIDO_1,
				ti_us_ct_score_1				=	vTI_US_CT_SCORE_1,
				ti_us_ct_score_id_1				=	vTI_US_CT_SCORE_ID_1,
				ti_us_ct_tipo_prod_1			=	vTI_US_CT_TIPO_PROD_1,
				ti_us_cantidad_cuenta 			= 	vTI_US_CANTIDAD_CUENTA,
				fecha_proceso = vFechahoy
				WHERE empresa = vEmpresa AND ti_us_account_id = vTI_US_ACCOUNT_ID;
			commit;

	ELSE
		begin;
			 insert into bdicobranza:"informix".cb_triad_us(empresa,ti_us_customer_id,ti_us_account_id,
			 ti_us_user_defined_key_n_67,ti_us_user_defined_key_n_68,
			 ti_us_user_defined_key_n_69,ti_us_user_defined_key_n_70,ti_us_user_defined_key_n_71,ti_us_user_defined_key_n_72,ti_us_user_defined_key_n_73,ti_us_user_defined_key_n_74,
			 ti_us_user_defined_key_n_75,ti_us_user_defined_key_n_76,ti_us_user_defined_key_n_77,ti_us_user_defined_key_n_78,ti_us_user_defined_key_n_79,ti_us_user_defined_key_n_80,
			 ti_us_user_defined_key_n_81,ti_us_user_defined_key_n_82,ti_us_user_defined_key_n_83,ti_us_user_defined_key_n_84,ti_us_user_defined_key_n_85,ti_us_user_defined_key_n_86,
			 --segunda parte
			 ti_us_ct_ciclo_mor_1,ti_us_ct_ciclo_mor_mes_ant_1,ti_us_ct_id_1,
			 ti_us_ct_tipo_1,ti_us_ct_fecha_apertura_1,ti_us_ct_frecuencia_pago_1,ti_us_ct_limite_1,ti_us_ct_peor_ciclo_mor_u12m_1,ti_us_ct_plazo_1,ti_us_ct_saldo_1,ti_us_ct_saldo_vencido_1,
			 ti_us_ct_score_1,ti_us_ct_score_id_1,ti_us_ct_tipo_prod_1,ti_us_cantidad_cuenta,
			 fecha_proceso)
			 values(vEmpresa,vTI_US_CUSTOMER_ID,vTI_US_ACCOUNT_ID,
			 vTI_US_USER_DEFINED_KEY_N_67,
			 vTI_US_USER_DEFINED_KEY_N_68,vTI_US_USER_DEFINED_KEY_N_69,vTI_US_USER_DEFINED_KEY_N_70,vTI_US_USER_DEFINED_KEY_N_71,vTI_US_USER_DEFINED_KEY_N_72,vTI_US_USER_DEFINED_KEY_N_73,vTI_US_USER_DEFINED_KEY_N_74,
			 vTI_US_USER_DEFINED_KEY_N_75,vTI_US_USER_DEFINED_KEY_N_76,vTI_US_USER_DEFINED_KEY_N_77,vTI_US_USER_DEFINED_KEY_N_78,vTI_US_USER_DEFINED_KEY_N_79,vTI_US_USER_DEFINED_KEY_N_80,vTI_US_USER_DEFINED_KEY_N_81,
			 vTI_US_USER_DEFINED_KEY_N_82,vTI_US_USER_DEFINED_KEY_N_83,vTI_US_USER_DEFINED_KEY_N_84,vTI_US_USER_DEFINED_KEY_N_85,vTI_US_USER_DEFINED_KEY_N_86,
			 --SEGUNDA PARTE
			 vTI_US_CT_CICLO_MOR_1,vTI_US_CT_CICLO_MOR_MES_ANT_1,vTI_US_CT_ID_1,
			 vTI_US_CT_TIPO_1,vTI_US_CT_FECHA_APERTURA_1,vTI_US_CT_FRECUENCIA_PAGO_1,vTI_US_CT_LIMITE_1,vTI_US_CT_PEOR_CICLO_MOR_U12M_1,vTI_US_CT_PLAZO_1,vTI_US_CT_SALDO_1,vTI_US_CT_SALDO_VENCIDO_1,vTI_US_CT_SCORE_1,vTI_US_CT_SCORE_ID_1,
			 vTI_US_CT_TIPO_PROD_1,vTI_US_CANTIDAD_CUENTA,
			 vFechahoy);
		commit;
		 

	END IF;
   
  
  	LET vTI_US_CUSTOMER_ID = '                    '; --20
	LET vTI_US_ACCOUNT_ID = '                    ';

	LET vTI_US_USER_DEFINED_KEY_N_67 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_68 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_69 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_70 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_71 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_72 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_73 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_74 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_75 = 0.0;
	LET vTI_US_USER_DEFINED_KEY_N_76 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_77 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_78 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_79 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_80 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_81 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_82 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_83 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_84 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_85 = 0;
	LET vTI_US_USER_DEFINED_KEY_N_86 = 0;
	--------------------------------------------------
	LET vTI_US_CANTIDAD_CUENTA 			= 0;
	LET vTI_US_CT_CICLO_MOR_1			= 0;
	LET vTI_US_CT_CICLO_MOR_MES_ANT_1 	= 0;
	LET vTI_US_CT_ID_1 					= '                    ';
	LET vTI_US_CT_TIPO_1 				= 0;
	LET vTI_US_CT_FECHA_APERTURA_1 		= DATE(1);
	LET vTI_US_CT_FRECUENCIA_PAGO_1 	= 0;
	LET vTI_US_CT_LIMITE_1 				= 0.0;
	LET vTI_US_CT_PEOR_CICLO_MOR_U12M_1 = 0;
	LET vTI_US_CT_PLAZO_1 				= 0;
	LET vTI_US_CT_SALDO_1 				= 0.0;
	LET vTI_US_CT_SALDO_VENCIDO_1 = '000000000';
	LET vTI_US_CT_SCORE_1 				= 0;	
	LET vTI_US_CT_SCORE_ID_1 			= 0;	
	LET vTI_US_CT_TIPO_PROD_1 			= 0;
	LET TI_US_CT_CICLO_MOR_2 = '0';
	LET TI_US_CT_CICLO_MOR_MES_ANT_2 = '0';
	LET TI_US_CT_ID_2 = '                    ';
	LET TI_US_CT_TIPO_2 = '000';
	LET TI_US_CT_FECHA_APERTURA_2 = '00000000';
	LET TI_US_CT_FRECUENCIA_PAGO_2 = '0';
	LET TI_US_CT_LIMITE_2 = '000000000';
	LET TI_US_CT_PEOR_CICLO_MOR_U12M_2 = '0';
	LET TI_US_CT_PLAZO_2 = '000';
	LET TI_US_CT_SALDO_2 = '000000000';
	LET TI_US_CT_SALDO_VENCIDO_2 = '000000000';
	LET TI_US_CT_SCORE_2 = '000000000';
	LET TI_US_CT_SCORE_ID_2 = '0000';
	LET TI_US_CT_TIPO_PROD_2 = '0';
	LET TI_US_CT_CICLO_MOR_3 = '0';
	LET TI_US_CT_CICLO_MOR_MES_ANT_3 = '0';
	LET TI_US_CT_ID_3 = '                    ';
	LET TI_US_CT_TIPO_3 = '000';
	LET TI_US_CT_FECHA_APERTURA_3 = '00000000';
	LET TI_US_CT_FRECUENCIA_PAGO_3 = '0';
	LET TI_US_CT_LIMITE_3 = '000000000';
	LET TI_US_CT_PEOR_CICLO_MOR_U12M_3 = '0';
	LET TI_US_CT_PLAZO_3 = '000';
	LET TI_US_CT_SALDO_3 = '000000000';
	LET TI_US_CT_SALDO_VENCIDO_3 = '000000000';
	LET TI_US_CT_SCORE_3 = '000000000';
	LET TI_US_CT_SCORE_ID_3 = '0000';
	LET TI_US_CT_TIPO_PROD_3 = '0';
	LET TI_US_CT_CICLO_MOR_4 = '0';
	LET TI_US_CT_CICLO_MOR_MES_ANT_4 = '0';
	LET TI_US_CT_ID_4 = '                    ';
	LET TI_US_CT_TIPO_4 = '000';
	LET TI_US_CT_FECHA_APERTURA_4 = '00000000';
	LET TI_US_CT_FRECUENCIA_PAGO_4 = '0';
	LET TI_US_CT_LIMITE_4 = '000000000';
	LET TI_US_CT_PEOR_CICLO_MOR_U12M_4 = '0';
	LET TI_US_CT_PLAZO_4 = '000';
	LET TI_US_CT_SALDO_4 = '000000000';
	LET TI_US_CT_SALDO_VENCIDO_4 = '000000000';
	LET TI_US_CT_SCORE_4 = '000000000';
	LET TI_US_CT_SCORE_ID_4 = '0000';
	LET TI_US_CT_TIPO_PROD_4 = '0';
	LET TI_US_CT_CICLO_MOR_5 = '0';
	LET TI_US_CT_CICLO_MOR_MES_ANT_5 = '0';
	LET TI_US_CT_ID_5 = '                    ';
	LET TI_US_CT_TIPO_5 = '000';
	LET TI_US_CT_FECHA_APERTURA_5 = '00000000';
	LET TI_US_CT_FRECUENCIA_PAGO_5 = '0';
	LET TI_US_CT_LIMITE_5 = '000000000';
	LET TI_US_CT_PEOR_CICLO_MOR_U12M_5 = '0';
	LET TI_US_CT_PLAZO_5 = '000';
	LET TI_US_CT_SALDO_5 = '000000000';
	LET TI_US_CT_SALDO_VENCIDO_5 = '000000000';
	LET TI_US_CT_SCORE_5 = '000000000';
	LET TI_US_CT_SCORE_ID_5 = '0000';
	LET TI_US_CT_TIPO_PROD_5 = '0';
	LET TI_US_CT_CICLO_MOR_6 = '0';
	LET TI_US_CT_CICLO_MOR_MES_ANT_6 = '0';
	LET TI_US_CT_ID_6 = '                    ';
	LET TI_US_CT_TIPO_6 = '000';
	LET TI_US_CT_FECHA_APERTURA_6 = '00000000';
	LET TI_US_CT_FRECUENCIA_PAGO_6 = '0';
	LET TI_US_CT_LIMITE_6 = '000000000';
	LET TI_US_CT_PEOR_CICLO_MOR_U12M_6 = '0';
	LET TI_US_CT_PLAZO_6 = '000';
	LET TI_US_CT_SALDO_6 = '000000000';
	LET TI_US_CT_SALDO_VENCIDO_6 = '000000000';
	LET TI_US_CT_SCORE_6 = '000000000';
	LET TI_US_CT_SCORE_ID_6 = '0000';
	LET TI_US_CT_TIPO_PROD_6 = '0';
	LET TI_US_CT_CICLO_MOR_7 = '0';
	LET TI_US_CT_CICLO_MOR_MES_ANT_7 = '0';
	LET TI_US_CT_ID_7 = '                    ';
	LET TI_US_CT_TIPO_7 = '000';
	LET TI_US_CT_FECHA_APERTURA_7 = '00000000';
	LET TI_US_CT_FRECUENCIA_PAGO_7 = '0';
	LET TI_US_CT_LIMITE_7 = '000000000';
	LET TI_US_CT_PEOR_CICLO_MOR_U12M_7 = '0';
	LET TI_US_CT_PLAZO_7 = '000';
	LET TI_US_CT_SALDO_7 = '000000000';
	LET TI_US_CT_SALDO_VENCIDO_7 = '000000000';
	LET TI_US_CT_SCORE_7 = '000000000';
	LET TI_US_CT_SCORE_ID_7 = '0000';
	LET TI_US_CT_TIPO_PROD_7 = '0';
	LET TI_US_CT_CICLO_MOR_8 = '0';
	LET TI_US_CT_CICLO_MOR_MES_ANT_8 = '0';
	LET TI_US_CT_ID_8 = '                    ';
	LET TI_US_CT_TIPO_8 = '000';
	LET TI_US_CT_FECHA_APERTURA_8 = '00000000';
	LET TI_US_CT_FRECUENCIA_PAGO_8 = '0';
	LET TI_US_CT_LIMITE_8 = '000000000';
	LET TI_US_CT_PEOR_CICLO_MOR_U12M_8 = '0';
	LET TI_US_CT_PLAZO_8 = '000';
	LET TI_US_CT_SALDO_8 = '000000000';
	LET TI_US_CT_SALDO_VENCIDO_8 = '000000000';
	LET TI_US_CT_SCORE_8 = '000000000';
	LET TI_US_CT_SCORE_ID_8 = '0000';
	LET TI_US_CT_TIPO_PROD_8 = '0';
	LET TI_US_CT_CICLO_MOR_9 = '0';
	LET TI_US_CT_CICLO_MOR_MES_ANT_9 = '0';
	LET TI_US_CT_ID_9 = '                    ';
	LET TI_US_CT_TIPO_9 = '000';
	LET TI_US_CT_FECHA_APERTURA_9 = '00000000';
	LET TI_US_CT_FRECUENCIA_PAGO_9 = '0';
	LET TI_US_CT_LIMITE_9 = '000000000';
	LET TI_US_CT_PEOR_CICLO_MOR_U12M_9 = '0';
	LET TI_US_CT_PLAZO_9 = '000';
	LET TI_US_CT_SALDO_9 = '000000000';
	LET TI_US_CT_SALDO_VENCIDO_9 = '000000000';
	LET TI_US_CT_SCORE_9 = '000000000';
	LET TI_US_CT_SCORE_ID_9 = '0000';
	LET TI_US_CT_TIPO_PROD_9 = '0';
	LET vTI_US_CT_CICLO_MOR_10 = '0';
	LET vTI_US_CT_CICLO_MOR_MES_ANT_10 = '0';
	LET vTI_US_CT_ID_10 = '                    ';
	LET vTI_US_CT_TIPO_10 = '000';
	LET vTI_US_CT_FECHA_APERTURA_10 = '00000000';
	LET vTI_US_CT_FRECUENCIA_PAGO_10 = '0';
	LET vTI_US_CT_LIMITE_10 = '000000000';
	LET vTI_US_CT_PEOR_CICLO_MOR_U12M_10 = '0';
	LET vTI_US_CT_PLAZO_10 = '000';
	LET vTI_US_CT_SALDO_10 = '000000000';
	LET vTI_US_CT_SALDO_VENCIDO_10 = '000000000';
	LET vTI_US_CT_SCORE_10 = '000000000';
	LET vTI_US_CT_SCORE_ID_10 = '0000';
	LET vTI_US_CT_TIPO_PROD_10 = '0';
	LET vTI_US_CT_CICLO_MOR_11 = '0';
	LET vTI_US_CT_CICLO_MOR_MES_ANT_11 = '0';
	LET vTI_US_CT_ID_11 = '                    ';
	LET vTI_US_CT_TIPO_11 = '000';
	LET vTI_US_CT_FECHA_APERTURA_11 = '00000000';
	LET vTI_US_CT_FRECUENCIA_PAGO_11 = '0';
	LET vTI_US_CT_LIMITE_11 = '000000000';
	LET vTI_US_CT_PEOR_CICLO_MOR_U12M_11 = '0';
	LET vTI_US_CT_PLAZO_11 = '000';
	LET vTI_US_CT_SALDO_11 = '000000000';
	LET vTI_US_CT_SALDO_VENCIDO_11 = '000000000';
	LET vTI_US_CT_SCORE_11 = '000000000';
	LET vTI_US_CT_SCORE_ID_11 = '0000';
	LET vTI_US_CT_TIPO_PROD_11 = '0';
	LET vTI_US_CT_CICLO_MOR_12 = '0';
	LET vTI_US_CT_CICLO_MOR_MES_ANT_12 = '0';
	LET vTI_US_CT_ID_12 = '                    ';
	LET vTI_US_CT_TIPO_12 = '000';
	LET vTI_US_CT_FECHA_APERTURA_12 = '00000000';
	LET vTI_US_CT_FRECUENCIA_PAGO_12 = '0';
	LET vTI_US_CT_LIMITE_12 = '000000000';
	LET vTI_US_CT_PEOR_CICLO_MOR_U12M_12 = '0';
	LET vTI_US_CT_PLAZO_12 = '000';
	LET vTI_US_CT_SALDO_12 = '000000000';
	LET vTI_US_CT_SALDO_VENCIDO_12 = '000000000';	
	LET vTI_US_CT_SCORE_12 = '000000000';
	LET vTI_US_CT_SCORE_ID_12 = '0000';
	LET vTI_US_CT_TIPO_PROD_12 = '0';
	
	LET cEmpresa_10 = '';
	LET iExisteCuenta = 0;
	
	LET iDiasTransUltConv = 0;
	LET iPlazo = 0;
    LET vMontoUltConvenio = 0;
	LET iDiasTransUltConv = 0;
    LET cFechaVctoConv1 = '';
	LET cFechaVctoConv2 = '';
	LET iActivo = 0; 
	LET iDiasRestConv = 0;
	
	--COMMIT WORK;
  
  END FOREACH

  begin;
       update bdicobranza:cb_param set valor = '1'
        where cod_param = '8';
  commit;
  
 let cContGral = iContGral;
 CALL bdicobranza:sp_inserta_bitacora_cob_2(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2;  
 --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2; 
 
 LET cMensaje = trim(cMensaje) || '. ' || trim(cContGral) || ' registros procesados.';
 
 
	
    ---RETURN cCodRet;
	RETURN cCodRet, trim(cMensaje);
	END
END PROCEDURE;