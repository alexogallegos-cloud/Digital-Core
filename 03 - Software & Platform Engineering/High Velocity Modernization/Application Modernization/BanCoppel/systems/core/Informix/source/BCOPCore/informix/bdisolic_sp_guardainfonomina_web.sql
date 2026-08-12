CREATE PROCEDURE "informix".sp_guardainfonomina_web(pEmpresa CHAR(3), 
												pNum_solicitud  CHAR(20),
												pNumcte CHAR(20),
												pPromedio_mensual DECIMAL(18,2),
												pMaximo_sol DECIMAL(18,2),
												pCuenta CHAR(20),
												pFrecuencia INTEGER,
												pDiaPago INTEGER
												)
RETURNING 	CHAR(6)   AS CodRetorno,  	-- Codigo de retorno
            CHAR(80)  AS Mensaje_Retorno; -- Mensaje de retorno	  
		  
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
-- Variables de control de errores
DEFINE isqlerr      	INTEGER;
DEFINE iIsamError         INTEGER;
DEFINE cErrorInfo       CHAR(80);

-- Variables para valores de retorno
DEFINE cCodRet     		CHAR(5); 	      -- CÃ³digo de retorno de error
DEFINE cMens_Ret        CHAR(80);         -- Mensajes de error
-- ****************************************************************************
-- *           ASIGNACION DE VALORES POR DEFAULT A VARIABLES                  *
-- ****************************************************************************
LET isqlerr     		= 0;
LET iIsamError            = 0;
LET cErrorInfo          = "";

LET cCodRet     		= "00000";
LET cMens_Ret           = "Proceso realizado con exito";

BEGIN
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
      LET cCodRet= iSqlErr;
	  LET cMens_Ret= cErrorInfo;
      RETURN cCodRet,  '' ;
END EXCEPTION;

--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_guardainfonomina.out';
--TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
 
	IF NVL(pEmpresa,'') = '' OR NVL(pNum_solicitud,'') = '' OR NVL(pNumcte,'') = '' OR NVL(pPromedio_mensual,0) = 0 
	OR NVL(pMaximo_sol,0) = 0 OR NVL(pCuenta,'') = '' OR NVL(pFrecuencia,0) = 0 OR NVL(pDiaPago,0) = 0 THEN
		LET cCodRet     = "00001";  --Faltan parametros de entrada
		LET cMens_Ret = 'PARAMETROS INVALIDOS';
		RETURN cCodRet, '' ;
	END IF;	

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;	
	
	INSERT INTO "informix".ss_sol_nomina 
	(empresa, num_solicitud, numcte, promedio_mes, maximo_solic, cuenta, frecuencia_pgo, dia_pago, fecha_insert, user_insert) 
	VALUES (pEmpresa,pNum_solicitud,pNumcte,pPromedio_mensual,pMaximo_sol,pCuenta,pFrecuencia,pDiaPago, TODAY,USER);
	
	RETURN cCodRet,cMens_Ret;
	
END;

END PROCEDURE
