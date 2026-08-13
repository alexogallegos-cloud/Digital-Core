CREATE PROCEDURE "informix".sp_ofi_consultasdos_pba(pEmpresa CHAR(3),pNumCredito CHAR(20),pSucursal CHAR(4))
RETURNING
	CHAR(5) AS Cod_Ret, 
	CHAR(80)  AS Mensaje_retorno,
	CHAR(20) AS Num_credito,
	CHAR(40) AS Producto,
	CHAR(20) AS Num_cliente,
	CHAR(150) AS Nom_cliente,
	MONEY(18,2) AS Linea_otorgada,
	DATE AS Fecha_origen,
	DECIMAL(18,2) AS saldo_ultimoCorte,
	MONEY(18,2) AS Interes_moratorio,
	MONEY(18,2) AS Iva_InteresMoratorio,
	MONEY(18,2) AS Total_liquidacion,
	MONEY(18,2) AS Pagos_vdos,
	INTEGER AS pagos_realizados,
	INTEGER AS plazo,
	DATE AS Fecha_ProximoPago,
	MONEY(18,2) AS Pago_minimo,
	MONEY(18,2) AS Saldar,
	DECIMAL(18,2) AS Ahorro,
	MONEY(18,2) As Deuda, 
-- se agregan datos de intereres y comisiones
	MONEY(18,2) AS Pago_Realizado,
	MONEY(18,2) AS Interes_devengado,
	MONEY(18,2) AS Iva_Interes_devengado,
	MONEY(18,2) AS Comision,
	MONEY(18,2) AS Iva_Comision;
	
	---DECLARACIONES
    DEFINE iSqlErr         INTEGER;
    DEFINE iIsamErr        INTEGER;
    DEFINE cErrorInfo      CHAR(80);
    DEFINE cCodRet         CHAR(6);
	DEFINE cMensajeRet   	CHAR(80);
    DEFINE iNRows           INTEGER;
	DEFINE dSdoUltCorte		DECIMAL(18,2);
	DEFINE dSumaInteres		DECIMAL(18,2);
	DEFINE dSumaIvaInteres	DECIMAL(18,2);
	DEFINE dAhorroPago		DECIMAL(18,2);
	DEFINE sNumCuotasVig	SMALLINT;
	DEFINE dtFechaHoy		DATE;
	DEFINE dtAnio			DATE;
	DEFINE dtMES			DATE;
	DEFINE cSiglasProd		CHAR(2);
	DEFINE iFrecuenciaPago	INTEGER;
	DEFINE mCapital		    MONEY(18,2);
	DEFINE dMontoFinanciado	DECIMAL(18,2);
	DEFINE dIva				MONEY(18,2); 
	DEFINE dComisionesPendientes MONEY(18,2);
	DEFINE dIvaComisionesPendientes MONEY(18,2); 
	DEFINE mMontoMin		DECIMAL(18,6);		-- MONTO MINIMO
	DEFINE mMontoMax		DECIMAL(18,6);		-- MONTO MAXIMO
	
	DEFINE cCodRetCD		CHAR(6);   
	DEFINE cMensajeCD 		CHAR(80); 
    DEFINE cNumCredCD 		CHAR(20); 
	DEFINE cNumCteCD 		CHAR(20);  
	DEFINE cNomProductoCD	CHAR(40);
    DEFINE cNumTarjetaCD    CHAR(20); 
    DEFINE cNomCteCD     	CHAR(150);
    define wdiacorte        smallint;
    define wFechamesiver, wFechafactura date;
	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	DEFINE cCsg_codigo_ret			CHAR(6);
	DEFINE cCsg_mensaje_ret			CHAR(80);
	DEFINE cCsg_num_credito			CHAR(20);
	DEFINE cCsg_cod_tipcred			CHAR(2);
	DEFINE dtCsg_fec_origen			DATE;
	DEFINE dtCsg_fec_prox_pago		DATE;
	DEFINE mCsg_pago_min			MONEY(18,2);
	DEFINE dtCsg_fec_ult_pago		DATE;
	DEFINE iCsg_plazo				INTEGER;
	DEFINE iCsg_pagos_realizados	INTEGER;
	DEFINE mCsg_linea_otorgada		MONEY(18,2);
	DEFINE mCsg_tasa_interes			DECIMAL(9,6);
	DEFINE dCsg_tasa_moratorios		DECIMAL(9,6);
	DEFINE dCsg_monto_sbc			DECIMAL(14,2);
	DEFINE mCsg_cap_vig				MONEY(18,2);
	DEFINE mCsg_cap_trans			MONEY(18,2);
	DEFINE mCsg_cap_vdo_exig		MONEY(18,2);
	DEFINE mCsg_cap_vdo_no_exig		MONEY(18,2);
	DEFINE mCsg_sdo_act_total_cap	MONEY(18,2);
	DEFINE mCsg_int_vig				MONEY(18,2);
	DEFINE mCsg_int_vdo				MONEY(18,2);
	DEFINE mCsg_int_moratorios		MONEY(18,2);
	DEFINE mCsg_int_mes				MONEY(18,2);
	DEFINE mCsg_sdo_act_total_int	MONEY(18,2);
	DEFINE mCsg_iva_int_vig			MONEY(18,2);
	DEFINE mCsg_iva_int_vdo			MONEY(18,2);
	DEFINE mCsg_iva_int_moratorios	MONEY(18,2);
	DEFINE mCsg_iva_int_mes			MONEY(18,2);
	DEFINE mCsg_sdo_act_total_iva	MONEY(18,2);
	DEFINE mCsg_com_pend			MONEY(18,2);
	DEFINE mCsg_iva_com				MONEY(18,2);
	DEFINE mCsg_sdo_retenido		MONEY(18,2);
	DEFINE mCsg_tot_liquidacion		MONEY(18,2);
	DEFINE mCsg_int_devengado		MONEY(18,2);
	DEFINE mCsg_iva_int_devengado	MONEY(18,2);
	DEFINE mCsg_linea_disp			MONEY(18,2);
	DEFINE mCsg_pagos_vdos			MONEY(18,2);
	DEFINE cCsg_desc_status_cred	CHAR(60);
	DEFINE iCsg_id_bloqueo_cred		INTEGER;
	DEFINE cCsg_bloqueo_cta			CHAR(60);
	DEFINE cCsg_id_causa_bloq_cred	CHAR(3);
	DEFINE cCsg_causa_bloqueo_cta	CHAR(50);
	DEFINE cCsg_id_sit_esp_cte		CHAR(1);
	DEFINE iCsg_id_causa_esp_cte	INTEGER;
	DEFINE cCsg_sit_esp_cte			CHAR(75);
	DEFINE cCsg_id_sit_esp_cred		CHAR(1);
	DEFINE iCsg_id_causa_esp_cred	INTEGER;
	DEFINE cCsg_sit_esp_cred		CHAR(75);
	
	-- VARIABLES DEL PROCESO BDISOLIC: sp_proyecta_prestamos
	DEFINE pp_CodRet 			CHAR(6);
	DEFINE pp_Periodo 			INTEGER;
	DEFINE pp_FechaCuota 		DATE;
	DEFINE pp_SaldoInicial		DECIMAL(18,2);
	DEFINE pp_Mensualidad   	DECIMAL(18,2);
	DEFINE pp_Intereses     	DECIMAL(18,2);
	DEFINE pp_IvaIntereses		DECIMAL(18,2);
	DEFINE pp_Capital			DECIMAL(18,2);
	DEFINE pp_SaldoFinal		DECIMAL(18,2);
	DEFINE pp_DiasPeriodo		SMALLINT;
	DEFINE pp_FechaAper	        DATE;
	
	DEFINE dMonto_Autorizado 	DECIMAL(18,6);
	DEFINE iPlazo 				INTEGER;
	DEFINE dCapacidad_Pres		DECIMAL(18,6);
	DEFINE cProducto 			CHAR(4);
	DEFINE cSucursal 			CHAR(4);
	DEFINE sTipoRetorno 		SMALLINT;
	DEFINE sSolicitudes 		SMALLINT;
	DEFINE dtFecha 				DATE;
	-- VARIABLES DEL PROCESO bdicred: sp_ofi_validacredito
	DEFINE cCodRet_vc 			CHAR(6);
	DEFINE cMensajeRet_vc	  	CHAR(80);
	DEFINE cNumProducto_vc	  	CHAR(4);
	DEFINE cNomProducto_vc		CHAR(40);
	DEFINE cNomCliente_vc		CHAR(40);
	DEFINE cNumCte_vc 			CHAR(20);  


    define wabonos_his, wmora_his, wivamora_his DECIMAL(18,2);
    define wabonos_dia, wmora_dia, wivamora_dia DECIMAL(18,2);
    define wintvencido_his, wivaintvencido_his  DECIMAL(18,2); 
    define wintvencido_dia, wivaintvencido_dia  DECIMAL(18,2); 
    define iFechaProceso                        date;
    define wnumpago                             integer;
    define wtasas                               DECIMAL(18,2); 
    define wpagomes                             DECIMAL(18,2);  

	---INICIALIZACIONES
    LET iSqlErr            = 0;
    LET iIsamErr           = 0;
    LET cErrorInfo         = "";
    LET cMensajeRet        = "PROCESO EXITOSO";
    LET cCodRet            = "00000";
    LET iNRows             = 0;
	LET dSdoUltCorte	   = 0.0;
	LET dSumaInteres	   = 0.0;
	LET dSumaIvaInteres	   = 0.0;
	LET dAhorroPago		   = 0.0;
	LET sNumCuotasVig	   = 0;
	LET dtFechaHoy		   = MDY(1,1,1900);
	LET dtAnio		   	   = MDY(1,1,1900);
	LET dtMes		   	   = MDY(1,1,1900);
	LET cSiglasProd		   = "";
	LET iFrecuenciaPago	   = 0;
	LET mCapital	   = 0;
	LET dMontoFinanciado	   = 0;
	LET dIva			   = 0; 
	LET dComisionesPendientes    = 0;
	LET dIvaComisionesPendientes   = 0;
	LET mMontoMin		= 0;
	LET mMontoMax		= 0;
	
	LET cCodRetCD			= "";
	LET cMensajeCD 			= "";
    LET cNumCredCD 			= "";
	LET cNumCteCD 			= "";
	LET cNomProductoCD		= "";
    LET cNumTarjetaCD    	= "";
    LET cNomCteCD     		= "";
	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	LET cCsg_codigo_ret				= "00000";
	LET cCsg_mensaje_ret			= "";
	LET cCsg_num_credito			= "";
	LET cCsg_cod_tipcred			= "";
	LET dtCsg_fec_origen			= MDY(1,1,1900);
	LET dtCsg_fec_prox_pago			= MDY(1,1,1900);
	LET mCsg_pago_min				= 0.0;
	LET dtCsg_fec_ult_pago			= MDY(1,1,1900);
	LET iCsg_plazo					= 0;
	LET iCsg_pagos_realizados		= 0;
	LET mCsg_linea_otorgada			= 0.0;
	LET mCsg_tasa_interes			= 0.0;
	LET dCsg_tasa_moratorios		= 0.0;
	LET dCsg_monto_sbc				= 0.0;
	LET mCsg_cap_vig				= 0.0;
	LET mCsg_cap_trans				= 0.0;
	LET mCsg_cap_vdo_exig			= 0.0;
	LET mCsg_cap_vdo_no_exig		= 0.0;
	LET mCsg_sdo_act_total_cap		= 0.0;
	LET mCsg_int_vig				= 0.0;
	LET mCsg_int_vdo				= 0.0;
	LET mCsg_int_moratorios			= 0.0;
	LET mCsg_int_mes				= 0.0;
	LET mCsg_sdo_act_total_int		= 0.0;
	LET mCsg_iva_int_vig			= 0.0;
	LET mCsg_iva_int_vdo			= 0.0;
	LET mCsg_iva_int_moratorios		= 0.0;
	LET mCsg_iva_int_mes			= 0.0;
	LET mCsg_sdo_act_total_iva		= 0.0;
	LET mCsg_com_pend				= 0.0;
	LET mCsg_iva_com				= 0.0;
	LET mCsg_sdo_retenido			= 0.0;
	LET mCsg_tot_liquidacion		= 0.0;
	LET mCsg_int_devengado			= 0.0;
	LET mCsg_iva_int_devengado		= 0.0;
	LET mCsg_linea_disp				= 0.0;
	LET mCsg_pagos_vdos				= 0.0;
	LET cCsg_desc_status_cred		= "";
	LET iCsg_id_bloqueo_cred		= 0;
	LET cCsg_bloqueo_cta			= "";
	LET cCsg_id_causa_bloq_cred		= "";
	LET cCsg_causa_bloqueo_cta		= "";
	LET cCsg_id_sit_esp_cte			= "";
	LET iCsg_id_causa_esp_cte		= 0;
	LET cCsg_sit_esp_cte			= "";
	LET cCsg_id_sit_esp_cred		= "";
	LET iCsg_id_causa_esp_cred		= 0;
	LET cCsg_sit_esp_cred			= "";
	
	-- VARIABLES DEL PROCESO BDISOLIC: sp_proyecta_prestamos
	LET pp_CodRet 					= "";
	LET pp_Periodo 					= 0;
	LET pp_FechaCuota 				= MDY(1,1,1900);
	LET pp_SaldoInicial				= 0;
	LET pp_Mensualidad   			= 0;
	LET pp_Intereses     			= 0;
	LET pp_IvaIntereses				= 0;
	LET pp_Capital					= 0;
	LET pp_SaldoFinal				= 0;
	LET pp_DiasPeriodo				= 0;
	LET pp_FechaAper	        	= MDY(1,1,1900);
	--VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_ofi_validacredito
	LET cCodRet_vc 			= "";
	LET cMensajeRet_vc	  	= "";
	LET cNumProducto_vc	  	= "";
	LET cNomProducto_vc		= "";
	LET cNomProducto_vc		= "";
	LET cNumCte_vc			= "";
	
	LET dMonto_Autorizado 			= 0.0;
	LET iPlazo 						= 0;
	LET dCapacidad_Pres				= 0.0;
	LET cProducto 					= "";
	LET cSucursal 					= "";
	LET sTipoRetorno 				= 0;
	LET sSolicitudes 				= 0;
	LET dtFecha 					= MDY(1,1,1900);
    let wdiacorte                   = 0;
    let wFechamesiver               = date(1);
    let wFechafactura               = date(1);
    let wabonos_his                 = 0;
    let wmora_his                   = 0;
    let wivamora_his                = 0;
    let wintvencido_his             = 0;
    let wivaintvencido_his          = 0;
    let wabonos_dia                 = 0;
    let wmora_dia                   = 0;
    let wivamora_dia                = 0;
    let wintvencido_dia             = 0;
    let wivaintvencido_dia          = 0;
    let iFechaProceso               = date(1);
    let wnumpago                    = 0;
    let wtasas                      = 0;
    let wpagomes                    = 0;



BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
		  LET cMensajeRet= cErrorInfo;
          RETURN cCodRet,cMensajeRet,'','','','',0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0;
       END IF;
    END EXCEPTION;
		
  	--SET DEBUG FILE TO "/tmp/sp_ofi_consultasdos.out";
	--TRACE ON;
    
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	-- VALIDA LOS PARAMETROS DE ENTRADA
	IF NVL(pEmpresa,"") =  "" OR NVL(pNumCredito,"") = ""   OR NVL(pSucursal,"") = "" THEN
		LET cCodRet = '00361';
		LET cMensajeRet= 'PARAMETROS INVALIDOS';
		RETURN cCodRet,cMensajeRet,'','','','',0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0;
	END IF 
	
	-- OBTIENE LOS DATOS DEL PRESTAMO/REESTRUCTURA/CREDINOMINA
	EXECUTE PROCEDURE "informix".sp_consulta_datos_general(pEmpresa, '',pNumCredito,'','','','')
	INTO cCodRetCD,cMensajeCD,cNumCredCD,cNumCteCD,cNomProductoCD,cNumTarjetaCD,cNomCteCD;
	IF cCodRetCD::INTEGER <> 0 THEN
		LET cCodRet = '00363';
		LET cMensajeRet= cMensajeCD;
		RETURN cCodRet,cMensajeRet,'','','','',0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0;
	END IF
	
	-- OBTIENE LOS SALDOS DEL  PRESTAMO/REESTRUCTURA/CREDINOMINA
	EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(pEmpresa,pNumCredito)
	INTO  cCsg_codigo_ret,cCsg_mensaje_ret,cCsg_num_credito,cCsg_cod_tipcred,dtCsg_fec_origen,dtCsg_fec_prox_pago,mCsg_pago_min,
			dtCsg_fec_ult_pago,iCsg_plazo,iCsg_pagos_realizados,mCsg_linea_otorgada,mCsg_tasa_interes,dCsg_tasa_moratorios,
			dCsg_monto_sbc,mCsg_cap_vig,mCsg_cap_trans,mCsg_cap_vdo_exig,mCsg_cap_vdo_no_exig,mCsg_sdo_act_total_cap,mCsg_int_vig,
			mCsg_int_vdo,mCsg_int_moratorios,mCsg_int_mes,mCsg_sdo_act_total_int,mCsg_iva_int_vig,mCsg_iva_int_vdo,mCsg_iva_int_moratorios,
			mCsg_iva_int_mes,mCsg_sdo_act_total_iva,mCsg_com_pend,mCsg_iva_com,mCsg_sdo_retenido,mCsg_tot_liquidacion,mCsg_int_devengado,
			mCsg_iva_int_devengado,mCsg_linea_disp,mCsg_pagos_vdos,cCsg_desc_status_cred,iCsg_id_bloqueo_cred,cCsg_bloqueo_cta,
			cCsg_id_causa_bloq_cred,cCsg_causa_bloqueo_cta,cCsg_id_sit_esp_cte,iCsg_id_causa_esp_cte,cCsg_sit_esp_cte,cCsg_id_sit_esp_cred,
			iCsg_id_causa_esp_cred,cCsg_sit_esp_cred;
	IF cCsg_codigo_ret::INTEGER <> 0 THEN
		LET cCodRet = '00364';
		LET cMensajeRet= cCsg_mensaje_ret;
		RETURN cCodRet,cMensajeRet,'','','','',0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0;
	END IF
	
	
	--se obtiene el iva de la sucursal	
	SELECT iva  
	INTO dIva
	FROM bdinteg:"informix".si_sucursales 
	WHERE sucursal = pSucursal;

	
	--se obtiene el iva de la sucursal	
	SELECT nvl(dia_corte::smallint,0)
	INTO wdiacorte
	FROM bdicred:"informix".sd_maecredanexocrd
    WHERE empresa = pEmpresa
       AND num_credito = pNumCredito;
	
    execute procedure "informix".sp_fecha_plazo(pEmpresa,wdiacorte)
    into cCodRet, wFechamesiver, wFechafactura;

    if (cCodRet <> '00000') then
		LET cCodRet = '00361';
		LET cMensajeRet= 'PARAMETROS INVALIDOS';
		RETURN cCodRet,cMensajeRet,'','','','',0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0;
   end if;

	-- OBTENER EL SALDO AL ULTIMO CORTE
	SELECT sdo_cap_insoluto + -- capital_total_corte,
           sdo_no_exig + -- interes_vigente_corte, 
           mto_finan_vdo + --iva_vigente_corte,  
           int_tra_no_exig + -- interes_vencido_corte, 
           mto_venc_int, -- iva_vencido_corte, 
