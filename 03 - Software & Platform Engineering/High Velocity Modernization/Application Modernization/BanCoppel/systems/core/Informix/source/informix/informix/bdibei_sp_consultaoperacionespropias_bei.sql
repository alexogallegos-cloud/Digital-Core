CREATE PROCEDURE "informix".sp_consultaoperacionespropias_bei(pIdUsuario INTEGER, pRegInical INTEGER)
RETURNING   CHAR (5) AS cCod_ret, CHAR(50) AS cOperacionDesc, CHAR(150) AS cOperador,
            DATE AS dFechaOperacion,  DATE AS dFechaAplicacion,
            CHAR(20) AS cCuentaOrigen, MONEY AS mMonto,
            CHAR(1) AS cEstatusOperacion, INTEGER AS cId_operacion, INTEGER AS cIdCatOper,
            INTEGER AS iTotalReg;
--****************************************************************************************************
	-- DESCRIPCION:  COSULTA DE OPERACIONES MANCOMUNADAS
	-- AUTOR : SOLSER
	-- FECHA : 26/06/2013
	-- BD: BDIBEI
	--***************************************************************************************************

	DEFINE sql_err INT;
	DEFINE cCod_ret CHAR (5);
    DEFINE cOperacionDesc CHAR(50);
    DEFINE cOperador CHAR(150);
    DEFINE dFechaOperacion DATE;
    DEFINE dFechaAplicacion DATE;
    DEFINE cCuentaOrigen CHAR(20);
    DEFINE mMonto MONEY;
    DEFINE cEstatusOperacion CHAR(1);
	DEFINE cId_operacion INTEGER;
    DEFINE cIdCatOper INTEGER;
    DEFINE iTotalReg INTEGER;

    LET cCod_ret = '00000';
    LET iTotalReg = 0;
    LET cOperacionDesc = NULL;
    LET cOperador = NULL;
    LET dFechaOperacion = NULL;
    LET dFechaAplicacion = NULL;
    LET cCuentaOrigen = NULL;
    LET mMonto = NULL;
    LET cEstatusOperacion = NULL;
	LET cId_operacion = NULL;
    LET cIdCatOper = NULL;

    BEGIN
        ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret, cOperacionDesc, cOperador, dFechaOperacion, dFechaAplicacion,
                    cCuentaOrigen, mMonto, cEstatusOperacion,cId_operacion, cIdCatOper, iTotalReg;
		  END IF ;
		END EXCEPTION ;

        SET LOCK MODE TO WAIT 4;

        SELECT COUNT(*)
        INTO  iTotalReg
        FROM "informix".bei_operacionesmancomunadasoperadorresumen AS resumen
            INNER JOIN bei_cat_operaciones AS cat_operaciones
                ON resumen.id_catoperacion = cat_operaciones.id_cat_oper
        WHERE resumen.id_usuario = pIdUsuario;

        IF(iTotalReg = 0) THEN
			LET cCod_ret = '00001';
			RETURN cCod_ret, cOperacionDesc, cOperador, dFechaOperacion, dFechaAplicacion,
                    cCuentaOrigen, mMonto, cEstatusOperacion, cId_operacion,cIdCatOper, iTotalReg;
		END IF;
        FOREACH
            SELECT SKIP pRegInical FIRST 10 cat_operaciones.desc_oper AS OperacionDesc,
                    resumen.operador  AS Operador,
                    resumen.f_operacion AS FechaOperacion,
                    resumen.f_aplicacion AS FechaAplicacion,
                    resumen.cuenta_origen AS CuentaOrigen,
                    resumen.montototal as montoTotal,
                    resumen.statusoperacion AS EstatusOperacion,
                    resumen.id_operacion AS idOperacion,
                    cat_operaciones.ID_CAT_OPER AS idCatOper
            INTO  cOperacionDesc, cOperador, dFechaOperacion, dFechaAplicacion,
                    cCuentaOrigen, mMonto, cEstatusOperacion,cId_operacion,cIdCatOper
            FROM "informix".bei_operacionesmancomunadasoperadorresumen AS resumen
                INNER JOIN bei_cat_operaciones AS cat_operaciones
                    ON resumen.id_catoperacion = cat_operaciones.id_cat_oper
            WHERE resumen.id_usuario = pIdUsuario AND resumen.statusoperacion <> 'C'



            RETURN cCod_ret, cOperacionDesc, cOperador, dFechaOperacion, dFechaAplicacion,
                    cCuentaOrigen,NVL(mMonto,0.00), cEstatusOperacion, cId_operacion, cIdCatOper, iTotalReg  WITH RESUME;
        END FOREACH


    END

END PROCEDURE;