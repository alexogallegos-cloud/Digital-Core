CREATE PROCEDURE "informix".sp_ofi_consultasdos(pEmpresa CHAR(3),pNumCredito CHAR(20),pSucursal CHAR(4))
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

CREATE PROCEDURE "informix".sp_consindicador_cred(pEmpresa CHAR(3),pNumTarjeta CHAR(16))
	
     RETURNING 	
                CHAR (5) AS rValRetorno,
                CHAR (12) AS rnumcredito,
				MONEY (14,2)AS rmonto_dev,
                DATETIME YEAR to FRACTION(3) AS rfecha_traspaso;
	
	-- DEFINICION DE VARIABLES

  
	DEFINE iSqlErr			INTEGER;
	DEFINE cValRetorno		CHAR(5);
    DEFINE numcredito       CHAR(12);
    DEFINE monto_dev        MONEY(14,2);
    DEFINE numcreditoact    CHAR(12);
    DEFINE fecha_traspaso   DATETIME YEAR to FRACTION(3);
	--DEFINE cFlag			INTEGER;
	
	--INICIALIZACION DE VARIABLES
	LET cValRetorno     = '00001';
    LET numcredito      = "";
    LET monto_dev       = 0.0;
--	LET cFlag			= "";
	
    --SET DEBUG FILE TO "/tmp/sp_consindicador_cred.out"; 
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'',0.0,'';
			END IF;
		END EXCEPTION;
		
		
		IF NVL(pNumTarjeta,'') = '' THEN
			LET cValRetorno = '00001';
		ELSE
	        SELECT num_credito 
            INTO numcreditoact
            from bdicred:sd_tarjeta where num_tarjeta = pNumTarjeta;


			SELECT a.num_credito,a.monto_devolucion 
			INTO numcredito,monto_dev
			FROM bdicred:"informix".sd_indicador_cred a
            INNER JOIN bdicred:sd_maecred  b on a.num_credito=b.num_credito 
			WHERE a.num_credito = numcreditoact  AND b.id_unidad_prod=4 AND a.fecha_pre_devol_anual IS NOT NULL
            AND a.fecha_devol_anual IS  NULL; 
            --AND a.fecha_trasp_devol_anual IS NULL AND a.empresa = '001';
            
            LET cValRetorno = '00000';

           	SELECT fecha_trasp_devol_anual
			INTO fecha_traspaso
			FROM bdicred:"informix".sd_indicador_cred 
			WHERE num_credito = numcreditoact;
             
	       IF fecha_traspaso IS NOT NULL THEN
			LET cValRetorno = '01209';
	       END IF
          
	       IF TRIM(NVL(numcredito, '')) = '' THEN
			LET cValRetorno = '00001';
	       END IF
         
 
		END IF;
		RETURN cValRetorno,numcredito,monto_dev,fecha_traspaso;	
	END
END PROCEDURE             
DOCUMENT
'Creado: Jose Miguel Guicochea',
'Fecha: 06/07/2017',
'Descripcion: Se crea sp para validar si existe el credito en la tabla sd_indicador_cred';

CREATE PROCEDURE "informix".sp_consulta_producto (pEmpresa CHAR(3), pNumCredito CHAR(20), pNumTarjeta CHAR(20))

RETURNING CHAR(5)   AS codigo_retorno,
          CHAR(4)   AS numero_pructo,
          CHAR(40)  AS nombre_producto;

DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(5);

DEFINE cNumCredito   CHAR(20);
DEFINE cNumProducto  CHAR(4);
DEFINE cNomProducto  CHAR(40);
DEFINE cNumTarjeta   CHAR(20);
DEFINE cCodprod      CHAR(2);

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '';

LET cNumCredito   = '';
LET cNumProducto  = '';
LET cNomProducto  = '';
LET cNumTarjeta   = '';
LET cCodprod      = '';

BEGIN 

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
		  LET cCodRet= iSqlErr;
		  RETURN cCodRet, NVL(cNumProducto,''), NVL(cNomProducto,'');
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_consulta_producto.out"; 
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;
		

	LET cCodRet= '00000';

	IF NVL(pNumCredito,'') = '' THEN
	  LET pNumCredito = NULL;
	END IF;

	IF NVL(pNumTarjeta,'') = '' THEN
	  LET pNumTarjeta = NULL;
	ELSE 
		SELECT num_credito
		  INTO pNumCredito
		  FROM sd_tarjeta
		 WHERE empresa     = pEmpresa
		   AND num_tarjeta = pNumTarjeta;
	END IF;


	IF pNumCredito IS NOT NULL THEN
	-- consulta por numero de credito para creditos normales
		SELECT num_credito,b.cod_prod
		INTO cNumCredito,cCodprod
		FROM bdicred:"informix".sd_maecred a,
			 bdicred:"informix".sd_tipprod b
		WHERE a.num_credito = pNumCredito
		AND a.empresa=pEmpresa
		AND a.empresa=b.empresa 
		AND a.num_producto=b.abrevia_prod;

			IF cNumCredito IS NULL OR cCodprod IS NULL THEN
				SELECT num_credito,b.cod_prod
				INTO cNumCredito,cCodprod
				FROM bdicred:"informix".sd_maecredcrd a,
				     bdicred:"informix".sd_tipprod b
				WHERE a.num_credito = pNumCredito
				AND a.empresa=pEmpresa
				AND a.empresa=b.empresa 
				AND a.num_producto=b.abrevia_prod;
				
				IF cNumCredito IS NULL OR cCodprod IS NULL THEN
				   LET cCodRet     = '00001';
				   RETURN cCodRet, NVL(cNumProducto,''), NVL(cNomProducto,'');
				END IF;
			END IF;

		IF cCodprod ='T' THEN
			SELECT  a.num_credito,
				   c.num_producto,
				   c.nombre_prod
			  INTO cNumCredito,
				   cNumProducto,
				   cNomProducto
			  FROM bdicred:"informix".sd_maecred a,
				   bdicred:"informix".sd_definicion c, 
				   bdicred:"informix".sd_tarjeta d
			 WHERE c.num_producto = a.num_producto
			   AND c.empresa = a.empresa
			   AND d.empresa = a.empresa
			   AND c.num_producto = a.num_producto
			   AND d.num_credito = a.num_credito
			   AND d.tipo_tarjeta = 'T'
			   and d.secuencia = (SELECT MAX(secuencia) 
									FROM bdicred:"informix".sd_tarjeta 
								   WHERE empresa = pEmpresa 
									 AND num_credito = pNumCredito 
									 AND tipo_tarjeta = 'T')
			   AND a.empresa = pEmpresa
			   AND a.num_credito= pNumCredito;
			   
			   IF cNumCredito IS NOT NULL THEN
				   LET nrows=nrows+1;
				  RETURN cCodRet, NVL(cNumProducto,''), NVL(cNomProducto,'');
			   END IF;
		ELSE
			  --consulta de por numero de credito para prestamos personales
			   SELECT a.num_credito,
					  c.num_producto,
					  c.nombre_prod
				 INTO cNumCredito,
					  cNumProducto,
					  cNomProducto
				  FROM bdicred:"informix".sd_maecredcrd a,
					   bdicred:"informix".sd_definicion c
				 WHERE c.num_producto = a.num_producto
				   AND c.empresa = a.empresa
				   AND c.num_producto = a.num_producto
				   AND a.empresa = pEmpresa
				   AND a.num_credito = pNumCredito;  
				   
				   IF cNumCredito IS NOT NULL THEN
					   LET nrows=nrows+1;
					   RETURN cCodRet, NVL(cNumProducto,''), NVL(cNomProducto,'');
				   END IF;
	
		END IF;
	END IF;
		   
	IF nrows= 0 THEN
	   LET cCodRet= '00002';
	   RETURN cCodRet, NVL(cNumProducto,''), NVL(cNomProducto,'');
	END IF;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para realizar una consulta general',
