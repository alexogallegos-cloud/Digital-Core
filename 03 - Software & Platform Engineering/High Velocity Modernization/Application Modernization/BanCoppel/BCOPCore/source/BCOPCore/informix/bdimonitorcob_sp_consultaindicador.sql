CREATE PROCEDURE "informix".sp_consultaindicador(pNum_credito    CHAR(20),
                                      pIndicador      CHAR(3))

	RETURNING
    CHAR(6),
	CHAR(211)
	--Declaracion de variables
	DEFINE v_codret 		CHAR(6);
    define v_isam_err       INTEGER;
    define v_error_info     CHAR(80);
	DEFINE v_sqlerr 		INTEGER;
    define cTrama           CHAR(211);
    define iAnio            INTEGER;
    DEFINE datesum          INTEGER;
	DEFINE iDiaActual       int;
	DEFINE iMesActual       int;
    DEFINE vcodret         CHAR(6);
    DEFINE vmensaje        CHAR(150);


	--Inicializacion de variables
	LET v_codret = "000";
	LET v_sqlerr = 0;

	LET cTrama = '';
    LET	iAnio = 0;

    LET datesum = 3;

	LET iDiaActual = DAY(current);
	LET iMesActual = MONTH(current);
    LET vcodret = '';
    LET vmensaje = '';

	--******************************************************
	--23-02-2009
	--Realizo:
	--Abraham Ayala A.
	--Consultar indicadores mensuales y/o anuales para un credito
    --Filtrados por numero de credito y tipo de indicador sugun la opcion recibida
    --cuando se reciba opcion '000' debera regresar todos los indicadores
	--******************************************************
	--------------------------------------------------------
	--16-06-2009
	--modifico:Bernardo Carlos Baez Gonzalez
    --Se adapta al esquema de BD que esta en produccion
	--------------------------------------------------------
	--08-07-2009
	--Modifico: Bernardo Carlos Báez González
	--Se aplica formato decimal a los campos de los montos anual y mensual momento de armar la trama
	--para que no se genere la trama con caracteres de "$"
	--------------------------------------------------------
	--07-06-2010
	--Modifico: Javier Humberto Calderón Zazueta
	--Se amplio la longitud de los tipos Decimal para ampliar el rango de las cifras em los montos anual y mensual
	--------------------------------------------------------


	BEGIN
	    ON EXCEPTION SET v_sqlerr, v_isam_err, v_error_info
	        IF v_sqlerr != 0 THEN
	            LET v_codret = v_sqlerr;
                LET cTrama = v_error_info;
	            RETURN v_codret, cTrama;
	        END IF;
	    END EXCEPTION;

    --SET DEBUG FILE TO '/ids10_uc9/jtrujillo/sp_consultaindicador.out';
    --TRACE ON;

		IF pNum_credito IS NULL OR pNum_credito = '' OR pIndicador IS NULL OR pIndicador = '' THEN
			LET v_codret = '999';
	        LET cTrama = "Faltan parametros";
			RETURN v_codret, cTrama;
		ELSE

            CALL bdimonitorcob:sp_calculaindicadores(pNum_credito)
            RETURNING vcodret, vmensaje;

			IF pIndicador <> '000' THEN
                IF EXISTS (SELECT {+ INDEX (bdimonitorcob:mc_conceptosmes idx_conceptosmes)} id_conceptom FROM bdimonitorcob:mc_conceptosmes WHERE id_conceptom = pIndicador) THEN

                    IF iMesActual = 1 then
                      IF iDiaActual >= 1 or iDiaActual <= 20 then
                        LET datesum = 4;
                      END IF
                    END IF

                    LET iAnio = YEAR (current) - datesum;

					FOREACH
					    SELECT {+ INDEX (bdimonitorcob:mc_detestadmes idx_detestadmes)} anio || '|' || id_conceptom || '|' || NVL(ene::DECIMAL(16,2),'') || '|' || NVL(feb::DECIMAL(16,2),'') || '|' || NVL(mar::DECIMAL(16,2),'') || '|' || NVL(abr::DECIMAL(16,2),'') || '|' ||
					                                                 NVL(may::DECIMAL(16,2),'') || '|' || NVL(jun::DECIMAL(16,2),'') || '|' || NVL(jul::DECIMAL(16,2),'') || '|' || NVL(ago::DECIMAL(16,2),'') || '|' ||
					                                                 NVL(sep::DECIMAL(16,2),'') || '|' || NVL(oct::DECIMAL(16,2),'') || '|' || NVL(nov::DECIMAL(16,2),'') || '|' || NVL(dic::DECIMAL(16,2),'') || '|'
					    INTO cTrama
                        FROM bdimonitorcob:mc_detestadmes
					    WHERE num_credito = pNum_credito
					    AND id_conceptom = pIndicador
					    AND anio > iAnio
					    ORDER BY anio DESC

					    RETURN v_codret, cTrama WITH RESUME;

					END FOREACH;
				ELSE

					FOREACH
						SELECT {+ INDEX (bdimonitorcob:mc_detestadanual idx_detestadanual)} anio || '|' || id_conceptoa || '|' || monto::DECIMAL(16,2) || '|'
						INTO cTrama
                        FROM bdimonitorcob:mc_detestadanual
						WHERE num_credito = pNum_credito
						AND id_conceptoa = pIndicador
						AND anio > iAnio
						ORDER BY anio desc

						RETURN v_codret, cTrama WITH RESUME;

					END FOREACH;

					SELECT {+ INDEX (bdimonitorcob:mc_detestadanual idx_detestadanual)} 'OTD' || '|' || pIndicador || '|' || max(monto::DECIMAL(16,2)) || '|'
					INTO cTrama
                    FROM bdimonitorcob:mc_detestadanual
					WHERE num_credito = pNum_credito
					AND id_conceptoa = pIndicador
					AND anio > iAnio;

					IF cTrama IS NULL THEN
						RETURN v_codret, '';
					END IF;

					RETURN v_codret, cTrama;

				END IF;
			ELSE

				FOREACH
					SELECT  {+ INDEX (bdimonitorcob:mc_conceptosmes idx_conceptosmes)} id_conceptom
					INTO pIndicador
                    FROM bdimonitorcob:mc_conceptosmes

					FOREACH
					    SELECT {+ INDEX (bdimonitorcob:mc_detestadmes idx_detestadmes)} anio || '|' || id_conceptom || '|' || NVL(ene::DECIMAL(16,2),'') || '|' || NVL(feb::DECIMAL(16,2),'') || '|' || NVL(mar::DECIMAL(16,2),'') || '|' || NVL(abr::DECIMAL(16,2),'') || '|' ||
					                                                 NVL(may::DECIMAL(16,2),'') || '|' || NVL(jun::DECIMAL(16,2),'') || '|' || NVL(jul::DECIMAL(16,2),'') || '|' || NVL(ago::DECIMAL(16,2),'') || '|' ||
					                                                 NVL(sep::DECIMAL(16,2),'') || '|' || NVL(oct::DECIMAL(16,2),'') || '|' || NVL(nov::DECIMAL(16,2),'') || '|' || NVL(dic::DECIMAL(16,2),'') || '|'
					    INTO cTrama
                        FROM bdimonitorcob:mc_detestadmes
					    WHERE num_credito = pNum_credito
					    AND id_conceptom = pIndicador
					    AND anio > iAnio
					    ORDER BY anio DESC

					    RETURN v_codret, cTrama WITH RESUME;

					END FOREACH;
				END FOREACH;

				FOREACH
					SELECT id_conceptoa
					INTO pIndicador
                    FROM bdimonitorcob:mc_conceptosanual

					FOREACH
						SELECT {+ INDEX (bdimonitorcob:mc_detestadanual idx_detestadanual)} anio || '|' || id_conceptoa || '|' || monto::DECIMAL(16,2) || '|'
						INTO cTrama
                        FROM bdimonitorcob:mc_detestadanual
						WHERE num_credito = pNum_credito
						AND id_conceptoa = pIndicador
						AND anio > iAnio
						ORDER BY anio desc

						RETURN v_codret, cTrama WITH RESUME;

					END FOREACH;

					SELECT {+ INDEX (bdimonitorcob:mc_detestadanual idx_detestadanual)} 'OTD' || '|' || pIndicador || '|' || max(monto::DECIMAL(16,2)) || '|'
					INTO cTrama
                    FROM bdimonitorcob:mc_detestadanual
					WHERE num_credito = pNum_credito
					AND id_conceptoa = pIndicador
					AND anio > iAnio;

					IF cTrama IS NULL THEN
						CONTINUE FOREACH;
					END IF;

					RETURN v_codret, cTrama WITH RESUME;

				END FOREACH;
			END IF;
		END IF;
    DELETE bdimonitorcob:mc_detestadmes WHERE num_credito = pNum_credito;
    DELETE bdimonitorcob:mc_detestadanual WHERE num_credito = pNum_credito;
	END;
END PROCEDURE;