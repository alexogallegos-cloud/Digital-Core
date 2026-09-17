CREATE PROCEDURE "informix".sp_get_estadisticas_correos_telefonos_pba()
RETURNING CHAR(6), CHAR(100);
--VARIABLES DE ERROR
DEFINE cVarDataErr      	CHAR(100);
DEFINE iSqlErr          	INTEGER;
DEFINE iSamErr          	INTEGER;
DEFINE vCodRet          	CHAR(6);
DEFINE cCodRetSP          	CHAR(6);
DEFINE cVarDataErrSP      	CHAR(100);
--DEFINICION DE VARIABLES		
DEFINE dFechahoy			DATE;	
DEFINE dfecha_alta			DATE;
DEFINE dFechaproceso		DATE;
DEFINE dmax_fecha_insert	DATE;
DEFINE iEnTransaccion		SMALLINT;
DEFINE vcod_param_sms		SMALLINT;
DEFINE vcod_param_cels		SMALLINT;
DEFINE vcod_param_correo	SMALLINT;
DEFINE vcod_param_alta_cte	SMALLINT; 
DEFINE iCod_param_ind_com   SMALLINT;
DEFINE vsms_val				INTEGER;
DEFINE vsms_total			INTEGER;
DEFINE vsms_no_val			INTEGER;
DEFINE ivalidos				INTEGER;
DEFINE iinvalidos			INTEGER;
DEFINE isin_validar			INTEGER;
DEFINE iBanco				INTEGER;
DEFINE icoppel				INTEGER;
DEFINE ibanco_coppel 		INTEGER;
DEFINE isolo_coppel 		INTEGER;
DEFINE isolo_banco			INTEGER;
DEFINE ibca_basica			INTEGER;
DEFINE ibca_avanzada		INTEGER;
--ALTA DE CLIENTES
DEFINE cnumcte				CHAR(20);
DEFINE cPromotor			CHAR(8);
DEFINE csucursal			CHAR(4);
DEFINE cProceso				CHAR(100);
DEFINE cEvento				CHAR(100);
DEFINE iTotal_tel_casa		INTEGER;
DEFINE iTotal_tel_casa_val	INTEGER;
DEFINE iTotal_tel_casa_inval INTEGER;
DEFINE iTotal_tel_casa_pen	INTEGER;
DEFINE iTotal_tel_casa_rep	INTEGER;
DEFINE iTotal_celular		INTEGER;
DEFINE iTotal_celular_val	INTEGER;
DEFINE iTotal_celular_inval	INTEGER;
DEFINE iTotal_celular_pen	INTEGER;
DEFINE iVerificados			INTEGER;
DEFINE iTotal_celular_rep	INTEGER;
DEFINE iTotal_otro			INTEGER;
DEFINE iTotal_otro_val		INTEGER;
DEFINE iTotal_otro_inval	INTEGER;
DEFINE iTotal_otro_pen		INTEGER;
DEFINE iTotal_otro_rep		INTEGER;
DEFINE iprospectos			INTEGER;
DEFINE iTitulares			INTEGER;
DEFINE isinproductos		INTEGER;
--MANTENIMIENTOS
DEFINE vcod_param_manntos_diarios SMALLINT;
DEFINE imannto_huella		INTEGER;
DEFINE imannto_direcciones	INTEGER;
DEFINE imannto_direcciones_casa	INTEGER;
DEFINE imannto_direcciones_oficina	INTEGER;
DEFINE imannto_correos		INTEGER;
DEFINE itel_casa			INTEGER;
DEFINE itel_celular			INTEGER;
DEFINE itel_oficina			INTEGER;
DEFINE itel_otro			INTEGER;
DEFINE cstatus_consulta		CHAR(1);				
DEFINE dfecha_solicitud		DATETIME YEAR TO FRACTION;
DEFINE dfecha_respuesta		DATETIME YEAR TO FRACTION;
DEFINE dtiempo_resp    		INTERVAL HOUR TO SECOND;
DEFINE usuario				CHAR(8);
DEFINE dfecha_insert		DATETIME YEAR TO FRACTION;
--ASIGNACION DE VARIABLES
LET dFechahoy=CURRENT::DATE;
LET vcod_param_sms=0;
LET vcod_param_cels=0;
LET vcod_param_correo=0;
LET vsms_val=0;				
LET vsms_total=0;	
LET vsms_no_val=0;	
LET ivalidos=0;			
LET iinvalidos=0;
LET isin_validar=0;
LET iCod_param_ind_com=0;
LET iEnTransaccion = 0;
--ALTA DE CLIENTES
LET vcod_param_alta_cte=0;
LET cnumcte='';
LET iBanco=0;
LET icoppel=0;
LET ibanco_coppel=0;
LET isolo_coppel=0;
LET isolo_banco=0;
LET ibca_basica=0;
LET ibca_avanzada=0;
LET csucursal='';
LET iprospectos=0;
LET dfecha_alta='';
LET iTitulares=0;
LET isinproductos=0;			
--MANTENIMIENTOS
LET vcod_param_manntos_diarios=0;
LET imannto_huella=0;
LET imannto_direcciones=0;
LET imannto_direcciones_casa=0;
LET imannto_direcciones_oficina=0;
LET imannto_correos=0;
LET itel_casa=0;
LET itel_celular=0;
LET itel_oficina=0;
LET itel_otro=0;
LET cstatus_consulta ='';				
LET dfecha_solicitud ='';
LET dfecha_respuesta ='';
LET dtiempo_resp ='';
LET usuario	='';
LET dfecha_insert='';
LET cProceso = '';
LET cEvento = '';

--ASIGNACION DE VARIABLES ERROR
LET vCodRet = '000000';
LET cVarDataErr = 'EL REPORTE DE ESTADISTICAS, FUE GENERADO SATISFACTORIAMENTE';

