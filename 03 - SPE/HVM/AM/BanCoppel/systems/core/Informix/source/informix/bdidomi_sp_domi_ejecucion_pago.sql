CREATE PROCEDURE "informix".sp_domi_ejecucion_pago(pTipoDomi char(2), pTipoEjecucion char(1), pUsuario CHAR(8) )
RETURNING char(5) as cCodRet, CHAR(121) as cMensaje

-- DECLARACIï¿½N DE VARIABLES
DEFINE cCodRet						CHAR(5);
DEFINE cMensaje						CHAR(121);         
DEFINE iSqlerr      				INTEGER;
DEFINE cInTransaction	 			CHAR(1); 
DEFINE iIsamerr						INTEGER;
DEFINE cErrorInfo					CHAR(70);
DEFINE cDescripcionProceso			CHAR(60);
DEFINE dFecha_hoy					DATE;
DEFINE iExiste						INTEGER;
DEFINE cFechaFormat					CHAR(10);
DEFINE vsNomProceso					CHAR(20); 
DEFINE vsCodRetorno2				CHAR(5);
DEFINE INICIADO						CHAR(1);
DEFINE TERMINADO					CHAR(1);
DEFINE ERROR						CHAR(1);
DEFINE CARGO						CHAR(1);
DEFINE ABONO						CHAR(1);
DEFINE REVERSION					CHAR(1);
DEFINE cNom_Arch_Salida				CHAR(20);
DEFINE cNumeroCliente				CHAR(100);
DEFINE cCuentaAbono_Prov			CHAR(20);
DEFINE cTransaccCargo				CHAR(4);
DEFINE cTransaccAbono				CHAR(4);
DEFINE cTransaccReverso				CHAR(4);
DEFINE cSucursalContable			CHAR(4);
DEFINE cNumCte_proveedor			CHAR(9);
DEFINE cTipo 						CHAR(1);
DEFINE cEstatusProceso				CHAR(1);
DEFINE cFechaCargo					CHAR(8);
DEFINE cNom_Arch_Aux				CHAR(20);
DEFINE cClabeoTarjeta_Cargo			CHAR(20);
DEFINE iSecuencia					INTEGER;
DEFINE cRFC_Cargo					CHAR(18);
DEFINE cRFCOrdenante				CHAR(18);
DEFINE cRef_Leyenda					CHAR(40);
DEFINE dFechaEnvio					DATE;
DEFINE cCveBanco_Cargo				CHAR(3);
DEFINE cRef_servicio				CHAR(40);
DEFINE cRef_titular_serv			CHAR(40);
DEFINE cReintentarCuenta			CHAR(1);
DEFINE cRefNumerica 				CHAR(7);
DEFINE cTipoRegistro				CHAR(1);
DEFINE cCuentaCargo					CHAR(20);
DEFINE cCuentaAbono					CHAR(20);
DEFINE cStatusTar					CHAR(1);
DEFINE cTipo_tarjeta				CHAR(1);
DEFINE cNum_Tarjeta					CHAR(16);
DEFINE cNum_TarjetaAbono			CHAR(16);
DEFINE cEstatusCtaCargo				CHAR(1);
DEFINE cEstatusCtaAbono				CHAR(2);
DEFINE cProductoCtaCargo			CHAR(4);
DEFINE mSaldoActual					MONEY(16,2);
DEFINE cEstatusAutorizacion			CHAR(2);
DEFINE mImp_maximo					MONEY(16,2);
DEFINE cFolioActivacion				CHAR(20);
DEFINE cTipoPago					CHAR(1);
DEFINE cNumCte						CHAR(20);
DEFINE mlim_importe 				CHAR(5);
DEFINE mMontoPagar					DECIMAL(18,2);
DEFINE cMonto						CHAR(20);
DEFINE dMonto						DECIMAL(18,2);
DEFINE mMontoPagarPeriodo			DECIMAL(18,2);
DEFINE cDivisaAbono					CHAR(2);
DEFINE cPeriodo						CHAR(2);
DEFINE dFechaPago					DATE;
DEFINE dFechaUltimoPago				DATE;
DEFINE dFechaProximoPago			DATE;
DEFINE dFecha_inicio 				DATE;
DEFINE dFecha_fin    				DATE;
DEFINE iIntentos					INTEGER;
DEFINE cNombre1Cte					CHAR(26);
DEFINE cApellido1Cte				CHAR(26);
DEFINE cNombreCte					CHAR(26);
DEFINE cRFC							CHAR(18);
DEFINE cRazonSocial					CHAR(60);
DEFINE cNumTelefono					CHAR(13);
DEFINE cCorreoElect					CHAR(100);
DEFINE cProductName					CHAR(80);
DEFINE cProductShortName 			CHAR(20);
DEFINE cCuentaAbonoX				CHAR(20);
DEFINE cCuentaCargoX				CHAR(20);
DEFINE cCuentaAbonoShortX			CHAR(4);
DEFINE cDiaMes						CHAR(5); 
DEFINE cNumeroFolioCargo			CHAR(16);
DEFINE cTranRet						CHAR(4);
DEFINE mSdoDisp						MONEY(16,2);
DEFINE mMontoRet					MONEY(16,2);
DEFINE mRemanente					MONEY(14,2);
DEFINE mIntMoraCobrado				MONEY(14,2);
DEFINE mIntVencCobrado				MONEY(14,2);
DEFINE mCapVencCobrado				MONEY(14,2);
DEFINE mIntVigCobrado				MONEY(14,2);
DEFINE mCapVigCobrado				MONEY(14,2);
DEFINE mImpuestoCobrado				MONEY(14,2);
DEFINE mComisionesCobradas			MONEY(14,2);
DEFINE mSeguroCobrado				MONEY(14,2);
DEFINE dFechaProceso				DATE;
DEFINE iAplicoCargo					INTEGER;
DEFINE iAplicoAbono					INTEGER;
DEFINE iTotalOperaciones			INTEGER;	
DEFINE iImpTotalOperaciones			INTEGER;
DEFINE iPendientes					INTEGER;
DEFINE iImpPendientes				INTEGER;
DEFINE iAplicaciones				INTEGER;
DEFINE iImpAplicaciones				INTEGER;
DEFINE iRechazos					INTEGER;
DEFINE iImpRechazos					INTEGER;
DEFINE cSPProceso					CHAR(50);
DEFINE cFechaCortePago				CHAR(2);
DEFINE dFechaPagoSiguiente			DATE;
--RQM 09 704.Se definen las variables requeridas para la consulta del saldo disponible.DHG
	DEFINE mSdoActual		MONEY(14,2); --Monto del saldo actual de la cuenta.
	DEFINE mSdoRetenido     MONEY(14,2); --Monto del saldo retenido de la cuenta.
	DEFINE mSdoCong	        MONEY(14,2); --Monto del saldo congelado de la cuenta.
	DEFINE mSaldoSBC        MONEY(14,2); --Monto del saldo inmovilizado (salvo buen cobro) de la cuenta.
	DEFINE mImpChqSbg		MONEY(14,2); --Monto del importe de cheques de sobregiro.
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.

