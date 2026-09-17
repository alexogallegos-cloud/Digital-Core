CREATE PROCEDURE "informix".sps_update_avatar_y_frase_seguridad_bpi_nueva_imagen(pEmpresa CHAR(3),pIdUsuario CHAR(11), pAvatar CHAR(10),pFrase CHAR(50))
RETURNING CHAR(5);

--Declaración de variables
DEFINE cCodRet CHAR(5);
DEFINE iSql_err INTEGER;
DEFINE cNumCliente CHAR(9);

--Inicializar variables
LET cNumCliente='';
LET cCodRet='00000';

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF ;
	END EXCEPTION ;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF(pEmpresa <> '' OR pEmpresa IS NOT NULL OR pIdUsuario<>'' OR pIdUsuario IS NOT NULL) THEN

		SELECT NUMCLIENTE INTO cNumCliente FROM bdibpi:"informix".bpi_usuario WHERE ID_USUARIO = TRIM(pIdUsuario);
		
		IF (cNumCliente <> '' OR cNumCliente IS NOT NULL) THEN
			UPDATE bdibpi:"informix".bpi_avatar SET imagen = pAvatar, frase = pFrase, asig_avat_nuev_img = '1' WHERE num_cte=cNumCliente;
			LET cCodRet = '00000';		
		END IF;
		
	ELSE
		LET cCodRet='00001';
	END IF;
	
	RETURN cCodRet;

END
END PROCEDURE;