--SET DEBUG FILE TO '/informix/Ingrid/sp_get_estadisticas_correos_telefonos.out';
--TRACE ON;
BEGIN
	--Manejo del error
	ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
			LET vCodret=iSqlErr;
			
			IF iEnTransaccion = 1 THEN
				ROLLBACK;
			END IF;
			
			INSERT INTO si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
			VALUES (dFechaProceso, cProceso, cEvento, vCodret, cVarDataErr);
			
			IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabid > 99 and tabname = 'tmp_alta_ctes_titulares') THEN
				DROP TABLE tmp_alta_ctes_titulares;
			END IF;			
			
			IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabid > 99 and tabname = 'tmp_sucursal_ejecut') THEN
				DROP TABLE tmp_sucursal_ejecut;
			END IF;			
			
			IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabid > 99 and tabname = 'tmp_telefonos_ctenvos') THEN
				DROP TABLE tmp_telefonos_ctenvos;
			END IF;		
			
			IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabid > 99 and tabname = 'tmp_mantto_ctes_titulares') THEN
				DROP TABLE tmp_mantto_ctes_titulares;
			END IF;
			
			IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabid > 99 and tabname = 'tmp_telefonos_ctesmantto') THEN
				DROP TABLE tmp_telefonos_ctesmantto;
			END IF;
			
			IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabid > 99 and tabname = 'tmp_sucursal_ejecut_mantto') THEN
				DROP TABLE tmp_sucursal_ejecut_mantto;
			END IF;
	
			RETURN vCodret, iSamErr || ' ' ||cVarDataErr;
		END IF;
	END EXCEPTION;
			
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	LET cProceso = 'PRINCIPAL';
	LET cEvento	= 'OBTENCION DE PARAMETROS';
	LET dFechaproceso = dFechahoy - 1 UNITS DAY;	
	
	SELECT valor 
	INTO vcod_param_sms
	FROM bdinteg:"informix".si_param 
	WHERE empresa='001'
	AND cod_param='312';
	
	SELECT valor 
	INTO vcod_param_cels
	FROM bdinteg:"informix".si_param 
	WHERE empresa='001'
	AND cod_param='310';
	
	SELECT valor 
	INTO vcod_param_correo
	FROM bdinteg:"informix".si_param 
	WHERE empresa='001'
	AND cod_param='311';
		
	LET cEvento	= 'GENERACION TABLA TEMPORAL TMP_ALTA_CTES_TITULARES';
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} a.sucursal, a.numcte, b.usuario AS numemp, b.fecha_alta
	FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_cte_huella b 
	WHERE a.numcte=b.numcte AND b.secuencia=1 AND b.fecha_alta=dFechaproceso 
	AND a.tipo_cliente='1'	
	INTO TEMP tmp_alta_ctes_titulares
	WITH NO LOG;
	
	CREATE INDEX "informix".tmp_idx_alta_ctes_titulares ON tmp_alta_ctes_titulares (numcte);
	CREATE INDEX "informix".tmp_idx_alta_ctes_titulares2 ON tmp_alta_ctes_titulares (fecha_alta);
	CREATE INDEX "informix".tmp_idx_alta_ctes_titulares3 ON tmp_alta_ctes_titulares (sucursal);
	
	LET cEvento = 'GENERACION TABLA TEMPORAL TMP_MANTTO_CTES_TITULARES';
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	SELECT a.numcte, a.user_insert AS numemp, c.sucursal, a.fecha  AS fecha_alta
	FROM TABLE(MULTISET(SELECT DISTINCT user_insert, numcte, fecha_hora::DATE AS fecha FROM si_telefonos WHERE fecha_hora::DATE = dFechaproceso AND secuencia > 1 AND user_insert NOT IN ('interact', 'transBPI')
                    UNION ALL
                    SELECT DISTINCT user_insert, numcte, fecha_hora::DATETIME YEAR TO FRACTION::DATE AS fecha FROM si_correos WHERE fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaproceso AND secuencia > 1 AND user_insert NOT IN ('interact', 'transBPI'))) a,
	si_cliente b, si_ejecut c, si_cte_huella d
	WHERE a.numcte = b.numcte
	AND b.numcte = d.numcte
	AND b.tipo_cliente = '1'
	AND a.user_insert = c.ejecutivo
	AND d.secuencia = 1
	AND a.fecha > d.fecha_alta
	AND c.password IN ('bancoppel2007','informix')
	INTO TEMP tmp_mantto_ctes_titulares 
	WITH NO LOG;
	
	CREATE INDEX "informix".tmp_idx_mantto_ctes_titulares ON tmp_mantto_ctes_titulares (numcte);
	CREATE INDEX "informix".tmp_idx_mantto_ctes_titulares ON tmp_mantto_ctes_titulares (fecha_alta);
	CREATE INDEX "informix".tmp_idx_mantto_ctes_titulares ON tmp_mantto_ctes_titulares (sucursal);
		
	LET cProceso = 'INDICADORES DE SMS';	
	LET cEvento	= 'OBTENCION DE MAX FECHA DE si_estadistica_sms';
	SELECT MAX(fecha_insert::DATE)
	INTO dmax_fecha_insert
	FROM bdinteg:"informix".si_estadistica_sms;	
	
	LET dFechaproceso = dFechahoy - vcod_param_sms;	
	BEGIN WORK;
		LET iEnTransaccion = 1;
		IF NOT EXISTS (SELECT 1 FROM bdinteg:"informix".si_estadistica_sms WHERE fecha = dFechaproceso) THEN			
			LET cEvento = 'OBTENCION DE INDICADORES EN SI_TELEFONOS';
			--SI_TELEFONOS 
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT COUNT(*) AS sms_val
			INTO vsms_val 
			FROM bdinteg:si_telefonos WHERE telefono IN (
			SELECT {+INDEX (bdimnsj:"informix".mnsjr_trx_online inx_fh_idmsg)} celular_alterno 
			FROM bdimnsj:"informix".mnsjr_trx_online 
			WHERE id_mensaje = 'OFI_AVSMS' 
			AND fecha_hora_registro::DATE = dFechaproceso)
			AND tipo_tel='2' AND verificado='V' AND fecha_hora::DATE = dFechaproceso;		
						
			--SI_TELEFONOS_ACTUAL
			LET cEvento = 'OBTENCION DE INDICADORES EN SI_TELEFONOS_ACTUAL';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;			
			SELECT COUNT(*) AS sms_total
			INTO vsms_total 
			FROM bdinteg:si_telefonos_actual WHERE telefono IN (
			SELECT {+INDEX (bdimnsj:"informix".mnsjr_trx_online inx_fh_idmsg)} celular_alterno 
			FROM bdimnsj:"informix".mnsjr_trx_online 
			WHERE id_mensaje = 'OFI_AVSMS' 
			AND fecha_hora_registro::DATE = dFechaproceso) 
			AND cofetel='V' AND tipo_tel='2' AND fecha_hora::DATE=dFechaproceso; 
			
			LET vsms_no_val = vsms_total - vsms_val;		

			LET cEvento = 'INSERCION DE INDICADORES EN SI_ESTADISTICA_SMS';
			INSERT INTO bdinteg:"informix".si_estadistica_sms(fecha, sms_val, sms_no_val, total, porc_val, porc_no_val, user_insert, fecha_insert)
			VALUES (dFechaproceso, vsms_val, vsms_no_val, vsms_total, NVL(((NULLIF(vsms_val,0)/ NULLIF(vsms_total,0))*100),0), NVL(((NULLIF(vsms_no_val,0)/ NULLIF(vsms_total,0))*100),0), USER, CURRENT);							
		END IF;	
	COMMIT WORK;
	LET iEnTransaccion = 0;
	
	LET cProceso = 'INDICADORES DE CORREOS DE CLIENTES NUEVOS';
	LET cEvento	= 'OBTENCION DE MAX FECHA DE si_estadistica_correos_clientes_nvos';
	
	SELECT MAX(fecha_insert::DATE) 
	INTO dmax_fecha_insert
	FROM bdinteg:si_estadistica_correos_clientes_nvos;	
	
	LET dFechaproceso = dFechahoy - 1;		
	BEGIN WORK;
		LET iEnTransaccion = 1;
		IF NOT EXISTS(SELECT 1 FROM bdinteg:si_estadistica_correos_clientes_nvos WHERE fecha = dFechaProceso) THEN
			LET cEvento = 'INSERCION DE INDICADORES EN SI_ESTADISTICA_CORREOS_CLIENTES_NVOS';
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;			
			INSERT INTO bdinteg:"informix".si_estadistica_correos_clientes_nvos (sucursal, fecha, total, validos, invalidos, sin_validar, user_insert, fecha_insert)
			SELECT sucursal,dFechaproceso, NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) AS total_correos, NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos, NVL(SUM(sin_validar),0) AS sin_validar, USER, CURRENT::DATE
			FROM TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_correos idx_corr_status)} d.sucursal,
								CASE WHEN a.valido = '1' THEN COUNT(a.correo_elec) ELSE 0 END AS validos,
								CASE WHEN a.valido = '0' THEN COUNT(a.correo_elec) ELSE 0 END AS invalidos,
								CASE WHEN a.valido IS NULL THEN COUNT(a.correo_elec) ELSE 0 END AS sin_validar
								 
							FROM bdinteg:"informix".si_correos a, bdinteg:si_cliente b, bdinteg:"informix".si_cte_huella c, bdinteg:"informix".si_ejecut d
							WHERE a.numcte=b.numcte
							AND b.numcte=c.numcte
							AND b.tipo_cliente= '1'
							AND a.secuencia =1
							AND c.secuencia = 1
							AND c.fecha_alta = a.fecha_hora::DATETIME YEAR TO FRACTION::DATE
							AND a.fecha_hora::DATETIME YEAR TO FRACTION::DATE =dFechaproceso
							AND c.usuario = d.ejecutivo
							GROUP BY d.sucursal, a.valido
			))
			GROUP BY 1,2;
		END IF;
	COMMIT WORK;
	LET iEnTransaccion = 0;
	
	LET cProceso = 'INDICADORES DE CORREOS REPETIDOS';
	LET cEvento	= 'OBTENCION DE MAX FECHA DE si_estadistica_correos';
	SELECT MAX(fecha_insert::DATE)
	INTO dmax_fecha_insert
	FROM bdinteg:"informix".si_estadistica_correos;
	
	LET dFechaproceso = dFechahoy - vcod_param_correo;
		
	BEGIN WORK;
		LET iEnTransaccion = 1;
		--IF (vDiaSemana=1 AND dmax_fecha_insert IS NULL) OR (dFechaHoy::DATE - dmax_fecha_insert::DATE = vcod_param_correo) THEN --SEMANAL
		IF NOT EXISTS (SELECT 1 FROM bdinteg:si_estadistica_correos WHERE fecha = dFechaProceso) THEN						
			LET cEvento = 'OBTENCION DE INDICADORES DE SI_CORREOS';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;			
			SELECT NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos, NVL(SUM(sin_validar),0) AS sin_validar
			INTO ivalidos, iinvalidos, isin_validar
			FROM (TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_correos idx_corr_status)} 
										CASE WHEN a.valido = '1' THEN COUNT(a.correo_elec) END AS validos,
										CASE WHEN a.valido = '0' THEN COUNT(a.correo_elec) END AS invalidos,
										CASE WHEN a.valido IS NULL THEN COUNT(a.correo_elec) END AS sin_validar
								FROM bdinteg:"informix".si_correos a, bdinteg:si_cliente b
								WHERE a.numcte=b.numcte
								AND a.status_correo='A'
								AND b.fecha_alta= dFechaproceso
								GROUP BY a.valido))); 
			
			LET cEvento = 'INSERCION DE INDICADORES EN SI_ESTADISTICA_CORREOS';
			INSERT INTO bdinteg:"informix".si_estadistica_correos(fecha, total, valido,invalido,sin_validar, user_insert, fecha_insert)
			VALUES(dFechaproceso, (NVL(ivalidos,0)+ NVL(iinvalidos,0)+ NVL(isin_validar,0)), NVL(ivalidos,0), NVL(iinvalidos,0), NVL(isin_validar,0), USER, CURRENT);				
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			LET cEvento = 'INSERCION DE INDICADORES EN SI_ESTADISTICA_CORREOS_REPETIDOS';
			INSERT INTO bdinteg:"informix".si_estadistica_correos_repetidos(correo_elec, cantidad, sucursal, usuario, fecha, user_insert, fecha_insert)
			SELECT {+INDEX (bdinteg:"informix".si_correos idx_corr_ctetipcorrstat)} b.correo_elec, COUNT(*) AS cantidad, a.sucursal, a.user_insert, a.fecha_alta, USER, CURRENT
			FROM bdinteg:si_cliente a, bdinteg:"informix".si_correos b
			WHERE a.numcte=b.numcte
			AND a.fecha_alta= dFechaproceso
			AND b.correo_elec<>'' 
			AND b.status_correo='A'
			GROUP BY 1,3,4,5
			HAVING COUNT(*) > 1;  			
		END IF;
	COMMIT WORK; 
	LET iEnTransaccion = 0;
	
	LET cProceso = 'INDICADORES DE CELULARES REPETIDOS';
	LET cEvento	= 'OBTENCION DE MAX FECHA DE si_estadistica_cels';
	SELECT MAX(fecha_insert::DATE)
	INTO dmax_fecha_insert
	FROM bdinteg:"informix".si_estadistica_cels;	
	
	LET dFechaproceso = dFechahoy - vcod_param_cels;
	
	BEGIN WORK;
		LET iEnTransaccion = 1;
		--IF (vDiaSemana=1 AND dmax_fecha_insert IS NULL) OR (dFechaHoy::DATE - dmax_fecha_insert::DATE = vcod_param_cels) THEN --SEMANAL
		IF NOT EXISTS(SELECT 1 FROM bdinteg:"informix".si_estadistica_cels WHERE fecha = dFechaProceso ) THEN
			LET cEvento = 'OBTENCION DE INDICADORES DE SI_TELEFONOS_ACTUAL';
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;			
			SELECT NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos
			INTO ivalidos, iinvalidos
			FROM (TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_telefonos_actual idx_telact_ctetipo)} 
							CASE WHEN a.cofetel = 'V' THEN COUNT(a.telefono) END AS validos,
							CASE WHEN a.cofetel = 'F' THEN COUNT(a.telefono) END AS invalidos                       
							FROM bdinteg:si_telefonos_actual a, bdinteg:si_cliente b 
							WHERE a.numcte=b.numcte
							AND a.tipo_tel='2' 
							AND a.status_tel='A'
							AND a.fecha_hora::DATE= dFechaproceso 
							AND b.fecha_alta= dFechaproceso
							GROUP BY a.cofetel)));					
			
			LET cEvento = 'INSERCION DE INDICADORES DE SI_ESTADISTICA_CELS';
			INSERT INTO bdinteg:"informix".si_estadistica_cels(fecha, total, validos, invalidos, user_insert, fecha_insert)
			VALUES(dFechaproceso, (NVL(ivalidos,0)+ NVL(iinvalidos,0)), NVL(ivalidos,0), NVL(iinvalidos,0), USER, CURRENT);	
			
			--INSERTA EL DETALLE DE LOS CELULARES
			LET cEvento = 'INSERCION DE INDICADORES EN SI_ESTADISTICA_CELS_REPETIDOS';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			INSERT INTO bdinteg:"informix".si_estadistica_cels_repetidos(telefono, cantidad, sucursal, usuario, fecha, user_insert, fecha_insert)
			SELECT  {+INDEX (bdinteg:"informix".si_telefonos_actual idx_telact_ctetipo)} a.telefono, COUNT(*) AS cantidad, b.sucursal, b.user_insert, b.fecha_alta, USER, CURRENT
			FROM bdinteg:si_telefonos_actual a, bdinteg:si_cliente b
			WHERE a.numcte=b.numcte
			AND a.tipo_tel='2' 
			AND a.status_tel='A'
			AND a.fecha_hora::DATE= dFechaproceso
			AND b.fecha_alta= dFechaproceso
			GROUP BY 1,3,4,5
			HAVING COUNT(*) > 1;			
		END IF; 
	COMMIT WORK;
	LET iEnTransaccion = 0;
	
	LET cProceso = 'INDICADORES DE ALTA DE CLIENTES';
	LET cEvento	= 'OBTENCION DE MAX FECHA DE si_alta_ctes_indicadores';
	
	SELECT MAX(fecha_insert::DATE) 
	INTO dmax_fecha_insert 
	FROM bdinteg:"informix".si_alta_ctes_indicadores;
	
	LET dFechaproceso = dFechahoy - vcod_param_cels;
	
	--IF (vDiaSemana=1 AND dmax_fecha_insert IS NULL) OR (dFechaHoy::DATE - dmax_fecha_insert::DATE = vcod_param_cels) THEN --SEMANAL
	BEGIN WORK;
		LET iEnTransaccion = 1;				
		IF NOT EXISTS(SELECT 1 FROM bdinteg:"informix".si_alta_ctes_indicadores WHERE fecha_proceso = dFechaProceso) THEN			
			LET cEvento = 'INSERCION DE INDICADORES DE ALTA DE CLIENTES EN si_alta_ctes_indicadores_suc';
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdinteg:"informix".si_alta_ctes_indicadores_suc(fecha_proceso, sucursal, titulares, prospectos, total, tot_prod_coppel, tot_prod_banco, tot_cop_bco, tot_sinproductos, tot_bca_basica, tot_bca_avanzada, user_insert, fecha_insert)
			SELECT fecha_alta, sucursal, titulares, prospectos, total, tot_prod_coppel, tot_prod_banco, tot_cop_bco, tot_sinproductos, tot_bca_basica, tot_bca_avanzada, user_insert, fecha_insert
			FROM (TABLE(MULTISET(SELECT fecha_alta ,sucursal, NVL(COUNT(*),0) AS titulares,0 AS prospectos,0 AS total,0 AS tot_prod_coppel,0 AS tot_prod_banco,0 AS tot_cop_bco, 0 AS tot_sinproductos,0 AS tot_bca_basica,0 AS tot_bca_avanzada, USER AS user_insert, CURRENT AS fecha_insert
			FROM tmp_alta_ctes_titulares
			GROUP BY fecha_alta, sucursal 
			ORDER BY sucursal))); 
			
			LET cEvento = 'GENERACION DE INDICADORES DE ALTA DE CLIENTES PROSPECTOS';	
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH
				SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} sucursal, NVL(COUNT(*),0) AS prospectos
				INTO csucursal, iprospectos
				FROM bdinteg:si_cliente 
				WHERE tipo_cliente='2'
				AND fecha_alta= dFechaproceso
				GROUP BY sucursal  
				
				IF EXISTS (SELECT fecha_proceso FROM bdinteg:"informix".si_alta_ctes_indicadores_suc WHERE fecha_proceso = dfechaproceso AND sucursal = csucursal) THEN
					UPDATE bdinteg:"informix".si_alta_ctes_indicadores_suc 
					SET prospectos = iprospectos  
					WHERE fecha_proceso=dfechaproceso 
					AND sucursal=csucursal; 
				ELSE
					INSERT INTO bdinteg:"informix".si_alta_ctes_indicadores_suc(fecha_proceso, sucursal, titulares, prospectos, total, tot_prod_coppel, tot_prod_banco, tot_cop_bco, tot_sinproductos, tot_bca_basica, tot_bca_avanzada, user_insert, fecha_insert)
					VALUES(dfechaproceso, csucursal, 0, NVL(iprospectos,0), NVL(iprospectos,0),0,0,0,0,0,0, USER, CURRENT);
				END IF;										
			END FOREACH; 
			
			LET cEvento = 'GENERACION DE INDICADORES DE PRODUCTOS DE NUEVOS CLIENTES TITULARES';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;			
			FOREACH 
				SELECT DISTINCT sucursal 
				INTO csucursal
				FROM tmp_alta_ctes_titulares			
				FOREACH		
					SELECT numcte 
					INTO cnumcte
					FROM tmp_alta_ctes_titulares 
					WHERE sucursal=csucursal		
															
					LET iBanco = 0;
					LET iCoppel = 0;
								
					IF EXISTS(SELECT num_cte FROM bdicheq:"informix".sc_maechq WHERE num_cte=cnumcte AND sucursal=csucursal) THEN
						LET iBanco=1;			
					ELIF EXISTS(SELECT {+INDEX (bdisolic:"informix".ss_solicitudes idx_numctesolic)} numcte FROM bdisolic:"informix".ss_solicitudes WHERE numcte=cnumcte AND sucursal=csucursal AND tipo_solicitud<>'C') THEN
						LET iBanco=1;
					ELIF EXISTS (SELECT {+INDEX (bdinvers:"informix".sv_maeinv mai3)} num_cte FROM bdinvers:"informix".sv_maeinv WHERE num_cte=cnumcte AND sucursal=csucursal) THEN
						LET iBanco=1;
					END IF;				
					IF EXISTS(SELECT {+INDEX (bdisolic:"informix".ss_solicitudes idx_numctesolic)} numcte FROM bdisolic:"informix".ss_solicitudes WHERE numcte=cnumcte AND sucursal=csucursal AND tipo_solicitud='C') THEN
						LET iCoppel=1; 
					END IF;	
					IF (iBanco = 0 AND iCoppel=0 ) THEN --EN CASO QUE NO TENGA CUENTA DE BANCO NI DE COPPEL
						LET isinproductos = isinproductos + 1;  
					END IF;		
					IF (iBanco = 1 AND iCoppel=1 ) THEN
						LET ibanco_coppel=ibanco_coppel + 1;  
					ELSE
						LET isolo_coppel = isolo_coppel + iCoppel; 
						LET isolo_banco = isolo_banco + iBanco; 
					END IF;					
				END FOREACH;	
							
				LET cEvento = 'GENERACION DE INDICADORES DE BANCA BASICA/AVANZADA DE NUEVOS CLIENTES TITULARES';
				
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				SELECT NVL(SUM(bca_basica),0) AS bca_basica, NVL(SUM(bca_avanzada),0) AS bca_avanzada
				INTO ibca_basica, ibca_avanzada
				FROM (TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_bpiusuarios idx_bpi)} 
									CASE WHEN a.servicio= 1 THEN COUNT(a.numcte) END AS bca_basica,
									CASE WHEN a.servicio= 2 THEN COUNT(a.numcte) END AS bca_avanzada			
									FROM bdinteg:"informix".si_bpiusuarios a, tmp_alta_ctes_titulares b
									WHERE a.numcte=b.numcte
									AND a.suc_registro = b.sucursal 
									AND a.suc_registro= csucursal
									AND a.f_registro::DATE=dFechaproceso
									AND b.fecha_alta::DATE=dFechaproceso
									GROUP BY a.servicio))); 
				
				UPDATE bdinteg:"informix".si_alta_ctes_indicadores_suc 
				SET total =(isolo_coppel + isolo_banco + ibanco_coppel + isinproductos), tot_prod_coppel=isolo_coppel, tot_prod_banco=isolo_banco, tot_cop_bco=ibanco_coppel, tot_sinproductos = isinproductos, tot_bca_basica=ibca_basica, tot_bca_avanzada=ibca_avanzada  
				WHERE fecha_proceso=dFechaproceso 
				AND sucursal=csucursal;				
				LET ibca_basica=0;
				LET ibca_avanzada=0;						
				LET ibanco_coppel=0;
				LET isolo_coppel=0;
				LET isolo_banco=0;
				LET isinproductos=0;				
			END FOREACH;
						
			LET ibanco_coppel = 0;
			LET isolo_coppel = 0;
			LET isolo_banco = 0;
			LET isinproductos = 0;	
			--GENERA TOTALES GLOBALES DE ALTA DE CLIENTES.
			SELECT NVL(COUNT(*),0)
			INTO iTitulares
			FROM tmp_alta_ctes_titulares;
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} NVL(COUNT(*),0)
			INTO iProspectos
			FROM bdinteg:si_cliente
			WHERE tipo_cliente = '2'
			AND fecha_alta= dFechaproceso; 
							
			FOREACH --	AGREGAR LA SUCURSAL
				SELECT numcte, sucursal 
				INTO cnumcte, csucursal
				FROM tmp_alta_ctes_titulares
				
				LET iBanco = 0;
				LET iCoppel = 0;
				
				IF EXISTS(SELECT num_cte FROM bdicheq:"informix".sc_maechq WHERE num_cte=cnumcte AND sucursal=csucursal ) THEN
					LET iBanco=1;
				ELIF EXISTS(SELECT {+INDEX (bdisolic:"informix".ss_solicitudes idx_numctesolic)} numcte FROM bdisolic:"informix".ss_solicitudes WHERE numcte=cnumcte AND sucursal=csucursal AND tipo_solicitud<>'C') THEN
					LET iBanco=1;			
				ELIF EXISTS(SELECT {+INDEX (bdinvers:"informix".sv_maeinv mai3)} num_cte FROM bdinvers:"informix".sv_maeinv WHERE num_cte=cnumcte AND sucursal=csucursal ) THEN
					LET iBanco=1;
				END IF;			
				IF EXISTS(SELECT {+INDEX (bdisolic:"informix".ss_solicitudes idx_numctesolic)} numcte FROM bdisolic:"informix".ss_solicitudes WHERE numcte=cnumcte AND sucursal=csucursal AND tipo_solicitud='C') THEN
					LET iCoppel=1; 
				END IF;
				--CONTABILIZA LOS TOTALES DE CLIENTES POR PRODUCTO
				IF (iBanco = 0 AND iCoppel=0 ) THEN --EN CASO QUE NO TENGA CUENTA DE BANCO NI DE COPPEL
					LET isinproductos = isinproductos + 1;  
				END IF;	
				IF (iBanco = 1 AND iCoppel=1) THEN
					LET ibanco_coppel = ibanco_coppel + 1;  
				ELSE
					LET isolo_coppel = isolo_coppel + iCoppel; 
					LET isolo_banco = isolo_banco + iBanco; 
				END IF;			
			END FOREACH;
			
			LET cEvento = 'GENERACION DE INDICADORES DE TOTAL CLIENTES CON BANCA BASICA/AVANZADA';
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT NVL(SUM(bca_basica),0) AS bca_basica, NVL(SUM(bca_avanzada),0) AS bca_avanzada
			INTO ibca_basica, ibca_avanzada
			FROM (TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_bpiusuarios idx_bpi)} 
								CASE WHEN a.servicio= 1 THEN COUNT(a.numcte) END AS bca_basica,
								CASE WHEN a.servicio= 2 THEN COUNT(a.numcte) END AS bca_avanzada			
								FROM bdinteg:"informix".si_bpiusuarios a, tmp_alta_ctes_titulares b
								WHERE a.numcte=b.numcte
								AND a.suc_registro= b.sucursal 
								AND a.f_registro::DATE=dFechaproceso
								AND b.fecha_alta::DATE=dFechaproceso
								GROUP BY a.servicio)));  
								
			INSERT INTO bdinteg:"informix".si_alta_ctes_indicadores(fecha_proceso, titulares, prospectos, total, tot_prod_coppel, tot_prod_banco, tot_cop_bco, tot_sinproductos, tot_bca_basica, tot_bca_avanzada, user_insert, fecha_insert)
			VALUES (dFechaproceso, NVL(iTitulares,0), NVL(iProspectos,0), NVL(( iTitulares + iProspectos),0), NVL(isolo_coppel,0), NVL(isolo_banco,0) , NVL(ibanco_coppel,0), NVL(isinproductos,0), NVL(ibca_basica,0), NVL(ibca_avanzada,0), USER, CURRENT);

			IF DBINFO ('sqlca.sqlerrd2') = 0 THEN
				INSERT INTO bdinteg:"informix".si_alta_ctes_indicadores(fecha_proceso, titulares, prospectos, total, tot_prod_coppel, tot_prod_banco, tot_cop_bco, tot_sinproductos, tot_bca_basica, tot_bca_avanzada, user_insert, fecha_insert)
				VALUES(dFechaproceso, 0, 0, 0,0,0,0,0,0,0, USER, CURRENT);
			END IF;	
		END IF; 	
	
	COMMIT WORK;
	LET iEnTransaccion = 0;
	
	LET cProceso = 'INDICADORES DE MANTENIMIENTOS DIARIOS';
	LET cEvento	= 'OBTENCION DE MAX FECHA DE si_manntos_diarios';
	
	SELECT MAX(fecha_insert::DATE) 	
	INTO dmax_fecha_insert 	
	FROM bdinteg:"informix".si_manntos_diarios;
	
	LET dFechaproceso = dFechahoy - vcod_param_cels;
	--IF (vDiaSemana=1 AND dmax_fecha_insert IS NULL) OR (dFechaHoy::DATE - dmax_fecha_insert::DATE = vcod_param_cels) THEN --SEMANAL
	BEGIN WORK;
		LET iEnTransaccion = 1;
		IF NOT EXISTS(SELECT 1 FROM bdinteg:"informix".si_manntos_diarios WHERE fecha_proceso = dFechaProceso) THEN
			LET cEvento = 'GENERACION DE INDICADORES DE MANTENIMIENTOS DE HUELLAS';
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT {+INDEX (bdisitesp:"informix".se_sitespctetmphis idx_se_sitespctetmphis_ctefecha)} COUNT(a.numcte) 
			INTO imannto_huella
			FROM bdisitesp:se_sitespctetmphis a INNER JOIN bdinteg:"informix".si_cliente b ON a.numcte = b.numcte
			WHERE a.fecha= dFechaproceso
			AND b.tipo_cliente= '1'; 
			
			LET cEvento = 'GENERACION DE INDICADORES DE MANTENIMIENTOS DE DOMICILIOS';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;		
			SELECT {+INDEX (bdinteg:"informix".si_direcciones_actual idx_diract_cte3)} COUNT(dir.numcte) AS imannto_direcciones
			INTO imannto_direcciones	
			FROM bdinteg:"informix".si_direcciones_actual dir 
			INNER JOIN	bdinteg:si_cliente cte ON dir.numcte = cte.numcte
			WHERE dir.fecha_insert = dFechaproceso
			AND dir.secuencia > 1
			AND dir.tipo_dir IN('1','2','3') 
			AND cte.tipo_cliente= '1'  
			AND cte.fecha_insert <> dFechaproceso;	 
					
			LET cEvento = 'GENERACION DE INDICADORES DE MANTENIMIENTOS DE CORREOS';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT {+INDEX(bdinteg:"informix".si_correos idx_corr_cte_fhr_sec)} COUNT(a.numcte) 
			INTO imannto_correos 
			FROM bdinteg:"informix".si_correos a 
			INNER JOIN bdinteg:"informix".si_cliente b ON a.numcte = b.numcte 
			WHERE a.fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaproceso 
			AND a.secuencia > 1 
			AND b.tipo_cliente= '1'
			AND b.fecha_insert <> dFechaproceso; 
			
			LET cEvento = 'GENERACION DE INDICADORES DE MANTENIMIENTOS DE TELEFONOS';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT NVL(SUM(tel_casa),0) AS tel_casa, NVL(SUM(tel_celular),0) AS tel_celular, NVL(SUM(tel_oficina),0) AS tel_oficina, NVL(SUM(tel_otro),0) AS tel_otro
			INTO itel_casa, itel_celular, itel_oficina, itel_otro
			FROM (TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_telefonos_actual idx_telact_ctetipo )}  
								CASE WHEN a.tipo_tel= 1 THEN COUNT(telefono) END AS tel_casa,
								CASE WHEN a.tipo_tel= 2 THEN COUNT(telefono) END AS tel_celular,
								CASE WHEN a.tipo_tel= 3 THEN COUNT(telefono) END AS tel_oficina,
								CASE WHEN a.tipo_tel= 4 THEN COUNT(telefono) END AS tel_otro
								FROM bdinteg:si_telefonos_actual a INNER JOIN bdinteg:"informix".si_cliente b
								ON a.numcte=b.numcte
								WHERE b.fecha_insert <> dFechaproceso
								AND a.secuencia>1
								AND a.fecha_hora::DATE= dFechaproceso
								AND b.tipo_cliente= '1'
								GROUP BY a.tipo_tel)));	 
								
			
			LET cEvento = 'INSERCION DE INDICADORES EN SI_MANNTOS_DIARIOS';
			INSERT INTO bdinteg:"informix".si_manntos_diarios(fecha_proceso,huellas,direcciones,tel_casa,tel_cel,tel_ofi,tel_otro,correos,user_insert,fecha_insert)
			VALUES(dFechaproceso, NVL(imannto_huella,0), NVL(imannto_direcciones,0), NVL(itel_casa,0), NVL(itel_celular,0), NVL(itel_oficina,0), NVL(itel_otro,0), NVL(imannto_correos,0), USER, CURRENT);
			
			IF DBINFO ('sqlca.sqlerrd2') = 0 THEN
				INSERT INTO bdinteg:"informix".si_manntos_diarios(fecha_proceso,huellas,direcciones,tel_casa,tel_cel,tel_ofi,tel_otro,correos,user_insert,fecha_insert)
				VALUES(dFechaproceso, 0, 0, 0,0,0,0,0, USER, CURRENT);
			END IF;	
		 
			LET imannto_huella=0;
			LET imannto_direcciones=0;
			LET imannto_correos=0;
			LET itel_casa=0;
			LET itel_celular=0;
			LET itel_oficina=0;
			LET itel_otro=0;
			
			LET cEvento = 'GENERACION DE INDICADORES DE MANTENIMIENTOS DE HUELLAS POR SUCURSAL';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH				
				SELECT {+INDEX (bdisitesp:"informix".se_sitespctetmphis idx_se_sitespctetmphis_ctefecha)} a.sucursal, COUNT(a.numcte) 
				INTO csucursal, imannto_huella
				FROM bdisitesp:se_sitespctetmphis a INNER JOIN bdinteg:"informix".si_cliente b ON a.numcte = b.numcte
				WHERE a.fecha= dFechaproceso
				AND b.tipo_cliente ='1'	
				GROUP BY a.sucursal ORDER BY a.sucursal		
				IF EXISTS (SELECT sucursal FROM bdinteg:"informix".si_manntos_diarios_suc WHERE sucursal=csucursal AND fecha_proceso=dFechaproceso) THEN
					UPDATE bdinteg:"informix".si_manntos_diarios_suc 
					SET huellas = imannto_huella 
					WHERE sucursal = csucursal 
					AND fecha_proceso = dFechaproceso;
				ELSE 
					INSERT INTO bdinteg:"informix".si_manntos_diarios_suc(fecha_proceso,sucursal,huellas,direcciones,tel_casa,tel_cel,tel_ofi,tel_otro,correos, user_insert,fecha_insert)
					VALUES(dFechaproceso, csucursal, NVL(imannto_huella,0),0,0,0,0,0,0, USER, CURRENT);
				END IF;				
			END FOREACH;
			
			LET cEvento = 'GENERACION DE INDICADORES DE MANTENIMIENTOS DE DIRECCIONES POR SUCURSAL';

			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH
				SELECT {+INDEX (bdinteg:"informix".si_direcciones_actual idx_diract_cte3)}  b.sucursal, COUNT(a.numcte) AS imannto_direcciones
				INTO csucursal, imannto_direcciones
				FROM bdinteg:"informix".si_direcciones_actual a INNER JOIN bdinteg:"informix".si_cliente b
				ON a.numcte = b.numcte 
				WHERE a.fecha_insert = dFechaproceso 
				AND a.secuencia > 1
				AND b.fecha_insert <> dFechaproceso
				AND b.tipo_cliente ='1'
				GROUP BY b.sucursal ORDER BY 1	
				IF EXISTS (SELECT sucursal FROM bdinteg:"informix".si_manntos_diarios_suc WHERE sucursal=csucursal AND fecha_proceso=dFechaproceso) THEN --SQUENTIAL
					UPDATE bdinteg:"informix".si_manntos_diarios_suc 
					SET direcciones = imannto_direcciones 
					WHERE sucursal = csucursal 
					AND fecha_proceso = dFechaproceso;
				ELSE 
					INSERT INTO bdinteg:"informix".si_manntos_diarios_suc(fecha_proceso,sucursal,huellas,direcciones,tel_casa,tel_cel,tel_ofi,tel_otro,correos, user_insert,fecha_insert)
					VALUES(dFechaproceso,csucursal,0,NVL(imannto_direcciones,0),0,0,0,0,0, USER, CURRENT);
				END IF;			
			END FOREACH;
			
			LET cEvento = 'GENERACION DE INDICADORES DE MANTENIMIENTOS DE CORREOS POR SUCURSAL';

			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;			
			FOREACH	
				SELECT {+INDEX(bdinteg:"informix".si_correos idx_corr_cte_fhr_sec)}  b.sucursal, COUNT(a.numcte) AS imannto_correos
				INTO csucursal, imannto_correos
				FROM bdinteg:"informix".si_correos a INNER JOIN bdinteg:"informix".si_cliente b 
				ON a.numcte = b.numcte
				WHERE a.fecha_hora::DATETIME YEAR TO FRACTION::DATE= dFechaproceso 
				AND a.secuencia>1  
				AND b.fecha_insert <> dFechaproceso 
				AND b.tipo_cliente ='1'		
				GROUP BY b.sucursal 
				ORDER BY b.sucursal 	
				IF EXISTS (SELECT sucursal FROM bdinteg:"informix".si_manntos_diarios_suc WHERE sucursal=csucursal AND fecha_proceso=dFechaproceso) THEN
					UPDATE bdinteg:"informix".si_manntos_diarios_suc 
					SET correos = imannto_correos 
					WHERE sucursal = csucursal 
					AND fecha_proceso = dFechaproceso;
				ELSE 
					INSERT INTO bdinteg:"informix".si_manntos_diarios_suc(fecha_proceso, sucursal,huellas,direcciones,tel_casa,tel_cel,tel_ofi,tel_otro,correos,user_insert,fecha_insert)
					VALUES(dFechaproceso, csucursal,0,0,0,0,0,0, NVL(imannto_correos,0), USER, CURRENT);
				END IF;		
			END FOREACH;
			
			LET cEvento = 'GENERACION DE INDICADORES DE MANTENIMIENTOS DE TELEFONOS POR SUCURSAL';
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;			
			FOREACH
				SELECT sucursal, NVL(SUM(tel_casa),0), NVL(SUM(tel_celular),0), NVL(SUM(tel_oficina),0), NVL(SUM(tel_otro),0)
				INTO csucursal, itel_casa, itel_celular, itel_oficina, itel_otro 
				FROM TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_telefonos_actual idx_telact_ctetipo)} 
										CASE WHEN a.tipo_tel= 1 THEN COUNT(a.telefono) END AS tel_casa,
										CASE WHEN a.tipo_tel= 2 THEN COUNT(a.telefono) END AS tel_celular,
										CASE WHEN a.tipo_tel= 3 THEN COUNT(a.telefono) END AS tel_oficina,
										CASE WHEN a.tipo_tel= 4 THEN COUNT(a.telefono) END AS tel_otro, b.sucursal 
									FROM bdinteg:si_telefonos_actual a INNER JOIN bdinteg:"informix".si_cliente b 
									ON a.numcte=b.numcte
									WHERE b.fecha_insert <> dFechaproceso
									AND a.secuencia>1
									AND a.fecha_hora::DATE= dFechaproceso
									AND b.tipo_cliente ='1'
									GROUP BY a.tipo_tel, b.sucursal))
									GROUP BY sucursal ORDER BY sucursal			
				
				LET cEvento = 'INSERCION DE INDICADORES EN SI_MANNTOS_DIARIOS_SUC';
				IF EXISTS (SELECT sucursal FROM bdinteg:"informix".si_manntos_diarios_suc WHERE sucursal=csucursal AND fecha_proceso=dFechaproceso) THEN
					UPDATE bdinteg:"informix".si_manntos_diarios_suc 
					SET tel_casa=itel_casa, tel_cel=itel_celular, tel_ofi=itel_oficina,  tel_otro=itel_otro 
					WHERE sucursal=csucursal 
					AND fecha_proceso=dFechaproceso;
				ELSE 
					INSERT INTO bdinteg:"informix".si_manntos_diarios_suc(fecha_proceso, sucursal,huellas,direcciones,tel_casa,tel_cel,tel_ofi,tel_otro,correos,user_insert,fecha_insert)
					VALUES(dFechaproceso, csucursal, 0, 0, NVL(itel_casa,0),NVL(itel_celular,0),NVL(itel_oficina,0),NVL(itel_otro,0), 0,USER, CURRENT);
				END IF;				
			END FOREACH;	
		END IF;
	COMMIT WORK;
	LET iEnTransaccion = 0;
	
	--INDICADORES DE CORREOS Y TELEFONOS DE CLIENTES NUEVOS
	LET cProceso = 'INDICADORES DE CORREOS/TELEFONOS DE MANTENIMIENTOS/CLIENTES NUEVOS';
	LET cEvento	= 'OBTENCION DE MAX FECHA DE si_indicadores_ctes_nvos_det';
		
	SELECT MAX(fecha_insert::DATE) 
	INTO dmax_fecha_insert
	FROM bdinteg:si_indicadores_ctes_nvos_det;
	
	LET dFechaproceso = dFechahoy - 1;

	
	BEGIN WORK;  
		LET iEnTransaccion = 1;
		IF NOT EXISTS(SELECT 1 FROM bdinteg:si_indicadores_ctes_nvos_det WHERE fecha = dFechaProceso) THEN			
			LET cEvento	= 'GENERACION DE TABLA TEMPORAL tmp_sucursal_ejecut';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT DISTINCT a.sucursal, a.nombre AS nom_suc, b.ejecutivo, b.nombre AS nom_emp
			FROM bdinteg:"informix".si_sucursales a, bdinteg:"informix".si_ejecut b, tmp_alta_ctes_titulares c
			WHERE a.sucursal = b.sucursal
			AND b.ejecutivo = c.numemp
			INTO TEMP tmp_sucursal_ejecut
			WITH NO LOG;
			
			LET cEvento	= 'GENERACION DE INDICE DE TABLA TEMPORAL tmp_sucursal_ejecut';
			CREATE INDEX "informix".idx_tmp_suc_ejecut ON tmp_sucursal_ejecut (ejecutivo, sucursal);
			
			LET cEvento	= 'INSERCION DE INDICADORES DE CORREOS DE NUEVOS CLIENTES TITULARES';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdinteg:si_indicadores_ctes_nvos_det( tipo_movto, fecha, sucursal, ejecutivo, altas_ctes, correo_cap, correo_val, correo_inval, correo_pen, correo_rep, 
												  telcasa_cap, telcasa_val, telcasa_inval, telcasa_pen, telcasa_rep, 
												  telcel_cap, telcel_val, telcel_inval, telcel_pen, telcel_ver, telcel_rep, 
												  telotro_cap, telotro_val, telotro_inval, telotro_pen, telotro_rep)
			SELECT '1', dFechaproceso, b.sucursal, a.numemp, a.altas, a.total_correos, a.validos, a.invalidos, a.sin_validar, a.repetidos, 
					0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			FROM TABLE(MULTISET(
			SELECT a.numemp, a.altas, a.total_correos, a.validos, a.invalidos, a.sin_validar, NVL(b.repetidos,0) AS repetidos
			FROM 
			TABLE(MULTISET(SELECT numemp, SUM(NVL(altas,0)) AS altas, SUM(NVL(total_correos,0)) AS total_correos, SUM(NVL(validos,0)) AS validos, SUM(NVL(invalidos,0)) AS invalidos, SUM(NVL(sin_validar,0)) AS sin_validar
						   FROM TABLE(MULTISET(SELECT a.numemp, a.numcte, NVL(COUNT(a.numcte),0) AS altas , NVL(b.total_correos, 0) AS total_correos, NVL(b.validos,0) AS validos, NVL(b.invalidos,0) AS invalidos, NVL(b.sin_validar,0) AS sin_validar
											   FROM tmp_alta_ctes_titulares a 
											   LEFT JOIN
											   TABLE(MULTISET(SELECT user_insert, numcte, NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) AS total_correos, NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos, NVL(SUM(sin_validar),0) AS sin_validar
											   FROM TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_correos idx_corr_status)} user_insert,numcte,
																	   CASE WHEN valido = '1' THEN COUNT(correo_elec) ELSE 0 END AS validos,
																	   CASE WHEN valido = '0' THEN COUNT(correo_elec) ELSE 0 END AS invalidos,
																	   CASE WHEN valido IS NULL THEN COUNT(correo_elec) ELSE 0  END AS sin_validar
																	FROM bdinteg:"informix".si_correos
																	WHERE fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaproceso
																	AND secuencia = 1
																	GROUP BY user_insert, numcte, valido ))
																	GROUP BY user_insert, numcte)) b
											   ON a.numcte = b.numcte
											   GROUP BY a.numemp, a.numcte,b.total_correos, b.validos, b.invalidos, b.sin_validar))
						   GROUP BY numemp)) a
						   LEFT JOIN 
						   TABLE(MULTISET(SELECT numemp, SUM(repetidos) AS repetidos FROM TABLE(MULTISET(SELECT a.user_insert AS numemp, a.correo_elec, COUNT(a.correo_elec) AS repetidos
										  FROM bdinteg:"informix".si_correos a, tmp_alta_ctes_titulares b
										  WHERE a.numcte=b.numcte
										  AND a.fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaproceso
										  GROUP BY 1,2
										  HAVING COUNT(a.correo_elec) >1)) GROUP BY 1)) b
						   ON a.numemp = b.numemp ))a, tmp_sucursal_ejecut b
			WHERE a.numemp = b.ejecutivo;
			
			LET cEvento	= 'OBTENCION DE INDICADORES DE TELEFONOS DE NUEVOS CLIENTES TITULARES';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT '1' AS tipo_movto, dFechaproceso AS fecha, a.numemp, 
				   NVL(SUM(a.total_tel_casa), 0) AS total_tel_casa, NVL(SUM(a.total_tel_casa_val),0) AS total_tel_casa_val, NVL(SUM(a.total_tel_casa_inval),0) AS total_tel_casa_inval, NVL(SUM(a.total_tel_casa_pen),0) AS total_tel_casa_pen, NVL(b.tel_casa_rep,0) AS total_tel_casa_rep,
				   NVL(SUM(a.total_celular), 0) AS total_celular, NVL(SUM(a.total_celular_val),0) AS total_celular_val, NVL(SUM(a.total_celular_inval),0) AS total_celular_inval, NVL(SUM(a.total_celular_pen),0) AS total_celular_pen, NVL(SUM(a.verificados),0) AS verificados, NVL(b.tel_cel_rep,0) AS total_tel_cel_rep,
				   NVL(SUM(a.total_otro), 0) AS total_otro, NVL(SUM(a.total_otro_val),0) AS total_otro_val, NVL(SUM(a.total_otro_inval),0) AS total_otro_inval, NVL(SUM(a.total_otro_pen),0) AS total_otro_pen, NVL(b.tel_otro_rep,0) AS total_tel_otro_rep
			FROM TABLE(MULTISET(
			SELECT a.numemp, a.numcte, NVL(SUM(b.total_tel_casa), 0) AS total_tel_casa, NVL(SUM(b.total_tel_casa_val),0) AS total_tel_casa_val, NVL(SUM(b.total_tel_casa_inval),0) AS total_tel_casa_inval, NVL(SUM(b.total_tel_casa_pen),0) AS total_tel_casa_pen,
				   NVL(SUM(b.total_celular), 0) AS total_celular, NVL(SUM(b.total_celular_val),0) AS total_celular_val, NVL(SUM(b.total_celular_inval),0) AS total_celular_inval, NVL(SUM(b.total_celular_pen),0) AS total_celular_pen, NVL(SUM(b.verificados),0) AS verificados,
				   NVL(SUM(b.total_otro), 0) AS total_otro, NVL(SUM(b.total_otro_val),0) AS total_otro_val, NVL(SUM(b.total_otro_inval),0) AS total_otro_inval, NVL(SUM(b.total_otro_pen),0) AS total_otro_pen
			FROM tmp_alta_ctes_titulares a 
			LEFT JOIN
			TABLE(MULTISET(SELECT user_insert, numcte,
									CASE WHEN tipo_tel = '1' THEN NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) ELSE 0 END AS total_tel_casa,
									CASE WHEN tipo_tel = '1' THEN NVL(SUM(validos),0) ELSE 0 END AS total_tel_casa_val,
									CASE WHEN tipo_tel = '1' THEN NVL(SUM(invalidos),0) ELSE 0 END AS total_tel_casa_inval,
									CASE WHEN tipo_tel = '1' THEN NVL(SUM(sin_validar),0) ELSE 0 END AS total_tel_casa_pen,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) ELSE 0 END AS total_celular,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(validos),0) ELSE 0 END AS total_celular_val,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(validos),0) ELSE 0 END AS total_celular_val,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(invalidos),0) ELSE 0 END AS total_celular_inval,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(sin_validar),0) ELSE 0 END AS total_celular_pen,
									NVL(SUM(verificado),0) AS verificados,
									CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) ELSE 0 END AS total_otro,
									CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(validos),0) ELSE 0 END AS total_otro_val,
									CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(invalidos),0) ELSE 0 END AS total_otro_inval,
									CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(sin_validar),0) ELSE 0 END AS total_otro_pen
									FROM TABLE(MULTISET(SELECT a.user_insert, a.numcte, a.tipo_tel, a.validos, a.invalidos, a.sin_validar, b.verificado
														FROM
														TABLE(MULTISET(SELECT user_insert,numcte,tipo_tel,
															   CASE WHEN cofetel = 'V' THEN COUNT(telefono) ELSE 0 END AS validos,
															   CASE WHEN cofetel = 'F' THEN COUNT(telefono) ELSE 0 END AS invalidos,
															   CASE WHEN cofetel IS NULL THEN COUNT(telefono)ELSE 0  END AS sin_validar
														FROM bdinteg:"informix".si_telefonos
														WHERE fecha_hora::DATE = dFechaproceso
														GROUP BY user_insert, numcte, tipo_tel, cofetel)) a LEFT JOIN
														TABLE(MULTISET(SELECT user_insert,numcte,tipo_tel, COUNT(telefono) AS verificado
																	   FROM bdinteg:"informix".si_telefonos
																	   WHERE fecha_hora::DATE = dFechaproceso
																	   AND verificado = 'V' 
																	   AND tipo_tel = '2'
																	   GROUP BY user_insert, numcte, tipo_tel)) b
														ON a.user_insert = b.user_insert AND a.numcte = b.numcte AND a.tipo_tel = b.tipo_tel
												))
									GROUP BY user_insert, numcte, tipo_tel))b
			ON a.numcte = b.numcte GROUP BY 1,2)) a 
			LEFT JOIN
			TABLE(MULTISET(SELECT numemp, SUM(NVL(tel_casa_rep,0)) AS tel_casa_rep, SUM(NVL(tel_cel_rep,0)) AS tel_cel_rep, SUM(NVL(tel_otro_rep,0)) AS tel_otro_rep
							   FROM 
							   TABLE(MULTISET(SELECT b.numemp AS numemp, a.telefono,
													 CASE WHEN a.tipo_tel = '1' THEN COUNT(a.telefono) ELSE 0 END AS tel_casa_rep,
													 CASE WHEN a.tipo_tel = '2' THEN COUNT(a.telefono) ELSE 0 END AS tel_cel_rep,
													 CASE WHEN a.tipo_tel NOT IN('1','2') THEN COUNT(a.telefono) ELSE 0 END AS tel_otro_rep
											  FROM bdinteg:"informix".si_telefonos a, tmp_alta_ctes_titulares b
											  WHERE a.numcte=b.numcte
											  AND a.user_insert = b.numemp
											  AND a.fecha_hora::DATE = dFechaproceso
											  GROUP BY b.numemp, a.telefono, a.tipo_tel
											  HAVING COUNT(a.telefono) >1))
							   GROUP BY 1)) b
			ON a.numemp = b.numemp
			GROUP BY 1, 2, 3, b.tel_casa_rep, tel_cel_rep, b.tel_otro_rep
			INTO TEMP tmp_telefonos_ctenvos WITH NO LOG;
			
			LET cEvento	= 'UNION DE INDICADORES DE TELEFONOS Y CORREOS DE NUEVOS CLIENTES TITULARES';
			MERGE INTO bdinteg:si_indicadores_ctes_nvos_det AS a 
			USING tmp_telefonos_ctenvos AS b
			ON a.tipo_movto = b.tipo_movto AND a.ejecutivo = b.numemp AND a.fecha = b.fecha
			WHEN MATCHED THEN UPDATE
			SET telcasa_cap = total_tel_casa, telcasa_val = total_tel_casa_val, telcasa_inval = total_tel_casa_inval, telcasa_pen = total_tel_casa_pen, telcasa_rep = total_tel_casa_rep, 
				telcel_cap = total_celular, telcel_val = total_celular_val, telcel_inval = total_celular_inval, telcel_pen = total_celular_pen, telcel_ver = verificados, telcel_rep = total_tel_cel_rep,
				telotro_cap = total_otro, telotro_val = total_otro_val, telotro_inval = total_otro_inval, telotro_pen = total_otro_pen, telotro_rep = total_tel_otro_rep;
			
			LET cEvento	= 'GENERACION DE TABLA TEMPORAL tmp_sucursal_ejecut_mantto';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT DISTINCT a.sucursal, a.nombre AS nom_suc, b.ejecutivo, b.nombre AS nom_emp
			FROM bdinteg:"informix".si_sucursales a, bdinteg:"informix".si_ejecut b, tmp_mantto_ctes_titulares c
			WHERE a.sucursal = b.sucursal
			AND b.ejecutivo = c.numemp
			INTO TEMP tmp_sucursal_ejecut_mantto
			WITH NO LOG;			

    CREATE INDEX "informix".tmp_sucursal_ejecut_mantto1 ON tmp_sucursal_ejecut_mantto (ejecutivo);
    CREATE INDEX "informix".tmp_sucursal_ejecut_mantto2 ON tmp_sucursal_ejecut_mantto (sucursal);
			
			LET cEvento	= 'ACTUALIZACION DE TABLA TEMPORAL tmp_sucursal_ejecut';
			MERGE INTO tmp_sucursal_ejecut a
				USING tmp_sucursal_ejecut_mantto b
				ON a.ejecutivo= b.ejecutivo
				AND a.sucursal = b.sucursal
			WHEN NOT MATCHED THEN
				INSERT (a.sucursal, a.nom_suc, a.ejecutivo, a.nom_emp)
					VALUES 
						(b.sucursal, b.nom_suc, b.ejecutivo, b.nom_emp);

			LET cEvento	= 'OBTENCION DE INDICADORES DE CORREOS CLIENTES TITULARES CON MANTENIMIENTO';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;			
			INSERT INTO bdinteg:si_indicadores_ctes_nvos_det( tipo_movto, fecha, sucursal, ejecutivo, altas_ctes, correo_cap, correo_val, correo_inval, correo_pen, correo_rep, 
												  telcasa_cap, telcasa_val, telcasa_inval, telcasa_pen, telcasa_rep, 
												  telcel_cap, telcel_val, telcel_inval, telcel_pen, telcel_ver, telcel_rep, 
												  telotro_cap, telotro_val, telotro_inval, telotro_pen, telotro_rep)
			SELECT DISTINCT '2' AS tipo_mov, dFechaproceso AS fecha, b.sucursal, a.numemp, a.altas, a.total_correos, a.validos, a.invalidos, a.sin_validar, a.repetidos, 
					0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			FROM TABLE(MULTISET(
			SELECT a.numemp, a.altas, a.total_correos, a.validos, a.invalidos, a.sin_validar, NVL(b.repetidos,0) AS repetidos
			FROM 
			TABLE(MULTISET(SELECT numemp, SUM(NVL(altas,0)) AS altas, SUM(NVL(total_correos,0)) AS total_correos, SUM(NVL(validos,0)) AS validos, SUM(NVL(invalidos,0)) AS invalidos, SUM(NVL(sin_validar,0)) AS sin_validar
						   FROM TABLE(MULTISET(SELECT a.numemp, a.numcte, NVL(COUNT(a.numcte),0) AS altas , NVL(b.total_correos, 0) AS total_correos, NVL(b.validos,0) AS validos, NVL(b.invalidos,0) AS invalidos, NVL(b.sin_validar,0) AS sin_validar
											   FROM tmp_mantto_ctes_titulares a 
											   LEFT JOIN
											   TABLE(MULTISET(SELECT user_insert, numcte, NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) AS total_correos, NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos, NVL(SUM(sin_validar),0) AS sin_validar
											   FROM TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_correos idx_corr_status)} user_insert,numcte,
																	   CASE WHEN valido = '1' THEN COUNT(correo_elec) ELSE 0 END AS validos,
																	   CASE WHEN valido = '0' THEN COUNT(correo_elec) ELSE 0 END AS invalidos,
																	   CASE WHEN valido IS NULL THEN COUNT(correo_elec) ELSE 0  END AS sin_validar
																	FROM bdinteg:"informix".si_correos
																	WHERE fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaproceso
																	GROUP BY user_insert, numcte, valido ))
																	GROUP BY user_insert, numcte)) b
											   ON a.numcte = b.numcte
											   GROUP BY a.numemp, a.numcte,b.total_correos, b.validos, b.invalidos, b.sin_validar))
						   GROUP BY numemp)) a
						   LEFT JOIN 
						   TABLE(MULTISET(SELECT numemp, SUM(repetidos) AS repetidos FROM TABLE(MULTISET(SELECT a.user_insert AS numemp, a.correo_elec, COUNT(a.correo_elec) AS repetidos
                                          FROM bdinteg:"informix".si_correos a, tmp_mantto_ctes_titulares b
                                          WHERE a.numcte=b.numcte
                                          AND a.fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaproceso
                                          GROUP BY 1,2
                                          HAVING COUNT(a.correo_elec) >1)) GROUP BY 1)) b
						   ON a.numemp = b.numemp ))a, tmp_sucursal_ejecut_mantto b
			WHERE a.numemp = b.ejecutivo;
			
			LET cEvento	= 'OBTENCION DE INDICADORES DE TELEFONOS CLIENTES TITULARES CON MANTENIMIENTO';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;			
			SELECT '2' AS tipo_movto, dFechaproceso AS fecha, a.numemp, 
				   NVL(SUM(a.total_tel_casa), 0) AS total_tel_casa, NVL(SUM(a.total_tel_casa_val),0) AS total_tel_casa_val, NVL(SUM(a.total_tel_casa_inval),0) AS total_tel_casa_inval, NVL(SUM(a.total_tel_casa_pen),0) AS total_tel_casa_pen, NVL(b.tel_casa_rep,0) AS total_tel_casa_rep,
				   NVL(SUM(a.total_celular), 0) AS total_celular, NVL(SUM(a.total_celular_val),0) AS total_celular_val, NVL(SUM(a.total_celular_inval),0) AS total_celular_inval, NVL(SUM(a.total_celular_pen),0) AS total_celular_pen, NVL(SUM(a.verificados),0) AS verificados, NVL(b.tel_cel_rep,0) AS total_tel_cel_rep,
				   NVL(SUM(a.total_otro), 0) AS total_otro, NVL(SUM(a.total_otro_val),0) AS total_otro_val, NVL(SUM(a.total_otro_inval),0) AS total_otro_inval, NVL(SUM(a.total_otro_pen),0) AS total_otro_pen, NVL(b.tel_otro_rep,0) AS total_tel_otro_rep
			FROM TABLE(MULTISET(
			SELECT a.numemp, a.numcte, NVL(SUM(b.total_tel_casa), 0) AS total_tel_casa, NVL(SUM(b.total_tel_casa_val),0) AS total_tel_casa_val, NVL(SUM(b.total_tel_casa_inval),0) AS total_tel_casa_inval, NVL(SUM(b.total_tel_casa_pen),0) AS total_tel_casa_pen,
				   NVL(SUM(b.total_celular), 0) AS total_celular, NVL(SUM(b.total_celular_val),0) AS total_celular_val, NVL(SUM(b.total_celular_inval),0) AS total_celular_inval, NVL(SUM(b.total_celular_pen),0) AS total_celular_pen, NVL(SUM(b.verificados),0) AS verificados,
				   NVL(SUM(b.total_otro), 0) AS total_otro, NVL(SUM(b.total_otro_val),0) AS total_otro_val, NVL(SUM(b.total_otro_inval),0) AS total_otro_inval, NVL(SUM(b.total_otro_pen),0) AS total_otro_pen
			FROM tmp_mantto_ctes_titulares a 
			LEFT JOIN
			TABLE(MULTISET(SELECT user_insert, numcte,
									CASE WHEN tipo_tel = '1' THEN NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) ELSE 0 END AS total_tel_casa,
									CASE WHEN tipo_tel = '1' THEN NVL(SUM(validos),0) ELSE 0 END AS total_tel_casa_val,
									CASE WHEN tipo_tel = '1' THEN NVL(SUM(invalidos),0) ELSE 0 END AS total_tel_casa_inval,
									CASE WHEN tipo_tel = '1' THEN NVL(SUM(sin_validar),0) ELSE 0 END AS total_tel_casa_pen,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) ELSE 0 END AS total_celular,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(validos),0) ELSE 0 END AS total_celular_val,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(validos),0) ELSE 0 END AS total_celular_val,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(invalidos),0) ELSE 0 END AS total_celular_inval,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(sin_validar),0) ELSE 0 END AS total_celular_pen,
									NVL(SUM(verificado),0) AS verificados,
									CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) ELSE 0 END AS total_otro,
									CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(validos),0) ELSE 0 END AS total_otro_val,
									CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(invalidos),0) ELSE 0 END AS total_otro_inval,
									CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(sin_validar),0) ELSE 0 END AS total_otro_pen
									FROM TABLE(MULTISET(SELECT a.user_insert, a.numcte, a.tipo_tel, a.validos, a.invalidos, a.sin_validar, b.verificado
														FROM
														TABLE(MULTISET(SELECT user_insert,numcte,tipo_tel,
															   CASE WHEN cofetel = 'V' THEN COUNT(telefono) ELSE 0 END AS validos,
															   CASE WHEN cofetel = 'F' THEN COUNT(telefono) ELSE 0 END AS invalidos,
															   CASE WHEN cofetel IS NULL THEN COUNT(telefono)ELSE 0  END AS sin_validar
														FROM bdinteg:"informix".si_telefonos
														WHERE fecha_hora::DATE = dFechaproceso
														GROUP BY user_insert, numcte, tipo_tel, cofetel)) a LEFT JOIN
														TABLE(MULTISET(SELECT user_insert,numcte,tipo_tel, COUNT(telefono) AS verificado
																	   FROM bdinteg:"informix".si_telefonos
																	   WHERE fecha_hora::DATE = dFechaproceso
																	   AND verificado = 'V' 
																	   AND tipo_tel = '2'
																	   GROUP BY user_insert, numcte, tipo_tel)) b
														ON a.user_insert = b.user_insert AND a.numcte = b.numcte AND a.tipo_tel = b.tipo_tel
												))
									GROUP BY user_insert, numcte, tipo_tel))b
			ON a.numcte = b.numcte GROUP BY 1,2)) a 
			LEFT JOIN
			TABLE(MULTISET(SELECT numemp, SUM(NVL(tel_casa_rep,0)) AS tel_casa_rep, SUM(NVL(tel_cel_rep,0)) AS tel_cel_rep, SUM(NVL(tel_otro_rep,0)) AS tel_otro_rep
							   FROM 
							   TABLE(MULTISET(SELECT b.numemp AS numemp, a.telefono,
													 CASE WHEN a.tipo_tel = '1' THEN COUNT(a.telefono) ELSE 0 END AS tel_casa_rep,
													 CASE WHEN a.tipo_tel = '2' THEN COUNT(a.telefono) ELSE 0 END AS tel_cel_rep,
													 CASE WHEN a.tipo_tel NOT IN('1','2') THEN COUNT(a.telefono) ELSE 0 END AS tel_otro_rep
											  FROM bdinteg:"informix".si_telefonos a, tmp_mantto_ctes_titulares b
											  WHERE a.numcte=b.numcte
											  AND a.user_insert = b.numemp
											  AND a.fecha_hora::DATE = dFechaproceso
											  GROUP BY b.numemp, a.telefono, a.tipo_tel
											  HAVING COUNT(a.telefono) >1))
							   GROUP BY 1)) b
			ON a.numemp = b.numemp
			GROUP BY 1, 2, 3, b.tel_casa_rep, tel_cel_rep, b.tel_otro_rep
			INTO TEMP tmp_telefonos_ctesmantto WITH NO LOG;

    CREATE INDEX "informix".tmp_telefonos_ctesmantto1 ON tmp_telefonos_ctesmantto (tipo_movto);
    CREATE INDEX "informix".tmp_telefonos_ctesmantto2 ON tmp_telefonos_ctesmantto (numemp);
    CREATE INDEX "informix".tmp_telefonos_ctesmantto3 ON tmp_telefonos_ctesmantto (fecha);

		
			LET cEvento	= 'UNION DE INDICADORES DE TELEFONOS Y CORREOS DE CLIENTES CON MANTENIMIENTO';
			MERGE INTO bdinteg:si_indicadores_ctes_nvos_det AS a 
			USING tmp_telefonos_ctesmantto AS b
			ON a.tipo_movto = b.tipo_movto AND a.ejecutivo = b.numemp AND a.fecha = b.fecha
			WHEN MATCHED THEN UPDATE
			SET telcasa_cap = total_tel_casa, telcasa_val = total_tel_casa_val, telcasa_inval = total_tel_casa_inval, telcasa_pen = total_tel_casa_pen, telcasa_rep = total_tel_casa_rep, 
				telcel_cap = total_celular, telcel_val = total_celular_val, telcel_inval = total_celular_inval, telcel_pen = total_celular_pen, telcel_ver = verificados, telcel_rep = total_tel_cel_rep,
				telotro_cap = total_otro, telotro_val = total_otro_val, telotro_inval = total_otro_inval, telotro_pen = total_otro_pen, telotro_rep = total_tel_otro_rep;
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;	
			
			LET cEvento	= 'OBTENCION DE TOTALES DE INDICADORES DE TELEFONOS Y CORREOS DE NUEVOS CLIENTES/MANTENIMIENTOS';
			INSERT INTO bdinteg:si_indicadores_ctes_nvos (tipo_movto, fecha, altas_ctes, correo_cap, correo_val, correo_inval, correo_pen, correo_rep, 
														  telcasa_cap, telcasa_val, telcasa_inval, telcasa_pen, telcasa_rep, 
														  telcel_cap, telcel_val, telcel_inval, telcel_pen, telcel_ver, telcel_rep, 
														  telotro_cap, telotro_val, telotro_inval, telotro_pen, telotro_rep) 
			SELECT tipo_movto, fecha, NVL(SUM(altas_ctes),0), NVL(SUM(correo_cap),0), NVL(SUM(correo_val),0),  NVL(SUM(correo_inval),0), NVL(SUM(correo_pen),0), NVL(SUM(correo_rep),0), 
				   NVL(SUM(telcasa_cap),0), NVL(SUM(telcasa_val),0), NVL(SUM(telcasa_inval),0), NVL(SUM(telcasa_pen),0), NVL(SUM(telcasa_rep),0), 
				   NVL(SUM(telcel_cap),0), NVL(SUM(telcel_val),0), NVL(SUM(telcel_inval),0), NVL(SUM(telcel_pen),0), NVL(SUM(telcel_ver),0), NVL(SUM(telcel_rep),0), 
				   NVL(SUM(telotro_cap),0), NVL(SUM(telotro_val),0), NVL(SUM(telotro_inval),0), NVL(SUM(telotro_pen),0), NVL(SUM(telotro_rep),0)
			FROM si_indicadores_ctes_nvos_det
			WHERE fecha = dFechaproceso
			--AND tipo_movto = '1'
			GROUP BY 1,2;				
		END IF;
	COMMIT WORK;
	LET iEnTransaccion = 0;
	
	LET cProceso = 'REPLICA DE INFORMACION A BDIBI';		
	LET cEvento	= 'OBTIENE VALOR FLAG PARA GRABAR BDIBI';
	SELECT NVL(valor,0)::INTEGER 
	INTO iCod_param_ind_com 
	FROM bdinteg:si_param WHERE cod_param = 343;
				
	IF iCod_param_ind_com = 1 THEN
		
		IF NOT EXISTS (SELECT 1 FROM bdibi@stag_ids1170:"informix".bi_controlprocesos WHERE fecha_carga = dFechaProceso AND flagfinalizado = 'V' AND id_proc = 2 ) THEN
		--IF NOT EXISTS (SELECT 1 FROM bdibi@coppel_tcp:"informix".bi_controlprocesos WHERE fecha_carga = dFechaProceso AND flagfinalizado = 'V') THEN 
			LET cEvento	= 'EJECUCION DE sp_replica_indicadores_ctes_bi';
			
			EXECUTE PROCEDURE "informix".sp_replica_indicadores_ctes_bi(dFechaProceso)
			INTO cCodRetSP, cVarDataErrSP;
			
			IF cCodRetSP <> '000000' THEN
				INSERT INTO si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
				VALUES (dFechaProceso, cProceso, cEvento, cCodRetSP, cVarDataErrSP);
                
                LET vCodRet = cCodRetSP;
                LET cVarDataErr = cVarDataErrSP;                
                
			END IF;	
		END IF;
	END IF;
	
	IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_alta_ctes_titulares') THEN
		DROP TABLE tmp_alta_ctes_titulares;
	END IF;
	
	IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_sucursal_ejecut') THEN
		DROP TABLE tmp_sucursal_ejecut;
	END IF;
	
	IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_telefonos_ctenvos') THEN
		DROP TABLE tmp_telefonos_ctenvos;
	END IF;
	
	IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_mantto_ctes_titulares') THEN
		DROP TABLE tmp_mantto_ctes_titulares;
	END IF;
	
	IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_telefonos_ctesmantto') THEN
		DROP TABLE tmp_telefonos_ctesmantto;
	END IF;
		
	IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_sucursal_ejecut_mantto') THEN
		DROP TABLE tmp_sucursal_ejecut_mantto;
	END IF;
	
	RETURN vCodRet,cVarDataErr;		
