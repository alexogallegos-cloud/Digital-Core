CREATE PROCEDURE "informix".sp_consemp( pEmpresa char (3),pNumEmp char(8))
RETURNING char (5), char (5), char (45);

--Define variables
define sql_err integer;
define cod_ret char (5);
define cod_ret2 char (5);
define pNombre char(45);


--Inicializa variables
LET sql_err = 0;
LET cod_ret = '00000';
LET cod_ret2 = '00000';
LET pNombre = '';


BEGIN

 ON EXCEPTION SET sql_err
          LET cod_ret = sql_err;
      RETURN  cod_ret,cod_ret2,pNombre;
   END EXCEPTION;

   EXECUTE PROCEDURE sp_consulta_empleado_iccat(pEmpresa,pNumEmp)
	INTO cod_ret2, pNombre;

	RETURN cod_ret,cod_ret2,pNombre;

END;

END PROCEDURE;