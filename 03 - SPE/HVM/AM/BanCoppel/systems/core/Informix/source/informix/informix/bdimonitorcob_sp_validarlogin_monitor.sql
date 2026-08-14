CREATE PROCEDURE "informix".sp_validarlogin_monitor(pNumEmp char(9))
 returning char (5), char (22), datetime year to second;

	--Elaboró: Javier A. Chávez T.
	--Actividad: valida que el usuario y contraseña sean correctas
	--Solicito: Mauricio León
	--Fecha: 03-04-09
    ------------------------------------------------------------------------------------
	-- Modificó: Mauricio León
    --Actividad: Cambios en validaciones
    --Fecha: 12/06/2009
    ------------------------------------------------------------------------------------
	-- Modificó: Pedro Enrique Zavala Valdez
    --Actividad: Valida que solo exista el numero de empleado
    --Fecha: 15/09/2009



	--DEFINE VARIABLES
	DEFINE vFecha char (22);
	DEFINE cod_ret char(5);
        DEFINE sql_err integer;
	DEFINE vNumEmpleado char (9);
    DEFINE vNombre char(25);
	DEFINE vFechaActual datetime year to second;

	--Inicializa
	LET vFecha = '';
	LET cod_ret ='000';
	LET vNombre = '';
	LET vFechaActual = current;

 BEGIN

  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, vFecha, vFechaActual;
      END IF ;
   END EXCEPTION ;

		IF (pNumEmp <> "") THEN

            /*
				SELECT desc_nombre,(current - fecha_ult_intento)::char(22)
						INTO vNombre,vFecha
						FROM bdimonitorcob:mc_usuario
                        WHERE num_empleado = pNumEmp;

				IF (vNombre = "" OR vNombre IS NULL ) THEN
					LET cod_ret = '002';
				ELSE
					UPDATE bdimonitorcob:mc_usuario SET
					 fecha_ult_acceso = current
					 WHERE num_empleado = pNumEmp;
				END IF;
                */
                LET cod_ret = '000';
                LET vFecha = (vFechaActual)::char(22);
		ELSE
			LET cod_ret = '001';
		END IF;

		RETURN cod_ret, vFecha, vFechaActual;
 END;
END PROCEDURE;