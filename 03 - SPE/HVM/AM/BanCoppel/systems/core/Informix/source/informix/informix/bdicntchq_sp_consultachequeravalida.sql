CREATE PROCEDURE "informix".sp_consultachequeravalida(pEmpresa char(3),pNumCuenta CHAR(11),pConsecutivo integer)
	RETURNING CHAR(5);
	
	--*******************************************
	--sp_consultachequeravalida
	--Objetivo:verificar si la chequera es valida o no para cancelarla
	--Autor: Francisco Rodriguez Ibarra
	--Fecha:15-Abril-2010
	--*********************************************
	--Declaracion de variables
	DEFINE vSqlErr 		 INTEGER;
	DEFINE vsCodRet  		CHAR(5);
	DEFINE vTotalCheques INTEGER;
	
	--Asignacion de Valores a Variables
	LET vsCodRet='00000';
	LET vSqlErr = 0;
	LET vTotalCheques =0;
	
	BEGIN
	
		ON EXCEPTION SET vSqlErr
	        IF vSqlErr <> 0 THEN
	            let vsCodRet = vSqlErr;
				--ROLLBACK WORK;
				RETURN vsCodRet;
				
			END IF;
		END EXCEPTION;
	
		  SELECT count(estado)
			INTO vTotalCheques
			FROM bdicheq:sc_contch
			WHERE empresa = TRIM(pEmpresa)
				AND cuenta = TRIM(pNumCuenta)
				AND consec = pConsecutivo
				AND estado = "A";
				
			IF (vTotalCheques < 25) THEN
				LET vsCodRet='00001';
			END IF;
			
		RETURN vsCodRet;
	END
END PROCEDURE;