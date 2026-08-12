CREATE PROCEDURE "informix".cons_saldocrd(pNumCredito CHAR(20))
   RETURNING CHAR(5), MONEY(16,2), CHAR(1);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nrows               SMALLINT;

   DEFINE NumProducto         CHAR(4);
   DEFINE StatusCred          CHAR(2);
   DEFINE Saldo               MONEY(16,2);
   DEFINE ManejaLinea         CHAR(1);
   DEFINE wStatus             CHAR(1);
   DEFINE cMtoVen       	  DECIMAL(18,2);




   ON EXCEPTION SET sql_err, isam_err, error_info
      --SET DEBUG FILE TO "Cons_Saldo.err";
      --TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET saldo = 0;
      LET wStatus = " ";
      RETURN cod_ret, Saldo, wStatus;
   END EXCEPTION;


   LET cod_ret = "000";
   LET saldo = 0;
   LET wStatus = " ";
   LET cMtoVen = 0;

   SELECT {+INDEX (sd_maesdoscrd idx_maesdoscrd1) +INDEX (sd_definicioncrd definicioncrd1)}
      a.num_producto,
      a.status_cred,
      b.monto_otorgado - b.sdo_cap_insoluto,
      c.maneja_linea,
	  NVL(b.monto_vencido + b.mto_venc_trasp,0)
   INTO
      NumProducto,
      StatusCred,
      Saldo,
      ManejaLinea,
	  cMtoVen	  
   FROM
      sd_maecredcrd a,
      sd_maesdoscrd b,
      sd_definicioncrd c
   WHERE
      a.num_credito = pNumCredito
   AND
      b.num_credito = a.num_credito and b.empresa='001'
   AND
      c.num_producto = a.num_producto and c.empresa='001';

   LET nrows = dbinfo("sqlca.sqlerrd2");
   IF(nrows = 0) THEN
      LET Saldo = 0;
      LET cod_ret = "008";
      RETURN cod_ret, Saldo, wStatus;
   END IF;

   LET wStatus = StatusCred[1,1];

   IF(ManejaLinea <> "S") THEN
      LET cod_ret = "206";
      RETURN cod_ret, Saldo, wStatus;
   END IF;

   IF (Saldo = 0) THEN
      LET cod_ret = "202";
      RETURN cod_ret, Saldo, wStatus;
   END IF;

   IF (StatusCred in ("BA","BT","E1","E2","E3") AND cMtoVen > 0) THEN
      LET cod_ret = "204";
      RETURN cod_ret, Saldo, wStatus;
   END IF;



   RETURN cod_ret, Saldo, wStatus;
END PROCEDURE
DOCUMENT
'Esta funcion realiza la consulta de saldo disponible para ',
'un credito Inta - Cash',
'AUTOR : Raul Mendoza',
'FECHA : 8/10/2003',
'BD : bdicred ',
'CLIENTE : CACSI';

CREATE PROCEDURE "informix".sp_calcula_proyecta_prestamo()

RETURNING   CHAR(6) 	AS retorno,				-- CODIGO DE RETORNO
			CHAR(100)	AS mensaje_ret;			-- MENSAJE DE RETORNO
			--INTEGER		AS registros_afec		-- NUMERO DE REGISTROS AFECTADOS

--EXECUTE PROCEDURE "informix".sp_calcula_proyecta_prestamo();

-- VARIABLES PARA RETORNO DE DATOS
DEFINE cCodRet          	CHAR(6);
DEFINE cMensajeRet    		CHAR(100);
-- VARIABLES DE CONTROL DE ERRORES
DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr         	INTEGER;
-- VARIABLES AUXILIARES
--DEFINE cont					INTEGER;			-- CONTADOR
DEFINE a_num_producto		CHAR(4);			-- NUMERO DEL PRODUCTO
DEFINE a_sucursal			CHAR(4);			-- SUCURSAL
DEFINE a_num_credito		CHAR(20);			-- NUMERO DE CREDITO
DEFINE num_cred				CHAR(20);			-- NUMERO DE CREDITO PARA RETORNAR EN ERROR
DEFINE mPeriodo				INTEGER;			-- PERIODO DE PAGO
DEFINE dFechaCouta			DATE;				-- FECHA
DEFINE mSdoInicial			DECIMAL(18,6);		-- SALDO INICIAL
DEFINE mMensualidad			DECIMAL(18,6);		-- MENSUALIDAD
DEFINE mIntereses			DECIMAL(18,6);		-- INTERESES
DEFINE mIvaInt				DECIMAL(18,6);		-- IVA DE INTERESES
DEFINE mCapital				DECIMAL(18,6);		-- CAPITAL
DEFINE mSdoFinal			DECIMAL(18,6);		-- SALDO FINAL
DEFINE sDiasPeriodo			SMALLINT;			-- DIAS DEL PERIODO
DEFINE dFechaAper			DATE;				-- FECHA DE APERTURA
DEFINE mPlazoAux      		DECIMAL(18,6);		-- NUMERO MAXIMO DE PLAZOS
DEFINE mTotalPagar			DECIMAL(18,2);		-- MONTO TOTAL A PAGAR

--INICIALIZACION DE VARIABLES PARA RETORNO DE DATOS
LET cCodRet					= '000000';
LET cMensajeRet      		= "EL PROCESO SE EJECUTO CON EXITO";
--INICIALIZACION DE VARIABLES DE CONTROL DE ERRORES
LET iSqlErr                 = 0;
LET iIsamErr				= 0;
--INICIALIZACION DE VARIABLES AUXILIARES
--LET cont 					= 0;
LET a_num_producto			= "";
LET a_sucursal				= "";
LET a_num_credito			= "";
LET num_cred				= "";
LET mPeriodo				= 0;
LET dFechaCouta				= DATE(1);
LET mSdoInicial				= 0;
LET mMensualidad			= 0;
LET mIntereses				= 0;
LET mIvaInt					= 0;
LET mCapital				= 0;
LET mSdoFinal				= 0;
LET sDiasPeriodo			= 0;
LET dFechaAper				= DATE(1);
LET mPlazoAux       		= 0;
LET mTotalPagar				= 0;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		LET cCodRet= iSqlErr;
		LET cMensajeRet = 'EL PROCESO MARCO ERROR EN EL CREDITO '||num_cred;
		DROP TABLE cal_pro;
		RETURN 	cCodRet,
				cMensajeRet;
				--cont;
	END EXCEPTION;

	--SET DEBUG FILE TO "/pisa/Pamela/Carlos/sp_calcula_proyecta_prestamo.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
		-- SE OBTIENEN LOS PARAMETROS PARA LA EJECUCION DEL PROYECTA PRESTAMO Y SE CARGAN EN UN TABLA TEMPORAL
		SELECT a.num_credito, a.num_producto, a.sucursal, b.mto_capitalizado
		FROM "informix".sd_maecredcrd a, "informix".sd_maesdoscrd b
		WHERE a.empresa = '001'
		AND a.empresa = b.empresa
		AND a.num_credito = b.num_credito
		--AND a.num_credito in (630013690684,630013737303,630013767094,630013864164,630014080075)
		AND a.num_producto in ('6300','6400')
		AND a.status_cred in ('AA','BA','BT','E1','E2','E3')
		AND b.mto_capitalizado = 0
		INTO temp cal_pro WITH NO LOG;
		--AND a.sucursal in ('0192','0204')
		
	FOREACH WITH HOLD
			
			--CONSULTA LA TABLA TEMPORAL PARA SACAR LOS VALORES PARA HACER EL CALCULO EL MONTO TOTAL A PAGAR POR CREDITO
			SELECT num_credito, num_producto, sucursal 
			INTO a_num_credito, a_num_producto, a_sucursal
			FROM cal_pro
			
			LET num_cred = a_num_credito;
			
			FOREACH
				
				--SE OBTIENE CON EL PROYECTA PRESTAMO CADA UNA DE LAS MENSUALIDADES PARA SUMARLAS y CALCULAR EL MONTO TOTAL A PAGAR
				EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos(0,0,0,a_num_producto,a_sucursal,'2','0',a_num_credito,'',1) 
				INTO cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux
				
				--SE VALIDAD PARA VER SI EL PROYECTA PRESTAMO SE EJECUTA CORRECTAMENTE
				IF cCodRet::INTEGER <> 0  THEN				
					--LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO DEL PROYECTA PRESTAMO CON EL CREDITO '||num_cred;
					--DROP TABLE cal_pro;
					--RETURN 	cCodRet,
					--		cMensajeRet;
							--cont;
					LET mTotalPagar = 0;
					
				ELSE
				
					--VARIABLE QUE GUARDA LA SUMA DE LAS MENSUALIDADES
					LET mTotalPagar = mTotalPagar + mMensualidad;
					
				END IF;
				
			END FOREACH;
			
		BEGIN WORK;
			
			-- SE GUARDA EL MONTO TOTAL A PAGAR DEL PRESTAMO PERSONAL
			UPDATE "informix".sd_maesdoscrd
			SET mto_capitalizado = mTotalPagar
			WHERE empresa = '001'
			AND num_credito = a_num_credito;
			
		COMMIT WORK;	
		
		--LET cont = cont + 1;
		
		-- INICIALIZACION DE LA VARIABLES PARA VOLVER A USARLAS CON EL PROXIMO NUMERO DE CREDITO PARA EL CALCULO DEL MONTO TOTAL A PAGAR
		LET mMensualidad			= 0;
		LET mTotalPagar				= 0;
		LET a_num_credito			= 0;
		LET a_num_producto			= 0;
		LET a_sucursal				= 0;
	
	END FOREACH;
	
	DROP TABLE cal_pro;
	
	LET cCodRet = '000000';
	
