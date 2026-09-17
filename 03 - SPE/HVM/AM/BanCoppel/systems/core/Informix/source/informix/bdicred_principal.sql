CREATE PROCEDURE "informix".principal(p_Empresa  CHAR(3),
                           p_NumCredito             CHAR(20),
                           p_TpPago                 SMALLINT,
                           p_Monto                  MONEY(14,2),
                           p_Usuario                CHAR(8),
                           p_Sucursal               CHAR(4),
                           p_Folio                  LIKE sd_movdia.Folio_Suc,
                           p_Transacc               LIKE sd_movdia.Transacc_Suc)
						   
--EXECUTE PROCEDURE "informix".principal('001', '600591560153', 1, 920, 'informix', '0239', 1706202117062021, '6001');

--EXECUTE PROCEDURE "informix".principal('001','600544566810', 1, 920, 'informix', '0965', 1706202117062021, '6001');
--EXECUTE PROCEDURE "informix".principal('001','810000063786', 1, 560, 'informix', '0965', '1706202117062021', '6813');

   RETURNING CHAR(5),     -- Codigo de Retorno
	         MONEY(14,2), -- Remanente
             MONEY(14,2), -- Interes Moratorio Cobrado
             MONEY(14,2), -- Interes Vencido Cobrado
             MONEY(14,2), -- Capital Vencido Cobrado
             MONEY(14,2), -- Interes Vigente Cobrado
             MONEY(14,2), -- Capital Vigente Cobrado
             MONEY(14,2), -- Impuesto Cobrado
             MONEY(14,2), -- Comisiones Cobradas
             MONEY(14,2)  -- Seguro Cobrado

   DEFINE CodRet                CHAR(5);
   DEFINE CodRetqc              CHAR(5);
   DEFINE sql_err               SMALLINT;
   DEFINE isam_err              SMALLINT;
   DEFINE error_info            CHAR(40);
   DEFINE nRows                 SMALLINT;
   DEFINE Mensaje               CHAR(80);

   DEFINE wBegin                CHAR(1);
   DEFINE vcod_ret	            CHAR(5);

   DEFINE GLOBAL g_Sistema        CHAR(2)     DEFAULT '06';
   DEFINE GLOBAL g_Empresa        CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito     CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_TpPago         SMALLINT    DEFAULT 0;
   DEFINE GLOBAL g_Monto          MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Usuario        CHAR(8)     DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal       CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio          CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_Transacc       CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Fecha          DATE        DEFAULT '';
   DEFINE GLOBAL g_FechaProxPago  DATE        DEFAULT '';


   DEFINE GLOBAL g_NumProducto    CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Moratorio      MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_NumCte         CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_Divisa         CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_SdoMoratorio   MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_IntMora        MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_IntVenc        MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_CapVenc        MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_IntVig         MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_CapVig         MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_ManejaLinea    CHAR(1)     DEFAULT ' ';
   DEFINE GLOBAL g_CodigoFun      CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_PagoAdic       CHAR(1)     DEFAULT ' ';

   DEFINE GLOBAL g_SdoVencInt     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoVencTraInt  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_MontoVencido   MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_MtoVencTrasp   MONEY(14,2) DEFAULT 0;

   DEFINE GLOBAL g_SdoCapInsoluto   MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_MtoCapitalizado  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_MontoFinanciado  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_MontoReservado   MONEY(14,2) DEFAULT 0;

   DEFINE GLOBAL g_SdoIntAnticip  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoIntAntDev   MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_IntTraNoExig   MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoTrab4       MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoIntereses   MONEY(14,2) DEFAULT 0;

   DEFINE GLOBAL g_SdoAcumMesInt  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_ProvisionNorm  MONEY(14,2) DEFAULT 0;

   DEFINE GLOBAL  g_Remanente      MONEY(14,2) DEFAULT 0;
--   DEFINE GLOBAL  mRemanente_cq   MONEY(14,2) DEFAULT 0; --RQM 09 459
   DEFINE GLOBAL  g_IntMoraCob     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL  g_IntVencCob     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL  g_CapVencCob     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL  g_IntVigCob      MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL  g_CapVigCob      MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL  g_Impuesto       MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL  g_Comision       MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL  g_Seguro         MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL  g_IvaCte         DECIMAL(9,6) DEFAULT 0;
   DEFINE GLOBAL g_PagoCapVencido  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_ACT	   INTEGER DEFAULT 0;


   DEFINE vCapital           MONEY(14,2);
   DEFINE vTotPag            MONEY(14,2);
   DEFINE vReferencia        SMALLINT;
   DEFINE v_fcuota		     DATE;
   DEFINE v_capvenc          MONEY(14,2);
   DEFINE GLOBAL g_StCred	 CHAR(2) DEFAULT ' ';
   DEFINE ax_tranliq		 CHAR(4);
   DEFINE ax_status		     CHAR(1);
   DEFINE vCodTipCred        CHAR(2);
   DEFINE vSdoRetenido	  	 DECIMAL(14,2);
   DEFINE vIva			     DECIMAL(14,2);
   DEFINE vBloqueo	         INTEGER;
   DEFINE vcDisponCred CHAR(1);
    --------------------------------------------------------
    --	Varibale de Control de Fecha Proceso
    --------------------------------------------------------
   DEFINE vFechaHoy	    DATE;
   DEFINE v_forma_pago  CHAR(1);

   DEFINE mRemanente_cq   MONEY(14,2); --RQM 09 459

   
   --Usadas en CobraIvaInts
   DEFINE GLOBAL g_Iva          MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_MoraIva      MONEY(14,2) DEFAULT 0;
   DEFINE vCapNoTras	        MONEY(14,2);

   DEFINE vMontoCuotas          MONEY(14,2);

   DEFINE vIvaPag				MONEY(14,2);
   DEFINE vMoraPag				MONEY(14,2);
   DEFINE vIntPag				MONEY(14,2);
   DEFINE vIvaIntPag			MONEY(14,2);
   DEFINE tras_int_vig          MONEY(14,2);
   DEFINE vFecVenc              DATE;
   DEFINE vintmes               DECIMAL(18,2);
   DEFINE vfecha_ini            DATE;
   DEFINE vdia_corte            SMALLINT;
   DEFINE vMax_SdoFavor         DECIMAL(10,2);
   DEFINE pcod_fun              CHAR(3);
-- CAS   DEFINE vDiaVenc        INTEGER;
   DEFINE  vlIndicador		    CHAR(1);
   DEFINE vvcodigo_retorno    CHAR(6);
   DEFINE vvmensaje_retorno   CHAR(80);
   DEFINE dPago_minimo       DECIMAL(18,2);
   DEFINE dSaldo_vencido     DECIMAL(18,2);

   DEFINE dIntVdo          DECIMAL(18,2);
   DEFINE dIntMoratorio    DECIMAL(18,2);
   DEFINE dIvaIntVdo       DECIMAL(18,2);
   DEFINE dPagosVdos       DECIMAL(18,2);
   DEFINE dIvaIntMoratorio DECIMAL(18,2);
   DEFINE dIntMes_2        DECIMAL(18,2);
   DEFINE dIvaIntMes       DECIMAL(18,2);
   DEFINE dIntVig          DECIMAL(18,2);
   DEFINE dIvaIntVig       DECIMAL(18,2);
   DEFINE dMontoOtorgado   DECIMAL(18,2);
   DEFINE plimcred_sdofavor		DECIMAL(10,2);
   DEFINE porcentaje_sdofavor    DECIMAL(18,2);
   DEFINE cCodigo_concp    CHAR(2);
   DEFINE cFolio_CredisolPF CHAR(16);
   DEFINE cSucursalCsPF		CHAR(4);
   DEFINE sStatusPF        	SMALLINT;
   DEFINE dMonto_RetPF      DECIMAL(18,2);
   DEFINE vtarjeta         CHAR(20);
   DEFINE cproduto         VARCHAR(3);
   
   --Proceso Condonaciones y Quitas
   DEFINE vMontoCondonado  DECIMAL(18,2);
   DEFINE vMontoQuita     DECIMAL(18,2);
   DEFINE GLOBAL vIndProceso     CHAR(1) DEFAULT ' ';
   DEFINE vIndCQProducto  CHAR(1);
   DEFINE vSaldoTotal	  DECIMAL (14,2);
   DEFINE scod_ret        CHAR(3);
   DEFINE d_saldoInsoluto DECIMAL (14,2);
   DEFINE d_moratorio     DECIMAL (14,2);
   DEFINE d_ivaMoratorio  DECIMAL (14,2); 
   DEFINE d_interesVenc   DECIMAL (14,2); 
   DEFINE d_ivaIntVenc    DECIMAL (14,2);
   DEFINE d_totalLiquidacion DECIMAL (14,2);
   DEFINE vFechaVigencia  DATE;
   DEFINE vMontoCondona   DECIMAL (14,2);
   DEFINE vSdoFavor       DECIMAL (14,2);
   ------------
   DEFINE dPagoMinimo DECIMAL(18,2); 
   DEFINE dIntMes DECIMAL(18,2); 
   DEFINE IvaIntMes DECIMAL(18,2); 
   DEFINE vCancela CHAR(1);
   DEFINE vMontoTotal DECIMAL(18,2);
   DEFINE vMontoMora  DECIMAL(18,2);
   DEFINE vMontoIntVenc DECIMAL(18,2);   
   DEFINE vIntVencProporcion DECIMAL(18,2);

