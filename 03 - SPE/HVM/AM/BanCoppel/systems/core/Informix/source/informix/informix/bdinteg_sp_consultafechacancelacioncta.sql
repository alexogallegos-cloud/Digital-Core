CREATE PROCEDURE "informix".sp_consultafechacancelacioncta(pCuenta CHAR(20), pSistemaCuenta CHAR(2))
	RETURNING 
		CHAR(5) AS codret,
		DATE AS fecha_cancelacion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE dFechaCancelacion DATE;
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET dFechaCancelacion = '';
	LET iSqlErr = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				
				LET cCodRet = iSqlErr;
				RETURN cCodRet, dFechaCancelacion;
			
			END IF;
		END EXCEPTION;
		
		IF pCuenta = '' OR pSistemaCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechaCancelacion;
		END IF;
		
		IF pSistemaCuenta NOT IN ('01', '03', '06') THEN
			LET cCodRet = '00037';
			RETURN cCodRet, dFechaCancelacion;
		END IF;
		
		IF pSistemaCuenta = '01' THEN
			
			SET ISOLATION TO DIRTY READ;
			
			SELECT fec_cancelac 
			INTO dFechaCancelacion
			FROM bdicheq:sc_maechq 
			WHERE cuenta = pCuenta AND status_cta=2;
			
		ELIF pSistemaCuenta = '03' THEN
			
			SET ISOLATION TO DIRTY READ;
			
			SELECT FIRST 1 fec_cancelac 
			INTO dFechaCancelacion
			FROM bdinvers:sv_maeinv
			WHERE cuenta = pCuenta AND status_cta=2;
			
			--let dFechaCancelacion = NULL;
			
		ELIF pSistemaCuenta = '06' THEN
			
			SET ISOLATION TO DIRTY READ;
			
			SELECT MAX(fecha_proceso)
			INTO dFechaCancelacion
			FROM bdicred:sd_maecredanexo mca, bdicred:sd_maecred mc
			WHERE mc.num_credito = pCuenta
				AND mc.status_cred = 'FF'
				AND mca.num_credito = mc.num_credito;
			
		END IF;
		
		RETURN cCodRet, dFechaCancelacion;
	END;
	
END PROCEDURE;