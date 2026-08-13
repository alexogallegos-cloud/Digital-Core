CREATE PROCEDURE "informix".sp_obtenerdatoscontacto_bei(pNumCliente VARCHAR(9))
RETURNING CHAR (5), CHAR(80), CHAR(15), INT;

	-- Creador: Manuel Ramos Figueroa
	-- Objetivo: Obtiene los datos del usuario
	-- Fecha: 04/08/2011
	
	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE cEmail CHAR(80);
	DEFINE cCel CHAR(15);
	DEFINE iCiaCel INT;
	
	LET cCod_ret = '00000';
	LET cEmail = '';
	LET cCel = '';
	LET iCiaCel = 0;
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret, cEmail, cCel, iCiaCel;
		  END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;

		--SELECT e_mail,tel_celular,cia_cel INTO cEmail, cCel, iCiaCel FROM bdibpi:"informix".bpi_usuariopm WHERE numcliente = pNumCliente AND st_portal = 'activo';
		SELECT telefono, carrier INTO cCel, iCiaCel FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = pNumCliente AND tipo_tel = '2';
		SELECT correo_elec INTO cEmail FROM bdinteg:"informix".si_correos WHERE numcte = pNumCliente AND status_correo = 'A';
		
		RETURN cCod_ret, NVL(cEmail, ''), NVL(cCel, ''), NVL(iCiaCel, 0);
	END;
END PROCEDURE;