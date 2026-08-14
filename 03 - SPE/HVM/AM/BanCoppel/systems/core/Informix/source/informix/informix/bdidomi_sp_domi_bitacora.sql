CREATE PROCEDURE "informix".sp_domi_bitacora(p_TipoProceso CHAR(1), p_FechaProceso DATE, p_CveProceso VARCHAR(20), p_Descripcion CHAR(60), p_Estatus CHAR(1), p_CodRet CHAR(5), p_Usuario CHAR(8), p_NomSPLlamado VARCHAR(50), p_NomArchivo VARCHAR(20), p_FechaPres CHAR(8), p_CveStatus CHAR(2))
RETURNING
	CHAR(5); ---cod_ret
---	VARCHAR(95); ---descripcion

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;

	DEFINE sDescMensajeError	VARCHAR(100);
	DEFINE iTotReg				INTEGER;
	DEFINE vdFecha_proceso		DATE;
	DEFINE sFechaAplicacion		CHAR(8);

	---INICIALIZACIONES
	LET v_cod_ret 			= '00000';
	LET sDescMensajeError	= "";
	LET iTotReg				= 0;
	LET sFechaAplicacion	="";

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;

        RETURN v_cod_ret;
    END EXCEPTION;

	---SET DEBUG FILE TO "/tmp/has/sp_Domi_Bitacora.out";
	---TRACE ON;

	EXECUTE PROCEDURE bdidomi: sp_valida_fecha(p_FechaPres)INTO v_cod_ret;

	IF v_cod_ret = "00000" THEN
		LET vdFecha_proceso = Substr(p_FechaPres,5,2) || "/" || Substr(p_FechaPres,7,2) || "/" || Substr(p_FechaPres,1,4);
	ELSE
		LET vdFecha_proceso = CURRENT;
	END IF

	LET v_cod_ret 	= '00000';

	--- VALIDA QUE SEA UNA TIPO DE OPERACION AUTOMATICA O MANUAL
	IF UPPER(p_TipoProceso) NOT IN ("A","M") THEN
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00400") INTO v_cod_ret, sDescMensajeError;
		RETURN v_cod_ret;
	END IF


	--- VALIDA QUE CUANDO EL CODIGO DE RETORNO LO MANDE EN CEROS EL PROCESO ESTA TRABAJANDO SIN ERRORES Y REALIZA UNA NUEVA INSERCION CUANDO ES LA PRIMERA VEZ O ACTUALIZA LOS DATOS SI YA EXISTE
	IF p_CodRet = "00000" THEN
		IF NOT EXISTS (SELECT cve_proceso FROM bdidomi: dom_procesos WHERE cve_proceso = p_CveProceso AND  fecha_proceso = vdFecha_proceso) THEN
			INSERT INTO bdidomi: dom_procesos (tipo_proceso,fecha_proceso,cve_proceso,descripcion,estatus,cod_retorno,user_insert,fecha_insert)
			VALUES (UPPER(p_TipoProceso),vdFecha_proceso,p_CveProceso,p_Descripcion,p_Estatus,p_CodRet,p_Usuario,CURRENT);
		ELSE
			UPDATE bdidomi: dom_procesos
			SET descripcion = p_Descripcion, estatus = p_Estatus, cod_retorno = p_CodRet, user_insert = p_Usuario
			WHERE cve_proceso = p_CveProceso AND tipo_proceso = p_TipoProceso AND fecha_proceso = vdFecha_proceso;
		END IF
	ELSE
	--- CUANDO TRAE UN CODIGO DE RETORNO DIFERENTE DE CEROS ACTUALIZA EN LA TABLA DOM_PROCESOS E INSERTA EN LA TABLA DOM_ERRORES
		UPDATE bdidomi: dom_procesos
		SET descripcion = p_Descripcion, estatus = p_Estatus, cod_retorno = p_CodRet
		WHERE cve_proceso = p_CveProceso AND tipo_proceso = p_TipoProceso AND fecha_proceso = vdFecha_proceso;

		SELECT LIMIT 1 descripcion
		INTO sDescMensajeError
		FROM bdidomi:  dom_cat_rechazos
		WHERE cve_rechazo::INTEGER = p_CodRet::INTEGER;

		LET v_cod_ret	= p_CodRet;

		IF sDescMensajeError IS NULL THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError(p_CodRet) INTO v_cod_ret, sDescMensajeError;
		END IF

		INSERT INTO dom_errores(fecha_error,hora_error,cod_error,nombre_arch,sp_llamado,mensaje_error,user_insert,fecha_insert)
		VALUES (CURRENT,CURRENT HOUR TO FRACTION,p_CodRet,p_NomArchivo,p_NomSPLlamado,sDescMensajeError,p_Usuario,CURRENT);

	END IF

	IF p_CveStatus <> "11" THEN
		IF p_CveStatus = "02" THEN
			SELECT LIMIT 1 num_operaciones::INTEGER
			INTO iTotReg
			FROM bdidomi: dom_cce_sumario
			WHERE nombre_arch = p_NomArchivo;

			SELECT  LIMIT 1 SUBSTR(fecha_aplica,5,2)||SUBSTR(fecha_aplica,7,2)||SUBSTR(fecha_aplica,1,4)
			INTO sFechaAplicacion
			FROM bdidomi: dom_cce_detalle
			WHERE nombre_arch = p_NomArchivo;

		ELSE
			SELECT LIMIT 1 num_operaciones::INTEGER
			INTO iTotReg
			FROM bdidomi: dom_cce_sumario_paso
			WHERE nombre_arch = p_NomArchivo;

			SELECT  LIMIT 1 SUBSTR(fecha_aplica,5,2)||SUBSTR(fecha_aplica,7,2)||SUBSTR(fecha_aplica,1,4)
			INTO sFechaAplicacion
			FROM bdidomi: dom_cce_detalle_paso
			WHERE nombre_arch = p_NomArchivo;
		END IF

		IF iTotReg IS NULL THEN
			LET iTotReg = 0;
		END IF

		IF NOT EXISTS(SELECT nombre_arch FROM bdidomi: dom_cce_archivos WHERE nombre_arch = p_NomArchivo   AND fecha_presentacion = p_FechaPres) THEN
			INSERT INTO bdidomi: dom_cce_archivos(nombre_arch,fecha_presentacion,fecha_aplicacion,cve_status,tot_registros,user_insert,fecha_insert)
			VALUES (p_NomArchivo,p_FechaPres,sFechaAplicacion,p_CveStatus,iTotReg,p_Usuario,CURRENT);
		ELSE
			UPDATE bdidomi: dom_cce_archivos
			SET cve_status = p_CveStatus, fecha_aplicacion = sFechaAplicacion, user_insert = p_Usuario
			WHERE nombre_arch = p_NomArchivo   AND fecha_presentacion = p_FechaPres;
		END IF
	END IF

	RETURN v_cod_ret;

END;
--##############################################################################
--## Procedimiento   : sp_Domi_Bitacora
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Julio de 2009
--##Descripcion :  Procedimiento para insertar en la tabla dom_procesos y dom_errores para registrar el estado del proceso
--##############################################################################
END PROCEDURE;