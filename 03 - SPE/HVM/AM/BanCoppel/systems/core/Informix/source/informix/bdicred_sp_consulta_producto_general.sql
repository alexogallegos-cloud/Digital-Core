CREATE PROCEDURE "informix".sp_consulta_producto_general(pEmpresa CHAR(3))
RETURNING CHAR(6)         AS codigo_retorno,
          VARCHAR(100,1)  AS mensaje_retorno,
          CHAR(4)         AS numero_producto,
		  VARCHAR(100,1)  AS nombre_producto;
		  
DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   VARCHAR(100,1);
DEFINE cEmpresa      CHAR(3);
DEFINE cNumProducto  CHAR(4);
DEFINE cNomProducto  VARCHAR(100,1);

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '000000';
LET cMensajeRet   = 'Se realizó la consulta correctamente.';

LET cEmpresa      = '';
LET cNumProducto  = '';
LET cNomProducto  = '';

BEGIN 

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet, NVL(cNumProducto,''), NVL(cNomProducto,'');
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_consulta_datos_general';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
INTO cEmpresa     
FROM bdinteg:si_empresas 
WHERE empresa= pEmpresa;

IF TRIM(NVL(cEmpresa,'')) = '' THEN
  LET cCodRet = '000001';
  LET cMensajeRet = 'El parámetro no es valido';
  RETURN cCodRet, cMensajeRet, NVL(cNumProducto,''), NVL(cNomProducto,'');
END IF;

FOREACH
	SELECT num_producto, nombre_prod
	  INTO cNumProducto, cNomProducto
	  FROM "informix".sd_definicion
	 WHERE empresa = cEmpresa
	   AND flag_arbol = 1
	RETURN cCodRet, cMensajeRet, NVL(cNumProducto,''), NVL(cNomProducto,'') WITH RESUME;
END FOREACH;

IF DBINFO("sqlca.sqlerrd2") = 0 THEN
   LET cCodRet= '000002';
   LET cMensajeRet= 'No hay datos con la información indicada';
   RETURN cCodRet, cMensajeRet, NVL(cNumProducto,''), NVL(cNomProducto,'');
END IF;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener los productos ',
'para el aplicativo arbol de solicitudes',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 08/10/2015',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_consultaporanalistamc_pba(pFechaInicial CHAR(10), pFechaFinal CHAR(10), pProducto CHAR(4))
RETURNING
	CHAR(6)  AS cCodRet,
	CHAR(8)  AS cEjecutivo,
	CHAR(80) AS cNombre,
	INTEGER  AS iAnalizadas,
	DECIMAL  AS dPorcentajeAnalizadas,
	INTEGER	 AS iRevaluadas,
	DECIMAL  AS dPorcentajeRevaluadas,
	INTEGER	 AS iNoRevaluadas,
	DECIMAL  AS dPorcentajeNoRevaluadas,
	INTEGER  AS iSigueProceso,
	DECIMAL  AS dPorcentajeSigueProc,
	INTEGER  AS iRechazadas,
	DECIMAL  AS dPorcentajeRechazadas,
	INTEGER  AS iCanceladas,
	DECIMAL  AS dPorcentajeCanceladas,	
    INTEGER  AS iMIXTA,
	DECIMAL  AS dPorcentajeMIXTA,
	INTEGER  AS iUNICA,
	DECIMAL  AS dPorcentajeUNICA,	
	CHAR(80) AS cNombreProducto;
-- DECLARACIONES
DEFINE cCodRet            	CHAR(6);
DEFINE cCodRet2            	CHAR(6);
DEFINE iSqlErr     			INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);

DEFINE iSigueProceso			INTEGER;
DEFINE iCanceladas				INTEGER;
DEFINE iRechazadas				INTEGER;
DEFINE cEjecutivo				CHAR(8);
DEFINE icont					INTEGER;
DEFINE cNombre		        	CHAR(80);
DEFINE iTotal_Analizadas		INTEGER;
DEFINE iTotal_SigueProceso		INTEGER;
DEFINE iTotal_Canceladas		INTEGER;
DEFINE iTotal_Rechazadas		INTEGER;
DEFINE iTotal_Todas				INTEGER;
DEFINE iRevaluadas				INTEGER;
DEFINE iNoRevaluadas			INTEGER;
DEFINE dPorcentajeRevaluadas	DECIMAL(18,2);
DEFINE dPorcentajeNoRevaluadas  DECIMAL(18,2);
DEFINE dPorcentajeAnalizadas	DECIMAL(18,2);
DEFINE dPorcentajeSigueProc	    DECIMAL(18,2);
DEFINE dPorcentajeRechazadas 	DECIMAL(18,2);
DEFINE dPorcentajeCanceladas  	DECIMAL(18,2);

DEFINE dTotal_PorcentajeRev		  	DECIMAL(18,2);
DEFINE dTotal_PorcentajeNoRev	  	DECIMAL(18,2);
DEFINE dTotal_PorcentajeAnalizadas	DECIMAL(18,2);
DEFINE dTotal_PorcentajeSigueProc	DECIMAL(18,2);
DEFINE dTotal_PorcentajeRechaz 		DECIMAL(18,2);
DEFINE dTotal_PorcentajeCanc  		DECIMAL(18,2);
DEFINE iAnalizadas					INTEGER;
DEFINE iTotal_Revaluadas			INTEGER;
DEFINE iTotal_NoRevaluadas			INTEGER;
DEFINE cNombreProducto				CHAR(80);

DEFINE iUNICA						INTEGER;
DEFINE iTotalUNICA					INTEGER;
DEFINE iTotalMIXTA					INTEGER;
DEFINE iMIXTA						INTEGER;

DEFINE dPorcentajeUnica				DECIMAL(18,2);
DEFINE dTotal_PorcentajeUnica		DECIMAL(18,2);
DEFINE dTotal_PorcentajeMixta 		DECIMAL(18,2);
DEFINE dPorcentajeMixta  			DECIMAL(18,2);

-- INICIALIZACIONES
LET cCodRet 				= '00000';
LET cCodRet2 				= '000000';
LET iSqlErr 				= 0;
LET iIsamErr 				= 0;
LET cErrorInfo 				= '';

LET iSigueProceso			= 0;
LET iCanceladas				= 0;
LET iRechazadas				= 0;
LET cEjecutivo				= "";
LET icont					= 0;
LET cNombre					= "";
LET iTotal_Analizadas		= 0;
LET iRevaluadas				= 0;
LET iNoRevaluadas			= 0;
LET iTotal_SigueProceso		= 0;
LET iTotal_Canceladas		= 0;
LET iTotal_Rechazadas		= 0;
LET dPorcentajeRevaluadas	= 0.0;
LET dPorcentajeNoRevaluadas = 0.0;
LET dPorcentajeAnalizadas	= 0.0;
LET dPorcentajeSigueProc	= 0.0;
LET dPorcentajeRechazadas 	= 0.0;
LET dPorcentajeCanceladas  	= 0.0;

LET dTotal_PorcentajeRev		= 0.0;
LET dTotal_PorcentajeNoRev	  	= 0.0;
LET dTotal_PorcentajeAnalizadas	= 0.0;
LET dTotal_PorcentajeSigueProc	= 0.0;
LET dTotal_PorcentajeRechaz 	= 0.0;
LET dTotal_PorcentajeCanc  		= 0.0;
LET iAnalizadas					= 0;
LET iTotal_Revaluadas			=0;
LET iTotal_NoRevaluadas			=0;
LET cNombreProducto				= "";

LET iUNICA		= 0;
LET iTotalUNICA	  	= 0;
LET dPorcentajeUnica	= 0.0;
LET dTotal_PorcentajeUnica	= 0.0;

