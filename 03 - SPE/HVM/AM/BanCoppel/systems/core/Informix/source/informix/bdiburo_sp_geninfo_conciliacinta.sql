CREATE PROCEDURE "informix".sp_geninfo_conciliacinta()
RETURNING   CHAR(6) 	AS retorno,
            CHAR(100)   AS mensaje_ret;
DEFINE  iSqlErr      		INTEGER;
DEFINE iIsamErr         	INTEGER;
DEFINE cErrorINfo       	CHAR(100);
DEFINE cCodRet          	CHAR(6);
DEFINE cMensajeRet    		CHAR(100);

DEFINE v_fechaproceso       DATE;
DEFINE v_primero_mes        DATE;
DEFINE v_fechaproceso_ant   DATE;
DEFINE vano                 CHAR(04);
DEFINE vmes                 CHAR(02);
DEFINE vdia                 CHAR(02);
DEFINE vfecha_reporte       CHAR(08); 
DEFINE val_info_reporte    CHAR(08);
DEFINE vprod                CHAR(04);
DEFINE vNumCredAux          CHAR(12);
DEFINE vnum_cred            CHAR(12);
DEFINE vetiqueta            CHAR(02);
DEFINE v_tipocred           CHAR(02);
DEFINE vclave_obs           CHAR(02);
DEFINE vstatus_cred         CHAR(02);
DEFINE vsaldo_actual_SIC    DECIMAL(18,2);
DEFINE vsaldo_venc_SIC      DECIMAL(18,2);
DEFINE vmonto_insoluto_SIC  DECIMAL(18,2);
DEFINE vsaldo_actual_app    DECIMAL(18,2);
DEFINE vsaldo_venc_app      DECIMAL(18,2);
DEFINE vmonto_insoluto_app  DECIMAL(18,2);
DEFINE vsaldo_actual_dif    DECIMAL(18,2);
DEFINE vsaldo_venc_dif      DECIMAL(18,2);
DEFINE vmonto_insoluto_dif  DECIMAL(18,2);
--DEFINE v_valfecha            SMALLINT;
--DEFINE v_valcinta            SMALLINT;
--DEFINE vflag                 CHAR(1);

LET cCodRet 				= "000000";
LET  iSqlErr              	= 0;
LET iIsamErr             	= 0;
LET cErrorINfo           	= "";
LET vNumCredAux				= '';
LET vnum_cred				= '';

