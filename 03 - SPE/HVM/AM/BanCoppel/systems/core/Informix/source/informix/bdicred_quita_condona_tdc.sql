CREATE PROCEDURE "informix".quita_condona_tdc(p_Empresa  CHAR(3),
                           p_NumCredito             CHAR(20),
                           p_TpPago                 SMALLINT, 
                           p_Usuario                CHAR(8),
                           p_Sucursal               CHAR(4),
                           p_Folio                  LIKE sd_movdia.Folio_Suc,
                           p_Transacc               LIKE sd_movdia.Transacc_Suc,
                           p_MontoEfe               MONEY(14,2)
						   )
  --Valores a Regresar
      RETURNING CHAR(5)
			 
	DEFINE CodRet                	CHAR(5);
	DEFINE sql_err               	SMALLINT;
	DEFINE isam_err              	SMALLINT;
	DEFINE error_info            	CHAR(40);
	DEFINE nRows                 	SMALLINT;
	DEFINE Mensaje               	CHAR(80);
	DEFINE wBegin                	CHAR(1);
		
	
	DEFINE g_Remanente    			MONEY(14,2);
	DEFINE g_IntMoraCob   			MONEY(14,2);
	DEFINE g_IntVencCob   			MONEY(14,2);
	DEFINE g_CapVencCob   			MONEY(14,2);
	DEFINE g_IntVigCob    			MONEY(14,2);
	DEFINE g_CapVigCob    			MONEY(14,2);
	DEFINE g_Impuesto     			MONEY(14,2);
	DEFINE g_Comision     			MONEY(14,2);
	DEFINE g_Seguro       			MONEY(14,2);
			 
