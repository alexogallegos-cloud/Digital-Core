CREATE PROCEDURE "informix".sp_valida_respuesta_bc_ofi(pEmpresa CHAR(3),pNumSol CHAR(20))

RETURNING CHAR(6) AS CodigoRetorno, 	 -- Codigo de Retorno
		  VARCHAR(255) AS DescripcionError;  -- Descripcion del error

--****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ***************************************************************************
DEFINE cCod_ret       CHAR(5);
DEFINE cCodRet        CHAR(6);
DEFINE iSqlerr        INTEGER;
DEFINE iSam_err       SMALLINT;
DEFINE cError_info    CHAR(100);
DEFINE cS_califica    CHAR(1);
DEFINE dS_compromisos DECIMAL(14,2);
DEFINE cStatus	      CHAR(2);
DEFINE cUser          CHAR(10);
DEFINE cStatusSol    CHAR(2);
DEFINE vMensaje      VARCHAR(255);
DEFINE sCuantos      SMALLINT;
DEFINE dMontoUdis    DECIMAL(14,2);
DEFINE cCodUdi       CHAR(2);
DEFINE cCodUs        CHAR(2);
DEFINE cClase        CHAR(1);
DEFINE dTpCambioUdi  DECIMAL(14,6);
DEFINE dTpCambioUs   DECIMAL(14,6);
DEFINE dMaxMtoUdi    DECIMAL(14,2);
DEFINE cTl11         CHAR(1);
DEFINE dTl16         DATE;
DEFINE dTl17         DATE;
DEFINE dtFecha       DATE;
DEFINE cTl26              	CHAR(2);
DEFINE cTl27		      	CHAR(24);
DEFINE cTl30               	CHAR(2);
DEFINE iRespuesta    		INTEGER;
DEFINE cDescripcion_status  CHAR(40);
DEFINE i            		INTEGER;
DEFINE imesescon    		INTEGER;
DEFINE imescuenta   		INTEGER;
DEFINE v_sc01       		VARCHAR(04);
DEFINE cNumcliente		 	CHAR(20);
DEFINE cCausa			 	CHAR(3);
DEFINE sLineaCreditoCAC     INTEGER;
DEFINE cSucursal 			CHAR(4);
DEFINE cPregunta 			CHAR(200);
DEFINE dtFechaIncremento    DATE;
DEFINE cAntecedentesBC      CHAR(1);
DEFINE cAntecedentesCC      CHAR(1);
DEFINE iExcepciones      	INTEGER;
DEFINE cOrigen      		CHAR(1);
DEFINE dLineaSugerida   DECIMAL(18,2);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET cCod_ret      		= "00000";
LET cCodRet       		= "000000";
LET iSqlerr       		= 0;
LET iSam_err			= 0;
LET cError_info	  		= " ";
LET cS_califica    		= "X";
LET dS_compromisos 		= 0;
LET cStatus       		= "";
LET cStatusSol    		= "";
LET vMensaje            = "";
LET sCuantos			= 0;
LET dMontoUdis    		= 0;
LET cCodUdi		  		= "";
LET cCodUs		  		= "";
LET dTpCambioUdi  		= 0;
LET dTpCambioUs  		= 0;
LET dMaxMtoUdi    		= 0;
LET cTl11         		= "";
LET dTl16         		= DATE(1);
LET dTl17		  		= DATE(1);
LET dtFecha        		= DATE(1);
LET cTl26		  		= "";
LET cTl27		  		= "";
LET cTl30				= "";
LET iRespuesta    		= 0;
LET cDescripcion_status = "";
LET i 					= 0;
LET imesescon    		= 0;
LET imescuenta   		= 0;
LET v_sc01       		= "";
LET cClase       		= "";
LET	cNumcliente			= "";
LET	cCausa				= "";
LET cUser               = USER;
LET sLineaCreditoCAC  	= 0;
LET cSucursal  		 	= "";
LET cPregunta  		 	= "";
LET dtFechaIncremento  	= DATE(1);
LET cAntecedentesBC  	= "";
LET cAntecedentesCC  	= "";
LET iExcepciones  		= 0;
LET cOrigen  		= "";
LET dLineaSugerida  	= 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET iSqlerr, iSam_err, cError_info
  LET cCod_ret = iSqlerr;
  RETURN cCod_ret, vMensaje;
