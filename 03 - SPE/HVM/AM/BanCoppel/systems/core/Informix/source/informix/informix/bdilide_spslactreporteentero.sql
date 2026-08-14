CREATE PROCEDURE "informix".spslactreporteentero(p_dfechareporte DATE, p_susuario CHAR(8), p_snum_operacion CHAR(20),p_dfecha_operacion DATE)
    --*************************************************
	--  Modificó: Anselmo Verdugo                   --*
	-- Actividad: Se actualiza el campo num_operacion y fech_operacion en la tabla sl_enteros.
    --  Solicitó: Aymme Osuna                       --*
	--     Fecha: 14/AGO/2008                       --*
    --*************************************************
	RETURNING CHAR(5), CHAR(80);

	DEFINE v_scodret 			  CHAR(5);
	DEFINE v_smensaje 			  CHAR(80);

	DEFINE sql_err                INTEGER;
    DEFINE isam_err               INTEGER;
    DEFINE error_info             CHAR(40);
	DEFINE v_sstatus			  CHAR(1);
	DEFINE v_dfechahoy			  DATE;
	DEFINE v_snum_operacion		  CHAR(20);
    

	ON EXCEPTION SET sql_err, isam_err, error_info
      	LET v_scodret = sql_err;
      	LET v_smensaje = sql_err||" * "||isam_err|| " * "||error_info;
      	RETURN v_scodret, v_smensaje;
   	END EXCEPTION;

	LET v_dfechahoy = CURRENT::DATE;
	LET v_scodret = '001';
	LET v_smensaje = 'NO SE GRABO EL NUMERO DE OPERACION';

	--********************************************************
	-- Creado por Fabiola Corrales Tapia 15/MAY/2007 	   --*
	-- Modificado por Julio Polanco 03/JUN/2008            --*
    -- Modificado por Anselmo Verdugo 14/AGO/2008          --*
	-- Debug del Procedure                           	   --*
 	-- SET DEBUG FILE TO "/tmp/spslactreporteentero.out";  --*
 	-- TRACE ON;                                           --*
	--********************************************************

	BEGIN
		SELECT num_operacion INTO v_snum_operacion FROM bdilide:sl_enteros WHERE fech_entero = p_dfechareporte;
		IF v_snum_operacion = 'NULL' THEN
            UPDATE bdilide:sl_enteros SET num_operacion = p_snum_operacion, fech_operacion = p_dfecha_operacion
            WHERE fech_entero = p_dfechareporte;
            LET v_scodret = '000';
			LET v_smensaje = 'NUMERO DE OPERACION GRABADO';
		ELSE
            UPDATE bdilide:sl_enteros SET num_operacion = p_snum_operacion, fech_operacion = p_dfecha_operacion
            WHERE fech_entero = p_dfechareporte;
			LET v_scodret = '002';
			LET v_smensaje = 'NUMERO DE OPERACION ANTERIOR:'||"  "|| v_snum_operacion;
		END IF
	END
	RETURN v_scodret, v_smensaje;
END PROCEDURE;