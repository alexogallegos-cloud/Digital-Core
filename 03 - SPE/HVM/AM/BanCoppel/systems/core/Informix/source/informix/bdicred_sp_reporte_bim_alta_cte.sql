CREATE PROCEDURE "informix".sp_reporte_bim_alta_cte()
RETURNING   CHAR(6) 	AS retorno ;            --CHAR(100)   AS mensaje_ret;

--EXECUTE PROCEDURE "informix".sp_reporte_bim_alta_cte();

--DeclaraciÃÂÃÂ³n de variables.
DEFINE v_num_cliente             	 CHAR(20);
DEFINE v_folio_cte_buro              CHAR(20);
DEFINE v_folio_cte_cc                CHAR(20);
DEFINE v_pers_juridica               SMALLINT;
DEFINE v_nombre_cte                  CHAR(150);
DEFINE v_apellidos                   CHAR(150);
DEFINE v_nacionalidad                SMALLINT;
DEFINE v_fecha_nac                   CHAR(12);
DEFINE v_sector_economico            SMALLINT;
DEFINE v_rfc                         CHAR(13);
--DEFINE v_rfc1                        CHAR(10);
DEFINE v_curp                        CHAR(18);
DEFINE v_genero_cte                  SMALLINT;
DEFINE v_edo_civil                   SMALLINT;
DEFINE v_sector_laboral              SMALLINT;
DEFINE v_ing_bruto_mens              DECIMAL(18,2);
DEFINE v_cod_postal                  CHAR(5);
DEFINE v_pais                        SMALLINT;
DEFINE v_estado                      SMALLINT;
DEFINE v_deleg_municip               SMALLINT;
DEFINE v_localidad                   CHAR(12);
DEFINE v_activ_economica             CHAR(7);
DEFINE v_activ_econ		             CHAR(7);
DEFINE v_subactiv_econ		         CHAR(7);
DEFINE v_total_empleados             SMALLINT;  
DEFINE iSqlErr      					INTEGER;
DEFINE iIsamErr         				INTEGER;
DEFINE cErrorInfo       				CHAR(100);
DEFINE cCodRet          				CHAR(6);
DEFINE cMensajeRet    					CHAR(100);
DEFINE pPeriodo              		   DATE;
DEFINE piniPeriodo					   DATE;
DEFINE v_Periodo              		   DATE;
DEFINE v_primerdiaPf           		   DATE;
DEFINE v_ultdiaPf					   DATE;
DEFINE v_primerdiaPi           		   DATE;
DEFINE v_ultdiaPi					   DATE;
DEFINE vCodRet          			   CHAR(6);
DEFINE flag_aniobis					   INTEGER;
DEFINE v_num_solicitud_sic				CHAR(20);
DEFINE v_seg_cons_appaterno				CHAR(1);
DEFINE v_seg_cons_nombre				CHAR(1);
DEFINE i							INTEGER;
DEFINE v_producto					CHAR(4);
DEFINE v_credito					CHAR(20);
DEFINE v_num_cliente_aux			CHAR(20);
DEFINE v_producto_aux				CHAR(4);
DEFINE cRuta CHAR (50);
DEFINE cBitCamp CHAR (50);
DEFINE cCadena  CHAR (1500);

--INICIALIZACION DE VARIABLES

