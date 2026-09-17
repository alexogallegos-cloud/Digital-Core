CREATE PROCEDURE "informix".sp_cambiarstatus_serv_bex_mx3(pNumCel CHAR(10),pNumCte CHAR(10),pNuevoStatus SMALLINT)
	RETURNING char (5);

--Define variables
define sql_err integer;
define cod_ret char (5);
define estatus_anterior smallint;

--Inicializa variables
LET sql_err = '';
LET cod_ret = '00000';
LET estatus_anterior = 0;


--	SET DEBUG FILE TO "/informix/ireb/bdibpi/bex/sp_cambiarstatus_serv_bex.out";
--	TRACE ON;

BEGIN

 ON EXCEPTION SET sql_err
          LET cod_ret = sql_err;
      RETURN  cod_ret;
   END EXCEPTION;

   IF(NVL(pNumcte,'')='' OR NVL(pNumCel,'')='' OR NVL(pNuevoStatus,'')='') THEN
		LET cod_ret = '00002';
		RETURN cod_ret;
	END IF;
		
   IF EXISTS(SELECT id_usuario FROM bdibpi:bpi_registro_bex WHERE num_cliente = pNumcte AND no_celular = pNumCel) THEN
			IF EXISTS(SELECT id_usuario FROM bdibpi:bpi_registro_bex WHERE num_cliente = pNumcte AND no_celular = pNumCel AND estatus_servicio = 3) THEN
					
					UPDATE bdibpi:bpi_registro_bex  SET estatus_servicio = pNuevoStatus  WHERE num_cliente = pNumcte AND no_celular=pNumCel AND estatus_servicio=3;
					
					DELETE FROM bdibpi:bpi_ctl_inicio_sesion_bex WHERE num_cliente = pNumcte AND no_celular=pNumCel;
					
					LET cod_ret = '00000'; 
			END IF		
	ELSE
		LET cod_ret = '00001'; -- El cliente No existe
	END IF;

	RETURN cod_ret;

END;

END PROCEDURE;