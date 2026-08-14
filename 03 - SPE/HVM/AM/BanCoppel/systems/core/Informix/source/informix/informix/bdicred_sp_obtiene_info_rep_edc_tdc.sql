CREATE PROCEDURE "informix".sp_obtiene_info_rep_edc_tdc(v_num_credito CHAR(20), v_numcte CHAR(20), v_fecha_consul DATE, v_fecha_corte_edc DATE, v_sin_servicio CHAR(1),
														v_view_down	CHAR(1), v_no_view_down CHAR(1), v_si_serv_sin_view CHAR(1),v_canal CHAR(4)
														)

RETURNING 	--CHAR(255) AS Mensaje_Salida, 
			CHAR(5) AS Codigo_Retorno;
-- CANAL MAIL: 5000
-- CANAL APP : 5011
-- CANAL BPI : 5003

-- ************************************************************
-- *** DECLARACION DE VARIABLES INTERNAS DEL STORED PROCEDURE ***
-- ************************************************************
DEFINE iSqlErr                  INTEGER;     
DEFINE iIsamErr                 INTEGER; 
DEFINE cCodRet                  CHAR(5);
DEFINE cErrorInfo               VARCHAR(255); 
DEFINE cMensajeSalida			CHAR(150);
DEFINE v_x_mail                 CHAR(2);
DEFINE v_x_app_movil            CHAR(2);
DEFINE v_x_suc_web              CHAR(2);
DEFINE v_mto_comi               DECIMAL(18,2);
DEFINE v_mto_mora               DECIMAL(18,2);	
DEFINE v_fecha_hoy              DATE;
DEFINE v_ult_dia_mes            DATE;
DEFINE vCanal_aprob				CHAR(4);
DEFINE v_num_proceso			CHAR(4);

-- ************************************************************
-- *** INICIALIZACION DE VARIABLES ***
-- ************************************************************

LET iSqlErr                     = 0;
LET iIsamErr                    = 0;
LET cCodRet                     = '00000';
LET cErrorInfo                  = '';
LET cMensajeSalida              = 'PROCESO EXITOSO';
LET v_x_mail                    = '';
LET v_x_app_movil               = '';
LET v_x_suc_web                 = '';
LET v_mto_comi                  = 0;
LET v_mto_mora                  = 0;
LET v_fecha_hoy                 = DATE(1);
LET vCanal_aprob				= '';
LET v_num_proceso				= '0017';

-- ************************************************************
-- *** BLOQUE PRINCIPAL DEL STORED PROCEDURE ***
-- ************************************************************
BEGIN -- Inicio del bloque principal del SP

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			DROP TABLE IF EXISTS tmp_canales;
			--LET cMensajeSalida = cErrorInfo;
			RETURN TRIM('00000');
			
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
--SET DEBUG FILE TO "/informix/David/RQM_10_1790/sp_obtiene_info_rep_edc_tdc.out";
--TRACE ON;

	SELECT CURRENT::DATE 
		INTO v_fecha_hoy 
	FROM systables WHERE tabid = 1;
	
	SELECT id_canal, cc_canal
	FROM bdinteg:"informix".si_canales WHERE id_canal IN('03','17')
	INTO TEMP tmp_canales WITH NO LOG;
	
	SELECT cc_canal INTO vCanal_aprob 
	FROM tmp_canales WHERE cc_canal = v_canal;

	--WHILE 1 = 1
	
	IF vCanal_aprob = v_canal THEN 
		IF v_fecha_hoy = v_fecha_consul THEN 
			IF NOT EXISTS (
				SELECT num_credito FROM "informix".sd_info_rep_edc 
				WHERE num_credito = v_num_credito AND fecha_consul = v_fecha_consul AND fecha_corte_edc = v_fecha_corte_edc AND canal = v_canal 
			  ) THEN
						 INSERT INTO "informix".sd_info_rep_edc
									(
									num_credito,					numcte,						fecha_consul,					fecha_corte_edc,				sin_servicio,
									view_down,						no_view_down,               si_serv_sin_view,				canal	    				
									)
							 VALUES(
									NVL(v_num_credito,''),			NVL(v_numcte,''),			NVL(v_fecha_consul,DATE(1)),	NVL(v_fecha_corte_edc,DATE(1)),	NVL(v_sin_servicio,''),			
									NVL(v_view_down,''),			NVL(v_no_view_down,''),     NVL(v_si_serv_sin_view,''),		NVL(v_canal,'')
									);
				--EXIT WHILE;
			ELSE 
				LET cMensajeSalida = 'Ya existe un registro durante el dia.';
				--EXIT WHILE;
			END IF;
		ELSE 
			LET cMensajeSalida = 'La fecha de consulta no es igual al dia de hoy.';
			LET cCodRet = '00001';
			--EXIT WHILE;
		END IF;
	ELSE 
		LET cMensajeSalida = 'El canal no es valido.';
		LET cCodRet = '00002';
		--EXIT WHILE;
	END IF;
	
	IF cCodRet != '00000' THEN
	
		INSERT INTO bdicred:sd_bitacora_mec (
					empresa, 		num_proceso, 	fecha_ejecucion, 	cod_ret, 	mensaje,
					user_insert, 	fecha_insert, 	hora_insert
					) 
			VALUES (
					'001',			v_num_proceso,	TODAY, 				cCodRet,	TRIM(cMensajeSalida) || ' Para el credito: ' || TRIM(v_num_credito) || ' con canal: ' || v_canal,
					user, 			TODAY,			CURRENT
					);
	END IF;
	DROP TABLE IF EXISTS tmp_canales;
			
	RETURN '00000';

END; 

END PROCEDURE;