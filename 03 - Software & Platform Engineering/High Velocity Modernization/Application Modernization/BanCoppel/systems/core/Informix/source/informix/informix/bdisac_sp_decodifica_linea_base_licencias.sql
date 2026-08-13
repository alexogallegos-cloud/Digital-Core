CREATE PROCEDURE "informix".sp_decodifica_linea_base_licencias(pCaptura CHAR(20),
												pImporte CHAR(20), pLlaveGDF INTEGER)
	RETURNING CHAR(5) AS CodRetorno,
	CHAR(1)  AS TipoLicencia,
	CHAR(30) AS Periodo,
	CHAR(10) AS TipoReferencia,
	CHAR(300) AS DescripcionConcepto;

-- ELABORO: 	ING CRUZ
-- FECHA:		06-05-2013
-- PROYECTO: 	PAGOS GDF BPI
-- DESCRIPCION:	DECODIFICA LA LINEA BASE CLAVES 01 - 14

--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE cCodRet2     CHAR(5);
DEFINE i			INTEGER;
DEFINE k 			CHAR(1);
DEFINE cCadena 		CHAR(20);
DEFINE cConcepto    CHAR(2);
DEFINE cLeyenda     CHAR(20);
DEFINE cTipoLicencia 		CHAR(1);
DEFINE cTipoReferencia 		CHAR(10);
DEFINE cDescripcionConcepto	CHAR(300);
DEFINE cPeriodo				CHAR(50);

--Inicializacion de Variables
LET iSqlErr 	= 0;
LET cCodRet 	= '00000';
LET cCodRet2    = '';
LET i       	= 0;
LET cCadena 	= '';
LET k			= '';
LET cConcepto 	= '';
LET cLeyenda    = '';
LET cTipoLicencia		= '';
LET cTipoReferencia		= '';
LET cDescripcionConcepto = '';
LET cPeriodo			= '';

--SET DEBUG FILE TO '/home/informix/bibiana/sp_decodifica_linea_base_licencias.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet, cTipoLicencia, cPeriodo, cTipoReferencia, cDescripcionConcepto;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	-- SE LEE EL CONCEPTO DE PAGO Y LA LINEA BASE

	EXECUTE PROCEDURE bdisac:"informix".sp_obtienelineabase_bpi(pCaptura,pImporte, pLlaveGDF) INTO cCodRet2, cLeyenda, cCadena;
	--LET cCodRet2 = '00000';
	IF cCodRet2 <> '00000' THEN
			LET cCodRet = cCodRet2;
	ELSE
		--PARA EL EJEMPLO cTipoLicencia = A
		LET cTipoLicencia = pCaptura[3,3];

		IF ((pCaptura[4,5]=='XX') AND (pCaptura[6,6] IN ('0','1','2','3','4','5','6','7','8','9'))) THEN
			--PARA EL EJEMPLO cTipoReferencia = MASA890505TEQ
			LET cTipoReferencia = pCaptura[6,13]; --- Se cambia la primer posición a partir de la cual se toma la referencia BGV
		ELSE
			FOR i = 4 TO 7
				--LET k = pCaptura[i,i];
				IF i = 4 THEN
					--LET  k = UPPER(pCaptura[4,4]);
					IF(pCaptura[4,4] IN ('0','1','2','3','4','5','6','7','8','9'))THEN
						IF(pCaptura[4,4]=='1')THEN
							LET pCaptura[4,4] = '&';
						ELIF (pCaptura[4,4]=='2')THEN
							LET pCaptura[4,4] = 'Ñ';
						END IF;
					END IF;
				ELIF i = 5 THEN
					--LET  k = UPPER(pCaptura[5,5]);
					IF(pCaptura[5,5] IN ('0','1','2','3','4','5','6','7','8','9'))THEN
						IF(pCaptura[5,5]=='1')THEN
							LET pCaptura[5,5] = '&';
						ELIF (pCaptura[5,5]=='2')THEN
							LET pCaptura[5,5] = 'Ñ';
						END IF;
					END IF;
				ELIF i = 6 THEN
					--LET  k = UPPER(pCaptura[6,6]);
					IF(pCaptura[6,6] IN ('0','1','2','3','4','5','6','7','8','9'))THEN
						IF(pCaptura[6,6]=='1')THEN
							LET pCaptura[6,6] = '&';
						ELIF (pCaptura[6,6]=='2')THEN
							LET pCaptura[6,6] = 'Ñ';
						END IF;
					END IF;
				ELIF i = 7 THEN
					--LET  k = UPPER(pCaptura[7,7]);
					IF(pCaptura[7,7] IN ('0','1','2','3','4','5','6','7','8','9'))THEN
						IF(pCaptura[7,7]=='1')THEN
							LET pCaptura[7,7] = '&';
						ELIF (pCaptura[7,7]=='2')THEN
							LET pCaptura[7,7] = 'Ñ';
						END IF;
					END IF;
				END IF;

			END FOR;
			-- SE OBTIENE TIPO DE REFERENCIA ACTUALIZADA
			LET cTipoReferencia = pCaptura[4,13];
		END IF;

		-- CONSULTAR EL PERIODO DEL CATALOGO DE PERIODOS
		EXECUTE PROCEDURE bdisac:"informix".sp_consultaconceptogdf_bpi(pCaptura[1,2])INTO cCodRet2, cPeriodo, cDescripcionConcepto;
		IF cCodRet2 <> '00000' THEN
			LET cCodRet = cCodRet2;
		END IF;
	END IF;

	RETURN cCodRet, cTipoLicencia, cPeriodo, cTipoReferencia, cDescripcionConcepto;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: DECODIFICA LA LINEA BASE.',
'AUTOR : Ing. Cruz',
'FECHA : 06-05-2013',
'BD: bdisac',
'VERSION: 20130506.11',
'Folio: 1448',
'Autor: 95734511 - L.S.C. José Magdiel Martínez',
'Fecha: 09-04-2014',
'Modificación: Se añade un nuevo parámetro quen contiene la llave de decodificación de la linea base.',
'Sustento: Reimpresion GDF';

