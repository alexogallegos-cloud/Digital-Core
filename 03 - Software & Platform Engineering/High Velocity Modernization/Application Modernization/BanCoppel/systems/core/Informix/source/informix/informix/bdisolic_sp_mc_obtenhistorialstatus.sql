CREATE PROCEDURE "informix".sp_mc_obtenhistorialstatus(pEmpresa CHAR(3),pNumSol CHAR(20))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		  CHAR(2) AS status_solicitud,
		  DATE AS fecha_entrada,
		  DATE AS fecha_salida;
		  
		  
---DECLARACIONES
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cComentario      CHAR(80);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cStatusSol		CHAR(2);
DEFINE dtFechaEntrada	DATE;
DEFINE dtFechaSalida	DATE;

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizó la consulta correctamente";
LET cStatusSol			= "";
LET dtFechaEntrada      = DATE(1);
LET dtFechaSalida       = DATE(1);

       
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo   
     LET cCodRet= iSqlErr;
     RETURN cCodRet, cMensajeRet,cStatusSol,dtFechaEntrada,dtFechaSalida; 
END EXCEPTION;


    --SET DEBUG FILE TO '/informix/jesus/sp_mc_obtenhistorialstatus.out';
	--TRACE ON;

		  --CONTROL DE ERRORES POR PARAMETRO--
 IF NVL(pEmpresa, '' ) = '' OR NVL(pNumSol,'')= ''  THEN
	LET cCodret = '000001';
	LET cMensajeRet = 'PARAMETROS DE ENTRADA INVALIDOS'; 
	RETURN cCodRet, cMensajeRet,cStatusSol,dtFechaEntrada,dtFechaSalida; 
 END IF;
	 
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

  FOREACH
	SELECT status_solicitud,fecha_entrada,fecha_salida	       
	  INTO cStatusSol,dtFechaEntrada,dtFechaSalida
    FROM "informix".ss_autorizacion 
    WHERE empresa = pEmpresa
    AND num_solicitud = pNumSol
	ORDER BY rowid
	
	 RETURN cCodRet, cMensajeRet,cStatusSol,dtFechaEntrada,dtFechaSalida WITH RESUME;   
	 
  END FOREACH;	
  IF DBINFO('sqlca.sqlerrd2') = 0 THEN
	LET cCodRet             = "000001";
	LET cMensajeRet         = "No se encontro información, verifique...";
	RETURN cCodRet, cMensajeRet,cStatusSol,dtFechaEntrada,dtFechaSalida; 
  END IF;
	
END
END PROCEDURE