RETURN 	cCodRet,
		cMensajeRet;
		--cont;

END

END PROCEDURE
DOCUMENT
'Descripcion: Proceso que sirve para calcular y guardar el monto total a pagar de un prestamo personal ya existente en la tabla sd_maesdoscrd.',
'BD: bdicred',
'Fecha: 2015/01/22.',
'Creado: Carlos Antonio Valenzuela Leyva';

CREATE PROCEDURE "informix".reversion_web(o_empresa CHAR(3),
                           O_SUCursal CHAR(4),
                           O_USUARIO  CHAR(8),
                           o_folio    CHAR(16),
                           o_tiporev  CHAR(1))
RETURNING CHAR(5);

-- ***************************************************************************
-- *                         DEFINICION DE VARIABLES                         *
-- ***************************************************************************
DEFINE v_codret         CHAR(5);
DEFINE sql_err          INTEGER;
DEFINE w_usuario        CHAR(8);
DEFINE v_maxsec         SMALLINT;
DEFINE vdia             DATE;
DEFINE vCodTipCred      CHAR(3);
DEFINE wBegin           CHAR(1);
DEFINE cant_transacc    INTEGER;
DEFINE vExiste			INTEGER;

DEFINE mc_empresa LIKE sd_maecred.empresa;
DEFINE mc_num_credito LIKE sd_maecred.num_credito;
DEFINE mc_num_producto LIKE sd_maecred.num_producto;
DEFINE mc_ejecutivo LIKE sd_maecred.ejecutivo;
DEFINE mc_numcte LIKE sd_maecred.numcte;
DEFINE mc_divisa LIKE sd_maecred.divisa;
DEFINE mc_sucursal LIKE sd_maecred.sucursal;
DEFINE mc_id_origen LIKE sd_maecred.id_origen;
DEFINE mc_origen LIKE sd_maecred.origen;
DEFINE mc_cod_tipo_linea LIKE sd_maecred.cod_tipo_linea;
DEFINE mc_cod_linea LIKE sd_maecred.cod_linea;
DEFINE mc_porc_rec_prop LIKE sd_maecred.porc_rec_prop;
DEFINE mc_status_cred LIKE sd_maecred.status_cred;
DEFINE mc_bandera_renovac LIKE sd_maecred.bandera_renovac;
DEFINE mc_bandera_prorroga LIKE sd_maecred.bandera_prorroga;
DEFINE mc_periodo_plazo LIKE sd_maecred.periodo_plazo;
DEFINE mc_plazo LIKE sd_maecred.plazo;
DEFINE mc_fecha_apertura LIKE sd_maecred.fecha_apertura;
DEFINE mc_fecha_vencim LIKE sd_maecred.fecha_vencim;
DEFINE mc_period_pago_cap LIKE sd_maecred.period_pago_cap;
DEFINE mc_period_pag_int LIKE sd_maecred.period_pag_int;
DEFINE mc_dias_trasp_cap LIKE sd_maecred.dias_trasp_cap;
DEFINE mc_dias_trasp_int LIKE sd_maecred.dias_trasp_int;
DEFINE mc_tasa_fija_o_var LIKE sd_maecred.tasa_fija_o_var;
DEFINE mc_cod_tasa_base LIKE sd_maecred.cod_tasa_base;
DEFINE mc_factor_sobretasa LIKE sd_maecred.factor_sobretasa;
DEFINE mc_sobretasa LIKE sd_maecred.sobretasa;
DEFINE mc_tasa_interes LIKE sd_maecred.tasa_interes;
DEFINE mc_cod_tasa_mora LIKE sd_maecred.cod_tasa_mora;
DEFINE mc_sobretasa_mora LIKE sd_maecred.sobretasa_mora;
DEFINE mc_fact_sobret_mora LIKE sd_maecred.fact_sobret_mora;
DEFINE mc_tasa_moratorios LIKE sd_maecred.tasa_moratorios;
DEFINE mc_fecha_pago_cap LIKE sd_maecred.fecha_pago_cap;
DEFINE mc_fecha_pago_int LIKE sd_maecred.fecha_pago_int;
DEFINE mc_es_fisica LIKE sd_maecred.es_fisica;
DEFINE mc_bandera_fi_fo LIKE sd_maecred.bandera_fi_fo;
DEFINE mc_codigo_pro LIKE sd_maecred.codigo_pro;
DEFINE mc_superficie LIKE sd_maecred.superficie;
DEFINE mc_actividad LIKE sd_maecred.actividad;
DEFINE mc_cal_edos_fin LIKE sd_maecred.cal_edos_fin;
DEFINE mc_tipo_calculo LIKE sd_maecred.tipo_calculo;
DEFINE mc_admite_tlp LIKE sd_maecred.admite_tlp;
DEFINE mc_rel_garcred LIKE sd_maecred.rel_garcred;
DEFINE mc_id_unidad_prod LIKE sd_maecred.id_unidad_prod;
DEFINE mc_num_aper_ant LIKE sd_maecred.num_aper_ant;
DEFINE mc_rev_tasa_var_per LIKE sd_maecred.rev_tasa_var_per;
DEFINE mc_dia_para_revisar LIKE sd_maecred.dia_para_revisar;
DEFINE mc_cod_prod LIKE sd_maecred.cod_prod;
DEFINE mc_bandera_ministra LIKE sd_maecred.bandera_ministra;
DEFINE mc_num_fideicomiso LIKE sd_maecred.num_fideicomiso;
DEFINE mc_credito_externo LIKE sd_maecred.credito_externo;
DEFINE mc_gracia_capital LIKE sd_maecred.gracia_capital;
DEFINE mc_diferimiento_int LIKE sd_maecred.diferimiento_int;
DEFINE mc_fecha_fin_prorrateo LIKE sd_maecred.fecha_fin_prorrateo;
DEFINE mc_campo_trab1 LIKE sd_maecred.campo_trab1;
DEFINE mc_campo_trab2 LIKE sd_maecred.campo_trab2;
DEFINE mc_campo_trab3 LIKE sd_maecred.campo_trab3;
DEFINE mc_campo_trab4 LIKE sd_maecred.campo_trab4;
DEFINE mc_calificacion_riesgo LIKE sd_maecred.calificacion_riesgo;
DEFINE mc_cod_agricola LIKE sd_maecred.cod_agricola;
DEFINE mc_tasa_base_piso LIKE sd_maecred.tasa_base_piso;
DEFINE mc_sobretasa_piso LIKE sd_maecred.sobretasa_piso;
DEFINE mc_factor_piso LIKE sd_maecred.factor_piso;
DEFINE mc_tasa_piso LIKE sd_maecred.tasa_piso;
DEFINE mc_tasa_base_techo LIKE sd_maecred.tasa_base_techo;
DEFINE mc_sobretasa_techo LIKE sd_maecred.sobretasa_techo;
DEFINE mc_factor_techo LIKE sd_maecred.factor_techo;
DEFINE mc_tasa_techo LIKE sd_maecred.tasa_techo;
DEFINE mc_cod_caract LIKE sd_maecred.cod_caract;
DEFINE mc_cod_caract_2 LIKE sd_maecred.cod_caract_2;
DEFINE mc_cuenta_clabe LIKE sd_maecred.cuenta_clabe;