---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general   
	DEFINE csg_codigo_ret			CHAR(6);
	DEFINE csg_mensaje_ret			CHAR(80);
	DEFINE csg_num_credito			CHAR(20);
	DEFINE csg_cod_tipcred			CHAR(2);
	DEFINE cStatus					CHAR(2);
	DEFINE csg_fec_origen			DATE;
	DEFINE csg_fec_prox_pago		DATE;
	DEFINE csg_pago_min				MONEY(18,2);
	DEFINE csg_fec_ult_pago			DATE;
	DEFINE csg_plazo				INTEGER;
	DEFINE csg_pagos_realizados		INTEGER;
	DEFINE csg_linea_otorgada		MONEY(18,2);
	DEFINE csg_tasa_interes			DECIMAL(9,6);
	DEFINE csg_tasa_moratorios		DECIMAL(9,6);
	DEFINE csg_monto_sbc			DECIMAL(14,2);
	DEFINE csg_cap_vig				MONEY(18,2);
	DEFINE csg_cap_trans			MONEY(18,2);
	DEFINE csg_cap_vdo_exig			MONEY(18,2);
	DEFINE csg_cap_vdo_no_exig		MONEY(18,2);
	DEFINE csg_sdo_act_total_cap	MONEY(18,2);
	DEFINE csg_int_vig				MONEY(18,2);
	DEFINE GLOBAL csg_int_vdo				MONEY(18,2) DEFAULT 0.00; --RQM 09 459
	DEFINE GLOBAL csg_int_moratorios		MONEY(18,2) DEFAULT 0.00; --RQM 09 459
	DEFINE GLOBAL csg_iva_int_vdo			MONEY(18,2) DEFAULT 0.00; --RQM 09 459
	DEFINE GLOBAL csg_iva_int_moratorios	MONEY(18,2) DEFAULT 0.00; --RQM 09 459	
	DEFINE csg_int_mes				MONEY(18,2);
	DEFINE csg_sdo_act_total_int	MONEY(18,2);
	DEFINE csg_iva_int_vig			MONEY(18,2);
	DEFINE GLOBAL vQuitaEscVenc 	CHAR(1) DEFAULT ''; --RQM 09 459
	DEFINE v_MoraProvi              MONEY(18,2); --RQM 09 459
	DEFINE v_MoraIva                MONEY(18,2); --RQM 09 459
	DEFINE vIntVencido              MONEY(18,2); --RQM 09 459
	DEFINE vIntMoratorio            MONEY(18,2); --RQM 09 459
	DEFINE vDescuentoQuita          MONEY(18,2); --RQM 09 459
	DEFINE vPorcQuita               MONEY(18,2); --RQM 09 459
	DEFINE vMesesVencidos			SMALLINT;
	DEFINE vMesesHistoria			INTEGER;
	DEFINE vSdoCredito				DECIMAL(18,2);
	DEFINE vInteresDebe				DECIMAL(14,2);
	DEFINE vInteresPagado			DECIMAL(14,2);
	DEFINE vMoraProviOrdi			DECIMAL(14,2);
	DEFINE vMoraProviCope			DECIMAL(14,2);
	DEFINE vMoraSdoOrdi				DECIMAL(14,2);
	DEFINE vMoraSdoOrdiPag			DECIMAL(14,2);
	DEFINE vMoraSdoCope				DECIMAL(14,2);
	DEFINE vMoraSdoCopePag			DECIMAL(14,2);
	DEFINE vIvaDebe					DECIMAL(14,2);
	DEFINE vIvaPagado				DECIMAL(14,2);
	DEFINE vMoraIntDebe				DECIMAL(14,2);
	DEFINE vIvaIntVigente			DECIMAL(14,2);
	DEFINE vIvaIntVencido			DECIMAL(14,2); --RQM 09 459
	DEFINE csg_iva_int_mes			MONEY(18,2);
	DEFINE csg_sdo_act_total_iva	MONEY(18,2);
	DEFINE csg_com_pend				MONEY(18,2);
	DEFINE csg_iva_com				MONEY(18,2);
	DEFINE csg_sdo_retenido			MONEY(18,2);
	DEFINE csg_tot_liquidacion		MONEY(18,2);
	DEFINE csg_int_devengado		MONEY(18,2);
	DEFINE csg_iva_int_devengado	MONEY(18,2);
	DEFINE csg_linea_disp			MONEY(18,2);
	DEFINE csg_pagos_vdos			MONEY(18,2);
	DEFINE csg_desc_status_cred		CHAR(60);
	DEFINE csg_id_bloqueo_cred		INTEGER;
	DEFINE csg_bloqueo_cta			CHAR(60);
	DEFINE csg_id_causa_bloq_cred	CHAR(3);
	DEFINE csg_causa_bloqueo_cta	CHAR(50);
	DEFINE csg_id_sit_esp_cte		CHAR(1);
	DEFINE csg_id_causa_esp_cte		INTEGER;
	DEFINE csg_sit_esp_cte			CHAR(75);
	DEFINE csg_id_sit_esp_cred		CHAR(1);
	DEFINE csg_id_causa_esp_cred	INTEGER;
	DEFINE csg_sit_esp_cred			CHAR(75);
	DEFINE csg_dMoraBase        DECIMAL(18,2);
	DEFINE csg_dMoraCopete      DECIMAL(18,2);
	DEFINE csg_dIvamoraBase     DECIMAL(18,2);
	DEFINE csg_dIvaMoraCopete   DECIMAL(18,2);
	DEFINE vMontoTransaccCapitalVdo DECIMAL(18,2);
	DEFINE vMontoTransaccCancelaLinea DECIMAL(18,2);
	DEFINE vaux1_cap_vdo_exig                DECIMAL(18,2);
	DEFINE vaux2_cap_vdo_no_exig             DECIMAL(18,2);
	DEFINE vaux3_sdo_cap_insol               DECIMAL(18,2);
	DEFINE estatus_qc						CHAR(2);
	DEFINE fecha_quita						DATE;
	DEFINE dFechaProceso					DATE;
  DEFINE vACT						      INTEGER;
  	DEFINE vCapitalMtoCuota		DECIMAL(14,2);
	DEFINE dFechaUltMov DATE;	
	DEFINE monto_qc				DECIMAL(18,2);
	DEFINE estatus_proceso_act CHAR(2);
	DEFINE dFechanegociacion  DATE;
	DEFINE dFechaliquidacion  DATE;
	DEFINE dFechastatus  DATE;
	DEFINE cAplicaBoniAnual				CHAR(1);
    DEFINE sCargosEspecialesBoni			SMALLINT;
    DEFINE sDiaCorte						SMALLINT;
    DEFINE dFechaProxAnualidad			DATE;
    DEFINE pFecha						DATE;
	DEFINE  cod_ret3     CHAR(5);
	

	
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "Principal.err";
      --TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      LET Mensaje = error_info;
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
      RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
	     g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
   END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      ROLLBACK WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

  --SET DEBUG FILE TO "/RESPALDOSNEW/ulises/RQI/principal.out";
  --TRACE ON;


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
   LET wBegin = "N";

   BEGIN WORK;

   LET CodRet = "000";


   SELECT descripcion
     INTO Mensaje
     FROM bdinteg:"informix".si_codret
    WHERE sistema = g_sistema
      AND codigo_retorno = CodRet;

   LET g_empresa    = p_empresa;
   LET g_NumCredito = p_NumCredito;
   LET g_TpPago     = 1; --p_TpPago;
   LET g_Monto      = p_Monto;
   LET g_Usuario    = p_Usuario;
   LET g_Sucursal   = p_Sucursal;
   LET g_Transacc   = p_Transacc;
   LET g_Seguro     = 0;
   LET vTotPAg      = 0;
   LET p_TpPago     = 1;
   LET vBloqueo     = 0;
   LET vlIndicador	= "";

   IF (p_Folio = ' ' OR p_Folio IS NULL) THEN
       LET g_Folio   = ConstruyeFolio();
   ELSE
       LET g_Folio       = p_Folio;
   END IF;

   LET g_Moratorio		= 0;
   LET g_Remanente		= g_Monto;
   LET CodRet			= "000";
   LET Mensaje			= '';
   LET g_IntVencCob		= 0;
   LET g_CapVencCob		= 0;
   LET g_IntVigCob		= 0;
   LET g_CapVigCob		= 0;
   LET g_Seguro         = 0;
   LET g_Comision		= 0;
   LET g_IntMoraCob		= 0;
   LET vSdoRetenido		= 0;
   LET vIva             = 0;
   LET vCapNoTras		= 0;
   LET vIvaPag          = 0;
   LET vMoraPag         = 0;
   LET vIntPag          = 0;
   LET vIvaIntPag       = 0;
   LET tras_int_vig     = 0;
   LET vFecVenc         = DATE(1);
   LET vintmes          = 0;
   LET pcod_fun         ="";
  -- CAS LET vDiaVenc   = 0;
   LET vcod_ret	= '00000';
   LET vcDisponCred     = '';

   LET vvcodigo_retorno    = '';
   LET vvmensaje_retorno   = '';
   LET dPago_minimo       = 0;
   LET dSaldo_vencido     = 0;

   LET dIntVdo          = 0;
   LET dIntMoratorio    = 0;
   LET dIvaIntVdo       = 0;
   LET dPagosVdos       = 0;
   LET dIvaIntMoratorio = 0;
   LET dIntMes_2        = 0;
   LET dIvaIntMes       = 0;
   LET dIntVig          = 0;
   LET dIvaIntVig       = 0;
   LET vMax_SdoFavor    = 0;
   LET dMontoOtorgado   = 0;
   LET plimcred_sdofavor = 0;
   LET porcentaje_sdofavor = -.20;
   LET cCodigo_concp    = '';
   LET cFolio_CredisolPF = '';
   LET cSucursalCsPF	 = '';
   LET sStatusPF		 = 0;
   LET dMonto_RetPF		 = 0;
   
   --Variables Condonaciones y Quitas
   LET vMontoCondonado   = 0;
   LET vMontoQuita     = 0;
   --LET vIndProceso     = '';
   LET vIndCQProducto  = '';
   LET vSaldoTotal	   = 0;
   LET scod_ret        = '00000';
   LET d_saldoInsoluto = 0;
   LET d_moratorio     = 0;
   LET d_ivaMoratorio  = 0; 
   LET d_interesVenc   = 0; 
   LET d_ivaIntVenc    = 0;
   LET d_totalLiquidacion = 0;
   LET v_MoraProvi  = 0; --RQM 09 459
   LET v_MoraIva  = 0; --RQM 09 459
   LET vIntVencido = 0; --RQM 09 459
   LET vIntMoratorio = 0; --RQM 09 459
   LET vDescuentoQuita = 0; --RQM 09 459
   LET vPorcQuita    = 0; --RQM 09 459
   LET vMesesVencidos	= 0; --RQM 09 459
   LET vMesesHistoria	= 0; --RQM 09 459
   LET vSdoCredito		= 0; --RQM 09 459
   LET vInteresDebe		= 0;
   LET vInteresPagado	= 0;
   LET vMoraProviOrdi	= 0;
   LET vMoraProviCope	= 0;
   LET vMoraSdoOrdi		= 0;
   LET vMoraSdoOrdiPag	= 0;
   LET vMoraSdoCope		= 0;
   LET vMoraSdoCopePag	= 0;
   LET vIvaDebe			= 0;
   LET vIvaPagado		= 0;
   LET vMoraIntDebe		= 0;
   LET vIvaIntVigente	= 0;
   LET vIvaIntVencido	= 0; --RQM 09 459	   
   LET mRemanente_cq  =0;
   LET vFechaVigencia  = date(1);
   LET vMontoMora   = 0;
   LET vMontoIntVenc = 0;
   --LET g_Fecha = mdy(08,20,2020); --para pruebas
   LET vSdoFavor = 0;
   LET vtarjeta = 0;
   LET cproduto  = 0;
   
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	LET csg_codigo_ret				= "000000";
	LET csg_mensaje_ret				= "";
	LET csg_num_credito				= "";
	LET csg_cod_tipcred				= "";
	LET cStatus						= "";
	LET csg_fec_origen				= DATE(1);
	LET csg_fec_prox_pago			= DATE(1);
	LET csg_pago_min				= 0.0;
	LET csg_fec_ult_pago			= DATE(1);
	LET csg_plazo					= 0;
	LET csg_pagos_realizados		= 0;
	LET csg_linea_otorgada			= 0.0;
	LET csg_tasa_interes			= 0.0;
	LET csg_tasa_moratorios			= 0.0;
	LET csg_monto_sbc				= 0.0;
	LET csg_cap_vig					= 0.0;
	LET csg_cap_trans				= 0.0;
	LET csg_cap_vdo_exig			= 0.0;
	LET csg_cap_vdo_no_exig			= 0.0;
	LET csg_sdo_act_total_cap		= 0.0;
	LET csg_int_vig					= 0.0;
	--LET csg_int_vdo					= 0.0;
	--LET csg_int_moratorios			= 0.0;
	LET csg_int_mes					= 0.0;
	LET csg_sdo_act_total_int		= 0.0;
	LET csg_iva_int_vig				= 0.0;
	--LET csg_iva_int_vdo				= 0.0;
	--LET csg_iva_int_moratorios		= 0.0;
	LET csg_iva_int_mes				= 0.0;
	LET csg_sdo_act_total_iva		= 0.0;
	LET csg_com_pend				= 0.0;
	LET csg_iva_com					= 0.0;
	LET csg_sdo_retenido			= 0.0;
	LET csg_tot_liquidacion			= 0.0;
	LET csg_int_devengado			= 0.0;
	LET csg_iva_int_devengado		= 0.0;
	LET csg_linea_disp				= 0.0;
	LET csg_pagos_vdos				= 0.0;
	LET csg_desc_status_cred		= "";
	LET csg_id_bloqueo_cred			= 0;
	LET csg_bloqueo_cta				= "";
	LET csg_id_causa_bloq_cred		= "";
	LET csg_causa_bloqueo_cta		= "";
	LET csg_id_sit_esp_cte			= "";
	LET csg_id_causa_esp_cte		= 0;
	LET csg_sit_esp_cte				= "";
	LET csg_id_sit_esp_cred			= "";
	LET csg_id_causa_esp_cred		= 0;
	LET csg_sit_esp_cred			= "";
	LET csg_dMoraBase               = "";
	LET csg_dMoraCopete             = "";
	LET csg_dIvamoraBase            = "";
	LET csg_dIvaMoraCopete          = "";   