CREATE PROCEDURE "informix".sp_decodificadatosimpuestopredial(pLineaCaptura CHAR(20), pImporte CHAR(16), pLlaveGDF INTEGER)
	RETURNING CHAR(5) AS CodRetorno, CHAR(40) AS Leyenda, CHAR(25) AS Cuenta, CHAR(120) AS Ejercicio, CHAR(20) AS Bimestre;

	--Definicion de Variables
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRet 				CHAR(5);
	DEFINE cCodRet2				CHAR(5);
	DEFINE cLeyenda				CHAR(40);
	DEFINE cLineaCapturaBase	CHAR(20);
	DEFINE cConcepto			CHAR(2);
	DEFINE cCuenta				CHAR(25);
	DEFINE cEjercicio			CHAR(120);
	DEFINE cBimestre			CHAR(20);
	DEFINE cDV					CHAR;
	DEFINE cDato				CHAR(15);

	--Inicializacion de Variables
	LET iSqlErr 			= 0;
	LET cCodRet 			= '00000';
	LET cCodRet2			= '00000';
	LET cLeyenda			= '';
	LET cLineaCapturaBase	= '';
	LET cConcepto			= '';
	LET cCuenta				= '';
	LET cEjercicio			= '';
	LET cBimestre			= '';
	LET cDV					= '';
	LET cDato				= '';

	--SET DEBUG FILE TO "/informix/gaby/certififcacionGDF2022/spl_liberar/outs/sp_decodificaDatosImpuestoPredial.out";
	--TRACE ON;

	BEGIN
		--Control de excepciones
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET  cCodRet = iSqlErr;
				RETURN cCodRet, '', '', '', '';
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		--Se valida que la Linea de Captura y el Importe tengan el formato correcto
		IF TRIM(NVL(pLineaCaptura,'')) = '' OR LENGTH(TRIM(pLineaCaptura)) <> 20 OR TRIM(NVL(pImporte,'')) = '' OR TRIM(NVL(pLlaveGDF,'')) = '' THEN
			LET cCodRet = '00001';
		ELSE
			--Se valida que sea una Linea de Captura apta para ser procesada y la Linea de Captura Base
			--para decodificar los datos necesarios
			EXECUTE PROCEDURE bdisac:"informix".sp_obtienelineabase_bpi(pLineaCaptura, pImporte, pLlaveGDF)
			INTO cCodRet2, cLeyenda, cLineaCapturaBase;

			IF NVL(cCodRet2, '') = '00000' THEN
				LET cConcepto = SUBSTR(pLineaCaptura, 1, 2);

				SELECT descripcion
				INTO cLeyenda
				FROM bdisac:"informix".sac_catconceptosgdf
				WHERE clave = cConcepto;

				LET cLeyenda = 'Concepto=' || cLeyenda;
				LET cDato = SUBSTR(cLineaCapturaBase, 3, 11);

				--Se obtiene el difito verificador
				EXECUTE PROCEDURE bdisac:"informix".sp_obtenerDVGDF(cDato)
				INTO cCodRet2, cDV;

				IF cCodRet2 = '00000' THEN
					LET cCuenta = "Cuenta=" || cDato;
					LET cCuenta = TRIM(cCuenta) || cDV;
					LET cDato = SUBSTR(cLineaCapturaBase, 17, 1);

					EXECUTE PROCEDURE bdisac:"informix".sp_validaCadenaNumerica(TRIM(cDato))
					INTO cCodRet2;

					IF cCodRet2 = '00000' THEN
						EXECUTE PROCEDURE bdisac:"informix".sp_asignaAnioPredial(TRIM(cDato))
						INTO cCodRet2, cEjercicio;

						IF cCodRet2 = '00000' THEN
							LET cEjercicio = "Ejercicio=" || cEjercicio;
													
							--Se cambia la forma en que se obtiene el a?o del ejercicio							
							LET cDato = SUBSTR(cLineaCapturaBase, 18, 1);

							EXECUTE PROCEDURE bdisac:"informix".sp_asignaBimestre(cDato)
							INTO cCodRet2, cBimestre;

							IF cCodRet2 = '00000' THEN
								LET cBimestre = "Bimestre=" || cBimestre;
							ELSE
								--Ocurrio un error al ejecutar el spl sp_asignaBimestre.
								LET cCuenta = '';
								LET cEjercicio = '';
								LET cCodRet = '00007';
							END IF;
						ELIF cCodRet2 = '00002' THEN
							--AÌ?å±o invalido en Linea de Captura Base
							LET cCuenta = '';
							LET cCodRet = '00006';
						ELSE
							--Ocurrio un error al ejecutar el spl sp_asignaAnio.
							LET cCuenta = '';
							LET cCodRet = '00005';
						END IF;
					ELIF cCodRet2 = '00002' THEN --- Se cambia el mensaje que aparece en el recibo para pagos de multiples periodos - BGV 11/12/2013
						LET cEjercicio = "Ejercicio=MULTIPLES PERIODOS (Consultar detalle del pago en: Anexo adjunto en la generacion de la Linea de Captura)";
					ELSE
						--Ocurrio un error al ejecutar el spl sp_validaCadenaNumerica.
						LET cCuenta = '';
						LET cCodRet = '00004';
					END IF;
				ELSE
					--Ocurrio un error al ejecutar el spl sp_obtenerDVGDF.
					LET cCodRet = '00003';
				END IF;
			ELSE
				LET cCodRet = cCodRet2;
			END IF;
		END IF;

		RETURN cCodRet, cLeyenda, cCuenta, cEjercicio, cBimestre;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para decodificar datos de la Linea de Captura Base de Pagos de Impuesto de GDF ',
'				(Impuesto Predial, Conceptos 80 - 81).',
'AUTOR : Manuel Ramos Figueroa',
'FECHA : 06 de Mayo 2013',
'BD: bdisac',
'Folio: 1448',
'Autor: 95734511 - L.S.C. Jose Magdiel Martinez',
'Fecha: 09-04-2014',
'Modificacion: Se a?ade un nuevo parametro quen contiene la llave de decodificacion de la linea base.',
'Sustento: Reimpresion GDF',
'Se modifica la forma en que se obtiene el a?o del ejercicio, se obtiene de la tabla de fechas sac_fechas',
'Bibiana Gaxiola Verdugo',
'13/01/2015',
'Se modifica la forma en que se obtiene el a?o del ejercicio',
'11/12/2018';

CREATE PROCEDURE "informix".sp_obtenerconfiguracionesremesa_wu(pNumParametros INTEGER, siParametros CHAR(200),pEmpresa CHAR(3), pUsuario CHAR(8), pMarca CHAR(2) )
--Retorno
RETURNING CHAR(5) AS cCodigoRet, char(500) as cValordesc;
--RETURNING CHAR(5), char(200);

--Declaracion de variables
DEFINE cParametros_temp  CHAR(200);
DEFINE cDelimitador CHAR(1);
DEFINE indice BIGINT;
DEFINE tamsiParametros BIGINT;
DEFINE retorno INTEGER;
DEFINE cValordesc  CHAR(500);
DEFINE cValordescPrevio  CHAR(500);
DEFINE i    SMALLINT ;
DEFINE iContador INTEGER ;
DEFINE sCodparametro CHAR(100);
DEFINE iSqlErr INTEGER;
DEFINE cCodigoRet CHAR(5);
DEFINE cCodigoRet2  CHAR (5);
DEFINE cValor       CHAR(500);


DEFINE indice2 BIGINT;
DEFINE retorno2 INTEGER;
DEFINE iLengthcValor INTEGER; --LENGTH
DEFINE iLengthcValordesc INTEGER; --LENGTH
DEFINE isumaLenghValores INTEGER; --LENGTH

DEFINE cSucursal 	CHAR(4);
DEFINE cForeignSystemId	CHAR(11); 
DEFINE cForeignRsCntRq  CHAR(11);

--inicializacion de variables
LET cValordesc  = '';
LET cValordescPrevio  = '';
LET i = 1;
LET iContador = pNumParametros;
LET indice = 0;
LET tamsiParametros = LENGTH(siParametros);
LET iSqlErr=0;
LET cParametros_temp = siParametros;
LET cDelimitador = '|';
LET cCodigoRet = '00000';
LET cCodigoRet2 = '00000';
LET cValor = '';
LET sCodparametro = '';

