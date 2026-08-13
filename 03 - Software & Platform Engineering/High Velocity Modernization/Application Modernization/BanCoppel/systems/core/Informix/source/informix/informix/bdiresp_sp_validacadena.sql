CREATE PROCEDURE "informix".sp_validacadena(pcCadena CHAR(100), pcValidaLetras CHAR(1), pcValidaNumeros CHAR(1), pcValidaCarAdicional VARCHAR(255))
	RETURNING CHAR(5) AS Retorno;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Valida una cadena ya sea con letras, numeros, algun caracter -----------------------
	-- en especial o combinados -------------------------------------------------------------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 04/10/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	-- MODIFICACIÓN: Se eliminaron las referencias a la BD bdiresp de los sp's propios de esta.
	-- AUTOR: Moisés Soriano
	-- FECHA : 26/02/2013
	-- BD: bdiresp
	*/
	
	DEFINE viCodigo				INT;
	DEFINE vcCodRet				CHAR(5);
	DEFINE vilongitud			INT;
	DEFINE viCuenta				INT;
	DEFINE vcSubcadena			CHAR(1);
	DEFINE viEncuentraCadena 	INT;
		
	LET viCodigo			= 	0;
	LET vcCodRet			= 	'00000';
	LET vilongitud			= 	0;
	LET viCuenta			= 	0;
	LET vcSubcadena			= 	'';
	LET viEncuentraCadena 	= 	0;
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;		
		RETURN NVL(vcCodRet,'');
	END EXCEPTION;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF ( TRIM(NVL(pcCadena,'')) = '' ) THEN
		LET vcCodRet = '00001';
	ELSE
		LET vilongitud = LENGTH(pcCadena);
		FOR viCuenta = 1 TO vilongitud		  
			LET vcSubcadena = SUBSTR(pcCadena,viCuenta,1);
			IF (TRIM(NVL(pcValidaLetras,'')) = '1') THEN
				IF (TRIM(NVL(pcValidaNumeros,'')) = '1') THEN					
					IF ( ASCII(vcSubcadena) < 48 OR (ASCII(vcSubcadena) > 57 AND ASCII(vcSubcadena) < 65) OR (ASCII(vcSubcadena) > 90 AND ASCII(vcSubcadena) < 97 ) OR ASCII(vcSubcadena) > 122 AND ASCII(vcSubcadena) <>209 AND ASCII(vcSubcadena) <>241) THEN
						IF ( NOT pcValidaCarAdicional IS NULL ) THEN 
							EXECUTE PROCEDURE sp_buscaCaracter(pcValidaCarAdicional, vcSubcadena) INTO viEncuentraCadena;
							IF viEncuentraCadena <= 0 THEN
								LET vcCodRet = '00002';
								EXIT FOR;
							ELSE CONTINUE FOR;
							END IF;
						ELSE
							LET vcCodRet = '00002';
							EXIT FOR;
						END IF;
					ELSE CONTINUE FOR;
					END IF;
				ELSE					
					IF ( ASCII(vcSubcadena) < 65 OR (ASCII(vcSubcadena) > 90 AND ASCII(vcSubcadena) < 97 ) OR ASCII(vcSubcadena) > 122 AND ASCII(vcSubcadena) <>209 AND ASCII(vcSubcadena) <>241) THEN
						IF ( NOT pcValidaCarAdicional IS NULL ) THEN 
							EXECUTE PROCEDURE sp_buscaCaracter(pcValidaCarAdicional, vcSubcadena) INTO viEncuentraCadena;
							IF viEncuentraCadena <= 0 THEN
								LET vcCodRet = '00002';
								EXIT FOR;
							ELSE CONTINUE FOR;
							END IF;
						ELSE
							LET vcCodRet = '00002';
							EXIT FOR;
						END IF;
					ELSE CONTINUE FOR;
					END IF;
				END IF;
			ELSE
				IF (TRIM(NVL(pcValidaNumeros,'')) = '1') THEN					
					IF ( ASCII(vcSubcadena) < 48 OR ASCII(vcSubcadena) > 57) THEN
						IF ( NOT pcValidaCarAdicional IS NULL ) THEN 
							EXECUTE PROCEDURE sp_buscaCaracter(pcValidaCarAdicional, vcSubcadena) INTO viEncuentraCadena;
							IF viEncuentraCadena <= 0 THEN
								LET vcCodRet = '00002';
								EXIT FOR;
							ELSE CONTINUE FOR;
							END IF;
						ELSE
							LET vcCodRet = '00002';
							EXIT FOR;
						END IF;
					ELSE CONTINUE FOR;
					END IF;
				ELSE					
					IF ( NOT pcValidaCarAdicional IS NULL ) THEN 
						EXECUTE PROCEDURE sp_buscaCaracter(pcValidaCarAdicional, vcSubcadena) INTO viEncuentraCadena;
						IF viEncuentraCadena <= 0 THEN
							LET vcCodRet = '00002';
							EXIT FOR;
						ELSE CONTINUE FOR;
						END IF;
					ELSE
						LET vcCodRet = '00002';
						EXIT FOR;
					END IF;
					
				END IF;
			END IF;
		END FOR
	END IF;		
	
	RETURN vcCodRet;
	END;
END PROCEDURE;