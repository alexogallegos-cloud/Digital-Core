CREATE PROCEDURE "informix".sp_domi_cop_procesararchivo (cTipoEjecucion CHAR(1), pUsuario CHAR(8))
	RETURNING CHAR(5), CHAR(200);

	--	Definicion de variables.
	DEFINE dFecha_hoy					DATE;
	DEFINE dFechaManana					DATE;
	DEFINE iExiste						INTEGER;
	DEFINE iNumRechazos					INTEGER;
	DEFINE iContadorVueltas				INTEGER;
	DEFINE iSQLerr						INTEGER;
	DEFINE iSecuencia					INTEGER;
	DEFINE iMaximoRechazosPermitidos	INTEGER;
	DEFINE iAplicoCargo					INTEGER;
	DEFINE iAplicoAbono					INTEGER;
	
	DEFINE iContadorRepetidas			INTEGER;
	DEFINE cFisica						CHAR(1);
	DEFINE cEstatus						CHAR(1);
	DEFINE cEstatusCtaCargo				CHAR(1);
	DEFINE cEstatusCtaAbono				CHAR(1);
	DEFINE cStatusTar					CHAR(1);
	DEFINE cTipo_tarjeta				CHAR(1);
	DEFINE cEstatusAutorizacion			CHAR(2);
	DEFINE cCveBanco_Cargo				CHAR(3);
	DEFINE cBancoReceptor   			CHAR(3);
	DEFINE cClaVeBancaria				CHAR(3);
	DEFINE cSucursalContable			CHAR(4);
	DEFINE cTransaccCargo				CHAR(4);
	DEFINE cTranRet						CHAR(4);
	DEFINE cTransaccAbono				CHAR(4);
	DEFINE cProductoCtaCargo			CHAR(4);
	DEFINE cProductoCtaAbono			CHAR(4);
	DEFINE cCodRet						CHAR(5);
	DEFINE cCodRetSMS					CHAR(5);
	DEFINE cCodRetMensaje				CHAR(5);
	DEFINE cSecuencia					CHAR(7);
	
	--DEFINE cFechaEnvio					CHAR(8);
	DEFINE dFechaEnvio					DATE;
	DEFINE cFechaFormat					CHAR(10);
	DEFINE cNum_cte						CHAR(20);
	DEFINE cNumeroFolioCargo			CHAR(16);
	DEFINE cNumeroFolioAbono			CHAR(16);
	DEFINE cNum_Tarjeta					CHAR(16);
	DEFINE cRFC_Cargo					CHAR(18);
	DEFINE cRFCOrdenante				CHAR(18);
	DEFINE cCuentaCargo					CHAR(20);
	DEFINE cCuentaAbono_Prov			CHAR(20);
	DEFINE cCve_proceso					CHAR(20);
	DEFINE cClabeoTarjeta_Cargo			CHAR(20);
	DEFINE cValTarjeta					CHAR(20);
	DEFINE cValTarjNuevo				CHAR(20);
	DEFINE cRef_servicio				CHAR(40);
	DEFINE cRef_titular_serv			CHAR(40);
	DEFINE cRef_Leyenda					CHAR(40);
	DEFINE cListaProductosPermitidos	CHAR(100);
	DEFINE cMensaje						CHAR(200);
	DEFINE cEvento						CHAR(200);
	DEFINE mImporte_dom					MONEY(16,2);
	DEFINE mSaldoActual					MONEY(16,2);
	DEFINE mSdoDisp						MONEY(16,2);
	DEFINE mMontoRet					MONEY(16,2);
	DEFINE mImp_maximo					MONEY(16,2);
	DEFINE d_Fech_prox					DATE;
	DEFINE cFecha_trans					CHAR(8);
	DEFINE cFecha_aplica				CHAR(8);
	DEFINE cCodRetReverso				CHAR(5);
	DEFINE cReintentarCuenta			CHAR(1);
	DEFINE smIntento					SMALLINT;
	DEFINE smMaxIntentos				SMALLINT;
	DEFINE cNom_Arch_Aux				CHAR(20);
	
	DEFINE iPendientes					INTEGER;
	DEFINE iRechazos					INTEGER;
	DEFINE iPendRechazos				INTEGER;
	DEFINE iAplicaciones				INTEGER;
	DEFINE iTotalOperaciones			INTEGER;
	
	DEFINE iImpPendientes				INTEGER;
	DEFINE iImpRechazos					INTEGER;
	DEFINE iImpPendRechazos				INTEGER;
	DEFINE iImpAplicaciones				INTEGER;
	DEFINE iImpTotalOperaciones			INTEGER;
	DEFINE cConsecutivo_archivo			CHAR(2);
	DEFINE cNumCte_proveedor			CHAR(20);
	DEFINE cFechaCargo					CHAR(8);
	DEFINE cNom_Arch_Salida				CHAR(20);
	
	DEFINE cNom_Arch_Aux2				CHAR(20);
	DEFINE cNom_Arch_Proceso			CHAR(20);
	DEFINE iSecuencia2					INTEGER;
	
	DEFINE cEstatusProceso				CHAR(1);
	DEFINE vsNomProceso					CHAR(20);
	DEFINE vsCodRetorno2				CHAR(5);
	DEFINE cPaso						CHAR(6);
	DEFINE iAplicoRevCargo				INTEGER;
	DEFINE iAplicoRevAbono				INTEGER;
	
	DEFINE cRetGrabaDet					CHAR(5);
	DEFINE cResOper						CHAR(1);
	DEFINE cEstatusOper					CHAR(2);
	DEFINE cCausaRechOper				CHAR(2);
	DEFINE bErrores						BOOLEAN;
	DEFINE INICIADO						CHAR(1);
	DEFINE TERMINADO					CHAR(1);
	DEFINE ERROR						CHAR(1);
	DEFINE PROC_ARC_IN					CHAR(1);	
	DEFINE GEN_ARC_OUT					CHAR(1);
	DEFINE IMP_ARC_OUT					CHAR(1);
	DEFINE CARGO_COMI					CHAR(1);
	
	DEFINE iCancelaciones				INTEGER;
	
	DEFINE cCuentaCargo_Comision 		CHAR(20);
	DEFINE dComision					DECIMAL(16,2);
	DEFINE dComisionTotal				DECIMAL(16,2);
	DEFINE dIvaComision					DECIMAL(16,2);
	DEFINE dSaldoCuentaCargoProv		DECIMAL(16,2);
	DEFINE dIVA							DECIMAL(16,2);
	DEFINE dTotalCargoComision			DECIMAL(16,2);
	DEFINE dComisionPendiente			DECIMAL(16,2);
	
	DEFINE iContadorNoPagadas			INTEGER;
	DEFINE iContadorPagadas				INTEGER;
	DEFINE iContadorComisiones			INTEGER;
	DEFINE iBanderaIndicaSiSaldoEsMayor INTEGER;	
	
	DEFINE cTransaccCargoComision		CHAR(4);
	DEFINE cTransaccCargoIVA			CHAR(4);
	DEFINE cTransaccCargoReverso		CHAR(4);
	DEFINE cTransaccAbonoReverso		CHAR(4);
	DEFINE cReferenciaCargoReverso		CHAR(50);
	DEFINE cReferenciaAbonoReverso		CHAR(50);
	DEFINE cReferenciaCargoIva			CHAR(50);
	DEFINE cReferenciaCargoComision 	CHAR(50);
	
	DEFINE bEnTransaccion				BOOLEAN;
	DEFINE bInsertaDetalle				BOOLEAN;
	DEFINE dFechaVal					DATE;
	DEFINE bErrorControlado				BOOLEAN;

	DEFINE cRefNumerica 				CHAR(7); --nmr 13ene20
	DEFINE cTpoCuenta_Cargo             CHAR(2);
	DEFINE cClabeCancel                 CHAR(20);
	DEFINE cRefServCancel               CHAR(40);
	DEFINE cCuentaCargoCancel           CHAR(20);
	DEFINE cTarjetaCargoCancel          CHAR(20);
	
	--RQM 09 704. Se agregan las variables para el retorno de consulta de saldo.
	DEFINE cCodRetSpCons	CHAR(5);
	DEFINE cMensajeRet		CHAR(50);
	DEFINE mSdoActual		MONEY(14,2);
	DEFINE mSdoCong 		MONEY(14,2);
	DEFINE mSdoRetenido		MONEY(14,2);
	DEFINE mImpChqSbg		MONEY(14,2);
	DEFINE mSdoSbc			MONEY(14,2);
	
	--	Cacha algun posible error no controlado.
	
	ON EXCEPTION SET iSQLerr
		IF iSQLerr <> 0 THEN
			LET cCodRet = iSQLerr;

			SET ISOLATION DIRTY READ;
			SET LOCK MODE TO WAIT 3;
							
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
			INTO cCodret,cMensaje;
			
			IF cEstatusProceso = PROC_ARC_IN THEN

				IF iAplicoCargo = 1 THEN
					SELECT cuenta_cargo, cuenta_abono, imp_operacion/100 
					INTO cCuentaCargo, cCuentaAbono_Prov, mImporte_dom 
					FROM dom_cte_detalle
					WHERE nombre_arch = cNom_Arch_Aux AND consecutivo = iSecuencia;
					
					SELECT 1 INTO iExiste FROM bdicheq:sc_tarjeta
					WHERE empresa = '001'
						AND num_tarjeta = SUBSTR(cCuentaCargo ,5,16)
						AND (SUBSTR(num_tarjeta,1,6) = cValTarjeta OR  SUBSTR(num_tarjeta,1,6) = cValTarjNuevo)
						AND tipo_tarjeta = 'T'
						AND status_tar = 'A';
						
					IF iExiste = 1 THEN
						--	extrae la cuenta por el # tarjeta para el abono_ref.
						SELECT cuenta INTO cCuentaCargo FROM bdicheq:sc_tarjeta
						WHERE empresa = '001'
							AND num_tarjeta = SUBSTR(cCuentaCargo ,5,16)
							AND tipo_tarjeta = 'T'
							AND status_tar = 'A';
					ELSE
						--Va por la cuenta para el abono_ref.
						-- RQM 09 704. Se agrega los campos a las variables y se onbtiene el saldo_sbc para calcular el saldo disponible con el SP.
						SELECT cuenta,num_cte,status_cta,producto, sdo_actual, sdo_cong, sdo_retenido, imp_chq_sbg, saldo_sbc
						INTO cCuentaCargo,cNum_cte,cEstatusCtaCargo,cProductoCtaCargo, mSdoActual, mSdoCong, mSdoRetenido, mImpChqSbg, mSdoSbc
						FROM bdicheq:sc_maechq 
						WHERE empresa = '001' 
							AND cuenta = SUBSTR (cCuentaCargo,9,11);
							
						-- RQM 09 704. Se agrega el SP para calcular el saldo disponible tomando en cuenta el saldo_sbc.
						EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo
						('', mSdoActual, mSdoRetenido, mSdoCong, mSdoSbc, mImpChqSbg, NULL, NULL, 'F', '1') INTO cCodRetSpCons, cMensajeRet, mSaldoActual;
						
					END IF;
					
					CALL bdicheq:sp_generafolionomina(RPAD(TRIM(pUsuario),8,'0'))
					RETURNING cCodRetMensaje,cNumeroFolioAbono;

					--	Se llama la ejecucion del abono para que si se afecto a el cliente se le regrese el dinero.
					CALL bdicheq:abono_ref ("001", cSucursalContable, pUsuario,  cTransaccAbonoReverso, "0000", cNumeroFolioAbono, cCuentaCargo,
											0, mImporte_dom, mImporte_dom, 0, 0, 0, "01", cReferenciaAbonoReverso, '', pUsuario) 
					RETURNING cCodRetMensaje;
					
					--Se valida si se aplico el abono a la cuenta del proveedor, si es asi, se reversara el abono
					IF iAplicoAbono = 1 THEN
						CALL bdicheq:cargo_ref ("001", cSucursalContable, pUsuario, cTransaccCargoReverso, "0000", cNumeroFolioAbono, TRIM(cCuentaAbono_Prov),0, mImporte_dom,"01", cReferenciaCargoReverso, '', pUsuario) 
						RETURNING cCodRet,cTranRet,dFecha_hoy,mSdoDisp,mMontoRet;
					END IF;				
				END IF;
				
				UPDATE dom_cte_detalle 
				SET estatus = '02', causa_rechazo = '11'
				WHERE nombre_arch = cNom_Arch_Aux
				AND consecutivo = iSecuencia;
				
				SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0') 
				INTO cSecuencia FROM bdidomi:dom_cte_detalle
				WHERE nombre_arch = cNom_Arch_Salida;
				
				INSERT INTO dom_cte_detalle (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
				cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
				ref_titular_serv, accion, reintentar_cuenta, estatus,
				causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
				fecha_insert, tipo_cta_abono)
				SELECT cNom_Arch_Salida,fecha_envio,tipo_registro,cSecuencia, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, 
				cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
				ref_titular_serv, accion, reintentar_cuenta, '02',
				'11', '', '', '', '', '', '', pUsuario,
				CURRENT::DATE, ''
				FROM dom_cte_detalle 
				WHERE nombre_arch = cNom_Arch_Aux
				AND consecutivo = iSecuencia;
				
				LET iRechazos = iRechazos + 1;
				LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
				
				LET iAplicoCargo = 0;
				LET iAplicoAbono = 0;
				
				IF bErrorControlado = 't' THEN
					LET bErrorControlado = 'f';
					LET bErrores = 't';
					
					INSERT INTO dom_errores(fecha_error,hora_error,cod_error,nombre_arch,sp_llamado,mensaje_error,user_insert,fecha_insert)
					VALUES (CURRENT,CURRENT HOUR TO FRACTION,cCodRet,cNom_Arch_Aux,'sp_domi_cop_procesararchivo',TRIM(cMensaje)||':(Error controlado)',pUsuario,CURRENT);						
				ELSE
					EXECUTE PROCEDURE sp_domi_bitacora(cTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), 'PROCESO ARCHIVO PROV CPL', PROC_ARC_IN, cCodRet, pUsuario, 'sp_domi_cop_procesararchivo', cNom_Arch_Salida, cFechaFormat, '11')
					INTO vsCodRetorno2;		
					
					RETURN cCodRet, cMensaje;						
				END IF;

			ELIF cEstatusProceso = GEN_ARC_OUT THEN
				IF bEnTransaccion = 't' THEN
					ROLLBACK WORK;
				END IF;
				DELETE FROM dom_cte_sumario WHERE nombre_arch = cNom_Arch_Salida;				
				DELETE FROM dom_cte_encabezado WHERE nombre_arch = cNom_Arch_Salida;
				DELETE FROM dom_cte_archivos WHERE nombre_arch = cNom_Arch_Salida;
				
				EXECUTE PROCEDURE sp_domi_bitacora(cTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), 'PROCESO ARCHIVO PROV CPL', GEN_ARC_OUT, cCodRet, pUsuario, 'sp_domi_cop_procesararchivo', cNom_Arch_Salida, cFechaFormat, '11')
				INTO vsCodRetorno2;		
				
				RETURN cCodRet, cMensaje;
			ELIF cEstatusProceso = IMP_ARC_OUT THEN
				EXECUTE PROCEDURE sp_domi_bitacora(cTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), 'PROCESO ARCHIVO PROV CPL', IMP_ARC_OUT, cCodRet, pUsuario, 'sp_domi_cop_procesararchivo', cNom_Arch_Salida, cFechaFormat, '11')
				INTO vsCodRetorno2;		
				
				RETURN cCodRet, cMensaje;			
			ELIF cEstatusProceso = CARGO_COMI THEN
				IF bEnTransaccion = 't' THEN
					ROLLBACK WORK;
				END IF;
				EXECUTE PROCEDURE sp_domi_bitacora(cTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), 'PROCESO ARCHIVO PROV CPL', CARGO_COMI, cCodRet, pUsuario, 'sp_domi_cop_procesararchivo', cNom_Arch_Salida, cFechaFormat, '11')
				INTO vsCodRetorno2;		
				
				RETURN cCodRet, cMensaje;
				
			ELSE
				EXECUTE PROCEDURE sp_domi_bitacora(cTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), 'PROCESO ARCHIVO PROV CPL', cEstatusProceso, cCodRet, pUsuario, 'sp_domi_cop_procesararchivo', cNom_Arch_Salida, cFechaFormat, '11')
				INTO vsCodRetorno2;
				
				RETURN cCodRet, cMensaje;
			END IF;
			
		END IF;		
	END EXCEPTION WITH RESUME;
	
	--SET DEBUG FILE TO "/informix/EGC/sp_domi_cop_procesararchivo.out";
    --TRACE ON;
    	
	
    SET ISOLATION DIRTY READ;
    SET LOCK MODE TO WAIT 4;
	
    UPDATE STATISTICS MEDIUM FOR TABLE dom_cte_detalle;
	LET bErrores = 'f';	
	LET INICIADO	= '0';
	LET TERMINADO	= '1';
	LET PROC_ARC_IN = '2';
	LET GEN_ARC_OUT	= '3';
	LET IMP_ARC_OUT = '4';
	LET CARGO_COMI	= '5';
	LET ERROR		= '6';
	

	LET cPaso = 'VALPREV';
	--	Inicializacion de las variables.
	LET cFecha_trans = "";
	LET cFecha_aplica = "";
	LET cCodRet			  	= "00000";
	--LET cCve_proceso		= "RECARCH_30." || SUBSTR(TRIM(pNom_Arch), 15, 2);
	LET cCve_proceso		= 'GENARCHCOP_BCP.01';
	LET cRef_Leyenda 		= "COBRO POR SERVICIO DE DOMICILIACION";
	LET cProductoCtaAbono	= "";
	LET cProductoCtaCargo	= "";
	LET cSucursalContable 	= "";
	LET cMensaje			= "PROCESAMIENTO EXITOSO";
	LET cNumeroFolioCargo	= "";
	LET dFecha_hoy			= "";
	LET cEstatus			= "";
	LET cClabeoTarjeta_Cargo= "";
	LET cClaVeBancaria		= "";
	LET cCodRetMensaje 		= "";
	LET cCuentaCargo		= "";
	LET cCuentaAbono_Prov 	= "";
	LET cTransaccCargo		= "";
	LET cTransaccAbono		= "";
	LET cTranRet			= "";
	LET cEstatusCtaAbono	= "";
	LET cEstatusCtaCargo	= "";
	LET dFechaEnvio			= "";
	LET cCveBanco_Cargo		= "";
	LET cBancoReceptor		= "";
	LET cSecuencia			= "";
	LET cRFC_Cargo			= "";
	LET cRFCOrdenante		= "";
	LET cFisica				= "";
	LET cRef_servicio 		= "";
	LET cRef_titular_serv	= "";
	LET cStatusTar			= "";
	LET cNum_Tarjeta		= "";
	LET cTipo_tarjeta		= "";
	LET cListaProductosPermitidos = "";
	LET iMaximoRechazosPermitidos = 0;
	LET iContadorVueltas	= 0;
	LET iContadorRepetidas	= 0;
	LET iAplicoCargo		= 0;
	LET iAplicoAbono		= 0;
	LET iExiste 		  	= 0;
	LET iSecuencia			= 0;
	LET iSQLerr				= 0;
	LET iNumRechazos		= 0;
	LET mImporte_dom 		= 0.00;
	LET mSdoDisp			= 0.00;
	LET mMontoRet			= 0.00;
	LET mImp_maximo			= 0.00;
	LET cCodRetReverso		= '';
	LET cReintentarCuenta	= '';
	LET smIntento			= 0;
	LET smMaxIntentos		= 0;
	LET cNom_Arch_Aux		= '';
	LET iPendRechazos		= 0;
	LET iRechazos			= 0;
	LET iPendientes			= 0;
	LET iAplicaciones       = 0;
	LET iTotalOperaciones	= 0;
	
	LET iImpPendientes		= 0;
	LET iImpRechazos		= 0;
	LET iImpPendRechazos	= 0;
	LET iImpAplicaciones	= 0;
	LET iImpTotalOperaciones= 0;
	LET cConsecutivo_archivo= '00';
	LET cNumCte_proveedor 	= '';
	LET cFechaCargo		  	= '';
	LET cNom_Arch_Salida	  = '';
	
	LET cNom_Arch_Aux2 		= '';
	LET iSecuencia2 		= 0;
	
	LET cEstatusProceso = '';
	LET cNom_Arch_Proceso = '';

	LET vsNomProceso = 'GENARCHCOP_BCP.01';
	LET iAplicoRevCargo		= 0;
	LET iAplicoRevAbono		= 0;
	
	LET cResOper = '';
	LET cRetGrabaDet = '';
	LET cEstatusOper = '';
	LET cCausaRechOper = '';
	
	LET iCancelaciones = 0;
	LET cCodRetSMS = '';
	
	LET cCuentaCargo_Comision	= '';
	LET dComision				= 0.00;
	LET dComisionTotal			= 0.00;
	LET dIvaComision			= 0.00;
	LET dSaldoCuentaCargoProv	= 0.00;
	LET dIVA					= 0.00;
	LET dTotalCargoComision		= 0.00;
	LET dComisionPendiente		= 0.00;
	
	LET iContadorNoPagadas		= 0;
	LET iContadorPagadas		= 0;
	LET iContadorComisiones		= 0;
	LET iBanderaIndicaSiSaldoEsMayor = 0;
	
	LET cTransaccCargoComision	= '';
	LET cTransaccCargoIVA		= '';
	LET cReferenciaCargoIva		= '';
	LET cReferenciaCargoComision= '';
	LET bEnTransaccion = 'f';
	LET bInsertaDetalle = 'f';
	LET dFechaVal = '';
	LET bErrorControlado = 'f';

	LET cRefNumerica =''; --nmr 13ene20
	LET cTpoCuenta_Cargo = '';
	LET cClabeCancel = '';
	LET cRefServCancel = '';
	LET cCuentaCargoCancel ='';
	LET cTarjetaCargoCancel = '';
	
	--RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo.
	LET cCodRetSpCons	= '00000';
	LET cMensajeRet		= '';
	LET mSdoActual		= 0.0;
	LET mSdoCong 	    = 0.0;
	LET mSdoRetenido 	= 0.0;
	LET mImpChqSbg	    = 0.0;
	LET mSdoSbc			= 0.0;
	
	
	BEGIN

		--***********************************************************************************************************************************
		--****************************************************INICIO CONSULTA DE PARAMETROS Y VALIDACIONES*************************************

		--	Consulta  fecha del sistema de cheques.
		SELECT fecha_hoy INTO dFecha_hoy FROM bdicheq:sc_fechas;
			--      Saca la fecha de presentacion

		LET dFechaManana = dFecha_hoy + 1;

		--LET cFechaFormat = YEAR(dFechaManana) || LPAD(MONTH (dFechaManana),2,'0') || LPAD(DAY (dFechaManana),2,'0');
		LET cFechaFormat = YEAR(dFecha_hoy) || LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0');
		
		IF EXISTS (SELECT fecha FROM bdinteg:si_feriado_banca WHERE pais = '001' AND fecha = dFecha_hoy) THEN
			LET cCodRet = '02917';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
			INTO cCodret,cMensaje;			
			RETURN cCodRet, cMensaje;
		ELSE
			EXECUTE PROCEDURE bdinteg:splvalfecha('001', dFecha_hoy, 0 ) INTO cCodRet, dFechaVal;
			IF dFecha_hoy <> dFechaVal THEN
				LET cCodRet = '02917';
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;			
				RETURN cCodRet, cMensaje;
			ELSE
				LET cCodRet = '00000';
			END IF;
		END IF;
		
		CALL sp_valida_fecha(cFechaFormat) RETURNING cCodRet;

		IF cCodRet <>0 THEN
			EXECUTE FUNCTION bdinteg:splvalfecha('001', dFechaManana, 0 ) INTO cCodRet,dFechaManana;

			SELECT fecha_prox INTO d_Fech_prox FROM bdinteg:si_feriado_banca WHERE empresa = '001' AND fecha = dFechaManana;
			IF (d_Fech_prox IS NULL) OR (d_Fech_prox = "") THEN
				LET dFechaManana = dFechaManana;
			ELSE
				LET dFechaManana = d_Fech_prox;
			END IF;
			LET cFechaFormat = YEAR(dFechaManana) || LPAD(MONTH (dFechaManana),2,'0') || LPAD(DAY (dFechaManana),2,'0');
			IF cCodRet <>0 THEN
				LET cCodRet = '02900';
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
				RETURN cCodRet, cMensaje;
			END IF;
			LET cFecha_trans = YEAR(dFechaManana) || LPAD(MONTH(dFechaManana),2,'0')|| LPAD(DAY(dFechaManana),2,'0');
			--LET cFecha_aplica = YEAR(dFechaManana) || LPAD(MONTH(dFechaManana),2,'0')|| LPAD(DAY(dFechaManana),2,'0');

		END IF;
		--REVISAR
		--REVISAR
		--REVISAR
		SELECT fecha_prox INTO d_Fech_prox FROM bdinteg:si_feriado_banca WHERE empresa = '001' AND fecha = dFechaManana;
		
		IF (d_Fech_prox IS NULL) OR (d_Fech_prox = "") THEN
			LET dFechaManana = dFechaManana;
		ELSE
			LET dFechaManana = d_Fech_prox;
		END IF;
		
		--LET cFechaFormat = YEAR(dFechaManana) || LPAD(MONTH (dFechaManana),2,'0') || LPAD(DAY (dFechaManana),2,'0');
		LET cFechaFormat = YEAR(dFecha_hoy) || LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0');
		
		LET cFecha_trans = YEAR(dFechaManana) || LPAD(MONTH(dFechaManana),2,'0')|| LPAD(DAY(dFechaManana),2,'0');
		--LET cFecha_aplica = YEAR(dFechaManana) || LPAD(MONTH(dFechaManana),2,'0')|| LPAD(DAY(dFechaManana),2,'0');
		
		

		--	Valida si el usuario contiene un blanco le asigna informix por default.
		IF (NVL(pUsuario,'') = '')  THEN
			LET pUsuario = 'informix';
		END IF;
		
		IF (NVL(cTipoEjecucion,'') = '') OR (cTipoEjecucion  NOT IN('A','M')) THEN
			LET cCodRet = '02912';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;			
			RETURN cCodRet, cMensaje;
		END IF;

		--Obtiene la lista de productos permitidos
		SELECT valor 
		INTO cListaProductosPermitidos FROM dom_parametros WHERE cod_param = '12';


		--	se extrae el valor del prefijo correspondiente a la cuenta de debito.
		SELECT valor INTO cClaVeBancaria FROM bdidomi:dom_parametros WHERE cod_param = '05';

		--	Valida que tenga un valor el prefijo correspondiente a la cuenta de debito.
		IF cClaVeBancaria = '' OR cClaVeBancaria IS NULL Then
			LET cCodRet = '02901';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;			
			RETURN cCodRet, cMensaje;
		END IF;

		--	se extrae el valor del prefijo correspondiente a la cuenta de debito.
		SELECT valor INTO cValTarjeta 
		FROM bdidomi:dom_parametros WHERE cod_param = '06';
		
		SELECT valor INTO cValTarjNuevo 
		FROM bdidomi:dom_parametros WHERE cod_param = '43';
	
		--	Valida que tenga un valor el prefijo correspondiente a la cuenta de debito.
		IF (NVL(cValTarjeta,'') = '') OR  (NVL(cValTarjNuevo,'') = '') THEN
			LET cCodRet = '02902';			
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;			
		END IF;

		--	se extrae el valor de la sucursal contable.
		SELECT valor INTO cSucursalContable 
		FROM bdidomi:dom_parametros WHERE cod_param = '07';

		--	validar si existe en el catÃÂ?ÃÂÃÂ¡logo la sucursal contable.
		SELECT 1 INTO iExiste 
		FROM bdinteg:si_sucursales WHERE sucursal = cSucursalContable;

		--	Se valida si existe la sucursal contable.
		IF iExiste = 0 Then
			LET cCodRet = '02903';			
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;
		ELSE
			LET iExiste = 0;
		END IF;

		--	se extrae el valor de la transaccion de cargo.
		SELECT TRIM(valor) INTO cTransaccCargo 
		FROM bdidomi:dom_parametros WHERE cod_param = '47';
		
		SELECT TRIM(valor) INTO cTransaccAbono 
		FROM bdidomi:dom_parametros WHERE cod_param = '48';

		SELECT TRIM(valor), descripcion 
		INTO cTransaccCargoComision, cReferenciaCargoComision 
		FROM bdidomi:dom_parametros WHERE cod_param = '49';
		
		SELECT TRIM(valor), descripcion 
		INTO cTransaccCargoIVA, cReferenciaCargoIva
		FROM bdidomi:dom_parametros WHERE cod_param = '15';
		
		SELECT TRIM(a.valor), b.descripcion 
		INTO cTransaccCargoReverso , cReferenciaCargoReverso
				FROM bdidomi:dom_parametros a, bdinteg:si_transacc b 
		WHERE a.cod_param = '35'		
		AND TRIM(a.valor) = b.numero;
		
		SELECT TRIM(a.valor), b.descripcion 
		INTO cTransaccAbonoReverso , cReferenciaAbonoReverso
				FROM bdidomi:dom_parametros a, bdinteg:si_transacc b 
		WHERE a.cod_param = '34'		
		AND TRIM(a.valor) = b.numero;		
		
		--	Valida si existe la transaccion de cargo.
		SELECT COUNT(numero) INTO iExiste 
		FROM bdinteg:si_transacc WHERE numero IN (cTransaccCargo,cTransaccAbono, cTransaccCargoComision, cTransaccCargoIVA, cTransaccAbonoReverso, cTransaccCargoReverso);

		--	Valida si existe las transacciones parametrizadas.
		IF iExiste < 6 Then
			LET cCodRet = '02904';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;
		ELSE
			LET iExiste = 0;
		END IF;

		SELECT 1,valor INTO iExiste,iMaximoRechazosPermitidos 
		FROM bdidomi:dom_parametros WHERE cod_param = '11';

		IF iExiste = 0  THEN
			LET cCodRet = '02905';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;
		ELSE
			LET iExiste = 0;
		END IF;
		
		IF EXISTS (SELECT 1 FROM dom_parametros WHERE cod_param = '45') THEN
			SELECT TRIM(valor) INTO cNumCte_proveedor 
			FROM dom_parametros 
			WHERE cod_param = '45';
			
			IF NVL(cNumCte_proveedor,'') = '' THEN
				LET cCodRet = '02907';
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
				RETURN cCodRet, cMensaje;
			END IF;
		ELSE
			LET cCodRet = '02907';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;
		END IF;
		
		IF EXISTS (SELECT 1 FROM dom_parametros WHERE cod_param = '46') THEN
			SELECT TRIM(valor) INTO cCuentaAbono_Prov 
			FROM dom_parametros 
			WHERE cod_param = '46';
		ELSE
			LET cCodRet = '02908';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;
		END IF;

		IF EXISTS(SELECT rfc FROM bdidomi:dom_cat_servicios WHERE num_cte = cNumCte_proveedor) THEN
			SELECT NVL(rfc,''), NVL(num_reintentos,0)+1 INTO cRFCOrdenante, smMaxIntentos
			FROM bdidomi:dom_cat_servicios 
			WHERE num_cte = cNumCte_proveedor;
			
			IF cRFCOrdenante = '' OR LENGTH(TRIM(cRFCOrdenante)) < 12 THEN
				LET cCodRet = '02251';
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
					INTO cCodret,cMensaje;
				RETURN cCodRet, cMensaje;
			END IF;			
		ELSE
			LET cCodRet = '02250';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;
		END IF;
		
		IF LENGTH(pUsuario) NOT IN (7,8) THEN
			LET cCodRet = '02911';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;
		END IF;		
		
		SELECT NVL(estatus,'')
		INTO cEstatusProceso
		FROM bdidomi:dom_procesos 
		WHERE tipo_proceso = cTipoEjecucion 
		AND fecha_proceso = dFecha_hoy
		AND cve_proceso = vsNomProceso;

		LET cNom_Arch_Salida = 'S'||
								TRIM(cNumCte_proveedor)||
								'B'||
								LPAD(DAY(dFecha_hoy),2,'0') || 	LPAD(MONTH(dFecha_hoy),2,'0') || SUBSTR(YEAR(dFecha_hoy)::CHAR(4),3,2)||
								'.'||
								'01';

		IF (NVL(cNom_Arch_Salida,'') = '') OR (LENGTH (cNom_Arch_Salida) < 20) THEN			
			LET cCodRet = '02909';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;
		END IF;	
		
		IF NVL(cEstatusProceso,'') NOT IN ('',INICIADO,TERMINADO,PROC_ARC_IN, GEN_ARC_OUT, IMP_ARC_OUT, CARGO_COMI, ERROR) THEN
			LET cCodRet = '02915';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;			
		ELIF NVL(cEstatusProceso,'') = TERMINADO THEN
			LET cCodRet = '02916';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;
		
		ELIF NVL(cEstatusProceso,'') IN ('',ERROR, PROC_ARC_IN, GEN_ARC_OUT ) THEN

			EXECUTE PROCEDURE sp_domi_bitacora(cTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), 'PROCESO ARCHIVO PROV CPL', INICIADO, '00000', pUsuario, 'sp_domi_cop_receptor', cNom_Arch_Salida, cFechaFormat, '11')
			INTO vsCodRetorno2;
			
			SELECT NVL(MAX(SUBSTR(nombre_arch,19,2)),'00') INTO cConsecutivo_archivo
			FROM dom_cte_archivos 		
			WHERE fecha_envio = dFecha_hoy
			AND SUBSTR(nombre_arch,1,1) = 'S'
			AND LENGTH (nombre_arch) = 20;
			
			LET cFechaCargo = YEAR(dFecha_hoy)::CHAR(4)||LPAD(MONTH(dFecha_hoy),2,'0') || LPAD(DAY(dFecha_hoy),2,'0');

			--*****************************************************FIN CONSULTA DE PARAMETROS Y VALIDACIONES***************************************
			--********************************************************************************************************************************************		
			
			/*LET INICIADO	= '0';
			LET TERMINADO	= '1';
			LET PROC_ARC_IN = '2';
			LET GEN_ARC_OUT	= '3';
			LET IMP_ARC_OUT = '4';
			LET CARGO_COMI	= '5';
			LET ERROR		= '6';*/

			
			--VALIDA SI EXISTEN INSTRUCCIONES DE BAJA O ALTA POR PROCESAR 
			
			
			IF NOT EXISTS(SELECT 1 FROM bdidomi:dom_cte_encabezado AS Enc INNER JOIN bdidomi:dom_cte_detalle AS Det  ON (Enc.nombre_arch  = Det.nombre_arch)
						  WHERE Det.fecha_cargo = cFechaCargo
						  AND Det.estatus = 'EP' AND Det.accion = 'A' AND Det.cve_banco_cargo = '137'
						  AND SUBSTR(Enc.num_cte,12,9) = cNumCte_proveedor AND SUBSTR(Enc.nombre_arch,11,1) = 'B') 
			   AND
			   NOT EXISTS (SELECT 1 FROM bdidomi:dom_cte_encabezado AS Enc INNER JOIN bdidomi:dom_cte_detalle AS Det  ON (Enc.nombre_arch  = Det.nombre_arch)
			               WHERE Det.fecha_envio = dFecha_hoy
						   AND Det.accion = 'B' AND Det.cve_banco_cargo = '137'
						   AND SUBSTR(Enc.num_cte,12,9) = cNumCte_proveedor AND SUBSTR(Enc.nombre_arch,11,1) = 'B') THEN
				IF NVL(cEstatusProceso,'') IN ('',ERROR) THEN				
					LET cCodRet = '02913';
					
					EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
					INTO cCodret,cMensaje;
					
					EXECUTE PROCEDURE sp_domi_bitacora(cTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), 'PROCESO ARCHIVO PROV CPL', ERROR, '00000', pUsuario, 'sp_domi_cop_receptor', cNom_Arch_Salida, cFechaFormat, '11')
					INTO vsCodRetorno2;
										
					RETURN cCodRet, cMensaje;
				END IF;
			END IF;
			
			LET cEstatusProceso = PROC_ARC_IN;
			
			TRUNCATE TABLE tmp_detalle_duplicados;
			
			--PROCESAMIENTO DE SOLICITUDES DE BAJA
			FOREACH WITH HOLD
				SELECT Det.nombre_arch, Det.consecutivo, Det.fecha_cargo, Det.cuenta_cargo, Det.rfc_cargo, Det.cve_banco_cargo, Det.imp_operacion /100 AS importe_operacion, Det.ref_servicio, Det.ref_numerica  --nmr 13ene20
				INTO   cNom_Arch_Aux, iSecuencia, cFechaCargo, cClabeoTarjeta_Cargo, cRFC_Cargo, cCveBanco_Cargo, mImporte_dom, cRef_servicio, cRefNumerica  --nmr 13ene20
				FROM bdidomi:dom_cte_encabezado AS Enc INNER JOIN bdidomi:dom_cte_detalle AS Det  
				ON (Enc.nombre_arch  = Det.nombre_arch)
				WHERE Det.fecha_envio = dFecha_hoy
				AND Det.accion = 'B'
				AND Det.cve_banco_cargo = '137'
				AND SUBSTR(Enc.num_cte,12,9) = cNumCte_proveedor
				AND SUBSTR(Enc.nombre_arch,11,1) = 'B'
				
				LET iTotalOperaciones = iTotalOperaciones + 1;
				LET iImpTotalOperaciones = iImpTotalOperaciones + (mImporte_dom * 100);							
				
				IF NOT EXISTS(SELECT 1 FROM tmp_detalle_duplicados WHERE nombre_arch = cNom_Arch_Aux AND consecutivo = iSecuencia) THEN	
					SELECT COUNT(*) 
					INTO iContadorRepetidas 
					FROM bdidomi:dom_cte_detalle
					WHERE nombre_arch =  cNom_Arch_Aux
					AND cuenta_cargo = cClabeoTarjeta_Cargo
					AND rfc_cargo = cRFC_Cargo
					AND cve_banco_cargo =  cCveBanco_Cargo
					AND imp_operacion/100 = mImporte_dom
					AND ref_servicio = cRef_servicio
					AND ref_numerica= cRefNumerica --nmr 13ene20
					AND estatus ='EP'
					AND accion = 'B';
						
					IF iContadorRepetidas > 1 THEN							
						INSERT INTO tmp_detalle_duplicados 
						SELECT nombre_arch, consecutivo
						FROM dom_cte_detalle
						WHERE nombre_arch =  cNom_Arch_Aux
							AND cuenta_cargo = cClabeoTarjeta_Cargo
							AND rfc_cargo = cRFC_Cargo
							AND cve_banco_cargo =  cCveBanco_Cargo
							AND imp_operacion/100 = mImporte_dom
							AND ref_servicio = cRef_servicio
							AND consecutivo <> iSecuencia;
							
						FOREACH SELECT nombre_arch, consecutivo
								INTO cNom_Arch_Aux2, iSecuencia2
								FROM dom_cte_detalle
								WHERE  nombre_arch =  cNom_Arch_Aux
									AND cuenta_cargo = cClabeoTarjeta_Cargo
									AND rfc_cargo = cRFC_Cargo
									AND cve_banco_cargo =  cCveBanco_Cargo
									AND imp_operacion/100 = mImporte_dom
									AND ref_servicio = cRef_servicio
									AND consecutivo <> iSecuencia
									
							LET bInsertaDetalle = 'f';
							SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0') 
							INTO cSecuencia FROM bdidomi:dom_cte_detalle
							WHERE nombre_arch = cNom_Arch_Salida;

							INSERT INTO dom_cte_detalle (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
								cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
								ref_titular_serv, accion, reintentar_cuenta, estatus,
								causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
								fecha_insert, tipo_cta_abono)					
							SELECT cNom_Arch_Salida,fecha_envio,tipo_registro,cSecuencia, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, --cFecha_trans,
								cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
								ref_titular_serv, accion, reintentar_cuenta, '02',
								'07', '', '', '', '', '', '', pUsuario, 
								CURRENT::DATE, ''
							FROM dom_cte_detalle
							WHERE  nombre_arch =  cNom_Arch_Aux2
								AND consecutivo = iSecuencia2;
							
							LET bInsertaDetalle = 't';
							
							UPDATE bdidomi:dom_cte_detalle SET estatus = '02', causa_rechazo = '07'
							WHERE  nombre_arch =  cNom_Arch_Aux2
							--AND cuenta_cargo = cClabeoTarjeta_Cargo
							AND consecutivo = iSecuencia2;
							
							LET iRechazos = iRechazos + 1;
							LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
							
						END FOREACH;					
					END IF;
					
					LET cEstatusOper = '02';
					LET cCausaRechOper = 'CP';
					
					FOREACH
						SELECT ROWID INTO iExiste
						FROM dom_cte_detalle 
						WHERE fecha_cargo = cFechaCargo
						AND cuenta_cargo = cClabeoTarjeta_Cargo
						AND rfc_cargo = cRFC_Cargo
						AND cve_banco_cargo =  cCveBanco_Cargo
						AND imp_operacion/100 = mImporte_dom
						AND ref_servicio = cRef_servicio
						AND accion = 'A'
						AND estatus = 'EP'
						
						LET bInsertaDetalle = 'f';
						SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0') 
						INTO cSecuencia FROM bdidomi:dom_cte_detalle
						WHERE nombre_arch = cNom_Arch_Salida;
						
						INSERT INTO dom_cte_detalle (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
							cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
							ref_titular_serv, accion, reintentar_cuenta, estatus,
							causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
							fecha_insert, tipo_cta_abono)
						SELECT cNom_Arch_Salida,fecha_envio,tipo_registro, cSecuencia, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, 
							cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
							ref_titular_serv, accion, reintentar_cuenta, cEstatusOper, 
							cCausaRechOper, '', '', '', '', '', '', pUsuario, 
							CURRENT::DATE, ''
						FROM dom_cte_detalle 
						WHERE fecha_cargo = cFechaCargo
						AND cuenta_cargo = cClabeoTarjeta_Cargo
						AND rfc_cargo = cRFC_Cargo
						AND cve_banco_cargo =  cCveBanco_Cargo
						AND imp_operacion/100 = mImporte_dom
						AND ref_servicio = cRef_servicio
						AND accion = 'A'
						AND estatus = 'EP'
						AND ROWID = iExiste;
						
						LET bInsertaDetalle = 't';
						
						UPDATE bdidomi:dom_cte_detalle						
						SET estatus = cEstatusOper, causa_rechazo = cCausaRechOper
						WHERE fecha_cargo = cFechaCargo
						AND cuenta_cargo = cClabeoTarjeta_Cargo
						AND rfc_cargo = cRFC_Cargo
						AND cve_banco_cargo =  cCveBanco_Cargo
						AND imp_operacion/100 = mImporte_dom
						AND ref_servicio = cRef_servicio
						AND accion = 'A'
						AND estatus = 'EP'
						AND ROWID = iExiste;
					
						LET iCancelaciones = DBINFO('sqlca.sqlerrd2');
										
						LET iRechazos = iRechazos + iCancelaciones;
						LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
					END FOREACH;
					
					UPDATE dom_cte_detalle
					SET estatus = cEstatusOper, causa_rechazo = cCausaRechOper
					WHERE nombre_arch = cNom_Arch_Aux
					AND consecutivo = iSecuencia;					
				END IF;				
			END FOREACH;
			
			LET cFechaCargo = YEAR(dFecha_hoy)::CHAR(4)||LPAD(MONTH(dFecha_hoy),2,'0') || LPAD(DAY(dFecha_hoy),2,'0');
			
			TRUNCATE TABLE tmp_detalle_duplicados;		
			
			FOREACH WITH HOLD
				SELECT 	nombre_arch, importe_operacion::MONEY(16,2) AS importe_operacion,cuenta_cargo,cuenta_abono,consecutivo,rfc_cargo,ref_leyenda,fecha_envio,
				cve_banco_cargo,ref_servicio,ref_titular_serv, reintentar_cuenta, intentos, ref_numerica,tipo_cta_cargo  --egc
				INTO 	cNom_Arch_Aux, mImporte_dom,cClabeoTarjeta_Cargo,cCuentaAbono_Prov,iSecuencia,cRFC_Cargo,cRef_Leyenda,dFechaEnvio,
						cCveBanco_Cargo,cRef_servicio,cRef_titular_serv, cReintentarCuenta, smIntento, cRefNumerica,cTpoCuenta_Cargo  --egc
				FROM TABLE(MULTISET(
						SELECT Det.nombre_arch, Det.imp_operacion /100 AS importe_operacion,Det.cuenta_cargo,Det.cuenta_abono,Det.consecutivo,Det.rfc_cargo,Det.ref_leyenda,Det.fecha_envio,
							   Det.cve_banco_cargo,Det.ref_servicio,Det.ref_titular_serv, reintentar_cuenta, 1::SMALLINT AS intentos, Det.ref_numerica, Det.tipo_cta_cargo
						FROM bdidomi:dom_cte_encabezado AS Enc INNER JOIN bdidomi:dom_cte_detalle AS Det  
						ON (Enc.nombre_arch  = Det.nombre_arch)
						WHERE Det.fecha_cargo = cFechaCargo
						AND Det.estatus = 'EP'
						AND Det.accion = 'A'
						AND Det.cve_banco_cargo = '137'
						AND SUBSTR(Enc.num_cte,12,9) = cNumCte_proveedor
						AND SUBSTR(Enc.nombre_arch,11,1) = 'B'))
				ORDER BY consecutivo