END;
END PROCEDURE
DOCUMENT
'REALIZA:Estadísticas sobre celulares y correos electrónicos repetidos',
'EQUIPO:Análisis y diseño de Mannto.4',
'FECHA:01/07/2014',
'VERSION:20140701',
'MODIFICO: José Cristóbal Hernández Fierro',
'DESCRIPCION: Se sustituyo el valor de cod_param de SMS a 312',
'SOLICITA:José Ángel López Adams',
'Fecha: 2014-07-08',
'BASE DE DATOS:Bdinteg',
'MODIFICO: Rocio Karina Márquez Coronel',
'DESCRIPCION: Se agregó una validación a las consultas donde status_tel y status_correo sean Activos ',
'FECHA: 2014-07-15',
'MODIFICO: Rocio Karina Márquez Coronel',
'DESCRIPCION: Se cambio a la tabla si_telefonos_actual en la sección de celulares repetidos y se modifica para que no inserte registro si no ay repetidos ',
'FECHA: 2014-08-07',
'MODIFICO: Rocio Karina Márquez Coronel',
'DESCRIPCION: Estadisticas de SMS: se modifica que en el campo id_mensaje es igual a OFI_AVSMS ',
'Estadisticas de celulares repetidos: Se modifica el query para obtener la información de las tablas temporales generadas anteriormente (tmp_si_telefonos_actual, tmp_si_cliente) para obtener los celulares válidos e invalidos, de la misma forma en el query para generar la información de los celulares repetidos. Se cambia de la tabla si_telefonos a la si_telefonos_actual la extración de la información',
'Estadisticas de celulares y correos repetidos: Se modifica para que no agregue el registro cuando NO exista inf. en los correos y celulares repetidos',
'Estadisticas de alta de clientes: Obtiene el total de clientes titulares y prospectos, agrupados por fecha y por sucursal',
'Estadisticas de clientes titulares por tipo de producto ofertado o aperturado: Del total de clientes titulares, se deberán obtener cifras en cuanto a la oferta de productos, para esto se deberá obtener cuantos aperturaron (o al menos solicitaron) Credito Coppel, cuantos aperturaron (o al menos solicitaron) productos BanCoppel, y cuantos aperturaron (o al menos solicitaron) productos de ambas empresas y a cuantos se les dio alta el servicio de banca electrónica básica y banca electrónica avanzada',
'Estadisticas de Mantenimientos: Obtienen cifras diarias de los mantenimientos a huellas, domicilios, correos y teléfonos',
'FECHA: 2015-04-24',
'MODIFICO: Ingrid Pamela Cazarez Villegas',
'DESCRIPCION: Se modifica proceso para obtener nuevos indicadores de comportamiento de promotores de sucursal, así como también se agrega bandera para insertar en BDIBI.',
'FECHA: 2015-04-30',
'MODIFICO: Ingrid Pamela Cazarez Villegas',
'DESCRIPCION: Se modifica campo para obterner información correcta de telefonos celulares repetidos.',
'FECHA: 2015-05-05',
'MODIFICO: Ingrid Pamela Cazarez Villegas',
'DESCRIPCION: Se modifica consulta que obtiene información de correos y consulta que obtiene información de telefonos para obtener información correcta de ambos.',
'FECHA: 2015-05-15',
'MODIFICO: Ingrid Pamela Cázarez Villegas',
'DESCRIPCION: Se modifica proceso para obtener nuevos indicadores de comportamiento de promotores de sucursal que realizaron mantenimiento de correos electrónicos y teléfonos a clientes en sucursal.';

