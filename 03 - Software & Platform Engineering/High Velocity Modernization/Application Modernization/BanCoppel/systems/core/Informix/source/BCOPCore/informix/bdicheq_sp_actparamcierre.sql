CREATE PROCEDURE "informix".sp_actparamcierre(pempresa CHAR(3)) 
RETURNING CHAR(5); 
     
    --- ################################################################################
    --- ##  Nombre:              sp_actparamcierre                                    ##
    --- ##  Version:             1.0.1                                                ##
    --- ##  Objetivo:            Programa inicial del cierre diario de captacion      ##
    --- ##  Creado por:                                                               ##
    --- ##  ModIficado por:      JICS                                                 ##
    --- ##  Ultima Modificacion: Julio 2013                                           ##
    --- ################################################################################
    
    DEFINE vcodret          CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE vsqlerr          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE error_info       CHAR(50);
    DEFINE vfecha_hoy       DATE;
    DEFINE vpromedio        INTEGER;
    DEFINE vcont            SMALLINT;
    DEFINE vbrinca          INTEGER;
    DEFINE vcuenta          CHAR(20);
    DEFINE vdia             SMALLINT;
    
    LET vcodret    = "000";
    LET vcodret2   = "000";
    LET vcodret3   = " ";
    LET vsqlerr    = 0;
    LET isam_err   = 0;
    LET error_info = '';
    LET vfecha_hoy = ' ';    
    LET vpromedio  = 0;
    LET vcont      = 0;
    LET vbrinca    = 0;
    LET vcuenta    = '';
    LET vdia       = -1;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparamcierre.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            RETURN vcodret;
        END IF;
    END EXCEPTION;
    
    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparamcierre.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    LET vdia = WEEKDAY(vfecha_hoy);
    
    IF vdia = 0 THEN
        SELECT ROUND(COUNT(*)/14)
          INTO vpromedio
          FROM sc_maechq
         WHERE producto = '2000'
           AND status_cta NOT IN("2","7","8")
           AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy);
           
        LET vcont = 1;  
        
        WHILE vcont <= 13         
            IF vcont = 1 THEN
                LET vbrinca = vpromedio;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                 
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCierreCapComp1';
                END FOREACH;
            ELIF vcont = 2 THEN
                LET vbrinca = vpromedio * 2;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCierreCapComp2';
                END FOREACH;
            ELIF vcont = 3 THEN
                LET vbrinca = vpromedio * 3;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCierreCapComp3';
                END FOREACH;
            ELIF vcont = 4 THEN
                LET vbrinca = vpromedio * 4;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCierreCapComp4';
                END FOREACH;
            ELIF vcont = 5 THEN
                LET vbrinca = vpromedio * 5;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCierreCapComp5';
                END FOREACH;
            ELIF vcont = 6 THEN
                LET vbrinca = vpromedio * 6;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCierreCapComp6';
                END FOREACH;
            ELIF vcont = 7 THEN
                LET vbrinca = vpromedio * 7;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCierreCapComp7';
                END FOREACH;
            ELIF vcont = 8 THEN
                LET vbrinca = vpromedio * 8;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCierreCapComp8';
                END FOREACH;
            ELIF vcont = 9 THEN
                LET vbrinca = vpromedio * 9;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCierreCapComp9';
                END FOREACH;
            ELIF vcont = 10 THEN
                LET vbrinca = vpromedio * 10;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCiereCapComp10';
                END FOREACH;
            ELIF vcont = 11 THEN
                LET vbrinca = vpromedio * 11;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCiereCapComp11';
                END FOREACH;
            ELIF vcont = 12 THEN
                LET vbrinca = vpromedio * 12;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCiereCapComp12';
                END FOREACH;
            ELIF vcont = 13 THEN
                LET vbrinca = vpromedio * 13;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCiereCapComp13';
                END FOREACH;
            END IF;
            
            LET vcont = vcont + 1;  
            LET vcuenta = '';
        END WHILE;    
    END IF;
    
    RETURN vcodret;
    
    END;
    
END PROCEDURE;