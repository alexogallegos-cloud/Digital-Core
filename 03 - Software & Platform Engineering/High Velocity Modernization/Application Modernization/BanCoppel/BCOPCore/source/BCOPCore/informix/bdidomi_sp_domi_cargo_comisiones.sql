CREATE PROCEDURE "informix".sp_domi_cargo_comisiones(cTipoEjecucion CHAR(1), pUsuario CHAR (8))
	RETURNING CHAR(5), CHAR(200);

	--	Definicion de variables.
	DEFINE dFecha_hoy					DATE;
	DEFINE cFechaFormat					CHAR(10);
	DEFINE iExiste						INTEGER;
	DEFINE iSQLerr						INTEGER;
	DEFINE cSucursalContable			CHAR(4);
	DEFINE cCodRet						CHAR(5);
	DEFINE cCodRetComis					CHAR(5);
	DEFINE cNumeroFolioCargo			CHAR(16);
	DEFINE cRFCOrdenante				CHAR(18);
	DEFINE cCuentaAbono_Prov			CHAR(20);
	DEFINE cMensaje						CHAR(200);
	DEFINE cNumCte_proveedor			CHAR(20);
	DEFINE cEstatusProceso				CHAR(1);
	DEFINE vsNomProceso					CHAR(20);
	DEFINE vsCodRetorno2				CHAR(5);
	DEFINE cCuentaCargo_Comision 		CHAR(20);
	DEFINE dComisionTotal				DECIMAL(16,2);
	DEFINE dIvaComision					DECIMAL(16,2);
	DEFINE dSaldoCuentaCargoProv		DECIMAL(16,2);
	DEFINE dIVA							DECIMAL(16,2);
	DEFINE dTotalCargoComision			DECIMAL(16,2);
	DEFINE dComisionPendiente			DECIMAL(16,2);
	DEFINE cTransaccCargoComision		CHAR(4);
	DEFINE cTransaccCargoIVA			CHAR(4);
	DEFINE cReferenciaCargoIva			CHAR(50);
	DEFINE cReferenciaCargoComision 	CHAR(50);
	DEFINE bEnTransaccion				BOOLEAN;
	DEFINE dFechaUltDiaMesActual				DATE;
	DEFINE dFechaPriDiaMesActual				DATE;
	DEFINE dFechaAux					DATE;
	DEFINE INICIADO						CHAR(1);
	DEFINE TERMINADO					CHAR(1);
	DEFINE ERROR						CHAR(1);
	DEFINE cEstatusCargoCom				CHAR(1);
	DEFINE cEstatusCargoIva				CHAR(1);
	DEFINE cTipoDomi					CHAR(3);
	DEFINE iPaso						SMALLINT;
	DEFINE cDivisaCtaCargoComision		CHAR(2);
	DEFINE cAnioMesComision				CHAR(6);
	DEFINE cAnioComision				CHAR(4);
	DEFINE cMesComision					CHAR(2);
	DEFINE bErrores						BOOLEAN;
	DEFINE cCodRetSMS					CHAR(5);
	--	Cacha algun posible error no controlado.

	ON EXCEPTION SET iSQLerr
		IF iSQLerr <> 0 THEN
			LET cCodRet = iSQLerr;

			SET ISOLATION DIRTY READ;
			SET LOCK MODE TO WAIT 3;
							
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
			INTO cCodret,cMensaje;
			
			IF bEnTransaccion = 't' THEN
				ROLLBACK WORK;
			END IF;
				
			EXECUTE PROCEDURE sp_domi_bitacora(cTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), 'CARGO COMISION PROVR DOMI CTAS BCPL', ERROR, cCodRet, pUsuario, 'sp_domi_cop_cargo_comisiones', '', cFechaFormat, '11')
			INTO vsCodRetorno2;
			
			RETURN cCodRet, cMensaje;
			
		END IF;		
	END EXCEPTION;
    
	--SET DEBUG FILE TO "/tmp/josea/10211/liberacion_final/sp_domi_cop_cargo_comisiones.out";
    --TRACE ON;	
	
    SET ISOLATION DIRTY READ;
    SET LOCK MODE TO WAIT 4;
	
	--	Inicializacion de las variables.
	
	LET cCodRet			  	= "00000";
	LET cSucursalContable 	= "";
	LET cMensaje			= "PROCESAMIENTO EXITOSO";
	LET cNumeroFolioCargo	= "";
	LET dFecha_hoy			= "";
	LET cCuentaAbono_Prov 	= "";
	LET cRFCOrdenante		= "";
	LET iExiste 		  	= 0;
	LET iSQLerr				= 0;
	LET cNumCte_proveedor 	= '';
	LET cEstatusProceso = '';
	LET vsNomProceso = 'CARGOCOMIS_BCP.01';
	LET cCuentaCargo_Comision	= '';
	LET dComisionTotal			= 0.00;
	LET dIvaComision			= 0.00;
	LET dSaldoCuentaCargoProv	= 0.00;
	LET dIVA					= 0.00;
	LET dTotalCargoComision		= 0.00;
	LET dComisionPendiente		= 0.00;
	LET cTransaccCargoComision	= '';
	LET cTransaccCargoIVA		= '';
	LET cReferenciaCargoIva		= '';
	LET cReferenciaCargoComision= '';
	LET bEnTransaccion = 'f';
	LET dFechaUltDiaMesActual = '';
	LET dFechaPriDiaMesActual	= '';
	LET dFechaAux = '';
	LET dComisionTotal = 0.00;
	LET INICIADO = 0;
	LET TERMINADO = 1;
	LET ERROR = 3;
	LET cEstatusCargoCom = 'F';
	LET cEstatusCargoIva = 'F';
	LET cTipoDomi = 'BCP';
	LET iPaso = 0;
	LET cDivisaCtaCargoComision = '';
	LET cAnioMesComision = '';
	LET cAnioComision = '';
	LET cMesComision = '';
	LET bErrores = 'f';
	LET cCodRetSMS = '';
	LET cCodRetComis = '';
	
	BEGIN

		--***********************************************************************************************************************************
		--****************************************************INICIO CONSULTA DE PARAMETROS Y VALIDACIONES*************************************
		--	Consulta  fecha del sistema de cheques.
		SELECT fecha_hoy INTO dFecha_hoy FROM bdicheq:sc_fechas;
		
		LET dFechaUltDiaMesActual = ((EXTEND(dFecha_hoy::DATE, YEAR TO MONTH) +1 UNITS MONTH)::DATE - 1);
		LET dFechaPriDiaMesActual = (dFechaUltDiaMesActual - DAY(dFechaUltDiaMesActual) +1);
		
		LET cFechaFormat = YEAR(dFecha_hoy) || LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0');

		--	se extrae el valor de la sucursal contable.
		IF EXISTS (SELECT 1 FROM bdidomi:dom_parametros WHERE cod_param = '07') THEN 
			SELECT valor INTO cSucursalContable 
			FROM bdidomi:dom_parametros WHERE cod_param = '07';
		ELSE
			LET cCodRet = '03001';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) INTO cCodret,cMensaje;
						
			RETURN cCodRet, cMensaje;
		END IF;

		IF NOT EXISTS (SELECT 1 FROM bdinteg:si_sucursales WHERE sucursal = cSucursalContable) THEN 
			LET cCodRet = '03002';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;
		END IF;

		
		IF EXISTS(SELECT 1 FROM bdidomi:dom_parametros WHERE cod_param = '49') THEN
			SELECT TRIM(valor), descripcion 
			INTO cTransaccCargoComision, cReferenciaCargoComision 
			FROM bdidomi:dom_parametros WHERE cod_param = '49';			
		ELSE
			LET cCodRet = '03003';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;
		END IF;
		
		IF EXISTS(SELECT 1 FROM bdidomi:dom_parametros WHERE cod_param = '15') THEN
			SELECT TRIM(valor), descripcion 
			INTO cTransaccCargoIVA, cReferenciaCargoIva
			FROM bdidomi:dom_parametros WHERE cod_param = '15';
		ELSE
			LET cCodRet = '03004';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;		
		END IF;
		
		SELECT COUNT(numero) INTO iExiste 
		FROM bdinteg:si_transacc WHERE numero IN (cTransaccCargoComision, cTransaccCargoIVA);

		IF iExiste < 2 Then
			LET cCodRet = '03005';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;
		END IF;
		
		LET iExiste = 0;
	
		/*IF EXISTS (SELECT 1 FROM dom_parametros WHERE cod_param = '45') THEN
			SELECT TRIM(valor) INTO cNumCte_proveedor 
			FROM dom_parametros 
			WHERE cod_param = '45';
			
			IF NVL(cNumCte_proveedor,'') = '' THEN
				LET cCodRet = '03006';
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
				RETURN cCodRet, cMensaje;
			END IF;
		ELSE
			LET cCodRet = '03006';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;
		END IF;*/
		
		IF EXISTS (SELECT 1 FROM dom_parametros WHERE cod_param = '46') THEN
			SELECT TRIM(valor) INTO cCuentaAbono_Prov 
			FROM dom_parametros 
			WHERE cod_param = '46';
			
			IF NVL(cCuentaAbono_Prov,'') = '' THEN
				LET cCodRet = '03007';
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
				RETURN cCodRet, cMensaje;
			END IF;	
		ELSE
			LET cCodRet = '03007';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;
		END IF;

		/*IF EXISTS(SELECT rfc FROM bdidomi:dom_cat_servicios WHERE num_cte = cNumCte_proveedor) THEN
			SELECT NVL(rfc,''), NVL(num_reintentos,0)+1 INTO cRFCOrdenante, smMaxIntentos
			FROM bdidomi:dom_cat_servicios 
			WHERE num_cte = cNumCte_proveedor;
			
			IF cRFCOrdenante = '' OR LENGTH(TRIM(cRFCOrdenante)) < 12 THEN
				LET cCodRet = '03008';
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
					INTO cCodret,cMensaje;
				RETURN cCodRet, cMensaje;
			END IF;			
		ELSE
			LET cCodRet = '03008';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;
		END IF;*/

		IF LENGTH(pUsuario) NOT IN (7,8) OR NVL(pUsuario,'') = '' THEN
			LET cCodRet = '03009';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;
		END IF;		
		
		IF EXISTS (SELECT 1 FROM bdinteg:si_param WHERE cod_param = '47') THEN
			SELECT NVL(valor,0) INTO dIVA FROM bdinteg:si_param WHERE cod_param = '47';
			
			IF dIVA = 0 THEN
				LET cCodRet = '03010';
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
					INTO cCodret,cMensaje;
				RETURN cCodRet, cMensaje;
			END IF;
		ELSE
			LET cCodRet = '03010';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
				INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;
		END IF;
				
		
		LET dFechaAux = dFechaPriDiaMesActual;
	
		/*SELECT DISTINCT (a.rfc_ord),b.comision,b.cuenta_cargo_comision
		INTO cRFCOrdenante,mValorComisionIndividual,cCuentaAbono
		FROM bdidomi:dom_cce_detalle_paso AS a
		INNER JOIN bdidomi:dom_cat_servicios AS b ON (a.rfc_ord = b.rfc)
		WHERE a.nombre_arch = pNom_Arch32*/
		
		SELECT NVL(estatus,'')
		INTO cEstatusProceso
		FROM bdidomi:dom_procesos 
		WHERE tipo_proceso = cTipoEjecucion 
		AND fecha_proceso = dFecha_hoy
		AND cve_proceso = vsNomProceso;

		IF NVL(cEstatusProceso,'') = INICIADO THEN 
			LET cCodRet = '03012';
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
			INTO cCodret,cMensaje;
			RETURN cCodRet, cMensaje;			
		END IF;		
		--********************************************************************************************************************************
		--***************************************** CALCULO Y CARGO DE COMISIONES DOMI CTAS BANCOPPEL*************************************
		EXECUTE PROCEDURE sp_domi_bitacora(cTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), 'PROCESO ARCHIVO PROV CPL', INICIADO, '00000', pUsuario, 'sp_domi_cop_receptor', '', cFechaFormat, '11')
		INTO vsCodRetorno2;
				
		IF EXISTS (SELECT 1 FROM bdidomi:dom_cargo_comision_prov WHERE fecha_comision < dFechaPriDiaMesActual AND estatus = 'P') THEN
		
			--Cargo de comisiones correspondientes al servicio de domiciliacion con cargo a cuentas BanCoppel		
			SET ISOLATION DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH WITH HOLD
				--SELECT a.num_cte, a.rfc, NVL(a.transaccion,'') AS transaccion, NVL(SUM(a.comision),0) AS comision, NVL(SUM(a.iva),0) AS iva
				SELECT YEAR(a.fecha_comision)|| LPAD(MONTH(a.fecha_comision),2,'0') AS mes_comision, a.num_cte, a.rfc, NVL(a.transaccion,'') AS transaccion, NVL(SUM(a.comision),0) AS comision, NVL(SUM(a.iva),0) AS iva
				INTO cAnioMesComision, cNumCte_proveedor, cRFCOrdenante, cTransaccCargoComision, dComisionTotal, dIvaComision
				FROM bdidomi:dom_cargo_comision_prov a
				WHERE fecha_comision < dFechaPriDiaMesActual
				AND estatus = 'P'
				GROUP BY 1,2,3,4
							
				ON EXCEPTION SET iSQLerr
					IF iSQLerr <> 0 THEN
						LET bErrores = 't';
						
						LET cCodRet = iSQLerr;
						
						EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
						INTO cCodret,cMensaje;
						
						IF bEnTransaccion = 't' THEN
							ROLLBACK WORK;
							LET bEnTransaccion = 'f';
						END IF;
						
						LET cEstatusCargoCom = 'F';
						LET cEstatusCargoIva = 'F';
						LET dComisionTotal = 0;
						LET dIvaComision = 0;
						LET dComisionPendiente = 0;
						
						INSERT INTO bdidomi:dom_cargo_comision_prov_bitacora (fecha_comision, num_cte, rfc, cod_ret, fecha_insert, fecha_movto)
						VALUES(dFecha_hoy, cNumCte_proveedor, cRFCOrdenante, cCodRet, CURRENT::DATE,(SELECT DBINFO('utc_to_datetime', sh_curtime)FROM sysmaster:"informix".sysshmvals));
						
						CONTINUE FOREACH;
					END IF;
				END EXCEPTION WITH RESUME;

				IF bEnTransaccion = 'f' THEN
					BEGIN WORK;
					LET bEnTransaccion = 't';
				END IF;
				
				LET cAnioComision = SUBSTR(cAnioMesComision,1,4);
				LET cMesComision = SUBSTR(cAnioMesComision,5,2);
				
				SELECT cuenta_cargo_comision 
				INTO cCuentaCargo_Comision
				FROM bdidomi:dom_cat_servicios
				WHERE num_cte = cNumCte_proveedor;
				
				SELECT b.divisa 
				INTO cDivisaCtaCargoComision
				FROM bdicheq:sc_maechq a, bdicheq:sc_producto b
				WHERE a.producto = b.producto
				AND a.cuenta = SUBSTR(cCuentaCargo_Comision,9,11);
							
				LET iPaso = 1; --No se ha cobrado comisiÃ³n mensual		
				
				SELECT cuenta,sdo_actual-(sdo_cong + sdo_retenido+imp_chq_sbg)
				INTO cCuentaCargo_Comision,dSaldoCuentaCargoProv
				FROM bdicheq:sc_maechq 
				WHERE empresa = '001' 
				AND cuenta = SUBSTR(cCuentaCargo_Comision,9,11);
				
				--LET dIvaComision = dComisionTotal * dIVA;
				
				--Asignacion de PRUEBA para validar flujo				
				--/*************************************************/
				--/*************************************************/
				--LET dComisionTotal = dSaldoCuentaCargoProv + 100;
				--LET dIvaComision = dComisionTotal * dIVA;
				--/*************************************************/
				--/*************************************************/
				
				LET dTotalCargoComision = dComisionTotal + dIvaComision;
				
				LET iPaso = 2; --Se calcularon comisiones
				IF dComisionTotal > 0 THEN		
					CALL bdicheq:sp_generafolionomina(RPAD(TRIM(pUsuario),8,'0')) RETURNING cCodRetComis,cNumeroFolioCargo;
					LET cCodRetComis = LPAD(TRIM(cCodRetComis),5,'0');
					
					EXECUTE PROCEDURE bdicheq:cargo_comisiones('001', cCuentaCargo_Comision,cTransaccCargoComision,dComisionTotal,cNumeroFolioCargo,cSucursalContable,pUsuario,
										 0, cDivisaCtaCargoComision, dFecha_hoy)
					INTO cCodRetComis;						

					INSERT INTO bdidomi:dom_cargo_comision_prov_bitacora (fecha_comision, num_cte, rfc, cod_ret, fecha_insert, fecha_movto)
					VALUES(dFecha_hoy, cNumCte_proveedor, cRFCOrdenante, cCodRetComis, CURRENT::DATE,(SELECT DBINFO('utc_to_datetime', sh_curtime)FROM sysmaster:"informix".sysshmvals));
					
					IF cCodRetComis::INTEGER = 0 THEN	
						LET cEstatusCargoCom = 'V';
						
						UPDATE bdidomi:dom_cargo_comision_prov
						SET estatus = 'A', fecha_cargo = dFecha_hoy
						WHERE num_cte = cNumCte_proveedor
						AND rfc = cRFCOrdenante
						AND transaccion = cTransaccCargoComision
						AND estatus = 'P';
					ELSE
						LET bErrores = 't';
						--LET cCodRet = LPAD(TRIM(cCodRet),5,"0");
						
						--IF cCodRet IN ('00549', '00550', '00777')  THEN
						--	COMMIT WORK;
						--END IF;*/
					END IF;
					

				END IF;	
				IF bEnTransaccion = 't' THEN
					COMMIT WORK;
					LET bEnTransaccion = 'f';
				END IF;
					
				LET cEstatusCargoCom = 'F';
				LET cEstatusCargoIva = 'F';
				
				LET dComisionTotal = 0;
				LET dIvaComision = 0;
				LET dComisionPendiente = 0;					
			END FOREACH;
		ELSE
			LET cCodRet = '03013';
		END IF;
		
		IF bErrores = 't' THEN
			--ENVIA SMS
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento_prod('1', 'DOM_COPPSM', 'DOM_COMSMS','GRUPO_DOM_COP_SMS', '','', '1', '','','','','','','','','', CURRENT,'','',1,0,0,0,0,'','')
			INTO cCodRetSMS;

			IF cCodRetSMS <> '00000' THEN
				INSERT INTO dom_errores(fecha_error,hora_error,cod_error,nombre_arch,sp_llamado,mensaje_error,user_insert,fecha_insert)
				VALUES (CURRENT,CURRENT HOUR TO FRACTION,cCodRetSMS,'','sp_domi_cargo_comisiones','Error al enviar SMS',pUsuario,CURRENT);
								
			END IF;
			--ENVIA EMAIL
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento_prod('2', 'DOM_COPPEM', 'DOM_COMEM','GRUPO_DOM_COP', '','', '1', '','','','','','','','','', CURRENT,'','',1,0,0,0,0,'','')
			INTO cCodRetSMS;
			
			IF cCodRetSMS <> '00000' THEN
				INSERT INTO dom_errores(fecha_error,hora_error,cod_error,nombre_arch,sp_llamado,mensaje_error,user_insert,fecha_insert)
				VALUES (CURRENT,CURRENT HOUR TO FRACTION,cCodRetSMS,'','sp_domi_cargo_comisiones','Error al enviar EMAIL',pUsuario,CURRENT);
			END IF;
		END IF;		
		--LET cCodRet = '00000';
		
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodret) 
		INTO cCodret,cMensaje;
		IF LPAD (cCodRet,5,'0') = '00000' THEN
			
			EXECUTE PROCEDURE sp_domi_bitacora(cTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), 'CARGO COMISION PROVR DOMI CTAS BCPL', TERMINADO, cCodRet, pUsuario, 'sp_domi_cop_cargo_comisiones', '', cFechaFormat, '11')
			INTO vsCodRetorno2;		
		ELSE
			EXECUTE PROCEDURE sp_domi_bitacora(cTipoEjecucion, dFecha_hoy, TRIM(vsNomProceso), 'CARGO COMISION PROVR DOMI CTAS BCPL', ERROR, cCodRet, pUsuario, 'sp_domi_cop_cargo_comisiones', '', cFechaFormat, '11')
			INTO vsCodRetorno2;		
		END IF;
		
		RETURN cCodRet,cMensaje;
	END
END PROCEDURE;