CREATE PROCEDURE "informix".sp_calcularrfcpba(pApellidoPaterno CHAR(26), pApellidoMaterno CHAR(26), pNombre CHAR(55), pFechaNacimiento DATE)
        RETURNING CHAR(5) AS codret,
                        CHAR(13) AS rfc;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cRfc CHAR(13);
        DEFINE cCaracter CHAR(1);
        DEFINE i SMALLINT;
        DEFINE bBoolValue BOOLEAN;
        DEFINE lPalabra LVARCHAR;
        DEFINE bSalirBucle BOOLEAN;
        -- Variables de RFC
        DEFINE cPrimerLetraApellidoPaterno CHAR(1);
        DEFINE cVocalApellidoPaterno CHAR(1);
        DEFINE cPrimerLetraApellidoMaterno CHAR(1);
        DEFINE cPrimerLetraNombre CHAR(1);
        DEFINE cFechaNacimientos CHAR(6);
        DEFINE cHomoclave CHAR(2);
        DEFINE cDigitoVerificador CHAR(2);
		DEFINE cApellidoMaterno CHAR(26);

    DEFINE iCont INTEGER;
    DEFINE lPalabra2 LVARCHAR;
    LET iCont=0;
    LET lPalabra2 = '';

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cRfc = '';
        LET cCaracter = '';
        LET bBoolValue = 'f';
        LET lPalabra = '';
        LET bSalirBucle = 'f';
        LET cPrimerLetraApellidoPaterno = '';
        LET cVocalApellidoPaterno = '';
        LET cPrimerLetraApellidoMaterno = 'X';
        LET cPrimerLetraNombre = '';
        LET cFechaNacimientos = '';
        LET cHomoclave = '';
        LET cDigitoVerificador = '';
		LET cApellidoMaterno = pApellidoMaterno;

        BEGIN

                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cRfc;
                END EXCEPTION;

                SET DEBUG FILE TO 'sp_calcularrfc.out';
                TRACE ON;

                IF pNombre = '' OR pFechaNacimiento IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cRfc;
                END IF;

                IF pApellidoPaterno = '' AND pApellidoMaterno = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cRfc;
                END IF;

                LET pApellidoPaterno = UPPER(pApellidoPaterno);
                LET pApellidoMaterno = UPPER(pApellidoMaterno);
                LET pNombre = UPPER(pNombre);

                FOR i = 0 TO LENGTH(TRIM(pApellidoPaterno))
                        LET cCaracter = SUBSTR(TRIM(pApellidoPaterno), i, 1);
                        EXECUTE FUNCTION "informix".sp_sololetrasnumeros(cCaracter) INTO bBoolValue;

                        IF NOT bBoolValue THEN
                                LET cCodRet = '00221'; -- CARACTER RARO EN EL APELLIDO PATERNO
                                RETURN cCodRet, cRfc;
                        END IF;
                END FOR;

                FOR i = 0 TO LENGTH(TRIM(pApellidoMaterno))
                        LET cCaracter = SUBSTR(TRIM(pApellidoMaterno), i, 1);
                        EXECUTE FUNCTION "informix".sp_sololetrasnumeros(cCaracter) INTO bBoolValue;

                        IF NOT bBoolValue THEN
                                LET cCodRet = '00222'; -- CARACTER RARO EN EL APELLIDO MATERNO
                                RETURN cCodRet, cRfc;
                        END IF;
                END FOR;

                FOR i = 0 TO LENGTH(TRIM(pNombre))
                        LET cCaracter = SUBSTR(TRIM(pNombre), i, 1);
                        EXECUTE FUNCTION "informix".sp_sololetrasnumeros(cCaracter) INTO bBoolValue;

                        IF NOT bBoolValue THEN
                                LET cCodRet = '00223'; -- CARACTER RARO EN EL NOMBRE
                                RETURN cCodRet, cRfc;
                        END IF;
                END FOR;

                -- SI SOLO TIENE UN APELLIDO TOMARLO COMO PATERNO
                IF TRIM(pApellidoPaterno) = '' AND TRIM(pApellidoMaterno) <> '' THEN
                        LET pApellidoPaterno = pApellidoMaterno;
                        LET pApellidoMaterno = '';
                END IF;

                -- Se Obtiene la primera letra y la primer vocal del apellido
                IF TRIM(pApellidoPaterno) <> '' THEN
						--CONTADOR DE APELLIDO
						FOREACH EXECUTE FUNCTION "informix".sp_split_cadena(pApellidoPaterno, ' ') INTO lPalabra2
							Let iCont=iCont+1;
							--RETURN iCont, 'CONTADOR';
						END FOREACH;


                        FOREACH EXECUTE FUNCTION "informix".sp_split_cadena(pApellidoPaterno, ' ') INTO lPalabra

                                -- Verificar que el apellido no este abreviado
                                EXECUTE FUNCTION "informix".sp_esnombre_apellido_abreviado(lPalabra) INTO bBoolValue;
                                IF bBoolValue THEN -- EL APELLIDO ESTA ABREVIADO
                                        LET cCodRet = '00224'; -- APELLIDO PATERNO ABREVIADO
                                        RETURN cCodRet, cRfc;
                                ELSE -- EL APELLIDO PATERNO NO ESTA ABREVIADO
                                        -- SE VALIDA QUE SEA UN APELLIDO VALIDO
								IF iCont>1 THEN
									EXECUTE FUNCTION "informix".sp_esapellido_valido(lPalabra) INTO bBoolValue;
								ELSE
									LET bBoolValue='t';
								END IF;

                                        IF bBoolValue THEN
                                                LET cPrimerLetraApellidoPaterno = SUBSTR(TRIM(lPalabra), 1, 1);
                                                -- SE BUSCA LA PRIMERA VOCAL DEL APELLIDO
                                                IF LENGTH(TRIM(lPalabra)) > 1 THEN
                                                        FOR i = 2 TO LENGTH(TRIM(lPalabra))
                                                                LET cCaracter = SUBSTR(TRIM(lPalabra), i, 1);
                                                                EXECUTE FUNCTION "informix".sp_esvocal(cCaracter) INTO bBoolValue;
                                                                IF bBoolValue THEN
                                                                        LET cVocalApellidoPaterno = cCaracter;
                                                                        LET bSalirBucle = 't';
                                                                        EXIT FOR;
                                                                --ELSE
                                                                --      LET cVocalApellidoPaterno = 'X';
                                                                END IF;
                                                        END FOR;
                                                        LET bSalirBucle = 't';
                                                ELSE
                                                        LET bSalirBucle = 't';
                                                END IF;

                                                IF bSalirBucle THEN
                                                        EXIT FOREACH;
                                                END IF;
                                        END IF;

                                END IF;

                        END FOREACH;
                END IF;
                LET bSalirBucle = 'f';

                -- Se Obtiene la primera letra apellido materno
                IF TRIM(pApellidoMaterno) <> '' THEN
                        FOREACH EXECUTE FUNCTION "informix".sp_split_cadena(pApellidoMaterno, ' ') INTO lPalabra

                                -- Verificar que el apellido no este abreviado
                                EXECUTE FUNCTION "informix".sp_esnombre_apellido_abreviado(lPalabra) INTO bBoolValue;
                                IF bBoolValue THEN -- EL APELLIDO ESTA ABREVIADO
                                        LET cCodRet = '00225'; -- APELLIDO MATERNO ABREVIADO
                                        RETURN cCodRet, cRfc;
                                ELSE -- EL APELLIDO MATERNO NO ESTA ABREVIADO
                                        -- SE VALIDA QUE SEA UN APELLIDO VALIDO
                                        EXECUTE FUNCTION "informix".sp_esapellido_valido(lPalabra) INTO bBoolValue;

                                        IF bBoolValue THEN
                                                LET cPrimerLetraApellidoMaterno = SUBSTR(TRIM(lPalabra), 1, 1);
                                                EXIT FOREACH;
                                        END IF;

                                END IF;

                        END FOREACH;
                END IF;

				--TRACE '-----------------------------------------------------';
				--TRACE '>>>>>'||cPrimerLetraApellidoPaterno||cVocalApellidoPaterno||cPrimerLetraApellidoMaterno||cPrimerLetraNombre;

                -- Se obtiene la primer letra del nombre
                IF TRIM(pNombre) <> '' THEN

                        FOREACH EXECUTE FUNCTION "informix".sp_split_cadena(pNombre, ' ') INTO lPalabra

                                -- Revisar que el nombre no este abreviado
                                EXECUTE FUNCTION "informix".sp_esnombre_apellido_abreviado(lPalabra) INTO bBoolValue;
                                IF bBoolValue THEN
                                        LET cCodRet = '00226'; -- NOMBRE ABREVIADO
                                        RETURN cCodRet, cRfc;
                                ELSE
                                        EXECUTE FUNCTION "informix".sp_esnombre_valido(TRIM(lPalabra)) INTO bBoolValue;

                                        IF bBoolValue THEN
												--TRACE '*********************************';
                                                IF cVocalApellidoPaterno = '' THEN
                                                        LET cVocalApellidoPaterno = cPrimerLetraApellidoMaterno;
                                                        LET cPrimerLetraApellidoMaterno = SUBSTR(TRIM(lPalabra), 1, 1);
                                                        LET cPrimerLetraNombre = SUBSTR(TRIM(lPalabra), 2, 1);
                                                ELSE
                                                        IF TRIM(pApellidoMaterno) = '' THEN
                                                                LET cPrimerLetraApellidoMaterno = SUBSTR(TRIM(lPalabra), 1, 1);
                                                                LET cPrimerLetraNombre = SUBSTR(TRIM(lPalabra), 2, 1);
                                                        ELSE
                                                                LET cPrimerLetraNombre = SUBSTR(TRIM(lPalabra), 1, 1);
                                                        END IF;
                                                END IF;
                                                EXIT FOREACH;
                                        ELSE
                                                IF TRIM(lPalabra) = 'MARIA' OR TRIM(lPalabra) = 'JOSE' OR TRIM(lPalabra) = 'MA' OR TRIM(lPalabra) = 'M' OR TRIM(lPalabra) = 'J' THEN
                                                        IF cVocalApellidoPaterno = '' THEN
                                                                LET cVocalApellidoPaterno = cPrimerLetraApellidoMaterno;
																LET pApellidoMaterno = '';
                                                                LET cPrimerLetraApellidoMaterno = SUBSTR(TRIM(lPalabra), 1, 1);
                                                                LET cPrimerLetraNombre = SUBSTR(TRIM(lPalabra), 2, 1);
                                                        ELSE
                                                                LET cPrimerLetraNombre = SUBSTR(TRIM(lPalabra), 1, 1);
                                                        END IF;
                                                END IF;
                                        END IF;

                                END IF;

                        END FOREACH;

                END IF;

				LET pApellidoMaterno = cApellidoMaterno;

                LET cRfc = cPrimerLetraApellidoPaterno||cVocalApellidoPaterno||cPrimerLetraApellidoMaterno||cPrimerLetraNombre;
                -- Busqueda de palabra Altisonante
                EXECUTE FUNCTION "informix".sp_espalabra_altisonante(TRIM(cRfc)) INTO bBoolValue;
                IF bBoolValue THEN
                        LET cPrimerLetraNombre = 'X';
                END IF;

                LET cFechaNacimientos = TO_CHAR(pFechaNacimiento, '%y%m%d');
                LET cRfc =      cPrimerLetraApellidoPaterno||cVocalApellidoPaterno||cPrimerLetraApellidoMaterno||cPrimerLetraNombre||cFechaNacimientos;

                -- ObtenciÃ³n de la homoclave
                LET lPalabra = UPPER(TRIM(pApellidoPaterno))||' '||UPPER(TRIM(pApellidoMaterno))||' '||UPPER(TRIM(pNombre));
                EXECUTE FUNCTION "informix".sp_obtenerhomoclave(lPalabra) INTO cHomoclave;

                -- ObtenciÃ³n del digito verificador
                LET cRfc = TRIM(cRfc)||cHomoclave;
                EXECUTE FUNCTION "informix".sp_obtienedigitoverificador_rfc(TRIM(cRfc)) INTO cDigitoVerificador;

                LET cRfc =      cPrimerLetraApellidoPaterno||cVocalApellidoPaterno||cPrimerLetraApellidoMaterno||cPrimerLetraNombre||cFechaNacimientos||cHomoclave||cDigitoVerificador;
                RETURN cCodRet, cRfc;
        END;

