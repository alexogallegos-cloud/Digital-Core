CREATE PROCEDURE "informix".ivr_desbloq_ctes() 
RETURNING CHAR(5); 
    
    DEFINE Sql_Err      INTEGER;
    DEFINE Isam_Err     INTEGER;
    DEFINE Desc_Err     CHAR(50);
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(50);
    DEFINE vcNumCte     CHAR(20);
    DEFINE vcTarjeta    CHAR(20);
    
    LET Sql_Err	  = 0;
    LET Isam_Err  = 0;
    LET Desc_Err  = '';
    LET vCodRet1  = '000';
    LET vCodRet2  = '';
    LET vCodRet3  = '';  
    LET vcNumCte  = '';
    LET vcTarjeta = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/ivr_desbloq_ctes.err";
        --- TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/ivr_desbloq_ctes.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // DESBLOQUEA CLIENTES BLOQUEADOS POR INTENTOS DE ACCESO FALLIDOS
    FOREACH
        SELECT numcte, num_tarjeta
          INTO vcNumCte, vcTarjeta
          FROM bdinteg:"informix".si_cliente_ivr
         WHERE status_cte = 'B'
         
        UPDATE bdinteg:"informix".si_cliente_ivr
           SET status_cte = 'A',
               numintacce = 0
         WHERE numcte = vcNumCte
           AND num_tarjeta = vcTarjeta;
    
        LET vcNumCte = '';
        LET vcTarjeta = '';
    END FOREACH
    
    END;
    
    RETURN vCodRet1;
    
END PROCEDURE;