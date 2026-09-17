CREATE PROCEDURE "informix".sp_marcagraba_tdc_oro_web(pempresa CHAR(3),TipoEjec CHAR(1), NvaLinea DECIMAL(18,2),pnumsolcred CHAR(20))
RETURNING CHAR(6)         AS codigo_retorno,
		  DECIMAL(18,2)	  AS NvaLinea,
		  CHAR(20)        AS pnumsolcred;
		  
DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   VARCHAR(100,1);
DEFINE cEmpresa      CHAR(3);
DEFINE cNumProducto  CHAR(4);
DEFINE cNomProducto  VARCHAR(100,1);
DEFINE vingresomensual DECIMAL(18,2);
DEFINE vgrupo 		 CHAR(1);
DEFINE v_tpsol		 CHAR(1);
--DEFINE vCte			 CHAR(20);
DEFINE VNuevoStatus  CHAR(2);
DEFINE v_respsic     CHAR(1);
DEFINE scod_ret		 CHAR(5);
DEFINE v_valor		 MONEY(14,2);
DEFINE v_capacidad_pago MONEY(14,2);
DEFINE iPlazo 		INTEGER;
DEFINE v_valor_1s   DECIMAL(14,2);
DEFINE v_valor_2s   DECIMAL(14,2);
DEFINE cLineaTeorica DECIMAL(18,2);

DEFINE cSolOro   CHAR(20);
DEFINE vCompromisos DECIMAL(14,2);
DEFINE vMensaje     VARCHAR(255);
DEFINE cNumSolClass   CHAR(20);
DEFINE cNumcte   CHAR(20);
--RQM10679-2
DEFINE  v_Linea_min_oro DECIMAL(18,2);
DEFINE  v_ingreso_min_oro DECIMAL(18,2);
DEFINE v_ingreso                MONEY(14,2);
DEFINE v_flujo_libre1      DECIMAL(14,2);
DEFINE v_flujo_libre2      DECIMAL(14,2);
DEFINE iexiste 		INTEGER;
DEFINE cmtoingresomc 	DECIMAL(18,2);
DEFINE csucursal CHAR(4); 
DEFINE dbscore DECIMAL(5,2); --INC27201
DEFINE iAuxSucMotor INTEGER;

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '000000';
LET cMensajeRet   = 'Se realizÃ³ la consulta correctamente.';
LET scod_ret	  = '00000';

LET cEmpresa      = '';
LET cNumProducto  = '';
LET cNomProducto  = '';
LET vingresomensual = 0.0;
LET vgrupo 		  = '';
LET v_tpsol		  = '';
--LET vCte		  = '';
LET VNuevoStatus  = '';
LET v_respsic     = '';
LET v_valor		  = 0;
LET v_capacidad_pago = 0;
LET iPlazo 		  = 0;
LET v_valor_1s    = 0;
LET v_valor_2s    = 0;
LET cSolOro    = '';
LET vCompromisos  = 0.0; 
LET vMensaje      = '';
LET cNumSolClass    = '';
LET cNumcte    = '';
LET cLineaTeorica = '';
--RQM10679-2
LET v_Linea_min_oro 	=0.0;
LET v_ingreso_min_oro 	=0.0;
LET v_ingreso       		=0.0;
LET v_flujo_libre1  		=0.0;
LET v_flujo_libre2    		=0.0;
LET iexiste 		= 0;
LET cmtoingresomc       = 0.0;
LET csucursal = '';
LET dbscore =0.0; --INC27201
LET iAuxSucMotor = 0;

BEGIN 

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, NVL(NvaLinea,''), NVL(pnumsolcred,'');

    END IF;
END EXCEPTION;

-- SET DEBUG FILE TO '/ifxsif01/ciaguilar/Monto_Cero_2024/TRACE/sp_marcagraba_tdc_oro.out';
-- TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
INTO cEmpresa     
FROM bdinteg:si_empresas 
WHERE empresa= pempresa;

IF TRIM(NVL(cEmpresa,'')) = '' THEN
  LET cCodRet = '000001';
  RETURN cCodRet, NVL(NvaLinea,''), NVL(pnumsolcred,'');
END IF;

IF  TRIM(NVL(NvaLinea,'')) = ''  AND TRIM(NVL(TipoEjec,'')) = '1'THEN
  LET cCodRet = '000002';
  RETURN cCodRet, NVL(NvaLinea,''), NVL(pnumsolcred,'');