LET dTotal_PorcentajeMixta		= 0.0;
LET dPorcentajeMixta	  	= 0.0;
LET iTotalMIXTA	= 0;
LET iMIXTA	= 0;

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
		
		LET cCodRet = iSqlErr; -- FALLÓ LA CONSULTA
			RETURN cCodRet,TRIM(NVL(cEjecutivo,"")),TRIM(NVL(cNombre,"")),NVL(iAnalizadas,0),NVL(dPorcentajeAnalizadas,0.0),
					NVL(iRevaluadas,0),NVL(dPorcentajeRevaluadas,0.0),NVL(iNoRevaluadas,0),NVL(dPorcentajeNoRevaluadas,0.0),
					NVL(iSigueProceso,0),NVL(dPorcentajeSigueProc,0.0),NVL(iRechazadas,0),NVL(dPorcentajeRechazadas,0.0),
					NVL(iCanceladas,0),NVL(dPorcentajeCanceladas,0.0),0,0.0,0,0.0,TRIM(NVL(cNombreProducto,""));
		END IF;
	END EXCEPTION; 
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	-- SET DEBUG FILE TO "/home/sysifx/sp_consultaporanalistamc.sql";
	-- TRACE ON;
	
		-- OBTENEMOS EL NOMBRE DEL PRODUCTO QUE ESTAMOS CONSULTANDO.
		IF pProducto <> "" THEN
			SELECT nombre_prod INTO cNombreProducto FROM bdicred:"informix".sd_definicion WHERE num_producto  = pProducto ;
		END IF;
		
		SELECT COUNT(ejecutivo_autoriza),
			   SUM(CASE WHEN status_fin IN('EE','AT','ST') AND ejecutivo_autoriza <> ""  THEN 1 ELSE 0 END) AS SigueProceso,
			   SUM(CASE WHEN status_fin = "RT" THEN 1 ELSE 0 END) AS Rechazadas,
			   SUM(CASE WHEN status_fin IN("CN","CM") THEN 1 ELSE 0 END) AS Canceladas,
			   SUM(NVL( CASE WHEN tipo_movimiento = "M" THEN 1 END,0)),
			  SUM(NVL( CASE WHEN tipo_movimiento = "U" THEN 1 END,0)),
			  SUM(NVL( CASE WHEN revalua = "S" THEN 1 END,0)),
			  (COUNT(ejecutivo_autoriza) -SUM(NVL( CASE WHEN revalua = "S" THEN 1 END,0)))
			INTO iTotal_Analizadas,iTotal_SigueProceso,iTotal_Rechazadas,iTotal_Canceladas,iTotalMIXTA,iTotalUNICA,iTotal_Revaluadas,iTotal_NoRevaluadas
		FROM bdisolic:"informix".ss_solicitudes_mc 
		WHERE num_producto = DECODE(pProducto, "", num_producto, pProducto)
		AND fecha_insert >= pFechaInicial::DATE
		AND fecha_insert <= pFechaFinal::DATE
		AND ejecutivo_autoriza <> "";
		
		-- SE SACA EL TOTAL DE PORCENTAJE DE CADA TIPO DE SOLICITUD
		
			LET dTotal_PorcentajeAnalizadas =   100 ;
			LET dTotal_PorcentajeSigueProc =  CASE WHEN iTotal_Analizadas <= 0 THEN 0 ELSE (iTotal_SigueProceso / iTotal_Analizadas) * 100 END;
			LET dTotal_PorcentajeRechaz =  CASE WHEN iTotal_Analizadas <= 0 THEN 0 ELSE (iTotal_Rechazadas / iTotal_Analizadas) * 100 END;
			LET dTotal_PorcentajeCanc =  CASE WHEN iTotal_Analizadas <= 0 THEN 0 ELSE (iTotal_Canceladas / iTotal_Analizadas) * 100 END;
			LET dTotal_PorcentajeMixta =  CASE WHEN iTotal_Analizadas <= 0 THEN 0 ELSE (iTotalMIXTA / iTotal_Analizadas) * 100 END;
			LET dTotal_PorcentajeUnica =  CASE WHEN iTotal_Analizadas <= 0 THEN 0 ELSE (iTotalUNICA / iTotal_Analizadas) * 100 END;
			-- SE RETORNAN LOS VALORES OBTENIDOS DE TODAS LAS SOLICITUDES DE CADA ANALISTA
		
		
		FOREACH WITH HOLD
			SELECT ejecutivo_autoriza, 				 -- SOLICITUDES ANALIZADAS POR CADA ANALISTA
				SUM(CASE WHEN status_fin <> "" AND ejecutivo_autoriza <> "" THEN 1 ELSE 0 END) AS Analizadas,			
				SUM(CASE WHEN status_fin IN('EE','AT','ST') AND ejecutivo_autoriza <> ""  THEN 1 ELSE 0 END) AS SigueProceso,
				SUM(CASE WHEN status_fin = "RT" THEN 1 ELSE 0 END) AS Rechazadas,
				SUM(CASE WHEN status_fin IN("CN","CM") THEN 1 ELSE 0 END) AS Canceladas,
				  SUM(NVL( CASE WHEN tipo_movimiento = "M" THEN 1 END,0)),
			  SUM(NVL( CASE WHEN tipo_movimiento = "U" THEN 1 END,0)),
			  	  SUM(NVL( CASE WHEN revalua = "S" THEN 1 END,0))
			  
			INTO cEjecutivo, iAnalizadas,
				iSigueProceso,iRechazadas,iCanceladas,iMIXTA,iUNICA,
				iRevaluadas			
			FROM bdisolic:"informix".ss_solicitudes_mc 
			WHERE num_producto = DECODE(pProducto, "", num_producto, pProducto)
			AND fecha_insert >= pFechaInicial::DATE
			AND fecha_insert <= pFechaFinal::DATE
			AND ejecutivo_autoriza <> ""  
			GROUP BY ejecutivo_autoriza
			 
			SELECT nombre	-- SE TOMA EL NOMBRE DE CADA ANALISTA POR SU NUMERO DE EMPLEADO
			INTO cNombre
			FROM bdinteg:"informix".si_ejecut 		
			WHERE ejecutivo = cEjecutivo;
			
		LET iNoRevaluadas = iAnalizadas - iRevaluadas;
			-- SE SACA EL PORCENTAJE DE CADA TIPO DE SOLICITUD POR CADA ANALISTA
			
			LET dPorcentajeAnalizadas = CASE WHEN iTotal_Analizadas <= 0 THEN 0 ELSE (iAnalizadas / iTotal_Analizadas) * 100 END;
			LET dPorcentajeSigueProc = CASE WHEN iAnalizadas <= 0 THEN 0 ELSE (iSigueProceso / iAnalizadas) * 100 END;
			LET dPorcentajeRechazadas = CASE WHEN iAnalizadas <= 0 THEN 0 ELSE (iRechazadas / iAnalizadas)  * 100 END;
			LET dPorcentajeCanceladas = CASE WHEN iAnalizadas <= 0 THEN 0 ELSE (iCanceladas / iAnalizadas) * 100 END;
			LET dPorcentajeMixta = CASE WHEN iAnalizadas <= 0 THEN 0 ELSE (iMIXTA / iAnalizadas) * 100 END;			
			LET dPorcentajeUnica = CASE WHEN iAnalizadas <= 0 THEN 0 ELSE (iUNICA / iAnalizadas) * 100 END;			
			
			
			LET dPorcentajeRevaluadas = CASE WHEN iAnalizadas <= 0 THEN 0 ELSE (iRevaluadas / iAnalizadas) * 100 END;			
			LET dPorcentajeNoRevaluadas = CASE WHEN iAnalizadas <= 0 THEN 0 ELSE (iNoRevaluadas / iAnalizadas) * 100 END;		
		
			
			
			RETURN cCodRet,TRIM(NVL(cEjecutivo,"")),TRIM(NVL(cNombre,"")),NVL(iAnalizadas,0),NVL(dPorcentajeAnalizadas,0.0),
					NVL(iRevaluadas,0),NVL(dPorcentajeRevaluadas,0.0),NVL(iNoRevaluadas,0),NVL(dPorcentajeNoRevaluadas,0.0),
					NVL(iSigueProceso,0),NVL(dPorcentajeSigueProc,0.0),NVL(iRechazadas,0),NVL(dPorcentajeRechazadas,0.0),
					NVL(iCanceladas,0),NVL(dPorcentajeCanceladas,0.0),NVL(iMIXTA,0),NVL(dPorcentajeMixta,0.0),NVL(iUNICA,0),NVL(dPorcentajeUnica,0.0),TRIM(NVL(cNombreProducto,""))WITH RESUME;
		END FOREACH	
		
		-- SE RETORNAN LOS VALORES OBTENIDOS DE TODAS LAS SOLICITUDES DE CADA ANALISTA MIENTRAS EXISTAN REGISTROS EN LA TABLA CON DICHOS CRITERIOS
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			RETURN cCodRet,TRIM(NVL(cEjecutivo,"")),TRIM(NVL(cNombre,"")),NVL(iAnalizadas,0),NVL(dPorcentajeAnalizadas,0.0),
					NVL(iRevaluadas,0),NVL(dPorcentajeRevaluadas,0.0),NVL(iNoRevaluadas,0),NVL(dPorcentajeNoRevaluadas,0.0),
					NVL(iSigueProceso,0),NVL(dPorcentajeSigueProc,0.0),NVL(iRechazadas,0),NVL(dPorcentajeRechazadas,0.0),
					NVL(iCanceladas,0),NVL(dPorcentajeCanceladas,0.0),NVL(iMIXTA,0),NVL(dPorcentajeMixta,0.0),NVL(iUNICA,0),NVL(dPorcentajeUnica,0.0),TRIM(NVL(cNombreProducto,""));
		ELSE 
		
		-- SE RETORNAN LOS VALORES DE LOS TOTALES DE  TODAS LAS SOLICITUDES 
			LET dTotal_PorcentajeRev = CASE WHEN iTotal_Analizadas <= 0 THEN 0 ELSE (iTotal_Revaluadas / iTotal_Analizadas) * 100 END;
			LET dTotal_PorcentajeNoRev = CASE WHEN iTotal_Analizadas <= 0 THEN 0 ELSE (iTotal_NoRevaluadas / iTotal_Analizadas) * 100 END;
			
			RETURN cCodRet, "TOTAL", "" ,NVL(iTotal_Analizadas,0),NVL(dTotal_PorcentajeAnalizadas,0.0),
				NVL(iTotal_Revaluadas,0),NVL(dTotal_PorcentajeRev,0.0),NVL(iTotal_NoRevaluadas,0),NVL(dTotal_PorcentajeNoRev,0.0),
				NVL(iTotal_SigueProceso,0),NVL(dTotal_PorcentajeSigueProc,0.0),NVL(iTotal_Rechazadas,0),NVL(dTotal_PorcentajeRechaz,0.0),
				NVL(iTotal_Canceladas,0),NVL(dTotal_PorcentajeCanc,0.0),NVL(iTotalMIXTA,0),NVL(dTotal_PorcentajeMixta,0.0),NVL(iTotalUNICA,0),NVL(dTotal_PorcentajeUnica,0.0),TRIM(NVL(cNombreProducto,""));
		
		END IF
		
END;

END PROCEDURE
DOCUMENT
'AUTOR: Josué R. Zazueta Acosta',
'DESCRIPCIÓN: Hace un reporte de las solicitudes que fueron analizadas por analista',
'FECHA: 14/Diciembre/2012',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_cac_consultasolincrelincred_pba(pEmpresa     CHAR(3),
                                                      pStatus      CHAR(2),
													  pFechaIni    CHAR (10),
													  pFechaFin    CHAR (10),
													  pNomCte1     VARCHAR(26,1),        
													  pNomCte2     VARCHAR(26,1),
													  pApellPat    VARCHAR(26,1),
													  pApellMat    VARCHAR(26,1),    
													  pFechaNac    CHAR (10),
													  pOrigen      CHAR(1),
													  pNumCte      VARCHAR(20,1),
													  pNumCred     VARCHAR(20,1),
													  pNumTarjeta  VARCHAR(20,1),
													  pEjecutivo   CHAR(8),
													  pNumPag           INTEGER,
                                                      pDesplazar        INTEGER)
													  
													  
RETURNING CHAR(6)           AS cod_ret,
          VARCHAR(100,1)    AS mensaje_ret,
          VARCHAR(20,1)     AS num_cred,
          VARCHAR(20,1)     AS num_cte,
		  VARCHAR(107,1)    AS nombre_cte,
		  CHAR(2)           AS status,
		  CHAR(10)          AS origen,
		  CHAR(4)           AS sucursal,
		  DATE              AS fecha,
		  DECIMAL(18,2)     AS lincred_actual,
		  DECIMAL(18,2)     AS lincred_sugerida,
		  INTEGER           AS iRevisionCac,
		  VARCHAR(107,1)    AS usuario_trabajando,
		  SMALLINT			AS Continua,         -- Indica si existen más registros por consultar
		  INTEGER           AS pagina,
		  INTEGER as totalReg,
		  DATE as fechaSolicitud,
		  CHAR(3) as ClaveRT_CM;

DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        VARCHAR(255,1);
DEFINE cCodRet           CHAR(6);
DEFINE cMensajeRet       VARCHAR(100,1);													  
DEFINE cNumCred          VARCHAR(20,1);
DEFINE cNumCte           VARCHAR(20,1);
DEFINE cStatus           CHAR(2);
DEFINE cOrigen           CHAR(10);
DEFINE cSucursal         CHAR(4);
DEFINE dtFechaInsert     DATE;
DEFINE dtFechaStatus 	 DATE;
DEFINE dtFechaIni        DATE;
DEFINE dtFechaFin        DATE;
DEFINE dtFechaNac        DATE;
DEFINE dLincredActual    DECIMAL(18,2);
DEFINE dLincredSugerida  DECIMAL(18,2);
DEFINE cNomCte           VARCHAR(107,1);
DEFINE iNumReg           INTEGER;
DEFINE iNumReg2           INTEGER;
DEFINE iRevisionCac      INTEGER;
DEFINE cNombreUsuario    VARCHAR(107,1);
DEFINE dMontoIncremento  DECIMAL(18,2);
DEFINE cRevisionCacAzul  CHAR(2);
DEFINE iContador         INTEGER;
DEFINE iContadorSol      INTEGER;
DEFINE iNumPag           INTEGER;
DEFINE sSiguiente        SMALLINT;
DEFINE iTotalReg        INTEGER;
DEFINE cCausa 	    CHAR(3);
DEFINE iNivel           INTEGER;
DEFINE pChkRevision	    CHAR(3);

LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";
LET cCodRet              = "000000";
LET cMensajeRet          = "CONSULTA EXITOSA";
LET cNumCred             = "";
LET cNumCte              = "";
LET cStatus              = "";
LET cOrigen              = "";
LET cSucursal            = "";
LET dtFechaInsert        = DATE(1);
LET dtFechaStatus		 = DATE(1);
LET dtFechaIni           = DATE(1);
LET dtFechaFin           = DATE(1);
LET dtFechaNac           = DATE(1);
LET dLincredActual       = 0;
LET dLincredSugerida     = 0;
LET cNomCte              = "";
LET iNumReg              = 0;
LET iNumReg2              = 0;
LET iRevisionCac         = 0;
LET cNombreUsuario       = "";
LET iContador            = 0;
LET iContadorSol         = 0;
LET iNumPag              = 1;
LET sSiguiente           = 0;
LET cRevisionCacAzul     = "";
LET dMontoIncremento     = 0;
LET iTotalReg            = 0;
LET cCausa              = '';
LET iNivel              = 0;
LET pChkRevision        = '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet     = iSqlErr;
	 LET cMensajeRet = cErrorInfo;
     RETURN cCodRet,cMensajeRet,cNumCred, cNumCte,cNomCte, cStatus, cOrigen, cSucursal,
		    dtFechaStatus, dLincredActual, dLincredSugerida,iRevisionCac,cNombreUsuario,0,iNumPag,iTotalReg, dtFechaInsert, cCausa ;	    		 
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/informix/jesus/sp_cac_consultasolincrelincred.out';
--TRACE ON;

IF pEmpresa IS NULL THEN 
   LET cCodRet     = "000001";
   LET cMensajeRet = "LA EMPRESA INDICADA NO ES VALIDA";
   RETURN cCodRet,cMensajeRet,cNumCred, cNumCte,cNomCte, cStatus, cOrigen, cSucursal,
		    dtFechaStatus, dLincredActual, dLincredSugerida,iRevisionCac,cNombreUsuario,0,iNumPag,iTotalReg, dtFechaInsert, cCausa ;
END IF;

