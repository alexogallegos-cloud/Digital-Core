CREATE PROCEDURE "informix".sp_inserta_tarjeta_vencida(pempresa CHAR(3), pnumcte CHAR(20), ptarjeta_ant CHAR(20), ptarjeta_new CHAR(20), pTipoRep CHAR(5))
   returning char(5);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNumCte CHAR(20);
DEFINE cProdIntC CHAR(5);
DEFINE cProdCred CHAR(5);

LET iSqlErr = 0;
LET cCodRet = "00000";
LET cNumCte = '';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF iSqlErr <> 0 THEN
            RETURN iSqlErr;
        END IF;
    END EXCEPTION;

    IF pempresa = '' OR pempresa IS NULL THEN
       LET cCodRet = '00001';
       RETURN cCodRet;
    END IF;

    IF pnumcte = '' OR pnumcte IS NULL THEN
       LET cCodRet = '00001';
       RETURN cCodRet;
    END IF;

    IF ptarjeta_ant = '' OR ptarjeta_ant IS NULL THEN
       LET cCodRet = '00001';
       RETURN cCodRet;
    END IF;

    IF pTipoRep='05' THEN
        INSERT INTO si_tarjeta_vencimiento(empresa,numcte,num_tarjeta_ant, num_tarjeta_new, fecha_rep)
        VALUES (pempresa,pnumcte,ptarjeta_ant,ptarjeta_new,current);
    END IF;

    IF ptarjeta_new<>'' THEN
          SELECT codproductotarjeta 
            INTO cProdIntC
             FROM intercard:tarjeta WHERE numtarjeta=ptarjeta_ant;

          UPDATE intercard:tarjeta  SET  codproductotarjeta= cProdIntC WHERE numtarjeta=ptarjeta_new;
          
    END IF;

RETURN cCodRet;

END
END PROCEDURE;