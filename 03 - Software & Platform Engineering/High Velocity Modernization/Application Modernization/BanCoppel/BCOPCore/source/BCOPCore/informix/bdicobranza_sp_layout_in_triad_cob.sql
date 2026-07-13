CREATE PROCEDURE "informix".sp_layout_in_triad_cob(pEjecucion smallint)

RETURNING CHAR(6), char(80);
	
	-- VERSION: 1.0.13 20200901,1.0.12 20200818, 1.0.11 20200611, 1.0.10 20190313
	DEFINE vDataErr				VARCHAR(64);
	DEFINE iSqlErr				INTEGER;
	DEFINE iSamErr				INTEGER;
	DEFINE cCodRet				CHAR(6);
	
	-- Este SP no genera archivo solo inserta en tabla. 
	DEFINE vNomarchivo  		CHAR(70); 
	DEFINE cRuta        		CHAR(20);
	
	DEFINE cMensaje     		CHAR(80);
	DEFINE cMensaje_2     		CHAR(80);
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
	DEFINE cred_ini_temp_2     CHAR(30);
	
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
	DEFINE cred_ini_2					CHAR(20);
	DEFINE cred_fin_2					CHAR(20);
	DEFINE dFechaCorte_ant              DATE;
	
   --INICIALIZACION DE VARIABLES--
	LET vDataErr		  = '';
	LET iSqlErr		  = 0;
	LET iSamErr		  = 0;
	LET cCodRet		  = "000000";
	
	--LET vNomarchivo   = 'Layout_in_triad.txt';
	LET vNomarchivo     = 'Bancoppel_Layout_in_Triad_Cob.txt';
	LET cRuta           = '/RESPALDOS/aacano/';
	
	LET cMensaje            = 'FIN DEL PROCESO CORRECTO';
	LET cMensaje_2            = '';
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
	LET cred_ini_2			 		='';
	LET cred_fin_2			 		='';
	LET cred_ini_temp_2             ='';   
	LET dFechaCorte_ant             = date(1);
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
	--SET DEBUG FILE TO "/ifxsif01/macf/cob/sp_layout_in_triad_cob.trc";
	--TRACE ON;
   
    LET cMensaje = pEjecucion;
	--CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
	CALL bdicobranza:sp_inserta_bitacora_cob_2(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
	
	/*SELECT fecha_hoy,fecha_ant,pri_dia_mes,ult_dia_mes 
	    INTO vFechahoy, vFechaDiaAnt,vPriDiaMes,vUltDiaMes
	    FROM bdicred:sd_fechas WHERE empresa = vEmpresa; */
	
	
	   let vFechahoy = today -1;
	   let vFechaDiaAnt = today -2;
	
    --let vFechahoy = mdy(9,1,2020);               --TEST MACF
    --let vFechaDiaAnt =  date(vFechahoy - 1 units day);   --TEST MACF

	let iDia_corte = DAY(vFechahoy);
	
	LET dFechaCorte     =  lpad(month(vFechahoy),2,0) || "/" || lpad(day(vFechahoy),2,0) || "/" || year(vFechahoy);
    LET dFechaCorte_ant =  date(dFechaCorte - 1 units month);
	
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
	FROM bdicred:sd_param  WHERE cod_param = (830 + pEjecucion)::CHAR(3);  

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
		SELECT a.numcte, a.num_credito, 'REV'
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
		SELECT a.numcte, a.num_credito, 'REV'
		  FROM bdicred:sd_maecred a
		       JOIN bdicred:sd_maecredanexo d ON d.empresa = a.empresa AND d.num_credito = a.num_credito AND d.fecha_ult_pago = vFechaDiaAnt --PAGO UN DIA ANTERIOR
		       JOIN bdicred:sd_maesdoshist e ON e.empresa = a.empresa AND e.num_credito = a.num_credito 
			                                    -- AND e.fecha = (mdy(month(vFechahoy),d.dia_corte,year(vFechahoy)) -1 units month)
												AND e.fecha = dFechaCorte_ant
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
			/*IF day(vFechahoy) <= vDiacorte THEN 					
					LET cFechacorte = TO_CHAR(vFechacorte,'%Y%m%d');
			ELSE 
				LET vFechacorte =  bdicred:monthadd(vFechacorte,-1);		-- ESTO esta mal pq esta diciendo que su fecha sea 16/07 menos un mes		
				LET cFechacorte = TO_CHAR(vFechacorte,'%Y%m%d');            -- entonces sería el 21 y ya tiene generado su prox fecha pago 16/08 
				END IF;
			*/	
		   IF day(vFechahoy) <= vDiacorte THEN 					
				LET cFechacorte = TO_CHAR(vFechacorte,'%Y%m%d');
		   ELSE 
			    LET vFechacorte =  mdy(month(vFechahoy),vDiacorte,year(vFechahoy));
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
	 LET cMensaje_2 = pEjecucion || '- Regs. Procs. = ' || iContGral;
	 CALL bdicobranza:sp_inserta_bitacora_cob_2(vempresa, cProceso, cCodRet, cMensaje_2, '03') RETURNING cCod_ret_2;  
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
'Version: 1.0',
'Dscripción: Se modifica para que se ejecute en 5 hilos',
'Autor: Marco A. Campos',
'Fecha: 2020-09-01',
'Versión: 1.0.13';

CREATE PROCEDURE "informix".sp_rep_cobvent_ctesvencsuc(pOpcion INTEGER, pFechaIni date, pFechaFin date)
	--	NOTA:
	--	pOpcion = 1	FECHAS AUTOMATICAS
	--		"pFechaIni" Y "pFechaFin" ENVIARLOS VACIOS.
	--	pOpcion = 2 CONSULTAR POR RANGO DE FECHA INICIO A FECHA FIN.
	--		"pFechaIni" Y "pFechaFin" ENVIARLOS LAS FECHAS
	

	--RETORNOS
	RETURNING
	CHAR(6) AS cCodRet, CHAR(50) AS cMensajeRet; 
	
	-- CREACION DE VARIABLES.
	DEFINE cCodRet              CHAR(6);		--	CODIGO DE RETORNO. 
	DEFINE iSqlErr              INTEGER;		--	ERROR CONTROLADO DE BDD.
	DEFINE cMensajeRet			CHAR(50);		--	MENSAJE DE RETORNO.
	DEFINE dFechaHoy		    DATE;			--	FECHA ACTUAL DEL SISTEMA.
	DEFINE iDia					INTEGER;		--	DIA ACTUAL.		
	DEFINE cRuta				CHAR(200);		--	RUTA DEL REPORTE.
	DEFINE cSeparador			CHAR(1);		--	SEPARADOR DE CAMPOS	
	DEFINE cNombreArchivo		CHAR(50);		--	NOMBRE DEL REPORTE.	
	DEFINE cGeneraSql			CHAR(2000);		--	GENERA EL ARCHIVO.
	DEFINE cSql                	CHAR(500);		--	ALMACENA LA CADENA A CREAR.
	DEFINE cEmpresa				CHAR(3);		--	EMPRESA.
	DEFINE cFechaRepINI			CHAR(10);		
	DEFINE cFechaRepFIN			CHAR(10);
	DEFINE dFechaRepINI 		DATE;
	DEFINE dFechaRepFIN 		DATE;
	DEFINE cNombreArchivo_head  CHAR(14);
	DEFINE cNombreArchivo_aux	CHAR(50);		--	ARCHIVO AUXILIAR.	
	
	-- INICIALIZACION DE VARIABLES.
	LET cCodRet                 = 	'';
	LET iSqlErr                 =	0;
	LET cMensajeRet				=	'';
	LET dFechaHoy				=	NULL;
	LET iDia					=	0;	
	LET cRuta					=	'';
	LET cSeparador				=	'';	
	LET cNombreArchivo			=	'';
	LET cGeneraSql				=	'';	
	LET cSql 					=	'';	
	LET cEmpresa				=	'001';
	LET cFechaRepINI			=	'';
	LET cFechaRepFIN			=	'';
	--LET dFechaRepINI 			=	NULL;
	--LET dFechaRepFIN			= 	NULL;
	LET dFechaRepINI = date(1);
	LET dFechaRepFIN = date(1);
	LET cNombreArchivo_head  = 'encabezado.txt';
	LET cNombreArchivo_aux  = '';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/home/sysifx/PaulGarcia/TRACE/sp_rep_cobvent_ctesvencsuc.out';
	--SET DEBUG FILE TO '/ifxsif01/macf/sp_rep_cobvent_ctesvencsuc.out';
	--TRACE ON;
	
	BEGIN
		
			ON EXCEPTION SET iSqlErr		
			 
				LET cCodRet			= iSqlErr;
				LET cMensajeRet 	= "ERROR DE BDD";
				
			    RETURN cCodRet,cMensajeRet;
				  
			END EXCEPTION;
		
			--	*****************************************************************************
			--	*	cCodRet	=	"000000".	(CREACION DE REPORTE EXITOSO).					*
			--	*	cCodRet	=	"000001".	(ERROR OPCION INVALIDA).						*
			--	*	cCodRet	=	"000002".	(ERROR FECHAS INCORRECTAS).						*
			--	*	cCodRet	=	"000003".	(ERROR AL OBTENER RUTA O NOMBRE DEL REPORTE).	*
			--	*****************************************************************************
		
			IF pOpcion <= 0 OR pOpcion > 2  THEN
			
				LET cCodRet     	= "000001";
				LET cMensajeRet		= "ERROR OPCION INVALIDA.";
				
				RETURN cCodRet, cMensajeRet;
				
			ELIF pOpcion = 2 THEN
			
				--IF pFechaIni = "" AND pFechaFin = "" THEN
				IF NVL(pFechaIni,'') = "" AND NVL(pFechaFin,"") = "" THEN

					--	SI LAS FECHAS SON VACIAS MANDAR MENSAJE DE ERROR CORRESPONDIENTE.
					LET cCodRet     	= "000002";
					LET cMensajeRet 	= "ERROR FECHAS INCORRECTAS.";
					
					RETURN cCodRet, cMensajeRet;
				ELSE
				   LET dFechaRepINI = pFechaIni;
	               LET dFechaRepFIN = pFechaFin;

				END IF;	
				
			END IF;
			
			--	OBTENER LA RUTA DONDE SE ALMACENARA EL ARCHIVO DE CONTEO PARA CLIENTES TITULARES.
			SELECT valor_alfabetico
			INTO cRuta				
			FROM cb_param_campania
			WHERE empresa = cEmpresa 
			AND tipo_campania = 11 
			AND grupo_parametro = 'RUTAS' 
			AND num_parametro = 1;
			
			-- OBTIENE EL SEPARADOR DE LOS CAMPOS
			SELECT valor_alfabetico 
			INTO cSeparador
			FROM bdicobranza:cb_param_campania
			WHERE empresa       = cEmpresa
			AND tipo_campania   = '1'
			AND grupo_parametro = 'ARCHIVOS'
			AND num_parametro   = 2;

			-- OBTENER EL NOMBRE DEL ARCHIVO DE CONTEO PARA CLIENTES TITULARES.
			SELECT valor_alfabetico
			INTO cNombreArchivo				
			FROM cb_param_campania
			WHERE empresa = cEmpresa
			AND tipo_campania = 1 
			AND grupo_parametro = 'ARCHIVOS'
			AND num_parametro = 95;

			IF NVL(cRuta,'') = '' OR NVL(cSeparador,'') = '' OR NVL(cNombreArchivo,'') = '' THEN

				LET cCodRet     	= "000003";
				LET cMensajeRet 	= "ERROR AL OBTENER LA RUTA, SEPARADOR DE CAMPOS O NOMBRE DEL REPORTE.";
				
				RETURN cCodRet, cMensajeRet;

			END IF; 

			--	SE ASIGNAN VALORES A VARIABLES PARA MANEJO DE FECHAS.			
			SELECT fecha_hoy
			INTO dFechaHoy
			FROM bdicred:sd_fechas
			WHERE empresa = cEmpresa;

			--LET dFechaHoy = mdy(7,8,2020);
			
			LET iDia = TO_NUMBER(TO_CHAR(dFechaHoy,"%d"));

			IF pOpcion = 1 THEN

				IF iDia = 8 OR iDia = 15 OR iDia = 22 THEN 
				
					--LET pFechaIni = TO_CHAR((dFechaHoy - 7),"%Y-%m-%d");
					--LET pFechaFin = TO_CHAR((dFechaHoy - 1),"%Y-%m-%d");
					LET dFechaRepINI = (dFechaHoy - 7);
					LET dFechaRepFIN = (dFechaHoy - 1);
					
				ELIF iDia = 1 THEN
										
					--LET pFechaIni = TO_CHAR(ADD_MONTHS(dFechaHoy,-1),"%Y-%m")||'-22';
					--LET pFechaFin = TO_CHAR(LAST_DAY(ADD_MONTHS(dFechaHoy,-1)),'%Y-%m-%d');
					LET dFechaRepINI = (ADD_MONTHS(dFechaHoy,-1) -22);
					LET dFechaRepFIN = (LAST_DAY(ADD_MONTHS(dFechaHoy,-1)));
						
				END IF;

			END IF;
					
			--IF pFechaIni <> '' AND pFechaFin <> '' THEN
			IF NVL(dFechaRepINI,'') <> "" AND NVL(dFechaRepFIN,'') <> "" THEN

				-- CAMBIAR FORMATO DE FECHA PARA CONCATENARLO AL NOMBRE DEL REPORTE.
				--LET dFechaRepINI = TO_DATE(pFechaIni, "%Y-%m-%d");
				--LET dFechaRepFIN = TO_DATE(pFechaFin, "%Y-%m-%d");
				
				LET cFechaRepINI =  TO_CHAR(dFechaRepINI,"%d%m%Y");
				LET cFechaRepFIN =  TO_CHAR(dFechaRepFIN,"%d%m%Y");
				
				LET cNombreArchivo_aux = TRIM(cNombreArchivo) || '.txt'; 
				LET cNombreArchivo = TRIM(cNombreArchivo) || TRIM(cFechaRepINI) || '_al_' || TRIM(cFechaRepFIN) || '.txt';
				
	
				LET cSql = '' ;
				LET cSql = 'echo "Sucursal|Empleado|Nombre_Cajero|Clientes_c_vencido|" > '|| TRIM(cRuta) || trim(cNombreArchivo_head);
				SYSTEM trim(cSql);				
				   
				-- GENERAR EL ARCHIVO DE TEXTO.
				LET cSql = '' ;
				LET cSql = "SELECT b.sucursal AS sucursal, b.usr_captura AS empleado, e.nombre AS nombre_cajero, COUNT(*) :: INTEGER AS clientes_c_vencido " 
							||"FROM cb_compac_bit_realiza b INNER JOIN  bdinteg: si_ejecut e ON b.usr_captura = e.ejecutivo " 
							--||"WHERE SUBSTR(b.fh_movimiento, 0, 10) BETWEEN '" || TRIM(pFechaIni) || "' AND '" || TRIM(pFechaFin) || "' " 
							|| "WHERE b.fh_movimiento BETWEEN mdy('" || month(dFechaRepINI) || "','" || day(dFechaRepINI)|| "','" || year(dFechaRepINI) || "') "
							||"AND mdy('" || month(dFechaRepFIN) || "','" || day(dFechaRepFIN)|| "','" || year(dFechaRepFIN) || "') " 
							||"GROUP BY b.sucursal, b.usr_captura, e.nombre ORDER BY b.sucursal ASC; ";
				
				LET cGeneraSql = "'" || TRIM(cRuta) ||TRIM(cNombreArchivo_aux) || "' DELIMITER '" || cSeparador || "'";
				LET cGeneraSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cGeneraSql) || ' ' || TRIM(cSql) || '" > ' || TRIM(cRuta) || 'CtesVndsSuc.sql';
				SYSTEM cGeneraSql;

				-- PERMISO PARA LA CREACION DE ARCHIVO.
				LET cSql = '' ;
				LET cSql = 'chmod 775 ' || TRIM(cRuta) || 'CtesVndsSuc.sql';
				LET cSql = '' ;
				LET cSql = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'CtesVndsSuc.sql';
				SYSTEM cSql;

				LET cSql = '' ;
				LET cSql = 'cat ' || trim(cRuta) || trim(cNombreArchivo_head) || ' ' || trim(cRuta) || trim(cNombreArchivo_aux)  || '>' ||trim(cRuta) || trim(cNombreArchivo); 
		        SYSTEM trim(cSql);

				
				-- BORRA EL ARCHIVO DE CONTROL.
				LET cSql = '' ;
				LET cSql = 'rm ' || TRIM(cRuta) || 'CtesVndsSuc.sql ' || TRIM(cRuta) || trim(cNombreArchivo_head) || ' ' || TRIM(cRuta) || trim(cNombreArchivo_aux) ;
				SYSTEM trim(cSql);

				LET cSql = '';
				LET cSql = 'gzip -f ' ||trim(cRuta) || trim(cNombreArchivo); 
				SYSTEM trim(cSql);
				
				LET cCodRet     	=	"000000";
				LET cMensajeRet 	=	"CREACION DE REPORTE EXITOSO.";

				RETURN cCodRet, cMensajeRet;
				
			ELSE

				-- SI LAS FECHAS SON VACIAS MANDAR MENSAJE DE ERROR CORRESPONDIENTE.				
				LET cCodRet     	= "000002";
				LET cMensajeRet 	= "ERROR FECHAS INCORRECTAS.";
				
				RETURN cCodRet, cMensajeRet;
			
			END IF;
			
		RETURN cCodRet,cMensajeRet;
		
	END;
