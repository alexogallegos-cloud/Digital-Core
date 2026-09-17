CREATE PROCEDURE "informix".sp_obtenerdatosusuario(pNumCliente CHAR(9))
RETURNING  CHAR (5), CHAR(50), CHAR(11), CHAR(100), CHAR(10), CHAR(200), CHAR(1);
	-- Creador: Ismael Hernández
	-- Objetivo: Optimizar login de portal concentrando información de usuario en un solo spl
	-- Fecha: 16/08/2012
    -- Modifica: Ismael Hernandez
    --Objetivo: Modifca nombre de imagen de avatar para que convivan las versiones del portal actual y el de la reinigenieria
    --Fecha: 21/03/2013

	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vUsuario CHAR(50);
    DEFINE vIdUsuario CHAR(11);
    DEFINE vEmail VARCHAR(80);
    DEFINE vEmpresa CHAR(4);
    DEFINE vTipoCorreo SMALLINT;
    DEFINE vCorreoElec CHAR(100);
    DEFINE vStatusCorreo CHAR(1);
    DEFINE vDescAvatar CHAR(10);
	DEFINE vFrase CHAR(200);
	DEFINE vDescAvatar_ANT CHAR(1);

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				 RETURN vCod_ret, vUsuario, vIdUsuario, vCorreoElec, vDescAvatar, vFrase, vDescAvatar_ANT;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';
		LET vUsuario = '';
        LET vIdUsuario = '';
        LET vEmpresa = '001';
        LET vCorreoElec = '';
        LET vDescAvatar = '';
        LET vFrase = '';
        LET vDescAvatar_ANT = '';
        
        
        EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos( vEmpresa, pNumCliente, 1, '0')
           INTO vCod_ret, vCorreoElec, vTipoCorreo, vStatusCorreo;

        IF (TRIM(vCod_ret) = '000') THEN

            SELECT {+INDEX (bpi_usuario,inx_ncst)} TRIM(usuario), id_usuario INTO vUsuario, vIdUsuario 
            FROM bdibpi:"informix".bpi_usuario 
            WHERE numcliente = pNumCliente AND st_portal = 'activo'; 
        
            IF (NVL(vUsuario,'') <> '') THEN
                IF EXISTS ( SELECT num_cte FROM bdibpi:"informix".bpi_avatar WHERE num_cte = pNumCliente ) THEN
                    SELECT CASE WHEN LENGTH(TRIM(imagen)) = 7 THEN "a00" || substring(imagen FROM 7 FOR 1) ELSE imagen END,
                    TRIM(frase) ,CASE WHEN LENGTH(TRIM(avatar)) > 0 THEN 1 ELSE 0 END
                    --SELECT imagen, TRIM(frase) ,CASE WHEN LENGTH(TRIM(avatar)) > 0 THEN 1 ELSE 0 END
                    INTO vDescAvatar, vFrase, vDescAvatar_ANT
                    FROM bdibpi:"informix".bpi_avatar
                    WHERE num_cte = pNumCliente;		
                END IF;

                LET vCod_ret = '00000';
            ELSE
                LET vCod_ret = '100';
            END IF;  
        END IF;    

        RETURN vCod_ret, vUsuario, vIdUsuario, TRIM(vCorreoElec), vDescAvatar, vFrase, vDescAvatar_ANT;

	END;
END PROCEDURE;