END PROCEDURE
DOCUMENT
"AUTOR: Oscar Flores Conde",
"FECHA: 05/12/2013",
"DESCRIPCION: Funcion que genera el RFC de un cliente";

CREATE PROCEDURE "informix".sp_esnombre_apellido_abreviado(pPalabra CHAR(26))
	RETURNING BOOLEAN AS es_palabra_abreviada;
	
	DEFINE bEsPalabraAbreviada BOOLEAN;
	DEFINE cPalabra CHAR(26);
	
	LET bEsPalabraAbreviada = 'f';
	LET pPalabra = UPPER(pPalabra);
	LET cPalabra = '';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		
		SELECT apellido_nombre_abreviado
		INTO cPalabra
		FROM bdinteg:"informix".apellido_nombre_abreviado
		WHERE apellido_nombre_abreviado = pPalabra;
		
		IF cPalabra IS NOT NULL THEN
			LET bEsPalabraAbreviada = 't';
		END IF;
		
		RETURN bEsPalabraAbreviada;
		
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 04/12/2013",
"DESCRIPCION: Funcion que revisa si el parametro de entrada es un nombre o apellido abreviado, deveulve un booleano";

CREATE PROCEDURE "informix".sp_esnombre_valido(pNombre CHAR(26))
	RETURNING BOOLEAN AS es_nombre_valido;
	
	DEFINE bEsNombreValido BOOLEAN;
	DEFINE cNombre CHAR(26);
	
	LET bEsNombreValido = 't';
	LET pNombre = UPPER(pNombre);
	LET cNombre = '';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		
		SELECT nombre_novalido
		INTO cNombre
		FROM bdinteg:"informix".nombres_novalidos
		WHERE nombre_novalido = pNombre;
		
		IF cNombre IS NOT NULL THEN
			LET bEsNombreValido = 'f';
		END IF;
		
		RETURN bEsNombreValido;
		
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 04/12/2013",
"DESCRIPCION: Funcion que revisa si la palabra de entrada es valida, deveulve un booleano";