-- VALORES INICIALES
LET iSqlerr    			=  0;
LET cCodRet				= "00000";
LET cMensaje			= "";    
LET iExiste	   			=  0;
LET vsNomProceso 		= 'EJECUTADOMI_TDCBCPL';
LET cDescripcionProceso	= 'EJECUCIÃN DOMI PAGO TDCBCPL';
LET cSPProceso			= 'sp_domi_ejecucion_pago';
LET INICIADO			= '0';
LET TERMINADO			= '1';
LET CARGO				= '2';
LET ABONO				= '3';
LET REVERSION			= '4';
LET ERROR				= '6';
LET cCuentaAbono_Prov 	= "";
LET cTransaccCargo  	= "";
LET cTransaccAbono  	= "";
LET cSucursalContable 	= "";
LET cNumCte_proveedor   = "";
LET cTipo 				= ''; 
LET cEstatusProceso 	= '';
LET cNom_Arch_Salida	= "";
LET cNom_Arch_Aux		= '';
LET cClabeoTarjeta_Cargo= "";
LET iSecuencia			= 0;
LET cRFC_Cargo			= "";
LET cRFCOrdenante		= "";
LET cRef_Leyenda 		= "COBRO POR SERVICIO DE DOMICILIACION";
LET dFechaEnvio			= "";
LET cCveBanco_Cargo		= "";
LET cRef_servicio 		= "";
LET cRef_titular_serv	= "";
LET cReintentarCuenta	= '';
LET cRefNumerica 		= ''; 
LET cTipoRegistro		= '';
LET cCuentaCargo		= "";
LET cCuentaAbono		= "";
LET cStatusTar			= "";
LET cTipo_tarjeta		= "";
LET cNum_Tarjeta		= "";
LET cNum_TarjetaAbono	= "";
LET cEstatusCtaCargo	= "";
LET cEstatusCtaAbono	= "";
LET cProductoCtaCargo	= "";
LET mSaldoActual		= 0.00;
LET cEstatusAutorizacion= "";
LET mImp_maximo			= 0.00;
LET cFolioActivacion    = "";
LET cTipoPago			= '';
LET cNumCte				= "";
LET mMontoPagar			= 0.00;
LET mMontoPagarPeriodo	= 0.00;
LET cDivisaAbono		= "";
LET iIntentos			= 0;
LET cApellido1Cte		= "";
LET cNombre1Cte			= "";
LET cNombreCte			= "";
LET cRFC				= "";
LET cRazonSocial		= "";
LET cNumTelefono		= "";
LET cCorreoElect		= "";
LET cProductName		= "";
LET cProductShortName	= "";
LET cCuentaAbonoX  		= "";   
LET cCuentaCargoX		= "";
LET cCuentaAbonoShortX	= "";
LET mRemanente			= 0.00;
LET mIntMoraCobrado		= 0.00;
LET mIntVencCobrado		= 0.00;
LET mCapVencCobrado		= 0.00;
LET mIntVigCobrado		= 0.00;
LET mCapVigCobrado		= 0.00;
LET mImpuestoCobrado	= 0.00;
LET mComisionesCobradas	= 0.00;
LET mSeguroCobrado		= 0.00;
LET iAplicoCargo		= 0;
LET iAplicoAbono		= 0;
LET iTotalOperaciones	= 0;
LET iImpTotalOperaciones= 0;
LET iPendientes			= 0;
LET iImpPendientes		= 0;
LET iAplicaciones		= 0;
LET iImpAplicaciones	= 0;
LET iRechazos			= 0;
LET iImpRechazos		= 0;
LET dFecha_hoy 			= today;
LET cFechaFormat		= today;
LET cInTransaction      = 'N';
	--RQM 09 704. Se inicializan las variables para el llamado y retorno de consulta de saldo. DHG.
	LET mSdoActual			=0.00;	
	LET mSdoRetenido		=0.00;
	LET mSdoCong			=0.00;
	LET mSaldoSBC   		=0.00;
	LET mImpChqSbg			=0.00;
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';