END EXCEPTION;

--SET DEBUG FILE TO "/informix/jesus/sp_valida_respuesta_bc_ofi.out";
--TRACE ON;

	LET vMensaje      = "";
	--Consulta principal para obtener el valor de la sucursal donde se origino el credito y el valor que indica si tiene activo los incrementos automaticos.
	SELECT a.numcte,a.status,a.fecha_insert,sucursal,origen,lincred_sugerida
	  INTO cNumcliente,cStatusSol,dtFechaIncremento,cSucursal,cOrigen,dLineaSugerida
	  FROM bdicred:"informix".sd_bitacora_aumlincred a
	 WHERE num_solicitud = pNumSol
	   AND fecha_insert = (SELECT MAX(fecha_insert)
	 					     FROM bdicred:"informix".sd_bitacora_aumlincred c
							WHERE  c.empresa = '001' AND c.num_solicitud = a.num_solicitud
							AND  status ='BC')
		AND status ='BC';
--	    LET cS_califica  = "X";
--	    LET vMensaje = pNumSol || '  valida_respuesta_buró';

	--IF EXISTS (SELECT num_solicitud FROM bdicred:"informix".sd_bitacora_aumlincred WHERE fecha_insert = dtFechaIncremento AND num_solicitud = pNumSol AND empresa = pEmpresa AND status = "RT" AND origen = "S") THEN
    IF cStatusSol = "RT" AND cOrigen = "S" THEN
	   LET cCod_ret='00001';			
	   LET vMensaje='La solicitud se encuentra con estatus rechazado';
	   RETURN cCodRet, vMensaje;
	END IF;

        EXECUTE PROCEDURE bdisolic:"informix".cal_circulocredito_cjunk(pEmpresa,cNumcliente,pNumSol)
                INTO cCodRet, cS_califica, dS_compromisos, cDescripcion_status;

		IF cStatusSol = "BC" AND cS_califica ='1' THEN
			LET cAntecedentesBC = cS_califica;
			LET cAntecedentesCC = "";
            LET cstatus = 'RT';
   			LET cCausa  = "RBC";
		ELIF cStatusSol = "CC"  AND cS_califica ='1'  THEN
			LET cAntecedentesBC = "";
			LET cAntecedentesCC = cS_califica;
            LET cstatus = 'RT';
  			LET cCausa  = "RCC";
  
		ELIF cStatusSol = "BC" AND  cS_califica IN ('X','0') THEN
			LET cAntecedentesBC = cS_califica;
			LET cAntecedentesCC = "";
            LET cstatus = 'AT';
   			LET cCausa  = '';
		ELIF cStatusSol = "CC" AND  cS_califica IN ('X','0') THEN
			LET cAntecedentesBC = "";
			LET cAntecedentesCC = cS_califica;
            LET cstatus = 'AT';
   			LET cCausa  = '';
		END IF;

        SELECT COUNT(excepciones)
        INTO iExcepciones
        FROM bdicred:"informix".sd_sol_excepciones_aumlincred
        WHERE empresa = pEmpresa
        AND  num_solicitud = pNumSol
        --AND fecha_insert BETWEEN CURRENT - 90 UNITS DAY AND CURRENT;
        AND fecha_insert =dtFechaIncremento;