---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general   
	DEFINE csg_codigo_ret			CHAR(6);
	DEFINE csg_mensaje_ret			CHAR(80);
	DEFINE csg_num_credito			CHAR(20);
	DEFINE csg_cod_tipcred			CHAR(2);
	DEFINE cStatus					CHAR(2);
	DEFINE csg_fec_origen			DATE;
	DEFINE csg_fec_prox_pago		DATE;
	DEFINE csg_pago_min				MONEY(18,2);
	DEFINE csg_fec_ult_pago			DATE;
	DEFINE csg_plazo				INTEGER;
	DEFINE csg_pagos_realizados		INTEGER;
	DEFINE csg_linea_otorgada		MONEY(18,2);
	DEFINE csg_tasa_interes			DECIMAL(9,6);
	DEFINE csg_tasa_moratorios		DECIMAL(9,6);
	DEFINE csg_monto_sbc			DECIMAL(14,2);
	DEFINE csg_cap_vig				MONEY(18,2);
	DEFINE csg_cap_trans			MONEY(18,2);
	DEFINE csg_cap_vdo_exig			MONEY(18,2);
	DEFINE csg_cap_vdo_no_exig		MONEY(18,2);
	DEFINE csg_sdo_act_total_cap	MONEY(18,2);
	DEFINE csg_int_vig				MONEY(18,2);
	DEFINE csg_int_vdo				MONEY(18,2); 
	DEFINE csg_int_moratorios		MONEY(18,2); 
	DEFINE csg_iva_int_vdo			MONEY(18,2); 
	DEFINE csg_iva_int_moratorios	MONEY(18,2); 	
	DEFINE csg_int_mes				MONEY(18,2);
	DEFINE csg_sdo_act_total_int	MONEY(18,2);
	DEFINE csg_iva_int_vig			MONEY(18,2);
	DEFINE vQuitaEscVenc 			CHAR(1); 	 
	DEFINE v_MoraProvi              MONEY(18,2); 
	DEFINE v_MoraIva                MONEY(18,2); 
	DEFINE vIntVencido              MONEY(18,2); 
	DEFINE vIntMoratorio            MONEY(18,2); 
	DEFINE vDescuentoQuita          MONEY(18,2); 
	DEFINE vPorcQuita               MONEY(18,2); 
	DEFINE csg_iva_int_mes			MONEY(18,2);
	DEFINE csg_sdo_act_total_iva	MONEY(18,2);
	DEFINE csg_com_pend				MONEY(18,2);
	DEFINE csg_iva_com				MONEY(18,2);
	DEFINE csg_sdo_retenido			MONEY(18,2);
	DEFINE csg_tot_liquidacion		MONEY(18,2);
	DEFINE csg_int_devengado		MONEY(18,2);
	DEFINE csg_iva_int_devengado	MONEY(18,2);
	DEFINE csg_linea_disp			MONEY(18,2);
	DEFINE csg_pagos_vdos			MONEY(18,2);
	DEFINE csg_desc_status_cred		CHAR(60);
	DEFINE csg_id_bloqueo_cred		INTEGER;
	DEFINE csg_bloqueo_cta			CHAR(60);
	DEFINE csg_id_causa_bloq_cred	CHAR(3);
	DEFINE csg_causa_bloqueo_cta	CHAR(50);
	DEFINE csg_id_sit_esp_cte		CHAR(1);
	DEFINE csg_id_causa_esp_cte		INTEGER;
	DEFINE csg_sit_esp_cte			CHAR(75);
	DEFINE csg_id_sit_esp_cred		CHAR(1);
	DEFINE csg_id_causa_esp_cred	INTEGER;
	DEFINE csg_sit_esp_cred			CHAR(75);
	DEFINE csg_dMoraBase        DECIMAL(18,2);
	DEFINE csg_dMoraCopete      DECIMAL(18,2);
	DEFINE csg_dIvamoraBase     DECIMAL(18,2);
	DEFINE csg_dIvaMoraCopete   DECIMAL(18,2);
	DEFINE vMontoTransaccCapitalVdo DECIMAL(18,2);
	DEFINE vMontoTransaccCancelaLinea DECIMAL(18,2);
	DEFINE vaux1_cap_vdo_exig                DECIMAL(18,2);
	DEFINE vaux2_cap_vdo_no_exig             DECIMAL(18,2);
	DEFINE vaux3_sdo_cap_insol               DECIMAL(18,2);
	DEFINE CodRetqc              CHAR(5);
   
	DEFINE vMontoCondonado  	DECIMAL(18,2);
	DEFINE vMontoQuita     		DECIMAL(18,2);
	DEFINE vIndProceso     		CHAR(1);
	DEFINE v_SdoCapInsoluto   	MONEY(14,2);
	
	DEFINE monto_condona		DECIMAL(18,2);
	DEFINE monto_capital		DECIMAL(18,2);
	DEFINE quita_capital		DECIMAL(18,2);
	DEFINE numProducto			CHAR(4);
	DEFINE vDivisa				CHAR(2);
	DEFINE cancela				INT;
	DEFINE vtarjeta         	CHAR(20);
	DEFINE cproduto         	VARCHAR(3);
	DEFINE vFechaVigencia		DATE;
	DEFINE vfecha_hoy            DATE;
	DEFINE vmonto_quita_condona	DECIMAL(18,2);