CREATE PROCEDURE "informix".sp_espalabra_altisonante(pPalabra CHAR(10))
	RETURNING BOOLEAN AS es_palabra_altisonante;

	DEFINE bEsPalabraAltisonante BOOLEAN;
	DEFINE cPalabra CHAR(10);

	LET bEsPalabraAltisonante = 'f';
	LET pPalabra = UPPER(pPalabra);
	LET cPalabra = '';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN

		SELECT palabra_incoveniente
		INTO cPalabra
		FROM bdinteg:"informix".palabra_inconveniente
		WHERE palabra_incoveniente = pPalabra;

		IF cPalabra IS NOT NULL THEN
			LET bEsPalabraAltisonante = 't';
		END IF;

		RETURN bEsPalabraAltisonante;

	END;

END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 04/12/2013",
"DESCRIPCION: Funcion que revisa si el parametro de entrada es una palabra altisonante, deveulve un booleano";

CREATE PROCEDURE "informix".sp_esvocal(pLetra CHAR(1))
	RETURNING BOOLEAN as esvocal;
	
	DEFINE bEsVocal BOOLEAN;
	
	LET bEsVocal = 'f';
	LET pLetra = UPPER(pLetra);

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
	
		IF pLetra = 'A' THEN
			LET bEsVocal = 't';
		ELIF pLetra = 'E' THEN
			LET bEsVocal = 't';
		ELIF pLetra = 'I' THEN
			LET bEsVocal = 't';
		ELIF pLetra = 'O' THEN
			LET bEsVocal = 't';
		ELIF pLetra = 'U' THEN
			LET bEsVocal = 't';
		END IF;
	
		RETURN bEsVocal;
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 04/12/2013",
"DESCRIPCION: Funcion que revisa si un caracter es vocal, deveulve un booleano";