CREATE PROCEDURE "informix".sp_borra_reenvio_ext_tokens_pba()
	RETURNING CHAR(5) as codRet;

	--************************************************************************************************************************************************
	--Modificó: Manuel Ramos Figueroa.
	--Objetivo: Depurar y cancelar las solicitudes que se encuentren en estatus de reactivada (180) con un periodo de días mayor al valor del campo 
	--			bdibpi:bpi_param.valor donde el valor del campo bdibpi:bpi_param.id_param sea igual a 17.
	--Solicitó: Aida Valenzuela (BanCoppel).
	--Fecha: 2015-07-20.
	--BD:bdinteg.
	--************************************************************************************************************************************************

	DEFINE cod_ret CHAR(5);
	DEFINE sql_err INTEGER;
	DEFINE cDiasDepuracion CHAR(40);
	DEFINE iDiasDepuracion INTEGER;
	DEFINE cDiasVigencia CHAR(40);
	DEFINE iDiasVigencia INTEGER;
	DEFINE cSolicitud CHAR(10);
	DEFINE cStatus SMALLINT;
	DEFINE cNumCte CHAR(9);
	DEFINE cSolicitudesDepuradas CHAR(7);
	DEFINE iSolicitudesDepuradas INTEGER;
	DEFINE cEmailUsuarioAdmToken CHAR(40);

	--Variables de retorno del SP sp_cons_detenvios_token
	DEFINE vCodRet CHAR(5);
	DEFINE vFolioSuc CHAR(16);
	DEFINE vCuenta CHAR(20);
	DEFINE vFecha DATE;
	DEFINE vSucursal CHAR(4);
	DEFINE vCargoTot MONEY(16,2);

	--Variable de retorno del SP sp_registra_evento
	DEFINE vCodRet2 CHAR(5);

	LET cod_ret = '00000';
	LET cDiasDepuracion = '';
	LET iDiasDepuracion = 0;
	LET cDiasVigencia = '';
	LET iDiasVigencia = 0;
	LET cSolicitud = '00000';
	LET cStatus = 0;
	LET cNumCte = '';
	LET cSolicitudesDepuradas = '';
	LET iSolicitudesDepuradas = 0;
	LET cEmailUsuarioAdmToken = '';

	LET vCodRet = '';
	LET vFolioSuc = '';
	LET vCuenta = '';
	LET vSucursal = '';
	LET vCargoTot = 0;

	LET vCodRet2 = '';

	SET DEBUG FILE TO 'sp_borra_reenvio_ext_tokens.out';
	TRACE ON;

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cod_ret = sql_err;
				RETURN cod_ret;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		SELECT valor 
		INTO cDiasDepuracion 
		FROM bdibpi:"informix".bpi_param 
		WHERE id_param = '17';

		SELECT valor 
		INTO cDiasVigencia 
		FROM bdibpi:"informix".bpi_param 
		WHERE id_param = '18';

		LET iDiasDepuracion = TRIM(cDiasDepuracion)::INTEGER;
		LET iDiasVigencia = TRIM(cDiasVigencia)::INTEGER;

		DELETE {+INDEX(bdibpi:"informix".bpi_bitacora_reenvios idx_bitacora_reenvios)} FROM bdibpi:"informix".bpi_bitacora_reenvios WHERE fecha_depuracion < CURRENT YEAR TO SECOND - iDiasVigencia UNITS DAY;

		FOREACH

			SELECT  {+INDEX (bdibpi:"informix".bpi_tokensolicitud idx_bpi_tokensolicitud)}solicitud, id_status, numcte 
			INTO cSolicitud, cStatus, cNumCte 
			FROM bdibpi:"informix".bpi_tokensolicitud 
			WHERE id_status = 180 
			AND f_atencion < CURRENT YEAR TO SECOND - iDiasDepuracion UNITS DAY

			EXECUTE PROCEDURE bdibpi:"informix".sp_cons_detenvios_token('001',cSolicitud)
			INTO vCodRet, vFolioSuc, vCuenta, vFecha, vSucursal, vCargoTot;

			IF TRIM(NVL(vCodRet, '')) = '002' THEN

				INSERT INTO bdibpi:"informix".bpi_bitacora_reenvios(num_solicitud,numcliente,estatus_depuracion,fecha_depuracion) VALUES(cSolicitud,cNumCte,cStatus,current);

				UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status = 199 WHERE solicitud = cSolicitud;
				
				INSERT INTO bdibpi:"informix".tkn_stasolicitud(solicitud,anterior,actual,f_registro) VALUES(cSolicitud,'180','199',current);

				UPDATE {+INDEX(bdibpi:"informix".tkn_envios idx_tkn_envios_sol)} bdibpi:"informix".tkn_envios SET id_status = 199, comentarios = 'La solicitud fue cancelada' WHERE solicitud = cSolicitud;

				LET iSolicitudesDepuradas = iSolicitudesDepuradas + 1;

			END IF;

		END FOREACH;

		IF iSolicitudesDepuradas > 0 THEN

			LET cSolicitudesDepuradas = iSolicitudesDepuradas::CHAR(7);

			SELECT valor 
			INTO cEmailUsuarioAdmToken 
			FROM bdibpi:"informix".bpi_param 
			WHERE id_param = '16';

			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','PORTAL_BPI','BPI_DRTOKN', '000000000', '','','1', cSolicitudesDepuradas,'','','','', '','','','0','',cEmailUsuarioAdmToken,'',1,0,0,0,0,current,'')
			INTO vCodRet2;

		ELSE

			--No se encontraron solicitudes a depurar.
			LET cod_ret = '00001';

		END IF;

		RETURN cod_ret;
	END;
END PROCEDURE;