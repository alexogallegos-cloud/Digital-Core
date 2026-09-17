CREATE PROCEDURE "informix".gen_archsdos_comp3_mes()
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;
     
    DEFINE vcodret1         char(5);
    DEFINE vcodret2         char(5);
    DEFINE vcodret3         char(50);
    DEFINE sql_err          integer;
    DEFINE isam_err         integer;
    DEFINE desc_err         char(50);
    DEFINE vcontador1       integer;
    DEFINE vcontador2       integer;
    DEFINE ven_transacc     smallint;
    DEFINE vcomienza        smallint;
    DEFINE vsql             char(600);
    DEFINE vstmt            char(300);
    DEFINE vempresa         char(3);
    DEFINE vproceso         char(10);
    DEFINE vsistema         char(2);
    DEFINE vusuario         char(20);
    DEFINE vfecha_hoy       date;
    DEFINE vpri_dia_mes     date; 
    DEFINE vult_dia_mes_ant date;
    DEFINE vdia_fin_mes_ant char(2);
    DEFINE vmes             char(2);
    DEFINE vanio            char(4);
    DEFINE vaniomes         char(6);
    DEFINE vexiste          smallint;
    DEFINE vexistefin       smallint;
    DEFINE vcuentafin       char(20);
    DEFINE vcuenta          char(20);
    DEFINE vsucursal        char(4);
    DEFINE vsdo_mes_ant     decimal(14,2);
    DEFINE vint_mes_ant     decimal(14,2);
    DEFINE vcodretmes       char(5);
    DEFINE vcodretrim       char(5);
    
    LET vcodret1         = "000";               
    LET vcodret2         = '000';
    LET vcodret3         = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err          = 0;                   
    LET isam_err         = 0;
    LET desc_err         = '';
    LET vcontador1       = 0;                   
    LET vcontador2       = 0;
    LET ven_transacc     = 0;                   
    LET vcomienza        = -1;  
    LET vsql             = '';                  
    LET vstmt            = '';
    LET vempresa         = '001';
    LET vproceso         = 'sdochqmes3';
    LET vsistema         = '01';
    LET vusuario         = user;
    LET vfecha_hoy       = '';
    LET vpri_dia_mes     = '';
    LET vult_dia_mes_ant = '';
    LET vdia_fin_mes_ant = '';
    LET vmes             = '';                  
    LET vanio            = '';  
    LET vaniomes         = '';
    LET vexiste          = 0;                   
    LET vexistefin       = 0;        
    LET vcuentafin       = '';
    LET vcuenta          = '';                  
    LET vsucursal        = '';
    LET vsdo_mes_ant     = 0.00;
    LET vint_mes_ant     = 0.00;
    LET vcodretmes       = '';
    LET vcodretrim       = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/gen_archsdos_comp3_mes.err";
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
                       'WHERE empresa = '''||vempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horassdosmes3.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosmes3.sql';
            SYSTEM vstmt;  
            RETURN vcodret1, vcodret2, vcodret3, vcontador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/gen_archsdos_comp3_mes.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy, pri_dia_mes
      INTO vfecha_hoy, vpri_dia_mes
      FROM sc_fechas
     WHERE empresa = vempresa;
     
    LET vult_dia_mes_ant = vpri_dia_mes - 1 UNITS DAY;
    LET vdia_fin_mes_ant = LPAD(DAY(vult_dia_mes_ant), 2, '0');
    LET vanio = YEAR(vult_dia_mes_ant);
    LET vmes = LPAD(MONTH(vult_dia_mes_ant), 2, '0');
    LET vaniomes = vanio||vmes;
	 	 
    SELECT count(*)
      INTO vexiste
      FROM bdinteg:sx_contproc
     WHERE empresa = vempresa
       AND proceso = vproceso
       AND fecha   = vfecha_hoy
       AND sistema = vsistema;

    IF vexiste = 0 THEN
        LET vsql = 'echo "INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||vempresa||''', '''||vproceso||''', '''||vfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||vusuario||''', '||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horassdosmes3.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosmes3.sql';
        SYSTEM vstmt;
    ELSE
        SELECT count(*)
          INTO vexistefin
          FROM bdinteg:sx_contproc
         WHERE empresa     = vempresa
           AND proceso     = vproceso
           AND fecha       = vfecha_hoy
           AND sistema     = vsistema
           AND status_proc = "F";

        IF vexistefin = 0 THEN
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'I'||''','||
                       'codret        = '''||' '||''','||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||vempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horassdosmes3.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosmes3.sql';
            SYSTEM vstmt;
        ELSE
            LET vcodret1 = "958";
            LET vcodret2 = "958";
            
            SELECT descripcion
              INTO vcodret3
              FROM bdinteg:si_codret
             WHERE sistema = vsistema
               AND codigo_retorno = vcodret1;
            
            RETURN vcodret1, vcodret2, vcodret3, vcontador1;
        END IF;
    END IF;
    
    IF vdia_fin_mes_ant = '28' THEN
        FOREACH WITH HOLD
            SELECT {+INDEX(sc_sdodiarioc isdodiario)}
                   cuenta, sucursal, capvig28, intprovnp28
              INTO vcuenta, vsucursal, vsdo_mes_ant, vint_mes_ant
              FROM sc_sdodiarioc
             WHERE cuenta LIKE '11%'
               AND aniomes = vaniomes
               AND statuscta28 IN('1','3','4','5','6','8')
               
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                BEGIN WORK;
                LET ven_transacc = 1; 
            END IF;
               
            CALL sp_actsdomensualc(vcuenta, vsucursal, vsdo_mes_ant, vint_mes_ant, vanio, vmes) 
            RETURNING vcodretmes;
            
            IF vmes = '03' OR  vmes ='06' OR  vmes ='09' OR vmes = '12' THEN
                CALL sp_actsdotrimestralc(vcuenta, vsucursal, vanio, vmes)
                RETURNING vcodretrim;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador2 = vcontador2 + 1;

            IF (vcontador2 >= 1000) THEN
                LET vcontador2 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
        END FOREACH;
    ELIF vdia_fin_mes_ant = '29' THEN
        FOREACH WITH HOLD
            SELECT {+INDEX(sc_sdodiarioc isdodiario)}
                   cuenta, sucursal, capvig29, intprovnp29
              INTO vcuenta, vsucursal, vsdo_mes_ant, vint_mes_ant
              FROM sc_sdodiarioc
             WHERE cuenta LIKE '11%'
               AND aniomes = vaniomes
               AND statuscta29 IN('1','3','4','5','6','8')
               
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                BEGIN WORK;
                LET ven_transacc = 1; 
            END IF;
               
            CALL sp_actsdomensualc(vcuenta, vsucursal, vsdo_mes_ant, vint_mes_ant, vanio, vmes) 
            RETURNING vcodretmes;
            
            IF vmes = '03' OR  vmes ='06' OR  vmes ='09' OR vmes = '12' THEN
                CALL sp_actsdotrimestralc(vcuenta, vsucursal, vanio, vmes)
                RETURNING vcodretrim;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador2 = vcontador2 + 1;

            IF (vcontador2 >= 1000) THEN
                LET vcontador2 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
        END FOREACH;
    ELIF vdia_fin_mes_ant = '30' THEN
        FOREACH WITH HOLD
            SELECT {+INDEX(sc_sdodiarioc isdodiario)}
                   cuenta, sucursal, capvig30, intprovnp30
              INTO vcuenta, vsucursal, vsdo_mes_ant, vint_mes_ant
              FROM sc_sdodiarioc
             WHERE cuenta LIKE '11%'
               AND aniomes = vaniomes
               AND statuscta30 IN('1','3','4','5','6','8')
               
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                BEGIN WORK;
                LET ven_transacc = 1; 
            END IF;
               
            CALL sp_actsdomensualc(vcuenta, vsucursal, vsdo_mes_ant, vint_mes_ant, vanio, vmes) 
            RETURNING vcodretmes;
            
            IF vmes = '03' OR  vmes ='06' OR  vmes ='09' OR vmes = '12' THEN
                CALL sp_actsdotrimestralc(vcuenta, vsucursal, vanio, vmes)
                RETURNING vcodretrim;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador2 = vcontador2 + 1;

            IF (vcontador2 >= 1000) THEN
                LET vcontador2 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
        END FOREACH;
    ELIF vdia_fin_mes_ant = '31' THEN
        FOREACH WITH HOLD
            SELECT {+INDEX(sc_sdodiarioc isdodiario)}
                   cuenta, sucursal, capvig31, intprovnp31
              INTO vcuenta, vsucursal, vsdo_mes_ant, vint_mes_ant
              FROM sc_sdodiarioc
             WHERE cuenta LIKE '11%'
               AND aniomes = vaniomes
               AND statuscta31 IN('1','3','4','5','6','8')
               
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                BEGIN WORK;
                LET ven_transacc = 1; 
            END IF;
               
            CALL sp_actsdomensualc(vcuenta, vsucursal, vsdo_mes_ant, vint_mes_ant, vanio, vmes) 
            RETURNING vcodretmes;
            
            IF vmes = '03' OR  vmes ='06' OR  vmes ='09' OR vmes = '12' THEN
                CALL sp_actsdotrimestralc(vcuenta, vsucursal, vanio, vmes)
                RETURNING vcodretrim;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador2 = vcontador2 + 1;

            IF (vcontador2 >= 1000) THEN
                LET vcontador2 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
        END FOREACH;
    END IF;
            
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET ejecutivo = '''||vusuario||''','||
               'status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret1||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||vempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horassdosmes.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosmes.sql';
    SYSTEM vstmt;
    
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1;

END PROCEDURE;