SELECT valor 
  INTO iNumReg
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '044'
   AND empresa = pEmpresa ;


IF NVL(iNumReg,"") = "" THEN
    LET cCodRet = "000001";
    LET cMensajeRet = "NO SE ENCUENTRA EL PARÁMETRO PARA LA PAGINACIÓN DE CONSULTA.";
          RETURN cCodRet,cMensajeRet,cNumCred, cNumCte,cNomCte, cStatus, cOrigen, cSucursal,
		    dtFechaStatus, dLincredActual, dLincredSugerida,iRevisionCac,cNombreUsuario,0,iNumPag,iTotalReg,dtFechaInsert, cCausa;
END IF;

IF pStatus IS NULL THEN 
 LET pStatus = "";
END IF;

IF pFechaIni IS NULL OR pFechaIni = "" THEN 
  LET dtFechaIni = DATE(1);
ELSE
	LET dtFechaIni = pFechaIni;
END IF;

IF pFechaFin IS NULL OR pFechaFin = "" THEN 
  LET dtFechaFin = CURRENT;
ELSE
	LET dtFechaFin = pFechaFin;
END IF;

IF pNomCte1 IS NULL THEN
  LET pNomCte1 = "";
END IF;

IF pNomCte2 IS NULL THEN
  LET pNomCte2 = "";
END IF;

IF pApellPat IS NULL THEN
  LET pApellPat = "";
END IF;

IF pApellMat IS NULL THEN
  LET pApellMat = "";
END IF;

IF pFechaNac IS NULL OR pFechaNac = "" THEN
  LET dtFechaNac = DATE(1);  
ELSE
	LET dtFechaNac = pFechaNac;  
END IF;

IF pOrigen IS NULL THEN
  LET pOrigen = "";
END IF;

IF pNumCte IS NULL THEN
  LET pNumCte = "";
END IF;

IF pNumCred IS NULL THEN
  LET pNumCred = "";
END IF;

IF pNumTarjeta IS NULL THEN
  LET pNumTarjeta = "";
END IF;

SELECT LIMIT 1 nivel INTO iNivel
 FROM "informix".sd_perfiles_cac_aumlincred
 WHERE ejecutivo = pEjecutivo;

LET iNumReg2 = iNumReg * 2; 
IF NVL(pDesplazar,0) IN (0,2,3) THEN -- Consulta inicial (0), pagina siguiente(2), consulta general sin paginación (3).

	IF NVL(pDesplazar,0) = 0 THEN
		DELETE FROM bdicred:"informix".sd_paginacion_cac_aumlincred WHERE ejecutivo = pEjecutivo;	

		FOREACH WITH HOLD
			SELECT num_cred INTO cNumCred FROM bdicred:"informix".tme_bitacora_aumlincred_orden WHERE ejecutivo = pEjecutivo
				DELETE FROM bdicred:"informix".tme_bitacora_aumlincred_orden WHERE ejecutivo = pEjecutivo AND num_cred = cNumCred ; 			
		END FOREACH;
		
		
	ELIF NVL(pDesplazar,0) = 2 THEN 	-- Avanzar hacia la siguiente página
		SELECT MAX(pagina) + 1
		  INTO iNumPag
		  FROM bdicred:"informix".sd_paginacion_cac_aumlincred
		 WHERE ejecutivo = pEjecutivo; 		 
	END IF;
  
		IF NVL(pNumTarjeta,'') <> '' THEN
			SELECT num_credito
				INTO pNumCred
			FROM bdicred:"informix".sd_tarjeta 	
			WHERE empresa = '001'
			AND status_tar = "A"
			AND tipo_tarjeta = "T"			
			AND num_tarjeta   = pNumTarjeta;
			
			IF NVL(pNumCred,'') ='' THEN
				LET cCodRet     = "000003";
				LET cMensajeRet = "NO EXISTE INFORMACION,VERIFIQUE";
				RETURN cCodRet,cMensajeRet,NVL(cNumCred,""), NVL(cNumCte,""),NVL(cNomCte,""), NVL(cStatus,""), NVL(cOrigen,""), NVL(cSucursal,""),
				  NVL(dtFechaStatus,DATE(1)), NVL(dLincredActual,0), NVL(dLincredSugerida,0), NVL(iRevisionCac,0),cNombreUsuario,1,NVL(iNumPag,0),NVL(iTotalReg,0), NVL(dtFechaInsert, 0), NVL(cCausa, '') ;
			END IF;
		END IF;
		
		--Obtener el número total de registros
		IF NVL(pDesplazar,0) = 0 THEN
			FOREACH WITH HOLD
				SELECT  LIMIT  iNumReg2 a.num_solicitud, 
					   a.numcte,
					   a.status,
					   a.origen, --DECODE(a.origen,"C","CENTRAL","S","SUCURSAL"),
					   a.sucursal,
					   a.fecha_insert,
					   a.fecha_status, 
					   a.lincred_actual,
					   a.lincred_sugerida,
					   a.causa_status					   
				  INTO cNumCred,
					   cNumCte,
					   cStatus,
					   cOrigen,
					   cSucursal,
					   dtFechaInsert,
					   dtFechaStatus, 
					   dLincredActual,
					   dLincredSugerida,
					   cCausa					   
				  FROM "informix".sd_bitacora_aumlincred a			         			   		   
				 WHERE  a.empresa       = pEmpresa
				   AND a.numcte        = a.numcte
				   AND a.num_solicitud = (CASE WHEN pNumCred  = "" THEN a.num_solicitud ELSE pNumCred END)
				   AND a.numcte        = (CASE WHEN pNumCte   = "" THEN a.numcte ELSE pNumCte END)
				   AND a.status        = (CASE WHEN pStatus   = "" THEN a.status ELSE pStatus END)
				   AND a.fecha_insert  BETWEEN dtFechaIni AND dtFechaFin
				   AND a.origen        = (CASE WHEN pOrigen   = "" THEN a.origen ELSE pOrigen END)			  
				  -- AND a.num_solicitud NOT IN (SELECT num_cred  FROM bdicred:"informix".sd_paginacion_cac_aumlincred WHERE ejecutivo = pEjecutivo AND NVL(pDesplazar,0) <> 3)
				   ORDER BY fecha_insert
				   				 
				   IF cStatus = "AC" THEN		   
					   /*SELECT revision_cac
						INTO iRevisionCac
					   FROM bdicred:"informix".sd_autorizacion_aumlincred
					   WHERE num_solicitud =cNumCred
					   AND status = 'AC'
					   AND fecha_insert = dtFechaStatus; */
					   SELECT limit 1 revision_cac
						INTO iRevisionCac
						FROM bdicred:"informix".sd_autorizacion_aumlincred
						WHERE  num_solicitud = cNumCred
						AND status = 'AC'
						 AND fecha_status = (SELECT MAX(fecha_status)	
											FROM bdicred:"informix".sd_autorizacion_aumlincred
											WHERE  num_solicitud = cNumCred
											AND status = 'AC' );
				   ELSE
						LET iRevisionCac=0;
				   END IF;
				
				IF iRevisionCac = 3 THEN  
				    LET dMontoIncremento =dLincredSugerida-dLincredActual;
					   
					SELECT rango_autorizacion
					INTO cRevisionCacAzul
					FROM bdicred:"informix".sd_autorizaciones_cac_aumlincred
					WHERE dMontoIncremento BETWEEN monto_minimo AND monto_maximo;
									
					IF cRevisionCacAzul = "03" THEN
						LET iRevisionCac = 5;
					END IF;				
				
				END IF;
				
				LET iContadorSol = iContadorSol + 1;
					
								   
			INSERT INTO 'informix'.tme_bitacora_aumlincred_orden(
					   orden,	secuencia,ejecutivo,num_cred,numcte,status_sol,origen,sucursal,fecha_sol,
					   lincred_actual,lincred_sugerida,revision_cac,pagina, fecha_insert, causa_status)
					VALUES( ( --case when pStatus <> "AC" then iContadorSol  --> Si es por "AC" hacer el ordenamiento pot orden de insertcion
						--else
							case when iRevisionCac = 4 then 5 
							else
								case when iRevisionCac = 5 then 4
								else 
									case when iRevisionCac = 3 then 3
									else 
										case when iRevisionCac = 2 then 2
										else
											case when iRevisionCac = 1 then 1
											else
												case when iRevisionCac = 0 then 0
												else
													case when iRevisionCac IS NULL then 0
													end
												end
											end
										end
									end
								end
							--end
						end),
						iContadorSol,pEjecutivo,cNumCred, cNumCte, cStatus, cOrigen, cSucursal,dtFechaStatus, 
						dLincredActual, dLincredSugerida, iRevisionCac, iNumPag, dtFechaInsert, cCausa); 
			
					
			END FOREACH;				
		END IF;
		
		LET iContadorSol         = 0;
		LET iContadorSol =(iNumPag - 1) * 100;
		--Determinar si es analista de crédito para que solo le aparescan solitudes en blanco
		--SELECT LIMIT 1 nivel INTO iNivel FROM "informix".sd_perfiles_cac_aumlincred WHERE ejecutivo = pEjecutivo;

		IF iNivel = 1 THEN
		 LET pChkRevision = '1'; --Trae nomas las revisiones en 0 (Solicitudes en blanco)
		 
		ELSE 
			IF iNivel in (2,3,4) THEN
				LET pChkRevision = '0';  --Trae todas la revisiones
			END IF;
		END IF;
		
		
		--Si se consulta por estatus distinto a ac ordenamiento por fecha_insert
		IF pStatus != 'AC' THEN
		
			UPDATE "informix".tme_bitacora_aumlincred_orden
			SET orden = 0 
			WHERE ejecutivo = pEjecutivo;
			--Que busque por todas las revisiones
			LET pChkRevision = '0';
		END IF;
		
		
		--Total de registros total deacuerdo a la revisión
		SELECT COUNT(a.num_cred) INTO iTotalReg FROM tme_bitacora_aumlincred_orden a 
		WHERE (NVL(a.revision_cac,0) <= (CASE WHEN (pChkRevision = '1') THEN 1 ELSE a.revision_cac END) OR (a.revision_cac IS NULL) )
		AND a.ejecutivo = pEjecutivo ; -- Trae todas las solictudes en blanco cuando el ejecutivo tenga nivel 1 (Analista) ;
		
		FOREACH WITH HOLD			   
			   
			SELECT a.num_cred, 
				   a.numcte,
				   a.status_sol,
				   DECODE(a.origen,"C","CENTRAL","S","SUCURSAL"),
				   a.sucursal,
				   a.fecha_insert,
				   a.fecha_sol, 
				   a.lincred_actual,
				   a.lincred_sugerida,
				   a.causa_status,a.revision_cac
			  INTO cNumCred,
				   cNumCte,
				   cStatus,
				   cOrigen,
				   cSucursal,
				   dtFechaInsert,
				   dtFechaStatus, 
				   dLincredActual,
				   dLincredSugerida,
				   cCausa,iRevisionCac
			  FROM "informix".tme_bitacora_aumlincred_orden a			         			   		   
			 WHERE  a.ejecutivo = pEjecutivo
			   AND (NVL(a.revision_cac,0) <= (CASE WHEN (pChkRevision = '1') THEN  1 ELSE a.revision_cac END) OR (a.revision_cac IS NULL) ) -- Trae todas las solictudes en blanco cuando el ejecutivo tenga nivel 1 (Analista) 
			   AND  a.numcte = a.numcte
			   ORDER BY orden DESC, fecha_insert			   
			  
					LET iContador = iContador + 1;		 
					LET iContadorSol = iContadorSol + 1;
					LET cNombreUsuario = "";
				IF (iContador > (iNumPag-1) * iNumReg) THEN
					   SELECT TRIM(NVL(apell_paterno," ")) || " " ||
						   TRIM(NVL(apell_materno," ")) || " " ||
						   TRIM(NVL(nombre1," ")) || " " ||
						   TRIM(NVL(nombre2," "))
						INTO cNomCte
					   FROM bdinteg:"informix".si_cliente
					   WHERE empresa ='001'
					   AND numcte =cNumCte; 
					   
					IF pStatus != 'AC' THEN   
						IF EXISTS (SELECT num_credito FROM bdicred:"informix".sd_sol_procesando_aumlincred WHERE num_credito = cNumCred) THEN	
							SELECT  b.nombre 
								INTO cNombreUsuario
							FROM bdicred:"informix".sd_sol_procesando_aumlincred a
							INNER JOIN bdinteg:"informix".si_ejecut b ON (b.ejecutivo = a.usuario)
							WHERE num_credito = pNumCred;			
					
							LET cNombreUsuario = "SOLICITUD ESTÁ SIENDO ATENDIDA POR "|| TRIM(cNombreUsuario);
						END IF;				  
					END IF;
								
				
					IF  pDesplazar <> 3 THEN				
						IF ((iContador ) <=  (iNumPag) * iNumReg) OR ((iNumPag - 1) =0 AND iContador<=iNumReg)  THEN
								INSERT INTO bdicred:"informix".sd_paginacion_cac_aumlincred 
									(secuencia,ejecutivo,num_cred,numcte,nombrecte,status_sol,origen,sucursal,fecha_sol,lincred_actual,lincred_sugerida,revision_cac,nombre_usuario, fecha_apertura, causa, pagina)
								VALUES (iContadorSol,pEjecutivo,cNumCred, cNumCte,cNomCte, cStatus, cOrigen, cSucursal,dtFechaStatus, dLincredActual, dLincredSugerida, iRevisionCac,cNombreUsuario, dtFechaInsert, cCausa, iNumPag);
						ELIF (iContador ) = (((iNumPag ) *iNumReg ) + 1) OR  ((iNumPag - 1) =0 AND iContador=iNumReg +1)   THEN
							LET sSiguiente = 1;
						ELSE
							EXIT FOREACH;		
						END IF;	       
					END IF;
				
					RETURN cCodRet,cMensajeRet,cNumCred, cNumCte,cNomCte, cStatus, cOrigen, cSucursal,
					dtFechaStatus, dLincredActual, dLincredSugerida, iRevisionCac,cNombreUsuario, sSiguiente,iNumPag,iTotalReg, dtFechaInsert, cCausa WITH RESUME;
		    END IF
		END FOREACH;
