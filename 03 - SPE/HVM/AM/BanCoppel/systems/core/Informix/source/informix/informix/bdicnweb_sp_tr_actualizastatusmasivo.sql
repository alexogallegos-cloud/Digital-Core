CREATE PROCEDURE "informix".sp_tr_actualizastatusmasivo(pUsuario CHAR(8), pIdFunciON CHAR(10), pStatus CHAR(2), pIdRegistros VARCHAR(255))
	RETURNING
		CHAR(5) AS codret,
		INT AS exitosos, 
		INT AS fracasos
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE iExitosos INT;
	DEFINE iFracasos INT;
	DEFINE iCount INT;
	DEFINE iStart INT;
	DEFINE iLength INT;
	DEFINE iRow INT;
	DEFINE cBaseDatos CHAR(50);
	DEFINE cTablaDst CHAR(50);
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExitosos = 0;
	LET iFracasos = 0;
	LET iLength = LENGTH(pIdRegistros);	
	LET iRow = 0;
	LET cBaseDatos = '';
	LET cTablaDst = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iExitosos, iFracasos;
			END IF;
		END EXCEPTION;

		IF pUsuario = '' OR pIdFunciON = ''
				OR pStatus = ''
				OR pIdRegistros = ''
			THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iExitosos, iFracasos;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iExitosos, iFracasos;
		END IF;
		
		LET iStart = 1;
		--set debug file to 'masiva.out';
		--trace on;
		
		SELECT base_datos, tabla
		INTO cBaseDatos, cTablaDst
		FROM sw_tr_info_tablas WHERE id_funcion = pIdFuncion;		
		
		IF cBaseDatos IS NULL OR cBaseDatos = '' THEN
			LET cCodRet = '00154';
			RETURN cCodRet, iExitosos, iFracasos;
		END IF;
		
		FOR iCount = 1 TO iLength
			IF SUBSTR(pIdRegistros, iCount, 1) = '|' THEN
				LET iRow = SUBSTR(pIdRegistros, iStart, iCount - iStart);
				EXECUTE IMMEDIATE "UPDATE " || TRIM(cBaseDatos) || ":" || TRIM(cTablaDst) || " SET status='"|| TRIM(pStatus) ||"' WHERE id_registro=" || iRow;
				LET iRow = dbinfo('sqlca.sqlerrd2');
				
				IF iRow > 0 THEN
					LET iExitosos = iExitosos + 1;
				ELSE
					LET iFracasos = iFracasos + 1;
				END IF;
				LET iStart = iCount + 1;
				
			ELIF iCount = iLength THEN
			
				LET iRow = SUBSTR(pIdRegistros, iStart);
				EXECUTE IMMEDIATE "UPDATE " || TRIM(cBaseDatos) || ":" || TRIM(cTablaDst) || " SET status='"|| TRIM(pStatus) ||"' WHERE id_registro=" || iRow;
				LET iRow = dbinfo('sqlca.sqlerrd2');
				
				IF iRow > 0 THEN
					LET iExitosos = iExitosos + 1;
				ELSE
					LET iFracasos = iFracasos + 1;
				END IF;
				LET iStart = iCount + 1;
			END IF;
		END FOR;
		--trace off;
		RETURN cCodRet, iExitosos, iFracasos;
	END
END PROCEDURE;