--------------------------
   LET dPagoMinimo = 0;  
   LET dIntMoratorio = 0; 
   LET dIvaIntVdo = 0;  
   LET dPagosVdos = 0;  
   LET dIvaIntMoratorio = 0;  
   LET dIntMes = 0;  
   LET IvaIntMes = 0; 
   LET dIntVig = 0; 
   LET dIvaIntVig = 0; 
   LET vCancela = '';
   LET vMontoTotal = 0;
   LET vIntVencProporcion = 0;
   LET vMontoTransaccCapitalVdo = 0;
   LET vMontoTransaccCancelaLinea = 0;
   LET vaux1_cap_vdo_exig         = 0;
   LET vaux2_cap_vdo_no_exig      = 0;
   LET vaux3_sdo_cap_insol        = 0;
   LET CodRetqc                   = 0;
   LET vACT               = 0; 
   LET estatus_qc				  = '';
   LET fecha_quita				  = DATE(1);
   LET dFechaProceso				  = DATE(1);
   LET vCapitalMtoCuota			  = 0;		
   LET dFechaUltMov  			  = DATE(1); 
   LET vMontoCondona   			  = 0;
   LET monto_qc			          = 0;
   LET estatus_proceso_act        = '';
   LET dFechanegociacion          = DATE (1);
   LET dFechaliquidacion          = DATE (1);
   LET dFechastatus               = DATE (1);
   LET cAplicaBoniAnual		= '';
   LET sCargosEspecialesBoni = 0;
   LET sDiaCorte			= 0;
   LET dFechaProxAnualidad  = DATE(1);
   LET pFecha  = DATE(1);
   LET cod_ret3 = '00000';

   -- Valida disponibilidad del sistema de credito JOM INI



  
   SELECT NVL(ind_disponible, '0'),fecha_hoy
     INTO vcDisponCred, fecha_quita
     FROM bdicred:sd_fechas
    WHERE empresa = g_Empresa;
	
	IF (vcDisponCred <> '0') then
	-- Valida si puede realizar pagos ini
		 IF EXISTS (SELECT *
			FROM bdicred:sd_contproc
			WHERE empresa = p_empresa
			AND proceso = "CierreCred"
			AND fecha = (select fecha_hoy from bdicred:sd_fechas where empresa = p_empresa)) THEN
			LET vcDisponCred = '0';
		 ELSE
			LET vcDisponCred = '1';
		 END IF;
	
	-- Valida si puede realizar pagos fin
	END IF;
	
    IF (vcDisponCred = '0') THEN
       LET CodRet = "040";

       SELECT descripcion
       INTO Mensaje
       FROM bdinteg:si_codret
       WHERE sistema = g_sistema
       AND codigo_retorno = CodRet;

       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;
       RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
               g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;

    END IF;

	
   -- Valida disponibilidad del sistema de credito JOM FIN

  --------------------------------------------------------
  --	Varibale de Control de Fecha Proceso
  --------------------------------------------------------
   LET vFechaHoy	= " ";
   LET v_forma_pago = "" ;

   SELECT TRIM(valor) INTO ax_tranliq FROM "informix".sd_param
    WHERE cod_param = "70"
      AND empresa = g_Empresa;

	SELECT indicador_proceso,mto_quita,monto_condonado,fecha_negociacion,fecha_liquidacion,fecha_status --Se agregan montos quita y condonacion 
		INTO  vIndProceso,vMontoQuita,vMontoCondona,dFechanegociacion,dFechaliquidacion,dFechastatus
	FROM  bdicred:sd_bitacora_quitacondonacion
		WHERE num_credito = g_NumCredito
		AND estatus_proceso = 'PR';
		--AND fecha_negociacion >= fecha_quita;
		
		IF vIndProceso IS NULL OR vIndProceso = '' THEN
			LET vIndProceso = '';
	END IF;
	
	IF vMontoQuita IS NULL OR vMontoQuita = '' THEN
		LET vMontoQuita = 0;
	END IF;
	
	IF vMontoCondona IS NULL OR vMontoCondona = '' THEN
		LET vMontoCondona = 0;
	END IF;

	LET monto_qc = vMontoQuita + vMontoCondona;
	  
	SELECT status_cred
		INTO estatus_qc
	FROM bdicred:sd_maecred
		WHERE num_credito = g_NumCredito;

  SELECT nvl(act,0)
		INTO vACT
	FROM bdicred:sd_maesdos
		WHERE num_credito = g_NumCredito;
	
	IF estatus_qc IS NULL THEN LET estatus_qc = ''; END IF;

  	------------------------------------------  Se agrega validacion con ACT  vACT  
  --IF p_Transacc <> '8638' AND ((vIndProceso = 'Q' AND estatus_qc = 'BT') OR (vIndProceso = 'C' AND estatus_qc IN ('BA','BT'))) THEN
  IF p_Transacc <> '8638' AND ((vIndProceso = 'Q' AND estatus_qc IN ('BT','E3'))  OR (vIndProceso = 'C' AND (estatus_qc IN ('BA','BT') or vACT > 0))) AND dFechanegociacion >= fecha_quita THEN
	 
-----------------------------------------------------PRIMER UPDATE--------------------------------------------------------------------
	   
		--Se consultan saldos antes de aplicar el pago
		EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(g_Empresa,g_NumCredito) 
		INTO  csg_codigo_ret,csg_mensaje_ret,csg_num_credito,csg_cod_tipcred,csg_fec_origen,csg_fec_prox_pago,csg_pago_min,
				csg_fec_ult_pago,csg_plazo,csg_pagos_realizados,csg_linea_otorgada,csg_tasa_interes,csg_tasa_moratorios,
				csg_monto_sbc,csg_cap_vig,csg_cap_trans,csg_cap_vdo_exig,csg_cap_vdo_no_exig,csg_sdo_act_total_cap,csg_int_vig,
				csg_int_vdo,csg_int_moratorios,csg_int_mes,csg_sdo_act_total_int,csg_iva_int_vig,csg_iva_int_vdo,csg_iva_int_moratorios,
				csg_iva_int_mes,csg_sdo_act_total_iva,csg_com_pend,csg_iva_com,csg_sdo_retenido,csg_tot_liquidacion,csg_int_devengado,
				csg_iva_int_devengado,csg_linea_disp,csg_pagos_vdos,csg_desc_status_cred,csg_id_bloqueo_cred,csg_bloqueo_cta,
				csg_id_causa_bloq_cred,csg_causa_bloqueo_cta,csg_id_sit_esp_cte,csg_id_causa_esp_cte,csg_sit_esp_cte,csg_id_sit_esp_cred,
				csg_id_causa_esp_cred,csg_sit_esp_cred;
		--BEGIN WORK;				
		--Se actualizan saldos y estatus en la bitacora	
		UPDATE "informix".sd_bitacora_quitacondonacion 
		SET pago_realizado = p_Monto, int_vencido = NVL(csg_int_vdo,0), iva_int_vencido = NVL(csg_iva_int_vdo,0), cap_vigente = csg_cap_vig, iva_int_vigente = NVL(csg_iva_int_vig,0),
		cap_vigente_cq = NVL(csg_cap_vig,0), iva_int_vigente_cq = csg_iva_int_vig, 
		int_moratorio = csg_int_moratorios, iva_int_mora = csg_iva_int_moratorios,int_vigente_cq =  csg_int_vig,
		int_vencido_cq = csg_int_vdo,iva_int_vencido_cq = csg_iva_int_vdo,
		int_moratorio_cq = csg_int_moratorios, iva_int_mora_cq = csg_iva_int_moratorios,
		cap_vencido = csg_cap_vdo_exig, int_vigente = csg_int_vig, cap_vencido_cq = csg_cap_vdo_exig,
        ---------------------------------------------------------------------------------------------	
		meses_vencidos=vMesesVencidos WHERE num_credito = g_NumCredito AND estatus_proceso='PR';
	   	---------------------------------------------------------------------------------------------			
	    COMMIT;
		BEGIN;
		
		CALL bdicred:quita_condona_tdc (g_empresa,g_NumCredito,g_TpPago,g_Usuario,g_Sucursal,g_Folio,'8638',p_Monto)
			returning CodRet;
			
		IF CodRet = '001' THEN
			LET vIndProceso = '';
			LET CodRet = "000";
		END IF;
			
		LET g_empresa    = p_empresa;
		LET g_NumCredito = p_NumCredito;
		LET g_Transacc	 = p_Transacc;
		LET g_Monto      = p_Monto;
		LET g_Remanente	 = g_Monto;

    --Si la fecha de pago es mayor a la fecha de negociacion se actualiza el estatus a cancelado
    ELIF dFechanegociacion < fecha_quita 
		AND ((vIndProceso = 'Q' AND estatus_qc IN ('BT','E3'))  OR (vIndProceso = 'C' AND (estatus_qc IN ('BA','BT')))) THEN 
		
		 UPDATE "informix".sd_bitacora_quitacondonacion 
			SET estatus_proceso = 'CN',fecha_status = fecha_quita
          WHERE num_credito = p_NumCredito and estatus_proceso='PR';
		  
		IF p_Transacc <> '8638' THEN
			LET vIndProceso = '';
		END IF;
	
		COMMIT;
		BEGIN;
	ELSE
		IF p_Transacc <> '8638' THEN
			LET vIndProceso = '';
		END IF;
	
	END IF;
	  
	  

-- Obtiene los valores generales para el proceso

   SELECT a.num_producto, a.numcte, a.divisa, b.sdo_intereses,
       b.sdo_int_anticip, b.sdo_int_ant_dev, b.int_tra_no_exig , b.sdo_trab4,
       (b.sdo_contab_mora + b.sdo_moratorio), b.sdo_exig_int,
       b.monto_vencido + b.mto_venc_trasp,
       b.monto_vencido, b.mto_venc_trasp, b.sdo_no_exig, b.sdo_capital,
       b.monto_financiado,b.monto_reservado,b.mto_venc_int, b.mto_venc_tra_int,
       b.sdo_acum_mes_int, b.provision_normal, b.sdo_cap_insoluto,
       b.mto_capitalizado, c.fecha_hoy, d.maneja_linea, "2", status_cred,
       d.cod_tipcred, b.sdo_retenido, a.fecha_vencim, e.iva, cap_tras_no_venci, id_unidad_prod, b.monto_otorgado
	   ,b.act , round((today - a.fecha_apertura)/30.4), b.fecha_ult_mov
	   ,NVL(d.aplica_boni_anual,'0'), NVL(d.cargos_especiales_boni,0), d.dia_cuota
   INTO
       g_NumProducto, g_NumCte, g_Divisa, g_SdoIntereses,
       g_SdoIntAnticip, g_SdoIntAntDev, g_IntTraNoExig, g_SdoTrab4,
       g_SdoMoratorio, g_IntVenc, g_CapVenc,
       g_MontoVencido, g_MtoVencTrasp, g_IntVig, g_CapVig,
       g_MontoFinanciado, g_MontoReservado, g_SdoVencInt, g_SdoVencTraInt,
       g_SdoAcumMesInt, g_ProvisionNorm, g_SdoCapInsoluto, g_MtoCapitalizado,
       g_Fecha, g_ManejaLinea, g_PagoAdic, g_StCred, vCodTipCred, vSdoRetenido,
       g_FechaProxPago, g_IvaCte, vCapNoTras, vBloqueo, dMontoOtorgado
	   ,g_ACT , vMesesHistoria, dFechaUltMov,
	   cAplicaBoniAnual,sCargosEspecialesBoni, sDiaCorte
   
   FROM
       "informix".sd_maecred a, "informix".sd_maesdos b, "informix".sd_fechas c, "informix".sd_definicion d,
       bdinteg:"informix".si_sucursales e
   WHERE a.empresa          = g_Empresa
     AND a.num_credito      = g_NumCredito
     AND a.bandera_ministra = 'M'
     AND b.empresa          = a.empresa
     AND b.num_credito      = a.num_credito
     AND c.empresa          = a.empresa
     AND d.empresa          = a.empresa
     AND d.num_producto     = a.num_producto
     AND e.empresa	        = a.empresa
     AND a.status_cred      not in ('CV','FC','FF','FI')
     and (a.id_unidad_prod is null or a.id_unidad_prod <> 1)
     AND e.sucursal         = a.sucursal;

   LET nrows = dbinfo("sqlca.sqlerrd2");
   IF (nrows = 0) THEN
       LET CodRet = "008";
       SELECT descripcion
       INTO Mensaje
       FROM bdinteg:"informix".si_codret
       WHERE sistema = g_sistema
       AND codigo_retorno = CodRet;
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
           --COMMIT WORK;
       END IF;
       RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
               g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;

   END IF;

    --EVALUACION OBJETIVA. Antes de realizar el pago calcular el pago minimo y el saldo vencido para guardarlo en la tabla: cb_evaluacion_objetiva bdicobranza. MACF
      CALL "informix".sp_obtener_pagomin(g_Empresa,g_NumCredito) RETURNING vvcodigo_retorno, vvmensaje_retorno, dPago_minimo, dIntVdo, dIntMoratorio,
                                                                        dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes_2, dIvaIntMes, dIntVig, dIvaIntVig;
      LET dSaldo_vencido = g_CapVenc + dIntMoratorio + dIvaIntMoratorio + dIntVdo + dIvaIntVdo;
    --EVALUACION OBJETIVA.