ELIF NVL(pDesplazar,0) = 1 THEN -- Pagina anterior

    DELETE FROM bdicred:"informix".sd_paginacion_cac_aumlincred
          WHERE ejecutivo = pEjecutivo
			AND pagina = pNumPag + 1;

    FOREACH
        SELECT num_cred,numcte,nombrecte,status_sol,	origen,sucursal,fecha_sol,lincred_actual,lincred_sugerida,revision_cac,nombre_usuario, fecha_apertura, causa, pagina
          INTO cNumCred, cNumCte,cNomCte, cStatus, cOrigen, cSucursal, dtFechaStatus, dLincredActual, dLincredSugerida, iRevisionCac,cNombreUsuario, dtFechaInsert,cCausa, iNumPag
          FROM bdicred:"informix".sd_paginacion_cac_aumlincred
         WHERE ejecutivo = pEjecutivo
           AND pagina = pNumPag 
		   ORDER BY secuencia
          
       RETURN cCodRet,cMensajeRet,NVL(cNumCred,""), NVL(cNumCte,""),NVL(cNomCte,""), NVL(cStatus,""), NVL(cOrigen,""), NVL(cSucursal,""),
				    NVL(dtFechaStatus,DATE(1)), NVL(dLincredActual,0), NVL(dLincredSugerida,0), NVL(iRevisionCac,0),cNombreUsuario,1,NVL(iNumPag,0),NVL(iTotalReg,0), NVL(dtFechaInsert, 0), NVL(cCausa, '') WITH RESUME;
    END FOREACH;
ELSE
		LET cCodRet     = "000002";
		LET cMensajeRet = "PARAMETRO INCORRECTO EN EL VALOR DE PAGINACION,VERIFIQUE";
		RETURN cCodRet,cMensajeRet,NVL(cNumCred,""), NVL(cNumCte,""),NVL(cNomCte,""), NVL(cStatus,""), NVL(cOrigen,""), NVL(cSucursal,""),
		  NVL(dtFechaStatus,DATE(1)), NVL(dLincredActual,0), NVL(dLincredSugerida,0), NVL(iRevisionCac,0),cNombreUsuario,1,NVL(iNumPag,0),NVL(iTotalReg,0), NVL(dtFechaInsert, 0), NVL(cCausa, '') WITH RESUME;
END IF;


END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para',
'la generación de la información para la',
'consulta de incrementos',
'AUTOR : Paul Ivan Quintero Varela,Jesús Manuel Aguilar Heredia',
'FECHA : 07/SEPT/2011',
'BD: BDICRED',
'VERSION:20110907.0838',
'----------------------------------------------------------------------------------',
'Autor: Josué Remberto Zazueta Acosta',
'Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían,Se implementan reglas', 'de informix',
'Fecha de modificación: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'Autor: Jesús Manuel Aguilar Heredia',
'Modificación: Se realiza optimizacion',
'Fecha de modificación: 23/Enero/2013',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'Autor: Juan Daniel Lazalde Centeno',
'Modificación: Se agrega el numero total de registros, se agrega código para traer los datos sin paginación, ordenamiento de la solicitudes por nivel del ejecutivo',
'Fecha de modificación: 28/Enero/2014',
'BD : bdicred',
'----------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_traspasocuentas_cred_pba(pClienteTitular CHAR(20), pClienteTraspasaCtas CHAR(20), pUsuario CHAR(8)) 
RETURNING CHAR(5), CHAR(80);
--DEFINICION DE VARIABLES
DEFINE vc_CodRet        CHAR(5);
DEFINE vi_SqlErr        INTEGER;
DEFINE vi_iSAMErr        INTEGER;
DEFINE vi_iSAMData        CHAR(80);
DEFINE vc_Mensaje       CHAR(80);
DEFINE vc_proceso       CHAR(50);
DEFINE vc_tabla         CHAR(30);
DEFINE vc_detalle_mov   CHAR(200);
DEFINE vc_detalle_mov2   CHAR(200);
DEFINE vc_Cuenta        CHAR(20);
DEFINE vc_Credito        CHAR(20);
DEFINE vi_secuencia     INTEGER;
DEFINE vc_num_tarjeta   CHAR(20);
DEFINE iExiste      SMALLINT;

--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET vi_iSAMErr=0;
LET vi_iSAMData="";
LET vc_Mensaje = "EL PROCESO SE EFECTUO CORRECTAMENTE";
LET vc_proceso = "FusionClientes";
LET vc_tabla = "";
LET vc_detalle_mov = "";
LET vc_detalle_mov2 = "";
LET vc_Cuenta = "";
LET vc_Credito = "";
LET vi_secuencia = 0;
LET vc_num_tarjeta = "";
LET iExiste=0;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    BEGIN WORK;

    BEGIN

    ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            LET vc_Mensaje = "ERROR NO CONTROLADO";
            ROLLBACK WORK;
            let vc_detalle_mov2=vi_SqlErr||'|'||vi_iSAMErr||'|'||vi_iSAMData; 
            INSERT INTO bdinteg:log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov2, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;

