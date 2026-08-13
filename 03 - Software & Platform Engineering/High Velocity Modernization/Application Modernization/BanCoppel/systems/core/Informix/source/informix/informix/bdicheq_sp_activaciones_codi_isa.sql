CREATE PROCEDURE "informix".sp_activaciones_codi_isa( pEmpresa char(3) )
RETURNING CHAR(6), CHAR(9);
       
    DEFINE sql_err 			            INTEGER;
	DEFINE isam_err 		            INTEGER;
	DEFINE error_info		            CHAR(150);
	DEFINE cMensaje 		            CHAR(80);
	DEFINE cCod_ret                     CHAR(6);
    DEFINE vComienza            INTEGER;
    DEFINE vEnTransacc          SMALLINT;
    DEFINE vContador1           INTEGER;
    DEFINE vContador2           INTEGER;
    DEFINE vFechaHoy            DATE;
	DEFINE vFechadia			date;
	DEFINE vFechadiault			date;
	DEFINE vFechaAct			char(10);
    DEFINE vfecha_ant           DATE;
    DEFINE vsql                 CHAR(1200);
    DEFINE vstmt                CHAR(250);
    DEFINE vfecha               char(10);
    DEFINE vnum_cliente         CHAR(9);
	DEFINE vfecha_reg			char(20);
	DEFINE vsuc_registro		CHAR(4);
	DEFINE vnum_empleado		char(8);
	DEFINE vclaveopcionpuesto	integer;
	DEFINE vsec_ingreso			integer;
	DEFINE dtHoraFin     		DATETIME HOUR TO SECOND;
	DEFINE vhora				char(4);
    
	--SET DEBUG FILE TO "/resplogifx/conciliachq/activacionesCoDi/sp_respuesta_isa.out";
    --TRACE ON;
      LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
	
    LET vComienza         = -1;
    LET vEnTransacc       = 0;
    LET vContador1        = 0;
    LET vContador2        = 0;
    LET vFechaHoy         = '';
	LET vfecha_ant		  = '';
	LET vFechadia		  = '';
	LET vFechadiault	  = '';
	LET vFechaAct		  = '';
    LET vsql              = '';
    LET vstmt             = '';
    LET vfecha            = '';
    LET vnum_cliente         = '';
	LET vfecha_reg			= '';
	LET vsuc_registro		= '';
	LET vnum_empleado		= '';
	LET vclaveopcionpuesto	= 0;
	LET vsec_ingreso		= 0;
	LET vhora			  = '';
    
	
	BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		RETURN cCod_ret,vnum_cliente;
	END EXCEPTION;
        
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy , fecha_ant, pri_dia_mes -1
      INTO vFechaHoy, vfecha_ant, vFechadiault
      FROM sc_fechas
     WHERE empresa = pEmpresa;
	 
	--Se truncan la tabla de activaciones diario porque es nuevo archivo
	TRUNCATE TABLE sc_activaciones_codi;
	 
	--Se carga archivo del día actual
		LET vsql = '';
		LET vsql = 'echo "FILE /resplogifx/conciliachq/activacionesCoDi/activaciones_codi.txt DELIMITER ' || "'" || '|' || "'" || ' 2;' ||
				   ' insert into sc_activaciones_codi;" > /resplogifx/conciliachq/activacionesCoDi/cargaarchivo_codi.com';
		System vsql;

		LET vsql = '';
		Let vsql = ' echo "dbload -d bdicheq -c /resplogifx/conciliachq/activacionesCoDi/cargaarchivo_codi.com -l cargaarchivo_codi.log -n 1000 -k" > /resplogifx/conciliachq/activacionesCoDi/cargaarchivo_codi.sh';
		--LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/activacionesCoDi/cargaarchivo_codi.sql';
		SYSTEM vsql; 
		LET vsql = '';
		
		SYSTEM '/usr/bin/chmod 777 /resplogifx/conciliachq/activacionesCoDi/cargaarchivo_codi.sh'; 
		SYSTEM '/usr/bin/sh /resplogifx/conciliachq/activacionesCoDi/cargaarchivo_codi.sh'; 
		
     --Se trunca las tabla solo los días 2 de cada mes
		 IF DAY(vFechaHoy) = '02' THEN
			
			TRUNCATE TABLE sc_activa_codi_isa;
			
		 END IF;
	 
	
        FOREACH WITH HOLD
            SELECT unique num_cliente--, fecha_reg
              INTO vnum_cliente--, vfecha_reg
              FROM bdicheq:sc_activaciones_codi 
			 --where num_cliente is not null
			  
			 
			--Validar que sea cliente con negocio propio
			select max(sec_ingreso)
			  INTO vsec_ingreso
			  from bdinteg:si_ingresos
			 where empresa = pEmpresa
			   and numcte = vnum_cliente;
			   
			select claveopcionpuesto
				  INTO vclaveopcionpuesto
				  from bdinteg:si_ingresos
				 where empresa = pEmpresa
				   and numcte = vnum_cliente
				   and sec_ingreso = vsec_ingreso;

			
			IF vclaveopcionpuesto <> 3 THEN
				CONTINUE FOREACH;
			END IF;
			 
			--para el caso que no tengamos Indice de satisfaccion este mes
			  SELECT bpi.suc_registro, bpi.num_empleado
			    INTO vsuc_registro,vnum_empleado
			    FROM bdinteg:si_bpiusuarios bpi
			   WHERE bpi.empresa = pEmpresa
			     AND bpi.numcte = vnum_cliente;
			 
			IF vsuc_registro is null OR vnum_empleado is null THEN
				CONTINUE FOREACH;
			END IF;
            
                INSERT INTO sc_activa_codi_isa
                ( fecha_reg, sucursal, promotor, num_cliente )
                VALUES
                ( vfecha_ant, vsuc_registro, vnum_empleado, vnum_cliente );
               
            LET vContador2 = vContador2 + 1;
            
            /*IF vContador2 >= 500 THEN
                LET vContador2 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;*/
        END FOREACH;
    
    -- LET vFechaAct = TO_CHAR(vFechadia, '%d/%m/%Y');
    LET vfecha = TO_CHAR(vfecha_ant, '%d_%m_%Y');
	
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
		INTO dtHoraFin 
	FROM sysmaster:"informix".sysshmvals;
	
	LET vhora = substr(dtHoraFin,1,2)||substr(dtHoraFin,4,5);
    
    LET vsql = '';
    LET vsql = 'echo "FECHA|SUCURSAL|PROMOTOR|'||
					'NUM_CLIENTE|" > /resplogifx/conciliachq/activacionesCoDi/KPI_Seguimiento_CODI_'||vfecha||'_'||vhora||'.txt.enc';
    SYSTEM vsql;
    LET vsql = '';
 
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/activacionesCoDi/KPI_Seguimiento_CODI_'||vfecha||'_'||vhora||'.txt.det '||
               'SELECT distinct TO_CHAR(a.fecha_reg, ''%d/%m/%Y''), a.sucursal, a.promotor, a.num_cliente '||
               'FROM bdicheq:sc_activa_codi_isa a '||
			   'order by 1;" > /resplogifx/conciliachq/activacionesCoDi/activaciones_isa.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/activacionesCoDi/activaciones_isa.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
    
    LET vsql = '';
    LET vsql = 'cat /resplogifx/conciliachq/activacionesCoDi/KPI_Seguimiento_CODI_'||vfecha||'_'||vhora||'.txt.enc /resplogifx/conciliachq/activacionesCoDi/KPI_Seguimiento_CODI_'||vfecha||'_'||vhora||'.txt.det > /resplogifx/conciliachq/activacionesCoDi/KPI_Seguimiento_CODI_'||vfecha||'_'||vhora||'.txt';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vsql = '';
    LET vsql = 'rm /resplogifx/conciliachq/activacionesCoDi/KPI_Seguimiento_CODI_'||vfecha||'_'||vhora||'.txt.enc';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vsql = '';
    LET vsql = 'rm /resplogifx/conciliachq/activacionesCoDi/KPI_Seguimiento_CODI_'||vfecha||'_'||vhora||'.txt.det';
    SYSTEM vsql;
    LET vsql = '';
 
    END; 
    
    RETURN cCod_ret, vnum_cliente;
    
END PROCEDURE;