CREATE PROCEDURE "informix".sp_obtienedigitoverificador_rfc(pRfc CHAR(13))
        RETURNING CHAR(1) AS digito_verificador;
        
        DEFINE cCaracter CHAR(1);
        DEFINE bBoolValue BOOLEAN;
        DEFINE i SMALLINT;
        DEFINE iCodigoLetra SMALLINT;
        DEFINE iOperacion INTEGER;
        DEFINE iModulo INTEGER;
        
        LET cCaracter = '';
        LET bBoolValue = 'f';
        LET iOperacion = 0;
        LET iModulo = 0;
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        BEGIN
        
                --SET DEBUG FILE TO '/tmp/mfinis/sp_obtienedigitoverificador_rfc.out';
                --TRACE ON;
                
                FOR i = 1 TO LENGTH(TRIM(pRfc))
                        
                        LET cCaracter = SUBSTR(TRIM(pRfc), i, 1);
                        
                        SELECT codigo_letra
                        INTO iCodigoLetra
                        FROM "informix".letras_codigoverificador_rfc
                        WHERE letra = cCaracter;
                        
                        IF iCodigoLetra IS NULL THEN
                                LET bBoolValue = 'f';
                        ELSE
                                LET bBoolValue = 't';
                        END IF;
                        
                        IF NOT bBoolValue THEN
                        
                                IF cCaracter = '' THEN
                                        LET iCodigoLetra = 24;
                                ELSE
                                        IF cCaracter = ' ' THEN
                                                LET iCodigoLetra = 37;
                                        ELSE
                                                IF cCaracter::INTEGER >= 0 AND cCaracter::INTEGER <= 9 AND ASCII(cCaracter) NOT IN (209) THEN
                                                        LET iCodigoLetra = cCaracter::INTEGER;
                                                ELSE
                                                        LET iCodigoLetra = 0;
                                                END IF;
                                        END IF;
                                END IF;
                        END IF;
                        
                        LET iOperacion = iOperacion + (iCodigoLetra * (14 - i));
                        
                END FOR;
                
                LET iModulo = ABS(MOD(iOperacion, 11));
                
                IF iModulo = 0 THEN
                        LET cCaracter = 0;
                ELIF iModulo > 0 THEN--AND iModulo != 10 
                        LET iOperacion = 11 - iModulo;
						IF iOperacion = 10 THEN
							LET cCaracter = 'A';
						ELSE
							LET cCaracter = iOperacion;
						END IF;
                --ELIF iModulo = 10 THEN
                --        LET cCaracter = 'A';
                END IF;
                
                RETURN cCaracter;
                
        END;
        
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 05/12/2013",
"DESCRIPCION: Funcion que obtiene el digito verificador, devuelve un caracter";

