CREATE PROCEDURE "informix".sp_actparampasomovshis( pempresa CHAR(3), pfecha DATE )
RETURNING CHAR(5);
    
    --- ################################################################################
    --- ##  Nombre:              sp_actparampasomovshis                               ##
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
    DEFINE vpri_dia_mes     DATE;
    DEFINE vultdiamesant    DATE;
    
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
    LET vpri_dia_mes  = '';
    LET vultdiamesant = '';
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparampasomovshis.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparampasomovshis.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT pri_dia_mes
      INTO vpri_dia_mes
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    LET vultdiamesant = vpri_dia_mes - 1 UNITS DAY;
	
     
        SELECT ROUND(COUNT(*)/7)
        INTO vpromedio
        FROM sc_movdia
        WHERE fech_alt = pfecha;
           
        LET vcont = 1;  
        
        WHILE vcont <= 6         
            IF vcont = 1 THEN
                LET vbrinca = vpromedio;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 num_serial
                      INTO vserial
                      FROM sc_movdia
                     WHERE fech_alt = pfecha
                     ORDER BY num_serial
                    
                    LET vparam_serial = vserial;
                    
                    IF vparam_serial is null OR vparam_serial = '' THEN
                        LET vparam_serial = ' ';
                    END IF;
                    
                    UPDATE sc_param
                       SET valor = vparam_serial
                     WHERE empresa = pempresa
                       AND codparam = 'SerialIniPasoMovHis1';
                END FOREACH;
            ELIF vcont = 2 THEN
                LET vbrinca = vpromedio * 2;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 num_serial
                      INTO vserial
                      FROM sc_movdia
                     WHERE fech_alt = pfecha
                     ORDER BY num_serial
                     
                    LET vparam_serial = vserial;
                    
                    IF vparam_serial is null OR vparam_serial = '' THEN
                        LET vparam_serial = ' ';
                    END IF;
                     
                    UPDATE sc_param
                       SET valor = vparam_serial
                     WHERE empresa = pempresa
                       AND codparam = 'SerialIniPasoMovHis2';
                END FOREACH;
            ELIF vcont = 3 THEN
                LET vbrinca = vpromedio * 3;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 num_serial
                      INTO vserial
                      FROM sc_movdia
                     WHERE fech_alt = pfecha
                     ORDER BY num_serial
                     
                    LET vparam_serial = vserial;
                    
                    IF vparam_serial is null OR vparam_serial = '' THEN
                        LET vparam_serial = ' ';
                    END IF;
                     
                    UPDATE sc_param
                       SET valor = vparam_serial
                     WHERE empresa = pempresa
                       AND codparam = 'SerialIniPasoMovHis3';
                END FOREACH;
            ELIF vcont = 4 THEN
                LET vbrinca = vpromedio * 4;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 num_serial
                      INTO vserial
                      FROM sc_movdia
                     WHERE fech_alt = pfecha
                     ORDER BY num_serial
                     
                    LET vparam_serial = vserial;
                    
                    IF vparam_serial is null OR vparam_serial = '' THEN
                        LET vparam_serial = ' ';
                    END IF;
                     
                    UPDATE sc_param
                       SET valor = vparam_serial
                     WHERE empresa = pempresa
                       AND codparam = 'SerialIniPasoMovHis4';
                END FOREACH;
			ELIF vcont = 5 THEN
                LET vbrinca = vpromedio * 5;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 num_serial
                      INTO vserial
                      FROM sc_movdia
                     WHERE fech_alt = pfecha
                     ORDER BY num_serial
                     
                    LET vparam_serial = vserial;
                    
                    IF vparam_serial is null OR vparam_serial = '' THEN
                        LET vparam_serial = ' ';
                    END IF;
                     
                    UPDATE sc_param
                       SET valor = vparam_serial
                     WHERE empresa = pempresa
                       AND codparam = 'SerialIniPasoMovHis5';
                END FOREACH;
			ELIF vcont = 6 THEN
                LET vbrinca = vpromedio * 6;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 num_serial
                      INTO vserial
                      FROM sc_movdia
                     WHERE fech_alt = pfecha
                     ORDER BY num_serial
                     
                    LET vparam_serial = vserial;
                    
                    IF vparam_serial is null OR vparam_serial = '' THEN
                        LET vparam_serial = ' ';
                    END IF;
                     
                    UPDATE sc_param
                       SET valor = vparam_serial
                     WHERE empresa = pempresa
                       AND codparam = 'SerialIniPasoMovHis6';
                END FOREACH;	
            END IF;
            LET vcont = vcont + 1;  
            LET vserial = 0;
            LET vparam_serial = '';
        END WHILE;   
    RETURN vcodret;
    END;
END PROCEDURE;