LET iLengthcValor = 0;
LET iLengthcValordesc = 0;
LET isumaLenghValores = 0;

LET cSucursal  = "";
LET cForeignSystemId =""; 
LET cForeignRsCntRq  ="" ;
 
--SET DEBUG FILE TO '/home/sysifx/Aracely/bdinteg/sp_split_huella.out';
--TRACE ON;

BEGIN

	ON EXCEPTION SET iSqlErr
        IF iSqlErr !=0 THEN
			DROP TABLE tempDual;
            RETURN iSqlErr, cValordesc;
        END IF;
    END EXCEPTION;	
	
	SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO dirty READ;
	
	--VALIDAR DATOS VACIOS
	IF  NVL(cParametros_temp, '') = '' THEN
		LET cCodigoRet = '00001'; 
		RETURN cCodigoRet, cValordesc;
	ELSE
	
		IF (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param ='87054') = pMarca
		OR (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param ='87055') = pMarca
		OR (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param ='87056') = pMarca THEN
				IF pUsuario = "sys_wu" THEN
					LET cSucursal = '9250';
				ELSE
					SELECT sucursal
					INTO cSucursal
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = pEmpresa AND ejecutivo = pUsuario;
				END IF;
				IF pUsuario = 'sys_wu' OR cSucursal <> '' THEN
					SELECT fsid ,counter_id
					INTO cForeignSystemId ,cForeignRsCntRq
					FROM bdisac:"informix".sac_wu_identificadores
					WHERE empresa = pEmpresa AND marca = pMarca AND sucursal = cSucursal;

					IF cForeignSystemId IS NULL OR cForeignSystemId = '' OR cForeignRsCntRq IS NULL OR cForeignRsCntRq = '' THEN
						LET cCodigoRet = '00027';
						LET cValordesc	= 'Usuario no tiene Id. Asignado';
						RETURN cCodigoRet, cValordesc;
					END IF;
				ELSE
					LET	cCodigoRet = '00026'; --- Usuario no se encuentra
					LET cValordesc	= 'NO EXISTE USUARIO';
					RETURN cCodigoRet, cValordesc;
			   END IF;
		ELSE
			LET	cCodigoRet = '00003'; --- Marca InvÃ¡lida
			LET cValordesc	= 'NO EXISTE MARCA EN SAC PARAM';			
			RETURN cCodigoRet, cValordesc;
		END IF;
		
		
		DROP TABLE IF EXISTS tempDual;		
		CREATE temp TABLE tempDual 
		( dual char(1)) WITH NO LOG ; 
		
		
		CREATE INDEX bdisac: "informix".idx_tempDual ON tempDual(dual) ONLINE;
		
		UPDATE STATISTICS MEDIUM FOR TABLE tempDual;
		
		INSERT INTO tempDual(dual) 
		VALUES('X');		
		
		--CORTAR CADENAS DE PARAMETROS						
		WHILE (i <= iContador) --LOOP
			
			IF (i = 1) THEN 
				
				SELECT CHARINDEX(cDelimitador, cParametros_temp) into indice from tempDual;
				SELECT SUBSTR(cParametros_temp, 0, indice - 1) into retorno from tempDual;
				LET sCodparametro = retorno;
				
				SELECT valor INTO cValor FROM bdisac:"informix".sac_param  WHERE cod_param = sCodparametro;				
				
				--LET cValordesc = 'HOLA' || '|';				
				LET cValor = NVL(TRIM(cValor), 'ESNULO');
				
				
				LET iLengthcValor = LENGTH(TRIM(cValor));
				
				IF iLengthcValor > 500 Then
					DROP TABLE tempDual;		
					RETURN TRIM(NVL('00002','')), 'TamaÃ±o de respuesta demasiado grande.';
				END IF;
				
				--iLengthcValor = 0;
				--iLengthcValordesc = 0; 
				
				IF (cValor = 'ESNULO') THEN
					LET cValordesc = '??' || '|';
				ELSE
					LET cValordesc = TRIM(cValor) || '|';
				END IF;
			ELSE
				IF (i = iContador ) THEN
					SELECT SUBSTR(cParametros_temp, indice + 1 , tamsiParametros - indice) into cParametros_temp from tempDual;			
					LET sCodparametro = cParametros_temp;
					
					SELECT valor INTO cValor FROM bdisac:"informix".sac_param  WHERE cod_param = sCodparametro;
					
					LET cValor = NVL(cValor, 'ESNULO');
					
					LET iLengthcValor = LENGTH (TRIM(cValor));
					LET iLengthcValordesc = LENGTH (TRIM(cValordesc));
									
					LET isumaLenghValores = iLengthcValor + iLengthcValordesc;
					
					IF (cValor = 'ESNULO') THEN
						--LET cValordesc = TRIM(cValordesc) || '??';
						
						IF isumaLenghValores > 500 Then							
							 
							-- CHARINDEX(cDelimitador, cValordesc) into indice2 from tempDual;
							-- SUBSTR(cValordesc, 0, indice2 - 1) into cValordescPrevio from tempDual;
							LET indice2 = LENGTH (TRIM(cValordesc));
							SELECT SUBSTR(cValordesc, 0, indice2 - 1) into cValordescPrevio from tempDual;
							
							LET cValordesc =  TRIM(cValordescPrevio );
							
							DROP TABLE tempDual;		
							RETURN TRIM(NVL(cCodigoRet,"")), TRIM(cValordesc);
						ELSE
							LET cValordesc = TRIM(cValordesc) || '??';
						END IF;				
						
					ELSE
						--LET cValordesc = TRIM(cValordesc) || TRIM(cValor);
						
						IF isumaLenghValores > 500 Then						
							 
							--SELECT CHARINDEX(cDelimitador, cValordesc) into indice2 from tempDual;
							--SELECT SUBSTR(cValordesc, 0, indice2 - 1) into cValordescPrevio from tempDual;
							LET indice2 = LENGTH (TRIM(cValordesc));
							SELECT SUBSTR(cValordesc, 0, indice2 - 1) into cValordescPrevio from tempDual;
							
							LET cValordesc =  TRIM(cValordescPrevio );
							
							DROP TABLE tempDual;		
							RETURN TRIM(NVL(cCodigoRet,"")), TRIM(cValordesc);
						ELSE
							LET cValordesc = TRIM(cValordesc) || TRIM(cValor);
						END IF;						
						
					END IF;					
				ELSE
					SELECT SUBSTR(cParametros_temp, indice + 1 , tamsiParametros - indice) into cParametros_temp from tempDual;
					SELECT CHARINDEX(TRIM(cDelimitador), cParametros_temp) into indice from tempDual;
					SELECT SUBSTR(cParametros_temp, 0, indice - 1) into retorno from tempDual;
					LET sCodparametro = retorno ;
					
					SELECT valor INTO cValor FROM bdisac:"informix".sac_param  WHERE cod_param = sCodparametro;
					
					LET cValor = NVL(cValor, 'ESNULO');
				
					
					LET iLengthcValor = LENGTH (TRIM(cValor));
					LET iLengthcValordesc = LENGTH (TRIM(cValordesc));
				
					LET isumaLenghValores = iLengthcValor + iLengthcValordesc;				
				
					IF (cValor = 'ESNULO') THEN						
						
						--LET cValordesc =  TRIM(cValordesc ) || '??' || '|';						
						IF isumaLenghValores > 500 Then					
							 
							-- CHARINDEX(cDelimitador, cValordesc) into indice2 from tempDual;
							-- SUBSTR(cValordesc, 0, indice2 - 1) into cValordescPrevio from tempDual;
							LET indice2 = LENGTH (TRIM(cValordesc));
							SELECT SUBSTR(cValordesc, 0, indice2 - 1) into cValordescPrevio from tempDual;
							
							LET cValordesc =  TRIM(cValordescPrevio );
							
							DROP TABLE tempDual;		
							RETURN TRIM(NVL(cCodigoRet,"")), TRIM(cValordesc);
						ELSE
							LET cValordesc =  TRIM(cValordesc ) || '??' || '|';
						END IF;						
					ELSE
						--LET cValordesc =  TRIM(cValordesc ) || TRIM(cValor) || '|';
						
						IF isumaLenghValores > 500 Then
														 
							--SELECT CHARINDEX(cDelimitador, cValordesc) into indice2 from tempDual;
							--SELECT SUBSTR(cValordesc, 0, indice2 - 1) into cValordescPrevio from tempDual;
							LET indice2 = LENGTH (TRIM(cValordesc));
							SELECT SUBSTR(cValordesc, 0, indice2 - 1) into cValordescPrevio from tempDual;
							
							LET cValordesc =  TRIM(cValordescPrevio );
							
							DROP TABLE tempDual;		
							RETURN TRIM(NVL(cCodigoRet,"")), TRIM(cValordesc);
						ELSE
							LET cValordesc =  TRIM(cValordesc ) || TRIM(cValor) || '|';
						END IF;					
						
					END IF;					
				END IF;				
			END IF;
			
			IF LENGTH (cValordesc) > 500 Then
				DROP TABLE tempDual;		
				RETURN TRIM(NVL('00002','')), 'TamaÃ±o de respuesta demasiado grande';
			END IF;		
			
			LET i = i + 1;			
		
		END WHILE;
		 
		DROP TABLE tempDual;
		
		RETURN TRIM(NVL(cCodigoRet,"")), TRIM(cValordesc);
		
	END IF;
