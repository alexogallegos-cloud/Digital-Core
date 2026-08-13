CREATE PROCEDURE "informix".sp_enmascarado(pCadena CHAR(50),pIndicador INTEGER)
RETURNING CHAR(05)       AS Codigo_Retorno,
          CHAR(50)       AS Cadena_Final;
	
--*******************************************************************************************************
-- Realizo   : 
-- Proyecto  : 
-- Actividad : 
-- Fecha     : 

--Autor: 
--Fecha: 05/05/2022
--ModificaciÃ³n: 
--*******************************************************************************************************
-- EL INDICADOR ES LA OPCION DE ENMASCARAR DIFERENTES CAMPOS COMO:
--INDICADOR 1: ENMASCARA EL NOMBRE DEL CLIENTE
--INDICADIR 2: ENMASCARA EL NUMERO DE TARJETA DEL CLIENTE
--*******************************************************************************************************

DEFINE cCodRet         	CHAR(6);
DEFINE cErrorInfo      	CHAR(80);
DEFINE cErrorInfoR     	CHAR(80);
DEFINE iSqlerr         	INTEGER;
DEFINE sIsamErr        	SMALLINT;
DEFINE iRegistros      	INTEGER;
DEFINE cCadena 			CHAR(50);
DEFINE sLongitud 		SMALLINT;
DEFINE dContador 		SMALLINT;
DEFINE cCadenaFinal		CHAR(50);

LET cCodRet         = '000000';
LET cErrorInfo      = "";
--LET cErrorInfoR     = "OPERACION EXITOSA";
LET iSqlerr         = 0;
LET iRegistros      = 0;
LET cCadenaFinal	= '';


BEGIN

ON EXCEPTION  SET iSqlerr, sIsamErr, cErrorInfo
	IF iSqlerr <> 0  THEN
		LET  cCodRet  = iSqlerr;
--		LET cErrorInfoR = cErrorInfo;
     RETURN cCodRet,cCadenaFinal;
	END IF;
END  EXCEPTION

--set debug file to '/informix/sysistbus/logs_sp/sp_enmascarado.out';
--trace on;
--set debug file to "/informix/IvanZazueta/sp_enmascarado.out";
--trace on;

		IF NVL(TRIM(pCadena),'') = '' THEN
			LET cCodRet     = '00001';	-- 'NO SE ESPECIFICA LA CADENA'
			RETURN cCodRet,cCadenaFinal;
		ELIF pIndicador = '' OR pIndicador NOT IN (1,2) THEN
			LET cCodRet     = '00002';	-- 'NO SE ESPECIFICA EL INDICADOR O INDICADOR INCORRECTO'
			RETURN cCodRet,cCadenaFinal;		 
		END IF;

  IF pIndicador = 1 THEN --Enmascarado  de nombre de cliente
  
		LET cCadena = TRIM(pCadena);
		LET sLongitud = length(cCadena);
		LET dContador = 1;

		IF sLongitud <= 3 THEN
			LET cCadena = '';
			WHILE dContador <= sLongitud
				LET cCadena = TRIM(cCadena) || '*';
				LET dContador = dContador + 1;
			END WHILE;
			LET cCadenaFinal = TRIM(cCadena);
		ELSE
			WHILE dContador < sLongitud
				IF dContador = 1 THEN
					LET cCadena = substr(TRIM(cCadena),dContador,1);
				ELSE
					LET cCadena = TRIM(cCadena) || '*';
				END IF;
				LET dContador = dContador + 1;
			END WHILE;
			LET cCadenaFinal = TRIM(cCadena) || substr(TRIM(pCadena),-1);
		END IF;

		RETURN cCodRet,TRIM(cCadenaFinal);
		
  ELIF pIndicador = 2 THEN --Enmascarado de numero de tarjeta
       
		LET cCadena = TRIM(pCadena);
		LET sLongitud = length(cCadena);
		LET dContador = 1;

		IF sLongitud <= 3 THEN
			LET cCadena = '';
			WHILE dContador <= sLongitud
				LET cCadena = TRIM(cCadena) || '*';
				LET dContador = dContador + 1;
			END WHILE;
			LET cCadenaFinal = TRIM(cCadena);
		ELSE
			WHILE dContador < sLongitud
				IF dContador = 1 THEN
					LET cCadena = substr(TRIM(cCadena),dContador,0);
				ELSE
					LET cCadena = TRIM(cCadena) || '*';
				END IF;
				LET dContador = dContador + 1;
			END WHILE;
			--LET cCadenaFinal = TRIM(cCadena);-- || substr(TRIM(pCadena),-4);
			LET cCadenaFinal = substr(TRIM(cCadena),1,12) || substr(TRIM(pCadena),-4);
		END IF;

		RETURN cCodRet,TRIM(cCadenaFinal); 
  END IF;
  
END;
END PROCEDURE;