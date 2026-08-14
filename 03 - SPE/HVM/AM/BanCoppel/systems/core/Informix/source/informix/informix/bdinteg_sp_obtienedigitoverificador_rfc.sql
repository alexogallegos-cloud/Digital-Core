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