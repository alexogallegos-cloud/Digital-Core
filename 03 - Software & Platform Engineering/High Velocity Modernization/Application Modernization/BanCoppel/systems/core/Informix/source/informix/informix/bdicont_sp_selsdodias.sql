CREATE PROCEDURE "informix".sp_selsdodias(p_sempresa CHAR(3), 
                                            p_scuentacontable CHAR(20), 
                                            p_sciudad CHAR(3), 
                                            p_ssucursal CHAR(4), 
                                            p_smoneda CHAR(2), 
                                            p_dfechacontable DATE, 
                                            p_ext CHAR(2))
	
RETURNING CHAR(5) AS codigo, 
        SMALLINT AS dia, 
        MONEY(18,2) AS saldoiniciodia, 
        MONEY(18,2) AS cargosdia, 
        MONEY(18,2) AS abonosdia, 
        MONEY(18,2) AS saldoactual;
  

	--DEFINICION DE VARIABLES
	DEFINE vCodret 				CHAR(5);
	DEFINE iSqlErr          	INTEGER;
	DEFINE v_sccmayor			CHAR(4);
	DEFINE v_sccsub				CHAR(2);
	DEFINE v_sccsubsub			CHAR(2);
	DEFINE v_sccssubsub			CHAR(2);
	DEFINE v_sccsssubsub		CHAR(2);
	DEFINE v_ssector			CHAR(2);
	DEFINE v_sidia				SMALLINT;
	DEFINE v_fsaldoiniciodia	MONEY(18,2);
	DEFINE v_fcargosdia			MONEY(18,2);
	DEFINE v_fabonosdia			MONEY(18,2);
	DEFINE v_fsaldoactual		MONEY(18,2);
	DEFINE v_dfechainicio		DATE;
	
	--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	--CREADO POR: VLADIMIR FÉLIX GÁLVEZ 8/JULIO/2009
	--Sp que realiza el proceso de obtencion de saldos de una cuenta contable por dia de una cuenta contable.
	--DEBUG DEL PROCEDURE
	--SET DEBUG FILE TO "/tmp/vladi/sp_consultarsaldosdiarios.out";
	--TRACE ON;
	--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
	BEGIN
		ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET vCodret = iSqlErr;
                RETURN vCodret,'','','','','';
            END IF;
        END EXCEPTION;
		
		IF p_sempresa = '' OR p_scuentacontable = '' OR (p_dfechacontable = '' OR p_dfechacontable IS NULL) OR p_smoneda = '' OR p_ext = '' THEN
			LET vCodret = '001';
			RETURN vCodret,'','','','','';
		END IF;	
		
		IF p_sciudad = '' THEN
			LET p_sciudad = NULL;
		END IF;
		IF p_ssucursal = '' THEN
			LET p_ssucursal = NULL;
		END IF;
				
		LET vCodret = '000';
		LET v_sccmayor = SUBSTR(p_scuentacontable,1,4);
		LET v_sccsub = SUBSTR(p_scuentacontable,6,2);
		LET v_sccsubsub = SUBSTR(p_scuentacontable,9,2);
		LET v_sccssubsub = SUBSTR(p_scuentacontable,12,2);
		LET v_sccsssubsub = SUBSTR(p_scuentacontable,15,2);
		LET v_ssector = SUBSTR(p_scuentacontable,18,2);
		LET v_dfechainicio = MDY(MONTH(p_dfechacontable),01,YEAR(p_dfechacontable));
		
		IF p_ext = 'DM' THEN
			
			FOREACH			
				SELECT DAY(mes_dia), SUM(saldo_inicio_dia), SUM(cargos_dia), SUM(abonos_dia), SUM(saldo_fin_de_dia)
				INTO v_sidia, v_fsaldoiniciodia, v_fcargosdia, v_fabonosdia, v_fsaldoactual
				FROM bdicont:"informix".co_sdodias
				WHERE empresa = p_sempresa
                    AND ccmayor = v_sccmayor 
                    AND ccsub = v_sccsub 
                    AND ccsubsub = v_sccsubsub
                    AND ccssubsub = v_sccssubsub 
                    AND ccsssubsub = v_sccsssubsub 
                    AND sector = v_ssector
                    AND ciudad = NVL(p_sciudad, ciudad)
                    AND sucursal = NVL(p_ssucursal, sucursal)
                    AND moneda = p_smoneda
                    AND mes_dia BETWEEN v_dfechainicio AND p_dfechacontable
                GROUP BY 1 ORDER BY 1
				
				RETURN vCodret, v_sidia, v_fsaldoiniciodia, v_fcargosdia, v_fabonosdia, v_fsaldoactual WITH RESUME;	
			END FOREACH;
			 
		ELIF p_ext = 'DO' THEN
			FOREACH			
				SELECT DAY(mes_dia), SUM(saldo_inicio_dia), SUM(cargos_dia), SUM(abonos_dia), SUM(saldo_fin_de_dia)
				INTO v_sidia, v_fsaldoiniciodia, v_fcargosdia, v_fabonosdia, v_fsaldoactual
				FROM bdicont:"informix".co_histsdodias
				WHERE empresa = p_sempresa
                    AND ccmayor = v_sccmayor 
                    AND ccsub = v_sccsub 
                    AND ccsubsub = v_sccsubsub
                    AND ccssubsub = v_sccssubsub 
                    AND ccsssubsub = v_sccsssubsub 
                    AND sector = v_ssector				
                    AND ciudad = NVL(p_sciudad, ciudad)				
                    AND sucursal = NVL(p_ssucursal, sucursal)
                    AND moneda = p_smoneda
                    AND mes_dia BETWEEN v_dfechainicio AND p_dfechacontable
				GROUP BY 1 ORDER BY 1
			
				RETURN vCodret, v_sidia, v_fsaldoiniciodia, v_fcargosdia, v_fabonosdia, v_fsaldoactual WITH RESUME;	
			END FOREACH;
		END IF;
	END;	
END PROCEDURE;