DEFINE ms_empresa LIKE sd_maesdos.empresa;
DEFINE ms_num_credito LIKE sd_maesdos.num_credito;
DEFINE ms_fecha_ult_mov LIKE sd_maesdos.fecha_ult_mov;
DEFINE ms_sdo_int_anticip LIKE sd_maesdos.sdo_int_anticip;
DEFINE ms_sdo_int_ant_dev LIKE sd_maesdos.sdo_int_ant_dev;
DEFINE ms_sdo_intereses LIKE sd_maesdos.sdo_intereses;
DEFINE ms_sdo_dia_ant_int LIKE sd_maesdos.sdo_dia_ant_int;
DEFINE ms_sdo_mes_ant_int LIKE sd_maesdos.sdo_mes_ant_int;
DEFINE ms_sdo_acum_mes_int LIKE sd_maesdos.sdo_acum_mes_int;
DEFINE ms_sdo_retenido LIKE sd_maesdos.sdo_retenido;
DEFINE ms_sdo_acum_cap_int LIKE sd_maesdos.sdo_acum_cap_int;
DEFINE ms_sdo_exig_int LIKE sd_maesdos.sdo_exig_int;
DEFINE ms_sdo_no_exig LIKE sd_maesdos.sdo_no_exig;
DEFINE ms_provision_normal LIKE sd_maesdos.provision_normal;
DEFINE ms_dias_acum_int LIKE sd_maesdos.dias_acum_int;
DEFINE ms_sdo_moratorio LIKE sd_maesdos.sdo_moratorio;
DEFINE ms_sdo_dia_ant_mor LIKE sd_maesdos.sdo_dia_ant_mor;
DEFINE ms_sdo_mes_ant_mor LIKE sd_maesdos.sdo_mes_ant_mor;
DEFINE ms_sdo_contab_mora LIKE sd_maesdos.sdo_contab_mora;
DEFINE ms_dias_acum_mora LIKE sd_maesdos.dias_acum_mora;
DEFINE ms_sdo_capital LIKE sd_maesdos.sdo_capital;
DEFINE ms_sdo_cap_insoluto LIKE sd_maesdos.sdo_cap_insoluto;
DEFINE ms_sdo_dia_ant_cap LIKE sd_maesdos.sdo_dia_ant_cap;
DEFINE ms_sdo_mes_ant_cap LIKE sd_maesdos.sdo_mes_ant_cap;
DEFINE ms_sdo_acum_mes_cap LIKE sd_maesdos.sdo_acum_mes_cap;
DEFINE ms_mto_capitalizado LIKE sd_maesdos.mto_capitalizado;
DEFINE ms_mto_ministra_cap LIKE sd_maesdos.mto_ministra_cap;
DEFINE ms_cargos_dia_cap LIKE sd_maesdos.cargos_dia_cap;
DEFINE ms_abonos_dia_cap LIKE sd_maesdos.abonos_dia_cap;
DEFINE ms_cargos_mes_cap LIKE sd_maesdos.cargos_mes_cap;
DEFINE ms_abonos_mes_cap LIKE sd_maesdos.abonos_mes_cap;
DEFINE ms_dias_acum_cap LIKE sd_maesdos.dias_acum_cap;
DEFINE ms_monto_vencido LIKE sd_maesdos.monto_vencido;
DEFINE ms_mto_venc_trasp LIKE sd_maesdos.mto_venc_trasp;
DEFINE ms_monto_financiado LIKE sd_maesdos.monto_financiado;
DEFINE ms_monto_reservado LIKE sd_maesdos.monto_reservado;
DEFINE ms_sdo_acum_vencido LIKE sd_maesdos.sdo_acum_vencido;
DEFINE ms_dias_acum_intper LIKE sd_maesdos.dias_acum_intper;
DEFINE ms_sdo_global_int LIKE sd_maesdos.sdo_global_int;
DEFINE ms_sdo_acum_intper LIKE sd_maesdos.sdo_acum_intper;
DEFINE ms_monto_otorgado LIKE sd_maesdos.monto_otorgado;
DEFINE ms_provi_venc_normal LIKE sd_maesdos.provi_venc_normal;
DEFINE ms_provi_venc_anticip LIKE sd_maesdos.provi_venc_anticip;
DEFINE ms_cap_tras_no_venci LIKE sd_maesdos.cap_tras_no_venci;
DEFINE ms_mto_venc_int LIKE sd_maesdos.mto_venc_int;
DEFINE ms_mto_venc_tra_int LIKE sd_maesdos.mto_venc_tra_int;
DEFINE ms_mto_finan_vdo LIKE sd_maesdos.mto_finan_vdo;
DEFINE ms_mto_reser_int LIKE sd_maesdos.mto_reser_int;
DEFINE ms_mto_fin_ven_trasp LIKE sd_maesdos.mto_fin_ven_trasp;
DEFINE ms_mto_fin_vig_trasp LIKE sd_maesdos.mto_fin_vig_trasp;
DEFINE ms_int_tra_no_exig LIKE sd_maesdos.int_tra_no_exig;
DEFINE ms_sdo_trab4 LIKE sd_maesdos.sdo_trab4;
DEFINE ms_act LIKE sd_maesdos.act;

DEFINE dc_empresa LIKE sd_detcomi.empresa;
DEFINE dc_cod_comis LIKE sd_detcomi.cod_comis;
DEFINE dc_num_credito LIKE sd_detcomi.num_credito;
DEFINE dc_fecha_alta LIKE sd_detcomi.fecha_alta;
DEFINE dc_fecha_pago LIKE sd_detcomi.fecha_pago;
DEFINE dc_monto_com LIKE sd_detcomi.monto_com;
DEFINE dc_monto_pag LIKE sd_detcomi.monto_pag;
DEFINE dc_apli_factor LIKE sd_detcomi.apli_factor;
DEFINE dc_estado_com LIKE sd_detcomi.estado_com;
DEFINE dc_num_solicitud LIKE sd_detcomi.num_solicitud;
DEFINE dc_user_insert LIKE sd_detcomi.user_insert;
DEFINE dc_fecha_insert LIKE sd_detcomi.fecha_insert;

DEFINE mx_empresa LIKE sd_maecredanexo.empresa;
DEFINE mx_num_credito LIKE sd_maecredanexo.num_credito;
DEFINE mx_dia_corte LIKE sd_maecredanexo.dia_corte;
DEFINE mx_dias_gracia_mora LIKE sd_maecredanexo.dias_gracia_mora;
DEFINE mx_tp_dias_calc_mora LIKE sd_maecredanexo.tp_dias_calc_mora;
DEFINE mx_dias_fecha_max_pago LIKE sd_maecredanexo.dias_fecha_max_pago;
DEFINE mx_tp_dias_fecha_pago LIKE sd_maecredanexo.tp_dias_fecha_pago;
DEFINE mx_cod_tasa_base_cte LIKE sd_maecredanexo.cod_tasa_base_cte;
DEFINE mx_factor_sobretasa_cte LIKE sd_maecredanexo.factor_sobretasa_cte;
DEFINE mx_sobretasa_cte LIKE sd_maecredanexo.sobretasa_cte;
DEFINE mx_tasa_interes_cte LIKE sd_maecredanexo.tasa_interes_cte;
DEFINE mx_fecha_vencto LIKE sd_maecredanexo.fecha_vencto;
DEFINE mx_prox_fecha_pago LIKE sd_maecredanexo.prox_fecha_pago;
DEFINE mx_fecha_proceso LIKE sd_maecredanexo.fecha_proceso;
DEFINE mx_fecha_ult_pago LIKE sd_maecredanexo.fecha_ult_pago;

DEFINE am_empresa LIKE sd_amortiza_credito.empresa;
DEFINE am_num_credito LIKE sd_amortiza_credito.num_credito;
DEFINE am_fecha_cuota LIKE sd_amortiza_credito.fecha_cuota;
DEFINE am_tipo_cuota LIKE sd_amortiza_credito.tipo_cuota;
DEFINE am_capital_mto_cuota LIKE sd_amortiza_credito.capital_mto_cuota;
DEFINE am_capital_debe LIKE sd_amortiza_credito.capital_debe;
DEFINE am_capital_pagado LIKE sd_amortiza_credito.capital_pagado;
DEFINE am_capital_status LIKE sd_amortiza_credito.capital_status;
DEFINE am_capital_status_ant LIKE sd_amortiza_credito.capital_status_ant;
DEFINE am_capital_fecha_pago LIKE sd_amortiza_credito.capital_fecha_pago;
DEFINE am_interes_debe LIKE sd_amortiza_credito.interes_debe;
DEFINE am_interes_pagado LIKE sd_amortiza_credito.interes_pagado;
DEFINE am_interes_status LIKE sd_amortiza_credito.interes_status;
DEFINE am_interes_status_ant LIKE sd_amortiza_credito.interes_status_ant;
DEFINE am_interes_fecha_pago LIKE sd_amortiza_credito.interes_fecha_pago;
DEFINE am_iva_debe LIKE sd_amortiza_credito.iva_debe;
DEFINE am_iva_pagado LIKE sd_amortiza_credito.iva_pagado;
DEFINE am_iva_status LIKE sd_amortiza_credito.iva_status;
DEFINE am_iva_status_ant LIKE sd_amortiza_credito.iva_status_ant;
DEFINE am_iva_fecha_pago LIKE sd_amortiza_credito.iva_fecha_pago;
DEFINE am_mora_provi_ordi LIKE sd_amortiza_credito.mora_provi_ordi;
DEFINE am_mora_provi_cope LIKE sd_amortiza_credito.mora_provi_cope;
DEFINE am_mora_sdo_ordi LIKE sd_amortiza_credito.mora_sdo_ordi;
DEFINE am_mora_sdo_ordi_pag LIKE sd_amortiza_credito.mora_sdo_ordi;
DEFINE am_mora_sdo_cope LIKE sd_amortiza_credito.mora_sdo_cope;
DEFINE am_mora_sdo_cope_pag LIKE sd_amortiza_credito.mora_sdo_cope_pag;
DEFINE am_mora_bonificado LIKE sd_amortiza_credito.mora_bonificado;
DEFINE am_mora_status LIKE sd_amortiza_credito.mora_status;
DEFINE am_mora_iva_debe LIKE sd_amortiza_credito.mora_iva_debe;
DEFINE am_mora_iva_pagado LIKE sd_amortiza_credito.mora_iva_pagado;
DEFINE am_mora_iva_status LIKE sd_amortiza_credito.mora_iva_status;
DEFINE am_mora_iva_fecha_pago LIKE sd_amortiza_credito.mora_iva_fecha_pago;
DEFINE am_num_pago LIKE sd_amortiza_credito.num_pago;
DEFINE am_campo_trabajo1 LIKE sd_amortiza_credito.campo_trabajo1;
DEFINE am_campo_trabajo2 LIKE sd_amortiza_credito.campo_trabajo2;
DEFINE am_campo_trabajo3 LIKE sd_amortiza_credito.campo_trabajo3;
DEFINE am_campo_trabajo4 LIKE sd_amortiza_credito.campo_trabajo4;
DEFINE de_empresa              CHAR(3)  ;
DEFINE de_num_credito          CHAR(20) ;
DEFINE de_fecha_venc_seg       DATE     ;
DEFINE de_cod_comis            CHAR(4)  ;
DEFINE de_monto_poliza         MONEY(14,2);
DEFINE de_monto_mensual        MONEY(14,2);
DEFINE de_plazo                VARCHAR(5,1);
DEFINE de_saldo                DECIMAL(18,2);
DEFINE de_texto                VARCHAR(200,0);

