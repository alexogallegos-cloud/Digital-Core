CREATE PROCEDURE "informix".sp_cambio_sic(pinstitucion	CHAR(2),pnum_solicitud	CHAR(25))

	RETURNING CHAR(5) AS retorno;
	------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------
	-- Autor: Felix Ignacio Leyva Gamez
	-- Fecha: 30/12/2022
	-- Descripcion: Sp que realiza el cambio de SIC consultada a la otra SIC, como respaldo.
	--				En caso de no tener respuesta de la primera SIC consultada
	-- Peticion: RQM 09 606 - Consulta aleatoria a las SIC's cadena 2x1 - OriginaciÃ³n
	------------------------------------------------------------------------------------
	--ModificÃ³: 
	--Fecha de modificacion: 
	--Descripcion: 
	--Peticion: 
	------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------
	
	-- ****************************************************************************
	-- *                        DEFINICION DE VARIABLES                           *
	-- ****************************************************************************
	
	DEFINE scod_ret				CHAR(5);
	DEFINE p_cod_ret			CHAR(6);
	DEFINE vsqlerr				INTEGER;
	DEFINE cResultado			CHAR(6);
	DEFINE cMensajeRes			CHAR(8);
	DEFINE tipo_acceso_sic		CHAR (03);
	DEFINE usu_sic				CHAR(10);
	DEFINE pass_sic				CHAR(8);
	DEFINE vfecha				DATE;
	DEFINE vnumcte				CHAR(20);
	
	DEFINE v_num_sol_conjunta	CHAR(20);
	DEFINE v_envio				CHAR(255);
	DEFINE v_envio1				CHAR(255);
	DEFINE v_envio2				CHAR(255);
	DEFINE v_status				CHAR(1);
	
	------Definicion de nuevas variables-----------------------------------------
	
	DEFINE v_institucion		CHAR(2);
	DEFINE v_numcte				CHAR(20);
	DEFINE v_num_solicitud		CHAR(25);
	DEFINE v_envio3				CHAR(255);
	DEFINE v_envio4				CHAR(255);
	DEFINE v_envio5				CHAR(255);
	DEFINE v_status1			CHAR(1);
	DEFINE v_fecha_insert		DATE;
	------------------------------------------------------------------------------
	
	DEFINE vFalloSIC			INTEGER;
	DEFINE vcanal_sol			CHAR(2);
	DEFINE vNuevaSIC			CHAR(2);
	DEFINE pcomentario			VARCHAR(255,1);
	
	DEFINE v_sql				char(1024);
	
	-- ****************************************************************************
	-- *                        ASIGNACION DE VARIABLES                           *
	-- ****************************************************************************
	
	LET scod_ret				= "000";
	LET p_cod_ret				= "000000";
	LET vsqlerr					= 0;
	LET cResultado				= "";
	LET cMensajeRes				= "";
	LET v_num_sol_conjunta		= "";
	LET vnumcte					= "";
	
	LET vFalloSIC				= 0;
	LET vcanal_sol				= "";
	LET vNuevaSIC				= "";
	LET pcomentario				= "";
	
	-- ****************************************************************************
	-- *                        CONTROL DE ERRORES                                *
	-- ****************************************************************************

	BEGIN
	ON EXCEPTION SET vsqlerr
	   IF vsqlerr != 0 THEN
		  LET scod_ret=vsqlerr;
		  ROLLBACK WORK;
		  RETURN scod_ret;
	   END IF;
	END EXCEPTION WITH RESUME;
	
	--SET DEBUG FILE TO '/informix/FelixLeyva/Aleatorio/LOGS/sp_cambio_sic-'||pnum_solicitud||'.out';
	--TRACE ON;
	
	--SET DEBUG FILE TO '/home/c90077639/ACT_DEMONIO/sp_cambio_sic-'||pnum_solicitud||'.out';
	--TRACE ON;
	
	BEGIN WORK;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- ****************************************************************************
	-- *                        PROGRAMA PRINCIPAL                                *
	-- ****************************************************************************
	
	--validacion de Parametros
	IF pinstitucion = '' OR pinstitucion IS NULL OR pnum_solicitud = '' OR pnum_solicitud IS NULL THEN
		LET scod_ret = '00001'; --PARAMETRO VACIO
		COMMIT WORK;
		RETURN scod_ret;
	END IF;
	
	--Tomar el numero de cliente y el canal de la solicitud
		SELECT canal_sol,numcte
			INTO vcanal_sol,vnumcte
				FROM bdisolic:"informix".ss_solicitudes
				WHERE empresa = '001'
				AND num_solicitud = pnum_solicitud;
		
	-----------------------------------------------------------------------------------------------------------------------
	--ActualizaciÃ³n a status 9 de la trama
	
	UPDATE bdiburo:br_traslado SET status = '9' WHERE institucion = pinstitucion AND numcte = vnumcte AND num_solicitud = pnum_solicitud;
	
	-----------------------------------------------------------------------------------------------------------------------
	
	--Valida si es un folio del autenticador
	IF length(pnum_solicitud) < 25 Then
		IF vcanal_sol NOT IN ('6','7','4') THEN -- Validar los canales de OneClick y Autosolicitudes, no entran en el cambio de SIC
			--Obtener la bandera de FalloSIC
			SELECT FalloSIC
				INTO vFalloSIC
					FROM bdisolic:"informix".ss_solicitudes_sic
					WHERE ROWID = (SELECT MAX(rowid)
							FROM bdisolic:"informix".ss_solicitudes_sic
							WHERE numcte= vnumcte
							AND num_solicitud = pnum_solicitud
							AND institucion = pinstitucion);
								
			IF vFalloSIC = 0 THEN --Validar si la bandera no esta activa
				
				--Asignar la Otra institucion
				IF pinstitucion = 'BC' THEN
					LET vNuevaSIC	= 'CC';
					
					--Numero de producto TIPO CONSULTA CC
					select trim(valor) into tipo_acceso_sic
					from bdiburo:br_param
					where cod_param = 141;  
					
					--Usuario Consolidado
					select trim(valor) into usu_sic
					from bdiburo:br_param
					where cod_param = 1;   
					
					--Password Consolidado
					select trim(valor) into pass_sic
					from bdiburo:br_param
					where cod_param = 2;   
					
				ELSE
					LET vNuevaSIC = 'BC';
					
					--Numero de producto TIPO CONSULTA BC
					select trim(valor) into tipo_acceso_sic
					from bdiburo:br_param
					where cod_param = 126;
					
					--Usuario Consolidado
					select trim(valor) into usu_sic
					from bdiburo:br_param
					where cod_param = 124;
					
					--Password Consolidado
					select trim(valor) into pass_sic
					from bdiburo:br_param
					where cod_param = 125;
					
				END IF;	
				
				LET pcomentario	= "SOLICITUD ENVIADA A " || vNuevaSIC || " por Respaldo de SIC";
				
				--Consultar solicitud conjunta
				SELECT num_solicitud
					INTO v_num_sol_conjunta
						FROM  bdisolic:"informix".ss_solicitudes_sic
							WHERE numcte = vnumcte
							AND num_solicitud_sic = pnum_solicitud
							AND num_solicitud <> pnum_solicitud;
							
				--Validar si se tiene solicitud conjunta, para tambien actualizarla
				IF v_num_sol_conjunta is not null  THEN
				
					-- Actualizar el estatus de la solicitud
					EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol ('001', 'sistema',v_num_sol_conjunta, vNuevaSIC, '', pcomentario) INTO p_cod_ret;
					
					IF p_cod_ret <> '000000' THEN
						LET scod_ret= '00003'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
						ROLLBACK WORK;
						RETURN scod_ret;
					END IF;
					
					-- Actualizar la institucion de la solicitud en la SIC
					UPDATE bdisolic:"informix".ss_solicitudes_sic SET institucion = vNuevaSIC, FalloSIC = 1 WHERE numcte = vnumcte AND num_solicitud = v_num_sol_conjunta;
				END IF;	
				
				-- Actualizar el estatus de la solicitud
				EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol ('001', 'sistema',pnum_solicitud, vNuevaSIC, '', pcomentario) INTO p_cod_ret;
				
				IF p_cod_ret <> '000000' THEN
					LET scod_ret= '00003'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
					ROLLBACK WORK;
					RETURN scod_ret;
				END IF;
				
				-- Actualizar la institucion de la solicitud en la SIC
				UPDATE bdisolic:"informix".ss_solicitudes_sic SET institucion = vNuevaSIC, FalloSIC = 1 
					WHERE numcte = vnumcte AND num_solicitud = pnum_solicitud;
				
				-- Realizar respaldo de la trama que no tuvo respuesta basado en el sp bdiburo:sp_generarespaldoshistoricosic
				
					SELECT institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert
					INTO v_institucion,v_numcte,v_num_solicitud,v_envio3,v_envio4,v_envio5,v_status1,v_fecha_insert
						FROM bdiburo:br_traslado
							WHERE institucion = pInstitucion
							AND numcte = vnumcte
							AND num_solicitud = pnum_solicitud;
							
					INSERT INTO bdiburo:"informix".br_traslado_hist(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
						VALUES (v_institucion,v_numcte,v_num_solicitud,v_envio3,v_envio4,v_envio5,v_status1,v_fecha_insert);
						
				-------------------
				--Insertar la nueva trama con la nueva SIC
				SELECT substr(envio,1,31)||tipo_acceso_sic||substr(envio,35,6)||trim(usu_sic)||trim(pass_sic)||trim(substr(envio,59,1000)), envio1, envio2, '0', fecha_insert
				INTO v_envio,v_envio1,v_envio2,v_status,vfecha
					FROM bdiburo:br_traslado WHERE institucion = pinstitucion 
					AND num_solicitud = pnum_solicitud
					AND numcte = vnumcte;
				
				INSERT INTO bdiburo:br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
					VALUES(vNuevaSIC, vnumcte,pnum_solicitud,v_envio,v_envio1,v_envio2,v_status,vfecha);
					
				--------------------------
				--Eliminar la trama sin respuesta
				DELETE FROM bdiburo:br_traslado WHERE num_solicitud = pnum_solicitud AND institucion = pinstitucion AND numcte = vnumcte;
				
			END IF; --End validacion bandera
		
		END IF; --End validacion Canal
	END IF;	
	COMMIT WORK;
	
	RETURN scod_ret;
	
END

END PROCEDURE
