CREATE PROCEDURE "informix".sp_validacte_transfer(cNumCtePrincipal CHAR(20))
				returning 
				CHAR(5)     AS Cod_Retorno,
                INT    		AS iTpo_cliente,
				CHAR(20)	AS cNumCte;
				
DEFINE iTpo_cliente		INT;
DEFINE cCodRet			CHAR(5);
DEFINE iExiste			INT; 
DEFINE iSql_err         INT; 
DEFINE cNumCte 			CHAR(20);
DEFINE cNumCteTf 		CHAR(20);

LET iTpo_cliente = 2;
LET iExiste = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ; 
LET cNumcte = "";
LET cNumcteTf = "";

BEGIN
     ON EXCEPTION SET iSql_err
          IF iSql_err <> 0 THEN
               LET cCodRet = iSql_err;
               RETURN cCodRet,iTpo_cliente,cNumCte;
          END IF;
     END EXCEPTION;

	 --SET DEBUG FILE TO "/informix/CHVN/transfer/sp_validacte_transfer.out";
     --TRACE ON;
	 
	 SELECT count(*)
	 INTO iExiste
	 FROM bditransfer:tf_maecte
	 WHERE numcte = cNumCtePrincipal;
	 
	  IF iExiste = 0 THEN
		SELECT FIRST 1 numcte, numcte_tf
		INTO cNumCte, cNumCteTf
		FROM bditransfer:tf_maecte
		WHERE numcte_tf = cNumCtePrincipal;
		IF cNumCteTf IS NOT NULL AND (cNumCte IS NULL or cNumCte = '') THEN
			LET iTpo_cliente = 1;
			LET cNumCtePrincipal = cNumCteTf;
			RETURN cCodRet,iTpo_cliente,cNumCtePrincipal;
		ELSE
		LET iTpo_cliente = 2;
		LET cNumCtePrincipal = cNumCte;
		END IF;
		LET iTpo_cliente = 2;
	 END IF;
	 
	 RETURN cCodRet,iTpo_cliente,cNumCtePrincipal;
END
END PROCEDURE;