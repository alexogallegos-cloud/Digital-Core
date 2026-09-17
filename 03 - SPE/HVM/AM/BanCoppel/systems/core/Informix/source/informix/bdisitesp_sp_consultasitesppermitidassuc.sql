CREATE PROCEDURE "informix".sp_consultasitesppermitidassuc(cCatalogo CHAR(1), cEmpresa CHAR(3), cEjecutivo CHAR(8), cSituacionEsp CHAR(1),
	siCausas SMALLINT, siRegistros SMALLINT)

	RETURNING CHAR(5), CHAR(1), CHAR(1), CHAR(1), SMALLINT, CHAR(75)

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cDepartamento CHAR(3);
	DEFINE iArea INTEGER;
	DEFINE cSustituir CHAR(1);
	DEFINE cEliminar CHAR(1);
	DEFINE cSitEsp CHAR(1); 
	DEFINE siCausa SMALLINT;
	DEFINE cDescripcion CHAR(75);
	DEFINE siContReg SMALLINT;

	LET cCodRet = "000";
	LET iSqlErr = 0;
	LET cDepartamento = "";
	LET iArea = 0;
	LET cSustituir = "";
	LET cEliminar = "";
	LET cSitEsp = ""; 
	LET siCausa = 0;
	LET cDescripcion = "";
	LET siContReg = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cSustituir, cEliminar, cSitEsp, siCausa, cDescripcion;
		END EXCEPTION;

		--SET DEBUG FILE TO "/respaldos/sp_ConsultaSitEspPermitidasSuc.out";
		--TRACE ON;

		IF NVL(cEmpresa, "") = "" OR NVL(cEjecutivo, "") = "" THEN
			LET cCodRet = "001";
			RETURN cCodRet, cSustituir, cEliminar, cSitEsp, siCausa, cDescripcion;
		END IF;

		IF EXISTS(SELECT 1 FROM bdinteg:si_ejecut WHERE ejecutivo = TRIM(cEjecutivo)) THEN
			SELECT departamento INTO cDepartamento FROM bdinteg:si_ejecut WHERE ejecutivo = TRIM(cEjecutivo);
			
			IF EXISTS(SELECT 1 FROM bdisitesp:se_areas WHERE departamento = TRIM(cDepartamento)) THEN
				SELECT idarea INTO iArea FROM bdisitesp:se_areas WHERE departamento = TRIM(cDepartamento);
				
				IF NOT EXISTS(SELECT 1 FROM bdisitesp:se_logicaacceso WHERE empresa = TRIM(cEmpresa) AND idarea= iArea) THEN
					LET cCodRet = "004"; -- El usuario no tiene permiso de acceso
					RETURN cCodRet, cSustituir, cEliminar, cSitEsp, siCausa, cDescripcion;
				END IF;
			ELSE
				LET cCodRet = "003"; -- No existe el area del usuario
				RETURN cCodRet, cSustituir, cEliminar, cSitEsp, siCausa, cDescripcion;
			END IF;
		ELSE
			LET cCodRet = "002"; -- No existe el usuario
			RETURN cCodRet, cSustituir, cEliminar, cSitEsp, siCausa, cDescripcion;
		END IF;

		IF cSituacionEsp <> "" AND siCausas <> 0 THEN
			IF NOT EXISTS(SELECT 1 FROM bdisitesp:se_logicasustit a
				INNER JOIN bdisitesp:se_catsitesp b ON ( a.sitsiguente = b.situacion AND a.causasiguiente = b.causa AND a.empresa = b.empresa)
				WHERE a.empresa = cEmpresa AND a.situacion = cSituacionEsp AND a.causa = siCausas AND b.alcance IN (0, 2)) THEN

				IF NOT EXISTS(SELECT 1 FROM bdisitesp:se_logicaacceso a
					INNER JOIN bdisitesp:se_catsitesp b ON(a.empresa = b.empresa AND a.situacion = b.situacion AND a.causa = b.causa)
					WHERE a.empresa = cEmpresa AND idarea = iArea AND a.situacion = cSituacionEsp AND a.causa = siCausas AND b.alcance IN (0, 2)
					AND idtipomov = 'E') THEN

					LET cCodRet = "005"; -- La situacion especial y causa actual no pueden ser cambiadas
					RETURN cCodRet, cSustituir, cEliminar, cSitEsp, siCausa, cDescripcion;
				ELSE
					--DSB 21/05/2010
					LET cEliminar = "1"; --  La situacion especial y causa actual permite eliminar
				END IF
			ELSE
				IF EXISTS(SELECT 1 FROM bdisitesp:se_logicaacceso a
					INNER JOIN bdisitesp:se_catsitesp b ON(a.empresa = b.empresa AND a.situacion = b.situacion AND a.causa = b.causa)
					WHERE a.empresa = cEmpresa AND idarea = iArea AND a.situacion = cSituacionEsp AND a.causa = siCausas AND b.alcance IN (0, 2)
					AND idtipomov = 'S') THEN
					LET cSustituir = "1"; --  La situacion especial y causa actual permite sustituir
				END IF;
				IF EXISTS(SELECT 1 FROM bdisitesp:se_logicaacceso a
					INNER JOIN bdisitesp:se_catsitesp b ON(a.empresa = b.empresa AND a.situacion = b.situacion AND a.causa = b.causa)
					WHERE a.empresa = cEmpresa AND idarea = iArea AND a.situacion = cSituacionEsp AND a.causa = siCausas AND b.alcance IN (0, 2)
					AND idtipomov = 'E') THEN
					LET cEliminar = "1"; --  La situacion especial y causa actual permite eliminar
				END IF;
			END IF;
			RETURN cCodRet, cSustituir, cEliminar, cSitEsp, siCausa, cDescripcion;
		ELSE		
			-- Obtener Situaciones Especiales permitidas para la Sucursal
			IF cCatalogo = "1" THEN
				FOREACH
					SELECT DISTINCT a.situacion
					INTO cSitEsp
					FROM bdisitesp:se_logicaacceso a
					INNER JOIN bdisitesp:se_catsitesp b ON (a.empresa = b.empresa AND a.situacion = b.situacion AND a.causa = b.causa)
					WHERE a.empresa = cEmpresa AND a.idarea = iArea AND b.alcance IN (0, 2) AND idtipomov = 'M'
					ORDER BY a.situacion

					LET siContReg = siContReg + 1;
					IF siContReg <= siRegistros THEN
						CONTINUE FOREACH;
					END IF;
					RETURN cCodRet, cSustituir, cEliminar, cSitEsp, siCausa, cDescripcion WITH RESUME;
				END FOREACH;
				
			-- Obtener Causas permitidas para la Sucursal
			ELIF cCatalogo = "2" THEN
				FOREACH
					SELECT DISTINCT a.situacion, a.causa, b.descripcion
					INTO cSitEsp, siCausa, cDescripcion
					FROM bdisitesp:se_logicaacceso a
					INNER JOIN bdisitesp:se_catsitesp b ON (a.empresa = b.empresa AND a.situacion = b.situacion AND a.causa = b.causa)
					WHERE a.empresa = cEmpresa AND a.idarea = iArea AND a.situacion = cSituacionEsp AND b.alcance IN (0, 2) AND idtipomov = 'M'
					ORDER BY a.situacion, a.causa

					LET siContReg = siContReg + 1;
					IF siContReg <= siRegistros THEN
						CONTINUE FOREACH;
					END IF;
					RETURN cCodRet, cSustituir, cEliminar, cSitEsp, siCausa, cDescripcion WITH RESUME;
				END FOREACH;
			END IF;
		END IF;
	END
END PROCEDURE
