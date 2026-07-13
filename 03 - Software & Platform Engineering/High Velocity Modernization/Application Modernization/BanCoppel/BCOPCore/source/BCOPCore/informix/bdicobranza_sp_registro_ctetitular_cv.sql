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