END IF;
IF  TRIM(NVL(TipoEjec,'')) = '' THEN
  LET cCodRet = '000003';
  RETURN cCodRet, NVL(NvaLinea,''), NVL(pnumsolcred,'');
END IF;

IF TRIM(NVL(TipoEjec,'')) = '1' THEN

	  SELECT a.tipo_solicitud, a.numcte, b.ingreso_mensual, b.grupo, b.evalua_cc, '8100', b.monto_reportado_mc, a.sucursal, b.bs_score
      INTO v_tpsol,cNumcte,vingresomensual,vgrupo,v_respsic, cNumProducto, cmtoingresomc, csucursal, dbscore
      FROM "informix".ss_solicitudes a, "informix".ss_revision_determinacion b
     WHERE a.empresa = pempresa       
       AND a.num_solicitud= pnumsolcred
       AND b.empresa= a.empresa
       AND b.num_solicitud = a.num_solicitud;  
	   
	   IF cmtoingresomc > 0 THEN  
			LET vingresomensual = cmtoingresomc; 
	   END IF;

	   --Obtener la lÃ­nea minima para una TDC Oro RQM 10 679-2
	  SELECT monto_min_cred
      INTO v_Linea_min_oro
      FROM bdicred:"informix".sd_definicion
     WHERE empresa = pempresa       
       AND num_producto= cNumProducto;	 
	   
	 --Obtener parametro de ingreso minimo de cliente para TDC Oro
	  SELECT valor
      INTO v_ingreso_min_oro
      FROM bdicred:"informix".sd_param
     WHERE empresa = pempresa  
	 AND cod_param ='096';	 
	 
	--INC 27 194 Se excluyen solicitudes de origen canal 4 Auto Solicitudes para la oferta de oro Suc 8503
	IF csucursal <> '8503' THEN
		--Validar si la lÃ­nea del cliente es mayor o igual a 15000
		IF NvaLinea >=v_Linea_min_oro THEN 	
			--Validar si el ingreso es mayor o igual a 15000
			
			IF EXISTS (SELECT * FROM bdisolic:"informix".ss_enviossolicitudesmotor WHERE num_solicitud = pNumsolcred) THEN  --BRM ACP
				
				SELECT count(numero_solicitud) INTO iexiste FROM "informix".ss_solicitudes_tdcoro where numero_solicitud=pNumsolcred; 
					IF iexiste = 0 THEN
						INSERT INTO bdisolic:"informix".ss_solicitudes_tdcoro(empresa, numero_solicitud,numcte ,numero_solicitud_oro, confirma_oro , flag_oro, nombre_embosado, ingreso_lc, valor_cma,	valor_tab, linea_teorica, user_insert, fecha_insert)
						  VALUES(pempresa, pNumsolcred,cNumcte, '', '',1, '', 0, 0, 0, 0, USER, CURRENT);
					ELSE
						UPDATE bdisolic:"informix".ss_solicitudes_tdcoro SET flag_oro = 1 WHERE numero_solicitud=pNumsolcred;
					END IF;
			
			ELIF vingresomensual >= v_ingreso_min_oro THEN
					
				--Se valida que pase score coppel y Score Propietario.
				SELECT evaluacion
				  INTO v_valor_1s
				FROM "informix".ss_resumen_scoring	
				where num_solicitud=pNumsolcred
				AND seccion=6;
				
				SELECT evaluacion
				  INTO v_valor_2s
				FROM "informix".ss_resumen_scoring	
				where num_solicitud=pNumsolcred
				AND seccion=2;			
			-- INC 27 201 Se agrega consideracion para cuando la respuesta de bcscore sea negativa se toma como Hit sin InformaciÃ³n, se agrega con evalua X para tomarlo como Hit sin informacion solo esta ocasiÃ³n ya que asÃ­ esta parametrizado en Oro por que este producto no tiene No Hit
				--evalua_cc  Parametrizacion correcta de Buro
				--X-- No hit
				--0 , bcscore > a 0 -- Hit con buenos antecedentes
				--0 , bcscore < a 0 -- Hit sin informaciÃ³n
				-- > 0  -- Hit con malos antecedentes
				IF dbscore <= 0 THEN 
					LET v_respsic='X';
				END IF;				
				/*Se cambia la validaciÃ³n de score por parametrico de score coppel -> 4*/
				SELECT UNIQUE status_sol 
				  INTO VNuevoStatus
				  FROM "informix".ss_scoring_modelo2
				 WHERE tp_solicitud  = v_tpsol
				   AND respuesta_sic = DECODE(v_respsic,"X","X","0","0","2","1","3","1","4","1","1")
				   AND grupo = vgrupo            
				   AND v_valor_1s BETWEEN bc_scoremin AND bc_scoremax
				   AND v_valor_2s BETWEEN pro_scormin AND pro_scormax
				   AND tp_parametrico = 4 	
				   AND num_producto =cNumProducto;
			   
				 IF VNuevoStatus IS NULL OR VNuevoStatus = '' THEN
					LET VNuevoStatus = 'RT';
				 END IF;  
						   
				IF VNuevoStatus = 'AT' THEN
					--Se registran datos de determinaciÃ³n para el producto TDCOro
					SELECT count(numero_solicitud) INTO iexiste FROM "informix".ss_solicitudes_tdcoro where numero_solicitud=pNumsolcred; 
					IF iexiste = 0 THEN
						INSERT INTO bdisolic:"informix".ss_solicitudes_tdcoro(empresa, numero_solicitud,numcte ,numero_solicitud_oro, confirma_oro , flag_oro, nombre_embosado, ingreso_lc, valor_cma,	valor_tab, linea_teorica, user_insert, fecha_insert)
						  VALUES(pempresa, pNumsolcred,cNumcte, '', '',1, '', 0, 0, 0, 0, USER, CURRENT);
					ELSE
						UPDATE  bdisolic:"informix".ss_solicitudes_tdcoro SET flag_oro=1 WHERE numero_solicitud=pNumsolcred;
					END IF;		
					
					EXECUTE PROCEDURE bdisolic:"informix".determina_lincred_tc_cjunk(pempresa, pnumsolcred,'')
					INTO scod_ret, v_valor,v_capacidad_pago,iPlazo;
				ELSE
					--Se apaga el flag de oro por que ya no se cumple con las politicas de crÃ©dito de puntajes
					SELECT count(numero_solicitud) INTO iexiste FROM "informix".ss_solicitudes_tdcoro where numero_solicitud=pNumsolcred; 
					IF iexiste = 1 THEN
						UPDATE  bdisolic:"informix".ss_solicitudes_tdcoro SET flag_oro=0 WHERE numero_solicitud=pNumsolcred;
					END IF;						
				END IF;
			ELSE 
				--Se apaga el flag de oro por que ya no se cumple con el ingreso minimo valido para Oro
				SELECT count(numero_solicitud) INTO iexiste FROM "informix".ss_solicitudes_tdcoro where numero_solicitud=pNumsolcred; 		
				IF iexiste = 1 THEN
					UPDATE  bdisolic:"informix".ss_solicitudes_tdcoro SET flag_oro=0 WHERE numero_solicitud=pNumsolcred;
				END IF;		
			END IF;
		ELSE
			--Se apaga el flag de oro por que ya no se cumple con la lÃ­nea minima de producto para Oro
			SELECT count(numero_solicitud) INTO iexiste FROM "informix".ss_solicitudes_tdcoro where numero_solicitud=pNumsolcred; 		
			IF iexiste = 1 THEN
				UPDATE  bdisolic:"informix".ss_solicitudes_tdcoro SET flag_oro=0 WHERE numero_solicitud=pNumsolcred;
			END IF;	
		END IF;
	END IF;
	RETURN cCodRet, v_valor, '';
	
