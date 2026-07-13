CREATE PROCEDURE "informix".respventacnr(eEmpresa    CHAR(3),
										eNumCredito CHAR(20),
										eFecha      date)
--EXECUTE PROCEDURE respventacnr ('001','610002874077',TODAY);
   RETURNING CHAR(5);   --CodRet   

	--Definicion de variables
	DEFINE CodRet              CHAR(5);
	DEFINE sql_err             SMALLINT;
	DEFINE isam_err            SMALLINT;
	DEFINE error_info          CHAR(40);
	DEFINE nrows               SMALLINT;
	DEFINE Mensaje             CHAR(80);
	DEFINE wSecuenciaPago      LIKE sd_secpago.secuencia;
	-- Se definen variables para quitar INSERT - SELECT
	DEFINE mvNumCredito			CHAR(20);
	DEFINE mvNumProducto		CHAR(4);
	DEFINE mvEjecutivo			CHAR(8);
	DEFINE mvNumCte				CHAR(20);
	DEFINE mvAvalCte			CHAR(20);
	DEFINE mvAvalLinea			CHAR(20);
	DEFINE mvDivisa				CHAR(2);
	DEFINE mvSucursal			CHAR(4);
	DEFINE mvIdOrigen			CHAR(2);
	DEFINE mvOrigen				CHAR(3);
	DEFINE mvCodTipoLinea		CHAR(2);
	DEFINE mvCodLinea			CHAR(4);
	DEFINE mvStatusCred			CHAR(2);
	DEFINE mvBanderaRenovac		CHAR(1);
	DEFINE mvBanderaProrroga	CHAR(1);
	DEFINE mvPeriodoPlazo		CHAR(1);
	DEFINE mvPlazo				INTEGER;
	DEFINE mvFechaApertura		DATE;
	DEFINE mvFechaVencim		DATE;
	DEFINE mvPeriodoPagoCap		CHAR(1);
	DEFINE mvPeriodPagInt		CHAR(1);
	DEFINE mvDiasTraspCap		INTEGER;
	DEFINE mvDiasTraspInt		INTEGER;
	DEFINE mvTasaFijaOVar		CHAR(1);
	DEFINE mvCodTasaBase		CHAR(8);
	DEFINE mvFactorSobretasa	CHAR(1);
	DEFINE mvSobretasa			DECIMAL(9,6);
	DEFINE mvTasaInteres		DECIMAL(9,6);
	DEFINE mvCodTasaMora		CHAR(8);
	DEFINE mvSobretasaMora		DECIMAL(9,6);
	DEFINE mvFactSobretMora		CHAR(1);
	DEFINE mvTasaMoratorios		DECIMAL(9,6);
	DEFINE mvTasaPreferencial	CHAR(8);
	DEFINE mvSobretasaPreferencial	DECIMAL(9,6);
	DEFINE mvFactorPreferencial	CHAR(1);
	DEFINE mvValorPreferencial	DECIMAL(18,2);
	DEFINE mvFechaPagoCap		DATE;
	DEFINE mvFechaPagoInt		DATE;
	DEFINE mvEsFisica			CHAR(1);
	DEFINE mvBanderaFiFo		CHAR(2);
	DEFINE mvActividad			CHAR(3);
	DEFINE mvTipoCalculo		CHAR(2);
	DEFINE mvNumAperAnt			CHAR(20);
	DEFINE mvRevTasaVarPer		CHAR(1);
	DEFINE mvDiaParaRevisar		CHAR(1);
	DEFINE mvCodProd			CHAR(2);
	DEFINE mvBanderaMinistra	CHAR(1);
	DEFINE mvCreditoExterno		CHAR(20);
	DEFINE mvCalificaRiesgo		CHAR(2);
	DEFINE mvCodAgricola		CHAR(5);
	DEFINE mvPagosSostenidos	INTEGER;
	DEFINE mvCampoTrab1			DECIMAL(18,2);
	DEFINE mvCampoTrab2			DECIMAL(18,2);
	DEFINE mvCampoTrab3			CHAR(10);
	DEFINE mvCampoTrab4			CHAR(10);
	DEFINE mvCuentaClabe		CHAR(18);
	
	DEFINE svNumCredito			CHAR(20);
	DEFINE svFechaUltMov		DATE;
	DEFINE svSdoIntAnticip		DECIMAL(18,2);
	DEFINE svSdoIntAntDev		DECIMAL(18,2);
	DEFINE svSdoIntereses		DECIMAL(18,2);
	DEFINE svSdoDiaAntInt		DECIMAL(18,2);
	DEFINE svSdoMesAntInt		DECIMAL(18,2);
	DEFINE svSdoAcumMesInt		DECIMAL(18,2);
	DEFINE svSdoRetenido		DECIMAL(18,2);
	DEFINE svSdoAcumCapInt		DECIMAL(18,2);
	DEFINE svSdoExigInt			DECIMAL(18,2);
	DEFINE svSdoNoExig			DECIMAL(18,2);
	DEFINE svProvisionNormal	DECIMAL(18,2);
	DEFINE svDiasAcumInt		INTEGER;
	DEFINE svSdoMoratorio		DECIMAL(18,2);
	DEFINE svSdoDiaAntMor		DECIMAL(18,2);
	DEFINE svSdoMesAntMor		DECIMAL(18,2);
	DEFINE svSdoContabMora		DECIMAL(18,2);
	DEFINE svDiasAcumMora		INTEGER;
	DEFINE svSdoCapital			DECIMAL(18,2);
	DEFINE svSdoCapInsoluto		DECIMAL(18,2);
	DEFINE svSdoDiaAntCap		DECIMAL(18,2);
	DEFINE svSdoMesAntCap		DECIMAL(18,2);
	DEFINE svSdoAcumMesCap		DECIMAL(18,2);
	DEFINE svMtoCapitalizado	DECIMAL(18,2);
	DEFINE svMtoMinistraCap		DECIMAL(18,2);
	DEFINE svCargosDiaCap		DECIMAL(18,2);
	DEFINE svAbonosDiaCap		DECIMAL(18,2);
	DEFINE svCargosMesCap		DECIMAL(18,2);
	DEFINE svAbonosMesCap		DECIMAL(18,2);
	DEFINE svDiasAcumCap		INTEGER;
	DEFINE svMontoVencido		DECIMAL(18,2);
	DEFINE svMtoVencTrasp		DECIMAL(18,2);
	DEFINE svMontoFinanciado	DECIMAL(18,2);
	DEFINE svMontoReservado		DECIMAL(18,2);
	DEFINE svSdoAcumVencido		DECIMAL(18,2);
	DEFINE svDiasAcumIntper		INTEGER;
	DEFINE svSdoGlobalInt		DECIMAL(18,2);
	DEFINE svSdoAcumIntper		DECIMAL(18,2);
	DEFINE svMontoOtorgado		DECIMAL(18,2);
	DEFINE svProviVencNormal	DECIMAL(18,2);
	DEFINE svProviVencAnticip	DECIMAL(18,2);
	DEFINE svCapTrasNoVenci		DECIMAL(18,2);
	DEFINE svMtoVencInt			DECIMAL(18,2);
	DEFINE svMtoVencTraInt		DECIMAL(18,2);
	DEFINE svMtoFinanVdo		DECIMAL(18,2);
	DEFINE svMtoReserInt		DECIMAL(18,2);
	DEFINE svMtoFinVenTrasp		DECIMAL(18,2);
	DEFINE svMtoFinVigTrasp		DECIMAL(18,2);
	DEFINE svIntTraNoExig		DECIMAL(18,2);
	DEFINE svSdoTrab4			DECIMAL(18,2);
	
	DEFINE avNumCredito			CHAR(20);
	DEFINE avFechaCuota			DATE;
	DEFINE avTipoCuota			CHAR(1);
	DEFINE avCapitalMtoCuota	DECIMAL(14,2);
	DEFINE avCapitalDebe		DECIMAL(14,2);
	DEFINE avCapitalPagado		DECIMAL(14,2);
	DEFINE avCapitalStatus		CHAR(1);
	DEFINE avCapitalStatusAnt	CHAR(1);
	DEFINE avCapitalFechaPago	DATE;
	DEFINE avInteresDebe		DECIMAL(14,2);
	DEFINE avInteresPagado		DECIMAL(14,2);
	DEFINE avInteresStatus		CHAR(1);
	DEFINE avInteresStatusAnt	CHAR(18);
	DEFINE avInteresFechaPago	CHAR(18);
	DEFINE avIvaDebe			DECIMAL(14,2);
	DEFINE avIvaPagado			DECIMAL(14,2);
	DEFINE avIvaStatus			CHAR(1);
	DEFINE avIvaStatusAnt		CHAR(1);
	DEFINE avIvaFechaPago		DATE;
	DEFINE avMoraProviOrdi		DECIMAL(14,2);
	DEFINE avMoraProviCope		DECIMAL(14,2);
	DEFINE avMoraSdoOrdi		DECIMAL(14,2);
	DEFINE avMoraSdoOrdiPag		DECIMAL(14,2);
	DEFINE avMoraSdoCope		DECIMAL(14,2);
	DEFINE avMoraSdoCopePag		DECIMAL(14,2);
	DEFINE avMoraBonificado		DECIMAL(14,2);
	DEFINE avMoraStatus			CHAR(1);
	DEFINE avMoraIvaDebe		DECIMAL(14,2);
	DEFINE avMoraIvaPagado		DECIMAL(14,2);
	DEFINE avMoraIvaStatus		CHAR(1);
	DEFINE avMoraIvaFechaPago	DATE;
	DEFINE avNumPago			INTEGER;
	DEFINE avCampoTrabajo1		DECIMAL(14,2);
	DEFINE avCampoTrabajo2		DECIMAL(14,2);
	DEFINE avCampoTrabajo3		VARCHAR(20);
	DEFINE avCampoTrabajo4		VARCHAR(20);
   
