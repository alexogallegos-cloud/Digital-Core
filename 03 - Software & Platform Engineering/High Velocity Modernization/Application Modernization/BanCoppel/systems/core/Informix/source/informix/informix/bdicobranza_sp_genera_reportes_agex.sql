CREATE PROCEDURE "informix".sp_genera_reportes_agex(pfecha DATE)
returning VARCHAR(06),
          VARCHAR(80);
-----------------------------------------------------------------------
--  EXECUTE PROCEDURE "informix".sp_genera_reportes_agex(TODAY);

DEFINE SQL_ERR					INTEGER;
DEFINE ISAM_ERR					INTEGER;
DEFINE ERROR_INFO				VARCHAR(80);
DEFINE cProceso					CHAR(4);
DEFINE P_COD_RET				VARCHAR(6);
DEFINE P_MENSAJE				VARCHAR(200);
DEFINE cCodRet  				CHAR(6);

DEFINE cSql						CHAR(2000);
DEFINE cruta                	CHAR(100);
DEFINE vnom_archivo				CHAR(100);
DEFINE cnomarchivo1				CHAR(100);
DEFINE vfecha					DATE;
DEFINE v_num_credito			CHAR(20);
DEFINE v_tipo_cobranza 			CHAR(1);
DEFINE v_mon_ult_pag_per 		DECIMAL(18,2);
DEFINE v_fecha_ultimo_pago 		DATE;
DEFINE cStatusCred 				CHAR(2);
DEFINE sNumVencidos 			SMALLINT;
DEFINE dt_fecha_dia_anterior    DATE;
DEFINE c_num_producto           CHAR(4);
DEFINE dt_fecha_min_tipoA       DATE;
DEFINE dt_fecha_min_tipoR       DATE;
DEFINE dt_fecha_periodo         DATE;
DEFINE vCanal                   CHAR(4);
DEFINE dt_fecha_mes_anterior    DATE;
DEFINE iDia_ejec                SMALLINT;

