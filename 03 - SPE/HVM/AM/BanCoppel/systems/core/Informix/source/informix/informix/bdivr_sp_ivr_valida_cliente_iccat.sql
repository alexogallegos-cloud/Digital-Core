CREATE PROCEDURE "informix".sp_ivr_valida_cliente_iccat(pnumTelefono CHAR(10), popcionAcceso CHAR(16))
RETURNING CHAR(5); -- CÃDIGO DE RETORNO

-- DECLARACIÃN DE VARIABLES
DEFINE error_sql 			INTEGER;
DEFINE vnumCte				CHAR(9);
DEFINE vcodret				VARCHAR(5);
DEFINE vnumTelRegisrado		CHAR(10);
DEFINE vopcionAcceso		SMALLINT;
-- DEFINE pnumTelefono		VARCHAR(10);
-- DEFINE vnumtarjeta		VARCHAR(16);

-- INICIALIZACIÃN DE VARIABLES
LET vnumCte 				= '';
LET vcodret 				= '00000';
LET vnumTelRegisrado 		= '';
LET vopcionAcceso 			= 0;
-- LET pnumTelefono 		= '';
-- LET vnumtarjeta 			= '';

-- SET DEBUG FILE TO "/tmp/clizarraga/sp_ivr_valida_cliente_iccat.out";
-- TRACE ON;

BEGIN
    ON EXCEPTION SET error_sql
        IF error_sql != 0 THEN
            LET vcodret = error_sql;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- SE VALIDA QUE LA INFORMACIÃN CAPTURADA NO ESTÃ VACÃA NI COMPUESTA DE ESPACIOS EN BLANCO
	IF (TRIM(NVL(popcionAcceso, '')) != '') THEN
		LET vopcionAcceso = LENGTH(popcionAcceso);

		IF vopcionAcceso NOT IN (9, 11, 12, 16) THEN
			LET vcodret = '00001'; -- INFORMACIÃN DE ACCESO INVÃLIDA
			RETURN vcodret;
		END IF;

		-- VALIDACIÃN DE INFORMACIÃN DE ACCESO POR NÃMERO DE CLIENTE
		IF vopcionAcceso = 9 THEN
			SELECT numcte
				INTO vnumCte
				FROM bdinteg:"informix".si_cliente 
				WHERE numcte = popcionAcceso;

			IF (TRIM(vnumCte) IS NULL) OR (TRIM(vnumCte) = '') THEN
				LET vcodret = '00011'; -- NÃMERO DE CLIENTE INGRESADO INVÃLIDO
				RETURN vcodret;
			END IF;
		END IF;

		-- VALIDACIÃN DE INFORMACIÃN DE ACCESO POR NÃMERO DE CUENTA
		IF vopcionAcceso = 11 THEN
			SELECT num_cte
				INTO vnumCte
				FROM bdicheq:sc_maechq
				WHERE cuenta = popcionAcceso;
				
			IF (TRIM(vnumCte) IS NULL) OR (TRIM(vnumCte) = '') THEN
				LET vcodret = '00012'; -- NÃMERO DE CUENTA INGRESADO INVÃLIDO
				RETURN vcodret;
			END IF;
		END IF;

		-- VALIDACIÃN DE INFORMACIÃN DE ACCESO POR NÃMERO DE CRÃDITO
		IF vopcionAcceso = 12 THEN
			SELECT numcte
				INTO vnumCte
				FROM bdicred:sd_maecred
				WHERE num_credito = popcionAcceso;

			IF (TRIM(vnumCte) IS NULL) OR (TRIM(vnumCte) = '') THEN
				LET vcodret = '00013'; -- NÃMERO DE CRÃDITO INGRESADO INVÃLIDO
				RETURN vcodret;
			END IF;
		END IF;
		
		-- VALIDACIÃN DE INFORMACIÃN DE ACCESO POR NÃMERO DE TARJETA
		IF vopcionAcceso = 16 THEN
			SELECT numcliente
				INTO vnumCte
				FROM intercard:tarjeta
				WHERE numtarjeta = popcionAcceso;
				
			IF (TRIM(vnumCte) IS NULL) OR (TRIM(vnumCte) = '') THEN
				LET vcodret = '00014'; -- NÃMERO DE TARJETA INGRESADO INVÃLIDO
				RETURN vcodret;
			END IF;
		END IF;
	ELSE
		LET vcodret = '00001'; -- INFORMACIÃN DE ACCESO INVÃLIDA
		RETURN vcodret;
	END IF;
	
	-- INFORMACIÃN DE ACCESO VÃLIDA
	/*
	IF (vcodret = '00000') THEN
		-- VERIFICACIÃN DE QUE EL CLIENTE TENGA UN NÃMERO DE TELÃFONO REGISTRADO
		SELECT COUNT(*)
			INTO vnumTelRegisrado
			FROM bdinteg:"informix".si_telefonos_actual
			WHERE numcte = vnumCte
				AND telefono = pnumTelefono
				AND tipo_tel = 1; -- TELÃFONO DE CASA

		IF vnumTelRegisrado = 0 THEN
			SELECT COUNT(*)
				INTO vnumTelRegisrado
				FROM bdinteg:"informix".si_telefonos_actual
				WHERE numcte = vnumCte
					AND telefono = pnumTelefono
					AND tipo_tel = 2; -- TELÃFONO CELULAR
					
			IF vnumTelRegisrado = 0 THEN
				LET vcodret = '00021'; -- NÃMERO DE TELÃFONO INVÃLIDO
				RETURN vcodret;
			END IF;
		END IF;

	END IF;
	*/

	-- SI LAS VALIDACIONES FUERON CORRECTAS, SE RECOPILA INFORMACIÃN DEL CLIENTE EN LA TABLA DE CLIENTES ICCAT
	INSERT INTO bdivr:si_cliente_iccat(telefono, numcliente, fecha)
	VALUES (pnumTelefono, vnumCte, current);
	
END;
RETURN vcodret;
END PROCEDURE;