CREATE PROCEDURE "informix".sp_sololetrasnumeros(pCaracter CHAR(1))
	RETURNING BOOLEAN AS es_letra_numero;
	
	DEFINE bEsLetraNumero BOOLEAN;
	DEFINE iAscii SMALLINT;
	
	LET bEsLetraNumero = 't';
	LET iAscii = 0;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		LET iAscii = ASCII(pCaracter);
		
		IF NOT ((iAscii >= 97 AND iAscii <= 122)  OR (iAscii >= 65 AND iAscii <= 90) OR (iAscii >= 48 AND iAscii <= 57) OR iAscii = 32 OR iAscii = 209) THEN
			LET bEsLetraNumero = 'f';
		END IF;
		
		RETURN bEsLetraNumero;
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 04/12/2013",
"DESCRIPCION: Funcion que revisa si el parametro de entrada es un caracter o numero, deveulve un booleano";

CREATE PROCEDURE "informix".sp_split_cadena(pCadena LVARCHAR, pDelimitador CHAR(1))
	RETURNING LVARCHAR AS palabra;
	
	DEFINE tPalabra LVARCHAR;
	DEFINE i INTEGER;
	DEFINE iTamCad INTEGER;
	DEFINE iInicioCadena INTEGER;
	DEFINE iRecuperarCaracteres INTEGER;
	DEFINE cCaracter CHAR(1);
	DEFINE cPalabra LVARCHAR;
	
	LET tPalabra = '';
	LET iTamCad = LENGTH(TRIM(pCadena));
	LET cCaracter = '';
	LET cPalabra = '';
	LET iInicioCadena = 1;
	LET iRecuperarCaracteres = 0;

        --SET DEBUG FILE TO '/tmp/sp_split_cadena.SQL';
		--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	BEGIN
	
		FOR i IN (1 TO iTamCad) LOOP
		
			LET cCaracter = SUBSTR(TRIM(pCadena), i, 1);
			LET iRecuperarCaracteres = iRecuperarCaracteres + 1;
			
			IF cCaracter = pDelimitador THEN
				LET iRecuperarCaracteres = iRecuperarCaracteres - 1;
				
				--TRACE iInicioCadena||' -> '|| iRecuperarCaracteres;
				LET cPalabra = SUBSTR(TRIM(pCadena), iInicioCadena, iRecuperarCaracteres);
				LET iInicioCadena = i + 1;
				LET iRecuperarCaracteres = 0;
				
				IF cPalabra <> '' THEN
					RETURN cPalabra WITH RESUME;
				END IF;
			END IF;
			
		END LOOP;
		
		LET cPalabra = SUBSTR(TRIM(pCadena), iInicioCadena, iRecuperarCaracteres);
		IF cPalabra <> '' THEN
			RETURN cPalabra;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 04/12/2013",