DEFINE sp_empresa LIKE sd_secpago.empresa;
DEFINE sp_num_credito LIKE sd_secpago.num_credito;
DEFINE sp_num_credisolucion LIKE sd_secpago.num_credito;
DEFINE sp_folio_suc LIKE sd_secpago.folio_suc;
DEFINE sp_secuencia LIKE sd_secpago.secuencia;
DEFINE sp_disp_desp_pag        INTEGER;

-- Variables para la reversion de Instacash
DEFINE vempresa  CHAR(3);
DEFINE vsucursal CHAR(4);
DEFINE vnum_credito CHAR(20);
DEFINE vdivisa CHAR(3);
DEFINE vmonto MONEY(14,2);
DEFINE vtrannro CHAR(4);
DEFINE vcod_ret  CHAR(5);
DEFINE vCodigoRef INTEGER;
DEFINE  vfecha_mov DATE;
DEFINE dtFechaHoy DATE;
-- jom ini registro reversion
DEFINE vcodigo_fun CHAR(03);
define vreversable CHAR(01);
-- jom fin registro reversion
DEFINE vBloqueo         LIKE sd_maecred.id_unidad_prod; -- Ini devolucion anualidad
DEFINE dfh_pre_devol_an LIKE sd_indicador_cred.fecha_pre_devol_anual;
DEFINE dfh_devol_an     LIKE sd_indicador_cred.fecha_devol_anual;
DEFINE cNumCred			CHAR(20);					    -- Fin devolucion anualidad
--AAME INC 27 136 31/10/2019 
DEFINE cstatus_cred CHAR(2);

-- ***************************************************************************
-- *                     ASIGNACION DE VALORES A VARIABLES                   *
-- ***************************************************************************
LET v_codret  = "00000";
LET wBegin    = "N";
LET sql_err   = 0;
LET w_usuario = USER;
LET v_maxsec  = 0;
LET vdia = "";
LET sp_disp_desp_pag=0;
LET cant_transacc=0;
-- jom ini registro reversion
LET vcodigo_fun = '';
LEt vreversable = '';
-- jom fin registro reversion
LET vExiste = 0;
LET dtFechaHoy= DATE(1);
--AAME INC 27 136 31/10/2019 
LET cstatus_cred = '';


-- ***************************************************************************

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET v_codret = sql_err;
         IF wBegin = "S" THEN
                ROLLBACK WORK;
                BEGIN WORK;
         END IF
         RETURN v_codret;
      END IF
   END EXCEPTION;

  ON EXCEPTION IN (-535)
     LET wBegin = "S";
     ROLLBACK WORK;
     BEGIN WORK;
  END EXCEPTION WITH RESUME;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

  LET wBegin = "N";

 --SET DEBUG FILE TO "/tmp/reversion.out";
 --TRACE ON;

SELECT {+INDEX(sd_fechas idx_sdfechas)} fecha_hoy
    INTO dtFechaHoy
   FROM bdicred:sd_fechas
  WHERE empresa = "001";

   SELECT UNIQUE(cod_tipcred), num_credito
     INTO vCodTipCred, vnum_credito
     FROM "informix".sd_movdia a, "informix".sd_definicion b
    WHERE folio_suc = o_folio
      AND sucursal = o_sucursal
      AND b.empresa = a.empresa
      AND b.num_producto = a.num_producto;
	  
	--AAME INC 27 136 31/10/2019 No realizar reverso si el crÃÂÃÂ©dito esta cancelado (FF)  
	SELECT status_cred 
	INTO cstatus_cred
	FROM "informix".sd_maecred
	WHERE empresa = '001'
	AND num_credito = vnum_credito;
	
	IF cstatus_cred = 'FF' THEN
	   LET v_codret = "00439";
		   IF (wBegin = "S") THEN
			 BEGIN WORK;
		   END IF;
	   RETURN v_codret;
	END IF;	

   SELECT count(1)  INTO cant_transacc
     FROM "informix".sd_movdia
    WHERE num_credito = vnum_credito
      AND folio_suc = o_folio
      AND transacc_suc IN (SELECT {+INDEX ("informix".sd_conceptoscargoscredito)} transacc FROM "informix".sd_conceptoscargoscredito
					       WHERE  aplica_reversion = "S"); --JMAH

	SELECT limit 1 num_credito
	INTO sp_num_credito
	FROM bdicred: "informix".sd_movdia
	WHERE folio_suc = o_folio ;

	-- DSB TH 07/02/2017
	SELECT num_credito
	INTO sp_num_credisolucion
	FROM bdicred: "informix".sd_secpago
	WHERE folio_suc = o_folio and num_credito <> sp_num_credito;
	
	

    IF sp_num_credisolucion IS NULL THEN
	   IF cant_transacc = 0 THEN
		  -- LA TRANSACCION A REVERSAR ES UN PAGO Y SE VALIDA QUE NO TENGA UNA OPERACION POSTERIOR AL PAGO A REVERSAR.
		  SELECT COUNT(1) INTO sp_disp_desp_pag
			FROM "informix".sd_movdia
		   WHERE empresa = '001'
			 AND num_credito = vnum_credito
			 AND reversado='N'
			 AND fecha_mov = dtFechaHoy
			 AND hora_mov > (SELECT MAX(hora_mov)
							   FROM "informix".sd_movdia
							   WHERE empresa = '001'
								 AND sucursal = O_SUCursal
								 AND folio_suc = o_folio
								 AND num_credito = vnum_credito
								 AND reversado='N'
								 AND fecha_mov = dtFechaHoy);

		ELSE
		  -- LA TRANSACCION A REVERSAR ES UN CARGO Y SE VALIDA QUE DESPUES DE LA TRANSACCION DE CARGO NO SE ENCUENTRE UN MOVIMIENTO DE PAGO
		  SELECT COUNT(1) INTO sp_disp_desp_pag
			FROM "informix".sd_movdia
		   WHERE empresa = '001'
			 and num_credito = vnum_credito
			 and codigo_fun in (SELECT {+INDEX ("informix".sd_conceptospagomanual)} cod_fun FROM "informix".sd_conceptospagomanual)
			 and codigo_ref=1
			 and reversado='N'
			 AND fecha_mov = dtFechaHoy
			 and hora_mov >( select max(hora_mov)
							   from "informix".sd_movdia
							  where sucursal=O_SUCursal
								and folio_suc=o_folio
								and num_credito = vnum_credito
								and reversado='N'
								AND fecha_mov = dtFechaHoy);
		END IF;
  END IF;

  IF sp_disp_desp_pag <> 0 THEN
	   LET v_codret = "00431"; -- PAGO NO ES EL ULTIMO REVERSA EN ORDEN
	  --     COMMIT WORK;
		   IF (wBegin = "S") THEN
			 BEGIN WORK;
		   END IF;
	   RETURN v_codret;
  END IF;

  -- Reversa el Movimiento de disposicion de tarjeta
   IF vCodTipCred = "03" THEN
   		SELECT first 1 transacc_suc INTO vtrannro
		  FROM "informix".sd_movdia
		 WHERE num_credito = vnum_credito
		   AND folio_suc = o_folio
		   AND codigo_fun = "002"
		    AND codigo_ref != 45;

		--AAME INC 27 108 Se elimina IF EXITS a peticion de Base de Datos
		SELECT  {+INDEX ("informix".sd_conceptoscargoscredito)} 
			UNIQUE 1 into vExiste FROM "informix".sd_conceptoscargoscredito
					WHERE transacc = vtrannro AND aplica_reversion = "S";
		IF vExiste = 1 THEN --JMAH
		   BEGIN WORK;
			   -- Extrae Movimiento para Reversion
		   LET cNumCred = vnum_credito;
		   LET vnum_credito =" ";
		   LET vtrannro = " ";
		   LET vmonto = 0;
		   LET vdivisa = " ";
			   CALL "informix".reversion_td (o_sucursal, o_usuario, o_folio, vnum_credito,
						  o_empresa, vmonto, vmonto,o_folio,
						  vtrannro, vdivisa)
			   RETURNING v_codret, vdia;

			-- Devolucion anualidad - INI
			-- Valida si el movimiento a reversar corresponde al retiro de devolucion de comision por anualidad.
			SELECT nvl(date(fecha_pre_devol_anual),date(1)), nvl(date(fecha_devol_anual),date(1)) INTO dfh_pre_devol_an, dfh_devol_an
			  FROM bdicred:sd_indicador_cred WHERE empresa = o_empresa AND num_credito = cNumCred;

			SELECT id_unidad_prod INTO vBloqueo
			  FROM bdicred:sd_maecred WHERE empresa = o_empresa AND num_credito = cNumCred;

			IF vBloqueo = 4 AND nvl(dfh_pre_devol_an,date(1)) > date(1) AND nvl(dfh_devol_an,date(1)) > date(1) THEN
				UPDATE bdicred:sd_indicador_cred SET fecha_devol_anual = NULL WHERE empresa = o_empresa AND num_credito = cNumCred;
			END IF;
			-- Devolucion anualidad - FIN

		   COMMIT WORK;
		   IF wBegin = "S" THEN
			 BEGIN WORK;
		   END IF
		   LET vExiste = 0;
		   RETURN v_codret;
		END IF
   END IF;



   --Bloque de modificacion para tomar en cuenta reestructuras y prestamos personal para reversos
  IF (vCodTipCred IS NULL AND vnum_credito IS NULL) OR (sp_num_credisolucion IS NOT NULL) THEN
  
	--AAME INC 27 108 Se elimina IF EXITS a peticion de Base de Datos
	SELECT  UNIQUE 1 into vExiste FROM bdicred: "informix".sd_movdiacrd WHERE folio_suc = o_folio AND empresa = "001";
	
	IF vExiste = 1 THEN

		SELECT UNIQUE(cod_tipcred), num_credito
			INTO vCodTipCred, vnum_credito
		FROM bdicred: "informix".sd_movdiacrd a, bdicred: "informix".sd_definicion b
		WHERE folio_suc = o_folio
			AND sucursal = o_sucursal
			AND b.empresa = a.empresa
			AND b.num_producto = a.num_producto;
		LET vExiste = 0;
	End if;
		  select  UNIQUE 1 into vExiste
			 FROM "informix".sd_movdiacrd a, "informix".sd_definicion b
			WHERE folio_suc = o_folio
			  AND sucursal = o_sucursal
			  AND b.empresa = a.empresa
			  AND b.num_producto = a.num_producto;
		IF vExiste = 1 THEN
			BEGIN WORK;


			EXECUTE PROCEDURE "informix".reversioncrd(o_empresa, o_sucursal, O_USUARIO, o_folio,o_tiporev)
			   INTO v_codret;
			COMMIT WORK;
		   IF wBegin = "S" THEN
			 BEGIN WORK;
		   END IF

		   /*UPDATE bdicred: "informix".sd_movdia
			SET reversado = "S"
			WHERE empresa = o_empresa
			--AND num_credito = vnum_credito
			AND folio_suc = o_folio
			AND sucursal = o_sucursal;*/

		   IF sp_num_credisolucion IS NULL THEN
			  RETURN v_codret;
		   END IF;
		END IF
