CREATE PROCEDURE "informix".sp_verifica_tel( pNumCte    CHAR(20), 
                                             pTelefono  CHAR(13), 
                                             pTipoTel   SMALLINT,
                                             pStatusTel CHAR(1), 
                                             pSecuencia SMALLINT ) 
    DEFINE cCodRet1     CHAR(5);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr     	INTEGER;
    DEFINE iExisteTel  	INTEGER;
    
    LET cCodRet1    = '000';
    LET iSqlErr	    = 0;
    LET iSamErr    	= 0;
    LET iExisteTel 	= 0;
	
	--- SET DEBUG FILE TO "/tmp/sp_verifica_tel.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
        END IF;
    END EXCEPTION;  
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    SELECT COUNT(*)
      INTO iExisteTel
      FROM si_telefonos
     WHERE numcte = pNumCte
       AND tipo_tel = pTipoTel
       AND secuencia = pSecuencia
       AND telefono = pTelefono
       AND status_tel = pStatusTel; 
    
    IF iExisteTel = 0 THEN
        INSERT INTO si_bitac_telef_inval VALUES
        ( pNumCte, pTipoTel, pSecuencia, pTelefono, pStatusTel, current );
    END IF;    
    
    END;
    
END PROCEDURE;