--SET DEBUG FILE TO "/home/sysifx/JesusBueno/1449/sp_traspasocuentas_cred.out";
--TRACE ON;

    --***INICIA EL TRASPASO DE CUENTAS DE CREDITO
   
   SET ISOLATION TO DIRTY READ;
    
	SELECT COUNT (num_credito) INTO iExiste FROM sd_maecred WHERE numcte = pClienteTraspasaCtas AND empresa='001';
	
	IF iExiste > 0 THEN
		
		FOREACH
			
			SELECT num_credito INTO vc_Credito FROM sd_maecred WHERE numcte = pClienteTraspasaCtas AND empresa='001'
			
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT {+INDEX (bdicred:sd_maecredcont maecredcont1)} 'SD_MAECREDCONT',"sd_maecredcont",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas), CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
			FROM "informix".sd_maecredcont WHERE  fecha IS NOT NULL AND num_credito = vc_Credito AND empresa='001' ;
			
			INSERT INTO bdinteg:"informix".si_fusmaecredcont(fecha,empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2)
			SELECT {+INDEX (bdicred:sd_maecredcont maecredcont1)}  fecha,empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
			FROM "informix".sd_maecredcont WHERE fecha IS NOT NULL AND num_credito = vc_Credito AND empresa='001' ;

			UPDATE  "informix".sd_maecredcont SET numcte = pClienteTitular WHERE  fecha IS NOT NULL AND num_credito = vc_Credito AND empresa='001' ;
		
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT 'CUENTAS DE CREDITO','sd_maecred',TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),
			TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas), CURRENT HOUR TO FRACTION(3), TRIM(pUsuario),CURRENT::DATE 
			FROM bdicred: "informix".sd_maecred WHERE   num_credito = vc_Credito AND empresa='001';
		
			INSERT INTO bdinteg:"informix".si_fusmaecred (empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2)
			SELECT   empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
			FROM "informix".sd_maecred  WHERE  num_credito = vc_Credito AND empresa='001';
            
			UPDATE   "informix".sd_maecred SET numcte = pClienteTitular WHERE  num_credito = vc_Credito AND empresa='001';
		
		END FOREACH;			
		
		SET ISOLATION TO DIRTY READ;
		IF EXISTS (SELECT {+INDEX (bdicred:sd_bitacora_aumlincred idx_bitacora_status)} num_solicitud FROM "informix".sd_bitacora_aumlincred WHERE numcte=pClienteTraspasaCtas AND status IS NOT NULL AND empresa='001') THEN
		
					INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
					SELECT  'AUMENTO LINEA CRED',"sd_bitacora_aumlincred",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),
					TRIM(pClienteTitular)||'|'||TRIM(num_solicitud)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
					FROM "informix".sd_bitacora_aumlincred WHERE numcte= TRIM(pClienteTraspasaCtas) AND status IS NOT NULL AND empresa='001';

					INSERT INTO bdinteg:"informix".si_fusbitacora_aumlincred (empresa,num_solicitud,numcte,num_producto,status,causa_status,fecha_status,hora_status,sucursal,lincred_actual,lincred_sugerida,smb_lincred,grado_riesgo,monto_reserva,califica_buro,resp_cte,mensaje,ejecutivo,sucursal_at,origen,user_insert,fecha_insert,dfecha_cobranza,num_inc_prev,num_per_porutimay_806,num_per_porutimay_8012,medio_res,cte_noestit_p,cte_noestit_v,porc_uso,int_cred_ven,may_porc_uso6,revisioncac,numcte_cop,antiguedad,puntualidad,eficienciapago,montovencido,abonomensual,lincred_solicitada,comp_ingreso,antecedentes_buro,antecedentes_circulo,pago_minimo,situacion,causa,compromisos_bco,compromisos_hip,ingreso_idp)
					SELECT {+INDEX (bdicred:sd_bitacora_aumlincred idx_bitacora_status)} empresa,num_solicitud,numcte,num_producto,status,causa_status,fecha_status,hora_status,sucursal,lincred_actual,lincred_sugerida,smb_lincred,grado_riesgo,monto_reserva,califica_buro,resp_cte,mensaje,ejecutivo,sucursal_at,origen,user_insert,fecha_insert,dfecha_cobranza,num_inc_prev,num_per_porutimay_806,num_per_porutimay_8012,medio_res,cte_noestit_p,cte_noestit_v,porc_uso,int_cred_ven,may_porc_uso6,revisioncac,numcte_cop,antiguedad,puntualidad,eficienciapago,montovencido,abonomensual,lincred_solicitada,comp_ingreso,antecedentes_buro,antecedentes_circulo,pago_minimo,situacion,causa,compromisos_bco,compromisos_hip,ingreso_idp
					FROM "informix".sd_bitacora_aumlincred WHERE numcte=pClienteTraspasaCtas AND status IS NOT NULL AND empresa='001';

					UPDATE {+INDEX (bdicred:sd_bitacora_aumlincred idx_bitacora_status)} "informix".sd_bitacora_aumlincred SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas AND status IS NOT NULL AND empresa='001';               
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		IF EXISTS (SELECT {+INDEX (bdicred:sd_tarjeta idx_sd_tarjeta1)} num_tarjeta  FROM "informix".sd_tarjeta WHERE numcte=pClienteTraspasaCtas) THEN
	  			FOREACH 
						SELECT {+INDEX (bdicred:sd_tarjeta idx_sd_tarjeta1)}  num_credito, secuencia, num_tarjeta INTO vc_Cuenta, vi_secuencia, vc_num_tarjeta
						FROM "informix".sd_tarjeta WHERE numcte=pClienteTraspasaCtas  

						LET vc_tabla = "sd_tarjeta";
						LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas)||'|'||vi_secuencia||'|'||TRIM(vc_num_tarjeta);
						LET vc_proceso='TARJETAS CREDITO';

						INSERT INTO bdinteg:"informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
						VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);
						
						INSERT INTO bdinteg:"informix".si_fustarjetacred (empresa,num_credito,secuencia,num_tarjeta,numcte,prodtarjeta,expiracion,tipo_tarjeta,nombre,status_tar,limite_aut,disp_mes,motivo,tipo_asignacion,cobro_comision,gerente_autoriza, folio_canc)
					   
						SELECT  empresa,num_credito,secuencia,num_tarjeta,numcte,prodtarjeta,expiracion,tipo_tarjeta,nombre,status_tar,limite_aut,disp_mes,motivo,tipo_asignacion,cobro_comision,gerente_autoriza, folio_canc
						FROM "informix".sd_tarjeta WHERE num_tarjeta = vc_num_tarjeta AND empresa='001';
						
						UPDATE  "informix".sd_tarjeta SET numcte = pClienteTitular WHERE num_tarjeta = vc_num_tarjeta; 
 
						LET vc_tabla = "intercard";
						LET vc_proceso='INTERCARD';

						INSERT INTO bdinteg:"informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
						VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);
						
						INSERT INTO bdinteg:"informix".si_fusintercardtarjeta (numtarjeta,codstatustarjeta,codproductotarjeta,numcliente,titular,nombre,direccion,coldeleg,ciudad,estado,codpostal,telcasa,teloficina,fechaexp,sefabricaplastico,seimprimenip,acumdiarioretatmnac,acumdiarioretatmint,acummensretatmnac,acummensretatmint,acumdiariocompraposnac,acumdiariocompraposint,acummenscompraposnac,acummenscompraposint,acumcomconsatmnac,acumcomconsatmint,acumcomretatmnac,acumcomretatmint,acumcomcompraposnac,acumcomcompraposint,acumcomrevatmnac,acumcomrevatmint,acumcomrevposnac,acumcomrevposint,acumcomfzdaposnac,acumcomfzdaposint,contcomconsatmnac,contcomconsatmint,contcomretatmnac,contcomretatmint,contcomcompraposnac,contcomcompraposint,contcomrevatmnac,contcomrevatmint,contcomrevposnac,contcomrevposint,contcomfzdaposnac,contcomfzdaposint,conttranconsatmlibres,conttranretatmlibres,conttrancompraposlibres,contmaxtranconsatmdiarias,contmaxtranretatmdiarias,contmaxtrancompraposdiarias,contmaxtranconsatmmens,contmaxtranretatmmens,contmaxtrancompraposmens,numerolote,contmaxtranretatmnachd,contmaxtrancompraposnachd,contmaxtranretatminthd,contmaxtrancompraposinthd,usuarioultmodif,fechaultmodif,acumretatmnachd,acumretatminthd,acumcompraposnachd,acumcompraposinthd,numreporte,enrenovacion,fechaexprenovacion,numtarjetasustituta,acumdiarioretatmpropio,acummensretatmpropio,acumcomconsatmpropio,acumcomretatmpropio,acumcomrevatmpropio,contcomconsatmpropio,contcomretatmpropio,contcomrevatmpropio,conttranconsatmlibrespropio,conttranretatmlibrespropio,contmaxtranconsatmdiariopropio,contmaxtranretatmdiariaspropio,contmaxtranconsatmmenspropio,contmaxtranretatmmenspropio,contmaxtranretatmpropiohd,acumretatmpropiohd,nombrecorto,fechanacimiento,nombrepromotor,cobracomreexptrj,cobracomreimpnip,idpaq,codstatusasignada,fechaasignacion,acumdiariocashbacknac,acummenscashbacknac,acumdiariocashadvancenac,acummenscashadvancenac,conttrancashbacklibres,conttrancashadvancelibres,contmaxtrancashbackdiarias,contmaxtrancashadvancediarias,contmaxtrancashbackmens,contmaxtrancashadvancemens,soportatranatmcajeropropio,soportatranatmcajeroconvenio,soportetranatmcajerored,contnipinvalido,acumdiarioretatmconvenio,acummensualretatmconvenio,acumcomconsatmconvenio,acumcomretatmconvenio,acumcomrevatmconvenio,contcomconsatmconvenio,contcomretatmconvenio,contcomrevatmconvenio,conttranconsatmconveniolibres,conttranretatmconveniolibres,contmaxtranconsatmdconveniodiarias,contmaxtranretatmconveniodiarias,contmaxtranconsatmconveniomens,contmaxtranretatmconveniomens,soportatranatmcajerointernacional,limitemenscompraposnac,limitemenscompraposint,numeroguia,acumdiarioqps,acumdiariocat,acumdiariomotovoz,acumdiariomotoint,acummensualmotovoz,acummensualmotoint,conttransmotovozdiario,conttransmotointdiario,conttransmotovozmensual,conttransmotointmensual) 
						SELECT numtarjeta,codstatustarjeta,codproductotarjeta,numcliente,titular,nombre,direccion,coldeleg,ciudad,estado,codpostal,telcasa,teloficina,fechaexp,sefabricaplastico,seimprimenip,acumdiarioretatmnac,acumdiarioretatmint,acummensretatmnac,acummensretatmint,acumdiariocompraposnac,acumdiariocompraposint,acummenscompraposnac,acummenscompraposint,acumcomconsatmnac,acumcomconsatmint,acumcomretatmnac,acumcomretatmint,acumcomcompraposnac,acumcomcompraposint,acumcomrevatmnac,acumcomrevatmint,acumcomrevposnac,acumcomrevposint,acumcomfzdaposnac,acumcomfzdaposint,contcomconsatmnac,contcomconsatmint,contcomretatmnac,contcomretatmint,contcomcompraposnac,contcomcompraposint,contcomrevatmnac,contcomrevatmint,contcomrevposnac,contcomrevposint,contcomfzdaposnac,contcomfzdaposint,conttranconsatmlibres,conttranretatmlibres,conttrancompraposlibres,contmaxtranconsatmdiarias,contmaxtranretatmdiarias,contmaxtrancompraposdiarias,contmaxtranconsatmmens,contmaxtranretatmmens,contmaxtrancompraposmens,numerolote,contmaxtranretatmnachd,contmaxtrancompraposnachd,contmaxtranretatminthd,contmaxtrancompraposinthd,usuarioultmodif,fechaultmodif,acumretatmnachd,acumretatminthd,acumcompraposnachd,acumcompraposinthd,numreporte,enrenovacion,fechaexprenovacion,numtarjetasustituta,acumdiarioretatmpropio,acummensretatmpropio,acumcomconsatmpropio,acumcomretatmpropio,acumcomrevatmpropio,contcomconsatmpropio,contcomretatmpropio,contcomrevatmpropio,conttranconsatmlibrespropio,conttranretatmlibrespropio,contmaxtranconsatmdiariopropio,contmaxtranretatmdiariaspropio,contmaxtranconsatmmenspropio,contmaxtranretatmmenspropio,contmaxtranretatmpropiohd,acumretatmpropiohd,nombrecorto,fechanacimiento,nombrepromotor,cobracomreexptrj,cobracomreimpnip,idpaq,codstatusasignada,fechaasignacion,acumdiariocashbacknac,acummenscashbacknac,acumdiariocashadvancenac,acummenscashadvancenac,conttrancashbacklibres,conttrancashadvancelibres,contmaxtrancashbackdiarias,contmaxtrancashadvancediarias,contmaxtrancashbackmens,contmaxtrancashadvancemens,soportatranatmcajeropropio,soportatranatmcajeroconvenio,soportetranatmcajerored,contnipinvalido,acumdiarioretatmconvenio,acummensualretatmconvenio,acumcomconsatmconvenio,acumcomretatmconvenio,acumcomrevatmconvenio,contcomconsatmconvenio,contcomretatmconvenio,contcomrevatmconvenio,conttranconsatmconveniolibres,conttranretatmconveniolibres,contmaxtranconsatmdconveniodiarias,contmaxtranretatmconveniodiarias,contmaxtranconsatmconveniomens,contmaxtranretatmconveniomens,soportatranatmcajerointernacional,limitemenscompraposnac,limitemenscompraposint,numeroguia,acumdiarioqps,acumdiariocat,acumdiariomotovoz,acumdiariomotoint,acummensualmotovoz,acummensualmotoint,conttransmotovozdiario,conttransmotointdiario,conttransmotovozmensual,conttransmotointmensual
						FROM intercard:"informix".tarjeta where numcliente=pClienteTraspasaCtas AND numtarjeta = vc_num_tarjeta;

						UPDATE  intercard:"informix".tarjeta SET numcliente= pClienteTitular WHERE numtarjeta = vc_num_tarjeta; 
						
						LET vc_tabla = "sd_encabezado_edocta";
						LET vc_detalle_mov = TRIM(vc_num_tarjeta)||'|'||TRIM(pClienteTraspasaCtas)||'|'||vc_Cuenta; 
						LET vc_proceso='SD_ENCABEZADO_EDOCTA';

						INSERT INTO bdinteg:"informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
						VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);
					   
						INSERT INTO bdinteg:"informix".si_fusencabezado_edocta (fecha_emision,num_credito,num_producto,numcte,num_tarjeta,nombre_cte,direccion_cn,direccion_col,direccion_del,edo_cd,sucursal_nombre,sucursal_gerente,sucursal_tel,fecha_corte,cp,cl_cobra,rfc,ruta,entre_calles,observaciones,insertos,sucursal)
						
						SELECT {+INDEX (bdicred:sd_encabezado_edocta idx_encabezado_numcte)} fecha_emision,num_credito,num_producto,numcte,num_tarjeta,nombre_cte,direccion_cn,direccion_col,direccion_del,edo_cd,sucursal_nombre,sucursal_gerente,sucursal_tel,fecha_corte,cp,cl_cobra,rfc,ruta,entre_calles,observaciones,insertos,sucursal
						FROM "informix".sd_encabezado_edocta WHERE  num_tarjeta= vc_num_tarjeta;
						
						UPDATE  {+INDEX (bdicred:sd_encabezado_edocta idx_encabezado_numcte)} "informix".sd_encabezado_edocta SET numcte = pClienteTitular WHERE num_tarjeta= vc_num_tarjeta;
					   
					END FOREACH;
        END IF;

    END IF;
    --***INICIA TRASPASO DE REESTRUCTURA
    SET ISOLATION TO DIRTY READ;
	
	IF EXISTS  (SELECT COUNT(num_credito) FROM sd_maecredcrd WHERE numcte =pClienteTraspasaCtas AND empresa='001') THEN
	
				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT 'SD_MAECREDCRD',"sd_maecredcrd",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
				FROM "informix".sd_maecredcrd WHERE numcte= TRIM(pClienteTraspasaCtas);
	
				INSERT INTO bdinteg:"informix".si_fusmaecredcrd (empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4 )
				SELECT {+INDEX (bdicred:sd_maecredcrd idx_1x)} empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4 
				FROM "informix".sd_maecredcrd WHERE numcte = pClienteTraspasaCtas;

				UPDATE {+INDEX (bdicred:sd_maecredcrd idx_1x)} "informix".sd_maecredcrd SET numcte = pClienteTitular WHERE numcte = pClienteTraspasaCtas;
				--**
		
		IF EXISTS (SELECT num_credito FROM "informix".sd_maecredrevcrd WHERE numcte = pClienteTraspasaCtas) THEN
		
				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT 'SD_MAECREDREVCRD',"sd_maecredrevcrd",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE
				FROM "informix".sd_maecredrevcrd WHERE numcte= TRIM(pClienteTraspasaCtas);
						
				INSERT INTO bdinteg:"informix".si_fusmaecredrevcrd(empresa,folio,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4)
				SELECT {+INDEX (bdicred:sd_maecredrevcrd idx_sd_maecredrevcrd)}  empresa,folio,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4
				FROM "informix".sd_maecredrevcrd WHERE numcte= pClienteTraspasaCtas;

				UPDATE {+INDEX (bdicred:sd_maecredrevcrd idx_sd_maecredrevcrd)}  "informix".sd_maecredrevcrd SET numcte = pClienteTitular WHERE numcte= pClienteTraspasaCtas;
		END IF;
		--****
		IF EXISTS (SELECT num_credito  FROM "informix".sd_maecredcontcrd WHERE numcte=pClienteTraspasaCtas) THEN
		
				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT {+INDEX (bdicred:sd_maecredcontcrd idx_sd_maecredcontcrd)}  'SD_MAECREDCONTCRD',"sd_maecredcontcrd",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
				FROM "informix".sd_maecredcontcrd WHERE numcte= pClienteTraspasaCtas;
				
				INSERT INTO bdinteg:"informix".si_fusmaecredcontcrd (fecha,empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4)
				SELECT {+INDEX (bdicred:sd_maecredcontcrd idx_sd_maecredcontcrd)}  fecha,empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4
				FROM "informix".sd_maecredcontcrd WHERE numcte=pClienteTraspasaCtas;

				UPDATE {+INDEX (bdicred:sd_maecredcontcrd idx_sd_maecredcontcrd)}  "informix".sd_maecredcontcrd SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
					 
		END IF;
		
		IF EXISTS (SELECT  num_credito FROM "informix".sd_seguimientocrd WHERE numcte = pClienteTraspasaCtas) THEN
				
				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT  'SD_SEGUIMIENTOCRD',"sd_seguimientocrd",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
				FROM "informix".sd_seguimientocrd WHERE numcte= TRIM(pClienteTraspasaCtas);
				
				INSERT INTO bdinteg:"informix".si_fusseguimientocrd (empresa,id_tipo,id_campania,num_credito,fecha_corte,sucursal,numcte,nombre_cliente,tel_casa,tel_celular,tel_oficina,num_extension,nombre_referencia1,telefono_referencia1,nombre_referencia2,telefono_referencia2,fecha_reestruc,monto_reestruc,fecha_prox_pago,monto_prox_pago,saldo_corte) 
				SELECT empresa,id_tipo,id_campania,num_credito,fecha_corte,sucursal,numcte,nombre_cliente,tel_casa,tel_celular,tel_oficina,num_extension,nombre_referencia1,telefono_referencia1,nombre_referencia2,telefono_referencia2,fecha_reestruc,monto_reestruc,fecha_prox_pago,monto_prox_pago,saldo_corte
				FROM "informix".sd_seguimientocrd WHERE numcte= pClienteTraspasaCtas;

				UPDATE  "informix".sd_seguimientocrd SET numcte = pClienteTitular WHERE  numcte= pClienteTraspasaCtas;
		
		END IF;
		
		IF EXISTS (SELECT num_credito FROM "informix".sd_encabezado_edoctacrd WHERE numcte = pClienteTraspasaCtas) THEN
		
				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT  'SD_ENCABEZADO_EDOCTACRD',"sd_encabezado_edoctacrd",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
				FROM "informix".sd_encabezado_edoctacrd WHERE numcte= TRIM(pClienteTraspasaCtas);
				
				INSERT INTO bdinteg:"informix".si_fusencabezado_edoctacrd (fecha_emision,num_credito,num_cta_efec,num_producto,numcte,nombre_cte,direccion_cn,direccion_col,direccion_del,edo_cd,cl_cobra,sucursal_numero,sucursal_nombre,sucursal_gerente,rfc,sucursal_tel,cp,ruta,entre_calles,observaciones,insertos) 
				SELECT  fecha_emision,num_credito,num_cta_efec,num_producto,numcte,nombre_cte,direccion_cn,direccion_col,direccion_del,edo_cd,cl_cobra,sucursal_numero,sucursal_nombre,sucursal_gerente,rfc,sucursal_tel,cp,ruta,entre_calles,observaciones,insertos
				FROM "informix".sd_encabezado_edoctacrd WHERE numcte= pClienteTraspasaCtas;
		
				UPDATE "informix".sd_encabezado_edoctacrd SET numcte = pClienteTitular WHERE numcte = pClienteTraspasaCtas;
				
		END IF;
		
    END IF;   
     
	IF EXISTS (SELECT num_credito  FROM "informix".sd_grupo_credito WHERE numcte=pClienteTraspasaCtas) THEN
    
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT 'GRUPO_CREDITO',"sd_grupo_credito",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(pClienteTitular)||'|'||TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
			FROM "informix".sd_grupo_credito WHERE numcte= TRIM(pClienteTraspasaCtas);
	
            INSERT INTO bdinteg:"informix".si_fusgrupo_credito (empresa,num_producto,num_credito,numcte,grupo,tipo,status_cliente,fecha_status,status_cred,monto_autorizado,porcentaje_uso,num_historia_efic,meses_sinusolin,user_insert,fecha_insert)
			SELECT  empresa,num_producto,num_credito,numcte,grupo,tipo,status_cliente,fecha_status,status_cred,monto_autorizado,porcentaje_uso,num_historia_efic,meses_sinusolin,user_insert,fecha_insert
			FROM "informix".sd_grupo_credito WHERE numcte= pClienteTraspasaCtas;
			
            UPDATE "informix".sd_grupo_credito SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
			
    END IF;
     
	IF EXISTS (SELECT num_credito  FROM "informix".sd_grupo_credito_his WHERE numcte=pClienteTraspasaCtas) THEN
    
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT  'GRUPO_CREDITO_HIS',"sd_grupo_credito_his",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(pClienteTitular)||'|'||TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
			FROM "informix".sd_grupo_credito_his WHERE numcte= TRIM(pClienteTraspasaCtas);
			
            INSERT INTO bdinteg:"informix".si_fusgrupo_credito_his (empresa,num_producto,num_credito,numcte,fecha_status,grupo,tipo,status_cliente,status_cred,monto_autorizado,porcentaje_uso,num_historia_efic,user_insert,fecha_insert,motivo)
			SELECT  empresa,num_producto,num_credito,numcte,fecha_status,grupo,tipo,status_cliente,status_cred,monto_autorizado,porcentaje_uso,num_historia_efic,user_insert,fecha_insert,motivo
			FROM "informix".sd_grupo_credito_his WHERE numcte=pClienteTraspasaCtas;

            UPDATE "informix".sd_grupo_credito_his SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
        
    END IF;
    
	IF EXISTS (SELECT numcte  FROM "informix".sd_grupo_cliente WHERE numcte=pClienteTraspasaCtas) THEN
  
        LET vc_tabla = "sd_grupo_cliente";
        LET vc_detalle_mov = TRIM(pClienteTraspasaCtas); 
        LET vc_proceso='GRUPO_CLIENTE';

		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
        VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);
		
        INSERT INTO bdinteg:"informix".si_fusgrupo_cliente (empresa,numcte,grupo,user_insert,fecha_insert)
        SELECT empresa,numcte,grupo,user_insert,fecha_insert
		FROM "informix".sd_grupo_cliente 
		WHERE numcte=pClienteTraspasaCtas;

        DELETE FROM "informix".sd_grupo_cliente WHERE numcte=pClienteTraspasaCtas;

    END IF;
    --***
	IF EXISTS (SELECT  {+INDEX (bdicred:sd_maecred_vendida idx_maecredvendida)}   num_credito FROM "informix".sd_maecred_vendida WHERE numcte=pClienteTraspasaCtas) THEN
    
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT {+INDEX (bdicred:sd_maecred_vendida idx_maecredvendida)}   'CARTERA VENDIDA',"sd_maecred_vendida",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(pClienteTitular)||'|'||TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
			FROM "informix".sd_maecred_vendida WHERE numcte= TRIM(pClienteTraspasaCtas);
					
            INSERT INTO bdinteg:"informix".si_fusmaecred_vendida (fecha,empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2)
			SELECT   {+INDEX (bdicred:sd_maecred_vendida idx_maecredvendida)}   fecha,empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
			FROM "informix".sd_maecred_vendida WHERE numcte=pClienteTraspasaCtas;

            UPDATE {+INDEX (bdicred:sd_maecred_vendida idx_maecredvendida)}   "informix".sd_maecred_vendida SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;          
	
	END IF;
     --***
	 
	IF EXISTS (SELECT  num_credito  FROM "informix".sd_maecredcont_apoyo WHERE numcte=pClienteTraspasaCtas) THEN
    
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT 'CREDITO APOYO',"sd_maecredcont_apoyo",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(pClienteTitular)||'|'||TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE
			FROM "informix".sd_maecredcont_apoyo WHERE numcte= TRIM(pClienteTraspasaCtas);
		
            INSERT INTO bdinteg:"informix".si_fusmaecredcont_apoyo (fecha,empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2)
			SELECT fecha,empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
			FROM "informix".sd_maecredcont_apoyo WHERE numcte=pClienteTraspasaCtas;

            UPDATE  "informix".sd_maecredcont_apoyo SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
    
	END IF;
     --***
	
	IF EXISTS (SELECT {+INDEX (bdicred:sd_maecredcrd_vendida idx_maecredcrdvendida)}   num_credito FROM "informix".sd_maecredcrd_vendida WHERE numcte=pClienteTraspasaCtas) THEN
    		
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT {+INDEX (bdicred:sd_maecredcrd_vendida idx_maecredcrdvendida)}   'CRD VENDIDA',"sd_maecredcrd_vendida",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(pClienteTitular)||'|'||TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
			FROM "informix".sd_maecredcrd_vendida WHERE numcte= TRIM(pClienteTraspasaCtas);
		
            INSERT INTO bdinteg:"informix".si_fusmaecredcrd_vendida (fecha,empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4)
            SELECT  {+INDEX (bdicred:sd_maecredcrd_vendida idx_maecredcrdvendida)}   fecha,empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4
			FROM   "informix".sd_maecredcrd_vendida where numcte=pClienteTraspasaCtas;

            UPDATE  {+INDEX (bdicred:sd_maecredcrd_vendida idx_maecredcrdvendida)}   "informix".sd_maecredcrd_vendida SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
    
	END IF;
    --***
	
	IF EXISTS (SELECT {+INDEX (bdicred:sd_maecredrev idx_sd_maecredrev)}  num_credito FROM "informix".sd_maecredrev WHERE numcte=pClienteTraspasaCtas) THEN
	
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT {+INDEX (bdicred:sd_maecredrev idx_sd_maecredrev)}   'SD_MAECREDREV',"sd_maecredrev",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(folio)||'|'||TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
			FROM "informix".sd_maecredrev WHERE numcte= TRIM(pClienteTraspasaCtas);
			
            INSERT INTO bdinteg:"informix".si_fusmaecredrev (empresa,folio,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2)
           SELECT  {+INDEX (bdicred:sd_maecredrev idx_sd_maecredrev)}   empresa,folio,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
			FROM "informix".sd_maecredrev WHERE numcte=pClienteTraspasaCtas;

            UPDATE  {+INDEX (bdicred:sd_maecredrev idx_sd_maecredrev)}    "informix".sd_maecredrev SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;
    
	END IF;
    
	EXECUTE PROCEDURE bdicred:"informix".sp_traspasocuentas_cred2(pClienteTitular, pClienteTraspasaCtas, pUsuario) INTO vc_CodRet, vc_Mensaje;
	
    IF vc_CodRet = "00000" THEN
		COMMIT WORK;
		RETURN vc_CodRet,vc_Mensaje;
	ELSE
	--Si el segundo SP devuelve un código de retorno diferente de '00000',  hará un ROLLBACK de todo el proceso
		ROLLBACK WORK;
		RETURN vc_CodRet,vc_Mensaje;
	END IF;
