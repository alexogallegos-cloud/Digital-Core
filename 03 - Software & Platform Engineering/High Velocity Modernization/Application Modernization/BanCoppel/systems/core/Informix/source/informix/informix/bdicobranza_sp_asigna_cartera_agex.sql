CREATE PROCEDURE "informix".sp_asigna_cartera_agex(ptipo_cobranza CHAR(1), paccion CHAR(2))
returning VARCHAR(06),
          VARCHAR(80);
-----------------------------------------------------------------------
--  EXECUTE PROCEDURE "informix".sp_asigna_cartera_agex('R', 'AS');

DEFINE SQL_ERR					INTEGER;
DEFINE ISAM_ERR					INTEGER;
DEFINE ERROR_INFO				VARCHAR(80);
DEFINE cProceso					CHAR(4);
DEFINE P_COD_RET				VARCHAR(6);
DEFINE P_MENSAJE				VARCHAR(200);
DEFINE cCodRet  				CHAR(6);

DEFINE v_pago_venc_ini			INTEGER;
DEFINE v_pago_venc_fin			INTEGER;
DEFINE v_porcentaje_asignado 	DECIMAL(9,2);
DEFINE pfechaevalua				DATE;
DEFINE v_cantidadtdc 			INTEGER;
DEFINE v_asignados				INTEGER;
DEFINE vcontador 				INTEGER;
DEFINE v_num_producto			CHAR(4);
DEFINE v_numcte 				CHAR(20);
DEFINE v_fecha_insert			DATE;
DEFINE v_num_credito 			CHAR(20);
DEFINE v_puntualidad 			CHAR(1);
DEFINE v_eficiencia 			SMALLINT;
DEFINE v_calificacion 			SMALLINT;
DEFINE v_pago_venc 				SMALLINT;
DEFINE v_prioridad 				SMALLINT;
DEFINE v_tipo_logica 			SMALLINT;
DEFINE v_status_cliente 		CHAR(2);
DEFINE v_tipo_movto 			SMALLINT;
DEFINE v_fecha_modificacion 	DATE;
DEFINE v_apell_paterno 			CHAR(26);
DEFINE v_apell_materno 			CHAR(26);
DEFINE v_nombre1 				CHAR(26);
DEFINE v_nombre2 				CHAR(26);
DEFINE v_sucursal 				CHAR(4);
DEFINE v_fecha_apertura 		DATE;
DEFINE v_monto_ult_pago_periodo DECIMAL(18,2);
DEFINE v_pagos_realizados 		DECIMAL(18,2);
DEFINE v_fecha_ultimo_pago 		DATE;
DEFINE v_dias_atraso 			SMALLINT;
DEFINE v_saldo_vencido_inicial 	DECIMAL(18,2);
DEFINE v_saldo_total_inicial 	DECIMAL(18,2);
DEFINE v_saldo_vencido_final 	DECIMAL(18,2);
DEFINE v_saldo_total_final 		DECIMAL(18,2);
DEFINE v_saldovencido1 			DECIMAL(18,2);
DEFINE v_saldovencido2 			DECIMAL(18,2);
DEFINE v_saldovencido3 			DECIMAL(18,2);
DEFINE v_saldovencido4 			DECIMAL(18,2);
DEFINE v_saldovencido5 			DECIMAL(18,2);
DEFINE v_saldovencido6 			DECIMAL(18,2);
DEFINE v_interesmoratorio1 		DECIMAL(18,2);
DEFINE v_interesmoratorio2 		DECIMAL(18,2);
DEFINE v_interesmoratorio3 		DECIMAL(18,2);
DEFINE v_interesmoratorio4 		DECIMAL(18,2);
DEFINE v_interesmoratorio5 		DECIMAL(18,2);
DEFINE v_interesmoratorio6 		DECIMAL(18,2);
DEFINE v_sdo_intereses 			DECIMAL(18,2);
DEFINE v_pago_vencido1_inicial	DECIMAL(18,2);
DEFINE v_pago_vencido2_inicial	DECIMAL(18,2);
DEFINE v_pago_vencido3_inicial	DECIMAL(18,2);
DEFINE v_pago_vencido4_inicial	DECIMAL(18,2);
DEFINE v_pago_vencido1_final 	DECIMAL(18,2);
DEFINE v_pago_vencido2_final 	DECIMAL(18,2);
DEFINE v_pago_vencido3_final 	DECIMAL(18,2);
DEFINE v_pago_vencido4_final 	DECIMAL(18,2);
DEFINE v_cantidadpp12 			INTEGER;
DEFINE v_preasignados 			INTEGER;
DEFINE v_cantidadant 	 		INTEGER;
DEFINE cNumProd 				CHAR(4);
DEFINE v_fecha_vigencia			DATE;
DEFINE vFecha_hoy               DATE;
DEFINE b_Upd_saldos_ini         CHAR(1);

DEFINE iCantTbl_Agex            INTEGER;
DEFINE c_digitos_selec          CHAR(2);
DEFINE cSql                     CHAR(500);
DEFINE vEmpresa                 CHAR(3);
DEFINE cruta                    CHAR(100);
DEFINE iCantTest                INTEGER;
DEFINE iCargaIni_A              INTEGER;
DEFINE iCargaIni_R              INTEGER;
DEFINE iCargaSig_A              INTEGER;
DEFINE iCargaSig_R              INTEGER;
DEFINE v_num_credito_previo		CHAR(20);
DEFINE v_pago_venc_previo       INTEGER;        
DEFINE v_numcte_previo          CHAR(20);
DEFINE c_canal                  CHAR(4);
DEFINE dt_fecha_asigna_mesant   DATE;
DEFINE v_numcte_mesant			CHAR(20);
DEFINE v_num_credito_mesant	    CHAR(20);
DEFINE c_canal_mesant           CHAR(4);
DEFINE vFecha_hoy_sys           DATE;
DEFINE pfechaevalua_tdc			DATE;
DEFINE v_pago_venc_en_tipoA     SMALLINT;
DEFINE v_numcte_en_tipoA        CHAR(20);
DEFINE v_num_credito_en_tipoA   CHAR(20);
DEFINE c_canal_en_tipoA         CHAR(4);
DEFINE v_num_credito_c 			CHAR(20);
DEFINE v_status_cliente_c 		CHAR(2);
DEFINE v_tipomov		 		INTEGER;
DEFINE v_bandera_reasigna		INTEGER;
DEFINE c_canal_reasigna         VARCHAR(4);
DEFINE c_canal_anterior         VARCHAR(4);
DEFINE c_fecha_reasigna         DATE;
DEFINE cCanal_digitos			VARCHAR(4);
DEFINE cCanal_actual			VARCHAR(4);
      
