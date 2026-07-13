CREATE PROCEDURE "informix".sp_mueve_aclaraciones_historico()

RETURNING CHAR(5);

-- *********************************************************************
-- *                        DEFINICION DE VARIABLES                    *
-- *********************************************************************
DEFINE scod_ret         CHAR(5);
DEFINE vsqlerr          INTEGER;
DEFINE v_pky_aclaracion CHAR(20);
DEFINE icontador        INTEGER;
DEFINE v_folio_csuac    VARCHAR(11);
DEFINE v_sol_eglobal    INTEGER;
DEFINE v_res_eglobal    INTEGER;
DEFINE v_fecha_limit    DATE;
DEFINE vsql	        	char(3000);
Define cCadena 			CHAR(1000);
DEFINE respuesta_repetida_e_global	INTEGER;
DEFINE solicitud_faltante_e_global	INTEGER;
DEFINE cRuta CHAR(100);
DEFINE horaActual     datetime year to fraction;
DEFINE horafinal     datetime year to fraction;
DEFINE v_pky_movimiento CHAR(20);
DEFINE v_pky_movimiento2 CHAR(20);
DEFINE v_pky_bitacora CHAR(20);
DEFINE v_resul_mov INTEGER;
DEFINE v_temp_aclara INTEGER;
DEFINE v_temp_solic INTEGER;
DEFINE v_temp_respues INTEGER;
DEFINE v_temp_bitacora INTEGER;
DEFINE v_temp_mov INTEGER;
DEFINE c_pky_bitacora INTEGER;
DEFINE c_fky_padre INTEGER;
DEFINE c_pky_movimiento INTEGER;



--DEFINE v_year           INTEGER; --variable año
--DEFINE v_mes            INTEGER;
--DEFINE v_dia            INTEGER;
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret  = "00000";
LET vsqlerr = 0;
LET icontador=0;


LET v_resul_mov = NULL;
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
	   LET scod_ret=vsqlerr;
	   ROLLBACK WORK;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/RESPALDOSNEW/aclaraciones/mover.out";
--TRACE ON;
SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;


--Verificar tablas fisicas
		SELECT tabid
		INTO v_temp_aclara
		FROM systables WHERE tabname ='temp_aclara';
		
		IF v_temp_aclara IS NOT NULL THEN
			DROP TABLE "informix".temp_aclara;
		END IF;
--Verificar tabla fisica
			SELECT tabid
			INTO v_temp_solic
			FROM systables WHERE tabname ='temp_solic';
		IF v_temp_solic IS NOT NULL THEN
			DROP TABLE "informix".temp_solic;
		END IF;
--Verificar tabla fisica
			SELECT tabid 
			INTO v_temp_respues
			FROM systables WHERE tabname ='temp_respues';
		IF 	v_temp_respues is not null	THEN
			DROP TABLE "informix".temp_respues;
		END IF;
--Verificar tabla fisica
			SELECT tabid
			INTO v_temp_mov
			FROM systables WHERE tabname ='temp_mov';
		IF 	v_temp_mov IS NOT NULL	THEN
			DROP TABLE "informix".temp_mov;
		END IF;
--Verificar tabla fisica
--		IF EXISTS( SELECT * FROM systables WHERE tabname ='temp_mov_2') THEN
--			DROP TABLE "informix".temp_mov_2;
--		END IF;
--Verificar tabla fisica

			SELECT tabid
			INTO v_temp_bitacora
			FROM systables WHERE tabname ='temp_bitacora';
		IF v_temp_bitacora IS NOT NULL THEN
			DROP TABLE "informix".temp_bitacora;
		END IF;
BEGIN WORK;
----------se crean las tablas fisicas
	CREATE /*TEMP*/ table temp_aclara(
		pky_aclaracion     integer     NOT NULL,
		folio_csuac  VARCHAR(11));
	CREATE /*TEMP*/ table temp_solic (
		pky_solicitud_e_global integer);
	CREATE /*TEMP*/ table temp_respues (
		pky_respuesta_e_global integer);
	CREATE INDEX index_temp_1
		ON temp_aclara (pky_aclaracion);
	CREATE INDEX index_temp_2
		ON temp_aclara (folio_csuac);
	CREATE /*TEMP*/ table temp_mov(
		pky_movimiento    integer,
		fky_padre integer);
	--CREATE /*TEMP*/ table temp_mov_2(
	--	pky_movimiento    integer);
	CREATE /*TEMP*/ table temp_bitacora(
		pky_bitacora   integer);

----------------------------------------------------------
update statistics medium for table "informix".acl_aclaracion;
--update statistics high for table "informix".acl_aclaracion_his;
update statistics medium for table "informix".acl_entrada_bitacora;
--update statistics high for table "informix".acl_entrada_bitacora;
update statistics medium for table "informix".acl_movimiento;
--update statistics high for table "informix".acl_movimiento_his;
update statistics medium for table "informix".acl_documento;
--update statistics high for table "informix".acl_documento_his;
update statistics medium for table "informix".acl_recuperacion_saldos;
--update statistics high for table "informix".acl_recuperacion_saldos_his;
update statistics medium for table "informix".acl_solicitud_e_global;
--update statistics high for table "informix".acl_solicitud_e_global_his;
update statistics medium for table "informix".acl_respuesta_e_global;
--update statistics high for table "informix".acl_respuesta_e_global_his;
update statistics medium for table "informix".acl_control_aclaracion_tel;
--update statistics high for table "informix".acl_control_aclaracion_tel_his;
update statistics medium for table "informix".acl_regulatorio27;
--update statistics high for table "informix".acl_regulatorio27_his;
update statistics medium for table "informix".acl_sistema_bitacora;
--update statistics high for table "informix".acl_sistema_bitacora_his;
--
--
---- ****************************************************************************
---- *                        PROGRAMA PRINCIPAL                                *
---- ****************************************************************************
--	-- *************************************************************
--	-- * Mover información a historico del sistema de aclaraciones *
--	-- *************************************************************
--------obtener fecha de validación.
--next_day
--select (last_day(add_months((date('20200101')), -13)))+1 from bdinteg:"informix".si_fechas where empresa=001
--SELECT fecha_hoy
--   INTO v_fecha_limit
--FROM bdinteg:si_fechas;
--LET fechaPasada = ADD_MONTHS(fechaActual,-12);
--LET fechaInicio = last_day(ADD_MONTHS(fechaActual,-13)) + 1;
	
	
	select (last_day(add_months((date(fecha_hoy)), -13)))+1
		into v_fecha_limit
	from bdinteg:"informix".si_fechas where empresa='001';
  --if v_ano < (select year(fecha_hoy) from bdinteg:si_fechas where empresa='001') then  