END;
END PROCEDURE
DOCUMENT
'Folio: 1447',
'Autor: 95347143 ',
'Fecha: 22/07/2014',
'Descripción: Optmizar sp sp_traspasocuentas_cred para reducir tiempos y costos de ejecución. Se secciono el sp, la segunda parte se llama',
'sp_traspasocuentas_cred2. Se eliminaron selec *, se eliminaron ciclos foreach (lo mas posible) y hacer uso de indices. ',
'Sustento: Analisis RQI64012 Optimizacion de proceso de fusion automatica.pdf',
'Solicita: Jose Angel Lopez Adams',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_cargoref_tdc_general(pEmpresa  CHAR(3),
												 pSucursal CHAR(4),
												 pUsuario  CHAR(8),
												 pTarjeta  CHAR(20),
												 pMonto    DECIMAL(14,2),
												 pTransuc  CHAR(4),
												 pFolioSuc  CHAR(16),
												 pReferencia  CHAR(40))
RETURNING CHAR(5)     AS codigo_retorno,
          CHAR(4)     AS terminacion_tarjeta,
          CHAR(60)    AS nombre_cte,
          MONEY(16,2) AS monto_cargo,
		  MONEY(16,2) AS monto_comision,
		  MONEY(16,2) AS iva_comision;
		  
