CREATE PROCEDURE "informix".sp_actparamcierre_vb(pempresa CHAR(3))
RETURNING CHAR(5);
 
    --- ################################################################################
    --- ##  Nombre:              sp_actparamcierre_vb                                 ##
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
    DEFINE vbrinca          INTEGER;
    DEFINE vcuenta          CHAR(20);
    
    LET vcodret    = "";
    LET vcodret2   = "";
    LET vcodret3   = " ";
    LET vsqlerr    = 0;
    LET isam_err   = 0;
    LET error_info = '';
    LET vfecha_hoy = ' ';    
    LET vpromedio  = 0;
    LET vbrinca    = 0;
    LET vcuenta    = '';
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparamcierre_vb.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparamcierre_vb.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    SELECT ROUND(COUNT(*)/2)
      INTO vpromedio
      FROM sc_maechq
     WHERE producto = '2000'
       AND status_cta NOT IN("2","6","7","8")
       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy);
       
    LET vbrinca = vpromedio;
    
    FOREACH
        SELECT SKIP vbrinca FIRST 1 cuenta
          INTO vcuenta
          FROM sc_maechq
         WHERE producto = '2000'
           AND status_cta not in("2","6","7","8")
           AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
         ORDER BY cuenta
     
        UPDATE sc_param
           SET valor = vcuenta
         WHERE empresa = pempresa
           AND codparam = 'CtaEjeCierreCheques';
           
        LET vcodret = "000";
    END FOREACH;

    RETURN vcodret;

    END;

END PROCEDURE;