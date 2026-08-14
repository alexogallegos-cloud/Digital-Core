CREATE PROCEDURE "informix".sp_act_norecuperados(pcliente CHAR(9))
   RETURNING CHAR(3);

DEFINE iSqlErr   INTEGER;
DEFINE cCodRet   CHAR(5);


LET iSqlErr = 0;
LET cCodRet = '000';

--SET DEBUG FILE TO '/tmp/anj/sp_autoriza_datos_contacto.sql';
--		TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
   IF iSqlErr <> 0 THEN
       LET cCodRet = iSqlErr;
       RETURN cCodRet;
   END IF;
END EXCEPTION;
        
    update ss_cont_norecuperados set bandera='1' where numcte=pcliente;
    
RETURN cCodRet;

END
END PROCEDURE;