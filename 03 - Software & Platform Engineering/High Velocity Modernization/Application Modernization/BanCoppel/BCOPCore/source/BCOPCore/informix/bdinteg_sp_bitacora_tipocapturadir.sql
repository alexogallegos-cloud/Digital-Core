CREATE PROCEDURE "informix".sp_bitacora_tipocapturadir(pIdentificador CHAR, pNumCte CHAR(20), pSucursal CHAR(4), pEjecutivo CHAR(9))

	RETURNING CHAR(5);

	DEFINE pFecha_insert  DATETIME YEAR TO FRACTION;
	DEFINE cCodret		  CHAR(5);
	DEFINE sql_err 		  INTEGER;
	
/*****************************************
 CREADO POR: JOSÃ DE JESÃS INZUNZA MURO.
 FECHA: 22/04/2022.
 *****************************************/

	--ASIGANACION DE VARIABLES
	LET pFecha_insert  = CURRENT;
	LET sql_err 	   = 0;
	LET cCodret        = '00000';
	
BEGIN
	
	ON EXCEPTION SET sql_err

		RETURN sql_err;

    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;
	
	--SET DEBUG FILE TO "/home/sysifx/JesusI/Domicilio_localizacion/sp_bitacora_tipocapturadir.out";
    --TRACE ON;
	
	INSERT INTO "informix".si_bitacora_capdireccion(identificador, numcte, sucursal, ejecutivo, fecha_insert) VALUES (pIdentificador, pNumCte, pSucursal, pEjecutivo, pFecha_insert);
	LET cCodret = '00000';
	
	RETURN cCodret;
	
END;
END PROCEDURE
DOCUMENT
'CREADO: 90233836 - JosÃ© de JesÃºs Inzunza Muro.',
'Folio: 850',
'RQM: RQM 09 531-2-Adendum Domicilio de localizaciÃ³n de Cliente ',
'DescripcÃ­on: Se crea procedimiento almacenado para insertar registro en la tabla si_bitacora_capdireccion.',
'Fecha: 2022/04/22',
'Solicito: Abraham Narvaez',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_inser_alerta_exlimblo(pEmpresa Char(3),pSucursal Char(4), pEjecutivo Char(8), pMovimiento Char(1), pMonto_exce DECIMAL(19,2), pHora_alerta DATETIME YEAR TO SECOND, pHora_reemb DATETIME YEAR TO SECOND, pImport_reemb DECIMAL(19,2), pBloqueo Char(1))

--DATOS A REGRESAR---												 
RETURNING CHAR(6) AS vCodret;
	  
--DECLARACIONES.
DEFINE iSqlErr         	 INTEGER;
DEFINE vCodret           CHAR(5);
DEFINE iConsecutivo      INTEGER;
DEFINE vFechaHoy         DATE;

---INICIALIZACIONES
LET iSqlErr          = 0;
LET vCodret          = "00001";
LET iConsecutivo     = 0;


BEGIN
    ON EXCEPTION SET iSqlErr	
		IF 	iSqlErr <> 0 THEN
			RETURN iSqlErr;
		END IF;
	END EXCEPTION;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO  "/home/sysifx/JoseLuis/Folio376/sp_inser_alerta_exlimblo.out";
	--TRACE ON;
	
	--- Verifica recepcion correcta de datos
	IF pMovimiento = '1' THEN 
		IF pEmpresa = '' or pSucursal = '' or pEjecutivo = '' or  pMonto_exce = '' or NVL(pHora_alerta, '' )= '' or pImport_reemb = '' or pBloqueo = '' THEN 
			LET vCodret = '00002';
		ELSE 
			SELECT fecha_hoy 
			INTO   vFechaHoy
			FROM   "informix".si_fechas;
			
			SELECT NVL(MAX(num_alerta::integer),0)
			INTO iConsecutivo
			from "informix".si_fuera_rango where ejecutivo = pEjecutivo
			AND date(hora_alerta) = vFechaHoy; 
			
			IF iConsecutivo IS NULL THEN
				LET iConsecutivo = 1;
			ELSE
				LET iConsecutivo = iConsecutivo + 1; 
			END IF;
			
			INSERT INTO "informix".si_fuera_rango (empresa, sucursal, ejecutivo, num_alerta, movimiento, monto_exce, hora_alerta, hora_reemb, import_reemb, bloqueo)
			VALUES (pEmpresa, pSucursal, pEjecutivo, iConsecutivo::char(3), pMovimiento, pMonto_exce, pHora_alerta, '', '', pBloqueo);

			LET vCodret = '00000';
		END IF;

	ELIF pMovimiento = '2' THEN
		IF pEmpresa = '' or pSucursal = '' or pEjecutivo = '' or  pMonto_exce = '' or NVL(pHora_reemb, '') = '' or pImport_reemb = '' or pBloqueo = '' THEN 
			LET vCodret = '00002';
		ELSE 
			INSERT INTO "informix".si_fuera_rango (empresa, sucursal, ejecutivo, num_alerta, movimiento, monto_exce, hora_alerta, hora_reemb, import_reemb, bloqueo)
		    VALUES (pEmpresa, pSucursal, pEjecutivo, '', pMovimiento, '', '', pHora_reemb, pImport_reemb, '0');
			
			LET vCodret = '00000';
		END IF;
	ELSE
		LET vCodret = '00001';
	END IF;
	
		RETURN vCodret;
