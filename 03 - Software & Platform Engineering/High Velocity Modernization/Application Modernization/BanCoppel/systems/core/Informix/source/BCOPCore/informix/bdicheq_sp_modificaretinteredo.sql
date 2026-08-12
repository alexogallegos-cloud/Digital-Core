CREATE PROCEDURE "informix".sp_modificaretinteredo( pParametro CHAR(20), pValor CHAR(60), pUsuario CHAR(20) )
RETURNING CHAR(5);
       
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE vcCodRet     CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    DEFINE vcValParam   CHAR(60);
    DEFINE vcTrxAbierta CHAR(1);
    
    LET viSqlErr     = 0;
    LET viIsamErr    = 0;
    LET vcDescErr    = '';
    LET vcCodRet     = '000';
    LET vcCodRet2    = '';
    LET vcCodRet3    = '';
    LET vcValParam   = '';
    LET vcTrxAbierta = '0';
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_modificaretinteredo.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_modificaretinteredo.err";
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
    
    IF ( pParametro is null OR pParametro = '' ) OR ( pUsuario is null OR pUsuario = '' ) THEN
        LET vcCodRet = '110';
        LET vcValParam  = '';
        RETURN vcCodRet;
    END IF;
    
    IF ( pValor is not null AND pValor != '' ) THEN
        SELECT TRIM(valor)
          INTO vcValParam
          FROM sc_param
         WHERE empresa = '001'
           AND codparam = pParametro;
           
        IF vcValParam is null THEN
            LET vcCodRet = '110';
            RETURN vcCodRet;
        END IF;
        
        BEGIN WORK;
        LET vcTrxAbierta = '1';
        
        UPDATE sc_param
           SET valor = TRIM(pValor)
         WHERE empresa = '001'
           AND codparam = pParametro;
           
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            INSERT INTO sc_retenido_interedo(fecha_mod, usuario_mod, retenido_anterior, retenido_actual)
            VALUES(today, pUsuario, vcValParam, TRIM(pValor));
            
            IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
                COMMIT WORK;
                LET vcTrxAbierta = '0';
            ELSE
                ROLLBACK WORK;
                LET vcTrxAbierta = '0';
            END IF;
        ELSE
            ROLLBACK WORK;
            LET vcTrxAbierta = '0';
        END IF;
    ELSE
        LET vcCodRet = '000';
    END IF;
    
    RETURN vcCodRet;

    END;

END PROCEDURE;