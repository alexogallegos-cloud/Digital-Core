CREATE PROCEDURE "informix".sp_estadisticas_sac_altactes_minuto
( fechaInicio date, fechaFin date )

RETURNING
	CHAR(5) AS codigo_respuesta,
	CHAR(80) AS mensaje_respuesta;

	DEFINE cCodRet CHAR(5);
	DEFINE cMensaje CHAR(80);
	
    DEFINE usuario CHAR(9);
    DEFINE Vsp CHAR(100);
    DEFINE Vid_sp INTEGER;
    DEFINE Vperiodo CHAR(25);
    DEFINE VVfecha DATE;
    DEFINE VVpromedio_minuto DECIMAL;
    DEFINE VVmaximo_altas INT;
    DEFINE VVhora_maximo_altas CHAR(5);
    DEFINE VVtipo CHAR(25);
    DEFINE VVuser_insert CHAR(25);
    DEFINE VVfecha_insert DATETIME YEAR to FRACTION(3);

    DEFINE Vfecha_insert DATE;
    DEFINE Vconteo int;
    DEFINE Vmin_dif int;
    DEFINE Vprom_min DECIMAL(18,2);

    
	DEFINE iSqlErr INT;
    DEFINE iIsamErr INT;
    DEFINE cInfoErr CHAR;
        
    DEFINE vFecha_minuto char(10);
    DEFINE vFecha_alta char(10);
    DEFINE vMaximo_minuto int;
    DEFINE vHora_maximo char(5);

	LET cCodRet = "00000";
	LET cMensaje = 'PROCESO EXITOSO';

    LET usuario='informix';    
    LET Vsp ='sp_estadisticas_sac_altactes_minuto';
    LET Vid_sp = '4';
    LET Vperiodo = fechaInicio || ' a ' || fechaFin;
    LET VVfecha ='';
    LET VVpromedio_minuto =0;
    LET VVmaximo_altas =0;
    LET VVhora_maximo_altas ='';
    LET VVtipo ='';
    LET VVuser_insert ='';
    LET VVfecha_insert ='';

    LET Vfecha_insert='';
    LET Vconteo =0;
    LET Vmin_dif =0;
    LET Vprom_min =0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