'para obtener la información basica del cliente',
'AUTOR : Martin Miranda',
'FECHA : 05/05/2011',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_obtiene_tabla_amortizacion_edocta_inha( pEmpresa CHAR(3), vFechaHoy DATE)
	RETURNING   CHAR(6)         AS Codigo; 		  	-- CODIGO DE RETORNO


	-- VARIABLES PARA RETORNO DE DATOS --
	DEFINE cCodRet     			CHAR(6); 			-- CODIGO DE RETORNO DE ERROR
	DEFINE iPeriodo				INTEGER;			-- PERIODO ACTUAL PARA PP
	DEFINE iCicloRtc 			INTEGER;   			-- PERIODO ACTUAL PARA RTC
	DEFINE dtFechaCouta			DATE;				-- FECHA DEL PAGO PARA PP
	DEFINE dtFecha_Alta       	DATE;				-- FECHA DEL PAGO PARA RTC
	DEFINE dSdoInicial			MONEY(14,2);		-- SALDO INICIAL
	DEFINE dMensualidad			DECIMAL(18,6);		-- MENSUALIDAD
	DEFINE dIntereses			MONEY(14,2);		-- INTERESES
	DEFINE dIvaInt				DECIMAL(14,2);		-- IVA DE INTERESES
	DEFINE dCapital				MONEY(14,2);		-- CAPITAL
	DEFINE dSdoFinal			DECIMAL(18,6);		-- SALDO FINAL
	DEFINE iDiasPeriodo			INTEGER;			-- DIAS DEL PERIODO
	DEFINE dtFechaAper			DATE;				-- FECHA DE APERTURA
	DEFINE dPlazoAux      		DECIMAL(18,6);		-- NUMERO DE MESES PAGO
	DEFINE dMtoContrato      	DECIMAL(18,2);		-- MONTO CONTRATADO PARA PP
	DEFINE dEnganchePag      	DECIMAL(18,2);		-- ENGANCHE PAGADO DE LA RTC
	DEFINE dMtoTotalaPagar      DECIMAL(18,2);		-- MONTO TOTAL A PAGAR PARA PP Y RTC
	DEFINE cTasaFija      		CHAR(6);			-- TASA DE INTERES FIJA ANUAL PARA PP Y RTC
	DEFINE dTasaFija      		DECIMAL(18,2);		-- TASA DE INTERES FIJA ANUAL PARA PP Y RTC
	DEFINE dTotLiqpp 			DECIMAL(18,2);   	-- TOTAL LIQUIDACION PARA PRESTAMO
	DEFINE dTotLiqRtc 			DECIMAL(18,2);   	-- TOTAL LIQUIDACION PARA REESCTRUCTURA
	DEFINE dTotAhorro  			DECIMAL(18,2);		-- MONTO DE TE AHORRARIAS
	DEFINE cCadena1      		CHAR(3);
	DEFINE cCadena2      		CHAR(6);
	DEFINE cCadena3      		CHAR(6);
	-- VARIABLES AUXILIARES PARA PRESTAMO/REESTRUCTURA/CREDINOMINA
	DEFINE iSqlErr      		INTEGER;			-- CODIGO DE ERROR
	DEFINE dTasa				DECIMAL(18,6);		-- TASA ANUAL
	DEFINE dTasa_Mora			DECIMAL(18,6);		-- TASA ANUAL MORATORIA	
	DEFINE iContador 			INTEGER; 			-- PARA CONTROLAR LAS INTERACIONES DEL CICLO
	DEFINE cProducto     		CHAR(4);			-- NUMERO DEL PRODUCTO
	DEFINE dCapacidadPres		DECIMAL(18,6); 		-- CAPACIDAD DE PAGO DEL CLIENTE
	DEFINE iDiaPago      		INTEGER;			-- DIA DE PAGO
	DEFINE iPagosRealizados 	INTEGER;			-- NUMERO DE PAGOS REALIZADO
	DEFINE dIva              	MONEY(14,2);		-- IVA DE SUCURSAL
	-- VARIABLES AUXILIARES PARA PRESTAMO
	DEFINE dtFechaInicial		DATE;				-- FECHA QUE SE TOMA COMO INICIO PARA CALCULAR LAS DEMAS FECHAS
	DEFINE dtFechaAnt			DATE;				-- FECHA ANTERIOR DE COUTA
	DEFINE dTasaInt 			DECIMAL(18,6);		-- TASA DE INTERES
	DEFINE dtFechaCoutaAux		DATE;				-- FECHA DEL PAGO AUXILIAR
	DEFINE cFrecuencia     		CHAR(1);			-- FECUENCIA DEL PAGO
	DEFINE dMontoAut 			DECIMAL(18,6); 		-- MONTO DEL CREDITO
	DEFINE dPlazo  	 			DECIMAL(18,6);		-- PLAZO EN MESES PARA PAGAR
	-- VARIABLES AUXILIARES PARA REESTRUCTURA
	DEFINE dtFechaIniRtc		DATE;				-- FECHA CUOTA DE LA PRIMERA MENSUALIDAD
	DEFINE dtFechaActual		DATE;				-- FECHA DEL CAMPO  fecha_hoy DE LA TABLA sd_fechas
	DEFINE dSobreTasa			DECIMAL(18,2);		-- TASA ANUAL
	DEFINE cDias_Cal_Int    	CHAR(10);			-- DIAS PARA EL CALCULO DE INTERESES
	DEFINE cFactor_SobreTasa 	CHAR(1);			-- FACTOR SOBRE TASA
	DEFINE dTasa_IntDiario      DECIMAL(10,6);		-- TASA DE INTERES DIARIO
	DEFINE dTasa_Interes    	DECIMAL(9,6);		-- TASA DE INTERES
	DEFINE sPlazoMax			SMALLINT;			-- PLAZO MAXIMO
	-- VARIABLES PARA EL PROCEDIMIENTO sp_ofi_consultasdos
	DEFINE cCod_Ret2 			CHAR(6);			-- CODIGO DE RETORNO
	DEFINE cMensaje 			CHAR(80);  	  		-- MENSAJE DE RETORNO
	DEFINE cNumCred				CHAR(20); 	  		-- NUMERO DE CREDITO
	DEFINE cNumProd				CHAR(4); 	  		-- NUMERO DEL PRODUCTO
	DEFINE cDescProd			CHAR(40);      		-- DESCRIPCION DEL PRODUCTO
	DEFINE cNumCte				CHAR(20);      		-- NUMERO DE CLIENTE
	DEFINE cNomCte				CHAR(150);			-- NOMBRE DEL CLIENTE
	DEFINE dMtoLinea			DECIMAL(18,2);		-- MONTO DE LINEA OTORGADA
	DEFINE cStatus 				CHAR (60); 			-- ESATUS DEL CREDITO
	DEFINE dtProximo 			DATE;				-- FECHA DEL PROXIMO PAGO
	DEFINE dtFecha 				DATE; 				-- FECHA DEL PAGO
	DEFINE dSaldo				DECIMAL(18,2); 		-- SALDO DEL CREDITO
	DEFINE mInteres 			DECIMAL(18,2);   	-- INTERESES DEL CREDITO
	DEFINE dIvaInt2				DECIMAL(18,2);   	-- IVA DE INTERESES DEL CREDITO
	DEFINE mTotal 				DECIMAL(18,2);  	-- MONTO TOTAL DEL CREDITO
	DEFINE mPagos 				DECIMAL(18,2);      -- MONTO DE PAGO DEL CREDITO
	DEFINE mMinimo 				DECIMAL(18,2);   	-- MONTO DE PAGO MINIMO DEL CREDITO
	DEFINE mSaldar 				DECIMAL(18,2); 		-- MONTO DE TOTAL DE LIQUIDACION
	DEFINE dAhorro  			DECIMAL(18,2);		-- MONTO DE AHORRO DEL CREDITO
	DEFINE mDeuda 				DECIMAL(18,2);   	-- MONTO DE DEUDA DEL CREDITO
	DEFINE mPagReal				DECIMAL(18,2);   	-- MONTO DE PAGO REAL DEL CREDITO
	DEFINE mIntDeven			DECIMAL(18,2);   	-- INTERESES DEVENGADOS DEL CREDITO
	DEFINE dIvaIntDeven			DECIMAL(18,2);  	-- IVA DE INTERES DEVENGADOS DEL CREDITO
	DEFINE mComision 			DECIMAL(18,2);   	-- MONTO DE COMISION DEL CREDITO
	DEFINE mIvaCom 				DECIMAL(18,2);   	-- IVA DE COMISION DEL CREDITO
	DEFINE mMonto 				DECIMAL(18,2);   	-- MONTO DEL CREDITO
	DEFINE iPagos 				INTEGER;       		-- NUMERO DE PAGOS DEL CREDITO
	DEFINE iPlazo 				INTEGER;   			-- NUMERO DE PLAZOS DEL CREDITO
	DEFINE cCodRetTDif			CHAR(6);			-- COD RETORNO TASAS DIFERENCIADAS
	DEFINE dfechahoy 			DATE;
	DEFINE dSum_capital DECIMAL(18,2); 
	DEFINE	dSum_intereses DECIMAL(18,2); 
	DEFINE	dSum_iva_intereses DECIMAL(18,2); 
	DEFINE	dSum_pagomin DECIMAL(18,2); 
	DEFINE  pNumCred CHAR(12);
	DEFINE cAmortiza INTEGER;
	DEFINE cBandera INTEGER;
	DEFINE pSucursal CHAR(4);
	DEFINE dMesesadicionales  INTEGER;
	DEFINE dFecha_vencim DATE;
	DEFINE dInteresesAcum MONEY(14,2);
	DEFINE sSdo_debe MONEY(14,2);
	DEFINE sSdo_pagado MONEY(14,2);
	DEFINE psaldoInteresApoyo DECIMAL(18,2);
	DEFINE psaldoIvaApoyo DECIMAL(18,2);
	DEFINE dSdoAdeudTotal  DECIMAL(18,2);
	DEFINE pProporcion  DECIMAL(18,2);
	DEFINE dUltimopago  DECIMAL(18,2);
	DEFINE dUlt_interes  DECIMAL(18,2);
	DEFINE dUltiva  DECIMAL(18,2);
	DEFINE dInt_restante  DECIMAL(18,2);
	DEFINE dInteres_sumar  DECIMAL(18,2);
	DEFINE dIva_sumar  DECIMAL(18,2);
	DEFINE pFinal_intreses  DECIMAL(18,2);
	DEFINE pFinal_iva	  DECIMAL(18,2);
	DEFINE DFinal_montopago  DECIMAL(18,2);
	DEFINE dUltpago_capital  DECIMAL(18,2);
	DEFINE dInteresesN DECIMAL(18,2);
	DEFINE dIvaIntN DECIMAL(18,2);
	DEFINE dMensualidadN DECIMAL(18,2);
	DEFINE dSdoAdeudTotal_liquidar DECIMAL(18,2);

	
	-- VARIABLES PARA RETORNO DE DATOS
	LET cCodRet     			= '000000';
	LET iPeriodo				= 0;
	LET iCicloRtc				= 0;
	LET dtFechaCouta			= DATE(1);
	LET dtFecha_Alta			= DATE(1);
	LET dSdoInicial				= 0;
	LET dMensualidad			= 0;
	LET dIntereses				= 0;
	LET dIvaInt					= 0;
	LET dCapital				= 0;
	LET dSdoFinal				= 0;
	LET iDiasPeriodo			= 0;
	LET dtFechaAper				= DATE(1);
	LET dPlazoAux      			= 0;
	LET dMtoContrato      		= 0;
	LET dEnganchePag			= 0;
	LET dMtoTotalaPagar      	= 0;
	LET dTasaFija				= 0;
	LET dTotLiqpp 				= 0;
	LET dTotLiqRtc 				= 0;
	LET dTotAhorro  			= 0;
	-- VARIABLES AUXILIARES PARA PRESTAMO/REESTRUCTURA/CREDINOMINA
	LET iSqlErr      			= 0;
	LET dTasa					= 0;
	LET dTasa_Mora				= 0;
	LET iContador 				= 0;
	LET cProducto     			= '';
	LET dCapacidadPres			= 0;
	LET iDiaPago      			= 0;
	LET iPagosRealizados 		= 0;
	LET dIva              		= 0;
	-- VARIABLES AUXILIARES PARA PRESTAMO
	LET dtFechaInicial			= DATE(1);
	LET dtFechaAnt				= DATE(1);
	LET dTasaInt 				= DATE(1);
	LET dtFechaCoutaAux			= DATE(1);
	LET cFrecuencia     		= '';
	LET dMontoAut 				= 0;
	LET dPlazo  	 			= 0;
	-- VARIABLES AUXILIARES PARA REESTRUCTURA
	LET dtFechaActual			= DATE(1);
	LET dtFechaIniRtc			= DATE(1);
	LET dSobreTasa				= 0;
	LET cDias_Cal_Int    		= '';
	LET cFactor_SobreTasa 		= '';
	LET dTasa_IntDiario     	= 0;
	LET dTasa_Interes    		= 0;
	LET sPlazoMax				= 0;
	-- VARIABLES PARA EL PROCEDIMIENTO sp_ofi_consultasdos
	LET cCod_Ret2 				= '000000';
	LET cMensaje 				= '';
	LET cNumCred				= '';
	LET cNumProd				= '';
	LET cDescProd				= '';
	LET cNumCte					= '';
	LET cNomCte					= '';
	LET dMtoLinea				= 0;
	LET cStatus 				= '';
	LET dtProximo 				= DATE(1);
	LET dtFecha 				= DATE(1);
	LET dSaldo					= 0;
	LET mInteres 				= 0;
	LET dIvaInt2				= 0;
	LET mTotal 					= 0;
	LET mPagos 					= 0;
	LET mMinimo 				= 0;
	LET mSaldar 				= 0;
	LET dAhorro  				= 0;
	LET mDeuda 					= 0;
	LET mPagReal				= 0;
	LET mIntDeven				= 0;
	LET dIvaIntDeven			= 0;
	LET mComision 				= 0;
	LET mIvaCom 				= 0;
	LET mMonto 					= 0;
	LET iPagos 					= 0;
	LET iPlazo 					= 0;
	LET cCodRetTDif				= '';
	LET dfechahoy				= DATE(1);
	LET dSum_capital 			= 0;
	LET	dSum_intereses 			= 0;
	LET	dSum_iva_intereses 		= 0;
	LET	dSum_pagomin 			= 0;
	LET pNumCred				= '';
	LET cAmortiza = 0;
	LET cBandera = 0;
	LET pSucursal = '';
	LET dMesesadicionales = 0;
	LET dFecha_vencim = DATE(1);
	LET dInteresesAcum =  0;
	LET sSdo_debe = 0;
	LET sSdo_pagado =  0;
	LET psaldoInteresApoyo = 0;
	LET psaldoIvaApoyo = 0;
	LET dSdoAdeudTotal   = 0;
	LET pProporcion   = 0;
	LET dUltimopago  = 0;
	LET dUlt_interes   = 0;
	LET dUltiva   = 0;
	LET dInt_restante  = 0;
	LET dInteres_sumar  = 0;
	LET dIva_sumar   = 0;
	LET pFinal_intreses   = 0;
	LET pFinal_iva	   = 0;
	LET DFinal_montopago   = 0;
	LET dUltpago_capital  = 0;
	LET dInteresesN  = 0;
	LET dIvaIntN  = 0;
	LET dMensualidadN  = 0;
	LET dSdoAdeudTotal_liquidar  = 0;

	BEGIN

		ON EXCEPTION  SET iSqlErr
			IF iSqlErr <> 0  THEN
				LET  cCodRet  = iSqlErr;
				RETURN NVL(cCodRet,'');
			END IF;
		END  EXCEPTION

		--SET DEBUG FILE TO '/RESPALDOSNEW/gpe/sp_obtiene_tabla_amortizacion.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
