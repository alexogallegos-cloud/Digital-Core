CREATE PROCEDURE "informix".sp_ctrl_estadisticas_sac()

RETURNING
    CHAR(5) AS codigo_respuesta,
	CHAR(80) AS mensaje_respuesta;

	DEFINE cCodRet CHAR(5);
	DEFINE cMensaje CHAR(80);

    DEFINE fechaInicio date;
    DEFINE fechaFin date;

	DEFINE iSqlErr INT;
    DEFINE iIsamErr INT;
    DEFINE cInfoErr CHAR;
    
    DEFINE usuario CHAR(9);
    DEFINE Vsp CHAR(100);
    DEFINE Vid_sp INT;
    --DEFINE Vestatus CHAR(5);
    DEFINE VnombreSP CHAR(50);
    DEFINE Vnombretabla CHAR(100);
    DEFINE Vperiodo CHAR(25);

    DEFINE ejecutaSP CHAR(100);
    DEFINE vsql CHAR(500);
	DEFINE vruta CHAR(100);
	LET cCodRet = "00000";
	LET cMensaje = 'PROCESO EXITOSO';

    LET usuario= 'informix';    
    LET fechaInicio=(SELECT first 1 date(LAST_DAY(ADD_MONTHS(today, -2)) + 1) FROM bdisac:"informix".sac_fechas WHERE empresa = '001');    
    LET fechaFin=(SELECT first 1 date(LAST_DAY(ADD_MONTHS(today, -1))) FROM bdisac:"informix".sac_fechas WHERE empresa = '001');    
    LET Vsp ='sp_ctrl_estadisticas_sac';
	LET Vid_sp = '0';
    LET Vperiodo = fechaInicio || ' a ' || fechaFin;
	LET vruta = '/ifxsif01/Control-M/';
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
    --SET DEBUG FILE TO '/ifxsif01/Control-M/sac_ctrl.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET Vid_sp=0;
                INSERT INTO "informix".tb_ejecucion_estadisticas_sac(fecha_hora_ejecucion, id_sp, resultado, periodo, usuario_insert, fecha_insert) 
                VALUES(current, Vid_sp, iSqlErr || ' - ' || iIsamErr, Vperiodo, usuario, current);
				LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR ctrl";
				RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;

        FOREACH SELECT id_sp, tabla INTO Vid_sp, Vnombretabla from "informix".tb_ctrl_estadisticas_sac where estatus_sp=1 order by prioridad asc
            
                LET vsql = '';            
                --LET Vestatus='';
                LET VnombreSP=(select nombre_sp from "informix".tb_ctrl_estadisticas_sac where id_sp=Vid_sp);
                LET Vnombretabla= (select tabla from "informix".tb_ctrl_estadisticas_sac where id_sp=Vid_sp);
                LET vsql = '';

                LET vsql = cast('echo "EXECUTE PROCEDURE "informix".' || TRIM(VnombreSP) || '(''' || month(fechaInicio) || '/' || day(fechaInicio) || '/' || year(fechaInicio) || ''',''' || month(fechaFin) || '/' || day(fechaFin) || '/' || year(fechaFin) || '''); UPDATE "informix".' || TRIM(Vnombretabla) || ' set sp=''' || TRIM(Vsp) || ''' where fecha_insert in(SELECT max(fecha_insert) FROM "informix".' || TRIM(Vnombretabla) || ');" > ' || TRIM(vruta) || 'sac_ctrl.sql' as char(500));
                SYSTEM trim(vsql);
				
				LET vsql = 'chmod 777 ' || TRIM(vruta) || 'sac_ctrl.sql';
                SYSTEM trim(vsql);
				
                LET vsql = cast('dbaccess bdisac /ifxsif01/Control-M/sac_ctrl.sql' as char(500));
				--LET vsql = cast('/infmx_desa/bin/dbaccess bdisac ' || TRIM(vruta) || 'sac_ctrl.sql' as char(500));--Dev

				
                SYSTEM trim(vsql);

                --LET Vestatus='OK';

            
        END FOREACH;
		
		INSERT INTO "informix".tb_ejecucion_estadisticas_sac(fecha_hora_ejecucion, id_sp, resultado, periodo, usuario_insert, fecha_insert) 
            VALUES(current, Vid_sp, cCodRet, Vperiodo, usuario, current); -- Actualizado RALVAREZ 10/10/2022
		
		RETURN cCodRet, cMensaje; 
	END;

END PROCEDURE
DOCUMENT
'AUTOR: Noe Medina Ramirez ',
'DESCRIPCIÃN: Ejecuta los SPLs definidos en la tabla: TB_CTRL_ESTADISTICAS_SAC',
'SUSTENTO: ',
'EJECUTADO O LLAMADO POR: ',
'FECHA: 09/09/2016 ',
'ACTUALIZACION:',
'FECHA: 05/12/2016 ',
'SE QUITA LA CONDICION QUE NO EJECUTABA EL PROCESO SI YA SE HABIA EJECUTADO EN LA TABLA EJECUCIONES',
'VERSIÃN:  ',
'Solicita: Jaime GonzÃ¡lez',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_ctrl_estadisticas_sac
(fechaInicio DATE, fechaFin DATE)

RETURNING
    CHAR(5) AS codigo_respuesta,
	CHAR(80) AS mensaje_respuesta;

	DEFINE cCodRet CHAR(5);
	DEFINE cMensaje CHAR(80);

	DEFINE iSqlErr INT;
    DEFINE iIsamErr INT;
    DEFINE cInfoErr CHAR;
    
    DEFINE usuario CHAR(9);
    DEFINE Vsp CHAR(100);
    DEFINE Vid_sp INT;
    --DEFINE Vestatus CHAR(5);
    DEFINE VnombreSP CHAR(50);
    DEFINE Vnombretabla CHAR(100);
    DEFINE Vperiodo CHAR(25);

    DEFINE ejecutaSP CHAR(100);
    DEFINE vsql CHAR(500);
    DEFINE vruta CHAR(100);

	LET cCodRet = "00000";
	LET cMensaje = 'PROCESO EXITOSO';

    LET usuario= 'informix';    

    LET Vsp ='sp_ctrl_estadisticas_sac(date,date)';
    LET Vid_sp = '0';
    LET Vperiodo = fechaInicio || ' a ' || fechaFin;

    LET vruta = '/ifxsif01/Control-M/';
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
    --SET DEBUG FILE TO '/ifxsif01/Control-M/sac_ctrl_date.out';
	--TRACE ON;

	BEGIN
		
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET Vid_sp=0;
                INSERT INTO "informix".tb_ejecucion_estadisticas_sac(fecha_hora_ejecucion, id_sp, resultado, periodo, usuario_insert, fecha_insert) 
                VALUES(current, Vid_sp, iSqlErr || ' - ' || iIsamErr, Vperiodo, usuario, current);
				LET cCodRet = iSqlErr;
				LET cMensaje = 'ERROR ctrl';
				RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;

        FOREACH SELECT id_sp, tabla INTO Vid_sp, Vnombretabla from "informix".tb_ctrl_estadisticas_sac where estatus_sp=1 order by prioridad asc
		
                LET vsql = '';            
                --LET Vestatus='';
                LET VnombreSP=(select nombre_sp from "informix".tb_ctrl_estadisticas_sac where id_sp=Vid_sp);
                LET Vnombretabla= (select tabla from "informix".tb_ctrl_estadisticas_sac where id_sp=Vid_sp);
                LET vsql = '';
				
                LET vsql = cast('echo "EXECUTE PROCEDURE "informix".' || TRIM(VnombreSP) || '(''' || month(fechaInicio) || '/' || day(fechaInicio) || '/' || year(fechaInicio) || ''',''' || month(fechaFin) || '/' || day(fechaFin) || '/' || year(fechaFin) || '''); UPDATE "informix".' || TRIM(Vnombretabla) || ' set sp=''' || TRIM(Vsp) || ''' where fecha_insert in(SELECT max(fecha_insert) FROM "informix".' || TRIM(Vnombretabla) || ');" > ' || TRIM(vruta) || 'sac_ctrl.sql' as char(500));
				
                SYSTEM trim(vsql);

                LET vsql = 'chmod 777 ' || TRIM(vruta) || 'sac_ctrl.sql';
                SYSTEM trim(vsql);
				
                LET vsql = cast('dbaccess bdisac ' || TRIM(vruta) || 'sac_ctrl.sql' as char(500));                --LET vsql = cast('/infmx_desa/bin/dbaccess bdisac ' || TRIM(vruta) || 'sac_ctrl.sql' as char(500));--Dev
                
                SYSTEM trim(vsql);

                --LET Vestatus='OK';

        END FOREACH;

        INSERT INTO "informix".tb_ejecucion_estadisticas_sac(fecha_hora_ejecucion, id_sp, resultado, periodo, usuario_insert, fecha_insert) 
            VALUES(current, Vid_sp, cCodRet, Vperiodo, usuario, current); -- Actualizado RALVAREZ 10/10/2022
		
		RETURN cCodRet, cMensaje; 
	END;

END PROCEDURE
DOCUMENT
'AUTOR: Noe Medina Ramirez ',
'DESCRIPCIÃN: Ejecuta los SPLs definidos en la tabla: TB_CTRL_ESTADISTICAS_SAC con 2 con dos parametros de entrada',
'SUSTENTO: ',
'EJECUTADO O LLAMADO POR: ',
'FECHA: 29/11/2016 ',
'ACTUALIZACION:',
'FECHA: 05/12/2016 ',
'SE QUITA LA CONDICION QUE NO EJECUTABA EL PROCESO SI YA SE HABIA EJECUTADO EN LA TABLA EJECUCIONES',
'VERSIÃN:  ',
'Solicita: Jaime GonzÃ¡lez',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_estadisticas_sac_altactes_anio
( fechaInicio date, fechaFin date )

RETURNING
	CHAR(5) AS codigo_respuesta,
	CHAR(80) AS mensaje_respuesta;

	DEFINE cCodRet CHAR(5);
	DEFINE cMensaje CHAR(80);
	
    DEFINE usuario CHAR(9);
	DEFINE iSqlErr INT;
    DEFINE iIsamErr INT;
    DEFINE cInfoErr CHAR;
    DEFINE Vsp CHAR(100);
    DEFINE Vid_sp INTEGER;
    DEFINE Vperiodo CHAR(25);
    
	LET cCodRet = "00000";
	LET cMensaje = 'PROCESO EXITOSO';
	
    LET usuario ='informix';    
    LET Vsp = 'sp_estadisticas_sac_altactes_anio';
    LET Vid_sp = '7';
    LET Vperiodo = fechaInicio || ' a ' || fechaFin;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

--	SET DEBUG FILE TO '/ifxsif01/Control-M/sp_estadisticas_sac_altactes_anio.out';
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

		DROP TABLE IF EXISTS TB_TEST_ANIO;
		
		CREATE TEMP TABLE TB_TEST_ANIO (empresa CHAR(3), fecha_insert DATE, tipo_cte CHAR(1)) WITH NO LOG; 
			insert into TB_TEST_ANIO (empresa, fecha_insert, tipo_cte)
				select {+INDEX (bdinteg:"informix".si_cliente.idx_fecha_insert)} empresa,fecha_insert,tipo_cliente 
				from bdinteg:"informix".si_cliente 
				where empresa='001' 
				and fecha_insert >= mdy(month(fechaInicio),day(fechaInicio),year(fechaInicio)) 
				and fecha_insert <= mdy(month(fechaFin),day(fechaFin),year(fechaFin));
		
		insert into bdisac:"informix".sac_estadisticas_altactes_anio (mes, anio, mesanio, dias_por_mes, titulares, prom_diario_titulares, no_titulares, prom_diario_no_titulares, todos, prom_diario_todos, user_insert, fecha_insert, sp, periodo)
			select 
					month(fecha_insert) as mes
					, year(fecha_insert) as anio
					, DECODE(MONTH(fecha_insert),1,'Enero',2,'Febrero',3,'Marzo',4,'Abril',5,'Mayo',6,'Junio',7,'Julio',8,'Agosto',9,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre') || ' ' || year(fecha_insert) as mesanio
					, count(distinct(day(fecha_insert))) as mesesPorAnio
					, sum(case tipo_cte when '1' then 1 else 0 end) as titulares
					, cast(sum(case tipo_cte when '1' then 1 else 0 end) / count(distinct(day(fecha_insert))) as decimal(18,2)) as PromMesTitulares
					, sum(case tipo_cte when '1' then 0 else 1 end) as notitulares
					, cast(sum(case tipo_cte when '1' then 0 else 1 end) / count(distinct(day(fecha_insert))) as decimal(18,2)) as PromMesNoTitulares
					, count(*) Todos
					, cast(count(*) / count(distinct(day(fecha_insert))) as decimal(18,2)) as PromMesTodos
					, usuario
					, current
					, trim(Vsp)
					, Vperiodo
			from TB_TEST_ANIO
			where empresa='001' 
			group by 1,2,3
			order by 2,1,3 asc;
			
			DROP TABLE IF EXISTS TB_TEST_ANIO;

			INSERT INTO "informix".tb_ejecucion_estadisticas_sac(fecha_hora_ejecucion, id_sp, resultado, periodo, usuario_insert, fecha_insert) 
                VALUES(current, Vid_sp, cCodRet, Vperiodo, usuario, current); -- Actualizado RALVAREZ 10/10/2022
			
			RETURN cCodRet, cMensaje;
	END;

END PROCEDURE
DOCUMENT
'AUTOR: Noe Medina Ramirez ',
'DESCRIPCIÃÂN: Genera la informaciÃÂ³n para los Reportes Periodicos de ALTA DE CLIENTES POR AÃÂO',
'SUSTENTO: ',
'EJECUTADO O LLAMADO POR: ',
'FECHA: 19/10/2016 ',
'ACTUALIZACION:',
'FECHA: 30/11/2016 ',
'SE QUITA EL TRUNCATE DE LA TABLA DE ESTADISTICAS',
'VERSIÃÂN:  ',
'Solicita: Jaime GonzÃÂ¡lez',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_estadisticas_sac_altactes_dia
( fechaInicio date, fechaFin date )

RETURNING
	CHAR(5) AS codigo_respuesta,
	CHAR(80) AS mensaje_respuesta;

	DEFINE cCodRet CHAR(5);
	DEFINE cMensaje CHAR(80);

    DEFINE usuario CHAR(9);
	DEFINE iSqlErr INT;
    DEFINE iIsamErr INT;
    DEFINE cInfoErr CHAR;
    DEFINE Vsp CHAR(100);
    DEFINE Vid_sp INTEGER;
    DEFINE Vperiodo CHAR(25);
    
	LET cCodRet = "00000";
	LET cMensaje = 'PROCESO EXITOSO';
	
    LET usuario ='informix';    
    LET Vsp = 'sp_estadisticas_sac_altactes_dia';
    LET Vid_sp = '11';
    LET Vperiodo = fechaInicio || ' a ' || fechaFin;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/ifxsif01/Control-M/sp_estadisticas_sac_altactes_dia.out';
	--TRACE ON;

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

		DROP TABLE IF EXISTS TB_SAC_ALTACTES_DIA;
		
		CREATE TEMP TABLE TB_SAC_ALTACTES_DIA (empresa CHAR(3), fecha_insert DATE, tipo_cte CHAR(1)) WITH NO LOG; 
		INSERT INTO TB_SAC_ALTACTES_DIA (empresa, fecha_insert, tipo_cte)
			select {+INDEX (bdinteg:"informix".si_cliente.idx_fecha_insert)} empresa,fecha_insert,tipo_cliente 
			from bdinteg:"informix".si_cliente 
			where empresa='001' 
			and fecha_insert >= mdy(month(fechaInicio),day(fechaInicio),year(fechaInicio)) 
			and fecha_insert <= mdy(month(fechaFin),day(fechaFin),year(fechaFin));
		
		insert into bdisac:"informix".sac_estadisticas_altactes_dia (dia, titulares, no_titulares, total, user_insert, fecha_insert, sp, periodo)
			select 
				fecha_insert as dia
				,sum(case tipo_cte when '1' then 1 else 0 end) as titulares
				,sum(case tipo_cte when '1' then 0 else 1 end) as NO_titulares
				, count(*) total
				, usuario
				, current
				, trim(Vsp)
				, Vperiodo
			from TB_SAC_ALTACTES_DIA
			where empresa='001' 
			group by 1
			order by 1 asc;
		
		DROP TABLE IF EXISTS TB_SAC_ALTACTES_DIA;

		INSERT INTO "informix".tb_ejecucion_estadisticas_sac(fecha_hora_ejecucion, id_sp, resultado, periodo, usuario_insert, fecha_insert) 
                VALUES(current, Vid_sp, cCodRet, Vperiodo, usuario, current); -- Actualizado RALVAREZ 10/10/2022
		
		RETURN cCodRet, cMensaje;
	END;

END PROCEDURE
DOCUMENT
'AUTOR: Noe Medina Ramirez ',
'DESCRIPCIÃÂN: Genera la informaciÃÂ³n para los Reportes Periodicos de ALTA DE CLIENTES POR DIA (FECHA)',
'SUSTENTO: ',
'EJECUTADO O LLAMADO POR: ',
'FECHA: 20/10/2016 ',
'ACTUALIZACION:',
'FECHA: 30/11/2016 ',
'SE QUITA EL TRUNCATE DE LA TABLA DE ESTADISTICAS',
'VERSIÃÂN:  ',
'Solicita: Jaime GonzÃÂ¡lez',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_estadisticas_sac_altactes_diasemana
( fechaInicio date, fechaFin date )

RETURNING
	CHAR(5) AS codigo_respuesta,
	CHAR(80) AS mensaje_respuesta;

	DEFINE cCodRet CHAR(5);
	DEFINE cMensaje CHAR(80);

    DEFINE usuario CHAR(9);
	DEFINE iSqlErr INT;
    DEFINE iIsamErr INT;
    DEFINE cInfoErr CHAR;
    DEFINE Vsp CHAR(100);
    DEFINE Vid_sp INTEGER;
    DEFINE Vperiodo CHAR(25);
    
	LET cCodRet = "00000";
	LET cMensaje = 'PROCESO EXITOSO';
	
    LET usuario ='informix';    
    LET Vsp = 'sp_estadisticas_sac_altactes_diasemana';
    LET Vid_sp = '10';
    LET Vperiodo = fechaInicio || ' a ' || fechaFin;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/ifxsif01/Control-M/sp_estadisticas_sac_altactes_diasemana.out';
	--TRACE ON;

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

		
		DROP TABLE IF EXISTS TB_SAC_ALTACTES_DIASEMANA;
		
		CREATE TEMP TABLE TB_SAC_ALTACTES_DIASEMANA (empresa CHAR(3), fecha_insert DATE, tipo_cte CHAR(1)) WITH NO LOG; 
		insert into TB_SAC_ALTACTES_DIASEMANA (empresa, fecha_insert, tipo_cte)
			select {+INDEX (bdinteg:"informix".si_cliente.idx_fecha_insert)} empresa,fecha_insert,tipo_cliente 
			from bdinteg:"informix".si_cliente 
			where empresa='001' 
			and fecha_insert >= mdy(month(fechaInicio),day(fechaInicio),year(fechaInicio)) 
			and fecha_insert <= mdy(month(fechaFin),day(fechaFin),year(fechaFin));
		
		insert into bdisac:"informix".sac_estadisticas_altactes_diasemana (num_dia, mes, anio, mesanio, nombre_dia, titulares, no_titulares, total, user_insert, fecha_insert, sp, periodo)
			select 
				WEEKDAY(fecha_insert) dia
				, month(fecha_insert) as mes
				, year(fecha_insert) as anio
				, DECODE(MONTH(fecha_insert),1,'Enero',2,'Febrero',3,'Marzo',4,'Abril',5,'Mayo',6,'Junio',7,'Julio',8,'Agosto',9,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre') || ' ' || year(fecha_insert) as mesanio 
				, DECODE(WEEKDAY(fecha_insert),0,'Domingo',1,'Lunes',2,'Martes',3,'Miercoles',4,'Jueves',5,'Viernes',6,'Sabado') nombreDia 
				, sum(case tipo_cte when '1' then 1 else 0 end) as titulares
				, sum(case tipo_cte when '1' then 0 else 1 end) as no_titulares
				, count(*) Todos
				, usuario
				, current
				, trim(Vsp)
				, Vperiodo
			from TB_SAC_ALTACTES_DIASEMANA
			where empresa='001'
			group by 3,2,5,4,1
			order by 3,2,5,4,1 asc;
																			
			DROP TABLE IF EXISTS TB_SAC_ALTACTES_DIASEMANA;

			INSERT INTO "informix".tb_ejecucion_estadisticas_sac(fecha_hora_ejecucion, id_sp, resultado, periodo, usuario_insert, fecha_insert) 
                VALUES(current, Vid_sp, cCodRet, Vperiodo, usuario, current); -- Actualizado RALVAREZ 10/10/2022
			
			RETURN cCodRet, cMensaje;
	END;

END PROCEDURE
DOCUMENT
'AUTOR: Noe Medina Ramirez ',
'DESCRIPCIÃÂN: Genera la informaciÃÂ³n para los Reportes Periodicos de ALTA DE CLIENTES POR DIA DE LA SEMANA',
'SUSTENTO: ',
'EJECUTADO O LLAMADO POR: ',
'FECHA: 20/10/2016 ',
'ACTUALIZACION:',
'FECHA: 30/11/2016 ',
'SE QUITA EL TRUNCATE DE LA TABLA DE ESTADISTICAS',
'ACTUALIZACION:',
'FECHA: 05/12/2016 ',
'SE CAMBIA EL FORMATO DE FECHAS A MDY',
'VERSIÃÂN:  ',
'Solicita: Jaime GonzÃÂ¡lez',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_estadisticas_sac_altactes_estado
( fechaInicio date, fechaFin date )

RETURNING
	CHAR(5) AS codigo_respuesta,
	CHAR(80) AS mensaje_respuesta;

	DEFINE cCodRet CHAR(5);
	DEFINE cMensaje CHAR(80);
	
    DEFINE usuario CHAR(9);
	DEFINE iSqlErr INT;
    DEFINE iIsamErr INT;
    DEFINE cInfoErr CHAR;
    DEFINE Vsp CHAR(100);
    DEFINE Vid_sp INTEGER;
    DEFINE Vperiodo CHAR(25);
	
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
	
    LET usuario ='informix';    
    LET Vsp = 'sp_estadisticas_sac_altactes_estado';
    LET Vid_sp = '9';

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

	--SET DEBUG FILE TO '/ifxsif01/Control-M/sp_estadisticas_sac_altactes_estado.out';
	--TRACE ON;

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
		
		DROP TABLE IF EXISTS TB_SAC_ALTACTES_ESTADO;
		
		CREATE TEMP TABLE TB_SAC_ALTACTES_ESTADO (estado CHAR(25),sucursal char(4), fecha_insert DATE, tipo_cte CHAR(1)) WITH NO LOG; 		

		FOREACH
			select {+INDEX(bdinteg:"informix".si_cliente.idx_fecha_insert)} 				  				
			C.fecha_insert, C.tipo_cliente, C.sucursal
			into dFecha_insert, cTipo_cliente, cSucursal
			from bdinteg:"informix".si_cliente C
			where C.fecha_insert >= mdy(month(fechaInicio),day(fechaInicio),year(fechaInicio)) 
			and C.fecha_insert <= mdy(month(fechaFin),day(fechaFin),year(fechaFin))
			
			execute procedure bdisac:"informix".sp_sac_consucursales(cSucursal) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,ccve_estado,cnomestado,ctel1,ctel2,ctipo;

			insert into TB_SAC_ALTACTES_ESTADO (estado,sucursal, fecha_insert, tipo_cte)
			values (cnomestado,cSucursal,dFecha_insert,cTipo_cliente);

		END FOREACH;
		
			insert into "informix".sac_estadisticas_altactes_estado (mes, anio, mesanio, estado, cant_sucursales, titulares, no_titulares, total, user_insert, fecha_insert, sp, periodo)
		select month(fecha_insert) as mes
			, year(fecha_insert) as anio
			, DECODE(MONTH(fecha_insert),1,'Enero',2,'Febrero',3,'Marzo',4,'Abril',5,'Mayo',6,'Junio',7,'Julio',8,'Agosto',9,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre') || ' ' || year(fecha_insert) as mesanio 
			, estado
			, count(distinct(sucursal)) as cant_suc
			, sum(case tipo_cte when '1' then 1 else 0 end) as ctes_titulares
			, sum(case tipo_cte when '1' then 0 else 1 end) as ctes_notitulares
			, COUNT(*) as ctes_todos
			, usuario
			, current
			, trim(Vsp)
			, Vperiodo
		from TB_SAC_ALTACTES_ESTADO
			group by 2,1,3,4
			order by 2,1,3,4 asc;
		
		DROP TABLE IF EXISTS TB_SAC_ALTACTES_ESTADO;

		INSERT INTO "informix".tb_ejecucion_estadisticas_sac(fecha_hora_ejecucion, id_sp, resultado, periodo, usuario_insert, fecha_insert) 
                VALUES(current, Vid_sp, cCodRet, Vperiodo, usuario, current); -- Actualizado RALVAREZ 10/10/2022
		RETURN cCodRet, cMensaje;
	END;

END PROCEDURE;