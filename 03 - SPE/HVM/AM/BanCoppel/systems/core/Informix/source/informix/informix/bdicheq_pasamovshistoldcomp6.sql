CREATE PROCEDURE "informix".pasamovshistoldcomp6(pempresa CHAR(3))
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
    DEFINE vfecha_borrado   DATE;
    DEFINE vexiste          SMALLINT;
    DEFINE vexistefin       SMALLINT;
    DEFINE vfechaproc       SMALLINT;
    DEFINE vsql             char(600);
    DEFINE vstmt            char(250);
    DEFINE vexistefinproc   CHAR(1);
    DEFINE vproceso         CHAR(20);
    DEFINE vsistema         CHAR(2);
    DEFINE vusuario         CHAR(10);
    DEFINE vexiste_fecha    SMALLINT;
    
    DEFINE vcodretparam     CHAR(5);
    DEFINE vserial_inicial  INTEGER;
    DEFINE vserial_final    INTEGER;
    DEFINE vcomienza        INTEGER;
    DEFINE vcont_commit     INTEGER;
    DEFINE vnum_serial      INTEGER;
    
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
    LET vfecha_borrado  = '';
    LET vexiste         = 0;
    LET vexistefin      = 0;
    LET vfechaproc      = 0;
    LET vsql            = '';
    LET vstmt           = '';
    LET vexistefinproc  = '';
    LET vproceso        = 'pasamovshistoldcomp6';
    LET vsistema        = '01';
    LET vusuario        = user;
    LET vexiste_fecha   = 0;
    
    LET vcodretparam    = '';    
    LET vserial_inicial = 0;
    LET vserial_final   = 0;
    LET vcomienza       = -1;
    LET vcont_commit    = 0;
    LET vnum_serial     = 0;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/pasamovshistoldcomp6.err";
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold6.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold6.sql';
            SYSTEM vstmt;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/pasamovshistoldcomp6.out";
    --- TRACE ON;
    
    SET OPTIMIZATION HIGH;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE LAS FECHAS DEL SISTEMA
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    SELECT valor
      INTO vfecha_ant
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'PasoMovhis_MovhisOld';
       
    SELECT valor
      INTO vfecha_borrado
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'BorraRegistrosMovhis';
    
    -- // VALIDA HAYA INICIADO EL PROCESO PRINCIPAL
    WHILE vfechaproc = 0
        SET ISOLATION TO DIRTY READ;
    
        SELECT COUNT(*)
          INTO vfechaproc
          FROM sc_contproc
         WHERE empresa = pempresa
           AND proceso = 'ini_pasomovshistold'
           AND fecha = vfecha_ant;
    END WHILE;
      
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
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horaspasamovsold6.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold6.sql';
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold6.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold6.sql';
            SYSTEM vstmt;
        ELSE
            SELECT "1"
              INTO vexistefinproc
              FROM sc_contproc
             WHERE empresa = pempresa
               AND proceso = "pasomovshistoldcomp6"
               AND fecha = vfecha_ant;
               
            IF vexistefinproc = "1" THEN
                LET vcodret1 = "958";
                RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
            END IF
        END IF;
    END IF;
    
    -- // OBTIENE VALORES PARA RANGO DE SERIALES A PROCESAR
    SELECT valor::integer
      INTO vserial_inicial
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'SerIniPasoMovHisOld6';
       
    SELECT valor::integer
      INTO vserial_final
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'SerIniPasoMovHisOld7';
       
    -- // OBTIENE EL NUMERO DE REGISTROS A TRASPASAR
    SELECT {+INDEX(sc_movhis idx_movhis_serial)}
           COUNT(*)
      INTO vcontador1
      FROM sc_movhis
     WHERE fech_alt = vfecha_ant
       AND num_serial >= vserial_inicial
       AND num_serial < vserial_final;
    
    FOREACH WITH HOLD 
        SELECT {+INDEX(sc_movhis idx_movhis_serial)}
               num_serial
          INTO vnum_serial
          FROM sc_movhis
         WHERE fech_alt = vfecha_ant
           AND num_serial >= vserial_inicial
           AND num_serial < vserial_final
           
        BEGIN WORK;
        LET ven_transacc = 1;
        
        IF vfecha_ant > vfecha_borrado THEN 
            INSERT INTO sc_movhis_old
            SELECT {+INDEX(sc_movhis idx_movhis_serial)}
                   mov.*
              FROM sc_movhis mov
             WHERE mov.fech_alt = vfecha_ant
               AND mov.num_serial = vnum_serial;
             
            DELETE {+INDEX(sc_movhis idx_movhis_serial)}
              FROM sc_movhis
             WHERE fech_alt = vfecha_ant
               AND num_serial = vnum_serial;
        ELSE
            DELETE {+INDEX(sc_movhis idx_movhis_serial)}
              FROM sc_movhis
             WHERE fech_alt = vfecha_ant
               AND num_serial = vnum_serial;
        END IF;
         
        LET vcont_commit = vcont_commit + 1;
        
        COMMIT WORK;
        LET ven_transacc = 0;
    END FOREACH;
    
    SELECT {+INDEX(sc_movhis_old idx_movhis_serial_old)}
           COUNT(*)
      INTO vcontador2
      FROM sc_movhis_old
     WHERE fech_alt = vfecha_ant
       AND num_serial >= vserial_inicial
       AND num_serial < vserial_final;
     
    SELECT {+INDEX(sc_movhis idx_movhis_serial)}
           COUNT(*)
      INTO vcontador3
      FROM sc_movhis
     WHERE fech_alt = vfecha_ant
       AND num_serial >= vserial_inicial
       AND num_serial < vserial_final;
       
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
                   'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold6.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold6.sql';
        SYSTEM vstmt;
           
        UPDATE sc_contproc
           SET fecha   = vfecha_ant
         WHERE empresa = pempresa
           AND proceso = 'pasomovshistoldcomp6';
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
                   'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold6.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold6.sql';
        SYSTEM vstmt;
    END IF;
       
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;

END PROCEDURE;