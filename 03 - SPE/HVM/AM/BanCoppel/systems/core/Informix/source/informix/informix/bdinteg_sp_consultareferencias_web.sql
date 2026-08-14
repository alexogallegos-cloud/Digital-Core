CREATE PROCEDURE "informix".sp_consultareferencias_web (pEmpresa char(3), pNumeroCliente char(20))
        returning char(5), integer, integer;

--Creado: Rodolfo Tortolero Varela
--Fecha: 05/03/2009
--Consulta las secuencias maximas del cliente en la tabla si_refclientes

--Se Definen Variables
DEFINE iSqlErr INTEGER;
DEFINE vcodret char(5);
DEFINE iSecuencia1 integer;
DEFINE iSecuencia2 integer;

--Se Inicializan Variables
LET vcodret = "00000";
LET iSecuencia1  = 0;
LET iSecuencia2  = 0;

    BEGIN
            ON EXCEPTION
                    SET iSqlErr
                    IF iSqlErr <> 0 THEN
                            LET vCodRet = iSqlErr;
                            RETURN  vcodret, iSecuencia1, iSecuencia2;
                    END IF;
            END EXCEPTION;

            SELECT  MAX(secuencia)  INTO iSecuencia1
            FROM si_refclientes
            WHERE empresa = pEmpresa AND numcte = pNumeroCliente;

            SELECT  MAX(secuencia)  INTO iSecuencia2
            FROM si_refclientes
            WHERE empresa = pEmpresa AND numcte = pNumeroCliente AND secuencia < iSecuencia1;

            IF iSecuencia1 <> 0 OR iSecuencia1 IS NOT NULL THEN
                    IF iSecuencia2 <> 0  OR iSecuencia2 IS NOT NULL THEN
                            RETURN vcodret, iSecuencia1, iSecuencia2;
                    ELSE
                            LET vcodret = '00001'; --No tiene NÃºmero de Secuencia
                            RETURN vcodret, iSecuencia1, iSecuencia2;
                    END IF;
            ELSE
                    LET vcodret = '00001'; --No tiene NÃºmero de Secuencia
                    RETURN vcodret, iSecuencia1, iSecuencia2;
            END IF;
    END;
END PROCEDURE;