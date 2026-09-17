CREATE PROCEDURE "informix".sp_layout_in_triad_cob_mib(pEjecucion smallint)

RETURNING CHAR(6), char(80);
	
	-- VERSION: 1.0.11 20200611, 1.0.10 20190313
	DEFINE vDataErr				VARCHAR(64);
	DEFINE iSqlErr				INTEGER;
	DEFINE iSamErr				INTEGER;
	DEFINE cCodRet				CHAR(6);
	
	-- Este SP no genera archivo solo inserta en tabla. 
	DEFINE vNomarchivo  		CHAR(70); 
	DEFINE cRuta        		CHAR(20);
	
	DEFINE cMensaje     		CHAR(80);
	DEFINE iContGral         	INTEGER;
	DEFINE cProceso          	CHAR(4);
	DEFINE cCod_ret_2        	CHAR(6);
	DEFINE cContGral         	CHAR(10);

	DEFINE vEmpresa         	CHAR(3);
	DEFINE vEmpresa_2         	CHAR(3);
	DEFINE vFechahoy        	DATE;
	DEFINE vFechaDiaAnt			DATE;
	DEFINE vPriDiaMes      		DATE;
	DEFINE vUltDiaMes       	DATE;

	DEFINE vDiacorte         	SMALLINT;
	DEFINE vFechacorte      	DATE;
	DEFINE cFechacorte			CHAR(8);
	DEFINE vFechacorteant   	DATE;

	DEFINE iNumvencidosCob  	INTEGER;
	DEFINE iNumvencidosCobCH    INTEGER;
	DEFINE cNumvencidosCob		CHAR(2);
	DEFINE dMontoVencidoCob		DECIMAL(18,2);
	DEFINE dFechaUltMovCob		DATE;

	DEFINE iValidaP2P			INTEGER;
	DEFINE cValidaP2P			CHAR(2);
   
	DEFINE vTipo_prod        	CHAR(3);
	DEFINE cEmpresa_10		    CHAR(3);
	DEFINE iContUpd         	INTEGER;
	DEFINE iContIns         	INTEGER;
    DEFINE cCobro_anualidad     CHAR(1);
	
	-- VARIABLES DE HILOS
	DEFINE pNumCredIni			CHAR(20);
	DEFINE pNumCredFin			CHAR(20);
	DEFINE cred_ini				CHAR(20);
	DEFINE cred_fin				CHAR(20);

	DEFINE pNumCredIni_temp    CHAR(30);
	--DEFINE pNumCredFin_temp	   CHAR(20);
	DEFINE cred_ini_temp	   CHAR(30);
	--DEFINE cred_fin_temp	   CHAR(20);
	
	-- VARIABLES TRIAD
	DEFINE vTI_CO_ACCOUNT_ID  				CHAR(20);
	DEFINE vTI_CO_CUSTOMER_ID  				CHAR(20);
	DEFINE vTI_CO_PROD_TYPE  				INTEGER;
	DEFINE vTI_CO_PROD_CODE  				INTEGER;
	DEFINE vTI_CO_STATUS    				INTEGER;
	DEFINE vTI_CO_FULL_BAL_PAYMENT_IND  	INTEGER;
	DEFINE vTI_CO_TRANS_REVOLVE_IND  		INTEGER;
	DEFINE vTI_CO_TELEPHONE_IND  			INTEGER;
	DEFINE vTI_CO_ADDRESS_IND  				INTEGER;
	DEFINE vTI_CO_SMS_IND  					INTEGER;
	DEFINE vTI_CO_BLOCK_CODE  				INTEGER;
	DEFINE vTI_CO_LEGAL_CODE  				INTEGER;
	DEFINE TI_CO_DATE_OPEN  				DATE;
	DEFINE vTI_CO_DATE_BILLING_CYMD  		DATE;
	DEFINE vTI_CO_DATE_START_DELQ  			DATE;
	DEFINE vTI_CO_DATE_LAST_DEBIT  			DATE;
	DEFINE vTI_CO_DATE_LAST_CREDIT  		DATE;
	DEFINE vTI_CO_DATE_LAST_MON_TXN_CYM  	DATE;
	DEFINE vTI_CO_DATE_LAST_CASH_CYM  		DATE;
	DEFINE vTI_CO_DATE_LAST_DELQ_CYMD  		DATE;
	DEFINE vTI_CO_DATE_LAST_PUR_CYM  		DATE;
	DEFINE vTI_CO_DATE_FEE_CYM  			DATE;
	DEFINE vTI_CO_DATE_ORIGINAL_MATURITY  	DATE;
	DEFINE vTI_CO_DATE_CURRENT_MATURITY  	DATE;
	DEFINE vTI_CO_DATE_PROM_BRKN_CYMD  		DATE;
	DEFINE vTI_CO_BHVR_SCORE  				CHAR(8);
	DEFINE vTI_CO_BHVR_SCRD_ID  			CHAR(5);
	DEFINE vTI_CO_BAR_FACTOR  				CHAR(6);
	DEFINE vTI_CO_BALANCE  					DECIMAL(18,2);
	DEFINE vTI_CO_LIMIT  					DECIMAL(18,2);
	DEFINE vTI_CO_CASH_BALANCE  			DECIMAL(18,2);
	DEFINE vTI_CO_AMT_ARREARS  				DECIMAL(18,2);
	DEFINE vTI_CO_AMT_DISPUTE  				DECIMAL(18,2);
	DEFINE vTI_CO_AMT_LAST_CREDIT  			DECIMAL(18,2);
	DEFINE vTI_CO_HIGH_BALANCE_LF  			DECIMAL(18,2);
	DEFINE vTI_CO_NUM_PYMNTS_LF  			INTEGER;
	DEFINE vTI_CO_NUM_PTP  					INTEGER;
	DEFINE vTI_CO_MTHLY_BALANCE_1  			DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_DEBITS_1  			DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_CREDITS_1  			DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_BALANCE_2  			DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_DEBITS_2  			DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_CREDITS_2  			DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_BALANCE_3  			DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_DEBITS_3  			DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_CREDITS_3  			DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_BALANCE_4  			DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_DEBITS_4  			DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_CREDITS_4  			DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_BALANCE_5  			DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_DEBITS_5  			DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_CREDITS_5  			DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_BALANCE_6  			DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_DEBITS_6  			DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_CREDITS_6  			DECIMAL(18,2);
	DEFINE vTI_CO_DELQ_1  					INTEGER;
	DEFINE vTI_CO_MTHLY_INTEREST_1  		DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_FEES_1  			DECIMAL(18,2);
	DEFINE vTI_CO_DELQ_2  					INTEGER;
	DEFINE vTI_CO_MTHLY_INTEREST_2  		DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_FEES_2  			DECIMAL(18,2);
	DEFINE vTI_CO_DELQ_3  					INTEGER;
	DEFINE vTI_CO_MTHLY_INTEREST_3  		DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_FEES_3  			DECIMAL(18,2);
	DEFINE vTI_CO_DELQ_4  					INTEGER;
	DEFINE vTI_CO_MTHLY_INTEREST_4  		DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_FEES_4  			DECIMAL(18,2);
	DEFINE vTI_CO_DELQ_5  					INTEGER;
	DEFINE vTI_CO_MTHLY_INTEREST_5  		DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_FEES_5  			DECIMAL(18,2);
	DEFINE vTI_CO_DELQ_6  					INTEGER;
	DEFINE vTI_CO_MTHLY_INTEREST_6  		DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_FEES_6  			DECIMAL(18,2);
	DEFINE vTI_CO_DELQ_7  					INTEGER;
	DEFINE vTI_CO_MTHLY_INTEREST_7 			DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_FEES_7  			DECIMAL(18,2);
	DEFINE vTI_CO_DELQ_8  					INTEGER;
	DEFINE vTI_CO_MTHLY_INTEREST_8  		DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_FEES_8  			DECIMAL(18,2);
	DEFINE vTI_CO_DELQ_9 					INTEGER;
	DEFINE vTI_CO_MTHLY_INTEREST_9  		DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_FEES_9  			DECIMAL(18,2);
	DEFINE vTI_CO_DELQ_10					DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_INTEREST_10 		DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_FEES_10				DECIMAL(18,2);
	DEFINE vTI_CO_DELQ_11 					INTEGER;
	DEFINE vTI_CO_MTHLY_INTEREST_11  		DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_FEES_11 			DECIMAL(18,2);
	DEFINE vTI_CO_DELQ_12  					INTEGER;
	DEFINE vTI_CO_MTHLY_INTEREST_12  		DECIMAL(18,2);
	DEFINE vTI_CO_MTHLY_FEES_12 			DECIMAL(18,2);
	DEFINE vTI_CO_REMAINING_TERM  			INTEGER;
	DEFINE vTI_CO_ORIGINAL_LOAN_AMT  		DECIMAL(18,2);
	DEFINE vTI_CO_MANUAL_HANDLING_STATUS	INTEGER;
	DEFINE vTI_CO_CONTACT_MADE_IND 			INTEGER;
	DEFINE vTI_CO_USR_DF_COLL_AMT 			DECIMAL(18,2);
	DEFINE vTI_CO_USR_DF_WORSE_TRIGGER1  	INTEGER;
	DEFINE vTI_CO_USR_DF_WORSE_TRIGGER2		INTEGER;
	DEFINE vTI_CO_USR_DF_WORSE_TRIGGER3 	INTEGER;
	DEFINE vTI_CO_USR_DF_BETTER_TRIGGER1  	INTEGER;
	DEFINE vTI_CO_STGY_ID  					CHAR(4);
	DEFINE vTI_CO_SCEN_ID  					CHAR(5);
	DEFINE vTI_CO_ACTION_CTR  				CHAR(1);
	DEFINE vTI_CO_PTP  						INTEGER;
	DEFINE vTI_CO_DATE_BILL_EQV  			CHAR(8);
	DEFINE vTI_CO_DATE_FIRST_COLLS_DA  		CHAR(8);
	DEFINE vTI_CO_COLL_BALANCE_INITIAL  	CHAR(10);
	DEFINE vTI_CO_COLL_BALANCE_PREV  		CHAR(10);
	DEFINE vTI_CO_OOO_TYPE_PREV  			CHAR(1);
	DEFINE vTI_CO_DELQ_PREV  				CHAR(2);
	DEFINE vTI_CO_AMT_ARREARS_PREV  		CHAR(10);
	DEFINE vTI_CO_AMT_EXCESS_OVLM_PREV  	CHAR(10);
	DEFINE vTI_CO_BALANCE_PREV  			CHAR(10);
	DEFINE vTI_CO_LIMIT_PREV  				CHAR(10);
	DEFINE vTI_CO_PTP_PREV  				CHAR(1);
	DEFINE vTI_CO_TELEPHONE_IND_PREV  		CHAR(1);
	DEFINE vTI_CO_ADDRESS_IND_PREV  		CHAR(1);
	DEFINE vTI_CO_BLOCK_CODE_PREV  			CHAR(4);
	DEFINE vTI_CO_BLOCK_CODE_LAST_REVIEW  	CHAR(4);
	DEFINE vTI_CO_WORST_CYC_DELQ_PREV  		CHAR(2);
	DEFINE vTI_CO_TOTAL_OOO_AMT_PREV  		CHAR(10);

	--COBRANZA	
	DEFINE cNumCteCob				CHAR(20);
	DEFINE cNumCredCob 				CHAR(20);
	DEFINE cNumCredCobPrueba		CHAR(20);
	DEFINE cProductoCob				CHAR(4);
	DEFINE cStatusCob				CHAR(2);
	DEFINE cPlazoCob				CHAR(2);
	DEFINE iPlazoRestCob			INTEGER;
	DEFINE cPlazoRestCob			CHAR(2);
	DEFINE iPlazoCob				INTEGER;
	DEFINE iIdOrigen				INTEGER;
	DEFINE dIntMesCob				DECIMAL(18,2);
	DEFINE cSitCob		 			CHAR(3);
	DEFINE dFechaSitCob				DATE;
	DEFINE cFechaSitCob				CHAR(2);
	DEFINE iFinLlamadaCob			INTEGER;
	DEFINE cFinLlamadaCob           CHAR(2);
	DEFINE cSitCobNull				CHAR(2);
	DEFINE cCausaCobNull			CHAR(3);
	DEFINE cCausaCob				CHAR(3);
	DEFINE cStatusTelCob			CHAR(2);
	DEFINE cComportamientoCob		CHAR(2);
	DEFINE iValidaTelCob			INTEGER;
	DEFINE cValidaTelNull			CHAR(2);
	DEFINE iValidaDirCob			INTEGER;
	DEFINE cValidaDirCob			CHAR(2);
	DEFINE iValidaCelCob			INTEGER;
	DEFINE cBlockCode				CHAR(2);
	DEFINE cBlockCodeNull			CHAR(2);
	DEFINE cValidaCelCob			CHAR(2);
	DEFINE cValidaTelCob            CHAR(1);  
	DEFINE iValidaAclCob			INTEGER;
	DEFINE cValidaAclCob			CHAR(2);
	DEFINE dFechaAperturaCob		DATE;
	DEFINE dFechaVencOrigCob		DATE;
	DEFINE cFechaVencOrigCob		CHAR(8);
	DEFINE cFechaAperturaCob		CHAR(8);
	DEFINE cFechaFactCob			CHAR(8);
	DEFINE dFechaUltPagoCob			DATE;
	DEFINE cFechaUltPagoCob			CHAR(8);
	DEFINE dSaldoCapCob				DECIMAL(18,2);
	DEFINE cSaldoCapCob				CHAR(10);
	DEFINE cSaldoMorCob				CHAR(10);
	DEFINE dSaldoMorCob				DECIMAL(18,2);
	DEFINE cMontoAcl				CHAR(10);
	DEFINE dMontoAcl				DECIMAL(18,2);
	DEFINE dMontoUltPagoCob 		DECIMAL(18,2); 
	DEFINE cMontoUltPagoCob         CHAR(10);
	DEFINE cMontoUltPagoCobNull     CHAR(2);
	DEFINE dSumaMontoUltPagoCob		DECIMAL(18,2);
	DEFINE cSumaMontoUltPagoCob		CHAR(9);
	

	DEFINE iConvenio				INTEGER;
	DEFINE dSaldoMaxCob 			DECIMAL(18,2);
	DEFINE cSaldoMaxCob 			CHAR(10);
	DEFINE dFechaSdoMaxCob			DATE;
	DEFINE iNumPagos				INTEGER;
	DEFINE cFechaSdoMaxCob			CHAR(8);
	DEFINE dMontoOtorgadoCob		DECIMAL(18,2);
	DEFINE cMontoOtorgadoCob		CHAR(10);
	DEFINE cCashBalCob				CHAR(8);
	DEFINE dCashBalCob				DECIMAL(18,2);
	DEFINE iPagosRealizaCob 		INTEGER;
	DEFINE cPagosRealizaCob 		CHAR(2);
	DEFINE iNumConvenioHistCob		INTEGER;
	DEFINE cNumConvenioHistCob		CHAR(2);
	DEFINE dFechaUltimaCompraCob	DATE;
	DEFINE cFechaUltimaCompraCob	CHAR(2);
	DEFINE dFechaMoraCob			DATE; 
	DEFINE dFechaVencidoCob			DATE;
	DEFINE iPlazo					INTEGER;
	DEFINE cPlazo					CHAR(2);
	DEFINE dMontoUltConvenio		DECIMAL(18,2);
	DEFINE dMontoUltConvenio_2		DECIMAL(18,2);
	DEFINE cDiasTransUltConv		CHAR(8);
	DEFINE dFechaVctoConv1			DATE;
	DEFINE cFechaVctoConv1			CHAR(2);
	DEFINE iActivo					INTEGER;
	DEFINE cMontoUltConvenio		CHAR(8);
	DEFINE dMontoPagadoUltConvenio  DECIMAL(18,2);
	DEFINE dMontoPagadoUltConvenio_2 DECIMAL(18,2);
	DEFINE cMontoPagadoUltConvenio  CHAR(8);
	DEFINE cFechaVencidoCob			CHAR(8);
	DEFINE cFechaVencidoCob6		CHAR(8);
	DEFINE dProxFechaAnualidad		DATE;
	DEFINE cProxFechaAnualidad		CHAR(8);
	DEFINE cFechaDispVntCob 		CHAR(8);
	DEFINE cFechaDispAtmCob 		CHAR(8);
	DEFINE cFechaDispPosCob 		CHAR(8);
	DEFINE cFechaUltMovCob			CHAR(8);
	DEFINE cDispVntCob				CHAR(10); 
	DEFINE cDispAtmCob				CHAR(10);
	DEFINE cDispPosCob				CHAR(10);
	DEFINE dDispVntCob				DECIMAL(18,2);
	DEFINE dDispAtmCob				DECIMAL(18,2);
	DEFINE dDispPosCob				DECIMAL(18,2);
	DEFINE dCompraDispCta			DECIMAL(18,2);
	DEFINE cCompraDispCta			CHAR(8);
	DEFINE cCompraDispCtaNull		CHAR(2);
	DEFINE dFechaDispVntCob			DATE;
	DEFINE dMesUltMoraCob			DATE;
	DEFINE cMesUltMoraCob			CHAR(2);
	DEFINE dFechaDispPosCob			DATE;
	DEFINE dFechaDispAtmCob			DATE;
	DEFINE cMesMoraCob				CHAR(2);
	DEFINE dComisionCobCH			DECIMAL(18,2);
	DEFINE cComisionCob				CHAR(10);
	DEFINE cIntMesCob				CHAR(10);
	DEFINE cValEmailCob				CHAR(1);
	DEFINE iProfesion				INTEGER;
	
	--Pago Minimo
	DEFINE dSdoTotalLiq				DECIMAL(18,2);
	DEFINE cSdoTotalLiq      		CHAR(9);
	DEFINE dSdoTotalLiq_2    		DECIMAL(18,2);
	
	DEFINE dPagoMinimoCob			DECIMAL(18,2);
	DEFINE cPagoMinimoCob			CHAR(2);

	DEFINE dSdoTotalLiqCH			DECIMAL(18,2);
	DEFINE cSdoTotalLiqCH			CHAR(2);
	DEFINE cSaldoCapCobCH			CHAR(10);
	DEFINE dIntMesCobCH				DECIMAL(18,2);
	DEFINE dMontoPagosCH	  		DECIMAL(18,2);
	DEFINE cMontoPagos		  		char(8); 

	 --INDICADORES
	 ----------------------------------------------
	 DEFINE dMontoPagos1	  		DECIMAL(18,2);	
	 DEFINE dSdoTotalLiq1     		DECIMAL(18,2);
	 DEFINE cSdoTotalLiq1			CHAR(2);
	 DEFINE dCompraDispCta1	  		DECIMAL(18,2);
	 DEFINE cCompraDispCta1			CHAR(2);
	 DEFINE iMesMoraCob1			INTEGER;
	 DEFINE cMesMoraCob1			CHAR(2);
	 DEFINE dIntMesCob1				DECIMAL(18,2);
	 DEFINE cIntMesCob1				CHAR(2);
	 DEFINE dComisionCob1			DECIMAL(18,2);
	 DEFINE cComisionCob1			CHAR(2);
	 
	 
	 DEFINE dMontoPagos2	  		DECIMAL(18,2);	
	 DEFINE dSdoTotalLiq2     		DECIMAL(18,2);
	 DEFINE cSdoTotalLiq2			CHAR(2);
	 DEFINE dCompraDispCta2	  		DECIMAL(18,2);
	 DEFINE cCompraDispCta2			CHAR(2);
	 DEFINE iMesMoraCob2			INTEGER;
	 DEFINE cMesMoraCob2			CHAR(2);
	 DEFINE dIntMesCob2				DECIMAL(18,2);
	 DEFINE cIntMesCob2				CHAR(2);
	 DEFINE dComisionCob2			DECIMAL(18,2);
	 DEFINE cComisionCob2			CHAR(2);
	 
	 DEFINE dMontoPagos3	  		DECIMAL(18,2);	
	 DEFINE dSdoTotalLiq3     		DECIMAL(18,2);
	 DEFINE cSdoTotalLiq3			CHAR(2);
	 DEFINE dCompraDispCta3	  		DECIMAL(18,2);
	 DEFINE cCompraDispCta3			CHAR(2);
	 DEFINE iMesMoraCob3			INTEGER;
	 DEFINE cMesMoraCob3			CHAR(2);
	 DEFINE dIntMesCob3				DECIMAL(18,2);
	 DEFINE cIntMesCob3				CHAR(2);
	 DEFINE dComisionCob3			DECIMAL(18,2);
	 DEFINE cComisionCob3			CHAR(2);
	 
	 DEFINE dMontoPagos4	  		DECIMAL(18,2);	
	 DEFINE dSdoTotalLiq4     		DECIMAL(18,2);
	 DEFINE cSdoTotalLiq4			CHAR(2);
	 DEFINE dCompraDispCta4	  		DECIMAL(18,2);
	 DEFINE cCompraDispCta4			CHAR(2);
	 DEFINE iMesMoraCob4			INTEGER;
	 DEFINE cMesMoraCob4			CHAR(2);
	 DEFINE cIntMesCob4				CHAR(2);
	 DEFINE dIntMesCob4				DECIMAL(18,2);
	 DEFINE dComisionCob4			DECIMAL(18,2);
	 DEFINE cComisionCob4			CHAR(2);
	 
	 DEFINE dMontoPagos5	  		DECIMAL(18,2);	
	 DEFINE dSdoTotalLiq5     		DECIMAL(18,2);
	 DEFINE cSdoTotalLiq5			CHAR(2);
	 DEFINE dCompraDispCta5	  		DECIMAL(18,2);
	 DEFINE cCompraDispCta5			CHAR(2);
	 DEFINE iMesMoraCob5			INTEGER;
	 DEFINE cMesMoraCob5			CHAR(2);
	 DEFINE dIntMesCob5				DECIMAL(18,2);
	 DEFINE cIntMesCob5				CHAR(2);
	 DEFINE dComisionCob5			DECIMAL(18,2);
	 DEFINE cComisionCob5			CHAR(2);
	 ------
	 DEFINE iMesMoraCob6			INTEGER;
	 DEFINE cMesMoraCob6			CHAR(2);
	 DEFINE dIntMesCob6  		  	DECIMAL(18,2);
	 DEFINE cIntMesCob6				CHAR(2);
	 DEFINE dComisionCob6			DECIMAL(18,2);
	 DEFINE cComisionCob6			CHAR(2);
	 
	 DEFINE iMesMoraCob7			INTEGER;
	 DEFINE cMesMoraCob7			CHAR(2);
	 DEFINE dIntMesCob7  		  	DECIMAL(18,2);
	 DEFINE cIntMesCob7				CHAR(2);
	 DEFINE dComisionCob7			DECIMAL(18,2);
	 DEFINE cComisionCob7			CHAR(2);
	 
	 DEFINE iMesMoraCob8			INTEGER;
	 DEFINE cMesMoraCob8			CHAR(2);
	 DEFINE dIntMesCob8  		  	DECIMAL(18,2);
	 DEFINE cIntMesCob8				CHAR(2);
	 DEFINE dComisionCob8			DECIMAL(18,2);
	 DEFINE cComisionCob8			CHAR(2);
	 
	 DEFINE iMesMoraCob9			INTEGER;
	 DEFINE cMesMoraCob9			CHAR(2);
	 DEFINE dIntMesCob9  		  	DECIMAL(18,2);
	 DEFINE cIntMesCob9				CHAR(2);
	 DEFINE dComisionCob9			DECIMAL(18,2);
	 DEFINE cComisionCob9			CHAR(2);
	 
	 DEFINE iMesMoraCob10			INTEGER;
	 DEFINE cMesMoraCob10			CHAR(2);
	 DEFINE dIntMesCob10  		  	DECIMAL(18,2);
	 DEFINE cIntMesCob10			CHAR(2);
	 DEFINE dComisionCob10			DECIMAL(18,2);
	 DEFINE cComisionCob10			CHAR(2);
	 
	 DEFINE iMesMoraCob11			INTEGER;
	 DEFINE cMesMoraCob11			CHAR(2);
	 DEFINE dIntMesCob11  		  	DECIMAL(18,2);
	 DEFINE cIntMesCob11			CHAR(2);	
	 DEFINE dComisionCob11			DECIMAL(18,2);
	 DEFINE cComisionCob11			CHAR(2);
	 
	 DEFINE iExisteCuenta			INTEGER; 
	 define vNumCredito_salida      char(20);
	 
	 DEFINE dPagoMinimoCob_2        DECIMAL(18,2);
	 DEFINE	dMontoUltPagoCob_2      DECIMAL(18,2);
	 DEFINE	dSaldoMaxCob_2          DECIMAL(18,2);
	 DEFINE	iPagosRealizaCob_2      DECIMAL(18,2);
	 DEFINE	dSdoTotalLiqCH_2        DECIMAL(18,2);
	 DEFINE	dDispAtmCob_2           DECIMAL(18,2);
	 DEFINE	dDispVntCob_2           DECIMAL(18,2);
	 DEFINE	dDispPosCob_2           DECIMAL(18,2);
	 DEFINE	dMontoPagosCH_2         DECIMAL(18,2); 
	 DEFINE	iNumPagos_2             DECIMAL(18,2);
	 DEFINE	iNumvencidosCobCH_2     DECIMAL(18,2);
	 DEFINE	dIntMesCobCH_2          DECIMAL(18,2);
	 DEFINE	dComisionCobCH_2        DECIMAL(18,2);   
	 DEFINE v_out_cu_customer_id_temp char(20);
	 DEFINE iDia_corte              INTEGER;
     DEFINE dFechaCorte	            DATE;    
	 DEFINE dFechaIniMesPosterior   DATE;
	 
	DEFINE dFechahora_tel           DATE;   --REING
	DEFINE dfchalta_sitesp          DATE;
    DEFINE dFecha_hora_email        DATE;
	DEFINE cActualiza_tel           CHAR(1);
	DEFINE cActualiza_tel_2         CHAR(1);
    DEFINE cActualiza_email         CHAR(1);
    DEFINE cActualiza_sitesp        CHAR(1);
	DEFINE cActualiza_aclaracion    CHAR(1); 
    DEFINE cFecha_hora_email        CHAR(23);
	DEFINE vTI_CO_TELEPHONE_IND_actual INTEGER;
	DEFINE vTI_CO_STATUS_actual		INTEGER;
	DEFINE dFechahora_tel_2         DATE;
	DEFINE vTI_CO_SMS_IND_actual    INTEGER;
	DEFINE vTI_CO_MANUAL_HANDLING_STATUS_actual	INTEGER;
	DEFINE vVal_SdoInmaterial       DECIMAL(18,2);
	DEFINE vTI_CO_USR_DF_WORSE_TRIGGER1_actual 	INTEGER;
	DEFINE vTI_CO_LEGAL_CODE_actual INTEGER;
	----------------------------------------------
	
	-- PROCESOS
	DEFINE PR20_ALIGNED_SCORE			CHAR(8);
	DEFINE PR20_SCRD_ID					CHAR(5);
	DEFINE PR20_BAR_FACTOR_2			CHAR(9); -- Se copiara dicho campo y se eliminaran los ultimos 3 digitos, de tal manera que la longitud sea 6
	------
	DEFINE PR20_COLL_STGY_ID			CHAR(3);
	DEFINE PR20_COLL_SCEN_ID			CHAR(4);
	DEFINE PR20_COLL_ACTION_CTR			CHAR(1);
	DEFINE PR20_COLL_DATE_BILL_EQV 		CHAR(8); 
	DEFINE PR20_COLL_DATE_BILL_EQV2		CHAR(8);
	DEFINE PR20_COLL_BALANCE_INITIAL 	CHAR(10); 
	DEFINE PR20_COLL_BALANCE_ACTUAL 	CHAR(10); 
	DEFINE PR20_COLL_OOO_TYPE 			CHAR(1); 
	DEFINE PR20_COLL_CURR_DELQ 			CHAR(2);
	DEFINE PR20_COLL_AMT_ARREARS 		CHAR(10); 
	DEFINE PR20_COLL_AMT_EXCESS_OVLM 	CHAR(10); 
	DEFINE PR20_COLL_BALANCE 			CHAR(10); 
	DEFINE PR20_COLL_LIMIT 				CHAR(10);
	DEFINE PR20_COLL_PTP				CHAR(1);
	DEFINE PR20_COLL_TELEPHONE_IND 		CHAR(1); 
	DEFINE PR20_COLL_ADDRESS_IND 		CHAR(1); 
	DEFINE PR20_COLL_BLOCK_CODE 		CHAR(4); 
	DEFINE PR20_COLL_WORST_CYC_DELQ 	CHAR(2); 
	DEFINE PR20_COLL_TOTAL_OOO_AMT 		CHAR(10); 
	
	DEFINE cProfesion                   CHAR(3);
	DEFINE cProfesion_2                 CHAR(3);
	DEFINE iStatusTelCob                INTEGER;
	
   --INICIALIZACION DE VARIABLES--
	LET vDataErr		  = '';
	LET iSqlErr		  = 0;
	LET iSamErr		  = 0;
	LET cCodRet		  = "000000";
	
	--LET vNomarchivo   = 'Layout_in_triad.txt';
	LET vNomarchivo     = 'Bancoppel_Layout_in_Triad_Cob.txt';
	LET cRuta           = '/RESPALDOS/aacano/';
	
	LET cMensaje            = 'FIN DEL PROCESO CORRECTO';
	LET vTipo_prod          = '';
	LET iContGral           = 0; 
	LET cProceso            = '0111';	--No.PROCESO ASIGNADO
	LET cCod_ret_2          = ''; 
	LET cContGral           = '';
     
	LET vEmpresa      = '001';
	LET vFechahoy     = date(1);
	LET vFechaDiaAnt  = date(1);
	LET vPriDiaMes    = date(1);
	LET vUltDiaMes	  = DATE(1);

	LET vDiacorte           = 0;
	LET vFechacorte         = date(1);
	LET cFechacorte         = '';
	LET vFechacorteant      = date(1);

	LET iNumvencidosCob       = 0;
	LET iNumvencidosCobCH     = 0;
	LET cNumvencidosCob		  = '';
	LET dMontoVencidoCob	  = 0;
	LET dFechaUltMovCob		  = DATE (1);

	LET	iValidaP2P			  = 0;
	LET cValidaP2P			  = '00';
    LET cEmpresa_10           = '';
	LET iContUpd         	  = 0;
	LET iContIns         	  = 0;
	LET cCobro_anualidad      = '';
	
	-- VARIABLES DE HILOS
	 LET pNumCredIni		 ='';
	 LET pNumCredFin		 ='';
	 LET cred_ini			 ='';
	 LET cred_fin			 ='';
	 LET pNumCredIni_temp    ='';
	 --LET pNumCredFin_temp	 ='';
	 LET cred_ini_temp		 ='';
	 --LET cred_fin_temp			 ='';

	-- VARIABLES TRIAD
	LET vTI_CO_CUSTOMER_ID = '';
	LET vTI_CO_ACCOUNT_ID = '';
	LET vTI_CO_PROD_TYPE 				= 0;	
	LET vTI_CO_PROD_CODE 				= 0;
	LET vTI_CO_STATUS 					= 0;
	LET vTI_CO_FULL_BAL_PAYMENT_IND 	= 0;
	LET vTI_CO_TRANS_REVOLVE_IND 		= 0;
	LET vTI_CO_TELEPHONE_IND 			= 0;
	LET vTI_CO_ADDRESS_IND 				= 0;
	LET vTI_CO_SMS_IND 					= 0;
	LET vTI_CO_BLOCK_CODE 				= 0;
	LET vTI_CO_LEGAL_CODE 				= 0;
	LET TI_CO_DATE_OPEN 				= DATE(1);
	LET vTI_CO_DATE_BILLING_CYMD 		= DATE(1);
	LET vTI_CO_DATE_START_DELQ 			= DATE(1);
	LET vTI_CO_DATE_LAST_DEBIT 			= DATE(1);
	LET vTI_CO_DATE_LAST_CREDIT 		= DATE(1);
	LET vTI_CO_DATE_LAST_MON_TXN_CYM 	= DATE(1);
	LET vTI_CO_DATE_LAST_CASH_CYM 		= DATE(1);
	LET vTI_CO_DATE_LAST_DELQ_CYMD 		= DATE(1);
	LET vTI_CO_DATE_LAST_PUR_CYM 		= DATE(1);
	LET vTI_CO_DATE_FEE_CYM 			= DATE(1);
	LET vTI_CO_DATE_ORIGINAL_MATURITY 	= DATE(1);
	LET vTI_CO_DATE_CURRENT_MATURITY 	= DATE(1);
	LET vTI_CO_DATE_PROM_BRKN_CYMD 		= DATE(1);
	LET vTI_CO_BHVR_SCORE				= '+0000000';
	LET vTI_CO_BHVR_SCRD_ID 			= '+0000';
	LET vTI_CO_BAR_FACTOR 				= '+00000';
	LET vTI_CO_BALANCE 					= 0;
	LET vTI_CO_LIMIT 					= 0;
	LET vTI_CO_CASH_BALANCE 			= 0;
	LET vTI_CO_AMT_ARREARS 				= 0;
	LET vTI_CO_AMT_DISPUTE 				= 0;
	LET vTI_CO_AMT_LAST_CREDIT 			= 0;
	LET vTI_CO_HIGH_BALANCE_LF 			= 0;
	LET vTI_CO_NUM_PYMNTS_LF 			= 0;
	LET vTI_CO_NUM_PTP 					= 0;
	LET vTI_CO_MTHLY_BALANCE_1 			= 0;
	LET vTI_CO_MTHLY_DEBITS_1  			= 0;
	LET vTI_CO_MTHLY_CREDITS_1 			= 0;
	LET vTI_CO_MTHLY_BALANCE_2 			= 0;
	LET vTI_CO_MTHLY_DEBITS_2  			= 0;
	LET vTI_CO_MTHLY_CREDITS_2 			= 0;
	LET vTI_CO_MTHLY_BALANCE_3 			= 0;
	LET vTI_CO_MTHLY_DEBITS_3  			= 0;
	LET vTI_CO_MTHLY_CREDITS_3 			= 0;
	LET vTI_CO_MTHLY_BALANCE_4 			= 0;
	LET vTI_CO_MTHLY_DEBITS_4  			= 0;
	LET vTI_CO_MTHLY_CREDITS_4 			= 0;
	LET vTI_CO_MTHLY_BALANCE_5 			= 0;
	LET vTI_CO_MTHLY_DEBITS_5  			= 0;
	LET vTI_CO_MTHLY_CREDITS_5 			= 0;
	LET vTI_CO_MTHLY_BALANCE_6 			= 0;
	LET vTI_CO_MTHLY_DEBITS_6  			= 0;
	LET vTI_CO_MTHLY_CREDITS_6 			= 0;
	LET vTI_CO_DELQ_1 					= 0;
	LET vTI_CO_MTHLY_INTEREST_1 		= 0;
	LET vTI_CO_MTHLY_FEES_1 			= 0;
	LET vTI_CO_DELQ_2 					= 0;
	LET vTI_CO_MTHLY_INTEREST_2 		= 0;
	LET vTI_CO_MTHLY_FEES_2 			= 0;
	LET vTI_CO_DELQ_3 					= 0;
	LET vTI_CO_MTHLY_INTEREST_3 		= 0;
	LET vTI_CO_MTHLY_FEES_3 			= 0;
	LET vTI_CO_DELQ_4 					= 0;
	LET vTI_CO_MTHLY_INTEREST_4 		= 0;
	LET vTI_CO_MTHLY_FEES_4 			= 0;
	LET vTI_CO_DELQ_5					= 0;
	LET vTI_CO_MTHLY_INTEREST_5 		= 0;
	LET vTI_CO_MTHLY_FEES_5 			= 0;
	LET vTI_CO_DELQ_6 					= 0;
	LET vTI_CO_MTHLY_INTEREST_6 		= 0;
	LET vTI_CO_MTHLY_FEES_6 			= 0;
	LET vTI_CO_DELQ_7 					= 0;
	LET vTI_CO_MTHLY_INTEREST_7 		= 0;
	LET vTI_CO_MTHLY_FEES_7 			= 0;
	LET vTI_CO_DELQ_8 					= 0;
	LET vTI_CO_MTHLY_INTEREST_8 		= 0;
	LET vTI_CO_MTHLY_FEES_8 			= 0;
	LET vTI_CO_DELQ_9					= 0;
	LET vTI_CO_MTHLY_INTEREST_9 		= 0;
	LET vTI_CO_MTHLY_FEES_9 			= 0;
	LET vTI_CO_DELQ_10					= 0;
	LET vTI_CO_MTHLY_INTEREST_10		= 0;
	LET vTI_CO_MTHLY_FEES_10 			= 0;
	LET vTI_CO_DELQ_11 					= 0;
	LET vTI_CO_MTHLY_INTEREST_11 		= 0;
	LET vTI_CO_MTHLY_FEES_11 			= 0;
	LET vTI_CO_DELQ_12 					= 0;
	LET vTI_CO_MTHLY_INTEREST_12 		= 0;
	LET vTI_CO_MTHLY_FEES_12			= 0;
	LET vTI_CO_REMAINING_TERM 			= 0;
	LET vTI_CO_ORIGINAL_LOAN_AMT		= 0;
	LET vTI_CO_MANUAL_HANDLING_STATUS 	= 0;
	LET vTI_CO_CONTACT_MADE_IND 		= 0;
	LET vTI_CO_USR_DF_COLL_AMT 			= 0;
	LET vTI_CO_USR_DF_WORSE_TRIGGER1 	= 0;
	LET vTI_CO_USR_DF_WORSE_TRIGGER2	= 0;
	LET vTI_CO_USR_DF_WORSE_TRIGGER3 	= 0;
	LET vTI_CO_USR_DF_BETTER_TRIGGER1 	= 0;
	LET vTI_CO_STGY_ID 					= '+000';
	LET vTI_CO_SCEN_ID 					= '+0000';
	LET vTI_CO_ACTION_CTR 				= '0';
	LET vTI_CO_PTP 						= 0;
	LET vTI_CO_DATE_BILL_EQV 			= '00000000';
	LET vTI_CO_DATE_FIRST_COLLS_DA 		= '00000000';
	LET vTI_CO_COLL_BALANCE_INITIAL 	= '+000000000';
	LET vTI_CO_COLL_BALANCE_PREV 		= '+000000000';
	LET vTI_CO_OOO_TYPE_PREV 			= '0';
	LET vTI_CO_DELQ_PREV 				= '00';
	LET vTI_CO_AMT_ARREARS_PREV 		= '+000000000';
	LET vTI_CO_AMT_EXCESS_OVLM_PREV		= '+000000000';
	LET vTI_CO_BALANCE_PREV				= '+000000000';
	LET vTI_CO_LIMIT_PREV 				= '+000000000';
	LET vTI_CO_PTP_PREV					= '0';
	LET vTI_CO_TELEPHONE_IND_PREV 		= '0';
	LET vTI_CO_ADDRESS_IND_PREV			= '0';
	LET vTI_CO_BLOCK_CODE_PREV 			= '0000';
	LET vTI_CO_BLOCK_CODE_LAST_REVIEW 	= '0000';
	LET vTI_CO_WORST_CYC_DELQ_PREV 		= '00';
	LET vTI_CO_TOTAL_OOO_AMT_PREV 		= '+000000000';
	
	--------------------------------------------------------------------------------------------------------------------
	--COBRANZA		
	LET cNumCteCob				= '';
	LET cNumCredCob				= '';
	LET cNumCredCobPrueba		= '';
	LET cProductoCob			= '';
	LET cStatusCob				= '';
	LET cPlazoCob				= '';
	LET iPlazoRestCob			= 0;
	LET cPlazoRestCob			= '';
	LET iPlazoCob				= 0;
	LET iIdOrigen				= 0;
	LET dIntMesCob				= 0;
	LET cSitCob		 			= '';
	LET dFechaSitCob			= DATE(1);
	LET cFechaSitCob			= '';
	LET iFinLlamadaCob			= 0;
	LET cFinLlamadaCob          = '';
	LET cSitCobNull				= '';
	LET cCausaCobNull			= '';
	LET cComportamientoCob		= '';
	LET cStatusTelCob			= '';
	LET cCausaCob 				= '';
	LET iValidaTelCob			= 0;
	LET cValidaTelNull			= '';
	LET iValidaDirCob			= 0;
	LET cValidaDirCob			= '';
	LET iValidaCelCob			= 0;
	LET cBlockCode				= '';
	LET cBlockCodeNull			= '';
	LET cValidaCelCob			= '';
	LET cValidaTelCob           = ''; 
	LET iValidaAclCob			= 0;
	LET cValidaAclCob			= '';
	LET dFechaAperturaCob		= DATE(1);
	LET cFechaAperturaCob		= '00000000';
	LET dFechaVencOrigCob		= DATE(1);
	LET cFechaVencOrigCob		= '';
	LET cFechaFactCob			= '00000000';
	LET dFechaUltPagoCob		= DATE(1);
	LET cFechaUltPagoCob		= '';
	LET dSaldoCapCob			= 0;
	LET cSaldoCapCob			= '+000000000';
	LET cSaldoMorCob			= '+000000000';
	LET dSaldoMorCob			= 0;
	LET cMontoPagos				= '';
	LET dMontoUltPagoCob 		= 0; 
	LET cMontoUltPagoCob		= '';
	LET cMontoUltPagoCobNull    = '';
	LET dSumaMontoUltPagoCob	= 0;
	LET cSumaMontoUltPagoCob	= '';


	LET iConvenio				= 0;
	LET cMontoAcl				= '+000000000';
	LET dMontoAcl				= 0;
	LET dSaldoMaxCob 			= 0; 
	LET cSaldoMaxCob 			= '+000000000'; 
	LET dFechaSdoMaxCob			= DATE(1);
	LET iNumPagos				= 0;
	LET cFechaSdoMaxCob			= '';
	LET dMontoOtorgadoCob		= 0;
	LET cMontoOtorgadoCob		= '+000000000'; 
	LET cCashBalCob				= '';
	LET dCashBalCob				= 0;
	LET iPagosRealizaCob 		= 0;
	LET cPagosRealizaCob		= '';
	LET iNumConvenioHistCob		= 0;
	LET cNumConvenioHistCob		= '';
	LET dFechaUltimaCompraCob	= DATE(1);
	LET cFechaUltimaCompraCob	= '';
	LET dFechaMoraCob			= DATE(1); 
	LET dFechaVencidoCob		= DATE(1);
	LET iPlazo					= 0;
	LET cPlazo					= '';
	LET dMontoUltConvenio		= 0;
	LET dMontoUltConvenio_2     = 0;
	LET cDiasTransUltConv		= '';
	LET dFechaVctoConv1			= DATE(1);
	LET cFechaVctoConv1			= '';
	LET iActivo					= 0;
	LET cMontoUltConvenio		= ''; 
	LET dMontoPagadoUltConvenio = 0;
	LET dMontoPagadoUltConvenio_2 = 0;
	LET cMontoPagadoUltConvenio = '';
	LET cFechaVencidoCob		= '';
	LET cFechaVencidoCob6		= '';
	LET dProxFechaAnualidad		= DATE(1);
	LET cProxFechaAnualidad		= '';
	LET cFechaDispVntCob 		= '';
	LET cFechaDispAtmCob 		= '';
	LET cFechaDispPosCob 		= '';
	LET cFechaUltMovCob			= '00000000';
	LET dDispVntCob				= 0; 
	LET dDispAtmCob				= 0;
	LET dDispPosCob				= 0;
	LET dCompraDispCta          = 0;
	LET cCompraDispCta			= '';
	LET cCompraDispCtaNull		= '';
	LET cDispPosCob				= '';
	LET dMesUltMoraCob			= DATE(1); 
	LET cMesUltMoraCob			= '';
	LET dFechaDispVntCob		= DATE(1);
	LET dFechaDispPosCob		= DATE(1);
	LET dFechaDispAtmCob		= DATE(1);
	LET cMesMoraCob				= '00';
	LET dComisionCobCH			= 0;
	LET cComisionCob			= '+000000000';
	LET cIntMesCob				= '+000000000';
	LET cValEmailCob			= '1';
	LET iProfesion				= 0;
	
	--Pago Minimo
	LET dSdoTotalLiq			= 0;
	LET cSdoTotalLiq			= '';
	LET dSdoTotalLiq_2        	= 0;
	
	LET dPagoMinimoCob			= 0;
	LET cPagoMinimoCob			= '00';
	
	LET dSdoTotalLiqCH			= 0;
	LET cSdoTotalLiqCH			= '';
	LET cSaldoCapCobCH			= '';
	LET dIntMesCobCH			= 0;
	LET	dMontoPagosCH	  		= 0;
	LET cMontoPagos		  		= ''; 

	--INDICADORES
	LET dMontoPagos1	        = 0;
    LET dSdoTotalLiq1           = 0;
	LET dCompraDispCta1	  		= 0;
	LET iMesMoraCob1		  	= 0;
	LET cMesMoraCob1			= '';
	LET dIntMesCob1  		  	= 0;
	LET cIntMesCob1				= '';
	LET cComisionCob1			= '';
	
    LET dMontoPagos2	        = 0;
    LET dSdoTotalLiq2           = 0;
    LET dCompraDispCta2	  		= 0;
	LET iMesMoraCob2		  	= 0;
	LET cMesMoraCob2			= '';
	LET dIntMesCob2  		  	= 0;
	LET cIntMesCob2				= '';
	LET cComisionCob2			= '';
	
    LET dMontoPagos3	        = 0;
    LET dSdoTotalLiq3           = 0;
    LET dCompraDispCta3	  		= 0;
	LET iMesMoraCob3			= 0;
	LET cMesMoraCob3			= '';
	LET dIntMesCob3  		  	= 0;
	LET cIntMesCob3				= '';
	LET cComisionCob3			= '';
	
    LET dMontoPagos4	        = 0;
    LET dSdoTotalLiq4           = 0;
    LET dCompraDispCta4	  		= 0;
	LET iMesMoraCob4			= 0;
	LET cMesMoraCob4			= '';
	LET dIntMesCob4  		  	= 0;
	LET cIntMesCob4				= '';
	LET cComisionCob4			= '';
			
    LET dMontoPagos5	        = 0;
    LET dSdoTotalLiq5           = 0;
	LET dCompraDispCta5	  		= 0;
	LET iMesMoraCob5			= 0;
	LET cMesMoraCob5			= '';
	LET dIntMesCob5  		  	= 0;
	LET cIntMesCob5				= '';
	LET cComisionCob5			= '';
	
	LET iMesMoraCob6			= 0;
	LET cMesMoraCob6			= '';
	LET dIntMesCob6  		  	= 0;
	LET cIntMesCob6				= '';
	LET cComisionCob6			= '';
	
	LET iMesMoraCob7			= 0;
	LET cMesMoraCob7			= '';
	LET dIntMesCob7  		  	= 0;
	LET cIntMesCob7				= '';
	LET cComisionCob7			= '';
	
	LET iMesMoraCob8			= 0;
	LET cMesMoraCob8			= '';
	LET dIntMesCob8  		  	= 0;
	LET cIntMesCob8				= '';
	LET cComisionCob8			= '';
	
	LET iMesMoraCob9			= 0;
	LET cMesMoraCob9			= '';
	LET dIntMesCob9  		  	= 0;
	LET cIntMesCob9				= '';
	LET cComisionCob9			= '';
	
	LET iMesMoraCob10			= 0;
	LET cMesMoraCob10			= '';
	LET dIntMesCob10  		  	= 0;
	LET cIntMesCob10			= '';
	LET cComisionCob10			= '';
	
	LET iMesMoraCob11			= 0;
	LET cMesMoraCob11			= '';
	LET dIntMesCob11  		  	= 0;
	LET cIntMesCob11			= '';
	LET cComisionCob11			= '';
	
	LET iExisteCuenta			= 0;
	let vNumCredito_salida      = '';
	let vEmpresa_2              = '';
	
	LET dPagoMinimoCob_2        = 0;
	LET	dMontoUltPagoCob_2      = 0;
	LET	dSaldoMaxCob_2          = 0;
	LET	iPagosRealizaCob_2      = 0;
	LET	dSdoTotalLiqCH_2        = 0;
	LET	dDispAtmCob_2           = 0;
	LET	dDispVntCob_2           = 0; 
	LET	dDispPosCob_2           = 0;
	LET	dMontoPagosCH_2         = 0;
	LET	iNumPagos_2             = 0;
	LET	iNumvencidosCobCH_2     = 0;
	LET	dIntMesCobCH_2          = 0;
	LET	dComisionCobCH_2        = 0; 
	LET v_out_cu_customer_id_temp = '';
	LET iDia_corte              = 0;
	LET cSdoTotalLiq1           = '';
	LET cSdoTotalLiq3 = '';
	LET cCompraDispCta3 = '';
	LET cSdoTotalLiq4 = '';
	LET cCompraDispCta4 = '';
	LET cSdoTotalLiq5 = '';
	LET cCompraDispCta5 = '';
	LET ccompradispcta1 = '';
    LET cSdoTotalLiq2 = '';
    LET cCompraDispCta2 = '';
	
	LET dFechahora_tel           = DATE(1);  -- REING
	LET dfchalta_sitesp          = DATE(1);
    LET dFecha_hora_email        = DATE(1);
	LET cActualiza_tel           = '';
	LET cActualiza_tel_2         = '';
    LET cActualiza_email         = '';
    LET cActualiza_sitesp        = '';
	LET cActualiza_aclaracion    = '';
    LET cFecha_hora_email        = '';
	LET vTI_CO_TELEPHONE_IND_actual = 0;
	LET vTI_CO_STATUS_actual        = 0;
	LET dFechahora_tel_2            = DATE(1);
	LET vTI_CO_SMS_IND_actual       = 0;
	LET vTI_CO_MANUAL_HANDLING_STATUS_actual= 0;
	LET vVal_SdoInmaterial          = 0;
	LET vTI_CO_USR_DF_WORSE_TRIGGER1_actual = 0;
	LET vTI_CO_LEGAL_CODE_actual    = 0;
	----------------------------------------------	
	
	--PROCESOS
	LET PR20_ALIGNED_SCORE			= '+0000000';
	LET PR20_SCRD_ID				= '+0000';
	LET PR20_BAR_FACTOR_2			= '+00000000'; -- Se copiara dicho campo y se eliminaran los ultimos 3 digitos, de tal manera que la longitud sea 6
	---	
	LET PR20_COLL_STGY_ID 			= '000';
	LET	PR20_COLL_SCEN_ID 			= '+000'; 
	LET	PR20_COLL_ACTION_CTR 		= '0';
	LET PR20_COLL_DATE_BILL_EQV 	= '00000000';
	LET PR20_COLL_DATE_BILL_EQV2 	= '00000000';
	LET PR20_COLL_BALANCE_INITIAL 	= '+000000000';
	LET PR20_COLL_BALANCE_ACTUAL 	= '+000000000' ;
	LET PR20_COLL_OOO_TYPE 			= '0';
	LET PR20_COLL_CURR_DELQ 		= '00';
	LET PR20_COLL_AMT_ARREARS 		= '+000000000';
	LET PR20_COLL_AMT_EXCESS_OVLM 	= '+000000000';
	LET PR20_COLL_BALANCE 			= '+000000000';
	LET PR20_COLL_LIMIT 			= '+000000000';
	LET PR20_COLL_PTP 				= '0';
	LET PR20_COLL_TELEPHONE_IND 	= '0';
	LET PR20_COLL_ADDRESS_IND 		= '0';
	LET PR20_COLL_BLOCK_CODE 		= '0000';
	LET PR20_COLL_WORST_CYC_DELQ 	= '00';
	LET PR20_COLL_TOTAL_OOO_AMT 	= '+000000000';

	LET cProfesion                  = '';
	LET cProfesion_2                = '';
	LET iStatusTelCob               = 0;
	LET dFechaCorte	                = DATE(1);    
	LET dFechaIniMesPosterior       = DATE(1);
	-----------------------------------------------

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDataErr
        IF iSqlErr <> 0 THEN
            LET cCodRet=iSqlErr ;
			let cMensaje = pEjecucion || '-' || trim(cCodRet) || ' ' || cNumCredCob;
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '02') RETURNING cCod_ret_2;
			--CALL "informix".sp_inserta_bitacora_cob_2(vempresa, cProceso, cCodRet, cMensaje, '02') RETURNING cCod_ret_2;
			 
            RETURN cCodRet, trim(cMensaje);
        END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/descarga_info/aacano/triad_opt/concu/sp_layout_in_triad_cob.out";
	SET DEBUG FILE TO "/tmp/sp_layout_in_triad_cob.trc";
	TRACE ON;
   
    LET cMensaje = pEjecucion;
	--CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
	CALL bdicobranza:sp_inserta_bitacora_cob_2(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
	
	/*SELECT fecha_hoy,fecha_ant,pri_dia_mes,ult_dia_mes 
	    INTO vFechahoy, vFechaDiaAnt,vPriDiaMes,vUltDiaMes
	    FROM bdicred:sd_fechas WHERE empresa = vEmpresa; */
	
	
	  let vFechahoy = today -1;
	  let vFechaDiaAnt = today -2;
	
	
	--let vFechahoy = mdy('05','20','2020');               --TEST MACF
    --let vFechaDiaAnt =  date(vFechahoy - 1 units day);   --TEST MACF

	let iDia_corte = DAY(vFechahoy);
	
	
	--if iDia_corte = 18 or iDia_corte = 20 then
	--  let dFechaCorte = date(vFechahoy - 4 units day);
	--end if;
	
	IF pEjecucion IS NULL OR pEjecucion = '' THEN
		LET cCodRet     = "000005";
		LET cMensaje = "Parametro de proceso invalido";
		RETURN cCodRet, cMensaje;
	END IF;
	
	--  Se determina el rango de creditos 
	--SELECT SUBSTR(valor,1,12),SUBSTR(valor,14,25) INTO pNumCredIni,pNumCredFin		-- cod_param between '931' and '977'
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
	
	SELECT valor::decimal(18,2) into vVal_SdoInmaterial
	FROM bdicred:"informix".sd_param WHERE empresa = '001' AND cod_param='083';
	
	/* No es conveniente traer los 17 campos en la tabla temporal
		-- EN DÍA DE CORTE:  Pago mínimo > 0 (pendientes de pago)
			SELECT a.num_credito vNumCredito_2, a.numcte vTI_CU_CUSTOMER_ID_2, 'REV' vTipo_prod_2, a.num_producto, a.status_cred,  
			       d.dia_corte, a.fecha_apertura, d.prox_fecha_pago, a.fecha_vencim, a.plazo, a.id_origen, c.monto_otorgado,
				   c.sdo_capital, c.sdo_moratorio, c.fecha_ult_mov, d.prox_fecha_pago, d.fecha_vencto --(17) */
		 
		 SELECT a.numcte cNumCteCob_2, a.num_credito cNumCredCob_2, 'REV' vTipo_prod_2
		  FROM bdicred:sd_maecred a 
			   JOIN bdicred:sd_maesdos c ON c.empresa = a.empresa AND c.num_credito = a.num_credito
											AND c.monto_financiado > 0  -- PM MAYOR A CERO
			   JOIN bdicred:sd_maecredanexo d ON a.empresa = d.empresa AND a.num_credito = d.num_credito
		 WHERE a.num_producto <> '7800'   
		   AND a.num_credito >= pNumCredIni AND a.num_credito < pNumCredFin  
		   AND a.status_cred = 'AA'
		   AND d.dia_corte = iDia_corte 
		   AND a.num_credito NOT IN(SELECT ti_co_account_id from bdicobranza:cb_triad_cobranza WHERE fecha_proceso = vFechahoy)
		 INTO TEMP paso_cob WITH NO LOG;
		
		create unique index inx_paso_cob on paso_cob(cNumCredCob_2);
		update statistics medium for table paso_cob;

		  
		-- DIARIO: TODAS LAS CUENTAS VENCIDAS
        INSERT INTO paso_cob		
		SELECT a.numcte, a.num_credito, 'REV'
		  FROM bdicred:sd_maecred a
               JOIN bdicred:sd_maecredanexo d ON a.empresa = d.empresa AND a.num_credito = d.num_credito
		 WHERE a.num_producto <> '7800' AND a.status_cred in('BA','BT') --VENCIDOS
		   AND a.num_credito >= pNumCredIni AND a.num_credito < pNumCredFin
		   AND a.num_credito NOT IN(SELECT cNumCredCob_2 from paso_cob)
		   AND a.num_credito NOT IN(SELECT ti_co_account_id from bdicobranza:cb_triad_cobranza WHERE fecha_proceso = vFechahoy);


	    -- DIARIO: CUENTAS VIGENTES, VALIDA CAMPO DE ARCHIVO SALIDA: OUT_CO_ACCOUNT_ID		
		insert into paso_cob 
		SELECT a.num_credito, a.numcte, 'REV'
		  FROM bdicred:sd_maecred a 
			   JOIN bdicred:sd_maecredanexo d ON d.empresa = a.empresa AND d.num_credito = a.num_credito 
			   JOIN bdicobranza:cb_triad_salida f ON f.num_credito = a.num_credito 
		 WHERE a.num_producto <> '7800' AND a.status_cred = 'AA' --VIGENTES 
		   AND a.num_credito NOT IN(SELECT cNumCredCob_2 from paso_cob)
		   AND a.num_credito NOT IN(SELECT ti_co_account_id from bdicobranza:cb_triad_cobranza WHERE fecha_proceso = vFechahoy)
		   AND a.num_credito >= pNumCredIni AND a.num_credito < pNumCredFin 
		   AND d.prox_fecha_pago+f.out_coll_next_call_days = vFechahoy;  --VIGENTES EN EL CAMPO OUT-COLL-NEXT-CALL-DAYS*

		-- DIARIO 2:  VIGENTES PAGO UN DIA ANTERIOR
		---  Y que la fecha de proceso no sea el dia de corte, siempre y cuando debía algo el mes anterior (monto_financiado en la sd_maesdoshist), 
		---dejar al final para que sean los menos créditos	, despues de la cons a cb_triad_salida	
		insert into paso_cob 
		SELECT a.num_credito, a.numcte, 'REV'
		  FROM bdicred:sd_maecred a
		       JOIN bdicred:sd_maecredanexo d ON d.empresa = a.empresa AND d.num_credito = a.num_credito AND d.fecha_ult_pago = vFechaDiaAnt --PAGO UN DIA ANTERIOR
		       JOIN bdicred:sd_maesdoshist e ON e.empresa = a.empresa AND e.num_credito = a.num_credito 
			                                    AND e.fecha = (mdy(month(vFechahoy),d.dia_corte,year(vFechahoy)) -1 units month)
												AND (e.monto_vencido+e.mto_venc_trasp) > 0
		 WHERE a.num_producto <> '7800' AND a.status_cred = 'AA' --VIGENTES
		   AND a.num_credito NOT IN(SELECT cNumCredCob_2 from paso_cob)
		   AND a.num_credito NOT IN(SELECT ti_co_account_id from bdicobranza:cb_triad_cobranza WHERE fecha_proceso = vFechahoy)
		   AND a.num_credito >= pNumCredIni AND a.num_credito  < pNumCredFin;
		   
		----  montovencido  mtovenctrasp  = 0  no es elegible  > 0 es elegible,, ya no es necesario validar el monto  financiado
		---- Iniciaron corte con monto a pagar
	    
        ---------------------------    OLD
		/*if iDia_corte = 18 or iDia_corte = 20 then
		
		--CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '02') RETURNING cCod_ret_2;
	
		-- 3 CORTE:  SALDO MAYOR A CERO
		SELECT a.numcte cNumCteCob_2, a.num_credito cNumCredCob_2, 'REV' vTipo_prod_2
		  FROM bdicred:sd_maecred a 
			   JOIN bdicred:sd_maesdos c ON c.empresa = a.empresa AND c.num_credito = a.num_credito AND c.sdo_cap_insoluto > 0  --SALDO MAYOR A CERO
		 WHERE a.num_producto <> '7800'   
		   --AND a.num_credito not in (select cNumCredCob_2 from paso_cob)
		   AND a.num_credito >= pNumCredIni AND a.num_credito < pNumCredFin
		   AND a.status_cred in('AA','BA','BT')
	     INTO TEMP paso_cob WITH NO LOG;
		
		-- 4: DIARIO/CORTE	 VIGENTES	VALIDA CAMPO DE ARCHIVO SALIDA: OUT_CO_ACCOUNT_ID		
		insert into paso_cob 
		SELECT a.numcte, a.num_credito, 'REV' 
		  FROM bdicred:sd_maecred a 
			   JOIN bdicred:sd_maecredanexo d ON d.empresa = a.empresa AND d.num_credito = a.num_credito 
			   --JOIN bdicobranza:cb_triad_salida f ON f.out_co_account_id='00000000'||a.num_credito 
			   JOIN bdicobranza:cb_triad_salida f ON f.num_credito = a.num_credito 
		 WHERE a.num_producto <> '7800' AND a.status_cred = 'AA' --VIGENTES 
		   AND a.num_credito not in (select cNumCredCob_2 from paso_cob)
		   AND a.num_credito >= pNumCredIni AND a.num_credito < pNumCredFin 
		   AND d.prox_fecha_pago+f.out_coll_next_call_days = vFechahoy;  --VIGENTES EN EL CAMPO OUT-COLL-NEXT-CALL-DAYS*
		   
		ELSE
	
		-- 1 DIARIO: VENCIDOS 
		SELECT a.numcte cNumCteCob_2, a.num_credito cNumCredCob_2, 'REV' vTipo_prod_2
		  FROM bdicred:sd_maecred a 
		 WHERE a.num_producto <> '7800' AND a.status_cred in('BA','BT') --VENCIDOS
		   AND a.num_credito >= pNumCredIni AND a.num_credito < pNumCredFin  
			INTO TEMP paso_cob WITH NO LOG;
		
        create unique index inx_paso_cob on paso_cob(cNumCredCob_2);
		update statistics medium for table paso_cob;
		
		-- 2 DIARIO:  VIGENTES PAGO UN DIA ANTERIOR   
		insert into paso_cob 
		SELECT a.numcte, a.num_credito, 'REV' 
		  FROM bdicred:sd_maecred a
		  JOIN bdicred:sd_maecredanexo d ON d.empresa = a.empresa AND d.num_credito = a.num_credito AND d.fecha_ult_pago = vFechaDiaAnt --PAGO UN DIA ANTERIOR
		 WHERE a.num_producto <> '7800' AND a.status_cred = 'AA' --VIGENTES
		   AND a.num_credito not in (select cNumCredCob_2 from paso_cob)
		   AND a.num_credito >= pNumCredIni AND a.num_credito  < pNumCredFin;


		-- 4: DIARIO/CORTE	 VIGENTES	VALIDA CAMPO DE ARCHIVO SALIDA: OUT_CO_ACCOUNT_ID		
		insert into paso_cob 
		SELECT a.numcte, a.num_credito, 'REV' 
		  FROM bdicred:sd_maecred a 
			   JOIN bdicred:sd_maecredanexo d ON d.empresa = a.empresa AND d.num_credito = a.num_credito 
			   --JOIN bdicobranza:cb_triad_salida f ON f.out_co_account_id='00000000'||a.num_credito 
			   JOIN bdicobranza:cb_triad_salida f ON f.num_credito = a.num_credito 
		 WHERE a.num_producto <> '7800' AND a.status_cred = 'AA' --VIGENTES 
		   AND a.num_credito not in (select cNumCredCob_2 from paso_cob)
		   AND a.num_credito >= pNumCredIni AND a.num_credito < pNumCredFin 
		   AND d.prox_fecha_pago+f.out_coll_next_call_days = vFechahoy;  --VIGENTES EN EL CAMPO OUT-COLL-NEXT-CALL-DAYS*
		
		
		end if;

		*/
		-- 1: CUENTAS A PLAZO: DIARIO/CORTE	 VENCIDOS
		insert into paso_cob  
		SELECT b.numcte, b.num_credito, 'CRD'
		  FROM bdicred:sd_maecredcrd b
		 WHERE b.num_producto <> '6800'  --in('6011','6300','7600','7700','6400') 
		   AND b.status_cred in('BA','BT','VP')	--VENCIDOS
		   AND b.num_credito >= cred_ini AND b.num_credito  < cred_fin;
		
		
		-- 2: CUENTAS A PLAZO: DIARIO/CORTE	VIGENTES PAGO UN DIA ANTERIOR
		insert into paso_cob
		SELECT b.numcte, b.num_credito, 'CRD' 
		  FROM bdicred:sd_maecredcrd b
		  JOIN bdicred:sd_maecredanexocrd d ON d.empresa = b.empresa AND d.num_credito = b.num_credito AND d.fecha_ult_pago = vFechaDiaAnt 
		 WHERE b.num_producto <> '6800' 
		   AND b.status_cred = 'AA'
		   AND b.num_credito not in (select cNumCredCob_2 from paso_cob)
		   AND b.num_credito NOT IN(SELECT ti_co_account_id from bdicobranza:cb_triad_cobranza WHERE fecha_proceso = vFechahoy)
		   AND b.num_credito >= cred_ini AND b.num_credito  < cred_fin;		
		
		-- 3: CUENTAS A PLAZO: CORTE  (Saldo > 0)
		insert into paso_cob
		SELECT b.numcte, b.num_credito, 'CRD' 
		  FROM bdicred:sd_maecredcrd b
		  JOIN bdicred:sd_maesdoscrd c ON c.num_credito = b.num_credito AND c.sdo_cap_insoluto>0
		  --JOIN bdicred:sd_maecredanexocrd d ON d.empresa = b.empresa AND d.num_credito = b.num_credito AND d.dia_corte = iDia_corte --FECHA DE CORTE
		  JOIN bdicred:sd_maecredanexocrd d ON d.empresa = b.empresa AND d.num_credito = b.num_credito AND d.prox_fecha_pago = vFechahoy --FECHA DE CORTE
		WHERE b.num_producto <> '6800' 
		  AND b.status_cred = 'AA'
		  AND b.num_credito not in (select cNumCredCob_2 from paso_cob)
		  AND b.num_credito NOT IN(SELECT ti_co_account_id from bdicobranza:cb_triad_cobranza WHERE fecha_proceso = vFechahoy)
		  AND b.num_credito >= cred_ini AND b.num_credito  < cred_fin;		
		

		-- 4: CUENTAS PLAZO: DIARIO/CORTE	|	VALIDA CAMPO DE ARCHIVO SALIDA: OUT_CO_ACCOUNT_ID
		insert into paso_cob
		SELECT b.numcte, b.num_credito, 'CRD'
		  FROM bdicred:sd_maecredcrd b
		  JOIN bdicred:sd_maecredanexocrd d ON d.empresa = b.empresa AND d.num_credito = b.num_credito 
		  --JOIN bdicobranza:cb_triad_salida f ON f.out_co_account_id='00000000'||b.num_credito 
		  JOIN bdicobranza:cb_triad_salida f ON f.num_credito = b.num_credito 
		 WHERE b.num_producto <> '6800' 
		   AND b.status_cred = 'AA'
		   AND b.num_credito not in (select cNumCredCob_2 from paso_cob)
		   AND b.num_credito NOT IN(SELECT ti_co_account_id from bdicobranza:cb_triad_cobranza WHERE fecha_proceso = vFechahoy)
		   AND b.num_credito >= cred_ini AND b.num_credito  < cred_fin 
		   AND d.prox_fecha_pago+f.out_coll_next_call_days = vFechahoy; --VIGENTES EN EL CAMPO OUT-COLL-NEXT-CALL-DAYS*		

         update statistics medium for table paso_cob;			

        /*
		SELECT limit 1 empresa into vEmpresa_2
		FROM bdicobranza:cb_triad_cobranza 
		WHERE ti_co_account_id >= '600000000001' AND fecha_proceso = vFechahoy;
		
		IF nvl(vEmpresa_2,'') <> '' then
			begin;
			  delete from paso_cob
			  where cNumCredCob_2 in (SELECT ti_co_account_id from bdicobranza:cb_triad_cobranza WHERE ti_co_account_id >= '600000000001' and fecha_proceso = vFechahoy);
			commit;
		END IF;
		*/
		begin; 
          delete from paso_cob
          where cNumCredCob_2 in (SELECT num_credito FROM bdicred:sd_inactivos_12meses WHERE num_credito > '600000000001');
		commit;

        update statistics medium for table paso_cob;

		
	FOREACH WITH HOLD
	    SELECT a.cNumCteCob_2, a.cNumCredCob_2, a.vTipo_prod_2
		  INTO cNumCteCob, cNumCredCob, vTipo_prod
	      FROM paso_cob a
		 
		 
		IF vTipo_prod = 'REV' THEN
		
		   SELECT a.num_producto, a.status_cred, a.fecha_apertura, a.fecha_vencim, a.plazo, a.id_origen,
		          b.monto_otorgado, b.sdo_capital, b.sdo_moratorio, b.fecha_ult_mov,
				  c.dia_corte, c.prox_fecha_pago, c.fecha_vencto
		     INTO cProductoCob, cStatusCob, dFechaAperturaCob, dFechaVencOrigCob, iPlazoCob, iIdOrigen,
			      dMontoOtorgadoCob, dSaldoCapCob, dSaldoMorCob, dFechaUltMovCob,
				  vDiacorte, vFechacorte, dFechaVencidoCob
		     FROM bdicred:sd_maecred a, bdicred:sd_maesdos b, bdicred:sd_maecredanexo c 
		    WHERE a.num_credito = b.num_credito and a.num_credito = c.num_credito  
		      AND a.num_credito = cNumCredCob;
	
		ELSE
		
		    SELECT a.num_producto, a.status_cred, a.fecha_apertura, a.fecha_vencim, a.plazo, a.id_origen,
		           b.monto_otorgado, b.sdo_capital, b.sdo_moratorio, b.fecha_ult_mov,
				   c.dia_corte, c.prox_fecha_pago, c.fecha_vencto
			  INTO cProductoCob, cStatusCob, dFechaAperturaCob, dFechaVencOrigCob, iPlazoCob, iIdOrigen,
			       dMontoOtorgadoCob, dSaldoCapCob, dSaldoMorCob, dFechaUltMovCob,
				   vDiacorte, vFechacorte, dFechaVencidoCob
		      FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c  
		     WHERE a.num_credito = b.num_credito and a.num_credito = c.num_credito
			   AND a.num_credito = cNumCredCob;
		
		END IF;
		
		LET iContGral = iContGral + 1;	
		
		--FECHA DE CORTE: 
		IF nvl(vFechacorte,'') = '' THEN 
			--IF vDiacorte <= 0 THEN CONTINUE foreach; END IF;
			LET vFechacorte = vFechahoy;
			LET vDiacorte	= DAY(vFechahoy);
		END IF;	


		IF vDiacorte = '1' AND vFechacorte =  mdy(month(vFechahoy),'2',year(vFechahoy))THEN 
			LET cFechacorte = TO_CHAR(vFechacorte,'%Y%m%d');
		ELSE
			IF day(vFechahoy) <= vDiacorte THEN 					
					LET cFechacorte = TO_CHAR(vFechacorte,'%Y%m%d');
			ELSE 
				LET vFechacorte =  bdicred:monthadd(vFechacorte,-1);				
				LET cFechacorte = TO_CHAR(vFechacorte,'%Y%m%d');
				END IF;
		END IF;	
		
		LET vFechacorteant =  bdicred:monthadd(vFechacorte,-1);
		
		--ti_co_customer_id
		LET vTI_CO_CUSTOMER_ID = trim(cNumCteCob);
		
		--TI-CO-ACCOUNT-ID:Identificador unico de cuenta
		LET vTI_CO_ACCOUNT_ID = trim(cNumCredCob);		
		
		
		SELECT empresa, TI_CO_TELEPHONE_IND, TI_CO_STATUS, TI_CO_SMS_IND, TI_CO_MANUAL_HANDLING_STATUS, TI_CO_USR_DF_WORSE_TRIGGER1,
               TI_CO_LEGAL_CODE		
		  INTO cEmpresa_10, vTI_CO_TELEPHONE_IND_actual, vTI_CO_STATUS_actual, vTI_CO_SMS_IND_actual, vTI_CO_MANUAL_HANDLING_STATUS_actual,
		  vTI_CO_USR_DF_WORSE_TRIGGER1_actual, vTI_CO_LEGAL_CODE_actual
		  FROM bdicobranza:cb_triad_cobranza
		 WHERE ti_co_account_id = vTI_CO_ACCOUNT_ID;
		
		IF NVL(cEmpresa_10,'') <> '' THEN  let iExisteCuenta = 1; END IF;
		
		
		--TI-CO-PROD-TYPE: "3: tarjeta 5: prestamo"
		IF cProductoCob IN ('6001','8100','7000','6600') THEN
			LET vTI_CO_PROD_TYPE = 3;
		END IF;
		
		IF cProductoCob IN ('6300','7600','7700','6400','6011') THEN
			LET vTI_CO_PROD_TYPE = 5;
		END IF;

		--TI-CO-PROD-CODE: Poner el mismo valor que TI-RV-ACCOUNT-TYPE o TI-LN-ACCOUNT-TYPE. 
		--1:Prestamo 		|	 TDC Visa
		IF cProductoCob IN ('6300','7600','7700','6001') 	THEN  	LET vTI_CO_PROD_CODE = 1; END IF;
		--2: Nomina			|	 TDC Oro
		IF cProductoCob IN ('6400','8100') 					THEN 	LET vTI_CO_PROD_CODE = 2; END IF;
		--3: Reestructura	|	 TDC Platino
		IF cProductoCob IN ('6011','7000') 					THEN 	LET vTI_CO_PROD_CODE = 3; END IF;
		--4: TDC Basica: Se agreaga aunque no viene en el requerimiento.
		IF cProductoCob IN ('6600') 						THEN 	LET vTI_CO_PROD_CODE = 4; END IF;
	
	    --TI-CO-MANUAL-HANDLING-STATUS: Identificador de situacion especial:
		--0 - No tiene alguna marca de situacion especial HOY.	|	1 - Tiene alguna marca de situacion especial HOY.	|	2 - Se quita la situacion especial HOY.
		--SELECT MAX(fchalta) INTO dFechaSitCob FROM bdisitesp:"informix".se_ctessitespcred WHERE empresa = vEmpresa AND numcte = cNumCredCob;
		/* --esto erróneo, debe ser de la tabla se_ctessitespcte
		  SELECT MAX(fchalta) INTO dFechaSitCob 
		  FROM bdisitesp:"informix".se_ctessitespcred 
		 WHERE numcte = cNumCteCob; 
		
		IF nvl(dFechaSitCob,'') = '' then
			LET vTI_CO_MANUAL_HANDLING_STATUS = 0;
		elif dFechaSitCob >= vFechahoy then
			LET vTI_CO_MANUAL_HANDLING_STATUS = 1;
		ELSE
			LET vTI_CO_MANUAL_HANDLING_STATUS = 2;
		END IF;
		*/
		
		IF iExisteCuenta >0 THEN
	       -- Si cuenta existe se validarán si cambiaron los datos que se podrían actualizar diario
		   
		   select limit  1 date(fecha_hora) into dFechahora_tel
			  from bdinteg:si_telefonos_actual 
			 where numcte = cNumCteCob 
			   and tipo_tel = '1';
			
			
			if NVL(dFechahora_tel,'') <> '' then
				if dFechahora_tel >= vFechahoy THEN
					LET vTI_CO_TELEPHONE_IND = 1; 
					LET cActualiza_tel = 'S';
				ELSE
					LET vTI_CO_TELEPHONE_IND = 0; 
					LET vTI_CO_STATUS = 5;
				END IF;
			ELSE
				LET vTI_CO_TELEPHONE_IND = vTI_CO_TELEPHONE_IND_actual;
				LET vTI_CO_STATUS = vTI_CO_STATUS_actual;
			END IF;
	         
			select limit  1 date(fecha_hora) into dFechahora_tel_2
			  from bdinteg:si_telefonos_actual 
			 where numcte = cNumCteCob 
			   and tipo_tel = '2';
			
			if NVL(dFechahora_tel_2,'') <> '' then
				if dFechahora_tel_2 >= vFechahoy THEN
					LET vTI_CO_SMS_IND = 1; 
					LET cActualiza_tel_2 = 'S';
				ELSE
					LET vTI_CO_SMS_IND = 0;
				END IF;
			ELSE
				LET vTI_CO_SMS_IND = vTI_CO_SMS_IND_actual;
			END IF;

			
          select limit 1 date(fchalta), situacion,causa into dfchalta_sitesp, cSitCob,cCausaCob
			from bdisitesp:se_ctessitespcte
		   where numcte = cNumCteCob;
			-- and situacion = 'F'
			-- and causa in(42,43,101,102,107);
		    
			LET cSitCob = nvl(cSitCob,'');
			LET cCausaCob = nvl(cCausaCob,0);
		   
			if NVL(dfchalta_sitesp,'') <> '' then
				if dfchalta_sitesp >= vFechahoy then
					LET vTI_CO_MANUAL_HANDLING_STATUS = 1;
					LET cActualiza_sitesp = 'S';
					
					IF(cSitCob = 'F' AND cCausaCob = '42') OR (cSitCob = 'F' AND cCausaCob = '101') OR (cSitCob = 'F' AND cCausaCob = '107') THEN 
						LET vTI_CO_STATUS = 1; 
					--002 - Cliente no tiene trabajo (P45)
					ELIF(cSitCob = 'P' AND cCausaCob = '45') THEN 
						LET vTI_CO_STATUS = 2; 
					--003 - Cuenta reestructurada (P35)
					ELIF(cSitCob = 'P' AND cCausaCob = '35') THEN 
						LET vTI_CO_STATUS = 3; 
					END IF;
					
				else
					LET vTI_CO_MANUAL_HANDLING_STATUS = '0';  
					
				end if;   
			else
				LET vTI_CO_MANUAL_HANDLING_STATUS = vTI_CO_MANUAL_HANDLING_STATUS_actual;
				LET vTI_CO_STATUS = vTI_CO_STATUS_actual;
			end if;
			
			--- E-MAIL
			--TI-CO-USR-DF-WORSE-TRIGGER1: +000000000 - El email esta valido.	|	+000000001 - email invalido identificado HOY.
			--SELECT LIMIT 1 valido INTO cValEmailCob FROM bdinteg:si_correos where numcte = cNumCteCob AND fecha_hora=(select max(fecha_hora) from bdinteg:si_correos where numcte = cNumCteCob );
			SELECT limit 1 fecha_hora INTO cFecha_hora_email
			  FROM bdinteg:si_correos
			 WHERE numcte = cNumCteCob
			   AND status_correo = 'A';
			   
			   let dFecha_hora_email = mdy(substr(cFecha_hora_email,6,2), substr(cFecha_hora_email,9,2), substr(cFecha_hora_email,1,4));
			
			if NVL(dFecha_hora_email,'') <> '' then
				if dFecha_hora_email >= vFechahoy then
					   LET vTI_CO_USR_DF_WORSE_TRIGGER1 = 1;
					   LET cActualiza_email = 'S';
				else
					   LET vTI_CO_USR_DF_WORSE_TRIGGER1 = 0; 
				end if; 
			else
				LET vTI_CO_USR_DF_WORSE_TRIGGER1 = vTI_CO_USR_DF_WORSE_TRIGGER1_actual;
			end if;
			
			
		ELSE
			--TI-CO-STATUS:(FI) Situacion especial. 	- 	Index
			--SELECT LIMIT 1 situacion,causa INTO cSitCob,cCausaCob FROM bdisitesp:"informix".se_ctessitespcred WHERE empresa = vEmpresa AND numcred = cNumCredCob;
			select limit 1 situacion,causa INTO cSitCob,cCausaCob
			  from bdisitesp:se_ctessitespcte
			 where numcte = cNumCteCob; 
			
			LET cSitCob = nvl(cSitCob,'');
			LET cCausaCob = nvl(cCausaCob,0);
			
			if nvl(cSitCob,'') = '' then
			   LET vTI_CO_MANUAL_HANDLING_STATUS = 0;
			   LET vTI_CO_STATUS = 0;
			else
			   LET vTI_CO_MANUAL_HANDLING_STATUS = 1;
	
			   IF(cSitCob = 'F' AND cCausaCob = '42') OR (cSitCob = 'F' AND cCausaCob = '101') OR (cSitCob = 'F' AND cCausaCob = '107') THEN 
					LET vTI_CO_STATUS = 1; 
					--002 - Cliente no tiene trabajo (P45)
				ELIF(cSitCob = 'P' AND cCausaCob = '45') THEN 
					LET vTI_CO_STATUS = 2; 
					--003 - Cuenta reestructurada (P35)
				ELIF(cSitCob = 'P' AND cCausaCob = '35') THEN 
					LET vTI_CO_STATUS = 3; 
				END IF;
			   
			end if;
			
			--SELECT COUNT(*) INTO cStatusTelCob FROM bdinteg:si_telefonos_actual WHERE numcte = cNumCteCob AND tipo_tel= 1 AND cofetel = 'V'; 
			--select limit 1 1 into iStatusTelCob FROM bdinteg:si_telefonos_actual WHERE numcte = cNumCteCob AND tipo_tel= 1;
			
			--TI-CO-TELEPHONE-IND: Si se tiene el numero de telefono registrado 1, si no 0.		|	CASA:	tipo_tel= '1'   - Index
			-- 0 = sin numero de telefono 		|		1 =  hay numero de telefono.
			--SELECT LIMIT 1 1 INTO iValidaTelCob FROM bdinteg:si_telefonos_actual WHERE numcte=cNumCteCob AND tipo_tel= '1' AND status_tel='A';
			
			/*select case when tipo_tel = 1 then '1' else '0' end as tipo1,
				   case when tipo_tel = 2 then '1' else '0' end as tipo2
				into cValidaTelCob, cValidaCelCob
			  from bdinteg:si_telefonos_actual where numcte = cNumCteCob;
			*/
			select tipo_tel into iValidaTelCob 
			  from bdinteg:si_telefonos_actual where numcte = cNumCteCob and tipo_tel = 1;
			
			select tipo_tel into iValidaCelCob 
			  from bdinteg:si_telefonos_actual where numcte = cNumCteCob and tipo_tel = 2;
			
			IF nvl(iValidaTelCob,0) = 0 THEN
				LET vTI_CO_TELEPHONE_IND = 0; 
				LET vTI_CO_STATUS = 5;
			ELSE
				LET vTI_CO_TELEPHONE_IND = 1; 
			END IF;
					
			--005 - Cliente con telefono no valido (NT)  -- vTI_CO_STATUS
			--ELIF(cStatusTelCob = '' OR cStatusTelCob IS NULL OR cStatusTelCob = '0') THEN 
			--IF NVL(iValidaTelCob,0) = 0 THEN 
			--   LET vTI_CO_STATUS = 5;				
			--END IF;

			--TI-CO-SMS-IND: Si se tiene el numero de telefono celular registrado 1, sino 0		|	CELULAR:	tipo_tel= '2'   - Index
			--SELECT LIMIT 1 1 INTO iValidaCelCob FROM bdinteg:si_telefonos_actual WHERE numcte = cNumCteCob AND tipo_tel= '2';
			
			--IF iValidaCelCob IS NULL THEN LET cValidaCelCob = '-1'; END IF;
			
			--IF cValidaCelCob = '-1' OR iValidaCelCob = '' OR iValidaCelCob = 0 THEN
			--IF cValidaCelCob = '' OR cValidaCelCob = '0' THEN
			IF nvl(iValidaCelCob,0) = 0 THEN
				LET vTI_CO_SMS_IND = 0;
			ELSE
				LET vTI_CO_SMS_IND = 1; 
			END IF;

			--- E-MAIL
			--TI-CO-USR-DF-WORSE-TRIGGER1: +000000000 - El email esta valido.	|	+000000001 - email invalido identificado HOY.
			--SELECT LIMIT 1 valido INTO cValEmailCob FROM bdinteg:si_correos where numcte = cNumCteCob AND fecha_hora=(select max(fecha_hora) from bdinteg:si_correos where numcte = cNumCteCob );
			
			SELECT LIMIT 1 valido INTO cValEmailCob 
			   FROM bdinteg:si_correos 
			  WHERE numcte = cNumCteCob; 
				--AND secuencia = (select max(secuencia) from bdinteg:si_correos where numcte = cNumCteCob );
			
			--IF cValEmailCob IS NOT NULL OR nvl(cValEmailCob,'') <>'' THEN
			IF nvl(cValEmailCob,'') <> '' or cValEmailCob <> '' THEN
				IF cValEmailCob = '1' THEN 
					LET vTI_CO_USR_DF_WORSE_TRIGGER1 = 1;  
				ELSE	
					LET vTI_CO_USR_DF_WORSE_TRIGGER1 = 0; 
				END IF;
			ELSE
				LET vTI_CO_USR_DF_WORSE_TRIGGER1 = 0;  
			END IF;
			
		END IF;
		
		--004 - Cuenta vendida (CV)
		IF(cStatusCob = 'CV') AND (vTipo_prod = 'REV' OR vTipo_prod = 'CRD') THEN 

			LET vTI_CO_STATUS = 4; 		
		   --005 - Cliente con telefono no valido (NT)
		   --ELIF NVL(iStatusTelCob,0) <= 0 THEN 
		
			--LET vTI_CO_STATUS = 5;		
		--006 - Cliente con saldo Inmaterial < 500 pesos"			
		--ELIF ( dSaldoCapCob < (SELECT valor FROM bdicred:"informix".sd_param WHERE empresa = '001' AND cod_param='083')) THEN 
		ELIF ( dSaldoCapCob < vVal_SdoInmaterial )  THEN
			LET vTI_CO_STATUS = 6; 
		ELSE
			LET vTI_CO_STATUS = 0; 
		END IF;	
			   	
			
		
	
		--TI-CO-FULL-BAL-PAYMENT-IND: 0 - El credito se debe pagar en una sola exhibicion (en la proxima mensualidad) -- > Si el pago minimo es igual al saldo total para liquidar. 
		--							  1 - El credito se puede pagar en mas de una exhibicion (en mas mensualidades)   -- > Si el pago minimo es menor al saldo total para liquidar. Indicador que especifica como se pagara el saldo total.
		IF vTipo_prod = 'REV' THEN	
			-- Saldo total para liquidar TDC	
			SELECT sdo_tot_liquidar, pago_minimo, comportamiento, atm_disp_fecha, pos_disp_fecha, vnt_disp_fecha, fecha_ultimo_pago, fecha_ultima_mora, fecha_ultima_compra,
			       fecha_promesa_rota, monto_ultimo_pago, saldo_maximo_hist, num_pagos_hist, num_convenios_hist, sdo_tot_liquidar_ch, 
				   atm_disp_monto, vnt_disp_monto, pos_disp_monto, monto_pagos_ch, fecha_sdo_maximo, num_pagos_h, 
				   num_vencidos_ch, intereses_periodo_ch, total_comisiones_ch, fecha_prox_anualidad, cobro_anualidad
			INTO dSdoTotalLiq_2, dPagoMinimoCob_2, cComportamientoCob, dFechaDispAtmCob, dFechaDispPosCob, dFechaDispVntCob, dFechaUltPagoCob, dMesUltMoraCob, dFechaUltimaCompraCob,
			     dFechaVctoConv1, dMontoUltPagoCob_2, dSaldoMaxCob_2, iPagosRealizaCob_2, iNumConvenioHistCob, dSdoTotalLiqCH_2,
				 dDispAtmCob_2, dDispVntCob_2, dDispPosCob_2, dMontoPagosCH_2, dFechaSdoMaxCob, iNumPagos_2, 
				 iNumvencidosCobCH_2, dIntMesCobCH_2, dComisionCobCH_2, dProxFechaAnualidad, cCobro_anualidad
			FROM bdicred:sd_indicador_cred WHERE empresa  = vEmpresa AND num_credito = cNumCredCob;
			
			LET dSdoTotalLiq = NVL(dSdoTotalLiq_2,0);
			LET dPagoMinimoCob =  NVL(dPagoMinimoCob_2,0); 
			LET dMontoUltPagoCob = NVL(dMontoUltPagoCob_2,0); 
			LET dSaldoMaxCob = NVL(dSaldoMaxCob_2,0); 
			LET iPagosRealizaCob = NVL(iPagosRealizaCob_2,0); 
			LET dSdoTotalLiqCH = NVL(dSdoTotalLiqCH_2,0);
			LET dDispAtmCob = NVL(dDispAtmCob_2,0);
			LET dDispVntCob = NVL(dDispVntCob_2,0); 
			LET dDispPosCob = NVL(dDispPosCob_2,0); 
			LET dMontoPagosCH = NVL(dMontoPagosCH_2,0); 
			LET iNumPagos = NVL(iNumPagos_2,0); 
			LET iNumvencidosCobCH = NVL(iNumvencidosCobCH_2,0); 
			LET dIntMesCobCH = NVL(dIntMesCobCH_2,0); 
			LET dComisionCobCH = NVL(dComisionCobCH_2,0);
		
			
			--IF dSdoTotalLiq IS NULL THEN LET cSdoTotalLiq = '-1'; END IF;
			
			--IF cSdoTotalLiq = '-1' OR dSdoTotalLiq = '' OR dSdoTotalLiq = 0 OR cPagoMinimoCob = '-1' OR dPagoMinimoCob='' OR dPagoMinimoCob=0  THEN
			IF dSdoTotalLiq = '' OR dSdoTotalLiq <= 0 OR dPagoMinimoCob='' OR dPagoMinimoCob<=0  THEN
				LET vTI_CO_FULL_BAL_PAYMENT_IND = 0;
			ELSE
				-- 0 - El credito se debe pagar en una sola exhibicion (en la proxima mensualidad) -- > Si el pago minimo es igual al saldo total para liquidar. 
				IF dPagoMinimoCob = dSdoTotalLiq THEN
					LET vTI_CO_FULL_BAL_PAYMENT_IND = 0;
				-- 1 - El credito se puede pagar en mas de una exhibicion (en mas mensualidades) --> Si el pago minimo es menor al saldo total para liquidar.Indi
				ELIF dPagoMinimoCob < dSdoTotalLiq THEN
					LET vTI_CO_FULL_BAL_PAYMENT_IND = 1;
				ELSE 
					LET vTI_CO_FULL_BAL_PAYMENT_IND = 0;
				END IF;
			END IF;
		ELIF vTipo_prod = 'CRD' THEN
			-- Saldo total para liquidar Prestamo 
			SELECT  sdo_tot_liquidar, pago_minimo, fecha_ultimo_pago, fecha_ultima_mora, fecha_promesa_rota, monto_ultimo_pago, saldo_maximo_hist,
			        num_pagos_hist, num_convenios_hist, sdo_tot_liquidar_ch, monto_pagos_ch, cumplio_convenio, num_vencidos_ch, intereses_periodo_ch
			  INTO dSdoTotalLiq_2, dPagoMinimoCob_2, dFechaUltPagoCob, dMesUltMoraCob, dFechaVctoConv1, dMontoUltPagoCob_2, dSaldoMaxCob_2,
			       iPagosRealizaCob_2, iNumConvenioHistCob, dSdoTotalLiqCH_2, dMontoPagosCH_2, iConvenio, iNumvencidosCobCH_2, dIntMesCobCH_2
			  FROM bdicred:sd_indicador_cred_crd 
		     WHERE empresa  = vEmpresa 
  		       AND num_credito = cNumCredCob;
			
			LET dSdoTotalLiq = NVL(dSdoTotalLiq_2,0);
			LET dPagoMinimoCob =  NVL(dPagoMinimoCob_2,0); 
			LET dMontoUltPagoCob = NVL(dMontoUltPagoCob_2,0); 
			LET dSaldoMaxCob = NVL(dSaldoMaxCob_2,0); 
			LET iPagosRealizaCob = NVL(iPagosRealizaCob_2,0); 
			LET dSdoTotalLiqCH = NVL(dSdoTotalLiqCH_2,0);
			LET dMontoPagosCH = NVL(dMontoPagosCH_2,0); 
			LET iNumvencidosCobCH = NVL(iNumvencidosCobCH_2,0); 
			LET dIntMesCobCH = NVL(dIntMesCobCH_2,0); 
		
			
			--IF dSdoTotalLiq IS NULL THEN LET cSdoTotalLiq = '-1'; END IF;
			
			--IF cSdoTotalLiq = '-1' OR dSdoTotalLiq = '' OR dSdoTotalLiq = 0 OR cPagoMinimoCob = '-1' OR dPagoMinimoCob='' OR dPagoMinimoCob=0 THEN
			IF dSdoTotalLiq = '' OR dSdoTotalLiq <= 0 OR dPagoMinimoCob='' OR dPagoMinimoCob <=0 THEN
				LET vTI_CO_FULL_BAL_PAYMENT_IND = 0;
			ELSE
				-- 0 - El credito se debe pagar en una sola exhibicion (en la proxima mensualidad) -- > Si el pago minimo es igual al saldo total para liquidar. 
				IF dPagoMinimoCob = dSdoTotalLiq THEN
					LET vTI_CO_FULL_BAL_PAYMENT_IND = 0;
				-- 1 - El credito se puede pagar en mas de una exhibicion (en mas mensualidades) --> Si el pago minimo es menor al saldo total para liquidar.Indi
				ELIF dPagoMinimoCob < dSdoTotalLiq THEN
					LET vTI_CO_FULL_BAL_PAYMENT_IND = 1;
				ELSE 
					LET vTI_CO_FULL_BAL_PAYMENT_IND = 0;
				END IF;
			END IF;
		END IF;
		
		--TI-CO-TRANS-REVOLVE-IND: Indicador de Transaccion/Revolvente, se refiere a un identificador relacionado a los pagos reales que hace el cliente; - Index
		--0: Sin codigo           1: Totalero (que no paga intereses)			2: Revolvente (que paga intereses)		
		IF cComportamientoCob IS NULL THEN LET cComportamientoCob = '-1'; END IF;
		
		--0: Sin codigo : En el caso de prestamos a plazo: "Sin Codigo".                                                                      
		IF (vTI_CO_PROD_TYPE = 3 OR cComportamientoCob NOT IN ('1','2') OR cComportamientoCob = '-1') THEN 
			LET vTI_CO_TRANS_REVOLVE_IND = 0; 
		--1: Totalero (que no paga intereses): si son mayores o iguales a este se considera "Totalero"
		ELIF (vTI_CO_PROD_TYPE = 5 AND cComportamientoCob = '1') THEN 
			LET vTI_CO_TRANS_REVOLVE_IND = 1; 
		--2: Revolvente (que paga intereses): En el caso de prestamos revolventes: en los ultimos 3 meses (o los meses de historia que tenga el credito menores a 3), el cliente ha realizado en promedio pagos menores al pago para no generar intereses y mayores o iguales a 0, se considera "Revolvente"

		ELIF (vTI_CO_PROD_TYPE = 5 AND cComportamientoCob = '2') THEN 
			LET vTI_CO_TRANS_REVOLVE_IND = 2; 
		END IF; 						
		
		/*--TI-CO-TELEPHONE-IND: Si se tiene el numero de telefono registrado 1, si no 0.		|	CASA:	tipo_tel= '1'   - Index
		-- 0 = sin numero de telefono 		|		1 =  hay numero de telefono.
		--SELECT COUNT(*) INTO iValidaTelCob FROM bdinteg:si_telefonos_actual WHERE numcte=cNumCteCob AND tipo_tel= '1' AND status_tel='A' AND cofetel='V';  
		SELECT LIMIT 1 1 INTO iValidaTelCob FROM bdinteg:si_telefonos_actual WHERE numcte=cNumCteCob AND tipo_tel= '1' AND status_tel='A';
		
		IF iValidaTelCob IS NULL THEN LET cValidaTelNull = '-1'; END IF;
		
		IF cValidaTelNull = '-1' OR iValidaTelCob = '' OR iValidaTelCob = 0 THEN
			LET vTI_CO_TELEPHONE_IND = 0; 
		ELSE
			LET vTI_CO_TELEPHONE_IND = 1; 
		END IF;
		*/
		
		/*--- Comenta Juan no necesario hacer esto, todas las cuentas tienen una Dirección desde su apertura
		--TI-CO-ADDRESS-IND: Si se tiene la direccion registrada 1, sino 0. 		Tipo 1:Casa 	|		2:Trabajo 			- Index
		--SELECT COUNT(*) INTO iValidaDirCob FROM bdinteg:si_direcciones_actual WHERE numcte=cNumCteCob AND tipo_dir ='1'; 
		
		SELECT limit 1 1 INTO iValidaDirCob
		  FROM bdinteg:si_direcciones_actual
		 WHERE numcte = cNumCteCob
		   AND tipo_dir ='1'; 
		
		IF iValidaDirCob IS NULL THEN LET cValidaDirCob='-1'; END IF;
		
		IF cValidaDirCob = '-1' OR iValidaDirCob = '' OR iValidaDirCob = 0 THEN
			LET vTI_CO_ADDRESS_IND = 0;
		ELSE
			LET vTI_CO_ADDRESS_IND = 1;
		END IF;
		*/
		
		LET vTI_CO_ADDRESS_IND = 1;
		
		/*--TI-CO-SMS-IND: Si se tiene el numero de telefono celular registrado 1, sino 0		|	CELULAR:	tipo_tel= '2'   - Index
		--SELECT COUNT(*) INTO iValidaCelCob FROM bdinteg:si_telefonos_actual WHERE numcte=cNumCteCob AND tipo_tel= '2' AND cofetel = 'V';
		SELECT LIMIT 1 1 INTO iValidaCelCob FROM bdinteg:si_telefonos_actual WHERE numcte = cNumCteCob AND tipo_tel= '2';
		
		IF iValidaCelCob IS NULL THEN LET cValidaCelCob = '-1'; END IF;
		
		IF cValidaCelCob = '-1' OR iValidaCelCob = '' OR iValidaCelCob = 0 THEN
			LET vTI_CO_SMS_IND = 0;
		ELSE
			LET vTI_CO_SMS_IND = 1; 
		END IF;
		*/
		
		IF iExisteCuenta > 0 THEN
			--TI-CO-LEGAL-CODE: 			000: No hay aclaraciOn.  			001: Hay aclaraciOn. - Index 	-		fky_estatus_aclaracion = 2  activa
			SELECT COUNT(*) INTO iValidaAclCob 
			  FROM bdiaclaracion:acl_producto a
				   JOIN bdiaclaracion:acl_aclaracion b ON b.fky_producto = a.pky_producto AND b.fky_estatus_aclaracion= '2'
			 WHERE a.numero_cuenta = cNumCredCob;
			
			IF iValidaAclCob IS NULL THEN LET cValidaAclCob = '-1'; END IF;
			
			IF cValidaAclCob = '-1' OR iValidaAclCob = '' OR iValidaAclCob = 0 THEN 
				LET vTI_CO_LEGAL_CODE = 0; 
			ELSE	
				LET vTI_CO_LEGAL_CODE = 1; 
				LET cActualiza_aclaracion = 'S';
			END IF;
		ELSE
			LET vTI_CO_LEGAL_CODE = 0; 
			LET cActualiza_aclaracion = '';
		END IF;
		
		--TI-CO-DATE-OPEN: Fecha de apertura de la cuenta.	
		IF dFechaAperturaCob IS NULL THEN LET cFechaAperturaCob = '-1'; END IF;
		
		IF cFechaAperturaCob = '-1' OR dFechaAperturaCob = '' THEN 
			LET TI_CO_DATE_OPEN = '01/01/1900'; 
		ELSE 
			LET TI_CO_DATE_OPEN = dFechaAperturaCob;
		END IF;
		
		--TI-CO-DATE-BILLING-CYMD: ultima fecha de facturacion - Se toma la fecha de corte.		
		IF vFechacorte IS NULL THEN LET cFechacorte  = '-1'; END IF;
		
		IF cFechacorte = '-1' OR vFechacorte = '' THEN
			LET vTI_CO_DATE_BILLING_CYMD = '01/01/1900'; 
		ELSE
			LET vTI_CO_DATE_BILLING_CYMD = vFechacorte;
		END IF;
		
		--TI-CO-DATE-START-DELQ: Fecha de inicio de Morosidad - Index 					
		IF dFechaVencidoCob IS NULL THEN LET cFechaVencidoCob = '-1'; END IF;
		
		IF cFechaVencidoCob = '-1' OR dFechaVencidoCob = '' THEN 
			LET vTI_CO_DATE_START_DELQ = '01/01/1900'; 
		ELSE 
			LET vTI_CO_DATE_START_DELQ = dFechaVencidoCob;
		END IF;
		
		--TI-CO-DATE-LAST-DEBIT: Fecha de la ultima compra o disposicion generado(a) por el cliente registrado en la cuenta (No aplica para prestamos a plazo). - Index
		IF dFechaDispVntCob IS NULL THEN LET cFechaDispVntCob = '-1'; END IF;
		IF dFechaDispAtmCob IS NULL THEN LET cFechaDispAtmCob = '-1'; END IF;
		IF dFechaDispPosCob IS NULL THEN LET cFechaDispPosCob = '-1'; END IF;


--MACF
		IF vTipo_prod = 'CRD' THEN
			LET vTI_CO_DATE_LAST_DEBIT = '01/01/1900';

			LET vTI_CO_DATE_LAST_CASH_CYM = '01/01/1900';

			IF dMesUltMoraCob IS NULL THEN LET cMesUltMoraCob = '-1'; END IF;
			
			IF dMesUltMoraCob = '' OR cMesUltMoraCob = '-1' THEN
				LET vTI_CO_DATE_LAST_DELQ_CYMD = '01/01/1900';
			ELSE
				LET vTI_CO_DATE_LAST_DELQ_CYMD = dMesUltMoraCob; 
			END IF;
			
			LET vTI_CO_DATE_LAST_PUR_CYM = '01/01/1900';
			
			LET vTI_CO_DATE_FEE_CYM = '01/01/1900';
			
			--TI-CO-DATE-ORIGINAL-MATURITY: Para los productos a plazos, la fecha de vencimiento ORIGINAL de la cuenta,aplica solo para prestamos a plazo.
			IF dFechaVencOrigCob IS NULL THEN LET cFechaVencOrigCob = '-1'; END IF;
			
			IF cFechaVencOrigCob = '-1' OR dFechaVencOrigCob='' THEN 
				LET vTI_CO_DATE_ORIGINAL_MATURITY = '01/01/1900';
			ELSE 
				--LET cFechaVencOrigCob = TO_CHAR(dFechaVencOrigCob,'%Y%m%d');
				--LET vTI_CO_DATE_ORIGINAL_MATURITY = substr(cFechaVencOrigCob,3,6); 
				LET vTI_CO_DATE_ORIGINAL_MATURITY = dFechaVencOrigCob; 
			END IF;
			
			--TI-CO-DATE-CURRENT-MATURITY: Para los productos a plazos, la fecha de vencimiento ACTUAL de la cuenta, aplica solo para prestamos a plazo.					 	-		NOTA: LONGITUD 6	
			IF cFechaVencidoCob = '-1' OR dFechaVencidoCob = '' THEN 
				LET vTI_CO_DATE_CURRENT_MATURITY = '01/01/1900';
			ELSE 
				--LET cFechaVencidoCob6 = TO_CHAR(dFechaVencidoCob,'%Y%m%d');
				--LET vTI_CO_DATE_CURRENT_MATURITY = substr(cFechaVencidoCob6,3,6);
				LET vTI_CO_DATE_CURRENT_MATURITY = dFechaVencidoCob; 
			END IF;
			
		ELIF vTipo_prod = 'REV' THEN
		
			--TI-CO-BLOCK-CODE: De la cuenta que fue reportata en TI-CO-ACCOUNT-ID
			SELECT LIMIT 1 cve_causa INTO cBlockCode 
			  FROM bdicred:sd_bitacorabloqueocta 
			 WHERE cuenta = cNumCredCob 
			   AND cve_causa IN ('04','06','10','01','02','03','05','07','08','09') 
			   AND fecha = (SELECT MAX(fecha) 
							  FROM bdicred:sd_bitacorabloqueocta 
							 WHERE cuenta = cNumCredCob and cve_causa IN ('04','06','10','01','02','03','05','07','08','09'));
			
			IF cBlockCode IS NULL THEN LET cBlockCodeNull='-1'; END IF;
			
			IF cBlockCodeNull = '-1' OR cBlockCode = '0' OR cBlockCode='' THEN 
				LET vTI_CO_BLOCK_CODE 	 = 0;
			ELSE
				IF iIdOrigen = 1 OR cStatusCob='CV' THEN 
					LET vTI_CO_BLOCK_CODE = 1; 
				ELIF cBlockCode = '04' THEN 
					LET vTI_CO_BLOCK_CODE =	8; 
				ELIF cBlockCode = '06' THEN 
					LET vTI_CO_BLOCK_CODE = 4; 
				ELIF cBlockCode = '10' THEN 
					LET vTI_CO_BLOCK_CODE = 2;
				ELSE 
					LET vTI_CO_BLOCK_CODE = 95;
				END IF;
			END IF;
		
			IF (cFechaDispAtmCob = '-1' OR cFechaDispVntCob = '-1' OR cFechaDispPosCob = '-1' OR
			    dFechaDispAtmCob = '' OR dFechaDispVntCob = '' OR dFechaDispPosCob = '') THEN
				LET vTI_CO_DATE_LAST_DEBIT = '01/01/1900'; 
			ELSE
				IF dFechaDispAtmCob > dFechaDispVntCob THEN 
					IF(dFechaDispAtmCob > dFechaDispPosCob) THEN
						LET dFechaUltMovCob = dFechaDispAtmCob;
						LET vTI_CO_DATE_LAST_DEBIT = dFechaUltMovCob;
					ELSE
						LET dFechaUltMovCob = dFechaDispPosCob;
						LET vTI_CO_DATE_LAST_DEBIT = dFechaUltMovCob;
					END IF;
				ELSE
					IF dFechaDispVntCob > dFechaDispPosCob THEN 
						--LET cFechaUltMovCob = dFechaDispVntCob;
						LET vTI_CO_DATE_LAST_DEBIT = dFechaDispVntCob;
					ELSE 
						--LET cFechaUltMovCob = dFechaDispPosCob;
						LET vTI_CO_DATE_LAST_DEBIT = dFechaDispPosCob;
					END IF;
				END IF;
			END IF;
			
			--TI-CO-DATE-LAST-CASH-CYM:Fecha del Ultimo cash advance (disposicion en efectivo) 		-			NOTA: LONGITUD 6	
			IF dFechaDispVntCob IS NULL  THEN LET cFechaDispVntCob = '-1'; END IF;
			IF dFechaDispAtmCob IS NULL  THEN LET cFechaDispAtmCob = '-1'; END IF;
			
			IF (dFechaDispVntCob='' OR dFechaDispAtmCob=''OR cFechaDispVntCob = '-1' OR cFechaDispAtmCob = '-1') THEN
				LET vTI_CO_DATE_LAST_CASH_CYM = '01/01/1900';
			ELSE
				IF ( dFechaDispVntCob > dFechaDispAtmCob) THEN 
					--LET vTI_CO_DATE_LAST_CASH_CYM = SUBSTR(TO_CHAR(dFechaDispVntCob,'%Y%m%d'),3,6); 
					LET vTI_CO_DATE_LAST_CASH_CYM = dFechaDispVntCob; 
				ELSE		
					--LET vTI_CO_DATE_LAST_CASH_CYM = SUBSTR(TO_CHAR(dFechaDispAtmCob,'%Y%m%d'),3,6); 
					LET vTI_CO_DATE_LAST_CASH_CYM = dFechaDispAtmCob; 
				END IF;
			END IF;
			
			--TI-CO-DATE-LAST-DELQ-CYMD: Fecha de la ultima vez que la cuenta estuvo morasa. 
			IF dMesUltMoraCob IS NULL THEN LET cMesUltMoraCob = '-1'; END IF;
			
			IF  dMesUltMoraCob = '' OR cMesUltMoraCob = '-1' THEN
				LET vTI_CO_DATE_LAST_DELQ_CYMD = '01/01/1900';
			ELSE
				LET vTI_CO_DATE_LAST_DELQ_CYMD = dMesUltMoraCob; 
			END IF;
			
			--TI-CO-DATE-LAST-PUR-CYM: Fecha de la ultima compra. Solo aplica para revolventes.				-			NOTA: LONGITUD 6	-	No aplica para Plazo
            --IF  dFechaUltimaCompraCob IS NULL THEN LET cFechaUltimaCompraCob = '-1'; END IF;
			
			IF nvl(dFechaUltimaCompraCob,'') = '' THEN 
				LET vTI_CO_DATE_LAST_PUR_CYM = '01/01/1900';
			ELSE 
				--LET vTI_CO_DATE_LAST_PUR_CYM = SUBSTR(to_char(dFechaUltimaCompraCob,'%Y%m%d'),3,6);     
				LET vTI_CO_DATE_LAST_PUR_CYM = dFechaUltimaCompraCob;     
			END IF;
			
			--TI-CO-DATE-FEE-CYM: Fecha de vencimiento de las cuotas anuales. 	-	USUARIO MENCIONA QUE SOLO APLICA ORO Y PLATINO 		-		NOTA: LONGITUD 6	- No aplica Plazo	
			IF cProductoCob IN ('8100','7000') THEN
				--SELECT fecha_prox_anualidad INTO dProxFechaAnualidad FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cNumCredCob AND  cobro_anualidad=1;
				
				IF cCobro_anualidad = '1' THEN
				   IF NVL(dProxFechaAnualidad,'01/01/1900') <> '01/01/1900' OR dProxFechaAnualidad <> '' THEN 
				      LET dProxFechaAnualidad = (dProxFechaAnualidad - 1 units DAY);
					  LET vTI_CO_DATE_FEE_CYM = dProxFechaAnualidad; 
				   ELSE 
				      LET vTI_CO_DATE_FEE_CYM = '01/01/1900';
                   END IF;
                ELSE
                   LET vTI_CO_DATE_FEE_CYM = '01/01/1900';  
				END IF;
				
				/*IF dProxFechaAnualidad IS NULL THEN LET cProxFechaAnualidad = '-1'; END IF;
				IF cProxFechaAnualidad = '-1' OR dProxFechaAnualidad = '' THEN 
					LET vTI_CO_DATE_FEE_CYM = '01/01/1900';
				ELSE 
					LET dProxFechaAnualidad = (dProxFechaAnualidad - 1 units DAY);
					LET vTI_CO_DATE_FEE_CYM = dProxFechaAnualidad; 
				END IF;
				*/
			
			END IF;
			
			--TI-CO-DATE-ORIGINAL-MATURITY: Para los productos a plazos, la fecha de vencimiento ORIGINAL de la cuenta,aplica solo para prestamos a plazo.		-		NOTA: LONGITUD 6	
			LET vTI_CO_DATE_ORIGINAL_MATURITY = '01/01/1900';
			
			--TI-CO-DATE-CURRENT-MATURITY: Para los productos a plazos, la fecha de vencimiento ACTUAL de la cuenta, aplica solo para prestamos a plazo.					 	-		NOTA: LONGITUD 6	
			LET vTI_CO_DATE_CURRENT_MATURITY = '01/01/1900';
			
		END IF;
		
		--TI-CO-DATE-LAST-CREDIT: Fecha del ultimo pago generado por el cliente registrado en la cuenta.
		IF dFechaUltPagoCob IS NULL THEN LET cFechaUltPagoCob = '-1'; END IF;
		
		IF cFechaUltPagoCob = '-1' OR dFechaUltPagoCob = '' THEN 
			LET vTI_CO_DATE_LAST_CREDIT = '01/01/1900';
		ELSE 
			LET vTI_CO_DATE_LAST_CREDIT = dFechaUltPagoCob; 
		END IF;
		
		--TI-CO-DATE-LAST-MON-TXN-CYM : Fecha de la ultima transaccion monetaria.				-			NOTA: LONGITUD 6: SUBSTR(vTI_CO_DATE_LAST_DEBIT,3,6);
		IF (vTI_CO_DATE_LAST_DEBIT = '01/01/1900') THEN
			LET vTI_CO_DATE_LAST_MON_TXN_CYM = '01/01/1900';
		ELSE
			LET vTI_CO_DATE_LAST_MON_TXN_CYM = vTI_CO_DATE_LAST_DEBIT;
		END IF;	
		
		--TI-CO-DATE-PROM-BRKN-CYMD: Fecha en que la promesa de pago fue rota. La fecha de promesa rota, se tomara como la fecha de vencimiento del convenio que no se cumplio.
		--Un convenio no cumplido se definira como aquel que no fue cumplido al 100%. Fecha en la que la promesa de pago fue rota. 
		IF dFechaVctoConv1 IS NULL THEN LET cFechaVctoConv1 = '-1'; END IF;
		
		IF 	cFechaVctoConv1 = '-1' OR dFechaVctoConv1 = '' THEN  
			LET vTI_CO_DATE_PROM_BRKN_CYMD = '01/01/1900';
		ELSE
			LET vTI_CO_DATE_PROM_BRKN_CYMD = dFechaVctoConv1;
		END IF;
--MACF
		let vNumCredito_salida = '00000000' || trim(cNumCredCob);
		

		
		--TI-CO-BALANCE: Saldo actual de la cuenta				-			USUARIO ENVIA CORREO PARA TOMAR EL SALDO TOTAL PARA LIQUIDAR.
		IF dSdoTotalLiq IS NULL THEN LET cSdoTotalLiq = '-1'; END IF; 
			
		IF 	cSdoTotalLiq = '-1' OR dSdoTotalLiq = '' OR dSdoTotalLiq = 0 THEN
			LET vTI_CO_BALANCE = 0;
		ELSE
			LET vTI_CO_BALANCE = dSdoTotalLiq;
		END IF;
		
		--TI-CO-LIMIT: Limite actual de la cuenta (en el caso de prestamo el monto original de la cuenta).	
		IF dMontoOtorgadoCob IS NULL THEN LET cMontoOtorgadoCob = '-1'; END IF;
		
		IF cMontoOtorgadoCob = '-1' OR dMontoOtorgadoCob = '' OR dMontoOtorgadoCob = 0  THEN 
			LET vTI_CO_LIMIT = 0; 
		ELSE 
			LET vTI_CO_LIMIT = dMontoOtorgadoCob; 
		END IF;
	
		--TI-CO-CASH-BALANCE: Saldo de efectivo actual de la cuenta: Saldo de disposiciones en efectivo al corte de la cuenta que fue reportada en TI-CO-ACCOUNT-ID 
		--					  (NO aplica para prestamos a plazo)
		IF  vTipo_prod = 'CRD' THEN	
			LET vTI_CO_CASH_BALANCE = 0; 
		ELIF vTipo_prod = 'REV' THEN		
			LET dCashBalCob = dDispAtmCob+dDispVntCob;
			
			IF dCashBalCob IS NULL THEN LET cCashBalCob = '-1'; END IF;
			
			IF cCashBalCob = '-1' OR dCashBalCob = '' OR dCashBalCob = 0 THEN 
				LET vTI_CO_CASH_BALANCE = 0; 
			ELSE 
				LET vTI_CO_CASH_BALANCE = dCashBalCob;
			END IF;
		END IF;
		
		--TI-CO-AMT-ARREARS: Monto actual de la cuenta en mora (saldo vencido actual de la cuenta)
		IF dSaldoMorCob IS NULL THEN LET cSaldoMorCob = '-1'; END IF;
		
		IF cSaldoMorCob = '-1' OR dSaldoMorCob = '' OR dSaldoMorCob = 0 THEN 
			LET vTI_CO_AMT_ARREARS = 0; 
		ELSE 
			LET vTI_CO_AMT_ARREARS = dSaldoMorCob;
		END IF;
		
		let dMontoAcl = 0;
		
		if vTI_CO_LEGAL_CODE = 1 then
		
			--TI-CO-AMT-DISPUTE: El monto que esta actualmente en disputa (aclaracion) para esta cuenta.	fky_estatus_aclaracion = 2  activa					  
			SELECT SUM(b.importereclamado) INTO dMontoAcl 
			  FROM bdiaclaracion:acl_producto a
			       JOIN bdiaclaracion:acl_aclaracion b ON b.fky_producto = a.pky_producto 
			 WHERE b.fky_producto=a.pky_producto 
			   AND b.fky_estatus_aclaracion = '2' AND a.numero_cuenta = cNumCredCob
			   AND b.fechainicio = (SELECT MAX(fechainicio) 
			                          FROM bdiaclaracion:acl_producto m
							               JOIN bdiaclaracion:acl_aclaracion n ON n.fky_producto = m.pky_producto   
							         WHERE n.fky_producto = m.pky_producto 
							           AND n.fky_estatus_aclaracion= '2' AND m.numero_cuenta = cNumCredCob);

			IF dMontoAcl IS NULL THEN LET cMontoAcl = '-1'; END IF;
		
		end if; 
		
		IF cMontoAcl = '-1' OR dMontoAcl = '' OR dMontoAcl = 0 THEN
			LET vTI_CO_AMT_DISPUTE = 0; 
		ELSE
			LET vTI_CO_AMT_DISPUTE = dMontoAcl;
		END IF;
	
		--TI-CO-AMT-LAST-CREDIT: Monto del ultimo pago generado por el cliente registradado en la cuenta.		
		IF dMontoUltPagoCob IS NULL THEN LET cMontoUltPagoCobNull = '-1'; END IF;
		
		IF cMontoUltPagoCobNull = '-1' OR dMontoUltPagoCob = '' OR dMontoUltPagoCob = 0 THEN 
			LET vTI_CO_AMT_LAST_CREDIT = 0; 
		ELSE 
			LET vTI_CO_AMT_LAST_CREDIT = dMontoUltPagoCob;
		END IF;
		
		--TI-CO-HIGH-BALANCE-LF: El maximo saldo de la cuenta.	-	TOMANDO COMO REFERENCIA 3 ANIOS		-		INDICADOR			-		INDEX
		IF dSaldoMaxCob IS NULL THEN LET cSaldoMaxCob = '-1'; END IF;
		
		IF cSaldoMaxCob = '-1' OR dSaldoMaxCob = '' OR dSaldoMaxCob = 0 THEN 
			LET vTI_CO_HIGH_BALANCE_LF = 0; 
		ELSE
			LET vTI_CO_HIGH_BALANCE_LF = dSaldoMaxCob;
		END IF;
		
		--TI-CO-NUM-PYMNTS-LF: Numero de pagos realizados a la cuenta que fue reportada en TI-CO-ACCOUNT-ID (de la historia que se tenga disponible). 			-		INDICADOR			
		IF iPagosRealizaCob IS NULL THEN LET cPagosRealizaCob = '-1'; END IF;
		
		IF cPagosRealizaCob = '-1' OR iPagosRealizaCob = '' OR iPagosRealizaCob = 0 THEN 
			LET vTI_CO_NUM_PYMNTS_LF = 0; 
		ELSE 
			LET vTI_CO_NUM_PYMNTS_LF = iPagosRealizaCob;
		END IF;

		--TI-CO-NUM-PTP: El numero total de Promesas de Pagos (convenios) efectuadas en la cuenta desde su apertura.
		IF iNumConvenioHistCob IS NULL THEN LET cNumConvenioHistCob = '-1'; END IF;
		
		IF cNumConvenioHistCob ='-1' OR iNumConvenioHistCob='' OR iNumConvenioHistCob=0 THEN 
			LET vTI_CO_NUM_PTP = 0; 
		ELSE 
			LET vTI_CO_NUM_PTP = iNumConvenioHistCob;
		END IF;
		
		--TI-CO-MTHLY-BALANCE(1): Saldo en el ciclo o fecha de vencimiento. 														-	Ciclo actual.		
		IF dSdoTotalLiqCH IS NULL THEN LET cSdoTotalLiqCH = '-1'; END IF;
		
		IF cSdoTotalLiqCH = '-1' OR dSdoTotalLiqCH = '' OR dSdoTotalLiqCH = 0 THEN
			LET vTI_CO_MTHLY_BALANCE_1 = 0; 
		ELSE 
			LET vTI_CO_MTHLY_BALANCE_1 = dSdoTotalLiqCH; 
		END IF;
		
		--TI-CO-MTHLY-DEBITS(1):Monto de las compras y disposiciones realizados en la cuenta. (No aplica para prestamos a plazo).	 -	 Ciclo actual. 
		IF vTipo_prod = 'REV' THEN				
			IF dDispPosCob IS NULL THEN LET cDispPosCob = '-1'; END IF;
			IF dCashBalCob IS NULL THEN LET cCashBalCob = '-1'; END IF;
			
			IF (dCashBalCob ='' OR dCashBalCob = 0 OR cCashBalCob = '-1') OR (dDispPosCob = 0 OR dDispPosCob = '' OR cDispPosCob='-1') THEN 
				LET vTI_CO_MTHLY_DEBITS_1 = 0; 
			ELSE
				LET dCompraDispCta = dCashBalCob + dDispPosCob;
				LET vTI_CO_MTHLY_DEBITS_1 = dCompraDispCta;
			END IF;
		ELIF  vTipo_prod = 'CRD' THEN	
			LET vTI_CO_MTHLY_DEBITS_1 = 0;
		END IF;
		
		--TI-CO-MTHLY-CREDITS(1):Monto de los pagos hechos a la cuenta durante el periodo correspondiente. 				-			 	 Ciclo actual. 
		IF dMontoPagosCH IS NULL THEN LET cMontoPagos = '-1'; END IF;
		
		IF cMontoPagos = '-1' OR dMontoPagosCH='' OR dMontoPagosCH = 0 THEN 
			LET vTI_CO_MTHLY_CREDITS_1 = 0; 
		ELSE 
			LET vTI_CO_MTHLY_CREDITS_1 = dMontoPagosCH;
		END IF;

		--TI-CO-MTHLY-BALANCE(2): Saldo en el ciclo o fecha de vencimiento	-	Ciclo actual -1
		IF  (vFechacorte = vFechahoy) THEN   -- Es fecha de corte?   INI
			IF vTipo_prod = 'REV' THEN
				SELECT  sdo_tot_liquidar1,monto_pos1+monto_disp_efectivo1,monto_pagos1,num_vencidos1,intereses_periodo1,monto_comisiones1,
						sdo_tot_liquidar2,monto_pos2+monto_disp_efectivo2,monto_pagos2,num_vencidos2,intereses_periodo2,monto_comisiones2,
						sdo_tot_liquidar3,monto_pos3+monto_disp_efectivo3,monto_pagos3,num_vencidos3,intereses_periodo3,monto_comisiones3, 
						sdo_tot_liquidar4,monto_pos4+monto_disp_efectivo4,monto_pagos4,num_vencidos4,intereses_periodo4,monto_comisiones4,
						sdo_tot_liquidar5,monto_pos5+monto_disp_efectivo5,monto_pagos5,num_vencidos5,intereses_periodo5,monto_comisiones5,
																					   num_vencidos6,intereses_periodo6,monto_comisiones6,
																					   num_vencidos7,intereses_periodo7,monto_comisiones7,
																					   num_vencidos8,intereses_periodo8,monto_comisiones8,
																					   num_vencidos9,intereses_periodo9,monto_comisiones9, 
																					   num_vencidos10,intereses_periodo10,monto_comisiones10,
																					   num_vencidos11,intereses_periodo11,monto_comisiones11
				INTO dSdoTotalLiq1,dCompraDispCta1,dMontoPagos1,iMesMoraCob1,dIntMesCob1,dComisionCob1,
					 dSdoTotalLiq2,dCompraDispCta2,dMontoPagos2,iMesMoraCob2,dIntMesCob2,dComisionCob2,
					 dSdoTotalLiq3,dCompraDispCta3,dMontoPagos3,iMesMoraCob3,dIntMesCob3,dComisionCob3,
					 dSdoTotalLiq4,dCompraDispCta4,dMontoPagos4,iMesMoraCob4,dIntMesCob4,dComisionCob4,
					 dSdoTotalLiq5,dCompraDispCta5,dMontoPagos5,iMesMoraCob5,dIntMesCob5,dComisionCob5,
																iMesMoraCob6,dIntMesCob6,dComisionCob6,
																iMesMoraCob7,dIntMesCob7,dComisionCob7,
																iMesMoraCob8,dIntMesCob8,dComisionCob8,
																iMesMoraCob9,dIntMesCob9,dComisionCob9,
																iMesMoraCob10,dIntMesCob10,dComisionCob10,
																iMesMoraCob11,dIntMesCob11,dComisionCob11
				FROM bdicobranza:cb_triad_sdos_inds_tdc 
				WHERE num_credito=cNumCredCob
				--AND fecha_proceso =(SELECT date(max(fecha_proceso) - 1 units month) FROM bdicobranza:cb_triad_sdos_inds_tdc WHERE num_credito=cNumCredCob);
				AND fecha_proceso =(SELECT max(fecha_proceso) FROM bdicobranza:cb_triad_sdos_inds_tdc WHERE num_credito=cNumCredCob);							
			ELIF vTipo_prod = 'CRD' AND (vFechacorte = vFechahoy) THEN
			
				SELECT  sdo_tot_liquidar1,monto_pagos1,num_vencidos1,intereses_periodo1,
						sdo_tot_liquidar2,monto_pagos2,num_vencidos2,intereses_periodo2,
						sdo_tot_liquidar3,monto_pagos3,num_vencidos3,intereses_periodo3,
						sdo_tot_liquidar4,monto_pagos4,num_vencidos4,intereses_periodo4,
						sdo_tot_liquidar5,monto_pagos5,num_vencidos5,intereses_periodo5,
													   num_vencidos6,intereses_periodo6,
													   num_vencidos7,intereses_periodo7,
													   num_vencidos8,intereses_periodo8,
													   num_vencidos9,intereses_periodo9, 
													   num_vencidos10,intereses_periodo10,
													   num_vencidos11,intereses_periodo11
				INTO	dSdoTotalLiq1,dMontoPagos1,iMesMoraCob1,dIntMesCob1,
						dSdoTotalLiq2,dMontoPagos2,iMesMoraCob2,dIntMesCob2,
						dSdoTotalLiq3,dMontoPagos3,iMesMoraCob3,dIntMesCob3,
						dSdoTotalLiq4,dMontoPagos4,iMesMoraCob4,dIntMesCob4,
						dSdoTotalLiq5,dMontoPagos5,iMesMoraCob5,dIntMesCob5,
												   iMesMoraCob6,dIntMesCob6,
												   iMesMoraCob7,dIntMesCob7,
												   iMesMoraCob8,dIntMesCob8,
												   iMesMoraCob9,dIntMesCob9,
												   iMesMoraCob10,dIntMesCob10,
												   iMesMoraCob11,dIntMesCob11
				FROM bdicobranza:cb_triad_sdos_inds_cnr 
				WHERE num_credito=cNumCredCob
				--AND fecha_proceso =(SELECT date(max(fecha_proceso) - 1 units month) FROM bdicobranza:cb_triad_sdos_inds_cnr WHERE num_credito=cNumCredCob);
				AND fecha_proceso =(SELECT max(fecha_proceso) FROM bdicobranza:cb_triad_sdos_inds_cnr WHERE num_credito=cNumCredCob);
			END IF;			
		
			--- 20200529-- ESTA asignación de las variables solo se hará cuando sea fecha de corte, continuar con esto......
			
			IF dSdoTotalLiq1 IS NULL THEN LET cSdoTotalLiq1 = '-1'; END IF;
			
			IF dSdoTotalLiq1 = 0 OR dSdoTotalLiq1 = '' OR cSdoTotalLiq1 = '-1' THEN 
				LET vTI_CO_MTHLY_BALANCE_2 = 0;
			ELSE
				LET vTI_CO_MTHLY_BALANCE_2 = dSdoTotalLiq1;
			END IF;		
			
			--TI-CO-MTHLY-DEBITS(2): Monto de las compras y disposiciones realizados en la cuenta. (NO aplica para prestamos a plazo). 			-		Ciclo actual -1
			IF vTipo_prod = 'REV' THEN
				
				IF dCompraDispCta1 IS NULL THEN LET cCompraDispCta1 = '-1'; END IF;
				
				IF (dCompraDispCta1 = 0 OR dCompraDispCta1 = '' OR cCompraDispCta1 = '-1') THEN 
					LET vTI_CO_MTHLY_DEBITS_2 = 0; 
				ELSE
					LET vTI_CO_MTHLY_DEBITS_2 = dCompraDispCta1;
				END IF;
			ELIF vTipo_prod = 'CRD' THEN
				LET vTI_CO_MTHLY_DEBITS_2 = 0;
			END IF;
					
			--TI-CO-MTHLY-CREDITS(2):Monto de los pagos hechos a la cuenta durante el periodo correspondiente. 									-		Ciclo actual -1		
			IF dMontoPagos1 IS NULL OR dMontoPagos1='' OR dMontoPagos1=0THEN 
				LET vTI_CO_MTHLY_CREDITS_2 = 0; 
			ELSE 
				LET vTI_CO_MTHLY_CREDITS_2 = dMontoPagos1;
			END IF;
			
			--TI-CO-MTHLY-BALANCE(3): Saldo en el ciclo o fecha de vencimiento. 																- 		Ciclo actual -2.		
			IF dSdoTotalLiq2 IS NULL THEN LET cSdoTotalLiq2 = '-1'; END IF;
			
			IF dSdoTotalLiq2 = 0 OR  dSdoTotalLiq2 = '' OR cSdoTotalLiq2 = '-1' THEN 
				LET vTI_CO_MTHLY_BALANCE_3 = 0;
			ELSE
				LET vTI_CO_MTHLY_BALANCE_3 = dSdoTotalLiq2;
			END IF;
			
			--TI-CO-MTHLY-DEBITS(3): Monto de las compras y disposiciones realizados en la cuenta. (NO aplica para prestamos a plazo). 			-		Ciclo actual - 2
			IF vTipo_prod = 'REV' THEN			
				
				IF dCompraDispCta2 IS NULL THEN LET cCompraDispCta2 = '-1'; END IF;
				
				IF (dCompraDispCta2 = 0 OR dCompraDispCta2 = '' OR cCompraDispCta2 = '-1') THEN 
					LET vTI_CO_MTHLY_DEBITS_3 = 0; 
				ELSE
					LET vTI_CO_MTHLY_DEBITS_3 = dCompraDispCta2;
				END IF;
			ELIF vTipo_prod = 'CRD' THEN
				LET vTI_CO_MTHLY_DEBITS_3 = 0;
			END IF;
					
			--TI-CO-MTHLY-CREDITS(3):Monto de los pagos hechos a la cuenta durante el periodo correspondiente. 									-		Ciclo actual -2
			IF dMontoPagos2 IS NULL OR dMontoPagos2 = '' OR dMontoPagos2 = 0 THEN 
				LET vTI_CO_MTHLY_CREDITS_3 = 0; 
			ELSE 
				LET vTI_CO_MTHLY_CREDITS_3 = dMontoPagos2;
			END IF;
			
			--TI-CO-MTHLY-BALANCE(4): Saldo en el ciclo o fecha de vencimiento. 																-		Ciclo actual -3
			IF dSdoTotalLiq3 IS NULL THEN LET cSdoTotalLiq3 = '-1'; END IF;
			
			IF dSdoTotalLiq3 = 0 OR dSdoTotalLiq3 = '' OR cSdoTotalLiq3 = '-1' THEN 
				LET vTI_CO_MTHLY_BALANCE_4 = 0;
			ELSE		
				LET vTI_CO_MTHLY_BALANCE_4 = dSdoTotalLiq3;
			END IF;
			
			--TI-CO-MTHLY-DEBITS(4): Monto de las compras y disposiciones realizados en la cuenta. (No aplica para prestamos a plazo). 			-			Ciclo actual - 3	
			IF vTipo_prod = 'REV' THEN
				
				IF dCompraDispCta3 IS NULL THEN LET cCompraDispCta3 = '-1'; END IF;
				
				IF (dCompraDispCta3 = 0 OR dCompraDispCta3 = '' OR cCompraDispCta3 = '-1') THEN 
					LET vTI_CO_MTHLY_DEBITS_4 = 0; 
				ELSE
					LET vTI_CO_MTHLY_DEBITS_4 = dCompraDispCta3;
				END IF;
			ELIF vTipo_prod = 'CRD' THEN
				LET vTI_CO_MTHLY_DEBITS_4 = 0;
			END IF;
			
			--TI-CO-MTHLY-CREDITS(4): Monto de los pagos hechos a la cuenta durante el periodo correspondiente. 								-			Ciclo actual -3
			IF dMontoPagos3 IS NULL OR dMontoPagos3 = '' OR dMontoPagos3 = 0 THEN 
				LET vTI_CO_MTHLY_CREDITS_4 = 0; 
			ELSE 
				LET vTI_CO_MTHLY_CREDITS_4 = dMontoPagos3;
			END IF;
			
			--TI-CO-MTHLY-BALANCE(5): Saldo en el ciclo o fecha de vencimiento																	-			Ciclo actual -4
			IF dSdoTotalLiq4 IS NULL THEN LET cSdoTotalLiq4 = '-1'; END IF;
			
			IF dSdoTotalLiq4 = 0 OR dSdoTotalLiq4 = '' OR cSdoTotalLiq4 = '-1' THEN 
				LET vTI_CO_MTHLY_BALANCE_5 = 0;
			ELSE		
				LET vTI_CO_MTHLY_BALANCE_5 = dSdoTotalLiq4;
			END IF;
			
			--TI-CO-MTHLY-DEBITS(5): Monto de las compras y disposiciones realizados en la cuenta. (No aplica para prestamos a plazo). 			-			Ciclo actual -4
			IF vTipo_prod = 'REV' THEN			
				IF dCompraDispCta4 IS NULL THEN LET cCompraDispCta4 = '-1'; END IF;
				
				IF (dCompraDispCta4 = 0 OR dCompraDispCta4 = '' OR cCompraDispCta4 = '-1') THEN 
					LET vTI_CO_MTHLY_DEBITS_5 = 0; 
				ELSE
					LET vTI_CO_MTHLY_DEBITS_5 = dCompraDispCta4;
				END IF;
			ELIF vTipo_prod = 'CRD' THEN
				LET vTI_CO_MTHLY_DEBITS_5 = 0;
			END IF;
			
			--TI-CO-MTHLY-CREDITS(5): Monto de los pagos hechos a la cuenta durante el periodo correspondiente. 								-				Ciclo actual -4		
			IF dMontoPagos4 IS NULL OR dMontoPagos4 = '' OR dMontoPagos4 = 0 THEN 
				LET vTI_CO_MTHLY_CREDITS_5 = 0; 
			ELSE 
				LET vTI_CO_MTHLY_CREDITS_5 = dMontoPagos4;
			END IF;
			
			--TI-CO-MTHLY-BALANCE(6): Saldo en el ciclo o fecha de vencimiento.																	-			Ciclo actual -5		
			IF dSdoTotalLiq5 IS NULL THEN LET cSdoTotalLiq5 = '-1'; END IF;
			
			IF dSdoTotalLiq5 = 0 OR dSdoTotalLiq5 = '' OR cSdoTotalLiq5 = '-1' THEN 
				LET vTI_CO_MTHLY_BALANCE_6 = 0;
			ELSE		
				LET vTI_CO_MTHLY_BALANCE_6 = dSdoTotalLiq5;
			END IF;
			
			--TI-CO-MTHLY-DEBITS(6): Saldo en el ciclo o fecha de vencimiento.																	-			Ciclo actual -5
			IF vTipo_prod = 'REV' THEN

				IF dCompraDispCta5 IS NULL THEN LET cCompraDispCta5 = '-1'; END IF;
				
				IF (dCompraDispCta5 = 0 OR dCompraDispCta5 = '' OR cCompraDispCta5 = '-1') THEN 
					LET vTI_CO_MTHLY_DEBITS_6 = 0; 
				ELSE
					LET vTI_CO_MTHLY_DEBITS_6 = dCompraDispCta5;
				END IF;
			ELIF vTipo_prod = 'CRD' THEN
				LET vTI_CO_MTHLY_DEBITS_6 = 0;
			END IF;
			
			--TI-CO-MTHLY-CREDITS(6): Monto de los pagos hechos a la cuenta durante el periodo correspondiente. 								-			Ciclo actual -5
			IF dMontoPagos5 IS NULL OR dMontoPagos5 = '' OR dMontoPagos5 = 0 THEN 
				LET vTI_CO_MTHLY_CREDITS_6 = 0; 
			ELSE 
				LET vTI_CO_MTHLY_CREDITS_6 = dMontoPagos5;
			END IF;

			--TI-CO-DELQ(1): Indicador de Morosidad o de no pago. Numero de meses vencidos del ciclo actual (corte o mesiversario correspondiente). Topado a 9 como maximo. 
			--CICLO ACTUAL
			IF iNumvencidosCobCH IS NULL THEN LET cNumvencidosCob = '-1'; END IF;
			
			IF iNumvencidosCobCH = 0 OR iNumvencidosCobCH = '' OR cNumvencidosCob = '-1' THEN
				LET vTI_CO_DELQ_1 = 0;
			ELSE
				IF iNumvencidosCobCH >= 9 THEN 
					LET vTI_CO_DELQ_1 = 9;
				ELSE
					LET vTI_CO_DELQ_1 = iNumvencidosCobCH;
				END IF;
			END IF; 
			
			--TI-CO-MTHLY-INTEREST(1): El monto de los intereses cargados en la cuenta durante el periodo. 		-		CICLO ACTUAL
			IF dIntMesCobCH IS NULL THEN LET cIntMesCob = '-1'; END IF;
			
			IF dIntMesCobCH = '' OR cIntMesCob = '-1' THEN
				LET vTI_CO_MTHLY_INTEREST_1 = 0;
			ELSE
				LET vTI_CO_MTHLY_INTEREST_1 = dIntMesCobCH;
			END IF; 
			
			--TI-CO-MTHLY-FEES(1):Total de comisiones cargadas durante el periodo. 		- 		No hay comisiones para Plazo (LN).		-		CICLO ACTUAL
			IF vTipo_prod = 'REV' THEN
				-- Comision por apertura (no se tiene actualmente) : Comision por falta de pago (no se tiene actualmente) : Otras comisiones (no se tiene actualmente)			
				-- Disposicion efectivo : Comision anual. Se tiene solamente para Oro y Platino.
				IF dComisionCobCH IS NULL THEN LET cComisionCob = '-1'; END IF;
				
				IF cComisionCob = '-1' OR dComisionCobCH = '' OR dComisionCobCH = 0 THEN
					LET vTI_CO_MTHLY_FEES_1 = 0;
				ELSE	
					LET vTI_CO_MTHLY_FEES_1 = dComisionCobCH;
				END IF;			
			--NO HAY COMISIONES PARA PRODUCTOS A PLAZO
			ELIF vTipo_prod = 'CRD' THEN
				LET vTI_CO_MTHLY_FEES_1 = 0;
			END IF;
					
			--TI-CO-DELQ(2): Indicador de Morosidad o de no pago. Numero de meses vencidos del ciclo actual(corte o mesiversario correspondiente). Topado a 9 como maximo. 	-	Index
			--Ciclo actual - 1
			IF iMesMoraCob1 IS NULL THEN LET cMesMoraCob1 = '-1'; END IF;
			
			IF iMesMoraCob1 = '' OR iMesMoraCob1 = 0 OR cMesMoraCob1 = '-1' THEN
				LET vTI_CO_DELQ_2 = 0;
			ELSE
				IF iMesMoraCob1 >= 9 THEN
					LET vTI_CO_DELQ_2 = 9;
				ELSE
					LET vTI_CO_DELQ_2 = iMesMoraCob1;
				END IF;
			END IF; 
			
			--TI-CO-MTHLY-INTEREST(2): El monto de los intereses cargados en la cuenta durante el periodo. 					Ciclo actual - 1    	 	-		Index
			IF dIntMesCob1 IS NULL THEN LET cIntMesCob1 = '-1'; END IF;
			
			IF dIntMesCob1 = '' OR dIntMesCob1 = 0 OR cIntMesCob1 = '-1' THEN
				LET vTI_CO_MTHLY_INTEREST_2 = 0;
			ELSE
				LET vTI_CO_MTHLY_INTEREST_2 = dIntMesCob1;
			END IF; 
	--AQUI		
			--TI-CO-MTHLY-FEES(2): Total de comisiones cargadas durante el periodo.  										Ciclo actual - 1  
			IF vTipo_prod = 'REV' THEN
				IF dComisionCob1 IS NULL THEN LET cComisionCob1 = '-1'; END IF;
				
				IF dComisionCob1 = ''  OR dComisionCob1 = 0 OR cComisionCob1 = '-1' THEN
					LET vTI_CO_MTHLY_FEES_2 = 0;
				ELSE
					LET vTI_CO_MTHLY_FEES_2 = dComisionCob1;
				END IF;			
			ELIF vTipo_prod = 'CRD' THEN
				LET vTI_CO_MTHLY_FEES_2 = 0;
			END IF;
			
			--TI-CO-DELQ(3): Indicador de Morosidad o de no pago. Numero de meses vencidos del ciclo actual (corte o mesiversario correspondiente). Topado a 9 como maximo. 
			--Ciclo actual - 2		
			IF iMesMoraCob2 IS NULL THEN LET cMesMoraCob2 = '-1'; END IF;
			
			IF iMesMoraCob2 = '' OR iMesMoraCob2 = 0 OR cMesMoraCob2 = '-1' THEN
				LET vTI_CO_DELQ_3 = 0;
			ELSE
				IF iMesMoraCob2 >= 9 THEN
					LET vTI_CO_DELQ_3 = 9;
				ELSE
					LET vTI_CO_DELQ_3 = iMesMoraCob2;
				END IF;
			END IF; 

			--TI-CO-MTHLY-INTEREST(3): El monto de los intereses cargados en la cuenta durante el periodo. 
			IF dIntMesCob2 IS NULL THEN LET cIntMesCob2='-1'; END IF;
			
			IF dIntMesCob2 = '' OR dIntMesCob2 = 0 OR cIntMesCob2 ='-1' THEN
				LET vTI_CO_MTHLY_INTEREST_3 = 0;
			ELSE
				LET vTI_CO_MTHLY_INTEREST_3 = dIntMesCob2;
			END IF; 
			
			--TI-CO-MTHLY-FEES(3):Total de comisiones cargadas durante el periodo.
			IF vTipo_prod = 'REV' THEN
				IF dComisionCob2 IS NULL THEN LET cComisionCob2 = '-1'; END IF;
				
				IF dComisionCob2 = '' OR dComisionCob2 = 0 OR cComisionCob2 = '-1'  THEN
					LET vTI_CO_MTHLY_FEES_3 = 0;
				ELSE
					LET vTI_CO_MTHLY_FEES_3 = dComisionCob2;
				END IF;			
			ELIF vTipo_prod = 'CRD' THEN
				LET vTI_CO_MTHLY_FEES_3 = 0;
			END IF;
			
			--TI-CO-DELQ(4): Indicador de Morosidad o de no pago. Numero de meses vencidos del ciclo actual (corte o mesiversario correspondiente). Topado a 9 como maximo. 
			IF iMesMoraCob3 IS NULL THEN LET cMesMoraCob3 = '-1'; END IF;
			
			IF iMesMoraCob3 = '' OR iMesMoraCob3 = 0 OR cMesMoraCob3 = '-1'THEN
				LET vTI_CO_DELQ_4 = 0;
			ELSE
				IF iMesMoraCob3 >= 9 THEN
					LET vTI_CO_DELQ_4 = 9;
				ELSE
					LET vTI_CO_DELQ_4 = iMesMoraCob3;
				END IF;
			END IF;  
			
			--TI-CO-MTHLY-INTEREST(4): El monto de los intereses cargados en la cuenta durante el periodo. 
			IF dIntMesCob3 IS NULL THEN LET cIntMesCob3 ='-1'; END IF;
			
			IF dIntMesCob3 = '' OR dIntMesCob3 = 0 OR cIntMesCob3 = '-1' THEN
				LET vTI_CO_MTHLY_INTEREST_4 = 0;
			ELSE
				LET vTI_CO_MTHLY_INTEREST_4 = dIntMesCob3;
			END IF; 
			
			--TI-CO-MTHLY-FEES(4):Total de comisiones cargadas durante el periodo.
			IF vTipo_prod = 'REV' THEN
				IF dComisionCob3 IS NULL THEN LET cComisionCob3 = '-1'; END IF;
			
				IF dComisionCob3 = '' OR dComisionCob3 = 0 OR cComisionCob3 = '-1'  THEN
					LET vTI_CO_MTHLY_FEES_4 = 0;
				ELSE
					LET vTI_CO_MTHLY_FEES_4 = dComisionCob3;
				END IF;			
			ELIF vTipo_prod = 'CRD' THEN
				LET vTI_CO_MTHLY_FEES_4 = 0;
			END IF;
			
			--TI-CO-DELQ(5): Indicador de Morosidad o de no pago. Numero de meses vencidos del ciclo actual (corte o mesiversario correspondiente). Topado a 9 como maximo. 
			IF iMesMoraCob4 IS NULL THEN LET cMesMoraCob4 = '-1'; END IF;
			
			IF iMesMoraCob4 = '' OR iMesMoraCob4 = 0 OR cMesMoraCob4 = '-1' THEN
				LET vTI_CO_DELQ_5 = 0;
			ELSE
				IF iMesMoraCob4 >= 9 THEN
					LET vTI_CO_DELQ_5 = 9;
				ELSE
					LET vTI_CO_DELQ_5 = iMesMoraCob4;
				END IF;
			END IF;  
			
			--TI-CO-MTHLY-INTEREST(5): El monto de los intereses cargados en la cuenta durante el periodo. 
			IF dIntMesCob4 IS NULL THEN LET cIntMesCob4 = '-1'; END IF;
					
			IF dIntMesCob4 = '' OR dIntMesCob4 = 0 OR cIntMesCob4 = '-1' THEN
				LET vTI_CO_MTHLY_INTEREST_5 = 0;
			ELSE
				LET vTI_CO_MTHLY_INTEREST_5 = dIntMesCob4;
			END IF; 
			
			--TI-CO-MTHLY-FEES(5): Total de comisiones cargadas durante el periodo.
			IF vTipo_prod = 'REV' THEN
				IF dComisionCob4 IS NULL THEN LET cComisionCob4 = '-1'; END IF;
				
				IF dComisionCob4 = '' OR dComisionCob4 = 0 OR cComisionCob4 = '-1'  THEN
					LET vTI_CO_MTHLY_FEES_5 = 0;
				ELSE
					LET vTI_CO_MTHLY_FEES_5 = dComisionCob4;
				END IF;			
			ELIF vTipo_prod = 'CRD' THEN
				LET vTI_CO_MTHLY_FEES_5 = 0;
			END IF;
			
			--TI-CO-DELQ(6): Indicador de Morosidad o de no pago. Numero de meses vencidos del ciclo actual (corte o mesiversario correspondiente). Topado a 9 como maximo. 
			IF iMesMoraCob5 IS NULL THEN LET cMesMoraCob5 = '-1'; END IF;
			
			IF iMesMoraCob5 = '' OR iMesMoraCob5 = 0 OR cMesMoraCob5 = '-1' THEN
				LET vTI_CO_DELQ_6 = 0;
			ELSE
				IF iMesMoraCob5 >= 9 THEN
					LET vTI_CO_DELQ_6 = 9;
				ELSE
					LET vTI_CO_DELQ_6 = iMesMoraCob5;
				END IF;
			END IF;  
			
			--TI-CO-MTHLY-INTEREST(6):El monto de los intereses cargados en la cuenta durante el periodo. 
			IF dIntMesCob5 IS NULL THEN LET cIntMesCob5 = '-1'; END IF;
			
			IF dIntMesCob5 = '' OR dIntMesCob5 = 0 OR cIntMesCob5 = '-1' THEN
				LET vTI_CO_MTHLY_INTEREST_6 = 0;
			ELSE
				LET vTI_CO_MTHLY_INTEREST_6 = dIntMesCob5;
			END IF; 
			
			--TI-CO-MTHLY-FEES(6): Total de comisiones cargadas durante el periodo.
			IF vTipo_prod = 'REV' THEN
				IF dComisionCob5 IS NULL THEN LET cComisionCob5 = '-1'; END IF;
				
				IF dComisionCob5 = '' OR dComisionCob5 = 0 OR cComisionCob5 = '-1'  THEN
					LET vTI_CO_MTHLY_FEES_6 = 0;
				ELSE
					LET vTI_CO_MTHLY_FEES_6 = dComisionCob5;	
				END IF;
			ELIF vTipo_prod = 'CRD' THEN
				LET vTI_CO_MTHLY_FEES_6 = 0;
			END IF;
			
			--TI-CO-DELQ(7): Indicador de Morosidad o de no pago. Numero de meses vencidos del ciclo actual (corte o mesiversario correspondiente). Topado a 9 como maximo. 
			IF iMesMoraCob6 IS NULL THEN LET cMesMoraCob6 = '-1'; END IF;
			
			IF iMesMoraCob6 = '' OR iMesMoraCob6 = 0 OR cMesMoraCob6 = '-1' THEN
				LET vTI_CO_DELQ_7 = 0;
			ELSE
				IF iMesMoraCob6 >= 9 THEN
					LET vTI_CO_DELQ_7 = 9;
				ELSE
					LET vTI_CO_DELQ_7 = iMesMoraCob6;
				END IF;
			END IF;  
			
			--TI-CO-MTHLY-INTEREST(7): El monto de los intereses cargados en la cuenta durante el periodo. 
			IF dIntMesCob6 IS NULL THEN LET cIntMesCob6 = '-1'; END IF;
			
			IF dIntMesCob6 = '' OR dIntMesCob6 = 0 OR cIntMesCob6 = '-1' THEN
				LET vTI_CO_MTHLY_INTEREST_7 = 0;
			ELSE
				LET vTI_CO_MTHLY_INTEREST_7 = dIntMesCob6;
			END IF; 

			--TI-CO-MTHLY-FEES(7): Total de comisiones cargadas durante el periodo.
			IF vTipo_prod = 'REV' THEN
				IF dComisionCob6 IS NULL THEN LET cComisionCob6 = '-1'; END IF;
				
				IF dComisionCob6 = '' OR dComisionCob6 = 0 OR cComisionCob6 = '-1'  THEN
					LET vTI_CO_MTHLY_FEES_7 = 0;
				ELSE
					LET vTI_CO_MTHLY_FEES_7 = dComisionCob6;
				END IF;			
			ELIF vTipo_prod = 'CRD' THEN
				LET vTI_CO_MTHLY_FEES_7 = 0;
			END IF;
			
			--TI-CO-DELQ(8): Indicador de Morosidad o de no pago. Numero de meses vencidos del ciclo actual (corte o mesiversario correspondiente). Topado a 9 como maximo. 
			IF iMesMoraCob7 IS NULL THEN LET cMesMoraCob7 = '-1'; END IF;
			
			IF iMesMoraCob7 = '' OR iMesMoraCob7 = 0 OR cMesMoraCob7 = '-1' THEN
				LET vTI_CO_DELQ_8 = 0;
			ELSE
				IF iMesMoraCob7 >= 9 THEN
					LET vTI_CO_DELQ_8 = 9;
				ELSE
					LET vTI_CO_DELQ_8 = iMesMoraCob7;
				END IF;
			END IF;  
			
			--TI-CO-MTHLY-INTEREST(8):El monto de los intereses cargados en la cuenta durante el periodo. 
			IF dIntMesCob7 IS NULL THEN LET cIntMesCob7 = '-1'; END IF;
			
			IF dIntMesCob7 = '' OR dIntMesCob7 = 0 OR cIntMesCob7 = '-1' THEN
				LET vTI_CO_MTHLY_INTEREST_8 = 0;
			ELSE
				LET vTI_CO_MTHLY_INTEREST_8 = dIntMesCob7;
			END IF; 
			
			--TI-CO-MTHLY-FEES(8):Total de comisiones cargadas durante el periodo.
			IF vTipo_prod = 'REV' THEN
				IF dComisionCob7 IS NULL THEN LET cComisionCob7 = '-1'; END IF;
				
				IF dComisionCob7 = '' OR dComisionCob7 = 0 OR cComisionCob7 = '-1'  THEN
					LET vTI_CO_MTHLY_FEES_8 = 0;
				ELSE
					LET vTI_CO_MTHLY_FEES_8 = dComisionCob7;
				END IF;			
			ELIF vTipo_prod = 'CRD' THEN
				LET vTI_CO_MTHLY_FEES_8 = 0;
			END IF;
			
			--TI-CO-DELQ(9):Indicador de Morosidad o de no pago. Numero de meses vencidos del ciclo actual (corte o mesiversario correspondiente). Topado a 9 como maximo. 
			IF iMesMoraCob8 IS NULL THEN LET cMesMoraCob8 = '-1'; END IF;
			
			IF iMesMoraCob8 = '' OR iMesMoraCob8 = 0 OR cMesMoraCob8 = '-1' THEN
				LET vTI_CO_DELQ_9 = 0;
			ELSE
				IF iMesMoraCob8 >= 9 THEN
					LET vTI_CO_DELQ_9 = 9;
				ELSE
					LET vTI_CO_DELQ_9 = iMesMoraCob8;
				END IF;
			END IF;  
			
			--TI-CO-MTHLY-INTEREST(9):El monto de los intereses cargados en la cuenta durante el periodo. 
			IF dIntMesCob8 IS NULL THEN LET cIntMesCob8 = '-1'; END IF;
			
			IF dIntMesCob8 = '' OR dIntMesCob8 = 0 OR cIntMesCob8 = '-1' THEN
				LET vTI_CO_MTHLY_INTEREST_9 = 0;
			ELSE
				LET vTI_CO_MTHLY_INTEREST_9 = dIntMesCob8;
			END IF; 
			
			--TI-CO-MTHLY-FEES(9):Total de comisiones cargadas durante el periodo.
			IF vTipo_prod = 'REV' THEN
				IF dComisionCob8 IS NULL THEN LET cComisionCob8 = '-1'; END IF;
				
				IF dComisionCob8 = '' OR dComisionCob8 = 0 OR cComisionCob8 = '-1'  THEN
					LET vTI_CO_MTHLY_FEES_9 = 0;
				ELSE
					LET vTI_CO_MTHLY_FEES_9 = dComisionCob8;
				END IF;			
			ELIF vTipo_prod = 'CRD' THEN
				LET vTI_CO_MTHLY_FEES_9 = 0;
			END IF;
			
			--TI-CO-DELQ(10):Indicador de Morosidad o de no pago. Numero de meses vencidos del ciclo actual (corte o mesiversario correspondiente). Topado a 9 como maximo. 
			IF iMesMoraCob9 IS NULL THEN LET cMesMoraCob9 = '-1'; END IF;
			
			IF iMesMoraCob9 = '' OR iMesMoraCob9 = 0 OR cMesMoraCob9 = '-1' THEN
				LET vTI_CO_DELQ_10 = 0;
			ELSE
				IF iMesMoraCob9 >= 9 THEN
					LET vTI_CO_DELQ_10 = 9;
				ELSE
					LET vTI_CO_DELQ_10 = iMesMoraCob9;
				END IF;
			END IF;  
			
			--TI-CO-MTHLY-INTEREST(10):El monto de los intereses cargados en la cuenta durante el periodo. 
			IF dIntMesCob9 IS NULL THEN LET cIntMesCob9 = '-1'; END IF;
					
			IF dIntMesCob9 = '' OR dIntMesCob9 = 0 OR cIntMesCob9 = '-1' THEN
				LET vTI_CO_MTHLY_INTEREST_10 = 0;
			ELSE
				LET vTI_CO_MTHLY_INTEREST_10 = dIntMesCob9;
			END IF; 
			
			--TI-CO-MTHLY-FEES(10): Total de comisiones cargadas durante el periodo.
			IF vTipo_prod = 'REV' THEN
				IF dComisionCob9 IS NULL THEN LET cComisionCob9 = '-1'; END IF;
				
				IF dComisionCob9 = '' OR dComisionCob9 = 0 OR cComisionCob9 = '-1'  THEN
					LET vTI_CO_MTHLY_FEES_10 = 0;
				ELSE
					LET vTI_CO_MTHLY_FEES_10 = dComisionCob9;	
				END IF;
			ELIF vTipo_prod = 'CRD' THEN
				LET vTI_CO_MTHLY_FEES_10 = 0;
			END IF;
			
			--TI-CO-DELQ(11):Indicador de Morosidad o de no pago. Numero de meses vencidos del ciclo actual (corte o mesiversario correspondiente). Topado a 9 como maximo. 
			IF iMesMoraCob10 IS NULL THEN LET cMesMoraCob10 = '-1'; END IF;
			
			IF iMesMoraCob10 = ''  OR iMesMoraCob10 = 0 OR cMesMoraCob10 = '-1'  THEN
				LET vTI_CO_DELQ_11 = 0;
			ELSE
				IF iMesMoraCob10 >= 9 THEN
					LET vTI_CO_DELQ_11 = 9;
				ELSE
					LET vTI_CO_DELQ_11 = iMesMoraCob10;
				END IF;
			END IF;  
			
			--TI-CO-MTHLY-INTEREST(11):El monto de los intereses cargados en la cuenta durante el periodo. 
			IF dIntMesCob10 IS NULL THEN LET cIntMesCob10 = '-1'; END IF;
			
			IF dIntMesCob10 = '' OR dIntMesCob10 = '' OR cIntMesCob10 = '-1' THEN
				LET vTI_CO_MTHLY_INTEREST_11 = 0;
			ELSE
				LET vTI_CO_MTHLY_INTEREST_11 = dIntMesCob10;
			END IF; 
			
			--TI-CO-MTHLY-FEES(11): Total de comisiones cargadas durante el periodo.
			IF vTipo_prod = 'REV' THEN
				IF dComisionCob10 IS NULL THEN LET cComisionCob10 = '-1'; END IF;
				
				IF dComisionCob10 = '' OR dComisionCob10= 0 OR cComisionCob10 = '-1'  THEN
					LET vTI_CO_MTHLY_FEES_11 = 0;
				ELSE
					LET vTI_CO_MTHLY_FEES_11 = dComisionCob10;
				END IF;			
			ELIF vTipo_prod = 'CRD' THEN
				LET vTI_CO_MTHLY_FEES_11 = 0;
			END IF;
			
			--TI-CO-DELQ(12):Indicador de Morosidad o de no pago. Numero de meses vencidos del ciclo actual (corte o mesiversario correspondiente). Topado a 9 como maximo. 
			IF iMesMoraCob11 IS NULL THEN LET cMesMoraCob11 = '-1'; END IF;
			
			IF iMesMoraCob11 = '' OR iMesMoraCob11 = 0 OR cMesMoraCob11 = '-1' THEN
				LET vTI_CO_DELQ_12 = 0;
			ELSE
				IF iMesMoraCob11 >= 9 THEN
					LET vTI_CO_DELQ_12 = 9;
				ELSE
					LET vTI_CO_DELQ_12 = iMesMoraCob11;
				END IF;
			END IF;  
			
			--TI-CO-MTHLY-INTEREST(12): El monto de los intereses cargados en la cuenta durante el periodo. 
			IF dIntMesCob11 IS NULL THEN LET cIntMesCob11 = '-1'; END IF;
			
			IF dIntMesCob11 = '' OR dIntMesCob11 = 0 OR cIntMesCob11 = '-1' THEN
				LET vTI_CO_MTHLY_INTEREST_12 = 0;
			ELSE
				LET vTI_CO_MTHLY_INTEREST_12 = dIntMesCob11;
			END IF; 
			
			--TI-CO-MTHLY-FEES(12): Total de comisiones cargadas durante el periodo.
			IF vTipo_prod = 'REV' THEN
				IF dComisionCob11 IS NULL THEN LET cComisionCob11 = '-1'; END IF;
				
				IF dComisionCob11 = '' OR dComisionCob11 = 0 OR cComisionCob11 = '-1'  THEN
					LET vTI_CO_MTHLY_FEES_12 = 0;
				ELSE
					LET vTI_CO_MTHLY_FEES_12 = dComisionCob11;
				END IF;			
			ELIF vTipo_prod = 'CRD' THEN
				LET vTI_CO_MTHLY_FEES_12 = 0;
			END IF;
		
		END IF;   -- Es fecha de corte?   FIN

		--TI-CO-REMAINING-TERM: El plazo restante de la cuenta (en meses). En el caso de creditos revolventes enviar +000.
		IF vTipo_prod = 'REV' THEN
			LET vTI_CO_REMAINING_TERM = 0;
		ELIF vTipo_prod = 'CRD' THEN
			--SELECT ROUND(months_between(fecha_vencim,vFechahoy)) INTO iPlazoRestCob FROM bdicred:sd_maecredcrd where num_credito=cNumCredCob;
			
			let iPlazoRestCob = ROUND(bdicred:months_between(dFechaVencOrigCob,vFechahoy));
			
		--	IF nvl(cPlazoCob,'') <> '' or nvl(cPlazoCob,'') = ''  THEN
		--	IF iPlazoCob IS NULL THEN LET cPlazoCob = '-1'; END IF;
		--	IF iPlazoRestCob IS NULL THEN LET cPlazoRestCob  = '-1'; END IF;
			
		--	IF (cPlazoCob = '' OR iPlazoCob = '' OR iPlazoCob = 0) OR (cPlazoRestCob = '-1' OR iPlazoRestCob = '' OR iPlazoRestCob <= 0) THEN
			--IF iPlazoRestCob = '' OR iPlazoRestCob <= 0 THEN
			IF nvl(iPlazoRestCob,'') <> '' or nvl(iPlazoRestCob,'') = '' THEN
				LET vTI_CO_REMAINING_TERM = 0;
			ELSE
				LET vTI_CO_REMAINING_TERM = iPlazoRestCob;
			END IF; 
		END IF;

		--TI-CO-ORIGINAL-LOAN-AMT: Para prestamos a plazo el monto original del prestamos.
		-- 						   Para prestamos revolventes el limite de credito original.
		IF cMontoOtorgadoCob = '-1' OR dMontoOtorgadoCob = '' OR dMontoOtorgadoCob = 0 THEN 
			LET vTI_CO_ORIGINAL_LOAN_AMT = 0; 
		ELSE			
			LET vTI_CO_ORIGINAL_LOAN_AMT = dMontoOtorgadoCob; 
		END IF;
		
		--TI-CO-MANUAL-HANDLING-STATUS: Identificador de situacion especial:
		--0 - No tiene alguna marca de situacion especial HOY.	|	1 - Tiene alguna marca de situacion especial HOY.	|	2 - Se quita la situacion especial HOY.
		--SELECT MAX(fchalta) INTO dFechaSitCob FROM bdisitesp:"informix".se_ctessitespcred WHERE empresa = vEmpresa AND numcte = cNumCredCob;
		/*SELECT MAX(fchalta) INTO dFechaSitCob 
		  FROM bdisitesp:"informix".se_ctessitespcred 
		 WHERE numcte = cNumCteCob; 
		
		IF nvl(dFechaSitCob,'') = '' then
			LET vTI_CO_MANUAL_HANDLING_STATUS = 0;
		elif dFechaSitCob >= vFechahoy then
			LET vTI_CO_MANUAL_HANDLING_STATUS = 1;
		ELSE
			LET vTI_CO_MANUAL_HANDLING_STATUS = 2;
		END IF;
		*/
		
		/*IF dFechaSitCob	IS NULL THEN LET cFechaSitCob = '-1'; END IF;
		
		IF cFechaSitCob = '-1' OR dFechaSitCob = '' THEN 
			LET vTI_CO_MANUAL_HANDLING_STATUS = 0;
		ELIF dFechaSitCob >= vFechahoy THEN
			LET vTI_CO_MANUAL_HANDLING_STATUS = 1;
		ELSE
			LET vTI_CO_MANUAL_HANDLING_STATUS = 2;
		END IF;*/
			
		--TI-CO-CONTACT-MADE-IND: 0: Contacto no realizado	|	1: Contacto realizado	|	2: Error de contacto
		--SELECT limit 1 finllamada INTO iFinLlamadaCob FROM  bdicobranza:cb_cat_movimientos  WHERE cliente = cNumCteCob AND fechahorallamada=(SELECT MAX(fechahorallamada) FROM  bdicobranza:cb_cat_movimientos  WHERE cliente = cNumCteCob);
		
		SELECT limit 1 a.finllamada INTO iFinLlamadaCob 
		  FROM bdicobranza:cb_cat_movimientos a
		 WHERE a.cliente = cNumCteCob 
		   AND a.fechahorallamada = (SELECT MAX(fechahorallamada) 
		                             FROM bdicobranza:cb_cat_movimientos
									WHERE cliente = cNumCteCob);
		
		
		--IF iFinLlamadaCob IS NULL THEN LET cFinLlamadaCob = '-1'; END IF;
		
		--IF iFinLlamadaCob = 0 OR iFinLlamadaCob = '' OR cFinLlamadaCob = '-1' THEN 
		IF NVL(iFinLlamadaCob,0) = 0  THEN 
			LET vTI_CO_CONTACT_MADE_IND = 0;
		ELIF iFinLlamadaCob IN (1,2,3,4,5,19) THEN
			LET vTI_CO_CONTACT_MADE_IND = 1;
		ELIF iFinLlamadaCob IN (6,7,11,8,9,10,12,13,14,15,16,17,18,21,33) THEN 
			LET vTI_CO_CONTACT_MADE_IND = 2;
		END IF;
		
		--TI-CO-USR-DF-COLL-AMT: Pago Minimo
		IF dPagoMinimoCob IS NULL THEN LET cPagoMinimoCob = '-1'; END IF;
			
			IF cPagoMinimoCob = '-1' OR dPagoMinimoCob = '' OR dPagoMinimoCob = 0 THEN 
				LET vTI_CO_USR_DF_COLL_AMT = 0;
			ELSE
				LET vTI_CO_USR_DF_COLL_AMT = dPagoMinimoCob;
			END IF;
		/* --- MOVERLO AL PRINCIPIO
		--TI-CO-USR-DF-WORSE-TRIGGER1: +000000000 - El email esta valido.	|	+000000001 - email invalido identificado HOY.
		 --SELECT LIMIT 1 valido INTO cValEmailCob FROM bdinteg:si_correos where numcte = cNumCteCob AND fecha_hora=(select max(fecha_hora) from bdinteg:si_correos where numcte = cNumCteCob );
        
		SELECT LIMIT 1 valido INTO cValEmailCob 
		   FROM bdinteg:si_correos 
		  WHERE numcte = cNumCteCob; 
		    --AND secuencia = (select max(secuencia) from bdinteg:si_correos where numcte = cNumCteCob );
		
        --IF cValEmailCob IS NOT NULL OR nvl(cValEmailCob,'') <>'' THEN
		IF nvl(cValEmailCob,'') <> '' or cValEmailCob <> '' THEN
			IF cValEmailCob = '1' THEN 
				LET vTI_CO_USR_DF_WORSE_TRIGGER1 = 1;  
			ELSE	
				LET vTI_CO_USR_DF_WORSE_TRIGGER1 = 0; 
			END IF;
		ELSE
			LET vTI_CO_USR_DF_WORSE_TRIGGER1 = 0;  
		END IF;
		*/
		
		--TI-CO-USR-DF-WORSE-TRIGGER2: 0 - No hubo cambio cuenta lider HOY		|		1 - Hubo cambio de cuenta lider HOY		- 	NO APLICA
		LET vTI_CO_USR_DF_WORSE_TRIGGER2 = 0;
		
		--TI-CO-USR-DF-WORSE-TRIGGER3: el cliente tiene o no tiene trabajo:
		--+000000000 - No fue indentificado HOY que el cliente no tiene trabajo.		+000000001 - Fue identificado HOY que el cliente no tiene trabajo.
		--SELECT profesion INTO iProfesion FROM bdinteg:si_ctepf WHERE numcte = cNumCteCob;
		SELECT profesion INTO cProfesion FROM bdinteg:si_ctepf WHERE numcte = cNumCteCob;
		
		IF NVL(cProfesion,'') <> '' or cProfesion <> '' THEN
			if cProfesion IN ('05','06','12','15','16') then
		       LET vTI_CO_USR_DF_WORSE_TRIGGER3 = 1;
			end if;   
		ELSE
		    LET vTI_CO_USR_DF_WORSE_TRIGGER3 = 0;
		END IF;
		
		   
		/*IF iProfesion IN (5,6,12,15,16) THEN
			LET vTI_CO_USR_DF_WORSE_TRIGGER3 = 1;
		ELSE
			LET vTI_CO_USR_DF_WORSE_TRIGGER3 = 0;
		END IF;
		*/
		
		--TI-CO-USR-DF-BETTER-TRIGGER1: Valida si tiene Email o no pero NO DIARIO.
		--+00000000 - Email continua invalido.		|			+000000001 - Email valido identificado HOY.
			LET vTI_CO_USR_DF_BETTER_TRIGGER1 = vTI_CO_USR_DF_WORSE_TRIGGER1;

		---MACF Bloque movido de arriba para aquí	(23 cols)
		--PROCESO: TI-CO-BHVR-SCORE: Se inicializa en+0000000 y posteriormente se toma el valor del campo PP20-ALIGNED-SCORE del layout de salida para futuras llamadas de TRIAD. 	-	REVISION USUARIO
		SELECT limit 1 out_cu_customer_id, out_aligned_score, out_scrd_id, out_bar_factor2, out_coll_stgy_id, out_coll_scen_id, out_coll_action_ctr,
		 out_coll_date_bill_eqv, out_date_first_colls_da, out_coll_balance_initial, out_coll_balance_actual, out_coll_ooo_type, out_coll_delq, out_coll_amt_arrears, 
		 out_coll_amt_excess_ovlm, out_coll_balance, out_coll_limit, out_coll_ptp, out_coll_telephone_ind, out_coll_address_ind, out_coll_block_code,
		 out_coll_worst_cyc_delq, out_coll_total_ooo_amt
		INTO v_out_cu_customer_id_temp, PR20_ALIGNED_SCORE, PR20_SCRD_ID, PR20_BAR_FACTOR_2, PR20_COLL_STGY_ID, PR20_COLL_SCEN_ID, PR20_COLL_ACTION_CTR,
		     PR20_COLL_DATE_BILL_EQV, PR20_COLL_DATE_BILL_EQV2, PR20_COLL_BALANCE_INITIAL, PR20_COLL_BALANCE_ACTUAL, PR20_COLL_OOO_TYPE, PR20_COLL_CURR_DELQ,
			 PR20_COLL_AMT_ARREARS,
		     PR20_COLL_AMT_EXCESS_OVLM, PR20_COLL_BALANCE, PR20_COLL_LIMIT, PR20_COLL_PTP, PR20_COLL_TELEPHONE_IND, PR20_COLL_ADDRESS_IND, 
			 PR20_COLL_BLOCK_CODE,
		     PR20_COLL_WORST_CYC_DELQ, PR20_COLL_TOTAL_OOO_AMT
		FROM bdicobranza:cb_triad_salida 
		--WHERE out_co_account_id = vNumCredito_salida;
		WHERE num_credito = cNumCredCob;
		  --AND out_co_account_id = vNumCredito_salida;
		
		IF NVL(v_out_cu_customer_id_temp,'') = '' THEN  --poner todas en ceros
			LET vTI_CO_BHVR_SCORE = '+0000000';
			LET vTI_CO_BHVR_SCRD_ID  = '+0000';
			LET vTI_CO_BAR_FACTOR  = '+00000';
			LET vTI_CO_STGY_ID = '+000';
			LET vTI_CO_SCEN_ID = '+0000';
			LET vTI_CO_ACTION_CTR = '0';
			LET vTI_CO_DATE_BILL_EQV = '00000000';
			LET vTI_CO_DATE_FIRST_COLLS_DA = '00000000';
			LET vTI_CO_COLL_BALANCE_INITIAL = '+000000000';
			LET vTI_CO_COLL_BALANCE_PREV = '+000000000';
			LET vTI_CO_OOO_TYPE_PREV = '0';
			LET vTI_CO_DELQ_PREV = '00';
			LET vTI_CO_AMT_ARREARS_PREV = '+000000000';
			LET vTI_CO_AMT_EXCESS_OVLM_PREV = '+000000000';
			LET vTI_CO_BALANCE_PREV = '+000000000';
			LET vTI_CO_LIMIT_PREV = '+000000000';
			LET vTI_CO_PTP_PREV = '0';
			LET vTI_CO_TELEPHONE_IND_PREV = '0';
			LET vTI_CO_ADDRESS_IND_PREV = '0';
			LET vTI_CO_BLOCK_CODE_PREV = '0000';
			LET vTI_CO_BLOCK_CODE_LAST_REVIEW = '0000';
			LET vTI_CO_WORST_CYC_DELQ_PREV = '00';
			LET vTI_CO_TOTAL_OOO_AMT_PREV = '+000000000';
		else 
		
			IF PR20_ALIGNED_SCORE IS NULL OR PR20_ALIGNED_SCORE = '' OR PR20_ALIGNED_SCORE = '0' THEN		--PENDIENTE
				LET vTI_CO_BHVR_SCORE = '+0000000';   			-- Indica que se inicializa con ceros
			ELSE 
				LET vTI_CO_BHVR_SCORE = PR20_ALIGNED_SCORE; 
			END IF;
			
			--PROCESO: TI-CO-BHVR-SCRD-ID: Se inicializa en +0000 y posteriormente se toma el valor del campo PR20-SCRD-ID del layout de salida para futuras llamadas de TRIAD. 
			IF PR20_SCRD_ID IS NULL OR PR20_SCRD_ID = '' OR PR20_SCRD_ID = '0' THEN							--PENDIENTE
				LET vTI_CO_BHVR_SCRD_ID  = '+0000';   			-- Indica que se inicializa con ceros
			ELSE 
				LET vTI_CO_BHVR_SCRD_ID = PR20_SCRD_ID; 
			END IF;
			
			--PROCESO: TI-CO-BAR-FACTOR: Se inicializa en +00000 y posteriormente se toma el valor del campo PP20-BAR-FACTOR (2) del layout de salida para futuras llamadas de TRIAD. 
			--NOTA: Se copiara dicho campo y se eliminaran los ultimos 3 digitos, de tal manera que la longitud sea 6
			IF PR20_BAR_FACTOR_2 IS NULL OR PR20_BAR_FACTOR_2 = '' OR PR20_BAR_FACTOR_2 = '0' THEN
				LET vTI_CO_BAR_FACTOR  = '+00000';   			-- Indica que se inicializa con ceros
			ELSE 
				LET vTI_CO_BAR_FACTOR = SUBSTR(PR20_BAR_FACTOR_2,1,6);
			END IF;	
			
			--PROCESO: TI-CO-STGY-ID: PR20-COLL-STGY-ID de la ejecucion anterior.
			IF PR20_COLL_STGY_ID IS NULL OR PR20_COLL_STGY_ID = '' OR PR20_COLL_STGY_ID = '0' THEN --PENDIENTE			OJO REVISAR
				LET vTI_CO_STGY_ID = '+000';
			ELSE
				LET vTI_CO_STGY_ID = '+' || PR20_COLL_STGY_ID;		-- NOTA: Se debera anexar al valor tomado el signo +, tal que la longitud sea 4
			END IF;
			
			--PROCESO: TI-CO-SCEN-ID: PR20-COLL-SCEN-ID de la ejecucion anterior.
			IF PR20_COLL_SCEN_ID IS NULL OR PR20_COLL_SCEN_ID = '' OR PR20_COLL_SCEN_ID = '0' THEN --PENDIENTE
				LET vTI_CO_SCEN_ID = '+0000';
			ELSE
				LET vTI_CO_SCEN_ID = '+' || PR20_COLL_SCEN_ID;		-- NOTA: Se debera anexar al valor tomado el signo +, tal que la longitud sea 5
			END IF;
			
			--PROCESO: TI-CO-ACTION-CTR: PR20-COLL-ACTION-CTR de la ejecucion anterior.
			IF PR20_COLL_ACTION_CTR IS NULL OR PR20_COLL_ACTION_CTR = '' OR PR20_COLL_ACTION_CTR = '0' THEN 
				LET vTI_CO_ACTION_CTR = '0';
			ELSE
				LET vTI_CO_ACTION_CTR = PR20_COLL_ACTION_CTR;
			END IF;
		
			--PROCESO: TI-CO-DATE-BILL-EQV: Se inicializa en 00000000 y posteriormente se toma el valor del campo PR20-COLL-DATE-BILL-EQV del layout de salida para futuras llamadas de TRIAD.
			IF PR20_COLL_DATE_BILL_EQV IS NULL OR PR20_COLL_DATE_BILL_EQV = '' OR PR20_COLL_DATE_BILL_EQV = '0' THEN 
				LET vTI_CO_DATE_BILL_EQV = '00000000';
			ELSE
				LET vTI_CO_DATE_BILL_EQV = PR20_COLL_DATE_BILL_EQV;
			END IF;
			
			--PROCESO: TI-CO-DATE-FIRST-COLLS-DA: Se inicializa en 00000000 y posteriormente se toma el valor del campo PR20-COLL-DATE-BILL-EQV del layout de salida para futuras llamadas de TRIAD.
			IF PR20_COLL_DATE_BILL_EQV2 IS NULL OR PR20_COLL_DATE_BILL_EQV2 = '' OR PR20_COLL_DATE_BILL_EQV2 = '0' THEN 
				LET vTI_CO_DATE_FIRST_COLLS_DA = '00000000';
			ELSE
				LET vTI_CO_DATE_FIRST_COLLS_DA = PR20_COLL_DATE_BILL_EQV2;
			END IF;
			
			--PROCESO: TI-CO-COLL-BALANCE-INITIAL: Se inicializa en +000000000 y posteriormente se toma el valor del campo PR20-COLL-BALANCE-INITIAL del layout de salida para futuras llamadas de TRIAD. 
			IF PR20_COLL_BALANCE_INITIAL IS NULL OR PR20_COLL_BALANCE_INITIAL = '' OR PR20_COLL_BALANCE_INITIAL = '0' THEN 
				LET vTI_CO_COLL_BALANCE_INITIAL = '+000000000';
			ELSE
				LET vTI_CO_COLL_BALANCE_INITIAL = PR20_COLL_BALANCE_INITIAL;
			END IF;
			
			--PROCESO: TI-CO-COLL-BALANCE-PREV: Se inicializa en +000000000 y posteriormente se toma el valor del campo PR20-COLL-BALANCE-ACTUAL del layout de salida para futuras llamadas de TRIAD. 
			IF PR20_COLL_BALANCE_ACTUAL IS NULL OR PR20_COLL_BALANCE_ACTUAL = '' OR PR20_COLL_BALANCE_ACTUAL = '0' THEN 
				LET vTI_CO_COLL_BALANCE_PREV = '+000000000';
			ELSE
				LET vTI_CO_COLL_BALANCE_PREV =  PR20_COLL_BALANCE_ACTUAL;
			END IF;

			--PROCESO: TI-CO-OOO-TYPE-PREV: Se inicializa en 0 y posteriormente se toma el valor del campo PR20-COLL-OOO-TYPE del layout de salida para futuras llamadas de TRIAD. 
			IF PR20_COLL_OOO_TYPE IS NULL OR PR20_COLL_OOO_TYPE = '' OR PR20_COLL_OOO_TYPE = '0' THEN 
				LET vTI_CO_OOO_TYPE_PREV = '0';
			ELSE
				LET vTI_CO_OOO_TYPE_PREV = PR20_COLL_OOO_TYPE;
			END IF;

			--PROCESO: TI-CO-DELQ-PREV: Se inicializa en 00 y posteriormente se toma el valor del campo PR20-COLL-CURR-DELQ del layout de salida para futuras llamadas de TRIAD. 
			IF PR20_COLL_CURR_DELQ IS NULL OR PR20_COLL_CURR_DELQ = '' OR PR20_COLL_CURR_DELQ = '0' THEN 
				LET vTI_CO_DELQ_PREV = '00';
			ELSE
				LET vTI_CO_DELQ_PREV = PR20_COLL_CURR_DELQ;
			END IF;

			--PROCESO: TI-CO-AMT-ARREARS-PREV: Se inicializa en +000000000 y posteriormente se toma el valor del campo PR20-COLL-AMT-ARREARS del layout de salida para futuras llamadas de TRIAD. 
			IF PR20_COLL_AMT_ARREARS IS NULL OR PR20_COLL_AMT_ARREARS = '' OR PR20_COLL_AMT_ARREARS = '0' THEN 
				LET vTI_CO_AMT_ARREARS_PREV = '+000000000';
			ELSE
				LET vTI_CO_AMT_ARREARS_PREV = PR20_COLL_AMT_ARREARS;
			END IF;
			
			--PROCESO: TI-CO-AMT-EXCESS-OVLM-PREV: Se inicializa en +000000000 y posteriormente se toma el valor del campo PR20-COLL-AMT-EXCESS-OVLM del layout de salida para futuras llamadas de TRIAD. 
			IF PR20_COLL_AMT_EXCESS_OVLM IS NULL OR PR20_COLL_AMT_EXCESS_OVLM = '' OR PR20_COLL_AMT_EXCESS_OVLM = '0' THEN 
				LET vTI_CO_AMT_EXCESS_OVLM_PREV = '+000000000';
			ELSE
				LET vTI_CO_AMT_EXCESS_OVLM_PREV = PR20_COLL_AMT_EXCESS_OVLM;
			END IF;
			
			--PROCESO: TI-CO-BALANCE-PREV: Se inicializa en +000000000 y posteriormente se toma el valor del campo PR20-COLL-BALANCE del layout de salida para futuras llamadas de TRIAD. 
			IF PR20_COLL_BALANCE IS NULL OR PR20_COLL_BALANCE = '' OR PR20_COLL_BALANCE = '0' THEN 
				LET vTI_CO_BALANCE_PREV = '+000000000';
			ELSE
				LET vTI_CO_BALANCE_PREV = PR20_COLL_BALANCE;
			END IF;

			--PROCESO: TI-CO-LIMIT-PREV: Se inicializa en +000000000 y posteriormente se toma el valor del campo PR20-COLL-LIMIT del layout de salida para futuras llamadas de TRIAD. 
			IF PR20_COLL_LIMIT IS NULL OR PR20_COLL_LIMIT = '' OR PR20_COLL_LIMIT = '0' THEN 
				LET vTI_CO_LIMIT_PREV = '+000000000';
			ELSE
				LET vTI_CO_LIMIT_PREV = PR20_COLL_LIMIT;
			END IF;

			--PROCESO: TI-CO-PTP-PREV: Se inicializa en 0 y posteriormente se toma el valor del campo PR20-COLL-PTP del layout de salida para futuras llamadas de TRIAD. 
			IF PR20_COLL_PTP IS NULL OR PR20_COLL_PTP = '' OR PR20_COLL_PTP = '0' THEN 
				LET vTI_CO_PTP_PREV = '0';
			ELSE
				LET vTI_CO_PTP_PREV = PR20_COLL_PTP;
			END IF;

			--PROCESO: TI-CO-TELEPHONE-IND-PREV: Se inicializa en 0 y posteriormente se toma el valor del campo PR20-COLL-TELEPHONE-IND del layout de salida para futuras llamadas de TRIAD. 
			IF PR20_COLL_TELEPHONE_IND IS NULL OR PR20_COLL_TELEPHONE_IND = '' OR PR20_COLL_TELEPHONE_IND = '0' THEN 
				LET vTI_CO_TELEPHONE_IND_PREV = '0';
			ELSE
				LET vTI_CO_TELEPHONE_IND_PREV = PR20_COLL_TELEPHONE_IND;
			END IF;
			
			--PROCESO: TI-CO-ADDRESS-IND-PREV : Se inicializa en 0 y posteriormente se toma el valor del campo PR20-COLL-ADDRESS-IND del layout de salida para futuras llamadas de TRIAD. 
			IF PR20_COLL_ADDRESS_IND IS NULL OR PR20_COLL_ADDRESS_IND = '' OR PR20_COLL_ADDRESS_IND = '0' THEN 
				LET vTI_CO_ADDRESS_IND_PREV = '0';
			ELSE
				LET vTI_CO_ADDRESS_IND_PREV = PR20_COLL_ADDRESS_IND;
			END IF;		
			
			--PROCESO: TI-CO-BLOCK-CODE-PREV: Se inicializa en 0000 y posteriormente se toma el valor del campo PR20-COLL-BLOCK-CODE del layout de salida para futuras llamadas de TRIAD. 
			--PROCESO: TI-CO-BLOCK-CODE-LAST-REVIEW: Se inicializa en 0000 y posteriormente se toma el valor del campo PR20-COLL-BLOCK-CODE del layout de salida para futuras llamadas de TRIAD. 
			IF PR20_COLL_BLOCK_CODE IS NULL OR PR20_COLL_BLOCK_CODE = '' OR PR20_COLL_BLOCK_CODE = '0' THEN 
				LET vTI_CO_BLOCK_CODE_PREV = '0000';
				LET vTI_CO_BLOCK_CODE_LAST_REVIEW = '0000';
			ELSE
				LET vTI_CO_BLOCK_CODE_PREV = PR20_COLL_BLOCK_CODE;
				LET vTI_CO_BLOCK_CODE_LAST_REVIEW = PR20_COLL_BLOCK_CODE;
			END IF;
			
			--PROCESO: TI-CO-BLOCK-CODE-LAST-REVIEW: Se inicializa en 0000 y posteriormente se toma el valor del campo PR20-COLL-BLOCK-CODE del layout de salida para futuras llamadas de TRIAD. 
			--IF PR20_COLL_BLOCK_CODE IS NULL OR PR20_COLL_BLOCK_CODE = '' OR PR20_COLL_BLOCK_CODE = '0' THEN 
			--	LET vTI_CO_BLOCK_CODE_LAST_REVIEW = '0000';
			--ELSE
			--	LET vTI_CO_BLOCK_CODE_LAST_REVIEW = PR20_COLL_BLOCK_CODE;
			--END IF;
			
			--PROCESO: TI-CO-WORST-CYC-DELQ-PREV: Se inicializa en 00 y posteriormente se toma el valor del campo PR20-COLL-WORST-CYC-DELQ del layout de salida para futuras llamadas de TRIAD. 
			IF PR20_COLL_WORST_CYC_DELQ IS NULL OR PR20_COLL_WORST_CYC_DELQ = '' OR PR20_COLL_WORST_CYC_DELQ = '0' THEN 
				LET vTI_CO_WORST_CYC_DELQ_PREV = '00';
			ELSE
				LET vTI_CO_WORST_CYC_DELQ_PREV = PR20_COLL_WORST_CYC_DELQ;
			END IF;
			
			
			--PROCESO: TI-CO-TOTAL-OOO-AMT-PREV: Se inicializa en +000000000 y posteriormente se toma el valor del campo PR20-COLL-TOTAL-OOO-AMT del layout de salida para futuras llamadas de TRIAD. 
			IF PR20_COLL_TOTAL_OOO_AMT IS NULL OR PR20_COLL_TOTAL_OOO_AMT = '' OR PR20_COLL_TOTAL_OOO_AMT = '0' THEN 
				LET vTI_CO_TOTAL_OOO_AMT_PREV = '+000000000';
			ELSE
				LET vTI_CO_TOTAL_OOO_AMT_PREV = PR20_COLL_TOTAL_OOO_AMT;
			END IF;
		END IF;
		
		--TI-CO-PTP: Estado de la Promesa de pago de la cuenta hoy. Estatus de la promesa de pago (convenio) de la cuenta del dia. 
		SELECT LIMIT 1 flag_pago,activo,NVL(importe,0),NVL(imp_pagado,0) 
		  INTO iValidaP2P, iActivo, dMontoUltConvenio_2, dMontoPagadoUltConvenio_2 
		  FROM bdicobranza:cb_compac 
		 WHERE empresa = vEmpresa AND numcuenta = cNumCredCob;
		
		IF iValidaP2P IS NULL THEN LET cValidaP2P = '-1'; END IF;
		
		LET dMontoUltConvenio = NVL(dMontoUltConvenio_2,0);
		LET dMontoPagadoUltConvenio = NVL(dMontoPagadoUltConvenio_2,0); 
		
		--0 = sin promesa de pago (convenio)
		--IF cValidaP2P = '-1' OR iValidaP2P = '' THEN 
		IF NVL(iValidaP2P,'') = '' THEN 
			LET vTI_CO_PTP = 0;
		--1 = promesa de pago (convenio) activa
		ELIF iActivo = 1 THEN
			LET vTI_CO_PTP = 1;
		--2 = promesa de pago (convenio) cumplida (si el ultimo convenio se cumplio al 100%)
		ELIF iValidaP2P = 1 AND dMontoUltConvenio >= dMontoPagadoUltConvenio THEN
			LET vTI_CO_PTP = 2;
		--3 = promesa rota (si el ultimo convenio no se cumplio al 100%)
		ELIF iValidaP2P = 0 AND dMontoUltConvenio < dMontoPagadoUltConvenio  THEN
			LET vTI_CO_PTP = 3;
		--4 = negativa de pago
		ELIF iValidaP2P = 0 AND dMontoPagadoUltConvenio = '' OR dMontoPagadoUltConvenio = 0 THEN
			LET vTI_CO_PTP = 4;
		END IF;
		
		--LET cNumCredCob=cNumCredCob;
		--let vTI_CO_ACCOUNT_ID=vTI_CO_ACCOUNT_ID;
		
		/*SELECT COUNT(*) into iExisteCuenta
		FROM bdicobranza:"informix".cb_triad_cobranza
		WHERE empresa=vEmpresa AND ti_co_account_id = trim(vTI_CO_ACCOUNT_ID);
		*/
		
		/*SELECT empresa INTO cEmpresa_10
		  FROM bdicobranza:cb_triad_cobranza
		 WHERE ti_co_account_id = vTI_CO_ACCOUNT_ID;
		
		IF NVL(cEmpresa_10,'') <> '' THEN  let iExisteCuenta = 1; END IF;
		--Pasarlo al principio 
		
		*/
	--DEFINE cActualiza_tel           CHAR(1);
	--DEFINE cActualiza_tel_2         CHAR(1);
    --DEFINE cActualiza_email         CHAR(1);
    --DEFINE cActualiza_sitesp        CHAR(1);
	--DEFINE cActualiza_aclaracion    CHAR(1);
	
		--- 1. Actualizar datos de actualización diaria y los que se validan si se actualizaron (tel, cel, sitesp, e-mail, aclaración), los de saldos al corte e históricos tampoco se actualizan aquí
		IF iExisteCuenta > 0 AND (cActualiza_tel='S' OR cActualiza_tel_2 = 'S' OR cActualiza_email = 'S' OR cActualiza_sitesp = 'S' OR cActualiza_aclaracion ='S') THEN
			begin; 	 		
				UPDATE bdicobranza:cb_triad_cobranza	SET ti_co_customer_id = cNumCteCob,    
				  ti_co_status					=	vTI_CO_STATUS, --puede cambiar diario			  
				  ti_co_full_bal_payment_ind 	=	vTI_CO_FULL_BAL_PAYMENT_IND, -- cambia de acuerdo a PM y Sdo Total
				  ti_co_trans_revolve_ind	 	=	vTI_CO_TRANS_REVOLVE_IND, --totalero o no
				  ti_co_telephone_ind			=	vTI_CO_TELEPHONE_IND,
				  --ti_co_address_ind				=	vTI_CO_ADDRESS_IND, -- Dir valida, solo al insertarlo
				  ti_co_sms_ind					= 	vTI_CO_SMS_IND, -- Tel celular
				  ti_co_block_code			 	=	vTI_CO_BLOCK_CODE, -- bloqueo cta solo tdc
				  ti_co_legal_code			 	=	vTI_CO_LEGAL_CODE, -- Aclaración
				  --ti_co_date_billing_cymd	 	=	vTI_CO_DATE_BILLING_CYMD,  
				  --ti_co_date_start_delq		 	=	vTI_CO_DATE_START_DELQ, 
				  ti_co_date_last_debit		 	=	vTI_CO_DATE_LAST_DEBIT, -- ult compra o disp
				  ti_co_date_last_credit	 	=	vTI_CO_DATE_LAST_CREDIT, --fecha ult pago 
				  ti_co_date_last_mon_txn_cym	=	vTI_CO_DATE_LAST_MON_TXN_CYM, -- fecha ult tnx monetaria
				  ti_co_date_last_cash_cym 		=	vTI_CO_DATE_LAST_CASH_CYM, -- fecha ult disp efec
				  --ti_co_date_last_delq_cymd		=	vTI_CO_DATE_LAST_DELQ_CYMD, -- fecha ul vez en mora
				  ti_co_date_last_pur_cym		=	vTI_CO_DATE_LAST_PUR_CYM, -- fecha ult compra
				  ti_co_date_fee_cym			=	vTI_CO_DATE_FEE_CYM,  -- fecha vencim cuotas anuales (oro y platino)
				  --ti_co_date_original_maturity  = 	vTI_CO_DATE_ORIGINAL_MATURITY, -- fecha vencim ori (plazo) solo al insertarse
				  --ti_co_date_current_maturity	=	vTI_CO_DATE_CURRENT_MATURITY, 
				  ti_co_date_prom_brkn_cymd		=	vTI_CO_DATE_PROM_BRKN_CYMD, -- fecha promesa rota(convenio)
				  ti_co_bhvr_score				=	vTI_CO_BHVR_SCORE, -- de cb_triad_salida
				  ti_co_bhvr_scrd_id			=	vTI_CO_BHVR_SCRD_ID, -- de cb_triad_salida
				  ti_co_bar_factor				=	vTI_CO_BAR_FACTOR,  -- de cb_triad_salida
				  ti_co_balance					=	vTI_CO_BALANCE,  -- saldo actual de la cuenta
				  ti_co_limit					=	vTI_CO_LIMIT,  --limite actual de la cuenta
				  --ti_co_cash_balance			=	vTI_CO_CASH_BALANCE, 
				  --ti_co_amt_arrears				=	vTI_CO_AMT_ARREARS, 
				  ti_co_amt_dispute				=	vTI_CO_AMT_DISPUTE,   --monto de aclaracion (ligado al vTI_CO_LEGAL_CODE)
				  ti_co_amt_last_credit			=	vTI_CO_AMT_LAST_CREDIT, -- último pago registrado
				  --ti_co_high_balance_lf			=	vTI_CO_HIGH_BALANCE_LF, 
				  ti_co_num_pymnts_lf			=	vTI_CO_NUM_PYMNTS_LF, -- Num pagos realizados a cuenta (hist disponible)
				  ti_co_num_ptp					=	vTI_CO_NUM_PTP, -- num convenios desde su apertura
				  --ti_co_mthly_balance_1			=	vTI_CO_MTHLY_BALANCE_1,
				  --ti_co_mthly_debits_1			=	vTI_CO_MTHLY_DEBITS_1, 
				  --ti_co_mthly_credits_1			=	vTI_CO_MTHLY_CREDITS_1, 
				  --ti_co_mthly_balance_2			=	vTI_CO_MTHLY_BALANCE_2, 
				  --ti_co_mthly_debits_2			=	vTI_CO_MTHLY_DEBITS_2, 
				  --ti_co_mthly_credits_2			=	vTI_CO_MTHLY_CREDITS_2, 
				  --ti_co_mthly_balance_3			=	vTI_CO_MTHLY_BALANCE_3, 
				  --ti_co_mthly_debits_3			=	vTI_CO_MTHLY_DEBITS_3, 
				  --ti_co_mthly_credits_3			=	vTI_CO_MTHLY_CREDITS_3, 
				  --ti_co_mthly_balance_4			=	vTI_CO_MTHLY_BALANCE_4, 
				  --ti_co_mthly_debits_4			=	vTI_CO_MTHLY_DEBITS_4, 
				  --ti_co_mthly_credits_4			=	vTI_CO_MTHLY_CREDITS_4,
				  --ti_co_mthly_balance_5			=	vTI_CO_MTHLY_BALANCE_5, 
				  --ti_co_mthly_debits_5			=	vTI_CO_MTHLY_DEBITS_5, 
				  --ti_co_mthly_credits_5			=	vTI_CO_MTHLY_CREDITS_5, 
				  --ti_co_mthly_balance_6			=	vTI_CO_MTHLY_BALANCE_6, 
				  --ti_co_mthly_debits_6			=	vTI_CO_MTHLY_DEBITS_6,
				  --ti_co_mthly_credits_6			=	vTI_CO_MTHLY_CREDITS_6, 
				  --ti_co_delq_1					=	vTI_CO_DELQ_1, 
				  --ti_co_mthly_interest_1		= 	vTI_CO_MTHLY_INTEREST_1, 
				  --ti_co_mthly_fees_1			=	vTI_CO_MTHLY_FEES_1, 
				  --ti_co_delq_2					=	vTI_CO_DELQ_2, 
				  --ti_co_mthly_interest_2		=	vTI_CO_MTHLY_INTEREST_2, 
				  --ti_co_mthly_fees_2			=	vTI_CO_MTHLY_FEES_2, 
				  --ti_co_delq_3					=	vTI_CO_DELQ_3, 
				  --ti_co_mthly_interest_3		=	vTI_CO_MTHLY_INTEREST_3,
				  --ti_co_mthly_fees_3			=	vTI_CO_MTHLY_FEES_3, 
				  --ti_co_delq_4					=	vTI_CO_DELQ_4, 
				  --ti_co_mthly_interest_4		=	vTI_CO_MTHLY_INTEREST_4, 
				  --ti_co_mthly_fees_4			=	vTI_CO_MTHLY_FEES_4, 
				  --ti_co_delq_5					=	vTI_CO_DELQ_5, 
				  --ti_co_mthly_interest_5		=	vTI_CO_MTHLY_INTEREST_5, 
				  --ti_co_mthly_fees_5			=	vTI_CO_MTHLY_FEES_5, 
				  --ti_co_delq_6					=	vTI_CO_DELQ_6, 
				  --ti_co_mthly_interest_6		=	vTI_CO_MTHLY_INTEREST_6,  
				  --ti_co_mthly_fees_6			=	vTI_CO_MTHLY_FEES_6, 
				  --ti_co_delq_7					=	vTI_CO_DELQ_7,
				  --ti_co_mthly_interest_7		=	vTI_CO_MTHLY_INTEREST_7, 
				  --ti_co_mthly_fees_7			=	vTI_CO_MTHLY_FEES_7, 
				  --ti_co_delq_8					=	vTI_CO_DELQ_8, 
				  --ti_co_mthly_interest_8		=	vTI_CO_MTHLY_INTEREST_8, 
				  --ti_co_mthly_fees_8			=	vTI_CO_MTHLY_FEES_8,
				  --ti_co_delq_9					=	vTI_CO_DELQ_9, 
				  --ti_co_mthly_interest_9		=	vTI_CO_MTHLY_INTEREST_9,  
				  --ti_co_mthly_fees_9			=	vTI_CO_MTHLY_FEES_9, 
				  --ti_co_delq_10					=	vTI_CO_DELQ_10, 
				  --ti_co_mthly_interest_10		=	vTI_CO_MTHLY_INTEREST_10,
				  --ti_co_mthly_fees_10			=	vTI_CO_MTHLY_FEES_10, 
				  --ti_co_delq_11					=	vTI_CO_DELQ_11, 
				  --ti_co_mthly_interest_11		=	vTI_CO_MTHLY_INTEREST_11, 
				  --ti_co_mthly_fees_11			=	vTI_CO_MTHLY_FEES_11,
				  --ti_co_delq_12					=	vTI_CO_DELQ_12, 
				  --ti_co_mthly_interest_12		=	vTI_CO_MTHLY_INTEREST_12, 
				  --ti_co_mthly_fees_12			=	vTI_CO_MTHLY_FEES_12, 
				  --ti_co_remaining_term			=	vTI_CO_REMAINING_TERM, 
				  --ti_co_original_loan_amt		=	vTI_CO_ORIGINAL_LOAN_AMT, 
				  ti_co_manual_handling_status	=	vTI_CO_MANUAL_HANDLING_STATUS, --Sitesp
				  ti_co_contact_made_ind		=	vTI_CO_CONTACT_MADE_IND, --contaco llamada cob
				  ti_co_usr_df_coll_amt			=	vTI_CO_USR_DF_COLL_AMT, -- PM
				  ti_co_usr_df_worse_trigger1	=	vTI_CO_USR_DF_WORSE_TRIGGER1, -- validac e-mail
				  --ti_co_usr_df_worse_trigger2 	=	vTI_CO_USR_DF_WORSE_TRIGGER2, -- se guarda al insert reg por unica vez con val default
				  ti_co_usr_df_worse_trigger3	=	vTI_CO_USR_DF_WORSE_TRIGGER3, 	--tiene o no trabajo
				  ti_co_usr_df_better_trigger1	=	vTI_CO_USR_DF_BETTER_TRIGGER1, -- relacionado al e-mail 
				  ti_co_stgy_id					=	vTI_CO_STGY_ID,  --de cb_triad_salida
				  ti_co_scen_id					= 	vTI_CO_SCEN_ID,  --de cb_triad_salida
				  ti_co_action_ctr				=	vTI_CO_ACTION_CTR, --de cb_triad_salida
				  ti_co_ptp						=	vTI_CO_PTP,       -- convenio
				  ti_co_date_bill_eqv			=	vTI_CO_DATE_BILL_EQV, --de cb_triad_salida
				  ti_co_date_first_colls_da		= 	vTI_CO_DATE_FIRST_COLLS_DA, --de cb_triad_salida
				  ti_co_coll_balance_initial	=	vTI_CO_COLL_BALANCE_INITIAL, --de cb_triad_salida
				  ti_co_coll_balance_prev		=	vTI_CO_COLL_BALANCE_PREV,   --de cb_triad_salida
				  ti_co_ooo_type_prev			=	vTI_CO_OOO_TYPE_PREV, --de cb_triad_salida
				  ti_co_delq_prev				=	vTI_CO_DELQ_PREV,     --de cb_triad_salida
				  ti_co_amt_arrears_prev		=	vTI_CO_AMT_ARREARS_PREV,  --de cb_triad_salida
				  ti_co_amt_excess_ovlm_prev	=	vTI_CO_AMT_EXCESS_OVLM_PREV, --de cb_triad_salida
				  ti_co_balance_prev			=	vTI_CO_BALANCE_PREV,  --de cb_triad_salida 
				  ti_co_limit_prev				=	vTI_CO_LIMIT_PREV,  --de cb_triad_salida
				  ti_co_ptp_prev				=	vTI_CO_PTP_PREV,    --de cb_triad_salida
				  ti_co_telephone_ind_prev		=	vTI_CO_TELEPHONE_IND_PREV, --de cb_triad_salida
				  ti_co_address_ind_prev		=	vTI_CO_ADDRESS_IND_PREV,   --de cb_triad_salida
				  ti_co_block_code_prev			=	vTI_CO_BLOCK_CODE_PREV,    --de cb_triad_salida
				  ti_co_block_code_last_review	=	vTI_CO_BLOCK_CODE_LAST_REVIEW, --de cb_triad_salida
				  ti_co_worst_cyc_delq_prev		=	vTI_CO_WORST_CYC_DELQ_PREV, --de cb_triad_salida
				  ti_co_total_ooo_amt_prev		=	vTI_CO_TOTAL_OOO_AMT_PREV,  --de cb_triad_salida
				  fecha_proceso					=	vFechahoy
				WHERE empresa=vEmpresa AND ti_co_account_id = cNumCredCob;
			commit;
			LET iContUpd = iContUpd + 1;
		
		--- 2. Actualizar datos de actualización diaria menos los que se validan si se actualizaron (tel, cel, sitesp,e-mail, aclaración) los de saldos al corte e históricos tampoco se actualizan aquí
		ELIF iExisteCuenta > 0 AND (cActualiza_tel='' AND cActualiza_tel_2 = '' AND cActualiza_email = '' AND cActualiza_sitesp = '' AND cActualiza_aclaracion ='') THEN
		
			begin; 	 		
				UPDATE bdicobranza:cb_triad_cobranza	SET ti_co_customer_id = cNumCteCob,    
				  ti_co_status					=	vTI_CO_STATUS, --puede cambiar diario			  
				  ti_co_full_bal_payment_ind 	=	vTI_CO_FULL_BAL_PAYMENT_IND, -- cambia de acuerdo a PM y Sdo Total
				  ti_co_trans_revolve_ind	 	=	vTI_CO_TRANS_REVOLVE_IND, --totalero o no
				  -- ti_co_telephone_ind			=	vTI_CO_TELEPHONE_IND, -- tel casa (NO ACTUALIZAR AQUÍ)
				  --ti_co_address_ind				=	vTI_CO_ADDRESS_IND, -- Dir valida, solo al insertarlo
				  --ti_co_sms_ind					= 	vTI_CO_SMS_IND, -- Tel celular (NO ACTUALIZAR AQUÍ)
				  ti_co_block_code			 	=	vTI_CO_BLOCK_CODE, -- bloqueo cta solo tdc
				  --ti_co_legal_code			 	=	vTI_CO_LEGAL_CODE, -- Aclaración (NO ACTUALIZAR AQUÍ)
				  --ti_co_date_billing_cymd	 	=	vTI_CO_DATE_BILLING_CYMD,  -- Última fecha corte
				  --ti_co_date_start_delq		 	=	vTI_CO_DATE_START_DELQ, -- fecha en la cual inició a estar en mora
				  ti_co_date_last_debit		 	=	vTI_CO_DATE_LAST_DEBIT, -- ult compra o disp
				  ti_co_date_last_credit	 	=	vTI_CO_DATE_LAST_CREDIT, --fecha ult pago 
				  ti_co_date_last_mon_txn_cym	=	vTI_CO_DATE_LAST_MON_TXN_CYM, -- fecha ult tnx monetaria
				  ti_co_date_last_cash_cym 		=	vTI_CO_DATE_LAST_CASH_CYM, -- fecha ult disp efec
				  --ti_co_date_last_delq_cymd		=	vTI_CO_DATE_LAST_DELQ_CYMD, -- fecha ul vez en mora
				  ti_co_date_last_pur_cym		=	vTI_CO_DATE_LAST_PUR_CYM, -- fecha ult compra
				  ti_co_date_fee_cym			=	vTI_CO_DATE_FEE_CYM,  -- fecha vencim cuotas anuales (oro y platino)
				  --ti_co_date_original_maturity  = 	vTI_CO_DATE_ORIGINAL_MATURITY, -- fecha vencim ori (plazo) solo al insertarse
				  --ti_co_date_current_maturity	=	vTI_CO_DATE_CURRENT_MATURITY, 
				  ti_co_date_prom_brkn_cymd		=	vTI_CO_DATE_PROM_BRKN_CYMD, -- fecha promesa rota(convenio)
				  ti_co_bhvr_score				=	vTI_CO_BHVR_SCORE, -- de cb_triad_salida
				  ti_co_bhvr_scrd_id			=	vTI_CO_BHVR_SCRD_ID, -- de cb_triad_salida
				  ti_co_bar_factor				=	vTI_CO_BAR_FACTOR,  -- de cb_triad_salida
				  ti_co_balance					=	vTI_CO_BALANCE,  -- saldo actual de la cuenta
				  ti_co_limit					=	vTI_CO_LIMIT,  --limite actual de la cuenta
				  --ti_co_cash_balance			=	vTI_CO_CASH_BALANCE, 
				  --ti_co_amt_arrears				=	vTI_CO_AMT_ARREARS, 
				  --ti_co_amt_dispute				=	vTI_CO_AMT_DISPUTE,   --monto de aclaracion (ligado al vTI_CO_LEGAL_CODE) (NO ACTUALIZAR AQUÍ)
				  ti_co_amt_last_credit			=	vTI_CO_AMT_LAST_CREDIT, -- último pago registrado
				  --ti_co_high_balance_lf			=	vTI_CO_HIGH_BALANCE_LF, 
				  ti_co_num_pymnts_lf			=	vTI_CO_NUM_PYMNTS_LF, -- Num pagos realizados a cuenta (hist disponible)
				  ti_co_num_ptp					=	vTI_CO_NUM_PTP, -- num convenios desde su apertura
				  --ti_co_mthly_balance_1			=	vTI_CO_MTHLY_BALANCE_1,
				  --ti_co_mthly_debits_1			=	vTI_CO_MTHLY_DEBITS_1, 
				  --ti_co_mthly_credits_1			=	vTI_CO_MTHLY_CREDITS_1, 
				  --ti_co_mthly_balance_2			=	vTI_CO_MTHLY_BALANCE_2, 
				  --ti_co_mthly_debits_2			=	vTI_CO_MTHLY_DEBITS_2, 
				  --ti_co_mthly_credits_2			=	vTI_CO_MTHLY_CREDITS_2, 
				  --ti_co_mthly_balance_3			=	vTI_CO_MTHLY_BALANCE_3, 
				  --ti_co_mthly_debits_3			=	vTI_CO_MTHLY_DEBITS_3, 
				  --ti_co_mthly_credits_3			=	vTI_CO_MTHLY_CREDITS_3, 
				  --ti_co_mthly_balance_4			=	vTI_CO_MTHLY_BALANCE_4, 
				  --ti_co_mthly_debits_4			=	vTI_CO_MTHLY_DEBITS_4, 
				  --ti_co_mthly_credits_4			=	vTI_CO_MTHLY_CREDITS_4,
				  --ti_co_mthly_balance_5			=	vTI_CO_MTHLY_BALANCE_5, 
				  --ti_co_mthly_debits_5			=	vTI_CO_MTHLY_DEBITS_5, 
				  --ti_co_mthly_credits_5			=	vTI_CO_MTHLY_CREDITS_5, 
				  --ti_co_mthly_balance_6			=	vTI_CO_MTHLY_BALANCE_6, 
				  --ti_co_mthly_debits_6			=	vTI_CO_MTHLY_DEBITS_6,
				  --ti_co_mthly_credits_6			=	vTI_CO_MTHLY_CREDITS_6, 
				  --ti_co_delq_1					=	vTI_CO_DELQ_1, 
				  --ti_co_mthly_interest_1		= 	vTI_CO_MTHLY_INTEREST_1, 
				  --ti_co_mthly_fees_1			=	vTI_CO_MTHLY_FEES_1, 
				  --ti_co_delq_2					=	vTI_CO_DELQ_2, 
				  --ti_co_mthly_interest_2		=	vTI_CO_MTHLY_INTEREST_2, 
				  --ti_co_mthly_fees_2			=	vTI_CO_MTHLY_FEES_2, 
				  --ti_co_delq_3					=	vTI_CO_DELQ_3, 
				  --ti_co_mthly_interest_3		=	vTI_CO_MTHLY_INTEREST_3,
				  --ti_co_mthly_fees_3			=	vTI_CO_MTHLY_FEES_3, 
				  --ti_co_delq_4					=	vTI_CO_DELQ_4, 
				  --ti_co_mthly_interest_4		=	vTI_CO_MTHLY_INTEREST_4, 
				  --ti_co_mthly_fees_4			=	vTI_CO_MTHLY_FEES_4, 
				  --ti_co_delq_5					=	vTI_CO_DELQ_5, 
				  --ti_co_mthly_interest_5		=	vTI_CO_MTHLY_INTEREST_5, 
				  --ti_co_mthly_fees_5			=	vTI_CO_MTHLY_FEES_5, 
				  --ti_co_delq_6					=	vTI_CO_DELQ_6, 
				  --ti_co_mthly_interest_6		=	vTI_CO_MTHLY_INTEREST_6,  
				  --ti_co_mthly_fees_6			=	vTI_CO_MTHLY_FEES_6, 
				  --ti_co_delq_7					=	vTI_CO_DELQ_7,
				  --ti_co_mthly_interest_7		=	vTI_CO_MTHLY_INTEREST_7, 
				  --ti_co_mthly_fees_7			=	vTI_CO_MTHLY_FEES_7, 
				  --ti_co_delq_8					=	vTI_CO_DELQ_8, 
				  --ti_co_mthly_interest_8		=	vTI_CO_MTHLY_INTEREST_8, 
				  --ti_co_mthly_fees_8			=	vTI_CO_MTHLY_FEES_8,
				  --ti_co_delq_9					=	vTI_CO_DELQ_9, 
				  --ti_co_mthly_interest_9		=	vTI_CO_MTHLY_INTEREST_9,  
				  --ti_co_mthly_fees_9			=	vTI_CO_MTHLY_FEES_9, 
				  --ti_co_delq_10					=	vTI_CO_DELQ_10, 
				  --ti_co_mthly_interest_10		=	vTI_CO_MTHLY_INTEREST_10,
				  --ti_co_mthly_fees_10			=	vTI_CO_MTHLY_FEES_10, 
				  --ti_co_delq_11					=	vTI_CO_DELQ_11, 
				  --ti_co_mthly_interest_11		=	vTI_CO_MTHLY_INTEREST_11, 
				  --ti_co_mthly_fees_11			=	vTI_CO_MTHLY_FEES_11,
				  --ti_co_delq_12					=	vTI_CO_DELQ_12, 
				  --ti_co_mthly_interest_12		=	vTI_CO_MTHLY_INTEREST_12, 
				  --ti_co_mthly_fees_12			=	vTI_CO_MTHLY_FEES_12, 
				  --ti_co_remaining_term			=	vTI_CO_REMAINING_TERM, 
				  --ti_co_original_loan_amt		=	vTI_CO_ORIGINAL_LOAN_AMT, 
				  --ti_co_manual_handling_status	=	vTI_CO_MANUAL_HANDLING_STATUS, --Sitesp (NO ACTUALIZAR AQUÍ)
				  ti_co_contact_made_ind		=	vTI_CO_CONTACT_MADE_IND, --contaco llamada cob
				  ti_co_usr_df_coll_amt			=	vTI_CO_USR_DF_COLL_AMT, -- PM
				  --ti_co_usr_df_worse_trigger1	=	vTI_CO_USR_DF_WORSE_TRIGGER1, -- validac e-mail (NO ACTUALIZAR AQUÍ)
				  --ti_co_usr_df_worse_trigger2 	=	vTI_CO_USR_DF_WORSE_TRIGGER2, -- se guarda al insert reg por unica vez con val default
				  ti_co_usr_df_worse_trigger3	=	vTI_CO_USR_DF_WORSE_TRIGGER3, 	--tiene o no trabajo
				  --ti_co_usr_df_better_trigger1	=	vTI_CO_USR_DF_BETTER_TRIGGER1, -- relacionado al e-mail (NO ACTUALIZAR AQUÍ)
				  ti_co_stgy_id					=	vTI_CO_STGY_ID,  --de cb_triad_salida
				  ti_co_scen_id					= 	vTI_CO_SCEN_ID,  --de cb_triad_salida
				  ti_co_action_ctr				=	vTI_CO_ACTION_CTR, --de cb_triad_salida
				  ti_co_ptp						=	vTI_CO_PTP,       -- convenio
				  ti_co_date_bill_eqv			=	vTI_CO_DATE_BILL_EQV, --de cb_triad_salida
				  ti_co_date_first_colls_da		= 	vTI_CO_DATE_FIRST_COLLS_DA, --de cb_triad_salida
				  ti_co_coll_balance_initial	=	vTI_CO_COLL_BALANCE_INITIAL, --de cb_triad_salida
				  ti_co_coll_balance_prev		=	vTI_CO_COLL_BALANCE_PREV,   --de cb_triad_salida
				  ti_co_ooo_type_prev			=	vTI_CO_OOO_TYPE_PREV, --de cb_triad_salida
				  ti_co_delq_prev				=	vTI_CO_DELQ_PREV,     --de cb_triad_salida
				  ti_co_amt_arrears_prev		=	vTI_CO_AMT_ARREARS_PREV,  --de cb_triad_salida
				  ti_co_amt_excess_ovlm_prev	=	vTI_CO_AMT_EXCESS_OVLM_PREV, --de cb_triad_salida
				  ti_co_balance_prev			=	vTI_CO_BALANCE_PREV,  --de cb_triad_salida 
				  ti_co_limit_prev				=	vTI_CO_LIMIT_PREV,  --de cb_triad_salida
				  ti_co_ptp_prev				=	vTI_CO_PTP_PREV,    --de cb_triad_salida
				  ti_co_telephone_ind_prev		=	vTI_CO_TELEPHONE_IND_PREV, --de cb_triad_salida
				  ti_co_address_ind_prev		=	vTI_CO_ADDRESS_IND_PREV,   --de cb_triad_salida
				  ti_co_block_code_prev			=	vTI_CO_BLOCK_CODE_PREV,    --de cb_triad_salida
				  ti_co_block_code_last_review	=	vTI_CO_BLOCK_CODE_LAST_REVIEW, --de cb_triad_salida
				  ti_co_worst_cyc_delq_prev		=	vTI_CO_WORST_CYC_DELQ_PREV, --de cb_triad_salida
				  ti_co_total_ooo_amt_prev		=	vTI_CO_TOTAL_OOO_AMT_PREV,  --de cb_triad_salida
				  fecha_proceso					=	vFechahoy
				WHERE empresa=vEmpresa AND ti_co_account_id = cNumCredCob;
			commit;
			LET iContUpd = iContUpd + 1;
	
		--- 3. Actualizar datos de actualización diaria menos los que se validan si se actualizaron (tel, cel, sitesp,e-mail, aclaración) Y los de saldos al corte e históricos también actualizar aquí
		ELIF iExisteCuenta > 0 AND (vFechacorte = vFechahoy) AND (cActualiza_tel='' AND cActualiza_tel_2 = '' AND cActualiza_email = '' AND cActualiza_sitesp = '' AND cActualiza_aclaracion ='') THEN  
		
			begin; 	 		
				UPDATE bdicobranza:cb_triad_cobranza	SET ti_co_customer_id = cNumCteCob,    
				  ti_co_status					=	vTI_CO_STATUS, --puede cambiar diario			  
				  ti_co_full_bal_payment_ind 	=	vTI_CO_FULL_BAL_PAYMENT_IND, -- cambia de acuerdo a PM y Sdo Total
				  ti_co_trans_revolve_ind	 	=	vTI_CO_TRANS_REVOLVE_IND, --totalero o no
				  -- ti_co_telephone_ind			=	vTI_CO_TELEPHONE_IND, -- tel casa (NO ACTUALIZAR AQUÍ)
				  --ti_co_address_ind				=	vTI_CO_ADDRESS_IND, -- Dir valida, solo al insertarlo
				  --ti_co_sms_ind					= 	vTI_CO_SMS_IND, -- Tel celular (NO ACTUALIZAR AQUÍ)
				  ti_co_block_code			 	=	vTI_CO_BLOCK_CODE, -- bloqueo cta solo tdc
				  --ti_co_legal_code			 	=	vTI_CO_LEGAL_CODE, -- Aclaración (NO ACTUALIZAR AQUÍ)
				  ti_co_date_billing_cymd	 	=	vTI_CO_DATE_BILLING_CYMD,  -- Última fecha corte
				  ti_co_date_start_delq		 	=	vTI_CO_DATE_START_DELQ, -- fecha en la cual inició a estar en mora
				  ti_co_date_last_debit		 	=	vTI_CO_DATE_LAST_DEBIT, -- ult compra o disp
				  ti_co_date_last_credit	 	=	vTI_CO_DATE_LAST_CREDIT, --fecha ult pago 
				  ti_co_date_last_mon_txn_cym	=	vTI_CO_DATE_LAST_MON_TXN_CYM, -- fecha ult tnx monetaria
				  ti_co_date_last_cash_cym 		=	vTI_CO_DATE_LAST_CASH_CYM, -- fecha ult disp efec
				  ti_co_date_last_delq_cymd		=	vTI_CO_DATE_LAST_DELQ_CYMD, -- fecha ul vez en mora
				  ti_co_date_last_pur_cym		=	vTI_CO_DATE_LAST_PUR_CYM, -- fecha ult compra
				  ti_co_date_fee_cym			=	vTI_CO_DATE_FEE_CYM,  -- fecha vencim cuotas anuales (oro y platino)
				  --ti_co_date_original_maturity  = 	vTI_CO_DATE_ORIGINAL_MATURITY, -- fecha vencim ori (plazo) solo al insertarlo
				  ti_co_date_current_maturity	=	vTI_CO_DATE_CURRENT_MATURITY, -- Fecha de vencimiento actual (Solo para plazo)
				  ti_co_date_prom_brkn_cymd		=	vTI_CO_DATE_PROM_BRKN_CYMD, -- fecha promesa rota(convenio)
				  ti_co_bhvr_score				=	vTI_CO_BHVR_SCORE, -- de cb_triad_salida
				  ti_co_bhvr_scrd_id			=	vTI_CO_BHVR_SCRD_ID, -- de cb_triad_salida
				  ti_co_bar_factor				=	vTI_CO_BAR_FACTOR,  -- de cb_triad_salida
				  ti_co_balance					=	vTI_CO_BALANCE,  -- saldo actual de la cuenta
				  ti_co_limit					=	vTI_CO_LIMIT,  --limite actual de la cuenta
				  ti_co_cash_balance			=	vTI_CO_CASH_BALANCE, -- Saldo de efectivo actual (al corte)
				  ti_co_amt_arrears				=	vTI_CO_AMT_ARREARS, -- saldo vencido actual (al corte)
				  --ti_co_amt_dispute				=	vTI_CO_AMT_DISPUTE,   --monto de aclaracion (ligado al vTI_CO_LEGAL_CODE) (NO ACTUALIZAR AQUÍ)
				  ti_co_amt_last_credit			=	vTI_CO_AMT_LAST_CREDIT, -- último pago registrado
				  ti_co_high_balance_lf			=	vTI_CO_HIGH_BALANCE_LF, -- máximo saldo cuenta 3 años (al corte)
				  ti_co_num_pymnts_lf			=	vTI_CO_NUM_PYMNTS_LF, -- Num pagos realizados a cuenta (hist disponible)
				  ti_co_num_ptp					=	vTI_CO_NUM_PTP, -- num convenios desde su apertura
				  ti_co_mthly_balance_1			=	vTI_CO_MTHLY_BALANCE_1,  -- Saldo en el ciclo o fecha de vencimiento (al corte)
				  ti_co_mthly_debits_1			=	vTI_CO_MTHLY_DEBITS_1,  -- Monto de las compras y disposiciones realizados en la cuenta (al corte)
				  ti_co_mthly_credits_1			=	vTI_CO_MTHLY_CREDITS_1, -- Monto de los pagos hechos a la cuenta durante el periodo correspondiente (al corte)
				  ti_co_mthly_balance_2			=	vTI_CO_MTHLY_BALANCE_2, 
				  ti_co_mthly_debits_2			=	vTI_CO_MTHLY_DEBITS_2, 
				  ti_co_mthly_credits_2			=	vTI_CO_MTHLY_CREDITS_2, 
				  ti_co_mthly_balance_3			=	vTI_CO_MTHLY_BALANCE_3, 
				  ti_co_mthly_debits_3			=	vTI_CO_MTHLY_DEBITS_3, 
				  ti_co_mthly_credits_3			=	vTI_CO_MTHLY_CREDITS_3, 
				  ti_co_mthly_balance_4			=	vTI_CO_MTHLY_BALANCE_4, 
				  ti_co_mthly_debits_4			=	vTI_CO_MTHLY_DEBITS_4, 
				  ti_co_mthly_credits_4			=	vTI_CO_MTHLY_CREDITS_4,
				  ti_co_mthly_balance_5			=	vTI_CO_MTHLY_BALANCE_5, 
				  ti_co_mthly_debits_5			=	vTI_CO_MTHLY_DEBITS_5, 
				  ti_co_mthly_credits_5			=	vTI_CO_MTHLY_CREDITS_5, 
				  ti_co_mthly_balance_6			=	vTI_CO_MTHLY_BALANCE_6, 
				  ti_co_mthly_debits_6			=	vTI_CO_MTHLY_DEBITS_6,
				  ti_co_mthly_credits_6			=	vTI_CO_MTHLY_CREDITS_6, 
				  ti_co_delq_1					=	vTI_CO_DELQ_1,         --Indicador de Morosidad o de no pago. Numero de meses vencidos del ciclo actual (al corte)
				  ti_co_mthly_interest_1		= 	vTI_CO_MTHLY_INTEREST_1, --monto de los intereses cargados en la cuenta durante el periodo (al corte)
				  ti_co_mthly_fees_1			=	vTI_CO_MTHLY_FEES_1, --Total de comisiones cargadas durante el periodo (Solo TDC) (al corte)
				  ti_co_delq_2					=	vTI_CO_DELQ_2, 
				  ti_co_mthly_interest_2		=	vTI_CO_MTHLY_INTEREST_2, 
				  ti_co_mthly_fees_2			=	vTI_CO_MTHLY_FEES_2, 
				  ti_co_delq_3					=	vTI_CO_DELQ_3, 
				  ti_co_mthly_interest_3		=	vTI_CO_MTHLY_INTEREST_3,
				  ti_co_mthly_fees_3			=	vTI_CO_MTHLY_FEES_3, 
				  ti_co_delq_4					=	vTI_CO_DELQ_4, 
				  ti_co_mthly_interest_4		=	vTI_CO_MTHLY_INTEREST_4, 
				  ti_co_mthly_fees_4			=	vTI_CO_MTHLY_FEES_4, 
				  ti_co_delq_5					=	vTI_CO_DELQ_5, 
				  ti_co_mthly_interest_5		=	vTI_CO_MTHLY_INTEREST_5, 
				  ti_co_mthly_fees_5			=	vTI_CO_MTHLY_FEES_5, 
				  ti_co_delq_6					=	vTI_CO_DELQ_6, 
				  ti_co_mthly_interest_6		=	vTI_CO_MTHLY_INTEREST_6,  
				  ti_co_mthly_fees_6			=	vTI_CO_MTHLY_FEES_6, 
				  ti_co_delq_7					=	vTI_CO_DELQ_7,
				  ti_co_mthly_interest_7		=	vTI_CO_MTHLY_INTEREST_7, 
				  ti_co_mthly_fees_7			=	vTI_CO_MTHLY_FEES_7, 
				  ti_co_delq_8					=	vTI_CO_DELQ_8, 
				  ti_co_mthly_interest_8		=	vTI_CO_MTHLY_INTEREST_8, 
				  ti_co_mthly_fees_8			=	vTI_CO_MTHLY_FEES_8,
				  ti_co_delq_9					=	vTI_CO_DELQ_9, 
				  ti_co_mthly_interest_9		=	vTI_CO_MTHLY_INTEREST_9,  
				  ti_co_mthly_fees_9			=	vTI_CO_MTHLY_FEES_9, 
				  ti_co_delq_10					=	vTI_CO_DELQ_10, 
				  ti_co_mthly_interest_10		=	vTI_CO_MTHLY_INTEREST_10,
				  ti_co_mthly_fees_10			=	vTI_CO_MTHLY_FEES_10, 
				  ti_co_delq_11					=	vTI_CO_DELQ_11, 
				  ti_co_mthly_interest_11		=	vTI_CO_MTHLY_INTEREST_11, 
				  ti_co_mthly_fees_11			=	vTI_CO_MTHLY_FEES_11,
				  ti_co_delq_12					=	vTI_CO_DELQ_12, 
				  ti_co_mthly_interest_12		=	vTI_CO_MTHLY_INTEREST_12, 
				  ti_co_mthly_fees_12			=	vTI_CO_MTHLY_FEES_12, 
				  ti_co_remaining_term			=	vTI_CO_REMAINING_TERM, -- plazo restante de la cuenta (Solo para Plazo) (al corte)
				  ti_co_original_loan_amt		=	vTI_CO_ORIGINAL_LOAN_AMT, -- Para Plazo el monto original del prestamos. Para TDC el limite de credito original (al corte)
				  --ti_co_manual_handling_status	=	vTI_CO_MANUAL_HANDLING_STATUS, --Sitesp (NO ACTUALIZAR AQUÍ)
				  ti_co_contact_made_ind		=	vTI_CO_CONTACT_MADE_IND, --contacto llamada cob
				  ti_co_usr_df_coll_amt			=	vTI_CO_USR_DF_COLL_AMT, -- PM
				  --ti_co_usr_df_worse_trigger1	=	vTI_CO_USR_DF_WORSE_TRIGGER1, -- validac e-mail (NO ACTUALIZAR AQUÍ)
				  --ti_co_usr_df_worse_trigger2 	=	vTI_CO_USR_DF_WORSE_TRIGGER2, -- se guarda al insert reg por unica vez con val default
				  ti_co_usr_df_worse_trigger3	=	vTI_CO_USR_DF_WORSE_TRIGGER3, 	--tiene o no trabajo
				  --ti_co_usr_df_better_trigger1	=	vTI_CO_USR_DF_BETTER_TRIGGER1, -- relacionado al e-mail (NO ACTUALIZAR AQUÍ)
				  ti_co_stgy_id					=	vTI_CO_STGY_ID,  --de cb_triad_salida
				  ti_co_scen_id					= 	vTI_CO_SCEN_ID,  --de cb_triad_salida
				  ti_co_action_ctr				=	vTI_CO_ACTION_CTR, --de cb_triad_salida
				  ti_co_ptp						=	vTI_CO_PTP,       -- convenio
				  ti_co_date_bill_eqv			=	vTI_CO_DATE_BILL_EQV, --de cb_triad_salida
				  ti_co_date_first_colls_da		= 	vTI_CO_DATE_FIRST_COLLS_DA, --de cb_triad_salida
				  ti_co_coll_balance_initial	=	vTI_CO_COLL_BALANCE_INITIAL, --de cb_triad_salida
				  ti_co_coll_balance_prev		=	vTI_CO_COLL_BALANCE_PREV,   --de cb_triad_salida
				  ti_co_ooo_type_prev			=	vTI_CO_OOO_TYPE_PREV, --de cb_triad_salida
				  ti_co_delq_prev				=	vTI_CO_DELQ_PREV,     --de cb_triad_salida
				  ti_co_amt_arrears_prev		=	vTI_CO_AMT_ARREARS_PREV,  --de cb_triad_salida
				  ti_co_amt_excess_ovlm_prev	=	vTI_CO_AMT_EXCESS_OVLM_PREV, --de cb_triad_salida
				  ti_co_balance_prev			=	vTI_CO_BALANCE_PREV,  --de cb_triad_salida 
				  ti_co_limit_prev				=	vTI_CO_LIMIT_PREV,  --de cb_triad_salida
				  ti_co_ptp_prev				=	vTI_CO_PTP_PREV,    --de cb_triad_salida
				  ti_co_telephone_ind_prev		=	vTI_CO_TELEPHONE_IND_PREV, --de cb_triad_salida
				  ti_co_address_ind_prev		=	vTI_CO_ADDRESS_IND_PREV,   --de cb_triad_salida
				  ti_co_block_code_prev			=	vTI_CO_BLOCK_CODE_PREV,    --de cb_triad_salida
				  ti_co_block_code_last_review	=	vTI_CO_BLOCK_CODE_LAST_REVIEW, --de cb_triad_salida
				  ti_co_worst_cyc_delq_prev		=	vTI_CO_WORST_CYC_DELQ_PREV, --de cb_triad_salida
				  ti_co_total_ooo_amt_prev		=	vTI_CO_TOTAL_OOO_AMT_PREV,  --de cb_triad_salida
				  fecha_proceso					=	vFechahoy
				WHERE empresa=vEmpresa AND ti_co_account_id = cNumCredCob;
			commit;
			LET iContUpd = iContUpd + 1;
		
		--- 4. Actualizar datos de actualización diaria, los que se validan si se actualizaron (tel, cel, sitesp,e-mail, aclaración), Los de saldos al corte e históricos también actualizar aquí (TODO)
		ELIF iExisteCuenta > 0 AND (vFechacorte = vFechahoy)  THEN  
			
			begin; 	 		
				UPDATE bdicobranza:cb_triad_cobranza	SET ti_co_customer_id = cNumCteCob,    
				  ti_co_status					=	vTI_CO_STATUS, --puede cambiar diario			  
				  ti_co_full_bal_payment_ind 	=	vTI_CO_FULL_BAL_PAYMENT_IND, -- cambia de acuerdo a PM y Sdo Total
				  ti_co_trans_revolve_ind	 	=	vTI_CO_TRANS_REVOLVE_IND, --totalero o no
				   ti_co_telephone_ind			=	vTI_CO_TELEPHONE_IND, -- tel casa
				  --ti_co_address_ind				=	vTI_CO_ADDRESS_IND, -- Dir valida, solo al insertarlo
				  ti_co_sms_ind					= 	vTI_CO_SMS_IND, -- Tel celular
				  ti_co_block_code			 	=	vTI_CO_BLOCK_CODE, -- bloqueo cta solo tdc
				  ti_co_legal_code			 	=	vTI_CO_LEGAL_CODE, -- Aclaración
				  ti_co_date_billing_cymd	 	=	vTI_CO_DATE_BILLING_CYMD,  -- Última fecha corte
				  ti_co_date_start_delq		 	=	vTI_CO_DATE_START_DELQ, -- fecha en la cual inició a estar en mora
				  ti_co_date_last_debit		 	=	vTI_CO_DATE_LAST_DEBIT, -- ult compra o disp
				  ti_co_date_last_credit	 	=	vTI_CO_DATE_LAST_CREDIT, --fecha ult pago 
				  ti_co_date_last_mon_txn_cym	=	vTI_CO_DATE_LAST_MON_TXN_CYM, -- fecha ult tnx monetaria
				  ti_co_date_last_cash_cym 		=	vTI_CO_DATE_LAST_CASH_CYM, -- fecha ult disp efec
				  ti_co_date_last_delq_cymd		=	vTI_CO_DATE_LAST_DELQ_CYMD, -- fecha ul vez en mora
				  ti_co_date_last_pur_cym		=	vTI_CO_DATE_LAST_PUR_CYM, -- fecha ult compra
				  ti_co_date_fee_cym			=	vTI_CO_DATE_FEE_CYM,  -- fecha vencim cuotas anuales (oro y platino)
				  --ti_co_date_original_maturity  = 	vTI_CO_DATE_ORIGINAL_MATURITY, -- fecha vencim ori (plazo) solo al insertarlo
				  ti_co_date_current_maturity	=	vTI_CO_DATE_CURRENT_MATURITY, -- Fecha de vencimiento actual (Solo para plazo)
				  ti_co_date_prom_brkn_cymd		=	vTI_CO_DATE_PROM_BRKN_CYMD, -- fecha promesa rota(convenio)
				  ti_co_bhvr_score				=	vTI_CO_BHVR_SCORE, -- de cb_triad_salida
				  ti_co_bhvr_scrd_id			=	vTI_CO_BHVR_SCRD_ID, -- de cb_triad_salida
				  ti_co_bar_factor				=	vTI_CO_BAR_FACTOR,  -- de cb_triad_salida
				  ti_co_balance					=	vTI_CO_BALANCE,  -- saldo actual de la cuenta
				  ti_co_limit					=	vTI_CO_LIMIT,  --limite actual de la cuenta
				  ti_co_cash_balance			=	vTI_CO_CASH_BALANCE, -- Saldo de efectivo actual (al corte)
				  ti_co_amt_arrears				=	vTI_CO_AMT_ARREARS, -- saldo vencido actual (al corte)
				  ti_co_amt_dispute				=	vTI_CO_AMT_DISPUTE,   --monto de aclaracion (ligado al vTI_CO_LEGAL_CODE)
				  ti_co_amt_last_credit			=	vTI_CO_AMT_LAST_CREDIT, -- último pago registrado
				  ti_co_high_balance_lf			=	vTI_CO_HIGH_BALANCE_LF, -- máximo saldo cuenta 3 años (al corte)
				  ti_co_num_pymnts_lf			=	vTI_CO_NUM_PYMNTS_LF, -- Num pagos realizados a cuenta (hist disponible)
				  ti_co_num_ptp					=	vTI_CO_NUM_PTP, -- num convenios desde su apertura
				  ti_co_mthly_balance_1			=	vTI_CO_MTHLY_BALANCE_1,  -- Saldo en el ciclo o fecha de vencimiento (al corte)
				  ti_co_mthly_debits_1			=	vTI_CO_MTHLY_DEBITS_1,  -- Monto de las compras y disposiciones realizados en la cuenta (al corte)
				  ti_co_mthly_credits_1			=	vTI_CO_MTHLY_CREDITS_1, -- Monto de los pagos hechos a la cuenta durante el periodo correspondiente (al corte)
				  ti_co_mthly_balance_2			=	vTI_CO_MTHLY_BALANCE_2, 
				  ti_co_mthly_debits_2			=	vTI_CO_MTHLY_DEBITS_2, 
				  ti_co_mthly_credits_2			=	vTI_CO_MTHLY_CREDITS_2, 
				  ti_co_mthly_balance_3			=	vTI_CO_MTHLY_BALANCE_3, 
				  ti_co_mthly_debits_3			=	vTI_CO_MTHLY_DEBITS_3, 
				  ti_co_mthly_credits_3			=	vTI_CO_MTHLY_CREDITS_3, 
				  ti_co_mthly_balance_4			=	vTI_CO_MTHLY_BALANCE_4, 
				  ti_co_mthly_debits_4			=	vTI_CO_MTHLY_DEBITS_4, 
				  ti_co_mthly_credits_4			=	vTI_CO_MTHLY_CREDITS_4,
				  ti_co_mthly_balance_5			=	vTI_CO_MTHLY_BALANCE_5, 
				  ti_co_mthly_debits_5			=	vTI_CO_MTHLY_DEBITS_5, 
				  ti_co_mthly_credits_5			=	vTI_CO_MTHLY_CREDITS_5, 
				  ti_co_mthly_balance_6			=	vTI_CO_MTHLY_BALANCE_6, 
				  ti_co_mthly_debits_6			=	vTI_CO_MTHLY_DEBITS_6,
				  ti_co_mthly_credits_6			=	vTI_CO_MTHLY_CREDITS_6, 
				  ti_co_delq_1					=	vTI_CO_DELQ_1,         --Indicador de Morosidad o de no pago. Numero de meses vencidos del ciclo actual (al corte)
				  ti_co_mthly_interest_1		= 	vTI_CO_MTHLY_INTEREST_1, --monto de los intereses cargados en la cuenta durante el periodo (al corte)
				  ti_co_mthly_fees_1			=	vTI_CO_MTHLY_FEES_1, --Total de comisiones cargadas durante el periodo (Solo TDC) (al corte)
				  ti_co_delq_2					=	vTI_CO_DELQ_2, 
				  ti_co_mthly_interest_2		=	vTI_CO_MTHLY_INTEREST_2, 
				  ti_co_mthly_fees_2			=	vTI_CO_MTHLY_FEES_2, 
				  ti_co_delq_3					=	vTI_CO_DELQ_3, 
				  ti_co_mthly_interest_3		=	vTI_CO_MTHLY_INTEREST_3,
				  ti_co_mthly_fees_3			=	vTI_CO_MTHLY_FEES_3, 
				  ti_co_delq_4					=	vTI_CO_DELQ_4, 
				  ti_co_mthly_interest_4		=	vTI_CO_MTHLY_INTEREST_4, 
				  ti_co_mthly_fees_4			=	vTI_CO_MTHLY_FEES_4, 
				  ti_co_delq_5					=	vTI_CO_DELQ_5, 
				  ti_co_mthly_interest_5		=	vTI_CO_MTHLY_INTEREST_5, 
				  ti_co_mthly_fees_5			=	vTI_CO_MTHLY_FEES_5, 
				  ti_co_delq_6					=	vTI_CO_DELQ_6, 
				  ti_co_mthly_interest_6		=	vTI_CO_MTHLY_INTEREST_6,  
				  ti_co_mthly_fees_6			=	vTI_CO_MTHLY_FEES_6, 
				  ti_co_delq_7					=	vTI_CO_DELQ_7,
				  ti_co_mthly_interest_7		=	vTI_CO_MTHLY_INTEREST_7, 
				  ti_co_mthly_fees_7			=	vTI_CO_MTHLY_FEES_7, 
				  ti_co_delq_8					=	vTI_CO_DELQ_8, 
				  ti_co_mthly_interest_8		=	vTI_CO_MTHLY_INTEREST_8, 
				  ti_co_mthly_fees_8			=	vTI_CO_MTHLY_FEES_8,
				  ti_co_delq_9					=	vTI_CO_DELQ_9, 
				  ti_co_mthly_interest_9		=	vTI_CO_MTHLY_INTEREST_9,  
				  ti_co_mthly_fees_9			=	vTI_CO_MTHLY_FEES_9, 
				  ti_co_delq_10					=	vTI_CO_DELQ_10, 
				  ti_co_mthly_interest_10		=	vTI_CO_MTHLY_INTEREST_10,
				  ti_co_mthly_fees_10			=	vTI_CO_MTHLY_FEES_10, 
				  ti_co_delq_11					=	vTI_CO_DELQ_11, 
				  ti_co_mthly_interest_11		=	vTI_CO_MTHLY_INTEREST_11, 
				  ti_co_mthly_fees_11			=	vTI_CO_MTHLY_FEES_11,
				  ti_co_delq_12					=	vTI_CO_DELQ_12, 
				  ti_co_mthly_interest_12		=	vTI_CO_MTHLY_INTEREST_12, 
				  ti_co_mthly_fees_12			=	vTI_CO_MTHLY_FEES_12, 
				  ti_co_remaining_term			=	vTI_CO_REMAINING_TERM, -- plazo restante de la cuenta (Solo para Plazo) (al corte)
				  ti_co_original_loan_amt		=	vTI_CO_ORIGINAL_LOAN_AMT, -- Para Plazo el monto original del prestamos. Para TDC el limite de credito original (al corte)
				  ti_co_manual_handling_status	=	vTI_CO_MANUAL_HANDLING_STATUS, --Sitesp
				  ti_co_contact_made_ind		=	vTI_CO_CONTACT_MADE_IND, --contacto llamada cob
				  ti_co_usr_df_coll_amt			=	vTI_CO_USR_DF_COLL_AMT, -- PM
				  ti_co_usr_df_worse_trigger1	=	vTI_CO_USR_DF_WORSE_TRIGGER1, -- validac e-mail
				  --ti_co_usr_df_worse_trigger2 	=	vTI_CO_USR_DF_WORSE_TRIGGER2, -- se guarda al insert reg por unica vez con val default
				  ti_co_usr_df_worse_trigger3	=	vTI_CO_USR_DF_WORSE_TRIGGER3, 	--tiene o no trabajo
				  ti_co_usr_df_better_trigger1	=	vTI_CO_USR_DF_BETTER_TRIGGER1, -- relacionado al e-mail
				  ti_co_stgy_id					=	vTI_CO_STGY_ID,  --de cb_triad_salida
				  ti_co_scen_id					= 	vTI_CO_SCEN_ID,  --de cb_triad_salida
				  ti_co_action_ctr				=	vTI_CO_ACTION_CTR, --de cb_triad_salida
				  ti_co_ptp						=	vTI_CO_PTP,       -- convenio
				  ti_co_date_bill_eqv			=	vTI_CO_DATE_BILL_EQV, --de cb_triad_salida
				  ti_co_date_first_colls_da		= 	vTI_CO_DATE_FIRST_COLLS_DA, --de cb_triad_salida
				  ti_co_coll_balance_initial	=	vTI_CO_COLL_BALANCE_INITIAL, --de cb_triad_salida
				  ti_co_coll_balance_prev		=	vTI_CO_COLL_BALANCE_PREV,   --de cb_triad_salida
				  ti_co_ooo_type_prev			=	vTI_CO_OOO_TYPE_PREV, --de cb_triad_salida
				  ti_co_delq_prev				=	vTI_CO_DELQ_PREV,     --de cb_triad_salida
				  ti_co_amt_arrears_prev		=	vTI_CO_AMT_ARREARS_PREV,  --de cb_triad_salida
				  ti_co_amt_excess_ovlm_prev	=	vTI_CO_AMT_EXCESS_OVLM_PREV, --de cb_triad_salida
				  ti_co_balance_prev			=	vTI_CO_BALANCE_PREV,  --de cb_triad_salida 
				  ti_co_limit_prev				=	vTI_CO_LIMIT_PREV,  --de cb_triad_salida
				  ti_co_ptp_prev				=	vTI_CO_PTP_PREV,    --de cb_triad_salida
				  ti_co_telephone_ind_prev		=	vTI_CO_TELEPHONE_IND_PREV, --de cb_triad_salida
				  ti_co_address_ind_prev		=	vTI_CO_ADDRESS_IND_PREV,   --de cb_triad_salida
				  ti_co_block_code_prev			=	vTI_CO_BLOCK_CODE_PREV,    --de cb_triad_salida
				  ti_co_block_code_last_review	=	vTI_CO_BLOCK_CODE_LAST_REVIEW, --de cb_triad_salida
				  ti_co_worst_cyc_delq_prev		=	vTI_CO_WORST_CYC_DELQ_PREV, --de cb_triad_salida
				  ti_co_total_ooo_amt_prev		=	vTI_CO_TOTAL_OOO_AMT_PREV,  --de cb_triad_salida
				  fecha_proceso					=	vFechahoy
				WHERE empresa=vEmpresa AND ti_co_account_id = cNumCredCob;
			commit;
			LET iContUpd = iContUpd + 1;
			
		   
		/*-------------------------------- VERSION ANTERIOR		
		IF iExisteCuenta > 0 THEN
			begin; 	 		
				UPDATE bdicobranza:cb_triad_cobranza	SET ti_co_customer_id = cNumCteCob,    
				  ti_co_status					=	vTI_CO_STATUS, 			  
				  ti_co_full_bal_payment_ind 	=	vTI_CO_FULL_BAL_PAYMENT_IND, 
				  ti_co_trans_revolve_ind	 	=	vTI_CO_TRANS_REVOLVE_IND, 
				  ti_co_telephone_ind			=	vTI_CO_TELEPHONE_IND,
				  ti_co_address_ind				=	vTI_CO_ADDRESS_IND, 
				  ti_co_sms_ind					= 	vTI_CO_SMS_IND, 
				  ti_co_block_code			 	=	vTI_CO_BLOCK_CODE, 
				  ti_co_legal_code			 	=	vTI_CO_LEGAL_CODE,
				  
				  ti_co_date_billing_cymd	 	=	vTI_CO_DATE_BILLING_CYMD,  
				  ti_co_date_start_delq		 	=	vTI_CO_DATE_START_DELQ, 
				  ti_co_date_last_debit		 	=	vTI_CO_DATE_LAST_DEBIT, 
				  ti_co_date_last_credit	 	=	vTI_CO_DATE_LAST_CREDIT, 
				  ti_co_date_last_mon_txn_cym	=	vTI_CO_DATE_LAST_MON_TXN_CYM,
				  ti_co_date_last_cash_cym 		=	vTI_CO_DATE_LAST_CASH_CYM, 
				  ti_co_date_last_delq_cymd		=	vTI_CO_DATE_LAST_DELQ_CYMD, 
				  ti_co_date_last_pur_cym		=	vTI_CO_DATE_LAST_PUR_CYM, 
				  ti_co_date_fee_cym			=	vTI_CO_DATE_FEE_CYM,
				  ti_co_date_original_maturity  = 	vTI_CO_DATE_ORIGINAL_MATURITY, 
				  ti_co_date_current_maturity	=	vTI_CO_DATE_CURRENT_MATURITY, 
				  ti_co_date_prom_brkn_cymd		=	vTI_CO_DATE_PROM_BRKN_CYMD, 
				  ti_co_bhvr_score				=	vTI_CO_BHVR_SCORE, 
				  ti_co_bhvr_scrd_id			=	vTI_CO_BHVR_SCRD_ID, 
				  ti_co_bar_factor				=	vTI_CO_BAR_FACTOR,
				  ti_co_balance					=	vTI_CO_BALANCE, 
				  ti_co_limit					=	vTI_CO_LIMIT, 
				  ti_co_cash_balance			=	vTI_CO_CASH_BALANCE, 
				  ti_co_amt_arrears				=	vTI_CO_AMT_ARREARS, 
				  ti_co_amt_dispute				=	vTI_CO_AMT_DISPUTE, 
				  ti_co_amt_last_credit			=	vTI_CO_AMT_LAST_CREDIT, 
				  ti_co_high_balance_lf			=	vTI_CO_HIGH_BALANCE_LF, 
				  ti_co_num_pymnts_lf			=	vTI_CO_NUM_PYMNTS_LF, 
				  ti_co_num_ptp					=	vTI_CO_NUM_PTP, 
				  ti_co_mthly_balance_1			=	vTI_CO_MTHLY_BALANCE_1,
				  ti_co_mthly_debits_1			=	vTI_CO_MTHLY_DEBITS_1, 
				  ti_co_mthly_credits_1			=	vTI_CO_MTHLY_CREDITS_1, 
				  ti_co_mthly_balance_2			=	vTI_CO_MTHLY_BALANCE_2, 
				  ti_co_mthly_debits_2			=	vTI_CO_MTHLY_DEBITS_2, 
				  ti_co_mthly_credits_2			=	vTI_CO_MTHLY_CREDITS_2, 
				  ti_co_mthly_balance_3			=	vTI_CO_MTHLY_BALANCE_3, 
				  ti_co_mthly_debits_3			=	vTI_CO_MTHLY_DEBITS_3, 
				  ti_co_mthly_credits_3			=	vTI_CO_MTHLY_CREDITS_3, 
				  ti_co_mthly_balance_4			=	vTI_CO_MTHLY_BALANCE_4, 
				  ti_co_mthly_debits_4			=	vTI_CO_MTHLY_DEBITS_4, 
				  ti_co_mthly_credits_4			=	vTI_CO_MTHLY_CREDITS_4,
				  ti_co_mthly_balance_5			=	vTI_CO_MTHLY_BALANCE_5, 
				  ti_co_mthly_debits_5			=	vTI_CO_MTHLY_DEBITS_5, 
				  ti_co_mthly_credits_5			=	vTI_CO_MTHLY_CREDITS_5, 
				  ti_co_mthly_balance_6			=	vTI_CO_MTHLY_BALANCE_6, 
				  ti_co_mthly_debits_6			=	vTI_CO_MTHLY_DEBITS_6,
				  ti_co_mthly_credits_6			=	vTI_CO_MTHLY_CREDITS_6, 
				  ti_co_delq_1					=	vTI_CO_DELQ_1, 
				  ti_co_mthly_interest_1		= 	vTI_CO_MTHLY_INTEREST_1, 
				  ti_co_mthly_fees_1			=	vTI_CO_MTHLY_FEES_1, 
				  ti_co_delq_2					=	vTI_CO_DELQ_2, 
				  ti_co_mthly_interest_2		=	vTI_CO_MTHLY_INTEREST_2, 
				  ti_co_mthly_fees_2			=	vTI_CO_MTHLY_FEES_2, 
				  ti_co_delq_3					=	vTI_CO_DELQ_3, 
				  ti_co_mthly_interest_3		=	vTI_CO_MTHLY_INTEREST_3,
				  ti_co_mthly_fees_3			=	vTI_CO_MTHLY_FEES_3, 
				  ti_co_delq_4					=	vTI_CO_DELQ_4, 
				  ti_co_mthly_interest_4		=	vTI_CO_MTHLY_INTEREST_4, 
				  ti_co_mthly_fees_4			=	vTI_CO_MTHLY_FEES_4, 
				  ti_co_delq_5					=	vTI_CO_DELQ_5, 
				  ti_co_mthly_interest_5		=	vTI_CO_MTHLY_INTEREST_5, 
				  ti_co_mthly_fees_5			=	vTI_CO_MTHLY_FEES_5, 
				  ti_co_delq_6					=	vTI_CO_DELQ_6, 
				  ti_co_mthly_interest_6		=	vTI_CO_MTHLY_INTEREST_6,  
				  ti_co_mthly_fees_6			=	vTI_CO_MTHLY_FEES_6, 
				  ti_co_delq_7					=	vTI_CO_DELQ_7,
				  ti_co_mthly_interest_7		=	vTI_CO_MTHLY_INTEREST_7, 
				  ti_co_mthly_fees_7			=	vTI_CO_MTHLY_FEES_7, 
				  ti_co_delq_8					=	vTI_CO_DELQ_8, 
				  ti_co_mthly_interest_8		=	vTI_CO_MTHLY_INTEREST_8, 
				  ti_co_mthly_fees_8			=	vTI_CO_MTHLY_FEES_8,
				  ti_co_delq_9					=	vTI_CO_DELQ_9, 
				  ti_co_mthly_interest_9		=	vTI_CO_MTHLY_INTEREST_9,  
				  ti_co_mthly_fees_9			=	vTI_CO_MTHLY_FEES_9, 
				  ti_co_delq_10					=	vTI_CO_DELQ_10, 
				  ti_co_mthly_interest_10		=	vTI_CO_MTHLY_INTEREST_10,
				  ti_co_mthly_fees_10			=	vTI_CO_MTHLY_FEES_10, 
				  ti_co_delq_11					=	vTI_CO_DELQ_11, 
				  ti_co_mthly_interest_11		=	vTI_CO_MTHLY_INTEREST_11, 
				  ti_co_mthly_fees_11			=	vTI_CO_MTHLY_FEES_11,
				  ti_co_delq_12					=	vTI_CO_DELQ_12, 
				  ti_co_mthly_interest_12		=	vTI_CO_MTHLY_INTEREST_12, 
				  ti_co_mthly_fees_12			=	vTI_CO_MTHLY_FEES_12, 
				  ti_co_remaining_term			=	vTI_CO_REMAINING_TERM, 
				  ti_co_original_loan_amt		=	vTI_CO_ORIGINAL_LOAN_AMT,
				  ti_co_manual_handling_status	=	vTI_CO_MANUAL_HANDLING_STATUS, 
				  ti_co_contact_made_ind		=	vTI_CO_CONTACT_MADE_IND, 
				  ti_co_usr_df_coll_amt			=	vTI_CO_USR_DF_COLL_AMT, 
				  ti_co_usr_df_worse_trigger1	=	vTI_CO_USR_DF_WORSE_TRIGGER1, 
				  ti_co_usr_df_worse_trigger2 	=	vTI_CO_USR_DF_WORSE_TRIGGER2, 
				  ti_co_usr_df_worse_trigger3	=	vTI_CO_USR_DF_WORSE_TRIGGER3, 	
				  ti_co_usr_df_better_trigger1	=	vTI_CO_USR_DF_BETTER_TRIGGER1, 
				  ti_co_stgy_id					=	vTI_CO_STGY_ID,
				  ti_co_scen_id					= 	vTI_CO_SCEN_ID, 
				  ti_co_action_ctr				=	vTI_CO_ACTION_CTR, 
				  ti_co_ptp						=	vTI_CO_PTP, 
				  ti_co_date_bill_eqv			=	vTI_CO_DATE_BILL_EQV, 
				  ti_co_date_first_colls_da		= 	vTI_CO_DATE_FIRST_COLLS_DA, 
				  ti_co_coll_balance_initial	=	vTI_CO_COLL_BALANCE_INITIAL, 
				  ti_co_coll_balance_prev		=	vTI_CO_COLL_BALANCE_PREV, 
				  ti_co_ooo_type_prev			=	vTI_CO_OOO_TYPE_PREV, 
				  ti_co_delq_prev				=	vTI_CO_DELQ_PREV, 
				  ti_co_amt_arrears_prev		=	vTI_CO_AMT_ARREARS_PREV,
				  ti_co_amt_excess_ovlm_prev	=	vTI_CO_AMT_EXCESS_OVLM_PREV, 
				  ti_co_balance_prev			=	vTI_CO_BALANCE_PREV, 
				  ti_co_limit_prev				=	vTI_CO_LIMIT_PREV, 
				  ti_co_ptp_prev				=	vTI_CO_PTP_PREV, 
				  ti_co_telephone_ind_prev		=	vTI_CO_TELEPHONE_IND_PREV,
				  ti_co_address_ind_prev		=	vTI_CO_ADDRESS_IND_PREV, 
				  ti_co_block_code_prev			=	vTI_CO_BLOCK_CODE_PREV, 
				  ti_co_block_code_last_review	=	vTI_CO_BLOCK_CODE_LAST_REVIEW, 
				  ti_co_worst_cyc_delq_prev		=	vTI_CO_WORST_CYC_DELQ_PREV, 
				  ti_co_total_ooo_amt_prev		=	vTI_CO_TOTAL_OOO_AMT_PREV, 
				  fecha_proceso					=	vFechahoy
				WHERE empresa=vEmpresa AND ti_co_account_id = cNumCredCob;
			commit;
			LET iContUpd = iContUpd + 1;
		*/
		   
		ELIF iExisteCuenta <= 0  AND (vFechacorte = vFechahoy) THEN		
		--Se inserta el nuevo registro (solo en fecha de corte) 
			begin;
				INSERT INTO bdicobranza:cb_triad_cobranza(empresa, ti_co_customer_id, ti_co_account_id, ti_co_prod_type, ti_co_prod_code, ti_co_status, 			  
				  ti_co_full_bal_payment_ind, ti_co_trans_revolve_ind, ti_co_telephone_ind, ti_co_address_ind, ti_co_sms_ind, ti_co_block_code, ti_co_legal_code,
				  ti_co_date_open, ti_co_date_billing_cymd,  
				  ti_co_date_start_delq, 
				  ti_co_date_last_debit, ti_co_date_last_credit, ti_co_date_last_mon_txn_cym,
				  ti_co_date_last_cash_cym, ti_co_date_last_delq_cymd, ti_co_date_last_pur_cym, ti_co_date_fee_cym,
				  ti_co_date_original_maturity, ti_co_date_current_maturity, 
				  ti_co_date_prom_brkn_cymd, ti_co_bhvr_score, ti_co_bhvr_scrd_id, ti_co_bar_factor,
				  ti_co_balance, ti_co_limit, ti_co_cash_balance, ti_co_amt_arrears, ti_co_amt_dispute, 
				  ti_co_amt_last_credit, ti_co_high_balance_lf, ti_co_num_pymnts_lf, 
				  ti_co_num_ptp, ti_co_mthly_balance_1,
				  ti_co_mthly_debits_1, ti_co_mthly_credits_1, ti_co_mthly_balance_2, ti_co_mthly_debits_2, ti_co_mthly_credits_2, ti_co_mthly_balance_3, ti_co_mthly_debits_3, ti_co_mthly_credits_3, ti_co_mthly_balance_4, ti_co_mthly_debits_4, ti_co_mthly_credits_4,
				  ti_co_mthly_balance_5, ti_co_mthly_debits_5, ti_co_mthly_credits_5, ti_co_mthly_balance_6, ti_co_mthly_debits_6,
				  ti_co_mthly_credits_6, ti_co_delq_1, ti_co_mthly_interest_1, 
				  ti_co_mthly_fees_1, ti_co_delq_2, ti_co_mthly_interest_2, 
				  ti_co_mthly_fees_2, ti_co_delq_3, ti_co_mthly_interest_3,
				  ti_co_mthly_fees_3, 
				  ti_co_delq_4, ti_co_mthly_interest_4, ti_co_mthly_fees_4, 
				  ti_co_delq_5, ti_co_mthly_interest_5, 
				  ti_co_mthly_fees_5, ti_co_delq_6, ti_co_mthly_interest_6,  
				  ti_co_mthly_fees_6, ti_co_delq_7,
				  ti_co_mthly_interest_7, ti_co_mthly_fees_7, 
				  ti_co_delq_8, ti_co_mthly_interest_8, ti_co_mthly_fees_8,
				  ti_co_delq_9, ti_co_mthly_interest_9,  
				  ti_co_mthly_fees_9, ti_co_delq_10, ti_co_mthly_interest_10,
				  ti_co_mthly_fees_10, 
				  ti_co_delq_11, ti_co_mthly_interest_11, ti_co_mthly_fees_11,
				  ti_co_delq_12, ti_co_mthly_interest_12, 
				  ti_co_mthly_fees_12, ti_co_remaining_term, ti_co_original_loan_amt,
				  ti_co_manual_handling_status, ti_co_contact_made_ind, ti_co_usr_df_coll_amt, ti_co_usr_df_worse_trigger1, ti_co_usr_df_worse_trigger2,
				  ti_co_usr_df_worse_trigger3, 	ti_co_usr_df_better_trigger1, 
				  ti_co_stgy_id, ti_co_scen_id, ti_co_action_ctr, ti_co_ptp, 
				  ti_co_date_bill_eqv, ti_co_date_first_colls_da, ti_co_coll_balance_initial, ti_co_coll_balance_prev, ti_co_ooo_type_prev, ti_co_delq_prev, ti_co_amt_arrears_prev,
				  ti_co_amt_excess_ovlm_prev, ti_co_balance_prev, ti_co_limit_prev, ti_co_ptp_prev, ti_co_telephone_ind_prev,
				  ti_co_address_ind_prev, ti_co_block_code_prev, ti_co_block_code_last_review, ti_co_worst_cyc_delq_prev, ti_co_total_ooo_amt_prev, 
				  fecha_proceso
				)
				VALUES(vEmpresa,cNumCteCob, cNumCredCob, vTI_CO_PROD_TYPE,vTI_CO_PROD_CODE,vTI_CO_STATUS, 
				  vTI_CO_FULL_BAL_PAYMENT_IND, vTI_CO_TRANS_REVOLVE_IND,vTI_CO_TELEPHONE_IND, vTI_CO_ADDRESS_IND, vTI_CO_SMS_IND, vTI_CO_BLOCK_CODE, vTI_CO_LEGAL_CODE,
				  ti_co_date_open, vTI_CO_DATE_BILLING_CYMD,  
				  vTI_CO_DATE_START_DELQ, 
				  vTI_CO_DATE_LAST_DEBIT, vTI_CO_DATE_LAST_CREDIT, vTI_CO_DATE_LAST_MON_TXN_CYM,
				  vTI_CO_DATE_LAST_CASH_CYM, vTI_CO_DATE_LAST_DELQ_CYMD, vTI_CO_DATE_LAST_PUR_CYM, vTI_CO_DATE_FEE_CYM,
				  vTI_CO_DATE_ORIGINAL_MATURITY, vTI_CO_DATE_CURRENT_MATURITY, 
				  vTI_CO_DATE_PROM_BRKN_CYMD, vTI_CO_BHVR_SCORE, vTI_CO_BHVR_SCRD_ID, vTI_CO_BAR_FACTOR,
				  vTI_CO_BALANCE, vTI_CO_LIMIT, vTI_CO_CASH_BALANCE, vTI_CO_AMT_ARREARS, vTI_CO_AMT_DISPUTE, 
				  vTI_CO_AMT_LAST_CREDIT, vTI_CO_HIGH_BALANCE_LF, vTI_CO_NUM_PYMNTS_LF, 
				  vTI_CO_NUM_PTP, vTI_CO_MTHLY_BALANCE_1,
				  vTI_CO_MTHLY_DEBITS_1, vTI_CO_MTHLY_CREDITS_1, vTI_CO_MTHLY_BALANCE_2, vTI_CO_MTHLY_DEBITS_2, vTI_CO_MTHLY_CREDITS_2, 
				  vTI_CO_MTHLY_BALANCE_3, vTI_CO_MTHLY_DEBITS_3, vTI_CO_MTHLY_CREDITS_3, vTI_CO_MTHLY_BALANCE_4, vTI_CO_MTHLY_DEBITS_4, vTI_CO_MTHLY_CREDITS_4,
				  vTI_CO_MTHLY_BALANCE_5, vTI_CO_MTHLY_DEBITS_5, vTI_CO_MTHLY_CREDITS_5, vTI_CO_MTHLY_BALANCE_6, vTI_CO_MTHLY_DEBITS_6,
				  vTI_CO_MTHLY_CREDITS_6, vTI_CO_DELQ_1, vTI_CO_MTHLY_INTEREST_1, 
				  vTI_CO_MTHLY_FEES_1, vTI_CO_DELQ_2, vTI_CO_MTHLY_INTEREST_2, 
				  vTI_CO_MTHLY_FEES_2, vTI_CO_DELQ_3, vTI_CO_MTHLY_INTEREST_3,
				  vTI_CO_MTHLY_FEES_3, 
				  vTI_CO_DELQ_4, vTI_CO_MTHLY_INTEREST_4, vTI_CO_MTHLY_FEES_4, 
				  vTI_CO_DELQ_5, vTI_CO_MTHLY_INTEREST_5, 
				  vTI_CO_MTHLY_FEES_5, vTI_CO_DELQ_6, vTI_CO_MTHLY_INTEREST_6,  
				  vTI_CO_MTHLY_FEES_6, vTI_CO_DELQ_7,
				  vTI_CO_MTHLY_INTEREST_7, vTI_CO_MTHLY_FEES_7, vTI_CO_DELQ_8, vTI_CO_MTHLY_INTEREST_8, vTI_CO_MTHLY_FEES_8,
				  vTI_CO_DELQ_9, vTI_CO_MTHLY_INTEREST_9, 
				  vTI_CO_MTHLY_FEES_9, vTI_CO_DELQ_10, vTI_CO_MTHLY_INTEREST_10,
				  vTI_CO_MTHLY_FEES_10, 
				  vTI_CO_DELQ_11, vTI_CO_MTHLY_INTEREST_11, vTI_CO_MTHLY_FEES_11,
				  vTI_CO_DELQ_12, vTI_CO_MTHLY_INTEREST_12, 
				  vTI_CO_MTHLY_FEES_12, vTI_CO_REMAINING_TERM, vTI_CO_ORIGINAL_LOAN_AMT,
				  vTI_CO_MANUAL_HANDLING_STATUS, vTI_CO_CONTACT_MADE_IND, vTI_CO_USR_DF_COLL_AMT, 
				  vTI_CO_USR_DF_WORSE_TRIGGER1, vTI_CO_USR_DF_WORSE_TRIGGER2,
				  vTI_CO_USR_DF_WORSE_TRIGGER3, vTI_CO_USR_DF_BETTER_TRIGGER1,  
				  vTI_CO_STGY_ID, vTI_CO_SCEN_ID, vTI_CO_ACTION_CTR, vTI_CO_PTP, 
				  vTI_CO_DATE_BILL_EQV, vTI_CO_DATE_FIRST_COLLS_DA, vTI_CO_COLL_BALANCE_INITIAL, vTI_CO_COLL_BALANCE_PREV, vTI_CO_OOO_TYPE_PREV, vTI_CO_DELQ_PREV, vTI_CO_AMT_ARREARS_PREV,
				  vTI_CO_AMT_EXCESS_OVLM_PREV, vTI_CO_BALANCE_PREV, vTI_CO_LIMIT_PREV, vTI_CO_PTP_PREV, vTI_CO_TELEPHONE_IND_PREV,
				  vTI_CO_ADDRESS_IND_PREV, vTI_CO_BLOCK_CODE_PREV, vTI_CO_BLOCK_CODE_LAST_REVIEW, vTI_CO_WORST_CYC_DELQ_PREV, vTI_CO_TOTAL_OOO_AMT_PREV, 
				  vFechahoy
				);
			commit;
			LET iContIns = iContIns + 1;
		END IF;

		LET iExisteCuenta					= 0;
		LET vTI_CO_CUSTOMER_ID              = '';
		LET vTI_CO_ACCOUNT_ID               = '';
		LET vTI_CO_PROD_TYPE 				= 0;
		LET vTI_CO_PROD_CODE 				= 0;
		LET vTI_CO_STATUS 					= 0;
		LET vTI_CO_FULL_BAL_PAYMENT_IND 	= 0;
		LET vTI_CO_TRANS_REVOLVE_IND 		= 0;
		LET vTI_CO_TELEPHONE_IND 			= 0;
		LET vTI_CO_ADDRESS_IND 				= 0;
		LET vTI_CO_SMS_IND 					= 0;
		LET vTI_CO_BLOCK_CODE 				= 0;
		LET vTI_CO_LEGAL_CODE 				= 0;
		LET TI_CO_DATE_OPEN 				= DATE(1);
		LET vTI_CO_DATE_BILLING_CYMD 		= DATE(1);
		LET vTI_CO_DATE_START_DELQ 			= DATE(1);
		LET vTI_CO_DATE_LAST_DEBIT 			= DATE(1);
		LET vTI_CO_DATE_LAST_CREDIT 		= DATE(1);
		LET vTI_CO_DATE_LAST_MON_TXN_CYM 	= DATE(1);
		LET vTI_CO_DATE_LAST_CASH_CYM 		= DATE(1);
		LET vTI_CO_DATE_LAST_DELQ_CYMD 		= DATE(1);
		LET vTI_CO_DATE_LAST_PUR_CYM 		= DATE(1);
		LET vTI_CO_DATE_FEE_CYM 			= DATE(1);
		LET vTI_CO_DATE_ORIGINAL_MATURITY 	= DATE(1);
		LET vTI_CO_DATE_CURRENT_MATURITY 	= DATE(1);
		LET vTI_CO_DATE_PROM_BRKN_CYMD 		= DATE(1);
		LET vTI_CO_BHVR_SCORE 				= '+0000000';
		LET vTI_CO_BHVR_SCRD_ID 			= '+0000';
		LET vTI_CO_BAR_FACTOR 				= '+00000';
		LET vTI_CO_BALANCE 					= 0;
		LET vTI_CO_LIMIT 					= 0;
		LET vTI_CO_CASH_BALANCE 			= 0;
		LET vTI_CO_AMT_ARREARS 				= 0;
		LET vTI_CO_AMT_DISPUTE 				= 0;
		LET vTI_CO_AMT_LAST_CREDIT 			= 0;
		LET vTI_CO_HIGH_BALANCE_LF 			= 0;
		LET vTI_CO_NUM_PYMNTS_LF 			= 0;
		LET vTI_CO_NUM_PTP 					= 0;
		LET vTI_CO_MTHLY_BALANCE_1 			= 0;
		LET vTI_CO_MTHLY_DEBITS_1  			= 0;
		LET vTI_CO_MTHLY_CREDITS_1 			= 0;
		LET vTI_CO_MTHLY_BALANCE_2 			= 0;
		LET vTI_CO_MTHLY_DEBITS_2  			= 0;
		LET vTI_CO_MTHLY_CREDITS_2 			= 0;
		LET vTI_CO_MTHLY_BALANCE_3 			= 0;
		LET vTI_CO_MTHLY_DEBITS_3  			= 0;
		LET vTI_CO_MTHLY_CREDITS_3 			= 0;
		LET vTI_CO_MTHLY_BALANCE_4 			= 0;
		LET vTI_CO_MTHLY_DEBITS_4  			= 0;
		LET vTI_CO_MTHLY_CREDITS_4 			= 0;
		LET vTI_CO_MTHLY_BALANCE_5 			= 0;
		LET vTI_CO_MTHLY_DEBITS_5  			= 0;
		LET vTI_CO_MTHLY_CREDITS_5 			= 0;
		LET vTI_CO_MTHLY_BALANCE_6 			= 0;
		LET vTI_CO_MTHLY_DEBITS_6  			= 0;
		LET vTI_CO_MTHLY_CREDITS_6 			= 0;
		LET vTI_CO_DELQ_1 					= 0;
		LET vTI_CO_MTHLY_INTEREST_1 		= 0;
		LET vTI_CO_MTHLY_FEES_1 			= 0;
		LET vTI_CO_DELQ_2 					= 0;
		LET vTI_CO_MTHLY_INTEREST_2 		= 0;
		LET vTI_CO_MTHLY_FEES_2 			= 0;
		LET vTI_CO_DELQ_3 					= 0;
		LET vTI_CO_MTHLY_INTEREST_3 		= 0;
		LET vTI_CO_MTHLY_FEES_3 			= 0;
		LET vTI_CO_DELQ_4 					= 0;	
		LET vTI_CO_MTHLY_INTEREST_4 		= 0;
		LET vTI_CO_MTHLY_FEES_4 			= 0;
		LET vTI_CO_DELQ_5 					= 0;
		LET vTI_CO_MTHLY_INTEREST_5 		= 0;
		LET vTI_CO_MTHLY_FEES_5 			= 0;
		LET vTI_CO_DELQ_6 					= 0;
		LET vTI_CO_MTHLY_INTEREST_6 		= 0;
		LET vTI_CO_MTHLY_FEES_6 			= 0;
		LET vTI_CO_DELQ_7 					= 0;
		LET vTI_CO_MTHLY_INTEREST_7 		= 0;
		LET vTI_CO_MTHLY_FEES_7 			= 0;
		LET vTI_CO_DELQ_8 					= 0;
		LET vTI_CO_MTHLY_INTEREST_8 		= 0;
		LET vTI_CO_MTHLY_FEES_8 			= 0;
		LET vTI_CO_DELQ_9 					= 0;
		LET vTI_CO_MTHLY_INTEREST_9 		= 0;
		LET vTI_CO_MTHLY_FEES_9 			= 0;
		LET vTI_CO_DELQ_10 					= 0;
		LET vTI_CO_MTHLY_INTEREST_10 		= 0;
		LET vTI_CO_MTHLY_FEES_10 			= 0;
		---------------------------------------------------- 9
		LET vTI_CO_DELQ_11 					= 0;
		LET vTI_CO_MTHLY_INTEREST_11 		= 0;
		LET vTI_CO_MTHLY_FEES_11 			= 0;
		LET vTI_CO_DELQ_12 					= 0;
		LET vTI_CO_MTHLY_INTEREST_12 		= 0;
		LET vTI_CO_MTHLY_FEES_12			= 0;
		LET vTI_CO_REMAINING_TERM 			= 0;
		LET vTI_CO_ORIGINAL_LOAN_AMT 		= 0;
		LET vTI_CO_MANUAL_HANDLING_STATUS 	= 0;
		LET vTI_CO_CONTACT_MADE_IND 		= 0;
		LET vTI_CO_USR_DF_COLL_AMT 			= 0;
		LET vTI_CO_USR_DF_WORSE_TRIGGER1 	= 0;
		LET vTI_CO_USR_DF_WORSE_TRIGGER2	= 0;
		LET vTI_CO_USR_DF_WORSE_TRIGGER3 	= 0;
		LET vTI_CO_USR_DF_BETTER_TRIGGER1 	= 0;
		LET vTI_CO_STGY_ID 					= '+000';
		LET vTI_CO_SCEN_ID 					= '+0000';
		LET vTI_CO_ACTION_CTR 				= '0';
		LET vTI_CO_PTP 						= 0;
		LET vTI_CO_DATE_BILL_EQV 			= '00000000';
		LET vTI_CO_DATE_FIRST_COLLS_DA 		= '00000000';
		LET vTI_CO_COLL_BALANCE_INITIAL 	= '+000000000';
		LET vTI_CO_COLL_BALANCE_PREV 		= '+000000000';
		LET vTI_CO_OOO_TYPE_PREV 			= '0';
		LET vTI_CO_DELQ_PREV 				= '00';
		LET vTI_CO_AMT_ARREARS_PREV 		= '+000000000';
		LET vTI_CO_AMT_EXCESS_OVLM_PREV 	= '+000000000';
		LET vTI_CO_BALANCE_PREV 			= '+000000000';
		LET vTI_CO_LIMIT_PREV 				= '+000000000';
		LET vTI_CO_PTP_PREV 				= '0';
		LET vTI_CO_TELEPHONE_IND_PREV 		= '0';
		LET vTI_CO_ADDRESS_IND_PREV 		= '0';
		LET vTI_CO_BLOCK_CODE_PREV 			= '0000';
		LET vTI_CO_BLOCK_CODE_LAST_REVIEW 	= '0000';
		LET vTI_CO_WORST_CYC_DELQ_PREV 		= '00';
		LET vTI_CO_TOTAL_OOO_AMT_PREV 		= '+000000000';
	    LET cCobro_anualidad                = ''; 
		LET v_out_cu_customer_id_temp       = '';
		LET cEmpresa_10                     = '';
		
		LET dFechahora_tel           = DATE(1);  -- REING
		LET dfchalta_sitesp          = DATE(1);
		LET dFecha_hora_email        = DATE(1);
		LET cActualiza_tel           = '';
		LET cActualiza_tel_2         = '';
		LET cActualiza_email         = '';
		LET cActualiza_sitesp        = '';
		LET cActualiza_aclaracion    = '';
		LET cFecha_hora_email        = '';
		LET vTI_CO_TELEPHONE_IND_actual = 0;
		LET vTI_CO_STATUS_actual        = 0;
		LET dFechahora_tel_2            = DATE(1);
		LET vTI_CO_SMS_IND_actual       = 0;
		LET vTI_CO_MANUAL_HANDLING_STATUS_actual= 0;
		LET vVal_SdoInmaterial = 0;
		LET vTI_CO_USR_DF_WORSE_TRIGGER1_actual = 0;
		
	--COMMIT WORK;
	
END FOREACH


--  let vsql = 'echo "' || 'FTR1' || '" >>'||TRIM(cRuta)|| TRIM(vNomarchivo);
--  SYSTEM vsql;
	 
	 LET cContGral = iContGral;
	 LET cMensaje = pEjecucion;
	 CALL bdicobranza:sp_inserta_bitacora_cob_2(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2;  
	 --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2; 
	 
	 --LET cMensaje = trim(cMensaje) || '. ' || trim(cContGral) || ' registros procesados.';
	 LET cMensaje = trim(cMensaje) || '. UPDs= ' || iContUpd || '  Ins= ' || iContIns;
	
    ---RETURN cCodRet;
	RETURN cCodRet, trim(cMensaje);
	END
END PROCEDURE

DOCUMENT
'DESCRIPCION: Procedimiento para generar info de cobranza TRIAD.',
'Autor: Anayeli Alba',
'Fecha: 2018-08-02',
'Version: 1.0';

CREATE PROCEDURE "informix".sp_registro_ctetitular_cv(pSucural CHAR(4), pEmpleado CHAR(8), pTipoCliente CHAR(1), pFecha DATE)
RETURNING   CHAR(6)     AS cCodRet,
			CHAR(80) 	AS cMensajeRet;

 DEFINE cCodRet         CHAR(6);
 DEFINE iSqlErr         INTEGER;
 DEFINE iIsamErr        INTEGER;
 DEFINE cErrorInfo		CHAR(80);
 DEFINE cMensajeRet     CHAR(80); 

 DEFINE dFechains		DATE;
 DEFINE cSucursal		CHAR(4);
 DEFINE cEmpleado		CHAR(8);
 DEFINE cTipoCliente    CHAR(1);
 
 LET cCodRet = '000';
 LET cMensajeRet = 'Registro insertado';
 LET cSucursal = pSucural;
 LET cEmpleado = pEmpleado;
 LET cTipoCliente = pTipoCliente;
 LET dFechains = pFecha;

 
 SET ISOLATION TO DIRTY READ;
 SET LOCK MODE TO WAIT 3;

 BEGIN	

     ON EXCEPTION SET iSqlErr, iIsamErr
      	let cCodRet = iSqlErr;
        let cMensajeRet = trim(cCodRet) || '- ' || iIsamErr ;
			  
        RETURN cCodRet,cMensajeRet;
	END EXCEPTION;

	
   IF cSucursal = '' OR cEmpleado = '' OR NVL(dFechains,'') = '' THEN
      LET cCodRet = '001';
	  LET cMensajeRet = 'Parámetros incompletos';
	  RETURN cCodRet,cMensajeRet;
   END IF;
  
   
   IF cTipoCliente = 'T' THEN
   
	   INSERT INTO "informix".cb_cob_vent_cliente_titular(fecha, sucursal, empleado, cont_si, cont_no)
	   VALUES(dFechains, cSucursal, cEmpleado, 1, 0);
   ELSE
   
       INSERT INTO "informix".cb_cob_vent_cliente_titular(fecha, sucursal, empleado, cont_si, cont_no)
	   VALUES(dFechains, cSucursal, cEmpleado, 0, 1);
   END IF;
   
 RETURN cCodRet,cMensajeRet;

END;
 
END PROCEDURE
DOCUMENT
'Autor: Marco A. Campos',
'Fecha: 20200803',
'Descripción: Regisra en tabla un contador cuando el cliente es titulas o no, para Cobranza en Ventanilla',
'BD: bdicobranza';

CREATE PROCEDURE "informix".sp_layout_in_triad_customer(pEjecucion smallint)

RETURNING CHAR(6), char(80);
  -- Vers 1.0.8 20200901, 1.0.7 20200528, 1.0.6 20200227, 1.0.5 20200213, 1.0.4 20190924, 1.0.3 20190822, 1.0.2 20190409, 1.0.1 20180315
  DEFINE vDataErr			VARCHAR(64);
  DEFINE iSqlErr			INTEGER;
  DEFINE iSamErr			INTEGER;
  DEFINE cCodRet			CHAR(6);
  define cMensaje           char(80);
  DEFINE cMensaje_2         CHAR(80); 
    
define vEmpresa               char(3);
define v_numcte_ref           char(20); 
define vSitesp                integer;
define vCuentaTels            integer;
define vCuentaEmails          integer;
define vMoraMaxHist           integer;
define vFechahoy              date;
define vFechahoy_temp         date;
define vPriDiaMes             date;
define vfecha_fin_mes_ant     date;
define vFechacorte            date;
define vFechacorteant         date;
define vFechacorte_24MsAntes  date;
define v_evalua_cc            char(1);
define iIdUnidadProd          integer;
define vNumvencidos           integer;
define cContadorTarjetas      char(3);
define vFecha_proceso         date;

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
 define vRetCs_acum       decimal(18,2); 
 define dIntVdo           decimal(18,2);
 
 define cPagoMinimo       char(9);

 define dSdoTotalLiq      decimal(18,2);
 define dSdoTotalLiq_2    decimal(18,2);
 define cSdoTotalLiq      char(9);
 define dIntsCobrados     decimal(18,2);
 define cIntsCobrados     char(9);
 define vCod_retorno      char(6);
 define vMsj_retorno      char(80);
 define vDiacorte         integer;
 define cDiacorte         char(2);
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
 define cScoreBehavior    char(4);
 define iScoreBehavior    integer;
 define cNumRegion        char(4);
   
 define vNumcuentas       integer;
 define vTipo_prod        CHAR(3);
 define vNumCredito           char(20);
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
 define iResult_insert    integer;
 define iCantCuentasPrestamo integer;
 define cCantCuentasPrestamo integer;
 define dFecha_ult_reestruc_activa date;
 define cFecha_ult_reestruc_activa char(8);
 define cGoodBadind       char(2);
 define iGoodBadind       integer;
 define cNumProducto      char(4);
 define cValorRiskFactor  char(8);
 
 define vFechacorte_6MesesAntes   date;
 define cScoreBc_a                char(2);
 define iMora_en_6meses           smallint; 
 define cStatusCred               char(2);
 define cCredIni                  char(20);
 define cCredFin                  char(20); 
 define cCredIni_cnr              char(20);
 define cCredFin_cnr              char(20); 
 
 define iNum_vencidos1            smallint;
 define iNum_vencidos2            smallint; 
 define iNum_vencidos3            smallint; 
 define iNum_vencidos4            smallint;
 define iNum_vencidos5            smallint;   
 define iNum_vencidos6            smallint; 
 define iMaxNum_vencido_en6       smallint; 
 define iExisteCuenta             smallint; 
 define iMescorte                 smallint;
 define vFechacorte_nuevo         date;
 define iDia_hoy                  integer;
 define iDia_corte_nuevo          smallint;
 define iMes_corte_nuevo          smallint;
 define cDia_corte_nuevo          char(2);
 define iContador_upd             integer;
 define iContador_ins             integer;
 define cScoreBehavior_calif      char(5);
 define cValor_distrib_bcscore    char(5);
 define vFechaDiaAnt			  date;
 define vFechaDiaAnt_temp         date; 
 DEFINE iExisteTabla              INTEGER;
 define iCuenta_paso_customer   smallint;
 define iCuenta_paso_customer_2   smallint;
 define cStatusCred_Ree           char(4);
 define vNumCredito_salida        char(20);
 define iCuentaProcAntes          smallint;
 define cFechacorte			      CHAR(8);
 define vProx_fecha_pago         date;
 define pNumCredIni_temp         CHAR(30);
 define vEmpresa_2               CHAR(3); 
 define cEmpresa_10              CHAR(3);
 define v_numcte_ref_2           char(20); 
 define cred_ini_temp	         char(30);
 define iDia_corte               INTEGER; 
 define v_numcte                 char(20); 
 define dFechaMax_CleanBehav     DATE;
 define dFechaMax_Dirty          DATE;
 define vUltDiaMes               DATE;
 define dFechahora_tel           DATE;
 define cActualiza_tel           CHAR(1);
 define cActualiza_email         CHAR(1);
 define cActualiza_sitesp        CHAR(1);
 define cActualiza_behaviour     CHAR(1);
 define dfchalta_sitesp          DATE;
 define dFecha_hora_email        DATE;
 define cFecha_hora_email        CHAR(23);
 define vti_cu_phone_addr_ind_actual    char(1);
 define vti_cu_email_ind_actual         char(1);
 define vti_cu_cust_status_actual       char(1);
 define vti_cu_external_risk_factor_1_actual	CHAR(5);
 define vti_cu_external_exclusion_cat_1_actual char(1);
 define vti_cu_external_exclusion_ind_1_actual	CHAR(2);
 define vti_cu_scrd_id_1_actual           INTEGER;
 define vti_cu_raw_score_1_actual         CHAR(5);
 define vti_cu_aligned_score_1_actual     CHAR(5);
 define dFechaProcAnt_cta       DATE;
 DEFINE dFechaCorte	            DATE;
 DEFINE dFechaCorte_ant         DATE;
 
 DEFINE vTI_RV_ACCOUNT_ID  char(20); 
 
define vPP20_PROC_CODE              CHAR(4);
define vPP20_PROC_DATE_CYMD         DATE;
define vTI_CU_CUSTOMER_ID  			CHAR(20);
define vTI_CU_DATE_FIRST_REL        DATE;
define vTI_CU_CUST_TYPE             CHAR(1);
define vTI_CU_CUST_STATUS           CHAR(1);
define vTI_CU_CUST_SPR_TYPE         CHAR(1);
define vTI_CU_NUM_REV_ACCT          CHAR(2);
define vTI_CU_NUM_LOAN_ACCT         CHAR(2);
define vTI_CU_DATE_OF_BIRTH         DATE;
define vTI_CU_DATE_LAST_RESTRCTRE   DATE;
define vTI_CU_APP_SCORE             INTEGER;
define vTI_CU_PHONE_ADDR_IND        CHAR(1);
define vTI_CU_EMAIL_IND             CHAR(1);
define vTI_CU_SPID                  CHAR(3);
define vTI_CU_TEST_DIGITS_1         CHAR(4);
define vTI_CU_TEST_DIGITS_2         CHAR(4);
define vTI_CU_TEST_DIGITS_3         CHAR(4);
define vTI_CU_TEST_DIGITS_4         CHAR(4);
define vTI_CU_TRIAD_CAT             CHAR(2);
define vTI_CU_GEOGRAPHIC_CODE       SMALLINT;
define vTI_CU_BRANCH_NUMBER         CHAR(4);
define vTI_CU_EXTERNAL_RISK_FACTOR_1		CHAR(5);
define vTI_CU_EXTERNAL_EXCLUSION_CAT_1 		CHAR(1);
define vTI_CU_EXTERNAL_EXCLUSION_IND_1		CHAR(2);
define vTI_CU_EXTERNAL_MAX_DELQ_1           SMALLINT;
define vTI_CU_EXTERNAL_GOOD_BAD_IND_1 		SMALLINT;
define vTI_CU_EXTERNAL_RISK_FACTOR_3		CHAR(5);
define vTI_CU_EXTERNAL_EXCLUSION_CAT_3 		CHAR(1);
define vTI_CU_EXTERNAL_EXCLUSION_IND_3 		CHAR(2);
define vTI_CU_EXTERNAL_MAX_DELQ_3           SMALLINT;
define vTI_CU_EXTERNAL_GOOD_BAD_IND_3  		SMALLINT;
define vTI_CU_CB_SCORE_TYPE       SMALLINT;
define vTI_CU_BAR_FACTOR          CHAR(9);
define vTI_CU_RECOVERY_FACTOR     CHAR(9);
define vTI_CU_SCRD_ID_1           INTEGER;
define vTI_CU_RAW_SCORE_1         CHAR(5);
define vTI_CU_ALIGNED_SCORE_1     CHAR(5);
define vTI_CU_SCRD_ID_2           CHAR(5);
define vTI_CU_RAW_SCORE_2         CHAR(8);
define vTI_CU_ALIGNED_SCORE_2     CHAR(8);
define vTI_CU_SCRD_ID_3           SMALLINT;
define vTI_CU_RAW_SCORE_3         CHAR(5);
define vTI_CU_ALIGNED_SCORE_3     CHAR(5);
define vTI_CU_GEOGRAPHIC_CODE_2   SMALLINT;

--INICIALIZACION DE VARIABLES--
	    
let vEmpresa      = '001';
let v_numcte_ref  = '';
let vSitesp       = 0;
let vCuentaTels   = 0;
let vCuentaEmails = 0;
let vMoraMaxHist  = 0;
let vFechahoy     = date(1);
let vFechahoy_temp = date(1);
let vPriDiaMes    = date(1);
let vfecha_fin_mes_ant    = date(1);
let vFechacorte           = date(1);
let vFechacorteant        = date(1);
let vFechacorte_24MsAntes = date(1); 
let v_evalua_cc           = '';
let iIdUnidadProd         = 0;	    
let vNumvencidos          = 0;
let cContadorTarjetas     = '000';
let dSdoTotalLiq          = 0;
let dSdoTotalLiq_2        = 0;
let vFecha_proceso        = date(1);
let cCodRet		          = "000000";


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
 let vRetCs_acum       = 0; 
 let dIntVdo           = 0; 
 let cPagoMinimo         = '';
 let cSdoTotalLiq        = '';
 let dIntsCobrados       = 0;
 let cIntsCobrados       = ''; 
 let vCod_retorno        = '';
 let vMsj_retorno        = '';
 let vDiacorte           = 0;
 let cDiacorte           = '';
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
 let cScoreBehavior      = '';
 let iScoreBehavior      = 0;
 let cNumRegion          = '';
 let cMensaje            = 'PROCESO TERMINADO';
 let cMensaje_2          = '';
 let vNumcuentas         = 0;
 let vTipo_prod          = '';
 let vNumCredito             = '';
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
 let cProceso            = '0108';
 let cCod_ret_2          = ''; 
 let cContGral           = '';
 let iResult_insert      = 0;
 let iCantCuentasPrestamo = 0;
 let cCantCuentasPrestamo = '';
 let dFecha_ult_reestruc_activa = date(1);
 let cFecha_ult_reestruc_activa = '';
 let cGoodBadind          = '';
 let iGoodBadind          = 0; 
 let cNumProducto         = '';
 let cValorRiskFactor     = '';
 
 let vFechacorte_6MesesAntes   = date(1);
 let cScoreBc_a                = '';
 let iMora_en_6meses           = 0;
 let cStatusCred               = '';
 let cCredIni                  = '';
 let cCredFin                  = '';
 
 let iNum_vencidos1            = 0; 
 let iNum_vencidos2            = 0; 
 let iNum_vencidos3            = 0; 
 let iNum_vencidos4            = 0; 
 let iNum_vencidos5            = 0; 
 let iNum_vencidos6            = 0; 
 let iMaxNum_vencido_en6       = 0; 
 let iExisteCuenta             = 0;
 let iMescorte                 = 0;
 let vFechacorte_nuevo         = date(1);
 let iDia_hoy                  = 0;
 let iDia_corte_nuevo          = 0;
 let iMes_corte_nuevo          = 0;
 let cDia_corte_nuevo          = '';
 let iContador_upd             = 0;
 let iContador_ins             = 0;
 let cScoreBehavior_calif      = '';
 let cValor_distrib_bcscore    = '';
 let vFechaDiaAnt              = date(1);
 let vFechaDiaAnt_temp         = date(1); 
 LET iExisteTabla   = 0;
 let iCuenta_paso_customer   = 0;
 let iCuenta_paso_customer_2 = 0;
 let cStatusCred_Ree         = '';
 let vNumCredito_salida      = '';
 let iCuentaProcAntes        = 0;
 let cFechacorte             = '';
 let vProx_fecha_pago        = date(1); 
 let pNumCredIni_temp        = '';
 let vEmpresa_2              = '';
 let cEmpresa_10             = '';
 let v_numcte_ref_2          = '';
 let cred_ini_temp           = '';
 let iDia_corte              = 0;
 let v_numcte                = '';
 let dFechaMax_CleanBehav    = date(1);
 let dFechaMax_Dirty         = date(1);
 let vUltDiaMes              = date(1);
 let dFechahora_tel          = date(1);
 let cActualiza_tel          = '';
 let cActualiza_email        = '';
 let cActualiza_sitesp       = '';
 let cActualiza_behaviour    = '';
 let dfchalta_sitesp         = date(1);
 let dFecha_hora_email       = date(1);
 let cFecha_hora_email       = '';
 let vti_cu_phone_addr_ind_actual = '';
 let vti_cu_email_ind_actual      = '';
 let vti_cu_cust_status_actual    = '';
 let vti_cu_external_risk_factor_1_actual = '';
 let vti_cu_external_exclusion_cat_1_actual = '';
 let vti_cu_external_exclusion_ind_1_actual	= '';
 let vti_cu_scrd_id_1_actual        = 0;
 let vti_cu_raw_score_1_actual      = '';
 let vti_cu_aligned_score_1_actual  = '';
 let dFechaProcAnt_cta       = date(1);
 let dFechaCorte	         = date(1);
 let dFechaCorte_ant         = date(1);
 
 
let vPP20_PROC_CODE          = '';
let vPP20_PROC_DATE_CYMD     = date(1);
let vTI_CU_CUSTOMER_ID       = '';
let vTI_CU_DATE_FIRST_REL    = date(1);
let vTI_CU_CUST_TYPE         = ''; 
let vTI_CU_CUST_STATUS       = '';
let vTI_CU_CUST_SPR_TYPE     = '';
let vTI_CU_NUM_REV_ACCT      = '';
let vTI_CU_NUM_LOAN_ACCT     = '';
let vTI_CU_DATE_OF_BIRTH     = date(1);
let vTI_CU_DATE_LAST_RESTRCTRE  = date(1);
let vTI_CU_APP_SCORE         = 0;
let vTI_CU_PHONE_ADDR_IND    = '';
let vTI_CU_EMAIL_IND         = '';
let vTI_CU_SPID              = '';
let vTI_CU_TEST_DIGITS_1     = '';
let vTI_CU_TEST_DIGITS_2     = '';
let vTI_CU_TEST_DIGITS_3     = '';
let vTI_CU_TEST_DIGITS_4     = '';
let vTI_CU_TRIAD_CAT         = '';
let vTI_CU_GEOGRAPHIC_CODE   = 0;
let vTI_CU_BRANCH_NUMBER     = '';
let vTI_CU_EXTERNAL_RISK_FACTOR_1		= '';
let vTI_CU_EXTERNAL_EXCLUSION_CAT_1  	= '';
let vTI_CU_EXTERNAL_EXCLUSION_IND_1		= '';
let vTI_CU_EXTERNAL_MAX_DELQ_1          = 0;
let vTI_CU_EXTERNAL_GOOD_BAD_IND_1 		= 0;
let vTI_CU_EXTERNAL_RISK_FACTOR_3		= '+00000000';
let vTI_CU_EXTERNAL_EXCLUSION_CAT_3 	= '';
let vTI_CU_EXTERNAL_EXCLUSION_IND_3 	= '';
let vTI_CU_EXTERNAL_MAX_DELQ_3          = 0;
let vTI_CU_EXTERNAL_GOOD_BAD_IND_3  	= 0;
let vTI_CU_CB_SCORE_TYPE                = 0;
let vTI_CU_BAR_FACTOR        = '';
let vTI_CU_RECOVERY_FACTOR   = '';
let vTI_CU_SCRD_ID_1         = 0;
let vTI_CU_RAW_SCORE_1       = '';
let vTI_CU_ALIGNED_SCORE_1   = '';
let vTI_CU_SCRD_ID_2         = '';
let vTI_CU_RAW_SCORE_2       = '';
let vTI_CU_ALIGNED_SCORE_2   = '';
let vTI_CU_SCRD_ID_3         = 1;
let vTI_CU_RAW_SCORE_3       = '';
let vTI_CU_ALIGNED_SCORE_3   = '';
let vTI_RV_ACCOUNT_ID        = '';
let vTI_CU_GEOGRAPHIC_CODE_2 = 0;

	
-------------------------------------------------------------------------------------------------------------------

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDataErr
        IF iSqlErr <> 0 THEN
            LET cCodRet=iSqlErr ;
			let cMensaje = pEjecucion || '-' || trim(cCodRet) || ' ' || trim(vNumCredito);
			CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '02') RETURNING cCod_ret_2;
			 
            RETURN cCodRet, trim(cMensaje);
        END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/ifxsif01/macf/sp_layout_in_triad_customer.out";
	--TRACE ON;
  
  LET cMensaje = pEjecucion; 
  CALL bdicobranza:sp_inserta_bitacora_cob_2(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
   
  select fecha_hoy, fecha_ant, pri_dia_mes, ult_dia_mes into vFechahoy, vFechaDiaAnt, vPriDiaMes, vUltDiaMes
  --select fecha_hoy, fecha_ant, pri_dia_mes into vFechahoy_temp, vFechaDiaAnt_temp, vPriDiaMes
    from bdicred:sd_fechas 
   where empresa = vEmpresa; 
  
   
   -- let vFechahoy = date(vFechahoy_temp - 1 units day);      -- para que ejecute despues del cambio de fechas
   -- let vFechaDiaAnt= date(vFechaDiaAnt_temp - 1 units day); -- para que ejecute despues del cambio de fechas
    --let vFechahoy = vFechahoy_temp;
    --let vFechaDiaAnt= vFechaDiaAnt_temp;
	
	let vFechahoy = today -1;
    let vFechaDiaAnt= today -2;
   
    /*let vFechahoy = mdy(9,1,2020);   -- SOLO TEST MACF
	let vFechaDiaAnt = date(vFechahoy - 1 units day); -- SOLO TEST MACF
	let vPriDiaMes = mdy(9,1,2020);  -- SOLO TEST MACF
	let vUltDiaMes = mdy(9,30,2020); -- SOLO TEST MACF*/
   
    LET iDia_corte = DAY(vFechahoy);
   
    LET vPP20_PROC_DATE_CYMD = vFechahoy;
  
    LET dFechaCorte     =  lpad(month(vFechahoy),2,0) || "/" || lpad(day(vFechahoy),2,0) || "/" || year(vFechahoy);
    LET dFechaCorte_ant =  date(dFechaCorte - 1 units month);
  
    begin;
       update bdicobranza:cb_param set valor = '0'
        where cod_param = '8';
    commit;
  
  SELECT valor INTO pNumCredIni_temp
	--FROM bdicred:sd_param  WHERE cod_param = (980 + pEjecucion)::CHAR(3);  
   FROM bdicred:sd_param  WHERE cod_param = (830 + pEjecucion)::CHAR(3);  
   
	LET cCredIni = SUBSTR(pNumCredIni_temp,1,12); 
	LET cCredFin = SUBSTR(pNumCredIni_temp,14,25);

    
  IF pEjecucion < 7 THEN
		--  Se determina el rango de prestamos 
		--SELECT SUBSTR(valor,1,12),SUBSTR(valor,14,25) INTO cred_ini,cred_fin
		SELECT valor INTO cred_ini_temp
		FROM bdicred:sd_param  WHERE cod_param = (971 + pEjecucion)::CHAR(3);       -- cod_param between '972' and '977'     
		
        let cCredIni_cnr = SUBSTR(cred_ini_temp,1,12);
		let cCredFin_cnr = SUBSTR(cred_ini_temp,14,25);
		
		IF cCredIni_cnr IS NULL OR cCredFin_cnr IS NULL OR cCredIni_cnr='' OR cCredFin_cnr='' THEN
			LET cCodRet     = "000007";
			LET cMensaje 	= "Sin cuentas a procesar";
			RETURN cCodRet, cMensaje;
		END IF;
	ELSE
		LET  cCredIni_cnr = '600000000000';
		LET  cCredFin_cnr = '600000000001';
	END IF;
  

  
  ---- crear tabla temporal de regiones-sucursal
  select {+AVOID_FULL (bdinteg:si_ciudades)} c.sucursal sucursal, cat.numero_region region
    from bdinteg:si_sucursales c
         left outer join bdinteg:si_ciudades ci on (c.estado = ci.estado and c.ciudad = ci.ciudad)
         left outer join bdinteg:si_catciudades cat on (cat.numerociudad = ci.ciudad_coppel)
    into temp paso_suc_region with no log;	 
  
    create unique index inx_paso_suc_region on paso_suc_region(sucursal);
    update statistics medium for table paso_suc_region;


			-- EN DÍA DE CORTE:  Pago mínimo > 0 (pendientes de pago)
			SELECT a.num_credito vNumCredito_2, a.numcte vTI_CU_CUSTOMER_ID_2, 'REV' vTipo_prod_2, a.num_producto, a.status_cred,  
			       d.dia_corte, a.fecha_apertura, d.prox_fecha_pago
			  FROM bdicred:sd_maecred a 
				   JOIN bdicred:sd_maesdos c ON c.empresa = a.empresa AND c.num_credito = a.num_credito
				                                AND c.monto_financiado > 0  -- PM MAYOR A CERO
				   JOIN bdicred:sd_maecredanexo d ON a.empresa = d.empresa AND a.num_credito = d.num_credito
			 WHERE a.num_producto <> '7800'   
			   AND a.num_credito >= cCredIni AND a.num_credito < cCredFin
			   AND a.status_cred = 'AA'
			   AND d.dia_corte = iDia_corte 
			   AND a.num_credito NOT IN(SELECT ti_account_id from bdicobranza:cb_triad_customer_2 WHERE fecha_proceso = vFechahoy)
			 INTO TEMP paso_customer WITH NO LOG;
			
			create unique index inx_paso_customer on paso_customer(vNumCredito_2);
			update statistics medium for table paso_customer;

		  
		-- DIARIO: TODAS LAS CUENTAS VENCIDAS
        INSERT INTO paso_customer		
		SELECT a.num_credito, a.numcte, 'REV', a.num_producto, a.status_cred, d.dia_corte, a.fecha_apertura, d.prox_fecha_pago
		  FROM bdicred:sd_maecred a
               JOIN bdicred:sd_maecredanexo d ON a.empresa = d.empresa AND a.num_credito = d.num_credito
		 WHERE a.num_producto <> '7800' AND a.status_cred in('BA','BT') --VENCIDOS
		   AND a.num_credito >= cCredIni AND a.num_credito < cCredFin
		   AND a.num_credito not in (select vNumCredito_2 from paso_customer)
		   AND a.num_credito NOT IN(SELECT ti_account_id from bdicobranza:cb_triad_customer_2 WHERE fecha_proceso = vFechahoy);


	    -- DIARIO: CUENTAS VIGENTES, VALIDA CAMPO DE ARCHIVO SALIDA: OUT_CO_ACCOUNT_ID		
		insert into paso_customer 
		SELECT a.num_credito, a.numcte, 'REV', a.num_producto, a.status_cred, d.dia_corte, a.fecha_apertura, d.prox_fecha_pago
		  FROM bdicred:sd_maecred a 
			   JOIN bdicred:sd_maecredanexo d ON d.empresa = a.empresa AND d.num_credito = a.num_credito 
			   JOIN bdicobranza:cb_triad_salida f ON f.num_credito = a.num_credito 
		 WHERE a.num_producto <> '7800' AND a.status_cred = 'AA' --VIGENTES 
		   AND a.num_credito not in (select vNumCredito_2 from paso_customer)
		   AND a.num_credito NOT IN(SELECT ti_account_id from bdicobranza:cb_triad_customer_2 WHERE fecha_proceso = vFechahoy)
		   AND a.num_credito >= cCredIni AND a.num_credito < cCredFin 
		   AND d.prox_fecha_pago+f.out_coll_next_call_days = vFechahoy;  --VIGENTES EN EL CAMPO OUT-COLL-NEXT-CALL-DAYS*

		-- DIARIO 2:  VIGENTES PAGO UN DIA ANTERIOR
		---  Y que la fecha de proceso no sea el dia de corte, siempre y cuando debía algo el mes anterior (monto_financiado en la sd_maesdoshist), 
		---dejar al final para que sean los menos créditos	, despues de la cons a cb_triad_salida	
		insert into paso_customer 
		SELECT a.num_credito, a.numcte, 'REV', a.num_producto, a.status_cred, d.dia_corte, a.fecha_apertura, d.prox_fecha_pago
		  FROM bdicred:sd_maecred a
		       JOIN bdicred:sd_maecredanexo d ON d.empresa = a.empresa AND d.num_credito = a.num_credito AND d.fecha_ult_pago = vFechaDiaAnt --PAGO UN DIA ANTERIOR
		       JOIN bdicred:sd_maesdoshist e ON e.empresa = a.empresa AND e.num_credito = a.num_credito 
			                                    --AND e.fecha = (mdy(month(vFechahoy),d.dia_corte,year(vFechahoy)) -1 units month)
												AND e.fecha = dFechaCorte_ant
												AND (e.monto_vencido+e.mto_venc_trasp) > 0
		 WHERE a.num_producto <> '7800' AND a.status_cred = 'AA' --VIGENTES
		   AND a.num_credito not in (select vNumCredito_2 from paso_customer)
		   AND a.num_credito NOT IN(SELECT ti_account_id from bdicobranza:cb_triad_customer_2 WHERE fecha_proceso = vFechahoy)
		   AND a.num_credito >= cCredIni AND a.num_credito  < cCredFin;
		   
		----  montovencido  mtovenctrasp  = 0  no es elegible  > 0 es elegible,, ya no es necesario validar el monto  financiado
		--- Iniciaron corte con monto a pagar
		
		--- Ejecutar DIARIO Y DIARIO 2 y comparar el contenido
		
		-- 1: CUENTAS A PLAZO: DIARIO/CORTE	 VENCIDOS
		insert into paso_customer 
		SELECT b.num_credito, b.numcte, 'CNR', b.num_producto, b.status_cred, d.dia_corte, b.fecha_apertura, d.prox_fecha_pago
		  FROM bdicred:sd_maecredcrd b
		       JOIN bdicred:sd_maecredanexocrd d ON b.empresa = d.empresa AND b.num_credito = d.num_credito
		 WHERE b.num_producto <> '6800'  --in('6011','6300','7600','7700','6400') 
		   AND b.status_cred in('BA','BT','VP')	--VENCIDOS
		   AND b.num_credito >= cCredIni_cnr AND b.num_credito  < cCredFin_cnr
		   AND b.num_credito NOT IN(SELECT ti_account_id from bdicobranza:cb_triad_customer_2 WHERE fecha_proceso = vFechahoy);

		-- 2: CUENTAS A PLAZO: DIARIO/CORTE	VIGENTES PAGO UN DIA ANTERIOR
		insert into paso_customer
		SELECT b.num_credito, b.numcte, 'CNR', b.num_producto, b.status_cred, d.dia_corte, b.fecha_apertura, d.prox_fecha_pago
		  FROM bdicred:sd_maecredcrd b
		      JOIN bdicred:sd_maecredanexocrd d ON d.empresa = b.empresa AND d.num_credito = b.num_credito AND d.fecha_ult_pago = vFechaDiaAnt 
		 WHERE b.num_producto <> '6800' 
		   AND b.status_cred = 'AA'
		   AND b.num_credito not in (select vNumCredito_2 from paso_customer)
		   AND b.num_credito NOT IN (SELECT ti_account_id from bdicobranza:cb_triad_customer_2 WHERE fecha_proceso = vFechahoy)
		   AND b.num_credito >= cCredIni_cnr AND b.num_credito  < cCredFin_cnr;		

		
		-- 3: CUENTAS A PLAZO: CORTE  (Saldo > 0)
		insert into paso_customer
		SELECT b.num_credito, b.numcte, 'CNR', b.num_producto, b.status_cred, d.dia_corte, b.fecha_apertura, d.prox_fecha_pago  
		  FROM bdicred:sd_maecredcrd b
		    JOIN bdicred:sd_maesdoscrd c ON c.num_credito = b.num_credito AND c.sdo_cap_insoluto > 0
		    --JOIN bdicred:sd_maecredanexocrd d ON d.empresa = b.empresa AND d.num_credito = b.num_credito AND d.dia_corte = iDia_corte --FECHA DE CORTE
		    JOIN bdicred:sd_maecredanexocrd d ON d.empresa = b.empresa AND d.num_credito = b.num_credito AND d.prox_fecha_pago = vFechahoy --FECHA DE CORTE
		WHERE b.num_producto <> '6800' 
		  AND b.status_cred = 'AA'
		  AND b.num_credito not in (select vNumCredito_2 from paso_customer)
		  AND b.num_credito NOT IN(SELECT ti_account_id from bdicobranza:cb_triad_customer_2 WHERE fecha_proceso = vFechahoy)
		  AND b.num_credito >= cCredIni_cnr AND b.num_credito  < cCredFin_cnr;		
		

		-- 4: CUENTAS PLAZO: DIARIO/CORTE	|	VALIDA CAMPO DE ARCHIVO SALIDA: OUT_CO_ACCOUNT_ID
		insert into paso_customer
		SELECT b.num_credito, b.numcte, 'CNR', b.num_producto, b.status_cred, d.dia_corte, b.fecha_apertura, d.prox_fecha_pago  
		  FROM bdicred:sd_maecredcrd b
		    JOIN bdicred:sd_maecredanexocrd d ON d.empresa = b.empresa AND d.num_credito = b.num_credito 
		    --JOIN bdicobranza:cb_triad_salida f ON f.out_co_account_id='00000000'||b.num_credito 
		    JOIN bdicobranza:cb_triad_salida f ON f.num_credito = b.num_credito 
		 WHERE b.num_producto <> '6800' 
		   AND b.status_cred = 'AA'
		   AND b.num_credito not in (select vNumCredito_2 from paso_customer)
		   AND b.num_credito >= cCredIni_cnr AND b.num_credito  < cCredFin_cnr 
		   AND b.num_credito NOT IN(SELECT ti_account_id from bdicobranza:cb_triad_customer_2 WHERE fecha_proceso = vFechahoy)
		   AND d.prox_fecha_pago+f.out_coll_next_call_days = vFechahoy; --VIGENTES EN EL CAMPO OUT-COLL-NEXT-CALL-DAYS*		


		update statistics medium for table paso_customer;
	
		
		begin; 
          delete from paso_customer
          where vNumCredito_2 in (SELECT num_credito FROM bdicred:sd_inactivos_12meses WHERE num_credito > '600000000001');
		commit;

        update statistics medium for table paso_customer;

		-- 2020-02-11 Se cambia el origen de obtención del Behaviour, ahora considerar si hay actualización en el mes de proceso vFechahoy REING
		SELECT max(fecha_reporte) INTO dFechaMax_CleanBehav
		  FROM bdicred:sd_clientes_clean_behavior 
		  WHERE fecha_reporte between vPriDiaMes and vUltDiaMes   
		  AND status_bit is null;
		
		SELECT max(fecha_reporte) INTO dFechaMax_Dirty
		  FROM bdicred:sd_clientes_dirty_behavior 
		 WHERE fecha_reporte between vPriDiaMes and vUltDiaMes
		   AND status_bit is null;
		
		LET dFechaMax_CleanBehav = NVL(dFechaMax_CleanBehav,'01/01/1900');
		LET dFechaMax_Dirty = NVL(dFechaMax_Dirty,'01/01/1900');
		
    FOREACH WITH HOLD

		SELECT vNumCredito_2, vTI_CU_CUSTOMER_ID_2, vTipo_prod_2, num_producto, status_cred, dia_corte, fecha_apertura, prox_fecha_pago
		  INTO vNumCredito, v_numcte, vTipo_prod, cNumProducto, cStatusCred, vDiacorte, vTI_CU_DATE_FIRST_REL, vProx_fecha_pago
	      FROM paso_customer
		  
        
		let vTI_CU_CUSTOMER_ID = trim(v_numcte);
		 
        let iContGral = iContGral + 1;
	  
	  
	  if vDiacorte <= 0 then
	     CONTINUE FOREACH;
	  end if;
	  
      let vfecha_fin_mes_ant = date(vPriDiaMes - 1 units day);   -- 2017-10-31
	  let cDiacorte = vDiacorte;
	  let iMescorte = MONTH(vFechahoy);
	  let iDia_hoy  = DAY(vFechahoy);
	  
	  LET vFechacorte = vProx_fecha_pago;
	  
	  if vTipo_prod = 'REV'	then
		   /*
		   if day(vFechahoy) <= vDiacorte then    --aqui debe ser menor igual (<=)  -- 20200829
		     let vFechacorte = mdy(month(vfecha_fin_mes_ant),lpad(cDiacorte,2,'0'),year(vfecha_fin_mes_ant)); 
		   elif day(vFechahoy) > vDiacorte then  -- aqui debe ser mayor (>)  --20200829
			  --let vFechacorte = mdy(month(vFechahoy),lpad(cDiacorte,2,'0'),year(vFechahoy)); -- no sería necesario esto
			  -- bastaría con esto: 
			  let vFechacorte =  mdy(month(vProx_fecha_pago), lpad(cDiacorte,2,'0'), year(vProx_fecha_pago));
		   end if;
		   */
		  IF day(vFechahoy) <= vDiacorte THEN 					
				LET cFechacorte = TO_CHAR(vFechacorte,'%Y%m%d');
		  ELSE 
			    LET vFechacorte =  mdy(month(vFechahoy),vDiacorte,year(vFechahoy));
			    LET cFechacorte = TO_CHAR(vFechacorte,'%Y%m%d');
		  END IF;	
		  
      else

		--FECHA DE CORTE: 
		IF vFechacorte IS NULL THEN 
			--LET cFechacorte = '-1'; 
			--IF vDiacorte <= 0 THEN CONTINUE foreach; END IF;
			LET vFechacorte = vFechahoy;
			LET vDiacorte	= DAY(vFechahoy);
		END IF;	

		IF vDiacorte = '1' AND vFechacorte =  mdy(month(vFechahoy),'2',year(vFechahoy))THEN 
			LET cFechacorte = TO_CHAR(vFechacorte,'%Y%m%d');
		ELSE
			IF day(vFechahoy) <= vDiacorte THEN 					
					LET cFechacorte = TO_CHAR(vFechacorte,'%Y%m%d');
			ELSE 
				LET vFechacorte =  bdicred:monthadd(vFechacorte,-1);				
				LET cFechacorte = TO_CHAR(vFechacorte,'%Y%m%d');
				END IF;
		END IF;	
		
		
	  end if;
	   
	   --let vFechacorteant = date(vFechacorte -1 units month);  
	   LET vFechacorteant =  bdicred:monthadd(vFechacorte,-1);
	   --let vFechacorte_24MsAntes = date(vFechacorte -2 units year);
	   let vFechacorte_24MsAntes = bdicred:monthadd(vFechacorte,-2);
	   	   

		-- Validar primero si los datos cambiaroN
		
	   --select count(*) into iExisteCuenta
	  /*  select limit 1 empresa into cEmpresa_10
		  from "informix".cb_triad_customer_2
		 --where TI_CU_CUSTOMER_ID = vTI_CU_CUSTOMER_ID and TI_ACCOUNT_ID = vNumCredito;  -- quitar 20190924
		 where TI_ACCOUNT_ID = vNumCredito;   -- habilitar 20190924
	*/
		select limit 1 empresa, ti_cu_phone_addr_ind, ti_cu_email_ind, ti_cu_cust_status, fecha_proceso 
		  into cEmpresa_10, vti_cu_phone_addr_ind_actual, vti_cu_email_ind_actual, vti_cu_cust_status_actual, dFechaProcAnt_cta
	      from "informix".cb_triad_customer_2
		  where TI_ACCOUNT_ID = vNumCredito;
     
		  
		IF NVL(cEmpresa_10,'') <> '' THEN  
		   let iExisteCuenta = 1; 
		END IF;
	   
        --if vFecha_proceso is null or vFecha_proceso = '01/01/1900' then
		if iExisteCuenta <= 0 then
		   let vTI_CU_RAW_SCORE_2 = '+0000000';
		   let vTI_CU_ALIGNED_SCORE_2  = '+0000000';
		   let vTI_CU_BAR_FACTOR = '+00000000';
		   let vTI_CU_RECOVERY_FACTOR = '+00000000';
		   let vTI_CU_SCRD_ID_2 = '+0000';
		else
		   --let iExisteCuenta = 1;
		   --let vNumCredito_salida = '00000000' || vNumCredito;
		   let iCuentaProcAntes = 1;
		   
		   select limit 1 out_raw_score2, out_aligned_score, out_bar_factor, out_recovery_factor, out_scrd_id
		     into vTI_CU_RAW_SCORE_2, vTI_CU_ALIGNED_SCORE_2, vTI_CU_BAR_FACTOR, vTI_CU_RECOVERY_FACTOR, vTI_CU_SCRD_ID_2
             from bdicobranza:cb_triad_salida
			 --where out_co_account_id = vNumCredito_salida; 
			 where num_credito = vNumCredito;
		
			 if vTI_CU_RAW_SCORE_2 is null or vTI_CU_RAW_SCORE_2 = '' then
			    --let vTI_CU_RAW_SCORE_2 = '0';
				let vTI_CU_RAW_SCORE_2 = '+0000000';        --2019/08/13
			 end if;
			 if vTI_CU_ALIGNED_SCORE_2 is null or vTI_CU_ALIGNED_SCORE_2 = '' then
                --let vTI_CU_ALIGNED_SCORE_2  = '0';
				let vTI_CU_ALIGNED_SCORE_2  = '+0000000';   --2019/08/13
             end if;			 
			 if vTI_CU_BAR_FACTOR is null or vTI_CU_BAR_FACTOR = '' then
			    let vTI_CU_BAR_FACTOR = '+00000000';        --2019/08/13
				--let vTI_CU_BAR_FACTOR = '0';
		     end if;
			 if vTI_CU_RECOVERY_FACTOR is null or vTI_CU_RECOVERY_FACTOR = '' then
			    let vTI_CU_RECOVERY_FACTOR = '+00000000';   --2019/08/13 
				--let vTI_CU_RECOVERY_FACTOR = '0';
		     end if;
			 if vTI_CU_SCRD_ID_2 is null or vTI_CU_SCRD_ID_2 = '' then
			    let vTI_CU_SCRD_ID_2 = '+0000';             --2019/08/13 
				--let vTI_CU_SCRD_ID_2 = '0';
			 end if;
		end if;
	  
	   /*
       --select limit 1 to_char(a.fecha_insert,"%Y%m%d"), nvl(a.numcte_ref,''), to_char(b.fecha_nac, "%Y%m%d"), lpad(r.numero_region,4,'0'), c.sucursal
	   select limit 1  nvl(a.numcte_ref,''), b.fecha_nac, NVL(r.numero_region,0), c.sucursal
           into v_numcte_ref, vTI_CU_DATE_OF_BIRTH, vTI_CU_GEOGRAPHIC_CODE, vTI_CU_BRANCH_NUMBER
           --from bdinteg@coppel_cor:si_cliente a
		   from bdinteg:si_cliente a
            --left outer join bdinteg@coppel_cor:si_ctepf b on (a.numcte = b.numcte)
			left outer join bdinteg:si_ctepf b on (a.numcte = b.numcte)
            left outer join bdinteg:si_sucursales c on (a.sucursal = c.sucursal)
                     left outer join bdinteg:si_ciudades ci on (c.estado = ci.estado and c.ciudad = ci.ciudad)
                               left outer join bdinteg:si_catciudades cat on (cat.numerociudad = ci.ciudad_coppel)
                                  left outer join bdinteg:si_regiones r on (cat.numero_region = r.numero_region)
         where a.numcte = vTI_CU_CUSTOMER_ID;
	     */ -- En Stagging crea conflicto la tabla temporal
	 
	    
	    --select nvl(a.numcte_ref,''), b.fecha_nac, NVL(c.region,0), a.sucursal
		select a.numcte_ref, b.fecha_nac, c.region, a.sucursal
          into v_numcte_ref_2, vTI_CU_DATE_OF_BIRTH, vTI_CU_GEOGRAPHIC_CODE_2, vTI_CU_BRANCH_NUMBER
          from bdinteg:si_cliente a
               left outer join bdinteg:si_ctepf b on (a.numcte = b.numcte)
			   left outer join paso_suc_region c on (a.sucursal = c.sucursal)
		  where a.numcte = vTI_CU_CUSTOMER_ID;
       
	   let v_numcte_ref = nvl(v_numcte_ref_2,'');
       let vTI_CU_GEOGRAPHIC_CODE = nvl(vTI_CU_GEOGRAPHIC_CODE_2,0);
	   
      if v_numcte_ref <> '' and v_numcte_ref <> '0' then 
           let vTI_CU_CUST_TYPE = '1';
	  else	
		   let vTI_CU_CUST_TYPE = '0'; 	
      end if;
	 
      if iExisteCuenta > 0 then	 

		  --select limit 1 1 into vSitesp
			select limit 1 date(fchalta) into dfchalta_sitesp
			from bdisitesp:se_ctessitespcte
		   where numcte = vTI_CU_CUSTOMER_ID
			 and situacion = 'F'
			 and causa in(42,43,101,102,107);
		  
			if NVL(dfchalta_sitesp,'') <> '' then
				if dfchalta_sitesp >= vFechahoy then
					   let vTI_CU_CUST_STATUS = '1'; 
					   let cActualiza_sitesp = 'S';
				else
					   let vTI_CU_CUST_STATUS = '0';  
				end if;   
			else
				let vti_cu_cust_status = vti_cu_cust_status_actual;
			end if;
			
			-- 0=telefono confirmado y direccion registrada.    1=telefono sin confirmar, direccion registrada.
			-- 2=telefono confirmado, sin direccion registrada. 3=telefono sin confirmar y sin direccion registrada.
			
			--select limit 1 1 into vCuentaTels 
			select limit  1 date(fecha_hora) into dFechahora_tel
			  from bdinteg:si_telefonos_actual 
			 where numcte = vTI_CU_CUSTOMER_ID 
			   and tipo_tel in(1,2) 
			   and status_tel = 'A'; 
			
			if NVL(dFechahora_tel,'') <> '' then
				if dFechahora_tel >= vFechahoy THEN
					
					   let vTI_CU_PHONE_ADDR_IND = '0'; 
					   LET cActualiza_tel = 'S';
				else 
					   let vTI_CU_PHONE_ADDR_IND = '1'; 
				end if;
			ELSE
			   let vti_cu_phone_addr_ind = vti_cu_phone_addr_ind_actual;
			END IF;
			
			-- 0 = no email address on file    1 = email address on fileIndicator for email address on file.
			--select count(*) into vCuentaEmails 
			 --select limit 1 1 into vCuentaEmails 
			 select limit 1 fecha_hora into cFecha_hora_email
			 from bdinteg:si_correos
			 where numcte = vTI_CU_CUSTOMER_ID
			   and status_correo = 'A';
			   
			   let dFecha_hora_email = mdy(substr(cFecha_hora_email,6,2), substr(cFecha_hora_email,9,2), substr(cFecha_hora_email,1,4));
			   
			if NVL(dFecha_hora_email,'') <> '' then
				if dFecha_hora_email >= vFechahoy then
					   let vTI_CU_EMAIL_IND = '1'; 
					   let cActualiza_email = 'S';
				else
					   let vTI_CU_EMAIL_IND = '0'; 
				end if; 
			else
				let vti_cu_email_ind = vti_cu_email_ind_actual;
			end if;
			
	  ELSE     ---- CUENTA NO EXISTE PREVIAMENTE EN cb_triad_customer_2
	  
			select limit 1 1 into vSitesp
			from bdisitesp:se_ctessitespcte
		   where numcte = vTI_CU_CUSTOMER_ID
			 and situacion = 'F'
			 and causa in(42,43,101,102,107);
		  
			if nvl(vSitesp,0) > 0 then 
			   let vTI_CU_CUST_STATUS = '1'; 
			else
			   let vTI_CU_CUST_STATUS = '0';  
			end if;
	 	
			-- 0=telefono confirmado y direccion registrada.    1=telefono sin confirmar, direccion registrada.
			-- 2=telefono confirmado, sin direccion registrada. 3=telefono sin confirmar y sin direccion registrada.
			
			--select count(*) into vCuentaTels 
			select limit 1 1 into vCuentaTels 
			  from bdinteg:si_telefonos_actual 
			 where numcte = vTI_CU_CUSTOMER_ID 
			   and tipo_tel in(1,2) 
			   and status_tel = 'A'; 
			
			if nvl(vCuentaTels,0) > 0 then 
			   let vTI_CU_PHONE_ADDR_IND = '0'; 
			else 
			   let vTI_CU_PHONE_ADDR_IND = '1'; 
			end if;
			
			-- 0 = no email address on file    1 = email address on fileIndicator for email address on file.
			--select count(*) into vCuentaEmails 
			 --select limit 1 1 into vCuentaEmails 
			select limit 1 1 into vCuentaEmails 
			  from bdinteg:si_correos
			 where numcte = vTI_CU_CUSTOMER_ID
			   and status_correo = 'A';

			if nvl(vCuentaEmails,0) > 0 then 
			   let vTI_CU_EMAIL_IND = '1'; 
			else
			   let vTI_CU_EMAIL_IND = '0'; 
			end if; 
	  	  
      END IF;   
        --- Pendientes el llenado de estos campos hasta encontrar como generar numeros aleatorios en informix
        --- TI_CU_TEST_DIGITS_1, TI_CU_TEST_DIGITS_2, TI_CU_TEST_DIGITS_3, TI_CU_TEST_DIGITS_4
		IF iExisteCuenta <= 0  THEN
let iRandomNumber1 = iContGral;
let iRandomNumber2 = iContGral + 1;
let iRandomNumber3 = iContGral + 2;
let iRandomNumber4 = iContGral + 3;


			execute procedure bdicred:informix.sp817_setrandomseed(iRandomNumber1);
			call bdicred:informix.sp817_random() returning fValor;
			let cValor = fValor;
			let cRandomNumber1 = right(trim(REPLACE(cValor,'.','0')),4);
			
			execute procedure bdicred:informix.sp817_setrandomseed(iRandomNumber2);
			call bdicred:informix.sp817_random() returning fValor;
			let cValor = fValor;
			let cRandomNumber2 = right(trim(REPLACE(cValor,'.','0')),4);
			
			execute procedure bdicred:informix.sp817_setrandomseed(iRandomNumber3);
			call bdicred:informix.sp817_random() returning fValor;
			let cValor = fValor;
			let cRandomNumber3 = right(trim(REPLACE(cValor,'.','0')),4);
			
			execute procedure bdicred:informix.sp817_setrandomseed(iRandomNumber4);
			call bdicred:informix.sp817_random() returning fValor;
			let cValor = fValor;
			let cRandomNumber4 = right(trim(REPLACE(cValor,'.','0')),4);
			
			let vTI_CU_TEST_DIGITS_1 = lpad(trim(cRandomNumber1),4,'0');
			let vTI_CU_TEST_DIGITS_2 = lpad(trim(cRandomNumber2),4,'0');
			let vTI_CU_TEST_DIGITS_3 = lpad(trim(cRandomNumber3),4,'0');
			let vTI_CU_TEST_DIGITS_4 = lpad(trim(cRandomNumber4),4,'0');
		END IF;
	  
	  --cambiarlo por este
	  if cNumProducto = '6011' then
		 --select fecha_apertura into vTI_CU_DATE_LAST_RESTRCTRE
         --  from bdicred:sd_maecredcrd
         -- where num_credito = vNumCredito; 
         let vTI_CU_DATE_LAST_RESTRCTRE = vTI_CU_DATE_FIRST_REL;
	  else		
 	     let vTI_CU_DATE_LAST_RESTRCTRE = date(1);

      end if;		

	   
	   ---- Queries para ambos REV y CNR
	   IF iExisteCuenta <= 0 THEN
		   select score_prop, bs_score, evalua_cc  into iScoreProp, iScoreBc, v_evalua_cc
			 from bdisolic:ss_revision_determinacion
			where num_solicitud = vNumCredito;
			 
			
			if iScoreProp is not null then
			   let vTI_CU_APP_SCORE = round(iScoreProp,0);
			else
			   let vTI_CU_APP_SCORE = 0;
			end if;   
			

			
				--  TI_CU_EXTERNAL_RISK_FACTOR_3 +00000000, este campo no cambia pq ya se tenÃ?Â­a la tabla (sd_param_reservas) con los valores a asignar
					 if iScoreBc is not null then
					 
						   if iScoreBc > 0 then
							   let cScoreBc = round(iScoreBc);
							   
							   select valor_final into cValor_distrib_bcscore
								 from cb_triad_distrib_bcscore
								where valor_min >= iScoreBc  and valor_max <= iScoreBc; 
							   
								if cValor_distrib_bcscore is not null and cValor_distrib_bcscore <> '' then
								   let vTI_CU_EXTERNAL_RISK_FACTOR_3 = cValor_distrib_bcscore;
								else
								   let vTI_CU_EXTERNAL_RISK_FACTOR_3 = '0'; 
								end if;
								
								let vTI_CU_EXTERNAL_EXCLUSION_CAT_3 = ' ';
								let vTI_CU_EXTERNAL_EXCLUSION_IND_3 = '00';
								let vTI_CU_RAW_SCORE_3 = vTI_CU_EXTERNAL_RISK_FACTOR_3;   -- Puntaje bruto del BC Score
								
						   else
								let vTI_CU_EXTERNAL_RISK_FACTOR_3 = '0';
								let vTI_CU_EXTERNAL_EXCLUSION_CAT_3 = 'E';  --Rellenar con datos de BC Score	(Si no tiene BC Score marcar como E)
								let vTI_CU_EXTERNAL_EXCLUSION_IND_3 = '01';
								let vTI_CU_RAW_SCORE_3 = vTI_CU_EXTERNAL_RISK_FACTOR_3;
						   end if;				   
					 else
					   let vTI_CU_EXTERNAL_RISK_FACTOR_3 = '0';
					   let vTI_CU_EXTERNAL_EXCLUSION_CAT_3 = 'E';  --Rellenar con datos de BC Score	(Si no tiene BC Score marcar como E)
					   let vTI_CU_EXTERNAL_EXCLUSION_IND_3 = '01';
					   let vTI_CU_RAW_SCORE_3 = vTI_CU_EXTERNAL_RISK_FACTOR_3;
					end if;   
					
					let vTI_CU_ALIGNED_SCORE_3 = vTI_CU_RAW_SCORE_3;
					---- fin bloque score

				   
					let vTI_CU_EXTERNAL_GOOD_BAD_IND_3 = '0';  -- siempre se envÃ?Â­a este valor
		   
					-- 1 - No hit   2 - Hit con informacion   3 - Hit sin informacion
					-- Para obtener TI_CU_CUST_SPR_TYPE
					/*select limit 1 evalua_cc
					  into v_evalua_cc  
					  from bdisolic:ss_resum_scor_fin 
					 where empresa = vEmpresa
					   and num_solicitud = vNumCredito;
					*/
					
					if (v_evalua_cc = '' or v_evalua_cc is null) or v_evalua_cc = 'X' then  
					   let vTI_CU_CUST_SPR_TYPE = '1';
					elif v_evalua_cc = '0' or v_evalua_cc = '1' then
					   let vTI_CU_CUST_SPR_TYPE = '2';
					elif cScoreBc_a <> ''  then
					   let vTI_CU_CUST_SPR_TYPE = '3';
					else
					   let vTI_CU_CUST_SPR_TYPE = '0';
					end if;
					-- dentro de 2 - Hit con informacion
					-- 0 buen comportamiento -- 1 mal comportamiento
					
					let vTI_CU_CB_SCORE_TYPE = '1'; --siempre se envÃ?Â­a este valor
		   

	   END IF;
	   
	   
			IF vTipo_prod = 'REV' then
				    ---En esta va lo de  +0001 - Tarjeta Clean Hit ,+0002 - Tarjeta Clean No Hit, +0003 - Tarjeta Dirty, +0004 Prestamo
					-- 2020-02-11 Se cambia el origen de obtención del Behaviour
			
				IF dFechaMax_CleanBehav <> '01/01/1900' OR dFechaMax_Dirty <> '01/01/1900' THEN

					IF vFechahoy = dFechaMax_CleanBehav OR  vFechahoy = dFechaMax_Dirty THEN
					    --si fecha_proceso = dFechaMax_CleanBehav or fecha_proceso_gral = dFechaMax_Dirty
						--    actualizar
						let cActualiza_behaviour = 'S';
						
						SELECT score INTO cScoreBehavior 
						  FROM bdicred:sd_clientes_clean_behavior
						 WHERE fecha_reporte = dFechaMax_CleanBehav
						   AND num_credito = vNumCredito 
						   AND status_bit is null;
						
						-- NULL SI está la cuenta pero con valor null, '' no está la cuenta
						IF cScoreBehavior IS NULL OR cScoreBehavior = '0' THEN
						   LET iScoreBehavior = 0;
						ELIF cScoreBehavior = ''  THEN
						   --LET cScoreBehavior = '';
						   -- Buscar en Dirty
						   SELECT score INTO cScoreBehavior 
							 FROM bdicred:sd_clientes_dirty_behavior
							WHERE fecha_reporte = dFechaMax_Dirty
							  AND num_credito = vNumCredito 
							  AND status_bit is null;
					
							LET cScoreBehavior = NVL(cScoreBehavior,'');
							IF cScoreBehavior = '' OR cScoreBehavior = 0 THEN
							   LET iScoreBehavior = 0;
							   let cActualiza_behaviour = '';
							ELSE
							   LET iScoreBehavior = cScoreBehavior;
							   LET vTI_CU_SCRD_ID_1 = 3;
							END IF;
						ELSE
							LET iScoreBehavior = cScoreBehavior;
							LET vTI_CU_SCRD_ID_1 = 1;
						END IF;
					ELIF dFechaProcAnt_cta <> (vFechahoy -1 UNITS DAY) 
						    AND (dFechaProcAnt_cta < dFechaMax_CleanBehav OR dFechaProcAnt_cta < dFechaMax_Dirty) THEN
							
							let cActualiza_behaviour = 'S'; 
							
							SELECT score INTO cScoreBehavior 
							  FROM bdicred:sd_clientes_clean_behavior
							 WHERE fecha_reporte = dFechaMax_CleanBehav
							   AND num_credito = vNumCredito 
							   AND status_bit is null;
							
							-- NULL SI está la cuenta pero con valor null, '' no está la cuenta
							IF cScoreBehavior IS NULL OR cScoreBehavior = '0' THEN
							   LET iScoreBehavior = 0;
							ELIF cScoreBehavior = ''  THEN
							   --LET cScoreBehavior = '';
							   -- Buscar en Dirty
							   SELECT score INTO cScoreBehavior 
								 FROM bdicred:sd_clientes_dirty_behavior
								WHERE fecha_reporte = dFechaMax_Dirty
								  AND num_credito = vNumCredito 
								  AND status_bit is null;
						
								LET cScoreBehavior = NVL(cScoreBehavior,'');
								IF cScoreBehavior = '' OR cScoreBehavior = 0 THEN
								   LET iScoreBehavior = 0;
								   let cActualiza_behaviour = '';
								ELSE
								   LET iScoreBehavior = cScoreBehavior;
								   LET vTI_CU_SCRD_ID_1 = 3;
								END IF;
							ELSE
								LET iScoreBehavior = cScoreBehavior;
								LET vTI_CU_SCRD_ID_1 = 1;
							END IF;
					
					ELSE
					    LET iScoreBehavior = 0;
					    let cActualiza_behaviour = '';
					END IF;
				
				ELSE
					LET iScoreBehavior = 0;
					let cActualiza_behaviour = '';
				
				END IF;
				
			ELIF vTipo_prod = 'CNR' then
				LET iScoreBehavior = 0;
				LET vTI_CU_SCRD_ID_1 = 4;  --Para Plazo
			END IF;
				
					--if iScoreBehavior <> '' and iScoreBehavior is not null then 
					--if iScoreBehavior <> 0 and nvl(iScoreBehavior,'') <> '' then   --20191017
					if iScoreBehavior <> 0 then   --20200213
						select valor_final into  cScoreBehavior_calif
						from bdicobranza:cb_riesgo_behavscore
						where num_producto = cNumProducto
						--and valor_min >= iScoreBehavior and valor_max <= iScoreBehavior;
						and iScoreBehavior >= valor_min  and  iScoreBehavior <= valor_max;
						
						if cScoreBehavior_calif is not null and cScoreBehavior_calif <> '' then
						   let vTI_CU_EXTERNAL_RISK_FACTOR_1 = cScoreBehavior_calif;
						   let vTI_CU_RAW_SCORE_1 = cScoreBehavior_calif;
						else
						   let vTI_CU_EXTERNAL_RISK_FACTOR_1 = '0';
						   let vTI_CU_RAW_SCORE_1 = '0';            --20191017  
						end if;
						let vTI_CU_EXTERNAL_EXCLUSION_CAT_1 = ' ';
						let vTI_CU_EXTERNAL_EXCLUSION_IND_1 = '00';
						--let vTI_CU_RAW_SCORE_1 = cScoreBehavior_calif; --20191017
				   else
					   let vTI_CU_EXTERNAL_RISK_FACTOR_1 = '0';
					  
					   let vTI_CU_RAW_SCORE_1 = '0';
					   let vTI_CU_EXTERNAL_EXCLUSION_CAT_1 = 'E';
					   let vTI_CU_EXTERNAL_EXCLUSION_IND_1 = '01';
					  
				   end if;
			
			---- fin bloque comportamiento
 			
                let vTI_CU_ALIGNED_SCORE_1 = vTI_CU_RAW_SCORE_1;
                --let TI_CU_EXTERNAL_RISK_FACTOR_1 = rpad(TI_CU_RAW_SCORE_1,9,0);
	   
	   
	   ---- Queries para ambos REV y CNR	
	   
        -- VALIDAR QUE TIPO DE CUENTAS ES  
        if vTipo_prod = 'CNR' then
            ------------------------------- S I    C U E N T A    A    P L A Z O
			let cCantCuentasPrestamo = 1;
            let vTI_CU_NUM_LOAN_ACCT = lpad(cCantCuentasPrestamo,2,'0');
			
            if vFechacorte = vFechahoy then  
		      LET vPP20_PROC_CODE = 'REVC';  
			else 
			  LET vPP20_PROC_CODE = 'COLL'; 
		    end if;
			
			-- TI_CU_EXTERNAL_GOOD_BAD_IND_1 - INI
	        -- SI como se platicÃ?Â³ en la junta este campo TI_CU_EXTERNAL_GOOD_BAD_IND_1 no se va a rellenar, como decÃ?Â­a en layout, con el score de comportamiento
			-- entonces se calcularÃ?Â­a asÃ?Â­, primero validar si cuenta REV o CNR
			
			-- calcular 6 meses atrÃ?Â¡s de la fecha corte
			if vFechacorte = vFechahoy then  -- Agregar validación 20200519 
				 select nvl(num_vencidos1,0), nvl(num_vencidos2,0), nvl(num_vencidos3,0), nvl(num_vencidos4,0), nvl(num_vencidos5,0), nvl(num_vencidos6,0)
				   into iNum_vencidos1, iNum_vencidos2, iNum_vencidos3, iNum_vencidos4, iNum_vencidos5, iNum_vencidos6
				   from bdicobranza:cb_triad_sdos_inds_cnr
				  where empresa = vEmpresa
					and num_credito = vNumCredito;
				
					if iNum_vencidos1 > iMaxNum_vencido_en6 then  let iMaxNum_vencido_en6 = iNum_vencidos1; end if;
					if iNum_vencidos2 > iMaxNum_vencido_en6 then  let iMaxNum_vencido_en6 = iNum_vencidos2;	end if;
					if iNum_vencidos3 > iMaxNum_vencido_en6 then  let iMaxNum_vencido_en6 = iNum_vencidos3; end if;
					if iNum_vencidos4 > iMaxNum_vencido_en6 then  let iMaxNum_vencido_en6 = iNum_vencidos4; end if;
					if iNum_vencidos5 > iMaxNum_vencido_en6 then  let iMaxNum_vencido_en6 = iNum_vencidos5; end if;
					if iNum_vencidos6 > iMaxNum_vencido_en6 then  let iMaxNum_vencido_en6 = iNum_vencidos6; end if;
					
					if iMora_en_6meses = 0  then
						let vTI_CU_EXTERNAL_GOOD_BAD_IND_1 = '0'; -- ExclusiÃ?Â³n
					--elif iMora_en_6meses >= 60 and iMora_en_6meses <= 89 then
					elif iMora_en_6meses = 2 then --60 and iMora_en_6meses <= 89 then
						let vTI_CU_EXTERNAL_GOOD_BAD_IND_1 = '2'; -- indeterminate
					--elif iMora_en_6meses >= 90 then
					elif iMora_en_6meses >= 3 then
						let vTI_CU_EXTERNAL_GOOD_BAD_IND_1 = '3'; -- bad
					else
						let vTI_CU_EXTERNAL_GOOD_BAD_IND_1 = '1'; -- Good
					end if;
				
				-- ESTE DATO SE OBTENDRÃ?Â DE sd_indicador_cred_crd (NUEVA columna: max_mora_hist)
				-- TI_CU_EXTERNAL_MAX_DELQ_1   Maxima morosidad historica de la cuenta (maximo numero de meses vencidos historicos de la cuenta), topada a 9. en los Ã?Âºltimos dos aÃ?Â±os
				--- Mientras se crea en  sd_indicador_cred_crd  ---PENDIENTE QUITAR   
				--if vFechahoy = vFechacorte then   --Quitar 20200519
				   
					 --select (case when nvl(max_mora_hist,0) >= 9 then 9 else nvl(max_mora_hist,0) end)
					 select max_mora_hist
					  into vMoraMaxHist
					  from bdicred:sd_indicador_cred_crd
					 where empresa = vEmpresa
					   and num_credito = vNumCredito;
					
					if vMoraMaxHist is not null then
					  if vMoraMaxHist >= 9 then let vMoraMaxHist = 9; end if;
					  let vTI_CU_EXTERNAL_MAX_DELQ_1 = vMoraMaxHist;
					else 
					  let vTI_CU_EXTERNAL_MAX_DELQ_1 = '0';
					end if;    

			end if;
			
                -- esta lÃ?Â­nea siempre va
				let vTI_CU_EXTERNAL_MAX_DELQ_3  =  vTI_CU_EXTERNAL_MAX_DELQ_1;
            
				-- TI_CU_NUM_REV_ACCT si es cuenta rev = 01, si no es = 00.
                let vTI_CU_NUM_REV_ACCT = '00';
				
        -- INFO A OBTENER CON LA CUENTA REV     
        elif vTipo_prod = 'REV' then
		   
		   ------------------------------- S I    C U E N T A     R E V O L V E N T E
		   let vTI_RV_ACCOUNT_ID = vNumCredito;
		   let vTI_CU_NUM_REV_ACCT = '01';  --Es TDC
		   let vTI_CU_NUM_LOAN_ACCT = '00';
		   
		   -- ESTE DATO SE OBTENDAÂ DE sd_indicador_cred (NUEVA columna: max_mora_hist)
		   
		   if vFechacorte = vFechahoy then  
		      LET vPP20_PROC_CODE = 'REVC'; --4 podrÃ?Â¡ tener tambiÃ?Â©n el valor COLL 
		   else    
			  LET vPP20_PROC_CODE = 'COLL';  
		   end if;
		   
		   -- TI_CU_EXTERNAL_GOOD_BAD_IND_1 - INI
	        -- SI como se platico en la junta este campo TI_CU_EXTERNAL_GOOD_BAD_IND_1 no se va a rellenar, como decia en layout, con el score de comportamiento
			-- entonces se calcularaa asi, primero validar si cuenta REV o CNR
			
			-- calcular 6 meses atrÃ?Â¡s de la fecha corte
			if vFechacorte = vFechahoy then 
				 --select nvl(num_vencidos1,0), nvl(num_vencidos2,0), nvl(num_vencidos3,0), nvl(num_vencidos4,0), nvl(num_vencidos5,0), nvl(num_vencidos6,0)
				 select num_vencidos1, num_vencidos2, num_vencidos3, num_vencidos4, num_vencidos5, num_vencidos6
				   into iNum_vencidos1, iNum_vencidos2, iNum_vencidos3, iNum_vencidos4, iNum_vencidos5, iNum_vencidos6
				   from bdicobranza:cb_triad_sdos_inds_tdc
				  where empresa = vEmpresa
					and num_credito = vNumCredito;
				
				  if iNum_vencidos1 is not null then
					 if iNum_vencidos1 > iMaxNum_vencido_en6 then  
						let iMaxNum_vencido_en6 = iNum_vencidos1; 
					 end if;
				  end if;
				  if iNum_vencidos2 is not null then
					 if iNum_vencidos2 > iMaxNum_vencido_en6 then 
						let iMaxNum_vencido_en6 = iNum_vencidos2; 
					 end if;
				  end if;
				  if iNum_vencidos3 is not null then 	
					 if iNum_vencidos3 > iMaxNum_vencido_en6 then
						let iMaxNum_vencido_en6 = iNum_vencidos3; 
					 end if;
				  end if;
				  if iNum_vencidos4 is not null then 	
					 if iNum_vencidos4 > iMaxNum_vencido_en6 then  
						let iMaxNum_vencido_en6 = iNum_vencidos4; 
					 end if;
				  end if;
				  if iNum_vencidos5 is not null then 	
					 if iNum_vencidos5 > iMaxNum_vencido_en6 then 
						let iMaxNum_vencido_en6 = iNum_vencidos5; 
					 end if;
				  end if;
				  if iNum_vencidos6 is not null then 	
					 if iNum_vencidos6 > iMaxNum_vencido_en6 then
						let iMaxNum_vencido_en6 = iNum_vencidos6; 
					 end if;
				  end if;
				
				if iMora_en_6meses = 0  then
					let vTI_CU_EXTERNAL_GOOD_BAD_IND_1 = '0'; -- ExclusiÃ?Â³n
				--elif iMora_en_6meses >= 60 and iMora_en_6meses <= 89 then
				elif iMora_en_6meses = 2 then --60 and iMora_en_6meses <= 89 then
					let vTI_CU_EXTERNAL_GOOD_BAD_IND_1 = '2'; -- indeterminate
				--elif iMora_en_6meses >= 90 then
				elif iMora_en_6meses >= 3 then
					let vTI_CU_EXTERNAL_GOOD_BAD_IND_1 = '3'; -- bad
				else
					let vTI_CU_EXTERNAL_GOOD_BAD_IND_1 = '1'; -- Good
				end if;
			   
				--elif (vFecha_proceso is not null or vFecha_proceso <> '01/01/1900') and (vFechahoy = vFechacorte) then
				--if vFechahoy = vFechacorte then    -- Quitar validación 20200519
	  
					--select (case when nvl(max_mora_hist,0) >= 9 then 9 else nvl(max_mora_hist,0) end)
					select max_mora_hist
					  into vMoraMaxHist
					  from bdicred:sd_indicador_cred
					 where empresa = vEmpresa
					   and num_credito = vNumCredito;
					
					if vMoraMaxHist is not null then
					  if vMoraMaxHist > 9 then let vMoraMaxHist = 9; end if; 
					  let vTI_CU_EXTERNAL_MAX_DELQ_1 = round(vMoraMaxHist,0);
					else 
					  let vTI_CU_EXTERNAL_MAX_DELQ_1 = '0';
					end if;    
				
					-- TI_CU_NUM_REV_ACCT si es cuenta rev = 01, si no es = 00.
					--let vTI_CU_NUM_REV_ACCT = '01';
            end if;
			 
			 let vTI_CU_NUM_LOAN_ACCT = '00';
        end if;
		
   /* if  iExisteCuenta > 0 then
		-- Actualizar cuales datos cambiaron
		if cActualiza_tel = ''  then -- Actualiza el tel y a todo lo demás le pone valor de ayer
		   let vti_cu_phone_addr_ind = vti_cu_phone_addr_ind_actual;
		end if;
		if cActualiza_email = ''  then
		   let vti_cu_email_ind = vti_cu_email_ind_actual;
		end if;
		if cActualiza_sitesp = '' then 
		   let vti_cu_cust_status = vti_cu_cust_status_actual;
		end if;
		if cActualiza_behaviour = '' then  
		   let vti_cu_external_risk_factor_1 = vti_cu_external_risk_factor_1_actual;
		   let vti_cu_external_exclusion_cat_1 = vti_cu_external_exclusion_cat_1_actual;
		   let vti_cu_external_exclusion_ind_1 = vti_cu_external_exclusion_ind_1_actual;
	       let vti_cu_scrd_id_1 = vti_cu_scrd_id_1_actual;
		   let vti_cu_raw_score_1 = vti_cu_raw_score_1_actual;
		   let vti_cu_aligned_score_1 = vti_cu_aligned_score_1_actual;
		end if;
	end if;
   */
    if  iExisteCuenta > 0 and (vFechahoy <> vFechacorte) then --Existe cuenta y fecha proc diferente de fecha corte INI
		IF cActualiza_behaviour = 'S' AND 
		   (cActualiza_tel = 'S' OR  cActualiza_email = 'S' OR cActualiza_sitesp= 'S' )   THEN
			begin;
		  --Actualiza todo lo del diario incluido BEHAVIOR
			UPDATE "informix".cb_triad_customer_2 SET 
			         ti_cu_customer_id = vTI_CU_CUSTOMER_ID,   --El cliente  cuando hay fusiones
			          pp20_proc_code = vPP20_PROC_CODE,        --VALIDAR QUE TIPO DE CUENTAS ES  si es corte   = 'REVC';   si no  = 'COLL'; 
			          pp20_proc_date_cymd = vPP20_PROC_DATE_CYMD, --Fecha hoy
				     ti_cu_cust_type = vti_cu_cust_type,			--Si tiene referencia como cliente.   
			         ti_cu_phone_addr_ind = vti_cu_phone_addr_ind,  --Telefono
			          ti_cu_email_ind = vti_cu_email_ind,           --Correo
			           ti_cu_cust_status = vti_cu_cust_status,      --Situacion especial
					 ti_cu_geographic_code = vti_cu_geographic_code, --Regi+on
					 ti_cu_bar_factor = vti_cu_bar_factor,            --Datos de TRIAD 
					 ti_cu_recovery_factor = vti_cu_recovery_factor,  --Datos de TRIAD
				     ti_cu_scrd_id_2 = vti_cu_scrd_id_2,              --Datos de TRIAD 
				      ti_cu_raw_score_2 = vti_cu_raw_score_2,         --Datos de TRIAD
				       ti_cu_aligned_score_2 = vti_cu_aligned_score_2,-- Datos de TRIAD
			         ti_cu_external_risk_factor_1 = vti_cu_external_risk_factor_1,    --Behavior
			          ti_cu_external_exclusion_cat_1 = vti_cu_external_exclusion_cat_1,  --behavir
				     ti_cu_external_exclusion_ind_1 = vti_cu_external_exclusion_ind_1,  --behavior
				     ti_cu_scrd_id_1 = vti_cu_scrd_id_1,   --behavior
				     ti_cu_raw_score_1 = vti_cu_raw_score_1, --behavior 
				     ti_cu_aligned_score_1 = vti_cu_aligned_score_1,  --behhavior
					 ti_cu_status_anterior = cStatusCred,   --Status_anterior
					 --fecha_corte = vFechacorte, empresa = vEmpresa, 
					 fecha_proceso = vFechahoy
			   WHERE TI_ACCOUNT_ID = vNumCredito;
		 commit; 
		    let iContador_upd = iContador_upd +1;
		ELIF cActualiza_behaviour <> 'S' AND 
		    (cActualiza_tel = 'S' OR  cActualiza_email = 'S' OR cActualiza_sitesp= 'S' ) THEN
			begin;
		  --Actualiza todo lo del diario menos BEHAVIOR
			UPDATE "informix".cb_triad_customer_2 SET 
			         ti_cu_customer_id = vTI_CU_CUSTOMER_ID,   --El cliente  cuando hay fusiones
			          pp20_proc_code = vPP20_PROC_CODE,        --VALIDAR QUE TIPO DE CUENTAS ES  si es corte   = 'REVC';   si no  = 'COLL'; 
			          pp20_proc_date_cymd = vPP20_PROC_DATE_CYMD, --Fecha hoy
				     ti_cu_cust_type = vti_cu_cust_type,			--Si tiene referencia como cliente.   
			         ti_cu_phone_addr_ind = vti_cu_phone_addr_ind,  --Telefono
			          ti_cu_email_ind = vti_cu_email_ind,           --Correo
			           ti_cu_cust_status = vti_cu_cust_status,      --Situacion especial
					 ti_cu_geographic_code = vti_cu_geographic_code, --Regi+on
					 ti_cu_bar_factor = vti_cu_bar_factor,            --Datos de TRIAD 
					 ti_cu_recovery_factor = vti_cu_recovery_factor,  --Datos de TRIAD
				     ti_cu_scrd_id_2 = vti_cu_scrd_id_2,              --Datos de TRIAD 
				      ti_cu_raw_score_2 = vti_cu_raw_score_2,         --Datos de TRIAD
				       ti_cu_aligned_score_2 = vti_cu_aligned_score_2,-- Datos de TRIAD
			         --ti_cu_external_risk_factor_1 = vti_cu_external_risk_factor_1,    --Behavior
			          --ti_cu_external_exclusion_cat_1 = vti_cu_external_exclusion_cat_1,  --behavir
				     --ti_cu_external_exclusion_ind_1 = vti_cu_external_exclusion_ind_1,  --behavior
				     --ti_cu_scrd_id_1 = vti_cu_scrd_id_1,   --behavior
				     --ti_cu_raw_score_1 = vti_cu_raw_score_1, --behavior 
				     --ti_cu_aligned_score_1 = vti_cu_aligned_score_1,  --behhavior
					 ti_cu_status_anterior = cStatusCred,   --Status_anterior
					 --fecha_corte = vFechacorte, empresa = vEmpresa, 
					 fecha_proceso = vFechahoy
			   WHERE TI_ACCOUNT_ID = vNumCredito;
			commit; 
			let iContador_upd = iContador_upd +1;		  
		
		ELIF cActualiza_behaviour <> 'S' AND 
		     cActualiza_tel <> 'S' AND  cActualiza_email <> 'S' AND  cActualiza_sitesp <> 'S'     THEN
		     --Se actualiza todo menos lo de behaviour ni lo de los otros 3 campos
			begin;
			   UPDATE "informix".cb_triad_customer_2 SET ti_cu_customer_id = vTI_CU_CUSTOMER_ID, 
			         pp20_proc_code = vPP20_PROC_CODE, pp20_proc_date_cymd = vPP20_PROC_DATE_CYMD,
				     ti_cu_cust_type = vti_cu_cust_type,
					 ti_cu_geographic_code = vti_cu_geographic_code,
					 ti_cu_bar_factor = vti_cu_bar_factor, ti_cu_recovery_factor = vti_cu_recovery_factor,
				     ti_cu_scrd_id_2 = vti_cu_scrd_id_2, ti_cu_raw_score_2 = vti_cu_raw_score_2, ti_cu_aligned_score_2 = vti_cu_aligned_score_2, 
					 ti_cu_status_anterior = cStatusCred, 
					 fecha_proceso = vFechahoy	
			   WHERE TI_ACCOUNT_ID = vNumCredito;
					 
			commit; 
			let iContador_upd = iContador_upd +1;
			
		ELIF cActualiza_behaviour = 'S' AND 
		     (cActualiza_tel = '' OR  cActualiza_email = '' OR cActualiza_sitesp= '' ) THEN
			begin;
			--Actualiza todo lo del diario incluido BEHAVIOR y los otros 3 campos no
			UPDATE "informix".cb_triad_customer_2 SET 
			         ti_cu_customer_id = vTI_CU_CUSTOMER_ID,   --El cliente  cuando hay fusiones
			          pp20_proc_code = vPP20_PROC_CODE,        --VALIDAR QUE TIPO DE CUENTAS ES  si es corte   = 'REVC';   si no  = 'COLL'; 
			          pp20_proc_date_cymd = vPP20_PROC_DATE_CYMD, --Fecha hoy
				     ti_cu_cust_type = vti_cu_cust_type,			--Si tiene referencia como cliente.   
			        -- ti_cu_phone_addr_ind = vti_cu_phone_addr_ind,  --Telefono
			        -- ti_cu_email_ind = vti_cu_email_ind,           --Correo
			        -- ti_cu_cust_status = vti_cu_cust_status,      --Situacion especial
					 ti_cu_geographic_code = vti_cu_geographic_code, --Regi+on
					 ti_cu_bar_factor = vti_cu_bar_factor,            --Datos de TRIAD 
					 ti_cu_recovery_factor = vti_cu_recovery_factor,  --Datos de TRIAD
				     ti_cu_scrd_id_2 = vti_cu_scrd_id_2,              --Datos de TRIAD 
				      ti_cu_raw_score_2 = vti_cu_raw_score_2,         --Datos de TRIAD
				       ti_cu_aligned_score_2 = vti_cu_aligned_score_2,-- Datos de TRIAD
			         ti_cu_external_risk_factor_1 = vti_cu_external_risk_factor_1,    --Behavior
			          ti_cu_external_exclusion_cat_1 = vti_cu_external_exclusion_cat_1,  --behavir
				     ti_cu_external_exclusion_ind_1 = vti_cu_external_exclusion_ind_1,  --behavior
				     ti_cu_scrd_id_1 = vti_cu_scrd_id_1,   --behavior
				     ti_cu_raw_score_1 = vti_cu_raw_score_1, --behavior 
				     ti_cu_aligned_score_1 = vti_cu_aligned_score_1,  --behhavior
					 ti_cu_status_anterior = cStatusCred,   --Status_anterior
					 --fecha_corte = vFechacorte, empresa = vEmpresa, 
					 fecha_proceso = vFechahoy
			   WHERE TI_ACCOUNT_ID = vNumCredito;
			commit; 
			let iContador_upd = iContador_upd +1;
		END IF;
		
	elif iExisteCuenta > 0 and (vFechahoy = vFechacorte) then 
		IF cActualiza_behaviour = 'S' AND 
		   (cActualiza_tel = 'S' OR  cActualiza_email = 'S' OR cActualiza_sitesp= 'S' )   THEN
			begin;
		  --Actualiza todo lo del diario incluido BEHAVIOR
			UPDATE "informix".cb_triad_customer_2 SET 
			         ti_cu_customer_id = vTI_CU_CUSTOMER_ID,   --El cliente  cuando hay fusiones
			          pp20_proc_code = vPP20_PROC_CODE,        --VALIDAR QUE TIPO DE CUENTAS ES  si es corte   = 'REVC';   si no  = 'COLL'; 
			          pp20_proc_date_cymd = vPP20_PROC_DATE_CYMD, --Fecha hoy
				     ti_cu_cust_type = vti_cu_cust_type,			--Si tiene referencia como cliente.   
			         ti_cu_phone_addr_ind = vti_cu_phone_addr_ind,  --Telefono
			          ti_cu_email_ind = vti_cu_email_ind,           --Correo
			           ti_cu_cust_status = vti_cu_cust_status,      --Situacion especial
					 ti_cu_geographic_code = vti_cu_geographic_code, --Regi+on
					 ti_cu_bar_factor = vti_cu_bar_factor,            --Datos de TRIAD 
					 ti_cu_recovery_factor = vti_cu_recovery_factor,  --Datos de TRIAD
				     ti_cu_scrd_id_2 = vti_cu_scrd_id_2,              --Datos de TRIAD 
				      ti_cu_raw_score_2 = vti_cu_raw_score_2,         --Datos de TRIAD
				       ti_cu_aligned_score_2 = vti_cu_aligned_score_2,-- Datos de TRIAD
			         ti_cu_external_risk_factor_1 = vti_cu_external_risk_factor_1,    --Behavior
			          ti_cu_external_exclusion_cat_1 = vti_cu_external_exclusion_cat_1,  --behavir
				     ti_cu_external_exclusion_ind_1 = vti_cu_external_exclusion_ind_1,  --behavior
				     ti_cu_scrd_id_1 = vti_cu_scrd_id_1,   --behavior
				     ti_cu_raw_score_1 = vti_cu_raw_score_1, --behavior 
				     ti_cu_aligned_score_1 = vti_cu_aligned_score_1,  --behhavior
					 ti_cu_external_good_bad_ind_1 = vti_cu_external_good_bad_ind_1, 
			         ti_cu_external_max_delq_3 = vti_cu_external_max_delq_3,  ti_cu_external_max_delq_1 = vti_cu_external_max_delq_1,
					 ti_cu_status_anterior = cStatusCred,   --Status_anterior
					 fecha_corte = vFechacorte,
					 fecha_proceso = vFechahoy
			   WHERE TI_ACCOUNT_ID = vNumCredito;
			   
					 
		 commit; 
		    let iContador_upd = iContador_upd +1;
			
		ELIF cActualiza_behaviour <> 'S' AND 
		    (cActualiza_tel = 'S' OR  cActualiza_email = 'S' OR cActualiza_sitesp= 'S' ) THEN
			begin;
		      --Actualiza todo lo del diario menos BEHAVIOR
			  UPDATE "informix".cb_triad_customer_2 SET 
			         ti_cu_customer_id = vTI_CU_CUSTOMER_ID,   --El cliente  cuando hay fusiones
			          pp20_proc_code = vPP20_PROC_CODE,        --VALIDAR QUE TIPO DE CUENTAS ES  si es corte   = 'REVC';   si no  = 'COLL'; 
			          pp20_proc_date_cymd = vPP20_PROC_DATE_CYMD, --Fecha hoy
				     ti_cu_cust_type = vti_cu_cust_type,			--Si tiene referencia como cliente.   
			         ti_cu_phone_addr_ind = vti_cu_phone_addr_ind,  --Telefono
			          ti_cu_email_ind = vti_cu_email_ind,           --Correo
			           ti_cu_cust_status = vti_cu_cust_status,      --Situacion especial
					 ti_cu_geographic_code = vti_cu_geographic_code, --Regi+on
					 ti_cu_bar_factor = vti_cu_bar_factor,            --Datos de TRIAD 
					 ti_cu_recovery_factor = vti_cu_recovery_factor,  --Datos de TRIAD
				     ti_cu_scrd_id_2 = vti_cu_scrd_id_2,              --Datos de TRIAD 
				      ti_cu_raw_score_2 = vti_cu_raw_score_2,         --Datos de TRIAD
				       ti_cu_aligned_score_2 = vti_cu_aligned_score_2,-- Datos de TRIAD
			         --ti_cu_external_risk_factor_1 = vti_cu_external_risk_factor_1,    --Behavior
			          --ti_cu_external_exclusion_cat_1 = vti_cu_external_exclusion_cat_1,  --behavir
				     --ti_cu_external_exclusion_ind_1 = vti_cu_external_exclusion_ind_1,  --behavior
				     --ti_cu_scrd_id_1 = vti_cu_scrd_id_1,   --behavior
				     --ti_cu_raw_score_1 = vti_cu_raw_score_1, --behavior 
				     --ti_cu_aligned_score_1 = vti_cu_aligned_score_1,  --behhavior
					 ti_cu_external_good_bad_ind_1 = vti_cu_external_good_bad_ind_1, 
			         ti_cu_external_max_delq_3 = vti_cu_external_max_delq_3,  ti_cu_external_max_delq_1 = vti_cu_external_max_delq_1,
					 ti_cu_status_anterior = cStatusCred,   --Status_anterior
					 fecha_corte = vFechacorte,
					 fecha_proceso = vFechahoy
			   WHERE TI_ACCOUNT_ID = vNumCredito;
			commit; 
			let iContador_upd = iContador_upd +1;		  
		
		ELIF cActualiza_behaviour <> 'S' AND 
		      cActualiza_tel <> 'S' AND  cActualiza_email <> 'S' AND  cActualiza_sitesp <> 'S'     THEN
		     --Se actualiza todo menos lo de behaviour ni lo de los otros 3 campos
			begin;
			   UPDATE "informix".cb_triad_customer_2 SET ti_cu_customer_id = vTI_CU_CUSTOMER_ID, 
			         pp20_proc_code = vPP20_PROC_CODE, pp20_proc_date_cymd = vPP20_PROC_DATE_CYMD,
				     ti_cu_cust_type = vti_cu_cust_type,
					 ti_cu_geographic_code = vti_cu_geographic_code,
					 ti_cu_bar_factor = vti_cu_bar_factor, ti_cu_recovery_factor = vti_cu_recovery_factor,
				     ti_cu_scrd_id_2 = vti_cu_scrd_id_2, ti_cu_raw_score_2 = vti_cu_raw_score_2, ti_cu_aligned_score_2 = vti_cu_aligned_score_2, 
					 ti_cu_external_good_bad_ind_1 = vti_cu_external_good_bad_ind_1, 
			         ti_cu_external_max_delq_3 = vti_cu_external_max_delq_3,  ti_cu_external_max_delq_1 = vti_cu_external_max_delq_1,
					 ti_cu_status_anterior = cStatusCred,
					 fecha_corte = vFechacorte,
					 fecha_proceso = vFechahoy	
			   WHERE TI_ACCOUNT_ID = vNumCredito;
					 
			commit; 
			let iContador_upd = iContador_upd +1;
			
		ELIF cActualiza_behaviour = 'S' AND 
		     (cActualiza_tel = '' OR  cActualiza_email = '' OR cActualiza_sitesp= '' ) THEN
			begin;
			  --Actualiza todo lo del diario incluido BEHAVIOR y los otros 3 campos no
			  UPDATE "informix".cb_triad_customer_2 SET 
			         ti_cu_customer_id = vTI_CU_CUSTOMER_ID,   --El cliente  cuando hay fusiones
			          pp20_proc_code = vPP20_PROC_CODE,        --VALIDAR QUE TIPO DE CUENTAS ES  si es corte   = 'REVC';   si no  = 'COLL'; 
			          pp20_proc_date_cymd = vPP20_PROC_DATE_CYMD, --Fecha hoy
				     ti_cu_cust_type = vti_cu_cust_type,			--Si tiene referencia como cliente.   
			        -- ti_cu_phone_addr_ind = vti_cu_phone_addr_ind,  --Telefono
			        -- ti_cu_email_ind = vti_cu_email_ind,           --Correo
			        -- ti_cu_cust_status = vti_cu_cust_status,      --Situacion especial
					 ti_cu_geographic_code = vti_cu_geographic_code, --Regi+on
					 ti_cu_bar_factor = vti_cu_bar_factor,            --Datos de TRIAD 
					 ti_cu_recovery_factor = vti_cu_recovery_factor,  --Datos de TRIAD
				     ti_cu_scrd_id_2 = vti_cu_scrd_id_2,              --Datos de TRIAD 
				      ti_cu_raw_score_2 = vti_cu_raw_score_2,         --Datos de TRIAD
				       ti_cu_aligned_score_2 = vti_cu_aligned_score_2,-- Datos de TRIAD
			         ti_cu_external_risk_factor_1 = vti_cu_external_risk_factor_1,    --Behavior
			          ti_cu_external_exclusion_cat_1 = vti_cu_external_exclusion_cat_1,  --behavir
				     ti_cu_external_exclusion_ind_1 = vti_cu_external_exclusion_ind_1,  --behavior
				     ti_cu_scrd_id_1 = vti_cu_scrd_id_1,   --behavior
				     ti_cu_raw_score_1 = vti_cu_raw_score_1, --behavior 
				     ti_cu_aligned_score_1 = vti_cu_aligned_score_1,  --behhavior
					 ti_cu_external_good_bad_ind_1 = vti_cu_external_good_bad_ind_1, 
			         ti_cu_external_max_delq_3 = vti_cu_external_max_delq_3,  ti_cu_external_max_delq_1 = vti_cu_external_max_delq_1,
					 ti_cu_status_anterior = cStatusCred,   --Status_anterior
					 fecha_corte = vFechacorte,
					 fecha_proceso = vFechahoy
			   WHERE TI_ACCOUNT_ID = vNumCredito;
			commit; 
			let iContador_upd = iContador_upd +1;
		END IF;
		
	elif iExisteCuenta <= 0 and (vFechahoy = vFechacorte) then   
	  begin;
	     INSERT INTO "informix".cb_triad_customer_2(ti_cu_customer_id, ti_account_id, pp20_proc_code, pp20_proc_date_cymd, ti_cu_date_first_rel, ti_cu_cust_type, ti_cu_cust_status, 
	                                         ti_cu_cust_spr_type, ti_cu_num_rev_acct, ti_cu_num_loan_acct, ti_cu_date_of_birth, ti_cu_date_last_restrctre, ti_cu_app_score, 
											 ti_cu_phone_addr_ind, ti_cu_email_ind, ti_cu_spid, ti_cu_test_digits_1, ti_cu_test_digits_2, ti_cu_test_digits_3, ti_cu_test_digits_4,
											 ti_cu_triad_cat, ti_cu_geographic_code, ti_cu_branch_number, ti_cu_external_risk_factor_1, ti_cu_external_exclusion_cat_1, 
											 ti_cu_external_exclusion_ind_1, ti_cu_external_max_delq_1, ti_cu_external_good_bad_ind_1, ti_cu_external_risk_factor_3, 
											 ti_cu_external_exclusion_cat_3, ti_cu_external_exclusion_ind_3, ti_cu_external_max_delq_3, ti_cu_external_good_bad_ind_3, 
											 ti_cu_cb_score_type, ti_cu_bar_factor, ti_cu_recovery_factor, ti_cu_scrd_id_1, ti_cu_raw_score_1, ti_cu_aligned_score_1, 
											 ti_cu_scrd_id_2, ti_cu_raw_score_2, ti_cu_aligned_score_2, ti_cu_scrd_id_3, ti_cu_raw_score_3, ti_cu_aligned_score_3,
											 ti_cu_status_anterior, fecha_corte, empresa, fecha_proceso)

         VALUES(vTI_CU_CUSTOMER_ID, vNumCredito, vPP20_PROC_CODE, vPP20_PROC_DATE_CYMD, vti_cu_date_first_rel, vti_cu_cust_type, vti_cu_cust_status,
             vti_cu_cust_spr_type, vti_cu_num_rev_acct, vti_cu_num_loan_acct, vti_cu_date_of_birth, vti_cu_date_last_restrctre, vti_cu_app_score,
			 vti_cu_phone_addr_ind, vti_cu_email_ind, vti_cu_spid, vti_cu_test_digits_1, vti_cu_test_digits_2, vti_cu_test_digits_3, vti_cu_test_digits_4,
			 vti_cu_triad_cat, vti_cu_geographic_code, vti_cu_branch_number, vti_cu_external_risk_factor_1, vti_cu_external_exclusion_cat_1,
			 vti_cu_external_exclusion_ind_1, vti_cu_external_max_delq_1, vti_cu_external_good_bad_ind_1, vti_cu_external_risk_factor_3,
			 vti_cu_external_exclusion_cat_3, vti_cu_external_exclusion_ind_3, vti_cu_external_max_delq_3, vti_cu_external_good_bad_ind_3,
			 vti_cu_cb_score_type, vti_cu_bar_factor, vti_cu_recovery_factor, vti_cu_scrd_id_1, vti_cu_raw_score_1, vti_cu_aligned_score_1,
			 vti_cu_scrd_id_2, vti_cu_raw_score_2, vti_cu_aligned_score_2, vti_cu_scrd_id_3, vti_cu_raw_score_3, vti_cu_aligned_score_3,
			 cStatusCred, vFechacorte, vEmpresa,vFechahoy);
	  commit;
	  let iContador_ins = iContador_ins +1;
	  
	end if;
    
    
  ---validar que el primer insert se realiza correctamente
  --LET iResult_insert = dbinfo("sqlca.sqlerrd2");
 
LET vPP20_PROC_CODE = ''; --4 podrÃ?Â¡ tener tambiÃ?Â©n el valor COLL
LET vTI_CU_CUSTOMER_ID = ''; --20

let vPP20_PROC_CODE = '';
--let vPP20_PROC_DATE_CYMD   = date(1);
let vTI_CU_CUSTOMER_ID     = '';
let vTI_CU_DATE_FIRST_REL  = date(1);
let vTI_CU_CUST_TYPE       = ''; 
let vTI_CU_CUST_STATUS     = '';
let vTI_CU_CUST_SPR_TYPE   = '';
let vTI_CU_NUM_REV_ACCT      = '';
let vTI_CU_NUM_LOAN_ACCT     = '';
let vTI_CU_DATE_OF_BIRTH     = date(1);
let vTI_CU_DATE_LAST_RESTRCTRE     = date(1);
let vTI_CU_APP_SCORE         = 0;
let vTI_CU_PHONE_ADDR_IND    = '';
let vTI_CU_EMAIL_IND         = '';
let vTI_CU_SPID              = '';
let vTI_CU_TEST_DIGITS_1     = '';
let vTI_CU_TEST_DIGITS_2     = '';
let vTI_CU_TEST_DIGITS_3     = '';
let vTI_CU_TEST_DIGITS_4     = '';
let vTI_CU_TRIAD_CAT         = '';
let vTI_CU_GEOGRAPHIC_CODE   = 0;
let vTI_CU_BRANCH_NUMBER     = '';
let vTI_CU_EXTERNAL_RISK_FACTOR_1		= '';
let vTI_CU_EXTERNAL_EXCLUSION_CAT_1  	= '';
let vTI_CU_EXTERNAL_EXCLUSION_IND_1		= '';
let vTI_CU_EXTERNAL_MAX_DELQ_1          = 0;
let vTI_CU_EXTERNAL_GOOD_BAD_IND_1 		= 0;
let vTI_CU_EXTERNAL_RISK_FACTOR_3		= 0;
let vTI_CU_EXTERNAL_EXCLUSION_CAT_3 	= '';
let vTI_CU_EXTERNAL_EXCLUSION_IND_3 	= '';
let vTI_CU_EXTERNAL_MAX_DELQ_3          = 0;
let vTI_CU_EXTERNAL_GOOD_BAD_IND_3  	= 0;
let vTI_CU_CB_SCORE_TYPE                = 0;
let vTI_CU_BAR_FACTOR        = '';
let vTI_CU_RECOVERY_FACTOR   = '';
let vTI_CU_SCRD_ID_1         = 0;
let vTI_CU_RAW_SCORE_1       = '';
let vTI_CU_ALIGNED_SCORE_1   = '';
let vTI_CU_SCRD_ID_2         = '';
let vTI_CU_RAW_SCORE_2       = '';
let vTI_CU_ALIGNED_SCORE_2   = '';
let vTI_CU_SCRD_ID_3         = 0;
let vTI_CU_RAW_SCORE_3       = 0;
let vTI_CU_ALIGNED_SCORE_3   = 0;
LET vTI_RV_ACCOUNT_ID        = ''; 
let cEmpresa_10              = '';
let iExisteCuenta            = 0; 
let v_numcte                 = '';  
LET iScoreBehavior           = 0;
let cActualiza_tel           = '';
let cActualiza_email         = '';
let cActualiza_sitesp        = '';
let cActualiza_behaviour     = '';
let vti_cu_phone_addr_ind_actual = '';
let vti_cu_email_ind_actual = '';
let vti_cu_cust_status_actual = '';
let dFechaProcAnt_cta = date(1);

end foreach




 let cContGral = iContGral;
 LET cMensaje_2 = pEjecucion || '- Regs. Procs. = ' || iContGral;
 --CALL bdicobranza:sp_inserta_bitacora_cob_2(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2; 
 CALL bdicobranza:sp_inserta_bitacora_cob_2(vempresa, cProceso, cCodRet, cMensaje_2, '03') RETURNING cCod_ret_2; 
 
 LET cMensaje = trim(cMensaje) || '. Procesados: ' || trim(cContGral) || ' - UPD: ' || iContador_upd || '- Ins: ' || iContador_ins;
 
 
	
    ---RETURN cCodRet;
	RETURN cCodRet, trim(cMensaje);
END
END PROCEDURE
;