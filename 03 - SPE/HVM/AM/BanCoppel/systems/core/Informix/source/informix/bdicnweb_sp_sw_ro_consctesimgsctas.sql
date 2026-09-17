CREATE PROCEDURE "informix".sp_sw_ro_consctesimgsctas(pUsuario CHAR(8), pIdFunciON CHAR(10), pIdOficio INT)
	RETURNING CHAR(5) AS codret,
			INT AS id_cliente,
			CHAR(164) AS nombre
	DEFINE iSqlErr INT;
	DEFINE iNoRows INT;
	DEFINE cCodRet CHAR(5);
	DEFINE iIdCte INT;
	DEFINE cNombreCte CHAR(164);
	LET iSqlErr = 0;
	LET cCodRet = '00000';
	LET iIdCte = 0;
	LET cNombreCte = '';
	LET iNoRows = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iIdCte, cNombreCte;
			END IF;
		END EXCEPTION;
		IF pUsuario = ''OR pIdFunciON = ''OR pIdOficio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdCte, cNombreCte;
		END IF;
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdCte, cNombreCte;
		END IF;
		SET ISOLATION TO DIRTY READ;
		SELECT {+INDEX (bdicnweb:sw_ro_resulcte idx_certexpdig)} COUNT(*)
		INTO iNoRows
		FROM sw_ro_resulper a, sw_ro_resulcte b
			WHERE a.id_oficio = pIdOficio
				AND a.status_busqueda = '1'
				AND a.ind_omitir = '0'
				AND a.status = '1'
				AND b.id_resulper = a.id_resulper
				AND (b.certifica_imagenes = '1'OR b.ind_expdig = '1');
		IF iNoRows = 0 THEN
			LET cCodRet = '00111';
			RETURN cCodRet, iIdCte, cNombreCte;
		END IF;
		LET iNoRows = 0; 
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT {+INDEX (bdicnweb:sw_ro_resulcte idx_certexpdig)} b.id_resulcte, TRIM(TRIM(a.nombre1)||' '||
										TRIM(a.nombre2)||' '||
										TRIM(a.apell_paterno)||' '||
										TRIM(a.apell_materno)||' '||
										TRIM(a.razon_social)) AS nombre
			INTO iIdCte, cNombreCte
			FROM sw_ro_resulper a, sw_ro_resulcte b
			WHERE a.id_oficio = pIdOficio
				AND a.status_busqueda = '1'
				AND a.ind_omitir = '0'
				AND a.status = '1'
				AND b.id_resulper = a.id_resulper
				AND (b.certifica_imagenes = '1'OR b.ind_expdig = '1')
			LET iNoRows = iNoRows + 1;
			RETURN cCodRet, iIdCte, cNombreCte WITH resume;
		END FOREACH;
		IF iNoRows = 0 THEN
			LET cCodRet = '01001';
			RETURN cCodRet, iIdCte, cNombreCte;
		END IF;
	END
END PROCEDURE;