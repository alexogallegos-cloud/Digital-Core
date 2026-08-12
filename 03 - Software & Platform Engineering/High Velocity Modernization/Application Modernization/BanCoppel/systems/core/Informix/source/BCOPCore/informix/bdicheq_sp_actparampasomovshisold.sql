CREATE PROCEDURE "informix".sp_actparampasomovshisold( pempresa CHAR(3), pfecha DATE )
RETURNING CHAR(5);
    
    --- ################################################################################
    --- ##  Nombre:              sp_actparampasomovshisold                            ##
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
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparampasomovshisold.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/ifxsif01/ilopez/OPTIMIZACION_CAPTACION/BLOQUE5/sp_actparampasomovshisold.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT {+INDEX(sc_movhis idx_movhisnew6)}
           ROUND(COUNT(*)/10)
      INTO vpromedio----1214579
      FROM sc_movhis
     WHERE fech_alt = pfecha;    LET vcont = 1;  
    
    WHILE vcont <= 9         
        IF vcont = 1 THEN
            LET vbrinca = vpromedio;            
			FOREACH
                SELECT {+INDEX(sc_movhis idx_movhisnew6)}
                       SKIP vbrinca FIRST 1 num_serial
                  INTO vserial--36925115
                  FROM sc_movhis
                 WHERE fech_alt = pfecha--'07/31/2023'
                 ORDER BY num_serial
                
                LET vparam_serial = vserial; --1955500805              
                UPDATE sc_param
                   SET valor = vparam_serial 
                 WHERE empresa = pempresa
                   AND codparam = 'SerIniPasoMovHisOld1';
            END FOREACH;
        ELIF vcont = 2 THEN
            LET vbrinca = vpromedio * 2;            
			FOREACH
                SELECT {+INDEX(sc_movhis idx_movhisnew6)}
                       SKIP vbrinca FIRST 1 num_serial 
                  INTO vserial
                  FROM sc_movhis
                 WHERE fech_alt = pfecha--'09/02/2023'
                 ORDER BY num_serial 
                 
                LET vparam_serial = vserial;                 
                UPDATE sc_param
                   SET valor = vparam_serial--37694931
                 WHERE empresa = pempresa--'001'
                   AND codparam = 'SerIniPasoMovHisOld2';
            END FOREACH;
        ELIF vcont = 3 THEN
            LET vbrinca = vpromedio * 3;
            FOREACH
                SELECT {+INDEX(sc_movhis idx_movhisnew6)}
                       SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM sc_movhis
                 WHERE fech_alt = pfecha
                 ORDER BY num_serial
                 
                LET vparam_serial = vserial;
                 
                UPDATE sc_param
                   SET valor = vparam_serial
                 WHERE empresa = pempresa
                   AND codparam = 'SerIniPasoMovHisOld3';
            END FOREACH;
        ELIF vcont = 4 THEN
            LET vbrinca = vpromedio * 4;
            FOREACH
                SELECT {+INDEX(sc_movhis idx_movhisnew6)}
                       SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM sc_movhis
                 WHERE fech_alt = pfecha
                 ORDER BY num_serial
                 
                LET vparam_serial = vserial;
                 
                UPDATE sc_param
                   SET valor = vparam_serial
                 WHERE empresa = pempresa
                   AND codparam = 'SerIniPasoMovHisOld4';
            END FOREACH;
		ELIF vcont = 5 THEN
            LET vbrinca = vpromedio * 5;
            FOREACH
                SELECT {+INDEX(sc_movhis idx_movhisnew6)}
                       SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM sc_movhis
                 WHERE fech_alt = pfecha
                 ORDER BY num_serial
                 
                LET vparam_serial = vserial;
                 
                UPDATE sc_param
                   SET valor = vparam_serial
                 WHERE empresa = pempresa
                   AND codparam = 'SerIniPasoMovHisOld5';
            END FOREACH;
		ELIF vcont = 6 THEN
            LET vbrinca = vpromedio * 6;
            FOREACH
                SELECT {+INDEX(sc_movhis idx_movhisnew6)}
                       SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM sc_movhis
                 WHERE fech_alt = pfecha
                 ORDER BY num_serial
                 
                LET vparam_serial = vserial;
                 
                UPDATE sc_param
                   SET valor = vparam_serial
                 WHERE empresa = pempresa
                   AND codparam = 'SerIniPasoMovHisOld6';
            END FOREACH;
		ELIF vcont = 7 THEN
            LET vbrinca = vpromedio * 7;
            FOREACH
                SELECT {+INDEX(sc_movhis idx_movhisnew6)}
                       SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM sc_movhis
                 WHERE fech_alt = pfecha
                 ORDER BY num_serial
                 
                LET vparam_serial = vserial;
                 
                UPDATE sc_param
                   SET valor = vparam_serial
                 WHERE empresa = pempresa
                   AND codparam = 'SerIniPasoMovHisOld7';
            END FOREACH;
		ELIF vcont = 8 THEN
            LET vbrinca = vpromedio * 8;
            FOREACH
                SELECT {+INDEX(sc_movhis idx_movhisnew6)}
                       SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM sc_movhis
                 WHERE fech_alt = pfecha
                 ORDER BY num_serial
                 
                LET vparam_serial = vserial;
                 
                UPDATE sc_param
                   SET valor = vparam_serial
                 WHERE empresa = pempresa
                   AND codparam = 'SerIniPasoMovHisOld8';
            END FOREACH;
		ELIF vcont = 9 THEN
            LET vbrinca = vpromedio * 9;
            FOREACH
                SELECT {+INDEX(sc_movhis idx_movhisnew6)}
                       SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM sc_movhis
                 WHERE fech_alt = pfecha
                 ORDER BY num_serial
                 
                LET vparam_serial = vserial;
                 
                UPDATE sc_param
                   SET valor = vparam_serial
                 WHERE empresa = pempresa
                   AND codparam = 'SerIniPasoMovHisOld9';
            END FOREACH;
       END IF;
        LET vcont = vcont + 1;  
        LET vserial = 0;
        LET vparam_serial = '';
    END WHILE;    

    RETURN vcodret;

    END;

END PROCEDURE;