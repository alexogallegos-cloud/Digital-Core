CREATE PROCEDURE "informix".sp_domi_proximo_pago(pTipoPago CHAR(1), pEmpresa CHAR(3), pNumCredito CHAR(12), pUserStatus CHAR(8), pFolioActivacion CHAR(20), pTipoDomi CHAR(2))
	RETURNING	CHAR (5) 		AS CodRet, --Codigo de Retorno
				MONEY(18,2) 	AS MontoPago; --Monto a pagar
	
--Declaracion de  Variables
	DEFINE sql_err 				INTEGER;
	DEFINE cCodRet				CHAR(5);
	DEFINE dPago				DECIMAL(18,2);
	DEFINE dMontoFijo			DECIMAL(18,2);
	DEFINE dMontoMaximo			DECIMAL(18,2);
	DEFINE cCodret2				CHAR(5);
	DEFINE cMensajeRespuesta 	CHAR (110);
	DEFINE dSaldoActivo			MONEY(18,2);
	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDIMIENTO DE sp_consulta_saldos_general
	DEFINE cCsg_codigo_ret			CHAR(6);
	DEFINE cCsg_mensaje_ret			CHAR(80);
	DEFINE cCsg_num_credito			CHAR(20);
	DEFINE cCsg_cod_tipcred			CHAR(2);
	DEFINE dtCsg_fec_origen			DATE;
	DEFINE dtCsg_fec_prox_pago		DATE;
	DEFINE mCsg_pago_min			MONEY(18,2);
	DEFINE dtCsg_fec_ult_pago		DATE;
	DEFINE iCsg_plazo				INTEGER;
	DEFINE iCsg_pagos_realizados	INTEGER;
	DEFINE mCsg_linea_otorgada		MONEY(18,2);
	DEFINE mCsg_tasa_interes		DECIMAL(9,6);
	DEFINE dCsg_tasa_moratorios		DECIMAL(9,6);
	DEFINE dCsg_monto_sbc			DECIMAL(14,2);
	DEFINE mCsg_cap_vig				MONEY(18,2);
	DEFINE mCsg_cap_trans			MONEY(18,2);
	DEFINE mCsg_cap_vdo_exig		MONEY(18,2);
	DEFINE mCsg_cap_vdo_no_exig		MONEY(18,2);
	DEFINE mCsg_sdo_act_total_cap	MONEY(18,2);
	DEFINE mCsg_int_vig				MONEY(18,2);
	DEFINE mCsg_int_vdo				MONEY(18,2);
	DEFINE mCsg_int_moratorios		MONEY(18,2);
	DEFINE mCsg_int_mes				MONEY(18,2);
	DEFINE mCsg_sdo_act_total_int	MONEY(18,2);
	DEFINE mCsg_iva_int_vig			MONEY(18,2);
	DEFINE mCsg_iva_int_vdo			MONEY(18,2);
	DEFINE mCsg_iva_int_moratorios	MONEY(18,2);
	DEFINE mCsg_iva_int_mes			MONEY(18,2);
	DEFINE mCsg_sdo_act_total_iva	MONEY(18,2);
	DEFINE mCsg_com_pend			MONEY(18,2);
	DEFINE mCsg_iva_com				MONEY(18,2);
	DEFINE mCsg_sdo_retenido		MONEY(18,2);
	DEFINE mCsg_tot_liquidacion		MONEY(18,2);
	DEFINE mCsg_int_devengado		MONEY(18,2);
	DEFINE mCsg_iva_int_devengado	MONEY(18,2);
	DEFINE mCsg_linea_disp			MONEY(18,2);
	DEFINE mCsg_pagos_vdos			MONEY(18,2);
	DEFINE cCsg_desc_status_cred	CHAR(60);
	DEFINE iCsg_id_bloqueo_cred		INTEGER;
	DEFINE cCsg_bloqueo_cta			CHAR(60);
	DEFINE cCsg_id_causa_bloq_cred	CHAR(3);
	DEFINE cCsg_causa_bloqueo_cta	CHAR(50);
	DEFINE cCsg_id_sit_esp_cte		CHAR(1);
	DEFINE iCsg_id_causa_esp_cte	INTEGER;
	DEFINE cCsg_sit_esp_cte			CHAR(75);
	DEFINE cCsg_id_sit_esp_cred		CHAR(1);
	DEFINE iCsg_id_causa_esp_cred	INTEGER;
	DEFINE cCsg_sit_esp_cred		CHAR(75);
	
	
	--Inicializo Variables
	LET sql_err 			= 0;
	LET cCodRet 			= "00000";
	LET dPago				= 0;
	LET dMontoFijo			= 0;
	LET dMontoMaximo		= 0;
	LET cCodret2			= '';
	LET cMensajeRespuesta	= '';
	LET dSaldoActivo		= 0;
	
	--VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	LET cCsg_codigo_ret				= "00000";
	LET cCsg_mensaje_ret			= "";
	LET cCsg_num_credito			= "";
	LET cCsg_cod_tipcred			= "";
	LET dtCsg_fec_origen			= MDY(1,1,1900);
	LET dtCsg_fec_prox_pago			= MDY(1,1,1900);
	LET mCsg_pago_min				= 0.0;
	LET dtCsg_fec_ult_pago			= MDY(1,1,1900);
	LET iCsg_plazo					= 0;
	LET iCsg_pagos_realizados		= 0;
	LET mCsg_linea_otorgada			= 0.0;
	LET mCsg_tasa_interes			= 0.0;
	LET dCsg_tasa_moratorios		= 0.0;
	LET dCsg_monto_sbc				= 0.0;
	LET mCsg_cap_vig				= 0.0;
	LET mCsg_cap_trans				= 0.0;
	LET mCsg_cap_vdo_exig			= 0.0;
	LET mCsg_cap_vdo_no_exig		= 0.0;
	LET mCsg_sdo_act_total_cap		= 0.0;
	LET mCsg_int_vig				= 0.0;
	LET mCsg_int_vdo				= 0.0;
	LET mCsg_int_moratorios			= 0.0;
	LET mCsg_int_mes				= 0.0;
	LET mCsg_sdo_act_total_int		= 0.0;
	LET mCsg_iva_int_vig			= 0.0;
	LET mCsg_iva_int_vdo			= 0.0;
	LET mCsg_iva_int_moratorios		= 0.0;
	LET mCsg_iva_int_mes			= 0.0;
	LET mCsg_sdo_act_total_iva		= 0.0;
	LET mCsg_com_pend				= 0.0;
	LET mCsg_iva_com				= 0.0;
	LET mCsg_sdo_retenido			= 0.0;
	LET mCsg_tot_liquidacion		= 0.0;
	LET mCsg_int_devengado			= 0.0;
	LET mCsg_iva_int_devengado		= 0.0;
	LET mCsg_linea_disp				= 0.0;
	LET mCsg_pagos_vdos				= 0.0;
	LET cCsg_desc_status_cred		= "";
	LET iCsg_id_bloqueo_cred		= 0;
	LET cCsg_bloqueo_cta			= "";
	LET cCsg_id_causa_bloq_cred		= "";
	LET cCsg_causa_bloqueo_cta		= "";
	LET cCsg_id_sit_esp_cte			= "";
	LET iCsg_id_causa_esp_cte		= 0;
	LET cCsg_sit_esp_cte			= "";
	LET cCsg_id_sit_esp_cred		= "";
	LET iCsg_id_causa_esp_cred		= 0;
	LET cCsg_sit_esp_cred			= "";
	
	--**********************************************************
	--SET DEBUG FILE TO "/tmp/sp_domi_proximo_pago.out";
	--TRACE ON;
	--**********************************************************
	
	BEGIN
		--Manejo de excepciones (errores)
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCodRet = sql_err;
			
				INSERT INTO bdidomi:"informix".dom_errores(Fecha_Error, Hora_Error, Cod_Error, Nombre_Arch, Sp_Llamado, Mensaje_Error, User_Insert, Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_proximo_pago', TRIM(pFolioActivacion), pUserStatus, CURRENT);
							
				RETURN cCodRet, dPago;
			END IF;
		END EXCEPTION;
   
  	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
		
		--Valida parametros de entrada
		 IF NVL(pTipoPago,'') = '' OR NVL(pEmpresa,'') = '' OR NVL(pNumCredito,'') = '' OR NVL(pUserStatus,'') = '' OR NVL(pFolioActivacion,'') = '' OR NVL(pTipoDomi,'') = ''THEN
			LET cCodRet = '99942'; --Algun parametro de entrada requerido esta en blanco.	
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodRet) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores(Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodRet, '', 'sp_domi_proximo_pago', trim(pFolioActivacion) || ' - ' || trim(cMensajeRespuesta), pUserStatus, CURRENT);
			
			RETURN cCodRet, dPago;
		END IF;
   
		IF pTipoDomi = '01' OR  pTipoDomi = '02' THEN
																								
			EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa, pNumCredito) INTO cCsg_codigo_ret,cCsg_mensaje_ret,cCsg_num_credito,cCsg_cod_tipcred,dtCsg_fec_origen,dtCsg_fec_prox_pago,mCsg_pago_min,
			dtCsg_fec_ult_pago,iCsg_plazo,iCsg_pagos_realizados,mCsg_linea_otorgada,mCsg_tasa_interes,dCsg_tasa_moratorios,
			dCsg_monto_sbc,mCsg_cap_vig,mCsg_cap_trans,mCsg_cap_vdo_exig,mCsg_cap_vdo_no_exig,mCsg_sdo_act_total_cap,mCsg_int_vig,
			mCsg_int_vdo,mCsg_int_moratorios,mCsg_int_mes,mCsg_sdo_act_total_int,mCsg_iva_int_vig,mCsg_iva_int_vdo,mCsg_iva_int_moratorios,
			mCsg_iva_int_mes,mCsg_sdo_act_total_iva,mCsg_com_pend,mCsg_iva_com,mCsg_sdo_retenido,mCsg_tot_liquidacion,mCsg_int_devengado,
			mCsg_iva_int_devengado,mCsg_linea_disp,mCsg_pagos_vdos,cCsg_desc_status_cred,iCsg_id_bloqueo_cred,cCsg_bloqueo_cta,
			cCsg_id_causa_bloq_cred,cCsg_causa_bloqueo_cta,cCsg_id_sit_esp_cte,iCsg_id_causa_esp_cte,cCsg_sit_esp_cte,cCsg_id_sit_esp_cred,
			iCsg_id_causa_esp_cred,cCsg_sit_esp_cred;
			IF cCsg_codigo_ret != '000000' THEN
					
				LET cCodRet = '99949';
				
				INSERT INTO bdidomi:"informix".dom_errores(Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_proximo_pago', TRIM(pNumCredito) || ' - ' || trim(cCsg_mensaje_ret), pUserStatus, CURRENT);
				
				RETURN cCodret, dPago;
			END IF;
			
			LET dSaldoActivo = mCsg_sdo_act_total_cap + mCsg_sdo_act_total_int +  mCsg_sdo_act_total_iva;
		
			IF  dSaldoActivo > 0 THEN
			
				--Si tipo de pago es T- Obtener monto total para no generar intereses
				IF pTipoPago = 'T' THEN
					
				--pTipoConsulta
				--	0 = Pago para no generar intereses actualizado con pagos
				--  1 = Saldo al Cierre
				--  2 = Pago para no generar intereses
				--  3 = pago minimo al corte
				--  4 = pago minimo al corte actualizado con pagos
				--  5 = Saldo actual TDC					
					EXECUTE PROCEDURE bdicred:"informix".sp_consultasaldocortemin(pEmpresa, pNumCredito, 0) INTO cCodRet, dPago; 
					
					IF cCodret != '00000' THEN
					
						INSERT INTO bdidomi:"informix".dom_errores(Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
						VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_proximo_pago', TRIM(pFolioActivacion), pUserStatus, CURRENT);
						
						LET cCodRet = '99949';
						
						RETURN cCodret, dPago;
					END IF;
					
				END IF;
			
				--Si tipo de pago es M -Obtener mï¿½nimo para no generar intereses
				IF pTipoPago = 'M' THEN
				
				--pTipoConsulta   
				--	0 = Pago para no generar intereses actualizado con pagos
				--  1 = Saldo al Cierre
				--  2 = Pago para no generar intereses
				--  3 = pago minimo al corte
				--  4 = pago minimo al corte actualizado con pagos
				--  5 = Saldo actual TDC
					EXECUTE PROCEDURE bdicred: "informix".sp_consultasaldocortemin(pEmpresa, pNumCredito, 4) INTO cCodRet, dPago;
					
					IF cCodret != '00000' THEN
					
						INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
						VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_proximo_pago', TRIM(pFolioActivacion), pUserStatus, CURRENT);
						
						LET cCodRet = '99949';
						
						RETURN cCodret, dPago;
					END IF;
					
				END IF;
					
				--Obtener monto fijo y mï¿½ximo de tabla dom_autorizaciones
				SELECT imp_fijo_tc, imp_maximo
				INTO dMontoFijo, dMontoMaximo
				FROM bdidomi:"informix".dom_autorizaciones
				WHERE folio_activacion = pFolioActivacion;
				
				--Si el tipo de Pago es M o T, si el Monto Mï¿½ximo es menor que el monto a pagar, se tomarï¿½ el monto mï¿½ximo
				IF pTipoPago = 'M' OR pTipoPago = 'T' THEN
					IF dMontoMaximo < dPago THEN
						LET dPago = dMontoMaximo;
					END IF;
				END IF;
			
				--Si tipo de pago es F - 
				IF pTipoPago = 'F' THEN
				
					LET dPago = dMontoFijo;
                    
                    IF pTipoDomi = '02' AND dPago > mCsg_tot_liquidacion THEN
                        LET dPago = mCsg_tot_liquidacion;
                    ELIF pTipoDomi = '01' THEN
                        IF (dPago > mCsg_tot_liquidacion) AND (mCsg_tot_liquidacion < 100) THEN
                            LET dPago = 0;
                        END IF;
                    END IF;
					
				END IF;
				
				UPDATE bdidomi:"informix".dom_pago
				SET monto_proximo_pago = dPago
				WHERE folio_activacion = pFolioActivacion;
			
				RETURN cCodRet, dPago;
			ELSE
                -- RESPETAR IMPORTE MAXIMO EN OTROS BANCOS.
                IF pTipoDomi = '02' THEN
                    --Obtener monto fijo y mï¿½ximo de tabla dom_autorizaciones
                    SELECT imp_maximo
                    INTO dMontoMaximo
                    FROM bdidomi:"informix".dom_autorizaciones
                    WHERE folio_activacion = pFolioActivacion;

                    --Si el tipo de Pago es M o T, si el Monto Mï¿½ximo es menor que el monto a pagar, se tomarï¿½ el monto mï¿½ximo
                    IF dMontoMaximo < mCsg_tot_liquidacion THEN
                        LET mCsg_tot_liquidacion = dMontoMaximo;
                    END IF;
                END IF;

				UPDATE bdidomi:"informix".dom_pago
				SET monto_proximo_pago = mCsg_tot_liquidacion
				WHERE folio_activacion = pFolioActivacion;
				
				RETURN cCodRet, mCsg_tot_liquidacion;
			END IF;
		END IF;		
		RETURN cCodRet, mCsg_tot_liquidacion;
	END;
END PROCEDURE
DOCUMENT
'AUTOR      		: Edith Mendoza Barraza',
'DESCRIPCION		: Se actualiza el proximo pago de una domiciliaciï¿½n',
'FECHA      		: 01/06/2022',
'BD         		: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_createtablascte_ob(pFolio CHAR(20),
	pCliente CHAR(20), pUser CHAR(8), pFechaProxPago DATE, pTipoDomi CHAR(2)
)
	RETURNING CHAR(5) AS cCodret

-- DECLARACION DE VARIABLES.
DEFINE iSqlerr       				INTEGER;
DEFINE cCodret    					CHAR(5);
DEFINE cCodRet3    					CHAR(5);
DEFINE cInTransaction	 			CHAR(1);
DEFINE cNombre_arch_manual 			CHAR(20);
DEFINE cTipoRegistro  				CHAR(1);
DEFINE cConsecutivo  				CHAR(6);
DEFINE dFecha_envio  				DATE;
DEFINE cFecha_cargo  				CHAR(8);
DEFINE cFecha_abono  				CHAR(8);
DEFINE cTipoCtaCargo 				CHAR(2);
DEFINE cCveBancoCargo 				CHAR(3);
DEFINE cCtaCargo 					CHAR(20);
DEFINE cRfcCargo 					CHAR(13);
DEFINE cNombreCargo 				CHAR(50);
DEFINE cCtaAbono 					CHAR(20);
DEFINE cImpOperacion 				CHAR(18);
DEFINE cImpIva 						CHAR(15);
DEFINE cRefNumerica 				CHAR(7);
DEFINE cRefLeyenda 					CHAR(40);
DEFINE cRefServicio 				CHAR(40);
DEFINE cRefTitularServicio 			CHAR(40);
DEFINE cAccion						CHAR(1);
DEFINE cReintentarCta 				CHAR(1);
DEFINE cEstatus						CHAR(2);
DEFINE cCausaRechazo 				CHAR(50);
DEFINE cComisionCobrada		 		CHAR(16);
DEFINE cIvaCobrado					CHAR(16);
DEFINE cUserInsert	 				CHAR(8);
DEFINE dFechaInsert	 				DATE;
DEFINE cTipoCtaAbono 				CHAR(2);
DEFINE dFecha_pago   				DATE;
DEFINE dFecha_prox_pago 			DATE;
DEFINE dFecha_inicio 				CHAR(8);
DEFINE dFecha_fin    				CHAR(8);
DEFINE cCodret2						CHAR(5);
DEFINE cMensajeRespuesta 			CHAR(110);
DEFINE cTipoDomi		 			CHAR(2);
DEFINE cTipoPago		 			CHAR(1);
DEFINE cNumeroCredito			 	CHAR(20);
DEFINE cMonto			 			DECIMAL(18,2);
DEFINE cFolioActivacion				CHAR(20);

DEFINE cNombreArchivoCce 			CHAR(20);
DEFINE cFechaPresentacionCCe 		CHAR(8);
DEFINE cTipoRegistroCce	 			CHAR(20);
DEFINE cNumeroSecuenciaCce 			CHAR(7);

--VALIDACION FECHA OTROS BANCOS
DEFINE dFechaProceso 				DATE;
DEFINE dFechaLimitesCargo			CHAR(8);

-- VALORES INICIALES.
LET iSqlerr    				=  0;
LET cCodret   				= '00000';
LET cCodret2				= '';
LET cMensajeRespuesta		= '';
LET cInTransaction      	= 'N';
LET cFechaPresentacionCce 	= '';
LET cFolioActivacion		= '';
LET dFecha_envio 			= '';

LET cConsecutivo  		    = '000001';

--*********************************************************************************************
    --SET DEBUG FILE TO "/home/sysdomi/createtablascte_ob.out";
    --TRACE ON;
--*********************************************************************************************

BEGIN
	--Manejo de excepciones (errores)
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 then
			IF cInTransaction = 'S' THEN
				ROLLBACK WORK;
			END IF;

			LET cCodret = iSqlerr;

			-- Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
			INSERT INTO bdidomi:"informix".dom_errores(Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_createtablascte_ob', TRIM(pFolio), pUser, CURRENT);

			RETURN cCodret;
		END IF;
	END EXCEPTION;

	-- Valida parametros de entrada
	IF NVL(pFolio,'') = '' OR NVL(pCliente,'') = '' OR NVL(pUser,'') = '' OR NVL(pFechaProxPago, '') = '' THEN
		LET cCodret = '99958'; --Problema con los parametros

		--Obtenemos los datos del error ocurrido.
		EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;

		--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
		INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
		VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_createtablascte_ob', TRIM(pFolio) || '-' || TRIM(cMensajeRespuesta), pUser, CURRENT);

		RETURN cCodret;
	END IF;

	-- Validamos si el cliente existe.
	IF NOT EXISTS(SELECT 1 FROM bdinteg:"informix".si_cliente WHERE numcte = pCliente) THEN
		LET cCodret = '99950'; --Cliente no existe.

		--Obtenemos los datos del error ocurrido.
		EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;

		--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
		INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
		VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_createtablascte_ob', TRIM(pFolio) || '-' || TRIM(cMensajeRespuesta), pUser, CURRENT);

		RETURN cCodret;
	END IF;
 
 	SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

	-- Verificamos que se haya obtenido informacion adicional.
	IF EXISTS
		(SELECT 1 FROM bdidomi:"informix".dom_archivomanual a
		INNER JOIN bdidomi:"informix".dom_fecha_pago b
		ON a.folio_activacion = b.folio_activacion
		WHERE a.folio_activacion = pFolio
		AND a.estatus = 'EP')
	THEN

		SELECT nombre_arch, a.fecha_envio, a.tipo_registro, a.fecha_cargo, a.fecha_abono,
		a.tipo_cta_cargo, a.cve_banco_cargo, a.cuenta_cargo, a.rfc_cargo, a.nombre_cargo,
		a.cuenta_abono, a.imp_iva, a.ref_numerica, a.ref_leyenda,a.ref_servicio,
		a.ref_titular_serv, a.accion, a.reintentar_cuenta,a.estatus, a.causa_rechazo,
		a.nombre_arch_cce, a.tipo_registro_cce,a.numero_secuencia_cce, a.comision_cobrada,
		a.iva_cobrado, a.tipo_cta_abono,b.fecha_pago, b.fecha_prox_pago,
		TO_CHAR(b.fecha_inicio,'%Y%m%d') , TO_CHAR(b.fecha_fin,'%Y%m%d'), c.cve_domiciliar_tc,
		a.tipo_domi, c.cuenta, a.imp_operacion, d.monto_proximo_pago
		INTO  cNombre_arch_manual, dFecha_envio, cTipoRegistro, cFecha_cargo, cFecha_abono,
		cTipoCtaCargo, cCveBancoCargo, cCtaCargo, cRfcCargo, cNombreCargo, cCtaAbono, cImpIva,
		cRefNumerica, cRefLeyenda, cRefServicio, cRefTitularServicio, cAccion, cReintentarCta,
		cEstatus, cCausaRechazo, cNombreArchivoCce, cTipoRegistroCce, cNumeroSecuenciaCce,
		cComisionCobrada, cIvaCobrado, cTipoCtaAbono, dFecha_pago, dFecha_prox_pago, dFecha_inicio,
		dFecha_fin, cTipoPago, cTipoDomi, cNumeroCredito, cImpOperacion, cMonto
		FROM bdidomi:"informix".dom_archivomanual a
		INNER JOIN bdidomi:"informix".dom_fecha_pago b ON a.folio_activacion = b.folio_activacion
		INNER JOIN bdidomi:"informix".dom_autorizaciones c ON a.folio_activacion = c.folio_activacion
		INNER JOIN bdidomi:"informix".dom_pago d ON a.folio_activacion = d.folio_activacion
		WHERE a.folio_activacion = pFolio
		AND a.estatus = 'EP'
		AND a.tipo_domi = '02';

		LET cNombreCargo = REPLACE(REPLACE(cNombreCargo, 'ï¿½', '#'), 'ï¿½', '#');
		LET cRefTitularServicio = REPLACE(REPLACE(cRefTitularServicio, 'ï¿½', '#'), 'ï¿½', '#');

		LET dFechaLimitesCargo = dFecha_inicio ;
		--TO_CHAR(dFecha_inicio,'%y/%m/%d')
		--TO_DATE(dtFecha_Respuesta,'%d/%m/%Y')

        LET cImpOperacion = LPAD(TRIM((cMonto*100)::INTEGER::CHAR(15)),15,'0');

		LET dFechaProceso = dFecha_envio ;

		-- Validando el folio_suc para ptros bancos ya que este campo se llena cuando se hace la ejecucion de pago
		LET cFolioActivacion = NULL;

		IF NOT EXISTS
			(SELECT 1 FROM bdidomi:"informix".dom_cte_archivos
			 WHERE nombre_arch = cNombre_arch_manual
			 AND fecha_envio = dFechaProceso)
		THEN

			IF EXISTS (
				SELECT consecutivo FROM bdidomi:"informix".dom_cte_detalle
				WHERE fecha_envio = dFecha_prox_pago AND nombre_arch = cNombre_arch_manual
			) THEN
				--Obtenemos el valor del ultimo consecutivo de nombre de archivo y lo incrementamos en 1.
				SELECT LPAD(TO_CHAR(MAX(consecutivo::INTEGER)+1),6,'0')
				INTO cConsecutivo
				FROM bdidomi:"informix".dom_cte_detalle
				WHERE fecha_envio = dFecha_prox_pago AND nombre_arch = cNombre_arch_manual;

			END IF;

			BEGIN WORK;
				LET cInTransaction = 'S';

				-- insertar tablas cte
				INSERT INTO bdidomi:"informix".dom_cte_archivos(nombre_arch,fecha_envio,num_cte,fecha_carga,cve_status,user_insert,fecha_insert)
				VALUES(cNombre_arch_manual, EXTEND(MDY(MONTH(dFecha_envio), DAY(dFecha_envio), YEAR(dFecha_envio)), YEAR TO SECOND),TRIM(pCliente), EXTEND(MDY(MONTH(dFecha_envio), DAY(dFecha_envio), YEAR(dFecha_envio)), YEAR TO SECOND),'01',pUser, today);

				INSERT INTO bdidomi:"informix".dom_cte_encabezado(nombre_arch,fecha_envio,tipo_registro,num_cte,cuenta_abono,
				num_operaciones,fecha_inicial,fecha_final,user_insert,fecha_insert)
				VALUES(cNombre_arch_manual, EXTEND(MDY(MONTH(dFecha_envio), DAY(dFecha_envio), YEAR(dFecha_envio)), YEAR TO SECOND),'E',LPAD(TRIM(pCliente),20,'0'), LPAD('',20,'0'),LPAD('1',8,'0'),dFechaLimitesCargo, dFechaLimitesCargo,pUser,today);

				INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch, fecha_envio, tipo_registro, consecutivo, fecha_cargo,
					fecha_abono, tipo_cta_cargo, cve_banco_cargo, cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion,
					imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, accion, reintentar_cuenta, estatus,
					causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada,
					iva_cobrado, user_insert, fecha_insert, tipo_cta_abono, folio_suc)
				VALUES(cNombre_arch_manual, EXTEND(MDY(MONTH(dFecha_envio), DAY(dFecha_envio), YEAR(dFecha_envio)), YEAR TO SECOND),
					cTipoRegistro, cConsecutivo, cFecha_cargo, cFecha_abono, cTipoCtaCargo, cCveBancoCargo, cCtaCargo, cRfcCargo,
					cNombreCargo, cCtaAbono, cImpOperacion, cImpIva, cRefNumerica, cRefLeyenda, cRefServicio, cRefTitularServicio,
					cAccion, cReintentarCta, cEstatus, cCausaRechazo, cNombreArchivoCce, cFechaPresentacionCce, cTipoRegistroCce,
					cNumeroSecuenciaCce, cComisionCobrada, cIvaCobrado, pUser, today, cTipoCtaAbono, cFolioActivacion);

				INSERT INTO bdidomi:"informix".dom_cte_sumario(nombre_arch,fecha_envio,tipo_registro,num_operaciones,
				imp_operaciones,num_oper_pend,imp_oper_pend,num_oper_apli,imp_oper_apli,num_oper_rech,imp_oper_rech,user_insert,
				fecha_insert)
				VALUES(cNombre_arch_manual, EXTEND(MDY(MONTH(dFecha_envio), DAY(dFecha_envio), YEAR(dFecha_envio)), YEAR TO SECOND),'S', LPAD('1',8,'0'), LPAD(TRIM(cImpOperacion),18,'0'),LPAD('',8,'0'),LPAD('',18,'0'), LPAD('',8,'0'), LPAD('',18,'0'),LPAD('',8,'0'),LPAD('',18,'0'), pUser, today);
		   	COMMIT WORK;

			LET cInTransaction = 'N';

		--Verificar que no exista registro con misma ctaCargo, ctaAbono y fecha de proximo pago.
		ELIF NOT EXISTS
			(SELECT 1 FROM bdidomi:"informix".dom_cte_detalle
			 WHERE cuenta_cargo = cCtaCargo
			 AND cuenta_abono = cCtaAbono
			 AND fecha_envio = dFechaProceso)
		THEN

			BEGIN WORK;
				LET cInTransaction = 'S';
				UPDATE bdidomi:"informix".dom_cte_encabezado
				SET num_operaciones = LPAD(TO_CHAR(num_operaciones::INTEGER + 1),8,'0')
				WHERE nombre_arch = cNombre_arch_manual;

				--Obtenemos el valor del ultimo consecutivo de nombre de archivo y lo incrementamos en 1.
				SELECT LPAD(TO_CHAR(NVL(MAX(consecutivo::INTEGER),0)+1),6,'0')
				INTO cConsecutivo 
				FROM bdidomi:"informix".dom_cte_detalle 
				WHERE nombre_arch = cNombre_arch_manual;

				INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch, fecha_envio, tipo_registro, consecutivo, fecha_cargo,
					fecha_abono, tipo_cta_cargo, cve_banco_cargo, cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion,
					imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, accion, reintentar_cuenta, estatus,
					causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada,
					iva_cobrado, user_insert, fecha_insert, tipo_cta_abono, folio_suc)
				VALUES(cNombre_arch_manual, extend(MDY(MONTH(dFecha_envio), DAY(dFecha_envio), YEAR(dFecha_envio)), year to second),
					cTipoRegistro, cConsecutivo, cFecha_cargo, cFecha_abono, cTipoCtaCargo, cCveBancoCargo, cCtaCargo, cRfcCargo,
					cNombreCargo, cCtaAbono, cImpOperacion, cImpIva, cRefNumerica, cRefLeyenda, cRefServicio,
					cRefTitularServicio, cAccion, cReintentarCta, cEstatus, cCausaRechazo, cNombreArchivoCce,
					cFechaPresentacionCce, cTipoRegistroCce, cNumeroSecuenciaCce, cComisionCobrada, cIvaCobrado,
					pUser, today, cTipoCtaAbono, cFolioActivacion);

				UPDATE bdidomi:"informix".dom_cte_sumario
				SET num_operaciones = LPAD(TO_CHAR(num_operaciones::INTEGER + 1),8,'0'),
					imp_operaciones = LPAD(TO_CHAR(imp_operaciones::INTEGER + cImpOperacion::INTEGER),18,'0')
				WHERE nombre_arch = cNombre_arch_manual;
			COMMIT WORK;

			LET cInTransaction = 'N';
		ELSE
			UPDATE bdidomi:"informix".dom_cte_detalle
			SET accion = 'A'
			WHERE cuenta_abono = cCtaAbono
			AND cuenta_cargo = cCtaCargo
			AND fecha_envio = dFechaProceso;
		END IF;

	ELSE
		LET cCodret = '99957'; --No se obtuvo informacion adicional.
		--Obtenemos los datos del error ocurrido.
		EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;

		--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
		INSERT INTO bdidomi:"informix".dom_errores(Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
		VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_createtablascte_ob', TRIM(pFolio) || '-' || TRIM(cMensajeRespuesta), pUser, CURRENT);

	END IF;

END;
RETURN cCodret;
END PROCEDURE;