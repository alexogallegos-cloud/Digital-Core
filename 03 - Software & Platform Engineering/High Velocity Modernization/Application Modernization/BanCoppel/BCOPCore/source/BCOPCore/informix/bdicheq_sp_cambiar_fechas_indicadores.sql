CREATE PROCEDURE "informix".sp_cambiar_fechas_indicadores( )
RETURNING CHAR(6)  AS cod_ret,
          CHAR(80) AS desc_ret,
          INTEGER  AS procesados;
    
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
    DEFINE cCodRet2         CHAR(6);
	DEFINE cDescRet			CHAR(80);
    DEFINE vcomienza1       SMALLINT;
	DEFINE vabierto     	SMALLINT;
    DEFINE vcontador1   	INTEGER;
	DEFINE vcontador2   	INTEGER;
	DEFINE cCuenta     		CHAR(20);
	
	LET iSqlErr      = 0;
	LET iIsamErr     = 0;
	LET cErrorInfo   = '';
	LET cCodRet      = '000000';
    LET cCodRet2     = '';
	LET cDescRet	 = 'PROCESO EXITOSO';
    LET vcomienza1   = -1;
	LET vabierto   	 = 0;
    LET vcontador1 	 = 0;
	LET vcontador2 	 = 0;
	LET cCuenta    	 = '';
	
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        SET DEBUG FILE TO '/resplogifx/conciliachq/sp_cambiar_fechas_indicadores.err';
        TRACE ON;
        IF iSqlErr != 0 THEN
			LET cCodRet  = iSqlErr;
            LET cCodRet2 = iIsamErr;
			LET cDescRet = cErrorInfo;
            IF vabierto = 1 THEN
                ROLLBACK WORK;
            END IF;
			RETURN cCodRet, cDescRet, vcontador1;
		END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/sp_cambiar_fechas_indicadores.out';
	--- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD
        SELECT cuenta
          INTO cCuenta
          FROM "informix".sc_indicadores
         WHERE cuenta >= '10000005016'
         
        IF vcomienza1 = -1 THEN
            LET vcomienza1 = 0;
			BEGIN WORK;
			LET vabierto = 1; 
		END IF;
        
        UPDATE "informix".sc_indicadores
           SET anio_mes = '201407'
         WHERE cuenta = cCuenta;
         
        LET vcontador1 = vcontador1 + 1;
		LET vcontador2 = vcontador2 + 1;
		
		IF vcontador2 >= 5000 THEN
			LET vcontador2 = 0;			
			COMMIT WORK;
            BEGIN WORK;
		END IF;
	END FOREACH;
    
    IF vabierto = 1 THEN
		COMMIT WORK;
        LET vabierto = 0;
	END IF;
    
    RETURN cCodRet, cDescRet, vcontador1;
    
    END;
    
END PROCEDURE
    
DOCUMENT
'DESCRIPCION: Proceso para actualizar los indicadores',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ', 
'FECHA: Febrero 2014';