END PROCEDURE
DOCUMENT
'Folio:659.',
'Autor: 98786903 Paul Antonio Garcia Gastelum.',
'Fecha: 09/03/2020.',
'DESCRIPCION: Procedimineto para creacion de archivo con el conteo de clientes vencidos.',
'Solicita: Marco Campos.',
'BD: bdicobranza.';

CREATE PROCEDURE "informix".sp_rep_cobvent_ctetitular(pOpcion INTEGER, pFechaIni date, pFechaFin date) 
-- pOpcion = 1	FECHAS AUTOMATICAS, pOpcion = 2 CONSULTAR POR RANGO DE FECHA INICIO A FECHA FIN.	
--"pFechaIni" Y "pFechaFin" SON PARA LA pOpcion = 2, SI "pOpcion ES "1" LOS PARAMETRO DEBEMOS ENVIARLOS VACIOS.   		

	--RETORNOS
	RETURNING
	CHAR(6) AS cCodRet, 
	CHAR(50) AS cMensajeRet; 
	
	-- CREACION DE VARIABLES.
	DEFINE cCodRet              CHAR(6);		--	CODIGO DE RETORNO. 
	DEFINE iSqlErr              INTEGER;		--	ERROR CONTROLADO DE BDD.
	DEFINE cMensajeRet			CHAR(50);		--	MENSAJE DE RETORNO.
	DEFINE dFechaHoy		    DATE;			--	FECHA ACTUAL DEL SISTEMA.
	DEFINE iDia					INTEGER;		--	DIA ACTUAL.		
	DEFINE cRuta				CHAR(200);		--	RUTA DEL REPORTE.
	DEFINE cSeparador			CHAR(1);		--	SEPARADOR DE CAMPOS	
	DEFINE cNombreArchivo		CHAR(50);		--	NOMBRE DEL REPORTE.	
	DEFINE cGeneraSql			CHAR(2000);		--	GENERA EL ARCHIVO.
	DEFINE cSql                	CHAR(500);		--	ALMACENA LA CADENA A CREAR.
	DEFINE cEmpresa				CHAR(3);		--	EMPRESA.
	DEFINE cFechaRepINI			CHAR(10);		
	DEFINE cFechaRepFIN			CHAR(10);
	DEFINE dFechaRepINI 		DATE;
	DEFINE dFechaRepFIN 		DATE;
	DEFINE cNombreArchivo_head  CHAR(15);
	DEFINE cNombreArchivo_aux	CHAR(50);		--	ARCHIVO AUXILIAR.
	
	-- INICIALIZACION DE VARIABLES.
	LET cCodRet                 = 	'';
	LET iSqlErr                 =	0;
	LET cMensajeRet				=	'';
	LET dFechaHoy				=	NULL;
	LET iDia					=	0;	
	LET cRuta					=	'';
	LET cSeparador				=	'';	
	LET cNombreArchivo			=	'';
	LET cGeneraSql				=	'';	
	LET cSql 					=	'';	
	LET cEmpresa				=	'001';
	LET cFechaRepINI			=	'';
	LET cFechaRepFIN			=	'';
	LET dFechaRepINI 			=	date(1);
	LET dFechaRepFIN			= 	date(1);
	LET cNombreArchivo_head  = 'encabezado1.txt';
	LET cNombreArchivo_aux  = '';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/home/sysifx/PaulGarcia/TRACE/sp_rep_cobvent_ctetitular.out';
	--SET DEBUG FILE TO '/ifxsif01/macf/sp_rep_cobvent_ctetitular.out';
	--TRACE ON;
	
	BEGIN
		
			ON EXCEPTION SET iSqlErr		
			 
			 LET cCodRet 			= iSqlErr;
			  LET cMensajeRet 	= "ERROR DE BDD";
			  RETURN cCodRet,cMensajeRet;
			  
			END EXCEPTION;
		
			--	*****************************************************************************
			--	*	cCodRet	=	"000000".	(CREACION DE REPORTE EXITOSO).					*
			--	*	cCodRet	=	"000001".	(ERROR OPCION INVALIDA).						*
			--	*	cCodRet	=	"000002".	(ERROR FECHAS INCORRECTAS).						*
			--	*	cCodRet	=	"000003".	(ERROR AL OBTENER RUTA O NOMBRE DEL REPORTE).	*
			--	*****************************************************************************
		
			IF pOpcion <= 0 OR pOpcion > 2  THEN
			
				LET cCodRet     	= "000001";
				LET cMensajeRet		= "ERROR OPCION INVALIDA.";
				
				RETURN cCodRet, cMensajeRet;
				
			ELIF pOpcion = 2 THEN
			
				--IF pFechaIni = "" AND pFechaFin = "" THEN
				IF NVL(pFechaIni,'') = "" AND NVL(pFechaFin,"") = "" THEN

					--	SI LAS FECHAS SON VACIAS MANDAR MENSAJE DE ERROR CORRESPONDIENTE.
					LET cCodRet     	= "000002";
					LET cMensajeRet 	= "ERROR FECHAS INCORRECTAS.";
					
					RETURN cCodRet, cMensajeRet;
				
				ELSE
				
				   LET dFechaRepINI = pFechaIni;
	               LET dFechaRepFIN = pFechaFin;

				END IF;	
				
			END IF;
			
				--	OBTENER LA RUTA DONDE SE ALMACENARA EL ARCHIVO DE CONTEO PARA CLIENTES TITULARES.
				SELECT valor_alfabetico
				INTO cRuta
				FROM cb_param_campania
				WHERE empresa = cEmpresa 
				AND tipo_campania = 11 
				AND grupo_parametro = 'RUTAS' 
				AND num_parametro = 1;
				
				-- OBTIENE EL SEPARADOR DE LOS CAMPOS
				SELECT valor_alfabetico 
				INTO cSeparador
				FROM bdicobranza:cb_param_campania
				WHERE empresa       = cEmpresa
				AND tipo_campania   = '1'
				AND grupo_parametro = 'ARCHIVOS'
				AND num_parametro   = 2;
				
				-- OBTENER EL NOMBRE DEL ARCHIVO DE CONTEO PARA CLIENTES TITULARES.
				SELECT valor_alfabetico 
				INTO cNombreArchivo
				FROM cb_param_campania
				WHERE empresa = cEmpresa
				AND tipo_campania = 1 
				AND grupo_parametro = 'ARCHIVOS'
				AND num_parametro = 93;
		
				IF NVL(cRuta,'') = '' OR NVL(cSeparador,'') = '' OR NVL(cNombreArchivo,'') = '' THEN

					LET cCodRet     	= "000003";
					LET cMensajeRet 	= "ERROR AL OBTENER LA RUTA, SEPARADOR DE CAMPOS O NOMBRE DEL REPORTE.";
					
					RETURN cCodRet, cMensajeRet;

				END IF; 

			--	SE ASIGNAN VALORES A VARIABLES PARA MANEJO DE FECHAS.	
			
			SELECT fecha_hoy
			INTO dFechaHoy
			FROM bdicred:sd_fechas
			WHERE empresa = cEmpresa;
			
			--LET dFechaHoy = mdy(9,15,2020);

			LET iDia = TO_NUMBER(TO_CHAR(dFechaHoy,"%d") :: INTEGER);

			IF pOpcion = 1 THEN

				IF iDia = 8 OR iDia = 15 OR iDia = 22 THEN 
				
					--LET pFechaIni = TO_CHAR((dFechaHoy - 7),"%Y-%m-%d");
					--LET pFechaFin = TO_CHAR((dFechaHoy - 1),"%Y-%m-%d");
					LET dFechaRepINI = (dFechaHoy - 7);
					LET dFechaRepFIN = (dFechaHoy - 1);
					
				ELIF iDia = 1 THEN
										
					--LET pFechaIni = TO_CHAR(ADD_MONTHS(dFechaHoy,-1),"%Y-%m")||'-22';
					--LET pFechaFin = TO_CHAR(LAST_DAY(ADD_MONTHS(dFechaHoy,-1)),'%Y-%m-%d');
					LET dFechaRepINI = (ADD_MONTHS(dFechaHoy,-1) -22);
					LET dFechaRepFIN = (LAST_DAY(ADD_MONTHS(dFechaHoy,-1)));
							
				END IF;
			
			END IF;
					
			--IF dFechaRepINI <> '' AND dFechaRepFIN <> '' THEN
			IF NVL(dFechaRepINI,'') <> "" AND NVL(dFechaRepFIN,'') <> "" THEN
			
				-- CAMBIAR FORMATO DE FECHA PARA CONCATENARLO AL NOMBRE DEL REPORTE.
				--LET dFechaRepINI = TO_DATE(pFechaIni, "%Y-%m-%d");
				--LET dFechaRepFIN = TO_DATE(pFechaFin, "%Y-%m-%d");
				
				LET cFechaRepINI =  TO_CHAR(dFechaRepINI,"%d%m%Y");
				LET cFechaRepFIN =  TO_CHAR(dFechaRepFIN,"%d%m%Y");
				
				LET cNombreArchivo_aux = TRIM(cNombreArchivo) || '.txt';
				LET cNombreArchivo = TRIM(cNombreArchivo) || TRIM(cFechaRepINI) || '_al_' || TRIM(cFechaRepFIN) || '.txt';
				
	
				LET cSql = '' ;
				LET cSql = 'echo "Sucursal|Empleado|Nombre_Cajero|Si|No|" > '|| TRIM(cRuta) || trim(cNombreArchivo_head);
				SYSTEM trim(cSql);
				
			
				-- GENERAR EL ARCHIVO DE TEXTO.
				LET cSql = '' ;
				LET cSql = "SELECT cv.sucursal, cv.empleado,e.nombre,sum(cv.cont_si)::INTEGER CONT_SI,sum(cv.cont_no)::INTEGER CONT_NO "
							||"FROM cb_cob_vent_cliente_titular cv INNER JOIN bdinteg: si_ejecut e ON cv.empleado = e.ejecutivo "
							--||" AND " || "TRIM(TO_CHAR(cv.fecha,'%Y-%m-%d')) BETWEEN '" || TRIM(pFechaIni) || "' AND '" || TRIM(pFechaFin) || "' " 
							||" AND " || "cv.fecha BETWEEN '" || dFechaRepINI || "' AND '" || dFechaRepFIN || "' " 
							||"GROUP BY cv.sucursal, cv.empleado,e.nombre "
							||"ORDER BY cv.sucursal ASC; ";
				
				LET cGeneraSql = "'" || TRIM(cRuta) ||TRIM(cNombreArchivo_aux) || "' DELIMITER '" || cSeparador || "'";
				LET cGeneraSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cGeneraSql) || ' ' || TRIM(cSql) || '" > ' || TRIM(cRuta) || 'ctetitular.sql';
				SYSTEM trim(cGeneraSql);

				-- PERMISO PARA LA CREACION DE ARCHIVO.
				LET cSql = '' ;
				LET cSql = 'chmod 666 ' || TRIM(cRuta) || 'ctetitular.sql';
				LET cSql = '' ;
				LET cSql = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'ctetitular.sql';
				SYSTEM trim(cSql);
				
				LET cSql = '' ;
				LET cSql = 'cat ' || trim(cRuta) || trim(cNombreArchivo_head) || ' ' || trim(cRuta) || trim(cNombreArchivo_aux)  || ' >' ||trim(cRuta) || trim(cNombreArchivo); 
		        SYSTEM trim(cSql);

				-- BORRA EL ARCHIVO DE CONTROL.
				LET cSql = '' ;
				LET cSql = 'rm ' || TRIM(cRuta) || 'ctetitular.sql ' || TRIM(cRuta) || trim(cNombreArchivo_head) || ' ' || TRIM(cRuta) || trim(cNombreArchivo_aux) ;
				SYSTEM trim(cSql);

				LET cSql = '';
				LET cSql = 'gzip -f ' ||trim(cRuta) || trim(cNombreArchivo); 
				SYSTEM trim(cSql);
				
				LET cCodRet     	=	"000000";
				LET cMensajeRet 	=	"CREACION DE REPORTE EXITOSO.";
				
				RETURN cCodRet, cMensajeRet;
				
			ELSE
			
				--	SI LAS FECHAS SON VACIAS MANDAR MENSAJE DE ERROR CORRESPONDIENTE.
				LET cCodRet     	= "000002";
				LET cMensajeRet 	= "ERROR FECHAS INCORRECTAS.";
				
				RETURN cCodRet, cMensajeRet;
			
			END IF;
			
		RETURN cCodRet,cMensajeRet; 
		
	END;
END PROCEDURE
DOCUMENT
'Folio:659.',
'Autor: 98786903 Paul Antonio Garcia Gastelum.',
'Fecha: 09/03/2020.',
'DESCRIPCION: Procedimineto para creacion de archivo con el conteo de la tabla cb_cob_vent_cliente_titular.',
'Solicita: Marco Campos.',
'BD: bdicobranza.';

