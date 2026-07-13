CREATE PROCEDURE "informix".sp_busca_sol_supervision
(pEmpresa CHAR(3), pEjecutivo CHAR(9),
pNumSolicitud  VARCHAR(20,1),
pNumCte        VARCHAR(20,1),
pFechaIni      DATE,
pFechaFin      DATE,
pStatus        CHAR(2),
pProducto      CHAR(4))
RETURNING
CHAR(6)         AS codigo_retorno,
VARCHAR(80,1)   AS mensaje_retorno,
VARCHAR(20,1)	AS Num_Solicitud,
VARCHAR(20,1)	AS Num_Cte,
VARCHAR(130,1)	AS Nombre_Cte,
DATE 			AS Fecha_Solicitud,
DATE 			AS Fecha_Cambio_Status,
CHAR(2) 		AS Status,
VARCHAR(8,1)    AS Respuesta_OS;

---DECLARACIONES
DEFINE cCodRet          CHAR(6);
DEFINE cMensajeRet      VARCHAR(80,1);
DEFINE cComentario      VARCHAR(80,1);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       VARCHAR(80,1);
DEFINE cCodRetAux       CHAR(6);
DEFINE cMensajeRetAux   VARCHAR(80,1);

DEFINE cNumSolic            VARCHAR(20,1);
DEFINE cNumCte              VARCHAR(20,1);
DEFINE cNomCte              VARCHAR(130,1);
DEFINE dtFechaSolic         DATE;
DEFINE dtFechaCambioSolic   DATE;
DEFINE cStatusSolic         CHAR(2);
DEFINE cSityCausa           VARCHAR(8,1);
DEFINE iNumReg              INTEGER;
DEFINE iCuantos             INTEGER;

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "Se asignaron las solicitudes correctamente";
LET cCodRetAux          = "";
LET cMensajeRetAux      = "";

LET cNumSolic           = '';
LET cNumCte             = '';
LET cNomCte             = '';
LET dtFechaSolic        = DATE(1);
LET dtFechaCambioSolic  = DATE(1);
LET cStatusSolic        = '';
LET cSityCausa          = '';
LET iNumReg             = 0;
LET iCuantos            = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
	 LET cMensajeRet = cErrorInfo;
     RETURN cCodRet, cMensajeRet, NVL(cNumSolic,''),NVL(cNumCte,''),NVL(cNomCte,''),NVL(dtFechaSolic,DATE(1)),
		NVL(dtFechaCambioSolic,DATE(1)),NVL(cStatusSolic,''),NVL(cSityCausa,'');
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO 'sp_busca_sol_supervision.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

IF TRIM(NVL(pEmpresa,'')) = '' OR TRIM(NVL(pEjecutivo,'')) = '' THEN
	LET cCodRet = "000001";
	LET cMensajeRet = 'La ejecución no se realizó correctamente';
	RETURN cCodRet, cMensajeRet, NVL(cNumSolic,''),NVL(cNumCte,''),NVL(cNomCte,''),NVL(dtFechaSolic,DATE(1)),
		NVL(dtFechaCambioSolic,DATE(1)),NVL(cStatusSolic,''),NVL(cSityCausa,'');
END IF;

SELECT valor INTO iCuantos
 FROM ss_param
WHERE empresa = pEmpresa
  AND secuencia = 384;

IF NVL(iCuantos,'0') = 0 THEN
	LET cCodRet = "000002";
	LET cMensajeRet = 'Parámetro no se encuentra definido';
	RETURN cCodRet, cMensajeRet, NVL(cNumSolic,''),NVL(cNumCte,''),NVL(cNomCte,''),NVL(dtFechaSolic,DATE(1)),
		NVL(dtFechaCambioSolic,DATE(1)),NVL(cStatusSolic,''),NVL(cSityCausa,'');
END IF;

EXECUTE PROCEDURE "informix".sp_elimina_sol_supervision(pEmpresa, pEjecutivo)
             INTO cCodRetAux, cMensajeRetAux;

IF cCodRetAux <> '00000' THEN
	LET cCodRet = "000003";
	LET cMensajeRet = 'No se eliminaron los registros correctamente';
	RETURN cCodRet, cMensajeRet, NVL(cNumSolic,''),NVL(cNumCte,''),NVL(cNomCte,''),NVL(dtFechaSolic,DATE(1)),
		NVL(dtFechaCambioSolic,DATE(1)),NVL(cStatusSolic,''),NVL(cSityCausa,'');
END IF;

FOREACH EXECUTE PROCEDURE bdicred:"informix".sp_consulta_supervision_mc
(pEmpresa,pNumSolicitud,pNumCte,pFechaIni,pFechaFin,pStatus,pProducto,0,iCuantos)
             INTO cCodRetAux ,cNumSolic,cNumCte,cNomCte,dtFechaSolic,dtFechaCambioSolic,cStatusSolic,cSityCausa

 IF cCodRetAux = '000000' THEN
		INSERT INTO ss_solsuperv_paso
			(empresa,numcte,num_solicitud,nombre_cte,fecha_solicitud,
			fecha_cambio,status,respuesta_os,
			user_insert,fecha_insert)
		VALUES
			(NVL(pEmpresa,''), NVL(cNumCte,''), NVL(cNumSolic,''), NVL(cNomCte,''), NVL(dtFechaSolic,DATE(1)),
			NVL(dtFechaCambioSolic,DATE(1)), NVL(cStatusSolic,''), NVL(cSityCausa,''),
			NVL(pEjecutivo,''),TODAY);

			RETURN cCodRet, cMensajeRet, NVL(cNumSolic,''),NVL(cNumCte,''),NVL(cNomCte,''),NVL(dtFechaSolic,DATE(1)),
			NVL(dtFechaCambioSolic,DATE(1)),NVL(cStatusSolic,''),NVL(cSityCausa,'') WITH RESUME;
 ELSE
	LET cCodRet = "000004";
	LET cMensajeRet = 'No hay solicitudes para asignar con el filtro indicado';
	RETURN cCodRet, cMensajeRet, NVL(cNumSolic,''),NVL(cNumCte,''),NVL(cNomCte,''),NVL(dtFechaSolic,DATE(1)),
		NVL(dtFechaCambioSolic,DATE(1)),NVL(cStatusSolic,''),NVL(cSityCausa,'');
 END IF;

END FOREACH;

SELECT LIMIT 1 1
  INTO iNumReg
  FROM ss_solsuperv_paso
 WHERE empresa = pEmpresa
   AND user_insert = pEjecutivo;

IF iNumReg = 0 THEN
	LET cCodRet = "000004";
	LET cMensajeRet = 'No hay solicitudes para asignar con el filtro indicado';
	RETURN cCodRet, cMensajeRet, NVL(cNumSolic,''),NVL(cNumCte,''),NVL(cNomCte,''),NVL(dtFechaSolic,DATE(1)),
		NVL(dtFechaCambioSolic,DATE(1)),NVL(cStatusSolic,''),NVL(cSityCausa,'');
END IF;

END
END PROCEDURE