-- ini -- Se agrega bloqueo de cuentas
-- Bloqueo de cuentas operaciones
-- id_unidad_prod = 2 = bloqueo pago
-- id_unidad_prod = 3 = bloqueo disposicion
-- id_unidad_prod = 4 = bloqueo pago y disposicion
   IF vBloqueo = 2 THEN		-- Si esta bloqueado por PFSI se cancele.  
		SELECT folio_movto, sucursal, status, monto_int_iva INTO cFolio_CredisolPF, cSucursalCsPF, sStatusPF, dMonto_RetPF
		  FROM bdicred:sd_promocion_credito WHERE num_credito = g_NumCredito AND status = 0 AND num_promo = 9;
		
		IF NVL(sStatusPF, -1) = 0 THEN	
			-- Libera el saldo retenido del monto int e iva diferido			
			UPDATE bdicred:sd_promocion_credito SET status = 7 WHERE num_credito = g_NumCredito AND status = 0 AND num_promo = 9 AND folio_movto = cFolio_CredisolPF;		
			UPDATE bdicred:"informix".sd_maeretenido SET estatus = "S" WHERE empresa = '001' AND num_credito = g_NumCredito AND folio_suc = cFolio_CredisolPF AND estatus = "R";
			UPDATE bdicred:"informix".sd_maesdos SET sdo_retenido = sdo_retenido - dMonto_RetPF WHERE num_credito = g_NumCredito;
			UPDATE bdicred:"informix".sd_movdia SET reversado = "S" WHERE empresa = '001' AND num_credito = g_NumCredito AND folio_suc = cFolio_CredisolPF AND codigo_fun = '002' AND codigo_ref = 45; 

			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '5', respuesta_cte_sms = 'N', fecha_resp_cte_sms = CURRENT, fecha_cancela = today, compra_inmd = '1'

			 WHERE num_credito = g_NumCredito AND num_promo = 9 AND tipo_contrato = '3' AND tipo_sms = '7';
			
			UPDATE bdicred:sd_maecred SET id_unidad_prod = NULL WHERE num_credito = g_NumCredito;		
			LET vBloqueo = NULL;		
		END IF;
   END IF;

-----SE TRAE EL DIA DE CORTE

    SELECT dia_corte,fecha_proceso INTO vdia_corte,dFechaProceso
    FROM  bdicred:"informix".sd_maecredanexo
    WHERE empresa=p_Empresa
      AND num_credito=g_NumCredito;
	  
   
   IF (vBloqueo = 2 or vBloqueo = 4 or g_Fecha > dFechaProceso) THEN
       LET CodRet = "301";
       SELECT descripcion
       INTO Mensaje
       FROM bdinteg:"informix".si_codret
       WHERE sistema = g_sistema
       AND codigo_retorno = CodRet;
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
           --COMMIT WORK;
       END IF;
       RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
               g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
   END IF;
	
	LET g_Fecha = dFechaProceso;
	
-- fin -- Se agrega bloqueo de cuentas

   IF g_StCred <> "CC" THEN
       LET g_CodigoFun  = '033';
   ELSE
       LET g_CodigoFun  = '333';
   END IF

	IF p_Transacc IN ('9854', '4356') THEN
		LET g_CodigoFun  = '059';
	END IF;
   IF p_Transacc = "6814" THEN

        SELECT fecha_hoy 	- 15 UNITS DAY	INTO vFechaHoy
        FROM bdinteg:"informix".si_fechas WHERE empresa = p_Empresa;

          /*SELECT forma_pago INTO v_forma_pago   --  Se comenta por desuso de tablas por reingenieria de la conciliacion
          FROM bditarjeta:td_conpospnc
      WHERE folio_mov = p_Folio
        AND fecha >= vFechaHoy;*/
      -- Se integra para usar nuevas tablas de la reingenieria de la conciliacion
      -- 07102012  Sistemas Perifericos
      SELECT TRIM(montosurcharge325) INTO v_forma_pago
          FROM bditarjeta:"informix".td_movimientos_conciliacion
      WHERE folio_mov = p_Folio
        AND FechaCarga::date >= vFechaHoy;

        IF v_forma_pago = "1" THEN
              LET g_CodigoFun = '335';
        ELSE
              LET g_CodigoFun = '334';
        END IF

   ELSE
		SET ISOLATION TO DIRTY READ;
        SELECT cod_fun,max_sdo_favor,codigo,limcred_sdo_favor INTO pcod_fun,vMax_SdoFavor,cCodigo_concp,plimcred_sdofavor FROM bdicred:"informix".sd_conceptospagomanual where transacc = p_Transacc;
        IF pcod_fun <> '' OR pcod_fun is not NULL THEN
            LET g_CodigoFun = pcod_fun;
        END IF
/*
   ELIF p_Transacc = "7100" THEN
		LET g_CodigoFun = '337';         -- BC.HEMI.020908 identificacion canal internet
   ELIF p_Transacc = "6246" THEN
		LET g_CodigoFun = '336';         -- Jom Pago SBC
   ELIF p_Transacc = "6813" THEN
		LET g_CodigoFun = '904';         -- Devolucion "INTERCARD"
   ELIF p_Transacc = "6883" THEN
		LET g_CodigoFun = '905';         -- Devolucion "INTERCARD COPPEL"
   ELIF p_Transacc = "6990" THEN
        LET g_CodigoFun = '050';         -- LHM Aplicacion de Pago Manual
   ELIF p_Transacc in ('6992','6994','6996','6998') THEN
        LET g_CodigoFun = '052';
*/

        --INI Confirma monto de saldo maximo. Si rebasa el limite, se cancela el pago.
        IF vMax_SdoFavor IS NULL THEN
            SELECT first 1 nvl(max_sdo_favor,0), codigo, nvl(limcred_sdo_favor,0) INTO vMax_SdoFavor, cCodigo_concp,plimcred_sdofavor FROM bdicred:"informix".sd_conceptospagomanual where cod_fun = g_CodigoFun;
        END IF;
		
		IF plimcred_sdofavor <> 0 THEN
			IF dMontoOtorgado > plimcred_sdofavor THEN  --- pc_Max_SdoFavor si monto otorgado es mayor a 25mil se obtien el 20% que sera su maximo saldo a favor
				LET vMax_SdoFavor = dMontoOtorgado * porcentaje_sdofavor;
			END IF;
		END IF;

        -- Si el saldo del credito es mayor a 15000 de Sdo a Favor, se rechaza el pago.
        -- (dPago_minimo - g_MontoFinanciado + g_SdoCapInsoluto) = Total liquidacion
		IF (dPago_minimo <= 0) THEN
			IF (g_SdoCapInsoluto - p_monto) < vMax_SdoFavor THEN
			       --LET CodRet = '296';  -- Codigo de error en la si_codret
				LET CodRet = '1144'; -- Codigo de error en la ierrcom, para mostrar en ofi
				ROLLBACK WORK;

                BEGIN WORK;
                    INSERT INTO bdicred:"informix".sd_pagos_rech_sdo_favor VALUES(p_Empresa,g_NumCredito,p_Monto,g_Fecha,
                        g_SdoCapInsoluto,dMontoOtorgado,g_Folio,g_Transacc,g_CodigoFun,cCodigo_concp,p_Sucursal,p_Usuario,CURRENT);
				COMMIT WORK;

				IF (wBegin = "S") THEN
				   BEGIN WORK;
				END IF;
				RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
			END IF;
		ELSE
			IF (dPago_minimo - g_MontoFinanciado + g_SdoCapInsoluto - p_monto) < vMax_SdoFavor THEN
						       --LET CodRet = '296';  -- Codigo de error en la si_codret
				LET CodRet = '1144'; -- Codigo de error en la ierrcom, para mostrar en ofi
				ROLLBACK WORK;

                BEGIN WORK;
                    INSERT INTO bdicred:"informix".sd_pagos_rech_sdo_favor VALUES(p_Empresa,g_NumCredito,p_Monto,g_Fecha,(dPago_minimo - g_MontoFinanciado + g_SdoCapInsoluto),
                        dMontoOtorgado,g_Folio,g_Transacc,g_CodigoFun,cCodigo_concp,p_Sucursal,p_Usuario,CURRENT);
                COMMIT WORK;

				IF (wBegin = "S") THEN
				   BEGIN WORK;
				END IF;
				RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
			END IF;
		END IF;
   END IF


--Inicia Respaldo de Tablas de Reversion

   CALL RespaldaCredito() RETURNING CodRet;
   IF (CodRet <> "000") THEN
       SELECT descripcion
         INTO Mensaje
         FROM bdinteg:"informix".si_codret
        WHERE empresa        = g_Empresa
          AND codigo_retorno = p_CodRet;

       ROLLBACK WORK;
       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;

       RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
               g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
   END IF;

   -- PROCESOS PARA TARJETA DE CREDITO
   IF vCodTipCred = "03" THEN
	LET g_ManejaLinea ="S";
        SELECT SUM(iva_debe - iva_pagado) INTO vIva
        FROM "informix".sd_amortiza_credito
        WHERE empresa = g_Empresa
        AND num_credito = g_NumCredito;

        IF vIva IS NULL THEN
                LET vIva = 0;
        END IF

        --MODIFICACION PARA QUE NO COBRE INTERESES E IVA, SI AUN NO ESTA VENCIDO
        --IF g_StCred = "AA" AND g_FechaProxPago > g_fecha THEN
        IF ( ((g_StCred = "AA")  or (g_ACT = 0 and g_StCred = 'E1' )) AND g_FechaProxPago > g_fecha) THEN
            LET g_IntVig = 0;
            LET g_Iva    = 0;
        END IF;

 --       IF g_SdoCapInsoluto <= p_monto AND SUBSTR(g_StCred,1,1) = "B" THEN
 --           UPDATE sd_maesdos
 --              SET sdo_intereses = 0
 --            WHERE num_credito = g_NumCredito
 --              AND empresa = g_Empresa;
 --       END IF

    END IF