--           round((sdo_contab_mora + sdo_moratorio) * (1 + dIva::float),2), -- moratorio_corte
            fecha
      INTO dSdoUltCorte,dtFecha
      FROM "informix".sd_maesdoshistcrd h
    WHERE h.empresa = pEmpresa
       AND h.num_credito = pNumCredito
       AND h.fecha  = wFechafactura;

-- se agrega el total vencido de la cuenta    
    let mCsg_cap_vdo_exig = mCsg_cap_vdo_exig + mCsg_cap_trans + mCsg_int_vdo + mCsg_iva_int_vdo + mCsg_int_moratorios + mCsg_iva_int_moratorios;

    SELECT nvl(capital_mto_cuota,0)
     into mCsg_cap_vdo_exig
    FROM bdicred:sd_amortiza_creditocrd a
    WHERE empresa = pEmpresa
      AND num_credito = pNumCredito
      AND num_pago = 1;

    SELECT  nvl(sum(CASE WHEN codigo_ref = 1 AND fecha_mov > wFechamesiver THEN monto ELSE 0 END),0), --MENOS SUS ABONOS
            nvl(sum(CASE WHEN codigo_ref = 2 AND fecha_mov > wFechamesiver THEN monto ELSE 0 END),0), --INTERES MORATORIO
            nvl(sum(CASE WHEN codigo_ref = 3 AND fecha_mov > wFechamesiver THEN monto ELSE 0 END),0), --IVA INTERES MORATORIO
            nvl(sum(CASE WHEN codigo_ref = 30 and codigo_fun = '221' AND fecha_mov > wFechamesiver THEN monto ELSE 0 END),0),--INTERES VENCIODO
            nvl(sum(CASE WHEN codigo_ref = 45 and codigo_fun = '221' AND fecha_mov > wFechamesiver THEN monto ELSE 0 END),0) --IVA INTERES VENCIDO
     into wabonos_his, wmora_his, wivamora_his, wintvencido_his, wivaintvencido_his
    FROM bdicred:sd_movhiscrd a
    WHERE empresa = pEmpresa
      AND num_credito = pNumCredito
