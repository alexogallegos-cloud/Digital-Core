CREATE PROCEDURE "informix".sp_actualizadatoscontacto_bei_historico(pIdUsuario VARCHAR(9),
										   pCel VARCHAR(15),
										   pCiaCel INT,
										   pEmail VARCHAR(80),
                                           pidBitacoraAdmin INTEGER)
RETURNING CHAR(5);

	DEFINE sql_err INT;
	DEFINE cCod_ret CHAR(5);

	--variables para registro en historico
    DEFINE vid_usuario              	INTEGER;
	DEFINE vnombre                  	CHAR(150);
	DEFINE vtel_celular             	CHAR(15);
	DEFINE vcia_cel                 	SMALLINT;
	DEFINE ve_mail                  	CHAR(100);
	DEFINE vactivo                  	BOOLEAN;
	DEFINE vid_ultima_oper          	SMALLINT;
	DEFINE vfecha_bloqueo           	DATETIME YEAR to SECOND;
	DEFINE vfecha_bloqueo_camb_pass 	DATETIME YEAR to SECOND;
	DEFINE vfecha_bloqueo_camb_pregs	DATETIME YEAR to SECOND;
	DEFINE vtipo_bloqueo_temp_pass  	SMALLINT;
	DEFINE vtipo_bloqueo_temp_resp  	SMALLINT;

	DEFINE vcomienza  INTEGER;
	DEFINE vcuantos   INTEGER;
	DEFINE vregistros INTEGER;
	DEFINE vcontador  INTEGER;
	
	--SET DEBUG FILE TO "/home/informix/BereniceOut/sp_actualizadatoscontacto_bei_historico.out";
    --TRACE ON; 
	
	LET cCod_ret = '00000';
	
	LET vcontador = -1;
	LET vcuantos = 0;
	LET vcomienza   = -1;	
	LET vregistros = 1000;
	
	--****************************************************************************************************
    -- NOTA: para el requerimiento de bitacora de administradores
    -- AUTOR: Solser
    -- FECHA: 05/06/2018
	-- FECHA LIBERACIÃÂN PRODUCCIÃÂN: 07-AGOSTO-2018
	-- BASE DE DATOS: BDIBEI
	
	-- MODIFICACIÃN: Se actualiza el campo fecha_mov_hist por el correcto nombre del campo f_mov_historico
	-- MODIFICO: Berenice Noriega
	-- Fecha: 22 Octubre 2018
	-- Fecha LiberaciÃ³n a produccion: 25-Octubre-2018
	--***************************************************************************************************


	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret;
			END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ;
		
	
		FOREACH WITH HOLD
				
			SELECT id_usuario, nombre, tel_celular, cia_cel, e_mail, 
					activo, id_ultima_oper, fecha_bloqueo, fecha_bloqueo_camb_pass, 
					fecha_bloqueo_camb_pregs, tipo_bloqueo_temp_pass, tipo_bloqueo_temp_resp
			INTO  vid_usuario, vnombre, vtel_celular, vcia_cel, ve_mail,
					vactivo, vid_ultima_oper, vfecha_bloqueo, vfecha_bloqueo_camb_pass, 
					vfecha_bloqueo_camb_pregs, vtipo_bloqueo_temp_pass, vtipo_bloqueo_temp_resp  
			FROM bdibei:"informix".bei_datos_usuario WHERE id_usuario = pIdUsuario

			IF vcomienza = -1 THEN
				BEGIN WORK;
				LET vcontador = 1;
				LET vcomienza = 0;
			END IF;
					
					
			INSERT INTO bdibei:"informix".bei_datos_usuario_historico(id_historico, id_bitacora_admin, id_usuario, nombre, tel_celular, cia_cel, e_mail, 
					activo, id_ultima_oper, fecha_bloqueo, fecha_bloqueo_camb_pass, fecha_bloqueo_camb_pregs, tipo_bloqueo_temp_pass, tipo_bloqueo_temp_resp, f_mov_historico) 
				VALUES(0, pidBitacoraAdmin, vid_usuario, vnombre, vtel_celular, vcia_cel, ve_mail, 
					vactivo, vid_ultima_oper, vfecha_bloqueo, vfecha_bloqueo_camb_pass, 
					vfecha_bloqueo_camb_pregs, vtipo_bloqueo_temp_pass, vtipo_bloqueo_temp_resp, CURRENT YEAR TO SECOND);
		
			IF (vcontador = vregistros) THEN
				COMMIT WORK;
				LET vcontador = 0;							
				LET vcomienza = -1;
			ELSE
				LET vcontador = vcontador + 1 ;						
			END IF;	

		END FOREACH;
		
		IF (vcontador > 1) THEN
			COMMIT WORK;
			LET vcontador = 0;							
			LET vcomienza = -1;							
		END IF;	
		
		RETURN cCod_ret;
	END;
END PROCEDURE;