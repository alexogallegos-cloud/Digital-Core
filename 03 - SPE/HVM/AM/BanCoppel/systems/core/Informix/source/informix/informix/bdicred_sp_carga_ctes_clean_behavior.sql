CREATE PROCEDURE "informix".sp_carga_ctes_clean_behavior(pEmpresa CHAR(3))

RETURNING 
          CHAR(06) AS resultado,    CHAR(80) AS mensaje;
--GEV 201502 Proceso para realizar la carga del archivo de ctes clean behavior.

DEFINE vproceso         CHAR(4);
DEFINE cCod_RetIB       CHAR(6);
DEFINE dFechaHoy        DATE;
DEFINE dFechaAumLinCrd  DATE;
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cRutaArch        CHAR(100);
DEFINE cParamNomArch    CHAR(100);
DEFINE cNomArchivo      CHAR(150);
DEFINE cNomArchivo2		CHAR(150);
DEFINE cNomArchEjecSql  CHAR(100);
DEFINE cSQL             CHAR(1500);
DEFINE vDiaRegistro		SMALLINT;

DEFINE cArchivo_dbld	CHAR(50);
DEFINE cArchivo_log		CHAR(50);
DEFINE cArchivo_out		CHAR(50);


--	SET DEBUG FILE TO "/respaldos/Israel/sp_carga_ctes_clean_behavior.out";
--	TRACE ON;

LET vproceso        = '3402';
LET cCod_RetIB      = '000000';
LET dFechaHoy       = DATE(0); 
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = '000000';
LET cMensajeRet     = 'PROCESO EXITOSO';    
LET cRutaArch       = '';
LET cNomArchivo     = '';
LET cNomArchivo2	= '';
LET cNomArchEjecSql = '';
LET cSQL            = '';
LET vDiaRegistro	= 0;

LET cArchivo_dbld	= "f_datosctes_clean.cmd";
LET cArchivo_log	= "f_datosctes_clean.log";
LET cArchivo_out	= "f_datosctes_clean.out";

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        LET cCodRet = iSqlErr;
        LET cMensajeRet = cErrorInfo;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, trim(cMensajeRet) || "-" || iIsamErr::CHAR, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 3;

    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '01') Returning cCod_RetIB;

    IF ( NVL(pEmpresa,"") = "" ) THEN
        LET cCodRet= '102005'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas WHERE empresa = pempresa;
    IF ( dFechaHoy IS NULL ) THEN
        LET cCodRet= '20013'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

--IPCB Dic2015 se cambia la extracciÃÂ³n de fecha de la sd_fechas_aumlincred x sd_fechas, manejando como constante el dia 10 a lo largo del mes
	SELECT valor::SMALLINT INTO vDiaRegistro
	  FROM bdicred:"informix".sd_param 
	 WHERE cod_param = '049' AND empresa   = pEmpresa;
 
    --SELECT fecha_hoy INTO dFechaAumLinCrd FROM bdicred:"informix".sd_fechas_aumlincred  WHERE empresa = pEmpresa;
	SELECT mdy(month(fecha_hoy),vDiaRegistro, year(fecha_hoy)) INTO dFechaAumLinCrd  FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;
    IF dFechaAumLinCrd IS NULL OR dFechaAumLinCrd = date(1) OR dFechaAumLinCrd = date(0) THEN
        LET dFechaAumLinCrd = dFechaHoy;
    END IF
	
    SELECT trim(valor) INTO cParamNomArch FROM bdicred:sd_param WHERE cod_param = 107;
    IF ( NVL(cParamNomArch, "") = "" ) THEN
        LET cCodRet= '104006';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT trim(valor) INTO cRutaArch  FROM bdicred:sd_param WHERE cod_param = 103;
	
    IF ( NVL(cRutaArch, "") = "" ) THEN
        LET cCodRet = '104005';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;
	

    LET cNomArchivo = trim(cParamNomArch) || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
	LET cNomArchivo2 = trim(cParamNomArch) || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '_2.txt';

	system ' echo "FILE ' ||TRIM(cRutaArch) ||  TRIM(cNomArchivo2) ||' DELIMITER '|| "'" || '|' || "'" || ' 9;' || '">' || TRIM(cRutaArch) || TRIM(cArchivo_dbld);  
	system ' echo "INSERT INTO sd_clientes_clean_behavior;' || '">>' || TRIM(cRutaArch) || TRIM(cArchivo_dbld);
	system 'chmod 777 ' ||TRIM(cRutaArch) || TRIM(cArchivo_dbld);

	system ' echo "cat ' ||TRIM(cRutaArch) || TRIM(cNomArchivo) || ' | sed ' || "'" ||'s/ //g'|| "'" ||' | cut -d\| -f1,2 | awk -F \"|\" '|| "'" ||'{if(NF>0) print \"'||dFechaHoy|| '|\"'||'\$1'|| '\"|\"' ||'\$2\"'||'|||||||\"}'|| "'" ||' > '|| TRIM(cRutaArch)|| TRIM(cNomArchivo2)||';'|| '">' || TRIM(cRutaArch) || 'dbload_clean.sh';	
	system ' echo "date | tee -a ' ||TRIM(cRutaArch) || TRIM(cArchivo_out) || '">>' || TRIM(cRutaArch) || 'dbload_clean.sh';
	system ' echo "dbload -d bdicred -c '||TRIM(cRutaArch)|| TRIM(cArchivo_dbld)||' -l '||TRIM(cRutaArch)||TRIM(cArchivo_log)||' -e 20000000 -n 1000 -k | tee -a '||TRIM(cRutaArch) || TRIM(cArchivo_out) || '">>' || TRIM(cRutaArch)|| 'dbload_clean.sh'; 
	system ' echo "date | tee -a ' ||TRIM(cRutaArch) || TRIM(cArchivo_out) || '">>' || TRIM(cRutaArch) || 'dbload_clean.sh';       
	system 'chmod 777 ' || TRIM(cRutaArch)|| 'dbload_clean.sh';
	system TRIM(cRutaArch)|| 'dbload_clean.sh';


    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '03') Returning cCod_RetIB;

    RETURN cCodRet,cMensajeRet;

END
END PROCEDURE;