-------------------------------------------------
-- Ejecuta el pago de acurdo al parametro de
-- tp_pago en donde :
--    1  Aplica Cascada Normal
--    2  Aplica por Cuota
--    3  Aplica Solo Capital
--    SI el producto maneja linea el tipo de pago siempre sera 1 y se insertara
--    una cuota ficticia para que el proceso tenga un flujo natural
-------------------------------------------------



    IF g_TpPago = "1" OR g_TpPago = "2" THEN
      --------------------------------------------------------------------
      --  Realiza el Cobro de Comisiones, estas siempre seran por Rubro --
      --------------------------------------------------------------------
       FOREACH
        SELECT fecha_cuota INTO v_fcuota
          FROM "informix".sd_amortiza_credito
         WHERE empresa = g_Empresa
           AND num_credito = g_NumCredito
           AND capital_status  IN ("7", "2","6") --Se agrega nuevo estatus para IFRS --AEH

        ORDER BY fecha_cuota asc
	      ------------------------------------------------
	      --  Realiza el Cobro de Seguros               --
	      ------------------------------------------------
            IF g_Remanente > 0 AND (g_Iva > 0 OR g_SdoMoratorio > 0) THEN
					CALL calporcentaje(v_fcuota,1,0) RETURNING CodRet, vIvaPag,vMoraPag,vIntPag,vIvaIntPag;
               IF vIvaPag > 0 THEN
                  LET g_Remanente = vIvaPag;
               END IF;

			   IF g_Transacc IN ('7795', '7796') THEN

			      IF g_Transacc = '7795' THEN

						   LET g_CodigoFun = '063';  --POR CONDONACION

			       ELIF g_Transacc = '7796' THEN

					       LET g_CodigoFun = '064';  --POR CONDONACION POR FALLECIMIENTO

			       END IF;

		        END IF;

					CALL CobraIvaInt(v_fcuota) RETURNING CodRet;
					IF CodRet <> "000" THEN
						ROLLBACK WORK;
						IF wBegin = "S" THEN
						  BEGIN WORK;
						END IF;
						SELECT descripcion INTO Mensaje
						FROM bdinteg:"informix".si_codret
						WHERE sistema = g_sistema
						 AND codigo_retorno = CodRet;
						RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
							 g_CapVencCob, g_IntVigCob, g_CapVigCob,
							 g_Impuesto, g_Comision, g_Seguro;
					END IF;
            END IF

		------------------------------------------------
	    -- Realiza el cobro de Intereses Moratorios   --
	    ------------------------------------------------
              --  CALL calporcentaje(v_fcuota,1,0) RETURNING CodRet, vIvaPag,vMoraPag,vIntPag,vIvaIntPag;
               
		  IF p_Monto='0.01' AND g_Remanente=0 THEN 
            Let g_Remanente = 0;
      ELSE
		    IF vMoraPag > 0   THEN
				  Let g_Remanente = vMoraPag;
			  END IF
      END IF;

          IF (g_SdoMoratorio > 0 AND g_Remanente > 0) THEN
				
					  CALL CobraMoratorios(v_fcuota) RETURNING CodRet;
				
            IF(CodRet <> "000") THEN
              ROLLBACK WORK;
              IF (wBegin = "S") THEN
                BEGIN WORK;
              END IF;
              SELECT descripcion INTO Mensaje
              FROM bdinteg:"informix".si_codret
              WHERE sistema = g_sistema
              AND codigo_retorno = CodRet;
                RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
              g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
              g_Comision, g_Seguro;
            END IF;
			    END IF;
        
          ------------------------------------------------
          -- Realiza el cobro de Intereses Vencidos     --
          -- Cuotas 7 y 2                               --
          ------------------------------------------------
        IF ((g_IntVenc + g_IntTraNoExig) > 0 AND g_Remanente > 0) THEN 
			    	CALL calporcentaje(v_fcuota,0,2) RETURNING CodRet, vIvaPag,vMoraPag,vIntPag,vIvaIntPag;			   
			   
			    	IF vIntPag > 0 Or vIvaIntPag  > 0 THEN
			    	   Let g_Remanente = vIntPag + vIvaIntPag;
			    	END IF;
			  				
					CALL CobraIntVencido(v_fcuota,vIntPag,vIvaIntPag) RETURNING CodRet;
					IF(CodRet <> "000") THEN
						ROLLBACK WORK;
						IF (wBegin = "S") THEN
								BEGIN WORK;
						END IF;
						SELECT descripcion INTO Mensaje
						FROM bdinteg:"informix".si_codret
						WHERE sistema = g_sistema
						AND codigo_retorno = CodRet;

						RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
					   g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
					   g_Comision, g_Seguro;
					END IF;
			  END IF;
			
	      ------------------------------------------------
	      -- Realiza el cobro de Capital Vencidos       --
	      -- Cuotas 7 y 2                               --
	      ------------------------------------------------
		  --LET g_CapVenc = g_CapVenc; --PRUEBA
		  --LET g_Remanente = g_Remanente;  --PRUEBA
            IF (g_CapVenc > 0 AND g_Remanente > 0) THEN
                LET  g_PagoCapVencido = 0;
                CALL CobraCapVencido(v_fcuota) RETURNING CodRet;
                IF(CodRet <> "000") THEN
                    ROLLBACK WORK;
                    IF (wBegin = "S") THEN
                        BEGIN WORK;
                    END IF;
                    SELECT descripcion INTO Mensaje
                      FROM bdinteg:"informix".si_codret
                     WHERE sistema = g_sistema
                       AND codigo_retorno = CodRet;
                    RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
                            g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
                            g_Comision, g_Seguro;
                END IF;
            END IF;

            IF g_Remanente = 0 THEN
                EXIT FOREACH;
            END IF
        END FOREACH

	-- **********************************************
	-- * Traspasa Cap Vencido No Exigible a Vigente 
	-- **********************************************
  IF (g_MtoVencTrasp = 0 AND g_StCred = "BT") THEN
		IF (g_Transacc = "9854") THEN --PAGO ATM CGO CUENTA
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,52,
							'059', g_Fecha, vCapNoTras, g_Folio,
							g_Sucursal, g_Divisa, g_Transacc)
				RETURNING CodRet, Mensaje;
		ELSE
            CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,902,
                        g_CodigoFun, g_Fecha, vCapNoTras, g_Folio,
                        g_Sucursal, g_Divisa, g_Transacc)
			RETURNING CodRet, Mensaje;
		END IF;
            IF (CodRet <> "00000") THEN
                LET  CodRet = CodRet;
            ELSE
                LET CodRet = "000";
            END IF;
	    UPDATE "informix".sd_maesdos
	       SET sdo_capital = vCapNoTras,
		   cap_tras_no_venci = 0
             WHERE empresa = g_Empresa
               AND num_credito = g_NumCredito;

	    LET g_CapVig = g_CapVig + vCapNoTras;
	    LET vCapNoTras = 0;


		-- **********************************************
		-- * Traspasa Etapa 3 a Etapa 1 *
		-- **********************************************
	ELIF (g_MontoVencido = 0 AND g_StCred = "E3") THEN
		IF (g_Transacc = "9854") THEN--Transaccion para nuevo pago por ATMs --52
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,51,
							'059', g_Fecha, vCapNoTras, g_Folio,
							g_Sucursal, g_Divisa, g_Transacc)
				RETURNING CodRet, Mensaje;
		ELIF (g_Transacc = "4356") THEN--Transaccion para nuevo pago por ATMs --52
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,140,
							'059', g_Fecha, vCapNoTras, g_Folio,
							g_Sucursal, g_Divisa, g_Transacc)
				RETURNING CodRet, Mensaje;
		ELSE
          CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,913,
                        g_CodigoFun, g_Fecha, g_CapVig, g_Folio,
                        g_Sucursal, g_Divisa, g_Transacc)
			RETURNING CodRet, Mensaje;
		END IF;
            IF (CodRet <> "00000") THEN
                LET  CodRet = CodRet;
            ELSE
                LET CodRet = "000";
            END IF;

	    LET g_CapVig = g_CapVig + vCapNoTras;
	    LET vCapNoTras = 0;
  
  -- **********************************************
	-- * Traspasa Etapa 2 a Etapa 1 *
	-- **********************************************
  ELIF (g_MontoVencido = 0 AND g_StCred = "E2") THEN
		IF (g_Transacc = "9854") THEN--Transaccion para nuevo pago por ATMs --48
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,47,
							'059', g_Fecha, vCapNoTras, g_Folio,
							g_Sucursal, g_Divisa, g_Transacc)
				RETURNING CodRet, Mensaje;
		ELIF (g_Transacc = "4356") THEN--Transaccion para nuevo pago por ATMs --48
		        CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,141,
							'059', g_Fecha, vCapNoTras, g_Folio,
							g_Sucursal, g_Divisa, g_Transacc)
				RETURNING CodRet, Mensaje;
		ELSE
          CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,912,
                        g_CodigoFun, g_Fecha, g_CapVig, g_Folio,
                        g_Sucursal, g_Divisa, g_Transacc)
			RETURNING CodRet, Mensaje;
		END IF;
            IF (CodRet <> "00000") THEN
                LET  CodRet = CodRet;
            ELSE
                LET CodRet = "000";
            END IF;

	    LET g_CapVig = g_CapVig + vCapNoTras;
	    LET vCapNoTras = 0;
	END IF

       LET vfecha_ini=date(mdy(month(g_fecha),vdia_corte,year(g_fecha))-1 units month);

       IF DAY(g_fecha)>vdia_corte THEN
          LET vfecha_ini=mdy(month(g_fecha),vdia_corte,year(g_fecha));
       END IF;

	        SELECT fecha_cuota INTO v_fcuota
            FROM "informix".sd_amortiza_credito --sd_paginter
            WHERE empresa = g_Empresa
            AND num_credito = g_NumCredito
            AND fecha_cuota=vfecha_ini;

        IF v_fcuota IS NULL THEN
	        SELECT fecha_cuota INTO v_fcuota
            FROM "informix".sd_amortiza_credito --sd_paginter
            WHERE empresa = g_Empresa
            AND num_credito = g_NumCredito
            AND fecha_cuota=date(vfecha_ini+ 1 units month);
        END IF;

        IF v_fcuota IS NOT NULL THEN
	      ------------------------------------------------
	      --  Realiza el Cobro de Seguros               --
	      ------------------------------------------------
            IF g_Remanente > 0 THEN
		 --IF p_Transacc <> ax_tranliq THEN
                CALL CobraComisiones("2", v_fcuota) RETURNING CodRet;
                IF(CodRet <> "000") THEN
                    ROLLBACK WORK;
                    IF (wBegin = "S") THEN
                        BEGIN WORK;
                    END IF;
                    SELECT descripcion INTO Mensaje
                      FROM bdinteg:"informix".si_codret
                     WHERE sistema = g_sistema
                       AND codigo_retorno = CodRet;
                    RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
                            g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
                            g_Comision, g_Seguro;
                END IF;
		--END IF
            END IF

	      ------------------------------------------------
	      -- Realiza el cobro de Interes Vigente        --
	      -- Cuotas 1                                   --
	      ------------------------------------------------
            IF (g_IntVig > 0 AND g_Remanente > 0 AND g_ManejaLinea <>"S") THEN
              IF vIntPag = 0 THEN
                   CALL CobraIntVigente(v_fcuota) RETURNING CodRet;
                IF(CodRet <> "000") THEN
                        ROLLBACK WORK;
                  IF (wBegin = "S") THEN
                            BEGIN WORK;
                  END IF;
                  SELECT descripcion INTO Mensaje
                  FROM bdinteg:"informix".si_codret
                  WHERE sistema = g_sistema
                  AND codigo_retorno = CodRet;
                        RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
                              g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
                              g_Comision, g_Seguro;
                END IF;
              END IF;
	          END IF;
	      ------------------------------------------------
	      -- Realiza el cobro de Capital Vigente        --
	      -- Cuotas 1                                   --
	      ------------------------------------------------
            IF (g_CapVig > 0 AND g_Remanente > 0) THEN
                CALL CobraCapVigente(v_fcuota) RETURNING CodRet;
                IF(CodRet <> "000") THEN
                    ROLLBACK WORK;
                    IF (wBegin = "S") THEN
                        BEGIN WORK;
                    END IF;
                  SELECT descripcion INTO Mensaje
                    FROM bdinteg:"informix".si_codret
                  WHERE sistema = g_sistema
                    AND codigo_retorno = CodRet;
                        RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
                                g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
                                g_Comision, g_Seguro;
                END IF;
            END IF;

