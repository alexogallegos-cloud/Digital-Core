CREATE PROCEDURE "informix".sp_carga_ctes_behavior(pEmpresa CHAR(3))

RETURNING 
          CHAR(06) AS resultado,    CHAR(80) AS mensaje;


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


--SET DEBUG FILE TO "/informix/jesus/soltar/sp_carga_ctes_behavior.out";
--TRACE ON;

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
LET cNomArchEjecSql = '';
LET cSQL            = '';


BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        LET cCodRet = iSqlErr;
        LET cMensajeRet = cErrorInfo;
        
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 10;



    IF ( NVL(pEmpresa,"") = "" ) THEN
        LET cCodRet= '102005'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        
        RETURN cCodRet, cMensajeRet;
	END IF;

    SELECT fecha_hoy INTO dFechaAumLinCrd FROM bdicred:sd_fechas WHERE empresa = pempresa;
   
    SELECT trim(valor) INTO cParamNomArch FROM bdicred:sd_param WHERE cod_param = '182';
    IF ( NVL(cParamNomArch, "") = "" ) THEN
        LET cCodRet= '104006';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        
        RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT trim(valor) INTO cRutaArch  FROM bdicred:sd_param WHERE cod_param = 103;
    IF ( NVL(cRutaArch, "") = "" ) THEN
        LET cCodRet = '104005';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        
        RETURN cCodRet, cMensajeRet;
    END IF;
	
    LET cNomArchivo = trim(cParamNomArch) || lpad(day(dFechaAumLinCrd),2,'0')|| lpad(month(dFechaAumLinCrd),2,'0') || lpad(year(dFechaAumLinCrd),4,'0') || '.txt';
    LET cNomArchEjecSql = 'Carga_behavior.sql';
    TRUNCATE TABLE bdicred:sd_ctes_behavior;
	UPDATE STATISTICS MEDIUM FOR TABLE  bdicred:sd_ctes_behavior;
    -- Realiza carga de archivo.
    LET cSQL = '';
    LET cSQL = ' echo " CREATE TEMP TABLE cred_behavior (num_credito CHAR(20),segmento CHAR(20),nivel_riesgo CHAR(10), score CHAR(4)) with no log; '
            || ' LOAD FROM ' || TRIM(cRutaArch) || TRIM(cNomArchivo) 
            || ' INSERT INTO cred_behavior; '
            || ' INSERT INTO bdicred:sd_ctes_behavior ( fecha_insert, num_credito,segmento,nivel_riesgo,  score ) '
            || ' SELECT ''' || dFechaAumLinCrd || ''', num_credito,segmento,nivel_riesgo, score FROM cred_behavior;  ">' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql); 
    SYSTEM cSQL;

    LET cSQL = 'dbaccess bdicred ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    UPDATE STATISTICS MEDIUM FOR TABLE  bdicred:sd_ctes_behavior;

    RETURN cCodRet,cMensajeRet;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para carga de archivo de creditos candidatos para validarse bajo perfil de segundo producto', 
'AUTOR: JESUS AGUILAR  ',
'FECHA: octubre  2016',
'VERSION: 20151012.1433',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_calculo_tiir_pp(
montoDisposicion DECIMAL(18,2),
pago_mensual DECIMAL(18,2),
numeroPeriodos INTEGER,
numeroPagosPeriodos INTEGER,
comision  DECIMAL(18,2)
)

RETURNING CHAR(6)  AS codigo_retorno,
          VARCHAR(80,1) AS mensaje_retorno,
		   DECIMAL(18,2) AS cat;

---DECLARACIONES
DEFINE cCodRet          CHAR(6);
DEFINE cMensajeRet      VARCHAR(80,1);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       VARCHAR(80,1);

DEFINE vCATMin          DECIMAL(18,2);
DEFINE vCAT            DECIMAL(21,10);
DEFINE vCATFin            DECIMAL(21,10);
DEFINE vCATMax          DECIMAL(21,10);
DEFINE vPrecision       DECIMAL(18,2);
DEFINE vPrecisionAux    DECIMAL(18,2);
DEFINE vPrecisionAux2    DECIMAL(18,2);
DEFINE vCiclado         INTEGER;
DEFINE iNumPago         INTEGER;

DEFINE vPagoSum         DECIMAL(18,2);
DEFINE vPlazo           DECIMAL(18,2);
DEFINE vCATx            DECIMAL(21,10);
DEFINE vCATy            DECIMAL(32,10);
DEFINE vCATz            DECIMAL(21,10);
DEFINE vCatFinal            DECIMAL(21,1);
DEFINE vPagoCosto       DECIMAL(18,2);
DEFINE pago_mensualAux       DECIMAL(18,2);
DEFINE iContador      	INTEGER;
DEFINE iNumPagos      	INTEGER;
DEFINE iBanPrecision      	INTEGER;


---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizó el cálculo correctamente";

LET vCATMin = 0;
LET vCAT = 10;
LET vCATFin = 1;
LET vCATMax =5000;
LET vPrecision = 1;
LET vPrecisionAux = 1;
LET vPrecisionAux2 = 1;
LET vCiclado = 1;
LET iNumPago = 0;

LET vPagoSum = 0;
LET vPlazo = 0;
LET vCATx = 0;
LET vCATy = 0;
LET vCATz = 0;
LET vPagoCosto = 0;
LET pago_mensualAux = 0;
LET iContador = 1;
LET iNumPagos = 1;
LET vCatFinal =0;
LET iBanPrecision =0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
	 LET cMensajeRet = cErrorInfo;
     RETURN NVL(cCodRet,''),NVL(cMensajeRet,''),NVL(vCAT,0);
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/jesus/sp_calculo_tiir_pp.out';
--TRACE ON;

LET pago_mensualAux = pago_mensual;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

WHILE (ABS(vPrecision) * 1000) > 1
	LET vPagoSum = 0;
	--LET vPlazo = 1;

	--LET pago_mensualAux = pago_mensual *12 ;
	WHILE iContador <=   numeroPeriodos

		IF iContador  = 0 THEN
			LET pago_mensualAux = (montoDisposicion * -1) + comision;
		ELSE
			LET pago_mensualAux = pago_mensual;
		END IF;

		LET vCATx = 1 + (vCAT/100);
		LET vCATy = iNumPagos ;
		LET vCATz = pow(vCATx, vCATy);

		LET vPagoCosto = pago_mensualAux / vCATz;

		LET vPagoSum = vPagoSum + vPagoCosto;
		LET iContador = iContador +1;
		LET iNumPagos = iNumPagos +1 ;
	END WHILE


		LET vPrecision = (montoDisposicion -comision)  - vPagoSum  ;
		 IF vPrecision < 0 THEN
			LET vCATMin = vCAT;
			LET vCAT = (vCATMax + vCAT) / 2;
		 ELIF vPrecision > 0 THEN
			LET vCATMax = vCAT;
			LET vCAT = (vCATMin + vCAT) / 2;
		 END IF;

     IF  vCiclado > 100 THEN
		LET vPrecisionAux2 = vPrecision;
		LET vPrecision = 0;
		LET iBanPrecision =1;
	 ELSE
		LET vPrecisionAux = vPrecision;

	 END IF;


LET iContador =1;
LET iNumPagos = 1 ;
LET vCiclado = vCiclado + 1;

END WHILE


IF  (vPrecisionAux2 <> vPrecisionAux) AND iBanPrecision =1 THEN
	LET vCAT =0;
END IF

LET vCATFin = vCAT;

LET vCatFinal = ( pow(1+ (vCAT/100),numeroPagosPeriodos) - 1 ) * 100;


RETURN NVL(cCodRet,''),NVL(cMensajeRet,''),NVL(vCatFinal,0);

END
END PROCEDURE;