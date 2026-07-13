CREATE PROCEDURE "informix".sp_obtpagointinvcrec(pempresa CHAR(3), pfechaini DATE, pfechafin DATE)

RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vdesccodret      CHAR(50);
    DEFINE vsqlerr          INTEGER;
    DEFINE visamerr         INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE vcomienzaa       SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vmes                 SMALLINT;
    DEFINE vcuenta              CHAR(20);
    DEFINE vexiste              CHAR(20);
    DEFINE vfechaini            DATE;
    DEFINE vinicio_periodo      DATE;
    DEFINE vfin_periodo         DATE;
    DEFINE vtipo_tasa           CHAR(1);
    DEFINE vvalor_tasa          DECIMAL(9,6);
    DEFINE vint_acum            DECIMAL(18,2);
    DEFINE visr                 DECIMAL(18,2);
    DEFINE vtasa_isr            DECIMAL(9,6);
    DEFINE vsdo_cuenta          DECIMAL(18,2);      
    DEFINE vmontopagoint        DECIMAL(18,2);
    DEFINE vmontopagoisr        DECIMAL(18,2);
    DEFINE vmontopagoide        DECIMAL(18,2);
    DEFINE vpromedio            DECIMAL(18,2);
    DEFINE vacum_sdo_pos        DECIMAL(18,2);
    DEFINE vdia_sdo_pos         DECIMAL(18,2);
    DEFINE vfechainimovhis      DATE;
    DEFINE vfechainimovhisold   DATE;
    
    LET vcodret1     = "000";
    LET vcodret2     = "000";
    LET vdesccodret  = " ";
    LET vsqlerr      = 0;
    LET visamerr     = 0;
    LET vcomienza    = -1;
    LET vcomienzaa   = -1;
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vcontador3   = 0;
    LET ven_transacc = 0;
    
    LET vmes                = 0;
    LET vcuenta             = "";
    LET vexiste             = '';
    LET vfechaini           = '';
    LET vinicio_periodo     = '';
    LET vfin_periodo        = '';
    LET vtipo_tasa          = '';
    LET vvalor_tasa         = 0;
    LET vint_acum           = 0;
    LET visr                = 0;
    LET vtasa_isr           = 0;
    LET vsdo_cuenta         = 0;
    LET vmontopagoint       = 0;
    LET vmontopagoisr       = 0;
    LET vmontopagoide       = 0;
    LET vpromedio           = 0;
    LET vacum_sdo_pos       = 0;
    LET vdia_sdo_pos        = 0;
    LET vfechainimovhis     = '';
    LET vfechainimovhisold  = '';
    
    BEGIN

    ON EXCEPTION SET vsqlerr, visamerr
        SET debug file to "./sp_obtpagointinvcrec.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret1 = vsqlerr;
            LET vcodret2 = visamerr;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vdesccodret, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET debug file to "./sp_obtpagointinvcrec.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    CREATE TEMP TABLE sc_tasa_variable_tmp
        (
            mes             SMALLINT,
            cuenta          CHAR(20), 
            inicio_periodo  DATE,
            fin_periodo     DATE,
            tipo_tasa       CHAR(1),
            valor_tasa      DECIMAL(9,6),
            int_acum        DECIMAL(14,2),
            isr             DECIMAL(14,2),
            tasa_isr        DECIMAL(9,6)
        ) 
    WITH NO LOG LOCK MODE ROW;
    CREATE INDEX idx_invstmp ON sc_tasa_variable_tmp(cuenta) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE sc_tasa_variable_tmp;
    
    CREATE TEMP TABLE sc_tasa_variable_tmp2
        (
            mes             SMALLINT,
            cuenta          CHAR(20), 
            inicio_periodo  DATE,
            fin_periodo     DATE,
            tipo_tasa       CHAR(1),
            valor_tasa      DECIMAL(9,6),
            int_acum        DECIMAL(14,2),
            isr             DECIMAL(14,2),
            tasa_isr        DECIMAL(9,6),
            sdo_cuenta      DECIMAL(18,2),
            sdo_promedio     DECIMAL(18,2)
        ) 
    WITH NO LOG LOCK MODE ROW;
    CREATE INDEX idx_invstmp2 ON sc_tasa_variable_tmp2(cuenta) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE sc_tasa_variable_tmp2;
    
    -- // OBTIENEN PARAMETROS DE LECTURA DE HISTORICOS
    SELECT valor
      INTO vfechainimovhis
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor
      INTO vfechainimovhisold
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechIniCon_movhis_ol';
        
    -- // OBTIENE INVERSIONES CON PAGO DE INTERESES
    SELECT {+INDEX(sc_movhis idx_movhisnew4)}
           num_serial, cuenta, fech_alt, sdo_cuenta, monto_tot
      FROM sc_movhis
     WHERE empresa = pempresa
       AND cuenta LIKE '11%'
       AND fech_alt >= vfechainimovhis
       AND fech_alt BETWEEN pfechaini AND pfechafin
       AND cancelad <> 'S'
       AND transacc = '3276'
       AND producto = '1100'
    UNION ALL
    SELECT {+INDEX(sc_movhis_old movhis1)}
           num_serial, cuenta, fech_alt, sdo_cuenta, monto_tot
      FROM sc_movhis_old
     WHERE empresa = pempresa
       AND cuenta LIKE '11%'
       AND fech_alt >= vfechainimovhisold
       AND fech_alt < vfechainimovhis
       AND fech_alt BETWEEN pfechaini AND pfechafin
       AND cancelad <> 'S'
       AND transacc = '3276'
       AND producto = '1100'
      INTO TEMP tmp_intinvscrecs WITH NO LOG;
    CREATE INDEX idx_intinvscrecs ON tmp_intinvscrecs(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_intinvscrecs;
    
    -- // OBTIENE INVERSIONES CON COBRO DE ISR
    SELECT {+INDEX(sc_movhis idx_movhisnew4)}
           num_serial, cuenta, fech_alt, sdo_cuenta, monto_tot
      FROM sc_movhis
     WHERE empresa = pempresa
       AND cuenta LIKE '11%'
       AND fech_alt >= vfechainimovhis
       AND fech_alt BETWEEN pfechaini AND pfechafin
       AND cancelad <> 'S'
       AND transacc = '3277'
       AND producto = '1100'
    UNION ALL
    SELECT {+INDEX(sc_movhis_old movhis1)}
           num_serial, cuenta, fech_alt, sdo_cuenta, monto_tot
      FROM sc_movhis_old
     WHERE empresa = pempresa
       AND cuenta LIKE '11%'
       AND fech_alt >= vfechainimovhisold
       AND fech_alt < vfechainimovhis
       AND fech_alt BETWEEN pfechaini AND pfechafin
       AND cancelad <> 'S'
       AND transacc = '3277'
       AND producto = '1100'
      INTO TEMP tmp_isrinvscrecs WITH NO LOG;
    CREATE INDEX idx_isrinvscrecs ON tmp_isrinvscrecs(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_isrinvscrecs;
    
    -- // OBTIENE INVERSIONES CON COBRO DE IDE
    SELECT {+INDEX(sc_movhis idx_movhisnew4)}
           num_serial, cuenta, fech_alt, sdo_cuenta, monto_tot
      FROM sc_movhis
     WHERE empresa = pempresa
       AND cuenta LIKE '11%'
       AND fech_alt >= vfechainimovhis
       AND fech_alt BETWEEN pfechaini AND pfechafin
       AND cancelad <> 'S'
       AND transacc = '3280'
       AND producto = '1100'
    UNION ALL
    SELECT {+INDEX(sc_movhis_old movhis1)}
           num_serial, cuenta, fech_alt, sdo_cuenta, monto_tot
      FROM sc_movhis_old
     WHERE empresa = pempresa
       AND cuenta LIKE '11%'
       AND fech_alt >= vfechainimovhisold
       AND fech_alt < vfechainimovhis
       AND fech_alt BETWEEN pfechaini AND pfechafin
       AND cancelad <> 'S'
       AND transacc = '3280'
       AND producto = '1100'
      INTO TEMP tmp_ideinvscrecs WITH NO LOG;
    CREATE INDEX idx_ideinvscrecs ON tmp_ideinvscrecs(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ideinvscrecs;
    
    FOREACH WITH HOLD
        SELECT UNIQUE cuenta
          INTO vcuenta
          FROM tmp_intinvscrecs
          
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
          
        LET vmes = 1;
          
        SELECT FIRST 1 cuenta
          INTO vexiste
          FROM sc_tasa_variable
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND fin_periodo - 1 BETWEEN pfechaini AND pfechafin;
           
        IF vexiste is not null OR vexiste <> '' THEN
            FOREACH
                SELECT inicio_periodo, fin_periodo, tipo_tasa, valor_tasa, int_acum, isr, tasa_isr
                  INTO vinicio_periodo, vfin_periodo, vtipo_tasa, vvalor_tasa, vint_acum, visr, vtasa_isr
                  FROM sc_tasa_variable
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                 ORDER BY fin_periodo, tipo_tasa
                   
                INSERT INTO sc_tasa_variable_tmp VALUES
                (vmes, vcuenta, vinicio_periodo, vfin_periodo, vtipo_tasa, vvalor_tasa, vint_acum, visr, vtasa_isr);
                
                LET vinicio_periodo = '';
                LET vfin_periodo    = '';
                LET vtipo_tasa      = '';
                LET vvalor_tasa     = 0;
                LET vint_acum       = 0;
                LET visr            = 0;
                LET vtasa_isr       = 0;
                
                LET vmes = vmes + 1;
            END FOREACH;
        ELSE
            SELECT MAX(inicio_periodo)
              INTO vfechaini
              FROM sc_tasa_var_hist
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND tipo_tasa = 'P';
               
            FOREACH
                SELECT inicio_periodo, fin_periodo, tipo_tasa, valor_tasa, int_acum, isr, tasa_isr
                  INTO vinicio_periodo, vfin_periodo, vtipo_tasa, vvalor_tasa, vint_acum, visr, vtasa_isr
                  FROM sc_tasa_var_hist
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND fin_periodo > vfechaini
                 ORDER BY fin_periodo, tipo_tasa
                   
                INSERT INTO sc_tasa_variable_tmp VALUES
                (vmes, vcuenta, vinicio_periodo, vfin_periodo, vtipo_tasa, vvalor_tasa, vint_acum, visr, vtasa_isr);
                
                LET vinicio_periodo = '';
                LET vfin_periodo    = '';
                LET vtipo_tasa      = '';
                LET vvalor_tasa     = 0;
                LET vint_acum       = 0;
                LET visr            = 0;
                LET vtasa_isr       = 0;
                
                LET vmes = vmes + 1;
            END FOREACH;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vcuenta   = "";
        LET vexiste   = '';
        LET vfechaini = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_tasa_variable_tmp;
    
    FOREACH WITH HOLD
        SELECT UNIQUE cuenta
          INTO vcuenta
          FROM tmp_intinvscrecs
          
        IF vcomienzaa = -1 THEN
            LET vcomienzaa = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
          
        FOREACH
            SELECT mes, inicio_periodo, fin_periodo, tipo_tasa, valor_tasa, int_acum, isr, tasa_isr
              INTO vmes, vinicio_periodo, vfin_periodo, vtipo_tasa, vvalor_tasa, vint_acum, visr, vtasa_isr
              FROM sc_tasa_variable_tmp
             WHERE cuenta = vcuenta
               AND fin_periodo - 1 BETWEEN pfechaini AND pfechafin
               
            SELECT FIRST 1 sdo_cuenta
              INTO vsdo_cuenta
              FROM tmp_intinvscrecs
             WHERE cuenta = vcuenta;
             
            SELECT SUM(monto_tot)
              INTO vmontopagoint
              FROM tmp_intinvscrecs
             WHERE cuenta = vcuenta;
             
            SELECT SUM(monto_tot)
              INTO vmontopagoisr
              FROM tmp_isrinvscrecs
             WHERE cuenta = vcuenta;
             
            IF vmontopagoisr is null OR vmontopagoisr = '' THEN
                LET vmontopagoisr = 0.00;
            END IF;
             
            SELECT SUM(monto_tot)
              INTO vmontopagoide
              FROM tmp_ideinvscrecs
             WHERE cuenta = vcuenta;
             
            IF vmontopagoide is null OR vmontopagoide = '' THEN
                LET vmontopagoide = 0.00;
            END IF;
             
            LET vsdo_cuenta = (vsdo_cuenta + (vmontopagoint - (vmontopagoisr + vmontopagoide)));
             
            SELECT NVL(acum_sdo_pos, 0), NVL(dia_sdo_pos, 0)
              INTO vacum_sdo_pos, vdia_sdo_pos
              FROM sc_maehis
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND fechafin = vfin_periodo - 1;
               
            LET vpromedio = vacum_sdo_pos / vdia_sdo_pos;
        
            INSERT INTO sc_tasa_variable_tmp2 VALUES
            (vmes, vcuenta, vinicio_periodo, vfin_periodo, vtipo_tasa, vvalor_tasa, vint_acum, visr, vtasa_isr, vsdo_cuenta, vpromedio);
            
            LET vcontador2 = vcontador2 + 1;
            
            LET vmes            = 0;
            LET vinicio_periodo = '';
            LET vfin_periodo    = '';
            LET vtipo_tasa      = '';
            LET vvalor_tasa     = 0;
            LET vint_acum       = 0;
            LET visr            = 0;
            LET vtasa_isr       = 0;
            LET vsdo_cuenta     = 0;
            LET vmontopagoint   = 0;
            LET vmontopagoisr   = 0;
            LET vmontopagoide   = 0;
        END FOREACH;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vcuenta = "";
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_tasa_variable_tmp2;
    
    LET vdesccodret = "EL PROCESO SE REALIZO SATISFACTORIAMENTE";
    
    RETURN vcodret1, vcodret2, vdesccodret, vcontador1, vcontador2;
    
    END;

END PROCEDURE;