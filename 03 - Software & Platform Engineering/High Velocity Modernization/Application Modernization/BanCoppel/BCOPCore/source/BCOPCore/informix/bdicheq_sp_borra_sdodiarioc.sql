CREATE PROCEDURE "informix".sp_borra_sdodiarioc( pAnioMes CHAR(6) ) 
RETURNING CHAR(5), CHAR(50), INTEGER, INTEGER; 
    
    DEFINE Sql_Err      INTEGER;
    DEFINE Isam_Err     INTEGER;
    DEFINE Desc_Err     CHAR(50);
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(50);
    DEFINE vComienza    SMALLINT;
    DEFINE vContador1   INTEGER;
    DEFINE vContador2   INTEGER;
    DEFINE vContador3   INTEGER;
    DEFINE vAbierto     CHAR(1);
    DEFINE vCuenta      CHAR(20);
	
    LET Sql_Err	   = 0;
    LET Isam_Err   = 0;
    LET Desc_Err   = '';
    LET vCodRet1   = '000';
    LET vCodRet2   = '000';
    LET vCodRet3   = 'PROCESO FINALIZADO CORRECTAMENTE';
    LET vComienza  = -1;
    LET vContador1 = 0;
    LET vContador2 = 0;
    LET vContador3 = 0;
    LET vAbierto   = '0';
    LET vCuenta    = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_borra_sdodiarioc.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vAbierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet3, vContador1, vContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_borra_sdodiarioc.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // REALIZA LIBERACION DE MONTOS RETENIDOS 
    FOREACH WITH HOLD
        SELECT {+INDEX(sc_sdodiarioc isdodiario_aniomes)}
               cuenta
          INTO vCuenta
          FROM sc_sdodiarioc
         WHERE aniomes = pAnioMes 
           
        IF vComienza = -1 THEN
            LET vComienza = 0;
            BEGIN WORK;
            LET vAbierto = '1';
        END IF;
			 
		DELETE FROM sc_sdodiarioc
         WHERE aniomes = pAnioMes 
           AND cuenta = vCuenta;
           
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            LET vcontador2 = vcontador2 + 1;
        END IF;
        
        LET vContador1 = vContador1 + 1;
        LET vContador3 = vContador3 + 1;
           
        IF vContador3 >= 1000 THEN
            LET vContador3 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
           
        LET vCuenta = '';
    END FOREACH;
    
    IF vAbierto = '1' THEN
        LET vAbierto = '0';
        COMMIT WORK;
    END IF;
    	    
    END; 
    
    RETURN vCodRet1, vCodRet3, vContador1, vContador2;
    
END PROCEDURE;