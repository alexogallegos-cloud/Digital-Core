CREATE PROCEDURE "informix".sp_compac_obtenerrechazosconvenio(pEmpresa char(3))
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
LET cCodRet                  = '00000';
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

--Set debug file to '/home/sysifx/jesusm/sp_debug.out';
--trace on;		  

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

IF pEmpresa IS NULL OR TRIM(pEmpresa) = "" THEN
    LET cCodRet                  = '00001';
	LET cMensajeRet              = 'El parametro Empresa no es valido';
    RETURN cCodRet, cMensajeRet,vDescripcion;
END IF;

FOREACH WITH HOLD
	SELECT descripcion 
	  INTO  vDescripcion
	  FROM bdicobranza:cb_param_campania
	 WHERE tipo_campania=10
	   AND grupo_parametro='MOTRCOMPAC'
	   AND empresa=pEmpresa	
	
	RETURN cCodRet, cMensajeRet,vDescripcion WITH RESUME;		
END FOREACH;

	LET iCont = dbinfo("sqlca.sqlerrd2");
	IF iCont = 0 THEN
		LET cCodRet = '00002';
		LET cMensajeRet = 'No se encontraron registros';
		RETURN cCodRet, cMensajeRet,vDescripcion;
	END IF;
	
END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener los motivos de rechazo para realizar un convenio de pago ',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 16/08/2010',
'BD    : BDICOBRANZA';

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