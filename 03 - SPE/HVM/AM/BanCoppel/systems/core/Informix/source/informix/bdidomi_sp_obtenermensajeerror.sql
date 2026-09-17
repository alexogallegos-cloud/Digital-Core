CREATE PROCEDURE "informix".sp_obtenermensajeerror(p_CodError CHAR(5))
RETURNING
	CHAR(5), ---cod_ret
	VARCHAR(121); ---descripcion

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;

	DEFINE sDescripcion			VARCHAR(121);

	---INICIALIZACIONES
	LET v_cod_ret 				= '00000';
	LET sDescripcion			= "";

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;

        RETURN v_cod_ret, NULL;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	LET p_CodError = TRIM(p_CodError);

	SELECT modulo || " " ||descripcion
	INTO sDescripcion
	FROM bdidomi: dom_cat_mensajes_error
	WHERE cod_ret = p_CodError;

	IF sDescripcion IS NULL THEN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		SELECT modulo || " " ||descripcion
		INTO sDescripcion
		FROM bdidomi: dom_cat_mensajes_error
		WHERE cod_ret = "00500";
	END IF

	RETURN p_CodError, sDescripcion;

END;
--##############################################################################
--## Procedimiento   :  sp_ObtenerMensajeError
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Julio de 2009
--##Descripcion : Obtiene las descripciones de los mensajes de error
--##############################################################################
END PROCEDURE;