CREATE PROCEDURE "informix".sp_rep_cobvent_mtvosrechazo(pOpcion INTEGER, pFechaIni date, pFechaFin date)
--	pOpcion = 1	FECHAS AUTOMATICAS, pOpcion = 2 CONSULTAR POR RANGO DE FECHA INICIO A FECHA FIN.															
--	"pFechaIni" Y "pFechaFin" SON PARA LA pOpcion = 2, SI "pOpcion ES "1" LOS PARAMETRO DEBEMOS ENVIARLOS VACIOS.   		
	
	--RETORNOS
	RETURNING
	CHAR(6) AS cCodRet, CHAR(50) AS cMensajeRet; 
	
	-- CREACION DE VARIABLES.
	DEFINE cCodRet              CHAR(6);		--	CODIGO DE RETORNO. 
	DEFINE iSqlErr              INTEGER;		--	ERROR CONTROLADO DE BDD.
	DEFINE cMensajeRet			CHAR(50);		--	MENSAJE DE RETORNO.
	DEFINE dFechaHoy		    DATE;			--	FECHA ACTUAL DEL SISTEMA.
	DEFINE iDia					INTEGER;		--	DIA ACTUAL.		
	DEFINE cRuta				CHAR(200);		--	RUTA DEL REPORTE.
	DEFINE cSeparador			CHAR(1);		--	SEPARADOR DE CAMPOS	
	DEFINE cNombreArchivo		CHAR(50);		--	NOMBRE DEL REPORTE.	
	DEFINE cGeneraSql			CHAR(2000);		--	GENERA EL ARCHIVO.
	DEFINE cSql                	CHAR(1000);		--	ALMACENA LA CADENA A CREAR.
	DEFINE cEmpresa				CHAR(3);		--	EMPRESA.
	DEFINE cInifecRep			CHAR(10);
	DEFINE cFechaRepINI			CHAR(10);		
	DEFINE cFechaRepFIN			CHAR(10);
	DEFINE dFechaRepINI 		DATE;
	DEFINE dFechaRepFIN 		DATE;
	DEFINE cNombreArchivo_head  CHAR(15);
	DEFINE cNombreArchivo_aux	CHAR(50);		--	ARCHIVO AUXILIAR.	
	
	-- INICIALIZACION DE VARIABLES.
	LET cCodRet                 = 	'';
	LET iSqlErr                 =	0;
	LET cMensajeRet				=	'';
	LET dFechaHoy				=	NULL;
	LET iDia					=	0;	
	LET cRuta					=	'';
	LET cSeparador				=	'';	
	LET cNombreArchivo			=	'';
	LET cGeneraSql				=	'';	
	LET cSql 					=	'';	
	LET cEmpresa				=	'001';
	LET cFechaRepINI			=	'';
	LET cFechaRepFIN			=	'';
	--LET dFechaRepINI 			=	NULL;
	--LET dFechaRepFIN			= 	NULL;
	LET dFechaRepINI = date(1);
	LET dFechaRepFIN = date(1);
	LET cNombreArchivo_head  = 'encabezado2.txt';
	LET cNombreArchivo_aux  = '';
	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/home/sysifx/PaulGarcia/TRACE/sp_rep_cobvent_mtvosrechazo.out';
	--SET DEBUG FILE TO '/ifxsif01/macf/sp_rep_cobvent_mtvosrechazo.out';
	--TRACE ON;
	
	
	BEGIN
		
			ON EXCEPTION SET iSqlErr		
			 
				LET cCodRet			= iSqlErr;
				LET cMensajeRet 	= "ERROR DE BDD";
				
			RETURN cCodRet,cMensajeRet;
				  
			END EXCEPTION;
		
			--	*****************************************************************************
			--	*	cCodRet	=	"000000".	(CREACION DE REPORTE EXITOSO).					*
			--	*	cCodRet	=	"000001".	(ERROR OPCION INVALIDA).						*
			--	*	cCodRet	=	"000002".	(ERROR FECHAS INCORRECTAS).						*
			--	*	cCodRet	=	"000003".	(ERROR AL OBTENER RUTA O NOMBRE DEL REPORTE).	*
			--	*****************************************************************************
		
			IF pOpcion <= 0 OR pOpcion > 2  THEN
			
				LET cCodRet     	= "000001";
				LET cMensajeRet		= "ERROR OPCION INVALIDA.";
				
				RETURN cCodRet, cMensajeRet;
				
			ELIF pOpcion = 2 THEN
			
				IF NVL(pFechaIni,'') = "" AND NVL(pFechaFin,"") = "" THEN

					--	SI LAS FECHAS SON VACIAS MANDAR MENSAJE DE ERROR CORRESPONDIENTE.
					LET cCodRet     	= "000002";
					LET cMensajeRet 	= "ERROR FECHAS INCORRECTAS.";
					
					RETURN cCodRet, cMensajeRet;
				ELSE
				   LET dFechaRepINI = pFechaIni;
	               LET dFechaRepFIN = pFechaFin;

				END IF;	
				
			END IF;
			
				--	OBTENER LA RUTA DONDE SE ALMACENARA EL ARCHIVO DE CONTEO PARA CLIENTES TITULARES.
				SELECT valor_alfabetico
				INTO cRuta	
				FROM cb_param_campania
				WHERE empresa = cEmpresa 
				AND tipo_campania = 11 
				AND grupo_parametro = 'RUTAS' 
				AND num_parametro = 1;
				
				-- OBTIENE EL SEPARADOR DE LOS CAMPOS
				SELECT valor_alfabetico 
				INTO cSeparador
				FROM bdicobranza:cb_param_campania
				WHERE empresa       = cEmpresa
				AND tipo_campania   = '1'
				AND grupo_parametro = 'ARCHIVOS'
				AND num_parametro   = 2;
				
				-- OBTENER EL NOMBRE DEL ARCHIVO DE CONTEO PARA CLIENTES TITULARES.
				SELECT valor_alfabetico 
				INTO cNombreArchivo
				FROM cb_param_campania
				WHERE empresa = cEmpresa
				AND tipo_campania = 1 
				AND grupo_parametro = 'ARCHIVOS'
				AND num_parametro = 94;
		
			IF NVL(cRuta,'') = '' OR NVL(cSeparador,'') = '' OR NVL(cNombreArchivo,'') = '' THEN

				LET cCodRet     	= "000003";
				LET cMensajeRet 	= "ERROR AL OBTENER LA RUTA, SEPARADOR DE CAMPOS O NOMBRE DEL REPORTE.";
				
				RETURN cCodRet, cMensajeRet;

			END IF; 

			--	SE ASIGNAN VALORES A VARIABLES PARA MANEJO DE FECHAS.			
			SELECT fecha_hoy
			 INTO dFechaHoy
			 FROM bdicred:sd_fechas
			WHERE empresa = cEmpresa;	
			
			--LET dFechaHoy = mdy(7,8,2020);

			LET iDia = TO_NUMBER(TO_CHAR(dFechaHoy,"%d"));

			IF pOpcion = 1 THEN

				IF iDia = 8 OR iDia = 15 OR iDia = 22 THEN 
				
					--LET pFechaIni = TO_CHAR((dFechaHoy - 7),"%Y-%m-%d");
					--LET pFechaFin = TO_CHAR((dFechaHoy - 1),"%Y-%m-%d");
					LET dFechaRepINI = (dFechaHoy - 7);
					LET dFechaRepFIN = (dFechaHoy - 1);
					
				ELIF iDia = 1 THEN
										
					--LET pFechaIni = TO_CHAR(ADD_MONTHS(dFechaHoy,-1),"%Y-%m")||'-22';
					--LET pFechaFin = TO_CHAR(LAST_DAY(ADD_MONTHS(dFechaHoy,-1)),'%Y-%m-%d');
					LET dFechaRepINI = (ADD_MONTHS(dFechaHoy,-1) -22);
					LET dFechaRepFIN = (LAST_DAY(ADD_MONTHS(dFechaHoy,-1)));
				END IF;

			END IF;
					

			IF NVL(dFechaRepINI,'') <> "" AND NVL(dFechaRepFIN,'') <> "" THEN
			
				-- CAMBIAR FORMATO DE FECHA PARA CONCATENARLO AL NOMBRE DEL REPORTE.
				--LET dFechaRepINI = TO_DATE(pFechaIni, "%Y-%m-%d");
				--LET dFechaRepFIN = TO_DATE(pFechaFin, "%Y-%m-%d");
				
				LET cFechaRepINI =  TO_CHAR(dFechaRepINI,"%d%m%Y");
				LET cFechaRepFIN =  TO_CHAR(dFechaRepFIN,"%d%m%Y");
					
				--LET cNombreArchivo = TRIM(cNombreArchivo) || TRIM(cFechaRepINI) || '_al_' || TRIM(cFechaRepFIN) || '.txt';
				
				LET cNombreArchivo_aux = TRIM(cNombreArchivo) || '.txt';
				LET cNombreArchivo = TRIM(cNombreArchivo) || TRIM(cFechaRepINI) || '_al_' || TRIM(cFechaRepFIN) || '.txt';
				
	
				LET cSql = '' ;  
				LET cSql = 'echo "Sucursal|Empleado|Nombre_Cajero|Num_Cliente|Mot_rechazo|" > '|| TRIM(cRuta) || trim(cNombreArchivo_head);
				SYSTEM trim(cSql);
				
				-- GENERAR EL ARCHIVO DE TEXTO.
				LET cSql = "SELECT b.sucursal AS sucursal, b.usr_captura AS empleado, e.nombre AS nombre_cajero, b.numcliente AS num_cliente, m.descripcion AS mot_rechazo "
							||"FROM cb_compac_bit_realiza b INNER JOIN  bdinteg: si_ejecut e ON  b.usr_captura = e.ejecutivo AND b.negociar_convenio IN ('N','NT') "
							||"INNER JOIN cb_param_campania m ON b.motivo = m.valor_numerico AND m.tipo_campania = 11 AND m.grupo_parametro = 'MOTRCOMPAC' AND "
							--||"SUBSTR(b.fh_movimiento, 0, 10) BETWEEN '" || TRIM(pFechaIni) || "' AND '" || TRIM(pFechaFin) || "' " 
							||"b.fh_movimiento BETWEEN mdy('" || month(dFechaRepINI) || "','" || day(dFechaRepINI)|| "','" || year(dFechaRepINI) || "') "
							||"AND mdy('" || month(dFechaRepFIN) || "','" || day(dFechaRepFIN)|| "','" || year(dFechaRepFIN) || "') " 
							||"GROUP BY b.sucursal, b.usr_captura, e.nombre, b.numcliente, m.descripcion ORDER BY b.sucursal ASC;";
				
				
				LET cGeneraSql = "'" || TRIM(cRuta) ||TRIM(cNombreArchivo_aux) || "' DELIMITER '" || cSeparador || "'";
				LET cGeneraSql = 'echo "UNLOAD TO ' || TRIM(cGeneraSql) || ' ' || TRIM(cSql) || '" > ' || TRIM(cRuta) || 'mtvosrechazo.sql';
				SYSTEM cGeneraSql;

				-- PERMISO PARA LA CREACION DE ARCHIVO.
				LET cSql = '' ;
				LET cSql = 'chmod 775 ' || TRIM(cRuta) || 'mtvosrechazo.sql';
				LET cSql = '' ;
				LET cSql = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'mtvosrechazo.sql';
				SYSTEM trim(cSql);

				LET cSql = '' ;
				LET cSql = 'cat ' || trim(cRuta) || trim(cNombreArchivo_head) || ' ' || trim(cRuta) || trim(cNombreArchivo_aux)  || '>' ||trim(cRuta) || trim(cNombreArchivo); 
		        SYSTEM trim(cSql);
				
				-- BORRA EL ARCHIVO DE CONTROL.
				LET cSql = '' ;
				LET cSql = 'rm ' || TRIM(cRuta) || 'mtvosrechazo.sql ' || TRIM(cRuta) || trim(cNombreArchivo_head) || ' ' || TRIM(cRuta) || trim(cNombreArchivo_aux) ;
				SYSTEM trim(cSql);

				LET cSql = '';
				LET cSql = 'gzip -f ' ||trim(cRuta) || trim(cNombreArchivo); 
				SYSTEM trim(cSql);
				
				LET cCodRet     	=	"000000";
				LET cMensajeRet 	=	"CREACION DE REPORTE EXITOSO.";
				
				RETURN cCodRet, cMensajeRet;
				
			ELSE
			
				--	SI LAS FECHAS SON VACIAS MANDAR MENSAJE DE ERROR CORRESPONDIENTE.
				LET cCodRet     	= "000002";
				LET cMensajeRet 	= "ERROR FECHAS INCORRECTAS.";
				
				RETURN cCodRet, cMensajeRet;
			
			END IF;
			
		RETURN cCodRet,cMensajeRet;
		
	END;
END PROCEDURE
DOCUMENT
'Folio:659.',
'Autor: 98786903 Paul Antonio Garcia Gastelum.',
'Fecha: 09/03/2020.',
'DESCRIPCION: Procedimineto para creacion de archivo con el conteo motivos de rechazo.',
'Solicita: Marco Campos.',
'BD: bdicobranza.';

CREATE PROCEDURE "informix".sp_ctbcpl_gen_arctelefonos_pred(pEmpresa         CHAR(3),
                                                       pTipoCobranza    CHAR(1),
                                                       pFechaGenCartera DATE,
                                                       pStatusTel       CHAR(2))
RETURNING CHAR(6) AS COD_RET;

-- DECLARACIONES
DEFINE iSqlErr              INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE error_info		    CHAR(80);
DEFINE cCodRet              CHAR(6);
DEFINE cMensaje 		    CHAR(80);
DEFINE cRuta                CHAR(100);
DEFINE cNomArchivo          CHAR(100);
DEFINE cNomArchivoAux       CHAR(100);
DEFINE cNomArchivoEjecSql   CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(100);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE cEmpresa             CHAR(3);
DEFINE cDelimitador         CHAR(1);
DEFINE cTipoCampania        CHAR(1);
DEFINE cCodRetIB            CHAR(6);
DEFINE vnumparametro        SMALLINT;
--1728
DEFINE cNumProd				CHAR(4);
DEFINE cNumProd2			CHAR(4);
DEFINE iConProd				INTEGER;
DEFINE iPrimeraVez			INTEGER;
DEFINE vnumparametro2       SMALLINT;
DEFINE vproceso			    CHAR(06);
DEFINE vday					INTEGER;
DEFINE vnum_prod			CHAR(4);
DEFINE vbandera				CHAR(1);
DEFINE vContTrab			INTEGER;
DEFINE v_num_producto	    CHAR(4);
DEFINE dt_FechaCorte        DATE;
DEFINE c_tipo_producto      CHAR(2);
DEFINE c_canal              CHAR(4); 	
DEFINE bandera_ree			CHAR(1);
DEFINE cNombreArchivo_ree   CHAR(50);
DEFINE dFechahoy_sys        DATE;
DEFINE c_canal_actual       CHAR(4);
DEFINE c_canal_temp         CHAR(4);
DEFINE iNumProds 			INTEGER;
DEFINE iNumProds_pent       INTEGER;
DEFINE iNumProds_siga       INTEGER;
DEFINE iNumProds_test       INTEGER;
DEFINE iCuentaPP            INTEGER;
DEFINE cComprimirArch       CHAR(1);

