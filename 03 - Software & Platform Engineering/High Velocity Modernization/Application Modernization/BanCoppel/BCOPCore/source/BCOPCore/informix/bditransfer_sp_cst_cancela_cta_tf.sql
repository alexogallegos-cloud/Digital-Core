CREATE PROCEDURE "informix".sp_cst_cancela_cta_tf ()

RETURNING 	CHAR(5) 	AS cCodRet,
		CHAR(20) 	AS cserviceName,
		CHAR(4) 	AS ccountryCode,
		CHAR(4) 	AS cbankId,
		CHAR(4) 	AS caccessMethod,
		CHAR(20) 	AS cCuentaTf,
		CHAR (10) 	AS cidentifierType,	    			
	    CHAR(13) 	AS cTelefono;
			
	
			
---DECLARACION DE VARIABLES
DEFINE iSqlErr      	 	INTEGER;
DEFINE cCodRet      	 	CHAR(5);
DEFINE cserviceName 	 	CHAR(20);
DEFINE ccountryCode 		CHAR(4);
DEFINE cbankId     		CHAR(4);
DEFINE coriginatorTransactionId CHAR(50);
DEFINE caccessMethod        	CHAR(4);
DEFINE ccustomerIdentifier      CHAR(3);
DEFINE cidentifierType    	CHAR(10);
DEFINE cCuentaTf    		CHAR(20);
DEFINE cTelefono	   	CHAR(13);
DEFINE dFecCancelac		CHAR(12);

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '0000';
LET cserviceName        = 'getCustomerData';    
LET ccountryCode 	= '484';    
LET cbankId         = '137';
LET coriginatorTransactionId = '';
LET caccessMethod 	= '102';    
LET ccustomerIdentifier = '';    
LET cidentifierType     = '104';    
LET cCuentaTf     	= '';    
LET cTelefono		= '';
LET dFecCancelac	= '';


BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, '','','','','','','';
		END IF;
	END EXCEPTION;
	
		
	--SET DEBUG FILE TO '/informix/mijail/sp_valida_curp.out';
	--TRACE ON;
	
	
	SET LOCK MODE TO WAIT 3;
	
		FOREACH WITH HOLD
		
					SELECT fec_cancelac,cuenta_tf,telefono
		INTO dFecCancelac,cCuentaTf,cTelefono
		FROM bditransfer:"informix".tf_maecte
		WHERE status_cta = '2' 
			
			RETURN cCodret,trim(cserviceName),trim(ccountryCode),trim(cbankId),trim(caccessMethod),trim(cCuentaTf),trim(cidentifierType),cTelefono WITH RESUME;
			
		END FOREACH;		
					
			RETURN cCodRet, '','','','','','','';


END;			
END PROCEDURE;