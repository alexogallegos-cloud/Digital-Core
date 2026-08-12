CREATE PROCEDURE "informix".sp_guardainfoadn_web(pEmpresa CHAR(3), pNum_solicitud  CHAR(20),pNumcte CHAR(20),pCuenta CHAR(20),pFrecuencia INTEGER,pDiaPago INTEGER)
RETURNING 	CHAR(5)   AS CodRetorno;  	-- Codigo de retorno            
		  
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
-- Variables de control de errores
DEFINE isqlerr      	INTEGER;
DEFINE iIsamError         INTEGER;
DEFINE cErrorInfo       CHAR(80);

-- Variables para valores de retorno
DEFINE cCodRet     		CHAR(5); 	      -- CÃ³digo de retorno de error
-- ****************************************************************************
-- *           ASIGNACION DE VALORES POR DEFAULT A VARIABLES                  *
-- ****************************************************************************
LET isqlerr     		= 0;
LET iIsamError            = 0;
LET cErrorInfo          = "";

LET cCodRet     		= "00000";

BEGIN
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
      LET cCodRet= iSqlErr;
	  RETURN cCodRet ;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/jesus/sp_guardainfoadn.out';
--TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
 
	IF NVL(pEmpresa,'') = '' OR NVL(pNum_solicitud,'') = '' OR NVL(pNumcte,'') = ''  OR NVL(pCuenta,'') = '' OR NVL(pFrecuencia,0) = 0 OR NVL(pDiaPago,0) = 0 THEN
		LET cCodRet     = "00001";  --Faltan parametros de entrada		
		RETURN cCodRet;
	END IF;	

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;	
	
	UPDATE "informix".ss_adn_solicitudcuenta
		SET num_solicitud = pNum_solicitud ,
		frecuencia_pgo = pFrecuencia,
		dia_pago = pDiaPago
	WHERE numcte =pNumcte
	AND cuenta_nomina =pCuenta;
	
	RETURN cCodRet;
	
END;

END PROCEDURE
