CREATE PROCEDURE "informix".sp_insertarbitacora_monitor(pNumEmp integer, pCadena varchar(100), pIp char (15),pUsuario char(10))
returning char (5);

	--Realizó: Javier Alonso Chávez Trujillo.
	--Solicitó: Mauricio León.
	--Actividad: Inserta los registros en la bitacora
	--Fecha: 15/04/09
	--------------------------------------------------------
	--Modificó: Pedro Enrique Zavala Valdez
	--Actividad: Inserta los registros en la bitacora sin validar el parametro pUsuario
	--Fecha: 15/09/09
	
	--DEFINICION
	DEFINE cod_ret char (5);
	DEFINE sql_err integer;
	--INICIALIZA VARIABLES
	LET cod_ret = '000';
  
  BEGIN

  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;
   
   IF (pNumEmp <> 0 AND pCadena <> '') THEN
		INSERT INTO mc_bitacora (num_empleado,fecha_oper,cadena_enviada,ip_usuario,usuario)VALUES(pNumEmp,CURRENT,pCadena,pIp,pUsuario);
   ELSE
		LET cod_ret = '001';
   END IF;
   return cod_ret;
 END;  
END PROCEDURE;