--FOREACH
-----------***se obtiene el pky_de aclaraciones
        INSERT INTO temp_aclara
			SELECT pky_aclaracion,folio_csuac
				FROM "informix".acl_aclaracion where fechacaptura <= v_fecha_limit; 
-----------** se obtiene el pky_solicitud e-global
		INSERT INTO temp_solic
			select fky_solicitud_e_global
			from acl_movimiento 
				where fky_aclaracion in(select pky_aclaracion from temp_aclara where folio_csuac is not null) AND fky_solicitud_e_global is not null;
-----------** se obtiene el pky_respuesta e-global
		INSERT INTO temp_respues
			select fky_respuesta_e_global
			from acl_solicitud_e_global
				where pky_solicitud_e_global in(select pky_solicitud_e_global from temp_solic where fky_respuesta_e_global is not null);
   ------*Se las respuestas E-global Duplicadas....
		/*INSERT INTO temp_solic
		select pky_solicitud_e_global
		from acl_solicitud_e_global where fky_respuesta_e_global in (Select fky_respuesta_e_global from acl_solicitud_e_global where fky_respuesta_e_global in(select pky_respuesta_e_global from temp_respues)	group by fky_respuesta_e_global HAVING COUNT(fky_respuesta_e_global)  >  1);
		*/
		FOREACH
			Select fky_respuesta_e_global 
				Into respuesta_repetida_e_global
			from acl_solicitud_e_global 
				Inner Join temp_respues on fky_respuesta_e_global = pky_respuesta_e_global
			group by fky_respuesta_e_global HAVING COUNT(fky_respuesta_e_global)  >  1
			
			FOREACH
				SELECT seg.pky_solicitud_e_global 
					Into solicitud_faltante_e_global
				FROM acl_solicitud_e_global seg
					LEFT JOIN temp_solic tseg ON seg.pky_solicitud_e_global = tseg.pky_solicitud_e_global
				WHERE seg.fky_respuesta_e_global = respuesta_repetida_e_global 
					AND tseg.pky_solicitud_e_global is NULL
				
				INSERT INTO temp_solic (pky_solicitud_e_global) VALUES (solicitud_faltante_e_global);
				
				INSERT INTO temp_aclara
					SELECT fky_aclaracion, folio_csuac FROM acl_movimiento WHERE fky_solicitud_e_global = solicitud_faltante_e_global;
			END FOREACH;
		END FOREACH;

COMMIT WORK;
--BEGIN WORK;
	BEGIN WORK;
 /*1*/--********************inserción de historico en aclaraciones
 
        let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_aclaracion_his.unl '||
						'select * from "informix".acl_aclaracion WHERE pky_aclaracion in (select pky_aclaracion from temp_aclara);">/RESPALDOSNEW/aclaraciones/acl_aclaracion_his.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_aclaracion_his.sql';
		system vsql;
--------------------------------------Se carga la informacion en la tabla histoca
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_aclaracion_his.unl DELIMITER '|| "'" || '|' || "'" || ' 36;' || '">/RESPALDOSNEW/aclaraciones/aclaracion.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_aclaracion_his;' || '">> /RESPALDOSNEW/aclaraciones/aclaracion.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/aclaracion.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/aclaracion.sql -l /RESPALDOSNEW/aclaraciones/aclaracion.log -n 1000 -k';
		SYSTEM cCadena;
		------------------------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_aclaracion_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_aclaracion_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/aclaracion.sql';
		system vsql; 

 /*2*/-----------------------------------------------------------------------------------------------------------------
		--		 --********************inserción de historico en entrada bitacora
  		let vsql = '';
  		system vsql; 
  		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_entrada_bitacora_his.unl '||
						'select * from "informix".acl_entrada_bitacora  WHERE  fky_aclaracion in(select pky_aclaracion from temp_aclara);">/RESPALDOSNEW/aclaraciones/acl_entrada_bitacora_his.sql';
  		system vsql;
  		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_entrada_bitacora_his.sql';
  		system vsql;
		-----------------------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_entrada_bitacora_his.unl DELIMITER '|| "'" || '|' || "'" || ' 11;' || '">/RESPALDOSNEW/aclaraciones/bitacora.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_entrada_bitacora_his;' || '">> /RESPALDOSNEW/aclaraciones/bitacora.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/bitacora.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/bitacora.sql -l /RESPALDOSNEW/aclaraciones/bitacora.log -n 1000 -k';
		SYSTEM cCadena;
		--------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_entrada_bitacora_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_entrada_bitacora_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/bitacora.sql';
		system vsql; 
	COMMIT WORK;
 /*3*/-----------------------------------------------------------------------------------------------------------------
	--********************inserción de historico en documentos
	FOREACH WITH HOLD
		
		select pky_aclaracion, folio_csuac
			into v_pky_aclaracion,v_folio_csuac
		from temp_aclara
		
		BEGIN WORK;	
			INSERT INTO "informix".acl_documento_his 
			select * from "informix".acl_documento WHERE fky_aclaracion =v_pky_aclaracion and folio_csuac = v_folio_csuac;
		COMMIT WORK;
	
	END FOREACH;
