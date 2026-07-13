CREATE PROCEDURE "informix".sp_ope_sldecanual(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaProceso DATE, pTipoDecl CHAR(1), pFechaPresentacion DATE, pNumFolio VARCHAR(16))
		RETURNING CHAR(5) AS codret,
			CHAR(80) AS mensaje;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensaje CHAR(80);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensaje = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE bdicnweb:"informix".sw_bitacoraprocedimientoside
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_sldecanual' AND fecha_fin IS NULL;
			RETURN cCodRet, cMensaje;

			UPDATE bdicnweb:"informix".sw_verificastatusdeclide
			SET status = 'E', error = cCodRet
			WHERE usuario_insert = pUsuario;
		END EXCEPTION;

		--SET DEBUG FILE TO '/informix2/ilopez/IDE_ANUAL_MENSUAL/sp_ope_sldecanual.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pFechaProceso = '' OR pTipoDecl = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMensaje;
		END IF;

		DELETE FROM bdicnweb:"informix".sw_verificastatusdeclide WHERE usuario_insert = pUsuario;
		--TRUNCATE TABLE bdicnweb:"informix".sw_verificastatusdeclide;
		INSERT INTO bdicnweb:"informix".sw_verificastatusdeclide(usuario_insert, status,	error_proceso, error, mensaje) VALUES(pUsuario,'I','','','');

		INSERT INTO bdicnweb:"informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin)
		VALUES(pUsuario, 'sp_ope_sldecanual', CURRENT, null);

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		EXECUTE PROCEDURE bdilide:"informix".spsldecanual2(pFechaProceso, pUsuario, pTipoDecl, pFechaPresentacion, pNumFolio)
		INTO cCodRetSp, cMensaje;

		
		--EXECUTE PROCEDURE bdilide:"informix".spsldecanual(pFechaProceso, pUsuario, pTipoDecl, pFechaPresentacion, pNumFolio)
		--INTO cCodRetSp, cMensaje;

		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			--Se agrega update
			UPDATE bdicnweb:"informix".sw_verificastatusdeclide
			SET status = 'E', error = cCodRetSp
			WHERE usuario_insert = pUsuario;
      
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP spsldecanual";
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '99999'; --EL REPORTE DE LA DECLARACION MENSUAL DE DICIEMBRE NO SE HA GENERADO o EL REPORTE SE GENERO CON ERRORES, NO GENERAR XML
		ELIF iCodRetSp = 6 THEN
			LET cCodRet = '01223'; --Se han generado el nÃºmero de  Declaracines informativas complementarias permitidas
		ELIF iCodRetSp = 7 THEN
			LET cCodRet = '01224'; --No se puede generar DeclaraciÃ³n complementaria sin hacer primero la Normal
		END IF;

		UPDATE bdicnweb:"informix".sw_bitacoraprocedimientoside
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_sldecanual' AND fecha_fin IS NULL;

		IF cCodRet = '00000' THEN
			UPDATE bdicnweb:"informix".sw_verificastatusdeclide
			SET status = 'T', error = cCodRet, mensaje = cMensaje
			WHERE usuario_insert = pUsuario;
		ELSE
			UPDATE bdicnweb:"informix".sw_verificastatusdeclide
			SET status = 'E', error = cCodRet
			WHERE usuario_insert = pUsuario;
		END IF;

		RETURN cCodRet, cMensaje;

	END;

END PROCEDURE
