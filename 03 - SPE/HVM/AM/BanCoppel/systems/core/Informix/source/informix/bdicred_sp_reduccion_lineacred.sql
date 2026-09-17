CREATE PROCEDURE "informix".sp_reduccion_lineacred()
-- execute procedure "informix".sp_reduccion_lineacred();
   RETURNING CHAR(6),CHAR (100);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE vcod_ret				CHAR(10);
DEFINE P_COD_RET			CHAR(6);
DEFINE COD_RET				CHAR(6);
DEFINE SQL_ERR				INTEGER;
DEFINE ISAM_ERR				INTEGER;
DEFINE ERROR_INFO			VARCHAR(80);
DEFINE P_MENSAJE			CHAR(100);
DEFINE v_Mensaje2			CHAR(100);
DEFINE dFechaHoy			DATE;
DEFINE vcontador			INTEGER;
DEFINE vcontador1			INTEGER;
DEFINE vcontador2			INTEGER;
DEFINE sScore				SMALLINT;
DEFINE vminscore 			DECIMAL (18,2);
DEFINE vmaxscore			DECIMAL (18,2);
DEFINE cScoreMaxPermitido	DECIMAL (18,2);
DEFINE sPorcDisponibilidad	DECIMAL (06,2);
DEFINE sPorcReduccion		DECIMAL (06,2);
DEFINE sPorcUtilizacion		DECIMAL (06,2);
DEFINE cPorcMaxPermitido	DECIMAL (06,2);
DEFINE cNumcte				CHAR(20);
DEFINE cNumCredito			CHAR(20);
DEFINE dReduccionMaxima		DECIMAL (18,2);
DEFINE dNuevoMontoOtorgado	DECIMAL (18,2);
DEFINE dMontoOtorgado		DECIMAL (18,2);
DEFINE vAjusteMonto			DECIMAL (18,2);
DEFINE iDisponibilidad		INTEGER;
DEFINE dMontoAjuste			DECIMAL (18,2);
DEFINE dSdoCapInsoluto		DECIMAL (18,2);
DEFINE cNumProducto			CHAR(4);
DEFINE cDivisa				CHAR(2);
DEFINE cSucursal			CHAR(4);
DEFINE vref					INTEGER;
DEFINE vfun					INTEGER;
DEFINE vtrans				CHAR(4);
DEFINE iCreditosProcesados		INTEGER;
DEFINE iReduccionesRealizadas	INTEGER;
DEFINE iCreditosSinDecremento	INTEGER;
DEFINE iCreditosLineaMinima		INTEGER;
DEFINE vproceso					CHAR (4);
DEFINE cMensaje					CHAR(150);
DEFINE dFechaInsertReduccion	DATE;
DEFINE dFechaInsertAumento	DATE;
DEFINE dFecha1AnioAtras		DATE;
DEFINE vFechaHoy			DATE;
DEFINE vFechaInicio			DATE;
DEFINE vsdocap				DECIMAL (18,2);
DEFINE cSegmento			CHAR(20);
DEFINE cSql					CHAR(2000);
DEFINE vContadorCred		INTEGER;


-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET vcod_ret				= "000";
LET P_COD_RET				= "000000";
LET COD_RET					= "000000";
LET SQL_ERR					= 0;
LET ISAM_ERR				= 0;
LET ERROR_INFO				= '';
LET P_MENSAJE 				= "Proceso exitoso";
LET v_Mensaje2				= "";
LET dFechaHoy				= DATE (1);
LET vcontador				= 0;
LET vcontador1				= 0;
LET vcontador2				= 0;
LET sScore					= 0;
LET vminscore 				= 0;
LET vmaxscore				= 0;
LET cScoreMaxPermitido		= 0;
LET sPorcDisponibilidad		= 0;
LET sPorcReduccion			= 0;
LET sPorcUtilizacion		= 0;
LET cPorcMaxPermitido		= 0;
LET cNumcte					= "";
LET cNumCredito				= "";
LET dReduccionMaxima		= 0;
LET dNuevoMontoOtorgado		= 0;
LET dMontoOtorgado			= 0;
LET vAjusteMonto			= 0;
LET iDisponibilidad			= 0;
LET dMontoAjuste			= 0;
LET dSdoCapInsoluto			= 0;
LET cNumProducto			= "";
LET cDivisa					= "";
LET cSucursal				= "";
LET vref					= 0;
LET vfun					= 0;
LET vtrans					= 0;
LET iCreditosProcesados		= 0;
LET iReduccionesRealizadas	= 0;
LET iCreditosSinDecremento	= 0;
LET iCreditosLineaMinima	= 0;
LET vproceso				= '0040';
LET cMensaje				= '';
LET dFechaInsertReduccion	= DATE(1);
LET dFechaInsertAumento		= DATE(1);
LET	dFecha1AnioAtras		= DATE(1);
LET vFechaHoy				= DATE(1);
LET vFechaInicio			= DATE(1);
LET vsdocap					= 0;
LET cSegmento				= '';
LET cSql					= '';
LET vContadorCred			= 0;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
--        LET P_MENSAJE = ERROR_INFO;
        LET P_MENSAJE = 'Error al ejecutar el proceso. '||cNumCredito;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, P_MENSAJE, '02') RETURNING COD_RET;
		RETURN P_COD_RET,P_MENSAJE;
	END EXCEPTION;

  --Set debug file to "/informix/jorger/sp_reduccion_lineacred.out";
  --trace on;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01') RETURNING COD_RET;

     if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************


	EXECUTE PROCEDURE bdicred:monthadd(TODAY, -12) INTO dFecha1AnioAtras;
	
	SELECT CAST (valor AS DECIMAL (6,2)) 
		INTO cPorcMaxPermitido
	FROM sd_param 
	WHERE empresa = '001' 
	AND cod_param = '85';
	
	SELECT cast (valor AS DECIMAL (18,2)) 
		INTO cScoreMaxPermitido
	FROM sd_param 
	WHERE empresa = '001' 
	AND cod_param = '86';	
	
	/*SELECT fecha_hoy 
		INTO vFechaHoy
	FROM sd_fechas
	WHERE empresa = '001';*/
	
	SELECT fecha_hoy, (pri_dia_mes - 2 units month) fecha_inicio
		INTO vFechaHoy, vFechaInicio
	FROM sd_fechas
	WHERE empresa = '001';
	

	FOREACH WITH HOLD
