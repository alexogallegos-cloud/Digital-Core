CREATE PROCEDURE "informix".sp_depura_parametrico()
   RETURNING CHAR(5) AS CodRet;
   --##### Define variables de Retorno #####
	DEFINE cCodRet          CHAR(5);
	DEFINE cCodRet2		    CHAR(6);
	DEFINE cNumcte_pros		CHAR(10);
   --###### Inicializa Variables ###########
	LET cCodRet         = '00000'; 
	LET cNumcte_pros    = ''; 
	LET cCodRet2        = ''; 

	--SET DEBUG FILE TO "sp_depura_parametrico.out";
	--TRACE ON;

   FOREACH  SELECT NUMCTE_PROS 
			INTO cNumcte_pros 
			FROM "informix".pr_cliente 
			WHERE status_numcte_pros = 'CP'

    IF cNumcte_pros IS NOT NULL THEN
       EXECUTE PROCEDURE "informix".sp_guardaprospecto_his(cNumcte_pros)
		INTO cCodRet2;
	IF cCodRet2 <> "00000" THEN
			LET cCodRet =  cCodRet2;
			END IF;
	ELSE
        LET cCodRet = '00001';
      END IF;
    END FOREACH;
  RETURN cCodRet;
END PROCEDURE;