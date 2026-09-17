CREATE PROCEDURE "informix".sp_obtiene_periodo_vigencia_preingreso(pTipoAclaracion INTEGER)
	
	RETURNING
		CHAR(5)				AS cod_ret,
		INTEGER 			AS dias_vencimiento;

	--Variables--
	DEFINE sql_err 						INTEGER;
	DEFINE v_cod_ret 					CHAR(5);
	DEFINE v_existe_tipo_acl			SMALLINT;
	DEFINE v_dias_vencimiento			INTEGER;
	
	LET v_cod_ret 						= "00000";
	LET v_existe_tipo_acl 				= NULL;
	LET v_dias_vencimiento	 			= NULL;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_cod_ret = sql_err;
				
				RETURN v_cod_ret, v_dias_vencimiento;
			END IF;
		END EXCEPTION;
		
		IF (pTipoAclaracion IS NULL) THEN
			RETURN '00001', v_dias_vencimiento; --La invocaciÃ³n debe tener algÃºn valor
		END IF;
		
		SELECT 1, dias_vencimiento 
			INTO v_existe_tipo_acl, v_dias_vencimiento
		FROM acl_cat_tipo_aclaracion 
		WHERE pky_cat_tipo_aclaracion = pTipoAclaracion;
		
		IF (v_existe_tipo_acl IS NULL) THEN
			RETURN '00002', v_dias_vencimiento; --No existe el Tipo de Ingreso de AclaraciÃ³n
		END IF;
		
		--En caso de no tener parÃ¡metro y existir el Tipo de AclaraciÃ³n, se devolverÃ¡ 0
		LET v_dias_vencimiento = NVL(v_dias_vencimiento,0);
		
		RETURN v_cod_ret, v_dias_vencimiento; 
		
	END;
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones BPI',
'CreaciÃ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Noviembre/2018',
'Requerimiento	:	RQM 06 626',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_obten_estatus_canales(
								pEstatusAcl				INTEGER,
								pEstatusCorpGral		INTEGER,
								pEstatusCorpAnalisis	INTEGER)

	RETURNING
		CHAR(5)							AS cod_ret,
		CHAR(50)						AS desc_estatus_canales,
		SMALLINT 						AS concatena_dictamen,
		INTEGER 						AS id_etapa_canales,
        CHAR(20)						AS desc_etapa_canales;

	--Variables--
	DEFINE sql_err 							INTEGER;
	DEFINE v_cod_ret 						CHAR(5);
	
	DEFINE v_id_estatus_aclaracion			INTEGER;
	DEFINE v_id_estatus_corp_analisis		INTEGER;
	DEFINE v_id_estatus_corp_general		INTEGER;
	DEFINE v_concatena_dictamen				SMALLINT;
	DEFINE v_estatus_canales				CHAR(50);
	DEFINE v_id_etapa_canales				INTEGER;
	DEFINE v_desc_etapa_canales				CHAR(20);
	
	
	DEFINE contador			INTEGER;
	LET contador			= 0;
	
	LET v_cod_ret 						= '00000';
	LET sql_err 						= NULL;
	
	LET v_id_estatus_aclaracion			= NULL;
	LET v_id_estatus_corp_analisis		= NULL;
	LET v_id_estatus_corp_general		= NULL;
	LET v_concatena_dictamen			= NULL;
	LET v_estatus_canales					= NULL;
	LET v_id_etapa_canales					= NULL;
	LET v_desc_etapa_canales				= NULL;
	
	--SET DEBUG FILE TO "/informix/traces/estatus_canales.out";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				
				LET v_cod_ret = sql_err;
				RETURN v_cod_ret, v_estatus_canales, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales;
				
		    END IF;
		END EXCEPTION;
		
		IF (pEstatusAcl IS NULL) THEN
			RETURN '00001', v_estatus_canales, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales; --El estatus de la Aclaración no puede ser Nulo
		END IF;
		
		--Se realiza la consulta por los parámetros de invocación del SP
		SELECT ea.pky_estatus_aclaracion, eca.pky_estatus_corporativo, ecg.pky_estatus_corporativo, ecan.descripcion, ecan.concatena_dictamen,
				ecan.id_etapa_canales, ecan.descripcion_etapa_canales
			INTO v_id_estatus_aclaracion, v_id_estatus_corp_analisis, v_id_estatus_corp_general, v_estatus_canales, v_concatena_dictamen,
				v_id_etapa_canales, v_desc_etapa_canales
		FROM acl_estatus_canales ecan
			INNER JOIN acl_estatus_aclaracion ea ON ea.nombre = ecan.nombre_estatus_aclaracion 
			LEFT OUTER JOIN acl_estatus_corporativo ecg ON ecg.fky_tipo_estatus = 1 AND ecg.nombre = ecan.nombre_estatus_corp_general 
			LEFT OUTER JOIN acl_estatus_corporativo eca ON eca.fky_tipo_estatus = 2 AND eca.nombre = ecan.nombre_estatus_corp_analisis 
		WHERE pky_estatus_aclaracion = pEstatusAcl
			AND ecg.pky_estatus_corporativo = pEstatusCorpGral
			AND eca.pky_estatus_corporativo = pEstatusCorpAnalisis;
		
		--En caso que la consulta no devuelva resultados se valida si se tiene algún comodín con un estatus de análisis
		IF v_estatus_canales IS NULL THEN
			SELECT ea.pky_estatus_aclaracion, eca.pky_estatus_corporativo, ecg.pky_estatus_corporativo, ecan.descripcion, ecan.concatena_dictamen,
					ecan.id_etapa_canales, ecan.descripcion_etapa_canales
				INTO v_id_estatus_aclaracion, v_id_estatus_corp_analisis, v_id_estatus_corp_general, v_estatus_canales, v_concatena_dictamen,
					v_id_etapa_canales, v_desc_etapa_canales
			FROM acl_estatus_canales ecan
				INNER JOIN acl_estatus_aclaracion ea ON ea.nombre = ecan.nombre_estatus_aclaracion 
				LEFT OUTER JOIN acl_estatus_corporativo ecg ON ecg.fky_tipo_estatus = 1 AND ecg.nombre = ecan.nombre_estatus_corp_general 
				LEFT OUTER JOIN acl_estatus_corporativo eca ON eca.fky_tipo_estatus = 2 AND eca.nombre = ecan.nombre_estatus_corp_analisis 
			WHERE pky_estatus_aclaracion = pEstatusAcl
				AND ecg.pky_estatus_corporativo IS NULL 
				AND eca.pky_estatus_corporativo = pEstatusCorpAnalisis;
		END IF;
		
		--En caso que la consulta no devuelva resultados se valida si se tiene algún comodín con un estatus de corporativo
		IF v_estatus_canales IS NULL THEN
			SELECT ea.pky_estatus_aclaracion, eca.pky_estatus_corporativo, ecg.pky_estatus_corporativo, ecan.descripcion, ecan.concatena_dictamen,
					ecan.id_etapa_canales, ecan.descripcion_etapa_canales
				INTO v_id_estatus_aclaracion, v_id_estatus_corp_analisis, v_id_estatus_corp_general, v_estatus_canales, v_concatena_dictamen,
					v_id_etapa_canales, v_desc_etapa_canales
			FROM acl_estatus_canales ecan
				INNER JOIN acl_estatus_aclaracion ea ON ea.nombre = ecan.nombre_estatus_aclaracion 
				LEFT OUTER JOIN acl_estatus_corporativo ecg ON ecg.fky_tipo_estatus = 1 AND ecg.nombre = ecan.nombre_estatus_corp_general 
				LEFT OUTER JOIN acl_estatus_corporativo eca ON eca.fky_tipo_estatus = 2 AND eca.nombre = ecan.nombre_estatus_corp_analisis 
			WHERE pky_estatus_aclaracion = pEstatusAcl
				AND ecg.pky_estatus_corporativo = pEstatusCorpGral
				AND eca.pky_estatus_corporativo IS NULL;
		END IF;
		
		--En caso que la consulta no devuelva resultados se valida si existe el registro para el estatus de la aclaración
		IF v_estatus_canales IS NULL THEN
			SELECT ea.pky_estatus_aclaracion, ecan.descripcion, ecan.concatena_dictamen, ecan.id_etapa_canales, ecan.descripcion_etapa_canales
				INTO v_id_estatus_aclaracion, v_estatus_canales, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales
			FROM acl_estatus_canales ecan
				INNER JOIN acl_estatus_aclaracion ea ON ea.nombre = ecan.nombre_estatus_aclaracion 
			WHERE pky_estatus_aclaracion = pEstatusAcl 
				AND ecan.nombre_estatus_corp_general IS NULL 
				AND ecan.nombre_estatus_corp_analisis IS NULL;
		END IF;
		
		--En caso que la consulta no devuelva resultados se mostrará el valor del Estatus de la aclaración
		IF v_estatus_canales IS NULL THEN
			SELECT ea.pky_estatus_aclaracion, ea.descripcion, 0
				INTO v_id_estatus_aclaracion, v_estatus_canales, v_concatena_dictamen
			FROM acl_estatus_aclaracion ea 
			WHERE pky_estatus_aclaracion = pEstatusAcl;
			
			--Se asignan los valores de la "Etapa" considerando el estatus de la Aclaración
			IF v_id_estatus_aclaracion = 1 THEN
				LET v_id_etapa_canales = 1;
				LET v_desc_etapa_canales = 'ALTA';
			ELIF v_id_estatus_aclaracion = 2 THEN
				LET v_id_etapa_canales = 2;
				LET v_desc_etapa_canales = 'ANÁLISIS';
			ELIF v_id_estatus_aclaracion BETWEEN 3 AND 5 THEN
				LET v_id_etapa_canales = 3;
				LET v_desc_etapa_canales = 'DICTAMEN';
			ELSE
				LET v_id_etapa_canales = 0;
				LET v_desc_etapa_canales = 'NO DEFINIDO';
			END IF;
		END IF;
		
		IF v_estatus_canales IS NULL THEN
			LET v_cod_ret = '00002'; --El estatus de la Aclaración no existe
		END IF;
		
		RETURN v_cod_ret, v_estatus_canales, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales;
			
	END;
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones BPI',
'Creación		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Noviembre/2018',
'Requerimiento	:	RQM 06 626',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_buscarevento_por_flujo(
                        pTipoProducto INTEGER,
                        pOrigenEvento INTEGER,
						pTipoFlujo INTEGER,
						pEsCargoRecurrente SMALLINT)
	
	RETURNING
		CHAR(5)				AS cod_ret,
		INTEGER 			AS id_evento,
		SMALLINT			AS capturamanual,
		CHAR(50)			AS descripcion,
		SMALLINT			AS diferenciaimportes,
		CHAR(4)				AS grupo_doc,
		CHAR(50)			AS nombre,
		INTEGER				AS fky_tipo_transaccion,
		MONEY				AS costo,
		SMALLINT			AS acepta_cargos_recurrentes,
		CHAR(2)				AS motivobloqueodebito,
		INTEGER				AS tipobloqueocredito,
		CHAR(2)				AS motivobloqueocredito,
		INTEGER				AS tipobloqueodebito,
		INTEGER				AS idTipoProducto;

	--Variables--
	DEFINE sql_err 						INTEGER;
	DEFINE v_cod_ret 					CHAR(5);
	DEFINE v_pky_tipo_evento  			INTEGER;
	DEFINE v_capturamanual	 			SMALLINT;
	DEFINE v_descripcion  				VARCHAR(50);
	DEFINE v_diferenciaimportes  		SMALLINT;
	DEFINE v_grupo_doc  				VARCHAR(4);
	DEFINE v_nombre  					VARCHAR(50);
	DEFINE v_fky_tipo_transaccion  		INTEGER;
	DEFINE v_costo 						MONEY;
	DEFINE v_acepta_cargos_recurrentes	SMALLINT;
	DEFINE v_motivobloqueodebito  		CHAR(2);
	DEFINE v_tipobloqueocredito 		INTEGER;
	DEFINE v_motivobloqueocredito 		CHAR(2);
	DEFINE v_tipobloqueodebito 			INTEGER;
	DEFINE v_pky_tipo_producto 			INTEGER;

	LET v_cod_ret 						= "00000";
	LET v_pky_tipo_evento 				= NULL;
	LET v_capturamanual	 				= NULL;
	LET v_descripcion 					= NULL;
	LET v_diferenciaimportes			= NULL;
	LET v_grupo_doc						= NULL;
	LET v_nombre						= NULL;
	LET v_fky_tipo_transaccion			= NULL;
	LET v_costo							= NULL;
	LET v_acepta_cargos_recurrentes		= NULL;
	LET v_motivobloqueodebito			= NULL;
	LET v_tipobloqueocredito			= NULL;
	LET v_motivobloqueocredito			= NULL;
	LET v_tipobloqueodebito 			= NULL;
	LET v_pky_tipo_producto				= NULL;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_cod_ret = sql_err;
				
				RETURN v_cod_ret,v_pky_tipo_evento,v_capturamanual,v_descripcion,v_diferenciaimportes,v_grupo_doc,v_nombre,v_fky_tipo_transaccion,
					v_costo,v_acepta_cargos_recurrentes,v_motivobloqueodebito,v_tipobloqueocredito,v_motivobloqueocredito,v_tipobloqueodebito, 
					v_pky_tipo_producto;
			END IF;
		END EXCEPTION;
		
		IF pEsCargoRecurrente IS NULL THEN
			FOREACH
				SELECT te.pky_tipo_evento, te.capturamanual, te.descripcion, te.diferenciaimportes, te.grupo_doc, te.nombre,
						te.fky_tipo_transaccion, te.costo, te.acepta_cargos_recurrentes, te.motivobloqueodebito, te.tipobloqueocredito,
						te.motivobloqueocredito, te.tipobloqueodebito, tp.pky_tipo_producto
					INTO v_pky_tipo_evento, v_capturamanual, v_descripcion, v_diferenciaimportes, v_grupo_doc,v_nombre, v_fky_tipo_transaccion,
						v_costo, v_acepta_cargos_recurrentes, v_motivobloqueodebito, v_tipobloqueocredito, v_motivobloqueocredito,
						v_tipobloqueodebito, v_pky_tipo_producto
				FROM acl_tipo_evento te
					INNER JOIN acl_origen_evento oe ON te.fky_origen_evento = oe.pky_origen_evento
					INNER JOIN acl_tipo_prod_tipo_evento tpte ON te.pky_tipo_evento = tpte.fky_tipo_evento
					INNER JOIN acl_tipo_producto tp ON tpte.fky_tipo_producto = tp.pky_tipo_producto
				WHERE te.activo = 1 AND te.fky_tipo_flujo = pTipoFlujo
					AND oe.pky_origen_evento = pOrigenEvento AND tp.producto = pTipoProducto
				ORDER BY te.descripcion ASC

				RETURN
					v_cod_ret, v_pky_tipo_evento, v_capturamanual, v_descripcion, v_diferenciaimportes, v_grupo_doc, v_nombre, v_fky_tipo_transaccion,
						v_costo, v_acepta_cargos_recurrentes, v_motivobloqueodebito, v_tipobloqueocredito, v_motivobloqueocredito, v_tipobloqueodebito,
						v_pky_tipo_producto
				WITH RESUME;
			END FOREACH;
		ELSE
			FOREACH
				SELECT te.pky_tipo_evento, te.capturamanual, te.descripcion, te.diferenciaimportes, te.grupo_doc, te.nombre,
						te.fky_tipo_transaccion, te.costo, te.acepta_cargos_recurrentes, te.motivobloqueodebito, te.tipobloqueocredito,
						te.motivobloqueocredito, te.tipobloqueodebito, tp.pky_tipo_producto
					INTO v_pky_tipo_evento, v_capturamanual, v_descripcion, v_diferenciaimportes, v_grupo_doc,v_nombre, v_fky_tipo_transaccion,
						v_costo, v_acepta_cargos_recurrentes, v_motivobloqueodebito, v_tipobloqueocredito, v_motivobloqueocredito,
						v_tipobloqueodebito, v_pky_tipo_producto
				FROM acl_tipo_evento te
					INNER JOIN acl_origen_evento oe ON te.fky_origen_evento = oe.pky_origen_evento
					INNER JOIN acl_tipo_prod_tipo_evento tpte ON te.pky_tipo_evento = tpte.fky_tipo_evento
					INNER JOIN acl_tipo_producto tp ON tpte.fky_tipo_producto = tp.pky_tipo_producto
				WHERE te.activo = 1 AND te.fky_tipo_flujo = pTipoFlujo
					AND oe.pky_origen_evento = pOrigenEvento AND tp.producto = pTipoProducto
					AND te.acepta_cargos_recurrentes = pEsCargoRecurrente
				ORDER BY te.descripcion ASC

				RETURN
					v_cod_ret, v_pky_tipo_evento, v_capturamanual, v_descripcion, v_diferenciaimportes, v_grupo_doc, v_nombre, v_fky_tipo_transaccion,
						v_costo, v_acepta_cargos_recurrentes, v_motivobloqueodebito, v_tipobloqueocredito, v_motivobloqueocredito, v_tipobloqueodebito,
						v_pky_tipo_producto
				WITH RESUME;
			END FOREACH;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones BPI',