BEGIN

	--Manejo de excepciones (errores)
	ON EXCEPTION SET iSqlerr, iIsamerr, cErrorInfo
		IF iSqlerr <> 0 then
			IF cInTransaction = 'S' THEN 
				ROLLBACK WORK;
			END IF;
			LET cCodRet = iSqlerr;
			LET cMensaje = cErrorInfo;
		
			EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, 
			ERROR, cCodRet, pUsuario, cSPProceso, cNom_Arch_Salida, cFechaFormat, '11')
			INTO vsCodRetorno2;
		
			RETURN cCodRet, cMensaje;
		END IF;
	END EXCEPTION WITH RESUME;
	
	--***************************************************************************************
		--SET DEBUG FILE TO "/informix/Derian/sp_domi_ejecucion_pago.out";
		--TRACE ON;
	--***************************************************************************************
	SET ISOLATION TO DIRTY READ;
	-- consultar fecha de hoy en bdintg:si_fechas.
	SELECT fecha_hoy INTO dFecha_hoy FROM bdinteg:"informix".si_fechas where empresa = '001';

	LET cFechaFormat = YEAR(dFecha_hoy) || LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0');

	-- Validar tipo de domiciliacion
	SELECT 1 INTO iExiste FROM bdidomi:dom_cat_tipo WHERE cve_tipo = pTipoDomi;

	IF iExiste=1 THEN
		IF pTipoDomi='01' THEN 
			
			--VALIDACIONES
			IF EXISTS (SELECT 1 FROM bdidomi:"informix".dom_parametros WHERE cod_param='36') THEN
				SELECT trim(valor) INTO cNumeroCliente 
				FROM bdidomi:"informix".dom_parametros WHERE cod_param='36';
			ELSE
				-- PARAMETRO NUMCTE PROV NO EXISTE O ES INVALIDO
				LET cCodRet = "99976";
			
				EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, 
				ERROR, cCodRet, pUsuario, cSPProceso, cNom_Arch_Salida, cFechaFormat, '11')
				INTO vsCodRetorno2;
				EXECUTE PROCEDURE bdidomi:"informix".sp_ObtenerMensajeError(cCodRet) 
				INTO cCodRet,cMensaje;
				RETURN cCodRet, cMensaje;
			END IF;
		
			LET cNom_Arch_Salida = 'SB'||
								TRIM(cNumeroCliente)||
								'B'||
								LPAD(DAY(dFecha_hoy),2,'0') || 	LPAD(MONTH(dFecha_hoy),2,'0') || SUBSTR(YEAR(dFecha_hoy)::CHAR(4),3,2)||
								'01'; 
		
			IF EXISTS (SELECT 1 FROM bdidomi:"informix".dom_parametros WHERE cod_param='46') THEN 
				SELECT TRIM(valor) INTO cCuentaAbono_Prov 
				FROM bdidomi:"informix".dom_parametros WHERE cod_param = '46';
			ELSE
				-- PARAMETRO NUM CTA PROV NO EXISTE O ES INVALIDO
				LET cCodRet = "99981"; 
				
				EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso,ERROR, cCodRet, pUsuario, cSPProceso, cNom_Arch_Salida, cFechaFormat, '11')
				INTO vsCodRetorno2;
				
				EXECUTE PROCEDURE bdidomi:"informix".sp_ObtenerMensajeError(cCodRet) 
				INTO cCodRet,cMensaje;
				RETURN cCodRet, cMensaje;
			END IF;
		
			SELECT TRIM(valor) INTO cTransaccCargo 
			FROM bdidomi:"informix".dom_parametros WHERE cod_param = '56'; 
		
			SELECT TRIM(valor) INTO cTransaccAbono
			FROM bdidomi:"informix".dom_parametros WHERE cod_param = '55';
			
			SELECT TRIM(valor) INTO cTransaccReverso
			FROM bdidomi:"informix".dom_parametros WHERE cod_param = '57';
		
			-- Validar la existencia de las transacciones
			SELECT COUNT(numero) INTO iExiste 
			FROM bdinteg:"informix".si_transacc WHERE numero IN (cTransaccCargo,cTransaccAbono,cTransaccReverso);
		
			IF iExiste < 3 then
				-- Regresa error TRANSACCIONES DOMI NO DEFINIDAS
				LET cCodRet = '99952';
			
				EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso,ERROR, cCodRet, pUsuario, cSPProceso, cNom_Arch_Salida, cFechaFormat, '11')
				INTO vsCodRetorno2;
				
				EXECUTE PROCEDURE bdidomi:"informix".sp_ObtenerMensajeError(cCodRet) 
				INTO cCodRet,cMensaje;
				RETURN cCodRet, cMensaje;
			END IF;
		
			LET iExiste = 0;
		
			SELECT TRIM(valor) INTO cSucursalContable 
			FROM bdidomi:"informix".dom_parametros WHERE cod_param = '54'; 
		
			--	Se valida si existe la sucursal contable.
			IF NOT EXISTS(SELECT 1 FROM bdinteg:si_sucursales WHERE sucursal = cSucursalContable) THEN
				-- SUCURSAL CONTABLE NO DEFINIDA
				LET cCodRet = '99977';
			
				EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso,ERROR, cCodRet, pUsuario, cSPProceso, cNom_Arch_Salida, cFechaFormat, '11')
				INTO vsCodRetorno2;
				
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) 
				INTO cCodRet,cMensaje;
				RETURN cCodRet, cMensaje;
			END IF;
			LET iExiste = 0;
		
			IF EXISTS(SELECT 1 FROM bdidomi:"informix".dom_cat_servicios WHERE num_cte = cNumeroCliente) THEN
				SELECT NVL(rfc,'') INTO cRFCOrdenante
				FROM bdidomi:"informix".dom_cat_servicios WHERE num_cte = cNumeroCliente;
			
				IF cRFCOrdenante = '' OR LENGTH(TRIM(cRFCOrdenante)) < 12 THEN
					--RFC ORDENANTE REGISTRADO INVALIDO
					LET cCodRet = '99978';
				
					EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso,ERROR, cCodRet, pUsuario, cSPProceso, cNom_Arch_Salida, cFechaFormat, '11')
					INTO vsCodRetorno2;
					EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) 
					INTO cCodRet,cMensaje;
					RETURN cCodRet, cMensaje;
				END IF;			
			ELSE
				--PROVEEDOR NO REGISTRADO
				LET cCodRet = '99979';
				
				EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, 
				ERROR, cCodRet, pUsuario, cSPProceso, cNom_Arch_Salida, cFechaFormat, '11')
				INTO vsCodRetorno2;
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) 
				INTO cCodRet,cMensaje;
				RETURN cCodRet, cMensaje;
			END IF;
		
			IF EXISTS(SELECT 1 FROM bdidomi:"informix".dom_parametros WHERE cod_param='10')THEN
				SELECT trim(valor)::NUMERIC INTO mlim_importe 
				FROM bdidomi:"informix".dom_parametros WHERE cod_param='10';
			ELSE
				-- LIMITE DE IMPORTE NO ESTA PARAMETRIZADO
				LET cCodRet = '99980';
			
				EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, 
				ERROR, cCodRet, pUsuario, cSPProceso, cNom_Arch_Salida, cFechaFormat, '11')
				INTO vsCodRetorno2;
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) 
				INTO cCodRet,cMensaje;
				RETURN cCodRet, cMensaje;
			END IF;
		
			LET cTipo = 'B';
			LET iExiste = 0;
		
			-- Validar estatus de proceso
			SELECT NVL(estatus,'') INTO cEstatusProceso
			FROM bdidomi:"informix".dom_procesos WHERE tipo_proceso = pTipoEjecucion AND fecha_proceso = dFecha_hoy
			AND cve_proceso = vsNomProceso;
		
			IF NVL(cEstatusProceso,'') NOT IN ('',INICIADO,TERMINADO,ERROR) THEN
				-- ESTATUS INVALIDO
				LET cCodRet = '99953';
			
				EXECUTE PROCEDURE bdidomi:"informix".sp_ObtenerMensajeError(cCodRet) 
				INTO cCodRet,cMensaje;
				RETURN cCodRet, cMensaje;
			ELIF NVL(cEstatusProceso,'') = TERMINADO THEN
				-- Regresa error EL PROCESO YA FUE EJECUTADO
				LET cCodRet = '99954';
			
				EXECUTE PROCEDURE bdidomi:"informix".sp_ObtenerMensajeError(cCodRet) 
				INTO cCodRet,cMensaje;
				RETURN cCodRet, cMensaje;
			ELIF NVL(cEstatusProceso,'') = INICIADO THEN  
				-- INSTRUCCION SE ESTA PROCESANDO
				LET cCodRet = '99955';
			
				EXECUTE PROCEDURE bdidomi:"informix".sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
				RETURN cCodRet, cMensaje;
			ELIF NVL(cEstatusProceso,'') in ('',ERROR) then
				-- Aqui se buscan los pendientes de pago 
				EXECUTE PROCEDURE bdidomi:"informix".sp_domi_pendientes_pago() INTO vsCodRetorno2;
			
				-- Iniciar el proceso en la bitacora
				EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, 
					INICIADO, '00000', pUsuario, cSPProceso, cNom_Arch_Salida, cFechaFormat, '11')
				INTO vsCodRetorno2;
			
				LET cFechaCargo = YEAR(dFecha_hoy)::CHAR(4)||LPAD(MONTH(dFecha_hoy),2,'0') || LPAD(DAY(dFecha_hoy),2,'0');
			
				SELECT COUNT(consecutivo) INTO iExiste 
				FROM bdidomi:"informix".dom_cte_detalle 
				WHERE tipo_registro = 'B' and accion='A' and fecha_envio = dFecha_hoy and estatus='EP' and cve_banco_cargo = '137';
				
				IF iExiste = 0 THEN 
					-- NO HAY INSTRUCCIONES POR PROCESAR
					LET cCodRet = '99956';
				
					EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, 
								ERROR, cCodret, pUsuario, cSPProceso, cNom_Arch_Salida, cFechaFormat, '11')
					INTO vsCodRetorno2;
					EXECUTE PROCEDURE bdidomi:"informix".sp_ObtenerMensajeError(cCodret) 
					INTO cCodret,cMensaje;
					RETURN cCodRet, cMensaje;	
				END IF;
			
				LET cEstatusProceso = INICIADO;
				
				--insertar en archivo 
				INSERT INTO bdidomi:"informix".dom_cte_archivos(nombre_arch,fecha_envio,num_cte,fecha_carga,cve_status,user_insert,fecha_insert)values(cNom_Arch_Salida,dFecha_hoy,LPAD(TRIM(cNumeroCliente),20,'0'),dFecha_hoy,'01',pUsuario,today);
				
				--insertar en encabezado
				INSERT INTO bdidomi:"informix".dom_cte_encabezado(nombre_arch,fecha_envio,tipo_registro,num_cte,cuenta_abono,num_operaciones,fecha_inicial,fecha_final,user_insert,fecha_insert)
				VALUES(cNom_Arch_Salida,dFecha_hoy,'E',LPAD(TRIM(cNumeroCliente),20,'0'), LPAD('',20,'0'),
				LPAD('',8,'0'),cFechaFormat,cFechaFormat,pUsuario,today);
			
				-- Validar que haya instrucciones de Alta por procesar 
				FOREACH WITH HOLD 
					SELECT nombre_arch, cuenta_cargo,cuenta_abono,consecutivo,rfc_cargo,ref_leyenda,
					       fecha_envio,cve_banco_cargo,ref_servicio,ref_titular_serv,reintentar_cuenta,ref_numerica,tipo_registro,folio_suc
					INTO cNom_Arch_Aux, cClabeoTarjeta_Cargo,cCuentaAbono_Prov,iSecuencia,cRFC_Cargo,cRef_Leyenda,dFechaEnvio,
						 cCveBanco_Cargo,cRef_servicio,cRef_titular_serv, cReintentarCuenta,cRefNumerica,cTipoRegistro,cFolioActivacion
					FROM bdidomi:"informix".dom_cte_detalle
					WHERE tipo_registro = 'B' and accion='A' and fecha_envio = dFecha_hoy and estatus='EP' and cve_banco_cargo = '137'
					ORDER by consecutivo
					
					EXECUTE PROCEDURE bdidomi:"informix".sp_domi_generafolio(pUsuario,cFolioActivacion) INTO cNumeroFolioCargo;
								
					--Se obtiene el tipo de Pago de domiciliacion y numero de cliente
					SELECT cve_domiciliar_tc, num_cte INTO cTipoPago, cNumCte
					FROM bdidomi:"informix".dom_autorizaciones WHERE folio_activacion = cFolioActivacion;
					
					-- Se obtiene el monto a pagar
					EXECUTE PROCEDURE bdidomi:"informix".sp_domi_proximo_pago(cTipoPago,'001', ltrim(cCuentaAbono_Prov,'0'), pUsuario, cFolioActivacion, pTipoDomi) 
					INTO vsCodRetorno2,mMontoPagar;
									
					-- Se obtiene los datos de la cuenta cargo del cliente
					--RQM 09 704. Se agregan las variables de saldos de la cuenta para el calculo de saldo disponible.
					SELECT cuenta,status_cta,producto,sdo_actual,sdo_cong,sdo_retenido,imp_chq_sbg,saldo_sbc
					INTO cCuentaCargo,cEstatusCtaCargo,cProductoCtaCargo,mSdoActual,mSdoCong,mSdoRetenido,mImpChqSbg,mSaldoSBC
					FROM bdicheq:"informix".sc_maechq WHERE empresa = '001' AND cuenta = ltrim(cClabeoTarjeta_Cargo,'0') AND num_cte= cNumCte;
				
					--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
					EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('',mSdoActual,mSdoRetenido,mSdoCong,mSaldoSBC,mImpChqSbg,0.00,0.00,'F',1) INTO cCodRetConsSdo,cMensajeRetConsSdo,mSaldoActual;        
			
					SELECT periodo,fecha_pago,nvl(fecha_ult_pago,fecha_pago),fecha_prox_pago,fecha_inicio,fecha_fin 
					INTO cPeriodo,dFechaPago,dFechaUltimoPago,dFechaProximoPago,dFecha_Inicio,dFecha_Fin
					FROM bdidomi:"informix".dom_fecha_pago where folio_activacion = cFolioActivacion;
				
					-- Obtener los datos del cliente
					EXECUTE PROCEDURE bdidomi:"informix".sp_domi_consultardatoscliente(cNumCte,pUsuario) 
					INTO vsCodRetorno2, cNumCte, cNombreCte, cRFC, cRazonSocial, cNumTelefono, cCorreoElect;
					
					SELECT TRIM(nombre1), TRIM(apell_paterno) INTO cNombre1Cte, cApellido1Cte
					FROM bdinteg:"informix".si_cliente
					WHERE numcte = cNumCte
					AND empresa = '001';
				
					-- Obtener los datos del producto para la plantilla
					SELECT b.descripcion,d.nombre_corto,SUBSTR(TRIM(a.num_tarjeta), -4), a.num_tarjeta 
					INTO cProductName,cProductShortName,cCuentaAbonoShortX,cNum_TarjetaAbono
					FROM bdicred:"informix".sd_tarjeta a 
					inner join bdicred:"informix".sd_maecred c on a.num_credito = c.num_credito
					inner join bdicred:"informix".sd_productos_sdoret b on b.num_producto = c.num_producto
					inner join bdidomi:"informix".dom_prod_permitidos_tc d on c.num_producto = d.cve_producto 
					WHERE a.numcte = cNumCte and a.num_credito = ltrim(cCuentaAbono_Prov,'0') and a.status_tar <>'C' and c.empresa='001' and c.status_cred in ('E1','E2','E3');

					LET cCuentaCargoX = replace(cClabeoTarjeta_Cargo,substr(cClabeoTarjeta_Cargo,0,length(cClabeoTarjeta_Cargo)-4),'XXXXXXXXXXXX');
					
					LET cCuentaAbonoX = replace(cNum_TarjetaAbono,substr(cNum_TarjetaAbono,0,length(cNum_TarjetaAbono)-4),'XXXXXXXXXXXX');
					
					IF cCuentaCargo IS NULL OR cCuentaCargo = '' THEN
						-- CUENTA INEXISTENTE
						LET cCodRet = '99959';
						
						UPDATE bdidomi:"informix".dom_archivomanual SET imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),causa_rechazo = '01'
						WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP';
					
						UPDATE bdidomi:"informix".dom_cte_detalle SET estatus = '02', causa_rechazo =  '01', imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),folio_suc='' 
						WHERE consecutivo = iSecuencia AND fecha_envio = dFechaEnvio AND nombre_arch = cNom_Arch_Aux AND tipo_registro = cTipoRegistro;
					
						INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo,cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,
						estatus,causa_rechazo,user_insert,fecha_insert,tipo_cta_abono,folio_suc)
						SELECT FIRST 1 cNom_Arch_Salida,fecha_envio,'S',consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo,cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,estatus,causa_rechazo,pUsuario,today, tipo_cta_abono,folio_suc
						FROM bdidomi:"informix".dom_cte_detalle
						WHERE consecutivo = iSecuencia and fecha_envio = dFechaEnvio and nombre_arch = cNom_Arch_Aux and  tipo_registro = cTipoRegistro;
					
						-- validar intento, se programa para el siguiente periodo
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(3,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio, cFolioActivacion,cNumCte,'02',pUsuario) INTO vsCodRetorno2;
					
						-- Notificar al cliente SMS
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGNOEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX,
						'',cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') into vsCodRetorno2;
						
						-- Notificar al cliente Email
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','NO EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX,
						cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;
				
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso,ERROR, cCodret, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11')
						INTO vsCodRetorno2;
							
						CONTINUE FOREACH;
					END IF;
					
					-- VALIDA SI LA CUENTA ESTA CANCELADA.
					IF cEstatusCtaCargo = '2' THEN
					
						LET cCodRet = '99962';
						
						UPDATE bdidomi:"informix".dom_archivomanual SET imp_operacion =LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),causa_rechazo = '03'
						WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP';
					
						UPDATE bdidomi:"informix".dom_cte_detalle SET estatus = '02',causa_rechazo = '03',imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),folio_suc='' 
						WHERE consecutivo = iSecuencia AND fecha_envio = dFechaEnvio AND nombre_arch = cNom_Arch_Aux AND tipo_registro = cTipoRegistro;
						
						INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo, cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,
						estatus,causa_rechazo,user_insert,fecha_insert,tipo_cta_abono,folio_suc)
						SELECT FIRST 1 cNom_Arch_Salida,fecha_envio,'S',consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo,cuenta_cargo,rfc_cargo, nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,estatus,causa_rechazo,pUsuario,today,tipo_cta_abono,folio_suc
						FROM bdidomi:"informix".dom_cte_detalle
						WHERE consecutivo = iSecuencia and fecha_envio = dFechaEnvio and nombre_arch = cNom_Arch_Aux and  tipo_registro = cTipoRegistro;
					
						-- validar intento, se programa para el siguiente periodo
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(3,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio, cFolioActivacion,cNumCte,'02',pUsuario) INTO vsCodRetorno2;
					
						-- Notificar al cliente SMS
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGNOEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX,
						'',cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') into vsCodRetorno2;
						
						-- Notificar al cliente Email
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','NO EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX,
						cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;
				
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, 
							ERROR, cCodret, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11')
						INTO vsCodRetorno2;
					
						CONTINUE FOREACH;
					END IF;
					
					-- VALIDA SI LA CUENTA ESTA BLOQUEADA
					IF cEstatusCtaCargo = '3' THEN
						
						LET cCodRet = '99963';
					
						UPDATE bdidomi:"informix".dom_archivomanual SET imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),causa_rechazo = '02'
						WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP';
						
						UPDATE bdidomi:"informix".dom_cte_detalle SET estatus = '02',causa_rechazo = '02',imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),folio_suc='' 
						WHERE consecutivo = iSecuencia AND fecha_envio = dFechaEnvio AND nombre_arch = cNom_Arch_Aux AND tipo_registro = cTipoRegistro;
						
						INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo, cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta, estatus,causa_rechazo,user_insert,fecha_insert,tipo_cta_abono,folio_suc)
						SELECT FIRST 1 cNom_Arch_Salida,fecha_envio,'S',consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo,cuenta_cargo,rfc_cargo, nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,estatus,causa_rechazo,pUsuario,today,tipo_cta_abono,folio_suc
						FROM bdidomi:"informix".dom_cte_detalle
						WHERE consecutivo = iSecuencia and fecha_envio = dFechaEnvio and nombre_arch = cNom_Arch_Aux and  tipo_registro = cTipoRegistro;
					
						-- validar intento, se programa para el siguiente periodo
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(3,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio, cFolioActivacion,cNumCte,'02',pUsuario) INTO vsCodRetorno2;
					
						-- Notificar al cliente SMS
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGNOEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX,
						'',cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') into vsCodRetorno2;
						
						-- Notificar al cliente Email
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','NO EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX,
						cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;
				
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, ERROR, cCodret, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11')
						INTO vsCodRetorno2;
					
						CONTINUE FOREACH;
					END IF;
				
					-- VALIDA SI ESTATUS DE CUENTA ES PERMITIDA
					IF (cEstatusCtaCargo <> '1' AND cEstatusCtaCargo <> '4' AND cEstatusCtaCargo <> '5') OR (cEstatusCtaCargo IS NULL AND cEstatusCtaCargo = '') THEN
						
						UPDATE bdidomi:"informix".dom_archivomanual SET imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),causa_rechazo = '17'
						WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP';
					
						UPDATE bdidomi:"informix".dom_cte_detalle SET estatus = '02',causa_rechazo = '17',imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),folio_suc='' 
						WHERE consecutivo = iSecuencia AND fecha_envio = dFechaEnvio AND nombre_arch = cNom_Arch_Aux AND tipo_registro = cTipoRegistro;
						
						INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo, cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,
						estatus,causa_rechazo,user_insert,fecha_insert,tipo_cta_abono,folio_suc)
						SELECT FIRST 1 cNom_Arch_Salida,fecha_envio,'S',consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo,cuenta_cargo,rfc_cargo, nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,estatus,causa_rechazo,pUsuario,today,tipo_cta_abono,folio_suc
						FROM bdidomi:"informix".dom_cte_detalle
						WHERE consecutivo = iSecuencia and fecha_envio = dFechaEnvio and nombre_arch = cNom_Arch_Aux and  tipo_registro = cTipoRegistro;
					
						-- validar intento, se programa para el siguiente periodo
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(3,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio, cFolioActivacion,cNumCte,'02',pUsuario) INTO vsCodRetorno2;
					
						-- Notificar al cliente SMS
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGNOEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX,
						'',cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') into vsCodRetorno2;
						
						-- Notificar al cliente Email
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','NO EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX,
						cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;
					
						-- Se guarda en bitacora que no se pudo realizar el cobro por la TDC
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, ERROR, cCodret, pUsuario, cSPProceso, cNom_Arch_Salida, cFechaFormat, '11')
						INTO vsCodRetorno2;

						CONTINUE FOREACH;
					END IF;
				
					IF NOT cProductoCtaCargo IS NULL OR NOT cProductoCtaCargo = "" THEN
						SELECT 1 INTO iExiste FROM bdicheq:"informix".sc_producto WHERE producto = cProductoCtaCargo AND divisa = '01';
						
						--	VALIDA CUENTA EN OTRA DIVISA
						IF iExiste <> 1 OR iExiste IS NULL THEN
							
							LET cCodRet = '99964';
						
							UPDATE bdidomi:"informix".dom_archivomanual SET imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),causa_rechazo = '05'
							WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP';
							
							UPDATE bdidomi:"informix".dom_cte_detalle SET estatus = '02', causa_rechazo = '05',imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),folio_suc='' 
							WHERE consecutivo = iSecuencia AND fecha_envio = dFechaEnvio AND nombre_arch = cNom_Arch_Aux AND tipo_registro = cTipoRegistro;
						
							INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo, cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta, estatus,causa_rechazo,user_insert,fecha_insert,tipo_cta_abono,folio_suc)
							SELECT FIRST 1 cNom_Arch_Salida,fecha_envio,'S',consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo,cuenta_cargo,rfc_cargo, nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,estatus,causa_rechazo,pUsuario,today,tipo_cta_abono,folio_suc
							FROM bdidomi:"informix".dom_cte_detalle
							WHERE consecutivo = iSecuencia and fecha_envio = dFechaEnvio and nombre_arch = cNom_Arch_Aux and  tipo_registro = cTipoRegistro;
						
							-- validar intento, se programa para el siguiente periodo
							EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(3,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio, cFolioActivacion,cNumCte,'02',pUsuario) INTO vsCodRetorno2;
					
							-- Notificar al cliente SMS
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGNOEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX,
							'',cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') into vsCodRetorno2;
						
							-- Notificar al cliente Email
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','NO EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX,
							cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;
				
							EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, ERROR, cCodret, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11')
							INTO vsCodRetorno2;
						
							CONTINUE FOREACH;
						END IF;
					END IF;
				
					LET iExiste=0;
					-- VALIDA QUE EL CLIENTE SEA UNA PERSONA FISICA.
					SELECT 1 INTO iExiste FROM bdicheq:"informix".sc_maechq mae INNER JOIN bdinteg:si_cliente cte ON mae.num_cte = cte.numcte
					WHERE mae.empresa = '001' AND mae.cuenta = cCuentaCargo AND cte.tpo_persona = '01';
					
					IF iExiste <>1 OR iExiste IS NULL THEN
						--	CLIENTE NO TIENE AUTORIZADO EL SERVICIO
						LET cCodRet = '99965';
						
						UPDATE bdidomi:"informix".dom_archivomanual SET imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),causa_rechazo = '11'
						WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP';
					
						UPDATE bdidomi:"informix".dom_cte_detalle SET estatus = '02', causa_rechazo = '11',imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),folio_suc='' 
						WHERE consecutivo = iSecuencia AND fecha_envio = dFechaEnvio AND nombre_arch = cNom_Arch_Aux AND tipo_registro = cTipoRegistro;
						
						INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo, cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta, estatus,causa_rechazo,user_insert,fecha_insert,tipo_cta_abono,folio_suc)
						SELECT FIRST 1 cNom_Arch_Salida,fecha_envio,'S',consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo,cuenta_cargo,rfc_cargo, nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,estatus,causa_rechazo,pUsuario,today,tipo_cta_abono,folio_suc
						FROM bdidomi:"informix".dom_cte_detalle
						WHERE consecutivo = iSecuencia and fecha_envio = dFechaEnvio and nombre_arch = cNom_Arch_Aux and  tipo_registro = cTipoRegistro;
					
						-- validar intento, se programa para el siguiente periodo
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(3,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio, cFolioActivacion,cNumCte,'02',pUsuario) INTO vsCodRetorno2;
					
						-- Notificar al cliente SMS
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGNOEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX,
						'',cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') into vsCodRetorno2;
						
						-- Notificar al cliente Email
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','NO EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX,
						cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;
				
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, 
						ERROR, cCodret, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11')
						INTO vsCodRetorno2;
					
						CONTINUE FOREACH;
					END IF;
				
					LET iExiste=0;
					
					--CONSULTA SI EL CLIENTE ESTA AUTORIZADO EN EL SERVICIO DE DOMI.
					SELECT 1,cve_estatus,imp_maximo,folio_activacion,cve_domiciliar_tc,num_cte 
					INTO iExiste,cEstatusAutorizacion,mImp_maximo,cFolioActivacion,cTipoPago,cNumCte
					FROM bdidomi:"informix".dom_autorizaciones WHERE folio_activacion = cFolioActivacion AND cve_estatus = '01';
				
					IF iExiste <>1 OR iExiste IS NULL THEN
						-- CLIENTE NO AUTORIZADO EL SERVICIO
						LET cCodRet = '99965';
						
						UPDATE bdidomi:"informix".dom_archivomanual SET imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),causa_rechazo = '11'
						WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP';
					
						UPDATE bdidomi:"informix".dom_cte_detalle SET estatus = '02', causa_rechazo = '11',imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),folio_suc='' 
						WHERE consecutivo = iSecuencia AND fecha_envio = dFechaEnvio AND nombre_arch = cNom_Arch_Aux AND tipo_registro = cTipoRegistro;
						
						INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo, cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,
						estatus,causa_rechazo,user_insert,fecha_insert,tipo_cta_abono,folio_suc)
						SELECT FIRST 1 cNom_Arch_Salida,fecha_envio,'S',consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo,cuenta_cargo,rfc_cargo, nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,estatus,causa_rechazo,pUsuario,today,tipo_cta_abono,folio_suc
						FROM bdidomi:"informix".dom_cte_detalle
						WHERE consecutivo = iSecuencia and fecha_envio = dFechaEnvio and nombre_arch = cNom_Arch_Aux and  tipo_registro = cTipoRegistro;
					
						-- validar intento, se programa para el siguiente periodo
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(3,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio, cFolioActivacion,cNumCte,'02',pUsuario) INTO vsCodRetorno2;
					
						-- Notificar al cliente SMS
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGNOEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX,
						'',cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') into vsCodRetorno2;
						
						-- Notificar al cliente Email
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','NO EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX,
						cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;
				
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, ERROR, cCodret, pUsuario, cSPProceso, cNom_Arch_Salida, cFechaFormat, '11')
						INTO vsCodRetorno2;
					
						CONTINUE FOREACH;					
					END IF;
					
					LET iExiste=0;

					-- SE OBTIENE EL DIA DE CORTE DE LA CUENTA DE CREDITO.
					SELECT dia_corte - 1 INTO cFechaCortePago FROM bdicred:"informix".sd_maecredanexo 
					WHERE num_credito = ltrim(cCuentaAbono_Prov,'0') and empresa='001';						
				
					-- Validar que el cliente tenga definido un monto maximo.
					IF mImp_maximo = 0.00 THEN
						-- CLIENTE NO TIENE MONTO MAXIMO
						LET cCodRet = '99966'; 
						
						UPDATE bdidomi:"informix".dom_archivomanual SET imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),causa_rechazo = '14'
						WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP';
					
						UPDATE bdidomi:"informix".dom_cte_detalle SET estatus = '02', causa_rechazo = '14',imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),folio_suc='' 
						WHERE consecutivo = iSecuencia AND fecha_envio = dFechaEnvio AND nombre_arch = cNom_Arch_Aux AND tipo_registro = cTipoRegistro;
						
						INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo, cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,
						estatus,causa_rechazo,user_insert,fecha_insert,tipo_cta_abono,folio_suc)
						SELECT FIRST 1 cNom_Arch_Salida,fecha_envio,'S',consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo,cuenta_cargo,rfc_cargo, nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,estatus,causa_rechazo,pUsuario,today,tipo_cta_abono,folio_suc
						FROM bdidomi:"informix".dom_cte_detalle
						WHERE consecutivo = iSecuencia and fecha_envio = dFechaEnvio and nombre_arch = cNom_Arch_Aux and  tipo_registro = cTipoRegistro;
				
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, ERROR, cCodret, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11')
						INTO vsCodRetorno2;
					
						-- Validar que sea fecha antes o igual que la fecha limite de pago
						IF TO_CHAR(dFecha_hoy,'%d') < cFechaCortePago THEN
							-- PASAR A QUE SE HAGAN LOS TRES INTENTOS POR PERIODO
							SELECT num_periodo,num_intento into cPeriodo,iIntentos FROM bdidomi:"informix".dom_archivomanual
							WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP'; 
						
							EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(iIntentos,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio,
							cFolioActivacion,cNumCte,'02',pUsuario) into vsCodRetorno2;
						
							SELECT fecha_prox_pago
							INTO dFechaPagoSiguiente
							FROM bdidomi:"informix".dom_fecha_pago 
							WHERE folio_activacion = cFolioActivacion;
						
							LET iIntentos = iIntentos + 1;
							IF iIntentos = 3 THEN 
								-- Notificar al cliente SMS
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGNOEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX,
								'',cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') into vsCodRetorno2;
						
								-- Notificar al cliente Email
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','NO EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX,
								cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;
						
								CONTINUE FOREACH;
							END IF;
						
							LET cDiaMes = to_char(dFechaPagoSiguiente,'%d/%m');
						
							-- Notificar al cliente SMS
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_REINPAG',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX, cDiaMes,cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') INTO vsCodRetorno2;
						
							CONTINUE FOREACH;
						END IF;
					
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(3,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio, cFolioActivacion,cNumCte,'02',pUsuario) into vsCodRetorno2;
					
						-- Notificar al cliente SMS
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGNOEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX,
						'',cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') into vsCodRetorno2;
						
						-- Notificar al cliente Email
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','NO EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX,
						cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;
						
						CONTINUE FOREACH;
					END IF;
				
					-- Validar el monto maximo  no supere al limite de importe.
					IF mImp_maximo > mlim_importe THEN
						-- SUPERA MONTO MAXIMO PERMITIDO POR OPERACION
						LET cCodRet = '99967';
						
						UPDATE bdidomi:"informix".dom_archivomanual SET imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),causa_rechazo = '15'
						WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP';
					
						UPDATE bdidomi:"informix".dom_cte_detalle SET estatus = '02', causa_rechazo = '15',imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),folio_suc='' 
						WHERE consecutivo = iSecuencia AND fecha_envio = dFechaEnvio AND nombre_arch = cNom_Arch_Aux AND tipo_registro = cTipoRegistro;
						
						INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo, cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,
						estatus,causa_rechazo,user_insert,fecha_insert,tipo_cta_abono,folio_suc)
						SELECT FIRST 1 cNom_Arch_Salida,fecha_envio,'S',consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo,cuenta_cargo,rfc_cargo, nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,estatus,causa_rechazo,pUsuario,today,tipo_cta_abono,folio_suc
						FROM bdidomi:"informix".dom_cte_detalle
						WHERE consecutivo = iSecuencia and fecha_envio = dFechaEnvio and nombre_arch = cNom_Arch_Aux and  tipo_registro = cTipoRegistro;
					
						-- validar intento, se programa para el siguiente periodo
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(3,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio, cFolioActivacion,cNumCte,'02',pUsuario) INTO vsCodRetorno2;
					
						-- Notificar al cliente SMS
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGNOEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX,
						'',cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') into vsCodRetorno2;
						
						-- Notificar al cliente Email
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','NO EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX,
						cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;
				
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, ERROR, cCodret, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11')
						INTO vsCodRetorno2;
							
						CONTINUE FOREACH;
					END IF;
					
					-- Validar monto a pagar > al monto maximo
					IF mMontoPagar > mImp_maximo THEN
						LET mMontoPagar = mImp_maximo;
					END IF;
				
					IF mMontoPagar = 0.00 THEN
						UPDATE bdidomi:"informix".dom_archivomanual SET imp_operacion = LPAD(0,15,'0'),causa_rechazo = '16'
						WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP';
					
						UPDATE bdidomi:"informix".dom_cte_detalle SET estatus = '02', causa_rechazo = '16',imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),folio_suc=''
						WHERE consecutivo = iSecuencia AND fecha_envio = dFechaEnvio AND nombre_arch = cNom_Arch_Aux AND tipo_registro = cTipoRegistro;
						
						INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo, cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,
						estatus,causa_rechazo,user_insert,fecha_insert,tipo_cta_abono,folio_suc)
						SELECT FIRST 1 cNom_Arch_Salida,fecha_envio,'S',consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo,cuenta_cargo,rfc_cargo, nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,estatus,causa_rechazo,pUsuario,today,tipo_cta_abono,folio_suc
						FROM bdidomi:"informix".dom_cte_detalle
						WHERE consecutivo = iSecuencia and fecha_envio = dFechaEnvio and nombre_arch = cNom_Arch_Aux and  tipo_registro = cTipoRegistro;
					
						-- validar intento , se programa para el siguiente periodo por no deber nada
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(3,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio, cFolioActivacion,cNumCte,'02',pUsuario) into vsCodRetorno2; 
						CONTINUE FOREACH;
					END IF;
				
					--VALIDA QUE EL SALDO ACTUAL DE LA CUENTA ALCANZE A PAGAR EL MONTO.
					IF mMontoPagar > mSaldoActual THEN
						UPDATE bdidomi:"informix".dom_archivomanual SET imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),causa_rechazo = '04'
						WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP';
					
						UPDATE bdidomi:"informix".dom_cte_detalle SET estatus = '02',causa_rechazo = '04',imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),folio_suc='' 
						WHERE consecutivo = iSecuencia AND fecha_envio = dFechaEnvio AND nombre_arch = cNom_Arch_Aux AND tipo_registro = cTipoRegistro;
						
						INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo, cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,
						estatus,causa_rechazo,user_insert,fecha_insert,tipo_cta_abono,folio_suc)
						SELECT FIRST 1 cNom_Arch_Salida,fecha_envio,'S',consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo,cuenta_cargo,rfc_cargo, nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,estatus,causa_rechazo,pUsuario,today,tipo_cta_abono,folio_suc
						FROM bdidomi:"informix".dom_cte_detalle
						WHERE consecutivo = iSecuencia and fecha_envio = dFechaEnvio and nombre_arch = cNom_Arch_Aux and  tipo_registro = cTipoRegistro;
					
						-- Validar que sea fecha antes o igual que la fecha limite de pago
						IF TO_CHAR(dFecha_hoy,'%d') < cFechaCortePago THEN
							-- PASAR A QUE SE HAGAN LOS TRES INTENTOS POR PERIODO
							SELECT num_periodo,num_intento into cPeriodo,iIntentos FROM bdidomi:"informix".dom_archivomanual
							WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP'; 
							-- validar intento, se programa el cobro nuevamente
							EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(iIntentos,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio,
							cFolioActivacion,cNumCte,'02',pUsuario) into vsCodRetorno2; 
							
							SELECT fecha_prox_pago
							INTO dFechaPagoSiguiente
							FROM bdidomi:"informix".dom_fecha_pago 
							WHERE folio_activacion = cFolioActivacion;
						
							LET iIntentos = iIntentos + 1;
							-- Se valida intentos de cobro por periodo
							IF iIntentos = 3 THEN 
								-- COBRO NO EXITOSO FINAL
								LET cCodRet = '99968';
							
								EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, 
								ERROR, cCodret, pUsuario, cSPProceso, cNom_Arch_Salida, cFechaFormat, '11')
								INTO vsCodRetorno2;
						
								-- Notificar al cliente SMS
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGNOEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX,
								'',cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') into vsCodRetorno2;
						
								-- Notificar al cliente Email
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','NO EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX,
								cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;
						
								CONTINUE FOREACH;
							END IF;
						
							-- COBRO NO EXITOSO REINTENTA PAGO
							LET cCodRet = '99969';
						
							EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso,ERROR, cCodret, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11')
							INTO vsCodRetorno2;
					
							LET cDiaMes = to_char(dFechaPagoSiguiente,'%d/%m');
						
							-- Notificar al cliente SMS
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_REINPAG',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX, cDiaMes,cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') INTO vsCodRetorno2;
							
							CONTINUE FOREACH;
						END IF;
					
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(3,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio, cFolioActivacion,cNumCte,'02',pUsuario) into vsCodRetorno2;
					
						-- COBRO NO EXITOSO FINAL
						LET cCodRet = '99968';
							
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso,ERROR, cCodret, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11')
						INTO vsCodRetorno2;
						
						-- Notificar al cliente SMS
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGNOEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX,
						'',cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') into vsCodRetorno2;
						
						-- Notificar al cliente Email
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','NO EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX,
						cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;					
						
						CONTINUE FOREACH;
					END IF;
				
					-- Obtener lo datos de la cuenta de credito del cliente
					SELECT 1 num_credito, divisa, status_cred
					INTO cCuentaAbono, cDivisaAbono, cEstatusCtaAbono 
					FROM bdicred:"informix".sd_maecred
					WHERE num_credito = ltrim(cCuentaAbono_Prov,'0') and numcte = cNumCte and empresa = "001";
					
					-- Valida si la cuenta es inexistente
					IF cCuentaAbono IS NULL OR cCuentaAbono = '' THEN
						
						LET cCodRet = '99959';
						
						UPDATE bdidomi:"informix".dom_archivomanual SET imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),causa_rechazo = '01'
						WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP';
					
						UPDATE bdidomi:"informix".dom_cte_detalle SET estatus = '02', causa_rechazo =  '01',imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),folio_suc='' 
						WHERE consecutivo = iSecuencia AND fecha_envio = dFechaEnvio AND nombre_arch = cNom_Arch_Aux AND tipo_registro = cTipoRegistro;
					
						INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo,cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,
						estatus,causa_rechazo,user_insert,fecha_insert,tipo_cta_abono,folio_suc)
						SELECT FIRST 1 cNom_Arch_Salida,fecha_envio,'S',consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo,cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,estatus,causa_rechazo,pUsuario,today, tipo_cta_abono,folio_suc
						FROM bdidomi:"informix".dom_cte_detalle
						WHERE consecutivo = iSecuencia and fecha_envio = dFechaEnvio and nombre_arch = cNom_Arch_Aux and  tipo_registro = cTipoRegistro;
					
						-- validar intento, se programa para el siguiente periodo
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(3,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio, cFolioActivacion,cNumCte,'02',pUsuario) INTO vsCodRetorno2;
					
						-- Notificar al cliente SMS
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGNOEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX,
						'',cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') into vsCodRetorno2;
						
						-- Notificar al cliente Email
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','NO EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX,
						cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;
				
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso,ERROR, cCodret, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11')
						INTO vsCodRetorno2;
							
						CONTINUE FOREACH;
					END IF;
					
					--	VALIDA CUENTA EN OTRA DIVISA
					IF cDivisaAbono <> '01' THEN
						
						LET cCodRet = '99964';
					
						UPDATE bdidomi:"informix".dom_archivomanual SET imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),causa_rechazo = '05'
						WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP';
						
						UPDATE bdidomi:"informix".dom_cte_detalle SET estatus = '02', causa_rechazo = '05',imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),folio_suc=''
						WHERE consecutivo = iSecuencia AND fecha_envio = dFechaEnvio AND nombre_arch = cNom_Arch_Aux AND tipo_registro = cTipoRegistro;
					
						INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo, cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta, estatus,causa_rechazo,user_insert,fecha_insert,tipo_cta_abono,folio_suc)
						SELECT FIRST 1 cNom_Arch_Salida,fecha_envio,'S',consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo,cuenta_cargo,rfc_cargo, nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,estatus,causa_rechazo,pUsuario,today,tipo_cta_abono,folio_suc
						FROM bdidomi:"informix".dom_cte_detalle
						WHERE consecutivo = iSecuencia and fecha_envio = dFechaEnvio and nombre_arch = cNom_Arch_Aux and  tipo_registro = cTipoRegistro;
					
						-- validar intento, se programa para el siguiente periodo
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(3,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio, cFolioActivacion,cNumCte,'02',pUsuario) INTO vsCodRetorno2;
					
						-- Notificar al cliente SMS
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGNOEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX,
						'',cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') into vsCodRetorno2;
						
						-- Notificar al cliente Email
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','NO EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX,
						cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;
			
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, ERROR, cCodret, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11')
						INTO vsCodRetorno2;
					
						CONTINUE FOREACH;
					END IF;
					
					-- VALIDA SI ESTATUS DE CUENTA ES PERMITIDA
					IF (cEstatusCtaAbono <> 'E1' AND cEstatusCtaAbono <> 'E2' AND cEstatusCtaAbono <> 'E3') OR (cEstatusCtaAbono IS NULL AND cEstatusCtaAbono = '') THEN
						
						UPDATE bdidomi:"informix".dom_archivomanual SET imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),causa_rechazo = '17'
						WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP';
					
						UPDATE bdidomi:"informix".dom_cte_detalle SET estatus = '02',causa_rechazo = '17',imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),folio_suc='' 
						WHERE consecutivo = iSecuencia AND fecha_envio = dFechaEnvio AND nombre_arch = cNom_Arch_Aux AND tipo_registro = cTipoRegistro;
						
						INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo, cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,
						estatus,causa_rechazo,user_insert,fecha_insert,tipo_cta_abono,folio_suc)
						SELECT FIRST 1 cNom_Arch_Salida,fecha_envio,'S',consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo,cuenta_cargo,rfc_cargo, nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,estatus,causa_rechazo,pUsuario,today,tipo_cta_abono,folio_suc
						FROM bdidomi:"informix".dom_cte_detalle
						WHERE consecutivo = iSecuencia and fecha_envio = dFechaEnvio and nombre_arch = cNom_Arch_Aux and  tipo_registro = cTipoRegistro;
					
						-- validar intento, se programa para el siguiente periodo por no tener tdc validada
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(3,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio, cFolioActivacion,cNumCte,'02',pUsuario) INTO vsCodRetorno2; 
					
						-- Notificar al cliente SMS
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGNOEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX,
						'',cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') into vsCodRetorno2;
						
						-- Notificar al cliente Email
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','NO EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX,
						cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;
						
						-- Se guarda en bitacora que no se pudo realizar el cobro por la TDC
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, ERROR, cCodret, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11')
						INTO vsCodRetorno2;

						CONTINUE FOREACH;
					END IF;
								
					LET iAplicoAbono = 0;
					LET iAplicoCargo = 0;
						
					-- LLamado al proceso de cargo
					EXECUTE PROCEDURE bdicheq:"informix".cargo_ref ("001", cSucursalContable, pUsuario, cTransaccCargo, "0000", cNumeroFolioCargo, cCuentaCargo,0, mMontoPagar,"01",cRef_Leyenda, '', pUsuario) 
					INTO cCodRet,cTranRet,dFechaProceso,mSdoDisp,mMontoRet;
				
					EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso,CARGO, cCodret, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11') INTO vsCodRetorno2;
				
					LET cCodRet = LPAD(TRIM(cCodRet),5,"0");
				
					IF cCodRet::INTEGER <> 0 THEN
						-- Realizar proceso de bdicheq:reversion
						EXECUTE PROCEDURE bdicheq:"informix".reversion("001", cSucursalContable,pUsuario,cNumeroFolioCargo,"") INTO cCodRet;
					
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, 
						REVERSION, cCodret, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11') INTO vsCodRetorno2;
					
						UPDATE bdidomi:"informix".dom_archivomanual SET imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),causa_rechazo = 'PR'
						WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP';
					
						UPDATE bdidomi:"informix".dom_cte_detalle SET estatus = '03', causa_rechazo = 'PR',imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),folio_suc=''
						WHERE consecutivo = iSecuencia AND fecha_envio = dFechaEnvio AND nombre_arch = cNom_Arch_Aux AND tipo_registro = cTipoRegistro;
						
						INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo, cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,
						estatus,causa_rechazo,user_insert,fecha_insert,tipo_cta_abono,folio_suc)
						SELECT FIRST 1 cNom_Arch_Salida,fecha_envio,'S',consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo,cuenta_cargo,rfc_cargo, nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,estatus,causa_rechazo,pUsuario,today,tipo_cta_abono,folio_suc
						FROM bdidomi:"informix".dom_cte_detalle
						WHERE consecutivo = iSecuencia and fecha_envio = dFechaEnvio and nombre_arch = cNom_Arch_Aux and  tipo_registro = cTipoRegistro;
					
						-- Validar que sea fecha antes o igual que la fecha limite de pago
						IF TO_CHAR(dFecha_hoy,'%d') < cFechaCortePago THEN
							-- Se obtienen los datos de los periodos e intentos de cobro
							SELECT num_periodo,num_intento INTO cPeriodo,iIntentos FROM bdidomi:"informix".dom_archivomanual
							WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP'; 
							-- validar intento , se programa el cobro nuevamente
							EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(iIntentos,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio, cFolioActivacion,cNumCte,'03',pUsuario) INTO cCodRet; 
						
							SELECT fecha_prox_pago
							INTO dFechaPagoSiguiente
							FROM bdidomi:"informix".dom_fecha_pago 
							WHERE folio_activacion = cFolioActivacion;
							
							-- FALLO EL CARGO A CUENTA DE DEBITO
							LET cCodRet = '99971';
						
							-- Grabar a bitacora
							EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, ERROR, cCodret, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11')
							INTO vsCodRetorno2;
					
							LET iIntentos = iIntentos + 1;
					
							-- Se valida intentos de cobro por periodo
							IF iIntentos = 3 THEN 
						
								-- Notificar al cliente SMS
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGNOEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX, 
								'',cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') into vsCodRetorno2;
						
								-- Notificar al cliente Email
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','NO EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX, cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;
						
								CONTINUE FOREACH;
							END IF;
					
							LET cDiaMes = to_char(dFechaPagoSiguiente,'%d/%m');
						
							-- Notificar al cliente SMS
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_REINPAG',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX, cDiaMes,cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') INTO vsCodRetorno2;
						
							CONTINUE FOREACH;
						END IF;
					
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(3,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio, cFolioActivacion,cNumCte,'03',pUsuario) into vsCodRetorno2;
					
						-- FALLO EL CARGO A CUENTA DE DEBITO
						LET cCodRet = '99971';
							
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, ERROR, cCodret, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11')
						INTO vsCodRetorno2;
						
						-- Notificar al cliente SMS
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGNOEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX, '',cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') into vsCodRetorno2;
						
						-- Notificar al cliente Email
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','NO EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX, cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;					
						
						CONTINUE FOREACH;
					ELSE
						LET iAplicoCargo = 1;
					
						EXECUTE PROCEDURE bdicred:"informix".principalrefer('001',ltrim(cCuentaAbono_Prov,'0'),1,cNum_TarjetaAbono,pUsuario,cSucursalContable,cNumeroFolioCargo, cTransaccAbono,0,mMontoPagar,cRef_servicio)
						INTO cCodRet, mRemanente, mIntMoraCobrado, mIntVencCobrado, mCapVencCobrado, mIntVigCobrado, mCapVigCobrado, mImpuestoCobrado, mComisionesCobradas, mSeguroCobrado;
					
						EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, ABONO, cCodRet, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11') INTO vsCodRetorno2;

						IF cCodRet::INTEGER <> 0 AND iAplicoCargo = 1 THEN
							-- Realizar proceso de bdicheq:reversion
							EXECUTE PROCEDURE bdicheq:"informix".reversion("001", cSucursalContable,pUsuario,cNumeroFolioCargo,"")INTO cCodRet;
						
							EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, REVERSION, cCodRet, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11') INTO vsCodRetorno2;
						
							UPDATE bdidomi:"informix".dom_archivomanual SET imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),causa_rechazo = 'PR'
							WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP';
						
							UPDATE bdidomi:"informix".dom_cte_detalle SET estatus = '03',causa_rechazo = 'PR',imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'),folio_suc=''
							WHERE consecutivo = iSecuencia AND fecha_envio = dFechaEnvio AND nombre_arch = cNom_Arch_Aux AND tipo_registro = cTipoRegistro;
						
							INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo, cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta, estatus,causa_rechazo,user_insert,fecha_insert,tipo_cta_abono,folio_suc)
							SELECT FIRST 1 cNom_Arch_Salida,fecha_envio,'S',consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo,cuenta_cargo,rfc_cargo, nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,estatus,causa_rechazo,pUsuario,today,tipo_cta_abono,folio_suc
							FROM bdidomi:"informix".dom_cte_detalle
							WHERE consecutivo = iSecuencia and fecha_envio = dFechaEnvio and nombre_arch = cNom_Arch_Aux and  tipo_registro = cTipoRegistro;
							
							-- Validar que sea fecha antes o igual que la fecha limite de pago
							IF TO_CHAR(dFecha_hoy,'%d') < cFechaCortePago THEN
								-- Se obtienen los datos de los periodos e intentos de cobro
								SELECT num_periodo,num_intento INTO cPeriodo,iIntentos FROM bdidomi:"informix".dom_archivomanual
								WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP';
								-- validar intento , se programa el cobro nuevamente
								EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(iIntentos,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio,cFolioActivacion,cNumCte,'03',pUsuario) into cCodRet;
					
								SELECT fecha_prox_pago
								INTO dFechaPagoSiguiente
								FROM bdidomi:"informix".dom_fecha_pago 
								WHERE folio_activacion = cFolioActivacion;
					
								-- FALLO EL ABONO A CUENTA DE CREDITO
								LET cCodRet = '99970';
							
								-- Grabar a bitacora
								EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, ERROR, cCodRet, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11')
								INTO vsCodRetorno2;
						
								LET iIntentos = iIntentos + 1;
							
								-- Se valida intentos de cobro por periodo
								IF iIntentos = 3 THEN 
						
									-- Notificar al cliente Email/SMS
									EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGNOEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX, '',cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') into vsCodRetorno2;
							
									-- Notificar al cliente Email
									EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','NO EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX, cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;
						
									CONTINUE FOREACH;
								END IF;
						
								LET cDiaMes = to_char(dFechaPagoSiguiente,'%d/%m');
						
								-- Notificar al cliente SMS
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_REINPAG',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX, cDiaMes,cProductShortName,'',cCorreoElect, cNumTelefono,0,0,0,0,0,'','') INTO vsCodRetorno2;
							
								CONTINUE FOREACH;
							END IF;
							
						
							EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(3,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio, cFolioActivacion,cNumCte,'03',pUsuario) into vsCodRetorno2;
					
							-- FALLO EL ABONO A CUENTA DE CREDITO
							LET cCodRet = '99970';
							
							EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, ERROR, cCodRet, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11')
							INTO vsCodRetorno2;
						
							-- Notificar al cliente SMS
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGNOEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX, '',cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') into vsCodRetorno2;
						
							-- Notificar al cliente Email
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','NO EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX, cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;					
						
							LET iAplicoCargo = 0;
							CONTINUE FOREACH;
						ELSE
							LET iAplicoAbono = 1;
						
							UPDATE bdidomi:"informix".dom_archivomanual SET imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0')
							WHERE folio_activacion = cFolioActivacion and accion = 'A' and estatus='EP';
							
							UPDATE bdidomi:"informix".dom_cte_detalle SET estatus = '01',imp_operacion = LPAD(TRIM((mMontoPagar*100)::INTEGER::CHAR(15)),15,'0'), folio_suc = cNumeroFolioCargo
							WHERE consecutivo = iSecuencia AND fecha_envio = dFechaEnvio AND nombre_arch = cNom_Arch_Aux AND tipo_registro = cTipoRegistro;
						
							INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo, cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta, estatus,causa_rechazo,user_insert,fecha_insert,tipo_cta_abono,folio_suc)
							SELECT FIRST 1 cNom_Arch_Salida,fecha_envio,'S',consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo,cve_banco_cargo,cuenta_cargo,rfc_cargo, nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,estatus,causa_rechazo,pUsuario,today,tipo_cta_abono,folio_suc
							FROM bdidomi:"informix".dom_cte_detalle
							WHERE consecutivo = iSecuencia and fecha_envio = dFechaEnvio and nombre_arch = cNom_Arch_Aux and  tipo_registro = cTipoRegistro;
					
							-- actualizar dom_pago
							UPDATE bdidomi:"informix".dom_pago SET monto_ultimo_pago = mMontoPagar WHERE folio_activacion = cFolioActivacion;
						
							UPDATE bdidomi:"informix".dom_fecha_pago SET fecha_ult_pago = dFecha_hoy WHERE folio_activacion = cFolioActivacion;
						
							-- validar intento , se programa el cobro nuevamente
							EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_intentos(3,cPeriodo,dFechaProximoPago,cNom_Arch_Aux,dFechaEnvio, cFolioActivacion,cNumCte,'01',pUsuario) into cCodRet;
						
							LET cDiaMes = to_char(dFecha_hoy,'%d/%m');
							
							-- Notificar al cliente SMS
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PAGEXI',cNumCte,'','','1','','','','',cProductName,'',cCuentaAbonoShortX, cDiaMes,cProductShortName,'',cCorreoElect,cNumTelefono,0,0,0,0,0,'','') INTO vsCodRetorno2;
							
							-- Notificar al cliente Email
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_COBRO',cNumCte,'','','1','EXITOSO',cFolioActivacion,cCuentaCargoX,cCuentaAbonoX, cProductName,cNombre1Cte,cCuentaAbonoShortX,'','',cApellido1Cte,cCorreoElect,cNumTelefono,0,mMontoPagar,0,0,0,'',current) into vsCodRetorno2;
						
							LET iAplicoAbono = 0;
							LET iAplicoCargo = 0;
						END IF;
					END IF;
				END FOREACH;
			
				SELECT count(*), NVL(SUM(imp_operacion::INTEGER),0)
				INTO iTotalOperaciones, iImpTotalOperaciones
				FROM bdidomi:"informix".dom_cte_detalle WHERE fecha_envio = dFecha_hoy and tipo_registro='B' and accion='A' and cve_banco_cargo=137;
			
				-- Sumatoria de domiciliaciones aplicadas con exito
				SELECT count(*), NVL(SUM(imp_operacion::INTEGER),0)
				INTO iAplicaciones, iImpAplicaciones
				FROM bdidomi:"informix".dom_cte_detalle WHERE fecha_envio = dFecha_hoy and tipo_registro='B' and accion='A' and cve_banco_cargo=137 and estatus = '01';
			
				-- Sumatoria de domiciliaciones rechazadas
				SELECT count(*), NVL(SUM(imp_operacion::INTEGER),0)
				INTO iRechazos, iImpRechazos
				FROM bdidomi:"informix".dom_cte_detalle WHERE fecha_envio = dFecha_hoy and tipo_registro='B' and accion='A' and cve_banco_cargo=137 and estatus = '02';
				
				-- Sumatoria de domiciliaciones pendientes
				SELECT count(*), NVL(SUM(imp_operacion::INTEGER),0)
				INTO iPendientes, iImpPendientes
				FROM bdidomi:"informix".dom_cte_detalle WHERE fecha_envio = dFecha_hoy and tipo_registro='B' and accion='A' and cve_banco_cargo=137 and estatus = '03';
			
				begin work;
				LET cInTransaction = 'S';
				
				-- Actualizacion de operaciones en encabezado
				UPDATE bdidomi:"informix".dom_cte_encabezado 
				SET num_operaciones = LPAD(TRIM(iTotalOperaciones::CHAR(8)),8,'0')
				WHERE nombre_arch = cNom_Arch_Salida;	
				
				-- insertar en sumario
				INSERT INTO bdidomi:"informix".dom_cte_sumario(nombre_arch,fecha_envio,tipo_registro,num_operaciones,
				imp_operaciones,num_oper_pend,imp_oper_pend,num_oper_apli,
				imp_oper_apli,num_oper_rech,imp_oper_rech,user_insert,fecha_insert)
				VALUES(cNom_Arch_Salida,dFecha_hoy,'S',
				LPAD(TRIM(iTotalOperaciones::CHAR(8)),8,'0'), LPAD(TRIM(iImpTotalOperaciones::CHAR(18)),18,'0'),
				LPAD(TRIM(iPendientes::CHAR(8)),8,0),LPAD(TRIM(iImpPendientes::CHAR(18)),18,'0'),
				LPAD(TRIM(iAplicaciones::CHAR(8)),8,0),LPAD(TRIM(iImpAplicaciones::CHAR(18)),18,'0'),
				LPAD(TRIM(iRechazos::CHAR(8)),8,0),LPAD(TRIM(iImpRechazos::CHAR(18)),18,'0'),
				pUsuario,today);
				commit work;
				LET cInTransaction = 'N';
			
				LET cCodRet = "00000";
				LET cEstatusProceso = TERMINADO;
			
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) 
				INTO cCodRet,cMensaje;
			END IF;
		
			EXECUTE PROCEDURE bdidomi:"informix".sp_domi_bitacora(pTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), cDescripcionProceso, cEstatusProceso, cCodRet, pUsuario, cSPProceso, cFolioActivacion, cFechaFormat, '11')
			INTO vsCodRetorno2;
		END IF;
	END IF;
END;
RETURN cCodRet, cMensaje;
END PROCEDURE DOCUMENT
'MODIFICO : Daniel Hernandez Garcia',
'FECHA : 17-06-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdidomi',
'VER   : 1.2';