CREATE PROCEDURE "informix".sp_obtiene_movs_ide(pEmpresa CHAR(3))
RETURNING CHAR(5) AS vCodRet1,
          CHAR(5) AS vCodRet2,
          CHAR(50) AS vCodRet3;
          
    DEFINE vCodRet1             CHAR(5);
    DEFINE vCodRet2             CHAR(5);
    DEFINE vCodRet3             CHAR(50);
    DEFINE vSqlErr              INTEGER;
    DEFINE vIsamErr             INTEGER;
    DEFINE vDescErr             CHAR(50);
    DEFINE vFechaHoy            DATE;
    DEFINE vPriDiaMes           DATE;
    DEFINE vFechaIni            DATE;
    DEFINE vFechaFin            DATE;
    DEFINE vAnioMes             CHAR(6);
    DEFINE vExisteProceso       SMALLINT;
    DEFINE vExisteProcesoFin    SMALLINT;
    DEFINE vNoDepVent           INTEGER;
    DEFINE vMtoDepVent          DECIMAL(18,2);
    DEFINE vNoDepCorr           INTEGER;
    DEFINE vMtoDepCorr          DECIMAL(18,2);
    DEFINE vNoDep               INTEGER;
    DEFINE vMtoDep              DECIMAL(18,2);
    DEFINE vMtoIdePorRecaudar   DECIMAL(18,2);
    DEFINE vMtoIdeVent1         DECIMAL(18,2);
    DEFINE vMtoIdeVent2         DECIMAL(18,2);
    DEFINE vMtoIdeVent3         DECIMAL(18,2);
    DEFINE vMtoIdeVent4         DECIMAL(18,2);
    DEFINE vMtoIdeVent5         DECIMAL(18,2);
    DEFINE vMtoIdeCorr1         DECIMAL(18,2);
    DEFINE vMtoIdeCorr2         DECIMAL(18,2);
    DEFINE vMtoIdeCorr3         DECIMAL(18,2);
    DEFINE vMtoIdeCorr4         DECIMAL(18,2);
    DEFINE vMtoIdeCorr5         DECIMAL(18,2);
    DEFINE vsql                 CHAR(600);
    DEFINE vstmt                CHAR(250);
    
    LET vCodRet1           = '000';
    LET vCodRet2           = '000';
    LET vCodRet3           = 'PROCESO REALIZADO SATISFACTORIAMENTE';
    LET vSqlErr            = 0;
    LET vIsamErr           = 0;
    LET vDescErr           = '';
    LET vFechaHoy          = '';
    LET vPriDiaMes         = '';
    LET vFechaIni          = '';
    LET vFechaFin          = '';
    LET vAnioMes           = '';
    LET vExisteProceso     = 0;
    LET vExisteProcesoFin  = 0;
    LET vNoDepVent         = 0;
    LET vMtoDepVent        = 0.00;
    LET vNoDepCorr         = 0;
    LET vMtoDepCorr        = 0.00;
    LET vNoDep             = 0;
    LET vMtoDep            = 0.00;
    LET vMtoIdePorRecaudar = 0.00;
    LET vMtoIdeVent1       = 0.00;
    LET vMtoIdeVent2       = 0.00;
    LET vMtoIdeVent3       = 0.00;
    LET vMtoIdeVent4       = 0.00;
    LET vMtoIdeVent5       = 0.00;
    LET vMtoIdeCorr1       = 0.00;
    LET vMtoIdeCorr2       = 0.00;
    LET vMtoIdeCorr3       = 0.00;
    LET vMtoIdeCorr4       = 0.00;
    LET vMtoIdeCorr5       = 0.00;
    LET vsql               = '';
    LET vstmt              = '';
    
    BEGIN
    
    ON EXCEPTION SET vSqlErr, vIsamErr, vDescErr
        SET DEBUG FILE TO '/resplogifx/conciliachq/sp_obtiene_movs_ide.err';
        TRACE ON;
        IF vSqlErr <> 0 THEN
            LET vCodRet1 = vSqlErr;
            LET vCodRet2 = vIsamErr;
            LET vCodRet3 = vDescErr;
            
            DELETE FROM bdilide:"informix".sl_depmensuales WHERE aniomes = vAnioMes;
            DELETE FROM bdilide:"informix".sl_depmensuales_vent_rangos WHERE aniomes = vAnioMes;
            DELETE FROM bdilide:"informix".sl_depmensuales_corr_rangos WHERE aniomes = vAnioMes;
            
            RETURN vCodRet1, vCodRet2, vCodRet3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/sp_obtiene_movs_ide.out';
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE FECHAS DEL SISTEMA 
    SELECT fecha_hoy, pri_dia_mes
      INTO vFechaHoy, vPriDiaMes
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = pEmpresa;
     
    LET vFechaIni = vPriDiaMes - 1 UNITS MONTH;
    LET vFechaFin = vPriDiaMes - 1 UNITS DAY;
    LET vAnioMes = YEAR(vFechaFin)||LPAD(MONTH(vFechaFin),2,'0');
    
    SELECT COUNT(*)
      INTO vExisteProceso
      FROM bdilide:"informix".sl_procesos
     WHERE proceso = 'geninfmensual'
       AND fech_proceso >= vPriDiaMes;
       
    IF vExisteProceso = 0 THEN
        -- // INSERTA REGISTRO DE CONTROL DE PROCESO
        INSERT INTO bdilide:"informix".sl_procesos(proceso, fech_proceso, status, user_insert, fecha_insert)
        VALUES('geninfmensual', vFechaHoy, '0', 'informix', vFechaHoy);
    ELSE
        SELECT COUNT(*)
          INTO vExisteProcesoFin
          FROM bdilide:"informix".sl_procesos
         WHERE proceso = 'geninfmensual'
           AND fech_proceso >= vPriDiaMes
           AND status = '1';
           
        IF vExisteProcesoFin = 0 THEN
            UPDATE bdilide:"informix".sl_procesos
               SET fech_proceso = vFechaHoy,
                   fecha_insert = vFechaHoy
             WHERE proceso = 'geninfmensual'
               AND fech_proceso >= vPriDiaMes;
        ELSE
            LET vCodRet1 = '958';
            LET vCodRet2 = '958';
            
            SELECT descripcion
              INTO vCodRet3
              FROM bdinteg:"informix".si_codret
             WHERE codigo_retorno = '958'
               AND sistema = '01';
            
            RETURN vCodRet1, vCodRet2, vCodRet3;
        END IF;
    END IF;
     
    -- // OBTIENE DEPOSITOS EN VENTANILLA
    select count(*), NVL(sum(imp_tot_dep),0)
      into vNoDepVent, vMtoDepVent
	  --    10205529  $30625859334.41
      from bdilide:sl_movefec_his
     where aniomes = vAnioMes
       and tipo_cta = "D"
       and sucursal <> "5005";
    
    -- // OBTIENE DEPOSITOS DE CORRESPONSALES
    select count(*), NVL(sum(imp_tot_dep),0)
      into vNoDepCorr, vMtoDepCorr
	  --        0     , null
      from bdilide:sl_movefec_his
     where aniomes = vAnioMes
       and tipo_cta = "D"
       and sucursal = "5005";
    
    LET vNoDep = vNoDepVent + vNoDepCorr;
	             --10205529 +      0
    LET vMtoDep = vMtoDepVent + vMtoDepCorr;
				 --$30625859334.41 + null
    -- // OBTIENE MONTO TOTAL DEL LIDE POR RETENER   
    select NVL(sum(imp_arecaudar),0)
      into vMtoIdePorRecaudar
	  --$394806764.00
      from bdilide:sl_retlide
     where aniomes = vAnioMes;
    
	IF vAnioMes IS NULL THEN
		LET vAnioMes = '199901';
	END IF;
	
	IF vMtoIdePorRecaudar is null THEN
        LET vMtoIdePorRecaudar = 0.00;
    END IF;

    INSERT INTO bdilide:"informix".sl_depmensuales(aniomes, no_dep_vent, monto_dep_vent, no_dep_corr, monto_dep_corr, no_tot_dep, monto_tot_dep, monto_ide)
    VALUES(vAnioMes, vNoDepVent, vMtoDepVent, vNoDepCorr, vMtoDepCorr, vNoDep, vMtoDep, vMtoIdePorRecaudar);
    --      202405,    10205529,$30625859334.41,0,           null                         ,$394806764.00
    -- // OBTIENE DEPOSITOS POR RANGOS
    select sucursal, tran_central, imp_tot_dep
      from bdilide:sl_retlide a, 
           bdilide:sl_movefec_his b
     where a.aniomes = vAnioMes
       and a.aniomes = b.aniomes
       and a.num_cte = b.num_cte
       and b.tipo_cta = "D"
    into temp tmp_lide with no log;
    CREATE INDEX idx_tmp_lide ON tmp_lide(sucursal, imp_tot_dep) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_lide;
    
    -- // OBTIENE RANGOS DE DESPOSITOS EN VENTANILLA
    select sum(imp_tot_dep)
      into vMtoIdeVent1
      from tmp_lide
     where sucursal <> "5005"
       and imp_tot_dep < 15000.00;
       
    IF vMtoIdeVent1 is null THEN
        LET vMtoIdeVent1 = 0.00;
    END IF;

    select sum(imp_tot_dep)
      into vMtoIdeVent2
      from tmp_lide
     where sucursal <> "5005"
       and imp_tot_dep >= 15000.00
       and imp_tot_dep <= 20000.00;
       
    IF vMtoIdeVent2 is null THEN
        LET vMtoIdeVent2 = 0.00;
    END IF;

    select sum(imp_tot_dep)
      into vMtoIdeVent3
      from tmp_lide
     where sucursal <> "5005"
       and imp_tot_dep >  20000.00
       and imp_tot_dep <= 25000.00;
       
    IF vMtoIdeVent3 is null THEN
        LET vMtoIdeVent3 = 0.00;
    END IF;

    select sum(imp_tot_dep)
      into vMtoIdeVent4
      from tmp_lide
     where sucursal <> "5005"
       and imp_tot_dep >  25000.00
       and imp_tot_dep <= 30000.00;
       
    IF vMtoIdeVent4 is null THEN
        LET vMtoIdeVent4 = 0.00;
    END IF;

    select sum(imp_tot_dep)
      into vMtoIdeVent5
      from tmp_lide
     where sucursal <> "5005"
       and imp_tot_dep >  30000.00;
       
    IF vMtoIdeVent5 is null THEN
        LET vMtoIdeVent5 = 0.00;
    END IF;
       
    INSERT INTO bdilide:"informix".sl_depmensuales_vent_rangos(aniomes, dep_menor15, dep_15a20, dep_20a25, dep_25a30, dep_mayor30)
    VALUES(vAnioMes, vMtoIdeVent1, vMtoIdeVent2, vMtoIdeVent3, vMtoIdeVent4, vMtoIdeVent5);

    -- // OBTIENE RANGOS DE CORRESPONSALES
    select sum(imp_tot_dep)
      into vMtoIdeCorr1
      from tmp_lide
     where sucursal = "5005"
       and imp_tot_dep <  15000.00;
       
    IF vMtoIdeCorr1 is null THEN
        LET vMtoIdeCorr1 = 0.00;
    END IF;

    select sum(imp_tot_dep)
      into vMtoIdeCorr2
      from tmp_lide
     where sucursal = "5005"
       and imp_tot_dep >= 15000.00
       and imp_tot_dep <= 20000.00;
       
    IF vMtoIdeCorr2 is null THEN
        LET vMtoIdeCorr2 = 0.00;
    END IF;

    select sum(imp_tot_dep)
      into vMtoIdeCorr3
      from tmp_lide
     where sucursal = "5005"
       and imp_tot_dep >  20000.00
       and imp_tot_dep <= 25000.00;
       
    IF vMtoIdeCorr3 is null THEN
        LET vMtoIdeCorr3 = 0.00;
    END IF;

    select sum(imp_tot_dep)
      into vMtoIdeCorr4
      from tmp_lide
     where sucursal = "5005"
       and imp_tot_dep >  25000.00
       and imp_tot_dep <= 30000.00;
       
    IF vMtoIdeCorr4 is null THEN
        LET vMtoIdeCorr4 = 0.00;
    END IF;

    select sum(imp_tot_dep)
      into vMtoIdeCorr5
      from tmp_lide
     where sucursal = "5005"
       and imp_tot_dep >  30000.00;
       
    IF vMtoIdeCorr5 is null THEN
        LET vMtoIdeCorr5 = 0.00;
    END IF;
       
    INSERT INTO bdilide:"informix".sl_depmensuales_corr_rangos(aniomes, dep_menor15, dep_15a20, dep_20a25, dep_25a30, dep_mayor30)
    VALUES(vAnioMes, vMtoIdeCorr1, vMtoIdeCorr2, vMtoIdeCorr3, vMtoIdeCorr4, vMtoIdeCorr5);
    
    -- // GENERA ARCHIVO DE TOTALES
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/depmensuales_'||vAnioMes||'.txt '||
               'SELECT * FROM sl_depmensuales WHERE aniomes = '''||vAnioMes||''' " > /resplogifx/conciliachq/depmentot.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdilide /resplogifx/conciliachq/depmentot.sql"; 
    SYSTEM vsql;
    
    -- // GENERA ARCHIVO DE VENTANILLA
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/depmensualesvent_'||vAnioMes||'.txt '||
               'SELECT * FROM sl_depmensuales_vent_rangos WHERE aniomes = '''||vAnioMes||''' " > /resplogifx/conciliachq/depmenvent.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdilide /resplogifx/conciliachq/depmenvent.sql"; 
    SYSTEM vsql;
    
    -- // GENERA ARCHIVO DE CORRESPONSALES
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/depmensualescorresp_'||vAnioMes||'.txt '||
               'SELECT * FROM sl_depmensuales_corr_rangos WHERE aniomes = '''||vAnioMes||''' " > /resplogifx/conciliachq/depmencorr.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdilide /resplogifx/conciliachq/depmencorr.sql"; 
    SYSTEM vsql;
    
    -- // REGISTRA FIN DEL PROCESO
    UPDATE bdilide:"informix".sl_procesos
       SET status = '1'
     WHERE proceso = 'geninfmensual'
       AND fech_proceso >= vPriDiaMes;
            
    END;
    
    RETURN vCodRet1, vCodRet2, vCodRet3;
    
END PROCEDURE;