END;
END PROCEDURE
DOCUMENT
'Autor : 92473997 Isaac Salomon Quintero Serrano',
'FECHA : 10/01/2018',
'DescripciÃ³n: Store Procedure para concatenar resultado de la sac_param para WU',
'BD   : bdisac';

CREATE PROCEDURE "informix".sp_obtenerconfiguracionesremesa(pNumParametros INTEGER, siParametros CHAR(200))
--Retorno
RETURNING CHAR(5) AS cCodigoRet, char(500) as cValordesc;
--RETURNING CHAR(5), char(200);

--Declaracion de variables
DEFINE cParametros_temp  CHAR(200);
DEFINE cDelimitador CHAR(1);
DEFINE indice BIGINT;
DEFINE tamsiParametros BIGINT;
DEFINE retorno INTEGER;
DEFINE cValordesc  CHAR(500);
DEFINE cValordescPrevio  CHAR(500);
DEFINE i    SMALLINT ;
DEFINE iContador INTEGER ;
DEFINE sCodparametro CHAR(100);
DEFINE iSqlErr INTEGER;
DEFINE cCodigoRet CHAR(5);
DEFINE cCodigoRet2  CHAR (5);
DEFINE cValor       CHAR(500);


DEFINE indice2 BIGINT;
DEFINE retorno2 INTEGER;
DEFINE iLengthcValor INTEGER; --LENGTH
DEFINE iLengthcValordesc INTEGER; --LENGTH
DEFINE isumaLenghValores INTEGER; --LENGTH

--inicializacion de variables
LET cValordesc  = '';
LET cValordescPrevio  = '';
LET i = 1;
LET iContador = pNumParametros;
LET indice = 0;
LET tamsiParametros = LENGTH(siParametros);
LET iSqlErr=0;
LET cParametros_temp = siParametros;
LET cDelimitador = '|';
LET cCodigoRet = '00000';
LET cCodigoRet2 = '00000';
LET cValor = '';
LET sCodparametro = '';

LET iLengthcValor = 0;
LET iLengthcValordesc = 0;
LET isumaLenghValores = 0;
 
--SET DEBUG FILE TO '/home/sysifx/Aracely/bdinteg/sp_split_huella.out';
--TRACE ON;

