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
		FROM bdicnweb:"informix".apellido_nombre_abreviado
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
		FROM bdicnweb:"informix".nombres_novalidos
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
		FROM bdicnweb:"informix".palabra_inconveniente
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

CREATE PROCEDURE "informix".sp_obtenerhomoclave(pNombre LVARCHAR)
	RETURNING CHAR(2) AS homoclave;
	
	DEFINE i INTEGER;
	DEFINE cCaracter CHAR(1);
	DEFINE cNombreNumerico LVARCHAR;
	DEFINE iCodigoLetra SMALLINT;
	DEFINE bBoolValue BOOLEAN;
	DEFINE iSuma INTEGER;
	DEFINE iValor1 INTEGER;
	DEFINE iValor2 INTEGER;
	DEFINE iValor3 INTEGER;
	DEFINE iDiv1 INTEGER;
	DEFINE iDiv2 INTEGER;
	
	LET cCaracter = '';
	LET cNombreNumerico = '0';
	LET bBoolValue = 'f';
	LET iSuma = 0;
	LET iValor1 = 0;
	LET iValor2 = 0;
	LET iValor3 = 0;
	LET iDiv1 = 0;
	LET iDiv2 = 0;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		--SET DEBUG FILE TO '/tmp/mfinis/sp_obtenerhomoclave.out';
		--TRACE ON;
	
		FOR i = 1 TO LENGTH(TRIM(pNombre))
			LET cCaracter = UPPER(SUBSTR(TRIM(pNombre), i, 1));
			
			SELECT codigo_letra
			INTO iCodigoLetra
			FROM "informix".letras_rfc
			WHERE UPPER(letra) = cCaracter;
			
			IF iCodigoLetra IS NULL THEN
				LET bBoolValue = 'f';
			ELSE
				LET cNombreNumerico = TRIM(cNombreNumerico)||iCodigoLetra;
				LET bBoolValue = 't';
			END IF;
			
			IF NOT bBoolValue THEN
			
				IF ASCII(cCaracter) = 209 THEN -- Ã
					LET cNombreNumerico = TRIM(cNombreNumerico)||40;
				ELIF ASCII(cCaracter) = 38 THEN -- &
					LET cNombreNumerico = TRIM(cNombreNumerico)||10;
				ELSE
					IF cCaracter = ' ' THEN
						LET cNombreNumerico = TRIM(cNombreNumerico)||'00';
					ELIF cCaracter::SMALLINT >= 0 AND cCaracter::SMALLINT <= 9 THEN
						LET cNombreNumerico = TRIM(cNombreNumerico)||LPAD(cCaracter, 2, '0');
					END IF;
				END IF;
			
			END IF;
		
		END FOR;
		
		
		FOR i = 1 TO LENGTH(TRIM(cNombreNumerico)) - 1
			LET iValor1 = SUBSTR(TRIM(cNombreNumerico), i, 2)::INTEGER;
			LET iValor2 = SUBSTR(TRIM(cNombreNumerico), (i + 1), 1)::INTEGER;
			LET iValor3 = iValor1 * iValor2;
			LET iSuma = iSuma + iValor3;
		END FOR;
		
		LET iDiv1 = MOD(iSuma, 1000);
		LET iDiv2 = MOD(iDiv1, 34);
		LET iDiv1 = (iDiv1 - iDiv2) / 34;
		
		SELECT digito
		INTO cCaracter
		FROM "informix".homoclaves_rfc
		WHERE id_dverificador = (iDiv1 + 1);
		
		LET cNombreNumerico = cCaracter;
		
		SELECT digito
		INTO cCaracter
		FROM "informix".homoclaves_rfc
		WHERE id_dverificador = (iDiv2 + 1);
		
		LET cNombreNumerico = TRIM(cNombreNumerico)||cCaracter;
		
		RETURN TRIM(cNombreNumerico);
	
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 05/12/2013",
"DESCRIPCION: Funcion que separa una cadena de acuerdo a un delimitador indicado";

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
                        FROM 'informix'.letras_codigoverificador_rfc
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

CREATE PROCEDURE "informix".sp_actualizasolicitudmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pSucursal CHAR(4), pTipoOperacion SMALLINT)
	RETURNING CHAR(5) AS codret,
			CHAR(45) AS nombre_atiende;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cNombreEjecutivo CHAR(45);
	
	LET cCodRet = '';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cNombreEjecutivo = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreEjecutivo;
		END EXCEPTION;
	
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_actualizasolicitudmc.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumSolicitud = '' OR pSucursal = '' OR pTipoOperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreEjecutivo;
		END IF;
		
		-- VALIDACCIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreEjecutivo;
		END IF;
		
		IF pTipoOperacion NOT IN (1,2) THEN
			LET cCodRet = '00044';
			RETURN cCodRet, cNombreEjecutivo;
		END IF;
		
		EXECUTE PROCEDURE bdisolic:'informix'.sp_actualizasolicmc(pNumSolicitud, pSucursal, pUsuario, pTipoOperacion) INTO cCodRetSp, cNombreEjecutivo;
		
		IF cCodRetSp::SMALLINT = 3 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNombreEjecutivo;
		ELIF cCodRetSp::SMALLINT = 4 THEN
			LET cCodRet = '90000'; -- LA SOLICITUD YA ESTA SIENDO ATENDIDA POR OTRO USUARIO
			RETURN cCodRet, cNombreEjecutivo;
		ELIF cCodRetSp::SMALLINT = 5 THEN
			LET cCodRet = '90001'; -- LA SOLICITUD YA FUE ATENDIDA POR OTRO USUARIO
			RETURN cCodRet, cNombreEjecutivo;
		ELIF cCodRetSp::SMALLINT = 6 THEN
			LET cCodRet = '90002'; -- SOLICITUD SE ENVIO A ORDEN SUPERVISION CALLE POR SISTEMA
			RETURN cCodRet, cNombreEjecutivo;
		ELIF cCodRetSp::SMALLINT = 6 THEN
			LET cCodRet = '90003'; -- LA SOLICITUD NO FUE REESTABLECIDA
			RETURN cCodRet, cNombreEjecutivo;
		ELIF cCodRetSp::SMALLINT < 0 THEN
			RAISE EXCEPTION cCodRetSp::SMALLINT;
		END IF;
		
		RETURN cCodRet, cNombreEjecutivo;
		
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 12/12/2013",
"DESCRIPCION: Actualiza el estatus de una solicitud de credito para que el usuario pueda atenderla",
"BD: bdisolic";

CREATE PROCEDURE "informix".sp_consultacatalogo_productosmc(pIdFuncionDummy CHAR(10))
	RETURNING CHAR(5) AS codret,
			CHAR(40) AS nombre_prod,
			CHAR(4) AS num_producto;
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cMensajeRetorno CHAR(80);
	DEFINE cNombreProducto CHAR(40);
	DEFINE cNumProducto CHAR(4);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET cMensajeRetorno = '';
	LET cNombreProducto = '';
	LET cNumProducto = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreProducto, cNumProducto;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultacatalogo_productosmc.out';
		--TRACE ON;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_cac_consulta_productos()
			INTO cCodRetSp, cMensajeRetorno, cNombreProducto, cNumProducto
			
			IF cCodRetSp = '00001' THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cNombreProducto, cNumProducto;
			ELSE
				RETURN cCodRet, cNombreProducto, cNumProducto WITH RESUME;
			END IF;
			
		END FOREACH;
	
	END;
	
END PROCEDURE;