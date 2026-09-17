CREATE PROCEDURE "informix".sp_actparamactsdos(pempresa CHAR(3))
RETURNING CHAR(5);
     
    --- ################################################################################
    --- ##  Nombre:              sp_actparamactsdos                                   ##
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
    DEFINE vpromedio        INTEGER;
    DEFINE vcont            SMALLINT;
    DEFINE vbrinca          INTEGER;
    DEFINE vcuenta          CHAR(20);
    DEFINE vfecha_hoy       DATE;
    DEFINE vultdiames       DATE;
    
    LET vcodret    = "000";
    LET vcodret2   = "000";
    LET vcodret3   = " ";
    LET vsqlerr    = 0;
    LET isam_err   = 0;
    LET error_info = '';
    LET vpromedio  = 0;
    LET vcont      = 0;
    LET vbrinca    = 0;
    LET vcuenta    = '';
    LET vfecha_hoy = '';
    LET vultdiames = '';
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparamactsdos.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparamactsdos.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    SELECT fecha_hoy, ult_dia_mes
      INTO vfecha_hoy, vultdiames
      FROM sc_fechas
     WHERE empresa = pempresa;
	 
	--- IF ( ( WEEKDAY(vfecha_hoy) = 0 ) AND ( vfecha_hoy <> vultdiames ) ) THEN
        
        SELECT ROUND(COUNT(*)/9)
          INTO vpromedio
          FROM sc_maechq 
         WHERE producto <> '1100'
           AND status_cta <> '2';
            
        LET vcont = 1;  
        
        WHILE vcont <= 8   
            
            IF vcont = 1 THEN
                
                LET vbrinca = vpromedio;
                
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto <> '1100'
                       AND status_cta <> '2'
                     ORDER BY cuenta
                 
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE codparam = 'CtaIniActuaSdosComp1';
                END FOREACH;
                
            ELIF vcont = 2 THEN
                
                LET vbrinca = vpromedio * 2;
                
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq 
                     WHERE producto <> '1100'
                       AND status_cta <> '2'
                     ORDER BY cuenta
                    
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE codparam = 'CtaIniActuaSdosComp2';
                END FOREACH;
                
			ELIF vcont = 3 THEN
            
                LET vbrinca = vpromedio * 3;
                
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq 
                     WHERE producto <> '1100'
                       AND status_cta <> '2'
                     ORDER BY cuenta
                 
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE codparam = 'CtaIniActuaSdosComp3';
                END FOREACH;
                
           ELIF vcont = 4 THEN
                
                LET vbrinca = vpromedio * 4;
                
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq 
                     WHERE producto <> '1100'
                       AND status_cta <> '2'
                     ORDER BY cuenta
                 
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE codparam = 'CtaIniActuaSdosComp4';
                END FOREACH;
                
			ELIF vcont = 5 THEN
                
                LET vbrinca = vpromedio * 5;
                
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq 
                     WHERE producto <> '1100'
                       AND status_cta <> '2'
                     ORDER BY cuenta
                 
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE codparam = 'CtaIniActuaSdosComp5';
                END FOREACH;
                
            ELIF vcont = 6 THEN
                
                LET vbrinca = vpromedio * 6;
                
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq 
                     WHERE producto <> '1100'
                       AND status_cta <> '2'
                     ORDER BY cuenta
                 
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE codparam = 'CtaIniActuaSdosComp6';
                END FOREACH;
                
            ELIF vcont = 7 THEN
                
                LET vbrinca = vpromedio * 7;
                
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq 
                     WHERE producto <> '1100'
                       AND status_cta <> '2'
                     ORDER BY cuenta
                 
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE codparam = 'CtaIniActuaSdosComp7';
                END FOREACH;
                
            ELIF vcont = 8 THEN
                
                LET vbrinca = vpromedio * 8;
                
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq 
                     WHERE producto <> '1100'
                       AND status_cta <> '2'
                     ORDER BY cuenta
                 
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE codparam = 'CtaIniActuaSdosComp8';
                END FOREACH;
                
            END IF;
            
            LET vcont = vcont + 1;
            
        END WHILE;  
        
    --- ELSE
        
        --- LET vcodret = "000";
        
    --- END IF;
    
    RETURN vcodret;
    
    END;
    
END PROCEDURE;