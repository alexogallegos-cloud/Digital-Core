CREATE PROCEDURE "informix".sp_actualiza_saldos( pEmpresa CHAR(3) ) 
RETURNING CHAR(5), INTEGER, INTEGER; 
    
    DEFINE Sql_Err    INTEGER;
    DEFINE Isam_Err   INTEGER;
    DEFINE Desc_Err   CHAR(50);
    DEFINE vCodRet1   CHAR(5);
    DEFINE vCodRet2   CHAR(5);
    DEFINE vCodRet3   CHAR(50);
    DEFINE vContador1 INTEGER;
    DEFINE vContador2 INTEGER;
    DEFINE vContador3 INTEGER;
    DEFINE vComienza  SMALLINT;
    DEFINE vAbierto   CHAR(1);
    DEFINE iCommit    INTEGER;
    DEFINE cCuenta    CHAR(20);
    DEFINE dCapital   DECIMAL(14,2);
    DEFINE dInteres   DECIMAL(14,2);
    DEFINE cEstatus   CHAR(1);
	
    LET Sql_Err	   = 0;
    LET Isam_Err   = 0;
    LET Desc_Err   = '';
    LET vCodRet1   = '000';
    LET vCodRet2   = '';
    LET vCodRet3   = '';  
    LET vContador1 = 0;
    LET vContador2 = 0;
    LET vContador3 = 0;
    LET vComienza  = -1;
    LET vAbierto   = '0';
    LET iCommit    = 500;
    LET cCuenta    = '';
    LET dCapital   = 0.00;
    LET dInteres   = 0.00;
    LET cEstatus   = '';
    
    BEGIN
    
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualiza_saldos.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vAbierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vContador1, vContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualiza_saldos.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD
        SELECT ant.cuenta, ant.capvig27, ant.intprovnp27, ant.statuscta27
          INTO cCuenta, dCapital, dInteres, cEstatus
          FROM sc_sdodiarioc sdo,
               sc_sdodiarioc_2021 ant
         WHERE sdo.cuenta = ant.cuenta
           AND sdo.aniomes = ant.aniomes
           AND sdo.aniomes = '202104'
        
        IF vComienza = -1 THEN
            LET vComienza = 0;
            BEGIN WORK;
            LET vAbierto = '1';
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
        UPDATE sc_sdodiarioc
           SET capvig27 = dCapital,
               intprovnp27 = dInteres,
               statuscta27 = cEstatus
         WHERE cuenta = cCuenta
           AND aniomes = '202104';
        
        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
            LET vcontador2 = vcontador2 + 1;
        END IF;
        
        LET vcontador3 = vcontador3 + 1;
        
        IF vcontador3 >= iCommit THEN
            LET vcontador3 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET cCuenta  = '';
        LET dCapital = 0.00;
        LET dInteres = 0.00;
        LET cEstatus = '';
    END FOREACH;
    
    IF vAbierto = '1' THEN
        COMMIT WORK;
        LET vAbierto = '0';
    END IF;
    
    END; 
    
    RETURN vCodRet1, vContador1, vContador2;
    
END PROCEDURE;