--Determina si la solicitud se va al CAC para análisis o se autoriza
--temporalmente se autorizan todas las solicitudes hasta que se genere la pantalla de determinación de línea del CAC
        IF iExcepciones	> 0 AND cstatus = 'AT' THEN
            LET cstatus     = "AC";
            LET cCausa      = "";
        ELIF cstatus = 'AT' THEN
            LET cstatus     = "AT";
            LET cCausa      = "";
        END IF;

		UPDATE bdicred:"informix".sd_bitacora_aumlincred
		SET califica_buro = cS_califica,
			antecedentes_buro = cAntecedentesBC,
			antecedentes_circulo =cAntecedentesCC,
			pago_minimo   = dS_compromisos,
			status        = cstatus,
			causa_status  = cCausa,
			fecha_status  = today,
			hora_status   = CURRENT
		WHERE empresa = pEmpresa
		AND num_solicitud = pNumSol
		AND status = cStatusSol
		AND fecha_insert = dtFechaIncremento;

		INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac)
		VALUES(pEmpresa, pNumSol, cstatus, cCausa, cUser, today, today, 0);

		--validacion para ver si el cliente cuenta con incrementos automaticos, si es asi se manda llamar al procedimiento sp_registrarrespuestacte para simular la respuesta de autorizacion del cliente.
		IF cstatus= "AT" THEN
			LET cPregunta= "Autorizo expresamente a BanCoppel a incrementar mi linea de crédito a $" ||dLineaSugerida|| ", así mismo, acepto las nuevas condiciones y términos aplicables a partir de esta fecha.";
				
			EXECUTE PROCEDURE bdicred:"informix".sp_registrarrespuestacte(pEmpresa,pNumSol,'1',cPregunta,cSucursal,'sistema') INTO cCod_ret, vMensaje;

			IF cCod_ret <> "00000" THEN
				LET cCod_ret = "00001";
				LET vMensaje = "Error al realizar incremento automático de línea para el crédito  " || pNumSol;
			ELSE
				LET vMensaje     = "Se realizó la consulta correctamente";
			END IF;
		ELSE
			LET vMensaje     = "Se realizó la consulta correctamente";
		END IF;
RETURN cCodRet, vMensaje;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento espejo para sucursal que se encagará de validar la respuesta de buro de credito y se le agrega retorno en donde se obtiene la sucursal donde se origino el credito ',
'MODIFICÓ: ARMANDO MORALES',
'FECHA: JUNIO 2012',
'VERSION: 20120615.0910',
'BD: BDIBURO';

CREATE PROCEDURE "informix".sp_geninfo_conciliacinta_cnr()
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
DEFINE vflag                 CHAR(1);

LET cCodRet 				= "000000";
LET  iSqlErr              	= 0;
LET iIsamErr             	= 0;
LET cErrorINfo           	= "";
LET vNumCredAux				= '';
LET vnum_cred				= '';

