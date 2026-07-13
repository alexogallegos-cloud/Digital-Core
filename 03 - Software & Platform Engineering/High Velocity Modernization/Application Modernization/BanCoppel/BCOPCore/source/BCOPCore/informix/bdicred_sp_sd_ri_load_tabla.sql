CREATE PROCEDURE "informix".sp_sd_ri_load_tabla(pParamNomArch CHAR(20),pParamNomTabla CHAR(40),pRutaArch CHAR(40))

RETURNING 
          CHAR(06) AS resultado,    CHAR(80) AS mensaje;
--Proceso para realizar la carga del archivo a una tabla de la BD.

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
DEFINE cNomArchEjecSql  CHAR(100);
DEFINE cSQL             CHAR(1500);
DEFINE vDiaRegistro		SMALLINT;
DEFINE pEmpresa         CHAR(40);



--SET DEBUG FILE TO "/informix/PLL/RI/Log/" || TRIM(pParamNomArch)||".out";
--TRACE ON;

LET vproceso        = '3403'; -- Folio proporcionado por area de Credito de consumo email
LET cCod_RetIB      = '000000';
LET dFechaHoy       = DATE(0);   
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = '000000';
LET cMensajeRet     = 'PROCESO EXITOSO';    
LET cRutaArch       = '';
LET cNomArchivo     = '';
LET cNomArchEjecSql = '';
LET cSQL            = '';
LET vDiaRegistro	= 0;
LET pEmpresa		='001';



BEGIN

   ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        LET cCodRet = iSqlErr;
        LET cMensajeRet = cErrorInfo;
		--ROLLBACK WORK;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, trim(cMensajeRet) || "-" || iIsamErr::CHAR, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 10;
	
    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '01') Returning cCod_RetIB;

    IF (NVL(pParamNomArch, "") = ""  OR   NVL(pParamNomTabla,"") = "" OR NVL(pRutaArch,"") = "" )  
        THEN 
        LET cCodRet= '104006'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;
   
   
   SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas WHERE empresa = pEmpresa;
    IF ( dFechaHoy IS NULL ) THEN
        LET cCodRet= '20013';  -- No se informo la fecha.
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; 
		END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;
    
	   --LET dFechaHoy = mdy (03,10,2018); ---- pruebas
	   --LET dFechaAumLinCrd = mdy (03,10,2018); ---- pruebas
	
    LET cNomArchivo = trim(pParamNomArch) ||  lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
    LET cNomArchEjecSql = trim(pParamNomArch)||'.sql'; -- ARCHIVO SALIDA
	

    -- Realiza carga de archivo.   
   
    LET cSQL = '';
    LET cSQL = ' echo " LOAD FROM ' || TRIM(pRutaArch) || TRIM(cNomArchivo) 
            || ' INSERT INTO '||TRIM(pParamNomTabla)||';">' || TRIM(pRutaArch) || TRIM(cNomArchEjecSql); 
	SYSTEM cSQL;
	
		
	LET cSQL = '' ;
    LET cSQL = 'chmod 777 '|| TRIM(pRutaArch)|| TRIM(cNomArchEjecSql);
    SYSTEM cSQL;
 	
	LET cSQL = 'dbaccess bdicred ' || TRIM(pRutaArch) || TRIM(cNomArchEjecSql);
	SYSTEM cSQL;
    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(pRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;
	
	
	CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '03') Returning cCod_RetIB;
	RETURN cCodRet,cMensajeRet;


END
END PROCEDURE;