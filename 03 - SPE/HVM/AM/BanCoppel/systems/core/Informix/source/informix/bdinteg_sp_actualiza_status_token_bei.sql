CREATE PROCEDURE "informix".sp_actualiza_status_token_bei(pEmpresa char (3), pNumCte char(9), pStatus char(3), pNSToken char(10))
	RETURNING char (5), integer;

--Realizó: Manuel Ramos Figueroa
--Fecha: 26/08/2011
--Actividad: Actualiza el status y fecha de status del token asignado al cliente
--Realizó: Jose Ruben Lopez Hernandez
--Fecha: 26/03/2013
--Actividad: Se agrego la ejecucion del sp sp_set_statustoken_admtoken

DEFINE sql_err integer;
DEFINE cCod_ret char (5);
DEFINE statusAntToken char(3);
LET sql_err = '';
LET cCod_ret = '000';

BEGIN

 ON EXCEPTION SET sql_err
          LET cCod_ret = sql_err;
      RETURN  cCod_ret, 0;
   END EXCEPTION;

	SET LOCK MODE TO WAIT 3 ;
	SET ISOLATION DIRTY READ ;
	--Se obtiene estatus viejo del token a actualizar
	SELECT id_status_token
	INTO statusAntToken
	FROM bdinteg:"informix".si_bpitokenpm WHERE num_cliente = pNumCte AND ns_token = pNSToken; 
	
	
   IF EXISTS(SELECT num_cliente FROM bdinteg:"informix".si_bpiusuariospm WHERE num_cliente = pNumcte AND empresa = pEmpresa) THEN
			EXECUTE PROCEDURE bdibpi:"informix".sp_set_statustoken_admtoken(pNSToken,statusAntToken, pStatus,'transBEI','03') 
			into cCod_ret;
			if cCod_ret<>'001' THEN
				UPDATE bdinteg:"informix".si_bpitokenpm SET id_status_token = pStatus, f_status = CURRENT 
				WHERE empresa = pEmpresa AND num_cliente = pNumCte AND ns_token = pNSToken;
			ELSE
			LET	cCod_ret='002';			END IF;
			
	ELSE
		LET cCod_ret = '001'; -- El cliente No existe
	END IF;
	
	RETURN cCod_ret, pStatus;

END;

END PROCEDURE;