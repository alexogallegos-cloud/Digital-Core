CREATE PROCEDURE "informix".sp_obtienelineabase(pCaptura CHAR(20),
												pImporte CHAR(20))
	RETURNING CHAR(5) AS CodRetorno, CHAR(20)  AS Leyenda;

--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE i			INTEGER;
DEFINE iP			INTEGER;
DEFINE cP 			INTEGER;
DEFINE iResultado 	INTEGER;
DEFINE iMod     	INTEGER;
DEFINE iPotencia    INTEGER;
DEFINE iPot			INTEGER;
DEFINE iCadenaA_2 	INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE cCodRet2     CHAR(5);
DEFINE cDigV        CHAR(2);
DEFINE k 			CHAR(1);
DEFINE cCadena 		CHAR(20);
DEFINE cLetra 		CHAR(1);
DEFINE cLlave       CHAR(100);
DEFINE cConcepto    CHAR(2);
DEFINE cCadenaB     CHAR(5);
DEFINE cCadenaA 	CHAR(10);
DEFINE cK		 	NUMERIC;
DEFINE nSuma        NUMERIC;
DEFINE nCociente  	NUMERIC;
DEFINE dFecha_Hoy 	DATE;
DEFINE cLeyenda     CHAR(20);

DEFINE cImporteEvaluar NUMERIC;
DEFINE cImportepunto INTEGER;
DEFINE cImportelargo INTEGER;

--SET DEBUG FILE TO '/informix/HMLG/sp_obtienelineabase_p.out';
--TRACE ON;

		--SET DEBUG FILE TO '/informix/leo/sp_obtienelineabase.out';
		--TRACE ON;

--Inicializacion de Variables
LET iSqlErr 	= 0;
LET cCodRet 	= '00000';
LET cCodRet2    = '';
LET i       	= 0;
LET cK      	= '0';
LET nSuma   	= '0';
LET cCadena 	= '';
LET nCociente	= '0';
LET dFecha_Hoy	= DATE(1);
LET iMod		= 0;
LET cLetra		= '';
LET cP 			= 0;
LET k			= '';
LET iResultado  = 0;
LET iPot 		= 0;
LET cCadenaA  	= '';
LET iCadenaA_2  = 0;
LET cCadenaB 	= '';
LET cDigV 		= '';
LET cLlave 		= '';
LET cConcepto 	= '';
LET iP 			= 0;
LET cLeyenda    = '';
LET cImporteEvaluar = 0;
LET cImportepunto = 0;
LET cImportelargo = 0;


BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet, cLeyenda;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	--Validacion para detectar decimales en el importe de pago recibido
	LET cImportepunto = INSTR(TRIM(pImporte),'.');
	
	IF cimportepunto > 0 THEN 
		LET cImportelargo = LENGTH(TRIM(pImporte)) ;
		LET cImporteEvaluar = SUBSTR(TRIM(pImporte),cImportepunto,cImportelargo);
	END IF
	
	--DESARROLLO IF PARA CERTIFICACIONES ANUALES NO SE ACEPTAN IMPORTEN EN 0 NI CON DECIMALES
	--IF (TRIM(NVL(pCaptura,'')) = '' OR LENGTH(TRIM(pCaptura)) <> 20) OR TRIM(NVL(pImporte,'')) = '' OR pImporte::INTEGER <= 0 OR cImporteEvaluar > 0 THEN
	
	--PRODUCCION IF PRODUCTIVO NO SE ACEPTAN PAGOS MENORES A 10 NI CON DECIMALES
	IF (TRIM(NVL(pCaptura,'')) = '' OR LENGTH(TRIM(pCaptura)) <> 20) OR TRIM(NVL(pImporte,'')) = '' OR pImporte::INTEGER < 10 OR cImporteEvaluar > 0 THEN  
		LET cCodRet = '00002';
	ELSE

		LET cConcepto = pCaptura[1,2];

		EXECUTE PROCEDURE bdisac:"informix".sp_consultaconceptogdf(cConcepto) INTO cCodRet2, cLeyenda;

		IF cCodRet2 <> '00000' THEN
			LET cCodRet = cCodRet2;
		ELSE

			SELECT valor
			INTO cLlave
			FROM bdisac:"informix".sac_param WHERE
			cod_param = '87034';

			LET cCadenaB = UPPER(pCaptura[14,18]);

			FOR i = 1 TO 5

				IF i = 1 THEN
					LET  k = cCadenaB[1,1];
					LET iP = 4;
				ELIF i = 2 THEN
					LET  k = cCadenaB[2,2];
					LET iP = 3;
				ELIF i = 3 THEN
					LET  k = cCadenaB[3,3];
					LET iP = 2;
				ELIF i = 4 THEN
					LET  k = cCadenaB[4,4];
					LET iP = 1;
				ELIF i = 5 THEN
					LET  k = cCadenaB[5,5];
					LET iP = 0;
				END IF;

				IF k IS NOT NULL THEN

					SELECT valor
					INTO cP
					FROM bdisac:"informix".sac_base30
					WHERE letra = k;
					LET iPotencia = cP * POW(30,iP);
					LET nSuma = nSuma + iPotencia;

				END IF;

			END FOR;

			LET iResultado = nSuma - TRIM(cLlave)::INTEGER;
			LET iResultado = TRUNC(iResultado - pImporte::INTEGER);
			LET iMod = POW(30,5);

			IF iResultado < 0 THEN
				LET iPot = iResultado + iMod;
			ELSE
				LET iPot = MOD(iResultado,iMod);
			END IF;

-- MODIFICACION FRG-i (modif. para 2014):
			IF iPot < 0 THEN
				LET iPot = iPot + iMod;
			END IF;
--	(modif. para 2015):
			IF iPot < 0 THEN
				LET iPot = iPot + iMod;
			END IF;
-- MODIFICACION FRG-f

			IF iPot < 0 THEN
				LET iPot = iPot + iMod;
			END IF;

			IF iPot < 0 THEN
				LET iPot = iPot + iMod;
			END IF;



			LET iCadenaA_2 = iPot;
			FOR iP = 1 TO 5
				LET	iMod = MOD (iCadenaA_2,30);
				LET nCociente = iCadenaA_2 / 30 ;
				IF nCociente = '0' THEN
					EXIT FOR;
				END IF;
				LET iCadenaA_2 = nCociente;

				SELECT letra
				INTO cLetra
				FROM bdisac:"informix".sac_base30
				WHERE valor = iMod;

				LET cCadenaA = cLetra || cCadenaA;

			END FOR;

			LET cCadena = TRIM(TRIM(pCaptura[1,13]) || TRIM(cCadenaA) || TRIM(pCaptura[19,20]));

			EXECUTE PROCEDURE bdisac:"informix".sp_validadvgdf(cCadena) INTO cCodRet2;

			IF cCodRet2 = '00000' THEN

				EXECUTE PROCEDURE bdisac:"informix".sp_validalimpago(cCadena) INTO cCodRet2;

				IF cCodRet2 = '00000' THEN
					LET cCodRet = '00000';
				ELSE
					LET cCodRet = cCodRet2;
				END IF;
			ELSE
				LET cCodRet = cCodRet2;
			END IF;
		END IF;
	END IF;

	RETURN cCodRet, cLeyenda;

END;

END PROCEDURE;