/*		SELECT fecha_hoy - 1 units day ---SE COMENTA PARA PRUEBAS
			INTO dfechahoy
		FROM bdicred:"informix".sd_fechas;
*/		
		LET dfechahoy = MDY(MONTH(vFechaHoy),DAY(vFechaHoy),YEAR(vFechaHoy));
		--RQI 27 231 Se contemplan productos 9100 y 9300 para impresion de tabla de amortiza en Edo Cta
			FOREACH
					 SELECT  a.num_credito
							  INTO pNumCred
							  FROM "informix".sd_encabezado_edoctacrd a
							 WHERE  a.fecha_emision = dfechahoy
							   --AND a.empresa = pempresa
								AND a.num_producto IN ('6300','7600','7700','6800','9100','9300')
								AND a.ind_tabla_amortizacion = 1

								
					-- SE OBTIENEN LOS PARAMETROS PARA VALIDAR EL MONTO Y EL PLAZO DEL CREDITO,
					--INCLUYE EL ENGANCHE PAGADO DE LA REESTRUCTURA
					SELECT plazo, periodo_plazo,fecha_apertura,
						num_producto,valor_preferencial,tasa_interes::CHAR(6),sucursal,fecha_vencim
					INTO dPlazo,cFrecuencia,dtFechaCouta,
						cProducto,dEnganchePag,cTasaFija, pSucursal,dFecha_vencim
					FROM "informix".sd_maecredcrd
					WHERE empresa = pEmpresa AND num_credito = pNumCred
					AND status_cred IN ('AA','E1', 'FF');
					
					IF NVL(cProducto,'') = '' THEN
						--LET cCodRet = '001042';
						CONTINUE FOREACH;
					END IF;
					
					INSERT INTO "informix".sd_amortizacion_creditoedoctacrd (
							fecha_emision ,num_credito ,monto_ahorro ,num_periodo ,fecha_pago ,pago_capital, intereses  ,iva_intereses ,monto_pago  ,
							saldo_insoluto ,sum_capital ,sum_intereses ,sum_iva_intereses  ,sum_pagomin  )
					VALUES(dfechahoy,pNumCred, 0.00,0,dtFechaCouta ,0.00,0.00,0.00,
							0.00,0.00,0.00,0.00,0.00,0.00);
					LET dTotAhorro = 0.00;
					--SE TOMA COMO REFERENCIA LA FECHA DE APERTURA PARA PP
					LET dtFechaCoutaAux = dtFechaCouta;

					--SI ES CREDINOMINA RESPETA RESPETA LA FECHA ACTUAL
					SELECT fecha_hoy
					INTO dtFechaActual
					FROM "informix".sd_fechas
					WHERE empresa = pEmpresa ;

					-- CONSULTA SALDO INICIAL PARA PP Y RTC, MONTO DE TOTAL A PAGAR PARA PRESTAMO PERSONAL
					SELECT  sdo_cap_insoluto,mto_capitalizado
					INTO  dSdoInicial,dMtoTotalaPagar
					FROM "informix".sd_maesdoscrd
					WHERE num_credito = pNumCred
					AND empresa = pEmpresa;

					
	   
					--NUMERO DE PAGOS REALIZADOS
					SELECT COUNT(num_credito)
					INTO iPagosRealizados
					FROM "informix".sd_amortiza_creditocrd
					WHERE empresa = pEmpresa
					AND num_credito = pNumCred
					AND capital_status = '5';

					-- SE OBTIENE EL I.V.A
					SELECT valor
					INTO dIva
					FROM "informix".sd_param
					WHERE empresa = '001'
					AND cod_param = '12';

					-- SE OBTIENE LA TASA ANUAL
					
					SELECT a.factor_sobretasa, a.sobretasa, plazo_max_cred
					  INTO cFactor_SobreTasa,  dSobreTasa, sPlazoMax
					  FROM "informix".sd_definicion a
					 WHERE a.num_producto = cProducto;
					
					LET dTasa = cTasaFija; -- Calculo de intereses diarios se hace en base a la tasa del credito ya que varia por credito.
					
					
					--MONTO DE LA MENSUALIDAD
					--OBTIENE LA FECHA CUOTA PARA LA PRIMERA MENSUALIDAD
					SELECT capital_mto_cuota,fecha_cuota
					INTO dCapacidadPres,dtFechaIniRtc
					FROM "informix".sd_amortiza_creditocrd
					WHERE num_credito = pNumCred
					AND  num_pago = 1;
					
					
						--TASA DE INTERES FIJA ANUAL
						IF NVL(cTasaFija,'') <> '' THEN
							LET cCadena1 = SUBSTR(cTasaFija, 0, INSTR(cTasaFija, '.')-1);
							LET cCadena2 = (cTasaFija - cCadena1); 
							LET cCadena2 = SUBSTR(cCadena2, 3, INSTR(cCadena2, '.')-1);
							LET cTasaFija = TRIM(cCadena1)  || '.' || TRIM(cCadena2);
							LET dTasaFija = NVL(TRIM(cTasaFija)::DECIMAL(18,2),0);
						END IF;
						
						--plazo origen del prÃÂÃÂ©stamo
						LET iPlazo = dPlazo;
						
					---se revisa si es programa de apoyo.	
						SELECT COUNT(*) 
						INTO cBandera
						FROM bdicred:sd_programa_apoyo2020crd 
						WHERE  num_credito = pNumCred;

					IF cBandera > 0 THEN
					
						SELECT count(fecha_cuota) 
						 INTO cAmortiza
							FROM "informix".sd_amortiza_creditocrd
							WHERE empresa = pEmpresa
							AND num_credito = pNumCred;
							
							IF cAmortiza > dPlazo THEN
							 LET dPlazo = cAmortiza;
							END IF;
						--- se obtienen los  montos de INT e IVA de la maeretenido del prorama de apoyo
						SELECT monto
							INTO psaldoInteresApoyo
						FROM bdicred:sd_maeretenido 
						WHERE num_credito = pNumCred
							AND transacc = '8374'
							AND estatus = 'R';

							IF psaldoInteresApoyo IS NULL THEN
								LET psaldoInteresApoyo = 0;
							END IF;

						SELECT monto
							INTO psaldoIvaApoyo
						FROM bdicred:sd_maeretenido 
						WHERE num_credito = pNumCred
							AND transacc ='8375'
							AND estatus = 'R';

							IF psaldoIvaApoyo IS NULL THEN
								LET psaldoIvaApoyo = 0;
							END IF;
						
					END IF;
					
						LET dMontoAut = NVL(dSdoInicial,0);
						LET dPlazo = NVL(dPlazo,0) - NVL(iPagosRealizados,0);
						-- SE OBTIENE LA TASA ANUAL CON IVA
						LET dTasaInt = NVL(dTasa,0) / 100;
						LET dPlazoAux = NVL(dPlazo,0);

						IF cFrecuencia = 'M'  THEN --FRECUENCIA MENSUAL
							LET dPlazo = dPlazo * 1;
							LET iDiasPeriodo = 30;
						ELIF cFrecuencia = 'Q'  THEN --FRECUENCIA QUINCENAL
							LET dPlazo = dPlazo * 2;
							LET iDiasPeriodo = 15;
						END IF;

						LET dMensualidad = ROUND(dCapacidadPres,0);

						CALL "informix".monthadd(dtFechaCouta,iPagosRealizados) RETURNING dtFechaCouta;

						-- EL CICLO TENDRA EL NUMERO DE ITERACIONES IGUAL AL PLAZO DE PAGOS
						LET dtFechaInicial = dtFechaCouta;
						LET dtFechaAnt = dtFechaCouta;

						SELECT b.sdo_cap_insoluto
							  -- NVL(SUM(sdo_cap_insoluto + sdo_no_exig + int_tra_no_exig + mto_finan_vdo + mto_venc_int),0) --v_usted_debe_tc
						  INTO dSdoFinal
						  FROM sd_maecredcrd a, sd_maesdoshistcrd b
						 WHERE b.fecha = dfechahoy
						   AND a.empresa       = b.empresa
						   AND a.empresa       = pEmpresa
						   AND a.num_credito   = pNumCred
						   AND a.num_credito   = b.num_credito;
						
						---	Se suman los montos de interes e IVA del programa de apoyo a la deuda total

							IF psaldoInteresApoyo > 0 THEN
								LET dSdoAdeudTotal = 0;
								LET dSdoAdeudTotal = dSdoAdeudTotal + psaldoInteresApoyo + psaldoIvaApoyo;
								LET dSdoAdeudTotal_liquidar = psaldoInteresApoyo + psaldoIvaApoyo;
							END IF;
					
					IF dSdoFinal > 0 THEN 
							
							LET dMesesadicionales = round(dSdoFinal / dMensualidad) + 1 ;
							
							LET dPlazo =  dPlazo + dMesesadicionales;
							
							
							
							--es porque ya excedio elpretamo
							IF dSdoAdeudTotal > 0 THEN 
							
								LET dMesesadicionales = round(dSdoAdeudTotal / dMensualidad) + 1 ;
								LET dPlazo =  dPlazo + dMesesadicionales;

							END IF;

					END IF;

				IF dPlazo > 0 THEN
					
						
						FOR iContador = 1 TO dPlazo  STEP 1

							-- SE OBTIENE EL SALDO INICIAL DEL PERIODO, SI EL SALDO FINAL ES CERO 
							--QUIERE DECIR QUE ES EL PRIMER PERIODO Y EL SALDO INICIAL ES IGUAL AL MONTO APROBADO
							IF dSdoFinal > 0 THEN
								LET dSdoInicial = NVL(dSdoFinal,0);
							END IF;

							IF dSdoFinal <= 0 AND iContador > 1 THEN
								IF dSdoAdeudTotal <= 0 THEN
								EXIT FOR;
								ELSE 
								LET dSdoInicial = 0;
								END IF;
								
							END IF;

							--SE OBTIENEN LOS MESES DEL PERIODO
							LET iPeriodo = NVL(iContador,0) + NVL(iPagosRealizados,0);

							-- ********************************************************************************************************************
							-- ************************** SE OBTIENE LA SIGUIENTE FECHA DE CUOTA Y LOS DIAS DEL PERIODO **********************
							--*********************************************************************************************************************
							
								--OBTIENE LA FECHA DE LA SIGUIENTE FECHA DE PAGO
								CALL "informix".monthadd(dtFechaInicial,iContador) RETURNING dtFechaCouta;
								--OBTIENE LA FECHA DE LA FECHA DE PAGO ANTERIOR
								CALL "informix".monthadd(dtFechaInicial,iContador-1) RETURNING dtFechaAnt;

								--SI LA FECHA CUOTA O FECHA ANTERIOS ESTAN ENTRE LOS DIAS FESTIVOS 1 DE ENERO Y 25 DE DICIEMBRE
								--SE PASAN AL DIA SIGUIENTE
								IF (MONTH(dtFechaCouta) = 1 AND DAY(dtFechaCouta) = 1) OR (MONTH(dtFechaCouta) = 12 AND DAY(dtFechaCouta) = 25) THEN
									LET dtFechaCouta = dtFechaCouta + 1;
								END IF;

								IF (MONTH(dtFechaAnt) = 1 AND DAY(dtFechaAnt) = 1) OR (MONTH(dtFechaAnt) = 12 AND DAY(dtFechaAnt) = 25) THEN
									LET dtFechaAnt = dtFechaAnt + 1;
								END IF;

								IF iContador = 1 THEN
									IF NVL(iPagosRealizados,0 ) =0 THEN
										LET iDiasPeriodo = dtFechaCouta - dtFechaCoutaAux;
									ELSE
										LET iDiasPeriodo = dtFechaCouta - dtFechaAnt;
									END IF
								ELSE
									LET iDiasPeriodo = dtFechaCouta - dtFechaAnt;
								END IF;
							

							--SE CALCULAN LOS INTERESES
							LET dIntereses = NVL(dSdoInicial,0) * (NVL(dTasaInt,0) / 360) * NVL(iDiasPeriodo,0);
							-- SE CALCULA EL IVA DE LOS INTERESES
							LET dIvaInt = ROUND(NVL(dIntereses,0) * NVL(dIva,0),2);

							IF dMontoAut < dMensualidad and dSdoFinal > 0  THEN
							
								/*IF iPeriodo > iPlazo THEN
								--IF iPeriodo = '13' THEN--
								--LET dSdoInicial = '700';--
								--END IF;--
								LET dCapital = dSdoInicial ;
								LET dMensualidad = dSdoInicial ;
								ELSE*/
								LET dMensualidad = NVL(dMontoAut,0) + NVL(dIntereses,0) + NVL(dIvaInt,0);
								LET dCapital = NVL(dMontoAut,0);
								--END IF;
							ELSE
								/*IF iPeriodo > iPlazo THEN
								--IF iPeriodo = '13' THEN--
								--LET dSdoInicial = '700';--
								--END IF;--
								LET dCapital = NVL(dMensualidad,0);
								ELSE*/
								IF dSdoFinal > 0 THEN
								LET dCapital = NVL(dMensualidad,0) - (NVL(dIntereses,0) + NVL(dIvaInt,0));
								ELSE
								LET dCapital = 0;
								END IF;
								--END IF;
								LET dIntereses = NVL(dIntereses,0) ;
								LET dIvaInt  = NVL(dIvaInt,0) ;
								LET iDiasPeriodo= NVL(iDiasPeriodo,0);
							END IF;

							-- SE CALCULA EL SALDO FINAL
							LET dSdoFinal = NVL(dSdoInicial,0) - NVL(dCapital,0);
							
						   
							LET dMontoAut = NVL(dSdoInicial,0) - NVL(dCapital,0);
							
							
						IF 	dSdoFinal = 0 and dSdoAdeudTotal > 0 THEN
						
						
								
							--proporcional a intereses
							LET pProporcion = round(psaldoInteresApoyo / dSdoAdeudTotal,10);
							
							/*SELECT pago_capital, monto_pago,intereses  ,iva_intereses 
							INTO dUltpago_capital, dUltimopago, dUlt_interes, dUltiva
							FROM sd_amortizacion_creditoedoctacrd
							WHERE num_credito = pNumCred
							AND num_periodo <> 0
							AND saldo_insoluto = 0;*/
							
							LET dUltpago_capital  = dCapital;
							LET dUltimopago = dMensualidad;
							LET dUlt_interes = dIntereses;
							LET dUltiva = dIvaInt;
							
							IF dCapital > 0 THEN
							
								IF dMensualidad < dCapacidadPres AND (dSdoAdeudTotal - dMensualidad) = 0 THEN
									LET dInt_restante = dMensualidad;								ELSE
									--IF dMensualidad < dCapacidadPres AND dSdoAdeudTotal <= dMensualidad THEN
									--	LET dInt_restante = dSdoAdeudTotal;
									--ELSE
										IF dSdoAdeudTotal > dMensualidad AND dSdoAdeudTotal <= dCapacidadPres  THEN
											LET dInt_restante = dSdoAdeudTotal;
										ELSE
											LET dInt_restante = dCapacidadPres - dUltimopago ;
										END IF;
									--END IF;
								END IF;
							ELSE
								IF dSdoAdeudTotal < dMensualidad THEN
								LET dMensualidad = dSdoAdeudTotal;								--LET  dIntereses = psaldoInteresApoyo;
								--LET dIvaInt = 0;
								/*ELSE
								--LET dMensualidad = dMensualidad;
								LET dIntereses = dMensualidad - psaldoIvaApoyo;
								LET dIvaInt = psaldoIvaApoyo;*/
								END IF;
							LET dInt_restante = dMensualidad;
							END IF;
							LET dInteres_sumar =  dInt_restante * pProporcion;
							LET dIva_sumar = dInt_restante - dInteres_sumar;
							
							
							LET pFinal_intreses = dUlt_interes + dInteres_sumar;
							LET pFinal_iva =  dUltiva + dIva_sumar;
							LET DFinal_montopago = dUltpago_capital + pFinal_intreses + pFinal_iva;
							
							
							--IF dCapital > 0 THEN
								LET dIntereses = pFinal_intreses;
								LET dIvaInt = pFinal_iva;
								LET dMensualidad = DFinal_montopago;
							--ELSE 
								
							IF dCapital = 0 THEN	
								IF dSdoAdeudTotal > 0 THEN
								let psaldoInteresApoyo = psaldoInteresApoyo - dIntereses;
								let dSdoAdeudTotal = dSdoAdeudTotal - dMensualidad;								LET psaldoIvaApoyo = psaldoIvaApoyo - dIvaInt;
								END IF;
							 ELSE
								IF dSdoAdeudTotal > 0 THEN
								let psaldoInteresApoyo = psaldoInteresApoyo - dInteres_sumar;
								let dSdoAdeudTotal = dSdoAdeudTotal - (dInteres_sumar + dIva_sumar );								LET psaldoIvaApoyo = psaldoIvaApoyo - dIva_sumar;
								END IF;
							END IF;
							--END IF;
							
						END IF;
							
							INSERT INTO "informix".sd_amortizacion_creditoedoctacrd (
							fecha_emision ,num_credito ,monto_ahorro ,num_periodo ,fecha_pago ,pago_capital, intereses  ,iva_intereses ,
							monto_pago  ,
							saldo_insoluto ,sum_capital ,sum_intereses ,sum_iva_intereses  ,sum_pagomin  )
							VALUES(dfechahoy,pNumCred, 0.00,iPeriodo,dtFechaCouta ,dCapital,dIntereses,dIvaInt,
							dMensualidad,dSdoFinal,0.00,0.00,0.00,0.00);
							
						
						/*	UPDATE "informix".sd_amortizacion_creditoedoctacrd 
							set intereses = pFinal_intreses  ,iva_intereses = pFinal_iva , monto_pago = DFinal_montopago
							WHERE fecha_emision = dfechahoy
								AND num_credito = pNumCred
								AND num_periodo <> 0
								AND pago_capital > 0
							AND saldo_insoluto = 0;*/
							
							/*INSERT INTO "informix".sd_amortizacion_creditoedoctacrd (
							fecha_emision ,num_credito ,monto_ahorro ,num_periodo ,fecha_pago ,pago_capital, intereses  ,iva_intereses ,monto_pago  ,
							saldo_insoluto ,sum_capital ,sum_intereses ,sum_iva_intereses  ,sum_pagomin  )
							VALUES(dfechahoy,pNumCred, 0.00,iPeriodo,dtFechaCouta ,0.00,dInteresesN,dIvaIntN,
							dMensualidadN,0.00,0.00,0.00,0.00,0.00);*/
				
							
						END FOR;
			
				END IF;
					
							SELECT sum(pago_capital), sum(intereses), sum(iva_intereses), sum(monto_pago)
								INTO dSum_capital, dSum_intereses, dSum_iva_intereses, dSum_pagomin
							FROM  "informix".sd_amortizacion_creditoedoctacrd
								WHERE fecha_emision = dfechahoy
								AND num_credito = pNumCred;
								
							IF cBandera > 0 THEN
							LET dSum_capital = dSum_capital + dSdoAdeudTotal_liquidar;
							END IF;
							
							LET dTotAhorro = NVL(dTotAhorro,0) + NVL(dSum_intereses,0) + NVL(dSum_iva_intereses,0);
							
							UPDATE "informix".sd_amortizacion_creditoedoctacrd 
							set sum_capital = dSum_capital, sum_intereses = dSum_intereses, sum_iva_intereses = dSum_iva_intereses,  
							sum_pagomin = dSum_pagomin,
							monto_ahorro = dTotAhorro
							WHERE fecha_emision = dfechahoy
								AND num_credito = pNumCred
								AND num_periodo = '0';
								
							
			END FOREACH;
						
								
								
			RETURN NVL(cCodRet,'');
		
	END;