----------------------------------------------------------------------------------------------------------------------		
/*4*/-------------------********************inserción de historico en recuperacion de saldos
	BEGIN WORK;
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_recuperacion_saldos_his.unl '||
						'select * from "informix".acl_recuperacion_saldos WHERE fky_aclaracion in (select pky_aclaracion from temp_aclara);">/RESPALDOSNEW/aclaraciones/acl_recuperacion_saldos_his.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_recuperacion_saldos_his.sql';
		system vsql;
		--------------------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_recuperacion_saldos_his.unl DELIMITER '|| "'" || '|' || "'" || ' 27;' || '">/RESPALDOSNEW/aclaraciones/recuperacion.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_recuperacion_saldos_his;' || '">> /RESPALDOSNEW/aclaraciones/recuperacion.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/recuperacion.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/recuperacion.sql -l /RESPALDOSNEW/aclaraciones/recuperacion.log -n 1000 -k';
		SYSTEM cCadena;
		--------------------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_recuperacion_saldos_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_recuperacion_saldos_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/recuperacion.sql';
		system vsql; 
 /*5*/--------------------------------------------------------------------------------------------------------------------		
--********************inserción de historico de respuesta E-GALOBAL
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_respuesta_e_global_his.unl '||
						'select * from "informix".acl_respuesta_e_global WHERE pky_respuesta_e_global in (select pky_respuesta_e_global from temp_respues);">/RESPALDOSNEW/aclaraciones/acl_respuesta_e_global_his.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_respuesta_e_global_his.sql';
		system vsql;
		----------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_respuesta_e_global_his.unl DELIMITER '|| "'" || '|' || "'" || ' 3;' || '">/RESPALDOSNEW/aclaraciones/respuesta.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_respuesta_e_global_his;' || '">> /RESPALDOSNEW/aclaraciones/respuesta.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/respuesta.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/respuesta.sql -l /RESPALDOSNEW/aclaraciones/respuesta.log -n 1000 -k';
		SYSTEM cCadena;
		--------------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_respuesta_e_global_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_respuesta_e_global_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/respuesta.sql';
		system vsql; 
 /*6*/--------------------------------------------------------------------------------------------------------------------------		
--********************inserción de historico de solicitud E-GALOBAL
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_solicitud_e_global_his.unl '||
						'select * from "informix".acl_solicitud_e_global WHERE pky_solicitud_e_global in(select pky_solicitud_e_global from temp_solic);">/RESPALDOSNEW/aclaraciones/acl_solicitud_e_global_his.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_solicitud_e_global_his.sql';
		system vsql;
		Let vsql = '';
		--------------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_solicitud_e_global_his.unl DELIMITER '|| "'" || '|' || "'" || ' 4;' || '">/RESPALDOSNEW/aclaraciones/solicitud.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_solicitud_e_global_his;' || '">> /RESPALDOSNEW/aclaraciones/solicitud.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/solicitud.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/solicitud.sql -l /RESPALDOSNEW/aclaraciones/solicitud.log -n 1000 -k';
		SYSTEM cCadena;
		---------------------------------------------------------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_solicitud_e_global_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_solicitud_e_global_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/solicitud.sql';
		system vsql; 
 /*7*/--------------------------------------------------------------------------------------------------------------------------------
--********************inserción de historico en movimiento
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_movimiento_his.unl '||
						'select * from "informix".acl_movimiento WHERE (fky_aclaracion in(select pky_aclaracion from temp_aclara) or folio_csuac in(select folio_csuac from temp_aclara where folio_csuac is not null)) and fky_padre is null order by pky_movimiento asc;">/RESPALDOSNEW/aclaraciones/acl_movimiento_his.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_movimiento_his.sql';
		system vsql;
		--------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_movimiento_his.unl DELIMITER '|| "'" || '|' || "'" || ' 34;' || '">/RESPALDOSNEW/aclaraciones/movimiento.sql';
		SYSTEM cCadena;
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_movimiento_his;' || '">> /RESPALDOSNEW/aclaraciones/movimiento.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/movimiento.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/movimiento.sql -l /RESPALDOSNEW/aclaraciones/movimiento.log -n 1000 -k';
		SYSTEM cCadena;
		--------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_movimiento_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_movimiento_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/movimiento.sql';
		system vsql; 
 /*8*/--------------------------------------------------------------------------------------------------------------------
--********************inserción de historico en movimiento pky_padre no es nulo
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_movimiento_his1.unl '||
						'select * from "informix".acl_movimiento WHERE (fky_aclaracion in(select pky_aclaracion from temp_aclara) or folio_csuac in(select folio_csuac from temp_aclara where folio_csuac is not null)) and fky_padre is not null order by fky_padre asc;">/RESPALDOSNEW/aclaraciones/acl_movimiento_his1.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_movimiento_his1.sql';
		system vsql;
		-----------------------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_movimiento_his1.unl DELIMITER '|| "'" || '|' || "'" || ' 34;' || '">/RESPALDOSNEW/aclaraciones/movimiento1.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_movimiento_his;' || '">> /RESPALDOSNEW/aclaraciones/movimiento1.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/movimiento1.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/movimiento1.sql -l /RESPALDOSNEW/aclaraciones/movimiento1.log -n 1000 -k';
		SYSTEM cCadena;
		-----------------------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_movimiento_his1.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_movimiento_his1.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/movimiento1.sql';
		system vsql; 
 /*9*/-----------------------------------------------------------------------------------------------------------------------------		
--**** inserción de la informacion que no cuenta con referencia a acl_Aclaracion
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_movimiento_his2.unl '||
						'select * from "informix".acl_movimiento WHERE fky_aclaracion is null and folio_csuac is null and fechahora <= (select (last_day(add_months((date(fecha_hoy)), -13)))+1 from bdinteg:"informix".si_fechas where empresa=001)  order by pky_movimiento asc;">/RESPALDOSNEW/aclaraciones/acl_movimiento_his2.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_movimiento_his2.sql';
		system vsql;
		--------------------------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_movimiento_his2.unl DELIMITER '|| "'" || '|' || "'" || ' 34;' || '">/RESPALDOSNEW/aclaraciones/movimiento2.sql';
		SYSTEM cCadena;
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_movimiento_his;' || '">> /RESPALDOSNEW/aclaraciones/movimiento2.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/movimiento2.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/movimiento2.sql -l /RESPALDOSNEW/aclaraciones/movimiento2.log -n 1000 -k';
		SYSTEM cCadena;
		------------------------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_movimiento_his2.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_movimiento_his2.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/movimiento2.sql';
		system vsql; 
 /*10*/-----------------------------------------------------------------------------------------------------------------------------------