--      AND fecha_mov > wFechamesiver
      AND codigo_fun IN (select cod_fun from bdicred:sd_conceptospagomanualcrd)
      AND reversado = "N";

    SELECT  nvl(sum(CASE WHEN codigo_ref = 1 AND fecha_mov > wFechamesiver THEN monto ELSE 0 END),0), --MENOS SUS ABONOS
            nvl(sum(CASE WHEN codigo_ref = 2 AND fecha_mov > wFechamesiver THEN monto ELSE 0 END),0), --INTERES MORATORIO
            nvl(sum(CASE WHEN codigo_ref = 3 AND fecha_mov > wFechamesiver THEN monto ELSE 0 END),0), --IVA INTERES MORATORIO
            nvl(sum(CASE WHEN codigo_ref = 30 and codigo_fun = '221' AND fecha_mov > wFechamesiver THEN monto ELSE 0 END),0),--INTERES VENCIODO
            nvl(sum(CASE WHEN codigo_ref = 45 and codigo_fun = '221' AND fecha_mov > wFechamesiver THEN monto ELSE 0 END),0) --IVA INTERES VENCIDO
     into wabonos_dia, wmora_dia, wivamora_dia, wintvencido_dia, wivaintvencido_dia
    FROM bdicred:sd_movdiacrd a
    WHERE empresa = pEmpresa
      AND num_credito = pNumCredito