BEGIN 
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET = SQL_ERR;
     LET P_MENSAJE = ERROR_INFO;
     CALL "informix".sp_inserta_bitacora_cob("001", cProceso, P_COD_RET, P_MENSAJE, '02')
     RETURNING P_COD_RET;
     LET P_COD_RET = SQL_ERR;
     RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

	--SET DEBUG FILE TO "/ifxsif01/macf/sp_genera_reportes_agex.out";
	--TRACE ON;

	LET cProceso            		= '0087';
	LET P_COD_RET           		= '000000';
	LET P_MENSAJE           		= 'El proceso REPORTES EXT se ejecuto correctamente.';
	LET cCodRet           			= '000000';

	LET cSql 						= "";
	LET cruta                   	= "";
	LET vnom_archivo				= "";
	LET cnomarchivo1 				= "";
	LET vfecha 						= DATE(1);
	LET v_num_credito 				= "";
	LET v_tipo_cobranza 			= "";
	LET v_mon_ult_pag_per 			= 0;
	LET v_fecha_ultimo_pago 		= DATE(1);
	LET cStatusCred 				= "";
	LET sNumVencidos 				= 0;
    LET dt_fecha_dia_anterior       = DATE(1); 
	LET c_num_producto              = '';
	LET dt_fecha_min_tipoA          = DATE(1);
    LET dt_fecha_min_tipoR          = DATE(1);
    LET vCanal                      = '';
	LET dt_fecha_mes_anterior       = DATE(1);
	LET iDia_ejec                   = 0;
	
	CALL "informix".sp_inserta_bitacora_cob("001", cProceso, cCodRet, "INICIO PROCESO GENERA REPORTES PARA AGENCIA EXTERNA", '02')
		RETURNING P_COD_RET;

	IF P_COD_RET != '000000' THEN
	   LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
	   RETURN P_COD_RET,P_MENSAJE;
	END IF;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	LET iDia_ejec = DAY(pfecha);
	
	--OBTENER RUTA DEL ARCHIVO
	SELECT valor_alfabetico INTO cruta
	FROM "informix".cb_param_campania
	WHERE empresa = "001"
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 3;

	
	SELECT MAX(fecha_insert) INTO vfecha
	FROM "informix".cb_cat_directorio_cte
	WHERE empresa = '001' 
	AND tipo_cobranza = 'A'
	AND num_producto = '6001';

	--LET cruta = '/RESPALDOS/Carlos/';
	--LET cruta ='/ifxsif01/macf/';  --- SOLO TEST MACF

	LET dt_fecha_dia_anterior = pfecha -1 UNITS DAY;
	LET dt_fecha_mes_anterior = bdicred:monthadd(pfecha, -1);
	
	IF iDia_ejec <> 21 THEN
		-- Obtener las fechas minimas de corte de cada tipo para que se tome en cuenta la mas antigua
		SELECT MIN(fecha_insert) INTO dt_fecha_min_tipoA
		  FROM bdicobranza:cb_cat_directorio_cte
		 WHERE tipo_cobranza = 'A';
	ELIF iDia_ejec = 21 THEN

	    SELECT MIN(fecha_insert) INTO dt_fecha_min_tipoA
		FROM bdicobranza:cb_cat_directorio_cte
        WHERE tipo_cobranza = 'A' and month(fecha_insert) = month(pfecha);
	
	END IF;
	
	/*SELECT MIN(fecha_insert) INTO dt_fecha_min_tipoR
	  FROM bdicobranza:cb_cat_directorio_cte
	 WHERE tipo_cobranza = 'R';
	 
	 IF dt_fecha_min_tipoA <= dt_fecha_min_tipoR THEN
	   LET dt_fecha_periodo = dt_fecha_min_tipoA;
	 ELSE
       LET dt_fecha_periodo = dt_fecha_min_tipoR;
     END IF;
  */
	
	LET dt_fecha_min_tipoR = dt_fecha_mes_anterior + 1 UNITS DAY;
	
	--LET dt_fecha_periodo = MDY(7,1,2020);--- SOLO TEST
	
	/*SELECT num_credito, tipo_cobranza
	FROM bdicobranza:cb_cat_directorio_cte
	WHERE num_credito > ""
	AND fecha_insert between dt_fecha_periodo and pfecha
	AND canal <> ''
	--AND fecha_insert <= TODAY
	--AND canal = 'PENT'
	GROUP BY 1,2
	INTO TEMP paso_agexmont WITH NO LOG;

	CREATE INDEX indx_paso_agexmont ON paso_agexmont(num_credito);
	UPDATE STATISTICS MEDIUM FOR TABLE paso_agexmont;*/
    
    -- Primero agregar las de TDC
	SELECT num_credito, tipo_cobranza
	FROM bdicobranza:cb_cat_directorio_cte
	WHERE tipo_cobranza = 'A'
	AND fecha_insert between dt_fecha_min_tipoA and pfecha
	AND canal <> ''
	--AND fecha_insert <= TODAY
	--AND canal = 'PENT'
	GROUP BY 1,2
	INTO TEMP paso_agexmont WITH NO LOG;

	-- DespuÃÂ©s agregar las de Plazo
	INSERT into paso_agexmont
	SELECT num_credito, tipo_cobranza
	FROM bdicobranza:cb_cat_directorio_cte
	WHERE tipo_cobranza = 'R'
	AND fecha_insert between dt_fecha_min_tipoR and pfecha
	AND canal <> ''
	GROUP BY 1,2;
	
	
	CREATE INDEX indx_paso_agexmont ON paso_agexmont(num_credito);
	UPDATE STATISTICS MEDIUM FOR TABLE paso_agexmont;
	
	FOREACH WITH HOLD
		SELECT num_credito, tipo_cobranza
		INTO v_num_credito, v_tipo_cobranza
		FROM paso_agexmont
		WHERE num_credito > ""

		IF v_tipo_cobranza = "A" THEN
			--SELECT monto_ultimo_pago, fecha_ultimo_pago
			--	INTO v_mon_ult_pag_per, v_fecha_ultimo_pago
			SELECT fecha_ultimo_pago
			  INTO v_fecha_ultimo_pago
			FROM bdicred:"informix".sd_indicador_cred
			WHERE empresa = "001"
			AND num_credito = v_num_credito;
			
			IF (v_fecha_ultimo_pago = pfecha - 1 UNITS DAY) THEN
				SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} NVL(SUM(monto),0)
				  INTO v_mon_ult_pag_per			
				  FROM bdicred:sd_movhis
				 WHERE empresa = '001' 
				   AND fecha_mov = v_fecha_ultimo_pago
				   AND num_credito = v_num_credito
				   AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanual) 
				   AND codigo_ref = 1
				   AND reversado = 'N';
			END IF;	   
			
		ELSE
			--SELECT monto_ultimo_pago, fecha_ultimo_pago
			--	INTO v_mon_ult_pag_per, v_fecha_ultimo_pago
			SELECT a.fecha_ultimo_pago, b.num_producto  --PROD
			--SELECT LIMIT 1 a.fecha_ultimo_pago, b.num_producto   ---- SOLO TEST MACF
			  INTO v_fecha_ultimo_pago, c_num_producto
			FROM bdicred:sd_indicador_cred_crd a, bdicred:sd_maecredcrd b
			WHERE a.empresa = "001" AND a.num_credito = b.num_credito
			AND a.num_credito = v_num_credito;
			
			IF (v_fecha_ultimo_pago = pfecha - 1 UNITS DAY) THEN
				SELECT NVL(SUM(monto),0)
				  INTO v_mon_ult_pag_per
				  FROM bdicred:sd_movhiscrd
				 WHERE empresa = '001' AND num_credito = v_num_credito
				   AND fecha_mov = v_fecha_ultimo_pago
				   AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanualcrd where num_producto = c_num_producto)
				   AND codigo_ref = 1
				   AND reversado = 'N';
			END IF;
			
		END IF;

		IF (v_fecha_ultimo_pago = pfecha - 1 UNITS DAY) THEN
			BEGIN WORK;
				UPDATE bdicobranza:cb_cat_directorio_cte
				SET monto_ult_pago_periodo = v_mon_ult_pag_per, fecha_ult_pago_periodo = v_fecha_ultimo_pago
				WHERE num_credito = v_num_credito;
			COMMIT WORK;
		ELSE
			BEGIN WORK;
				UPDATE bdicobranza:cb_cat_directorio_cte
				SET monto_ult_pago_periodo = 0, fecha_ult_pago_periodo = DATE(1)
				WHERE num_credito = v_num_credito;
			COMMIT WORK;
		END IF;
	END FOREACH;

	
	IF DAY(pfecha) = 1 THEN
		
		FOREACH WITH HOLD
		
			SELECT distinct canal INTO vCanal
			  FROM bdicobranza:cb_gestion_cobranza_agex
		
		
			--LET vnom_archivo = "Reporte_gestion_canales" || TO_CHAR(pfecha,'%d%m%Y') || ".txt";
			LET vnom_archivo = "Reporte_gestion_canales_" || vCanal || "_" || TO_CHAR(pfecha,'%d%m%Y') || ".txt";
			LET cnomarchivo1 = "Aux_" || vnom_archivo;

			LET cSql = '';
			--LET cSql ='if [ -f '||TRIM(cruta)||TRIM(vnom_archivo)||'.gz ]; then nice nice -n -30 rm -f '||TRIM(cruta)||TRIM(vnom_archivo)||'.gz; fi';
			LET cSql ='if [ -f '||TRIM(cruta)||TRIM(vnom_archivo)||'.gz ]; then rm -f '||TRIM(cruta)||TRIM(vnom_archivo)||'.gz; fi';
			System cSql;

			--SE ARMA SCRIPT QUE CONTENDRA EL QUERY DE LA DESCARGA DE LA INFORMACION
			LET cSql = "";
			LET cSql = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || '">' || TRIM(cruta) || "queryagextgescan.sql";
			SYSTEM cSql;

			LET cSql = "";
			LET cSql = 'echo "' || "SELECT TO_CHAR(TODAY,'%d/%m/%Y'), num_producto, numcte, num_credito, canal," || '">>' || TRIM(cruta) || "queryagextgescan.sql";
			SYSTEM cSql;

			LET cSql = "";
			LET cSql = 'echo "' || "saldo_vencido_inicial, saldo_vencido_final, saldo_total_inicial, saldo_total_final" || '">>' || TRIM(cruta) || "queryagextgescan.sql";
			SYSTEM cSql;

			LET cSql = "";
			--LET cSql = 'echo "' || "FROM bdicobranza:cb_cat_directorio_cte WHERE num_credito > '' AND fecha_insert >= (MDY(" ||MONTH(pfecha)|| "," ||DAY(pfecha)|| "," ||YEAR(pfecha)|| ") - 1 UNITS MONTH) AND fecha_insert < MDY(" ||MONTH(pfecha)|| "," ||DAY(pfecha)|| "," ||YEAR(pfecha)|| ") AND canal = 'PENT';" || '">>' || TRIM(cruta) || "queryagextgescan.sql";
			LET cSql = 'echo "' || "FROM bdicobranza:cb_cat_directorio_cte WHERE num_credito > '' AND fecha_insert >= '" || dt_fecha_mes_anterior || "' AND fecha_insert < MDY(" ||MONTH(pfecha)|| "," ||DAY(pfecha)|| "," ||YEAR(pfecha)|| ") AND canal = '" || vCanal || "';" || '">>' || TRIM(cruta) || "queryagextgescan.sql";
			

			SYSTEM cSql;

			--ASIGNACION DE PERMISO AL ARCHIVO TEMPORAL QUE CONTIENE EL QUERY DE LA DESCARGA
			LET cSql = "";
			LET cSql = "chmod 777 " || TRIM(cruta) || "queryagextgescan.sql";
			SYSTEM cSql;

			--EJCUCION DEL ARCHIVO TEMPORAL QUE CONTIENE EL QUERY DE LA DESCARGA
			LET cSql = "";
			LET cSql = "dbaccess bdicobranza " || TRIM(cruta) || "queryagextgescan.sql";
			SYSTEM cSql;

			--SE PASA LA INFORMACION DESCARGADA AL ARCHIVO FINAL
			LET cSql = "";
			LET cSql = "sed 's/|$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || vnom_archivo;
			SYSTEM cSql;

			--ASIGNACION DE PERMISO AL ARCHIVO FINAL
			LET cSql = "";
			LET cSql = "chmod 777 " || TRIM(cruta) || TRIM(vnom_archivo);
			SYSTEM cSql;

			--BORRADO DE ARCHIVOS TEMPORALES
			LET cSql = "";
			LET cSql = "rm " || TRIM(cruta) || "queryagextgescan.sql";		
			SYSTEM cSql;

			LET cSql = "";
			LET cSql = "rm " || TRIM(cruta) || TRIM(cnomarchivo1);
			SYSTEM cSql;

			--SE COMPACTA ARCHIVO FINAL
			LET cSql = "";
			LET cSql = "gzip " || TRIM(cruta) || TRIM(vnom_archivo);
			SYSTEM cSql;

			--ASIGNACION DE PERMISO AL ARCHIVO COMPACTADO
			LET cSql = "";
			LET cSql = "chmod 777 " || TRIM(cruta) || TRIM(vnom_archivo)||".gz";
			SYSTEM cSql;

			LET vnom_archivo = ""; LET cnomarchivo1 = ""; LET cSql = "";
		
		END FOREACH;
	END IF;
  
	
	FOREACH WITH HOLD
	
		SELECT distinct canal INTO vCanal
		  FROM bdicobranza:cb_gestion_cobranza_agex
		  
		LET cSql = "";
		
		IF vCanal = 'PENT' THEN
		   --LET vnom_archivo = "Reporte_feedback_agex" || TO_CHAR(pfecha,'%d%m%Y') || ".txt";
		   LET vnom_archivo = "Reporte_feedback_agex_AE" || TO_CHAR(pfecha,'%d%m%Y') || ".txt";
		ELIF vCanal = 'TEST' THEN
		   LET vnom_archivo = "Reporte_feedback_TE_agex" || TO_CHAR(pfecha,'%d%m%Y') || ".txt";
		ELSE 
		   --LET vnom_archivo = "Reporte_feedback_TE_agex" || TO_CHAR(pfecha,'%d%m%Y') || ".txt";
		   LET vnom_archivo = "Reporte_feedback_agex_" || vCanal || TO_CHAR(pfecha,'%d%m%Y') || ".txt";
		END IF; 
		
		
		LET cSql = '' ;
		LET cSql = 'echo "fecha_reporte|num_producto|numcte|num_cuenta|importe_pagado|fecha_pago|saldo_vencido|saldo_total|pago_vencido1|pago_vencido2|pago_vencido3|pago_vencido4" > '|| TRIM(cruta) || trim(vnom_archivo);
		SYSTEM trim(cSql);
		
		LET cnomarchivo1 = "Aux_" || vnom_archivo;

		LET cSql = "";
		--LET cSql ='if [ -f '||TRIM(cruta)||TRIM(vnom_archivo)||'.gz ]; then nice nice -n -30 rm -f '||TRIM(cruta)||TRIM(vnom_archivo)||'.gz; fi';
		LET cSql ='if [ -f '||TRIM(cruta)||TRIM(vnom_archivo)||'.gz ]; then rm -f '||TRIM(cruta)||TRIM(vnom_archivo)||'.gz; fi';
		System cSql;

		--SE ARMA SCRIPT QUE CONTENDRA EL QUERY DE LA DESCARGA DE LA INFORMACION
		LET cSql = "";
		LET cSql = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || '">' || TRIM(cruta) || "queryagextfeed.sql";
		SYSTEM cSql;
 
		IF vCanal <> 'TEST' THEN
			
			LET cSql = "";    ---TIPO A
			LET cSql = 'echo "' || "SELECT TO_CHAR(TODAY,'%d/%m/%Y'), num_producto, numcte, num_credito," || '">>' || TRIM(cruta) || "queryagextfeed.sql";
			SYSTEM cSql;

			LET cSql = "";
			LET cSql = 'echo "' || "monto_ult_pago_periodo, TO_CHAR(fecha_ult_pago_periodo,'%d/%m/%Y'), saldo_vencido_final, saldo_total_final," || '">>' || TRIM(cruta) || "queryagextfeed.sql";
			SYSTEM cSql;

			LET cSql = "";
			LET cSql = 'echo "' || "pago_vencido1_final, pago_vencido2_final, pago_vencido3_final, pago_vencido4_final" || '">>' || TRIM(cruta) || 'queryagextfeed.sql';
			SYSTEM cSql;

			LET cSql = "";
			--LET cSql = 'echo "' || "FROM bdicobranza:cb_cat_directorio_cte WHERE num_credito > '' AND fecha_insert <= MDY(" ||MONTH(pfecha)|| "," ||DAY(pfecha)|| "," ||YEAR(pfecha)|| ") AND canal = 'PENT';" || '">>' || TRIM(cruta) || "queryagextfeed.sql";
			--LET cSql = 'echo "' || "FROM bdicobranza:cb_cat_directorio_cte WHERE num_credito > '' AND fecha_insert between '" || dt_fecha_periodo || "' AND today  AND canal ='" || vCanal || "';" || '">>' || TRIM(cruta) || "queryagextfeed.sql";
			LET cSql = 'echo "' || "FROM bdicobranza:cb_cat_directorio_cte WHERE tipo_cobranza = 'A' " || " AND fecha_insert between '" || dt_fecha_min_tipoA || "' AND '" || pfecha || "'  AND canal ='" || vCanal || "'  UNION " || '">>' || TRIM(cruta) || "queryagextfeed.sql";
			SYSTEM cSql;
			
			LET cSql = "";  --TIPO R
			LET cSql = 'echo "' || "SELECT TO_CHAR(TODAY,'%d/%m/%Y'), num_producto, numcte, num_credito," || '">>' || TRIM(cruta) || "queryagextfeed.sql";
			SYSTEM cSql;

			LET cSql = "";
			LET cSql = 'echo "' || "monto_ult_pago_periodo, TO_CHAR(fecha_ult_pago_periodo,'%d/%m/%Y'), saldo_vencido_final, saldo_total_final," || '">>' || TRIM(cruta) || "queryagextfeed.sql";
			SYSTEM cSql;

			LET cSql = "";
			LET cSql = 'echo "' || "pago_vencido1_final, pago_vencido2_final, pago_vencido3_final, pago_vencido4_final" || '">>' || TRIM(cruta) || 'queryagextfeed.sql';
			SYSTEM cSql;

			LET cSql = "";
			--LET cSql = 'echo "' || "FROM bdicobranza:cb_cat_directorio_cte WHERE num_credito > '' AND fecha_insert <= MDY(" ||MONTH(pfecha)|| "," ||DAY(pfecha)|| "," ||YEAR(pfecha)|| ") AND canal = 'PENT';" || '">>' || TRIM(cruta) || "queryagextfeed.sql";
			--LET cSql = 'echo "' || "FROM bdicobranza:cb_cat_directorio_cte WHERE num_credito > '' AND fecha_insert between '" || dt_fecha_periodo || "' AND today  AND canal ='" || vCanal || "';" || '">>' || TRIM(cruta) || "queryagextfeed.sql";
			LET cSql = 'echo "' || "FROM bdicobranza:cb_cat_directorio_cte WHERE tipo_cobranza = 'R' " || " AND fecha_insert between '" || dt_fecha_min_tipoR || "' AND '" || pfecha || "' AND canal ='" || vCanal || "';" || '">>' || TRIM(cruta) || "queryagextfeed.sql";
			SYSTEM cSql;
		
		ELSE
		    
			LET cSql = "";
			LET cSql = 'echo "' || "SELECT TO_CHAR(TODAY,'%d/%m/%Y'), a.num_producto, a.numcte, a.num_credito," || '">>' || TRIM(cruta) || "queryagextfeed.sql";
			SYSTEM cSql;

			LET cSql = "";
			LET cSql = 'echo "' || "b.monto_ultimo_pago, TO_CHAR(b.fecha_ultimo_pago,'%d/%m/%Y'), c.mto_venc_trasp, c.sdo_cap_insoluto," || '">>' || TRIM(cruta) || "queryagextfeed.sql";
			SYSTEM cSql;

			LET cSql = "";
			LET cSql = 'echo "' || "(c.saldovencido1 + c.interesmoratorio1 + c.interesmoratorio2 + c.interesmoratorio3 + c.interesmoratorio4 + c.interesmoratorio5 + c.interesmoratorio6 + c.sdo_intereses) pago_vencido1_inicial," || '">>' || TRIM(cruta) || 'queryagextfeed.sql';
			SYSTEM cSql;

			LET cSql = "";
			LET cSql = 'echo "' || "(c.saldovencido2 + c.saldovencido1 + c.interesmoratorio1 + c.interesmoratorio2 + c.interesmoratorio3 + c.interesmoratorio4 + c.interesmoratorio5 + c.interesmoratorio6 + c.sdo_intereses) pago_vencido2_inicial," || '">>' || TRIM(cruta) || 'queryagextfeed.sql';
			SYSTEM cSql;

			LET cSql = "";
			LET cSql = 'echo "' || "(c.saldovencido3 + c.saldovencido2 + c.saldovencido1 + c.interesmoratorio1 + c.interesmoratorio2 + c.interesmoratorio3 + c.interesmoratorio4 + c.interesmoratorio5 + c.interesmoratorio6 + c.sdo_intereses) pago_vencido3_inicial," || '">>' || TRIM(cruta) || 'queryagextfeed.sql';
			SYSTEM cSql;

			LET cSql = "";
			LET cSql = 'echo "' || "(c.saldovencido6 + c.saldovencido5 + c.saldovencido4 + c.saldovencido3 + c.saldovencido2 + c.saldovencido1 + c.interesmoratorio1 + c.interesmoratorio2 + c.interesmoratorio3 + c.interesmoratorio4 + c.interesmoratorio5 + c.interesmoratorio6 + c.sdo_intereses) pago_vencido4_inicial" || '">>' || TRIM(cruta) || 'queryagextfeed.sql';
			SYSTEM cSql;

			LET cSql = "";
			LET cSql = 'echo "' || "FROM bdicobranza:cb_cat_directorio_cte a" || '">>' || TRIM(cruta) || "queryagextfeed.sql";
			SYSTEM cSql;
			
			LET cSql = "";
			LET cSql = 'echo "' || "LEFT OUTER JOIN bdicred:'informix'.sd_indicador_cred b ON(b.empresa = a.empresa AND b.num_credito = a.num_credito)" || '">>' || TRIM(cruta) || "queryagextfeed.sql";
			SYSTEM cSql;

			LET cSql = "";
			LET cSql = 'echo "' || "LEFT OUTER JOIN bdicred:'informix'.sd_sdos_cartera_linea c ON(c.num_credito = a.num_credito)" || '">>' || TRIM(cruta) || "queryagextfeed.sql";
			SYSTEM cSql;

			LET cSql = "";
			LET cSql = 'echo "' || "WHERE a.tipo_cobranza = 'A'" || '">>' || TRIM(cruta) || "queryagextfeed.sql";
			SYSTEM cSql;

			LET cSql = "";
			LET cSql = 'echo "' || "AND a.status_cliente = 'TE' AND fecha_insert = MDY(" ||MONTH(vfecha)|| "," ||DAY(vfecha)|| "," ||YEAR(vfecha)|| ");" || '">>' || TRIM(cruta) || "queryagextfeed.sql";
			SYSTEM cSql;
		
		END IF;
		
		--ASIGNACION DE PERMISO AL ARCHIVO TEMPORAL QUE CONTIENE EL QUERY DE LA DESCARGA
		LET cSql = "";
		LET cSql = "chmod 777 " || TRIM(cruta) || "queryagextfeed.sql";
		SYSTEM cSql;

		--EJCUCION DEL ARCHIVO TEMPORAL QUE CONTIENE EL QUERY DE LA DESCARGA
		LET cSql = "";
		LET cSql = "dbaccess bdicobranza " || TRIM(cruta) || "queryagextfeed.sql";
		SYSTEM cSql;

		--SE PASA LA INFORMACION DESCARGADA AL ARCHIVO FINAL
		LET cSql = "";
		LET cSql = "sed 's/|$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || vnom_archivo;
		SYSTEM cSql;

		--ASIGNACION DE PERMISO AL ARCHIVO FINAL
		LET cSql = "";
		LET cSql = "chmod 777 " || TRIM(cruta) || TRIM(vnom_archivo);
		SYSTEM cSql;

		--BORRADO DE ARCHIVOS TEMPORALES
		LET cSql = "";
		LET cSql = "rm " || TRIM(cruta) || "queryagextfeed.sql";		
		SYSTEM cSql;

		LET cSql = "";
		LET cSql = "rm " || TRIM(cruta) || TRIM(cnomarchivo1);
		SYSTEM cSql;

		--SE COMPACTA ARCHIVO FINAL
		LET cSql = "";
		LET cSql = "gzip -f " || TRIM(cruta) || TRIM(vnom_archivo);
		SYSTEM cSql;

		--ASIGNACION DE PERMISO AL ARCHIVO COMPACTADO
		LET cSql = "";
		LET cSql = "chmod 777 " || TRIM(cruta) || TRIM(vnom_archivo)||".gz";
		SYSTEM cSql;

		LET vnom_archivo = ""; LET cnomarchivo1 = ""; LET cSql = "";

	END FOREACH;
	
	
	
 /* ----------------------------------REPORTE TE--------------------------------

	LET vnom_archivo = "Reporte_feedback_TE_agex" || TO_CHAR(pfecha,'%d%m%Y') || ".txt";

	LET cnomarchivo1 = "Aux_" || vnom_archivo;

	LET cSql ='if [ -f '||TRIM(cruta)||TRIM(vnom_archivo)||'.gz ]; then nice nice -n -30 rm -f '||TRIM(cruta)||TRIM(vnom_archivo)||'.gz; fi';
	System cSql;

	--SE ARMA SCRIPT QUE CONTENDRA EL QUERY DE LA DESCARGA DE LA INFORMACION
	LET cSql = "";
	LET cSql = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || '">' || TRIM(cruta) || "queryagextfeedTE.sql";
	SYSTEM cSql;

	LET cSql = "";
	LET cSql = 'echo "' || "SELECT TO_CHAR(TODAY,'%d/%m/%Y'), a.num_producto, a.numcte, a.num_credito," || '">>' || TRIM(cruta) || "queryagextfeedTE.sql";
	SYSTEM cSql;

	LET cSql = "";
	LET cSql = 'echo "' || "b.monto_ultimo_pago, TO_CHAR(b.fecha_ultimo_pago,'%d/%m/%Y'), c.mto_venc_trasp, c.sdo_cap_insoluto," || '">>' || TRIM(cruta) || "queryagextfeedTE.sql";
	SYSTEM cSql;

	LET cSql = "";
	LET cSql = 'echo "' || "(c.saldovencido1 + c.interesmoratorio1 + c.interesmoratorio2 + c.interesmoratorio3 + c.interesmoratorio4 + c.interesmoratorio5 + c.interesmoratorio6 + c.sdo_intereses) pago_vencido1_inicial," || '">>' || TRIM(cruta) || 'queryagextfeedTE.sql';
	SYSTEM cSql;

	LET cSql = "";
	LET cSql = 'echo "' || "(c.saldovencido2 + c.saldovencido1 + c.interesmoratorio1 + c.interesmoratorio2 + c.interesmoratorio3 + c.interesmoratorio4 + c.interesmoratorio5 + c.interesmoratorio6 + c.sdo_intereses) pago_vencido2_inicial," || '">>' || TRIM(cruta) || 'queryagextfeedTE.sql';
	SYSTEM cSql;

	LET cSql = "";
	LET cSql = 'echo "' || "(c.saldovencido3 + c.saldovencido2 + c.saldovencido1 + c.interesmoratorio1 + c.interesmoratorio2 + c.interesmoratorio3 + c.interesmoratorio4 + c.interesmoratorio5 + c.interesmoratorio6 + c.sdo_intereses) pago_vencido3_inicial," || '">>' || TRIM(cruta) || 'queryagextfeedTE.sql';
	SYSTEM cSql;

	LET cSql = "";
	LET cSql = 'echo "' || "(c.saldovencido6 + c.saldovencido5 + c.saldovencido4 + c.saldovencido3 + c.saldovencido2 + c.saldovencido1 + c.interesmoratorio1 + c.interesmoratorio2 + c.interesmoratorio3 + c.interesmoratorio4 + c.interesmoratorio5 + c.interesmoratorio6 + c.sdo_intereses) pago_vencido4_inicial" || '">>' || TRIM(cruta) || 'queryagextfeedTE.sql';
	SYSTEM cSql;

	LET cSql = "";
	LET cSql = 'echo "' || "FROM bdicobranza:cb_cat_directorio_cte a" || '">>' || TRIM(cruta) || "queryagextfeedTE.sql";
	SYSTEM cSql;
	
	LET cSql = "";
	LET cSql = 'echo "' || "LEFT OUTER JOIN bdicred:'informix'.sd_indicador_cred b ON(b.empresa = a.empresa AND b.num_credito = a.num_credito)" || '">>' || TRIM(cruta) || "queryagextfeedTE.sql";
	SYSTEM cSql;

	LET cSql = "";
	LET cSql = 'echo "' || "LEFT OUTER JOIN bdicred:'informix'.sd_sdos_cartera_linea c ON(c.num_credito = a.num_credito)" || '">>' || TRIM(cruta) || "queryagextfeedTE.sql";
	SYSTEM cSql;

	LET cSql = "";
	LET cSql = 'echo "' || "WHERE a.tipo_cobranza = 'A'" || '">>' || TRIM(cruta) || "queryagextfeedTE.sql";
	SYSTEM cSql;

	LET cSql = "";
	LET cSql = 'echo "' || "AND a.status_cliente = 'TE' AND fecha_insert = MDY(" ||MONTH(vfecha)|| "," ||DAY(vfecha)|| "," ||YEAR(vfecha)|| ");" || '">>' || TRIM(cruta) || "queryagextfeedTE.sql";
	SYSTEM cSql;

	--ASIGNACION DE PERMISO AL ARCHIVO TEMPORAL QUE CONTIENE EL QUERY DE LA DESCARGA
	LET cSql = "";
	LET cSql = "chmod 777 " || TRIM(cruta) || "queryagextfeedTE.sql";
	SYSTEM cSql;

	--EJCUCION DEL ARCHIVO TEMPORAL QUE CONTIENE EL QUERY DE LA DESCARGA
	LET cSql = "";
	LET cSql = "dbaccess bdicobranza " || TRIM(cruta) || "queryagextfeedTE.sql";
	SYSTEM cSql;

	--SE PASA LA INFORMACION DESCARGADA AL ARCHIVO FINAL
	LET cSql = "";
	LET cSql = "sed 's/|$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || vnom_archivo;
	SYSTEM cSql;

	--ASIGNACION DE PERMISO AL ARCHIVO FINAL
	LET cSql = "";
	LET cSql = "chmod 777 " || TRIM(cruta) || TRIM(vnom_archivo);
	SYSTEM cSql;

	--BORRADO DE ARCHIVOS TEMPORALES
	LET cSql = "";
	LET cSql = "rm " || TRIM(cruta) || "queryagextfeedTE.sql";		
	SYSTEM cSql;

	LET cSql = "";
	LET cSql = "rm " || TRIM(cruta) || TRIM(cnomarchivo1);
	SYSTEM cSql;

	--SE COMPACTA ARCHIVO FINAL
	LET cSql = "";
	LET cSql = "gzip " || TRIM(cruta) || TRIM(vnom_archivo);
	SYSTEM cSql;

	--ASIGNACION DE PERMISO AL ARCHIVO COMPACTADO
	LET cSql = "";
	LET cSql = "chmod 777 " || TRIM(cruta) || TRIM(vnom_archivo)||".gz";
	SYSTEM cSql;

 */	
	