--********************inserción de historico de control de aclaraciones via telefonica
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_control_aclaracion_tel_his.unl '||
						'select * from "informix".acl_control_aclaracion_tel WHERE fky_aclaracion in(select pky_aclaracion from temp_aclara);">/RESPALDOSNEW/aclaraciones/acl_control_aclaracion_tel_his.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_control_aclaracion_tel_his.sql';
		system vsql;
		-------------------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_control_aclaracion_tel_his.unl DELIMITER '|| "'" || '|' || "'" || ' 9;' || '">/RESPALDOSNEW/aclaraciones/control.sql';
		SYSTEM cCadena;
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_control_aclaracion_tel_his;' || '">> /RESPALDOSNEW/aclaraciones/control.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/control.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/control.sql -l /RESPALDOSNEW/aclaraciones/control.log -n 1000 -k';
		SYSTEM cCadena;
		----------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_control_aclaracion_tel_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_control_aclaracion_tel_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/control.sql';
		system vsql; 
 /*11*/-----------------------------------------------------------------------------------------------------------------------------------------
---=========*******Inserción de informacion de historicos de cancelación de cuentas por recuperacion de saldos
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.unl '||
						'select * from "informix".acl_bitacora_control_cancelacion_cuenta WHERE fky_aclaracion in (select pky_aclaracion from temp_aclara);">/RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.sql';
		system vsql;
		------------------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.unl DELIMITER '|| "'" || '|' || "'" || ' 7;' || '">/RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.sql';
		SYSTEM cCadena;
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_bitacora_control_cancelacion_cuenta_his;' || '">> /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.sql -l /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.log -n 1000 -k';
		SYSTEM cCadena;
		--------------------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.sql';
-------------------------------------------------------------------------------------------------------------------------

 /*12*/---********************inserción de historico de regulatorio 27
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_regulatorio27_his.unl '||
						'select * from "informix".acl_regulatorio27 WHERE folio_csuac in (select folio_csuac from temp_aclara);">/RESPALDOSNEW/aclaraciones/acl_regulatorio27_his.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_regulatorio27_his.sql';
		system vsql;
		------------------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_regulatorio27_his.unl DELIMITER '|| "'" || '|' || "'" || ' 25;' || '">/RESPALDOSNEW/aclaraciones/regulatorio.sql';
		SYSTEM cCadena;
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_regulatorio27_his;' || '">> /RESPALDOSNEW/aclaraciones/regulatorio.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/regulatorio.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/regulatorio.sql -l /RESPALDOSNEW/aclaraciones/regulatorio.log -n 1000 -k';
		SYSTEM cCadena;
		--------------------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_regulatorio27_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_regulatorio27_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/regulatorio.sql';
		system vsql; 
----------------------------------------------------------------------------------------------------------------------------------
 /*13*/--********************inserción de historico bitacora del sistema
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_sistema_bitacora_his.unl '||
						'select * from "informix".acl_sistema_bitacora WHERE fecha <= (select (last_day(add_months((date(fecha_hoy)), -13)))+1 from bdinteg:"informix".si_fechas where empresa=001);">/RESPALDOSNEW/aclaraciones/acl_sistema_bitacora_his.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_sistema_bitacora_his.sql';
		system vsql;
		---------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_sistema_bitacora_his.unl DELIMITER '|| "'" || '|' || "'" || ' 11;' || '">/RESPALDOSNEW/aclaraciones/sistema.sql';
		SYSTEM cCadena;
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_sistema_bitacora_his;' || '">> /RESPALDOSNEW/aclaraciones/sistema.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/sistema.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/sistema.sql -l /RESPALDOSNEW/aclaraciones/sistema.log -n 1000 -k';
		SYSTEM cCadena;
		--------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_sistema_bitacora_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_sistema_bitacora_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/sistema.sql';
		system vsql; 
		
/*14*/--===========================Se genera archivo para historico de la tabla acl_aclaracion_estatus_proceso_analisis ====================================================
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_aclaracion_estatus_proceso_analisis_his.unl '||
						'select * from "informix".acl_aclaracion_estatus_proceso_analisis WHERE fky_aclaracion in (select pky_aclaracion from temp_aclara);">/RESPALDOSNEW/aclaraciones/acl_aclaracion_estatus_proceso_analisis_his.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_aclaracion_estatus_proceso_analisis_his.sql';
		system vsql;
--------------------------------------Se carga la informacion en la tabla histoca
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_aclaracion_estatus_proceso_analisis_his.unl DELIMITER '|| "'" || '|' || "'" || ' 2;' || '">/RESPALDOSNEW/aclaraciones/estatus_proceso_analisis.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_aclaracion_estatus_proceso_analisis_his;' || '">> /RESPALDOSNEW/aclaraciones/estatus_proceso_analisis.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/estatus_proceso_analisis.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/estatus_proceso_analisis.sql -l /RESPALDOSNEW/aclaraciones/aclaracion.log -n 1000 -k';
		SYSTEM cCadena;
		------------------------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_aclaracion_estatus_proceso_analisis_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_aclaracion_estatus_proceso_analisis_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/estatus_proceso_analisis.sql';
		system vsql; 
--===================================================================================================================================================
	COMMIT WORK;		
	
--		---*obtencion de los pky_movimientos a mover.
	BEGIN WORK;
		FOREACH WITH HOLD	
		
			--INSERT INTO temp_bitacora		
			select pky_bitacora 
			INTO c_pky_bitacora
			from "informix".acl_sistema_bitacora where fecha <= (select (last_day(add_months((date(fecha_hoy)), -13)))+1 from bdinteg:"informix".si_fechas where empresa=001)
			
			INSERT INTO "informix".temp_bitacora (pky_bitacora) values (c_pky_bitacora);
			
			LET iContador = iContador + 1;
			IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
			END IF; 
	
		END FOREACH;
	COMMIT WORK;
	LET iContador = 0;
