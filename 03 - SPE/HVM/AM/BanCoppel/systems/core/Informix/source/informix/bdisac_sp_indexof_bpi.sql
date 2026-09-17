CREATE PROCEDURE "informix".sp_indexof_bpi(pCadena CHAR(20),pLetra CHAR(1))
	RETURNING CHAR(5) AS CodRetorno,
	INT AS Posicion;

-- ELABORO: 	ING CRUZ
-- FECHA:		06-05-2013
-- PROYECTO: 	PAGOS GDF BPI
-- DESCRIPCION:	DECODIFICA LA LINEA BASE CLAVES 36 - 45

--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE iLength int;
DEFINE iPosicion int;
DEFINE i int;
--Inicializacion de Variables
LET iSqlErr 	= 0;
LET cCodRet 	= '00000';
LET iLength = 0;
LET iPosicion = -1;
LET i = 0;

--SET DEBUG FILE TO '/home/informix/bibiana/sp_obtienelineabase.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet, iPosicion;
		END IF;
	END EXCEPTION;
	
	IF ((TRIM(nvl(pCadena,''))=='')OR(TRIM(NVL(pLetra,''))=='')) THEN
		LET cCodRet = '00001';
	ELSE
		LET iLength = LENGTH(pCadena);
		IF(iLength==1)THEN
			LET cCodRet = '00002';
		ELSE
			FOR i = 1 TO 20

				IF i = 1 THEN 
					IF(pCadena[1,1]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 2 THEN 
					IF(pCadena[2,2]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 3 THEN 
					IF(pCadena[3,3]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 4 THEN 
					IF(pCadena[4,4]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 5 THEN 
					IF(pCadena[5,5]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 6 THEN 
					IF(pCadena[6,6]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 7 THEN 
					IF(pCadena[7,7]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 8 THEN 
					IF(pCadena[8,8]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 9 THEN 
					IF(pCadena[9,9]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 10 THEN 
					IF(pCadena[10,10]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 11 THEN 
					IF(pCadena[11,11]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 12 THEN 
					IF(pCadena[12,12]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 13 THEN 
					IF(pCadena[13,13]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 14 THEN 
					IF(pCadena[14,14]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 15 THEN 
					IF(pCadena[15,15]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 16 THEN 
					IF(pCadena[16,16]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 17 THEN 
					IF(pCadena[17,17]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 18 THEN 
					IF(pCadena[18,18]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 19 THEN 
					IF(pCadena[19,19]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 20 THEN 
					IF(pCadena[20,20]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				END IF;				
		    END FOR;
		END IF;				
	END IF;	
	
	RETURN cCodRet,iPosicion;		
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: TIPICO INDEXOF DE UNA CADENA.',
'AUTOR : Ing. Cruz',
'FECHA : 08-05-2013',
'VERSION: 20130508.1657',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_indexof_der_bpi(pCadena CHAR(20),pLetra CHAR(1))
	RETURNING CHAR(5) AS CodRetorno,
	INT AS Posicion;

-- ELABORO: 	ING CRUZ
-- FECHA:		06-05-2013
-- PROYECTO: 	PAGOS GDF BPI
-- DESCRIPCION:	DECODIFICA LA LINEA BASE CLAVES 36 - 45

--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE iLength int;
DEFINE iPosicion int;
DEFINE i int;
--Inicializacion de Variables
LET iSqlErr 	= 0;
LET cCodRet 	= '00000';
LET iLength = 0;
LET iPosicion = -1;
LET i = 0;

--SET DEBUG FILE TO '/home/informix/bibiana/sp_indexof_der_bpi.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet, iPosicion;
		END IF;
	END EXCEPTION;
	
	IF ((TRIM(nvl(pCadena,''))=='')OR(TRIM(NVL(pLetra,''))=='')) THEN
		LET cCodRet = '00001';
	ELSE
		LET iLength = LENGTH(pCadena);
		IF(iLength==1)THEN
			LET cCodRet = '00002';
		ELSE
			FOR i = 20 TO 1

				IF i = 1 THEN 
					IF(pCadena[1,1]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 2 THEN 
					IF(pCadena[2,2]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 3 THEN 
					IF(pCadena[3,3]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 4 THEN 
					IF(pCadena[4,4]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 5 THEN 
					IF(pCadena[5,5]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 6 THEN 
					IF(pCadena[6,6]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 7 THEN 
					IF(pCadena[7,7]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 8 THEN 
					IF(pCadena[8,8]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 9 THEN 
					IF(pCadena[9,9]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 10 THEN 
					IF(pCadena[10,10]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 11 THEN 
					IF(pCadena[11,11]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 12 THEN 
					IF(pCadena[12,12]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 13 THEN 
					IF(pCadena[13,13]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 14 THEN 
					IF(pCadena[14,14]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 15 THEN 
					IF(pCadena[15,15]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 16 THEN 
					IF(pCadena[16,16]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 17 THEN 
					IF(pCadena[17,17]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 18 THEN 
					IF(pCadena[18,18]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 19 THEN 
					IF(pCadena[19,19]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 20 THEN 
					IF(pCadena[20,20]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				END IF;				
		    END FOR;
		END IF;				
	END IF;
	
	RETURN cCodRet,iPosicion;		
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: TIPICO INDEXOF DE UNA CADENA.',
'AUTOR : Ing. Cruz',
'FECHA : 08-05-2013',
'VERSION: 20130508.1657',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_isnumeric(pNumero CHAR(20))
	RETURNING CHAR(5) AS CodRetorno;

-- ELABORO: 	ING CRUZ
-- FECHA:		06-05-2013
-- PROYECTO: 	PAGOS GDF BPI
-- DESCRIPCION:	DECODIFICA LA LINEA BASE CLAVES 36 - 45

--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE nNumero 		NUMERIC;
--Inicializacion de Variables
LET iSqlErr 	= 0;
LET cCodRet 	= '00000';
LET nNumero 	= 0;

--SET DEBUG FILE TO '/home/informix/bibiana/sp_isnumeric.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			IF(iSqlErr=-1215 or iSqlErr=-1213)THEN
				LET iSqlErr = 1;
			END IF;
			LET  cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	IF (TRIM(pNumero)=='') THEN
		LET cCodRet = '2';
	ELSE
		LET nNumero = pNumero;
		IF(nNumero<0)THEN
			LET cCodRet = '2';
		END IF;
	END IF;
	
	RETURN cCodRet;		
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: VALIDA SI ES NUMERO POSITIVO.',
'AUTOR : Ing. Cruz',
'FECHA : 08-05-2013',
'VERSION: 20130506.11',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_isnumeric_int(pNumero CHAR(16))
	RETURNING CHAR(5) AS CodRetorno;

-- ELABORO: 	ING CRUZ
-- FECHA:		06-05-2013
-- PROYECTO: 	PAGOS GDF BPI
-- DESCRIPCION:	DECODIFICA LA LINEA BASE CLAVES 36 - 45

--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);

--Inicializacion de Variables
LET iSqlErr 	= 0;
LET cCodRet 	= '00000';

--SET DEBUG FILE TO '/home/informix/bibiana/sp_isnumeric_int.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			IF(iSqlErr=-1215 or iSqlErr=-1213)THEN
				LET iSqlErr = 1;
			END IF;
			LET  cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	IF (TRIM(pNumero)=='') OR  (pNumero::INTEGER<0) THEN
		LET cCodRet = '2';
	ELSE
		LET iSqlErr = pNumero;
	END IF;
	
	RETURN cCodRet;		
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: VALIDA SI ES NUMERO ENTERO POSITIVO.',
'AUTOR : Ing. Cruz',
'FECHA : 06-05-2013',
'VERSION: 20130506.11',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_obtenerdvgdf(pCuenta CHAR(20))
	RETURNING CHAR(5) AS CodRetorno, CHAR AS DV;
	
	--Definicion de Variables
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRet 		CHAR(5);
	DEFINE cDV			CHAR;
	DEFINE cValor		CHAR;
	DEFINE i			INTEGER;
	DEFINE iSuma		INTEGER;
	DEFINE iProducto	INTEGER;
	DEFINE cDigito		CHAR;
	DEFINE cDigito2		CHAR;
	DEFINE cAux			CHAR(3);
	
	--Inicializacion de Variables
	LET iSqlErr		= 0;
	LET cCodRet		= '00000';
	LET cDV			= '';
	LET cValor		= '';
	LET i			= 0;
	LET iSuma		= 0;
	LET iProducto	= 0;
	LET cDigito		= '';
	LET cDigito2	= '';
	LET cAux		= '';
	
	--SET DEBUG FILE TO "/home/informix/bibiana/sp_obtenerDVGDF.out";
	--TRACE ON;
	
	BEGIN
		--Control de excepciones
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET  cCodRet = iSqlErr;
				RETURN cCodRet, '';
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;

		--Se valida la Cadena reciba por parametro
		IF TRIM(NVL(pCuenta,'')) = '' THEN
			LET cCodRet = '00001';
		ELSE
			LET i = LENGTH(TRIM(pCuenta));
			WHILE i > 0 
				LET cValor = SUBSTR(TRIM(pCuenta), i, 1);
				
				IF i = 1 OR i = 3 OR i = 5 OR i = 7 OR i = 9 OR i = 11 OR i = 13 OR i = 15 THEN
					LET iProducto = cValor::integer * 2;
				ELSE
					LET iProducto = cValor::integer * 1;
				END IF;
				
				IF iProducto < 10 THEN
					LET iSuma = iSuma + iProducto;
				ELSE
					LET cDigito = SUBSTR(iProducto::char(2), 1, 1);
					LET cDigito2 = SUBSTR(iProducto::char(2), 2, 1);					
					LET iSuma = iSuma + (cDigito::integer + cDigito2::integer);
				END IF;
				
				LET i = i - 1;
			END WHILE;
			LET cAux = iSuma::char(3);
			LET cDigito = SUBSTR(TRIM(cAux), LENGTH(TRIM(cAux)), 1);
			
			IF cDigito <> '0' THEN
				LET cDV = (10 - cDigito::integer)::char;
			ELSE
				LET cDV = '0';
			END IF;
		END IF;
		
		RETURN cCodRet, cDV;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para obtener el digito verificador de una cuenta obtenida para pago de Impuesto',
'				Predial y Servicios de Agua, en pagos de servicios GDF.',
'AUTOR : Manuel Ramos Figueroa',
'FECHA : 06 de Mayo 2013',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_valfecha_banca_gdf(pCodPais 	  CHAR(3),
			    		pFechaActual DATE)
RETURNING
    VARCHAR(5),         -- CodigoRetorno
    DATE;               -- Fecha Habil del bloque


/* 
***************************************************************************
REALIZO: ING CRUZ
FECHA: 21/06/2013
DESCRIPCION: VALIDA SI EL DIA ACTUAL ES FERIADO Y OBTIENE EL SIGUIENTE
			 DIA HABIL.
*************************************************************************** 
*/

DEFINE cVarDataErr      VARCHAR(64);
DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;

DEFINE cCodRet          CHAR(5);
DEFINE dFechaProx        DATE;

	--SET DEBUG FILE TO "/home/informix/bibiana/sp_sac_valfecha_banca_gdf.out";
	--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET cCodret=iSqlErr;
            RETURN cCodret, cVarDataErr;
        END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 10;
	SET ISOLATION TO DIRTY READ;
	
	SELECT fecha_prox
	INTO dFechaProx       
	FROM bdinteg:si_feriado_banca
	WHERE fecha = pFechaActual
    AND pais = pCodPais and laborable = "N";
	
	IF(TRIM(NVL(dFechaProx,''))=='')THEN
		LET dFechaProx = pFechaActual;
	END IF;
	
   RETURN '000',dFechaProx;
END
END PROCEDURE;