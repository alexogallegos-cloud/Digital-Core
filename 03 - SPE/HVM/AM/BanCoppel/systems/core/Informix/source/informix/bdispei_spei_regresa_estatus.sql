CREATE PROCEDURE "informix".spei_regresa_estatus( pRegistros INTEGER ) 
RETURNING CHAR(5), INTEGER, INTEGER; 
    
    DEFINE Sql_Err     INTEGER;
    DEFINE Isam_Err    INTEGER;
    DEFINE Desc_Err    CHAR(50);
    DEFINE vCodRet1    CHAR(5);
    DEFINE vCodRet2    CHAR(5);
    DEFINE vCodRet3    CHAR(50);
    DEFINE vContador1  INTEGER;
    DEFINE vContador2  INTEGER;
    DEFINE vContador3  INTEGER;
    DEFINE vComienza   SMALLINT;
    DEFINE vAbierto    CHAR(1);
    DEFINE vcverastreo CHAR(30);
    
    LET Sql_Err	    = 0;
    LET Isam_Err    = 0;
    LET Desc_Err    = '';
    LET vCodRet1    = '000';
    LET vCodRet2    = '';
    LET vCodRet3    = '';  
    LET vContador1  = 0;
    LET vContador2  = 0;
    LET vContador3  = 0;
    LET vComienza   = -1;
    LET vAbierto    = '0';
    LET vcverastreo = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei_regresa_estatus.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vAbierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vcontador1, vcontador3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/spei_regresa_estatus.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD
        SELECT FIRST pRegistros
               vchrclaverastreo
          INTO vcverastreo
          FROM tblpago pago,
               bdicheq:sc_movdia mov
         WHERE pago.chrestatusenvio = 'T'
           AND pago.vchrclaverastreo = mov.referencia
           AND mov.transacc = '0274'
         ORDER BY num_serial
        
        IF vComienza = -1 THEN
            LET vComienza = 0;
        END IF;
        
        BEGIN WORK;
        LET vAbierto = '1';
        
        UPDATE tblpago
           SET chrestatusenvio = 'N'
         WHERE vchrclaverastreo = vcverastreo;
           
        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
            LET vcontador3 = vcontador3 + 1;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;
        
        COMMIT WORK;
        LET vAbierto = '1';
        
        LET vcverastreo = '';
    END FOREACH;
    
    END; 
    
    RETURN vCodRet1, vcontador1, vcontador3;
    
END PROCEDURE;