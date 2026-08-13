CREATE PROCEDURE "informix".sp_consulta_empleado_iccat(pEmpresa char (3), pNumEmp char(8))
	RETURNING char(5), char (45);

--Realizó: Javier A. Chávez Trujillo
--Fecha: 18/12/08
--Solicitó: Mauricio León
--Actividad: Retorna el nombre del empleado

--Define variables
define sql_err integer;
define cod_ret char (5);
define vNombre char(45);


--Inicializa variables
LET sql_err = '';
LET cod_ret = '000';
LET vNombre = '';


BEGIN

 ON EXCEPTION SET sql_err
          LET cod_ret = sql_err;
      RETURN  cod_ret, vNombre;
   END EXCEPTION;

   IF EXISTS(SELECT ejecutivo FROM bdinteg:si_ejecut WHERE empresa = pEmpresa AND ejecutivo = pNumEmp) THEN

			SELECT nombre INTO vNombre FROM bdinteg:si_ejecut WHERE empresa = pEmpresa AND ejecutivo = pNumEmp;

	ELSE
		LET cod_ret = '001'; -- El empleado No existe
	END IF;

	RETURN cod_ret, vNombre;

END;

END PROCEDURE;