CREATE PROCEDURE "informix".sp_conciliachqfinal( pempresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50);
      
    DEFINE vcodret1     	CHAR(5);
    DEFINE vcodret2     	CHAR(5);
    DEFINE vcodret3     	CHAR(50);
    DEFINE sql_err      	INTEGER;
    DEFINE isam_err     	INTEGER;
    DEFINE desc_err     	CHAR(50);
    DEFINE vsql             CHAR(600);
    DEFINE vstmt            CHAR(250);
    DEFINE vfecha           CHAR(8);
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha_ant       DATE;
    DEFINE vpri_hab_mes     DATE;
    DEFINE vfecha_actual    DATE;
    DEFINE vproceso         CHAR(16);
    DEFINE vsistema         CHAR(2);
    DEFINE vexiste          INTEGER;
    DEFINE vexistefin       INTEGER;
    DEFINE vusuario         CHAR(10);
    DEFINE vfechaprocsdo    DATE;
    DEFINE vexisteconcil    SMALLINT;
    DEFINE vexisteconcil1   SMALLINT;
    DEFINE vexisteconcil2   SMALLINT;
    DEFINE vexisteconcil3   SMALLINT;
    DEFINE vexisteconcil4   SMALLINT;
    DEFINE vexisteconcil5   SMALLINT;
    DEFINE vexisteconcil6   SMALLINT;
    DEFINE vexisteconcil7   SMALLINT;
    DEFINE vexisteconcil8   SMALLINT;
    DEFINE vexisteconcil9   SMALLINT;
    DEFINE vexisteconcil10  SMALLINT;
	DEFINE vfecha2			CHAR(6);
	DEFINE v_fecha          DATE;
	DEFINE v_cuenta		    CHAR(20);  
	DEFINE v_producto       CHAR(4); 
	DEFINE v_num_cte        CHAR(20);      
	DEFINE v_sucursal       CHAR(4);
	DEFINE v_ejecutivo      CHAR(8);
	DEFINE v_capital_anterior    MONEY (18,2);
	DEFINE v_movs_cargo          MONEY (18,2);
	DEFINE v_movs_abono          MONEY (18,2);
	DEFINE v_capital_calculado   MONEY (18,2);
	DEFINE v_capital_actual      MONEY (18,2);
	DEFINE v_diferencia_capital  MONEY (18,2);
	DEFINE v_interes_anterior    MONEY (18,2);
	DEFINE v_movs_cargo_interes  MONEY (18,2);
	DEFINE v_movs_abono_interes  MONEY (18,2);
	DEFINE v_interes_calculado 	 MONEY (18,2);
	DEFINE v_interes_actual      MONEY (18,2);
	DEFINE v_diferencia_interes  MONEY (18,2);
	
	DEFINE v_total                  INTEGER;
    DEFINE v_tot_capital_anterior   MONEY (18,2);
    DEFINE v_tot_capital_calculado  MONEY (18,2);
    DEFINE v_tot_capital_actual     MONEY (18,2);
    DEFINE v_tot_interes_anterior   MONEY (18,2);
    DEFINE v_tot_interes_calculado  MONEY (18,2);
    DEFINE v_tot_interes_actual     MONEY (18,2);

	    
    LET vcodret1        = '000';
    LET vcodret2        = '000';
    LET vcodret3        = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err	        = 0;
    LET isam_err        = 0;
    LET desc_err        = '';
    LET vsql            = '';
    LET vstmt           = '';
    LET vfecha          = '';
    LET vfecha_hoy      = ''; 
    LET vfecha_ant      = '';
    LET vpri_hab_mes    = '';
    LET vfecha_actual   = '';
    LET vproceso        = 'conciliachqfinal';
    LET vsistema        = '01';
    LET vexiste         = 0;
    LET vexistefin      = 0;
    LET vusuario        = user;
    LET vfechaprocsdo   = '';
    LET vexisteconcil   = 0;
    LET vexisteconcil1  = 0;
    LET vexisteconcil2  = 0;
    LET vexisteconcil3  = 0;
    LET vexisteconcil4  = 0;
    LET vexisteconcil5  = 0;
    LET vexisteconcil6  = 0;
    LET vexisteconcil7  = 0;
    LET vexisteconcil8  = 0;
    LET vexisteconcil8  = 0;
    LET vexisteconcil10 = 0;
	LET vfecha2         = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliachqfinal.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'C'||''','||
                       'codret        = '''||vcodret1||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horasconcilchqfin.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchqfin.sql';
            SYSTEM vstmt;
            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;
    
    /* #######################################################################
    ON EXCEPTION IN (-668)
        LET vcodret1 = '668';
        LET vcodret2 = '668';
        LET vcodret3 = 'PROBLEMAS EN LA DESCARGA DE ARCHIVOS VERIFIQUE';
    END EXCEPTION WITH RESUME;
    ####################################################################### */

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliachqfinal.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE LAS FECHAS DEL SISTEMA
    SELECT fecha_hoy, fecha_ant, pri_hab_mes, fecha_hoy
      INTO vfecha_hoy, vfecha_ant, vpri_hab_mes, vfecha_actual
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    -- // VALIDA LA FECHA DE AYER
    LET vfecha_hoy = vfecha_hoy - 1 UNITS DAY;
    
    CALL sp_valfechabil(vfecha_hoy, '-') 
    RETURNING vcodret1, vfecha_hoy;
    
    -- // VALIDA LA FECHA DE ANTIER
    LET vfecha_ant = vfecha_ant - 1 UNITS DAY;
    
    CALL sp_valfechabil(vfecha_ant, '-') 
    RETURNING vcodret1, vfecha_ant;
    
    -- // VERIFICA QUE TODOS LOS COMPLEMENTOS HAYAN FINALIZADO
    select count(*)
      into vexisteconcil
      from bdinteg:sx_contproc
     where proceso = "conciliachq"
       and fecha   = vfecha_hoy
       and sistema = vsistema
       and status_proc = 'F';
       
    select count(*)
      into vexisteconcil1
      from bdinteg:sx_contproc
     where proceso = "conciliachqcomp1"
       and fecha   = vfecha_hoy
       and sistema = vsistema
       and status_proc = 'F';
       
    select count(*)
      into vexisteconcil2
      from bdinteg:sx_contproc
     where proceso = "conciliachqcomp2"
       and fecha   = vfecha_hoy
       and sistema = vsistema
       and status_proc = 'F';
       
    select count(*)
      into vexisteconcil3
      from bdinteg:sx_contproc
     where proceso = "conciliachqcomp3"
       and fecha   = vfecha_hoy
       and sistema = vsistema
       and status_proc = 'F';
       
    select count(*)
      into vexisteconcil4
      from bdinteg:sx_contproc
     where proceso = "conciliachqcomp4"
       and fecha   = vfecha_hoy
       and sistema = vsistema
       and status_proc = 'F';
       
    select count(*)
      into vexisteconcil5
      from bdinteg:sx_contproc
     where proceso = "conciliachqcomp5"
       and fecha   = vfecha_hoy
       and sistema = vsistema
       and status_proc = 'F';
       
    select count(*)
      into vexisteconcil6
      from bdinteg:sx_contproc
     where proceso = "conciliachqcomp6"
       and fecha   = vfecha_hoy
       and sistema = vsistema
       and status_proc = 'F';
       
    select count(*)
      into vexisteconcil7
      from bdinteg:sx_contproc
     where proceso = "conciliachqcomp7"
       and fecha   = vfecha_hoy
       and sistema = vsistema
       and status_proc = 'F';
       
    select count(*)
      into vexisteconcil8
      from bdinteg:sx_contproc
     where proceso = "conciliachqcomp8"
       and fecha   = vfecha_hoy
       and sistema = vsistema
       and status_proc = 'F';
       
    select count(*)
      into vexisteconcil9
      from bdinteg:sx_contproc
     where proceso = "conciliachqcomp9"
       and fecha   = vfecha_hoy
       and sistema = vsistema
       and status_proc = 'F';
       
    select count(*)
      into vexisteconcil10
      from bdinteg:sx_contproc
     where proceso = "conciliachqcomp10"
       and fecha   = vfecha_hoy
       and sistema = vsistema
       and status_proc = 'F';
    
    if ( vexisteconcil <= 0 or vexisteconcil1 <= 0 or vexisteconcil2 <= 0 or vexisteconcil3 <= 0 or vexisteconcil4 <= 0 or vexisteconcil5 <= 0 or
         vexisteconcil6 <= 0 or vexisteconcil7 <= 0 or vexisteconcil8 <= 0 or vexisteconcil9 <= 0 or vexisteconcil10 <= 0 ) then
        let vcodret1 = "978";
        
        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET ejecutivo = '''||vusuario||''','||
                   'status_proc   = '''||'C'||''','||
                   'codret        = '''||vcodret1||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horasconcilchqfin.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchqfin.sql';
        SYSTEM vstmt;
           
        return vcodret1, vcodret2, vcodret3;
    end if;
    
    -- // GUARDA REGISTRO DE CONTROL EN TABLA DE INTEGRAL
    select count(*)
      into vexiste
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = vproceso
       and fecha   = vfecha_hoy
       and sistema = vsistema;

    if vexiste = 0 then
        LET vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso||''', '''||vfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||vusuario||''','||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horasconcilchqfin.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchqfin.sql';
        SYSTEM vstmt;
    else
        SELECT count(*)
          INTO vexistefin
          FROM bdinteg:sx_contproc
         WHERE empresa     = pempresa
           AND proceso     = vproceso
           AND fecha       = vfecha_hoy
           AND sistema     = vsistema
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horasconcilchqfin.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchqfin.sql';
            SYSTEM vstmt;
        ELSE
            LET vcodret1 = "958";
            LET vcodret2 = "958";
            
            SELECT descripcion
              INTO vcodret3
              FROM bdinteg:si_codret
             WHERE sistema = vsistema
               AND codigo_retorno = vcodret1;

            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    end if;

	-- // Llena Tablas para ConciliaciÃ³n de Saldos Aplicativos vs Contables
    EXECUTE PROCEDURE bdicheq:"informix".sp_ins_concilsdo(pempresa, vfecha_hoy) 
    INTO vcodret2;
    
    UPDATE STATISTICS MEDIUM FOR TABLE conciliachq;
    UPDATE STATISTICS MEDIUM FOR TABLE conciliachq_dif;

    LET vfecha = TO_CHAR(vfecha_hoy, '%d%m%Y');
	LET vfecha2 = TO_CHAR(vfecha_hoy, '%Y%m');
    
    -- // GENERA EL ARCHIVO DE TODAS LAS CUENTAS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/conciliachq_'||vfecha||'.txt '||
               'SELECT fecha, cuenta, producto, num_cte, sucursal, ejecutivo, '||
               'capital_anterior, movs_cargo, movs_abono, capital_calculado, capital_actual, diferencia_capital, '||
               'interes_anterior, movs_cargo_interes, movs_abono_interes, interes_calculado, interes_actual, diferencia_interes '||
               'FROM conciliachq WHERE cuenta is not null AND fecha = '''||vfecha_hoy||''' ORDER BY cuenta;" > /resplogifx/conciliachq/concilia.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/concilia.sql"; 
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = '/usr/bin/split -1000000 /resplogifx/conciliachq/conciliachq_'||vfecha||'.txt /resplogifx/conciliachq/conciliachq_'||vfecha;
    SYSTEM vsql;
	
	IF vfecha_actual = vpri_hab_mes THEN
		LET vsql = '';
		LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/conciliachq_R2421_'||vfecha2||'.txt '||
				   ' SELECT sucursal, producto, genero, COUNT(*), SUM(capital_actual), SUM(interes_actual) '||
                   ' FROM conciliachq WHERE capital_actual >= 0 GROUP BY 1, 2, 3;" > /resplogifx/conciliachq/conciliar2421.sql';
		SYSTEM vsql;
		
		LET vsql = '';
		LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/conciliar2421.sql"; 
		SYSTEM vsql;
	END IF;
    
    -- // GENERA EL ARCHIVO DE DIFERENCIAS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/conciliachqdif_'||vfecha||'.txt '||
               'SELECT fecha, cuenta, producto, num_cte, sucursal, ejecutivo, '||
               'capital_anterior, movs_cargo, movs_abono, capital_calculado, capital_actual, diferencia_capital, '||
               'interes_anterior, movs_cargo_interes, movs_abono_interes, interes_calculado, interes_actual, diferencia_interes '||
               'FROM conciliachq_dif WHERE cuenta is not null AND fecha = '''||vfecha_hoy||''' ORDER BY cuenta" > /resplogifx/conciliachq/concilia.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/concilia.sql"; 
    SYSTEM vsql;
    
    -- // LLENA TABLA sc_conciliachqdif PARA REPORTES EN SOC - TASF

	FOREACH WITH HOLD
            
			SELECT fecha,                cuenta,              producto,            num_cte,              sucursal,             ejecutivo,          capital_anterior, 
	               movs_cargo,           movs_abono,          capital_calculado,   capital_actual,       diferencia_capital,   interes_anterior,   movs_cargo_interes, 
	        	   movs_abono_interes,   interes_calculado,   interes_actual,      diferencia_interes
	        INTO   v_fecha,              v_cuenta,		      v_producto,          v_num_cte,            v_sucursal,           v_ejecutivo,        v_capital_anterior, 
	               v_movs_cargo,         v_movs_abono,        v_capital_calculado, v_capital_actual,     v_diferencia_capital, v_interes_anterior, v_movs_cargo_interes, 
                   v_movs_abono_interes, v_interes_calculado, v_interes_actual,    v_diferencia_interes
		    FROM   conciliachq_dif
			
			INSERT INTO sc_conciliachqdif VALUES (v_fecha,v_cuenta,v_producto,v_num_cte,v_sucursal,v_ejecutivo,v_capital_anterior,v_movs_cargo,v_movs_abono,v_capital_calculado,v_capital_actual,v_diferencia_capital,v_interes_anterior,v_movs_cargo_interes,v_movs_abono_interes,v_interes_calculado,v_interes_actual,v_diferencia_interes);            
	
	END FOREACH; 	
			
    
    -- // GENERA ARCHIVO DE GLOBALES POSITIVOS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/conciliachqglob_'||vfecha||'.txt '||
               'SELECT producto, COUNT(*), SUM(capital_anterior), SUM(capital_calculado), SUM(capital_actual), SUM(interes_anterior), SUM(interes_calculado), SUM(interes_actual) '||
               'FROM conciliachq WHERE cuenta is not null AND fecha = '''||vfecha_hoy||''' AND capital_actual >= 0 GROUP BY producto ORDER BY producto" > /resplogifx/conciliachq/concilia.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/concilia.sql"; 
    SYSTEM vsql;
    
    -- // LLENA TABLA sc_conciliachqglob PARA REPORTES EN SOC - TASF
    
	LET v_fecha    = '';
	LET v_producto = '';
	
	FOREACH WITH HOLD
            
			SELECT fecha,   producto,   COUNT(*), SUM(capital_anterior),  SUM(capital_calculado),  SUM(capital_actual),  SUM(interes_anterior),  SUM(interes_calculado),  SUM(interes_actual)
            INTO   v_fecha, v_producto, v_total,  v_tot_capital_anterior, v_tot_capital_calculado, v_tot_capital_actual, v_tot_interes_anterior, v_tot_interes_calculado, v_tot_interes_actual
	        FROM   conciliachq
            WHERE  cuenta is not null
            AND    fecha = vfecha_hoy
            AND    capital_actual >= 0
            GROUP BY 1, 2
            ORDER BY 2
			
			INSERT INTO sc_conciliachqglob VALUES (v_fecha, v_producto, v_total, v_tot_capital_anterior, v_tot_capital_calculado, v_tot_capital_actual, v_tot_interes_anterior, v_tot_interes_calculado, v_tot_interes_actual);
	
	END FOREACH; 
	
    	
    -- // GENERA ARCHIVO DE GLOBALES NEGATIVOS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/conciliachqglobneg_'||vfecha||'.txt '||
               'SELECT producto, COUNT(*), SUM(capital_anterior), SUM(capital_calculado), SUM(capital_actual), SUM(interes_anterior), SUM(interes_calculado), SUM(interes_actual) '||
               'FROM conciliachq WHERE cuenta is not null AND fecha = '''||vfecha_hoy||''' AND capital_actual < 0 GROUP BY producto ORDER BY producto" > /resplogifx/conciliachq/concilia.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/concilia.sql"; 
    SYSTEM vsql;
    
    
	--- INICIALIZAR VARIABLES 
	LET v_fecha                 = '';
	LET v_producto              = '';
	LET v_total                 = 0;
	LET v_tot_capital_anterior  = 0;
	LET v_tot_capital_calculado = 0;
	LET v_tot_capital_actual    = 0;
	LET v_tot_interes_anterior  = 0; 
	LET v_tot_interes_calculado = 0;
	LET v_tot_interes_actual    = 0;
		
	FOREACH WITH HOLD
	
            SELECT fecha,   producto,   COUNT(*), SUM(capital_anterior),  SUM(capital_calculado),  SUM(capital_actual),  SUM(interes_anterior),  SUM(interes_calculado),  SUM(interes_actual)
            INTO   v_fecha, v_producto, v_total,  v_tot_capital_anterior, v_tot_capital_calculado, v_tot_capital_actual, v_tot_interes_anterior, v_tot_interes_calculado, v_tot_interes_actual
	        FROM   conciliachq
            WHERE  cuenta is not null
            AND    fecha = vfecha_hoy
            AND    capital_actual < 0
            GROUP BY 1, 2
            ORDER BY 2
			
			INSERT INTO sc_conciliachqglobneg VALUES (v_fecha, v_producto, v_total,  v_tot_capital_anterior, v_tot_capital_calculado, v_tot_capital_actual, v_tot_interes_anterior, v_tot_interes_calculado, v_tot_interes_actual);
			
	END FOREACH;
    
    -- // GUARDA HORA FINAL DEL PROCESO
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET ejecutivo = '''||vusuario||''','||
               'status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret1||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horasconcilchqfin.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchqfin.sql';
    SYSTEM vstmt;
           
    END;

    RETURN vcodret1, vcodret2, vcodret3;

END PROCEDURE;