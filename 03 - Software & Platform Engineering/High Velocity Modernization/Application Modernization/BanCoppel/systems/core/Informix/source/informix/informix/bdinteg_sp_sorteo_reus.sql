CREATE PROCEDURE "informix".sp_sorteo_reus()
RETURNING CHAR(5) AS cCod_Ret;
-- DEFINICION DE VARIABLES
DEFINE cCodRet						CHAR(5);
DEFINE iSqlErr						INTEGER;
DEFINE cDia							CHAR(2);
DEFINE cMes							CHAR(2);
DEFINE cAnio						CHAR(4);
DEFINE vCadena_req					CHAR(334);
DEFINE cCadena 						CHAR(200);
DEFINE vsql 						CHAR(200);
DEFINE v_totales 					INTEGER;
DEFINE v_id 						INTEGER;
DEFINE v_estado 					CHAR(1);
DEFINE v_nombres 					CHAR(50);
DEFINE v_paterno 					CHAR(50);
DEFINE v_materno 					CHAR(50);
DEFINE v_rfc 						CHAR(13);
DEFINE v_telefono_fijo 				CHAR(10);
DEFINE v_telefono_movil 			CHAR(10);
DEFINE v_correo_particular 			CHAR(50);
DEFINE v_correo_oficina 			CHAR(50);
DEFINE v_fecha_inicio_vigencia 		CHAR(13);
DEFINE v_fecha_termino_vigencia 	CHAR(13);
DEFINE v_fecha_registro 			CHAR(13);
DEFINE v_status 					CHAR(1);

--DEFINE v_f_fecha_inicio_vigencia 		DATE;
--DEFINE v_f_fecha_termino_vigencia 	DATE;
--DEFINE v_f_fecha_registro 			DATE;


DEFINE dFecha_Hoy					DATE;
DEFINE dFecha_Max_Procesada			DATE;
DEFINE vcontador					INTEGER;
DEFINE v_temp_table			INTEGER;


--INICIALIZACION DE VARIABLES--
LET cCodRet						= "00000";
LET iSqlErr						= 0;
LET cDia						= '';
LET cMes						= '';
LET cAnio						= '';
LET vCadena_req					= '';
LET dFecha_Max_Procesada		= MDY('01','01','1900');
LET vcontador					= 0;
LET cCadena 					= '';
LET vsql 						= '';
LET v_totales 					= 0;
LET v_id 						= 0;
LET v_estado 					= '';
LET v_nombres 					= '';
LET v_paterno 					= '';
LET v_materno 					= '';
LET v_rfc 						= '';
LET v_telefono_fijo 			= '';
LET v_telefono_movil 			= '';
LET v_correo_particular 		= '';
LET v_correo_oficina 			= '';
LET v_fecha_inicio_vigencia 	= '';
LET v_fecha_termino_vigencia 	= '';
LET v_fecha_registro 			= '';
LET v_status 					= '';

	-- SET DEBUG FILE TO  '/ifxsif01/sor/sp_reus_tra.out';
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				--insert into "informix".sac_log_errores_sorteo (codigoError,mensaje,fecha)
				--values (cCodRet,vCadena_req,sysdate);
				COMMIT;
			RETURN cCodRet;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		
		
--Consulta que regresa la fecha del dia actual
	/*	SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM "informix".si_fechas
		WHERE empresa = "001";
		
--Se inicializa la variable dFecha_Max_Procesada con el valor dFecha_Hoy
		LET dFecha_Max_Procesada = EXTEND(dFecha_Hoy, YEAR TO DAY) - 1 UNITS MONTH;
		
--Se asignan los valores a las variables cDia,cMes,cAnio, vMesActualCadena

	/*	LET cDia = LPAD(DAY(dFecha_Max_Procesada::DATE), 2, '0');
		LET cMes = LPAD(MONTH(dFecha_Max_Procesada::DATE), 2, '0'); 
		LET cAnio = LPAD(YEAR(dFecha_Max_Procesada::DATE),4,'0');*/

		SELECT tabid
		INTO v_temp_table
		FROM systables WHERE tabname ='tabla_temp_sorteo_reus';
		
		IF v_temp_table IS NOT NULL THEN
			DROP TABLE "informix".tabla_temp_sorteo_reus;
		END IF;
		