-- INICIALIZACIONES
LET iSqlErr                 = 0;
LET iIsamErr                = 0;
LET cCodRet                 = '000000';
LET cMensaje                = 'PROCESO EXITOSO';
LET cRuta                   = '';
LET cNomArchivo             = '';
LET cNomArchivoAux          = '';
LET cNomArchivoEjecSql      = '';
LET cSQL                    = '';
LET cSQL1                   = '';
LET cSQL2                   = '';
LET cSQL3                   = '';
LET cEmpresa                = '000';
LET cDelimitador            = '';
LET cTipoCampania           = '';
LET cCodRetIB               = '000000';
---
LET cNumProd           		= '';
LET cNumProd2           	= '';
LET iConProd                = 0;
LET iPrimeraVez             = 0;
LET vnumparametro2          = 0;
LET vproceso				= "0312";
LET vday 					= 0;
LET vnum_prod 				= '';
LET vbandera 				= '';
LET vContTrab 				= 0;
LET v_num_producto          = '';
LET dt_FechaCorte           = pFechaGenCartera;
LET c_tipo_producto         = '';
LET c_canal                 = ''; 
LET bandera_ree			    = ''; 
LET cNombreArchivo_ree      = '';
LET dFechahoy_sys           = today;
LET c_canal_actual          = '';
LET c_canal_temp            = '';
LET iNumProds               = 0;
LET iNumProds_pent          = 0;
LET iNumProds_siga          = 0; 
LET iNumProds_test          = 0;
LET iCuentaPP               = 0;
LET cComprimirArch          = '';
-----------------------Descripcion de Errores controlados----------------------------
--104001	Es necesario proporcionar todos los parametros de ejecucion                     
--104002	La empresa proporcionada es invalida                                            
--104003	El tipo de campana indicado no existe                                           
--104004	No se encuentra el parametros con el caracter de separador de archivo            
--104005	No se encuentra la ruta para almacenar el archivo                               
--104006	No se encuentra el parametros para nombrar el archivo                            
--104007	Es necesario proporcionar la empresa                                            
--104008	Es necesario indicar la fecha a consultar                                       
--104009	No se encontraron clientes marcados como excluidos                              
-------------------------------------------------------------------------------------

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, error_info
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = error_info;

				--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		-- DIRECTIVA PARA TENER LECTURA DE TABLAS AUNQUE ESTEN BLOQUEADAS
		SET ISOLATION TO DIRTY READ;
		-- DIRECTIVA PARA QUE EXISTA UNA ESPERA DE TRES SEGUNDOS AL ACCESO 
		SET LOCK MODE TO WAIT 3;

		--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"01") INTO cCodRetIB;

		--SET DEBUG FILE TO "/ifxsif01/macf/sp_ctbcpl_gen_arctelefonos_pred.trc";
		--TRACE ON;

		-- VALIDA LOS PARAMETROS DE ENTRADA   
		IF 	NVL(pEmpresa,'') = '' OR ( NVL(pTipoCobranza,'') = '' OR  NVL(pTipoCobranza,'') NOT IN ('A','P','R','E','X','Y')) 
			OR NVL(pFechaGenCartera,'')= '' OR NVL(pStatusTel,'') = '' THEN

			LET cCodRet = '104001';

			SELECT descripcion INTO cMensaje
			FROM "informix".cb_errores
			WHERE origen       = 3
			AND codigo_error = cCodRet; 

			IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

			--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

			RETURN cCodRet;
		END IF

		LET vnumparametro = 56;

		SELECT empresa INTO cEmpresa
		FROM bdinteg: "informix".si_empresas
		WHERE empresa= pEmpresa;

		IF NVL(cEmpresa,'') = '' THEN
			LET cCodRet = '104002';

			SELECT descripcion INTO cMensaje
			FROM "informix".cb_errores
			WHERE origen       = 3
			AND codigo_error = cCodRet; 

			IF cMensaje IS NULL THEN LET cMensaje = ''; END IF;

			--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

			RETURN cCodRet;
		END IF;

		-- OBTIENE EL CARACTER SEPARADOR
		SELECT valor_alfabetico INTO cDelimitador
		FROM "informix".cb_param_campania 
		WHERE empresa       = pEmpresa 
		AND tipo_campania   = 1 
		AND grupo_parametro = "ARCHIVOS" 
		AND num_parametro   = 2;

		-- VALIDA QUE EXISTA EL CARACTER
		IF NVL(cDelimitador,'') = '' THEN
			LET cCodRet = '104004';

			SELECT descripcion INTO cMensaje
			FROM "informix".cb_errores
			WHERE origen       = 3
			AND codigo_error = cCodRet; 

			IF cMensaje IS NULL THEN LET cMensaje = ''; END IF;

			--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

			RETURN cCodRet;
		END IF;

		-- OBTIENE LA RUTA DESTINO DEL ARCHIVO
		SELECT valor_alfabetico INTO cRuta
		FROM "informix".cb_param_campania 
		WHERE empresa = pEmpresa
		AND tipo_campania   = 1 
		AND grupo_parametro = "ARCHIVOS" 
		AND num_parametro   = 3;

		--LET cRuta = '/RESPALDOS/Carlos/';
        --LET dFechahoy_sys = mdy(01,03,2020);   --- SOLO TEST MACF
		
		-- VALIDA QUE EXISTA LA CARPETA
		IF NVL(cRuta,'') = '' THEN
			LET cCodRet = '104005';

			SELECT descripcion INTO cMensaje
			FROM "informix".cb_errores
			WHERE origen       = 3
			AND codigo_error = cCodRet; 

			IF cMensaje IS NULL THEN LET cMensaje = ''; END IF;

			--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

			RETURN cCodRet;
		END IF;

		LET pFechaGenCartera = DATE(1);

		IF ptipocobranza = 'A' THEN
		
		    --Nueva parte pq antes solo generaba 6001, poner esto para 8100 tambiï¿½n
			/* IF day(dt_FechaCorte) = 19 THEN
			    let v_num_producto = '8100';
				--let pfechacorte = pfechacorte - 1 units day;
		     ELIF day(dt_FechaCorte) = 21 THEN
			    let v_num_producto = '6001';
				--let pfechacorte = pfechacorte - 1 units day;
		     END IF;
		    */
			
			SELECT MAX(fecha_insert) INTO pFechaGenCartera
			FROM "informix".cb_cat_directorio_cte
			WHERE empresa = pEmpresa
			  --AND num_producto = v_num_producto
			AND tipo_cobranza = ptipocobranza;

			LET vday = DAY(pFechaGenCartera);

			FOREACH WITH HOLD
				SELECT valor_alfabetico INTO vnum_prod
				FROM "informix".cb_param_campania 
				WHERE empresa = pEmpresa AND tipo_campania = 61
				AND grupo_parametro = ptipocobranza
				AND valor_numerico = vday

				IF vnum_prod IS NULL THEN LET vnum_prod = ''; END IF;

				SELECT descripcion INTO vbandera FROM bdicobranza:"informix".cb_param WHERE empresa = pEmpresa AND valor = vnum_prod;

				IF vbandera IS NULL THEN LET vbandera = ''; END IF;

				IF vbandera = 'S' THEN
					LET vContTrab = vContTrab + 1;
				END IF;
			END FOREACH;

			IF vContTrab = 0 THEN
				RETURN cCodRet;
			END IF;
		END IF;

		IF ptipocobranza = 'X' OR ptipocobranza = 'Y' THEN
			IF ptipocobranza = 'X' THEN LET ptipocobranza = 'A'; ELSE LET ptipocobranza = 'R'; END IF;

			   IF  ptipocobranza = 'A'  THEN
			   
			       /*IF day(dt_FechaCorte) = 19 THEN
					let v_num_producto = '8100';
				   ELIF day(dt_FechaCorte) = 21 THEN
					let v_num_producto = '6001';
				   END IF;
			       */

				   -- SE OBTIENE LA FECHA MAXIMA SEGUN EL TIPO DE COBRANZA
					SELECT MAX(fecha_insert) INTO pFechaGenCartera
					FROM "informix".cb_cat_directorio_cte
					WHERE empresa = pEmpresa
					  --AND num_producto = v_num_producto  --MACF
					 AND tipo_cobranza = ptipocobranza;

					--LET pFechaGenCartera = mdy(04,18,2017);

					LET vday = DAY(pFechaGenCartera);				
					
					
					--IF (DAY(TODAY) <> 21) AND (ptipocobranza = "A") THEN
					IF ( (DAY(dFechahoy_sys) <> 21) AND (DAY(dFechahoy_sys) <> 19) )AND (ptipocobranza = "A") THEN
						LET cCodRet = '000000';
						RETURN cCodRet;
					END IF;
                    
					
					IF vday = 18 THEN
					   let v_num_producto = '8100';
					   --let pfechacorte = pfechacorte - 1 units day;
				    ELIF vday = 20 THEN
					   let v_num_producto = '6001';
					   --let pfechacorte = pfechacorte - 1 units day;
				    END IF;
					
					
					IF NVL(pFechaGenCartera,"") = "" THEN
						LET cCodRet     = "104008";
						SELECT descripcion
						INTO cMensaje
						FROM bdicobranza:"informix".cb_errores
						WHERE origen       = 3
						AND codigo_error = cCodRet; 

						IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

						--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

						RETURN cCodRet;
					END IF;

					--*--
					--GENERACION DE ARCHIVOS PARA TDC,PP,REE AGENCIA EXTERNA
					FOREACH WITH HOLD
					
						SELECT canal, tipo_producto, num_producto INTO c_canal, c_tipo_producto, cNumProd --c_num_producto_2 
						  FROM bdicobranza:cb_gestion_cobranza_agex
						 WHERE tipo_cobranza = ptipocobranza
						   AND activo = '1' 
						   AND num_producto = v_num_producto
					
						--SE OBTIENE EL NUMERO DEL PRODUCTO
						/*SELECT DISTINCT num_producto 
						INTO cNumProd
						FROM "informix".cb_cat_directorio_cte 
						WHERE empresa = '001'
						AND tipo_cobranza = ptipocobranza
						AND fecha_insert = pFechaGenCartera
						AND canal = "PENT"
						ORDER BY 1
						*/
						
						--IF ptipocobranza = "A" THEN
							IF cNumProd = "6001" THEN
								LET vnumparametro = 56; --TDC
							ELIF cNumProd = "8100" THEN
								LET vnumparametro = 73; --TDCO
							ELSE
								CONTINUE FOREACH;
							END IF;
						/*ELSE
							IF cNumProd = "6300" OR cNumProd = "7600" OR cNumProd = "7700" OR cNumProd = "6800" THEN
								LET vnumparametro = 58; --PP
							ELIF cNumProd = "6011" THEN
								LET vnumparametro = 57; --REE
							ELSE
								CONTINUE FOREACH;
							END IF;
						END IF;
                        */  
						-- OBTIENE EL NOMBRE DEL ARCHIVO
						SELECT valor_alfabetico INTO cNomArchivo
						FROM "informix".cb_param_campania 
						WHERE empresa         = pEmpresa 
						AND tipo_campania   = 1
						AND grupo_parametro = "ARCHIVOS" 
						AND num_parametro   = vnumparametro;

						-- VALIDA QUE EXISTA EL NOMBRE DEL ARCHIVO
						IF NVL(cNomArchivo,'') = '' THEN
							LET cCodRet = '104006';

							SELECT descripcion INTO cMensaje
							FROM "informix".cb_errores
							WHERE origen       = 3
							AND codigo_error = cCodRet; 

							IF cMensaje IS NULL THEN LET cMensaje = '' ; END IF;

							--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

							RETURN cCodRet;
						END IF
						
						LET cFechaGenArchivo = TRIM(LPAD(DAY(pFechaGenCartera),2,'0') || LPAD(MONTH(pFechaGenCartera),2,'0') || YEAR(pFechaGenCartera));

						IF c_canal = 'PENT' THEN
						   LET cNomArchivoAux = TRIM(cNomArchivo) || cFechaGenArchivo || '_aux_' || pTipoCobranza ||'_AE.txt';
						   LET cNomArchivo = TRIM(cNomArchivo) || cFechaGenArchivo || '_AE.txt';
						ELSE
						   LET cNomArchivoAux = TRIM(cNomArchivo) || cFechaGenArchivo || '_aux_' || pTipoCobranza ||'_' || c_canal || '.txt';
						   LET cNomArchivo = TRIM(cNomArchivo) || cFechaGenArchivo || '_' || c_canal || '.txt';
						END IF;

						LET cSQL1 = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNomArchivoAux) || " DELIMITER '" || cDelimitador || "' ";
						LET cSQL2 = "SELECT TO_CHAR(dir.fecha_insert,'%d/%m/%Y'), dir.numcte , substr(tel.telefono,length(tel.telefono)-9,10) telefono, "
							|| "tel.tipo_tel "
							|| "FROM bdicobranza:cb_cat_directorio_cte dir "
							|| "INNER JOIN bdinteg:si_telefonos_actual tel on dir.numcte = tel.numcte AND tel.tipo_tel in (1,2,3) AND tel.cofetel = 'V' "
							|| "LEFT OUTER JOIN bdinteg: si_bitsmstels bits on  bits.numcte  = tel.numcte AND bits.telefono = tel.telefono "
							|| " AND bits.fecha in (select max(bits2.fecha) from bdinteg:si_bitsmstels bits2 where bits.numcte = bits2.numcte and bits.telefono = bits2.telefono) "   
							|| "WHERE dir.tipo_cobranza = '" || pTipoCobranza || "' "
							
							|| "AND (dir.fecha_insert = '" || pFechaGenCartera || "' OR dir.fecha_reasignacion = '" || pFechaGenCartera || "') "
							|| "AND (dir.status_cliente NOT IN ('NT', 'EX') OR dir.fecha_reasignacion = '" || pFechaGenCartera || "') "

							|| "AND dir.canal = '" || c_canal || "' "
							|| "AND dir.num_producto = '" || cNumProd || "'";

						LET cSQL3 = ' " > '|| TRIM(cRuta) || 'arctele_pred_qry_AE.sql';
					
						LET cSQL1 = TRIM(cSQL1);
						LET cSQL3 = TRIM(cSQL3);
						LET cSQL = cSQL1 || TRIM(cSQL2) || cSQL3;

						-- Verifica que no este vacia la consulta.
						IF ( cSQL <> '' ) THEN 
							SYSTEM cSQL;
							--Permiso para la creacion de archivo.
							LET cSQL = '' ;
							LET cSQL = 'chmod 777 ' || TRIM(cRuta) || "arctele_pred_qry_AE.sql" ;
							LET cSQL = '' ;
							LET cSql = "dbaccess bdicobranza "|| TRIM(cRuta) || "arctele_pred_qry_AE.sql";
							SYSTEM TRIM(cSql);

							LET cSql = cSql;
							LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNomArchivoAux) || " >> " || TRIM(cRuta) || TRIM(cNomArchivo);
							SYSTEM cSql;
						
							--BORRADO DE TEMPORALES QUE FUERON USADOS PARA LA CREACION DE ARCHIVO
							LET cSql = '';
							LET cSQL = "rm "||TRIM(cRuta)||'arctele_pred_qry_AE.sql';		
							SYSTEM TRIM(cSql); 

							LET cSQL = '' ;
							LET cSQL = 'rm ' || TRIM(cruta) || cNomArchivoAux;
							SYSTEM cSQL; 
							
							LET cSql = '';
					        LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
					        SYSTEM cSql;
 
					        LET cSql = '';
					        LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
					        SYSTEM cSql;
							
						END IF;	
					END FOREACH;

					/*LET cSql = '';
					LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
					SYSTEM cSql;

					LET cSql = '';
					LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
					SYSTEM cSql;*/

					RETURN cCodRet;
			
			ELSE 
			    --------<<<<<  TIPO COB R  AGEX
			    -- SE OBTIENE LA FECHA MAXIMA SEGUN EL TIPO DE COBRANZA
					SELECT MAX(fecha_insert) INTO pFechaGenCartera
					FROM "informix".cb_cat_directorio_cte
					WHERE empresa = pEmpresa
					AND tipo_cobranza = ptipocobranza;
				
                   --LET pFechaGenCartera = MDY(9,3,2020); --- USADO SOLO TEST MACF
				   LET vday = DAY(pFechaGenCartera);				
				
				-- Contar cuantos archivos para cada agencia
				FOREACH WITH HOLD
					SELECT canal, count(*) INTO c_canal_temp, iNumProds
					  FROM bdicobranza:cb_gestion_cobranza_agex
					 WHERE tipo_producto = 'PP' 
					 group by 1 order by 1
				
				    IF c_canal_temp = 'PENT' THEN
					   LET iNumProds_pent = iNumProds;
				    ELIF c_canal_temp = 'SIGA' THEN    
                       LET iNumProds_siga = iNumProds; 
					ELIF c_canal_temp = 'TEST' THEN
					   LET iNumProds_test = iNumProds;
				    END IF;
				END FOREACH;
				
				LET iCuentaPP = 0;
				--GENERACION DE ARCHIVOS PARA TDC,PP,REE AGENCIA EXTERNA
				FOREACH WITH HOLD
				
					SELECT canal, tipo_producto, num_producto INTO c_canal, c_tipo_producto, cNumProd --c_num_producto_2 
					  FROM bdicobranza:cb_gestion_cobranza_agex
					 WHERE tipo_cobranza = ptipocobranza
					   AND num_producto <> ''
					   AND activo = '1' 
					   order by canal, num_producto
	   
				
					--SE OBTIENE EL NUMERO DEL PRODUCTO
					/*SELECT DISTINCT num_producto 
					INTO cNumProd
					FROM "informix".cb_cat_directorio_cte 
					WHERE empresa = '001'
					AND tipo_cobranza = ptipocobranza
					AND fecha_insert = pFechaGenCartera
					AND canal = "PENT"
					ORDER BY 1
					*/
					
					/*IF ptipocobranza = "A" THEN
						IF cNumProd = "6001" THEN
							LET vnumparametro = 56; --TDC
						ELIF cNumProd = "8100" THEN
							LET vnumparametro = 73; --TDCO
						ELSE
							CONTINUE FOREACH;
						END IF;
					ELSE*/
									
					IF cNumProd = "6300" OR cNumProd = "7600" OR cNumProd = "7700" OR cNumProd = "6800" THEN
						LET vnumparametro = 58; --PP
						LET iCuentaPP = iCuentaPP +1;
					ELIF cNumProd = "6011" THEN
						IF vday NOT IN(3,18) THEN
						   CONTINUE FOREACH;
						ELSE
						   LET vnumparametro = 57; --REE
						   LET bandera_ree = "S";
						   
						END IF;
					ELSE
						CONTINUE FOREACH;
					END IF;
					--END IF;

					-- OBTIENE EL NOMBRE DEL ARCHIVO
					SELECT valor_alfabetico INTO cNomArchivo
					FROM "informix".cb_param_campania 
					WHERE empresa         = pEmpresa 
					AND tipo_campania   = 1
					AND grupo_parametro = "ARCHIVOS" 
					AND num_parametro   = vnumparametro;

					-- VALIDA QUE EXISTA EL NOMBRE DEL ARCHIVO
					IF NVL(cNomArchivo,'') = '' THEN
						LET cCodRet = '104006';

						SELECT descripcion INTO cMensaje
						FROM "informix".cb_errores
						WHERE origen       = 3
						AND codigo_error = cCodRet; 

						IF cMensaje IS NULL THEN LET cMensaje = '' ; END IF;

						--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

						RETURN cCodRet;
					END IF

										
					LET cFechaGenArchivo = TRIM(LPAD(DAY(pFechaGenCartera),2,'0') || LPAD(MONTH(pFechaGenCartera),2,'0') || YEAR(pFechaGenCartera));
					IF c_canal = 'PENT' THEN
					    LET cNomArchivoAux = TRIM(cNomArchivo) || cFechaGenArchivo || '_aux_' || pTipoCobranza ||'_AE.txt';
					    LET cNomArchivo = TRIM(cNomArchivo) || cFechaGenArchivo || '_AE.txt';
					ELSE
                        LET cNomArchivoAux = TRIM(cNomArchivo) || cFechaGenArchivo || '_aux_' || pTipoCobranza ||'_' || c_canal || '.txt';
					    LET cNomArchivo = TRIM(cNomArchivo) || cFechaGenArchivo || '_' ||  c_canal ||  '.txt';
                    END IF;					

					IF bandera_ree = "S" and vnumparametro = 57 THEN
					   LET cNombreArchivo_ree = cNomArchivo;
					END IF;
					
					LET cSQL1 = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNomArchivoAux) || " DELIMITER '" || cDelimitador || "' ";
					LET cSQL2 = "SELECT TO_CHAR(dir.fecha_insert,'%d/%m/%Y'), dir.numcte , substr(tel.telefono,length(tel.telefono)-9,10) telefono, "
						|| "tel.tipo_tel "
						|| "FROM bdicobranza:cb_cat_directorio_cte dir "
						|| "INNER JOIN bdinteg:si_telefonos_actual tel on dir.numcte = tel.numcte AND tel.tipo_tel in (1,2,3) AND tel.cofetel = 'V' "
						|| "LEFT OUTER JOIN bdinteg: si_bitsmstels bits on  bits.numcte  = tel.numcte AND bits.telefono = tel.telefono "
						|| " AND bits.fecha in (select max(bits2.fecha) from bdinteg:si_bitsmstels bits2 where bits.numcte = bits2.numcte and bits.telefono = bits2.telefono) "   
						|| "WHERE dir.tipo_cobranza = '" || pTipoCobranza || "' "
						|| "AND (dir.fecha_insert = '" || pFechaGenCartera || "' OR dir.fecha_reasignacion = '" || pFechaGenCartera || "') "
						|| "AND (dir.status_cliente NOT IN ('NT', 'EX') OR dir.fecha_reasignacion = '" || pFechaGenCartera || "') "
						|| "AND dir.canal = '" || c_canal || "' "
						|| "AND dir.num_producto = '" || cNumProd || "'";

					LET cSQL3 = ' " > '|| TRIM(cRuta) || 'arctele_pred_qry_AE.sql';
				
					LET cSQL1 = TRIM(cSQL1);
					LET cSQL3 = TRIM(cSQL3);
					LET cSQL = cSQL1 || TRIM(cSQL2) || cSQL3;

					-- Verifica que no este vacia la consulta.
					IF ( cSQL <> '' ) THEN 
						SYSTEM cSQL;
						--Permiso para la creacion de archivo.
						LET cSQL = '' ;
						LET cSQL = 'chmod 777 ' || TRIM(cRuta) || "arctele_pred_qry_AE.sql" ;
						LET cSQL = '' ;
						LET cSql = "dbaccess bdicobranza "|| TRIM(cRuta) || "arctele_pred_qry_AE.sql";
						SYSTEM TRIM(cSql);

						LET cSql = cSql;
						LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNomArchivoAux) || " >> " || TRIM(cRuta) || TRIM(cNomArchivo);
						SYSTEM cSql;

						/*IF cNumProd = '6011' THEN
							LET cSql = '';
							LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
							SYSTEM cSql;

							LET cSql = '';
							LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
							SYSTEM cSql;
						END IF;
                        */
						--BORRADO DE TEMPORALES QUE FUERON USADOS PARA LA CREACION DE ARCHIVO
						LET cSql = '';
						LET cSQL = "rm "||TRIM(cRuta)||'arctele_pred_qry_AE.sql';		
						SYSTEM TRIM(cSql); 

						LET cSQL = '' ;
						LET cSQL = 'rm ' || TRIM(cruta) || cNomArchivoAux;
						SYSTEM cSQL;

						IF bandera_ree = 'S' THEN
							LET cSql = '';
							LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNombreArchivo_ree);
							SYSTEM cSql;
							LET bandera_ree = 'N';
							
							LET cSql = '';
						    LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNombreArchivo_ree)||".gz";
						    SYSTEM cSql;						
						ELSE
						    -- Validar si el canal no cambia aÃºn  20200916
							IF c_canal = 'PENT' and  c_tipo_producto = 'PP' THEN
							   IF iCuentaPP = iNumProds_pent THEN
							      LET cComprimirArch = 'S';
							   END IF;
							ELIF c_canal = 'SIGA' and  c_tipo_producto = 'PP' THEN
							   IF iCuentaPP = iNumProds_siga THEN
							      LET cComprimirArch = 'S';
							   END IF;
							ELIF c_canal = 'TEST' and  c_tipo_producto = 'PP' THEN
							   IF iCuentaPP = iNumProds_test THEN
							      LET cComprimirArch = 'S';
							   END IF;
							END IF
						
						
						    IF cComprimirArch = 'S' THEN
								LET cSql = '';
								LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
								SYSTEM cSql;
							
								LET cSql = '';
								LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
								SYSTEM cSql;	
								LET cComprimirArch = 'N';
								LET iCuentaPP = 0;
							END IF;
						END IF;		
					
						
					END IF;	
				END FOREACH;

				/*LET cSql = '';
				LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
				SYSTEM cSql;

				LET cSql = '';
				LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
				SYSTEM cSql;

				IF bandera_ree = 'S' THEN
				   LET cSql = '';
				   LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNombreArchivo_ree);
				   SYSTEM cSql;
				   LET bandera_ree = 'N';
				END IF;
				*/
				RETURN cCodRet;
			
			    --------------- TIPO COB R AGEX ---- >>>>
				
			END IF;
		 ELSE
			
			/* mi 1a modif
			IF ptipocobranza = 'A' THEN
				-- SE OBTIENE LA FECHA MAXIMA SEGUN EL TIPO DE COBRANZA
				SELECT MAX(fecha_insert) INTO pFechaGenCartera
				FROM "informix".cb_cat_directorio_cte
				WHERE empresa = pEmpresa
				AND num_producto = v_num_producto
				AND tipo_cobranza = ptipocobranza;
			ELIF ptipocobranza = 'R' THEN
			    SELECT MAX(fecha_insert) INTO pFechaGenCartera
				FROM "informix".cb_cat_directorio_cte
				WHERE empresa = pEmpresa
				AND tipo_cobranza = ptipocobranza;
            END IF; 			
            */
			
			-- SE OBTIENE LA FECHA MAXIMA SEGUN EL TIPO DE COBRANZA
			SELECT MAX(fecha_insert) INTO pFechaGenCartera
			FROM "informix".cb_cat_directorio_cte
			WHERE empresa = pEmpresa
			AND tipo_cobranza = ptipocobranza;
			
			--LET pFechaGenCartera = mdy(11,02,2019); -- SOLO TEST MACF

			IF NVL(pFechaGenCartera,"") = "" THEN
				LET cCodRet     = "104008";
				SELECT descripcion
				INTO cMensaje
				FROM bdicobranza:"informix".cb_errores
				WHERE origen       = 3
				AND codigo_error = cCodRet; 

				IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

				--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

				RETURN cCodRet;
			END IF;

			--*--
			--GENERACION DE ARCHIVOS PARA TDC,PP,REE CAT
			FOREACH WITH HOLD
				--SE OBTIENE EL NUMERO DEL PRODUCTO
				SELECT DISTINCT num_producto 
				INTO cNumProd
				FROM "informix".cb_cat_directorio_cte 
				WHERE empresa = '001'
				AND tipo_cobranza = ptipocobranza
				AND fecha_insert = pFechaGenCartera
				AND canal = ""
				ORDER BY 1
				--AND num_producto != '6400'

	/*			WHERE empresa = pEmpresa
				AND tipo_cobranza = ptipocobranza
				AND fecha_insert = fecha_insert 
				AND num_credito = num_credito*/

				IF ptipocobranza = "A" OR ptipocobranza = "P" THEN
					IF cNumProd = "8100" OR cNumProd = "8500" THEN
						LET vnumparametro = 73; --TCO
					ELIF cNumProd = "6001" THEN
						LET vnumparametro = 56; --TDC
					ELSE
						CONTINUE FOREACH;
					END IF;
				ELSE
					IF cNumProd = "6300" OR cNumProd = "6400" OR cNumProd = "7600" OR cNumProd = "7700" OR cNumProd = "6800" THEN
						LET vnumparametro = 58; --PP
	/*				ELSE
						LET vnumparametro = 57; --REE
					END IF*/
					ELIF cNumProd = "6011" THEN
						LET vnumparametro = 57; --REE
					ELSE
						CONTINUE FOREACH;
					END IF
				END IF;

				-- OBTIENE EL NOMBRE DEL ARCHIVO
				SELECT valor_alfabetico INTO cNomArchivo
				FROM "informix".cb_param_campania 
				WHERE empresa         = pEmpresa 
				AND tipo_campania   = 1
				AND grupo_parametro = "ARCHIVOS" 
				AND num_parametro   = vnumparametro;

				-- VALIDA QUE EXISTA EL NOMBRE DEL ARCHIVO
				IF NVL(cNomArchivo,'') = '' THEN
					LET cCodRet = '104006';

					SELECT descripcion INTO cMensaje
					FROM "informix".cb_errores
					WHERE origen       = 3
					AND codigo_error = cCodRet; 

					IF cMensaje IS NULL THEN LET cMensaje = '' ; END IF;

					--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

					RETURN cCodRet;
				END IF

				LET cFechaGenArchivo = TRIM(LPAD(DAY(pFechaGenCartera),2,'0') || LPAD(MONTH(pFechaGenCartera),2,'0') || YEAR(pFechaGenCartera));
				LET cNomArchivoAux = TRIM(cNomArchivo) || cFechaGenArchivo || '_aux_' || pTipoCobranza ||'.txt';
				LET cNomArchivo = TRIM(cNomArchivo) || cFechaGenArchivo || '.txt';

				LET cSQL1 = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNomArchivoAux) || " DELIMITER '" || cDelimitador || "' ";
				LET cSQL2 = "SELECT dir.numcte ,tel.tipo_tel,substr(tel.telefono,length(tel.telefono)-9,10),decode(tel.tipo_tel,1,'F',2,'M','M'),tel.carrier,"
					|| "DECODE(bits.bandera,'T','S','F','N','N') "
					|| "FROM bdicobranza:cb_cat_directorio_cte dir "
					|| "INNER JOIN bdinteg:si_telefonos_actual tel on dir.numcte = tel.numcte AND tel.tipo_tel in (1,2,3) AND tel.cofetel = 'V' "
					|| "LEFT OUTER JOIN bdinteg: si_bitsmstels bits on  bits.numcte  = tel.numcte AND bits.telefono = tel.telefono "
					--|| "	AND bits.rowid in (select max(bits2.rowid) from bdinteg:si_bitsmstels bits2 where bits.numcte = bits2.numcte and bits.telefono = bits2.telefono) "
					|| " AND bits.fecha in (select max(bits2.fecha) from bdinteg:si_bitsmstels bits2 where bits.numcte = bits2.numcte and bits.telefono = bits2.telefono) "   
					|| "WHERE dir.tipo_cobranza = '" || pTipoCobranza || "' "
					|| "AND dir.fecha_insert = '" || pFechaGenCartera || "' "
					--|| "AND dir.tipo_logica > 0 "
					|| "AND dir.status_cliente NOT IN ('NT', 'EX') "
					|| "AND dir.canal = ''"
					|| "AND dir.num_producto = '" || cNumProd || "'";

				LET cSQL3 = ' " > '|| TRIM(cRuta) || 'arctele_pred_qry.sql';
			
				LET cSQL1 = TRIM(cSQL1);
				LET cSQL3 = TRIM(cSQL3);
				LET cSQL = cSQL1 || TRIM(cSQL2) || cSQL3;

				-- Verifica que no este vacia la consulta.
				IF ( cSQL <> '' ) THEN 
					SYSTEM cSQL;
					--Permiso para la creacion de archivo.
					LET cSQL = '' ;
					LET cSQL = 'chmod 777 ' || TRIM(cRuta) || "arctele_pred_qry.sql" ;
					LET cSQL = '' ;
					LET cSql = "dbaccess bdicobranza "|| TRIM(cRuta) || "arctele_pred_qry.sql";
					SYSTEM TRIM(cSql);

					LET cSql = cSql;
					LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNomArchivoAux) || " >> " || TRIM(cRuta) || TRIM(cNomArchivo);
					SYSTEM cSql;

					IF cNumProd = '6011' THEN
						LET cSql = '';
						LET cSql = "wc -l "|| TRIM(cRuta) || TRIM(cNomArchivo) || ' > '  || TRIM(cRuta) ||'CC_'||TRIM(cNomArchivo);
						SYSTEM cSql;

						LET cSql = '';
						LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
						SYSTEM cSql;

						LET cSql = '';
						LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
						SYSTEM cSql;
					END IF;

					--BORRADO DE TEMPORALES QUE FUERON USADOS PARA LA CREACION DE ARCHIVO
					LET cSql = '';
					LET cSQL = "rm "||TRIM(cRuta)||'arctele_pred_qry.sql';		
					SYSTEM TRIM(cSql); 

					LET cSQL = '' ;
					LET cSQL = 'rm ' || TRIM(cruta) || cNomArchivoAux;
					SYSTEM cSQL; 
				END IF;	
			END FOREACH;

			--GENERACION DE ACHIVO DE CIFRAS DE CONTROL
			LET cSql = '';
			LET cSql = "wc -l "|| TRIM(cRuta) || TRIM(cNomArchivo) || ' > '  || TRIM(cRuta) ||'CC_'||TRIM(cNomArchivo);
			SYSTEM cSql;

			LET cSql = '';
			LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
			SYSTEM cSql;

			LET cSql = '';
			LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
			SYSTEM cSql;

			--*--
			--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"03") INTO cCodRetIB;

			RETURN cCodRet;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'MODIFICACION: ISARAI BOJORQUEZ',