--	SET DEBUG FILE TO '/informix/tmp/sp_estadisticas_sac_altactes_minuto.out';
--	TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
                INSERT INTO "informix".tb_ejecucion_estadisticas_sac(fecha_hora_ejecucion, id_sp, resultado, periodo, usuario_insert, fecha_insert) 
                VALUES(current, Vid_sp, cCodRet, Vperiodo, usuario, current); -- Actualizado RALVAREZ 10/10/2022
				RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;

        DROP TABLE IF EXISTS TB_MAXIMO_INDIVIDUAL_CTES;
		DROP TABLE IF EXISTS TB_SAC_ALTACTES_MINUTO_CTEPF;
		DROP TABLE IF EXISTS TB_SAC_ALTACTES_MINUTO_CLIENTE;
		DROP TABLE IF EXISTS TB_SAC_ESTADISTICAS_ALTACTES_MINUTO;
		
		CREATE TEMP TABLE TB_SAC_ALTACTES_MINUTO_CTEPF (empresa CHAR(3), fecha_insert DATE, hora_insert DATETIME YEAR to FRACTION(3), numcte CHAR(20)) WITH NO LOG; 
		EXECUTE IMMEDIATE  'CREATE INDEX idx_TB_SAC_ALTACTES_MINUTO_CTEPF_tmp ON TB_SAC_ALTACTES_MINUTO_CTEPF(hora_insert)';
		
		CREATE TEMP TABLE TB_SAC_ALTACTES_MINUTO_CLIENTE (empresa CHAR(3), tipo_cliente CHAR(1), numcte CHAR(20)) WITH NO LOG; 
		EXECUTE IMMEDIATE  'CREATE INDEX idx_TB_SAC_ALTACTES_MINUTO_CLIENTE ON TB_SAC_ALTACTES_MINUTO_CLIENTE(numcte)';
		
		CREATE TEMP TABLE TB_SAC_ESTADISTICAS_ALTACTES_MINUTO ( 
													fecha               	DATE,
													conteo_tot          	INTEGER,
													min_dif_tot         	INTEGER,
													prom_mint_tot       	DECIMAL(15,5),
													conteo_tit          	INTEGER,
													min_dif_tit         	INTEGER,
													prom_min_tit        	DECIMAL(15,5),
													conteo_notit        	INTEGER,
													min_dif_notit       	INTEGER,
													prom_min_notit      	DECIMAL(15,5),
													num_max_altas_tot   	INTEGER,
													hora_max_altas_tot  	VARCHAR(5),
													num_max_altas_tit   	INTEGER,
													hora_max_altas_tit  	VARCHAR(5),
													num_max_altas_notit 	INTEGER,
													hora_max_altas_notit	VARCHAR(5),
													user_insert         	VARCHAR(25),
													fecha_insert        	DATETIME YEAR to FRACTION(3),
													sp                  	VARCHAR(50),
													periodo             	VARCHAR(25) 
													) WITH NO LOG;
		
		insert into TB_SAC_ALTACTES_MINUTO_CTEPF (empresa, fecha_insert, hora_insert, numcte)
			select {+INDEX (bdinteg:"informix".si_ctepf.idx_ctepf_hora_insert)} empresa, fecha_insert, hora_insert, numcte
			from bdinteg:"informix".si_ctepf
			where hora_insert is not null 
			and fecha_insert >= mdy(month(fechaInicio),day(fechaInicio),year(fechaInicio)) 
			and fecha_insert <= mdy(month(fechaFin),day(fechaFin),year(fechaFin));
			
		insert into TB_SAC_ALTACTES_MINUTO_CLIENTE (empresa, tipo_cliente,numcte)
			select {+INDEX (bdinteg:"informix".si_cliente.idx_si_clientex)} empresa, tipo_cliente, numcte
			from bdinteg:"informix".si_cliente
			where numcte in(select numcte from TB_SAC_ALTACTES_MINUTO_CTEPF);
		
        --BUSCA E INSERTA TODAS LAS FECHAS DEL PERIODO
                            insert into TB_SAC_ESTADISTICAS_ALTACTES_MINUTO (fecha, conteo_tot, min_dif_tot, prom_mint_tot, sp, periodo, fecha_insert)
                                    select {+ INDEX (TB_SAC_ALTACTES_MINUTO_CTEPF.idx_TB_SAC_ALTACTES_MINUTO_CTEPF_tmp)}
											CP.fecha_insert
                                            ,count(*) as conteo_todos
                                            ,count(distinct(substr(CP.hora_insert, 12, 5))) as min_dif_tot
                                            , cast(count(*) / count(distinct(substr(CP.hora_insert, 12, 5))) as decimal(8,1)) as prom_mint_total
                                            , TRIM(Vsp)
                                            , Vperiodo
											, current
                                    from TB_SAC_ALTACTES_MINUTO_CTEPF CP, TB_SAC_ALTACTES_MINUTO_CLIENTE CT
                                    where (substr(CP.hora_insert, 12, 5) between '10:00' and '20:00')
                                            --and (date(CP.hora_insert) between fechaInicio and fechaFin)
											and DATE(CP.fecha_insert) >= mdy(month(fechaInicio),day(fechaInicio),year(fechaInicio))
											and DATE(CP.fecha_insert) <= mdy(month(fechaFin),day(fechaFin),year(fechaFin))
                                            and CP.numcte=CT.numcte
                                    group by 1
                                    order by 1 asc;
                                    
                        FOREACH SELECT fecha INTO vFecha_alta from TB_SAC_ESTADISTICAS_ALTACTES_MINUTO where fecha between fechaInicio and fechaFin
                                        LET Vconteo=0;
                                        LET Vmin_dif=0;
                                        LET Vprom_min=0;
                                        
          --BUSCA, CUENTA Y ASIGNA CLIENTES TIPO 1
                                    if (select count(*) from (select {+ INDEX (TB_SAC_ALTACTES_MINUTO_CTEPF.idx_TB_SAC_ALTACTES_MINUTO_CTEPF_tmp)}
																CP.fecha_insert, count(*) as conteo_todos, count(distinct(substr(CP.hora_insert, 12, 5))) as min_dif_tot
                                        ,cast(count(*) / count(distinct(substr(CP.hora_insert, 12, 5))) as decimal(8,1)) as prom_mint_total
                                        from TB_SAC_ALTACTES_MINUTO_CTEPF CP, TB_SAC_ALTACTES_MINUTO_CLIENTE CT
                                        where CT.empresa='001' and CT.tipo_cliente = '1' and substr(CP.hora_insert, 12, 5) between '10:00' and '20:00'
                                        and date(CP.hora_insert) = date(vFecha_alta)
                                        and CT.numcte=CP.numcte group by CP.fecha_insert order by CP.fecha_insert asc) as t1) > 0 then
       
                                        select {+ INDEX (TB_SAC_ALTACTES_MINUTO_CTEPF.idx_TB_SAC_ALTACTES_MINUTO_CTEPF_tmp)}
											first 1 fecha_insert, conteo_todos, min_dif_tot, prom_mint_total into Vfecha_insert, Vconteo, Vmin_dif, Vprom_min from (select CP.fecha_insert, count(*) as conteo_todos, count(distinct(substr(CP.hora_insert, 12, 5))) as min_dif_tot
											 ,cast(count(*) / count(distinct(substr(CP.hora_insert, 12, 5))) as decimal(8,1)) as prom_mint_total
											 from TB_SAC_ALTACTES_MINUTO_CTEPF CP, TB_SAC_ALTACTES_MINUTO_CLIENTE CT
											 where CT.empresa='001' and CT.tipo_cliente='1' and substr(CP.hora_insert, 12, 5) between '10:00' and '20:00'
											 and date(CP.hora_insert) = date(vFecha_alta)
											 and CT.numcte=CP.numcte group by CP.fecha_insert order by CP.fecha_insert asc) as t2;
                                    else
                                        LET Vconteo=0;
                                        LET Vmin_dif=0;
                                        LET Vprom_min=0;
                                    end if;

                 UPDATE TB_SAC_ESTADISTICAS_ALTACTES_MINUTO 
				 SET conteo_tit= Vconteo, min_dif_tit= Vmin_dif, prom_min_tit= Vprom_min, user_insert=usuario--, fecha_insert=current 
				 WHERE fecha= vFecha_alta;
                                    
                --BUSCA, CUENTA Y ASIGNA CLIENTES QUE NO SEAN TIPO 1
                                    if (select count(*) from (select {+ INDEX (TB_SAC_ALTACTES_MINUTO_CTEPF.idx_TB_SAC_ALTACTES_MINUTO_CTEPF_tmp)}
											CP.fecha_insert, count(*) as conteo_todos, count(distinct(substr(CP.hora_insert, 12, 5))) as min_dif_tot
                                        ,cast(count(*) / count(distinct(substr(CP.hora_insert, 12, 5))) as decimal(8,1)) as prom_mint_total
                                        from TB_SAC_ALTACTES_MINUTO_CTEPF CP, TB_SAC_ALTACTES_MINUTO_CLIENTE CT
                                        where CT.empresa='001' and CT.tipo_cliente <> '1' and substr(CP.hora_insert, 12, 5) between '10:00' and '20:00'
                                        and date(CP.hora_insert) = date(vFecha_alta)
                                        and CT.numcte=CP.numcte group by CP.fecha_insert order by CP.fecha_insert asc) as t1) > 0 then

                                        select first 1 fecha_insert, conteo_todos, min_dif_tot, prom_mint_total into Vfecha_insert, Vconteo, Vmin_dif, Vprom_min 
											from (select {+ INDEX (TB_SAC_ALTACTES_MINUTO_CTEPF.idx_TB_SAC_ALTACTES_MINUTO_CTEPF_tmp)}
													CP.fecha_insert, count(*) as conteo_todos, count(distinct(substr(CP.hora_insert, 12, 5))) as min_dif_tot
													 ,cast(count(*) / count(distinct(substr(CP.hora_insert, 12, 5))) as decimal(8,1)) as prom_mint_total
													 from TB_SAC_ALTACTES_MINUTO_CTEPF CP, TB_SAC_ALTACTES_MINUTO_CLIENTE CT
													 where CT.empresa='001' and CT.tipo_cliente <>'1' and substr(CP.hora_insert, 12, 5) between '10:00' and '20:00'
													 and date(CP.hora_insert) = date(vFecha_alta)
													 and CT.numcte=CP.numcte group by CP.fecha_insert order by CP.fecha_insert asc
											) as t2;
                                    else
                                        LET Vconteo=0;
                                        LET Vmin_dif=0;
                                        LET Vprom_min=0;
                                    end if;

				UPDATE TB_SAC_ESTADISTICAS_ALTACTES_MINUTO 
				SET conteo_notit= Vconteo, min_dif_notit= Vmin_dif, prom_min_notit= Vprom_min, user_insert=usuario--, fecha_insert=current 
				WHERE fecha= vFecha_alta;
                                    
           --BUSCA MAXIMO INDIVIDUAL (TODOS LOS CLIENTES)
                              if (select count(*) from (
                                                        select {+ INDEX (TB_SAC_ALTACTES_MINUTO_CTEPF.idx_TB_SAC_ALTACTES_MINUTO_CTEPF_tmp)}
														first 1 I.fecha_insert, count(substr(I.hora_insert, 12, 5)) as altasXMinuto, substr(I.hora_insert, 12, 5) as minuto
                                                        from TB_SAC_ALTACTES_MINUTO_CTEPF I, TB_SAC_ALTACTES_MINUTO_CLIENTE C where I.empresa='001' and
                                                        substr(I.hora_insert, 12, 5) between '10:00' and '20:00' 
                                                        and date(I.hora_insert)=date(vFecha_alta) and I.numcte=C.numcte
                                                        group by 1,3  having count(substr(I.hora_insert, 12, 5)) = (SELECT MAX(A.altasXMinutos) 
                                                        FROM (select {+ INDEX (TB_SAC_ALTACTES_MINUTO_CTEPF.idx_TB_SAC_ALTACTES_MINUTO_CTEPF_tmp)}
																I.fecha_insert, substr(I.hora_insert, 12, 5) as minuto, count(substr(I.hora_insert, 12, 5)) as altasXMinutos
																from TB_SAC_ALTACTES_MINUTO_CTEPF I, TB_SAC_ALTACTES_MINUTO_CLIENTE C where I.empresa='001' and
																substr(I.hora_insert, 12, 5) between '10:00' and '20:00'
																and date(I.hora_insert)=date(vFecha_alta) and I.numcte=C.numcte group by 1,2) AS A ) --order by 3 desc;
																)as t1) > 0 then
                                 
                                DROP TABLE IF EXISTS TB_MAXIMO_INDIVIDUAL_CTES;
                                    CREATE TEMP TABLE TB_MAXIMO_INDIVIDUAL_CTES (fecha char(10), maximo int, minuto char(5), indice SERIAL) WITH NO LOG; 
                                                insert into TB_MAXIMO_INDIVIDUAL_CTES (fecha, maximo, minuto)
                                                    select {+ INDEX (TB_SAC_ALTACTES_MINUTO_CTEPF.idx_TB_SAC_ALTACTES_MINUTO_CTEPF_tmp)}
														first 1 I.fecha_insert, count(substr(I.hora_insert, 12, 5)) as altasXMinuto, substr(I.hora_insert, 12, 5) as minuto
                                                        from TB_SAC_ALTACTES_MINUTO_CTEPF I, TB_SAC_ALTACTES_MINUTO_CLIENTE C where I.empresa='001' and
                                                        substr(I.hora_insert, 12, 5) between '10:00' and '20:00' 
                                                        and date(I.hora_insert)=date(vFecha_alta) and I.numcte=C.numcte
                                                        group by 1,3  having count(substr(I.hora_insert, 12, 5)) = (SELECT MAX(A.altasXMinutos) 
                                                        FROM (select {+ INDEX (TB_SAC_ALTACTES_MINUTO_CTEPF.idx_TB_SAC_ALTACTES_MINUTO_CTEPF_tmp)}
																I.fecha_insert, substr(I.hora_insert, 12, 5) as minuto, count(substr(I.hora_insert, 12, 5)) as altasXMinutos
																from TB_SAC_ALTACTES_MINUTO_CTEPF I, TB_SAC_ALTACTES_MINUTO_CLIENTE C where I.empresa='001' and
																substr(I.hora_insert, 12, 5) between '10:00' and '20:00'
																and date(I.hora_insert)=date(vFecha_alta) and I.numcte=C.numcte group by 1,2) 
														AS A ) order by 3 desc;

                                    LET vMaximo_minuto=(select maximo from TB_MAXIMO_INDIVIDUAL_CTES where indice=1);
                                    LET vHora_maximo=(select minuto from TB_MAXIMO_INDIVIDUAL_CTES where indice=1);
                                    
										 UPDATE TB_SAC_ESTADISTICAS_ALTACTES_MINUTO 
										 SET num_max_altas_tot=vMaximo_minuto, hora_max_altas_tot=vHora_maximo 
										 WHERE fecha= vFecha_alta;
				 
                                    DROP TABLE IF EXISTS TB_MAXIMO_INDIVIDUAL_CTES; 
                                end if

               --BUSCA MAXIMO INDIVIDUAL (CLIENTES TITULARES)
                              if (select count(*) from (
                                                        select {+ INDEX (TB_SAC_ALTACTES_MINUTO_CTEPF.idx_TB_SAC_ALTACTES_MINUTO_CTEPF_tmp)}
															first 1 I.fecha_insert, count(substr(I.hora_insert, 12, 5)) as altasXMinuto, substr(I.hora_insert, 12, 5) as minuto
                                                        from TB_SAC_ALTACTES_MINUTO_CTEPF I, TB_SAC_ALTACTES_MINUTO_CLIENTE C where I.empresa='001' and
                                                        C.tipo_cliente='1'
                                                        and substr(I.hora_insert, 12, 5) between '10:00' and '20:00' 
                                                        and date(I.hora_insert)=date(vFecha_alta) and I.numcte=C.numcte
                                                        group by 1,3  having count(substr(I.hora_insert, 12, 5)) = (SELECT MAX(A.altasXMinutos) 
                                                        FROM (select {+ INDEX (TB_SAC_ALTACTES_MINUTO_CTEPF.idx_TB_SAC_ALTACTES_MINUTO_CTEPF_tmp)}
																I.fecha_insert, substr(I.hora_insert, 12, 5) as minuto, count(substr(I.hora_insert, 12, 5)) as altasXMinutos
																from TB_SAC_ALTACTES_MINUTO_CTEPF I, TB_SAC_ALTACTES_MINUTO_CLIENTE C where I.empresa='001' and
																C.tipo_cliente='1'
																and substr(I.hora_insert, 12, 5) between '10:00' and '20:00'
																and date(I.hora_insert)=date(vFecha_alta) and I.numcte=C.numcte group by 1,2) AS A ) --order by 3 desc;
                                                        )as t1) > 0 then
                                 
                                DROP TABLE IF EXISTS TB_MAXIMO_INDIVIDUAL_CTES_TITULARES;
                                    CREATE TEMP TABLE TB_MAXIMO_INDIVIDUAL_CTES_TITULARES (fecha char(10), maximo int, minuto char(5)) WITH NO LOG; 
                                                insert into TB_MAXIMO_INDIVIDUAL_CTES_TITULARES (fecha, maximo, minuto)
                                                    select {+ INDEX (TB_SAC_ALTACTES_MINUTO_CTEPF.idx_TB_SAC_ALTACTES_MINUTO_CTEPF_tmp)}
															first 1 I.fecha_insert, count(substr(I.hora_insert, 12, 5)) as altasXMinuto, substr(I.hora_insert, 12, 5) as minuto
                                                        from TB_SAC_ALTACTES_MINUTO_CTEPF I, TB_SAC_ALTACTES_MINUTO_CLIENTE C where I.empresa='001' and
                                                        C.tipo_cliente='1'
                                                        and substr(I.hora_insert, 12, 5) between '10:00' and '20:00' 
                                                        and date(I.hora_insert)=date(vFecha_alta) and I.numcte=C.numcte
                                                        group by 1,3  having count(substr(I.hora_insert, 12, 5)) = (SELECT MAX(A.altasXMinutos) 
                                                        FROM (select {+ INDEX (TB_SAC_ALTACTES_MINUTO_CTEPF.idx_TB_SAC_ALTACTES_MINUTO_CTEPF_tmp)}
																I.fecha_insert, substr(I.hora_insert, 12, 5) as minuto, count(substr(I.hora_insert, 12, 5)) as altasXMinutos
																from TB_SAC_ALTACTES_MINUTO_CTEPF I , TB_SAC_ALTACTES_MINUTO_CLIENTE C where I.empresa='001' and
																C.tipo_cliente='1'
																and substr(I.hora_insert, 12, 5) between '10:00' and '20:00'
																and date(I.hora_insert)=date(vFecha_alta) and I.numcte=C.numcte group by 1,2) 
															AS A ) 
														order by 3 desc;

                                    LET vMaximo_minuto=(select maximo from TB_MAXIMO_INDIVIDUAL_CTES_TITULARES where date(fecha)= date(vFecha_alta));
                                    LET vHora_maximo=(select minuto from TB_MAXIMO_INDIVIDUAL_CTES_TITULARES where date(fecha)= date(vFecha_alta));
                                    
									 UPDATE TB_SAC_ESTADISTICAS_ALTACTES_MINUTO 
									 SET num_max_altas_tit=vMaximo_minuto, hora_max_altas_tit=vHora_maximo 
									 WHERE fecha= vFecha_alta;
									 
                                    DROP TABLE IF EXISTS TB_MAXIMO_INDIVIDUAL_CTES_TITULARES; 
                                ELSE
									 UPDATE TB_SAC_ESTADISTICAS_ALTACTES_MINUTO 
									 SET num_max_altas_tit=0, hora_max_altas_tit='00:00' 
									 WHERE fecha= vFecha_alta;

                                    DROP TABLE IF EXISTS TB_MAXIMO_INDIVIDUAL_CTES_TITULARES; 
                                end if

             --BUSCA MAXIMO INDIVIDUAL (CLIENTES NO TITULARES)
                              if (select count(*) from (
                                                        select {+ INDEX (TB_SAC_ALTACTES_MINUTO_CTEPF.idx_TB_SAC_ALTACTES_MINUTO_CTEPF_tmp)}
														first 1 I.fecha_insert, count(substr(I.hora_insert, 12, 5)) as altasXMinuto, substr(I.hora_insert, 12, 5) as minuto
                                                        from TB_SAC_ALTACTES_MINUTO_CTEPF I, TB_SAC_ALTACTES_MINUTO_CLIENTE C where I.empresa='001' and
                                                        C.tipo_cliente<>'1'
                                                        and substr(I.hora_insert, 12, 5) between '10:00' and '20:00' 
                                                        and date(I.hora_insert)=date(vFecha_alta) and I.numcte=C.numcte
                                                        group by 1,3  having count(substr(I.hora_insert, 12, 5)) = (SELECT MAX(A.altasXMinutos) 
                                                        FROM (select {+ INDEX (TB_SAC_ALTACTES_MINUTO_CTEPF.idx_TB_SAC_ALTACTES_MINUTO_CTEPF_tmp)}
																I.fecha_insert, substr(I.hora_insert, 12, 5) as minuto, count(substr(I.hora_insert, 12, 5)) as altasXMinutos
																from TB_SAC_ALTACTES_MINUTO_CTEPF I, TB_SAC_ALTACTES_MINUTO_CLIENTE C where I.empresa='001' and
																C.tipo_cliente<>'1'
																and substr(I.hora_insert, 12, 5) between '10:00' and '20:00'
																and date(I.hora_insert)=date(vFecha_alta) and I.numcte=C.numcte group by 1,2) AS A ) --order by 3 desc;
                                                        )as t1) > 0 then
                                 
                                DROP TABLE IF EXISTS TB_MAXIMO_INDIVIDUAL_CTES_NOTITULARES;

                                    CREATE TEMP TABLE TB_MAXIMO_INDIVIDUAL_CTES_NOTITULARES (fecha char(10), maximo int, minuto char(5)) WITH NO LOG; 
                                                insert into TB_MAXIMO_INDIVIDUAL_CTES_NOTITULARES (fecha, maximo, minuto)
                                                    select {+ INDEX (TB_SAC_ALTACTES_MINUTO_CTEPF.idx_TB_SAC_ALTACTES_MINUTO_CTEPF_tmp)}
														first 1 I.fecha_insert, count(substr(I.hora_insert, 12, 5)) as altasXMinuto, substr(I.hora_insert, 12, 5) as minuto
                                                        from TB_SAC_ALTACTES_MINUTO_CTEPF I, TB_SAC_ALTACTES_MINUTO_CLIENTE C where I.empresa='001' and
                                                        C.tipo_cliente<>'1'
                                                        and substr(I.hora_insert, 12, 5) between '10:00' and '20:00' 
                                                        and date(I.hora_insert)=date(vFecha_alta) and I.numcte=C.numcte
                                                        group by 1,3  having count(substr(I.hora_insert, 12, 5)) = (SELECT MAX(A.altasXMinutos) 
                                                        FROM (select {+ INDEX (TB_SAC_ALTACTES_MINUTO_CTEPF.idx_TB_SAC_ALTACTES_MINUTO_CTEPF_tmp)}
																I.fecha_insert, substr(I.hora_insert, 12, 5) as minuto, count(substr(I.hora_insert, 12, 5)) as altasXMinutos
																from TB_SAC_ALTACTES_MINUTO_CTEPF I, TB_SAC_ALTACTES_MINUTO_CLIENTE C where I.empresa='001' and
																C.tipo_cliente<>'1'
																and substr(I.hora_insert, 12, 5) between '10:00' and '20:00'
																and date(I.hora_insert)=date(vFecha_alta) and I.numcte=C.numcte group by 1,2) 
														AS A ) order by 3 desc;

                                    LET vMaximo_minuto=(select maximo from TB_MAXIMO_INDIVIDUAL_CTES_NOTITULARES where date(fecha)= date(vFecha_alta));
                                    LET vHora_maximo=(select minuto from TB_MAXIMO_INDIVIDUAL_CTES_NOTITULARES where date(fecha)= date(vFecha_alta));
                                    
									 UPDATE TB_SAC_ESTADISTICAS_ALTACTES_MINUTO 
									 SET num_max_altas_notit=vMaximo_minuto, hora_max_altas_notit=vHora_maximo 
									 WHERE fecha= vFecha_alta;

                                    DROP TABLE IF EXISTS TB_MAXIMO_INDIVIDUAL_CTES_NOTITULARES; 
                                ELSE
									 UPDATE TB_SAC_ESTADISTICAS_ALTACTES_MINUTO
									 SET num_max_altas_notit=0, hora_max_altas_notit='00:00' 
									 WHERE fecha= vFecha_alta;
				 
                                    DROP TABLE IF EXISTS TB_MAXIMO_INDIVIDUAL_CTES_NOTITULARES; 
                                end if

                                END FOREACH;
								
				INSERT INTO bdisac:"informix".sac_estadisticas_altactes_minuto 
					SELECT * FROM TB_SAC_ESTADISTICAS_ALTACTES_MINUTO;
										
					DROP TABLE IF EXISTS TB_MAXIMO_INDIVIDUAL_CTES;
					DROP TABLE IF EXISTS TB_SAC_ALTACTES_MINUTO_CTEPF;
					DROP TABLE IF EXISTS TB_SAC_ALTACTES_MINUTO_CLIENTE;
					DROP TABLE IF EXISTS TB_SAC_ESTADISTICAS_ALTACTES_MINUTO;

                    INSERT INTO "informix".tb_ejecucion_estadisticas_sac(fecha_hora_ejecucion, id_sp, resultado, periodo, usuario_insert, fecha_insert) 
                VALUES(current, Vid_sp, cCodRet, Vperiodo, usuario, current); -- Actualizado RALVAREZ 10/10/2022
						
			RETURN cCodRet, cMensaje;
	END;