BEGIN 
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET = SQL_ERR;
     LET P_MENSAJE = ERROR_INFO ||'   Error credito: '||v_num_credito;
     CALL "informix".sp_inserta_bitacora_cob("001", cProceso, P_COD_RET, P_MENSAJE, '02')
     RETURNING P_COD_RET;
     LET P_COD_RET = SQL_ERR;
     RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

	--SET DEBUG FILE TO "/ifxsif01/aldo/asig/sp_asigna_cartera_agex.out";
	--TRACE ON;

	LET cProceso            		= '0086';
	LET P_COD_RET           		= '000000';
	LET P_MENSAJE           		= 'El proceso ASIGNACION EXT se ejecuto correctamente.';
	LET cCodRet           			= '000000';

	LET v_pago_venc_ini				= 0;
	LET v_pago_venc_fin				= 0;
	LET v_porcentaje_asignado 		= 0;
	LET pfechaevalua				= DATE(1);
	LET v_cantidadtdc 				= 0;
	LET v_asignados					= 0;
	LET vcontador 					= 0;
	LET v_num_producto				= "";
	LET v_numcte 					= "";
	LET v_fecha_insert				= DATE(1);
	LET v_num_credito 				= "";
	LET v_puntualidad 				= "";
	LET v_eficiencia 				= 0;
	LET v_calificacion 				= 0;
	LET v_pago_venc 				= 0;
	LET v_prioridad 				= 0;
	LET v_tipo_logica 				= 0;
	LET v_status_cliente 			= "";
	LET v_tipo_movto 				= 0;
	LET v_fecha_modificacion 		= DATE(1);
	LET v_apell_paterno 			= "";
	LET v_apell_materno 			= "";
	LET v_nombre1 					= "";
	LET v_nombre2 					= "";
	LET v_sucursal 					= "";
	LET v_fecha_apertura 			= DATE(1);
	LET v_monto_ult_pago_periodo 	= 0;
	LET v_pagos_realizados 			= 0;
	LET v_fecha_ultimo_pago 		= DATE(1);
	LET v_dias_atraso 				= 0;
	LET v_saldo_vencido_inicial 	= 0;
	LET v_saldo_total_inicial 		= 0;
	LET v_saldo_vencido_final 		= 0;
	LET v_saldo_total_final 		= 0;
	LET v_saldovencido1 			= 0;
	LET v_saldovencido2 			= 0;
	LET v_saldovencido3 			= 0;
	LET v_saldovencido4 			= 0;
	LET v_saldovencido5 			= 0;
	LET v_saldovencido6 			= 0;
	LET v_interesmoratorio1 		= 0;
	LET v_interesmoratorio2 		= 0;
	LET v_interesmoratorio3 		= 0;
	LET v_interesmoratorio4 		= 0;
	LET v_interesmoratorio5 		= 0;
	LET v_interesmoratorio6 		= 0;
	LET v_sdo_intereses 			= 0;
	LET v_pago_vencido1_inicial		= 0;
	LET v_pago_vencido2_inicial		= 0;
	LET v_pago_vencido3_inicial		= 0;
	LET v_pago_vencido4_inicial		= 0;
	LET v_pago_vencido1_final 		= 0;
	LET v_pago_vencido2_final 		= 0;
	LET v_pago_vencido3_final 		= 0;
	LET v_pago_vencido4_final 		= 0;
	LET v_cantidadpp12 				= 0;
	LET v_preasignados 				= 0;
	LET v_cantidadant 	 			= 0;
	LET cNumProd 					= "";
	LET v_fecha_vigencia 			= DATE(1);
    LET vFecha_hoy                  = DATE(1);
	LET iCantTbl_Agex               = 0;
	LET c_digitos_selec             = '';
	LET cSql                        = ''; 
    LET vEmpresa                    = '001';
	LET cruta                       = '';
	LET iCantTest                   = 0;
	
	
	LET iCargaIni_A             = 0;
    LET iCargaIni_R             = 0;
    LET iCargaSig_A             = 0;
    LET iCargaSig_R             = 0;
	LET v_num_credito_previo    = '';
	LET v_pago_venc_previo      = 0;
	LET v_numcte_previo         = '';
	LET c_canal                 = '';  
	LET dt_fecha_asigna_mesant  = DATE(1);
	LET v_numcte_mesant			= '';
    LET v_num_credito_mesant	= '';
    LET c_canal_mesant          = '';
	LET b_Upd_saldos_ini        = '0'; 
	LET vFecha_hoy_sys          = DATE(1);
	LET pfechaevalua_tdc        = DATE(1);
	LET v_pago_venc_en_tipoA    = 0;
	LET v_numcte_en_tipoA       = '';
	LET v_num_credito_en_tipoA  = '';
	LET c_canal_en_tipoA        = '';
	LET v_num_credito_c 		= "";
	LET v_status_cliente_c		= '';
	LET v_tipomov				= 0;
	LET v_bandera_reasigna 		= 0;
	LET c_canal_reasigna		= '';
	LET c_canal_anterior		= '';	
    LET c_fecha_reasigna		= DATE(1);	
	LET cCanal_digitos			= '';
	LET cCanal_actual			= '';
	

	CALL "informix".sp_inserta_bitacora_cob("001", cProceso, cCodRet, "INICIO PROCESO "||paccion||" PARA TIPO COBRANZA "||ptipo_cobranza||"", '02')
		RETURNING P_COD_RET;

	IF P_COD_RET != '000000' THEN
	   LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
	   RETURN P_COD_RET,P_MENSAJE;
	END IF;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


		
	SELECT MAX(fecha_insert) INTO pfechaevalua
	FROM "informix".cb_cat_directorio_cte
	WHERE tipo_cobranza = ptipo_cobranza; 

	--LET pfechaevalua = MDY(02,20,2020); -- PARA TEST TIPO R (MACF)
    --LET vFecha_hoy_sys = MDY(03,24,2019);  -- SOLO TEST MACF 

	LET vFecha_hoy_sys = TODAY;
	
    --LET dt_fecha_asigna_mesant = pfechaevalua -1 UNITS MONTH;
	LET dt_fecha_asigna_mesant = bdicred:monthadd(pfechaevalua, -1);
	 
	  
	IF paccion = "AS" THEN	
	
		
		IF ptipo_cobranza = "A" THEN
			   
			   
			   -- Crear tabla temporal con los datos de la asignaciÃÂÃÂÃÂÃÂ³n anterior (mes anterior)
			    SELECT numcte, num_credito, pago_venc, canal 
				  FROM bdicobranza:cb_cat_directorio_cte
				 WHERE empresa = vEmpresa AND tipo_cobranza = ptipo_cobranza 
				   AND fecha_insert = dt_fecha_asigna_mesant
				   AND status_cliente NOT IN('NT')
				  INTO temp paso_catdircte_anterior with no log;
				  
				  CREATE UNIQUE INDEX inx_paso_catdircte_anterior on paso_catdircte_anterior(numcte,num_credito);
                  UPDATE STATISTICS MEDIUM FOR TABLE paso_catdircte_anterior;
			   
				FOREACH WITH HOLD
			
				SELECT DISTINCT(canal) INTO c_canal_reasigna
				  FROM bdicobranza:cb_cat_directorio_cte
				 WHERE empresa = vEmpresa
				  AND tipo_cobranza = ptipo_cobranza
				  AND fecha_insert = pfechaevalua
				  AND status_cliente IN ("AC","EX")

					FOREACH WITH HOLD
					
						SELECT {+AVOID_FULL(bdicobranza:cb_gestion_cobagext_clasifica)} a.num_producto, a.numcte, a.num_credito, a.puntualidad, a.eficiencia, a.calificacion, a.pago_venc, 
							a.prioridad, a.tipo_logica, a.status_cliente, a.tipo_movto, a.fecha_modificacion, a.apell_paterno, a.apell_materno,
							a.nombre1, a.nombre2, a.digitos_selec, c.canal, a.canal
						INTO v_num_producto, v_numcte, v_num_credito, v_puntualidad, v_eficiencia, v_calificacion, v_pago_venc, 
							v_prioridad, v_tipo_logica, v_status_cliente, v_tipo_movto, v_fecha_modificacion, v_apell_paterno, v_apell_materno,
							v_nombre1, v_nombre2, c_digitos_selec, c_canal, cCanal_actual
						FROM bdicobranza:cb_cat_directorio_cte a
							INNER JOIN bdicobranza:cb_gestion_cobagext_clasifica c ON(a.digitos_selec = c.digitos_selec) -- and c.canal IN('PENT','TEST')   
						WHERE a.empresa = vEmpresa 
						AND a.tipo_cobranza = ptipo_cobranza
						AND a.fecha_insert = pfechaevalua 
						AND a.status_cliente IN ("AC","EX") 
						AND a.canal = c_canal_reasigna


						SELECT numcte, num_credito, canal INTO v_numcte_mesant, v_num_credito_mesant, c_canal_mesant
						FROM paso_catdircte_anterior
						WHERE numcte = v_numcte AND num_credito = v_num_credito;

						LET v_numcte_mesant = NVL(v_numcte_mesant,'');
						LET v_num_credito_mesant = NVL(v_num_credito_mesant,''); 
						LET c_canal_mesant = NVL(c_canal_mesant,'');
						LET v_bandera_reasigna = 1;
						
						-- Si existe en el mes anterior, solamente le actualizao el canal ya que si una vez fue asignado a ÃÂÃÂÃÂÃÂ©l
						-- no importa si aumentÃÂÃÂÃÂÃÂ³ o disminuyo su mora debe seguir atendiÃÂÃÂÃÂÃÂ©ndolo ese canal (de agex?)

						IF nvl(c_canal,'') = 'CAT' THEN
							LET cCanal_digitos='';
						ELSE 
							LET cCanal_digitos=c_canal;
						END IF;


						IF nvl(c_canal_mesant,'') != nvl(cCanal_digitos,'') AND nvl(c_canal_mesant,'') != '' THEN 
							BEGIN WORK;
								UPDATE "informix".cb_cat_directorio_cte 
								SET canal = cCanal_digitos, fecha_reasignacion=pfechaevalua, canal_ant_reasigna=c_canal_mesant
								WHERE empresa = vEmpresa 
								AND tipo_cobranza = ptipo_cobranza
								AND num_credito = v_num_credito
								AND fecha_insert = pfechaevalua; 
							COMMIT WORK;

						ELIF nvl(v_numcte_mesant,'') <> '' AND nvl(v_num_credito_mesant,'') <> '' and nvl(c_canal_mesant,'') <> '' THEN
							BEGIN WORK;
								UPDATE "informix".cb_cat_directorio_cte 
								SET canal = c_canal_mesant
								WHERE empresa = vEmpresa 
								AND tipo_cobranza = ptipo_cobranza
								AND num_credito = v_num_credito
								AND fecha_insert = pfechaevalua; 
							COMMIT WORK;

						ELIF v_pago_venc > 2 THEN
							IF trim(c_canal) = 'TEST' THEN
								Let v_status_cliente = 'TE';  
								BEGIN WORK;
									UPDATE "informix".cb_cat_directorio_cte 
									SET canal = 'TEST', status_cliente = v_status_cliente, fecha_reasignacion=pfechaevalua
									WHERE empresa = vEmpresa 
									AND tipo_cobranza = ptipo_cobranza
									AND num_credito = v_num_credito
									AND fecha_insert = pfechaevalua; 
								COMMIT WORK;
							ELIF (nvl(c_canal,'') <> '' AND nvl(c_canal,'') <> 'CAT' ) THEN
								IF v_pago_venc <= 8 THEN
									BEGIN WORK;
									UPDATE "informix".cb_cat_directorio_cte 
										SET canal = c_canal, fecha_reasignacion=pfechaevalua
									WHERE empresa = vEmpresa 
										AND tipo_cobranza = ptipo_cobranza
										AND num_credito = v_num_credito
										AND fecha_insert = pfechaevalua; 
									COMMIT WORK;
								ELSE
									LET v_bandera_reasigna = 0;	
								END IF;
							ELSE
								LET v_bandera_reasigna = 0;	   						    
							END IF;	
						ELSE
							LET v_bandera_reasigna = 0;
						END IF;						
						
						IF v_bandera_reasigna = 1 THEN
							FOREACH WITH HOLD
								SELECT num_credito,status_cliente, tipo_movto, canal, fecha_insert 
									INTO v_num_credito_c,v_status_cliente_c, v_tipomov, c_canal_anterior, c_fecha_reasigna 
								  FROM bdicobranza:cb_cat_directorio_cte
								  WHERE empresa = vEmpresa 
								  	AND status_cliente IN ("AC","EX") 
									AND canal != c_canal
									AND numcte = v_numcte
									AND num_credito != v_num_credito
									AND fecha_insert BETWEEN (pfechaevalua - 1 UNITS MONTH) AND (pfechaevalua)

								IF v_status_cliente_c = 'EX' THEN
									LET v_tipomov=9;
								END IF;	
								
								BEGIN WORK;
									UPDATE "informix".cb_cat_directorio_cte 
									SET canal = cCanal_digitos, fecha_reasignacion=pfechaevalua,
											tipo_movto=v_tipomov, canal_ant_reasigna=c_canal_anterior 
									WHERE empresa = vEmpresa 
									AND num_credito = v_num_credito_c
									AND fecha_insert = c_fecha_reasigna; 
								COMMIT WORK;
							END FOREACH;
						END IF;

					END FOREACH;

				END FOREACH;
			
		ELIF ptipo_cobranza = 'R' THEN 	--Tipo Cob R  (AsignaciÃÂÃÂÃÂÃÂ³n)

		        SELECT MAX(fecha_insert) INTO pfechaevalua_tdc
	              FROM "informix".cb_cat_directorio_cte
	             WHERE tipo_cobranza = 'A'; 
				
				--IF DAY(pfechaevalua) = 30 AND ( DAY(dt_fecha_asigna_mesant) = 30 AND month(dt_fecha_asigna_mesant) in(4,6,9,11) )  THEN
				IF DAY(pfechaevalua) = 30 AND ( DAY(dt_fecha_asigna_mesant) = 30 AND month(dt_fecha_asigna_mesant) in(3,5,8,10) )  THEN
				
				   SELECT num_producto, numcte, num_credito, pago_venc, canal 
				     FROM bdicobranza:cb_cat_directorio_cte
				    WHERE empresa = vEmpresa AND tipo_cobranza = ptipo_cobranza AND fecha_insert BETWEEN dt_fecha_asigna_mesant AND (dt_fecha_asigna_mesant +1 UNITS DAY)
				      AND status_cliente NOT IN('EX','NT')
			         INTO temp paso_catdircte_anterior with no log;
				
				/*ELIF DAY(pfechaevalua) = 30 AND ( DAY(dt_fecha_asigna_mesant) = 31 AND month(dt_fecha_asigna_mesant) in() )  THEN
				   
				   SELECT num_producto, numcte, num_credito, pago_venc, canal 
				     FROM bdicobranza:cb_cat_directorio_cte
				    WHERE empresa = vEmpresa AND tipo_cobranza = ptipo_cobranza AND fecha_insert BETWEEN (dt_fecha_asigna_mesant -1 UNITS DAY) AND dt_fecha_asigna_mesant
				      AND status_cliente NOT IN('EX','NT')
			         INTO temp paso_catdircte_anterior with no log; */
				   
				ELIF ( DAY(pfechaevalua) = 28 AND MONTH(pfechaevalua)= 2) OR (DAY(pfechaevalua) = 29 AND MONTH(pfechaevalua)= 2) THEN
                     LET dt_fecha_asigna_mesant = MDY(MONTH(dt_fecha_asigna_mesant),31,YEAR(dt_fecha_asigna_mesant));
					 
					 SELECT num_producto, numcte, num_credito, pago_venc, canal 
				     FROM bdicobranza:cb_cat_directorio_cte
				    WHERE empresa = vEmpresa AND tipo_cobranza = ptipo_cobranza AND fecha_insert BETWEEN (dt_fecha_asigna_mesant -1 UNITS DAY) AND dt_fecha_asigna_mesant
				      AND status_cliente NOT IN('EX','NT')
			         INTO temp paso_catdircte_anterior with no log;
					 
				ELSE
				
				   SELECT num_producto, numcte, num_credito, pago_venc, canal 
				     FROM bdicobranza:cb_cat_directorio_cte
				    WHERE empresa = vEmpresa AND tipo_cobranza = ptipo_cobranza AND fecha_insert = dt_fecha_asigna_mesant
				      AND status_cliente NOT IN('EX','NT')
			         INTO temp paso_catdircte_anterior with no log;
				
				END IF;
			

			FOREACH WITH HOLD
			
				SELECT DISTINCT(canal) INTO c_canal_reasigna
				  FROM bdicobranza:cb_cat_directorio_cte
				 WHERE empresa = vEmpresa
				   AND tipo_cobranza = ptipo_cobranza
				   AND fecha_insert = pfechaevalua
				   AND status_cliente IN ("AC","EX")
				   AND num_producto IN ('6300','7600','7700','6800','6011') 
			    
				FOREACH WITH HOLD
					SELECT {+AVOID_FULL(bdicobranza:cb_gestion_cobagext_clasifica)} a.num_producto, a.numcte, a.num_credito, a.puntualidad, a.eficiencia, a.calificacion, a.pago_venc, 
							a.prioridad, a.tipo_logica, a.status_cliente, a.tipo_movto, a.fecha_modificacion, a.apell_paterno, a.apell_materno,
							a.nombre1, a.nombre2, a.digitos_selec, c.canal, a.canal
						INTO v_num_producto, v_numcte, v_num_credito, v_puntualidad, v_eficiencia, v_calificacion, v_pago_venc, 
							v_prioridad, v_tipo_logica, v_status_cliente, v_tipo_movto, v_fecha_modificacion, v_apell_paterno, v_apell_materno,
							v_nombre1, v_nombre2, c_digitos_selec, c_canal, cCanal_actual
						FROM bdicobranza:cb_cat_directorio_cte a
							INNER JOIN bdicobranza:cb_gestion_cobagext_clasifica c ON(a.digitos_selec = c.digitos_selec) -- and c.canal IN('PENT','TEST')   
						WHERE a.empresa = vEmpresa AND a.tipo_cobranza = ptipo_cobranza AND a.fecha_insert = pfechaevalua 
						AND a.status_cliente IN ("AC","EX") 
						AND a.num_producto IN ('6300','7600','7700','6800','6011')
						AND a.canal = c_canal_reasigna
					  
					/*-- Validar si el cliente ya estÃÂÃÂÃÂÃÂ¡ asignado en TDC (ÃÂÃÂÃÂÃÂltimo corte)
					--IPCB se incluye el limit para tener un registro unico
					SELECT limit 1 numcte, num_credito, canal, pago_venc INTO v_numcte_en_tipoA, v_num_credito_en_tipoA, c_canal_en_tipoA, v_pago_venc_en_tipoA
					  FROM bdicobranza:cb_cat_directorio_cte
					 WHERE tipo_cobranza = 'A' and fecha_insert = pfechaevalua_tdc 
					   AND numcte = v_numcte;
					   
					LET v_numcte_en_tipoA = NVL(v_numcte_en_tipoA,'');
                    LET v_num_credito_en_tipoA = NVL(v_num_credito_en_tipoA,'');
                    
					IF v_numcte_en_tipoA <> '' AND v_num_credito_en_tipoA <> '' THEN
                       BEGIN;
					        UPDATE "informix".cb_cat_directorio_cte 
						       SET canal = c_canal_en_tipoA
						     WHERE empresa = vEmpresa 
						       AND tipo_cobranza = ptipo_cobranza
						       AND num_credito = v_num_credito
						       AND fecha_insert = pfechaevalua; 
					   COMMIT;   
   					ELSE*/
					
						--Buscar el cliente en el corte anterior
						SELECT numcte, num_credito, canal INTO v_numcte_mesant, v_num_credito_mesant, c_canal_mesant
						  FROM paso_catdircte_anterior
						 WHERE numcte = v_numcte AND num_credito = v_num_credito;

						LET v_numcte_mesant = NVL(v_numcte_mesant,'');
						LET v_num_credito_mesant = NVL(v_num_credito_mesant,''); 
						LET c_canal_mesant = NVL(c_canal_mesant,'');
						LET v_bandera_reasigna = 1;
						
						-- Si existe en el mes anterior, solamente le actualizo el canal ya que si una vez fue asignado a ÃÂÃÂÃÂÃÂ©l
						-- no importa si aumentÃÂÃÂÃÂÃÂ³ o disminuyo su mora debe seguir atendiÃÂÃÂÃÂÃÂ©ndolo ese canal

						IF nvl(c_canal,'') = 'CAT' THEN
							LET cCanal_digitos='';
						ELSE 
							LET cCanal_digitos=c_canal;
						END IF;

						IF nvl(c_canal_mesant,'') != nvl(cCanal_digitos,'') AND nvl(c_canal_mesant,'') != '' THEN 
							BEGIN WORK;
								UPDATE "informix".cb_cat_directorio_cte 
								SET canal = cCanal_digitos, fecha_reasignacion=pfechaevalua, canal_ant_reasigna=c_canal_mesant
								WHERE empresa = vEmpresa 
								AND tipo_cobranza = ptipo_cobranza
								AND num_credito = v_num_credito
								AND fecha_insert = pfechaevalua; 
							COMMIT WORK; 

						ELIF v_numcte_mesant <> '' AND v_num_credito_mesant <> '' and nvl(c_canal_mesant,'') <> '' THEN
						    BEGIN;
								UPDATE "informix".cb_cat_directorio_cte 
								   SET canal = c_canal_mesant
								 WHERE empresa = vEmpresa 
								   AND tipo_cobranza = ptipo_cobranza
								   AND num_credito = v_num_credito
								   AND fecha_insert = pfechaevalua; 
						    COMMIT; 
						
						ELIF v_pago_venc > 2 THEN
							IF c_canal = 'TEST' THEN
								Let v_status_cliente = 'TE';  
								BEGIN;
									UPDATE "informix".cb_cat_directorio_cte 
									SET canal = 'TEST', status_cliente = v_status_cliente, fecha_reasignacion=pfechaevalua
									WHERE empresa = vEmpresa 
									AND tipo_cobranza = ptipo_cobranza
									AND num_credito = v_num_credito
									AND fecha_insert = pfechaevalua; 
								COMMIT;

							ELIF (nvl(c_canal,'') <> '' AND nvl(c_canal,'') <> 'CAT' ) THEN
								IF v_pago_venc <= 8 THEN
									BEGIN;
									UPDATE "informix".cb_cat_directorio_cte 
										SET canal = c_canal, fecha_reasignacion=pfechaevalua
									WHERE empresa = vEmpresa 
										AND tipo_cobranza = ptipo_cobranza
										AND num_credito = v_num_credito
										AND fecha_insert = pfechaevalua; 
									COMMIT;
								ELSE
									LET v_bandera_reasigna = 0;	
								END IF;			
							ELSE
								LET v_bandera_reasigna = 0;					    
							END IF;	
						ELSE
							LET v_bandera_reasigna = 0;
						END IF;

						IF v_bandera_reasigna = 1 THEN
							FOREACH WITH HOLD
								SELECT num_credito,status_cliente, tipo_movto, canal, fecha_insert 
									INTO v_num_credito_c,v_status_cliente_c, v_tipomov, c_canal_anterior, c_fecha_reasigna 
								  FROM bdicobranza:cb_cat_directorio_cte
								  WHERE empresa = vEmpresa 
								  	AND status_cliente IN ("AC","EX") 
									AND canal != c_canal
									AND numcte = v_numcte
									AND num_credito != v_num_credito
									AND fecha_insert BETWEEN (pfechaevalua - 1 UNITS MONTH) AND (pfechaevalua)

								IF v_status_cliente_c = 'EX' THEN
									LET v_tipomov=9;
								END IF;	
								
								BEGIN WORK;
									UPDATE "informix".cb_cat_directorio_cte 
									SET canal = cCanal_digitos, fecha_reasignacion=pfechaevalua,
											tipo_movto=v_tipomov, canal_ant_reasigna=c_canal_anterior 
									WHERE empresa = vEmpresa 
									AND num_credito = v_num_credito_c
									AND fecha_insert = c_fecha_reasigna; 
								COMMIT WORK;
							END FOREACH;
						END IF;
					
				END FOREACH;
			END FOREACH;	
		END IF;	

    ELIF paccion = "AC" THEN
	
		IF ptipo_cobranza = "A" THEN

		FOREACH WITH HOLD
			SELECT DISTINCT(canal) INTO c_canal
				FROM bdicobranza:cb_cat_directorio_cte
				WHERE empresa = vEmpresa
				AND tipo_cobranza = ptipo_cobranza
				AND num_producto in("6001","8100")
				AND fecha_insert >= (TODAY - 1 UNITS MONTH)
				AND fecha_insert <= TODAY

			FOREACH WITH HOLD
				SELECT fecha_insert, num_credito, status_cliente, tipo_movto, fecha_modificacion
				INTO v_fecha_insert, v_num_credito, v_status_cliente, v_tipo_movto, v_fecha_modificacion
				FROM "informix".cb_cat_directorio_cte
				WHERE empresa = "001"
				AND tipo_cobranza = ptipo_cobranza
				AND num_producto in("6001","8100")
				AND fecha_insert >= (TODAY - 1 UNITS MONTH)
				AND fecha_insert <= TODAY
				AND canal = c_canal

				SELECT monto_ultimo_pago, fecha_ultimo_pago, dias_atraso
					INTO v_monto_ult_pago_periodo, v_fecha_ultimo_pago, v_dias_atraso
				FROM bdicred:"informix".sd_indicador_cred
				WHERE empresa = "001"
				AND num_credito = v_num_credito;

				SELECT mto_venc_trasp+monto_vencido, sdo_cap_insoluto, saldovencido1, saldovencido2, saldovencido3,
						saldovencido4, saldovencido5, saldovencido6, interesmoratorio1, interesmoratorio2,
						interesmoratorio3, interesmoratorio4, interesmoratorio5, interesmoratorio6, sdo_intereses
					INTO v_saldo_vencido_inicial, v_saldo_total_inicial, v_saldovencido1, v_saldovencido2, v_saldovencido3,
						v_saldovencido4, v_saldovencido5, v_saldovencido6, v_interesmoratorio1, v_interesmoratorio2,
						v_interesmoratorio3, v_interesmoratorio4, v_interesmoratorio5, v_interesmoratorio6, v_sdo_intereses
				FROM bdicred:"informix".sd_sdos_cartera_linea
				WHERE num_credito = v_num_credito;

				IF v_monto_ult_pago_periodo IS NULL THEN LET v_monto_ult_pago_periodo = 0; END IF;
				IF v_dias_atraso IS NULL THEN LET v_dias_atraso = 0; END IF;
				IF v_saldo_vencido_inicial IS NULL THEN LET v_saldo_vencido_inicial = 0; END IF;
				IF v_saldo_total_inicial IS NULL THEN LET v_saldo_total_inicial = 0; END IF;
				IF v_saldovencido1 IS NULL THEN LET v_saldovencido1 = 0; END IF;
				IF v_saldovencido2 IS NULL THEN LET v_saldovencido2 = 0; END IF;
				IF v_saldovencido3 IS NULL THEN LET v_saldovencido3 = 0; END IF;
				IF v_saldovencido4 IS NULL THEN LET v_saldovencido4 = 0; END IF;
				IF v_saldovencido5 IS NULL THEN LET v_saldovencido5 = 0; END IF;
				IF v_saldovencido6 IS NULL THEN LET v_saldovencido6 = 0; END IF;
				IF v_interesmoratorio1 IS NULL THEN LET v_interesmoratorio1 = 0; END IF;
				IF v_interesmoratorio2 IS NULL THEN LET v_interesmoratorio2 = 0; END IF;
				IF v_interesmoratorio3 IS NULL THEN LET v_interesmoratorio3 = 0; END IF;
				IF v_interesmoratorio4 IS NULL THEN LET v_interesmoratorio4 = 0; END IF;
				IF v_interesmoratorio5 IS NULL THEN LET v_interesmoratorio5 = 0; END IF;
				IF v_interesmoratorio6 IS NULL THEN LET v_interesmoratorio6 = 0; END IF;
				IF v_sdo_intereses IS NULL THEN LET v_sdo_intereses = 0; END IF;

				LET v_saldo_vencido_final = v_saldo_vencido_inicial; LET v_saldo_total_final = v_saldo_total_inicial;

				--IF (v_fecha_insert = TODAY - 1 UNITS DAY)THEN
				IF (v_fecha_insert = vFecha_hoy_sys - 1 UNITS DAY)THEN
					LET v_pago_vencido1_inicial = v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

					LET v_pago_vencido2_inicial = v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

					LET v_pago_vencido3_inicial = v_saldovencido3 + v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

					LET v_pago_vencido4_inicial = v_saldovencido6 + v_saldovencido5 + v_saldovencido4 + v_saldovencido3 + v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

					BEGIN WORK;
						UPDATE "informix".cb_cat_directorio_cte
						SET saldo_vencido_inicial = v_saldo_vencido_inicial, saldo_total_inicial = v_saldo_total_inicial,
							monto_ult_pago = v_monto_ult_pago_periodo, fecha_ult_pago = v_fecha_ultimo_pago,
							dias_mora = v_dias_atraso, pago_vencido1_inicial = v_pago_vencido1_inicial,
							pago_vencido2_inicial = v_pago_vencido2_inicial, pago_vencido3_inicial = v_pago_vencido3_inicial,
							pago_vencido4_inicial = v_pago_vencido4_inicial
						WHERE num_credito = v_num_credito
						AND fecha_insert = v_fecha_insert;
						
					COMMIT WORK;
				END IF;

				--IF (v_fecha_ultimo_pago = TODAY - 1 UNITS DAY) THEN
				IF (v_fecha_ultimo_pago = vFecha_hoy_sys - 1 UNITS DAY) THEN
					SELECT pagos_realizados
					INTO v_pagos_realizados
					FROM "informix".cb_cat_directorio_cte
					WHERE num_credito = v_num_credito
					AND fecha_insert = v_fecha_insert;

					IF v_pagos_realizados IS NULL THEN LET v_pagos_realizados = 0; END IF;

					IF v_monto_ult_pago_periodo IS NULL THEN LET v_monto_ult_pago_periodo = 0; END IF;

					LET v_pagos_realizados = v_pagos_realizados + v_monto_ult_pago_periodo;

					BEGIN WORK;
						UPDATE "informix".cb_cat_directorio_cte
						SET pagos_realizados = v_pagos_realizados
						WHERE num_credito = v_num_credito
						AND fecha_insert = v_fecha_insert;

					COMMIT WORK;
				END IF;

				LET v_pago_vencido1_final = v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

				LET v_pago_vencido2_final = v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

				LET v_pago_vencido3_final = v_saldovencido3 + v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

				LET v_pago_vencido4_final = v_saldovencido6 + v_saldovencido5 + v_saldovencido4 + v_saldovencido3 + v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

				BEGIN WORK;
					UPDATE "informix".cb_cat_directorio_cte
					SET --status_cliente = v_status_cliente, tipo_movto = v_tipo_movto,
						--fecha_modificacion = v_fecha_modificacion,
						saldo_vencido_final = v_saldo_vencido_final, saldo_total_final = v_saldo_total_final,
						pago_vencido1_final = v_pago_vencido1_final, pago_vencido2_final = v_pago_vencido2_final,
						pago_vencido3_final = v_pago_vencido3_final, pago_vencido4_final = v_pago_vencido4_final
					WHERE num_credito = v_num_credito
					AND fecha_insert = v_fecha_insert;

				COMMIT WORK;
			END FOREACH;
		END FOREACH;

		ELSE  --AC TIPO R

			FOREACH WITH HOLD
				SELECT DISTINCT(canal) INTO c_canal
					FROM bdicobranza:cb_cat_directorio_cte
					WHERE empresa = vEmpresa
					AND tipo_cobranza = ptipo_cobranza
					AND num_producto in ("6300","7600","7700","6800","6011")
					AND fecha_insert >= (TODAY - 1 UNITS MONTH)
					AND fecha_insert <= TODAY

				FOREACH WITH HOLD
					SELECT fecha_insert, num_credito, status_cliente, tipo_movto, fecha_modificacion
					INTO v_fecha_insert, v_num_credito, v_status_cliente, v_tipo_movto, v_fecha_modificacion
					FROM "informix".cb_cat_directorio_cte
					WHERE empresa = vEmpresa
					AND tipo_cobranza = ptipo_cobranza
					AND num_producto IN ("6300","7600","7700","6800","6011")
					AND fecha_insert >= (TODAY - 1 UNITS MONTH)
					AND fecha_insert <= TODAY
					AND canal = c_canal

					SELECT monto_ultimo_pago, fecha_ultimo_pago, dias_atraso
						INTO v_monto_ult_pago_periodo, v_fecha_ultimo_pago, v_dias_atraso
					FROM bdicred:"informix".sd_indicador_cred_crd
					WHERE empresa = "001"
					AND num_credito = v_num_credito;

					SELECT mto_venc_trasp+monto_vencido, sdo_cap_insoluto, saldovencido1, saldovencido2, saldovencido3,
							saldovencido4, saldovencido5, saldovencido6, interesmoratorio1, interesmoratorio2,
							interesmoratorio3, interesmoratorio4, interesmoratorio5, interesmoratorio6, sdo_intereses
						INTO v_saldo_vencido_inicial, v_saldo_total_inicial, v_saldovencido1, v_saldovencido2, v_saldovencido3,
							v_saldovencido4, v_saldovencido5, v_saldovencido6, v_interesmoratorio1, v_interesmoratorio2,
							v_interesmoratorio3, v_interesmoratorio4, v_interesmoratorio5, v_interesmoratorio6, v_sdo_intereses 
					FROM bdicred:"informix".sd_sdos_cartera_linea
					WHERE num_credito = v_num_credito;

					IF v_monto_ult_pago_periodo IS NULL THEN LET v_monto_ult_pago_periodo = 0; END IF;
					IF v_dias_atraso IS NULL THEN LET v_dias_atraso = 0; END IF;
					IF v_saldo_vencido_inicial IS NULL THEN LET v_saldo_vencido_inicial = 0; END IF;
					IF v_saldo_total_inicial IS NULL THEN LET v_saldo_total_inicial = 0; END IF;
					IF v_saldovencido1 IS NULL THEN LET v_saldovencido1 = 0; END IF;
					IF v_saldovencido2 IS NULL THEN LET v_saldovencido2 = 0; END IF;
					IF v_saldovencido3 IS NULL THEN LET v_saldovencido3 = 0; END IF;
					IF v_saldovencido4 IS NULL THEN LET v_saldovencido4 = 0; END IF;
					IF v_saldovencido5 IS NULL THEN LET v_saldovencido5 = 0; END IF;
					IF v_saldovencido6 IS NULL THEN LET v_saldovencido6 = 0; END IF;
					IF v_interesmoratorio1 IS NULL THEN LET v_interesmoratorio1 = 0; END IF;
					IF v_interesmoratorio2 IS NULL THEN LET v_interesmoratorio2 = 0; END IF;
					IF v_interesmoratorio3 IS NULL THEN LET v_interesmoratorio3 = 0; END IF;
					IF v_interesmoratorio4 IS NULL THEN LET v_interesmoratorio4 = 0; END IF;
					IF v_interesmoratorio5 IS NULL THEN LET v_interesmoratorio5 = 0; END IF;
					IF v_interesmoratorio6 IS NULL THEN LET v_interesmoratorio6 = 0; END IF;
					IF v_sdo_intereses IS NULL THEN LET v_sdo_intereses = 0; END IF;

					LET v_saldo_vencido_final = v_saldo_vencido_inicial; LET v_saldo_total_final = v_saldo_total_inicial;

					--IF v_fecha_insert = TODAY THEN
					IF v_fecha_insert = vFecha_hoy_sys THEN
						LET v_pago_vencido1_inicial = v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

						LET v_pago_vencido2_inicial = v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

						LET v_pago_vencido3_inicial = v_saldovencido3 + v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

						LET v_pago_vencido4_inicial = v_saldovencido6 + v_saldovencido5 + v_saldovencido4 + v_saldovencido3 + v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

						BEGIN WORK;
							UPDATE "informix".cb_cat_directorio_cte
							SET saldo_vencido_inicial = v_saldo_vencido_inicial, saldo_total_inicial = v_saldo_total_inicial,
								monto_ult_pago = v_monto_ult_pago_periodo, fecha_ult_pago = v_fecha_ultimo_pago,
								dias_mora = v_dias_atraso, pago_vencido1_inicial = v_pago_vencido1_inicial,
								pago_vencido2_inicial = v_pago_vencido2_inicial, pago_vencido3_inicial = v_pago_vencido3_inicial,
								pago_vencido4_inicial = v_pago_vencido4_inicial
							WHERE num_credito = v_num_credito
							AND fecha_insert = v_fecha_insert;

						COMMIT WORK;
					END IF;

					--IF (v_fecha_ultimo_pago = TODAY - 1 UNITS DAY) THEN
					IF (v_fecha_ultimo_pago = vFecha_hoy_sys - 1 UNITS DAY) THEN
						SELECT pagos_realizados
						INTO v_pagos_realizados
						FROM "informix".cb_cat_directorio_cte
						WHERE num_credito = v_num_credito
						AND fecha_insert = v_fecha_insert;

						IF v_pagos_realizados IS NULL THEN LET v_pagos_realizados = 0; END IF;

						IF v_monto_ult_pago_periodo IS NULL THEN LET v_monto_ult_pago_periodo = 0; END IF;

						LET v_pagos_realizados = v_pagos_realizados + v_monto_ult_pago_periodo;

						BEGIN WORK;
							UPDATE "informix".cb_cat_directorio_cte
							SET pagos_realizados = v_pagos_realizados
							WHERE num_credito = v_num_credito
							AND fecha_insert = v_fecha_insert;
							--AND f_vigencia = "1";
						COMMIT WORK;
					END IF;

					LET v_pago_vencido1_final = v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

					LET v_pago_vencido2_final = v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

					LET v_pago_vencido3_final = v_saldovencido3 + v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

					LET v_pago_vencido4_final = v_saldovencido6 + v_saldovencido5 + v_saldovencido4 + v_saldovencido3 + v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

					BEGIN WORK;
						UPDATE "informix".cb_cat_directorio_cte
						SET --status_cliente = v_status_cliente, tipo_movto = v_tipo_movto,
							--fecha_modificacion = v_fecha_modificacion,
							saldo_vencido_final = v_saldo_vencido_final, saldo_total_final = v_saldo_total_final,
							pago_vencido1_final = v_pago_vencido1_final, pago_vencido2_final = v_pago_vencido2_final,
							pago_vencido3_final = v_pago_vencido3_final, pago_vencido4_final = v_pago_vencido4_final
						WHERE num_credito = v_num_credito
						AND fecha_insert = v_fecha_insert;

					COMMIT WORK;
				END FOREACH;
			END FOREACH;	
		END IF;

	
	END IF;	
	
	CALL "informix".sp_inserta_bitacora_cob("001", cProceso, cCodRet, "FIN PROCESO "||paccion||" PARA TIPO COBRANZA "||ptipo_cobranza||"", '02') RETURNING P_COD_RET;

	IF P_COD_RET != '000000' THEN
		LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
		RETURN P_COD_RET,P_MENSAJE;
	END IF;

	RETURN cCodRet,P_MENSAJE;
END;
END PROCEDURE;