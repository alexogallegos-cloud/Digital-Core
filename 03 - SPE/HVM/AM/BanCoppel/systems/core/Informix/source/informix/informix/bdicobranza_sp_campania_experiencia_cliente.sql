CREATE PROCEDURE "informix".sp_campania_experiencia_cliente(pEmpresa char (3), pCampania SMALLINT)
RETURNING VARCHAR(6)  AS codigo_retorno,CHAR(80)    AS mensaje_retorno;
 
DEFINE cNumCredito  					CHAR(20);
DEFINE cNumcte      					CHAR(20);
define cNumTarjeta  					CHAR(20);
DEFINE dFechaHoy    					DATE;
DEFINE cNumProducto 					CHAR(04);
 
DEFINE cProceso     					CHAR(4);
DEFINE cCod_ret     					CHAR(6);
DEFINE cMensaje     					CHAR (100);
DEFINE SQL_ERR      					INTEGER;
DEFINE ISAM_ERR     					INTEGER;
DEFINE ERROR_INFO   					VARCHAR(80);
DEFINE P_COD_RET    					VARCHAR(6);
DEFINE P_MENSAJE    					VARCHAR(80);
DEFINE cNombre1							CHAR(26);
DEFINE cNombre2							CHAR(26);
DEFINE cApellPat						CHAR(26);
DEFINE cApellMat						CHAR(26);
DEFINE iCuentasProcesadas 				INTEGER;
DEFINE iCount_TC_EXPCTE    				INTEGER;
DEFINE iCount_TCO_EXPCTE   				INTEGER;
DEFINE iCount_TCP_EXPCTE   				INTEGER;
DEFINE iCuentasExcluidasXProdErroneo	INTEGER;
DEFINE iCuentasExcluidasXMail 			INTEGER;
DEFINE iCuentasExcluidasXPago0 			INTEGER;
DEFINE cNumTarjetaUlt4digitos  			CHAR(04);
DEFINE cNombreCliente   				CHAR(104);
DEFINE dPagoMinimo      				DECIMAL(14,2);
DEFINE dPagoNoGenerarInt    			DECIMAL(14,2);
DEFINE cCorreoElec    					CHAR(100);
DEFINE cNombreProd    					CHAR(40);
DEFINE dProxFechaPago      				DATE;
DEFINE dProxFechaPago_lt   				CHAR(25);
DEFINE dFecha       					DATE;
DEFINE cIdCampania 						CHAR(10);
DEFINE dFechaUltCorte   				DATE;
DEFINE dFechaUltCorte_lt   				CHAR(15);
DEFINE dFechaEmision    				DATE;
DEFINE sPagoMinimo						VARCHAR(20);
DEFINE sPagoNoGenerarInt				VARCHAR(20);

LET P_COD_RET   					= '000000';
LET P_MENSAJE   					='Proceso CampaÃ±a EXPERIENCIA CTE correcto.';
LET cCod_ret    					= '000000';
LET cMensaje    					= '';
LET cproceso    					= '2007';
LET SQL_ERR							=0;
LET ISAM_ERR						=0;
LET ERROR_INFO						= '';
LET cNumCredito   					= '';
LET cNumcte      	 				= '';
LET cNumTarjeta 					= '';
LET cNumTarjetaUlt4digitos 			= '';
LET cNombreCliente 					= '';
LET dPagoMinimo      				= 0;
LET dPagoNoGenerarInt    			= 0;
LET cCorreoElec 					= '';
LET iCount_TC_EXPCTE    			= 0;
LET iCount_TCO_EXPCTE   			= 0;
LET iCount_TCP_EXPCTE   			= 0;
LET iCuentasProcesadas 				= 0;
LET iCuentasExcluidasXProdErroneo 	= 0;
LET iCuentasExcluidasXMail 			= 0;
LET iCuentasExcluidasXPago0 		= 0;
LET dFechaHoy 						= DATE(0);
LET cNumProducto 					= '';
LET cNombreProd						= '';
LET dProxFechaPago 					= DATE(0);
LET dFecha  						= DATE(0);
LET cIdCampania 					= '';
LET dFechaUltCorte 					= DATE(0);
LET dFechaEmision 					= DATE(0);
LET sPagoMinimo						='0.00';
LET sPagoNoGenerarInt				='0.00';

--SET DEBUG FILE TO 'sp_campania_experiencia_cliente.out';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

