CREATE PROCEDURE "informix".sp_consultabenef_inver(pEmpresa CHAR(3), pCuenta CHAR(20),pOpcion CHAR(1))
RETURNING CHAR(6) AS cCodRet, CHAR(20) AS cNumcte, CHAR(104) AS cNombreCompleto, CHAR(1) AS cCodParentesco,CHAR(20) AS cDesParentesco, SMALLINT AS sPorcentaje;

--DEFINICION DE VARIABLES
DEFINE cCodRet  CHAR(6);
DEFINE cNumcte CHAR(20);
DEFINE cNombreCompleto CHAR(104);
DEFINE cCodParentesco CHAR(1);
DEFINE cDesParentesco CHAR(20);
DEFINE sPorcentaje 	SMALLINT;
DEFINE iSqlErr INTEGER;

--INICIALIZACION DE VARIABLES 
LET cCodret	= "000000";
LET cNumCte ="";
LET cNombreCompleto ="";
LET cCodParentesco="";
LET cDesParentesco="";
LET sPorcentaje=0;
LET iSqlErr = 0;

--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_consultabenef_inver.out';
    --TRACE ON;
	
BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN  cCodRet,cNumcte,cNombreCompleto,cCodParentesco,cDesParentesco,sPorcentaje;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		IF TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pCuenta,'')) ='' OR TRIM(NVL(pOpcion,''))='' THEN
			LET cCodret = '000001'; --Parámetros de entrada vacíos
			RETURN  cCodRet,cNumcte,cNombreCompleto,cCodParentesco,cDesParentesco,sPorcentaje;
		ELSE
		
			IF TRIM(NVL(pOpcion,''))='1' THEN
				FOREACH
					SELECT parentesco, porcentaje,numcte
					INTO   cCodParentesco,sPorcentaje,cNumcte
					FROM bdicheq:"informix".sc_beneficiario
					WHERE cuenta=TRIM(NVL(pCuenta,''))
					AND empresa=TRIM(NVL(pEmpresa,''))
					
						SELECT TRIM(nombre1)||' ' || TRIM(NVL(nombre2,'')) ||' ' || TRIM(apell_paterno) ||' ' || TRIM(NVL(apell_materno,''))
						INTO cNombreCompleto
						FROM bdinteg:"informix".si_cliente
						WHERE numcte=TRIM(NVL(cNumcte,'')) 
						AND empresa=TRIM(NVL(pEmpresa,''));
						
						IF dbinfo("sqlca.sqlerrd2") = 0 THEN
							LET cCodret = '000002'; --No se encontraron registros
							LET cNumCte ="";
							LET cNombreCompleto ="";
							LET cCodParentesco="";
							LET cDesParentesco="";
							LET sPorcentaje=0;
						ELSE
							SELECT descripcion
							INTO cDesParentesco
							FROM bdinteg:"informix".si_parentesco
							WHERE parentesco= TRIM(NVL(cCodParentesco,''))
							AND empresa=TRIM(NVL(pEmpresa,''));
							
							IF dbinfo("sqlca.sqlerrd2") = 0 THEN
								LET cCodret = '000002'; --No se encontraron registros
								LET cNumCte ="";
								LET cNombreCompleto ="";
								LET cCodParentesco="";
								LET cDesParentesco="";
								LET sPorcentaje=0;
							END IF
						END IF
					RETURN  cCodRet,cNumcte,cNombreCompleto,cCodParentesco,cDesParentesco,sPorcentaje WITH RESUME;
				END FOREACH;
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cCodret = '000002'; --No se encontraron registros
						LET cNumCte ="";
						LET cNombreCompleto ="";
						LET cCodParentesco="";
						LET cDesParentesco="";
						LET sPorcentaje=0;
						RETURN  cCodRet,cNumcte,cNombreCompleto,cCodParentesco,cDesParentesco,sPorcentaje;
				END IF
			ELIF TRIM(NVL(pOpcion,''))='2' THEN
				FOREACH
					SELECT parentesco, porcentaje,numcte
					INTO   cCodParentesco,sPorcentaje,cNumcte
					FROM bdinvers:"informix".sv_benefic
					WHERE cuenta=TRIM(NVL(pCuenta,''))
					AND empresa=TRIM(NVL(pEmpresa,''))
			
						SELECT TRIM(nombre1)||' ' || TRIM(NVL(nombre2,'')) ||' ' || TRIM(apell_paterno) ||' ' || TRIM(NVL(apell_materno,''))
						INTO cNombreCompleto
						FROM bdinteg:"informix".si_cliente
						WHERE numcte=TRIM(NVL(cNumcte,'')) 
						AND empresa=TRIM(NVL(pEmpresa,''));
						
						IF dbinfo("sqlca.sqlerrd2") = 0 THEN
							LET cCodret = '000002'; --No se encontraron registros
							LET cNumCte ="";
							LET cNombreCompleto ="";
							LET cCodParentesco="";
							LET cDesParentesco="";
							LET sPorcentaje=0;
						ELSE
							SELECT descripcion
							INTO cDesParentesco
							FROM bdinteg:"informix".si_parentesco
							WHERE parentesco= TRIM(NVL(cCodParentesco,''))
							AND empresa=TRIM(NVL(pEmpresa,''));
							
							IF dbinfo("sqlca.sqlerrd2") = 0 THEN
								LET cCodret = '000002'; --No se encontraron registros
								LET cNumCte ="";
								LET cNombreCompleto ="";
								LET cCodParentesco="";
								LET cDesParentesco="";
								LET sPorcentaje=0;
							END IF
						END IF
					RETURN  cCodRet,cNumcte,cNombreCompleto,cCodParentesco,cDesParentesco,sPorcentaje WITH RESUME;
				END FOREACH;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cCodret = '000002'; --No se encontraron registros
						LET cNumCte ="";
						LET cNombreCompleto ="";
						LET cCodParentesco="";
						LET cDesParentesco="";
						LET sPorcentaje=0;
						RETURN  cCodRet,cNumcte,cNombreCompleto,cCodParentesco,cDesParentesco,sPorcentaje;
				END IF
			END IF
		END IF
