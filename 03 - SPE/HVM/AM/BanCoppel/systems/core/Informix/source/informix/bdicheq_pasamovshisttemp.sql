CREATE PROCEDURE "informix".pasamovshisttemp(pempresa CHAR(3))

RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcuantos         INTEGER;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vfecha           DATE;
    DEFINE vfecha2          CHAR(10);
    DEFINE vexiste          SMALLINT;
    DEFINE vexistefin       SMALLINT;
    DEFINE vmin_cta         CHAR(20);
    DEFINE vmax_cta         CHAR(20);
    DEFINE vcuenta          CHAR(20);
    DEFINE vsql             char(600);
    DEFINE vstmt            char(250);
    
    LET vcodret1        = '000';
    LET vcodret2        = '000';
    LET sql_err	        = 0;
    LET isam_err        = 0;
    LET vcomienza       = -1;
    LET vcontador1      = 0;
    LET vcontador2      = 0;
    LET vcuantos        = 0;
    LET ven_transacc    = 0; 
    
    LET vfecha          = ''; 
    LET vfecha2         = '';
    LET vexiste         = 0;
    LET vexistefin      = 0;
    LET vmin_cta        = '';
    LET vmax_cta        = '';
    LET vcuenta         = ''; 
    LET vsql            = '';
    LET vstmt           = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/pasamovshisttemp.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            
            LET vsql = 'echo "UPDATE {+INDEX(bdinteg:sx_contproc idx_xcontproc1)} bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||'informix'||''','||
                       'status_proc   = '''||'C'||''','||
                       'codret        = '''||vcodret1||''','||
                       'hora_fin      = (SELECT {+INDEX(bdicheq:sc:fechas idx_fechas1)} CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas where empresa = "001") '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||'PasaMovsHistTemp'||''' '||
                       'AND fecha     = '''||vfecha||''' '||
                       'AND sistema   = '''||'01'||''';" > /tmp/horaspasamovstmp.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovstmp.sql';
            SYSTEM vstmt;
            
            RETURN vcodret1, vcodret2, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;

    -- SET DEBUG FILE TO "/resplogifx/conciliachq/pasamovshisttemp.out";
    -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    
    -- // OBTIENE LAS FECHAS DEL SISTEMA
    SELECT {+INDEX(sc_param idx_param1 )} valor 
      INTO vfecha
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'PasoMovhis_MovhisTmp';
     
    -- // Guarda inicio de proceso     
    SELECT {+INDEX(bdinteg:sx_contproc idx_xcontproc1)} COUNT(*)
      INTO vexiste
      FROM bdinteg:sx_contproc
     WHERE empresa = pempresa
       AND proceso = 'PasaMovsHistTemp'
       AND fecha   = vfecha
       AND sistema = '01';

    IF vexiste = 0 THEN
        LET vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||'PasaMovsHistTemp'||''', '''||vfecha||''', '''||'01'||''', '''||'I'||''', '''||'informix'||''','||
                   '(SELECT {+INDEX(bdicheq:sc:fechas idx_fechas1)} CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas where empresa = "001"), NULL, NULL);" > /tmp/horaspasamovstmp.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovstmp.sql';
        SYSTEM vstmt;
    ELSE
        SELECT {+INDEX(bdinteg:sx_contproc idx_xcontproc1)} COUNT(*)
          INTO vexistefin
          FROM bdinteg:sx_contproc
         WHERE empresa = pempresa
           AND proceso = 'PasaMovsHistTemp'
           AND fecha   = vfecha
           AND sistema = '01'
           AND (status_proc = "F" OR codret = '958');
    
        IF vexistefin = 0 THEN
            LET vsql = 'echo "UPDATE {+INDEX(bdinteg:sx_contproc idx_xcontproc1)} bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||'informix'||''','||
                       'status_proc   = '''||'I'||''','||
                       'codret        = '''||' '||''','||
                       'hora_fin      = '''||' '||''','||
                       'hora_ini      = (SELECT {+INDEX(bdicheq:sc:fechas idx_fechas1)} CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas where empresa = "001") '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||'PasaMovsHistTemp'||''' '||
                       'AND fecha     = '''||vfecha||''' '||
                       'AND sistema   = '''||'01'||''';" > /tmp/horaspasamovstmp.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovstmp.sql';
            SYSTEM vstmt;
        ELSE
            LET vcodret1 = "958";
            
            LET vsql = 'echo "UPDATE {+INDEX(bdinteg:sx_contproc idx_xcontproc1)} bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||'informix'||''','||
                       'status_proc   = '''||'C'||''','||
                       'codret        = '''||vcodret1||''','||
                       'hora_fin      = (SELECT {+INDEX(bdicheq:sc:fechas idx_fechas1)} CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas where empresa = "001") '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||'PasaMovsHistTemp'||''' '||
                       'AND fecha     = '''||vfecha||''' '||
                       'AND sistema   = '''||'01'||''';" > /tmp/horaspasamovstmp.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovstmp.sql';
            SYSTEM vstmt;
            
            RETURN vcodret1, vcodret2, vcontador1, vcontador2;
        END IF;
    END IF;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmin_cta, vmax_cta
      FROM sc_movhis;
      
    SELECT 
           COUNT(*)
      INTO vcontador1
      FROM sc_movhis
     WHERE fech_alt = vfecha; 
       
    FOREACH WITH HOLD 
        SELECT 
               UNIQUE cuenta
          INTO vcuenta
          FROM sc_movhis
         WHERE fech_alt = vfecha
           AND producto NOT IN('1200','1600','9900','9901')
           
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        INSERT INTO sc_movhis_temp
        SELECT {+INDEX(sc_movhis idx_movhisnew1)} mov.*
          FROM sc_movhis mov
         WHERE mov.empresa = pempresa
           AND mov.cuenta = vcuenta
           AND mov.fech_alt = vfecha;
           
        LET vcontador2 = vcontador2 + 1;
        
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        LET vcomienza = -1;
        COMMIT WORK;
    END IF;
    
    FOREACH WITH HOLD 
        SELECT 
               UNIQUE cuenta
          INTO vcuenta
          FROM sc_movhis
         WHERE fech_alt = vfecha
           AND producto IN('1200','1600','9900','9901')
           
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        INSERT INTO sc_movhis_temp
        SELECT {+INDEX(sc_movhis idx_movhisnew1)} mov.*
          FROM sc_movhis mov
         WHERE mov.empresa = pempresa
           AND mov.cuenta = vcuenta
           AND mov.fech_alt = vfecha;
           
        LET vcontador2 = vcontador2 + 1;
        
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    LET vfecha2 = TO_CHAR(vfecha + 1 UNITS DAY, '%m/%d/%Y');
    
    IF vcodret1 = '000' THEN
        UPDATE {+INDEX(sc_param idx_param1)} sc_param
           SET valor = vfecha2
         WHERE empresa = '001'
           AND codparam = 'PasoMovhis_MovhisTmp';
           
        LET vsql = 'echo "UPDATE {+INDEX(bdinteg:sx_contproc idx_xcontproc1)} bdinteg:sx_contproc '||
                   'SET ejecutivo = '''||'informix'||''','||
                   'status_proc   = '''||'F'||''','||
                   'codret        = '''||vcodret1||''','||
                   'hora_fin      = (SELECT {+INDEX(bdicheq:sc:fechas idx_fechas1)} CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas where empresa = "001") '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||'PasaMovsHistTemp'||''' '||
                   'AND fecha     = '''||vfecha||''' '||
                   'AND sistema   = '''||'01'||''';" > /tmp/horaspasamovstmp.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovstmp.sql';
        SYSTEM vstmt;
    ELSE
    
        LET vsql = 'echo "UPDATE {+INDEX(bdinteg:sx_contproc idx_xcontproc1)} bdinteg:sx_contproc '||
                   'SET ejecutivo = '''||'informix'||''','||
                   'status_proc   = '''||'C'||''','||
                   'codret        = '''||vcodret1||''','||
                   'hora_fin      = (SELECT {+INDEX(bdicheq:sc:fechas idx_fechas1)} CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas where empresa = "001") '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||'PasaMovsHistTemp'||''' '||
                   'AND fecha     = '''||vfecha||''' '||
                   'AND sistema   = '''||'01'||''';" > /tmp/horaspasamovstmp.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovstmp.sql';
        SYSTEM vstmt;
    END IF;
       
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE;