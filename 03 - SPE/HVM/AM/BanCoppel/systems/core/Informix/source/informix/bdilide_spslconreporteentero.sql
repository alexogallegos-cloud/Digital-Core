CREATE PROCEDURE "informix".spslconreporteentero(p_dfechareporte DATE)
    --*************************************************
	--  Modificó: Anselmo Verdugo                   --*
	-- Actividad: Se recupera la cantidad enterada para la fecha dada, así como el número de operación y la fecha de operación.
    --  Solicitó: Aymme Osuna                       --*
	--     Fecha: 14/AGO/2008                       --*
    --*************************************************
    --**************************************************
        --Modificò: Aymme Osuna
        --Actividad: Se agregan validaciones para el caso que no este dado de alta el registro del entero pero que en la sl_procesos
        --este como 1
        --Solicitò: Aymme Osuna
        --Fecha: 15/AGO/2008
    --**************************************************
	RETURNING CHAR(5), CHAR(80), MONEY(16,2), CHAR(20),DATE;

	DEFINE v_scodret 			  CHAR(5);
	DEFINE v_smensaje 			  CHAR(80);
	--DEFINE v_mrecaudado			  MONEY(10,2);
	DEFINE v_mrecaudado			   MONEY(16,2);	DEFINE v_snum_operacion	      CHAR(20);

	DEFINE sql_err                INTEGER;
    DEFINE isam_err               INTEGER;
    DEFINE error_info             CHAR(40);
	DEFINE v_sstatus			  CHAR(1);
	DEFINE v_dfechahoy			  DATE;
    DEFINE v_dFechaOperacion      DATE;

	ON EXCEPTION SET sql_err, isam_err, error_info
      	LET v_scodret = sql_err;
      	LET v_smensaje = sql_err||" * "||isam_err|| " * "||error_info;
      	RETURN v_scodret, v_smensaje, v_mrecaudado, v_snum_operacion,v_dFechaOperacion;
   	END EXCEPTION;

	LET v_dfechahoy = CURRENT::DATE;
	LET v_scodret = '001';
	LET v_smensaje = 'NO SE HA GENERADO EL REPORTE';
	LET v_mrecaudado = 0;
	LET v_snum_operacion = '0';
    LET v_dFechaOperacion = '';

	--********************************************************
	-- Creado por Fabiola Corrales Tapia 15/MAY/2007 	   --*
	-- Debug del Procedure                           	   --*
 	--SET DEBUG FILE TO "/tmp/spslconreporteentero.out";  --*
 	--TRACE ON;                                           --*
	--********************************************************

	BEGIN
		SELECT status INTO v_sstatus FROM bdilide:sl_procesos WHERE proceso = 'rep_entero' AND fech_proceso = p_dfechareporte;
		IF v_sstatus <> 'NULL' THEN
			IF v_sstatus = 0 THEN

				LET v_scodret = '002';
				LET v_smensaje = 'EL PROCESO DE REPORTE ENTERO SE GENERO CON ERRORES';

			ELIF v_sstatus = 1 THEN
                                IF EXISTS (SELECT monto FROM bdilide:sl_enteros WHERE fech_entero = p_dfechareporte) THEN
                                    SELECT monto, num_operacion, fech_operacion INTO v_mrecaudado, v_snum_operacion, v_dFechaOperacion FROM bdilide:sl_enteros WHERE fech_entero = p_dfechareporte;
									LET v_mrecaudado = v_mrecaudado;
                                    LET v_scodret = '000';
                                    LET v_smensaje = 'REPORTE ENTERO GENERADO EXITOSAMENTE';
                                ELSE
                                    LET v_scodret = '003';
                                    LET v_smensaje = 'EL PROCESO DE REPORTE ENTERO SE GENERO INCOMPLETO';                                
                                END IF;
			END IF;
		END IF;
	END
	RETURN v_scodret, v_smensaje, v_mrecaudado, v_snum_operacion,nvl(v_dFechaOperacion,'01-01-1900');
END PROCEDURE