'CreaciÃ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Noviembre/2018',
'Requerimiento	:	RQM 06 626',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_obten_origen_automatico(
						pNumeroCuenta CHAR(30),
						pNumTarjeta CHAR(16),
						pSecuenciaMovimiento INTEGER, 
						pFoliosuc CHAR(30), 
						pTransaccion CHAR(5), 
						pfechaMovimiento DATE,
						pTipoProducto CHAR(1))
	
	RETURNING
		CHAR(5)				AS cod_ret_origen, 
		CHAR(2) 			AS es_cargo_recurrente, 
		CHAR(1) 			AS es_nacional, 
		CHAR(2) 			AS modoentrada,
		SMALLINT 			AS tiene_acl_asociada,
		SMALLINT			AS transacc_registrada_en_sistema,
		SMALLINT			AS es_saldo_retenido,
		SMALLINT			AS es_transaccion_hijo,
		INTEGER				AS origen_evento,
		CHAR(50)			AS desc_origen_evento;
		
	--Variables--
	DEFINE sql_err 						INTEGER;
	DEFINE v_cod_ret 					CHAR(5);
	DEFINE v_cod_ret_sp_cr				CHAR(4);
	
	DEFINE v_secuenciaextendida			CHAR(16);
	DEFINE v_foliosuc1					CHAR(30);
	DEFINE v_valor_secuencia_folio		CHAR(1);
	DEFINE v_valida_movimiento			SMALLINT;
	DEFINE v_es_nacional				CHAR(1);
	DEFINE v_codgironeg					CHAR(4);
	DEFINE v_modo_entrada				CHAR(2);
	DEFINE v_es_movimiento_forzado		SMALLINT;
	DEFINE v_cant_origenes_asociados	INTEGER;
	DEFINE v_modo_entrada_asociado		CHAR(2);
	DEFINE v_origen_evento				INTEGER;
	DEFINE v_desc_origen_evento			CHAR(50);
	DEFINE v_es_transaccion_hijo		SMALLINT;
	DEFINE v_origen_evento_por_defecto	INTEGER;
	DEFINE v_tiene_acl_asociada			SMALLINT;
	DEFINE c_nombre_pre_ingreso			CHAR(20);
	DEFINE c_estatus_pre_ingreso		INTEGER;
	DEFINE v_es_cargo_recurrente		CHAR(2);
	DEFINE v_transacc_registrada_en_sistema		SMALLINT;
	DEFINE v_es_saldo_retenido			SMALLINT;
	
	DEFINE segundaLetraFolioSuc			CHAR(1);
	

	LET v_cod_ret 						= "00000";
	LET v_cod_ret_sp_cr					= NULL;
	
	LET v_secuenciaextendida			= NULL;
	LET v_foliosuc1						= NULL;
	LET v_valor_secuencia_folio			= NULL;
	LET v_valida_movimiento				= 0;
	LET v_es_nacional					= NULL;
	LET v_codgironeg					= NULL;
	LET v_modo_entrada					= NULL;
	LET v_es_movimiento_forzado			= NULL;
	LET v_cant_origenes_asociados		= NULL;
	LET v_modo_entrada_asociado			= NULL;
	LET v_origen_evento					= NULL;
	LET v_desc_origen_evento			= NULL;
	LET v_es_transaccion_hijo			= NULL;
	LET v_origen_evento_por_defecto		= NULL;
	LET v_tiene_acl_asociada			= NULL;
	LET c_estatus_pre_ingreso			= NULL;
	LET c_nombre_pre_ingreso			= 'PRE_INGRESO';
	LET v_es_cargo_recurrente			= NULL;
	LET v_transacc_registrada_en_sistema			= NULL;
	LET v_es_saldo_retenido				= NULL;
	
	LET segundaLetraFolioSuc 			= NULL;
	
	--SET DEBUG FILE TO "/informix/traces/VJMP_OE.out";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_cod_ret = sql_err;
				
				RETURN v_cod_ret, --cod_ret_origen,
					v_es_cargo_recurrente, --es_cargo_recurrente,
					v_es_nacional, --es_nacional,
					v_modo_entrada, --modoentrada,
					v_tiene_acl_asociada, --tiene_acl_asociada,
					v_transacc_registrada_en_sistema, --transacc_registrada_en_sistema,
					v_es_saldo_retenido,--es_saldo_retenido,
					v_es_transaccion_hijo,--es_transaccion_hijo
					v_origen_evento, --origen_evento
					v_desc_origen_evento; --desc_origen_evento;
			END IF;
		END EXCEPTION;
		
		/*Valores en duro del OrÃ­gen y Evento por defecto cuando no identifica alguna soluciÃ³n Ãºnica*/
		--LET v_origen_evento_por_defecto = 0;
		SELECT fky_origen_evento
			INTO v_origen_evento_por_defecto
		FROM acl_asociacion_origen_evento_canal WHERE fky_cat_tipo_aclaracion = 6;
		--Se coloca en duro el valor 6 correspondiente al portal, se seleccionarÃ¡ origen sin importar su estatus.
		
		--Se determina si se va a buscar el movimiento en Intercard y se obtiene el valor de la secuenciaextendida para realizar dicha bÃºsqueda
		LET segundaLetraFolioSuc = substr(pFoliosuc,2,1);
		--IF substr(pFoliosuc,1,1) = 'i' AND substr(pFoliosuc,2,1) IN ('0','1','2','3','4','5','6','7','8','9') THEN
		IF substr(pFoliosuc,1,1) = 'i' AND segundaLetraFolioSuc IN ('0','1','2','3','4','5','6','7','8','9') THEN
			LET v_secuenciaextendida = substr(pFoliosuc,2,(length(trim(pFoliosuc))-1));
			LET v_valida_movimiento = 1;
			LET v_valor_secuencia_folio = substr(v_secuenciaextendida,9,1);
			IF  v_valor_secuencia_folio <> '1' AND v_valor_secuencia_folio IN (0,2,3,4,5,6,7,8,9) THEN
				LET v_secuenciaextendida = substr(v_secuenciaextendida,1,8) || '1' || substr (v_secuenciaextendida,10 , LENGTH(v_secuenciaextendida)) ;
				--LET v_foliosuc1 = substr(v_foliosuc1,1,8) || '1' || substr (v_foliosuc1,10 , LENGTH(v_foliosuc1)) ;
				LET v_foliosuc1 = substr(v_foliosuc1,1,9) || '1' || substr (v_foliosuc1,11 , LENGTH(v_foliosuc1)) ;
			END IF;
		END IF
		
		IF v_valida_movimiento = 1 THEN
			SELECT esnacional, codgironeg, metodocaptura
				INTO v_es_nacional, v_codgironeg, v_modo_entrada
			FROM intercard:movimiento
				WHERE secuenciaextendida = v_secuenciaextendida
					AND numtarjeta = pNumTarjeta;
			
			--En caso de no tener valor, se realiza la bÃºsqueda en la tabla de movimientos histÃ³ricos
			IF (v_es_nacional IS NULL AND v_modo_entrada IS NULL) THEN
				SELECT esnacional, codgironeg, metodocaptura
					INTO v_es_nacional, v_codgironeg, v_modo_entrada
				FROM intercard:movimientohistorico
					WHERE secuenciaextendida = v_secuenciaextendida
						AND numtarjeta = pNumTarjeta;
				
				--En caso de no tener valor, se valida si el movimiento no corresponde a uno Forzado (sin movimiento en Intercard)
				IF (v_es_nacional IS NULL AND v_modo_entrada IS NULL) THEN
					SELECT 1 
						INTO v_es_movimiento_forzado
					FROM bditarjeta:td_movimientos_conciliacion con WHERE
						con.numtarjeta = pNumTarjeta AND con.folio_mov = v_foliosuc1
							AND con.tipo_conciliacion IN (8,31);
					
					IF (v_es_movimiento_forzado IS NULL) THEN
						SELECT 1 
							INTO v_es_movimiento_forzado
						FROM bditarjeta:td_movimientos_conciliacion_his con WHERE
							con.numtarjeta = pNumTarjeta AND con.folio_mov = v_foliosuc1
								AND con.tipo_conciliacion IN (8,31);
					END IF;
					
					IF (v_es_movimiento_forzado IS NULL) THEN
						LET v_es_nacional = 'V';
					END IF;
					
				END IF;
			END IF;
		END IF;
		
		LET v_codgironeg = NVL(v_codgironeg,'NA');
		
		LET v_modo_entrada_asociado = v_modo_entrada;
		
		IF (v_modo_entrada IS NULL OR v_modo_entrada = '') THEN
			LET v_modo_entrada_asociado = 'NA';
			LET v_modo_entrada = 'NN';
		END IF;
		
		LET v_es_nacional = NVL(v_es_nacional,'N');
		
		--Se valida que el resultado para los parÃ¡metros deseados sean Ãºnicos
		SELECT COUNT(*) 
			INTO v_cant_origenes_asociados
		FROM acl_asociacion_origen
		WHERE transaccion = pTransaccion AND tipo_producto = pTipoProducto AND 
			modo_entrada = v_modo_entrada_asociado AND codgironeg = v_codgironeg AND activo = 1;
		
		IF v_cant_origenes_asociados = 1 THEN
			SELECT fky_origen_evento, es_transaccion_hijo
				INTO v_origen_evento, v_es_transaccion_hijo
			FROM acl_asociacion_origen
			WHERE transaccion = pTransaccion AND tipo_producto = pTipoProducto AND 
				modo_entrada = v_modo_entrada_asociado AND codgironeg = v_codgironeg AND activo = 1;
		ELSE
			LET v_cant_origenes_asociados = NULL;
			SELECT COUNT(*) 
				INTO v_cant_origenes_asociados
			FROM acl_asociacion_origen
			WHERE transaccion = pTransaccion AND tipo_producto = pTipoProducto AND 
				modo_entrada = 'NA' AND codgironeg = v_codgironeg AND activo = 1;
			
			IF v_cant_origenes_asociados = 1 THEN
				SELECT fky_origen_evento, es_transaccion_hijo
					INTO v_origen_evento, v_es_transaccion_hijo
				FROM acl_asociacion_origen
				WHERE transaccion = pTransaccion AND tipo_producto = pTipoProducto AND 
				modo_entrada = 'NA' AND codgironeg = v_codgironeg AND activo = 1;
			ELSE
				LET v_cant_origenes_asociados = NULL;
				SELECT COUNT(*) 
					INTO v_cant_origenes_asociados
				FROM acl_asociacion_origen
				WHERE transaccion = pTransaccion AND tipo_producto = pTipoProducto AND 
					modo_entrada = v_modo_entrada_asociado AND codgironeg = 'NA' AND activo = 1;
				
				IF v_cant_origenes_asociados = 1 THEN
					SELECT fky_origen_evento, es_transaccion_hijo
						INTO v_origen_evento, v_es_transaccion_hijo
					FROM acl_asociacion_origen
					WHERE transaccion = pTransaccion AND tipo_producto = pTipoProducto AND 
					modo_entrada = v_modo_entrada_asociado AND codgironeg = 'NA' AND activo = 1;
				ELSE
					SELECT COUNT(*) 
						INTO v_cant_origenes_asociados
					FROM acl_asociacion_origen
					WHERE transaccion = pTransaccion AND tipo_producto = pTipoProducto AND 
						modo_entrada = 'NA' AND codgironeg = 'NA' AND activo = 1;
					
					IF v_cant_origenes_asociados = 1 THEN
						SELECT fky_origen_evento, es_transaccion_hijo
							INTO v_origen_evento, v_es_transaccion_hijo
						FROM acl_asociacion_origen
						WHERE transaccion = pTransaccion AND tipo_producto = pTipoProducto AND 
							modo_entrada = 'NA' AND codgironeg = 'NA' AND activo = 1;
					ELSE
						LET v_origen_evento = v_origen_evento_por_defecto;
					END IF;
					
				END IF;
				
			END IF ;
		END IF;
		
		SELECT DISTINCT 1 
			INTO v_tiene_acl_asociada
		FROM acl_movimiento mov
			INNER JOIN acl_aclaracion acl ON acl.folio_csuac = mov.folio_csuac 
				and acl.fky_estatus_aclaracion BETWEEN 2 and 5
		WHERE folio_suc = pFoliosuc;
		
		--Se identifica si el folio se encuentra asociada a alguna aclaraciÃ³n ingresada o con estatus pre-ingreso
		IF v_tiene_acl_asociada IS NULL THEN
			
			SELECT pky_estatus_corporativo
				INTO c_estatus_pre_ingreso
			FROM acl_estatus_corporativo WHERE nombre = c_nombre_pre_ingreso;
			
			SELECT DISTINCT 1 
				INTO v_tiene_acl_asociada
			FROM acl_movimiento mov
				INNER JOIN acl_aclaracion acl ON acl.folio_csuac = mov.folio_csuac AND 
					acl.fky_estatus_aclaracion = 1 AND fky_estatus_corp_analisis = c_estatus_pre_ingreso
			WHERE folio_suc = pFoliosuc;
		END IF
		
		LET v_tiene_acl_asociada = NVL(v_tiene_acl_asociada,0);
		
		--Se invoca el SP que valida si un movimiento es Cargo Recurrente y se ajusta el resultado
		CALL sp_consulta_cargo_recurrente(pNumTarjeta, v_secuenciaextendida)
			RETURNING  v_cod_ret_sp_cr, v_es_cargo_recurrente;
		
		LET v_cod_ret_sp_cr = SUBSTR(v_cod_ret_sp_cr,1,3);
		
		IF v_es_cargo_recurrente IS NOT NULL AND v_es_cargo_recurrente <> '' THEN
			LET v_es_cargo_recurrente = SUBSTR(v_es_cargo_recurrente,1,1);
		END IF;
		
		--Se revisa si la transacciÃ³n pertenece a un saldo retenido CrÃ©dito
		IF (pTransaccion in ('6801')) THEN 
			LET v_es_saldo_retenido = 1;
		--Se revisa si la transacciÃ³n pertenece a un saldo retenido DÃ©bito
		ELIF (pTransaccion in ('0801')) THEN 
			LET v_es_saldo_retenido = 1;
		ELSE
			LET v_es_saldo_retenido = 0;
		END IF;
		
		--Se consulta en las tablas de Aclaraciones, para validar que se tenga configurada la transacciÃ³n para el origen correspondiente
		--Si el origen obtenido es el configurado por defecto, se considerarÃ¡ registrada en el Sistema
		--Se considera validar si los saldos retenidos se encuentran registrados en el sistema
		IF v_origen_evento = v_origen_evento_por_defecto AND v_es_saldo_retenido = 0 THEN
			--LET v_transacc_registrada_en_sistema = 1;
			SELECT DISTINCT 1
				INTO v_transacc_registrada_en_sistema
			FROM acl_tipo_movimiento 
			WHERE transaccion = pTransaccion AND --fky_origen_evento = v_origen_evento AND 
				trans_no_procede IS NOT NULL AND trans_procede IS NOT NULL AND 
				trans_procede_automatico IS NOT NULL AND 
				trans_procede_sin_autorizacion IS NOT NULL AND trans_cargo_ajuste IS NOT NULL AND activo = 1;
		ELSE
			SELECT 1
				INTO v_transacc_registrada_en_sistema
			FROM acl_tipo_movimiento 
			WHERE transaccion = pTransaccion AND fky_origen_evento = v_origen_evento AND 
				trans_no_procede IS NOT NULL AND trans_procede IS NOT NULL AND 
				trans_procede_automatico IS NOT NULL AND 
				trans_procede_sin_autorizacion IS NOT NULL AND trans_cargo_ajuste IS NOT NULL AND activo = 1;
		END IF;
		
		LET v_transacc_registrada_en_sistema = NVL(v_transacc_registrada_en_sistema, 0);
		
		--Se obtiene la descripciÃ³n del Origen del Evento
		SELECT descripcion 
			INTO v_desc_origen_evento
		FROM acl_origen_Evento 
		WHERE pky_origen_evento = v_origen_evento;
		
		RETURN
			v_cod_ret, --cod_ret_origen,
			v_es_cargo_recurrente, --es_cargo_recurrente,
			v_es_nacional, --es_nacional,
			v_modo_entrada, --modoentrada,
			v_tiene_acl_asociada, --tiene_acl_asociada,
			v_transacc_registrada_en_sistema, --transacc_registrada_en_sistema,
			v_es_saldo_retenido,--es_saldo_retenido,
			v_es_transaccion_hijo, --es_transaccion_hijo
			v_origen_evento, --origen_evento;
			v_desc_origen_evento; --desc_origen_evento;
			
		
	END;
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones BPI',
'CreaciÃ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Noviembre/2018',
'Requerimiento	:	RQM 06 626',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_buscar_movimientos_credito_his_canales(
						pNumeroCuenta 			CHAR(30), 
						pFechaInicial 			DATE, 
						pFechaFinal 			DATE,
						pTipoFlujo				INTEGER,
						pMonto 					MONEY(16,2), 
						pEsMontoCerrado 		CHAR(3))

	RETURNING
		CHAR(5)								AS cod_ret,
		INTEGER								AS secuenciaMovimiento,
		DATE 								AS fechamovimiento,
		DATETIME HOUR TO FRACTION(3) 		AS horamovimiento,
		money(16,2) 						AS monto,
		CHAR(30) 							AS foliosuc,
		CHAR(4) 							AS sucursal,
		CHAR(30) 							AS nombre,
		CHAR(5) 							AS clavetipo,
		CHAR(40) 							AS tipo,
		CHAR(30) 							AS referencia23,
		CHAR(1) 							AS reversado,
		CHAR(40) 							AS refcomercio,
		DATE 								AS fechacconsumo,
		DATETIME HOUR TO FRACTION(3) 		AS horaconsumo,
		INTEGER								AS origenevento,
		CHAR(50)							AS desc_origen_evento,
		CHAR(2)								AS esCargoRecurrente,
		CHAR(1)								AS esNacional,
		CHAR(2)								AS modoEntrada,
		SMALLINT							AS tieneAclAsociada,
		SMALLINT							AS transaccionRegistradaEnSistema,
		SMALLINT							AS esSaldoRetenido,
		SMALLINT							AS esTransaccionHijo,
		INTEGER								AS secuenciaPadre;
		
	--definicion de variables--	    
	DEFINE cod_ret							CHAR(5);
	DEFINE cod_ret_origen					CHAR(5);
	DEFINE iSqlErr                  		INTEGER; 
	DEFINE v_fechaMovimiento				DATE;
	DEFINE v_monto							money(16,2);
	DEFINE v_monto_inicial					money(16,2);
	DEFINE v_monto_final					money(16,2);
	DEFINE saldo_favor    					money(16,2);
	DEFINE v_horaMovimiento					DATETIME HOUR TO FRACTION(3);
	DEFINE v_foliosuc						CHAR(30);
	DEFINE v_numSucursal					CHAR(4);
   	DEFINE v_nombreSucursal   	        	CHAR(30);
   	DEFINE v_claveTipo      			 	CHAR(5);
    DEFINE v_tipo   						CHAR(40);
    DEFINE v_referencia23					CHAR(30);
    DEFINE reversado						CHAR(1);
	DEFINE v_refComercio					CHAR(40);
    DEFINE res_v_fechaMovimiento_ret	   	DATE;
	DEFINE res_v_horaMovimiento_ret			DATETIME HOUR TO FRACTION(3);
	DEFINE v_NumTarjeta						CHAR(16);
	DEFINE res_v_fechaMovimiento_re1	 	DATE;
	DEFINE res_v_horaMovimiento_re1			DATETIME HOUR TO FRACTION(3);	
	DEFINE v_origen_evento					INTEGER;
	DEFINE v_desc_origen_evento				CHAR(50);
	DEFINE v_secuenciaMovimiento			INTEGER;
	DEFINE v_es_cargo_recurrente			CHAR(2);
	DEFINE v_es_nacional					CHAR(1);
	DEFINE v_tiene_acl_asociada				SMALLINT;
	DEFINE v_modo_entrada					CHAR(2);
	DEFINE v_transacc_registrada_en_sistema	SMALLINT;
	DEFINE v_es_saldo_retenido				SMALLINT;
	DEFINE v_es_transaccion_hijo			SMALLINT;
	DEFINE v_secuencia_padre				INTEGER;
	DEFINE v_movimiento_valido				SMALLINT;
	DEFINE segundaLetraFolioSuc				CHAR(1);
	DEFINE v_foliosuc1, v_foliosuc2, v_foliosuc3, v_foliosuc4, v_foliosuc5	CHAR(30);
	
	DEFINE v_origen_evento_por_defecto		INTEGER;
	DEFINE v_claveTipoPadre    			 	CHAR(5);
	DEFINE v_transacc_padre_registrada_en_sistema	SMALLINT;
	
     -- Inicializacion de las variables.
	LET cod_ret = '00000';
	LET cod_ret_origen = NULL;
	LET v_fechaMovimiento = '';
	LET v_monto = '';
	LET v_monto_inicial	= NULL;
	LET v_monto_final = NULL;
	LET saldo_favor = '';
	LET v_horaMovimiento = TO_DATE("00:00","%H:%M");
	LET v_foliosuc = '';
	LET v_numSucursal = '';
    LET v_nombreSucursal = '';
    LET v_claveTipo = '';
	LET v_tipo = '';
    LET v_referencia23 = '';
    LET reversado = '';
	LET v_refComercio = '';
   	LET res_v_fechaMovimiento_ret = '';
	LET res_v_horaMovimiento_ret  = TO_DATE("00:00","%H:%M");
	LET v_NumTarjeta = NULL;
	LET res_v_fechaMovimiento_re1 = '';
	LET res_v_horaMovimiento_re1  = TO_DATE("00:00","%H:%M");
	LET v_origen_evento = NULL;
	LET v_desc_origen_evento = NULL;
	LET v_es_cargo_recurrente	= NULL;
	LET v_es_nacional = NULL;
	LET v_tiene_acl_asociada = NULL;
	LET v_secuenciaMovimiento = NULL;
	LET v_modo_entrada = NULL;
	LET v_transacc_registrada_en_sistema = NULL;
	LET v_es_saldo_retenido = NULL;
	LET v_es_transaccion_hijo = NULL;
	LET v_secuencia_padre = NULL;
	LET v_movimiento_valido = NULL;
	LET segundaLetraFolioSuc = NULL;
	LET v_foliosuc1 = NULL;
	LET v_foliosuc2 = NULL;
	LET v_foliosuc3 = NULL;
	LET v_foliosuc4 = NULL;
	LET v_foliosuc5 = NULL;

	LET v_origen_evento_por_defecto = NULL;
	LET v_claveTipoPadre = NULL;
	LET v_transacc_padre_registrada_en_sistema = NULL;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    --SET DEBUG FILE TO "/informix/traces/VJMP.out";
    --TRACE ON;
	
	BEGIN
        ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cod_ret = iSqlErr;
				
				RETURN cod_ret, v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
						v_claveTipo, v_tipo, v_referencia23, reversado, v_refComercio, res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret, 
						v_origen_evento, v_desc_origen_evento, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
						v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_secuencia_padre;
			END IF;
        END EXCEPTION;
		
		--Se obtienen los montos a buscar:
		IF pMonto IS NULL OR pMonto = 0 THEN
			--En caso de no ser requerido algún valor, el monto inicial y final serán el mínimo y el máximo respectivamente
			LET v_monto_inicial = 1;
			LET v_monto_final = 99999999999999.99;
		ELSE
			IF pEsMontoCerrado IS NULL OR pEsMontoCerrado = 1 THEN
				--En caso de ser monto cerrado, el monto inicial y el final será el monto ingresado
				LET v_monto_inicial	= pMonto;
				LET v_monto_final = pMonto;
			ELSE
				--En caso de ser necesario redondear, se calculan el inicial y el final
				LET v_monto_inicial	= TRUNC(pMonto);
				LET v_monto_final = TRUNC(pMonto) + 0.99;
			END IF;
		END IF;
		
		
		FOREACH	
			SELECT DISTINCT secuencia, fecha_mov, hora_mov, monto, folio_suc, suc.sucursal, nombre, 
					transacc.numero, transacc.descripcion, referencia23, reversado, referencia, fecha_mov, hora_mov,
					nro_tarjeta
				INTO v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
					v_claveTipo, v_tipo, v_referencia23, reversado, v_refComercio, res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret,
					v_NumTarjeta
			FROM bdicred:sd_movhis movh 
				LEFT JOIN bdicred:sd_transfun transfun ON (movh.codigo_fun = transfun.codigo_fun AND movh.codigo_ref = transfun.codigo_ref) 
				LEFT JOIN bdinteg:si_sucursales suc ON (suc.sucursal = movh.sucursal) 
				LEFT JOIN bdinteg:si_transacc transacc ON (transacc.numero = transfun.transacc AND transfun.transacc <> '0801') 
			WHERE num_credito = pNumeroCuenta 
				AND fecha_mov <= pFechaFinal 
				AND fecha_mov >= pFechaInicial
				AND movh.reversado <>'S'
				ORDER BY folio_suc,fecha_mov
			
			LET v_secuencia_padre = NULL;
			LET v_referencia23 = LPAD (v_referencia23,23,"0");
				
			IF (v_claveTipo IN ('6900','6800','6871','6872','6873','6830','6887')) THEN  -- se agrego 6887
				
				SELECT monto
							INTO saldo_favor
						FROM bdicred:sd_movhis movh 
						WHERE num_credito = pNumeroCuenta 
							AND fecha_mov <= pFechaFinal 
							AND fecha_mov >= pFechaInicial
							AND movh.empresa = '001'
							AND folio_suc = v_foliosuc
							AND movh.transacc_suc <> '6801'
							AND movh.transacc_suc in ('7380','7381','7382','7383','7384','7729','7730');
				
				IF (saldo_favor IS NULL) THEN 
					let saldo_favor = 0;
				end if;
				
				let v_monto = v_monto + saldo_favor;
			END IF;

			LET res_v_fechaMovimiento_re1=res_v_fechaMovimiento_ret;
			LET res_v_horaMovimiento_re1=res_v_horaMovimiento_ret;
			
			
			-- Obtener la fecha de Retenido del movimiento
			IF (v_claveTipo in ('6830','7729')) THEN 
				SELECT DISTINCT fecha_mov, hora_mov
					INTO res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret
				FROM bdicred:sd_movhis movh 
					WHERE num_credito = pNumeroCuenta 
						AND fecha_mov <= pFechaFinal 
						AND fecha_mov >= pFechaInicial-30
						AND movh.folio_suc=v_foliosuc	
						AND movh.transacc_suc='6801';  
			END IF;	
						
			IF (res_v_fechaMovimiento_ret is null  OR res_v_fechaMovimiento_ret='') THEN 
				LET res_v_fechaMovimiento_ret=res_v_fechaMovimiento_re1;
				LET res_v_horaMovimiento_ret=res_v_horaMovimiento_re1;							
			END IF;
			
			--Se obtiene la secuencia 1 del folio_suc para tener el folio_suc como la secuencia 1 
			LET segundaLetraFolioSuc = substr(v_foliosuc,2,1);
			IF substr(v_foliosuc,1,1) = 'i' AND segundaLetraFolioSuc IN ('0','1','2','3','4','5','6','7','8','9') THEN
				LET v_foliosuc1 = substr(v_foliosuc,1,9) || '1' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc2 = substr(v_foliosuc,1,9) || '2' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc3 = substr(v_foliosuc,1,9) || '3' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc4 = substr(v_foliosuc,1,9) || '4' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc5 = substr(v_foliosuc,1,9) || '5' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
			ELSE
				LET v_foliosuc1 = v_foliosuc;
				LET v_foliosuc2 = v_foliosuc;
				LET v_foliosuc3 = v_foliosuc;
				LET v_foliosuc4 = v_foliosuc;
				LET v_foliosuc5 = v_foliosuc;
			END IF
			
			--Se valida que el monto este dentro de los permitidos
			SELECT distinct 1
				INTO v_movimiento_valido
			FROM bdicred:sd_movhis 
			WHERE num_credito = pNumeroCuenta and folio_suc in (v_foliosuc, v_foliosuc1, v_foliosuc2, v_foliosuc3, v_foliosuc4, v_foliosuc5)
				--AND fecha_mov = v_fechaMovimiento
				AND monto BETWEEN v_monto_inicial AND v_monto_final;
			
			IF (v_movimiento_valido IS NOT NULL) THEN
				
				SELECT min(secuencia) 
					INTO v_secuencia_padre
				FROM bdicred:sd_movhis 
					WHERE transacc_suc <> '6801' --Saldo Retenido
						AND num_credito = pNumeroCuenta
						AND folio_suc = v_foliosuc1;
				
				CALL sp_obten_origen_automatico(pNumeroCuenta, v_NumTarjeta, v_secuenciaMovimiento, v_foliosuc, v_claveTipo, v_fechaMovimiento, 1/*Tipo Producto Crédito*/)
						RETURNING cod_ret_origen, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
							v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_origen_evento, v_desc_origen_evento; 
				
				IF v_es_saldo_retenido = 1 OR v_tiene_acl_asociada = 1 THEN
					CONTINUE FOREACH;
				END IF;
				
				IF v_transacc_registrada_en_sistema = 0 THEN
					SELECT transfun.transacc
						INTO v_claveTipoPadre
					FROM bdicred:sd_movhis movh
						LEFT JOIN bdicred:sd_transfun transfun ON (movh.codigo_fun = transfun.codigo_fun AND movh.codigo_ref = transfun.codigo_ref) 
					WHERE num_credito = pNumeroCuenta
						AND folio_suc = v_foliosuc1
						AND secuencia = v_secuencia_padre;
					
					SELECT fky_origen_evento
						INTO v_origen_evento_por_defecto
					FROM acl_asociacion_origen_evento_canal WHERE fky_cat_tipo_aclaracion = 6;
					
					IF v_origen_evento_por_defecto = v_origen_evento THEN 
						SELECT DISTINCT 1
							INTO v_transacc_padre_registrada_en_sistema
						FROM acl_tipo_movimiento 
						WHERE transaccion = v_claveTipoPadre AND 
							trans_no_procede IS NOT NULL AND trans_procede IS NOT NULL AND 
							trans_procede_automatico IS NOT NULL AND 
							trans_procede_sin_autorizacion IS NOT NULL AND trans_cargo_ajuste IS NOT NULL AND activo = 1;
					ELSE
						SELECT 1
							INTO v_transacc_padre_registrada_en_sistema
						FROM acl_tipo_movimiento 
						WHERE transaccion = v_claveTipoPadre AND fky_origen_evento = v_origen_evento AND 
							trans_no_procede IS NOT NULL AND trans_procede IS NOT NULL AND 
							trans_procede_automatico IS NOT NULL AND 
							trans_procede_sin_autorizacion IS NOT NULL AND trans_cargo_ajuste IS NOT NULL AND activo = 1;
					END IF;
					
					LET v_transacc_padre_registrada_en_sistema = NVL(v_transacc_padre_registrada_en_sistema,0);
					
					IF v_transacc_padre_registrada_en_sistema = 0 THEN
						CONTINUE FOREACH;
					END IF;
					
				END IF;
				
				RETURN cod_ret, v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
						v_claveTipo, v_tipo, v_referencia23, reversado, v_refComercio, res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret, 
						v_origen_evento, v_desc_origen_evento, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
							v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_secuencia_padre
					WITH RESUME;
					
			ELSE
				CONTINUE FOREACH;
			END IF;	
						
				
		END FOREACH;
	END 
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones BPI',
'Creación		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Noviembre/2018',
'Requerimiento	:	RQM 06 626',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_buscar_movimientos_credito_dia_canales(
						pNumeroCuenta 			CHAR(30), 
						pFechaInicial 			DATE, 
						pFechaFinal 			DATE,
						pTipoFlujo				INTEGER,
						pMonto 					MONEY(16,2), 
						pEsMontoCerrado 		CHAR(3))

	RETURNING
		CHAR(5)								AS cod_ret,
		INTEGER								AS secuenciaMovimiento,
		DATE 								AS fechamovimiento,
		DATETIME HOUR TO FRACTION(3) 		AS horamovimiento,
		money(16,2) 						AS monto,
		CHAR(30) 							AS foliosuc,
		CHAR(4) 							AS sucursal,
		CHAR(30) 							AS nombre,
		CHAR(5) 							AS clavetipo,
		CHAR(40) 							AS tipo,
		CHAR(30) 							AS referencia23,
		CHAR(1) 							AS reversado,
		CHAR(40) 							AS refcomercio,
		DATE 								AS fechacconsumo,
		DATETIME HOUR TO FRACTION(3) 		AS horaconsumo,
		INTEGER								AS origenevento,
		CHAR(50)							AS desc_origen_evento,
		CHAR(2)								AS esCargoRecurrente,
		CHAR(1)								AS esNacional,
		CHAR(2)								AS modoEntrada,
		SMALLINT							AS tieneAclAsociada,
		SMALLINT							AS transaccionRegistradaEnSistema,
		SMALLINT							AS esSaldoRetenido,
		SMALLINT							AS esTransaccionHijo,
		INTEGER								AS secuenciaPadre;
		
	--definicion de variables--	    
	DEFINE cod_ret							CHAR(5);
	DEFINE cod_ret_origen					CHAR(5);
	DEFINE iSqlErr                  		INTEGER; 
	DEFINE v_fechaMovimiento				DATE;
	DEFINE v_monto							money(16,2);
	DEFINE v_monto_inicial					money(16,2);
	DEFINE v_monto_final					money(16,2);
	DEFINE saldo_favor    					money(16,2);
	DEFINE v_horaMovimiento					DATETIME HOUR TO FRACTION(3);
	DEFINE v_foliosuc						CHAR(30);
	DEFINE v_numSucursal					CHAR(4);
   	DEFINE v_nombreSucursal   	        	CHAR(30);
   	DEFINE v_claveTipo      			 	CHAR(5);
    DEFINE v_tipo   						CHAR(40);
    DEFINE v_referencia23					CHAR(30);
    DEFINE reversado						CHAR(1);
	DEFINE v_refComercio					CHAR(40);
    DEFINE res_v_fechaMovimiento_ret	   	DATE;
	DEFINE res_v_horaMovimiento_ret			DATETIME HOUR TO FRACTION(3);
	DEFINE v_NumTarjeta						CHAR(16);
	DEFINE res_v_fechaMovimiento_re1	 	DATE;
	DEFINE res_v_horaMovimiento_re1			DATETIME HOUR TO FRACTION(3);	
	DEFINE v_origen_evento					INTEGER;
	DEFINE v_desc_origen_evento				CHAR(50);
	DEFINE v_secuenciaMovimiento			INTEGER;
	DEFINE v_es_cargo_recurrente			CHAR(2);
	DEFINE v_es_nacional					CHAR(1);
	DEFINE v_tiene_acl_asociada				SMALLINT;
	DEFINE v_modo_entrada					CHAR(2);
	DEFINE v_transacc_registrada_en_sistema	SMALLINT;
	DEFINE v_es_saldo_retenido				SMALLINT;
	DEFINE v_es_transaccion_hijo			SMALLINT;
	DEFINE v_secuencia_padre				INTEGER;
	DEFINE v_movimiento_valido				SMALLINT;
	DEFINE segundaLetraFolioSuc				CHAR(1);
	DEFINE v_foliosuc1, v_foliosuc2, v_foliosuc3, v_foliosuc4, v_foliosuc5	CHAR(30);
	
	DEFINE v_origen_evento_por_defecto		INTEGER;
	DEFINE v_claveTipoPadre    			 	CHAR(5);
	DEFINE v_transacc_padre_registrada_en_sistema	SMALLINT;
	
     -- Inicializacion de las variables.
	LET cod_ret = '00000';
	LET cod_ret_origen = NULL;
	LET v_fechaMovimiento = '';
	LET v_monto = '';
	LET v_monto_inicial	= NULL;
	LET v_monto_final = NULL;
	LET saldo_favor = '';
	LET v_horaMovimiento = TO_DATE("00:00","%H:%M");
	LET v_foliosuc = '';
	LET v_numSucursal = '';
    LET v_nombreSucursal = '';
    LET v_claveTipo = '';
	LET v_tipo = '';
    LET v_referencia23 = '';
    LET reversado = '';
	LET v_refComercio = '';
   	LET res_v_fechaMovimiento_ret = '';
	LET res_v_horaMovimiento_ret  = TO_DATE("00:00","%H:%M");
	LET v_NumTarjeta = NULL;
	LET res_v_fechaMovimiento_re1 = '';
	LET res_v_horaMovimiento_re1  = TO_DATE("00:00","%H:%M");
	LET v_origen_evento = NULL;
	LET v_desc_origen_evento = NULL;
	LET v_es_cargo_recurrente	= NULL;
	LET v_es_nacional = NULL;
	LET v_tiene_acl_asociada = NULL;
	LET v_secuenciaMovimiento = NULL;
	LET v_modo_entrada = NULL;
	LET v_transacc_registrada_en_sistema = NULL;
	LET v_es_saldo_retenido = NULL;
	LET v_es_transaccion_hijo = NULL;
	LET v_secuencia_padre = NULL;
	LET v_movimiento_valido = NULL;
	LET segundaLetraFolioSuc = NULL;
	LET v_foliosuc1 = NULL;
	LET v_foliosuc2 = NULL;
	LET v_foliosuc3 = NULL;
	LET v_foliosuc4 = NULL;
	LET v_foliosuc5 = NULL;

	LET v_origen_evento_por_defecto = NULL;
	LET v_claveTipoPadre = NULL;
	LET v_transacc_padre_registrada_en_sistema = NULL;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    --SET DEBUG FILE TO "/informix/traces/VJMP.out";
    --TRACE ON;
	
	BEGIN
        ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cod_ret = iSqlErr;
				
				RETURN cod_ret, v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
						v_claveTipo, v_tipo, v_referencia23, reversado, v_refComercio, res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret, 
						v_origen_evento, v_desc_origen_evento, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
						v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_secuencia_padre;
			END IF;
        END EXCEPTION;
		
		--Se obtienen los montos a buscar:
		IF pMonto IS NULL OR pMonto = 0 THEN
			--En caso de no ser requerido algún valor, el monto inicial y final serán el mínimo y el máximo respectivamente
			LET v_monto_inicial = 1;
			LET v_monto_final = 99999999999999.99;
		ELSE
			IF pEsMontoCerrado IS NULL OR pEsMontoCerrado = 1 THEN
				--En caso de ser monto cerrado, el monto inicial y el final será el monto ingresado
				LET v_monto_inicial	= pMonto;
				LET v_monto_final = pMonto;
			ELSE
				--En caso de ser necesario redondear, se calculan el inicial y el final
				LET v_monto_inicial	= TRUNC(pMonto);
				LET v_monto_final = TRUNC(pMonto) + 0.99;
			END IF;
		END IF;
		
		FOREACH	
			SELECT DISTINCT secuencia, fecha_mov, hora_mov, monto, folio_suc, suc.sucursal, nombre, 
					transacc.numero, transacc.descripcion, referencia23, reversado, referencia, fecha_mov, hora_mov,
					nro_tarjeta
				INTO v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
					v_claveTipo, v_tipo, v_referencia23, reversado, v_refComercio, res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret,
					v_NumTarjeta
			FROM bdicred:sd_movdia movh 
				LEFT JOIN bdicred:sd_transfun transfun ON (movh.codigo_fun = transfun.codigo_fun AND movh.codigo_ref = transfun.codigo_ref) 
				LEFT JOIN bdinteg:si_sucursales suc ON (suc.sucursal = movh.sucursal) 
				LEFT JOIN bdinteg:si_transacc transacc ON (transacc.numero = transfun.transacc AND transfun.transacc <> '0801') 
			WHERE num_credito = pNumeroCuenta 
				AND fecha_mov <= pFechaFinal 
				AND fecha_mov >= pFechaInicial
				AND movh.reversado <>'S'
				--AND movh.transacc_suc not in ('6801','7380','7381','7383','7384','6881')
				ORDER BY folio_suc,fecha_mov
			
			LET v_secuencia_padre = NULL;
			LET v_referencia23 = LPAD (v_referencia23,23,"0");
				
			IF (v_claveTipo IN ('6900','6800','6871','6872','6873','6830','6887')) THEN  -- se agrego 6887
				
				SELECT monto
							INTO saldo_favor
						FROM bdicred:sd_movdia movh 
						WHERE num_credito = pNumeroCuenta 
							AND fecha_mov <= pFechaFinal 
							AND fecha_mov >= pFechaInicial
							--AND (nro_tarjeta = p_sTarjeta OR nro_tarjeta = '' OR nro_tarjeta IS NULL)
							AND movh.empresa = '001'
							AND folio_suc = v_foliosuc
							AND movh.transacc_suc <> '6801'
							AND movh.transacc_suc in ('7380','7381','7382','7383','7384','7729','7730');
				
				IF (saldo_favor IS NULL) THEN 
					let saldo_favor = 0;
				end if;
				
				let v_monto = v_monto + saldo_favor;
			END IF;

			LET res_v_fechaMovimiento_re1=res_v_fechaMovimiento_ret;
			LET res_v_horaMovimiento_re1=res_v_horaMovimiento_ret;
			
			-- Obtener la fecha de Retenido del movimiento
			IF (v_claveTipo in ('6830','7729')) THEN 
				SELECT DISTINCT fecha_mov, hora_mov
					INTO res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret
				FROM bdicred:sd_movhis movh
					WHERE num_credito = pNumeroCuenta 
						AND fecha_mov <= pFechaFinal 
						AND fecha_mov >= pFechaInicial-30
						AND movh.folio_suc=v_foliosuc	
						AND movh.transacc_suc='6801';  
			END IF;	
						
			IF (res_v_fechaMovimiento_ret is null  OR res_v_fechaMovimiento_ret='') THEN 
				LET res_v_fechaMovimiento_ret=res_v_fechaMovimiento_re1;
				LET res_v_horaMovimiento_ret=res_v_horaMovimiento_re1;							
			END IF;
			
			--Se obtiene la secuencia 1 del folio_suc para tener el folio_suc como la secuencia 1 
			LET segundaLetraFolioSuc = substr(v_foliosuc,2,1);
			IF substr(v_foliosuc,1,1) = 'i' AND segundaLetraFolioSuc IN ('0','1','2','3','4','5','6','7','8','9') THEN
				LET v_foliosuc1 = substr(v_foliosuc,1,9) || '1' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc2 = substr(v_foliosuc,1,9) || '2' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc3 = substr(v_foliosuc,1,9) || '3' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc4 = substr(v_foliosuc,1,9) || '4' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc5 = substr(v_foliosuc,1,9) || '5' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
			ELSE
				LET v_foliosuc1 = v_foliosuc;
				LET v_foliosuc2 = v_foliosuc;
				LET v_foliosuc3 = v_foliosuc;
				LET v_foliosuc4 = v_foliosuc;
				LET v_foliosuc5 = v_foliosuc;
			END IF
			
			--Se valida que el monto este dentro de los permitidos
			SELECT distinct 1
				INTO v_movimiento_valido
			FROM bdicred:sd_movdia
			WHERE num_credito = pNumeroCuenta and folio_suc in (v_foliosuc, v_foliosuc1, v_foliosuc2, v_foliosuc3, v_foliosuc4, v_foliosuc5)
				--AND fecha_mov = v_fechaMovimiento
				AND monto BETWEEN v_monto_inicial AND v_monto_final;
			
			IF v_movimiento_valido IS NULL THEN
				SELECT distinct 1
					INTO v_movimiento_valido
				FROM bdicred:sd_movhis 
				WHERE num_credito = pNumeroCuenta and folio_suc in (v_foliosuc, v_foliosuc1, v_foliosuc2, v_foliosuc3, v_foliosuc4, v_foliosuc5)
					--AND fecha_mov = v_fechaMovimiento
					AND monto BETWEEN v_monto_inicial AND v_monto_final;
			END IF;
			
			IF (v_movimiento_valido IS NOT NULL) THEN
				
				SELECT min(secuencia) 
					INTO v_secuencia_padre
				FROM bdicred:sd_movdia 
					WHERE transacc_suc <> '6801' --Saldo Retenido
						AND num_credito = pNumeroCuenta
						AND folio_suc = v_foliosuc1;
				
				CALL sp_obten_origen_automatico(pNumeroCuenta, v_NumTarjeta, v_secuenciaMovimiento, v_foliosuc, v_claveTipo, v_fechaMovimiento, 1/*Tipo Producto Crédito*/)
						RETURNING cod_ret_origen, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
							v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_origen_evento, v_desc_origen_evento; 
				
				IF cod_ret_origen <> '00000' THEN
					LET cod_ret = cod_ret_origen;
				END IF
				
				IF v_transacc_registrada_en_sistema = 0 THEN
					SELECT transfun.transacc
						INTO v_claveTipoPadre
					FROM bdicred:sd_movdia movh
						LEFT JOIN bdicred:sd_transfun transfun ON (movh.codigo_fun = transfun.codigo_fun AND movh.codigo_ref = transfun.codigo_ref) 
					WHERE num_credito = pNumeroCuenta
						AND folio_suc = v_foliosuc1
						AND secuencia = v_secuencia_padre;
					
					SELECT fky_origen_evento
						INTO v_origen_evento_por_defecto
					FROM acl_asociacion_origen_evento_canal WHERE fky_cat_tipo_aclaracion = 6;
					
					IF v_origen_evento_por_defecto = v_origen_evento THEN 
						SELECT DISTINCT 1
							INTO v_transacc_padre_registrada_en_sistema
						FROM acl_tipo_movimiento 
						WHERE transaccion = v_claveTipoPadre AND 
							trans_no_procede IS NOT NULL AND trans_procede IS NOT NULL AND 
							trans_procede_automatico IS NOT NULL AND 
							trans_procede_sin_autorizacion IS NOT NULL AND trans_cargo_ajuste IS NOT NULL AND activo = 1;
					ELSE
						SELECT 1
							INTO v_transacc_padre_registrada_en_sistema
						FROM acl_tipo_movimiento 
						WHERE transaccion = v_claveTipoPadre AND fky_origen_evento = v_origen_evento AND 
							trans_no_procede IS NOT NULL AND trans_procede IS NOT NULL AND 
							trans_procede_automatico IS NOT NULL AND 
							trans_procede_sin_autorizacion IS NOT NULL AND trans_cargo_ajuste IS NOT NULL AND activo = 1;
					END IF;
					
					LET v_transacc_padre_registrada_en_sistema = NVL(v_transacc_padre_registrada_en_sistema,0);
					
					IF v_transacc_padre_registrada_en_sistema = 0 THEN
						CONTINUE FOREACH;
					END IF;
					
				END IF;
				
				IF v_es_saldo_retenido = 1 OR v_tiene_acl_asociada = 1 THEN
					CONTINUE FOREACH;
				END IF;
				
				RETURN cod_ret, v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
						v_claveTipo, v_tipo, v_referencia23, reversado, v_refComercio, res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret, 
						v_origen_evento, v_desc_origen_evento, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
							v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_secuencia_padre
					WITH RESUME;
					
			ELSE
				CONTINUE FOREACH;
			END IF;	
						
				
		END FOREACH;
	END 
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones BPI',
'Creación		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Noviembre/2018',
'Requerimiento	:	RQM 06 626',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_buscar_movimientos_cheques_dia_canales(
						pNumeroCuenta 			CHAR(30), 
						pFechaInicial 			DATE, 
						pFechaFinal 			DATE,
						pTipoFlujo				INTEGER,
						pMonto 					MONEY(16,2), 
						pEsMontoCerrado 		CHAR(3))

	RETURNING	
		CHAR(5)								AS cod_ret,
		INTEGER								AS secuenciaMovimiento,
		DATE 								AS fechamovimiento,
		DATETIME HOUR TO FRACTION(3) 		AS horamovimiento,
		money(16,2) 						AS monto,
		CHAR(30) 							AS foliosuc,
		CHAR(4) 							AS sucursal,
		CHAR(30) 							AS nombre,
		CHAR(5) 							AS clavetipo,
		CHAR(40) 							AS tipo,
		CHAR(30) 							AS referencia23,
		CHAR(1) 							AS reversado,
		CHAR(40) 							AS refcomercio,
		DATE 								AS fechacconsumo,
		DATETIME HOUR TO FRACTION(3) 		AS horaconsumo,
		INTEGER								AS origenevento,
		CHAR(50)							AS desc_origen_evento,
		CHAR(2)								AS esCargoRecurrente,
		CHAR(1)								AS esNacional,
		CHAR(2)								AS modoEntrada,
		SMALLINT							AS tieneAclAsociada,
		SMALLINT							AS transaccionRegistradaEnSistema,
		SMALLINT							AS esSaldoRetenido,
		SMALLINT							AS esTransaccionHijo,
		INTEGER								AS secuenciaPadre;
	
	--definicion de variables--	    
	DEFINE cod_ret							CHAR(5);
	DEFINE cod_ret_origen					CHAR(5);
	DEFINE iSqlErr                  		INTEGER; 
	DEFINE v_fechaMovimiento				DATE;
	DEFINE v_monto							money(16,2);
	DEFINE v_monto_inicial					money(16,2);
	DEFINE v_monto_final					money(16,2);
	DEFINE monto_cashback    				money(16,2);
    DEFINE v_horaMovimiento					DATETIME HOUR TO FRACTION(3);
	DEFINE v_foliosuc						CHAR(30);
	DEFINE v_foliosuc1, v_foliosuc2, v_foliosuc3, v_foliosuc4, v_foliosuc5	CHAR(30);
	DEFINE segundaLetraFolioSuc				CHAR(1);
	DEFINE v_numSucursal					CHAR(4);
   	DEFINE v_nombreSucursal   	        	CHAR(30);
   	DEFINE v_claveTipo      			 	CHAR(5);
	DEFINE v_transacc_suc					CHAR(5);
    DEFINE v_tipo   						CHAR(40);
    DEFINE v_referencia23					CHAR(30);
    DEFINE reversado						CHAR(1);
	DEFINE v_refComercio					CHAR(40);
    DEFINE res_v_fechaMovimiento_ret	   	DATE;
	DEFINE res_v_horaMovimiento_ret			DATETIME HOUR TO FRACTION(3);
	DEFINE v_NumTarjeta						CHAR(16);
	DEFINE res_v_fechaMovimiento_re1	 	DATE;
	DEFINE res_v_horaMovimiento_re1			DATETIME HOUR TO FRACTION(3);	
	DEFINE v_origen_evento					INTEGER;
	DEFINE v_desc_origen_evento				CHAR(50);
	DEFINE v_secuenciaMovimiento			INTEGER;
	DEFINE v_es_cargo_recurrente			CHAR(2);
	DEFINE v_es_nacional					CHAR(1);
	DEFINE v_tiene_acl_asociada				SMALLINT;
	DEFINE v_modo_entrada					CHAR(2);
	DEFINE v_transacc_registrada_en_sistema	SMALLINT;
	DEFINE v_es_saldo_retenido				SMALLINT;
	DEFINE v_es_transaccion_hijo			SMALLINT;
	DEFINE v_secuencia_padre				INTEGER;
	DEFINE v_movimiento_valido				SMALLINT;
	
	DEFINE v_origen_evento_por_defecto		INTEGER;
	DEFINE v_claveTipoPadre    			 	CHAR(5);
	DEFINE v_transacc_padre_registrada_en_sistema	SMALLINT;
		
     -- Inicializacion de las variables.
	LET cod_ret = '00000';
	LET cod_ret_origen = NULL;
	LET v_fechaMovimiento = '';
	LET v_monto = '';
	LET monto_cashback = NULL;
	LET v_monto_inicial	= NULL;
	LET v_monto_final = NULL;
	LET v_horaMovimiento = TO_DATE("00:00","%H:%M");
	LET v_foliosuc = '';
	LET v_numSucursal = '';
    LET v_nombreSucursal = '';
    LET v_claveTipo = '';
    LET v_transacc_suc = '';
	LET v_tipo = '';
    LET v_referencia23 = '';
    LET reversado = '';
	LET v_refComercio = '';
   	LET res_v_fechaMovimiento_ret = '';
	LET res_v_horaMovimiento_ret  = TO_DATE("00:00","%H:%M");
	LET v_NumTarjeta = NULL;
	LET res_v_fechaMovimiento_re1 = '';
	LET res_v_horaMovimiento_re1  = TO_DATE("00:00","%H:%M");
	LET v_origen_evento = NULL;
	LET v_desc_origen_evento = NULL;
	LET v_es_cargo_recurrente	= NULL;
	LET v_es_nacional = NULL;
	LET v_tiene_acl_asociada = NULL;
	LET v_secuenciaMovimiento = NULL;
	LET v_modo_entrada = NULL;
	LET v_transacc_registrada_en_sistema = NULL;
	LET v_es_saldo_retenido = NULL;
	LET v_es_transaccion_hijo = NULL;
	LET v_secuencia_padre = NULL;
	LET segundaLetraFolioSuc = NULL;
	LET v_movimiento_valido = NULL;
	LET v_foliosuc1 = NULL;
	LET v_foliosuc2 = NULL;
	LET v_foliosuc3 = NULL;
	LET v_foliosuc4 = NULL;
	LET v_foliosuc5 = NULL;
	
	LET v_origen_evento_por_defecto = NULL;
	LET v_claveTipoPadre = NULL;
	LET v_transacc_padre_registrada_en_sistema = NULL;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/informix/traces/movs_debito.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				
				LET cod_ret = iSqlErr;
				
				RETURN cod_ret, v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
						v_claveTipo, v_tipo, v_referencia23, reversado, v_refComercio, res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret, 
						v_origen_evento, v_desc_origen_evento, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
						v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_secuencia_padre;
			END IF;
        END EXCEPTION;
		
		--Se obtienen los montos a buscar:
		IF pMonto IS NULL OR pMonto = 0 THEN
			--En caso de no ser requerido algÃºn valor, el monto inicial y final serÃ¡n el mÃ­nimo y el mÃ¡ximo respectivamente
			LET v_monto_inicial = 1;
			LET v_monto_final = 99999999999999.99;
		ELSE
			IF pEsMontoCerrado IS NULL OR pEsMontoCerrado = 1 THEN
				--En caso de ser monto cerrado, el monto inicial y el final serÃ¡ el monto ingresado
				LET v_monto_inicial	= pMonto;
				LET v_monto_final = pMonto;
			ELSE
				--En caso de ser necesario redondear, se calculan el inicial y el final
				LET v_monto_inicial	= TRUNC(pMonto);
				LET v_monto_final = TRUNC(pMonto) + 0.99;
			END IF;
		END IF;
		
		
		FOREACH	
			
			SELECT DISTINCT num_serial, fech_val, fech_hor, monto_tot, folio_suc, suc.sucursal, suc.nombre, 
					transacc.numero, transacc.descripcion, cancelad, referencia_23, referencia, fech_val, 
					fech_hor, num_tarjeta, transacc_suc
				INTO v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
					v_claveTipo, v_tipo, reversado, v_referencia23, v_refComercio, res_v_fechaMovimiento_ret, 
					res_v_horaMovimiento_ret, v_NumTarjeta, v_transacc_suc
			FROM bdicheq:sc_movdia movh
				LEFT JOIN bdinteg:si_sucursales suc ON suc.sucursal =movh.sucursal
				LEFT JOIN bdinteg:si_transacc transacc ON transacc.numero = movh.transacc
			WHERE cuenta = pNumeroCuenta 
				AND fech_val BETWEEN pFechaInicial AND pFechaFinal 
				AND cancelad <> 'S'
				AND se_emite_edocta = 'S'
			ORDER BY folio_suc ASC, fech_val ASC
			
			
			IF v_transacc_suc = '0280' THEN
				LET v_refComercio = '';
			END IF;
			
			
			LET v_secuencia_padre = NULL;
			LET v_referencia23 = LPAD (v_referencia23,23,"0");
			
			IF (v_claveTipo = '0830') THEN 
				SELECT monto_tot
					INTO monto_cashback 
				FROM bdicheq:sc_movdia
				WHERE cuenta = pNumeroCuenta
					AND fech_val BETWEEN pFechaInicial AND pFechaFinal
					AND folio_suc = v_foliosuc
					AND transacc = '0832';
				
				IF monto_cashback IS NULL THEN 
					LET monto_cashback =0;
				END IF;
				
				LET v_monto = v_monto + monto_cashback;
			END IF; --IF (v_claveTipo ='0830') THEN 
			
			--Se obtiene la fecha del saldo retenido
			LET res_v_fechaMovimiento_re1 = res_v_fechaMovimiento_ret;
			LET res_v_horaMovimiento_re1 = res_v_horaMovimiento_ret;
			
			IF (v_claveTipo in ('0830', '0832')) THEN
				SELECT  fech_val, fech_hor
					INTO res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret
				FROM bdicheq:sc_movhis_old
				WHERE cuenta = pNumeroCuenta
					AND fech_val BETWEEN (pFechaInicial - 31) AND pFechaFinal
					AND folio_suc = v_foliosuc
					AND transacc='0801';
				
				/*Si no encontrÃ³ fecha y hora para retenido, pone datos de liberacion*/
				IF (res_v_fechaMovimiento_ret IS NULL  OR res_v_fechaMovimiento_ret = '') THEN 
					LET res_v_fechaMovimiento_ret = res_v_fechaMovimiento_re1;
					LET res_v_horaMovimiento_ret = res_v_horaMovimiento_re1;
				END IF;
			END IF;
			
			--Se obtiene la secuencia 1 del folio_suc para tener el folio_suc como la secuencia 1 
			LET segundaLetraFolioSuc = substr(v_foliosuc,2,1);
			IF substr(v_foliosuc,1,1) = 'i' AND segundaLetraFolioSuc IN ('0','1','2','3','4','5','6','7','8','9') THEN
				LET v_foliosuc1 = substr(v_foliosuc,1,9) || '1' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc2 = substr(v_foliosuc,1,9) || '2' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc3 = substr(v_foliosuc,1,9) || '3' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc4 = substr(v_foliosuc,1,9) || '4' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc5 = substr(v_foliosuc,1,9) || '5' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
			ELSE
				LET v_foliosuc1 = v_foliosuc;
				LET v_foliosuc2 = v_foliosuc;
				LET v_foliosuc3 = v_foliosuc;
				LET v_foliosuc4 = v_foliosuc;
				LET v_foliosuc5 = v_foliosuc;
			END IF
			
			--Se valida que el monto este dentro de los permitidos
			SELECT distinct 1
				INTO v_movimiento_valido
			FROM bdicheq:sc_movdia 
			WHERE cuenta = pNumeroCuenta and folio_suc in (v_foliosuc, v_foliosuc1, v_foliosuc2, v_foliosuc3, v_foliosuc4, v_foliosuc5)
				--AND fech_val = v_fechaMovimiento
				AND monto_tot BETWEEN v_monto_inicial AND v_monto_final;
			
			IF (v_movimiento_valido IS NOT NULL) THEN
				SELECT min(num_serial) 
					INTO v_secuencia_padre
				FROM bdicheq:sc_movdia
					WHERE transacc_suc <> '0801' --Saldo Retenido
						AND cuenta = pNumeroCuenta
						AND folio_suc = v_foliosuc1;
				
				CALL sp_obten_origen_automatico(pNumeroCuenta, v_NumTarjeta, v_secuenciaMovimiento, v_foliosuc, v_claveTipo, v_fechaMovimiento, 2/*Tipo Producto DÃ©bito*/)
						RETURNING cod_ret_origen, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
							v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_origen_evento, v_desc_origen_evento; 
				
				IF v_transacc_registrada_en_sistema = 0 THEN
					SELECT transacc
						INTO v_claveTipoPadre
					FROM bdicheq:sc_movdia
						WHERE cuenta = pNumeroCuenta
							AND folio_suc = v_foliosuc1
							AND num_serial = v_secuencia_padre;
					
					SELECT fky_origen_evento
						INTO v_origen_evento_por_defecto
					FROM acl_asociacion_origen_evento_canal WHERE fky_cat_tipo_aclaracion = 6;
					
					IF v_origen_evento_por_defecto = v_origen_evento THEN 
						SELECT DISTINCT 1
							INTO v_transacc_padre_registrada_en_sistema
						FROM acl_tipo_movimiento 
						WHERE transaccion = v_claveTipoPadre AND 
							trans_no_procede IS NOT NULL AND trans_procede IS NOT NULL AND 
							trans_procede_automatico IS NOT NULL AND 
							trans_procede_sin_autorizacion IS NOT NULL AND trans_cargo_ajuste IS NOT NULL AND activo = 1;
					ELSE
						SELECT 1
							INTO v_transacc_padre_registrada_en_sistema
						FROM acl_tipo_movimiento 
						WHERE transaccion = v_claveTipoPadre AND fky_origen_evento = v_origen_evento AND 
							trans_no_procede IS NOT NULL AND trans_procede IS NOT NULL AND 
							trans_procede_automatico IS NOT NULL AND 
							trans_procede_sin_autorizacion IS NOT NULL AND trans_cargo_ajuste IS NOT NULL AND activo = 1;
					END IF;
					
					LET v_transacc_padre_registrada_en_sistema = NVL(v_transacc_padre_registrada_en_sistema,0);
					
					IF v_transacc_padre_registrada_en_sistema = 0 THEN
						CONTINUE FOREACH;
					END IF;
					
				END IF;
				
				IF v_es_saldo_retenido = 1 OR v_tiene_acl_asociada = 1 THEN
					CONTINUE FOREACH;
				END IF;
				
				RETURN cod_ret, v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
						v_claveTipo, v_tipo, v_referencia23, reversado, v_refComercio, res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret, 
						v_origen_evento, v_desc_origen_evento, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
							v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_secuencia_padre
					WITH RESUME;
			
			ELSE
				CONTINUE FOREACH;
			END IF;	
			
			
		END FOREACH;
		
	END 
	
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones BPI',
'CreaciÃ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Noviembre/2018',
'Requerimiento	:	RQM 06 626',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_buscar_movimientos_cheques_his_canales(
						pNumeroCuenta 			CHAR(30), 
						pFechaInicial 			DATE, 
						pFechaFinal 			DATE,
						pTipoFlujo				INTEGER,
						pMonto 					MONEY(16,2), 
						pEsMontoCerrado 		CHAR(3))

	RETURNING	
		CHAR(5)								AS cod_ret,
		INTEGER								AS secuenciaMovimiento,
		DATE 								AS fechamovimiento,
		DATETIME HOUR TO FRACTION(3) 		AS horamovimiento,
		money(16,2) 						AS monto,
		CHAR(30) 							AS foliosuc,
		CHAR(4) 							AS sucursal,
		CHAR(30) 							AS nombre,
		CHAR(5) 							AS clavetipo,
		CHAR(40) 							AS tipo,
		CHAR(30) 							AS referencia23,
		CHAR(1) 							AS reversado,
		CHAR(40) 							AS refcomercio,
		DATE 								AS fechacconsumo,
		DATETIME HOUR TO FRACTION(3) 		AS horaconsumo,
		INTEGER								AS origenevento,
		CHAR(50)							AS desc_origen_evento,
		CHAR(2)								AS esCargoRecurrente,
		CHAR(1)								AS esNacional,
		CHAR(2)								AS modoEntrada,
		SMALLINT							AS tieneAclAsociada,
		SMALLINT							AS transaccionRegistradaEnSistema,
		SMALLINT							AS esSaldoRetenido,
		SMALLINT							AS esTransaccionHijo,
		INTEGER								AS secuenciaPadre;
	
	--definicion de variables--	    
	DEFINE cod_ret							CHAR(5);
	DEFINE cod_ret_origen					CHAR(5);
	DEFINE iSqlErr                  		INTEGER; 
	DEFINE v_fechaMovimiento				DATE;
	DEFINE v_monto							money(16,2);
	DEFINE v_monto_inicial					money(16,2);
	DEFINE v_monto_final					money(16,2);
	DEFINE monto_cashback    				money(16,2);
    DEFINE v_horaMovimiento					DATETIME HOUR TO FRACTION(3);
	DEFINE v_foliosuc						CHAR(30);
	DEFINE v_foliosuc1, v_foliosuc2, v_foliosuc3, v_foliosuc4, v_foliosuc5	CHAR(30);
	DEFINE segundaLetraFolioSuc				CHAR(1);
	DEFINE v_numSucursal					CHAR(4);
   	DEFINE v_nombreSucursal   	        	CHAR(30);
   	DEFINE v_claveTipo      			 	CHAR(5);
	DEFINE v_transacc_suc					CHAR(5);
    DEFINE v_tipo   						CHAR(40);
    DEFINE v_referencia23					CHAR(30);
    DEFINE reversado						CHAR(1);
	DEFINE v_refComercio					CHAR(40);
    DEFINE res_v_fechaMovimiento_ret	   	DATE;
	DEFINE res_v_horaMovimiento_ret			DATETIME HOUR TO FRACTION(3);
	DEFINE v_NumTarjeta						CHAR(16);
	DEFINE res_v_fechaMovimiento_re1	 	DATE;
	DEFINE res_v_horaMovimiento_re1			DATETIME HOUR TO FRACTION(3);	
	DEFINE v_origen_evento					INTEGER;
	DEFINE v_desc_origen_evento				CHAR(50);
	DEFINE v_secuenciaMovimiento			INTEGER;
	DEFINE v_es_cargo_recurrente			CHAR(2);
	DEFINE v_es_nacional					CHAR(1);
	DEFINE v_tiene_acl_asociada				SMALLINT;
	DEFINE v_modo_entrada					CHAR(2);
	DEFINE v_transacc_registrada_en_sistema	SMALLINT;
	DEFINE v_es_saldo_retenido				SMALLINT;
	DEFINE v_es_transaccion_hijo			SMALLINT;
	DEFINE v_secuencia_padre				INTEGER;
	DEFINE v_movimiento_valido				SMALLINT;
	
	DEFINE v_origen_evento_por_defecto		INTEGER;
	DEFINE v_claveTipoPadre    			 	CHAR(5);
	DEFINE v_transacc_padre_registrada_en_sistema	SMALLINT;
	
	 -- Inicializacion de las variables.
	LET cod_ret = '00000';
	LET cod_ret_origen = NULL;
	LET v_fechaMovimiento = '';
	LET v_monto = '';
	LET monto_cashback = NULL;
	LET v_monto_inicial	= NULL;
	LET v_monto_final = NULL;
	LET v_horaMovimiento = TO_DATE("00:00","%H:%M");
	LET v_foliosuc = '';
	LET v_numSucursal = '';
    LET v_nombreSucursal = '';
    LET v_claveTipo = '';
    LET v_transacc_suc = '';
	LET v_tipo = '';
    LET v_referencia23 = '';
    LET reversado = '';
	LET v_refComercio = '';
   	LET res_v_fechaMovimiento_ret = '';
	LET res_v_horaMovimiento_ret  = TO_DATE("00:00","%H:%M");
	LET v_NumTarjeta = NULL;
	LET res_v_fechaMovimiento_re1 = '';
	LET res_v_horaMovimiento_re1  = TO_DATE("00:00","%H:%M");
	LET v_origen_evento = NULL;
	LET v_desc_origen_evento = NULL;
	LET v_es_cargo_recurrente	= NULL;
	LET v_es_nacional = NULL;
	LET v_tiene_acl_asociada = NULL;
	LET v_secuenciaMovimiento = NULL;
	LET v_modo_entrada = NULL;
	LET v_transacc_registrada_en_sistema = NULL;
	LET v_es_saldo_retenido = NULL;
	LET v_es_transaccion_hijo = NULL;
	LET v_secuencia_padre = NULL;
	LET segundaLetraFolioSuc = NULL;
	LET v_movimiento_valido = NULL;
	LET v_foliosuc1 = NULL;
	LET v_foliosuc2 = NULL;
	LET v_foliosuc3 = NULL;
	LET v_foliosuc4 = NULL;
	LET v_foliosuc5 = NULL;
	
	LET v_origen_evento_por_defecto = NULL;
	LET v_claveTipoPadre = NULL;
	LET v_transacc_padre_registrada_en_sistema = NULL;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/informix/traces/movs_debito2.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				
				LET cod_ret = iSqlErr;
				
				RETURN cod_ret, v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
						v_claveTipo, v_tipo, v_referencia23, reversado, v_refComercio, res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret, 
						v_origen_evento, v_desc_origen_evento, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
						v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_secuencia_padre;
			END IF;
        END EXCEPTION;
		
		--Se obtienen los montos a buscar:
		IF pMonto IS NULL OR pMonto = 0 THEN
			--En caso de no ser requerido algÃºn valor, el monto inicial y final serÃ¡n el mÃ­nimo y el mÃ¡ximo respectivamente
			LET v_monto_inicial = 1;
			LET v_monto_final = 99999999999999.99;
		ELSE
			IF pEsMontoCerrado IS NULL OR pEsMontoCerrado = 1 THEN
				--En caso de ser monto cerrado, el monto inicial y el final serÃ¡ el monto ingresado
				LET v_monto_inicial	= pMonto;
				LET v_monto_final = pMonto;
			ELSE
				--En caso de ser necesario redondear, se calculan el inicial y el final
				LET v_monto_inicial	= TRUNC(pMonto);
				LET v_monto_final = TRUNC(pMonto) + 0.99;
			END IF;
		END IF;
		
		
		FOREACH	
			
			SELECT DISTINCT num_serial, fech_val, fech_hor, monto_tot, folio_suc, suc.sucursal, suc.nombre, 
					transacc.numero, transacc.descripcion, cancelad, referencia_23, referencia, fech_val, 
					fech_hor, num_tarjeta, transacc_suc
				INTO v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
					v_claveTipo, v_tipo, reversado, v_referencia23, v_refComercio, res_v_fechaMovimiento_ret, 
					res_v_horaMovimiento_ret, v_NumTarjeta, v_transacc_suc
			FROM bdicheq:sc_movhis movh
				LEFT JOIN bdinteg:si_sucursales suc ON suc.sucursal =movh.sucursal
				LEFT JOIN bdinteg:si_transacc transacc ON transacc.numero = movh.transacc
			WHERE cuenta = pNumeroCuenta 
				AND fech_val BETWEEN pFechaInicial AND pFechaFinal 
				AND cancelad <> 'S'
				AND se_emite_edocta = 'S'
			ORDER BY folio_suc ASC, fech_val ASC
			
			
			IF v_transacc_suc = '0280' THEN
				LET v_refComercio = '';
			END IF;
			
			
			LET v_secuencia_padre = NULL;
			LET v_referencia23 = LPAD (v_referencia23,23,"0");
			
			IF (v_claveTipo = '0830') THEN 
				SELECT monto_tot
					INTO monto_cashback 
				FROM bdicheq:sc_movhis
				WHERE cuenta = pNumeroCuenta
					AND fech_val BETWEEN pFechaInicial AND pFechaFinal
					AND folio_suc = v_foliosuc
					AND transacc = '0832';
				
				IF monto_cashback IS NULL THEN 
					LET monto_cashback =0;
				END IF;
				
				LET v_monto = v_monto + monto_cashback;
			END IF; --IF (v_claveTipo ='0830') THEN 
			
			--Se obtiene la fecha del saldo retenido
			LET res_v_fechaMovimiento_re1 = res_v_fechaMovimiento_ret;
			LET res_v_horaMovimiento_re1 = res_v_horaMovimiento_ret;
			
			IF (v_claveTipo in ('0830', '0832')) THEN
				SELECT  fech_val, fech_hor
					INTO res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret
				FROM bdicheq:sc_movhis_old
				WHERE cuenta = pNumeroCuenta
					AND fech_val BETWEEN (pFechaInicial - 31) AND pFechaFinal
					AND folio_suc = v_foliosuc
					AND transacc='0801';
				
				/*Si no encontrÃ³ fecha y hora para retenido, pone datos de liberacion*/
				IF (res_v_fechaMovimiento_ret IS NULL  OR res_v_fechaMovimiento_ret = '') THEN 
					LET res_v_fechaMovimiento_ret = res_v_fechaMovimiento_re1;
					LET res_v_horaMovimiento_ret = res_v_horaMovimiento_re1;
				END IF;
			END IF;
			
			--Se obtiene la secuencia 1 del folio_suc para tener el folio_suc como la secuencia 1 
			LET segundaLetraFolioSuc = substr(v_foliosuc,2,1);
			IF substr(v_foliosuc,1,1) = 'i' AND segundaLetraFolioSuc IN ('0','1','2','3','4','5','6','7','8','9') THEN
				LET v_foliosuc1 = substr(v_foliosuc,1,9) || '1' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc2 = substr(v_foliosuc,1,9) || '2' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc3 = substr(v_foliosuc,1,9) || '3' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc4 = substr(v_foliosuc,1,9) || '4' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc5 = substr(v_foliosuc,1,9) || '5' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
			ELSE
				LET v_foliosuc1 = v_foliosuc;
				LET v_foliosuc2 = v_foliosuc;
				LET v_foliosuc3 = v_foliosuc;
				LET v_foliosuc4 = v_foliosuc;
				LET v_foliosuc5 = v_foliosuc;
			END IF
			
			--Se valida que el monto este dentro de los permitidos
			SELECT distinct 1
				INTO v_movimiento_valido
			FROM bdicheq:sc_movhis 
			WHERE cuenta = pNumeroCuenta and folio_suc in (v_foliosuc, v_foliosuc1, v_foliosuc2, v_foliosuc3, v_foliosuc4, v_foliosuc5)
				--AND fech_val = v_fechaMovimiento
				AND monto_tot BETWEEN v_monto_inicial AND v_monto_final;
			
			IF (v_movimiento_valido IS NOT NULL) THEN
				SELECT min(num_serial)
					INTO v_secuencia_padre
				FROM bdicheq:sc_movhis
					WHERE transacc_suc <> '0801' --Saldo Retenido
						AND cuenta = pNumeroCuenta
						AND folio_suc = v_foliosuc1;
				
				CALL sp_obten_origen_automatico(pNumeroCuenta, v_NumTarjeta, v_secuenciaMovimiento, v_foliosuc, v_claveTipo, v_fechaMovimiento, 2/*Tipo Producto DÃ©bito*/)
						RETURNING cod_ret_origen, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
							v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_origen_evento, v_desc_origen_evento; 
				
				IF v_transacc_registrada_en_sistema = 0 THEN
					SELECT transacc
						INTO v_claveTipoPadre
					FROM bdicheq:sc_movhis
						WHERE cuenta = pNumeroCuenta
							AND folio_suc = v_foliosuc1
							AND num_serial = v_secuencia_padre;
					
					SELECT fky_origen_evento
						INTO v_origen_evento_por_defecto
					FROM acl_asociacion_origen_evento_canal WHERE fky_cat_tipo_aclaracion = 6;
					
					IF v_origen_evento_por_defecto = v_origen_evento THEN 
						SELECT DISTINCT 1
							INTO v_transacc_padre_registrada_en_sistema
						FROM acl_tipo_movimiento 
						WHERE transaccion = v_claveTipoPadre AND 
							trans_no_procede IS NOT NULL AND trans_procede IS NOT NULL AND 
							trans_procede_automatico IS NOT NULL AND 
							trans_procede_sin_autorizacion IS NOT NULL AND trans_cargo_ajuste IS NOT NULL AND activo = 1;
					ELSE
						SELECT 1
							INTO v_transacc_padre_registrada_en_sistema
						FROM acl_tipo_movimiento 
						WHERE transaccion = v_claveTipoPadre AND fky_origen_evento = v_origen_evento AND 
							trans_no_procede IS NOT NULL AND trans_procede IS NOT NULL AND 
							trans_procede_automatico IS NOT NULL AND 
							trans_procede_sin_autorizacion IS NOT NULL AND trans_cargo_ajuste IS NOT NULL AND activo = 1;
					END IF;
					
					LET v_transacc_padre_registrada_en_sistema = NVL(v_transacc_padre_registrada_en_sistema,0);
					
					IF v_transacc_padre_registrada_en_sistema = 0 THEN
						CONTINUE FOREACH;
					END IF;
					
				END IF;
				
				IF v_es_saldo_retenido = 1 OR v_tiene_acl_asociada = 1 THEN
					CONTINUE FOREACH;
				END IF;
				
				RETURN cod_ret, v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
						v_claveTipo, v_tipo, v_referencia23, reversado, v_refComercio, res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret, 
						v_origen_evento, v_desc_origen_evento, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
							v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_secuencia_padre
					WITH RESUME;
				
			ELSE
				CONTINUE FOREACH;
			END IF;	
			
				
		END FOREACH;
		
	END 
	
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones BPI',
'CreaciÃ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Noviembre/2018',
'Requerimiento	:	RQM 06 626',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_buscar_movimientos_cheques_his_old_canales(
						pNumeroCuenta 			CHAR(30), 
						pFechaInicial 			DATE, 
						pFechaFinal 			DATE,
						pTipoFlujo				INTEGER,
						pMonto 					MONEY(16,2), 
						pEsMontoCerrado 		CHAR(3))

	RETURNING	
		CHAR(5)								AS cod_ret,
		INTEGER								AS secuenciaMovimiento,
		DATE 								AS fechamovimiento,
		DATETIME HOUR TO FRACTION(3) 		AS horamovimiento,
		money(16,2) 						AS monto,
		CHAR(30) 							AS foliosuc,
		CHAR(4) 							AS sucursal,
		CHAR(30) 							AS nombre,
		CHAR(5) 							AS clavetipo,
		CHAR(40) 							AS tipo,
		CHAR(30) 							AS referencia23,
		CHAR(1) 							AS reversado,
		CHAR(40) 							AS refcomercio,
		DATE 								AS fechacconsumo,
		DATETIME HOUR TO FRACTION(3) 		AS horaconsumo,
		INTEGER								AS origenevento,
		CHAR(50)							AS desc_origen_evento,
		CHAR(2)								AS esCargoRecurrente,
		CHAR(1)								AS esNacional,
		CHAR(2)								AS modoEntrada,
		SMALLINT							AS tieneAclAsociada,
		SMALLINT							AS transaccionRegistradaEnSistema,
		SMALLINT							AS esSaldoRetenido,
		SMALLINT							AS esTransaccionHijo,
		INTEGER								AS secuenciaPadre;
	
	--definicion de variables--	    
	DEFINE cod_ret							CHAR(5);
	DEFINE cod_ret_origen					CHAR(5);
	DEFINE iSqlErr                  		INTEGER; 
	DEFINE v_fechaMovimiento				DATE;
	DEFINE v_monto							money(16,2);
	DEFINE v_monto_inicial					money(16,2);
	DEFINE v_monto_final					money(16,2);
	DEFINE monto_cashback    				money(16,2);
    DEFINE v_horaMovimiento					DATETIME HOUR TO FRACTION(3);
	DEFINE v_foliosuc						CHAR(30);
	DEFINE v_foliosuc1, v_foliosuc2, v_foliosuc3, v_foliosuc4, v_foliosuc5	CHAR(30);
	DEFINE segundaLetraFolioSuc				CHAR(1);
	DEFINE v_numSucursal					CHAR(4);
   	DEFINE v_nombreSucursal   	        	CHAR(30);
   	DEFINE v_claveTipo      			 	CHAR(5);
	DEFINE v_transacc_suc					CHAR(5);
    DEFINE v_tipo   						CHAR(40);
    DEFINE v_referencia23					CHAR(30);
    DEFINE reversado						CHAR(1);
	DEFINE v_refComercio					CHAR(40);
    DEFINE res_v_fechaMovimiento_ret	   	DATE;
	DEFINE res_v_horaMovimiento_ret			DATETIME HOUR TO FRACTION(3);
	DEFINE v_NumTarjeta						CHAR(16);
	DEFINE res_v_fechaMovimiento_re1	 	DATE;
	DEFINE res_v_horaMovimiento_re1			DATETIME HOUR TO FRACTION(3);	
	DEFINE v_origen_evento					INTEGER;
	DEFINE v_desc_origen_evento				CHAR(50);
	DEFINE v_secuenciaMovimiento			INTEGER;
	DEFINE v_es_cargo_recurrente			CHAR(2);
	DEFINE v_es_nacional					CHAR(1);
	DEFINE v_tiene_acl_asociada				SMALLINT;
	DEFINE v_modo_entrada					CHAR(2);
	DEFINE v_transacc_registrada_en_sistema	SMALLINT;
	DEFINE v_es_saldo_retenido				SMALLINT;
	DEFINE v_es_transaccion_hijo			SMALLINT;
	DEFINE v_secuencia_padre				INTEGER;
	DEFINE v_movimiento_valido				SMALLINT;
	
	DEFINE v_origen_evento_por_defecto		INTEGER;
	DEFINE v_claveTipoPadre    			 	CHAR(5);
	DEFINE v_transacc_padre_registrada_en_sistema	SMALLINT;
	
     -- Inicializacion de las variables.
	LET cod_ret = '00000';
	LET cod_ret_origen = NULL;
	LET v_fechaMovimiento = '';
	LET v_monto = '';
	LET monto_cashback = NULL;
	LET v_monto_inicial	= NULL;
	LET v_monto_final = NULL;
	LET v_horaMovimiento = TO_DATE("00:00","%H:%M");
	LET v_foliosuc = '';
	LET v_numSucursal = '';
    LET v_nombreSucursal = '';
    LET v_claveTipo = '';
    LET v_transacc_suc = '';
	LET v_tipo = '';
    LET v_referencia23 = '';
    LET reversado = '';
	LET v_refComercio = '';
   	LET res_v_fechaMovimiento_ret = '';
	LET res_v_horaMovimiento_ret  = TO_DATE("00:00","%H:%M");
	LET v_NumTarjeta = NULL;
	LET res_v_fechaMovimiento_re1 = '';
	LET res_v_horaMovimiento_re1  = TO_DATE("00:00","%H:%M");
	LET v_origen_evento = NULL;
	LET v_desc_origen_evento = NULL;
	LET v_es_cargo_recurrente	= NULL;
	LET v_es_nacional = NULL;
	LET v_tiene_acl_asociada = NULL;
	LET v_secuenciaMovimiento = NULL;
	LET v_modo_entrada = NULL;
	LET v_transacc_registrada_en_sistema = NULL;
	LET v_es_saldo_retenido = NULL;
	LET v_es_transaccion_hijo = NULL;
	LET v_secuencia_padre = NULL;
	LET segundaLetraFolioSuc = NULL;
	LET v_movimiento_valido = NULL;
	LET v_foliosuc1 = NULL;
	LET v_foliosuc2 = NULL;
	LET v_foliosuc3 = NULL;
	LET v_foliosuc4 = NULL;
	LET v_foliosuc5 = NULL;
	
	LET v_origen_evento_por_defecto = NULL;
	LET v_claveTipoPadre = NULL;
	LET v_transacc_padre_registrada_en_sistema = NULL;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/informix/traces/movs_debito.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				
				LET cod_ret = iSqlErr;
				
				RETURN cod_ret, v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
						v_claveTipo, v_tipo, v_referencia23, reversado, v_refComercio, res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret, 
						v_origen_evento, v_desc_origen_evento, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
						v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_secuencia_padre;
			END IF;
        END EXCEPTION;
		
		--Se obtienen los montos a buscar:
		IF pMonto IS NULL OR pMonto = 0 THEN
			--En caso de no ser requerido algÃºn valor, el monto inicial y final serÃ¡n el mÃ­nimo y el mÃ¡ximo respectivamente
			LET v_monto_inicial = 1;
			LET v_monto_final = 99999999999999.99;
		ELSE
			IF pEsMontoCerrado IS NULL OR pEsMontoCerrado = 1 THEN
				--En caso de ser monto cerrado, el monto inicial y el final serÃ¡ el monto ingresado
				LET v_monto_inicial	= pMonto;
				LET v_monto_final = pMonto;
			ELSE
				--En caso de ser necesario redondear, se calculan el inicial y el final
				LET v_monto_inicial	= TRUNC(pMonto);
				LET v_monto_final = TRUNC(pMonto) + 0.99;
			END IF;
		END IF;
		
		
		FOREACH	
			
			SELECT DISTINCT num_serial, fech_val, fech_hor, monto_tot, folio_suc, suc.sucursal, suc.nombre, 
					transacc.numero, transacc.descripcion, cancelad, referencia_23, referencia, fech_val, 
					fech_hor, num_tarjeta, transacc_suc
				INTO v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
					v_claveTipo, v_tipo, reversado, v_referencia23, v_refComercio, res_v_fechaMovimiento_ret, 
					res_v_horaMovimiento_ret, v_NumTarjeta, v_transacc_suc
			FROM bdicheq:sc_movhis_old movh
				LEFT JOIN bdinteg:si_sucursales suc ON suc.sucursal =movh.sucursal
				LEFT JOIN bdinteg:si_transacc transacc ON transacc.numero = movh.transacc
			WHERE cuenta = pNumeroCuenta 
				AND fech_val BETWEEN pFechaInicial AND pFechaFinal 
				AND cancelad <> 'S'
				AND se_emite_edocta = 'S'
			ORDER BY folio_suc ASC, fech_val ASC
			
			
			IF v_transacc_suc = '0280' THEN
				LET v_refComercio = '';
			END IF;
			
			
			LET v_secuencia_padre = NULL;
			LET v_referencia23 = LPAD (v_referencia23,23,"0");
			
			IF (v_claveTipo = '0830') THEN 
				SELECT monto_tot
					INTO monto_cashback 
				FROM bdicheq:sc_movhis_old
				WHERE cuenta = pNumeroCuenta
					AND fech_val BETWEEN pFechaInicial AND pFechaFinal
					AND folio_suc = v_foliosuc
					AND transacc = '0832';
				
				IF monto_cashback IS NULL THEN 
					LET monto_cashback =0;
				END IF;
				
				LET v_monto = v_monto + monto_cashback;
			END IF; --IF (v_claveTipo ='0830') THEN 
			
			--Se obtiene la fecha del saldo retenido
			LET res_v_fechaMovimiento_re1 = res_v_fechaMovimiento_ret;
			LET res_v_horaMovimiento_re1 = res_v_horaMovimiento_ret;
			
			IF (v_claveTipo in ('0830', '0832')) THEN
				SELECT  fech_val, fech_hor
					INTO res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret
				FROM bdicheq:sc_movhis_old
				WHERE cuenta = pNumeroCuenta
					AND fech_val BETWEEN (pFechaInicial - 31) AND pFechaFinal
					AND folio_suc = v_foliosuc
					AND transacc='0801';
				
				/*Si no encontrÃ³ fecha y hora para retenido, pone datos de liberacion*/
				IF (res_v_fechaMovimiento_ret IS NULL  OR res_v_fechaMovimiento_ret = '') THEN 
					LET res_v_fechaMovimiento_ret = res_v_fechaMovimiento_re1;
					LET res_v_horaMovimiento_ret = res_v_horaMovimiento_re1;
				END IF;
			END IF;
			
			--Se obtiene la secuencia 1 del folio_suc para tener el folio_suc como la secuencia 1 
			LET segundaLetraFolioSuc = substr(v_foliosuc,2,1);
			IF substr(v_foliosuc,1,1) = 'i' AND segundaLetraFolioSuc IN ('0','1','2','3','4','5','6','7','8','9') THEN
				LET v_foliosuc1 = substr(v_foliosuc,1,9) || '1' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc2 = substr(v_foliosuc,1,9) || '2' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc3 = substr(v_foliosuc,1,9) || '3' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc4 = substr(v_foliosuc,1,9) || '4' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc5 = substr(v_foliosuc,1,9) || '5' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
			ELSE
				LET v_foliosuc1 = v_foliosuc;
				LET v_foliosuc2 = v_foliosuc;
				LET v_foliosuc3 = v_foliosuc;
				LET v_foliosuc4 = v_foliosuc;
				LET v_foliosuc5 = v_foliosuc;
			END IF
			
			--Se valida que el monto este dentro de los permitidos
			SELECT distinct 1
				INTO v_movimiento_valido
			FROM bdicheq:sc_movhis_old 
			WHERE cuenta = pNumeroCuenta and folio_suc in (v_foliosuc, v_foliosuc1, v_foliosuc2, v_foliosuc3, v_foliosuc4, v_foliosuc5)
				--AND fech_val = v_fechaMovimiento
				AND monto_tot BETWEEN v_monto_inicial AND v_monto_final;
			
			IF (v_movimiento_valido IS NOT NULL) THEN
				SELECT min(num_serial) 
					INTO v_secuencia_padre
				FROM bdicheq:sc_movhis_old
					WHERE transacc_suc <> '0801' --Saldo Retenido
						AND cuenta = pNumeroCuenta
						AND folio_suc = v_foliosuc1;
				
				CALL sp_obten_origen_automatico(pNumeroCuenta, v_NumTarjeta, v_secuenciaMovimiento, v_foliosuc, v_claveTipo, v_fechaMovimiento, 2/*Tipo Producto DÃ©bito*/)
						RETURNING cod_ret_origen, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
							v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_origen_evento, v_desc_origen_evento; 
				
				IF v_transacc_registrada_en_sistema = 0 THEN
					SELECT transacc
						INTO v_claveTipoPadre
					FROM bdicheq:sc_movhis_old
						WHERE cuenta = pNumeroCuenta
							AND folio_suc = v_foliosuc1
							AND num_serial = v_secuencia_padre;
					
					SELECT fky_origen_evento
						INTO v_origen_evento_por_defecto
					FROM acl_asociacion_origen_evento_canal WHERE fky_cat_tipo_aclaracion = 6;
					
					IF v_origen_evento_por_defecto = v_origen_evento THEN 
						SELECT DISTINCT 1
							INTO v_transacc_padre_registrada_en_sistema
						FROM acl_tipo_movimiento 
						WHERE transaccion = v_claveTipoPadre AND 
							trans_no_procede IS NOT NULL AND trans_procede IS NOT NULL AND 
							trans_procede_automatico IS NOT NULL AND 
							trans_procede_sin_autorizacion IS NOT NULL AND trans_cargo_ajuste IS NOT NULL AND activo = 1;
					ELSE
						SELECT 1
							INTO v_transacc_padre_registrada_en_sistema
						FROM acl_tipo_movimiento 
						WHERE transaccion = v_claveTipoPadre AND fky_origen_evento = v_origen_evento AND 
							trans_no_procede IS NOT NULL AND trans_procede IS NOT NULL AND 
							trans_procede_automatico IS NOT NULL AND 
							trans_procede_sin_autorizacion IS NOT NULL AND trans_cargo_ajuste IS NOT NULL AND activo = 1;
					END IF;
					
					LET v_transacc_padre_registrada_en_sistema = NVL(v_transacc_padre_registrada_en_sistema,0);
					
					IF v_transacc_padre_registrada_en_sistema = 0 THEN
						CONTINUE FOREACH;
					END IF;
					
				END IF;
				
				IF v_es_saldo_retenido = 1 OR v_tiene_acl_asociada = 1 THEN
					CONTINUE FOREACH;
				END IF;
				
				RETURN cod_ret, v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
						v_claveTipo, v_tipo, v_referencia23, reversado, v_refComercio, res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret, 
						v_origen_evento, v_desc_origen_evento, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
							v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_secuencia_padre
					WITH RESUME;
			
			ELSE
				CONTINUE FOREACH;
			END IF;
			
				
		END FOREACH;
		
	END 
	
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones BPI',
'CreaciÃ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Noviembre/2018',
'Requerimiento	:	RQM 06 626',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_buscar_movimientos_creditocrd_his_canales(
							pNumeroCuenta 			CHAR(30), 
							pFechaInicial 			DATE, 
							pFechaFinal 			DATE,
							pTipoFlujo				INTEGER,
							pMonto 					MONEY(16,2), 
							pEsMontoCerrado 		CHAR(3))

    RETURNING
		CHAR(5)								AS cod_ret,
		INTEGER								AS secuenciaMovimiento,
		DATE 								AS fechamovimiento,
		DATETIME HOUR TO FRACTION(3) 		AS horamovimiento,
		money(16,2) 						AS monto,
		CHAR(30) 							AS foliosuc,
		CHAR(4) 							AS sucursal,
		CHAR(30) 							AS nombre,
		CHAR(5) 							AS clavetipo,
		CHAR(40) 							AS tipo,
		CHAR(30) 							AS referencia23,
		CHAR(1) 							AS reversado,
		CHAR(40) 							AS refcomercio,
		DATE 								AS fechacconsumo,
		DATETIME HOUR TO FRACTION(3) 		AS horaconsumo,
		INTEGER								AS origenevento,
		CHAR(50)							AS desc_origen_evento,
		CHAR(2)								AS esCargoRecurrente,
		CHAR(1)								AS esNacional,
		CHAR(2)								AS modoEntrada,
		SMALLINT							AS tieneAclAsociada,
		SMALLINT							AS transaccionRegistradaEnSistema,
		SMALLINT							AS esSaldoRetenido,
		SMALLINT							AS esTransaccionHijo,
		INTEGER								AS secuenciaPadre;
	
	--definicion de variables--	    
	DEFINE cod_ret							CHAR(5);
	DEFINE cod_ret_origen					CHAR(5);
	DEFINE iSqlErr                  		INTEGER; 
	DEFINE v_fechaMovimiento				DATE;
	DEFINE v_monto							money(16,2);
	DEFINE v_monto_inicial					money(16,2);
	DEFINE v_monto_final					money(16,2);
	DEFINE saldo_favor    					money(16,2);
	DEFINE v_horaMovimiento					DATETIME HOUR TO FRACTION(3);
	DEFINE v_foliosuc						CHAR(30);
	DEFINE v_numSucursal					CHAR(4);
   	DEFINE v_nombreSucursal   	        	CHAR(30);
   	DEFINE v_claveTipo      			 	CHAR(5);
    DEFINE v_tipo   						CHAR(40);
    DEFINE v_referencia23					CHAR(30);
    DEFINE reversado						CHAR(1);
	DEFINE v_refComercio					CHAR(40);
    DEFINE res_v_fechaMovimiento_ret	   	DATE;
	DEFINE res_v_horaMovimiento_ret			DATETIME HOUR TO FRACTION(3);
	DEFINE v_NumTarjeta						CHAR(16);
	DEFINE res_v_fechaMovimiento_re1	 	DATE;
	DEFINE res_v_horaMovimiento_re1			DATETIME HOUR TO FRACTION(3);	
	DEFINE v_origen_evento					INTEGER;
	DEFINE v_desc_origen_evento				CHAR(50);
	DEFINE v_secuenciaMovimiento			INTEGER;
	DEFINE v_es_cargo_recurrente			CHAR(2);
	DEFINE v_es_nacional					CHAR(1);
	DEFINE v_tiene_acl_asociada				SMALLINT;
	DEFINE v_modo_entrada					CHAR(2);
	DEFINE v_transacc_registrada_en_sistema	SMALLINT;
	DEFINE v_es_saldo_retenido				SMALLINT;
	DEFINE v_es_transaccion_hijo			SMALLINT;
	DEFINE v_secuencia_padre				INTEGER;
	DEFINE v_movimiento_valido				SMALLINT;
	DEFINE segundaLetraFolioSuc				CHAR(1);
	DEFINE v_foliosuc1, v_foliosuc2, v_foliosuc3, v_foliosuc4, v_foliosuc5	CHAR(30);
	
	DEFINE v_origen_evento_por_defecto		INTEGER;
	DEFINE v_claveTipoPadre    			 	CHAR(5);
	DEFINE v_transacc_padre_registrada_en_sistema	SMALLINT;
	
     -- Inicializacion de las variables.
	LET cod_ret = '00000';
	LET cod_ret_origen = NULL;
	LET v_fechaMovimiento = '';
	LET v_monto = '';
	LET v_monto_inicial	= NULL;
	LET v_monto_final = NULL;
	LET saldo_favor = '';
	LET v_horaMovimiento = TO_DATE("00:00","%H:%M");
	LET v_foliosuc = '';
	LET v_numSucursal = '';
    LET v_nombreSucursal = '';
    LET v_claveTipo = '';
	LET v_tipo = '';
    LET v_referencia23 = '';
    LET reversado = '';
	LET v_refComercio = '';
   	LET res_v_fechaMovimiento_ret = '';
	LET res_v_horaMovimiento_ret  = TO_DATE("00:00","%H:%M");
	LET v_NumTarjeta = NULL;
	LET res_v_fechaMovimiento_re1 = '';
	LET res_v_horaMovimiento_re1  = TO_DATE("00:00","%H:%M");
	LET v_origen_evento = NULL;
	LET v_desc_origen_evento = NULL;
	LET v_es_cargo_recurrente	= NULL;
	LET v_es_nacional = NULL;
	LET v_tiene_acl_asociada = NULL;
	LET v_secuenciaMovimiento = NULL;
	LET v_modo_entrada = NULL;
	LET v_transacc_registrada_en_sistema = NULL;
	LET v_es_saldo_retenido = NULL;
	LET v_es_transaccion_hijo = NULL;
	LET v_secuencia_padre = NULL;
	LET v_movimiento_valido = NULL;
	LET segundaLetraFolioSuc = NULL;
	LET v_foliosuc1 = NULL;
	LET v_foliosuc2 = NULL;
	LET v_foliosuc3 = NULL;
	LET v_foliosuc4 = NULL;
	LET v_foliosuc5 = NULL;

	LET v_origen_evento_por_defecto = NULL;
	LET v_claveTipoPadre = NULL;
	LET v_transacc_padre_registrada_en_sistema = NULL;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/informix/traces/creditocrd.out";
    --TRACE ON;
	
	BEGIN
        ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
               LET cod_ret = iSqlErr;
				
				RETURN cod_ret, v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
						v_claveTipo, v_tipo, v_referencia23, reversado, v_refComercio, res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret, 
						v_origen_evento, v_desc_origen_evento, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
						v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_secuencia_padre;
			END IF;
        END EXCEPTION;
		
		--Se obtienen los montos a buscar:
		IF pMonto IS NULL OR pMonto = 0 THEN
			--En caso de no ser requerido algÃºn valor, el monto inicial y final serÃ¡n el mÃ­nimo y el mÃ¡ximo respectivamente
			LET v_monto_inicial = 1;
			LET v_monto_final = 99999999999999.99;
		ELSE
			IF pEsMontoCerrado IS NULL OR pEsMontoCerrado = 1 THEN
				--En caso de ser monto cerrado, el monto inicial y el final serÃ¡ el monto ingresado
				LET v_monto_inicial	= pMonto;
				LET v_monto_final = pMonto;
			ELSE
				--En caso de ser necesario redondear, se calculan el inicial y el final
				LET v_monto_inicial	= TRUNC(pMonto);
				LET v_monto_final = TRUNC(pMonto) + 0.99;
			END IF;
		END IF;
		
		FOREACH	
			SELECT DISTINCT secuencia, fecha_mov, hora_mov, monto, folio_suc, suc.sucursal, nombre, 
					transacc.numero, transacc.descripcion, referencia23, reversado, referencia, fecha_mov, hora_mov,
					nro_tarjeta
				INTO v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
					v_claveTipo, v_tipo, v_referencia23, reversado, v_refComercio, res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret,
					v_NumTarjeta
			FROM bdicred:sd_movhiscrd movh
				LEFT JOIN bdicred:sd_transfun transfun ON (movh.codigo_fun = transfun.codigo_fun AND movh.codigo_ref = transfun.codigo_ref)
				LEFT JOIN bdinteg:si_sucursales suc ON (suc.sucursal = movh.sucursal)
				LEFT JOIN bdinteg:si_transacc transacc ON (transacc.numero = transfun.transacc AND transfun.transacc <> '0801') 
			WHERE num_credito = pNumeroCuenta 
				AND fecha_mov <= pFechaFinal 
				AND fecha_mov >= pFechaInicial
				AND movh.reversado <>'S'
				--AND movh.transacc_suc not in ('6801','7380','7381','7383','7384','6881')
			ORDER BY folio_suc,fecha_mov
			
			LET v_secuencia_padre = NULL;
			LET v_referencia23 = LPAD (v_referencia23,23,"0");
			
			IF (v_claveTipo IN ('6900','6800','6871','6872','6873','6830','7729','7730','7380','7381','7382','7383','7384','6887')) THEN 
				
				SELECT monto
					INTO saldo_favor
				FROM bdicred:sd_movhis movh 
				WHERE num_credito = pNumeroCuenta 
					AND fecha_mov <= pFechaFinal 
					AND fecha_mov >= pFechaInicial
					AND movh.empresa = '001'
					AND folio_suc = v_foliosuc
					AND movh.transacc_suc <> '6801'
					AND movh.transacc_suc in ('7380','7381','7382','7383','7384','7729','7730');
				
				IF (saldo_favor IS NULL) THEN 
					let saldo_favor = 0;
				end if;
				
				let v_monto = v_monto + saldo_favor;
			END IF;

			LET res_v_fechaMovimiento_re1=res_v_fechaMovimiento_ret;
			LET res_v_horaMovimiento_re1=res_v_horaMovimiento_ret;
			
			-- Obtener la fecha de Retenido del movimiento
			IF (v_claveTipo in ('6830','7729')) THEN 
				SELECT DISTINCT fecha_mov, hora_mov
					INTO res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret
				FROM bdicred:sd_movhiscrd_old movh
				WHERE num_credito = pNumeroCuenta 
					AND fecha_mov <= pFechaFinal 
					AND fecha_mov >= pFechaInicial - 30
					AND movh.folio_suc=v_foliosuc	
					AND movh.transacc_suc='6801';  
			END IF;	
						
			IF (res_v_fechaMovimiento_ret is null  OR res_v_fechaMovimiento_ret='') THEN 
				LET res_v_fechaMovimiento_ret=res_v_fechaMovimiento_re1;
				LET res_v_horaMovimiento_ret=res_v_horaMovimiento_re1;							
			END IF;
			
			--Se obtiene la secuencia 1 del folio_suc para tener el folio_suc como la secuencia 1 
			LET segundaLetraFolioSuc = substr(v_foliosuc,2,1);
			IF substr(v_foliosuc,1,1) = 'i' AND segundaLetraFolioSuc IN ('0','1','2','3','4','5','6','7','8','9') THEN
				LET v_foliosuc1 = substr(v_foliosuc,1,9) || '1' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc2 = substr(v_foliosuc,1,9) || '2' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc3 = substr(v_foliosuc,1,9) || '3' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc4 = substr(v_foliosuc,1,9) || '4' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc5 = substr(v_foliosuc,1,9) || '5' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
			ELSE
				LET v_foliosuc1 = v_foliosuc;
				LET v_foliosuc2 = v_foliosuc;
				LET v_foliosuc3 = v_foliosuc;
				LET v_foliosuc4 = v_foliosuc;
				LET v_foliosuc5 = v_foliosuc;
			END IF
			
			--Se valida que el monto este dentro de los permitidos
			SELECT distinct 1
				INTO v_movimiento_valido
			FROM bdicred:sd_movhiscrd 
			WHERE num_credito = pNumeroCuenta and folio_suc in (v_foliosuc, v_foliosuc1, v_foliosuc2, v_foliosuc3, v_foliosuc4, v_foliosuc5)
				AND monto BETWEEN v_monto_inicial AND v_monto_final;
			
			
			IF (v_movimiento_valido is not null) THEN
				
				SELECT min(secuencia) 
					INTO v_secuencia_padre
				FROM bdicred:sd_movhiscrd 
					WHERE transacc_suc <> '6801' --Saldo Retenido
						AND num_credito = pNumeroCuenta
						AND folio_suc = v_foliosuc1;
				
				CALL sp_obten_origen_automatico(pNumeroCuenta, v_NumTarjeta, v_secuenciaMovimiento, v_foliosuc, v_claveTipo, v_fechaMovimiento, 1/*Tipo Producto CrÃ©dito*/)
						RETURNING cod_ret_origen, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
							v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_origen_evento, v_desc_origen_evento; 
				
				IF v_transacc_registrada_en_sistema = 0 THEN
					SELECT transfun.transacc
						INTO v_claveTipoPadre
					FROM bdicred:sd_movhiscrd movh
						LEFT JOIN bdicred:sd_transfun transfun ON (movh.codigo_fun = transfun.codigo_fun AND movh.codigo_ref = transfun.codigo_ref) 
					WHERE num_credito = pNumeroCuenta
						AND folio_suc = v_foliosuc1
						AND secuencia = v_secuencia_padre;
					
					SELECT fky_origen_evento
						INTO v_origen_evento_por_defecto
					FROM acl_asociacion_origen_evento_canal WHERE fky_cat_tipo_aclaracion = 6;
					
					IF v_origen_evento_por_defecto = v_origen_evento THEN 
						SELECT DISTINCT 1
							INTO v_transacc_padre_registrada_en_sistema
						FROM acl_tipo_movimiento 
						WHERE transaccion = v_claveTipoPadre AND 
							trans_no_procede IS NOT NULL AND trans_procede IS NOT NULL AND 
							trans_procede_automatico IS NOT NULL AND 
							trans_procede_sin_autorizacion IS NOT NULL AND trans_cargo_ajuste IS NOT NULL AND activo = 1;
					ELSE
						SELECT 1
							INTO v_transacc_padre_registrada_en_sistema
						FROM acl_tipo_movimiento 
						WHERE transaccion = v_claveTipoPadre AND fky_origen_evento = v_origen_evento AND 
							trans_no_procede IS NOT NULL AND trans_procede IS NOT NULL AND 
							trans_procede_automatico IS NOT NULL AND 
							trans_procede_sin_autorizacion IS NOT NULL AND trans_cargo_ajuste IS NOT NULL AND activo = 1;
					END IF;
					
					LET v_transacc_padre_registrada_en_sistema = NVL(v_transacc_padre_registrada_en_sistema,0);
					
					IF v_transacc_padre_registrada_en_sistema = 0 THEN
						CONTINUE FOREACH;
					END IF;
					
				END IF;
				
				IF v_es_saldo_retenido = 1 OR v_tiene_acl_asociada = 1 THEN
					CONTINUE FOREACH;
				END IF;
				
				RETURN cod_ret, v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
						v_claveTipo, v_tipo, v_referencia23, reversado, v_refComercio, res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret, 
						v_origen_evento, v_desc_origen_evento, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
							v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_secuencia_padre
					WITH RESUME;
				
			ELSE
				CONTINUE FOREACH;
			END IF;	
		END FOREACH;
	END 
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones BPI',
'CreaciÃ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Enero/2019',
'Requerimiento	:	RQM 06 626',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_buscar_movimientos_inversion_dia_canales(
						pNumeroCuenta 			CHAR(30), 
						pFechaInicial 			DATE, 
						pFechaFinal 			DATE,
						pTipoFlujo				INTEGER,
						pMonto 					MONEY(16,2), 
						pEsMontoCerrado 		CHAR(3))

	RETURNING	
		CHAR(5)								AS cod_ret,
		INTEGER								AS secuenciaMovimiento,
		DATE 								AS fechamovimiento,
		DATETIME HOUR TO FRACTION(3) 		AS horamovimiento,
		money(16,2) 						AS monto,
		CHAR(30) 							AS foliosuc,
		CHAR(4) 							AS sucursal,
		CHAR(30) 							AS nombre,
		CHAR(5) 							AS clavetipo,
		CHAR(40) 							AS tipo,
		CHAR(30) 							AS referencia23,
		CHAR(1) 							AS reversado,
		CHAR(40) 							AS refcomercio,
		DATE 								AS fechacconsumo,
		DATETIME HOUR TO FRACTION(3) 		AS horaconsumo,
		INTEGER								AS origenevento,
		CHAR(50)							AS desc_origen_evento,
		CHAR(2)								AS esCargoRecurrente,
		CHAR(1)								AS esNacional,
		CHAR(2)								AS modoEntrada,
		SMALLINT							AS tieneAclAsociada,
		SMALLINT							AS transaccionRegistradaEnSistema,
		SMALLINT							AS esSaldoRetenido,
		SMALLINT							AS esTransaccionHijo,
		INTEGER								AS secuenciaPadre;
	
	--definicion de variables--	    
	DEFINE cod_ret							CHAR(5);
	DEFINE cod_ret_origen					CHAR(5);
	DEFINE iSqlErr                  		INTEGER; 
	DEFINE v_fechaMovimiento				DATE;
	DEFINE v_monto							money(16,2);
	DEFINE v_monto_inicial					money(16,2);
	DEFINE v_monto_final					money(16,2);
	DEFINE monto_cashback    				money(16,2);
    DEFINE v_horaMovimiento					DATETIME HOUR TO FRACTION(3);
	DEFINE v_foliosuc						CHAR(30);
	DEFINE v_foliosuc1, v_foliosuc2, v_foliosuc3, v_foliosuc4, v_foliosuc5	CHAR(30);
	DEFINE segundaLetraFolioSuc				CHAR(1);
	DEFINE v_numSucursal					CHAR(4);
   	DEFINE v_nombreSucursal   	        	CHAR(30);
   	DEFINE v_claveTipo      			 	CHAR(5);
	DEFINE v_transacc_suc					CHAR(5);
    DEFINE v_tipo   						CHAR(40);
    DEFINE v_referencia23					CHAR(30);
    DEFINE reversado						CHAR(1);
	DEFINE v_refComercio					CHAR(40);
    DEFINE res_v_fechaMovimiento_ret	   	DATE;
	DEFINE res_v_horaMovimiento_ret			DATETIME HOUR TO FRACTION(3);
	DEFINE v_NumTarjeta						CHAR(16);
	DEFINE res_v_fechaMovimiento_re1	 	DATE;
	DEFINE res_v_horaMovimiento_re1			DATETIME HOUR TO FRACTION(3);	
	DEFINE v_origen_evento					INTEGER;
	DEFINE v_desc_origen_evento				CHAR(50);
	DEFINE v_secuenciaMovimiento			INTEGER;
	DEFINE v_es_cargo_recurrente			CHAR(2);
	DEFINE v_es_nacional					CHAR(1);
	DEFINE v_tiene_acl_asociada				SMALLINT;
	DEFINE v_modo_entrada					CHAR(2);
	DEFINE v_transacc_registrada_en_sistema	SMALLINT;
	DEFINE v_es_saldo_retenido				SMALLINT;
	DEFINE v_es_transaccion_hijo			SMALLINT;
	DEFINE v_secuencia_padre				INTEGER;
	DEFINE v_movimiento_valido				SMALLINT;
	
	DEFINE v_origen_evento_por_defecto		INTEGER;
	DEFINE v_claveTipoPadre    			 	CHAR(5);
	DEFINE v_transacc_padre_registrada_en_sistema	SMALLINT;
	
     -- Inicializacion de las variables.
	LET cod_ret = '00000';
	LET cod_ret_origen = NULL;
	LET v_fechaMovimiento = '';
	LET v_monto = '';
	LET monto_cashback = NULL;
	LET v_monto_inicial	= NULL;
	LET v_monto_final = NULL;
	LET v_horaMovimiento = TO_DATE("00:00","%H:%M");
	LET v_foliosuc = '';
	LET v_numSucursal = '';
    LET v_nombreSucursal = '';
    LET v_claveTipo = '';
    LET v_transacc_suc = '';
	LET v_tipo = '';
    LET v_referencia23 = '';
    LET reversado = '';
	LET v_refComercio = '';
   	LET res_v_fechaMovimiento_ret = '';
	LET res_v_horaMovimiento_ret  = TO_DATE("00:00","%H:%M");
	LET v_NumTarjeta = NULL;
	LET res_v_fechaMovimiento_re1 = '';
	LET res_v_horaMovimiento_re1  = TO_DATE("00:00","%H:%M");
	LET v_origen_evento = NULL;
	LET v_desc_origen_evento = NULL;
	LET v_es_cargo_recurrente	= NULL;
	LET v_es_nacional = NULL;
	LET v_tiene_acl_asociada = NULL;
	LET v_secuenciaMovimiento = NULL;
	LET v_modo_entrada = NULL;
	LET v_transacc_registrada_en_sistema = NULL;
	LET v_es_saldo_retenido = NULL;
	LET v_es_transaccion_hijo = NULL;
	LET v_secuencia_padre = NULL;
	LET segundaLetraFolioSuc = NULL;
	LET v_movimiento_valido = NULL;
	LET v_foliosuc1 = NULL;
	LET v_foliosuc2 = NULL;
	LET v_foliosuc3 = NULL;
	LET v_foliosuc4 = NULL;
	LET v_foliosuc5 = NULL;
	
	LET v_origen_evento_por_defecto = NULL;
	LET v_claveTipoPadre = NULL;
	LET v_transacc_padre_registrada_en_sistema = NULL;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/informix/traces/inversiones.out";
	--TRACE ON;
	
	BEGIN
        ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				
				LET cod_ret = iSqlErr;
				
				RETURN cod_ret, v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
						v_claveTipo, v_tipo, v_referencia23, reversado, v_refComercio, res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret, 
						v_origen_evento, v_desc_origen_evento, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
						v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_secuencia_padre;
			END IF;
		END EXCEPTION;
		
		--Se obtienen los montos a buscar:
		IF pMonto IS NULL OR pMonto = 0 THEN
			--En caso de no ser requerido algÃºn valor, el monto inicial y final serÃ¡n el mÃ­nimo y el mÃ¡ximo respectivamente
			LET v_monto_inicial = 1;
			LET v_monto_final = 99999999999999.99;
		ELSE
			IF pEsMontoCerrado IS NULL OR pEsMontoCerrado = 1 THEN
				--En caso de ser monto cerrado, el monto inicial y el final serÃ¡ el monto ingresado
				LET v_monto_inicial	= pMonto;
				LET v_monto_final = pMonto;
			ELSE
				--En caso de ser necesario redondear, se calculan el inicial y el final
				LET v_monto_inicial	= TRUNC(pMonto);
				LET v_monto_final = TRUNC(pMonto) + 0.99;
			END IF;
		END IF;
		
		
		FOREACH
			
			SELECT DISTINCT num_serial, fech_alt, fech_hor, monto_tot, folio_suc, suc.sucursal, suc.nombre, 
					transacc.numero, transacc.descripcion, cancelad, /*referencia_23, referencia,*/ fech_alt, 
					fech_hor, /*num_tarjeta, */transacc_suc
				INTO v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
					v_claveTipo, v_tipo, reversado, /*v_referencia23, v_refComercio, */res_v_fechaMovimiento_ret, 
					res_v_horaMovimiento_ret, /*v_NumTarjeta,*/v_transacc_suc
			 FROM bdinvers:sv_movdia movh
			 LEFT JOIN bdinteg:si_sucursales suc ON suc.sucursal =movh.sucursal
			 LEFT JOIN bdinteg:si_transacc transacc ON transacc.numero = movh.transacc
			WHERE cuenta = pNumeroCuenta 
				AND fech_alt BETWEEN pFechaInicial AND pFechaFinal 
				AND cancelad <> 'S'
				AND se_emite_edocta = 'S'
			ORDER BY folio_suc ASC, fech_alt ASC
			
			LET v_secuencia_padre = NULL;
			LET v_referencia23 = LPAD (v_referencia23,23,"0");
			
			--Se obtiene la fecha del saldo retenido
			LET res_v_fechaMovimiento_re1 = res_v_fechaMovimiento_ret;
			LET res_v_horaMovimiento_re1 = res_v_horaMovimiento_ret;
			
			IF (v_claveTipo in ('0801') OR v_transacc_suc IN ('6801')) THEN
				SELECT fech_val, fech_hor
					INTO res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret
				FROM bdinvers:sv_movdia
				WHERE cuenta = pNumeroCuenta
					AND fech_val BETWEEN (pFechaInicial - 31) AND pFechaFinal
					AND folio_suc = v_foliosuc
					AND transacc='0801';
				
				/*Si no encontrÃ³ fecha y hora para retenido, pone datos de liberacion*/
				IF (res_v_fechaMovimiento_ret IS NULL  OR res_v_fechaMovimiento_ret = '') THEN 
					LET res_v_fechaMovimiento_ret = res_v_fechaMovimiento_re1;
					LET res_v_horaMovimiento_ret = res_v_horaMovimiento_re1;
				END IF;
			END IF;
			
			--Se obtiene la secuencia 1 del folio_suc para tener el folio_suc como la secuencia 1 
			LET segundaLetraFolioSuc = substr(v_foliosuc,2,1);
			IF substr(v_foliosuc,1,1) = 'i' AND segundaLetraFolioSuc IN ('0','1','2','3','4','5','6','7','8','9') THEN
				LET v_foliosuc1 = substr(v_foliosuc,1,9) || '1' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc2 = substr(v_foliosuc,1,9) || '2' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc3 = substr(v_foliosuc,1,9) || '3' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc4 = substr(v_foliosuc,1,9) || '4' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc5 = substr(v_foliosuc,1,9) || '5' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
			ELSE
				LET v_foliosuc1 = v_foliosuc;
				LET v_foliosuc2 = v_foliosuc;
				LET v_foliosuc3 = v_foliosuc;
				LET v_foliosuc4 = v_foliosuc;
				LET v_foliosuc5 = v_foliosuc;
			END IF
			
			--Se valida que el monto este dentro de los permitidos
			SELECT distinct 1
				INTO v_movimiento_valido
			FROM bdinvers:sv_movdia
			WHERE cuenta = pNumeroCuenta and folio_suc in (v_foliosuc, v_foliosuc1, v_foliosuc2, v_foliosuc3, v_foliosuc4, v_foliosuc5)
				AND monto_tot BETWEEN v_monto_inicial AND v_monto_final;
			
			IF v_movimiento_valido IS NULL THEN
				SELECT distinct 1
					INTO v_movimiento_valido
				FROM bdinvers:sv_movhis
				WHERE cuenta = pNumeroCuenta and folio_suc in (v_foliosuc, v_foliosuc1, v_foliosuc2, v_foliosuc3, v_foliosuc4, v_foliosuc5)
					AND monto_tot BETWEEN v_monto_inicial AND v_monto_final;
			END IF;
			
			IF (v_movimiento_valido IS NOT NULL) THEN
				SELECT min(num_serial) 
					INTO v_secuencia_padre
				FROM bdinvers:sv_movdia
					WHERE transacc_suc <> '0801' --Saldo Retenido
						AND cuenta = pNumeroCuenta
						AND folio_suc = v_foliosuc1;
				
				CALL sp_obten_origen_automatico(pNumeroCuenta, v_NumTarjeta, v_secuenciaMovimiento, v_foliosuc, v_claveTipo, v_fechaMovimiento, 2/*Tipo Producto DÃ©bito*/)
						RETURNING cod_ret_origen, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
							v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_origen_evento, v_desc_origen_evento; 
				
				IF v_transacc_registrada_en_sistema = 0 THEN
					SELECT transacc
						INTO v_claveTipoPadre
					FROM bdinvers:sv_movdia
						WHERE cuenta = pNumeroCuenta
							AND folio_suc = v_foliosuc1
							AND num_serial = v_secuencia_padre;
					
					SELECT fky_origen_evento
						INTO v_origen_evento_por_defecto
					FROM acl_asociacion_origen_evento_canal WHERE fky_cat_tipo_aclaracion = 6;
					
					IF v_origen_evento_por_defecto = v_origen_evento THEN 
						SELECT DISTINCT 1
							INTO v_transacc_padre_registrada_en_sistema
						FROM acl_tipo_movimiento 
						WHERE transaccion = v_claveTipoPadre AND 
							trans_no_procede IS NOT NULL AND trans_procede IS NOT NULL AND 
							trans_procede_automatico IS NOT NULL AND 
							trans_procede_sin_autorizacion IS NOT NULL AND trans_cargo_ajuste IS NOT NULL AND activo = 1;
					ELSE
						SELECT 1
							INTO v_transacc_padre_registrada_en_sistema
						FROM acl_tipo_movimiento 
						WHERE transaccion = v_claveTipoPadre AND fky_origen_evento = v_origen_evento AND 
							trans_no_procede IS NOT NULL AND trans_procede IS NOT NULL AND 
							trans_procede_automatico IS NOT NULL AND 
							trans_procede_sin_autorizacion IS NOT NULL AND trans_cargo_ajuste IS NOT NULL AND activo = 1;
					END IF;
					
					LET v_transacc_padre_registrada_en_sistema = NVL(v_transacc_padre_registrada_en_sistema,0);
					
					IF v_transacc_padre_registrada_en_sistema = 0 THEN
						CONTINUE FOREACH;
					END IF;
					
				END IF;
				
				IF v_es_saldo_retenido = 1 OR v_tiene_acl_asociada = 1 THEN
					CONTINUE FOREACH;
				END IF;
				
				RETURN cod_ret, v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
						v_claveTipo, v_tipo, v_referencia23, reversado, v_refComercio, res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret, 
						v_origen_evento, v_desc_origen_evento, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
							v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_secuencia_padre
					WITH RESUME;
				
			ELSE
				CONTINUE FOREACH;
			END IF;	
		END FOREACH;
	
	END 
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones BPI',
'CreaciÃ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Noviembre/2018',
'Requerimiento	:	RQM 06 626',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_buscar_movimientos_inversion_his_canales(
						pNumeroCuenta 			CHAR(30), 
						pFechaInicial 			DATE, 
						pFechaFinal 			DATE,
						pTipoFlujo				INTEGER,
						pMonto 					MONEY(16,2), 
						pEsMontoCerrado 		CHAR(3))

	RETURNING	
		CHAR(5)								AS cod_ret,
		INTEGER								AS secuenciaMovimiento,
		DATE 								AS fechamovimiento,
		DATETIME HOUR TO FRACTION(3) 		AS horamovimiento,
		money(16,2) 						AS monto,
		CHAR(30) 							AS foliosuc,
		CHAR(4) 							AS sucursal,
		CHAR(30) 							AS nombre,
		CHAR(5) 							AS clavetipo,
		CHAR(40) 							AS tipo,
		CHAR(30) 							AS referencia23,
		CHAR(1) 							AS reversado,
		CHAR(40) 							AS refcomercio,
		DATE 								AS fechacconsumo,
		DATETIME HOUR TO FRACTION(3) 		AS horaconsumo,
		INTEGER								AS origenevento,
		CHAR(50)							AS desc_origen_evento,
		CHAR(2)								AS esCargoRecurrente,
		CHAR(1)								AS esNacional,
		CHAR(2)								AS modoEntrada,
		SMALLINT							AS tieneAclAsociada,
		SMALLINT							AS transaccionRegistradaEnSistema,
		SMALLINT							AS esSaldoRetenido,
		SMALLINT							AS esTransaccionHijo,
		INTEGER								AS secuenciaPadre;
	
	--definicion de variables--	    
	DEFINE cod_ret							CHAR(5);
	DEFINE cod_ret_origen					CHAR(5);
	DEFINE iSqlErr                  		INTEGER; 
	DEFINE v_fechaMovimiento				DATE;
	DEFINE v_monto							money(16,2);
	DEFINE v_monto_inicial					money(16,2);
	DEFINE v_monto_final					money(16,2);
	DEFINE monto_cashback    				money(16,2);
    DEFINE v_horaMovimiento					DATETIME HOUR TO FRACTION(3);
	DEFINE v_foliosuc						CHAR(30);
	DEFINE v_foliosuc1, v_foliosuc2, v_foliosuc3, v_foliosuc4, v_foliosuc5	CHAR(30);
	DEFINE segundaLetraFolioSuc				CHAR(1);
	DEFINE v_numSucursal					CHAR(4);
   	DEFINE v_nombreSucursal   	        	CHAR(30);
   	DEFINE v_claveTipo      			 	CHAR(5);
	DEFINE v_transacc_suc					CHAR(5);
    DEFINE v_tipo   						CHAR(40);
    DEFINE v_referencia23					CHAR(30);
    DEFINE reversado						CHAR(1);
	DEFINE v_refComercio					CHAR(40);
    DEFINE res_v_fechaMovimiento_ret	   	DATE;
	DEFINE res_v_horaMovimiento_ret			DATETIME HOUR TO FRACTION(3);
	DEFINE v_NumTarjeta						CHAR(16);
	DEFINE res_v_fechaMovimiento_re1	 	DATE;
	DEFINE res_v_horaMovimiento_re1			DATETIME HOUR TO FRACTION(3);	
	DEFINE v_origen_evento					INTEGER;
	DEFINE v_desc_origen_evento				CHAR(50);
	DEFINE v_secuenciaMovimiento			INTEGER;
	DEFINE v_es_cargo_recurrente			CHAR(2);
	DEFINE v_es_nacional					CHAR(1);
	DEFINE v_tiene_acl_asociada				SMALLINT;
	DEFINE v_modo_entrada					CHAR(2);
	DEFINE v_transacc_registrada_en_sistema	SMALLINT;
	DEFINE v_es_saldo_retenido				SMALLINT;
	DEFINE v_es_transaccion_hijo			SMALLINT;
	DEFINE v_secuencia_padre				INTEGER;
	DEFINE v_movimiento_valido				SMALLINT;
	
	DEFINE v_origen_evento_por_defecto		INTEGER;
	DEFINE v_claveTipoPadre    			 	CHAR(5);
	DEFINE v_transacc_padre_registrada_en_sistema	SMALLINT;
	
     -- Inicializacion de las variables.
	LET cod_ret = '00000';
	LET cod_ret_origen = NULL;
	LET v_fechaMovimiento = '';
	LET v_monto = '';
	LET monto_cashback = NULL;
	LET v_monto_inicial	= NULL;
	LET v_monto_final = NULL;
	LET v_horaMovimiento = TO_DATE("00:00","%H:%M");
	LET v_foliosuc = '';
	LET v_numSucursal = '';
    LET v_nombreSucursal = '';
    LET v_claveTipo = '';
    LET v_transacc_suc = '';
	LET v_tipo = '';
    LET v_referencia23 = '';
    LET reversado = '';
	LET v_refComercio = '';
   	LET res_v_fechaMovimiento_ret = '';
	LET res_v_horaMovimiento_ret  = TO_DATE("00:00","%H:%M");
	LET v_NumTarjeta = NULL;
	LET res_v_fechaMovimiento_re1 = '';
	LET res_v_horaMovimiento_re1  = TO_DATE("00:00","%H:%M");
	LET v_origen_evento = NULL;
	LET v_desc_origen_evento = NULL;
	LET v_es_cargo_recurrente	= NULL;
	LET v_es_nacional = NULL;
	LET v_tiene_acl_asociada = NULL;
	LET v_secuenciaMovimiento = NULL;
	LET v_modo_entrada = NULL;
	LET v_transacc_registrada_en_sistema = NULL;
	LET v_es_saldo_retenido = NULL;
	LET v_es_transaccion_hijo = NULL;
	LET v_secuencia_padre = NULL;
	LET segundaLetraFolioSuc = NULL;
	LET v_movimiento_valido = NULL;
	LET v_foliosuc1 = NULL;
	LET v_foliosuc2 = NULL;
	LET v_foliosuc3 = NULL;
	LET v_foliosuc4 = NULL;
	LET v_foliosuc5 = NULL;
	
	LET v_origen_evento_por_defecto = NULL;
	LET v_claveTipoPadre = NULL;
	LET v_transacc_padre_registrada_en_sistema = NULL;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/informix/traces/inversiones.out";
	--TRACE ON;
	
	BEGIN
        ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				
				LET cod_ret = iSqlErr;
				
				RETURN cod_ret, v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
						v_claveTipo, v_tipo, v_referencia23, reversado, v_refComercio, res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret, 
						v_origen_evento, v_desc_origen_evento, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
						v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_secuencia_padre;
			END IF;
		END EXCEPTION;
		
		--Se obtienen los montos a buscar:
		IF pMonto IS NULL OR pMonto = 0 THEN
			--En caso de no ser requerido algÃºn valor, el monto inicial y final serÃ¡n el mÃ­nimo y el mÃ¡ximo respectivamente
			LET v_monto_inicial = 1;
			LET v_monto_final = 99999999999999.99;
		ELSE
			IF pEsMontoCerrado IS NULL OR pEsMontoCerrado = 1 THEN
				--En caso de ser monto cerrado, el monto inicial y el final serÃ¡ el monto ingresado
				LET v_monto_inicial	= pMonto;
				LET v_monto_final = pMonto;
			ELSE
				--En caso de ser necesario redondear, se calculan el inicial y el final
				LET v_monto_inicial	= TRUNC(pMonto);
				LET v_monto_final = TRUNC(pMonto) + 0.99;
			END IF;
		END IF;
		
		
		FOREACH
		
			SELECT DISTINCT num_serial, fech_alt, fech_hor, monto_tot, folio_suc, suc.sucursal, suc.nombre, 
					transacc.numero, transacc.descripcion, cancelad, /*referencia_23, referencia,*/ fech_alt, 
					fech_hor, /*num_tarjeta, */transacc_suc
				INTO v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
					v_claveTipo, v_tipo, reversado, /*v_referencia23, v_refComercio, */res_v_fechaMovimiento_ret, 
					res_v_horaMovimiento_ret, /*v_NumTarjeta,*/v_transacc_suc
			 FROM bdinvers:sv_movhis movh
			 LEFT JOIN bdinteg:si_sucursales suc ON suc.sucursal =movh.sucursal
			 LEFT JOIN bdinteg:si_transacc transacc ON transacc.numero = movh.transacc
			WHERE cuenta = pNumeroCuenta 
				AND fech_alt BETWEEN pFechaInicial AND pFechaFinal 
				AND cancelad <> 'S'
				AND se_emite_edocta = 'S'
			ORDER BY folio_suc ASC, fech_alt ASC
			
			LET v_secuencia_padre = NULL;
			LET v_referencia23 = LPAD (v_referencia23,23,"0");
			
			--Se obtiene la fecha del saldo retenido
			LET res_v_fechaMovimiento_re1 = res_v_fechaMovimiento_ret;
			LET res_v_horaMovimiento_re1 = res_v_horaMovimiento_ret;
			
			IF (v_claveTipo in ('0801') OR  v_transacc_suc IN ('6801')) THEN
				SELECT fech_val, fech_hor
					INTO res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret
				FROM bdinvers:sv_movhis
				WHERE cuenta = pNumeroCuenta
					AND fech_val BETWEEN (pFechaInicial - 31) AND pFechaFinal
					AND folio_suc = v_foliosuc
					AND transacc='0801';
				
				/*Si no encontrÃ³ fecha y hora para retenido, pone datos de liberacion*/
				IF (res_v_fechaMovimiento_ret IS NULL  OR res_v_fechaMovimiento_ret = '') THEN 
					LET res_v_fechaMovimiento_ret = res_v_fechaMovimiento_re1;
					LET res_v_horaMovimiento_ret = res_v_horaMovimiento_re1;
				END IF;
			END IF;
			
			--Se obtiene la secuencia 1 del folio_suc para tener el folio_suc como la secuencia 1 
			LET segundaLetraFolioSuc = substr(v_foliosuc,2,1);
			IF substr(v_foliosuc,1,1) = 'i' AND segundaLetraFolioSuc IN ('0','1','2','3','4','5','6','7','8','9') THEN
				LET v_foliosuc1 = substr(v_foliosuc,1,9) || '1' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc2 = substr(v_foliosuc,1,9) || '2' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc3 = substr(v_foliosuc,1,9) || '3' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc4 = substr(v_foliosuc,1,9) || '4' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				LET v_foliosuc5 = substr(v_foliosuc,1,9) || '5' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
			ELSE
				LET v_foliosuc1 = v_foliosuc;
				LET v_foliosuc2 = v_foliosuc;
				LET v_foliosuc3 = v_foliosuc;
				LET v_foliosuc4 = v_foliosuc;
				LET v_foliosuc5 = v_foliosuc;
			END IF
			
			--Se valida que el monto este dentro de los permitidos
			SELECT distinct 1
				INTO v_movimiento_valido
			FROM bdinvers:sv_movhis
			WHERE cuenta = pNumeroCuenta and folio_suc in (v_foliosuc, v_foliosuc1, v_foliosuc2, v_foliosuc3, v_foliosuc4, v_foliosuc5)
				AND monto_tot BETWEEN v_monto_inicial AND v_monto_final;
			
			IF (v_movimiento_valido IS NOT NULL) THEN
				SELECT min(num_serial) 
					INTO v_secuencia_padre
				FROM bdinvers:sv_movhis
					WHERE transacc_suc <> '0801' --Saldo Retenido
						AND cuenta = pNumeroCuenta
						AND folio_suc = v_foliosuc1;
				
				CALL sp_obten_origen_automatico(pNumeroCuenta, v_NumTarjeta, v_secuenciaMovimiento, v_foliosuc, v_claveTipo, v_fechaMovimiento, 2/*Tipo Producto DÃ©bito*/)
						RETURNING cod_ret_origen, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
							v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_origen_evento, v_desc_origen_evento; 
				
				IF v_transacc_registrada_en_sistema = 0 THEN
					SELECT transacc
						INTO v_claveTipoPadre
					FROM bdinvers:sv_movhis
						WHERE cuenta = pNumeroCuenta
							AND folio_suc = v_foliosuc1
							AND num_serial = v_secuencia_padre;
					
					SELECT fky_origen_evento
						INTO v_origen_evento_por_defecto
					FROM acl_asociacion_origen_evento_canal WHERE fky_cat_tipo_aclaracion = 6;
					
					IF v_origen_evento_por_defecto = v_origen_evento THEN 
						SELECT DISTINCT 1
							INTO v_transacc_padre_registrada_en_sistema
						FROM acl_tipo_movimiento 
						WHERE transaccion = v_claveTipoPadre AND 
							trans_no_procede IS NOT NULL AND trans_procede IS NOT NULL AND 
							trans_procede_automatico IS NOT NULL AND 
							trans_procede_sin_autorizacion IS NOT NULL AND trans_cargo_ajuste IS NOT NULL AND activo = 1;
					ELSE
						SELECT 1
							INTO v_transacc_padre_registrada_en_sistema
						FROM acl_tipo_movimiento 
						WHERE transaccion = v_claveTipoPadre AND fky_origen_evento = v_origen_evento AND 
							trans_no_procede IS NOT NULL AND trans_procede IS NOT NULL AND 
							trans_procede_automatico IS NOT NULL AND 
							trans_procede_sin_autorizacion IS NOT NULL AND trans_cargo_ajuste IS NOT NULL AND activo = 1;
					END IF;
					
					LET v_transacc_padre_registrada_en_sistema = NVL(v_transacc_padre_registrada_en_sistema,0);
					
					IF v_transacc_padre_registrada_en_sistema = 0 THEN
						CONTINUE FOREACH;
					END IF;
					
				END IF;
				
				IF v_es_saldo_retenido = 1 OR v_tiene_acl_asociada = 1 THEN
					CONTINUE FOREACH;
				END IF;
				
				RETURN cod_ret, v_secuenciaMovimiento, v_fechaMovimiento, v_horaMovimiento, v_monto, v_foliosuc, v_numSucursal, v_nombreSucursal, 
						v_claveTipo, v_tipo, v_referencia23, reversado, v_refComercio, res_v_fechaMovimiento_ret, res_v_horaMovimiento_ret, 
						v_origen_evento, v_desc_origen_evento, v_es_cargo_recurrente, v_es_nacional, v_modo_entrada, v_tiene_acl_asociada, 
							v_transacc_registrada_en_sistema, v_es_saldo_retenido, v_es_transaccion_hijo, v_secuencia_padre
					WITH RESUME;
			ELSE
				CONTINUE FOREACH;
			END IF;	
		END FOREACH;
	
	END 
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones BPI',
'CreaciÃ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Noviembre/2018',
'Requerimiento	:	RQM 06 626',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_cuestionario_telefonico2(p_NumCte CHAR(30))

    RETURNING   CHAR(50) AS estado, CHAR(15) AS fecha_nacimiento, CHAR(10) AS cod_postal,
     CHAR(15) AS numero_exterior, CHAR(50) AS estado_nacio,CHAR(30) AS telefono,
     CHAR(50) AS calle, CHAR(50) AS colonia, CHAR(50) AS municipio, CHAR(50) AS correo_electronico,
	 CHAR(100) AS pregunta_1,CHAR(100) AS pregunta_2,CHAR(100) AS pregunta_3,CHAR(100) AS pregunta_4,CHAR(100) AS pregunta_5,
	 CHAR(100) AS pregunta_6,CHAR(100) AS pregunta_7,CHAR(100) AS pregunta_8,CHAR(100) AS pregunta_9,CHAR(100) AS pregunta_10;

    --definicion de variables--
    DEFINE resultado_estado                 CHAR(50);
    DEFINE resultado_estado_nacio           CHAR(50);
    DEFINE resultado_fecha_nacimiento       CHAR(15);
    DEFINE resultado_cod_postal             CHAR(10);
    DEFINE resultado_numero_exterior        CHAR(15);
    DEFINE resultado_apellido_paterno       CHAR(20);
    DEFINE resultado_apellido_materno       CHAR(20);
    DEFINE resultado_telefono               CHAR(30);
    DEFINE resultado_calle                  CHAR(50);
    DEFINE resultado_colonia                CHAR(50);
    DEFINE resultado_municipio              CHAR(50);
    DEFINE resultado_correo_electronico     CHAR(50);
    DEFINE iSqlErr                          INTEGER;
	
	DEFINE cPregunta_1 						CHAR(100);
	DEFINE cPregunta_2 						CHAR(100);
	DEFINE cPregunta_3 						CHAR(100);
	DEFINE cPregunta_4 						CHAR(100);
	DEFINE cPregunta_5 						CHAR(100);
	DEFINE cPregunta_6 						CHAR(100);
	DEFINE cPregunta_7 						CHAR(100);
	DEFINE cPregunta_8 						CHAR(100);
	DEFINE cPregunta_9 						CHAR(100);
	DEFINE cPregunta_10 					CHAR(100);

    -- Inicializacion de las variables.
    LET resultado_estado = '';
    LET resultado_estado_nacio ='';
    LET resultado_fecha_nacimiento = '';
    LET resultado_cod_postal = '';
    LET resultado_numero_exterior = '';
    LET resultado_apellido_paterno='';
    LET resultado_apellido_materno='';
    LET resultado_telefono = '';
    LET resultado_calle = '';
    LET resultado_colonia = '';
    LET resultado_municipio = '';
    LET resultado_correo_electronico = '';
	
	LET cPregunta_1  = 'NULL';
	LET cPregunta_2  = 'NULL';
	LET cPregunta_3  = 'NULL';
	LET cPregunta_4  = 'NULL';
	LET cPregunta_5  = 'NULL';
	LET cPregunta_6  = 'NULL';
	LET cPregunta_7  = 'NULL';
	LET cPregunta_8  = 'NULL';
	LET cPregunta_9  = 'NULL';
	LET cPregunta_10 = 'NULL';

    SET ISOLATION TO DIRTY READ;

    BEGIN
        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_estado = '';
                    LET resultado_estado_nacio ='';
                    LET resultado_fecha_nacimiento = '';
                    LET resultado_cod_postal = '';
                    LET resultado_numero_exterior = '';
                    LET resultado_telefono = '';
                    LET resultado_calle = '';
                    LET resultado_colonia = '';
                    LET resultado_municipio = '';
                    LET resultado_correo_electronico = '';
                    RETURN resultado_estado, resultado_fecha_nacimiento, resultado_cod_postal, resultado_numero_exterior,resultado_estado_nacio, resultado_telefono, resultado_calle, resultado_colonia, resultado_municipio, resultado_correo_electronico,
					cPregunta_1,cPregunta_2,cPregunta_3,cPregunta_4,cPregunta_5,cPregunta_6,cPregunta_7,cPregunta_8,cPregunta_9,cPregunta_10;
                END IF;
        END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cuestionario_telefonico2.out';
		--TRACE ON;
		
        --SELECT
        --         ' 01 '|| Trim(edo.nombre)as estado, ' 02 '|| substr(rfc,5,6) as fecha_nacimiento, ' 03 ' || sd.cod_postal,
        --         ' 04 ' || numeroextcalle as numero_exterior, ' 06 ' || telefono as
        --         telefono_casa, ' 07 ' || Trim(ct.nombrecalle) as calle,
        --         ' 08 ' || Trim(sz.nombrezona) as colonia, '09 ' || Trim(sz.municipiozona) as municipio,
        --         '10 ' || Trim(em.correo_elec) as correo_electronico
		
		SELECT
                 edo.nombre as estado, ' 02 '|| substr(rfc,5,6) as fecha_nacimiento, ' 03 ' || sd.cod_postal,
                 ' 04 ' || numeroextcalle as numero_exterior, ' 06 ' || telefono as
                 telefono_casa, ct.nombrecalle as calle,
                 sz.nombrezona as colonia, sz.municipiozona as municipio,
                 em.correo_elec as correo_electronico
                 INTO resultado_estado, resultado_fecha_nacimiento,resultado_cod_postal,resultado_numero_exterior
                 ,resultado_telefono,resultado_calle,resultado_colonia,resultado_municipio,resultado_correo_electronico
                FROM bdinteg:si_cliente sc
                 Left Outer Join bdinteg:si_direcciones_actual sd on sc.numcte = sd.numcte and tipo_dir = '1'
                 Left Outer Join bdinteg:si_estados edo on edo.estado = sd.estado
                 Left Outer Join bdinteg:si_telefonos st on st.numcte = sc.numcte and st.tipo_tel = '1' and st.status_tel = 'A'
                 Left Outer Join bdinteg:si_catcalles ct on ct.numerocalle = sd.numerocalle
                 Left Outer Join bdinteg:si_catzonas sz on sz.numerociudad = sd.numerociudad and sz.numerocolonia = sd.numerocolonia
                 Left Outer Join bdinteg:si_correos em on em.numcte = sc.numcte and status_correo = 'A' and em.tipo_correo='1'
            where
            sc.NUMCTE = p_NumCte;


            LET resultado_estado_nacio = ( select estados.nombre from bdinteg:si_ctepf ctpf
            inner join bdinteg:si_estados estados on ctpf.lugar_nac = estados.estado
            where numcte = p_NumCte);

	IF resultado_estado is null THEN
		LET resultado_estado = 'null';
	ELSE
		SELECT pregunta 
		INTO cPregunta_1
		FROM "informix".acl_cuestionario_tel
		WHERE activo = 1 AND pky_pregunta_tel = 1;
	END IF;

	IF resultado_fecha_nacimiento is null THEN
		LET resultado_fecha_nacimiento = '02 null';
	ELSE
		SELECT pregunta 
		INTO cPregunta_2
		FROM "informix".acl_cuestionario_tel
		WHERE activo = 1 AND pky_pregunta_tel = 2;
	END IF;

	IF resultado_cod_postal is null THEN
		LET resultado_cod_postal = '03 null';
	ELSE
		SELECT pregunta 
		INTO cPregunta_3
		FROM "informix".acl_cuestionario_tel
		WHERE activo = 1 AND pky_pregunta_tel = 3;
	END IF;

	IF resultado_numero_exterior is null THEN
		LET resultado_numero_exterior = '04 null';
	ELSE
		SELECT pregunta 
		INTO cPregunta_4
		FROM "informix".acl_cuestionario_tel
		WHERE activo = 1 AND pky_pregunta_tel = 4;
	END IF;

	IF resultado_estado_nacio is null THEN
		LET resultado_estado_nacio = 'null';
	ELSE
		SELECT pregunta 
		INTO cPregunta_5
		FROM "informix".acl_cuestionario_tel
		WHERE activo = 1 AND pky_pregunta_tel = 5;
	END IF;

	IF resultado_telefono is null THEN
		LET resultado_telefono = '06 null';
	ELSE
		SELECT pregunta 
		INTO cPregunta_6
		FROM "informix".acl_cuestionario_tel
		WHERE activo = 1 AND pky_pregunta_tel = 6;
	END IF;

	IF resultado_calle is null THEN
		LET resultado_calle = 'null';
	ELSE
		SELECT pregunta 
		INTO cPregunta_7
		FROM "informix".acl_cuestionario_tel
		WHERE activo = 1 AND pky_pregunta_tel = 7;
	END IF;

	IF resultado_colonia is null THEN
		LET resultado_colonia = 'null';
	ELSE
		SELECT pregunta 
		INTO cPregunta_8
		FROM "informix".acl_cuestionario_tel
		WHERE activo = 1 AND pky_pregunta_tel = 8;
	END IF;

	IF resultado_municipio is null THEN
		LET resultado_municipio = 'null';
	ELSE
		SELECT pregunta 
		INTO cPregunta_9
		FROM "informix".acl_cuestionario_tel
		WHERE activo = 1 AND pky_pregunta_tel = 9;
	END IF;

	IF resultado_correo_electronico is null THEN
		LET resultado_correo_electronico = 'null';
	ELSE
		SELECT pregunta 
		INTO cPregunta_10
		FROM "informix".acl_cuestionario_tel
		WHERE activo = 1 AND pky_pregunta_tel = 10;
	END IF;
	
	--RETURN resultado_estado, resultado_fecha_nacimiento,resultado_cod_postal,resultado_numero_exterior,' 05 '||resultado_estado_nacio,
    --resultado_telefono,resultado_calle,resultado_colonia,resultado_municipio,resultado_correo_electronico,
	--cPregunta_1,cPregunta_2,cPregunta_3,cPregunta_4,cPregunta_5,cPregunta_6,cPregunta_7,cPregunta_8,cPregunta_9,cPregunta_10;
	
    RETURN '01 '||TRIM(resultado_estado), resultado_fecha_nacimiento,resultado_cod_postal,resultado_numero_exterior,' 05 '||resultado_estado_nacio,
    resultado_telefono,'07 '||TRIM(resultado_calle),'08 '||TRIM(resultado_colonia),'09 '||TRIM(resultado_municipio),'10 '||TRIM(resultado_correo_electronico),
	cPregunta_1,cPregunta_2,cPregunta_3,cPregunta_4,cPregunta_5,cPregunta_6,cPregunta_7,cPregunta_8,cPregunta_9,cPregunta_10;

