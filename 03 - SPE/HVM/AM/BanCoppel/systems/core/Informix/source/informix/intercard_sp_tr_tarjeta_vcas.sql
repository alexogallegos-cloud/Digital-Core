CREATE PROCEDURE "informix".sp_tr_tarjeta_vcas(pNumtarjeta VARCHAR(16), pCodstatustarjeta VARCHAR(3), pCodstatusasignada VARCHAR(3), pFechaasignacion DATETIME YEAR TO FRACTION(5), pUsuarioModificacion VARCHAR(8))
	
    DEFINE vCodigoRetorno   		VARCHAR(10);
	DEFINE vMensajeRetorno  		VARCHAR(255);
    DEFINE sql_err    				INTEGER;
    DEFINE isam_err   				INTEGER;
    DEFINE error_info 				CHAR(40);
 	DEFINE vNumtarjeta 				CHAR(16);
 	DEFINE vFechaultmodif 			DATETIME YEAR TO FRACTION(5);
	DEFINE vFechaultmodifAux 		DATETIME YEAR TO FRACTION(5);
	DEFINE vCodstatustarjeta		VARCHAR(3);
	DEFINE vUsuarioModificacion		VARCHAR(8);
	
	--SET DEBUG FILE TO "/RESPALDOSNEW/debug_sp_tr_tarjeta_update.out";
    --TRACE ON;

    LET vCodigoRetorno    		= '00000';          
    LET vMensajeRetorno    		= '';  
    LET sql_err					= 0;          
    LET isam_err				= 0;        
    LET error_info				= '';
 	LET vNumtarjeta 			= '';
 	LET vFechaultmodif 			= CURRENT;
	LET vFechaultmodifAux 		= CURRENT;
	LET vCodstatustarjeta		= '';

	BEGIN

		-- Manejo del error
		ON EXCEPTION SET sql_err, isam_err, error_info
				
        --SET DEBUG FILE TO "/RESPALDOSNEW/sp_tr_tarjeta_update_error.out" WITH APPEND;
        --TRACE ON;
	
			IF sql_err <> 0 THEN
				
				LET vCodigoRetorno = sql_err;
				LET vMensajeRetorno = isam_err|| ' ' ||error_info;
				
				INSERT INTO "informix".bitacora_tr_tarjeta_update(numtarjeta, codret, mnsjret, fecha_registro) 
				VALUES (pNumtarjeta, vCodigoRetorno, vMensajeRetorno, vFechaultmodif);		
				
			END IF;
			
		END EXCEPTION;
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- Validacion de parametros
		IF ( pNumtarjeta IS NULL OR pNumtarjeta = '' OR pCodstatustarjeta IS NULL OR pCodstatustarjeta = '' ) THEN
		
			LET vCodigoRetorno = '00001';
			LET vMensajeRetorno = 'El numero de tarjeta: ' || pNumtarjeta || ' o el codigo de estatus: ' || pCodstatustarjeta ||' de asignacion es vacio o nulo.';
			
			INSERT INTO "informix".bitacora_tr_tarjeta_update(numtarjeta, codret, mnsjret, fecha_registro) 
			VALUES (pNumtarjeta, vCodigoRetorno, vMensajeRetorno, vFechaultmodif);				
			
		ELSE 
			IF ( pCodstatusasignada IS NULL OR pCodstatusasignada = '' ) THEN 
			
				LET vCodigoRetorno = '00002';
				LET vMensajeRetorno = 'El codigo de estatus de asignacion es vacio o nulo.';
			
				INSERT INTO "informix".bitacora_tr_tarjeta_update( numtarjeta, codret, mnsjret, fecha_registro ) 
				VALUES (pNumtarjeta, vCodigoRetorno, vMensajeRetorno, vFechaultmodif);
				
			ELIF (pCodstatusasignada <> 'SIA') THEN 
			
				LET vCodigoRetorno = '00003';
				LET vMensajeRetorno = 'El codigo de estatus de asignacion es diferente de asignado: ' || pCodstatusasignada || ' .';
			
				INSERT INTO "informix".bitacora_tr_tarjeta_update( numtarjeta, codret, mnsjret, fecha_registro ) 
				VALUES (pNumtarjeta, vCodigoRetorno, vMensajeRetorno, vFechaultmodif);
				
			END IF;
			
			IF ( pUsuarioModificacion IS NULL OR pUsuarioModificacion = '' ) THEN 
				LET vCodigoRetorno = '00004';
				LET vMensajeRetorno = 'El usuario de ultima modificacion es vacio o nulo.';
			
				INSERT INTO "informix".bitacora_tr_tarjeta_update( numtarjeta, codret, mnsjret, fecha_registro )
				VALUES (pNumtarjeta, vCodigoRetorno, vMensajeRetorno, vFechaultmodif);				
			END IF;
			
			IF ( pCodstatustarjeta IN ('ACT', 'BLO', 'BLT') ) THEN
				
				SELECT numtarjeta
					INTO vNumtarjeta
				FROM intercard:"informix".info_tarjeta_vcas
				WHERE numtarjeta = pNumtarjeta;
				
				-- Valida si existe la tarjeta en la tabla info_tarjeta_vcas
				IF ( vNumtarjeta IS NOT NULL OR vNumtarjeta <> '' ) THEN
						
					UPDATE "informix".info_tarjeta_vcas
					SET codstatustarjeta = pCodstatustarjeta, fechaultmodif = vFechaultmodif, usuarioultmodif = pUsuarioModificacion
					WHERE numtarjeta = pNumtarjeta;
					
				ELSE 
					
					INSERT INTO "informix".info_tarjeta_vcas(numtarjeta, codstatustarjeta, fechaasignacion, fechaultmodif, usuarioultmodif) 
					VALUES (pNumtarjeta, pCodstatustarjeta, pFechaasignacion, vFechaultmodif, pUsuarioModificacion);
					
				END IF;
				
			
			ELIF ( pCodstatustarjeta IN ('CAN', 'FAL', 'ROB', 'EXT') ) THEN
				
				SELECT numtarjeta, codstatustarjeta, fechaultmodif
					INTO vNumtarjeta, vCodstatustarjeta, vFechaultmodifAux
				FROM intercard:"informix".info_tarjeta_vcas
				WHERE numtarjeta = pNumtarjeta;
				
				IF ( vNumtarjeta IS NOT NULL OR vNumtarjeta <> '' ) THEN
				
					INSERT INTO "informix".info_tarjeta_vcas_historico(numtarjeta, codstatustarjeta, fechaasignacion, fechaultmodif, usuarioultmodif) 
					VALUES (pNumtarjeta, vCodstatustarjeta, pFechaasignacion, vFechaultmodifAux, pUsuarioModificacion);
					
					DELETE FROM "informix".info_tarjeta_vcas
					WHERE numtarjeta = pNumtarjeta;
				
				END IF;
				
				INSERT INTO "informix".info_tarjeta_vcas_historico(numtarjeta, codstatustarjeta, fechaasignacion, fechaultmodif, usuarioultmodif) 
				VALUES (pNumtarjeta, pCodstatustarjeta, pFechaasignacion, vFechaultmodif, pUsuarioModificacion);
				
			END IF;
		
		END IF;
		
	END;

END PROCEDURE
DOCUMENT
'Creacion: 14/05/2024',
'Autor: Maria Fernanda Ortiz Figueroa',
'Descripcion: SP que actualiza / inserta / elimina los registros de la tabla info_tarjeta_vcas cuando se actualiza el estatus de la tabla tarjeta.';


