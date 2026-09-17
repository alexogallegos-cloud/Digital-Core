CREATE PROCEDURE "informix".sp_borrardetpol( pusuario CHAR(8), pcontrol_poliza INTEGER,
        pfecha_captura DATE, pempresa CHAR(3), pmoneda CHAR(2))
    RETURNING CHAR(6);

	-- ############################################################################
	-- #                        Definicion de Variables                           #
	-- ############################################################################

    DEFINE cCodRet      CHAR(6);
	DEFINE iSqlErr		INTEGER;

	-- ############################################################################
	-- #                        Asignacion de Variables                           #
	-- ############################################################################

	LET cCodRet     = '000';
	LET iSqlErr     = 0;

	-- ############################################################################
	-- #                    Control de Errores para INFORMIX                      #
	-- ############################################################################

	BEGIN
		ON EXCEPTION
			SET iSqlErr
            LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

        --*************************************************************************
        --Creado por Vladimir Félix Gálvez 25/May/2009       			--*
        --Debug del Procedure                                			--*
        --SET DEBUG FILE TO "/tmp/subir/borrarpolizadetalle.out";   	        --*
        --TRACE ON;                                          			--*
        --Modificaciones:                                                       --*
        --Descripcion: Se le cambió la firma al SP de "borrarpolizadetalle" a   --*
        --             "sp_borrardetpol"                                        --*
        --Modificó:    César andrés De Anda Alcántara                           --*
        --Fecha:       17/06/2009                                               --*
        --*************************************************************************

		--VALIDAR LOS PARAMETROS DE ENTRADA
        IF pusuario = '' OR pusuario IS NULL OR pcontrol_poliza = '' OR pcontrol_poliza IS NULL
            OR pfecha_captura = '' OR pfecha_captura IS NULL OR pempresa = '' OR pempresa IS NULL THEN
			LET cCodRet = '001';
		END IF;

		IF EXISTS(SELECT usuario FROM bdicont:co_detpol WHERE usuario = pusuario AND control_poliza = pcontrol_poliza
				  AND fecha_captura = pfecha_captura AND empresa = pempresa) THEN

			IF pmoneda <> '' THEN
				DELETE FROM bdicont:co_detpol
				WHERE usuario = pusuario
				AND control_poliza = pcontrol_poliza
				AND fecha_captura = pfecha_captura
				AND empresa = pempresa
				AND moneda = pmoneda;
			ELSE
				DELETE FROM bdicont:co_detpol
				WHERE usuario = pusuario
				AND control_poliza = pcontrol_poliza
				AND fecha_captura = pfecha_captura
				AND empresa = pempresa;
			END IF;
        ELSE
            LET cCodRet = '002';
        END IF;

        RETURN cCodRet;
	END;
END PROCEDURE;