--/********************************************************************************************************************************/
--/********************************************************************************************************************************/
				ON EXCEPTION SET iSQLerr
					IF iSQLerr <> 0 THEN
						LET cCodRet = iSQLerr;

						SET ISOLATION DIRTY READ;
						SET LOCK MODE TO WAIT 3;
												
						EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
						INTO cCodret,cMensaje;
						
						IF cEstatusProceso = PROC_ARC_IN THEN

							IF iAplicoCargo = 1 THEN
								SELECT cuenta_cargo, cuenta_abono, imp_operacion/100 
								INTO cCuentaCargo, cCuentaAbono_Prov, mImporte_dom 
								FROM dom_cte_detalle
								WHERE nombre_arch = cNom_Arch_Aux AND consecutivo = iSecuencia;
								
								SELECT 1 INTO iExiste FROM bdicheq:sc_tarjeta
								WHERE empresa = '001'
									AND num_tarjeta = SUBSTR(cCuentaCargo ,5,16)
									AND (SUBSTR(num_tarjeta,1,6) = cValTarjeta OR  SUBSTR(num_tarjeta,1,6) = cValTarjNuevo)
									AND tipo_tarjeta = 'T'
									AND status_tar = 'A';
									
								IF iExiste = 1 THEN
									--	extrae la cuenta por el # tarjeta para el abono_ref.
									SELECT cuenta INTO cCuentaCargo FROM bdicheq:sc_tarjeta
									WHERE empresa = '001'
										AND num_tarjeta = SUBSTR(cCuentaCargo ,5,16)
										AND tipo_tarjeta = 'T'
										AND status_tar = 'A';
								ELSE
									--Va por la cuenta para el abono_ref.
									-- RQM 09 704. Se agrega los campos a las variables y se onbtiene el saldo_sbc para calcular el saldo disponible con el SP.
									SELECT cuenta,num_cte,status_cta,producto, sdo_actual, sdo_cong, sdo_retenido, imp_chq_sbg, saldo_sbc
									INTO cCuentaCargo,cNum_cte,cEstatusCtaCargo,cProductoCtaCargo, mSdoActual, mSdoCong, mSdoRetenido, mImpChqSbg, mSdoSbc --mSaldoActual
									FROM bdicheq:sc_maechq 
									WHERE empresa = '001' 
										AND cuenta = SUBSTR (cCuentaCargo,9,11);
									
									-- RQM 09 704. Se agrega el SP para calcular el saldo disponible tomando en cuenta el saldo_sbc.
									EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo
									('', mSdoActual, mSdoRetenido, mSdoCong, mSdoSbc, mImpChqSbg, NULL, NULL, 'F', '1') INTO cCodRetSpCons, cMensajeRet, mSaldoActual;
									
								END IF;
								
								CALL bdicheq:sp_generafolionomina(RPAD(TRIM(pUsuario),8,'0'))
								RETURNING cCodRetMensaje,cNumeroFolioAbono;

								--	Se llama la ejecucion del abono para que si se afecto a el cliente se le regrese el dinero.
								CALL bdicheq:abono_ref ("001", cSucursalContable, pUsuario,  cTransaccAbonoReverso, "0000", cNumeroFolioAbono, cCuentaCargo,
														0, mImporte_dom, mImporte_dom, 0, 0, 0, "01", cReferenciaAbonoReverso, '', pUsuario) 
								RETURNING cCodRetMensaje;
								
								--Se valida si se aplico el abono a la cuenta del proveedor, si es asi, se reversara el abono
								IF iAplicoAbono = 1 THEN
									CALL bdicheq:cargo_ref ("001", cSucursalContable, pUsuario, cTransaccCargoReverso, "0000", cNumeroFolioAbono, TRIM(cCuentaAbono_Prov),0, mImporte_dom,"01", cReferenciaCargoReverso, '', pUsuario) 
									RETURNING cCodRet,cTranRet,dFecha_hoy,mSdoDisp,mMontoRet;
								END IF;				
							END IF;
							
							UPDATE dom_cte_detalle 
							SET estatus = '02', causa_rechazo = '11'
							WHERE nombre_arch = cNom_Arch_Aux
							AND consecutivo = iSecuencia;
							
							SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0') 
							INTO cSecuencia FROM bdidomi:dom_cte_detalle
							WHERE nombre_arch = cNom_Arch_Salida;
							
							INSERT INTO dom_cte_detalle (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
							cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
							ref_titular_serv, accion, reintentar_cuenta, estatus,
							causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
							fecha_insert, tipo_cta_abono)
							SELECT cNom_Arch_Salida,fecha_envio,tipo_registro,cSecuencia, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, 
							cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
							ref_titular_serv, accion, reintentar_cuenta, '02',
							'11', '', '', '', '', '', '', pUsuario,
							CURRENT::DATE, ''
							FROM dom_cte_detalle 
							WHERE nombre_arch = cNom_Arch_Aux
							AND consecutivo = iSecuencia;
							
							LET iRechazos = iRechazos + 1;
							LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
							
							LET iAplicoCargo = 0;
							LET iAplicoAbono = 0;
							
							IF bErrorControlado = 't' THEN
								LET bErrorControlado = 'f';
								LET bErrores = 't';
								
								INSERT INTO dom_errores(fecha_error,hora_error,cod_error,nombre_arch,sp_llamado,mensaje_error,user_insert,fecha_insert)
								VALUES (CURRENT,CURRENT HOUR TO FRACTION,cCodRet,cNom_Arch_Aux,'sp_domi_cop_procesararchivo',TRIM(cMensaje)||':(Error controlado)',pUsuario,CURRENT);
							ELSE
								EXECUTE PROCEDURE sp_domi_bitacora(cTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), 'PROCESO ARCHIVO PROV CPL', PROC_ARC_IN, cCodRet, pUsuario, 'sp_domi_cop_procesararchivo', cNom_Arch_Salida, cFechaFormat, '11')
								INTO vsCodRetorno2;		
								
								RETURN cCodRet, cMensaje;						
							END IF;
						END IF;						
					END IF;		
				END EXCEPTION WITH RESUME;	