END
END PROCEDURE
DOCUMENT
"Descripción: Consulta datos de los beneficiarios de una cuenta de Inversión Creciente o Pagaré",
"Autor : Leslie Rendón",
"FECHA : 27/10/2014",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_consultacte_altaunica(pEmpresa CHAR(3), pNumero CHAR(16),pOpcion CHAR(1))
RETURNING CHAR(6) AS cCodRet,CHAR(26) AS cPrimerNombre,CHAR(26) AS cSegundoNombre,CHAR(26) AS cApellidoPaterno,CHAR(26) AS cApellidoMaterno,DATE AS dFechaNacimiento,CHAR(13) AS cRfc,CHAR(20) AS cClienteCoppel,CHAR(20) AS cNumCte;

--DEFINICION DE VARIABLES
DEFINE cCodRet  CHAR(6);
DEFINE cCodRet2  CHAR(5);
DEFINE cPrimerNombre  CHAR(26);
DEFINE cSegundoNombre CHAR(26);
DEFINE cApellidoPaterno CHAR(26);
DEFINE cApellidoMaterno CHAR(26);
DEFINE dFechaNacimiento DATE;
DEFINE cRfc CHAR(13);
DEFINE cClienteCoppel CHAR(20);
DEFINE iSqlErr INTEGER;
DEFINE cNumCte CHAR(20);
--INICIALIZACION DE VARIABLES 
LET cCodret	= "000000";
LET cCodret2 = "00000";
LET cPrimerNombre = "";
LET cSegundoNombre ="";
LET cApellidoPaterno ="";
LET cApellidoMaterno ="";
LET dFechaNacimiento ="";
LET cRfc ="";
LET cClienteCoppel ="";
LET iSqlErr = 0;
LET cNumCte ="";
--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_consultacte_altaunica.out';
    --TRACE ON;
	
BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN  cCodRet,cPrimerNombre,cSegundoNombre,cApellidoPaterno,cApellidoMaterno,dFechaNacimiento,cRfc,cClienteCoppel,cNumcte;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		IF TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pNumero,'')) ='' OR TRIM(NVL(pOpcion,''))='' THEN
			LET cCodret = '000001'; --Parámetros de entrada vacíos
		ELSE
			IF TRIM(NVL(pOpcion,''))='1' THEN
				SELECT numcte 
				INTO cNumCte
				FROM  bdicheq:"informix".sc_tarjeta
				WHERE num_tarjeta=TRIM(NVL(pNumero,''))
				AND empresa=TRIM(NVL(pEmpresa,''));
			ELIF TRIM(NVL(pOpcion,''))='2' THEN
				FOREACH
					SELECT num_cte
					INTO cNumCte
					FROM bdicheq:"informix".sc_maechq
					WHERE cuenta= TRIM(NVL(pNumero,''))
					AND empresa=TRIM(NVL(pEmpresa,''))
					UNION
					SELECT num_cte
					FROM bdinvers:"informix".sv_maeinv
					WHERE cuenta= TRIM(NVL(pNumero,''))
					AND empresa=TRIM(NVL(pEmpresa,''))
				END FOREACH;
			ELIF TRIM(NVL(pOpcion,''))='3' THEN
				LET cNumCte=pNumero;
			ELIF TRIM(NVL(pOpcion,''))='4' THEN
				SELECT numcte 
				INTO cNumCte
				FROM  bdicred:"informix".sd_tarjeta
				WHERE num_tarjeta=TRIM(NVL(pNumero,''))
				AND empresa=TRIM(NVL(pEmpresa,''));
			END IF
			
			SELECT apell_paterno,apell_materno,nombre1,nombre2,rfc
			INTO cApellidoPaterno, cApellidoMaterno, cPrimerNombre, cSegundoNombre, cRfc
			FROM bdinteg:"informix".si_cliente
			WHERE numcte=TRIM(NVL(cNumcte,''))
			AND empresa=TRIM(NVL(pEmpresa,''));
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodret	= "000002";
				LET cPrimerNombre='';
				LET cSegundoNombre='';
				LET cApellidoPaterno='';
				LET cApellidoMaterno='';
				LET dFechaNacimiento='';
				LET cRfc='';
				LET cClienteCoppel='';
			ELSE
				SELECT fecha_nac
				INTO dFechaNacimiento
				FROM bdinteg:"informix".si_ctepf
				WHERE numcte= TRIM(NVL(cNumcte,''))
				AND empresa=TRIM(NVL(pEmpresa,''));
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodret	= "000002";
					LET cPrimerNombre='';
					LET cSegundoNombre='';
					LET cApellidoPaterno='';
					LET cApellidoMaterno='';
					LET dFechaNacimiento='';
					LET cRfc='';
					LET cClienteCoppel='';
				ELSE
					EXECUTE PROCEDURE bdinteg:"informix".sp_consultactesrelacionados (TRIM(NVL(pEmpresa,'')),TRIM(NVL(cNumcte,'')))
					INTO cCodret2, cClienteCoppel;
				END IF
			END IF
		END IF
		RETURN  cCodRet,cPrimerNombre,cSegundoNombre,cApellidoPaterno,cApellidoMaterno,dFechaNacimiento,cRfc,TRIM(NVL(cClienteCoppel,'')),TRIM(NVL(cNumcte,''));
END
END PROCEDURE
DOCUMENT
"Descripción: Consulta datos generales del cliente",
"Autor : Leslie Rendón",
"FECHA : 24/10/2014",
"Descripción: Se modifica para agregar consulta por Tarjeta de crédito",
"Modifico : Leslie Rendón",
"FECHA : 16/12/2014",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_consultabiometria(pTipo CHAR(1), pCodSuc CHAR(4), pNumCte CHAR(20))
	RETURNING 	CHAR(5) AS CodRet, 
				CHAR(1) AS SucBiometria, 
				CHAR(1) AS CteBiometria;

	--Definicion de Variables
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cSucBiometria CHAR(1);
	DEFINE cCteBiometria CHAR(1);

	--Inicializacion de Variables
	LET iSqlErr = 0;
	LET cCodRet = '000';
	LET cSucBiometria = '0';
	LET cCteBiometria = '0';

	--SET DEBUG FILE TO '/informix/IrisA/sp_consultabiometria.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cSucBiometria, cCteBiometria;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF pTipo = '1' THEN
			SELECT ibanbiometria INTO cSucBiometria
			FROM "informix".si_sucursales WHERE sucursal = pCodSuc;

			IF NVL(cSucBiometria,'') = '1' AND NVL(pNumCte,'') <> '' THEN
				SELECT tpo_biometria INTO cCteBiometria
				FROM "informix".si_cliente WHERE numcte = pNumCte;
			END IF;

		ELSE
			LET cCodRet = '001'; -- No Existe el Tipo de Consulta
		END IF;

		RETURN cCodRet, NVL(cSucBiometria,''), NVL(cCteBiometria,'');
	END;
END PROCEDURE;