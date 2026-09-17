CREATE PROCEDURE "informix".obtienecuentaclabe (sEmpresa CHAR(3), sNumCte CHAR(20), sNumCuenta CHAR(20))
    RETURNING CHAR(5), CHAR(20);

--DEFINICIÓN DE VARIABLES
    DEFINE iSqlErr            INTEGER;
    DEFINE sCodRet        CHAR(5);
    DEFINE sClabe           CHAR(20);

--INICIALIZACIÓN DE VARIABLES
    LET sCodRet = "000";
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
                LET sCodRet = "001"; -- NO ESISTE LA CUENTA CLABE
                RETURN sCodRet, sClabe;
        END IF;

        RETURN sCodRet, sClabe;

    END;
--*************************************************************************
--| Procedimiento   : ObtieneCuentaClabe
--| Versión         : 1.0
--| Creado por      : Martha Aguirre
--| Fecha creacion  : Junio de 2009
--| Descripción     : Realiza una consulta en la tabla sc_maechq para 
--|				      obtener la cuenta clabe del cliente cuando se le
--|					  otorga una cuenta efectiva.
--*************************************************************************
END PROCEDURE;