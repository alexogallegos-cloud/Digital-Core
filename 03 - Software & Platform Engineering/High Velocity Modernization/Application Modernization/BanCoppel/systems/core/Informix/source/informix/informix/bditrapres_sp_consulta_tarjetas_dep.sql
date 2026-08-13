CREATE PROCEDURE "informix".sp_consulta_tarjetas_dep( pcliente CHAR(20) )
RETURNING CHAR(5), CHAR(16);
    
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(5);
    DEFINE vind_cierre  CHAR(1);
    DEFINE vind_dispon  CHAR(1);
    DEFINE vcuenta      CHAR(20);
    DEFINE vstatus_cta  CHAR(1);
    DEFINE vnum_tarjeta CHAR(16);
    DEFINE vexiste      SMALLINT;
    DEFINE vopcion      SMALLINT;
    DEFINE vabono       CHAR(1);
    DEFINE vmotivo      CHAR(2);
    
    LET sql_err      = 0;
    LET isam_err     = 0;
    LET vcodret1     = '000';
    LET vcodret2     = '';
    LET vcodret3     = '';
    LET vind_cierre  = '0';
    LET vind_dispon  = '0';
    LET vcuenta      = '';
    LET vstatus_cta  = '';
    LET vnum_tarjeta = '';
    LET vexiste      = 0;
    LET vopcion      = 0;
    LET vabono       = '';
    LET vmotivo      = '';
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consulta_tarjetas_dep.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consulta_tarjetas_dep.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            RETURN vcodret1, vnum_tarjeta;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF ( pcliente is null OR pcliente = '' ) THEN
        LET vcodret1 = '110';
        RETURN vcodret1, vnum_tarjeta;
    END IF;
    
    -- // Obtiene fechas del sistema de cheques
    SELECT ind_cierre, ind_disponible
      INTO vind_cierre, vind_dispon
      FROM bdicheq:sc_fechas 
     WHERE empresa = '001';
     
    IF ( vind_cierre = '0' OR vind_dispon = '0' ) THEN
        LET vcodret1 = '004';
        RETURN vcodret1, vnum_tarjeta;
    END IF;
    
    -- // OBTIENE LAS TARJETAS DEL CLIENTE
    FOREACH
        SELECT mae.cuenta, mae.status_cta, mae.motivo, trj.num_tarjeta 
          INTO vcuenta, vstatus_cta, vmotivo, vnum_tarjeta 
          FROM bdicheq:sc_tarjeta trj, 
               bdicheq:sc_maechq mae
         WHERE mae.num_cte = trj.numcte
           AND mae.cuenta = trj.cuenta
           AND trj.tipo_tarjeta = 'T'
           AND trj.status_tar = 'A'
           AND trj.expiracion >= TODAY
           AND mae.status_cta IN('1','3','4','5')
           AND mae.num_cte = pcliente
           
        IF vstatus_cta = 3 THEN
            SELECT COUNT(*)
              INTO vexiste
              FROM bdicheq:sc_ctabloqueo
             WHERE cuenta = vcuenta;
              
            IF vexiste > 0 THEN
                SELECT opcion
                  INTO vopcion
                  FROM bdicheq:sc_ctabloqueo
                 WHERE cuenta = vcuenta;
                
                IF vopcion IN(2,4) THEN
                    CONTINUE FOREACH;
                END IF;
            ELSE
                SELECT abono
                  INTO vabono
                  FROM bdicheq:sc_bloqueo
                 WHERE codigo = vmotivo;
                
                IF vabono = 'N' THEN
                    CONTINUE FOREACH;
                END IF;
            END IF;            
        END IF;
        
        RETURN vcodret1, vnum_tarjeta WITH RESUME;
        
        LET vcuenta = '';
        LET vstatus_cta = '';
        LET vnum_tarjeta = '';
        LET vopcion = 0;
        LET vabono = '';
        LET vmotivo = '';
    END FOREACH;

    END;

END PROCEDURE;