CREATE PROCEDURE "informix".sp_actparamtraspmovefec( pFechaIni DATE, pFechaFin DATE )
RETURNING CHAR(5);
    
    --- ################################################################################
    --- ##  Nombre:              sp_actparamtraspmovefec                               ##
    --- ##  Version:             1.0.1                                                ##
    --- ##  Objetivo:            Programa del paso de regs de movdia a movhis         ##
    --- ##  Creado por:          JICS                                                 ##
    --- ##  ModIFicado por:      JICS                                                 ##
    --- ##  Ultima Modificacion: Diciembre 2012                                       ##
    --- ################################################################################

    DEFINE vcodret          CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE vsqlerr          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE error_info       CHAR(50);
    DEFINE vpromedio        INTEGER;
    DEFINE vcont            SMALLINT;
    DEFINE vbrinca          INTEGER;
    DEFINE vserial          INTEGER;
    DEFINE vparam_serial    CHAR(60);
    
    LET vcodret       = "000";
    LET vcodret2      = "000";
    LET vcodret3      = " ";
    LET vsqlerr       = 0;
    LET isam_err      = 0;
    LET error_info    = '';
    LET vpromedio     = 0;
    LET vcont         = 0;
    LET vbrinca       = 0;
    LET vserial       = 0;
    LET vparam_serial = '';
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparamtraspmovefec.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparamtraspmovefec.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT ROUND(COUNT(*)/3)
      INTO vpromedio
      FROM sl_movefec
     WHERE tipo_cta IN('D','C')
       AND fecha_mov BETWEEN pFechaIni AND pFechaFin;
       
    LET vcont = 1;  
    
    WHILE vcont <= 2         
        IF vcont = 1 THEN
            LET vbrinca = vpromedio;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM sl_movefec
                 WHERE tipo_cta IN('D','C')
                   AND fecha_mov BETWEEN pFechaIni AND pFechaFin
                 ORDER BY num_serial
                
                LET vparam_serial = vserial;
                
                IF vparam_serial is null OR vparam_serial = '' THEN
                    LET vparam_serial = ' ';
                END IF;
                
                UPDATE sl_parametros
                   SET valor = vparam_serial
                 WHERE cve_param = 'TrasMov1';
            END FOREACH;
        ELIF vcont = 2 THEN
            LET vbrinca = vpromedio * 2;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM sl_movefec
                 WHERE tipo_cta IN('D','C')
                   AND fecha_mov BETWEEN pFechaIni AND pFechaFin
                 ORDER BY num_serial
                 
                LET vparam_serial = vserial;
                
                IF vparam_serial is null OR vparam_serial = '' THEN
                    LET vparam_serial = ' ';
                END IF;
                 
                UPDATE sl_parametros
                   SET valor = vparam_serial
                 WHERE cve_param = 'TrasMov2';
            END FOREACH;
        END IF;
        LET vcont = vcont + 1;  
        LET vserial = 0;
        LET vparam_serial = '';
    END WHILE;    

    RETURN vcodret;

    END;

END PROCEDURE;