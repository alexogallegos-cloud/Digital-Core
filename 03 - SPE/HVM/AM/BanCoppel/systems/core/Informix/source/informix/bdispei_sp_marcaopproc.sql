create procedure "informix".sp_marcaopproc(chrfolio char(12), pintEnReenvio integer)
RETURNING CHAR(5);

DEFINE vchrRegBitacora CHAR;
DEFINE codret 				CHAR(5);
DEFINE sql_err 				INTEGER;

LET codret = '000';


--    SET DEBUG FILE TO "/tmp/sp_marcaoppend.out";                                                       
--    TRACE ON;     

BEGIN
	ON EXCEPTION SET sql_err
	  IF sql_err <> 0 THEN
	     LET codret = sql_err;
	     RETURN codret;
	  END IF
	END EXCEPTION;

	{Verifica si el mensaje procesado debe ser conservado
	en bitacora para sincronizacion}
	SELECT chrregbitacora
	INTO vchrRegBitacora
	FROM tblbitacoramsj, tbltipo_mensaje
	WHERE idbitacoramsj = chrFolio
	AND tbltipo_mensaje.inttipomensaje = tblbitacoramsj.inttipomensaje;
	
	IF vchrRegBitacora = '1' THEN
		{Solo marca el registro como procesado}
		UPDATE tblbitacoramsj SET chrProcesado = '1'
   		WHERE idbitacoramsj = chrFolio;
   	ELSE
   		{Elimina el registro para no se tomado en la sincronizacion}
   		UPDATE tblbitacoramsj SET chrProcesado = '3'
   		WHERE idbitacoramsj = chrFolio;
   	END IF;

        RETURN codret;

END

end procedure;