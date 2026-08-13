CREATE PROCEDURE "informix".sp_consultasolaltadirecta (pEmpresa CHAR(03),pSolicitud CHAR(20))
RETURNING CHAR(6),  -- Código de retorno
          CHAR(80), -- Mensaje de código
          CHAR(1),  -- Situacion especial
          SMALLINT; -- causa

DEFINE cSituacion       CHAR(1);
DEFINE sCausa           SMALLINT;
DEFINE cCodRet          CHAR(6);
DEFINE cMensajeRet      CHAR(80);
DEFINE sRegistro        SMALLINT;
DEFINE iSqlErr          INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);


LET cSituacion          = "";
LET sCausa              = 0;
LET cCodRet             = '000000';
LET cMensajeRet         = "Solicitud con Alta Directa";
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";

--SET DEBUG FILE TO '/tmp/consultasolaltadirecta.out';
--TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
       RETURN cCodRet, cMensajeRet, nvl(cSituacion, ""), nvl(sCausa,0);
   END IF;
END EXCEPTION;


IF nvl(pEmpresa,"") = "" OR nvl(pSolicitud,"") = "" THEN
    LET cCodRet = "000001";
    LET cMensajeRet = "Proceso no ejecutado. Información inválida";
    RETURN cCodRet, cMensajeRet, nvl(cSituacion, ""), nvl(sCausa,0);
END IF;

SELECT situacionespecial, causa
  INTO cSituacion, sCausa
  FROM "informix".ss_os_solautdirecta
 WHERE empresa = pEmpresa
   AND num_solicitud = pSolicitud;

LET sRegistro = dbinfo("sqlca.sqlerrd2");

IF sRegistro = 0 THEN
    LET cCodRet = '000002';
    LET cMensajeRet = 'La solicitud no fue alta automática.';
    RETURN cCodRet, cMensajeRet, nvl(cSituacion, ""), nvl(sCausa,0);
END IF;

RETURN cCodRet, cMensajeRet, nvl(cSituacion, ""), nvl(sCausa,0);

END
END PROCEDURE
