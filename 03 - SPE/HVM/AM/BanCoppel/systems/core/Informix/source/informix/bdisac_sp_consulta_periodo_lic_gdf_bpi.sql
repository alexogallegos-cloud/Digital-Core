CREATE PROCEDURE "informix".sp_consulta_periodo_lic_gdf_bpi(pClave CHAR(4))
-- DESCRIPCION: CONSULTA TIPO DE HOLOGRAMA
-- AUTOR: ING. CRUZ
-- FECHA: 13-05-2013
-- SISTEMA: PAGOS GDF BPI

RETURNING
CHAR(5)   AS CodigoRetorno,
CHAR(300)  AS Tramite;

DEFINE iSqlerr     	INTEGER;
DEFINE cCodRet     	CHAR(5);
DEFINE cPeriodoLic CHAR(300);

LET iSqlerr = 0;
LET cCodRet = '00000';
LET cPeriodoLic =''; 

--SET DEBUG FILE TO "/home/solserBD/sp_consulta_periodo_lic_gdf_bpi.out";
--TRACE ON;
  
BEGIN

	ON EXCEPTION SET iSqlerr
		LET cCodRet= iSqlerr;
		RETURN cCodRet, cPeriodoLic;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pClave,'')) = '' THEN
		LET cCodRet = '00001';
	END IF;
	
	SELECT tipo
	INTO cPeriodoLic
	FROM bdisac:"informix".sac_periodoslicenciagdf
	WHERE clave = TRIM(pClave);
	
	IF (cPeriodoLic is NULL) OR (TRIM(cPeriodoLic)=='') THEN
		LET cCodRet = '00001';
		--LA DECLARACION NO SE ENCONTRO EN EL CATALOGO O NO TIENE DESCRIPCION
	END IF;
	
	RETURN cCodRet, cPeriodoLic;	
END
END PROCEDURE

DOCUMENT
"Autor : Ing. Cruz",
"FECHA : 13-05-2013",
"Descripcion: Consulta el periodo de la licencia.",
"SISTEMA: PAGOS GDF BPI";

CREATE PROCEDURE "informix".sp_consulta_tipo_impuesto_gdf_bpi(pId CHAR(4))
-- DESCRIPCION: CONSULTA IMPUESTO
-- AUTOR: ING. CRUZ
-- FECHA: 10-05-2013
-- SISTEMA: PAGOS GDF BPI

RETURNING
CHAR(5)   AS CodigoRetorno,
CHAR(300)  AS Tramite;

DEFINE iSqlerr     	INTEGER;
DEFINE cCodRet     	CHAR(5);
DEFINE cImpuesto CHAR(300);

LET iSqlerr = 0;
LET cCodRet = '00000';
LET cImpuesto =''; 

--SET DEBUG FILE TO "/home/informix/bibiana/sp_consulta_tipo_impuesto_gdf_bpi.out";
--TRACE ON;
  
BEGIN

	ON EXCEPTION SET iSqlerr
		LET cCodRet= iSqlerr;
		RETURN cCodRet, cImpuesto;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pId,'')) = '' THEN
		LET cCodRet = '00001';
	END IF;
	
	SELECT impuesto
	INTO cImpuesto
	FROM bdisac:"informix".sac_cattipoimpuestogdf
	WHERE tipo = TRIM(pId);
	
	IF (cImpuesto is NULL) OR (TRIM(cImpuesto)=='') THEN
		LET cCodRet = '00001';
		--EL TRAMITE NO SE ENCONTRO EN EL CATALOGO O NO TIENE DESCRIPCION
	END IF;
	
	RETURN cCodRet, cImpuesto;	
END
END PROCEDURE
DOCUMENT
"Autor : Ing. Cruz",
"FECHA : 10-05-2013",
"Descripcion: Consulta el campo impuesto del catalogo de impuestos.",
"SISTEMA: PAGOS GDF BPI";

