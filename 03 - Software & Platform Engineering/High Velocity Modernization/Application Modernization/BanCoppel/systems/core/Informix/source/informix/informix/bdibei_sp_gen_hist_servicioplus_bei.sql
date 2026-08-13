CREATE PROCEDURE "informix".sp_gen_hist_servicioplus_bei(pNumcte VARCHAR(9))
RETURNING CHAR (5);

--****************************************************************************************************
-- DESCRIPCION: Se guarda la información relevante del servicio anterior de la empresa a tablas historicas
--		la sobrante se depura, y se llama a spl que cambia los id de imagenes. De manera que el 
--		cliente queda "limpio" para solicitar de nuevo el servicio.
-- AUTOR: David Picos	
-- FECHA: 12/08/2014
-- BD: bdibei
-- SOLICITO: Alejandro Vazquez
-- Liberado a produccion: 23 Octubre 2014
-- MODIFICACION: para borrar el registro de los avatar que tenian lo usuarios.
-- MODIFICO:Berenice Noriega Guevara - BanCoppel - Coordinación Internet
-- SOLICITO: Alejandro Vazquez
-- FECHA CAMBIO: 24-Feb-2015
--***************************************************************************************************

DEFINE sql_err int;
	DEFINE cod_ret CHAR (5);
	DEFINE vNumCte VARCHAR(9);
	DEFINE vIdusuario INTEGER;
	DEFINE vIdperfil INTEGER;
	
	DEFINE sTipoMov SMALLINT;
	DEFINE sCountDet SMALLINT;
	DEFINE sCountH SMALLINT;

	LET cod_ret = '00000';

	LET vNumCte =0;
	LET vIdusuario = 0;
	LET vIdperfil = 0;
	
	LET sTipoMov =0;
	LET sCountDet=0;
	LET sCountH=0;


 
	BEGIN
--****************************************************************************************************
-- Excepciones:
--***************************************************************************************************
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cod_ret = sql_err;
				RETURN cod_ret;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
		
--Respaldo de Datos bei_contratacion
		IF EXISTS (	select num_cliente
					FROM bdibei:"informix".bei_contratacion
					where num_cliente = TRIM(pNumcte)) THEN 
	
				INSERT INTO "informix".bei_contratacion_his
				(
				empresa,num_cliente,folio_contrato,oper_no_token,rep_legal,f_registro,num_empleado,fecha_movto,
				usuario_atiende,usuario_aut,suc_registro,status_contrato,f_mov_historico)
				SELECT 	empresa,num_cliente,folio_contrato,oper_no_token,rep_legal,f_registro,num_empleado,fecha_movto,usuario_atiende,
				usuario_aut,suc_registro,status_contrato,current
				FROM bdibei:"informix".bei_contratacion
				WHERE num_cliente= pNumcte;
        	
				DELETE bdibei:"informix".bei_contratacion WHERE num_cliente=TRIM(pNumcte);
				--LET cod_ret = '00015';
				--return cod_ret;
	END IF			

--Respaldo de Datos bei_servicio
	IF EXISTS (	select num_cliente
					FROM bdibei:"informix".bei_servicio
					where num_cliente = TRIM(pNumcte)) THEN 
	
				INSERT INTO "informix".bei_servicio_his
				(num_cliente,id_servicio,folio_contrato,folio_activa,id_status,codidentif,identificacion_admin,f_status,
				f_registro,f_unico_reg,ns_token,status_manco,f_mod_manco,f_reg_manco,id_usuario,apell_paterno,
				apell_materno,nombre1,nombre2,es_replegal,f_mov_historico)
				SELECT 	num_cliente,id_servicio,folio_contrato,folio_activa,id_status,codidentif,identificacion_admin,f_status,
				f_registro,f_unico_reg,ns_token,status_manco,f_mod_manco,f_reg_manco,id_usuario,apell_paterno,
				apell_materno,nombre1,nombre2,es_replegal,current
				FROM bdibei: "informix".bei_servicio
				WHERE num_cliente= pNumcte;
        	
				DELETE bdibei:"informix".bei_servicio WHERE num_cliente=TRIM(pNumcte);

				--LET cod_ret = '00016';
				--return cod_ret;
	END IF
	
--Limpia de tabla bei_cambiostusuario

--Respaldo de Datos bei_datos_usuario