grant  execute on function "informix".cargo_ref (char,char,char,char,char,char,integer,money,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".cargo_ref (char,char,char,char,char,char,integer,money,char,char) to "public" as "informix";
grant  execute on function "informix".cargo_ref (char,char,char,char,char,char,integer,money,char,char) to "syswallet" as "informix";
grant  execute on function "informix".cargo_ref (char,char,char,char,char,char,integer,money,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".cargo_ref (char,char,char,char,char,char,integer,money,char,char) to "c90306542" as "informix";
grant  execute on function "informix".cargo_ref (char,char,char,char,char,char,integer,money,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_obtenerivasuc (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_obtenerivasuc (char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_obtenerivasuc (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenerivasuc (char) to "public" as "informix";
grant  execute on function "informix".sp_obtenerivasuc (char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtenerivasuc (char) to "select_role_intercard" as "informix";
grant  execute on function "informix".reversiontd_cel (char,char,char,integer,char,char,money,money,char,integer,char,char,char,char,char,integer,char,char,money,money,char,integer,char,char,char,char,integer,char,money,money,char,integer,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".reversiontd_cel (char,char,char,integer,char,char,money,money,char,integer,char,char,char,char,char,integer,char,char,money,money,char,integer,char,char,char,char,integer,char,money,money,char,integer,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".reversiontd_cel (char,char,char,integer,char,char,money,money,char,integer,char,char,char,char,char,integer,char,char,money,money,char,integer,char,char,char,char,integer,char,money,money,char,integer,char,char) to "public" as "informix";
grant  execute on function "informix".reversiontd_cel (char,char,char,integer,char,char,money,money,char,integer,char,char,char,char,char,integer,char,char,money,money,char,integer,char,char,char,char,integer,char,money,money,char,integer,char,char) to "syswallet" as "informix";
grant  execute on function "informix".reversiontd_cel (char,char,char,integer,char,char,money,money,char,integer,char,char,char,char,char,integer,char,char,money,money,char,integer,char,char,char,char,integer,char,money,money,char,integer,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".cargo_ref_cel (char,char,char,char,char,char,integer,money,char,char,char,char,char,char,char,char,integer,money,char,char,char,char,char,char,integer,money,char,char) to "public" as "informix";
grant  execute on function "informix".cargo_ref_cel (char,char,char,char,char,char,integer,money,char,char,char,char,char,char,char,char,integer,money,char,char,char,char,char,char,integer,money,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".cargo_ref_cel (char,char,char,char,char,char,integer,money,char,char,char,char,char,char,char,char,integer,money,char,char,char,char,char,char,integer,money,char,char) to "syswallet" as "informix";
grant  execute on function "informix".cargo_ref_cel (char,char,char,char,char,char,integer,money,char,char,char,char,char,char,char,char,integer,money,char,char,char,char,char,char,integer,money,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".cargo_ref_cel (char,char,char,char,char,char,integer,money,char,char,char,char,char,char,char,char,integer,money,char,char,char,char,char,char,integer,money,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_actualiza_saldo () to "c90306542" as "informix";
grant  execute on function "informix".sp_actualiza_saldo () to "syswallet" as "informix";
grant  execute on function "informix".sp_actualiza_saldo () to "public" as "informix";
grant  execute on function "informix".sp_actualiza_saldo () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_actualiza_saldo () to "ifxprod" as "informix";
grant  execute on function "informix".sp_actualiza_saldo () to "all_role_intercard" as "informix";
grant  execute on function "informix".proximafecha () to "syswallet" as "informix";
grant  execute on function "informix".proximafecha () to "c90306542" as "informix";
grant  execute on function "informix".proximafecha () to "all_role_intercard" as "informix";
grant  execute on function "informix".proximafecha () to "select_role_intercard" as "informix";
grant  execute on function "informix".proximafecha () to "ifxprod" as "informix";
grant  execute on function "informix".proximafecha () to "public" as "informix";
grant  execute on function "informix".sp_obtcobrosaniv (datetime) to "public" as "informix";
grant  execute on function "informix".sp_obtcobrosaniv (datetime) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtcobrosaniv (datetime) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_obtcobrosaniv (datetime) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_obtcobrosaniv (datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtcobrosaniv (datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_comaniversariocta (char,money,integer) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_comaniversariocta (char,money,integer) to "public" as "informix";
grant  execute on function "informix".sp_comaniversariocta (char,money,integer) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_comaniversariocta (char,money,integer) to "ifxprod" as "informix";
grant  execute on function "informix".sp_comaniversariocta (char,money,integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_comaniversariocta (char,money,integer) to "c90306542" as "informix";
grant  execute on function "informix".cargo_ref_cel (char,char,char,char,char,char,char,integer,money,money,char,char,char,char,char,char,char,char,char,char,integer,money,char,char,char,char,char,char,integer,money,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".cargo_ref_cel (char,char,char,char,char,char,char,integer,money,money,char,char,char,char,char,char,char,char,char,char,integer,money,char,char,char,char,char,char,integer,money,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".cargo_ref_cel (char,char,char,char,char,char,char,integer,money,money,char,char,char,char,char,char,char,char,char,char,integer,money,char,char,char,char,char,char,integer,money,char,char) to "syswallet" as "informix";
grant  execute on function "informix".cargo_ref_cel (char,char,char,char,char,char,char,integer,money,money,char,char,char,char,char,char,char,char,char,char,integer,money,char,char,char,char,char,char,integer,money,char,char) to "public" as "informix";
grant  execute on function "informix".cargo_ref_cel (char,char,char,char,char,char,char,integer,money,money,char,char,char,char,char,char,char,char,char,char,integer,money,char,char,char,char,char,char,integer,money,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".reversiontd_cel (char,char,char,char,integer,char,char,money,money,char,char,money,char,integer,char,char,char,char,char,integer,char,char,money,money,char,integer,char,char,char,char,integer,char,money,money,char,integer,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".reversiontd_cel (char,char,char,char,integer,char,char,money,money,char,char,money,char,integer,char,char,char,char,char,integer,char,char,money,money,char,integer,char,char,char,char,integer,char,money,money,char,integer,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".reversiontd_cel (char,char,char,char,integer,char,char,money,money,char,char,money,char,integer,char,char,char,char,char,integer,char,char,money,money,char,integer,char,char,char,char,integer,char,money,money,char,integer,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".reversiontd_cel (char,char,char,char,integer,char,char,money,money,char,char,money,char,integer,char,char,char,char,char,integer,char,char,money,money,char,integer,char,char,char,char,integer,char,money,money,char,integer,char,char) to "public" as "informix";
grant  execute on function "informix".reversiontd_cel (char,char,char,char,integer,char,char,money,money,char,char,money,char,integer,char,char,char,char,char,integer,char,char,money,money,char,integer,char,char,char,char,integer,char,money,money,char,integer,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_cancelacion_tarjeta (varchar,varchar,varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_cancelacion_tarjeta (varchar,varchar,varchar) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_cancelacion_tarjeta (varchar,varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_cancelacion_tarjeta (varchar,varchar,varchar) to "ifxprod" as "informix";
grant  execute on function "informix".sp_cancelacion_tarjeta (varchar,varchar,varchar) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_cancelacion_tarjeta (varchar,varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_cancelacion_tarjeta (varchar,varchar,varchar) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_archivo_log (char,integer) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_archivo_log (char,integer) to "ifxprod" as "informix";
grant  execute on function "informix".sp_archivo_log (char,integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_archivo_log (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_archivo_log (char,integer) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_archivo_log (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_archivo_log (char,integer) to "sysconau" as "informix";
grant  execute on function "informix".sp_esconvenio (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_esconvenio (char) to "public" as "informix";
grant  execute on function "informix".sp_esconvenio (char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_esconvenio (char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_esconvenio (char) to "sysconau" as "informix";
grant  execute on function "informix".sp_esconvenio (char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_esconvenio (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_espropio (char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_espropio (char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_espropio (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_espropio (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_espropio (char) to "public" as "informix";
grant  execute on function "informix".sp_espropio (char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_espropio (char) to "sysconau" as "informix";
grant  execute on function "informix".sp_getsecuenciatrancon () to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_getsecuenciatrancon () to "sysconau" as "informix";
grant  execute on function "informix".sp_getsecuenciatrancon () to "public" as "informix";
grant  execute on function "informix".sp_getsecuenciatrancon () to "ifxprod" as "informix";
grant  execute on function "informix".sp_getsecuenciatrancon () to "syswallet" as "informix";
grant  execute on function "informix".sp_getsecuenciatrancon () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_getsecuenciatrancon () to "c90306542" as "informix";
grant  execute on function "informix".sp_insertamovconciliados (char,char,char,char,char,char,char,char,char,datetime,char,datetime,char,datetime,char,char,char,char,char,char,char,money,money,money,money,money,money,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,integer,char,char,integer,char,char,char,char,char,money) to "c90306542" as "informix";
grant  execute on function "informix".sp_insertamovconciliados (char,char,char,char,char,char,char,char,char,datetime,char,datetime,char,datetime,char,char,char,char,char,char,char,money,money,money,money,money,money,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,integer,char,char,integer,char,char,char,char,char,money) to "syswallet" as "informix";
grant  execute on function "informix".sp_insertamovconciliados (char,char,char,char,char,char,char,char,char,datetime,char,datetime,char,datetime,char,char,char,char,char,char,char,money,money,money,money,money,money,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,integer,char,char,integer,char,char,char,char,char,money) to "sysconau" as "informix";
grant  execute on function "informix".sp_insertamovconciliados (char,char,char,char,char,char,char,char,char,datetime,char,datetime,char,datetime,char,char,char,char,char,char,char,money,money,money,money,money,money,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,integer,char,char,integer,char,char,char,char,char,money) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_insertamovconciliados (char,char,char,char,char,char,char,char,char,datetime,char,datetime,char,datetime,char,char,char,char,char,char,char,money,money,money,money,money,money,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,integer,char,char,integer,char,char,char,char,char,money) to "public" as "informix";
grant  execute on function "informix".sp_insertamovconciliados (char,char,char,char,char,char,char,char,char,datetime,char,datetime,char,datetime,char,char,char,char,char,char,char,money,money,money,money,money,money,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,integer,char,char,integer,char,char,char,char,char,money) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_insertamovconciliados (char,char,char,char,char,char,char,char,char,datetime,char,datetime,char,datetime,char,char,char,char,char,char,char,money,money,money,money,money,money,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,integer,char,char,integer,char,char,char,char,char,money) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reversa_mov (char,char,integer) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_reversa_mov (char,char,integer) to "sysconau" as "informix";
grant  execute on function "informix".sp_reversa_mov (char,char,integer) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reversa_mov (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_reversa_mov (char,char,integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_reversa_mov (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_reversa_mov (char,char,integer) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_actualizamovimiento (char,char,char,datetime) to "sysconau" as "informix";
grant  execute on function "informix".sp_actualizamovimiento (char,char,char,datetime) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_actualizamovimiento (char,char,char,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_actualizamovimiento (char,char,char,datetime) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_actualizamovimiento (char,char,char,datetime) to "ifxprod" as "informix";
grant  execute on function "informix".sp_actualizamovimiento (char,char,char,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizamovimiento (char,char,char,datetime) to "public" as "informix";
grant  execute on function "informix".sp_archivo_central (char) to "public" as "informix";
grant  execute on function "informix".sp_archivo_central (char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_archivo_central (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_archivo_central (char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_archivo_central (char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_archivo_central (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_archivo_central (char) to "sysconau" as "informix";
grant  execute on function "informix".sp_establoqueadaocancelada (char,char,char) to "sysconau" as "informix";
grant  execute on function "informix".sp_establoqueadaocancelada (char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_establoqueadaocancelada (char,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_establoqueadaocancelada (char,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_establoqueadaocancelada (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_establoqueadaocancelada (char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_establoqueadaocancelada (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_existemovimientooriginal_estareversado (char,char) to "public" as "informix";
grant  execute on function "informix".sp_existemovimientooriginal_estareversado (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_existemovimientooriginal_estareversado (char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_existemovimientooriginal_estareversado (char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_existemovimientooriginal_estareversado (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_existemovimientooriginal_estareversado (char,char) to "sysconau" as "informix";
grant  execute on function "informix".sp_existemovimientooriginal_estareversado (char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_generareferencia (integer,char,char) to "sysconau" as "informix";
grant  execute on function "informix".sp_generareferencia (integer,char,char) to "public" as "informix";
grant  execute on function "informix".sp_generareferencia (integer,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_generareferencia (integer,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_generareferencia (integer,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_generareferencia (integer,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_generareferencia (integer,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_getmontoparametros (integer,char,char,char) to "sysconau" as "informix";
grant  execute on function "informix".sp_getmontoparametros (integer,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_getmontoparametros (integer,char,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_getmontoparametros (integer,char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_getmontoparametros (integer,char,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_getmontoparametros (integer,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_getmontoparametros (integer,char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_gettransaccioninterempresas (char,char,money,money) to "syswallet" as "informix";
grant  execute on function "informix".sp_gettransaccioninterempresas (char,char,money,money) to "sysconau" as "informix";
grant  execute on function "informix".sp_gettransaccioninterempresas (char,char,money,money) to "ifxprod" as "informix";
grant  execute on function "informix".sp_gettransaccioninterempresas (char,char,money,money) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_gettransaccioninterempresas (char,char,money,money) to "public" as "informix";
grant  execute on function "informix".sp_gettransaccioninterempresas (char,char,money,money) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_gettransaccioninterempresas (char,char,money,money) to "c90306542" as "informix";
grant  execute on function "informix".sp_gettypeoftransaction (char,char,char,money,money) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_gettypeoftransaction (char,char,char,money,money) to "ifxprod" as "informix";
grant  execute on function "informix".sp_gettypeoftransaction (char,char,char,money,money) to "public" as "informix";
grant  execute on function "informix".sp_gettypeoftransaction (char,char,char,money,money) to "c90306542" as "informix";
grant  execute on function "informix".sp_gettypeoftransaction (char,char,char,money,money) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_gettypeoftransaction (char,char,char,money,money) to "syswallet" as "informix";
grant  execute on function "informix".sp_gettypeoftransaction (char,char,char,money,money) to "sysconau" as "informix";
grant  execute on function "informix".sp_obtenerreversaoforzada_pos (char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtenerreversaoforzada_pos (char,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_obtenerreversaoforzada_pos (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenerreversaoforzada_pos (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_obtenerreversaoforzada_pos (char,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_obtenerreversaoforzada_pos (char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_obtenerreversaoforzada_pos (char,char,char) to "sysconau" as "informix";
grant  execute on function "informix".sp_reporteatmstat06cajero (datetime,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_reporteatmstat06cajero (datetime,datetime) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reporteatmstat06cajero (datetime,datetime) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_reporteatmstat06cajero (datetime,datetime) to "sysconau" as "informix";
grant  execute on function "informix".sp_reporteatmstat06cajero (datetime,datetime) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_reporteatmstat06cajero (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".cambio_producto_intercard () to "ifxprod" as "informix";
grant  execute on function "informix".cambio_producto_intercard () to "public" as "informix";
grant  execute on function "informix".cambio_producto_intercard () to "c90306542" as "informix";
grant  execute on function "informix".cambio_producto_intercard () to "syswallet" as "informix";
grant  execute on function "informix".cambio_producto_intercard () to "select_role_intercard" as "informix";
grant  execute on function "informix".cambio_producto_intercard () to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_emigraconsecutivostarjetas () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_emigraconsecutivostarjetas () to "ifxprod" as "informix";
grant  execute on function "informix".sp_emigraconsecutivostarjetas () to "c90306542" as "informix";
grant  execute on function "informix".sp_emigraconsecutivostarjetas () to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_emigraconsecutivostarjetas () to "public" as "informix";
grant  execute on function "informix".sp_emigraconsecutivostarjetas () to "syswallet" as "informix";
grant  execute on function "informix".sp_emigraresumenmaquila () to "ifxprod" as "informix";
grant  execute on function "informix".sp_emigraresumenmaquila () to "public" as "informix";
grant  execute on function "informix".sp_emigraresumenmaquila () to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_emigraresumenmaquila () to "syswallet" as "informix";
grant  execute on function "informix".sp_emigraresumenmaquila () to "c90306542" as "informix";
grant  execute on function "informix".sp_emigraresumenmaquila () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_emigra_lotes () to "c90306542" as "informix";
grant  execute on function "informix".sp_emigra_lotes () to "syswallet" as "informix";
grant  execute on function "informix".sp_emigra_lotes () to "public" as "informix";
grant  execute on function "informix".sp_emigra_lotes () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_emigra_lotes () to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_emigra_lotes () to "ifxprod" as "informix";
grant  execute on function "informix".sp_genera_estadistica_existencia () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_genera_estadistica_existencia () to "c90306542" as "informix";
grant  execute on function "informix".sp_genera_estadistica_existencia () to "syswallet" as "informix";
grant  execute on function "informix".sp_genera_estadistica_existencia () to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_genera_estadistica_existencia () to "ifxprod" as "informix";
grant  execute on function "informix".sp_genera_estadistica_existencia () to "public" as "informix";
grant  execute on function "informix".sp_genera_estadistica_existencia_adicionales () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_genera_estadistica_existencia_adicionales () to "ifxprod" as "informix";
grant  execute on function "informix".sp_genera_estadistica_existencia_adicionales () to "c90306542" as "informix";
grant  execute on function "informix".sp_genera_estadistica_existencia_adicionales () to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_genera_estadistica_existencia_adicionales () to "syswallet" as "informix";
grant  execute on function "informix".sp_genera_estadistica_existencia_adicionales () to "public" as "informix";
grant  execute on function "informix".sp_catsucursal () to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_catsucursal () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_catsucursal () to "ifxprod" as "informix";
grant  execute on function "informix".sp_catsucursal () to "public" as "informix";
grant  execute on function "informix".sp_catsucursal () to "c90306542" as "informix";
grant  execute on function "informix".sp_catsucursal () to "syswallet" as "informix";
grant  execute on function "informix".sp_repinvtarconsolidado (char,date,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_repinvtarconsolidado (char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_repinvtarconsolidado (char,date,date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_repinvtarconsolidado (char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_repinvtarconsolidado (char,date,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_repinvtarconsolidado (char,date,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_repinvtardia (char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_repinvtardia (char,date,date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_repinvtardia (char,date,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_repinvtardia (char,date,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_repinvtardia (char,date,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_repinvtardia (char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_get_fecha_estadistica () to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_get_fecha_estadistica () to "c90306542" as "informix";
grant  execute on function "informix".sp_get_fecha_estadistica () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_get_fecha_estadistica () to "ifxprod" as "informix";
grant  execute on function "informix".sp_get_fecha_estadistica () to "syswallet" as "informix";
grant  execute on function "informix".sp_get_fecha_estadistica () to "public" as "informix";
grant  execute on function "informix".sp_obtener_udi (char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_obtener_udi (char,date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_obtener_udi (char,date) to "public" as "informix";
grant  execute on function "informix".sp_obtener_udi (char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_obtener_udi (char,date) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_obtener_udi (char,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtener_udi (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_control_reportes (char,integer,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_control_reportes (char,integer,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_control_reportes (char,integer,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_control_reportes (char,integer,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_control_reportes (char,integer,char,char) to "public" as "informix";
grant  execute on function "informix".sp_control_reportes (char,integer,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_control_reportes (char,integer,char,char) to "sysconau" as "informix";
grant  execute on function "informix".sp_descripcionerrorconciliacion (char,datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_descripcionerrorconciliacion (char,datetime,datetime) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_descripcionerrorconciliacion (char,datetime,datetime) to "sysconau" as "informix";
grant  execute on function "informix".sp_descripcionerrorconciliacion (char,datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_descripcionerrorconciliacion (char,datetime,datetime) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_descripcionerrorconciliacion (char,datetime,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_descripcionerrorconciliacion (char,datetime,datetime) to "ifxprod" as "informix";
grant  execute on function "informix".sp_esnumerico (char) to "public" as "informix";
grant  execute on function "informix".sp_esnumerico (char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_esnumerico (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_esnumerico (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_esnumerico (char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_esnumerico (char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_esnumerico (char) to "sysconau" as "informix";
grant  execute on function "informix".sp_obtdatosbitacoraconciliacion_syserrorconciliacion (char,datetime,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_obtdatosbitacoraconciliacion_syserrorconciliacion (char,datetime,datetime) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtdatosbitacoraconciliacion_syserrorconciliacion (char,datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtdatosbitacoraconciliacion_syserrorconciliacion (char,datetime,datetime) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_obtdatosbitacoraconciliacion_syserrorconciliacion (char,datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_obtdatosbitacoraconciliacion_syserrorconciliacion (char,datetime,datetime) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_obtdatosbitacoraconciliacion_syserrorconciliacion (char,datetime,datetime) to "sysconau" as "informix";
grant  execute on function "informix".sp_obtregmonitorconciliacionman (char,datetime,datetime) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtregmonitorconciliacionman (char,datetime,datetime) to "sysconau" as "informix";
grant  execute on function "informix".sp_obtregmonitorconciliacionman (char,datetime,datetime) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_obtregmonitorconciliacionman (char,datetime,datetime) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_obtregmonitorconciliacionman (char,datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtregmonitorconciliacionman (char,datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_obtregmonitorconciliacionman (char,datetime,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_rep_stat06_transaccionestodoatm (char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_rep_stat06_transaccionestodoatm (char,char,char) to "sysconau" as "informix";
grant  execute on function "informix".sp_rep_stat06_transaccionestodoatm (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_rep_stat06_transaccionestodoatm (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_rep_stat06_transaccionestodoatm (char,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_rep_stat06_transaccionestodoatm (char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_rep_stat06_transaccionestodoatm (char,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_rep_stat06_transxcajerocreddeb (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_rep_stat06_transxcajerocreddeb (char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_rep_stat06_transxcajerocreddeb (char,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_rep_stat06_transxcajerocreddeb (char,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_rep_stat06_transxcajerocreddeb (char,char,char) to "sysconau" as "informix";
grant  execute on function "informix".sp_rep_stat06_transxcajerocreddeb (char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_rep_stat06_transxcajerocreddeb (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporteatmstat06cajero (char,char) to "sysconau" as "informix";
grant  execute on function "informix".sp_reporteatmstat06cajero (char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_reporteatmstat06cajero (char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_reporteatmstat06cajero (char,char) to "public" as "informix";
grant  execute on function "informix".sp_reporteatmstat06cajero (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reporteatmstat06cajero (char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_correcciontarjetascanceladas () to "syswallet" as "informix";
grant  execute on function "informix".sp_correcciontarjetascanceladas () to "c90306542" as "informix";
grant  execute on function "informix".sp_correcciontarjetascanceladas () to "public" as "informix";
grant  execute on function "informix".sp_correcciontarjetascanceladas () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_correcciontarjetascanceladas () to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_correcciontarjetascanceladas () to "ifxprod" as "informix";
grant  execute on function "informix".sp_corrigestatusasigtar () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_corrigestatusasigtar () to "syswallet" as "informix";
grant  execute on function "informix".sp_corrigestatusasigtar () to "public" as "informix";
grant  execute on function "informix".sp_corrigestatusasigtar () to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_corrigestatusasigtar () to "ifxprod" as "informix";
grant  execute on function "informix".sp_corrigestatusasigtar () to "c90306542" as "informix";
grant  execute on function "informix".sp_mf_consultaextranjerotransacciones (datetime,datetime,int8) to "c90306542" as "informix";
grant  execute on function "informix".sp_mf_consultaextranjerotransacciones (datetime,datetime,int8) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_mf_consultaextranjerotransacciones (datetime,datetime,int8) to "public" as "informix";
grant  execute on function "informix".sp_mf_consultaextranjerotransacciones (datetime,datetime,int8) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_mf_consultaextranjerotransacciones (datetime,datetime,int8) to "syswallet" as "informix";
grant  execute on function "informix".sp_mf_consultaextranjerotransacciones (datetime,datetime,int8) to "ifxprod" as "informix";
grant  execute on function "informix".sp_mf_consultagironegocio (datetime,datetime,varchar,int8) to "c90306542" as "informix";
grant  execute on function "informix".sp_mf_consultagironegocio (datetime,datetime,varchar,int8) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_mf_consultagironegocio (datetime,datetime,varchar,int8) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_mf_consultagironegocio (datetime,datetime,varchar,int8) to "syswallet" as "informix";
grant  execute on function "informix".sp_mf_consultagironegocio (datetime,datetime,varchar,int8) to "ifxprod" as "informix";
grant  execute on function "informix".sp_mf_consultagironegocio (datetime,datetime,varchar,int8) to "public" as "informix";
grant  execute on function "informix".sp_mf_consultamontotransacciones (datetime,datetime,integer,integer,int8) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_mf_consultamontotransacciones (datetime,datetime,integer,integer,int8) to "public" as "informix";
grant  execute on function "informix".sp_mf_consultamontotransacciones (datetime,datetime,integer,integer,int8) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_mf_consultamontotransacciones (datetime,datetime,integer,integer,int8) to "ifxprod" as "informix";
grant  execute on function "informix".sp_mf_consultamontotransacciones (datetime,datetime,integer,integer,int8) to "c90306542" as "informix";
grant  execute on function "informix".sp_mf_consultamontotransacciones (datetime,datetime,integer,integer,int8) to "syswallet" as "informix";
grant  execute on function "informix".sp_mf_consultaerrortransacciones (datetime,datetime,int8) to "syswallet" as "informix";
grant  execute on function "informix".sp_mf_consultaerrortransacciones (datetime,datetime,int8) to "public" as "informix";
grant  execute on function "informix".sp_mf_consultaerrortransacciones (datetime,datetime,int8) to "ifxprod" as "informix";
grant  execute on function "informix".sp_mf_consultaerrortransacciones (datetime,datetime,int8) to "c90306542" as "informix";
grant  execute on function "informix".sp_mf_consultaerrortransacciones (datetime,datetime,int8) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_mf_consultaerrortransacciones (datetime,datetime,int8) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_mf_consultatarjeta (varchar,int8) to "c90306542" as "informix";
grant  execute on function "informix".sp_mf_consultatarjeta (varchar,int8) to "ifxprod" as "informix";
grant  execute on function "informix".sp_mf_consultatarjeta (varchar,int8) to "syswallet" as "informix";
grant  execute on function "informix".sp_mf_consultatarjeta (varchar,int8) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_mf_consultatarjeta (varchar,int8) to "public" as "informix";
grant  execute on function "informix".sp_mf_consultatarjeta (varchar,int8) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_mf_consultatipoproducto (datetime,datetime,int8,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_mf_consultatipoproducto (datetime,datetime,int8,varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_mf_consultatipoproducto (datetime,datetime,int8,varchar) to "public" as "informix";
grant  execute on function "informix".sp_mf_consultatipoproducto (datetime,datetime,int8,varchar) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_mf_consultatipoproducto (datetime,datetime,int8,varchar) to "ifxprod" as "informix";
grant  execute on function "informix".sp_mf_consultatipoproducto (datetime,datetime,int8,varchar) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_mf_consultatransacciontarjeta (varchar,datetime) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_mf_consultatransacciontarjeta (varchar,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_mf_consultatransacciontarjeta (varchar,datetime) to "ifxprod" as "informix";
grant  execute on function "informix".sp_mf_consultatransacciontarjeta (varchar,datetime) to "public" as "informix";
grant  execute on function "informix".sp_mf_consultatransacciontarjeta (varchar,datetime) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_mf_consultatransacciontarjeta (varchar,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_mf_estadistica (date) to "syswallet" as "informix";
grant  execute on function "informix".sp_mf_estadistica (date) to "public" as "informix";
grant  execute on function "informix".sp_mf_estadistica (date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_mf_estadistica (date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_mf_estadistica (date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_mf_estadistica (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_mf_numoperaciones (integer,date,integer,integer) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_mf_numoperaciones (integer,date,integer,integer) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_mf_numoperaciones (integer,date,integer,integer) to "ifxprod" as "informix";
grant  execute on function "informix".sp_mf_numoperaciones (integer,date,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_mf_numoperaciones (integer,date,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_mf_numoperaciones (integer,date,integer,integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_generaarchivoconciliacion () to "public" as "informix";
grant  execute on function "informix".sp_generaarchivoconciliacion () to "ifxprod" as "informix";
grant  execute on function "informix".sp_generaarchivoconciliacion () to "syswallet" as "informix";
grant  execute on function "informix".sp_generaarchivoconciliacion () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_generaarchivoconciliacion () to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_generaarchivoconciliacion () to "sysconau" as "informix";
grant  execute on function "informix".sp_generaarchivoconciliacion_pba (char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_generaarchivoconciliacion_pba (char) to "public" as "informix";
grant  execute on function "informix".sp_generaarchivoconciliacion_pba (char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_generaarchivoconciliacion_pba (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_generaarchivoconciliacion_pba (char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_generaarchivoconciliacion_pba (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_generaarchivoconciliacion (char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_generaarchivoconciliacion (char) to "public" as "informix";
grant  execute on function "informix".sp_generaarchivoconciliacion (char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_generaarchivoconciliacion (char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_generaarchivoconciliacion (char) to "syswallet" as "informix";
grant  execute on function "informix".locate (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".locate (char,char) to "public" as "informix";
grant  execute on function "informix".locate (char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".locate (char,char) to "syswallet" as "informix";
grant  execute on function "informix".locate (char,char) to "c90306542" as "informix";
grant  execute on function "informix".locate (char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_genconadmin_pba (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_genconadmin_pba (char) to "public" as "informix";
grant  execute on function "informix".sp_genconadmin_pba (char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_genconadmin_pba (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_genconadmin_pba (char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_genconadmin_pba (char) to "select_role_intercard" as "informix";
grant  execute on procedure "informix".sp_aplica_genconadmin_pba (char,char,char,char,datetime) to "all_role_intercard" as "informix";
grant  execute on procedure "informix".sp_aplica_genconadmin_pba (char,char,char,char,datetime) to "ifxprod" as "informix";
grant  execute on procedure "informix".sp_aplica_genconadmin_pba (char,char,char,char,datetime) to "public" as "informix";
grant  execute on procedure "informix".sp_aplica_genconadmin_pba (char,char,char,char,datetime) to "select_role_intercard" as "informix";
grant  execute on procedure "informix".sp_aplica_genconadmin_pba (char,char,char,char,datetime) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_aplica_genconadmin_pba (char,char,char,char,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_geninfocomitmp (char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_geninfocomitmp (char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_geninfocomitmp (char,char,char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_geninfocomitmp (char,char,char,date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_geninfocomitmp (char,char,char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_geninfocomitmp (char,char,char,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtenerdatostransacciondbmovimiento_atm (char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_obtenerdatostransacciondbmovimiento_atm (char,char,char,char,char,char,char,char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_obtenerdatostransacciondbmovimiento_atm (char,char,char,char,char,char,char,char,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_obtenerdatostransacciondbmovimiento_atm (char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenerdatostransacciondbmovimiento_atm (char,char,char,char,char,char,char,char,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_obtenerdatostransacciondbmovimiento_atm (char,char,char,char,char,char,char,char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_carga_archivoseglobal (char,char,integer,integer) to "ifxprod" as "informix";
grant  execute on function "informix".sp_carga_archivoseglobal (char,char,integer,integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_carga_archivoseglobal (char,char,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_carga_archivoseglobal (char,char,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_carga_archivoseglobal (char,char,integer,integer) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_carga_archivoseglobal (char,char,integer,integer) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_conciliacion_atm (char,char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_conciliacion_atm (char,char,char,integer) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_conciliacion_atm (char,char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_conciliacion_atm (char,char,char,integer) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_conciliacion_atm (char,char,char,integer) to "ifxprod" as "informix";
grant  execute on function "informix".sp_conciliacion_atm (char,char,char,integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_insertar_log_atm (char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,char,char,char,char,char,char,money,money,char,char,money,money,char,char,char,char,char,char,char,char,char,char,char,money,char,money,money,char,char,char,char,char,char,char,char,char,char,char,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_insertar_log_atm (char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,char,char,char,char,char,char,money,money,char,char,money,money,char,char,char,char,char,char,char,char,char,char,char,money,char,money,money,char,char,char,char,char,char,char,char,char,char,char,integer,char) to "public" as "informix";
grant  execute on function "informix".sp_insertar_log_atm (char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,char,char,char,char,char,char,money,money,char,char,money,money,char,char,char,char,char,char,char,char,char,char,char,money,char,money,money,char,char,char,char,char,char,char,char,char,char,char,integer,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_insertar_log_atm (char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,char,char,char,char,char,char,money,money,char,char,money,money,char,char,char,char,char,char,char,char,char,char,char,money,char,money,money,char,char,char,char,char,char,char,char,char,char,char,integer,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_insertar_log_atm (char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,char,char,char,char,char,char,money,money,char,char,money,money,char,char,char,char,char,char,char,char,char,char,char,money,char,money,money,char,char,char,char,char,char,char,char,char,char,char,integer,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_insertar_log_atm (char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,char,char,char,char,char,char,money,money,char,char,money,money,char,char,char,char,char,char,char,char,char,char,char,money,char,money,money,char,char,char,char,char,char,char,char,char,char,char,integer,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_insertar_log_pos (char,char,char,money,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,char,char,money,char,char,char,char,money,char,char,char,char,money,char,char,char,char,char,char,char,char,char,char,char,integer,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_insertar_log_pos (char,char,char,money,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,char,char,money,char,char,char,char,money,char,char,char,char,money,char,char,char,char,char,char,char,char,char,char,char,integer,char) to "public" as "informix";
grant  execute on function "informix".sp_insertar_log_pos (char,char,char,money,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,char,char,money,char,char,char,char,money,char,char,char,char,money,char,char,char,char,char,char,char,char,char,char,char,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_insertar_log_pos (char,char,char,money,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,char,char,money,char,char,char,char,money,char,char,char,char,money,char,char,char,char,char,char,char,char,char,char,char,integer,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_insertar_log_pos (char,char,char,money,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,char,char,money,char,char,char,char,money,char,char,char,char,money,char,char,char,char,char,char,char,char,char,char,char,integer,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_insertarcentral (char,char,char,char,char,char,char,money,char,char,char,char,char,money,money,char,char,char,money,char,char,char,money,char) to "public" as "informix";
grant  execute on function "informix".sp_insertarcentral (char,char,char,char,char,char,char,money,char,char,char,char,char,money,money,char,char,char,money,char,char,char,money,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_insertarcentral (char,char,char,char,char,char,char,money,char,char,char,char,char,money,money,char,char,char,money,char,char,char,money,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_insertarcentral (char,char,char,char,char,char,char,money,char,char,char,char,char,money,money,char,char,char,money,char,char,char,money,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_insertarcentral (char,char,char,char,char,char,char,money,char,char,char,char,char,money,money,char,char,char,money,char,char,char,money,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_insertarcentral (char,char,char,char,char,char,char,money,char,char,char,char,char,money,money,char,char,char,money,char,char,char,money,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_conciliacion_atm_registro (char,char,char,char,char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,integer,char,char,char,char,char,char,char,char,money,money,char,char,money,money,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_conciliacion_atm_registro (char,char,char,char,char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,integer,char,char,char,char,char,char,char,char,money,money,char,char,money,money,char,char) to "public" as "informix";
grant  execute on function "informix".sp_conciliacion_atm_registro (char,char,char,char,char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,integer,char,char,char,char,char,char,char,char,money,money,char,char,money,money,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_conciliacion_atm_registro (char,char,char,char,char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,integer,char,char,char,char,char,char,char,char,money,money,char,char,money,money,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_conciliacion_atm_registro (char,char,char,char,char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,integer,char,char,char,char,char,char,char,char,money,money,char,char,money,money,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_conciliacion_atm_registro (char,char,char,char,char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,integer,char,char,char,char,char,char,char,char,money,money,char,char,money,money,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_borrararchconaut (char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_borrararchconaut (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_borrararchconaut (char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_borrararchconaut (char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_borrararchconaut (char) to "public" as "informix";
grant  execute on function "informix".sp_borrararchconaut (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultaconadmincorr (char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_consultaconadmincorr (char,date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_consultaconadmincorr (char,date) to "public" as "informix";
grant  execute on function "informix".sp_consultaconadmincorr (char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_consultaconadmincorr (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultaconadmincorr (char,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_regeneracion_movimientohistorico (datetime,datetime) to "ifxprod" as "informix";
grant  execute on function "informix".sp_regeneracion_movimientohistorico (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_regeneracion_movimientohistorico (datetime,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_regeneracion_movimientohistorico (datetime,datetime) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_regeneracion_movimientohistorico (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_regeneracion_movimientohistorico (datetime,datetime) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_tipo_conciliacion_pos (char,char,char,char,char,char,char,money,money,char,char,char,char,money,char,integer,char,char,char,char,money,money,money,money,char,char,char,money,char,char,integer,char,char,char,char,char,money,money,char,char,char,money,char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_tipo_conciliacion_pos (char,char,char,char,char,char,char,money,money,char,char,char,char,money,char,integer,char,char,char,char,money,money,money,money,char,char,char,money,char,char,integer,char,char,char,char,char,money,money,char,char,char,money,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_tipo_conciliacion_pos (char,char,char,char,char,char,char,money,money,char,char,char,char,money,char,integer,char,char,char,char,money,money,money,money,char,char,char,money,char,char,integer,char,char,char,char,char,money,money,char,char,char,money,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tipo_conciliacion_pos (char,char,char,char,char,char,char,money,money,char,char,char,char,money,char,integer,char,char,char,char,money,money,money,money,char,char,char,money,char,char,integer,char,char,char,char,char,money,money,char,char,char,money,char,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_tipo_conciliacion_pos (char,char,char,char,char,char,char,money,money,char,char,char,char,money,char,integer,char,char,char,char,money,money,money,money,char,char,char,money,char,char,integer,char,char,char,char,char,money,money,char,char,char,money,char,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_tipo_conciliacion_pos (char,char,char,char,char,char,char,money,money,char,char,char,char,money,char,integer,char,char,char,char,money,money,money,money,char,char,char,money,char,char,integer,char,char,char,char,char,money,money,char,char,char,money,char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reportespos325 (integer,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_reportespos325 (integer,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_reportespos325 (integer,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_reportespos325 (integer,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reportespos325 (integer,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportespos325 (integer,char,char) to "public" as "informix";
grant  execute on function "informix".sp_reporteatmstat07 (integer,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_reporteatmstat07 (integer,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reporteatmstat07 (integer,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_reporteatmstat07 (integer,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_reporteatmstat07 (integer,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporteatmstat07 (integer,char,char) to "public" as "informix";
grant  execute on function "informix".sp_consultatrancred (char,char,char,money) to "public" as "informix";
grant  execute on function "informix".sp_consultatrancred (char,char,char,money) to "ifxprod" as "informix";
grant  execute on function "informix".sp_consultatrancred (char,char,char,money) to "syswallet" as "informix";
grant  execute on function "informix".sp_consultatrancred (char,char,char,money) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultatrancred (char,char,char,money) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_consultatrancred (char,char,char,money) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_consultatrandeb (char,char,char,money) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_consultatrandeb (char,char,char,money) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultatrandeb (char,char,char,money) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_consultatrandeb (char,char,char,money) to "public" as "informix";
grant  execute on function "informix".sp_consultatrandeb (char,char,char,money) to "syswallet" as "informix";
grant  execute on function "informix".sp_consultatrandeb (char,char,char,money) to "ifxprod" as "informix";
grant  execute on function "informix".sp_valida_cadena (lvarchar,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_valida_cadena (lvarchar,char) to "public" as "informix";
grant  execute on function "informix".sp_valida_cadena (lvarchar,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_valida_cadena (lvarchar,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_valida_cadena (lvarchar,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_cadena (lvarchar,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_valida_fecha (char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_valida_fecha (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_fecha (char) to "public" as "informix";
grant  execute on function "informix".sp_valida_fecha (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_valida_fecha (char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_valida_fecha (char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_actualizanivcap (char,char,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_actualizanivcap (char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_actualizanivcap (char,char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_actualizanivcap (char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizanivcap (char,char,date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_actualizanivcap (char,char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_conciladm_concileglounlpba (char,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_conciladm_concileglounlpba (char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_conciladm_concileglounlpba (char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_conciladm_concileglounlpba (char,date) to "public" as "informix";
grant  execute on function "informix".sp_conciladm_concileglounlpba (char,date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_conciladm_concileglounlpba (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_conciladm_concileglounl_pba (char,date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_conciladm_concileglounl_pba (char,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_conciladm_concileglounl_pba (char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_conciladm_concileglounl_pba (char,date) to "public" as "informix";
grant  execute on function "informix".sp_conciladm_concileglounl_pba (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_conciladm_concileglounl_pba (char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_operstatusbloqprev (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_operstatusbloqprev (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_operstatusbloqprev (char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_operstatusbloqprev (char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_operstatusbloqprev (char,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_operstatusbloqprev (char,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_operstatusbloqprev (char,char,char) to "paytrue" as "informix";
grant  execute on function "informix".sp_obtenerdatostransacciondbmovimiento_pos (money,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_obtenerdatostransacciondbmovimiento_pos (money,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtenerdatostransacciondbmovimiento_pos (money,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenerdatostransacciondbmovimiento_pos (money,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_obtenerdatostransacciondbmovimiento_pos (money,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_obtenerdatostransacciondbmovimiento_pos (money,char,char) to "public" as "informix";
grant  execute on procedure "informix".sp_aplica_genconadmin (char,char,char,char,datetime) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_aplica_genconadmin (char,char,char,char,datetime) to "public" as "informix";
grant  execute on procedure "informix".sp_aplica_genconadmin (char,char,char,char,datetime) to "ifxprod" as "informix";
grant  execute on procedure "informix".sp_aplica_genconadmin (char,char,char,char,datetime) to "select_role_intercard" as "informix";
grant  execute on procedure "informix".sp_aplica_genconadmin (char,char,char,char,datetime) to "all_role_intercard" as "informix";
grant  execute on procedure "informix".sp_aplica_genconadmin (char,char,char,char,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_conciliacion_pos (char,char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_conciliacion_pos (char,char,char,integer) to "ifxprod" as "informix";
grant  execute on function "informix".sp_conciliacion_pos (char,char,char,integer) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_conciliacion_pos (char,char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_conciliacion_pos (char,char,char,integer) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_conciliacion_pos (char,char,char,integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_genarchcomi (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_genarchcomi (char,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_genarchcomi (char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_genarchcomi (char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_genarchcomi (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_genarchcomi (char,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_tipo_conciliacion_pos2 (char,char,char,char,char,char,char,money,money,char,char,char,char,money,char,integer,char,char,char,char,money,money,money,money,char,char,char,money,char,char,integer,char,char,char,char,char,money,money,char,char,char,money,char,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_tipo_conciliacion_pos2 (char,char,char,char,char,char,char,money,money,char,char,char,char,money,char,integer,char,char,char,char,money,money,money,money,char,char,char,money,char,char,integer,char,char,char,char,char,money,money,char,char,char,money,char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_tipo_conciliacion_pos2 (char,char,char,char,char,char,char,money,money,char,char,char,char,money,char,integer,char,char,char,char,money,money,money,money,char,char,char,money,char,char,integer,char,char,char,char,char,money,money,char,char,char,money,char,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_tipo_conciliacion_pos2 (char,char,char,char,char,char,char,money,money,char,char,char,char,money,char,integer,char,char,char,char,money,money,money,money,char,char,char,money,char,char,integer,char,char,char,char,char,money,money,char,char,char,money,char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tipo_conciliacion_pos2 (char,char,char,char,char,char,char,money,money,char,char,char,char,money,char,integer,char,char,char,char,money,money,money,money,char,char,char,money,char,char,integer,char,char,char,char,char,money,money,char,char,char,money,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tipo_conciliacion_pos2 (char,char,char,char,char,char,char,money,money,char,char,char,char,money,char,integer,char,char,char,char,money,money,money,money,char,char,char,money,char,char,integer,char,char,char,char,char,money,money,char,char,char,money,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_admintablas_conaut (char,char,char,char,char,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_admintablas_conaut (char,char,char,char,char,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_admintablas_conaut (char,char,char,char,char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_admintablas_conaut (char,char,char,char,char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_admintablas_conaut (char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_admintablas_conaut (char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_genarcherroresconaut (char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_genarcherroresconaut (char,date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_genarcherroresconaut (char,date) to "public" as "informix";
grant  execute on function "informix".sp_genarcherroresconaut (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_genarcherroresconaut (char,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_genarcherroresconaut (char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_insertar_bitacora (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_insertar_bitacora (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_insertar_bitacora (char,char,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_insertar_bitacora (char,char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_insertar_bitacora (char,char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_insertar_bitacora (char,char,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_integridad_conciliacion_auto (char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_integridad_conciliacion_auto (char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_integridad_conciliacion_auto (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_integridad_conciliacion_auto (char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_integridad_conciliacion_auto (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_integridad_conciliacion_auto (char) to "public" as "informix";
grant  execute on function "informix".sp_loadarchivo_conciliacionauto (varchar,varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_loadarchivo_conciliacionauto (varchar,varchar,varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_loadarchivo_conciliacionauto (varchar,varchar,varchar) to "ifxprod" as "informix";
grant  execute on function "informix".sp_loadarchivo_conciliacionauto (varchar,varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_loadarchivo_conciliacionauto (varchar,varchar,varchar) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_loadarchivo_conciliacionauto (varchar,varchar,varchar) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_obtregmonitorconciliacionaut (char,datetime,datetime) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_obtregmonitorconciliacionaut (char,datetime,datetime) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtregmonitorconciliacionaut (char,datetime,datetime) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_obtregmonitorconciliacionaut (char,datetime,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_obtregmonitorconciliacionaut (char,datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_obtregmonitorconciliacionaut (char,datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_esnumericoneg (char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_esnumericoneg (char) to "public" as "informix";
grant  execute on function "informix".sp_esnumericoneg (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_esnumericoneg (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_esnumericoneg (char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_guardarstatusconciliacion (char,datetime,char,char,char,datetime,char,datetime,char,datetime,char,datetime,integer,char,datetime,integer,char,datetime,integer,char,datetime,char,datetime,datetime,char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_guardarstatusconciliacion (char,datetime,char,char,char,datetime,char,datetime,char,datetime,char,datetime,integer,char,datetime,integer,char,datetime,integer,char,datetime,char,datetime,datetime,char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_guardarstatusconciliacion (char,datetime,char,char,char,datetime,char,datetime,char,datetime,char,datetime,integer,char,datetime,integer,char,datetime,integer,char,datetime,char,datetime,datetime,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_guardarstatusconciliacion (char,datetime,char,char,char,datetime,char,datetime,char,datetime,char,datetime,integer,char,datetime,integer,char,datetime,integer,char,datetime,char,datetime,datetime,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_guardarstatusconciliacion (char,datetime,char,char,char,datetime,char,datetime,char,datetime,char,datetime,integer,char,datetime,integer,char,datetime,integer,char,datetime,char,datetime,datetime,char,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_guardarstatusconciliacion (char,datetime,char,char,char,datetime,char,datetime,char,datetime,char,datetime,integer,char,datetime,integer,char,datetime,integer,char,datetime,char,datetime,datetime,char,char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_cons_fechaexp (char,char) to "public" as "informix";
grant  execute on function "informix".sp_cons_fechaexp (char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_cons_fechaexp (char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_cons_fechaexp (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cons_fechaexp (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_cons_fechaexp (char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_obtiene_tarjetas (char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_obtiene_tarjetas (char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_obtiene_tarjetas (char) to "public" as "informix";
grant  execute on function "informix".sp_obtiene_tarjetas (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_obtiene_tarjetas (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_clasifica_devoluciones_pos_pba (varchar,varchar,varchar,varchar,money,varchar,varchar,money,integer,char,datetime) to "public" as "informix";
grant  execute on procedure "informix".sp_clasifica_devoluciones_pos_pba (varchar,varchar,varchar,varchar,money,varchar,varchar,money,integer,char,datetime) to "all_role_intercard" as "informix";
grant  execute on procedure "informix".sp_clasifica_devoluciones_pos_pba (varchar,varchar,varchar,varchar,money,varchar,varchar,money,integer,char,datetime) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_clasifica_devoluciones_pos_pba (varchar,varchar,varchar,varchar,money,varchar,varchar,money,integer,char,datetime) to "syswallet" as "informix";
grant  execute on procedure "informix".sp_clasifica_devoluciones_pos_pba (varchar,varchar,varchar,varchar,money,varchar,varchar,money,integer,char,datetime) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_cargararchivos_conciliacionauto (char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_cargararchivos_conciliacionauto (char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_cargararchivos_conciliacionauto (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cargararchivos_conciliacionauto (char,char) to "public" as "informix";
grant  execute on function "informix".sp_cargararchivos_conciliacionauto (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_cargararchivos_conciliacionauto (char,char) to "syswallet" as "informix";
grant  execute on procedure "informix".sp_clasifica_devoluciones_pos (varchar,varchar,varchar,varchar,money,varchar,varchar,money,integer,char,datetime) to "select_role_intercard" as "informix";
grant  execute on procedure "informix".sp_clasifica_devoluciones_pos (varchar,varchar,varchar,varchar,money,varchar,varchar,money,integer,char,datetime) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_clasifica_devoluciones_pos (varchar,varchar,varchar,varchar,money,varchar,varchar,money,integer,char,datetime) to "public" as "informix";
grant  execute on procedure "informix".sp_clasifica_devoluciones_pos (varchar,varchar,varchar,varchar,money,varchar,varchar,money,integer,char,datetime) to "all_role_intercard" as "informix";
grant  execute on procedure "informix".sp_clasifica_devoluciones_pos (varchar,varchar,varchar,varchar,money,varchar,varchar,money,integer,char,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_conciliacion_pos_registro (char,char,char,char,char,char,char,char,char,money,money,char,char,char,char,char,char,char,money,char) to "public" as "informix";
grant  execute on function "informix".sp_conciliacion_pos_registro (char,char,char,char,char,char,char,char,char,money,money,char,char,char,char,char,char,char,money,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_conciliacion_pos_registro (char,char,char,char,char,char,char,char,char,money,money,char,char,char,char,char,char,char,money,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_conciliacion_pos_registro (char,char,char,char,char,char,char,char,char,money,money,char,char,char,char,char,char,char,money,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_conciliacion_pos_registro (char,char,char,char,char,char,char,char,char,money,money,char,char,char,char,char,char,char,money,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_conciliacion_pos_registro (char,char,char,char,char,char,char,char,char,money,money,char,char,char,char,char,char,char,money,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_exportar_central_sif (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_exportar_central_sif (char,char) to "public" as "informix";
grant  execute on function "informix".sp_exportar_central_sif (char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_exportar_central_sif (char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_exportar_central_sif (char,char) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_exportar_central_sif (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenernombrearchivo (integer) to "public" as "informix";
grant  execute on function "informix".sp_obtenernombrearchivo (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenernombrearchivo (integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_obtenernombrearchivo (integer) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_obtenernombrearchivo (integer) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtenernombrearchivo (integer) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_actualiza_inventarios (varchar,varchar,integer,integer,integer,integer) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_actualiza_inventarios (varchar,varchar,integer,integer,integer,integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_actualiza_inventarios (varchar,varchar,integer,integer,integer,integer) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_actualiza_inventarios (varchar,varchar,integer,integer,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualiza_inventarios (varchar,varchar,integer,integer,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_obtfechahoraservidor (varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_obtfechahoraservidor (varchar) to "public" as "informix";
grant  execute on function "informix".sp_obtfechahoraservidor (varchar) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_obtfechahoraservidor (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtfechahoraservidor (varchar) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtfechahoraservidor (varchar) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_conciladm_concileglounl (char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_conciladm_concileglounl (char,date) to "public" as "informix";
grant  execute on function "informix".sp_conciladm_concileglounl (char,date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_conciladm_concileglounl (char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_conciladm_concileglounl (char,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_conciladm_concileglounl (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_con_buscararchivo (varchar,varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_con_buscararchivo (varchar,varchar) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_con_buscararchivo (varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_con_buscararchivo (varchar,varchar) to "ifxprod" as "informix";
grant  execute on function "informix".sp_con_buscararchivo (varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_con_buscararchivo (varchar,varchar) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_gerenasenalizacion (date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_gerenasenalizacion (date) to "public" as "informix";
grant  execute on function "informix".sp_gerenasenalizacion (date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_gerenasenalizacion (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_gerenasenalizacion (date) to "syswallet" as "informix";
grant  execute on function "informix".sp_conciladm_paserarchivo (varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_conciladm_paserarchivo (varchar,varchar) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_conciladm_paserarchivo (varchar,varchar) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_conciladm_paserarchivo (varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_conciladm_paserarchivo (varchar,varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_concilatm_carga_archivoseglo (char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_concilatm_carga_archivoseglo (char,date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_concilatm_carga_archivoseglo (char,date) to "public" as "informix";
grant  execute on function "informix".sp_concilatm_carga_archivoseglo (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_concilatm_carga_archivoseglo (char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_concilatm_concileglounl (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_concilatm_concileglounl (char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_concilatm_concileglounl (char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_concilatm_concileglounl (char,date) to "public" as "informix";
grant  execute on function "informix".sp_concilatm_concileglounl (char,date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_archivo_coppcnc (date) to "syswallet" as "informix";
grant  execute on function "informix".sp_archivo_coppcnc (date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_archivo_coppcnc (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_archivo_coppcnc (date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_archivo_coppcnc (date) to "public" as "informix";
grant  execute on function "informix".sp_concilatm_carga_archivoseglo_pba (char,date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_concilatm_carga_archivoseglo_pba (char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_concilatm_carga_archivoseglo_pba (char,date) to "public" as "informix";
grant  execute on function "informix".sp_concilatm_carga_archivoseglo_pba (char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_concilatm_carga_archivoseglo_pba (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_tipo_conciliacion_atm (integer,char,integer,char,char,char,char,char,money,money,char,char,char,char,char,integer,char,char,char,char,char,char,char,char,char,char,money,char,char,money,money,money,char,char,char,char,money) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_tipo_conciliacion_atm (integer,char,integer,char,char,char,char,char,money,money,char,char,char,char,char,integer,char,char,char,char,char,char,char,char,char,char,money,char,char,money,money,money,char,char,char,char,money) to "c90306542" as "informix";
grant  execute on function "informix".sp_tipo_conciliacion_atm (integer,char,integer,char,char,char,char,char,money,money,char,char,char,char,char,integer,char,char,char,char,char,char,char,char,char,char,money,char,char,money,money,money,char,char,char,char,money) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tipo_conciliacion_atm (integer,char,integer,char,char,char,char,char,money,money,char,char,char,char,char,integer,char,char,char,char,char,char,char,char,char,char,money,char,char,money,money,money,char,char,char,char,money) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_tipo_conciliacion_atm (integer,char,integer,char,char,char,char,char,money,money,char,char,char,char,char,integer,char,char,char,char,char,char,char,char,char,char,money,char,char,money,money,money,char,char,char,char,money) to "public" as "informix";
grant  execute on function "informix".sp_tipo_conciliacion_atm (integer,char,integer,char,char,char,char,char,money,money,char,char,char,char,char,integer,char,char,char,char,char,char,char,char,char,char,money,char,char,money,money,money,char,char,char,char,money) to "syswallet" as "informix";
grant  execute on function "informix".sp_genconadmin (char,char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_genconadmin (char,char,char,char,char,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_genconadmin (char,char,char,char,char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_genconadmin (char,char,char,char,char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_genconadmin (char,char,char,char,char,date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_genconadmin (char,char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_genconadmincorr (char,char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_genconadmincorr (char,char,char,char,char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_genconadmincorr (char,char,char,char,char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_genconadmincorr (char,char,char,char,char,date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_genconadmincorr (char,char,char,char,char,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_genconadmincorr (char,char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_consultaconadmin (char,date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_consultaconadmin (char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_consultaconadmin (char,date) to "public" as "informix";
grant  execute on function "informix".sp_consultaconadmin (char,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_consultaconadmin (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultaconadmin (char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_interepor (varchar,varchar,varchar) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_interepor (varchar,varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_interepor (varchar,varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_interepor (varchar,varchar,varchar) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_interepor (varchar,varchar,varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_segcamp (varchar,varchar,varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_segcamp (varchar,varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_segcamp (varchar,varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_segcamp (varchar,varchar,varchar) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_segcamp (varchar,varchar,varchar) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_getsecuencia (integer) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_getsecuencia (integer) to "public" as "informix";
grant  execute on function "informix".sp_getsecuencia (integer) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_getsecuencia (integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_getsecuencia (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_getsecuencia (integer) to "ifxprod" as "informix";
grant  execute on function "informix".sp_auditortarjeta () to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_auditortarjeta () to "syswallet" as "informix";
grant  execute on function "informix".sp_auditortarjeta () to "public" as "informix";
grant  execute on function "informix".sp_auditortarjeta () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_auditortarjeta () to "c90306542" as "informix";
grant  execute on function "informix".sp_tras_conadminhis_con (varchar) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_tras_conadminhis_con (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_tras_conadminhis_con (varchar) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_tras_conadminhis_con (varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_tras_conadminhis_con (varchar) to "public" as "informix";
grant  execute on function "informix".sp_idconadminhis_cnc (date) to "public" as "informix";
grant  execute on function "informix".sp_idconadminhis_cnc (date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_idconadminhis_cnc (date) to "syswallet" as "informix";
grant  execute on function "informix".sp_idconadminhis_cnc (date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_idconadminhis_cnc (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_concilatm_concileglo (char,date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_concilatm_concileglo (char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_concilatm_concileglo (char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_concilatm_concileglo (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_concilatm_concileglo (char,date) to "public" as "informix";
grant  execute on function "informix".sp_tarbanda_pba () to "syswallet" as "informix";
grant  execute on function "informix".sp_tarbanda_pba () to "c90306542" as "informix";
grant  execute on function "informix".sp_tarbanda_pba () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_tarbanda_pba () to "public" as "informix";
grant  execute on function "informix".sp_tarbanda_pba () to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_verifica_cp_o_st (char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_verifica_cp_o_st (char,date) to "all_role_intercard" as "informix";
grant  execute on function "informix".sp_verifica_cp_o_st (char,date) to "public" as "informix";
grant  execute on function "informix".sp_verifica_cp_o_st (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_verifica_cp_o_st (char,date) to "intern4" as "informix";
grant  execute on function "informix".sp_verifica_cp_o_st (char,date) to "intern6" as "informix";
grant  execute on function "informix".sp_verifica_cp_o_st (char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_extrae_llave_publica (integer) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_extrae_llave_publica (integer) to "sysinven" as "informix";
grant  execute on function "informix".sp_extrae_llave_publica (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_extrae_llave_publica (integer) to "public" as "informix";
grant  execute on function "informix".sp_extrae_llave_publica (integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_verifica_maquilas () to "sysinven" as "informix";
grant  execute on function "informix".sp_verifica_maquilas () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_verifica_maquilas () to "c90306542" as "informix";
grant  execute on function "informix".sp_verifica_maquilas () to "syswallet" as "informix";
grant  execute on function "informix".sp_verifica_maquilas () to "public" as "informix";
grant  execute on function "informix".sp_informacion_qiubo (datetime,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_informacion_qiubo (datetime,datetime) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_informacion_qiubo (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_informacion_qiubo (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_reportes_conciliacion (varchar,varchar,varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_reportes_conciliacion (varchar,varchar,varchar,varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_reportes_conciliacion (varchar,varchar,varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportes_conciliacion (varchar,varchar,varchar,varchar) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_contacto_vencimiento_debito () to "c90306542" as "informix";
grant  execute on function "informix".sp_contacto_vencimiento_debito () to "public" as "informix";
grant  execute on function "informix".sp_contacto_vencimiento_debito () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_contacto_vencimiento_debito () to "syswallet" as "informix";
grant  execute on function "informix".sp_conciladm_carga_archivoseglo (char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_conciladm_carga_archivoseglo (char,date) to "public" as "informix";
grant  execute on function "informix".sp_conciladm_carga_archivoseglo (char,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_conciladm_carga_archivoseglo (char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_conciladm_carga_archivoseglo (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_reversoeliminatarj (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reversoeliminatarj (char,char) to "public" as "informix";
grant  execute on function "informix".sp_reversoeliminatarj (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reversoeliminatarj (char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_reversoeliminatarj (char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_status_tar_transfer (char,char) to "public" as "informix";
grant  execute on function "informix".sp_status_tar_transfer (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_status_tar_transfer (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_status_tar_transfer (char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_status_tar_transfer (char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_validarlimpiartarjeta (char,char,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_validarlimpiartarjeta (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_validarlimpiartarjeta (char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_validarlimpiartarjeta (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validarlimpiartarjeta (char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_verifica_cancelacion (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_verifica_cancelacion (varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_verifica_cancelacion (varchar) to "public" as "informix";
grant  execute on function "informix".sp_verifica_cancelacion (varchar) to "ifxprod" as "informix";
grant  execute on function "informix".sp_verifica_cancelacion (varchar) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_initeverydays_pba () to "public" as "informix";
grant  execute on function "informix".sp_initeverydays_pba () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_initeverydays_pba () to "syswallet" as "informix";
grant  execute on function "informix".sp_initeverydays_pba () to "c90306542" as "informix";
grant  execute on function "informix".sp_depura_movimientobpi () to "c90306542" as "informix";
grant  execute on function "informix".sp_depura_movimientobpi () to "syswallet" as "informix";
grant  execute on function "informix".sp_depura_movimientobpi () to "public" as "informix";
grant  execute on function "informix".sp_depura_movimientobpi () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_tarjetabanda (varchar) to "public" as "informix";
grant  execute on function "informix".sp_tarjetabanda (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_tarjetabanda (varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_tarjetabanda (varchar) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_reporte_tarjetas_pba () to "c90306542" as "informix";
grant  execute on function "informix".sp_reporte_tarjetas_pba () to "syswallet" as "informix";
grant  execute on function "informix".sp_reporte_tarjetas_pba () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_reporte_tarjetas_pba () to "public" as "informix";
grant  execute on function "informix".sp_bloquea_tarjeta (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_bloquea_tarjeta (char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_bloquea_tarjeta (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_bloquea_tarjeta (char) to "public" as "informix";
grant  execute on function "informix".sp_bloquea_tarjeta (char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_movimientosvi () to "public" as "informix";
grant  execute on function "informix".sp_movimientosvi () to "syswallet" as "informix";
grant  execute on function "informix".sp_movimientosvi () to "c90306542" as "informix";
grant  execute on function "informix".sp_movimientosvi () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_txn_forzadas (varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_txn_forzadas (varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_txn_forzadas (varchar,varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_txn_forzadas (varchar,varchar) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_cancelatarjetas_rob_frau_ext (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_cancelatarjetas_rob_frau_ext (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_cancelatarjetas_rob_frau_ext (char,integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_cancelatarjetas_rob_frau_ext (char,integer) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_reporte_tarjetas () to "c90306542" as "informix";
grant  execute on function "informix".sp_reporte_tarjetas () to "syswallet" as "informix";
grant  execute on function "informix".sp_reporte_tarjetas () to "public" as "informix";
grant  execute on function "informix".sp_reporte_tarjetas () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_actualizabinarqc () to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizabinarqc () to "public" as "informix";
grant  execute on function "informix".sp_actualizabinarqc () to "syswallet" as "informix";
grant  execute on function "informix".sp_actualizabinarqc () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_txn_auto_noauto (varchar,datetime,datetime,char) to "public" as "informix";
grant  execute on function "informix".sp_txn_auto_noauto (varchar,datetime,datetime,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_txn_auto_noauto (varchar,datetime,datetime,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_txn_auto_noauto (varchar,datetime,datetime,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_conciladm_carga_archivoseglo_pba (char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_conciladm_carga_archivoseglo_pba (char,date) to "public" as "informix";
grant  execute on function "informix".sp_conciladm_carga_archivoseglo_pba (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_conciladm_carga_archivoseglo_pba (char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_generartarjetas_pba (varchar) to "ifxprod" as "informix";
grant  execute on function "informix".sp_generartarjetas_pba (varchar) to "public" as "informix";
grant  execute on function "informix".sp_generartarjetas_pba (varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_generartarjetas_pba (varchar) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_generartarjetas_pba (varchar) to "c90306542" as "informix";
grant  execute on function "informix".burofisicas_clon_pba () to "public" as "informix";
grant  execute on function "informix".burofisicas_clon_pba () to "c90306542" as "informix";
grant  execute on function "informix".burofisicas_clon_pba () to "syswallet" as "informix";
grant  execute on function "informix".burofisicas_clon_pba () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_bloqueo_temporal_tarjetas (date,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_bloqueo_temporal_tarjetas (date,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_bloqueo_temporal_tarjetas (date,char) to "public" as "informix";
grant  execute on function "informix".sp_bloqueo_temporal_tarjetas (date,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_metodocaptura () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_metodocaptura () to "public" as "informix";
grant  execute on function "informix".sp_metodocaptura () to "syswallet" as "informix";
grant  execute on function "informix".sp_metodocaptura () to "c90306542" as "informix";
grant  execute on function "informix".sp_trans_his_movimientos (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_trans_his_movimientos (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_trans_his_movimientos (datetime,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_trans_his_movimientos (datetime,datetime) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_desbloqueo_temporal_tarjetas (date,char) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_desbloqueo_temporal_tarjetas (date,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_desbloqueo_temporal_tarjetas (date,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_desbloqueo_temporal_tarjetas (date,char) to "public" as "informix";
grant  execute on function "informix".sp_cancelatarjetas_lote () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_cancelatarjetas_lote () to "c90306542" as "informix";
grant  execute on function "informix".sp_cancelatarjetas_lote () to "public" as "informix";
grant  execute on function "informix".sp_cancelatarjetas_lote () to "syswallet" as "informix";
grant  execute on function "informix".sp_concorresponsales2 (char,date,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_concorresponsales2 (char,date,integer,integer) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_concorresponsales2 (char,date,integer,integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_concorresponsales2 (char,date,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_concorresponsales2 (char,date,integer,integer) to "sysconau" as "informix";
grant  execute on function "informix".sp_concorresponsales2_totales (char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_concorresponsales2_totales (char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_concorresponsales2_totales (char,date) to "public" as "informix";
grant  execute on function "informix".sp_concorresponsales2_totales (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_concorresponsales2_totales (char,date) to "sysconau" as "informix";
grant  execute on function "informix".sp_consultaconadmin2 (char,date,integer,integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_consultaconadmin2 (char,date,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_consultaconadmin2 (char,date,integer,integer) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_consultaconadmin2 (char,date,integer,integer) to "sysconau" as "informix";
grant  execute on function "informix".sp_consultaconadmin2 (char,date,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultaconadmin2_totales (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultaconadmin2_totales (char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_consultaconadmin2_totales (char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_consultaconadmin2_totales (char,date) to "sysconau" as "informix";
grant  execute on function "informix".sp_consultaconadmin2_totales (char,date) to "public" as "informix";
grant  execute on function "informix".sp_consultaconadmincorr2 (char,date,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_consultaconadmincorr2 (char,date,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultaconadmincorr2 (char,date,integer,integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_consultaconadmincorr2 (char,date,integer,integer) to "sysconau" as "informix";
grant  execute on function "informix".sp_consultaconadmincorr2 (char,date,integer,integer) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_consultaconadmincorr2_totales (char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_consultaconadmincorr2_totales (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultaconadmincorr2_totales (char,date) to "sysconau" as "informix";
grant  execute on function "informix".sp_consultaconadmincorr2_totales (char,date) to "public" as "informix";
grant  execute on function "informix".sp_consultaconadmincorr2_totales (char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_concorresponsales (char,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_concorresponsales (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_concorresponsales (char,date) to "public" as "informix";
grant  execute on function "informix".sp_concorresponsales (char,date) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_concorresponsales (char,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_calcula_tarjetasbanda () to "syswallet" as "informix";
grant  execute on function "informix".sp_calcula_tarjetasbanda () to "public" as "informix";
grant  execute on function "informix".sp_calcula_tarjetasbanda () to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_calcula_tarjetasbanda () to "c90306542" as "informix";
grant  execute on function "informix".sp_consultartarjetas_iccat (char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_consultartarjetas_iccat (char,smallint) to "syswallet" as "informix";
grant  execute on function "informix".sp_consultartarjetas_iccat (char,smallint) to "ifxprod" as "informix";
grant  execute on function "informix".sp_consultartarjetas_iccat (char,smallint) to "select_role_intercard" as "informix";
grant  execute on function "informix".sp_consultartarjetas_iccat (char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_bedito_rechazo (varchar,datetime,datetime,char,varchar) to "public" as "informix";
grant  execute on function "informix".sp_bedito_rechazo (varchar,datetime,datetime,char,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_bedito_rechazo (varchar,datetime,datetime,char,varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_reportenegocio_pba () to "public" as "informix";
grant  execute on function "informix".sp_reportenegocio_pba () to "c90306542" as "informix";
grant  execute on function "informix".sp_reportenegocio_pba () to "syswallet" as "informix";
grant  execute on function "informix".sp_txrechazo_pba (varchar,varchar,varchar,varchar,varchar,varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_txrechazo_pba (varchar,varchar,varchar,varchar,varchar,varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_txrechazo_pba (varchar,varchar,varchar,varchar,varchar,varchar,varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_txrechazo (varchar,varchar,varchar,varchar,varchar,varchar,varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_txrechazo (varchar,varchar,varchar,varchar,varchar,varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_txrechazo (varchar,varchar,varchar,varchar,varchar,varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_calcula_caratulaproducto_pba () to "public" as "informix";
grant  execute on function "informix".sp_calcula_caratulaproducto_pba () to "syswallet" as "informix";
grant  execute on function "informix".sp_calcula_caratulaproducto_pba () to "c90306542" as "informix";
grant  execute on function "informix".sp_atmdudoso () to "syswallet" as "informix";
grant  execute on function "informix".sp_atmdudoso () to "c90306542" as "informix";
grant  execute on function "informix".sp_atmdudoso () to "public" as "informix";
grant  execute on function "informix".sp_trans_his_movimientoshistoricos (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_trans_his_movimientoshistoricos (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_trans_his_movimientoshistoricos (datetime,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_trans_his_movimientos_stat_blokes (datetime,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_trans_his_movimientos_stat_blokes (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_trans_his_movimientos_stat_blokes (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_validasolper (varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_validasolper (varchar,varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_ws_appriza_login (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_ws_appriza_login (char) to "public" as "informix";
grant  execute on function "informix".sp_ws_appriza_login (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_validaproducto (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validaproducto (char,char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_validaproducto (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_validaproducto (char,char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_operstatusbloqprev_pba (char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_operstatusbloqprev_pba (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_operstatusbloqprev_pba (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_validaproducto1 (char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_validaproducto1 (char,char,char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_validasolper (varchar,varchar,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_validasolper (varchar,varchar,char) to "public" as "informix";
grant  execute on function "informix".sp_validasolper (varchar,varchar,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_validaexistenciatarjetasbandachip (integer,varchar,varchar,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_validaexistenciatarjetasbandachip (integer,varchar,varchar,integer) to "public" as "informix";
grant  execute on function "informix".sp_validaexistenciatarjetasbandachip (integer,varchar,varchar,integer) to "ifxprod" as "informix";
grant  execute on function "informix".sp_validaexistenciatarjetasbandachip (integer,varchar,varchar,integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_registra_evento (varchar,varchar,char) to "intern4" as "informix";
grant  execute on function "informix".sp_registra_evento (varchar,varchar,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_registra_evento (varchar,varchar,char) to "public" as "informix";
grant  execute on function "informix".sp_registro_bitacora_envio_mensajes (varchar,varchar,char,datetime,money,datetime,varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_registro_bitacora_envio_mensajes (varchar,varchar,char,datetime,money,datetime,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_registro_bitacora_envio_mensajes (varchar,varchar,char,datetime,money,datetime,varchar) to "public" as "informix";
grant  execute on function "informix".sp_notificacion_tarjetas () to "c90306542" as "informix";
grant  execute on function "informix".sp_notificacion_tarjetas () to "public" as "informix";
grant  execute on function "informix".sp_notificacion_tarjetas () to "syswallet" as "informix";
grant  execute on function "informix".sp_reporte_tarjetas_notificadas () to "c90306542" as "informix";
grant  execute on function "informix".sp_reporte_tarjetas_notificadas () to "syswallet" as "informix";
grant  execute on function "informix".sp_reporte_tarjetas_notificadas () to "public" as "informix";
grant  execute on function "informix".sp_transferencia_movhis_stat06 () to "syswallet" as "informix";
grant  execute on function "informix".sp_transferencia_movhis_stat06 () to "public" as "informix";
grant  execute on function "informix".sp_transferencia_movhis_stat06 () to "c90306542" as "informix";
grant  execute on function "informix".sp_puntoscompromiso3 (varchar,varchar,varchar,char,varchar,varchar,date,date,char,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_puntoscompromiso3 (varchar,varchar,varchar,char,varchar,varchar,date,date,char,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_puntoscompromiso3 (varchar,varchar,varchar,char,varchar,varchar,date,date,char,char,smallint) to "syswallet" as "informix";
grant  execute on function "informix".sp_solicitudes_reposiciones_tarjetas () to "c90306542" as "informix";
grant  execute on function "informix".sp_solicitudes_reposiciones_tarjetas () to "public" as "informix";
grant  execute on function "informix".sp_solicitudes_reposiciones_tarjetas () to "syswallet" as "informix";
grant  execute on function "informix".sp_validasolper_web (varchar,varchar,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validasolper_web (varchar,varchar,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_validasolper_web (varchar,varchar,char) to "public" as "informix";
grant  execute on function "informix".sp_reporte_parametrico_rpt (date,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_reporte_parametrico_rpt (date,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_reporte_parametrico_rpt (date,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_activatarjeta_iccat (char,char,char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_activatarjeta_iccat (char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_activatarjeta_iccat (char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_limpiatarjeta_bloqueada_iccat () to "public" as "informix";
grant  execute on function "informix".sp_limpiatarjeta_bloqueada_iccat () to "c90306542" as "informix";
grant  execute on function "informix".sp_limpiatarjeta_bloqueada_iccat () to "syswallet" as "informix";
grant  execute on function "informix".sp_registra_evento (varchar,varchar,char,datetime,varchar,decimal,varchar,char) to "public" as "informix";
grant  execute on function "informix".sp_registra_evento (varchar,varchar,char,datetime,varchar,decimal,varchar,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_registra_evento (varchar,varchar,char,datetime,varchar,decimal,varchar,char) to "intern4" as "informix";
grant  execute on function "informix".sp_validaproducto2 (char,char,char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_validaproducto2 (char,char,char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_validaproducto2 (char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_validaproducto2 (char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validartarjetas_debcred_iccat (char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_validartarjetas_debcred_iccat (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_validartarjetas_debcred_iccat (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validarfechatarjetas_debcred_iccat (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validarfechatarjetas_debcred_iccat (char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_validarfechatarjetas_debcred_iccat (char,char) to "public" as "informix";
grant  execute on function "informix".sp_registraintentos_acttarjetas_iccat (char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_registraintentos_acttarjetas_iccat (char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_registraintentos_acttarjetas_iccat (char,char,char,char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_arqcvalidoshistorico () to "syswallet" as "informix";
grant  execute on function "informix".sp_arqcvalidoshistorico () to "public" as "informix";
grant  execute on function "informix".sp_arqcvalidoshistorico () to "c90306542" as "informix";
grant  execute on function "informix".sp_reporteparametrico (date,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_reporteparametrico (date,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_reporteparametrico (date,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualiza_estadisticas () to "public" as "informix";
grant  execute on function "informix".sp_actualiza_estadisticas () to "syswallet" as "informix";
grant  execute on function "informix".sp_actualiza_estadisticas () to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenerstatustarjetaintercard (integer) to "public" as "informix";
grant  execute on function "informix".sp_obtenerstatustarjetaintercard (integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_obtenerstatustarjetaintercard (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenerstatustarjetaintercard (integer) to "ifxprod" as "informix";
grant  execute on function "informix".sp_movimientobpihistorico () to "c90306542" as "informix";
grant  execute on function "informix".sp_movimientobpihistorico () to "public" as "informix";
grant  execute on function "informix".sp_movimientobpihistorico () to "syswallet" as "informix";
grant  execute on function "informix".sp_synmotor_agregar_campos (integer,char) to "public" as "informix";
grant  execute on function "informix".sp_synmotor_agregar_campos (integer,char) to "sysdish" as "informix";
grant  execute on function "informix".sp_synmotor_agregar_campos (integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_synmotor_agregar_campos (integer,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_synmotor_agregar_parametros (integer,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_synmotor_agregar_parametros (integer,char) to "public" as "informix";
grant  execute on function "informix".sp_synmotor_agregar_parametros (integer,char) to "sysdish" as "informix";
grant  execute on function "informix".sp_synmotor_agregar_parametros (integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_synmotor_getcantidad_infspcampo (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_synmotor_getcantidad_infspcampo (integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_synmotor_getcantidad_infspcampo (integer) to "public" as "informix";
grant  execute on function "informix".sp_synmotor_existeoperacion (char) to "public" as "informix";
grant  execute on function "informix".sp_synmotor_existeoperacion (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_synmotor_existeoperacion (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_synmotor_getcantidadcampos (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_synmotor_getcantidadcampos (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_synmotor_getcantidadcampos (char) to "public" as "informix";
grant  execute on function "informix".sp_synmotor_getcantidadparametros (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_synmotor_getcantidadparametros (char) to "public" as "informix";
grant  execute on function "informix".sp_synmotor_getcantidadparametros (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_synmotor_getelementxml (char,char) to "public" as "informix";
grant  execute on function "informix".sp_synmotor_getelementxml (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_synmotor_getelementxml (char,char) to "sysdish" as "informix";
grant  execute on function "informix".sp_synmotor_getelementxml (char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_synmotor_getinf_campo_sp (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_synmotor_getinf_campo_sp (integer) to "sysdish" as "informix";
grant  execute on function "informix".sp_synmotor_getinf_campo_sp (integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_synmotor_getinf_campo_sp (integer) to "public" as "informix";
grant  execute on function "informix".sp_synmotor_gettrandummy (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_synmotor_gettrandummy (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_synmotor_gettrandummy (char) to "sysdish" as "informix";
grant  execute on function "informix".sp_synmotor_gettrandummy (char) to "public" as "informix";
grant  execute on function "informix".sp_synmotor_geturlws (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_synmotor_geturlws (char) to "public" as "informix";
grant  execute on function "informix".sp_synmotor_geturlws (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_synmotor_insert_bitacorawuheartbeat (varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar) to "sysdish" as "informix";
grant  execute on function "informix".sp_synmotor_insert_bitacorawuheartbeat (varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_synmotor_insert_bitacorawuheartbeat (varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_synmotor_insert_bitacorawuheartbeat (varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_synmotor_insert_mc_estadistica (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_synmotor_insert_mc_estadistica (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_synmotor_insert_mc_estadistica (char) to "public" as "informix";
grant  execute on function "informix".sp_synmotor_insert_mc_estadistica (char) to "sysdish" as "informix";
grant  execute on function "informix".sp_reporteupgrade (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporteupgrade (varchar) to "public" as "informix";
grant  execute on function "informix".sp_reporteupgrade (varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_validaaumentolincred (char) to "public" as "informix";
grant  execute on function "informix".sp_validaaumentolincred (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_validaaumentolincred (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizainventarj (char,char,char,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizainventarj (char,char,char,integer,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_actualizainventarj (char,char,char,integer,char) to "public" as "informix";
grant  execute on function "informix".sp_consultarangotarjetasbanco (integer,char,char,smallint) to "syswallet" as "informix";
grant  execute on function "informix".sp_consultarangotarjetasbanco (integer,char,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultarangotarjetasbanco (integer,char,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_consultatarjetasdan (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultatarjetasdan (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_consultatarjetasdan (char,char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_contacto_vencimiento_credito () to "c90306542" as "informix";
grant  execute on function "informix".sp_contacto_vencimiento_credito () to "public" as "informix";
grant  execute on function "informix".sp_contacto_vencimiento_credito () to "syswallet" as "informix";
grant  execute on function "informix".sp_synmotor_geturlwsdl (integer) to "public" as "informix";
grant  execute on function "informix".sp_synmotor_geturlwsdl (integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_synmotor_geturlwsdl (integer) to "sysdish" as "informix";
grant  execute on function "informix".sp_synmotor_geturlwsdl (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_ws_antad_login (char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_ws_antad_login (char,char) to "public" as "informix";
grant  execute on function "informix".sp_ws_antad_login (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_synmotor_agregar_parametroswsdl_pba1 (integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_synmotor_agregar_parametroswsdl_pba1 (integer,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_synmotor_agregar_parametroswsdl_pba1 (integer,char) to "public" as "informix";
grant  execute on function "informix".sp_obtienebinoropla (char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_obtienebinoropla (char,char) to "public" as "informix";
grant  execute on function "informix".sp_obtienebinoropla (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_muestra_servicios_mov_iccat (char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_muestra_servicios_mov_iccat (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_muestra_servicios_mov_iccat (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_inventariotarjetas (char,char,integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_inventariotarjetas (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_inventariotarjetas (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_synmotor_agregar_parametroswsdl (integer,char) to "public" as "informix";
grant  execute on function "informix".sp_synmotor_agregar_parametroswsdl (integer,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_synmotor_agregar_parametroswsdl (integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_synmotor_getlentotaltrama (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_synmotor_getlentotaltrama (char,char) to "sysdish" as "informix";
grant  execute on function "informix".sp_synmotor_getlentotaltrama (char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_synmotor_getlentotaltrama (char,char) to "public" as "informix";
grant  execute on function "informix".sp_reporte_transaccional_categoria (datetime,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_reporte_transaccional_categoria (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_reporte_transaccional_categoria (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporte_transaccional_categoria (datetime,datetime) to "syseglobal" as "informix";
grant  execute on function "informix".sp_synmotor_agregar_parametroswsdl_mx2 (integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_synmotor_agregar_parametroswsdl_mx2 (integer,char) to "public" as "informix";
grant  execute on function "informix".sp_synmotor_agregar_parametroswsdl_mx2 (integer,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_puntoscompromiso (varchar,varchar,date,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_puntoscompromiso (varchar,varchar,date,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_puntoscompromiso (varchar,varchar,date,date) to "public" as "informix";
grant  execute on function "informix".sp_puntoscompromiso (varchar,varchar,varchar,char,varchar,varchar,date,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_puntoscompromiso (varchar,varchar,varchar,char,varchar,varchar,date,date) to "public" as "informix";
grant  execute on function "informix".sp_tarj_det_vcas_mx2 () to "c90306542" as "informix";
grant  execute on function "informix".sp_tarj_det_vcas_mx2 () to "public" as "informix";
grant  execute on function "informix".sp_tarj_det_vcas_mx2 () to "syswallet" as "informix";
grant  execute on function "informix".sp_trx_mayor_a_tres (datetime,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_trx_mayor_a_tres (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_trx_mayor_a_tres (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_trx_comercios_aut_dia_chip (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_trx_comercios_aut_dia_chip (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_trx_comercios_aut_dia_chip (datetime,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_trx_cvv_dinamico (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_trx_cvv_dinamico (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_trx_cvv_dinamico (datetime,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_trx_top_comercios (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_trx_top_comercios (datetime,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_trx_top_comercios (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_reporte_trxs_semanal (char) to "public" as "informix";
grant  execute on function "informix".sp_reporte_trxs_semanal (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_reporte_trxs_semanal (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_calcular_fechas_semanales () to "c90306542" as "informix";
grant  execute on function "informix".sp_calcular_fechas_semanales () to "public" as "informix";
grant  execute on function "informix".sp_calcular_fechas_semanales () to "syswallet" as "informix";
grant  execute on function "informix".sp_consultar_movimientos (char,datetime,datetime,date) to "public" as "informix";
grant  execute on function "informix".sp_consultar_movimientos (char,datetime,datetime,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_consultar_movimientos (char,datetime,datetime,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizar_tarjetas () to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizar_tarjetas () to "syswallet" as "informix";
grant  execute on function "informix".sp_actualizar_tarjetas () to "public" as "informix";
grant  execute on function "informix".sp_reporte_controltarjetas (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_reporte_controltarjetas (char) to "public" as "informix";
grant  execute on function "informix".sp_reporte_controltarjetas (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tarjetas_lotes_recibidos (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_tarjetas_lotes_recibidos (datetime,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_tarjetas_lotes_recibidos (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporte_cvv_dinamico (char) to "syswallet" as "informix";
grant  execute on function "informix".sp_reporte_cvv_dinamico (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporte_cvv_dinamico (char) to "public" as "informix";
grant  execute on function "informix".sp_tarjetas_por_caja (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_tarjetas_por_caja (datetime,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_tarjetas_por_caja (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_rpt_maq_auto_img_perso () to "syswallet" as "informix";
grant  execute on function "informix".sp_rpt_maq_auto_img_perso () to "public" as "informix";
grant  execute on function "informix".sp_rpt_maq_auto_img_perso () to "c90306542" as "informix";
grant  execute on function "informix".sp_monitoreo_grupo_coppel (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_monitoreo_grupo_coppel (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_monitoreo_grupo_coppel (datetime,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_monitoreo_trx_digitadas (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_monitoreo_trx_digitadas (datetime,datetime) to "syswallet" as "informix";
grant  execute on function "informix".sp_monitoreo_trx_digitadas (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_validatarjetacentralsuc (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validatarjetacentralsuc (char,char) to "public" as "informix";
grant  execute on function "informix".sp_validatarjetacentralsuc (char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_depuracion_tarjetapivote (integer) to "public" as "informix";
grant  execute on function "informix".sp_depuracion_tarjetapivote (integer) to "syswallet" as "informix";
grant  execute on function "informix".sp_depuracion_tarjetapivote (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporte_transaccional_detallado (datetime,datetime,integer,smallint) to "syswallet" as "informix";
grant  execute on function "informix".sp_reporte_transaccional_detallado (datetime,datetime,integer,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporte_transaccional_detallado (datetime,datetime,integer,smallint) to "public" as "informix";
grant  execute on function "informix".sp_procesar_tarjetas_maquila () to "public" as "informix";
grant  execute on function "informix".sp_procesar_tarjetas_maquila () to "c90306542" as "informix";
grant  execute on function "informix".sp_cons_edotarjeta (char) to "public" as "informix";
grant  execute on function "informix".sp_cons_edotarjeta (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_rpt_reporte_parametrico (date,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_rpt_reporte_parametrico (date,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_rpt_validar_fechas_reporte (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_rpt_validar_fechas_reporte (date,date) to "public" as "informix";
grant  execute on function "informix".sp_rpt_obtener_transacciones (datetime,datetime,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_rpt_obtener_transacciones (datetime,datetime,char) to "public" as "informix";
grant  execute on function "informix".sp_rpt_generar_archivo (varchar) to "public" as "informix";
grant  execute on function "informix".sp_rpt_generar_archivo (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_rpt_filtrado_param (datetime,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_rpt_filtrado_param (datetime,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_rpt_calcular_parametros (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_rpt_calcular_parametros (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_consultartarjetas_debcred_iccat (char,char,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultartarjetas_debcred_iccat (char,char,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_rpt_trim_generar_archivos (varchar,varchar,varchar,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_rpt_trim_generar_archivos (varchar,varchar,varchar,char) to "public" as "informix";
grant  execute on function "informix".sp_rpt_trim_obtener_parametros (varchar,varchar,varchar,integer) to "public" as "informix";
grant  execute on function "informix".sp_rpt_trim_obtener_parametros (varchar,varchar,varchar,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_tarj_det_vcas_test () to "public" as "informix";
grant  execute on function "informix".sp_tarj_det_vcas_test () to "c90306542" as "informix";
grant  execute on function "informix".sp_txn_forzadas_mib (varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_txn_forzadas_mib (varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporte_general_corresponsal_mc (datetime,datetime,smallint) to "public" as "informix";
grant  execute on function "informix".sp_reporte_general_corresponsal_mc (datetime,datetime,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_puntoscompro_generaarchivo (char,char,varchar,varchar,varchar,char,varchar,varchar,date,date,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_puntoscompro_generaarchivo (char,char,varchar,varchar,varchar,char,varchar,varchar,date,date,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_puntoscompromiso (varchar,varchar,varchar,char,varchar,varchar,char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_tarj_det_vcas_mc () to "c90306542" as "informix";
grant  execute on function "informix".sp_tarj_det_vcas_mc () to "public" as "informix";
grant  execute on function "informix".sp_reversatarjetasbanco (char,char,integer,char,char) to "public" as "informix";
grant  execute on function "informix".sp_reversatarjetasbanco (char,char,integer,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_depuracion_historica () to "c90306542" as "informix";
grant  execute on function "informix".sp_depuracion_historica () to "public" as "informix";
grant  execute on function "informix".sp_genrep_puntoscompromiso (char,char,varchar,varchar,varchar,char,varchar,varchar,date,date,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_genrep_puntoscompromiso (char,char,varchar,varchar,varchar,char,varchar,varchar,date,date,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultaestatus_tar (char,char) to "public" as "informix";
grant  execute on function "informix".sp_consultaestatus_tar (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_tarjeta_reposicion (char,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_tarjeta_reposicion (char,varchar) to "public" as "informix";
grant  execute on function "informix".sp_muestra_servicios_mov (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_muestra_servicios_mov (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_contador_dias_incidencia () to "public" as "informix";
grant  execute on function "informix".sp_contador_dias_incidencia () to "c90306542" as "informix";
grant  execute on function "informix".sp_reporte_transaccional_categoria_notif (datetime,datetime,smallint) to "public" as "informix";
grant  execute on function "informix".sp_reporte_transaccional_categoria_notif (datetime,datetime,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_move_lotedesucursal (integer,varchar,varchar) to "ifxprod" as "informix";
grant  execute on function "informix".sp_move_lotedesucursal (integer,varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_move_lotedesucursal (integer,varchar,varchar) to "public" as "informix";
grant  execute on procedure "informix".sp_regbitacoracancelcanal (char,char,char,char,datetime) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_regbitacoracancelcanal (char,char,char,char,datetime) to "public" as "informix";
grant  execute on function "informix".sp_cancelatarjeta_canales (char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cancelatarjeta_canales (char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_initeverydays () to "public" as "informix";
grant  execute on function "informix".sp_initeverydays () to "c90306542" as "informix";
grant  execute on function "informix".sp_consultaestatusasignada (char,char) to "public" as "informix";
grant  execute on function "informix".sp_consultaestatusasignada (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_status_tarjeta_usuario (char,char) to "public" as "informix";
grant  execute on function "informix".sp_valida_status_tarjeta_usuario (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultartarjetas_debcred_blodesb_iccat (char,char,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultartarjetas_debcred_blodesb_iccat (char,char,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_notifica_tjtsporexpirar () to "public" as "informix";
grant  execute on function "informix".sp_notifica_tjtsporexpirar () to "c90306542" as "informix";
grant  execute on function "informix".sp_pase_historico_atm () to "public" as "informix";
grant  execute on function "informix".sp_pase_historico_atm () to "c90306542" as "informix";
grant  execute on function "informix".sp_consultartarjetas_debcred_can_iccat (char,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultartarjetas_debcred_can_iccat (char,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_camp_registrar_notificaciones (varchar,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_camp_registrar_notificaciones (varchar,char) to "public" as "informix";
grant  execute on function "informix".sp_tarj_det_vcas_prueba () to "public" as "informix";
grant  execute on function "informix".sp_tarj_det_vcas_prueba () to "c90306542" as "informix";
grant  execute on function "informix".sp_intercard_calcular_periodos (char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_intercard_calcular_periodos (char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_rpt_mc_corresp_retiros_efectivo (varchar,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_rpt_mc_corresp_retiros_efectivo (varchar,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_rpt_mc_obtener_movs_dep_pag (varchar,datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_rpt_mc_obtener_movs_dep_pag (varchar,datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_rpt_mc_generar_archivos (varchar,varchar,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_rpt_mc_generar_archivos (varchar,varchar,char) to "public" as "informix";
grant  execute on function "informix".sp_rpt_mc_corresp_transaccionalidad (varchar,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_rpt_mc_corresp_transaccionalidad (varchar,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_cancelatarjetas_expiradas (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cancelatarjetas_expiradas (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_depura_movimientohistorico () to "c90306542" as "informix";
grant  execute on function "informix".sp_depura_movimientohistorico () to "public" as "informix";
grant  execute on function "informix".sp_trans_movs_depurar_stat06 (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_trans_movs_depurar_stat06 (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_trans_movs_principal (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_trans_movs_principal (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_trans_bitac_envios_principal (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_trans_bitac_envios_principal (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_trans_bitac_envios_depurar (datetime,datetime,char) to "public" as "informix";
grant  execute on function "informix".sp_trans_bitac_envios_depurar (datetime,datetime,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_trans_bitac_envios_pivote (datetime,datetime,char) to "public" as "informix";
grant  execute on function "informix".sp_trans_bitac_envios_pivote (datetime,datetime,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_trans_bitac_envios_unload (datetime,datetime,char) to "public" as "informix";
grant  execute on function "informix".sp_trans_bitac_envios_unload (datetime,datetime,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_comparar_info_tbl_auth () to "c90306542" as "informix";
grant  execute on function "informix".sp_comparar_info_tbl_auth () to "public" as "informix";
grant  execute on function "informix".sp_monitoreocrecimientotablas () to "public" as "informix";
grant  execute on function "informix".sp_monitoreocrecimientotablas () to "c90306542" as "informix";
grant  execute on function "informix".sp_trans_movs_unload_stat06 (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_trans_movs_unload_stat06 (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_cmp_validar_obligatoriedad_ctes (varchar,varchar,varchar,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cmp_validar_obligatoriedad_ctes (varchar,varchar,varchar,char) to "public" as "informix";
grant  execute on function "informix".sp_registra_ctes_notificados () to "public" as "informix";
grant  execute on function "informix".sp_registra_ctes_notificados () to "c90306542" as "informix";
grant  execute on function "informix".sp_comparar_info_tbl_prodtar () to "c90306542" as "informix";
grant  execute on function "informix".sp_comparar_info_tbl_prodtar () to "public" as "informix";
grant  execute on function "informix".sp_trans_movs_pivote_stat06 (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_trans_movs_pivote_stat06 (datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_consultartarjetas_debcred_rep_iccat_exp (char,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_consultartarjetas_debcred_rep_iccat_exp (char,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultartarjetas_debcred_rep_iccat (char,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_consultartarjetas_debcred_rep_iccat (char,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_centinela_rst () to "public" as "informix";
grant  execute on function "informix".sp_centinela_rst () to "c90306542" as "informix";
grant  execute on function "informix".sp_stock_tjts_sucursales () to "c90306542" as "informix";
grant  execute on function "informix".sp_stock_tjts_sucursales () to "public" as "informix";
grant  execute on function "informix".sp_tarj_det_vcas_exp () to "c90306542" as "informix";
grant  execute on function "informix".sp_carga_tarjetas_suc () to "c90306542" as "informix";
grant  execute on function "informix".sp_rpt_mc_obtener_movs_retiros (varchar,datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_camp_proceso_principal (varchar,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_carga_ctas_empleados () to "c90306542" as "informix";
grant  execute on procedure "informix".sp_valida_cambio_status (integer,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizacion_productointercard () to "c90306542" as "informix";
grant  execute on function "informix".sp_corrige_segmento () to "c90306542" as "informix";
grant  execute on function "informix".sp_obtencion_tarjetapivote (char,date,date,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_conciladm_concileglo (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_conciladm_concileglo (char,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_concreing_genarcom_mx4 (char,char,char,char,char,char,char,char,char,char,money,money,money,money) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtienemaquilaauto () to "c90306542" as "informix";
grant  execute on function "informix".sp_monitor_volumen_tablas () to "public" as "informix";
grant  execute on function "informix".sp_monitor_volumen_tablas () to "c90306542" as "informix";
grant  execute on function "informix".sp_manntto_bitacoraspinoffline (datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtiene_cte_contacto_cap (char,varchar) to "public" as "informix";
grant  execute on function "informix".sp_obtiene_cte_contacto_cap (char,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_transmc_inter_cnc_unload (varchar,datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_transmc_inter_cnc_pivote (varchar,datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_transmc_inter_cnc_mover_reg_admin (datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_transmc_inter_cnc_principal (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_vau_obtener_tarjetas () to "c90306542" as "informix";
grant  execute on function "informix".sp_vau_carga_tar_estatus_activas () to "c90306542" as "informix";
grant  execute on function "informix".sp_vau_carga_tar_estatus_final () to "c90306542" as "informix";
grant  execute on function "informix".sp_carga_inicial_vau () to "c90306542" as "informix";
grant  execute on function "informix".sp_camp_obtener_movs_transacc (varchar,datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_msi_validar_archivo_prod (varchar,varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_intercard_info_ctes_por_notif (varchar,char) to "public" as "informix";
grant  execute on function "informix".sp_intercard_info_ctes_por_notif (varchar,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_rpt_vau () to "c90306542" as "informix";
grant  execute on function "informix".sp_reportenegocio_pbajj (char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_initeverydays_ctrlm_pbajj () to "c90306542" as "informix";
grant  execute on function "informix".sp_camp_proceso_principal_pbajj (varchar,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_ctes_tdd_presente_pbajj (varchar,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_depuracion_alertservice () to "c90306542" as "informix";
grant  execute on function "informix".sp_txns_pos_diaria (char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_txns_pos_diaria (char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_consultartarjetas_debcred_iccat_v1 (char,char,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultartarjetas_debcred_rep_iccat_v1 (char,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_inter_cuadrar_inventario_tarjetas () to "c90306542" as "informix";
grant  execute on function "informix".sp_carga_ctes_enrola () to "c90306542" as "informix";
grant  execute on function "informix".sp_generartarjetas_imagenes (varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_generartarjetas_imagenes (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_generartarjetas_imagenes (varchar) to "public" as "informix";
grant  execute on function "informix".sp_horasazules_obtener_tdc_clientes_trace () to "c90306542" as "informix";
grant  execute on function "informix".sp_validar_cliente_bancoppel (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_validar_cliente_coppel (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_generartarjetas_traceon (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_descarga_info_horasazules () to "c90306542" as "informix";
grant  execute on function "informix".sp_horasazules_obtener_tdc_clientes () to "c90306542" as "informix";
grant  execute on function "informix".sp_consultaregtarjeta (varchar,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_oper_corr_oxxo_eleven_aut () to "c90306542" as "informix";
grant  execute on function "informix".sp_limpiatarjeta_web (char,char) to "public" as "informix";
grant  execute on function "informix".sp_limpiatarjeta_web (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validacodprodlineacred (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validacodprodlineacred (char) to "public" as "informix";
grant  execute on function "informix".sp_carga_info_conciliacion_dep (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validacodprodlineacred_pru1 (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_camp_registrar_notificaciones_pru1 (varchar,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_registra_evento (varchar) to "intern4" as "informix";
grant  execute on function "informix".sp_limpiatarjeta (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_limpiatarjeta (char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_limpiatarjeta (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_limpiatarjeta (char,char) to "public" as "informix";
grant  execute on function "informix".sp_rst_notificacion_clientes (varchar,varchar,decimal,integer) to "public" as "informix";
grant  execute on function "informix".sp_rst_notificacion_clientes (varchar,varchar,decimal,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_codprodaumentolinea (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_rpt_trim_consultar_movs (varchar,varchar,varchar,varchar,char,datetime,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_rpt_trim_consultar_movs (varchar,varchar,varchar,varchar,char,datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_rpt_trim_registrar_clientes (varchar,varchar,varchar,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_rpt_trim_registrar_clientes (varchar,varchar,varchar,char) to "public" as "informix";
grant  execute on function "informix".sp_carga_diaria_vau () to "c90306542" as "informix";
grant  execute on function "informix".sp_monitor_rst () to "c90306542" as "informix";
grant  execute on function "informix".sp_monitor_rst () to "public" as "informix";
grant  execute on function "informix".sp_genera_archivo_afiliacion_comercios () to "c90306542" as "informix";
grant  execute on function "informix".sp_validarlimpiartarjeta_n (char,char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_validarlimpiartarjeta_n (char,char,char,integer) to "ifxprod" as "informix";
grant  execute on function "informix".sp_registro_cte_cvv2din (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_registro_cte_cvv2din (varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_registro_cte_cvv2din (varchar) to "intern4" as "informix";
grant  execute on function "informix".sp_registro_cte_cvv2din (varchar) to "public" as "informix";
grant  execute on function "informix".sp_generartarjetas (varchar) to "public" as "informix";
grant  execute on function "informix".sp_generartarjetas (varchar) to "syswallet" as "informix";
grant  execute on function "informix".sp_generartarjetas (varchar) to "ifxprod" as "informix";
grant  execute on function "informix".sp_generartarjetas (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_initeverydays_ctrlm () to "public" as "informix";
grant  execute on function "informix".sp_initeverydays_ctrlm () to "c90306542" as "informix";
grant  execute on function "informix".sp_msi_principal () to "c90306542" as "informix";
grant  execute on function "informix".sp_msi_dbload_archivos (varchar,varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_msi_generar_archivo (varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultartarjetas_debcred_blodesb_iccat_v1 (char,char,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultartarjetas_debcred_can_iccat_v1 (char,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_puntoscompromiso2_totales (varchar,varchar,varchar,char,varchar,varchar,date,date) to "public" as "informix";
grant  execute on function "informix".sp_puntoscompromiso2_totales (varchar,varchar,varchar,char,varchar,varchar,date,date) to "syswallet" as "informix";
grant  execute on function "informix".sp_registra_evento (varchar,varchar,varchar,char,datetime,varchar,varchar,varchar,varchar,varchar,decimal,varchar,char) to "intern4" as "informix";
grant  execute on function "informix".sp_registra_evento (varchar,varchar,varchar,char,datetime,varchar,varchar,varchar,varchar,varchar,decimal,varchar,char) to "public" as "informix";
grant  execute on function "informix".sp_registra_evento (varchar,varchar,varchar,char,datetime,varchar,varchar,varchar,varchar,varchar,decimal,varchar,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_puntoscompromiso3_2 (varchar,varchar,varchar,char,varchar,varchar,date,date,char,char,smallint,char) to "public" as "informix";
grant  execute on function "informix".sp_puntoscompromiso3_2 (varchar,varchar,varchar,char,varchar,varchar,date,date,char,char,smallint,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_confirmapinoffline (char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_confirmapinoffline (char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_confirmapinoffline (char,char,char,char,char,char,char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_reportenegocio () to "public" as "informix";
grant  execute on function "informix".sp_reportenegocio () to "syswallet" as "informix";
grant  execute on function "informix".sp_validaproducto1 (char,char,char,char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_validaproducto1 (char,char,char,char,char,char) to "syswallet" as "informix";
grant  execute on function "informix".sp_validaproducto1 (char,char,char,char,char,char) to "public" as "informix";
revoke  execute on function "informix".sp_tarj_det_vcas_exp () from public as "informix";
revoke  execute on function "informix".sp_carga_tarjetas_suc () from public as "informix";
revoke  execute on function "informix".sp_rpt_mc_obtener_movs_retiros (varchar,datetime,datetime) from public as "informix";
revoke  execute on function "informix".sp_camp_proceso_principal (varchar,char,smallint) from public as "informix";
revoke  execute on function "informix".sp_carga_ctas_empleados () from public as "informix";
revoke  execute on procedure "informix".sp_valida_cambio_status (integer,char,char) from public as "informix";
revoke  execute on function "informix".sp_actualizacion_productointercard () from public as "informix";
revoke  execute on function "informix".sp_corrige_segmento () from public as "informix";
revoke  execute on function "informix".sp_obtencion_tarjetapivote (char,date,date,char) from public as "informix";
revoke  execute on function "informix".sp_conciladm_concileglo (char,date) from public as "informix";
revoke  execute on function "informix".sp_concreing_genarcom_mx4 (char,char,char,char,char,char,char,char,char,char,money,money,money,money) from public as "informix";
revoke  execute on function "informix".sp_obtienemaquilaauto () from public as "informix";
revoke  execute on function "informix".sp_manntto_bitacoraspinoffline (datetime) from public as "informix";
revoke  execute on function "informix".sp_transmc_inter_cnc_unload (varchar,datetime,datetime) from public as "informix";
revoke  execute on function "informix".sp_transmc_inter_cnc_pivote (varchar,datetime,datetime) from public as "informix";
revoke  execute on function "informix".sp_transmc_inter_cnc_mover_reg_admin (datetime,datetime) from public as "informix";
revoke  execute on function "informix".sp_transmc_inter_cnc_principal (varchar) from public as "informix";
revoke  execute on function "informix".sp_vau_obtener_tarjetas () from public as "informix";
revoke  execute on function "informix".sp_vau_carga_tar_estatus_activas () from public as "informix";
revoke  execute on function "informix".sp_vau_carga_tar_estatus_final () from public as "informix";
revoke  execute on function "informix".sp_carga_inicial_vau () from public as "informix";
revoke  execute on function "informix".sp_camp_obtener_movs_transacc (varchar,datetime,datetime) from public as "informix";
revoke  execute on function "informix".sp_msi_validar_archivo_prod (varchar,varchar,varchar) from public as "informix";
revoke  execute on function "informix".sp_rpt_vau () from public as "informix";
revoke  execute on function "informix".sp_reportenegocio_pbajj (char,smallint) from public as "informix";
revoke  execute on function "informix".sp_initeverydays_ctrlm_pbajj () from public as "informix";
revoke  execute on function "informix".sp_camp_proceso_principal_pbajj (varchar,char,smallint) from public as "informix";
revoke  execute on function "informix".sp_ctes_tdd_presente_pbajj (varchar,integer) from public as "informix";
revoke  execute on function "informix".sp_depuracion_alertservice () from public as "informix";
revoke  execute on function "informix".sp_consultartarjetas_debcred_iccat_v1 (char,char,char,smallint) from public as "informix";
revoke  execute on function "informix".sp_consultartarjetas_debcred_rep_iccat_v1 (char,char,smallint) from public as "informix";
revoke  execute on function "informix".sp_inter_cuadrar_inventario_tarjetas () from public as "informix";
revoke  execute on function "informix".sp_carga_ctes_enrola () from public as "informix";
revoke  execute on function "informix".sp_horasazules_obtener_tdc_clientes_trace () from public as "informix";
revoke  execute on function "informix".sp_validar_cliente_bancoppel (varchar) from public as "informix";
revoke  execute on function "informix".sp_validar_cliente_coppel (varchar) from public as "informix";
revoke  execute on function "informix".sp_generartarjetas_traceon (varchar) from public as "informix";
revoke  execute on function "informix".sp_descarga_info_horasazules () from public as "informix";
revoke  execute on function "informix".sp_horasazules_obtener_tdc_clientes () from public as "informix";
revoke  execute on function "informix".sp_consultaregtarjeta (varchar,integer,integer) from public as "informix";
revoke  execute on function "informix".sp_oper_corr_oxxo_eleven_aut () from public as "informix";
revoke  execute on function "informix".sp_carga_info_conciliacion_dep (char,char) from public as "informix";
revoke  execute on function "informix".sp_validacodprodlineacred_pru1 (char) from public as "informix";
revoke  execute on function "informix".sp_camp_registrar_notificaciones_pru1 (varchar,char) from public as "informix";
revoke  execute on function "informix".sp_registra_evento (varchar) from public as "informix";
revoke  execute on function "informix".sp_ajuste_cvv2 (char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_migra_oro_plat_reporte () from public as "informix";
revoke  execute on function "informix".sp_codprodaumentolinea (char) from public as "informix";
revoke  execute on function "informix".sp_elimina_mj_vau () from public as "informix";
revoke  execute on function "informix".busca_pasadovau () from public as "informix";
revoke  execute on function "informix".sp_carga_diaria_vau () from public as "informix";
revoke  execute on function "informix".sp_consultatarjetabin_pba (char,integer,char,char) from public as "informix";
revoke  execute on function "informix".sp_consultatarjetabin_pba1 (char,integer,char,char) from public as "informix";
revoke  execute on function "informix".sp_consultatarjetabin_pba2 (char,integer,char,char) from public as "informix";
revoke  execute on function "informix".sp_genera_archivo_afiliacion_comercios () from public as "informix";
revoke  execute on function "informix".sp_validarlimpiartarjeta_n (char,char,char,integer) from public as "informix";
revoke  execute on function "informix".sp_consultatarjetabin (char,integer,char,char) from public as "informix";
revoke  execute on function "informix".sp_consulta_cte_cvv2din_tjts (varchar) from public as "informix";
revoke  execute on function "informix".sp_inicia_carga_sus_final () from public as "informix";
revoke  execute on procedure "informix".sp_tr_tarjeta_vcas (varchar,varchar,varchar,datetime,varchar) from public as "informix";
revoke  execute on function "informix".sp_depura_bitacora_tokenizacion_otp () from public as "informix";
revoke  execute on function "informix".sp_depura_bitacora_token_digitalcard () from public as "informix";
revoke  execute on function "informix".sp_depura_bitacora_token_cardoperation () from public as "informix";
revoke  execute on function "informix".sp_depura_cardsid_tokenizadas () from public as "informix";
revoke  execute on function "informix".sp_omologa_tdc_can () from public as "informix";
revoke  execute on function "informix".sp_msi_principal () from public as "informix";
revoke  execute on function "informix".sp_msi_dbload_archivos (varchar,varchar,varchar) from public as "informix";
revoke  execute on function "informix".sp_msi_modifica_registros () from public as "informix";
revoke  execute on function "informix".sp_msi_generar_archivo (varchar,varchar) from public as "informix";
revoke  execute on function "informix".sp_tokenizacion_cardoperation (char,char,char,char,char,lvarchar,char) from public as "informix";
revoke  execute on function "informix".sp_tokenizacion_cliente (char,char,char) from public as "informix";
revoke  execute on function "informix".sp_tokenizacion_deliverotp (char,char,char,char,char,char,char,char,char,lvarchar,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_tokenizacion_digitalcardoperation (char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_tokenizacion_getconsumerinfo (char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_tokenizacion_ciclo_vida () from public as "informix";
revoke  execute on function "informix".sp_consultartarjetas_debcred_blodesb_iccat_v1 (char,char,char,smallint) from public as "informix";
revoke  execute on function "informix".sp_consultartarjetas_debcred_can_iccat_v1 (char,char,smallint) from public as "informix";
revoke  execute on function "informix".sp_conciliacionautomatica_atm_stat06_pagos (varchar,integer) from public as "informix";
revoke  execute on function "informix".sp_conciliacionautomatica_dep_atm (varchar,integer) from public as "informix";
revoke  execute on function "informix".sp_nombre_archivo_atm_stat06_pagos () from public as "informix";
revoke  execute on function "informix".sp_nombre_archivo_dep_atm () from public as "informix";
revoke  execute on function "informix".sp_solicitud_manual_maquila_tarjetas_personalizadas () from public as "informix";
revoke  execute on function "informix".sp_cnc_coppel_plazos_fijos_tarjetas () from public as "informix";
revoke  execute on function "informix".sp_homologacion_estatus_tarjetas (integer) from public as "informix";
revoke  execute on function "informix".sp_sol_maq_per_dup () from public as "informix";
revoke  execute on function "informix".sp_homologacion_tarjeta_general (integer,varchar,char) from public as "informix";
revoke  execute on function "informix".sp_homologacion_tarjeta_normal (integer) from public as "informix";
revoke  execute on function "informix".sp_tokenizacion_consultatarjeta (char,char,char,char,char,char,varchar,char) from public as "informix";
revoke  execute on function "informix".sp_gen_reporte_vcas () from public as "informix";
revoke  execute on function "informix".sp_descarga_credenciales_vcas (char) from public as "informix";
revoke  execute on function "informix".sp_tarj_det_vcas () from public as "informix";
revoke  execute on function "informix".sp_tarj_det_vcas_ext () from public as "informix";
revoke  execute on function "informix".sp_cierre_sucursal (varchar,varchar,char) from public as "informix";
revoke  execute on function "informix".sp_consultatarjetabin_pba2 (char,integer,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_consultatarjetabin_pba (char,integer,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_consultatarjetabin (char,integer,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_cancelacion_tarjetas_expiradas () from public as "informix";
revoke  execute on function "informix".sp_consultatarjetabini_02_pbajlh (char,integer,char,char) from public as "informix";
revoke  execute on function "informix".sp_consultatarjetabin_01_pbajlh (char,integer,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_clientes_tokenizacion () from public as "informix";

revoke usage on language SPL from public ;

grant usage on language SPL to public ;

grant usage on language SPL to ifxcons ;

grant usage on language SPL to ifxdesaa ;

grant usage on language SPL to ifxprod ;

grant usage on language SPL to ifxconsacc ;

grant usage on language SPL to ifxsopsuc ;


grant select on "informix".seq_consecutivo_archivo to "ifxcons" as "informix";
grant select on "informix".seq_consecutivo_archivo to "ifxconsacc" as "informix";
grant select on "informix".seq_consecutivo_archivo to "ifxdesaa" as "informix";
grant alter on "informix".seq_consecutivo_archivo to "ifxdesaa" as "informix";
grant select on "informix".seq_consecutivo_archivo to "ifxprod" as "informix";
grant alter on "informix".seq_consecutivo_archivo to "ifxprod" as "informix";
grant select on "informix".seq_consecutivo_archivo to "public" as "informix";
grant select on "informix".seq_consecutivo_archivo to "sysctrlinfo" as "informix";
grant select on "informix".secuenceinteract to "ifxcons" as "informix";
grant select on "informix".secuenceinteract to "ifxconsacc" as "informix";
grant select on "informix".secuenceinteract to "ifxdesaa" as "informix";
grant alter on "informix".secuenceinteract to "ifxdesaa" as "informix";
grant select on "informix".secuenceinteract to "ifxprod" as "informix";
grant alter on "informix".secuenceinteract to "ifxprod" as "informix";
grant select on "informix".secuenceinteract to "public" as "informix";
grant select on "informix".secuenceinteract to "sysctrlinfo" as "informix";
grant select on "informix".secuencia_clavetipo to "ifxcons" as "informix";
grant select on "informix".secuencia_clavetipo to "ifxconsacc" as "informix";
grant select on "informix".secuencia_clavetipo to "ifxdesaa" as "informix";
grant alter on "informix".secuencia_clavetipo to "ifxdesaa" as "informix";
grant select on "informix".secuencia_clavetipo to "ifxprod" as "informix";
grant alter on "informix".secuencia_clavetipo to "ifxprod" as "informix";
grant select on "informix".secuencia_clavetipo to "public" as "informix";
grant select on "informix".secuencia_clavetipo to "sysctrlinfo" as "informix";
grant select on "informix".secuencia_imagenprede to "ifxcons" as "informix";
grant select on "informix".secuencia_imagenprede to "ifxconsacc" as "informix";
grant select on "informix".secuencia_imagenprede to "ifxdesaa" as "informix";
grant alter on "informix".secuencia_imagenprede to "ifxdesaa" as "informix";
grant select on "informix".secuencia_imagenprede to "ifxprod" as "informix";
grant alter on "informix".secuencia_imagenprede to "ifxprod" as "informix";
grant select on "informix".secuencia_imagenprede to "public" as "informix";
grant select on "informix".secuencia_imagenprede to "sysctrlinfo" as "informix";
grant select on "informix".secuencia_parametromaquila to "ifxcons" as "informix";
grant select on "informix".secuencia_parametromaquila to "ifxconsacc" as "informix";
grant select on "informix".secuencia_parametromaquila to "ifxdesaa" as "informix";
grant alter on "informix".secuencia_parametromaquila to "ifxdesaa" as "informix";
grant select on "informix".secuencia_parametromaquila to "ifxprod" as "informix";
grant alter on "informix".secuencia_parametromaquila to "ifxprod" as "informix";
grant select on "informix".secuencia_parametromaquila to "public" as "informix";
grant select on "informix".secuencia_parametromaquila to "sysctrlinfo" as "informix";
grant select on "informix".secuencia_productoimagen to "ifxcons" as "informix";
grant select on "informix".secuencia_productoimagen to "ifxconsacc" as "informix";
grant select on "informix".secuencia_productoimagen to "ifxdesaa" as "informix";
grant alter on "informix".secuencia_productoimagen to "ifxdesaa" as "informix";
grant select on "informix".secuencia_productoimagen to "ifxprod" as "informix";
grant alter on "informix".secuencia_productoimagen to "ifxprod" as "informix";
grant select on "informix".secuencia_productoimagen to "public" as "informix";
grant select on "informix".secuencia_productoimagen to "sysctrlinfo" as "informix";
grant select on "informix".secuencia_provedormaq to "ifxcons" as "informix";
grant select on "informix".secuencia_provedormaq to "ifxconsacc" as "informix";
grant select on "informix".secuencia_provedormaq to "ifxdesaa" as "informix";
grant alter on "informix".secuencia_provedormaq to "ifxdesaa" as "informix";
grant select on "informix".secuencia_provedormaq to "ifxprod" as "informix";
grant alter on "informix".secuencia_provedormaq to "ifxprod" as "informix";
grant select on "informix".secuencia_provedormaq to "public" as "informix";
grant select on "informix".secuencia_provedormaq to "sysctrlinfo" as "informix";
grant select on "informix".secuencia_solmaquila to "ifxcons" as "informix";
grant select on "informix".secuencia_solmaquila to "ifxconsacc" as "informix";
grant select on "informix".secuencia_solmaquila to "ifxdesaa" as "informix";
grant alter on "informix".secuencia_solmaquila to "ifxdesaa" as "informix";
grant select on "informix".secuencia_solmaquila to "ifxprod" as "informix";
grant alter on "informix".secuencia_solmaquila to "ifxprod" as "informix";
grant select on "informix".secuencia_solmaquila to "public" as "informix";
grant select on "informix".secuencia_solmaquila to "sysctrlinfo" as "informix";
grant select on "informix".seq_servicealert to "ifxcons" as "informix";
grant select on "informix".seq_servicealert to "ifxconsacc" as "informix";
grant select on "informix".seq_servicealert to "ifxdesaa" as "informix";
grant alter on "informix".seq_servicealert to "ifxdesaa" as "informix";
grant select on "informix".seq_servicealert to "ifxprod" as "informix";
grant alter on "informix".seq_servicealert to "ifxprod" as "informix";
grant select on "informix".seq_servicealert to "public" as "informix";
grant select on "informix".seq_servicealert to "sysctrlinfo" as "informix";
grant select on "informix".secuencia_folioasignacionactivacion to "ifxcons" as "informix";
grant select on "informix".secuencia_folioasignacionactivacion to "ifxconsacc" as "informix";
grant select on "informix".secuencia_folioasignacionactivacion to "ifxdesaa" as "informix";
grant alter on "informix".secuencia_folioasignacionactivacion to "ifxdesaa" as "informix";
grant select on "informix".secuencia_folioasignacionactivacion to "ifxprod" as "informix";
grant alter on "informix".secuencia_folioasignacionactivacion to "ifxprod" as "informix";
grant select on "informix".secuencia_folioasignacionactivacion to "sysctrlinfo" as "informix";
create index "informix".idx_gironegocio on "informix".gironegocio 
    (codgironeg) using btree  in datos03;
create index "informix".idx_parametros on "informix".parametros 
    (fiid) using btree  in dbs_cierrecred5;
create index "informix".idx_parametros2 on "informix".parametros 
    (usuario,sucursal) using btree  in dbs_cierrecred5;
create index "informix".numtarjeta on "informix".tarjetacuenta 
    (numtarjeta) using btree  in dbstarjetacuenta;
create index "informix".idx_clave_nombre_sucursal on "informix"
    .sucursal (clave_sucursal,nombre_sucursal) using btree  in 
    datos01_idx;
create index "informix".idx_productotarjeta_2 on "informix".productotarjeta 
    (permitetransdigitadas) using btree  in db_cheqhist03;
create index "informix".idx_bines on "informix".bines (creditodebito) 
    using btree  in datos00;
create index "informix".idx_bines2 on "informix".bines (prefijo) 
    using btree  in datos00;
create index "informix".fecha on "informix".detalle_maquila (fecha_generacion) 
    using btree  in datos00;
create index "informix".idx_clave_sucursal on "informix".detalle_maquila 
    (clave_sucursal) using btree  in idx_info04;
create index "informix".idx_idsolicitud on "informix".detalle_maquila 
    (idsolicitud) using btree  in dbs_cfd_idxs;
create index "informix".ind_detalle_maquila_01 on "informix".detalle_maquila 
    (numtarjeta) using btree  in datos00;
create index "informix".indx_idsolmaquila on "informix".detalle_maquila 
    (idsolmaquila) using btree  in datos00;
create index "informix".indx_idsolmaquila_provedormaquila on 
    "informix".detalle_maquila (idsolmaquila,provedormaquila) 
    using btree  in datos00;
create index "informix".numlote on "informix".detalle_maquila 
    (numlote) using btree  in datos00;
create index "informix".bitacora_conciliacion_keyx_index on "informix"
    .bitacora_conciliacion (keyx) using btree  in datos00;
create index "informix".idx_bitacora_conciliacion on "informix"
    .bitacora_conciliacion (fechaconciliacion,actividad,archivoorigen) 
    using btree  in datos00;
create index "c92357113".cat_paisdivisa_cod_divisa_index on "c92357113"
    .cat_paisdivisa (cod_divisa) using btree  in datos00;
create index "c92357113".cat_paisdivisa_keyx_index on "c92357113"
    .cat_paisdivisa (keyx) using btree  in datos00;
create index "c92357113".cat_comisioninterempresas_keyx_index 
    on "c92357113".cat_comisioninterempresas (keyx) using btree 
     in datos00;
create index "informix".cat_comisioninterempresas_rfc_empresa_index 
    on "c92357113".cat_comisioninterempresas (rfc) using btree 
     in datos00;
create index "informix".conciliacion_pos_in_archivoorigen_index 
    on "informix".conciliacion_pos_in (archivoorigen) using btree 
     in datos00;
create index "informix".conciliacion_pos_in_keyx_index on "informix"
    .conciliacion_pos_in (keyx) using btree  in datos00;
create index "informix".idx_sucursal_tipotarjeta on "informix"
    .sucursal_tipotarjeta (clave_tipotarjeta) using btree  in 
    datos00;
create index "informix".idx_clavetipotarjeta_leyenda_descripcion 
    on "informix".tipotarjeta (clave_tipotarjeta,leyendatarjeta,
    descripcion) using btree  in datos01_idx;
create index "informix".idx_tipotarjeta on "informix".tipotarjeta 
    (chip) using btree  in datos00;
create index "informix".idx_lote on "informix".lote (clave_tipotarjeta,
    numerolote) using btree  in datos03;
create index "informix".idx_tbllote_clave_sucursal_clave_tipotarjeta 
    on "informix".lote (clave_tipotarjeta,clave_sucursal) using 
    btree  in datos01_idx;
create index "informix".idx_estadisticatarjetasuc on "informix"
    .estadisticatarjetasuc (clave_tipotarjeta,fecha) using btree 
     in datos00;
create index "informix".idx_param_conciliacionauto on "informix"
    .param_conciliacionauto (descripcion) using btree  in datos00;
    
create index "informix".param_conciliacionauto_keyx_index on 
    "informix".param_conciliacionauto (keyx) using btree  in datos00;
    
create index "informix".con_archerrint_index1 on "informix".con_archerrint 
    (fechaconciliacion,archivoorigen) using btree  in datos00;
    
create index "informix".idx_con_archerrint2 on "informix".con_archerrint 
    (fechaconciliacion) using btree  in datos00;
create index "informix".syserror_conciliacion_index1 on "informix"
    .syserror_conciliacion (fecha,nom_archivo) using btree  in 
    datos00;
create index "informix".syserror_conciliacion_keyx_index on "informix"
    .syserror_conciliacion (keyx) using btree  in datos00;
create index "informix".idx_monitor_conciliacionaut on "informix"
    .monitor_conciliacionaut (fechaconciliacion,nom_archivo,archivoorigen) 
    using btree  in datos00;
create index "informix".idx_monitor_conciliacionaut2 on "informix"
    .monitor_conciliacionaut (nom_archivo) using btree  in datos00;
    
create index "informix".idx_monitor_conciliacionaut3 on "informix"
    .monitor_conciliacionaut (fechaconciliacion) using btree 
     in datos00;
create index "informix".conarchcomisiones1 on "informix".conarchcomisiones 
    (nomarchivocom) using btree  in datos00;
create index "informix".conarchcomisiones2 on "informix".conarchcomisiones 
    (fechamov) using btree  in datos00;
create index "informix".idx_conarchcomisiones3 on "informix".conarchcomisiones 
    (archivoorigen,nomarchivocom,fechamov) using btree  in datos00;
    
create index "informix".idx_monitor_conciliacionman on "informix"
    .monitor_conciliacionman (nom_archivo) using btree  in datos00;
    
create index "informix".idx01info_tarjeta_pyt2_historico on "informix"
    .info_tarjeta_pyt_historico (numtarjeta) using btree  in 
    datos00;
create index "informix".idx01info_tarjeta_pyt3_historico on "informix"
    .info_tarjeta_pyt_historico (codstatustarjeta,fechaasignacion) 
    using btree  in datos00_idx;
create index "informix".idx01info_tarjeta_pyt_historico on "informix"
    .info_tarjeta_pyt_historico (fechaultmodif) using btree  
    in datos00;
create index "informix".idx01conciladm_archeglo on "informix".conciladm_archeglo 
    (registro) using btree  in datos00;
create index "informix".idx01conciladm_archegloposacum on "informix"
    .conciladm_archegloposacum (fecha_mov) using btree  in datos00;
    
create index "informix".idx01conciladm_eglopos on "informix".conciladm_eglopos 
    (secuencia_e) using btree  in datos00;
create index "informix".idx02conciladm_eglopos on "informix".conciladm_eglopos 
    (secuencia_e,tipo_mov_e,fecha_mov_e) using btree  in datos00;
    
create index "informix".idx03conciladm_eglopos on "informix".conciladm_eglopos 
    (nomarchivo_e) using btree  in datos00;
create index "informix".idx04conciladm_eglopos on "informix".conciladm_eglopos 
    (fecha_mov_e) using btree  in dbs_movhis_idx3;
create index "informix".idx05conciladm_eglopos on "informix".conciladm_eglopos 
    (fecha_mov_s) using btree  in dbs_movhis_idx3;
create index "informix".idx06conciladm_eglopos on "informix".conciladm_eglopos 
    (fecha_mov_e,nro_tarjeta_e) using btree  in datos00;
create index "informix".idx07conciladm_eglopos on "informix".conciladm_eglopos 
    (fecha_mov_s,nro_tarjeta_e) using btree  in datos00;
create index "informix".idx01conciladm_sifegloposacum on "informix"
    .conciladm_sifegloposacum (fecha_mov) using btree  in datos00;
    
create index "infromix".apeestatusenv on "informix".archivospendenvio 
    (idenviopend) using btree  in datos00;
create index "informix".idxallfields_revi on "informix".bitacoratransrevi 
    (sbranchnumber,sconfirmationnumber,sagentusername,codigoretorno,
    operationalcode,fechahorainserccion) using btree  in datos00;
    
create index "informix".idxbranchnumber_revi on "informix".bitacoratransrevi 
    (sbranchnumber) using btree  in datos00;
create index "informix".idxcodret_revi on "informix".bitacoratransrevi 
    (codigoretorno) using btree  in datos00;
create index "informix".idxdateinsert_revi on "informix".bitacoratransrevi 
    (fechahorainserccion) using btree  in datos00;
create index "informix".idxnumconfirm_revi on "informix".bitacoratransrevi 
    (sconfirmationnumber) using btree  in datos00;
create index "informix".idxopercod_revi on "informix".bitacoratransrevi 
    (operationalcode) using btree  in datos00;
create index "informix".idxsagentusername_revi on "informix".bitacoratransrevi 
    (sagentusername) using btree  in datos00;
create index "informix".idx_sen_credito on "informix".senalizacion_credito 
    (periodo,n_suc) using btree  in datos00;
create index "informix".idx_sen_debito on "informix".senalizacion_debito 
    (periodo,n_suc) using btree  in datos00;
create index "informix".idx_credito_vip on "informix".vencimiento_credito_vip 
    (periodo,sucursal) using btree  in datos00;
create index "informix".idx_debito_vip on "informix".vencimiento_debito_vip 
    (periodo,sucursal) using btree  in datos00;
create index "informix".idx_debito_altransac on "informix".vencimiento_debito_altransac 
    (periodo,sucursal) using btree  in datos00;
create index "informix".idx_hsmkey_idtype on "informix".hsmkey 
    (key_id,key_type) using btree  in datos00;
create index "informix".idx_key_id on "informix".hsmkey (key_id) 
    using btree  in dbs_idxinteg;
create index "informix".idx_key_type on "informix".hsmkey (key_type) 
    using btree  in idx_his_edocta1;
create index "informix".idx_conci_redtcat137d on "informix".conciliacion_redtcat137d 
    (fechaconciliacion,keyx) using btree  in datos00;
create index "informix".idx01concilatm_archeglo on "informix".concilatm_archeglo 
    (registro) using btree  in datos00;
create index "informix".idx_bittrnslgn on "informix".bitacoratranslogon 
    (process_dt,opcode) using btree  in datos00;
create index "informix".idx_codretbts on "informix".codretornobts 
    (codigo) using btree  in datos00;
create index "informix".idx_cantidad_old on "informix".estadisticabts_old 
    (cantidad) using btree  in dbs_cfd_idxs;
create index "informix".idx_estadbts_old on "informix".estadisticabts_old 
    (fecha,grupo) using btree  in datos00;
create index "informix".idx_grupo_old on "informix".estadisticabts_old 
    (grupo) using btree  in dbs_cfd_idxs;
create index "informix".idx_tarjxact on "informix".tarjxact (no_tarjeta) 
    using btree  in datos00;
create index "informix".idx_reptarj1 on "informix".rep_tarjetas 
    (tarjeta) using btree  in datos00;
create index "informix".idx_reptarj2 on "informix".rep_tarjetas 
    (status) using btree  in datos00;
create index "informix".idx01conciliacion_atm_es on "informix"
    .conciliacion_atm_es (secuenciaut_e) using btree  in datos00;
    
create index "informix".idx02conciliacion_atm_es on "informix"
    .conciliacion_atm_es (fechaconciliacion_e,secuenciaut_e) 
    using btree  in datos00;
create index "informix".idx03conciliacion_atm_es on "informix"
    .conciliacion_atm_es (nombre_arc) using btree  in datos00;
    
create index "informix".idx04conciliacion_atm_es on "informix"
    .conciliacion_atm_es (fechaconciliacion_e) using btree  in 
    datos00;
create index "informix".idx05conciliacion_atm_es on "informix"
    .conciliacion_atm_es (fecha_s) using btree  in datos00;
create index "informix".idx06conciliacion_atm_es on "informix"
    .conciliacion_atm_es (numtarjeta_e,codigoiso_e) using btree 
     in datos00;
create index "informix".idx01concilatm_sifegloposacum on "informix"
    .concilatm_sifegloposacum (fecha_mov) using btree  in datos00;
    
create index "informix".idx_tempfac_establecimiento on "informix"
    .tempfac_establecimiento (producto) using btree  in datos03;
    
create index "informix".idx_tempfac_establecimiento1 on "informix"
    .tempfac_establecimiento (periodo) using btree  in datos03;
    
create index "informix".idx_tempfac_establecimiento2 on "informix"
    .tempfac_establecimiento (esnacional) using btree  in datos03;
    
create index "informix".idx_tempfacgiro_negocio1 on "informix"
    .tempfacgiro_negocio (periodo) using btree  in datos03;
create index "informix".idx_tempfacgiro_negocio2 on "informix"
    .tempfacgiro_negocio (producto) using btree  in datos03;
create index "informix".idx_tempfacgiro_negocio3 on "informix"
    .tempfacgiro_negocio (esnacional) using btree  in datos03;
    
create index "informix".idx_movconciliados on "informix".movconciliados 
    (fechahorainauth) using btree  in datos03;
create index "informix".idx_wsbitacoralogin_old_01 on "informix"
    .wsbitacoralogin_old (id_sesion,datetimeinsert) using btree 
     in dbs_movhis_idx5;
create index "informix".idx_conadmin4 on "informix".conadmin (archivoorigen,
    nomarchivo325,nomarchivocom,fecharegistro) using btree  in 
    datos00;
create index "informix".index_conadmin1 on "informix".conadmin 
    (fecharegistro) using btree  in datos00;
create index "informix".index_conadmin2 on "informix".conadmin 
    (nomarchivocom) using btree  in datos00;
create index "informix".index_conadmin3 on "informix".conadmin 
    (nomarchivo325,nomarchivocom,tiporegistro,estatus,tipooperacion) 
    using btree  in datos00;
create index "informix".index_conadmin4 on "informix".conadmin 
    (nomarchivo325) using btree  in datos00;
create index "informix".index_conadmin5 on "informix".conadmin 
    (keyx) using btree  in datos00;
create index "informix".idx_estadisticautorizacion on "informix"
    .estadisticautorizacion (periodo) using btree  in datos03;
    
create index "informix".idx_bitacwsgdf on "informix".bitacorawsgdf 
    (linea_cap,fecha_insert) using btree  in datos00;
create index "informix".idx_wsimpgdfscfg on "informix".wsimpuestoscfg 
    (destination) using btree  in datos00;
create index "informix".idx_bandacontrol3 on "informix".td_bandacontrol 
    (cuenta) using btree  in dbs_idxinteg;
create index "informix".idx_codstatustarjeta on "informix".td_bandacontrol 
    (codstatustarjeta) using btree  in dbs_movhis_idx3;
create index "informix".idx_maycta10000 on "informix".td_bandacontrol 
    (maycta10000) using btree  in dbs_movhis_idx3;
create index "informix".idx_menatm10000 on "informix".td_bandacontrol 
    (menatm10000) using btree  in dbs_movhis_idx3;
create index "informix".idx_menpos10000 on "informix".td_bandacontrol 
    (menpos10000) using btree  in dbs_movhis_idx3;
create index "informix".idx_menven10000 on "informix".td_bandacontrol 
    (menven10000) using btree  in dbs_movhis_idx3;
create index "informix".idx_numcliente on "informix".td_bandacontrol 
    (numcliente) using btree  in dbs_idxinteg;
create index "informix".idx_numtarjeta1 on "informix".td_bandacontrol 
    (numtarjeta) using btree  in dbs_idxinteg;
create index "informix".idx_promedio_saldo on "informix".td_bandacontrol 
    (promedio_saldo) using btree  in dbs_movhis_idx3;
create index "informix".idx_td_bandacontrol on "informix".td_bandacontrol 
    (fechaexp) using btree  in dbs_movhis_idx3;
create index "informix".idx_td_bandacontrol1 on "informix".td_bandacontrol 
    (consecutivo) using btree  in dbs_movhis_idx3;
create index "informix".idx_bitacorawuheartbeat on "informix".bitacorawuheartbeat 
    (rtncode,fechahorainsercion) using btree  in datos00;
create index "informix".idx_estadwu on "informix".estadisticawu 
    (grupo,fecha) using btree  in datos00;
create index "informix".idx_wswu on "informix".wswesternunion 
    (usuario,nombrerequest) using btree  in datos00;
create index "informix".idx_perm_segmentar on "informix".segmentoproducto 
    (permite_segmentacion) using btree  in dbs_movhis_idx5;
create index "informix".idx_segmento_tipo_producto on "informix"
    .segmentoproducto (tipo_producto) using btree  in dbs_movhis_idx5;
    
create index "informix".idx_sgmtoprod on "informix".segmentoproducto 
    (codproductotarjeta,tipo_producto) using btree  in datos00;
    
create unique index "informix".segmento_producto on "informix"
    .segmentoproducto (codproductotarjeta,clasifica_producto) 
    using btree  in datos00;
create index "informix".idx_clave_tipotarjeta_solicitud_maquila 
    on "informix".solicitud_maquila (clave_tipotarjeta) using 
    btree  in datos01_idx;
create index "informix".idx_consecutivo_solicitud_maquila on 
    "informix".solicitud_maquila (consecutivo) using btree  in 
    datos01_idx;
create index "informix".idx_filtro_solicitud_maquila on "informix"
    .solicitud_maquila (fecha_generacion,indicadortipoproceso,
    flagprocesorealizado) using btree  in datos01_idx;
create index "informix".idx_solicitud_maquila on "informix".solicitud_maquila 
    (clave_sucursal) using btree  in datos03;
create index "informix".indx_fecha_generacion on "informix".solicitud_maquila 
    (fecha_generacion) using btree  in datos00_idx;
create index "informix".indx_flagprocesorealizado on "informix"
    .solicitud_maquila (flagprocesorealizado) using btree  in 
    datos00_idx;
create index "informix".indx_indicadortipoproceso on "informix"
    .solicitud_maquila (indicadortipoproceso) using btree  in 
    datos00_idx;
create index "informix".idx_statusdas on "informix".statusdas 
    (catalogo,marca,status) using btree  in datos00;
create index "informix".idx_bitacorawumoneypaystatus on "informix"
    .bitacorawumoneypaystatus (mtcn,fechahorainsercion) using 
    btree  in datos00;
create index "informix".idx_bitacorawumoneyselect on "informix"
    .bitacorawumoneyselect (money_transfer_key,fechahorainsercion) 
    using btree  in datos00;
create index "informix".idx_bitacorawudas on "informix".bitacorawudas 
    (fecha) using btree  in datos00;
create index "informix".idx_ipinteract on "informix".wstransferscf 
    (ipinteract,puertointeract) using btree  in dbs_cfd_idxs;
    
create index "informix".mc_estadistica on "informix".mc_estadistica 
    (grupo) using btree  in datos00;
create index "informix".mc_estadistica2 on "informix".mc_estadistica 
    (grupo,fecha) using btree  in dbs_movhis_idx3;
create index "informix".idx_mc_iactrans on "informix".mc_iac_transaccion 
    (id_tran,tran_iac) using btree  in datos00;
create index "informix".idx_mc_iactrans2 on "informix".mc_iac_transaccion 
    (tran_iac) using btree  in datos00;
create index "informix".idx_mc_iaccampos on "informix".mc_iac_trans_campos 
    (id_tran,tipo,estatus) using btree  in datos00;
create index "informix".mc_codigoretorno on "informix".mc_codigoretorno 
    (codigo) using btree  in datos00;
create index "informix".idx_mc_oper on "informix".mc_operaciones 
    (id_tran,id_ws) using btree  in datos00;
create index "informix".idx_mc_oper2 on "informix".mc_operaciones 
    (id_tran,id_ws,id_oper) using btree  in datos00;
create index "informix".idx_mc_param on "informix".mc_parametros 
    (id_param,id_campo) using btree  in datos00;
create index "informix".idx_mc_param2 on "informix".mc_parametros 
    (id_oper,id_sp_campo) using btree  in datos00;
create index "informix".idx_mc_param3 on "informix".mc_parametros 
    (id_campo) using btree  in datos00;
create index "informix".idx_campospcentral_idsp on "informix".mc_sp_central_campos 
    (id_sp) using btree  in dbs_movhis_idx3;
create index "informix".idx_campospcentral_tipocampo on "informix"
    .mc_sp_central_campos (tipo_campo) using btree  in dbs_movhis_idx3;
    
create index "informix".idx_codproductotarjeta on "informix".sc_promtarjmensual 
    (codproductotarjeta) using btree  in datos00;
create index "informix".idx_codproductotarjetanuevo on "informix"
    .sc_promtarjmensual (codproductotarjetanuevo) using btree 
     in datos00;
create index "informix".idx_numcuenta on "informix".sc_promtarjmensual 
    (numcuenta) using btree  in datos00;
create index "informix".idx_numtarjeta on "informix".sc_promtarjmensual 
    (numtarjeta) using btree  in datos00;
create index "informix".idx_proceso on "informix".sc_promtarjmensual 
    (proceso) using btree  in datos00;
create index "informix".idx_promtar_numtarperiodo on "informix"
    .sc_promtarjmensual (numtarjeta,periodo) using btree  in 
    dbs_movhis_idx3;
create index "informix".idx_promtarj_periodo on "informix".sc_promtarjmensual 
    (periodo) using btree  in dbs_movhis_idx5;
create index "informix".idx_codigoiso_rpt_y_banda on "informix"
    .td_tablaposatm (codigoiso) using btree  in datos00;
create index "informix".idx_descripcion_rpt_y_banda on "informix"
    .td_tablaposatm (descripcion) using btree  in datos00;
create index "informix".idx_numtarjeta_rpt_y_banda on "informix"
    .td_tablaposatm (numtarjeta) using btree  in datos00;
create index "informix".idx_prodind_rpt_y_banda on "informix".td_tablaposatm 
    (prodind) using btree  in datos00;
create index "informix".idx_hsmcard_paso on "informix".hsmcard_paso 
    (numerolote) using btree  in datos00;
create index "informix".idx_bitacorastrikeiron on "informix".bitacorastrikeiron 
    (email,fechahorainserccion) using btree  in datos00;
create index "informix".idx_trjts on "informix".tt_temporal_tarjetas 
    (tt_numtarjeta) using btree  in datos00;
create unique index "informix".numerodeafiliacion_fecharegistro 
    on "informix".bitacoraafiliacionpermitida (numerodeafiliacion,
    fecharegistro) using btree  in datos00;
create index "informix".afiliacionpermitidavigencia on "informix"
    .afiliacionpermitida (vigencia) using btree  in datos00;
create index "informix".arqcduplicados on "informix".arqcduplicados 
    (arqcduplicado) using btree  in datos00;
create index "informix".idx_bitacoraafiliacion on "informix".bitacoraafiliacion 
    (idbitacoraafiliacion) using btree  in datos00;
create index "informix".idx_bitacoraenvios_proceso_hist on "informix"
    .bitacoraenvios_tjts_hist (id_proceso) using btree  in datos00;
    
create index "informix".idx_bitacoraenvios_tjts1_hist on "informix"
    .bitacoraenvios_tjts_hist (id_proceso,fecha_insert) using 
    btree  in datos00;
create index "informix".bitacora_control_envios_can1 on "informix"
    .bitacora_control_envios_can (fecha_insert) using btree  
    in datos00;
create index "informix".idx_log_atm1 on "informix".log_atm (fechaconciliacion,
    archivoorigen,codigoiso,numtarjeta,registrocentral1,registrocentral2) 
    using btree  in datos03;
create index "informix".idx_log_atm2 on "informix".log_atm (nombrearchivo,
    fechaconciliacion) using btree  in datos03;
create index "informix".log_atm_index on "informix".log_atm (keyx) 
    using btree  in datos03;
create index "informix".idx_log_pos1 on "informix".log_pos (fechaconciliacion,
    archivoorigen,codigoiso,numtarjeta,registrocentral1,registrocentral2) 
    using btree  in datos03;
create index "informix".idx_log_pos2 on "informix".log_pos (nombrearchivo,
    fechaconciliacion) using btree  in datos03;
create index "informix".log_pos_keyx_index_03 on "informix".log_pos 
    (keyx) using btree  in datos03;
create index "informix".central_keyx_index_03 on "informix".central 
    (keyx) using btree  in datos03;
create index "informix".idx_central04 on "informix".central (nombrearchivo) 
    using btree  in datos03;
create index "informix".idx_central_01 on "informix".central (fechaconciliacion,
    archivoorigen,nombrearchivo,tipomov,numtarjeta,foliosucursal) 
    using btree  in datos03;
create index "informix".idx_central_02 on "informix".central (nombrearchivo,
    fechaconciliacion) using btree  in datos03;
create index "informix".idx_binproducto on "informix".binproducto 
    (bin,producto,codproductotarjeta,codprodcta) using btree 
     in dbs_movhis_idx1;
create index "informix".idx_imagenespredisenadas on "informix"
    .cat_imagenespredisenadas (id_diseno) using btree  in dbs_movhis_idx5;
    
create index "informix".idx_solicitudtarjeta on "informix".solicitudtarjeta 
    (idsolicitud,numcliente,numcuenta) using btree  in dbs_movhis_idx5;
    
create index "informix".idx_solicitudtarjetanumcuenta on "informix"
    .solicitudtarjeta (numcuenta) using btree  in dbs_movhis_idx1;
    
create index "informix".idx_bita_fecharegistro on "informix".bitasignacionactivaciontarjeta 
    (fecharegistro) using btree  in idx_info04;
create index "informix".idx_bita_numtarjeta on "informix".bitasignacionactivaciontarjeta 
    (numtarjeta) using btree  in idx_info04;
create index "informix".cnc_atm_stat06_01_mx on "informix".conciliacion_atm_stat06_mx 
    (numtarjeta) using btree  in datos00;
create index "informix".cnc_atm_stat06_02_mx on "informix".conciliacion_atm_stat06_mx 
    (numtarjeta,codigoiso,respuesta) using btree  in datos00;
    
create index "informix".idx_atm_stat06_04_mx on "informix".conciliacion_atm_stat06_mx 
    (numcuenta) using btree  in dbs_idxinteg;
create index "informix".idx_cnc_atm_stat06_03_mx on "informix"
    .conciliacion_atm_stat06_mx (fechaconciliacion,keyx) using 
    btree  in datos03;
create index "informix".idx_combinacionesnombres on "informix"
    .combinacionesnombres (nombre1) using btree  in datos00;
create index "informix".idx_credito_altransac on "informix".vencimiento_credito_altransac 
    (periodo,sucursal) using btree  in datos00;
create index "informix".arqcvalidos_hist2 on "informix".arqcvalidoshistorico 
    (arqccalculado) using btree  in datos03;
create index "informix".idx_movimientobpihnew1 on "informix".movimientobpihistorico 
    (secuencia,fechalocaltransaccion,horalocaltransaccion) using 
    btree  in dbs_movhis_idx5;
create index "informix".idx_movimientobpihnew2 on "informix".movimientobpihistorico 
    (fechahorainauth) using btree  in dbs_movhis_idx5;
create index "informix".idx_movimientobpihnew3 on "informix".movimientobpihistorico 
    (codtran,fechahorainauth) using btree  in dbs_movhis_idx5;
    
create index "informix".idx_movimientobpihnew4 on "informix".movimientobpihistorico 
    (referencia,fechahorainauth) using btree  in dbs_movhis_idx5;
    
create index "informix".idx_movimientobpihnew5 on "informix".movimientobpihistorico 
    (idterminal,fechahorainauth) using btree  in dbs_movhis_idx5;
    
create index "informix".idx_movimientobpihnew6 on "informix".movimientobpihistorico 
    (secuencia) using btree  in dbs_movhis_idx5;
create index "informix".idx_cantidad on "informix".estadisticabts 
    (cantidad) using btree  in dbs_cfd_04;
create index "informix".idx_estadbts on "informix".estadisticabts 
    (fecha,grupo) using btree  in dbs_cfd_04;
create index "informix".idx_grupo on "informix".estadisticabts 
    (grupo) using btree  in dbs_cfd_04;
create unique index "informix".i4626_12909_his on "informix".atm_conciliacion_admin_his 
    (tarjeta,secintercard,fechahorainauth) using btree  in dbs_cfd_04;
    
create index "informix".idx_fecha_archivo_repatm_his on "informix"
    .atm_conciliacion_aplicativos_his (fecha_archivo) using btree 
     in dbs_movhis_idx6;
create index "informix".idx_tarjeta on "informix".bitacoracancelaciontarjetas 
    (tarjeta) using btree  in datos00_idx;
create index "informix".idx_movimientobpinew1 on "informix".movimientobpi 
    (secuencia,fechalocaltransaccion,horalocaltransaccion) using 
    btree  in dbs_movhis3;
create index "informix".idx_movimientobpinew2 on "informix".movimientobpi 
    (fechahorainauth,secuencia,fechalocaltransaccion,horalocaltransaccion) 
    using btree  in dbs_movhis3;
create index "informix".idx_movimientobpinew3 on "informix".movimientobpi 
    (fechahorainauth) using btree  in dbs_movhis3;
create index "informix".idx_movimientobpinew4 on "informix".movimientobpi 
    (codtran,fechahorainauth) using btree  in dbs_movhis3;
create index "informix".idx_movimientobpinew5 on "informix".movimientobpi 
    (referencia,fechahorainauth) using btree  in dbs_movhis3;
    
create index "informix".idx_movimientobpinew6 on "informix".movimientobpi 
    (idterminal,fechahorainauth) using btree  in dbs_movhis3;
    
create index "informix".idx_tarjetapivote_depuracion2 on "informix"
    .tarjetapivote_depuracion (estatus_depuracion) using btree 
     in dbs_movhis_idx5;
create index "informix".idx_tarjetapivote_depuracion3 on "informix"
    .tarjetapivote_depuracion (numtarjeta) using btree  in dbs_movhis_idx5;
    
create index "informix".idx_control_depuracion on "informix".control_depuracion 
    (numtarjeta) using btree  in dbs_movhis_idx3;
create index "informix".idx_tarjetacuenta_historico2 on "informix"
    .tarjetacuenta_historico (numtarjeta) using btree  in dbs_movhis_idx5;
    
create index "informix".idx_rptdinamico_op on "informix".rptdinamico 
    (numcliente) using btree  in dbs_movhis3;
create index "informix".idx_detalle_maquila_historico2 on "informix"
    .detalle_maquila_historico (numtarjeta) using btree  in dbs_movhis_idx5;
    
create index "informix".idx_control_inventario_ejecucion on "informix"
    .control_inventario_ejecucion (tt_clave_sucursal,tt_clave_tipotarjeta) 
    using btree  in dbssc_sdodiarioc02;
create index "informix".idx_control_inventario on "informix".control_inventario 
    (tt_sucursal,tt_numerotarjeta,tt_numerolote) using btree 
     in dbssc_sdodiarioc03;
create index "informix".idx_procesoestatus on "informix".bitacoraprocesosejec 
    (idproceso,estatus) using btree  in dbssc_sdodiarioc02;
create index "informix".idx_procesofechaejec on "informix".bitacoraprocesosejec 
    (idproceso,fecha_ejecucion) using btree  in dbssc_sdodiarioc02;
    
create index "informix".idx_paso_prommes_codprodtarj on "informix"
    .tbl_paso_prom_mensual (codproductotarjeta) using btree  
    in dbs_movhis_idx3;
create index "informix".idx_cnc_adm_mc_1 on "informix".conciliacion_admin_mc 
    (nomarchivo325,estatus) using btree  in datos00_idx;
create index "informix".idx_cnc_adm_mc_3c on "informix".conciliacion_admin_mc 
    (archivoorigen,usuario,fechahorainauth) using btree  in datos00_idx;
    
create index "informix".idx_atm_cnc_apli_nombrearchivo on "informix"
    .atm_conciliacion_aplicativos (nombrearchivo) using btree 
     in dbs_movhis_idx6;
create index "informix".idx_fecha_archivo_repatm on "informix"
    .atm_conciliacion_aplicativos (fecha_archivo) using btree 
     in dbs_movhis_idx6;
create index "informix".idxallfields_qury on "informix".bitacoratransqury 
    (sbranchnumber,sconfirmationnumber,sagentusername,codigoretorno,
    operationalcode,fechahorainserccion) using btree  in dbs_movhis_idx4;
    
create index "informix".idxbranchnumber_qury on "informix".bitacoratransqury 
    (sbranchnumber) using btree  in dbs_movhis_idx4;
create index "informix".idxcodret_qury on "informix".bitacoratransqury 
    (codigoretorno) using btree  in dbs_movhis_idx4;
create index "informix".idxdateinsert_qury on "informix".bitacoratransqury 
    (fechahorainserccion) using btree  in dbs_movhis_idx5;
create index "informix".idxnumconfirm_qury on "informix".bitacoratransqury 
    (sconfirmationnumber) using btree  in dbs_movhis_idx5;
create index "informix".idxopercod_qury on "informix".bitacoratransqury 
    (operationalcode) using btree  in dbs_movhis_idx5;
create index "informix".idxsagentusername_qury on "informix".bitacoratransqury 
    (sagentusername) using btree  in dbs_movhis_idx5;
create index "informix".idx_bitacoratranscdep1 on "informix".bitacoratranscdep 
    (fechahorainserccion) using btree  in dbs_movhis_idx4;
create index "informix".idx_bitacoratranscdep2 on "informix".bitacoratranscdep 
    (confirmation_nm) using btree  in dbs_movhis_idx4;
create index "informix".idx_bitacoratranscdep3 on "informix".bitacoratranscdep 
    (confirmation_nm,fechahorainserccion) using btree  in dbs_movhis_idx4;
    
create index "informix".idx_bitacoratranscdep_old1 on "informix"
    .bitacoratranscdep_old (fechahorainserccion) using btree 
     in dbs_movhis_idx5;
create index "informix".idx_bitacoratranscdep_old2 on "informix"
    .bitacoratranscdep_old (confirmation_nm) using btree  in 
    dbs_movhis_idx5;
create index "informix".idx_bitacoratranscdep_old3 on "informix"
    .bitacoratranscdep_old (confirmation_nm,fechahorainserccion) 
    using btree  in dbs_movhis_idx5;
create index "informix".idx_bitacoratranspayc1 on "informix".bitacoratranspayc 
    (sconfirmationnumber) using btree  in dbs_movhis_idx4;
create index "informix".idx_bitacoratranspayc2 on "informix".bitacoratranspayc 
    (fechahorainserccion) using btree  in dbs_movhis_idx4;
create index "informix".idx_bitacoratranspayc3 on "informix".bitacoratranspayc 
    (sconfirmationnumber,fechahorainserccion) using btree  in 
    dbs_movhis_idx4;
create index "informix".idxallfields_payi on "informix".bitacoratranspayi 
    (sbranchnumber,sconfirmationnumber,sagentusername,codigoretorno,
    operationalcode,fechahorainserccion) using btree  in dbs_movhis_idx4;
    
create index "informix".idxbranchnumber_payi on "informix".bitacoratranspayi 
    (sbranchnumber) using btree  in dbs_movhis_idx4;
create index "informix".idxcodret_payi on "informix".bitacoratranspayi 
    (codigoretorno) using btree  in dbs_movhis_idx4;
create index "informix".idxdateinsert_payi on "informix".bitacoratranspayi 
    (fechahorainserccion) using btree  in dbs_movhis_idx4;
create index "informix".idxnumconfirm_payi on "informix".bitacoratranspayi 
    (sconfirmationnumber) using btree  in dbs_movhis_idx4;
create index "informix".idxopercod_payi on "informix".bitacoratranspayi 
    (operationalcode) using btree  in dbs_movhis_idx4;
create index "informix".idxsagentusername_payi on "informix".bitacoratranspayi 
    (sagentusername) using btree  in dbs_movhis_idx4;
create index "informix".idx_bitacorawucancelpaid on "informix"
    .bitacorawucancelpaid (mtcn,new_mtcn,retcode,fechahorainsercion) 
    using btree  in dbs_movhis_idx4;
create index "informix".idx_bitacorawusearchcancelpaid on "informix"
    .bitacorawusearchcancelpaid (mtcn,new_mtcn,retcode,fechahorainsercion) 
    using btree  in dbs_movhis_idx4;
create index "informix".idx_trjsctesbuenfin on "informix".tarjetas_clientes_buenfin 
    (num_tarjeta,fecha_hora,secuencia) using btree  in datos00;
    
create index "informix".idx_bitacoratranssdep1 on "informix".bitacoratranssdep 
    (confirmation_nm) using btree  in dbs_movhis_idx4;
create index "informix".idx_bitacoratranssdep2 on "informix".bitacoratranssdep 
    (fechahorainserccion) using btree  in dbs_movhis_idx5;
create index "informix".idx_bitacoratranssdep3 on "informix".bitacoratranssdep 
    (confirmation_nm,fechahorainserccion) using btree  in dbs_movhis_idx5;
    
create index "informix".idx_bitacorawumoneypay on "informix".bitacorawumoneypay 
    (mtcn,fechahorainsercion) using btree  in dbs_movhis_idx5;
    
create index "informix".idx_rpte_gral_horario_busqueda on "informix"
    .tbl_reporte_general (horainicio_busqueda,horafin_busqueda) 
    using btree  in db_lide02;
create index "informix".idx_wsbitacoralogin_01 on "informix".wsbitacoralogin 
    (id_sesion,datetimeinsert) using btree  in dbs_movhis_idx5;
    
create index "informix".idx_wsbitacoraqaccount_01 on "informix"
    .wsbitacoraqaccount (session_id,datetimeinsert) using btree 
     in dbs_movhis_idx5;
create index "informix".idx_bitwusearch on "informix".bitacorawumoneytransfersearch 
    (pt_mtcn,fechahorainsercion) using btree  in dbs_movhis_idx4;
    
create index "informix".idxbitacorawumoneytransfersearchfrm on 
    "informix".bitacorawumoneytransfersearch (fechahorainsercion,
    retcode,pt_mtcn) using btree  in dbs_movhis_idx4;
create index "informix".idxbitacorawumoneytransfersearchnm on 
    "informix".bitacorawumoneytransfersearch (new_mtcn) using 
    btree  in dbs_movhis_idx4;
create index "informix".idx_rpte_det_horario_busqueda on "informix"
    .tbl_reporte_detallado (horainicio_busqueda,horafin_busqueda) 
    using btree  in db_lide02;
create index "informix".idx_rpte_mon_horario_busqueda on "informix"
    .tbl_reporte_monitoreo_trx (horainicio_busqueda,horafin_busqueda) 
    using btree  in db_lide02;
create index "informix".idx_solicitud_eliminada_usuario on "informix"
    .solicitud_eliminada_usuario (consecutivo) using btree  in 
    dbs_movhis_idx3;
create index "informix".idx_paso_trxs_t_motivo on "informix".tbl_paso_transaccionalidad 
    (t_motivo) using btree  in dbssc_sdodiarioc01;
create index "informix".idx_tbl_paso_coppel_gpo on "informix".tbl_trxs_grupo_coppel 
    (t_grupo) using btree  in dbssc_sdodiarioc01;
create index "informix".idx_bitacora_inventario_fechahora on 
    "informix".bitacoracambioinventario (fechahora) using btree 
     in dbs_movhis_idx3;
create index "informix".idx_empresa_num_cliente on "informix".tbl_clientes_tarjeta_oro 
    (t_empresa,t_num_cliente) using btree  in dbs_movhis_idx4;
    
create index "informix".idx_solic_registrada on "informix".tbl_clientes_tarjeta_oro 
    (t_solicitud_registrada) using btree  in dbs_movhis_idx4;
    
create index "informix".idx_tbl_rpte_acumulado_fecha on "informix"
    .tbl_reporte_acumulado_trx (fecha_ejecucion) using btree 
     in dbstarjeta;
create index "informix".idx_tbl_rpte_acumulado_prodind on "informix"
    .tbl_reporte_acumulado_trx (tipo_prodind) using btree  in 
    dbstarjeta;
create index "informix".idx_info_clientes_captacion_ctes on "informix"
    .info_clientes_captacion (cliente) using btree  in datos02_idx;
    
create index "informix".idx_info_paso_clientes on "informix".info_paso_clientes 
    (inf_cliente) using btree  in datos02_idx;
create index "informix".idx_info_paso_ctes_plantilla on "informix"
    .info_paso_clientes (inf_plantilla) using btree  in datos02_idx;
    
create index "informix".idx_info_reporte_trimestral on "informix"
    .info_reporte_trimestral (plantilla) using btree  in datos02_idx;
    
create index "informix".idx_mov_histdep_1 on "informix".movimientohistorico_dep 
    (numtarjeta) using btree  in dbs_idxinteg;
create index "informix".idx_mov_histdep_2 on "informix".movimientohistorico_dep 
    (fechalocaltransaccion,horalocaltransaccion) using btree 
     in dbs_idxinteg;
create index "informix".idx_mov_histdep_3 on "informix".movimientohistorico_dep 
    (fechahorainauth) using btree  in dbs_idxinteg;
create index "informix".idx_mov_histdep_4 on "informix".movimientohistorico_dep 
    (fechahorainauth,prodind) using btree  in dbs_idxinteg;
create index "informix".idx_mov_histdep_5 on "informix".movimientohistorico_dep 
    (idretailer) using btree  in dbs_idxinteg;
create index "informix".idx_mov_histdep_6 on "informix".movimientohistorico_dep 
    (idterminal) using btree  in dbs_idxinteg;
create index "informix".idx_tbl_contador_dias_incidencias_estatus 
    on "informix".tbl_contador_dias_incidencias (estatus_dia) 
    using btree  in datos02_idx;
create index "informix".idx_bitacora_canceltarjetacanal_folio 
    on "informix".bitacora_cancelatarjetacanal (folio) using btree 
     in datos00;
create index "informix".idx_bitacora_canceltarjetacanal_numcte 
    on "informix".bitacora_cancelatarjetacanal (numcte) using 
    btree  in datos00;
create index "informix".idx_bitacora_canceltarjetacanal_numtarjeta 
    on "informix".bitacora_cancelatarjetacanal (numtarjeta) using 
    btree  in datos00;
create index "informix".idx_tbl_paso_repaut_corresp_mc on "informix"
    .tbl_paso_repaut_r026_establecimiento (corresp_mc) using 
    btree  in datos02_idx;
create index "informix".idx_tbl_paso_repaut_id_registro on "informix"
    .tbl_paso_repaut_r026_establecimiento (id_registro) using 
    btree  in datos02_idx;
create index "informix".idx_tbl_paso_repaut_periodo_afectacion 
    on "informix".tbl_paso_repaut_r026_establecimiento (periodo_afectacion) 
    using btree  in datos02_idx;
create index "informix".idx01info_tarjeta_pyt on "informix".info_tarjeta_pyt 
    (fechaultmodif) using btree  in dbs_movhis_idx6;
create index "informix".idx01info_tarjeta_pyt2 on "informix".info_tarjeta_pyt 
    (numtarjeta) using btree  in dbs_movhis_idx6;
create index "informix".idx01info_tarjeta_pyt3 on "informix".info_tarjeta_pyt 
    (codstatustarjeta,fechaasignacion) using btree  in dbs_movhis_idx6;
    
create index "informix".idx_info_tarjeta_pyt_04 on "informix".info_tarjeta_pyt 
    (numtarjeta,codstatustarjeta) using btree  in datos01_idx;
    
create index "informix".idx_tbl_campania_movs_tipo_estatus_tarj 
    on "informix".tbl_campania_movs_tipo_transacc (t_codstatustarjeta) 
    using btree  in datos02_idx;
create index "informix".idx_tbl_campania_movs_tipo_fechaexp on 
    "informix".tbl_campania_movs_tipo_transacc (t_fechaexp) using 
    btree  in datos01_idx;
create index "informix".idx_tbl_campania_movs_tipo_num_cliente 
    on "informix".tbl_campania_movs_tipo_transacc (t_num_cliente) 
    using btree  in datos01_idx;
create index "informix".idx_tbl_campania_movs_tipo_numtarjeta 
    on "informix".tbl_campania_movs_tipo_transacc (t_numtarjeta) 
    using btree  in datos01_idx;
create index "informix".idx_tbl_campania_notif_tarjeta_num_cliente_hist 
    on "informix".tbl_campania_notif_tarjeta_ctes_hist (num_cliente) 
    using btree  in datos01_idx;
create index "informix".idx_tbl_campania_notif_tarjeta_numtarjeta_hist 
    on "informix".tbl_campania_notif_tarjeta_ctes_hist (numtarjeta) 
    using btree  in datos01_idx;
create index "informix".idx_tbl_campania_notif_tarjeta_proceso_tipo_transacc_hist 
    on "informix".tbl_campania_notif_tarjeta_ctes_hist (estatus_proceso,
    tipo_transacc_carga) using btree  in datos01_idx;
create index "informix".idx_bitacoraenvios_proceso on "informix"
    .bitacoraenvios_tjts (id_proceso) using btree  in datos01_idx;
    
create index "informix".idx_bitacoraenvios_tjts1 on "informix"
    .bitacoraenvios_tjts (id_proceso,fecha_insert) using btree 
     in datos01_idx;
create index "informix".idx_bittar on "informix".bitacoraenvios_tjts 
    (id_proceso,estatus_envio,tarjeta) using btree  in datos01_idx;
    
create index "informix".idx_tjts_fecha_exp_1 on "informix".bitacora_can_fecha_exp 
    (numtarjeta,fechaexp,fecha_proc) using btree  in datos02_idx;
    
create index "informix".idx_tjts_fecha_exp_2 on "informix".bitacora_can_fecha_exp 
    (fechaexp,estatus_can) using btree  in dbssc_sdodiarioc03;
    
create index "informix".idx_tbl_campania_notif_tarjeta_num_cliente 
    on "informix".tbl_campania_notif_tarjeta_ctes (num_cliente) 
    using btree  in datos01_idx;
create index "informix".idx_tbl_campania_notif_tarjeta_numtarjeta 
    on "informix".tbl_campania_notif_tarjeta_ctes (numtarjeta) 
    using btree  in datos01_idx;
create index "informix".idx_tbl_campania_notif_tarjeta_proceso_tipo_transacc 
    on "informix".tbl_campania_notif_tarjeta_ctes (estatus_proceso,
    tipo_transacc_carga) using btree  in datos01_idx;
create index "informix".idx_paso_mov_giro1 on "informix".paso_mov_giro 
    (codproductotarjeta,periodo) using btree  in db_cheqhist02;
    
create index "informix".idx_trn_paso_mov_giro on "informix".paso_mov_giro 
    (transacciones) using btree  in db_cheqhist03;
create index "informix".idx_tbl_inter_param_cond_busqueda on 
    "informix".tbl_inter_parametros (cond_busqueda) using btree 
     in datos00_idx;
create unique index "informix".idx_tbl_inter_param_empresa_busq 
    on "informix".tbl_inter_parametros (empresa,cond_busqueda) 
    using btree  in datos00_idx;
create index "informix".idx_mov_cod_rst_otp_cta_tjt_sec on "informix"
    .mov_codigos_retiro_sin_tarjeta (otp,numcuenta,numtarjeta,
    secuenciaextendida) using btree  in datos01_idx;
create index "informix".idx_fechahorainauth on "informix".movimiento 
    (fechahorainauth) using btree  in dbs_mov_idx_01;
create index "informix".idx_movimiento21 on "informix".movimiento 
    (numtarjeta,secuenciaextendida,prodind,fechahorainauth,fechahoraoutauth) 
    using btree  in datos00_idx;
create index "informix".idx_movimiento6 on "informix".movimiento 
    (fechahorainauth,prodind,idterminal) using btree  in dbs_mov_idx_02;
    
create index "informix".idx_movimientonew1a on "informix".movimiento 
    (numtarjeta) using btree  in dbs_mov_idx_03;
create index "informix".idx_movimientonew2a on "informix".movimiento 
    (fechalocaltransaccion,horalocaltransaccion) using btree 
     in dbs_mov_idx_01;
create index "informix".idx_movimientonew3a on "informix".movimiento 
    (fechahorainauth,numtarjeta,formato) using btree  in dbs_mov_idx_03;
    
create index "informix".idx_movimientonew4a on "informix".movimiento 
    (idterminal,prodind,fechahorainauth) using btree  in dbs_mov_idx_02;
    
create index "informix".idx_movimientonew5a on "informix".movimiento 
    (idretailer,prodind,fechahorainauth) using btree  in dbs_mov_idx_01;
    
create index "informix".idx_movimientonew6a on "informix".movimiento 
    (fechahorainauth,codigoiso,codtran,transaccionorigen) using 
    btree  in dbs_mov_idx_03;
create index "informix".idx_secuenciaextendida on "informix".movimiento 
    (secuenciaextendida) using btree  in dbs_mov_idx_01;
create index "informix".idx_tbl_mc_movs_tipotransacc_corr_transacc 
    on "informix".tbl_mc_movs_tipo_transaccional (corresponsal,
    transaccionorigen) using btree  in datos02_idx;
create index "informix".idx_bines_desc_cnc_bin on "informix".bines_desc_cnc 
    (bin) using btree  in datos00;
create index "informix".idx_tbl_monitor_rst_movimiento_codigoiso 
    on "informix".tbl_monitor_rst_movimiento (codigoiso) using 
    btree  in datos00;
create index "informix".idx_tbl_monitor_rst_estatusotp on "informix"
    .tbl_monitor_rst (estatus_otp) using btree  in datos00;
create index "informix".idx_tbl_cmp_ctes_sin_notif_numcte on 
    "informix".tbl_campania_ctes_sin_notif (num_cliente) using 
    btree  in datos02_idx;
create index "informix".idx_tbl_campania_ctes_notificados_numcte 
    on "informix".tbl_campania_ctes_notificados (numcte) using 
    btree  in datos00_idx;
create index "informix".idx_tbl_campania_ctes_notificados_numtarjeta 
    on "informix".tbl_campania_ctes_notificados (numtarjeta) using 
    btree  in datos02_idx;
create index "informix".idx_tbl_corresp_mc_ctas_cruzadas_fecha 
    on "informix".tbl_corresp_mc_cuentas_cruzadas (t_fecha_registro) 
    using btree  in datos00_idx;
create index "informix".idx_tbl_corresp_mc_ctas_cruzadas_numcuenta_trans 
    on "informix".tbl_corresp_mc_cuentas_cruzadas (t_numcuenta_transacc) 
    using btree  in datos00_idx;
create index "informix".tbl_monitor_tablas_transacc_hab on "informix"
    .tbl_monitor_tablas_transacc (habilitada) using btree  in 
    datos02_idx;
create index "informix".tbl_monitor_tablas_transacc_tabla_base 
    on "informix".tbl_monitor_tablas_transacc (nombre_tabla,nombre_bd) 
    using btree  in datos02_idx;
create index "informix".idx_paso_mov_txns on "informix".paso_mov_txns 
    (afiliacion) using btree  in datos01_idx;
create index "informix".idx_paso_mov_txns2 on "informix".paso_mov_txns 
    (numtarjeta) using btree  in datos01_idx;
create index "informix".idx_paso_mov_txns3 on "informix".paso_mov_txns 
    (bin) using btree  in datos01_idx;
create index "informix".idx_tbl_paso_inventario_suc_tipo on "informix"
    .tbl_paso_inventario_suc (tipo) using btree  in datos00_idx;
    
create index "informix".idx_inventario_base01 on "informix".sucursales_base_tmp 
    (clave_sucursal,clave_tipotarjeta) using btree  in datos00_idx;
    
create index "informix".idx_inventario_noa01 on "informix".inventario_suc_tmp_noa 
    (clave_sucursal,clave_tipotarjeta) using btree  in datos00_idx;
    
create index "informix".idx_inventario_noe01 on "informix".inventario_suc_tmp_noe 
    (clave_sucursal,clave_tipotarjeta) using btree  in datos00_idx;
    
create index "informix".idx_inventario_suc01 on "informix".inventario_suc_final 
    (clave_sucursal,clave_tipotarjeta) using btree  in datos00_idx;
    
create index "informix".idx_carga_tarjetas on "informix".carga_tarjetas 
    (sucursal,flag_sucursal) using btree  in datos00_idx;
create index "informix".idx_cnc_cap_his_1 on "informix".conciliacion_dep_colaborapp 
    (nombrearchivo,folio_cap) using btree  in datos02_idx;
create index "informix".idx_ctas_nomina_empleado_cuenta on "informix"
    .ctas_nomina_empleado (cuenta) using btree  in datos02_idx;
    
create index "informix".idx_ctas_nomina_empleado_num_empleado 
    on "informix".ctas_nomina_empleado (num_empleado) using btree 
     in datos02_idx;
create index "informix".idx_conadmin4his on "informix".conadmin_his 
    (archivoorigen,nomarchivo325,nomarchivocom,fecharegistro) 
    using btree  in dbs_movhis_idx3;
create index "informix".index_conadmin1his on "informix".conadmin_his 
    (fecharegistro) using btree  in dbs_movhis_idx3;
create index "informix".index_conadmin2his on "informix".conadmin_his 
    (nomarchivocom) using btree  in dbs_movhis_idx3;
create index "informix".index_conadmin3his on "informix".conadmin_his 
    (nomarchivo325,nomarchivocom,tiporegistro,estatus,tipooperacion) 
    using btree  in dbs_movhis_idx3;
create index "informix".index_conadmin4his on "informix".conadmin_his 
    (nomarchivo325) using btree  in dbs_movhis_idx3;
create index "informix".index_conadmin5his on "informix".conadmin_his 
    (keyx) using btree  in dbs_movhis_idx3;
create index "informix".id_bitacorapfl_01 on "informix".bitacorapinoffline 
    (numtarjeta,estatusscripting) using btree  in dbs_movhis_idx5;
    
create index "informix".idx_bit_pinoffline on "informix".bit_pinoffline 
    (numtarjeta,tarjeta_edofinal) using btree  in dbs_movhis_idx5;
    
create index "informix".idx_bitacora_msi_2c on "informix".bitacora_msi 
    (numtarjeta,secuencia) using btree  in datos02_idx;
create index "informix".idx_bitacora_msi_secuenciaext on "informix"
    .bitacora_msi (secuenciaextendida) using btree  in datos02_idx;
    
create index "informix".idx_ctas_nomina_empleado_paso_1 on "informix"
    .ctas_nomina_empleado_paso (num_empleado) using btree  in 
    datos00;
create index "informix".tmp_trailer_vau on "informix".tmp_trailer_vau 
    (empresa) using btree  in datos02_idx;
create index "informix".idx_tbl_info_tarjetas_vau_codstatustarjeta 
    on "informix".tbl_info_tarjetas_vau (codstatustarjeta) using 
    btree  in datos02_idx;
create index "informix".idx_tbl_info_tarjetas_vau_numtarjeta 
    on "informix".tbl_info_tarjetas_vau (numtarjeta) using btree 
     in datos02_idx;
create index "informix".idx_tbl_info_tarjetas_vau_numtarjetasustituta 
    on "informix".tbl_info_tarjetas_vau (numtarjetasustituta) 
    using btree  in datos02_idx;
create index "informix".idx_elimina_mj on "informix".tbl_tarjetas_vau_final 
    (numtarjetasustituta) using btree  in db_cheqhist02;
create index "informix".idx_tbl_tarjetas_vau_final_numtarjeta 
    on "informix".tbl_tarjetas_vau_final (numtarjeta) using btree 
     in datos02_idx;
create index "informix".idx_trae_mj on "informix".tbl_tarjetas_vau_final 
    (identificadorvau) using btree  in db_cheqhist02;
create index "informix".idx_tbl_vau_tar_activas_codstatustarjeta 
    on "informix".tbl_vau_tar_activas (codstatustarjeta) using 
    btree  in datos02_idx;
create index "informix".idx_tbl_vau_tar_activas_numtarjeta on 
    "informix".tbl_vau_tar_activas (numtarjeta) using btree  in 
    datos02_idx;
create index "informix".idx_tbl_vau_tar_activas_numtarjetasustituta 
    on "informix".tbl_vau_tar_activas (numtarjetasustituta) using 
    btree  in datos02_idx;
create index "informix".idx_tbl_vau_tar_estatus_final_codstatustarjeta 
    on "informix".tbl_vau_tar_estatus_final (codstatustarjeta) 
    using btree  in datos02_idx;
create index "informix".idx_tbl_vau_tar_estatus_final_numcliente 
    on "informix".tbl_vau_tar_estatus_final (numcliente) using 
    btree  in datos02_idx;
create index "informix".idx_tbl_vau_tar_estatus_final_numtarjeta 
    on "informix".tbl_vau_tar_estatus_final (numtarjeta) using 
    btree  in datos02_idx;
create index "informix".idx_tbl_vau_tar_estatus_final_numtarjetasustituta 
    on "informix".tbl_vau_tar_estatus_final (numtarjetasustituta) 
    using btree  in datos02_idx;
create unique index "informix".idx_pk_tbl_catalogo_archivos on 
    "informix".tbl_catalogo_archivos_procesar (nombre_proceso,
    prefijo_archivo,ruta_destino) using btree  in datos00_idx;
    
create index "informix".idx_tbl_catalogo_archivos_nom_proceso 
    on "informix".tbl_catalogo_archivos_procesar (nombre_proceso) 
    using btree  in datos00_idx;
create index "informix".idx_tbl_catalogo_archivos_prefijo on 
    "informix".tbl_catalogo_archivos_procesar (empresa,prefijo_archivo) 
    using btree  in datos00_idx;
create index "informix".idx_comercios_afiliados_2 on "informix"
    .tbl_msi_info_comercios_afiliados (identificador_registro,
    clave_promocion,clave_afiliacion,cuenta_clabe) using btree 
     in dbs_cfd_01;
create index "informix".idx_tbl_msi_info_comercios_afiliados_idregistro 
    on "informix".tbl_msi_info_comercios_afiliados (identificador_registro) 
    using btree  in datos00_idx;
create index "informix".idx_tbl_msi_archivos_generados_fecha_proc 
    on "informix".tbl_msi_archivos_generados (fecha_proceso) using 
    btree  in datos00_idx;
create index "informix".idx_tbl_inter_params_cmp_ha_cond_busq 
    on "informix".tbl_inter_params_cmp_horas_azules (cond_busqueda) 
    using btree  in dbs_movhis_idx5;
create index "informix".idx_tbl_cmp_horas_azules_creditos_4c 
    on "informix".tbl_cmp_horas_azules_creditos (num_producto,
    num_credito,numcte,numtarjeta) using btree  in dbs_movhis_idx5;
    
create index "informix".idx_tbl_cmp_horas_azules_bitacora_1c 
    on "informix".tbl_cmp_horas_azules_bitacora (num_credito) 
    using btree  in dbs_movhis_idx5;
create index "informix".idx_mco_cnc_aplicat_fecha_archivo on 
    "informix".mco_conciliacion_aplicativos (fecha_archivo) using 
    btree  in datos00_idx;
create index "informix".idx_alertservice_piv_empresa on "informix"
    .alertservice_piv (empresa) using btree  in dbs_movhis_idx1;
    
create index "informix".afiliacioncof on "informix".afiliacioncof 
    (estatus) using btree  in dbs_idxinteg;
create index "informix".idx_movimiento1 on "informix".movimientohistorico 
    (numtarjeta) using btree ;
create index "informix".idx_movimiento2 on "informix".movimientohistorico 
    (fechalocaltransaccion,horalocaltransaccion) using btree 
    ;
create index "informix".idx_movimiento3 on "informix".movimientohistorico 
    (fechahorainauth) using btree ;
create index "informix".idx_movimiento4 on "informix".movimientohistorico 
    (fechahorainauth,prodind) using btree ;
create index "informix".idx_movimiento5 on "informix".movimientohistorico 
    (idretailer) using btree ;
create index "informix".idx_movimientohist6 on "informix".movimientohistorico 
    (idterminal) using btree ;
create index "informix".idx_movimientohist7 on "informix".movimientohistorico 
    (secuencia,numtarjeta,fechalocaltransaccion,horalocaltransaccion) 
    using btree ;
create index "informix".idx_conciliacion_mc_oxxo_3c on "informix"
    .conciliacion_mc_oxxo (fecha_conciliacion,num_tarjeta,numcuenta,
    nombrearchivo) using btree  in datos01_idx;
create index "informix".idx_conciliacion_mc_oxxo_5c on "informix"
    .conciliacion_mc_oxxo (nombrearchivo,tipo_txn,num_tarjeta,
    numcuenta,sec_extendida_archivo) using btree  in datos01_idx;
    
create index "informix".idx_tbl_bit_cambios_invent_tarjetas_suc_fecha 
    on "informix".tbl_bitacora_cambios_invent_tarjetas (clave_sucursal,
    fecha_ejecucion) using btree  in datos02_idx;
create index "informix".idx_cte_cvv2 on "informix".enrolactescvv2 
    (numcte) using btree  in dbs_movhis_idx4;
create index "informix".idx_numcte1 on "informix".num_ctes (numcte) 
    using btree  in dbs_movhis_idx4;
create index "informix".idx_cte_sus_tar on "informix".ctes_sus_tarjetas 
    (num_tarjeta) using btree  in dbs_movhis_idx5;
create index "informix".idx_cte_noenrolado on "informix".ctes_no_enrolado 
    (numero_cliente) using btree  in dbs_movhis_idx4;
create index "informix".idx_cte_enrolado_numtar on "informix".info_cte_enrolado 
    (numtarjeta) using btree  in dbs_movhis_idx4;
create unique index "informix".idx_mov_bancoppel_coppel_secuenciaextendida 
    on "informix".mov_bancoppel_coppel (secuenciaextendida) using 
    btree  in dbs_movhis_idx2;
create index "informix".idx_mov_oxxo_eleven on "informix".tmp_mov_oxxo_seven 
    (numtarjeta,monto,secuenciaextendida) using btree  in datos02_idx;
    
create index "informix".idx_mco_oxxo_eleven on "informix".tmp_mco_oxxo_seven 
    (numtarjeta,montomov,secuenciaextendida) using btree  in 
    datos02_idx;
create index "informix".idx_descuadre_numtarjeta on "informix"
    .descuadre_oxxo_seven (numtarjeta) using btree  in datos02_idx;
    
create index "informix".idx_descuadre_tar_numcte on "informix"
    .descuadre_oxxo_seven_num_cliente (numtarjeta) using btree 
     in datos02_idx;
create index "informix".idx_cnc_atm_stat06_pagos_01 on "informix"
    .conciliacion_atm_stat06_pagos (fechaconciliacion,keyx) using 
    btree  in dbs_movhis_idx4;
create index "informix".idx_cnc_atm_stat06_pagos_02 on "informix"
    .conciliacion_atm_stat06_pagos (keyx) using btree  in dbs_movhis_idx4;
    
create index "informix".idx_cnc_atm_stat06_pagos_03 on "informix"
    .conciliacion_atm_stat06_pagos (fechaconciliacion) using 
    btree  in dbs_movhis_idx4;
create index "informix".idx_cnc_atm_stat06_pagos_04 on "informix"
    .conciliacion_atm_stat06_pagos (numcuenta) using btree  in 
    dbs_movhis_idx4;
create index "informix".idx_cnc_atm_stat06_pagos_05 on "informix"
    .conciliacion_atm_stat06_pagos (numcuenta,codigoiso,respuesta) 
    using btree  in dbs_movhis_idx4;
create index "informix".cnc_atm_stat06_01 on "informix".conciliacion_atm_stat06 
    (numtarjeta) using btree  in dbs_info01;
create index "informix".cnc_atm_stat06_02 on "informix".conciliacion_atm_stat06 
    (numtarjeta,codigoiso,respuesta) using btree  in dbs_info01;
    
create index "informix".idx_atm_stat06_04 on "informix".conciliacion_atm_stat06 
    (numcuenta) using btree  in dbs_movhis_idx1;
create index "informix".idx_cnc_atm_stat06_03 on "informix".conciliacion_atm_stat06 
    (fechaconciliacion,keyx) using btree  in dbs_movhis_idx1;
    
create index "informix".idx_cnc_atm_stat_06_fecha on "informix"
    .conciliacion_atm_stat06 (fecha) using btree  in dbs_movhis_idx2;
    
create index "informix".idx_cnc_atm_stat_06_nombrearchivo on 
    "informix".conciliacion_atm_stat06 (nombrearchivo) using btree 
     in dbs_movhis_idx2;
create index "informix".idx_bitacoracambiosstatustarjeta_codstatustarjetanvo 
    on "informix".bitacoracambiosstatustarjeta (codstatustarjetanvo) 
    using btree ;
create index "informix".idxvau on "informix".bitacoracambiosstatustarjeta 
    (fechahora,codstatustarjetanvo,codigoerror) using btree ;
    
create unique index "informix".pktarjeta_fechahora on "informix"
    .bitacoracambiosstatustarjeta (tarjeta,fechahora) using btree 
    ;
create index "informix".idx_numeroafiliacion on "informix".afiliaciones_comercios 
    (numero_afiliacion) using btree  in datos00_idx;
create index "informix".idx_fechahora_inicioproceso on "informix"
    .bitacora_afiliaciones_comercios (fechahora_inicio_proceso) 
    using btree  in datos00_idx;
create index "informix".idx_num_afil on "informix".tbl_idproceso_numero_afiliacion 
    (numero_afiliacion) using btree  in datos00_idx;
create index "informix".idx_tntc_cvv2_numcliente on "informix"
    .td_numeros_tarjetas_cliente_cvv2 (numcliente) using btree 
     in datos02_idx;
create index "informix".idx_tbl_info_tarjetas_abu_codstatustarjeta 
    on "informix".tbl_info_tarjetas_abu (codstatustarjeta) using 
    btree  in datos02_idx;
create index "informix".idx_tbl_info_tarjetas_abu_fechaultmodif 
    on "informix".tbl_info_tarjetas_abu (fechaultmodif) using 
    btree  in idx_info06;
create index "informix".idx_tbl_info_tarjetas_abu_numtarjeta 
    on "informix".tbl_info_tarjetas_abu (numtarjeta) using btree 
     in datos02_idx;
create index "informix".idx_tbl_info_tarjetas_abu_numtarjetasustituta 
    on "informix".tbl_info_tarjetas_abu (numtarjetasustituta) 
    using btree  in datos02_idx;
create index "informix".idx_tbl_abu_tar_activas_codstatustarjeta 
    on "informix".tbl_abu_tar_activas (codstatustarjeta) using 
    btree  in datos02_idx;
create index "informix".idx_tbl_abu_tar_activas_numtarjeta2 on 
    "informix".tbl_abu_tar_activas (numtarjeta) using btree  in 
    datos02_idx;
create index "informix".idx_tbl_abu_tar_bitacora_marca on "informix"
    .tbl_abu_tar_bitacora (marca) using btree  in datos02_idx;
    
create index "informix".idx_bitacora_tr_tarjeta_update_01 on 
    "informix".bitacora_tr_tarjeta_update (numtarjeta) using btree 
     in idx_info02;
create index "informix".idx_bitacora_tr_tarjeta_update_02 on 
    "informix".bitacora_tr_tarjeta_update (fecha_registro) using 
    btree  in idx_info02;
create index "informix".idx_fechaultmodif on "informix".tarjeta 
    (fechaultmodif,codstatustarjeta) using btree  in idx_info06;
    
create index "informix".idx_lotecodstatusasig on "informix".tarjeta 
    (numerolote,codstatusasignada) using btree  in idx_info06;
    
create index "informix".idx_nombre on "informix".tarjeta (nombre) 
    using btree  in idx_info05;
create index "informix".idx_numcte on "informix".tarjeta (numcliente) 
    using btree  in idx_info06;
create unique index "informix".idx_numtarjeta_2 on "informix".tarjeta 
    (numtarjeta) using btree  in idx_info06;
create index "informix".idx_tarjeta1 on "informix".tarjeta (fechaasignacion,
    numtarjeta) using btree  in idx_info05;
create index "informix".idx_tarjeta2 on "informix".tarjeta (fechaexp) 
    using btree  in idx_info06;
create index "informix".idx_tarjeta_codproductotarjeta on "informix"
    .tarjeta (codproductotarjeta) using btree  in idx_info05;
    
create index "informix".idx_tarjeta_codstatustarjeta on "informix"
    .tarjeta (codstatustarjeta) using btree  in idx_info06;
create index "informix".idx_tarjetacodpro on "informix".tarjeta 
    (fechaasignacion,codstatustarjeta,codstatusasignada) using 
    btree  in idx_info05;
create index "informix".idx_tarjetacteconfirmado on "informix"
    .tarjeta (numcliente,fechaultmodif) using btree  in idx_info06;
    
create index "informix".lote on "informix".tarjeta (numerolote) 
    using btree  in idx_info05;
alter table "informix".tarjeta add constraint primary key (numtarjeta) 
    constraint "informix".idx_tarpri ;
create index "informix".idx_tokenizacion_cardid_cardid on "informix"
    .tokenizacion_cardid (card_id) using btree  in dbs_cierrechq3;
    
create index "informix".idx_tokenizacion_bines_binfisico on "informix"
    .tokenizacion_bines (binfisico) using btree  in dbs_cierrechq3;
    
create index "informix".idx_tbl_ciclo_vida_tokenizacion_codstatustarjeta 
    on "informix".tbl_ciclo_vida_tokenizacion (codstatustarjeta) 
    using btree  in dbs_cierrechq3;
create index "informix".idx_tbl_ciclo_vida_bitacora_cardid on 
    "informix".tbl_ciclo_vida_bitacora (cardid) using btree  in 
    dbs_cierrechq3;
create index "informix".idx_tarjetas_tokenizadas_status on "informix"
    .tarjetas_tokenizadas (status) using btree  in dbs_cierrechq3;
    
create index "informix".idx_tarjetas_tokenizadas_tokenizada on 
    "informix".tarjetas_tokenizadas (tokenizada) using btree  
    in dbs_cierrechq3;
create index "informix".idx_tarjeta_estatus_tokenizacion_estatus 
    on "informix".tarjeta_estatus_tokenizacion (estatus) using 
    btree  in dbs_cierrechq3;
create index "informix".idx_bitacora_tokenizacion_otp_consumer_id 
    on "informix".bitacora_tokenizacion_otp (consumer_id) using 
    btree  in dbs_cierrechq3;
create index "informix".idx_bitacora_token_digitalcard_digital_cardid 
    on "informix".bitacora_token_digitalcard (digital_cardid) 
    using btree  in dbs_cierrechq3;
create index "informix".idx_bitacora_token_digitalcard_fecha 
    on "informix".bitacora_token_digitalcard (fecha_insert) using 
    btree  in dbs_cierrechq3;
create index "informix".idx_bitacora_token_cardoperation_card_id 
    on "informix".bitacora_token_cardoperation (card_id) using 
    btree  in dbs_cierrechq3;
create index "informix".idx_bitacora_token_cardoperation_fecha 
    on "informix".bitacora_token_cardoperation (fecha_insert) 
    using btree  in dbs_cierrechq3;
create index "informix".alertservice_edo_idreg on "informix".alertservice 
    (estatus,fechahoraproc) using btree ;
create index "informix".alertservice_fechahorareg on "informix"
    .alertservice (fechahorareg) using btree  in idx_info04;
create index "informix".alertservice_fecproc_est on "informix"
    .alertservice (estatus,idregistro) using btree ;
create index "informix".idx_alertservice_edo_idreg_hist on "informix"
    .alertservice_hist (estatus,fechahoraproc) using btree  in 
    dbs_movhis_idx2;
create index "informix".idx_alertservice_fecproc_est_hist on 
    "informix".alertservice_hist (estatus,idregistro) using btree 
     in dbs_movhis_idx1;
create index "informix".idx_info_tarjeta_vcas_01 on "informix"
    .info_tarjeta_vcas (numtarjeta) using btree  in idx_info02;
    
create index "informix".idx_info_tarjeta_vcas_02 on "informix"
    .info_tarjeta_vcas (codstatustarjeta) using btree  in idx_info02;
    
create index "informix".idx_info_tarjeta_vcas_03 on "informix"
    .info_tarjeta_vcas (fechaultmodif) using btree  in idx_info02;
    
create index "informix".idx_info_tarjeta_vcas_04 on "informix"
    .info_tarjeta_vcas (fechaasignacion) using btree  in idx_info02;
    
create index "informix".idx_info_tarjeta_vcas_historico_01 on 
    "informix".info_tarjeta_vcas_historico (numtarjeta) using 
    btree  in idx_info02;
create index "informix".idx_info_tarjeta_vcas_historico_02 on 
    "informix".info_tarjeta_vcas_historico (codstatustarjeta) 
    using btree  in idx_info02;
create index "informix".idx_info_tarjeta_vcas_historico_03 on 
    "informix".info_tarjeta_vcas_historico (fechaultmodif) using 
    btree  in idx_info02;
create index "informix".idx_info_tarjeta_vcas_historico_04 on 
    "informix".info_tarjeta_vcas_historico (fechaasignacion) using 
    btree  in idx_info02;
create index "informix".idx_archivos_control_vcas_01 on "informix"
    .archivos_control_vcas (nombre_archivo) using btree  in datos02_idx;
    
create index "informix".idx_archivos_control_vcas_02 on "informix"
    .archivos_control_vcas (fecha_generacion) using btree  in 
    datos02_idx;
create index "informix".idx_archivos_control_vcas_03 on "informix"
    .archivos_control_vcas (estatus,tipo_archivo) using btree 
     in datos02_idx;
create index "informix".idx_info_credenciales_vcas_01 on "informix"
    .info_credenciales_vcas (numero_cliente) using btree  in 
    datos02_idx;
create index "informix".idx_info_credenciales_vcas_02 on "informix"
    .info_credenciales_vcas (numero_tarjeta) using btree  in 
    datos02_idx;
create index "informix".idx_info_credenciales_vcas_03 on "informix"
    .info_credenciales_vcas (nombre_archivo) using btree  in 
    datos02_idx;
create index "informix".idx_info_credenciales_vcas_his_01 on 
    "informix".info_credenciales_vcas_his (numero_cliente) using 
    btree  in datos02_idx;
create index "informix".idx_info_credenciales_vcas_his_02 on 
    "informix".info_credenciales_vcas_his (numero_tarjeta) using 
    btree  in datos02_idx;
create index "informix".idx_info_credenciales_vcas_his_03 on 
    "informix".info_credenciales_vcas_his (nombre_archivo) using 
    btree  in datos02_idx;
create index "informix".idx_numtarj_vcas on "informix".ctas_vcas 
    (numtarjeta) using btree  in datos02_idx;
create index "informix".idx_bitacora_vcas_reporte_01 on "informix"
    .bitacora_vcas_reporte (fecha) using btree  in datos02_idx;
    
create index "informix".idx_fecha_conciliacion on "informix".conciliacion_atm_stat06_depositadores 
    (fecha_conciliacion) using btree ;
create index "informix".idx_tbl_msi_info_comercios_afiliados_01 
    on "informix".tbl_paso_msi_info_comercios_afiliados (identificador_registro) 
    using btree  in datos00;
create index "informix".idx_tbl_msi_info_comercios_afiliados_02 
    on "informix".tbl_paso_msi_info_comercios_afiliados (identificador_registro,
    clave_promocion,clave_afiliacion,cuenta_clabe) using btree 
     in datos00;
create index "informix".idx_afiliacionsinatc_numerodeafiliacion 
    on "informix".afiliacionsinatc (numerodeafiliacion,estatus) 
    using btree  in datos02_idx;
create index "informix".idx_temp_tar_exp_numtarjeta on "informix"
    .temp_tarjetas_expiradas (numtarjeta) using btree  in datos00;
    
create index "informix".idx_fecha_nombre on "informix".tb_control_reporteria_general 
    (nombre_reporte) using btree  in idx_info03;
create index "informix".idx_bitacora_cierre_sucursal_01 on "informix"
    .bitacora_cierre_sucursal (sucursaldestino,fecha,tablaregistro) 
    using btree  in idx_info05;
create index "informix".bitacora_tarjeta on "informix".bitacoracambiostarjeta 
    (tarjeta,fechacambio) using btree  in dbs_idxinteg;
create index "informix".idx_bitcambiostjt_01 on "informix".bitacoracambiostarjeta 
    (descvaloranterior) using btree  in idx_info04;
create index "informix".idx_bitcambiostjt_02 on "informix".bitacoracambiostarjeta 
    (descvalornuevo) using btree  in idx_info04;
create index "informix".idx_bitcambiostjt_03 on "informix".bitacoracambiostarjeta 
    (tarjeta) using btree  in dbs_idxinteg;
create index "informix".idx_fechacambio on "informix".bitacoracambiostarjeta 
    (fechacambio) using btree  in idx_info04;
create unique index "informix".pk_bitacoracambiostarjeta on "informix"
    .bitacoracambiostarjeta (secuencial,fechacambio) using btree 
     in idx_info04;
alter table "informix".bitacoracambiostarjeta add constraint 
    primary key (secuencial,fechacambio) constraint "informix"
    .pk_bitacora ;
create index "informix".idxarqcvalidos_febrero2026 on "informix"
    .arqcvalidos_febrero2026 (arqccalculado) using btree  in 
    dbs_idxinteg;
create index "informix".idxbitacoraatc_febrero2026 on "informix"
    .bitacoraatc_febrero2026 (secuenciaextendida) using btree 
     in dbs_idxinteg;
create unique index "informix".idx_pk_bitacora_fda_febrero2026 
    on "informix".bitacora_fda_febrero2026 (numtarjeta,secuenciaextendida,
    fechahorainauth) using btree  in dbs_idxinteg;
create index "informix".idxarqcvalidos_abril2026 on "informix"
    .arqcvalidos_abril2026 (arqccalculado) using btree  in dbs_idxinteg;
    
create index "informix".idxbitacoraatc_abril2026 on "informix"
    .bitacoraatc_abril2026 (secuenciaextendida) using btree  
    in dbs_idxinteg;
create unique index "informix".idx_pk_bitacora_fda_abril2026 
    on "informix".bitacora_fda_abril2026 (numtarjeta,secuenciaextendida,
    fechahorainauth) using btree  in dbs_idxinteg;
create index "informix".idx_arqcvalidos on "informix".arqcvalidos 
    (arqccalculado) using btree  in dbs_datos05;
create index "informix".idx_bitacoraatc on "informix".bitacoraatc 
    (secuenciaextendida) using btree  in dbs_datos05;
create unique index "informix".idx_pk_bitacora_fda on "informix"
    .bitacora_fda (numtarjeta,secuenciaextendida,fechahorainauth) 
    using btree  in dbs_idxinteg;


alter table "informix".tipotarjeta add constraint (foreign key 
    (clave) references "informix".productoimagen );
alter table "informix".tipotarjeta add constraint (foreign key 
    (bin) references "informix".bines  disabled );
alter table "informix".lote add constraint (foreign key (clave_tipotarjeta) 
    references "informix".tipotarjeta );
alter table "informix".lote add constraint (foreign key (clave_sucursal) 
    references "informix".sucursal );
alter table "informix".sucursal add constraint (foreign key (tipo_sucursal) 
    references "informix".tipo_sucursal );


create trigger "informix".tr_sucursal_tipotarjeta_solicitadas 
    update of solicitadas on "informix".sucursal_tipotarjeta referencing 
    old as original new as actual
    for each row
        when ((((original.solicitadas != actual.solicitadas 
    ) AND (USER != 'sysinven' ) ) AND (USER != 'informix' ) ) )
            (
            insert into "informix".bitacoracambiostarjeta (secuencial,
    tarjeta,numcliente,cuenta,titular,tabla,campo,valoranterior,valornuevo,
    fechacambio,usuariocambio,identificadorcambio,descripcioncambio)  values 
    (0 ,'' ,'' ,'' ,'' ,'intercard:sucursal_tipotarjeta' ,((('solicitadas-' || 
    original.clave_sucursal ) || '-' ) || original.clave_tipotarjeta ) ,original.solicitadas 
    ,actual.solicitadas ,CURRENT year to fraction(3) ,USER ,'4' ,'Actualizacion en solicitadas'
     ));

create trigger "informix".tr_sucursal_tipotarjeta_existencias 
    update of existencia on "informix".sucursal_tipotarjeta referencing 
    old as original new as actual
    for each row
        when ((((original.existencia != actual.existencia ) 
    AND (USER != 'sysinven' ) ) AND (USER != 'informix' ) ) )
            (
            insert into "informix".bitacoracambiostarjeta (secuencial,
    tarjeta,numcliente,cuenta,titular,tabla,campo,valoranterior,valornuevo,
    fechacambio,usuariocambio,identificadorcambio,descripcioncambio)  values 
    (0 ,'' ,'' ,'' ,'' ,'intercard:sucursal_tipotarjeta' ,((('existencia-' || original.clave_sucursal 
    ) || '-' ) || original.clave_tipotarjeta ) ,original.existencia ,actual.existencia 
    ,CURRENT year to fraction(3) ,USER ,'3' ,'Actualizacion en existencias'
     ));

create trigger "informix".tr_alta_sucursal_tipotarjeta insert 
    on "informix".sucursal_tipotarjeta referencing new as nueva
    
    for each row
        when ((USER != 'sysinven' ) )
            (
            insert into "informix".bitacoracambiostarjeta (secuencial,
    tarjeta,numcliente,cuenta,titular,tabla,campo,valoranterior,valornuevo,
    fechacambio,usuariocambio,identificadorcambio,descripcioncambio)  values 
    (0 ,'' ,'' ,'' ,'' ,'intercard:sucursal_tipotarjeta' ,('clave_sucursal-' || 
    nueva.clave_sucursal ) ,'' ,'' ,CURRENT year to fraction(3) ,USER ,'5' ,
    'Alta nueva sucursal' ));

create trigger "informix".tr_monitor_conciliacionaut_update update 
    of aplicar_saldos on "informix".monitor_conciliacionaut referencing 
    old as pre new as post
    for each row
        (
        --/*****************************************************************************************************
        -- DESCRIPCION: IDENTIFICA CUANDO EL CAMPO "APLICAR_SALDOS" ES ACTUALIZADO Y ENVIA LOS DATOS --REQUERIDOS AL SP DE VALIDACION PARA CORRER LA CONCILIACION ADMINISTRATIVA DE MANERA AUTOMATICA --AL CONCILIARCE CORRECTAMENTE LO 2 ARCHIVOS DE TIENDAS COPPEL 
        -- AUTOR : Casanova Edeza Hector Juan
        -- FECHA : 09/02/2010
        -- BD: Intercard
        -- SISTEMA : Conciliacion Intercard -- Automatico --- ADMINISTRATIVA
        -- MODIFICADO : 
        --***************************************************************************************************
        execute procedure "informix".sp_aplica_genconadmin(post.usuario 
    ,post.archivoorigen ,post.nom_archivo ,post.aplicar_saldos ,post.fechaconciliacion 
    ));

create trigger "informix".tr_monitor_conciliacionman_insert insert 
    on "informix".monitor_conciliacionman referencing new as post
    
    for each row
        (
        --****************************************************************************************************
        -- DESCRIPCION: IDENTIFICA CUANDO SE INSERTA UN NUEVO REGISTRO EN LA TABLA Y ENVIA LOS DATOS REQUERIDOS AL SP DE VALIDACION PARA CORRER LA CONCILIACION ADMINISTRATIVA DE MANERA AUTOMATICA AL CONCILIARCE CORRECTAMENTE LO 2 ARCHIVOS DE TIENDAS COPPEL 
        -- AUTOR : Casanova Edeza Hector Juan
        -- FECHA : 09/06/2010
        -- BD: Intercard
        -- SISTEMA : Conciliacion Intercard -- Automatico --- ADMINISTRATIVA -- CORRESPONSALES
        -- MODIFICADO : 
        --***************************************************************************************************
        execute procedure "informix".sp_aplica_genconadmin(post.usuario 
    ,post.archivoorigen ,post.nom_archivo ,post.aplicar_saldos ,post.fechaconciliacion 
    ));

create trigger "informix".tr_solicitud_maquila_delete delete 
    on "informix".solicitud_maquila referencing old as pre
    for each row
        when ( 1=1 )
            (
            insert into "informix".bitacoramaquilaeliminada (secuencial,
    consecutivo,clave_sucursal,indicadortipoproceso,clave_tipotarjeta,fechaexp,
    codproductotarjeta,cantidad,fecha_generacion,nom_cliente,usuariosolicito,
    tipomaquila,fechaeliminacion,usuarioelimino)  values (0 ,pre.consecutivo 
    ,pre.clave_sucursal ,pre.indicadortipoproceso ,pre.clave_tipotarjeta 
    ,pre.fechaexp ,pre.codproductotarjeta ,pre.cantidad ,pre.fecha_generacion 
    ,pre.nom_cliente ,pre.usuario ,pre.tipomaquila ,CURRENT year to fraction(3) 
    ,(select x0.usuario from "informix".solicitud_eliminada_usuario x0 where 
    (x0.consecutivo = pre.consecutivo ) ) ));

create trigger "informix".tr_alta_afiliacionpermitida insert 
    on "informix".afiliacionpermitida referencing new as nueva
    
    for each row
        when ( 1=1 )
            (
            insert into "informix".bitacoraafiliacionpermitida 
    (numerodeafiliacion,descripcion,tipoevento,estatus,vigencia,comentarios,
    fecharegistro,usuarioregistro,permitecvv2dual)  values (nueva.afiliacion 
    ,nueva.descripcion ,'A' ,nueva.estatus ,nueva.vigencia ,nueva.comentarios 
    ,CURRENT year to fraction(3) ,nueva.usuarioregistro ,nueva.permitecvv2dual 
    ));

create trigger "informix".tr_cambio_afiliacionpermitida update 
    on "informix".afiliacionpermitida referencing old as anterior 
    new as nueva
    for each row
        when ( 1=1 )
            (
            insert into "informix".bitacoraafiliacionpermitida 
    (numerodeafiliacion,descripcion,tipoevento,estatus,vigencia,comentarios,
    fecharegistro,usuarioregistro,permitecvv2dual)  values (nueva.afiliacion 
    ,nueva.descripcion ,'C' ,nueva.estatus ,nueva.vigencia ,nueva.comentarios 
    ,CURRENT year to fraction(3) ,nueva.usuarioregistro ,nueva.permitecvv2dual 
    ));

create trigger "informix".tr_tarjetavip_update_estatus update 
    of estatus on "informix".tarjetavip referencing old as pre 
    new as pos
    for each row
        when ( 1=1 )
            (
            insert into "informix".bitacoracambiostarjeta (tarjeta,
    numcliente,cuenta,titular,tabla,campo,valoranterior,valornuevo,fechacambio,
    usuariocambio,identificadorcambio,descripcioncambio,descvaloranterior,
    descvalornuevo)  values (pos.numtarjeta ,(select x0.numcliente from "informix"
    .tarjeta x0 where (x0.numtarjeta = pos.numtarjeta ) ) ,(select x1.numcuenta 
    from "informix".tarjetacuenta x1 where (x1.numtarjeta = pos.numtarjeta 
    ) ) ,(select x2.titular from "informix".tarjeta x2 where (x2.numtarjeta 
    = pos.numtarjeta ) ) ,'InterCard.tarjetavip' ,pos.estatus ,pre.estatus 
    ,pos.estatus ,CURRENT year to fraction(3) ,USER ,'6' ,'Cambio status tarjeta VIP'
     ,'' ,'' ));

create trigger "informix".tr_alta_tipoproducto insert on "informix"
    .binproducto referencing new as nuevo
    for each row
        when (((nuevo.idbinproducto != ANY (select x0.idbinproducto 
    from "informix".binproducto x0 ) ) AND (SUBSTR (nuevo.codproductotarjeta 
    ,1 ,1 )= '5' ) ) )
            (
            insert into "informix".producto_tipo (idbinproducto,
    codproductotarjeta,descodprodtarjeta,desccodprodcta,fecha_registro,tipoproducto) 
     values (nuevo.idbinproducto ,nuevo.codproductotarjeta ,nuevo.desccodprodtarjeta 
    ,nuevo.desccodprodcta ,nuevo.fecha_registro ,'DD' )),
        when (((nuevo.idbinproducto != ANY (select x1.idbinproducto 
    from "informix".binproducto x1 ) ) AND (SUBSTR (nuevo.codproductotarjeta 
    ,1 ,1 )= '0' ) ) )
            (
            insert into "informix".producto_tipo (idbinproducto,
    codproductotarjeta,descodprodtarjeta,desccodprodcta,fecha_registro,tipoproducto) 
     values (nuevo.idbinproducto ,nuevo.codproductotarjeta ,nuevo.desccodprodtarjeta 
    ,nuevo.desccodprodcta ,nuevo.fecha_registro ,'CD' ));

create trigger "informix".tr_alta_tipoproducto_delete delete 
    on "informix".binproducto referencing old as ant
    for each row
        (
        delete from "informix".producto_tipo  where (idbinproducto 
    = ant.idbinproducto ) );

create trigger "informix".tr_alta_tipoproducto_update update 
    on "informix".binproducto referencing new as nuevo
    for each row
        (
        update "informix".producto_tipo set "informix".producto_tipo.codproductotarjeta 
    = nuevo.codproductotarjeta ,"informix".producto_tipo.descodprodtarjeta 
    = nuevo.desccodprodtarjeta ,"informix".producto_tipo.desccodprodcta 
    = nuevo.desccodprodcta ,"informix".producto_tipo.fecha_registro = 
    nuevo.fecha_registro  where (idbinproducto = nuevo.idbinproducto 
    ) );

create trigger "informix".tr_cat_imagenespredisenadas_update 
    update on "informix".cat_imagenespredisenadas referencing 
    old as pre new as pos
    for each row
        when ((pos.contcambimagen != pre.contcambimagen ) )
            (
            insert into "informix".bitacoracatimagenespredisenadas 
    (secuencial,id_diseno,descripcion_previo,descripcion_nuevo,estatus_previo,
    estatus_nuevo,producto_previo,producto_nuevo,cambioimagen,fechacambio,
    usuariocambio)  values (0 ,pos.id_diseno ,pre.descripcion_diseno ,pos.descripcion_diseno 
    ,pre.estatus ,pos.estatus ,pre.producto ,pos.producto ,'V' ,CURRENT year 
    to fraction(3) ,(select x0.usuariocambio from "informix".cat_imagenespredisenadas 
    x0 where (x0.id_diseno = pos.id_diseno ) ) )),
        when (((pos.contcambimagen = pre.contcambimagen ) AND 
    (((pos.descripcion_diseno != pre.descripcion_diseno ) OR (pos.estatus 
    != pre.estatus ) ) OR (pos.producto != pre.producto ) ) ) )
            (
            insert into "informix".bitacoracatimagenespredisenadas 
    (secuencial,id_diseno,descripcion_previo,descripcion_nuevo,estatus_previo,
    estatus_nuevo,producto_previo,producto_nuevo,cambioimagen,fechacambio,
    usuariocambio)  values (0 ,pos.id_diseno ,pre.descripcion_diseno ,pos.descripcion_diseno 
    ,pre.estatus ,pos.estatus ,pre.producto ,pos.producto ,'F' ,CURRENT year 
    to fraction(3) ,(select x1.usuariocambio from "informix".cat_imagenespredisenadas 
    x1 where (x1.id_diseno = pos.id_diseno ) ) ));

create trigger "informix".tr_alta_afiliacioncof insert on "informix"
    .afiliacioncof referencing new as nueva
    for each row
        when ( 1=1 )
            (
            insert into "informix".bitacoraafiliacioncof (numerodeafiliacion,
    descripcion,tipoevento,estatus,comentarios,fecharegistro,usuarioregistro) 
     values (nueva.afiliacion ,nueva.descripcion ,'1' ,nueva.estatus ,nueva.comentarios 
    ,CURRENT year to fraction(3) ,nueva.usuarioregistro ));

create trigger "informix".tr_cambio_afiliacioncof update on "informix"
    .afiliacioncof referencing old as anterior new as nueva
    for each row
        when ( 1=1 )
            (
            insert into "informix".bitacoraafiliacioncof (numerodeafiliacion,
    descripcion,tipoevento,estatus,comentarios,fecharegistro,usuarioregistro) 
     values (nueva.afiliacion ,nueva.descripcion ,'0' ,nueva.estatus ,nueva.comentarios 
    ,CURRENT year to fraction(3) ,nueva.usuarioregistro ));

create trigger "informix".tr_tarjeta_update update on "informix"
    .tarjeta referencing new as updt
    for each row
        when (((updt.codstatustarjeta = 'ACT' ) AND (updt.fechaultmodif 
    >= TODAY ) ) )
            (
            insert into "informix".info_tarjeta_pyt (numtarjeta,
    codstatustarjeta,codproductotarjeta,titular,fechaasignacion,fechaultmodif) 
     values (updt.numtarjeta ,updt.codstatustarjeta ,updt.codproductotarjeta 
    ,updt.titular ,updt.fechaasignacion ,updt.fechaultmodif ));

create trigger "informix".tr_tarjeta_update_codproducto update 
    of codproductotarjeta on "informix".tarjeta referencing old 
    as pre new as pos
    for each row
        when (((((pre.codproductotarjeta = ANY (select x0.codproductotarjeta 
    from "informix".productotarjeta x0 ) ) AND ((pre.codstatusasignada 
    = 'SIA' ) OR (pre.codstatusasignada = 'NOA' ) ) ) AND (pre.codstatustarjeta 
    != 'INA' ) ) AND (pos.codproductotarjeta != pre.codproductotarjeta 
    ) ) )
            (
            -- Se especifica que campo en especial se debe revisar
            -- Para validar que el producto tarjeta exista en los catalogos 
            -- Valor previo antes de la actualización debe ser este para que no tome cuando es nueva asignación
            -- Para que solo considere aquellas tarjetas cuya status sea diferente a Inactiva
            -- Para que no se ponga estatus iguales
            insert into "informix".bitacoracambiostarjeta (secuencial,
    tarjeta,numcliente,cuenta,titular,tabla,campo,valoranterior,valornuevo,
    fechacambio,usuariocambio,identificadorcambio,descripcioncambio)  values 
    (0 ,pos.numtarjeta ,pos.numcliente ,(select x1.numcuenta from "informix"
    .tarjetacuenta x1 where (x1.numtarjeta = pre.numtarjeta ) ) ,pos.titular 
    ,'Intercard:tarjeta' ,'codproductotarjeta' ,pre.codproductotarjeta ,pos.codproductotarjeta 
    ,CURRENT year to fraction(3) ,USER ,'2' ,'Cambio código producto' ));

create trigger "informix".tr_tarjeta_update_codstatus update 
    of codstatustarjeta on "informix".tarjeta referencing old 
    as pre new as pos
    for each row
        when (((((pre.codstatustarjeta = ANY (select x0.codstatustarjeta 
    from "informix".statustarjeta x0 ) ) AND ((pre.codstatusasignada = 
    'SIA' ) OR (pre.codstatusasignada = 'NOA' ) ) ) AND (pre.codstatustarjeta 
    != 'INA' ) ) AND (pos.codstatustarjeta != pre.codstatustarjeta ) ) 
    )
            (
            -- Se especifica que campo en especial se debe revisar 
            -- Para validar que el codigo del estatus de tarjeta exista en los catalogos
            -- Valor previo antes de la actualización debe ser este para que no tome cuando es nueva asignación
            -- Para que solo considere aquellas tarjetas cuya status sea diferente a Inactiva
            -- Para que no se ponga estatus iguales 
            insert into "informix".bitacoracambiostarjeta (secuencial,
    tarjeta,numcliente,cuenta,titular,tabla,campo,valoranterior,valornuevo,
    fechacambio,usuariocambio,identificadorcambio,descripcioncambio)  values 
    (0 ,pos.numtarjeta ,pos.numcliente ,(select x1.numcuenta from "informix"
    .tarjetacuenta x1 where (x1.numtarjeta = pre.numtarjeta ) ) ,pos.titular 
    ,'Intercard:tarjeta' ,'codstatustarjeta' ,pre.codstatustarjeta ,pos.codstatustarjeta 
    ,CURRENT year to fraction(3) ,USER ,'1' ,'Cambio status tarjeta' )),
        when ((pos.codstatustarjeta != 'ACT' ) )
            (
            update "informix".tarjetavip set "informix".tarjetavip.estatus 
    = 'C'  where ((numtarjeta = pos.numtarjeta ) AND (estatus = 'A' ) ) );

create trigger "informix".tr_tarjeta_vcas update on "informix"
    .tarjeta referencing new as updt
    for each row
        when ((((((((updt.codstatustarjeta = 'ACT' ) OR (updt.codstatustarjeta 
    = 'BLO' ) ) OR (updt.codstatustarjeta = 'BLT' ) ) OR (updt.codstatustarjeta 
    = 'CAN' ) ) OR (updt.codstatustarjeta = 'FAL' ) ) OR (updt.codstatustarjeta 
    = 'ROB' ) ) OR (updt.codstatustarjeta = 'EXT' ) ) )
            (
            execute procedure "informix".sp_tr_tarjeta_vcas(updt.numtarjeta 
    ,updt.codstatustarjeta ,updt.codstatusasignada ,updt.fechaasignacion 
    ,updt.usuarioultmodif ));

create trigger "informix".trg_cambiotarjeta_insert insert on 
    "informix".bitacoracambiostarjeta referencing new as nvo
    for each row
        (
        execute procedure "informix".sp_valida_cambio_status(nvo.secuencial 
    ,nvo.valoranterior ,nvo.valornuevo ));