DEFINE nrows              INTEGER;
DEFINE iSqlErr            INTEGER;
DEFINE iIsamErr           INTEGER;
DEFINE cErrorInfo         CHAR(80);
DEFINE vCodRet            CHAR(5);	  

DEFINE cod_ret            CHAR(5);
DEFINE v_codparam	   	  CHAR(4);
DEFINE v_fecha            DATE;
DEFINE Saldo              MONEY(14,2);
DEFINE MtoCgo		  	  MONEY(14,2);
DEFINE cod_ret2           CHAR(5);
DEFINE SaldoCom           MONEY(14,2);
DEFINE MtoCom		   	  MONEY(12,2);
DEFINE v_num_credito      CHAR(20);
DEFINE v_divisa           CHAR(2);
DEFINE vsucorig           CHAR(4);
DEFINE vNumCte            CHAR(20);
DEFINE vNombreCte         CHAR(60);
DEFINE vTerminacion       CHAR(4);
DEFINE vIvaCom            MONEY(16,2);

LET nrows                 = 0;
LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = '';
LET vCodRet               = '000';

LET cod_ret               = "000";
LET v_codparam	   	      = "";
LET v_fecha               = DATE(1);
LET Saldo                 = 0;
LET MtoCgo		  	      = 0;
LET cod_ret2              = "";
LET SaldoCom              = 0;
LET MtoCom		   	      = 0;
LET v_num_credito         = "";
LET v_divisa              = "";
LET vsucorig              = "";
LET vNumCte               = "";
LET vNombreCte            = "";
LET vTerminacion          = "";
LET vIvaCom               = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
		LET vCodRet = iSqlErr;
		RETURN cod_ret, vTerminacion, vNombreCte, MtoCgo, MtoCom, vIvaCom;
    END IF;
END EXCEPTION;

-- SET DEBUG FILE TO "/informix/paulq/cargoref_tdc_general.out";
-- TRACE ON;
	  
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT a.num_credito, b.divisa, b.sucursal, b.numcte
  INTO v_num_credito, v_divisa, vsucorig, vNumCte
  FROM bdicred:"informix".sd_tarjeta a,
       bdicred:"informix".sd_maecred b
 WHERE a.empresa     = pEmpresa
   AND a.num_tarjeta = pTarjeta
   AND b.empresa     = a.empresa
   AND b.num_credito = a.num_credito;

IF v_num_credito IS NULL THEN
	LET cod_ret = "8";
	RETURN cod_ret, vTerminacion, vNombreCte, MtoCgo, MtoCom, vIvaCom;
END IF

SELECT TRIM(NVL(razon_social, ' ')) ||
TRIM(nombre1) || " " ||
--TRIM(NVL(nombre2, ' ')) || " " ||
TRIM(apell_paterno)
--TRIM(apell_materno)
INTO vNombreCte
FROM bdinteg:"informix".si_cliente
WHERE numcte = vNumCte;

LET vTerminacion = SUBSTR(pTarjeta,LENGTH(pTarjeta)-3,LENGTH(pTarjeta));
		
EXECUTE PROCEDURE bdicred:"informix".cargo_ref_cel(pTarjeta, pSucursal, pUsuario,
					                               pTransuc, pTransuc, pFolioSuc,
												   v_num_credito, 1, pMonto, 0,
												   " ", " ", v_divisa, pReferencia,  
												   pSucursal, pUsuario, "",
												   "", "", v_num_credito,
												   1, 0, v_divisa, " ", "2",
												   "F"," ", " ", " ", 0, 0, " ", " ")
	INTO cod_ret, v_codparam, v_fecha, Saldo, MtoCgo, 
	     cod_ret2, v_codparam, v_fecha, SaldoCom, MtoCom;
		 
    LET vIvaCom = MtoCgo - pMonto - MtoCom;
		
RETURN cod_ret, vTerminacion, vNombreCte, MtoCgo, MtoCom, vIvaCom;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para la realización del cargo',
'por retiro de efectivo TDC desde alguna plataforma',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 08/09/2015',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_consulta_retiro_tdc(pEmpresa     CHAR(3),
												   pSucursal    CHAR(4),
												   pCuenta      CHAR(20),
												   pNumTarjeta  CHAR(20),
												   pMonto       DECIMAL(14,2),
												   pDivisa      CHAR(2))
RETURNING CHAR(5)         AS codigo_retorno,
          DECIMAL(14,2)   AS importe_retiro,
		  DECIMAL(14,2)   AS importe_comision,
		  DECIMAL(14,2)   AS importe_iva_comision;
									
DEFINE nrows              INTEGER;
DEFINE iSqlErr            INTEGER;
DEFINE iIsamErr           INTEGER;
DEFINE cErrorInfo         CHAR(80);
DEFINE vCodRet            CHAR(5);

DEFINE vNumCte            CHAR(20);
DEFINE vEmpresa           CHAR(3);
DEFINE vSucursal          CHAR(4);
DEFINE vDivisa            CHAR(2);
DEFINE vNumProducto       CHAR(4);
DEFINE vStatusCred        CHAR(2);
DEFINE vSaldo             MONEY(16,2);
DEFINE vTipoCredito       CHAR(2);
DEFINE vTasaIva           DECIMAL(5,3);
DEFINE vFechaHoy          DATE;
DEFINE vSdoPos            DECIMAL(14,2);
DEFINE vBloqueo           INTEGER;
DEFINE vCodCaracter       CHAR(2);
DEFINE v_codparam         CHAR(4);
DEFINE v_faplica          CHAR(1);
DEFINE vMtoComDisp        DECIMAL(14,2);
DEFINE v_factor           DECIMAL(9,6);
DEFINE v_rangos           CHAR(1);
DEFINE v_rmax             MONEY(14,2);
DEFINE vMtoComDisp_iva    DECIMAL(14,2);
DEFINE vIva               DECIMAL(14,2);

LET nrows                 = 0;
LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = '';
LET vCodRet               = '000';

LET vNumCte               = '';
LET vEmpresa              = '';
LET vSucursal             = '';
LET vDivisa               = '';
LET vNumProducto          = '';
LET vStatusCred           = '';
LET vSaldo                = 0;
LET vTipoCredito          = '';
LET vTasaIva              = 0;
LET vFechaHoy             = DATE(1);
LET vSdoPos               = 0;
LET vBloqueo              = 0;
LET vCodCaracter          = '';
LET v_codparam            = '';
LET v_faplica             = '';
LET vMtoComDisp           = 0;
LET v_factor              = 0;
LET v_rangos              = '';
LET v_rmax                = 0;
LET vMtoComDisp_iva       = 0;
LET vIva                  = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
		LET vCodRet = iSqlErr;
		RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/paulq/sp_consulta_retiro_tdc.out';
--TRACE ON;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

IF NOT EXISTS( SELECT empresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa) THEN
	LET vCodRet = "1070";
	RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
END IF;

IF NOT EXISTS(SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = pEmpresa AND sucursal = pSucursal) THEN
	LET vCodRet = "1077";
	RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
END IF;

IF NOT EXISTS(SELECT divisa FROM bdinteg:"informix".si_divisas where divisa = pDivisa) THEN
	LET vCodRet = "1078";
	RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
END IF;

IF NVL(pMonto,0) <= 0 THEN
	LET vCodRet = "1079";
	RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
END IF;

IF TRIM(NVL(pNumTarjeta,'')) = '' AND TRIM(NVL(pCuenta,'')) = '' THEN
	LET vCodRet = "1076";
	RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
END IF;

IF TRIM(NVL(pCuenta,'')) = '' THEN 
	SELECT num_credito
	  INTO pCuenta
	  FROM bdicred:"informix".sd_tarjeta
	 WHERE empresa = pEmpresa
	   AND num_tarjeta = pNumTarjeta
	   AND tipo_tarjeta = "T"
	   AND status_tar = "A";

	IF pCuenta IS NULL THEN
		LET vCodRet = "8";
		RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
	END IF
END IF;

SELECT a.empresa, a.sucursal, a.divisa, a.num_producto, a.status_cred,
	   b.monto_otorgado - (b.sdo_cap_insoluto + sdo_retenido),
       c.cod_tipcred, d.iva, e.fecha_proceso,
       CASE WHEN sdo_capital < 0 THEN  sdo_capital * -1 ELSE 0 END,
       a.id_unidad_prod, numcte,Cod_caract_2
  INTO vEmpresa, vSucursal, vDivisa, vNumProducto, vStatusCred,
	   vSaldo, vTipoCredito, vTasaIva, vFechaHoy, vSdoPos,
	   vBloqueo, vNumCte, vCodCaracter
  FROM "informix".sd_maecred a, "informix".sd_maesdos b, "informix".sd_definicion c, "informix".sd_maecredanexo e,
       bdinteg:"informix".si_sucursales d
 WHERE a.num_credito = pCuenta
   AND a.empresa = pEmpresa
   AND b.num_credito = a.num_credito
   AND a.empresa = b.empresa
   AND c.num_producto = a.num_producto
   AND e.num_credito = a.num_credito
   AND e.empresa = a.empresa
   AND d.empresa = a.empresa
   AND d.sucursal = pSucursal;
   
	IF vNumCte IS NULL THEN
			LET vCodRet = "100";
			RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
	END IF
   
SELECT valor
  INTO v_codparam
  FROM "informix".sd_param
 WHERE empresa = '001'
   AND cod_param = "334";

SELECT form_aplica, monto, apli_factor, consi_rango, monto_max
  INTO v_faplica, vMtoComDisp, v_factor, v_rangos, v_rmax
  FROM "informix".sd_tpcomis
 WHERE empresa = '001'
   AND cod_comis = v_codparam;
   
IF v_faplica = 2 THEN
	LET vMtoComDisp = pMonto * (v_factor/100);
END IF
   
IF v_rangos = "1" THEN
	IF vMtoComDisp < v_rmax THEN
		LET vMtoComDisp = v_rmax;
	END IF
END IF;

LET vMtoComDisp_iva = vMtoComDisp * vTasaIva;
LET vIva = vMtoComDisp_iva;

RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);

END
END PROCEDURE
DOCUMENT
'Se realiza el calculo de la comisión',
'por retiro de efectivo TDC',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 08/09/2015',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_cac_rep_perfil_usuario(pFechaIni CHAR (10), pFechaFin CHAR(10))
RETURNING CHAR(6)                         AS codigo_retorno,
          CHAR(80)                        AS mensaje_retorno,
		  CHAR(8)                         AS Numempleado,
		  CHAR(45)                        AS Nombre,
		  CHAR (25)                       AS Perfil_Puesto,
		  INTEGER                         AS Atendidas,
		  DECIMAL(18,2)                   AS PorcAtendidas,
		  INTEGER                         AS Canceladas,
		  DECIMAL(18,2)                   AS PorcCanceladas,
		  INTEGER                         AS Rechazadas,
		  DECIMAL(18,2)                   AS PorcRechazadas,
		  INTEGER                         AS Autorizadas,
		  DECIMAL(18,2)                   AS PorcAutorizadas,
		  
		  INTEGER                         AS TotalAtendidas,
		  DECIMAL(18,2)                   AS TotalPorcAtendidas,
		  INTEGER                         AS TotalCanceladas,
		  DECIMAL(18,2)                   AS TotalPorcCanceladas,
		  INTEGER                         AS TotalRechazadas,
		  DECIMAL(18,2)                   AS TotalPorcRechazadas,
		  INTEGER                         AS TotalAutorizadas,
		  DECIMAL(18,2)                   AS TotalPorcAutorizadas;

