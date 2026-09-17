CREATE PROCEDURE "informix".sp_consultarhistestatussol_pba(pEmpresa     CHAR(3),
                                                       pSolicitud   CHAR(20))

RETURNING  CHAR(6)          AS retorno,
            CHAR(100)       AS mensaje_ret,
            CHAR(2)         AS status_ant,
            CHAR(2)         AS status_nvo,
            VARCHAR(200)    AS justificacion,
            VARCHAR(104)    AS nombre_usuario;



DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   CHAR(100);

DEFINE cCodRet      CHAR(6);
DEFINE cMensajeRet  CHAR(100);

DEFINE CStatusAnt       CHAR(2);
DEFINE StatusNvo        CHAR(2);
DEFINE cComentario      VARCHAR(200); 
DEFINE cEjecutivo       CHAR(8);
DEFINE cNombreEjecut    VARCHAR(104);
DEFINE sExiste          SMALLINT;

LET iSqlErr     = 0;
LET iIsamErr    = 0;
LET cErrorInfo  = "";

LET cCodRet     = "000000";
LET cMensajeRet = "El proceso se realizó correctamente.";


LET CStatusAnt      = ""; 
LET StatusNvo       = "";
LET cComentario     = ""; 
LET cEjecutivo      = "";
LET cNombreEjecut   = "";
LET sExiste         = 0;

--SET DEBUG FILE TO "/home/sysifx/sp_consultarhistestatussol.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
      LET cCodRet = iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet,cMensajeRet,NVL(CStatusAnt,""), NVL(StatusNvo,""),NVL(cComentario,""), NVL(cNombreEjecut,"");
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

IF NVL(pEmpresa,"") = "" OR NVL(pSolicitud,"") = "" THEN
    LET cCodRet = "000001";
    LET cMensajeRet = "La información recibida no es correcta.";
    RETURN cCodRet,cMensajeRet,NVL(CStatusAnt,""), NVL(StatusNvo,""),NVL(cComentario,""), NVL(cNombreEjecut,"");
END IF;

SELECT COUNT(empresa)
  INTO sExiste
  FROM bdinteg:"informix".si_empresas
 WHERE empresa = pEmpresa;

IF sExiste = 0 THEN
    LET cCodRet = "000002";
    LET cMensajeRet = "La empresa indicada no es válida";
    RETURN cCodRet,cMensajeRet,NVL(CStatusAnt,""), NVL(StatusNvo,""),NVL(cComentario,""), NVL(cNombreEjecut,"");
END IF;

FOREACH

        SELECT status_ant, status_nvo,comentario,usuario_modif
          INTO CStatusAnt, StatusNvo,cComentario, cEjecutivo 
          FROM bdisolic:"informix".ss_autorizacion_especial
         WHERE empresa = pEmpresa
           AND num_solicitud = pSolicitud
      ORDER BY fecha_modif,secuencia ASC

        SELECT nombre
          INTO cNombreEjecut
          FROM bdinteg:"informix".si_ejecut
         WHERE empresa = pEmpresa
           AND ejecutivo = cEjecutivo;

   RETURN cCodRet,cMensajeRet,NVL(CStatusAnt,""), NVL(StatusNvo,""),NVL(cComentario,""), NVL(cNombreEjecut,"") WITH RESUME;

END FOREACH;

IF DBINFO("sqlca.sqlerrd2") = 0 THEN
    LET cCodRet = "000003";
    LET cMensajeRet = "La solicitud indicada no presenta historial de cambio de estatus.";
    RETURN cCodRet,cMensajeRet,NVL(CStatusAnt,""), NVL(StatusNvo,""),NVL(cComentario,""), NVL(cNombreEjecut,"");
END IF;

END 

END PROCEDURE