LET v_num_cliente             	  ="";
LET v_folio_cte_buro              ="";
LET v_folio_cte_cc                ="";
LET v_pers_juridica               =0;
LET v_nombre_cte                  ="";
LET v_apellidos                   ="";
LET v_nacionalidad                =0;
LET v_fecha_nac                   ="";
LET v_sector_economico            =0;
LET v_rfc                         ="";
--LET v_rfc1                        ="";
LET v_curp                        ="";
LET v_genero_cte                  =0;
LET v_edo_civil                   =0;
LET v_sector_laboral              =0;
LET v_ing_bruto_mens              =0;
LET v_cod_postal                  ="";
LET v_pais                        =0;
LET v_estado                      =0;
LET v_deleg_municip               =0;
LET v_localidad                   ="";
LET v_activ_economica             ="";
LET v_total_empleados             =0;  
LET iSqlErr                         = 0;
LET iIsamErr         				= 0;
LET cErrorInfo       				= "";
LET cCodRet          				= "00000";
LET cMensajeRet    					= "REPORTE BIMESTRAL ALTA_CLIENTES se realizÃÂÃÂ³ correctamente";
LET v_num_solicitud_sic			='';
LET v_seg_cons_appaterno		='';
LET v_seg_cons_nombre			='';
LET v_producto='';
LET v_credito='';
LET i=0;
LET v_num_cliente_aux			='';
LET v_producto_aux				='';
LET cRuta = '';
LET cBitCamp = '';
LET cCadena = '';
LET v_primerdiaPf	=DATE(1);
LET v_ultdiaPf		=DATE(1);
LET v_primerdiaPi   =DATE(1);
LET v_ultdiaPi		=DATE(1);
LET vCodRet         ='000000';
LET v_Periodo       =DATE(1);


BEGIN
    --Errores no controlados.
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;

          RETURN cCodRet; --, cMensajeRet;
    END EXCEPTION;

    --SET DEBUG FILE TO "sp_reporte_bimestral_alta_cliente.out";
    --TRACE ON;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO dirty READ;

   -- LET pPeriodo = mdy(month(today),1,year(today)) - 1 units day;
   --IPCB  Se cambia por consulta a la BD
	SELECT pri_dia_mes-1 units day , pri_dia_mes-2 units month  
	INTO pPeriodo, piniPeriodo
	FROM bdicred:sd_fechas;
	
	--LET cRuta="/ifxsif01/tmp/bim_alta_ctes/Entrega/";
	LET cRuta="/resplogifx/archivosriesgos/";	
	LET cBitCamp="bim_alta_ctes";
	LET cBitCamp= TRIM(cBitCamp)||'_'||YEAR(today)||LPAD(MONTH(today),2,0)||LPAD(DAY(today),2,0)||'.unl';

--Reproceso de Junio
--LET pPeriodo = mdy('06','30','2018');
--LET piniPeriodo = mdy('06','01','2018');
--Reproceso de Junio	

--Valida Anio Bisiesto
IF mod(year(pPeriodo),4) = 0 AND ((mod(year(pPeriodo),4)) = 0 OR (mod(year(pPeriodo),4) = 0)) THEN
	LET flag_aniobis = 1;
ELSE
	LET flag_aniobis = 0;
END IF;

