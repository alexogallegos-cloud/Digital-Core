CREATE PROCEDURE "informix".sp_consultacte_altaunica_filtro_web(pEmpresa CHAR(3), pNumero CHAR(16),pOpcion CHAR(1))
RETURNING CHAR(5) AS cCodRet,CHAR(26) AS cPrimerNombre,CHAR(26) AS cSegundoNombre,CHAR(26) AS cApellidoPaterno,CHAR(26) AS cApellidoMaterno,DATE AS dFechaNacimiento,CHAR(13) AS cRfc,CHAR(20) AS cClienteCoppel,CHAR(20) AS cNumCte;

--DEFINICION DE VARIABLES
DEFINE cCodRet  CHAR(5);
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
LET cCodret	= "00000";
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

	--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_consultacte_altaunica_filtro.out';
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
			LET cCodret = '00001'; --ParÃÂ¡metros de entrada vacÃÂ­os
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
				LET cCodret	= "00002";
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
					LET cCodret	= "00002";
					LET cPrimerNombre='';
					LET cSegundoNombre='';
					LET cApellidoPaterno='';
					LET cApellidoMaterno='';
					LET dFechaNacimiento='';
					LET cRfc='';
					LET cClienteCoppel='';
				ELSE
					EXECUTE PROCEDURE bdinteg:"informix".sp_consultactesrelacionados_filtro (TRIM(NVL(pEmpresa,'')),TRIM(NVL(cNumcte,'')))
					INTO cCodret2, cClienteCoppel;
				END IF
			END IF
		END IF
		RETURN  cCodRet,cPrimerNombre,cSegundoNombre,cApellidoPaterno,cApellidoMaterno,dFechaNacimiento,cRfc,TRIM(NVL(cClienteCoppel,'')),TRIM(NVL(cNumcte,''));
END
END PROCEDURE
DOCUMENT
"DescripciÃÂ³n: Consulta datos generales del cliente",
"Autor : Leslie RendÃÂ³n",
"FECHA : 24/10/2014",
"DescripciÃÂ³n: Se modifica para agregar consulta por Tarjeta de crÃÂ©dito",
"Modifico : Leslie RendÃÂ³n",
"FECHA : 16/12/2014",
"BD    : bdinteg",
'Clon de sp sp_consultacte_altaunica, que deja en blanco el cliente coppel si empieza con 9 y es de 11 digitos',
'Autor :Obed Vega',
'FECHA : 01/Julio/2016',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_consultaorigenpoliza_club_web(
   pEmpresa CHAR(3),
   pNumCte CHAR(20),
   pTipoCte INTEGER
)
RETURNING CHAR(5) AS CodRet,
		  CHAR(1) AS OrigenPoliza;

DEFINE	cCodRet CHAR(5);
DEFINE	iSql_err INTEGER;
DEFINE cOrigenPol CHAR(1);
DEFINE sExiste SMALLINT;
DEFINE cCteBanco CHAR(20);

LET cCodRet = '00000';
LET iSql_err = 0;
LET cOrigenPol = '';
LET sExiste = 0;
LET cCteBanco = '';

BEGIN

    ON EXCEPTION SET iSql_err
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
           RETURN cCodRet, cOrigenPol;
        END IF;

    END EXCEPTION;

     --SET DEBUG FILE TO "/respaldosbd/obed/sp_consultaorigenpoliza_club.out";
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pNumCte,'') <> '' AND NVL(pTipoCte,0) <> 0  THEN
		IF pTipoCte = 2 THEN
			SELECT  numcte_banco
			INTO cCteBanco
			FROM "informix".si_relacion_ctebcplcpl 
			WHERE empresa = pEmpresa
			AND cliente = pNumCte;
			
			IF NVL(cCteBanco,'') = '' THEN
				LET cOrigenPol = 'N';
			END IF;
		ELSE
			LET cCteBanco = pNumCte;
		END IF;
		IF pTipoCte = 1 OR cOrigenPol <> 'N' THEN
			SELECT  COUNT(numcte)
			INTO sExiste
			FROM "informix".si_club_proteccion
			WHERE empresa = pEmpresa
			AND numcte = cCteBanco
			AND aceptada = '1';
			IF sExiste > 0 THEN
				LET cOrigenPol = 'S';
			ELSE
				LET cOrigenPol = 'N';
			END IF;
		END IF;
		
	ELSE
		LET cCodRet = '00001'; 
	END IF;	
	RETURN cCodRet, cOrigenPol;
END;
END PROCEDURE;