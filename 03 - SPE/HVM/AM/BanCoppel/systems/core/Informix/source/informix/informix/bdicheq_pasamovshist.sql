CREATE PROCEDURE "informix".pasamovshist(pempresa CHAR(3))
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
    DEFINE vaniomes         CHAR(6);
    DEFINE vsql             char(600);
    DEFINE vstmt            char(250);
    DEFINE vexistefinproc   CHAR(1);
    DEFINE vproceso         CHAR(12);
    DEFINE vsistema         CHAR(2);
    DEFINE vusuario         CHAR(10);
    DEFINE vexiste_fecha    SMALLINT;
    
    DEFINE vno_regs         INTEGER;
    DEFINE vcodretparam     CHAR(5);
    DEFINE vserial_final    INTEGER;
    DEFINE vcomienza        INTEGER;
    DEFINE vcont_commit     INTEGER;
    DEFINE vnum_serial      INTEGER;
    DEFINE vfincomp1        SMALLINT;
    DEFINE vfincomp2        SMALLINT;
    DEFINE vfincomp3        SMALLINT;
    DEFINE vfincomp4        SMALLINT;
    DEFINE vfincomp5        SMALLINT;
    DEFINE vfincomp6        SMALLINT;
    
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
    LET vaniomes        = '';
    LET vsql            = '';
    LET vstmt           = '';
    LET vexistefinproc  = '';
    LET vproceso        = 'PasaMovsHist';
    LET vsistema        = '01';
    LET vusuario        = user;
    LET vexiste_fecha   = 0;
    
    LET vno_regs        = 0;
    LET vcodretparam    = '';   
    LET vserial_final   = 0;
    LET vcomienza       = -1;
    LET vcont_commit    = 0;
    LET vnum_serial     = 0;
    LET vfincomp1       = 0;
    LET vfincomp2       = 0;
    LET vfincomp3       = 0;
    LET vfincomp4       = 0;
    LET vfincomp5       = 0;
	LET vfincomp6       = 0;
 
    
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
     
    -- // CALCULA EL AÑO-MES 
    LET vaniomes = YEAR(vfecha_ant)||LPAD(MONTH(vfecha_ant),2,0);
     
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
    
    -- // OBTIENE NUMERO DE REGISTROS A TRASPASAR
    SELECT COUNT(*)
      INTO vexiste_fecha
      FROM sc_trasp_movdia_movhis
     WHERE fecha = vfecha_ant;
     
    IF vexiste_fecha = 0 THEN
        SELECT ---{+INDEX(sc_movdia idx_movdia_fechaserial)} 
               COUNT(*)
          INTO vno_regs
          FROM sc_movdia
         WHERE fech_alt = vfecha_ant
           AND num_serial > 0; 
         
        INSERT INTO sc_trasp_movdia_movhis(fecha, no_regs)
        VALUES(vfecha_ant, vno_regs);
    ELSE
        SELECT no_regs
          INTO vno_regs
          FROM sc_trasp_movdia_movhis
         WHERE fecha = vfecha_ant;
    END IF;
    
    -- // INVOCA PROCESO PARA ACTUALIZAR PARAMETROS DE NUMEROS DE SERIALES
    EXECUTE PROCEDURE "informix".sp_actparampasomovshis(pempresa, vfecha_ant)
    INTO vcodretparam;
    
    IF vcodretparam <> '000' THEN
        LET vcodret1 = '975';
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
    
    -- // ACTUALIZA BANDERA DE INICIO DE PROCESO
    UPDATE sc_contproc
       SET fecha = vfecha_ant
     WHERE empresa = pempresa
       AND proceso = 'inicio_pasomovshist';
    
    -- // OBTIENE VALORES PARA RANGO DE SERIALES A PROCESAR
    SELECT valor::integer
      INTO vserial_final
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'SerialIniPasoMovHis1';
       
    -- // OBTIENE EL NUMERO DE REGISTROS A TRASPASAR
    SELECT ----{+INDEX(sc_movdia idx_movdia_fechaserial)} 
           COUNT(*)
      INTO vcontador1
      FROM sc_movdia
     WHERE fech_alt = vfecha_ant
       AND num_serial < vserial_final;
    
    -- // TRASPASO DE REGISTROS DE MOVDIA A MOVHIS
    FOREACH WITH HOLD 
        SELECT----- {+INDEX(sc_movdia idx_movdia_fechaserial)} 
               num_serial
          INTO vnum_serial
          FROM sc_movdia
         WHERE fech_alt = vfecha_ant
           AND num_serial < vserial_final
           
        /* ########################
        IF vcomienza = -1 THEN
            BEGIN WORK;
            LET vcomienza = 0;
            LET ven_transacc = 1;
        END IF;
        ######################## */
        
        BEGIN WORK;
        LET ven_transacc = 1;
        
        INSERT INTO sc_movhis
        SELECT----- {+INDEX(sc_movdia idx_movdia_fechaserial)} 
               vaniomes, mov.*
          FROM sc_movdia mov
         WHERE mov.fech_alt = vfecha_ant
           AND mov.num_serial = vnum_serial;
         
        DELETE ----{+INDEX(sc_movdia idx_movdia_fechaserial)}
          FROM sc_movdia
         WHERE fech_alt = vfecha_ant
           AND num_serial = vnum_serial;
         
        LET vcont_commit = vcont_commit + 1;
        
        COMMIT WORK;
        LET ven_transacc = 0;
        
        /* ############################
        IF vcont_commit >= 5000 THEN
            COMMIT WORK;
            BEGIN WORK;
            LET vcont_commit = 0;
        END IF;
        ############################ */
    END FOREACH;
    
    /* #########################
    IF ven_transacc = 1 THEN
        COMMIT WORK;
        LET ven_transacc = 0;
    END IF;
    ######################### */
    
    SELECT ---{+INDEX(sc_movhis idx_movhisnew6)}
           COUNT(*)
      INTO vcontador2
      FROM sc_movhis
     WHERE fech_alt = vfecha_ant
       AND num_serial < vserial_final;
     
    SELECT ---{+INDEX(sc_movdia idx_movdia_fechaserial)}
           COUNT(*)
      INTO vcontador3
      FROM sc_movdia
     WHERE fech_alt = vfecha_ant
       AND num_serial < vserial_final;
       
    IF vcontador1 = vcontador2 THEN        
        WHILE ( vfincomp1 = 0 OR vfincomp2 = 0 OR vfincomp3 = 0 OR vfincomp4 = 0 OR vfincomp5 = 0 OR vfincomp6 = 0)
            SET ISOLATION TO DIRTY READ;
            
            SELECT COUNT(*)
              INTO vfincomp1
              FROM sc_contproc
             WHERE proceso = 'pasomovshistcomp1'
               AND fecha = vfecha_ant;
               
            SELECT COUNT(*)
              INTO vfincomp2
              FROM sc_contproc
             WHERE proceso = 'pasomovshistcomp2'
               AND fecha = vfecha_ant;
               
            SELECT COUNT(*)
              INTO vfincomp3
              FROM sc_contproc
             WHERE proceso = 'pasomovshistcomp3'
               AND fecha = vfecha_ant;
               
            SELECT COUNT(*)
              INTO vfincomp4
              FROM sc_contproc
             WHERE proceso = 'pasomovshistcomp4'
               AND fecha = vfecha_ant;

            SELECT COUNT(*)
              INTO vfincomp5
              FROM sc_contproc
             WHERE proceso = 'pasomovshistcomp5'
               AND fecha = vfecha_ant;

			SELECT COUNT(*)
              INTO vfincomp6
              FROM sc_contproc
             WHERE proceso = 'pasomovshistcomp6'
               AND fecha = vfecha_ant;
        END WHILE;
        
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
        LET vcodret1 = '999'; -- // LOS MOVIMIENTOS TRASPASADOS NO COINCIDEN CON LOS MOVIMIENTOS A TRASPASAR
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