IF (SELECT COUNT(num_cliente) FROM sd_reporte_bim_alta_cte)>0 THEN
	
	FOREACH WITH HOLD
		SELECT fecha_cierre,num_cliente,folio_cte_buro,folio_cte_cc,
		pers_juridica,nombre_cte,apellidos,nacionalidad,fecha_nac,
		sector_economico,rfc,curp,genero_cte,edo_civil,sector_laboral,
		ing_bruto_mens,cod_postal,pais,estado,deleg_municip,localidad,
		activ_economica,total_empleados,num_producto,num_credito
		INTO v_Periodo, v_num_cliente,v_folio_cte_buro,v_folio_cte_cc,
			 v_pers_juridica,v_nombre_cte,v_apellidos,v_nacionalidad,v_fecha_nac,
			 v_sector_economico,v_rfc,v_curp,v_genero_cte,v_edo_civil,v_sector_laboral,
			 v_ing_bruto_mens,v_cod_postal,v_pais,v_estado,v_deleg_municip,v_localidad,
			 v_activ_economica,v_total_empleados,v_producto,v_credito
		FROM "informix".sd_reporte_bim_alta_cte
		
		BEGIN WORK;
			INSERT INTO sd_repositorio_alta_cte
					(fecha_cierre, num_cliente,folio_cte_buro,folio_cte_cc,
					pers_juridica,nombre_cte,apellidos,nacionalidad,fecha_nac,
					sector_economico,rfc,curp,genero_cte,edo_civil,sector_laboral,
					ing_bruto_mens,cod_postal,pais,estado,deleg_municip,localidad,
					activ_economica,total_empleados,num_producto,num_credito)
			VALUES (v_Periodo, v_num_cliente,v_folio_cte_buro,v_folio_cte_cc,
					v_pers_juridica,v_nombre_cte,v_apellidos,v_nacionalidad,v_fecha_nac,
					v_sector_economico,v_rfc,v_curp,v_genero_cte,v_edo_civil,v_sector_laboral,
					v_ing_bruto_mens,v_cod_postal,v_pais,v_estado,v_deleg_municip,v_localidad,
					v_activ_economica,v_total_empleados,v_producto,v_credito);
			COMMIT WORK;
	END FOREACH;		
	/*INSERT INTO "informix".sd_repositorio_alta_cte(fecha_cierre, num_cliente,folio_cte_buro,folio_cte_cc,pers_juridica,nombre_cte,apellidos,nacionalidad,fecha_nac,sector_economico,rfc,curp,genero_cte,edo_civil,sector_laboral,ing_bruto_mens,cod_postal,pais,estado,deleg_municip,localidad,activ_economica,total_empleados)
	SELECT fecha_cierre,num_cliente,folio_cte_buro,folio_cte_cc,pers_juridica,nombre_cte,apellidos,nacionalidad,fecha_nac,sector_economico,rfc,curp,genero_cte,edo_civil,sector_laboral,ing_bruto_mens,cod_postal,pais,estado,deleg_municip,localidad,activ_economica,total_empleados
	FROM "informix".sd_reporte_bim_alta_cte;*/
	
	TRUNCATE TABLE sd_reporte_bim_alta_cte;