--set debug file to "respventacr.out";
--trace on;
	
	--Inicializacion de variables
	LET CodRet = "000";
	LET eNumCredito = eNumCredito;
	LET eFecha = eFecha;
	LET eEmpresa    = eEmpresa;
	
	LET mvNumCredito			= '';
	LET mvNumProducto			= '';
	LET mvEjecutivo				= '';
	LET mvNumCte				= '';
	LET mvAvalCte				= '';
	LET mvAvalLinea				= '';
	LET mvDivisa				= '';
	LET mvSucursal				= '';
	LET mvIdOrigen				= '';
	LET mvOrigen				= '';
	LET mvCodTipoLinea			= '';
	LET mvCodLinea				= '';
	LET mvStatusCred			= '';
	LET mvBanderaRenovac		= '';
	LET mvBanderaProrroga		= '';
	LET mvPeriodoPlazo			= '';
	LET mvPlazo					= 0;
	LET mvFechaApertura			= '';
	LET mvFechaVencim			= '';
	LET mvPeriodoPagoCap		= '';
	LET mvPeriodPagInt			= '';
	LET mvDiasTraspCap			= 0;
	LET mvDiasTraspInt			= 0;
	LET mvTasaFijaOVar			= '';
	LET mvCodTasaBase			= '';
	LET mvFactorSobretasa		= '';
	LET mvSobretasa				= 0;
	LET mvTasaInteres			= 0;
	LET mvCodTasaMora			= '';
	LET mvSobretasaMora			= 0;
	LET mvFactSobretMora		= '';
	LET mvTasaMoratorios		= 0;
	LET mvTasaPreferencial		= '';
	LET mvSobretasaPreferencial	= 0;
	LET mvFactorPreferencial	= '';
	LET mvValorPreferencial		= 0;
	LET mvFechaPagoCap			= '';
	LET mvFechaPagoInt			= '';
	LET mvEsFisica				= '';
	LET mvBanderaFiFo			= '';
	LET mvActividad				= '';
	LET mvTipoCalculo			= '';
	LET mvNumAperAnt			= '';
	LET mvRevTasaVarPer			= '';
	LET mvDiaParaRevisar		= '';
	LET mvCodProd				= '';
	LET mvBanderaMinistra		= '';
	LET mvCreditoExterno		= '';
	LET mvCalificaRiesgo		= '';
	LET mvCodAgricola			= '';
	LET mvPagosSostenidos		= 0;
	LET mvCampoTrab1			= 0;
	LET mvCampoTrab2			= 0;
	LET mvCampoTrab3			= '';
	LET mvCampoTrab4			= '';
	LET mvCuentaClabe			= '';
	
	LET svNumCredito			= '';
	LET svFechaUltMov			= 0;
	LET svSdoIntAnticip			= 0;
	LET svSdoIntAntDev			= 0;
	LET svSdoIntereses			= 0;
	LET svSdoDiaAntInt			= 0;
	LET svSdoMesAntInt			= 0;
	LET svSdoAcumMesInt			= 0;
	LET svSdoRetenido			= 0;
	LET svSdoAcumCapInt			= 0;
	LET svSdoExigInt			= 0;
	LET svSdoNoExig				= 0;
	LET svProvisionNormal		= 0;
	LET svDiasAcumInt			= 0;
	LET svSdoMoratorio			= 0;
	LET svSdoDiaAntMor			= 0;
	LET svSdoMesAntMor			= 0;
	LET svSdoContabMora			= 0;
	LET svDiasAcumMora			= 0;
	LET svSdoCapital			= 0;
	LET svSdoCapInsoluto		= 0;
	LET svSdoDiaAntCap			= 0;
	LET svSdoMesAntCap			= 0;
	LET svSdoAcumMesCap			= 0;
	LET svMtoCapitalizado		= 0;
	LET svMtoMinistraCap		= 0;
	LET svCargosDiaCap			= 0;
	LET svAbonosDiaCap			= 0;
	LET svCargosMesCap			= 0;
	LET svAbonosMesCap			= 0;
	LET svDiasAcumCap			= 0;
	LET svMontoVencido			= 0;
	LET svMtoVencTrasp			= 0;
	LET svMontoFinanciado		= 0;
	LET svMontoReservado		= 0;
	LET svSdoAcumVencido		= 0;
	LET svDiasAcumIntper		= 0;
	LET svSdoGlobalInt			= 0;
	LET svSdoAcumIntper			= 0;
	LET svMontoOtorgado			= 0;
	LET svProviVencNormal		= 0;
	LET svProviVencAnticip		= 0;
	LET svCapTrasNoVenci		= 0;
	LET svMtoVencInt			= 0;
	LET svMtoVencTraInt			= 0;
	LET svMtoFinanVdo			= 0;
	LET svMtoReserInt			= 0;
	LET svMtoFinVenTrasp		= 0;
	LET svMtoFinVigTrasp		= 0;
	LET svIntTraNoExig			= 0;
	LET svSdoTrab4				= 0;
	
	LET avNumCredito			= '';
	LET avFechaCuota			= '';
	LET avTipoCuota				= '';
	LET avCapitalMtoCuota		= 0;
	LET avCapitalDebe			= 0;
	LET avCapitalPagado			= 0;
	LET avCapitalStatus			= '';
	LET avCapitalStatusAnt		= '';
	LET avCapitalFechaPago		= '';
	LET avInteresDebe			= 0;
	LET avInteresPagado			= 0;
	LET avInteresStatus			= '';
	LET avInteresStatusAnt		= '';
	LET avInteresFechaPago		= '';
	LET avIvaDebe				= 0;
	LET avIvaPagado				= 0;
	LET avIvaStatus				= '';
	LET avIvaStatusAnt			= '';
	LET avIvaFechaPago			= '';
	LET avMoraProviOrdi			= 0;
	LET avMoraProviCope			= 0;
	LET avMoraSdoOrdi			= 0;
	LET avMoraSdoOrdiPag		= 0;
	LET avMoraSdoCope			= 0;
	LET avMoraSdoCopePag		= 0;
	LET avMoraBonificado		= 0;
	LET avMoraStatus			= '';
	LET avMoraIvaDebe			= 0;
	LET avMoraIvaPagado			= 0;
	LET avMoraIvaStatus			= '';
	LET avMoraIvaFechaPago		= '';
	LET avNumPago				= 0;
	LET avCampoTrabajo1			= 0;
	LET avCampoTrabajo2			= 0;
	LET avCampoTrabajo3			= '';
	LET avCampoTrabajo4			= '';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

      --FMV 20-ENE-2012 : ERROR -268 INFORMIX    
        DELETE FROM "informix".sd_maecredcrd_vendida WHERE empresa = eEmpresa 
                                                     AND num_credito = eNumCredito;
        DELETE FROM "informix".sd_maesdoscrd_vendida WHERE empresa = eEmpresa 
                                                     AND num_credito = eNumCredito;
        DELETE FROM "informix".sd_amortiza_creditocrd_vendida WHERE empresa = eEmpresa 
                                                             AND num_credito = eNumCredito;
	  --Se agrega la nueva tabla sd_maecredcrd_vend_total copia de la maecred_vendida
		DELETE FROM "informix".sd_maecredcrd_vend_total WHERE num_credito = eNumCredito;
													 
	--**    Respalda Maecredcrd		--
	--INSERT INTO sd_maecredcrd_vendida
	SELECT empresa				,num_credito				,num_producto				,ejecutivo, 
			numcte					,aval_cte				,aval_linea					,divisa			 			,sucursal,
			id_origen				,origen			 		,cod_tipo_linea				,cod_linea					,status_cred,
			bandera_renovac 		,bandera_prorroga		,periodo_plazo				,plazo			 			,fecha_apertura,
			fecha_vencim			,period_pago_cap		,period_pag_int	 			,dias_trasp_cap				,dias_trasp_int,
			tasa_fija_o_var 		,cod_tasa_base			,factor_sobretasa			,sobretasa					,tasa_interes,
			cod_tasa_mora			,sobretasa_mora			,fact_sobret_mora			,tasa_moratorios			,tasa_preferencial,
			sobretasa_preferencial	,factor_preferencial	,valor_preferencial			,fecha_pago_cap				,fecha_pago_int,
			es_fisica				,bandera_fi_fo			,actividad					,tipo_calculo				,num_aper_ant,
			rev_tasa_var_per		,dia_para_revisar		,cod_prod					,bandera_ministra			,credito_externo,
			califica_riesgo			,cod_agricola			,pagos_sostenidos			,campo_trab1				,campo_trab2,
			campo_trab3				,campo_trab4			,cuenta_clabe
	INTO	
			eEmpresa				,eNumCredito			,mvNumProducto				,mvEjecutivo
			,mvNumCte				,mvAvalCte				,mvAvalLinea				,mvDivisa					,mvSucursal
			,mvIdOrigen				,mvOrigen				,mvCodTipoLinea				,mvCodLinea					,mvStatusCred
			,mvBanderaRenovac		,mvBanderaProrroga		,mvPeriodoPlazo				,mvPlazo					,mvFechaApertura
			,mvFechaVencim			,mvPeriodoPagoCap		,mvPeriodPagInt				,mvDiasTraspCap				,mvDiasTraspInt
			,mvTasaFijaOVar			,mvCodTasaBase			,mvFactorSobretasa			,mvSobretasa				,mvTasaInteres
			,mvCodTasaMora			,mvSobretasaMora		,mvFactSobretMora			,mvTasaMoratorios			,mvTasaPreferencial
			,mvSobretasaPreferencial,mvFactorPreferencial	,mvValorPreferencial		,mvFechaPagoCap				,mvFechaPagoInt
			,mvEsFisica				,mvBanderaFiFo			,mvActividad				,mvTipoCalculo				,mvNumAperAnt
			,mvRevTasaVarPer		,mvDiaParaRevisar		,mvCodProd					,mvBanderaMinistra			,mvCreditoExterno
			,mvCalificaRiesgo		,mvCodAgricola			,mvPagosSostenidos			,mvCampoTrab1				,mvCampoTrab2
			,mvCampoTrab3			,mvCampoTrab4			,mvCuentaClabe
	FROM sd_maecredcrd
	WHERE empresa = eEmpresa
	AND num_credito = eNumCredito;
		
	INSERT INTO sd_maecredcrd_vendida (
				fecha				,empresa			,num_credito			,num_producto			,ejecutivo			,numcte				,aval_cte			,aval_linea
				,divisa				,sucursal			,id_origen				,origen					,cod_tipo_linea		,cod_linea  		,status_cred		,bandera_renovac
				,bandera_prorroga	,periodo_plazo		,plazo					,fecha_apertura			,fecha_vencim		,period_pago_cap	,period_pag_int		,dias_trasp_cap
				,dias_trasp_int		,tasa_fija_o_var	,cod_tasa_base			,factor_sobretasa		,sobretasa			,tasa_interes		,cod_tasa_mora		,sobretasa_mora
				,fact_sobret_mora	,tasa_moratorios	,tasa_preferencial		,sobretasa_preferencial	,factor_preferencial,valor_preferencial	,fecha_pago_cap		,fecha_pago_int
				,es_fisica			,bandera_fi_fo		,actividad				,tipo_calculo			,num_aper_ant		,rev_tasa_var_per	,dia_para_revisar	,cod_prod
				,bandera_ministra	,credito_externo	,califica_riesgo		,cod_agricola			,pagos_sostenidos	,campo_trab1		,campo_trab2		,campo_trab3
				,campo_trab4		,cuenta_clabe)
		VALUES (eFecha				,eEmpresa			,eNumCredito			,mvNumProducto			,mvEjecutivo		,mvNumCte			,mvAvalCte			,mvAvalLinea
				,mvDivisa			,mvSucursal			,mvIdOrigen				,mvOrigen				,mvCodTipoLinea		,mvCodLinea			,mvStatusCred		,mvBanderaRenovac
				,mvBanderaProrroga	,mvPeriodoPlazo		,mvPlazo				,mvFechaApertura		,mvFechaVencim		,mvPeriodoPagoCap	,mvPeriodPagInt		,mvDiasTraspCap
				,mvDiasTraspInt		,mvTasaFijaOVar		,mvCodTasaBase			,mvFactorSobretasa		,mvSobretasa		,mvTasaInteres		,mvCodTasaMora		,mvSobretasaMora
				,mvFactSobretMora	,mvTasaMoratorios	,mvTasaPreferencial		,mvSobretasaPreferencial,mvFactorPreferencial,mvValorPreferencial,mvFechaPagoCap	,mvFechaPagoInt
				,mvEsFisica			,mvBanderaFiFo		,mvActividad			,mvTipoCalculo			,mvNumAperAnt		,mvRevTasaVarPer	,mvDiaParaRevisar	,mvCodProd
				,mvBanderaMinistra	,mvCreditoExterno	,mvCalificaRiesgo		,mvCodAgricola			,mvPagosSostenidos	,mvCampoTrab1		,mvCampoTrab2		,mvCampoTrab3
				,mvCampoTrab4		,mvCuentaClabe);

	
	--Se inserta a la nueva tabla historica
	INSERT INTO bdicred:sd_maecredcrd_vend_total(fecha,num_credito,num_producto,numcte,status_cred,fecha_apertura,credito_externo) 
		VALUES (eFecha,eNumCredito,mvNumProducto,mvNumCte,mvStatusCred,mvFechaApertura,mvCreditoExterno);
	

	--**    Respalda Maesdoscrd		--
	--INSERT INTO sd_maesdoscrd_vendida
	SELECT empresa			 , num_credito		 , fecha_ult_mov		 , sdo_int_anticip			 , sdo_int_ant_dev			 ,
		   sdo_intereses	 , sdo_dia_ant_int	 , sdo_mes_ant_int		 , sdo_acum_mes_int			 , sdo_retenido				 , sdo_acum_cap_int	,
		   sdo_exig_int		 , sdo_no_exig		 , provision_normal		 , dias_acum_int			 , sdo_moratorio			 , sdo_dia_ant_mor	,
		   sdo_mes_ant_mor	 , sdo_contab_mora	 , dias_acum_mora		 , sdo_capital				 , sdo_cap_insoluto			 , sdo_dia_ant_cap	,
		   sdo_mes_ant_cap	 , sdo_acum_mes_cap	 , mto_capitalizado		 , mto_ministra_cap			 , cargos_dia_cap			 , abonos_dia_cap	,
		   cargos_mes_cap	 , abonos_mes_cap	 , dias_acum_cap		 , monto_vencido			 , mto_venc_trasp			 , monto_financiado	,
		   monto_reservado	 , sdo_acum_vencido	 , dias_acum_intper		 , sdo_global_int			 , sdo_acum_intper			 , monto_otorgado	,
		   provi_venc_normal , provi_venc_anticip, cap_tras_no_venci	 , mto_venc_int				 , mto_venc_tra_int			 , mto_finan_vdo	,
		   mto_reser_int	 , mto_fin_ven_trasp , mto_fin_vig_trasp	 , int_tra_no_exig			 ,sdo_trab4
	INTO
			eEmpresa			,eNumCredito		,svFechaUltMov			,svSdoIntAnticip		,svSdoIntAntDev				,svSdoIntereses
			,svSdoDiaAntInt		,svSdoMesAntInt		,svSdoAcumMesInt		,svSdoRetenido			,svSdoAcumCapInt			,svSdoExigInt				,svSdoNoExig
			,svProvisionNormal	,svDiasAcumInt		,svSdoMoratorio			,svSdoDiaAntMor			,svSdoMesAntMor				,svSdoContabMora			,svDiasAcumMora
			,svSdoCapital		,svSdoCapInsoluto	,svSdoDiaAntCap			,svSdoMesAntCap			,svSdoAcumMesCap			,svMtoCapitalizado			,svMtoMinistraCap
			,svCargosDiaCap		,svAbonosDiaCap		,svCargosMesCap			,svAbonosMesCap			,svDiasAcumCap				,svMontoVencido				,svMtoVencTrasp
			,svMontoFinanciado	,svMontoReservado	,svSdoAcumVencido		,svDiasAcumIntper		,svSdoGlobalInt				,svSdoAcumIntper			,svMontoOtorgado
			,svProviVencNormal	,svProviVencAnticip	,svCapTrasNoVenci		,svMtoVencInt			,svMtoVencTraInt			,svMtoFinanVdo				,svMtoReserInt
			,svMtoFinVenTrasp	,svMtoFinVigTrasp	,svIntTraNoExig			,svSdoTrab4
	FROM sd_maesdoscrd
	WHERE empresa = eEmpresa
	AND num_credito = eNumCredito;

	INSERT INTO sd_maesdoscrd_vendida(
			fecha				,empresa			,num_credito			,fecha_ult_mov			,sdo_int_anticip			,sdo_int_ant_dev			,sdo_intereses
			,sdo_dia_ant_int	,sdo_mes_ant_int	,sdo_acum_mes_int		,sdo_retenido			,sdo_acum_cap_int			,sdo_exig_int				,sdo_no_exig
			,provision_normal	,dias_acum_int		,sdo_moratorio			,sdo_dia_ant_mor		,sdo_mes_ant_mor			,sdo_contab_mora			,dias_acum_mora
			,sdo_capital		,sdo_cap_insoluto	,sdo_dia_ant_cap		,sdo_mes_ant_cap		,sdo_acum_mes_cap			,mto_capitalizado			,mto_ministra_cap
			,cargos_dia_cap		,abonos_dia_cap     ,cargos_mes_cap			,abonos_mes_cap			,dias_acum_cap				,monto_vencido				,mto_venc_trasp
			,monto_financiado	,monto_reservado	,sdo_acum_vencido		,dias_acum_intper		,sdo_global_int				,sdo_acum_intper			,monto_otorgado
			,provi_venc_normal	,provi_venc_anticip	,cap_tras_no_venci		,mto_venc_int			,mto_venc_tra_int			,mto_finan_vdo				,mto_reser_int
			,mto_fin_ven_trasp	,mto_fin_vig_trasp	,int_tra_no_exig		,sdo_trab4)
	VALUES	(eFecha				,eEmpresa			,eNumCredito			,svFechaUltMov			,svSdoIntAnticip			,svSdoIntAntDev				,svSdoIntereses
			,svSdoDiaAntInt		,svSdoMesAntInt		,svSdoAcumMesInt		,svSdoRetenido			,svSdoAcumCapInt			,svSdoExigInt				,svSdoNoExig
			,svProvisionNormal	,svDiasAcumInt		,svSdoMoratorio			,svSdoDiaAntMor			,svSdoMesAntMor				,svSdoContabMora			,svDiasAcumMora
			,svSdoCapital		,svSdoCapInsoluto	,svSdoDiaAntCap			,svSdoMesAntCap			,svSdoAcumMesCap			,svMtoCapitalizado			,svMtoMinistraCap
			,svCargosDiaCap		,svAbonosDiaCap		,svCargosMesCap			,svAbonosMesCap			,svDiasAcumCap				,svMontoVencido				,svMtoVencTrasp
			,svMontoFinanciado	,svMontoReservado	,svSdoAcumVencido		,svDiasAcumIntper		,svSdoGlobalInt				,svSdoAcumIntper			,svMontoOtorgado
			,svProviVencNormal	,svProviVencAnticip	,svCapTrasNoVenci		,svMtoVencInt			,svMtoVencTraInt			,svMtoFinanVdo				,svMtoReserInt
			,svMtoFinVenTrasp	,svMtoFinVigTrasp	,svIntTraNoExig			,svSdoTrab4);
	
	--**    Respalda AmortizaCreditocrd		--
	--INSERT INTO sd_amortiza_creditocrd_vendida
	FOREACH WITH HOLD
		SELECT empresa			  , e.num_credito	  	  , e.fecha_cuota			  , tipo_cuota			  , capital_mto_cuota	  ,
			   capital_debe		  , capital_pagado	  , capital_status		  , capital_status_ant	  , capital_fecha_pago	  , interes_debe		,
			   interes_pagado	  , interes_status	  , interes_status_ant	  , interes_fecha_pago	  , iva_debe		  	  , iva_pagado			,
			   iva_status		  , iva_status_ant	  , iva_fecha_pago	  	  , mora_provi_ordi	  	  , mora_provi_cope		  , mora_sdo_ordi		,
			   mora_sdo_ordi_pag  , mora_sdo_cope	  , mora_sdo_cope_pag 	  , mora_bonificado		  , mora_status			  , mora_iva_debe		,
			   mora_iva_pagado	  , mora_iva_status	  ,mora_iva_fecha_pago	  , num_pago			  , campo_trabajo1		  , campo_trabajo2		,
			   campo_trabajo3	  ,campo_trabajo4
		INTO
				eEmpresa			,eNumCredito		,avFechaCuota			,avTipoCuota			,avCapitalMtoCuota	,avCapitalDebe
				,avCapitalPagado	,avCapitalStatus	,avCapitalStatusAnt		,avCapitalFechaPago		,avInteresDebe		,avInteresPagado			,avInteresStatus
				,avInteresStatusAnt	,avInteresFechaPago	,avIvaDebe				,avIvaPagado			,avIvaStatus		,avIvaStatusAnt				,avIvaFechaPago
				,avMoraProviOrdi	,avMoraProviCope	,avMoraSdoOrdi			,avMoraSdoOrdiPag		,avMoraSdoCope		,avMoraSdoCopePag			,avMoraBonificado
				,avMoraStatus		,avMoraIvaDebe		,avMoraIvaPagado		,avMoraIvaStatus		,avMoraIvaFechaPago	,avNumPago					,avCampoTrabajo1
				,avCampoTrabajo2	,avCampoTrabajo3	,avCampoTrabajo4
		FROM sd_amortiza_creditocrd e
		WHERE empresa = eEmpresa
		AND e.num_credito = eNumCredito
			
		INSERT INTO sd_amortiza_creditocrd_vendida(
				fecha				,empresa			,num_credito			,fecha_cuota			,tipo_cuota			,capital_mto_cuota			,capital_debe
				,capital_pagado		,capital_status		,capital_status_ant		,capital_fecha_pago		,interes_debe		,interes_pagado				,interes_status
				,interes_status_ant	,interes_fecha_pago	,iva_debe				,iva_pagado				,iva_status			,iva_status_ant				,iva_fecha_pago
				,mora_provi_ordi	,mora_provi_cope	,mora_sdo_ordi			,mora_sdo_ordi_pag		,mora_sdo_cope		,mora_sdo_cope_pag			,mora_bonificado
				,mora_status		,mora_iva_debe		,mora_iva_pagado		,mora_iva_status		,mora_iva_fecha_pago,num_pago					,campo_trabajo1
				,campo_trabajo2		,campo_trabajo3		,campo_trabajo4)
		VALUES	(eFecha				,eEmpresa			,eNumCredito			,avFechaCuota			,avTipoCuota		,avCapitalMtoCuota			,avCapitalDebe
				,avCapitalPagado	,avCapitalStatus	,avCapitalStatusAnt		,avCapitalFechaPago		,avInteresDebe		,avInteresPagado			,avInteresStatus
				,avInteresStatusAnt	,avInteresFechaPago	,avIvaDebe				,avIvaPagado			,avIvaStatus		,avIvaStatusAnt				,avIvaFechaPago
				,avMoraProviOrdi	,avMoraProviCope	,avMoraSdoOrdi			,avMoraSdoOrdiPag		,avMoraSdoCope		,avMoraSdoCopePag			,avMoraBonificado
				,avMoraStatus		,avMoraIvaDebe		,avMoraIvaPagado		,avMoraIvaStatus		,avMoraIvaFechaPago	,avNumPago					,avCampoTrabajo1
				,avCampoTrabajo2	,avCampoTrabajo3	,avCampoTrabajo4);
	END FOREACH;
	RETURN CodRet;

END PROCEDURE;