CREATE PROCEDURE "informix".sp_consulta_suc_relacionadas_web(pEmpresa CHAR(3),pSucursal CHAR(4),pRegistro INTEGER)
--DATOS A REGRESAR---
RETURNING	CHAR(5) AS cCodRet,
			CHAR(4) AS cSucRelacionada,
			CHAR(10) AS cMatriz;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet			CHAR(5);
DEFINE  cSucRelacionada	CHAR(4);
DEFINE  cMatriz			CHAR(10);
DEFINE  iSqlErr			INTEGER;
DEFINE	iConteo			INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet			= '00000';
LET cSucRelacionada	= '';
LET cMatriz			= '';
LET iSqlErr			= 0;
LET iConteo			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,cSucRelacionada,cMatriz;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/tmp/jairo/sp_consulta_suc_relacionadas.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pSucursal,'') <> '' THEN

		SELECT sucursal INTO cSucRelacionada
		FROM bdinteg:"informix".si_sucursales
		WHERE empresa = pEmpresa AND sucursal = pSucursal;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '01309';
		ELSE

				SELECT LIMIT 1 sucursal_matriz INTO cSucRelacionada
				FROM bdisuc:"informix".ss_sucursalesrelacionadas
				WHERE empresa = pEmpresa
				AND sucursal_matriz = pSucursal AND status_relacion = 'A';

				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '01309';
				ELSE
					IF pRegistro = 0 THEN
						LET cMatriz = '';
						LET cMatriz = '(Matriz)';
						RETURN cCodRet,cSucRelacionada,cMatriz WITH RESUME;
					ELSE
						LET cMatriz = '';
					END IF;
				END IF;

			LET cMatriz = '';

			FOREACH
				SELECT sucursal_relacionada INTO cSucRelacionada
				FROM bdisuc:"informix".ss_sucursalesrelacionadas
				WHERE empresa = pEmpresa
				AND sucursal_matriz = pSucursal
				AND status_relacion = 'A'
				ORDER BY sucursal_relacionada ASC

				LET iConteo = iConteo + 1;
				IF iConteo <= pRegistro -1 THEN
					CONTINUE FOREACH;
				END IF;

				IF NVL(cSucRelacionada,'') = pSucursal THEN
					CONTINUE FOREACH;
				END IF;
				RETURN cCodRet,cSucRelacionada,cMatriz WITH RESUME;
			END FOREACH;

			IF iConteo = 0 THEN
				LET cCodRet ='00001';
			END IF;
		END IF;
	ELSE
		LET cCodRet ='01308';
	END IF;

	IF NVL(cCodRet,'') <> '00000' THEN
		RETURN cCodRet,cSucRelacionada,cMatriz;
	END IF;
END;
END PROCEDURE
;