CREATE PROCEDURE "informix".sp_consulta_tramite_gdf_bpi(pId CHAR(4))
-- DESCRIPCION: CONSULTA TRAMITE
-- AUTOR: ING. CRUZ
-- FECHA: 10-05-2013
-- SISTEMA: PAGOS GDF BPI

RETURNING
CHAR(5)   AS CodigoRetorno,
CHAR(300)  AS Tramite;

DEFINE iSqlerr     	INTEGER;
DEFINE cCodRet     	CHAR(5);
DEFINE cTramite CHAR(300);

LET iSqlerr = 0;
LET cCodRet = '00000';
LET cTramite =''; 

--SET DEBUG FILE TO "/home/informix/bibiana/sp_consulta_tramite_gdf_bpi.out";
--TRACE ON;
  
BEGIN

	ON EXCEPTION SET iSqlerr
		LET cCodRet= iSqlerr;
		RETURN cCodRet, cTramite;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pId,'')) = '' THEN
		LET cCodRet = '00001';
	END IF;
	
	SELECT tramite
	INTO cTramite
	FROM bdisac:"informix".sac_cattipotramitesgdf
	WHERE id = pId;
	
	IF (cTramite is NULL) OR (TRIM(cTramite)=='') THEN
		LET cCodRet = '00001';
		--EL TRAMITE NO SE ENCONTRO EN EL CATALOGO O NO TIENE DESCRIPCION
	END IF;
	
	RETURN cCodRet, cTramite;	
END
END PROCEDURE
DOCUMENT
"Autor : Ing. Cruz",
"FECHA : 10-05-2013",
"Descripcion: Consulta el campo tramite del catalogo de trÃ¡mites.",
"SISTEMA: PAGOS GDF BPI";

CREATE PROCEDURE "informix".sp_consultaconceptogdf_bpi(pClave CHAR(2))
-- DESCRIPCION: CONSULTA PERIODO Y DESCRIPCION
-- AUTOR: ING. CRUZ
-- FECHA: 08-05-2013
-- SISTEMA: PAGOS GDF BPI

RETURNING
CHAR(5)   AS CodigoRetorno,
CHAR(50)  AS Periodo,
CHAR(300)  AS Descripcion;

DEFINE iSqlerr     	INTEGER;
DEFINE cCodRet     	CHAR(5);
DEFINE cPeriodo     CHAR(50);
DEFINE cDescripcion CHAR(300);

LET iSqlerr = 0;
LET cCodRet = '00000';
LET cPeriodo = '';
LET cDescripcion =''; 

--SET DEBUG FILE TO "/home/informix/bibiana/sp_consultaconceptogdf.out";
--TRACE ON;
  
BEGIN

	ON EXCEPTION SET iSqlerr
		LET cCodRet= iSqlerr;
		RETURN cCodRet, cPeriodo,cDescripcion;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 10;
	
	IF TRIM(NVL(pClave,'')) = '' OR pClave::INT = 0 THEN
		LET cCodRet = '00001';
	END IF;
	
	SELECT descripcion
	INTO cDescripcion
	FROM bdisac:"informix".sac_catconceptosgdf 
	WHERE clave = pClave;
	
	SELECT periodo
	INTO cPeriodo
	FROM bdisac:"informix".sac_periodoslicenciagdf
	WHERE clave = pClave;	

	RETURN cCodRet, cPeriodo,cDescripcion;	
END
END PROCEDURE
DOCUMENT
"Autor : Ing. Cruz",
"FECHA : 08-05-2013",
"Descripcion: Consulta el campo periodo y descripcion.",
"SISTEMA: PAGOS GDF BPI";

CREATE PROCEDURE "informix".sp_ejercicio_fiscal_gdf(pBase CHAR(20))
	RETURNING CHAR(5) AS CodRetorno,
	CHAR(4) AS EjercicioFiscal;	
	