END IF;

	LET v_producto='';
	LET v_credito='';
	
	EXECUTE PROCEDURE "informix".sp_dia_primero_ultimo_mes_anio (month(piniPeriodo), year(piniPeriodo))
	INTO vCodRet, v_primerdiaPi, v_ultdiaPi;
	
	EXECUTE PROCEDURE "informix".sp_dia_primero_ultimo_mes_anio (month(pPeriodo), year(pPeriodo))
	INTO vCodRet, v_primerdiaPf, v_ultdiaPf;	
			
	SELECT {+AVOID_FULL(sd_maecredcontcrd)} numcte, num_producto, num_credito 
	FROM sd_maecredcontcrd  
	WHERE num_producto IN('6300','6400','7600','6800','7700','9300')
	AND fecha>= v_primerdiaPi AND fecha<= v_ultdiaPi 
	AND numcte NOT IN(SELECT num_cliente FROM sd_repositorio_alta_cte) --ACC
	--AND fecha>= mdy('03', '01', '2019') AND fecha<= mdy('03', '31', '2019') 
	UNION 
	SELECT numcte, num_producto, num_credito 
	FROM sd_maecredcont  
	WHERE num_producto in('7800','6001','7000','8100','6600')
	AND fecha>= v_primerdiaPi AND fecha<= v_ultdiaPi 
	AND numcte NOT IN(SELECT num_cliente FROM sd_repositorio_alta_cte) --ACC
	AND empresa='001' --ACC
	AND num_credito NOT IN(SELECT num_credito FROM sd_repositorio_alta_cte)--ACC
	--AND fecha>= mdy('03', '01', '2019') AND fecha<= mdy('03', '31', '2019')
	UNION
	SELECT numcte, num_producto, num_credito 
	FROM sd_maecredcont  
	WHERE num_producto in('8500')
	AND fecha>= v_primerdiaPi AND fecha<= v_ultdiaPi 
	AND numcte NOT IN(SELECT num_cliente FROM sd_repositorio_alta_cte) --ACC
	AND empresa='001' --SFAH
	INTO TEMP clientescred_alta with no log;
	
	
	SELECT {+AVOID_FULL(sd_maecredcontcrd)} numcte, num_producto, num_credito 
	FROM sd_maecredcontcrd  
	WHERE num_producto IN('6300','6400','7600','6800','7700','9300')
	AND fecha>= v_primerdiaPf AND fecha<= v_ultdiaPf 
	--AND fecha>= mdy('04', '01', '2019') AND fecha<= mdy('04', '30', '2019') 
	AND numcte NOT IN(SELECT numcte FROM clientescred_alta)
	UNION 
	SELECT numcte, num_producto, num_credito 
	FROM sd_maecredcont  
	WHERE num_producto in('7800','6001','7000','8100','6600','8500')
	AND fecha>= v_primerdiaPf AND fecha<= v_ultdiaPf 
	--AND fecha>= mdy('04', '01', '2019') AND fecha<= mdy('04', '30', '2019') 
	AND numcte NOT IN(SELECT numcte FROM clientescred_alta)
	INTO TEMP clientes_alta_abr19 with no log;
	
	INSERT INTO clientescred_alta
	SELECT * FROM clientes_alta_abr19;
		
	SELECT DISTINCT (numcte) FROM clientescred_alta
	INTO TEMP ctes_alta with no log;
	
    FOREACH WITH HOLD
        
        SELECT a.numcte,
		1 AS personalidad_juridica,
		REPLACE(trim(a.nombre1),'  ',' ')|| " " || REPLACE(trim(a.nombre2),'  ',' ') as nombre_cte,
		trim(a.apell_paterno)|| " " || trim(a.apell_materno) as apellidos,
		case when b.nacionalidad='001' then 1 else 2 end nacionalidad,
		TO_CHAR(b.fecha_nac, '%Y/%m/%d') as fecha_nac,
		32 as sector_socioeconomico,
		case when length(a.rfc)=13 then a.rfc else "" end rfc,
		trim(b.curp), --REPLACE(trim(b.curp), '|', 'X'), --trim(b.curp), 
		case when b.sexo='F' then 2 else 1 end sexo,
		case when b.estado_civil='C' then 2 else 1 end estado_civil,
		case when a.sector in('10','12') then 1 
             when a.sector in('13','14') then 2 
             when a.sector in('11','21','22','23','51') then 3 
             when a.sector in('25','26','31','41','42','30','40','20') then 4 
             when a.sector in('00','32') then 5 end sector_laboral,
		d.cod_postal,
	    484 as pais,
		d.estado,
		d.ciudad, 
		g.localidad_inegi,
		h.clave,
		0 as total_empleados,
		ingreso_mensual
        --INTO v_num_cliente, v_pers_juridica, v_nombre_cte,v_apellidos, v_nacionalidad, v_fecha_nac, v_sector_economico, v_rfc,  v_curp,     
        --v_genero_cte, v_edo_civil, v_sector_laboral, v_cod_postal,v_pais,v_estado,v_deleg_municip,v_localidad,v_activ_economica,v_total_empleados,v_ing_bruto_mens
        from  bdinteg:si_cliente a
		inner join bdinteg:si_ctepf b
        on a.numcte=b.numcte
        and a.empresa=b.empresa
        inner join bdicred:ctes_alta c
        on a.numcte=c.numcte
        inner join bdinteg:si_direcciones d
        on a.numcte=d.numcte
        left join bdinteg:si_ciudades g
        on g.estado=d.estado
        and g.ciudad=d.ciudad
		left join bdinteg:si_ingresos e
        on a.numcte=e.numcte
        and a.empresa=e.empresa
        left join bdicred:sd_clave_x_activ_bim h
        on h.actividad=e.claveopcionpuesto
        and h.subactividad=e.clavesubopcionpuesto
		where a.numcte not in (select num_cliente from sd_repositorio_alta_cte)
		and d.secuencia in(select max(secuencia) from bdinteg:si_direcciones where numcte=a.numcte)
		and e.sec_ingreso in(select max(sec_ingreso) from bdinteg:si_ingresos where numcte=a.numcte)
		--and e.numcte is null and e.empresa is null
		UNION 
		SELECT a.numcte,
		1 AS personalidad_juridica,
		REPLACE(trim(a.nombre1),'  ',' ')|| " " || REPLACE(trim(a.nombre2),'  ',' ') as nombre_cte,
		trim(a.apell_paterno)|| " " || trim(a.apell_materno) as apellidos,
		case when b.nacionalidad='001' then 1 else 2 end nacionalidad,
		TO_CHAR(b.fecha_nac, '%Y/%m/%d') as fecha_nac,
		32 as sector_socioeconomico,
		case when length(a.rfc)=13 then a.rfc else "" end rfc,
		trim(b.curp), --REPLACE(trim(b.curp), '|', 'X'), --trim(b.curp), 
		case when b.sexo='F' then 2 else 1 end sexo,
		case when b.estado_civil='C' then 2 else 1 end estado_civil,
		case when a.sector in('10','12') then 1 
             when a.sector in('13','14') then 2 
             when a.sector in('11','21','22','23','51') then 3 
             when a.sector in('25','26','31','41','42','30','40','20') then 4 
             when a.sector in('00','32') then 5 end sector_laboral,
		d.cod_postal,
	    484 as pais,
		d.estado,
		d.ciudad, 
		g.localidad_inegi,
		h.clave,
		0 as total_empleados,
		ingreso_mensual
        INTO v_num_cliente, v_pers_juridica, v_nombre_cte,v_apellidos, v_nacionalidad, v_fecha_nac, v_sector_economico, v_rfc,  v_curp,     
        v_genero_cte, v_edo_civil, v_sector_laboral, v_cod_postal,v_pais,v_estado,v_deleg_municip,v_localidad,v_activ_economica,v_total_empleados,v_ing_bruto_mens
        from  bdinteg:si_cliente a
		inner join bdinteg:si_ctepf b
        on a.numcte=b.numcte
        and a.empresa=b.empresa
        inner join bdicred:ctes_alta c
        on a.numcte=c.numcte
        inner join bdinteg:si_direcciones d
        on a.numcte=d.numcte
        left join bdinteg:si_ciudades g
        on g.estado=d.estado
        and g.ciudad=d.ciudad
		left join bdinteg:si_ingresos e
        on a.numcte=e.numcte
        and a.empresa=e.empresa
        left join bdicred:sd_clave_x_activ_bim h
        on h.actividad=e.claveopcionpuesto
        and h.subactividad=e.clavesubopcionpuesto
		where a.numcte not in (select num_cliente from sd_repositorio_alta_cte)
		and d.secuencia in(select max(secuencia) from bdinteg:si_direcciones where numcte=a.numcte)
		--and e.sec_ingreso in(select max(sec_ingreso) from bdinteg:si_ingresos where numcte=a.numcte)
		and e.numcte is null and e.empresa is null
		
		/*
		SELECT ingreso_mensual INTO v_ing_bruto_mens
                FROM bdinteg:si_ingresos 
                WHERE numcte =v_num_cliente and sec_ingreso=(select max(sec_ingreso) FROM bdinteg:si_ingresos 
                WHERE numcte =v_num_cliente);*/

	SELECT LIMIT 1 num_solicitud_sic 
	INTO v_num_solicitud_sic 
	FROM bdisolic:ss_solicitudes_sic
	WHERE numcte=v_num_cliente
	AND fecha_insert in(select max(fecha_insert) FROM bdisolic:ss_solicitudes_sic
						WHERE numcte=v_num_cliente);
						
	SELECT LIMIT 1 case when nvl(folio_bc,'') =' ' then '' else folio_bc end, 
	case when nvl(folio_cc,'') = ' ' then '' else folio_cc end  
	INTO v_folio_cte_buro,v_folio_cte_cc
	FROM bdisolic:ss_solicitudes_sic
	WHERE numcte=v_num_cliente
	and num_solicitud=v_num_solicitud_sic
	AND fecha_insert in(select max(fecha_insert) FROM bdisolic:ss_solicitudes_sic
						WHERE numcte=v_num_cliente and num_solicitud=v_num_solicitud_sic);
	
	IF v_nombre_cte LIKE('%  %') THEN 
		LET v_nombre_cte=REPLACE(v_nombre_cte, '  ', ' ');
	END IF;
	
	IF v_apellidos LIKE('%  %') THEN 
		LET v_apellidos=REPLACE(v_apellidos, '  ', ' ');
	END IF;  				
	
	IF length(v_cod_postal)<5 THEN	
		LET v_cod_postal= LPAD(TRIM(v_cod_postal),5,"0");
	END IF;
		
	IF nvl(v_cod_postal,'')='' OR v_cod_postal= '00000' THEN
		LET v_cod_postal= '20000';
		LET v_estado='1';
		LET v_deleg_municip='1';
		LET v_localidad='484010010001';
	END IF
	
	IF length(v_rfc)<13 THEN
		LET v_rfc= RPAD(TRIM(v_rfc),13,"0");
	END IF;
	
	IF v_nacionalidad=2 THEN 
		LET v_curp= 'EXT000000000000000';
	END IF;
	
	IF v_curp='XXXXXXXXXXXXXXXXXX' THEN
		LET v_curp='';
	END IF;
	
	IF v_curp IS NULL or v_curp='' or length(v_curp) <= 10 THEN
		LET v_curp= substr(v_rfc,1,10);
		IF v_genero_cte=1 THEN
			LET v_curp= substr(v_rfc,1,10)||'HXX';
		ELSE
			LET v_curp= substr(v_rfc,1,10)||'MXX';
		END IF;
		
		for i=2 to LEN(v_apellidos)
			LET v_seg_cons_appaterno=substr(v_apellidos,i,1);
			IF v_seg_cons_appaterno<>'A' and v_seg_cons_appaterno<>'E' and v_seg_cons_appaterno<>'I' and v_seg_cons_appaterno<>'O' and v_seg_cons_appaterno<>'U' THEN
				exit for;
			END IF;
		end for;
			
		for i=2 to LEN(v_nombre_cte)
			LET v_seg_cons_nombre=substr(v_nombre_cte,i,1);
			IF v_seg_cons_nombre<>'A' and v_seg_cons_nombre<>'E' and v_seg_cons_nombre<>'I' and v_seg_cons_nombre<>'O' and v_seg_cons_nombre<>'U' THEN
				exit for;
			END IF;
		end for; 
		
		IF v_seg_cons_appaterno='' OR v_seg_cons_appaterno IS NULL THEN
			LET v_seg_cons_appaterno='X';
		END IF;
		
		IF v_seg_cons_nombre='' OR v_seg_cons_nombre IS NULL THEN
			LET v_seg_cons_nombre='X';
		END IF;
		LET v_curp=trim(v_curp)||trim(v_seg_cons_appaterno)||'X'||trim(v_seg_cons_nombre)||'XX';	
			
	END IF;
	
	IF length(v_curp)<18 THEN
		LET v_curp=RPAD(TRIM(v_curp),18,"X");
	END IF;	
	
	IF v_curp LIKE('%#%') THEN 
		LET v_curp= REPLACE(v_curp, '#', 'X');
	END IF;
	
	IF v_curp LIKE('%|%') THEN 
		LET v_curp= REPLACE(v_curp, '|', 'X');
	END IF;
	
	IF v_curp LIKE('%.%') THEN 
		LET v_curp= REPLACE(v_curp, '.', 'X');
	END IF;
	
	IF trim(v_curp) LIKE('% %') THEN 
		LET v_curp= REPLACE(trim(v_curp), ' ', 'X');
	END IF;
	
	IF v_curp LIKE('%/%') THEN 
		LET v_curp= REPLACE(v_curp, '/', 'X');
	END IF;
	
	IF v_curp LIKE('%*%') THEN 
		LET v_curp= REPLACE(v_curp, '*', 'X');
	END IF;
	
	IF v_curp LIKE('%+%') THEN 
		LET v_curp= REPLACE(v_curp, '+', 'X');
	END IF;
	
	IF v_curp LIKE('%-%') THEN 
		LET v_curp= REPLACE(v_curp, '-', 'X');
	END IF;
	
	IF v_curp LIKE('%$%') THEN 
		LET v_curp= REPLACE(v_curp, '$', 'X');
	END IF;
	
	IF v_curp LIKE('%"%') THEN 
		LET v_curp= REPLACE(v_curp, '"', 'X');
	END IF;
	
	/*SELECT LIMIT 1 num_producto, num_credito
	INTO v_producto,v_credito
	FROM clientescred_alta
	WHERE numcte = v_num_cliente;*/
		
	if nvl(v_activ_economica,'')='' then
		let v_activ_economica='81';
	end if;
	
	
        BEGIN WORK;
            INSERT INTO sd_reporte_bim_alta_cte ( fecha_cierre,num_cliente,folio_cte_buro,folio_cte_cc,pers_juridica,nombre_cte,apellidos,nacionalidad,fecha_nac,sector_economico,rfc,curp,
						genero_cte,edo_civil,sector_laboral,ing_bruto_mens,cod_postal,pais,estado,deleg_municip,localidad,activ_economica,total_empleados,
						num_producto,num_credito)
                 VALUES( pPeriodo, v_num_cliente,nvl(v_folio_cte_buro,''),nvl(v_folio_cte_cc,''),v_pers_juridica,v_nombre_cte,v_apellidos,v_nacionalidad,v_fecha_nac,v_sector_economico,v_rfc,v_curp,
						v_genero_cte,v_edo_civil,v_sector_laboral,v_ing_bruto_mens,nvl(v_cod_postal,'00000'),v_pais,v_estado,v_deleg_municip,v_localidad,v_activ_economica,v_total_empleados,
						v_producto,v_credito);
      	COMMIT WORK;
		
	END FOREACH; 
	
	FOREACH WITH HOLD 
			SELECT numcte, num_producto, num_credito
			INTO v_num_cliente_aux, v_producto,v_credito
			FROM bdicred:clientescred_alta
			--WHERE num_cliente = v_num_cliente
		
				select num_producto 
				INTO v_producto_aux
				from sd_reporte_bim_alta_cte
				where num_cliente= v_num_cliente_aux;
				
			IF v_producto_aux = '' THEN
				BEGIN WORK;
						UPDATE sd_reporte_bim_alta_cte SET num_producto=v_producto, num_credito= v_credito where num_cliente= v_num_cliente_aux;
				COMMIT WORK;
			ELSE
				CONTINUE FOREACH;
			END IF;
	END FOREACH;
	
	LET cCadena = '';
	LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitCamp)  ||'  delimiter '';'' SELECT num_cliente,folio_cte_buro,folio_cte_cc,pers_juridica,nombre_cte,apellidos,nacionalidad,fecha_nac,sector_economico,rfc,curp,genero_cte,edo_civil,sector_laboral,ing_bruto_mens,cod_postal,pais,estado,deleg_municip,localidad,activ_economica,total_empleados,num_producto,num_credito FROM bdicred:"informix".sd_reporte_bim_alta_cte WHERE fecha_cierre= ''' ||mdy(month(pPeriodo), day(pPeriodo), year(pPeriodo))|| '''" >'||TRIM(cRuta)||'bim_alta_ctes.sql';
	SYSTEM cCadena;				
	LET cCadena='chmod 777 '|| TRIM(cRuta)||'bim_alta_ctes.sql';
	System cCadena;				
	let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bim_alta_ctes.sql';
	System cCadena;				
	LET cCadena = '' ;
	LET cCadena = 'rm ' || TRIM(cRuta) || 'bim_alta_ctes.sql';
	SYSTEM cCadena;
			
    LET cCodRet     = "00000";
    LET cMensajeRet = "REPORTE BIMESTRAL ALTA_CLIENTES OK ";

	RETURN cCodRet; --, cMensajeRet;
END
END PROCEDURE
;