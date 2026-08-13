CREATE PROCEDURE "informix".sp_clavereporte(p_tiporeporte CHAR(2),p_numcte CHAR(20),p_cve_programa CHAR(2),p_fecha_inicio DATE,p_fecha_fin DATE)
		
			RETURNING CHAR(5);
			
			DEFINE v_sCodRet CHAR(5);
			DEFINE v_sBandera CHAR (5);
			DEFINE v_sBandera2 CHAR (5);
			DEFINE v_sBandera3 CHAR (5);
			
			
			LET v_sCodRet = '';
			LET v_sBandera = '';
			LET v_sBandera2 = '';
			LET v_sBandera3 = ''; 
			
			--SET DEBUG FILE TO "/tmp/sp_ClaveReporte.out";
			--TRACE ON;
			
			BEGIN
			
				IF p_tiporeporte = '01' THEN
					IF (NVL(p_numcte,'') <> '') THEN
						LET v_sBandera = '11';
					ELSE
						LET v_sBandera = '10';
					END IF;
					IF v_sBandera = '11' THEN
						IF (NVL(p_cve_programa,'') <> '') THEN
							LET v_sBandera2 = '111';
						ELSE
							LET v_sBandera2 = '110';
						END IF;
					END IF;
					IF v_sBandera = '10' THEN
						IF (NVL(p_cve_programa,'') <> '') THEN
							LET v_sBandera2 = '101';
						ELSE
							LET v_sBandera2 = '100';
						END IF;
					END IF;
					IF v_sBandera2 = '111' THEN
						IF (NVL(p_fecha_inicio,'') <> '') AND (NVL(p_fecha_fin,'') <> '') THEN
							LET v_sBandera3 = '1111';
						ELSE
							LET v_sBandera3 = '1110';
						END IF;
					END IF;
					IF v_sBandera2 = '110' THEN
						IF (NVL(p_fecha_inicio,'') <> '') AND (NVL(p_fecha_fin,'') <> '') THEN
							LET v_sBandera3 = '1101';
						ELSE
							LET v_sBandera3 = '1100';
						END IF;
					END IF;
					IF v_sBandera2 = '100' THEN
						IF (NVL(p_fecha_inicio,'') <> '') AND (NVL(p_fecha_fin,'') <> '') THEN
							LET v_sBandera3 = '1001';
						ELSE
							LET v_sBandera3 = '1000';
						END IF;
					END IF;
					IF v_sBandera2 = '101' THEN
						IF (NVL(p_fecha_inicio,'') <> '') AND (NVL(p_fecha_fin,'') <> '') THEN
							LET v_sBandera3 = '1011';
						ELSE
							LET v_sBandera3 = '1010';
						END IF;
					END IF;
					RETURN v_sBandera3;
				END IF;
				
				IF p_tiporeporte = '02' THEN
					IF (NVL(p_numcte,'') <> '') THEN
						LET v_sBandera = '21';
					ELSE
						LET v_sBandera = '20';
					END IF;
					IF v_sBandera = '21' THEN
						IF (NVL(p_cve_programa,'') <> '') THEN
							LET v_sBandera2 = '211';
						ELSE
							LET v_sBandera2 = '210';
						END IF;
					END IF;
					IF v_sBandera = '20' THEN
						IF (NVL(p_cve_programa,'') <> '') THEN
							LET v_sBandera2 = '201';
						ELSE
							LET v_sBandera2 = '200';
						END IF;
					END IF;
					IF v_sBandera2 = '211' THEN
						IF (NVL(p_fecha_inicio,'') <> '') AND (NVL(p_fecha_fin,'') <> '') THEN
							LET v_sBandera3 = '2111';
						ELSE
							LET v_sBandera3 = '2110';
						END IF;
					END IF;
					IF v_sBandera2 = '210' THEN
						IF (NVL(p_fecha_inicio,'') <> '') AND (NVL(p_fecha_fin,'') <> '') THEN
							LET v_sBandera3 = '2101';
						ELSE
							LET v_sBandera3 = '2100';
						END IF;
					END IF;
					IF v_sBandera2 = '200' THEN
						IF (NVL(p_fecha_inicio,'') <> '') AND (NVL(p_fecha_fin,'') <> '') THEN
							LET v_sBandera3 = '2001';
						ELSE
							LET v_sBandera3 = '2000';
						END IF;
					END IF;
					IF v_sBandera2 = '201' THEN
						IF (NVL(p_fecha_inicio,'') <> '') AND (NVL(p_fecha_fin,'') <> '') THEN
							LET v_sBandera3 = '2011';
						ELSE
							LET v_sBandera3 = '2010';
						END IF;
					END IF;
					RETURN v_sBandera3;
				END IF;
				
				IF p_tiporeporte = '03' THEN
					IF (NVL(p_numcte,'') <> '') THEN
						LET v_sBandera = '31';
					ELSE
						LET v_sBandera = '30';
					END IF;
					IF v_sBandera = '31' THEN
						IF (NVL(p_cve_programa,'') <> '') THEN
							LET v_sBandera2 = '311';
						ELSE
							LET v_sBandera2 = '310';
						END IF;
					END IF;
					IF v_sBandera = '30' THEN
						IF (NVL(p_cve_programa,'') <> '') THEN
							LET v_sBandera2 = '301';
						ELSE
							LET v_sBandera2 = '300';
						END IF;
					END IF;
					IF v_sBandera2 = '311' THEN
						IF (NVL(p_fecha_inicio,'') <> '') AND (NVL(p_fecha_fin,'') <> '') THEN
							LET v_sBandera3 = '3111';
						ELSE
							LET v_sBandera3 = '3110';
						END IF;
					END IF;
					IF v_sBandera2 = '310' THEN
						IF (NVL(p_fecha_inicio,'') <> '') AND (NVL(p_fecha_fin,'') <> '') THEN
							LET v_sBandera3 = '3101';
						ELSE
							LET v_sBandera3 = '3100';
						END IF;
					END IF;
					IF v_sBandera2 = '300' THEN
						IF (NVL(p_fecha_inicio,'') <> '') AND (NVL(p_fecha_fin,'') <> '') THEN
							LET v_sBandera3 = '3001';
						ELSE
							LET v_sBandera3 = '3000';
						END IF;
					END IF;
					IF v_sBandera2 = '301' THEN
						IF (NVL(p_fecha_inicio,'') <> '') AND (NVL(p_fecha_fin,'') <> '') THEN
							LET v_sBandera3 = '3011';
						ELSE
							LET v_sBandera3 = '3010';
						END IF;
					END IF;
					RETURN v_sBandera3;
				END IF;
				
				IF p_tiporeporte = '04' THEN
					IF (NVL(p_numcte,'') <> '') THEN
						LET v_sBandera = '41';
					ELSE
						LET v_sBandera = '40';
					END IF;
					IF v_sBandera = '41' THEN
						IF (NVL(p_cve_programa,'') <> '') THEN
							LET v_sBandera2 = '411';
						ELSE
							LET v_sBandera2 = '410';
						END IF;
					END IF;
					IF v_sBandera = '40' THEN
						IF (NVL(p_cve_programa,'') <> '') THEN
							LET v_sBandera2 = '401';
						ELSE
							LET v_sBandera2 = '400';
						END IF;
					END IF;
					IF v_sBandera2 = '411' THEN
						IF (NVL(p_fecha_inicio,'') <> '') AND (NVL(p_fecha_fin,'') <> '') THEN
							LET v_sBandera3 = '4111';
						ELSE
							LET v_sBandera3 = '4110';
						END IF;
					END IF;
					IF v_sBandera2 = '410' THEN
						IF (NVL(p_fecha_inicio,'') <> '') AND (NVL(p_fecha_fin,'') <> '') THEN
							LET v_sBandera3 = '4101';
						ELSE
							LET v_sBandera3 = '4100';
						END IF;
					END IF;
					IF v_sBandera2 = '400' THEN
						IF (NVL(p_fecha_inicio,'') <> '') AND (NVL(p_fecha_fin,'') <> '') THEN
							LET v_sBandera3 = '4001';
						ELSE
							LET v_sBandera3 = '4000';
						END IF;
					END IF;
					IF v_sBandera2 = '401' THEN
						IF (NVL(p_fecha_inicio,'') <> '') AND (NVL(p_fecha_fin,'') <> '') THEN
							LET v_sBandera3 = '4011';
						ELSE
							LET v_sBandera3 = '4010';
						END IF;
					END IF;
					RETURN v_sBandera3;
				END IF;
			END;
END PROCEDURE;