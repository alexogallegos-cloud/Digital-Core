CREATE PROCEDURE "informix".sp_migracionparentescobenefchq()
	RETURNING CHAR(6) AS Codigo_retorno, CHAR(100) as Mensaje;

	DEFINE v_cuenta             CHAR(20);
	DEFINE v_numcte             CHAR(20);
	DEFINE v_sexo               CHAR(1); 
	DEFINE v_parentesco        	CHAR(3);
	DEFINE v_codigo_retorno		CHAR(3);
	DEFINE vsqlerr				INTEGER;
	DEFINE v_mensaje			CHAR(100);
	DEFINE v_secuencia 			INTEGER;

	--*********************************************************--
	-- Creado por: Frank Gaxiola Gaxiola		
	--Fecha: 29/Enero/2009
	--Objetivo: Migración de Parentesco de los beneficiarios de cuentas de cheques
	--Modificado: Frank Gaxiola Gaxiola		
	--Fecha: 20/Febrero/2009
	--Modificación: Se agrega validación para que solo se ejecute una vez el procedimiento
	--*********************************************************--

	LET vsqlerr = 0;
	LET v_codigo_retorno = "000";
	LET v_mensaje = "Migración de parentesco realizada con éxito";
	
--	    SET DEBUG FILE TO '/tmp/sp_migracionParentescoBenefChq.out';
--        TRACE ON;

	BEGIN
		ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				let v_codigo_retorno = vsqlerr;
				RETURN v_codigo_retorno, v_mensaje;
			END IF;
		END EXCEPTION;
		
		SELECT {+  INDEX(bdicheq:sc_beneficiario inx_adicdebito) } LIMIT 1 cuenta INTO v_cuenta FROM bdicheq:sc_beneficiario 
            WHERE parentesco IN('P', 'M', 'J', 'H', 'A', 'E', 'T', 'B', 'O', 'U', 'C' , 'I', 'R', 'S', 'N', 'K');
		
		IF v_cuenta IS NULL THEN

			FOREACH
				SELECT {+  INDEX(bdicheq:sc_beneficiario inx_adicdebito) } TRIM(numcte), TRIM(cuenta), TRIM(parentesco), secuencia 
				INTO v_numcte, v_cuenta, v_parentesco, v_secuencia 
				FROM bdicheq:sc_beneficiario WHERE parentesco <> ""

				IF v_parentesco = '01' THEN
					SELECT sexo INTO v_sexo FROM si_ctepf WHERE numcte = v_numcte;
					IF v_sexo = 'M' THEN
						UPDATE {+  INDEX(bdicheq:sc_beneficiario inx_adicdebitos ) } bdicheq:sc_beneficiario SET parentesco = 'P' 
						WHERE numcte = v_numcte AND cuenta = v_cuenta AND secuencia = v_secuencia AND parentesco = '01';
					ELSE
						UPDATE {+  INDEX(bdicheq:sc_beneficiario inx_adicdebitos ) } bdicheq:sc_beneficiario SET parentesco = 'M' 
						WHERE numcte = v_numcte AND cuenta = v_cuenta AND secuencia = v_secuencia AND parentesco = '01';
					END IF;
				ELIF v_parentesco = '02' THEN
					UPDATE {+  INDEX(bdicheq:sc_beneficiario inx_adicdebitos ) } bdicheq:sc_beneficiario SET parentesco = 'J'  WHERE numcte = v_numcte AND cuenta = v_cuenta AND secuencia = v_secuencia AND parentesco = '02';
				ELIF v_parentesco = '03' THEN
					UPDATE {+  INDEX(bdicheq:sc_beneficiario inx_adicdebitos ) } bdicheq:sc_beneficiario SET parentesco = 'H' WHERE numcte = v_numcte AND cuenta = v_cuenta AND secuencia = v_secuencia AND parentesco = '03';
				ELIF v_parentesco = '04' THEN
					UPDATE {+  INDEX(bdicheq:sc_beneficiario inx_adicdebitos ) } bdicheq:sc_beneficiario SET parentesco = 'A' WHERE numcte = v_numcte AND cuenta = v_cuenta AND secuencia = v_secuencia AND parentesco = '04';
				ELIF v_parentesco = '05' THEN
					UPDATE {+  INDEX(bdicheq:sc_beneficiario inx_adicdebitos ) } bdicheq:sc_beneficiario SET parentesco = 'E' WHERE numcte = v_numcte AND cuenta = v_cuenta AND secuencia = v_secuencia AND parentesco = '05';
				ELIF v_parentesco = '06' THEN
					UPDATE {+  INDEX(bdicheq:sc_beneficiario inx_adicdebitos ) } bdicheq:sc_beneficiario SET parentesco = 'T' WHERE numcte = v_numcte AND cuenta = v_cuenta AND secuencia = v_secuencia AND parentesco = '06';
				ELIF v_parentesco = '07' THEN
					UPDATE {+  INDEX(bdicheq:sc_beneficiario inx_adicdebitos ) } bdicheq:sc_beneficiario SET parentesco = 'B' WHERE numcte = v_numcte AND cuenta = v_cuenta AND secuencia = v_secuencia AND parentesco = '07';
				ELIF v_parentesco = '08' THEN
					UPDATE {+  INDEX(bdicheq:sc_beneficiario inx_adicdebitos ) } bdicheq:sc_beneficiario SET parentesco = 'O' WHERE numcte = v_numcte AND cuenta = v_cuenta AND secuencia = v_secuencia AND parentesco = '08';
				ELIF v_parentesco = '09' THEN
					UPDATE {+  INDEX(bdicheq:sc_beneficiario inx_adicdebitos ) } bdicheq:sc_beneficiario SET parentesco = 'U' WHERE numcte = v_numcte AND cuenta = v_cuenta AND secuencia = v_secuencia AND parentesco = '09';
				ELIF v_parentesco = '10' THEN
					UPDATE {+  INDEX(bdicheq:sc_beneficiario inx_adicdebitos ) } bdicheq:sc_beneficiario SET parentesco = 'C' WHERE numcte = v_numcte AND cuenta = v_cuenta AND secuencia = v_secuencia AND parentesco = '10';
				ELIF v_parentesco = '11' THEN
					UPDATE {+  INDEX(bdicheq:sc_beneficiario inx_adicdebitos ) } bdicheq:sc_beneficiario SET parentesco = 'I' WHERE numcte = v_numcte AND cuenta = v_cuenta AND secuencia = v_secuencia AND parentesco = '11';
				ELIF v_parentesco = '12' THEN
					UPDATE {+  INDEX(bdicheq:sc_beneficiario inx_adicdebitos ) } bdicheq:sc_beneficiario SET parentesco = 'R' WHERE numcte = v_numcte AND cuenta = v_cuenta AND secuencia = v_secuencia AND parentesco = '12';
				ELIF v_parentesco = '13' THEN
					UPDATE {+  INDEX(bdicheq:sc_beneficiario inx_adicdebitos ) } bdicheq:sc_beneficiario SET parentesco = 'S' WHERE numcte = v_numcte AND cuenta = v_cuenta AND secuencia = v_secuencia AND parentesco = '13';
				ELIF v_parentesco = '14' THEN
					UPDATE {+  INDEX(bdicheq:sc_beneficiario inx_adicdebitos ) } bdicheq:sc_beneficiario SET parentesco = 'N' WHERE numcte = v_numcte AND cuenta = v_cuenta AND secuencia = v_secuencia AND parentesco = '14';
				ELIF v_parentesco = '15' THEN
					UPDATE {+  INDEX(bdicheq:sc_beneficiario inx_adicdebitos ) } bdicheq:sc_beneficiario SET parentesco = 'K' WHERE numcte = v_numcte AND cuenta = v_cuenta AND secuencia = v_secuencia AND parentesco = '15';
				END IF;
				
			END FOREACH;
			
		ELSE
			LET v_mensaje = "La migración de parentesco solo se realiza una vez";
		END IF;
		
		RETURN v_codigo_retorno, v_mensaje;
		
	END;
END PROCEDURE;