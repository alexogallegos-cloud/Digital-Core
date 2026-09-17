CREATE PROCEDURE "informix".sp_obtenernumproductonew(p_sEmpresa CHAR(3), p_sNumCuenta CHAR(20), p_sNumTarjeta CHAR(20))
RETURNING	 VARCHAR(6) as sNumProducto --numero de producto

	DEFINE iSqlErr				INTEGER;
	DEFINE v_sNumProducto 		CHAR(4);
	DEFINE v_sTipoCuenta		CHAR(2);
	-----------------------------------------------------------------------------------------------------
	-- AUTOR: Erick Zamora
	-- FECHA: 23-03-2009
	-- Obtiene el numero de producto al que hace referencia una cuenta 
	-- SET DEBUG FILE TO "/tmp/sp_obtenernumproducto.out";
	-- TRACE ON;
	------------------------------------------------------------------------------------------------------
	LET v_sNumProducto = "";
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
		LET v_sNumProducto = "0000";
		--SE OBTIENE EL NUMERO DE CUENTA DE LA TARJETA DE DEBITO
		IF p_sNumCuenta = "" AND p_sNumTarjeta <> "" THEN
			SELECT prodtarjeta INTO v_sNumProducto FROM bdicheq:sc_tarjeta WHERE empresa = p_sEmpresa AND num_tarjeta = p_sNumTarjeta;
			RETURN v_sNumProducto;
		END IF
		
		LET v_sTipoCuenta = SUBSTR(p_sNumCuenta,1,2);
		
		IF v_sTipoCuenta IN('10','11','13','15','18','19') THEN	--CUENTAS DE DEBITO
			SELECT producto INTO v_sNumProducto FROM bdicheq:sc_maechq WHERE empresa = p_sEmpresa AND cuenta = p_sNumCuenta;
		
		ELIF v_sTipoCuenta IN ('60', '65','66') THEN				--TC COPPEL
			SELECT num_producto INTO v_sNumProducto FROM bdisolic:ss_solicitudes WHERE empresa = p_sEmpresa AND num_solicitud = p_sNumCuenta;
			IF v_sNumProducto IS NULL AND v_sTipoCuenta in ('60','66') THEN
				SELECT num_producto INTO v_sNumProducto FROM bdicred:sd_maecred WHERE empresa = p_sEmpresa AND num_credito = p_sNumCuenta;
			END IF
			
		ELIF v_sTipoCuenta in ('60','66') THEN						--CUENTAS DE CREDITO					
				SELECT num_producto INTO v_sNumProducto FROM bdicred:sd_maecred WHERE empresa = p_sEmpresa AND num_credito = p_sNumCuenta;
		
		ELIF v_sTipoCuenta = '30' THEN						--CUENTAS DE INVERSION
			SELECT cod_instrum INTO v_sNumProducto FROM bdinvers:sv_maeinv WHERE empresa = p_sEmpresa AND cuenta = p_sNumCuenta;
		
		END IF
		IF v_sNumProducto is null or v_sNumProducto = ""
		THEN
		   LET v_sNumProducto = "0000";
		END IF;
		RETURN v_sNumProducto;
	END
END PROCEDURE;