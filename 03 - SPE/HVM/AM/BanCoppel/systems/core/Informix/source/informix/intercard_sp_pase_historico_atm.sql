CREATE PROCEDURE "informix".sp_pase_historico_atm()

RETURNING CHAR(5),INTEGER;
-----------------------------------------------------------------------------------
--Definicion de variables del proceso, operaciones con fechas y manejo de errores--
-----------------------------------------------------------------------------------
    DEFINE vcodret1         		CHAR(5);
    DEFINE error_info       		CHAR(50);
    DEFINE sql_err          		INTEGER;
    DEFINE isam_err         		INTEGER;
    DEFINE vcontador1       		INTEGER;
    DEFINE vcontador2       		INTEGER;
    DEFINE vRegistros       		INTEGER;
    DEFINE vId              		INTEGER;
    DEFINE vfecha_oper      		DATE;
    DEFINE vsecuencia 				VARCHAR(7) ;
    DEFINE vnumtarjeta 				VARCHAR(16);
    DEFINE vfechalocaltransaccion 	VARCHAR(4);
    DEFINE vhoralocaltransaccion 	VARCHAR(6);
	
	/* DEFINICION DE VARIABLES PARA CALCULAR EL RANGO DE EXTRACCION */
	
	DEFINE vsFechaInicio	CHAR (10);
	DEFINE vsFechaFin	 	CHAR (10);
	DEFINE vsFecha_Inicio	DATETIME YEAR TO FRACTION (5);
	DEFINE vsFecha_Fin	 	DATETIME YEAR TO FRACTION (5);
	DEFINE vsDias			VARCHAR(3);
	DEFINE vExecuteSQL 		LVARCHAR(2000);
	
	/* DEFINICION VARIABLES PARA INSERT Y DELETE DE REGISTROS */
	
	DEFINE vsKeyx 				INTEGER;
	DEFINE vsFechaconciliacion 	DATETIME YEAR TO FRACTION (5);
	DEFINE vsArchivoorigen		VARCHAR (3);
	DEFINE vsNombrearchivo		VARCHAR (23);
	DEFINE vsNumtarjeta			VARCHAR (16);
	DEFINE vsAutorizacion		VARCHAR (7);
	DEFINE vsnumero				VARCHAR (1);
	
	