--		SET DEBUG FILE TO "/RESPALDOSNEW/quita_condona_tdc.out";
--		TRACE ON;

	LET CodRet						= '000';
	LET g_Remanente    				= 0;
	LET g_IntMoraCob   				= 0;
	LET g_IntVencCob   				= 0;
	LET g_CapVencCob   				= 0;
	LET g_IntVigCob    				= 0;
	LET g_CapVigCob    				= 0;
	LET g_Impuesto     				= 0;
	LET g_Comision     				= 0;
	LET g_Seguro       				= 0;
		
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	LET csg_codigo_ret				= "000000";
	LET csg_mensaje_ret				= "";
	LET csg_num_credito				= "";
	LET csg_cod_tipcred				= "";
	LET cStatus						= "";
	LET csg_fec_origen				= DATE(1);
	LET csg_fec_prox_pago			= DATE(1);
	LET csg_pago_min				= 0.0;
	LET csg_fec_ult_pago			= DATE(1);
	LET csg_plazo					= 0;
	LET csg_pagos_realizados		= 0;
	LET csg_linea_otorgada			= 0.0;
	LET csg_tasa_interes			= 0.0;
	LET csg_tasa_moratorios			= 0.0;
	LET csg_monto_sbc				= 0.0;
	LET csg_cap_vig					= 0.0;
	LET csg_cap_trans				= 0.0;
	LET csg_cap_vdo_exig			= 0.0;
	LET csg_cap_vdo_no_exig			= 0.0;
	LET csg_sdo_act_total_cap		= 0.0;
	LET csg_int_vig					= 0.0;
	LET csg_int_vdo					= 0.0;
	LET csg_int_moratorios			= 0.0;
	LET csg_int_mes					= 0.0;
	LET csg_sdo_act_total_int		= 0.0;
	LET csg_iva_int_vig				= 0.0;
	LET csg_iva_int_vdo				= 0.0;
	LET csg_iva_int_moratorios		= 0.0;
	LET csg_iva_int_mes				= 0.0;
	LET csg_sdo_act_total_iva		= 0.0;
	LET csg_com_pend				= 0.0;
	LET csg_iva_com					= 0.0;
	LET csg_sdo_retenido			= 0.0;
	LET csg_tot_liquidacion			= 0.0;
	LET csg_int_devengado			= 0.0;
	LET csg_iva_int_devengado		= 0.0;
	LET csg_linea_disp				= 0.0;
	LET csg_pagos_vdos				= 0.0;
	LET csg_desc_status_cred		= "";
	LET csg_id_bloqueo_cred			= 0;
	LET csg_bloqueo_cta				= "";
	LET csg_id_causa_bloq_cred		= "";
	LET csg_causa_bloqueo_cta		= "";
	LET csg_id_sit_esp_cte			= "";
	LET csg_id_causa_esp_cte		= 0;
	LET csg_sit_esp_cte				= "";
	LET csg_id_sit_esp_cred			= "";
	LET csg_id_causa_esp_cred		= 0;
	LET csg_sit_esp_cred			= "";
	LET csg_dMoraBase               = "";
	LET csg_dMoraCopete             = "";
	LET csg_dIvamoraBase            = "";
	LET csg_dIvaMoraCopete          = "";   
	
	LET vMontoCondonado  	= 0;
	LET vMontoQuita     		= 0;
	LET vIndProceso     		= '';
	LET v_SdoCapInsoluto   	= 0;
	LET monto_condona		= 0;
	LET monto_capital		= 0;
	LET quita_capital		= 0;
	LET numProducto			= 0;
	LET vDivisa				= 0;
	LET cancela				= 0;
	LET vtarjeta         	= '';
	LET cproduto         	= '';
	LET vFechaVigencia		= DATE (1);	
	LET vfecha_hoy   	= DATE (1);
	LET vmonto_quita_condona	= 0;
	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT fecha_hoy INTO vfecha_hoy FROM "informix".sd_fechas;
	
	SELECT monto_condonado, mto_quita, indicador_proceso, fecha_negociacion
		INTO  vMontoCondonado, vMontoQuita,  vIndProceso, vFechaVigencia
	FROM  bdicred:sd_bitacora_quitacondonacion
		WHERE num_credito = p_NumCredito
		AND estatus_proceso = 'PR';
		
		
		IF vFechaVigencia IS NULL THEN LET vFechaVigencia = date(1); END IF;
		IF vMontoCondonado IS NULL OR vMontoCondonado = ''  THEN LET vMontoCondonado = 0; END IF;
		IF vMontoQuita IS NULL OR vMontoQuita = '' THEN LET vMontoQuita = 0; END IF;
		IF vIndProceso IS NULL OR vIndProceso = '' THEN LET vIndProceso = ''; END IF;

		LET vmonto_quita_condona = vMontoCondonado + vMontoQuita;
		
		IF vIndProceso <> '' THEN
			--Se valida si el credito entra en el programa de Condonacion y Quitas
			IF (p_MontoEfe >= vmonto_quita_condona )	 
				AND vfecha_hoy <= vFechaVigencia 	THEN

				EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(p_Empresa,p_NumCredito) 
					INTO  csg_codigo_ret,csg_mensaje_ret,csg_num_credito,csg_cod_tipcred,csg_fec_origen,csg_fec_prox_pago,csg_pago_min,
					csg_fec_ult_pago,csg_plazo,csg_pagos_realizados,csg_linea_otorgada,csg_tasa_interes,csg_tasa_moratorios,
					csg_monto_sbc,csg_cap_vig,csg_cap_trans,csg_cap_vdo_exig,csg_cap_vdo_no_exig,csg_sdo_act_total_cap,csg_int_vig,
					csg_int_vdo,csg_int_moratorios,csg_int_mes,csg_sdo_act_total_int,csg_iva_int_vig,csg_iva_int_vdo,csg_iva_int_moratorios,
					csg_iva_int_mes,csg_sdo_act_total_iva,csg_com_pend,csg_iva_com,csg_sdo_retenido,csg_tot_liquidacion,csg_int_devengado,
					csg_iva_int_devengado,csg_linea_disp,csg_pagos_vdos,csg_desc_status_cred,csg_id_bloqueo_cred,csg_bloqueo_cta,
					csg_id_causa_bloq_cred,csg_causa_bloqueo_cta,csg_id_sit_esp_cte,csg_id_causa_esp_cte,csg_sit_esp_cte,csg_id_sit_esp_cred,
					csg_id_causa_esp_cred,csg_sit_esp_cred;
				
					--- valida si el pago sobrepasa el total a liquidar
				IF p_MontoEfe < csg_tot_liquidacion THEN
					IF csg_sdo_act_total_cap > 0 THEN
					
						UPDATE "informix".sd_bitacora_quitacondonacion
							SET saldo_tot_liquidar = csg_tot_liquidacion, copete_moratorio = NVL(csg_int_moratorios,0) + NVL(csg_iva_int_moratorios,0), 
							cap_vigente_cq = NVL(csg_cap_vig,0) + NVL(csg_cap_trans,0), cap_vencido_cq = NVL(csg_cap_vdo_exig,0) + NVL(csg_cap_vdo_no_exig,0), 
							int_vigente_cq =  csg_int_vig, int_vencido_cq = csg_int_vdo, int_moratorio = csg_int_moratorios, 
							iva_int_vigente_cq =  csg_iva_int_vig, iva_int_vencido_cq = csg_iva_int_vdo 			
						WHERE num_credito = p_NumCredito;
					
						LET monto_condona = csg_tot_liquidacion - p_MontoEfe;
						LET monto_capital = csg_tot_liquidacion - monto_condona;
														
						--- si el monto efectivo es mayor a capital no hay quita, solo se condonana moratorios y lo que alcance de vencidos.
						IF p_MontoEfe >= csg_sdo_act_total_cap THEN
						
							LET monto_condona = csg_tot_liquidacion - p_MontoEfe;
							IF monto_condona > 0 THEN	---- para casos de vigente no hay que condonar
								---- aplica pago de accesorios y capital que logre pagar
								CALL "informix".Principal(p_Empresa,p_NumCredito,p_TpPago,monto_condona,
										p_Usuario,p_Sucursal,p_Folio,'8638')	--- cambiar transacciÃ³n.. para condonaciones de quitas
										returning CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
											   g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;	
							END IF;

							IF vIndProceso = 'Q' THEN
								LET cancela = 1;
							END IF;
						
						ELSE	
							--- se obtiene accesorios por diferencia, no alcanza el pago se condona al 100%
							LET monto_condona = csg_tot_liquidacion - csg_sdo_act_total_cap;
							IF monto_condona > 0 THEN	---- para casos de vigente no hay que condonar
								CALL "informix".Principal(p_Empresa,p_NumCredito,p_TpPago,monto_condona,
										p_Usuario,p_Sucursal,p_Folio,'8638')	--- cambiar transacciÃ³n.. para condonaciones de quitas
										returning CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
											   g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;	
							END IF;	

							--- se obtiene la diferencia de capital que no cubre el pago.
							IF vIndProceso = 'Q' THEN
								LET quita_capital = csg_sdo_act_total_cap - p_MontoEfe;
								LET cancela = 1;
							END IF;
						
						END IF;
		
					END IF;
		
				END IF; 	--- csg_tot_liquidacion			
			ELSE
				LET CodRet = '001';
			END IF;
		END IF;

   RETURN CodRet;
END PROCEDURE;