BEGIN
    ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cproceso, P_COD_RET, P_MENSAJE, '02')
         RETURNING P_COD_RET;
        LET P_COD_RET = SQL_ERR;
        RETURN P_COD_RET,P_MENSAJE;
    END exception;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cproceso , cCod_ret, cMensaje, '01') RETURNING P_COD_RET;

     if P_COD_RET != '000000' then
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	SELECT Fecha_Hoy 
      INTO dFechaHoy 
	  FROM bdicred:sd_fechas
	  WHERE empresa = pEmpresa ;

--let dFechaHoy = mdy('12','25','2017');  --PBAS IPCB
--let dFechaAnt = mdy('02','22','2015');

    --valida parametros
    IF NVL (pEmpresa, '') = '' THEN
        LET cCod_Ret= '000010';
        LET cMensaje ='Falta Parametro de Empresa';
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cproceso, cCod_ret, cMensaje, '02') RETURNING P_COD_RET;
        RETURN cCod_ret,cMensaje;
    END IF;

	LET dFechaEmision =  MDY(MONTH(dFechaHoy),20,YEAR(dFechaHoy)) - 1 UNITS MONTH;
	
    IF pCampania = 1 THEN 
        LET dFechaUltCorte = dFechaEmision;

        SELECT mae.num_credito, mae.numcte, mae.num_producto, def.nombre_prod, mxo.prox_fecha_pago, mhi.fecha, mas.monto_financiado, mhi.sdo_cap_insoluto
        FROM bdicred:sd_maecred mae
        INNER JOIN bdicred:sd_maecredanexo mxo ON mxo.empresa = mae.empresa AND mxo.num_credito = mae.num_credito
        INNER JOIN bdicred:sd_maesdoshist mhi ON mhi.fecha = dFechaUltCorte AND mhi.empresa = mae.empresa AND mhi.num_credito = mae.num_credito AND mhi.monto_vencido = 0 AND mhi.mto_venc_trasp = 0 AND mhi.monto_financiado > 0
        INNER JOIN bdicred:sd_maesdos mas ON mas.empresa = mae.empresa AND mas.num_credito = mae.num_credito AND mas.monto_financiado > 0
        INNER JOIN bdicred:sd_definicion def ON def.empresa = mae.empresa AND def.num_producto = mae.num_producto
        WHERE mae.empresa = '001'
        AND mae.num_credito >= ''
		AND mae.status_cred IN ('AA','E1')
		AND (mas.monto_vencido + mas.mto_venc_trasp) = 0
		AND mae.num_producto = '6001'
        INTO temp camp_exp_cliente WITH NO LOG;
    ELIF pCampania = 2 THEN 
		LET dFechaUltCorte = MDY(MONTH(dFechaHoy),18,YEAR(dFechaHoy)) - 1 UNITS MONTH;

        SELECT mae.num_credito, mae.numcte, mae.num_producto, def.nombre_prod, mxo.prox_fecha_pago, mhi.fecha, mas.monto_financiado, mhi.sdo_cap_insoluto
        FROM bdicred:sd_maecred mae
        INNER JOIN bdicred:sd_maecredanexo mxo ON mxo.empresa = mae.empresa AND mxo.num_credito = mae.num_credito
        INNER JOIN bdicred:sd_maesdoshist mhi ON mhi.fecha = dFechaUltCorte AND mhi.empresa = mae.empresa AND mhi.num_credito = mae.num_credito AND mhi.monto_vencido = 0 AND mhi.mto_venc_trasp = 0 AND mhi.monto_financiado > 0
        INNER JOIN bdicred:sd_maesdos mas ON mas.empresa = mae.empresa AND mas.num_credito = mae.num_credito AND mas.monto_financiado > 0
        INNER JOIN bdicred:sd_definicion def ON def.empresa = mae.empresa AND def.num_producto = mae.num_producto
        WHERE mae.empresa = '001'
        AND mae.num_credito >= ''
		AND mae.status_cred IN ('AA','E1')
		AND (mas.monto_vencido + mas.mto_venc_trasp) = 0
		AND mae.num_producto IN ('8100')
