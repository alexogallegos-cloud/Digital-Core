CREATE PROCEDURE "informix".sp_remesasporestado(vFechaHoy DATE)
RETURNING CHAR(5), CHAR(80);

	--Definicion de Variables
    DEFINE cCodRet          	CHAR(5);
	DEFINE cMensaje				CHAR(80);
    DEFINE iSqlErr				INTEGER;
	DEFINE v_numcategoria		VARCHAR(2);
	DEFINE v_numconvenio		VARCHAR(5);
	DEFINE v_id_sucursal		VARCHAR(4);
	DEFINE v_referencia1		VARCHAR(40);
	DEFINE v_folio_suc			VARCHAR(16);
	DEFINE v_fecha_pago			DATE;
	DEFINE v_estado				CHAR(3);
	DEFINE v_ciudad				CHAR(40);
	DEFINE v_pais				CHAR(3);
	DEFINE cStmt				CHAR(500);
	DEFINE v_desc_edo_usa		VARCHAR(40);
	DEFINE v_cuenta_bts			INTEGER;
	DEFINE v_cuenta_wu			INTEGER;
	DEFINE v_cuenta_ov			INTEGER;
	DEFINE v_cuenta_vi			INTEGER;
	DEFINE v_cuenta_app			INTEGER;
	DEFINE v_ruta_archivo		CHAR(150);
	DEFINE v_nombre_archivo		CHAR(150);
	DEFINE v_fecha_inicial		DATE;
	DEFINE v_fecha_final		DATE;
	
	DEFINE vCuenta				INTEGER;

	-- Inicializa variables
	LET iSqlErr					= 0;
	LET cCodRet            		= '00000';
	LET cMensaje				= 'PROCESO EXITOSO';
	LET cStmt					= '';
	LET v_ruta_archivo			= '';
	LET v_nombre_archivo		= '';
	
	
	--SET DEBUG FILE TO '/ifxsif01/lfp/sp_remesasporestado.out';
	--TRACE ON;

    BEGIN
	
        ON EXCEPTION SET iSqlErr
			--Manejo de errores, en caso de error, envÃÂ­o codigo de error
            IF iSqlErr <> 0 THEN
				COMMIT WORK;
                LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR EN LA EJECUCION DEL SP";
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--Determino fecha inicial y final a tomar en cuenta (Mes pasado)
		IF MONTH(vFechaHoy) != 1 THEN
			LET v_fecha_inicial		= MDY(MONTH(vFechaHoy)-1,1,YEAR(vFechaHoy));
			LET v_fecha_final		= MDY(MONTH(vFechaHoy),1,YEAR(vFechaHoy))-1;
		ELSE
			LET v_fecha_inicial		= MDY(12,1,YEAR(vFechaHoy)-1);
			LET v_fecha_final		= MDY(12,31,YEAR(vFechaHoy)-1);
		END IF;
		
		--Busco el parametro de la ruta donde se almacenara el archivo generado
		SELECT valor INTO v_ruta_archivo FROM bdisac:"informix".sac_param WHERE cod_param = 6037;
		IF DBINFO("sqlca.sqlerrd2") = 0 OR TRIM(v_ruta_archivo) = '' THEN
			LET cCodRet = '00001';		--No existe el parametro de la ruta del archivo generado
			LET cMensaje = "NO EXISTE PARAMETRO RUTA";
			RETURN cCodRet, cMensaje;
		END IF;
		
		--Busco el parametro del nombre del archivo generado
		SELECT valor INTO v_nombre_archivo FROM bdisac:"informix".sac_param WHERE cod_param = 6038;
		IF DBINFO("sqlca.sqlerrd2") = 0 OR TRIM(v_nombre_archivo) = '' THEN
			LET cCodRet = '00002';		--No existe el parametro del nombre del archivo generado
			LET cMensaje = "NO EXISTE PARAMETRO NOM ARCH";
			RETURN cCodRet, cMensaje;
		END IF;
		
		LET v_nombre_archivo = TRIM(v_ruta_archivo) || TRIM(v_nombre_archivo);
		
		--Reemplaza la mascara por el periodo en el nombre del archivo (mensual)
		LET v_nombre_archivo = REPLACE(v_nombre_archivo,'AAAA',LPAD(YEAR(v_fecha_inicial), 4, '0'));
		LET v_nombre_archivo = REPLACE(v_nombre_archivo,'MM',LPAD(MONTH(v_fecha_inicial), 2, '0'));
		
		--Trunco la tabla de trabajo
		TRUNCATE bdisac:"informix".sac_remesas_estados;
		
		LET vCuenta = 0;
		
		--Obtengo datos de la tabla sac_remesas_estadistica_old
		BEGIN WORK;
		FOREACH WITH HOLD
			SELECT  {+INDEX(bdisac:sac_remesas_estadistica_old idx_sac_remesas_estadistica_old_01)} folio_suc, id_sucursal,
			        fecha_pago, numcategoria, numconvenio, referencia
			INTO    v_folio_suc, v_id_sucursal, v_fecha_pago, v_numcategoria, v_numconvenio, v_referencia1
			FROM    bdisac:"informix".sac_remesas_estadistica_old
			WHERE   numcategoria = '07'
			AND     numconvenio IN ('004','006','007','008','009')
			AND     fecha_pago       >= v_fecha_inicial
			AND     fecha_pago       <= v_fecha_final
			AND     status_cancelado != 'S'
			
			--INICIALIZACIONES DE VARIABLES EN CADA RENGLON DEL CICLO
			LET v_estado = '';			LET v_ciudad = '';				LET v_pais = '';
			
			--Valido si proviene de ventanilla o es automÃÂ¡tica
			IF v_id_sucursal = '9250' OR v_id_sucursal = '9251' OR v_id_sucursal = '9764' THEN
				--Es automÃÂ¡tica
				IF v_id_sucursal = '9250' THEN
					--Es BTS automÃÂ¡tica
					
					--Busco el registro en la tabla maestra
					SELECT FIRST 1 a.cod_edo_remitente, a.cd_remitente, a.cod_pais_remitente
					INTO   v_estado, v_ciudad, v_pais
					FROM   bdisac:"informix".sac_bts_sdep a
					WHERE  num_confirmacion = v_referencia1
					AND    estatus_sdep     = '05';
					
					INSERT INTO sac_remesas_estados (numcategoria, numconvenio, referencia, folio_suc, fecha_pago, estado, ciudad, pais)
					VALUES      (v_numcategoria, v_numconvenio, v_referencia1, v_folio_suc, v_fecha_pago, v_estado, v_ciudad, v_pais);
								
					--Hago commit y vuelvo a iniciar
					LET vCuenta = vCuenta + 1;
					IF vCuenta = 5000 THEN
						COMMIT WORK;
						LET vCuenta = 0;
						BEGIN WORK;
					END IF;
					
				ELIF v_id_sucursal = '9764' THEN
					--Es APP automÃÂ¡tica
					
					--Busco el registro en la tabla maestra
					SELECT FIRST 1 a.statecodesender, a.citysender, a.countrycodeorigin
					INTO   v_estado, v_ciudad, v_pais
					FROM   bdisac:"informix".sac_app_getorder a
					WHERE  uniquereferencenumber = v_referencia1
					AND    estatus_getorder      = '05';
					
					INSERT INTO sac_remesas_estados (numcategoria, numconvenio, referencia, folio_suc, fecha_pago, estado, ciudad, pais)
					VALUES      (v_numcategoria, v_numconvenio, v_referencia1, v_folio_suc, v_fecha_pago, v_estado, v_ciudad, v_pais);
								
					--Hago commit y vuelvo a iniciar
					LET vCuenta = vCuenta + 1;
					IF vCuenta = 5000 THEN
						COMMIT WORK;
						LET vCuenta = 0;
						BEGIN WORK;
					END IF;
					
				ELIF v_id_sucursal = '9251' AND v_numconvenio = '004' THEN
					--Es BTS CrÃÂ©dito automÃÂ¡tica
					
					--Busco el registro en la tabla maestra
					SELECT FIRST 1 a.cod_edo_remitente, a.cd_remitente, a.cod_pais_remitente
					INTO   v_estado, v_ciudad, v_pais
					FROM   bdisac:"informix".sac_bts_sdep a
					WHERE  num_confirmacion = v_referencia1
					AND    estatus_sdep     = '05';
					
					INSERT INTO sac_remesas_estados (numcategoria, numconvenio, referencia, folio_suc, fecha_pago, estado, ciudad, pais)
					VALUES      (v_numcategoria, v_numconvenio, v_referencia1, v_folio_suc, v_fecha_pago, v_estado, v_ciudad, v_pais);
								
					--Hago commit y vuelvo a iniciar
					LET vCuenta = vCuenta + 1;
					IF vCuenta = 5000 THEN
						COMMIT WORK;
						LET vCuenta = 0;
						BEGIN WORK;
					END IF;
					
				ELIF v_id_sucursal = '9251' AND v_numconvenio = '009' THEN
					--Es APP CrÃÂ©dito automÃÂ¡tica
					
					--Busco el registro en la tabla maestra
					SELECT FIRST 1 a.statecodesender, a.citysender, a.countrycodeorigin
					INTO   v_estado, v_ciudad, v_pais
					FROM   bdisac:"informix".sac_app_getorder a
					WHERE  uniquereferencenumber = v_referencia1
					AND    estatus_getorder      = '05';
					
					INSERT INTO sac_remesas_estados (numcategoria, numconvenio, referencia, folio_suc, fecha_pago, estado, ciudad, pais)
					VALUES      (v_numcategoria, v_numconvenio, v_referencia1, v_folio_suc, v_fecha_pago, v_estado, v_ciudad, v_pais);
								
					--Hago commit y vuelvo a iniciar
					LET vCuenta = vCuenta + 1;
					IF vCuenta = 5000 THEN
						COMMIT WORK;
						LET vCuenta = 0;
						BEGIN WORK;
					END IF;
					
				END IF;
			ELSE
				
				--Es de ventanilla
				IF v_numconvenio = '004' THEN
					--Es BTS ventanilla
					
					--Busco el ultimo registro de QRYI
					SELECT FIRST 1 a.s_state_cd, a.s_city, a.s_country_cd
					INTO   v_estado, v_ciudad, v_pais
					FROM   sac_bts_qryi a
					WHERE  confirmation_nm = v_referencia1;
					
					INSERT INTO sac_remesas_estados (numcategoria, numconvenio, referencia, folio_suc, fecha_pago, estado, ciudad, pais)
					VALUES      (v_numcategoria, v_numconvenio, v_referencia1, v_folio_suc, v_fecha_pago, v_estado, v_ciudad, v_pais);
								
					--Hago commit y vuelvo a iniciar
					LET vCuenta = vCuenta + 1;
					IF vCuenta = 5000 THEN
						COMMIT WORK;
						LET vCuenta = 0;
						BEGIN WORK;
					END IF;
					
				ELIF v_numconvenio = '006' OR v_numconvenio = '007' OR v_numconvenio = '008' THEN
					--Es WU ventanilla
					
					--Busco el ultimo registro de QRYI   ------Se cambia consulta a INTERCARD - NMR 28MAR19-----------
					SELECT FIRST 1 a.sender_state, a.sender_city, a.sender_country_code
					INTO v_estado, v_ciudad, v_pais
					FROM intercard:"informix".bitacorawumoneytransfersearch a
					WHERE a.pt_mtcn = v_referencia1;
					
					INSERT INTO sac_remesas_estados (numcategoria, numconvenio, referencia, folio_suc, fecha_pago, estado, ciudad, pais)
					VALUES      (v_numcategoria, v_numconvenio, v_referencia1, v_folio_suc, v_fecha_pago, v_estado, v_ciudad, v_pais);
								
					--Hago commit y vuelvo a iniciar
					LET vCuenta = vCuenta + 1;
					IF vCuenta = 5000 THEN
						COMMIT WORK;
						LET vCuenta = 0;
						BEGIN WORK;
					END IF;
					
				ELIF v_numconvenio = '009' THEN
					--Es APP ventanilla
					
					--Busco el ultimo registro de QRYI
					SELECT FIRST 1 a.r_statecode, a.r_city, a.r_countrycode_a
					INTO   v_estado, v_ciudad, v_pais
					FROM   sac_app_qryi a
					WHERE  a.unirefnum    = v_referencia1;
					
					INSERT INTO sac_remesas_estados (numcategoria, numconvenio, referencia, folio_suc, fecha_pago, estado, ciudad, pais)
					VALUES      (v_numcategoria, v_numconvenio, v_referencia1, v_folio_suc, v_fecha_pago, v_estado, v_ciudad, v_pais);
								
					--Hago commit y vuelvo a iniciar
					LET vCuenta = vCuenta + 1;
					IF vCuenta = 5000 THEN
						COMMIT WORK;
						LET vCuenta = 0;
						BEGIN WORK;
					END IF;
					
				END IF;
				
			END IF;
			
			
			
		END FOREACH;
		
		IF vCuenta < 5000 and vCuenta >= 0 THEN
			COMMIT WORK;
		END IF;
		
		LET vCuenta = 0;
		
		-- Genero encabezado
		LET cStmt = 'echo "ESTADO|BTS|WU|OV|V|APPRIZA" >> ' || v_nombre_archivo;
		SYSTEM cStmt;
		
		---- Finalemente genero el reporte solicitado
		FOREACH
			SELECT b.desc_edo estado_usa,
				   SUM(CASE WHEN a.numconvenio = '004' THEN 1 ELSE 0 END) cuenta_bts,
				   SUM(CASE WHEN a.numconvenio = '006' THEN 1 ELSE 0 END) cuenta_wu,
				   SUM(CASE WHEN a.numconvenio = '007' THEN 1 ELSE 0 END) cuenta_ov,
				   SUM(CASE WHEN a.numconvenio = '008' THEN 1 ELSE 0 END) cuenta_vi,
				   SUM(CASE WHEN a.numconvenio = '009' THEN 1 ELSE 0 END) cuenta_app
			INTO   v_desc_edo_usa, v_cuenta_bts, v_cuenta_wu, v_cuenta_ov, v_cuenta_vi, v_cuenta_app
			FROM   sac_remesas_estados a, sac_cat_edos_usa b
			WHERE  a.estado = b.id_edo
			GROUP BY 1
			ORDER BY 1
		
			LET cStmt = 'echo "' || v_desc_edo_usa || '|' || v_cuenta_bts || '|' || v_cuenta_wu || '|' || v_cuenta_ov || '|' || v_cuenta_vi || '|' || v_cuenta_app || '" >> ' || v_nombre_archivo;
			SYSTEM cStmt;
			
			LET vCuenta = vCuenta + 1;
			
		END FOREACH;
		
		IF vCuenta = 0 THEN
			LET cCodRet = '00003';		--No existen registros en el reporte
			LET cMensaje = "NO EXISTEN REGISTROS";
			RETURN cCodRet, cMensaje;
		END IF;
		
		--Trunco la tabla de trabajo para finalizar
		TRUNCATE bdisac:"informix".sac_remesas_estados;
		
		RETURN cCodRet, cMensaje;
		
    END;
END PROCEDURE
DOCUMENT
'AUTOR          : Luis Felipe Prieto',
'DESCRIPCION    : Se encarga de generar el reporte de estados de remesas en un periodo mensual especifico',
'FECHA CREACION : 17 de Octubre de 2018',
'BD             : bdisac';

CREATE PROCEDURE "informix".sp_generaconciliacioncoppel(pFecha_Hoy DATE)
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;


-- DEFINICION DE VARIABLES
DEFINE cCodRet					CHAR(5);
DEFINE cCodRetSP				CHAR(5);
DEFINE cMensaje					CHAR(80);
DEFINE iSqlErr     	 			INTEGER;
DEFINE iIsamErr     			INTEGER;
DEFINE cInfoErr  				VARCHAR(100);
DEFINE cNumcategoria			CHAR(2);
DEFINE cNumconvenio				CHAR(3);
DEFINE dFecha_ini				DATE;
DEFINE iDias_rang				INTEGER;
DEFINE cMovimiento          	CHAR(2);
DEFINE cTipomovimiento      	CHAR(2);
DEFINE cStatus						CHAR(1);

--INICIALIZACION DE VARIABLES--
LET cCodRet						= "00000";
LET cCodRetSP					= "99999";
LET cMensaje					= 'PROCESO EXITOSO';
LET iSqlErr						= 0;
LET cNumcategoria 				= '';
LET cNumconvenio 				= '';
LET dFecha_ini					= DATE(1);
LET iDias_rang					= 0;
LET cMovimiento             	= '';
LET cTipomovimiento         	= '';
LET cStatus						= '0';

	--SET DEBUG FILE TO  '/informix/EPG/sp_generaconciliacioncoppel.out';
	--TRACE ON;

	BEGIN

        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_generaconciliacioncoppel");
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
			
		--OBTENGO VALOR DE DIAS DE TOLERANCIA PARA INCLUIR EN ARCHIVO
		SELECT valor
		INTO   iDias_rang
		FROM   "informix".sac_param
		WHERE  empresa   = '001'
		AND    cod_param = '118';
			
		FOREACH
			
			SELECT a.numcategoria, a.numconvenio, b.movimiento, b.tipomovimiento
			INTO cNumcategoria, cNumconvenio, cMovimiento, cTipomovimiento
			FROM   bdisac:"informix".sac_convenios as a, bdisac:"informix".sac_servicios_cpl as b
			WHERE  a.numcategoria = b.numcategoria
			AND a.numconvenio = b.numconvenio
			AND b.conciliacion = '1'
			
			--SELECCIONA LA FECHA DEL ULTIMO ARCHIVO GENERADO
			SELECT fecha_ultimo_archivo
			INTO   dFecha_ini
			FROM   "informix".sac_controlarchivoscobranza
			WHERE  numcategoria = cNumcategoria
			AND    numconvenio  = cNumconvenio;
			
			--BORRO TABLA TEMPORAL SI EXISTE
			DROP TABLE IF EXISTS tmp_movs;
			
			--CREO TABLA TEMPORAL
			CREATE TEMP TABLE tmp_movs(
			  folio_suc    CHAR(16),
			  fecha_pago   DATE,
              numcategoria CHAR(2),
              numconvenio  CHAR(3)) WITH NO LOG;
			  

			--GUARDAR LOS CONCILIADOS
			--INSERT INTO bdisac:"informix".sac_movimientos_bcpl_cpl
			INSERT INTO tmp_movs
			SELECT b.folio_suc, b.fecha_pago, b.numcategoria, b.numconvenio
			FROM bdisac:"informix".sac_conciliacion_bcpl_cpl AS a					
			INNER JOIN 
			TABLE (MULTISET(SELECT id_sucursal,numcategoria,numconvenio,referencia1,referencia2,forma_pago,importe_pago,importe_comision_convenio,iva_comision_convenio,
				importe_comision_cte,iva_comision_cte,cuenta_cargo,usuario,folio_suc,transacc_suc,flag_confirmacion_central,flag_confirmacion_sucursal,
				fecha_pago,fecha_insert,status_cancelado,origen,sucursal_cpl,caja_cpl,transaccion,hora,folio_operacion,referencia3,referencia4 
			FROM "informix".sac_movimientos
			WHERE  numcategoria     =  cNumcategoria
			AND    numconvenio      =  cNumconvenio
			AND    fecha_pago       =  pFecha_Hoy
			AND    status_cancelado <> 'S'
			AND    (flag_confirmacion_central  = 1
			OR     flag_confirmacion_sucursal  = 1)
			AND    id_sucursal = '9764'
			UNION ALL
			SELECT id_sucursal,numcategoria,numconvenio,referencia1,referencia2,forma_pago,importe_pago,importe_comision_convenio,iva_comision_convenio,
				importe_comision_cte,iva_comision_cte,cuenta_cargo,usuario,folio_suc,transacc_suc,flag_confirmacion_central,flag_confirmacion_sucursal,
				fecha_pago,fecha_insert,status_cancelado,origen,sucursal_cpl,caja_cpl,transaccion,hora,folio_operacion,referencia3,referencia4 
			FROM "informix".sac_movimientoshistorial
			WHERE  numcategoria     =  cNumcategoria
			AND    numconvenio      =  cNumconvenio
			AND    fecha_pago       >  dFecha_ini - iDias_rang
			AND    fecha_pago       <= pFecha_Hoy
			AND    status_cancelado <> 'S'
			AND    (flag_confirmacion_central  = 1
			OR     flag_confirmacion_sucursal  = 1)
			AND    id_sucursal      = '9764')) AS b
		  --ON     a.tienda         = b.sucursal_cpl::INTEGER
		  --AND    a.caja           = b.caja_cpl
		  --AND    a.numerotiket    = b.folio_operacion
		  --AND    a.foliosucursal  = b.folio_suc
			ON     a.foliosucursal  = b.folio_suc
			AND    a.fechapago      = b.fecha_pago
            AND    a.tipomovimiento = (SELECT tipomovimiento FROM sac_servicios_cpl WHERE numcategoria = b.numcategoria AND numconvenio = b.numconvenio )
			WHERE  a.st_conciliado  = 0;
			
			--ACTUALIZA LAS CONCILIADAS ANTERIOES QUE FUERON CONCILIADOS CON EL ARCHIVO DE COPPEL DEL DIA
			MERGE INTO bdisac:"informix".sac_conciliacion_bcpl_cpl AS a 
			USING bdisac:"informix".tmp_movs AS b
			ON a.foliosucursal || a.fechapago = b.folio_suc || b.fecha_pago 
            AND    a.tipomovimiento = (SELECT tipomovimiento FROM sac_servicios_cpl WHERE numcategoria = b.numcategoria AND numconvenio = b.numconvenio )
			WHEN MATCHED THEN UPDATE SET a.st_conciliado = 1, a.fecha_concil = TODAY;
			
			DROP TABLE IF EXISTS tmp_movs;
			
		END FOREACH;	
			
		RETURN cCodRet, cMensaje;
	
	END;
	
END PROCEDURE
;