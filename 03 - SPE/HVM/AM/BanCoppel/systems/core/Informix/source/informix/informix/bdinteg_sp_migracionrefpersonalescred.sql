CREATE PROCEDURE "informix".sp_migracionrefpersonalescred()
	RETURNING CHAR(6) AS Codigo_retorno, CHAR(100) as Mensaje;
	
	DEFINE v_cuenta             CHAR(20);
	DEFINE v_numcte             CHAR(20);
	DEFINE v_sexo               CHAR(1); 
	DEFINE v_parentesco        	CHAR(3);
	DEFINE v_codigo_retorno		CHAR(3);
	DEFINE vsqlerr				INTEGER;
	DEFINE v_mensaje			CHAR(100);
	
	--*********************************************************--
	-- Creado por: Frank Gaxiola Gaxiola		
	--Fecha: 29/Enero/2009
	--Objetivo: Migración de Parentesco de las referencias de crédito
	--Modificado: Frank Gaxiola Gaxiola		
	--Fecha: 20/Febrero/2009
	--Modificación: Se agrega validación para que solo se ejecute una vez el procedimiento
	--*********************************************************--
	
	LET vsqlerr = 0;
	LET v_codigo_retorno = "000";
	LET v_mensaje = "Migración de parentesco realizada con éxito";
	
		--SET DEBUG FILE TO '/tmp/sp_migracionRefPersonalesCred.out';
        --TRACE ON;
	
	BEGIN
		ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				let v_codigo_retorno = vsqlerr;
				RETURN v_codigo_retorno, v_mensaje;
			END IF;
		END EXCEPTION;
		
		SELECT {+  INDEX(bdisolic:ss_refpersonales inx_refcredito) } LIMIT 1 num_solicitud INTO v_cuenta FROM bdisolic:ss_refpersonales WHERE parentesco IN('P', 'M', 'J', 'H', 'A', 'E', 'T', 'B', 'O', 'U', 'C' , 'I', 'R', 'S', 'N', 'K');
		
		IF v_cuenta IS NULL THEN
		
			FOREACH
				SELECT {+  INDEX(bdisolic:ss_refpersonales inx_refcredito) } TRIM(numcte), TRIM(num_solicitud), TRIM(parentesco) INTO v_numcte, v_cuenta, v_parentesco FROM bdisolic:ss_refpersonales WHERE parentesco <> ""

				IF v_parentesco = '01' THEN
					UPDATE {+  INDEX(bdisolic:ss_refpersonales inx_refcreditos) } bdisolic:ss_refpersonales SET parentesco = 'P' WHERE numcte = v_numcte AND num_solicitud = v_cuenta AND parentesco = '01';
				END IF;
			
				IF v_parentesco = '02' THEN
					UPDATE {+  INDEX(bdisolic:ss_refpersonales inx_refcreditos) } bdisolic:ss_refpersonales SET parentesco = 'J' WHERE numcte = v_numcte AND num_solicitud = v_cuenta AND parentesco = '02';
				END IF;
			
				IF v_parentesco = '03' THEN
					UPDATE {+  INDEX(bdisolic:ss_refpersonales inx_refcreditos) } bdisolic:ss_refpersonales SET parentesco = 'H' WHERE numcte = v_numcte AND num_solicitud = v_cuenta AND parentesco = '03';
				END IF;
			
				IF v_parentesco = '04' THEN
					UPDATE {+  INDEX(bdisolic:ss_refpersonales inx_refcreditos) } bdisolic:ss_refpersonales SET parentesco = 'A' WHERE numcte = v_numcte AND num_solicitud = v_cuenta AND parentesco = '04';
				END IF;
			
				IF v_parentesco = '05' THEN
					UPDATE {+  INDEX(bdisolic:ss_refpersonales inx_refcreditos) } bdisolic:ss_refpersonales SET parentesco = 'E' WHERE numcte = v_numcte AND num_solicitud = v_cuenta AND parentesco = '05';
				END IF;
			
				IF v_parentesco = '06' THEN
					UPDATE {+  INDEX(bdisolic:ss_refpersonales inx_refcreditos) } bdisolic:ss_refpersonales SET parentesco = 'T' WHERE numcte = v_numcte AND num_solicitud = v_cuenta AND parentesco = '06';
				END IF;
			
				IF v_parentesco = '07' THEN
					UPDATE {+  INDEX(bdisolic:ss_refpersonales inx_refcreditos) } bdisolic:ss_refpersonales SET parentesco = 'B' WHERE numcte = v_numcte AND num_solicitud = v_cuenta AND parentesco = '07';
				END IF;
			
				IF v_parentesco = '08' THEN
					UPDATE {+  INDEX(bdisolic:ss_refpersonales inx_refcreditos) } bdisolic:ss_refpersonales SET parentesco = 'O' WHERE numcte = v_numcte AND num_solicitud = v_cuenta AND parentesco = '08';
				END IF;
			
				IF v_parentesco = '09' THEN
					UPDATE {+  INDEX(bdisolic:ss_refpersonales inx_refcreditos) } bdisolic:ss_refpersonales SET parentesco = 'U' WHERE numcte = v_numcte AND num_solicitud = v_cuenta AND parentesco = '09';
				END IF;
			
				IF v_parentesco = '10' THEN
					UPDATE {+  INDEX(bdisolic:ss_refpersonales inx_refcreditos) } bdisolic:ss_refpersonales SET parentesco = 'C' WHERE numcte = v_numcte AND num_solicitud = v_cuenta AND parentesco = '10';
				END IF;
			
				IF v_parentesco = '11' THEN
					UPDATE {+  INDEX(bdisolic:ss_refpersonales inx_refcreditos) } bdisolic:ss_refpersonales SET parentesco = 'I' WHERE numcte = v_numcte AND num_solicitud = v_cuenta AND parentesco = '11';
				END IF;
			
				IF v_parentesco = '12' THEN
					UPDATE {+  INDEX(bdisolic:ss_refpersonales inx_refcreditos) } bdisolic:ss_refpersonales SET parentesco = 'R' WHERE numcte = v_numcte AND num_solicitud = v_cuenta AND parentesco = '12';
				END IF;
			
				IF v_parentesco = '13' THEN
					UPDATE {+  INDEX(bdisolic:ss_refpersonales inx_refcreditos) } bdisolic:ss_refpersonales SET parentesco = 'S' WHERE numcte = v_numcte AND num_solicitud = v_cuenta AND parentesco = '13';
				END IF;	
			
				IF v_parentesco = '14' THEN
					UPDATE {+  INDEX(bdisolic:ss_refpersonales inx_refcreditos) } bdisolic:ss_refpersonales SET parentesco = 'N' WHERE numcte = v_numcte AND num_solicitud = v_cuenta AND parentesco = '14';
				END IF;
			
				IF v_parentesco = '15' THEN
					UPDATE {+  INDEX(bdisolic:ss_refpersonales inx_refcreditos) } bdisolic:ss_refpersonales SET parentesco = 'K' WHERE numcte = v_numcte AND num_solicitud = v_cuenta AND parentesco = '15';
				END IF;
			
			END FOREACH;
			
		ELSE
			LET v_mensaje = "La migración de parentesco solo se realiza una vez";
		END IF;
		
		RETURN v_codigo_retorno, v_mensaje;
		
	END;
END PROCEDURE;