--/********************************************************************************************************************************/
--/********************************************************************************************************************************/		
		
				
				SELECT cuenta 
				INTO cCuentaAbono_Prov 
				FROM bdicheq:sc_maechq 
				WHERE empresa = '001' 
					AND cuenta_clabe = SUBSTR(cCuentaAbono_Prov,3,18);
				
				LET iTotalOperaciones = iTotalOperaciones + 1;
				LET iImpTotalOperaciones = iImpTotalOperaciones + (mImporte_dom * 100);
				
				--	VALIDA QUE LA CLABE NI EL IMPORTE SE OBTENGAN SIN VALORES.
				IF mImporte_dom IS NULL OR mImporte_dom = 0.00 OR  cClabeoTarjeta_Cargo IS NULL OR cClabeoTarjeta_Cargo = '' THEN
					CONTINUE FOREACH;
				END IF;

				SET ISOLATION DIRTY READ;
				SET LOCK MODE TO WAIT 4;
								
				LET iContadorVueltas = iContadorVueltas +1;					
				IF iContadorVueltas IN (500, 5000, 50000) THEN
					UPDATE STATISTICS MEDIUM FOR TABLE bdidomi:dom_cte_detalle;
					IF iContadorVueltas = 50000 THEN
						LET iContadorVueltas = 1;
					END IF;
				END IF;
				
				IF NOT EXISTS(SELECT 1 FROM tmp_detalle_duplicados WHERE nombre_arch = cNom_Arch_Aux AND consecutivo = iSecuencia) THEN	
					
					SELECT COUNT(*) 
					INTO iContadorRepetidas 
					FROM bdidomi:dom_cte_detalle
					WHERE  nombre_arch =  cNom_Arch_Aux
					AND cuenta_cargo = cClabeoTarjeta_Cargo
					AND rfc_cargo = cRFC_Cargo
					AND cve_banco_cargo =  cCveBanco_Cargo
					AND imp_operacion/100 = mImporte_dom
					AND ref_servicio = cRef_servicio
					AND ref_numerica= cRefNumerica --nmr 13ene20
					AND estatus ='EP'
					AND accion = 'A';
					
					IF iContadorRepetidas > 1 THEN							
						INSERT INTO tmp_detalle_duplicados 
						SELECT nombre_arch, consecutivo
						FROM dom_cte_detalle
						WHERE nombre_arch =  cNom_Arch_Aux
							AND cuenta_cargo = cClabeoTarjeta_Cargo
							AND rfc_cargo = cRFC_Cargo
							AND cve_banco_cargo =  cCveBanco_Cargo
							AND imp_operacion/100 = mImporte_dom
							AND ref_servicio = cRef_servicio
							AND consecutivo <> iSecuencia;
							
						FOREACH SELECT nombre_arch, consecutivo
								INTO cNom_Arch_Aux2, iSecuencia2
								FROM dom_cte_detalle
								WHERE  nombre_arch =  cNom_Arch_Aux
									AND cuenta_cargo = cClabeoTarjeta_Cargo
									AND rfc_cargo = cRFC_Cargo
									AND cve_banco_cargo =  cCveBanco_Cargo
									AND imp_operacion/100 = mImporte_dom
									AND ref_servicio = cRef_servicio
									AND ref_numerica= cRefNumerica --nmr 13ene20
									AND consecutivo <> iSecuencia					
						
							SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0') 
							INTO cSecuencia FROM bdidomi:dom_cte_detalle
							WHERE nombre_arch = cNom_Arch_Salida;

							INSERT INTO dom_cte_detalle_paso (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
								cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
								ref_titular_serv, accion, reintentar_cuenta, estatus,
								causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
								fecha_insert, tipo_cta_abono)					
							SELECT cNom_Arch_Salida,fecha_envio,tipo_registro,cSecuencia, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, --cFecha_trans,
								cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
								ref_titular_serv, accion, reintentar_cuenta, '02',
								'07', '', '', '', '', '', '', pUsuario, 
								CURRENT::DATE, ''
							FROM dom_cte_detalle
							WHERE  nombre_arch =  cNom_Arch_Aux2
								AND consecutivo = iSecuencia2;
							
							UPDATE bdidomi:dom_cte_detalle SET estatus = '02', causa_rechazo = '07'
							WHERE  nombre_arch =  cNom_Arch_Aux2
							--AND cuenta_cargo = cClabeoTarjeta_Cargo
							AND consecutivo = iSecuencia2;
							
							LET iRechazos = iRechazos + 1;
							LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
						END FOREACH;					
					END IF;

					--****************************************************INICIO VALIDACIONES A LA CUENTA CARGO*********************************************
					--***********************************************************************************************************************************
					--LINEAS DE PRUEBA
					/*IF iContadorVueltas = 10 THEN
						LET bErrorControlado = 't';
						RAISE EXCEPTION -222;
						CONTINUE FOREACH;
					END IF;*/
					
					--OBTIENE EL NUMERO DE VECES QUE SE HA INTENTADO REALIZAR EL CARGO
					SELECT COUNT(*) + 1
					INTO smIntento
					--FROM dom_cte_detalle_pend
					FROM dom_cte_reintentos_cce
					WHERE nombre_arch = cNom_Arch_Aux
					AND consecutivo = LPAD (TRIM (iSecuencia::CHAR(6)),6,'0');
					
					--	Valida si existe la tarjeta en la sc_tarjeta.
					SELECT 1 INTO iExiste FROM bdicheq:sc_tarjeta
					WHERE empresa = '001'
					AND num_tarjeta = SUBSTR(cClabeoTarjeta_Cargo ,5,16);

					--	Valida si existe la tarjeta y esta en el rango del valor de la tarjeta.
					IF iExiste = 1 THEN
						--	extrae la cuenta por el # tarjeta.
						SELECT cuenta,status_tar,tipo_tarjeta,num_tarjeta INTO cCuentaCargo,cStatusTar,cTipo_tarjeta,cNum_Tarjeta FROM bdicheq:sc_tarjeta
						WHERE empresa = '001'
							AND num_tarjeta = SUBSTR(cClabeoTarjeta_Cargo ,5,16);

						IF cCuentaCargo = '' OR cCuentaCargo IS NULL  THEN
							--	Motivo 01: Cuenta Inexistente								
							LET cEstatusOper = '02';
							LET cCausaRechOper = '01';
							
							--EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
							EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cRFCOrdenante, cCuentaCargo, cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
							INTO cRetGrabaDet, cResOper;
							
							IF cRetGrabaDet = '00000' THEN
								IF cResOper = 'R' THEN
									LET iRechazos = iRechazos + 1;
									LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
								ELIF cResOper = 'P' THEN
									LET iPendientes = iPendientes + 1;
									LET iImpPendientes = iImpPendientes + (mImporte_dom * 100);
								END IF;
							ELSE
								LET bErrorControlado = 't';
								RAISE EXCEPTION cRetGrabaDet;
							END IF;
							
							CONTINUE FOREACH;
						END IF;

						IF cTipo_tarjeta <> 'T' THEN
							--	Motivo 06: La cuenta no pertence al banco receptor.
							LET cEstatusOper = '02';
							LET cCausaRechOper = '06';
							
							--EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
							EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cRFCOrdenante, cCuentaCargo, cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
							INTO cRetGrabaDet, cResOper;
							
							IF cRetGrabaDet = '00000' THEN
								IF cResOper = 'R' THEN
									LET iRechazos = iRechazos + 1;
									LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
								ELIF cResOper = 'P' THEN
									LET iPendientes = iPendientes + 1;
									LET iImpPendientes = iImpPendientes + (mImporte_dom * 100);
								END IF;
							ELSE
								LET bErrorControlado = 't';
								RAISE EXCEPTION cRetGrabaDet;
							END IF;

							CONTINUE FOREACH;
						END IF;

						IF cStatusTar <> 'A' THEN
							--	Motivo 03: Tarjeta Cancelada
							LET cEstatusOper = '02';
							LET cCausaRechOper = '03';
							
							--EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
							EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cRFCOrdenante, cCuentaCargo, cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
							INTO cRetGrabaDet, cResOper;
							
							IF cRetGrabaDet = '00000' THEN
								IF cResOper = 'R' THEN
									LET iRechazos = iRechazos + 1;
									LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
								ELIF cResOper = 'P' THEN
									LET iPendientes = iPendientes + 1;
									LET iImpPendientes = iImpPendientes + (mImporte_dom * 100);
								END IF;
							ELSE
								LET bErrorControlado = 't';
								RAISE EXCEPTION cRetGrabaDet;
							END IF;

							CONTINUE FOREACH;
						END IF;

						IF SUBSTR(cNum_Tarjeta,1,6) <> cValTarjeta AND SUBSTR(cNum_Tarjeta,1,6) <> cValTarjNuevo THEN
							--VALIDACION DE BINES DE TARJETAS
							LET cEstatusOper = '02';
							LET cCausaRechOper = '06';
							
							--EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
							EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cRFCOrdenante, cCuentaCargo, cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
							INTO cRetGrabaDet, cResOper;
							
							IF cRetGrabaDet = '00000' THEN
								IF cResOper = 'R' THEN
									LET iRechazos = iRechazos + 1;
									LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
								ELIF cResOper = 'P' THEN
									LET iPendientes = iPendientes + 1;
									LET iImpPendientes = iImpPendientes + (mImporte_dom * 100);
								END IF;
							ELSE
								LET bErrorControlado = 't';
								RAISE EXCEPTION cRetGrabaDet;
							END IF;

							CONTINUE FOREACH;
						END IF;
						
						-- RQM 09 704. Se agrega los campos a las variables y se onbtiene el saldo_sbc para calcular el saldo disponible con el SP.
						SELECT 1,cuenta,num_cte,status_cta,producto, sdo_actual, sdo_cong, sdo_retenido, imp_chq_sbg, saldo_sbc
						INTO iExiste,cCuentaCargo,cNum_cte,cEstatusCtaCargo,cProductoCtaCargo, mSdoActual, mSdoCong, mSdoRetenido, mImpChqSbg, mSdoSbc --mSaldoActual
						FROM bdicheq:sc_maechq WHERE empresa = '001' AND cuenta = cCuentaCargo;
						
						-- RQM 09 704. Se agrega el SP para calcular el saldo disponible tomando en cuenta el saldo_sbc.
						EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo
						('', mSdoActual, mSdoRetenido, mSdoCong, mSdoSbc, mImpChqSbg, NULL, NULL, 'F', '1') INTO cCodRetSpCons, cMensajeRet, mSaldoActual;

					ELSE
						--Comprueba si la clabe nos corresponde.
						IF SUBSTR(cClabeoTarjeta_Cargo,3,3) <> cClaVeBancaria THEN
							LET iExiste = 1;
						END IF;
						--SELECT 1 INTO iExiste FROM bdicheq:sc_fechas WHERE SUBSTR(cClabeoTarjeta_Cargo,3,3) <> cClaVeBancaria;				
						IF iExiste = 1 THEN
							--	Motivo 06: La cuenta no pertence al banco receptor.
							LET cEstatusOper = '02';
							LET cCausaRechOper = '06';
							
							--EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
							EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cRFCOrdenante, cCuentaCargo, cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
							INTO cRetGrabaDet, cResOper;
							
							IF cRetGrabaDet = '00000' THEN
								IF cResOper = 'R' THEN
									LET iRechazos = iRechazos + 1;
									LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
								ELIF cResOper = 'P' THEN
									LET iPendientes = iPendientes + 1;
									LET iImpPendientes = iImpPendientes + (mImporte_dom * 100);
								END IF;
							ELSE
								LET bErrorControlado = 't';
								RAISE EXCEPTION cRetGrabaDet;
							END IF;

							CONTINUE FOREACH;
						END IF;

						LET iExiste = 0;
						
						-- si no existe consulta por la cuenta del cliente encontrada en la cuenta_clabe del cliente.
						-- RQM 09 704. Se agrega los campos a las variables y se onbtiene el saldo_sbc para calcular el saldo disponible con el SP.
						SELECT 1,cuenta,num_cte,status_cta,producto, sdo_actual, sdo_cong, sdo_retenido, imp_chq_sbg, saldo_sbc
						INTO iExiste,cCuentaCargo,cNum_cte,cEstatusCtaCargo,cProductoCtaCargo, mSdoActual, mSdoCong, mSdoRetenido, mImpChqSbg, mSdoSbc --mSaldoActual
						FROM bdicheq:sc_maechq WHERE empresa = '001' AND cuenta = SUBSTR (cClabeoTarjeta_Cargo,9,11);
						
						-- RQM 09 704. Se agrega el SP para calcular el saldo disponible tomando en cuenta el saldo_sbc.
						EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo
						('', mSdoActual, mSdoRetenido, mSdoCong, mSdoSbc, mImpChqSbg, NULL, NULL, 'F', '1') INTO cCodRetSpCons, cMensajeRet, mSaldoActual;
						
					END IF;
					
					IF cCuentaCargo = '' OR cCuentaCargo IS NULL THEN
						--	Motivo 06: La cuenta no pertence al banco receptor.
						LET cEstatusOper = '02';
						LET cCausaRechOper = '01';
							
						--EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
						EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cRFCOrdenante, cCuentaCargo, cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
						INTO cRetGrabaDet, cResOper;
						
						IF cRetGrabaDet = '00000' THEN
							IF cResOper = 'R' THEN
								LET iRechazos = iRechazos + 1;
								LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
							ELIF cResOper = 'P' THEN
								LET iPendientes = iPendientes + 1;
								LET iImpPendientes = iImpPendientes + (mImporte_dom * 100);
							END IF;
						ELSE
							LET bErrorControlado = 't';
							RAISE EXCEPTION cRetGrabaDet;
						END IF;
						
						CONTINUE FOREACH;
					END IF;
					-------------------------------Comienza validacion para la cancelacion de domicliacion--------------------------
					--Estatus cTipoDomiciliacion se valida por tarjeta o por domiciliacion en el sp_guarda_cancelaciones
					
						-- 1 Cancelacion por TARJETA
						-- 2 Cancelacion por Domiciliacion
						
					--Estatus cancelaciones de la tabla dom_cte_cancelaciones
						
						-- 0 Enviado de aclaraciones
						-- 1 Domiciliacion cancelada aplicada
					
					IF cTpoCuenta_Cargo = '40' THEN --Valida si es cuenta clabe
					
						--1 validar por rfc
						--2 validar por numero de cliente
							
						--si yo quiero cancelar sky eso lo vamos hacer por el proceso de recepcion	(es donde nosotros le pagamos a otros bancos)
						
						SELECT FIRST 1 cuenta_clabe,ref_servicio,cuenta INTO cClabeCancel,cRefServCancel,cCuentaCargoCancel FROM bdidomi:dom_cte_cancelaciones WHERE ref_servicio = TRIM(cRef_servicio) AND cuenta_clabe = TRIM(cClabeoTarjeta_Cargo) AND cuenta = TRIM(cCuentaCargo) AND status_cancelacion = '0';
						
						IF TRIM(cClabeCancel) = TRIM(cClabeoTarjeta_Cargo) AND TRIM(cRefServCancel) = TRIM(cRef_servicio) AND TRIM(cCuentaCargoCancel) = TRIM(cCuentaCargo) THEN
							--	Motivo 10: Por Orden del Cliente: Cancelacion del Servicio.             
							
							LET cEstatusOper = '02';
							LET cCausaRechOper = '10';
							EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cRFCOrdenante, cCuentaCargo, cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario) INTO cRetGrabaDet, cResOper;
						
							IF cRetGrabaDet = '00000' THEN
								IF cResOper = 'R' THEN
									LET iRechazos = iRechazos + 1;
									LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
								ELIF cResOper = 'P' THEN
									LET iPendientes = iPendientes + 1;
									LET iImpPendientes = iImpPendientes + (mImporte_dom * 100);
								END IF;
							ELSE
								LET bErrorControlado = 't';
								RAISE EXCEPTION cRetGrabaDet;
							END IF;
							
							UPDATE bdidomi:dom_cte_cancelaciones SET status_cancelacion = '1' WHERE ref_servicio = TRIM(cRef_servicio) AND cuenta_clabe = TRIM(cClabeoTarjeta_Cargo);
							
							CONTINUE FOREACH;
						END IF;
					END IF;
					
					IF cTpoCuenta_Cargo = '03' THEN  --Valida si es numero de tarjeta
					
						SELECT FIRST 1 num_tarjeta,ref_servicio,cuenta INTO cTarjetaCargoCancel,cRefServCancel,cCuentaCargoCancel FROM bdidomi:dom_cte_cancelaciones WHERE ref_servicio = TRIM(cRef_servicio) AND num_tarjeta = TRIM(cClabeoTarjeta_Cargo) AND cuenta = TRIM(cCuentaCargo) AND status_cancelacion = '0';

						IF TRIM(cTarjetaCargoCancel) = TRIM(cClabeoTarjeta_Cargo) AND TRIM(cRefServCancel) = TRIM(cRef_servicio) AND TRIM(cCuentaCargoCancel) = TRIM(cCuentaCargo) THEN
							--	Motivo 10: Por Orden del Cliente: Cancelacion del Servicio.             
							LET cEstatusOper = '02';
							LET cCausaRechOper = '10';
							--IF cRef_serv_cancel = cRef_servicio THEN
							
								EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cRFCOrdenante, cCuentaCargo, cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario) INTO cRetGrabaDet, cResOper;
								
								IF cRetGrabaDet = '00000' THEN
									IF cResOper = 'R' THEN
										LET iRechazos = iRechazos + 1;
										LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
									ELIF cResOper = 'P' THEN
										LET iPendientes = iPendientes + 1;
										LET iImpPendientes = iImpPendientes + (mImporte_dom * 100);
									END IF;
								ELSE
									LET bErrorControlado = 't';
									RAISE EXCEPTION cRetGrabaDet;
								END IF;
								
								UPDATE bdidomi:dom_cte_cancelaciones SET status_cancelacion = '1' WHERE ref_servicio = TRIM(cRef_servicio) AND num_tarjeta = TRIM(cClabeoTarjeta_Cargo);
							--END IF;
							CONTINUE FOREACH;
						END IF;
					END IF;
					
					-------------------------------Termina validacion para la cancelacion de domicliacion--------------------------
					
					IF iExiste = 1 THEN
						SELECT 1,cve_estatus,imp_maximo  INTO iExiste,cEstatusAutorizacion,mImp_maximo
						FROM bdidomi:dom_autorizaciones 
						WHERE cuenta = cCuentaCargo AND  rfc = cRFCOrdenante;

						IF iExiste != 1 OR iExiste IS NULL THEN
							IF NOT EXISTS (SELECT 1 FROM bdidomi:dom_cat_servicios WHERE rfc = cRFCOrdenante) THEN
								INSERT INTO bdidomi:dom_cat_servicios (rfc,razon_social,convenio,cve_canal,presentador,num_cte,nombre_corto,num_reintentos,
																   comision,comision_dev,cuenta_cargo_comision,layout_especial,user_insert,fecha_insert,
																   cod_grupo_act,cod_grupo_des,cod_grupo_react,cod_grupo_rev)
								VALUES (cRFCOrdenante,cRef_titular_serv,'N','05','N',NULL,NULL,NULL,NULL,NULL,NULL,NULL,pUsuario,CURRENT::DATE,'0000','0000','0000','0000');
							END IF;
							--Inserta el registro de autorizacion domi.
							INSERT INTO bdidomi:dom_autorizaciones(cuenta,rfc,num_cte,cve_canal,imp_maximo,num_rechazos
							,cve_sucursal,cve_estatus,fecha_estatus,user_estatus,cve_causa,user_insert,fecha_insert)
							VALUES (cCuentaCargo,cRFCOrdenante,cNum_cte,'05',0.00,0,cSucursalContable,'01',dFecha_hoy,pUsuario,'00',pUsuario,CURRENT::DATE);
						END IF;
					END IF;
					
					--	Si la cuenta esta cancelada
					IF cEstatusCtaCargo = '2' THEN
						--Motivo 03: La cuenta Cancelada.
						LET cEstatusOper = '02';
						LET cCausaRechOper = '03';
							
						--EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
						EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cRFCOrdenante, cCuentaCargo, cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
						INTO cRetGrabaDet, cResOper;
						
						IF cRetGrabaDet = '00000' THEN
							IF cResOper = 'R' THEN
								LET iRechazos = iRechazos + 1;
								LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
							ELIF cResOper = 'P' THEN
								LET iPendientes = iPendientes + 1;
								LET iImpPendientes = iImpPendientes + (mImporte_dom * 100);
							END IF;
						ELSE
							LET bErrorControlado = 't';
							RAISE EXCEPTION cRetGrabaDet;
						END IF;	

						CONTINUE FOREACH;
					END IF;
					
					--	Si la cuenta esta bloqueada
					IF cEstatusCtaCargo = '3' THEN
						--Motivo 02: La cuenta esta bloqueada .
						LET cEstatusOper = '02';
						LET cCausaRechOper = '02';
							
						--EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
						EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cRFCOrdenante, cCuentaCargo, cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
						INTO cRetGrabaDet, cResOper;
						
						IF cRetGrabaDet = '00000' THEN
							IF cResOper = 'R' THEN
								LET iRechazos = iRechazos + 1;
								LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
							ELIF cResOper = 'P' THEN
								LET iPendientes = iPendientes + 1;
								LET iImpPendientes = iImpPendientes + (mImporte_dom * 100);
							END IF;
						ELSE
							LET bErrorControlado = 't';
							RAISE EXCEPTION cRetGrabaDet;
						END IF;	

						CONTINUE FOREACH;
					END IF;
					
					IF NOT cProductoCtaCargo IS NULL OR NOT cProductoCtaCargo = "" THEN
						SELECT 1 INTO iExiste FROM bdicheq:sc_producto WHERE producto = cProductoCtaCargo AND divisa = '01';

						IF iExiste <> 1 OR iExiste IS NULL THEN
							--	Motivo 05: La cuenta esta en otra divisa.
							LET cEstatusOper = '02';
							LET cCausaRechOper = '05';
							
							--EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
							EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cRFCOrdenante, cCuentaCargo, cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
							INTO cRetGrabaDet, cResOper;
							
							IF cRetGrabaDet = '00000' THEN
								IF cResOper = 'R' THEN
									LET iRechazos = iRechazos + 1;
									LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
								ELIF cResOper = 'P' THEN
									LET iPendientes = iPendientes + 1;
									LET iImpPendientes = iImpPendientes + (mImporte_dom * 100);
								END IF;
							ELSE
								LET bErrorControlado = 't';
								RAISE EXCEPTION cRetGrabaDet;
							END IF;

							CONTINUE FOREACH;
						ELSE
							LET iExiste = 0;
						END IF;
					END IF;
					
					IF NOT( cListaProductosPermitidos LIKE '%'|| cProductoCtaCargo || '%' ) THEN
						--Verifica que el producto de la cuenta se encuentre dentro de los permitidos
						LET cEstatusOper = '02';
						LET cCausaRechOper = '06';
							
						--EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
						EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cRFCOrdenante, cCuentaCargo, cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
						INTO cRetGrabaDet, cResOper;
						
						IF cRetGrabaDet = '00000' THEN
							IF cResOper = 'R' THEN
								LET iRechazos = iRechazos + 1;
								LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
							ELIF cResOper = 'P' THEN
								LET iPendientes = iPendientes + 1;
								LET iImpPendientes = iImpPendientes + (mImporte_dom * 100);
							END IF;
						ELSE
							LET bErrorControlado = 't';
							RAISE EXCEPTION cRetGrabaDet;
						END IF;
						
						CONTINUE FOREACH;
					END IF;
					
					--****************************************************FIN VALIDACIONES A LA CUENTA CARGO************************************************
					--**************************************************************************************************************************************
					--****************************************************INICIO CONSULTA SI EL CLIENTE ESTA ATORIZADO**************************************
					--VALIDA QUE EL REGISTRO SEA PARA UNA PERSONA FISICA.
					SELECT 1 INTO iExiste FROM bdicheq:sc_maechq mae INNER JOIN bdinteg:si_cliente cte ON mae.num_cte = cte.numcte
					WHERE mae.empresa = '001' AND mae.cuenta = cCuentaCargo AND cte.tpo_persona = '01';

					IF iExiste != 1 THEN
						--	Motivo 11: Cliente no tiene autorizado el servicio
						LET cEstatusOper = '02';
						LET cCausaRechOper = '11';
							
						--EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
						EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cRFCOrdenante, cCuentaCargo, cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)						
						INTO cRetGrabaDet, cResOper;
						
						IF cRetGrabaDet = '00000' THEN
							IF cResOper = 'R' THEN
								LET iRechazos = iRechazos + 1;
								LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
							ELIF cResOper = 'P' THEN
								LET iPendientes = iPendientes + 1;
								LET iImpPendientes = iImpPendientes + (mImporte_dom * 100);
							END IF;
						ELSE
							LET bErrorControlado = 't';
							RAISE EXCEPTION cRetGrabaDet;
						END IF;

						CONTINUE FOREACH;
					ELSE
						LET iExiste = 0;
					END IF;
					
					--CONSULTA SI EL CLIENTE ESTA AUTORIZADO EN EL SERVICIO DE DOMI.
					SELECT 1,cve_estatus,imp_maximo  INTO iExiste,cEstatusAutorizacion,mImp_maximo
					FROM bdidomi:dom_autorizaciones WHERE cuenta = cCuentaCargo AND  rfc = cRFCOrdenante;

					IF iExiste = 1 THEN
						IF cEstatusAutorizacion <> '01' THEN
							LET cEstatusOper = '02';
							LET cCausaRechOper = '11';
							
							--EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
							EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cRFCOrdenante, cCuentaCargo, cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
							INTO cRetGrabaDet, cResOper;
							
							IF cRetGrabaDet = '00000' THEN
								IF cResOper = 'R' THEN
									LET iRechazos = iRechazos + 1;
									LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
								ELIF cResOper = 'P' THEN
									LET iPendientes = iPendientes + 1;
									LET iImpPendientes = iImpPendientes + (mImporte_dom * 100);
								END IF;
							ELSE
								LET bErrorControlado = 't';
								RAISE EXCEPTION cRetGrabaDet;
							END IF;
							
							CONTINUE FOREACH;
						END IF;
					ELSE
						IF NOT EXISTS (SELECT 1 FROM bdidomi:dom_cat_servicios WHERE rfc = cRFCOrdenante) THEN
							INSERT INTO bdidomi:dom_cat_servicios (rfc,razon_social,convenio,cve_canal,presentador,num_cte,nombre_corto,num_reintentos,
																   comision,comision_dev,cuenta_cargo_comision,layout_especial,user_insert,fecha_insert,
																   cod_grupo_act,cod_grupo_des,cod_grupo_react,cod_grupo_rev)
							VALUES (cRFCOrdenante,cRef_titular_serv,'N','05','N',NULL,NULL,NULL,NULL,NULL,NULL,NULL,pUsuario,CURRENT::DATE,'0000','0000','0000','0000');
						END IF;
						--Inserta el registro de autorizacion domi.
						INSERT INTO bdidomi:dom_autorizaciones(cuenta,rfc,num_cte,cve_canal,imp_maximo,num_rechazos
						,cve_sucursal,cve_estatus,fecha_estatus,user_estatus,cve_causa,user_insert,fecha_insert)
						VALUES (cCuentaCargo,cRFCOrdenante,cNum_cte,'05',0.00,0,cSucursalContable,'01',dFecha_hoy,pUsuario,'00',pUsuario,CURRENT::DATE);
					END IF;
					
					--Valida motivo 09 por orden del cliente:importe mayor del autorizado.
					IF mImporte_dom > mImp_maximo AND mImp_maximo > 0.00 THEN
						LET cEstatusOper = '02';
						LET cCausaRechOper = '09';
							
						--EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
						EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cRFCOrdenante, cCuentaCargo, cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
						INTO cRetGrabaDet, cResOper;
						
						IF cRetGrabaDet = '00000' THEN
							IF cResOper = 'R' THEN
								LET iRechazos = iRechazos + 1;
								LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
							ELIF cResOper = 'P' THEN
								LET iPendientes = iPendientes + 1;
								LET iImpPendientes = iImpPendientes + (mImporte_dom * 100);
							END IF;
						ELSE
							LET bErrorControlado = 't';
							RAISE EXCEPTION cRetGrabaDet;
						END IF;

						CONTINUE FOREACH;
					END IF;
					
					LET mSaldoActual = mSaldoActual;
					LET mImporte_dom = mImporte_dom;
					
					--VALIDA QUE EL SALDO ACTUAL DE LA CUENTA ALCANZE A PAGAR EL MONTO.
					IF mImporte_dom > mSaldoActual THEN
						
						--Motivo 04:Cuenta con Insuficiencia de Fondos
						LET cEstatusOper = '02';
						LET cCausaRechOper = '04';
												
						--EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
						EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cRFCOrdenante, cCuentaCargo, cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
						INTO cRetGrabaDet, cResOper;
						
						IF cRetGrabaDet = '00000' THEN
							IF cResOper = 'R' THEN
								LET iRechazos = iRechazos + 1;
								LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
							ELIF cResOper = 'P' THEN
								LET iPendientes = iPendientes + 1;
								LET iImpPendientes = iImpPendientes + (mImporte_dom * 100);
							END IF;
						ELSE
							LET bErrorControlado = 't';
							RAISE EXCEPTION cRetGrabaDet;
						END IF;	
						
						--LET iNumRechazos = 0;

						--CONSULTA SI EL NUMERO DE RECHAZOS PARAMETRIZADOS ES MENOR A LOS QUE TIENE EL CLIENTE.
						--SELECT num_rechazos INTO iNumRechazos FROM bdidomi:dom_autorizaciones WHERE cuenta = cCuentaCargo AND rfc = cRFCOrdenante;

						CONTINUE FOREACH;
					END IF;
					
					--****************************************************FIN CONSULTA SI EL CLIENTE ESTA ATORIZADO*****************************************
					--*************************************************************************************************************************************
					--****************************************************LLAMADO AL PROCESO DE CARGO Y ABONO**********************************************

					--IF cFechaFormat = dFechaEnvio THEN
						--	Genera el folio del cargo para el cliente.
						
						CALL bdicheq:sp_generafolionomina(RPAD(TRIM(pUsuario),8,'0')) RETURNING cCodRet,cNumeroFolioCargo;

						--	se llama la ejecucion del cargo para el cliente.
						--LET iAplicoCargo = 1;
						CALL bdicheq:cargo_ref ("001", cSucursalContable, pUsuario, cTransaccCargo, "0000", cNumeroFolioCargo, cCuentaCargo,0, mImporte_dom,"01", cRef_Leyenda, '', pUsuario) 
						RETURNING cCodRet,cTranRet,dFecha_hoy,mSdoDisp,mMontoRet;
						
						LET cCodRet = LPAD(TRIM(cCodRet),5,"0");

						IF cCodRet::INTEGER <> 0 THEN
							LET iAplicoCargo = 0;
							
							LET cEstatusOper = '02';
							LET cCausaRechOper = '11';
							
							--EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
							EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cRFCOrdenante, cCuentaCargo, cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
							INTO cRetGrabaDet, cResOper;
							
							IF cRetGrabaDet = '00000' THEN
								IF cResOper = 'R' THEN
									LET iRechazos = iRechazos + 1;
									LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
								ELIF cResOper = 'P' THEN
									LET iPendientes = iPendientes + 1;
									LET iImpPendientes = iImpPendientes + (mImporte_dom * 100);
								END IF;
							ELSE
								LET bErrorControlado = 't';
								RAISE EXCEPTION cRetGrabaDet;
							END IF;	

							CONTINUE FOREACH;
						ELSE
							LET iAplicoCargo = 1;
																	
							CALL bdicheq:abono_ref( '001', cSucursalContable, pUsuario, cTransaccAbono, '0000', cNumeroFolioCargo, TRIM(cCuentaAbono_Prov), 0.00, mImporte_dom, mImporte_dom, 0.00, 0.00, 0, '01', cRef_Leyenda, '', pUsuario)
							RETURNING cCodRet;
							
							IF cCodRet::INTEGER = 0 THEN
								LET iAplicoAbono = 1;
								
								LET cEstatusOper = '01';
								LET cCausaRechOper = '00';
							
								--EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
								EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cRFCOrdenante, cCuentaCargo, cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
								INTO cRetGrabaDet, cResOper;
								
								IF cRetGrabaDet = '00000' THEN
									IF cResOper = 'R' THEN
										LET iRechazos = iRechazos + 1;
										LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
									ELIF cResOper = 'P' THEN
										LET iPendientes = iPendientes + 1;
										LET iImpPendientes = iImpPendientes + (mImporte_dom * 100);
									ELIF cResOper = 'A' THEN
										LET iAplicaciones = iAplicaciones + 1;
										LET iImpAplicaciones = iImpAplicaciones + (mImporte_dom * 100);
									END IF;
								ELSE
									LET bErrorControlado = 't';
									RAISE EXCEPTION cRetGrabaDet;
								END IF;
								
								UPDATE bdidomi:dom_cte_detalle SET folio_suc =  cNumeroFolioCargo, estatus = '01', causa_rechazo = '00'
								WHERE nombre_arch = cNom_Arch_Aux AND consecutivo = iSecuencia;
								
								LET iAplicoAbono = 0;
								LET iAplicoCargo = 0;
								
								CONTINUE FOREACH;
								
							ELSE
								LET iAplicoAbono = 0;
															
								CALL bdicheq:abono_ref( '001', cSucursalContable, pUsuario, cTransaccAbono, '0000', cNumeroFolioCargo, cCuentaCargo, 0.00, mImporte_dom, mImporte_dom, 0.00, 0.00, 0, '01', '', '', pUsuario)
								RETURNING cCodRet;

								LET cEstatusOper = '02';
								LET cCausaRechOper = '11';
							
								--EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
								EXECUTE PROCEDURE sp_domi_cop_graba_detalle_respuesta(cRFCOrdenante, cCuentaCargo, cNom_Arch_Salida, iSecuencia, cNom_Arch_Aux, smIntento, cEstatusOper, cCausaRechOper, cReintentarCuenta, smMaxIntentos, pUsuario)
								INTO cRetGrabaDet, cResOper;
								
								IF cRetGrabaDet = '00000' THEN
									IF cResOper = 'R' THEN
										LET iRechazos = iRechazos + 1;
										LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
									ELIF cResOper = 'P' THEN
										LET iPendientes = iPendientes + 1;
										LET iImpPendientes = iImpPendientes + (mImporte_dom * 100);
									ELIF cResOper = 'A' THEN
										LET iAplicaciones = iAplicaciones + 1;
										LET iImpAplicaciones = iImpAplicaciones + (mImporte_dom * 100);										
									END IF;
								ELSE
									LET bErrorControlado = 't';
									RAISE EXCEPTION cRetGrabaDet;
								END IF;
								
								LET iAplicoCargo = 0;
								CONTINUE FOREACH;						
							END IF;					
						END IF;
					
					--ELSE
					--	CONTINUE FOREACH;
					--END IF;
					--************************************************FIN LLAMADO AL PROCESO DE CARGO Y ABONO**************************************
					--*****************************************************************************************************************************
				END IF;
				
				LET iAplicoAbono = 0;
				LET iAplicoCargo = 0;
			END FOREACH; -- Fin del ciclo de busqueda por archivo y sus registros.
			
			
			--*************************************************************************************************************************************
			--***************************************************** GENERACION DE ENCABEZADO Y SUMARIO ********************************************
			LET cEstatusProceso = GEN_ARC_OUT;
			--EXECUTE PROCEDURE sp_domi_bitacora(cTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), 'PROCESO ARCHIVO PROV CPL', cEstatusProceso, '00000', pUsuario, 'sp_domi_cop_procesararchivo', cNom_Arch_Salida, cFechaFormat, '11')
			--INTO vsCodRetorno2;
			
			SELECT COUNT(*), NVL(SUM(imp_operacion::INTEGER),0)
			INTO iTotalOperaciones , iImpTotalOperaciones
			FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida;
			
			SELECT COUNT(*), NVL(SUM(imp_operacion::INTEGER),0)
			INTO iPendientes, iImpPendientes
			FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida AND estatus = '02' AND causa_rechazo = 'PR';

			SELECT COUNT(*), NVL(SUM(imp_operacion::INTEGER),0)
			INTO iAplicaciones, iImpAplicaciones
			FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida AND estatus = '01' AND causa_rechazo = '00';

			SELECT COUNT(*), NVL(SUM(imp_operacion::INTEGER),0)
			INTO iRechazos, iImpRechazos
			FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida AND estatus = '02' AND causa_rechazo <> 'PR';
			
			IF EXISTS (SELECT 1 FROM bdidomi:dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida) THEN
				--ENCABEZADO
				BEGIN WORK;
				LET bEnTransaccion = 't';
					--INSERTA EN ARCHIVOS
					INSERT INTO bdidomi:dom_cte_archivos (nombre_arch, fecha_envio, num_cte, fecha_carga, cve_status, user_insert, fecha_insert) 
					VALUES (cNom_Arch_Salida, dFecha_hoy, LPAD(cNumCte_proveedor,20,'0'), dFecha_hoy, '01', pUsuario, CURRENT::DATE);
					
					--INSERTA EN ENCABEZADO
					INSERT INTO bdidomi:dom_cte_encabezado
					(nombre_arch, fecha_envio, tipo_registro, num_cte, cuenta_abono, 
					num_operaciones, fecha_inicial, 
					fecha_final, user_insert, fecha_insert)
					VALUES
					(cNom_Arch_Salida, dFecha_hoy, 'E', LPAD(TRIM(cNumCte_proveedor),20,'0'),(SELECT LPAD(TRIM(valor),20,'0') FROM dom_parametros WHERE cod_param = '46'),
					 LPAD(iTotalOperaciones,8,'0'), (SELECT MIN(fecha_cargo) FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida),
					(SELECT MAX(fecha_cargo) FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida), pUsuario, CURRENT::DATE);
					 
					--INSERTA DE LA TABLA DETALLE_PASO A LA DE DETALLE MAESTRA
					
					INSERT INTO dom_cte_detalle (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
					cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
					ref_titular_serv, accion, reintentar_cuenta, estatus,
					causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
					fecha_insert, tipo_cta_abono)
					SELECT nombre_arch,dFecha_hoy,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
					cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
					ref_titular_serv, accion, reintentar_cuenta, estatus,
					causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
					fecha_insert, tipo_cta_abono
					FROM dom_cte_detalle_paso
					WHERE nombre_arch = cNom_Arch_Salida;
					 
					
					--INSERTA EN SUMARIO
					INSERT INTO bdidomi:dom_cte_sumario (nombre_arch, fecha_envio, tipo_registro, 
						num_operaciones, imp_operaciones, 
						num_oper_pend, imp_oper_pend, 
						num_oper_apli, imp_oper_apli, 
						num_oper_rech, imp_oper_rech, 
						user_insert, fecha_insert)
					VALUES (cNom_Arch_Salida, dFecha_hoy, 'S', 
							LPAD(iTotalOperaciones,8,'0'), LPAD(iImpTotalOperaciones,18,'0'),
							LPAD(iPendientes,8,0),
							LPAD(iImpPendientes,18,'0'),
							LPAD(iAplicaciones,8,0),
							LPAD(iImpAplicaciones,18,'0'),
							LPAD(iRechazos,8,0),
							LPAD(iImpRechazos,18,'0'),
							pUsuario,
							CURRENT::DATE);	
				COMMIT WORK;
				LET bEnTransaccion = 'f';
				
				TRUNCATE TABLE dom_cte_detalle_paso;
			END IF;			
			--END IF;
			--*************************************************FIN  GENERACION DE ENCABEZADO Y SUMARIO *******************************************************
			--************************************************************************************************************************************************
						
			LET cEstatusProceso = IMP_ARC_OUT;
			--EXECUTE PROCEDURE sp_domi_bitacora(cTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), 'PROCESO ARCHIVO PROV CPL', cEstatusProceso, '00000', pUsuario, 'sp_domi_cop_procesararchivo', cNom_Arch_Salida, cFechaFormat, '11')
			--INTO vsCodRetorno2;
			
		ELIF NVL(cEstatusProceso,'') IN (INICIADO) THEN  --EL ARCHIVO SE ESTA PROCESANDO
			LET cCodRet = '02810';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
			INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;			
		END IF;
			
		IF NVL(cEstatusProceso,'') = IMP_ARC_OUT THEN
			--EXECUTE PROCEDURE sp_domi_bitacora(cTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), 'PROCESO ARCHIVO PROV CPL', cEstatusProceso, '00000', pUsuario, 'sp_domi_cop_procesararchivo', cNom_Arch_Salida, cFechaFormat, '11')
			--INTO vsCodRetorno2;
			
			IF EXISTS (SELECT 1 FROM bdidomi:dom_cte_detalle WHERE nombre_arch = cNom_Arch_Salida) THEN
		
				EXECUTE PROCEDURE bdidomi:sp_domi_cop_generaarchivo( cNom_Arch_Salida,  '02')
				INTO cCodRetMensaje;
				
				IF cCodRetMensaje::INTEGER = 0 THEN
					LET cEstatusProceso = CARGO_COMI;
					LET cCodRet = '00000';
					
					--EXECUTE PROCEDURE sp_domi_bitacora(cTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), 'PROCESO ARCHIVO PROV CPL', cEstatusProceso, cCodRet, pUsuario, 'sp_domi_cop_procesararchivo', cNom_Arch_Salida, cFechaFormat, '11')
					--INTO vsCodRetorno2;
				ELSE			
					LET cCodRet = '02910';
					EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
					INTO cCodret,cMensaje;
					
					EXECUTE PROCEDURE sp_domi_bitacora(cTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), 'PROCESO ARCHIVO PROV CPL', cEstatusProceso, cCodret, pUsuario, 'sp_domi_cop_procesararchivo', cNom_Arch_Salida, cFechaFormat, '11')
					INTO vsCodRetorno2;	
					
					--EJECUTAR RAISE EXCEPTION????
					
					RETURN cCodRet,TRIM(cMensaje)||" -->> "||cCodRetMensaje;
				END IF;
						
				LET cCodret = LPAD(TRIM(cCodRet),5,'0');
			
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
			ELSE
				LET cEstatusProceso = CARGO_COMI;
			END IF;
		END IF;
		
		IF NVL(cEstatusProceso,'') = CARGO_COMI THEN
			--*************************************************************************************************************************************
			--***************************************************** CALCULO Y CARGO DE COMISIONES ********************************************					
			SELECT rfc, comision, cuenta_cargo_comision
			INTO cRFCOrdenante, dComision, cCuentaCargo_Comision
			FROM bdidomi:dom_cat_servicios
			WHERE num_cte = cNumCte_proveedor;
			
			-- RQM 09 704. Se agrega los campos a las variables y se onbtiene el saldo_sbc para calcular el saldo disponible con el SP.
			SELECT cuenta, sdo_actual, sdo_cong, sdo_retenido, imp_chq_sbg, saldo_sbc
			INTO cCuentaCargo_Comision, mSdoActual, mSdoCong, mSdoRetenido, mImpChqSbg, mSdoSbc--dSaldoCuentaCargoProv
			FROM bdicheq:sc_maechq 
			WHERE empresa = '001' 
			AND cuenta = SUBSTR(cCuentaCargo_Comision,9,11);
			
			-- RQM 09 704. Se agrega el SP para calcular el saldo disponible tomando en cuenta el saldo_sbc.
			EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo
			('', mSdoActual, mSdoRetenido, mSdoCong, mSdoSbc, mImpChqSbg, NULL, NULL, 'F', '1') INTO cCodRetSpCons, cMensajeRet, dSaldoCuentaCargoProv;

			SELECT COUNT(*) * dComision 
			INTO dComisionTotal 
			FROM bdidomi:dom_cte_detalle
			WHERE nombre_arch = cNom_Arch_Salida
			AND estatus IN('01','02') AND causa_rechazo <> 'CP';
			
			SELECT valor INTO dIVA FROM bdinteg:si_param WHERE cod_param = '47';

			LET dIvaComision = dComisionTotal * dIVA;
			LET dTotalCargoComision = dComisionTotal + dIvaComision;
			
			--Se agregan estas lines y se comenta bloque siguiente con el proposito de manejar un cobro mensual de comisiones en un procedimiento independiente (sp_domi_cargo_comisiones)
			IF dComisionTotal > 0 THEN
				INSERT INTO dom_cargo_comision_prov(fecha_comision, num_cte, rfc, transaccion, estatus, comision, iva, fecha_cargo, fecha_insert, fecha_movto) 
				VALUES(dFecha_hoy, cNumCte_proveedor, cRFCOrdenante, cTransaccCargoComision, 'P', dComisionTotal, dIvaComision, '', CURRENT::DATE, (SELECT DBINFO('utc_to_datetime', sh_curtime)FROM sysmaster:"informix".sysshmvals));
			END IF;
			/*IF dComisionTotal > 0 THEN
				IF dTotalCargoComision <= dSaldoCuentaCargoProv THEN
					--	Genera el folio del cargo para el cliente.						
					CALL bdicheq:sp_generafolionomina(RPAD(TRIM(pUsuario),8,'0')) RETURNING cCodRet,cNumeroFolioCargo;
					LET cCodRet = LPAD(TRIM(cCodRet),5,'0');

					--	Se realiza el cargo de la comision al ordenante			
					CALL bdicheq:cargo_ref ("001", cSucursalContable, pUsuario, cTransaccCargoComision, "0000", cNumeroFolioCargo,
					cCuentaCargo_Comision,0, dComisionTotal,"01", cReferenciaCargoComision, '', pUsuario) 
					RETURNING cCodRet,cTransaccCargoComision,dFecha_hoy,dSaldoCuentaCargoProv,mMontoRet;

					LET cCodRet = LPAD(TRIM(cCodRet),5,"0");

					IF cCodRet <> '00000' THEN						
						BEGIN WORK;
							LET bEnTransaccion = 't';
							
							CALL bdicheq:sp_generafolionomina(RPAD(TRIM(pUsuario),8,'0')) RETURNING cCodRetMensaje,cNumeroFolioCargo;
							LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
							
							--QUE SE INSERTA EN EL ANTEPENULTIMO CAMPO? ref_leyenda?
							INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
							VALUES ('001',cCuentaCargo_Comision,cTransaccCargoComision,dComisionTotal,0.00,dFecha_hoy,'','P',cNumeroFolioCargo);
							
							CALL bdicheq:sp_generafolionomina(RPAD(TRIM(pUsuario),8,'0')) RETURNING cCodRetMensaje,cNumeroFolioCargo;
							
							INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
							VALUES ('001',cCuentaCargo_Comision,cTransaccCargoIVA,dIvaComision,0.00,dFecha_hoy,'','P',cNumeroFolioCargo);
							
							--HACER OTRO INSERT CON EL IMPORTE DEL IVA DE LA COMISION?
						COMMIT WORK;
						LET bEnTransaccion = 'f';

					ELSE
						--	Genera el folio del cargo para el cliente.						
						CALL bdicheq:sp_generafolionomina(RPAD(TRIM(pUsuario),8,'0')) RETURNING cCodRet,cNumeroFolioCargo;
						LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
						--	se llama la ejecucion del cargo para el cliente.
						CALL bdicheq:cargo_ref ("001", cSucursalContable, pUsuario, cTransaccCargoIVA, "0000", cNumeroFolioCargo,
						cCuentaCargo_Comision,0, dIvaComision,"01", cReferenciaCargoIva, '', pUsuario) 
						RETURNING cCodRet,cTransaccCargoIVA,dFecha_hoy,dSaldoCuentaCargoProv,mMontoRet;

						LET cCodRet = LPAD(TRIM(cCodRet),5,"0");
						
						IF cCodRet <> '00000' THEN
							BEGIN WORK;
							LET bEnTransaccion = 't';
							
							CALL bdicheq:sp_generafolionomina(RPAD(TRIM(pUsuario),8,'0')) RETURNING cCodRetMensaje,cNumeroFolioCargo;
							
							INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
							VALUES ('001',cCuentaCargo_Comision,cTransaccCargoIVA,dIvaComision,0.00,dFecha_hoy,'','P',cNumeroFolioCargo);
							
							COMMIT WORK;
							LET bEnTransaccion = 'f';						
						END IF;
					END IF;
				ELSE
					SELECT COUNT(*) 
					INTO iContadorComisiones 
					FROM bdidomi:dom_cte_detalle
					WHERE nombre_arch = cNom_Arch_Salida;

					LET dComisionTotal = 0;
					LET dIvaComision = 0;
					LET dTotalCargoComision  = 0;
					
					FOR iContadorPagadas = 1 TO iContadorComisiones

						LET dComisionTotal = iContadorPagadas * dComision;
						LET dIvaComision = dComisionTotal * dIVA;
						LET dTotalCargoComision = dComisionTotal + dIvaComision;

						IF dTotalCargoComision > dSaldoCuentaCargoProv AND dSaldoCuentaCargoProv > 0 THEN
							LET iBanderaIndicaSiSaldoEsMayor = 1;
							EXIT FOR;
						END IF;
					END FOR;

					IF iBanderaIndicaSiSaldoEsMayor = 1 THEN
						LET iContadorPagadas = iContadorPagadas - 1;
						LET iBanderaIndicaSiSaldoEsMayor = 0;
					END IF;
					
					LET dComisionTotal = iContadorPagadas * dComision;
					LET dIvaComision = dComisionTotal * dIVA;
					LET dTotalCargoComision = dComisionTotal + dIvaComision;
					LET iContadorNoPagadas = iContadorComisiones - iContadorPagadas;
					
					IF dComisionTotal > 0 AND dIvaComision > 0 THEN
						--	Genera el folio del cargo para el cliente.
						CALL bdicheq:sp_generafolionomina(RPAD(TRIM(pUsuario),8,'0')) RETURNING cCodRet,cNumeroFolioCargo;
						LET cCodRet = LPAD(TRIM(cCodRet),5,'0');

						--	se llama la ejecucion del cargo para el cliente.
						CALL bdicheq:cargo_ref ("001", cSucursalContable, pUsuario, cTransaccCargoComision, "0000", cNumeroFolioCargo,
						cCuentaCargo_Comision,0, dComisionTotal,"01", cReferenciaCargoComision, '', pUsuario) RETURNING cCodRet,cTransaccCargoComision,dFecha_hoy,dSaldoCuentaCargoProv,mMontoRet;

						LET cCodRet = LPAD(TRIM(cCodRet),5,"0");

						IF cCodRet <> 0 THEN
							BEGIN WORK;
							LET bEnTransaccion = 't';
								CALL bdicheq:sp_generafolionomina(RPAD(TRIM(pUsuario),8,'0')) RETURNING cCodRetMensaje,cNumeroFolioCargo;
								LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
								
								INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
								VALUES ('001',cCuentaCargo_Comision,cTransaccCargoComision,dComisionTotal,0.00,dFecha_hoy,'','P',cNumeroFolioCargo);
								--HACER OTRO INSERT CON EL IMPORTE DEL IVA DE LA COMISION en la tabla sc_detcomis??
								
								CALL bdicheq:sp_generafolionomina(RPAD(TRIM(pUsuario),8,'0')) RETURNING cCodRetMensaje,cNumeroFolioCargo;
								
								INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
								VALUES ('001',cCuentaCargo_Comision,cTransaccCargoIVA,dIvaComision,0.00,dFecha_hoy,'','P',cNumeroFolioCargo);
							COMMIT WORK;
							LET bEnTransaccion = 'f';
						ELSE
							--	Genera el folio del cargo para el cliente.
							CALL bdicheq:sp_generafolionomina(RPAD(TRIM(pUsuario),8,'0')) RETURNING cCodRet,cNumeroFolioCargo;

							LET cCodRet = LPAD(TRIM(cCodRet),5,'0');

							--	se llama la ejecucion del cargo para el cliente.
							CALL bdicheq:cargo_ref ("001", cSucursalContable, pUsuario, cTransaccCargoIVA, "0000", cNumeroFolioCargo,
							cCuentaCargo_Comision,0, dIvaComision,"01", cReferenciaCargoIva, '', pUsuario) RETURNING cCodRet,cTransaccCargoIVA,dFecha_hoy,dSaldoCuentaCargoProv,mMontoRet;

							LET cCodRet = LPAD(TRIM(cCodRet),5,"0");
							IF cCodRet <> '00000' THEN
								BEGIN WORK;
								LET bEnTransaccion = 't';
								
								CALL bdicheq:sp_generafolionomina(RPAD(TRIM(pUsuario),8,'0')) RETURNING cCodRetMensaje,cNumeroFolioCargo;
								
								INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
								VALUES ('001',cCuentaCargo_Comision,cTransaccCargoIVA,dIvaComision,0.00,dFecha_hoy,'','P',cNumeroFolioCargo);
								
								COMMIT WORK;
								LET bEnTransaccion = 'f';
							END IF;
						END IF;
					END IF;
					
					LET dComisionPendiente = iContadorNoPagadas * dComision;
						
					IF dComisionPendiente > 0 THEN
						--Genera el folio del cargo a la cuenta cargo.
						BEGIN WORK;
						LET bEnTransaccion = 't';
							CALL bdicheq:sp_generafolionomina(RPAD(TRIM(pUsuario),8,'0')) RETURNING cCodRetMensaje,cNumeroFolioCargo;
							LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
							--Registro Comisiones pendientes
							INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
							VALUES ('001',cCuentaCargo_Comision,cTransaccCargoComision,dComisionPendiente,0.00,dFecha_hoy,'','P',cNumeroFolioCargo);
							
							CALL bdicheq:sp_generafolionomina(RPAD(TRIM(pUsuario),8,'0')) RETURNING cCodRetMensaje,cNumeroFolioCargo;
							
							INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
							VALUES ('001',cCuentaCargo_Comision,cTransaccCargoIVA,(dComisionPendiente * dIVA),0.00,dFecha_hoy,'','P',cNumeroFolioCargo);
							
						COMMIT WORK;
						LET bEnTransaccion = 't';
						
					END IF;
				END IF;
			END IF;*/
			
			LET cEstatusProceso = TERMINADO;
			LET cCodRet = '00000';
			
			--EXECUTE PROCEDURE sp_domi_bitacora(cTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), 'PROCESO ARCHIVO PROV CPL', cEstatusProceso, cCodRet, pUsuario, 'sp_domi_cop_procesararchivo', cNom_Arch_Salida, cFechaFormat, '11')
			--INTO vsCodRetorno2;		

			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
			INTO cCodret,cMensaje;
		END IF;

		--VERIFICA SI ES NECESARIO ENVIAR NOTIFICACIONES DE ERROR
		IF bErrores = 't' THEN
			--ENVIA SMS
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento_prod('1', 'DOM_COPPSM', 'DOM_COPPSM','GRUPO_DOM_COP_SMS', '','', '1', '','','','','','','','','', CURRENT,'','',1,0,0,0,0,'','')
			INTO cCodRetSMS;
			
			IF cCodRetSMS <> '00000' THEN
				INSERT INTO dom_errores(fecha_error,hora_error,cod_error,nombre_arch,sp_llamado,mensaje_error,user_insert,fecha_insert)
				VALUES (CURRENT,CURRENT HOUR TO FRACTION,cCodRetSMS,cNom_Arch_Aux,'sp_domi_cop_procesararchivo','Error al enviar SMS',pUsuario,CURRENT);
			END IF;
			--ENVIA EMAIL
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento_prod('2', 'DOM_COPPEM', 'DOM_COPPEM','GRUPO_DOM_COP', '','', '1', '','','','','','','','','', CURRENT,'','',1,0,0,0,0,'','')
			INTO cCodRetSMS;
			
			IF cCodRetSMS <> '00000' THEN
				INSERT INTO dom_errores(fecha_error,hora_error,cod_error,nombre_arch,sp_llamado,mensaje_error,user_insert,fecha_insert)
				VALUES (CURRENT,CURRENT HOUR TO FRACTION,cCodRetSMS,cNom_Arch_Aux,'sp_domi_cop_procesararchivo','Error al enviar EMAIL',pUsuario,CURRENT);
			END IF;
		END IF;
		EXECUTE PROCEDURE sp_domi_bitacora(cTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), 'PROCESO ARCHIVO PROV CPL', cEstatusProceso, cCodRet, pUsuario, 'sp_domi_cop_procesararchivo', cNom_Arch_Salida, cFechaFormat, '11')
		INTO vsCodRetorno2;		
		
		RETURN cCodRet,cMensaje;
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procesar los archivos de domiciliacion Coppel y genera archivo de respuesta',
'FECHA: 2016/10/06',
'VERSION: 20161007.0825',
'BD: bdidomi',
'MODIFICO :     Ezequiel Moreno Paredes',
'BD :     		bdidomi',
'FECHA :        07-07-2025',
'MODIFICACION : Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo llamado saldo_sbc',
'PROYECTO :     RQM 09 704 Cobranza Automatica en cuentas de captacion',
'VERSION :      20161007.09';