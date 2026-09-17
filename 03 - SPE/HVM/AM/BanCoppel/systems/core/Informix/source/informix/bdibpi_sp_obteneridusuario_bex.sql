CREATE PROCEDURE "informix".sp_obteneridusuario_bex(pNumCel CHAR(10))
RETURNING CHAR (5), CHAR(11);

	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vIdUsuario VARCHAR(11);
	DEFINE vNumCte VARCHAR(9);
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vIdUsuario;
		  END IF ;
		END EXCEPTION ;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
		
		LET vCod_ret = '00000';
		LET vIdUsuario = '';
				
		SELECT id_usuario 
		INTO vIdUsuario 
		FROM bpi_registro_bex 
		WHERE (no_celular=pNumCel OR num_cliente=pNumCel)
		AND servicio='activo';  --Si se envia el numero de cliente
		IF NVL(vIdUsuario,'') <> '' THEN
			RETURN vCod_ret, vIdUsuario;
		ELSE
			LET vCod_ret = '00001';
			RETURN vCod_ret, vIdUsuario;
		END IF
		
	END;
END PROCEDURE;