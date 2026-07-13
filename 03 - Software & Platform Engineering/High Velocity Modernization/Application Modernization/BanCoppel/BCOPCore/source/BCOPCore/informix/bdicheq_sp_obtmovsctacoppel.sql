CREATE PROCEDURE "informix".sp_obtmovsctacoppel(pempresa CHAR(3))

RETURNING CHAR(5), CHAR(5);

    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    
    DEFINE vfecha_ant   CHAR(10);
    DEFINE vfecha_mov   CHAR(10);
    DEFINE vtransacc    CHAR(4);
    DEFINE vdescripcion CHAR(40);
    DEFINE vmonto       MONEY(18,2);
    
    DEFINE vsql         CHAR(500);
    DEFINE vfechades    CHAR(8);
    DEFINE vdia         CHAR(2);
    DEFINE vmes         CHAR(2);
    DEFINE vanio        CHAR(4);
    
    LET vcodret1    = '000';
    LET vcodret2    = '000';
    LET sql_err	    = 0;
    LET isam_err    = 0;
    
    LET vsql       = '';
    LET vfecha_ant = '';
    LET vfechades  = '';
    LET vdia       = '';
    LET vmes       = '';
    LET vanio      = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtmovsctacoppel.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            RETURN vcodret1, vcodret2;
        END IF;
    END EXCEPTION;
    
    -- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtmovsctacoppel.out";
    -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  
                WHERE partnum BETWEEN (SELECT MIN(partnum) FROM sysmaster:systabnames) AND
                                      (SELECT MAX(partnum) FROM sysmaster:systabnames)
                  AND tabname = 'movsctacoppel') THEN
        DROP TABLE bdicheq:"informix".movsctacoppel;
    END IF;
    
    CREATE RAW TABLE bdicheq:"informix".movsctacoppel(
        fecha                   CHAR(10),
        transacc                CHAR(4),
        descripcion             CHAR(40),
        monto                   MONEY(18,2))
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  
                WHERE partnum BETWEEN (SELECT MIN(partnum) FROM sysmaster:systabnames) AND
                                      (SELECT MAX(partnum) FROM sysmaster:systabnames)
                  AND tabname = 'movsctatelmex') THEN
        DROP TABLE bdicheq:"informix".movsctatelmex;
    END IF;
    
    CREATE RAW TABLE bdicheq:"informix".movsctatelmex(
        fecha                   CHAR(10),
        transacc                CHAR(4),
        descripcion             CHAR(40),
        monto                   MONEY(18,2))
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    
    SELECT fecha_ant
      INTO vfecha_ant
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    FOREACH
        select {+INDEX(sc_movhis idx_movhisnew4), +INDEX(bdinteg:si_transacc idx_transacc1)}
               vfecha_ant, m.transacc, t.descripcion, sum(m.monto_tot)
          into vfecha_mov, vtransacc, vdescripcion, vmonto
          from bdicheq:sc_movhis m, 
               bdinteg:si_transacc t
         where m.empresa = '001'
           and m.cuenta = '16000000012'
           and m.fech_alt = vfecha_ant
           and m.cancelad != 'S'
           and m.transacc = t.numero
           and t.empresa = m.empresa
           and t.numero = m.transacc
         group by m.transacc, t.descripcion
         order by m.transacc
         
        insert into movsctacoppel values(vfecha_mov, vtransacc, vdescripcion, vmonto);
    END FOREACH
    
    FOREACH
        select {+INDEX(sc_movhis idx_movhisnew4), +INDEX(bdinteg:si_transacc idx_transacc1)}
               vfecha_ant, m.transacc, t.descripcion, sum(m.monto_tot)
          into vfecha_mov, vtransacc, vdescripcion, vmonto
          from bdicheq:sc_movhis m, 
               bdinteg:si_transacc t
         where m.empresa = '001'
           and m.cuenta = '99010000012'
           and m.fech_alt = vfecha_ant
           and m.cancelad != 'S'
           and m.transacc = t.numero
           and t.empresa = m.empresa
           and t.numero = m.transacc
         group by m.transacc, t.descripcion
         order by m.transacc
         
        insert into movsctatelmex values(vfecha_mov, vtransacc, vdescripcion, vmonto);
    END FOREACH
    
    LET vfecha_ant = vfecha_ant;
    LET vdia  = SUBSTR(vfecha_ant, 4, 2);
    LET vmes  = SUBSTR(vfecha_ant, 1, 2);
    LET vanio = SUBSTR(vfecha_ant, 7, 4);
    LET vdia  = vdia;
    LET vmes  = vmes;
    LET vanio = vanio;
    LET vfechades = vmes||vdia||vanio;
    
    LET vsql = '';
    LET vsql = 'echo "unload to /resplogifx/conciliachq/movsctacoppel_'||vfechades||'.txt '||
               ' select * from movsctacoppel;" > /resplogifx/conciliachq/movscoppel.sql';
    SYSTEM vsql;
    LET vsql = '';
    -- LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/movscoppel.sql"; 
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/movscoppel.sql"; 
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = 'echo "unload to /resplogifx/conciliachq/movsctatelmex_'||vfechades||'.txt '||
               ' select * from movsctatelmex;" > /resplogifx/conciliachq/movstelmex.sql';
    SYSTEM vsql;
    LET vsql = '';
    -- LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/movstelmex.sql"; 
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/movstelmex.sql"; 
    SYSTEM vsql;

    END;

    RETURN vcodret1, vcodret2;

END PROCEDURE;