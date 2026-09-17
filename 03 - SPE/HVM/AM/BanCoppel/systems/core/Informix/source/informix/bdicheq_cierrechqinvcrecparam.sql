CREATE PROCEDURE "informix".cierrechqinvcrecparam(pempresa CHAR(3))
RETURNING CHAR(5);
     
    --- ################################################################################
    --- ##  Nombre:              cierrechqinvcrecparam                                ##
    --- ##  Version:             1.0.1                                                ##
    --- ##  Objetivo:            Programa inicial del cierre diario de captacion      ##
    --- ##  Creado por:                                                               ##
    --- ##  ModIFicado por:      JICS                                                 ##
    --- ##  Ultima Modificacion: Diciembre 2011                                       ##
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
    DEFINE vctamin          CHAR(20);
    DEFINE vctamax          CHAR(20);
    
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
    LET vctamin    = '';
    LET vctamax    = '';
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqinvcrecparam.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqinvcrecparam.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    UPDATE sc_fechas
       SET ind_cierre = '0'
     WHERE empresa = pempresa;
     
    SELECT mae.cuenta
      FROM sc_maechq mae,
           sc_maeinstrucc ins
     WHERE mae.producto = '1100'
       AND mae.status_cta <> '2'
       AND ( mae.fecha_proceso is null OR mae.fecha_proceso = "" OR mae.fecha_proceso = vfecha_hoy )
       AND ins.empresa = mae.empresa
       AND ins.cuenta = mae.cuenta
       AND ins.capint = 'R'
       AND ins.instrucc = '01'
    INTO TEMP tmp_invscrec WITH NO LOG;
    CREATE INDEX idxtmp_invcrec ON tmp_invscrec(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_invscrec;
     
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vctamin, vctamax
      FROM tmp_invscrec
     WHERE cuenta >= '10000000000';
     
    LET vctamin = TRIM(vctamin);
    LET vctamax = TRIM(vctamax);
      
    SELECT ROUND(COUNT(*)/5)
      INTO vpromedio
      FROM tmp_invscrec
     WHERE cuenta BETWEEN vctamin AND vctamax;
       
    LET vcont = 1;  
    
    WHILE vcont <= 5 
        IF vcont = 1 THEN 
            LET vcuenta = vctamin;
               
            UPDATE sc_param
               SET valor = vcuenta
             WHERE empresa = pempresa
               AND codparam = 'CtaIniCieInvCreComp1';
        ELIF vcont = 2 THEN
            LET vbrinca = vpromedio;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 cuenta
                  INTO vcuenta
                  FROM tmp_invscrec
                 WHERE cuenta BETWEEN vctamin AND vctamax
                 ORDER BY cuenta
             
                UPDATE sc_param
                   SET valor = vcuenta
                 WHERE empresa = pempresa
                   AND codparam = 'CtaIniCieInvCreComp2';
            END FOREACH;
        ELIF vcont = 3 THEN
            LET vbrinca = vpromedio * 2;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 cuenta
                  INTO vcuenta
                  FROM tmp_invscrec
                 WHERE cuenta BETWEEN vctamin AND vctamax
                 ORDER BY cuenta
                 
                UPDATE sc_param
                   SET valor = vcuenta
                 WHERE empresa = pempresa
                   AND codparam = 'CtaIniCieInvCreComp3';
            END FOREACH;
        ELIF vcont = 4 THEN
            LET vbrinca = vpromedio * 3;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 cuenta
                  INTO vcuenta
                  FROM tmp_invscrec
                 WHERE cuenta BETWEEN vctamin AND vctamax
                 ORDER BY cuenta
                 
                UPDATE sc_param
                   SET valor = vcuenta
                 WHERE empresa = pempresa
                   AND codparam = 'CtaIniCieInvCreComp4';
            END FOREACH;
        ELIF vcont = 5 THEN
            LET vbrinca = vpromedio * 4;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 cuenta
                  INTO vcuenta
                  FROM tmp_invscrec
                 WHERE cuenta BETWEEN vctamin AND vctamax
                 ORDER BY cuenta
                 
                UPDATE sc_param
                   SET valor = vcuenta
                 WHERE empresa = pempresa
                   AND codparam = 'CtaIniCieInvCreComp5';
            END FOREACH;
        END IF;
        
        LET vcont = vcont + 1;  
        LET vcuenta = '';
    END WHILE;    

    RETURN vcodret;

    END;

END PROCEDURE;