ELIF TRIM(NVL(TipoEjec,'')) = '2' THEN
		
	SELECT numero_solicitud_oro,numcte,linea_teorica, ingreso_lc, valor_cma, valor_tab
		INTO cSolOro,cNumcte,cLineaTeorica,	v_ingreso,  v_flujo_libre1,  v_flujo_libre2
	FROM "informix".ss_solicitudes_tdcoro	
	WHERE empresa = pempresa
	AND numero_solicitud = pnumsolcred;
	
	IF NVL(cSolOro,'') = '' THEN 	
		CALL bdisolic:"informix".asigna_numsol('001','8100')
		RETURNING scod_ret, cSolOro;

		IF scod_ret <> "000" THEN
		  RETURN '0001', NVL(0,''), NVL(cSolOro,'');
		END IF
		
		-- *************************************
		-- Graba Solicitud como Pre-Calificada *
		-- *************************************
		IF LENGTH(cSolOro) = 12 and bdinteg:"informix".val_num(cSolOro) then  --- se valida que el nÃºmero de solicitud sea de 12 y todos sean numericos.
			UPDATE bdisolic:"informix".ss_solicitudes_tdcoro
			SET numero_solicitud_oro = cSolOro, confirma_oro=1
			WHERE empresa = pempresa
			AND numero_solicitud = pnumsolcred;
		ELSE
			RETURN '0001', NVL(0,''), NVL(cSolOro,'');		
		END IF
		
		
    END IF;

	 --clonado de la solicitud
	--RQM 10 679-2 Se agrega migraciÃ³n de tabla ss_nuevo parametrico.
	INSERT INTO bdisolic:"informix".ss_nuevo_parametrico(empresa, num_solicitud, status_solicitud, situacion_especial, causa_sitesp, puntos_parcn, par_altoriesgo, par_celulares, par_prestamos, ingreso_mensual, cap_sistematica_abono, tope_abonocoppel, capmaxima_abono, capreal_abono, lineacredito_real, lineacreditotope, fechalineacreditoreal, fechalineacreditotope, compromisossic, flaglineacreditoesp, cod_ret, limitecredito, limitecreditopesos, paraaltoriesgonvo, campo_1, campo_2, campo_3, clienteprospecto, id_situaciones, puntualidad_ref1, puntualidad_ref2, flagtestigoparametricocn, flag_altadirecta_asupervisar, puntos_var_param, puntos_var_sic, score_domicilio, nuevo_puntajefinal, campo_4, prepuntajealtoriesgo, flag_pagoini, porc_pagoini, monto_disp_pagoini, flag_prestamo, canal_origensol, grupo_eval, grupo_hit, flagtipomsgmotos, montodispmotos, porcpimotos)
	select empresa, cSolOro, status_solicitud, situacion_especial, causa_sitesp, puntos_parcn, par_altoriesgo, par_celulares, par_prestamos, ingreso_mensual, cap_sistematica_abono, tope_abonocoppel, capmaxima_abono, capreal_abono, lineacredito_real, lineacreditotope, fechalineacreditoreal, fechalineacreditotope, compromisossic, flaglineacreditoesp, cod_ret, limitecredito, limitecreditopesos, paraaltoriesgonvo, campo_1, campo_2, campo_3, clienteprospecto, id_situaciones, puntualidad_ref1, puntualidad_ref2, flagtestigoparametricocn, flag_altadirecta_asupervisar, puntos_var_param, puntos_var_sic, score_domicilio, nuevo_puntajefinal, campo_4, prepuntajealtoriesgo, flag_pagoini, porc_pagoini, monto_disp_pagoini, flag_prestamo, canal_origensol, grupo_eval, grupo_hit, flagtipomsgmotos, montodispmotos, porcpimotos
	from "informix".ss_nuevo_parametrico where empresa =pempresa and  num_solicitud = pnumsolcred;
	
	INSERT INTO "informix".ss_solicitudes (empresa, num_solicitud, numcte, co_numcte, cod_funcion, regional, plaza, sucursal, tipo_solicitud, status_solicitud, num_producto, tipo_prestamo, monto_solicitado, periodo_plazo, plazo, divisa, tipo_calculo, cod_tasa_base, sobretasa, factor_sobretasa, tasa_interes, tasa_fija_o_var, rev_tasa_var_per, dia_para_revisar, tasa_mora_adic, cod_tasa_mora, fact_sobret_mora, sobretasa_mora, tasa_moratorios, factor_moratorio, periodo_pag_cap, periodo_pag_int, gracia_cap, diferimiento_int, tp_gen_planpago, individualizable, con_integrantes, fecha_apert_prop, fecha_venc_prop, ajuste_de_cuota, ajuste_venc_int, envio_coppel, envio_parametrico, tasa_base_piso, sobretasa_piso, factor_piso, tasa_piso, tasa_base_techo, sobretasa_techo, factor_techo, capacidad_pres, monto_autorizado, user_insert, fecha_insert, fecha_hora,canal_sol)
	select empresa, cSolOro, numcte, co_numcte, cod_funcion, regional, plaza, sucursal, tipo_solicitud, status_solicitud, "8100", tipo_prestamo, cLineaTeorica, periodo_plazo, plazo, divisa, tipo_calculo, cod_tasa_base, sobretasa, factor_sobretasa, tasa_interes, tasa_fija_o_var, rev_tasa_var_per, dia_para_revisar, tasa_mora_adic, cod_tasa_mora, fact_sobret_mora, sobretasa_mora, tasa_moratorios, factor_moratorio, periodo_pag_cap, periodo_pag_int, gracia_cap, diferimiento_int, tp_gen_planpago, individualizable, con_integrantes, fecha_apert_prop, fecha_venc_prop, ajuste_de_cuota, ajuste_venc_int, envio_coppel, envio_parametrico, tasa_base_piso, sobretasa_piso, factor_piso, tasa_piso, tasa_base_techo, sobretasa_techo, factor_techo, capacidad_pres, monto_autorizado, user_insert, today, current,canal_sol
	from "informix".ss_solicitudes where empresa =pempresa and  num_solicitud = pnumsolcred;

	INSERT INTO bdisolic:"informix".ss_resum_scor_fin(empresa, num_solicitud, situacion_pago, situacion_credito, meses_historia, fuente, evalua_cc, motivo_cc, ingreso_mensual, tp_ingreso, periodo_ingreso, pago_minimo, linea_tienda, causa, puntualidad, saldoropa, saldomuebles, saldoprestamos, vencidoropa, vencidomuebles, vencidoprestamos, abonomensualropa, abonomensualmuebles, abonomensualprestamos, fecha_ultima_compra, secuenciaconsulta, origen, smbc, salario_minimo, compromisos_bco, situacion_especial, causa_situacion, grupo, ingreso_lc, valor_cma, valor_tab, linea_teorica, tipo_movimiento, num_solicitud_ref, monto_hipoteca,vencidototalaire, abonomensualaire, saldototalaire, vencidototalafiliados, abonomensualafiliados, saldototalafiliados, vencidototalreestructura, abonomensualreestructura, saldototalreestructura, scorepuntualidad)
	SELECT a.empresa, cSolOro, a.situacion_pago, a.situacion_credito, a.meses_historia, a.fuente, a.evalua_cc, a.motivo_cc, a.ingreso_mensual, a.tp_ingreso, a.periodo_ingreso, a.pago_minimo, a.linea_tienda, a.causa, a.puntualidad, a.saldoropa, a.saldomuebles, a.saldoprestamos, a.vencidoropa, a.vencidomuebles, a.vencidoprestamos, a.abonomensualropa, a.abonomensualmuebles, a.abonomensualprestamos, a.fecha_ultima_compra, a.secuenciaconsulta, a.origen, a.smbc, a.salario_minimo, a.compromisos_bco, a.situacion_especial, a.causa_situacion, a.grupo,v_ingreso, v_flujo_libre1,  v_flujo_libre2, a.linea_teorica, a.tipo_movimiento, a.num_solicitud_ref, a.monto_hipoteca, 
	b.vencidototalaire, b.abonomensualaire, b.saldototalaire, b.vencidototalafiliados, b.abonomensualafiliados, b.saldototalafiliados, b.vencidototalreestructura, b.abonomensualreestructura, b.saldototalreestructura, b.scorepuntualidad	
	FROM "informix".ss_resum_scor_fin a
	LEFT OUTER JOIN "informix".ss_cliente_coppel_pp b ON b.empresa=a.empresa AND b.cliente_coppel = cNumcte
	WHERE a.empresa = pempresa
	AND a.num_solicitud = pnumsolcred;

	INSERT INTO "informix".ss_anexosol (empresa, num_solicitud, actividad, cod_tipo_linea, cod_linea, fecha_sol, fecha_ult_mod, ejecutivo_sol, ejecutivo_resol, num_acta, raza_origen_presta, raza_origen_cop, otro_presta, otro_copresta, num_cred_agencia, num_prestador, sexo_copresta, user_insert, fecha_insert)
	select empresa, cSolOro, actividad, cod_tipo_linea, cod_linea, TODAY, TODAY, ejecutivo_sol, ejecutivo_resol, num_acta, raza_origen_presta, raza_origen_cop, otro_presta, otro_copresta, num_cred_agencia, num_prestador, sexo_copresta, user_insert, TODAY
	from "informix".ss_anexosol where empresa =pempresa and  num_solicitud = pnumsolcred;

	INSERT INTO "informix".ss_autorizacion (empresa, ejecutivo_auto, num_solicitud, status_solicitud, comentario, causa_solicitud, cliente_pros, fecha_entrada, fecha_salida, user_insert, fecha_insert, revision_cac, fecha_hora)
	select empresa, ejecutivo_auto, cSolOro, status_solicitud, comentario, causa_solicitud, cliente_pros, fecha_entrada, TODAY, user_insert, TODAY, revision_cac, TODAY
	from "informix".ss_autorizacion where empresa =pempresa and  num_solicitud = pnumsolcred;

	INSERT INTO "informix".ss_resumen_scoring (empresa, num_solicitud, seccion, evaluacion)
	select empresa, cSolOro, seccion, evaluacion
	from "informix".ss_resumen_scoring where empresa =pempresa and  num_solicitud = pnumsolcred;

	INSERT INTO "informix".ss_detalle_scoring (empresa, seccion, grupo, elemento, tpo_persona, num_solicitud, valor)
	select empresa, seccion, grupo, elemento, tpo_persona, cSolOro, valor
	from "informix".ss_detalle_scoring where empresa =pempresa and  num_solicitud = pnumsolcred;

	INSERT INTO "informix".ss_detalle_modelo (empresa, num_solicitud, variable, valor, fecha_insert, usuario)
	select empresa, cSolOro, variable, valor, today, usuario
	from "informix".ss_detalle_modelo where empresa =pempresa and  num_solicitud = pnumsolcred;
	   
	INSERT INTO "informix".ss_refpersonales (empresa, num_solicitud, numcte, numcte_ref, parentesco, tipo_relacion, nombre_ref, telefono_ref)
	select empresa, cSolOro, numcte, numcte_ref, parentesco, tipo_relacion, nombre_ref, telefono_ref
	from "informix".ss_refpersonales where empresa =pempresa and  num_solicitud = pnumsolcred;

	INSERT INTO bdinteg:"informix".si_refclientes (empresa, num_solicitud, numcte, sucursal, apell_paterno, apell_materno, nombre1, nombre2, rfc, fecha_nac, curp, sexo, estado_civil, nacionalidad, no_fm3, codidentifi, numidentifi, pers_domicilio, email, parentesco, apellido_cas, numcte_ref, numcte_banco, user_insert, fecha_insert)
	select empresa, cSolOro, numcte, sucursal, apell_paterno, apell_materno, nombre1, nombre2, rfc, fecha_nac, curp, sexo, estado_civil, nacionalidad, no_fm3, codidentifi, numidentifi, pers_domicilio, email, parentesco, apellido_cas, numcte_ref, numcte_banco, user_insert, today
	from bdinteg:"informix".si_refclientes where empresa =pempresa and numcte = cNumcte and   num_solicitud = pnumsolcred;
	
	INSERT INTO "informix".ss_revision_determinacion (empresa,num_solicitud,numcte,num_producto,ingreso_mensual,ingreso_mensual_lc,situacion_pago,situacion_credito,meses_historia,saldoropa,saldomuebles,saldoprestamo,vencidoropa,vencidomuebles,vencidoprestamos,abonomensualropa,abonomensualmuebles,abonomensualprestamos,pago_crnom,pago_prest,pago_tdc,evalua_cc,monto_hipoteca,compromiso_sic,compromiso_sic_lc,linea_tienda,bs_score,score_prop,fico_score,mto_pagos_bco,monto_coppel,grupo,compromiso_mens,factor1,factor2,valor_cta,valor_cma,valor_tab,valor_rab,valor_pres,tasa,tasa_iva,tasa_mens,plazo,cap_pag_min,tope_ingreso_tope,linea_teorica,limiteinf,limitesup,linea_credito,porc_incre,porc_decre,monto_incre,monto_decre,linea_final,bandera_rr,linea_rest,bandera_mc,pago_mens,porc_hipo,porc_buro,porc_otros,perfil_riesgo,ingreso_sm,fecha_insert, otros_gastos, monto_hipoteca_lc, fecha_nacimiento, profesion, edad, sexo, escolaridad, escolaridad_descrip, edo_civil, rfc, actividad, subactividad, actividad_descrip, situacion_especial, causa_sit_esp, descripcion_siesp, comprob_ing_val_mc, monto_reportado_mc, tipo_cambio_udi, tipo_cambio_dls, salario_minimo, linea_min_prod, estatus_sol, causa_rechazo, num_reest_cte, fecha_sol, excluye_validacion, flag2credito, flag2creditoicc, cat, evalua_cc_original, motivo_cc_original, reasigna_evalua_cc, telefono_domicilio, telefono_celular, telefono_trabajo, telefono_ref1, telefono_ref2, compromiso_coppel_simulado, porcentaje_compromiso, vencidototalaire, abonomensualaire, saldototalaire, vencidototalafiliados, abonomensualafiliados, saldototalafiliados, vencidototalreestructura, abonomensualreestructura, saldototalreestructura, scorepuntualidad)
	SELECT a.empresa, cSolOro, a.numcte, "8100", a.ingreso_mensual, v_ingreso, a.situacion_pago, a.situacion_credito, a.meses_historia, a.saldoropa, a.saldomuebles, a.saldoprestamo, a.vencidoropa, a.vencidomuebles, a.vencidoprestamos, a.abonomensualropa, a.abonomensualmuebles, a.abonomensualprestamos, a.pago_crnom, a.pago_prest, a.pago_tdc, a.evalua_cc, a.monto_hipoteca, a.compromiso_sic, a.compromiso_sic_lc, a.linea_tienda, a.bs_score, a.score_prop, a.fico_score, a.mto_pagos_bco, a.monto_coppel, a.grupo, a.compromiso_mens, a.factor1, a.factor2, a.valor_cta, v_flujo_libre1,  v_flujo_libre2, a.valor_rab, a.valor_pres, a.tasa, a.tasa_iva, a.tasa_mens, a.plazo, a.cap_pag_min, a.tope_ingreso_tope, a.linea_teorica, a.limiteinf, a.limitesup, a.linea_credito, a.porc_incre, a.porc_decre, a.monto_incre, a.monto_decre, cLineaTeorica, a.bandera_rr, a.linea_rest, a.bandera_mc, a.pago_mens, a.porc_hipo, a.porc_buro, a.porc_otros, a.perfil_riesgo, a.ingreso_sm, a.fecha_insert,
	a.otros_gastos, a.monto_hipoteca_lc, a.fecha_nacimiento, a.profesion, a.edad, a.sexo, a.escolaridad, a.escolaridad_descrip, a.edo_civil, rfc, a.actividad, a.subactividad, a.actividad_descrip, a.situacion_especial, a.causa_sit_esp, a.descripcion_siesp, a.comprob_ing_val_mc, a.monto_reportado_mc, a.tipo_cambio_udi, a.tipo_cambio_dls, a.salario_minimo, a.linea_min_prod, a.estatus_sol, a.causa_rechazo, a.num_reest_cte, a.fecha_sol, a.excluye_validacion, a.flag2credito, a.flag2creditoicc, a.cat, a.evalua_cc_original, a.motivo_cc_original, a.reasigna_evalua_cc, a.telefono_domicilio, a.telefono_celular, a.telefono_trabajo, a.telefono_ref1, a.telefono_ref2, a.compromiso_coppel_simulado, a.porcentaje_compromiso, a.vencidototalaire, a.abonomensualaire, a.saldototalaire, a.vencidototalafiliados, a.abonomensualafiliados, a.saldototalafiliados, a.vencidototalreestructura, a.abonomensualreestructura, a.saldototalreestructura, a.scorepuntualidad
	FROM "informix".ss_revision_determinacion a
	WHERE a.empresa = pempresa
	AND a.num_solicitud = pnumsolcred;
	
	---ACP BRM MOTOR DE EVALUACION
	SELECT sucursal, num_producto INTO csucursal, cNumProducto 
	FROM bdisolic:"informix".ss_solicitudes 
	WHERE num_solicitud = cSolOro and empresa = pempresa;
	
	-- Validamos el numero de sucursales por producto
	SELECT COUNT(numsucursal) INTO iAuxSucMotor 
	FROM bdicred:"informix".sd_sucursales_motor WHERE producto = cNumproducto;
	
	IF EXISTS (SELECT numproducto FROM bdicred:"informix".sd_productos_motor WHERE numproducto = cNumProducto)
	   AND iAuxSucMotor > 0
	   AND EXISTS (SELECT numsucursal FROM bdicred:"informix".sd_sucursales_motor WHERE numsucursal = csucursal AND producto = cNumProducto) THEN 
			INSERT INTO bdisolic:"informix".ss_enviossolicitudesmotor
			(empresa, num_solicitud, num_cte, status_consumo, fecha_insert, status_respuesta)
			VALUES (pempresa,cSolOro, cNumcte , 0, current, '');			
	ELIF EXISTS (SELECT numproducto FROM bdicred:"informix".sd_productos_motor WHERE numproducto = cNumProducto)
	   AND iAuxSucMotor = 0 THEN
	   --AND NOT EXISTS (SELECT producto FROM bdicred:"informix".sd_sucursales_motor WHERE numsucursal = csucursal AND producto = cNumProducto) THEN 
			INSERT INTO bdisolic:"informix".ss_enviossolicitudesmotor
			(empresa, num_solicitud, num_cte, status_consumo, fecha_insert, status_respuesta)
			VALUES (pempresa,cSolOro, cNumcte , 0, current, '');		
	ELSE
		--Se actualiza la informacion de determinacion de linea para el nuevo credito TDC Oro
		EXECUTE PROCEDURE bdisolic:"informix".determina_lincred_tc_cjunk(pempresa, cSolOro,'')
		INTO scod_ret, v_valor,v_capacidad_pago,iPlazo;
	END IF;
	
	EXECUTE PROCEDURE "informix".sp_actualiza_status_sol 
	(pempresa, 'sistema',pnumsolcred, "CN", "CMP", "CancelaciÃ³n por migraciÃ³n a producto ORO")
	INTO scod_ret;
  
  RETURN cCodRet, NVL(cLineaTeorica,''), NVL(cSolOro,'');
	
