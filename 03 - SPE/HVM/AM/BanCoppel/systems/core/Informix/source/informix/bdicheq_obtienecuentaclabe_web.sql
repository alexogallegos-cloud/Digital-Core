CREATE PROCEDURE "informix".obtienecuentaclabe_web (sEmpresa CHAR(3), sNumCte CHAR(20), sNumCuenta CHAR(20))
    RETURNING CHAR(5), CHAR(20);

--DEFINICIÃÂN DE VARIABLES
    DEFINE iSqlErr            INTEGER;
    DEFINE sCodRet        CHAR(5);
    DEFINE sClabe           CHAR(20);

--INICIALIZACIÃÂN DE VARIABLES
    LET sCodRet = "00000";
    LET sClabe = "";

--SET DEBUG FILE TO '/tmp/ObtieneCuentaClabe.out';
--TRACE ON;

    BEGIN
        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                        LET sCodRet = iSqlErr;
                        RETURN sCodRet, sClabe;
                END IF;
        END EXCEPTION;

        SELECT cuenta_clabe INTO sClabe
        FROM sc_maechq
        WHERE num_cte = sNumCte
        AND cuenta = sNumCuenta;
        
        IF sClabe = '' or sClabe is null THEN
                LET sCodRet = "00001"; -- NO ESISTE LA CUENTA CLABE
                RETURN sCodRet, sClabe;
        END IF;

        RETURN sCodRet, sClabe;

    END;
--*************************************************************************
--| Procedimiento   : ObtieneCuentaClabe
--| VersiÃÂ³n         : 1.0
--| Creado por      : Martha Aguirre
--| Fecha creacion  : Junio de 2009
--| DescripciÃÂ³n     : Realiza una consulta en la tabla sc_maechq para 
--|				      obtener la cuenta clabe del cliente cuando se le
--|					  otorga una cuenta efectiva.
--*************************************************************************
END PROCEDURE;