---------------------------
--Inicializando variables--
---------------------------
        --SET DEBUG FILE TO "/home/c98188925/pase_historico/debug/sp_pase_historico_atm.out"; --Se genera log en un archivo .out
        --TRACE ON;

        LET vcodret1        		= '00000';
        LET sql_err         		= 0;
        LET isam_err        		= 0;
        LET vcontador1      		= -1;
        LET vcontador2      		= 0;
        LET vRegistros      		= 0;
        LET vId             		= 0;
        LET vsecuencia      		='';
        LET vnumtarjeta     		='';
        LET vfechalocaltransaccion 	='';
        LET vhoralocaltransaccion  	='';
		
		/* DEFINICION DE VARIABLES PARA CALCULAR EL RANGO DE EXTRACCION */
		
        LET vsFechaInicio  	='';
        LET vsFechaFin  	='';
        LET vsFecha_Inicio 	= CURRENT;
        LET vsFecha_Fin  	= CURRENT;
        LET vsDias  		='';
		
		/* DEFINICION VARIABLES PARA INSERT Y DELETE DE REGISTROS */
		
		LET vsKeyx 					= 0;	
		LET vsFechaconciliacion 	= CURRENT;
		LET vsArchivoorigen			='';
		LET vsNombrearchivo			='';
        LET vsNumtarjeta			='';
        LET vsAutorizacion			='';
        LET vsnumero				='';

		
        /*Incia SP*/
	BEGIN

		ON EXCEPTION SET sql_err, isam_err
				IF sql_err <> 0 THEN
						LET vcodret1 = sql_err;
						LET vcontador1 = isam_err;
						RETURN vcodret1, vcontador1;
				END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		SELECT valor INTO vsDias FROM bditarjeta:td_param_conciliacion_concreing WHERE codigo='753';


		SELECT TO_CHAR (min(fechaconciliacion ), '%Y-%m-%d') AS fecha_ini,
		   TO_CHAR (min(fechaconciliacion) + vsDias UNITS DAY, '%Y-%m-%d') AS fecha_fin
		   INTO vsFechaInicio,vsFechaFin
		FROM conciliacion_atm_stat06 ;
		
		IF ( (SELECT COUNT(*) FROM intercard:systables WHERE tabname = 'tbl_pase_historico_atm') = 1 ) THEN

			TRUNCATE TABLE tbl_pase_historico_atm DROP STORAGE;

		END IF;
		
		--------------------------------
		-- ExtracciÃ³n de transacciones--
		--------------------------------
		
		LET vsFecha_Inicio = vsFechaInicio || ' 00:00:00.00000';
		LET vsFecha_Fin    = vsFechaFin || ' 00:59:59.99999';
					
					
					/* SE DESCARGA TRANSACCIONES A PASAR A HISTORICO */

					
					LET vExecuteSQL = '';
					LET vExecuteSQL = 'echo "UNLOAD TO /RESPALDOSNEW/cnc_stat06.unl'||
					' SELECT keyx,fechaconciliacion,archivoorigen,nombrearchivo,numtarjeta,autorizacion,0'||
								' FROM Intercard:conciliacion_atm_stat06 '||
								' WHERE fechaconciliacion BETWEEN '||"'"|| vsFecha_Inicio||"'"||' AND '||"'"|| vsFecha_Fin ||"'"||
								';" >'|| 
								' /RESPALDOSNEW/'||'mov_cnc_atm.sql';
					SYSTEM vExecuteSQL;
					
					---Paso #2
					LET vExecuteSQL = '';
					LET vExecuteSQL = 'dbaccess intercard '||'/RESPALDOSNEW/'||'mov_cnc_atm.sql';
					SYSTEM vExecuteSQL;
					
					---Paso #3
					LET vExecuteSQL = '';
					LET vExecuteSQL = "echo "||'"'|| "file '"|| '/RESPALDOSNEW' ||
							"/" || 'cnc_stat06.unl' || "' delimiter '|' "|| '7'||
								"; insert into tbl_pase_historico_atm" || ";"||'"'||' > carga_mov_stat.txt';
						SYSTEM vExecuteSQL;
					
					---Paso #4
					LET vExecuteSQL = '';
					LET vExecuteSQL = "dbload -d intercard -c carga_mov_stat.txt -l err_carga.log -n 1000 -k";
					SYSTEM vExecuteSQL;			
					
					
	
						---Paso #5
					LET vExecuteSQL = '';
					LET vExecuteSQL = 'rm  -f /RESPALDOSNEW/cnc_stat06.unl';
					SYSTEM vExecuteSQL;
					
					LET vExecuteSQL = '';
					LET vExecuteSQL = 'rm  -f /RESPALDOSNEW/mov_cnc_atm.sql'; 
					SYSTEM vExecuteSQL;
					
					LET vExecuteSQL = '';
					LET vExecuteSQL = 'rm -f  carga_mov_stat.txt';
					SYSTEM vExecuteSQL;
					
					
					LET vExecuteSQL = '';
					LET vExecuteSQL = 'rm -f  err_carga.log';
					SYSTEM vExecuteSQL;
		
	

		FOREACH WITH HOLD
		

			SELECT  keyx,fechaconciliacion,archivoorigen,nombrearchivo,numtarjeta,autorizacion,numero 
			INTO    vsKeyx,vsFechaconciliacion,vsArchivoorigen,vsNombrearchivo,vsNumtarjeta,vsAutorizacion,vsnumero
			FROM "informix".tbl_pase_historico_atm where numero=0

			IF vcontador1 = -1 THEN
			LET vcontador1 = 0;
			BEGIN WORK;
			END IF;

			/********************* INSERT A CONCILIACION_ATM_STAT06_HIS *********************************************************************************************/
			
			INSERT INTO intercard:conciliacion_atm_stat06_his (
				keyx, fechaconciliacion, archivoorigen, nombrearchivo, emisor, numcajero, numtarjeta, numcuenta, indicadordereversa, descripcion, respuesta, codigoiso, 
				secuencia, fecha, hora, orden, red, monto, dolares, comisionsurcharge, donativo, emp, autorizacion, compania, comision_loyaltyfee, comision_usolinea, 
				pos_entry_mode, service_code, terminal_capability, arqc, arpc, arqc_verify)
				SELECT 
				keyx, fechaconciliacion, archivoorigen, nombrearchivo, emisor, numcajero, numtarjeta, numcuenta, indicadordereversa, descripcion, respuesta, codigoiso, 
				secuencia, fecha, hora, orden, red, monto, dolares, comisionsurcharge, donativo, emp, autorizacion, compania, comision_loyaltyfee, comision_usolinea, 
				pos_entry_mode, service_code, terminal_capability, arqc, arpc, arqc_verify
				FROM intercard:conciliacion_atm_stat06 
				WHERE keyx = vsKeyx AND fechaconciliacion = vsFechaconciliacion  
			AND numtarjeta = vsNumtarjeta and autorizacion = vsAutorizacion ;
			

			/********************************************************************************************************************************************************/
			
			DELETE FROM "informix".conciliacion_atm_stat06
				WHERE keyx = vsKeyx 
				AND fechaconciliacion = vsFechaconciliacion  
				AND numtarjeta = vsNumtarjeta 
			AND autorizacion = vsAutorizacion ;

			UPDATE "informix".tbl_pase_historico_atm 
				SET numero =1 
				WHERE keyx = vsKeyx 
				AND fechaconciliacion = vsFechaconciliacion  
				AND numtarjeta = vsNumtarjeta 
			AND autorizacion = vsAutorizacion;

			LET vcontador1 = vcontador1 + 1;
			LET vcontador2 = vcontador2 + 1;

			IF vcontador2 >= 10 THEN
				LET vcontador2 = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;

		END FOREACH;
		
			IF vcontador1 > -1 THEN
			COMMIT WORK;
			END IF;

			RETURN vcodret1, vcontador1;
			
		END;

	
END PROCEDURE;