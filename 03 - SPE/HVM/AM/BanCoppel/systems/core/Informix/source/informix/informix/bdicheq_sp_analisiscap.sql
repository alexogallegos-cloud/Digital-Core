CREATE PROCEDURE "informix".sp_analisiscap()
RETURNING CHAR(5);
      
    DEFINE Sql_Err              INTEGER;
    DEFINE Isam_Err             INTEGER;
    DEFINE Desc_Err             CHAR(50);
    DEFINE vCodRet1             CHAR(5);
    DEFINE vCodRet2             CHAR(5);
    DEFINE vCodRet3             CHAR(50);
    DEFINE vComienza            INTEGER;
    DEFINE vEnTransacc          SMALLINT;
    DEFINE vContador1           INTEGER;
    DEFINE vsql                 CHAR(600);
    DEFINE vstmt                CHAR(600);
    DEFINE vFechaHoy            DATE;
    DEFINE vPriDiaMes           DATE;
    DEFINE vFechaIni            DATE;
    DEFINE vFechaFin            DATE;
    DEFINE vFechaAniomes        DATE;
    DEFINE vAnio                CHAR(4);
    DEFINE vMes                 CHAR(2);
    DEFINE vAnioMes             CHAR(6);
    DEFINE vResiduo             SMALLINT;
    DEFINE vAniobase            SMALLINT;
    DEFINE vFechaConsMovhis     CHAR(10);
    DEFINE vFechaConsMovhisOld  CHAR(10);
    DEFINE vContCtes            INTEGER;
    DEFINE vNumCte              CHAR(20);
    DEFINE vFechaAlta           DATE;
    DEFINE vTipoPer             CHAR(2);
    DEFINE vFechaNac            DATE;
    DEFINE vFechaNacim          CHAR(10);
    DEFINE vFechaApertura       CHAR(10);
    DEFINE vRegFiscal           CHAR(1);
    DEFINE vTipoDepositante     CHAR(4);
    DEFINE vExsiteBPI           SMALLINT;
    DEFINE vBPI                 CHAR(1);
    DEFINE vExisteCtaChq        SMALLINT;
    DEFINE vCheques             CHAR(1);
    DEFINE vExisteCred          SMALLINT;
    DEFINE vExisteCredCrd       SMALLINT;
    DEFINE vCredito             CHAR(1);
    DEFINE vDepositos           DECIMAL(18,2);
    DEFINE vDepositosOld        DECIMAL(18,2);
    DEFINE vCargos              DECIMAL(18,2);
    DEFINE vCargosOld           DECIMAL(18,2);
    DEFINE vSdoInicial          DECIMAL(18,2);
    DEFINE vSdoFinal            DECIMAL(18,2);
    
    DEFINE vexiste              INTEGER;
    DEFINE vexistefin           INTEGER;
    DEFINE pempresa             CHAR(3);
    DEFINE vproceso             CHAR(20);
    DEFINE vsistema             CHAR(2);
    DEFINE vusuario             CHAR(8);
    
    LET Sql_Err	             = 0;
    LET Isam_Err             = 0;
    LET Desc_Err             = '';
    LET vCodRet1             = '000';
    LET vCodRet2             = '';
    LET vCodRet3             = '';
    LET vComienza            = -1;
    LET vEnTransacc          = 0;
    LET vContador1           = 0;
    LET vsql                 = '';
    LET vstmt                = '';
    LET vFechaHoy            = '';
    LET vPriDiaMes           = '';
    LET vFechaIni            = '';
    LET vFechaFin            = '';
    LET vFechaAniomes        = '';
    LET vAnio                = '';
    LET vMes                 = '';
    LET vAnioMes             = '';
    LET vResiduo             = 0;
    LET vAniobase            = 0;
    LET vFechaConsMovhis     = '';
    LET vFechaConsMovhisOld  = '';
    LET vContCtes            = 0;
    LET vNumCte              = '';
    LET vFechaAlta           = '';
    LET vTipoPer             = '';
    LET vFechaNac            = '';
    LET vFechaNacim          = '';
    LET vFechaApertura       = '';
    LET vRegFiscal           = '';
    LET vTipoDepositante     = '';
    LET vExsiteBPI           = 0;
    LET vBPI                 = '';
    LET vExisteCtaChq        = 0;
    LET vCheques             = '0';
    LET vExisteCred          = 0;
    LET vExisteCredCrd       = 0;
    LET vCredito             = '';
    LET vDepositos           = 0.00;
    LET vDepositosOld        = 0.00;
    LET vCargos              = 0.00;
    LET vCargosOld           = 0.00;
    LET vSdoInicial          = 0.00;
    LET vSdoFinal            = 0.00;
    
    LET vexiste              = 0;
    LET vexistefin           = 0;
    LET pempresa             = '001';
    LET vproceso             = 'RepAnalisisCaptacion';
    LET vsistema             = '01';
    LET vusuario             = 'informix';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/riesgos/sp_analisiscap.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            LET vCodRet1 = '999';
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-668)
        LET vcodret1 = '668';
    END EXCEPTION WITH RESUME;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/riesgos/sp_analisiscap.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // OBTINENE FECHAS DEL SISTEMA
    SELECT fecha_hoy, pri_dia_mes
      INTO vFechaHoy, vPriDiaMes
      FROM sc_fechas
     WHERE empresa = '001';
     
    LET vFechaIni = vPriDiaMes - 1 UNITS MONTH;
    LET vFechaFin = vPriDiaMes - 1 UNITS DAY;
    LET vFechaAniomes = vFechaIni - 1 UNITS DAY;
    
    LET vAnio = YEAR(vFechaAniomes);
    LET vMes = LPAD(MONTH(vFechaAniomes), 2, '0');
    LET vAnioMes = vAnio||vMes;
    LET vResiduo = MOD(vAnio, 4);
    
    IF vResiduo = 0 THEN
        LET vAniobase = 366;
    ELSE
        LET vAniobase = 365;
    END IF;
    
    -- // VERIFICA SI YA SE EJECUTO EL PROCESO PARA EL MES EN CURSO
    select count(*)
      into vexiste
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = vproceso
       and sistema = vsistema
       and fecha >= vPriDiaMes;

    if vexiste = 0 then
        LET vstmt = '';
        LET vstmt = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso||''', '''||vFechaHoy||''', '''||vsistema||''', '''||'I'||''', '''||vusuario||''','||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/anacap.sql';
        SYSTEM vstmt;
        LET vstmt = '';
        
        LET vsql = '';
        LET vsql = '/ifxsif01/bin/dbaccess bdicheq /tmp/anacap.sql';
        SYSTEM vsql;
        LET vsql = '';
    else
        select count(*)
          into vexistefin
          from bdinteg:sx_contproc
         where empresa     = pempresa
           and proceso     = vproceso
           and sistema     = vsistema
           and status_proc = "F"
           and fecha >= vPriDiaMes;

        if vexistefin = 0 then
            LET vstmt = '';
            LET vstmt = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'I'||''','||
                       'codret        = '''||' '||''','||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vFechaHoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/anacap.sql';
            SYSTEM vstmt;
            LET vstmt = '';
            
            LET vsql = '';
            LET vsql = '/ifxsif01/bin/dbaccess bdicheq /tmp/anacap.sql';
            SYSTEM vsql;
            LET vsql = '';
        else
            LET vcodret1 = "958";
            LET vcodret2 = "958";
            
            RETURN vCodRet1;
        end if
    end if;
    
    /* #############################################################################################################################################################################
    -- // TABLA PARA REPORTAR LAS CUENTAS POR INFORMAR
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctesxanalizar') THEN
        DROP TABLE ctesxanalizar;        
    END IF;
    
    CREATE TABLE ctesxanalizar
      (
        num_cte char(20)
      ) 
    EXTENT SIZE 10000 NEXT SIZE 1000 LOCK MODE ROW;
    
    -- // CARGA ARCHIVO DE CLIENTES
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/riesgos/ctes_analisis_cap.csv DELIMITER ''","'' INSERT INTO ctesxanalizar" > /resplogifx/conciliachq/riesgos/ctesxana.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/riesgos/ctesxana.sql';
    SYSTEM vstmt;
    
    CREATE INDEX idx_repctaxinf ON ctesxanalizar(num_cte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE ctesxanalizar;
    ############################################################################################################################################################################# */
    
    -- // VERIFICA QUE LA TABLA DE CLIENTES A PROCESAR TENGA INFORMACION
    SELECT COUNT(*)
      INTO vContCtes
      FROM ctesxanalizar;
      
    IF vContCtes <= 0 THEN
        LET vCodRet1 = '990';
        RETURN vCodRet1;
    END IF;
    
    -- // TABLA PARA REPORTAR LAS CUENTAS POR INFORMAR
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctesxinformar') THEN
        DROP TABLE ctesxinformar;        
    END IF;
    
    CREATE TABLE ctesxinformar
      (
        num_cte     char(20),
        fecha_nac   char(8),    
        reg_fiscal  char(1),
        tpo_dep     char(4),
        bancaxint   char(1),
        cheques     char(1),
        credito     char(1),
        fecha_alta  char(8)
      ) 
    EXTENT SIZE 25000 NEXT SIZE 2500 LOCK MODE ROW;
    
    -- // TABLA PARA REPORTAR LAS CUENTAS POR INFORMAR
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctesxinformarsdos') THEN
        DROP TABLE ctesxinformarsdos;        
    END IF;
    
    CREATE TABLE ctesxinformarsdos
      (
        periodo     char(6),
        num_cte     char(20),
        sdo_minimo  decimal(18,2),
        abonos      decimal(18,2),
        cargos      decimal(18,2),
        sdo_inicial decimal(18,2), 
        sdo_final   decimal(18,2)
      )
    EXTENT SIZE 40000 NEXT SIZE 4000 LOCK MODE ROW;
    
    -- // OBTIENE PARAMETROS PARA LAS CONSULTAS DE TRANSACCIONALIDAD
    SELECT valor
      INTO vFechaConsMovhis
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'fechcon_movhis';
    
    SELECT valor
      INTO vFechaConsMovhisOld
      FROM bdicheq:sc_param
     WHERE empresa = '001'
       AND codparam = 'FechIniCon_movhis_ol';
       
    FOREACH WITH HOLD
        SELECT ctes.num_cte, cte.tpo_persona, cte.fecha_insert, pf.fecha_nac 
          INTO vNumCte, vTipoPer, vFechaAlta, vFechaNac 
          FROM bdicheq:"informix".ctesxanalizar ctes,
               bdinteg:"informix".si_cliente cte,
               bdinteg:"informix".si_ctepf pf
         WHERE ctes.num_cte = cte.numcte
           AND cte.numcte = pf.numcte
           
        BEGIN WORK;
        LET vEnTransacc = 1;
           
        -- // FECHA DE NACIMIENTO
        LET vFechaNacim = TO_CHAR(vFechaNac, '%Y%m%d');
        
        -- // FECHA DE ALTA
        LET vFechaApertura = TO_CHAR(vFechaAlta, '%Y%m%d');
        
        -- // REGIMEN FISCAL Y TIPO DE DEPOSITANTE
        IF vTipoPer IN('01') THEN
            LET vRegFiscal = 'F';
            LET vTipoDepositante = 'PF';
        ELIF vTipoPer IN('03') THEN
            LET vRegFiscal = 'F';
            LET vTipoDepositante = 'PFAE';
        ELIF vTipoPer IN('02') THEN
            LET vRegFiscal = 'M';
            LET vTipoDepositante = 'PyME';
        ELIF vTipoPer IN('04') THEN
            LET vRegFiscal = 'M';
            LET vTipoDepositante = 'PyME';
        END IF;
        
        -- // VALIDA SERVICIO POR INTERNET
        SELECT COUNT(*)
          INTO vExsiteBPI
          FROM bdinteg:"informix".si_bpiusuarios
         WHERE numcte = vNumCte;
         
        IF vExsiteBPI > 0 THEN
            LET vBPI = '1';
        ELSE
            LET vBPI = '0';
        END IF;
        
        -- // VERIFICA SI TIENE CUENTAS DE CHEQUES
        SELECT COUNT(*)
          INTO vExisteCtaChq
          FROM bdicheq:"informix".sc_maechq
         WHERE num_cte = vNumCte
           AND producto IN('1900','2200')
           AND status_cta <> '2';
         
        IF vExisteCtaChq > 0 THEN
            LET vCheques = '1';
        ELSE
            LET vCheques = '0';
        END IF;
        
        -- // VALIDA SI TIENE CREDITOS VIGENTES
        SELECT COUNT(*)
          INTO vExisteCred
          FROM bdicred:"informix".sd_maecred
         WHERE numcte = vNumCte
           AND status_cred IN('AA','BA','BT','VP','E1','E2','E3');
           
        SELECT COUNT(*)
          INTO vExisteCredCrd
          FROM bdicred:"informix".sd_maecredcrd
         WHERE numcte = vNumCte
           AND status_cred IN('AA','BA','BT','VP','E1','E2','E3');
         
        IF vExisteCred > 0 OR vExisteCredCrd > 0 THEN
            LET vCredito = '1';
        ELSE
            LET vCredito = '0';
        END IF;
        
        -- // OBTIENE CUENTAS PARA INFORMACION DE TRANSACCIONALIDAD
        SELECT cuenta
          FROM bdicheq:"informix".sc_maechq 
         WHERE num_cte = vNumCte
           AND status_cta NOT IN("2", "6", "7", "8")
        INTO TEMP tmp_ctasxinf WITH NO LOG;
        CREATE INDEX idx_tmpctaxinform ON tmp_ctasxinf(cuenta) USING BTREE FILLFACTOR 99;
        UPDATE STATISTICS HIGH FOR TABLE tmp_ctasxinf;
        
        IF vMes IN('01','03','05','07','08','10','12') THEN
            SELECT SUM(NVL(capvig31, 0))
              INTO vSdoInicial
              FROM bdicheq:"informix".sc_sdodiarioc 
             WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
               AND aniomes = vAnioMes;
        ELIF vMes IN('04','06','09','11') THEN
            SELECT SUM(NVL(capvig30, 0))
              INTO vSdoInicial
              FROM bdicheq:"informix".sc_sdodiarioc 
             WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
               AND aniomes = vAnioMes;
        ELIF vMes = '02' THEN
            IF vAniobase = 365 THEN
                SELECT SUM(NVL(capvig28, 0))
                  INTO vSdoInicial
                  FROM bdicheq:"informix".sc_sdodiarioc 
                 WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                   AND aniomes = vAnioMes;
            ELIF vAniobase = 366 THEN
                SELECT SUM(NVL(capvig29, 0))
                  INTO vSdoInicial
                  FROM bdicheq:"informix".sc_sdodiarioc 
                 WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                   AND aniomes = vAnioMes;
            END IF;
        END IF;
              
        IF vSdoInicial is null THEN
            LET vSdoInicial = 0;
        END IF;
           
        -- // ABONOS 
        SELECT SUM(a.monto_tot)
          INTO vDepositosOld
          FROM bdicheq:"informix".sc_movhis_old a,
               bdinteg:"informix".si_transacc b
         WHERE a.empresa = '001'
           AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
           AND a.fech_alt >= vFechaConsMovhisOld
           AND a.fech_alt < vFechaConsMovhis
           AND a.fech_alt BETWEEN vFechaIni AND vFechaFin
           AND a.cancelad <> 'S'
           AND a.transacc = b.numero
           AND b.se_emite_edocta = 'S'
           AND b.naturaleza = 'A'
           AND b.numero <> '0250';
           
        IF vDepositosOld is null THEN
            LET vDepositosOld = 0.00;
        END IF;
        
        SELECT SUM(a.monto_tot)
          INTO vDepositos
          FROM bdicheq:"informix".sc_movhis a,
               bdinteg:"informix".si_transacc b
         WHERE a.empresa = '001'
           AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
           AND a.fech_alt >= vFechaConsMovhis
           AND a.fech_alt BETWEEN vFechaIni AND vFechaFin
           AND a.cancelad <> 'S'
           AND a.transacc = b.numero
           AND b.se_emite_edocta = 'S'
           AND b.naturaleza = 'A'
           AND b.numero <> '0250';
           
        IF vDepositos is null THEN
            LET vDepositos = 0.00;
        END IF;
        
        LET vDepositos = vDepositos + vDepositosOld;
               
        -- // CARGOS 
        SELECT SUM(a.monto_tot)
          INTO vCargosOld
          FROM bdicheq:"informix".sc_movhis_old a,
               bdinteg:"informix".si_transacc b
         WHERE a.empresa = '001'
           AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
           AND a.fech_alt >= vFechaConsMovhisOld
           AND a.fech_alt < vFechaConsMovhis
           AND a.fech_alt BETWEEN vFechaIni AND vFechaFin
           AND a.cancelad <> 'S'
           AND a.transacc = b.numero
           AND b.se_emite_edocta = 'S'
           AND b.naturaleza = 'C'
           AND b.numero <> '0232';
           
        IF vCargosOld is null THEN
            LET vCargosOld = 0.00;
        END IF;
        
        SELECT SUM(a.monto_tot)
          INTO vCargos
          FROM bdicheq:"informix".sc_movhis a,
               bdinteg:"informix".si_transacc b
         WHERE a.empresa = '001'
           AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
           AND a.fech_alt >= vFechaConsMovhis
           AND a.fech_alt BETWEEN vFechaIni AND vFechaFin
           AND a.cancelad <> 'S'
           AND a.transacc = b.numero
           AND b.se_emite_edocta = 'S'
           AND b.naturaleza = 'C'
           AND b.numero <> '0232';
           
        IF vCargos is null THEN
            LET vCargos = 0.00;
        END IF;
           
        LET vCargos = vCargos + vCargosOld;
        
        LET vSdoFinal = ((vSdoInicial + vDepositos) - vCargos);
        
        -- // GUARDA DATOS DEL CLIENTE
        INSERT INTO ctesxinformar(num_cte, fecha_nac, reg_fiscal, tpo_dep, bancaxint, cheques, credito, fecha_alta)
        VALUES(vNumCte, vFechaNacim, vRegFiscal, vTipoDepositante, vBPI, vCheques, vCredito, vFechaApertura);
        
        INSERT INTO ctesxinformarsdos(periodo, num_cte, sdo_minimo, abonos, cargos, sdo_inicial, sdo_final)
        VALUES(vAnioMes, vNumCte, 0.00, vDepositos, vCargos, vSdoInicial, vSdoFinal);
         
        DROP TABLE tmp_ctasxinf;
        
        LET vContador1 = vContador1 + 1;
        
        COMMIT WORK;
        LET vEnTransacc = 0;
        
        LET vNumCte = '';
        LET vTipoPer = '';
        LET vFechaAlta = '';
        LET vFechaNac = '';
        LET vFechaNacim = '';
        LET vFechaApertura = '';
        LET vRegFiscal = '';
        LET vTipoDepositante = '';
        LET vExsiteBPI = 0;
        LET vBPI = '';
        LET vExisteCtaChq = 0;
        LET vCheques = '';
        LET vExisteCred = 0;
        LET vExisteCredCrd = 0;
        LET vCredito = '';
        LET vSdoInicial = 0.00;
        LET vDepositos = 0.00;
        LET vDepositosOld = 0.00;
        LET vCargos = 0.00;
        LET vCargosOld = 0.00;
        LET vSdoFinal = 0.00;
    END FOREACH;
    
    FOREACH WITH HOLD
        SELECT ctes.num_cte, cte.tpo_persona, cte.fecha_insert, pm.fecha_constitct 
          INTO vNumCte, vTipoPer, vFechaAlta, vFechaNac 
          FROM bdicheq:"informix".ctesxinformar ctes,
               bdinteg:"informix".si_cliente cte,
               bdinteg:"informix".si_ctepm pm
         WHERE ctes.num_cte = cte.numcte
           AND cte.numcte = pm.numcte
           
        BEGIN WORK;
        LET vEnTransacc = 1;
        
        -- // FECHA DE NACIMIENTO
        IF vFechaNac IS NOT NULL THEN
            LET vFechaNacim = TO_CHAR(vFechaNac, '%Y%m%d');
        ELSE
            LET vFechaNacim = '';
        END IF;
        
        -- // FECHA DE ALTA
        LET vFechaApertura = TO_CHAR(vFechaAlta, '%Y%m%d');
        
        -- // REGIMEN FISCAL Y TIPO DE DEPOSITANTE
        IF vTipoPer IN('01') THEN
            LET vRegFiscal = 'F';
            LET vTipoDepositante = 'PF';
        ELIF vTipoPer IN('03') THEN
            LET vRegFiscal = 'F';
            LET vTipoDepositante = 'PFAE';
        ELIF vTipoPer IN('02') THEN
            LET vRegFiscal = 'M';
            LET vTipoDepositante = 'PyME';
        ELIF vTipoPer IN('04') THEN
            LET vRegFiscal = 'M';
            LET vTipoDepositante = 'PyME';
        END IF;
        
        -- // VALIDA SI TIENE SERVICIO DE BANCA POR INTERNET
        SELECT COUNT(*)
          INTO vExsiteBPI
          FROM bdinteg:"informix".si_bpiusuarios
         WHERE numcte = vNumCte
           AND f_registro BETWEEN vFechaIni AND vFechaFin;
         
        IF vExsiteBPI > 0 THEN
            LET vBPI = '1';
        ELSE
            LET vBPI = '0';
        END IF;
        
        -- // VERIFICA SI TIENE CUENTAS DE CHEQUES
        SELECT COUNT(*)
          INTO vExisteCtaChq
          FROM bdicheq:"informix".sc_maechq
         WHERE num_cte = vNumCte
           AND producto IN('1900','2200')
           AND status_cta <> '2';
         
        IF vExisteCtaChq > 0 THEN
            LET vCheques = '1';
        ELSE
            LET vCheques = '0';
        END IF;
        
        -- // VALIDA SI TIENE CREDITOS VIGENTES
        SELECT COUNT(*)
          INTO vExisteCred
          FROM bdicred:"informix".sd_maecred
         WHERE numcte = vNumCte
           AND status_cred IN('AA','BA','BT','VP','E1','E2','E3');
           
        SELECT COUNT(*)
          INTO vExisteCredCrd
          FROM bdicred:"informix".sd_maecredcrd
         WHERE numcte = vNumCte
           AND status_cred IN('AA','BA','BT','VP','E1','E2','E3');
         
        IF vExisteCred > 0 OR vExisteCredCrd > 0 THEN
            LET vCredito = '1';
        ELSE
            LET vCredito = '0';
        END IF;
        
        -- // OBTIENE CUENTAS PARA INFORMACION DE TRANSACCIONALIDAD
        SELECT cuenta
          FROM bdicheq:"informix".sc_maechq 
         WHERE num_cte = vNumCte
           AND status_cta NOT IN("2", "6", "7", "8")
        INTO TEMP tmp_ctasxinf WITH NO LOG;
        CREATE INDEX idx_tmpctaxinform ON tmp_ctasxinf(cuenta) USING BTREE FILLFACTOR 99;
        UPDATE STATISTICS HIGH FOR TABLE tmp_ctasxinf;
        
        IF vMes IN('01','03','05','07','08','10','12') THEN
            SELECT SUM(capvig31)
              INTO vSdoInicial
              FROM bdicheq:"informix".sc_sdodiarioc 
             WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
               AND aniomes = vAnioMes;
        ELIF vMes IN('04','06','09','11') THEN
            SELECT SUM(capvig30)
              INTO vSdoInicial
              FROM bdicheq:"informix".sc_sdodiarioc 
             WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
               AND aniomes = vAnioMes;
        ELIF vMes = '02' THEN
            IF vAniobase = 365 THEN
                SELECT SUM(capvig28)
                  INTO vSdoInicial
                  FROM bdicheq:"informix".sc_sdodiarioc 
                 WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                   AND aniomes = vAnioMes;
            ELIF vAniobase = 366 THEN
                SELECT SUM(capvig29)
                  INTO vSdoInicial
                  FROM bdicheq:"informix".sc_sdodiarioc 
                 WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                   AND aniomes = vAnioMes;
            END IF;
        END IF;
              
        IF vSdoInicial is null THEN
            LET vSdoInicial = 0.00;
        END IF;
           
        -- // ABONOS 
        SELECT SUM(a.monto_tot)
          INTO vDepositosOld
          FROM bdicheq:"informix".sc_movhis_old a,
               bdinteg:"informix".si_transacc b
         WHERE a.empresa = '001'
           AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
           AND a.fech_alt >= vFechaConsMovhisOld
           AND a.fech_alt < vFechaConsMovhis
           AND a.fech_alt BETWEEN vFechaIni AND vFechaFin
           AND a.cancelad <> 'S'
           AND a.transacc = b.numero
           AND b.se_emite_edocta = 'S'
           AND b.naturaleza = 'A'
           AND b.numero <> '0250';
           
        IF vDepositosOld is null THEN
            LET vDepositosOld = 0.00;
        END IF;
        
        SELECT SUM(a.monto_tot)
          INTO vDepositos
          FROM bdicheq:"informix".sc_movhis a,
               bdinteg:"informix".si_transacc b
         WHERE a.empresa = '001'
           AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
           AND a.fech_alt >= vFechaConsMovhis
           AND a.fech_alt BETWEEN vFechaIni AND vFechaFin
           AND a.cancelad <> 'S'
           AND a.transacc = b.numero
           AND b.se_emite_edocta = 'S'
           AND b.naturaleza = 'A'
           AND b.numero <> '0250';
           
        IF vDepositos is null THEN
            LET vDepositos = 0.00;
        END IF;
        
        LET vDepositos = vDepositos + vDepositosOld;
               
        -- // CARGOS 
        SELECT SUM(a.monto_tot)
          INTO vCargosOld
          FROM bdicheq:"informix".sc_movhis_old a,
               bdinteg:"informix".si_transacc b
         WHERE a.empresa = '001'
           AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
           AND a.fech_alt >= vFechaConsMovhisOld
           AND a.fech_alt < vFechaConsMovhis
           AND a.fech_alt BETWEEN vFechaIni AND vFechaFin
           AND a.cancelad <> 'S'
           AND a.transacc = b.numero
           AND b.se_emite_edocta = 'S'
           AND b.naturaleza = 'C'
           AND b.numero <> '0232';
           
        IF vCargosOld is null THEN
            LET vCargosOld = 0.00;
        END IF;
        
        SELECT SUM(a.monto_tot)
          INTO vCargos
          FROM bdicheq:"informix".sc_movhis a,
               bdinteg:"informix".si_transacc b
         WHERE a.empresa = '001'
           AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
           AND a.fech_alt >= vFechaConsMovhis
           AND a.fech_alt BETWEEN vFechaIni AND vFechaFin
           AND a.cancelad <> 'S'
           AND a.transacc = b.numero
           AND b.se_emite_edocta = 'S'
           AND b.naturaleza = 'C'
           AND b.numero <> '0232';
           
        IF vCargos is null THEN
            LET vCargos = 0.00;
        END IF;
           
        LET vCargos = vCargos + vCargosOld;
        
        LET vSdoFinal = ((vSdoInicial + vDepositos) - vCargos);
        
        -- // GUARDA DATOS DEL CLIENTE
        INSERT INTO ctesxinformar(num_cte, fecha_nac, reg_fiscal, tpo_dep, bancaxint, cheques, credito, fecha_alta)
        VALUES(vNumCte, vFechaNacim, vRegFiscal, vTipoDepositante, vBPI, vCheques, vCredito, vFechaApertura);
        
        INSERT INTO ctesxinformarsdos(periodo, num_cte, sdo_minimo, abonos, cargos, sdo_inicial, sdo_final)
        VALUES(vAnioMes, vNumCte, 0.00, vDepositos, vCargos, vSdoInicial, vSdoFinal);
         
        DROP TABLE tmp_ctasxinf;
        
        LET vContador1 = vContador1 + 1;
        
        COMMIT WORK;
        LET vEnTransacc = 0;
        
        LET vNumCte = '';
        LET vTipoPer = '';
        LET vFechaAlta = '';
        LET vFechaNac = '';
        LET vFechaNacim = '';
        LET vFechaApertura = '';
        LET vRegFiscal = '';
        LET vTipoDepositante = '';
        LET vExsiteBPI = 0;
        LET vBPI = '';
        LET vExisteCtaChq = 0;
        LET vCheques = '';
        LET vExisteCred = 0;
        LET vExisteCredCrd = 0;
        LET vCredito = '';
        LET vSdoInicial = 0.00;
        LET vDepositos = 0.00;
        LET vDepositosOld = 0.00;
        LET vCargos = 0.00;
        LET vCargosOld = 0.00;
        LET vSdoFinal = 0.00;
    END FOREACH;
    
    CREATE INDEX idx_ctexinf ON ctesxinformar(num_cte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE ctesxinformar;
    
    CREATE INDEX idx_ctexinfsdo ON ctesxinformarsdos(num_cte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE ctesxinformarsdos;
    
    -- // DESCARGA DE ARCHIVOS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/riesgos/cap_carac_gen.txt '||
               'SELECT num_cte, fecha_nac, reg_fiscal, tpo_dep, bancaxint, cheques, credito, fecha_alta '||
               'FROM ctesxinformar;" > /resplogifx/conciliachq/riesgos/ctescap1.sql';
    SYSTEM vsql;
    
    LET vstmt = '';
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/riesgos/ctescap1.sql';
    SYSTEM vstmt;
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/riesgos/cap_trans_cuen.txt '||
               'SELECT periodo, num_cte, sdo_minimo, abonos, cargos, sdo_inicial, sdo_final '||
               'FROM ctesxinformarsdos;" > /resplogifx/conciliachq/riesgos/ctescap2.sql';
    SYSTEM vsql;
    
    LET vstmt = '';
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/riesgos/ctescap2.sql';
    SYSTEM vstmt;
    
    -- // GUARDA REGISTRO DE FIN DEL PROCESO EN TABLA DE CONTROL DE PROCESOS
    LET vstmt = '';
    LET vstmt = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET status_proc   = '''||'F'||''','||
               'codret        = '''||vCodRet1||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vFechaHoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/anacap.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    LET vsql = '';
    LET vsql = '/ifxsif01/bin/dbaccess bdicheq /tmp/anacap.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    END;
    
    RETURN vCodRet1;
    
END PROCEDURE;