--		AND mae.num_producto IN ('7000','8100')
        INTO temp camp_exp_cliente WITH NO LOG;
    ELSE
        LET cCod_Ret = '000020';
        LET cMensaje  = 'Parametro dos no valido';
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cproceso, cCod_ret, cMensaje, '02') RETURNING P_COD_RET;
        RETURN cCod_Ret,cMensaje;
    END IF;
	
    UPDATE STATISTICS MEDIUM FOR TABLE camp_exp_cliente;

	FOREACH WITH HOLD
        SELECT num_credito, numcte, num_producto, nombre_prod, prox_fecha_pago, fecha, monto_financiado, sdo_cap_insoluto
          INTO cNumCredito, cNumcte, cNumProducto, cNombreProd, dProxFechaPago, dFechaUltCorte, dPagoMinimo, dPagoNoGenerarInt
          FROM camp_exp_cliente

        let iCuentasProcesadas = iCuentasProcesadas + 1;
		
--IPCB/Dic17-Se incluye traer la secuencia mÃ¡xima para no traer duplicados. 
		SELECT SUBSTR(num_tarjeta,13,4) INTO cNumTarjetaUlt4digitos
        FROM bdicred:sd_tarjeta 
        WHERE empresa = pEmpresa 
          AND num_credito = cNumCredito
		  AND tipo_tarjeta = 'T'
          AND status_tar = 'A'
		  AND secuencia = (SELECT MAX(secuencia) FROM bdicred:sd_tarjeta 
												WHERE empresa = pEmpresa 
												  AND num_credito = cNumCredito
												  AND tipo_tarjeta = 'T'
												  AND status_tar = 'A');  

        IF cNumTarjetaUlt4digitos IS NULL OR cNumTarjetaUlt4digitos = '' THEN LET cNumTarjetaUlt4digitos = ''; END IF;

        SELECT trim(nombre1)||' '||trim(nombre2)||' '||trim(apell_paterno)||' '||trim(apell_materno)
          INTO cNombreCliente
          FROM bdinteg:si_cliente 
         WHERE numcte = cNumcte;

/*        SELECT capital_tc + capital_ven_tc + interes_ven_tc + iva_interes_ven_tc + moratorios_tc + iva_moratorios_tc + comisionxcobrar, saldo_corte
          INTO dPagoMinimo,dPagoNoGenerarInt
          FROM bdicred:sd_info_edocta
         WHERE fecha_emision = dFechaEmision
           AND num_credito = cNumCredito;

        IF dPagoMinimo IS NULL OR dPagoMinimo = '' THEN LET dPagoMinimo = -1; END IF;
        IF dPagoNoGenerarInt IS NULL OR dPagoNoGenerarInt = '' THEN LET dPagoNoGenerarInt = -1; END IF;

        IF dPagoMinimo = -1 OR dPagoNoGenerarInt = -1 THEN
           LET iCuentasExcluidasXPago0 = iCuentasExcluidasXPago0 + 1;
           CONTINUE FOREACH; 
        END IF;
		
		IF dPagoMinimo < 0 THEN
			LET sPagoMinimo = '-'||trim(TO_CHAR(dPagoMinimo,"###,###,###,###.##"));
		ELSE*/
		LET sPagoMinimo = trim(TO_CHAR(dPagoMinimo,"###,###,###,###.##"));	
/*		END IF;
		
		IF sPagoMinimo = '.00' THEN
			LET sPagoMinimo = '0.00';
		END IF;

		IF dPagoNoGenerarInt < 0 THEN
			LET sPagoNoGenerarInt = '-'||trim(TO_CHAR(dPagoNoGenerarInt,"###,###,###,###.##"));	
		ELSE*/
		LET sPagoNoGenerarInt = trim(TO_CHAR(dPagoNoGenerarInt,"###,###,###,###.##"));	
/*		END IF;		

		IF sPagoNoGenerarInt = '.00' THEN
			LET sPagoNoGenerarInt = '0.00';
		END IF;*/

		SELECT LIMIT 1 cte.correo_elec INTO cCorreoElec 
		FROM bdinteg:si_correos cte 
        WHERE cte.empresa ='001' AND cte.numcte = cNumcte AND cte.status_correo ='A' AND cte.secuencia = 
                (SELECT MAX(secuencia) FROM bdinteg:si_correos WHERE empresa  = '001' AND numcte = cNumcte AND status_correo ='A');	

        IF cCorreoElec IS NULL OR cCorreoElec = '' THEN 
           LET iCuentasExcluidasXMail = iCuentasExcluidasXMail + 1;
           CONTINUE FOREACH; 
        END IF;

        IF cNumProducto = '6001' THEN
            LET cIdCampania = 'TC_EXPCTE';
            LET iCount_TC_EXPCTE = iCount_TC_EXPCTE + 1;