END;
END PROCEDURE
DOCUMENT
'Autor: 97839523 - Jose Luis Garcia',
'Folio: 376.1-Asignación de Nuevos Límites de Efectivo en Ventanilla',
'Fecha: 02-03-2018',
'Modificación:  Se crea procedimiento almacenado SP_INSER_ALERTA_EXLIMBLO para insertar las alertas y bloeques en la tabla si_fuera_rango.',
'Solicita: ABRAHAM NERVAEZ', 
'Base de datos: BDINTEG';

CREATE PROCEDURE "informix".sp_validacion_reporte(pNumReporte CHAR(4),
												  pEmpresa CHAR(3),
												  pSucursal CHAR(4), 
												  pFecha DATE, 	   
												  pUsuario CHAR(10), 
												  pcTipo CHAR(1), 
												  pOpcion CHAR(1) 
												  )
RETURNING
	CHAR(5) 	AS codRet,
	CHAR(50) 	AS rMensaje;

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_validacion_reporte"
Folio.........: 778 - Fin de dia, sp generico.
Autor.........: 90127902 - Epigmenio Martinez Pedraza
Fecha.........: 11/03/2022
Solicita......: 
BD............: bdinteg
*/

-- 
-- ***************************************************************************
	-- DEFINICION DE VARIABLES.
-- ***************************************************************************
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cMensaje VARCHAR(50);
	DEFINE cNumcteTmp VARCHAR(20);
	DEFINE dtFechaHoy DATE;
	DEFINE rsQuery VARCHAR(50);
	DEFINE cNumcte VARCHAR(20);

