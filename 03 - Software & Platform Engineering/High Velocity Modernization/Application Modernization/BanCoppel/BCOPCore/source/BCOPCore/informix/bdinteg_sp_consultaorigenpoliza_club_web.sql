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