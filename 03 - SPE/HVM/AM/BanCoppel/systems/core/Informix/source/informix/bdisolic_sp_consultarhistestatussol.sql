CREATE PROCEDURE "informix".sp_consultarhistestatussol(pEmpresa     CHAR(3),
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
DEFINE cnumsolacreditado  CHAR(20);

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
LET cnumsolacreditado = "";

--SET DEBUG FILE TO "/tmp/sp_consultarhistestatussol.out";
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

		  --AAME RQM 10 1177 Empaquetamiento de prèstamos contemplar solicitud de titular en solicitud de obligado
		  IF substr(pSolicitud,1,4) IN ('9200','9400','9600') THEN
			SELECT first 1 a.num_solicitud
			INTO cnumsolacreditado
			FROM bdinteg:"informix".si_refclientes a
			INNER JOIN bdisolic:"informix".ss_solicitudes b ON (a.empresa = b.empresa AND a.numcte = b.numcte AND a.num_solicitud = b.num_solicitud)
			INNER JOIN bdisolic:ss_refpersonales c ON (b.empresa = c.empresa AND b.numcte = c.numcte AND b.num_solicitud = c.num_solicitud AND c.numcte_ref  like 'R3%')
			WHERE b.empresa =pEmpresa AND a.numcte_ref = pSolicitud;

			LET cComentario = TRIM(cComentario) || " / Sol. Acreditado: " || NVL(TRIM(cnumsolacreditado),' ');

		  END IF;
        SELECT nombre
          INTO cNombreEjecut
          FROM bdinteg:"informix".si_ejecut
         WHERE empresa = pEmpresa
           AND ejecutivo = cEjecutivo;

   RETURN cCodRet,cMensajeRet,NVL(CStatusAnt,""), NVL(StatusNvo,""),NVL(cComentario,""), NVL(cNombreEjecut,"") WITH RESUME;

END FOREACH;

IF substr(pSolicitud,1,4) IN ('9200','9400','9600')  AND DBINFO("sqlca.sqlerrd2") = 0 THEN
			  --AAME RQM 10 1177 Empaquetamiento de prèstamos contemplar solicitud de titular en solicitud de obligado
	/*FOREACH
			SELECT status_solicitud, comentario
			INTO CStatusAnt,cComentario 
			  FROM bdisolic:"informix".ss_autorizacion
			 WHERE empresa = pEmpresa
			   AND num_solicitud = pSolicitud		   
		  ORDER BY fecha_hora ASC*/


			  --IF substr(pSolicitud,1,4) IN ('9200','9400','9600') THEN
				SELECT first 1 a.num_solicitud
				INTO cnumsolacreditado
				FROM bdinteg:"informix".si_refclientes a
				INNER JOIN bdisolic:"informix".ss_solicitudes b ON (a.empresa = b.empresa AND a.numcte = b.numcte AND a.num_solicitud = b.num_solicitud)
				INNER JOIN bdisolic:ss_refpersonales c ON (b.empresa = c.empresa AND b.numcte = c.numcte AND b.num_solicitud = c.num_solicitud AND c.numcte_ref like 'R3%')
				WHERE b.empresa =pEmpresa AND a.numcte_ref = pSolicitud;

				LET cComentario = TRIM(cComentario) || "Sol. Acreditado: " || NVL(TRIM(cnumsolacreditado),' ');

			 -- END IF;
			SELECT nombre
			  INTO cNombreEjecut
			  FROM bdinteg:"informix".si_ejecut
			 WHERE empresa = pEmpresa
			   AND ejecutivo = cEjecutivo;

	   RETURN cCodRet,cMensajeRet,NVL(CStatusAnt,""), NVL(StatusNvo,""),NVL(cComentario,""), NVL(cNombreEjecut,"") ;

	--END FOREACH;

ENd IF;

IF DBINFO("sqlca.sqlerrd2") = 0 THEN
    LET cCodRet = "000003";
    LET cMensajeRet = "La solicitud indicada no presenta historial de cambio de estatus.";
    RETURN cCodRet,cMensajeRet,NVL(CStatusAnt,""), NVL(StatusNvo,""),NVL(cComentario,""), NVL(cNombreEjecut,"");
END IF;

END 

END PROCEDURE
