CREATE PROCEDURE "informix".sp_domi_cop_graba_detalle_respuesta(cRFC_Ordenante CHAR(18), cCuentaCargo CHAR(20), cNom_Arch_Salida CHAR(20), iSecuencia INTEGER, cNom_Arch_Entrada CHAR(20),
 smIntento SMALLINT, cEstatus CHAR(2), cCausaRechazo CHAR(2), cReintentarCuenta CHAR(1), smMaxintentos SMALLINT, cUsuario CHAR(8))
	RETURNING CHAR(5), CHAR(1);
	
	--DEFINICION DE VARIABLES
	DEFINE iSQLerr		     INTEGER;
	DEFINE cCodRet           CHAR(5);
	DEFINE cEstatusOper	     CHAR(1);
	DEFINE cSecuencia	     CHAR(6);
	DEFINE bEntransaccion    BOOLEAN;
	DEFINE dFechaActual	     DATE;
	DEFINE dProxFechahabil   DATE;
	DEFINE cFecha_cargo_cteD CHAR(8);
	DEFINE cFecha_abono_cteD CHAR(8);
	DEFINE cCodSpFecha		 CHAR(5);
	DEFINE mIva				 MONEY(15,2);
	DEFINE mComision 		 MONEY(18,2);
	--DEFINE cCuentaCargo		CHAR(20);
	DEFINE iNumRechazos		INTEGER;
	DEFINE iMaxRechPerm		INTEGER ;
	DEFINE iExiste			INTEGER;
	DEFINE iContador		INTEGER;
	
	
	--INICIALIZACION DE VARIABLES
	LET cCodRet           = '00000';
	LET cEstatusOper      = '';
	LET bEntransaccion    = 'f';
	LET dFechaActual      = '';
	LET dProxFechahabil   = '';
	LET cFecha_cargo_cteD = '';
	LET cFecha_abono_cteD = '';
	LET cCodSpFecha       = '00000';
	LET mIva = 0.00;
	LET mComision = 0.00;
	LET iMaxRechPerm = 0;
	LET iNumRechazos = 0;
	LET iExiste = 0;
	LET iContador = 0;

	BEGIN
		
		ON EXCEPTION SET iSQLerr
			IF iSQLerr <> 0 THEN
				IF bEntransaccion = 't' THEN 
					ROLLBACK WORK;
				END IF;
				
				LET cCodRet = iSqlErr;
				
				RETURN cCodRet, cEstatusOper;				
			END IF;
		END EXCEPTION;
		
		IF NVL(cRFC_Ordenante,'') = '' OR NVL(cNom_Arch_Salida,'') = '' OR  (iSecuencia = 0 OR iSecuencia IS NULL) OR NVL(cNom_Arch_Entrada ,'') = '' OR (smIntento = 0 OR smIntento IS NULL)
			OR NVL(cEstatus, '') = '' OR NVL(cCausaRechazo, '') = '' OR NVL(cReintentarCuenta, '') = '' OR  cReintentarCuenta NOT IN ('S','N')
			OR (smMaxintentos IS NULL OR smMaxintentos = 0) OR NVL(cUsuario, '') = ''	THEN
			
			LET cCodRet = '00001';
		ELSE						
			BEGIN WORK;
				LET bEntransaccion = 't';
				
				/*SELECT valor 
				INTO mIva 
				FROM bdinteg:si_param  WHERE cod_param = '47';*/
				
				SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0') 
				INTO cSecuencia FROM bdidomi:dom_cte_detalle_paso
				WHERE nombre_arch = cNom_Arch_Salida;
				
				/*SELECT comision
				INTO mComision
				FROM dom_cat_servicios WHERE rfc = TRIM(cRFC_Ordenante);*/
					
				IF cEstatus <> '01' THEN 
				
					IF cCausaRechazo = '04' THEN
													
						SELECT NVL(num_rechazos,0) + 1
						INTO iNumRechazos 
						FROM bdidomi:dom_autorizaciones 
						WHERE cuenta = cCuentaCargo 
							AND rfc = cRFC_Ordenante;
						
						SELECT valor::INTEGER
						INTO iMaxRechPerm 
						FROM bdidomi:dom_parametros WHERE cod_param = '11';
						
						IF cReintentarCuenta = 'S' THEN
						
							IF smIntento < smMaxIntentos THEN
							
								IF iNumRechazos < iMaxRechPerm THEN
									SELECT fecha_hoy
									INTO dFechaActual
									FROM bdicheq:sc_fechas;
									
									WHILE (iExiste = 0)
										LET iContador = iContador + 1;
										
										EXECUTE FUNCTION bdinteg:splvalfecha('001',(dFechaActual) + iContador ,0)INTO cCodSpFecha,dProxFechahabil;
										
										IF NOT EXISTS 
											(SELECT fecha FROM bdinteg:si_feriado WHERE fecha = dProxFechahabil AND pais = '001') THEN
						 
											LET iExiste = 1;
																				
										END IF;	
										
										IF iContador >= 5 THEN
											LET iExiste = 1;
										END IF;
										
									END WHILE
								
									LET cFecha_cargo_cteD = YEAR(dProxFechahabil) || LPAD(MONTH(dProxFechahabil),2,'0')|| LPAD(DAY(dProxFechahabil),2,'0');
									LET cFecha_abono_cteD = cFecha_cargo_cteD;
									
									LET cCausaRechazo = 'PR';
									
									INSERT INTO dom_cte_detalle_paso (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
									cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
									ref_titular_serv, accion, reintentar_cuenta, estatus,
									causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
									fecha_insert, tipo_cta_abono)
									SELECT cNom_Arch_Salida,fecha_envio,tipo_registro, cSecuencia, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, --cFecha_trans,
									cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
									ref_titular_serv, accion, reintentar_cuenta, cEstatus, 
									cCausaRechazo, '', '', '', '', '', '', cUsuario, 
									CURRENT::DATE, ''
									FROM dom_cte_detalle 
									WHERE nombre_arch = cNom_Arch_Entrada 
									AND consecutivo = LPAD (TRIM (iSecuencia::CHAR(6)),6,'0');
									
									UPDATE dom_cte_detalle 
									SET estatus = 'EP', fecha_cargo = cFecha_cargo_cteD, fecha_abono = cFecha_abono_cteD
										,comision_cobrada = LPAD((mComision * 100):: INTEGER,16,'0') , iva_cobrado = LPAD(((mComision * mIva) * 100):: INTEGER,16,'0')
									WHERE nombre_arch = cNom_Arch_Entrada 
										AND consecutivo = LPAD (TRIM (iSecuencia::CHAR(6)),6,'0');
												
									INSERT INTO dom_cte_reintentos_cce(nombre_arch, fecha_envio, tipo_registro, consecutivo, num_intento, fecha_cargo, fecha_abono,
											nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, estatus, user_insert, fecha_insert)
									SELECT nombre_arch,fecha_envio,tipo_registro,consecutivo,smIntento, fecha_cargo, fecha_abono,
											'','','','', cEstatus, cUsuario, CURRENT
									FROM dom_cte_detalle 
									WHERE nombre_arch = cNom_Arch_Entrada 
									AND consecutivo = LPAD (TRIM (iSecuencia::CHAR(6)),6,'0');
									
									UPDATE bdidomi:dom_autorizaciones SET num_rechazos = num_rechazos + 1
									WHERE cuenta = cCuentaCargo AND rfc = cRFC_Ordenante;
									--OPERACION PENDIENTE
									LET cEstatusOper = 'P';
								ELSE
									UPDATE bdidomi:dom_cte_detalle
									SET estatus = cEstatus, causa_rechazo = cCausaRechazo--, intentos = smIntento,
										,comision_cobrada = LPAD((mComision * 100):: INTEGER,16,'0') , iva_cobrado = LPAD(((mComision * mIva) * 100):: INTEGER,16,'0')
									WHERE nombre_arch = cNom_Arch_Entrada 
									AND consecutivo = LPAD (TRIM (iSecuencia::CHAR(6)),6,'0');
									
									--Comentado para no bloquear las domiciliaciones RMQ 06 894 Modificaciones en intentos de cobranza al proceso de DOMI
									--UPDATE bdidomi:dom_autorizaciones SET cve_estatus = '02',cve_causa = '01', num_rechazos = num_rechazos + 1
									UPDATE bdidomi:dom_autorizaciones SET num_rechazos = num_rechazos + 1
									WHERE cuenta = cCuentaCargo AND rfc = cRFC_Ordenante;
									
									LET cEstatusOper = 'R';
								END IF;
							ELSE
								IF iNumRechazos >= iMaxRechPerm THEN
									--Comentado para no bloquear las domiciliaciones RMQ 06 894 Modificaciones en intentos de cobranza al proceso de DOMI
									--UPDATE bdidomi:dom_autorizaciones SET cve_estatus = '02',cve_causa = '01', num_rechazos = num_rechazos + 1
									UPDATE bdidomi:dom_autorizaciones SET num_rechazos = num_rechazos + 1
									WHERE cuenta = cCuentaCargo AND rfc = cRFC_Ordenante;
								ELSE
									UPDATE bdidomi:dom_autorizaciones SET num_rechazos = num_rechazos + 1
									WHERE cuenta = cCuentaCargo AND rfc = cRFC_Ordenante;								
								END IF;
								
								UPDATE bdidomi:dom_cte_detalle
								SET estatus = cEstatus, causa_rechazo = cCausaRechazo--, intentos = smIntento,
									,comision_cobrada = LPAD((mComision * 100):: INTEGER,16,'0') , iva_cobrado = LPAD(((mComision * mIva) * 100):: INTEGER,16,'0')
								WHERE nombre_arch = cNom_Arch_Entrada 
								AND consecutivo = LPAD (TRIM (iSecuencia::CHAR(6)),6,'0');
									
								LET cEstatusOper = 'R';
							END IF;
						ELSE
							IF iNumRechazos >= iMaxRechPerm THEN
								--Modificado para no bloquear las domiciliaciones RMQ 06 894 Modificaciones en intentos de cobranza al proceso de DOMI
								--UPDATE bdidomi:dom_autorizaciones SET cve_estatus = '02',cve_causa = '01', num_rechazos = num_rechazos + 1
								UPDATE bdidomi:dom_autorizaciones SET num_rechazos = num_rechazos + 1
								WHERE cuenta = cCuentaCargo AND rfc = cRFC_Ordenante;
							ELSE
								UPDATE bdidomi:dom_autorizaciones SET num_rechazos = num_rechazos + 1
								WHERE cuenta = cCuentaCargo AND rfc = cRFC_Ordenante;								
							END IF;
							
							UPDATE bdidomi:dom_cte_detalle
							SET estatus = cEstatus, causa_rechazo = cCausaRechazo--, intentos = smIntento,
								,comision_cobrada = LPAD((mComision * 100):: INTEGER,16,'0') , iva_cobrado = LPAD(((mComision * mIva) * 100):: INTEGER,16,'0')
							WHERE nombre_arch = cNom_Arch_Entrada 
							AND consecutivo = LPAD (TRIM (iSecuencia::CHAR(6)),6,'0');
							
							LET cEstatusOper = 'R';	
						END  IF;
					ELSE						
						UPDATE bdidomi:dom_cte_detalle 
						SET estatus = cEstatus, causa_rechazo = cCausaRechazo
							,comision_cobrada = LPAD((mComision * 100):: INTEGER,16,'0') , iva_cobrado = LPAD(((mComision * mIva) * 100):: INTEGER,16,'0')
						WHERE nombre_arch = cNom_Arch_Entrada 
						AND consecutivo = LPAD (TRIM (iSecuencia::CHAR(6)),6,'0');
												
						--OPERACION RECHAZADA
						LET cEstatusOper = 'R';
					END IF;
				ELSE
					LET cEstatusOper = 'A';
					
					UPDATE bdidomi:dom_cte_detalle 
					SET estatus = cEstatus, causa_rechazo = cCausaRechazo
						,comision_cobrada = LPAD((mComision * 100):: INTEGER,16,'0') , iva_cobrado = LPAD(((mComision * mIva) * 100):: INTEGER,16,'0')
					WHERE nombre_arch = cNom_Arch_Entrada 
					AND consecutivo = LPAD (TRIM (iSecuencia::CHAR(6)),6,'0');
					
					UPDATE bdidomi:dom_autorizaciones 
					SET num_rechazos = 0
					WHERE cuenta = cCuentaCargo 
						AND rfc = cRFC_Ordenante;
					
				END IF;
				
				IF cEstatusOper <> 'P'  THEN
					INSERT INTO dom_cte_detalle_paso (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
					cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
					ref_titular_serv, accion, reintentar_cuenta, estatus,
					causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
					fecha_insert, tipo_cta_abono)
					SELECT cNom_Arch_Salida,fecha_envio,tipo_registro, cSecuencia, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, --cFecha_trans,
					cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
					ref_titular_serv, accion, reintentar_cuenta, cEstatus, 
					cCausaRechazo, '', '', '', '', '', '', cUsuario, 
					CURRENT::DATE, ''
					FROM dom_cte_detalle 
					WHERE nombre_arch = cNom_Arch_Entrada 
					AND consecutivo = LPAD (TRIM (iSecuencia::CHAR(6)),6,'0');
				END IF;
				
			COMMIT WORK;
			LET bEntransaccion = 'f';
		END IF;
		RETURN cCodRet, cEstatusOper;
	END
