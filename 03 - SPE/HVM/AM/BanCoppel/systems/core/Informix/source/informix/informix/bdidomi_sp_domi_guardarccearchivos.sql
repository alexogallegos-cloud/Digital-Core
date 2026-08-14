CREATE PROCEDURE "informix".sp_domi_guardarccearchivos(p_Usuario CHAR(8), p_NomArchivo VARCHAR(20), p_FechaPres CHAR(8), p_CveStatus CHAR(2))

RETURNING

	CHAR(5); ---cod_ret

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;

	DEFINE sDescMensajeError	VARCHAR(95);
	DEFINE iTotReg				INTEGER;
	DEFINE sFechaAplicacion		CHAR(8);


	---INICIALIZACIONES
	LET v_cod_ret = '00000';
	LET sDescMensajeError	= "";
	LET sFechaAplicacion	="";

	LET iTotReg				= 0;

BEGIN
	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;

        RETURN v_cod_ret;
    END EXCEPTION;

	---SET DEBUG FILE TO "/tmp/has/sp_Domi_GuardarCCEArchivos.out";
	---TRACE ON;

	IF p_CveStatus <> "11" THEN
		IF p_CveStatus = "02" THEN
			SELECT num_operaciones::INTEGER 
			INTO iTotReg
			FROM bdidomi: dom_cce_sumario
			WHERE nombre_arch = p_NomArchivo;
			
			SELECT  LIMIT 1 SUBSTR(fecha_aplica,5,2)||SUBSTR(fecha_aplica,7,2)||SUBSTR(fecha_aplica,1,4)
			INTO sFechaAplicacion
			FROM bdidomi: dom_cce_detalle  
			WHERE nombre_arch = p_NomArchivo;
		ELSE
			SELECT num_operaciones::INTEGER 
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
			SET cve_status = p_CveStatus, fecha_aplicacion = sFechaAplicacion, user_insert = p_Usuario, tot_registros = iTotReg
			WHERE nombre_arch = p_NomArchivo   AND fecha_presentacion = p_FechaPres;
		END IF
	END IF

	RETURN v_cod_ret;

END;

--##############################################################################
--## Procedimiento   : sp_Domi_GuardarCCEArchivos
--## Version         : 1.0
--## Creado por      : Mohamed Carreón 
--## Fecha creacion  : Agosto de 2009
--##Descripcion :  
--##############################################################################
END PROCEDURE;