--Respaldo de Datos bei_usuario
  --para poder borrar  de esta tabla primero se tiene que eliminar datos de otras, que son las siguientes: 
				FOREACH
					SELECT id_usuario
					INTO vIdusuario
					FROM "informix".bei_usuario
					WHERE num_cliente=pNumcte 
					 
					IF vIdusuario <>0 OR vIdusuario IS NOT NULL THEN
                            
											SELECT id_perfil INTO vIdperfil FROM bdibei:"informix".bei_usuario_perfil WHERE id_usuario=vIdusuario; 
											--Elimina las operaciones del perfil y el perfil
											DELETE bdibei:"informix".bei_usuario_perfil WHERE id_usuario=vIdusuario;
											
											IF vIdperfil<>10 THEN
											
											DELETE bdibei:"informix".bei_perfil WHERE id_perfil=vIdperfil;
											DELETE bdibei:"informix".bei_operaciones WHERE id_perfil=vIdperfil;
											
											END IF;
											
											--Bitacora---- -- CONSULTAR SI SERA NECESARIO QUE ESTO SE BORRE - NORMATIVIDAD
											--delete  bdibei:bei_bitacora where id_usuario=vIdusuario;
											
											--Limpia de tabla bei_cambiostusuario
											DELETE bdibei:"informix".bei_cambiostusuario WHERE id_usuario=vIdusuario;
											
											DELETE bdibei:bei_operacionesmancomunadasoperadorresumen WHERE id_usuario=vIdusuario;
											DELETE bdibei:bei_operacionesmancomunadasoperador WHERE id_usuario=vIdusuario;
											DELETE  bdibei:bei_mancomunidad  WHERE id_usuario=vIdusuario;
											---Usuario y datos-------
											--Se elimina el usuario
																					
											--respaldar a tablas de historicos
											
											INSERT INTO "informix".bei_datos_usuario_his
											(id_usuario,nombre,tel_celular,cia_cel,e_mail,activo,id_ultima_oper,fecha_bloqueo,
											fecha_bloqueo_camb_pass,fecha_bloqueo_camb_pregs,tipo_bloqueo_temp_pass,tipo_bloqueo_temp_resp,
											f_mov_historico)
											SELECT 	 id_usuario,nombre,tel_celular,cia_cel,e_mail,activo,id_ultima_oper,fecha_bloqueo,
											fecha_bloqueo_camb_pass,fecha_bloqueo_camb_pregs,tipo_bloqueo_temp_pass,tipo_bloqueo_temp_resp,current
											FROM bdibei:"informix".bei_datos_usuario
											WHERE id_usuario=vIdusuario;
											
											DELETE  bdibei:"informix".bei_datos_usuario WHERE id_usuario=vIdusuario;
											
											INSERT INTO "informix".bei_usuario_his
											(id_usuario,num_cliente,id_status,usuario_bei,pass,f_pass,pass1,f_pass1,pass2,f_pass2,
											pass3,f_pass3,f_status,f_ultimo_acceso,f_actualizacion,f_registro,fec_primer_acceso,id_tipo_usuario,
											f_bloqueo_temp,f_mov_historico)
											SELECT 	id_usuario,num_cliente,id_status,usuario_bei,pass,f_pass,pass1,f_pass1,pass2,f_pass2,
											pass3,f_pass3,f_status,f_ultimo_acceso,f_actualizacion,f_registro,fec_primer_acceso,id_tipo_usuario,
											f_bloqueo_temp,current
											FROM bdibei:"informix".bei_usuario
											WHERE num_cliente= pNumcte AND id_usuario=vIdusuario;
											
											DELETE  bdibei:"informix".bei_usuario WHERE num_cliente=pNumcte AND id_usuario=vIdusuario;

						                                       -------BORRAR AVATAR----------------------------------------------------------------------
						                                       IF EXISTS (select num_cliente FROM bdibei:"informix".bei_avatar
						                                                  where num_cliente = TRIM(pNumcte) AND id_usuario=vIdusuario) THEN 
						                                       DELETE  bdibei:"informix".bei_avatar where num_cliente=pNumcte AND id_usuario=vIdusuario;
						                                       END IF
						                                       ------------------------------------------------------------------------------------------

					END IF;
					
				END FOREACH;
					

--Respaldo de Datos bei_solicitudtoken
		IF EXISTS (	select numcte
					FROM bdibei: "informix".bei_solicitudtoken
					where numcte = TRIM(pNumcte)) THEN 
	
				INSERT INTO "informix".bei_solicitudtoken_his
				(solicitud,numcte,id_status,unidades,sucursal,f_solicitud,f_atencion,sec_domicilio,usr_solicita,usr_atiende,folio_suc
				,comentarios,f_mov_historico)
				SELECT 	solicitud,numcte,id_status,unidades,sucursal,f_solicitud,f_atencion,sec_domicilio,usr_solicita,usr_atiende,folio_suc
				,comentarios,current
				FROM bdibei: "informix".bei_solicitudtoken
				WHERE numcte= pNumcte;
				
				DELETE bdibei:"informix".bei_solicitudtoken WHERE numcte=TRIM(pNumcte);
				--LET cod_ret = '00017';
				--return cod_ret;

		END IF
	
--Respaldo de Datos bei_tokensolicitud

	IF EXISTS (	select numcte
					FROM bdibei: "informix".bei_tokensolicitud
					where numcte = TRIM(pNumcte)) THEN 
	
				INSERT INTO "informix".bei_tokensolicitud_his
				(ns_token,solicitud,numcte,id_status,f_mov_historico)
				SELECT 	ns_token,solicitud,numcte,id_status,current
				FROM bdibei:"informix".bei_tokensolicitud
				WHERE numcte= pNumcte;
				
				DELETE bdibei:"informix".bei_tokensolicitud WHERE numcte=TRIM(pNumcte);
				--LET cod_ret = '00018';
				--return cod_ret;

	END IF
	
--Respaldo de Datos bei_envios
	
	IF EXISTS (	select numcte
					FROM bdibei: "informix".bei_envios
					where numcte = TRIM(pNumcte)) THEN 
	
				INSERT INTO "informix".bei_envios_his
				(num_guia,cod_rastreo,solicitud,numcte,num_envio,id_status,comentarios,
				f_envio,f_registro,f_mov_historico)
				SELECT 	num_guia,cod_rastreo,solicitud,numcte,num_envio,id_status,comentarios,
				f_envio,f_registro,current
				FROM bdibei: "informix".bei_envios
				WHERE numcte= pNumcte;
				
				DELETE bdibei:"informix".bei_envios WHERE numcte=TRIM(pNumcte);
				--LET cod_ret = '00019';
				--return cod_ret;

	END IF
	
--Respaldo de imagenes scaneadas por empresa

	EXECUTE PROCEDURE bdidigital:"informix".sp_doctos_previos_recontrata(pNumcte) 
	INTO cod_ret;

	IF cod_ret <> '00000'
	THEN 
		LET cod_ret = '00020'; --error de SPL
		return cod_ret;
	
	END IF
	
	return cod_ret;
	
  END;

END PROCEDURE;