CREATE PROCEDURE "informix".sp_bf_extrae_td_movs_cnc (psFechaInicio VARCHAR(10),psFechaFin VARCHAR(10))

		RETURNING VARCHAR (5)   AS CODIGO, VARCHAR (150) AS MENSAJE_RPTA;
		
		 /*  DEFINICION DE VARIABLES */

			-- CONTROL DE ERRORES
			
		    DEFINE  SQL_ERR          INTEGER;
			DEFINE  ISAM_ERR         INTEGER;
			DEFINE  ERROR_INFO       VARCHAR(80);
			
			--CONTROL GENERAL
			
			DEFINE CODIGO				 CHAR (6);
			DEFINE MENSAJE_RPTA			 CHAR (80);
			DEFINE vdFechaInicio		 DATETIME YEAR TO FRACTION (3);
			DEFINE vdFechaFin		     DATETIME YEAR TO FRACTION (3);
			DEFINE RUTA_DESTINO 		 VARCHAR(80);
			DEFINE TIPO_PLANTILLA		 VARCHAR(30);
			DEFINE vsql					 CHAR(1150);
			DEFINE vExecuteSQL 			 LVARCHAR(1500);

	BEGIN	
		
		ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
				
		  LET CODIGO    = SQL_ERR;
		  LET MENSAJE_RPTA  = ERROR_INFO;
		  
		  RETURN CODIGO, MENSAJE_RPTA;
		  
		END EXCEPTION;
		
			--SET DEBUG FILE TO "/home/c98188925/buenfin_2019/debug/bf_mov_cnc_debug.out";
			--TRACE ON;
			
				/* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
				
				LET CODIGO					= '00000';
				LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
				LET vdFechaInicio			= CURRENT;
				LET vdFechaFin			    = CURRENT;
				LET RUTA_DESTINO	 		= '/RESPALDOSNEW/';
				LET TIPO_PLANTILLA	 		= '';
				LET vsql					= '';
				LET vExecuteSQL				= '';

				
			SET ISOLATION TO dirty READ;
			SET LOCK MODE TO WAIT 3;	
	
				/* Se da formato de fechahorainauth como se encuentra en movimiento*/
			
			LET vdFechaInicio = psFechaInicio || ' 00:00:00.000';
			LET vdFechaFin    = psFechaFin    || ' 23:59:59.999';
							
				/* SE GENERA TABLA TEMPORAL CON LOS REGISTROS DE LA TABLA DE MOVIMIENTO */
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo "UNLOAD TO '||RUTA_DESTINO||'bf_td_mov_cnc.unl'||
							' SELECT bf.secuencia,bf.numtarjeta,cnc.numtarjeta,bf.monto,cnc.secuencia_extendida,bf.secuenciaextendida,'||
							' cnc.referencia23_325,bf.fechahorainauth,bf.referencia,bf.prodind,bf.codigoiso,bf.movreversado,'||
							' bf.esnacional,bf.movconciliado,bf.formato,bf.transaccionorigen,bf.tipotransaccionposdigitada'||
							' FROM td_movimientos_conciliacion cnc'||
							' INNER JOIN  tbl_bf_movimientos_sorteo bf'||
							' ON bf.numtarjeta = cnc.numtarjeta'||
							' AND bf.secuenciaextendida = cnc.secuencia_extendida'||
						  --  ' WHERE cnc.fechacarga BETWEEN '||"'"|| vdFechaInicio||"'"||' AND TODAY'||       
							' WHERE cnc.fechacarga BETWEEN  '||"'"|| vdFechaInicio||"'"||' AND '||"'"|| vdFechaFin ||"'"||							
							' AND cnc.archivo_origen IN (\"VND\",\"VNC\")'||
							' AND cnc.tipo_conciliacion NOT IN (3,4,6)   '||
							';" >'|| 
							RUTA_DESTINO||'bf_mov_cnc.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #2
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'dbaccess bditarjeta '||RUTA_DESTINO||'bf_mov_cnc.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #3
				LET vExecuteSQL = '';
				LET vExecuteSQL = "echo "||'"'|| "file '"|| RUTA_DESTINO ||
								  'bf_td_mov_cnc.unl' || "' delimiter '|' "|| '17'||
									"; insert into tbl_bf_movs_cnc_sorteo" || ";"||'"'||' > carga_td_mov_cnc.txt';
				SYSTEM vExecuteSQL;
				
				
				---Paso #4
				LET vExecuteSQL = '';
				LET vExecuteSQL = "dbload -d bditarjeta -c carga_td_mov_cnc.txt -l err_carga_mov.log -n 1000 -r";
				SYSTEM vExecuteSQL;			
				

				---Paso #5
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f '||RUTA_DESTINO||'bf_movimiento.unl';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f '||RUTA_DESTINO||'bf_mov.sql'; 
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  carga_td_mov_cnc.txt';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  err_carga.log';
				SYSTEM vExecuteSQL;

		RETURN CODIGO, MENSAJE_RPTA;
	END
END PROCEDURE;