--        ELIF cNumProducto = '7000' THEN
--            LET cIdCampania = 'TCP_EXPCTE';
--            LET iCount_TCP_EXPCTE = iCount_TCP_EXPCTE + 1;
        ELIF cNumProducto = '8100' THEN
            LET cIdCampania = 'TCO_EXPCTE';
            LET iCount_TCO_EXPCTE = iCount_TCO_EXPCTE + 1;
        ELSE
           LET iCuentasExcluidasXProdErroneo = iCuentasExcluidasXProdErroneo + 1;
           CONTINUE FOREACH; 
        END IF;
		
--- IPCB - Convierte las fechas en cadena  Proximo pago 
--dProxFechaPago a dProxFechaPago_lt
		IF   lpad(month(dProxFechaPago),2,"0") = '01' THEN 
			LET dProxFechaPago_lt = lpad(day(dProxFechaPago),2,"0")||' de Enero de '||year(dProxFechaPago);
		ELIF lpad(month(dProxFechaPago),2,"0") = '02' THEN     
			LET dProxFechaPago_lt = lpad(day(dProxFechaPago),2,"0")||' de Febrero de '||year(dProxFechaPago);
		ELIF lpad(month(dProxFechaPago),2,"0") = '03' THEN     
			LET dProxFechaPago_lt = lpad(day(dProxFechaPago),2,"0")||' de Marzo de '||year(dProxFechaPago);
		ELIF lpad(month(dProxFechaPago),2,"0") = '04' THEN     
			LET dProxFechaPago_lt = lpad(day(dProxFechaPago),2,"0")||' de Abril de '||year(dProxFechaPago);
		ELIF lpad(month(dProxFechaPago),2,"0") = '05' THEN     
			LET dProxFechaPago_lt = lpad(day(dProxFechaPago),2,"0")||' de Mayo de '||year(dProxFechaPago);
		ELIF lpad(month(dProxFechaPago),2,"0") = '06' THEN     
			LET dProxFechaPago_lt = lpad(day(dProxFechaPago),2,"0")||' de Junio de '||year(dProxFechaPago);
		ELIF lpad(month(dProxFechaPago),2,"0") = '07' THEN     
			LET dProxFechaPago_lt = lpad(day(dProxFechaPago),2,"0")||' de Julio de '||year(dProxFechaPago);
		ELIF lpad(month(dProxFechaPago),2,"0") = '08' THEN     
			LET dProxFechaPago_lt = lpad(day(dProxFechaPago),2,"0")||' de Agosto de '||year(dProxFechaPago);
		ELIF lpad(month(dProxFechaPago),2,"0") = '09' THEN     
			LET dProxFechaPago_lt = lpad(day(dProxFechaPago),2,"0")||' de Septiembre de '||year(dProxFechaPago);
		ELIF lpad(month(dProxFechaPago),2,"0") = '10' THEN     
			LET dProxFechaPago_lt = lpad(day(dProxFechaPago),2,"0")||' de Octubre de '||year(dProxFechaPago);
		ELIF lpad(month(dProxFechaPago),2,"0") = '11' THEN    
			LET dProxFechaPago_lt = lpad(day(dProxFechaPago),2,"0")||' de Noviembre de '||year(dProxFechaPago);
		ELIF lpad(month(dProxFechaPago),2,"0") = '12' THEN    
			LET dProxFechaPago_lt = lpad(day(dProxFechaPago),2,"0")||' de Diciembre de '||year(dProxFechaPago);
		END IF;
