CREATE PROCEDURE "informix".sp_obtienelineabase_bpi(pCaptura CHAR(20), pImporte CHAR(20), pLlaveGDF INTEGER)
	RETURNING CHAR(5) AS CodRetorno, CHAR(20)  AS Leyenda, CHAR(20) AS LineaBase;

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
DEFINE cLlaveGDF 	CHAR(5);

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
LET cLlaveGDF	= '';

-- SET DEBUG FILE TO '/home/informix/bibiana/sp_obtienelineabase_bpi.out';
-- TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet, cLeyenda, cCadena;
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	
	IF (TRIM(NVL(pCaptura,'')) = '' OR LENGTH(TRIM(pCaptura)) <> 20) OR TRIM(NVL(pImporte,'')) = '' OR TRIM(NVL(pLlaveGDF,'')) = '' THEN
		LET cCodRet = '00002';
	ELSE
		
		LET cConcepto = pCaptura[1,2];
		
		EXECUTE PROCEDURE bdisac:"informix".sp_consultaconceptogdf(cConcepto) INTO cCodRet2, cLeyenda;
			
		IF cCodRet2 <> '00000' THEN
			LET cCodRet = cCodRet2;
		ELSE			
			--LET cLlave = 38001979;
			-- 12357113
			SELECT valor 
			INTO cLlave
			FROM bdisac:"informix".sac_param 
			WHERE cod_param = pLlaveGDF;
			
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
			
			-- Valida que la llave enviada sea del aÃÂ±o anterior (2014) 
			IF pLlaveGDF = '87042' THEN 
			
				IF iPot < 0 THEN
					LET iPot = iPot + iMod;
				END IF;
				
				IF iPot < 0 THEN
					LET iPot = iPot + iMod;
				END IF;
				
			END IF;
			--	Valida que la llave enviada sea del aÃÂ±o 2015 
			
			IF pLlaveGDF = '87034' THEN				
				
				IF iPot < 0 THEN
					LET iPot = iPot + iMod;
				END IF;
				
				IF iPot < 0 THEN
					LET iPot = iPot + iMod;
				END IF; 
				
				IF iPot < 0 THEN
					LET iPot = iPot + iMod;
				END IF; 
				
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
			
			LET cLlaveGDF = pLlaveGDF::char(5);
			
			LET cCadena = TRIM(TRIM(pCaptura[1,13]) || TRIM(cCadenaA) || TRIM(pCaptura[19,20]));
			IF (cLlaveGDF<>'87042') THEN
											
				EXECUTE PROCEDURE bdisac:"informix".sp_validalimpago(cCadena) INTO cCodRet2;
				
				IF cCodRet2 = '00000' THEN
					
					EXECUTE PROCEDURE bdisac:"informix".sp_validadvgdf(cCadena) INTO cCodRet2;
					
					IF cCodRet2 = '00000' THEN
						LET cCodRet = '00000';
					ELSE
						LET cCodRet = cCodRet2;
					END IF;
				ELSE
					IF cCodRet2 == '00003' THEN
						LET cCodRet = '00403';
					ELSE
						LET cCodRet = cCodRet2;
					END IF;
				END IF;
			END IF;
			
		END IF;
	END IF;
	
	RETURN cCodRet, cLeyenda, cCadena;		
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para la validaciÃÂ³n del DÃÂ­gito Verificador para el Impuesto de GDF.',
'AUTOR : MartÃÂ­n Eduardo Miranda',
'FECHA : 12 de Diciembre 2012',
'VERSION: 20121212.12',
'BD: bdisac',
'MODIFICACION : 11/02/2013',
'MODIFICO :Felipe Urias  ',
'DESCRIPCION: se agrega como retorno la leyenda de conceptos de sac_catconceptosgdf',
'MODIFICACION : 09/05/2013',
'MODIFICO : Ing. Cruz  ',
'DESCRIPCION: Nuevo valor de retorno: lÃÂ­nea base.',
'MODIFICACION : 30/10/2013',
'MODIFICO : Ing. Cruz  ',
'DESCRIPCION: ValidaciÃÂ³n de fecha lÃÂ­mite de pago.',
'Folio: 1448',
'Autor: 95734511 - L.S.C. JosÃÂ© Magdiel MartÃÂ­nez',
'Fecha: 09-04-2014',
'ModificaciÃÂ³n: Se aÃÂ±ade un nuevo parÃÂ¡metro quen contiene la llave de decodificaciÃÂ³n de la linea base.',
'Sustento: Reimpresion GDF',
'Se modifica el SP agregando la validaciÃÂ³n de la llave que se envÃÂ­a, esto para poder reimprimir los comprobantes',
'Bibiana Gaxiola Verdugo',
'13/01/2015';

