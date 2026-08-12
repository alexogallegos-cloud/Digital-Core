CREATE PROCEDURE "informix".sp_valida_solicitud_movil(pEmpresa   CHAR(3),
                                                      pNumSolic  CHAR(20))
RETURNING CHAR(6)       AS codigo_retorno,
          VARCHAR(80,1) AS mensaje_retorno,
		  CHAR(20)      AS numero_solicitud,
          INTEGER       AS id_solicitud_movil;

DEFINE nrows           INTEGER;
DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cErrorInfo      VARCHAR(80,1);
DEFINE cCodRet         CHAR(6);
DEFINE cMensajeRet     VARCHAR(80,1);

DEFINE cEmpresa        CHAR(3);
DEFINE cNumSolicitud   CHAR(20);
DEFINE iSolicMovil     INTEGER;

LET nrows              = 0;
LET iSqlErr            = 0;
LET iIsamErr           = 0;
LET cErrorInfo         = '';
LET cCodRet            = '000000';
LET cMensajeRet        = 'Se realizó la consulta de solicitud correctamente.';

LET cEmpresa           = '';
LET cNumSolicitud      = '';
LET iSolicMovil        = 0;

--SET DEBUG FILE TO '/tmp/sp_valida_solicitud_movil.out';
--TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = 'Ocurrió error al validar la solicitud movil '||' - '||cErrorInfo;
      RETURN cCodRet, cMensajeRet, cNumSolicitud, NVL(iSolicMovil,0);
    END IF;
END EXCEPTION;

IF NVL(pEmpresa,'') = '' THEN
  LET pEmpresa = NULL;
  LET cEmpresa= '';
ELSE
  LET cEmpresa= TRIM(pEmpresa);
END IF;

IF NVL(pNumSolic,'') = '' THEN
  LET pNumSolic = NULL;
  LET cNumSolicitud= '';
ELSE
  LET cNumSolicitud = TRIM(pNumSolic);
END IF;

IF pEmpresa IS NULL AND pNumSolic IS NULL THEN
   LET cCodRet= '000001';
   LET cMensajeRet= 'No hay información para realizar la consulta';
   RETURN cCodRet, cMensajeRet, cNumSolicitud, NVL(iSolicMovil,0);
END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT LIMIT 1 1 
  INTO iSolicMovil
  FROM "informix".ss_solicitudes_movil 
 WHERE num_solicitud = cNumSolicitud 
   AND empresa = cEmpresa;

IF iSolicMovil IS NULL THEN
 LET iSolicMovil = 0;
END IF;

RETURN cCodRet, cMensajeRet, cNumSolicitud, NVL(iSolicMovil,0);

END
END PROCEDURE
