CREATE PROCEDURE "informix".sp_consultaprodactivossucur(p_sEmpresa CHAR(3), p_sSucursal CHAR(4))
    RETURNING       CHAR(6) AS retorno,
                    CHAR(5) AS producto;

    DEFINE iSqlErr          INTEGER;
    DEFINE cCodRet    		CHAR(5);
    DEFINE cNumProd         CHAR(4);
    

    LET cCodRet = '00000';
    LET cNumProd = "0000";

    BEGIN
        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
					RETURN cCodRet, cNumProd;
                END IF;
        END EXCEPTION;

		--set debug file to "/tmp/sp_consultaprodactivossucur.out";
		--trace on;
        
        IF p_sSucursal = "" THEN
            LET cCodRet = "00001";
        END IF;

        --DEBE PROPORCIONARSE LA EMPRESA
        FOREACH
            SELECT num_producto INTO cNumProd FROM bdinteg:si_prod_sucursal WHERE empresa = p_sEmpresa AND sucursal = p_sSucursal
            
            RETURN cCodRet, cNumProd WITH RESUME;
        END FOREACH
        
        IF cCodRet <> "00000" THEN
            RETURN cCodRet, cNumProd;
        END IF;
        
    END;
END PROCEDURE;