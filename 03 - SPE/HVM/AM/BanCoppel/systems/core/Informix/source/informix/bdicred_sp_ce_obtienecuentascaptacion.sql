CREATE PROCEDURE "informix".sp_ce_obtienecuentascaptacion (p_sEmpresa CHAR(3), p_sNumCliente CHAR(20))
	RETURNING	CHAR(6) AS retorno, 
				CHAR(20) AS cuenta;
	
	DEFINE iSqlErr							INTEGER;
	DEFINE v_sValRetorno					CHAR(6);
	DEFINE v_sEmpresa						CHAR(3);
	DEFINE v_sCuenta						CHAR(20);
	DEFINE v_sNumCliente					CHAR(20);

	--> ---------------------------------------------------------------------------
	-- Sp para obtención de cuentas eje de clientes de crédito empresarial - 30/09/2013
	-- Referencia: bdichq:sp_obtenercuentascaptacion
    -- Autor: SADCV
    -- Fecha: 30/09/2013
    ------------------------------------------------------------------------------>
	
	LET v_sValRetorno = '000001';
	-- LET v_sTipoCuenta = 'D';
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'';
			END IF;
		END EXCEPTION;
		
		--> LOS PARAMETROS NO DEBEN SER NULOS
		
		IF NVL(p_sEmpresa,'')='' OR NVL(p_sNumCliente,'')='' THEN
			RETURN v_sValRetorno,'';
		END IF;
		
		LET p_sNumCliente = LPAD(TRIM(p_sNumCliente),9,'0');
		
		--> OBTIENE LAS CUENTAS DE CHEQUES EJE PARA CRÉDITO EMPRESARIAL
		
		FOREACH
		
			SELECT empresa, cuenta, num_cte
			INTO v_sEmpresa, v_sCuenta, v_sNumCliente
			FROM bdicheq_ce:sc_maechq 			
			WHERE empresa = p_sEmpresa 
			AND num_cte = p_sNumCliente 
			AND producto IN ('1200','1600','2200')
			AND fec_cancelac IS NULL -- No considerar cuentas canceladas.
			
			LET v_sValRetorno = '000000';
			RETURN v_sValRetorno, v_sCuenta WITH RESUME;
			
		END FOREACH;
		
	END;
	
END PROCEDURE;