END IF;
--FIN DEL BLOQUE DE MODIFICACION

-- *************************************************** INICIO DEL PROGRAMA

BEGIN WORK;

 SELECT num_credito, folio_suc, secuencia
   INTO sp_num_credito, sp_folio_suc, sp_secuencia
   FROM "informix".sd_secpago
  WHERE folio_suc = o_folio;
 IF sp_secuencia IS NULL THEN
    -- MARCA COMO REVERSADA LA TRANSACCION DE ENCABEZADO
    UPDATE "informix".sd_movdia SET reversado = "S"
    WHERE folio_suc = o_folio
      and codigo_fun = '336'
      and codigo_ref = 20;
    LET v_codret = "00000"; -- NO HAY MOVIMIENTO CON ESE FOLIO
    COMMIT WORK;
    IF (wBegin = "S") THEN
       BEGIN WORK;
    END IF;
    RETURN v_codret;
 END IF;

 SELECT MAX(secuencia) INTO v_maxsec FROM "informix".sd_secpago
  WHERE num_credito = sp_num_credito;
 IF v_maxsec <> sp_secuencia THEN
        LET v_codret = "00431"; -- PAGO NO ES EL ULTIMO REVERSA EN ORDEN
        COMMIT WORK;
        IF (wBegin = "S") THEN
          BEGIN WORK;
        END IF;
        RETURN v_codret;
 END IF;
	 --SE VALIDA PARA REVERSAR EL FOLIO ANTES DEL CARGO AL CREDITO SOLO CREDISOLUCIONES
	 --AAME INC 27 108 Se comenta para que no actualice la secuencia cuando sea credisolucion
	  /*IF sp_num_credisolucion IS NOT NULL THEN
		LET sp_secuencia = v_maxsec-1;
		 SELECT folio_suc INTO o_folio
         FROM "informix".sd_secpago
		 WHERE num_credito = sp_num_credito AND secuencia = sp_secuencia;
	  END IF;*/
   SET CONSTRAINTS ALL DEFERRED;
        IF (SELECT {+ INDEX ("informix".sd_detcomi inx_detcomi)} COUNT(1)
            FROM "informix".sd_detcomi WHERE empresa = '001' and num_credito = sp_num_credito)>0 THEN
            DELETE {+ INDEX ("informix".sd_detcomi inx_detcomi)}
            FROM "informix".sd_detcomi
            WHERE empresa = '001'
            and num_credito = sp_num_credito;
        END IF;
		DELETE FROM "informix".sd_maesdos          WHERE num_credito = sp_num_credito and empresa = '001';
		DELETE FROM "informix".sd_maecredanexo     WHERE num_credito = sp_num_credito and empresa = '001';
		DELETE FROM "informix".sd_amortiza_credito WHERE empresa = '001' and num_credito = sp_num_credito;
		DELETE FROM "informix".sd_maecred          WHERE num_credito = sp_num_credito and empresa = '001';

        -- RECUPERA MAECRED
        SELECT empresa, num_credito, num_producto, ejecutivo, numcte,
               divisa, sucursal, id_origen, origen, cod_tipo_linea, cod_linea,
               porc_rec_prop, status_cred, bandera_renovac, bandera_prorroga,
               periodo_plazo, plazo, fecha_apertura, fecha_vencim,
               period_pago_cap, period_pag_int, dias_trasp_cap, dias_trasp_int,
               tasa_fija_o_var, cod_tasa_base, factor_sobretasa, sobretasa,
               tasa_interes, cod_tasa_mora, sobretasa_mora, fact_sobret_mora,
               tasa_moratorios, fecha_pago_cap, fecha_pago_int, es_fisica,
               bandera_fi_fo, codigo_pro, superficie, actividad, cal_edos_fin,
               tipo_calculo, admite_tlp, rel_garcred, id_unidad_prod,
               num_aper_ant, rev_tasa_var_per, dia_para_revisar, cod_prod,
               bandera_ministra, num_fideicomiso, credito_externo,
               gracia_capital, diferimiento_int, fecha_fin_prorrateo,
               campo_trab1, campo_trab2, campo_trab3, campo_trab4,
               calificacion_riesgo,cod_agricola, tasa_base_piso, sobretasa_piso,
               factor_piso, tasa_piso, tasa_base_techo, sobretasa_techo,
               factor_techo, tasa_techo,cod_caract,cod_caract_2,cuenta_clabe
          INTO mc_empresa, mc_num_credito, mc_num_producto, mc_ejecutivo,
               mc_numcte, mc_divisa, mc_sucursal, mc_id_origen, mc_origen,
               mc_cod_tipo_linea, mc_cod_linea, mc_porc_rec_prop,
               mc_status_cred, mc_bandera_renovac, mc_bandera_prorroga,
               mc_periodo_plazo, mc_plazo, mc_fecha_apertura, mc_fecha_vencim,
               mc_period_pago_cap, mc_period_pag_int, mc_dias_trasp_cap,
               mc_dias_trasp_int, mc_tasa_fija_o_var, mc_cod_tasa_base,
               mc_factor_sobretasa, mc_sobretasa, mc_tasa_interes,
               mc_cod_tasa_mora, mc_sobretasa_mora, mc_fact_sobret_mora,
               mc_tasa_moratorios, mc_fecha_pago_cap, mc_fecha_pago_int,
               mc_es_fisica, mc_bandera_fi_fo, mc_codigo_pro, mc_superficie,
               mc_actividad, mc_cal_edos_fin, mc_tipo_calculo, mc_admite_tlp,
               mc_rel_garcred, mc_id_unidad_prod, mc_num_aper_ant,
               mc_rev_tasa_var_per, mc_dia_para_revisar, mc_cod_prod,
               mc_bandera_ministra, mc_num_fideicomiso, mc_credito_externo,
               mc_gracia_capital, mc_diferimiento_int, mc_fecha_fin_prorrateo,
               mc_campo_trab1, mc_campo_trab2, mc_campo_trab3, mc_campo_trab4,
               mc_calificacion_riesgo, mc_cod_agricola, mc_tasa_base_piso,
               mc_sobretasa_piso, mc_factor_piso, mc_tasa_piso,
               mc_tasa_base_techo, mc_sobretasa_techo, mc_factor_techo,
               mc_tasa_techo,mc_cod_caract,mc_cod_caract_2,mc_cuenta_clabe
          FROM "informix".sd_maecredrev
         WHERE folio = o_folio;


        INSERT INTO "informix".sd_maecred( empresa, num_credito, num_producto, ejecutivo, numcte,
               divisa, sucursal, id_origen, origen, cod_tipo_linea, cod_linea,
               porc_rec_prop, status_cred, bandera_renovac, bandera_prorroga,
               periodo_plazo, plazo, fecha_apertura, fecha_vencim,
               period_pago_cap, period_pag_int, dias_trasp_cap, dias_trasp_int,
               tasa_fija_o_var, cod_tasa_base, factor_sobretasa, sobretasa,
               tasa_interes, cod_tasa_mora, sobretasa_mora, fact_sobret_mora,
               tasa_moratorios, fecha_pago_cap, fecha_pago_int, es_fisica,
               bandera_fi_fo, codigo_pro, superficie, actividad, cal_edos_fin,
               tipo_calculo, admite_tlp, rel_garcred, id_unidad_prod,
               num_aper_ant, rev_tasa_var_per, dia_para_revisar, cod_prod,
               bandera_ministra, num_fideicomiso, credito_externo,
               gracia_capital, diferimiento_int, fecha_fin_prorrateo,
               campo_trab1, campo_trab2, campo_trab3, campo_trab4,
               calificacion_riesgo,cod_agricola, tasa_base_piso, sobretasa_piso,
               factor_piso, tasa_piso, tasa_base_techo, sobretasa_techo,
               factor_techo, tasa_techo,cod_caract,cod_caract_2,cuenta_clabe)
        VALUES (mc_empresa, mc_num_credito, mc_num_producto, mc_ejecutivo,
               mc_numcte, mc_divisa, mc_sucursal, mc_id_origen, mc_origen,
               mc_cod_tipo_linea, mc_cod_linea, mc_porc_rec_prop,
               mc_status_cred, mc_bandera_renovac, mc_bandera_prorroga,
               mc_periodo_plazo, mc_plazo, mc_fecha_apertura, mc_fecha_vencim,
               mc_period_pago_cap, mc_period_pag_int, mc_dias_trasp_cap,
               mc_dias_trasp_int, mc_tasa_fija_o_var, mc_cod_tasa_base,
               mc_factor_sobretasa, mc_sobretasa, mc_tasa_interes,
               mc_cod_tasa_mora, mc_sobretasa_mora, mc_fact_sobret_mora,
               mc_tasa_moratorios, mc_fecha_pago_cap, mc_fecha_pago_int,
               mc_es_fisica, mc_bandera_fi_fo, mc_codigo_pro, mc_superficie,
               mc_actividad, mc_cal_edos_fin, mc_tipo_calculo, mc_admite_tlp,
               mc_rel_garcred, mc_id_unidad_prod, mc_num_aper_ant,
               mc_rev_tasa_var_per, mc_dia_para_revisar, mc_cod_prod,
               mc_bandera_ministra, mc_num_fideicomiso, mc_credito_externo,
               mc_gracia_capital, mc_diferimiento_int, mc_fecha_fin_prorrateo,
               mc_campo_trab1, mc_campo_trab2, mc_campo_trab3, mc_campo_trab4,
               mc_calificacion_riesgo, mc_cod_agricola, mc_tasa_base_piso,
               mc_sobretasa_piso, mc_factor_piso, mc_tasa_piso,
               mc_tasa_base_techo, mc_sobretasa_techo, mc_factor_techo,
               mc_tasa_techo,mc_cod_caract,mc_cod_caract_2,mc_cuenta_clabe);

        -- RECUPERA MAESDOS
        SELECT empresa, num_credito, fecha_ult_mov, sdo_int_anticip,
               sdo_int_ant_dev, sdo_intereses, sdo_dia_ant_int, sdo_mes_ant_int,
               sdo_acum_mes_int, sdo_retenido, sdo_acum_cap_int, sdo_exig_int,
               sdo_no_exig, provision_normal, dias_acum_int, sdo_moratorio,
               sdo_dia_ant_mor, sdo_mes_ant_mor, sdo_contab_mora,
               dias_acum_mora, sdo_capital, sdo_cap_insoluto, sdo_dia_ant_cap,
               sdo_mes_ant_cap, sdo_acum_mes_cap, mto_capitalizado,
               mto_ministra_cap, cargos_dia_cap, abonos_dia_cap, cargos_mes_cap,
               abonos_mes_cap, dias_acum_cap, monto_vencido, mto_venc_trasp,
               monto_financiado, monto_reservado, sdo_acum_vencido,
               dias_acum_intper, sdo_global_int, sdo_acum_intper,
               monto_otorgado, provi_venc_normal, provi_venc_anticip,
               cap_tras_no_venci, mto_venc_int, mto_venc_tra_int, mto_finan_vdo,
               mto_reser_int, mto_fin_ven_trasp, mto_fin_vig_trasp,
               int_tra_no_exig, sdo_trab4,act
          INTO ms_empresa, ms_num_credito, ms_fecha_ult_mov, ms_sdo_int_anticip,
               ms_sdo_int_ant_dev, ms_sdo_intereses, ms_sdo_dia_ant_int,
               ms_sdo_mes_ant_int, ms_sdo_acum_mes_int, ms_sdo_retenido,
               ms_sdo_acum_cap_int, ms_sdo_exig_int, ms_sdo_no_exig,
               ms_provision_normal, ms_dias_acum_int, ms_sdo_moratorio,
               ms_sdo_dia_ant_mor, ms_sdo_mes_ant_mor, ms_sdo_contab_mora,
               ms_dias_acum_mora, ms_sdo_capital, ms_sdo_cap_insoluto,
               ms_sdo_dia_ant_cap, ms_sdo_mes_ant_cap, ms_sdo_acum_mes_cap,
               ms_mto_capitalizado, ms_mto_ministra_cap, ms_cargos_dia_cap,
               ms_abonos_dia_cap, ms_cargos_mes_cap, ms_abonos_mes_cap,
               ms_dias_acum_cap, ms_monto_vencido, ms_mto_venc_trasp,
               ms_monto_financiado, ms_monto_reservado, ms_sdo_acum_vencido,
               ms_dias_acum_intper, ms_sdo_global_int, ms_sdo_acum_intper,
               ms_monto_otorgado, ms_provi_venc_normal, ms_provi_venc_anticip,
               ms_cap_tras_no_venci, ms_mto_venc_int, ms_mto_venc_tra_int,
               ms_mto_finan_vdo, ms_mto_reser_int, ms_mto_fin_ven_trasp,
               ms_mto_fin_vig_trasp, ms_int_tra_no_exig, ms_sdo_trab4,ms_act
          FROM "informix".sd_maesdosrev
         WHERE folio = o_folio;

        INSERT INTO "informix".sd_maesdos
         VALUES(ms_empresa,ms_num_credito, ms_fecha_ult_mov, ms_sdo_int_anticip,
               ms_sdo_int_ant_dev, ms_sdo_intereses, ms_sdo_dia_ant_int,
               ms_sdo_mes_ant_int, ms_sdo_acum_mes_int, ms_sdo_retenido,
               ms_sdo_acum_cap_int, ms_sdo_exig_int, ms_sdo_no_exig,
               ms_provision_normal, ms_dias_acum_int, ms_sdo_moratorio,
               ms_sdo_dia_ant_mor, ms_sdo_mes_ant_mor, ms_sdo_contab_mora,
               ms_dias_acum_mora, ms_sdo_capital, ms_sdo_cap_insoluto,
               ms_sdo_dia_ant_cap, ms_sdo_mes_ant_cap, ms_sdo_acum_mes_cap,
               ms_mto_capitalizado, ms_mto_ministra_cap, ms_cargos_dia_cap,
               ms_abonos_dia_cap, ms_cargos_mes_cap, ms_abonos_mes_cap,
               ms_dias_acum_cap, ms_monto_vencido, ms_mto_venc_trasp,
               ms_monto_financiado, ms_monto_reservado, ms_sdo_acum_vencido,
               ms_dias_acum_intper, ms_sdo_global_int, ms_sdo_acum_intper,
               ms_monto_otorgado, ms_provi_venc_normal, ms_provi_venc_anticip,
               ms_cap_tras_no_venci, ms_mto_venc_int, ms_mto_venc_tra_int,
               ms_mto_finan_vdo, ms_mto_reser_int, ms_mto_fin_ven_trasp,
               ms_mto_fin_vig_trasp, ms_int_tra_no_exig, ms_sdo_trab4,ms_act);

        -- RECUPERA DETCOMI
        FOREACH
        SELECT empresa, cod_comis, num_credito, fecha_alta, fecha_pago,
               monto_com, monto_pag, apli_factor, estado_com, num_solicitud,
               user_insert, fecha_insert
          INTO dc_empresa, dc_cod_comis, dc_num_credito, dc_fecha_alta,
               dc_fecha_pago, dc_monto_com, dc_monto_pag, dc_apli_factor,
               dc_estado_com, dc_num_solicitud, dc_user_insert,
               dc_fecha_insert
          FROM "informix".sd_detcomirev
          WHERE folio = o_folio
          ORDER BY fecha_alta

           let o_folio=o_folio;
           INSERT INTO "informix".sd_detcomi
                        (empresa, cod_comis, num_credito, fecha_alta,
                        fecha_pago, monto_com, monto_pag,
                        apli_factor, estado_com, num_solicitud,
                        user_insert, fecha_insert)
           VALUES(dc_empresa, dc_cod_comis, dc_num_credito, dc_fecha_alta,
                        dc_fecha_pago, dc_monto_com, dc_monto_pag,
                        dc_apli_factor, dc_estado_com, dc_num_solicitud,
                        dc_user_insert, dc_fecha_insert);

        END FOREACH;
        -- Recupera Amortiza Credito
        FOREACH
         SELECT empresa, num_credito, fecha_cuota, tipo_cuota,
                capital_mto_cuota, capital_debe, capital_pagado, capital_status,
                capital_status_ant, capital_fecha_pago, interes_debe,
                interes_pagado, interes_status, interes_status_ant,
                interes_fecha_pago, iva_debe, iva_pagado, iva_status,
                iva_status_ant, iva_fecha_pago,
                mora_provi_ordi, mora_provi_cope, mora_sdo_ordi,
                mora_sdo_ordi_pag, mora_sdo_cope, mora_sdo_cope_pag,
                mora_bonificado, mora_status, mora_iva_debe, mora_iva_pagado,
                mora_iva_status, mora_iva_fecha_pago, num_pago,
                campo_trabajo1, campo_trabajo2, campo_trabajo3,
                campo_trabajo4
           INTO am_empresa, am_num_credito, am_fecha_cuota, am_tipo_cuota,
                am_capital_mto_cuota, am_capital_debe, am_capital_pagado,
                am_capital_status, am_capital_status_ant, am_capital_fecha_pago,
                am_interes_debe, am_interes_pagado, am_interes_status,
                am_interes_status_ant, am_interes_fecha_pago, am_iva_debe,
                am_iva_pagado, am_iva_status, am_iva_status_ant,
                am_iva_fecha_pago, am_mora_provi_ordi, am_mora_provi_cope,
                am_mora_sdo_ordi, am_mora_sdo_ordi_pag, am_mora_sdo_cope,
                am_mora_sdo_cope_pag, am_mora_bonificado, am_mora_status,
                am_mora_iva_debe, am_mora_iva_pagado, am_mora_iva_status,
                am_mora_iva_fecha_pago, am_num_pago, am_campo_trabajo1,
                am_campo_trabajo2, am_campo_trabajo3, am_campo_trabajo4
           FROM "informix".sd_amortiza_creditorev
          WHERE folio = o_folio
          ORDER BY fecha_cuota

                INSERT INTO "informix".sd_amortiza_credito
                VALUES(
                 am_empresa, am_num_credito, am_fecha_cuota, am_tipo_cuota,
                 am_capital_mto_cuota, am_capital_debe, am_capital_pagado,
                 am_capital_status,am_capital_status_ant,am_capital_fecha_pago,
                 am_interes_debe, am_interes_pagado, am_interes_status,
                 am_interes_status_ant, am_interes_fecha_pago, am_iva_debe,
                 am_iva_pagado, am_iva_status, am_iva_status_ant,
                 am_iva_fecha_pago, am_mora_provi_ordi, am_mora_provi_cope,
                 am_mora_sdo_ordi, am_mora_sdo_ordi_pag, am_mora_sdo_cope,
                 am_mora_sdo_cope_pag, am_mora_bonificado, am_mora_status,
                 am_mora_iva_debe, am_mora_iva_pagado, am_mora_iva_status,
                 am_mora_iva_fecha_pago, am_num_pago, am_campo_trabajo1,
                 am_campo_trabajo2, am_campo_trabajo3, am_campo_trabajo4);

        END FOREACH

        -- Recupera Maecred Anexo
        SELECT empresa,          num_credito,       dia_corte,
               dias_gracia_mora, tp_dias_calc_mora, dias_fecha_max_pago,
               tp_dias_fecha_pago,cod_tasa_base_cte,factor_sobretasa_cte,
               sobretasa_cte,    tasa_interes_cte,  fecha_vencto,
               prox_fecha_pago,  fecha_proceso,     fecha_ult_pago
          INTO mx_empresa,       mx_num_credito,    mx_dia_corte,
               mx_dias_gracia_mora,mx_tp_dias_calc_mora,mx_dias_fecha_max_pago,
               mx_tp_dias_fecha_pago,mx_cod_tasa_base_cte,
               mx_factor_sobretasa_cte,
               mx_sobretasa_cte, mx_tasa_interes_cte, mx_fecha_vencto,
               mx_prox_fecha_pago, mx_fecha_proceso , mx_fecha_ult_pago
          FROM "informix".sd_maecredanexorev
          WHERE folio = o_folio;

        INSERT INTO "informix".sd_maecredanexo(
               empresa,num_credito, dia_corte,
               dias_gracia_mora, tp_dias_calc_mora, dias_fecha_max_pago,
               tp_dias_fecha_pago,cod_tasa_base_cte,factor_sobretasa_cte,
               sobretasa_cte,    tasa_interes_cte,  fecha_vencto,
               prox_fecha_pago,  fecha_proceso,     fecha_ult_pago)
        VALUES (mx_empresa,mx_num_credito,mx_dia_corte,
                 mx_dias_gracia_mora,    mx_tp_dias_calc_mora,
                 mx_dias_fecha_max_pago, mx_tp_dias_fecha_pago,
                 mx_cod_tasa_base_cte,   mx_factor_sobretasa_cte,
                 mx_sobretasa_cte,       mx_tasa_interes_cte,
                 mx_fecha_vencto,        mx_prox_fecha_pago,
                 mx_fecha_proceso ,      mx_fecha_ult_pago)        ;
		--SE VALIDA PARA CAMBIAR EL FOLIO QUE REGISTRO LOS MOVIMIENTOS SOLO CREDISOLUCIONES
		IF sp_num_credisolucion IS NOT NULL THEN
			DELETE FROM "informix".sd_secpago
			WHERE folio_suc = o_folio;
			LET o_folio = sp_folio_suc;
		END IF;

        -- BORRA TRANSACCIONES DE MOVDIA
        DELETE FROM "informix".sd_movdia
         WHERE folio_suc = o_folio
           AND sucursal  = o_sucursal
           AND codigo_ref <> 1;


        DELETE FROM "informix".sd_secpago
         WHERE folio_suc = o_folio;
        -- MARCA COMO REVERSADA LA TRANSACCION DE ENCABEZADO
        UPDATE "informix".sd_movdia SET reversado = "S"
         WHERE folio_suc = o_folio
           AND sucursal  = o_sucursal;