END PROCEDURE
DOCUMENT
'CREACION: GUADALUPE DE JESUS ESPINOZA VALENZUELA',
'FECHA: 29/08/2020 ',
'BD:BDICRED';

CREATE PROCEDURE "informix".valida_udi()
RETURNING CHAR(5); 


   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret             CHAR(3);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE vValor1	      DECIMAL(14,6);  
   DEFINE vDivUdi	      CHAR(2);
   DEFINE vClaseUdi	      CHAR(1);
   DEFINE vFecha            DATE;
   
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret;
   END EXCEPTION;

-- SET DEBUG FILE TO "valida_udi.out";
-- TRACE ON;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET cod_ret    = "000";
   LET vValor1	  = 0;
   LET vFecha     = "";
   LET vDivUdi	  = "";
   LET vClaseUdi  = "";

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
        
      -- ******************************************
      -- Consulta la fecha actual
      -- ******************************************
        SELECT prox_fecha INTO vFecha 
        FROM sd_fechas WHERE empresa='001';
      
      -- ******************************************
      -- Extrae Parametro de Codigo de Divisa UDI *
      -- ******************************************
      SELECT TRIM(valor) INTO vDivUdi
	  FROM bdinteg:si_param
      WHERE empresa = '001'
	  AND cod_param = 16;

      -- *****************************************
      -- Extrae Clase de Tipo de Cmabio para UDI *
      -- *****************************************
      SELECT TRIM(valor) INTO vClaseUdi
	  FROM sd_param
      WHERE empresa = '001'
	  AND cod_param = "336";


      -- **************
      -- Precio Inicio*
      -- **************
     
      SELECT precio_compra INTO vValor1
       	FROM bdinteg:si_tpcambio
        WHERE empresa = '001'
       	 AND divisa = vDivUdi
       	 AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
               	                 FROM bdinteg:si_tpcambio
                       	        WHERE empresa = '001'
                                AND divisa = vDivUdi
                               	AND fecha_tpcambio = vFecha
                                AND clase_tpcambio = vClaseUdi)
         AND hora_tpcambio=(SELECT MAX(hora_tpcambio)
               	                 FROM bdinteg:si_tpcambio
                       	        WHERE empresa = '001'
                       	   	  AND divisa = vDivUdi
                              AND fecha_tpcambio = vFecha
                              AND clase_tpcambio = vClaseUdi)
         AND clase_tpcambio = vClaseUdi;

	    IF vValor1 IS NULL THEN
            LET cod_ret = "900";
            RETURN cod_ret; 
	    END IF
	
