CREATE PROCEDURE "informix".sp_recalcula_estadisticafusion()
RETURNING CHAR(6);

	DEFINE iProcesados			INTEGER;
	DEFINE iFusionados			INTEGER;
	DEFINE iNo_fusionados		INTEGER;
	DEFINE iCantResultado		INTEGER;
	DEFINE iSqlErr				INTEGER;

	DEFINE cResultado			CHAR(5);
	DEFINE cRetorno				CHAR(6);
	
	DEFINE dFechaProceso 		DATE;
	
	LET iProcesados			= 0;
	LET iFusionados			= 0;
	LET iNo_fusionados		= 0;
	LET iCantResultado		= 0;	
	LET cRetorno 			= '000000';

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cRetorno = iSqlErr;
			ROLLBACK WORK;			
			RETURN cRetorno;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/sp_recalcula_estadisticafusion.out';
	--TRACE ON;
		
	BEGIN WORK;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	FOREACH 
		SELECT DISTINCT fecha_proceso
		INTO dFechaProceso
		FROM si_fusionaut
		WHERE fecha_proceso IS NOT NULL
		ORDER BY fecha_proceso ASC

		SELECT NVL(SUM(procesados),0) AS procesados, NVL(SUM(fusionados),0) AS fusionados, NVL(SUM(no_fusionados),0) AS no_fusionados
		INTO iProcesados, iFusionados, iNo_fusionados
		FROM (TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_fusionaut idx_fusfp_estatus)} 
								CASE WHEN estatus IS NOT NULL THEN NVL(COUNT(cliente_tit),0) END AS procesados,
								CASE WHEN estatus = '1' THEN NVL(COUNT(cliente_tit),0) END AS fusionados,
								CASE WHEN estatus >= '2' THEN NVL(COUNT(cliente_tit),0) END AS no_fusionados
							FROM bdinteg:si_fusionaut
							WHERE fecha_proceso = dFechaProceso::DATE
							AND canal = '1'
							AND fecha_insert = '05-13-2014'
							GROUP BY estatus)));

		IF EXISTS (SELECT fecha_proceso FROM bdinteg:si_estadistica_fusiones WHERE fecha_proceso = dFechaProceso::DATE AND tipo_fusion = '1') THEN
			UPDATE bdinteg:si_estadistica_fusiones 
			SET procesados = iProcesados, fusionados = iFusionados, no_fusionados = iNo_fusionados 
			WHERE fecha_proceso = dFechaProceso::DATE 
			AND tipo_fusion = '1';
		ELSE
			INSERT INTO bdinteg:si_estadistica_fusiones (fecha_proceso, tipo_fusion, procesados, fusionados, no_fusionados, user_proceso, user_insert, fecha_insert)
			VALUES (dFechaProceso::DATE, '1', iProcesados, iFusionados, iNo_fusionados, 'infoaut', USER, CURRENT);
		END IF;

		FOREACH 
			SELECT DISTINCT cod_retorno, COUNT(*)
			INTO cResultado, iCantResultado
			FROM bdinteg:si_fusionaut 
			WHERE fecha_proceso = dFechaProceso::DATE
			AND canal = '1'
			AND fecha_insert = '05-13-2014'
			GROUP BY cod_retorno

			IF EXISTS (SELECT fecha_proceso FROM bdinteg:si_estadistica_fusiones_det WHERE fecha_proceso = dFechaProceso AND tipo_fusion = '1' AND cod_retorno = cResultado) THEN
				UPDATE bdinteg:si_estadistica_fusiones_det 
				SET cantidad = iCantResultado
				WHERE fecha_proceso = dFechaProceso 
				AND tipo_fusion = '1' 
				AND cod_retorno = cResultado;
			ELSE
				INSERT INTO bdinteg:si_estadistica_fusiones_det (fecha_proceso, tipo_fusion, cod_retorno, cantidad, user_proceso, user_insert, fecha_insert)
				VALUES (dFechaProceso::DATE, '1', cResultado, iCantResultado, 'infoaut', USER, CURRENT);
			END IF;
		END FOREACH;
	END FOREACH;

	COMMIT WORK;
	RETURN cRetorno;
END 
END PROCEDURE;