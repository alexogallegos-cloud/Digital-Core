CREATE PROCEDURE "informix".sp_consultadetlide(pUsuario CHAR(8), pIdFuncion CHAR(10), pRfc CHAR(13))
	RETURNING CHAR(5) AS codret,
			CHAR(6) AS aniomes,
			CHAR(20) AS numcte,
			CHAR(20) AS referencia_retencion,
			DATE AS fecha_ret;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cAnioMes CHAR(6);
	DEFINE cNumCliente CHAR(20);
	DEFINE cReferenciaRetencion CHAR(20);
	DEFINE dFechaRet DATE;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cAnioMes = '';
	LET cNumCliente = '';
	LET cReferenciaRetencion = '';
	LET dFechaRet = NULL;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cAnioMes, cNumCliente, cReferenciaRetencion, dFechaRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultadetlide.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRfc = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cAnioMes, cNumCliente, cReferenciaRetencion, dFechaRet;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cAnioMes, cNumCliente, cReferenciaRetencion, dFechaRet;
		END IF;
		
		SELECT aniomes, num_cte, ref_ret, fecha_ret
		INTO cAnioMes, cNumCliente, cReferenciaRetencion, dFechaRet
		FROM bdilide:"informix".sl_detlide
		WHERE rfc = pRfc;
		
		IF cNumCliente IS NULL OR TRIM(cNumCliente) = '' THEN
			LET cCodRet = '00030';
		END IF;
		
		RETURN cCodRet, cAnioMes, cNumCliente, cReferenciaRetencion, dFechaRet;
	
	END;
			
END PROCEDURE;