CREATE PROCEDURE "informix".sp_concreing_dep_atm (psCve_Usuario VARCHAR(10) , piHorario INTEGER)

		RETURNING VARCHAR (5)   AS CODIGO, VARCHAR (150) AS MENSAJE_RPTA;
		
		 /*  DEFINICION DE VARIABLES */

			-- CONTROL DE ERRORES
			
		    DEFINE  SQL_ERR          INTEGER;
			DEFINE  ISAM_ERR         INTEGER;
			DEFINE  ERROR_INFO       VARCHAR(80);
			
			--CONTROL GENERAL
			
			DEFINE CODIGO				 CHAR (6);
			DEFINE MENSAJE_RPTA			 CHAR (80);
			DEFINE vdFechaInicio		 DATETIME YEAR TO FRACTION (5);
			DEFINE vdFechaFin			 DATETIME YEAR TO FRACTION (5);
			DEFINE vsFechaArchivo		 CHAR (10);
			DEFINE vsFechaArchivoTMO	 CHAR (06);
			DEFINE vsNombreArchivo		 VARCHAR (30);
			DEFINE vsProceso			 CHAR (01);
			DEFINE vsFechaHorainAuthini	 CHAR (10);
			DEFINE vsFechaHorainAuthfin	 CHAR (10);
			DEFINE vsConAdmin			 CHAR (01);
			DEFINE RUTA_DESTINO 		 VARCHAR(80);
			DEFINE TIPO_PLANTILLA		 VARCHAR(30);
			DEFINE TIPO_PLANTILLA_TOTAL	 VARCHAR(30);
			DEFINE vsql					 CHAR(1150);
			DEFINE vExecuteSQL 			 LVARCHAR(1500);
			
			
			
	BEGIN	
		
		ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
				
		  LET CODIGO    = SQL_ERR;
		  LET MENSAJE_RPTA  = ERROR_INFO;
		  
		  RETURN CODIGO, MENSAJE_RPTA;
		  
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/informix/LVRQ/dep_atm/debug/CNC_ATMS_DEP.out";
		--TRACE ON;
		
			/* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
			
			LET CODIGO					= '00000';
			LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
			LET vdFechaInicio			= CURRENT;
			LET vdFechaFin				= CURRENT;
			LET vsFechaArchivo			= '';
			LET vsFechaArchivoTMO		= '';
			LET vsNombreArchivo			= '';
			LET vsProceso				= '';
			LET vsFechaHorainAuthini	= '';
			LET vsFechaHorainAuthfin	= '';
			LET vsConAdmin				= '';
			LET RUTA_DESTINO	 		= '/RESPALDOSNEW/Depositadores_atm/';
			LET TIPO_PLANTILLA	 		= 'ATM_DEP_VS_MOVHIS_';
			LET TIPO_PLANTILLA_TOTAL	= 'TOTAL_CAJEROS_IST_'; -- QUITAR
			LET vsql					='';
			LET vExecuteSQL				='';

		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;	

		--TRACE 'ES CNC DE nueva inicio';
			IF ( (SELECT COUNT(*) FROM bditarjeta:td_archivos_conciliacion_dep_atm 	
					WHERE archivo_origen = 'DEP'
					AND conadmin = '') = 0 ) THEN
					
					LET CODIGO = '00001';
					LET MENSAJE_RPTA = 'NO SE ENCONTRO ARCHIVO PARA SER CONCILIADO';
					
					RETURN CODIGO, MENSAJE_RPTA;
				          
			END IF;
			--TRACE 'ES CNC DE nueva fin';

		   IF ( (SELECT COUNT(*) FROM bditarjeta:systables WHERE tabname = 'tmp_paso_movhis_cnc_atm') = 1 ) THEN

					TRUNCATE TABLE tmp_paso_dep_atm DROP STORAGE;
					TRUNCATE TABLE tmp_paso_mov_vs_dep DROP STORAGE;
					TRUNCATE TABLE tmp_paso_movhis_cnc_atm DROP STORAGE;

			END IF;
			
		
			FOREACH cursor_cnc FOR
			
				/* Campos utilizados para obtener los archivos que se deban procesar para la conciliacion */

				SELECT nombrearchivo,TO_CHAR((fecha_archivo)-1, '%m-%d-%Y'),TO_CHAR((fecha_archivo), '%m-%d-%Y'),
					   fecha_archivo,TO_CHAR((fecha_archivo)-1, '%d%m%y'),proceso,conadmin
				INTO vsNombreArchivo,vsFechaHorainAuthini,vsFechaHorainAuthfin,vsFechaArchivo,vsFechaArchivoTMO,vsProceso,vsConAdmin
					FROM bditarjeta:td_archivos_conciliacion_dep_atm
					WHERE archivo_origen = 'DEP'
					AND conadmin = ''
			
		
				/* SE GENERA TABLA TEMPORAL CON LOS REGISTROS DE LA TABLA DE MOVIMIENTO HISTORICOS */
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo " SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;'||
								  ' UNLOAD TO /RESPALDOSNEW/Depositadores_atm/dep_atm_movhis.unl'||
								  ' SELECT cuenta,monto_tot,transacc_suc,fech_oper,usuario,fech_alt,sucursal,folio_suc,referencia'||
							' FROM bdicheq:sc_movhis '||
							' WHERE fech_alt BETWEEN '||"'"|| vsFechaHorainAuthini||"'"||' AND '||"'"|| vsFechaHorainAuthini ||"'"||
							' AND transacc = \"0318\"		 	AND '||
							' sucursal = \"8502\"  '||
							';" >'|| 
							' /RESPALDOSNEW/Depositadores_atm/'||'movhis_DepAtm.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #2
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'dbaccess bdicheq '||'/RESPALDOSNEW/Depositadores_atm/'||'movhis_DepAtm.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #3
				LET vExecuteSQL = '';
				LET vExecuteSQL = "echo "||'"'|| "file '"|| '/RESPALDOSNEW/Depositadores_atm' ||
						"/" || 'dep_atm_movhis.unl' || "' delimiter '|' "|| '9'||
							"; insert into tmp_paso_movhis_cnc_atm" || ";"||'"'||' > /RESPALDOSNEW/Depositadores_atm/carga_movhis.txt';
					SYSTEM vExecuteSQL;
				
				---Paso #4
				LET vExecuteSQL = '';
				LET vExecuteSQL = "dbload -d bditarjeta -c /RESPALDOSNEW/Depositadores_atm/carga_movhis.txt -l err_carga.log -n 1000 -k";
				SYSTEM vExecuteSQL;			
				

					---Paso #5
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f /RESPALDOSNEW/Depositadores_atm/dep_atm_movhis.unl';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f /RESPALDOSNEW/Depositadores_atm/movhis_DepAtm.sql'; 
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  carga_movhis.txt';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  err_carga.log';
				SYSTEM vExecuteSQL;
				
				
				/* SE GENERA TABLA TEMPORAL CON LOS REGISTROS DE LA TABLA CONCILIACION_ATM_STAT06_DEPOSITADORES */
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo " SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;'||
								' UNLOAD TO /RESPALDOSNEW/Depositadores_atm/DepAtm_stat06.unl'||
								' SELECT nombrearchivo,num_cuenta,monto_deposito,fecha,hora,tipo_txn,'||
								' descripcion,folio_dep,sec_extendida_archivo,cajero'||
								' FROM Intercard:conciliacion_atm_stat06_depositadores '||
								' WHERE nombrearchivo = ' ||"'"||vsNombreArchivo||"'"||
								' AND tipo_txn =\"D\"'||
								';" >'|| 
							' /RESPALDOSNEW/Depositadores_atm/'||'DepAtm_cnc.sql';
				SYSTEM vExecuteSQL;
				
				
				---Paso #2
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'dbaccess intercard '||'/RESPALDOSNEW/Depositadores_atm/'||'DepAtm_cnc.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #3
				LET vExecuteSQL = '';
				LET vExecuteSQL = "echo "||'"'|| "file '"|| '/RESPALDOSNEW/Depositadores_atm' ||
						"/" || 'DepAtm_stat06.unl' || "' delimiter '|' "|| '10'||
							"; insert into tmp_paso_dep_atm" || ";"||'"'||' > /RESPALDOSNEW/Depositadores_atm/carga_dep_stat.txt';
				SYSTEM vExecuteSQL;
				
				---Paso #4
				LET vExecuteSQL = '';
				LET vExecuteSQL = "dbload -d bditarjeta -c /RESPALDOSNEW/Depositadores_atm/carga_dep_stat.txt -l err_carga.log -n 1000 -k";
				SYSTEM vExecuteSQL;

				---Paso #5
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f /RESPALDOSNEW/Depositadores_atm/DepAtm_stat06.unl';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f /RESPALDOSNEW/Depositadores_atm/DepAtm_cnc.sql'; 
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  carga_dep_stat.txt';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  err_carga.log';
				SYSTEM vExecuteSQL;				
			
				
				SELECT cnc.nombrearchivo,cnc.num_cuenta,his.cuenta,cnc.monto_deposito,his.monto_tot,his.transacc_suc,
						cnc.tipo_txn,his.sucursal,cnc.fecha,his.fech_oper,cnc.hora,his.fech_alt,cnc.descripcion,cnc.folio_dep,
						his.folio_suc,cnc.sec_extendida_archivo,cnc.cajero,his.usuario,his.referencia
					FROM tmp_paso_movhis_cnc_atm his
					full OUTER JOIN tmp_paso_dep_atm cnc
					ON cnc.num_cuenta = his.cuenta 
					and cnc.folio_dep = his.folio_suc
				INTO temp tb_full_stat_movhis WITH NO LOG ;
				
				
				SELECT *,
					CASE
						WHEN num_cuenta IS NULL THEN cuenta
						ELSE num_cuenta
					END fn_num_cuenta,

					CASE 
						WHEN folio_suc IS NULL then 'F'
						ELSE 'V'
					END  ok_movhis,

					CASE 
						WHEN folio_dep IS NULL then 'F'
						ELSE 'V'
					END ok_atm_dep

					FROM tb_full_stat_movhis
				INTO temp tb_full_stat_movhis_2 WITH NO LOG ;
				
				--- Aqui me quede
				
				SELECT tbl1.fn_num_cuenta,tbl1.folio_suc,tbl1.folio_dep
					FROM tb_full_stat_movhis_2 tbl1
					JOIN bditarjeta:dep_atm_stat06_vs_movhis tbl2
					ON tbl1.fn_num_cuenta=tbl2.fn_num_cuenta 
					AND tbl1.folio_suc = tbl2.folio_suc
					AND tbl1.folio_dep = tbl2.folio_dep
				INTO temp tb_duplicados_dep WITH NO LOG ;
				
				DELETE FROM tb_full_stat_movhis_2 tbl3
					WHERE (tbl3.fn_num_cuenta IN(SELECT tbl4.fn_num_cuenta FROM tb_duplicados_dep tbl4)
				AND tbl3.folio_dep IN (SELECT tbl4.folio_dep FROM tb_duplicados_dep tbl4)
				);
				
				
				/* TBL DE PASO CON LAS TXN DE MOVIMIENTO VS IST */
				
				INSERT INTO tmp_paso_mov_vs_dep  --- nuevo
				SELECT  * FROM tb_full_stat_movhis_2;

				---Paso #1
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo " SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;'||
								  ' UNLOAD TO /RESPALDOSNEW/Depositadores_atm/txn_movhis_vs_stat.unl'||
								' SELECT nombrearchivo,num_cuenta,cuenta,monto_deposito,monto_tot, transacc_suc,tipo_txn,sucursal,fecha,'||
								' fech_oper, hora,fech_alt,descripcion,folio_dep, folio_suc, sec_extendida_archivo,cajero,usuario,'||
								' referencia,fn_num_cuenta,ok_movhis,ok_atm_dep'||
								' FROM bditarjeta:tmp_paso_mov_vs_dep '||
								';" >'|| 
							' /RESPALDOSNEW/Depositadores_atm/'||'DepAtm_movhis_stat06.sql';
				SYSTEM vExecuteSQL;
				
				
				---Paso #2
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'dbaccess bditarjeta '||'/RESPALDOSNEW/Depositadores_atm/'||'DepAtm_movhis_stat06.sql';
				SYSTEM vExecuteSQL;

				---Paso #3
				LET vExecuteSQL = '';
				LET vExecuteSQL = "echo "||'"'|| "file '"|| '/RESPALDOSNEW/Depositadores_atm' ||
						"/" || 'txn_movhis_vs_stat.unl' || "' delimiter '|' "|| '22'||
							"; insert into dep_atm_stat06_vs_movhis " || ";"||'"'||' > /RESPALDOSNEW/Depositadores_atm/carga_dep_stat_final.txt';
				SYSTEM vExecuteSQL;
				
				---Paso #4
				LET vExecuteSQL = '';
				LET vExecuteSQL = "dbload -d bditarjeta -c /RESPALDOSNEW/Depositadores_atm/carga_dep_stat_final.txt -l err_carga.log -n 1000 -k";
				SYSTEM vExecuteSQL;
				
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f /RESPALDOSNEW/Depositadores_atm/txn_movhis_vs_stat.unl';
				SYSTEM vExecuteSQL;
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  /RESPALDOSNEW/Depositadores_atm/carga_dep_stat_final.txt';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  err_carga.log';
				SYSTEM vExecuteSQL;		
				
				
				UPDATE bditarjeta:td_archivos_conciliacion_dep_atm
					SET conadmin = 'V'
					WHERE nombrearchivo = vsNombreArchivo
				AND conadmin='';
				
				/* Tablas Fisicas Temporales */
				
				TRUNCATE TABLE tmp_paso_dep_atm DROP STORAGE;
				TRUNCATE TABLE tmp_paso_mov_vs_dep DROP STORAGE;
				TRUNCATE TABLE tmp_paso_movhis_cnc_atm DROP STORAGE;
				
				/* Tablas temporales */
				
				DROP TABLE IF EXISTS tb_full_stat_movhis;
				DROP TABLE IF EXISTS tb_full_stat_movhis_2;
				DROP TABLE IF EXISTS tb_duplicados_dep;
				
				--- Reporte de conciliacion entre movimiento vs el archivo IST con el Core Bancario
			
				LET vsql = ''; 	   
				LET vsql = 'echo "nombrearchivo|num_cuenta|cuenta|monto_deposito|monto_tot|transacc_suc|tipo_txn|sucursal|'||
						   ' fecha|fech_oper|hora|fech_alt|descripcion|folio_dep|folio_suc|sec_extendida_archivo|cajero| '||
						   ' usuario|referencia|fn_num_cuenta|ok_movhis|ok_atm_dep " > '||
							RUTA_DESTINO||TIPO_PLANTILLA||LPAD (DAY(vsFechaArchivo),2,"0")||
							LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo) ||'.unl';
				system vsql;
				
								LET vsql = '';
				LET vsql = 'echo " SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; ' ||
						   ' UNLOAD TO ' ||RUTA_DESTINO||TIPO_PLANTILLA||LPAD (DAY(vsFechaArchivo),2,"0")||LPAD (MONTH(vsFechaArchivo),2,"0")||
							year(vsFechaArchivo)||'_01.unl'||
						   ' SELECT nombrearchivo,num_cuenta,cuenta,monto_deposito,monto_tot,transacc_suc,tipo_txn,sucursal,'||
						   ' fecha,fech_oper,hora,fech_alt,descripcion,folio_dep,folio_suc,sec_extendida_archivo,cajero,'||
						   ' usuario,referencia,fn_num_cuenta,ok_movhis,ok_atm_dep'||
						   ' from bditarjeta:dep_atm_stat06_vs_movhis '||
						   ' WHERE nombrearchivo = ' ||"'"||vsNombreArchivo||"'"||
						   ';">'||RUTA_DESTINO||TIPO_PLANTILLA||LPAD (DAY(vsFechaArchivo),2,"0")||LPAD (MONTH(vsFechaArchivo),2,"0")||
							year(vsFechaArchivo)||'.sql'; 
				system vsql;
				
				LET vsql ='';
				LET vsql= 'chmod 777 ' ||RUTA_DESTINO||TIPO_PLANTILLA||
						  LPAD (DAY(vsFechaArchivo),2,"0")||LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo)||'.sql';
				system vsql;
				
				LET vsql ='';
				LET vsql= 'dbaccess bditarjeta ' ||RUTA_DESTINO||TIPO_PLANTILLA||LPAD (DAY(vsFechaArchivo),2,"0")||
						   LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo)||'.sql';
				system vsql;
				
				LET vsql = '';
				LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA||LPAD (DAY(vsFechaArchivo),2,"0")||LPAD(MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo)||'.sql';
				system vsql;
				
				LET vsql = '';
				LET vsql = "sed 's/|$//g' "||RUTA_DESTINO||TIPO_PLANTILLA||LPAD (DAY(vsFechaArchivo),2,"0")||
						   LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo)||"_01.unl >>"||RUTA_DESTINO||TIPO_PLANTILLA||
						   LPAD (DAY(vsFechaArchivo),2,"0")||LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo)||".unl";
				system vsql;
				
				LET vsql = '';
				LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA||LPAD (DAY(vsFechaArchivo),2,"0")||LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo)||'_01.unl';
				system vsql;
				

			END FOREACH; -- CICLO DE OBTENCION DE REGISTROS	
			
		RETURN CODIGO, MENSAJE_RPTA;
	END
END PROCEDURE;