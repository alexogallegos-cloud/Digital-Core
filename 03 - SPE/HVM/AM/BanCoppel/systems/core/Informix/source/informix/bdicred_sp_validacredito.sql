CREATE PROCEDURE "informix".sp_validacredito(pEmpresa CHAR(3), pNumCuenta CHAR(20))

RETURNING CHAR(6);

--30/10/2008
--Abraham Ayala Aguilar
--Valida que exista el registro del cliente en la tabla de credito.

--DEFINICION DE VARIABLES--
    DEFINE iSqlErr INTEGER;
    DEFINE vCodRet CHAR(6);
    
    --SET DEBUG FILE TO '/tmp/sp_validacliente.out';
    --TRACE ON;
    
    
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET vCodRet = iSqlErr;
                RETURN vCodRet;
            END IF;
        END EXCEPTION;
        
        
--INICIALIZACION DE VARIABLES--
        LET vCodRet = '000000';
        
        IF pEmpresa IS NOT NULL AND pNumCuenta IS NOT NULL THEN
            
            IF EXISTS (SELECT num_credito FROM bdicred:sd_maecred WHERE empresa = pEmpresa AND num_credito = pNumCuenta) THEN
            
                RETURN vCodRet;
                
            ELSE
            
                LET vCodRet = '000001';
                RETURN vCodRet;
                
            END IF;
            
        ELSE
        
            LET vCodRet = '000999';
            RETURN vCodRet;
            
        END IF;
    END;
END PROCEDURE;