/*
	FOREACH WITH HOLD
		SELECT num_credito, tipo_cobranza
		INTO v_num_credito, v_tipo_cobranza
		FROM paso_agexmont
		WHERE num_credito > ""

		IF v_tipo_cobranza = 'A' THEN
			SELECT status_cred INTO cStatusCred
			FROM bdicred:"informix".sd_maecred
			WHERE empresa = "001"
			AND num_credito = v_num_credito;
		ELSE
			SELECT mae.status_cred, mas.mto_fin_ven_trasp INTO cStatusCred, sNumVencidos
			FROM bdicred:"informix".sd_maecredcrd mae
			INNER JOIN bdicred:"informix".sd_maesdoscrd mas ON (mas.num_credito = mae.num_credito)
			WHERE mae.num_credito = v_num_credito;
		END IF;

		IF (cStatusCred = 'AA') OR (cStatusCred = 'VP' AND sNumVencidos > 0) THEN	-- Cuentas que recibieron pago y se cubriÃÂ?ÃÂÃÂ³ la totalidad del pago vencido
			BEGIN;
				UPDATE "informix".cb_cat_directorio_cte_agex
				   SET f_vigencia = "0"
				WHERE num_credito = v_num_credito
				AND f_vigencia = "1";
			COMMIT;
		ELIF cStatusCred = 'CV' THEN	-- Las que estÃÂ?ÃÂÃÂ¡n en el proceso de venta de cartera y que se vendan
			BEGIN;
				UPDATE "informix".cb_cat_directorio_cte_agex
				   SET f_vigencia = "0"
				WHERE num_credito = v_num_credito
				AND f_vigencia = "1";
			COMMIT;
		ELIF cStatusCred IN ('FF','FC','FI') THEN	-- Las que estÃÂ?ÃÂÃÂ¡n canceladas (independientemente su causa)
			BEGIN;
				UPDATE "informix".cb_cat_directorio_cte_agex
				   SET f_vigencia = "0"
				WHERE num_credito = v_num_credito
				AND f_vigencia = "1";
			COMMIT;
		END IF;
	END FOREACH;
*/
	DROP TABLE paso_agexmont;

	CALL "informix".sp_inserta_bitacora_cob("001", cProceso, cCodRet, "FIN PROCESO GENERA REPORTES PARA AGENCIA EXTERNA", '02') RETURNING P_COD_RET;

	IF P_COD_RET != '000000' THEN
		LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
		RETURN P_COD_RET,P_MENSAJE;
	END IF;

	RETURN cCodRet,P_MENSAJE;
END;
END PROCEDURE;