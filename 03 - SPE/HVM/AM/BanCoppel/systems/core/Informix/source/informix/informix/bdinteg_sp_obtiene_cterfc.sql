CREATE PROCEDURE "informix".sp_obtiene_cterfc( pRfc CHAR(13))

RETURNING CHAR(5) AS codret , 
	      CHAR(9) as numcte;

DEFINE vCodret CHAR (5);
DEFINE vNumcte CHAR (20);
DEFINE vSql_err INTEGER;  

LET vCodret  = '00000';
LET vNumcte  = '';
LET vSql_err = 0;

 BEGIN

     ON EXCEPTION SET vSql_err
        IF vSql_err <> 0 THEN
           LET vCodret = vSql_err;
           RETURN vCodret, vNumcte ;
        END IF;
     END EXCEPTION;
     
     --SET DEBUG FILE TO "/tmp/sp_obtiene_cterfc.out";
     --TRACE ON;

     SET LOCK MODE TO WAIT 3;
     SET ISOLATION TO DIRTY READ;

     IF pRfc is null or pRfc ="" THEN 
        LET vCodret = '00002' ; -- Falta parametro de entrada
        RETURN vCodret, vNumcte ;

     END IF;

     SELECT LIMIT 1 numcte 
     INTO vNumcte
     FROM si_cliente 
     WHERE rfc = pRfc; 
 
     LET vNumcte = NVL(vNumcte,'');

     RETURN vCodret, vNumcte ;
 END;
END PROCEDURE;