CREATE PROCEDURE "informix".sp_remesaswu_pld(NombreProceso CHAR(3),FechaIni DATE, FechaFin DATE)
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;
    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(100);
	DEFINE cCodRet              CHAR(5);
	DEFINE cMensaje				CHAR(80);
	DEFINE cStatus				CHAR(1);	
	DEFINE cDescripcionSPJWU	 CHAR(100);	
	DEFINE cDescripcionSPJOV	 CHAR(100);	
	DEFINE cDescripcionSPJVG	 CHAR(100);	
	DEFINE cCodRetSP			 CHAR(5);
			
	LET cCodRet  =   "00000";
	LET cMensaje = 'PROCESO EXITOSO';	
	LET cStatus						= '0';	
	LET cDescripcionSPJWU	  = 'Inserta datos de Remesas Western Union para sistema de PLD';
	LET cDescripcionSPJOV = 'Inserta datos de Remesas Orlandi Valuta para sistema de PLD';
	LET cDescripcionSPJVG = 'Inserta datos de Remesas Vigo para sistema de PLD';
	LET cCodRetSP = "00000";
	
	--SET DEBUG FILE TO  '/informix/adrian/sp_remesaswu_pld.out';
	--TRACE ON;
		
    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
                EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_remesaswu_pld");
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;
		
		IF NombreProceso = "" OR FechaIni = "" OR FechaFin = "" THEN
			LET cCodRet = '00001';
			LET cMensaje = "FALTAN PARAMETROS DE ENTRADA";
            RETURN cCodRet, cMensaje;
		ELSE
			EXECUTE PROCEDURE sp_inicializatablaspld('BWUN','',FechaFin) INTO cCodRetSP;				
			IF cCodRetSP <> '00000' THEN
				LET cCodRet = '00001';
				LET cMensaje = "ERROR AL BORRAR TABLAS DE PASO DE WU";
				RETURN cCodRet, cMensaje;			
			END IF;	
			
			IF FechaIni = FechaFin THEN		
				IF NOT EXISTS (SELECT * FROM "informix".sac_procesos_jobs where proceso='IND_PLD_WU' and fecha_proceso = FechaFin) THEN									
					--INSERTA EN BITACORA
					EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_PLD_WU', FechaFin, '0', 'informix', 'sp_remesaswu_pld_wu', cDescripcionSPJWU);
				ELSE
					SELECT status 
					INTO cStatus
					FROM "informix".sac_procesos_jobs 
					WHERE proceso='IND_PLD_WU' and fecha_proceso = FechaFin;
					IF cStatus = '0' THEN						
						--DELETE {+INDEX("informix".sac_pld_remesas idxsac_pld_remesasft)} FROM "informix".sac_pld_remesas where tipo_remesa='WUN' and fecha_proceso = FechaFin;										
						EXECUTE PROCEDURE sp_inicializatablaspld('','WUN',FechaFin) INTO cCodRetSP;			
						IF cCodRetSP <> '00000' THEN
							LET cCodRet = '00001';
							LET cMensaje = "ERROR AL BORRAR REGISTROS DE WU EN TABLA DE PLD";
							RETURN cCodRet, cMensaje;			
						END IF;	
					END IF;
				END IF;			
			END IF;			
			IF cStatus = '0' THEN
				--WU
				EXECUTE PROCEDURE "informix".sp_remesaswu_pld_wu('WUN',FechaIni, FechaFin) INTO cCodRet, cMensaje;
				IF cCodRet <> '00000' THEN
					RETURN cCodRet, cMensaje;
				END IF;				
				--ACTUALIZA EN BITACORA
				EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_PLD_WU', FechaFin, '1', 'informix', 'sp_remesaswu_pld_wu', cDescripcionSPJWU);
			END IF;	
			LET cStatus = '0';
			
			EXECUTE PROCEDURE sp_inicializatablaspld('BWUN','',FechaFin) INTO cCodRetSP;			
			IF cCodRetSP <> '00000' THEN
				LET cCodRet = '00001';
				LET cMensaje = "ERROR AL BORRAR TABLAS DE PASO DE OVA";
				RETURN cCodRet, cMensaje;			
			END IF;	
			
			IF FechaIni = FechaFin THEN		
				IF NOT EXISTS (SELECT * FROM "informix".sac_procesos_jobs where proceso='IND_PLD_OV' and fecha_proceso = FechaFin) THEN
					--INSERTA EN BITACORA
					EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_PLD_OV', FechaFin, '0', 'informix', 'sp_remesaswu_pld_ov', cDescripcionSPJOV);
				ELSE
					SELECT status 
					INTO cStatus
					FROM "informix".sac_procesos_jobs 
					WHERE proceso='IND_PLD_OV' and fecha_proceso = FechaFin;
					IF cStatus = '0' THEN						
						--DELETE {+INDEX("informix".sac_pld_remesas idxsac_pld_remesasft)} FROM "informix".sac_pld_remesas where tipo_remesa='OVA' and fecha_proceso = FechaFin;										
						EXECUTE PROCEDURE sp_inicializatablaspld('','OVA',FechaFin) INTO cCodRetSP;			
						IF cCodRetSP <> '00000' THEN
							LET cCodRet = '00001';
							LET cMensaje = "ERROR AL BORRAR REGISTROS DE OVA EN TABLA DE PLD";
							RETURN cCodRet, cMensaje;			
						END IF;	
					END IF;
				END IF;			
			END IF;				
			IF cStatus = '0' THEN					
				--OV
				EXECUTE PROCEDURE "informix".sp_remesaswu_pld_ov('WUN',FechaIni, FechaFin) INTO cCodRet, cMensaje;
				IF cCodRet <> '00000' THEN
					RETURN cCodRet, cMensaje;
				END IF;			
				--ACTUALIZA EN BITACORA
				EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_PLD_OV', FechaFin, '1', 'informix', 'sp_remesaswu_pld_ov', cDescripcionSPJOV);			
			END IF;
			LET cStatus = '0';			
			
			EXECUTE PROCEDURE sp_inicializatablaspld('BWUN','',FechaFin) INTO cCodRetSP;			
			IF cCodRetSP <> '00000' THEN
				LET cCodRet = '00001';
				LET cMensaje = "ERROR AL BORRAR TABLAS DE PASO DE VG";
				RETURN cCodRet, cMensaje;			
			END IF;	
			IF FechaIni = FechaFin THEN		
				IF NOT EXISTS (SELECT * FROM "informix".sac_procesos_jobs where proceso='IND_PLD_V' and fecha_proceso = FechaFin) THEN
					--INSERTA EN BITACORA
					EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_PLD_V', FechaFin, '0', 'informix', 'sp_remesaswu_pld_vg', cDescripcionSPJVG);
				ELSE
					SELECT status 
					INTO cStatus
					FROM "informix".sac_procesos_jobs 
					WHERE proceso='IND_PLD_V' and fecha_proceso = FechaFin;
					IF cStatus = '0' THEN					
						--DELETE {+INDEX("informix".sac_pld_remesas idxsac_pld_remesasft)} FROM "informix".sac_pld_remesas where tipo_remesa='VIG' and fecha_proceso = FechaFin;										
						EXECUTE PROCEDURE sp_inicializatablaspld('','VIG',FechaFin) INTO cCodRetSP;			
						IF cCodRetSP <> '00000' THEN
							LET cCodRet = '00001';
							LET cMensaje = "ERROR AL BORRAR REGISTROS DE VG EN TABLA DE PLD";							
							RETURN cCodRet, cMensaje;			
						END IF;		
					END IF;
				END IF;			
			END IF;			
			IF cStatus = '0' THEN			
				--VG
				EXECUTE PROCEDURE "informix".sp_remesaswu_pld_vg('WUN',FechaIni, FechaFin) INTO cCodRet, cMensaje;
				IF cCodRet <> '00000' THEN
					RETURN cCodRet, cMensaje;
				END IF;
				--ACTUALIZA EN BITACORA
				EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_PLD_V', FechaFin, '1', 'informix', 'sp_remesaswu_pld_vg', cDescripcionSPJVG);	
			END IF;
		END IF;			
		
		RETURN cCodRet, cMensaje;

	END;
			EXECUTE PROCEDURE sp_inicializatablaspld('BWUN','',FechaFin) INTO cCodRetSP;
			IF cCodRetSP <> '00000' THEN
				LET cCodRet = '00001';
				LET cMensaje = "ERROR AL BORRAR TABLAS DE PASO DE WU";
				RETURN cCodRet, cMensaje;			
			END IF;	
END PROCEDURE;