--dFechaUltCorte a dFechaUltCorte_lt
		IF   lpad(month(dFechaUltCorte),2,"0") = '01' THEN 
			LET dFechaUltCorte_lt = lpad(day(dFechaUltCorte),2,"0")||' Enero';
		ELIF lpad(month(dFechaUltCorte),2,"0") = '02' THEN     
			LET dFechaUltCorte_lt = lpad(day(dFechaUltCorte),2,"0")||' Febrero';
		ELIF lpad(month(dFechaUltCorte),2,"0") = '03' THEN     
			LET dFechaUltCorte_lt = lpad(day(dFechaUltCorte),2,"0")||' Marzo';
		ELIF lpad(month(dFechaUltCorte),2,"0") = '04' THEN     
			LET dFechaUltCorte_lt = lpad(day(dFechaUltCorte),2,"0")||' Abril';
		ELIF lpad(month(dFechaUltCorte),2,"0") = '05' THEN     
			LET dFechaUltCorte_lt = lpad(day(dFechaUltCorte),2,"0")||' Mayo';
		ELIF lpad(month(dFechaUltCorte),2,"0") = '06' THEN     
			LET dFechaUltCorte_lt = lpad(day(dFechaUltCorte),2,"0")||' Junio';
		ELIF lpad(month(dFechaUltCorte),2,"0") = '07' THEN     
			LET dFechaUltCorte_lt = lpad(day(dFechaUltCorte),2,"0")||' Julio';
		ELIF lpad(month(dFechaUltCorte),2,"0") = '08' THEN     
			LET dFechaUltCorte_lt = lpad(day(dFechaUltCorte),2,"0")||' Agosto';
		ELIF lpad(month(dFechaUltCorte),2,"0") = '09' THEN     
			LET dFechaUltCorte_lt = lpad(day(dFechaUltCorte),2,"0")||' Septiembre';
		ELIF lpad(month(dFechaUltCorte),2,"0") = '10' THEN     
			LET dFechaUltCorte_lt = lpad(day(dFechaUltCorte),2,"0")||' Octubre';
		ELIF lpad(month(dFechaUltCorte),2,"0") = '11' THEN    
			LET dFechaUltCorte_lt = lpad(day(dFechaUltCorte),2,"0")||' Noviembre';
		ELIF lpad(month(dFechaUltCorte),2,"0") = '12' THEN    
			LET dFechaUltCorte_lt = lpad(day(dFechaUltCorte),2,"0")||' Diciembre';
		END IF;

--IPCB se cambia de versiÃ³n para enviar la plantilla
		CALL bdimnsj:"informix".sp_registra_evento(1,'PROD_EMAIL',cIdCampania,cNumcte, cNumCredito, cNumTarjetaUlt4digitos, 2, 
												    cNombreCliente, cNombreProd, dProxFechaPago_lt,dFechaUltCorte_lt, cIdCampania, 
													sPagoMinimo,sPagoNoGenerarInt,'','','',

													'','',
													0, 0, 0, 0, 0,'','')RETURNING P_COD_RET;
/*	pTipoMsj char(1), pIdMsj char(10),pIdPlantilla char(12), pNumclt char(20),pNumcta char(20), pNumTarjeta char(16),pTipoproc char(1), 
    pStr1 char(30), pStr2 char(30), pStr3 char(30), pStr4 char (30), pStr5 char(150), 
	pStr6 char(100), pStr7 char(60), pStr8 char(60),pStr9 char(15), pStr10 char(100), 
	pcorreo_alterno char(100), pcelular_alterno char(10), 
	pImporte1 money (16,2), pImporte2 money (16,2),
	pImporte3 money (16,2), pImporte4 money (16,2), pImporte5 money (16,2), 
	pfecha1 datetime year to fraction(3), pfecha2 datetime year to fraction(3)		*/
    END FOREACH

--Genera cifras de control
    IF iCuentasProcesadas > 0 THEN
	   DROP TABLE camp_exp_cliente;
       LET cMensaje = 'TOTAL Cuentas procesadas campaÃ±a EXPERIENCIA DEL CLIENTE : ' ||iCuentasProcesadas;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING P_COD_RET;
       IF cIdCampania = 'TC_EXPCTE' THEN
            let cMensaje = 'EMAILs enviados TC_EXPCTE: ' ||iCount_TC_EXPCTE;
       ELSE
            LET cMensaje = TRIM(cMensaje) ||'    EMAILs enviados TCP_EXPCTE: ' ||iCount_TCP_EXPCTE;
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING P_COD_RET;
            LET cMensaje = 'EMAILs enviados TCO_EXPCTE: ' ||iCount_TCO_EXPCTE;
       END IF;
       LET cMensaje = TRIM(cMensaje) ||'    Cuentas excluidas por error email : ' ||iCuentasExcluidasXMail;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING P_COD_RET;
       LET cMensaje = 'Cuentas excluidas por pagos no encontrados : ' ||iCuentasExcluidasXPago0;
       LET cMensaje = TRIM(cMensaje) ||'    Cuentas excluidas por producto errÃ³neo : ' ||iCuentasExcluidasXProdErroneo;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING P_COD_RET;
    END IF;
--Genera cifras de control

   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cproceso, cCod_ret, cMensaje, '03')
   RETURNING P_COD_RET;

    IF P_COD_RET != '000000' THEN
--       let P_COD_RET = cCodRet;
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    END IF;

END
	RETURN P_COD_RET,P_MENSAJE;  --Se ejecuto Exitosamente.
END PROCEDURE;