-- INICIALIZACION DE VARIABLE.
	LET cCodRet 			= '00004';
	LET cMensaje 			= 'Ocurrio un error.';
	LET iSqlErr				= 0;
	LET rsQuery				= '';
	LET cNumcte 			= '';
	LET cNumcteTmp 			= '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF(iSqlErr != 0) THEN
			LET cCodRet = iSqlErr;
			LET cMensaje = 'Ocurrio un error.';
			RETURN cCodRet, cMensaje WITH RESUME;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
			
	IF ( NVL(pNumReporte, '') != '' ) THEN
		IF (pNumReporte = '756') THEN --REPORTE SPEI                                                     
			--pSucursal = sucursal, pFecha = dtfechacaptura
			IF (NVL(pSucursal, '') <> '' OR NVL(pFecha, '')<>'') THEN
				SELECT LIMIT 1 pago.vchrclaverastreo
				INTO rsQuery
				  FROM bdispei: tblpago pago,
						   bdispei: tbldetranpago det
				 WHERE pago.dtfechacaptura = pFecha
				   AND pago.chrsentidopago = 'E'
				   AND pago.intcvetipopago = 1
				   AND pago.vchrclaverastreo = det.clave_rastreo
				   AND det.transacc = "0274"        
				   AND det.sucursal = pSucursal                
				   AND pago.chrestatusenvio IN ('L','D','C');
			ELSE
				LET cCodRet = '00001';
				LET cMensaje = 'Rep:756, los parametros no pueder ser vacios';
			END IF;
			
		ELIF (pNumReporte = "802") THEN --VALIDAR EL B23  			
				--PARAMETROS: pOpcion CHAR(1), pNumSucursal CHAR(4), pEmpresa CHAR(3),pEjecutivo CHAR(8)
				--opcionales: pUsuario
			IF(NVL(pSucursal, '') <> '' AND NVL(pEmpresa, '') <> '') THEN
				SELECT fecha_hoy INTO dtFechaHoy FROM bdinteg: "informix".si_fechas WHERE empresa = pEmpresa;
				
				SELECT LIMIT 1 num_sucursal_retencion INTO rsQuery FROM bdisuc:"informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pSucursal	
																		AND empresa_retiene = pEmpresa 
																		AND fecha_insert = dtFechaHoy;
																				
				-- IF pUsuario = '' AND pOpcion = '1' THEN
					-- SELECT LIMIT 1 FROM "informix".ss_recibo_bym_falsos WHERE num_sucursal_retencion = pSucursal
																				-- AND empresa_retiene = pEmpresa 
																				-- AND fecha_insert = dtFechaHoy
				
				-- ELIF pUsuario <> ''  AND pOpcion = '1' THEN
					-- SELECT LIMIT 1 FROM "informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pSucursal
																				-- AND empresa_retiene = pEmpresa 
																				-- AND fecha_insert = dtFechaHoy 
																				-- AND ejecutivo_insert = pUsuario;
				-- ELIF pOpcion = '2' THEN
					-- IF pUsuario = '' THEN
						-- SELECT LIMIT 1 FROM "informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pSucursal	
																				-- AND empresa_retiene = pEmpresa 
																				-- AND fecha_insert = dtFechaHoy;
					-- ELIF pUsuario <> '' THEN
						-- SELECT LIMIT 1 FROM "informix".ss_recibo_bym_falsos WHERE num_sucursal_retencion = pSucursal 
																			   -- AND empresa_retiene = pEmpresa 
																			   -- AND fecha_insert = dtFechaHoy
																			   -- AND ejecutivo_insert = pUsuario;
					-- END IF;	
					
				--END IF;
			ELSE
				LET cCodRet = '00001';
				LET cMensaje = 'Rep:802, los parametros no pueder ser vacios';
			END IF;
			
		ELIF (pNumReporte = "763") THEN  --Validar el A38.- REPORTE OPERACIONES TEF
			
				--PARAMETROS: pSucursal CHAR (4), pFechaConsulta DATE
				--opcionales: 
			IF(NVL(pSucursal, '') <> '' AND NVL(pFecha, '') <> '') THEN
				SELECT limit 1 sucursal	
				INTO rsQuery 
				FROM bditef:"informix".tef_operaciones
				WHERE sucursal = pSucursal
					AND cve_status <> '04'
					AND fecha_trans  = pFecha;
			ELSE
				LET cCodRet = '00001';
				LET cMensaje = 'Rep:763, los parametros no pueder ser vacios';
			END IF;
		ELIF (pNumReporte = "751") THEN  --Validar el PS1
			--PARAMETROS: (cSucursal CHAR(4))
			--opcionales: 
			IF (NVL(pSucursal, '')<> '' AND LENGTH(pSucursal) = 4) THEN						
				--Obtension de la fecha actual configurada.
				SELECT fecha_hoy INTO dtFechaHoy FROM bdisac:"informix".sac_fechas;

				SELECT LIMIT 1 id_sucursal
				INTO rsQuery
				FROM bdisac:"informix".sac_movimientos
				WHERE fecha_pago = dtFechaHoy
				AND id_sucursal = pSucursal;
			ELSE
				LET cCodRet = "00001";
				LET cMensaje = 'Rep:751, los parametros no pueder ser vacios';
			
			END IF;
			
		ELIF (pNumReporte = "761") THEN --Validar el TC1.- PAGO TDC OTROS BANCOS
			--PARAMETROS: (pdFecha DATE, pcSucursal CHAR(4),pcTipo CHAR(1))
			--opcionales: 
			--Se valida el tipo de busqueda
			IF (NVL(pcTipo, '')<> '' AND NVL(pFecha, '')<> '' AND NVL(pSucursal, '')<> '' ) THEN
				IF pcTipo = 1 THEN
					SELECT LIMIT 1 sucursal
					INTO rsQuery
					FROM bdicheq:"informix".sc_movdia
					WHERE empresa = '001' AND transacc in('1193' ,'1194') --ARM_NEORIS CAMBIO DE AND transacc = '1193' AND transacc = '1194' POR transacc in('1193' ,'1194')
					AND fech_alt = pFecha
					AND sucursal = pSucursal;
				ELIF pcTipo = 2 THEN
					--EN ESTA SECCION ES PARA LA OBTENCION DE MOVIMIENTOS DEL HISTORICO
					--DE NO SER NECESARIO EL PARAMETRO pcTipo QUEDARIA ELIMINADO U OPCIONAL.
					LET cCodRet				= '00000';
				END IF;
			ELSE
				LET cCodRet = "00001";
				LET cMensaje = 'Rep:761, los parametros no pueder ser vacios';
			END IF;
				
		ELIF (TRIM(pNumReporte) = "107") THEN -- TRIM(pTipoRep)    Validar el RE1.-REVISION DE EXPEDIENTES
				--PARAMETROS: (pdFecha DATE, pcSucursal CHAR(4),pcTipo CHAR(1),piRegistro INTEGER)
				--opcionales:
				-- "informix".sp_revision_expediente_cte_reporte(pEmpresa, pSucursal, pUsuario, '', '', pRegistros)
			SELECT LIMIT 1 scte.numcte
			INTO cNumcte
			FROM bdinteg:"informix".si_cliente scte
				INNER JOIN bdinteg:"informix".si_reporte_expediente srptexp
					ON (scte.numcte = srptexp.numcte)
			WHERE scte.empresa = pEmpresa
			AND srptexp.empresa = pEmpresa
			AND TRIM(scte.numcte) != ''
			AND TRIM(scte.tipo_cliente) = '1'
			AND TRIM(scte.sucursal)  = TRIM(pSucursal)
			AND scte.fecha_insert = pFecha;
			
			IF DBINFO('sqlca.sqlerrd2') > 0 THEN
				LET cCodRet = '00000';
				LET cMensaje = 'Existen movimientos.';
			ELSE
				SELECT LIMIT 1 scte.numcte
				INTO cNumcte
				FROM bdicheq: "informix".sc_maechq mae
				INNER JOIN bdicheq: "informix".sc_maenoc noc
					ON (noc.cuenta = mae.cuenta)
				INNER JOIN bdinteg: "informix".si_cliente scte
					ON (scte.empresa = pEmpresa AND scte.numcte = mae.num_cte)
				INNER JOIN bdinteg: "informix".si_reporte_expediente srptexp
					ON (srptexp.numcte = scte.numcte AND srptexp.empresa = pEmpresa)
				WHERE  mae.status_cta = '1'
				AND noc.fecha_alta = pFecha
				AND mae.empresa = pEmpresa
				AND mae.sucursal = pSucursal
				AND scte.fecha_insert < pFecha
				AND mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100');
				
				IF DBINFO('sqlca.sqlerrd2') > 0 THEN
					LET cCodRet = '00000';
					LET cMensaje = 'Existen movimientos.';
				ELSE
					FOREACH WITH HOLD
						SELECT scte.numcte
						INTO cNumcte
						FROM bdisolic:"informix".ss_solicitudes sol
						INNER JOIN bdinteg:"informix".si_cliente scte
							ON (scte.empresa = pEmpresa	AND scte.numcte = sol.numcte)
						INNER JOIN bdinteg: "informix".si_reporte_expediente srptexp
							ON (srptexp.numcte = scte.numcte)
						WHERE scte.fecha_insert < sol.fecha_insert
						AND srptexp.empresa = pEmpresa
						AND sol.empresa = pEmpresa
						AND sol.sucursal = pSucursal					
						AND sol.fecha_insert = pFecha					
						AND sol.status_solicitud NOT IN ('PC','AN')
						
						LET cNumcteTmp = '';
						
						SELECT LIMIT 1 mae.num_cte
							INTO cNumcteTmp
						FROM bdicheq:sc_maechq mae
						INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta
						and noc.fecha_alta = pFecha)
						WHERE  mae.status_cta    = '1'
						AND mae.empresa = pEmpresa
						AND mae.num_cte = cNumcte
						AND mae.sucursal = pSucursal
						AND mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100');
							
						IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
							LET cCodRet = '00000';
							LET cMensaje = 'Existen movimientos.';
							EXIT FOREACH;
						END IF;
					END FOREACH;
					
					IF cCodRet != '00000' THEN
						FOREACH WITH HOLD
							SELECT scte.numcte
								INTO cNumcte
								FROM bdisolic:"informix".ss_solicitudes sssol
								INNER JOIN bdisolic:"informix".ss_autorizacion ssaut
									ON (ssaut.num_solicitud = sssol.num_solicitud
									AND ssaut.status_solicitud = sssol.status_solicitud)
								INNER JOIN bdinteg:"informix".si_cliente scte
									ON (scte.numcte = sssol.numcte)
								INNER JOIN bdinteg: "informix".si_reporte_expediente srptexp
									ON (srptexp.numcte = sssol.numcte)
								WHERE sssol.empresa = pEmpresa
								AND srptexp.empresa = pEmpresa
								AND ssaut.empresa = pEmpresa
								AND ssaut.fecha_insert = pFecha
								AND sssol.status_solicitud = 'AP'
								AND sssol.sucursal = pSucursal
								AND scte.fecha_insert < pFecha
								
								LET cNumcteTmp = '';
								
								SELECT LIMIT 1 mae.num_cte
										INTO cNumcteTmp
									FROM bdicheq:sc_maechq mae
									INNER JOIN bdicheq:sc_maenoc noc
										ON (noc.cuenta = mae.cuenta
											AND noc.fecha_alta = pFecha)
									WHERE  mae.status_cta = '1'
									AND mae.empresa = pEmpresa
									AND mae.num_cte = cNumcte
									AND mae.sucursal = pSucursal
									AND mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100');
								
								IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
									SELECT LIMIT 1 sol.numcte
											INTO cNumcteTmp
										FROM bdisolic:"informix".ss_solicitudes sol
										WHERE sol.empresa = pEmpresa
										AND sol.numcte = cNumcte
										AND sol.sucursal = pSucursal
										AND sol.fecha_insert = pFecha
										AND sol.status_solicitud NOT IN ('PC','AN');
										
										IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
											LET cCodRet = '00000';
											LET cMensaje = 'Existen movimientos.';
											EXIT FOREACH;
										END IF;
								END IF;
						END FOREACH;
						
						IF cCodRet != '00000' THEN
							FOREACH WITH HOLD
								SELECT cte5.numcte
									INTO cNumcte
								FROM bdinvers: "informix".sv_maeinv invers
								INNER JOIN bdinteg: "informix".si_cliente cte5
									ON (cte5.empresa = invers.empresa
									AND cte5.numcte = invers.num_cte)
								INNER JOIN 	bdinteg: "informix".si_reporte_expediente srptexp
									ON (srptexp.empresa = cte5.empresa AND srptexp.numcte = cte5.numcte)
								WHERE cte5.empresa = pEmpresa
								AND cte5.fecha_insert < invers.fecha_alta
								AND invers.fecha_alta = pFecha
								AND invers.sucursal = pSucursal
								AND invers.secuencia = 1

								LET cNumcteTmp = '';
								
								SELECT LIMIT 1  Mae.num_cte
									INTO cNumcteTmp
								FROM bdicheq:sc_maechq Mae
								INNER JOIN bdicheq:sc_maenoc noc
								ON (noc.cuenta = mae.cuenta
								AND noc.fecha_alta = pFecha)
								WHERE  Mae.status_cta = '1'
								AND Mae.empresa = pEmpresa
								AND Mae.num_cte = cNumcte
								AND mae.sucursal = pSucursal
								AND Mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100');
								
								IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
									SELECT LIMIT 1 sol.numcte
										INTO cNumcteTmp 
									FROM bdisolic:"informix".ss_solicitudes   sol
									WHERE sol.empresa = pEmpresa
									AND sol.numcte = cNumcte
									AND sol.sucursal = pSucursal
									AND sol.fecha_insert = pFecha
									AND sol.status_solicitud NOT IN ('PC','AN');
									
									IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
										SELECT LIMIT 1 sol2.numcte
											INTO cNumcteTmp
										FROM bdisolic: "informix".ss_solicitudes sol2
										INNER JOIN bdisolic: "informix".ss_autorizacion aut
										ON (aut.empresa = sol2.empresa 
										AND aut.num_solicitud = sol2.num_solicitud
										AND aut.status_solicitud = sol2.status_solicitud)
										WHERE sol2.empresa = pEmpresa
										AND sol2.numcte = cNumcte
										AND sol2.status_solicitud = 'AP'
										AND sol2.sucursal = pSucursal
										AND aut.fecha_insert = pFecha;
										
										IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
											--LET rsQuery = cNumcte||cNumcteTmp;
											LET cCodRet = '00000';
											LET cMensaje = 'Existen movimientos.';
											EXIT FOREACH;
										END IF;									
									END IF;
								END IF;
							END FOREACH;
						END IF;
					END IF;
				END IF;
			END IF;
			
		ELSE
			LET cCodRet = '00004';
			LET cMensaje = 'No se encontro el reporte.';
		END IF;
		
		--ARM_NEORIS se evalua si el codigo ya viene exitoso. 
		IF (NVL(cCodRet, '') <> '00000') THEN
			IF (NVL(rsQuery, '') <> '') THEN
				LET cCodRet				= '00000';
				LET cMensaje 			= 'Existen movimientos.';
			ELSE
				LET cCodRet = '00003';
				LET cMensaje = 'No existen movimientos.';
			END IF;
		END IF;
		
	ELSE
		LET cCodRet = '00001';
		LET cMensaje = 'Uno de los parametros viene vacio';
		
	END IF; --validacion de pCveReporte en vacio
	RETURN cCodRet, cMensaje;						   
