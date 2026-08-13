CREATE PROCEDURE "informix".sp_concreing_atm (psCve_Usuario VARCHAR(10) , piHorario INTEGER)

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
			DEFINE vsNombreArchivo		 VARCHAR (25);
			DEFINE vsProceso			 CHAR (01);
			DEFINE vsFechaHorainAuthini	 CHAR (10);
			DEFINE vsFechaHorainAuthfin	 CHAR (10);
			DEFINE vsFechaCncInicio		 DATETIME YEAR TO FRACTION (5);
			DEFINE vsFechaCncFin		 DATETIME YEAR TO FRACTION (5);
			DEFINE vsFechaProcesoCnc	 CHAR (10);
			DEFINE vsConAdmin			 CHAR (01);
			DEFINE RUTA_DESTINO 		 VARCHAR(80);
			DEFINE TIPO_PLANTILLA		 VARCHAR(30);
			DEFINE TIPO_PLANTILLA_TOTAL	 VARCHAR(30);
			DEFINE vsql					 CHAR(1150);
			DEFINE vExecuteSQL 			 LVARCHAR(1500);
			
			/* FOREACH */
			
			DEFINE vs_mv_secuencia				VARCHAR(7);
			DEFINE vs_stat_nombrearchivo		VARCHAR(23);
			DEFINE vs_stat_autorizacion      	VARCHAR(7);
			DEFINE vs_final_numtarjeta       	VARCHAR(16);
			DEFINE vs_stat_numcuenta         	CHAR(20);
			DEFINE vs_mv_montomov            	DECIMAL(19,4);
			DEFINE vs_stat_monto             	MONEY;
			DEFINE vs_monto_cheq_cred        	MONEY;
			DEFINE vs_fn_secuenciaextendida  	CHAR(16);
			DEFINE vs_mv_montorealrevfzda    	DECIMAL(19,4);
			DEFINE vs_mv_codreversa          	VARCHAR(1);
			DEFINE vs_stat_indicadordereversa	CHAR(19);
			DEFINE vs_mv_prodind             	VARCHAR(2);
			DEFINE vs_mv_formato             	VARCHAR(4);
			DEFINE vs_mv_codtran             	VARCHAR(2);
			DEFINE vs_mv_metodocaptura       	VARCHAR(2);
			DEFINE vs_mv_trancajeropropio    	VARCHAR(1);
			DEFINE vs_mv_idterminal          	VARCHAR(16);
			DEFINE vs_mv_infreceptor         	VARCHAR(40);
			DEFINE vs_mv_esnacional          	VARCHAR(1);
			DEFINE vs_mv_pais                	VARCHAR(2);
			DEFINE vs_mv_fechahorainauth     	DATETIME YEAR to FRACTION(5);
			DEFINE vs_stat_fechaconciliacion 	DATETIME YEAR to FRACTION(5);
			DEFINE vs_stat_fecha             	CHAR(8);
			DEFINE vs_stat_hora              	CHAR(8);
			DEFINE vs_fn_producto            	CHAR(1);
			DEFINE vs_tbl_mov                	CHAR(1);
			DEFINE vs_tbl_stat06             	CHAR(1);
			DEFINE vs_tbl_movhis             	CHAR(1);
			DEFINE vs_Resultado_final        	CHAR(13);

			
			
			
	BEGIN	
		
		ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
				
		  LET CODIGO    = SQL_ERR;
		  LET MENSAJE_RPTA  = ERROR_INFO;
		  
		  RETURN CODIGO, MENSAJE_RPTA;
		  
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/home/c98188925/debug/CNC_ATMS_MOD.out";
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
			LET vsFechaCncInicio		= CURRENT;
			LET vsFechaCncFin			= CURRENT;
			LET vsFechaProcesoCnc 		= '';
			LET vsConAdmin				= '';
			LET RUTA_DESTINO	 		= '/resplogifx/';
			LET TIPO_PLANTILLA	 		= 'IST_VS_APLICATIVOS_';
			LET TIPO_PLANTILLA_TOTAL	= 'TOTAL_CAJEROS_IST_';
			LET vsql					='';
			LET vExecuteSQL				='';
			
			
			/* FOREACH */
			
			LET vs_mv_secuencia				= '';
			LET vs_stat_nombrearchivo		= '';
			LET vs_stat_autorizacion      	= '';
			LET vs_final_numtarjeta       	= '';
			LET vs_stat_numcuenta         	= '';
			LET vs_mv_montomov            	= 0;
			LET vs_stat_monto             	= 0;
			LET vs_monto_cheq_cred        	= 0;
			LET vs_fn_secuenciaextendida  	= '';
			LET vs_mv_montorealrevfzda    	= 0;
			LET vs_mv_codreversa          	= '';
			LET vs_stat_indicadordereversa	= '';
			LET vs_mv_prodind             	= '';
			LET vs_mv_formato             	= '';
			LET vs_mv_codtran             	= '';
			LET vs_mv_metodocaptura       	= '';
			LET vs_mv_trancajeropropio    	= '';
			LET vs_mv_idterminal          	= '';
			LET vs_mv_infreceptor         	= '';
			LET vs_mv_esnacional          	= '';
			LET vs_mv_pais                	= '';
			LET vs_mv_fechahorainauth     	= '';
			LET vs_stat_fechaconciliacion 	= '';
			LET vs_stat_fecha             	= '';
			LET vs_stat_hora              	= '';
			LET vs_fn_producto            	= '';
			LET vs_tbl_mov                	= '';
			LET vs_tbl_stat06             	= '';
			LET vs_tbl_movhis             	= '';
			LET vs_Resultado_final        	= '';

		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;	
		
			IF ( (SELECT COUNT(*) FROM bditarjeta:td_archivos_conciliacion 	
					WHERE archivo_origen = 'IST'
					AND conadmin = ''
					AND proceso='T') = 0 ) THEN
					
					LET CODIGO = '00001';
					LET MENSAJE_RPTA = 'NO SE ENCONTRO ARCHIVO PARA SER CONCILIADO';
					
					RETURN CODIGO, MENSAJE_RPTA;
				          
			END IF;
			

		   IF ( (SELECT COUNT(*) FROM bditarjeta:systables WHERE tabname = 'tmp_paso_movimiento_cnc_atm') = 1 ) THEN

					TRUNCATE TABLE tmp_paso_movimiento_cnc_atm DROP STORAGE;
					TRUNCATE TABLE tmp_paso_stat DROP STORAGE;
					TRUNCATE TABLE tmp_paso_reversos_stat DROP STORAGE;
					TRUNCATE TABLE tmp_paso_mov_vs_ist DROP STORAGE;
					TRUNCATE TABLE tmp_atmAdmin DROP STORAGE;
			END IF;
			
		
			
			FOREACH cursor_cnc FOR
			
				/* Campos utilizados para obtener los archivos que se deban procesar para la conciliacion */


				SELECT nombrearchivo,TO_CHAR((fecha_archivo)-1, '%Y-%m-%d'),TO_CHAR((fecha_archivo), '%Y-%m-%d'),
					   fecha_archivo,TO_CHAR((fecha_archivo)-1, '%d%m%y'),proceso,conadmin,
					   TO_CHAR((fecha_proceso), '%Y-%m-%d')
				INTO vsNombreArchivo,vsFechaHorainAuthini,vsFechaHorainAuthfin,vsFechaArchivo,
					 vsFechaArchivoTMO,vsProceso,vsConAdmin,vsFechaProcesoCnc
					FROM bditarjeta:td_archivos_conciliacion
					WHERE archivo_origen = 'IST'
					AND proceso ='T'
					AND conadmin = ''
				

				/* Se da formato de fechahorainauth como se encuentra en movimiento*/
			
				LET vdFechaInicio = vsFechaHorainAuthini || ' 00:00:00.0';
				LET vdFechaFin = vsFechaHorainAuthfin || ' 00:00:00.0';
				
				/* Se da formato a la fecha para obtener registros en td_movimientos_conciliacion_mc */
			
				LET vsFechaCncInicio = vsFechaProcesoCnc || ' 00:00:00.0';
				LET vsFechaCncFin 	 = vsFechaProcesoCnc || ' 23:59:59.9';
				
				
				/* SE GENERA TABLA TEMPORAL CON LOS REGISTROS DE LA TABLA DE MOVIMIENTO */
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo "UNLOAD TO '||RUTA_DESTINO||'ist_movimiento.unl'||
				' SELECT secuencia,numtarjeta,monto,secuenciaextendida,montorealrevfzda,codreversa,prodind,formato,'||
							' codtran,metodocaptura,trancajeropropio,idterminal,infreceptor,esnacional,pais,fechahorainauth'||
							' FROM Intercard:movimiento '||
							' WHERE fechahorainauth BETWEEN '||"'"|| vdFechaInicio||"'"||' AND '||"'"|| vdFechaFin ||"'"||
							' AND prodind = \"01\"		 	AND '||
							' formato = \"0200\"  	 	 	AND '||
							' codigoiso = \"00\"  	 	 	AND '||
							' codtran = \"01\" 		 	 	AND '||
							' transaccionorigen = \"0010\" 	AND '|| 
							' codreversa = 0    	 	 	AND '||
							' movreversado = \"F\" 	 	 	AND '||
							' trancajeropropio = \"V\"          '||
							';" >'|| 
							' /resplogifx/'||'mov_cnc.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #2
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'dbaccess intercard  '||RUTA_DESTINO||'mov_cnc.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #3
				LET vExecuteSQL = '';
				LET vExecuteSQL = "echo "||'"'|| "file '"|| RUTA_DESTINO ||
								  'ist_movimiento.unl' || "' delimiter '|' "|| '16'||
									"; insert into tmp_paso_movimiento_cnc_atm" || ";"||'"'||' > carga_movimientos.txt';
					SYSTEM vExecuteSQL;
				
				---Paso #4
				LET vExecuteSQL = '';
				LET vExecuteSQL = "dbload -d bditarjeta -c carga_movimientos.txt -l err_carga_mov.log -n 1000 -k";
				SYSTEM vExecuteSQL;			
				

					---Paso #5
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f /resplogifx/ist_movimiento.unl';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f /resplogifx/mov_cnc.sql'; 
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  carga_movimientos.txt';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  err_carga.log';
				SYSTEM vExecuteSQL;

				
				/* SE OBTIENEN REGISTROS DE LA TABLA CONCILIACION_STAT06 */
				

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo "UNLOAD TO /resplogifx/ist_stat.unl'||
								' SELECT '||
								' \"1\" ||autorizacion AS autorizacionstat,numtarjeta,numcuenta,monto,indicadordereversa,'||
								' fechaconciliacion,fecha,hora,secuenciaextendida,nombrearchivo'||
								' FROM Intercard:Conciliacion_ATM_Stat06 '||
								' WHERE fechaconciliacion BETWEEN '||"'"|| vsFechaCncInicio||"'"||' AND '||"'"|| vsFechaCncFin ||"'"||
								' AND codigoiso =\"00\"'||
								' AND nombrearchivo = ' ||"'"||vsNombreArchivo||"'"||
								' AND descripcion LIKE \"%RETIRO%\" '||
								' AND indicadordereversa != \"REVERSAL\" '||
								' AND SUBSTR (numtarjeta,0,6) IN  (' ||
								' SELECT bin '||
								' FROM intercard:bines'||
								' WHERE creditodebito IN (\"C\", \"D\"))'||
								
								
								
								';" >'|| 
							' /resplogifx/'||'ist_cnc.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #2
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'dbaccess intercard '||'/resplogifx/'||'ist_cnc.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #3
				LET vExecuteSQL = '';
				LET vExecuteSQL = "echo "||'"'|| "file '"|| '/resplogifx' ||
						"/" || 'ist_stat.unl' || "' delimiter '|' "|| '10'||
							"; insert into tmp_paso_stat" || ";"||'"'||' > carga_stat.txt';
					SYSTEM vExecuteSQL;
				
				---Paso #4
				LET vExecuteSQL = '';
				LET vExecuteSQL = "dbload -d bditarjeta -c carga_stat.txt -l err_carga_ist.log -n 1000 -k";
				SYSTEM vExecuteSQL;

					---Paso #5
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f /resplogifx/ist_stat.unl';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f /resplogifx/ist_cnc.sql'; 
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  carga_stat.txt';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  err_carga.log';
				SYSTEM vExecuteSQL;				
			
			/* SE ELIMINAN LOS REVERSOS DE tmp_paso_reversos_stat */
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo "UNLOAD TO /resplogifx/ist_stat_rev.unl'||
								' SELECT {+AVOID_FULL (intercard:conciliacion_atm_stat06)}'||
								' \"1\" ||autorizacion AS autorizacionstat,numtarjeta,numcuenta,monto,indicadordereversa,'||
								' fechaconciliacion,fecha,hora,secuenciaextendida,nombrearchivo'||
								' FROM Intercard:Conciliacion_ATM_Stat06 '||
								' WHERE fechaconciliacion BETWEEN '||"'"|| vsFechaCncInicio||"'"||' AND '||"'"|| vsFechaCncFin ||"'"||
								' AND codigoiso =\"00\"'||
								' AND nombrearchivo = ' ||"'"||vsNombreArchivo||"'"||
								' AND descripcion LIKE \"%RETIRO%\" '||
								' AND indicadordereversa = \"REVERSAL\" '||
								' AND SUBSTR (numtarjeta,0,6) IN  (' ||
								' SELECT bin '||
								' FROM intercard:bines'||
								' WHERE creditodebito IN (\"C\", \"D\"))'||
								';" >'|| 
							' /resplogifx/'||'ist_cnc_rev.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #2
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'dbaccess intercard '||'/resplogifx/'||'ist_cnc_rev.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #3
				LET vExecuteSQL = '';
				LET vExecuteSQL = "echo "||'"'|| "file '"|| '/resplogifx' ||
						"/" || 'ist_stat_rev.unl' || "' delimiter '|' "|| '10'||
							"; insert into tmp_paso_reversos_stat" || ";"||'"'||' > carga_stat_rev.txt';
					SYSTEM vExecuteSQL;
				
				---Paso #4
				LET vExecuteSQL = '';
				LET vExecuteSQL = "dbload -d bditarjeta -c carga_stat_rev.txt -l err_carga_rev.log -n 1000 -k";
				SYSTEM vExecuteSQL;	
				
				---Paso #5
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f /resplogifx/ist_stat_rev.unl';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f /resplogifx/ist_cnc_rev.sql'; 
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  carga_stat_rev.txt';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  err_carga.log';
				SYSTEM vExecuteSQL;	
				
		
			/* SE ELIMINAN LOS REVERSOS DE tmp_paso_stat */
				
				
				DELETE FROM tmp_paso_stat st
					WHERE (st.numtarjeta IN(SELECT rv.numtarjeta FROM tmp_paso_reversos_stat rv)
					AND st.secuenciaextendida IN (SELECT rv.secuenciaextendida FROM tmp_paso_reversos_stat rv)
				);
				
				
				SELECT stat.nombrearchivo,mv.secuencia,stat.autorizacion,mv.numtarjeta AS mv_numtarjeta, stat.numtarjeta AS stat_numtarjeta,stat.numcuenta,
					mv.montomov,stat.monto,mv.secuenciaextendida AS mv_secuenciaextendida,stat.secuenciaextendida AS stat_secuenciaextendida,
					mv.montorealrevfzda,mv.codreversa,stat.indicadordereversa,mv.prodind,mv.formato,mv.codtran,mv.metodocaptura,
					mv.trancajeropropio,mv.idterminal,mv.infreceptor,mv.esnacional,mv.pais,mv.fechahorainauth,stat.fechaconciliacion,
					stat.fecha,stat.hora
					FROM tmp_paso_stat stat
					full OUTER JOIN tmp_paso_movimiento_cnc_atm mv 
					ON stat.numtarjeta= mv.numtarjeta and stat.secuenciaextendida = mv.secuenciaextendida
				INTO temp tb_full_stat_mov WITH NO LOG ;
				


				SELECT *,
					CASE
						WHEN mv_numtarjeta IS NULL THEN stat_numtarjeta
						ELSE mv_numtarjeta
					END fn_numtarjeta,
					
					CASE 
						WHEN secuencia IS NULL then 'F'
						ELSE 'V'
					END  tbl_mov,
					
					CASE 
						WHEN autorizacion IS NULL then 'F'
						ELSE 'V'
					END tbl_stat06
					
					FROM tb_full_stat_mov stmov
				INTO temp tb_full_stat_mov_2 WITH NO LOG ;
				
			/* TBL DE PASO CON LAS TXN DE MOVIMIENTO VS IST */
				
				INSERT INTO tmp_paso_mov_vs_ist  --- nuevo
				SELECT  * FROM tb_full_stat_mov_2;
				
			/* SE OBTIENEN TXN */	
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo "UNLOAD TO /resplogifx/ist_admin_atm.unl'||
								' SELECT nomarchivo325,tarjeta,cuenta,montosif,producto'||
								' FROM Intercard:atm_conciliacion_admin '||
								' WHERE nomarchivo325 = ' ||"'"||vsNombreArchivo||"'"||
								' AND estatus != \"S\" '||
								' ;" >'|| 
								' /resplogifx/'||'ist_admin_atm_cnc.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #2
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'dbaccess intercard '||'/resplogifx/'||'ist_admin_atm_cnc.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #3
				LET vExecuteSQL = '';
				LET vExecuteSQL = "echo "||'"'|| "file '"|| '/resplogifx' ||
						"/" || 'ist_admin_atm.unl' || "' delimiter '|' "|| '5'||
							"; insert into tmp_atmAdmin" || ";"||'"'||' > carga_stat_admin.txt';
					SYSTEM vExecuteSQL;
				
				---Paso #4
				LET vExecuteSQL = '';
				LET vExecuteSQL = "dbload -d bditarjeta -c carga_stat_admin.txt -l err_carga_admin.log -n 1000 -k";
				SYSTEM vExecuteSQL;

								
				---Paso #5
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f /resplogifx/ist_admin_atm.unl';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f /resplogifx/ist_admin_atm_cnc.sql'; 
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  carga_stat_admin.txt';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  err_carga.log';
				SYSTEM vExecuteSQL;	
				
				
				
				SELECT 	statmv.stat_nombrearchivo,statmv.mv_secuencia,statmv.stat_autorizacion,statmv.fn_numtarjeta,atm.tarjeta,
						statmv.stat_numcuenta,statmv.mv_montomov,statmv.stat_monto,atm.monto_cheq_cred,
						statmv.mv_secuenciaextendida,stat_secuenciaextendida,statmv.mv_montorealrevfzda,statmv.mv_codreversa,
						statmv.stat_indicadordereversa,statmv.mv_prodind,statmv.mv_formato,statmv.mv_codtran,
						statmv.mv_metodocaptura,statmv.mv_trancajeropropio,statmv.mv_idterminal,
						statmv.mv_infreceptor,statmv.mv_esnacional,statmv.mv_pais,statmv.mv_fechahorainauth,
						statmv.stat_fechaconciliacion,statmv.stat_fecha,statmv.stat_hora,atm.producto,
						statmv.tbl_mov,statmv.tbl_stat06
					FROM tmp_paso_mov_vs_ist statmv
					full OUTER JOIN tmp_atmAdmin atm 
					ON statmv.fn_numtarjeta=atm.tarjeta
				INTO temp tbl_stat_mov_adim WITH NO LOG ;
				
				
				SELECT 	stat_nombrearchivo,mv_secuencia,stat_autorizacion,fn_numtarjeta,stat_numcuenta,mv_montomov,stat_monto,monto_cheq_cred,
						mv_secuenciaextendida,stat_secuenciaextendida,mv_montorealrevfzda,mv_codreversa,stat_indicadordereversa,
						mv_prodind,mv_formato,mv_codtran,mv_metodocaptura,mv_trancajeropropio,mv_idterminal,mv_infreceptor,
						mv_esnacional,mv_pais,mv_fechahorainauth,stat_fechaconciliacion,stat_fecha,stat_hora,
						producto,tbl_mov,tbl_stat06,
					CASE 
						WHEN fn_numtarjeta IS NULL then tarjeta
						ELSE fn_numtarjeta
					END final_numtarjeta,
					CASE 
						WHEN tarjeta IS NULL then 'F'
						ELSE 'V'
					END  tbl_movhis
					FROM tbl_stat_mov_adim	
				INTO temp tbl_stat_mov_adim2 WITH NO LOG ;
				
				SELECT  *,
					CASE 
						WHEN tbl_stat06 = 'V' AND tbl_movhis = 'F' AND tbl_mov = 'F' THEN 'NO CONCILIADO'
						WHEN tbl_stat06 = 'F' THEN 'NO CONCILIADO'
					ELSE 'OK'
					END Resultado_final,
										
					CASE
						WHEN mv_secuenciaextendida IS NULL THEN stat_secuenciaextendida
						ELSE mv_secuenciaextendida
					END fn_secuenciaextendida,
					CASE 
						WHEN producto IS NULL THEN (select creditodebito from intercard:bines where bin = substr(final_numtarjeta,1,6))
						ELSE producto
					END fn_producto
					
				FROM tbl_stat_mov_adim2 
				INTO temp tbl_stat_mov_adim3 WITH NO LOG ;	

				SELECT tbl1.final_numtarjeta,tbl1.fn_secuenciaextendida
					FROM tbl_stat_mov_adim3 tbl1
					JOIN intercard:atm_conciliacion_aplicativos tbl2
					ON tbl1.final_numtarjeta=tbl2.numtarjeta 
					AND tbl1.fn_secuenciaextendida = tbl2.secuenciaextendida
				INTO temp tb_duplicados_cnc WITH NO LOG ;
				
				DELETE FROM tbl_stat_mov_adim3 tbl3
					WHERE (tbl3.final_numtarjeta IN(SELECT tbl4.final_numtarjeta FROM tb_duplicados_cnc tbl4)
					AND tbl3.fn_secuenciaextendida IN (SELECT tbl4.fn_secuenciaextendida FROM tb_duplicados_cnc tbl4)
				);
								
				/* Cambio para duplicados de las llaves */
				
				FOREACH cursor_admin3 WITH HOLD FOR
				
					SELECT  stat_nombrearchivo,mv_secuencia,stat_autorizacion,final_numtarjeta,stat_numcuenta,
						mv_montomov,stat_monto,monto_cheq_cred,fn_secuenciaextendida,mv_montorealrevfzda,mv_codreversa,
						stat_indicadordereversa,mv_prodind,mv_formato,mv_codtran,mv_metodocaptura,mv_trancajeropropio,
						mv_idterminal,mv_infreceptor,mv_esnacional,mv_pais,mv_fechahorainauth,stat_fechaconciliacion,
						stat_fecha,stat_hora,fn_producto,tbl_mov,tbl_stat06,tbl_movhis,Resultado_final
						INTO
						vs_stat_nombrearchivo,vs_mv_secuencia,vs_stat_autorizacion,vs_final_numtarjeta,vs_stat_numcuenta,vs_mv_montomov,vs_stat_monto,vs_monto_cheq_cred,
						vs_fn_secuenciaextendida,vs_mv_montorealrevfzda,vs_mv_codreversa,vs_stat_indicadordereversa,vs_mv_prodind,vs_mv_formato,vs_mv_codtran,
						vs_mv_metodocaptura,vs_mv_trancajeropropio,vs_mv_idterminal,vs_mv_infreceptor,vs_mv_esnacional,vs_mv_pais,vs_mv_fechahorainauth,
						vs_stat_fechaconciliacion ,vs_stat_fecha,vs_stat_hora,vs_fn_producto,vs_tbl_mov,vs_tbl_stat06,vs_tbl_movhis,vs_Resultado_final 
					FROM tbl_stat_mov_adim3
					
					BEGIN;
					INSERT INTO intercard:atm_conciliacion_aplicativos(fecha_archivo, nombrearchivo,secuencia, autorizacion, numtarjeta, numcuenta, montomov,
								monto_stat06, monto_cheq_cred, secuenciaextendida, montorealrevfzda, codreversa, indicadordereversa, prodind, 
								formato, codtran, metodocaptura,trancajeropropio, idterminal, infreceptor, esnacional, pais, fechahorainauth,
								fechaconciliacion, fecha, hora, producto, tbl_mov, tbl_stat06,tbl_movhis, resultado_final)
						VALUES(vsFechaArchivo,vs_stat_nombrearchivo,vs_mv_secuencia,vs_stat_autorizacion,vs_final_numtarjeta,vs_stat_numcuenta,vs_mv_montomov,
								vs_stat_monto,vs_monto_cheq_cred,vs_fn_secuenciaextendida,vs_mv_montorealrevfzda,vs_mv_codreversa,vs_stat_indicadordereversa,
								vs_mv_prodind,vs_mv_formato,vs_mv_codtran,vs_mv_metodocaptura,vs_mv_trancajeropropio,vs_mv_idterminal,vs_mv_infreceptor,
								vs_mv_esnacional,vs_mv_pais,vs_mv_fechahorainauth,vs_stat_fechaconciliacion ,vs_stat_fecha,vs_stat_hora,vs_fn_producto,
								vs_tbl_mov,vs_tbl_stat06,vs_tbl_movhis,vs_Resultado_final );
					COMMIT;
				
				END FOREACH;
				
				
				
				IF ((vsConAdmin = '') AND (vsProceso = 'T')) THEN
				
				  EXECUTE PROCEDURE BdiTarjeta:"informix".sp_concreing_tmo (
					  vsNombreArchivo, 
					  vsFechaArchivo ,
					  vsFechaArchivoTMO,
					  vsFechaProcesoCnc
					)
					INTO CODIGO, MENSAJE_RPTA;
				END IF;
				
				UPDATE bditarjeta:td_archivos_conciliacion
					SET conadmin = 'V'
					WHERE nombrearchivo = vsNombreArchivo
				AND proceso='T';
				
				/* Tablas Fisicas */
				
				TRUNCATE TABLE tmp_paso_movimiento_cnc_atm DROP STORAGE;
				TRUNCATE TABLE tmp_paso_stat DROP STORAGE;
				TRUNCATE TABLE tmp_paso_reversos_stat DROP STORAGE;
				TRUNCATE TABLE tmp_paso_mov_vs_ist DROP STORAGE;
				TRUNCATE TABLE tmp_atmAdmin DROP STORAGE;
				
				
				/* Tablas temporales */
				
				DROP TABLE IF EXISTS tb_full_stat_mov; -- se queda 
				DROP TABLE IF EXISTS tb_full_stat_mov_2; --- se queda
				DROP TABLE IF EXISTS tbl_stat_mov_adim;  --- se queda
				DROP TABLE IF EXISTS tbl_stat_mov_adim2;   --- se queda
				DROP TABLE IF EXISTS tbl_stat_mov_adim3;   --- se queda
				DROP TABLE IF EXISTS tb_duplicados_cnc;   --- se queda
		
				--- Reporte de conciliacion entre movimiento vs el archivo IST con el Core Bancario
			
				
				LET vsql = ''; 	   
				LET vsql = 'echo "IDCajero|numtarjeta|NumCuenta|Fecha|Hora|Monto_mov|monto_stat06|monto_cheq_cred|secuencia|autorizacion|'||
								'secuenciaextendida|producto|tbl_mov|tbl_stat06|tbl_movhis|resultado_final"> '||
							RUTA_DESTINO||TIPO_PLANTILLA||LPAD (DAY(vsFechaArchivo),2,"0")||
							LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo) ||'.unl';
				system vsql;
				
			
				LET vsql = '';
				LET vsql = 'echo "SET ISOLATION TO DIRTY READ; ' ||
						   ' UNLOAD TO ' ||RUTA_DESTINO||TIPO_PLANTILLA||LPAD (DAY(vsFechaArchivo),2,"0")||LPAD (MONTH(vsFechaArchivo),2,"0")||
							year(vsFechaArchivo)||'_01.unl'||
						   ' SELECT trim(idterminal),numtarjeta,numcuenta,fecha,hora,montomov,monto_stat06,monto_cheq_cred,secuencia,'||
						   ' autorizacion,secuenciaextendida,producto,tbl_mov,tbl_stat06,tbl_movhis,resultado_final'||
						   ' from intercard:atm_conciliacion_aplicativos '||
						   ' WHERE nombrearchivo = ' ||"'"|| vs_stat_nombrearchivo||"'"||
						   ';">'||RUTA_DESTINO||TIPO_PLANTILLA||LPAD (DAY(vsFechaArchivo),2,"0")||LPAD (MONTH(vsFechaArchivo),2,"0")||
							year(vsFechaArchivo)||'.sql'; 
				system vsql;
				
				LET vsql ='';
				LET vsql= 'chmod 777 ' ||RUTA_DESTINO||TIPO_PLANTILLA||
						  LPAD (DAY(vsFechaArchivo),2,"0")||LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo)||'.sql';
				system vsql;
				
				LET vsql ='';
				LET vsql= 'dbaccess intercard ' ||RUTA_DESTINO||TIPO_PLANTILLA||LPAD (DAY(vsFechaArchivo),2,"0")||
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
			
				--- Reporte de Totales por cajero de la tabla de atm_conciliacion_aplicativos
				
				SELECT fecha_archivo,idterminal, COUNT(*) AS conteo_movs, SUM(montomov) AS monto_movs
					FROM intercard:atm_conciliacion_aplicativos  
					WHERE nombrearchivo = vs_stat_nombrearchivo
					AND tbl_mov ='V'
				GROUP BY 1,2 INTO TEMP tmp_sum_movs WITH NO LOG;


				SELECT fecha_archivo,idterminal, COUNT(*) AS conteo_stat06, SUM(monto_stat06) AS monto_stat06
					FROM intercard:atm_conciliacion_aplicativos  
					WHERE nombrearchivo = vs_stat_nombrearchivo
					AND tbl_stat06 ='V'
				GROUP BY 1,2 INTO TEMP tmp_sum_stat WITH NO LOG;


				SELECT fecha_archivo,idterminal, COUNT(*) AS tbl_movhis, SUM(monto_cheq_cred) AS monto_cheq_cred
					FROM intercard:atm_conciliacion_aplicativos  
					WHERE nombrearchivo = vs_stat_nombrearchivo
					  AND tbl_movhis ='V'
				GROUP BY 1,2 INTO TEMP tmp_sum_core WITH NO LOG;
			
				
				SELECT movs.fecha_archivo,movs.idterminal,movs.conteo_movs, movs.monto_movs, ist.conteo_stat06, ist.monto_stat06,core.tbl_movhis, core.monto_cheq_cred  
					from tmp_sum_movs movs INNER JOIN tmp_sum_stat ist ON(movs.idterminal = ist.idterminal) 
					LEFT join tmp_sum_core core 
					ON(movs.idterminal = core.idterminal)
				INTO TEMP tmp_atm_total WITH NO LOG;
				
				INSERT INTO bditarjeta:cajeros_atm_totales  
				SELECT fecha_archivo,idterminal,Conteo_movs,monto_movs,conteo_stat06,monto_stat06,tbl_movhis,monto_cheq_cred
				FROM tmp_atm_total;
				
				LET vsql = ''; 	   
				LET vsql = 'echo "IDCajero|Total de movs|Monto_movs|Total de IST|'||
						   'Monto_IST|Total de movhis|Monto_cheq_cred"> '||
							RUTA_DESTINO||TIPO_PLANTILLA_TOTAL||LPAD (DAY(vsFechaArchivo),2,"0")||
							LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo) ||'.unl';
				system vsql;
				
				LET vsql = '';
				LET vsql = 'echo "SET ISOLATION TO DIRTY READ; ' ||
						   ' UNLOAD TO ' ||RUTA_DESTINO||TIPO_PLANTILLA_TOTAL||LPAD (DAY(vsFechaArchivo),2,"0")||LPAD (MONTH(vsFechaArchivo),2,"0")||
							year(vsFechaArchivo)||'_01.unl'||
						   ' select trim(idterminal),Conteo_movs,Sum_monto_movs,conteo_IST,Sum_monto_IST,conteo_movhis,Sum_monto_cheq_cred from cajeros_atm_totales;'||
						   ' "> ' ||RUTA_DESTINO||TIPO_PLANTILLA_TOTAL||LPAD (DAY(vsFechaArchivo),2,"0")||LPAD (MONTH(vsFechaArchivo),2,"0")||
							year(vsFechaArchivo)||'.sql'; 
				system vsql;
				
				LET vsql ='';
				LET vsql= 'chmod 777 ' ||RUTA_DESTINO||TIPO_PLANTILLA_TOTAL||
						  LPAD (DAY(vsFechaArchivo),2,"0")||LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo)||'.sql';
				system vsql;
				
				LET vsql ='';
				LET vsql= 'dbaccess bditarjeta ' ||RUTA_DESTINO||TIPO_PLANTILLA_TOTAL||LPAD (DAY(vsFechaArchivo),2,"0")||
						   LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo)||'.sql';
				system vsql;
				
				LET vsql = '';
				LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_TOTAL||LPAD (DAY(vsFechaArchivo),2,"0")||LPAD(MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo)||'.sql';
				system vsql;
				
				LET vsql = '';
				LET vsql = "sed 's/|$//g' "||RUTA_DESTINO||TIPO_PLANTILLA_TOTAL||LPAD (DAY(vsFechaArchivo),2,"0")||
						   LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo)||"_01.unl >>"||RUTA_DESTINO||TIPO_PLANTILLA_TOTAL||
						   LPAD (DAY(vsFechaArchivo),2,"0")||LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo)||".unl";
				system vsql;
		
				LET vsql = '';
				LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_TOTAL||LPAD (DAY(vsFechaArchivo),2,"0")||LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo)||'_01.unl';
				system vsql;
				
				DROP TABLE IF EXISTS tmp_sum_movs;
				DROP TABLE IF EXISTS tmp_sum_stat;
				DROP TABLE IF EXISTS tmp_sum_core;
				DROP TABLE IF EXISTS tmp_atm_total;
				TRUNCATE TABLE cajeros_atm_totales;
			
			 
			END FOREACH; -- CICLO DE OBTENCION DE REGISTROS	
		RETURN CODIGO, MENSAJE_RPTA;
	END
END PROCEDURE
;