BEGIN

	ON EXCEPTION SET iSqlErr
        IF iSqlErr !=0 THEN
			DROP TABLE tempDual;
            RETURN iSqlErr, cValordesc;
        END IF;
    END EXCEPTION;	
	
	SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO dirty READ;
	
	--VALIDAR DATOS VACIOS
	IF  NVL(cParametros_temp, '') = '' THEN
		LET cCodigoRet = '00001'; 
		RETURN cCodigoRet, cValordesc;
	ELSE
		
		
		DROP TABLE IF EXISTS tempDual;		
		CREATE temp TABLE tempDual 
		( dual char(1)) WITH NO LOG ; 
		
		
		CREATE INDEX bdisac: "informix".idx_tempDual ON tempDual(dual) ONLINE;		
		
		UPDATE STATISTICS MEDIUM FOR TABLE tempDual;
		
		INSERT INTO tempDual(dual) 
		VALUES('X');		
		
		--CORTAR CADENAS DE PARAMETROS						
		WHILE (i <= iContador) --LOOP
			
			IF (i = 1) THEN 
				
				SELECT CHARINDEX(cDelimitador, cParametros_temp) into indice from tempDual;
				SELECT SUBSTR(cParametros_temp, 0, indice - 1) into retorno from tempDual;
				LET sCodparametro = retorno;
				
				SELECT valor INTO cValor FROM bdisac:"informix".sac_param  WHERE cod_param = sCodparametro;				
				
				--LET cValordesc = 'HOLA' || '|';				
				LET cValor = NVL(TRIM(cValor), 'ESNULO');
				
				
				LET iLengthcValor = LENGTH(TRIM(cValor));
				
				IF iLengthcValor > 500 Then
					DROP TABLE tempDual;		
					RETURN TRIM(NVL('00002','')), 'TamaÃ±o de respuesta demasiado grande.';
				END IF;
				
				--iLengthcValor = 0;
				--iLengthcValordesc = 0; 
				
				IF (cValor = 'ESNULO') THEN
					LET cValordesc = '??' || '|';
				ELSE
					LET cValordesc = TRIM(cValor) || '|';
				END IF;
			ELSE
				IF (i = iContador ) THEN
					SELECT SUBSTR(cParametros_temp, indice + 1 , tamsiParametros - indice) into cParametros_temp from tempDual;			
					LET sCodparametro = cParametros_temp;
					
					SELECT valor INTO cValor FROM bdisac:"informix".sac_param  WHERE cod_param = sCodparametro;
					
					LET cValor = NVL(cValor, 'ESNULO');
					
					LET iLengthcValor = LENGTH (TRIM(cValor));
					LET iLengthcValordesc = LENGTH (TRIM(cValordesc));
									
					LET isumaLenghValores = iLengthcValor + iLengthcValordesc;
					
					IF (cValor = 'ESNULO') THEN
						--LET cValordesc = TRIM(cValordesc) || '??';
						
						IF isumaLenghValores > 500 Then							
							 
							-- CHARINDEX(cDelimitador, cValordesc) into indice2 from tempDual;
							-- SUBSTR(cValordesc, 0, indice2 - 1) into cValordescPrevio from tempDual;
							LET indice2 = LENGTH (TRIM(cValordesc));
							SELECT SUBSTR(cValordesc, 0, indice2 - 1) into cValordescPrevio from tempDual;
							
							LET cValordesc =  TRIM(cValordescPrevio );
							
							DROP TABLE tempDual;		
							RETURN TRIM(NVL(cCodigoRet,"")), TRIM(cValordesc);
						ELSE
							LET cValordesc = TRIM(cValordesc) || '??';
						END IF;				
						
					ELSE
						--LET cValordesc = TRIM(cValordesc) || TRIM(cValor);
						
						IF isumaLenghValores > 500 Then						
							 
							--SELECT CHARINDEX(cDelimitador, cValordesc) into indice2 from tempDual;
							--SELECT SUBSTR(cValordesc, 0, indice2 - 1) into cValordescPrevio from tempDual;
							LET indice2 = LENGTH (TRIM(cValordesc));
							SELECT SUBSTR(cValordesc, 0, indice2 - 1) into cValordescPrevio from tempDual;
							
							LET cValordesc =  TRIM(cValordescPrevio );
							
							DROP TABLE tempDual;		
							RETURN TRIM(NVL(cCodigoRet,"")), TRIM(cValordesc);
						ELSE
							LET cValordesc = TRIM(cValordesc) || TRIM(cValor);
						END IF;						
						
					END IF;					
				ELSE
					SELECT SUBSTR(cParametros_temp, indice + 1 , tamsiParametros - indice) into cParametros_temp from tempDual;
					SELECT CHARINDEX(TRIM(cDelimitador), cParametros_temp) into indice from tempDual;
					SELECT SUBSTR(cParametros_temp, 0, indice - 1) into retorno from tempDual;
					LET sCodparametro = retorno ;
					
					SELECT valor INTO cValor FROM bdisac:"informix".sac_param  WHERE cod_param = sCodparametro;
					
					LET cValor = NVL(cValor, 'ESNULO');
				
					
					LET iLengthcValor = LENGTH (TRIM(cValor));
					LET iLengthcValordesc = LENGTH (TRIM(cValordesc));
				
					LET isumaLenghValores = iLengthcValor + iLengthcValordesc;				
				
					IF (cValor = 'ESNULO') THEN						
						
						--LET cValordesc =  TRIM(cValordesc ) || '??' || '|';						
						IF isumaLenghValores > 500 Then					
							 
							-- CHARINDEX(cDelimitador, cValordesc) into indice2 from tempDual;
							-- SUBSTR(cValordesc, 0, indice2 - 1) into cValordescPrevio from tempDual;
							LET indice2 = LENGTH (TRIM(cValordesc));
							SELECT SUBSTR(cValordesc, 0, indice2 - 1) into cValordescPrevio from tempDual;
							
							LET cValordesc =  TRIM(cValordescPrevio );
							
							DROP TABLE tempDual;		
							RETURN TRIM(NVL(cCodigoRet,"")), TRIM(cValordesc);
						ELSE
							LET cValordesc =  TRIM(cValordesc ) || '??' || '|';
						END IF;						
					ELSE
						--LET cValordesc =  TRIM(cValordesc ) || TRIM(cValor) || '|';
						
						IF isumaLenghValores > 500 Then
														 
							--SELECT CHARINDEX(cDelimitador, cValordesc) into indice2 from tempDual;
							--SELECT SUBSTR(cValordesc, 0, indice2 - 1) into cValordescPrevio from tempDual;
							LET indice2 = LENGTH (TRIM(cValordesc));
							SELECT SUBSTR(cValordesc, 0, indice2 - 1) into cValordescPrevio from tempDual;
							
							LET cValordesc =  TRIM(cValordescPrevio );
							
							DROP TABLE tempDual;		
							RETURN TRIM(NVL(cCodigoRet,"")), TRIM(cValordesc);
						ELSE
							LET cValordesc =  TRIM(cValordesc ) || TRIM(cValor) || '|';
						END IF;					
						
					END IF;					
				END IF;				
			END IF;
			
			IF LENGTH (cValordesc) > 500 Then
				DROP TABLE tempDual;		
				RETURN TRIM(NVL('00002','')), 'TamaÃ±o de respuesta demasiado grande';
			END IF;		
			
			LET i = i + 1;			
		
		END WHILE;
		 
		DROP TABLE tempDual;
		
		RETURN TRIM(NVL(cCodigoRet,"")), TRIM(cValordesc);
		
	END IF;
END;
END PROCEDURE
DOCUMENT
'Autor : 92473997 Isaac Salomon Quintero Serrano',
'FECHA : 24/12/2018',
'DescripciÃ³n: Store Procedure para concatenar resultado de la sac_param',
'BD   : bdisac';

CREATE PROCEDURE "informix".sp_buscar_migrante_cardif(pNumCertificado VARCHAR(30),  pNombre2 VARCHAR(26),  pApell_materno VARCHAR(26), pSexo CHAR(1), pNacionalidad CHAR(3), pCiudad VARCHAR(100), pFechaNac DATE, pParentesco INTEGER)
RETURNING CHAR(5);
DEFINE sql_err INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE iExiste INTEGER;

LET sql_err = 0;
LET cCodRet = "00001";
LET iExiste = 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/TMP/sp_buscar_migrante_cardif.out";
	--TRACE ON;

	--pNumcte
	--pSecuencia
	
		IF NVL(pNumCertificado, '') <> '' AND TRIM(pNumCertificado) <> '' AND NVL(pSexo, '') <> '' AND TRIM(pSexo) <> '' AND NVL(pNacionalidad, '') <> '' AND TRIM(pNacionalidad) <> '' AND NVL(pCiudad, '') <> '' AND TRIM(pCiudad) <> '' AND pFechaNac IS NOT NULL AND pParentesco <> 0 THEN
			
			SELECT  LIMIT 1 1 INTO iExiste
				FROM "informix".sac_cardif_migrante
			WHERE num_certificado = pNumCertificado AND
				  estatus IN (1,2);
			
			IF iExiste <> 1 OR iExiste IS NULL THEN				
				LET cCodRet = "00003";				
			ELSE			
				UPDATE "informix".sac_cardif_migrante
					SET nombre2 = pNombre2, apell_materno = pApell_materno,
						sexo = pSexo, nacionalidad = pNacionalidad, ciudad = pCiudad,
						fechaNac = pFechaNac, parentesco = pParentesco
				WHERE num_certificado = pNumCertificado AND
					  estatus IN (1,2);

				IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
					LET cCodRet = "00000";
				END IF;			
			END IF;
		ELSE
			LET cCodRet = "00002";
		END IF;		

		RETURN cCodRet;	
