CREATE PROCEDURE "informix".sp_aumento_disminucion_lincred_masivo(o_empresa CHAR(3),Pusuario CHAR(20))

RETURNING CHAR(6),CHAR(80);


    DEFINE cCodRet                  CHAR(6);
    DEFINE cMensaje                 CHAR(80);
    DEFINE sql_err                  INTEGER;
    DEFINE isam_err                 INTEGER;
    DEFINE cSql                     CHAR(1024);

    DEFINE v_num_solicitud       CHAR(20);
    DEFINE v_monto_ahora         DECIMAL(14,2);
    DEFINE v_monto_otorgado     DECIMAL(14,2);
    DEFINE iContador			INTEGER;

	DEFINE v_inicia       CHAR(20);
	DEFINE v_termina       CHAR(20);



	--SET DEBUG FILE TO "/tmp/mejora/CAMBIO_LINEA.out";
	--TRACE ON;

    LET cCodRet = "000000";
    LET cMensaje = "PROCESO EXITOSO";
    LET cSql= "";

    LET v_num_solicitud="";
    LET v_monto_ahora=0;
    LET v_monto_otorgado=0;
    LET iContador=0;

	LET v_inicia="";
	LET v_termina="";

	BEGIN

		ON EXCEPTION SET sql_err,isam_err,cMensaje
			LET cCodRet = sql_err;
			RETURN cCodRet,cMensaje;
		END EXCEPTION;
		--
		ON EXCEPTION IN (-535)
		END EXCEPTION WITH RESUME;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;


		FOREACH WITH HOLD SELECT num_solicitud,monto INTO v_num_solicitud,v_monto_ahora FROM "informix".cambio_linea WHERE num_solicitud IS NOT NULL

			IF v_monto_ahora IS NULL THEN
				CONTINUE FOREACH;
			ELSE
				LET cCodRet = "000000";

				SELECT monto_otorgado INTO v_monto_otorgado FROM "informix".sd_maesdos WHERE empresa=o_empresa AND num_credito=v_num_solicitud;

				IF v_monto_ahora <= v_monto_otorgado THEN
					BEGIN WORK;
						INSERT INTO "informix".cambio_linea_historico(empresa, num_solicitud, monto_actual, monto_deseado, descripcion, fecha_hora_mov, user_mov)
						VALUES (o_empresa, v_num_solicitud, v_monto_otorgado, v_monto_ahora, 'La linea de credito nueva es menor a la actual', CURRENT YEAR TO SECOND, Pusuario);
					COMMIT WORK;
				ELSE
					Call bdicred:sp_actualiza_lincred_central(o_empresa, v_num_solicitud, v_monto_ahora, 'A','1', Pusuario)
					Returning cCodRet,cMensaje;
				END IF;

				IF cCodRet::INTEGER = 0 THEN
					BEGIN WORK;
						DELETE FROM "informix".cambio_linea WHERE num_solicitud = v_num_solicitud;
					COMMIT WORK;
				END IF;
			END IF;

		END FOREACH;

		RETURN cCodRet,cMensaje;

	END;

END PROCEDURE;