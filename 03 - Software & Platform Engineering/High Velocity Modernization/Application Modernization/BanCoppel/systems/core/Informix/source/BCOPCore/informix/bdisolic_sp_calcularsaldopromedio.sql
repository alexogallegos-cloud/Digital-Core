CREATE PROCEDURE "informix".sp_calcularsaldopromedio(pEmpresa CHAR(3), pCuenta  CHAR(20), pProducto CHAR(4))
RETURNING CHAR(5)  AS CODIGO,
		  DECIMAL(18,2) AS MONTO_PROMEDIO,
		  DECIMAL(18,2) AS MONTO_MAX_SOLICITUD;
		  
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
-- Variables de control de errores
DEFINE isqlerr      	INTEGER;

DEFINE cCodRet          CHAR(5);
DEFINE cFechaHoy   	    DATE;
DEFINE cFechaIni   	    DATE;
DEFINE cFechaFin   	    DATE;
DEFINE mMonto			DECIMAL(18,2);
DEFINE mMonto2			DECIMAL(18,2);
DEFINE dMontoMin		DECIMAL(18,2);
DEFINE cCodRet2 		CHAR(6);
DEFINE cCodRet3 		CHAR(6);
DEFINE dDiaprimero		DATE;
DEFINE dDiaUltimo		DATE;
DEFINE dDiaprimero2		DATE;
DEFINE dDiaUltimo2		DATE;
DEFINE  cMes 			CHAR(2);
DEFINE cAnio			CHAR(4);
DEFINE dMontoTopeSolicitud DECIMAL(18,2);
DEFINE mMontoMaxSolicitado DECIMAL(18,2);
DEFINE dMeses INTEGER;
DEFINE dmesprom INTEGER;  --FMV 24abr13: No. de mes para calcular sdo promedio.

-- ****************************************************************************
-- *           ASIGNACION DE VALORES POR DEFAULT A VARIABLES                  *
-- ****************************************************************************
LET isqlerr     		= 0;

LET cCodRet     		= "00000";
LET  cFechaHoy   	    = '';
LET cFechaIni   	    = '';
LET cFechaFin   	    = '';
LET mMonto				= 0;
LET mMonto2				= 0;
LET cCodRet2 			= '000000';
LET dDiaprimero			= '';
LET dDiaUltimo			= '';
LET dDiaprimero2		= '';
LET dDiaUltimo2			= '';
LET cCodRet3 			= '000000';
LET cMes = 0;
LET cAnio= 0;
LET dMontoTopeSolicitud = 0;
LET mMontoMaxSolicitado = 0;
LET dMeses = 0;
LET dmesprom = 0;

BEGIN
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

ON EXCEPTION SET iSqlErr
      LET cCodRet= iSqlErr;
	  RETURN cCodRet,0,0;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_calcularsaldopromedio.out';
--TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
	IF NVL(pEmpresa,"") = '' OR NVL(pCuenta,"") = ''OR NVL(pProducto,"") = ''  THEN
		LET cCodRet     = "00001";  --Faltan parametros de entrada
		RETURN cCodRet,0,0;
	END IF;
	
	--Obtiene la fecha actual
	SELECT fecha_hoy
	INTO cFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = pEmpresa;
	
		-- Extrae Valor de Parametro  MONTO MINIMO SALDO PROMEDIO DE CUENTA CAPTACION
	SELECT valor INTO dMontoMin
	  FROM "informix".ss_param
	 WHERE empresa = pEmpresa
	   AND secuencia = 30;
	   
	   IF NVL(dMontoMin,0) = 0 THEN
			LET cCodRet     = "00005";  --Faltan parametros  para realizar la consulta
			RETURN cCodRet,0,0;
	   END IF;

	 	-- Extrae Valor de Parametro NUMERO DE MESES PARA CALCULAR EL IMPORTE MAXIMO
	SELECT valor INTO dMeses
	  FROM "informix".ss_param
	 WHERE empresa = pEmpresa
	   AND secuencia = 31;
	   
	   IF NVL(dMeses,0) = 0 THEN
		LET cCodRet     = "00006";  --Faltan parametros  para realizar la consulta
		RETURN cCodRet,0,0;
	   END IF;  

  --FMV 24abr13: NO. DE MESES PARA CALCULAR DEPOSITOS PROMEDIO EN CREDINOMINA
	SELECT valor INTO dmesprom
	  FROM "informix".ss_param
	 WHERE empresa = pEmpresa
	   AND secuencia = 32;
	   
	   IF NVL(dmesprom,0) = 0 THEN
            LET cCodRet     = "00006";  --Faltan parametros  para realizar la consulta
            RETURN cCodRet,0,0;
	   END IF;  


	--Obtiene la fecha minima y maxima de un rango de 'dmesprom' meses anteriores 
	CALL bdicred:"informix".monthadd(cFechaHoy,-dmesprom) RETURNING cFechaIni;	
	CALL bdicred:"informix".monthadd(cFechaHoy,-1) RETURNING cFechaFin;	
		
	LET cMes = month(cFechaIni);
	LET cAnio= YEAR (cFechaIni);
	
	--Obtiene el primer dia del rango a consultar
	EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio (cMes, cAnio)
	INTO cCodRet2 , dDiaprimero, dDiaUltimo; 
		
	IF cCodRet2 <> '000000'	THEN
		LET cCodRet     = "00002";  
		RETURN cCodRet,0,0;
	END IF;
	LET cMes = 0;
	LET cAnio= 0;
	LET cMes = month(cFechaFin);
	LET cAnio= YEAR (cFechaFin);
	
	--Obtiene el ultimo dia del rango a consultar
	EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio (cMes, cAnio)
	INTO cCodRet3 , dDiaprimero2, dDiaUltimo2; 
	
	IF cCodRet3 <> '000000'	THEN
		LET cCodRet     = "00003";  
		RETURN cCodRet,0,0;
	END IF;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;	

    -- FMV 22-JUL-11 Se cambia el campo Cancelad de = N a <> S, para que filtre las operaciones correctas

	--Obtiene el total de los depositos de los ultimos 3 meses 
	SELECT SUM(monto_tot)
	INTO mMonto
	FROM bdicheq:"informix".sc_movhis mov
	INNER JOIN bdicred:"informix".sd_transvalprod  tran ON (tran.transacc = mov.transacc AND tran.activo = 1)
	WHERE cuenta = pCuenta
	AND cancelad <> 'S'
	AND fech_alt BETWEEN dDiaprimero AND dDiaUltimo2 ;	
	
	SELECT SUM(monto_tot)
	INTO mMonto2
	FROM bdicheq:"informix".sc_movhis_old mov
	INNER JOIN bdicred:"informix".sd_transvalprod  tran ON (tran.transacc = mov.transacc AND tran.activo = 1)
	WHERE cuenta = pCuenta
	AND cancelad <> 'S'
	AND fech_alt BETWEEN dDiaprimero AND dDiaUltimo2 ;
	
	--Obtiene el promedio de los depositos de 'dmesprom' ultimos meses
	
	LET mMonto = (NVL(mMonto,0) + NVL(mMonto2,0)) ;
	
	IF mMonto > 0 THEN			
		LET mMonto = mMonto/ dmesprom;	--FMV 24abr13: Se parametriza el promedio
	END IF;	
	--valida que el monto es mayor al minimo establecido, en caso contrario regresa un error controlado
	IF mMonto < dMontoMin THEN
		LET cCodRet     = "00004";  			
		RETURN cCodRet,0,0;
	END IF;	
--se obtiene el monto maximo para la solicitud
	SELECT monto_max_cred
		INTO dMontoTopeSolicitud
	FROM bdicred:"informix".sd_definicion
	WHERE empresa = pEmpresa
	AND num_producto = pProducto;
	
	LET mMontoMaxSolicitado = mMonto * dMeses;
	
	IF mMontoMaxSolicitado >  dMontoTopeSolicitud THEN
		LET mMontoMaxSolicitado = dMontoTopeSolicitud;
	END IF;
	
RETURN cCodRet,mMonto,mMontoMaxSolicitado;

END
END PROCEDURE
