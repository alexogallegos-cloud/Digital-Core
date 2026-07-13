CREATE PROCEDURE "informix".sp_reporte_notifica_solic()
    RETURNING CHAR(6)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje;         

--Proceso para la generacion del reporte de las solicitudes de credito RQM 09 408 
--Creado: Diciembre 2018

DEFINE sql_err				INTEGER;
DEFINE iSqlErr              INTEGER;
DEFINE isam_err				INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cnombre				CHAR(100);
DEFINE cnombre2             CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoEjecSql   CHAR(2000);
DEFINE cSQL                 CHAR(5000);
DEFINE cSQLL                CHAR(2000);
DEFINE cSQL1                CHAR(5000);
DEFINE cSQL2                CHAR(5000);
DEFINE cSQL3                CHAR(5000);
DEFINE cSQL4                CHAR(100);
DEFINE cSQL5                CHAR(100);
DEFINE cSQL6                CHAR(10000);
DEFINE cSQL7                CHAR(100);
DEFINE cruta                CHAR(100);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE dia                  CHAR(2);
DEFINE mes                  CHAR(2);
DEFINE anio					CHAR(4);
DEFINE cfechacorte          DATE;
DEFINE dFechaHoy            DATE;
DEFINE cfech_corte1         DATE;
DEFINE cfech_corte2         DATE;
DEFINE cfech1               CHAR(12);
DEFINE cfech2               CHAR(12);
DEFINE cCodRet              CHAR(6);
DEFINE cMensajeRet          VARCHAR(100,1);	
--VARIABLES REPORTE
DEFINE linea_max_aut        DECIMAL(14,2);
DEFINE linea_min_aut        DECIMAL(14,2);
DEFINE gpo                  CHAR(1);
DEFINE subtotal             DECIMAL(14,2);
DEFINE v_salariomin         DECIMAL(14,2);
DEFINE v_diaspromedio       DECIMAL(14,2);
DEFINE v_empresa            CHAR(3);
DEFINE min_cap_pag_min      DECIMAL(10,2);
DEFINE v_sepa               CHAR(2);

DEFINE s_status               INTEGER;
DEFINE nom_status             CHAR(2);
DEFINE min_ingreso_mensual_lc DECIMAL(14,2); 
DEFINE max_ingreso_mensual_lc DECIMAL(14,2); 
DEFINE min_valor_rab          DECIMAL(18,2); 
DEFINE max_tope_ingreso_tope  DECIMAL(14,2); 
DEFINE max_porc_incre         DECIMAL(5,2);
DEFINE max_monto_incre        DECIMAL(18,2); 
DEFINE min_porc_decre         DECIMAL(5,2); 
DEFINE min_monto_decre        DECIMAL(18,2);
DEFINE n_producto             CHAR(4);
DEFINE flujo_min              DECIMAL(14,2);


--Inicializacion de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "PROCESO NO EXITOSO";
LET cCod_Ret                = '00000';
LET cMensaje                = "";
LET cruta                   = "";
LET cnombre					= "NOTIFICA_SOLIC_";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cnomarchivoEjecSql      = "";
LET cSQL                    = "";
LET cSQLL                   = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cSQL4                   = "";
LET cSQL5                   = "";
LET cSQL6                   = "";
LET cSQL7                   = "";
LET mes                     = "";
LET anio					= "";
LET dia  					= "";
LET cfechacorte             = "";
LET dFechaHoy               = "";
LET cfech_corte1            = NULL;
LET cfech_corte2            = NULL;
LET cfech1                  = NULL;
LET cfech2                  = NULL;
LET cCodRet                 = '00000';
LET cMensajeRet             = '';
LET v_sepa                 	= '\|';
--INICIALIZA VARIABLES REPORTE
LET linea_max_aut        = 0;
LET linea_min_aut        = 0;
LET gpo                  = "";
LET subtotal             = 0;
LET v_diaspromedio       = 0;
LET v_salariomin         = 0;
LET v_empresa            = '001';
LET min_cap_pag_min      = 0;
LET s_status               = 0;
LET nom_status             = '';
LET min_ingreso_mensual_lc = 0.0; 
LET max_ingreso_mensual_lc = 0.0; 
LET min_valor_rab          = 0.0; 
LET max_tope_ingreso_tope  = 0.0; 
LET max_porc_incre         = 0.0;
LET max_monto_incre        = 0.0; 
LET min_porc_decre         = 0.0; 
LET min_monto_decre        = 0.0;
LET n_producto             = '';
LET flujo_min              = 0.0;

 BEGIN
   	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet     = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet,cMensajeRet;
		END IF;
	END EXCEPTION;

  --SET DEBUG FILE TO '/ifxsif01/sp_reporte_solic_credito.out';
  --TRACE ON; 

SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;    

	--Obtener ruta del archivo
    SELECT TRIM(valor)  INTO cruta
    FROM bdicred:"informix".sd_param 
	WHERE empresa = '001'
    AND cod_param = '033'; -- /resplogifx/archivoscartera/
	
	--LET cruta = '/ifxsif01/'; -- PARA PRUEBAS
	
  	SELECT fecha_hoy
	INTO dFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = v_empresa; 
	
     SELECT (fecha_hoy - 7)
	INTO cfech_corte1
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = v_empresa;   

	
    SELECT (fecha_hoy - 1)
	INTO cfech_corte2
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = v_empresa; 	
	
	SELECT valor::DECIMAL(14,2)
    INTO v_salariomin -- Salario Minimo Base
	FROM bdisolic:"informix".ss_param
	WHERE empresa = v_empresa
	AND secuencia = 354;
	
	SELECT valor::DECIMAL(14,2)
    INTO v_diaspromedio -- Dias Promedio
	FROM bdisolic:"informix".ss_param
	WHERE empresa = v_empresa
	AND secuencia = 355;
		
	IF DAY(dFechaHoy) < 10 THEN
	   LET dia = '0' || DAY(dFechaHoy);
	ELSE 
	   LET dia = DAY(dFechaHoy); 
	END IF;
	
    IF MONTH(dFechaHoy) < 10 THEN
	   LET mes = '0' || MONTH(dFechaHoy);
	ELSE 
	   LET mes = MONTH(dFechaHoy); 
	END IF;
	
	LET anio = TO_CHAR(YEAR(dFechaHoy));
	LET cfech1 =  TRIM(TO_CHAR(cfech_corte1,'%m,%d,%Y'));
	LET cfech2 =  TRIM(TO_CHAR(cfech_corte2,'%m,%d,%Y'));
	
	LET cFechaGenArchivo = dia || mes || anio;
        
	LET cSQL  = '';
	LET cSQL1 = '';
	LET cSQL2 = '';
	LET cSQL3 = ''; 
	LET cSQL4 = ''; 
	LET cSQL5 = '';
    LET cSQL6 = ''; 
	LET cSQL7 = '';
	LET subtotal = '';
	--LET cnomarchivo1 = '';
	LET cnomarchivo = '';
	LET cnomarchivoEjecSql = '';
	
    LET cMensajeRet = 'PROCESO INICIALIZADO';
	EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(v_empresa,'0097',cCodRet,cMensajeRet,'01')	INTO cCodRet;
	
	--Se definen nombres de archivos
	--LET cnomarchivo1 = trim(cnombre)||trim(cFechaGenArchivo)||'_Auxtdc'||'.unl ';
	LET cnomarchivo =  trim(cnombre)||trim(cFechaGenArchivo)||'.unl ';
    LET cnomarchivoEjecSql = 'Exec_Notifica_Solictdc.sql';

	LET subtotal = v_salariomin * v_diaspromedio;

	CREATE temp TABLE consultados ( num_solicitud CHAR(20), num_producto CHAR(4), status_solicitud CHAR(2), ingreso_mensual_lc DECIMAL(14,2)
	 ,valor_rab DECIMAL(18,2),tope_ingreso_tope DECIMAL(14,2), grupo CHAR(1),cap_pag_min DECIMAL(10,2),porc_incre DECIMAL(5,2)
	 ,monto_incre DECIMAL(18,2),porc_decre DECIMAL(5,2), monto_decre DECIMAL(18,2)) with no log; 
    --CREATE UNIQUE INDEX consultados_inx ON consultados(num_credito,num_producto, status_solicitud );


	--Se imprimen encabezados
    LET cSQL = '';
	LET cSQL = ' echo " Producto 6001'||v_sepa||'Total Solicitudes'||v_sepa||'Status Solicitud'||v_sepa||'Ing Min Solic'||v_sepa||'Ing Max Solic'||
	        v_sepa||'Valor Min RAB'||v_sepa||'Tope Ingreso Solic'||v_sepa||v_sepa||'Porc Inc Max Solic'||
			v_sepa||'Monto Inc Max Solic'||v_sepa||'Porc Dec Min Solic'||v_sepa||'Monto Dec Min Solic'||
			' " >>' || TRIM(cruta) || TRIM(cnomarchivo) || '';
    SYSTEM cSQL;
    
	INSERT INTO consultados
	--Generacion de universo de solicitudes
	SELECT  b.num_solicitud,b.num_producto,b.status_solicitud,a.ingreso_mensual_lc 
	,a.valor_rab , a.tope_ingreso_tope,a.grupo,nvl(a.cap_pag_min,0), nvl(a.porc_incre,0) porc_incre, nvl(a.monto_incre,0) monto_incre
	,nvl(a.porc_decre,0) porc_decre, nvl(a.monto_decre ,0) monto_decre 
	FROM bdisolic:"informix".ss_solicitudes b 
	JOIN bdisolic:"informix".ss_revision_determinacion a on b.num_solicitud = a.num_solicitud  
	WHERE b.status_solicitud IN ('AT','AP','RT','OS','MC')  
	AND a.fecha_insert::DATE >= cfech1   AND a.fecha_insert::DATE <=  cfech2  
	--AND date(a.fecha_insert) BETWEEN mdy (cfech1) AND mdy (cfech2) 
	AND a.num_producto in ('6001','6300','7600','7700');
		
	
	FOREACH WITH HOLD
		--Se arma consulta para extraccion de datos	para producto 6001
		SELECT  count(a.status_solicitud),a.status_solicitud, min(case when a.ingreso_mensual_lc > 0 then a.ingreso_mensual_lc end )  
		,max(case when a.ingreso_mensual_lc > 0 then a.ingreso_mensual_lc end )  
		,min(a.valor_rab) ,max(a.tope_ingreso_tope) , max(a.porc_incre) porc_incre, max(a.monto_incre) monto_incre  
		,nvl(min(case when a.porc_decre > 0 then nvl(a.porc_decre,0) end ),0) porc_decre
		,nvl(min(case when a.monto_decre > 0 then nvl(a.monto_decre,0) end ),0) monto_decre 
		INTO s_status,nom_status, min_ingreso_mensual_lc, max_ingreso_mensual_lc,min_valor_rab,max_tope_ingreso_tope, max_porc_incre
		,max_monto_incre, min_porc_decre, min_monto_decre
		FROM consultados a WHERE a.num_producto = '6001' 
		GROUP BY a.status_solicitud ORDER BY a.status_solicitud
		
	LET cSQLL = 'echo '||s_status||v_sepa||TRIM(nom_status)||v_sepa||min_ingreso_mensual_lc||v_sepa||max_ingreso_mensual_lc||v_sepa||min_valor_rab||
		v_sepa||max_tope_ingreso_tope||v_sepa||max_porc_incre||v_sepa||max_monto_incre||v_sepa||min_porc_decre||v_sepa||min_monto_decre||' >>'||TRIM(cruta)||TRIM(cnomarchivo);
	SYSTEM cSQLL;
        		
	END FOREACH;

	LET cSQLL = ' echo "Grupo'||v_sepa||'Linea Min autorizda'||v_sepa||'Linea Max autorizda'||v_sepa ||'Cap Minima Abono'||' " >> '||TRIM(cruta)||TRIM(cnomarchivo);
	SYSTEM cSQLL;
			
	FOREACH WITH HOLD

		SELECT grupo,(SUM(ROUND(cant_smb_inf * subtotal,-2))), --linea minima autorizada
		(SUM(ROUND(cant_smb_sup * subtotal,-2))), min_flujo --linea maxima autorizada
		INTO gpo,linea_min_aut,linea_max_aut, flujo_min FROM bdisolic:"informix".ss_scoring_solic 
		WHERE empresa = v_empresa AND tp_solicitud = 'T'
		AND seccion = 2 AND activa = '1' AND grupo <> '' GROUP BY grupo,min_flujo ORDER BY grupo ASC

		--Se arma consulta para extraccion de datos
		LET cSQL4 = ' echo " ' || gpo || v_sepa || linea_min_aut || v_sepa || linea_max_aut || v_sepa|| flujo_min;			
		LET cSQL5 = ' " >> '||TRIM(cruta)||TRIM(cnomarchivo);
		LET cSQL =  TRIM(cSQL4) || TRIM(cSQL5);
		SYSTEM cSQL;		
		
	END FOREACH;
				
	------------------------------
	LET cSQL='';
	LET cSQL = ' echo "Producto 6300 '||v_sepa||'Total Solicitudes'||v_sepa||'Status Solicitud'||v_sepa||'Ing Min Solic'||v_sepa||'Ing Max Solic'||
	        v_sepa||'Valor Min RAB'||v_sepa||'Tope Ingreso Solic'||v_sepa||v_sepa||'Porc Inc Max Solic'||
			v_sepa||'Monto Inc Max Solic'||v_sepa||'Porc Dec Min Solic'||v_sepa||'Monto Dec Min Solic'||
			' " >>' || TRIM(cruta) || TRIM(cnomarchivo) || '';
    SYSTEM cSQL;
	
    FOREACH WITH HOLD
		--Se arma consulta para extraccion de datos	para producto 6300
		SELECT  count(a.status_solicitud),a.status_solicitud, min(case when a.ingreso_mensual_lc > 0 then a.ingreso_mensual_lc end )  
		,max(case when a.ingreso_mensual_lc > 0 then a.ingreso_mensual_lc end )  
		,min(a.valor_rab) ,max(a.tope_ingreso_tope) , max(a.porc_incre) porc_incre, max(a.monto_incre) monto_incre  
		,nvl(min(case when a.porc_decre > 0 then nvl(a.porc_decre,0) end ),0) porc_decre
		,nvl(min(case when a.monto_decre > 0 then nvl(a.monto_decre,0) end ),0) monto_decre 
		INTO s_status,nom_status, min_ingreso_mensual_lc, max_ingreso_mensual_lc,min_valor_rab,max_tope_ingreso_tope, max_porc_incre
		,max_monto_incre, min_porc_decre, min_monto_decre
		FROM consultados a WHERE a.num_producto = '6300' 
		GROUP BY a.status_solicitud ORDER BY a.status_solicitud	
		
	LET cSQLL = 'echo '||s_status||v_sepa||TRIM(nom_status)||v_sepa||min_ingreso_mensual_lc||v_sepa||max_ingreso_mensual_lc||v_sepa||min_valor_rab||v_sepa||
		max_tope_ingreso_tope||v_sepa||max_porc_incre||v_sepa||max_monto_incre||v_sepa||min_porc_decre||v_sepa||min_monto_decre||' >>'||TRIM(cruta)||TRIM(cnomarchivo);
	SYSTEM cSQLL;
		    
    END FOREACH;
	
	LET cSQLL = ' echo "Grupo'||v_sepa||'Linea Min autorizda'||v_sepa||'Linea Max autorizda'||' " >> '||TRIM(cruta)||TRIM(cnomarchivo);
	SYSTEM cSQLL;
			
	FOREACH WITH HOLD

		SELECT grupo,(SUM(ROUND(cant_smb_inf * subtotal,-2))), --linea minima autorizada
		(SUM(ROUND(cant_smb_sup * subtotal,-2))), min_flujo --linea maxima autorizada
		INTO gpo,linea_min_aut,linea_max_aut, flujo_min FROM bdisolic:"informix".ss_scoring_solic 
		WHERE empresa = v_empresa AND tp_solicitud = 'P'
		AND seccion = 2 AND activa = '1' AND grupo <> '' GROUP BY grupo,min_flujo ORDER BY grupo ASC

		--Se arma consulta para extraccion de datos
		LET cSQL4 = ' echo " ' || gpo || v_sepa || linea_min_aut || v_sepa || linea_max_aut;			
		LET cSQL5 = ' " >> '||TRIM(cruta)||TRIM(cnomarchivo);
		LET cSQL =  TRIM(cSQL4) || TRIM(cSQL5);
		SYSTEM cSQL;		
		
	END FOREACH;
	
	--Se imprimen encabezados
	LET cSQLL = ' echo "Grupo'||v_sepa||'Capacidad Minima Abono'||v_sepa ||' " >> '||TRIM(cruta)||TRIM(cnomarchivo);
	SYSTEM cSQLL;
			
	CREATE temp TABLE cred_grupo2 (grupo CHAR(1),cap_pag_min DECIMAL(10,2)) with no log; 		

	Insert into cred_grupo2
		SELECT a.grupo, NVL(MIN(a.cap_pag_min),0)
		FROM bdisolic:"informix".ss_solicitudes b 
		JOIN bdisolic:"informix".ss_revision_determinacion a on b.num_solicitud = a.num_solicitud  
		WHERE b.status_solicitud IN ('AT','AP','RT','OS','MC')  
		AND a.fecha_insert::DATE >= cfech1   AND a.fecha_insert::DATE <=  cfech2  
		AND a.num_producto in ('6300')
		GROUP BY a.grupo ORDER BY a.grupo ASC;

	FOREACH	 WITH HOLD		
		SELECT a.grupo, NVL(MIN(a.cap_pag_min),0)
		INTO gpo , min_cap_pag_min
		FROM cred_grupo2  a
		GROUP BY a.grupo ORDER BY a.grupo ASC

		--Se arma consulta para extraccion de datos
		LET cSQL4 = ' echo " ' || gpo || v_sepa || min_cap_pag_min || v_sepa;			
		LET cSQL5 = ' " >> '||TRIM(cruta)||TRIM(cnomarchivo);
		LET cSQL =  TRIM(cSQL4) || TRIM(cSQL5);
		SYSTEM cSQL;			
	END FOREACH;

		------------------------------
    LET cSQL='';
    LET cSQL = ' echo " Producto 7600'||v_sepa||'Total Solicitudes'||v_sepa||'Status Solicitud'||v_sepa||'Ing Min Solic'||v_sepa||'Ing Max Solic'||
	        v_sepa||'Valor Min RAB'||v_sepa||'Tope Ingreso Solic'||v_sepa||v_sepa||'Porc Inc Max Solic'||
			v_sepa||'Monto Inc Max Solic'||v_sepa||'Porc Dec Min Solic'||v_sepa||'Monto Dec Min Solic'||
			' " >>' || TRIM(cruta) || TRIM(cnomarchivo) || '';
    SYSTEM cSQL;
	
    FOREACH WITH HOLD
		--Se arma consulta para extraccion de datos	para producto 7600
		SELECT  count(a.status_solicitud),a.status_solicitud, min(case when a.ingreso_mensual_lc > 0 then a.ingreso_mensual_lc end )  
		,max(case when a.ingreso_mensual_lc > 0 then a.ingreso_mensual_lc end )  
		,min(a.valor_rab) ,max(a.tope_ingreso_tope) , max(a.porc_incre) porc_incre, max(a.monto_incre) monto_incre  
		,nvl(min(case when a.porc_decre > 0 then nvl(a.porc_decre,0) end ),0) porc_decre
		,nvl(min(case when a.monto_decre > 0 then nvl(a.monto_decre,0) end ),0) monto_decre 
		INTO s_status,nom_status, min_ingreso_mensual_lc, max_ingreso_mensual_lc,min_valor_rab,max_tope_ingreso_tope, max_porc_incre
		,max_monto_incre, min_porc_decre, min_monto_decre
		FROM consultados a WHERE a.num_producto = '7600' 
		GROUP BY a.status_solicitud ORDER BY a.status_solicitud
				
		LET cSQLL = 'echo '||s_status||v_sepa||TRIM(nom_status)||v_sepa||min_ingreso_mensual_lc||v_sepa||max_ingreso_mensual_lc||v_sepa||min_valor_rab||v_sepa||
			max_tope_ingreso_tope||v_sepa||max_porc_incre||v_sepa||max_monto_incre||v_sepa||min_porc_decre||v_sepa||min_monto_decre||' >>'||TRIM(cruta)||TRIM(cnomarchivo);
		SYSTEM cSQLL;
		
    END FOREACH;
	
	LET cSQLL = ' echo "Grupo'||v_sepa||'Linea Min autorizda'||v_sepa||'Linea Max autorizda'||' " >> '||TRIM(cruta)||TRIM(cnomarchivo);
	SYSTEM cSQLL;
			
	FOREACH WITH HOLD

		SELECT grupo,(SUM(ROUND(cant_smb_inf * subtotal,-2))), --linea minima autorizada
		(SUM(ROUND(cant_smb_sup * subtotal,-2))), min_flujo --linea maxima autorizada
		INTO gpo,linea_min_aut,linea_max_aut, flujo_min FROM bdisolic:"informix".ss_scoring_solic 
		WHERE empresa = v_empresa AND tp_solicitud = 'P'
		AND seccion = 2 AND activa = '1' AND grupo <> '' GROUP BY grupo,min_flujo ORDER BY grupo ASC

		--Se arma consulta para extraccion de datos
		LET cSQL4 = ' echo " ' || gpo || v_sepa || linea_min_aut || v_sepa || linea_max_aut;			
		LET cSQL5 = ' " >> '||TRIM(cruta)||TRIM(cnomarchivo);
		LET cSQL =  TRIM(cSQL4) || TRIM(cSQL5);
		SYSTEM cSQL;		
		
	END FOREACH;
		
	--Se imprimen encabezados
	LET cSQLL = ' echo "Grupo'||v_sepa||'Capacidad Minima Abono'||v_sepa ||' " >> '||TRIM(cruta)||TRIM(cnomarchivo);
	SYSTEM cSQLL;

	CREATE temp TABLE cred_grupo3 (grupo CHAR(1),cap_pag_min DECIMAL(10,2)) with no log; 

	Insert into cred_grupo3
		SELECT a.grupo, NVL(MIN(a.cap_pag_min),0)
		FROM bdisolic:"informix".ss_solicitudes b 
		JOIN bdisolic:"informix".ss_revision_determinacion a on b.num_solicitud = a.num_solicitud  
		WHERE b.status_solicitud IN ('AT','AP','RT','OS','MC')  
		AND a.fecha_insert::DATE >= cfech1   AND a.fecha_insert::DATE <=  cfech2 
		AND a.num_producto in ('7600')
		GROUP BY a.grupo ORDER BY a.grupo ASC;

	FOREACH	WITH HOLD	
		SELECT a.grupo, NVL(MIN(a.cap_pag_min),0)
		INTO gpo , min_cap_pag_min
		FROM cred_grupo3 a 
		GROUP BY a.grupo ORDER BY a.grupo ASC
		
		--Se arma consulta para extraccion de datos
		LET cSQL4 = ' echo " ' || gpo || v_sepa || min_cap_pag_min || v_sepa;			
		LET cSQL5 = ' " >> '||TRIM(cruta)||TRIM(cnomarchivo);
		LET cSQL =  TRIM(cSQL4) || TRIM(cSQL5);
		SYSTEM cSQL;			
	END FOREACH;
		--------------
    LET cSQL='';
    LET cSQL = ' echo " Producto 7700 '||v_sepa||'Total Solicitudes'||v_sepa||'Status Solicitud'||v_sepa||'Ing Min Solic'||v_sepa||'Ing Max Solic'||
	        v_sepa||'Valor Min RAB'||v_sepa||'Tope Ingreso Solic'||v_sepa||v_sepa||'Porc Inc Max Solic'||
			v_sepa||'Monto Inc Max Solic'||v_sepa||'Porc Dec Min Solic'||v_sepa||'Monto Dec Min Solic'||
			' " >>' || TRIM(cruta) || TRIM(cnomarchivo) || '';
    SYSTEM cSQL;
	
    FOREACH WITH HOLD
		--Se arma consulta para extraccion de datos	para producto 7700	
		SELECT  count(a.status_solicitud),a.status_solicitud, min(case when a.ingreso_mensual_lc > 0 then a.ingreso_mensual_lc end )  
		,max(case when a.ingreso_mensual_lc > 0 then a.ingreso_mensual_lc end )  
		,min(a.valor_rab) ,max(a.tope_ingreso_tope) , max(a.porc_incre) porc_incre, max(a.monto_incre) monto_incre  
		,nvl(min(case when a.porc_decre > 0 then nvl(a.porc_decre,0) end ),0) porc_decre
		,nvl(min(case when a.monto_decre > 0 then nvl(a.monto_decre,0) end ),0) monto_decre 
		INTO s_status,nom_status, min_ingreso_mensual_lc, max_ingreso_mensual_lc,min_valor_rab,max_tope_ingreso_tope, max_porc_incre
		,max_monto_incre, min_porc_decre, min_monto_decre
		FROM consultados a WHERE a.num_producto = '7700' 
		GROUP BY a.status_solicitud ORDER BY a.status_solicitud
		
	LET cSQLL = 'echo '||s_status||v_sepa||TRIM(nom_status)||v_sepa||min_ingreso_mensual_lc||v_sepa||max_ingreso_mensual_lc||v_sepa||min_valor_rab||v_sepa||
		max_tope_ingreso_tope||v_sepa||max_porc_incre||v_sepa||max_monto_incre||v_sepa||min_porc_decre||v_sepa||min_monto_decre|| ' >>'||TRIM(cruta)||TRIM(cnomarchivo);
	SYSTEM cSQLL;
		
    END FOREACH;
	
	LET cSQLL = ' echo "Grupo'||v_sepa||'Linea Min autorizda'||v_sepa||'Linea Max autorizda'||' " >> '||TRIM(cruta)||TRIM(cnomarchivo);
	SYSTEM cSQLL;
			
	FOREACH WITH HOLD

		SELECT grupo,(SUM(ROUND(cant_smb_inf * subtotal,-2))), --linea minima autorizada
		(SUM(ROUND(cant_smb_sup * subtotal,-2))), min_flujo --linea maxima autorizada
		INTO gpo,linea_min_aut,linea_max_aut, flujo_min FROM bdisolic:"informix".ss_scoring_solic 
		WHERE empresa = v_empresa AND tp_solicitud = 'P'
		AND seccion = 2 AND activa = '1' AND grupo <> '' GROUP BY grupo,min_flujo ORDER BY grupo ASC

		--Se arma consulta para extraccion de datos
		LET cSQL4 = ' echo " ' || gpo || v_sepa || linea_min_aut || v_sepa || linea_max_aut;			
		LET cSQL5 = ' " >> '||TRIM(cruta)||TRIM(cnomarchivo);
		LET cSQL =  TRIM(cSQL4) || TRIM(cSQL5);
		SYSTEM cSQL;		
		
	END FOREACH;
	
	--Se imprimen encabezados
	LET cSQLL = ' echo "Grupo'||v_sepa||'Capacidad Minima Abono'||v_sepa ||' " >> '||TRIM(cruta)||TRIM(cnomarchivo);
	SYSTEM cSQLL;									

	CREATE temp TABLE cred_grupo4 (grupo CHAR(1),cap_pag_min DECIMAL(10,2)) with no log; 

	Insert into cred_grupo4
	SELECT a.grupo, NVL(MIN(a.cap_pag_min),0)
	FROM bdisolic:"informix".ss_solicitudes b 
	JOIN bdisolic:"informix".ss_revision_determinacion a on b.num_solicitud = a.num_solicitud  
	WHERE b.status_solicitud IN ('AT','AP','RT','OS','MC')  
	AND a.fecha_insert::DATE >= cfech1   AND a.fecha_insert::DATE <=  cfech2 
	AND a.num_producto in ('7700')
	GROUP BY a.grupo ORDER BY a.grupo ASC;

	FOREACH	WITH HOLD	
		SELECT a.grupo, NVL(MIN(a.cap_pag_min),0)
		INTO gpo , min_cap_pag_min
		FROM cred_grupo4 a
		GROUP BY a.grupo ORDER BY a.grupo ASC

		--Se arma consulta para extraccion de datos
		LET cSQL4 = ' echo " ' || gpo || v_sepa || min_cap_pag_min || v_sepa;			
		LET cSQL5 = ' " >> '||TRIM(cruta)||TRIM(cnomarchivo);
		LET cSQL =  TRIM(cSQL4) || TRIM(cSQL5);
		SYSTEM cSQL;
	END FOREACH;

  	LET cMensajeRet = 'PROCESO FINALIZADO';
	EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(v_empresa,'0097',cCodRet,cMensajeRet,'03')	INTO cCodRet;

    LET cCod_Ret = '00000';
    LET cMensaje = 'PROCESO EXITOSO';
	
	RETURN cCod_Ret,cMensaje;

 END;         

END PROCEDURE;