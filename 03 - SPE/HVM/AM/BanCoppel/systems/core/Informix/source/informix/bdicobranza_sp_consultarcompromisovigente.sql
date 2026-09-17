CREATE PROCEDURE "informix".sp_consultarcompromisovigente(pEmpresa char(3), pNumCuenta char(20))

    RETURNING CHAR(5), CHAR(1);

    --08/04/2009
    --Creado por:
    --Lorenzo Ibarra Garcia
    --Verifica que el numero de cuenta no tenga un compromiso o acuerdo activo

    DEFINE vCodRet        CHAR(5);
    DEFINE iSqlErr        INTEGER;

    DEFINE vActivo        CHAR(1);

    LET vCodRet = '000';
    LET iSqlErr = 0;
    LET vActivo = '1';

    --Set debug file to '/tmp/Lorenzo/sp_ComPacVigente.out';
    --trace on;

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET vCodRet = iSqlErr;
                RETURN vCodRet, vActivo;
            END IF;
        END EXCEPTION;
        --verificar si los parametros se pasaron correctamente
        IF TRIM(pEmpresa) = '' OR pEmpresa IS NULL THEN
            LET vCodRet = '001';
            LET vActivo = '0';
            RETURN vCodRet, vActivo;
        END IF;
        IF TRIM(pNumCuenta) = '' OR pNumCuenta IS NULL THEN
            LET vCodRet = '002';
            LET vActivo = '0';
            RETURN vCodRet, vActivo;
        END IF;
        --obtener el campo activo para saber si se encuentra activo un compromiso o acuerdo para esa cuenta
        set isolation to dirty read; 
        SELECT {+INDEX(bdicobranza:cb_compac idx_compac1)} limit 1 activo 
        INTO vActivo
        FROM bdicobranza:cb_compac 
        WHERE empresa = pEmpresa 
        AND numcuenta = pNumCuenta;
        
        IF vActivo IS NULL THEN
            LET vActivo = '0';
        END IF;
        
        RETURN vCodRet, vActivo;
    END;
END PROCEDURE;