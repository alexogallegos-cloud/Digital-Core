CREATE PROCEDURE "informix".spgrabardeschistorico (p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_sAuxiliar	CHAR(12), p_dFechaDesc DATE,
										p_mSueldoQuincenal MONEY(10,0), p_mDescuentoCalc MONEY(10,0),p_mDescuentoAplicado MONEY(10,0))
										
	RETURNING CHAR(5) AS retorno;

	DEFINE iSqlErr			INTEGER;
	DEFINE v_sValRetorno	CHAR(5);
	
	-----------------------------------------------------------------------
	--SET DEBUG FILE TO "/tmp/prisma/spgrabardeschistorico.out"; ;
	--TRACE ON;
	-----------------------------------------------------------------------

	LET v_sValRetorno = '00001';	
		
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sValRetorno = iSqlErr;
				ROLLBACK WORK;
				RETURN v_sValRetorno;
			END IF;
		END EXCEPTION;
		
		BEGIN WORK;
			--LOS PARAMETROS NO DEBEN SER NULOS
			IF NVL(p_sNumEmpleado,'')='' OR NVL(p_sNumSucursal,'')='' OR NVL(p_sAuxiliar,'') = ''
				OR NVL(p_dFechaDesc,'') = '' OR NVL(p_mSueldoQuincenal,'') = '' OR NVL(p_mDescuentoCalc,'') = ''
				OR NVL(p_mDescuentoAplicado,'') = '' THEN
				RETURN v_sValRetorno;
			END IF;
										
			IF NOT EXISTS (SELECT 1 FROM bdirech:rec_deschistorico WHERE numempleado = p_sNumEmpleado
				AND fechadesc = p_dFechaDesc) THEN			
				
				INSERT INTO bdirech:rec_deschistorico (numempleado, numsucursal, auxiliar, fechadesc,sueldoquincena,
					desccalculado, descaplicado)
				VALUES (p_sNumEmpleado, p_sNumSucursal, p_sAuxiliar, p_dFechaDesc, p_mSueldoQuincenal,
					p_mDescuentoCalc, p_mDescuentoAplicado);
							
				LET v_sValRetorno = '00000';
						
			ELSE
				LET v_sValRetorno = '00002';
			END IF;							
					
		COMMIT WORK;
		RETURN v_sValRetorno;
	END;    
END PROCEDURE									

