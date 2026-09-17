CREATE PROCEDURE "informix".trans_prestamo_val( pc_costos    CHAR(4),
                                                pusuario     CHAR(8),
                                                pfolio       CHAR(16),
                                                pcte_coppel  CHAR(20),
                                                pult_dig_trj CHAR(4),
                                                pfecha       DATE,
                                                pmto_tot     DECIMAL(14,2),
                                                pmoneda      CHAR(3),
                                                preferencia  CHAR(40) )
RETURNING CHAR(5), CHAR(11);
    
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(5);
    DEFINE vind_cierre  CHAR(1);
    DEFINE vind_dispon  CHAR(1);
    DEFINE vcuenta      CHAR(20);
    DEFINE vnum_tarjeta CHAR(16);
    
    LET sql_err      = 0;
    LET isam_err     = 0;
    LET vcodret1     = '000';
    LET vcodret2     = '000';
    LET vcodret3     = '';
    LET vind_cierre  = '0';
    LET vind_dispon  = '0';
    LET vcuenta      = '';
    LET vnum_tarjeta = '';
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/trans_prestamo_val.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/trans_prestamo_val.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            RETURN vcodret1, TRIM(vcuenta);
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF ( pc_costos is null OR pc_costos = '' OR LENGTH(pc_costos) <> 4 ) OR 
       ( pusuario is null OR pusuario = '' OR LENGTH(pusuario) <> 8 ) OR
       ( pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16 ) OR
       ( pcte_coppel is null OR pcte_coppel = '' ) OR 
       ( pult_dig_trj is null OR pult_dig_trj = '' OR LENGTH(pult_dig_trj) <> 4 ) OR 
       ( pfecha is null OR pfecha = '' ) OR
       ( pmto_tot is null OR pmto_tot <= 0.00 ) OR
       ( pmoneda is null OR pmoneda = '' OR LENGTH(pmoneda) <> 03 ) THEN
        LET vcodret1 = '110';
        RETURN vcodret1, TRIM(vcuenta);
    END IF;
    
    -- // Obtiene fechas del sistema de cheques
    SELECT ind_cierre, ind_disponible
      INTO vind_cierre, vind_dispon
      FROM bdicheq:sc_fechas 
     WHERE empresa = '001';
     
    IF ( vind_cierre = '0' OR vind_dispon = '0' ) THEN
        LET vcodret1 = '004';
        RETURN vcodret1, TRIM(vcuenta);
    END IF;
    
    -- // VALIDA QUE EXISTA LA TARJETA
    SELECT trj.cuenta, trj.num_tarjeta
      INTO vcuenta, vnum_tarjeta
      FROM bdicheq:sc_tarjeta trj, 
           bdinteg:si_cliente cte
     WHERE cte.numcte = trj.numcte
       AND cte.numcte_ref = pcte_coppel
       AND SUBSTR(trj.num_tarjeta, 13, 4) = pult_dig_trj;
    
    IF ( vcuenta is not null and vcuenta <> '' ) AND ( vnum_tarjeta is not null and vnum_tarjeta <> '' ) THEN
    
        EXECUTE PROCEDURE trans_prestamo( pc_costos, pusuario, pfolio, vcuenta, vnum_tarjeta, pfecha, pmto_tot, pmoneda, preferencia )
        INTO vcodret3, vcuenta;
        
        LET vcodret1 = vcodret3;
        RETURN vcodret1, TRIM(vcuenta);
        
    ELSE
        
        LET vcodret1 = '200';
        RETURN vcodret1, TRIM(vcuenta);
        
    END IF;

    END;

END PROCEDURE;