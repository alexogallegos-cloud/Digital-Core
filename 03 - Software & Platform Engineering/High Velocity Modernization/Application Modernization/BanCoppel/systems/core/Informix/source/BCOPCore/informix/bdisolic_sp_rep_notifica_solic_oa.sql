CREATE PROCEDURE "informix".sp_rep_notifica_solic_oa()
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
DEFINE SCOD_RET             CHAR(6);
DEFINE COD_RET              CHAR(6);
DEFINE cnombre				CHAR(100);
DEFINE cnombre2             CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cSQL                 CHAR(5000);
DEFINE cSQLL                CHAR(2000);
DEFINE cruta                CHAR(100);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE dia                  CHAR(2);
DEFINE mes                  CHAR(2);
DEFINE anio					CHAR(4);
DEFINE dFechaHoy            DATE;
DEFINE cfech_corte1         DATE;
DEFINE cfech_corte2         DATE;
DEFINE cfech1               CHAR(12);
DEFINE cfech2               CHAR(12);
DEFINE cCodRet              CHAR(6);
DEFINE cMensajeRet          VARCHAR(100,1);	
--VARIABLES REPORTE
DEFINE numsol               CHAR(20);
DEFINE numprod              CHAR(4);
DEFINE fecha_insert         DATETIME YEAR TO SECOND;
DEFINE fechasolicstatusOA   DATETIME YEAR TO SECOND;
DEFINE fechaenviomsj1       DATE;
DEFINE fechaenviomsj3       DATE;
DEFINE nummsjenvio          SMALLINT;
DEFINE statussolic          CHAR(2);
DEFINE gpo                  CHAR(1);
DEFINE fechacambiostatus    DATE;
DEFINE v_sepa               CHAR(2);

DEFINE vFechaH 			DATE;
DEFINE vFechaU			DATE;
DEFINE vFechaA			DATE;
DEFINE vproceso			CHAR(4);
DEFINE v_empresa        CHAR(4);
DEFINE codigo_param     CHAR(3);

--Inicializacion de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "PROCESO NO EXITOSO";
LET cCod_Ret                = '';

LET SCOD_RET                = '';
LET cMensaje                = "";
LET cruta                   = "";
LET cnombre					= "REPORTE_SOLIC_OA_AT_";
LET cnomarchivo             = "";
LET cSQL                    = "";
LET cSQLL                   = "";
LET mes                     = "";
LET anio					= "";
LET dia  					= "";
LET dFechaHoy               = "";
LET cfech_corte1            = NULL;
LET cfech_corte2            = NULL;
LET cfech1                  = NULL;
LET cfech2                  = NULL;
LET cCodRet                 = '';
LET cMensajeRet             = '';
LET v_sepa                 	= '\|';
LET vproceso			    = '0099';
--INICIALIZA VARIABLES REPORTE

LET numsol               = "";
LET numprod              = "";
LET fecha_insert         = "";
LET fechasolicstatusOA   = "";
LET fechaenviomsj1       = "";
LET fechaenviomsj3       = "";
LET nummsjenvio          = 0;
LET fechacambiostatus    = "";
LET statussolic          = "";
LET gpo                  = "";
LET COD_RET              = '';
LET vFechaH				 = NULL;
LET vFechaU				 = NULL;
LET vFechaA				 = NULL;
LET v_empresa            = '001';
LET codigo_param         = '033';

 BEGIN
   	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCod_Ret = iSqlErr;
			LET COD_RET = cCod_Ret;	
			LET cMensaje = 'Error al ejecutar el proceso.';			
			RETURN COD_RET,cMensaje;		
		END IF;
	END EXCEPTION;

  --SET DEBUG FILE TO '/informix/rep_notificacion_solicitudes_oa.out';
  --TRACE ON; 

SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;    

	--Obtener ruta del archivo
    SELECT TRIM(valor)  INTO cruta
    FROM bdicred:"informix".sd_param 
	WHERE empresa = v_empresa AND cod_param = codigo_param; -- /resplogifx/archivoscartera/
	
    SELECT fecha_hoy, pri_dia_mes, ult_dia_mes INTO vFechaH, vFechaA, vFechaU FROM bdicred:"informix".sd_fechas WHERE empresa = v_empresa;
	
		
	IF DAY(vFechaH) < 10 THEN
	   LET dia = '0' || DAY(vFechaH);
	ELSE 
	   LET dia = DAY(vFechaH); 
	END IF;
	
    IF MONTH(vFechaH) < 10 THEN
	   LET mes = '0' || MONTH(vFechaH);
	ELSE 
	   LET mes = MONTH(vFechaH); 
	END IF;
	
	LET cfech_corte1 = vFechaA;
	LET cfech_corte2 = vFechaU;
	
	LET anio = TO_CHAR(YEAR(vFechaH));
	LET cfech1 =  TRIM(TO_CHAR(cfech_corte1,'%m,%d,%Y'));
	LET cfech2 =  TRIM(TO_CHAR(cfech_corte2,'%m,%d,%Y'));
	
	LET cFechaGenArchivo = dia || mes || anio;
        
	LET cSQL  = '';
	LET cSQLL = '';
	LET cnomarchivo = '';
		
    LET cMensajeRet = 'PROCESO INICIALIZADO REPORTE SOLICITUDES OA';
	EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(v_empresa,vproceso,cCod_Ret,cMensajeRet,'01')	INTO SCOD_RET;
	IF SCOD_RET = '000000' THEN LET cCodRet = '00000'; END IF;
	
	IF SCOD_RET != '000000' THEN
		LET cCod_Ret = SUBSTRING(SCOD_RET FROM 2 FOR 5);
		LET COD_RET = cCod_Ret;
		LET cMensaje  = 'Error en el llamado a la insercion en bitacora.';
		RETURN COD_RET,cMensaje;
	END IF;
	
	--Se definen nombres de archivos
	LET cnomarchivo =  trim(cnombre)||trim(cFechaGenArchivo)||'.txt ';
    
	DROP TABLE IF EXISTS consultados;
	CREATE temp TABLE consultados ( num_solicitud CHAR(20), num_producto CHAR(4), fecha_hora DATETIME YEAR TO SECOND, fecha_status_OA DATETIME YEAR TO SECOND, 
	fecha_msj1 DATE,fecha_msj3 DATE,num_msj_enviado SMALLINT,fecha_status_sol DATE,status_solicitud CHAR(2),grupo CHAR(1)) with no log; 
    
	--Se imprimen encabezados
    LET cSQL = '';
	LET cSQL = ' echo "'||'Solicitud'||v_sepa||'Producto'||v_sepa||'Fecha Alta Solicitud'||v_sepa||'Fecha Status OA'||
	        v_sepa||'Fecha Envio Primer Mensaje'||v_sepa||'Fecha Envio Ultimo Mensaje'||v_sepa||'Numero de envios mensajes'||
			v_sepa||'Fecha cambio estatus AT RT CN'||v_sepa||'Estatus Solicitud'||v_sepa||'Grupo'||
			' " >>' || TRIM(cruta) || TRIM(cnomarchivo) || '';
    SYSTEM cSQL;
    
	 --Para pruebas
	INSERT INTO consultados
	--Generacion de universo de solicitudes
	SELECT sol.num_solicitud, sol.num_producto, solic.fecha_hora, 
	sol.fecha_cambio_status_oa,sol.fecha_envio_msj1, sol.fecha_envio_msj3, sol.num_msj_envio, 
	sol.fecha_cambio_status,sol.status_solicitud,sol.grupo
	FROM bdisolic:"informix".ss_solicitudes_envio_oa sol
	JOIN bdisolic:"informix".ss_autorizacion os ON (sol.num_solicitud = os.num_solicitud AND sol.status_solicitud = os.status_solicitud)
	JOIN bdisolic:"informix".ss_solicitudes solic ON (solic.num_solicitud = os.num_solicitud )
	WHERE sol.status_solicitud IN ('OA','AT','RT','CN') 
	AND os.fecha_hora::DATE >= vFechaA AND os.fecha_hora::DATE <=  vFechaU;

	
	FOREACH WITH HOLD
		SELECT a.num_solicitud, nvl(a.num_producto,''), nvl(a.fecha_hora,''), nvl(a.fecha_status_OA,''), nvl(a.fecha_msj1,''), nvl(a.fecha_msj3,''), 
		    nvl(a.num_msj_enviado,0), nvl(a.fecha_status_sol,''), nvl(a.status_solicitud,''), nvl(a.grupo,'')
		INTO numsol,numprod,fecha_insert,fechasolicstatusOA,fechaenviomsj1,fechaenviomsj3,nummsjenvio,fechacambiostatus,statussolic,gpo
		FROM consultados a
		
		LET cSQLL = 'echo '||TRIM(numsol)||v_sepa||TRIM(numprod)||v_sepa||nvl(fecha_insert,'')||v_sepa||nvl(fechasolicstatusOA,'')||v_sepa||nvl(fechaenviomsj1,'')||
			v_sepa||nvl(fechaenviomsj3,'')||v_sepa||nvl(nummsjenvio,0)||v_sepa||nvl(fechacambiostatus,'')||v_sepa||nvl(statussolic,'')||v_sepa||nvl(gpo,'')||'  >>'||TRIM(cruta)||TRIM(cnomarchivo);
		SYSTEM cSQLL;
        		
	END FOREACH;

  	LET cMensajeRet = 'PROCESO FINALIZADO REPORTE SOLICITUDES OA';
	EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(v_empresa,vproceso,cCod_Ret,cMensajeRet,'03')	INTO SCOD_RET;
	IF SCOD_RET = '000000' THEN LET cCodRet = '00000'; END IF;
	
	IF SCOD_RET != '000000' THEN
		LET cCod_Ret = SUBSTRING(SCOD_RET FROM 2 FOR 5);
		LET COD_RET = cCod_Ret;
		LET cMensaje  = 'Error en el llamado a la insercion en bitacora.';
		RETURN COD_RET,cMensaje;
	END IF;
	
    LET COD_RET = cCodRet;
    LET cMensaje = 'PROCESO EXITOSO';
	
	RETURN COD_RET,cMensaje;

 END;         

END PROCEDURE;