CREATE PROCEDURE "informix".sp_actparampasecheqhis(pempresa CHAR(3), pfecha DATE)
RETURNING CHAR(5);
    
    --- ################################################################################
    --- ##  Nombre:              sp_actparampasecheqhis                                  ##
    --- ##  Version:             1.0.1                                                ##
    --- ##  Objetivo:            Programa del pase contable de captacion              ##
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
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparampasecheqhis.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparampasecheqhis.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT ROUND(COUNT(*)/6)
      INTO vpromedio
      FROM sc_movhis
     WHERE fech_alt = pfecha;
       
    LET vcont = 1;  
    
    WHILE vcont <= 5         
        IF vcont = 1 THEN
            LET vbrinca = vpromedio;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM sc_movhis
                 WHERE fech_alt = pfecha
                 ORDER BY num_serial
                
                LET vparam_serial = vserial;
                
                UPDATE sc_param
                   SET valor = vparam_serial
                 WHERE empresa = pempresa
                   AND codparam = 'SerialIniPaseChqCom1';
            END FOREACH;
        ELIF vcont = 2 THEN
            LET vbrinca = vpromedio * 2;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM sc_movhis
                 WHERE fech_alt = pfecha
                 ORDER BY num_serial
                 
                LET vparam_serial = vserial;
                 
                UPDATE sc_param
                   SET valor = vparam_serial
                 WHERE empresa = pempresa
                   AND codparam = 'SerialIniPaseChqCom2';
            END FOREACH;
        ELIF vcont = 3 THEN
            LET vbrinca = vpromedio * 3;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM sc_movhis
                 WHERE fech_alt = pfecha
                 ORDER BY num_serial
                 
                LET vparam_serial = vserial;
                 
                UPDATE sc_param
                   SET valor = vparam_serial
                 WHERE empresa = pempresa
                   AND codparam = 'SerialIniPaseChqCom3';
            END FOREACH;
        ELIF vcont = 4 THEN
            LET vbrinca = vpromedio * 4;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM sc_movhis
                 WHERE fech_alt = pfecha
                 ORDER BY num_serial
                 
                LET vparam_serial = vserial;
                 
                UPDATE sc_param
                   SET valor = vparam_serial
                 WHERE empresa = pempresa
                   AND codparam = 'SerialIniPaseChqCom4';
            END FOREACH;
        ELIF vcont = 5 THEN
            LET vbrinca = vpromedio * 5;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM sc_movhis
                 WHERE fech_alt = pfecha
                 ORDER BY num_serial
                 
                LET vparam_serial = vserial;
                 
                UPDATE sc_param
                   SET valor = vparam_serial
                 WHERE empresa = pempresa
                   AND codparam = 'SerialIniPaseChqCom5';
            END FOREACH;
        END IF;
        LET vcont = vcont + 1;  
        LET vserial = 0;
        LET vparam_serial = '';
    END WHILE;    

    RETURN vcodret;

    END;

END PROCEDURE;