"DESCRIPCION: Funcion que separa una cadena de acuerdo a un delimitador indicado";

CREATE PROCEDURE "informix".sp_cifra_archivo_chq_pba( pCodigo CHAR(20) ) 
RETURNING CHAR(5);
    
    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3	        CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr	        CHAR(150);
    DEFINE vUsuario         CHAR(20);
    DEFINE vLLave           CHAR(200);
    DEFINE vNomarch         CHAR(100);
    DEFINE vRutaOrigen      CHAR(100);
    DEFINE vRutaDestino     CHAR(100);
    DEFINE vNomarchSalida   CHAR(100);
    DEFINE vRutaOriginales  CHAR(100);
    DEFINE vNomarch_salida  CHAR(100);
    
    
    LET cCodRet         = '';
    LET cCodRet2        = 0;
    LET cCodRet3        = '';
    LET iSqlErr         = 0;
    LET iSamErr         = 0;
    LET cDesErr         = '';
    LET vUsuario        = '';
    LET vLLave          = '';
    LET vNomarch        = '';
    LET vRutaOrigen     = '';
    LET vRutaDestino    = '';
    LET vNomarchSalida  = '';
    LET vRutaOriginales = '';
    LET vNomarch_salida = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cifra_archivo_chq.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cifra_archivo_chq.out";
    TRACE ON;
    
    FOREACH
        SELECT TRIM(usuario), TRIM(llave), TRIM(nomarch), TRIM(ruta_origen), TRIM(nomarch_salida), TRIM(ruta_destino), TRIM(ruta_originales)
          INTO vUsuario, vLLave, vNomarch, vRutaOrigen, vNomarch_salida, vRutaDestino, vRutaOriginales    
          FROM bdinteg:si_configura_pgp_chq
         WHERE codigo = pCodigo
         ORDER BY secuencia
        
        IF vUsuario <> user THEN
            LET cCodRet = '200';
            RETURN cCodRet;
        END IF;
        
        SYSTEM 'echo "export PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/'||TRIM(vUsuario)||'/bin:/usr/bin/X11:/sbin:.:/opt/pgp/bin:/informix/bin" > '||TRIM(vRutaOrigen)||'blinda_archivo.sh';
        SYSTEM 'echo "export HOME=/home/'||TRIM(vUsuario)||'" >> '||TRIM(vRutaOrigen)||'blinda_archivo.sh';
        SYSTEM 'echo "/opt/pgp/bin/pgp --encrypt -i '||TRIM(vRutaOrigen)||TRIM(vNomarch)||' -r '||''''||TRIM(vLLave)||''''||" --armor --compression --output "||TRIM(vRutaDestino)||TRIM(vNomarch_salida)||'" >> '||TRIM(vRutaOrigen)||'blinda_archivo.sh';
        SYSTEM '/usr/bin/chmod 777 '||TRIM(vRutaOrigen)||'blinda_archivo.sh';   
        SYSTEM '/usr/bin/sh '||TRIM(vRutaOrigen)||'blinda_archivo.sh';
        SYSTEM '/usr/bin/mv '||TRIM(vRutaOrigen)||TRIM(vNomarch)||' '||vRutaOriginales; 
    END FOREACH;
    
    LET cCodRet = '000';
    
    RETURN cCodRet;
    
    END;
    
END PROCEDURE;