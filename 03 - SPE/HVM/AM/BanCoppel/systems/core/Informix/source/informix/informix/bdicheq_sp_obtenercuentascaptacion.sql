CREATE PROCEDURE "informix".sp_obtenercuentascaptacion(p_sEmpresa CHAR(3), p_sNumCliente CHAR(20))
	RETURNING	CHAR(6) AS retorno, 
				CHAR(3) AS empresa, 
				CHAR(20) AS cuenta,
				CHAR(20) AS num_cte,
				CHAR(1) AS tipoCuenta;
	
	DEFINE iSqlErr							INTEGER;
	DEFINE v_sValRetorno					CHAR(6);
	DEFINE v_sEmpresa						CHAR(3);
	DEFINE v_sCuenta						CHAR(20);
	DEFINE v_sNumCliente					CHAR(20);
	DEFINE v_sTipoCuenta					CHAR(1);
	-----------------------------------------------------------------------------
	--Creado por Erick Zamora 05/Agosto/2009
	--	Obtiene las cuentas de Capatacion del cliente especifico
	--Caso de Uso asociado: PCU-bdicheq\CU-0042-ObtenerCuentasCaptación-SPL
	--SET DEBUG FILE TO "/tmp/sp_obtenerCuentasCaptacion.out";
	--TRACE ON;
	-----------------------------------------------------------------------------	
	
	LET v_sValRetorno = '000001';
	LET v_sTipoCuenta = 'D';
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','';
			END IF;
		END EXCEPTION;
		
		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'')='' OR NVL(p_sNumCliente,'')='' THEN
			RETURN v_sValRetorno,'','','','';
		END IF;
		
		LET p_sNumCliente = LPAD(TRIM(p_sNumCliente),9,'0');
		
		--OBTIENE LAS CUENTAS DE CHEQUES
		FOREACH
			SELECT empresa, cuenta, num_cte
			INTO v_sEmpresa, v_sCuenta, v_sNumCliente
			FROM bdicheq:sc_maechq 			
			WHERE empresa = p_sEmpresa AND num_cte = p_sNumCliente
			
			LET v_sValRetorno = '000000';
			RETURN v_sValRetorno, v_sEmpresa, v_sCuenta, v_sNumCliente, v_sTipoCuenta WITH RESUME;
		END FOREACH;
		--OBTIENE LAS CUENTAS DE INVERSION
		FOREACH
			SELECT DISTINCT empresa, cuenta, num_cte
			INTO v_sEmpresa, v_sCuenta, v_sNumCliente
			FROM bdinvers:sv_maeinv 			
			WHERE empresa = p_sEmpresa AND num_cte = p_sNumCliente
			
			LET v_sValRetorno = '000000';
			RETURN v_sValRetorno, v_sEmpresa, v_sCuenta, v_sNumCliente, v_sTipoCuenta WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE;