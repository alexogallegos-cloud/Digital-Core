CREATE PROCEDURE "informix".sp_compcancelactasinactivas( pEmpresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;
      
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vComienza        INTEGER;
    DEFINE vEnTransacc      SMALLINT;
    DEFINE vContador1       INTEGER;
    DEFINE vCuenta          CHAR(20);
    DEFINE vnum_tarjeta     CHAR(16);
    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '000';
    LET vCodRet2     = '000';
    LET vCodRet3     = '';
    LET vComienza    = -1;
    LET vEnTransacc  = 0;
    LET vContador1   = 0;
    LET vCuenta      = ''; 
    LET vnum_tarjeta = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_compcancelactasinactivas.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_compcancelactasinactivas.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD
        SELECT cuenta
          INTO vcuenta
          FROM sc_ctasinactinforcanc
          
        IF vComienza = -1 THEN
            LET vComienza = 0;
        END IF;    
        
        BEGIN WORK;
        LET vEnTransacc = 1;
        
        UPDATE bdicheq:"informix".sc_maechq
           SET motivo = '13'
         WHERE empresa = pEmpresa
           AND cuenta = vCuenta;
           
        FOREACH
            SELECT num_tarjeta
              INTO vnum_tarjeta
              FROM bdicheq:"informix".sc_tarjeta
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta
			   AND status_tar = 'A'
               AND secuencia > 0
               
            UPDATE bdicheq:"informix".sc_tarjeta
               SET status_tar = 'C'
             WHERE empresa = pEmpresa
               AND num_tarjeta = vnum_tarjeta;
               
            UPDATE intercard:"informix".tarjeta
               SET codstatustarjeta = 'CAN'
             WHERE numtarjeta = vnum_tarjeta;
        END FOREACH
        
        LET vContador1 = vContador1 + 1;
        
        COMMIT WORK;
        LET vEnTransacc = 0;
        
    END FOREACH;
    
    END;
    
    RETURN vCodRet1, vCodRet2, vCodRet3, vContador1;
    
END PROCEDURE;