--------------
	BEGIN WORK;
		FOREACH WITH HOLD
			--INSERT INTO temp_mov
			SELECT pky_movimiento, fky_padre
			into c_pky_movimiento, c_fky_padre
			FROM "informix".acl_movimiento_his where (fky_aclaracion in(select pky_aclaracion from temp_aclara) or folio_csuac in(select folio_csuac from temp_aclara where folio_csuac is not null)) and fky_padre is not null order by fky_padre asc 
			
			INSERT INTO "informix".temp_mov (pky_movimiento,fky_padre) VALUES(c_pky_movimiento,c_fky_padre);
			LET iContador = iContador + 1;
			IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
			END IF; 
		END FOREACH;	
	COMMIT WORK;
	LET iContador = 0;
	------------
	BEGIN WORK;
		FOREACH WITH HOLD
			--fky_padre is not null;
			--INSERT INTO temp_mov
			SELECT pky_movimiento,fky_padre
			into c_pky_movimiento, c_fky_padre
			FROM "informix".acl_movimiento_his where (fky_aclaracion in(select pky_aclaracion from temp_aclara) or folio_csuac in(select folio_csuac from temp_aclara where folio_csuac is not null)) and fky_padre is null order by pky_movimiento asc
			--fky_padre is null;
			INSERT INTO "informix".temp_mov (pky_movimiento,fky_padre) VALUES(c_pky_movimiento,c_fky_padre);
			LET iContador = iContador + 1;
			IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
			END IF; 
		END FOREACH;
	COMMIT WORK;
	LET iContador = 0;
	----------------------
	BEGIN WORK;
		FOREACH WITH HOLD
			--INSERT INTO temp_mov
			SELECT pky_movimiento, fky_padre
			into c_pky_movimiento, c_fky_padre
			FROM "informix".acl_movimiento_his where fky_aclaracion is null and folio_csuac is null and fechahora <= (select (last_day(add_months((date(fecha_hoy)), -13)))+1 from bdinteg:"informix".si_fechas where empresa=001)  order by pky_movimiento asc
			
			INSERT INTO "informix".temp_mov (pky_movimiento,fky_padre) VALUES(c_pky_movimiento,c_fky_padre);
			LET iContador = iContador + 1;
			IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
			END IF; 
	
		END FOREACH;
	COMMIT WORK;
	
	BEGIN WORK;
		FOREACH WITH HOLD
		-----Movimiento de aclaraciones que no cuentan con folio csuac
			--INSERT INTO temp_mov
			SELECT pky_movimiento, fky_padre
			into c_pky_movimiento, c_fky_padre
			FROM "informix".acl_movimiento_his where fky_aclaracion in(select pky_aclaracion from temp_aclara) and folio_csuac is null  order by pky_movimiento asc -----fky_aclaracion is not null and folio_csuac is null and fechahora <= (select last_day(add_months(((today) - 0 units year),-(month(today)))) from bdinteg:"informix".si_fechas where empresa=001)  order by pky_movimiento asc
			
			INSERT INTO "informix".temp_mov (pky_movimiento,fky_padre) VALUES(c_pky_movimiento,c_fky_padre);
			LET iContador = iContador + 1;
			IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
			END IF; 
	
		END FOREACH;
	COMMIT WORK;

FOREACH WITH HOLD
			
		select pky_aclaracion, folio_csuac
			into v_pky_aclaracion,v_folio_csuac
		from temp_aclara
		
		BEGIN WORK;	
        		 --********************Eliminacion de historico en entrada bitacora
			delete from "informix".acl_entrada_bitacora WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico en documentos
			delete from "informix".acl_documento WHERE  fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico en documentos
			delete from "informix".acl_recuperacion_saldos WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico de solicitud E-GALOBAL
			--********************Eliminacion de historico de control de aclaraciones via telefonica
			delete from "informix".acl_control_aclaracion_tel WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico de regulatorio 27
			delete from "informix".acl_regulatorio27 WHERE folio_csuac = v_folio_csuac;
			--********************Eliminacion de historico los intentos de cancelación
			delete from "informix".acl_bitacora_control_cancelacion_cuenta WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminación de los registros que se fueron a Historico----------------
			delete from "informix".acl_aclaracion_estatus_proceso_analisis WHERE fky_aclaracion = v_pky_aclaracion;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
		select pky_movimiento
			into v_pky_movimiento
		from temp_mov where fky_padre is not null --order by pky_movimiento desc
		
		BEGIN WORK;	
			LET v_resul_mov = v_pky_movimiento;
			--********************Eliminacion de historico en movimiento
			UPDATE "informix".acl_movimiento SET fky_padre = NULL WHERE pky_movimiento = v_pky_movimiento;
			LET v_resul_mov = NULL;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_movimiento
			into v_pky_movimiento
			from temp_mov order by fky_padre desc
		BEGIN WORK;	
			LET v_resul_mov = v_pky_movimiento;
			--********************Eliminacion de historico en movimiento
			delete from "informix".acl_movimiento WHERE pky_movimiento = v_pky_movimiento;
			LET v_resul_mov = NULL;
		COMMIT WORK;
END FOREACH;


FOREACH WITH HOLD		
			select pky_solicitud_e_global
			into v_sol_eglobal
			from temp_solic
		BEGIN WORK;	
			--********************Eliminacion de historico de Solicitud E-GALOBAL
			delete from "informix".acl_solicitud_e_global WHERE pky_solicitud_e_global = v_sol_eglobal;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD		
			select pky_respuesta_e_global
			into v_res_eglobal
			from temp_respues
		BEGIN WORK;	
    	--********************Eliminacion de historico de respuesta E-GALOBAL
			delete from "informix".acl_respuesta_e_global WHERE pky_respuesta_e_global = v_res_eglobal;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_aclaracion
			into v_pky_aclaracion
			from temp_aclara
		BEGIN WORK;	
		---********* Se elimina la informacion principal de aclaraciones********
			delete from "informix".acl_aclaracion WHERE  pky_aclaracion = v_pky_aclaracion;
		COMMIT WORK;
END FOREACH;
			
