CREATE PROCEDURE "informix".sp_verifica_pre_aprobados(cNumCte CHAR(9),cNumSolicitud CHAR(12))
RETURNING  CHAR(6) As Retorno,
           CHAR(12) As Numero_Solicitud,
		   CHAR (1) As  Es_Preaprobado,
		   CHAR (9) As  NumCteCoppel;

DEFINE iSqlErr  	INTEGER;
DEFINE cCodRet  	CHAR(6);
DEFINE cSql			CHAR(1000);
DEFINE cSolicitud   CHAR(12);
DEFINE cUserInsert  CHAR(1);
DEFINE cNumCteCoppel CHAR(9);
DEFINE cNumCteTRX CHAR(9);

LET iSqlErr			= 0;
LET cCodRet 		= '000000'; --Se va '000000'
LET cSql 			= '';
LET cSolicitud      = '';
LET cUserInsert     = '';
LET cNumCteCoppel   = '';
LET cNumCteTRX		= '';


BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			RETURN cCodret,cSolicitud,cUserInsert,cNumCteCoppel;
		END IF;
	END EXCEPTION;

	 -- SET DEBUG FILE TO "/ifxsif01/tmp/sp_verifica_pre_aprobados.out";
	 -- TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF TRIM(NVL(cNumCte,'')) != '' AND TRIM(NVL(cNumSolicitud,'')) != '' THEN

		 SELECT FIRST 1 S.num_solicitud,CASE WHEN S.canal_sol IN ('6','7') THEN '1' ELSE '0' END,T.numctecoppel, T.numcte
		 INTO cSolicitud,cUserInsert,cNumCteCoppel, cNumCteTRX
		 FROM bdisolic:"informix".ss_solicitudes S
	     LEFT JOIN bdicred:"informix".sd_pre_aprobados_trx T ON S.num_solicitud = T.solicitud
		 WHERE S.numcte = cNumCte AND S.num_solicitud = cNumSolicitud;

		IF cUserInsert != '1' AND cNumCteTRX IS NULL THEN
		 LET cCodRet = '000001';
		ELIF cUserInsert = '1' AND cNumCteTRX IS NULL THEN
		 LET cCodRet = '000003';
		END IF;
	ELSE

		LET cCodret = '000002';

	END IF;

	RETURN cCodret,cSolicitud,cUserInsert,cNumCteCoppel;
END;
END PROCEDURE