'FECHA: 2015/06/24',
'DESCRIPCION: SE CREA PROCEDIMIENTO PARA LA GENERACION DE ARCHIVOS CATTELEFONOS',
'BD: BDIcOBRANZA',
'VERSION:20150624.1500',
'Modif.: MACF 20191031',
'Desc.: Para corregir Error -268 debido a uso de rowid en si_bitsmstels';

CREATE PROCEDURE "informix".sp_depura_tbls_eval_objetiva(pTipoEjec char(1), pFechaIni date, pFechaFin date)

RETURNING CHAR(6), char(80);
  -- vers 1.0.0 20190901
  DEFINE vcCodRet CHAR(5);
  DEFINE viSqlErr INTEGER;
  define vDataErr	      varchar(64);
  DEFINE vcEsTransaccion  CHAR(1);
  define iSqlErr	      integer;
  define iSamErr	      integer;
  define cCodRet	      char(6);
  define dtFecha	      date;
  define cMensaje         char(120);
  define vEmpresa         char(3);
  define vFechahoy        date;
  define cNumCte          char(20);	 
  define cProceso         char(4);
  define cCod_ret_2       char(6);	 
  define iContGral        integer;
  define iContGral_2      integer;
  define vNum_credito     char(20);
  define dImporteConvenio decimal(18,2);
  define dtHora_insert    DATETIME HOUR to FRACTION(3);
  define dtFecha_convenio date;
  define cSucursal_pago   char(4);
  define cSucursal_pago_2 char(4);
  define vNum_credito_2   char(20);
  define iNum_pm_realizados    integer;
  define iNum_pm_no_realizados integer;
  define cCalificacion         char(1);
  define dTotal_importe        decimal(18,2);
  define dImp_pagado_acum      decimal(18,2); 
  define dFecha_vencim    date;
  
  define vPlazo           char(2);
  define iCteAsisteSuc    integer;
  define cOrigen          char(10);
  define pSucursalOrig    char(4);
  define psucursal        char(4);
  define pfechasistema    date;
  define pefectuo_compac  integer;
  define pnombre_efectuo  char(40);
  define pnumcuenta       char(20);
  define pnumproducto		char(4); 
  define pplazo           char(2);
  define porigen	        smallint;
  define ptipo_compac     char(1);
  define pimporte         decimal(18,2);
  define dImp_pagado      decimal(18,2);
  define cUsuario_pago    char(8);
  define cNomUsuario_pago char(45);
  
  define dtFecha_hoy      date;
  define dt_pri_dia_mes   date;
  define dt_ult_dia_mes   date;  
  define dtFecha_ini      date;
  define dtFecha_fin      date;
  define dtFecha_insert   date;
  define iNumConvenios    integer;
  define cReinicio		  char(1);
  define cMensajeRet	  char(80);
  define iCuentasEliminadas     integer; 
  define iCuentasIns_crd        integer;
  define iCuentasEliminadas_crd integer;
  define dMonto_pagomin         decimal(18,2);
  define dMonto_recup_pm        decimal(18,2); 
  define dMonto_saldo_vencido   decimal(18,2); 
  define dMonto_recup_sv        decimal(18,2);
  define iNum_sv_realizados     integer;
  define iNum_sv_no_realizados  integer;
  define iCuentasIns_evalobj_nvahis  integer;
  define iCuentasIns_evalobj_crd     integer;
  define iCuentasEliminadas_evalobj_nvahis integer;
  define iCuentasEliminadas_evalobj_crd    integer;
  define cTipoEjec      char(1);
  
  define dPct_cump_pm     decimal(8,2);   
  define dPct_cump_sv     decimal(8,2);
  define cEfectuo_compac  char(8);
  
  define dFecha_ctetit    date;    -- Para depurar cb_cob_vent_cliente_titular
  define cSucursal_ctetit char(4);
  define cEmpleado_ctetit char(8);
  define iCont_si         integer;
  define iCont_no         integer;
  
  define dtFecha_ini_mes_ant      date;
  define dtFecha_fin_mes_ant      date;
  define iCuentasIns_ctetit        integer; 
  define iCuentasEliminadas_ctetit integer;
  define iCuentasEliminadas_ctetit_his integer;
  define iRegsABorrar    integer;
  define dtFecha_ini_mes_ant_2m      date;
  define dtFecha_fin_mes_ant_2m      date;
  define iCuentasEliminadas_ctetit_operativa integer;
    
  let cCodRet	        = "000000";
  let dtFecha           = date(1);
  let cMensaje          = 'PROCESO EXITOSO';	  
  let vEmpresa          = '001';
  let vFechahoy         = date(1);
  let cNumCte           = '';
  let cProceso          = '0088';
  let cCod_ret_2        = '';
  let iContGral         = 0;
  let iContGral_2       = 0;
  let vNum_credito      = '';
  let dImporteConvenio  = 0;
  let dtHora_insert     = CURRENT;
  let dtFecha_convenio  = date(1);
  let cSucursal_pago    = ''; 
  let cSucursal_pago_2  = '';
  let vNum_credito_2    = '';
  let iNum_pm_realizados = 0;
  let iNum_pm_no_realizados = 0;
  let cCalificacion      = '';
  let dTotal_importe     = 0;

  let iCteAsisteSuc    = 0;
  let cOrigen          = '';
  let pSucursalOrig    = '';
  let psucursal        = ''; 
  let pfechasistema    = date(1); 
  let pefectuo_compac  = 0;
  let pnombre_efectuo  = '';
  let pnumcuenta       = '';
  let pnumproducto     = '';
  let pplazo           = '';
  let porigen          = 0;
  let ptipo_compac     = '';
  let pimporte         = 0;  
  let dImp_pagado      = 0;
  let vPlazo           = '';
  let dImp_pagado_acum = 0;
  
  let vcCodRet  = '00000';
  let viSqlErr  = 0;
  let vDataErr	= '';
  let vcEsTransaccion = '';
  let dFecha_vencim = date(1);
  let cUsuario_pago = '';
  let cNomUsuario_pago = '';
  
  let dtFecha_hoy     = date(1); 
  let dt_pri_dia_mes  = date(1); 
  let dt_ult_dia_mes  = date(1);
  let dtFecha_ini     = date(1);
  let dtFecha_fin     = date(1);
  let dtFecha_insert  = date(1);
  let iNumConvenios   = 0;
  let cReinicio       = '';
  let iCuentasEliminadas = 0;
  let iCuentasIns_crd    = 0;
  let iCuentasEliminadas_crd = 0;
  let dMonto_pagomin     = 0;
  let dMonto_recup_pm    = 0;
  let dMonto_saldo_vencido  = 0; 
  let dMonto_recup_sv       = 0;
  let iNum_sv_realizados    = 0;
  let iNum_sv_no_realizados = 0;
  let iCuentasIns_evalobj_nvahis = 0;
  let iCuentasIns_evalobj_crd = 0;
  let iCuentasEliminadas_evalobj_nvahis = 0;
  let iCuentasEliminadas_evalobj_crd = 0;
  
  let cTipoEjec = pTipoEjec;
  let dPct_cump_pm  = 0;
  let dPct_cump_sv  = 0;
  let cEfectuo_compac = '';

  let dFecha_ctetit    = date(1);   
  let cSucursal_ctetit = ''; 
  let cEmpleado_ctetit = '';
  let iCont_si         = 0; 
  let iCont_no         = 0; 
  
  let dtFecha_ini_mes_ant = date(1);
  let dtFecha_fin_mes_ant = date(1);
  let iCuentasIns_ctetit  = 0;
  let iCuentasEliminadas_ctetit = 0; 
  let iCuentasEliminadas_ctetit_his = 0;
  let iRegsABorrar  = 0;
  let dtFecha_ini_mes_ant_2m = date(1);
  let dtFecha_fin_mes_ant_2m = date(1);
  let iCuentasEliminadas_ctetit_operativa = 0;
  let iCuentasEliminadas_ctetit_his = 0;
  
BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDataErr
        IF iSqlErr <> 0 THEN
            LET cCodRet=iSqlErr ;
			let cMensaje = trim(cCodRet) || ' ' || vNum_credito;
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '02') RETURNING cCod_ret_2;
			 
            RETURN cCodRet, trim(cMensaje);
        END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/ifxsif01/macf/sp_depura_tbls_eval_objetiva.out";
	--TRACE ON;

	--CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
	CALL bdicobranza:sp_inserta_bitacora_cob(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
   
    -- Se depurará cada mes lo del meses anterior
    -- correrá al cierre del día 1
	
	if cTipoEjec = 'A' then
	
		SELECT fecha_hoy, pri_dia_mes, ult_dia_mes 
		  INTO dtFecha_hoy, dt_pri_dia_mes, dt_ult_dia_mes
		  FROM bdinteg:si_fechas
		 WHERE empresa = vEmpresa;
	   
         --LET dtFecha_hoy = MDY(11,2,2020);     -- SOLO TEST
		 --LET dt_pri_dia_mes = MDY(11,1,2020);  -- SOLO TEST
		 --LET dt_ult_dia_mes = MDY(11,30,2020); -- SOLO TEST
		 
		 let dtFecha_fin = date(dt_pri_dia_mes -1 units day);
		 let dtFecha_ini = month(dtFecha_fin)||'/01/'||year(dtFecha_fin);
		 		 
         let dtFecha_fin_mes_ant = date(dtFecha_ini -1 units day);
		 let dtFecha_ini_mes_ant = month(dtFecha_fin_mes_ant)||'/01/'||year(dtFecha_fin_mes_ant);
		 
		 let dtFecha_fin_mes_ant_2m = date(dtFecha_ini_mes_ant -1 units day);
		 let dtFecha_ini_mes_ant_2m = month(dtFecha_fin_mes_ant_2m)||'/01/'||year(dtFecha_fin_mes_ant_2m);
		 
    elif cTipoEjec = 'M' then
	     if (pFechaIni = '' or pFechaIni = '01/01/1900') or (pFechaFin = '' or pFechaFin = '01/01/1900') then
             LET cCodRet     = "000018";
		     LET cMensajeRet = "Error al obtener las fechas";
		     RETURN cCodRet, cMensajeRet;
	     else
	         let dtFecha_ini = pFechaIni;
             let dtFecha_fin = pFechaFin;
			 
			 let dtFecha_fin_mes_ant = date(dtFecha_ini -1 units day);
		     let dtFecha_ini_mes_ant = month(dtFecha_fin_mes_ant)||'/01/'||year(dtFecha_fin_mes_ant);
			 
		     let dtFecha_fin_mes_ant_2m = date(dtFecha_ini_mes_ant -1 units day);
		     let dtFecha_ini_mes_ant_2m = month(dtFecha_fin_mes_ant_2m)||'/01/'||year(dtFecha_fin_mes_ant_2m);
			 
	     end if; 
    end if;	

	--let dtFecha_hoy = mdy(9,2,2019);     -- SOLO TEST
	--let dt_pri_dia_mes = mdy(9,1,2019);   -- SOLO TEST
	--let dtFecha_fin = date(dt_pri_dia_mes -1 units day);              -- SOLO TEST
    --let dtFecha_ini = month(dtFecha_fin)||'/01/'||year(dtFecha_fin);  -- SOLO TEST
	

	
   SELECT valor INTO cReinicio FROM bdicobranza:cb_param WHERE empresa = vEmpresa AND cod_param = 6;

	IF NVL(cReinicio,"") = "" THEN
		LET cCodRet     = "000019";
		LET cMensajeRet = "Error al obtener el parametro de reinicio";
		RETURN cCodRet, cMensajeRet;
	END IF;
   
   IF cReinicio = '0' THEN
	   FOREACH WITH HOLD
		   SELECT a.num_credito, a.sucursal_origen, a.sucursal_pago, a.sucursal_convenio, a.fecha_insert, a.cajero, a.nom_cajero, a.num_producto, a.plazo, a.origen, 
		          a.tipo_compac, a.convenio_monto, a.convenio_abono, a.cte_con_vencido, a.num_convenios, a.num_pm_realizados, a.num_pm_no_realizados, a.calificacion, 
				  a.fecha_compac, a.fecha_vencim
			 INTO vNum_credito, pSucursalOrig, cSucursal_pago, psucursal, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, vPlazo, cOrigen, 
			 ptipo_compac, dImporteConvenio, dTotal_importe, iCteAsisteSuc, iNumConvenios, iNum_pm_realizados, iNum_pm_no_realizados,
				   cCalificacion, dtFecha_convenio, dFecha_vencim
			 FROM bdicobranza:cb_evaluacion_objetiva_convenios a
			 WHERE a.fecha_vencim between dtFecha_ini and dtFecha_fin
			   AND a.num_credito not in(select num_credito from cb_evaluacion_objetiva_convenios_his 
			                             where num_credito = a.num_credito and fecha_vencim = a.fecha_vencim)

	        
			begin work;
				INSERT INTO bdicobranza:cb_evaluacion_objetiva_convenios_his(num_credito, sucursal_origen, sucursal_pago, sucursal_convenio, fecha_insert, cajero, nom_cajero, 
							   num_producto, plazo,	origen, tipo_compac, convenio_monto, convenio_abono, cte_con_vencido, 
							   num_convenios, num_pm_realizados, num_pm_no_realizados, calificacion, fecha_compac, fecha_vencim)
																							 
				VALUES(vNum_credito, pSucursalOrig, cSucursal_pago, psucursal, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, vPlazo, cOrigen, ptipo_compac, 
					   dImporteConvenio, dTotal_importe, iCteAsisteSuc, iNumConvenios, iNum_pm_realizados, iNum_pm_no_realizados, cCalificacion, dtFecha_convenio, dFecha_vencim);
		
		        let iContGral_2 = iContGral_2 + 1;

				DELETE bdicobranza:cb_evaluacion_objetiva_convenios
                 WHERE num_credito = vNum_credito
                   AND fecha_vencim = dFecha_vencim; 
				   
		        LET iCuentasEliminadas = iCuentasEliminadas +1;
		         
			commit work; 
	   
		END FOREACH   
    
	    IF iContGral_2 > 0 THEN
	       LET cMensaje = 'TOTAL Ctas PROCS. Eval Obj Convs: ' || iContGral_2;
	       LET cMensaje = TRIM(cMensaje) ||' - TOTAL Ctas INSERT a histórica: ' || iContGral_2;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL Ctas ELIMINADAS Eval Obj Convs: ' || iCuentasEliminadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
	    END IF;     
	
	    let cReinicio = '1';
	    UPDATE bdicobranza:cb_param SET valor = cReinicio WHERE empresa = vEmpresa AND cod_param = 6;

	END IF;
    		
   

    IF cReinicio = '1' THEN
      FOREACH WITH HOLD
		  
		  SELECT a.num_credito, a.sucursal_origen, a.sucursal_pago, a.sucursal_convenio, a.fecha_insert, a.cajero, a.nom_cajero, a.num_producto, a.plazo, a.origen, 
		         a.tipo_compac, a.convenio_monto, a.convenio_abono, a.cte_con_vencido, a.num_convenios, a.num_pm_realizados, a.num_pm_no_realizados, a.calificacion, 
				 a.fecha_compac, a.fecha_vencim 
            INTO vNum_credito, pSucursalOrig, cSucursal_pago, psucursal, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, vPlazo, cOrigen, 
			     ptipo_compac, dImporteConvenio, dTotal_importe, iCteAsisteSuc, iNumConvenios, iNum_pm_realizados, iNum_pm_no_realizados, cCalificacion, 
				 dtFecha_convenio, dFecha_vencim
			FROM bdicobranza:cb_evaluacion_objetiva_convenios_crd a
           WHERE fecha_vencim between dtFecha_ini and dtFecha_fin
			 AND a.num_credito not in(select num_credito from bdicobranza:cb_evaluacion_objetiva_convenios_crd_his 
			                          where num_credito = a.num_credito and fecha_vencim = a.fecha_vencim)   

		begin work;
			   INSERT INTO bdicobranza:cb_evaluacion_objetiva_convenios_crd_his(num_credito, sucursal_origen, sucursal_pago, sucursal_convenio, fecha_insert, cajero, nom_cajero, 
			                                                                num_producto, plazo, origen, tipo_compac, convenio_monto, convenio_abono, cte_con_vencido, 
																			num_convenios, num_pm_realizados, num_pm_no_realizados, calificacion, fecha_compac, fecha_vencim)
			                                                          
																	 
			 																 
			   VALUES (vNum_credito, pSucursalOrig, cSucursal_pago, psucursal, dtFecha_insert, pefectuo_compac, pnombre_efectuo,  pnumproducto, vPlazo, cOrigen, ptipo_compac, 
			           dImporteConvenio, dTotal_importe, iCteAsisteSuc, iNumConvenios, iNum_pm_realizados, iNum_pm_no_realizados, cCalificacion, dtFecha_convenio,dFecha_vencim);
        
				let iCuentasIns_crd = iCuentasIns_crd + 1;
		
				DELETE bdicobranza:cb_evaluacion_objetiva_convenios_crd
                 WHERE num_credito = vNum_credito
                   AND fecha_vencim = dFecha_vencim; 
				   
		        LET iCuentasEliminadas_crd = iCuentasEliminadas_crd +1;
		
		commit work;
		

 	  END FOREACH   
	  
	  IF iCuentasIns_crd > 0 THEN
	       LET cMensaje = 'TOTAL Ctas PROCS. Eval Obj Convs CRD: ' || iCuentasIns_crd;
	       LET cMensaje = TRIM(cMensaje) ||' - TOTAL Ctas INSERT a histórica CRD: ' || iCuentasIns_crd;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL Ctas ELIMINADAS Eval Obj Convs CRD: ' || iCuentasEliminadas_crd;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
	  END IF;     
	
	  let cReinicio = '2';
      UPDATE bdicobranza:cb_param SET valor = cReinicio WHERE empresa = vEmpresa AND cod_param = 6;	  
	END IF;

		
	IF cReinicio = '2' THEN
		FOREACH WITH HOLD
	
			SELECT a.num_credito, a.sucursal_origen, a.sucursal_pago, a.fecha_insert, a.cajero, a.nom_cajero, a.num_producto, a.monto_pago_minimo, a.monto_recup_pm, 
			       a.num_pm_realizados, a.num_pm_no_realizados, a.monto_saldo_vencido, a.monto_recup_sv, a.num_sv_realizados, a.num_sv_no_realizados, a.pct_cump_pm, a.pct_cump_sv
			  --INTO vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm, 
			  INTO vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, cEfectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm, 
			       iNum_pm_realizados, iNum_pm_no_realizados, dMonto_saldo_vencido, dMonto_recup_sv, iNum_sv_realizados, iNum_sv_no_realizados, dPct_cump_pm, dPct_cump_sv
			  FROM bdicobranza:cb_evaluacion_objetiva_nueva a
			  WHERE a.num_credito >= '600000000001' and a.fecha_insert between dtFecha_ini and dtFecha_fin
               AND a.num_credito not in(select num_credito from bdicobranza:cb_evaluacion_objetiva_nueva_his 
			                             where num_credito = a.num_credito and fecha_insert = a.fecha_insert)
										 
			begin work;
				INSERT INTO bdicobranza:cb_evaluacion_objetiva_nueva_his(num_credito, sucursal_origen, sucursal_pago, fecha_insert, cajero, nom_cajero, num_producto, 
				       monto_pago_minimo, monto_recup_pm, num_pm_realizados, num_pm_no_realizados, monto_saldo_vencido, monto_recup_sv, num_sv_realizados, num_sv_no_realizados,
					   pct_cump_pm, pct_cump_sv)					   

				 --VALUES(vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm,
				 VALUES(vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, cEfectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm,
 			           iNum_pm_realizados, iNum_pm_no_realizados, dMonto_saldo_vencido, dMonto_recup_sv, iNum_sv_realizados, iNum_sv_no_realizados, dPct_cump_pm, dPct_cump_sv); 
			
			    let iCuentasIns_evalobj_nvahis = iCuentasIns_evalobj_nvahis + 1;
			
	            DELETE bdicobranza:cb_evaluacion_objetiva_nueva
				 WHERE num_credito = vNum_credito
				   AND fecha_insert = dtFecha_insert;
	            
				let iCuentasEliminadas_evalobj_nvahis = iCuentasEliminadas_evalobj_nvahis + 1;
	
	        commit work;
					
		END FOREACH
		
		IF iCuentasIns_evalobj_nvahis > 0 THEN
	       LET cMensaje = 'TOTAL Ctas PROCS. Eval Obj Nva: ' || iCuentasIns_evalobj_nvahis;
	       LET cMensaje = TRIM(cMensaje) ||' - TOTAL Ctas INSERT a Nva histórica: ' || iCuentasIns_evalobj_nvahis;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL Ctas ELIMINADAS Eval Obj Nva: ' || iCuentasEliminadas_evalobj_nvahis;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
	    END IF;
		

	let cReinicio = '3';
    UPDATE bdicobranza:cb_param SET valor = cReinicio WHERE empresa = vEmpresa AND cod_param = 6;	
	END IF;	

	
	IF cReinicio = '3' THEN
		FOREACH WITH HOLD
	
	         SELECT a.num_credito, a.sucursal_origen, a.sucursal_pago, a.fecha_insert, a.cajero, a.nom_cajero, a.num_producto, a.monto_pago_minimo, a.monto_recup_pm, 
			        a.num_pm_realizados, a.num_pm_no_realizados, a.monto_saldo_vencido, a.monto_recup_sv, a.num_sv_realizados, a.num_sv_no_realizados, a.pct_cump_pm, a.pct_cump_sv 
               --INTO vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm, 
			   INTO vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, cEfectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm, 
			       iNum_pm_realizados, iNum_pm_no_realizados, dMonto_saldo_vencido, dMonto_recup_sv, iNum_sv_realizados, iNum_sv_no_realizados, dPct_cump_pm, dPct_cump_sv
			   FROM bdicobranza:cb_evaluacion_objetiva_crd a
			   WHERE a.num_credito >= '600000000001' and a.fecha_insert between dtFecha_ini and dtFecha_fin
                 AND a.num_credito not in(select num_credito from bdicobranza:cb_evaluacion_objetiva_crd_his 
			                               where num_credito = a.num_credito and fecha_insert = a.fecha_insert)
	
	         begin work;
			    INSERT INTO bdicobranza:cb_evaluacion_objetiva_crd_his(num_credito, sucursal_origen, sucursal_pago, fecha_insert, cajero, nom_cajero, num_producto, 
				       monto_pago_minimo, monto_recup_pm, num_pm_realizados, num_pm_no_realizados, monto_saldo_vencido, monto_recup_sv, num_sv_realizados, num_sv_no_realizados,
					   pct_cump_pm, pct_cump_sv) 
	            --VALUES(vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm, 
				VALUES(vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, cEfectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm, 
			       iNum_pm_realizados, iNum_pm_no_realizados, dMonto_saldo_vencido, dMonto_recup_sv, iNum_sv_realizados, iNum_sv_no_realizados, 
				       dPct_cump_pm, dPct_cump_sv);   
		    
			    let iCuentasIns_evalobj_crd = iCuentasIns_evalobj_crd + 1;
				
  			    DELETE bdicobranza:cb_evaluacion_objetiva_crd
				 WHERE num_credito = vNum_credito
				   AND fecha_insert = dtFecha_insert;

                let iCuentasEliminadas_evalobj_crd = iCuentasEliminadas_evalobj_crd	+ 1;
				
			commit work;
		END FOREACH
		
		IF iCuentasIns_evalobj_crd > 0 THEN
	       LET cMensaje = 'TOTAL Ctas PROCS. Eval Obj CRD: ' || iCuentasIns_evalobj_crd;
	       LET cMensaje = TRIM(cMensaje) ||' - TOTAL Ctas INSERT a CRD histórica: ' || iCuentasIns_evalobj_crd;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL Ctas ELIMINADAS Eval Obj CRD: ' || iCuentasEliminadas_evalobj_crd;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
	    END IF;
		
		let cReinicio = '4';
		UPDATE bdicobranza:cb_param SET valor = cReinicio WHERE empresa = vEmpresa AND cod_param = 6;
	
			
	END IF;	
	
	-- dtFecha_fin = 01/10  dtFecha_ini= 31/10    dtFecha_fin_mes_ant= 30/09   dtFecha_ini_mes_ant= 01/09
	
	IF cReinicio = '4' THEN
        -- Ejem cuando corra en nov, dtFecha_hoy = 02/11, dt_pri_dia_mes= 01/11, dt_ult_dia_mes= 30/11  (bdinteg:si_fechas)
		FOREACH WITH HOLD
		
			SELECT fecha, sucursal, empleado, cont_si, cont_no 
			  INTO dFecha_ctetit, cSucursal_ctetit, cEmpleado_ctetit, iCont_si, iCont_no
			  FROM bdicobranza:cb_cob_vent_cliente_titular
	         WHERE fecha between dtFecha_ini_mes_ant and dtFecha_fin_mes_ant
			 
			 BEGIN WORK;
			    INSERT INTO bdicobranza:cb_cob_vent_cliente_titular_his(fecha, sucursal, empleado, cont_si, cont_no) 
	              VALUES(dFecha_ctetit, cSucursal_ctetit, cEmpleado_ctetit, iCont_si, iCont_no);

				let iCuentasIns_ctetit  = iCuentasIns_ctetit +1;
				
			 COMMIT WORK;
			 
		END FOREACH
		
  		
		let iCuentasEliminadas_ctetit = 0;
		
		FOREACH WITH HOLD
		
			SELECT fecha, sucursal, count(*)
			  INTO dFecha_ctetit, cSucursal_ctetit, iRegsABorrar
			  FROM bdicobranza:cb_cob_vent_cliente_titular
			 WHERE fecha between dtFecha_ini_mes_ant and dtFecha_fin_mes_ant
			 GROUP by 1,2
			
			BEGIN WORK;
				DELETE bdicobranza:cb_cob_vent_cliente_titular
				WHERE  fecha = dFecha_ctetit AND sucursal = cSucursal_ctetit;
			COMMIT WORK;
		    
			let iCuentasEliminadas_ctetit = iCuentasEliminadas_ctetit + iRegsABorrar;
			
			let iRegsABorrar = 0;
		END FOREACH
		let iCuentasEliminadas_ctetit_operativa = iCuentasEliminadas_ctetit;
		let iCuentasEliminadas_ctetit = 0;
			
	
		---- HIS
		FOREACH WITH HOLD
		
			SELECT fecha, sucursal, count(*)
			  INTO dFecha_ctetit, cSucursal_ctetit, iRegsABorrar
			  FROM bdicobranza:cb_cob_vent_cliente_titular_his
			 WHERE fecha between dtFecha_ini_mes_ant_2m and dtFecha_fin_mes_ant_2m
			 GROUP by 1,2
			
			BEGIN WORK;
				DELETE bdicobranza:cb_cob_vent_cliente_titular_his
				WHERE  fecha = dFecha_ctetit AND sucursal = cSucursal_ctetit;
			COMMIT WORK;
		    
			let iCuentasEliminadas_ctetit = iCuentasEliminadas_ctetit + iRegsABorrar;
			
			let iRegsABorrar = 0;
		END FOREACH
		let iCuentasEliminadas_ctetit_his = iCuentasEliminadas_ctetit;
				
		
		/*
		FOREACH WITH HOLD
		
			SELECT fecha, sucursal, empleado, cont_si, cont_no 
			  INTO dFecha_ctetit, cSucursal_ctetit, cEmpleado_ctetit, iCont_si, iCont_no
			  FROM bdicobranza:cb_cob_vent_cliente_titular_his
	         WHERE fecha between dtFecha_ini_mes_ant and dtFecha_fin_mes_ant
		
		    BEGIN WORK;
				DELETE bdicobranza:cb_cob_vent_cliente_titular_his
				 WHERE fecha = dFecha_ctetit,
				   AND sucursal = cSucursal_ctetit, empleado = cEmpleado_ctetit;
			COMMIT WORK;   
			
			let iCuentasEliminadas_ctetit_his = iCuentasEliminadas_ctetit_his +1;
				 
		END FOREACH		
	    */
		
		IF iCuentasIns_ctetit > 0 THEN
		   
		   --LET cMensaje = 'TOTAL Ctas PROCS. Cliente Titular: ' || iCuentasIns_ctetit;
	       LET cMensaje = ' TOTAL Ctas Cte Titular INSERT a histórica: ' || iCuentasIns_ctetit;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL Ctas Cte Titular ELIMINADAS: ' || iCuentasEliminadas_ctetit_operativa;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		END IF;
		
		IF iCuentasEliminadas_ctetit_his > 0 THEN
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL Ctas Cte Titular His ELIMINADAS: ' || iCuentasEliminadas_ctetit_his;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		END IF;
		let cReinicio = '0';
        UPDATE bdicobranza:cb_param SET valor = cReinicio WHERE empresa = vEmpresa AND cod_param = 6;
		
	END IF;
	
	
	
 --let cContGral = iContGral;
 LET cMensaje = 'PROCESO EXITOSO';
 --LET cMensaje = trim(cMensaje) || '. ' || iContGral || ' UPDs - ' || iContGral_2 || ' Inserts.' ;
 CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2;  
 --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2; 
 
 	
    ---RETURN cCodRet;
	RETURN cCodRet, trim(cMensaje);
	END
END PROCEDURE
DOCUMENT
'BD: bdicobranza',
'Ver: 1.0.0', 
'Autor: Marco A. Campos',
'Fecha: 20190901',
'DESCRIPCION: Depuración mensual de tablas de evaluación objetiva',
'Ver: 1.0.1',
'Autor: Marco A. Campos',
'Fecha: 20200802',
'Descripción: Modif para resolver incidencia error -1213 por tipo de dato en var. pefectuo_compac';

CREATE PROCEDURE "informix".sp_mail_primerconsumo()
returning 
VARCHAR(6)  AS codigo_retorno,
CHAR(80)    AS mensaje_retorno;

------------------------------------------------------------------------------------
--Maria Elizabeth Anzures Ibarguen
--2012-05-09
--crea archivo con datos que se muestran en pantalla cat con cliente con mora 1

----DATOS QUE VAN EN LA TABLA
DEFINE vnumcte		char(20);
define vnumcredito	char(20);
define vnumtarjeta	char(20);
define vimporte		decimal(18,2);
define vfecha		date;
define vfechas		date;


---DECLARACIONES
DEFINE cNumCta			CHAR(20);
DEFINE dCapMtoCuota		DECIMAL(18,2);
DEFINE cDiasAnticipados	DECIMAL(18,2);
DEFINE cCel				CHAR(13);
DEFINE cEstado			CHAR(2);
DEFINE cCiudad			CHAR(3);
DEFINE cNombre1			CHAR(26);
DEFINE cNombre2			CHAR(26);
DEFINE cApellPat		CHAR(26);
DEFINE cApellMat		CHAR(26);
DEFINE cTipoRed			CHAR(10);
DEFINE cCodRet2			CHAR(6);
DEFINE cNumCarrier		CHAR(3);
DEFINE cSituacion		CHAR(1);
DEFINE iCausa			INTEGER;
DEFINE cNomEstado 		CHAR(20);
DEFINE cNomCiudad 		CHAR(20);
DEFINE iPagoVenc 		INTEGER;
DEFINE vSdoTotal1  		DECIMAL(18,2);
DEFINE vMtoVencido1  	DECIMAL(18,2);
DEFINE vMensualidad 	DECIMAL(18,2);
DEFINE vSdoTotal2  		DECIMAL(18,2);
DEFINE vMtoVencido2 	DECIMAL(18,2);
DEFINE vsaldo_total 	DECIMAL(18,2);
DEFINE v_sdo_venc_int_mora  DECIMAL(18,2);
DEFINE v_pago_min_sin_vdo   DECIMAL(18,2);
DEFINE vpago_minimo_total   DECIMAL(18,2);
define vpago 			DECIMAL(18,2);
DEFINE Vfecha_apertura 	DATE;
DEFINE iCel 			SMALLINT;
DEFINE vdia_pago 		smallint;
DEFINE vmail 			char(100);
DEFINE vvalor_numerico	INTEGER;
DEFINE vtotal1			INTEGER;
DEFINE vtotal2			INTEGER;
DEFINE vtotal			INTEGER;
define vregistrostotal	integer;
define vfecha1 			date;
define vfecha2 			date;
define vimporte1		DECIMAL(18,2);
define vimporte2 		DECIMAL(18,2);     

---VARIABLES PARA CAPTURAR ERRORES
DEFINE SQL_ERR          INTEGER;
DEFINE ISAM_ERR         INTEGER;
DEFINE ERROR_INFO       VARCHAR(80);
DEFINE P_COD_RET     	VARCHAR(6);
DEFINE P_MENSAJE     	VARCHAR(80);
DEFINE vproceso			CHAR (4);
DEFINE cMensaje			CHAR(150);
DEFINE vpago_vencido	DECIMAL(18,2);
DEFINE vcontador		INTEGER;
define vpri_dia_mes		date;
define vapell_paterno 	char(30);
--define vcount 			INTEGER;
define iCount_TC_PRIMERC INTEGER; --A.L.L.
define iCount_TC_PRIMERS INTEGER; --A.L.L.
	define vvalor smallint;
define i integer;
define num smallint;
define vNumIniciudad 	char(8); --A.L.L
define vEstadoSiglas	char(10); --A.L.L
DEFINE iCuentasProcesadas     integer; 
DEFINE iCuentasExcluidasXMail integer;
--DEFINE iCuentasExcluidasXSdosVencidos integer;
--DEFINE dFechaCarLinea   date;
DEFINE iOtrasExclusiones integer;
DEFINE cNumProducto 	 char(04);
DEFINE iCuentasExcluidasXCel	INTEGER;

---INICIALIZACIONES
LET cNumCta				= '';
LET dCapMtoCuota		= 0;
LET	cDiasAnticipados	= 0;
LET cCel				= '';
LET cEstado				= '';
LET cCiudad				= '';
LET cNombre1			= '';
LET cNombre2			= '';
LET cApellPat			= '';
LET cApellMat			= '';
LET cTipoRed			= '';
LET cCodRet2			= '';
LET cNumCarrier			= '';
LET cSituacion			= '';
LET iCausa				= 0;
LET cNomEstado = '';
LET cNomCiudad = '';
LET iPagoVenc = 0;
LET vSdoTotal1 = 0;
LET vMtoVencido1 = 0;
LET vMensualidad = 0;
LET vSdoTotal2 = 0;
LET vMtoVencido2 = 0;
LET vsaldo_total = 0;
LET v_sdo_venc_int_mora = 0;
LET v_pago_min_sin_vdo = 0;
LET vpago_minimo_total = 0;
let vpago = 0;
LET iCel = 0;
LET vdia_pago = 0;
LET vpago_vencido = 0;

let vnumcte = '';
let vnumcredito = '';
let vnumtarjeta = '';
let vimporte	=0;
let vfecha		= date(1);
let vfechas		= date(1);

let SQL_ERR		= 0;
let ISAM_ERR	= 0;
let ERROR_INFO	= '';
let P_COD_RET	= '000000';
--let P_MENSAJE	= 'PROCESO EXITOSO';
let P_MENSAJE	= 'El proceso de las campañas XX TDC PRIMER CONSUMO se realizó correctamente.';
let vproceso	= '2034';
let cMensaje	= '';
let vmail 		= '';
let vvalor_numerico	= 0;
let vtotal1			= 0;
let vtotal2			= 0;
let vtotal			= 0;
let vregistrostotal = 0;
let vcontador 		= 0;
let vfecha1 		= date(1);
let vfecha2 		= date(1);
let vimporte1		= 0;
let vimporte2 		= 0; 
let vpri_dia_mes = date(1);
let vapell_paterno = '';
--let vcount = 0;
let iCount_TC_PRIMERC = 0; --A.L.L.
let iCount_TC_PRIMERS = 0; --A.L.L.
let i = 0;
LET num = 0;
let vNumIniciudad	='';
let vEstadoSiglas	='';
let iCuentasProcesadas      = 0;
let iCuentasExcluidasXMail  = 0;
--let iCuentasExcluidasXSdosVencidos = 0;
--let dFechaCarLinea = date(1);
let iOtrasExclusiones = 0;
let cNumProducto 	= '';
let iCuentasExcluidasXCel = 0;


BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, P_MENSAJE, '02')RETURNING P_COD_RET;	
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        RETURN P_COD_RET,P_MENSAJE;
    END EXCEPTION;

--  Set debug file to 'sp_mail_primerconsumo.out';
--  trace on;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01')RETURNING P_COD_RET;	

    if P_COD_RET != '000000' then
--       let P_COD_RET = cCodRet;
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;

	select fecha_ant into vfecha from bdicred:sd_fechas where empresa = '001';
--temporal para pruebas	
	--let vfecha = today;
--temporal para pruebas
	let vpri_dia_mes = mdy(month(vfecha),day(1),year(vfecha));
    set isolation to dirty read;
	
--	DELETE FROM bdicobranza:cb_info_administrativa WHERE empresa ='001' and fecha_ejecucion <= today and num_campania = 16; 
		select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;
		
	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)		
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente, fecha_hora_registro,string1,importe1,fecha1,fecha2)
		select  1, 'TC_PRIMERC',numcte,current,apell_paterno,100,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
				
			let num = num + 10;
	end for
		