END;
END PROCEDURE
DOCUMENT
'Folio: 778',
'AUTOR : 90127902 - Epigmenio Martinez Pedraza',
'FECHA : 14/03/2022',
'SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_validacion_reporte',
'SOLICITA: ',
'BD: bdinteg',
'MODIFICADO: 18/05/2022 Alejandro Rodriguez Martinez(ARM_NEORIS)-Se agrego validacion de ccoderet antes de validar rsQuery y se cambio un where no procedente por un in ';

CREATE PROCEDURE "informix".sp_validacion_reporte_reing(pNumReporte CHAR(4),
												  pEmpresa CHAR(3),
												  pSucursal CHAR(4), 
												  pFecha DATE, 	   
												  pUsuario CHAR(10), 
												  pcTipo CHAR(1), 
												  pOpcion CHAR(1) 
												  )
RETURNING
	CHAR(5) 	AS codRet,
	CHAR(50) 	AS rMensaje;

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_validacion_reporte"
Folio.........: 778 - Fin de dia, sp generico.
Autor.........: 90127902 - Epigmenio Martinez Pedraza
Fecha.........: 11/03/2022
Solicita......: 
BD............: bdinteg
*/

-- 
-- ***************************************************************************
	-- DEFINICION DE VARIABLES.
-- ***************************************************************************
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cMensaje VARCHAR(50);
	DEFINE cNumcteTmp VARCHAR(20);
	DEFINE dtFechaHoy DATE;
	DEFINE rsQuery VARCHAR(50);
	DEFINE cNumcte VARCHAR(20);

