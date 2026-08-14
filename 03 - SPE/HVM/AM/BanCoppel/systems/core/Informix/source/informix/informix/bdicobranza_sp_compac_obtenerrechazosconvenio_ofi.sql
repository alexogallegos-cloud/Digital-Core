CREATE PROCEDURE "informix".sp_compac_obtenerrechazosconvenio_ofi(pEmpresa char(3))
RETURNING CHAR(5)  AS Codigo_Retorno,
          CHAR(80) AS Mensaje_Retorno,
		  CHAR(100) AS Descripcion;   
		  
--definicion de variables
DEFINE cCodRet           CHAR(5); 
DEFINE cMensajeRet       CHAR(80);
DEFINE iSqlErr      	 INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE iCont	          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE vDescripcion      CHAR(100);


--inicializacion de variables	  
LET iSqlErr                  = 0;
LET iCont                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = '';
LET cCodRet                  = '';
LET cMensajeRet              = 'Se realizó la consulta correctamente';	  
LET vDescripcion              = '';	  
		  
		  
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet, cMensajeRet,vDescripcion;
   END IF;
END EXCEPTION;

--Set debug file to '/home/sysifx/jesusm/sp_debug_OFI.out';
--trace on;		  

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


FOREACH EXECUTE PROCEDURE sp_compac_obtenerrechazosconvenio(pEmpresa)
			into cCodRet,cMensajeRet,vDescripcion
			
	RETURN cCodRet, cMensajeRet,vDescripcion WITH RESUME;
END FOREACH;
END;
END PROCEDURE;