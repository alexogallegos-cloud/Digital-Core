CREATE PROCEDURE "informix".sp_actualiza_succte(pnumcte CHAR(9), pempsol_sucursal CHAR(8), pempsos_vobo  CHAR(8), pempbco_actualiza  CHAR(8), psuc_nueva  CHAR(4), psuc_solicito  CHAR(4))
RETURNING CHAR(5) AS cCodRet;

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE sSucAnterior CHAR(4);

LET iSqlErr = 0;
LET cCodRet = '';
LET sSucAnterior = '0000';

--SET DEBUG FILE TO '/tmp/anj/sp_autoriza_datos_contacto.sql';
--		TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
   IF iSqlErr <> 0 THEN
       LET cCodRet = iSqlErr;
       RETURN cCodRet;
   END IF;
END EXCEPTION;


        --let pcliente=pcliente;
        select sucursal INTO sSucAnterior  from si_cliente where numcte=pnumcte;
        IF sSucAnterior<>'' THEN
            INSERT INTO "informix".si_bitcamb_sucursal(numcte, empsol_sucursal, empsos_vobo, empbco_actualiza, suc_anterior, suc_nueva, suc_solicito, fecha) 
                            VALUES(pnumcte, pempsol_sucursal, pempsos_vobo, pempbco_actualiza, sSucAnterior, psuc_nueva, psuc_solicito, current);

            UPDATE "informix".si_cliente SET sucursal=psuc_nueva WHERE numcte=pnumcte;

            LET cCodRet = '00000';
        ELSE
            LET cCodRet = '00888';        END IF;
        

RETURN cCodRet;

END
END PROCEDURE;