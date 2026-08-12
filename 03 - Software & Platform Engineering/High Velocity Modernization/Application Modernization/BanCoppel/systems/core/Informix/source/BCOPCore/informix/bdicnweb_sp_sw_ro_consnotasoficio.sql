CREATE PROCEDURE "informix".sp_sw_ro_consnotasoficio(pUsuario CHAR(8), pIdFunciON CHAR(10), pIdOficio INT)
	RETURNING
		CHAR(5) AS codret,
		INT AS secuencia,
		CHAR(255) AS nota,
		CHAR(1) AS statusbus
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE iNoRegistros INT;
	DEFINE iSecuenciaNota INT;
	DEFINE cNota CHAR(255);
	DEFINE cStatusBus CHAR(1);
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iSecuenciaNota = 0;
	LET cNota = '';
	LET cStatusBus = '';
	LET iNoRegistros = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iSecuenciaNota, cNota, cStatusBus;
			END IF;
		END EXCEPTION;
		IF pUsuario = '' OR pIdFunciON = '' OR pIdOficio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iSecuenciaNota, cNota, cStatusBus;
		END IF;
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iSecuenciaNota, cNota, cStatusBus;
		END IF;
		SET ISOLATION TO DIRTY READ;		
		FOREACH
			SELECT DISTINCT NVL(nts.id_notasoficio, 0), NVL(nts.nota,''), res.status_busqueda 
			INTO iSecuenciaNota, cNota, cStatusBus
			FROM sw_ro_resulper AS res
			LEFT OUTER JOIN sw_ro_notasoficio AS nts ON res.id_oficio=nts.id_oficio AND res.status_busqueda=nts.status_busqueda
			WHERE res.id_oficio = pIdOficio 
			AND res.status = '1' AND res.ind_omitir = '0'
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iSecuenciaNota, cNota, cStatusBus WITH resume;
		END FOREACH;		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '01001';
			RETURN cCodRet, iSecuenciaNota, cNota, cStatusBus;
		END IF;
	END
END PROCEDURE;