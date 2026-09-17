CREATE PROCEDURE "informix".sp_consulta_doctos_admin_web(pEmpresa CHAR(3),pSucursal CHAR(4),pNumeroCaja CHAR(10),pTipo INTEGER,pRegistro INTEGER)
--DATOS A REGRESAR---
RETURNING	CHAR(5) AS cCodRet,
			SMALLINT AS cTipoDocumento,
			CHAR(80) AS cDocumento,
			CHAR(1) AS cTipoEstatus,
			CHAR(20) AS cEstatus,
			CHAR(10) AS cFechaInicio,
			CHAR(10) AS cFechaFin;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet			CHAR(5);
DEFINE  cTipoEstatus	CHAR(1);
DEFINE  cDocumento		CHAR(80);
DEFINE  cEstatus		CHAR(20);
DEFINE  cFechaInicio	CHAR(10);
DEFINE  cFechaFin		CHAR(10);
DEFINE  cCaja			CHAR(10);
DEFINE  cTipoDistinto   SMALLINT;
DEFINE	iConteo			INTEGER;
DEFINE	cTipoDocumento	SMALLINT;
DEFINE  iSqlErr			INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet			= '00000';
LET cTipoEstatus	= '';
LET cDocumento		= '';
LET cEstatus		= '';
LET cFechaInicio	= '';
LET cFechaFin		= '';
LET cCaja			= '';
LET cTipoDistinto   = 0;
LET iConteo			= 0;
LET cTipoDocumento	= 0;
LET iSqlErr			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,cTipoDocumento,cDocumento,cTipoEstatus,cEstatus,cFechaInicio,cFechaFin;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/claudio/sp_consulta_doctos_admin.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pTipo,0) = 1 THEN
		IF NVL(pEmpresa,'') <> '' THEN

			FOREACH
				SELECT tipodocumento,descripcion INTO cTipoDocumento,cDocumento
				FROM bdisuc:"informix".ss_cattipodocumento
				WHERE empresa = pEmpresa

				LET iConteo = iConteo + 1;
				IF iConteo <= pRegistro THEN
					CONTINUE FOREACH;
				END IF;
				LET cTipoEstatus = 'N';
				LET cEstatus = 'No Registrado';

				RETURN cCodRet,cTipoDocumento,cDocumento,cTipoEstatus,cEstatus,cFechaInicio,cFechaFin WITH RESUME;
			END FOREACH;

			IF iConteo = 0 THEN
				LET cCodRet ='01309';
			END IF;
		ELSE
			LET cCodRet ='01308';
		END IF;
	ELIF NVL(pTipo,0) = 2 THEN
		IF NVL(pEmpresa,'') <> '' AND NVL(pSucursal,'') <> '' AND NVL(pNumeroCaja,'') <> '' THEN

				
			SELECT numerocaja, tipopaquete INTO cCaja, cTipoDistinto
			FROM bdisuc:"informix".ss_numcajas 
			WHERE empresa = pEmpresa AND numerocaja = pNumeroCaja;

			IF NVL(cCaja,'') = '' THEN
				LET cCodRet ='01320';
			ELIF cTipoDistinto <> 3 THEN
				LET cCodRet ='01334';
			ELSE
				FOREACH
					SELECT cat.tipodocumento,cat.descripcion,adm.estatus,adm.fechainicio,adm.fechafinal
					INTO cTipoDocumento,cDocumento,cTipoEstatus,cFechaInicio,cFechaFin
					FROM bdisuc:"informix".ss_cattipodocumento cat, OUTER bdisuc:"informix".ss_documentosadmon adm
					WHERE adm.numerocaja = pnumerocaja AND adm.sucursal = psucursal
					AND cat.tipodocumento = adm.tipodocumento

					LET iConteo = iConteo + 1;
					IF iConteo <= pRegistro THEN
						CONTINUE FOREACH;
					END IF;

					IF NVL(cTipoEstatus,'') = 'R' THEN
						LET cEstatus ='Registrado';
					ELIF NVL(cTipoEstatus,'') = 'C' THEN
						CONTINUE FOREACH;
					ELIF NVL(cTipoEstatus,'') = 'N' THEN
						LET cEstatus ='No Registrado';
					END IF;

					IF NVL(cFechaInicio,'') = '' THEN
						LET cFechaInicio ='';
					END IF;

					IF NVL(cFechaFin,'') = '' THEN
						LET cFechaFin ='';
					END IF;

					RETURN cCodRet,cTipoDocumento,cDocumento,cTipoEstatus,cEstatus,cFechaInicio,cFechaFin WITH RESUME;
				END FOREACH;

				IF iConteo = 0 THEN
					LET cCodRet ='01309';
				END IF;
			END IF;

		ELSE
			LET cCodRet ='01308';
		END IF;
	END IF;

	IF NVL(cCodRet,'') <> '00000' THEN
		RETURN cCodRet,cTipoDocumento,cDocumento,cTipoEstatus,cEstatus,cFechaInicio,cFechaFin;
	END IF;
END;
END PROCEDURE
DOCUMENT
'000000 - Retorna Sucursales',
'001308 - Parametros Incompletos',
'001309 - No Existe informacion',
'DESCRIPCION: Consulta documentos',
'AUTOR: Claudio Almodovar',
'Folio: 1759',
'Solicita: Rodolfo GÃ³mez',
'FECHA: 16/10/2015',
'BD: bdisuc';

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