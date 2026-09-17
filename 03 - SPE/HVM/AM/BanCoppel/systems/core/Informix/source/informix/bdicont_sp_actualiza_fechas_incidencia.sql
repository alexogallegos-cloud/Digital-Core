CREATE PROCEDURE "informix".sp_actualiza_fechas_incidencia()

RETURNING
          CHAR (5) ,
	  CHAR(20) ,
          INTEGER  ;

--##############################################################################
--## Procedimiento       : sp_actualiza_fechas_incidencia
--## Version             : 1.0.0
--## Objetivo            : Actualiza los registros que tienen fecha 2010-12-08 a 2010-08-12
--## Base Datos          : bicont
--## Supuestos           :
--## Valores Retorno     : CodRet -->   Código de Retorno.
--##                       Desc   -->   Descricpion del Error
--##                       Registros->  Cantidad de Registros
--## Creado por          : Fermin Ramos
--## Fecha creacion      : Agosto de 2010
--##############################################################################


    DEFINE cod_ret                char(5);
    DEFINE iSqlErr                integer;

    DEFINE cCodErr                CHAR(5);
    DEFINE vDesErr                VARCHAR(60);

    DEFINE cursor_actfecha        INTEGER;

    DEFINE vsecuencia	          INTEGER;

    DEFINE vsFlagEnTransaccion    CHAR (1);

    --Variables de retorno
    DEFINE v_registros            INTEGER;

    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cod_ret = iSqlErr;
        END IF;
        RETURN cod_ret, vDesErr, NULL;

    END EXCEPTION;

        --	SET debug file TO "/tmp/sp_actualiza_fechas_incidencia.out";
	--	TRACE ON;

    LET cod_ret = "000";
    LET vDesErr = "";
    LET v_registros = 0;
    --LET vnumsecuencia = 1;
    LET vsFlagEnTransaccion = 'F';

    --// ********************************************************************
    --// Obtiene Registros de la tabla bdicont:co_detpol
    --// ********************************************************************



	SET ISOLATION TO DIRTY READ;
		FOREACH WITH HOLD
-- control_poliza, fecha_captura, empresa, sucursal, naturaleza
		select {INDEX (bdicont:co_detpol 386_2288 ) } secuencia
			into vsecuencia
			from co_detpol
			where
			fecha_captura = '12082010'
			and empresa = '001'
			and control_poliza = '169075'
			and usuario = 'chqinfor'

		--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION:
		IF (vsFlagEnTransaccion = 'F') THEN
			BEGIN WORK;
				LET vsFlagEnTransaccion = 'V';
		END IF;

		UPDATE {INDEX (bdicont:co_detpol 386_2288 ) } co_detpol
		SET
			fecha_captura = '08162010',
			fecha_valida = '08122010',
			usuario = '92536921'
			where
			fecha_captura = '12082010'
			and empresa = '001'
			and control_poliza = '169075'
			and usuario = 'chqinfor'
			and secuencia = vsecuencia;

			IF (v_registros = 1000) THEN --	VERIFICA SI ALCANZO EL MAXIMO DE TRANSACCIONES POR BLOQUE.
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET v_registros = 0;
				CONTINUE FOREACH;
			END IF;
		LET v_registros = v_registros + 1;
	END FOREACH;

	-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE:
	IF ((v_registros > 0) OR (vsFlagEnTransaccion = 'V')) THEN -- VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE.
		COMMIT WORK;
		LET vsFlagEnTransaccion = 'F';
	END IF;

	RETURN cod_ret, vDesErr, v_registros;

END PROCEDURE;