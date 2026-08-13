CREATE PROCEDURE "informix".spactualizarsueldoempleado (p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_mSueldo MONEY(10,0), p_dFecha DATE)
RETURNING CHAR(5) AS CodigoRetorno
	
	DEFINE iSqlErr          INTEGER;
	DEFINE v_sCodRet        CHAR(5);
	DEFINE v_sAuxiliar		CHAR(12);
	
	--SET DEBUG FILE TO  "/dbexportb/Fabiola/spactualizarsueldoempleado.out"; 
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				INSERT INTO bdirech:rec_errores(descripcion) VALUES ('sase '||iSqlErr);
				RETURN v_sCodRet;
			END IF;
		END EXCEPTION;		

		--// Valida parámetros de entrada
		IF NVL(p_sNumEmpleado, '') = '' OR NVL(p_sNumSucursal, '') = '' OR NVL(p_dFecha, '') = '' THEN
			LET v_sCodRet = '00001';
			RETURN v_sCodRet;
		END IF
		
		IF NVL(p_mSueldo, '') = '' THEN
			LET p_mSueldo = 0;
		END IF
		
		LET v_sCodRet = '00000';
		
		IF NOT EXISTS(SELECT sueldoquincena FROM bdirech:rec_descquincena WHERE numempleado = p_sNumEmpleado) THEN
			IF p_mSueldo > 0 THEN			
				LET v_sAuxiliar = p_sNumSucursal || p_sNumEmpleado;				
				
				INSERT INTO bdirech:rec_descquincena (numempleado, numsucursal, auxiliar, fechadesc, sueldoquincena, desccalculado, descaplicado)
				VALUES(p_sNumEmpleado, p_sNumSucursal, v_sAuxiliar, p_dFecha, p_mSueldo, 0, 0);				
							
			ELIF p_mSueldo < 0 THEN			
				UPDATE bdirech:rec_confaltante SET idestatus = 3 WHERE numempleado = p_sNumEmpleado AND numsucursal IS NOT NULL
				AND idfaltante <> 0;
				
			END IF
		ELSE			
			INSERT INTO bdirech:rec_errores(descripcion) VALUES ('sase '||p_sNumEmpleado||'-'||p_sNumSucursal||'-'||p_dFecha);			
			LET v_sCodRet = '00002';
		END IF
		
		RETURN v_sCodRet;
	END
END PROCEDURE
