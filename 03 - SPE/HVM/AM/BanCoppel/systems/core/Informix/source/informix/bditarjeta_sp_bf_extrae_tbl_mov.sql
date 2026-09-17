CREATE PROCEDURE "informix".sp_bf_extrae_tbl_mov (psFechaInicio VARCHAR(10) , psFechaFin VARCHAR(10))

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
		
			--SET DEBUG FILE TO "/RESPALDOSNEW/Buen_Fin/bf2023_mov_debug.out";
			--TRACE ON;
			
				/* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
				
				LET CODIGO					= '00000';
				LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
				LET vdFechaInicio			= CURRENT;
				LET vdFechaFin				= CURRENT;
				LET RUTA_DESTINO	 		= '/RESPALDOSNEW/';
				LET TIPO_PLANTILLA	 		= '';
				LET vsql					= '';
				LET vExecuteSQL				= '';

				
			--SET ISOLATION TO dirty READ;
			--SET LOCK MODE TO WAIT 3;	
	
				/* Se da formato de fechahorainauth como se encuentra en movimiento*/
			
			LET vdFechaInicio = psFechaInicio || ' 00:00:00.00000';
			LET vdFechaFin 	  = psFechaFin || ' 23:59:59.99999';
							
				/* SE GENERA TABLA TEMPORAL CON LOS REGISTROS DE LA TABLA DE MOVIMIENTO */
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo "UNLOAD TO '||RUTA_DESTINO||'bf_movimiento.unl'||
		                          ' SELECT secuencia,numtarjeta,NVL (monto ,0 ) AS monto ,secuenciaextendida,fechahorainauth,referencia,prodind,codigoiso,'||
		                          ' movreversado,esnacional,movconciliado,formato,transaccionorigen,NVL (tipotransaccionposdigitada ,\"\" ) AS tipotransaccionposdigitada '||
		                          ' FROM Intercard:movimiento '||
		                          ' WHERE fechahorainauth BETWEEN '||"'"|| vdFechaInicio||"'"||' AND '||"'"|| vdFechaFin ||"'"||
		                          ' AND prodind = \"02\"		 		 	'||
		                          ' AND formato = \"0200\"  	 	 	 	'||
		                          ' AND codigoiso = \"00\"  	 	 	 	'||
		                          ' AND esnacional = \"V\" 		 	 	'||
		                          ' AND transaccionorigen = \"1234\" 	 	'||
		                          ' AND movreversado = \"F\"				'||							
		                          ' AND movconciliado IN (\"P\",\"V\")	'||
		                          ' AND monto >= 250	'||
								  'AND SUBSTRING(numtarjeta FROM 1 FOR 8) IN (SELECT bin FROM bditarjeta:bines_buenfin WHERE participa = \"V\") '||
		                          'AND pcc <> \"02\" '|| --Se excluyen cargos recurrentes
		                          ';" >'|| 
		        RUTA_DESTINO||'bf_mov.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #2
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'dbaccess intercard  '||RUTA_DESTINO||'bf_mov.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #3
				LET vExecuteSQL = '';
				LET vExecuteSQL = "echo "||'"'|| "file '"|| RUTA_DESTINO ||
								  'bf_movimiento.unl' || "' delimiter '|' "|| '14'||
									"; insert into tbl_bf_movimientos_sorteo" || ";"||'"'||' > carga_movimientos.txt';
				SYSTEM vExecuteSQL;
				
				
				---Paso #4
				LET vExecuteSQL = '';
				LET vExecuteSQL = "dbload -d bditarjeta -c carga_movimientos.txt -l err_carga_mov.log -n 5000 -r";
				SYSTEM vExecuteSQL;			
				

				---Paso #5
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f '||RUTA_DESTINO||'bf_movimiento.unl';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f '||RUTA_DESTINO||'bf_mov.sql'; 
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  carga_movimientos.txt';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  err_carga.log';
				SYSTEM vExecuteSQL;

		RETURN CODIGO, MENSAJE_RPTA;
	END
END PROCEDURE;