CREATE PROCEDURE "informix".sp_co_sel_sdo_apli(v_empresa CHAR(4), 
											   v_fechainicio DATE,
											   v_fechafin DATE,
											   v_ccmayorini CHAR(4),
											   v_ccsubini CHAR(2),
											   v_ccsubsubini CHAR(2),
											   v_ccssubsubini CHAR(2),
											   v_ccsssubsubini CHAR(2),
											   v_sectorini CHAR(2),
											   v_ccmayorfin CHAR(4),
											   v_ccsubfin CHAR(2),
											   v_ccsubsubfin CHAR(2),
											   v_ccssubsubfin CHAR(2),
											   v_ccsssubsubfin CHAR(2),
											   v_sectorfin CHAR(2),
											   v_sucursal CHAR(4),
											   v_auxiliar CHAR(12),
											   v_moneda CHAR(2))

 RETURNING VARCHAR(5), DATE, CHAR(4), CHAR(4), CHAR(2), CHAR(2), CHAR(2), CHAR(2), CHAR(2), CHAR(12), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), CHAR(2);

	DEFINE v_ccmayor		CHAR(10);
	DEFINE v_ccsub			CHAR(10);
	DEFINE v_ccsubsub		CHAR(10);
	DEFINE v_ccssubsub		CHAR(10);
	DEFINE v_ccsssubsub		CHAR(10);
	DEFINE v_sector			CHAR(10);	
	DEFINE v_cuenta 		CHAR(14);
	DEFINE v_cuenta_fin		CHAR(14);
	DEFINE v_fechahoy		DATE;
	DEFINE v_mesinicio		INTEGER;
	DEFINE v_anoinicio		INTEGER;
	DEFINE v_mesfin			INTEGER;
	DEFINE v_anofin			INTEGER;
	DEFINE v_meshoy			INTEGER;
	DEFINE v_anohoy			INTEGER;
    DEFINE tmovimientos		INTEGER;
    DEFINE cVarDataErr      VARCHAR(64);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE vCodret          CHAR(5);
	DEFINE v_auxiliar_cta   CHAR(1);
	DEFINE vb_ctacontable   BOOLEAN;
	
	DEFINE v_mes_dia        DATE;
	DEFINE v_sucursal_r		CHAR(4);
	DEFINE v_nro_auxiliar   CHAR(12);
	DEFINE v_monto          DECIMAL(18,2);
    DEFINE v_moneda_r		CHAR(2);

	DEFINE v_saldo_inicio_dia DECIMAL(18,2);
	DEFINE v_cargos_dia       DECIMAL(18,2); 
	DEFINE v_abonos_dia       DECIMAL(18,2);
	DEFINE v_saldo_fin_de_dia DECIMAL(18,2);
	
	
    --SET DEBUG FILE TO "sp_co_sel_sdo_apli.out";
    --TRACE ON;

	LET v_ccmayor		= "";
	LET v_ccsub			= "";
	LET v_ccsubsub		= "";
	LET v_ccssubsub		= "";
	LET v_ccsssubsub	= "";
	LET v_sector		= "";	
	LET v_cuenta		= "";
	LET v_cuenta_fin    = "";
	LET v_fechahoy		= "";
	LET v_mesinicio		= 0;
	LET v_anoinicio		= 0;
	LET v_mesfin		= 0;
	LET v_anofin		= 0;
	LET v_meshoy		= 0;
	LET v_anohoy		= 0;    
    LET tmovimientos    = 0;
	LET v_auxiliar_cta  = "";

	LET vb_ctacontable   = 'F';
    LET cVarDataErr     = "";
    LET iSqlErr         = 0;
    LET iSamErr         = 0;
    LET vCodret       = "000";
	
	LET v_sucursal_r = "";
	LET v_nro_auxiliar = "";
	LET v_monto = 0;
	LET v_moneda_r = "";
	
	LET v_saldo_inicio_dia = 0;
	LET v_cargos_dia = 0;     
	LET v_abonos_dia = 0;     
	LET v_saldo_fin_de_dia = 0;

	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;    

	BEGIN  --INICIO PROGRAMA

		ON EXCEPTION
            SET iSqlErr, iSamErr, cVarDataErr
            IF iSqlErr <> 0 THEN

				IF vb_ctacontable = 'T' THEN
                    DROP TABLE bdicont:tmp_ctacontable;
                END IF

                LET vCodret=iSqlErr;
                RETURN vCodret, null, null, null, null, null, null, null, null, null, null, null, null, null, null;
            END IF
		END EXCEPTION;
	
		SELECT fecha_hoy
		INTO v_fechahoy
		FROM bdicont:"informix".co_fechas
		WHERE empresa = v_empresa;

		LET v_mesinicio = MONTH(v_fechainicio);
		LET v_mesfin = MONTH(v_fechafin);
		LET v_meshoy = MONTH(v_fechahoy);

		LET v_anoinicio = YEAR(v_fechainicio);
		LET v_anofin = YEAR(v_fechafin);
		LET v_anohoy = YEAR(v_fechahoy);

		LET v_cuenta = TRIM(v_ccmayorini) || TRIM(v_ccsubini) || TRIM(v_ccsubsubini) || TRIM(v_ccssubsubini) || TRIM(v_ccsssubsubini) || TRIM(v_sectorini);
		LET v_cuenta_fin = TRIM(v_ccmayorfin) || TRIM(v_ccsubfin) || TRIM(v_ccsubsubfin) || TRIM(v_ccssubsubfin) || TRIM(v_ccsssubsubfin) || TRIM(v_sectorfin);

 
		CREATE TEMP TABLE bdicont:tmp_ctacontable (ccmayor CHAR(4),
                                                   ccsub CHAR(2),
                                                   ccsubsub CHAR(2),
                                                   ccssubsub CHAR(2),
                                                   ccsssubsub CHAR(2),
                                                   sector CHAR(2),
                                                   auxiliar CHAR(1));
		LET	vb_ctacontable = 'T';

		IF (v_cuenta=v_cuenta_fin) THEN

			INSERT INTO tmp_ctacontable
			SELECT ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,auxiliar
			FROM bdinteg:"informix".si_catalog
			WHERE empresa = v_empresa
				AND TRIM(ccmayor)||TRIM(ccsub)||TRIM(ccsubsub)||TRIM(ccssubsub)||TRIM(ccsssubsub)||TRIM(sector) = v_cuenta
				AND tipo_cuenta = 'D';
		ELSE
		
			INSERT INTO tmp_ctacontable
			SELECT ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,auxiliar
			FROM bdinteg:"informix".si_catalog
			WHERE empresa = v_empresa
				AND TRIM(ccmayor)||TRIM(ccsub)||TRIM(ccsubsub)||TRIM(ccssubsub)||TRIM(ccsssubsub)||TRIM(sector) 
                    BETWEEN v_cuenta AND v_cuenta_fin
				AND tipo_cuenta = 'D';
		END IF

        CREATE INDEX idx01tmp_ctacontable ON bdicont:tmp_ctacontable(ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector);
        UPDATE STATISTICS MEDIUM FOR TABLE bdicont:tmp_ctacontable;
		
		IF v_sucursal IS NULL OR v_sucursal = "" THEN
			LET v_sucursal = NULL;
		END IF
		
		IF v_auxiliar IS NULL OR v_auxiliar = "" THEN
			LET v_auxiliar = NULL;
		END IF
		
		IF v_moneda IS NULL OR v_moneda = "" THEN
			LET v_moneda = NULL;
		END IF
		
        FOREACH WITH HOLD 
			SELECT ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,auxiliar
			INTO v_ccmayor, v_ccsub, v_ccsubsub, v_ccssubsub, v_ccsssubsub, v_sector, v_auxiliar_cta
			FROM bdicont:tmp_ctacontable
            WHERE 1 = 1
		  ORDER BY ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,auxiliar

			LET v_cuenta = TRIM(v_ccmayor) || TRIM(v_ccsub) || TRIM(v_ccsubsub)|| TRIM(v_ccssubsub) || TRIM(v_ccsssubsub) || TRIM(v_sector);

			IF v_mesfin = v_meshoy AND v_anofin = v_anohoy THEN  -- CONSULTA TABLAS MENSUALES
				IF v_auxiliar_cta = 'N' THEN
					FOREACH
						SELECT mes_dia,sucursal,'' AS auxiliar,saldo_inicio_dia,cargos_dia,abonos_dia,saldo_fin_de_dia,moneda
						  INTO v_mes_dia,v_sucursal_r,v_nro_auxiliar,v_saldo_inicio_dia,v_cargos_dia,v_abonos_dia,v_saldo_fin_de_dia,v_moneda_r
						  FROM bdicont:co_sdodias
						 WHERE empresa = v_empresa
						  AND mes_dia BETWEEN v_fechainicio AND v_fechafin
						  AND ccmayor = v_ccmayor
						  AND ccsub = v_ccsub
						  AND ccsubsub = v_ccsubsub
						  AND ccssubsub = v_ccssubsub
						  AND ccsssubsub = v_ccsssubsub
						  AND sector = v_sector
						  AND moneda = NVL(v_moneda,moneda) 
						  AND sucursal = NVL(v_sucursal,sucursal) 

						LET vCodret = '000';
						
						RETURN vCodret,v_mes_dia,v_sucursal_r,
							   v_ccmayor, v_ccsub, v_ccsubsub, v_ccssubsub, v_ccsssubsub, v_sector,
							   v_nro_auxiliar,v_saldo_inicio_dia,v_cargos_dia,v_abonos_dia,v_saldo_fin_de_dia,v_moneda_r
						WITH RESUME;
					END FOREACH		
				ELSE
					FOREACH
						SELECT mes_dia,sucursal,auxiliar,saldo_inicio_dia,cargos_dia,abonos_dia,saldo_fin_de_dia,moneda
						  INTO v_mes_dia,v_sucursal_r,v_nro_auxiliar,v_saldo_inicio_dia,v_cargos_dia,v_abonos_dia,v_saldo_fin_de_dia,v_moneda_r
						  FROM bdicont:co_diasaux
						 WHERE empresa = v_empresa
						   AND mes_dia BETWEEN v_fechainicio AND v_fechafin
						   AND ccmayor = v_ccmayor
						   AND ccsub = v_ccsub
						   AND ccsubsub = v_ccsubsub
						   AND ccssubsub = v_ccssubsub
						   AND ccsssubsub = v_ccsssubsub
						   AND sector = v_sector
						   AND auxiliar = NVL(v_auxiliar,auxiliar) 
						   AND moneda = NVL(v_moneda,moneda) 
						   AND sucursal = NVL(v_sucursal,sucursal) 

						LET vCodret = '000';
						
						RETURN vCodret,v_mes_dia,v_sucursal_r,
							   v_ccmayor, v_ccsub, v_ccsubsub, v_ccssubsub, v_ccsssubsub, v_sector,
							   v_nro_auxiliar,v_saldo_inicio_dia,v_cargos_dia,v_abonos_dia,v_saldo_fin_de_dia,v_moneda_r
						WITH RESUME;
					END FOREACH		
				END IF; 
			
			END IF; 

			IF v_mesinicio < v_meshoy OR v_anoinicio <= v_anohoy THEN  -- CONSULTA TABLAS HISTORICAS 
				IF v_auxiliar_cta = 'N' THEN
					FOREACH
						SELECT mes_dia,sucursal,'' AS auxiliar,saldo_inicio_dia,cargos_dia,abonos_dia,saldo_fin_de_dia,moneda
						  INTO v_mes_dia,v_sucursal_r,v_nro_auxiliar,v_saldo_inicio_dia,v_cargos_dia,v_abonos_dia,v_saldo_fin_de_dia,v_moneda_r
						  FROM bdicont:co_histsdodias
						 WHERE empresa = v_empresa
						  AND mes_dia BETWEEN v_fechainicio AND v_fechafin
						  AND ccmayor = v_ccmayor
						  AND ccsub = v_ccsub
						  AND ccsubsub = v_ccsubsub
						  AND ccssubsub = v_ccssubsub
						  AND ccsssubsub = v_ccsssubsub
						  AND sector = v_sector
						  AND moneda = NVL(v_moneda,moneda) 
						  AND sucursal = NVL(v_sucursal,sucursal) 

						LET vCodret = '000';
						
						RETURN vCodret,v_mes_dia,v_sucursal_r,
							   v_ccmayor, v_ccsub, v_ccsubsub, v_ccssubsub, v_ccsssubsub, v_sector,
							   v_nro_auxiliar,v_saldo_inicio_dia,v_cargos_dia,v_abonos_dia,v_saldo_fin_de_dia,v_moneda_r
						WITH RESUME;
					END FOREACH		
				ELSE
					FOREACH
						SELECT mes_dia,sucursal,auxiliar,saldo_inicio_dia,cargos_dia,abonos_dia,saldo_fin_de_dia,moneda
						  INTO v_mes_dia,v_sucursal_r,v_nro_auxiliar,v_saldo_inicio_dia,v_cargos_dia,v_abonos_dia,v_saldo_fin_de_dia,v_moneda_r
						  FROM bdicont:co_histdiasaux
						 WHERE empresa = v_empresa
						  AND mes_dia BETWEEN v_fechainicio AND v_fechafin
						  AND ccmayor = v_ccmayor
						  AND ccsub = v_ccsub
						  AND ccsubsub = v_ccsubsub
						  AND ccssubsub = v_ccssubsub
						  AND ccsssubsub = v_ccsssubsub
						  AND sector = v_sector
						  AND auxiliar = NVL(v_auxiliar,auxiliar) 
						  AND moneda = NVL(v_moneda,moneda) 
						  AND sucursal = NVL(v_sucursal,sucursal) 

						LET vCodret = '000';
						
						RETURN vCodret,v_mes_dia,v_sucursal_r,
							   v_ccmayor, v_ccsub, v_ccsubsub, v_ccssubsub, v_ccsssubsub, v_sector,
							   v_nro_auxiliar,v_saldo_inicio_dia,v_cargos_dia,v_abonos_dia,v_saldo_fin_de_dia,v_moneda_r
						WITH RESUME;
					END FOREACH		
				END IF; 
			END IF; 
		END FOREACH; 

        DROP TABLE tmp_ctacontable;
		LET vb_ctacontable = 'F';

	END; 
END PROCEDURE;