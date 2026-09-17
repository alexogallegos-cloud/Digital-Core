CREATE PROCEDURE "informix".sp_bf_registrar_bitacora( pNumTarjeta VARCHAR(16), pCodigoRetorno CHAR(5), pMensajeRespuesta VARCHAR(120) )
   
BEGIN
    INSERT INTO "informix".bitacora_sorteo_buen_fin (tarjeta, cod_retorno, mensaje_respuesta, fecharegistro) 
        VALUES (pNumTarjeta, pCodigoRetorno, pMensajeRespuesta, current);
END
END PROCEDURE
DOCUMENT
'AUTOR: Armando Garcia Ortiz',
'Proyecto: Sorteo El Buen Fin',
'Fecha de creacion: 30.noviembre.2018',
'Descripcion: Registrar el numero de tarjeta, codigo de respuesta y descripcion del error',
'Base de datos: bditarjeta'
;

CREATE PROCEDURE "informix".sp_conciliacion_finalizada_atm_stat06
(
	p_nombrearchivo                       	VARCHAR(30),
	p_archivo_origen                      	VARCHAR(3),
	p_fecha_archivo                       	DATE,
	p_num_registros325                    	INTEGER,
	p_monto325                            	MONEY,
	p_fecha_proceso                       	DATE,
	p_fecha_hora_transferencia            	DATETIME YEAR to FRACTION(5),
	p_fecha_hora_ini_proceso              	DATETIME YEAR to FRACTION(5),
	p_fecha_hora_carga_archivo            	DATETIME YEAR to FRACTION(5),
	p_fecha_hora_carga_tabla              	DATETIME YEAR to FRACTION(5),
	p_fecha_hora_ini_concilia_reg         	DATETIME YEAR to FRACTION(5),
	p_fecha_hora_fin_concilia_reg         	DATETIME YEAR to FRACTION(5),
	p_fecha_hora_fin_proceso              	DATETIME YEAR to FRACTION(5),
	p_fecha_hora_fin_conadminatm_intercard	DATETIME YEAR to FRACTION(5),
	p_transferencia                       	VARCHAR(1),
	p_carga                               	VARCHAR(1),
	p_conciliacion_admin                  	VARCHAR(1),
	p_traspaso_historico                  	VARCHAR(1),
	p_num_cargo                           	INTEGER,
	p_monto_cargo                         	MONEY,
	p_num_abono                           	INTEGER,
	p_monto_abono                         	MONEY,
	p_proceso                             	VARCHAR(1) 
)
	
    DEFINE vCodigoRetorno   	VARCHAR(10);
	DEFINE vMensajeRetorno  	VARCHAR(255);
    DEFINE sql_err    			INTEGER;
    DEFINE isam_err   			INTEGER;
    DEFINE error_info 			CHAR(40);
	
	--SET DEBUG FILE TO "/RESPALDOSNEW/debug_sp_tr_tarjeta_update.out";
    --TRACE ON;

    LET vCodigoRetorno    		= '00000';          
    LET vMensajeRetorno    		= '';          
    LET sql_err					= 0;          
    LET isam_err				= 0;        
    LET error_info				= '';

	BEGIN

		-- Manejo del error
		ON EXCEPTION SET sql_err, isam_err, error_info
				
        --SET DEBUG FILE TO "/RESPALDOSNEW/sp_tr_tarjeta_update_error.out" WITH APPEND;
        --TRACE ON;
	
			IF sql_err <> 0 THEN
				
				LET vCodigoRetorno = sql_err;
				LET vMensajeRetorno = isam_err|| ' ' ||error_info;
				
				INSERT INTO "informix".td_bitacora_conciliacion_atm_stat06(elemento, fecha_hora, actividad, cve_usuario) 
				VALUES (0, CURRENT,vCodigoRetorno || vMensajeRetorno, 'sysconau');		
				
			END IF;
			
		END EXCEPTION;
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF EXISTS ( SELECT 1 FROM "informix".td_archivos_conciliacion WHERE nombrearchivo = p_nombrearchivo ) THEN

			UPDATE "informix".td_archivos_conciliacion
			SET num_registros325 = p_num_registros325, 
				monto325 = p_monto325, 
				fecha_proceso = p_fecha_proceso, 
				fecha_hora_transferencia = p_fecha_hora_transferencia,
				fecha_hora_ini_proceso = p_fecha_hora_ini_proceso,
				fecha_hora_carga_archivo = p_fecha_hora_carga_archivo,
				fecha_hora_carga_tabla = p_fecha_hora_carga_tabla,
				fecha_hora_ini_concilia_reg = p_fecha_hora_ini_concilia_reg,
				fecha_hora_fin_concilia_reg = p_fecha_hora_fin_concilia_reg,
				fecha_hora_fin_proceso = p_fecha_hora_fin_proceso,
				fecha_hora_gen_conadmin = p_fecha_hora_fin_conadminatm_intercard,
				transferencia = p_transferencia,
				carga = p_carga,
				conadmin = p_conciliacion_admin,
				traspaso_historico = p_traspaso_historico,
				num_cargo = p_num_cargo,
				monto_cargo = p_monto_cargo,
				num_abono = p_num_abono,
				monto_abono = p_monto_abono,
				proceso = p_proceso
			WHERE nombrearchivo = p_nombrearchivo;
                      			
		ELSE 
		
			INSERT INTO "informix".td_archivos_conciliacion(nombrearchivo, archivo_origen, fecha_archivo, num_registros325, monto325, fecha_proceso, fecha_hora_transferencia, fecha_hora_ini_proceso, fecha_hora_carga_archivo, fecha_hora_carga_tabla, fecha_hora_ini_concilia_reg, fecha_hora_fin_concilia_reg, fecha_hora_fin_proceso, fecha_hora_gen_conadmin, transferencia, carga, conadmin, traspaso_historico, num_cargo, monto_cargo, num_abono, monto_abono, proceso)
			VALUES
			(
				p_nombrearchivo,                       
				p_archivo_origen,                      
				p_fecha_archivo,                       
				p_num_registros325,                    
				p_monto325,                            
				p_fecha_proceso,                       
				p_fecha_hora_transferencia,            
				p_fecha_hora_ini_proceso,              
				p_fecha_hora_carga_archivo,            
				p_fecha_hora_carga_tabla,              
				p_fecha_hora_ini_concilia_reg,         
				p_fecha_hora_fin_concilia_reg,         
				p_fecha_hora_fin_proceso,              
				p_fecha_hora_fin_conadminatm_intercard,
				p_transferencia,                       
				p_carga,                               
				p_conciliacion_admin,                  
				p_traspaso_historico,                  
				p_num_cargo,                           
				p_monto_cargo,                         
				p_num_abono,                           
				p_monto_abono,                         
				p_proceso                             
			);
		END IF;
	END;
END PROCEDURE;