LET vprod= '';
--LET v_valfecha           = 0;
--LET v_valcinta           = 0;

 BEGIN
	 ON EXCEPTION SET  iSqlErr, iIsamErr , cErrorINfo
     LET cCodRet=  iSqlErr;
     LET cMensajeRet= cErrorINfo;  
     RETURN cCodRet, cMensajeRet;
     END  EXCEPTION;

    -- SET DEBUG FILE TO "sp_geninfo_conciliacinta_cnr.out";
    -- TRACE ON; 

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

	SELECT valor INTO val_info_reporte FROM bdiburo:br_param WHERE cod_param = 136;
	
	IF val_info_reporte = vfecha_reporte THEN
	 	LET cCodRet     = "007777";
		LET cMensajeRet = "DETALLE DE CONCILIACIÓN CNR"||vfecha_reporte|| " YA PROCESADO.";
	ELSE 
	
		FOREACH WITH HOLD  --Ciclo productos con diferencias /PRINCIPAL
				SELECT num_producto  
				INTO vprod 
				FROM bdiburo:br_fechas_concil
				WHERE fecha_proceso = v_fechaproceso
				AND num_producto IN ('6300','6400')
				AND diferencia = 'D'

				--DETALLE DE diferencias CREDS A PLAZO
				FOREACH WITH HOLD --Ciclo producto CREDS A PLAZO
					--Extrae tipo de credito, clave observaciON y status credito que tengan diferencia.
					SELECT tipo_cred, clave_obs,status_cred
					INTO v_tipocred,vclave_obs,vstatus_cred
					FROM bdiburo:br_concil_consolidado_cnr
					WHERE fecha_proceso = v_fechaproceso
					AND num_producto = vprod 
					AND ( b_difprocesa = 'D' and (sdo_actual_dif > 0 OR sdo_vencido_dif > 0 OR sdo_insoluto_dif > 0 OR cred_diferencia  > 0)) 
					ORDER BY 1,2
					
					--Genera el universo de las SIC de ese tipo de credito a procesar.
					SELECT num_credito, status_cred, 'EN' ETIQUETA,NVL(saldo_actual,0) saldo_actual,  
							NVL(saldo_venc,0) saldo_venc,  NVL(monto_insoluto,0)  monto_insoluto
					FROM bdiburo:br_burofisicas_describe_cnr 
					WHERE fecha_reporte = vfecha_reporte
					AND num_producto = vprod 
					AND clave_obs = vclave_obs
					AND status_Cred= vstatus_cred
					AND num_credito NOT IN (SELECT num_credito FROM bdiburo:br_concil_diferencias_cnr WHERE fecha_proceso = v_fechaproceso)
					UNION ALL
					SELECT num_credito, status_cred, 'EX' ETIQUETA,NVL(saldo_actual,0) saldo_actual,  
							NVL(saldo_venc,0) saldo_venc,  NVL(monto_insoluto,0)  monto_insoluto
					FROM bdiburo:br_burofisicas_concilia_cnr 
					WHERE fecha_cinta = v_fechaproceso
					AND clave_obs = vclave_obs
					AND status_Cred= vstatus_cred
					AND motivo = 'CSS'
					AND num_credito NOT IN (SELECT num_credito FROM bdiburo:br_concil_diferencias_cnr where fecha_proceso = v_fechaproceso)
                    AND num_producto = vprod 
					INTO temp tot_creditos_cintas_cnr WITH NO LOG;

					--Extrae INformación Operativa de las diferencias por tipo de credito
					--Créditos a Plazo Activos
					IF v_tipocred = 'AC' THEN --IF Tipo de Crédito / Activo
						SELECT a.num_credito, a.status_cred, nvl(dias_atraso,0) vdiasatraso
						FROM bdicred:sd_maecredcontcrd a INNER JOIN bdicred:sd_indicador_cred_crd b
						ON a.empresa = b.empresa and a.num_credito = b.num_credito
						WHERE a.fecha =   v_fechaproceso
						AND a.empresa = '001'
						AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_concil_diferencias_cnr where fecha_proceso =  v_fechaproceso)
						AND a.num_producto = vprod
					--Suc para pruebas
							--AND (sucursal in (SELECT sucursal from bdiburo:suc_pro where des_suc = 'CNR'))-- OR a.num_credito  in (SELECT num_credito from creditos_err))
						INTO temp cred_act_op1_cnr WITH NO LOG; 

						SELECT a.*,b.status_cred  vstatus_credAnt,
						CASE WHEN (vdiasatraso >=  1 ) THEN 'PC'
							 WHEN b.status_cred IN ('BT','BA') AND a.status_cred ='AA' THEN 'EL'
							 ELSE '' END clave_obs
						FROM cred_act_op1_cnr a LEFT JOIN  bdicred:sd_maecredcontcrd b
						ON empresa = '001' AND a.num_credito = b.num_credito  AND b.fecha = v_fechaproceso_ant
						INTO temp cred_act_op_cnr  WITH NO LOG; 

						DROP TABLE cred_act_op1_cnr;
					
						SELECT b.num_credito,
						CASE WHEN ((NVL(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci,0))+ 
							CASE WHEN NVL(sdo_no_exig,0) IS NULL THEN 0
								WHEN NVL(sdo_no_exig,0) <= 0 THEN 0 
								ELSE NVL(sdo_no_exig,0) END) >0 AND (NVL(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci,0)+ 
								CASE WHEN NVL(sdo_no_exig,0) IS NULL THEN 0
									WHEN NVL(sdo_no_exig,0) <= 0 THEN 0 
									ELSE NVL(sdo_no_exig,0) END) <1 THEN 1
								ELSE round ((NVL(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci,0))+ 
								CASE WHEN NVL(sdo_no_exig,0) IS NULL THEN 0
									WHEN NVL(sdo_no_exig,0) <= 0 THEN 0 
									ELSE NVL(sdo_no_exig,0) END)END saldo_actual,
						CASE WHEN (NVL(monto_vencido + mto_venc_trasp,0)) >0 AND (NVL(monto_vencido + mto_venc_trasp,0)) <1 THEN 1
							ELSE round (NVL(monto_vencido + mto_venc_trasp,0))END saldo_vencido,
						CASE WHEN (NVL(sdo_cap_insoluto,0)) >0 AND (NVL(sdo_cap_insoluto,0)) <1 THEN 1
							ELSE round (NVL(sdo_cap_insoluto,0))END saldo_insoluto
						FROM bdicred:sd_maesdoscontcrd a INNER JOIN cred_act_op_cnr  b
						ON a.num_credito = b.num_credito
						WHERE a.fecha = v_fechaproceso 
						AND a.num_credito >= ''
						order by b.num_credito
						INTO temp creditos_apps_cnr WITH NO LOG;

						DROP TABLE cred_act_op_cnr;
										
						--EXTRAE PRIMER CREDITO A PROCESAR
						SELECT valor  INTO vNumCredAux
						FROM  bdiburo:br_param
						WHERE cod_param = 134;
					
						--Cruce cinta con operación (Hay Crédito en Cinta que no en la App)
						FOREACH WITH HOLD  --Ciclo Cinta con Operación
							SELECT a.num_credito,etiqueta, a.saldo_actual, a.saldo_venc,  a.monto_insoluto,b.saldo_actual,b.saldo_vencido,b.saldo_insoluto
							INTO vnum_cred,vetiqueta,vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app	 
							FROM creditos_apps_cnr  b  FULL OUTER JOIN tot_creditos_cintas_cnr a
							ON a.num_credito = b.num_credito AND a.num_credito > vNumCredAux 
							WHERE b.NUM_CREDITO IS  NULL

							LET vsaldo_actual_dif = vsaldo_actual_SIC;
							LET vsaldo_venc_dif =vsaldo_venc_SIC;
							LET vmonto_insoluto_dif	=vmonto_insoluto_SIC;
	
							BEGIN WORK;
								INSERT INTO br_concil_diferencias_cnr VALUES (v_fechaproceso,vprod,v_tipocred,vnum_cred,vclave_obs,vstatus_cred,
								vetiqueta,vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app,
								vsaldo_actual_dif,vsaldo_venc_dif,vmonto_insoluto_dif);

								UPDATE bdiburo:br_param SET valor = vnum_cred
								WHERE cod_param = 134;
							COMMIT WORK;
						END  FOREACH --FIN Ciclo Cinta con Operación
					
					BEGIN WORK;
						UPDATE bdiburo:br_param SET valor = ''
						WHERE cod_param = 134;
					COMMIT WORK; 

					SELECT valor INTO vNumCredAux
					FROM  bdiburo:br_param
					WHERE cod_param = 134;
					
					--Cruce operación con cinta (Hay Crédito en App que no en la Cinta)
					FOREACH WITH HOLD --Ciclo Operación con Cinta
						SELECT b.NUM_CREDITO,etiqueta,b.saldo_actual,b.saldo_vencido,b.saldo_insoluto, a.saldo_actual, a.saldo_venc,  a.monto_insoluto
						INTO vnum_cred,vetiqueta ,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app, vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC	 	 
						FROM  tot_creditos_cintas_cnr a FULL OUTER JOIN creditos_apps_cnr  b
						ON a.num_credito = b.num_credito AND b.NUM_CREDITO > vNumCredAux
						WHERE  A.NUM_CREDITO  IS  NULL 
	
						LET vsaldo_actual_dif = vsaldo_actual_app;
						LET vsaldo_venc_dif =vsaldo_venc_app;
						LET vmonto_insoluto_dif	=vmonto_insoluto_app;
           
						BEGIN WORK;
							INSERT INTO br_concil_diferencias_cnr VALUES (v_fechaproceso,vprod,v_tipocred,vnum_cred,vclave_obs,vstatus_cred, vetiqueta,
							vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app, 
							vsaldo_actual_dif,vsaldo_venc_dif,vmonto_insoluto_dif);
	
							UPDATE bdiburo:br_param SET valor = vnum_cred
							WHERE cod_param = 134;
						COMMIT WORK;
					END  FOREACH  --FIN Ciclo Operación con Cinta
					
					BEGIN WORK;
						UPDATE bdiburo:br_param SET valor = ''
						WHERE cod_param = 134;
					COMMIT WORK;
         
					DROP TABLE creditos_apps_cnr;
					--Créditos a Plazo Cancelados
					ELIF  v_tipocred = 'CA' THEN  --ELIF  Tipo de Crédito / Cancelada
						--extrae INfo operativa
						SELECT a.num_credito, 0 saldo_actual, 0 saldo_vencido, 0 saldo_insoluto	
						FROM bdicred:sd_maecredcrd a INNER JOIN bdicred:sd_maecredanexocrd b
						ON b.empresa = '001' AND a.num_credito = b.num_credito  AND fecha_proceso BETWEEN v_primero_mes AND v_fechaproceso
						WHERE a.empresa = '001'
						AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_concil_diferencias_cnr where fecha_proceso = v_fechaproceso)
						AND num_producto = vprod 
						AND status_cred = 'FF'
					--Suc para pruebas
							--AND (sucursal IN (SELECT sucursal FROM bdiburo:suc_pro WHERE des_suc = 'CNR'))-- OR a.num_credito  in (SELECT num_credito FROM creditos_err))
						order by a.num_credito	
						INTO temp creditos_apps_cnr WITH NO LOG;
					
						--EXTRAE PRIMER CREDITO A PROCESAR
						SELECT valor  INTO vNumCredAux
						FROM  bdiburo:br_param
						WHERE cod_param = 134;
					
						--Cruce cinta con operación (Hay Crédito en Cinta que no en la App)
						FOREACH WITH HOLD  --Ciclo Cinta con Operación
							SELECT a.num_credito,etiqueta, a.saldo_actual, a.saldo_venc,  a.monto_insoluto,b.saldo_actual,b.saldo_vencido,b.saldo_insoluto
							INTO vnum_cred,vetiqueta,vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app	 
							FROM creditos_apps_cnr  b  FULL OUTER JOIN tot_creditos_cintas_cnr a
							ON a.num_credito = b.num_credito AND a.num_credito > vNumCredAux
							WHERE b.NUM_CREDITO IS  NULL

							LET vsaldo_actual_dif = vsaldo_actual_SIC;
							LET vsaldo_venc_dif =vsaldo_venc_SIC;
							LET vmonto_insoluto_dif	=vmonto_insoluto_SIC;

							BEGIN WORK;
								INSERT INTO br_concil_diferencias_cnr VALUES (v_fechaproceso,vprod,v_tipocred,vnum_cred,vclave_obs,vstatus_cred,
								vetiqueta,vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app,
								vsaldo_actual_dif,vsaldo_venc_dif,vmonto_insoluto_dif);

								UPDATE bdiburo:br_param SET valor = vnum_cred
								WHERE cod_param = 134;
							COMMIT WORK;
						END  FOREACH --FIN Ciclo Cinta con Operación
					
						BEGIN WORK;
							UPDATE bdiburo:br_param SET valor = ''
							WHERE cod_param = 134;
						COMMIT WORK; 

						SELECT valor INTO vNumCredAux
						FROM  bdiburo:br_param
						WHERE cod_param = 134;
					
						--Cruce operación con cinta (Hay Crédito en App que no en la Cinta)
						FOREACH WITH HOLD --Ciclo Operación con Cinta
							SELECT b.NUM_CREDITO,etiqueta,b.saldo_actual,b.saldo_vencido,b.saldo_insoluto, a.saldo_actual, a.saldo_venc,  a.monto_insoluto
							INTO vnum_cred,vetiqueta ,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app, vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC	 	 
							FROM  tot_creditos_cintas_cnr a FULL OUTER JOIN creditos_apps_cnr  b
							ON a.num_credito = b.num_credito AND b.NUM_CREDITO > vNumCredAux
							WHERE  A.NUM_CREDITO  IS  NULL 
	
							LET vsaldo_actual_dif = vsaldo_actual_app;
							LET vsaldo_venc_dif =vsaldo_venc_app;
							LET vmonto_insoluto_dif	=vmonto_insoluto_app;
           
							BEGIN WORK;
								INSERT INTO br_concil_diferencias_cnr VALUES (v_fechaproceso,vprod,v_tipocred,vnum_cred,vclave_obs,vstatus_cred, vetiqueta,
								vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app, 
								vsaldo_actual_dif,vsaldo_venc_dif,vmonto_insoluto_dif);

								UPDATE bdiburo:br_param SET valor = vnum_cred
								WHERE cod_param = 134;
							COMMIT WORK;
						END FOREACH  --FIN Ciclo Operación con Cinta
					
						BEGIN WORK;
							UPDATE bdiburo:br_param SET valor = ''
							WHERE cod_param = 134;
						COMMIT WORK;
         
						DROP TABLE creditos_apps_cnr;	
					--Créditos a Plazo Vendidos
					ELIF  v_tipocred = 'VE' THEN  --ELIF  Créditos a Plazo  Vendidos
						--extrae INfo operativa 
						SELECT  a.num_credito , 0 saldo_actual, 
						CASE WHEN (NVL(((monto_vencido + mto_venc_trasp) + ((sdo_contab_mora + sdo_moratorio)*1.16)) + 
									(SELECT SUM((interes_debe - interes_pagado) + (iva_debe - iva_pagado)) 
									FROM bdicred:sd_amortiza_creditocrd_vendida 
									WHERE a.empresa = empresa AND a.num_credito = num_credito AND capital_status IN ('2','7')),0))  
									BETWEEN 0.0000001 AND 1 THEN 1 
							ELSE ROUND(NVL(((monto_vencido + mto_venc_trasp) + ((sdo_contab_mora + sdo_moratorio)*1.16)) + 
									(SELECT SUM((interes_debe - interes_pagado) + (iva_debe - iva_pagado)) FROM bdicred:sd_amortiza_creditocrd_vendida 
									WHERE a.empresa = empresa AND a.num_credito = num_credito AND capital_status IN ('2','7')),0)) 
							END saldo_vencido, 0 saldo_insoluto
						FROM bdicred:sd_maecredcrd a inner join bdicred:sd_maesdoscrd_vendida b
						ON fecha BETWEEN v_primero_mes AND v_fechaproceso AND a.empresa = b.empresa AND a.num_credito = b.num_credito
						WHERE a.empresa = '001'
						AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_concil_diferencias_cnr where fecha_proceso = v_fechaproceso)
					--Suc para pruebas
							--AND (sucursal IN (SELECT sucursal FROM bdiburo:suc_pro WHERE des_suc = 'CNR'))-- or a.num_credito  IN (SELECT num_credito FROM creditos_err))
						AND num_producto  = vprod 
						INTO temp creditos_apps_cnr WITH NO LOG;
					
						--EXTRAE PRIMER CREDITO A PROCESAR
						SELECT valor  INTO vNumCredAux
						FROM  bdiburo:br_param
						WHERE cod_param = 134;
					
						--Cruce cinta con operación (Hay Crédito en Cinta que no en la App)
						FOREACH WITH HOLD  --Ciclo Cinta con Operación
							SELECT a.num_credito,etiqueta, a.saldo_actual, a.saldo_venc,  a.monto_insoluto,b.saldo_actual,b.saldo_vencido,b.saldo_insoluto
							INTO vnum_cred,vetiqueta,vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app	 
							FROM creditos_apps_cnr  b  FULL OUTER JOIN tot_creditos_cintas_cnr a
							ON a.num_credito = b.num_credito AND a.num_credito > vNumCredAux
							WHERE b.NUM_CREDITO IS  NULL

							LET vsaldo_actual_dif = vsaldo_actual_SIC;
							LET vsaldo_venc_dif =vsaldo_venc_SIC;
							LET vmonto_insoluto_dif	=vmonto_insoluto_SIC;

							BEGIN WORK;
								INSERT INTO br_concil_diferencias_cnr VALUES (v_fechaproceso,vprod,v_tipocred,vnum_cred,vclave_obs,vstatus_cred,
								vetiqueta,vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app,
								vsaldo_actual_dif,vsaldo_venc_dif,vmonto_insoluto_dif);

								UPDATE bdiburo:br_param SET valor = vnum_cred
								WHERE cod_param = 134;
							COMMIT WORK;
						END  FOREACH --FIN Ciclo Cinta con Operación
					
						BEGIN WORK;
							UPDATE bdiburo:br_param SET valor = ''
							WHERE cod_param = 134;
						COMMIT WORK; 

						SELECT valor INTO vNumCredAux
						FROM  bdiburo:br_param
						WHERE cod_param = 134;
					
						--Cruce operación con cinta (Hay Crédito en App que no en la Cinta)
						FOREACH WITH HOLD --Ciclo Operación con Cinta
							SELECT b.NUM_CREDITO,etiqueta,b.saldo_actual,b.saldo_vencido,b.saldo_insoluto, a.saldo_actual, a.saldo_venc,  a.monto_insoluto
							INTO vnum_cred,vetiqueta ,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app, vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC	 	 
							FROM  tot_creditos_cintas_cnr a FULL OUTER JOIN creditos_apps_cnr  b
							ON a.num_credito = b.num_credito AND b.NUM_CREDITO > vNumCredAux
							WHERE  A.NUM_CREDITO  IS  NULL 
	
							LET vsaldo_actual_dif = vsaldo_actual_app;
							LET vsaldo_venc_dif =vsaldo_venc_app;
							LET vmonto_insoluto_dif	=vmonto_insoluto_app;
           
							BEGIN WORK;
								INSERT INTO br_concil_diferencias_cnr VALUES (v_fechaproceso,vprod,v_tipocred,vnum_cred,vclave_obs,vstatus_cred, vetiqueta,
								vsaldo_actual_SIC,vsaldo_venc_SIC,vmonto_insoluto_SIC,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app, 
								vsaldo_actual_dif,vsaldo_venc_dif,vmonto_insoluto_dif);
	
								UPDATE bdiburo:br_param SET valor = vnum_cred
								WHERE cod_param = 134;
							COMMIT WORK;
						END  FOREACH  --FIN Ciclo Operación con Cinta
					
						BEGIN WORK;
							UPDATE bdiburo:br_param SET valor = ''
							WHERE cod_param = 134;
						COMMIT WORK;
         
						DROP TABLE creditos_apps_cnr;							
					END IF --FIN IF Tipo de Crédito
				begin;				
				UPDATE br_concil_consolidado_cnr set b_difprocesa ='DP'       
				WHERE fecha_proceso = v_fechaproceso
				and num_producto = vprod
				and status_cred = vstatus_cred
				and clave_obs = vclave_obs;
				commit;
				LET v_tipocred= '';
				LET vclave_obs= '';
				LET vstatus_cred = '';
				DROP TABLE tot_creditos_cintas_cnr;
				END FOREACH --FIN Ciclo producto CREDS A PLAZO
			END FOREACH --FIN Ciclo productos con diferencias /PRINCIPAL
		UPDATE bdiburo:br_param SET valor = vfecha_reporte  WHERE cod_param = 136;
		LET cCodRet     = "000000";
		LET cMensajeRet = "DETALLE DE CONCILIACIÓN CNR "||vfecha_reporte|| " Ok.";
		END IF; 
	RETURN cCodRet, cMensajeRet; 
 END;
END  PROCEDURE;