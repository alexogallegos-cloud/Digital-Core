CREATE PROCEDURE "informix".sp_valrevtelefonos( pNumCte CHAR(20) ) 
RETURNING CHAR(5), CHAR(1), CHAR(1); 
    
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    
    DEFINE vRevision    INTEGER;
    DEFINE vFechaHoy    DATE;
    DEFINE vFechaIniMes DATE;
    DEFINE vIndTelefono CHAR(1);
    DEFINE vIndCorreo   CHAR(1);
    DEFINE vTelefono1   CHAR(13);
    DEFINE vTelefono2   CHAR(13);
    DEFINE vTelefono3   CHAR(13);
    DEFINE vTelefono4   CHAR(13);
    DEFINE vExisteCte   SMALLINT;
    
    LET vcodret1     = '000';
    LET vcodret2     = '';
    LET vcodret3     = '';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    
    LET vRevision    = 0;
    LET vFechaHoy    = '';
    LET vFechaIniMes = '';
    LET vIndTelefono = '0';
    LET vIndCorreo   = '0';
    LET vTelefono1   = '';
    LET vTelefono2   = '';
    LET vTelefono3   = '';
    LET vTelefono4   = '';
    LET vExisteCte   = 0;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_valrevtelefonos.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vIndTelefono, vIndCorreo;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_valrevtelefonos.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA ( DATOS INSUFICIENTES )
    IF ( pNumCte is null OR pNumCte = '' ) THEN
        LET vcodret1 = '110'; 
        RETURN vcodret1, vIndTelefono, vIndCorreo;
    END IF;
    
    SELECT fecha_hoy, pri_dia_mes
      INTO vFechaHoy, vFechaIniMes
      FROM si_fechas
     WHERE empresa = '001';
     
    SELECT valor::INTEGER
      INTO vRevision
      FROM si_param
     WHERE cod_param = 140;
     
    IF vRevision is null OR vRevision = 0 THEN
        
        LET vIndTelefono = '0';
        LET vIndCorreo   = '0';
        RETURN vcodret1, vIndTelefono, vIndCorreo;
        
    ELIF vRevision = 1 THEN
        
        SELECT COUNT(*)
          INTO vExisteCte
          FROM si_bitacora_tel
         WHERE numcte = pNumCte;
         
        IF vExisteCte = 0 THEN
            INSERT INTO si_bitacora_tel( numcte, ind_telefono, ind_correo, canal, sucursal, user_insert, fecha_oper )
            VALUES( pNumCte, '1', '1', 0, '0000', 'informix', CURRENT );
        ELSE
            SELECT COUNT(*)
              INTO vExisteCte
              FROM si_bitacora_tel
             WHERE numcte = pNumCte
               --- AND fecha_oper::date >= vFechaIniMes
               AND fecha_oper::date >= '01/01/'||YEAR(vFechaHoy)
               AND ( ind_telefono = '0' OR ind_correo = '0' );
               
            IF vExisteCte > 0 THEN
                LET vIndTelefono = '0';
                LET vIndCorreo   = '0';
                RETURN vcodret1, vIndTelefono, vIndCorreo;
            END IF;
        END IF;
    
        SELECT NVL(telefono, '')
          INTO vTelefono1
          FROM si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 1;
           
        SELECT NVL(telefono, '')
          INTO vTelefono2
          FROM si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 2;
           
        SELECT NVL(telefono, '')
          INTO vTelefono3
          FROM si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 3;
           
        SELECT NVL(telefono, '')
          INTO vTelefono4
          FROM si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 4;
        
        IF   ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '01' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '1' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '1' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '1' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '1' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '02' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '2' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '2' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '2' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '2' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '03' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '3' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '3' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '3' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '3' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '04' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '4' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '4' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '4' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '4' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '05' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '5' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '5' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '5' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '5' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '06' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '6' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '6' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '6' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '6' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '07' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '7' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '7' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '7' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '7' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '08' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '8' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '8' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '8' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '8' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '09' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '9' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '9' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '9' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '9' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '10' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '0' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '0' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '0' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '0' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') IN('11','12') ) AND ( (vTelefono1 is null OR vTelefono1 = '') OR
                                                                      (vTelefono2 is null OR vTelefono2 = '') OR
                                                                      (vTelefono3 is null OR vTelefono3 = '') OR
                                                                      (vTelefono4 is null OR vTelefono4 = '') ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        END IF;
        
        UPDATE si_bitacora_tel
           SET ind_correo   = '0',
               ind_telefono = '0',
               fecha_oper   = CURRENT
         WHERE numcte = pNumCte;
    
    ELIF vRevision = 2 THEN
    
        SELECT COUNT(*)
          INTO vExisteCte
          FROM si_bitacora_tel
         WHERE numcte = pNumCte;
         
        IF vExisteCte = 0 THEN
            INSERT INTO si_bitacora_tel( numcte, ind_telefono, ind_correo, canal, sucursal, user_insert, fecha_oper )
            VALUES( pNumCte, '1', '1', 0, '0000', 'informix', CURRENT );
            
            LET vIndTelefono = '1';
            LET vIndCorreo   = '1';
        ELSE
            SELECT COUNT(*)
              INTO vExisteCte
              FROM si_bitacora_tel
             WHERE numcte = pNumCte
               --- AND fecha_oper::date >= vFechaIniMes
               AND fecha_oper::date >= '01/01/'||YEAR(vFechaHoy)
               AND ( ind_telefono = '0' OR ind_correo = '0' );
               
            IF vExisteCte > 0 THEN
                LET vIndTelefono = '0';
                LET vIndCorreo   = '0';
                RETURN vcodret1, vIndTelefono, vIndCorreo;
            ELSE
                LET vIndTelefono = '1';
                LET vIndCorreo   = '1';
            END IF;
        END IF;
        
        UPDATE si_bitacora_tel
           SET ind_correo   = '0',
               ind_telefono = '0',
               fecha_oper   = CURRENT
         WHERE numcte = pNumCte;
    
    END IF;
    
    END;
    
    RETURN vcodret1, vIndTelefono, vIndCorreo;
    
END PROCEDURE;