--      AND fecha_mov > wFechamesiver
      AND codigo_fun IN (select cod_fun from bdicred:sd_conceptospagomanualcrd)
      AND reversado = "N";

      let wabonos_his = wabonos_his + wabonos_dia;
      let mCsg_int_moratorios = mCsg_int_moratorios + wmora_his + wmora_dia;
      let mCsg_iva_int_moratorios = mCsg_iva_int_moratorios + wivamora_his + wivamora_dia;
      let mCsg_int_devengado = mCsg_int_devengado  + wintvencido_his + wintvencido_dia;
      let mCsg_iva_int_devengado = mCsg_iva_int_devengado + wivaintvencido_his + wivaintvencido_dia;
					  
	--se obtienen las comisiones pendientes
	SELECT NVL(SUM(DECODE(tc.comi_o_seg, '1', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0) +
		   NVL(SUM(DECODE(tc.comi_o_seg, '4', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0)
	INTO  dComisionesPendientes
	FROM  "informix".sd_detcomi dc  ,
	"informix".sd_tpcomis tc   
	WHERE dc.num_credito = pNumCredito
	AND dc.fecha_alta = dtFecha
	AND dc.estado_com  = 'A'   
	AND dc.cod_comis   = tc.cod_comis 
	AND tc.comi_o_seg IN ('1','4');			
	  
	LET dIvaComisionesPendientes = dComisionesPendientes * dIva;
	LET dSdoUltCorte = NVL(dSdoUltCorte,0) + NVL(dComisionesPendientes,0) + NVL(dIvaComisionesPendientes,0);
	    	
	--se obtiene el numero de producto del credito
		
		EXECUTE PROCEDURE "informix".sp_ofi_validacred(pEmpresa,pNumCredito) INTO cCodRet_vc,cMensajeRet_vc,cNumProducto_vc,cNomProducto_vc,cNomCliente_vc,cNumCte_vc;
			
		IF cCodRet_vc::INTEGER <> 0 THEN
			LET cCodRet = '00362';
			LET cMensajeRet= cMensajeRet_vc;
			RETURN cCodRet,cMensajeRet,'','','','',0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0;
		END IF
		--Se obtiene los parametros que se le enviaran a la proyeccion
		--se obtiene la frecuencia de pago, 
		SELECT tp_dias_fecha_pago, fecha_proceso
			INTO iFrecuenciaPago,iFechaProceso
		FROM "informix".sd_maecredanexocrd
		WHERE empresa = pEmpresa
		AND num_credito = pNumCredito;
		
        --Se calcula el importe de ahorro
        SELECT nvl(num_pago,0)
        INTO wnumpago
        FROM "informix".sd_amortiza_creditocrd
        WHERE empresa = pEmpresa
        AND FECHA_CUOTA = wFechamesiver
        AND num_credito = pNumCredito;

        if ( wnumpago > 0 and wnumpago < iCsg_plazo and (mCsg_cap_vig + mCsg_cap_vdo_no_exig) > 0 ) then
            let iCsg_pagos_realizados = wnumpago + 1;
            let wtasas = pow((1 + (((mCsg_tasa_interes / 100) * (1+dIva)) / 12)), (iCsg_plazo - wnumpago));
            let wpagomes = (mCsg_cap_vig + mCsg_cap_vdo_no_exig) * (((((mCsg_tasa_interes / 100) * (1+dIva)) / 12) * wtasas) / (wtasas - 1));
            let dAhorroPago = (wpagomes * (iCsg_plazo - wnumpago)) - (mCsg_cap_vig + mCsg_cap_vdo_no_exig);
            let dAhorroPago = dAhorroPago - NVL(mCsg_int_devengado,0) - NVL(mCsg_iva_int_devengado,0);
            if dAhorroPago < 0 then 
                let dAhorroPago = 0;
            end if;
         else
            let dAhorroPago = 0;
            let iCsg_pagos_realizados = 0;
         end if;

		--se le manda a la proyeccion el saldo capital vigente o no exigible		
		LET mCapital=mCsg_cap_vig+mCsg_cap_trans;
		--se obtiene la mensualidad del cliente 	
			SELECT capital_mto_cuota
			INTO dMontoFinanciado
			FROM "informix".sd_amortiza_creditocrd 
			WHERE empresa = pEmpresa 
			AND num_credito = pNumCredito 
			AND num_pago = 1;
		--valida si es posible realizar la proyeccion
		--si no  debe capital, no se proyecta.
			SELECT monto_min_cred, monto_max_cred
				INTO mMontoMin, mMontoMax
			  FROM "informix".sd_definicion
		     WHERE num_producto = cNumProducto_vc
		     AND empresa      = pEmpresa;
{					
		 IF NVL(mCapital,0)  >= NVL(mMontoMin,0) AND NVL(mCapital,0)  <= NVL(mMontoMax,0) THEN 
			IF NVL(mCapital,0) > 0 AND NVL(dMontoFinanciado,0)  > 0 THEN
				--REALIZA LA PROYECCION DEL PRESTAMO/REESTRUCTURA/CREDINOMINA PARA OBTENER EL ESTIMADO
				FOREACH EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos(mCapital,0,dMontoFinanciado,cNumProducto_vc,pSucursal,1,0,pNumCredito,'')
						INTO pp_CodRet,pp_Periodo,pp_FechaCuota,pp_SaldoInicial,pp_Mensualidad,pp_Intereses,pp_IvaIntereses,pp_Capital,
						pp_SaldoFinal,pp_DiasPeriodo,pp_FechaAper
			    
						LET dSumaInteres = dSumaInteres + pp_Intereses;
						LET dSumaIvaInteres = dSumaIvaInteres + pp_IvaIntereses;
				
				END FOREACH;
				IF pp_CodRet::INTEGER <> 0 THEN
					LET dSumaInteres = 0 ;
					LET dSumaIvaInteres = 0 ;
				END IF
					LET dAhorroPago = dSumaInteres + dSumaIvaInteres;	
			END IF;		
		END IF;		
}	
	RETURN cCodRet,cMensajeRet,NVL(pNumCredito,""),NVL(cNomProductoCD,""),NVL(cNumCteCD,""),NVL(cNomCteCD,""),NVL(mCsg_linea_otorgada,0),
	NVL(dtCsg_fec_origen,""),NVL(dSdoUltCorte,0),NVL(mCsg_int_moratorios,0),NVL(mCsg_iva_int_moratorios,0),NVL(mCsg_tot_liquidacion,0),
	NVL(mCsg_cap_vdo_exig,0),NVL(iCsg_pagos_realizados,0),NVL(iCsg_plazo,0),NVL(dtCsg_fec_prox_pago,""),NVL(mCsg_pago_min,0),
	NVL(mCsg_tot_liquidacion,0), NVL(dAhorroPago,0),NVL(mCsg_tot_liquidacion,0), NVL(wabonos_his,0),
    NVL(mCsg_int_devengado,0),NVL(mCsg_iva_int_devengado,0),NVL(mCsg_com_pend,0),NVL(mCsg_iva_com,0);

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
'VERSION: 20110824.1741';

CREATE PROCEDURE "informix".determina_udi_rango_09062013(pEmpresa CHAR(3),
                                                pFecha_ini   DATE,
                                                pFecha_fin   DATE)
RETURNING CHAR(5) AS retorno,
          DECIMAL(14,6) AS valor_udi;
--------------------------------------------------------------------------------
-- Modificó: Viridiana Osobampo
-- Descripción: Se valida que la información de fechas recibidas sea correcta.
--        La fecha inicial no debe ser mayor que la fecha final y la fecha final 
--        no debe ser mayor a la fecha actual.
-- Fecha de modificación: 09-10-2009
-- Petición: Préstamo Personal.
--------------------------------------------------------------------------------
-- Modificó: Viridiana Osobampo
-- Descripción: Se modifica para que al obtener el valor2 de la udi, primero busque
--              en la tabla si_tpcambio y si no encontró información buscar en la
--              si_histdiv, tal como se hace al obtener el valor inicial.
-- Fecha de modificación: 22-01-2010
-- Petición: Préstamo Personal.
--------------------------------------------------------------------------------

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************

   DEFINE cod_ret		CHAR(5);
   DEFINE sql_err       SMALLINT;
   DEFINE isam_err      SMALLINT;
   DEFINE error_info    CHAR(40);
   DEFINE vValor1       DECIMAL(14,6);
   DEFINE vValor2       DECIMAL(14,6);
   DEFINE vPrecio       DECIMAL(14,6);
   DEFINE vFechaPaso    DATE;
   DEFINE vDivUdi       CHAR(2);
   DEFINE vClaseUdi     CHAR(1);
   DEFINE dtFechaHoy    DATE;

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
BEGIN

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret, vPrecio;
   END EXCEPTION;

 --SET DEBUG FILE TO "/pisa/cas/determina_udi_rango.out";
 --TRACE ON;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
   LET cod_ret    	= "000";
   LET vValor1   	= 0;
   LET vValor2   	= 0;
   LET vPrecio   	= 0;
   LET vFechaPaso 	= "";
   LET dtFechaHoy   = DATE(1);

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

    -- Valida que se proporcionen los parámetros de entrada
   IF NVL(pEmpresa,'')= '' OR NVL(pFecha_ini,'')= '' OR NVL(pFecha_fin,'')= '' THEN
       LET cod_ret = '902';
       RETURN cod_ret, NVL(vPrecio,0);
   END IF;

    -- valida que la fecha ini no sea mayor que la fecha fin
   IF pFecha_ini > pFecha_fin THEN
       LET cod_ret = '903';
       RETURN cod_ret, NVL(vPrecio,0);  
   END IF; 

   -- Valida que la fecha fin no sea mayor que la fecha actual
   SELECT fecha_hoy
     INTO dtFechaHoy
     FROM bdicred:sd_fechas;

  let dtFechaHoy = mdy('06','09','2013');
   IF pFecha_fin > dtFechaHoy THEN
       LET cod_ret = '904';
       RETURN cod_ret, NVL(vPrecio,0);
   END IF;

      -- ******************************************
      -- Extrae Parametro de Codigo de Divisa UDI *
      -- ******************************************
   SELECT TRIM(valor) 
     INTO vDivUdi
     FROM bdinteg:si_param
    WHERE empresa = pEmpresa
      AND cod_param = 16;

      -- *****************************************
      -- Extrae Clase de Tipo de Cmabio para UDI *
      -- *****************************************
   SELECT TRIM(valor) 
     INTO vClaseUdi
     FROM sd_param
    WHERE empresa = pEmpresa
      AND cod_param = "336";

      -- **************
      -- Precio Inicio*
      -- **************    
   SELECT precio_compra 
     INTO vValor1
     FROM bdinteg:si_tpcambio
    WHERE empresa = pEmpresa
      AND divisa = vDivUdi
      AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
                              FROM bdinteg:si_tpcambio
                             WHERE empresa = pEmpresa
                               AND divisa = vDivUdi
                               AND fecha_tpcambio = pFecha_fin)
      AND hora_tpcambio=(SELECT MAX(hora_tpcambio)
                           FROM bdinteg:si_tpcambio
                          WHERE empresa = pEmpresa
                            AND divisa = vDivUdi
                            AND fecha_tpcambio = pFecha_fin)
      AND clase_tpcambio = vClaseUdi;

       IF vValor1 IS NULL THEN

           SELECT precio_compra 
             INTO vValor1
             FROM bdinteg:si_histdiv
            WHERE empresa = pEmpresa
              AND divisa = "09"
              AND fecha_tc = (SELECT MAX(fecha_tc)
                                FROM bdinteg:si_histdiv
                               WHERE empresa = pEmpresa
                                 AND divisa = "09"
                                 AND fecha_tc = pFecha_fin)
              AND hora_tc=(SELECT MAX(hora_tc)
                             FROM bdinteg:si_histdiv
                            WHERE empresa = pEmpresa
                              AND divisa = "09"
                              AND fecha_tc = pFecha_fin)
              AND clase_tpcambio = vClaseUdi;

           IF vValor1 IS NULL THEN
               LET cod_ret = "900";
               RETURN cod_ret, vPrecio;
           END IF;

        END IF;

            -- *************
            -- Precio Final*
            -- *************
   SELECT precio_compra 
     INTO vValor2
     FROM bdinteg:si_tpcambio
    WHERE empresa = pEmpresa
      AND divisa = vDivUdi
      AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
                              FROM bdinteg:si_tpcambio
                             WHERE empresa = pEmpresa
                               AND divisa = vDivUdi
                               AND fecha_tpcambio = pFecha_ini)
      AND hora_tpcambio=(SELECT MAX(hora_tpcambio)
                           FROM bdinteg:si_tpcambio
                          WHERE empresa = pEmpresa
                            AND divisa = vDivUdi
                            AND fecha_tpcambio = pFecha_ini)
      AND clase_tpcambio = vClaseUdi;

      IF vValor2 IS NULL THEN

           SELECT precio_compra 
             INTO vValor2
             FROM bdinteg:si_histdiv
            WHERE empresa = pEmpresa
              AND divisa = "09"
              AND fecha_tc = (SELECT MAX(fecha_tc)
                                FROM bdinteg:si_histdiv
                               WHERE empresa = pEmpresa
                                 AND divisa = "09"
                                 AND fecha_tc = pFecha_ini)
              AND hora_tc=(SELECT MAX(hora_tc)
                           FROM bdinteg:si_histdiv
                           WHERE empresa = pEmpresa
                           AND divisa = "09"
                           AND fecha_tc = pFecha_ini)  
              AND clase_tpcambio = vClaseUdi;

           IF vValor2 IS NULL THEN
               LET cod_ret = "901";
               RETURN cod_ret, vPrecio;
           END IF
      END IF;

           LET vPrecio = (vValor1 / vValor2);

       IF vPrecio > 1 THEN
           LET vPrecio =  vPrecio -1;
       ELSE
           LET vPrecio = 0;
       END IF;
END
       RETURN cod_ret, vPrecio;
END PROCEDURE 
DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".calc_iva_grav_pp_09062013(p_cEmpresa CHAR(3), p_cNumCredito CHAR(20), p_dTasaInt DECIMAL(9,6),
                                             p_dIvaSuc DECIMAL(5,3), p_dtFechaHoy DATE,p_dtIvaFechaPag DATE,
                                             p_dtFechaApert DATE,p_dtFechaCuota DATE,p_dIntNorm DECIMAL(18,2))

RETURNING
   CHAR(6)        AS Cod_Ret,
   DECIMAL(18,2)  AS IvaIntReal,
   CHAR(80)       AS Mens_Ret;

    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cErrorInfo       CHAR(80);
    DEFINE cCodRet          CHAR(6);
    DEFINE cMensajeRet      CHAR(125);
    DEFINE l_diascalc       INTEGER;
    DEFINE l_dtFechaComp    DATE;
    DEFINE l_iDias          INTEGER;
    DEFINE l_dFactor1       DECIMAL(14,9);
    DEFINE l_dFactor2       DECIMAL(14,9);
    DEFINE l_dTasaReal      DECIMAL(14,9);
    DEFINE l_dFactorIntReal DECIMAL(14,9);
    DEFINE l_dIvaIntReal    DECIMAL(18,2);

    LET iSqlErr               = 0;
    LET iIsamErr              = 0;
    LET cErrorInfo            = "";
    LET cCodRet               = "000000";
    LET cMensajeRet           = "Proceso Exitoso";

    LET l_diascalc            = 0;
    LET l_dtFechaComp         = DATE(1);
    LET l_iDias               = 0;
    LET l_dFactor1            = 0;
    LET l_dFactor2            = 0;
    LET l_dTasaReal           = 0;
    LET l_dFactorIntReal      = 0;
    LET l_dIvaIntReal         = 0;

    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;
       RETURN cCodRet,l_dIvaIntReal,cMensajeRet;
       END IF;
    END EXCEPTION;

   -- SET DEBUG FILE TO "/pisa/cas/calc_iva_grav_pp.out";
   -- TRACE ON;

--    SET LOCK MODE TO WAIT 3;

    select valor
    into l_diascalc
    from bdicred:sd_param
    where cod_param='24'
    and empresa= p_cEmpresa;

    IF p_dtIvaFechaPag IS NULL THEN
        CALL bdicred:monthadd(p_dtFechaCuota,-1) RETURNING l_dtFechaComp;

          SELECT fecha_cuota
            INTO l_dtFechaComp
            FROM "informix".sd_amortiza_creditocrd
           WHERE empresa     = p_cEmpresa
             AND num_credito = p_cNumCredito
             AND fecha_cuota = l_dtFechaComp;

             IF l_dtFechaComp IS NULL THEN
                 LET l_dtFechaComp = p_dtFechaApert;
             END IF;
    ELSE
          LET l_dtFechaComp = p_dtIvaFechaPag;
    END IF;

    LET l_iDias    = p_dtFechaHoy - l_dtFechaComp;

    IF l_iDias > 0 THEN
        LET l_dFactor1 = NVL(p_dTasaInt,0)/(l_diascalc *100)* l_iDias;
        IF NVL(l_dFactor1,0) < 0 THEN
             LET cCodRet      = "000001";
             LET cMensajeRet  = "No es posible realizar los calculos con el valor obtenido para el factor 1";
          RETURN cCodRet,l_dIvaIntReal,TRIM(cMensajeRet);
        END IF;

        CALL bdicred:determina_udi_rango_09062013(p_cEmpresa,date(l_dtFechaComp-1),date(p_dtFechaHoy-1)) RETURNING cCodRet,l_dFactor2;

        IF NVL(l_dFactor2,0) < 0 THEN
             LET cCodRet     = "000002";
             LET cMensajeRet = "No es posible realizar los calculos con el valor obtenido para el factor 2";
          RETURN cCodRet,l_dIvaIntReal,TRIM(cMensajeRet);
        END IF;

        LET l_dTasaReal       = l_dFactor1 - l_dFactor2;
        IF l_dTasaReal< 0 THEN LET l_dTasaReal=0; END IF;
        LET l_dFactorIntReal  = (l_dTasaReal * p_dIvaSuc)/l_dFactor1;
--        LET p_dIntNorm        = g_dSdoInt;
        LET l_dIvaIntReal     = round(l_dFactorIntReal * p_dIntNorm,2);
    END IF;

    IF cCodRet <> "000000" THEN
      LET cCodRet = "000000";
    END IF;

        RETURN cCodRet,l_dIvaIntReal,cMensajeRet;

    END
END PROCEDURE;