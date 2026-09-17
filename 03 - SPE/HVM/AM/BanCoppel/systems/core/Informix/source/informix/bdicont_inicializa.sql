CREATE PROCEDURE "informix".inicializa(pempresa char(3),pfecha_hoy date)

DEFINE sql_err INTEGER;

DEFINE dpri_dia_mes    date;
DEFINE dpri_hab_mes    date;
DEFINE dult_dia_mes    date;
DEFINE dult_hab_mes    date;
DEFINE dfecha_ant      date;
DEFINE v_fecha_mes_sald date;
DEFINE v_fecha_sald_temp char(10);
DEFINE mes_sald        char(2);
DEFINE v_fecha_mes_hist date;
DEFINE v_fecha_hist_temp char(10);
DEFINE mes_hist        char(2);
DEFINE v_mes           char(2);
DEFINE v_meshist      char(2);
DEFINE v_mesc1         char(2);
DEFINE v_mesc2         char(2);
DEFINE v_amo           char(4);
DEFINE v_amohist       char(4);
DEFINE v_numcols       smallint;
DEFINE v_sql           char(400);
DEFINE nomb_tabla      char(5);
DEFINE v_tabla         char(20);
DEFINE m_ant           char(2);
DEFINE v_anomeshist    char(7);
DEFINE v_tablaid       integer;
DEFINE v_colnomb       char(20);
DEFINE p_rowid 	       int;
DEFINE pcontador       int;

	--set debug file to "/tmp/inicializa.out";
	--trace on;

	SET LOCK MODE TO WAIT 3;

	SELECT pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes, fecha_ant
	  INTO dpri_dia_mes,dpri_hab_mes,dult_dia_mes,dult_hab_mes,dfecha_ant
	  FROM bdicont:co_fechas
	 WHERE empresa = pempresa;

	SELECT mescierre1    ,mescierre2
	  INTO v_mesc1,v_mesc2
	  FROM bdicont:co_param
     WHERE empresa = pempresa;

   
	   SELECT meses_saldos,meses_historia
	   INTO mes_sald,mes_hist
	   FROM co_param
	   WHERE empresa = pempresa;

	   LET v_fecha_mes_sald = pfecha_hoy - mes_sald units MONTH;
	   LET v_fecha_mes_hist = pfecha_hoy - mes_hist units MONTH;

	   LET v_mes = month(v_fecha_mes_sald);
	   LET v_meshist = month(v_fecha_mes_hist);

	   IF v_mes < 10 then
	      LET v_mes = "0"||v_mes;
	   END IF
	   LET v_amo = year(v_fecha_mes_sald);

	   IF v_meshist < 10  then
	      LET v_meshist = "0"||v_meshist;
	   END IF
	   LET v_amohist = year(v_fecha_mes_hist);

	   LET v_fecha_sald_temp = v_mes||"01"||v_amo;
	   LET v_fecha_mes_sald = v_fecha_sald_temp;

	   LET v_fecha_hist_temp = v_meshist||"01"||v_amohist;
	   LET v_fecha_mes_hist = v_fecha_hist_temp;

	   LET v_anomeshist = v_amohist||"-"||v_meshist;

	   BEGIN WORK;
	       INSERT INTO bdicont:co_contproc_inicializa (empresa,proceso,fecha,cod_ret) VALUES ('001','fechas',pfecha_hoy,'000');
	   COMMIT WORK;

	IF pfecha_hoy = dult_hab_mes THEN 	   -- borra registros de tablas historicas --

	   LET pcontador = 0;

	    FOREACH WITH HOLD
			SELECT ROWID 
              INTO p_rowid 
		      FROM bdicont:co_historico 
		     WHERE empresa = pempresa
               AND ccmayor IS NOT NULL
			   AND ccsub IS NOT NULL
               AND ccsubsub IS NOT NULL
			   AND ccssubsub IS NOT NULL
			   AND ccsssubsub IS NOT NULL
			   AND sector IS NOT NULL
			   AND nro_auxiliar IS NOT NULL
			   AND moneda IS NOT NULL
			   AND sucursal > 0
			   AND ciudad IS NOT NULL
			   AND fecha_valida < v_fecha_mes_hist

			IF pcontador = 0 then
				BEGIN WORK;
			END IF 

	    DELETE FROM bdicont:co_historico 
	          WHERE ROWID = p_rowid;
	    
		LET pcontador = pcontador + 1;

	    IF pcontador = 10000 THEN
	       COMMIT WORK;
	       LET pcontador = 0;
	    END IF
	    
		END FOREACH;

	    IF pcontador > 0 THEN
	       COMMIT WORK;
	    END IF

	    BEGIN WORK;
			INSERT INTO bdicont:co_contproc_inicializa (empresa,proceso,fecha,cod_ret) values ('001','co_historico',pfecha_hoy,'000');
	    COMMIT WORK;

	    LET pcontador = 0;

	    FOREACH WITH HOLD
			SELECT ROWID INTO p_rowid 
			  FROM bdicont:co_histsdodias 
			 WHERE empresa = pempresa 
			   AND mes_dia < v_fecha_mes_sald
	    
			IF pcontador = 0 THEN
				BEGIN WORK;
			END IF 
	     
	    DELETE FROM bdicont:co_histsdodias
	     WHERE ROWID = p_rowid;

	    LET pcontador = pcontador + 1;

	    IF pcontador = 10000 THEN
	       COMMIT WORK;
	       LET pcontador = 0;
	    END IF

	    END FOREACH;

	    IF pcontador > 0 THEN
	       COMMIT WORK;
	    END IF

	    BEGIN WORK;
			INSERT INTO bdicont:co_contproc_inicializa (empresa,proceso,fecha,cod_ret) values ('001','co_histsdodias',pfecha_hoy,'000');
	    COMMIT WORK;

		LET pcontador = 0;

	    FOREACH WITH HOLD
			SELECT ROWID INTO p_rowid 
              FROM bdicont:co_histdiasaux 
	         WHERE empresa = pempresa 
			   AND mes_dia < v_fecha_mes_sald

	    IF pcontador = 0 THEN
			BEGIN WORK;
	    END IF 

	    DELETE FROM bdicont:co_histdiasaux 
	     WHERE ROWID = p_rowid;

	    LET pcontador = pcontador + 1;

	    IF pcontador = 10000 THEN
	       COMMIT WORK;
	       LET pcontador = 0;
	    END IF

	    END FOREACH;

	    IF pcontador > 0 THEN
			COMMIT WORK;
	    END IF

	    BEGIN WORK;
			INSERT INTO bdicont:co_contproc_inicializa (empresa,proceso,fecha,cod_ret) values ('001','co_histdiasaux',pfecha_hoy,'000');
	    COMMIT WORK;

	END IF

	IF pfecha_hoy = dpri_hab_mes THEN

		LET pcontador = 0;

	    FOREACH WITH HOLD
			SELECT ROWID INTO p_rowid 
		      FROM bdicont:co_sdomes
			 WHERE empresa = pempresa
               AND ccmayor IS NOT NULL
			   AND ccsub IS NOT NULL
               AND ccsubsub IS NOT NULL
			   AND ccssubsub IS NOT NULL
			   AND ccsssubsub IS NOT NULL
			   AND sector IS NOT NULL
			   AND ciudad IS NOT NULL
		       AND sucursal > 0
			   AND moneda IS NOT NULL
               AND ano_mes < v_anomeshist
	     
	    IF pcontador = 0 THEN
			BEGIN WORK;
	    END IF 

	    DELETE FROM bdicont:co_sdomes
	     WHERE ROWID = p_rowid;

	    LET pcontador = pcontador + 1;

	    IF pcontador = 10000 THEN
			COMMIT WORK;
	        LET pcontador = 0;
	    END IF

	    END FOREACH;

	    IF pcontador > 0 THEN
			COMMIT WORK;
	    END IF

	    BEGIN WORK;
			INSERT INTO bdicont:co_contproc_inicializa (empresa,proceso,fecha,cod_ret) values ('001','co_sdomes',pfecha_hoy,'000');
	    COMMIT WORK;

	   --- Limpiar los movimientos del mes anterior --
	    BEGIN WORK;
	      -- Obtiene el esquema de la tabla antes de drop
			LET v_sql ="dbschema -q -d bdicont -t co_mensual -p all tabla; sed /revoke/d tabla > tabla.sql";
			SYSTEM v_sql;

	      -- Elimina la tabla por drop y crea el esquema de la misma.
			LET v_sql ='echo "drop table bdicont:co_mensual" > query.sql';
			SYSTEM v_sql;
			LET v_sql = "dbaccess bdicont query.sql ";
			SYSTEM v_sql;

			LET v_sql = "dbaccess bdicont tabla 2>/dev/null > /dev/null";
			SYSTEM v_sql;

	    COMMIT WORK;

	    BEGIN WORK;
			INSERT INTO bdicont:co_contproc_inicializa (empresa,proceso,fecha,cod_ret) values ('001','drop_co_mensual',pfecha_hoy,'000');
	    COMMIT WORK;
	   
		BEGIN WORK;

			LET v_sql = 'echo "UNLOAD TO co_sdodias.unl' ||
	                  ' SELECT * FROM co_sdodias where empresa='|| pempresa ||' and month(mes_dia) = '|| month(pfecha_hoy) || '"' || ' > query.sql';

			SYSTEM v_sql;
			LET v_sql = "dbaccess bdicont query.sql ";
			SYSTEM v_sql;

			-- Obtiene el esquema de la tabla antes de drop
			LET v_sql ="dbschema -q -d bdicont -t co_sdodias -p all tabla; sed /revoke/d tabla > tabla.sql";
			SYSTEM v_sql;

			-- Elimina la tabla por drop y crea el esquema de la misma.
			LET v_sql ='echo "drop table bdicont:co_sdodias" > query.sql';
			SYSTEM v_sql;
			LET v_sql = "dbaccess bdicont query.sql ";
			SYSTEM v_sql;

			LET v_sql = "dbaccess bdicont tabla 2>/dev/null > /dev/null";
			SYSTEM v_sql;
	   
			LET v_sql = "echo "||'"'|| "file 'co_sdodias.unl' delimiter '|' "||
	                  20|| "; insert into co_sdodias"||";"||'"'||' > carga';

			SYSTEM v_sql;

			LET v_sql = "dbload -d bdicont -c carga -l er -n 100";
			SYSTEM v_sql;

		COMMIT WORK;

	    BEGIN WORK;
			INSERT INTO bdicont:co_contproc_inicializa (empresa,proceso,fecha,cod_ret) values ('001','load_co_sdodias',pfecha_hoy,'000');
	    COMMIT WORK;

	   CREATE VIEW co_saldos (empresa,ccmayor,ccsub,ccsubsub,ccssubsub,
	   ccsssubsub,sector,ciudad,sucursal,moneda,mes_dia,cargos_dia,
	   abonos_dia,nro_cargos_dia,nro_abonos_dia,dias_proyectado,
	   dias_acumulado,saldo_acumulado,saldo_inicio_dia,saldo_fin_de_dia,
	   nombre,rubro1,rubro2,rubro3,naturaleza_cta) as
	   select x0.empresa ,x0.ccmayor ,x0.ccsub ,x0.ccsubsub ,x0.ccssubsub
	     ,x0.ccsssubsub ,x0.sector ,x0.ciudad ,x0.sucursal ,x0.moneda
	     ,x0.mes_dia ,x0.cargos_dia ,x0.abonos_dia ,x0.nro_cargos_dia
	     ,x0.nro_abonos_dia ,x0.dias_proyectado ,x0.dias_acumulado
	     ,x0.saldo_acumulado ,x0.saldo_inicio_dia ,x0.saldo_fin_de_dia
	     ,x1.nombre ,x1.rubro1 ,x1.rubro2 ,x1.rubro3 ,x1.naturaleza_cta
	     from co_sdodias x0 ,bdinteg:si_catalog
	     x1 where (((((((x0.empresa = x1.empresa ) AND (x0.ccmayor
	     = x1.ccmayor ) ) AND (x0.ccsub = x1.ccsub ) ) AND (x0.ccsubsub
	     = x1.ccsubsub ) ) AND (x0.ccssubsub = x1.ccssubsub ) ) AND
	     (x0.ccsssubsub = x1.ccsssubsub ) ) AND (x0.sector = x1.sector
	     ) )  union select x2.empresa ,x2.ccmayor ,x2.ccsub ,x2.ccsubsub
	     ,x2.ccssubsub ,x2.ccsssubsub ,x2.sector ,x2.ciudad ,x2.sucursal
	     ,x2.moneda ,x2.mes_dia ,x2.cargos_dia ,x2.abonos_dia ,x2.nro_cargos_dia
	     ,x2.nro_abonos_dia ,x2.dias_proyectado ,x2.dias_acumulado
	     ,x2.saldo_acumulado ,x2.saldo_inicio_dia ,x2.saldo_fin_de_dia
	     ,x3.nombre ,x3.rubro1 ,x3.rubro2 ,x3.rubro3 ,x3.naturaleza_cta
	     from co_histsdodias x2 ,bdinteg:si_catalog
	     x3 where (((((((x2.empresa = x3.empresa ) AND (x2.ccmayor
	     = x3.ccmayor ) ) AND (x2.ccsub = x3.ccsub ) ) AND (x2.ccsubsub
	     = x3.ccsubsub ) ) AND (x2.ccssubsub = x3.ccssubsub ) ) AND
	     (x2.ccsssubsub = x3.ccsssubsub ) ) AND (x2.sector = x3.sector
	     ) ) ;

	    BEGIN WORK;
			INSERT INTO bdicont:co_contproc_inicializa (empresa,proceso,fecha,cod_ret) values ('001','view_co_saldos',pfecha_hoy,'000');
	    COMMIT WORK;
	   
	    BEGIN WORK;  
	   
			LET v_sql = 'echo "UNLOAD TO co_diasaux.unl' ||
	                    ' SELECT * FROM co_diasaux where empresa='|| pempresa ||' and month(mes_dia) = '|| month(pfecha_hoy) || '"' || ' > query.sql';

			SYSTEM v_sql;
			LET v_sql = "dbaccess bdicont query.sql ";
			SYSTEM v_sql;

			-- Obtiene el esquema de la tabla antes de drop
			LET v_sql ="dbschema -q -d bdicont -t co_diasaux -p all tabla; sed /revoke/d tabla > tabla.sql";
			SYSTEM v_sql;

			-- Elimina la tabla por drop y crea el esquema de la misma.
			LET v_sql ='echo "drop table bdicont:co_diasaux" > query.sql';
			SYSTEM v_sql;
			LET v_sql = "dbaccess bdicont query.sql ";
			SYSTEM v_sql;

			LET v_sql = "dbaccess bdicont tabla 2>/dev/null > /dev/null";
			SYSTEM v_sql;
	   
			LET v_sql = "echo "||'"'|| "file 'co_diasaux.unl' delimiter '|' "||
	                  21|| "; insert into co_diasaux"||";"||'"'||' > carga';

			SYSTEM v_sql;

			LET v_sql = "dbload -d bdicont -c carga -l er -n 100";
			SYSTEM v_sql;

		COMMIT WORK;

	    BEGIN WORK;
			INSERT INTO bdicont:co_contproc_inicializa (empresa,proceso,fecha,cod_ret) values ('001','load_co_diasaux',pfecha_hoy,'000');
	    COMMIT WORK;

		CREATE VIEW co_saldosaux (empresa,ccmayor,ccsub,ccsubsub,
		ccssubsub,ccsssubsub,sector,ciudad,sucursal,auxiliar,moneda,mes_dia,
		cargos_dia,abonos_dia,nro_cargos_dia,nro_abonos_dia,dias_proyectado,
		dias_acumulados,saldo_acumulado,saldo_inicio_dia,saldo_fin_de_dia,
		apell_paterno,apell_materno,nombre1,nombre2,razon_soc,nombre) as
		  select x0.empresa ,x0.ccmayor ,x0.ccsub ,x0.ccsubsub ,x0.ccssubsub
		    ,x0.ccsssubsub ,x0.sector ,x0.ciudad ,x0.sucursal ,x0.auxiliar
		    ,x0.moneda ,x0.mes_dia ,x0.cargos_dia ,x0.abonos_dia ,x0.nro_cargos_dia
		    ,x0.nro_abonos_dia ,x0.dias_proyectado ,x0.dias_acumulados
		    ,x0.saldo_acumulado ,x0.saldo_inicio_dia ,x0.saldo_fin_de_dia
		    ,x1.apell_paterno ,x1.apell_materno ,x1.nombre1 ,x1.nombre2
		    ,x1.razon_soc ,x2.nombre from co_diasaux x0 ,co_auxiliar x1 ,
		    bdinteg:si_catalog x2
		  where (((((((((x0.empresa
		    = x1.empresa ) AND (x0.auxiliar = x1.numero ) ) AND (x0.empresa
		    = x2.empresa ) ) AND (x0.ccmayor = x2.ccmayor ) ) AND (x0.ccsub
		    = x2.ccsub ) ) AND (x0.ccsubsub = x2.ccsubsub ) ) AND (x0.ccssubsub
		    = x2.ccssubsub ) ) AND (x0.ccsssubsub = x2.ccsssubsub ) )
		    AND (x0.sector = x2.sector ) )  union select x3.empresa ,
		    x3.ccmayor ,x3.ccsub ,x3.ccsubsub ,x3.ccssubsub ,x3.ccsssubsub
		    ,x3.sector ,x3.ciudad ,x3.sucursal ,x3.auxiliar ,x3.moneda
		    ,x3.mes_dia ,x3.cargos_dia ,x3.abonos_dia ,x3.nro_cargos_dia
		    ,x3.nro_abonos_dia ,x3.dias_proyectado ,x3.dias_acumulados

		,x3.saldo_acumulado ,x3.saldo_inicio_dia ,x3.saldo_fin_de_dia
		    ,x4.apell_paterno ,x4.apell_materno ,x4.nombre1 ,x4.nombre2
		    ,x4.razon_soc ,x5.nombre from co_histdiasaux x3
		    ,co_auxiliar x4 ,bdinteg:si_catalog x5
		    where (((((((((x3.empresa = x4.empresa ) AND (x3.auxiliar
		    = x4.numero ) ) AND (x3.empresa = x5.empresa ) ) AND (x3.ccmayor
		    = x5.ccmayor ) ) AND (x3.ccsub = x5.ccsub ) ) AND (x3.ccsubsub
		    = x5.ccsubsub ) ) AND (x3.ccssubsub = x5.ccssubsub ) ) AND
		    (x3.ccsssubsub = x5.ccsssubsub ) ) AND (x3.sector = x5.sector
		    ) ) ;

	    BEGIN WORK;
			INSERT INTO bdicont:co_contproc_inicializa (empresa,proceso,fecha,cod_ret) values ('001','view_co_saldosaux',pfecha_hoy,'000');
	    COMMIT WORK;

	   	BEGIN WORK;
			-- Obtiene el esquema de la tabla antes de drop
			LET v_sql ="dbschema -q -d bdicont -t co_diario -p all tabla; sed /revoke/d tabla > tabla.sql";
			SYSTEM v_sql;

			-- Elimina la tabla por drop y crea el esquema de la misma.
			LET v_sql ='echo "drop table bdicont:co_diario" > query.sql';
			SYSTEM v_sql;
			LET v_sql = "dbaccess bdicont query.sql ";
			SYSTEM v_sql;

			LET v_sql = "dbaccess bdicont tabla 2>/dev/null > /dev/null";
			SYSTEM v_sql;

		COMMIT WORK;

	    BEGIN WORK;
			INSERT INTO bdicont:co_contproc_inicializa (empresa,proceso,fecha,cod_ret) values ('001','load_co_diario',pfecha_hoy,'000');
	    COMMIT WORK;

	    CREATE VIEW co_movtos (usuario,control_poliza,
	    fecha_captura,secuencia,empresa,ccmayor,ccsub,ccsubsub,
	    ccssubsub,ccsssubsub,sector,ciudad,sucursal,naturaleza,
	    nro_auxiliar,monto,descripcion_det,fecha_valida,moneda,
	    valor_cambio,valor_div_cambio,poliza_usuario,tipo_mov,ccosto_orig) as
	    select x0.usuario ,x0.control_poliza ,x0.fecha_captura ,x0.secuencia
	      ,x0.empresa ,x0.ccmayor ,x0.ccsub ,x0.ccsubsub ,x0.ccssubsub
	      ,x0.ccsssubsub ,x0.sector ,x0.ciudad ,x0.sucursal ,x0.naturaleza
	      ,x0.nro_auxiliar ,x0.monto ,x0.descripcion_det ,x0.fecha_valida
	      ,x0.moneda ,x0.valor_cambio ,x0.valor_div_cambio ,x0.poliza_usuario
	      ,x0.tipo_mov,x0.ccosto_orig from co_detpol x0  union select x1.usuario
	      ,x1.control_poliza ,x1.fecha_captura ,x1.secuencia ,x1.empresa
	      ,x1.ccmayor ,x1.ccsub ,x1.ccsubsub ,x1.ccssubsub ,x1.ccsssubsub
	      ,x1.sector ,x1.ciudad ,x1.sucursal ,x1.naturaleza ,x1.nro_auxiliar
	      ,x1.monto ,x1.descripcion ,x1.fecha_valida ,x1.moneda ,x1.valor_cambio
	      ,x1.valor_div_cambio ,x1.poliza_usuario ,x1.tipo_mov,x1.ccosto_orig from
	      co_mensual x1  union select x2.usuario ,x2.control_poliza
	      ,x2.fecha_captura ,x2.secuencia ,x2.empresa ,x2.ccmayor ,
	      x2.ccsub ,x2.ccsubsub ,x2.ccssubsub ,x2.ccsssubsub ,x2.sector
	      ,x2.ciudad ,x2.sucursal ,x2.naturaleza ,x2.nro_auxiliar ,
	      x2.monto ,x2.descripcion ,x2.fecha_valida ,x2.moneda ,x2.valor_cambio
	      ,x2.valor_div_cambio ,x2.poliza_usuario ,x2.tipo_mov,x2.ccosto_orig from
	      co_historico x2 ;

	    BEGIN WORK;
			INSERT INTO bdicont:co_contproc_inicializa (empresa,proceso,fecha,cod_ret) values ('001','view_co_movtos',pfecha_hoy,'000');
	    COMMIT WORK;

		LET m_ant   = month(dfecha_ant);
	    IF v_mesc1 =  m_ant or v_mesc2 = m_ant THEN
			DELETE FROM co_contproc WHERE empresa = pempresa;
		ELSE 
			DELETE FROM co_contproc WHERE empresa = pempresa AND proceso <> "canresulta";
		END IF

	ELSE
		-- Obtiene el esquema de la tabla antes de drop
		LET v_sql ="dbschema -q -d bdicont -t co_diario -p all tabla; sed /revoke/d tabla > tabla.sql";
		SYSTEM v_sql;

		-- Elimina la tabla por drop y crea el esquema de la misma.
		LET v_sql ='echo "drop table bdicont:co_diario" > query.sql';
		SYSTEM v_sql;

		LET v_sql = "dbaccess bdicont query.sql ";
		SYSTEM v_sql;

		LET v_sql = "dbaccess bdicont tabla 2>/dev/null > /dev/null";
		SYSTEM v_sql;

		BEGIN WORK;
			INSERT INTO bdicont:co_contproc_inicializa (empresa,proceso,fecha,cod_ret) values ('001','drop_co_diario',pfecha_hoy,'000');
		COMMIT WORK;

		DELETE FROM co_contproc
	          WHERE empresa = pempresa
                AND proceso <> "revaloriza"
                AND proceso <> "canresulta";

	END IF

END PROCEDURE;