CREATE PROCEDURE "informix".sp_consultapagares(pOpticon INTEGER, pNumcte CHAR(20), pCuenta CHAR(20), pSecuencia SMALLINT)
	RETURNING CHAR(6) AS CodRetorno, CHAR(20) AS Cuenta, CHAR(104) AS Nombre, CHAR(1) AS Status;

--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);

DEFINE cNombre1 CHAR(26);
DEFINE cNombre2 CHAR(26);
DEFINE cApellPat CHAR(26);
DEFINE cApellMat CHAR(26);
DEFINE cNomCompleto CHAR(104);
DEFINE cCuenta CHAR(20);
DEFINE cCuenta2 CHAR(20);
DEFINE sCiclo SMALLINT;
DEFINE cNumProd CHAR(4);
DEFINE cStatus CHAR(1);

--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodRet = '000000';

LET cNombre1 = '';
LET cNombre2 = '';
LET cApellPat = '';
LET cApellMat = '';
LET cNomCompleto = '';
LET cCuenta = '';
LET cCuenta2 = '';
LET sCiclo = 0;
LET cNumProd = '';
LET cStatus = '';


	--SET DEBUG FILE TO "/respaldosbd/Daniela/sp_consultapagares.out";
	--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCuenta, cNomCompleto,cStatus;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF pOpticon = 1 THEN --Consulta pagares por Numero de cliente
	
		SELECT nombre1, nombre2, apell_paterno, apell_materno
		INTO cNombre1, cNombre2, cApellPat, cApellMat
		FROM bdinteg:"informix".si_cliente WHERE numcte = pNumcte;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000279';
			RETURN cCodRet, cCuenta, cNomCompleto,cStatus;
		ELSE
			IF cNombre2 = '' THEN
				LET cNomCompleto = TRIM(cNombre1)||" "||TRIM(cApellPat)||" "||TRIM(cApellMat);
			ELSE
				LET cNomCompleto = TRIM(cNombre1)||" "||TRIM(cNombre2)||" "||TRIM(cApellPat)||" "||TRIM(cApellMat);
			END IF;
			
			FOREACH 
				SELECT cuenta INTO cCuenta FROM bdinvers:"informix".sv_maeinv WHERE num_cte = pNumcte AND status_cta = 1

				LET sCiclo = sCiclo + 1;			
				IF sCiclo <= pSecuencia THEN
					CONTINUE FOREACH;
				END IF;
				
				RETURN cCodRet, cCuenta, TRIM(cNomCompleto),cStatus WITH RESUME;
			END FOREACH;
				
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '000280';
				RETURN cCodRet, cCuenta, cNomCompleto,cStatus;
			END IF;
		END IF;
		
	ELIF pOpticon = 2 THEN --Consulta pagares y cuentas eje por numero de cuenta
		IF SUBSTR(pCuenta,0,2) = '30' THEN
			SELECT cuenta,cta_cheques,status_cta 
			INTO cCuenta, cCuenta2, cStatus 
			FROM bdinvers:"informix".sv_maeinv 
			WHERE empresa = "001"
			AND cuenta = pCuenta
			AND status_cta  in ('1','2');
		ELSE
			SELECT LIMIT 1 inv.cuenta,inv.cta_cheques,chq.status_cta
			INTO cCuenta, cCuenta2,cStatus 
			FROM bdinvers:"informix".sv_maeinv inv, bdicheq:"informix".sc_maechq chq
			WHERE chq.cuenta = pCuenta
			AND inv.cta_cheques = pCuenta
			AND inv.status_cta = '1';
		END IF;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cNumProd = SUBSTR(pCuenta,0,2);
			IF cNumProd = '30' THEN
				LET cCodRet = '000284';
			ELSE
				LET cCodRet = '000278';
			END IF;
			
			RETURN cCodRet, cCuenta, cNomCompleto,cStatus;
		ELSE
			LET cNumProd = SUBSTR(pCuenta,0,2);
			IF cNumProd = '30' THEN --Cuentas Eje: si consulta por pagare
				FOREACH
					SELECT cta_cheques 
					  INTO cCuenta 
					  FROM bdinvers:"informix".sv_maeinv  
					 WHERE empresa = "001" and cuenta = pCuenta and status_cta in ('1','2')
				
					LET sCiclo = sCiclo + 1;			
					IF sCiclo <= pSecuencia THEN
						CONTINUE FOREACH;
					END IF;
					
					RETURN cCodRet, cCuenta, cNomCompleto,cStatus WITH RESUME;
				END FOREACH;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '000282';
					RETURN cCodRet, cCuenta, cNomCompleto,cStatus;
				END IF;
				
			ELSE --Cuentas Pagare: si consulta por cuenta eje
				
				FOREACH
					SELECT cuenta 
					  INTO cCuenta 
					  FROM bdinvers:"informix".sv_maeinv 
					 WHERE cta_cheques = pCuenta
					   AND status_cta = '1'
				
					LET sCiclo = sCiclo + 1;			
					IF sCiclo <= pSecuencia THEN
						CONTINUE FOREACH;
					END IF;
					
					RETURN cCodRet, cCuenta, cNomCompleto,cStatus WITH RESUME;
				END FOREACH;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '000283';
					RETURN cCodRet, cCuenta, cNomCompleto,cStatus;
				END IF;
				
			END IF;
		END IF;
	END IF;
		
END;

END PROCEDURE
