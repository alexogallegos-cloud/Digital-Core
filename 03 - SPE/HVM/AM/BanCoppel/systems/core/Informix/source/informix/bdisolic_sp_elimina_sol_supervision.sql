CREATE PROCEDURE "informix".sp_elimina_sol_supervision(pEmpresa CHAR(3), pEjecutivo CHAR(9))
RETURNING CHAR(6)  AS codigo_retorno,
          VARCHAR(80,1) AS mensaje_retorno; 
---DECLARACIONES
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      VARCHAR(80,1);
DEFINE cComentario      VARCHAR(80,1);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       VARCHAR(80,1);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizó la eliminación correctamente";
       
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
     RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO 'sp_elimina_sol_supervision.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


IF TRIM(NVL(pEmpresa,'')) = '' OR TRIM(NVL(pEmpresa,'')) = '' THEN
	LET cCodRet = "000001";
	LET cMensajeRet = 'La ejecución no se realizó correctamente';
	RETURN cCodRet, cMensajeRet;
END IF;

DELETE FROM bdisolic:"informix".ss_solsuperv_paso
 WHERE user_insert = pEjecutivo
   AND empresa = pEmpresa;
	
END
END PROCEDURE