ELIF TRIM(NVL(TipoEjec,'')) = '3' THEN	

	--tabla de control para clonacion de la solicitud  en esta ejecuciÃ³n pnumsolcred es la Solicitud TDC Oro
	SELECT  numero_solicitud,numcte 	
		INTO cNumSolClass,cNumcte
	FROM  "informix".ss_solicitudes_tdcoro 
	WHERE numero_solicitud_oro = pnumsolcred;
	
	--Borrado del clonado de la solicitud clasica a oro

	DELETE FROM  bdisolic:"informix".ss_solicitudes where empresa =pempresa and  num_solicitud = pnumsolcred;
	DELETE FROM  bdisolic:"informix".ss_resum_scor_fin where empresa =pempresa and  num_solicitud = pnumsolcred;
	DELETE FROM  bdisolic:"informix".ss_anexosol where empresa =pempresa and  num_solicitud = pnumsolcred;
	DELETE FROM  bdisolic:"informix".ss_autorizacion where empresa =pempresa and  num_solicitud = pnumsolcred;
	DELETE FROM  bdisolic:"informix".ss_resumen_scoring where empresa =pempresa and  num_solicitud = pnumsolcred;
	DELETE FROM  bdisolic:"informix".ss_detalle_scoring where empresa =pempresa and  num_solicitud = pnumsolcred;
	DELETE FROM  bdisolic:"informix".ss_detalle_modelo where empresa =pempresa and  num_solicitud = pnumsolcred;
	DELETE FROM  bdisolic:"informix".ss_refpersonales where empresa =pempresa and  num_solicitud = pnumsolcred;
	DELETE FROM  bdinteg:"informix".si_refclientes where empresa =pempresa and numcte = cNumcte and   num_solicitud = pnumsolcred;
	DELETE FROM  bdisolic:"informix".ss_revision_determinacion where empresa =pempresa and  num_solicitud = pnumsolcred;
	DELETE FROM  bdisolic:"informix".ss_nuevo_parametrico where empresa =pempresa and  num_solicitud = pnumsolcred;
	DELETE FROM  bdisolic:"informix".ss_enviossolicitudesmotor where empresa =pempresa and  num_solicitud = pnumsolcred;  --BRM ACP

	UPDATE bdisolic:"informix".ss_solicitudes
	SET status_solicitud = "AT"
	WHERE empresa = pempresa
	AND num_solicitud = cNumSolClass;
		  
	DELETE FROM bdisolic:"informix".ss_autorizacion 
	WHERE empresa = pempresa  
	AND num_solicitud = cNumSolClass  
	AND status_solicitud = "CN" 
	AND causa_solicitud ="CMP";
	
	UPDATE bdisolic:"informix".ss_solicitudes_tdcoro
	SET numero_solicitud_oro = "",
	confirma_oro= "" 
	WHERE empresa = pempresa
	AND numero_solicitud = cNumSolClass;

	RETURN cCodRet, NVL(NvaLinea,''), NVL(pnumsolcred,'');

	ELIF TRIM(NVL(TipoEjec,'')) = '4' THEN
		
	SELECT numero_solicitud_oro,numcte,linea_teorica, ingreso_lc, valor_cma, valor_tab
		INTO cSolOro,cNumcte,cLineaTeorica,	v_ingreso,  v_flujo_libre1,  v_flujo_libre2
	FROM "informix".ss_solicitudes_tdcoro	
	WHERE empresa = pempresa
	AND numero_solicitud_oro = pnumsolcred;
	
	RETURN cCodRet, NVL(cLineaTeorica,'0'), NVL(pnumsolcred,'');
	
END IF	

END
END PROCEDURE