END
	RETURN cod_ret; 

END PROCEDURE 
DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_actualiza_lincred_central(P_empresa CHAR(3), P_num_credito CHAR(20), Pmonto DECIMAL(18,2) , Ptipo CHAR(1),Pstatus CHAR(1),Pusuario CHAR(20))
              
RETURNING CHAR(6),
          VARCHAR(80);  
--Héctor Manuel Bojórquez Ruelas
--08  DE Junio DE 2011
--actualiza la linea de credito central y genera un movimiento en la movdia, así como tambien genera un registro del crédito en sd_bitacora_aumlincred y en  sd_autorizacion_aumlincred
--Folio 1258-BitácoraIncrementoLinCred

		  
--Roque Enrique Solis Campaña 
--20  DE DICIEMBRE DE 2008
--actualiza la linea de credito central y genera un movimiento en la movdia 
--19 DE FEBRERO DE 2009
--El movimiento se genera con la cantidad la diferencia del monto actual y el monto nuevo


--Modificación	  
--Juan Daniel Lazalde Centeno
--12  DE FEBRERO DE 2014
--Identificar si el usuario, que esta realizando la operación esta registrado en la tabla bdicred:sd_perfiles_cac_aumlincred y ponga en el campo roigen = "S" Sucursal 
--*************************************************************************
--                         DEFINICION DE VARIABLES
--*************************************************************************
DEFINE scod_ret 		CHAR(6);
DEFINE cCod_ret 		CHAR(6);
DEFINE vsqlerr 			INTEGER;

