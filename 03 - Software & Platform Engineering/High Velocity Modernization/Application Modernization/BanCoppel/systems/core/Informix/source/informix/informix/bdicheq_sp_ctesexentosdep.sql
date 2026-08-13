CREATE PROCEDURE "informix".sp_ctesexentosdep( pNumCte CHAR(20), pUsuario CHAR(20), pFuncion CHAR(1) )
RETURNING CHAR(5);
       
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE vcCodRet     CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    DEFINE vcValParam   CHAR(60);
    DEFINE vcTrxAbierta CHAR(1);
    DEFINE viExisCte    SMALLINT;
    
    LET viSqlErr     = 0;
    LET viIsamErr    = 0;
    LET vcDescErr    = '';
    LET vcCodRet     = '000';
    LET vcCodRet2    = '';
    LET vcCodRet3    = '';
    LET vcValParam   = '';
    LET vcTrxAbierta = '0';
    LET viExisCte    = 0;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_ctesexentosdep.out";
    --- TRACE ON;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_ctesexentosdep.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            IF vcTrxAbierta = '1' THEN
                ROLLBACK WORK;
                LET vcTrxAbierta = '0';
            END IF;
            RETURN vcCodRet;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pNumCte is null OR pNumCte = '' ) OR ( pUsuario is null OR pUsuario = '' ) OR ( pFuncion is null OR pFuncion = '' ) THEN
        LET vcCodRet = '110';
        RETURN vcCodRet;
    END IF;
    
    IF pFuncion = 'A' THEN
    
        SELECT COUNT(*)
          INTO viExisCte
          FROM sc_exentos_dep_efec
         WHERE num_cte = pNumCte;
         
        IF viExisCte > 0 THEN
            LET vcCodRet = '118';
            RETURN vcCodRet;
        END IF;
        
        BEGIN WORK;
        LET vcTrxAbierta = '1';
    
        INSERT INTO sc_exentos_dep_efec VALUES(pNumCte);
        INSERT INTO sc_exentos_dep_efec_bitacora VALUES(TODAY, pUsuario, 'ALTA', pNumCte);
           
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN        
            COMMIT WORK;
            LET vcTrxAbierta = '0';
        ELSE
            ROLLBACK WORK;
            LET vcTrxAbierta = '0';
        END IF;
        
    ELIF pFuncion = 'B' THEN
    
        SELECT COUNT(*)
          INTO viExisCte
          FROM sc_exentos_dep_efec
         WHERE num_cte = pNumCte;
         
        IF viExisCte = 0 THEN
            LET vcCodRet = '104';
            RETURN vcCodRet;
        END IF;
    
        BEGIN WORK;
        LET vcTrxAbierta = '1';
    
        DELETE FROM sc_exentos_dep_efec
         WHERE num_cte = pNumCte;
         
        INSERT INTO sc_exentos_dep_efec_bitacora VALUES(TODAY, pUsuario, 'BAJA', pNumCte);
           
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN        
            COMMIT WORK;
            LET vcTrxAbierta = '0';
        ELSE
            ROLLBACK WORK;
            LET vcTrxAbierta = '0';
        END IF;
        
    ELSE
    
        LET vcCodRet = '116';
        RETURN vcCodRet;
        
    END IF;
    
    RETURN vcCodRet;

    END;

END PROCEDURE;