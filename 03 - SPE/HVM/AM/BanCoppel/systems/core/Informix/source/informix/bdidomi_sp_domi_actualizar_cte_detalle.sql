CREATE PROCEDURE "informix".sp_domi_actualizar_cte_detalle(p_nombre_arch CHAR(20),p_fecha_presen CHAR(8))
	returning char(5);
	--ElaborÃ³: Alejandro Osuna Iza
	--Actividad: Actualiza los campos nombre_arch_cce, fecha_presetacion_cce, tipo_registro_cce y numero_secuencia_cce de la tabla dom_Cte_detalle, despues de procesar el 30
	--Solicito: Hector Casanova
	--Fecha: 13 de Agosto de 2009

	--DECLARACION DE VARIABLES GLOBALES
	DEFINE	v_cod_ret 		CHAR(5);
	DEFINE	sql_err 		INTEGER;
	DEFINE v_rfc_rec		CHAR(18);
	DEFINE v_cve_estatus	CHAR(2);
	DEFINE v_num_secuencia	CHAR(7);
	DEFINE cRef_servicio	CHAR(40);
	DEFINE cImporte			CHAR(15);

	BEGIN
		on exception set sql_err
		    if sql_err <> 0 then
				let v_cod_ret = sql_err;
				return v_cod_ret;
		    end if;
		end exception;

		--INICIALIZACION DE VARIABLES GLOBALES
		LET v_cod_ret 			= "";
		LET v_rfc_rec 			= "";
		LET v_cve_estatus 		= "";
		LET v_num_secuencia 	= "";
		LET cRef_servicio		= '';
		LET cImporte 			= '';

		---SET DEBUG FILE TO "/tmp/sp_domi_actualizar_cte_detalle.out";
	    ---TRACE ON;
		IF EXISTS(SELECT cod_operacion FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = p_nombre_arch
																AND fecha_presentacion = p_fecha_presen) THEN
			FOREACH
				SELECT rfc_rec, importe, ref_servicio, cve_estatus,num_secuencia
				INTO 	v_rfc_rec, cImporte, cRef_servicio, v_cve_estatus,v_num_secuencia
				FROM bdidomi:dom_cce_detalle_paso
				WHERE nombre_arch = p_nombre_arch
				AND fecha_presentacion = p_fecha_presen

				UPDATE bdidomi:dom_cte_detalle
				SET /*causa_rechazo = v_cve_estatus,*/
					estatus = "00", nombre_arch_cce = p_nombre_arch,
					fecha_presentacion_cce = p_fecha_presen, tipo_registro_cce = "02",
					numero_secuencia_cce = v_num_secuencia
				WHERE nombre_arch LIKE '%E%'
				AND rfc_cargo = v_rfc_rec
				AND imp_operacion = cImporte
				AND ref_servicio = cRef_servicio
				AND fecha_cargo = p_fecha_presen
				AND accion = 'A'
				AND estatus = 'EP';
				--AND nombre_arch = p_nombre_arch
				--AND fecha_envio = substr(p_fecha_presen,5,2) || "/" || substr(p_fecha_presen,7,2) || "/" || substr(p_fecha_presen,1,4);

			END FOREACH;

		ELSE
		--no existe el archivo en la de detalle
			let v_cod_ret = "02500";
			return v_cod_ret;

		END IF;
		let v_cod_ret = "00000";
		return v_cod_ret;
	END;

END PROCEDURE;