-- jom ini agrega transaccion original de reversion

        select codigo_fun , codigo_ref, fecha_mov
          into vcodigo_fun , vCodigoRef, vfecha_mov
          from "informix".sd_movdia
         WHERE folio_suc = o_folio
           AND sucursal  = o_sucursal
           and secuencia = (select max(secuencia)
                              from "informix".sd_movdia
                             WHERE folio_suc = o_folio
                               AND sucursal  = o_sucursal);


         select reversable
           into vreversable
           from bdinteg:"informix".si_transacc a,
                "informix".sd_transfun b
          where a.empresa = b.empresa
            and a.numero = b.transacc
            and b.codigo_fun = vcodigo_fun
            and b.codigo_ref = 1
			and a.sistema ="06";  --se agrega el sistema 06

         if (vreversable = 'S') then
             insert into "informix".sd_movdia
             select empresa,
                    0,
                    fecha_mov,
                    current,
                    sucursal,
                    num_credito,
                    plaza,
                    transacc_suc,
                    O_USUARIO,
                    monto,
                    codigo_fun,
                    99,
                    divisa,
                    reversado,
                    folio_suc,
                    num_producto,
                    nro_tarjeta,
                    referencia,
                    tipo_cambio,
                    monto_dls,
                    suc_origen,
                    rfc_comer,
                    referencia23,
					current
               from "informix".sd_movdia
             WHERE folio_suc = o_folio
               AND sucursal  = o_sucursal
               and codigo_fun= vcodigo_fun;
         end if;

