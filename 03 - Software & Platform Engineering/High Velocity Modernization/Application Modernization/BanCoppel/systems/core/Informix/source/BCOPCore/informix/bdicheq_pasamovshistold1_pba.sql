CREATE PROCEDURE "informix".pasamovshistold1_pba( pempresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE info_err         CHAR(40);
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha           DATE;
    DEFINE vdias            INTEGER;
    DEFINE vfecha2          CHAR(10);
    DEFINE vexiste          SMALLINT;
    DEFINE vexistefin       SMALLINT;
    DEFINE vcuenta          CHAR(20);
    DEFINE veliminados      INTEGER;
    DEFINE vproceso         CHAR(20);
    DEFINE vsistema         CHAR(2);
    DEFINE vusuario         CHAR(8);
    DEFINE vsql             CHAR(600);
    DEFINE vstmt            CHAR(250);
    DEFINE vborrado         CHAR(1);
    
    LET vcodret1     = '000';
    LET vcodret2     = '000';
    LET vcodret3     = '';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET info_err     = '';
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vcontador3   = 0;
    LET ven_transacc = 0; 
    
    LET vfecha_hoy  = '';
    LET vfecha      = ''; 
    LET vdias       = 0;
    LET vfecha2     = '';
    LET vexiste     = 0;
    LET vexistefin  = 0;
    LET vcuenta     = ''; 
    LET veliminados = 0;
    LET vproceso    = 'PasaMovsHistOld1';  
    LET vsistema    = '01';
    LET vusuario    = 'informix';
    LET vsql        = '';
    LET vstmt       = '';
    LET vborrado    = '0';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, info_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/pasamovshistold1.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = info_err;
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
                       'AND fecha     = '''||vfecha||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold.sql';
            SYSTEM vstmt;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/pasamovshistold1.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 10;
    
    -- // OBTIENE LAS FECHAS DEL SISTEMA
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    SELECT valor 
      INTO vfecha
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'PasoMovhis_MovhisOld';
       
    -- // VALIDA CUANTOS DIAS TIENE EL HISTORICO DE MOVIMIENTOS
    LET vdias = vfecha_hoy - vfecha;
    
    IF vdias <= 31 THEN
        LET vcodret1 = '111';
        LET vcodret2 = '111';
        LET vcodret3 = 'EL HISTORICO NO TIENE MAS DE 31 DIAS';
        RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
    END IF;
     
    -- // Guarda inicio de proceso     
    SELECT COUNT(*)
      INTO vexiste
      FROM bdinteg:sx_contproc
     WHERE empresa = pempresa
       AND proceso = 'PasaMovsHistOld1'
       AND fecha   = vfecha
       AND sistema = '01';

    IF vexiste = 0 THEN
        LET vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso||''', '''||vfecha||''', '''||vsistema||''', '''||'I'||''', '''||vusuario||''','||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horaspasamovsold.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold.sql';
        SYSTEM vstmt;
    ELSE
        SELECT COUNT(*)
          INTO vexistefin
          FROM bdinteg:sx_contproc
         WHERE empresa = pempresa
           AND proceso = 'PasaMovsHistOld1'
           AND fecha   = vfecha
           AND sistema = '01'
           AND status_proc = 'F';
    
        IF vexistefin = 0 THEN
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'I'||''','||
                       'codret        = '''||' '||''','||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold.sql';
            SYSTEM vsql;            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold.sql';
            SYSTEM vstmt;
        ELSE
            LET vcodret1 = '958';
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'F'||''','||
                       'codret        = '''||vcodret1||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold.sql';
            SYSTEM vstmt;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
        END IF;
    END IF;
    
    -- // NUMERO DE REGISTROS A TRASPASAR
    SELECT {+INDEX(sc_movhis idx_movhisnew6)} 
           COUNT(*)
      INTO vcontador1
      FROM sc_movhis
     WHERE fech_alt = vfecha; 
       
    -- // TRASPASA MOVIMIENTOS 
    FOREACH WITH HOLD 
        SELECT {+INDEX(sc_movhis idx_movhisnew6)} 
               UNIQUE cuenta
          INTO vcuenta
          FROM sc_movhis
         WHERE fech_alt = vfecha
           AND producto NOT IN('1200','1600','9900','9901')
           
        BEGIN WORK;
        LET ven_transacc = 1; 
        
        IF vfecha > '05/08/2012' THEN
            INSERT INTO sc_movhis_old
            ---SELECT {+INDEX(sc_movhis idx_movhisnew1)} 
            SELECT {+INDEX(sc_movhis idx_sc_movhis8)} 
                   mov.*
              FROM sc_movhis mov
             ---WHERE mov.empresa = pempresa
             WHERE mov.cuenta = vcuenta
               AND mov.fech_alt = vfecha;
        END IF;
           
        LET vborrado = '0';
           
        WHILE vborrado = '0'
            CALL borramovshistold1(pempresa, vcuenta, vfecha)
            RETURNING vcodret1, vcodret2, veliminados;
            
            IF vcodret1 = '000' THEN
                LET vborrado = '1';
            ELSE 
                LET vborrado = '0';
            END IF;
        END WHILE;
        
        LET vcontador3 = vcontador3 + veliminados;
        
        COMMIT WORK;
        LET ven_transacc = 0; 
    END FOREACH;
    
    -- // TRASPASA MOVIMIENTOS 
    FOREACH WITH HOLD 
        SELECT {+INDEX(sc_movhis idx_movhisnew6)} 
               UNIQUE cuenta
          INTO vcuenta
          FROM sc_movhis
         WHERE fech_alt = vfecha
           
        BEGIN WORK;
        LET ven_transacc = 1; 
           
        IF vfecha > '05/08/2012' THEN
            INSERT INTO sc_movhis_old
            ---SELECT {+INDEX(sc_movhis idx_movhisnew1)} 
            SELECT {+INDEX(sc_movhis idx_sc_movhis8)}
                   mov.*
              FROM sc_movhis mov
             ---WHERE mov.empresa = pempresa
             ---  AND mov.cuenta = vcuenta
                WHERE mov.cuenta = vcuenta
               AND mov.fech_alt = vfecha;
        END IF;
           
        LET vborrado = '0';
           
        WHILE vborrado = '0'
            CALL borramovshistold1(pempresa, vcuenta, vfecha)
            RETURNING vcodret1, vcodret2, veliminados;
            
            IF vcodret1 = '000' THEN
                LET vborrado = '1';
            ELSE 
                LET vborrado = '0';
            END IF;
        END WHILE;
           
        LET vcontador3 = vcontador3 + veliminados;
        
        COMMIT WORK;
        LET ven_transacc = 0; 
    END FOREACH;
    
    -- // NUMERO DE REGISTROS TRASPASADOS
    SELECT {+INDEX(sc_movhis_old idx_movhisnew6_old)} 
           COUNT(*)
      INTO vcontador2
      FROM sc_movhis_old
     WHERE fech_alt = vfecha; 
     
    -- // ACTUALIZA PARAMETROS FINALES
    IF vcontador1 = vcontador2 THEN
        LET vfecha2 = to_char(vfecha + 1 UNITS DAY, '%m/%d/%Y');
    
        UPDATE sc_param
           SET valor = vfecha2
         WHERE empresa = pempresa
           AND codparam = 'fechcon_movhis';
           
        UPDATE sc_param
           SET valor = vfecha2
         WHERE empresa = pempresa
           AND codparam = 'PasoMovhis_MovhisOld';
           
        LET vcodret1 = '000';
        LET vcodret2 = '000';
        LET vcodret3 = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
        
        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET status_proc   = '''||'F'||''','||
                   'codret        = '''||vcodret1||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vfecha||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold.sql';
        SYSTEM vstmt;
    ELSE
        LET vcodret1 = '999';
        LET vcodret2 = '999';
        LET vcodret3 = 'LOS MOVS TRASP NO COINCIDEN CON LOS MOVS ORIG';
        
        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET status_proc   = '''||'C'||''','||
                   'codret        = '''||vcodret1||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vfecha||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold.sql';
        SYSTEM vstmt;
    END IF;
       
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;

END PROCEDURE;