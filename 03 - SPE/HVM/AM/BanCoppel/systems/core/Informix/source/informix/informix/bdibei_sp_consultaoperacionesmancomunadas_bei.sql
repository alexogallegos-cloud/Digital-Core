CREATE PROCEDURE "informix".sp_consultaoperacionesmancomunadas_bei(pNumCte CHAR(20), pIdUsuario INTEGER, pRegInical INTEGER)
RETURNING   CHAR(5) AS vCodRet, CHAR(50) AS cOperacionDesc, CHAR(150) AS cOperador,
            DATE AS dFechaOperacion,  DATE AS dFechaAplicacion,
            CHAR(20) AS cCuentaOrigen, MONEY AS mMonto,
            CHAR(1) AS cEstatusOperacion, INTEGER AS cId_operacion,INTEGER AS cIdCatOper,
			INTEGER AS iTotalReg;
--****************************************************************************************************
	-- DESCRIPCION:  CONSULTA DE OPERACIONES MANCOMUNADAS
	-- AUTOR : SOLSER
	-- FECHA : 26/06/2013
	-- BD: BDIBEI
	--***************************************************************************************************

    DEFINE vCodRet CHAR(5);
	DEFINE sql_err INT;
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


    LET vCodRet = '00000';
	LET iTotalReg = 0;
    LET cId_operacion = NULL;
    LET cIdCatOper = NULL;
    LET cOperacionDesc = NULL;
    LET cOperador = NULL;
    LET dFechaOperacion = NULL;
    LET dFechaAplicacion = NULL;
    LET cCuentaOrigen = NULL;
    LET mMonto = NULL;
    LET cEstatusOperacion = NULL;

    BEGIN


        ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
                let vCodRet = sql_err;
				RETURN vCodRet, cOperacionDesc, cOperador, dFechaOperacion, dFechaAplicacion,
                    cCuentaOrigen, mMonto, cEstatusOperacion,cId_operacion, cIdCatOper, iTotalReg;
		  END IF ;
		END EXCEPTION ;

        SET LOCK MODE TO WAIT 4;

		SELECT count(*)
		INTO  iTotalReg
		FROM (
			SELECT 1
			FROM "informix".bei_operacionesmancomunadasoperadorresumen AS resumen
				INNER JOIN "informix".bei_cat_operaciones AS cat_operaciones
								ON resumen.id_catoperacion = cat_operaciones.id_cat_oper
				INNER JOIN (SELECT id_usuario, num_cte, num_cta 
							FROM "informix".bei_mancomunidad AS mancomunidad 
							WHERE mancomunidad.id_usuario = pIdUsuario AND mancomunidad.num_cte = pNumCte AND mancomunidad.autoriza) as mancomunidad
				ON resumen.id_usuario <> mancomunidad.id_usuario and resumen.id_cliente = mancomunidad.num_cte
				AND mancomunidad.num_cta = resumen.cuenta_origen
				AND statusoperacion = 'P'
			UNION ALL
			SELECT 1
			FROM "informix".bei_operacionesmancomunadasoperadorresumen AS resumen
				INNER JOIN "informix".bei_cat_operaciones AS cat_operaciones
					ON resumen.id_catoperacion = cat_operaciones.id_cat_oper                    
			WHERE resumen.id_usuarioCambiaStatus = pIdUsuario
			AND statusoperacion <> 'P'
		) AS CONTADOR;
			
		IF(iTotalReg = 0) THEN
			LET vCodRet = '00001';
			RETURN vCodRet, cOperacionDesc, cOperador, dFechaOperacion, dFechaAplicacion,
                    cCuentaOrigen, mMonto, cEstatusOperacion,cId_operacion, cIdCatOper,iTotalReg;
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
				INNER JOIN "informix".bei_cat_operaciones AS cat_operaciones
								ON resumen.id_catoperacion = cat_operaciones.id_cat_oper
				INNER JOIN (SELECT id_usuario, num_cte, num_cta 
							FROM "informix".bei_mancomunidad AS mancomunidad 
							WHERE mancomunidad.id_usuario = pIdUsuario AND mancomunidad.num_cte = pNumCte AND mancomunidad.autoriza) as mancomunidad
				ON resumen.id_usuario <> mancomunidad.id_usuario and resumen.id_cliente = mancomunidad.num_cte
				AND mancomunidad.num_cta = resumen.cuenta_origen
				AND statusoperacion = 'P'
			UNION
			SELECT cat_operaciones.desc_oper AS OperacionDesc,
					resumen.operador  AS Operador,
					resumen.f_operacion AS FechaOperacion,
					resumen.f_aplicacion AS FechaAplicacion,
					resumen.cuenta_origen AS CuentaOrigen,
					resumen.montototal as montoTotal,        
					resumen.statusoperacion AS EstatusOperacion,
					resumen.id_operacion AS idOperacion,
                    cat_operaciones.ID_CAT_OPER AS idCatOper
			FROM "informix".bei_operacionesmancomunadasoperadorresumen AS resumen
				INNER JOIN "informix".bei_cat_operaciones AS cat_operaciones
					ON resumen.id_catoperacion = cat_operaciones.id_cat_oper                    
			WHERE resumen.id_usuarioCambiaStatus = pIdUsuario
			AND statusoperacion <> 'P'
			ORDER BY id_operacion DESC

            RETURN vCodRet, cOperacionDesc, cOperador, dFechaOperacion, dFechaAplicacion,
                    cCuentaOrigen, mMonto, cEstatusOperacion, cId_operacion, cIdCatOper, iTotalReg WITH RESUME;

        END FOREACH
    END

END PROCEDURE;