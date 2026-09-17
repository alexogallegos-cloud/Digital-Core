CREATE PROCEDURE "informix".sp_ofi_consultasdos_mib(pEmpresa CHAR(3),pNumCredito CHAR(20),pSucursal CHAR(4))
RETURNING CHAR(5) AS Cod_Ret, 
	CHAR(80)  	  AS Mensaje_retorno,
	CHAR(20) 	  AS Num_credito,
	CHAR(4) 	  AS Nun_Producto,
	CHAR(40)      AS Producto,
	CHAR(20)      AS Num_cliente,
	CHAR(150)     AS Nom_cliente,
	MONEY(18,2)   AS Linea_otorgada,
	DATE          AS Fecha_origen,
	DECIMAL(18,2) AS saldo_ultimoCorte,
	MONEY(18,2)   AS Interes_moratorio,
	MONEY(18,2)   AS Iva_InteresMoratorio,
	MONEY(18,2)   AS Total_liquidacion,
	MONEY(18,2)   AS Pagos_vdos,
	INTEGER       AS pagos_realizados,
	INTEGER       AS plazo,
	DATE          AS Fecha_ProximoPago,
	MONEY(18,2)   AS Pago_minimo,
	MONEY(18,2)   AS Saldar,
	DECIMAL(18,2) AS Ahorro,
	MONEY(18,2)   As Deuda, 
--se agregan datos de intereres y comisiones
	MONEY(18,2)   AS Pago_Realizado,
	MONEY(18,2)   AS Interes_devengado,
	MONEY(18,2)   AS Iva_Interes_devengado,
	MONEY(18,2)   AS Comision,
	MONEY(18,2)   AS Iva_Comision,
	MONEY(18,2)   AS Monto_prox_pago,
	CHAR (60)     AS Status_Credito_Ant;
 	
--DECLARACIONES
DEFINE iSqlErr        		    INTEGER;
DEFINE iIsamErr       		    INTEGER;
DEFINE cErrorInfo      			CHAR(80);
DEFINE cCodRet         			CHAR(6);
DEFINE cMensajeRet   			CHAR(80);
DEFINE dSdoUltCorte				DECIMAL(18,2);
DEFINE dAhorroPago				DECIMAL(18,2);
DEFINE iFrecuenciaPago			INTEGER;
DEFINE mCapital		    		MONEY(18,2);
DEFINE mIva						MONEY(18,2); 
DEFINE mComisionesPendientes 	MONEY(18,2);
DEFINE mIvaComisionesPendientes MONEY(18,2); 
DEFINE dMontoMin				DECIMAL(18,6);DEFINE dMontoMax				DECIMAL(18,6);DEFINE dtFecha 			 		DATE;

DEFINE cCodRetCD		CHAR(6);   
DEFINE cMensajeCD 		CHAR(80); 
DEFINE cNumCredCD 		CHAR(20); 
DEFINE cNumCteCD 		CHAR(20);  
DEFINE cNomProductoCD	CHAR(40);
DEFINE cNumTarjetaCD    CHAR(20); 
DEFINE cNomCteCD     	CHAR(150);
DEFINE sDiacorte        SMALLINT;
DEFINE dFecha_MesIver   DATE;
DEFINE dFechaFactura    DATE;
	
--VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
DEFINE cCodigo_Ret			CHAR(6);
DEFINE cMensaje_Retorno		CHAR(80);
DEFINE cNum_Credito			CHAR(20);
DEFINE cCod_Tipcred			CHAR(2);
DEFINE dFecha_Origen		DATE;
DEFINE dFecha_Prox_Pago		DATE;
DEFINE mPago_Minimo			MONEY(18,2);
DEFINE dFecha_ultimo_Pago	DATE;
DEFINE iPlazo_Sg			INTEGER;
DEFINE iPagos_Realizados	INTEGER;
DEFINE mLinea_Otorgada		MONEY(18,2);
DEFINE dTasa_Interes		DECIMAL(9,6);
DEFINE dTasa_Moratorios		DECIMAL(9,6);
DEFINE dMonto_Sbc			DECIMAL(14,2);
DEFINE mCap_Vig				MONEY(18,2);
DEFINE mCap_Trans			MONEY(18,2);
DEFINE mCap_Vdo_Exig		MONEY(18,2);
DEFINE mCap_Vdo_NoExig		MONEY(18,2);
DEFINE mSdo_Act_TotalCap	MONEY(18,2);
DEFINE mInt_Vig				MONEY(18,2);
DEFINE mInt_Vdo				MONEY(18,2);
DEFINE mInt_Moratorios		MONEY(18,2);
DEFINE mInt_Mes				MONEY(18,2);
DEFINE mSdo_Act_TotalInt	MONEY(18,2);
DEFINE mIva_Int_Vig			MONEY(18,2);
DEFINE mIva_Int_Vdo			MONEY(18,2);
DEFINE mIva_Int_Moratorios	MONEY(18,2);
DEFINE mIva_Int_Mes			MONEY(18,2);
DEFINE mSdo_Act_Total_Iva	MONEY(18,2);
DEFINE mCom_Pend			MONEY(18,2);
DEFINE mIva_Com				MONEY(18,2);
DEFINE mSdo_Retenido		MONEY(18,2);
DEFINE mTotal_Liquidacion	MONEY(18,2);
DEFINE mInt_Devengado		MONEY(18,2);
DEFINE mIva_Int_Devengado	MONEY(18,2);
DEFINE mLinea_Disp			MONEY(18,2);
DEFINE mPagos_Vdos			MONEY(18,2);
DEFINE cDesc_Status_Cred	CHAR(60);
DEFINE iId_Bloqueo_Cred		INTEGER;
DEFINE cBloqueo_Cta			CHAR(60);
DEFINE cId_Causa_Bloq_Cred	CHAR(3);
DEFINE cCausa_Bloqueo_Cta	CHAR(50);
DEFINE cId_Sit_Esp_Cte		CHAR(1);
DEFINE iId_Causa_Esp_Cte	INTEGER;
DEFINE cSit_Esp_Cte			CHAR(75);
DEFINE cId_Sit_Esp_Cred		CHAR(1);
DEFINE iId_Causa_Esp_Cred	INTEGER;
DEFINE cSit_Esp_Cred		CHAR(75);
DEFINE dMto_Prox_Pago       DECIMAL(18,2);

--VARIABLES DEL PROCESO bdicred: sp_ofi_validacred
DEFINE cCodRet_vc 		CHAR(6);
DEFINE cMensajeRet_vc	CHAR(80);
DEFINE cNumProducto_vc  CHAR(4);
DEFINE cNomProducto_vc  CHAR(40);
DEFINE cNomCliente_vc	CHAR(40);
DEFINE cNumCte_vc 	    CHAR(20);  

DEFINE dAbonos_His          DECIMAL(18,2);
DEFINE dMora_His            DECIMAL(18,2);
DEFINE dIva_Mora_His        DECIMAL(18,2);
DEFINE dAbonos_Dia          DECIMAL(18,2);
DEFINE dMora_Dia            DECIMAL(18,2);
DEFINE dIva_Mora_Dia        DECIMAL(18,2);
DEFINE dInt_Vencido_His     DECIMAL(18,2);
DEFINE dIva_Int_Vencido_His DECIMAL(18,2); 
DEFINE dInt_Vencido_Dia     DECIMAL(18,2);
DEFINE dIva_Int_Vencido_Dia DECIMAL(18,2); 
DEFINE dFecha_Proceso       DATE;
DEFINE iPago_Mes            INTEGER;
DEFINE dTasas               DECIMAL(18,2); 
DEFINE dPago_Mes            DECIMAL(18,2);  

--INICIALIZACIONES
LET iSqlErr           		 = 0;
LET iIsamErr          		 = 0;
LET cErrorInfo        		 = '';
LET cMensajeRet       		 = 'PROCESO EXITOSO';
LET cCodRet           		 = '00000';
LET dSdoUltCorte	   		 = 0.0;
LET dAhorroPago		   		 = 0.0;
LET iFrecuenciaPago	  		 = 0;
LET mCapital	      		 = 0;
LET mIva			  		 = 0; 
LET mComisionesPendientes    = 0;
LET mIvaComisionesPendientes = 0;
LET dMontoMin				 = 0;
LET dMontoMax				 = 0;

LET cCodRetCD				 = '';
LET cMensajeCD 				 = '';
LET cNumCredCD 		 		 = '';
LET cNumCteCD 				 = '';
LET cNomProductoCD			 = '';
LET cNumTarjetaCD   		 = '';
LET cNomCteCD     			 = '';
	
--VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
LET cCodigo_Ret			= '00000';
LET cMensaje_Retorno	= '';
LET cNum_Credito		= '';
LET cCod_Tipcred		= '';
LET dFecha_Origen		= MDY(1,1,1900);
LET dFecha_Prox_Pago	= MDY(1,1,1900);
LET mPago_Minimo		= 0.0;
LET dFecha_ultimo_Pago	= MDY(1,1,1900);
LET iPlazo_Sg			= 0;
LET iPagos_Realizados	= 0;
LET mLinea_Otorgada		= 0.0;
LET dTasa_Interes		= 0.0;
LET dTasa_Moratorios	= 0.0;
LET dMonto_Sbc			= 0.0;
LET mCap_Vig			= 0.0;
LET mCap_Trans			= 0.0;
LET mCap_Vdo_Exig		= 0.0;
LET mCap_Vdo_NoExig		= 0.0;
LET mSdo_Act_TotalCap   = 0.0;
LET mInt_Vig			= 0.0;
LET mInt_Vdo			= 0.0;
LET mInt_Moratorios		= 0.0;
LET mInt_Mes			= 0.0;
LET mSdo_Act_TotalInt	= 0.0;
LET mIva_Int_Vig		= 0.0;
LET mIva_Int_Vdo		= 0.0;
LET mIva_Int_Moratorios	= 0.0;
LET mIva_Int_Mes		= 0.0;
LET mSdo_Act_Total_Iva	= 0.0;
LET mCom_Pend			= 0.0;
LET mIva_Com			= 0.0;
LET mSdo_Retenido		= 0.0;
LET mTotal_Liquidacion	= 0.0;
LET mInt_Devengado		= 0.0;
LET mIva_Int_Devengado	= 0.0;
LET mLinea_Disp			= 0.0;
LET mPagos_Vdos			= 0.0;
LET cDesc_Status_Cred	= '';
LET iId_Bloqueo_Cred	= 0;
LET cBloqueo_Cta		= '';
LET cId_Causa_Bloq_Cred	= '';
LET cCausa_Bloqueo_Cta	= '';
LET cId_Sit_Esp_Cte		= '';
LET iId_Causa_Esp_Cte	= 0;
LET cSit_Esp_Cte		= '';
LET cId_Sit_Esp_Cred	= '';
LET iId_Causa_Esp_Cred	= 0;
LET cSit_Esp_Cred		= '';
LET dMto_Prox_Pago      = 0;

--VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_ofi_validacred
LET cCodRet_vc 			 = '';
LET cMensajeRet_vc	  	 = '';
LET cNumProducto_vc	  	 = '';
LET cNomProducto_vc		 = '';
LET cNomCliente_vc		 = '';
LET cNumCte_vc			 = '';
LET dtFecha 			 = MDY(1,1,1900);
LET sDiacorte       	 = 0;
LET dFecha_MesIver       = DATE(1);
LET dFechaFactura        = DATE(1);
LET dAbonos_His          = 0;
LET dMora_His            = 0;
LET dIva_Mora_His        = 0;
LET dInt_Vencido_His     = 0;
LET dIva_Int_Vencido_His = 0;
LET dAbonos_Dia          = 0;
LET dMora_Dia            = 0;
LET dIva_Mora_Dia        = 0;
LET dInt_Vencido_Dia     = 0;
LET dIva_Int_Vencido_Dia = 0;
LET dFecha_Proceso       = DATE(1);
LET iPago_Mes            = 0;
LET dTasas               = 0;
LET dPago_Mes            = 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
		  LET cMensajeRet= cErrorInfo;
          RETURN cCodRet,cMensajeRet,'','','','','',0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,cDesc_Status_Cred;
       END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/home/tmp/leonardo/sp_ofi_consultasdos.out";
	--TRACE ON;
    
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	-- VALIDA LOS PARAMETROS DE ENTRADA
	IF NVL(pEmpresa,'') =  '' OR NVL(pNumCredito,'') = ''   OR NVL(pSucursal,'') = '' THEN
		LET cCodRet = '00361';
		LET cMensajeRet = 'PARAMETROS INVALIDOS';
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,cDesc_Status_Cred;
	END IF 
	
	-- OBTIENE LOS DATOS DEL PRESTAMO/REESTRUCTURA/CREDINOMINA
	EXECUTE PROCEDURE bdicred:"informix".sp_consulta_datos_general(pEmpresa, '',pNumCredito,'','','','')
	INTO cCodRetCD,cMensajeCD,cNumCredCD,cNumCteCD,cNomProductoCD,cNumTarjetaCD,cNomCteCD;
	IF cCodRetCD::INTEGER <> 0 THEN
		LET cCodRet = '00363';
		LET cMensajeRet= cMensajeCD;
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,cDesc_Status_Cred;
	END IF
	
	-- OBTIENE LOS SALDOS DEL  PRESTAMO/REESTRUCTURA/CREDINOMINA
	EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa,pNumCredito)
	INTO  cCodigo_Ret,cMensaje_Retorno,cNum_Credito,cCod_Tipcred,dFecha_Origen,dFecha_Prox_Pago,mPago_Minimo,dFecha_ultimo_Pago,iPlazo_Sg,iPagos_Realizados,mLinea_Otorgada,dTasa_Interes,dTasa_Moratorios,dMonto_Sbc,mCap_Vig,mCap_Trans,mCap_Vdo_Exig,mCap_Vdo_NoExig,mSdo_Act_TotalCap,mInt_Vig,mInt_Vdo,mInt_Moratorios,mInt_Mes,mSdo_Act_TotalInt,mIva_Int_Vig,mIva_Int_Vdo,mIva_Int_Moratorios,mIva_Int_Mes,mSdo_Act_Total_Iva,mCom_Pend,mIva_Com,mSdo_Retenido,mTotal_Liquidacion,mInt_Devengado,mIva_Int_Devengado,mLinea_Disp,mPagos_Vdos,cDesc_Status_Cred,iId_Bloqueo_Cred,cBloqueo_Cta,cId_Causa_Bloq_Cred,cCausa_Bloqueo_Cta,cId_Sit_Esp_Cte,iId_Causa_Esp_Cte,cSit_Esp_Cte,cId_Sit_Esp_Cred,iId_Causa_Esp_Cred,cSit_Esp_Cred;
	IF cCodigo_Ret::INTEGER <> 0 THEN
		LET cCodRet = '00364';
		LET cMensajeRet= cMensaje_Retorno;
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,cDesc_Status_Cred;
	END IF
	
	--se obtiene el iva de la sucursal	
	SELECT iva  
	INTO mIva
	FROM bdinteg:"informix".si_sucursales 
	WHERE sucursal = pSucursal;

	--se obtiene el iva de la sucursal	
	SELECT NVL(dia_corte::SMALLINT,0)
	INTO sDiacorte
	FROM bdicred:"informix".sd_maecredanexocrd
    WHERE empresa = pEmpresa
    AND num_credito = pNumCredito;
	
    EXECUTE PROCEDURE bdicred:"informix".sp_fecha_plazo(pEmpresa,sDiacorte)
    INTO cCodRet, dFecha_MesIver, dFechaFactura;

    IF (cCodRet <> '00000') THEN
		LET cCodRet = '00361';
		LET cMensajeRet= 'PARAMETROS INVALIDOS';
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,cDesc_Status_Cred;
    END IF;
	
	-- OBTENER EL SALDO AL ULTIMO CORTE
	SELECT sdo_cap_insoluto + -- capital_total_corte,
           sdo_no_exig + -- interes_vigente_corte, 
           mto_finan_vdo + --iva_vigente_corte,  
           int_tra_no_exig + -- interes_vencido_corte, 
           mto_venc_int, -- iva_vencido_corte, 
		-- round((sdo_contab_mora + sdo_moratorio) * (1 + dIva::float),2), -- moratorio_corte
            fecha
    INTO dSdoUltCorte,dtFecha
    FROM bdicred:"informix".sd_maesdoshistcrd h
    WHERE h.empresa = pEmpresa
    AND h.num_credito = pNumCredito
    AND h.fecha  = dFechaFactura;

	-- se agrega el total vencido de la cuenta    
    LET mCap_Vdo_Exig = mCap_Vdo_Exig + mCap_Trans + mInt_Vdo + mIva_Int_Vdo + mInt_Moratorios + mIva_Int_Moratorios;

    SELECT NVL(capital_mto_cuota,0)
    INTO mCap_Vdo_Exig
    FROM bdicred:"informix".sd_amortiza_creditocrd a
    WHERE empresa = pEmpresa
    AND num_credito = pNumCredito
    AND num_pago = 1;

    SELECT  NVL(SUM(CASE WHEN codigo_ref = 1 AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0), --MENOS SUS ABONOS
            NVL(SUM(CASE WHEN codigo_ref = 2 AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0), --INTERES MORATORIO
            NVL(SUM(CASE WHEN codigo_ref = 3 AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0), --IVA INTERES MORATORIO
            NVL(SUM(CASE WHEN codigo_ref = 30 AND codigo_fun = '221' AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0),--INTERES VENCIODO
            NVL(SUM(CASE WHEN codigo_ref = 45 AND codigo_fun = '221' AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0) --IVA INTERES VENCIDO
    INTO dAbonos_His, dMora_His, dIva_Mora_His, dInt_Vencido_His, dIva_Int_Vencido_His
    FROM bdicred:"informix".sd_movhiscrd a
    WHERE empresa = pEmpresa
    AND num_credito = pNumCredito
	--AND fecha_mov > dFecha_MesIver
    AND fecha_mov  in (today - 1, today - 2, today - 3, today - 4, today - 5, today - 6, today - 7, today - 8, today - 9, today  - 10, today - 11, today - 12, today - 13, today - 14, today - 15, today - 16, 
    today - 17, today -18, today - 19, today - 20, today - 21, today - 22, today - 23, today - 24, today - 25, today  - 26, today - 27, today - 28, today - 29, today - 30, today - 31)
    AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanualcrd)
    AND reversado = 'N';

    SELECT  NVL(SUM(CASE WHEN codigo_ref = 1 AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0), --MENOS SUS ABONOS
            NVL(SUM(CASE WHEN codigo_ref = 2 AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0), --INTERES MORATORIO
            NVL(SUM(CASE WHEN codigo_ref = 3 AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0), --IVA INTERES MORATORIO
            NVL(SUM(CASE WHEN codigo_ref = 30 AND codigo_fun = '221' AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0),--INTERES VENCIODO
            NVL(SUM(CASE WHEN codigo_ref = 45 AND codigo_fun = '221' AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0) --IVA INTERES VENCIDO
    INTO dAbonos_Dia, dMora_Dia, dIva_Mora_Dia, dInt_Vencido_Dia, dIva_Int_Vencido_Dia
    FROM bdicred:"informix".sd_movdiacrd a
    WHERE empresa = pEmpresa
    AND num_credito = pNumCredito
	--AND fecha_mov > dFecha_MesIver
    AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanualcrd)
    AND reversado = 'N';

	LET dAbonos_His = dAbonos_His + dAbonos_Dia;
	LET mInt_Moratorios = mInt_Moratorios + dMora_His + dMora_Dia;
	LET mIva_Int_Moratorios = mIva_Int_Moratorios + dIva_Mora_His + dIva_Mora_Dia;
	LET mInt_Devengado = mInt_Devengado  + dInt_Vencido_His + dInt_Vencido_Dia;
	LET mIva_Int_Devengado = mIva_Int_Devengado + dIva_Int_Vencido_His + dIva_Int_Vencido_Dia;

	--se obtienen las comisiones pendientes
	SELECT NVL(SUM(DECODE(tc.comi_o_seg, '1', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0) + NVL(SUM(DECODE(tc.comi_o_seg, '4', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0)
	INTO  mComisionesPendientes
	FROM  bdicred:"informix".sd_detcomi dc,
	      bdicred:"informix".sd_tpcomis tc   
	WHERE dc.num_credito = pNumCredito
	AND dc.fecha_alta = dtFecha
	AND dc.estado_com  = 'A'   
	AND dc.cod_comis   = tc.cod_comis 
	AND tc.comi_o_seg IN ('1','4');			
	
	LET mIvaComisionesPendientes = mComisionesPendientes * mIva;
	LET dSdoUltCorte = NVL(dSdoUltCorte,0) + NVL(mComisionesPendientes,0) + NVL(mIvaComisionesPendientes,0);

	--se obtiene el numero de producto del credito
	EXECUTE PROCEDURE bdicred:"informix".sp_ofi_validacred(pEmpresa,pNumCredito) 
	INTO cCodRet_vc,cMensajeRet_vc,cNumProducto_vc,cNomProducto_vc,cNomCliente_vc,cNumCte_vc;

	IF cCodRet_vc::INTEGER <> 0 THEN
		LET cCodRet = '00362';
		LET cMensajeRet= cMensajeRet_vc;
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,cDesc_Status_Cred;
	END IF
	--Se obtiene los parametros que se le enviaran a la proyeccion
	--se obtiene la frecuencia de pago, 
	SELECT tp_dias_fecha_pago, fecha_proceso--, plazo
	INTO iFrecuenciaPago,dFecha_Proceso--, iPlazo
	FROM bdicred:"informix".sd_maecredanexocrd
	WHERE empresa = pEmpresa
	AND num_credito = pNumCredito;

	--Se calcula el importe de ahorro
	SELECT NVL(num_pago,0)
	INTO iPago_Mes
	FROM bdicred:"informix".sd_amortiza_creditocrd
	WHERE empresa = pEmpresa
	AND FECHA_CUOTA = dFecha_MesIver
	AND num_credito = pNumCredito;

	IF ( iPago_Mes > 0 AND iPago_Mes < iPlazo_Sg AND (mCap_Vig + mCap_Vdo_NoExig) > 0 ) THEN
		LET iPagos_Realizados = iPago_Mes + 1;
		
		IF dTasa_Interes > 0 THEN
			LET dTasas = POW((1 + (((dTasa_Interes / 100) * (1+mIva)) / 12)), (iPlazo_Sg - iPago_Mes));
			LET dPago_Mes = (mCap_Vig + mCap_Vdo_NoExig) * (((((dTasa_Interes / 100) * (1+mIva)) / 12) * dTasas) / (dTasas - 1));
			
			LET dAhorroPago = (dPago_Mes * (iPlazo_Sg - iPago_Mes)) - (mCap_Vig + mCap_Vdo_NoExig);
			LET dAhorroPago = dAhorroPago - NVL(mInt_Devengado,0) - NVL(mIva_Int_Devengado,0);
		ELSE 
			LET dAhorroPago = 0;
		    --LET dPago_Mes = (mCap_Vig + mCap_Vdo_NoExig);			
		END IF;		
		
		IF dAhorroPago < 0 THEN 
			LET dAhorroPago = 0;
		END IF;
	ELSE
		LET dAhorroPago = 0;
		LET iPagos_Realizados = 0;
	END IF;

	--se le manda a la proyeccion el saldo capital vigente o no exigible		
	LET mCapital=mCap_Vig+mCap_Trans;
	--se obtiene la mensualidad del cliente 	
	SELECT capital_mto_cuota
	INTO dMto_Prox_Pago
	FROM bdicred:"informix".sd_amortiza_creditocrd 
	WHERE empresa = pEmpresa 
	AND num_credito = pNumCredito 
	AND num_pago = 1;
    
	--valida si es posible realizar la proyeccion
    --si no  debe capital, no se proyecta.
	SELECT monto_min_cred, monto_max_cred
	INTO dMontoMin, dMontoMax
	FROM bdicred:"informix".sd_definicion
	WHERE num_producto = cNumProducto_vc
	AND empresa = pEmpresa;

	RETURN cCodRet,cMensajeRet,NVL(pNumCredito,''),NVL(cNumProducto_vc,''),NVL(cNomProductoCD,''),NVL(cNumCteCD,''),NVL(cNomCteCD,''),NVL(mLinea_Otorgada,0), NVL(dFecha_Origen,''),NVL(dSdoUltCorte,0),NVL(mInt_Moratorios,0),NVL(mIva_Int_Moratorios,0),NVL(mTotal_Liquidacion,0),NVL(mCap_Vdo_Exig,0),NVL(iPagos_Realizados,0),NVL(iPlazo_Sg,0),NVL(dFecha_Prox_Pago,''),NVL(mPago_Minimo,0),NVL(mTotal_Liquidacion,0), NVL(dAhorroPago,0),NVL(mTotal_Liquidacion,0), NVL(dAbonos_His,0),NVL(mInt_Devengado,0),NVL(mIva_Int_Devengado,0),NVL(mCom_Pend,0),NVL(mIva_Com,0),NVL(dMto_Prox_Pago,0),NVL(cDesc_Status_Cred, '');

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para consultar la informacion del prestamo', 
'AUTOR: Mohamed Carreón, Jesús Aguilar ',
'FECHA: 29 Abril 2011',
'BD: BDICRED',
'VERSION: 20110429.1641',
'DESCRIPCION: Se modifica llamado de procedimiento (sp_proyecta_prestamos) utilizado para obtener el total del ahorro, para no contemplar la frecuencia de pago', 
'AUTOR: Jesús Aguilar ',
'FECHA: 24 Agosto 2011',
'BD: BDICRED',
'VERSION: 20110824.1741',
'DESCRIPCION: Se agrega numero de producto como retorno', 
'AUTOR: Felipe Urias ',
'FECHA: 05 Agosto 2013',
'Folio: 1580',
'AUTOR : 95594213',
'FECHA : 29/01/2014',
'MODIFICACIÓN: Se modifica sp_ofi_consultasdos agregandole un retorno status anterior del credito obtenido del sp_consulta_saldos_general',
'SUSTENTO: RQM_09-338_Depósito_personal_cobranzav3.1.pdf',
'SOLICITA: Rodolfo Gomez',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_ofi_consultasdos_2(pEmpresa CHAR(3),pNumCredito CHAR(20),pSucursal CHAR(4))
RETURNING CHAR(5) AS Cod_Ret, 
	CHAR(80)  	  AS Mensaje_retorno,
	CHAR(20) 	  AS Num_credito,
	CHAR(4) 	  AS Nun_Producto,
	CHAR(40)      AS Producto,
	CHAR(20)      AS Num_cliente,
	CHAR(150)     AS Nom_cliente,
	MONEY(18,2)   AS Linea_otorgada,
	DATE          AS Fecha_origen,
	DECIMAL(18,2) AS saldo_ultimoCorte,
	MONEY(18,2)   AS Interes_moratorio,
	MONEY(18,2)   AS Iva_InteresMoratorio,
	MONEY(18,2)   AS Total_liquidacion,
	MONEY(18,2)   AS Pagos_vdos,
	INTEGER       AS pagos_realizados,
	INTEGER       AS plazo,
	DATE          AS Fecha_ProximoPago,
	MONEY(18,2)   AS Pago_minimo,
	MONEY(18,2)   AS Saldar,
	DECIMAL(18,2) AS Ahorro,
	MONEY(18,2)   As Deuda, 
--se agregan datos de intereres y comisiones
	MONEY(18,2)   AS Pago_Realizado,
	MONEY(18,2)   AS Interes_devengado,
	MONEY(18,2)   AS Iva_Interes_devengado,
	MONEY(18,2)   AS Comision,
	MONEY(18,2)   AS Iva_Comision,
	MONEY(18,2)   AS Monto_prox_pago,
	CHAR (60)     AS Status_Credito_Ant;
 	
--DECLARACIONES
DEFINE iSqlErr        		    INTEGER;
DEFINE iIsamErr       		    INTEGER;
DEFINE cErrorInfo      			CHAR(80);
DEFINE cCodRet         			CHAR(6);
DEFINE cMensajeRet   			CHAR(80);
DEFINE dSdoUltCorte				DECIMAL(18,2);
DEFINE dAhorroPago				DECIMAL(18,2);
DEFINE iFrecuenciaPago			INTEGER;
DEFINE mCapital		    		MONEY(18,2);
DEFINE mIva						MONEY(18,2); 
DEFINE mComisionesPendientes 	MONEY(18,2);
DEFINE mIvaComisionesPendientes MONEY(18,2); 
DEFINE dMontoMin				DECIMAL(18,6);DEFINE dMontoMax				DECIMAL(18,6);DEFINE dtFecha 			 		DATE;

DEFINE cCodRetCD		CHAR(6);   
DEFINE cMensajeCD 		CHAR(80); 
DEFINE cNumCredCD 		CHAR(20); 
DEFINE cNumCteCD 		CHAR(20);  
DEFINE cNomProductoCD	CHAR(40);
DEFINE cNumTarjetaCD    CHAR(20); 
DEFINE cNomCteCD     	CHAR(150);
DEFINE sDiacorte        SMALLINT;
DEFINE dFecha_MesIver   DATE;
DEFINE dFechaFactura    DATE;
	
--VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
DEFINE cCodigo_Ret			CHAR(6);
DEFINE cMensaje_Retorno		CHAR(80);
DEFINE cNum_Credito			CHAR(20);
DEFINE cCod_Tipcred			CHAR(2);
DEFINE dFecha_Origen		DATE;
DEFINE dFecha_Prox_Pago		DATE;
DEFINE mPago_Minimo			MONEY(18,2);
DEFINE dFecha_ultimo_Pago	DATE;
DEFINE iPlazo_Sg			INTEGER;
DEFINE iPagos_Realizados	INTEGER;
DEFINE mLinea_Otorgada		MONEY(18,2);
DEFINE dTasa_Interes		DECIMAL(9,6);
DEFINE dTasa_Moratorios		DECIMAL(9,6);
DEFINE dMonto_Sbc			DECIMAL(14,2);
DEFINE mCap_Vig				MONEY(18,2);
DEFINE mCap_Trans			MONEY(18,2);
DEFINE mCap_Vdo_Exig		MONEY(18,2);
DEFINE mCap_Vdo_NoExig		MONEY(18,2);
DEFINE mSdo_Act_TotalCap	MONEY(18,2);
DEFINE mInt_Vig				MONEY(18,2);
DEFINE mInt_Vdo				MONEY(18,2);
DEFINE mInt_Moratorios		MONEY(18,2);
DEFINE mInt_Mes				MONEY(18,2);
DEFINE mSdo_Act_TotalInt	MONEY(18,2);
DEFINE mIva_Int_Vig			MONEY(18,2);
DEFINE mIva_Int_Vdo			MONEY(18,2);
DEFINE mIva_Int_Moratorios	MONEY(18,2);
DEFINE mIva_Int_Mes			MONEY(18,2);
DEFINE mSdo_Act_Total_Iva	MONEY(18,2);
DEFINE mCom_Pend			MONEY(18,2);
DEFINE mIva_Com				MONEY(18,2);
DEFINE mSdo_Retenido		MONEY(18,2);
DEFINE mTotal_Liquidacion	MONEY(18,2);
DEFINE mInt_Devengado		MONEY(18,2);
DEFINE mIva_Int_Devengado	MONEY(18,2);
DEFINE mLinea_Disp			MONEY(18,2);
DEFINE mPagos_Vdos			MONEY(18,2);
DEFINE cDesc_Status_Cred	CHAR(60);
DEFINE iId_Bloqueo_Cred		INTEGER;
DEFINE cBloqueo_Cta			CHAR(60);
DEFINE cId_Causa_Bloq_Cred	CHAR(3);
DEFINE cCausa_Bloqueo_Cta	CHAR(50);
DEFINE cId_Sit_Esp_Cte		CHAR(1);
DEFINE iId_Causa_Esp_Cte	INTEGER;
DEFINE cSit_Esp_Cte			CHAR(75);
DEFINE cId_Sit_Esp_Cred		CHAR(1);
DEFINE iId_Causa_Esp_Cred	INTEGER;
DEFINE cSit_Esp_Cred		CHAR(75);
DEFINE dMto_Prox_Pago       DECIMAL(18,2);

--VARIABLES DEL PROCESO bdicred: sp_ofi_validacred
DEFINE cCodRet_vc 		CHAR(6);
DEFINE cMensajeRet_vc	CHAR(80);
DEFINE cNumProducto_vc  CHAR(4);
DEFINE cNomProducto_vc  CHAR(40);
DEFINE cNomCliente_vc	CHAR(40);
DEFINE cNumCte_vc 	    CHAR(20);  

DEFINE dAbonos_His          DECIMAL(18,2);
DEFINE dMora_His            DECIMAL(18,2);
DEFINE dIva_Mora_His        DECIMAL(18,2);
DEFINE dAbonos_Dia          DECIMAL(18,2);
DEFINE dMora_Dia            DECIMAL(18,2);
DEFINE dIva_Mora_Dia        DECIMAL(18,2);
DEFINE dInt_Vencido_His     DECIMAL(18,2);
DEFINE dIva_Int_Vencido_His DECIMAL(18,2); 
DEFINE dInt_Vencido_Dia     DECIMAL(18,2);
DEFINE dIva_Int_Vencido_Dia DECIMAL(18,2); 
DEFINE dFecha_Proceso       DATE;
DEFINE iPago_Mes            INTEGER;
DEFINE dTasas               DECIMAL(18,2); 
DEFINE dPago_Mes            DECIMAL(18,2);  

--INICIALIZACIONES
LET iSqlErr           		 = 0;
LET iIsamErr          		 = 0;
LET cErrorInfo        		 = '';
LET cMensajeRet       		 = 'PROCESO EXITOSO';
LET cCodRet           		 = '00000';
LET dSdoUltCorte	   		 = 0.0;
LET dAhorroPago		   		 = 0.0;
LET iFrecuenciaPago	  		 = 0;
LET mCapital	      		 = 0;
LET mIva			  		 = 0; 
LET mComisionesPendientes    = 0;
LET mIvaComisionesPendientes = 0;
LET dMontoMin				 = 0;
LET dMontoMax				 = 0;

LET cCodRetCD				 = '';
LET cMensajeCD 				 = '';
LET cNumCredCD 		 		 = '';
LET cNumCteCD 				 = '';
LET cNomProductoCD			 = '';
LET cNumTarjetaCD   		 = '';
LET cNomCteCD     			 = '';
	
--VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
LET cCodigo_Ret			= '00000';
LET cMensaje_Retorno	= '';
LET cNum_Credito		= '';
LET cCod_Tipcred		= '';
LET dFecha_Origen		= MDY(1,1,1900);
LET dFecha_Prox_Pago	= MDY(1,1,1900);
LET mPago_Minimo		= 0.0;
LET dFecha_ultimo_Pago	= MDY(1,1,1900);
LET iPlazo_Sg			= 0;
LET iPagos_Realizados	= 0;
LET mLinea_Otorgada		= 0.0;
LET dTasa_Interes		= 0.0;
LET dTasa_Moratorios	= 0.0;
LET dMonto_Sbc			= 0.0;
LET mCap_Vig			= 0.0;
LET mCap_Trans			= 0.0;
LET mCap_Vdo_Exig		= 0.0;
LET mCap_Vdo_NoExig		= 0.0;
LET mSdo_Act_TotalCap   = 0.0;
LET mInt_Vig			= 0.0;
LET mInt_Vdo			= 0.0;
LET mInt_Moratorios		= 0.0;
LET mInt_Mes			= 0.0;
LET mSdo_Act_TotalInt	= 0.0;
LET mIva_Int_Vig		= 0.0;
LET mIva_Int_Vdo		= 0.0;
LET mIva_Int_Moratorios	= 0.0;
LET mIva_Int_Mes		= 0.0;
LET mSdo_Act_Total_Iva	= 0.0;
LET mCom_Pend			= 0.0;
LET mIva_Com			= 0.0;
LET mSdo_Retenido		= 0.0;
LET mTotal_Liquidacion	= 0.0;
LET mInt_Devengado		= 0.0;
LET mIva_Int_Devengado	= 0.0;
LET mLinea_Disp			= 0.0;
LET mPagos_Vdos			= 0.0;
LET cDesc_Status_Cred	= '';
LET iId_Bloqueo_Cred	= 0;
LET cBloqueo_Cta		= '';
LET cId_Causa_Bloq_Cred	= '';
LET cCausa_Bloqueo_Cta	= '';
LET cId_Sit_Esp_Cte		= '';
LET iId_Causa_Esp_Cte	= 0;
LET cSit_Esp_Cte		= '';
LET cId_Sit_Esp_Cred	= '';
LET iId_Causa_Esp_Cred	= 0;
LET cSit_Esp_Cred		= '';
LET dMto_Prox_Pago      = 0;

--VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_ofi_validacred
LET cCodRet_vc 			 = '';
LET cMensajeRet_vc	  	 = '';
LET cNumProducto_vc	  	 = '';
LET cNomProducto_vc		 = '';
LET cNomCliente_vc		 = '';
LET cNumCte_vc			 = '';
LET dtFecha 			 = MDY(1,1,1900);
LET sDiacorte       	 = 0;
LET dFecha_MesIver       = DATE(1);
LET dFechaFactura        = DATE(1);
LET dAbonos_His          = 0;
LET dMora_His            = 0;
LET dIva_Mora_His        = 0;
LET dInt_Vencido_His     = 0;
LET dIva_Int_Vencido_His = 0;
LET dAbonos_Dia          = 0;
LET dMora_Dia            = 0;
LET dIva_Mora_Dia        = 0;
LET dInt_Vencido_Dia     = 0;
LET dIva_Int_Vencido_Dia = 0;
LET dFecha_Proceso       = DATE(1);
LET iPago_Mes            = 0;
LET dTasas               = 0;
LET dPago_Mes            = 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
		  LET cMensajeRet= cErrorInfo;
          RETURN cCodRet,cMensajeRet,'','','','','',0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,cDesc_Status_Cred;
       END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/home/tmp/leonardo/sp_ofi_consultasdos.out";
	--TRACE ON;
    
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	-- VALIDA LOS PARAMETROS DE ENTRADA
	IF NVL(pEmpresa,'') =  '' OR NVL(pNumCredito,'') = ''   OR NVL(pSucursal,'') = '' THEN
		LET cCodRet = '00361';
		LET cMensajeRet = 'PARAMETROS INVALIDOS';
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,cDesc_Status_Cred;
	END IF 
	
	-- OBTIENE LOS DATOS DEL PRESTAMO/REESTRUCTURA/CREDINOMINA
	EXECUTE PROCEDURE bdicred:"informix".sp_consulta_datos_general(pEmpresa, '',pNumCredito,'','','','')
	INTO cCodRetCD,cMensajeCD,cNumCredCD,cNumCteCD,cNomProductoCD,cNumTarjetaCD,cNomCteCD;
	IF cCodRetCD::INTEGER <> 0 THEN
		LET cCodRet = '00363';
		LET cMensajeRet= cMensajeCD;
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,cDesc_Status_Cred;
	END IF
	
	-- OBTIENE LOS SALDOS DEL  PRESTAMO/REESTRUCTURA/CREDINOMINA
	EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa,pNumCredito)
	INTO  cCodigo_Ret,cMensaje_Retorno,cNum_Credito,cCod_Tipcred,dFecha_Origen,dFecha_Prox_Pago,mPago_Minimo,dFecha_ultimo_Pago,iPlazo_Sg,iPagos_Realizados,mLinea_Otorgada,dTasa_Interes,dTasa_Moratorios,dMonto_Sbc,mCap_Vig,mCap_Trans,mCap_Vdo_Exig,mCap_Vdo_NoExig,mSdo_Act_TotalCap,mInt_Vig,mInt_Vdo,mInt_Moratorios,mInt_Mes,mSdo_Act_TotalInt,mIva_Int_Vig,mIva_Int_Vdo,mIva_Int_Moratorios,mIva_Int_Mes,mSdo_Act_Total_Iva,mCom_Pend,mIva_Com,mSdo_Retenido,mTotal_Liquidacion,mInt_Devengado,mIva_Int_Devengado,mLinea_Disp,mPagos_Vdos,cDesc_Status_Cred,iId_Bloqueo_Cred,cBloqueo_Cta,cId_Causa_Bloq_Cred,cCausa_Bloqueo_Cta,cId_Sit_Esp_Cte,iId_Causa_Esp_Cte,cSit_Esp_Cte,cId_Sit_Esp_Cred,iId_Causa_Esp_Cred,cSit_Esp_Cred;
	IF cCodigo_Ret::INTEGER <> 0 THEN
		LET cCodRet = '00364';
		LET cMensajeRet= cMensaje_Retorno;
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,cDesc_Status_Cred;
	END IF
	
	--se obtiene el iva de la sucursal	
	SELECT iva  
	INTO mIva
	FROM bdinteg:"informix".si_sucursales 
	WHERE sucursal = pSucursal;

	--se obtiene el iva de la sucursal	
	SELECT NVL(dia_corte::SMALLINT,0)
	INTO sDiacorte
	FROM bdicred:"informix".sd_maecredanexocrd
    WHERE empresa = pEmpresa
    AND num_credito = pNumCredito;
	
    EXECUTE PROCEDURE bdicred:"informix".sp_fecha_plazo(pEmpresa,sDiacorte)
    INTO cCodRet, dFecha_MesIver, dFechaFactura;

    IF (cCodRet <> '00000') THEN
		LET cCodRet = '00361';
		LET cMensajeRet= 'PARAMETROS INVALIDOS';
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,cDesc_Status_Cred;
    END IF;
	
	-- OBTENER EL SALDO AL ULTIMO CORTE
	SELECT sdo_cap_insoluto + -- capital_total_corte,
           sdo_no_exig + -- interes_vigente_corte, 
           mto_finan_vdo + --iva_vigente_corte,  
           int_tra_no_exig + -- interes_vencido_corte, 
           mto_venc_int, -- iva_vencido_corte, 
		-- round((sdo_contab_mora + sdo_moratorio) * (1 + dIva::float),2), -- moratorio_corte
            fecha
    INTO dSdoUltCorte,dtFecha
    FROM bdicred:"informix".sd_maesdoshistcrd h
    WHERE h.empresa = pEmpresa
    AND h.num_credito = pNumCredito
    AND h.fecha  = dFechaFactura;

	-- se agrega el total vencido de la cuenta    
    LET mCap_Vdo_Exig = mCap_Vdo_Exig + mCap_Trans + mInt_Vdo + mIva_Int_Vdo + mInt_Moratorios + mIva_Int_Moratorios;

    SELECT NVL(capital_mto_cuota,0)
    INTO mCap_Vdo_Exig
    FROM bdicred:"informix".sd_amortiza_creditocrd a
    WHERE empresa = pEmpresa
    AND num_credito = pNumCredito
    AND num_pago = 1;

    SELECT  NVL(SUM(CASE WHEN codigo_ref = 1 AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0), --MENOS SUS ABONOS
            NVL(SUM(CASE WHEN codigo_ref = 2 AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0), --INTERES MORATORIO
            NVL(SUM(CASE WHEN codigo_ref = 3 AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0), --IVA INTERES MORATORIO
            NVL(SUM(CASE WHEN codigo_ref = 30 AND codigo_fun = '221' AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0),--INTERES VENCIODO
            NVL(SUM(CASE WHEN codigo_ref = 45 AND codigo_fun = '221' AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0) --IVA INTERES VENCIDO
    INTO dAbonos_His, dMora_His, dIva_Mora_His, dInt_Vencido_His, dIva_Int_Vencido_His
    FROM bdicred:"informix".sd_movhiscrd a
    WHERE empresa = pEmpresa
    AND num_credito = pNumCredito
	--AND fecha_mov > dFecha_MesIver
    AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanualcrd)
    AND reversado = 'N';

    SELECT  NVL(SUM(CASE WHEN codigo_ref = 1 AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0), --MENOS SUS ABONOS
            NVL(SUM(CASE WHEN codigo_ref = 2 AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0), --INTERES MORATORIO
            NVL(SUM(CASE WHEN codigo_ref = 3 AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0), --IVA INTERES MORATORIO
            NVL(SUM(CASE WHEN codigo_ref = 30 AND codigo_fun = '221' AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0),--INTERES VENCIODO
            NVL(SUM(CASE WHEN codigo_ref = 45 AND codigo_fun = '221' AND fecha_mov > dFecha_MesIver THEN monto ELSE 0 END),0) --IVA INTERES VENCIDO
    INTO dAbonos_Dia, dMora_Dia, dIva_Mora_Dia, dInt_Vencido_Dia, dIva_Int_Vencido_Dia
    FROM bdicred:"informix".sd_movdiacrd a
    WHERE empresa = pEmpresa
    AND num_credito = pNumCredito
	--AND fecha_mov > dFecha_MesIver
    AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanualcrd)
    AND reversado = 'N';

	LET dAbonos_His = dAbonos_His + dAbonos_Dia;
	LET mInt_Moratorios = mInt_Moratorios + dMora_His + dMora_Dia;
	LET mIva_Int_Moratorios = mIva_Int_Moratorios + dIva_Mora_His + dIva_Mora_Dia;
	LET mInt_Devengado = mInt_Devengado  + dInt_Vencido_His + dInt_Vencido_Dia;
	LET mIva_Int_Devengado = mIva_Int_Devengado + dIva_Int_Vencido_His + dIva_Int_Vencido_Dia;

	--se obtienen las comisiones pendientes
	SELECT NVL(SUM(DECODE(tc.comi_o_seg, '1', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0) + NVL(SUM(DECODE(tc.comi_o_seg, '4', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0)
	INTO  mComisionesPendientes
	FROM  bdicred:"informix".sd_detcomi dc,
	      bdicred:"informix".sd_tpcomis tc   
	WHERE dc.num_credito = pNumCredito
	AND dc.fecha_alta = dtFecha
	AND dc.estado_com  = 'A'   
	AND dc.cod_comis   = tc.cod_comis 
	AND tc.comi_o_seg IN ('1','4');			
	
	LET mIvaComisionesPendientes = mComisionesPendientes * mIva;
	LET dSdoUltCorte = NVL(dSdoUltCorte,0) + NVL(mComisionesPendientes,0) + NVL(mIvaComisionesPendientes,0);

	--se obtiene el numero de producto del credito
	EXECUTE PROCEDURE bdicred:"informix".sp_ofi_validacred(pEmpresa,pNumCredito) 
	INTO cCodRet_vc,cMensajeRet_vc,cNumProducto_vc,cNomProducto_vc,cNomCliente_vc,cNumCte_vc;

	IF cCodRet_vc::INTEGER <> 0 THEN
		LET cCodRet = '00362';
		LET cMensajeRet= cMensajeRet_vc;
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,cDesc_Status_Cred;
	END IF
	--Se obtiene los parametros que se le enviaran a la proyeccion
	--se obtiene la frecuencia de pago, 
	SELECT tp_dias_fecha_pago, fecha_proceso--, plazo
	INTO iFrecuenciaPago,dFecha_Proceso--, iPlazo
	FROM bdicred:"informix".sd_maecredanexocrd
	WHERE empresa = pEmpresa
	AND num_credito = pNumCredito;

	--Se calcula el importe de ahorro
	SELECT NVL(num_pago,0)
	INTO iPago_Mes
	FROM bdicred:"informix".sd_amortiza_creditocrd
	WHERE empresa = pEmpresa
	AND FECHA_CUOTA = dFecha_MesIver
	AND num_credito = pNumCredito;

	IF ( iPago_Mes > 0 AND iPago_Mes < iPlazo_Sg AND (mCap_Vig + mCap_Vdo_NoExig) > 0 ) THEN
		LET iPagos_Realizados = iPago_Mes + 1;
		
		IF dTasa_Interes > 0 THEN
			LET dTasas = POW((1 + (((dTasa_Interes / 100) * (1+mIva)) / 12)), (iPlazo_Sg - iPago_Mes));
			LET dPago_Mes = (mCap_Vig + mCap_Vdo_NoExig) * (((((dTasa_Interes / 100) * (1+mIva)) / 12) * dTasas) / (dTasas - 1));
			
			LET dAhorroPago = (dPago_Mes * (iPlazo_Sg - iPago_Mes)) - (mCap_Vig + mCap_Vdo_NoExig);
			LET dAhorroPago = dAhorroPago - NVL(mInt_Devengado,0) - NVL(mIva_Int_Devengado,0);
		ELSE 
			LET dAhorroPago = 0;
		    --LET dPago_Mes = (mCap_Vig + mCap_Vdo_NoExig);			
		END IF;		
		
		IF dAhorroPago < 0 THEN 
			LET dAhorroPago = 0;
		END IF;
	ELSE
		LET dAhorroPago = 0;
		LET iPagos_Realizados = 0;
	END IF;

	--se le manda a la proyeccion el saldo capital vigente o no exigible		
	LET mCapital=mCap_Vig+mCap_Trans;
	--se obtiene la mensualidad del cliente 	
	SELECT capital_mto_cuota
	INTO dMto_Prox_Pago
	FROM bdicred:"informix".sd_amortiza_creditocrd 
	WHERE empresa = pEmpresa 
	AND num_credito = pNumCredito 
	AND num_pago = 1;
    
	--valida si es posible realizar la proyeccion
    --si no  debe capital, no se proyecta.
	SELECT monto_min_cred, monto_max_cred
	INTO dMontoMin, dMontoMax
	FROM bdicred:"informix".sd_definicion
	WHERE num_producto = cNumProducto_vc
	AND empresa = pEmpresa;

	RETURN cCodRet,cMensajeRet,NVL(pNumCredito,''),NVL(cNumProducto_vc,''),NVL(cNomProductoCD,''),NVL(cNumCteCD,''),NVL(cNomCteCD,''),NVL(mLinea_Otorgada,0), NVL(dFecha_Origen,''),NVL(dSdoUltCorte,0),NVL(mInt_Moratorios,0),NVL(mIva_Int_Moratorios,0),NVL(mTotal_Liquidacion,0),NVL(mCap_Vdo_Exig,0),NVL(iPagos_Realizados,0),NVL(iPlazo_Sg,0),NVL(dFecha_Prox_Pago,''),NVL(mPago_Minimo,0),NVL(mTotal_Liquidacion,0), NVL(dAhorroPago,0),NVL(mTotal_Liquidacion,0), NVL(dAbonos_His,0),NVL(mInt_Devengado,0),NVL(mIva_Int_Devengado,0),NVL(mCom_Pend,0),NVL(mIva_Com,0),NVL(dMto_Prox_Pago,0),NVL(cDesc_Status_Cred, '');

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para consultar la informacion del prestamo', 
'AUTOR: Mohamed Carreón, Jesús Aguilar ',
'FECHA: 29 Abril 2011',
'BD: BDICRED',
'VERSION: 20110429.1641',
'DESCRIPCION: Se modifica llamado de procedimiento (sp_proyecta_prestamos) utilizado para obtener el total del ahorro, para no contemplar la frecuencia de pago', 
'AUTOR: Jesús Aguilar ',
'FECHA: 24 Agosto 2011',
'BD: BDICRED',
'VERSION: 20110824.1741',
'DESCRIPCION: Se agrega numero de producto como retorno', 
'AUTOR: Felipe Urias ',
'FECHA: 05 Agosto 2013',
'Folio: 1580',
'AUTOR : 95594213',
'FECHA : 29/01/2014',
'MODIFICACIÓN: Se modifica sp_ofi_consultasdos agregandole un retorno status anterior del credito obtenido del sp_consulta_saldos_general',
'SUSTENTO: RQM_09-338_Depósito_personal_cobranzav3.1.pdf',
'SOLICITA: Rodolfo Gomez',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_consultanombre_domitc
(
   pEmpresa CHAR(3),
   pNumCte CHAR(9),
   pNumCuenta CHAR(20),
   pNumTarjeta CHAR(20)
)
RETURNING CHAR(6) AS CodRet , CHAR(9) AS NumCliente, CHAR(107) AS NombreCte, CHAR(1) AS Status;

DEFINE  cCodRet                 CHAR(6);
DEFINE  iSql_err                INTEGER;
DEFINE  cNombre1                CHAR(26);
DEFINE  cNombre2                CHAR(26);
DEFINE  cApellPat               CHAR(26);
DEFINE  cApellMat               CHAR(26);
DEFINE  cStatusServElec CHAR(1);
DEFINE  cNombreCompleto CHAR(107);
DEFINE  tpo_tarjeta     CHAR(20);

LET     cCodRet                 = '000000';
LET     iSql_err                = 0;
LET     cNombre1                = "";
LET     cNombre2                = "";
LET     cApellPat               = "";
LET     cApellMat               = "";
LET     cStatusServElec = "";
LET     cNombreCompleto = "";
LET     tpo_tarjeta     = "";

BEGIN

    ON EXCEPTION SET iSql_err
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
           RETURN cCodRet, NVL(pNumCte,''), TRIM(cNombreCompleto), cStatusServElec;
        END IF;

    END EXCEPTION;

     --SET DEBUG FILE TO "/home/tmp/sp_consultanombre_domi.out";
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

        IF NVL(pEmpresa,'') <> '' AND (NVL(pNumTarjeta,'') <> '' OR NVL(pNumCte,'')<> '' OR NVL(pNumCuenta,'')<> '') THEN

                IF NVL(pNumCuenta,'') <> '' THEN

                         SELECT LIMIT 1 num_cte         --verifica si es tarjeta de debito
                         INTO pNumCte
                         FROM bdicheq:"informix".sc_maechq
                         WHERE empresa = pEmpresa
                         AND cuenta = pNumCuenta;

                        IF dbinfo("sqlca.sqlerrd2") = 0 THEN

                                SELECT LIMIT 1 numcte   --verifica si es tarjeta de credito
                                INTO pNumCte
                                FROM bdicred:"informix".sd_maecred
                                WHERE empresa = pEmpresa
                                AND num_credito = pNumCuenta;

                                IF dbinfo("sqlca.sqlerrd2") = 0 THEN

                                        SELECT LIMIT 1 numcte   --verifica si es prestamo o reestructura
                                        INTO pNumCte
                                        FROM bdicred:"informix".sd_maecredcrd
                                        WHERE empresa = pEmpresa
                                        AND num_credito = pNumCuenta;

                                        IF dbinfo("sqlca.sqlerrd2") = 0 THEN
                                                LET cCodRet = '000003';
                                        END IF;
                                END IF;
                        END IF;
                END IF;

                IF NVL(pNumTarjeta,'') <> '' THEN

                         SELECT LIMIT 1 numcte
                         INTO pNumCte
                         FROM bdicheq:"informix".sc_tarjeta
                         WHERE empresa = pEmpresa
                         AND num_tarjeta = pNumTarjeta
                         AND status_tar = "A"
                         AND tipo_tarjeta="T";

                        IF DBINFO("sqlca.sqlerrd2") = 0 THEN

                                SELECT LIMIT 1 numcte, tipo_tarjeta
                                INTO pNumCte,tpo_tarjeta
                                FROM bdicred:"informix".sd_tarjeta
                                WHERE empresa = pEmpresa
                                AND num_tarjeta = pNumTarjeta
                                AND status_tar = "A";
                              --  AND tipo_tarjeta="T";

                                IF dbinfo("sqlca.sqlerrd2") = 0 THEN
                                        LET cCodRet = '000002';
                                END IF;
			        IF tpo_tarjeta <>"T" THEN 
                                        LET cCodRet = '000005';
                                        RETURN cCodRet, NVL(pNumCte,''), TRIM(cNombreCompleto), cStatusServElec;
			        END IF;	
                        END IF;
                END IF;

                IF NVL(pNumCte,'') <> '' THEN
                        SELECT nombre1, nombre2, apell_paterno, apell_materno
                        INTO cNombre1, cNombre2, cApellPat, cApellMat
                        FROM bdinteg:"informix".si_cliente
                        WHERE numcte = pNumCte;

                        LET cNombreCompleto = TRIM(cNombre1) || " " || TRIM(cNombre2) || " " || TRIM(cApellPat) ||" " || TRIM(cApellMat);

                        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
                                LET cCodRet = '000002';
                        ELSE
                                SELECT LIMIT 1 status_serv_elec
                                INTO cStatusServElec
                                FROM bdiedoelec:"informix".edelec_alta_serv
                                WHERE numcte = pNumCte
                                AND status_serv_elec = 'A';

                                IF  DBINFO("sqlca.sqlerrd2") = 0 THEN
                                        LET cStatusServElec = 'I';
                                END IF;
                        END IF;
                END IF;
        ELSE
                LET cCodRet = '000001'; --parametros vacios
        END IF;

        RETURN cCodRet, NVL(pNumCte,''), TRIM(cNombreCompleto), cStatusServElec;
END;
END PROCEDURE
--DROP  PROCEDURE "informix".sp_consultanombre_domitc;
;

CREATE PROCEDURE "informix".sp_cancela_upgrade_prod()

RETURNING CHAR(6)         AS codigo_retorno,
          VARCHAR(100,1)  AS mensaje_retorno;

-- Proceso para la Cancelación del marcaje de upgrade TDC Oro/Platino RQM 10 1062 
-- Modificado: Febrero 2019

DEFINE iSqlErr          INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6);
DEFINE cMensajeRet      VARCHAR(100,1);		  
DEFINE cstcred          CHAR(2);
DEFINE cnumlote         INTEGER;
DEFINE ccredito         CHAR(20);
DEFINE ccliente         CHAR(20);
DEFINE cnumerotarjeta   CHAR(20);	
DEFINE dFechaHoy        DATE;
DEFINE cvalor           CHAR(10);
DEFINE cEmpresa			CHAR(3); 

LET ccredito            = NULL;
LET ccliente            = NULL;
LET cnumerotarjeta      = NULL;
LET cnumlote            = 0;
LET dFechaHoy           = NULL;
LET cMensajeRet         = '';
LET iSqlErr             = 0;
LET cErrorInfo          = "";
LET cCodRet             = '00000';
LET cEmpresa			= '001';

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cMensajeRet = cErrorInfo;
            RETURN cCodRet, cMensajeRet;
        END IF;
    END EXCEPTION;
	
    -- SET DEBUG FILE TO '/tmp/sp_cancela_prod_upgrade.out';
    -- SET DEBUG FILE TO '/informix/jquintana/RQM1010622/logs/sp_cancela_prod_upgrade.out';
    -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    ----------------
    SELECT fecha_hoy INTO dFechaHoy
    FROM bdicred:"informix".sd_fechas
	WHERE empresa = cEmpresa;
	
    SELECT valor INTO cvalor
    FROM bdicred:"informix".sd_param
    WHERE empresa = cEmpresa AND cod_param = '055';
		
    FOREACH 
			
        SELECT a.num_credito, b.numtarjeta
		INTO ccredito, cnumerotarjeta
		FROM bdicred:"informix".sd_credito_upgrade a 
		INNER JOIN intercard:"informix".solicitudtarjeta d ON d.numcliente = a.numcte AND a.num_credito = d.numcuenta AND a.num_producto_upgrade = d.codprodcta 
		INNER JOIN intercard:"informix".detalle_maquila b ON d.idsolicitud = b.idsolicitud 
		INNER JOIN intercard:"informix".tarjeta c ON c.numtarjeta = b.numtarjeta AND c.numcliente = a.numcte 
		WHERE a.empresa = cEmpresa AND a.numero_credito_upgrade = '' AND c.codstatusasignada IN('NOA','NOE','SIA')
		AND a.resultado = '0' AND c.codstatustarjeta IN('INA') AND d.idsolicitud = b.idsolicitud AND d.estatusproceso = 'V'
		AND (TODAY - DATE((SELECT MAX(fecha) FROM intercard:"informix".flujolote WHERE numerolote = b.numlote))) >= cvalor
					
		UPDATE bdicred:"informix".sd_credito_upgrade SET fecha_cancelaupgrade = CURRENT, resultado = '3' WHERE empresa = cEmpresa AND num_credito = ccredito; 
		UPDATE intercard:"informix".tarjeta SET codstatustarjeta = 'DAN', usuarioultmodif = 'informix', fechaultmodif = CURRENT WHERE numtarjeta = cnumerotarjeta;
		        
    END FOREACH;
			
	IF DAY(dFechaHoy) = 6 THEN
        EXECUTE PROCEDURE bdicred:"informix".sp_reporte_cancela_upgrade(dFechaHoy) INTO cCodRet, cMensajeRet;
	END IF;
			
	IF cCodRet <> '00000' THEN
        LET cMensajeRet = 'Error al generar el reporte';
		RETURN cCodRet, cMensajeRet;
	END IF;
					
	LET cCodRet = '00000';
	LET cMensajeRet = 'Cancelacion de marcaje realizada con exito';		
	-------------
			
RETURN cCodRet, cMensajeRet;
END
END PROCEDURE

DOCUMENT
'Se realiza procedimiento para realizar la cancelacion del marcaje de Upgrade TDC Oro/Platino ',
'AUTOR : Karla Rebeca Gonzalez Blanco',
'FECHA : 17/08/2018',
'BD    : BDICRED',
'-------------------------------------------------------------------------------------------------------------',
'-- CONTROL DE CAMBIOS',
'-------------------------------------------------------------------------------------------------------------',
'-- Modificó: Jorge Humberto Quintana Santiesteban',
'-- Fecha de Modificación: 28-02-2019',
'-- Descripción: Se modifica el nuevo estatus para las tarjetas de los marcajes a cancelar, de CAN a DAN.', 
'-- RQ: RQM 10 1062-2 - IMPLEMENTACIÓN - ADENDUM - Cancelación del marcaje de upgrade TDC Oro/Platinum (28960)',
'-- CC Rational: 30283',
'-------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_reporte_cancela_upgrade(pFecha DATE)
    RETURNING CHAR(6)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje;        

-- Proceso para la generación del reporte de la cancelación del marcaje de upgrade TDC Oro/Platino RQM 10 1062 
-- Modificado: Agosto 2018, Febrero 2019

DEFINE sql_err				INTEGER;
DEFINE iSqlErr              INTEGER;
DEFINE isam_err				INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoEjecSql   CHAR(100);
DEFINE cSQL                 CHAR(3000);
DEFINE cSQL1                CHAR(3000);
DEFINE cSQL2                CHAR(3000);
DEFINE cSQL3                CHAR(3000);
DEFINE cruta                CHAR(100);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE mes                  CHAR(2);
DEFINE anio					CHAR(4);
DEFINE cfechacorte          DATE;
DEFINE dFechaHoy            DATE;
DEFINE cfech_corte          DATE;
DEFINE cfech1               CHAR(12);
DEFINE cfech2               CHAR(12);
DEFINE cCodRet              CHAR(6);
DEFINE cMensajeRet          VARCHAR(100,1);
DEFINE cEmpresa				CHAR(3);	

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "PROCESO NO EXITOSO";
LET cCod_Ret                = '00000';
LET cMensaje                = "";
LET cruta                   = "";
LET cnombre					= "CANCELUPGRADE_";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cnomarchivoEjecSql      = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET mes                     = "";
LET anio					= "";
LET cfechacorte             = NULL;
LET dFechaHoy               = DATE(1);
LET cfech_corte             = NULL;
LET cfech1                  = NULL;
LET cfech2                  = NULL;
LET cCodRet                 = '00000';
LET cMensajeRet 			= '';
LET cEmpresa				= '001';

 BEGIN
   	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet;
		END IF;
	END EXCEPTION;

	-- SET DEBUG FILE TO '/tmp/sp_reporte_cancela_upgrade.out';
    -- SET DEBUG FILE TO '/informix/jquintana/RQM1010622/logs/sp_reporte_cancela_upgrade.out';
	-- TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;    

	-- Obtener ruta del archivo
    SELECT valor INTO cruta
    FROM bdicred:"informix".sd_param 
	WHERE empresa = cEmpresa AND cod_param = '056';
	
	LET cruta = TRIM(cruta);
	
	SELECT fecha_hoy INTO dFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = cEmpresa; 
	
 	SELECT (fecha_hoy - 30) INTO cfech_corte
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = cEmpresa; 
	
	LET cfech1 = TO_CHAR(cfech_corte,'%m,%d,%Y');
	LET cfech2 = TO_CHAR(pFecha,'%m,%d,%Y');
	
    -- SE VALIDA SI LA FECHA PARAMETRO ES MAYOR A LA FECHA HOY.
	IF pFecha > dFechaHoy THEN 
	   LET cCod_Ret = '00002';
	   LET cMensaje = error_info; 
	   RETURN cCod_Ret, cMensaje ;
	END IF; 
	
	IF MONTH(pFecha) < 10 THEN
	   LET mes = '0' || MONTH(pFecha);
	ELSE 
	   LET mes = MONTH(pFecha); 
	END IF;
	
	LET anio = TO_CHAR(YEAR(pFecha));
	
	LET cFechaGenArchivo = mes || SUBSTR(anio,3,2);
        
	LET cSQL  = '';
	LET cSQL1 = '';
	LET cSQL2 = '';
	LET cSQL3 = ''; 
	LET cnomarchivo1 = '';
	LET cnomarchivo = '';
	LET cnomarchivoEjecSql = '';
	
	--Se definen nombres de archivos
	LET cnomarchivo1 = TRIM(cnombre)||TRIM(cFechaGenArchivo)||'_Aux'||'.txt ';
	LET cnomarchivo =  TRIM(cnombre)||TRIM(cFechaGenArchivo)||'.txt ';
    LET cnomarchivoEjecSql = 'Exec_Cancel_Upgrade.sql';

    LET cSQL='';
    LET cSQL = ' echo "Num Credito'||'|'||'Num Cliente'||'|'||'Num Tarjeta credito marcado'||'|'||'Nombre cliente' ||
            '|'||'Num sucursal'||'|'||'Fecha Ingreso'||'|'||'Fecha Cancelacion'||'|'||' " >>' || TRIM(cruta) || TRIM(cnomarchivo)||'';
    SYSTEM cSQL;
	
	--Se arma consulta para extraccion de datos										
	LET cSQL1 = 'echo " UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || '';																	 
	LET cSQL2 = " SELECT cu.num_credito, cu.numcte, cu.numerotarjeta, cu.nombre, st.sucursal, cu.fecha_insert, cu.fecha_cancelaupgrade " ||        
                " FROM bdicred:'informix'.sd_credito_upgrade cu " ||
				" JOIN intercard:'informix'.solicitudtarjeta st ON cu.numcte = st.numcliente AND cu.num_credito = st.numcuenta " ||
                " WHERE cu.empresa = '" || TRIM(cEmpresa) || "' AND cu.fecha_cancelaupgrade IS NOT NULL " ||
                " AND cu.resultado = '3' " ||
				" AND DATE(cu.fecha_cancelaupgrade) BETWEEN MDY( " || TRIM(cfech1) || " ) AND MDY( " || TRIM(cfech2) || "  ) " ||
				" AND st.fechasolicitud = (SELECT MAX(fechasolicitud) FROM intercard:'informix'.solicitudtarjeta WHERE numcliente = cu.numcte AND numcuenta = cu.num_credito) " ||
                " ORDER BY cu.num_credito ";
	
	LET cSQL3 = ' " >> '||TRIM(cruta)|| TRIM(cnomarchivoEjecSql);
	LET cSQL = '';
	LET cSQL =  TRIM(cSQL1) || ' ' || TRIM(cSQL2) || ' ' || TRIM(cSQL3);
    System cSQL;
	
	LET cSQL = '';
    LET cSQL='chmod 777 '|| TRIM(cruta)|| TRIM(cnomarchivoEjecSql);
    System cSQL;

	LET cSQL = '';
    let cSQL = 'dbaccess bdicred ' || TRIM(cruta) || TRIM(cnomarchivoEjecSql);
    System cSQL;

	LET cSql = '';
    LET cSql = "sed 's/|$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
    SYSTEM cSql;

	-- Borra el archivo de control.
    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cruta) || TRIM(cnomarchivoejecsql) || ' ' || TRIM(cruta) || TRIM(cnomarchivo1);
    SYSTEM cSQL;

    LET cCod_Ret = '00000';
    LET cMensaje = 'PROCESO EXITOSO';

	RETURN cCod_Ret,cMensaje;

 END;

END PROCEDURE

DOCUMENT
'-------------------------------------------------------------------------------------------------------------',
'-- CONTROL DE CAMBIOS',
'-------------------------------------------------------------------------------------------------------------',
'-- Modificó: Jorge Humberto Quintana Santiesteban',
'-- Fecha de Modificación: 28-02-2019',
'-- Descripción: Se modifica el nuevo campo Número de Sucursal del reporte:',
'--              	De Número de sucursal de origen de Tarjeta marcada',
'--              	A Número de sucursal donde se ingresó la TDC Oro/Platinum cancelada.',
'-- RQ: RQM 10 1062-2 - IMPLEMENTACIÓN - ADENDUM - Cancelación del marcaje de upgrade TDC Oro/Platinum (28960)',
'-- CC Rational: 30283',
'-------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_depura_sd_movhis_auto()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 		INTEGER;
DEFINE isam_err 	INTEGER;
DEFINE error_info	CHAR(150);
DEFINE cMensaje 	CHAR(150);
DEFINE cCod_ret     CHAR(6);
DEFINE vrowid       INTEGER;
DEFINE VlNumCredito	CHAR(20);
DEFINE iCont		INTEGER;
DEFINE cValor		CHAR(1);
DEFINE dFecha		DATE;	

	--SET DEBUG FILE TO "/informix/c91691184/sp_depura_sd_movhis_auto.out";
    --TRACE ON; 

	LET cCod_ret    = '000000';
	LET sql_err     = 0;
	LET isam_err    = 0;
	LET error_info	= '';
	LET cMensaje    = 'PROCESO EXITOSO';
	LET iCont		= 0;
	LET cValor		= '';

	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		RETURN cCod_ret;
	END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

	select valor into cValor 
	from "informix".sd_param 
	where empresa = '001' and cod_param = 'DT6';

	LET cValor = trim(cValor);

	select date((pri_dia_mes - 1 units year) - 1 units day) into dFecha 
	from "informix".sd_fechas
	where empresa = '001';

	select count(*) into iCont 
	from "informix".temp_creditos_depurar6;

	if iCont > 0 and cValor = '1' then

		update "informix".sd_param set valor = '2'
		where empresa = '001' and cod_param = 'DT6';

	ELIF iCont > 0 and cValor = '0' then

		LET cCod_ret = '000001';
		RETURN cCod_ret;

	end if;

    FOREACH WITH HOLD

		select num_credito
		into VlNumCredito  
		from "informix".temp_creditos_depurar6

		BEGIN WORK;

			DELETE FROM bdicred:"informix".sd_movhis 
			WHERE empresa = '001' and  num_credito = VlNumCredito and fecha_mov <= dFecha;
			delete from "informix".temp_creditos_depurar6 where num_credito = VlNumCredito;

		COMMIT WORK;

	END FOREACH;

	update "informix".sd_param set valor = '0'
	where empresa = '001' and cod_param = 'DT6';

	RETURN cCod_ret;

	END;

END PROCEDURE;