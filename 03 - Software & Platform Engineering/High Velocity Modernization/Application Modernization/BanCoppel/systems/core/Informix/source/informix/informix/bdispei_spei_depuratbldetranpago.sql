CREATE PROCEDURE "informix".spei_depuratbldetranpago( pfecha_hoy DATE ) 
RETURNING CHAR(5); 
    
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vContador1       INTEGER;
    DEFINE vContador2       INTEGER;
    DEFINE vContador3       INTEGER;
    DEFINE vComienza        SMALLINT;
    DEFINE vAbierto         CHAR(1);
    DEFINE vnum_serial      INTEGER;
    DEFINE vfolio_suc       CHAR(16);
    DEFINE vsucursal        CHAR(4);
    DEFINE vusuario         CHAR(8);
    DEFINE vfech_alt        DATE;
    DEFINE vtransacc        CHAR(4);
    DEFINE vempresa         CHAR(3);
    DEFINE vcuenta          CHAR(20);
    DEFINE vmonto_tot       MONEY(14,2);
    DEFINE vclave_rastreo   CHAR(30);
    DEFINE vtransaccion     SMALLINT;
    DEFINE iCommit          INTEGER;
	
    LET Sql_Err	       = 0;
    LET Isam_Err       = 0;
    LET Desc_Err       = '';
    LET vCodRet1       = '000';
    LET vCodRet2       = '';
    LET vCodRet3       = '';  
    LET vContador1     = 0;
    LET vContador2     = 0;
    LET vContador3     = 0;
    LET vComienza      = -1;
    LET vAbierto       = '0';
    LET vnum_serial    = 0;
    LET vfolio_suc     = '';
    LET vsucursal      = '';
    LET vusuario       = '';
    LET vfech_alt      = '';
    LET vtransacc      = '';
    LET vempresa       = '';
    LET vcuenta        = '';
    LET vmonto_tot     = 0.00;
    LET vclave_rastreo = '';
    LET vtransaccion   = 0;
    LET iCommit        = 10;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei_depuratbldetranpago.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/spei_depuratbldetranpago.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD
        SELECT {+INDEX(tbldetranpago idx_detranpago2)}
               num_serial, folio_suc, sucursal, usuario, fech_alt, transacc, empresa, cuenta, monto_tot, clave_rastreo
          INTO vnum_serial, vfolio_suc, vsucursal, vusuario, vfech_alt, vtransacc, vempresa, vcuenta, vmonto_tot, vclave_rastreo
          FROM tbldetranpago 
         WHERE clave_rastreo = clave_rastreo
           AND fech_alt <= pfecha_hoy
        
        IF vComienza = -1 THEN
            LET vComienza = 0;
            BEGIN WORK;
            LET vAbierto = '1';
        END IF;
        
        INSERT INTO tblhistdetranpago
        ( num_serial, folio_suc, sucursal, usuario, fech_alt, transacc, empresa, cuenta, monto_tot, clave_rastreo )
        VALUES
        ( vnum_serial, vfolio_suc, vsucursal, vusuario, vfech_alt, vtransacc, vempresa, vcuenta, vmonto_tot, vclave_rastreo );
          
        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
            DELETE {+INDEX(tbldetranpago idx_detranpago2)}
              FROM tbldetranpago
             WHERE clave_rastreo = vclave_rastreo
               AND fech_alt <= pfecha_hoy
               AND num_serial = vnum_serial;
               
            IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                LET vcontador3 = vcontador3 + 1;
            END IF;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;
        
        IF vcontador2 >= iCommit THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vnum_serial = 0;
        LET vclave_rastreo = '';
    END FOREACH;
    
    IF vAbierto = '1' THEN
        COMMIT WORK;
        LET vAbierto = '0';
    END IF;
    
    END; 
    
    RETURN vCodRet1;
    
END PROCEDURE;