END
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 07/08/2018',
'SISTEMA: ACLARACIONES',
'FUNCIONALIDAD: CENTRO DE ATENCIÓN TELEFÓNICA (CAT)',
'DESCRIPCION: Se clona SPL sp_cuestionario_telefonico para agregar las preguntas correspondientes a cada respuesta.',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_actualizacion_r27()
						
	RETURNING	CHAR(5) AS codigo_ret;
	--	VARCHAR(150)		AS Mensaje;

	--Variables--
	DEFINE sql_err 						INTEGER;
	DEFINE v_cod_ret 					CHAR(5);
	
	--DEFINE c_ruta_archivo				VARCHAR(50);
	DEFINE c_nombre_archivo				VARCHAR(50);
	DEFINE c_ext_archivo				VARCHAR(50);
	DEFINE v_nombre_archivo				VARCHAR(50);
	DEFINE c_fecha_actual				DATE;
	DEFINE v_nombre            	 	VARCHAR(11) ;
	DEFINE v_descripcion        		VARCHAR(100);
	Define cCadena 			CHAR(1000);
	DEFINE vsql	        	char(3000);
	DEFINE v_folio_csuac varchar(11);
	DEFINE v_f_afectacion   CHAR(10);
	DEFINE v_fecha_afectacion   DATE;
	--DEFINE v_bitacora   LVARCHAR;
	DEFINE v_importeprocedente MONEY;
	DEFINE v_dias_conclucion integer;
	DEFINE v_pky_movimiento integer;
	DEFINE iContador  			INTEGER;
	DEFINE v_temp_table         INTEGER;
	DEFINE v_mensaje varchar(150);

	--------------------
	LET v_cod_ret 						= "00000";
	--LET c_ruta_archivo 					= "DISK:/resplogifx/repaclaraciones/";
	LET c_nombre_archivo				= "ACL_ACTUALIZACION_R27";
	LET c_ext_archivo					= ".csv";
	LET v_nombre_archivo				= NULL;
	LET v_folio_csuac = '';
	LET v_f_afectacion  = NULL;
	LET v_fecha_afectacion  = NULL;
	LET v_importeprocedente = '';
	
	LET v_pky_movimiento = '';
	LET iContador = 0;
	LET v_temp_table = '';
	LET v_mensaje = 'Procesado Correctamente';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/resplogifx/repaclaraciones/archivo_2.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_cod_ret = sql_err;
				RETURN v_cod_ret;				
			END IF;
		END EXCEPTION;
	on exception in (-668)
        LET v_cod_ret = '00001';
		RETURN v_cod_ret;    end exception with resume;	
		
		
		SELECT tabid
		INTO v_temp_table
		FROM systables WHERE tabname ='tabla_actualizacion_r27';
		
		IF v_temp_table IS NOT NULL THEN
			DROP TABLE "informix".tabla_actualizacion_r27;
		END IF;
		
		SELECT fecha_hoy 
			INTO c_fecha_actual
		FROM bdinteg:si_fechas;
		
		LET v_nombre_archivo = c_nombre_archivo||''|| c_ext_archivo;
		
		
		--CREATE TEMP TABLE tabla_pbas(
		CREATE TABLE "informix".tabla_actualizacion_r27( 
			folio_csuac            	 	VARCHAR(11) ,
			fecha_afectacion        	char(10)
		);
		
		-- Se crea cadana con la ruta donde se encuentra el archivo
		LET cCadena = '';
		LET cCadena = ' echo "FILE /resplogifx/repaclaraciones/'||v_nombre_archivo||' DELIMITER '|| "'" ||',' || "'" || ' 2;' || '">/resplogifx/repaclaraciones/aclaracion_r27.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".tabla_actualizacion_r27;' || '">> /resplogifx/repaclaraciones/aclaracion_r27.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /resplogifx/repaclaraciones/aclaracion_r27.sql';
		SYSTEM cCadena;
		
		--Cargamos la información en la tabla de control
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /resplogifx/repaclaraciones/aclaracion_r27.sql -l /resplogifx/repaclaraciones/aclaracion_r27.log -n 1000 -k';
		SYSTEM cCadena;
		-----Se elimina script de ruta
		LET vsql = "";
		system vsql; 
		let vsql ='rm  /resplogifx/repaclaraciones/aclaracion_r27.sql';
		system vsql; 
		---Se elimina archivo procedado de Ruta
		LET vsql = "";
		system vsql; 
		let vsql ='rm  /resplogifx/repaclaraciones/'||v_nombre_archivo||'';
		system vsql; 

	--------------------------------------------------
    -----------------------------------------------	
	BEGIN WORK;	
		FOREACH WITH HOLD
			
			SELECT folio_csuac, fecha_afectacion	INTO v_folio_csuac, v_f_afectacion
			FROM "informix".tabla_actualizacion_r27
			
			LET v_folio_csuac = LPAD(TRIM(v_folio_csuac), 10, '0');
			LET v_fecha_afectacion = to_date(v_f_afectacion, '%d/%m/%Y');

			
			--Se valida si la aclaracion tuvo o no abono temporal.
			select pky_movimiento INTO v_pky_movimiento
			from acl_movimiento
			where folio_csuac=v_folio_csuac and duplicado= 0 and fky_padre is null and exitoso = 1;
			
			--En caso de que no exita un abono temporal se actualiza la fecha de afectación
			IF (v_pky_movimiento is null or v_pky_movimiento ='') THEN
			
			UPDATE "informix".acl_regulatorio27 set fecha_abono = v_fecha_afectacion  where folio_csuac = v_folio_csuac;
			
			END IF;
			LET iContador = iContador + 1;
					
			IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
			END IF; 
			
		END FOREACH;
	COMMIT WORK;
	
	DROP TABLE "informix".tabla_actualizacion_r27;
	
----------------------------
----------------------------	
	RETURN v_cod_ret;	END;
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'Analista    	:	Rey David Zavala Garcia',
'FECHA			: 	27/06/2019',
'Requerimiento	:	RQI 65 441',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_busca_datos_3410pbahtm(pFolioCsuac CHAR(11))
	
	
	
	RETURNING
	
		CHAR(5)				AS cod_ret,
		SMALLINT			AS procede_abono_tmp,
		SMALLINT			AS es_diferencia_importes,
		SMALLINT			AS es_tarjeta_presente,
		CHAR(2)				AS modo_entrada,
		SMALLINT			AS mov_con_pinoffline,
		SMALLINT			AS reporte_robext_valido,
		CHAR(1)				AS vcas,
		CHAR(1)				AS cv2,
		SMALLINT			AS es_cvv2_dinamico,
		CHAR(16)			AS tarjeta,
		VARCHAR(30)			AS estatus_tarjeta,
		DATETIME YEAR TO FRACTION(5)	AS fecha_cancelacion_tarjeta,
		DATETIME YEAR TO FRACTION(5)	AS fecha_movimiento,
		CHAR(6)				AS num_autorizacion,
		VARCHAR(40)			AS comercio,
		VARCHAR(40)			AS receptor,
		MONEY				AS importe_reclamado,
		VARCHAR(25)		AS descripcion_dictamen1,
		VARCHAR(50)			AS descripcion_dictamen2;
	
	
	--Variables--
	DEFINE sql_err 						INTEGER;
	DEFINE v_cod_ret 					CHAR(5);
	
	DEFINE v_id_aclaracion				INTEGER;
	DEFINE v_importereclamado			MONEY;
	DEFINE v_evento						INTEGER;
	DEFINE v_origen_evento				INTEGER;
	DEFINE v_tipo_pos					VARCHAR(5);
	DEFINE v_es_evento_robo_ext			SMALLINT;
	
	DEFINE v_estatus_aclaracion			INTEGER;
	DEFINE v_estatus_corp_gral			INTEGER;
	DEFINE v_estatus_corp_analisis		INTEGER;
	
	DEFINE v_modo_entrada				CHAR(2);
	DEFINE v_es_nacional				CHAR(1);
	DEFINE v_referencia_mov				VARCHAR(30);
	DEFINE v_num_autorizacion			CHAR(6);
	DEFINE v_comercio					VARCHAR(40);
	DEFINE v_fechacaptura				DATE;
	DEFINE v_fecha_movimiento			DATETIME YEAR TO FRACTION(5);
	DEFINE v_fecha_act_pinoffline		DATETIME YEAR TO FRACTION(5);
	DEFINE v_fecha_act_pinoffline_atm	DATETIME YEAR TO FRACTION(5);
	DEFINE v_fecha_act_pinoffline_suc	DATETIME YEAR TO FRACTION(5);
	DEFINE v_fecha_act_cvv2				DATETIME YEAR TO FRACTION(5);
	DEFINE v_tiene_pinoffline			SMALLINT;
	DEFINE v_pinoffline_validado		SMALLINT;
	DEFINE v_num_tarjeta				CHAR(16);
	DEFINE v_procede_abono_tmp			SMALLINT;
	DEFINE v_id_msg_no_procedente		SMALLINT;
	DEFINE c_estatus_abonar				INTEGER;
	DEFINE c_nombre_estatus_abonar		CHAR(20);
	
	DEFINE v_estatus_tarjeta			CHAR(3);
	DEFINE v_desc_estatus_tarjeta		CHAR(30);
	DEFINE v_fecha_reporte_tarjeta		DATETIME YEAR TO FRACTION(5);
	DEFINE v_tarjeta_reportada			SMALLINT;
	DEFINE v_reporte_valido				SMALLINT;
	
	DEFINE v_es_captura_manual			SMALLINT;
	DEFINE v_es_diferencia_importes		SMALLINT;
	DEFINE v_es_tarjeta_presente		SMALLINT;
	
	DEFINE v_foliosuc					VARCHAR(30);
	DEFINE v_existe_movimiento			SMALLINT;
	DEFINE v_token_c0					VARCHAR(26);	DEFINE v_receptor					VARCHAR(40);
	DEFINE v_vcas						CHAR(1);
	DEFINE v_cv2						CHAR(1);
	DEFINE v_es_cvv2_presente			SMALLINT;
	DEFINE v_es_cvv2_dinamico			SMALLINT;
	DEFINE v_codigoiso					VARCHAR(2);
	DEFINE v_cvv2valido					VARCHAR(2);
	DEFINE v_tiene_cvv2_activo			SMALLINT;
	
	DEFINE v_descripcion_dictamen		LVARCHAR;
	DEFINE v_descripcion_dictamen1		VARCHAR(25);
	DEFINE v_descripcion_dictamen2		VARCHAR(50);
	
	DEFINE segundaLetraFolioSuc			CHAR(1);
	----Se definen dos variables para obtener las fechas movimiento original y de retencion
	DEFINE v_fecha_consumo			DATETIME YEAR TO FRACTION(5);
	DEFINE v_fecha_movimiento_libe	DATETIME YEAR TO FRACTION(5);
	
	LET v_cod_ret 						= "00000";
	
	LET v_id_aclaracion					= NULL;
	LET v_importereclamado				= NULL;
	LET v_evento						= NULL;
	LET v_origen_evento					= NULL;
	LET v_tipo_pos						= NULL;
	LET v_es_evento_robo_ext			= 0;
	
	LET v_estatus_aclaracion			= NULL;	
	LET v_estatus_corp_gral				= NULL;
	LET v_estatus_corp_analisis			= NULL;
	
	LET v_modo_entrada					= NULL;
	LET v_es_nacional					= NULL;
	LET v_referencia_mov				= NULL;
	LET v_num_autorizacion				= NULL;
	LET v_comercio						= NULL;
	LET v_fechacaptura					= NULL;
	LET v_fecha_movimiento				= NULL;
	LET v_fecha_act_pinoffline_suc		= NULL;
	LET v_fecha_act_cvv2				= NULL;
	LET v_fecha_act_pinoffline_atm		= NULL;
	LET v_fecha_act_pinoffline			= NULL;
	LET v_tiene_pinoffline				= NULL;
	LET v_pinoffline_validado			= NULL;
	LET v_num_tarjeta					= NULL;
	LET v_procede_abono_tmp				= NULL;	
	LET v_id_msg_no_procedente			= NULL;	
	LET c_estatus_abonar				= NULL;	
	LET c_nombre_estatus_abonar			= 'POR_ABONAR';
	
	LET v_estatus_tarjeta				= NULL;	
	LET v_desc_estatus_tarjeta			= NULL;	
	LET v_fecha_reporte_tarjeta			= NULL;	
	LET v_tarjeta_reportada				= 0;
	LET v_reporte_valido				= 0;
	
	LET v_es_captura_manual				= NULL;	
	LET v_es_diferencia_importes		= NULL;	
	LET v_es_tarjeta_presente			= NULL;	
	
	LET v_foliosuc						= NULL;	
	LET v_existe_movimiento				= NULL;	
	LET v_token_c0						= NULL;	
	LET v_receptor						= NULL;	
	LET v_vcas							= NULL;
	LET v_cv2							= NULL;
	LET v_es_cvv2_presente				= NULL;
	LET v_es_cvv2_dinamico				= NULL;
	LET v_codigoiso						= NULL;
	LET v_cvv2valido					= NULL;
	LET v_tiene_cvv2_activo				= NULL;
	
	LET v_descripcion_dictamen			= NULL;	
	LET v_descripcion_dictamen1			= NULL;	
	LET v_descripcion_dictamen2			= NULL;	
	
	LET segundaLetraFolioSuc 			= NULL;
	LET v_fecha_consumo					= NULL;
	LET v_fecha_movimiento_libe			= NULL;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_cod_ret = sql_err;
				
				RETURN v_cod_ret, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
					NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
			END IF;
		END EXCEPTION;
	SET DEBUG FILE TO "/RESPALDOSNEW/errvictor.out";
    TRACE ON;
		
		--Se obtiene el Estatus Correspondiente a En Espera de Autorización de Abono
		SELECT pky_estatus_corporativo
				INTO c_estatus_abonar
			FROM acl_estatus_corporativo 
			WHERE nombre = c_nombre_estatus_abonar and activo = 1;
		
		--Se realizan las consultas iniciales del Folio
		---26/09/2019 se agregan las variables v_fecha_consumo, v_fecha_movimiento_libe en las cuales se inserta la fecha consumo y fecha de 
		--- liberacion del saldo retenidp-
		SELECT acl.fechacaptura, mov.folio_suc, mov.fechahora, numero_tarjeta, acl.importereclamado,
					acl.pky_aclaracion, acl.fky_estatus_aclaracion, acl.fky_estatus_corp_general, 
					acl.fky_estatus_corp_analisis, acl.modo_entrada, mov.referencia, acl.fky_tipo_evento,
					te.fky_origen_evento, oe.nombre, te.capturamanual, te.diferenciaimportes,
					mov.ref_comercio, mov.fecha_consumo
				INTO v_fechacaptura, v_foliosuc, v_fecha_movimiento_libe, v_num_tarjeta, v_importereclamado,
					v_id_aclaracion, v_estatus_aclaracion, v_estatus_corp_gral, 
					v_estatus_corp_analisis, v_modo_entrada, v_referencia_mov, v_evento,
					v_origen_evento, v_tipo_pos, v_es_captura_manual, v_es_diferencia_importes,
					v_comercio, v_fecha_consumo
			FROM acl_aclaracion acl
				Inner Join acl_tipo_evento te on acl.fky_tipo_evento = te.pky_tipo_evento
				Inner Join acl_origen_evento oe on te.fky_origen_evento = oe.pky_origen_evento
				Inner Join acl_movimiento mov on mov.folio_csuac = acl.folio_csuac 
					and mov.fky_padre is null and mov.duplicado = 0
				Inner Join acl_producto pro on acl.fky_producto = pro.pky_producto
			WHERE acl.folio_csuac = pFolioCsuac; 
		
		--Se consideran los últimos 6 caracteres de la referencia
		LET v_referencia_mov = NVL(v_referencia_mov,'');
		LET v_num_autorizacion = RIGHT(TRIM(v_referencia_mov),6);
		------26/09/2019 Se le asigna valor a la variable v_fecha_movimiento en caso de que la fecha de consumo venga en nulo se tomara la fecha de liberación
		LET v_fecha_movimiento = nvl(v_fecha_consumo, v_fecha_movimiento_libe);
		
		IF TRIM(v_tipo_pos) <> 'POS' THEN
			LET v_cod_ret = '00001'; --La Aclaración no pertenece a un Origen de Compra en Comercio
			RETURN v_cod_ret, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
		END IF;
		
		IF v_estatus_corp_gral <> 2 THEN
			LET v_cod_ret = '00002'; --La Aclaración no se encuentra en Espera de Autorización de Abono
			RETURN v_cod_ret, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
			
		END IF;
		
		IF v_es_diferencia_importes = 1 THEN
			LET v_procede_abono_tmp = 1; --Si es diferencia de Importes, Continúa con el proceso Abonar
			RETURN v_cod_ret, v_procede_abono_tmp, v_es_diferencia_importes, NULL, NULL, NULL, NULL,
					NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
		END IF;
		
		--En caso de no contar con el registro del modo de entrada, se validará del origen de la información
		IF v_modo_entrada IS NULL OR v_modo_entrada = 'NN' THEN
			--Para buscar el folio_suc, se deberá realizar con el primero de la secuencia
			LET segundaLetraFolioSuc = substr(v_foliosuc,2,1);
			IF substr(v_foliosuc,1,1) = 'i' AND segundaLetraFolioSuc IN ('0','1','2','3','4','5','6','7','8','9') THEN
				LET v_foliosuc = substr(v_foliosuc,1,9) || '1' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				--Se invoca el SP para obtener la información del modo de entrada:
				CALL "informix".sp_consulta_tipo_movimiento(substr(v_foliosuc,2,29), v_num_tarjeta, v_origen_evento)
					RETURNING v_es_nacional, v_modo_entrada;
			ELSE
				LET v_modo_entrada = NULL;
			END IF;
			
			--En caso de tener el valor del modo de entrada, se actualiza el registro en acl_aclaracion
			-- IF v_modo_entrada IS NOT NULL AND v_modo_entrada <> 'NN' THEN
			--	UPDATE acl_aclaracion SET modo_entrada = v_modo_entrada WHERE folio_csuac = pFolioCsuac;
			-- END IF;
		END IF;
		
		--Se valida el Estatus Actual de la Tarjeta:
		SELECT t.codstatustarjeta, st.descstatustarjeta
			INTO v_estatus_tarjeta, v_desc_estatus_tarjeta
		FROM intercard:tarjeta t
			INNER JOIN intercard:statustarjeta st ON t.codstatustarjeta = st.codstatustarjeta
		WHERE numtarjeta = v_num_tarjeta;
		
		--Se valida si se encuentra Cancelada por Robo o Extravío y se determina la fecha del Reporte
		IF v_estatus_tarjeta IN ('EXT', 'ROB') THEN
			SELECT fechahora
				INTO v_fecha_reporte_tarjeta
			FROM intercard:bitacoracambiosstatustarjeta 
			WHERE tarjeta = v_num_tarjeta AND codstatustarjetanvo = v_estatus_tarjeta;
			LET v_tarjeta_reportada = 1;
		END IF;
		
		--Se obtienen los valores de intercard:movimiento
		SELECT 1, SUBSTRING_INDEX(tokens63in,'! C000026 ',-1), infreceptor, codigoiso, cvv2valido
			INTO v_existe_movimiento, v_token_c0, v_receptor, v_codigoiso, v_cvv2valido
		FROM intercard:movimiento 
		WHERE secuenciaextendida = substr(v_foliosuc,2,29) AND numtarjeta = v_num_tarjeta;

		IF v_existe_movimiento IS NULL OR v_existe_movimiento = 0 THEN
			SELECT 1, SUBSTRING_INDEX(tokens63in,'! C000026 ',-1), infreceptor, codigoiso, cvv2valido
				INTO v_existe_movimiento, v_token_c0, v_receptor, v_codigoiso, v_cvv2valido
			FROM intercard:movimientohistorico 
			WHERE secuenciaextendida = substr(v_foliosuc,2,29) AND numtarjeta = v_num_tarjeta;
		END IF;
		
		IF v_modo_entrada IS NULL OR v_modo_entrada = 'NN' THEN
			LET v_cod_ret = '00003'; --No se logró determinar el modo de entrada
			RETURN v_cod_ret, v_procede_abono_tmp, v_es_diferencia_importes, v_modo_entrada, NULL, NULL, NULL,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
		ELIF v_modo_entrada IN ('05','07','08') THEN --Tarjeta Presente
			LET v_es_tarjeta_presente = 1;
			
			--Se valida si la tarjeta tiene activa la Introducción del NIP
			SELECT MIN(fechahora_insert)
				INTO v_fecha_act_pinoffline_suc 
			FROM intercard:bit_pinoffline 
			WHERE numtarjeta = v_num_tarjeta AND tarjeta_edofinal = 1;
			
			SELECT MIN(fechageneracion)
				INTO v_fecha_act_pinoffline_atm
			FROM intercard:bitacorapinoffline 
			WHERE numtarjeta = v_num_tarjeta AND estatusscripting = 1;
			
			IF v_fecha_act_pinoffline_suc IS NULL AND v_fecha_act_pinoffline_atm IS NULL THEN
				--No cuenta con pinoffline
				LET v_tiene_pinoffline = 0;
			ELSE
				LET v_tiene_pinoffline = 1;
				--Se determina la fecha de la activación del pinoffline
				IF v_fecha_act_pinoffline_suc IS NULL THEN 
					LET v_fecha_act_pinoffline = v_fecha_act_pinoffline_atm;
				ELIF v_fecha_act_pinoffline_atm IS NULL THEN 
					LET v_fecha_act_pinoffline = v_fecha_act_pinoffline_suc;
				ELSE
					IF v_fecha_act_pinoffline_suc < v_fecha_act_pinoffline_atm THEN
						LET v_fecha_act_pinoffline = v_fecha_act_pinoffline_suc;
					ELSE
						LET v_fecha_act_pinoffline = v_fecha_act_pinoffline_atm;
					END IF;
				END IF;
			END IF;
			
			--Se corrobora que el movimiento fue realizado con el pinoffline
			IF (v_tiene_pinoffline = 1) AND (v_fecha_act_pinoffline < v_fecha_movimiento) THEN
				--La tarjeta cuenta con pinoffline y fue activado previo al movimiento
				LET v_procede_abono_tmp = 0; 
				LET v_id_msg_no_procedente = 4;
				LET v_pinoffline_validado = 1;
				
			ELSE
				LET v_pinoffline_validado = 0;
				--Se valida si el reporte de la tarjeta fue realizado con 48 hrs de diferencia
				IF v_tarjeta_reportada = 1 THEN 
					IF v_fecha_reporte_tarjeta < v_fecha_movimiento THEN
						--La tarjeta fue reportada previo al movimiento
						LET v_reporte_valido = 1;
						LET v_procede_abono_tmp = 1; 
					ELSE
						IF ('2 00:00:00') > (v_fecha_reporte_tarjeta - v_fecha_movimiento) THEN
							LET v_reporte_valido = 1;
							LET v_procede_abono_tmp = 1; 
						ELSE
							LET v_procede_abono_tmp = 0; 
							LET v_id_msg_no_procedente = 3;
						--	LET v_reporte_valido = 0;
						END IF;
					END IF;
				ELSE
					LET v_procede_abono_tmp = 1; 
				END IF;
			END IF;
			
			
		ELSE --Tarjeta No Presente
			LET v_es_tarjeta_presente = 0;
			
			IF v_token_c0 IS NOT NULL OR v_token_c0 <> '' THEN
				--Se obtiene el valor de vcas
				LET v_vcas = SUBSTR(v_token_c0,19,1);
				--Se obtiene si fue digitado el cv2
				LET v_cv2 = SUBSTR(v_token_c0,22,1);
			ELSE
				LET v_cod_ret = '00004'; --No se encontró el Valor para vcas
						RETURN v_cod_ret, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
							NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
			END IF;
			
			--Se corrobora si la cuenta tiene el CVV2 activo
			SELECT 1 
				INTO v_tiene_cvv2_activo
			FROM intercard:tarjeta_indicadores 
			WHERE numtarjeta = v_num_tarjeta 
				AND cvv2dinamico = 'V';
			
			--Validar la fecha de activación del CVV2 (en caso de tenerla)
			IF v_tiene_cvv2_activo = 1 THEN
				SELECT MIN(fechacambio)
					INTO v_fecha_act_cvv2
				FROM intercard:bitacoracambiostarjeta 
				WHERE tarjeta = v_num_tarjeta AND identificadorcambio = 9;
				
				--Se valida si la fecha de activación del CVV2 es válida para el movimiento
				IF v_fecha_act_cvv2 < v_fecha_movimiento THEN
					LET v_es_cvv2_dinamico = 1;
				ELSE
					LET v_es_cvv2_dinamico = 0;
				END IF
				
			ELSE
				LET v_es_cvv2_dinamico = 0;
			END IF
			
			--Se corrobora si fue con vcas 5
			IF v_vcas = 5 THEN
				IF v_es_cvv2_dinamico = 1 THEN--Si el cvv2 debió ser dinámico
					--Se valida si el valor del cv2 es correcto:
						--0 = El CV2 no fue incluido deliberadamente o no fue proporcionado por el negocio
						--1 = El CV2 está presente
						--2 = El CV2 está impreso en la tarjeta pero es ilegible
						--9 = El CV2 no está impreso en la tarjeta
						--" " = No hay información disponible
					IF v_cv2 = 1 THEN
						LET v_procede_abono_tmp = 0; 
						LET v_id_msg_no_procedente = 1;
					ELSE
						LET v_procede_abono_tmp = 0; 
						LET v_id_msg_no_procedente = 1;
					END IF;
				ELSE
					--Se valida si el valor del cv2 es correcto:
						--0 = El CV2 no fue incluido deliberadamente o no fue proporcionado por el negocio
						--1 = El CV2 está presente
						--2 = El CV2 está impreso en la tarjeta pero es ilegible
						--9 = El CV2 no está impreso en la tarjeta
						--" " = No hay información disponible
					IF v_cv2 = 1 THEN
						LET v_procede_abono_tmp = 0; 
						LET v_id_msg_no_procedente = 2;
					ELSE
						LET v_procede_abono_tmp = 0; 
						LET v_id_msg_no_procedente = 2;
					END IF;
				END IF;
			ELSE
				IF v_es_cvv2_dinamico = 1 THEN--VCAS <> 5 Y CON CVV2 DINÃMICO
					IF v_cv2 = 1 THEN
						LET v_procede_abono_tmp = 1; 
					END IF;
				ELSE
					IF v_cv2 <> 1 THEN--VCAS <> 5 Y SIN CVV2 TRADICIONAL
						LET v_procede_abono_tmp = 0; 
						LET v_id_msg_no_procedente = 2;
					END IF;
				END IF;
				
				--Robo o Extravío:
				IF v_tarjeta_reportada = 1 THEN 
					IF v_fecha_reporte_tarjeta < v_fecha_movimiento THEN
						--La tarjeta fue reportada previo al movimiento
						LET v_reporte_valido = 1;
						LET v_procede_abono_tmp = 1; 
					ELSE
						IF ('2 00:00:00') > (v_fecha_reporte_tarjeta - v_fecha_movimiento) THEN
							LET v_reporte_valido = 1;
							LET v_procede_abono_tmp = 1; 
						ELSE
							LET v_reporte_valido = 0;
							LET v_procede_abono_tmp = 0; 
							LET v_id_msg_no_procedente = 3;
						END IF;
					END IF;
				ELSE
					LET v_procede_abono_tmp = 1; 
				END IF;
			END IF;
		END IF;
		
		SELECT descripcion 
			INTO v_descripcion_dictamen
		FROM acl_no_procedenterbt 
		WHERE pky_no_procedenterbt = v_id_msg_no_procedente;
				
		LET v_descripcion_dictamen1 = TRIM(substr(v_descripcion_dictamen,1,25));
		LET v_descripcion_dictamen2 = TRIM(substr(v_descripcion_dictamen,26,50));
		
		RETURN v_cod_ret, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada, v_pinoffline_validado, 
					v_reporte_valido, v_vcas, v_cv2, v_es_cvv2_dinamico, v_num_tarjeta, v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, 
					v_fecha_movimiento, v_num_autorizacion, v_comercio, v_receptor, v_importereclamado, v_descripcion_dictamen1, 
					v_descripcion_dictamen2;
					
		
	END;
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Agosto/2019',
'Requerimiento	:	RQM 06 731/RQI 65 449; INC 65 486',
'VERSION		: 	1.2',
'FECHA MODF		: 	26/09/2019',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_busca_datos_3410_mx(pFolioCsuac CHAR(11))
	
	
	
	RETURNING
	
		CHAR(5)				AS cod_ret,
		SMALLINT			AS procede_abono_tmp,
		SMALLINT			AS es_diferencia_importes,
		SMALLINT			AS es_tarjeta_presente,
		CHAR(2)				AS modo_entrada,
		SMALLINT			AS mov_con_pinoffline,
		SMALLINT			AS reporte_robext_valido,
		CHAR(1)				AS vcas,
		CHAR(1)				AS cv2,
		SMALLINT			AS es_cvv2_dinamico,
		CHAR(16)			AS tarjeta,
		VARCHAR(30)			AS estatus_tarjeta,
		DATETIME YEAR TO FRACTION(5)	AS fecha_cancelacion_tarjeta,
		DATETIME YEAR TO FRACTION(5)	AS fecha_movimiento,
		CHAR(6)				AS num_autorizacion,
		VARCHAR(40)			AS comercio,
		VARCHAR(40)			AS receptor,
		MONEY				AS importe_reclamado,
		VARCHAR(255)		AS descripcion_dictamen1,
		VARCHAR(50)			AS descripcion_dictamen2;
	
	
	--Variables--
	DEFINE sql_err 						INTEGER;
	DEFINE v_cod_ret 					CHAR(5);
	
	DEFINE v_id_aclaracion				INTEGER;
	DEFINE v_importereclamado			MONEY;
	DEFINE v_evento						INTEGER;
	DEFINE v_origen_evento				INTEGER;
	DEFINE v_tipo_pos					VARCHAR(5);
	DEFINE v_es_evento_robo_ext			SMALLINT;
	
	DEFINE v_estatus_aclaracion			INTEGER;
	DEFINE v_estatus_corp_gral			INTEGER;
	DEFINE v_estatus_corp_analisis		INTEGER;
	
	DEFINE v_modo_entrada				CHAR(2);
	DEFINE v_es_nacional				CHAR(1);
	DEFINE v_referencia_mov				VARCHAR(30);
	DEFINE v_num_autorizacion			CHAR(6);
	DEFINE v_comercio					VARCHAR(40);
	DEFINE v_fechacaptura				DATE;
	DEFINE v_fecha_movimiento			DATETIME YEAR TO FRACTION(5);
	DEFINE v_fecha_act_pinoffline		DATETIME YEAR TO FRACTION(5);
	DEFINE v_fecha_act_pinoffline_atm	DATETIME YEAR TO FRACTION(5);
	DEFINE v_fecha_act_pinoffline_suc	DATETIME YEAR TO FRACTION(5);
	DEFINE v_fecha_act_cvv2				DATETIME YEAR TO FRACTION(5);
	DEFINE v_tiene_pinoffline			SMALLINT;
	DEFINE v_pinoffline_validado		SMALLINT;
	DEFINE v_num_tarjeta				CHAR(16);
	DEFINE v_procede_abono_tmp			SMALLINT;
	DEFINE v_id_msg_no_procedente		SMALLINT;
	DEFINE c_estatus_abonar				INTEGER;
	DEFINE c_nombre_estatus_abonar		CHAR(20);
	
	DEFINE v_estatus_tarjeta			CHAR(3);
	DEFINE v_desc_estatus_tarjeta		CHAR(30);
	DEFINE v_fecha_reporte_tarjeta		DATETIME YEAR TO FRACTION(5);
	DEFINE v_tarjeta_reportada			SMALLINT;
	DEFINE v_reporte_valido				SMALLINT;
	
	DEFINE v_es_captura_manual			SMALLINT;
	DEFINE v_es_diferencia_importes		SMALLINT;
	DEFINE v_es_tarjeta_presente		SMALLINT;
	
	DEFINE v_foliosuc					VARCHAR(30);
	DEFINE v_existe_movimiento			SMALLINT;
	DEFINE v_token_c0					VARCHAR(26);	DEFINE v_receptor					VARCHAR(40);
	DEFINE v_vcas						CHAR(1);
	DEFINE v_cv2						CHAR(1);
	DEFINE v_es_cvv2_presente			SMALLINT;
	DEFINE v_es_cvv2_dinamico			SMALLINT;
	DEFINE v_codigoiso					VARCHAR(2);
	DEFINE v_cvv2valido					VARCHAR(2);
	DEFINE v_tiene_cvv2_activo			SMALLINT;
	
    DEFINE v_bucio						CHAR(1);
	--DEFINE v_descripcion_dictamen		LVARCHAR;
	DEFINE v_descripcion_dictamen		LVARCHAR(500);
	DEFINE v_descripcion_dictamen1		VARCHAR(55);
	DEFINE v_descripcion_dictamen2		VARCHAR(255);
	
	DEFINE segundaLetraFolioSuc			CHAR(1);
	----Se definen dos variables para obtener las fechas movimiento original y de retencion
	DEFINE v_fecha_consumo			DATETIME YEAR TO FRACTION(5);
	DEFINE v_fecha_movimiento_libe	DATETIME YEAR TO FRACTION(5);
	
	LET v_cod_ret 						= "00000";
	
	LET v_id_aclaracion					= NULL;
	LET v_importereclamado				= NULL;
	LET v_evento						= NULL;
	LET v_origen_evento					= NULL;
	LET v_tipo_pos						= NULL;
	LET v_es_evento_robo_ext			= 0;
	
	LET v_estatus_aclaracion			= NULL;	
	LET v_estatus_corp_gral				= NULL;
	LET v_estatus_corp_analisis			= NULL;
	
	LET v_modo_entrada					= NULL;
	LET v_es_nacional					= NULL;
	LET v_referencia_mov				= NULL;
	LET v_num_autorizacion				= NULL;
	LET v_comercio						= NULL;
	LET v_fechacaptura					= NULL;
	LET v_fecha_movimiento				= NULL;
	LET v_fecha_act_pinoffline_suc		= NULL;
	LET v_fecha_act_cvv2				= NULL;
	LET v_fecha_act_pinoffline_atm		= NULL;
	LET v_fecha_act_pinoffline			= NULL;
	LET v_tiene_pinoffline				= NULL;
	LET v_pinoffline_validado			= NULL;
	LET v_num_tarjeta					= NULL;
	LET v_procede_abono_tmp				= NULL;	
	LET v_id_msg_no_procedente			= NULL;	
	LET c_estatus_abonar				= NULL;	
	LET c_nombre_estatus_abonar			= 'POR_ABONAR';
	
	LET v_estatus_tarjeta				= NULL;	
	LET v_desc_estatus_tarjeta			= NULL;	
	LET v_fecha_reporte_tarjeta			= NULL;	
	LET v_tarjeta_reportada				= 0;
	LET v_reporte_valido				= 0;
	
	LET v_es_captura_manual				= NULL;	
	LET v_es_diferencia_importes		= NULL;	
	LET v_es_tarjeta_presente			= NULL;	
	
	LET v_foliosuc						= NULL;	
	LET v_existe_movimiento				= NULL;	
	LET v_token_c0						= NULL;	
	LET v_receptor						= NULL;	
	LET v_vcas							= NULL;
	LET v_cv2							= NULL;
	LET v_es_cvv2_presente				= NULL;
	LET v_es_cvv2_dinamico				= NULL;
	LET v_codigoiso						= NULL;
	LET v_cvv2valido					= NULL;
	LET v_tiene_cvv2_activo				= NULL;
	
	LET v_descripcion_dictamen			= NULL;	
	LET v_descripcion_dictamen1			= NULL;	
	LET v_descripcion_dictamen2			= NULL;	
	
	LET segundaLetraFolioSuc 			= NULL;
	LET v_fecha_consumo					= NULL;
	LET v_fecha_movimiento_libe			= NULL;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_cod_ret = sql_err;
				
				RETURN v_cod_ret, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
					NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
			END IF;
		END EXCEPTION;
	 SET DEBUG FILE TO "/RESPALDOSNEW/errvictor.out";
     TRACE ON;
		
		--Se obtiene el Estatus Correspondiente a En Espera de Autorización de Abono
		SELECT pky_estatus_corporativo
				INTO c_estatus_abonar
			FROM acl_estatus_corporativo 
			WHERE nombre = c_nombre_estatus_abonar and activo = 1;
		
		--Se realizan las consultas iniciales del Folio
		---26/09/2019 se agregan las variables v_fecha_consumo, v_fecha_movimiento_libe en las cuales se inserta la fecha consumo y fecha de 
		--- liberacion del saldo retenidp-
		SELECT acl.fechacaptura, mov.folio_suc, mov.fechahora, numero_tarjeta, acl.importereclamado,
					acl.pky_aclaracion, acl.fky_estatus_aclaracion, acl.fky_estatus_corp_general, 
					acl.fky_estatus_corp_analisis, acl.modo_entrada, mov.referencia, acl.fky_tipo_evento,
					te.fky_origen_evento, oe.nombre, te.capturamanual, te.diferenciaimportes,
					mov.ref_comercio, mov.fecha_consumo
				INTO v_fechacaptura, v_foliosuc, v_fecha_movimiento_libe, v_num_tarjeta, v_importereclamado,
					v_id_aclaracion, v_estatus_aclaracion, v_estatus_corp_gral, 
					v_estatus_corp_analisis, v_modo_entrada, v_referencia_mov, v_evento,
					v_origen_evento, v_tipo_pos, v_es_captura_manual, v_es_diferencia_importes,
					v_comercio, v_fecha_consumo
			FROM acl_aclaracion acl
				Inner Join acl_tipo_evento te on acl.fky_tipo_evento = te.pky_tipo_evento
				Inner Join acl_origen_evento oe on te.fky_origen_evento = oe.pky_origen_evento
				Inner Join acl_movimiento mov on mov.folio_csuac = acl.folio_csuac 
					and mov.fky_padre is null and mov.duplicado = 0
				Inner Join acl_producto pro on acl.fky_producto = pro.pky_producto
			WHERE acl.folio_csuac = pFolioCsuac; 
		
		--Se consideran los últimos 6 caracteres de la referencia
		LET v_referencia_mov = NVL(v_referencia_mov,'');
		LET v_num_autorizacion = RIGHT(TRIM(v_referencia_mov),6);
		------26/09/2019 Se le asigna valor a la variable v_fecha_movimiento en caso de que la fecha de consumo venga en nulo se tomara la fecha de liberación
		LET v_fecha_movimiento = nvl(v_fecha_consumo, v_fecha_movimiento_libe);
		
		IF TRIM(v_tipo_pos) <> 'POS' THEN
			LET v_cod_ret = '00001'; --La Aclaración no pertenece a un Origen de Compra en Comercio
			RETURN v_cod_ret, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
		END IF;
		
		IF v_estatus_corp_gral <> 2 THEN
			LET v_cod_ret = '00002'; --La Aclaración no se encuentra en Espera de Autorización de Abono
			RETURN v_cod_ret, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
			
		END IF;
		
		IF v_es_diferencia_importes = 1 THEN
			LET v_procede_abono_tmp = 1; --Si es diferencia de Importes, Continúa con el proceso Abonar
			RETURN v_cod_ret, v_procede_abono_tmp, v_es_diferencia_importes, NULL, NULL, NULL, NULL,
					NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
		END IF;
		
		--En caso de no contar con el registro del modo de entrada, se validará del origen de la información
		IF v_modo_entrada IS NULL OR v_modo_entrada = 'NN' THEN
			--Para buscar el folio_suc, se deberá realizar con el primero de la secuencia
			LET segundaLetraFolioSuc = substr(v_foliosuc,2,1);
			IF substr(v_foliosuc,1,1) = 'i' AND segundaLetraFolioSuc IN ('0','1','2','3','4','5','6','7','8','9') THEN
				LET v_foliosuc = substr(v_foliosuc,1,9) || '1' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				--Se invoca el SP para obtener la información del modo de entrada:
				CALL "informix".sp_consulta_tipo_movimiento(substr(v_foliosuc,2,29), v_num_tarjeta, v_origen_evento)
					RETURNING v_es_nacional, v_modo_entrada;
			ELSE
				LET v_modo_entrada = NULL;
			END IF;
			
			--En caso de tener el valor del modo de entrada, se actualiza el registro en acl_aclaracion
			-- IF v_modo_entrada IS NOT NULL AND v_modo_entrada <> 'NN' THEN
			--	UPDATE acl_aclaracion SET modo_entrada = v_modo_entrada WHERE folio_csuac = pFolioCsuac;
			-- END IF;
		END IF;
		
		--Se valida el Estatus Actual de la Tarjeta:
		SELECT t.codstatustarjeta, st.descstatustarjeta
			INTO v_estatus_tarjeta, v_desc_estatus_tarjeta
		FROM intercard:tarjeta t
			INNER JOIN intercard:statustarjeta st ON t.codstatustarjeta = st.codstatustarjeta
		WHERE numtarjeta = v_num_tarjeta;
		
		--Se valida si se encuentra Cancelada por Robo o Extravío y se determina la fecha del Reporte
		IF v_estatus_tarjeta IN ('EXT', 'ROB') THEN
			SELECT fechahora
				INTO v_fecha_reporte_tarjeta
			FROM intercard:bitacoracambiosstatustarjeta 
			WHERE tarjeta = v_num_tarjeta AND codstatustarjetanvo = v_estatus_tarjeta;
			LET v_tarjeta_reportada = 1;
		END IF;
		
		--Se obtienen los valores de intercard:movimiento
		SELECT 1, SUBSTRING_INDEX(tokens63in,'! C000026 ',-1), infreceptor, codigoiso, cvv2valido
			INTO v_existe_movimiento, v_token_c0, v_receptor, v_codigoiso, v_cvv2valido
		FROM intercard:movimiento 
		WHERE secuenciaextendida = substr(v_foliosuc,2,29) AND numtarjeta = v_num_tarjeta;

		IF v_existe_movimiento IS NULL OR v_existe_movimiento = 0 THEN
			SELECT 1, SUBSTRING_INDEX(tokens63in,'! C000026 ',-1), infreceptor, codigoiso, cvv2valido
				INTO v_existe_movimiento, v_token_c0, v_receptor, v_codigoiso, v_cvv2valido
			FROM intercard:movimientohistorico 
			WHERE secuenciaextendida = substr(v_foliosuc,2,29) AND numtarjeta = v_num_tarjeta;
		END IF;
		
		IF v_modo_entrada IS NULL OR v_modo_entrada = 'NN' THEN
			LET v_cod_ret = '00003'; --No se logró determinar el modo de entrada
			RETURN v_cod_ret, v_procede_abono_tmp, v_es_diferencia_importes, v_modo_entrada, NULL, NULL, NULL,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
		ELIF v_modo_entrada IN ('05','07','08') THEN --Tarjeta Presente
			LET v_es_tarjeta_presente = 1;
			
			--Se valida si la tarjeta tiene activa la Introducción del NIP
			SELECT MIN(fechahora_insert)
				INTO v_fecha_act_pinoffline_suc 
			FROM intercard:bit_pinoffline 
			WHERE numtarjeta = v_num_tarjeta AND tarjeta_edofinal = 1;
			
			SELECT MIN(fechageneracion)
				INTO v_fecha_act_pinoffline_atm
			FROM intercard:bitacorapinoffline 
			WHERE numtarjeta = v_num_tarjeta AND estatusscripting = 1;
			
			IF v_fecha_act_pinoffline_suc IS NULL AND v_fecha_act_pinoffline_atm IS NULL THEN
				--No cuenta con pinoffline
				LET v_tiene_pinoffline = 0;
			ELSE
				LET v_tiene_pinoffline = 1;
				--Se determina la fecha de la activación del pinoffline
				IF v_fecha_act_pinoffline_suc IS NULL THEN 
					LET v_fecha_act_pinoffline = v_fecha_act_pinoffline_atm;
				ELIF v_fecha_act_pinoffline_atm IS NULL THEN 
					LET v_fecha_act_pinoffline = v_fecha_act_pinoffline_suc;
				ELSE
					IF v_fecha_act_pinoffline_suc < v_fecha_act_pinoffline_atm THEN
						LET v_fecha_act_pinoffline = v_fecha_act_pinoffline_suc;
					ELSE
						LET v_fecha_act_pinoffline = v_fecha_act_pinoffline_atm;
					END IF;
				END IF;
			END IF;
			
			--Se corrobora que el movimiento fue realizado con el pinoffline
			IF (v_tiene_pinoffline = 1) AND (v_fecha_act_pinoffline < v_fecha_movimiento) THEN
				--La tarjeta cuenta con pinoffline y fue activado previo al movimiento
				LET v_procede_abono_tmp = 0; 
				LET v_id_msg_no_procedente = 4;
				LET v_pinoffline_validado = 1;
				
			ELSE
				LET v_pinoffline_validado = 0;
				--Se valida si el reporte de la tarjeta fue realizado con 48 hrs de diferencia
				IF v_tarjeta_reportada = 1 THEN 
					IF v_fecha_reporte_tarjeta < v_fecha_movimiento THEN
						--La tarjeta fue reportada previo al movimiento
						LET v_reporte_valido = 1;
						LET v_procede_abono_tmp = 1; 
					ELSE
						IF ('2 00:00:00') > (v_fecha_reporte_tarjeta - v_fecha_movimiento) THEN
							LET v_reporte_valido = 1;
							LET v_procede_abono_tmp = 1; 
						ELSE
							LET v_procede_abono_tmp = 0; 
							LET v_id_msg_no_procedente = 3;
						--	LET v_reporte_valido = 0;
						END IF;
					END IF;
				ELSE
					LET v_procede_abono_tmp = 1; 
				END IF;
			END IF;
			
			
		ELSE --Tarjeta No Presente
			LET v_es_tarjeta_presente = 0;
			
			IF v_token_c0 IS NOT NULL OR v_token_c0 <> '' THEN
				--Se obtiene el valor de vcas
				LET v_vcas = SUBSTR(v_token_c0,19,1);
				--Se obtiene si fue digitado el cv2
				LET v_cv2 = SUBSTR(v_token_c0,22,1);
			ELSE
				LET v_cod_ret = '00004'; --No se encontró el Valor para vcas
						RETURN v_cod_ret, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
							NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
			END IF;
			
			--Se corrobora si la cuenta tiene el CVV2 activo
			SELECT 1 
				INTO v_tiene_cvv2_activo
			FROM intercard:tarjeta_indicadores 
			WHERE numtarjeta = v_num_tarjeta 
				AND cvv2dinamico = 'V';
			
			--Validar la fecha de activación del CVV2 (en caso de tenerla)
			IF v_tiene_cvv2_activo = 1 THEN
				SELECT MIN(fechacambio)
					INTO v_fecha_act_cvv2
				FROM intercard:bitacoracambiostarjeta 
				WHERE tarjeta = v_num_tarjeta AND identificadorcambio = 9;
				
				--Se valida si la fecha de activación del CVV2 es válida para el movimiento
				IF v_fecha_act_cvv2 < v_fecha_movimiento THEN
					LET v_es_cvv2_dinamico = 1;
				ELSE
					LET v_es_cvv2_dinamico = 0;
				END IF
				
			ELSE
				LET v_es_cvv2_dinamico = 0;
			END IF
			
			--Se corrobora si fue con vcas 5
			IF v_vcas = 5 THEN
				IF v_es_cvv2_dinamico = 1 THEN--Si el cvv2 debió ser dinámico
					--Se valida si el valor del cv2 es correcto:
						--0 = El CV2 no fue incluido deliberadamente o no fue proporcionado por el negocio
						--1 = El CV2 está presente
						--2 = El CV2 está impreso en la tarjeta pero es ilegible
						--9 = El CV2 no está impreso en la tarjeta
						--" " = No hay información disponible
					IF v_cv2 = 1 THEN
						LET v_procede_abono_tmp = 0; 
						LET v_id_msg_no_procedente = 1;
					ELSE
						LET v_procede_abono_tmp = 0; 
						LET v_id_msg_no_procedente = 1;
					END IF;
				ELSE
					--Se valida si el valor del cv2 es correcto:
						--0 = El CV2 no fue incluido deliberadamente o no fue proporcionado por el negocio
						--1 = El CV2 está presente
						--2 = El CV2 está impreso en la tarjeta pero es ilegible
						--9 = El CV2 no está impreso en la tarjeta
						--" " = No hay información disponible
					IF v_cv2 = 1 THEN
						LET v_procede_abono_tmp = 0; 
						LET v_id_msg_no_procedente = 2;
					ELSE
						LET v_procede_abono_tmp = 0; 
						LET v_id_msg_no_procedente = 2;
					END IF;
				END IF;
			ELSE
				IF v_es_cvv2_dinamico = 1 THEN--VCAS <> 5 Y CON CVV2 DINÃMICO
					IF v_cv2 = 1 THEN
						LET v_procede_abono_tmp = 1; 
					END IF;
				ELSE
					IF v_cv2 <> 1 THEN--VCAS <> 5 Y SIN CVV2 TRADICIONAL
						LET v_procede_abono_tmp = 0; 
						LET v_id_msg_no_procedente = 2;
					END IF;
				END IF;
				
				--Robo o Extravío:
				IF v_tarjeta_reportada = 1 THEN 
					IF v_fecha_reporte_tarjeta < v_fecha_movimiento THEN
						--La tarjeta fue reportada previo al movimiento
						LET v_reporte_valido = 1;
						LET v_procede_abono_tmp = 1; 
					ELSE
						IF ('2 00:00:00') > (v_fecha_reporte_tarjeta - v_fecha_movimiento) THEN
							LET v_reporte_valido = 1;
							LET v_procede_abono_tmp = 1; 
						ELSE
							LET v_reporte_valido = 0;
							LET v_procede_abono_tmp = 0; 
							LET v_id_msg_no_procedente = 3;
						END IF;
					END IF;
				ELSE
					LET v_procede_abono_tmp = 1; 
				END IF;
			END IF;
		END IF;
		
		--SELECT descripcion 
		--SELECT pky_no_procedenterbt 
		--INTO v_bucio 
		--FROM acl_no_procedenterbt 
		--WHERE pky_no_procedenterbt = '4';
		-- WHERE pky_no_procedenterbt = v_id_msg_no_procedente;
				
		--LET v_descripcion_dictamen1 = TRIM(substr(v_descripcion_dictamen,1,255));
		--LET v_descripcion_dictamen2 = TRIM(substr(v_descripcion_dictamen,256,50));

        SELECT descripcion
        --SELECT pky_no_procedenterbt
        INTO v_bucio
        FROM acl_no_procedenterbt
        WHERE pky_no_procedenterbt = '4';
        -- WHERE pky_no_procedenterbt = v_id_msg_no_procedente;


        LET v_descripcion_dictamen1 = 'HOLA' ;
        LET v_descripcion_dictamen2 = 'HOLA 2' ;

		
		RETURN v_cod_ret, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada, v_pinoffline_validado, 
					v_reporte_valido, v_vcas, v_cv2, v_es_cvv2_dinamico, v_num_tarjeta, v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, 
					v_fecha_movimiento, v_num_autorizacion, v_comercio, v_receptor, v_importereclamado, v_descripcion_dictamen1, 
					v_descripcion_dictamen2;
					
		
	END;
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Agosto/2019',
'Requerimiento	:	RQM 06 731/RQI 65 449; INC 65 486',
'VERSION		: 	1.2',
'FECHA MODF		: 	26/09/2019',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_mueve_aclaraciones_historico()

RETURNING CHAR(5);

-- *********************************************************************
-- *                        DEFINICION DE VARIABLES                    *
-- *********************************************************************
DEFINE scod_ret         CHAR(5);
DEFINE vsqlerr          INTEGER;
DEFINE v_pky_aclaracion CHAR(20);
DEFINE icontador        INTEGER;
DEFINE v_folio_csuac    VARCHAR(11);
DEFINE v_sol_eglobal    INTEGER;
DEFINE v_res_eglobal    INTEGER;
DEFINE v_fecha_limit    DATE;
DEFINE vsql	        	char(3000);
Define cCadena 			CHAR(1000);
DEFINE respuesta_repetida_e_global	INTEGER;
DEFINE solicitud_faltante_e_global	INTEGER;
DEFINE cRuta CHAR(100);
DEFINE horaActual     datetime year to fraction;
DEFINE horafinal     datetime year to fraction;
DEFINE v_pky_movimiento CHAR(20);
DEFINE v_pky_movimiento2 CHAR(20);
DEFINE v_pky_bitacora CHAR(20);
DEFINE v_resul_mov INTEGER;
DEFINE v_temp_aclara INTEGER;
DEFINE v_temp_solic INTEGER;
DEFINE v_temp_respues INTEGER;
DEFINE v_temp_bitacora INTEGER;
DEFINE v_temp_mov INTEGER;
DEFINE c_pky_bitacora INTEGER;
DEFINE c_fky_padre INTEGER;
DEFINE c_pky_movimiento INTEGER;



--DEFINE v_year           INTEGER; --variable año
--DEFINE v_mes            INTEGER;
--DEFINE v_dia            INTEGER;
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret  = "00000";
LET vsqlerr = 0;
LET icontador=0;


LET v_resul_mov = NULL;
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
	   LET scod_ret=vsqlerr;
	   ROLLBACK WORK;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/RESPALDOSNEW/aclaraciones/mover.out";
--TRACE ON;
SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;


--Verificar tablas fisicas
		SELECT tabid
		INTO v_temp_aclara
		FROM systables WHERE tabname ='temp_aclara';
		
		IF v_temp_aclara IS NOT NULL THEN
			DROP TABLE "informix".temp_aclara;
		END IF;
--Verificar tabla fisica
			SELECT tabid
			INTO v_temp_solic
			FROM systables WHERE tabname ='temp_solic';
		IF v_temp_solic IS NOT NULL THEN
			DROP TABLE "informix".temp_solic;
		END IF;
--Verificar tabla fisica
			SELECT tabid 
			INTO v_temp_respues
			FROM systables WHERE tabname ='temp_respues';
		IF 	v_temp_respues is not null	THEN
			DROP TABLE "informix".temp_respues;
		END IF;
--Verificar tabla fisica
			SELECT tabid
			INTO v_temp_mov
			FROM systables WHERE tabname ='temp_mov';
		IF 	v_temp_mov IS NOT NULL	THEN
			DROP TABLE "informix".temp_mov;
		END IF;
--Verificar tabla fisica
--		IF EXISTS( SELECT * FROM systables WHERE tabname ='temp_mov_2') THEN
--			DROP TABLE "informix".temp_mov_2;
--		END IF;
--Verificar tabla fisica

			SELECT tabid
			INTO v_temp_bitacora
			FROM systables WHERE tabname ='temp_bitacora';
		IF v_temp_bitacora IS NOT NULL THEN
			DROP TABLE "informix".temp_bitacora;
		END IF;
BEGIN WORK;
----------se crean las tablas fisicas
	CREATE /*TEMP*/ table temp_aclara(
		pky_aclaracion     integer     NOT NULL,
		folio_csuac  VARCHAR(11));
	CREATE /*TEMP*/ table temp_solic (
		pky_solicitud_e_global integer);
	CREATE /*TEMP*/ table temp_respues (
		pky_respuesta_e_global integer);
	CREATE INDEX index_temp_1
		ON temp_aclara (pky_aclaracion);
	CREATE INDEX index_temp_2
		ON temp_aclara (folio_csuac);
	CREATE /*TEMP*/ table temp_mov(
		pky_movimiento    integer,
		fky_padre integer);
	--CREATE /*TEMP*/ table temp_mov_2(
	--	pky_movimiento    integer);
	CREATE /*TEMP*/ table temp_bitacora(
		pky_bitacora   integer);

----------------------------------------------------------
update statistics medium for table "informix".acl_aclaracion;
--update statistics high for table "informix".acl_aclaracion_his;
update statistics medium for table "informix".acl_entrada_bitacora;
--update statistics high for table "informix".acl_entrada_bitacora;
update statistics medium for table "informix".acl_movimiento;
--update statistics high for table "informix".acl_movimiento_his;
update statistics medium for table "informix".acl_documento;
--update statistics high for table "informix".acl_documento_his;
update statistics medium for table "informix".acl_recuperacion_saldos;
--update statistics high for table "informix".acl_recuperacion_saldos_his;
update statistics medium for table "informix".acl_solicitud_e_global;
--update statistics high for table "informix".acl_solicitud_e_global_his;
update statistics medium for table "informix".acl_respuesta_e_global;
--update statistics high for table "informix".acl_respuesta_e_global_his;
update statistics medium for table "informix".acl_control_aclaracion_tel;
--update statistics high for table "informix".acl_control_aclaracion_tel_his;
update statistics medium for table "informix".acl_regulatorio27;
--update statistics high for table "informix".acl_regulatorio27_his;
update statistics medium for table "informix".acl_sistema_bitacora;
--update statistics high for table "informix".acl_sistema_bitacora_his;
--
--
---- ****************************************************************************
---- *                        PROGRAMA PRINCIPAL                                *
---- ****************************************************************************
--	-- *************************************************************
--	-- * Mover información a historico del sistema de aclaraciones *
--	-- *************************************************************
--------obtener fecha de validación.
--next_day
--select (last_day(add_months((date('20200101')), -13)))+1 from bdinteg:"informix".si_fechas where empresa=001
--SELECT fecha_hoy
--   INTO v_fecha_limit
--FROM bdinteg:si_fechas;
--LET fechaPasada = ADD_MONTHS(fechaActual,-12);
--LET fechaInicio = last_day(ADD_MONTHS(fechaActual,-13)) + 1;
	
	
	select (last_day(add_months((date(fecha_hoy)), -13)))+1
		into v_fecha_limit
	from bdinteg:"informix".si_fechas where empresa='001';
  --if v_ano < (select year(fecha_hoy) from bdinteg:si_fechas where empresa='001') then  
--FOREACH
-----------***se obtiene el pky_de aclaraciones
        INSERT INTO temp_aclara
			SELECT pky_aclaracion,folio_csuac
				FROM "informix".acl_aclaracion where fechacaptura <= v_fecha_limit; 
-----------** se obtiene el pky_solicitud e-global
		INSERT INTO temp_solic
			select fky_solicitud_e_global
			from acl_movimiento 
				where fky_aclaracion in(select pky_aclaracion from temp_aclara where folio_csuac is not null) AND fky_solicitud_e_global is not null;
-----------** se obtiene el pky_respuesta e-global
		INSERT INTO temp_respues
			select fky_respuesta_e_global
			from acl_solicitud_e_global
				where pky_solicitud_e_global in(select pky_solicitud_e_global from temp_solic where fky_respuesta_e_global is not null);
   ------*Se las respuestas E-global Duplicadas....
		/*INSERT INTO temp_solic
		select pky_solicitud_e_global
		from acl_solicitud_e_global where fky_respuesta_e_global in (Select fky_respuesta_e_global from acl_solicitud_e_global where fky_respuesta_e_global in(select pky_respuesta_e_global from temp_respues)	group by fky_respuesta_e_global HAVING COUNT(fky_respuesta_e_global)  >  1);
		*/
		FOREACH
			Select fky_respuesta_e_global 
				Into respuesta_repetida_e_global
			from acl_solicitud_e_global 
				Inner Join temp_respues on fky_respuesta_e_global = pky_respuesta_e_global
			group by fky_respuesta_e_global HAVING COUNT(fky_respuesta_e_global)  >  1
			
			FOREACH
				SELECT seg.pky_solicitud_e_global 
					Into solicitud_faltante_e_global
				FROM acl_solicitud_e_global seg
					LEFT JOIN temp_solic tseg ON seg.pky_solicitud_e_global = tseg.pky_solicitud_e_global
				WHERE seg.fky_respuesta_e_global = respuesta_repetida_e_global 
					AND tseg.pky_solicitud_e_global is NULL
				
				INSERT INTO temp_solic (pky_solicitud_e_global) VALUES (solicitud_faltante_e_global);
				
				INSERT INTO temp_aclara
					SELECT fky_aclaracion, folio_csuac FROM acl_movimiento WHERE fky_solicitud_e_global = solicitud_faltante_e_global;
			END FOREACH;
		END FOREACH;

COMMIT WORK;
--BEGIN WORK;
	BEGIN WORK;
 /*1*/--********************inserción de historico en aclaraciones
 
        let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_aclaracion_his.unl '||
						'select * from "informix".acl_aclaracion WHERE pky_aclaracion in (select pky_aclaracion from temp_aclara);">/RESPALDOSNEW/aclaraciones/acl_aclaracion_his.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_aclaracion_his.sql';
		system vsql;
--------------------------------------Se carga la informacion en la tabla histoca
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_aclaracion_his.unl DELIMITER '|| "'" || '|' || "'" || ' 36;' || '">/RESPALDOSNEW/aclaraciones/aclaracion.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_aclaracion_his;' || '">> /RESPALDOSNEW/aclaraciones/aclaracion.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/aclaracion.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/aclaracion.sql -l /RESPALDOSNEW/aclaraciones/aclaracion.log -n 1000 -k';
		SYSTEM cCadena;
		------------------------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_aclaracion_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_aclaracion_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/aclaracion.sql';
		system vsql; 

 /*2*/-----------------------------------------------------------------------------------------------------------------
		--		 --********************inserción de historico en entrada bitacora
  		let vsql = '';
  		system vsql; 
  		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_entrada_bitacora_his.unl '||
						'select * from "informix".acl_entrada_bitacora  WHERE  fky_aclaracion in(select pky_aclaracion from temp_aclara);">/RESPALDOSNEW/aclaraciones/acl_entrada_bitacora_his.sql';
  		system vsql;
  		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_entrada_bitacora_his.sql';
  		system vsql;
		-----------------------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_entrada_bitacora_his.unl DELIMITER '|| "'" || '|' || "'" || ' 11;' || '">/RESPALDOSNEW/aclaraciones/bitacora.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_entrada_bitacora_his;' || '">> /RESPALDOSNEW/aclaraciones/bitacora.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/bitacora.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/bitacora.sql -l /RESPALDOSNEW/aclaraciones/bitacora.log -n 1000 -k';
		SYSTEM cCadena;
		--------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_entrada_bitacora_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_entrada_bitacora_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/bitacora.sql';
		system vsql; 
	COMMIT WORK;
 /*3*/-----------------------------------------------------------------------------------------------------------------
	--********************inserción de historico en documentos
	FOREACH WITH HOLD
		
		select pky_aclaracion, folio_csuac
			into v_pky_aclaracion,v_folio_csuac
		from temp_aclara
		
		BEGIN WORK;	
			INSERT INTO "informix".acl_documento_his 
			select * from "informix".acl_documento WHERE fky_aclaracion =v_pky_aclaracion and folio_csuac = v_folio_csuac;
		COMMIT WORK;
	
	END FOREACH;
----------------------------------------------------------------------------------------------------------------------		
/*4*/-------------------********************inserción de historico en recuperacion de saldos
	BEGIN WORK;
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_recuperacion_saldos_his.unl '||
						'select * from "informix".acl_recuperacion_saldos WHERE fky_aclaracion in (select pky_aclaracion from temp_aclara);">/RESPALDOSNEW/aclaraciones/acl_recuperacion_saldos_his.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_recuperacion_saldos_his.sql';
		system vsql;
		--------------------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_recuperacion_saldos_his.unl DELIMITER '|| "'" || '|' || "'" || ' 27;' || '">/RESPALDOSNEW/aclaraciones/recuperacion.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_recuperacion_saldos_his;' || '">> /RESPALDOSNEW/aclaraciones/recuperacion.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/recuperacion.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/recuperacion.sql -l /RESPALDOSNEW/aclaraciones/recuperacion.log -n 1000 -k';
		SYSTEM cCadena;
		--------------------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_recuperacion_saldos_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_recuperacion_saldos_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/recuperacion.sql';
		system vsql; 
 /*5*/--------------------------------------------------------------------------------------------------------------------		
--********************inserción de historico de respuesta E-GALOBAL
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_respuesta_e_global_his.unl '||
						'select * from "informix".acl_respuesta_e_global WHERE pky_respuesta_e_global in (select pky_respuesta_e_global from temp_respues);">/RESPALDOSNEW/aclaraciones/acl_respuesta_e_global_his.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_respuesta_e_global_his.sql';
		system vsql;
		----------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_respuesta_e_global_his.unl DELIMITER '|| "'" || '|' || "'" || ' 3;' || '">/RESPALDOSNEW/aclaraciones/respuesta.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_respuesta_e_global_his;' || '">> /RESPALDOSNEW/aclaraciones/respuesta.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/respuesta.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/respuesta.sql -l /RESPALDOSNEW/aclaraciones/respuesta.log -n 1000 -k';
		SYSTEM cCadena;
		--------------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_respuesta_e_global_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_respuesta_e_global_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/respuesta.sql';
		system vsql; 
 /*6*/--------------------------------------------------------------------------------------------------------------------------		
--********************inserción de historico de solicitud E-GALOBAL
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_solicitud_e_global_his.unl '||
						'select * from "informix".acl_solicitud_e_global WHERE pky_solicitud_e_global in(select pky_solicitud_e_global from temp_solic);">/RESPALDOSNEW/aclaraciones/acl_solicitud_e_global_his.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_solicitud_e_global_his.sql';
		system vsql;
		Let vsql = '';
		--------------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_solicitud_e_global_his.unl DELIMITER '|| "'" || '|' || "'" || ' 4;' || '">/RESPALDOSNEW/aclaraciones/solicitud.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_solicitud_e_global_his;' || '">> /RESPALDOSNEW/aclaraciones/solicitud.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/solicitud.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/solicitud.sql -l /RESPALDOSNEW/aclaraciones/solicitud.log -n 1000 -k';
		SYSTEM cCadena;
		---------------------------------------------------------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_solicitud_e_global_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_solicitud_e_global_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/solicitud.sql';
		system vsql; 
 /*7*/--------------------------------------------------------------------------------------------------------------------------------
--********************inserción de historico en movimiento
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_movimiento_his.unl '||
						'select * from "informix".acl_movimiento WHERE (fky_aclaracion in(select pky_aclaracion from temp_aclara) or folio_csuac in(select folio_csuac from temp_aclara where folio_csuac is not null)) and fky_padre is null order by pky_movimiento asc;">/RESPALDOSNEW/aclaraciones/acl_movimiento_his.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_movimiento_his.sql';
		system vsql;
		--------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_movimiento_his.unl DELIMITER '|| "'" || '|' || "'" || ' 34;' || '">/RESPALDOSNEW/aclaraciones/movimiento.sql';
		SYSTEM cCadena;
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_movimiento_his;' || '">> /RESPALDOSNEW/aclaraciones/movimiento.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/movimiento.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/movimiento.sql -l /RESPALDOSNEW/aclaraciones/movimiento.log -n 1000 -k';
		SYSTEM cCadena;
		--------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_movimiento_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_movimiento_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/movimiento.sql';
		system vsql; 
 /*8*/--------------------------------------------------------------------------------------------------------------------
--********************inserción de historico en movimiento pky_padre no es nulo
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_movimiento_his1.unl '||
						'select * from "informix".acl_movimiento WHERE (fky_aclaracion in(select pky_aclaracion from temp_aclara) or folio_csuac in(select folio_csuac from temp_aclara where folio_csuac is not null)) and fky_padre is not null order by fky_padre asc;">/RESPALDOSNEW/aclaraciones/acl_movimiento_his1.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_movimiento_his1.sql';
		system vsql;
		-----------------------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_movimiento_his1.unl DELIMITER '|| "'" || '|' || "'" || ' 34;' || '">/RESPALDOSNEW/aclaraciones/movimiento1.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_movimiento_his;' || '">> /RESPALDOSNEW/aclaraciones/movimiento1.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/movimiento1.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/movimiento1.sql -l /RESPALDOSNEW/aclaraciones/movimiento1.log -n 1000 -k';
		SYSTEM cCadena;
		-----------------------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_movimiento_his1.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_movimiento_his1.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/movimiento1.sql';
		system vsql; 
 /*9*/-----------------------------------------------------------------------------------------------------------------------------		
--**** inserción de la informacion que no cuenta con referencia a acl_Aclaracion
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_movimiento_his2.unl '||
						'select * from "informix".acl_movimiento WHERE fky_aclaracion is null and folio_csuac is null and fechahora <= (select (last_day(add_months((date(fecha_hoy)), -13)))+1 from bdinteg:"informix".si_fechas where empresa=001)  order by pky_movimiento asc;">/RESPALDOSNEW/aclaraciones/acl_movimiento_his2.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_movimiento_his2.sql';
		system vsql;
		--------------------------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_movimiento_his2.unl DELIMITER '|| "'" || '|' || "'" || ' 34;' || '">/RESPALDOSNEW/aclaraciones/movimiento2.sql';
		SYSTEM cCadena;
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_movimiento_his;' || '">> /RESPALDOSNEW/aclaraciones/movimiento2.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/movimiento2.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/movimiento2.sql -l /RESPALDOSNEW/aclaraciones/movimiento2.log -n 1000 -k';
		SYSTEM cCadena;
		------------------------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_movimiento_his2.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_movimiento_his2.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/movimiento2.sql';
		system vsql; 
 /*10*/-----------------------------------------------------------------------------------------------------------------------------------
--********************inserción de historico de control de aclaraciones via telefonica
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_control_aclaracion_tel_his.unl '||
						'select * from "informix".acl_control_aclaracion_tel WHERE fky_aclaracion in(select pky_aclaracion from temp_aclara);">/RESPALDOSNEW/aclaraciones/acl_control_aclaracion_tel_his.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_control_aclaracion_tel_his.sql';
		system vsql;
		-------------------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_control_aclaracion_tel_his.unl DELIMITER '|| "'" || '|' || "'" || ' 9;' || '">/RESPALDOSNEW/aclaraciones/control.sql';
		SYSTEM cCadena;
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_control_aclaracion_tel_his;' || '">> /RESPALDOSNEW/aclaraciones/control.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/control.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/control.sql -l /RESPALDOSNEW/aclaraciones/control.log -n 1000 -k';
		SYSTEM cCadena;
		----------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_control_aclaracion_tel_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_control_aclaracion_tel_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/control.sql';
		system vsql; 
 /*11*/-----------------------------------------------------------------------------------------------------------------------------------------
---=========*******Inserción de informacion de historicos de cancelación de cuentas por recuperacion de saldos
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.unl '||
						'select * from "informix".acl_bitacora_control_cancelacion_cuenta WHERE fky_aclaracion in (select pky_aclaracion from temp_aclara);">/RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.sql';
		system vsql;
		------------------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.unl DELIMITER '|| "'" || '|' || "'" || ' 7;' || '">/RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.sql';
		SYSTEM cCadena;
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_bitacora_control_cancelacion_cuenta_his;' || '">> /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.sql -l /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.log -n 1000 -k';
		SYSTEM cCadena;
		--------------------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/bitacora_control_cancelacion.sql';
-------------------------------------------------------------------------------------------------------------------------

 /*12*/---********************inserción de historico de regulatorio 27
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_regulatorio27_his.unl '||
						'select * from "informix".acl_regulatorio27 WHERE folio_csuac in (select folio_csuac from temp_aclara);">/RESPALDOSNEW/aclaraciones/acl_regulatorio27_his.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_regulatorio27_his.sql';
		system vsql;
		------------------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_regulatorio27_his.unl DELIMITER '|| "'" || '|' || "'" || ' 25;' || '">/RESPALDOSNEW/aclaraciones/regulatorio.sql';
		SYSTEM cCadena;
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_regulatorio27_his;' || '">> /RESPALDOSNEW/aclaraciones/regulatorio.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/regulatorio.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/regulatorio.sql -l /RESPALDOSNEW/aclaraciones/regulatorio.log -n 1000 -k';
		SYSTEM cCadena;
		--------------------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_regulatorio27_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_regulatorio27_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/regulatorio.sql';
		system vsql; 
----------------------------------------------------------------------------------------------------------------------------------
 /*13*/--********************inserción de historico bitacora del sistema
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_sistema_bitacora_his.unl '||
						'select * from "informix".acl_sistema_bitacora WHERE fecha <= (select (last_day(add_months((date(fecha_hoy)), -13)))+1 from bdinteg:"informix".si_fechas where empresa=001);">/RESPALDOSNEW/aclaraciones/acl_sistema_bitacora_his.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_sistema_bitacora_his.sql';
		system vsql;
		---------------------------------
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_sistema_bitacora_his.unl DELIMITER '|| "'" || '|' || "'" || ' 11;' || '">/RESPALDOSNEW/aclaraciones/sistema.sql';
		SYSTEM cCadena;
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_sistema_bitacora_his;' || '">> /RESPALDOSNEW/aclaraciones/sistema.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/sistema.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/sistema.sql -l /RESPALDOSNEW/aclaraciones/sistema.log -n 1000 -k';
		SYSTEM cCadena;
		--------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_sistema_bitacora_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_sistema_bitacora_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/sistema.sql';
		system vsql; 
		
/*14*/--===========================Se genera archivo para historico de la tabla acl_aclaracion_estatus_proceso_analisis ====================================================
		let vsql = '';
		system vsql; 
		let vsql=  'echo "UNLOAD to /RESPALDOSNEW/aclaraciones/acl_aclaracion_estatus_proceso_analisis_his.unl '||
						'select * from "informix".acl_aclaracion_estatus_proceso_analisis WHERE fky_aclaracion in (select pky_aclaracion from temp_aclara);">/RESPALDOSNEW/aclaraciones/acl_aclaracion_estatus_proceso_analisis_his.sql';
		system vsql;
		let vsql= 'dbaccess bdiaclaracion /RESPALDOSNEW/aclaraciones/acl_aclaracion_estatus_proceso_analisis_his.sql';
		system vsql;
--------------------------------------Se carga la informacion en la tabla histoca
		LET cCadena = ' echo "FILE /RESPALDOSNEW/aclaraciones/acl_aclaracion_estatus_proceso_analisis_his.unl DELIMITER '|| "'" || '|' || "'" || ' 2;' || '">/RESPALDOSNEW/aclaraciones/estatus_proceso_analisis.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".acl_aclaracion_estatus_proceso_analisis_his;' || '">> /RESPALDOSNEW/aclaraciones/estatus_proceso_analisis.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /RESPALDOSNEW/aclaraciones/estatus_proceso_analisis.sql';
		SYSTEM cCadena;
		
		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /RESPALDOSNEW/aclaraciones/estatus_proceso_analisis.sql -l /RESPALDOSNEW/aclaraciones/aclaracion.log -n 1000 -k';
		SYSTEM cCadena;
		------------------------------------------------
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_aclaracion_estatus_proceso_analisis_his.unl';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/acl_aclaracion_estatus_proceso_analisis_his.sql';
		system vsql; 
		let vsql ='rm  /RESPALDOSNEW/aclaraciones/estatus_proceso_analisis.sql';
		system vsql; 
--===================================================================================================================================================
	COMMIT WORK;		
	
--		---*obtencion de los pky_movimientos a mover.
	BEGIN WORK;
		FOREACH WITH HOLD	
		
			--INSERT INTO temp_bitacora		
			select pky_bitacora 
			INTO c_pky_bitacora
			from "informix".acl_sistema_bitacora where fecha <= (select (last_day(add_months((date(fecha_hoy)), -13)))+1 from bdinteg:"informix".si_fechas where empresa=001)
			
			INSERT INTO "informix".temp_bitacora (pky_bitacora) values (c_pky_bitacora);
			
			LET iContador = iContador + 1;
			IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
			END IF; 
	
		END FOREACH;
	COMMIT WORK;
	LET iContador = 0;
--------------
	BEGIN WORK;
		FOREACH WITH HOLD
			--INSERT INTO temp_mov
			SELECT pky_movimiento, fky_padre
			into c_pky_movimiento, c_fky_padre
			FROM "informix".acl_movimiento_his where (fky_aclaracion in(select pky_aclaracion from temp_aclara) or folio_csuac in(select folio_csuac from temp_aclara where folio_csuac is not null)) and fky_padre is not null order by fky_padre asc 
			
			INSERT INTO "informix".temp_mov (pky_movimiento,fky_padre) VALUES(c_pky_movimiento,c_fky_padre);
			LET iContador = iContador + 1;
			IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
			END IF; 
		END FOREACH;	
	COMMIT WORK;
	LET iContador = 0;
	------------
	BEGIN WORK;
		FOREACH WITH HOLD
			--fky_padre is not null;
			--INSERT INTO temp_mov
			SELECT pky_movimiento,fky_padre
			into c_pky_movimiento, c_fky_padre
			FROM "informix".acl_movimiento_his where (fky_aclaracion in(select pky_aclaracion from temp_aclara) or folio_csuac in(select folio_csuac from temp_aclara where folio_csuac is not null)) and fky_padre is null order by pky_movimiento asc
			--fky_padre is null;
			INSERT INTO "informix".temp_mov (pky_movimiento,fky_padre) VALUES(c_pky_movimiento,c_fky_padre);
			LET iContador = iContador + 1;
			IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
			END IF; 
		END FOREACH;
	COMMIT WORK;
	LET iContador = 0;
	----------------------
	BEGIN WORK;
		FOREACH WITH HOLD
			--INSERT INTO temp_mov
			SELECT pky_movimiento, fky_padre
			into c_pky_movimiento, c_fky_padre
			FROM "informix".acl_movimiento_his where fky_aclaracion is null and folio_csuac is null and fechahora <= (select (last_day(add_months((date(fecha_hoy)), -13)))+1 from bdinteg:"informix".si_fechas where empresa=001)  order by pky_movimiento asc
			
			INSERT INTO "informix".temp_mov (pky_movimiento,fky_padre) VALUES(c_pky_movimiento,c_fky_padre);
			LET iContador = iContador + 1;
			IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
			END IF; 
	
		END FOREACH;
	COMMIT WORK;
	
	BEGIN WORK;
		FOREACH WITH HOLD
		-----Movimiento de aclaraciones que no cuentan con folio csuac
			--INSERT INTO temp_mov
			SELECT pky_movimiento, fky_padre
			into c_pky_movimiento, c_fky_padre
			FROM "informix".acl_movimiento_his where fky_aclaracion in(select pky_aclaracion from temp_aclara) and folio_csuac is null  order by pky_movimiento asc -----fky_aclaracion is not null and folio_csuac is null and fechahora <= (select last_day(add_months(((today) - 0 units year),-(month(today)))) from bdinteg:"informix".si_fechas where empresa=001)  order by pky_movimiento asc
			
			INSERT INTO "informix".temp_mov (pky_movimiento,fky_padre) VALUES(c_pky_movimiento,c_fky_padre);
			LET iContador = iContador + 1;
			IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
			END IF; 
	
		END FOREACH;
	COMMIT WORK;

FOREACH WITH HOLD
			
		select pky_aclaracion, folio_csuac
			into v_pky_aclaracion,v_folio_csuac
		from temp_aclara
		
		BEGIN WORK;	
        		 --********************Eliminacion de historico en entrada bitacora
			delete from "informix".acl_entrada_bitacora WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico en documentos
			delete from "informix".acl_documento WHERE  fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico en documentos
			delete from "informix".acl_recuperacion_saldos WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico de solicitud E-GALOBAL
			--********************Eliminacion de historico de control de aclaraciones via telefonica
			delete from "informix".acl_control_aclaracion_tel WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico de regulatorio 27
			delete from "informix".acl_regulatorio27 WHERE folio_csuac = v_folio_csuac;
			--********************Eliminacion de historico los intentos de cancelación
			delete from "informix".acl_bitacora_control_cancelacion_cuenta WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminación de los registros que se fueron a Historico----------------
			delete from "informix".acl_aclaracion_estatus_proceso_analisis WHERE fky_aclaracion = v_pky_aclaracion;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
		select pky_movimiento
			into v_pky_movimiento
		from temp_mov where fky_padre is not null --order by pky_movimiento desc
		
		BEGIN WORK;	
			LET v_resul_mov = v_pky_movimiento;
			--********************Eliminacion de historico en movimiento
			UPDATE "informix".acl_movimiento SET fky_padre = NULL WHERE pky_movimiento = v_pky_movimiento;
			LET v_resul_mov = NULL;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_movimiento
			into v_pky_movimiento
			from temp_mov order by fky_padre desc
		BEGIN WORK;	
			LET v_resul_mov = v_pky_movimiento;
			--********************Eliminacion de historico en movimiento
			delete from "informix".acl_movimiento WHERE pky_movimiento = v_pky_movimiento;
			LET v_resul_mov = NULL;
		COMMIT WORK;
END FOREACH;


FOREACH WITH HOLD		
			select pky_solicitud_e_global
			into v_sol_eglobal
			from temp_solic
		BEGIN WORK;	
			--********************Eliminacion de historico de Solicitud E-GALOBAL
			delete from "informix".acl_solicitud_e_global WHERE pky_solicitud_e_global = v_sol_eglobal;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD		
			select pky_respuesta_e_global
			into v_res_eglobal
			from temp_respues
		BEGIN WORK;	
    	--********************Eliminacion de historico de respuesta E-GALOBAL
			delete from "informix".acl_respuesta_e_global WHERE pky_respuesta_e_global = v_res_eglobal;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_aclaracion
			into v_pky_aclaracion
			from temp_aclara
		BEGIN WORK;	
		---********* Se elimina la informacion principal de aclaraciones********
			delete from "informix".acl_aclaracion WHERE  pky_aclaracion = v_pky_aclaracion;
		COMMIT WORK;
END FOREACH;
			
FOREACH WITH HOLD
			select pky_bitacora
			into v_pky_bitacora
			from temp_bitacora
		BEGIN WORK;		
			--------------------Elimina historico del bitacora del sistema----------------------
			delete from "informix".acl_sistema_bitacora WHERE pky_bitacora = v_pky_bitacora;
		COMMIT WORK;
END FOREACH;

	--------------****se eliminan las tablas temporales .::::::::::::
DROP TABLE temp_aclara;
DROP TABLE temp_solic;
DROP TABLE temp_respues;
DROP TABLE temp_mov;
--DROP TABLE temp_mov_2;
DROP TABLE temp_bitacora;
--COMMIT WORK;
RETURN scod_ret;
END
END PROCEDURE
DOCUMENT
'Sp sp_mueve_aclaraciones_historico',
'Se desarrolla para realizar la migración de información',
'Sistema: Aclaraciones',
'AUTOR : REY DAVID ZAVALA GARCIA',
'Area: Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte IV',
'Coordinador: Norberto Corona Berruecos',
'FECHA Modificacion: Diciembre/2019',
'VERSION: 4.0.0',
'BD    :  bdiaclaracion';

CREATE PROCEDURE "informix".sp_obten_estatus_canales_sms(
								pEstatusAcl				INTEGER,
								pEstatusCorpGral		INTEGER,
								pEstatusCorpAnalisis	INTEGER)

	RETURNING
		CHAR(5)							AS cod_ret,
		CHAR(50)						AS desc_estatus_canales,
		CHAR(50)						AS desc_estatus_sms,
		SMALLINT 						AS concatena_dictamen,
		INTEGER 						AS id_etapa_canales,
        CHAR(20)						AS desc_etapa_canales;

	--Variables--
	DEFINE sql_err 							INTEGER;
	DEFINE v_cod_ret 						CHAR(5);
	
	DEFINE v_id_estatus_aclaracion			INTEGER;
	DEFINE v_id_estatus_corp_analisis		INTEGER;
	DEFINE v_id_estatus_corp_general		INTEGER;
	DEFINE v_concatena_dictamen				SMALLINT;
	DEFINE v_estatus_canales				CHAR(50);
	DEFINE v_estatus_sms				CHAR(50);
	DEFINE v_id_etapa_canales				INTEGER;
	DEFINE v_desc_etapa_canales				CHAR(20);
	
	
	DEFINE contador			INTEGER;
	LET contador			= 0;
	
	LET v_cod_ret 						= '00000';
	LET sql_err 						= NULL;
	
	LET v_id_estatus_aclaracion			= NULL;
	LET v_id_estatus_corp_analisis		= NULL;
	LET v_id_estatus_corp_general		= NULL;
	LET v_concatena_dictamen			= NULL;
	LET v_estatus_canales					= NULL;
	LET v_estatus_sms					= NULL;
	LET v_id_etapa_canales					= NULL;
	LET v_desc_etapa_canales				= NULL;
	
	--SET DEBUG FILE TO "/informix/Paty/RQM665/estatus_canales_sms.out";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				
				LET v_cod_ret = sql_err;
				RETURN v_cod_ret, v_estatus_canales, v_estatus_sms, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales;
				
		    END IF;
		END EXCEPTION;
		
		IF (pEstatusAcl IS NULL) THEN
			RETURN '00001', v_estatus_canales, v_estatus_sms, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales; --El estatus de la AclaraciÃ³n no puede ser Nulo
		END IF;
		
		--Se realiza la consulta por los parÃ¡metros de invocaciÃ³n del SP
		SELECT ea.pky_estatus_aclaracion, eca.pky_estatus_corporativo, ecg.pky_estatus_corporativo, ecan.descripcion, ecan.concatena_dictamen,
				ecan.id_etapa_canales, ecan.descripcion_etapa_canales, ecan.descripcion_sms
			INTO v_id_estatus_aclaracion, v_id_estatus_corp_analisis, v_id_estatus_corp_general, v_estatus_canales, v_concatena_dictamen,
				v_id_etapa_canales, v_desc_etapa_canales, v_estatus_sms
		FROM acl_estatus_canales ecan
			INNER JOIN acl_estatus_aclaracion ea ON ea.nombre = ecan.nombre_estatus_aclaracion 
			LEFT OUTER JOIN acl_estatus_corporativo ecg ON ecg.fky_tipo_estatus = 1 AND ecg.nombre = ecan.nombre_estatus_corp_general 
			LEFT OUTER JOIN acl_estatus_corporativo eca ON eca.fky_tipo_estatus = 2 AND eca.nombre = ecan.nombre_estatus_corp_analisis 
		WHERE pky_estatus_aclaracion = pEstatusAcl
			AND ecg.pky_estatus_corporativo = pEstatusCorpGral
			AND eca.pky_estatus_corporativo = pEstatusCorpAnalisis;
		
		--En caso que la consulta no devuelva resultados se valida si se tiene algÃºn comodÃ­n con un estatus de anÃ¡lisis
		IF v_estatus_canales IS NULL THEN
			SELECT ea.pky_estatus_aclaracion, eca.pky_estatus_corporativo, ecg.pky_estatus_corporativo, ecan.descripcion, ecan.concatena_dictamen,
					ecan.id_etapa_canales, ecan.descripcion_etapa_canales, ecan.descripcion_sms
				INTO v_id_estatus_aclaracion, v_id_estatus_corp_analisis, v_id_estatus_corp_general, v_estatus_canales, v_concatena_dictamen,
					v_id_etapa_canales, v_desc_etapa_canales, v_estatus_sms
			FROM acl_estatus_canales ecan
				INNER JOIN acl_estatus_aclaracion ea ON ea.nombre = ecan.nombre_estatus_aclaracion 
				LEFT OUTER JOIN acl_estatus_corporativo ecg ON ecg.fky_tipo_estatus = 1 AND ecg.nombre = ecan.nombre_estatus_corp_general 
				LEFT OUTER JOIN acl_estatus_corporativo eca ON eca.fky_tipo_estatus = 2 AND eca.nombre = ecan.nombre_estatus_corp_analisis 
			WHERE pky_estatus_aclaracion = pEstatusAcl
				AND ecg.pky_estatus_corporativo IS NULL 
				AND eca.pky_estatus_corporativo = pEstatusCorpAnalisis;
		END IF;
		
		--En caso que la consulta no devuelva resultados se valida si se tiene algÃºn comodÃ­n con un estatus de corporativo
		IF v_estatus_canales IS NULL THEN
			SELECT ea.pky_estatus_aclaracion, eca.pky_estatus_corporativo, ecg.pky_estatus_corporativo, ecan.descripcion, ecan.concatena_dictamen,
					ecan.id_etapa_canales, ecan.descripcion_etapa_canales, ecan.descripcion_sms
				INTO v_id_estatus_aclaracion, v_id_estatus_corp_analisis, v_id_estatus_corp_general, v_estatus_canales, v_concatena_dictamen,
					v_id_etapa_canales, v_desc_etapa_canales, v_estatus_sms
			FROM acl_estatus_canales ecan
				INNER JOIN acl_estatus_aclaracion ea ON ea.nombre = ecan.nombre_estatus_aclaracion 
				LEFT OUTER JOIN acl_estatus_corporativo ecg ON ecg.fky_tipo_estatus = 1 AND ecg.nombre = ecan.nombre_estatus_corp_general 
				LEFT OUTER JOIN acl_estatus_corporativo eca ON eca.fky_tipo_estatus = 2 AND eca.nombre = ecan.nombre_estatus_corp_analisis 
			WHERE pky_estatus_aclaracion = pEstatusAcl
				AND ecg.pky_estatus_corporativo = pEstatusCorpGral
				AND eca.pky_estatus_corporativo IS NULL;
		END IF;
		
		--En caso que la consulta no devuelva resultados se valida si existe el registro para el estatus de la aclaraciÃ³n
		IF v_estatus_canales IS NULL THEN
			SELECT ea.pky_estatus_aclaracion, ecan.descripcion, ecan.concatena_dictamen, ecan.id_etapa_canales, ecan.descripcion_etapa_canales, ecan.descripcion_sms
				INTO v_id_estatus_aclaracion, v_estatus_canales, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales, v_estatus_sms
			FROM acl_estatus_canales ecan
				INNER JOIN acl_estatus_aclaracion ea ON ea.nombre = ecan.nombre_estatus_aclaracion 
			WHERE pky_estatus_aclaracion = pEstatusAcl 
				AND ecan.nombre_estatus_corp_general IS NULL 
				AND ecan.nombre_estatus_corp_analisis IS NULL;
		END IF;
		
		--En caso que la consulta no devuelva resultados se mostrarÃ¡ el valor del Estatus de la aclaraciÃ³n
		IF v_estatus_canales IS NULL THEN
			SELECT ea.pky_estatus_aclaracion, ea.descripcion, 0
				INTO v_id_estatus_aclaracion, v_estatus_canales, v_concatena_dictamen
			FROM acl_estatus_aclaracion ea 
			WHERE pky_estatus_aclaracion = pEstatusAcl;
			
			--Se asignan los valores de la "Etapa" considerando el estatus de la AclaraciÃ³n
			IF v_id_estatus_aclaracion = 1 THEN
				LET v_id_etapa_canales = 1;
				LET v_desc_etapa_canales = 'ALTA';
			ELIF v_id_estatus_aclaracion = 2 THEN
				LET v_id_etapa_canales = 2;
				LET v_desc_etapa_canales = 'ANÃLISIS';
			ELIF v_id_estatus_aclaracion BETWEEN 3 AND 5 THEN
				LET v_id_etapa_canales = 3;
				LET v_desc_etapa_canales = 'DICTAMEN';
			ELSE
				LET v_id_etapa_canales = 0;
				LET v_desc_etapa_canales = 'NO DEFINIDO';
			END IF;
		END IF;
		
		IF v_estatus_canales IS NULL THEN
			LET v_cod_ret = '00002'; --El estatus de la AclaraciÃ³n no existe
		END IF;
		
		RETURN v_cod_ret, v_estatus_canales, v_estatus_sms, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales;
			
	END;
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Enero/2020',
'Requerimiento	:	RQM 18 145',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_consulta_aclaracion_sms(
                        pFolioCsuac CHAR(30),pCel CHAR(10), pnumCliente CHAR(20))
		
		RETURNING
		CHAR(5)				AS cod_ret;
		/*
		CHAR(10)			AS folio_csuac,
		MONEY				AS montoreclamado,
		MONEY				AS montoprocedente,
		CHAR(50)			AS estatus_canales,
		CHAR(15)			AS telefono_dudas,
		SMALLINT			AS procede,
		INTEGER				AS fky_estatus_aclaracion,
		INTEGER				AS fky_estatus_corp_analisis,
		INTEGER				AS fky_estatus_corp_general,
		CHAR(10)			AS num_cliente;
        */

		/*Definicion de Variables*/
		
		DEFINE sql_err 				INTEGER;
		DEFINE autentica            INTEGER;
	    DEFINE v_cod_ret 			CHAR(5);
		DEFINE v_cod_ret_reg_eve	CHAR(5);
		DEFINE v_folio_csuac    	CHAR(10); 
		DEFINE v_montoreclamado		MONEY;
	    DEFINE v_montoprocedente	MONEY;
		DEFINE v_estatus_canales    CHAR(50); 
		DEFINE v_estatus_sms        CHAR(50); 
		DEFINE v_telefono_dudas     CHAR(15);
		DEFINE v_procede		    SMALLINT;
		DEFINE v_fky_estatus_aclaracion  	INTEGER;
		DEFINE v_fky_estatus_corp_analisis 	INTEGER;
		DEFINE v_fky_estatus_corp_general 	INTEGER;	
		
		DEFINE v_desc_estatus_canales    CHAR(50);			
		DEFINE v_concatena_dictamen 	 SMALLINT;
	    DEFINE v_id_etapa_canales        SMALLINT;
        DEFINE v_desc_etapa_canales 	 CHAR(20);
		DEFINE v_num_cliente	         CHAR(10);
		DEFINE v_fecha_consulta	        DATETIME YEAR TO FRACTION(5);
		
		/*Inicializacion de Variables*/
		
		LET v_cod_ret   		= "00000";
		LET sql_err 			=	0;
		LET autentica 			=	0;
		LET v_folio_csuac   	= NULL;
		LET v_montoreclamado	= NULL;
	    LET v_montoprocedente	= NULL;
		LET v_estatus_canales   = NULL;
        LET v_estatus_sms       = NULL;
		LET v_telefono_dudas    = ''; 
		LET v_procede		    = NULL;
		LET v_fky_estatus_aclaracion  	= NULL;
		LET v_fky_estatus_corp_analisis = NULL;
		LET v_fky_estatus_corp_general 	= NULL;
		LET v_num_cliente	            = NULL;
		LET v_desc_estatus_canales      = NULL;		
		LET v_concatena_dictamen 		= NULL;
	    LET v_id_etapa_canales       	= NULL;
        LET v_desc_etapa_canales 		= NULL;	
		LET v_cod_ret_reg_eve 			= "00000";
		LET v_fecha_consulta			=NULL;
		
		SET ISOLATION TO DIRTY READ;
	    SET LOCK MODE TO WAIT 3;
			
		--SET DEBUG FILE TO "/informix/Paty/RQM665/sp_consulta_aclaracion_sms.out";
		--TRACE ON;
		
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_cod_ret = sql_err;
				
				--RETURN v_cod_ret, v_folio_csuac, v_montoreclamado, v_montoprocedente, v_estatus_canales, v_telefono_dudas, v_procede,v_fky_estatus_aclaracion,
				--v_fky_estatus_corp_analisis,v_fky_estatus_corp_general;
				
			END IF;
		END EXCEPTION;
				
	LET pFolioCsuac= pFolioCsuac;			
	
    --Validar Telefono 
	IF pnumCliente IS NOT NULL AND TRIM(pnumCliente) <> '' AND pFolioCsuac IS NOT NULL AND TRIM(pFolioCsuac) <> '' AND pCel IS NOT NULL AND TRIM(pCel) <> '' 

	THEN  
	
	SELECT folio_csuac,importereclamado,montoprocedente,procede,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,num_cliente
	INTO  v_folio_csuac,v_montoreclamado,v_montoprocedente,v_procede,v_fky_estatus_aclaracion,v_fky_estatus_corp_analisis,v_fky_estatus_corp_general,v_num_cliente
	FROM "informix".acl_aclaracion WHERE folio_csuac IN (pFolioCsuac);
 	
	SELECT COUNT(*) INTO autentica FROM "informix".acl_aclaracion WHERE folio_csuac = pFolioCsuac AND num_cliente= pnumCliente;
		
	--SELECT COUNT(*) INTO autentica FROM bdinteg:"informix".si_telefonos_actual WHERE numcte= v_num_cliente AND telefono = pCel AND tipo_tel = '2' AND status_tel = 'A';
	
	IF  autentica > 0  THEN
	 /* Insertar en tabla */
	INSERT INTO "informix".acl_bitacora_sms(folio, num_cliente, num_telefono, envio_exitoso, fecha_consulta) 
    VALUES(pFolioCsuac, pnumCliente, pCel, 1, current);
	
	
	--Se obtiene estatus---
	CALL "informix".sp_obten_estatus_canales_sms(v_fky_estatus_aclaracion, v_fky_estatus_corp_general, v_fky_estatus_corp_analisis)
			RETURNING  v_cod_ret,v_estatus_canales,v_estatus_sms, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales;
			
	
		IF v_concatena_dictamen = 1 THEN
			IF v_procede = 1 THEN
				LET v_estatus_sms = TRIM(v_estatus_sms) || ' - Procedente';
				LET v_montoreclamado = v_montoprocedente;
			ELIF v_procede = 0 THEN
				LET v_estatus_sms = TRIM(v_estatus_sms) || ' - No procedente';
			END IF;
		END IF;
		
			
		LET v_montoreclamado = NVL(v_montoreclamado,0);
		LET v_montoprocedente = NVL(v_montoprocedente,0);
		
	
	/* se envia a llamar el SP de registra evento si existe el status de la aclaracion*/		
	       
        IF  v_estatus_sms IS NOT NULL THEN 	   
		  
		CALL bdimnsj:sp_registra_evento('2','ACL_SMS','ACL_EST','000000000','','','1',v_folio_csuac,'','','',v_estatus_sms,'','','','','','',pCel,1,v_montoreclamado,v_montoprocedente,0,0,current,'') RETURNING v_cod_ret_reg_eve;	
	
        ELSE 
		
		CALL bdimnsj:sp_registra_evento('2','ACL_SMS','ACL_EST_ERR','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,current,'') RETURNING v_cod_ret_reg_eve;	
		
	    END IF;
				
		ELIF autentica = 0 OR v_cod_ret_reg_eve != '00000' THEN 
		
		/*Actualiza bitacora a no se envio*/
		LET v_cod_ret_reg_eve = '00001';

		CALL bdimnsj:sp_registra_evento('2','ACL_SMS','ACL_EST_ERR','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,current,'') RETURNING v_cod_ret_reg_eve;	

		INSERT INTO "informix".acl_bitacora_sms(folio, num_cliente, num_telefono, envio_exitoso, fecha_consulta) 
		VALUES(pFolioCsuac, pnumCliente, pCel, 0, current);

		END IF;
		
	ELSE	
	
	    LET v_cod_ret_reg_eve = '00003';
	
		CALL bdimnsj:sp_registra_evento('2','ACL_SMS','ACL_EST_ERR','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,current,'') RETURNING v_cod_ret_reg_eve;	

		INSERT INTO "informix".acl_bitacora_sms(folio, num_cliente, num_telefono, envio_exitoso, fecha_consulta) 
		VALUES(pFolioCsuac, pnumCliente, pCel, 3, current);
		

		END IF; 
    	LET v_cod_ret = v_cod_ret_reg_eve;
				
		RETURN v_cod_ret;
	END;
END PROCEDURE;