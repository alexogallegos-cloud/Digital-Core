CREATE PROCEDURE "informix".recibe_detalle_scoring_movil( pEmpresa CHAR(3), 
														pFolio CHAR(20),
														pSeccion SMALLINT, 
														pGrupo SMALLINT, 
														pElemento SMALLINT)
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;
		  
---DECLARACIONES
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cComentario      CHAR(80);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cDescripcion		CHAR(40);
DEFINE cStatus			CHAR(2);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizó la consulta correctamente";
LET cStatus				= "";
LET cDescripcion		= "";
       
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo   
     LET cCodRet= iSqlErr;
     RETURN cCodRet, cMensajeRet;   
END EXCEPTION;

--SET DEBUG FILE TO 'recibe_detalle_scoring_movil.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


	IF NVL(pEmpresa,'') ='' OR  NVL(pSeccion,'') ='' OR NVL(pGrupo,'') ='' OR NVL(pElemento,'') ='' OR NVL(pFolio,'') ='' THEN
		LET cCodRet             = "000001";
		LET cMensajeRet         = "PARAMETROS DE ENTRADA INVALIDOS";
	ELSE
		---crear tabla
		INSERT INTO "informix".ss_detalle_scoring_movil (empresa,folio_movil, seccion, grupo, elemento,user_insert,fecha_insert )
		VALUES	 (pEmpresa, pFolio , pSeccion, pGrupo, pElemento,USER, today);
	END IF	
	
	RETURN cCodRet, cMensajeRet;   
	
END
END PROCEDURE
