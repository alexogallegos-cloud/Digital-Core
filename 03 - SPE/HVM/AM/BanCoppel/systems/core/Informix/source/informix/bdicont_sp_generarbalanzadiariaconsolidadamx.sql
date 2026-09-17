CREATE PROCEDURE "informix".sp_generarbalanzadiariaconsolidadamx(p_dFecha DATE)
RETURNING CHAR(5) AS retorno, VARCHAR(255) AS mensaje;

	DEFINE bpccmayor         		CHAR(10);
	DEFINE bpccsub           		CHAR(10);
	DEFINE bpccsubsub        		CHAR(10);
	DEFINE bpccssubsub       		CHAR(10);
	DEFINE bpccsssubsub      		CHAR(10);
	DEFINE bpsector          		CHAR(10);

	DEFINE v_mayor           		CHAR(10);
	DEFINE v_mayor1          		CHAR(1);
	DEFINE v_mayor2          		CHAR(10);
	DEFINE w_cuantos         		INTEGER;
	
	DEFINE v_len_may         		SMALLINT;
	DEFINE v_len_s           		SMALLINT;
	DEFINE v_len_ss          		SMALLINT;
	DEFINE v_len_sss         		SMALLINT;
	DEFINE v_len_ssss        		SMALLINT;
	DEFINE v_len_sect        		SMALLINT;
	DEFINE i                 		SMALLINT;

	DEFINE v_cero_may        		CHAR(10);
	DEFINE v_cero_s          		CHAR(10);
	DEFINE v_cero_ss         		CHAR(10);
	DEFINE v_cero_sss        		CHAR(10);
	DEFINE v_cero_ssss       		CHAR(10);
	DEFINE v_cero_sect       		CHAR(10);
	DEFINE v_cero_may_1      		CHAR(10);
	DEFINE v_cero_may_2      		CHAR(10);

	DEFINE v_tpc             		MONEY(16,2);
	DEFINE bpsaldo_ideudor			MONEY(32,2);
	DEFINE bpsaldo_iacreedor		MONEY(32,2);
	DEFINE bpcargos					MONEY(32,2);
	DEFINE bpabonos					MONEY(32,2);
	DEFINE bpsaldo_fdeudor			MONEY(32,2);
	DEFINE bpsaldo_facreedor		MONEY(32,2);
	DEFINE v_dFechaInsert			DATE;
	DEFINE v_dFechaMesAnt			DATE;
	DEFINE v_dFechaContable			DATE;
	DEFINE v_dFechaContableMesAnt	DATE;
	DEFINE v_nombre					CHAR(50);
	DEFINE v_cProcesoCierre			CHAR(5);

	DEFINE v_sCod_Ret       		CHAR(5);
	DEFINE v_sMensaje				VARCHAR(255);
	DEFINE cVarDataErr          	VARCHAR(255);
	DEFINE iSqlErr              	INTEGER;
	DEFINE iSamErr              	INTEGER;

	--SET DEBUG FILE TO "sp_generarbalanzadiariaconsolidadamx.out";
	--TRACE ON;

	LET bpccmayor = "";
	LET bpccsub = "";
	LET bpccsubsub = "";
	LET bpccssubsub = "";
	LET bpccsssubsub = "";
	LET bpsector = "";
	LET v_mayor = "";
	LET v_mayor1 = "";
	LET v_mayor2 = "";
	LET v_cero_may = "";
	LET v_cero_s = "";
	LET v_cero_ss = "";
	LET v_cero_sss = "";
	LET v_cero_ssss = "";
	LET v_cero_sect = "";
	LET v_cero_may_1 = "";
	LET v_cero_may_2 = "";
	LET v_nombre = "";
	LET v_cProcesoCierre = "";
	LET v_sCod_Ret = "";
	LET v_cProcesoCierre = "";

	SET LOCK MODE TO WAIT 3;
	BEGIN
		ON EXCEPTION
			SET iSqlErr, iSamErr, cVarDataErr
			IF iSqlErr <> 0 THEN
				LET v_sCod_Ret = iSqlErr;
				LET v_sMensaje = cVarDataErr;
				RETURN v_sCod_Ret, v_sMensaje;
			END IF;
		END EXCEPTION;

	--ELIMINA LOS REGISTROS DE LA FECHA PARA VOLVERLOS A GENERAR
	DELETE FROM bdicont:"informix".bi_balanza_dme
	WHERE fecha_balanza = p_dFecha;

	--OBTIENE LA FECHA AL DIA DE HOY
	SELECT fecha_hoy INTO v_dFechaInsert FROM bdinteg:"informix".si_fechas;

	--OBTIENE LA FECHA CONTABLE
	SELECT fecha_hoy INTO v_dFechaContable FROM bdicont:"informix".co_fechas;
	
	--VALIDA QUE LA FECHA PROCESO SEA MENOR O IGUAL A LA FECHA CONTABLE
	IF(p_dFecha <= v_dFechaContable) THEN

		SELECT codigo_retorno INTO v_cProcesoCierre 
		FROM bdicont:"informix".co_cierre_cif 
		WHERE UPPER(descripcion_cierre) = "CIERRE"
		AND cierre_fecha >= p_dFecha;
		
		--PRECIO CONTABLE PARA LA MONEDA
		SELECT NVL(preciocontable,0)::MONEY(16,2) INTO v_tpc
		FROM bdirepaut:"informix".sp_preciocontable
		WHERE moneda = "02" AND fecha = p_dFecha;

		IF v_tpc IS NULL THEN
			LET v_tpc = 0;
		END IF

		IF(v_cProcesoCierre IS NOT NULL) THEN
			--CIERRE EXITOSO
			IF(v_cProcesoCierre == "000") THEN
				--MISMO MES
				IF(YEAR(p_dFecha) = YEAR(v_dFechaContable) AND MONTH(p_dFecha) = MONTH(v_dFechaContable)) THEN
					--SALDOS DIARIOS(co_sdodias)
					INSERT INTO bdicont:"informix".bi_balanza_dme (fecha_insert, fecha_balanza, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, tipo_cta, descripcion,
					saldo_ideudor, saldo_iacreedor, cargos, abonos, saldo_fdeudor, saldo_facreedor)
					SELECT v_dFechaInsert, p_dFecha, a.ccmayor, a.ccsub, a.ccsubsub, a.ccssubsub, a.ccsssubsub, a.sector, "D", b.nombre,
					(SUM(CASE WHEN b.naturaleza_cta = "D" THEN a.saldo_inicio_dia ELSE 0 END) * v_tpc)::MONEY(32,2), 
					(SUM(CASE WHEN b.naturaleza_cta = "A" THEN a.saldo_inicio_dia ELSE 0 END) * v_tpc)::MONEY(32,2),
					(SUM(a.cargos_dia) * v_tpc)::MONEY(32,2), (SUM(a.abonos_dia) * v_tpc)::MONEY(32,2),
					(SUM(CASE WHEN b.naturaleza_cta = "D" THEN a.saldo_fin_de_dia ELSE 0 END) * v_tpc)::MONEY(32,2),
					(SUM(CASE WHEN b.naturaleza_cta = "A" THEN a.saldo_fin_de_dia ELSE 0 END) * v_tpc)::MONEY(32,2)
					FROM bdicont:"informix".co_sdodias a, bdinteg:"informix".si_catalog b
					WHERE a.empresa = b.empresa
					AND a.empresa = "001"
					AND a.ccmayor = b.ccmayor
					AND a.ccsub = b.ccsub
					AND a.ccsubsub = b.ccsubsub
					AND a.ccssubsub = b.ccssubsub
					AND a.ccsssubsub = b.ccsssubsub
					AND a.sector = b.sector
					AND a.moneda = "02"
					AND a.mes_dia = p_dFecha
					GROUP BY 1,2,3,4,5,6,7,8,9,10;
				--HISTORICA SALDOS DIARIOS(co_histsdodias)
				ELSE
					INSERT INTO bdicont:"informix".bi_balanza_dme (fecha_insert, fecha_balanza, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, tipo_cta, descripcion,
					saldo_ideudor, saldo_iacreedor, cargos, abonos, saldo_fdeudor, saldo_facreedor)
					SELECT v_dFechaInsert, p_dFecha, a.ccmayor, a.ccsub, a.ccsubsub, a.ccssubsub, a.ccsssubsub, a.sector, "D", b.nombre,
					(SUM(CASE WHEN b.naturaleza_cta == "D" THEN a.saldo_inicio_dia ELSE 0 END) * v_tpc)::MONEY(32,2), 
					(SUM(CASE WHEN b.naturaleza_cta == "A" THEN a.saldo_inicio_dia ELSE 0 END) * v_tpc)::MONEY(32,2),
					(SUM(cargos_dia) * v_tpc)::MONEY(32,2), (SUM(abonos_dia) * v_tpc)::MONEY(32,2),
					(SUM(CASE WHEN b.naturaleza_cta == "D" THEN a.saldo_fin_de_dia ELSE 0 END) * v_tpc)::MONEY(32,2),
					(SUM(CASE WHEN b.naturaleza_cta == "A" THEN a.saldo_fin_de_dia ELSE 0 END) * v_tpc)::MONEY(32,2)
					FROM bdicont:"informix".co_histsdodias a, bdinteg:"informix".si_catalog b
					WHERE a.empresa = b.empresa
					AND a.empresa = "001"
					AND a.ccmayor = b.ccmayor
					AND a.ccsub = b.ccsub
					AND a.ccsubsub = b.ccsubsub
					AND a.ccssubsub = b.ccssubsub
					AND a.ccsssubsub = b.ccsssubsub
					AND a.sector = b.sector
					AND a.moneda = "02"
					AND a.mes_dia = p_dFecha
					GROUP BY 1,2,3,4,5,6,7,8,9,10;
				END IF;

				SELECT len_may,   len_s,   len_ss,   len_sss,   len_ssss,   len_sect
				INTO   v_len_may, v_len_s, v_len_ss, v_len_sss, v_len_ssss, v_len_sect
				FROM   bdicont:"informix".co_param
				WHERE  empresa = "001";

				FOR i = 1 TO v_len_may
				   LET v_cero_may   = TRIM(v_cero_may) || "0";
				END FOR;

				FOR i = 1 TO v_len_s
				   LET v_cero_s     = TRIM(v_cero_s) || "0";
				END FOR;

				FOR i = 1 TO v_len_ss
				   LET v_cero_ss    = TRIM(v_cero_ss) || "0";
				END FOR;

				FOR i = 1 TO v_len_sss
				   LET v_cero_sss   = TRIM(v_cero_sss) || "0";
				END FOR;

				FOR i = 1 TO v_len_ssss
				   LET v_cero_ssss  = TRIM(v_cero_ssss) || "0";
				END FOR;

				FOR i = 1 TO v_len_sect
				   LET v_cero_sect  = TRIM(v_cero_sect) || "0";
				END FOR;

				FOR i = 2 TO v_len_may
				   LET v_cero_may_1 = TRIM(v_cero_may_1) || "0";
				END FOR;

				FOR i = 3 TO v_len_may
				   LET v_cero_may_2 = TRIM(v_cero_may_2) || "0";
				END FOR;

				FOREACH
					SELECT 	ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector
					INTO 	bpccmayor, bpccsub, bpccsubsub, bpccssubsub, bpccsssubsub, bpsector
					FROM 	bdicont:"informix".bi_balanza_dme
					WHERE 	ccmayor    IS NOT NULL
					AND 	ccsub      IS NOT NULL
					AND 	ccsubsub   IS NOT NULL
					AND 	ccssubsub  IS NOT NULL
					AND 	ccsssubsub IS NOT NULL
					AND 	sector     IS NOT NULL
					AND 	tipo_cta   IS NOT NULL
					AND 	fecha_balanza = p_dFecha
					AND (saldo_ideudor <> 0 OR saldo_iacreedor <> 0 OR cargos <> 0 OR abonos <> 0 OR saldo_fdeudor <> 0 OR saldo_facreedor <> 0)
					ORDER BY ccmayor DESC, ccsub DESC, ccsubsub DESC,ccssubsub DESC, ccsssubsub DESC, sector DESC, fecha_balanza

					-- ENCABEZADO PRIMER NIVEL
					LET v_mayor = bpccmayor[1,1]||TRIM(v_cero_may_1);
					LET v_mayor1 = bpccmayor[1,1];

					SELECT COUNT(*) INTO w_cuantos FROM bdicont:"informix".bi_balanza_dme WHERE ccmayor = v_mayor AND ccsub = v_cero_s AND ccsubsub = v_cero_ss
					AND ccssubsub = v_cero_sss AND ccsssubsub = v_cero_ssss AND sector = v_cero_sect AND fecha_balanza = p_dFecha AND tipo_cta = "T";

					IF w_cuantos = 0 THEN
						INSERT INTO bdicont:"informix".bi_balanza_dme (fecha_insert, fecha_balanza, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, tipo_cta, descripcion,
						saldo_ideudor, saldo_iacreedor, cargos, abonos, saldo_fdeudor, saldo_facreedor)
						SELECT v_dFechaInsert, p_dFecha, v_mayor, v_cero_s, v_cero_ss, v_cero_sss, v_cero_ssss, v_cero_sect,"T", "",
						NVL(SUM(saldo_ideudor),0), NVL(SUM(saldo_iacreedor),0), NVL(SUM(cargos),0), NVL(SUM(abonos),0), NVL(SUM(saldo_fdeudor),0), NVL(SUM(saldo_facreedor),0)
						FROM bdicont:"informix".bi_balanza_dme
						WHERE ccmayor[1,1] = v_mayor1
						AND ccsub        IS NOT NULL
						AND ccsubsub     IS NOT NULL
						AND ccssubsub    IS NOT NULL
						AND ccsssubsub   IS NOT NULL
						AND sector       IS NOT NULL
						AND fecha_balanza = p_dFecha
						AND tipo_cta     = "D";
					END IF
			   
					-- ENCABEZADO SEGUNDO NIVEL
					LET v_mayor = bpccmayor[1,2]||TRIM(v_cero_may_2);
					LET v_mayor2 = bpccmayor[1,2];
				   
					SELECT COUNT(*) INTO w_cuantos FROM bdicont:"informix".bi_balanza_dme WHERE ccmayor = v_mayor AND ccsub = v_cero_s AND ccsubsub = v_cero_ss
					AND ccssubsub = v_cero_sss AND ccsssubsub = v_cero_ssss AND sector = v_cero_sect AND fecha_balanza = p_dFecha AND tipo_cta = "T";

					IF w_cuantos = 0 THEN
						INSERT INTO bdicont:"informix".bi_balanza_dme (fecha_insert, fecha_balanza, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, tipo_cta, descripcion,
						saldo_ideudor, saldo_iacreedor, cargos, abonos, saldo_fdeudor, saldo_facreedor)
						SELECT v_dFechaInsert, p_dFecha, v_mayor, v_cero_s, v_cero_ss, v_cero_sss, v_cero_ssss, v_cero_sect,"T", "",
						NVL(SUM(saldo_ideudor),0), NVL(SUM(saldo_iacreedor),0), NVL(SUM(cargos),0), NVL(SUM(abonos),0), NVL(SUM(saldo_fdeudor),0), NVL(SUM(saldo_facreedor),0)
						FROM bdicont:"informix".bi_balanza_dme
						WHERE ccmayor[1,2] = v_mayor2
						AND  ccsub        IS NOT NULL
						AND  ccsubsub     IS NOT NULL
						AND  ccssubsub    IS NOT NULL
						AND  ccsssubsub   IS NOT NULL
						AND  sector       IS NOT NULL
						AND  fecha_balanza = p_dFecha
						AND  tipo_cta     = "D";
					END IF

					-- DETERMINA SI SE TRATA DE UNA CUENTA TOTALIZADORA
					-- CUARTO NIVEL
					IF bpccmayor > v_cero_may AND bpccsub > v_cero_s AND bpccsubsub > v_cero_ss AND bpccssubsub > v_cero_sss AND bpccsssubsub > v_cero_ssss THEN
						-- SECTOR CERO CUARTO NIVEL
						SELECT COUNT(*) INTO w_cuantos FROM bdicont:"informix".bi_balanza_dme WHERE ccmayor = bpccmayor AND ccsub = bpccsub AND ccsubsub = bpccsubsub
						AND ccssubsub = bpccssubsub AND ccsssubsub = bpccsssubsub AND sector = v_cero_sect AND tipo_cta IS NOT NULL AND fecha_balanza = p_dFecha;

						IF w_cuantos = 0 THEN
							INSERT INTO bdicont:"informix".bi_balanza_dme (fecha_insert, fecha_balanza, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, tipo_cta, descripcion,
							saldo_ideudor, saldo_iacreedor, cargos, abonos, saldo_fdeudor, saldo_facreedor)
							SELECT v_dFechaInsert, p_dFecha, bpccmayor, bpccsub, bpccsubsub, bpccssubsub, bpccsssubsub, v_cero_sect, "T", "",
							NVL(SUM(saldo_ideudor),0), NVL(SUM(saldo_iacreedor),0), NVL(SUM(cargos),0), NVL(SUM(abonos),0), NVL(SUM(saldo_fdeudor),0), NVL(SUM(saldo_facreedor),0)
							FROM bdicont:"informix".bi_balanza_dme
							WHERE ccmayor = bpccmayor AND
							ccsub       = bpccsub AND
							ccsubsub    = bpccsubsub AND
							ccssubsub   = bpccssubsub AND
							ccsssubsub  = bpccsssubsub AND
							sector      IS NOT NULL AND
							fecha_balanza = p_dFecha AND
							tipo_cta    = "D";
						END IF

						-- SECTOR CERO TERCER NIVEL
						SELECT COUNT(*) INTO w_cuantos FROM bdicont:"informix".bi_balanza_dme WHERE ccmayor = bpccmayor AND ccsub = bpccsub AND ccsubsub = bpccsubsub
						AND ccssubsub = bpccssubsub AND ccsssubsub = v_cero_ssss AND sector = v_cero_sect AND tipo_cta IS NOT NULL AND fecha_balanza = p_dFecha;

						IF w_cuantos = 0 THEN
							INSERT INTO bdicont:"informix".bi_balanza_dme (fecha_insert, fecha_balanza, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, tipo_cta, descripcion,
							saldo_ideudor, saldo_iacreedor, cargos, abonos, saldo_fdeudor, saldo_facreedor)
							SELECT v_dFechaInsert, p_dFecha, bpccmayor, bpccsub, bpccsubsub, bpccssubsub, v_cero_ssss, v_cero_sect, "T", "",
							NVL(SUM(saldo_ideudor),0), NVL(SUM(saldo_iacreedor),0), NVL(SUM(cargos),0), NVL(SUM(abonos),0), NVL(SUM(saldo_fdeudor),0), NVL(SUM(saldo_facreedor),0)
							FROM bdicont:"informix".bi_balanza_dme
							WHERE ccmayor = bpccmayor AND
							ccsub      = bpccsub AND
							ccsubsub   = bpccsubsub AND
							ccssubsub  = bpccssubsub AND
							ccsssubsub IS NOT NULL AND
							sector     IS NOT NULL AND
							fecha_balanza = p_dFecha AND
							tipo_cta   = "D";
						END IF

						-- SECTOR CERO SEGUNDO NIVEL
						SELECT COUNT(*) INTO w_cuantos FROM bdicont:"informix".bi_balanza_dme WHERE ccmayor = bpccmayor AND ccsub = bpccsub AND ccsubsub = bpccsubsub
						AND ccssubsub = v_cero_sss AND ccsssubsub = v_cero_ssss AND sector = v_cero_sect AND tipo_cta IS NOT NULL AND fecha_balanza = p_dFecha;

						IF w_cuantos = 0 THEN
							INSERT INTO bdicont:"informix".bi_balanza_dme (fecha_insert, fecha_balanza, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, tipo_cta, descripcion,
							saldo_ideudor, saldo_iacreedor, cargos, abonos, saldo_fdeudor, saldo_facreedor)
							SELECT v_dFechaInsert, p_dFecha, bpccmayor, bpccsub, bpccsubsub, v_cero_sss, v_cero_ssss, v_cero_sect, "T", "",
							NVL(SUM(saldo_ideudor),0), NVL(SUM(saldo_iacreedor),0), NVL(SUM(cargos),0), NVL(SUM(abonos),0), NVL(SUM(saldo_fdeudor),0), NVL(SUM(saldo_facreedor),0)
							FROM bdicont:"informix".bi_balanza_dme
							WHERE ccmayor  = bpccmayor AND
							ccsub    = bpccsub AND
							ccsubsub = bpccsubsub AND
							ccssubsub  IS NOT NULL AND
							ccsssubsub IS NOT NULL AND
							sector     IS NOT NULL AND 
							fecha_balanza  = p_dFecha AND
							tipo_cta = "D";
						END IF

						-- SECTOR CERO PRIMER NIVEL
						SELECT COUNT(*) INTO w_cuantos FROM bdicont:"informix".bi_balanza_dme WHERE ccmayor = bpccmayor AND ccsub = bpccsub AND ccsubsub = v_cero_ss
						AND ccssubsub = v_cero_sss AND ccsssubsub = v_cero_ssss AND sector = v_cero_sect AND tipo_cta IS NOT NULL AND fecha_balanza = p_dFecha;

						IF w_cuantos = 0 THEN
							INSERT INTO bdicont:"informix".bi_balanza_dme (fecha_insert, fecha_balanza, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, tipo_cta, descripcion,
							saldo_ideudor, saldo_iacreedor, cargos, abonos, saldo_fdeudor, saldo_facreedor)
							SELECT v_dFechaInsert, p_dFecha, bpccmayor, bpccsub, v_cero_ss, v_cero_sss, v_cero_ssss, v_cero_sect, "T", "",
							NVL(SUM(saldo_ideudor),0), NVL(SUM(saldo_iacreedor),0), NVL(SUM(cargos),0), NVL(SUM(abonos),0), NVL(SUM(saldo_fdeudor),0), NVL(SUM(saldo_facreedor),0)
							FROM bdicont:"informix".bi_balanza_dme
							WHERE ccmayor  = bpccmayor AND
							ccsub    = bpccsub AND
							ccsubsub   IS NOT NULL AND
							ccssubsub  IS NOT NULL AND
							ccsssubsub IS NOT NULL AND
							sector     IS NOT NULL AND
							fecha_balanza  = p_dFecha AND
							tipo_cta = "D";
						END IF

						-- SECTOR CERO NIVEL MAYOR
						SELECT COUNT(*) INTO w_cuantos FROM bdicont:"informix".bi_balanza_dme WHERE ccmayor = bpccmayor AND ccsub = v_cero_s AND ccsubsub = v_cero_ss
						AND ccssubsub = v_cero_sss AND ccsssubsub = v_cero_ssss AND sector = v_cero_sect AND tipo_cta IS NOT NULL AND fecha_balanza = p_dFecha;

						IF w_cuantos = 0 THEN
							INSERT INTO bdicont:"informix".bi_balanza_dme (fecha_insert, fecha_balanza, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, tipo_cta, descripcion,
							saldo_ideudor, saldo_iacreedor, cargos, abonos, saldo_fdeudor, saldo_facreedor)
							SELECT v_dFechaInsert, p_dFecha, bpccmayor, v_cero_s, v_cero_ss, v_cero_sss, v_cero_ssss, v_cero_sect, "T", "",
							NVL(SUM(saldo_ideudor),0), NVL(SUM(saldo_iacreedor),0), NVL(SUM(cargos),0), NVL(SUM(abonos),0), NVL(SUM(saldo_fdeudor),0), NVL(SUM(saldo_facreedor),0)
							FROM bdicont:"informix".bi_balanza_dme
							WHERE ccmayor = bpccmayor AND
							ccsub      IS NOT NULL AND
							ccsubsub   IS NOT NULL AND
							ccssubsub  IS NOT NULL AND
							ccsssubsub IS NOT NULL AND
							sector     IS NOT NULL AND
							fecha_balanza = p_dFecha AND
							tipo_cta   = "D";
						END IF
					END IF

					-- DETERMINA SI SE TRATA DE UNA CUENTA TOTALIZADORA
					-- TERCER NIVEL
					IF bpccmayor > v_cero_may AND bpccsub > v_cero_s AND bpccsubsub > v_cero_ss AND bpccssubsub > v_cero_sss AND bpccsssubsub = v_cero_ssss THEN
						-- SECTOR CERO TERCER NIVEL
						SELECT COUNT(*) INTO w_cuantos FROM bdicont:"informix".bi_balanza_dme WHERE ccmayor = bpccmayor AND ccsub = bpccsub AND ccsubsub = bpccsubsub
						AND ccssubsub = bpccssubsub AND ccsssubsub = v_cero_ssss AND sector = v_cero_sect AND tipo_cta IS NOT NULL AND fecha_balanza = p_dFecha ;

						IF w_cuantos = 0 THEN
							INSERT INTO bdicont:"informix".bi_balanza_dme (fecha_insert, fecha_balanza, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, tipo_cta, descripcion,
							saldo_ideudor, saldo_iacreedor, cargos, abonos, saldo_fdeudor, saldo_facreedor)
							SELECT v_dFechaInsert, p_dFecha, bpccmayor, bpccsub, bpccsubsub, bpccssubsub, v_cero_ssss, v_cero_sect,"T", "",
							NVL(SUM(saldo_ideudor),0), NVL(SUM(saldo_iacreedor),0), NVL(SUM(cargos),0), NVL(SUM(abonos),0), NVL(SUM(saldo_fdeudor),0), NVL(SUM(saldo_facreedor),0)
							FROM bdicont:"informix".bi_balanza_dme
							WHERE ccmayor = bpccmayor AND
							ccsub     = bpccsub AND
							ccsubsub  = bpccsubsub AND
							ccssubsub = bpccssubsub AND
							ccsssubsub IS NOT NULL AND 
							sector     IS NOT NULL AND
							fecha_balanza = p_dFecha AND 
							tipo_cta  = "D";
						END IF

						-- SECTOR CERO SEGUNDO NIVEL
						SELECT COUNT(*) INTO w_cuantos FROM bdicont:"informix".bi_balanza_dme WHERE ccmayor = bpccmayor AND ccsub = bpccsub AND ccsubsub = bpccsubsub
						AND ccssubsub = v_cero_sss AND ccsssubsub = v_cero_ssss AND sector = v_cero_sect AND tipo_cta IS NOT NULL AND fecha_balanza = p_dFecha;

						IF w_cuantos = 0 THEN
							INSERT INTO bdicont:"informix".bi_balanza_dme (fecha_insert, fecha_balanza, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, tipo_cta, descripcion,
							saldo_ideudor, saldo_iacreedor, cargos, abonos, saldo_fdeudor, saldo_facreedor)
							SELECT v_dFechaInsert, p_dFecha, bpccmayor, bpccsub, bpccsubsub, v_cero_sss, v_cero_ssss, v_cero_sect,"T", "",
							NVL(SUM(saldo_ideudor),0), NVL(SUM(saldo_iacreedor),0), NVL(SUM(cargos),0), NVL(SUM(abonos),0), NVL(SUM(saldo_fdeudor),0), NVL(SUM(saldo_facreedor),0)
							FROM bdicont:"informix".bi_balanza_dme
							WHERE ccmayor = bpccmayor AND
							ccsub      = bpccsub AND
							ccsubsub   = bpccsubsub AND
							ccssubsub  IS NOT NULL AND
							ccsssubsub IS NOT NULL AND
							sector     IS NOT NULL AND
							fecha_balanza = p_dFecha AND
							tipo_cta   = "D";
						END IF

						-- SECTOR CERO PRIMER NIVEL
						SELECT COUNT(*) INTO w_cuantos FROM bdicont:"informix".bi_balanza_dme WHERE ccmayor = bpccmayor AND ccsub = bpccsub AND ccsubsub = v_cero_ss
						AND ccssubsub = v_cero_sss AND ccsssubsub = v_cero_ssss AND sector = v_cero_sect AND tipo_cta IS NOT NULL AND fecha_balanza = p_dFecha;

						IF w_cuantos = 0 THEN
							INSERT INTO bdicont:"informix".bi_balanza_dme (fecha_insert, fecha_balanza, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, tipo_cta, descripcion,
							saldo_ideudor, saldo_iacreedor, cargos, abonos, saldo_fdeudor, saldo_facreedor)
							SELECT v_dFechaInsert, p_dFecha, bpccmayor, bpccsub, v_cero_ss, v_cero_sss, v_cero_ssss, v_cero_sect,"T", "",
							NVL(SUM(saldo_ideudor),0), NVL(SUM(saldo_iacreedor),0), NVL(SUM(cargos),0), NVL(SUM(abonos),0), NVL(SUM(saldo_fdeudor),0), NVL(SUM(saldo_facreedor),0)
							FROM bdicont:"informix".bi_balanza_dme
							WHERE ccmayor  = bpccmayor AND
							ccsub    = bpccsub AND
							ccsubsub   IS NOT NULL AND 
							ccssubsub  IS NOT NULL AND
							ccsssubsub IS NOT NULL AND
							sector     IS NOT NULL AND
							fecha_balanza = p_dFecha AND
							tipo_cta = "D";
						END IF

						-- SECTOR CERO NIVEL MAYOR
						SELECT COUNT(*) INTO w_cuantos FROM bdicont:"informix".bi_balanza_dme WHERE ccmayor = bpccmayor AND ccsub = v_cero_s AND ccsubsub = v_cero_ss
						AND ccssubsub = v_cero_sss AND ccsssubsub = v_cero_ssss AND sector = v_cero_sect AND tipo_cta IS NOT NULL AND fecha_balanza = p_dFecha;

						IF w_cuantos = 0 THEN
							INSERT INTO bdicont:"informix".bi_balanza_dme (fecha_insert, fecha_balanza, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, tipo_cta, descripcion,
							saldo_ideudor, saldo_iacreedor, cargos, abonos, saldo_fdeudor, saldo_facreedor)
							SELECT v_dFechaInsert, p_dFecha, bpccmayor, v_cero_s, v_cero_ss, v_cero_sss, v_cero_ssss, v_cero_sect,"T", "",
							NVL(SUM(saldo_ideudor),0), NVL(SUM(saldo_iacreedor),0), NVL(SUM(cargos),0), NVL(SUM(abonos),0), NVL(SUM(saldo_fdeudor),0), NVL(SUM(saldo_facreedor),0)
							FROM bdicont:"informix".bi_balanza_dme
							WHERE ccmayor = bpccmayor AND
							ccsub      IS NOT NULL AND
							ccsubsub   IS NOT NULL AND
							ccssubsub  IS NOT NULL AND
							ccsssubsub IS NOT NULL AND
							sector     IS NOT NULL AND
							fecha_balanza = p_dFecha AND
							tipo_cta   = "D";
						END IF
					END IF
					-- DETERMINA SI SE TRATA DE UNA CUENTA TOTALIZADORA
					-- SEGUNDO NIVEL
					IF bpccmayor > v_cero_may AND bpccsub > v_cero_s AND bpccsubsub > v_cero_ss AND bpccssubsub = v_cero_sss AND bpccsssubsub = v_cero_ssss THEN
						-- SECTOR CERO SEGUNDO NIVEL
						SELECT COUNT(*) INTO w_cuantos FROM bdicont:"informix".bi_balanza_dme WHERE ccmayor = bpccmayor AND ccsub = bpccsub AND ccsubsub = bpccsubsub
						AND ccssubsub = v_cero_sss AND ccsssubsub = v_cero_ssss AND sector = v_cero_sect AND tipo_cta IS NOT NULL AND fecha_balanza = p_dFecha;

						IF w_cuantos = 0 THEN
							INSERT INTO bdicont:"informix".bi_balanza_dme (fecha_insert, fecha_balanza, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, tipo_cta, descripcion,
							saldo_ideudor, saldo_iacreedor, cargos, abonos, saldo_fdeudor, saldo_facreedor)
							SELECT v_dFechaInsert, p_dFecha, bpccmayor, bpccsub, bpccsubsub, v_cero_sss, v_cero_ssss, v_cero_sect,"T", "",
							NVL(SUM(saldo_ideudor),0), NVL(SUM(saldo_iacreedor),0), NVL(SUM(cargos),0), NVL(SUM(abonos),0), NVL(SUM(saldo_fdeudor),0), NVL(SUM(saldo_facreedor),0)
							FROM bdicont:"informix".bi_balanza_dme
							WHERE ccmayor = bpccmayor AND
							ccsub      = bpccsub AND
							ccsubsub   = bpccsubsub AND
							ccssubsub  IS NOT NULL AND
							ccsssubsub IS NOT NULL AND 
							sector     IS NOT NULL AND
							fecha_balanza = p_dFecha AND
							tipo_cta   = "D";
						END IF

						-- SECTOR CERO PRIMER NIVEL
						SELECT COUNT(*) INTO w_cuantos FROM bdicont:"informix".bi_balanza_dme WHERE ccmayor = bpccmayor AND ccsub = bpccsub AND ccsubsub = v_cero_ss
						AND ccssubsub = v_cero_sss AND ccsssubsub = v_cero_ssss AND sector = v_cero_sect AND tipo_cta IS NOT NULL AND fecha_balanza = p_dFecha;

						IF w_cuantos = 0 THEN
							INSERT INTO bdicont:"informix".bi_balanza_dme (fecha_insert, fecha_balanza, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, tipo_cta, descripcion,
							saldo_ideudor, saldo_iacreedor, cargos, abonos, saldo_fdeudor, saldo_facreedor)
							SELECT v_dFechaInsert, p_dFecha, bpccmayor, bpccsub, v_cero_ss, v_cero_sss, v_cero_ssss, v_cero_sect,"T", "",
							NVL(SUM(saldo_ideudor),0), NVL(SUM(saldo_iacreedor),0), NVL(SUM(cargos),0), NVL(SUM(abonos),0), NVL(SUM(saldo_fdeudor),0), NVL(SUM(saldo_facreedor),0)
							FROM bdicont:"informix".bi_balanza_dme
							WHERE ccmayor = bpccmayor AND
							ccsub         = bpccsub AND
							ccsubsub      IS  NOT NULL AND
							ccssubsub     IS  NOT NULL AND
							ccsssubsub    IS  NOT NULL AND
							sector        IS  NOT NULL AND
							fecha_balanza = p_dFecha AND
							tipo_cta      = "D";
						END IF

						-- SECTOR CERO NIVEL MAYOR
						SELECT COUNT(*) INTO w_cuantos FROM bdicont:"informix".bi_balanza_dme WHERE ccmayor = bpccmayor AND ccsub = v_cero_s AND ccsubsub = v_cero_ss
						AND ccssubsub = v_cero_sss AND ccsssubsub = v_cero_ssss AND sector = v_cero_sect AND tipo_cta IS NOT NULL AND fecha_balanza = p_dFecha;

						IF w_cuantos = 0 THEN
							INSERT INTO bdicont:"informix".bi_balanza_dme (fecha_insert, fecha_balanza, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, tipo_cta, descripcion,
							saldo_ideudor, saldo_iacreedor, cargos, abonos, saldo_fdeudor, saldo_facreedor)
							SELECT v_dFechaInsert, p_dFecha, bpccmayor, v_cero_s, v_cero_ss, v_cero_sss, v_cero_ssss, v_cero_sect,"T", "",
							NVL(SUM(saldo_ideudor),0), NVL(SUM(saldo_iacreedor),0), NVL(SUM(cargos),0), NVL(SUM(abonos),0), NVL(SUM(saldo_fdeudor),0), NVL(SUM(saldo_facreedor),0)
							FROM bdicont:"informix".bi_balanza_dme
							WHERE ccmayor = bpccmayor AND
							ccsub      IS NOT NULL AND
							ccsubsub   IS NOT NULL AND
							ccssubsub  IS NOT NULL AND
							ccsssubsub IS NOT NULL AND
							sector     IS NOT NULL AND
							fecha_balanza = p_dFecha AND
							tipo_cta   = "D";
						END IF
					END IF

					-- DETERMINA SI SE TRATA DE UNA CUENTA TOTALIZADORA
					-- PRIMER NIVEL
					IF bpccmayor > v_cero_may AND bpccsub > v_cero_s AND bpccsubsub = v_cero_ss AND bpccssubsub = v_cero_sss AND bpccsssubsub = v_cero_ssss THEN
						-- SECTOR CERO PRIMER NIVEL
						SELECT COUNT(*) INTO w_cuantos FROM bdicont:"informix".bi_balanza_dme WHERE ccmayor = bpccmayor AND ccsub = bpccsub AND ccsubsub = v_cero_ss
						AND ccssubsub = v_cero_sss AND ccsssubsub = v_cero_ssss AND sector = v_cero_sect AND tipo_cta IS NOT NULL AND fecha_balanza = p_dFecha;

						IF w_cuantos = 0 THEN
							INSERT INTO bdicont:"informix".bi_balanza_dme (fecha_insert, fecha_balanza, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, tipo_cta, descripcion,
							saldo_ideudor, saldo_iacreedor, cargos, abonos, saldo_fdeudor, saldo_facreedor)
							SELECT v_dFechaInsert, p_dFecha, bpccmayor, bpccsub, v_cero_ss, v_cero_sss, v_cero_ssss, v_cero_sect,"T", "",
							NVL(SUM(saldo_ideudor),0), NVL(SUM(saldo_iacreedor),0), NVL(SUM(cargos),0), NVL(SUM(abonos),0), NVL(SUM(saldo_fdeudor),0), NVL(SUM(saldo_facreedor),0)
							FROM bdicont:"informix".bi_balanza_dme
							WHERE ccmayor = bpccmayor AND
							ccsub       = bpccsub AND
							ccsubsub    IS NOT NULL AND
							ccssubsub   IS NOT NULL AND
							ccsssubsub  IS NOT NULL AND
							sector      IS NOT NULL AND
							fecha_balanza = p_dFecha AND
							tipo_cta   = "D";
						END IF

						-- SECTOR CERO NIVEL MAYOR
						SELECT COUNT(*) INTO w_cuantos FROM bdicont:"informix".bi_balanza_dme WHERE ccmayor = bpccmayor AND ccsub = v_cero_s AND ccsubsub = v_cero_ss
						AND ccssubsub = v_cero_sss AND ccsssubsub = v_cero_ssss AND sector = v_cero_sect AND tipo_cta IS NOT NULL AND fecha_balanza = p_dFecha;

						IF w_cuantos = 0 THEN
							INSERT INTO bdicont:"informix".bi_balanza_dme (fecha_insert, fecha_balanza, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, tipo_cta, descripcion,
							saldo_ideudor, saldo_iacreedor, cargos, abonos, saldo_fdeudor, saldo_facreedor)
							SELECT v_dFechaInsert, p_dFecha, bpccmayor, v_cero_s, v_cero_ss, v_cero_sss, v_cero_ssss, v_cero_sect,"T", "",
							NVL(SUM(saldo_ideudor),0), NVL(SUM(saldo_iacreedor),0), NVL(SUM(cargos),0), NVL(SUM(abonos),0), NVL(SUM(saldo_fdeudor),0), NVL(SUM(saldo_facreedor),0)
							FROM bdicont:"informix".bi_balanza_dme
							WHERE ccmayor    = bpccmayor AND
							ccsub      IS NOT NULL AND
							ccsubsub   IS NOT NULL AND
							ccssubsub  IS NOT NULL AND
							ccsssubsub IS NOT NULL AND
							sector     IS NOT NULL AND
							fecha_balanza = p_dFecha AND
							tipo_cta   = "D";
						END IF
					END IF

					-- DETERMINA SI SE TRATA DE UNA CUENTA TOTALIZADORA
					-- MAYOR NIVEL
					IF bpccmayor > v_cero_may AND bpccsub = v_cero_s AND bpccsubsub = v_cero_ss AND bpccssubsub = v_cero_sss AND bpccsssubsub = v_cero_ssss THEN
						-- SECTOR CERO NIVEL MAYOR
						SELECT COUNT(*) INTO w_cuantos FROM bdicont:"informix".bi_balanza_dme WHERE ccmayor = bpccmayor AND ccsub = v_cero_s AND ccsubsub = v_cero_ss
						AND ccssubsub = v_cero_sss AND ccsssubsub = v_cero_ssss AND sector = v_cero_sect AND tipo_cta IS NOT NULL AND fecha_balanza = p_dFecha;
					 
						IF w_cuantos = 0 THEN
							INSERT INTO bdicont:"informix".bi_balanza_dme (fecha_insert, fecha_balanza, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, tipo_cta, descripcion,
							saldo_ideudor, saldo_iacreedor, cargos, abonos, saldo_fdeudor, saldo_facreedor)
							SELECT v_dFechaInsert, p_dFecha, bpccmayor, v_cero_s, v_cero_ss, v_cero_sss, v_cero_ssss, v_cero_sect,"T", "",
							NVL(SUM(saldo_ideudor),0), NVL(SUM(saldo_iacreedor),0), NVL(SUM(cargos),0), NVL(SUM(abonos),0), NVL(SUM(saldo_fdeudor),0), NVL(SUM(saldo_facreedor),0)
							FROM bdicont:"informix".bi_balanza_dme
							WHERE ccmayor = bpccmayor AND
							ccsub      IS NOT NULL AND
							ccsubsub   IS NOT NULL AND
							ccssubsub  IS NOT NULL AND
							ccsssubsub IS NOT NULL AND
							sector     IS NOT NULL AND
							fecha_balanza = p_dFecha AND
							tipo_cta   = "D";
						END IF
					END IF
				END FOREACH

				--ACTUALIZA EL NOMBRE DE LAS CUENTAS CONTABLES TOTALIZADORAS
				--DE ACUERDO AL CATALOGO DE CUENTAS CONTABLES
				FOREACH
					SELECT ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector
					INTO bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,bpsector
					FROM bdicont:"informix".bi_balanza_dme
					WHERE ccmayor  IS NOT NULL
					AND ccsub      IS NOT NULL
					AND ccsubsub   IS NOT NULL
					AND ccssubsub  IS NOT NULL
					AND ccsssubsub IS NOT NULL
					AND sector     IS NOT NULL
					AND tipo_cta   IS NOT NULL
					AND fecha_balanza = p_dFecha
					AND descripcion = ""

					SELECT nombre
					INTO v_nombre
					FROM bdinteg:"informix".si_catalog
					WHERE empresa = "001"
					AND   ccmayor = bpccmayor
					AND   ccsub   = bpccsub
					AND   ccsubsub = bpccsubsub
					AND   ccssubsub = bpccssubsub
					AND   ccsssubsub = bpccsssubsub
					AND   sector = bpsector;

					UPDATE bdicont:"informix".bi_balanza_dme
					SET descripcion = v_nombre
					WHERE ccmayor = bpccmayor
					AND   ccsub   = bpccsub
					AND   ccsubsub = bpccsubsub
					AND   ccssubsub = bpccssubsub
					AND   ccsssubsub = bpccsssubsub
					AND   sector = bpsector;
				END FOREACH

				LET v_sCod_Ret = "00000";
				LET v_sMensaje = "PROCESO EXITOSO";
			ELSE
				LET v_sCod_Ret = "00002";
				LET v_sMensaje = "PROCESO DE CIERRE CON ERRORES";
			END IF;
		ELSE
			LET v_sCod_Ret = "00003";
			LET v_sMensaje = "NO SE ENCONTRO EL PROCESO DE CIERRE DE LA FECHA ESPECIFICADA";
		END IF;
	ELSE
		LET v_sCod_Ret = "00001";
		LET v_sMensaje = "FECHA MAYOR A LA FECHA CONTABLE";
	END IF;

	RETURN v_sCod_Ret, v_sMensaje;
END;
END PROCEDURE;