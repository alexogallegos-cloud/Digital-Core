CREATE PROCEDURE "informix".sp_migraciontipocasactes()
	RETURNING CHAR(6) AS Codigo_retorno, CHAR(100) as Mensaje;
	
	DEFINE v_numcte 			CHAR(20);
	DEFINE v_tipocasa        	CHAR(3);
	DEFINE v_codigo_retorno		CHAR(3);
	DEFINE vsqlerr				INTEGER;
	DEFINE v_mensaje			CHAR(100);
	
	--*********************************************************--
	-- Creado por: Frank Gaxiola Gaxiola		
	--Fecha: 29/Enero/2009
	--Objetivo: Migración de tipo de casa de los clientes
	--Modificado: Frank Gaxiola Gaxiola		
	--Fecha: 20/Febrero/2009
	--Modificación: Se agrega validación para que solo se ejecute una vez el procedimiento
	--*********************************************************--
	
	LET vsqlerr = 0;
	LET v_codigo_retorno = "000";
	LET v_mensaje = "Migración de tipo de casa realizada con éxito";
	
		--SET DEBUG FILE TO '/tmp/sp_migracionTipoCasaCtes.out';
		--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				let v_codigo_retorno = vsqlerr;
				RETURN v_codigo_retorno, v_mensaje;
			END IF;
		END EXCEPTION;
	
	SELECT {+  INDEX(bdinteg:si_ctepf inx_habitaen) } LIMIT 1 numcte INTO v_numcte FROM bdinteg:si_ctepf WHERE habita_en IN('P', 'R', 'F', 'H', 'G');
	
		IF v_numcte IS NULL THEN
		
			FOREACH
				SELECT {+  INDEX(bdinteg:si_ctepf inx_habitaen) } TRIM(numcte), TRIM(habita_en) INTO v_numcte, v_tipocasa FROM bdinteg:si_ctepf WHERE habita_en <> ""

				IF v_tipocasa = '01' THEN
					UPDATE bdinteg:si_ctepf SET habita_en = 'P' WHERE numcte = v_numcte;
				END IF;
				
				IF v_tipocasa = '02' THEN
					UPDATE bdinteg:si_ctepf SET habita_en = 'R' WHERE numcte = v_numcte;
				END IF;
				
				IF v_tipocasa = '03' THEN
					UPDATE bdinteg:si_ctepf SET habita_en = 'F' WHERE numcte = v_numcte;
				END IF;
				
				IF v_tipocasa = '04' THEN
					UPDATE bdinteg:si_ctepf SET habita_en = 'H' WHERE numcte = v_numcte;
				END IF;
				
				IF v_tipocasa = '05' THEN
					UPDATE bdinteg:si_ctepf SET habita_en = 'G' WHERE numcte = v_numcte;
				END IF;

			END FOREACH;
			
		ELSE
			LET v_mensaje = "La migración de tipo de casa solo se realiza una vez";
		END IF;
		
		RETURN v_codigo_retorno, v_mensaje;
		
	END;
END PROCEDURE;