--            IF g_Remanente = 0 THEN
--                EXIT FOREACH;
--            END IF
--	    IF g_Remanente > 0 AND g_ManejaLinea = "S" THEN
--		EXIT FOREACH;
--	    END IF		
        END IF
	END IF

    -- ------------------------------------------------------
    -- -- PAGO SOLO DE CAPITAL (CACSI)
    -- ------------------------------------------------------
    IF g_TpPago = "3" THEN
	      ------------------------------------------------
	      -- Realiza el cobro de Pago Anticipado        --
	      -- Cuotas 1 de Interes y Capital              --
	      ------------------------------------------------

      -- Determina si la cuota Vigente ya esta pagada
      --SELECT status_cuota INTO ax_status FROM sd_pagocapit
        SELECT capital_status into ax_status FROM "informix".sd_amortiza_credito
         WHERE num_credito = g_NumCredito
	       AND empresa     = g_Empresa
	       AND fecha_cuota = (SELECT MIN(fecha_cuota)
			                    FROM "informix".sd_amortiza_credito
                               WHERE num_credito = g_NumCredito
			                     AND empresa     = g_Empresa
			                     AND fecha_cuota >= g_Fecha);

        IF (g_SdoMoratorio = 0 AND
            g_IntVenc = 0 AND
            g_CapVenc= 0  AND
            ax_status = 5 AND
            g_CapVig >= p_Monto) THEN
            IF (g_Remanente > 0) THEN
                CALL CobraAnticipado() RETURNING CodRet;
                IF(CodRet <> "000") THEN
                    ROLLBACK WORK;
                    IF (wBegin = "S") THEN
                        BEGIN WORK;
                    END IF;

                    SELECT descripcion INTO Mensaje
                      FROM bdinteg:"informix".si_codret
                     WHERE sistema = g_sistema
                       AND codigo_retorno = CodRet;

                    RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
                            g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
                            g_Comision, g_Seguro;

                END IF;
                CALL RenivelaPlanPagos()  RETURNING CodRet;
                IF(CodRet <> "000") THEN
                    ROLLBACK WORK;
                    IF (wBegin = "S") THEN
                        BEGIN WORK;
                    END IF;
	            SELECT descripcion
	              INTO Mensaje
	              FROM bdinteg:"informix".si_codret
	             WHERE sistema = g_sistema
	               AND codigo_retorno = CodRet;

                    RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
                           g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
                           g_Comision, g_Seguro;
                END IF;
            END IF;
        ELSE
            ROLLBACK WORK;
            IF (wBegin = "S") THEN
                BEGIN WORK;
            END IF;

            LET Codret = "099";

            SELECT descripcion
              INTO Mensaje
              FROM bdinteg:"informix".si_codret
             WHERE sistema = g_sistema
               AND codigo_retorno = CodRet;

            RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
                    g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
                    g_Comision, g_Seguro;

        END IF;
    END IF;
    SELECT sdo_cap_insoluto, (monto_vencido + mto_venc_trasp)
      INTO vCapital, v_capvenc
      FROM "informix".sd_maesdos
     WHERE empresa = g_empresa
       AND num_credito = g_NumCredito;

    IF v_capvenc <= 0 AND g_Remanente >= 0 AND (g_StCred='BT' or g_StCred='E3' OR g_StCred='E2') THEN
	
		  -- ini cas traspase solo la mensualidad del mes
                SELECT (interes_debe-interes_pagado)
                  INTO vintmes
                  FROM "informix".sd_amortiza_credito
                 WHERE empresa=g_empresa
                   AND num_credito=g_NumCredito
                   AND fecha_cuota=(SELECT date(prox_fecha_pago-1 units month)+4
                                    FROM "informix".sd_maecredanexo
                                    WHERE empresa=g_empresa
                                    AND num_credito=g_NumCredito);

                 IF vintmes is null or vintmes<0 THEN let vintmes=0; END IF;

                 UPDATE "informix".sd_maesdos
                    SET sdo_no_exig=vintmes,
                        int_tra_no_exig=(case when (int_tra_no_exig-vintmes)< 0 THEN 0 else int_tra_no_exig-vintmes end)
                  WHERE empresa = g_empresa
                    AND num_credito = g_NumCredito;

          IF g_StCred='BT' THEN
            CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,903,
                        g_CodigoFun, g_Fecha, vintmes, g_Folio,
                        g_Sucursal, g_Divisa, g_Transacc)
	          RETURNING CodRet, Mensaje;
          ELIF g_StCred='E2' THEN
            CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,903,
                        g_CodigoFun, g_Fecha, vintmes, g_Folio,
                        g_Sucursal, g_Divisa, g_Transacc)
	          RETURNING CodRet, Mensaje;
          ELIF g_StCred='E3' THEN
            CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,903,
                        g_CodigoFun, g_Fecha, vintmes, g_Folio,
                        g_Sucursal, g_Divisa, g_Transacc)
	          RETURNING CodRet, Mensaje;
          END IF;

            IF (CodRet <> "00000") THEN
                LET  CodRet = CodRet;
            ELSE
                LET CodRet = "000";
            END IF;

    END IF;

	
    IF (g_ManejaLinea <> 'S') THEN
        IF (vCapital = 0) THEN
            UPDATE "informix".sd_maecred SET status_cred = 'FF'
             WHERE empresa = g_empresa
               AND num_credito = g_NumCredito;
        ELSE
            IF g_StCred <> "CC" THEN
              IF (v_capvenc = 0 AND (g_StCred = "BT" OR g_StCred = "BA")) THEN
                  UPDATE "informix".sd_maecred SET status_cred = 'AA'
                  WHERE empresa = g_empresa
                    AND num_credito = g_NumCredito;
		      ELIF (v_capvenc = 0 AND g_StCred IN ('E2','E3','E1')) THEN --CAMBIOS POR IFRS --AEH
				  UPDATE "informix".sd_maecred SET status_cred = 'E1'
				  WHERE empresa = g_empresa
					AND num_credito = g_NumCredito;

				  UPDATE "informix".sd_maesdos
					SET act=0
				  WHERE num_credito = g_NumCredito
					AND empresa = g_Empresa;
              END IF
            END IF
        END IF;
    ELSE
 
		IF (v_capvenc <= 0 AND g_StCred <> "AA" ) THEN --CAMBIOS POR IFRS --AEH
            
			  IF (g_StCred='BT' OR g_StCred='BA') THEN
				UPDATE "informix".sd_maecred SET status_cred = 'AA'
				 WHERE empresa = g_Empresa
				   AND num_credito = g_NumCredito;
				   
			UPDATE "informix".sd_maesdos
			   SET dias_acum_mora = 0, act=null
			 WHERE num_credito = g_NumCredito
			   AND empresa = g_Empresa;				   
				   
			  ELIF (g_StCred IN ('E1','E2','E3')) THEN
				UPDATE "informix".sd_maecred SET status_cred = 'E1'
				 WHERE empresa = g_Empresa
				   AND num_credito = g_NumCredito;

				UPDATE "informix".sd_maesdos
				   SET dias_acum_mora = 0, act=0
				 WHERE num_credito = g_NumCredito
				   AND empresa = g_Empresa;				   
				   
			  END IF;
            

			UPDATE "informix".sd_maecredanexo
			   SET fecha_vencto = NULL
			 WHERE num_credito = g_NumCredito
			   AND empresa = g_Empresa;


			UPDATE "informix".sd_amortiza_credito
			   SET capital_status ="5"
			 WHERE num_credito = g_NumCredito
			   AND empresa = g_Empresa
			   AND capital_status IN ("2","7","6"); --CAMBIOS POR IFRS --AEH
       ELSE
             IF (g_PagoCapVencido > 0 and g_StCred <> "AA") THEN  --CAMBIOS POR IFRS --AEH
                 SELECT MIN(fecha_cuota) INTO vFecVenc  FROM "informix".sd_amortiza_credito
                 WHERE empresa='001'
                 and num_credito = g_NumCredito
                 and capital_status in ('2','7','6')
                 and capital_debe-capital_pagado > 0;
                  --                SELECT MONTH(fecha_vencto),DAY(fecha_vencto) INTO vFecVenc,vDiaVenc FROM sd_maecredanexo
                  --                WHERE num_credito = g_NumCredito
                  --                  AND empresa = g_Empresa;
                 UPDATE "informix".sd_maecredanexo
                     SET fecha_vencto =vFecVenc
                 WHERE num_credito = g_NumCredito
                   AND empresa = g_Empresa;
             END IF;
		END IF

-- CAS INI
     --   SELECT sdo_cap_insoluto, sdo_trab4
     --     INTO vSdoRetenido, vMontoCuotas
     --     FROM sd_maesdos
     --    WHERE num_credito = g_NumCredito
     --      AND empresa = g_Empresa;

      --  IF vSdoRetenido <= vMontoCuotas THEN
      --     LET vMontoCuotas = 0;
      --  END IF

      --  UPDATE sd_maesdos
      --     SET sdo_trab4 = vMontoCuotas
      --   WHERE num_credito = g_NumCredito
      --    AND empresa = g_Empresa;
-- CAS FIN

	IF g_Remanente > 0 THEN
	    UPDATE "informix".sd_maesdos
               SET sdo_cap_insoluto = sdo_cap_insoluto - g_Remanente ,
	           sdo_capital = sdo_capital - g_Remanente
	     WHERE empresa = g_Empresa
	       AND num_credito = g_NumCredito;
			IF (g_Transacc = '9854') THEN
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,53,
							'059', g_Fecha, g_Remanente, g_Folio,
							g_Sucursal, g_Divisa, g_Transacc) RETURNING
							CodRet, Mensaje;
			ELSE
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,901,
                        g_CodigoFun, g_Fecha, g_Remanente, g_Folio,
                        g_Sucursal, g_Divisa, g_Transacc) RETURNING
                        CodRet, Mensaje;
			END IF;
            IF (CodRet <> "00000") THEN
                LET  CodRet = CodRet;
            ELSE
                LET CodRet = "000";
            END IF;

	    LET g_Remanente = 0;
	END IF

	UPDATE "informix".sd_maecredanexo
	   SET fecha_ult_pago = g_Fecha
	 WHERE empresa = g_Empresa
	   AND num_credito = g_NumCredito;

    END IF;

    LET  g_IntMoraCob = g_IntMoraCob;
    LET  g_IntVencCob = g_IntVencCob;
    LET  g_CapVencCob = g_CapVencCob;
    LET  g_IntVigCob  = g_IntVigCob;
    LET  g_CapVigCob = g_CapVigCob;
    LET  g_Impuesto = g_Impuesto;
    LET  g_Comision = g_Comision;
    LET  g_Seguro = g_Seguro;
    LET  g_Iva = g_Iva;
    LET  g_MoraIva = g_MoraIva;

    LET vTotPag =  g_IntMoraCob + g_IntVencCob + g_CapVencCob + g_IntVigCob +
                   g_CapVigCob + g_Impuesto + g_Comision + g_Seguro +
                   g_Iva + g_MoraIva;
	SELECT sdo_cap_insoluto + sdo_retenido
	  INTO g_Remanente
	  FROM "informix".sd_maesdos
	 WHERE empresa = g_Empresa
	   AND num_credito = g_NumCredito;
	IF p_transacc <> '8151' THEN
		UPDATE "informix".sd_maesdos
		   SET monto_financiado = monto_financiado - ( g_CapVigCob + g_CapVencCob ),
			   mto_ministra_cap = mto_ministra_cap - (g_CapVigCob + g_CapVencCob)
		 WHERE empresa = g_Empresa
		   AND num_credito = g_NumCredito;
	 END IF;

    --p_MOnto > 0 para que registre pagos aun cuando se reciban pagos a cuentas con 0 saldo

    IF (vTotPag > 0) or (p_Monto > 0) THEN
		IF (g_Transacc = '9854') THEN
			LET vReferencia = 54;   --PAGO ATM CGO CUENTA
		ELIF (g_Transacc = '4356') THEN
			LET vReferencia = 125;   --PAGO ATM EFECTIVO
		ELSE
			LET vReferencia = 1;   -- Total del Pago
		END IF;
        CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto, vReferencia,
                     g_CodigoFun, g_Fecha, p_Monto, g_Folio,          --vtotpag
                     g_Sucursal, g_Divisa, g_Transacc) RETURNING
                     CodRet, Mensaje;
        IF (CodRet <> "00000") THEN
            LET  CodRet = CodRet;
        ELSE
            LET CodRet = "000";
        END IF;
