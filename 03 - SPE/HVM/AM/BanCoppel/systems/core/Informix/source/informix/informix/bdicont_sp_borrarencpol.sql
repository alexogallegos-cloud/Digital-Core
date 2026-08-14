CREATE PROCEDURE "informix".sp_borrarencpol( pusuario CHAR(8), pcontrol_poliza INTEGER,pfecha_captura DATE, pempresa CHAR(3))
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

		--************************************************************************
        --Creado por Vladimir Félix Gálvez 25/May/2009       			       --*
		--Actividad:Eliminacion del encabezado de una poliza contable                      --*
		--Modificado por Vladimir Félix Gálvez 28/May/2009                                 --*
		--Modidicación:Se elimina para que al momento de eliminar lo                       --*
		--             lo haga directamente                                                              --*
                --Debug del Procedure                                			       --*
                --SET DEBUG FILE TO "/tmp/subir/borrarpolizadetalle.out";  --*
                --TRACE ON;                                          			       --*
		-- Modificacion:    Se cambió la firma del Sp, de borrarpolizaencabezado por     --*
		--                        sp_borrarencpol                                                            --*
		-- Modificado por: César Andrés De Anda Alcántara                                   --*
		-- Fecha:              17/06/2009
        --************************************************************************

		--VALIDAR LOS PARAMETROS DE ENTRADA
        IF pusuario = '' OR pusuario IS NULL OR pcontrol_poliza = '' OR pcontrol_poliza IS NULL
            OR pfecha_captura = '' OR pfecha_captura IS NULL OR pempresa = '' OR pempresa IS NULL THEN

			LET cCodRet = '001';
			RETURN cCodRet;

        END IF;

		DELETE FROM bdicont:co_poliza
		WHERE usuario        = pusuario
		AND   control_poliza = pcontrol_poliza
		AND   fecha_captura  = pfecha_captura
		AND   empresa        = pempresa;

		RETURN cCodRet;
	END;
END PROCEDURE;