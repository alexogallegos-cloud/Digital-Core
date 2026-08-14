CREATE PROCEDURE "informix".sp_consflagtdcoro_web(pempresa CHAR(3),pnumsolcred CHAR(20),pflagconfirma_oro CHAR (1),pnombre_embosado CHAR (21))
RETURNING CHAR(5)       AS codigo_retorno,
          SMALLINT  	AS flag_oro;
		  
DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(5);
DEFINE cMensajeRet   VARCHAR(100,1);
DEFINE cEmpresa      CHAR(3);
DEFINE vflagoro		 SMALLINT;

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '00000';
LET cMensajeRet   = 'Se realizÃÂ³ la consulta correctamente.';
LET cEmpresa      = '';
LET vflagoro	  = 0;

BEGIN 

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      RETURN cCodRet, NVL(vflagoro,0);
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_marcagraba_tdc_oro';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
INTO cEmpresa     
FROM bdinteg:"informix".si_empresas 
WHERE empresa= pempresa;

IF TRIM(NVL(cEmpresa,'')) = '' THEN
  LET cCodRet = '00001'; -- 'El parÃÂ¡metro no es valido';
  RETURN cCodRet, NVL(vflagoro,'');
END IF;

	IF  NVL(pflagconfirma_oro,'') <> '' OR NVL(pnombre_embosado,'') <> '' THEN 
	
			UPDATE "informix".ss_solicitudes_tdcoro 
			SET confirma_oro = pflagconfirma_oro
			WHERE empresa = pempresa 
			AND numero_solicitud = pnumsolcred;
			
	ELIF NVL(pnombre_embosado,'') <> '' THEN 
	
			UPDATE "informix".ss_solicitudes_tdcoro 
			SET nombre_embosado = pnombre_embosado
			WHERE empresa = pempresa 
			AND numero_solicitud = pnumsolcred;	
	ELSE 
			SELECT flag_oro
			INTO vflagoro
			FROM "informix".ss_solicitudes_tdcoro 
			WHERE empresa = pempresa 
			AND numero_solicitud = pnumsolcred;

	END IF;

	 RETURN cCodRet, NVL(vflagoro,0);

END
END PROCEDURE