--------------------------------------------------------EMAIL------------------------------------------------------------------   
	FOREACH
	
		SELECT  
		a.numcte, a.num_credito, b.f_primer_compra,b.monto_primer_compra ,b.f_primer_disp, b.monto_primer_disp, a.num_producto
				INTO vnumcte, vnumcredito,vfecha1,vimporte1,vfecha2,vimporte2, cNumProducto
		FROM bdicred:sd_maecred a, bdicred:sd_indicador_cred b 
		WHERE a.empresa = '001'
			and a.empresa = b.empresa
			and a.num_credito = b.num_credito
			and a.num_producto = '6001'
			and (b.f_primer_compra = vfecha or b.f_primer_disp  = vfecha)
		--A.L.L	
		let iCuentasProcesadas = iCuentasProcesadas + 1;
		
		if (vfecha1 is null or vfecha2 is null) then
			if (vfecha1 = vfecha) then let vimporte = vimporte1; end if;
			if (vfecha2 = vfecha) then let vimporte = vimporte2; end if;
				
/*			select  apell_paterno into vapell_paterno
			from bdinteg:si_cliente where empresa = '001' and numcte = vnumcte ;*/
		  
			let vmail = '';
			select limit 1 cte.correo_elec into vmail 
			from  bdinteg:si_correos cte  where  cte.empresa ='001' and cte.numcte = vnumcte and cte.status_correo ='A'
			and cte.secuencia = (select max(secuencia) from bdinteg:si_correos 
				where empresa  = '001' and numcte = vnumcte and status_correo ='A');		

			if vmail is null or vmail = '' then 
		       let iCuentasExcluidasXMail = iCuentasExcluidasXMail + 1;
		       continue foreach; 
		    end if;

			select LIMIT 1 t.num_tarjeta into vnumtarjeta
			from bdicred:sd_tarjeta t
			where t.empresa = '001'
			and t.num_credito = vnumcredito
			and t.secuencia = (select max(tar.secuencia)
                from bdicred:sd_tarjeta tar
                where tar.empresa = '001'
                and tar.num_credito = vnumcredito
                and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
			and t.tipo_tarjeta ='T'  and t.status_tar = 'A';   
				
--			if (vmail <> '') then	
--				if nvl(vnumcte,'') <> '' then
				--A.L.L.
				LET iCount_TC_PRIMERC = iCount_TC_PRIMERC +1;
				call bdimnsj:"informix".sp_registra_evento (1, 'TC_PRIMERC' , vnumcte, vnumcredito,vnumtarjeta, 2,
							'','','','','',vimporte,0,0,0,0, today, '')RETURNING P_COD_RET;

				call "informix".sp_inserta_info_rep_envios ('001','EMAIL',1009, vnumcredito, vnumcte, cNumProducto, today, vmail, '','', 0) returning P_COD_RET;
--				end if;
--			end if;
		end if;
	END FOREACH

		--A.L.L.
	IF iCount_TC_PRIMERC > 0 THEN
--        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_PRIMERC',iCount_TC_PRIMERC) RETURNING P_COD_RET;
        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_PRIMERC',iCuentasProcesadas,iCuentasExcluidasXMail) RETURNING P_COD_RET;
	END IF;
	
--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña TC_PRIMERC : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados TC_PRIMERC : ' ||iCount_TC_PRIMERC;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error email : ' ||iCuentasExcluidasXMail;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
	   end if;
--Genera cifras de control

	
---------------------------------------------------------SMS-------------------------------------------------------	
	let vfecha1 = date(1);		let vfecha2 = date(1);		let vimporte1 = 0;		let vimporte2 = 0; 
	let iCuentasProcesadas = 0;
	--- foreach para sms 
	let vfechas = date(vfecha)	+ 1 units day;
	select valor_numerico 
			into vvalor_numerico
	from bdicobranza:cb_param_campania
	where tipo_campania = 51
		and grupo_parametro = 'LATINIA'
		and num_parametro = 1;
		
	select nvl(count(*),0) into vtotal1
	from bdimnsj:mnsjr_trx_batch_his
		where id_mensaje ='TC_PRIMERS' and DATE(fecha_hora_registro) >= vpri_dia_mes;
	select nvl(count(*),0) into vtotal2
	from bdimnsj:mnsjr_trx_batch
		where id_mensaje ='TC_PRIMERS' and DATE(fecha_hora_registro) >= vpri_dia_mes;
	let vtotal = vtotal1 + vtotal2;
		
		---- consulta para saber cuantos registros faltan por buscar al mes	
		let vregistrostotal = vvalor_numerico - vtotal;
		
		LET vtotal = vtotal;
		if (day(vfechas) = 1 ) then 
			let vtotal = 0; 
			let vregistrostotal = vvalor_numerico;
		end if;
		
if(vtotal < vvalor_numerico) then 
	FOREACH
	
		SELECT 
		a.numcte, a.num_credito, b.f_primer_compra,b.monto_primer_compra ,b.f_primer_disp, b.monto_primer_disp, a.num_producto
				INTO vnumcte, vnumcredito,vfecha1,vimporte1,vfecha2,vimporte2, cNumProducto
		FROM bdicred:sd_maecred a, bdicred:sd_indicador_cred b --, bdinteg:si_correos d
		WHERE a.empresa = '001'
			and a.empresa = b.empresa
			and a.num_credito = b.num_credito
			and a.num_producto = '6001'
			and (b.f_primer_compra = vfecha or b.f_primer_disp  = vfecha)
		--A.L.L.	
		let iCuentasProcesadas = iCuentasProcesadas + 1;
		
		if (vfecha1 is null or vfecha2 is null) then
			if (vfecha1 = vfecha) then let vimporte = vimporte1; end if;
			if (vfecha2 = vfecha) then let vimporte = vimporte2; end if;
				
			LET iPagoVenc = 0;		
		
			select LIMIT 1 t.num_tarjeta into vnumtarjeta
			from bdicred:sd_tarjeta t
			where t.empresa = '001'
			and t.num_credito = vnumcredito
			and t.secuencia = (select max(tar.secuencia)
                from bdicred:sd_tarjeta tar
                where tar.empresa = '001'
                and tar.num_credito = vnumcredito
                and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
			and t.tipo_tarjeta ='T'  and t.status_tar = 'A';   
				
/*			SELECT limit 1  e.nombre, c.nombre --NVL(estado,''), NVL(ciudad,'') 
		    INTO  cNomEstado, cNomCiudad  --cEstado, cCiudad
		    FROM bdinteg:"informix".si_direcciones_actual d, 
             bdinteg:"informix".si_estados e, 
             bdinteg:"informix".si_ciudades c 
			WHERE d.numcte= vnumcte
		     AND d.tipo_dir= '1'
		     AND d.estado = e.estado
		     AND d.ciudad = c.ciudad
		     AND c.estado = e.estado;*/
			 
			SELECT limit 1 d.telefono
		    INTO cCel
		    FROM bdinteg:"informix".si_telefonos_actual d
		    WHERE d.numcte= vnumcte
		     AND d.tipo_tel= '2' and status_tel = 'A' and cofetel ='V' ;

			if cCel is null or cCel = '' then 
		       let iCuentasExcluidasXCel = iCuentasExcluidasXCel + 1;
		       continue foreach; 
		    end if;

--			if (cCel <> '') then
		
				LET iCel = LENGTH(cCel) + 1 - 10;
    
--				IF cCel <> '' then
					IF ( LENGTH(cCel) > 10 ) THEN
						LET cCel = SUBSTR(cCel,iCel,10);
					ELIF ( LENGTH(cCel) < 10 ) THEN
						LET cCel =''; 
					END IF;		
--				END IF;
			
/*				SELECT NVL(nombre1,''), NVL(nombre2,''), NVL(apell_paterno,''), NVL(apell_materno,'')
				INTO cNombre1, cNombre2, cApellPat, cApellMat
				FROM bdinteg:"informix".si_cliente
				WHERE numcte= vnumcte;		*/
		
				SELECT {+ INDEX(bdisitesp:"informix".se_ctessitespcte se_ctessitespcte_idx1)} FIRST 1 situacion, causa
				INTO cSituacion, iCausa
				FROM bdisitesp:"informix".se_ctessitespcte
				WHERE numcte = vnumcte;
			
				IF cSituacion IS NULL THEN LET cSituacion = ''; END IF; 
				IF iCausa IS NULL THEN LET iCausa = 0; END IF; 
			
--				IF cCel <> '' then
--					if (vnumcredito is not null) then
/*					INSERT INTO bdicobranza:"informix".cb_info_administrativa
						(empresa, num_campania, producto, fecha_ejecucion, cliente, credito, cuenta, tarjeta, ciudad, estado, 
						nombre1, nombre2, apell_paterno, apell_materno, t_celular, sdo_total, 
						pago_min, fecha_pago, sdo_venc_int_mora, pago_venc, pago_min_sin_vdo, causa,situacion,
						pago_vencido ,pago_req_sms, cidad, estado)
					VALUES ('001', 16, '6001', today, vnumcte, vnumcredito, cNumCta, vnumtarjeta, cNomCiudad, cNomEstado, 
						cNombre1, cNombre2, cApellPat, cApellMat, cCel, 0,
						0, '', 0, iPagoVenc, 0, iCausa,cSituacion,0,vimporte, vNumIniciudad, vEstadoSiglas );*/
					--A.L.L.
					LET iCount_TC_PRIMERS = iCount_TC_PRIMERS +1;
					call bdimnsj:"informix".sp_registra_evento (2, 'TC_PRIMERS' , vnumcte, vnumcredito,vnumtarjeta, 2,
							'','','','','',0,0,0,0,0, '', '')RETURNING P_COD_RET;
							
					let vcontador = vcontador + 1;			
					call "informix".sp_inserta_info_rep_envios ('001','SMS',16, vnumcredito, vnumcte, cNumProducto, today, cCel, '','', 0) returning P_COD_RET;
					end if; 
--				end if;
--			end if;
			if (vcontador = vregistrostotal) then exit FOREACH; end if;
--		end if;
	END FOREACH
end if;
	
	if (vcontador >= 1) then 
	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1)
		select  2, 'TC_PRIMERS',numcte,current,apell_paterno
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
			let num = num + 10;
	end for
	end if;
	
	-------------------------------------------contadores------------------------------------	

		--A.L.L.
		IF iCount_TC_PRIMERS > 0 THEN
--            CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_PRIMERS',iCount_TC_PRIMERS) RETURNING P_COD_RET;
            CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_PRIMERS',iCuentasProcesadas,iCuentasExcluidasXCel) RETURNING P_COD_RET;
		END IF;
		
--Genera cifras de control
	    if iCuentasProcesadas > 0 then
	       let cMensaje = 'TOTAL Cuentas procesadas campaña TC_PRIMERS : ' ||iCuentasProcesadas;
	       let cMensaje = trim(cMensaje) ||'    EMAILs enviados TC_PRIMERS : ' ||iCount_TC_PRIMERS;
	       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
	       let cMensaje = 'Cuentas excluidas por error cel : ' ||iCuentasExcluidasXCel;
	       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
	    end if;
--Genera cifras de control
		
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '03')RETURNING P_COD_RET;	
--    RETURN P_COD_RET;

    if P_COD_RET != '000000' then
--       let P_COD_RET = cCodRet;
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;
    
	RETURN P_COD_RET,P_MENSAJE;
end;
end procedure;