-- ELABORO: 	ING CRUZ
-- FECHA:		30-10-2013
-- PROYECTO: 	PAGOS GDF BPI
-- DESCRIPCION:	GENERA EL EJERCICIO FISCAL A PARTIR DE LA POSICION 17 DE LA LINEA BASE

--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE cCodRet2     CHAR(5);
DEFINE cEjercicioFiscal CHAR(4);
DEFINE cAnioActual CHAR(4);
DEFINE cAnioMinimo CHAR(4);
DEFINE cComplemento CHAR(3);
DEFINE cAnioValidador CHAR(4);
DEFINE cComplemento2 CHAR(3);
DEFINE cAnioValidador2 CHAR(4);
--Inicializacion de Variables
LET iSqlErr 	= 0;
LET cCodRet 	= '00000';
LET cCodRet2    = '';
LET cEjercicioFiscal = '';
LET cAnioActual = '';
LET cAnioMinimo = '';
LET cComplemento = '';
LET cAnioValidador = '';
LET cComplemento2 = '';
LET cAnioValidador2 = '';

--SET DEBUG FILE TO '/home/informix/bibiana/sp_ejercicio_fiscal_gdf.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet, TRIM(NVL(cEjercicioFiscal,''));		
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ; 
	
	SELECT {+index(sac_fechas idx_sac_fechas)}year(fecha_hoy)
	INTO cAnioActual
	FROM bdisac:"informix".sac_fechas ;	
	
	LET cAnioMinimo = cAnioActual::INT - 5;
	LET cComplemento = cAnioActual[1,3];
	LET cAnioValidador = TRIM(cComplemento)||pBase[17,17];
	IF(cAnioValidador>cAnioActual) THEN
		LET cComplemento2 = cComplemento::INT - 1;
	ELSE
		LET cComplemento2 = TRIM(cComplemento);
	END IF;
	
	LET cAnioValidador2 = TRIM(cComplemento2)||pBase[17,17];
	
	--IF((cAnioValidador2<=cAnioActual) AND (cAnioValidador2>=cAnioMinimo)) THEN
	LET cEjercicioFiscal = TRIM(cAnioValidador2);
	--ELSE
	--	LET cCodRet = '00410';
	--END IF; 
	
	RETURN cCodRet, TRIM(NVL(cEjercicioFiscal,''));	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: GENERA EL EJERCICIO FISCAL A PARTIR DE LA POSICION 17 DE LA LINEA BASE',
'AUTOR : Ing. Cruz',
'FECHA : 30-10-2013',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_grababitacoragdf(pNombre char(50), pDomicilio char(80), pColonia char(40), pCP char(5), pDelegacion char(40), pEstado char(20), pGen1 char(100), 
												pGen2 char(100), pGen3 char(100), pGen4 char(100), pGen5 char(100), pGen6 char(100), pGen7 char(100), pGen8 char(100), pGen9 char(100), pGen10 char(100))
	RETURNING CHAR(5) AS CodRetorno;
	
	--Definicion de Variables
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRet 		CHAR(5);
	
	--Inicializacion de Variables
	LET iSqlErr		= 0;
	LET cCodRet		= '00000';
	
	--SET DEBUG FILE TO "/home/informix/bibiana/sp_grabaBitacoraGDF.out";
	--TRACE ON;
	
	BEGIN
		--Control de excepciones
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET  cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;

		INSERT INTO bdisac:"informix".sac_bitacoraGDF (fecha_insert, nombre, domicilio, colonia, cp, delegacion, estado, gen1, gen2, gen3, gen4, gen5, gen6, gen7, gen8, gen9, gen10)
		values (CURRENT, pNombre, pDomicilio, pColonia, pCP, pDelegacion, pEstado, pGen1, pGen2, pGen3, pGen4, pGen5, pGen6, pGen7, pGen8, pGen9, pGen10);		

		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para bitacorisar datos adicionales de los pagos de servicios del Gobierno del Distrito Federal',
'AUTOR : Manuel Ramos Figueroa',
'FECHA : 06 de Mayo 2013',
'BD: bdisac';

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