FOREACH WITH HOLD
			select pky_bitacora
			into v_pky_bitacora
			from temp_bitacora
		BEGIN WORK;		
			--------------------Elimina historico del bitacora del sistema----------------------
			delete from "informix".acl_sistema_bitacora WHERE pky_bitacora = v_pky_bitacora;
		COMMIT WORK;
END FOREACH;

	--------------****se eliminan las tablas temporales .::::::::::::
DROP TABLE temp_aclara;
DROP TABLE temp_solic;
DROP TABLE temp_respues;
DROP TABLE temp_mov;
--DROP TABLE temp_mov_2;
DROP TABLE temp_bitacora;
--COMMIT WORK;
RETURN scod_ret;
END
END PROCEDURE
DOCUMENT
'Sp sp_mueve_aclaraciones_historico',
'Se desarrolla para realizar la migración de información',
'Sistema: Aclaraciones',
'AUTOR : REY DAVID ZAVALA GARCIA',
'Area: Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte IV',
'Coordinador: Norberto Corona Berruecos',
'FECHA Modificacion: Diciembre/2019',
'VERSION: 4.0.0',
'BD    :  bdiaclaracion';

CREATE PROCEDURE "informix".sp_obten_estatus_canales_sms(
								pEstatusAcl				INTEGER,
								pEstatusCorpGral		INTEGER,
								pEstatusCorpAnalisis	INTEGER)

	RETURNING
		CHAR(5)							AS cod_ret,
		CHAR(50)						AS desc_estatus_canales,
		CHAR(50)						AS desc_estatus_sms,
		SMALLINT 						AS concatena_dictamen,
		INTEGER 						AS id_etapa_canales,
        CHAR(20)						AS desc_etapa_canales;

	--Variables--
	DEFINE sql_err 							INTEGER;
	DEFINE v_cod_ret 						CHAR(5);
	
	DEFINE v_id_estatus_aclaracion			INTEGER;
	DEFINE v_id_estatus_corp_analisis		INTEGER;
	DEFINE v_id_estatus_corp_general		INTEGER;
	DEFINE v_concatena_dictamen				SMALLINT;
	DEFINE v_estatus_canales				CHAR(50);
	DEFINE v_estatus_sms				CHAR(50);
	DEFINE v_id_etapa_canales				INTEGER;
	DEFINE v_desc_etapa_canales				CHAR(20);
	
	
	DEFINE contador			INTEGER;
	LET contador			= 0;
	
	LET v_cod_ret 						= '00000';
	LET sql_err 						= NULL;
	
	LET v_id_estatus_aclaracion			= NULL;
	LET v_id_estatus_corp_analisis		= NULL;
	LET v_id_estatus_corp_general		= NULL;
	LET v_concatena_dictamen			= NULL;
	LET v_estatus_canales					= NULL;
	LET v_estatus_sms					= NULL;
	LET v_id_etapa_canales					= NULL;
	LET v_desc_etapa_canales				= NULL;
	
	--SET DEBUG FILE TO "/informix/Paty/RQM665/estatus_canales_sms.out";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				
				LET v_cod_ret = sql_err;
				RETURN v_cod_ret, v_estatus_canales, v_estatus_sms, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales;
				
		    END IF;
		END EXCEPTION;
		
		IF (pEstatusAcl IS NULL) THEN
			RETURN '00001', v_estatus_canales, v_estatus_sms, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales; --El estatus de la AclaraciÃ³n no puede ser Nulo
		END IF;
		
		--Se realiza la consulta por los parÃ¡metros de invocaciÃ³n del SP
		SELECT ea.pky_estatus_aclaracion, eca.pky_estatus_corporativo, ecg.pky_estatus_corporativo, ecan.descripcion, ecan.concatena_dictamen,
				ecan.id_etapa_canales, ecan.descripcion_etapa_canales, ecan.descripcion_sms
			INTO v_id_estatus_aclaracion, v_id_estatus_corp_analisis, v_id_estatus_corp_general, v_estatus_canales, v_concatena_dictamen,
				v_id_etapa_canales, v_desc_etapa_canales, v_estatus_sms
		FROM acl_estatus_canales ecan
			INNER JOIN acl_estatus_aclaracion ea ON ea.nombre = ecan.nombre_estatus_aclaracion 
			LEFT OUTER JOIN acl_estatus_corporativo ecg ON ecg.fky_tipo_estatus = 1 AND ecg.nombre = ecan.nombre_estatus_corp_general 
			LEFT OUTER JOIN acl_estatus_corporativo eca ON eca.fky_tipo_estatus = 2 AND eca.nombre = ecan.nombre_estatus_corp_analisis 
		WHERE pky_estatus_aclaracion = pEstatusAcl
			AND ecg.pky_estatus_corporativo = pEstatusCorpGral
			AND eca.pky_estatus_corporativo = pEstatusCorpAnalisis;
		
		--En caso que la consulta no devuelva resultados se valida si se tiene algÃºn comodÃ­n con un estatus de anÃ¡lisis
		IF v_estatus_canales IS NULL THEN
			SELECT ea.pky_estatus_aclaracion, eca.pky_estatus_corporativo, ecg.pky_estatus_corporativo, ecan.descripcion, ecan.concatena_dictamen,
					ecan.id_etapa_canales, ecan.descripcion_etapa_canales, ecan.descripcion_sms
				INTO v_id_estatus_aclaracion, v_id_estatus_corp_analisis, v_id_estatus_corp_general, v_estatus_canales, v_concatena_dictamen,
					v_id_etapa_canales, v_desc_etapa_canales, v_estatus_sms
			FROM acl_estatus_canales ecan
				INNER JOIN acl_estatus_aclaracion ea ON ea.nombre = ecan.nombre_estatus_aclaracion 
				LEFT OUTER JOIN acl_estatus_corporativo ecg ON ecg.fky_tipo_estatus = 1 AND ecg.nombre = ecan.nombre_estatus_corp_general 
				LEFT OUTER JOIN acl_estatus_corporativo eca ON eca.fky_tipo_estatus = 2 AND eca.nombre = ecan.nombre_estatus_corp_analisis 
			WHERE pky_estatus_aclaracion = pEstatusAcl
				AND ecg.pky_estatus_corporativo IS NULL 
				AND eca.pky_estatus_corporativo = pEstatusCorpAnalisis;
		END IF;
		
		--En caso que la consulta no devuelva resultados se valida si se tiene algÃºn comodÃ­n con un estatus de corporativo
		IF v_estatus_canales IS NULL THEN
			SELECT ea.pky_estatus_aclaracion, eca.pky_estatus_corporativo, ecg.pky_estatus_corporativo, ecan.descripcion, ecan.concatena_dictamen,
					ecan.id_etapa_canales, ecan.descripcion_etapa_canales, ecan.descripcion_sms
				INTO v_id_estatus_aclaracion, v_id_estatus_corp_analisis, v_id_estatus_corp_general, v_estatus_canales, v_concatena_dictamen,
					v_id_etapa_canales, v_desc_etapa_canales, v_estatus_sms
			FROM acl_estatus_canales ecan
				INNER JOIN acl_estatus_aclaracion ea ON ea.nombre = ecan.nombre_estatus_aclaracion 
				LEFT OUTER JOIN acl_estatus_corporativo ecg ON ecg.fky_tipo_estatus = 1 AND ecg.nombre = ecan.nombre_estatus_corp_general 
				LEFT OUTER JOIN acl_estatus_corporativo eca ON eca.fky_tipo_estatus = 2 AND eca.nombre = ecan.nombre_estatus_corp_analisis 
			WHERE pky_estatus_aclaracion = pEstatusAcl
				AND ecg.pky_estatus_corporativo = pEstatusCorpGral
				AND eca.pky_estatus_corporativo IS NULL;
		END IF;
		
		--En caso que la consulta no devuelva resultados se valida si existe el registro para el estatus de la aclaraciÃ³n
		IF v_estatus_canales IS NULL THEN
			SELECT ea.pky_estatus_aclaracion, ecan.descripcion, ecan.concatena_dictamen, ecan.id_etapa_canales, ecan.descripcion_etapa_canales, ecan.descripcion_sms
				INTO v_id_estatus_aclaracion, v_estatus_canales, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales, v_estatus_sms
			FROM acl_estatus_canales ecan
				INNER JOIN acl_estatus_aclaracion ea ON ea.nombre = ecan.nombre_estatus_aclaracion 
			WHERE pky_estatus_aclaracion = pEstatusAcl 
				AND ecan.nombre_estatus_corp_general IS NULL 
				AND ecan.nombre_estatus_corp_analisis IS NULL;
		END IF;
		
		--En caso que la consulta no devuelva resultados se mostrarÃ¡ el valor del Estatus de la aclaraciÃ³n
		IF v_estatus_canales IS NULL THEN
			SELECT ea.pky_estatus_aclaracion, ea.descripcion, 0
				INTO v_id_estatus_aclaracion, v_estatus_canales, v_concatena_dictamen
			FROM acl_estatus_aclaracion ea 
			WHERE pky_estatus_aclaracion = pEstatusAcl;
			
			--Se asignan los valores de la "Etapa" considerando el estatus de la AclaraciÃ³n
			IF v_id_estatus_aclaracion = 1 THEN
				LET v_id_etapa_canales = 1;
				LET v_desc_etapa_canales = 'ALTA';
			ELIF v_id_estatus_aclaracion = 2 THEN
				LET v_id_etapa_canales = 2;
				LET v_desc_etapa_canales = 'ANÃLISIS';
			ELIF v_id_estatus_aclaracion BETWEEN 3 AND 5 THEN
				LET v_id_etapa_canales = 3;
				LET v_desc_etapa_canales = 'DICTAMEN';
			ELSE
				LET v_id_etapa_canales = 0;
				LET v_desc_etapa_canales = 'NO DEFINIDO';
			END IF;
		END IF;
		
		IF v_estatus_canales IS NULL THEN
			LET v_cod_ret = '00002'; --El estatus de la AclaraciÃ³n no existe
		END IF;
		
		RETURN v_cod_ret, v_estatus_canales, v_estatus_sms, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales;
			
	END;
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Enero/2020',
'Requerimiento	:	RQM 18 145',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_consulta_aclaracion_sms(
                        pFolioCsuac CHAR(30),pCel CHAR(10), pnumCliente CHAR(20))
		
		RETURNING
		CHAR(5)				AS cod_ret;
		/*
		CHAR(10)			AS folio_csuac,
		MONEY				AS montoreclamado,
		MONEY				AS montoprocedente,
		CHAR(50)			AS estatus_canales,
		CHAR(15)			AS telefono_dudas,
		SMALLINT			AS procede,
		INTEGER				AS fky_estatus_aclaracion,
		INTEGER				AS fky_estatus_corp_analisis,
		INTEGER				AS fky_estatus_corp_general,
		CHAR(10)			AS num_cliente;
        */

		/*Definicion de Variables*/
		
		DEFINE sql_err 				INTEGER;
		DEFINE autentica            INTEGER;
	    DEFINE v_cod_ret 			CHAR(5);
		DEFINE v_cod_ret_reg_eve	CHAR(5);
		DEFINE v_folio_csuac    	CHAR(10); 
		DEFINE v_montoreclamado		MONEY;
	    DEFINE v_montoprocedente	MONEY;
		DEFINE v_estatus_canales    CHAR(50); 
		DEFINE v_estatus_sms        CHAR(50); 
		DEFINE v_telefono_dudas     CHAR(15);
		DEFINE v_procede		    SMALLINT;
		DEFINE v_fky_estatus_aclaracion  	INTEGER;
		DEFINE v_fky_estatus_corp_analisis 	INTEGER;
		DEFINE v_fky_estatus_corp_general 	INTEGER;	
		
		DEFINE v_desc_estatus_canales    CHAR(50);			
		DEFINE v_concatena_dictamen 	 SMALLINT;
	    DEFINE v_id_etapa_canales        SMALLINT;
        DEFINE v_desc_etapa_canales 	 CHAR(20);
		DEFINE v_num_cliente	         CHAR(10);
		DEFINE v_fecha_consulta	        DATETIME YEAR TO FRACTION(5);
		
		/*Inicializacion de Variables*/
		
		LET v_cod_ret   		= "00000";
		LET sql_err 			=	0;
		LET autentica 			=	0;
		LET v_folio_csuac   	= NULL;
		LET v_montoreclamado	= NULL;
	    LET v_montoprocedente	= NULL;
		LET v_estatus_canales   = NULL;
        LET v_estatus_sms       = NULL;
		LET v_telefono_dudas    = ''; 
		LET v_procede		    = NULL;
		LET v_fky_estatus_aclaracion  	= NULL;
		LET v_fky_estatus_corp_analisis = NULL;
		LET v_fky_estatus_corp_general 	= NULL;
		LET v_num_cliente	            = NULL;
		LET v_desc_estatus_canales      = NULL;		
		LET v_concatena_dictamen 		= NULL;
	    LET v_id_etapa_canales       	= NULL;
        LET v_desc_etapa_canales 		= NULL;	
		LET v_cod_ret_reg_eve 			= "00000";
		LET v_fecha_consulta			=NULL;
		
		SET ISOLATION TO DIRTY READ;
	    SET LOCK MODE TO WAIT 3;
			
		--SET DEBUG FILE TO "/informix/Paty/RQM665/sp_consulta_aclaracion_sms.out";
		--TRACE ON;
		
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_cod_ret = sql_err;
				
				--RETURN v_cod_ret, v_folio_csuac, v_montoreclamado, v_montoprocedente, v_estatus_canales, v_telefono_dudas, v_procede,v_fky_estatus_aclaracion,
				--v_fky_estatus_corp_analisis,v_fky_estatus_corp_general;
				
			END IF;
		END EXCEPTION;
				
	LET pFolioCsuac= pFolioCsuac;			
	
    --Validar Telefono 
	IF pnumCliente IS NOT NULL AND TRIM(pnumCliente) <> '' AND pFolioCsuac IS NOT NULL AND TRIM(pFolioCsuac) <> '' AND pCel IS NOT NULL AND TRIM(pCel) <> '' 

	THEN  
	
	SELECT folio_csuac,importereclamado,montoprocedente,procede,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,num_cliente
	INTO  v_folio_csuac,v_montoreclamado,v_montoprocedente,v_procede,v_fky_estatus_aclaracion,v_fky_estatus_corp_analisis,v_fky_estatus_corp_general,v_num_cliente
	FROM "informix".acl_aclaracion WHERE folio_csuac IN (pFolioCsuac);
 	
	SELECT COUNT(*) INTO autentica FROM "informix".acl_aclaracion WHERE folio_csuac = pFolioCsuac AND num_cliente= pnumCliente;
		
	--SELECT COUNT(*) INTO autentica FROM bdinteg:"informix".si_telefonos_actual WHERE numcte= v_num_cliente AND telefono = pCel AND tipo_tel = '2' AND status_tel = 'A';
	
	IF  autentica > 0  THEN
	 /* Insertar en tabla */
	INSERT INTO "informix".acl_bitacora_sms(folio, num_cliente, num_telefono, envio_exitoso, fecha_consulta) 
    VALUES(pFolioCsuac, pnumCliente, pCel, 1, current);
	
	
	--Se obtiene estatus---
	CALL "informix".sp_obten_estatus_canales_sms(v_fky_estatus_aclaracion, v_fky_estatus_corp_general, v_fky_estatus_corp_analisis)
			RETURNING  v_cod_ret,v_estatus_canales,v_estatus_sms, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales;
			
	
		IF v_concatena_dictamen = 1 THEN
			IF v_procede = 1 THEN
				LET v_estatus_sms = TRIM(v_estatus_sms) || ' - Procedente';
				LET v_montoreclamado = v_montoprocedente;
			ELIF v_procede = 0 THEN
				LET v_estatus_sms = TRIM(v_estatus_sms) || ' - No procedente';
			END IF;
		END IF;
		
			
		LET v_montoreclamado = NVL(v_montoreclamado,0);
		LET v_montoprocedente = NVL(v_montoprocedente,0);
		
	
	/* se envia a llamar el SP de registra evento si existe el status de la aclaracion*/		
	       
        IF  v_estatus_sms IS NOT NULL THEN 	   
		  
		CALL bdimnsj:sp_registra_evento('2','ACL_SMS','ACL_EST','000000000','','','1',v_folio_csuac,'','','',v_estatus_sms,'','','','','','',pCel,1,v_montoreclamado,v_montoprocedente,0,0,current,'') RETURNING v_cod_ret_reg_eve;	
	
        ELSE 
		
		CALL bdimnsj:sp_registra_evento('2','ACL_SMS','ACL_EST_ERR','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,current,'') RETURNING v_cod_ret_reg_eve;	
		
	    END IF;
				
		ELIF autentica = 0 OR v_cod_ret_reg_eve != '00000' THEN 
		
		/*Actualiza bitacora a no se envio*/
		LET v_cod_ret_reg_eve = '00001';

		CALL bdimnsj:sp_registra_evento('2','ACL_SMS','ACL_EST_ERR','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,current,'') RETURNING v_cod_ret_reg_eve;	

		INSERT INTO "informix".acl_bitacora_sms(folio, num_cliente, num_telefono, envio_exitoso, fecha_consulta) 
		VALUES(pFolioCsuac, pnumCliente, pCel, 0, current);

		END IF;
		
	ELSE	
	
	    LET v_cod_ret_reg_eve = '00003';
	
		CALL bdimnsj:sp_registra_evento('2','ACL_SMS','ACL_EST_ERR','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,current,'') RETURNING v_cod_ret_reg_eve;	

		INSERT INTO "informix".acl_bitacora_sms(folio, num_cliente, num_telefono, envio_exitoso, fecha_consulta) 
		VALUES(pFolioCsuac, pnumCliente, pCel, 3, current);
		

		END IF; 
    	LET v_cod_ret = v_cod_ret_reg_eve;
				
		RETURN v_cod_ret;
	END;
END PROCEDURE;