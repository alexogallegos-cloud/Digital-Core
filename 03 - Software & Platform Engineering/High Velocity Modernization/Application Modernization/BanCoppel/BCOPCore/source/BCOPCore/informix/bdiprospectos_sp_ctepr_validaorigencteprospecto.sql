CREATE PROCEDURE "informix".sp_ctepr_validaorigencteprospecto(pCte CHAR(9))
RETURNING CHAR(6) AS cCodRet,
		  INTEGER AS iSolicCte,
		  INTEGER AS iEmpCob;
	
DEFINE iSqlErr			INTEGER;
DEFINE cCodRet			CHAR(6);
DEFINE cCteProspecto	CHAR(9);
DEFINE iEmpCob			INTEGER;
DEFINE iSolicCte		INTEGER;

LET iSqlErr				= 0;
LET	cCodRet 			= '000000';
LET	cCteProspecto 		= '';
LET	iEmpCob 			= 0;
LET	iSolicCte 			= 0;

BEGIN
	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iSolicCte, NVL(iEmpCob, 0);
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- SET DEBUG FILE TO "/respaldosbd/josue/sp_ctepr_validaorigencteprospecto.out";
	-- TRACE ON;
	
	-- VALIDACION DE LOS PARAMETROS.
	IF NVL(pCte, "") = "" THEN
		LET cCodRet = '000001';
		RETURN cCodRet, iSolicCte, NVL(iEmpCob, 0);
	END IF;
		
	-- CONSULTAMOS SI EL CLIENTE ES DE ORIGEN PROSPECTO.
	SELECT LIMIT 1 solic.numcte INTO cCteProspecto
	FROM bdisolic:"informix".ss_solicitudes solic
	INNER JOIN "informix".pr_cliente prcte ON (prcte.numcte = solic.numcte)
	WHERE solic.numcte = pCte;
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '000002'; -- NO EXISTE EL CLIENTE.
		RETURN cCodRet, iSolicCte, NVL(iEmpCob, 0);
	END IF;
	
	-- VERIFICAMOS SI EL CLIENTE TIENE SU ORIGEN DE ALTA MASIVA.
	SELECT LIMIT 1 prcte.id_empcob INTO iEmpCob
	FROM  "informix".pr_cliente prcte 
	INNER JOIN "informix".pr_monitorconcilia monitor ON (monitor.id_empcob = prcte.id_empcob) 
	WHERE prcte.numcte = cCteProspecto;
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '000002'; -- NO EXISTE EL CLIENTE.
		RETURN cCodRet, iSolicCte, NVL(iEmpCob, 0);
	END IF;
	
	-- VALIDAMOS SI EL CLIENTE PROSPECTO ES ORIGINADO DE ALTA MASIVA
	IF iEmpCob <> 0 THEN 
		
		SELECT COUNT(numcte) INTO iSolicCte
		FROM bdisolic:"informix".ss_solicitudes 
		WHERE numcte = pCte;
		
		LET cCodRet = '000000';
	ELSE
		LET cCodRet = '000003'; -- CLIENTE PROPECTO SIN IDENTIFICACION OFICIAL.
	END IF;
	
	RETURN cCodRet, iSolicCte, NVL(iEmpCob, 0);
	
END;
END PROCEDURE
