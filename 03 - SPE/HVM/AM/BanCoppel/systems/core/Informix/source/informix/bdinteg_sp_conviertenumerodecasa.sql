CREATE PROCEDURE "informix".sp_conviertenumerodecasa (pnumcasa VARCHAR(20))
	RETURNING CHAR (5),VARCHAR(20), VARCHAR (20); 

-- DEFINICION DE VARIABLES
DEFINE vCaracter VARCHAR(20);
DEFINE vsRespuesta VARCHAR(20);
DEFINE vVuelta1Numeros VARCHAR(20);
DEFINE vVuelta1Letras VARCHAR(20);
DEFINE vNumFinal VARCHAR(20);
DEFINE vLetras VARCHAR (20);
DEFINE vPrimero VARCHAR (20);
DEFINE i  INTEGER;
--VARIABLES PARA MANEJADOR DE ERROR
DEFINE iSqlErr INTEGER;
DEFINE vCodRetorno Char(5);

--ASIGNACION DE VARIABLES
LET i = 0;
LET vVuelta1Letras = '0';
LET vNumFinal = '';
LET vLetras = '' ;
LET vVuelta1Numeros = '0';
LET vCaracter = '';
LET vPrimero = '';
LET vCodRetorno = '00000';

---Set debug file to '/tmp/sp_ConvierteNumerodeCasa.out';
---trace on;
	
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET vCodRetorno = iSqlErr;
				RETURN vCodRetorno, vNumFinal, vLetras;
			END IF;
		END EXCEPTION;
		
		IF pnumcasa <> '' THEN
			For i = 1 to LENGTH (pnumcasa)			
				LET vCaracter = Substr(pnumcasa,i,1);
				
				EXECUTE PROCEDURE bdinteg:"informix".sp_EsNumerico (vCaracter) INTO vsRespuesta; -- Sp para validar el tipo de caracter(numero o letra)
					
					IF vsRespuesta = 'F' AND vVuelta1Letras = '0' AND vPrimero = '' THEN 
						LET vCaracter = '1';
						LET vVuelta1Letras = '1';
						LET vNumFinal = vCaracter;		
					END IF;
					
					IF vsRespuesta = 'F' AND vVuelta1Letras = '1' AND vVuelta1Numeros = '0' AND vNumFinal <> '' AND vPrimero = '1' THEN
						LET vCaracter = '1';
						LET vNumFinal = vNumFinal||vCaracter;
					END IF;
					
					IF vsRespuesta = 'V' THEN --Encuentra el primer numero
						LET vVuelta1Numeros = '1';
						LET vNumFinal = vNumFinal||vCaracter;
					END IF;
					
					IF  vsRespuesta = 'F' AND vVuelta1Numeros = '1' THEN 
						LET vLetras = vLetras||vCaracter;
					END IF;
				LET vPrimero = '1';
			END FOR;
		ELSE
			RETURN vCodRetorno, vNumFinal, vLetras;  ---RECIBE VAR VACIA
		END IF;
		
		RETURN vCodRetorno, vNumFinal, vLetras;
	END
--*************************************************************************
--| Procedimiento   : sp_ConvierteNumerodeCasa
--| Versión         : 1.0
--| Creado por      : Martha Aguirre
--| Fecha creacion  : Noviembre de 2008
--| Descripción     : Da formato a numero de casa separando letras
--|                   y numeros en caso de que el numero de casa contenga
--|                   letras
--*************************************************************************
END PROCEDURE;