END PROCEDURE
DOCUMENT
'AUTOR: Noe Medina Ramirez ',
'DESCRIPCIÃN: Genera la informaciÃ³n para los Reportes Periodicos de ALTA DE CLIENTES POR MINUTO',
'SUSTENTO: ',
'EJECUTADO O LLAMADO POR: ',
'FECHA: 09/09/2016 ',
'ACTUALIZACION:',
'FECHA: 30/11/2016 ',
'SE QUITA EL TRUNCATE DE LA TABLA DE ESTADISTICAS',
'ACTUALIZACION:',
'FECHA: 05/12/2016 ',
'SE CAMBIA EL FORMATO DE FECHAS A MDY',
'VERSIÃN:  ',
'Solicita: Jaime GonzÃ¡lez',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_estadisticas_sac_altactes_sucursal
( fechaInicio date, fechaFin date )

RETURNING
	CHAR(5) AS codigo_respuesta,
	CHAR(80) AS mensaje_respuesta;

	DEFINE cCodRet CHAR(5);
	DEFINE cMensaje CHAR(80);

    DEFINE usuario CHAR(9);
    DEFINE Vsp CHAR(100);
    DEFINE Vid_sp INTEGER;
    DEFINE Vperiodo CHAR(25);
	DEFINE iSqlErr INT;
    DEFINE iIsamErr INT;
    DEFINE cInfoErr CHAR;
	
	DEFINE dFecha_insert DATE;
	DEFINE cTipo_cliente CHAR(1);
	DEFINE cSucursal CHAR(4);
	
	DEFINE cSPCodRet CHAR(5); 
	DEFINE iMensaje CHAR(50);
	DEFINE cid_ptf CHAR(5); 
	DEFINE ccve_pais CHAR(3);
	DEFINE cnompais CHAR(20);
	DEFINE ccalle VARCHAR(100); 
	DEFINE cnum_ext VARCHAR(6); 
	DEFINE cnum_int VARCHAR(5); 
	DEFINE ccve_col CHAR(8);
	DEFINE cnomcol VARCHAR(100);
	DEFINE ccve_mun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE ccve_localidad CHAR(14);
	DEFINE cnomlocalidad VARCHAR(60);
	DEFINE ccp CHAR(5); 
	DEFINE ccve_ciudad CHAR(3);
	DEFINE cnomciudad VARCHAR(60);
	DEFINE ccve_estado CHAR(2); 
	DEFINE cnomestado VARCHAR(30);
	DEFINE ctel1 VARCHAR(14); 
	DEFINE ctel2 VARCHAR(14);
	DEFINE ctipo VARCHAR(5);
    
	LET cCodRet = "00000";
	LET cMensaje = 'PROCESO EXITOSO';
	
    LET usuario='informix';  
    LET Vsp ='sp_estadisticas_sac_altactes_sucursal';
    LET Vid_sp = '8';
    LET Vperiodo = fechaInicio || ' a ' || fechaFin;
	
	LET dFecha_insert = '';
	LET cTipo_cliente = '';
	LET cSucursal = '';
	
	LET cSPCodRet = '00000';
	LET iMensaje = '';
	LET cid_ptf = '';
	LET ccve_pais = '';
	LET cnompais = '';
	LET ccalle = '';
	LET cnum_ext = ''; 
	LET cnum_int = '';
	LET ccve_col = '';
	LET cnomcol = '';
	LET ccve_mun = '';
	LET cnommunicipio = '';
	LET ccve_localidad = '';
	LET cnomlocalidad = '';
	LET ccp = '';
	LET ccve_ciudad = '';
	LET cnomciudad = '';
	LET ccve_estado = ''; 
	LET cnomestado = '';
	LET ctel1 = '';
	LET ctel2 = '';
	LET ctipo = '';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