CREATE PROCEDURE "informix".sp_basectescat( pempresa CHAR(3) )
RETURNING CHAR(6);
      
    DEFINE vcodret    		CHAR(6);
    DEFINE sql_err      	INTEGER;
    DEFINE vsql             CHAR(1300);
    DEFINE vfecha           CHAR(4);
    DEFINE vfecha_hoy       DATE;
	DEFINE vano				CHAR(2);
	DEFINE vdate			CHAR(6);
    DEFINE vcliente			CHAR(20);
	
    LET vcodret      = '000000';
    LET sql_err	     = 0;
    LET vsql         = '';
    LET vfecha       = '';
    LET vfecha_hoy   = ''; 
	LET vano 		 = ''; 
	LET vdate 		 = '';
	LET vcliente	 = '';
	
    BEGIN
    
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET vcodret = sql_err;
            RETURN vcodret;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_basectescat.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	-- // OBTIENE LAS FECHAS DEL SISTEMA
	SELECT fecha_hoy 
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
	
	LET vano = SUBSTR(vfecha_hoy,9,2);
    LET vano = vano;
	LET vfecha = TO_CHAR(vfecha_hoy, '%d%m');
	LET vdate = vfecha||vano;
	     
    -- // COMIENZA DESCARGA DE INFORMACION OPERATIVA - REPORTES DIARIOS
    LET vfecha = TO_CHAR(vfecha_hoy, '%d%m%Y');
	
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tmp_sin_cta') THEN
        DROP TABLE "informix".tmp_sin_cta;        
    END IF;
	
    -- INVSERSIONES SIN CUENTA EJE
	CREATE RAW TABLE "informix".tmp_sin_cta( 
        cuenta 	CHAR(20) 
    ) 
    EXTENT SIZE 4880 NEXT SIZE 32 LOCK MODE ROW;
		
	insert into tmp_sin_cta
	select unique(cuenta) 
      from bdicheq:sc_maeinstrucc
	 where cuentadep = " ";
	
	IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tmp_inv_crec1') THEN
        DROP TABLE "informix".tmp_inv_crec1;        
    END IF;
	
	CREATE RAW TABLE "informix".tmp_inv_crec1 ( 
        tipo_promo            	CHAR(3),
        tipo_logica				CHAR(6),
        tipo_producto			CHAR(20),
        num_cte					CHAR(20),
        prioridad				CHAR(1),
        nombre					CHAR(104),
        sexo					CHAR(1),
        edo_civil				CHAR(2),
        email					CHAR(100),
        estado					CHAR(30),
        tel_cel					CHAR(13),
        tel_casa				CHAR(13),
        tel_trabajo				CHAR(13),
        tel_referencia			CHAR(13),
        extension				CHAR(5),
        fecha_apertura			DATE,
        fecha_venci				DATE,
        sucursal				CHAR(4) 
    ) 
    EXTENT SIZE 6960 NEXT SIZE 688 LOCK MODE ROW;
		
	LET vsql = '';
	LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               ' insert into tmp_inv_crec1  '||
               'select '||
               ' '''||"ICP"||''', '||  
               ''''||vdate||''', '||
               ''''||"Inversion Creciente"||''', '||
               'a.num_cte, '||
               ' '''||"1"||''', '|| 
               'trim(apell_paterno)||''" "''|| trim(apell_materno)||''" "''|| trim(nombre1)||''" "''|| trim(nombre2), '||
               'sexo, estado_civil, correo_elec, e.nombre,	CASE WHEN LENGTH(g.telefono) = 13 THEN substr(g.telefono, 4, 10)  '||
               'WHEN LENGTH(g.telefono) = 12 THEN substr(g.telefono, 3, 10) '||
               'WHEN LENGTH(g.telefono) = 11 THEN substr(g.telefono, 2, 10) '||
               'WHEN LENGTH(g.telefono) < 10 THEN '''' '||
               ' ELSE g.telefono END, '''||""||''', '''||""||''', '''||""||''', '''||""||''', '||
               'fecultdep,	fecha_mod,	a.sucursal	from bdicheq:tmp_sin_cta z, '||
               'bdicheq:sc_maechq a, bdinteg:si_cliente b, '||
               'outer bdinteg:si_correos c, bdinteg:si_direcciones_actual d, '||
               'bdinteg:si_estados e, bdicheq:sc_maenoc f, '||
               'bdinteg:si_telefonos_actual g, bdinteg:si_ctepf h '||
               'where z.cuenta = a.cuenta  and a.num_cte = b.numcte '||
               'and a.num_cte = c.numcte and a.num_cte = d.numcte '||
               'and d.estado = e.estado and a.cuenta = f.cuenta '||
               'and a.num_cte = g.numcte and a.num_cte = h.numcte '||
               'and status_cta <> ''2'' and d.tipo_dir = ''1'' and c.status_correo =''A'' '||
               'and g.tipo_tel = ''2'' and fecultdep + 1125 units day <= today '||
               ';" > /resplogifx/conciliachq/originales/sctp_inv_crec1.sql';
	SYSTEM vsql;
    
	LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/originales/sctp_inv_crec1.sql"; 
    SYSTEM vsql;
    LET vsql = '';   
	
	IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tmp_ctas_ctes') THEN
        DROP TABLE "informix".tmp_ctas_ctes;        
    END IF;
	
	CREATE RAW TABLE "informix".tmp_ctas_ctes ( 
        num_cte		CHAR(20),
        contador    INT8
	) EXTENT SIZE 7328 NEXT SIZE 736 LOCK MODE ROW;
	
	INSERT into tmp_ctas_ctes
	select b.num_cte, count(*) cuentas 
      from tmp_inv_crec1 b, 
           bdicheq:sc_maechq a
	 where a.num_cte = b.num_cte
	   and producto <> "1100"
	   and status_cta = "1"
	 group by 1;
	
	IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tmp_inv_crec2') THEN
        DROP TABLE "informix".tmp_inv_crec2;        
    END IF;
	
	CREATE RAW TABLE "informix".tmp_inv_crec2( 
        tipo_promo            	CHAR(3),
        tipo_logica				CHAR(6),
        tipo_producto			CHAR(20),
        num_cte					CHAR(20),
        prioridad				CHAR(1),
        nombre					CHAR(104),
        sexo					CHAR(1),
        edo_civil				CHAR(2),
        email					CHAR(100),
        estado					CHAR(30),
        tel_cel					CHAR(13),
        tel_casa				CHAR(13),
        tel_trabajo				CHAR(13),
        tel_referencia			CHAR(13),
        extension				CHAR(5),
        fecha_apertura			DATE,
        fecha_venci				DATE,
        sucursal				CHAR(4),
        cuenta_eje				CHAR(2)
	)
    EXTENT SIZE 6992 NEXT SIZE 704 LOCK MODE ROW;
	
	INSERT INTO tmp_inv_crec2
	select a.*,
           CASE WHEN b.num_cte > 0  THEN "SI" ELSE "NO" END x
	  from tmp_inv_crec1 a, tmp_ctas_ctes b
	 where a.num_cte = b.num_cte;
	
	--- PAGARE
	IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tmp_pagare_1') THEN
        DROP TABLE "informix".tmp_pagare_1;        
    END IF;
	
	CREATE RAW TABLE "informix".tmp_pagare_1 ( 
        cuenta  CHAR(20)
	)
    EXTENT SIZE 2928 NEXT SIZE 32 LOCK MODE ROW;
	
	INSERT INTO tmp_pagare_1
	select cuenta 
      from bdinvers:sv_maeinv
	 where secuencia = 1
	   and status_cta <> "2";
	
	IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tmp_pagare2') THEN
        DROP TABLE "informix".tmp_pagare2;        
    END IF;
	
	CREATE RAW TABLE "informix".tmp_pagare2 ( 
        cuenta		CHAR(20),
        secuencia	SMALLINT
	)
    EXTENT SIZE 3216 NEXT SIZE 32 LOCK MODE ROW;
	
	INSERT INTO tmp_pagare2
	select cuenta, max(secuencia) 
      from bdinvers:sv_maeinv
	 where cuenta in( select cuenta from tmp_pagare_1 )
	   and status_cta = "1"
	group by 1 ;
	
	IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tmp_inv_pagare3') THEN
        DROP TABLE "informix".tmp_inv_pagare3;        
    END IF;
	
	CREATE RAW TABLE "informix".tmp_inv_pagare3 ( 
        tipo_promo      CHAR(3),
        tipo_logica		CHAR(6),
        tipo_producto	CHAR(20),
        num_cte			CHAR(20),
        prioridad		CHAR(1),
        nombre			CHAR(104),
        sexo			CHAR(1),
        edo_civil		CHAR(2),
        email			CHAR(100),
        estado			CHAR(30),
        tel_cel			CHAR(13),
        tel_casa		CHAR(13),
        tel_trabajo		CHAR(13),
        tel_referencia	CHAR(13),
        extension		CHAR(5),
        fecha_apertura	DATE,
        fecha_venci		DATE,
        sucursal		CHAR(4),
        cuenta_eje		CHAR(2)
	)
    EXTENT SIZE 6992 NEXT SIZE 704 LOCK MODE ROW;
	
	LET vsql = '';
	LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               ' insert into tmp_inv_pagare3  '||
               'select '||
               ' '''||"ICP"||''', '||  
               ''''||vdate||''', '||
               ''''||"Pagare"||''', '||
               'a.num_cte, '||
               ' '''||"1"||''', '|| 
               'trim(apell_paterno)||''" "''|| trim(apell_materno)||''" "''|| trim(nombre1)||''" "''|| trim(nombre2), '||
               'sexo, estado_civil, correo_elec, e.nombre,	CASE WHEN LENGTH(g.telefono) = 13 THEN substr(g.telefono, 4, 10)  '||
               'WHEN LENGTH(g.telefono) = 12 THEN substr(g.telefono, 3, 10) '||
               'WHEN LENGTH(g.telefono) = 11 THEN substr(g.telefono, 2, 10) '||
               'WHEN LENGTH(g.telefono) < 10 THEN '''' '||
               ' ELSE g.telefono END, '''||""||''', '''||""||''', '''||""||''', '''||""||''', '||
               'a.fecha_alta,	i.fecha_venc, 	a.sucursal, '''||"SI"||'''	from bdicheq:tmp_pagare2 z, '||
               'bdinvers:sv_maeinv a, bdinteg:si_cliente b, '||
               'outer bdinteg:si_correos c, bdinteg:si_direcciones_actual d, '||
               'bdinteg:si_estados e, bdinteg:si_telefonos_actual g,'||
               'bdinteg:si_ctepf h,	bdinvers:sv_maeinv i '||
               'where a.cuenta = z.cuenta  and a.secuencia = 1 '||
               'and a.num_cte = b.numcte	and a.num_cte = c.numcte '||
               'and a.num_cte = d.numcte 	and d.estado = e.estado '||
               'and a.num_cte = g.numcte	and a.num_cte = h.numcte '||
               'and a.cuenta = i.cuenta 	and i.secuencia = z.secuencia '||
               'and d.tipo_dir = ''1''	and g.tipo_tel = ''2'' and c.status_correo =''A'' '||
               'and a.fecha_alta + 1125 units day <= today '||
               ';" > /resplogifx/conciliachq/originales/sctp_inv_pagare3.sql';
	SYSTEM vsql;
	
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/originales/sctp_inv_pagare3.sql"; 
    SYSTEM vsql;
    LET vsql = '';   
	
	-- INVERSIONES CON CUENTA EJE
	IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tmp_con_cta') THEN
        DROP TABLE "informix".tmp_con_cta;        
    END IF;
	
	CREATE RAW TABLE "informix".tmp_con_cta ( 
        cuenta 	CHAR(20)
	)
    EXTENT SIZE 74224 NEXT SIZE 7424 LOCK MODE ROW;
	
	INSERT INTO tmp_con_cta
	select unique(cuenta) 
      from bdicheq:sc_maeinstrucc
	 where cuentadep <> " ";
	
	IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tmp_inv_crec3') THEN
        DROP TABLE "informix".tmp_inv_crec3;        
    END IF;
	
	CREATE RAW TABLE "informix".tmp_inv_crec3 ( 
        tipo_promo      CHAR(3),
        tipo_logica		CHAR(6),
        tipo_producto	CHAR(20),
        num_cte			CHAR(20),
        prioridad		CHAR(1),
        nombre			CHAR(104),
        sexo			CHAR(1),
        edo_civil		CHAR(2),
        email			CHAR(100),
        estado			CHAR(30),
        tel_cel			CHAR(13),
        tel_casa		CHAR(13),
        tel_trabajo		CHAR(13),
        tel_referencia	CHAR(13),
        extension		CHAR(5),
        fecha_apertura	DATE,
        fecha_venci		DATE,
        sucursal		CHAR(4),
        cuenta_eje		CHAR(2)
	)
    EXTENT SIZE 6992 NEXT SIZE 704 LOCK MODE ROW;
	
	LET vsql = '';
	LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               ' insert into tmp_inv_crec3  '||
               'select '||
               ' '''||"ICP"||''', '||  
               ''''||vdate||''', '||
               ''''||"Inversion Creciente"||''', '||
               'a.num_cte, '||
               ' '''||"1"||''', '|| 
               'trim(apell_paterno)||''" "''|| trim(apell_materno)||''" "''|| trim(nombre1)||''" "''|| trim(nombre2), '||
               'sexo, estado_civil, correo_elec, e.nombre, CASE WHEN LENGTH(g.telefono) = 13 THEN substr(g.telefono, 4, 10)  '||
               'WHEN LENGTH(g.telefono) = 12 THEN substr(g.telefono, 3, 10) '||
               'WHEN LENGTH(g.telefono) = 11 THEN substr(g.telefono, 2, 10) '||
               'WHEN LENGTH(g.telefono) < 10 THEN '''' '||
               ' ELSE g.telefono END, '''||""||''', '''||""||''', '''||""||''', '''||""||''', '||
               'fecultdep,	fecha_mod, a.sucursal, '''||"SI"||'''	from bdicheq:tmp_con_cta z, '||
               'bdicheq:sc_maechq a, bdinteg:si_cliente b, '||
               'outer bdinteg:si_correos c, bdinteg:si_direcciones_actual d, '||
               'bdinteg:si_estados e, bdicheq:sc_maenoc f,'||
               'bdinteg:si_telefonos_actual g, bdinteg:si_ctepf h '||
               'where z.cuenta = a.cuenta and a.num_cte = b.numcte '||
               'and a.num_cte = c.numcte and a.num_cte = d.numcte '||
               'and d.estado = e.estado	and a.cuenta = f.cuenta '||
               'and a.num_cte = g.numcte and a.num_cte = h.numcte '||
               'and status_cta <> ''2'' and d.tipo_dir = ''1'' and c.status_correo =''A'' '||
               'and g.tipo_tel = ''2'' and fecultdep + 1125 units day <= today '||
               ';" > /resplogifx/conciliachq/originales/sctp_inv_crec3.sql';
	SYSTEM vsql;
    
	LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/originales/sctp_inv_crec3.sql"; 
    SYSTEM vsql;
	
	LET vsql = '';
	LET vsql = ' echo "SET ISOLATION TO DIRTY READ; '||
               ' insert into tmp_inv_crec2 '||
			   ' select * from tmp_inv_crec3 '||
			   ';" > /resplogifx/conciliachq/originales/script_icp1.sql';
	SYSTEM vsql;
			   
	LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/originales/script_icp1.sql"; 
    SYSTEM vsql;
    
    LET vsql = '';
	LET vsql = ' echo "SET ISOLATION TO DIRTY READ; '||
               ' insert into tmp_inv_crec2 '||
			   ' select * from tmp_inv_pagare3 '||
			   ';" > /resplogifx/conciliachq/originales/script_icp2.sql';
	SYSTEM vsql;
			   
	LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/originales/script_icp2.sql"; 
    SYSTEM vsql;
    
    LET vsql = '';  
	
	IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tmp_uni_ctes') THEN
        DROP TABLE "informix".tmp_uni_ctes;        
    END IF;
	
	CREATE RAW TABLE "informix".tmp_uni_ctes ( 
        num_cte	    CHAR(20)
	)
	EXTENT SIZE 1952 NEXT SIZE 32 LOCK MODE ROW;
	
	insert into tmp_uni_ctes
	select unique (num_cte) 
      from tmp_inv_crec2;
	
	IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tmp_inv_crec4') THEN
            DROP TABLE "informix".tmp_inv_crec4;        
    END IF;
	
	CREATE RAW TABLE "informix".tmp_inv_crec4 ( 
        tipo_promo            	CHAR(14),
        tipo_logica				CHAR(11),
        tipo_producto			CHAR(20),
        num_cte					CHAR(20),
        prioridad				CHAR(9),
        nombre					CHAR(104),
        sexo					CHAR(4),
        edo_civil				CHAR(12),
        email					CHAR(100),
        estado					CHAR(30),
        tel_cel					CHAR(21),
        tel_casa				CHAR(21),
        tel_trabajo				CHAR(21),
        tel_referencia			CHAR(21),
        extension				CHAR(9),
        fecha_apertura			CHAR(14),
        fecha_venci				CHAR(25),
        sucursal				CHAR(8),
        cuenta_eje				CHAR(10)
	)
    EXTENT SIZE 8240 NEXT SIZE 832 LOCK MODE ROW;
	
	INSERT INTO tmp_inv_crec4 	VALUES 
	( 'tipopromocion','tipologica','tipoproducto','numcliente','prioridad','nombre','sexo','estadocivil','email','estado',
	  'celular','telcasa','teltrabajo','telreferencia','extension','fechaapertura','fechaproxvenc','sucursal','cuentaeje' );

	/* ##############################################################################################################################################################
    ( 'Tipo_promocion','Tipo_logica','Tipo_Producto','Numero_cliente','Prioridad','Nombre','Sexo','Estado_Civil','Email','Estado','Telefono_recons_Tipo1',
	  'Telefono_recons_Tipo2','Telefono_recons_Tipo3','Telefono_recons_Tipo4','Extension','Fecha_Apertura','Fecha_Proximo_vencimiento','Sucursal','Cuenta_Eje');
    ############################################################################################################################################################## */
	
	FOREACH
        SELECT *
          INTO vcliente 
          FROM bdicheq:tmp_uni_ctes
        
        LET vsql = '';
        LET vsql = ' echo "SET ISOLATION TO DIRTY READ; '||
                   ' INSERT INTO tmp_inv_crec4 '||
                   ' SELECT FIRST 1 * FROM bdicheq:tmp_inv_crec2 '||
                   ' where num_cte = '''||vcliente||''' '||
                   ';" > /resplogifx/conciliachq/originales/script_icp3.sql';
                   
        SYSTEM vsql;
                   
        LET vsql = '';
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/originales/script_icp3.sql"; 
        SYSTEM vsql;
        LET vsql = '';
	END FOREACH;
	
	LET vsql = '';
	LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
    		   'UNLOAD TO /resplogifx/conciliachq/originales/tmp_ICP_'||vdate||'.txt' || ' DELIMITER ' || '''|''' ||
			   ' select * from tmp_inv_crec4 where tel_cel <> '''||"0000000000"||''' '||
			   ';" > /resplogifx/conciliachq/originales/script_icp.sql';
	SYSTEM vsql;
			   
	LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/originales/script_icp.sql"; 
    SYSTEM vsql;
    
    LET vsql = '';    
	LET vsql = 'sed "s/\ \|/\|/g" /resplogifx/conciliachq/originales/tmp_ICP_'||vdate||'.txt > /resplogifx/conciliachq/originales/ICP_'||vdate||'.txt';
	SYSTEM vsql;	
	
    LET vsql = '';    
	LET vsql = 'rm /resplogifx/conciliachq/originales/tmp_ICP_'||vdate||'.txt';
	SYSTEM vsql;	
    
	LET vsql = '';    
	
	END;
    
    RETURN vcodret;
    
END PROCEDURE;