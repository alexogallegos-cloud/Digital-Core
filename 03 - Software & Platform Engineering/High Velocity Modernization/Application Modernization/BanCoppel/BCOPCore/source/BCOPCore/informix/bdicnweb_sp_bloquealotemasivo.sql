CREATE PROCEDURE "informix".sp_bloquealotemasivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdFuncionPadre CHAR(10), pLote INTEGER, pOpcBloqueo INTEGER)
	RETURNING CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE cStatusLote CHAR(2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET cStatusLote = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdFuncionPadre = '' OR pLote = '' OR pOpcBloqueo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		IF pOpcBloqueo NOT IN (0,1,2) THEN
			LET cCodRet = '00108';
			RETURN cCodRet;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		-- Se busca el lote en la tabla de los masivos
		SELECT COUNT(id_lote)
		INTO iExiste
		FROM bdicnweb:sw_tr_totales_masivo
		WHERE id_lote = pLote AND id_funcion = pIdFuncionPadre;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00200';
			RETURN cCodRet;
		ELSE
			IF pOpcBloqueo = 0 THEN -- Desbloqiueo del lote, 'CARGADO'
				LET cStatusLote = 'C';
			ELIF pOpcBloqueo = 1 THEN -- Bloqueo del lote, 'PROCESANDO'
				LET cStatusLote = 'P';
			ELIF pOpcBloqueo = 2 THEN -- Desbloqiueo del lote, 'TERMINADO'
				LET cStatusLote = 'T';
			END IF;
			
			UPDATE bdicnweb:sw_tr_totales_masivo
			SET status_lote = cStatusLote
			WHERE id_lote = pLote AND id_funcion = pIdFuncionPadre;
			
			RETURN cCodRet;
		END IF;

	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRIPCION: Cambia el estatus de un lote de la aplicaciÃ³n CNWEB";

CREATE PROCEDURE "informix".sp_blqconsultabloqueocap(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pTipoMov CHAR(1))
	RETURNING CHAR(5) AS codret,
			CHAR(5) AS codretsp,
			CHAR(50) AS desc_bloqueo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE cDesBloqueo CHAR(50);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDesBloqueo = '';
	LET iSqlErr = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodRetSp, cDesBloqueo;
		END EXCEPTION;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' OR pTipoMov = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodRetSp, cDesBloqueo;
		END IF;
		
		IF pTipoMov NOT IN ('D', 'B') THEN
			LET cCodRet = '00005';
			RETURN cCodRet, cCodRetSp, cDesBloqueo;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodRetSp, cDesBloqueo;
		END IF;
		
		-- Busqueda del estatus de la cuenta
		EXECUTE PROCEDURE bdicheq:sp_blqvalbloqueocta(pCuenta) INTO cCodRetSp, cDesBloqueo;
		
		IF pTipoMov = 'B' THEN
			IF cCodRetSp = '10000' THEN
				LET cCodRet = '00173';
			END IF;
		ELIF pTipoMov = 'D' THEN
			IF cCodRetSp <> '10000' THEN
				LET cCodRet = '00172';
			END IF;
		END IF;
		
		RETURN cCodRet, cCodRetSp, cDesBloqueo;
		
	END;
	
END PROCEDURE;