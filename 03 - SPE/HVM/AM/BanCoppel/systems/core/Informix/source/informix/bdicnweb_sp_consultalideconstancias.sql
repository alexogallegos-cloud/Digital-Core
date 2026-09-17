CREATE PROCEDURE "informix".sp_consultalideconstancias(pUsuario CHAR(8), pIdFuncion CHAR(10), pRfc CHAR(13))
	RETURNING CHAR(5) AS codret,
			CHAR(6) AS aniomes,
			CHAR(20) AS numcte,
			CHAR(1) AS tipo_cons;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cAnioMes CHAR(6);
	DEFINE cNumCliente CHAR(20);
	DEFINE cTipoConstancia CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cAnioMes = '';
	LET cNumCliente = '';
	LET cTipoConstancia = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cAnioMes, cNumCliente, cTipoConstancia;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultalideconstancias.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRfc = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cAnioMes, cNumCliente, cTipoConstancia;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cAnioMes, cNumCliente, cTipoConstancia;
		END IF;
		
		SELECT aniomes, num_cte, tipo_cons
		INTO cAnioMes, cNumCliente, cTipoConstancia
		FROM bdilide:"informix".sl_constancias
		WHERE rfc = pRfc;
		
		IF cNumCliente IS NULL OR TRIM(cNumCliente) = '' THEN
			LET cCodRet = '00030';
		END IF;
		
		RETURN cCodRet, cAnioMes, cNumCliente, cTipoConstancia;
	
	END;
			
END PROCEDURE;