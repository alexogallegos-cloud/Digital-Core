CREATE PROCEDURE "informix".sp_borra_huella_pros(pcliente CHAR(9))
   RETURNING CHAR(3);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE sExiste CHAR(9);
DEFINE sTipoCliente CHAR(1);

LET iSqlErr = 0;
LET cCodRet = '';
LET sExiste='';
LET sTipoCliente = '';

--SET DEBUG FILE TO '/tmp/anj/sp_autoriza_datos_contacto.sql';
--		TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
   IF iSqlErr <> 0 THEN
       LET cCodRet = iSqlErr;
       RETURN cCodRet;
   END IF;
END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        --let pcliente=pcliente;
        select count(numcte) INTO sExiste  from si_cte_huella where numcte=pcliente;
		select tipo_cliente INTO sTipoCliente  from si_cliente where numcte=pcliente;

        IF sExiste<>'0' AND sTipoCliente = '2' THEN
           DELETE FROM si_cte_huella WHERE numcte=pcliente;
        END IF   

         LET cCodRet = '000';
        

RETURN cCodRet;

END
END PROCEDURE;