-- jom ini SBC -- Movimiento de Liberacion
        IF (g_CodigoFun = '336') THEN
            LET vReferencia = 21;   -- Por el total del pago
            CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto, vReferencia,
                         g_CodigoFun, g_Fecha, p_Monto, g_Folio,          --vtotpag
                         g_Sucursal, g_Divisa, g_Transacc) RETURNING
                         CodRet, Mensaje;
            IF (CodRet <> "00000") THEN
                LET  CodRet = CodRet;
            ELSE
                LET CodRet = "000";
            END IF;
        END IF;
-- jom fin SBC -- Movimiento de Liberacion
    END IF;

--- jom ini corresponsales coppel, oxxo, 7eleven
    IF (g_CodigoFun in ('700','701','702')) THEN
       UPDATE "informix".sd_movdia
          SET usuario = g_Usuario
        WHERE sucursal = g_Sucursal
          and folio_suc = g_Folio;
    END IF;
--- jom ini corresponsales coppel, oxxo, 7eleven

    IF(CodRet <> "000") THEN
        ROLLBACK WORK;
    ELSE
        COMMIT WORK;
    END IF;
    IF (wBegin = "S") THEN
        BEGIN WORK;
    END IF;

    SELECT descripcion
      INTO Mensaje
      FROM bdinteg:"informix".si_codret
     WHERE sistema = g_sistema
       AND codigo_retorno = CodRet;

	IF CodRet = "000" THEN
	  --FMJ marzo,2012
	  SELECT indicador INTO vlIndicador
        FROM bdicred:"informix".sd_transfun
       WHERE codigo_fun = g_CodigoFun
	     AND codigo_ref = 1;

	  IF vlIndicador ='V' THEN
	    EXECUTE PROCEDURE "informix".sp_graba_indicador(g_Empresa, g_NumCredito,p_Monto,'',g_CodigoFun,1, g_Fecha, p_Folio,0,0,2)
	     into vcod_ret;
	  END IF;
	  
		IF g_CodigoFun IN ('057','904','905') THEN 
			IF cAplicaBoniAnual <> '0' THEN
		
				SELECT fecha_prox_anualidad INTO dFechaProxAnualidad
				FROM bdicred:sd_indicador_cred
				WHERE empresa = g_Empresa and num_credito = g_NumCredito;  
				
				SELECT fecha_hoy INTO pFecha
				FROM bdicred:sd_fechas WHERE empresa = g_Empresa;
				
				EXECUTE PROCEDURE sp_actIndicadores_gastosBonificacion(g_Empresa, g_NumCredito, sDiaCorte, p_Monto, 
									pFecha,dFechaProxAnualidad, cAplicaBoniAnual, '1') INTO cod_ret3;
			END IF;		  
		END IF;		  
	END IF;

  ---Evaluacion objetiva -------------------------------------------------------------------------------------
  INSERT INTO bdicobranza:"informix".cb_evaluacion_objetiva(empresa, sucursal, fecha_insert, usuario, num_credito, pago_min, saldo_vencido, pago_realizado,
                                                          pct_cump_pm, pct_cump_sv, folio_suc, reversado, transacc_suc, codigo_fun)
    VALUES (g_Empresa, g_Sucursal, g_Fecha, g_Usuario, g_NumCredito, dPago_minimo, dSaldo_vencido, g_Monto,
            case when dPago_minimo > 0 THEN  case when (round((g_Monto/dPago_minimo),2)*100) > 100 then 100 else (round((g_Monto/dPago_minimo),2)*100) end ELSE 0 END,
            case when dSaldo_vencido > 0 THEN  case when (round((g_Monto/dSaldo_vencido),2)*100) > 100 then 100 else (round((g_Monto/dSaldo_vencido),2)*100) end ELSE 0 END,
            g_Folio,'N', g_Transacc, g_CodigoFun);

  ---Evaluacion objetiva -------------------------------------------------------------------------------------
	LET p_Transacc = p_Transacc;
	LET g_Transacc = g_Transacc;
  ------ Actualiza saldos Condonacion y Quitas
							   
    IF vIndProceso IN ('Q','C') AND g_Transacc <> '8638' THEN
	SELECT 
		SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),
        SUM((mora_provi_ordi + mora_provi_cope + mora_sdo_ordi) - (mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag)),
        NVL(SUM(interes_debe - interes_pagado),0),
		SUM(NVL(iva_debe,0) - NVL(iva_pagado,0))
		INTO vIntVencido, vIntMoratorio, vIvaIntVigente, vIvaIntVencido
		FROM "informix".sd_amortiza_credito WHERE empresa = '001' AND num_credito = g_NumCredito;

		SELECT capital_mto_cuota INTO vCapitalMtoCuota 
		FROM "informix".sd_amortiza_credito WHERE num_credito = g_NumCredito AND fecha_cuota = fecha_quita;

		IF vIndProceso IN ('Q') THEN 
		
			SELECT sdo_capital,monto_vencido,mto_venc_trasp,cap_tras_no_venci,monto_otorgado
				INTO csg_cap_vig,csg_cap_trans,csg_cap_vdo_exig,csg_cap_vdo_no_exig,vMontoTransaccCancelaLinea
			FROM bdicred:sd_maesdos
				WHERE num_credito =	g_NumCredito;
				
				IF csg_cap_vig IS NULL OR csg_cap_vig = '' THEN	LET csg_cap_vig = 0; END IF;
				IF csg_cap_trans IS NULL OR csg_cap_trans = '' THEN	LET csg_cap_trans = 0; END IF;
				IF csg_cap_vdo_exig IS NULL OR csg_cap_vdo_exig = '' THEN	LET csg_cap_vdo_exig = 0; END IF;
				IF csg_cap_vdo_no_exig IS NULL OR csg_cap_vdo_no_exig = '' THEN	LET csg_cap_vdo_no_exig = 0; END IF;
				

				--- se genera movimiento por la quita   
			IF (csg_cap_vig > 0 and ((g_StCred='AA' or g_StCred='BA') OR (g_StCred='E1' AND g_ACT=0))) THEN
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,941,'125',
								g_Fecha, csg_cap_vig, g_Folio,g_Sucursal, g_Divisa,'8652') RETURNING CodRet, Mensaje;
			END IF;
			IF (csg_cap_trans > 0 and ((g_StCred='AA' or g_StCred='BA') OR (g_StCred='E1' AND g_ACT>0))) THEN
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,942,'125',
								g_Fecha, csg_cap_trans, g_Folio,g_Sucursal, g_Divisa,'8653') RETURNING CodRet, Mensaje;						
			END IF;

			IF (csg_cap_vig > 0 and (g_StCred='BT' OR (g_StCred='E2' AND g_ACT<4))) THEN
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,944,'125',
								g_Fecha, csg_cap_vig, g_Folio,g_Sucursal, g_Divisa,'8659') RETURNING CodRet, Mensaje;
			END IF;
			IF (csg_cap_trans > 0 and (g_StCred='BT' OR (g_StCred='E2' AND g_ACT<4))) THEN
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,943,'125',
								g_Fecha, csg_cap_trans, g_Folio,g_Sucursal, g_Divisa,'8659') RETURNING CodRet, Mensaje;						
			END IF;

			IF (csg_cap_vig > 0 and (g_StCred='BT' OR (g_StCred='E3' AND g_ACT>3))) THEN
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,946,'125',
								g_Fecha, csg_cap_vig, g_Folio,g_Sucursal, g_Divisa,'8652') RETURNING CodRet, Mensaje;
			END IF;
			IF (csg_cap_trans > 0 and (g_StCred='BT' OR (g_StCred='E3' AND g_ACT>3))) THEN
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,945,'125',
								g_Fecha, csg_cap_trans, g_Folio,g_Sucursal, g_Divisa,'8653') RETURNING CodRet, Mensaje;						
			END IF;

			IF (csg_cap_vdo_exig > 0 and g_StCred='BT') THEN
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,13,'125',
								g_Fecha, csg_cap_vdo_exig, g_Folio,g_Sucursal, g_Divisa,'8659') RETURNING CodRet, Mensaje;						
			END IF;
			IF (csg_cap_vdo_no_exig > 0 and g_StCred='BT') THEN
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,14,'125',
								g_Fecha, csg_cap_vdo_no_exig, g_Folio,g_Sucursal, g_Divisa,'8660') RETURNING CodRet, Mensaje;						
			END IF;
			
			   IF CodRet::smallint = 0 THEN
			    LET CodRet = '000';
			   END IF;
			--- Solo cancela y salda cuando se realiza una quita de capital
			IF csg_cap_vig > 0 OR csg_cap_trans > 0 OR csg_cap_vdo_exig > 0 OR csg_cap_vdo_no_exig > 0 THEN
				
				---- se actualizan saldos
				UPDATE bdicred:sd_maesdos 
					SET  sdo_cap_insoluto = 
						CASE WHEN sdo_cap_insoluto - (csg_cap_vig + csg_cap_trans + csg_cap_vdo_exig + csg_cap_vdo_no_exig) < 0
						THEN 0 ELSE sdo_cap_insoluto - (csg_cap_vig + csg_cap_trans + csg_cap_vdo_exig + csg_cap_vdo_no_exig) END,
					sdo_capital = CASE WHEN (sdo_capital - csg_cap_vig) < 0 THEN 0 ELSE sdo_capital - csg_cap_vig END,
					monto_vencido = monto_vencido - csg_cap_trans,
					mto_venc_trasp = mto_venc_trasp - csg_cap_vdo_exig,  --Cambios por IFRS --AEH
					cap_tras_no_venci = cap_tras_no_venci - csg_cap_vdo_no_exig,  --Cambios por IFRS --AEH
					monto_financiado = sdo_cap_insoluto - (csg_cap_vig + csg_cap_trans + csg_cap_vdo_exig + csg_cap_vdo_no_exig)
				WHERE num_credito = g_NumCredito;
							
				--- se salda credito
				Update "informix".sd_maesdos Set monto_otorgado = 0 Where empresa = g_Empresa And num_credito= g_NumCredito;  		
				UPDATE "informix".sd_maecred SET status_cred= 'FF' WHERE empresa = g_Empresa AND num_credito= g_NumCredito;			
			
				-- Se realiza el Bloqueo de la tarjeta.
				FOREACH
					SELECT num_tarjeta INTO vtarjeta
					FROM bdicred:sd_tarjeta WHERE empresa = g_Empresa
					AND num_credito = g_NumCredito AND tipo_tarjeta<>'0' AND status_tar <> 'C'

					SELECT codproductotarjeta INTO cproduto
					FROM intercard:tarjeta WHERE numtarjeta=vtarjeta;

					EXECUTE PROCEDURE intercard:"informix".sp_cancelacion_tarjeta (vtarjeta,cproduto,'informix') INTO CodRetqc, Mensaje;

					IF CodRetqc='001' OR CodRetqc='002' THEN
					 LET CodRetqc = '000000';
					 LET Mensaje= " ";
					END IF;
				END FOREACH;
			
				UPDATE "informix".sd_tarjeta SET status_tar= 'C', limite_aut = 0, motivo = 'CV' WHERE empresa= g_Empresa AND num_credito= g_NumCredito AND status_tar <> 'C';	
				
				--- Se cambia bandera de quita para realizar cancelacion
				LET vIndProceso = 'F';
			END IF;

		END IF;
		
		--Se consultan saldos despues de aplicar el pago
		EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(g_Empresa,g_NumCredito) 
		INTO  csg_codigo_ret,csg_mensaje_ret,csg_num_credito,csg_cod_tipcred,csg_fec_origen,csg_fec_prox_pago,csg_pago_min,
				csg_fec_ult_pago,csg_plazo,csg_pagos_realizados,csg_linea_otorgada,csg_tasa_interes,csg_tasa_moratorios,
				csg_monto_sbc,csg_cap_vig,csg_cap_trans,csg_cap_vdo_exig,csg_cap_vdo_no_exig,csg_sdo_act_total_cap,csg_int_vig,
				csg_int_vdo,csg_int_moratorios,csg_int_mes,csg_sdo_act_total_int,csg_iva_int_vig,csg_iva_int_vdo,csg_iva_int_moratorios,
				csg_iva_int_mes,csg_sdo_act_total_iva,csg_com_pend,csg_iva_com,csg_sdo_retenido,csg_tot_liquidacion,csg_int_devengado,
				csg_iva_int_devengado,csg_linea_disp,csg_pagos_vdos,csg_desc_status_cred,csg_id_bloqueo_cred,csg_bloqueo_cta,
				csg_id_causa_bloq_cred,csg_causa_bloqueo_cta,csg_id_sit_esp_cte,csg_id_causa_esp_cte,csg_sit_esp_cte,csg_id_sit_esp_cred,
				csg_id_causa_esp_cred,csg_sit_esp_cred;
				
	LET vSdoCredito = dMontoOtorgado-g_SdoCapInsoluto-csg_sdo_retenido;
		
		-----Se valida si el pago fue igual o mayor a la quita o condonacion--------
		-------para modificar el estatus a FI y si no que se quede en PR------------
		IF g_Monto >= monto_qc THEN
		  LET estatus_proceso_act = 'FI';		  
		  LET dFechaliquidacion = today;
		  LET dFechastatus = today;
		ELSE
		  LET estatus_proceso_act = 'PR';
		  LET dFechaliquidacion = dFechaliquidacion;
		  LET dFechastatus = dFechastatus;
		END IF;
		----------------------------------------------------------------------------
		--Se actualizan saldos y estatus en la bitacora	
		UPDATE "informix".sd_bitacora_quitacondonacion 
		SET meses_historia=vMesesHistoria,sdo_credito = vSdoCredito,
		fecha_pago = today,	abono_mensual_al_quita = NVL(vCapitalMtoCuota,0), 
		fecha_ult_mov = dFechaUltMov, fecha_status = dFechastatus,
		estatus_proceso = estatus_proceso_act, fecha_liquidacion = dFechaliquidacion,
		----------------------------------------------------------------------------
		cap_vigente_dq = NVL(csg_cap_vig,0), 
		cap_vencido_dq = csg_cap_vdo_exig, 
		int_vigente_dq = csg_int_vig, 
		int_vencido_dq = csg_int_vdo,
		int_moratorio_dq = csg_int_moratorios,		
		iva_int_vigente_dq = csg_iva_int_vig, 
		iva_int_vencido_dq = csg_iva_int_vdo,
		iva_int_mora_dq = csg_iva_int_moratorios
		WHERE num_credito = g_NumCredito AND estatus_proceso='PR';
		----------------------------------------------------------------------------
	  COMMIT;
	  BEGIN;
		IF vMontoTransaccCancelaLinea > 0 AND vIndProceso = 'F' THEN
			CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,2,'008',g_Fecha, vMontoTransaccCancelaLinea, g_Folio,g_Sucursal, g_Divisa,'6697') RETURNING CodRetqc, Mensaje;
			IF  CodRetqc <> "00000" THEN
				LET mRemanente_cq = 4;
				RETURN CodRet, mRemanente_cq, g_IntMoraCob, g_IntVencCob,g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;				 
			END IF;	
        COMMIT;			
		END IF;  
		BEGIN;
	END IF;
  -------- Actualiza saldos Condonacion y Quitas
   
    RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
            g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
            g_Comision, g_Seguro;

