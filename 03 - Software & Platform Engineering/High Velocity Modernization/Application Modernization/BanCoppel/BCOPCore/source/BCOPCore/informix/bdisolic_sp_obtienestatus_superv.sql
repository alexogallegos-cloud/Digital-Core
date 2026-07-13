CREATE PROCEDURE "informix".sp_obtienestatus_superv(pEmpresa CHAR(3))
RETURNING CHAR(6)  AS codigo_retorno,
          VARCHAR(80,1) AS mensaje_retorno,	
		  CHAR(2) AS status,
		  VARCHAR(50,1) AS desc_status; 
---DECLARACIONES
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      VARCHAR(80,1);
DEFINE cComentario      VARCHAR(80,1);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       VARCHAR(80,1);
DEFINE cDescripcion		VARCHAR(50,1);
DEFINE cStatus			CHAR(2);
DEFINE iNumReg          INTEGER;

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizó la consulta correctamente";
LET cStatus				= "";
LET cDescripcion		= "";
LET iNumReg             = 0;
       
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
     RETURN cCodRet, cMensajeRet,cStatus,cDescripcion;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO 'sp_obtienestatus_superv.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

FOREACH
	SELECT status, TRIM(des_status)
	  INTO cStatus, cDescripcion
	  FROM  "informix".ss_catalogo_supervision
	 WHERE empresa = pEmpresa
	ORDER BY status	
				
	 RETURN cCodRet, cMensajeRet,cStatus,cDescripcion WITH RESUME;
END FOREACH;

LET iNumReg = dbinfo("sqlca.sqlerrd2");
IF iNumReg = 0 THEN
	LET cCodRet = "000001";
	LET cMensajeRet = 'No hay información para el filtro indicado';
	RETURN cCodRet, cMensajeRet,NVL(cStatus,''),NVL(cDescripcion,'');
END IF;
	
END
END PROCEDURE