DEFINE c_num_producto 	CHAR(4);
DEFINE c_divisa 		CHAR(2);
DEFINE c_sucursal 		CHAR(4);
DEFINE d_fecha_hoy 		DATE;
DEFINE c_transacc_suc 	CHAR(4);
DEFINE c_folio_suc 		VARCHAR(20);
DEFINE p_cod_ret 		VARCHAR(10);
DEFINE p_mensaje 		VARCHAR(80);
DEFINE d_hora           DATETIME HOUR TO SECOND;
DEFINE cDif			    CHAR (1);
DEFINE mMontoanterior   DECIMAL(18,2);
DEFINE cNum_cte         CHAR(20);
DEFINE cNombre_cte      CHAR(100);
DEFINE mMontoMov        DECIMAL(18,2);
DEFINE mMontoDif        DECIMAL(18,2);
DEFINE v_nombre_usuario CHAR(100);
DEFINE cNumCte          CHAR(20);
DEFINE cGradoRiesgo     CHAR(2);
DEFINE dMontoReserva    DECIMAL(18,2);
DEFINE valorsm			DECIMAL(18,2);
DEFINE smblinsug		DECIMAL(18,2);
DEFINE cCalifBuro       CHAR(1);
DEFINE cMotivoRechazo   CHAR(255);
DEFINE cCompromiso      DECIMAL(14,2);
DEFINE iReg             INTEGER;
DEFINE cOrigen          CHAR(1);