--LET vprod= '';
--LET v_valfecha           = 0;
--LET v_valcinta           = 0;

 BEGIN
	 ON EXCEPTION SET  iSqlErr, iIsamErr , cErrorINfo
     LET cCodRet=  iSqlErr;
     LET cMensajeRet= cErrorINfo;  
     RETURN cCodRet, cMensajeRet;
     END  EXCEPTION;

     --SET DEBUG FILE TO "sp_geninfo_conciliacinta.out";
     --TRACE ON; 

     SET ISOLATION TO DIRTY READ;
     SET LOCK MODE TO WAIT 3;

     SELECT pri_dia_mes -1, pri_dia_mes -  1 units month
     INTO v_fechaproceso,v_primero_mes
     FROM  bdicred:sd_fechas
     WHERE empresa = '001';

     --temporal para pruebas
		--LET v_fechaproceso = mdy('07','31','2014');
		--LET v_primero_mes  = mdy('07','01','2014');
     --temporal para pruebas
	 
     LET v_fechaproceso_ant = v_primero_mes - 1;
     LET vano = year(v_fechaproceso);
     LET vmes = lpad(month(v_fechaproceso),2,"0");
     LET vdia = lpad(day(v_fechaproceso),2,"0");
     LET vfecha_reporte = vdia||vmes||vano;

	SELECT valor INTO val_info_reporte FROM bdiburo:br_param WHERE cod_param = 135;
	IF val_info_reporte = vfecha_reporte THEN
	 	LET cCodRet     = "007777";
		LET cMensajeRet = "DETALLE DE CONCILIACIÓN "||vfecha_reporte|| " YA PROCESADO.";
	ELSE 
	FOREACH WITH HOLD  --Ciclo productos con diferencias /PRINCIPAL
		SELECT num_producto  
		INTO vprod 
		FROM bdiburo:br_fechas_concil
		WHERE fecha_proceso = v_fechaproceso
		AND num_producto NOT IN ('6300','6400')
		AND diferencia = 'D'

		--DETALLE DE diferenciaS TDC
		IF vprod = '6001' OR vprod = '6600' THEN   --IF Producto
			FOREACH WITH HOLD --Ciclo producto TDC
			
				--Extrae tipo de credito, clave observaciON y status credito que tengan diferencia.
				SELECT tipo_cred, clave_obs,status_cred
				INTO v_tipocred,vclave_obs,vstatus_cred
				FROM bdiburo:br_concil_consolidado
				WHERE fecha_proceso = v_fechaproceso
				AND num_producto = vprod 
				AND ( b_difprocesa = 'D' and (sdo_actual_dif > 0 OR sdo_vencido_dif > 0 OR sdo_insoluto_dif > 0 OR cred_diferencia  > 0)) 
				ORDER BY 1,2

				--Genera el universo de las SIC de ese tipo de credito a procesar.
				SELECT num_credito, status_cred, 'EN' ETIQUETA,NVL(saldo_actual,0) saldo_actual,  
				NVL(saldo_venc,0) saldo_venc,  NVL(monto_insoluto,0)  monto_insoluto
				FROM  bdiburo:br_burofisicas_describe  
				WHERE num_credito >= ''
				AND num_producto = vprod 
				AND fecha_reporte = vfecha_reporte
				AND clave_obs = vclave_obs
				AND status_Cred= vstatus_cred
				AND num_credito NOT IN (SELECT num_credito FROM bdiburo:br_concil_diferencias where fecha_proceso = v_fechaproceso)
				UNION ALL 
				SELECT num_credito, status_cred, 'EX' ETIQUETA,
				NVL(saldo_actual,0) saldo_actual,  NVL(saldo_venc,0) saldo_venc,  NVL(monto_insoluto,0)  monto_insoluto
				FROM  bdiburo:br_burofisicas_concilia 
				WHERE empresa = '001' 
				AND num_producto = vprod 
				AND num_credito >= ''
				AND motivo = 'CSS'
				AND fecha_cINta = v_fechaproceso
				AND clave_obs = vclave_obs
				AND status_Cred= vstatus_cred
				AND num_credito NOT IN (SELECT num_credito FROM bdiburo:br_concil_diferencias where fecha_proceso = v_fechaproceso)
				INTO temp tot_creditos_cintas WITH NO LOG;

				--Extrae INformación Operativa de las diferencias por tipo de credito
				--TDC Activa
				IF v_tipocred = 'AC' THEN --IF Tipo de Crédito / Activo
					SELECT a.num_credito, a.status_cred, nvl(dias_atraso,0) vdiasatraso
					FROM bdicred:sd_maecredcont a inner join bdicred:sd_indicador_cred  b
					on a.empresa = b.empresa and a.num_credito = b.num_credito
					WHERE a.fecha = v_fechaproceso
					AND a.empresa = '001'
					AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_concil_diferencias where fecha_proceso = v_fechaproceso)
					AND a.status_cred = vstatus_cred
				--Suc para pruebas
					--AND substr(sucursal,1,4) in (select sucursal from bdiburo:suc_pro where des_suc = 'TDC')
					INTO temp cred_act_op1 WITH NO LOG; 

					SELECT a.*, b.status_cred  vstatus_credAnt,
					CASE WHEN (vdiasatraso >=   1 ) THEN 'PC'
						 WHEN b.status_cred IN ('BT','BA') AND a.status_cred ='AA' THEN 'EL'
						 ELSE '' END clave_obs
					FROM cred_act_op1 a LEFT JOIN bdicred:sd_maecredcont b
					ON empresa = '001' AND a.num_credito = b.num_credito AND b.fecha = v_fechaproceso_ant
					INTO temp cred_act_op  WITH NO LOG;

					DROP TABLE cred_act_op1;
					
					IF day(v_fechaproceso) = 28 THEN --IF fecha fin de mes para saldos Activos
						SELECT b.num_credito,
						CASE WHEN (nvl(capvig28 + captrans28 + capvencnoexig28 + capvenexig28 + intvenc28 + ivaintvenc28 + moratorios28 + round((moratorios28 * 0.16),2),0)) >0 
							  AND (nvl(capvig28 + captrans28 + capvencnoexig28 + capvenexig28 + intvenc28 + ivaintvenc28 + moratorios28 + round((moratorios28 * 0.16),2),0)) <1 THEN 1
							 ELSE round (nvl(capvig28 + captrans28 + capvencnoexig28 + capvenexig28 + intvenc28 + ivaintvenc28 + moratorios28 + round((moratorios28 * 0.16),2),0)) END saldo_actual,
						CASE WHEN (nvl(captrans28 + capvenexig28 + intvenc28 + ivaintvenc28 + moratorios28 + round((moratorios28 * 0.16),2),0)) >0 
							  AND (nvl(captrans28 + capvenexig28 + intvenc28 + ivaintvenc28 + moratorios28 + round((moratorios28 * 0.16),2),0)) <1 THEN 1 
							 ELSE round(nvl(captrans28 + capvenexig28 + intvenc28 + ivaintvenc28 + moratorios28 + round((moratorios28 * 0.16),2),0),0) END saldo_vencido,
						CASE WHEN (nvl(capvig28 + captrans28 + capvencnoexig28 + capvenexig28,0)) >0 
							  AND (nvl(capvig28 + captrans28 + capvencnoexig28 + capvenexig28,0)) <1 THEN 1
							 WHEN (nvl(capvig28 + captrans28 + capvencnoexig28 + capvenexig28,0)) <0 THEN 0
							 ELSE round (nvl(capvig28 + captrans28 + capvencnoexig28 + capvenexig28,0)) END saldo_insoluto
						FROM bdicred:sd_sdodiario a INNER JOIN cred_act_op b
						ON a.num_credito = b.num_credito AND clave_obs  = vclave_obs AND b.status_Cred= vstatus_cred
						WHERE a.fecha = v_primero_mes
						AND a.num_credito >= ''
						order by b.num_credito
						INTO temp creditos_apps WITH NO LOG;

						DROP TABLE cred_act_op;
					ELIF day(v_fechaproceso) = 29 THEN --IF fecha fin de mes para saldos Activos
						SELECT b.num_credito,
						CASE WHEN (nvl(capvig29 + captrans29 + capvencnoexig29 + capvenexig29 + intvenc29 + ivaintvenc29 + moratorios29 + round((moratorios29 * 0.16),2),0)) >0 
							  AND (nvl(capvig29 + captrans29 + capvencnoexig29 + capvenexig29 + intvenc29 + ivaintvenc29 + moratorios29 + round((moratorios29 * 0.16),2),0)) <1 THEN 1
							 ELSE round (nvl(capvig29 + captrans29 + capvencnoexig29 + capvenexig29 + intvenc29 + ivaintvenc29 + moratorios29 + round((moratorios29 * 0.16),2),0)) END saldo_actual,
						CASE WHEN (nvl(captrans29 + capvenexig29 + intvenc29 + ivaintvenc29 + moratorios29 + round((moratorios29 * 0.16),2),0)) >0 
							  AND (nvl(captrans29 + capvenexig29 + intvenc29 + ivaintvenc29 + moratorios29 + round((moratorios29 * 0.16),2),0)) <1 THEN 1 
							 ELSE round(nvl(captrans29 + capvenexig29 + intvenc29 + ivaintvenc29 + moratorios29 + round((moratorios29 * 0.16),2),0),0) END saldo_vencido,
						CASE WHEN (nvl(capvig29 + captrans29 + capvencnoexig29 + capvenexig29,0)) >0 
							  AND (nvl(capvig29 + captrans29 + capvencnoexig29 + capvenexig29,0)) <1 THEN 1
							 WHEN (nvl(capvig29 + captrans29 + capvencnoexig29 + capvenexig29,0)) <0 THEN 0
							 ELSE round (nvl(capvig29 + captrans29 + capvencnoexig29 + capvenexig29,0)) END saldo_insoluto
						FROM bdicred:sd_sdodiario a INNER JOIN cred_act_op b
						ON a.num_credito = b.num_credito AND clave_obs  = vclave_obs AND b.status_Cred= vstatus_cred
						WHERE a.fecha = v_primero_mes
						AND a.num_credito >= ''
						order by b.num_credito
						INTO temp creditos_apps WITH NO LOG;

						DROP TABLE cred_act_op;
					ELIF day(v_fechaproceso) = 30 THEN --IF fecha fin de mes para saldos Activos
						SELECT b.num_credito,
						CASE WHEN (nvl(capvig30 + captrans30 + capvencnoexig30 + capvenexig30 + intvenc30 + ivaintvenc30 + moratorios30 + round((moratorios30 * 0.16),2),0)) >0 
							  AND (nvl(capvig30 + captrans30 + capvencnoexig30 + capvenexig30 + intvenc30 + ivaintvenc30 + moratorios30 + round((moratorios30 * 0.16),2),0)) <1 THEN 1
							 ELSE round (nvl(capvig30 + captrans30 + capvencnoexig30 + capvenexig30 + intvenc30 + ivaintvenc30 + moratorios30 + round((moratorios30 * 0.16),2),0)) END saldo_actual,
						CASE WHEN (nvl(captrans30 + capvenexig30 + intvenc30 + ivaintvenc30 + moratorios30 + round((moratorios30 * 0.16),2),0)) >0 
							  AND (nvl(captrans30 + capvenexig30 + intvenc30 + ivaintvenc30 + moratorios30 + round((moratorios30 * 0.16),2),0)) <1 THEN 1 
							 ELSE round(nvl(captrans30 + capvenexig30 + intvenc30 + ivaintvenc30 + moratorios30 + round((moratorios30 * 0.16),2),0),0) END saldo_vencido,
						CASE WHEN (nvl(capvig30 + captrans30 + capvencnoexig30 + capvenexig30,0)) >0 
							  AND (nvl(capvig30 + captrans30 + capvencnoexig30 + capvenexig30,0)) <1 THEN 1
							 WHEN (nvl(capvig30 + captrans30 + capvencnoexig30 + capvenexig30,0)) <0 THEN 0
							 ELSE round (nvl(capvig30 + captrans30 + capvencnoexig30 + capvenexig30,0)) END saldo_insoluto
						FROM bdicred:sd_sdodiario a INNER JOIN cred_act_op b
						ON a.num_credito = b.num_credito AND clave_obs  = vclave_obs AND b.status_Cred= vstatus_cred
						WHERE a.fecha = v_primero_mes
						AND a.num_credito >= ''
						order by b.num_credito
						INTO temp creditos_apps WITH NO LOG;

						DROP TABLE cred_act_op;
					ELSE  --IF fecha fin de mes para saldos 31 Activos
						SELECT b.num_credito,
						CASE WHEN (nvl(capvig31 + captrans31 + capvencnoexig31 + capvenexig31 + intvenc31 + ivaintvenc31 + moratorios31 + round((moratorios31 * 0.16),2),0)) >0 
							  AND (nvl(capvig31 + captrans31 + capvencnoexig31 + capvenexig31 + intvenc31 + ivaintvenc31 + moratorios31 + round((moratorios31 * 0.16),2),0)) <1 THEN 1
							 ELSE round (nvl(capvig31 + captrans31 + capvencnoexig31 + capvenexig31 + intvenc31 + ivaintvenc31 + moratorios31 + round((moratorios31 * 0.16),2),0)) END saldo_actual,
						CASE WHEN (nvl(captrans31 + capvenexig31 + intvenc31 + ivaintvenc31 + moratorios31 + round((moratorios31 * 0.16),2),0)) >0 
							  AND (nvl(captrans31 + capvenexig31 + intvenc31 + ivaintvenc31 + moratorios31 + round((moratorios31 * 0.16),2),0)) <1 THEN 1 
							 ELSE round(nvl(captrans31 + capvenexig31 + intvenc31 + ivaintvenc31 + moratorios31 + round((moratorios31 * 0.16),2),0),0) END saldo_vencido,
						CASE WHEN (nvl(capvig31 + captrans31 + capvencnoexig31 + capvenexig31,0)) >0 
							  AND (nvl(capvig31 + captrans31 + capvencnoexig31 + capvenexig31,0)) <1 THEN 1
							 WHEN (nvl(capvig31 + captrans31 + capvencnoexig31 + capvenexig31,0)) <0 THEN 0
							 ELSE round (nvl(capvig31 + captrans31 + capvencnoexig31 + capvenexig31,0)) END saldo_insoluto
						FROM bdicred:sd_sdodiario a INNER JOIN cred_act_op b
						ON a.num_credito = b.num_credito AND clave_obs  = vclave_obs AND b.status_Cred= vstatus_cred
						WHERE a.fecha = v_primero_mes
						AND a.num_credito >= ''
						order by b.num_credito
						INTO temp creditos_apps WITH NO LOG;

						DROP TABLE cred_act_op;
					END IF --FIN IF fecha fin de mes para saldos Activos	
					
					--EXTRAE PRIMER CREDITO A PROCESAR
					SELECT valor  INTO vNumCredAux
					FROM  bdiburo:br_param
					WHERE cod_param = 133;
					
					--Cruce cinta con operación (Hay Crédito en Cinta que no en la App)
					FOREACH WITH HOLD  --Ciclo Cinta con Operación
						SELECT a.num_credito,etiqueta, a.saldo_actual, a.saldo_venc,  a.monto_insoluto,b.saldo_actual,b.saldo_vencido,b.saldo_insoluto
						INTO vnum_cred,vetiqueta,vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app	 
						FROM creditos_apps  b  FULL OUTER JOIN tot_creditos_cintas a
						ON a.num_credito = b.num_credito AND a.num_credito > vNumCredAux 
						WHERE b.NUM_CREDITO IS  NULL

						LET vsaldo_actual_dif = vsaldo_actual_SIC;
						LET vsaldo_venc_dif =vsaldo_venc_SIC;
						LET vmonto_insoluto_dif	=vmonto_insoluto_SIC;

						BEGIN WORK;
							INSERT INTO br_concil_diferencias VALUES (v_fechaproceso,vprod,v_tipocred,vnum_cred,vclave_obs,vstatus_cred,
							vetiqueta,vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app,
							vsaldo_actual_dif,vsaldo_venc_dif,vmonto_insoluto_dif);

							UPDATE bdiburo:br_param SET valor = vnum_cred
							WHERE cod_param = 133;
						COMMIT WORK;
					END  FOREACH --FIN Ciclo Cinta con Operación
					
					BEGIN WORK;
						UPDATE bdiburo:br_param SET valor = ''
						WHERE cod_param = 133;
					COMMIT WORK; 

					SELECT valor INTO vNumCredAux
					FROM  bdiburo:br_param
					WHERE cod_param = 133;
					
					--Cruce operación con cinta (Hay Crédito en App que no en la Cinta)
					FOREACH WITH HOLD --Ciclo Operación con Cinta
						SELECT b.NUM_CREDITO,etiqueta,b.saldo_actual,b.saldo_vencido,b.saldo_insoluto, a.saldo_actual, a.saldo_venc,  a.monto_insoluto
						INTO vnum_cred,vetiqueta ,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app, vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC	 	 
						FROM  tot_creditos_cintas a FULL OUTER JOIN creditos_apps  b
						ON a.num_credito = b.num_credito AND b.NUM_CREDITO > vNumCredAux
						WHERE  A.NUM_CREDITO  IS  NULL
	
						LET vsaldo_actual_dif = vsaldo_actual_app;
						LET vsaldo_venc_dif =vsaldo_venc_app;
						LET vmonto_insoluto_dif	=vmonto_insoluto_app;
           
						BEGIN WORK;
							INSERT INTO br_concil_diferencias VALUES (v_fechaproceso,vprod,v_tipocred,vnum_cred,vclave_obs,vstatus_cred, vetiqueta,
							vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app, 
							vsaldo_actual_dif,vsaldo_venc_dif,vmonto_insoluto_dif);
	
							UPDATE bdiburo:br_param SET valor = vnum_cred
							WHERE cod_param = 133;
						COMMIT WORK;
					END  FOREACH  --FIN Ciclo Operación con Cinta
					
					BEGIN WORK;
						UPDATE bdiburo:br_param SET valor = ''
						WHERE cod_param = 133;
					COMMIT WORK;
         
					DROP TABLE creditos_apps;
				--TDC Reestructurada o Vendida
				ELIF  v_tipocred = 'RE'  OR v_tipocred = 'VE' THEN  --ELIF  Tipo de Crédito / Reestructuras o Vendidos
					--extrae INfo operativa 
					SELECT a.NUM_CREDITO,  0 saldo_actual, 0 saldo_vencido,  0 saldo_insoluto
					FROM bdicred:sd_maecred a INNER JOIN bdicred:sd_maesdos_vendida b
					ON fecha  BETWEEN   v_primero_mes AND v_fechaproceso  AND b.empresa =  a.empresa AND a.num_credito = b.num_credito
					WHERE a.empresa = '001'
					AND a.num_Credito NOT IN (SELECT num_credito FROM bdiburo:br_concil_diferencias where fecha_proceso = v_fechaproceso)
					AND status_cred = vstatus_cred
					AND num_producto = vprod 
				--Suc para pruebas
					--AND substr(sucursal,1,4) in (select sucursal from bdiburo:suc_pro where des_suc = 'TDC')
					order by a.num_credito					
					INTO temp creditos_apps WITH NO LOG;
					
					--EXTRAE PRIMER CREDITO A PROCESAR
					SELECT valor  INTO vNumCredAux
					FROM  bdiburo:br_param
					WHERE cod_param = 133;
					
					--Cruce cinta con operación (Hay Crédito en Cinta que no en la App)
					FOREACH WITH HOLD  --Ciclo Cinta con Operación
						SELECT a.num_credito,etiqueta, a.saldo_actual, a.saldo_venc,  a.monto_insoluto,b.saldo_actual,b.saldo_vencido,b.saldo_insoluto
						INTO vnum_cred,vetiqueta,vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app	 
						FROM creditos_apps  b  FULL OUTER JOIN tot_creditos_cintas a
						ON a.num_credito = b.num_credito AND a.num_credito > vNumCredAux 
						WHERE b.NUM_CREDITO IS  NULL

						LET vsaldo_actual_dif = vsaldo_actual_SIC;
						LET vsaldo_venc_dif =vsaldo_venc_SIC;
						LET vmonto_insoluto_dif	=vmonto_insoluto_SIC;

						BEGIN WORK;
							INSERT INTO br_concil_diferencias VALUES (v_fechaproceso,vprod,v_tipocred,vnum_cred,vclave_obs,vstatus_cred,
							vetiqueta,vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app,
							vsaldo_actual_dif,vsaldo_venc_dif,vmonto_insoluto_dif);

							UPDATE bdiburo:br_param SET valor = vnum_cred
							WHERE cod_param = 133;
						COMMIT WORK;
					END  FOREACH --FIN Ciclo Cinta con Operación
					
					BEGIN WORK;
						UPDATE bdiburo:br_param SET valor = ''
						WHERE cod_param = 133;
					COMMIT WORK; 

					SELECT valor INTO vNumCredAux
					FROM  bdiburo:br_param
					WHERE cod_param = 133;
					
					--Cruce operación con cinta (Hay Crédito en App que no en la Cinta)
					FOREACH WITH HOLD --Ciclo Operación con Cinta
						SELECT b.NUM_CREDITO,etiqueta,b.saldo_actual,b.saldo_vencido,b.saldo_insoluto, a.saldo_actual, a.saldo_venc,  a.monto_insoluto
						INTO vnum_cred,vetiqueta ,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app, vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC	 	 
						FROM  tot_creditos_cintas a FULL OUTER JOIN creditos_apps  b
						ON a.num_credito = b.num_credito AND b.NUM_CREDITO > vNumCredAux
						WHERE  A.NUM_CREDITO  IS  NULL
	
						LET vsaldo_actual_dif = vsaldo_actual_app;
						LET vsaldo_venc_dif =vsaldo_venc_app;
						LET vmonto_insoluto_dif	=vmonto_insoluto_app;
           
						BEGIN WORK;
							INSERT INTO br_concil_diferencias VALUES (v_fechaproceso,vprod,v_tipocred,vnum_cred,vclave_obs,vstatus_cred, vetiqueta,
							vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app, 
							vsaldo_actual_dif,vsaldo_venc_dif,vmonto_insoluto_dif);
	
							UPDATE bdiburo:br_param SET valor = vnum_cred
							WHERE cod_param = 133;
						COMMIT WORK;
					END  FOREACH  --FIN Ciclo Operación con Cinta
					
					BEGIN WORK;
						UPDATE bdiburo:br_param SET valor = ''
						WHERE cod_param = 133;
					COMMIT WORK;
         
					DROP TABLE creditos_apps;

				--TDC Cancelada
				ELIF  v_tipocred = 'CA' THEN  --ELIF  Tipo de Crédito / Cancelada
					--extrae INfo operativa
					SELECT a.num_credito,  0 saldo_actual, 0 saldo_vencido, 0 saldo_insoluto		
					  FROM bdicred:sd_maecred a inner join bdicred:sd_cred_can b
					    ON a.num_credito = b.num_credito AND fecha_can BETWEEN v_primero_mes AND v_fechaproceso  AND folio_cancelacion <>''
					 WHERE a.empresa = '001'
					   AND a.num_credito >= ''
					   AND a.status_cred = 'FF'
					--Suc para pruebas
					  --AND a.sucursal in (select sucursal from bdiburo:suc_pro where des_suc = 'TDC')   
				   ORDER BY a.num_credito	
				   INTO temp creditos_apps WITH NO LOG;					
					
					--EXTRAE PRIMER CREDITO A PROCESAR
					SELECT valor  INTO vNumCredAux
					FROM  bdiburo:br_param
					WHERE cod_param = 133;
					
					--Cruce cinta con operación (Hay Crédito en Cinta que no en la App)
					FOREACH WITH HOLD  --Ciclo Cinta con Operación
						SELECT a.num_credito,etiqueta, a.saldo_actual, a.saldo_venc,  a.monto_insoluto,b.saldo_actual,b.saldo_vencido,b.saldo_insoluto
						INTO vnum_cred,vetiqueta,vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app	 
						FROM creditos_apps  b  FULL OUTER JOIN tot_creditos_cintas a
						ON a.num_credito = b.num_credito AND a.num_credito > vNumCredAux 
						WHERE b.NUM_CREDITO IS  NULL

						LET vsaldo_actual_dif = vsaldo_actual_SIC;
						LET vsaldo_venc_dif =vsaldo_venc_SIC;
						LET vmonto_insoluto_dif	=vmonto_insoluto_SIC;

						BEGIN WORK;
							INSERT INTO br_concil_diferencias VALUES (v_fechaproceso,vprod,v_tipocred,vnum_cred,vclave_obs,vstatus_cred,
							vetiqueta,vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app,
							vsaldo_actual_dif,vsaldo_venc_dif,vmonto_insoluto_dif);

							UPDATE bdiburo:br_param SET valor = vnum_cred
							WHERE cod_param = 133;
						COMMIT WORK;
					END  FOREACH --FIN Ciclo Cinta con Operación
					
					BEGIN WORK;
						UPDATE bdiburo:br_param SET valor = ''
						WHERE cod_param = 133;
					COMMIT WORK; 

					SELECT valor INTO vNumCredAux
					FROM  bdiburo:br_param
					WHERE cod_param = 133;
					
					--Cruce operación con cinta (Hay Crédito en App que no en la Cinta)
					FOREACH WITH HOLD --Ciclo Operación con Cinta
						SELECT b.NUM_CREDITO,etiqueta,b.saldo_actual,b.saldo_vencido,b.saldo_insoluto, a.saldo_actual, a.saldo_venc,  a.monto_insoluto
						INTO vnum_cred,vetiqueta ,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app, vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC	 	 
						FROM  tot_creditos_cintas a FULL OUTER JOIN creditos_apps  b
						ON a.num_credito = b.num_credito AND b.NUM_CREDITO > vNumCredAux
						WHERE  A.NUM_CREDITO  IS  NULL
	
						LET vsaldo_actual_dif = vsaldo_actual_app;
						LET vsaldo_venc_dif =vsaldo_venc_app;
						LET vmonto_insoluto_dif	=vmonto_insoluto_app;
           
						BEGIN WORK;
							INSERT INTO br_concil_diferencias VALUES (v_fechaproceso,vprod,v_tipocred,vnum_cred,vclave_obs,vstatus_cred, vetiqueta,
							vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app, 
							vsaldo_actual_dif,vsaldo_venc_dif,vmonto_insoluto_dif);
	
							UPDATE bdiburo:br_param SET valor = vnum_cred
							WHERE cod_param = 133;
						COMMIT WORK;
					END  FOREACH  --FIN Ciclo Operación con Cinta
					
					BEGIN WORK;
						UPDATE bdiburo:br_param SET valor = ''
						WHERE cod_param = 133;
					COMMIT WORK;
         
					DROP TABLE creditos_apps;
					
				END IF --FIN IF Tipo de Crédito

				begin;				
				UPDATE br_concil_consolidado set b_difprocesa ='DP'       
				WHERE fecha_proceso = v_fechaproceso
				and num_producto = vprod
				and status_cred = vstatus_cred
				and clave_obs = vclave_obs;
				commit;					
				
				LET v_tipocred= '';
				LET vclave_obs= '';
				LET vstatus_cred = '';
				DROP TABLE tot_creditos_cintas;	
				
			END FOREACH --FIN Ciclo producto TDC
		ELIF vprod = '6011' THEN   --IF Producto
			FOREACH WITH HOLD --Ciclo producto Reestructura
			
				--Extrae tipo de credito, clave observaciON y status credito que tengan diferencia.
				SELECT tipo_cred, clave_obs,status_cred
				INTO v_tipocred,vclave_obs,vstatus_cred
				FROM bdiburo:br_concil_consolidado
				WHERE fecha_proceso = v_fechaproceso
				AND num_producto = vprod 
				AND ( b_difprocesa = 'D' and (sdo_actual_dif > 0 OR sdo_vencido_dif > 0 OR sdo_insoluto_dif > 0 OR cred_diferencia  > 0) )
				ORDER BY 1,2
				--Genera el universo de las SIC de ese tipo de credito a procesar.
				SELECT num_credito, status_cred, 'EN' ETIQUETA,NVL(saldo_actual,0) saldo_actual,  
				NVL(saldo_venc,0) saldo_venc,  NVL(monto_insoluto,0)  monto_insoluto
				FROM  bdiburo:br_burofisicas_describe  
				WHERE num_credito >= ''
				AND num_producto = vprod 
				AND fecha_reporte = vfecha_reporte
				AND clave_obs = vclave_obs
				AND status_Cred= vstatus_cred
				UNION ALL 
				SELECT num_credito, status_cred, 'EX' ETIQUETA,
				NVL(saldo_actual,0) saldo_actual,  NVL(saldo_venc,0) saldo_venc,  NVL(monto_insoluto,0)  monto_insoluto
				FROM  bdiburo:br_burofisicas_concilia 
				WHERE empresa = '001' 
				AND num_producto = vprod 
				AND num_credito >= ''
				AND motivo = 'CSS'
				AND fecha_cINta = v_fechaproceso
				AND clave_obs = vclave_obs
				AND status_Cred= vstatus_cred
				INTO temp tot_creditos_cintas WITH NO LOG;

				--Extrae INformación Operativa de las diferencias por tipo de credito
				--Reestructuras Activa
				IF v_tipocred = 'AC' THEN --IF Tipo de Crédito / Activo
					SELECT a.num_producto,a.num_credito, a.status_cred ,
						nvl(nvl(monto_vencido + mto_venc_trasp,0) + -- MONTO VENCIDO
						nvl(int_tra_no_exig,0) + -- INTERES VENCIDO
						nvl(mto_venc_int,0),0)    vsaldo_venc,
						nvl(dias_atraso,0) vdiasatraso
					FROM bdicred:sd_maecredcontcrd a INNER JOIN bdicred:sd_maesdoscontcrd b
					ON a.fecha = b.fecha AND a.empresa = b.empresa AND a.num_credito = b.num_credito
					INNER JOIN bdicred:sd_indicador_cred_crd c
					ON a.empresa = c.empresa AND a.num_credito = c.num_credito
					WHERE a.fecha = v_fechaproceso
					AND a.empresa = '001'
					AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_concil_diferencias where fecha_proceso = v_fechaproceso)
					AND a.num_producto = '6011'
				--Suc para pruebas
					--AND substr(sucursal,1,4) in (select sucursal from bdiburo:suc_pro where des_suc = 'REEST') 
					INTO temp cred_act_op1 WITH NO LOG; 
					
					SELECT a.*,NVL(NVL(monto_vencido + mto_venc_trasp,0) + -- MONTO VENCIDO
						NVL(int_tra_no_exig,0) + -- INTERES VENCIDO
						NVL(mto_venc_int,0),0) vsaldo_vencAnt, c.status_cred  vstatus_credAnt ,
						CASE WHEN (vdiasatraso >= 1 ) THEN 'PC'
							 WHEN ((c.status_cred  in ('BT','BA') and a.status_cred ='AA')
							   OR ((c.status_cred  = 'VP' and nvl(nvl(monto_vencido + mto_venc_trasp,0) + -- MONTO VENCIDO
															  nvl(int_tra_no_exig,0) + -- INTERES VENCIDO
															  nvl(mto_venc_int,0),0) > 0 )
									AND (a.status_cred = 'VP' and vsaldo_venc <= 0))) THEN 'EL'
							 ELSE '' END clave_obs  
					FROM cred_act_op1 a LEFT JOIN bdicred:sd_maesdoscontcrd b 
					ON a.num_credito = b.num_credito AND b.fecha = v_fechaproceso_ant
					LEFT JOIN bdicred:sd_maecredcontcrd c 
					ON c.empresa = '001' AND a.num_credito = c.num_credito AND c.fecha = v_fechaproceso_ant
					INTO temp cred_act_op  WITH NO LOG; 
					
					DROP TABLE cred_act_op1;
					
					SELECT B.num_credito, 
						CASE WHEN (nvl(nvl(sdo_cap_insoluto,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) +nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(provision_normal,0) + nvl(sdo_global_int,0),0)) >0 
                              AND (nvl(nvl(sdo_cap_insoluto,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) +nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(provision_normal,0) + nvl(sdo_global_int,0),0)) <1 THEN 1
							 ELSE ROUND (nvl(nvl(sdo_cap_insoluto,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) +nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(provision_normal,0) + nvl(sdo_global_int,0),0)) END  saldo_actual,
						CASE WHEN (nvl(vsaldo_venc,0)) >0 AND (nvl(vsaldo_venc,0)) <1 THEN 1
							 ELSE ROUND (nvl(vsaldo_venc,0)) END  saldo_vencido,
						CASE WHEN (sdo_cap_insoluto) >0 AND (sdo_cap_insoluto) <1 THEN 1
						     ELSE ROUND (sdo_cap_insoluto) END  saldo_insoluto
					FROM bdicred:sd_maesdoscontcrd a INNER JOIN cred_act_op  b
					ON a.num_credito = b.num_credito AND clave_obs  = vclave_obs AND b.status_Cred= vstatus_cred
					WHERE a.fecha =  v_fechaproceso
					AND a.num_credito >= ''
					order by b.num_credito
					INTO temp creditos_apps WITH NO LOG;

					DROP TABLE cred_act_op;

					--EXTRAE PRIMER CREDITO A PROCESAR
					SELECT valor  INTO vNumCredAux
					FROM  bdiburo:br_param
					WHERE cod_param = 133;
					
					--Cruce cinta con operación (Hay Crédito en Cinta que no en la App)
					FOREACH WITH HOLD  --Ciclo Cinta con Operación
						SELECT a.num_credito,etiqueta, a.saldo_actual, a.saldo_venc,  a.monto_insoluto,b.saldo_actual,b.saldo_vencido,b.saldo_insoluto
						INTO vnum_cred,vetiqueta,vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app	 
						FROM creditos_apps  b  FULL OUTER JOIN tot_creditos_cintas a
						ON a.num_credito = b.num_credito AND a.num_credito > vNumCredAux 
						WHERE b.NUM_CREDITO IS  NULL

						LET vsaldo_actual_dif = vsaldo_actual_SIC;
						LET vsaldo_venc_dif =vsaldo_venc_SIC;
						LET vmonto_insoluto_dif	=vmonto_insoluto_SIC;

						BEGIN WORK;
							INSERT INTO br_concil_diferencias VALUES (v_fechaproceso,vprod,v_tipocred,vnum_cred,vclave_obs,vstatus_cred,
							vetiqueta,vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app,
							vsaldo_actual_dif,vsaldo_venc_dif,vmonto_insoluto_dif);

							UPDATE bdiburo:br_param SET valor = vnum_cred
							WHERE cod_param = 133;
						COMMIT WORK;
					END  FOREACH --FIN Ciclo Cinta con Operación
					
					BEGIN WORK;
						UPDATE bdiburo:br_param SET valor = ''
						WHERE cod_param = 133;
					COMMIT WORK; 

					SELECT valor INTO vNumCredAux
					FROM  bdiburo:br_param
					WHERE cod_param = 133;
					
					--Cruce operación con cinta (Hay Crédito en App que no en la Cinta)
					FOREACH WITH HOLD --Ciclo Operación con Cinta
						SELECT b.NUM_CREDITO,etiqueta,b.saldo_actual,b.saldo_vencido,b.saldo_insoluto, a.saldo_actual, a.saldo_venc,  a.monto_insoluto
						INTO vnum_cred,vetiqueta ,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app, vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC	 	 
						FROM  tot_creditos_cintas a FULL OUTER JOIN creditos_apps  b
						ON a.num_credito = b.num_credito AND b.NUM_CREDITO > vNumCredAux
						WHERE  A.NUM_CREDITO  IS  NULL
	
						LET vsaldo_actual_dif = vsaldo_actual_app;
						LET vsaldo_venc_dif =vsaldo_venc_app;
						LET vmonto_insoluto_dif	=vmonto_insoluto_app;
           
						BEGIN WORK;
							INSERT INTO br_concil_diferencias VALUES (v_fechaproceso,vprod,v_tipocred,vnum_cred,vclave_obs,vstatus_cred, vetiqueta,
							vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app, 
							vsaldo_actual_dif,vsaldo_venc_dif,vmonto_insoluto_dif);
	
							UPDATE bdiburo:br_param SET valor = vnum_cred
							WHERE cod_param = 133;
						COMMIT WORK;
					END  FOREACH  --FIN Ciclo Operación con Cinta
					
					BEGIN WORK;
						UPDATE bdiburo:br_param SET valor = ''
						WHERE cod_param = 133;
					COMMIT WORK;
         
					DROP TABLE creditos_apps;

				--Reestructura Vendida
				ELIF  v_tipocred = 'VE' THEN  --ELIF  Tipo de Crédito / Vendidas
					--extrae INfo operativa 
					SELECT a.num_credito, 0 saldo_actual, 
					CASE WHEN (nvl(nvl(monto_vencido + mto_venc_trasp,0) + nvl(int_tra_no_exig,0) +nvl(mto_venc_int,0),0)) BETWEEN 0.0000001 AND 1 THEN 1 
						 ELSE ROUND (nvl(nvl(monto_vencido + mto_venc_trasp,0) + nvl(int_tra_no_exig,0) +nvl(mto_venc_int,0),0)) end saldo_vencido,  0 saldo_insoluto
					FROM bdicred:sd_maecredcrd a INNER JOIN bdicred:sd_maesdoscrd_vendida b
					ON fecha BETWEEN v_primero_mes AND v_fechaproceso --between mdy('12','01','2013') AND mdy('12','31','2013')
					AND b.empresa = a.empresa AND a.num_credito = b.num_credito  
					WHERE a.empresa = '001'
					AND a.num_Credito NOT IN (SELECT num_credito FROM bdiburo:br_concil_diferencias where fecha_proceso = v_fechaproceso)
					AND NUM_PRODUCTO = '6011'
					order by a.num_credito
					INTO temp creditos_apps WITH NO LOG;
					
					--EXTRAE PRIMER CREDITO A PROCESAR
					SELECT valor  INTO vNumCredAux
					FROM  bdiburo:br_param
					WHERE cod_param = 133;
					
					--Cruce cinta con operación (Hay Crédito en Cinta que no en la App)
					FOREACH WITH HOLD  --Ciclo Cinta con Operación
						SELECT a.num_credito,etiqueta, a.saldo_actual, a.saldo_venc,  a.monto_insoluto,b.saldo_actual,b.saldo_vencido,b.saldo_insoluto
						INTO vnum_cred,vetiqueta,vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app	 
						FROM creditos_apps  b  FULL OUTER JOIN tot_creditos_cintas a
						ON a.num_credito = b.num_credito AND a.num_credito > vNumCredAux 
						WHERE b.NUM_CREDITO IS  NULL

						LET vsaldo_actual_dif = vsaldo_actual_SIC;
						LET vsaldo_venc_dif =vsaldo_venc_SIC;
						LET vmonto_insoluto_dif	=vmonto_insoluto_SIC;

						BEGIN WORK;
							INSERT INTO br_concil_diferencias VALUES (v_fechaproceso,vprod,v_tipocred,vnum_cred,vclave_obs,vstatus_cred,
							vetiqueta,vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app,
							vsaldo_actual_dif,vsaldo_venc_dif,vmonto_insoluto_dif);

							UPDATE bdiburo:br_param SET valor = vnum_cred
							WHERE cod_param = 133;
						COMMIT WORK;
					END  FOREACH --FIN Ciclo Cinta con Operación
					
					BEGIN WORK;
						UPDATE bdiburo:br_param SET valor = ''
						WHERE cod_param = 133;
					COMMIT WORK; 

					SELECT valor INTO vNumCredAux
					FROM  bdiburo:br_param
					WHERE cod_param = 133;
					
					--Cruce operación con cinta (Hay Crédito en App que no en la Cinta)
					FOREACH WITH HOLD --Ciclo Operación con Cinta
						SELECT b.NUM_CREDITO,etiqueta,b.saldo_actual,b.saldo_vencido,b.saldo_insoluto, a.saldo_actual, a.saldo_venc,  a.monto_insoluto
						INTO vnum_cred,vetiqueta ,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app, vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC	 	 
						FROM  tot_creditos_cintas a FULL OUTER JOIN creditos_apps  b
						ON a.num_credito = b.num_credito AND b.NUM_CREDITO > vNumCredAux
						WHERE  A.NUM_CREDITO  IS  NULL
	
						LET vsaldo_actual_dif = vsaldo_actual_app;
						LET vsaldo_venc_dif =vsaldo_venc_app;
						LET vmonto_insoluto_dif	=vmonto_insoluto_app;
           
						BEGIN WORK;
							INSERT INTO br_concil_diferencias VALUES (v_fechaproceso,vprod,v_tipocred,vnum_cred,vclave_obs,vstatus_cred, vetiqueta,
							vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app, 
							vsaldo_actual_dif,vsaldo_venc_dif,vmonto_insoluto_dif);
	
							UPDATE bdiburo:br_param SET valor = vnum_cred
							WHERE cod_param = 133;
						COMMIT WORK;
					END  FOREACH  --FIN Ciclo Operación con Cinta
					
					BEGIN WORK;
						UPDATE bdiburo:br_param SET valor = ''
						WHERE cod_param = 133;
					COMMIT WORK;
         
					DROP TABLE creditos_apps;

				--Reestructuras Cancelada
				ELIF  v_tipocred = 'CA' THEN  --ELIF  Tipo de Crédito / Cancelada
					--extrae INfo operativa
					SELECT a.NUM_CREDITO,  0 saldo_actual, 0 saldo_vencido, 0 saldo_insoluto	
					FROM bdicred:sd_maecredcrd a INNER JOIN bdicred:sd_maecredanexocrd b
					ON b.empresa = a.empresa AND a.num_credito = b.num_credito  
					AND fecha_proceso  BETWEEN v_primero_mes AND v_fechaproceso--between mdy('02','01','2014') AND mdy('02','28','2014')
					WHERE a.empresa = '001'
					AND a.num_Credito NOT IN (SELECT num_credito FROM bdiburo:br_concil_diferencias where fecha_proceso = v_fechaproceso)
					AND num_producto = '6011'
					AND status_cred = 'FF'
				--Suc para pruebas
					--AND substr(sucursal,1,4) in (select sucursal from bdiburo:suc_pro where des_suc = 'REEST') 
					order by a.num_credito
					INTO temp creditos_apps WITH NO LOG;
					
					--EXTRAE PRIMER CREDITO A PROCESAR
					SELECT valor  INTO vNumCredAux
					FROM  bdiburo:br_param
					WHERE cod_param = 133;
					
					--Cruce cinta con operación (Hay Crédito en Cinta que no en la App)
					FOREACH WITH HOLD  --Ciclo Cinta con Operación
						SELECT a.num_credito,etiqueta, a.saldo_actual, a.saldo_venc,  a.monto_insoluto,b.saldo_actual,b.saldo_vencido,b.saldo_insoluto
						INTO vnum_cred,vetiqueta,vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app	 
						FROM creditos_apps  b  FULL OUTER JOIN tot_creditos_cintas a
						ON a.num_credito = b.num_credito AND a.num_credito > vNumCredAux 
						WHERE b.NUM_CREDITO IS  NULL

						LET vsaldo_actual_dif = vsaldo_actual_SIC;
						LET vsaldo_venc_dif =vsaldo_venc_SIC;
						LET vmonto_insoluto_dif	=vmonto_insoluto_SIC;

						BEGIN WORK;
							INSERT INTO br_concil_diferencias VALUES (v_fechaproceso,vprod,v_tipocred,vnum_cred,vclave_obs,vstatus_cred,
							vetiqueta,vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app,
							vsaldo_actual_dif,vsaldo_venc_dif,vmonto_insoluto_dif);

							UPDATE bdiburo:br_param SET valor = vnum_cred
							WHERE cod_param = 133;
						COMMIT WORK;
					END  FOREACH --FIN Ciclo Cinta con Operación
					
					BEGIN WORK;
						UPDATE bdiburo:br_param SET valor = ''
						WHERE cod_param = 133;
					COMMIT WORK; 

					SELECT valor INTO vNumCredAux
					FROM  bdiburo:br_param
					WHERE cod_param = 133;
					
					--Cruce operación con cinta (Hay Crédito en App que no en la Cinta)
					FOREACH WITH HOLD --Ciclo Operación con Cinta
						SELECT b.NUM_CREDITO,etiqueta,b.saldo_actual,b.saldo_vencido,b.saldo_insoluto, a.saldo_actual, a.saldo_venc,  a.monto_insoluto
						INTO vnum_cred,vetiqueta ,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app, vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC	 	 
						FROM  tot_creditos_cintas a FULL OUTER JOIN creditos_apps  b
						ON a.num_credito = b.num_credito AND b.NUM_CREDITO > vNumCredAux
						WHERE  A.NUM_CREDITO  IS  NULL
	
						LET vsaldo_actual_dif = vsaldo_actual_app;
						LET vsaldo_venc_dif =vsaldo_venc_app;
						LET vmonto_insoluto_dif	=vmonto_insoluto_app;
           
						BEGIN WORK;
							INSERT INTO br_concil_diferencias VALUES (v_fechaproceso,vprod,v_tipocred,vnum_cred,vclave_obs,vstatus_cred, vetiqueta,
							vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app, 
							vsaldo_actual_dif,vsaldo_venc_dif,vmonto_insoluto_dif);
	
							UPDATE bdiburo:br_param SET valor = vnum_cred
							WHERE cod_param = 133;
						COMMIT WORK;
					END  FOREACH  --FIN Ciclo Operación con Cinta
					
					BEGIN WORK;
						UPDATE bdiburo:br_param SET valor = ''
						WHERE cod_param = 133;
					COMMIT WORK;
         
					DROP TABLE creditos_apps;
			
				END IF --FIN IF Tipo de Crédito
				
				begin;				
				UPDATE br_concil_consolidado set b_difprocesa ='DP'       
				WHERE fecha_proceso = v_fechaproceso
				and num_producto = vprod
				and status_cred = vstatus_cred
				and clave_obs = vclave_obs;
				commit;
				
				LET v_tipocred= '';
				LET vclave_obs= '';
				LET vstatus_cred = '';
				DROP TABLE tot_creditos_cintas;
				
			END FOREACH --FIN Ciclo producto Reestructuras
		END IF --FIN IF Producto
	END FOREACH --FIN Ciclo productos con diferencias /PRINCIPAL
	UPDATE bdiburo:br_param SET valor = vfecha_reporte  WHERE cod_param = 135;
 	 LET cCodRet     = "000000";
	 LET cMensajeRet = "DETALLE DE CONCILIACIÓN "||vfecha_reporte|| " Ok.";
	END IF; 
	 RETURN cCodRet, cMensajeRet; 
 END;
END  PROCEDURE;