END;
END PROCEDURE
DOCUMENT
'Folio: 577',
'Autor: 97879606 Adrian Eduardo Lizarraga Cazares',
'BD: bdisac',
'Fecha: 2019-05-23',
'Descripcion: Se genera Procedimiento Almacenado para guardar los asegurados contratantes en la tabla sac_cardif_migrante para la asegurados en Cardiff',
'Solicito³: Abraham Narvaez';

CREATE PROCEDURE "informix".sp_updgenero_cte_remesa(pNumcte CHAR (9),pSexo CHAR (1),pEmpresa CHAR (3))
RETURNING   CHAR(5),CHAR(50);

DEFINE iSqlErr 			INTEGER;
DEFINE cCodret 			CHAR (5);
DEFINE cDescripcion 	CHAR (50);

LET iSqlErr  = 0;
LET cCodret  = '00000';
LET cDescripcion = '';
	
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN			
			LET cCodRet = iSqlErr;			
			RETURN cCodRet, cDescripcion; 
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/Guicho/sp_updgenero_cte_remesa.out';
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF NVL(pEmpresa,'')='' OR  NVL(pSexo,'')='' OR  NVL(pNumcte,'')= ''  THEN	
			LET cCodRet = '00002'; --Si algun parametro se encuentra vacio.
			LET cDescripcion = "Parametros de Entrada Requeridos";
			RETURN cCodRet, cDescripcion;
	END IF;

		UPDATE bdinteg:"informix".si_ctepf SET sexo = pSexo WHERE numcte = pNumcte AND empresa = pEmpresa;
	 
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= "00001";
			LET cDescripcion = "Update no realizado";
			RETURN TRIM(cCodRet), TRIM(cDescripcion);
        ELSE			
			LET cDescripcion = "Exitoso";
		END IF;
		
        
		
	RETURN  cCodret, cDescripcion;
END;
END PROCEDURE
DOCUMENT
' Folio      : 1992',  
' Autor      : Hector Hazael Aguilar Arteaga / Jesus Ivan Garcia Guicho',
' Fecha      : 17/01/2022',
' Descripcion: se crea SP para actualizar el valor del campo sexo, para clientes Banco que aun no son usuarios Remesas que no contengan',
'              en ese momento el campo sexo en la tabla si_ctepf por ser altas de origen del proceso de Dictamen Unificado.',  
' Solicito   : Hector Miguel Loera Guzman / Leonardo Hernandez Moreno',
' BD         : bdisac';