-- INICIALIZACION DE VARIABLE.
	LET cCodRet 			= '00004';
	LET cMensaje 			= 'Ocurrio un error.';
	LET iSqlErr				= 0;
	LET rsQuery				= '';
	LET cNumcte 			= '';
	LET cNumcteTmp 			= '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF(iSqlErr != 0) THEN
			LET cCodRet = iSqlErr;
			LET cMensaje = 'Ocurrio un error.';
			RETURN cCodRet, cMensaje WITH RESUME;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
			
	IF ( NVL(pNumReporte, '') != '' ) THEN
		IF (pNumReporte = '756') THEN --REPORTE SPEI                                                     
			--pSucursal = sucursal, pFecha = dtfechacaptura
			IF (NVL(pSucursal, '') <> '' OR NVL(pFecha, '')<>'') THEN
				SELECT LIMIT 1 pago.vchrclaverastreo
				INTO rsQuery
				  FROM bdispei: tblpago pago,
						   bdispei: tbldetranpago det
				 WHERE pago.dtfechacaptura = pFecha
				   AND pago.chrsentidopago = 'E'
				   AND pago.intcvetipopago = 1
				   AND pago.vchrclaverastreo = det.clave_rastreo
				   AND det.transacc = "0274"        
				   AND det.sucursal = pSucursal                
				   AND pago.chrestatusenvio IN ('L','D','C');
			ELSE
				LET cCodRet = '00001';
				LET cMensaje = 'Rep:756, los parametros no pueder ser vacios';
			END IF;
			
		ELIF (pNumReporte = "810") THEN --VALIDAR EL B23 REING		
				--PARAMETROS: pOpcion CHAR(1), pNumSucursal CHAR(4), pEmpresa CHAR(3),pEjecutivo CHAR(8)
				--opcionales: pUsuario
			IF(NVL(pSucursal, '') <> '' AND NVL(pEmpresa, '') <> '') THEN
				SELECT fecha_hoy INTO dtFechaHoy FROM bdinteg: "informix".si_fechas WHERE empresa = pEmpresa;
				
				SELECT LIMIT 1 num_sucursal_retencion INTO rsQuery FROM bdisuc:"informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pSucursal	
																		AND empresa_retiene = pEmpresa 
																		AND fecha_insert = dtFechaHoy;
																				
				-- IF pUsuario = '' AND pOpcion = '1' THEN
					-- SELECT LIMIT 1 FROM "informix".ss_recibo_bym_falsos WHERE num_sucursal_retencion = pSucursal
																				-- AND empresa_retiene = pEmpresa 
																				-- AND fecha_insert = dtFechaHoy
				
				-- ELIF pUsuario <> ''  AND pOpcion = '1' THEN
					-- SELECT LIMIT 1 FROM "informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pSucursal
																				-- AND empresa_retiene = pEmpresa 
																				-- AND fecha_insert = dtFechaHoy 
																				-- AND ejecutivo_insert = pUsuario;
				-- ELIF pOpcion = '2' THEN
					-- IF pUsuario = '' THEN
						-- SELECT LIMIT 1 FROM "informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pSucursal	
																				-- AND empresa_retiene = pEmpresa 
																				-- AND fecha_insert = dtFechaHoy;
					-- ELIF pUsuario <> '' THEN
						-- SELECT LIMIT 1 FROM "informix".ss_recibo_bym_falsos WHERE num_sucursal_retencion = pSucursal 
																			   -- AND empresa_retiene = pEmpresa 
																			   -- AND fecha_insert = dtFechaHoy
																			   -- AND ejecutivo_insert = pUsuario;
					-- END IF;	
					
				--END IF;
			ELSE
				LET cCodRet = '00001';
				LET cMensaje = 'Rep:810, los parametros no pueder ser vacios';
			END IF;
			
		ELIF (pNumReporte = "763") THEN  --Validar el A38.- REPORTE OPERACIONES TEF
			
				--PARAMETROS: pSucursal CHAR (4), pFechaConsulta DATE
				--opcionales: 
			IF(NVL(pSucursal, '') <> '' AND NVL(pFecha, '') <> '') THEN
				SELECT limit 1 sucursal	
				INTO rsQuery 
				FROM bditef:"informix".tef_operaciones
				WHERE sucursal = pSucursal
					AND cve_status <> '04'
					AND fecha_trans  = pFecha;
			ELSE
				LET cCodRet = '00001';
				LET cMensaje = 'Rep:763, los parametros no pueder ser vacios';
			END IF;
		ELIF (pNumReporte = "751") THEN  --Validar el PS1
			--PARAMETROS: (cSucursal CHAR(4))
			--opcionales: 
			IF (NVL(pSucursal, '')<> '' AND LENGTH(pSucursal) = 4) THEN						
				--Obtension de la fecha actual configurada.
				SELECT fecha_hoy INTO dtFechaHoy FROM bdisac:"informix".sac_fechas;

				SELECT LIMIT 1 id_sucursal
				INTO rsQuery
				FROM bdisac:"informix".sac_movimientos
				WHERE fecha_pago = dtFechaHoy
				AND id_sucursal = pSucursal;
			ELSE
				LET cCodRet = "00001";
				LET cMensaje = 'Rep:751, los parametros no pueder ser vacios';
			
			END IF;
			
		ELIF (pNumReporte = "761") THEN --Validar el TC1.- PAGO TDC OTROS BANCOS
			--PARAMETROS: (pdFecha DATE, pcSucursal CHAR(4),pcTipo CHAR(1))
			--opcionales: 
			--Se valida el tipo de busqueda
			IF (NVL(pcTipo, '')<> '' AND NVL(pFecha, '')<> '' AND NVL(pSucursal, '')<> '' ) THEN
				IF pcTipo = 1 THEN
					SELECT LIMIT 1 sucursal
					INTO rsQuery
					FROM bdicheq:"informix".sc_movdia
					WHERE empresa = '001' AND transacc in('1193' ,'1194') --ARM_NEORIS CAMBIO DE AND transacc = '1193' AND transacc = '1194' POR transacc in('1193' ,'1194')
					AND fech_alt = pFecha
					AND sucursal = pSucursal;
				ELIF pcTipo = 2 THEN
					--EN ESTA SECCION ES PARA LA OBTENCION DE MOVIMIENTOS DEL HISTORICO
					--DE NO SER NECESARIO EL PARAMETRO pcTipo QUEDARIA ELIMINADO U OPCIONAL.
					LET cCodRet				= '00000';
				END IF;
			ELSE
				LET cCodRet = "00001";
				LET cMensaje = 'Rep:761, los parametros no pueder ser vacios';
			END IF;
				
		ELIF (TRIM(pNumReporte) = "107") THEN -- TRIM(pTipoRep)    Validar el RE1.-REVISION DE EXPEDIENTES
				--PARAMETROS: (pdFecha DATE, pcSucursal CHAR(4),pcTipo CHAR(1),piRegistro INTEGER)
				--opcionales:
				-- "informix".sp_revision_expediente_cte_reporte(pEmpresa, pSucursal, pUsuario, '', '', pRegistros)
			SELECT LIMIT 1 scte.numcte
			INTO cNumcte
			FROM bdinteg:"informix".si_cliente scte
				INNER JOIN bdinteg:"informix".si_reporte_expediente srptexp
					ON (scte.numcte = srptexp.numcte)
			WHERE scte.empresa = pEmpresa
			AND srptexp.empresa = pEmpresa
			AND TRIM(scte.numcte) != ''
			AND TRIM(scte.tipo_cliente) = '1'
			AND TRIM(scte.sucursal)  = TRIM(pSucursal)
			AND scte.fecha_insert = pFecha;
			
			IF DBINFO('sqlca.sqlerrd2') > 0 THEN
				LET cCodRet = '00000';
				LET cMensaje = 'Existen movimientos.';
			ELSE
				SELECT LIMIT 1 scte.numcte
				INTO cNumcte
				FROM bdicheq: "informix".sc_maechq mae
				INNER JOIN bdicheq: "informix".sc_maenoc noc
					ON (noc.cuenta = mae.cuenta)
				INNER JOIN bdinteg: "informix".si_cliente scte
					ON (scte.empresa = pEmpresa AND scte.numcte = mae.num_cte)
				INNER JOIN bdinteg: "informix".si_reporte_expediente srptexp
					ON (srptexp.numcte = scte.numcte AND srptexp.empresa = pEmpresa)
				WHERE  mae.status_cta = '1'
				AND noc.fecha_alta = pFecha
				AND mae.empresa = pEmpresa
				AND mae.sucursal = pSucursal
				AND scte.fecha_insert < pFecha
				AND mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100');
				
				IF DBINFO('sqlca.sqlerrd2') > 0 THEN
					LET cCodRet = '00000';
					LET cMensaje = 'Existen movimientos.';
				ELSE
					FOREACH WITH HOLD
						SELECT scte.numcte
						INTO cNumcte
						FROM bdisolic:"informix".ss_solicitudes sol
						INNER JOIN bdinteg:"informix".si_cliente scte
							ON (scte.empresa = pEmpresa	AND scte.numcte = sol.numcte)
						INNER JOIN bdinteg: "informix".si_reporte_expediente srptexp
							ON (srptexp.numcte = scte.numcte)
						WHERE scte.fecha_insert < sol.fecha_insert
						AND srptexp.empresa = pEmpresa
						AND sol.empresa = pEmpresa
						AND sol.sucursal = pSucursal					
						AND sol.fecha_insert = pFecha					
						AND sol.status_solicitud NOT IN ('PC','AN')
						
						LET cNumcteTmp = '';
						
						SELECT LIMIT 1 mae.num_cte
							INTO cNumcteTmp
						FROM bdicheq:sc_maechq mae
						INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta
						and noc.fecha_alta = pFecha)
						WHERE  mae.status_cta    = '1'
						AND mae.empresa = pEmpresa
						AND mae.num_cte = cNumcte
						AND mae.sucursal = pSucursal
						AND mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100');
							
						IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
							LET cCodRet = '00000';
							LET cMensaje = 'Existen movimientos.';
							EXIT FOREACH;
						END IF;
					END FOREACH;
					
					IF cCodRet != '00000' THEN
						FOREACH WITH HOLD
							SELECT scte.numcte
								INTO cNumcte
								FROM bdisolic:"informix".ss_solicitudes sssol
								INNER JOIN bdisolic:"informix".ss_autorizacion ssaut
									ON (ssaut.num_solicitud = sssol.num_solicitud
									AND ssaut.status_solicitud = sssol.status_solicitud)
								INNER JOIN bdinteg:"informix".si_cliente scte
									ON (scte.numcte = sssol.numcte)
								INNER JOIN bdinteg: "informix".si_reporte_expediente srptexp
									ON (srptexp.numcte = sssol.numcte)
								WHERE sssol.empresa = pEmpresa
								AND srptexp.empresa = pEmpresa
								AND ssaut.empresa = pEmpresa
								AND ssaut.fecha_insert = pFecha
								AND sssol.status_solicitud = 'AP'
								AND sssol.sucursal = pSucursal
								AND scte.fecha_insert < pFecha
								
								LET cNumcteTmp = '';
								
								SELECT LIMIT 1 mae.num_cte
										INTO cNumcteTmp
									FROM bdicheq:sc_maechq mae
									INNER JOIN bdicheq:sc_maenoc noc
										ON (noc.cuenta = mae.cuenta
											AND noc.fecha_alta = pFecha)
									WHERE  mae.status_cta = '1'
									AND mae.empresa = pEmpresa
									AND mae.num_cte = cNumcte
									AND mae.sucursal = pSucursal
									AND mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100');
								
								IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
									SELECT LIMIT 1 sol.numcte
											INTO cNumcteTmp
										FROM bdisolic:"informix".ss_solicitudes sol
										WHERE sol.empresa = pEmpresa
										AND sol.numcte = cNumcte
										AND sol.sucursal = pSucursal
										AND sol.fecha_insert = pFecha
										AND sol.status_solicitud NOT IN ('PC','AN');
										
										IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
											LET cCodRet = '00000';
											LET cMensaje = 'Existen movimientos.';
											EXIT FOREACH;
										END IF;
								END IF;
						END FOREACH;
						
						IF cCodRet != '00000' THEN
							FOREACH WITH HOLD
								SELECT cte5.numcte
									INTO cNumcte
								FROM bdinvers: "informix".sv_maeinv invers
								INNER JOIN bdinteg: "informix".si_cliente cte5
									ON (cte5.empresa = invers.empresa
									AND cte5.numcte = invers.num_cte)
								INNER JOIN 	bdinteg: "informix".si_reporte_expediente srptexp
									ON (srptexp.empresa = cte5.empresa AND srptexp.numcte = cte5.numcte)
								WHERE cte5.empresa = pEmpresa
								AND cte5.fecha_insert < invers.fecha_alta
								AND invers.fecha_alta = pFecha
								AND invers.sucursal = pSucursal
								AND invers.secuencia = 1

								LET cNumcteTmp = '';
								
								SELECT LIMIT 1  Mae.num_cte
									INTO cNumcteTmp
								FROM bdicheq:sc_maechq Mae
								INNER JOIN bdicheq:sc_maenoc noc
								ON (noc.cuenta = mae.cuenta
								AND noc.fecha_alta = pFecha)
								WHERE  Mae.status_cta = '1'
								AND Mae.empresa = pEmpresa
								AND Mae.num_cte = cNumcte
								AND mae.sucursal = pSucursal
								AND Mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100');
								
								IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
									SELECT LIMIT 1 sol.numcte
										INTO cNumcteTmp 
									FROM bdisolic:"informix".ss_solicitudes   sol
									WHERE sol.empresa = pEmpresa
									AND sol.numcte = cNumcte
									AND sol.sucursal = pSucursal
									AND sol.fecha_insert = pFecha
									AND sol.status_solicitud NOT IN ('PC','AN');
									
									IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
										SELECT LIMIT 1 sol2.numcte
											INTO cNumcteTmp
										FROM bdisolic: "informix".ss_solicitudes sol2
										INNER JOIN bdisolic: "informix".ss_autorizacion aut
										ON (aut.empresa = sol2.empresa 
										AND aut.num_solicitud = sol2.num_solicitud
										AND aut.status_solicitud = sol2.status_solicitud)
										WHERE sol2.empresa = pEmpresa
										AND sol2.numcte = cNumcte
										AND sol2.status_solicitud = 'AP'
										AND sol2.sucursal = pSucursal
										AND aut.fecha_insert = pFecha;
										
										IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
											--LET rsQuery = cNumcte||cNumcteTmp;
											LET cCodRet = '00000';
											LET cMensaje = 'Existen movimientos.';
											EXIT FOREACH;
										END IF;									
									END IF;
								END IF;
							END FOREACH;
						END IF;
					END IF;
				END IF;
			END IF;
			
		ELSE
			LET cCodRet = '00004';
			LET cMensaje = 'No se encontro el reporte.';
		END IF;
		
		--ARM_NEORIS se evalua si el codigo ya viene exitoso. 
		IF (NVL(cCodRet, '') <> '00000') THEN
			IF (NVL(rsQuery, '') <> '') THEN
				LET cCodRet				= '00000';
				LET cMensaje 			= 'Existen movimientos.';
			ELSE
				LET cCodRet = '00003';
				LET cMensaje = 'No existen movimientos.';
			END IF;
		END IF;
		
	ELSE
		LET cCodRet = '00001';
		LET cMensaje = 'Uno de los parametros viene vacio';
		
	END IF; --validacion de pCveReporte en vacio
	RETURN cCodRet, cMensaje;						   
