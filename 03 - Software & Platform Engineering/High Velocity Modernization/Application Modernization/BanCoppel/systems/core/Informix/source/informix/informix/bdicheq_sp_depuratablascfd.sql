CREATE PROCEDURE  "informix".sp_depuratablascfd( pEmpresa CHAR(3) )
RETURNING CHAR(5);
    
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vSqlErr          INTEGER;
    DEFINE vIsamErr         INTEGER;
    DEFINE vDescErr         CHAR(50);
    DEFINE vSQL             CHAR(500);
    DEFINE vcSql            CHAR(500);
    DEFINE vcStmt           CHAR(300);
    DEFINE vFechaHoy        DATE;
    DEFINE vPriDiaMes       DATE;
    DEFINE vPriDiaMesAnt    DATE;
    DEFINE vFechaEjec       DATE;
    DEFINE vStatusProc      CHAR(1);
    DEFINE vAnioMesAnt      CHAR(6);
    DEFINE vExisteTabla1    SMALLINT;
    DEFINE vExisteTabla2    SMALLINT;
    DEFINE vExisteTabla3    SMALLINT;
    DEFINE vExisteTabla4    SMALLINT;
    DEFINE vExisteTabla5    SMALLINT;
    DEFINE vExisteTabla6    SMALLINT;
    
    LET vCodRet1        = '';
    LET vCodRet2        = '';
    LET vCodRet3        = '';
    LET vSqlErr         = 0;
    LET vIsamErr        = 0;
    LET vDescErr        = '';
    LET vSQL            = '';
    LET vcSql           = '';
    LET vcStmt          = '';
    LET vFechaHoy       = '';
    LET vPriDiaMes      = '';
    LET vPriDiaMesAnt   = '';
    LET vFechaEjec      = '';
    LET vStatusProc     = '';
    LET vAnioMesAnt     = '';
    LET vExisteTabla1   = 0;
    LET vExisteTabla2   = 0;
    LET vExisteTabla3   = 0;
    LET vExisteTabla4   = 0;
    LET vExisteTabla5   = 0;
    LET vExisteTabla6   = 0;
    
    BEGIN
    
    ON EXCEPTION SET vSqlErr, vIsamErr, vDescErr
        SET DEBUG FILE TO '/resplogifx/conciliachq/sp_depuratablascfd.err';
        TRACE ON;
        IF vSqlErr <> 0 THEN
            LET vCodRet1 = vSqlErr;
            LET vCodRet2 = vIsamErr;
            LET vCodRet3 = vDescErr;
            LET vcSql = 'echo " UPDATE bdicheq:sc_contproc_edocta_factelect '||
                        'SET status_proc = '''||'E'||''', '||
                        'hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), '||
                        'cod_ret = '''||vCodRet1||''', mensaje = '''||vCodRet3||''' '||
                        'WHERE fecha >= '''||vPriDiaMes||''' AND proceso = '''||'DEPURACION DE TABLAS'||''' AND tipo_proc = '''||'D'||''';" > /tmp/depuratblcfd.sql';
            SYSTEM vcSql;
            LET vcStmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/depuratblcfd.sql';
            SYSTEM vcStmt;
            RETURN vCodRet1;
        END IF;    
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/sp_depuratablascfd.out';
    --- TRACE ON;
	    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    SELECT fecha_hoy, pri_dia_mes
      INTO vFechaHoy, vPriDiaMes
      FROM sc_fechas
     WHERE empresa = pEmpresa;
     
    LET vPriDiaMesAnt = vPriDiaMes - 1 UNITS MONTH;
    LET vAnioMesAnt = TO_CHAR(vPriDiaMesAnt, '%Y%m');
     
    -- // VALIDA SI EL PROCESO DE FACTURACION YA SE FINALIZO PARA EL MES ANTERIOR
    SELECT MAX(fecha)
      INTO vFechaEjec
      FROM sc_contproc_edocta_factelect
     WHERE proceso = 'GENERA EDO CTA FE'
       AND empresa = pEmpresa
       AND tipo_proc = 'D'
       AND status_proc = 'F';
       
    IF vFechaEjec < vPriDiaMes THEN
        LET vCodRet1 = '999';
        LET vCodRet2 = '999';
        LET vCodRet3 = 'NO SE HA FINALIZADO DE PROCESAR EL MES ANTERIOR';
        RETURN vCodRet1;
    END IF;
    
    -- // VALIDA SI EL PROCESO YA SE EJECUTO PARA EL MES EN CURSO
    SELECT status_proc
      INTO vStatusProc
      FROM sc_contproc_edocta_factelect
     WHERE proceso = 'DEPURACION DE TABLAS'
       AND fecha >= vPriDiaMes
       AND tipo_proc = 'D';
       
    IF vStatusProc = 'F' THEN
        LET vCodRet1 = '958';
        LET vCodRet2 = '958';
        LET vCodRet3 = 'PROCESO EJECUTADO Y FINALIZADO CORRECTAMENTE';
        RETURN vCodRet1;
    ELIF vStatusProc is null OR vStatusProc = '' THEN
        LET vcSql = 'echo " INSERT INTO bdicheq:sc_contproc_edocta_factelect VALUES '||
                    '('''||pEmpresa||''', '''||'DEPURACION DE TABLAS'||''', '''||vFechaHoy||''', '''||'D'||''', '''||'I'||''', '''||'informix'||''', '||
                    '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL, '''||'PROCESO INICIADO'||''');" > /tmp/depuratblcfd.sql';
        SYSTEM vcSql;
        LET vcStmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/depuratblcfd.sql'; 
        SYSTEM vcStmt;
    ELSE
        LET vcSql = 'echo " UPDATE bdicheq:sc_contproc_edocta_factelect '||
                    'SET status_proc = '''||'I'||''', '||
                    'hora_inicio = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), '||
                    'hora_fin = NULL, cod_ret = NULL, mensaje = NULL '||
                    'WHERE fecha >= '''||vPriDiaMes||''' AND proceso = '''||'DEPURACION DE TABLAS'||''' AND tipo_proc = '''||'D'||''';" > /tmp/depuratblcfd.sql';
        SYSTEM vcSql;
        LET vcStmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/depuratblcfd.sql';
        SYSTEM vcStmt;
    END IF;
      
    
   /* -- // DESCARGA LAS TABLAS HISTORICAS    
    LET vSQL = '';
    LET vSQL = 'echo "SET ISOLATION TO DIRTY READ; '|| 
               'UNLOAD TO /RESPALDOSNEW/sc_encabezado_edocta_factelect_old_'||vAnioMesAnt||'.txt '||
               'SELECT * FROM sc_encabezado_edocta_factelect_old;" > /RESPALDOSNEW/desctblcfd.sql';
    SYSTEM vSQL;
    LET vSQL = '';
    LET vSQL = "/ifxsif01/bin/dbaccess bdicheq /RESPALDOSNEW/desctblcfd.sql"; 
    SYSTEM vSQL;
    
    
    LET vSQL = '';
    LET vSQL = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /RESPALDOSNEW/sc_encabezado2_edocta_factelect_old_'||vAnioMesAnt||'.txt '||
               'SELECT * FROM sc_encabezado2_edocta_factelect_old;" > /RESPALDOSNEW/desctblcfd.sql';
    SYSTEM vSQL;
    LET vSQL = '';
    LET vSQL = "/ifxsif01/bin/dbaccess bdicheq /RESPALDOSNEW/desctblcfd.sql"; 
    SYSTEM vSQL;
    LET vSQL = '';
    LET vSQL = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /RESPALDOSNEW/sc_detalle_edocta_factelect_old_'||vAnioMesAnt||'.txt '||
               'SELECT * FROM sc_detalle_edocta_factelect_old;" > /RESPALDOSNEW/desctblcfd.sql';
    SYSTEM vSQL;
    
    LET vSQL = '';
    LET vSQL = "/ifxsif01/bin/dbaccess bdicheq /RESPALDOSNEW/desctblcfd.sql"; 
    SYSTEM vSQL;

    LET vSQL = '';
    LET vSQL = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /RESPALDOSNEW/sc_mensajes_edocta_factelect_old_'||vAnioMesAnt||'.txt '||
               'SELECT * FROM sc_mensajes_edocta_factelect_old;" > /RESPALDOSNEW/desctblcfd.sql';
    SYSTEM vSQL;
    LET vSQL = '';
    LET vSQL = "/ifxsif01/bin/dbaccess bdicheq /RESPALDOSNEW/desctblcfd.sql"; 
    SYSTEM vSQL;
    
    LET vSQL = '';
    LET vSQL = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /RESPALDOSNEW/sc_piepagina_edocta_factelect_old_'||vAnioMesAnt||'.txt '||
               'SELECT * FROM sc_piepagina_edocta_factelect_old;" > /RESPALDOSNEW/desctblcfd.sql';
    SYSTEM vSQL;
    LET vSQL = '';
    LET vSQL = "/ifxsif01/bin/dbaccess bdicheq /RESPALDOSNEW/desctblcfd.sql"; 
    SYSTEM vSQL;
    
    LET vSQL = '';
    LET vSQL = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /RESPALDOSNEW/sc_grafica_fe_old_'||vAnioMesAnt||'.txt '||
               'SELECT * FROM sc_grafica_fe_old;" > /RESPALDOSNEW/desctblcfd.sql';
    SYSTEM vSQL;
    LET vSQL = '';
    LET vSQL = "/ifxsif01/bin/dbaccess bdicheq /RESPALDOSNEW/desctblcfd.sql"; 
    SYSTEM vSQL;
    
    
    -- // VERIFICA DESCARGA DE LAS TABLAS HISTORICAS    
    LET vSQL = '';
    LET vSQL = 'ls -l /RESPALDOSNEW/sc_encabezado_edocta_factelect_old_'||vAnioMesAnt||'.txt';
    SYSTEM vSQL;
    
    LET vSQL = '';
    LET vSQL = 'ls -l /RESPALDOSNEW/sc_encabezado2_edocta_factelect_old_'||vAnioMesAnt||'.txt';
    SYSTEM vSQL;
    
    LET vSQL = '';
    LET vSQL = 'ls -l /RESPALDOSNEW/sc_detalle_edocta_factelect_old_'||vAnioMesAnt||'.txt';
    SYSTEM vSQL;
    
    LET vSQL = '';
    LET vSQL = 'ls -l /RESPALDOSNEW/sc_mensajes_edocta_factelect_old_'||vAnioMesAnt||'.txt';
    SYSTEM vSQL;
    
    LET vSQL = '';
    LET vSQL = 'ls -l /RESPALDOSNEW/sc_piepagina_edocta_factelect_old_'||vAnioMesAnt||'.txt';
    SYSTEM vSQL;
    
    LET vSQL = '';
    LET vSQL = 'ls -l /RESPALDOSNEW/sc_grafica_fe_old_'||vAnioMesAnt||'.txt';
    SYSTEM vSQL;*/
    
    
   -- // BORRA TABLAS HISTORICAS
    DROP TABLE sc_encabezado_edocta_factelect_old;
    DROP TABLE sc_encabezado2_edocta_factelect_old;
    DROP TABLE sc_detalle_edocta_factelect_old;
    DROP TABLE sc_mensajes_edocta_factelect_old;
    DROP TABLE sc_piepagina_edocta_factelect_old;
    DROP TABLE sc_grafica_fe_old;     
    --//BORRAR LOS INDEX 
    -- DROP INDEX "informix".idx_encabezado_cte;
	-- DROP INDEX "informix".idx_encabezado_fe;
	-- DROP INDEX "informix".idx_encabezadofechacuenta_fe;
	-- DROP INDEX "informix".idx_sc_encabezado_com;
	-- DROP INDEX "informix".idx_encabezado2_fe;
	-- DROP INDEX "informix".idx_encabezado2_com;
	-- DROP INDEX "informix".idx_detedocta_fe;
	-- DROP INDEX "informix".idx_mensajes_fe;
	-- DROP INDEX "informix".idx_piepagina_fe;
	-- DROP INDEX "informix".idx_piepagina_fe2;
	-- DROP INDEX "informix".idx_graficafe;
  
    -- // RENOMBRA TABLA E INDICES 
    RENAME TABLE sc_encabezado_edocta_factelect  TO sc_encabezado_edocta_factelect_old;
    RENAME INDEX idx_encabezado_cte              TO idx_encabezado_cte_old;
    RENAME INDEX idx_encabezado_fe               TO idx_encabezado_fe_old;
    RENAME INDEX idx_encabezadofechacuenta_fe    TO idx_encabezadofechacuenta_fe_old;
    RENAME INDEX idx_sc_encabezado_com           TO idx_sc_encabezado_com_old;	
	
    RENAME TABLE sc_encabezado2_edocta_factelect TO sc_encabezado2_edocta_factelect_old;
    RENAME INDEX idx_encabezado2_fe              TO idx_encabezado2_fe_old; 
	  RENAME INDEX idx_encabezado2_com             TO idx_encabezado2_com_old;	
    
    RENAME TABLE sc_detalle_edocta_factelect     TO sc_detalle_edocta_factelect_old;
    RENAME INDEX idx_detedocta_fe                TO idx_detedocta_fe_old;
    
    RENAME TABLE sc_mensajes_edocta_factelect    TO sc_mensajes_edocta_factelect_old;
    RENAME INDEX idx_mensajes_fe                 TO idx_mensajes_fe_old;
    
    RENAME TABLE sc_piepagina_edocta_factelect   TO sc_piepagina_edocta_factelect_old;
    RENAME INDEX idx_piepagina_fe                TO idx_piepagina_fe_old;
    RENAME INDEX idx_piepagina_fe2               TO idx_piepagina_fe2_old;
    
    RENAME TABLE sc_grafica_fe                   TO sc_grafica_fe_old; 
    RENAME INDEX idx_graficafe                   TO idx_graficafe_old;    
    
    -- // CREA TABLA E INDICES 
    CREATE TABLE sc_encabezado_edocta_factelect 
      (
        idreg           integer,
        fecha_emision   date,
        num_cuenta      char(20),
        num_cte         char(20),
        num_tarjeta     char(16),
        nombre_cte      char(254),
        direccion_cte   char(200),
        direccion_col   char(120),
        direccion_del   char(120),
        edo_cd          char(120),
        cve_ruta        char(60),
        sucursal_nombre char(40),
        rfc             char(13),
        cp              char(5),
        cve_ahorro      char(47),
        clabe           char(60),
        curp            char(60),
        fechaalta       date,
        fechainicio     date,
        mensajeproducto char(255),
        inserto         char(15),
        fechafinal      date,
        sucursal        char(4),
        ciudad_suc      char(60),
        siglas_edo_suc  char(4),
        telefono_suc    char(14),
        gerente_suc     char(40),
		    correo			char(100),
		    confirmacion    char(5),
		    exportacion     CHAR(2),  
	      reg_fiscal      CHAR(3),
	      obj_impuesto    CHAR(2),
	      base	        MONEY(18,2)) 
     fragment by round robin in datoshis02, datoshis03, datoshis04 
    extent size 6579196 next size 6579196 lock mode row;
    
    CREATE INDEX idx_encabezado_cte ON sc_encabezado_edocta_factelect(num_cte) IN dbs_movhis_idx1 ONLINE;
    CREATE INDEX idx_encabezado_fe ON sc_encabezado_edocta_factelect(fecha_emision) IN dbs_movhis_idx1 ONLINE;
    CREATE INDEX idx_encabezadofechacuenta_fe ON sc_encabezado_edocta_factelect (fechafinal,num_cuenta) IN dbs_movhis_idx1 ONLINE;
    CREATE UNIQUE INDEX idx_sc_encabezado_com ON sc_encabezado_edocta_factelect (idreg,fecha_emision,num_cuenta) IN dbs_movhis_idx1 ONLINE;
	
    UPDATE STATISTICS MEDIUM FOR TABLE sc_encabezado_edocta_factelect; 
        
    CREATE TABLE sc_encabezado2_edocta_factelect 
      (
        idreg               integer,
        fecha_emision       date,
        num_cuenta          char(20),
        saldoanterior       money(16,2),
        depositos           money(16,2),
        interesespagados    money(16,2),
        retiros             money(16,2),
        otroscargos         money(16,2),
        ivaotroscargos      money(16,2),
        saldocorte          money(16,2),
        saldopromedio       money(16,2),
        retencionisr        money(16,2),
        interesesnetos      money(16,2),
        dias                integer,
        tasabruta           decimal(9,6),
	      baseisr             MONEY (16,2),
		    tasaisr             DECIMAL(9, 6),
		    descuento           MONEY (16,2),
		    subtotal            MONEY (16,2),
		    total               MONEY (16,2)
      --  PRIMARY KEY (idreg,fecha_emision,num_cuenta) 
      ) 
    fragment by round robin in dbs_movhis1, dbs_movhis2, dbs_movhis3
    extent size 3684780 next size 2210868 lock mode row;
    
    CREATE INDEX idx_encabezado2_fe ON sc_encabezado2_edocta_factelect(fecha_emision) IN dbs_movhis_idx2 ONLINE;
    CREATE UNIQUE INDEX idx_encabezado2_com ON sc_encabezado2_edocta_factelect(idreg,fecha_emision,num_cuenta) IN dbs_movhis_idx2 ONLINE;

    UPDATE STATISTICS MEDIUM FOR TABLE sc_encabezado2_edocta_factelect; 
    
    
    CREATE TABLE sc_detalle_edocta_factelect 
      (
        idreg           integer,
        fecha_emision   date,
        num_cuenta      char(20),
        secuencia       integer,
        nlinea          integer,
        fechamov        date,
        descripcion     char(255),
        retiro          decimal(14,2),
        deposito        decimal(14,2),
        saldo           decimal(14,2)
      ) 
    fragment by round robin in dbs_info01 , dbs_datos05, dbs_info06   
    extent size 11298660 next size 3579196 lock mode row; 
    
    CREATE INDEX idx_detedocta_fe ON sc_detalle_edocta_factelect(fecha_emision) IN dbs_movhis_idx2 ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE sc_detalle_edocta_factelect; 
    
    
    CREATE TABLE sc_mensajes_edocta_factelect 
      (
        idreg           integer,
        fecha_emision   date,
        num_cuenta      char(20),
        secuencia       integer,
        nlinea          integer,
        mensaje         char(255)
      ) 
    fragment by round robin in dbs_movhis1, dbs_movhis2, dbs_movhis3
    extent size 9298660 next size 5579196 lock mode row;
    
    CREATE INDEX idx_mensajes_fe ON sc_mensajes_edocta_factelect(fecha_emision) IN dbs_movhis_idx2 ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE sc_mensajes_edocta_factelect; 
    
    
    CREATE TABLE sc_piepagina_edocta_factelect 
      (
        idreg           integer,
        fecha_emision   date,
        num_cuenta      char(20),
        secuencia       integer,
        nlinea          integer,
        mensaje         char(255)
      ) 
    fragment by round robin in dbs_movhis1, dbs_movhis2, dbs_movhis3
    extent size 3684780 next size 2210868 lock mode row;
    
    CREATE INDEX idx_piepagina_fe ON sc_piepagina_edocta_factelect(fecha_emision) IN dbs_movhis_idx1 ONLINE;
    CREATE INDEX idx_piepagina_fe2 ON sc_piepagina_edocta_factelect(fecha_emision, idreg) IN dbs_movhis_idx1 ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE sc_piepagina_edocta_factelect; 
       
    
    CREATE TABLE sc_grafica_fe 
      (
        id_reg              integer,
        fecha_emision       date,
        num_cuenta          char(20),
        saldo_inicial       money(16,2),
        saldo_final         money(16,2),
        retiros_efectivo    money(16,2),
        depositos           money(16,2),
        intereses           money(16,2),
        comisiones          money(16,2),
        comisiones_iva      money(16,2),
        otros_cargos        money(16,2),
        gat                 decimal(9,6),
        gat_real            decimal(9,6)
      ) 
    fragment by round robin in dbs_movhis1, dbs_movhis2, dbs_movhis3  
    extent size 1368636 next size 821181 lock mode row;  
    
    CREATE INDEX idx_graficafe ON sc_grafica_fe(fecha_emision) IN dbs_movhis_idx1 ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE sc_grafica_fe; 
       
       
    -- // VERIFICA QUE SE HAYAN CREADO TODAS LAS TABLAS
    SELECT COUNT(*)
      INTO vExisteTabla1
      FROM sc_encabezado_edocta_factelect;
       
    SELECT COUNT(*)
      INTO vExisteTabla2
      FROM sc_encabezado2_edocta_factelect;
       
    SELECT COUNT(*)
      INTO vExisteTabla3
      FROM sc_detalle_edocta_factelect;
       
    SELECT COUNT(*)
      INTO vExisteTabla4
      FROM sc_mensajes_edocta_factelect;
       
    SELECT COUNT(*)
      INTO vExisteTabla5
      FROM sc_piepagina_edocta_factelect;
       
    SELECT COUNT(*)
      INTO vExisteTabla6
      FROM sc_grafica_fe;
       
    IF vExisteTabla1 = 0 AND vExisteTabla2 = 0 AND vExisteTabla3 = 0 AND vExisteTabla4 = 0 AND vExisteTabla5 = 0 AND vExisteTabla6 = 0 THEN
        LET vCodRet1 = '000';
        LET vCodRet2 = '000';
        LET vCodRet3 = 'PROCESO FINALIZADO CORRECTAMENTE';
        
        LET vcSql = 'echo " UPDATE bdicheq:sc_contproc_edocta_factelect '||
                    'SET status_proc = '''||'F'||''', '||
                    'hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), '||
                    'cod_ret = '''||vCodRet1||''', mensaje = '''||vCodRet3||''' '||
                    'WHERE fecha >= '''||vPriDiaMes||''' AND proceso = '''||'DEPURACION DE TABLAS'||''' AND tipo_proc = '''||'D'||''';" > /tmp/depuratblcfd.sql';
        SYSTEM vcSql;
        LET vcStmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/depuratblcfd.sql';  
        SYSTEM vcStmt;
    ELSE
        LET vCodRet1 = '111';
        LET vCodRet2 = '111';
        LET vCodRet3 = 'PROCESO FINALIZADO INCORRECTAMENTE. VERIFIQUE.';
        
        LET vcSql = 'echo " UPDATE bdicheq:sc_contproc_edocta_factelect '||
                    'SET status_proc = '''||'F'||''', '||
                    'hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), '||
                    'cod_ret = '''||vCodRet1||''', mensaje = '''||vCodRet3||''' '||
                    'WHERE fecha >= '''||vPriDiaMes||''' AND proceso = '''||'DEPURACION DE TABLAS'||''' AND tipo_proc = '''||'D'||''';" > /tmp/depuratblcfd.sql';
        SYSTEM vcSql;
        LET vcStmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/depuratblcfd.sql'; 
        SYSTEM vcStmt;
    END IF;
    
    END;
    
    RETURN vCodRet1;
    
END PROCEDURE;