--		SELECT fecha_insert, linea_disponible, monto_otorgado, sdo_capital, num_credito, segmento, score, numcte, num_producto, divisa, sucursal
--			INTO dFechaProceso, dMontoOtorgado, dMontoOtorgado, vsdocap, cNumCredito, cSegmento, sScore, cNumcte, cNumProducto, cDivisa, cSucursal
		 SELECT {+ INDEX (bdicred:sd_clientes_dirty_behavior ix_ctesdirty2)} a.num_credito, b.numcte, c.monto_otorgado, c.sdo_cap_insoluto, a.score, b.num_producto, b.divisa, b.sucursal
			INTO cNumCredito, cNumcte, dMontoOtorgado, dSdoCapInsoluto, sScore, cNumProducto, cDivisa, cSucursal
			FROM bdicred:"informix".sd_clientes_dirty_behavior a
		INNER JOIN bdicred:"informix".sd_maecred b on b.empresa = '001' AND b.num_credito = a.num_credito AND b.status_cred IN ('AA','BA','BT','E1','E2','E3')--'600000017647'
		INNER JOIN bdicred:"informix".sd_maesdos c on c.empresa = b.empresa AND c.num_credito = b.num_credito
		--WHERE a.fecha_reporte = vFechaHoy
		WHERE a.fecha_reporte >= vFechaInicio AND a.fecha_reporte <= vFechaHoy
		AND a.num_credito >''
		AND c.monto_otorgado>0
				
		
		SELECT COUNT (num_credito)
			INTO vContadorCred
		FROM sd_bitacora_redlincred_dirty
		WHERE num_credito = cNumCredito
		AND fecha_insert = vFechaHoy;
		
		IF vContadorCred > 0 THEN
			CONTINUE FOREACH;
		END IF;		
			

		--BEGIN WORK;

		LET iCreditosProcesados = iCreditosProcesados + 1;
		
		IF sScore > cScoreMaxPermitido THEN
			LET iCreditosSinDecremento = iCreditosSinDecremento + 1;
			CONTINUE FOREACH;
		END IF;		

		IF dSdoCapInsoluto IS NULL OR dSdoCapInsoluto = '' THEN LET dSdoCapInsoluto = 0; END IF;
		IF dMontoOtorgado IS NULL OR dMontoOtorgado = '' THEN LET dMontoOtorgado = 0; END IF;

		SELECT MAX(fecha_insert)
		  INTO dFechaInsertReduccion
		  FROM bdicred:"informix".sd_bitacora_redlincred_dirty
		 WHERE empresa = '001'
		   AND num_credito = cNumCredito;

		IF dFechaInsertReduccion IS NULL OR dFechaInsertReduccion = '' THEN LET dFechaInsertReduccion = DATE(1); END IF;

		SELECT MAX(fecha_insert)
		  INTO dFechaInsertAumento
		  FROM bdicred:"informix".sd_bitacora_aumlincred
		 WHERE empresa = '001'
		   AND num_solicitud = cNumCredito
		   AND status = 'AP';

		IF dFechaInsertAumento IS NULL OR dFechaInsertAumento = '' THEN LET dFechaInsertAumento = DATE(1); END IF;

		IF dFecha1AnioAtras < dFechaInsertReduccion OR dFecha1AnioAtras < dFechaInsertAumento THEN
			LET iCreditosSinDecremento = iCreditosSinDecremento + 1;
			--COMMIT WORK;
			CONTINUE FOREACH;
		END IF;

	-- se obtiene el porcentaje de utilizacion
		SELECT porc_reduccion, porc_disponibilidad
			INTO sPorcReduccion, sPorcDisponibilidad
		FROM bdicred:"informix".sd_param_redlineacred
		WHERE empresa = '001'
        AND sScore			BETWEEN bc_scoremin	AND bc_scoremax
        AND dMontoOtorgado	BETWEEN linea_min 	AND linea_max;

		IF sPorcReduccion IS NULL OR sPorcReduccion = '' THEN LET sPorcReduccion = 0; END IF;
		IF sPorcDisponibilidad IS NULL OR sPorcDisponibilidad = '' THEN LET sPorcDisponibilidad = 0; END IF;

	-- Se obtiene el maximo de reduccion
		LET dReduccionMaxima = ROUND(dMontoOtorgado * sPorcReduccion);

	-- Se obtiene el % de utilizacion
		LET sPorcUtilizacion = ROUND((dSdoCapInsoluto / dMontoOtorgado),2);
		
		IF sPorcUtilizacion > cPorcMaxPermitido THEN
			LET iCreditosSinDecremento = iCreditosSinDecremento + 1;
			CONTINUE FOREACH;
		END IF;	

	-- Se obtiene el diponible del 10%
		LET iDisponibilidad = dMontoOtorgado * sPorcDisponibilidad;

	-- Se obtiene el monto de reduccion
	-- FORMULA = minimo(reduccion maxima, (monto otorgado - (saldo + 10% del disponible))* % utilizacion)
		LET dMontoAjuste = ROUND(dSdoCapInsoluto + iDisponibilidad); ---* sPorcUtilizacion;
		LET dNuevoMontoOtorgado = ROUND(dMontoOtorgado - dMontoAjuste);

	-- Se determina el monto mÃ?Â­nimo de reducciÃ?Â³n
		/*IF dNuevoMontoOtorgado >= dReduccionMaxima THEN
			LET dNuevoMontoOtorgado = dReduccionMaxima;
		END IF;*/	
		IF dNuevoMontoOtorgado >= dReduccionMaxima THEN
			LET dNuevoMontoOtorgado = dMontoOtorgado - dReduccionMaxima;
		ELSE
			LET dNuevoMontoOtorgado = dMontoOtorgado - dNuevoMontoOtorgado;
		END IF;
		
		IF dNuevoMontoOtorgado = dMontoOtorgado THEN
			LET iCreditosLineaMinima = iCreditosLineaMinima + 1;
			CONTINUE FOREACH;
		END IF;
		
		LET vAjusteMonto = dMontoOtorgado - dNuevoMontoOtorgado;
		
		BEGIN WORK;
		
		--- Actualiza la linea con incremento.
		UPDATE bdicred:sd_maesdos 
			SET monto_otorgado = dNuevoMontoOtorgado
		WHERE empresa = '001'
			AND num_credito = cNumCredito;		

		--- Se guarda registro en bitacora 	
		INSERT INTO "informix".sd_bitacora_redlincred_dirty (fecha_insert, empresa, num_credito, numcte, score, saldo_corte, monto_otorgado_actual, monto_reducido, monto_otorgado_nuevo, mensaje)
			VALUES (vFechaHoy, '001', cNumCredito, cNumcte, sScore, dSdoCapInsoluto, dMontoOtorgado, vAjusteMonto, dNuevoMontoOtorgado, 'Red LineaCredito');

		LET iReduccionesRealizadas = iReduccionesRealizadas + 1;

		--- Se genera movimiento contable sd_movdia
		EXECUTE PROCEDURE "informix".GENMOV('001', cNumCredito, cNumProducto, 1, '008', vFechaHoy, vAjusteMonto, 'Red LineaCredito', cSucursal, cDivisa, '6697')
				INTO vcod_ret, v_Mensaje2;
				
		EXECUTE PROCEDURE bdicred:sp_segmentacion_lincred( '001', cNumCredito, dNuevoMontoOtorgado) 
			INTO vcod_ret, v_Mensaje2;				

		COMMIT WORK;

	END FOREACH;


	let cMensaje = 'TOTAL Creditos procesados: ' || iCreditosProcesados;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING COD_RET;
	
	let cMensaje = 'Creditos con reduccion de linea: ' || iReduccionesRealizadas;
	let cMensaje = trim(cMensaje) ||'   Creditos no procesados: ' || iCreditosSinDecremento;
	let cMensaje = trim(cMensaje) ||'   Creditos con reduccion 0 por linea minima: ' || iCreditosLineaMinima;	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING COD_RET;



	if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
    end if;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '03') RETURNING COD_RET;

    if COD_RET != '000000' then
       let P_COD_RET = COD_RET;
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;

	let P_MENSAJE = trim(P_MENSAJE) || ' Creditos procesados: '|| iCreditosProcesados;

	RETURN P_COD_RET, P_MENSAJE;

END;
END PROCEDURE;