--Se verificara que los clientes cumplan con las reglas para participar

		--CREATE TEMP TABLE tabla_sorteo_reus(
		CREATE TABLE "informix".tabla_temp_sorteo_reus( 
			id 						INTEGER,
			estado 					CHAR(1),
			nombres 				CHAR(50),
			paterno 				CHAR(50),
			materno 				CHAR(50),
			rfc 					CHAR(13),
			telefono_fijo 			CHAR(15),
			telefono_movil 			CHAR(15),
			correo_particular 		CHAR(50),
			correo_oficina 			CHAR(50),
			fecha_inicio_vigencia 	CHAR(12),
			fecha_termino_vigencia 	CHAR(12),
			fecha_registro 			CHAR(12),
			status 					CHAR(1)
		);
		
		-- Se crea cadena con la ruta donde se encuentra el archivo
		LET cCadena = '';
		LET cCadena = ' echo "FILE /RESPALDOSNEW/Sorteo2024/REUS_V40.csv DELIMITER '|| "'" || '|' || "'" || ' 14;' || '">/RESPALDOSNEW/Sorteo2024/REUS_V40.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".tabla_temp_sorteo_reus;' || '">> /RESPALDOSNEW/Sorteo2024/REUS_V40.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/Sorteo2024/REUS_V40.sql';
		SYSTEM cCadena;
		
		--Cargamos la informacion en la tabla de control
		LET cCadena = "";
		LET cCadena = 'dbload -d bdinteg -c /RESPALDOSNEW/Sorteo2024/REUS_V40.sql -l /RESPALDOSNEW/Sorteo2024/REUS_V40.log -n 1000 -r';
		SYSTEM cCadena;
		-----Se elimina script de ruta
		LET vsql = "";
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/Sorteo2024/REUS_V40.sql';
		system vsql; 
		---Se elimina archivo procedado de Ruta
		LET vsql = "";
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/Sorteo2024/REUS_V40.csv';
		system vsql; 

		SELECT COUNT(id)
		INTO v_totales
		FROM tabla_temp_sorteo_reus;

		/*IF v_totales = 0 then
			LET cCodRet = '00001';
			return cCodRet;
		END IF;*/
		
		SELECT tabid
		INTO v_temp_table
		FROM systables WHERE tabname ='si_sorteo_reus';
		
		IF v_temp_table IS NOT NULL THEN
			TRUNCATE TABLE "informix".si_sorteo_reus;
		END IF;
		
		--TRUNCATE TABLE "informix".si_sorteo_reus;

		BEGIN WORK;

			

			FOREACH WITH HOLD

				SELECT id, estado, nombres, paterno, materno, rfc, telefono_fijo, telefono_movil, correo_particular, correo_oficina, fecha_inicio_vigencia, fecha_termino_vigencia, fecha_registro, status
				INTO v_id, v_estado, v_nombres, v_paterno, v_materno, v_rfc, v_telefono_fijo, v_telefono_movil, v_correo_particular, v_correo_oficina, v_fecha_inicio_vigencia, v_fecha_termino_vigencia, v_fecha_registro, v_status
			 	FROM tabla_temp_sorteo_reus

			 	LET v_telefono_fijo = REPLACE(v_telefono_fijo, '.0', '');

			 	LET v_telefono_movil = REPLACE(v_telefono_movil, '.0', '');
				
				/*LET v_f_fecha_inicio_vigencia 	= trim(v_fecha_inicio_vigencia);
				LET v_f_fecha_termino_vigencia 	= trim(v_fecha_termino_vigencia);
				LET v_f_fecha_registro 			= trim(v_fecha_registro);*/
			 	
				INSERT INTO "informix".si_sorteo_reus VALUES (v_id, v_estado, v_nombres, v_paterno, v_materno, v_rfc, v_telefono_fijo, v_telefono_movil, v_correo_particular, v_correo_oficina, v_fecha_inicio_vigencia, v_fecha_termino_vigencia, v_fecha_registro, v_status);


			 	LET vcontador = vcontador + 1;
	
				IF vcontador = 1000 THEN
					COMMIT WORK;
					LET vcontador = 0;
					BEGIN WORK;
				END IF;

			END FOREACH;

		DROP TABLE "informix".tabla_temp_sorteo_reus;
				
		COMMIT WORK;
		
		RETURN cCodRet;
	
	END;
END PROCEDURE;