END PROCEDURE 	
DOCUMENT
'AUTOR :INGRID PAMELA CÃÂZAREZ VILLEGAS',
'DESCRIPCION: Este Procediemiento graba los registros de respuesta resultados del procesamiento de un archivo de instrucciones de cargo de un proveedor',
'FECHA : Agosto 12 de 2016',
'BD: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_createtablascte(pFolio CHAR(20), pCliente CHAR(20), pUser CHAR(8), pFechaProxPago DATE)
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
DEFINE dFecha_inicio 				DATE;
DEFINE dFecha_fin    				DATE;
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

-- VALORES INICIALES.
LET iSqlerr    				=  0;
LET cCodret   				= '00000';
LET cCodret2				= '';
LET cMensajeRespuesta		= '';
LET cInTransaction      	= 'N';
LET cFechaPresentacionCce 	= '';
LET cFolioActivacion		= '';

LET cConsecutivo  		    = '000001';


--*********************************************************************************************
   -- SET DEBUG FILE TO "/tmp/createtablascte.out";
   -- TRACE ON;
--*********************************************************************************************

BEGIN
	--Manejo de excepciones (errores)
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 then
			if cInTransaction = 'S' then 
				ROLLBACK WORK;
			end if;
			LET cCodret = iSqlerr;
					
			--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
			INSERT INTO bdidomi:"informix".dom_errores(Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_createtablascte', TRIM(pFolio), pUser, CURRENT);

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
		VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_createtablascte', TRIM(pFolio) || '-' || TRIM(cMensajeRespuesta), pUser, CURRENT);
			
		RETURN cCodret;	
	END IF;

	-- Validamos si el cliente existe.
	IF NOT EXISTS(SELECT 1 FROM bdinteg:"informix".si_cliente WHERE numcte = pCliente) THEN
		LET cCodret = '99950'; --Cliente no existe.
		
		--Obtenemos los datos del error ocurrido.
		EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
				
		--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
		INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
		VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_createtablascte', TRIM(pFolio) || '-' || TRIM(cMensajeRespuesta), pUser, CURRENT);
			
		RETURN cCodret;
	END IF;

	-- Verificamos que se haya obtenido informacion adicional.
	IF EXISTS
		(SELECT 1 FROM bdidomi:"informix".dom_archivomanual a
		INNER JOIN bdidomi:"informix".dom_fecha_pago b
		ON a.folio_activacion = b.folio_activacion 
		WHERE a.folio_activacion = pFolio
		AND a.estatus = 'EP') 
	THEN
	
		SELECT nombre_arch, a.fecha_envio, a.tipo_registro, a.fecha_cargo, a.fecha_abono, a.tipo_cta_cargo, a.cve_banco_cargo, a.cuenta_cargo, a.rfc_cargo, a.nombre_cargo, a.cuenta_abono, a.imp_iva, a.ref_numerica, a.ref_leyenda, a.ref_servicio, a.ref_titular_serv, a.accion, a.reintentar_cuenta, a.estatus, a.causa_rechazo, a.nombre_arch_cce, a.tipo_registro_cce, a.numero_secuencia_cce, a.comision_cobrada, a.iva_cobrado, a.tipo_cta_abono, b.fecha_pago, b.fecha_prox_pago, b.fecha_inicio, b.fecha_fin, c.cve_domiciliar_tc, a.tipo_domi, c.cuenta, a.imp_operacion, a.folio_activacion
		INTO  cNombre_arch_manual, dFecha_envio, cTipoRegistro, cFecha_cargo, cFecha_abono, cTipoCtaCargo, cCveBancoCargo, cCtaCargo, cRfcCargo, cNombreCargo, cCtaAbono, cImpIva, cRefNumerica, cRefLeyenda, cRefServicio, cRefTitularServicio, cAccion, cReintentarCta, cEstatus, cCausaRechazo, cNombreArchivoCce, cTipoRegistroCce, cNumeroSecuenciaCce, cComisionCobrada, cIvaCobrado, cTipoCtaAbono, dFecha_pago, dFecha_prox_pago, dFecha_inicio, dFecha_fin, cTipoPago, cTipoDomi, cNumeroCredito, cImpOperacion, cFolioActivacion
		FROM bdidomi:"informix".dom_archivomanual a 
		INNER JOIN bdidomi:"informix".dom_fecha_pago b ON a.folio_activacion = b.folio_activacion 
		INNER JOIN bdidomi:"informix".dom_autorizaciones c ON a.folio_activacion = c.folio_activacion
		WHERE a.folio_activacion = pFolio
		and a.estatus = 'EP';


		IF cTipoPago <> 'F' THEN
			EXECUTE PROCEDURE bdidomi:"informix".sp_domi_proximo_pago(cTipoPago, '001', TRIM(cNumeroCredito), pUser, TRIM(pFolio), cTipoDomi) INTO cCodRet3, cMonto;
			
			
			LET cImpOperacion = LPAD(TRIM((cMonto*100)::INTEGER::CHAR(15)),15,'0');
		END IF;
		
		IF NOT EXISTS
			(SELECT 1 FROM bdidomi:"informix".dom_cte_archivos 
			 WHERE nombre_arch = cNombre_arch_manual 
			 AND fecha_envio = dFecha_prox_pago) 
		THEN 
			BEGIN WORK;
				LET cInTransaction = 'S';
				
				IF EXISTS (select consecutivo from bdidomi:"informix".dom_cte_detalle 
							where fecha_envio = dFecha_prox_pago and nombre_arch = cNombre_arch_manual) THEN
					--Obtenemos el valor del ultimo consecutivo de nombre de archivo y lo incrementamos en 1.
					SELECT LPAD(TO_CHAR(MAX(consecutivo::INTEGER)+1),6,'0')
					INTO cConsecutivo 
					FROM bdidomi:"informix".dom_cte_detalle 
					WHERE fecha_envio = dFecha_prox_pago and nombre_arch = cNombre_arch_manual;

				END IF;
				

				-- insertar tablas cte
				INSERT INTO bdidomi:"informix".dom_cte_archivos(nombre_arch,fecha_envio,num_cte,fecha_carga,cve_status,user_insert,fecha_insert)
				VALUES(cNombre_arch_manual,dFecha_prox_pago,LPAD(TRIM(pCliente),20,'0'),to_date(cFecha_cargo,'%Y%m%d'),'01',pUser, today);
			
				INSERT INTO bdidomi:"informix".dom_cte_encabezado(nombre_arch,fecha_envio,tipo_registro,num_cte,cuenta_abono,
				num_operaciones,fecha_inicial,fecha_final,user_insert,fecha_insert)
				VALUES(cNombre_arch_manual,dFecha_prox_pago,'E',LPAD(TRIM(pCliente),20,'0'), LPAD('',20,'0'),LPAD('1',8,'0'),to_char(dFecha_inicio,'%Y%m%d'), to_char(dFecha_fin,'%Y%m%d'),pUser,today);
				
				INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch, fecha_envio, tipo_registro, consecutivo, fecha_cargo,
				fecha_abono, tipo_cta_cargo, cve_banco_cargo, cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion,
				imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, accion, reintentar_cuenta, estatus, causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert, fecha_insert, tipo_cta_abono, folio_suc)
				VALUES(cNombre_arch_manual, dFecha_prox_pago, cTipoRegistro, cConsecutivo, cFecha_cargo, cFecha_abono, cTipoCtaCargo, cCveBancoCargo, cCtaCargo, cRfcCargo, cNombreCargo, cCtaAbono, cImpOperacion, cImpIva, cRefNumerica, cRefLeyenda, cRefServicio, cRefTitularServicio, cAccion, cReintentarCta, cEstatus, cCausaRechazo, cNombreArchivoCce, cFechaPresentacionCce, cTipoRegistroCce, cNumeroSecuenciaCce, cComisionCobrada, cIvaCobrado,
				pUser, today, cTipoCtaAbono, cFolioActivacion);
					
				INSERT INTO bdidomi:"informix".dom_cte_sumario(nombre_arch,fecha_envio,tipo_registro,num_operaciones,
				imp_operaciones,num_oper_pend,imp_oper_pend,num_oper_apli,imp_oper_apli,num_oper_rech,imp_oper_rech,user_insert,
				fecha_insert)
				VALUES(cNombre_arch_manual,dFecha_prox_pago,'S', LPAD('1',8,'0'), LPAD(TRIM(cImpOperacion),18,'0'),LPAD('',8,'0'),LPAD('',18,'0'), LPAD('',8,'0'), LPAD('',18,'0'),LPAD('',8,'0'),LPAD('',18,'0'), pUser, today);
				

		   	COMMIT WORK;
		   
			LET cInTransaction = 'N';
		
		--Verificar que no exista registro con misma ctaCargo, ctaAbono y fecha de proximo pago.
		ELIF NOT EXISTS
			(SELECT 1 FROM bdidomi:"informix".dom_cte_detalle 
			 where cuenta_cargo = cCtaCargo 
			 AND cuenta_abono = cCtaAbono 
			 AND fecha_envio = dFecha_prox_pago) 
		THEN 

			BEGIN WORK;
				LET cInTransaction = 'S';
				UPDATE bdidomi:"informix".dom_cte_encabezado 
				SET num_operaciones = LPAD(TO_CHAR(num_operaciones::INTEGER + 1),8,'0') 
				WHERE nombre_arch = cNombre_arch_manual;	
				
				--Obtenemos el valor del ultimo consecutivo de nombre de archivo y lo incrementamos en 1.
				SELECT LPAD(TO_CHAR(MAX(consecutivo::INTEGER)+1),6,'0')
				INTO cConsecutivo 
				FROM bdidomi:"informix".dom_cte_detalle 
				WHERE nombre_arch = cNombre_arch_manual;
			
				INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch, fecha_envio, tipo_registro, consecutivo, fecha_cargo,
				fecha_abono, tipo_cta_cargo, cve_banco_cargo, cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion,
				imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, accion, reintentar_cuenta, estatus, causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert, fecha_insert, tipo_cta_abono, folio_suc)
				VALUES(cNombre_arch_manual, dFecha_prox_pago, cTipoRegistro, cConsecutivo, cFecha_cargo, cFecha_abono, cTipoCtaCargo, cCveBancoCargo, cCtaCargo, cRfcCargo, cNombreCargo, cCtaAbono, cImpOperacion, cImpIva, cRefNumerica, cRefLeyenda, cRefServicio, cRefTitularServicio, cAccion, cReintentarCta, cEstatus, cCausaRechazo, cNombreArchivoCce, cFechaPresentacionCce, cTipoRegistroCce, cNumeroSecuenciaCce, cComisionCobrada, cIvaCobrado, pUser, today, cTipoCtaAbono, cFolioActivacion);
				
				UPDATE bdidomi:"informix".dom_cte_sumario 
				SET num_operaciones = LPAD(TO_CHAR(num_operaciones::INTEGER + 1),8,'0'), imp_operaciones = LPAD(TO_CHAR(imp_operaciones::INTEGER + cImpOperacion::INTEGER),18,'0')
				WHERE nombre_arch = cNombre_arch_manual;
				
					
			COMMIT WORK;
		
			LET cInTransaction = 'N';

		END IF;
	
	ELSE
		LET cCodret = '99957'; --No se obtuvo informacion adicional.
		--Obtenemos los datos del error ocurrido.
		EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
				
		--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
		INSERT INTO bdidomi:"informix".dom_errores(Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
		VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_createtablascte', TRIM(pFolio) || '-' || TRIM(cMensajeRespuesta), pUser, CURRENT);
				
	END IF;

END;
RETURN cCodret;
END PROCEDURE;