END;
END PROCEDURE
DOCUMENT
'AUTOR : 97283169 - Jose Luis Sepulveda Perez',
'FECHA : 22/04/2022',
'se crea clon del procedimiento "sp_validacion_reporte',
'BD: bdinteg',
'MODIFICADO: 18/05/2022 Alejandro Rodriguez Martinez(ARM_NEORIS)-Se agrego validacion de ccoderet antes de validar rsQuery y se cambio un where no procedente por un in ';

CREATE PROCEDURE "informix".sp_sucursal_coordenadas(pClaveBusqueda VARCHAR(18))

RETURNING CHAR(5), CHAR(10), CHAR(11);
-----Variables-----
DEFINE cSeccion 	CHAR(4);
DEFINE cSucursal 	CHAR(5);

DEFINE codret		CHAR(5);
DEFINE cLatitud		CHAR(10);
DEFINE cLongitud	CHAR(11);

DEFINE vsqlerr     	INTEGER;
DEFINE error_info   CHAR(40);
DEFINE isam_err     SMALLINT;

LET codret = '00000';
LET cLatitud = '';
LET cLongitud = '';

LET vsqlerr = 0;
LET error_info = 'Iniciando ejecucion';
LET isam_err = 0;
	
BEGIN
	--LET  latitud = '-15.434821248';
	--LET  longitud = '95.2646215';
	ON EXCEPTION SET vsqlerr, isam_err, error_info
		IF vsqlerr <> 0 THEN
			LET codret = vsqlerr;
			LET isam_err = isam_err;
			LET error_info = error_info;
			
			RETURN codret, '', '';
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	LET cSeccion = LEFT(pClaveBusqueda, 4); --Toma los primeros 4 caracteres del lado izquierdo
	
	SELECT FIRST 1 sucursal INTO cSucursal FROM bdinteg:si_seccion_sucursal WHERE seccion = cSeccion;
	
	SELECT latitud, longitud INTO cLatitud, cLongitud FROM bdinteg:si_ptf WHERE id_ptf = cSucursal AND tipo='S';
	
	IF((cLatitud IS NULL OR cLatitud = '' OR cLatitud='Null') OR (cLongitud IS NULL OR cLongitud = '' OR cLongitud='Null')) THEN
		SELECT latitud, longitud INTO cLatitud, cLongitud FROM bdinteg:si_ptf WHERE id_ptf = '6700' AND tipo='S';
	END IF;
	

    RETURN codret, cLatitud, cLongitud;
	 
END;
END PROCEDURE;