END PROCEDURE
DOCUMENT
'Programa de Recuperacion de credito',
'Puede ser llamado desde el ofi, centrales o',
'Cobranza Automatica',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'VERSION: 1.00.003',
'BD    : BDICRED',
'Modificacion: Se implementan reglas de informix, se agregan las transacciones 7795 y 7796 de concepto de pago por condonacion',
'			   y condonacion por fallecimiento.',
'Modifico: Mireya Reyes',
'Folio: 1395-Condonacion de Intereses',
'BD: bdicred',
'Fecha: 2014-Enero-07',
'Version: 20140107.1540';

CREATE PROCEDURE "informix".sp_actindicadores_gastosbonificacion(pEmpresa CHAR(3), pNumCredito CHAR(20), pDiaCorte SMALLINT, pMonto DECIMAL(18,2), 
		pFecha DATE, pFechaProxAnualidad DATE, pAplicaBoniAnual CHAR(1), pBanderaReverso CHAR(1))
	RETURNING CHAR(5);   

---------------------------------------------------------------------------
--                         DEFINICION DE VARIABLES
---------------------------------------------------------------------------

--JRVT CAMBIOS BONIFICACION 29/10/2024
--DEFINE cNumProducto			CHAR(4);
DEFINE cMesAnterior			CHAR(1);
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE cCod_ret				CHAR(5);
DEFINE sAnioRegistro		SMALLINT;
DEFINE sCountReg			SMALLINT;
DEFINE dFechaCorte			DATE;
DEFINE sAnioRegistroAux		SMALLINT;


--LET cNumProducto			= '';
LET sCountReg			    = 0;
LET cMesAnterior			= '0';
LET cCod_ret      			= '00000';
LET sql_err       			= 0;
LET isam_err      			= 0;
LET sAnioRegistro			= 0;
LET dFechaCorte				= DATE(1);
LET sAnioRegistroAux 		= 0;
--JRVT

BEGIN
	ON EXCEPTION SET sql_err, isam_err
		LET cCod_ret = sql_err;
		RETURN cCod_ret;
	END EXCEPTION;
	
	LET dFechaCorte = MDY(MONTH(pFecha), pDiaCorte, YEAR(pFecha));
			
	IF MONTH(dFechaCorte) = 1 THEN
		IF pFecha < dFechaCorte THEN
			LET sAnioRegistro = YEAR(monthadd(pFecha, - 12));
		ELSE
			LET sAnioRegistro = YEAR(pFecha);
		END IF;
	ELSE 
		LET sAnioRegistro = YEAR(pFecha);
	END IF;
	
	IF pFecha <= dFechaCorte THEN
		LET cMesAnterior = '1';
	END IF;
	
	IF pAplicaBoniAnual = '1' OR pAplicaBoniAnual = '3' THEN -- SI ES BONIFICACION ANUAL O POR MESES
	
		SELECT COUNT(num_credito) INTO sCountReg FROM sd_gastos_bonificacion 
			WHERE empresa = pEmpresa AND num_credito = pNumCredito AND fecha_registro = pFechaProxAnualidad;
				  --AND anio_registro = sAnioRegistro;
				  
		IF sCountReg = 0 THEN
			INSERT INTO sd_gastos_bonificacion (empresa, fecha_registro,anio_registro,num_credito,gasto_total_anual)
				VALUES (pEmpresa, pFechaProxAnualidad, sAnioRegistro, pNumCredito, pMonto);
		ELSE
			IF sCountReg  = 2 THEN
				LET sAnioRegistroAux = sAnioRegistro - 1;
			ELSE
				SELECT anio_registro INTO sAnioRegistroAux FROM sd_gastos_bonificacion 
					WHERE empresa = pEmpresa AND num_credito = pNumCredito AND fecha_registro = pFechaProxAnualidad;
			END IF;
			
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_total_anual = NVL(gasto_total_anual,0) + pMonto 
					WHERE empresa = pEmpresa AND num_credito = pNumCredito AND fecha_registro = pFechaProxAnualidad 
						AND anio_registro = sAnioRegistroAux;
			ELSE --REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_total_anual = NVL(gasto_total_anual,0) - pMonto 
					WHERE empresa = pEmpresa AND num_credito = pNumCredito AND fecha_registro = pFechaProxAnualidad 
						AND anio_registro = sAnioRegistroAux;
			END IF;
		END IF;
	END IF;
	
	IF pAplicaBoniAnual = '2' OR pAplicaBoniAnual = '3' THEN -- SI ES BONIFICACION ANUAL O POR MESES
		
		IF MONTH(pFecha) = 1 AND cMesAnterior = '0' THEN--GASTOS ENERO
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_enero = NVL(gasto_enero, 0) + pMonto
					WHERE empresa = pEmpresa AND fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_enero = NVL(gasto_enero, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 1 AND cMesAnterior = '1' THEN--GASTOS DICIEMBRE
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_diciembre = NVL(gasto_diciembre, 0) + pMonto
					WHERE empresa = pEmpresa AND fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_diciembre = NVL(gasto_diciembre, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
		
		IF MONTH(pFecha) = 2 AND cMesAnterior = '0' THEN--GASTOS FEBRERO
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_febrero = NVL(gasto_febrero, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_febrero = NVL(gasto_febrero, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 2 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_enero = NVL(gasto_enero, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_enero = NVL(gasto_enero, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
		
		IF MONTH(pFecha) = 3 AND cMesAnterior = '0' THEN--GASTOS MARZO
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_marzo = NVL(gasto_marzo, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_marzo = NVL(gasto_marzo, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 3 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_febrero = NVL(gasto_febrero, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_febrero = NVL(gasto_febrero, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
		
		IF MONTH(pFecha) = 4 AND cMesAnterior = '0' THEN--GASTOS ABRIL
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_abril = NVL(gasto_abril, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro =  sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_abril = NVL(gasto_abril, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 4 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_marzo = NVL(gasto_marzo, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro =  sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_marzo = NVL(gasto_marzo, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
		
		IF MONTH(pFecha) = 5 AND cMesAnterior = '0' THEN--GASTOS MAYO
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_mayo = NVL(gasto_mayo, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_mayo = NVL(gasto_mayo, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 5 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_abril = NVL(gasto_abril, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_abril = NVL(gasto_abril, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
		
		IF MONTH(pFecha) = 6 AND cMesAnterior = '0' THEN--GASTOS JUNIO
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_junio = NVL(gasto_junio, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_junio = NVL(gasto_junio, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 6 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_mayo = NVL(gasto_mayo, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_mayo = NVL(gasto_mayo, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
		
		IF MONTH(pFecha) = 7 AND cMesAnterior = '0' THEN--GASTOS JULIO
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_julio = NVL(gasto_julio, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_julio = NVL(gasto_julio, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 7 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_junio = NVL(gasto_junio, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_junio = NVL(gasto_junio, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
			
		IF MONTH(pFecha) = 8 AND cMesAnterior = '0' THEN--GASTOS AGOSTO
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_agosto = NVL(gasto_agosto, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_agosto = NVL(gasto_agosto, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 8 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_julio = NVL(gasto_julio, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_julio = NVL(gasto_julio, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
			
		IF MONTH(pFecha) = 9 AND cMesAnterior = '0' THEN--GASTOS SEPTIEMBRE
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_septiembre = NVL(gasto_septiembre, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_septiembre = NVL(gasto_septiembre, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 9 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_agosto = NVL(gasto_agosto, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_agosto = NVL(gasto_agosto, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
		
		IF MONTH(pFecha) = 10 AND cMesAnterior = '0' THEN--GASTOS OCTUBRE
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_octubre = NVL(gasto_octubre, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_octubre = NVL(gasto_octubre, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 10 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_septiembre = NVL(gasto_septiembre, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_septiembre = NVL(gasto_septiembre, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
			
		IF MONTH(pFecha) = 11 AND cMesAnterior = '0' THEN--GASTOS NOVIEMBRE
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_noviembre = NVL(gasto_noviembre, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_noviembre = NVL(gasto_noviembre, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 11 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_octubre = NVL(gasto_octubre, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_octubre = NVL(gasto_octubre, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
		
		IF MONTH(pFecha) = 12 AND cMesAnterior = '0' THEN--GASTOS DICIEMBRE
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_diciembre = NVL(gasto_diciembre, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_diciembre = NVL(gasto_diciembre, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 12 AND cMesAnterior = '1' THEN	
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_noviembre = NVL(gasto_noviembre, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_noviembre = NVL(gasto_noviembre, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
	END IF;
	
	RETURN cCod_ret;
END;
END PROCEDURE
		
		
		
		
		
		
		
		
		
		
		
		
		
;