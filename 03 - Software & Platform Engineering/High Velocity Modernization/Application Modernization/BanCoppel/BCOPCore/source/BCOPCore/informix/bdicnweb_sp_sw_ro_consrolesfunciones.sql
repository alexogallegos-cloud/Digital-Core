CREATE PROCEDURE "informix".sp_sw_ro_consrolesfunciones(pUsuarioC CHAR(8), pIdFunciON CHAR(10))
	RETURNING
		CHAR(5) AS codRet,
        INT AS idRolFuncion,
		CHAR(40) AS descripcion
	DEFINE cCodRet CHAR(5);
	DEFINE iIdRolFunciON INT;
	DEFINE cDescripciON CHAR(25);
	DEFINE iSqlErr INT;
	DEFINE iNoRows INT;
	LET cCodRet = '00000';
	LET iIdRolFunciON = 0;
	LET cDescripciON = '';
	LET iSqlErr = 0;
	BEGIN
		ON EXCEPTION SET iSqlErr
				IF iSqlErr <> 0 THEN
					LET cCodRet = iSqlErr;
					RETURN cCodRet, iIdRolFuncion, cDescripcion;
				END IF;
		END EXCEPTION;
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuarioC, pIdFunciON) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdRolFuncion, cDescripcion;
		END IF;
		-- VALIDACIONES DE ENTRADA
		IF pUsuarioC = ''OR  pIdFunciON = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdRolFuncion, cDescripcion;
		END IF;
		-- CONTAMOS EL NUMERO DE REGISTROS
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(*)
		INTO iNoRows
		FROM sw_ro_roles_funciones;
		IF iNoRows = 0 THEN LET cCodRet = '00017';
			RETURN cCodRet, iIdRolFuncion, cDescripcion;
		END IF;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT id_rolfuncion, desc_rolfuncion
			INTO iIdRolFuncion, cDescripcion
			FROM sw_ro_roles_funciones 
			WHERE status = '1'
			ORDER BY 1
			IF SQLCODE = 100 THEN
				LET cCodRet = '01001';
				RETURN cCodRet, iIdRolFuncion, cDescripcion;
			END IF;
			RETURN cCodRet, iIdRolFuncion, cDescripciON WITH resume;
		END FOREACH;
	END
END PROCEDURE;