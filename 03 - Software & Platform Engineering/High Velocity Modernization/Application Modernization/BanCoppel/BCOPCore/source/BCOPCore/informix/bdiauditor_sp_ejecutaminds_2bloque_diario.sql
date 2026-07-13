CREATE PROCEDURE "informix".sp_ejecutaminds_2bloque_diario()
RETURNING CHAR(6) AS cod_ret,
		  CHAR(80) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(80);	
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);

    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO);
		RETURN cod_ret, vmensaje;
    END EXCEPTION;
		
	EXECUTE PROCEDURE "informix".sp_mindscuenta_diario() INTO cod_ret, vmensaje;
	IF cod_ret <> '000000' THEN 
		RETURN cod_ret, vmensaje;
	END IF
	
	EXECUTE PROCEDURE "informix".sp_mindscuentasrelacionadas_diario() INTO cod_ret, vmensaje;
	IF cod_ret <> '000000' THEN 
		RETURN cod_ret, vmensaje;
	END IF

	EXECUTE PROCEDURE "informix".sp_mindsperfil_diario() INTO cod_ret, vmensaje;
	IF cod_ret <> '000000' THEN 
		RETURN cod_ret, vmensaje;
	END IF
	
	EXECUTE PROCEDURE "informix".sp_mindsbancatradicional_diario() INTO cod_ret, vmensaje;
	IF cod_ret <> '000000' THEN 
		RETURN cod_ret, vmensaje;
	END IF
	
	EXECUTE PROCEDURE "informix".sp_mindscredito_diario() INTO cod_ret, vmensaje;
	IF cod_ret <> '000000' THEN 
		RETURN cod_ret, vmensaje;
	END IF

	LET cod_ret = '00000';
    LET vmensaje = 'PROCESO EXITOSO';
	
	RETURN cod_ret, vmensaje;
	
END PROCEDURE;