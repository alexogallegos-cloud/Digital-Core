CREATE PROCEDURE "informix".pasamovshist_pba(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha_ant       DATE;
    DEFINE vexiste          SMALLINT;
    DEFINE vexistefin       SMALLINT;
    DEFINE vfechaproc       DATE;
    DEFINE vmin_cta         CHAR(20);
    DEFINE vmax_cta         CHAR(20);
    DEFINE vcuenta          CHAR(20);
    DEFINE vaniomes         CHAR(6);
    DEFINE vsql             char(600);
    DEFINE vstmt            char(250);
    DEFINE vexistefinproc   CHAR(1);
    DEFINE vproceso         CHAR(12);
    DEFINE vsistema         CHAR(2);
    DEFINE vusuario         CHAR(10);
    DEFINE vexiste_fecha    SMALLINT;
    
    LET vcodret1        = '000';
    LET vcodret2        = '000';
    LET sql_err	        = 0;
    LET isam_err        = 0;
    LET vcontador1      = 0;
    LET vcontador2      = 0;
    LET vcontador3      = 0;
    LET ven_transacc    = 0; 
    
    LET vfecha_hoy      = ''; 
    LET vfecha_ant      = '';
    LET vexiste         = 0;
    LET vexistefin      = 0;
    LET vfechaproc      = '';
    LET vmin_cta        = '';
    LET vmax_cta        = '';
    LET vcuenta         = ''; 
    LET vaniomes        = '';
    LET vsql            = '';
    LET vstmt           = '';
    LET vexistefinproc  = '';
    LET vproceso        = 'PasaMovsHist';
    LET vsistema        = '01';
    LET vusuario        = user;
    LET vexiste_fecha   = 0;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/pasamovshist.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'C'||''','||
                       'codret        = '''||vcodret1||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovs.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovs.sql';
            SYSTEM vstmt;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/pasamovshist.out";
    --- TRACE ON;
    
    SET OPTIMIZATION HIGH;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE LAS FECHAS DEL SISTEMA
    SELECT fecha_hoy, fecha_ant
      INTO vfecha_hoy, vfecha_ant
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    -- // VALIDA HAYA FINALIZADO CIERRE DE CAPTACION
    SELECT fecha
      INTO vfechaproc
      FROM sc_contproc
     WHERE empresa = pempresa
       AND proceso = 'cierre'
       AND fecha = vfecha_ant;
    
    IF vfechaproc is null THEN
        LET vcodret1 = "962";
        LET vcodret2 = "962";
        RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
    END IF
     
    -- // Guarda inicio de proceso     
    SELECT COUNT(*)
      INTO vexiste
      FROM bdinteg:sx_contproc
     WHERE empresa = pempresa
       AND proceso = vproceso
       AND fecha   = vfecha_hoy
       AND sistema = vsistema;

    IF vexiste = 0 THEN
        LET vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso||''', '''||vfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||vusuario||''','||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horaspasamovs.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovs.sql';
        SYSTEM vstmt;
    ELSE
        SELECT COUNT(*)
          INTO vexistefin
          FROM bdinteg:sx_contproc
         WHERE empresa = pempresa
           AND proceso = vproceso
           AND fecha   = vfecha_hoy
           AND sistema = vsistema
           AND status_proc = "F";
           
        IF vexistefin = 0 THEN
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'I'||''','||
                       'codret        = '''||' '||''','||
                       'hora_fin      = '''||' '||''','||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovs.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovs.sql';
            SYSTEM vstmt;
        ELSE
            SELECT "1"
              INTO vexistefinproc
              FROM sc_contproc
             WHERE empresa = pempresa
               AND proceso = "pasomovshist"
               AND fecha = vfecha_ant;
               
            IF vexistefinproc = "1" THEN
                LET vcodret1 = "958";
                RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
            END IF
        END IF;
    END IF;
    
   /*  -- // LLENA TABLA PARA PROCESO EXTERIOR
    TRUNCATE TABLE sc_movdia_apert;

    INSERT INTO sc_movdia_apert
    SELECT *
      FROM sc_movdia
     WHERE empresa = pempresa
       AND cuenta <> '16000000012'
       AND fech_alt = vfecha_ant
       AND cancelad <> 'S'
       AND transacc in ('0202','0223'); */
       
    -- // OBTIENE NUMERO DE REGISTROS A TRASPASAR
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmin_cta, vmax_cta
      FROM sc_movdia;
      
    SELECT COUNT(*)
      INTO vexiste_fecha
      FROM sc_trasp_movdia_movhis
     WHERE fecha = vfecha_ant;
     
    IF vexiste_fecha = 0 THEN
        SELECT COUNT(*)
          INTO vcontador1
          FROM sc_movdia
         WHERE empresa = pempresa
           AND cuenta BETWEEN vmin_cta AND vmax_cta
           AND fech_alt = vfecha_ant; 
         
        INSERT INTO sc_trasp_movdia_movhis(fecha, no_regs)
        VALUES(vfecha_ant, vcontador1);
    ELSE
        SELECT no_regs
          INTO vcontador1
          FROM sc_trasp_movdia_movhis
         WHERE fecha = vfecha_ant;
    END IF;
    
    LET vaniomes = YEAR(vfecha_ant)||LPAD(MONTH(vfecha_ant),2,0);
    
    FOREACH WITH HOLD 
        SELECT UNIQUE cuenta
          INTO vcuenta
          FROM sc_movdia
         WHERE empresa = pempresa
           AND cuenta BETWEEN vmin_cta AND vmax_cta
           AND fech_alt = vfecha_ant
           AND producto NOT IN('1200','1600','9900','9901')
           
        BEGIN WORK;
        LET ven_transacc = 1; 
        
        INSERT INTO sc_movhis
        SELECT vaniomes, mov.*
          FROM sc_movdia mov
         WHERE mov.empresa = pempresa
           AND mov.cuenta = vcuenta
           AND mov.fech_alt = vfecha_ant;
           
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            DELETE FROM sc_movdia
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND fech_alt = vfecha_ant;
               
            IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
                COMMIT WORK;
                LET ven_transacc = 0; 
            ELSE
                ROLLBACK WORK;
                LET ven_transacc = 0; 
            END IF;
        ELSE
            ROLLBACK WORK;
            LET ven_transacc = 0; 
        END IF;
    END FOREACH;
    
    FOREACH WITH HOLD 
        SELECT UNIQUE cuenta
          INTO vcuenta
          FROM sc_movdia
         WHERE empresa = pempresa
           AND cuenta BETWEEN vmin_cta AND vmax_cta
           AND fech_alt = vfecha_ant
           
        BEGIN WORK;
        LET ven_transacc = 1; 
           
        INSERT INTO sc_movhis
        SELECT vaniomes, mov.*
          FROM sc_movdia mov
         WHERE mov.empresa = pempresa
           AND mov.cuenta = vcuenta
           AND mov.fech_alt = vfecha_ant;
           
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            DELETE FROM sc_movdia
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND fech_alt = vfecha_ant;
               
            IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
                COMMIT WORK;
                LET ven_transacc = 0; 
            ELSE
                ROLLBACK WORK;
                LET ven_transacc = 0; 
            END IF;
        ELSE
            ROLLBACK WORK;
            LET ven_transacc = 0; 
        END IF;
    END FOREACH;
    
    SELECT {+INDEX(sc_movhis idx_movhisnew6)}
           COUNT(*)
      INTO vcontador2
      FROM sc_movhis
     WHERE fech_alt = vfecha_ant;
     
    SELECT COUNT(*)
      INTO vcontador3
      FROM sc_movdia
     WHERE empresa = pempresa
       AND cuenta BETWEEN vmin_cta AND vmax_cta
       AND fech_alt = vfecha_ant; 
       
    IF vcontador1 = vcontador2 THEN
        LET vcodret1 = '000'; -- // PROCESO CONCLUIDO SATISFACTORIAMENTE
        LET vcodret2 = '000';
        
        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET ejecutivo = '''||vusuario||''','||
                   'status_proc   = '''||'F'||''','||
                   'codret        = '''||vcodret1||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovs.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovs.sql';
        SYSTEM vstmt;
           
        UPDATE sc_contproc
           SET fecha   = vfecha_ant
         WHERE empresa = pempresa
           AND proceso = 'pasomovshist';
    ELSE
        LET vcodret1 = '999'; -- // LOS MOVIMIENTOS TRASPASADOS NO COINCIDEN CON LOS MOVIMIENTOS A TRASAPASAR
        LET vcodret2 = '999';
        
        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET status_proc   = '''||'C'||''','||
                   'codret        = '''||vcodret1||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovs.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovs.sql';
        SYSTEM vstmt;
    END IF;
       
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;

END PROCEDURE;