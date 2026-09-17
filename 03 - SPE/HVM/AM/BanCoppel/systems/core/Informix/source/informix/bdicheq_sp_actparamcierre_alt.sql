CREATE PROCEDURE "informix".sp_actparamcierre_alt(pempresa CHAR(3))
RETURNING CHAR(5);
     
    --- #######################################################################################
    --- ##  Nombre:              sp_actparamcierre_alt                                       ##
    --- ##  Version:             1.0.1                                                       ##
    --- ##  Objetivo:            Programa inicial del cierre diario de captacion X REMANENTE ##
    --- ##  Creado por:                                                                      ##
    --- ##  ModIFicado por:      JICS                                                        ##
    --- ##  Ultima Modificacion: Diciembre 2011                                              ##
    --- #######################################################################################

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
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparamcierre_alt.err";
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
     
    SELECT ROUND(COUNT(*)/6)
      INTO vpromedio
      FROM sc_maechq
     WHERE producto NOT IN('1100','1900','2200')
       AND status_cta NOT IN("2","6","7","8")
       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy);
       
    LET vcont = 1;  
    
    WHILE vcont <= 5         
        IF vcont = 1 THEN
            LET vbrinca = vpromedio;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 cuenta
                  INTO vcuenta
                  FROM sc_maechq
                 WHERE producto NOT IN('1100','1900','2200')
                   AND status_cta not in("2","6","7","8")
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
                 WHERE producto NOT IN('1100','1900','2200')
                   AND status_cta not in("2","6","7","8")
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
                 WHERE producto NOT IN('1100','1900','2200')
                   AND status_cta not in("2","6","7","8")
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
                 WHERE producto NOT IN('1100','1900','2200')
                   AND status_cta not in("2","6","7","8")
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
                 WHERE producto NOT IN('1100','1900','2200')
                   AND status_cta not in("2","6","7","8")
                   AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                 ORDER BY cuenta
                 
                UPDATE sc_param
                   SET valor = vcuenta
                 WHERE empresa = pempresa
                   AND codparam = 'CtaIniCierreCapComp5';
            END FOREACH;
        END IF;
        
        LET vcont = vcont + 1;  
        LET vcuenta = '';
    END WHILE;    

    RETURN vcodret;

    END;

END PROCEDURE;