--	SET DEBUG FILE TO '/ifxsif01/Control-M/sp_estadisticas_sac_altactes_sucursal.out';
--	TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
				INSERT INTO "informix".tb_ejecucion_estadisticas_sac(fecha_hora_ejecucion, id_sp, resultado, periodo, usuario_insert, fecha_insert) 
                VALUES(current, Vid_sp, cCodRet, Vperiodo, usuario, current); -- Actualizado RALVAREZ 10/10/2022
				RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;
		
		DROP TABLE IF EXISTS TB_SAC_ALTACTES_SUCURSAL;
		
		CREATE TEMP TABLE TB_SAC_ALTACTES_SUCURSAL (sucursal CHAR(37), tipo_cliente CHAR(1), fecha_insert date) WITH NO LOG; 
		
		FOREACH
			select {+INDEX(bdinteg:"informix".si_cliente.idx_fecha_insert)} 				  				
			C.fecha_insert, C.tipo_cliente, C.sucursal
			into dFecha_insert, cTipo_cliente, cSucursal
			from bdinteg:"informix".si_cliente C
			where C.fecha_insert >= mdy(month(fechaInicio),day(fechaInicio),year(fechaInicio)) 
			and C.fecha_insert <= mdy(month(fechaFin),day(fechaFin),year(fechaFin))
			
			execute procedure bdisac:"informix".sp_sac_consucursales(cSucursal) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,ccve_estado,cnomestado,ctel1,ctel2,ctipo;

			insert into TB_SAC_ALTACTES_SUCURSAL (sucursal,tipo_cliente, fecha_insert)
			values (cSucursal || ' - ' || cnomestado,cTipo_cliente,dFecha_insert);

		END FOREACH;		
					
		insert into "informix".sac_estadisticas_altactes_sucursal (mes, anio, mesanio, num_sucursal, estado, sucursal, ctes_titulares, ctes_no_titulares, total, user_insert, fecha_insert, sp, periodo)
		   select month(fecha_insert) as mes
				, year(fecha_insert) as anio
				, DECODE(MONTH(fecha_insert),1,'Enero',2,'Febrero',3,'Marzo',4,'Abril',5,'Mayo',6,'Junio',7,'Julio',8,'Agosto',9,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre') || ' ' || year(fecha_insert) as mesanio 
				, substr(sucursal,1,4) as cve_suc
				, substr(sucursal,8,37) as nom_suc
				, sucursal
				,sum(case tipo_cliente when '1' then 1 else 0 end) as ctes_titulares
				,sum(case tipo_cliente when '1' then 0 else 1 end) as ctes_no_titulares
				,COUNT(*) as total
				,usuario
				,current
				,trim(Vsp)
				,Vperiodo
			from TB_SAC_ALTACTES_SUCURSAL
			group by 2,1,3,4,5,6
			order by 2,1,3,4,5,6 asc;
				
		DROP TABLE IF EXISTS TB_SAC_ALTACTES_SUCURSAL;

		INSERT INTO "informix".tb_ejecucion_estadisticas_sac(fecha_hora_ejecucion, id_sp, resultado, periodo, usuario_insert, fecha_insert) 
                VALUES(current, Vid_sp, cCodRet, Vperiodo, usuario, current); -- Actualizado RALVAREZ 10/10/2022
		
		RETURN cCodRet, cMensaje;
	END;

END PROCEDURE;