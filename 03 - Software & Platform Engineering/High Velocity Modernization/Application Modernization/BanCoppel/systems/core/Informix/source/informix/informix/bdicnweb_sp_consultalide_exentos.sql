CREATE PROCEDURE "informix".sp_consultalide_exentos(pUsuario CHAR(8), pIdFuncion CHAR(10), pRfc CHAR(13))
	RETURNING CHAR(5) AS codret,
			CHAR(20) AS numcte,
			DATE AS fecha_cambio,
			CHAR(1) AS estado;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNumCliente CHAR(20);
	DEFINE dFechaCambio DATE;
	DEFINE cEstado CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumCliente = '';
	LET dFechaCambio = NULL;
	LET cEstado = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCliente, dFechaCambio, cEstado;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultalide_exentos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRfc = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCliente, dFechaCambio, cEstado;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumCliente, dFechaCambio, cEstado;
		END IF;
		
		SELECT {+INDEX (bdilide:sl_exentos informix.idx_exentos)} num_cte, fech_cambio, status
		INTO cNumCliente, dFechaCambio, cEstado
		FROM bdilide:"informix".sl_exentos
		WHERE rfc = pRfc;
		
		IF cNumCliente IS NULL OR TRIM(cNumCliente) = '' THEN
			LET cCodRet = '00030';
		END IF;
		
		RETURN cCodRet, cNumCliente, dFechaCambio, cEstado;
	
	END;
			
END PROCEDURE;