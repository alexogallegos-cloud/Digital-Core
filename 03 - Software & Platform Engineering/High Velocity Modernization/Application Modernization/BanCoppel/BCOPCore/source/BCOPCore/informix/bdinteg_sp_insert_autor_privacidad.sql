CREATE PROCEDURE "informix".sp_insert_autor_privacidad(pempresa CHAR(3), pnumcte CHAR(20), psucursal CHAR(4), 
                                                       prespuesta char(1), pmensaje VARCHAR(200))
   returning char(5);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNumCte CHAR(20);

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

    IF psucursal = '' OR psucursal IS NULL THEN
       LET cCodRet = '00001';
       RETURN cCodRet;
    END IF;

    IF prespuesta = '' OR prespuesta IS NULL THEN
       LET cCodRet = '00001';
       RETURN cCodRet;
    END IF;

    IF pmensaje = '' OR pmensaje IS NULL THEN
       LET cCodRet = '00001';
       RETURN cCodRet;
    END IF;

    INSERT INTO si_autorizacion_privacidad(empresa,numcte,sucursal,respuesta,mensaje,fecha)
    VALUES (pempresa,pnumcte,psucursal,prespuesta,pmensaje,current);

RETURN cCodRet;

END
END PROCEDURE;