CREATE PROCEDURE "informix".sp_desbloquearacceso_iccat(pNumCte char(9))
	RETURNING CHAR(5);
	
--Realizó: Francisco Rodríguez Ibarra
--Fecha: 18/01/2013
--Solicitó: Walber Castro
--Actividad: Actualiza el desbloqueo temporal de 24 hrs

--Define variables
DEFINE sql_err INTEGER;
DEFINE cod_ret CHAR(5);

--Inicializa variables
LET sql_err = 0;
LET cod_ret = '00000';

--SET DEBUG FILE TO "/tmp/Manuel/sp_desbloquearacceso_iccat.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET sql_err
        LET cod_ret = sql_err;
		RETURN  cod_ret;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT;
	
	--Se actualiza la informacion del cliente en la tabla
	UPDATE bdibpi:"informix".bpi_avatar 
		SET bloqueo_temporal='F',fecha_bloqtemp=null,num_intentos_bloqtemp=0,mosaico_img=''
	WHERE num_cte=pNumCte;
	
	RETURN  cod_ret;
END;

END PROCEDURE;