CREATE PROCEDURE "informix".sp_sac_wu_depuracion()

	RETURNING CHAR(5), VARCHAR(200), VARCHAR(200), VARCHAR(200);


		--Definicion de Variables
    DEFINE cCodRet          	    CHAR(5);
    DEFINE iSqlErr				    INTEGER;
	DEFINE iIsamErr 			    INTEGER;
    DEFINE cInfoErr         	    CHAR(100);
	DEFINE cMensaje				    VARCHAR(200);
	DEFINE cMensaje2			    VARCHAR(200);
	DEFINE cMensaje3			    VARCHAR(200);
	DEFINE cRutaArch 			    CHAR(100);
	DEFINE cStmt 				    CHAR (500);
	DEFINE cConteoPay               VARCHAR(50);
	DEFINE cConteoSearch            VARCHAR(50);
	DEFINE cConteoCancel 		    VARCHAR(50);
	DEFINE cFecha_proceso 	        DATE;
	
	DEFINE cDiasRespaldos			INTEGER;
	DEFINE cDiasRespaldosG 	    	VARCHAR(5);
	DEFINE cDiasRespaldosPAY		INTEGER;
	DEFINE cDiasRespaldosSEARCH		INTEGER;
	DEFINE cDiasRespaldosCANCEL		INTEGER;
	
	
	DEFINE cConteo  	     	    INTEGER;
	DEFINE cConteo2  	     	    INTEGER;
	DEFINE cConteo3  	     	    INTEGER;
	
	DEFINE cNo_row			        VARCHAR(50);
	DEFINE cFh					    DATETIME YEAR to FRACTION(5);
	DEFINE cConteo4  	     	    INTEGER;
	DEFINE vtransaccion	   		    SMALLINT;
	DEFINE cConf_pago 			    VARCHAR(5);
	DEFINE cForeign_rs_refnum_rq    VARCHAR(20);
	DEFINE cRutaOltp                CHAR(50);
	DEFINE dFecha_Hoy               DATE;
	DEFINE cDia                 	CHAR (2);
	DEFINE cMes                 	CHAR (2);
	DEFINE cAnio                	CHAR (2);
	DEFINE cFecha_archivo       	VARCHAR(10);

	--SET DEBUG FILE TO '/RESPALDOSNEW/enrique/sp_sac_wu_depuracion.out';
	--TRACE ON;
	
	-- Inicializa variables
	LET cCodRet            		= "00000";
	LET cMensaje				= "Proceso Exitoso|";
	LET cMensaje2				= '';
	LET cMensaje3				= '';
	LET cFecha_proceso 			= MDY('01','01','1900');


	LET cConteo 	= 0;
	LET cConteo2 	= 0;
	LET cConteo3 	= 0;
	LET cConteoPay = '0';
    LET cConteoSearch = '0';
	LET cConteoCancel = '0';
	LET cDiasRespaldos = 0;
	LET cDiasRespaldosG = '';
	LET cDiasRespaldosPAY = 0;
	LET cDiasRespaldosSEARCH = 0;
	LET cDiasRespaldosCANCEL = 0;
	LET cNo_row				= '';
	LET cFh	 			= MDY('01','01','1900');
	LET cConteo4 	= 0;
	LET vtransaccion 	= 0;
	LET cConf_pago = '';
	LET cForeign_rs_refnum_rq = '';
	LET cStmt = '';
	LET cRutaArch = '';
	LET cFecha_proceso = today;
	LET dFecha_Hoy   			= DATE(1);
	LET cDia          		  	= '';
    LET cMes          		 	= '';
    LET cAnio         		  	= '';
	LET cFecha_archivo			= 'AA_MM_DD';
	LET cRutaOltp = '/RESPALDOSNEW/depuraremesas/';

	BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			--Manejo de errores, en caso de error, envÃ­o codigo de error y guarda evidencia
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sac_wu_depuracion");
								
				LET cMensaje = "ERROR EN LA EJECUCION DEL SP BDD";
				LET cMensaje2 = 'Fecha|Sac_Wu_Pay|Saw_Wu_Search|Cancel_Pay|';
				LET cMensaje3 = cFecha_proceso||'|'||cConteoPay||"|" ||cConteoSearch||"|" ||cConteoCancel||"|";
		
				
                RETURN cCodRet,cMensaje,cMensaje2,cMensaje3;
            END IF;
        END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
		-- IF vtransaccion = 1 THEN
			-- COMMIT WORK;
			-- BEGIN WORK;
		-- ELSE
			-- BEGIN WORK;
		-- END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT fecha_hoy 
		INTO dFecha_Hoy 
		FROM bdisac:"informix".sac_fechas
		WHERE empresa = "001";
		
		LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(SUBSTRING(YEAR(dFecha_Hoy ::DATE) FROM 3 FOR 2), 2, '0'); 
		
		LET cFecha_archivo = REPLACE(cFecha_archivo,'AA',cAnio);
		LET cFecha_archivo = REPLACE(cFecha_archivo,'MM',cMes);
		LET cFecha_archivo = REPLACE(cFecha_archivo,'DD',cDia);
		
	
		--DIAS PARA MIGRACION A PROCESOS HISTORICOS
		
		SELECT valor 
		INTO cDiasRespaldosG
		FROM sac_param
		WHERE cod_param = 147;
		
		IF cDiasRespaldosG IS NULL OR cDiasRespaldosG = "" THEN 
			LET cDiasRespaldosG = 'I';
		END IF;
		

	IF 	cDiasRespaldosG = 'A' THEN
		
		/*DEPURACION sac_wu_pay*/
		
			SELECT valor 
			INTO cDiasRespaldosPAY
			FROM sac_param
			WHERE cod_param = 148;
			
			IF cDiasRespaldosPAY IS NULL OR cDiasRespaldosPAY = 0 THEN 
				LET cDiasRespaldosPAY = '95';
			END IF;
			
			LET cConteo = 0;
					
			SELECT COUNT(*)
			INTO cConteo
			FROM sac_wu_pay 
			WHERE fecha_insert <= EXTEND((today - cDiasRespaldosPAY), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
			
			IF cConteo IS NULL THEN 
				LET cConteo = 0;
			END IF;
			
			IF cConteo <> 0 THEN 
				DROP TABLE IF EXISTS tmp_sac_wu_pay_621048;
				DROP TABLE IF EXISTS tmp_sac_wu_pay_621048_2;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '_up.log';
				SYSTEM cStmt;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.unl';
				SYSTEM cStmt;
				
				
				SELECT *
				FROM sac_wu_pay 
				WHERE fecha_insert <= EXTEND((today - cDiasRespaldosPAY), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
				INTO tmp_sac_wu_pay_621048;
				
				
				LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.unl SELECT * FROM tmp_sac_wu_pay_621048;">' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
				
				
				LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
							
				LET cStmt= 'dbaccess bdisac	' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
				
				LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.unl';
				SYSTEM cStmt;
				
				LET cStmt = '';
				LET cStmt = ' echo "FILE ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 60;' || '">' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;

				LET cStmt = '';
				LET cStmt = ' echo "INSERT INTO sac_wu_pay_old;' || '">> ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;
				
				LET cStmt = '';
				LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;
				
				LET cStmt = "";
				LET cStmt = 'dbload -d bdisac -c ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || cFecha_archivo || '_up.sql -l ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || cFecha_archivo || '_up.log -n 1000 -r';
				SYSTEM cStmt;
				
				
				LET cConteo2 = 0;
				
				SELECT COUNT(*)
				INTO cConteo2
				FROM tmp_sac_wu_pay_621048;
				
				IF cConteo2 IS NULL THEN 
					LET cConteo2 = 0;
				END IF;
					
					
				IF cConteo = cConteo2 THEN 
					
					LET cConteoPay = cConteo;
					
					
					LET cConteo4 = 0;
					BEGIN WORK;
					FOREACH WITH HOLD
						SELECT mtcn,fecha_insert,conf_pago,foreign_rs_refnum_rq 
						INTO cNo_row, cFh,cConf_pago,cForeign_rs_refnum_rq
						FROM tmp_sac_wu_pay_621048

							DELETE FROM "informix".sac_wu_pay WHERE mtcn = cNo_row AND fecha_insert = cFh AND conf_pago = cConf_pago AND foreign_rs_refnum_rq = cForeign_rs_refnum_rq;
						
						LET cConteo4 = cConteo4 + 1;						
						IF cConteo4 = 1000 THEN
							COMMIT WORK;
							LET cConteo4 = 0;
							BEGIN WORK;
						END IF;			
						
					END FOREACH;
					
					IF cConteo4 <> 0 THEN 
						COMMIT WORK;
						LET cConteo4 = 0;
						--BEGIN WORK;
					END IF;
				
					UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_wu_pay;
					UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_wu_pay_old;
					
					DROP TABLE IF EXISTS tmp_sac_wu_pay_621048;
					DROP TABLE IF EXISTS tmp_sac_wu_pay_621048_2;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '_up.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '_up.log';
					SYSTEM cStmt;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_pay_' || TRIM(cFecha_archivo) || '.unl';
					SYSTEM cStmt;
					LET cCodRet = "00000";
				ELSE 
					LET cCodRet = "00001";				
					LET cMensaje =  "Verificar Diferencias en Proceso|";
					LET cConteoPay = cConteo||"-"||cConteo2||"-"||cConteo3;

				END IF;

			END IF;

		/*FIN DEPURACION sac_wu_pay*/
		
		/*DEPURACION sac_wu_search*/
		
			SELECT valor 
			INTO cDiasRespaldosSEARCH
			FROM sac_param
			WHERE cod_param = 149;
			
			IF cDiasRespaldosSEARCH IS NULL OR cDiasRespaldosSEARCH = 0 THEN 
				LET cDiasRespaldosSEARCH = '95';
			END IF;
			
			LET cConteo = 0;
					
			SELECT COUNT(*)
			INTO cConteo
			FROM sac_wu_search 
			WHERE fecha_insert <= EXTEND((today - cDiasRespaldosSEARCH), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
			
			IF cConteo IS NULL THEN 
				LET cConteo = 0;
			END IF;
			
			IF cConteo <> 0 THEN 
				DROP TABLE IF EXISTS tmp_sac_wu_search_621048;
				DROP TABLE IF EXISTS tmp_sac_wu_search_621048_2;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '_up.log';
				SYSTEM cStmt;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.unl';
				SYSTEM cStmt;
				
				
				SELECT *
				FROM sac_wu_search 
				WHERE fecha_insert <= EXTEND((today - cDiasRespaldosSEARCH), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
				INTO tmp_sac_wu_search_621048;
				
				
				LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.unl SELECT * FROM tmp_sac_wu_search_621048;">' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
				
				
				LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
							
				LET cStmt= 'dbaccess bdisac	' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
				
				LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.unl';
				SYSTEM cStmt;
				
				LET cStmt = '';
				LET cStmt = ' echo "FILE ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 58;' || '">' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;

				LET cStmt = '';
				LET cStmt = ' echo "INSERT INTO sac_wu_search_old;' || '">> ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;
				
				LET cStmt = '';
				LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;
				
				LET cStmt = "";
				LET cStmt = 'dbload -d bdisac -c ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || cFecha_archivo || '_up.sql -l ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || cFecha_archivo || '_up.log -n 1000 -r';
				SYSTEM cStmt;
				
				
				LET cConteo2 = 0;
				
				SELECT COUNT(*)
				INTO cConteo2
				FROM tmp_sac_wu_search_621048;
				
				IF cConteo2 IS NULL THEN 
					LET cConteo2 = 0;
				END IF;
					
					
				IF cConteo = cConteo2 THEN 
					
					LET cConteoSearch = cConteo;
					
					
					LET cConteo4 = 0;
					BEGIN WORK;
					FOREACH WITH HOLD
						SELECT mtcn,fecha_insert,foreign_rs_refnum_rq 
						INTO cNo_row,cFh,cForeign_rs_refnum_rq
						FROM tmp_sac_wu_search_621048

							DELETE FROM "informix".sac_wu_search WHERE mtcn = cNo_row AND fecha_insert = cFh AND foreign_rs_refnum_rq = cForeign_rs_refnum_rq;
						
						LET cConteo4 = cConteo4 + 1;						
						IF cConteo4 = 1000 THEN
							COMMIT WORK;
							LET cConteo4 = 0;
							BEGIN WORK;
						END IF;			
						
					END FOREACH;
					
					IF cConteo4 <> 0 THEN 
						COMMIT WORK;
						LET cConteo4 = 0;
						--BEGIN WORK;
					END IF;
				
					UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_wu_search;
					UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_wu_search_old;
					
					DROP TABLE IF EXISTS tmp_sac_wu_search_621048;
					DROP TABLE IF EXISTS tmp_sac_wu_search_621048_2;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '_up.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '_up.log';
					SYSTEM cStmt;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_search_' || TRIM(cFecha_archivo) || '.unl';
					SYSTEM cStmt;
					LET cCodRet = "00000";
				ELSE 
					LET cCodRet = "00001";				
					LET cMensaje =  "Verificar Diferencias en Proceso|";
					LET cConteoPay = cConteo||"-"||cConteo2||"-"||cConteo3;

				END IF;

			END IF;

		/*FIN DEPURACION sac_wu_search*/
		
		/*DEPURACION sac_wu_cancelpay*/
		
			SELECT valor 
			INTO cDiasRespaldosCANCEL
			FROM sac_param
			WHERE cod_param = 150;
			
			IF cDiasRespaldosCANCEL IS NULL OR cDiasRespaldosCANCEL = 0 THEN 
				LET cDiasRespaldosCANCEL = '95';
			END IF;
			
			LET cConteo = 0;
					
			SELECT COUNT(*)
			INTO cConteo
			FROM sac_wu_cancelpay 
			WHERE fecha_insert <= EXTEND((today - cDiasRespaldosCANCEL), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND;
			
			IF cConteo IS NULL THEN 
				LET cConteo = 0;
			END IF;
			
			IF cConteo <> 0 THEN 
				DROP TABLE IF EXISTS tmp_sac_wu_cancelpay_621048;
				DROP TABLE IF EXISTS tmp_sac_wu_cancelpay_621048_2;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '_up.log';
				SYSTEM cStmt;
				LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.unl';
				SYSTEM cStmt;
				
				
				SELECT *
				FROM sac_wu_cancelpay 
				WHERE fecha_insert <= EXTEND((today - cDiasRespaldosCANCEL), YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
				INTO tmp_sac_wu_cancelpay_621048;
				
				
				LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.unl SELECT * FROM tmp_sac_wu_cancelpay_621048;">' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
				
				
				LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
							
				LET cStmt= 'dbaccess bdisac	' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.sql';
				SYSTEM cStmt;
				
				LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.unl';
				SYSTEM cStmt;
				
				LET cStmt = '';
				LET cStmt = ' echo "FILE ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.unl'||' DELIMITER '|| "'" || '|' || "'" || ' 23;' || '">' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;

				LET cStmt = '';
				LET cStmt = ' echo "INSERT INTO sac_wu_cancelpay_old;' || '">> ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;
				
				LET cStmt = '';
				LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '_up.sql';
				SYSTEM cStmt;
				
				LET cStmt = "";
				LET cStmt = 'dbload -d bdisac -c ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || cFecha_archivo || '_up.sql -l ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || cFecha_archivo || '_up.log -n 1000 -r';
				SYSTEM cStmt;
				
				
				LET cConteo2 = 0;
				
				SELECT COUNT(*)
				INTO cConteo2
				FROM tmp_sac_wu_cancelpay_621048;
				
				IF cConteo2 IS NULL THEN 
					LET cConteo2 = 0;
				END IF;
					
					
				IF cConteo = cConteo2 THEN 
					
					LET cConteoCancel = cConteo;
					
					
					LET cConteo4 = 0;
					BEGIN WORK;
					FOREACH WITH HOLD
						SELECT mtcn,fecha_insert
						INTO cNo_row,cFh
						FROM tmp_sac_wu_cancelpay_621048

							DELETE FROM "informix".sac_wu_cancelpay WHERE mtcn = cNo_row AND fecha_insert = cFh;
						
						LET cConteo4 = cConteo4 + 1;						
						IF cConteo4 = 1000 THEN
							COMMIT WORK;
							LET cConteo4 = 0;
							BEGIN WORK;
						END IF;			
						
					END FOREACH;
					
					IF cConteo4 <> 0 THEN 
						COMMIT WORK;
						LET cConteo4 = 0;
						--BEGIN WORK;
					END IF;
				
					UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_wu_cancelpay;
					UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_wu_cancelpay_old;
					
					DROP TABLE IF EXISTS tmp_sac_wu_cancelpay_621048;
					DROP TABLE IF EXISTS tmp_sac_wu_cancelpay_621048_2;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '_up.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '_up.log';
					SYSTEM cStmt;
					LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'tmp_sac_wu_cancelpay_' || TRIM(cFecha_archivo) || '.unl';
					SYSTEM cStmt;
					LET cCodRet = "00000";
				ELSE 
					LET cCodRet = "00001";				
					LET cMensaje =  "Verificar Diferencias en Proceso|";
					LET cConteoPay = cConteo||"-"||cConteo2||"-"||cConteo3;

				END IF;

			END IF;

		/*FIN DEPURACION sac_wu_cancelpay*/
	
	ELSE
		
		LET cCodRet = "00001";				
		LET cMensaje =  "Proceso Desactivado sac_param 147|";
		
	END IF;
	
	
		IF cCodRet = '00000' THEN 
			LET cCodRet = "00000";				
			LET cMensaje =  "Proceso Exitoso|";
			
			INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
			VALUES ('SAC_WU_DEPURACION',today,'1','informix',CURRENT,'1','sp_sac_wu_depuracion','Depuracion Tablas WU '||cCodRet);
			
		ELSE 
			INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
			VALUES ('SAC_WU_DEPURACION',today,'0','informix',CURRENT,'1','sp_sac_wu_depuracion','Depuracion Tablas WU Verificar '||cCodRet);
		END IF;
		
		LET cMensaje2 = 'Fecha|Sac_Wu_Pay|Saw_Wu_Search|Cancel_Pay|';
		LET cMensaje3 = cFecha_proceso||'|'||cConteoPay||"|" ||cConteoSearch||"|" ||cConteoCancel||"|";
		

					
		
		RETURN cCodRet,cMensaje,cMensaje2,cMensaje3;
		
	END;
END PROCEDURE;