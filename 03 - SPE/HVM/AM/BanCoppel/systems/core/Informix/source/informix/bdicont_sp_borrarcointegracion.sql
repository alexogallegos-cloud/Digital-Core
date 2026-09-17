CREATE PROCEDURE "informix".sp_borrarcointegracion(pempresa CHAR(3), p_susuario CHAR(8))
	RETURNING CHAR(6) AS retorno;

	DEFINE cod_ret		CHAR(6);
	DEFINE isam_err		INTEGER;
	DEFINE error_info	CHAR(6);
	DEFINE sql_err		INTEGER;

	--Elimina de co_integracion los registros que existan de un usuario.	
	--SET DEBUG FILE TO "/tmp/sp_borrarcointegracion.out";         	
	--TRACE ON;                                                     		

BEGIN
	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cod_ret = sql_err;
		RETURN cod_ret;
	END EXCEPTION;

	LET cod_ret = '000';

	SET LOCK MODE TO WAIT 10;

	DELETE FROM bdicont:co_integracion
	WHERE usuario_int = p_susuario;

	RETURN cod_ret;
END;
END PROCEDURE;