-- jom ini agrega transaccion original de reversion

-- ****************************************************** FIN DEL PROGRAMA
IF v_codret = "00000" THEN

  EXECUTE PROCEDURE sp_graba_indicador(o_empresa, vnum_credito,0, vtrannro,vcodigo_fun, vCodigoRef, vfecha_mov,o_folio,0,0,3)
  INTO vcod_ret;

  -- EVALUACION OBJETIVA marcar como reversado pago registrado anteriormente en tabla - Ini
    UPDATE bdicobranza:cb_evaluacion_objetiva set reversado = 'S' where empresa = o_empresa and folio_suc = o_folio;
  -- EVALUACION OBJETIVA marcar como reversado pago registrado anteriormente en tabla - Fin

END IF;

END
 COMMIT WORK;
 IF (wBegin = "S") THEN
    BEGIN WORK;
 END IF;
 RETURN v_codret;
END PROCEDURE
DOCUMENT
'MODIFICO : Jesus Manuel Aguilar Heredia ',
'DESCRIPCION: Se modifica validacion de transacciones para mandar llamar el procedimiento reversion_td',
'FECHA : Julio de 2011',
'VERSION: 20110725.0938',
'BD    : BDICRED',
'MODIFICO : Jesus Manuel Bustamante Lujano',
'DESCRIPCION: Se modifica validacion de transacciones para recuperar PROMOCION CREDITO	',
'FECHA : 14-11-2016',
'VERSION: 20161116.1020',
'BD    : BDICRED',
'----------------------------------------------------------------------------',
'Descripcion : se modifica consulta de numero de credito en sd_movdia de credisoluciones por duplicidad de registros',
'Modifico    : 95992243 - Trinidad Hernandez',
'Fecha       : 07/02/2017',
'BD          : bdicred',
'----------------------------------------------------------------------------',
'Descripcion : Se modifica para obtener vCodTipCred = "05" y poder ejecutar el procedimiento reversioncrd',
'Modifico    : 95451706 - Efrain Miranda',
'Fecha       : 08/03/2017',
'BD          : bdicred';

