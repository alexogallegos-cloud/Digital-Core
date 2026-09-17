CREATE PROCEDURE "informix".sp_sw_ro_guardanotaoficio(pUsuario CHAR(8), pIdFunciON CHAR(10), pIdOficio INT, pIdNota INT, pStatusBus CHAR(1), pNota VARCHAR(255), pIp CHAR(15), pMacAddress CHAR(12))
	RETURNING
		CHAR(5) AS codret,
		INT AS secuencia
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE iNumRegistro INT;
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNumRegistro = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iNumRegistro;
			END IF;
		END EXCEPTION;
		IF pUsuario = ''OR pIdFunciON = ''
				OR pIdOficio = ''
				OR pStatusBus = ''
				OR pNota = ''
				OR pIp = ''
				OR pMacAddress = '' 
			THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iNumRegistro;
		END IF;
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) 
		INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistro;
		END IF;
		
		IF pIdNota = 0 THEN
			-- Se INSERTan los valores
			INSERT INTO sw_ro_notasoficio(id_oficio, nota, status_busqueda, user_insert, ip_insert, mac_insert)
			VALUES (pIdOficio, pNota, pStatusBus, pUsuario, pIp, pMacAddress);
			LET iNumRegistro = dbinfo('sqlca.sqlerrd1');
			RETURN cCodRet, iNumRegistro;
		ELSE
			-- Se actualiza el contenido de la nota
			UPDATE sw_ro_notasoficio SET nota = pNota WHERE id_notasoficio = pIdNota;
			RETURN cCodRet, pIdNota;
		END IF;
	END
END PROCEDURE;