-- *************************************************************************
-- *                        ASIGNACION DE VARIABLES
-- **************************************************************************

LET scod_ret		 = "000000";
LET cCod_ret		 = "000000";
LET vsqlerr			 = 0;
LET c_num_producto	 ="";
LET c_divisa		 ="";
LET c_sucursal		 ="";
LET d_fecha_hoy		 = DATE(1);
LET c_transacc_suc	 ="";
LET c_folio_suc		 ="";
LET p_cod_ret		 ="";
LET p_mensaje		 =""; 	
LET d_hora           = CURRENT HOUR TO SECOND;
LET cDif			 ="";
LET mMontoanterior	 = 0;
LET cNum_cte		 ="";
LET cNombre_cte		 ="";
LET mMontoMov 	     = 0;
LET mMontoDif        = 0;
LET v_nombre_usuario = "";
LET cNumCte          = "";
LET cGradoRiesgo     = "";
LET dMontoReserva    = 0;
LET valorsm			 = 0;
LET smblinsug	     = 0;
LET cCalifBuro       = ""; 
LET cMotivoRechazo   = "";
LET cCompromiso      = 0;
LET cOrigen          = "";

-- **********************************************************************
-- *                        CONTROL DE ERRORES
-- ***********************************************************************
BEGIN
    ON EXCEPTION SET vsqlerr
       IF vsqlerr != 0 THEN
          LET scod_ret=vsqlerr;
		  ROLLBACK WORK;
          RETURN scod_ret, p_mensaje ;
       END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/respaldosbd/hectorb/actualiza_lincred.out";
	--TRACE ON;

    -- **********************************************************************
    -- *                        PROGRAMA PRINCIPAL
    -- **********************************************************************
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN WORK;
	
	IF EXISTS(SELECT num_credito FROM "informix".sd_maesdos where empresa=P_empresa AND num_credito=P_num_credito) THEN
	   
	   EXECUTE PROCEDURE bdicred:"informix".sp_consultacredito_central( P_empresa, P_num_credito) INTO p_cod_ret, p_mensaje, cNum_cte,cNombre_cte,mMontoanterior ;
        
		UPDATE "informix".sd_maesdos
		SET monto_otorgado=Pmonto
		WHERE empresa=P_empresa AND num_credito=P_num_credito;
		
		SELECT num_producto, sucursal , divisa, numcte 
		INTO   c_num_producto, c_sucursal, c_divisa, cNum_cte
		FROM   "informix".sd_maecred
		WHERE  empresa     = P_empresa
		AND    num_credito = P_num_credito;

		--Obtener la fecha del dia	
		SELECT fecha_hoy
		INTO   d_fecha_hoy
		FROM   "informix".sd_fechas
		WHERE  empresa = P_empresa;
        
		-- obtener el valor del salario minimo de la zona C
		SELECT valor 
		INTO valorsm
		FROM "informix".sd_param 
		WHERE empresa   = P_empresa 
		AND cod_param = '013';
		
		
		SELECT grado_riesgo,NVL(reserva_calificacion,0.00)
		INTO cGradoRiesgo, dMontoReserva
		FROM "informix".sd_hist_reserva
		WHERE  empresa     = P_empresa
		AND    num_credito = P_num_credito
		AND   fecha_cierre = (SELECT  MAX(fecha_cierre)
                    FROM "informix".sd_hist_reserva
                    WHERE  empresa     = P_empresa
                    AND    num_credito = P_num_credito);
		
		
	    LET  c_transacc_suc  = '0000';
		LET  c_folio_suc = 'Act LineaCredito';
        
        IF mMontoanterior < Pmonto THEN
		    LET cDif = '1';
            LET mMontoDif = Pmonto-mMontoanterior;
		ELSE
		    LET cDif = '2';
            LET mMontoDif = mMontoanterior-Pmonto;
		END IF;

		EXECUTE PROCEDURE "informix".genmov( P_empresa, P_num_credito
                                 , c_num_producto , cDif
                                 ,'008' , d_fecha_hoy
                                 , mMontoDif , c_folio_suc
                                 , c_sucursal, c_divisa
                                 , c_transacc_suc
                                 ) INTO p_cod_ret, p_mensaje;

		IF p_cod_ret::INTEGER > 0 THEN
			LET scod_ret= '000002'; 
			LET p_mensaje="Ocurrio un error al guardar los movimientos del credito en el SP bdicred:genmov";	   	
			RETURN scod_ret, p_mensaje;   
		END IF;

		LET smblinsug = Pmonto / (30.42 * valorsm);
				
		---Obtiene la  calificacion buro para actualizar el campo  califica_buro de la tabla sd_bitacora_aumlincred
		EXECUTE PROCEDURE bdisolic:"informix".cal_circulocredito_cjunk(P_empresa, cNum_cte, P_num_credito) 
		INTO  cCod_ret, 	    -- Codigo de Retorno
              cCalifBuro,	    -- Calificacion 1 Aprobado, 0 Rechazado
		      cCompromiso,      -- Compromisos > 0 si Calificacion es 1
		      cMotivoRechazo;   -- Descripcion de Creditos Motivo de Rechazo
		
		
		--Lazalde: Validar si el usuario existe en sd_perfiles_cac_aumlincred para identificar a que origen "SUCURSAL ó CENTRAL" se esta realizando el incremento de linea de crédito
		IF EXISTS(SELECT ejecutivo FROM "informix".sd_perfiles_cac_aumlincred where empresa = P_empresa AND ejecutivo = Pusuario) THEN
			LET cOrigen = 'S';
		ELSE
			LET cOrigen = 'C';
		END IF
		
		
		INSERT INTO "informix".sd_bitacora_aumlincred
		(empresa, num_solicitud,numcte,num_producto,status,causa_status,fecha_status,hora_status,sucursal,lincred_actual,lincred_sugerida,
		smb_lincred,grado_riesgo,monto_reserva,califica_buro,resp_cte,mensaje,ejecutivo,sucursal_at,origen,user_insert,fecha_insert, flagporsistema)
		VALUES (P_empresa,P_num_credito,cNum_cte,'6001','AP','',d_fecha_hoy,d_hora,c_sucursal,mMontoanterior,Pmonto,smblinsug,
		cGradoRiesgo,dMontoReserva,cCalifBuro,'1',Ptipo, Pusuario,'0000',cOrigen,Pusuario,d_fecha_hoy, 1);

		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET scod_ret = "000004";
			LET p_mensaje = "Ocurrio un error al guardar la información en la bitacora de aumento de linea de crédito";
			RETURN scod_ret, p_mensaje;   
		END IF;
		

		INSERT INTO "informix".sd_autorizacion_aumlincred 
		(empresa, num_solicitud, status,causa_status,user_insert,fecha_status,fecha_insert, revision_cac)     		
		VALUES(P_empresa,P_num_credito,'AP','',Pusuario,d_fecha_hoy,d_fecha_hoy,0);
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET scod_ret = "000005";
			LET p_mensaje = "Ocurrio un error al guardar la información en la bitacora de autorización de aumento de linea de crédito";
			RETURN scod_ret, p_mensaje;   
		END IF;

	ELSE
       LET scod_ret= '000001'; 
       LET p_mensaje="No es posible realizar la actualizacion";	   
	END IF
	
	IF p_cod_ret::INTEGER = 0 AND scod_ret::INTEGER = 0 THEN
		COMMIT WORK;
	ELSE
	  ROLLBACK WORK;
    END IF;	  
	
    RETURN scod_ret, p_mensaje;   
          
END;
END PROCEDURE;