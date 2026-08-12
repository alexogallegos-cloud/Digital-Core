CREATE PROCEDURE "informix".sp_genera_ec_tdc()
--EXECUTE PROCEDURE sp_genera_ec_tdc();

RETURNING CHAR(5);

--DECLARACION
DEFINE vCodRet			CHAR(05);
DEFINE cMensaje    	 	CHAR(100); 
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr     	INTEGER;
DEFINE vMes				CHAR(02);
DEFINE vAnio			CHAR(04);
DEFINE vFecha			DATE;
DEFINE contador_ec  	INTEGER;
DEFINE numero_cre  		VARCHAR(20,1);
DEFINE fecha_emi  		DATE;
DEFINE centro_cob  		CHAR(06);
DEFINE centro_imptemp  	CHAR(06);
DEFINE centro_impanterior 	CHAR(06);
DEFINE vNumCiudadCoppel 	CHAR(06);
DEFINE vNumCiudadCoppelAnt 	CHAR(06);
DEFINE numero_reg  		INTEGER;
DEFINE contador_aux 	CHAR(06);
DEFINE vCentroDis		INTEGER;
DEFINE vNumCte			CHAR(20);

--INICIALIZACION
LET vCodRet        	= '00000';
LET cMensaje    	= 'Ejecucion Exitosa';
LET iSqlErr     	= 0;
LET iIsamErr    	= 0;
LET vMes			= '';
LET vAnio			= '';
LET vFecha			= date(1);
LET contador_ec  	= 0;
LET numero_cre 		= "";
LET fecha_emi 		= DATE(1);
LET centro_cob 		= "";	
LET centro_imptemp 	= "";
LET centro_impanterior 	= "";
LET vNumCiudadCoppel 	= "";
LET vNumCiudadCoppelAnt 	= "";
LET numero_reg 		= 0;
LET contador_aux 	= '0';
LET vCentroDis		= 0;
LET vNumCte			= '';

--SET DEBUG FILE TO "/informix/ulises/edc/tdc/generacion_ec_rt.out";
--TRACE ON; 

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
			DROP TABLE IF EXISTS tmpNumeroRegistros;
			LET vCodRet = iSqlErr;		
            LET cMensaje = 'Error en la ejecucion';
            RETURN vCodRet;
		END IF;
    END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- Recupera la fecha
	SELECT LPAD(MONTH(fecha_hoy),2,0), YEAR(fecha_hoy)
	INTO vMes, vAnio
	FROM bdicred@coppel_tcp:"informix".sd_fechas
	WHERE empresa = '001';
	
	LET vFecha = MDY(vMes,20,vAnio);
	--LET vFecha = mdy('07','20','2021'); -- para pruebas
	
	SELECT numcte,centro FROM "informix".sd_edocta_direcciones where centro is null
	into temp centros_distrib;
	
	FOREACH WITH HOLD
		SELECT numcte,centro INTO vNumCte,vCentroDis FROM centros_distrib
		
		IF vCentroDis is null THEN
		BEGIN;
			UPDATE "informix".sd_edocta_direcciones SET centro = 999999 WHERE centro is null and numcte = vNumCte;
		COMMIT;
		END IF;
	END FOREACH;

	SELECT a.num_credito, a.fecha_emision, b.numerociudadcoppel, b.centro, b.jefegrupozona, b.supervisorzona, b.numerocoloniacoppel,
			b.numerocalle, b.numeroextcalle
	FROM bdicred:"informix".sd_encabezado_edocta a
	INNER JOIN bdicred:"informix".sd_edocta_direcciones b ON b.numcte = a.numcte
	WHERE a.fecha_emision = vFecha
	INTO TEMP creditostdc_ec WITH NO LOG;
	
	CREATE INDEX creditostdc_ec_regord 
	ON creditostdc_ec(numerociudadcoppel,centro,jefegrupozona,supervisorzona,numerocoloniacoppel,numerocalle,numeroextcalle);
	UPDATE STATISTICS MEDIUM FOR TABLE creditostdc_ec;
	
	INSERT INTO creditostdc_ec
	SELECT a.num_credito, a.fecha_emision, b.numerociudadcoppel, b.centro, b.jefegrupozona, b.supervisorzona, b.numerocoloniacoppel,
		   b.numerocalle, b.numeroextcalle
	FROM "informix".sd_encabezado_edocta a
	LEFT OUTER JOIN "informix".sd_edocta_direcciones b ON b.numcte = a.numcte
	WHERE a.fecha_emision = vFecha and c.centro is not null
	and a.num_credito NOT IN(select num_credito from creditostdc_ec);
	
	select num_credito, fecha_emision, numerociudadcoppel, centro, jefegrupozona, supervisorzona, numerocoloniacoppel,
		   numerocalle, numeroextcalle
	from creditostdc_ec where num_credito NOT IN('100','000')
	group by centro, numerociudadcoppel,jefegrupozona, supervisorzona, numerocoloniacoppel,numerocalle, numeroextcalle,fecha_emision,num_credito
	INTO TEMP tmpNumeroRegistros WITH NO LOG;


	FOREACH WITH HOLD 

		SELECT num_credito, fecha_emision, centro INTO numero_cre, fecha_emi, centro_cob FROM tmpNumeroRegistros
		ORDER BY centro::INTEGER, numerociudadcoppel, jefegrupozona, supervisorzona, numerocoloniacoppel, numerocalle, numeroextcalle
		
		IF centro_cob IS NULL THEN
			LET centro_cob = 999999;
		END IF;

		/*IF (contador_aux = '0') THEN

			LET centro_imptemp = centro_cob;

		END IF;*/
		
	BEGIN;

		IF (centro_impanterior = centro_cob)THEN

			/*IF( centro_impanterior <> centro_cob) THEN

				LET contador_ec = 0;

			END IF;*/

			LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_Edocta
			SET ec_edocta = contador_ec
			WHERE num_credito = numero_cre
			AND fecha_emision = fecha_emi;

			LET contador_aux = contador_aux + 1;

		ELSE
		
			LET centro_impanterior = centro_cob;

			--LET contador_aux = '0';
			LET contador_ec = 0;
			LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_Edocta
			SET ec_edocta = NVL(contador_ec,'')
			WHERE num_credito = numero_cre
			AND fecha_emision = fecha_emi;

		END IF;
	COMMIT;
		
		--LET centro_impanterior = centro_cob;

	END FOREACH; 
	
	DROP TABLE IF EXISTS creditostdc_ec;
	DROP TABLE IF EXISTS tmpNumeroRegistros;
	DROP INDEX creditostdc_ec_regord;
	
	FOREACH WITH HOLD
		SELECT numcte,centro INTO vNumCte,vCentroDis FROM centros_distrib
		
		BEGIN;
			UPDATE "informix".sd_edocta_direcciones SET centro = NULL WHERE centro = 999999 and numcte = vNumCte;
		COMMIT;
	END FOREACH;
	
	END;

	RETURN vCodRet;

END PROCEDURE;