CREATE PROCEDURE "informix".sp_depura_sd_amortizacrd()
--EXECUTE PROCEDURE sp_depura_sd_amortizacrd();
RETURNING 
CHAR(6),     -- codigo de retorno
CHAR(150);   -- mensaje

-- Modificacion -> Se hardcodea la fecha por motivo de que no corre con la variable dFechaDepura

DEFINE cCodRet      CHAR(6); 
DEFINE cMensaje     CHAR(150); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE Error_Info   VARCHAR(80);
DEFINE dFechaDepura DATE;
DEFINE sHoraInicial	SMALLINT;
DEFINE sHoraFinal	SMALLINT;
DEFINE cHoraInicial		CHAR(8);
DEFINE cHoraFinal		CHAR(8);
DEFINE sMinutoInicial	SMALLINT;
DEFINE sMinutoFinal		SMALLINT;
DEFINE sHorasProceso	SMALLINT;
DEFINE iCuentasProcesadas	INTEGER;
DEFINE iCount_sd_amortiza_credito_old	INTEGER;
DEFINE cProceso		CHAR(04);
DEFINE P_COD_RET    	VARCHAR(6);


LET cCodRet      = '000000';
LET cMensaje     = '';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET Error_Info   = '';
LET vNumCred     = '';
LET vNumCredAux  = '';
LET dFechaDepura = date(1);
LET sHoraInicial = 0;
LET sHoraFinal	 = 0;
LET cHoraInicial	= '';
LET cHoraFinal		= '';
LET sMinutoInicial	= 0;
LET sMinutoFinal	= 0;
LET sHorasProceso	= 0;
LET iCuentasProcesadas	= 0;
LET iCount_sd_amortiza_credito_old	= 0;
LET cProceso		= '0008';
LET P_COD_RET   	= '000000';


-- SET ISOLATION TO COMMITTED READ LAST COMMITTED;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, Error_Info
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;	
            LET cMensaje = 'Error --> '||Error_Info||'	'||vNumCred;
			CALL "informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '02') RETURNING P_COD_RET;			
            RETURN cCodRet,cMensaje;
        END IF;
    END EXCEPTION;

--    SET DEBUG FILE TO 'sp_depura_sd_amortizacrd.out';
--    TRACE ON;

    CALL "informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '01') RETURNING P_COD_RET;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraInicial from sysmaster:sysshmvals;

/*	LET sHoraInicial = SUBSTR(cHoraInicial,1,2);
	LET sMinutoInicial = SUBSTR(cHoraInicial,4,2);*/
	
    SELECT num_credito
      INTO vNumCredAux
      FROM "informix".sd_param_movhis_dep
     where proceso = 18;

    IF vNumCredAux = '' OR vNumCredAux IS NULL THEN 
       --LET vNumCredAux = '0'; 
       INSERT INTO "informix".sd_param_movhis_dep VALUES(18,'0');
    END IF;

--    select fecha_insert
--      into dFechaDepura
--    from sd_param
--    where empresa = '001'
--    and cod_param = '800'; 

/*    SELECT valor
      INTO dFechaDepura
      FROM "informix".sd_param
     WHERE cod_param = '115';

    IF dFechaDepura IS NULL THEN 
		INSERT INTO "informix".sd_param(empresa, cod_param, descripcion, valor, user_insert, fecha_insert) 
			VALUES('001', '115', 'FECHA DEPURACION AMORTIZA_CREDITO CUENTAS ACTIVAS', '12/31/2018', user, TODAY);
			
		--LET dFechaDepura = mdy('12','31','2018');
	END IF;

	SELECT valor
      INTO sHorasProceso
      FROM "informix".sd_param
     WHERE cod_param = '116';

	 IF sHorasProceso IS NULL THEN 
		INSERT INTO "informix".sd_param(empresa, cod_param, descripcion, valor, user_insert, fecha_insert) 
			VALUES('001', '116', 'PARAMETRO DE HORAS A PROCESAR CUENTAS ACTIVAS', '5', user, TODAY);

		--LET sHorasProceso = 5;
    END IF;
*/
/*       SELECT num_credito
           FROM "informix".sd_maecredcrd
           WHERE empresa  = '001' 
            AND num_credito > vNumCredAux
			AND status_cred IN ('AA','BA','BT')*/

       SELECT a.num_credito
		FROM bdicred:sd_maecredcrd a
		INNER JOIN bdicred:sd_maecredanexocrd b ON b.empresa = a.empresa AND b.num_credito = a. num_credito AND b.fecha_proceso <= mdy('12','31','2020')
		WHERE a.empresa='001'
		AND a.num_credito > vNumCredAux
		INTO TEMP cuentas_activascrd WITH NO LOG;
		
		UPDATE STATISTICS MEDIUM FOR TABLE cuentas_activascrd;
		
	FOREACH WITH HOLD	

		SELECT TRIM(num_credito)
           INTO vNumCred 
        FROM cuentas_activascrd
		ORDER BY num_credito ASC

	   LET iCuentasProcesadas = iCuentasProcesadas + 1;
	   
        BEGIN WORK;

            insert into "informix".sd_amortiza_creditocrd_new_2021
            select * 
--SELECT empresa, num_credito, fecha_cuota, tipo_cuota, capital_mto_cuota, capital_debe, capital_pagado, capital_status, capital_status_ant, capital_fecha_pago, interes_debe, interes_pagado, interes_status, interes_status_ant, interes_fecha_pago, iva_debe, iva_pagado, iva_status, iva_status_ant, iva_fecha_pago, mora_provi_ordi, mora_provi_cope, mora_sdo_ordi, mora_sdo_ordi_pag, mora_sdo_cope, mora_sdo_cope_pag, mora_bonificado, mora_status, mora_iva_debe, mora_iva_pagado, mora_iva_status, mora_iva_fecha_pago, num_pago, campo_trabajo1, campo_trabajo2, campo_trabajo3, campo_trabajo4			
			from "informix".sd_amortiza_creditocrd
            where empresa = '001'
            and num_credito = vNumCred;

            DELETE FROM "informix".sd_amortiza_creditocrd
            where empresa = '001'
            and num_credito = vNumCred;

			LET iCount_sd_amortiza_credito_old	= iCount_sd_amortiza_credito_old + 1;
						
			UPDATE "informix".sd_param_movhis_dep
			SET num_credito = vNumCred
			where proceso = 18;

        COMMIT WORK;

/*		SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraFinal from sysmaster:sysshmvals;

		LET	sHoraFinal = SUBSTR(cHoraFinal,1,2);
		LET	sMinutoFinal = SUBSTR(cHoraFinal,4,2);
		LET	sHoraFinal = sHoraFinal - sHoraInicial;

		IF sHoraFinal >= sHorasProceso AND sMinutoFinal > sMinutoInicial THEN
			EXIT FOREACH;
		END IF;*/
		
    END FOREACH;
	drop table cuentas_activascrd;

	LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iCuentasProcesadas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_amortiza_creditocrd_new_2021 : ' ||iCount_sd_amortiza_credito_old;
	CALL "informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = 'El proceso DEPURA CUENTAS CANCELADAS termino exitosamente. Cuentas procesadas ' || iCuentasProcesadas;

	CALL "informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '03') RETURNING P_COD_RET;
	
    RETURN cCodRet,cMensaje;

    END
END PROCEDURE;