---DECLARACIONES   
DEFINE cCodRet              CHAR(6); 
DEFINE cMensajeRet          CHAR(80);
DEFINE iSqlErr      	    INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);
DEFINE dPorcAtendidas		DECIMAL(18,2);	
DEFINE dPorcCanceladas		DECIMAL(18,2);
DEFINE dPorcRechazadas		DECIMAL(18,2);
DEFINE dPorcAutorizados	    DECIMAL(18,2);
DEFINE cDescripcion 		CHAR(25);
DEFINE cNombre				CHAR(45);
DEFINE cBandera 			CHAR(1);
DEFINE iCanceladas			INTEGER;
DEFINE iAutorizadas	     	INTEGER;
DEFINE iRechazadas		    INTEGER;
DEFINE cEjecutivo           CHAR(8);
DEFINE cPuesto 				CHAR(2);
DEFINE cRangoAutorizacion	CHAR(2);
DEFINE iTotalReg 			INTEGER;
DEFINE iTotalPerfil			INTEGER;

DEFINE dTotalPorcAtendidas		DECIMAL(18,2);	
DEFINE dTotalPorcCanceladas		DECIMAL(18,2);
DEFINE dTotalPorcRechazadas		DECIMAL(18,2);
DEFINE dTotalPorcAutorizados	    DECIMAL(18,2);

DEFINE iTotalTotalPerfil			INTEGER;
DEFINE iTotalCanceladas			INTEGER;
DEFINE iTotalAutorizadas	     	INTEGER;
DEFINE iTotalRechazadas		    INTEGER;
---INICIALIZACIONES

LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = "";
LET cCodRet                  = "000000";
LET cMensajeRet              = "Se realizó la consulta correctamente";
LET dPorcAtendidas		     = 0;
LET dPorcCanceladas		     = 0;
LET dPorcRechazadas		     = 0;
LET dPorcAutorizados	     = 0;
LET iCanceladas		     	 = 0;
LET iAutorizadas	     	 = 0;
LET iRechazadas		     	 = 0;
LET cEjecutivo				 = "";
LET cPuesto 				 = "";
LET cRangoAutorizacion		 = "";
LET iTotalReg				 = 0;
LET cDescripcion			 = "";
LET cNombre 				 = "";
LET cBandera				 = "";
LET iTotalPerfil			 = 0;

LET dTotalPorcAtendidas		     = 0;
LET dTotalPorcCanceladas		     = 0;
LET dTotalPorcRechazadas		     = 0;
LET dTotalPorcAutorizados	     = 0;

LET iTotalTotalPerfil			 = 0;
LET iTotalCanceladas		     	 = 0;
LET iTotalAutorizadas	     	 = 0;
LET iTotalRechazadas		     	 = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
    LET cCodRet= iSqlErr;
	LET cMensajeRet=cErrorInfo;
       RETURN cCodRet, cMensajeRet, NVL(cEjecutivo,' '), NVL(cNombre,' '), NVL(cDescripcion,' '), NVL(iTotalPerfil,0), NVL(dPorcAtendidas,0), NVL(iCanceladas,0), NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
		NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0);
   END IF;
END EXCEPTION;

	--set debug file to "/informix/jesus/sp_cac_rep_perfil_usuario.out";
	--trace on;

--se validan los parametros de entrada.
IF NVL(pFechaini,"") = "" OR NVL(pFechaFin,"")="" THEN
	LET cCodRet = "000001";
	LET cMensajeRet = "Falta un parámetro de fecha requerido para realizar  la consulta";
	RETURN cCodRet, cMensajeRet,NVL(cEjecutivo,""),NVL(cNombre,""),NVL(cDescripcion,""),NVL(iTotalPerfil,0),NVL(dPorcAtendidas,0),NVL(iCanceladas,0),NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
		NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0);
END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
----se obtiene el total de registros de solicitudes atendidas.
			
	SELECT {+INDEX (bdicred:sd_historica_cac_aumlincred idx1_sd_historica_cac_aumlincred)} COUNT( b.num_solicitud) --total atendidas 
	INTO iTotalReg
	FROM  bdicred:"informix".sd_historica_cac_aumlincred h ,
	bdicred:"informix".sd_bitacora_aumlincred b			  
	WHERE  h.empresa = b.empresa 
	AND h.solicitud  = b.num_solicitud
	AND h.fecha_insert between  b.fecha_insert and b.fecha_status
	AND b.fecha_insert >= pFechaIni
	AND b.fecha_insert <= pFechaFin
	AND b.origen = "S";
	
	
	IF iTotalReg = 0 THEN
		LET cCodRet = "000003";
		LET cMensajeRet =  "No hay información con el rango de fechas solicitado";		
		RETURN cCodRet, cMensajeRet,NVL(cEjecutivo,""),NVL(cNombre,""),NVL(cDescripcion,""),NVL(iTotalPerfil,0),NVL(dPorcAtendidas,0),NVL(iCanceladas,0),NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
			NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0);
	END IF;	
	--Ciclo para obtener la cantidad de solicitudes atendidas por puesto y ejecutivo
	FOREACH WITH HOLD	
		SELECT {+INDEX (bdicred:sd_historica_cac_aumlincred idx1_sd_historica_cac_aumlincred)} h.puesto,h.ejecutivo,COUNT( b.num_solicitud), --total atendidas por usuario	
		SUM(CASE WHEN b.status='CM' THEN 1 ELSE 0 END),--Canceladas
		SUM(CASE WHEN b.status='RT' THEN 1 ELSE 0 END),--Rechazadas
		SUM(CASE WHEN b.status in ('AT','AP','IN') THEN 1 ELSE 0 END)--Autorizadas
		INTO cPuesto,cEjecutivo,iTotalPerfil,iCanceladas,iRechazadas,iAutorizadas
		FROM bdicred:"informix".sd_bitacora_aumlincred b, bdicred:"informix".sd_historica_cac_aumlincred h
		WHERE  h.empresa = b.empresa 
		AND h.solicitud  = b.num_solicitud
		AND h.fecha_insert between  b.fecha_insert and b.fecha_status
		AND b.fecha_insert >= pFechaIni
		AND b.fecha_insert <= pFechaFin
		AND b.origen = "S"
		GROUP BY h.puesto,h.ejecutivo
		ORDER BY h.puesto,h.ejecutivo		
			
			LET dPorcCanceladas	=0;
			LET dPorcRechazadas	=0;
			LET dPorcAutorizados=0;
			LET dPorcAtendidas  =0;
			
			--Se obtiene el nombre del ejecutivo
			SELECT nombre
			INTO cNombre
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo=cEjecutivo;
			--Se obtiene la descripcion del puesto del ejecutivo
			SELECT descripcion_puesto
			INTO cDescripcion
			FROM bdicred:"informix".sd_puestos_cac_aumlincred
			WHERE puesto=cPuesto;
			
			--Calculo para obtener los porcentajes de las solicitudes atendidas,  canceladas, rechazadas y autorizadas. 
			IF NVL(iTotalPerfil,0) <> 0 THEN
			LET dPorcAtendidas = ((iTotalPerfil * 100) / iTotalReg);
			--Total
			LET iTotalTotalPerfil = iTotalTotalPerfil + iTotalPerfil;
			
			END IF;
			IF NVL(iCanceladas,0) <> 0 THEN
				LET dPorcCanceladas = ((iCanceladas * 100) / iTotalPerfil);
				--Total
				LET iTotalCanceladas = iTotalCanceladas + iCanceladas;
				
			END IF;
			IF NVL(iRechazadas,0) <> 0 THEN
				LET dPorcRechazadas	= ((iRechazadas * 100) / iTotalPerfil);
				--Total
				LET iTotalRechazadas = iTotalRechazadas + iRechazadas;
				
			END IF;
			IF NVL(iAutorizadas,0) <> 0 THEN
				LET dPorcAutorizados =((iAutorizadas * 100) / iTotalPerfil);
				--Total
				LET iTotalAutorizadas = iTotalAutorizadas + iAutorizadas;
				
			END IF;						
			
			LET dTotalPorcAtendidas = ((iTotalTotalPerfil * 100) / iTotalTotalPerfil); 
			LET dTotalPorcCanceladas = ((iTotalCanceladas * 100) / iTotalTotalPerfil);
			LET dTotalPorcRechazadas = ((iTotalRechazadas * 100) / iTotalTotalPerfil); 
			LET dTotalPorcAutorizados = ((iTotalAutorizadas * 100) / iTotalTotalPerfil);
			
			RETURN cCodRet, cMensajeRet,NVL(cEjecutivo,""),NVL(cNombre,""),NVL(cDescripcion,""),NVL(iTotalPerfil,0),NVL(dPorcAtendidas,0),NVL(iCanceladas,0),NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
				NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0) WITH RESUME;
		
	END FOREACH;	
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para obtener los registros para el reporte por perfil de usuario en un periodo de fecha',
'AUTOR: MARIA ELENA ANGULO AISPURO, HECTOR MANUEL BOJORQUEZ RUELAS',
'FECHA: SEPTIEMBRE 2011',
'VERSION: 20111021.0902',
'BD: BDICRED',
'----------------------------------------------------------------------------------',
'Autor: Daniel Lazalde',
'Modificación: Se agregan los totales de las atendidas, autorizadas, canceladas y rechazadas',
'Fecha de modificación: 08/Febrero/2014',
'BD : bdicred',
'----------------------------------------------------------------------------------';

create procedure "informix".sp_depura_incrementos()
--execute procedure sp_depura_incrementos()
RETURNING   CHAR(6) 	AS retorno,
            CHAR(100)   AS mensaje_ret;
			
DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr         	INTEGER;
DEFINE cErrorInfo       	CHAR(100);
DEFINE cCodRet          	CHAR(6);
DEFINE cMensajeRet    		CHAR(100);	

DEFINE vnum_credito        	CHAR(12);	
DEFINE vnum_cte     		VARCHAR(20);	
DEFINE vstatus				CHAR(2);	
DEFINE fh_inicio			char(19);DEFINE fh_fin				char(19);DEFINE vfecha				DATE;

LET cCodRet = "000000";
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";

LET vnum_credito			="";
LET vnum_cte				="";
LET vstatus					="";
LET fh_inicio				=date(1);
LET fh_fin					=date(1);
LET vfecha					=date(1);

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr , cErrorInfo
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;  
      RETURN cCodRet, cMensajeRet;
END EXCEPTION;


--SET DEBUG FILE TO "/RESPALDOS/ipcb/pruebas/sp_depura_incrementos.out";
--TRACE ON; 

set isolation to dirty read;
set lock mode to wait 3;

SELECT num_solicitud,fecha_insert
FROM bdicred:sd_bitacora_aumlincred 
WHERE status = 'RT' AND fecha_insert = mdy('12','10','2015') AND origen = 'C' 
INTO TEMP tot_creditos  WITH NO LOG;

CREATE INDEX idx_totcreditos ON tot_creditos (num_solicitud);	
update statistics medium for table tot_creditos;		

select first 1 today||" "||current HOUR TO SECOND   INTO fh_inicio
from systables;

  foreach with hold
    SELECT num_solicitud,fecha_insert INTO  vnum_credito, vfecha
	FROM tot_creditos

    begin;
		DELETE FROM "informix".sd_autorizacion_aumlincred WHERE num_solicitud = vnum_credito  AND fecha_insert  = vfecha;
		DELETE FROM "informix".sd_clientes_clean_behavior WHERE fecha_reporte  = vfecha AND num_credito = vnum_credito;
		DELETE FROM "informix".sd_bitacora_aumlincred WHERE empresa="001" AND num_solicitud = vnum_credito AND status = "RT" AND fecha_insert  = vfecha;
	commit;	
  END FOREACH

select first 1 today||" "||current HOUR TO SECOND   INTO fh_fin
from systables;

LET cCodRet     = "00000";
LET cMensajeRet = "DEPURA INCREMENTOS INICIO:"||fh_inicio ||" FIN:"||fh_fin;

RETURN cCodRet, cMensajeRet; 
END;
END PROCEDURE;