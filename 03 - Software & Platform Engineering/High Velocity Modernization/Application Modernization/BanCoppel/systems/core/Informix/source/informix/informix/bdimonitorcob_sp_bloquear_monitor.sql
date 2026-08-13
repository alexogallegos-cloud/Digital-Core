CREATE PROCEDURE "informix".sp_bloquear_monitor(pNumEmp char(9))
   returning char(5);

    --Elaboró: Javier A. Chávez T.
	--Actividad: Bloquea un usuario
	--Solicito: Mauricio León
	--Fecha: 07-04-09


   --DEFINE Variables
	DEFINE sql_err integer;
	DEFINE cod_ret char(5);
	DEFINE vUsuario char(10);
	
	--Inicializa Variables
	LET cod_ret = "000";
	LET vUsuario = "";
   
 BEGIN
	  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret; 
      END IF ;
   END EXCEPTION ;		
	
	
	IF (pNumEmp = "") THEN
		
		LET cod_ret = "001";
	
	ELSE
		SELECT usuario INTO vUsuario FROM bdimonitorcob:mc_usuario WHERE num_empleado = pNumEmp;
		IF(vUsuario <> "") THEN
			UPDATE bdimonitorcob:mc_usuario SET
			fecha_ult_intento = current
			WHERE num_empleado = pNumEmp;
		ELSE
			LET cod_ret = "002";
		END IF;	
	END IF;
	
	return cod_ret;
 END;
END PROCEDURE;