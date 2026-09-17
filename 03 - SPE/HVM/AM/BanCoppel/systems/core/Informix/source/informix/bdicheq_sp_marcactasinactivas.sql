CREATE PROCEDURE "informix".sp_marcactasinactivas( pempresa char(3) )
RETURNING CHAR(5);
    
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    
    DEFINE vcomienza        INTEGER;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    
    DEFINE vFecha_Hoy       DATE;
    DEFINE vfecha_ant       DATE;
    DEFINE vcuenta          CHAR(20);
    DEFINE vfecultdep       DATE;
    DEFINE vfecultret       DATE;
    DEFINE vfecha_alta      DATE;
    DEFINE vDias_Inact      INTEGER;
    DEFINE vsdo_actual      DECIMAL(18,2);
    
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    LET vcodret1 = '000';
    LET vcodret2 = '';
    LET vcodret3 = '';
    
    LET vcomienza    = -1;
    LET ven_transacc = 0;
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vcontador3   = 0;
    
    LET vFecha_Hoy  = '';
    LET vfecha_ant  = '';
    LET vcuenta     = '';                    
    LET vfecultdep  = '';
    LET vfecultret  = '';
    LET vfecha_alta = '';
    LET vDias_Inact = 0;
    LET vsdo_actual = 0.00;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_marcactasinactivas.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_marcactasinactivas.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy, fecha_ant
      INTO vFecha_Hoy, vfecha_ant
      FROM sc_fechas
     WHERE empresa = pEmpresa;
     
    SELECT valor
      INTO vDias_Inact
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasMaxDeInactividad';
       
    CREATE TEMP TABLE tmp_ctesno
      ( 
        num_cte CHAR(20) NOT NULL
      ) 
    WITH NO LOG;
    
    INSERT INTO tmp_ctesno
    SELECT num_cte
      FROM sc_maechq 
     WHERE empresa = pEmpresa
       AND producto = '1100'
       AND status_cta <> '2';
    
    INSERT INTO tmp_ctesno
    SELECT num_cte
      FROM bdinvers:sv_maeinv 
     WHERE empresa = pEmpresa
       AND status_cta = '1';
    
    INSERT INTO tmp_ctesno
    SELECT numcte
      FROM bdicred:sd_maecred 
     WHERE empresa = pEmpresa
       AND status_cred IN('AA','BA','BT','E1','E2','E3');
       
    INSERT INTO tmp_ctesno
    SELECT numcte
      FROM bdicred:sd_maecredcrd 
     WHERE empresa = pEmpresa
       AND status_cred IN('VP','AA','BA','BT','E1','E2','E3');
    
    UPDATE STATISTICS HIGH FOR TABLE tmp_ctesno;
    
    SELECT UNIQUE num_cte
      FROM tmp_ctesno
      INTO TEMP tmp_ctesexcluidos WITH NO LOG;
    CREATE INDEX idx_ctesexc ON tmp_ctesexcluidos(num_cte) USING BTREE FILLFACTOR 99;
    
    CREATE INDEX idx_tmpctexc ON tmp_ctesno(num_cte) USING BTREE;
    UPDATE STATISTICS HIGH FOR TABLE tmp_ctesexcluidos;
    
    FOREACH WITH HOLD
        SELECT mae.cuenta, mae.fecultdep, mae.fecultret, mae.sdo_actual, noc.fecha_alta
          INTO vcuenta, vfecultdep, vfecultret, vsdo_actual, vfecha_alta
          FROM sc_maechq mae,
               sc_maenoc noc,
               sc_productos_inactivos prod
         WHERE mae.empresa = pempresa
           AND mae.cuenta >= '10000000000'
           AND mae.status_cta = '1'
           AND mae.producto = prod.producto
           AND mae.num_cte NOT IN(SELECT num_cte FROM tmp_ctesexcluidos)
           AND (((vFecha_Hoy - mae.fecultdep) > vDias_Inact) OR ((vFecha_Hoy - mae.fecultret) > vDias_Inact) OR (fecultdep is null OR fecultdep = '') OR (fecultret is null OR fecultret = '' ))
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           AND noc.fecha_alta < vFecha_Hoy 
           
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            BEGIN WORK;
            LET ven_transacc = 1;
        END IF;
        
        IF vfecultdep is null OR vfecultdep = '' THEN
            LET vfecultdep = vfecha_alta;
        END IF;
        
        IF vfecultret is null OR vfecultret = '' THEN
            LET vfecultret = vfecha_alta;
        END IF;
        
        IF ((vFecha_Hoy - vfecultdep) > vDias_Inact) AND ((vFecha_Hoy - vfecultret) > vDias_Inact) THEN
            IF vsdo_actual > 0.00 THEN
                UPDATE sc_maechq
                   SET status_cta = '4'
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;
            ELSE
                UPDATE sc_maechq
                   SET status_cta = '4',
                       fecha_proceso = vfecha_ant
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;
            END IF;
               
            LET vcontador3 = vcontador3 + 1;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;

        IF vcontador2 >= 1000 THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vcuenta = '';
        LET vfecultdep = '';
        LET vfecultret = '';
        LET vfecha_alta = '';
        LET vsdo_actual = 0.00;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1;

END PROCEDURE;