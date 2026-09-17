CREATE PROCEDURE "informix".sp_depuradepspei( pEmpresa CHAR(3) ) 
RETURNING CHAR(5); 
    
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vAbierto         CHAR(1);
    DEFINE vFechaHoy        DATE;
    DEFINE vCuenta          CHAR(20);
	
    LET Sql_Err	      = 0;
    LET Isam_Err      = 0;
    LET Desc_Err      = '';
    LET vCodRet1      = '000';
    LET vCodRet2      = '';
    LET vCodRet3      = '';  
    LET vAbierto      = '0';
    LET vFechaHoy     = '';
    LET vCuenta       = '';
    
    BEGIN
    
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_depuradepspei.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vAbierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_depuradepspei.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
     
    FOREACH WITH HOLD
        SELECT UNIQUE cuenta
          INTO vCuenta
          FROM sc_depositospei
         WHERE fecha_hoy < vFechaHoy 
        
        BEGIN WORK;
        LET vAbierto = '1';
             
        INSERT INTO sc_depositospeihist
        SELECT *
          FROM sc_depositospei
         WHERE cuenta = vCuenta
           AND fecha_hoy < vFechaHoy;
           
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            DELETE FROM sc_depositospei
             WHERE cuenta = vCuenta
               AND fecha_hoy < vFechaHoy;
            
            COMMIT WORK;
            LET vAbierto = '0';
        ELSE
            ROLLBACK WORK;
            LET vAbierto = '0';
        END IF;
        
        LET vCuenta = '';
    END FOREACH; 
	    
    END; 
    
    RETURN vCodRet1;
    
END PROCEDURE;