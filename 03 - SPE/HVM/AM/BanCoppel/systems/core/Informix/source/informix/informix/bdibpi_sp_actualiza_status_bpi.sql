CREATE PROCEDURE "informix".sp_actualiza_status_bpi(pEmpresa char (3), pNumCte char(9), pStatus integer, pIpUsuario char(15), pSucursal char(4), pUsuario char(8))
	RETURNING char (5);

--Realizó: Javier A. Chávez Trujillo
--Fecha: 18/12/08
--Solicitó: Mauricio León
--Actividad: Actualiza el status y fecha de status
--Modificó: Pedro Enrique Zavala Valdez
--Fecha Modificacion: 25/11/09

--Define variables
define sql_err integer;
define cod_ret char (5);
define estatus_anterior smallint;

--Inicializa variables
LET sql_err = '';
LET cod_ret = '000';
LET estatus_anterior = 0;

BEGIN

 ON EXCEPTION SET sql_err
          LET cod_ret = sql_err;
      RETURN  cod_ret;
   END EXCEPTION;

   IF EXISTS(SELECT numcte FROM bdinteg:si_bpiusuarios WHERE numcte = pNumcte AND empresa = pEmpresa) THEN

                        --Se toma el viejo estatus
                        SELECT id_status  INTO estatus_anterior FROM bdinteg:si_bpiusuarios WHERE numcte = pNumcte AND empresa = pEmpresa;

                        INSERT INTO bdinteg:si_cambiostcte VALUES (pNumcte, estatus_anterior, pStatus, pIpUsuario, CURRENT, pSucursal, pUsuario);

                         --Se actualiza la tabla con el nuevo estatus
                        UPDATE bdinteg:si_bpiusuarios SET id_status = pStatus, f_status = CURRENT
			WHERE empresa = pEmpresa AND numcte = pNumCte;



	ELSE
		LET cod_ret = '001'; -- El cliente No existe
	END IF;

	RETURN cod_ret;

END;

END PROCEDURE;