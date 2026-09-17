CREATE PROCEDURE "informix".sp_generar_reporte_domi_pp_tdc_servicios(dFechaHoy DATE, pIdentificador CHAR(2), pTipo CHAR(2))
RETURNING CHAR(6), CHAR(115);

--DEFINICION DE VARIABLES
DEFINE cCodRet         	  CHAR(6);         --DSB::ANTONIO CEBREROS::01/12/2015 (cCodRet -- cCodRet)
DEFINE cMensCodRet     	  CHAR(115);
DEFINE iNomErr         	  INTEGER;
DEFINE iNanErr		   	  INTEGER;
DEFINE sEnTransaccion 	  SMALLINT;        --DSB::ANTONIO CEBREROS::01/12/2015 (sEnTransaccion -- sEnTransaccion)
DEFINE dFechaInicial      DATETIME YEAR TO FRACTION;
DEFINE dFechaFinal        DATETIME YEAR TO FRACTION;
DEFINE dFechaIni          DATE; 
DEFINE dFechaFin          DATE; 
DEFINE cComando           CHAR(300);
DEFINE cComercio          CHAR(60);
DEFINE cEstado1           CHAR(20);
DEFINE cNum_transacciones CHAR(18);
DEFINE dcMonto            DECIMAL(16,2);  --DSB::ANTONIO CEBREROS::01/12/2015 (dMonto -- dcMonto)

DEFINE dFecha             DATE;		  --DSB::ANTONIO CEBREROS::01/12/2015 (fFecha -- dFecha)
DEFINE cEstado2           CHAR(20);
DEFINE cNum_pagos         CHAR(10);
DEFINE dcMonto2           DECIMAL(16,2);  --DSB::ANTONIO CEBREROS::01/12/2015 (mMonto -- dcMonto2)

DEFINE dFecha2            DATE;
DEFINE cEstado3           CHAR(20);
DEFINE cNum_domi          CHAR(10);
DEFINE dcMonto3           DECIMAL(16,2);  --DSB::ANTONIO CEBREROS::01/12/2015 (mMonto2 -- dcMonto3)
DEFINE cRutaRepor         CHAR(100);
DEFINE cArchivo        	  CHAR(100);  
DEFINE cProceso			  CHAR(100);
DEFINE cEvento			  CHAR(100);
DEFINE cMensaje           CHAR(110);
DEFINE iTotal             INTEGER;
DEFINE iMaxC              INTEGER; 		  --DSB::ANTONIO CEBREROS::07/12/2015 (INT -- INTEGER)
DEFINE iMaxD              INTEGER; 		  --DSB::ANTONIO CEBREROS::07/12/2015 (INT -- INTEGER)
DEFINE cMes               CHAR(2);
DEFINE cAnio              CHAR(4);

--DSB::ANTONIO CEBREROS::01/12/2015
DEFINE dFechaIniSem		  DATE;	
DEFINE dFechaFinSem		  DATE;	
DEFINE cEstatusProceso    CHAR(1);
--DEFINE cComando			  CHAR (350);
DEFINE cNumCte 			  CHAR (20);
DEFINE cNumCta 			  CHAR (20);
DEFINE cImporte 		  CHAR (15);
DEFINE cEstado4 		  CHAR (20);
DEFINE dcPromMens4 		  DECIMAL (16,2);
DEFINE cFlag			  CHAR (1);
DEFINE cFechaIniSem		  CHAR (8);
DEFINE cFechaFinSem		  CHAR (8);
DEFINE cFechaIniPromSem   CHAR(6);
DEFINE cFechaFinPromSem   CHAR(6);
DEFINE cFecha			  CHAR(10);	
--DEFINE dFechaTabTemp	  DATE;
---

--ASIGNACION DE VARIABLES
LET cCodRet  = '000000'; --DSB::ANTONIO CEBREROS::01/12/2015 (variable inicializada en error, se cambia a cÃ?ÃÂ³digo de Ã?ÃÂ©xito si pasa por los caminos correctos en el sp).
LET cMensCodRet = 'REPORTE GENERADO CORRECTAMENTE';  --DSB::ANTONIO CEBREROS::01/12/2015 (inicializada con texto de error, se corrige (cambia) cuando pasa correctamente por los flujos debidos segÃ?ÃÂºn el reporte en que estÃ?ÃÂ©).
LET sEnTransaccion = 0;
LET cMes = '';
LET cAnio = '';
LET cRutaRepor  = ''; 
LET cArchivo = ''; 
LET cEvento = '';
LET cMensaje = '';
LET iTotal = 0;
LET iMaxC = 0;
LET iMaxD = 0;

--DSB::ANTONIO CEBREROS::01/12/2015
LET cComercio   = '';
LET dFechaIniSem = DATE (1);
LET dFechaFinSem = DATE (1);
LET cEstatusProceso = '';
LET cComando = '';
LET cNumCte 	  = '';
LET cNumCta 	  = '';
LET cImporte      = '';
LET cEstado4      = '';
LET dcPromMens4   = 0.00;
LET cFechaIniSem  = '';
LET cFechaFinSem  = '';
LET cFechaIniPromSem = '';
LET cFechaFinPromSem = '';
LET cProceso			= '';
--

--DSB::ANTONIO CEBREROS::07/12/2015 (SE INICIALIZAN VARIABLES PRODUCTIVAS)
LET iNanErr = 0;
LET iNomErr = 0;
LET dFechaInicial = DATE (1);
LET dFechaFinal   = DATE (1);
LET dFechaIni     = DATE (1);
LET dFechaFin     = DATE (1);
LET cComando              = ''; 
LET cComercio          = ''; 
LET cEstado1           = ''; 
LET cNum_transacciones = ''; 
LET dcMonto            = 0.00;
LET cComando              = '';
LET dFecha             = DATE(1);
LET cEstado2           = '';
LET cNum_pagos         = '';
LET dcMonto2           = 0.00;
LET cComando              = '';
LET dFecha2            = DATE (1);
LET cEstado3           = '';
LET cNum_domi          = '';
LET dcMonto3           = 0.00;
LET cFlag			   = '';
LET cFecha				= '';

--LET dFechaTabTemp	   = DATE (1);
---

--SET DEBUG FILE TO "/tmp/josea/reportesdomi/sp_generar_reporte_domi_pp_tdc_servicios.out";
--TRACE ON;

BEGIN

	--Manejo del error
	ON EXCEPTION SET iNomErr, iNanErr, cMensCodRet
		IF iNomErr <> 0 THEN
			LET cCodRet=iNomErr;
			
			IF sEnTransaccion = 1 THEN
				ROLLBACK;
			END IF;
			
			SELECT DBINFO('utc_to_datetime',sh_curtime)
			INTO dFechaFinal
			FROM sysmaster:"informix".sysshmvals;
			
			INSERT INTO "informix".si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
			VALUES (dFechaHoy - 1 UNITS DAY, cProceso, cEvento, cCodret, cMensCodRet);
			
			IF NVL(dFechaIni, '') = '' OR NVL(dFechaFin, '') = '' THEN
				LET dFechaIni = dFechaIniSem;
				LET dFechaFin = dFechaFinSem;				
			END IF;
			
			UPDATE "informix".si_controlproc_indicadores 
			SET maxfecha_cargada = dFechaFin , flagfinalizado = 'F', coderror = cCodRet, msgerror =  cMensCodRet, fecha_cargafin =  dFechaFinal
			WHERE id_proc = pIdentificador
			AND tipo = pTipo
			--AND nombre_proceso = cProceso
			AND fecha_procesoIni = dFechaIni
			AND fecha_procesoFin = dFechafin;
						
			RETURN cCodRet, cMensCodRet;
		END IF;				
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--DSB::01/12/2015
	--Validamos parÃ?ÃÂ¡metros obligatorios:	
	IF NVL(pIdentificador, '')  = '' OR NVL(pTipo, '') = '' THEN
		LET cCodRet  = '000001';
		LET cMensCodRet = TRIM(cMensCodRet)||'FALTAN PARAMETROS DE ENTRADA';		
	ELSE
		--GUARDA INFORMACIÃ??N INICIAL EN LA TABLA si_controlproc_indicadores			
		SELECT DBINFO('utc_to_datetime',sh_curtime)
		INTO dFechaInicial 
		FROM sysmaster:"informix".sysshmvals;
		
		LET cEvento = 'OBTENCION DE PARAMETROS';
		
		SELECT valor 
		INTO cRutaRepor 
		FROM "informix".si_param
		WHERE cod_param = '358';
		
		--OBTENEMOS EL NOMBRE DEL PROCESO Y EL ESTATUS DEL MISMO.
		SELECT TRIM(nombre_proceso), TRIM(estatus_proceso)
		INTO cProceso, cEstatusProceso
		FROM "informix".si_proc_indicadores 		
		WHERE identificador = pIdentificador
		--AND estatus_proceso = estatus_proceso
		AND tipo = pTipo;
		
		IF 	NVL(cProceso, '') <> '' AND NVL (cEstatusProceso, '') = 'A' THEN
		
			SELECT MAX(LENGTH(descripcion))
			INTO iMaxD
			FROM bdidomi:"informix".dom_status_pago;
					
			--Validamos el identificador para elegir el tipo de reporte a crear.
			IF pIdentificador = '1' THEN
			--Identificador 1:
				--OBTENCIÃ??N DE MES Y AÃ??O DE LOS REPORTES				
				LET dFechaFin = dFechaHoy - DAY(dFechaHoy);		       
				LET dFechaIni = dFechaFin - (DAY(dFechaFin) -1);	
				LET cMes      = LPAD(MONTH(dFechaFin), 2, 0);
				LET cAnio     = YEAR(dFechaFin);
			
				--LET cProceso = 'REPORTE DE DOMICILIACIONES TARJETA DE DEBITO';			
				SELECT valor 
				INTO   cArchivo
				FROM   "informix".si_param
				WHERE  cod_param = '355';
		
				LET cEvento = 'VALIDANDO GENERACION PREVIA DE REPORTE DE DOMICILIACIONES TARJETA DE DEBITO';
				
				SELECT LIMIT 1 flagfinalizado
				INTO cFlag
				FROM "informix".si_controlproc_indicadores 
				WHERE id_proc = pIdentificador 
					AND tipo = pTipo 
					--AND nombre_proceso = cProceso 
					AND fecha_procesoIni = dFechaIni 
					AND fecha_procesoFin = dFechaFin;
				
				IF NVL(cFlag, '') = '' THEN	
					LET cEvento = 'INSERTA REGISTRO INICIAL EN TABLA DE CONTROL DE PROCESOS';
					INSERT INTO "informix".si_controlproc_indicadores (fecha_procesoIni, fecha_procesoFin, tipo, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin, maxfecha_cargada, flagfinalizado, coderror, msgerror)
					VALUES (dFechaIni, dFechaFin, pTipo, pIdentificador, cProceso, dFechaInicial, NULL, NULL, 'F', NULL, NULL );
				END IF;
				
				IF NVL(cFlag, '') <> 'V' THEN	--GENERA REPORTE DE DOMICILIACIONES TARJETA DE DEBITO 				
					
					SELECT MAX(LENGTH(razon_social))
					INTO iMaxC
					FROM bdidomi:"informix".dom_cat_servicios;
										
					BEGIN WORK;
					LET sEnTransaccion = 1;
					
					LET cArchivo = REPLACE (cArchivo, 'AAAA', cAnio);
					LET cArchivo = REPLACE (cArchivo, 'MM', cMes);
						 
					--CUENTA NUMERO DE REGISTROS 
					LET cEvento = 'OBTIENE CANTIDAD DE REGISTROS DEL REPORTE DE DOMICILIACIONES TARJETA DE DEBITO';
					SELECT COUNT (a.razon_social)
						INTO iTotal 
						FROM bdidomi:"informix".dom_cat_servicios a, bdidomi:"informix".dom_cce_detalle b, bdidomi:"informix".dom_status_pago c  
						WHERE b.rfc_ord = a.rfc
						AND b.cve_estatus = c.cve_status
						AND b.cod_operacion = '30'
						AND b.banco_receptor = '137'
						AND b.tipo_cta_rec IN('03','10','40')
						--AND b.cve_estatus = '01'
						AND b.fecha_aplica BETWEEN YEAR(dFechaIni)||LPAD(MONTH(dFechaIni),2,0)||LPAD(DAY(dFechaIni),2,0) AND YEAR(dFechaFin)||LPAD(MONTH(dFechaFin),2,0)||LPAD(DAY(dFechaFin),2,0);
						 
						LET cEvento = 'GENERA ENCABEZADOS DE REPORTE DE DOMICILIACIONES TARJETA DE DEBITO';
						
						LET cComando =  'echo "' || RPAD('COMERCIO',iMaxC,' ') || '|' || RPAD('ESTADO',iMaxD,' ') || '|' || RPAD('NUMERO DE TRANSACCIONES',24, ' ') || '|' || 'MONTO' || '" >> ' || TRIM(cRutaRepor) || TRIM(cArchivo);
						SYSTEM cComando;
					
					IF iTotal = 0 THEN
						LET cMensaje = 'NO EXISTE INFORMACION PARA GENERAR REPORTE DE DOMICILIACIONES TARJETA DE DÃ??BITO';
						LET cComando =  'echo "' || ' ' || '" >> ' || TRIM(cRutaRepor) || TRIM(cArchivo);
						SYSTEM cComando;
						LET cComando =  'echo "' || ' ' || '" >> ' || TRIM(cRutaRepor) || TRIM(cArchivo);
						SYSTEM cComando;				
						LET cComando =  'echo "' || TRIM(cMensaje) || '" >> ' || TRIM(cRutaRepor) || TRIM(cArchivo);
						SYSTEM cComando;			
					ELSE
						LET cEvento = 'OBTENCION DE REGISTROS DEL REPORTE DE DOMICILIACIONES TARJETA DE DEBITO';
						LET cMensaje = 'REPORTE DE DOMICILIACIONES TARJETA DE DÃ??BITO GENERADO';
						--IMPRIME 
						--LET cComando =   'echo "' || 'ID COMERCIO'|| '|' || 'COMERCIO' || '|' || 'NUMERO DE TRANSACCIONES' || '|' || 'MONTO' || '" >> ' || TRIM(cRutaRepor) || TRIM(cArchivo);
						FOREACH	
							--SELECT TRIM(b.rfc_ord) AS id_comercio, a.razon_social AS comercio, COUNT(b.rfc_ord) AS num_transacciones, SUM(((b.importe::INTEGER)/100)::DECIMAL(16,2)) AS monto
							--INTO cId_comercio, cComercio, cNum_transacciones, dcMonto				
							---SELECT a.razon_social AS comercio, UPPER(c.descripcion) AS estado, COUNT(b.rfc_ord) AS num_transacciones, SUM(((b.importe::INTEGER)/100)::DECIMAL(16,2)) AS monto
							SELECT {+INDEX(bdidomi:dom_cce_detalle idx_dom_cce_detalle1)} a.razon_social AS comercio, UPPER(c.descripcion) AS estado, COUNT(b.rfc_ord) AS num_transacciones, SUM(((b.importe::INTEGER)/100)::DECIMAL(16,2)) AS monto
							INTO cComercio, cEstado1, cNum_transacciones, dcMonto
							FROM bdidomi:"informix".dom_cat_servicios a, bdidomi:"informix".dom_cce_detalle b, bdidomi:"informix".dom_status_pago c  
							WHERE b.rfc_ord = a.rfc
							AND b.cve_estatus = c.cve_status
							AND b.cod_operacion = '30'
							AND b.banco_receptor = '137'
							AND b.tipo_cta_rec IN('03','10','40')
							--AND b.cve_estatus = '01'
							AND b.fecha_aplica BETWEEN YEAR(dFechaIni)||LPAD(MONTH(dFechaIni),2,0)||LPAD(DAY(dFechaIni),2,0) AND YEAR(dFechaFin)||LPAD(MONTH(dFechaFin),2,0)||LPAD(DAY(dFechaFin),2,0)
							GROUP BY 1,2
							ORDER BY 1 
									 
							--IMPRIME
							--LET cComando =  'echo "' || RPAD(TRIM(cId_comercio),iMaxL,' ')|| '|' ||  RPAD(UPPER(TRIM(cComercio)),iMaxC,' ') || '|' || RPAD(TRIM(cNum_transacciones),18,' ') || '|' || dcMonto || '" >> ' || TRIM(cRutaRepor) || cArchivo;
							LET cComando =  'echo "' ||  RPAD(UPPER(TRIM(cComercio)),iMaxC,' ') || '|' || RPAD(TRIM(cEstado1),iMaxD,' ') || '|' || RPAD(TRIM(cNum_transacciones),24,' ') || '|' || dcMonto || '" >> ' || TRIM(cRutaRepor) || TRIM(cArchivo);
							SYSTEM cComando;				
						END FOREACH;
					END IF;	
					COMMIT;
					LET sEnTransaccion = 0;
				
					SELECT DBINFO('utc_to_datetime',sh_curtime)
					INTO dFechaFinal 
					FROM sysmaster:"informix".sysshmvals;
					
					LET cEvento = 'ACTUALIZACION FINAL DE REGISTRO EN TABLA DE CONTROL DE PROCESOS';	
					
					UPDATE "informix".si_controlproc_indicadores 
					SET maxfecha_cargada = dFechaFin , flagfinalizado = 'V', coderror = cCodRet, msgerror = cMensaje, fecha_cargafin =  dFechaFinal
					WHERE id_proc = pIdentificador
					AND tipo = pTipo
					--AND nombre_proceso = cProceso
					AND fecha_procesoIni = dFechaIni
					AND fecha_procesoFin = dFechafin;		
					
					LET cMensCodRet = 'EL PROCESO DE '||TRIM(cProceso)||' SE HA GENERADO CORRECTAMENTE';
					
				ELSE
					LET cMensCodRet = 'EL REPORTE YA FUE GENERADO ANTERIORMENTE.';
				END IF;

			ELIF pIdentificador = '2' THEN
			
				LET dFechaFin = dFechaHoy - DAY(dFechaHoy);		       
				LET dFechaIni = dFechaFin - (DAY(dFechaFin) -1);	
				LET cMes      = LPAD(MONTH(dFechaFin), 2, 0);
				LET cAnio     = YEAR(dFechaFin);
				
				--LET cProceso = 'REPORTE DE PAGOS PROGRAMADOS DE TDC BANCOPPEL';			
				SELECT valor 
				INTO cArchivo
				FROM "informix".si_param
				WHERE cod_param = '356';
				
				LET cEvento = 'INSERTA REGISTRO INICIAL EN TABLA DE CONTROL DE PROCESOS';
				
				SELECT LIMIT 1 flagfinalizado
				INTO  cFlag
				FROM  "informix".si_controlproc_indicadores 
				WHERE id_proc = pIdentificador AND tipo = pTipo AND nombre_proceso = cProceso AND fecha_procesoIni = dFechaIni 
				      AND fecha_procesoFin = dFechaFin;
				
				IF NVL(cFlag, '') = '' THEN	
					LET cEvento = 'INSERTA REGISTRO INICIAL EN TABLA DE CONTROL DE PROCESOS';
					INSERT INTO "informix".si_controlproc_indicadores (fecha_procesoIni, fecha_procesoFin, tipo, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin, maxfecha_cargada, flagfinalizado, coderror, msgerror)
					VALUES (dFechaIni, dFechaFin, pTipo, pIdentificador, cProceso, dFechaInicial, NULL, NULL, 'F', NULL, NULL );
				END IF;
				
				IF NVL(cFlag, '') <> 'V' THEN					
					BEGIN WORK;				
						LET sEnTransaccion = 1;		
						
						--REEMPLAZA LA FECHA EN EL NOMBRE DEL ARCHIVO
						LET cArchivo = REPLACE (cArchivo, 'AAAA', cAnio);
						LET cArchivo = REPLACE (cArchivo, 'MM', cMes);
					
						--CUENTA NUMERO DE REGISTROS
						LET cEvento = 'OBTIENE CANTIDAD DE REGISTROS DEL REPORTE DE PAGOS PROGRAMADOS DE TDC BANCOPPEL';
						SELECT COUNT (a.fecha_aplic) 
							INTO iTotal
							FROM bdiprog:"informix".pp_pagospend a, bdiprog:"informix".pp_pagoprog b, bdiprog:"informix".pp_estados c
							WHERE a.cve_pagoprog = b.cve_pagoprog
							AND a.estado = c.cve_estado
							--AND a.estado = '05'
							AND b.cve_pago = '05'
							AND a.fecha_aplic BETWEEN dFechaIni AND dFechaFin;
						
						LET cEvento = 'GENERA ENCABEZADOS DE REPORTE DE PAGOS PROGRAMADOS DE TDC BANCOPPEL';
						
						LET cComando =  'echo "' || RPAD('FECHA',12, ' ') || '|' || RPAD('ESTADO',iMaxD, ' ') || '|' || RPAD('NUMERO DE PAGOS',16,' ') || '|' || 'MONTO' || '" >> ' || TRIM(cRutaRepor) || TRIM(cArchivo);
						SYSTEM cComando;
					
						IF iTotal = 0 THEN 
							LET cMensaje = 'NO EXISTE INFORMACION PARA GENERAR REPORTE DE PAGOS PROGRAMADOS DE TDC BANCOPPEL';
							LET cComando =  'echo "' || ' ' || '" >> ' || TRIM(cRutaRepor) || TRIM(cArchivo);
							SYSTEM cComando;
							LET cComando =  'echo "' || ' ' || '" >> ' || TRIM(cRutaRepor) || TRIM(cArchivo);
							SYSTEM cComando;
							LET cComando =  'echo "' || TRIM(cMensaje) || '" >> ' || TRIM(cRutaRepor) || TRIM(cArchivo);
							SYSTEM cComando;			
						ELSE
							LET cEvento = 'OBTENCION DE REGISTROS DEL REPORTE DE PAGOS PROGRAMADOS DE TDC BANCOPPEL';	
							LET cMensaje = 'REPORTE DE PAGOS PROGRAMADOS DE TDC BANCOPPEL GENERADO';
							FOREACH                                                          				
								SELECT a.fecha_aplic AS fecha, UPPER(c.descripcion) AS estado, COUNT(a.cve_pagoprog) AS num_pagos, SUM(((b.importe::INTEGER)/100)::DECIMAL(16,2)) AS monto
								INTO dFecha, cEstado2, cNum_pagos, dcMonto2
								FROM bdiprog:"informix".pp_pagospend a, bdiprog:"informix".pp_pagoprog b, bdiprog:"informix".pp_estados c
								WHERE a.cve_pagoprog = b.cve_pagoprog
								AND a.estado = c.cve_estado
								--AND a.estado = '05'
								AND b.cve_pago = '05'
								AND a.fecha_aplic BETWEEN dFechaIni AND dFechaFin
								GROUP BY 1,2
								ORDER BY 1
									
								--IMPRIME
								LET cComando = 'echo "' || RPAD(dFecha,12, ' ') || '|' || RPAD(cEstado2,iMaxD, ' ') || '|' || RPAD(cNum_pagos,16,' ') || '|' || dcMonto2 || '" >> ' || TRIM(cRutaRepor) || TRIM(cArchivo);
								SYSTEM cComando;
							END FOREACH;
						END IF;
					COMMIT;
					LET sEnTransaccion = 0;
					
					SELECT DBINFO('utc_to_datetime',sh_curtime)
					INTO dFechaFinal
					FROM sysmaster:"informix".sysshmvals;
					
					LET cEvento = 'ACTUALIZACION FINAL DE REGISTRO EN TABLA DE CONTROL DE PROCESOS';
				
					UPDATE "informix".si_controlproc_indicadores 
					SET maxfecha_cargada = dFechaFin , flagfinalizado = 'V', coderror = cCodRet, msgerror =  cMensaje, fecha_cargafin =  dFechaFinal
					WHERE id_proc = pIdentificador
					AND tipo = pTipo
					--AND nombre_proceso = cProceso
					AND fecha_procesoIni = dFechaIni
					AND fecha_procesoFin = dFechafin;				

					LET cMensCodRet = 'EL PROCESO DE '||TRIM(cProceso)||' SE HA GENERADO CORRECTAMENTE';
					
				ELSE
					LET cMensCodRet = 'EL REPORTE FUE GENERADO ANTERIORMENTE';
				END IF;
				
			ELIF pIdentificador = '3' THEN		
				LET dFechaFin = dFechaHoy - DAY(dFechaHoy);		       
				LET dFechaIni = dFechaFin - (DAY(dFechaFin) -1);	
				LET cMes      = LPAD(MONTH(dFechaFin), 2, 0);
				LET cAnio     = YEAR(dFechaFin);
			
				--LET cProceso = 'REPORTE DE PAGO DE TARJETA DE CREDITO VISA DOMICILIADOS A OTROS BANCOS';
				SELECT valor 
				INTO cArchivo
				FROM "informix".si_param
				WHERE cod_param = '357';
				
				LET cEvento = 'VALIDANDO GENERACION PREVIA DE REPORTE DE PAGO DE TARJETA DE CREDITO VISA DOMICILIADOS A OTROS BANCOS';		
				--LET cEvento = 'INSERTA REGISTRO EN SI_CONTROLPROC_INDICADORES DE REPORTE DE PAGO DE TARJETA DE CREDITO VISA DOMICILIADOS A OTROS BANCOS';
					
				SELECT LIMIT 1 flagfinalizado
				INTO  cFlag
				FROM  "informix".si_controlproc_indicadores 
				WHERE id_proc = pIdentificador AND tipo = pTipo AND nombre_proceso = cProceso AND fecha_procesoIni = dFechaIni AND fecha_procesoFin = dFechaFin;
				
				IF NVL(cFlag, '') = '' THEN	
					LET cEvento = 'INSERTA REGISTRO INICIAL EN TABLA DE CONTROL DE PROCESOS';
					INSERT INTO "informix".si_controlproc_indicadores (fecha_procesoIni, fecha_procesoFin, tipo, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin, maxfecha_cargada, flagfinalizado, coderror, msgerror)
					VALUES (dFechaIni, dFechaFin, pTipo, pIdentificador, cProceso, dFechaInicial, NULL, NULL, 'F', NULL, NULL );
				END IF;
				
				IF NVL(cFlag, '') <> 'V' THEN	
					BEGIN WORK;
						LET sEnTransaccion = 1;						
						LET cArchivo = REPLACE (cArchivo, 'AAAA', cAnio);
						LET cArchivo = REPLACE (cArchivo, 'MM', cMes);
						
						--CUENTA NUMERO DE REGISTROS
						LET cEvento = 'OBTIENE CANTIDAD DE REGISTROS DEL REPORTE DE PAGO DE TARJETA DE CREDITO VISA DOMICILIADOS A OTROS BANCOS';
						SELECT COUNT(a.fecha_aplica) 
							INTO iTotal
							FROM bdidomi:"informix".dom_cce_detalle a, bdidomi:"informix".dom_status_pago b
							WHERE a.cve_estatus = b.cve_status 
							AND a.banco_receptor <> 137
							AND a.banco_presentador = 137
							AND a.tipo_cta_ord = 05  
							AND a.cod_operacion = 30
							AND a.fecha_aplica BETWEEN YEAR(dFechaIni)||LPAD(MONTH(dFechaIni),2,0)||LPAD(DAY(dFechaIni),2,0) 
											   AND 
											   YEAR(dFechaFin)||LPAD(MONTH(dFechaFin),2,0)||LPAD(DAY(dFechaFin),2,0);
						
						LET cEvento = 'GENERA ENCABEZADOS DE REPORTE DE PAGO DE TARJETA DE CREDITO VISA DOMICILIADOS A OTROS BANCOS';
						
						LET cComando =   'echo "' || RPAD('FECHA',12, ' ') || '|' || RPAD('ESTADO',iMaxD, ' ') || '|' || RPAD('NUMERO DE DOMICILIACIONES',26,' ') || '|' || 'MONTO' || '" >> ' || TRIM(cRutaRepor) || TRIM(cArchivo);
						SYSTEM cComando;
						
						IF iTotal = 0 THEN
							LET cMensaje = 'NO EXISTE INFORMACION PARA GENERAR REPORTE DE PAGO DE TARJETA DE CREDITO VISA DOMICILIADOS A OTROS BANCOS';
							LET cComando =   'echo "' || ' ' || '" >> ' || TRIM(cRutaRepor) || TRIM(cArchivo);
							SYSTEM cComando;
							LET cComando =   'echo "' || ' ' || '" >> ' || TRIM(cRutaRepor) || TRIM(cArchivo);
							SYSTEM cComando;
							LET cComando =   'echo "' || TRIM(cMensaje) || '" >> ' || TRIM(cRutaRepor) || TRIM(cArchivo);
							SYSTEM cComando;						
						ELSE
						   LET cEvento = 'OBTENCION DE REGISTROS DEL REPORTE DE PAGO DE TARJETA DE CREDITO VISA DOMICILIADOS A OTROS BANCOS';
						   LET cMensaje = 'REPORTE DE PAGO DE TARJETA DE CREDITO VISA DOMICILIADOS A OTROS BANCOS GENERADO';
						   						   
							FOREACH 					
								--SELECT a.xfecha_aplica::DATE AS fecha, UPPER(b.descripcion) AS estado, COUNT(a.rfc_ord) AS numero_domi, SUM(((a.importe::INTEGER)/100)::DECIMAL(16,2)) AS monto
								SELECT MDY(SUBSTR(a.fecha_aplica,5,2),SUBSTR(a.fecha_aplica,7,2),SUBSTR(a.fecha_aplica,1,4))::DATE AS fecha, UPPER(b.descripcion) AS estado, 
								COUNT(a.rfc_ord) AS numero_domi, SUM(((a.importe::INTEGER)/100)::DECIMAL(16,2)) AS monto
								INTO dFecha2, cEstado3, cNum_domi, dcMonto3
								FROM bdidomi:"informix".dom_cce_detalle a, bdidomi:"informix".dom_status_pago b
								WHERE a.cve_estatus = b.cve_status 
								AND a.banco_receptor <> 137
								AND a.banco_presentador = 137
								AND a.tipo_cta_ord = 05  
								AND a.cod_operacion = 30
								AND a.fecha_aplica BETWEEN YEAR(dFechaIni)||LPAD(MONTH(dFechaIni),2,0)||LPAD(DAY(dFechaIni),2,0) AND YEAR(dFechaFin)||LPAD(MONTH(dFechaFin),2,0)||LPAD(DAY(dFechaFin),2,0)
								GROUP BY 1,2
													
								--IMPRIME
								  LET cComando = 'echo "' || RPAD(dFecha2,12,' ') || '|' || RPAD(cEstado3,iMaxD,' ') || '|' || RPAD(cNum_domi,26,' ') || '|' || dcMonto3 || '" >> ' || TRIM(cRutaRepor) || cArchivo;
								  SYSTEM cComando; 		  
							END FOREACH;
						END IF;
					COMMIT;
					LET sEnTransaccion = 0;
				
						SELECT DBINFO('utc_to_datetime',sh_curtime)
						INTO dFechaFinal
						FROM sysmaster:"informix".sysshmvals;
						
						LET cEvento = 'ACTUALIZACION FINAL DE REGISTRO EN TABLA DE CONTROL DE PROCESOS';
						
						UPDATE "informix".si_controlproc_indicadores 
						SET maxfecha_cargada = dFechaFin , flagfinalizado = 'V', coderror = cCodRet, msgerror =  cMensaje, fecha_cargafin =  dFechaFinal
						WHERE id_proc = pIdentificador
						AND tipo = pTipo
						--AND nombre_proceso = cProceso
						AND fecha_procesoIni = dFechaIni
						AND fecha_procesoFin = dFechafin;
						
						LET cMensCodRet = 'EL PROCESO DE '||TRIM(cProceso)||' SE HA GENERADO CORRECTAMENTE';						
				ELSE
					LET cMensCodRet = 'EL REPORTE FUE GENERADO ANTERIORMENTE';
				END IF;			
			ELIF pIdentificador = '4' THEN
				
				--OBTENCION DE FECHA INICIAL Y FECHA FINAL (6 MESES ANTERIORES AL PARAMETRO dFechaHoy)		
				SELECT ((fecha_hoy - INTERVAL (6) MONTH TO MONTH):: DATE - ((DAY(fecha_hoy) - 1)::DATE))::DATE, (fecha_hoy - DAY(fecha_hoy)::DATE)::DATE 
				INTO dFechaIniSem, dFechaFinSem
				FROM "informix".si_fechas;
				
				LET cMes      = LPAD(MONTH(dFechaFinSem), 2, 0);
				LET cAnio     = YEAR(dFechaFinSem);
				LET dFechaFin = dFechaHoy - DAY(dFechaHoy);	
				--LET cMes      = LPAD(MONTH(dFechaFin), 2, 0);				
				--LET cAnio     = YEAR(dFechaFin);
					
				--LET cProceso = 'REPORTE DE DOMICILIACIONES SEMESTRALES CON CARGO A CUENTA DE CAPTACIÃ??N';
				SELECT valor 
				INTO cArchivo
				FROM "informix".si_param
				WHERE cod_param = '378';
				LET cEvento = 'VALIDANDO GENERACION PREVIA DE DOMICILIACIONES SEMESTRALES CON CARGO A CUENTA DE CAPTACIÃ??N';
				
				SELECT LIMIT 1 flagfinalizado
				INTO cFlag
				FROM "informix".si_controlproc_indicadores 
				WHERE id_proc = pIdentificador AND tipo = pTipo AND fecha_procesoIni = dFechaIniSem AND fecha_procesoFin = dFechaFinSem;
				
				IF NVL(cFlag, '') = '' THEN	
					LET cEvento = 'INSERTA REGISTRO INICIAL EN TABLA DE CONTROL DE PROCESOS';
					INSERT INTO "informix".si_controlproc_indicadores (fecha_procesoIni, fecha_procesoFin, tipo, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin, maxfecha_cargada, flagfinalizado, coderror, msgerror)
					VALUES (dFechaIniSem, dFechaFinSem, pTipo, pIdentificador, cProceso, dFechaInicial, NULL, NULL, 'F', NULL, NULL );
				END IF;
				IF NVL(cFlag, '') <> 'V' THEN	
				--GUARDAMOS REGISTRO DEL PROCESO.				
				    BEGIN WORK;					
  					    LET sEnTransaccion = 1;
					    --REEMPLAZA LA FECHA EN EL NOMBRE DEL ARCHIVO
						LET cArchivo = REPLACE (cArchivo, 'AAAA', cAnio);
						LET cArchivo = REPLACE (cArchivo, 'MM', cMes);
											
						LET cEvento = 'GENERA ENCABEZADOS DE REPORTE DE DOMICILIACIONES SEMESTRALES CON CARGO A CUENTA DE CAPTACION';				
						LET cComando =   'echo "' ||RPAD('FECHA', 10, ' ')|| '|' || RPAD('CLIENTE', 20, ' ')|| '|' ||RPAD('NUMERO DE CUENTA', 20)|| '|' ||
										         RPAD('COMERCIO DOMICILIADO', 60, ' ') || '|' ||
										         RPAD('MONTO DOMICILIADO', 18, ' ')|| '|' || RPAD('SALDO PROMEDIO', 17, ' ') || '|' || 
										         RPAD('ESTATUS', 20, ' ')|| '" > ' || TRIM(cRutaRepor) || TRIM(cArchivo);
						SYSTEM cComando;				

						LET cEvento = 'OBTENCION DE REGISTROS DEL REPORTE DE DOMICILIACIONES SEMESTRALES CON CARGO A CUENTA DE CAPTACIÃ??N';
						LET cMensaje = 'REPORTE DE PAGO DE DOMICILIACIONES SEMESTRALES CON CARGO A CUENTA DE CAPTACIÃ??N';
						
						LET cFechaIniSem = YEAR(dFechaIniSem)||LPAD(MONTH(dFechaIniSem),2,0)||LPAD(DAY(dFechaIniSem),2,0);
						LET cFechaFinSem = YEAR(dFechaFinSem)||LPAD(MONTH(dFechaFinSem),2,0)||LPAD(DAY(dFechaFinSem),2,0);
						
						LET cFechaIniPromSem = YEAR(dFechaIniSem)||LPAD(MONTH(dFechaIniSem),2,0);
						LET cFechaFinPromSem = YEAR(dFechaFinSem)||LPAD(MONTH(dFechaFinSem),2,0);
						
						SELECT SUBSTR(b.fecha_aplica,1,4)||'-'||SUBSTR(b.fecha_aplica,5,2)||'-'||SUBSTR(b.fecha_aplica,7,2) AS fecha_aplica,
								(CASE WHEN tipo_cta_rec = '40' THEN 
									(SELECT MAX(num_cte) FROM bdicheq:"informix".sc_maechq SM WHERE SM.cuenta = SUBSTR(b.num_cta_rec,9,11))
								 ELSE--WHEN tipo_cta_rec = '03' THEN 
									(SELECT MAX(numcte) FROM bdicheq:"informix".sc_tarjeta TJ WHERE SUBSTR(b.num_cta_rec,5,16) = TJ.num_tarjeta)
								END) AS num_cte,
								(CASE WHEN tipo_cta_rec = '40' THEN (SUBSTR(b.num_cta_rec,9,11))
								 ELSE (SELECT MAX(cuenta) FROM bdicheq:"informix".sc_tarjeta TJ WHERE SUBSTR(b.num_cta_rec,5,16) = TJ.num_tarjeta)
								 END) AS numero_cuenta, 
								a.razon_social AS comercio, b.importe, UPPER(c.descripcion) AS estado, SUBSTR(b.fecha_aplica,1,4)||SUBSTR(b.fecha_aplica,5,2) AS fecha_anio_mes
						FROM bdidomi:"informix".dom_cat_servicios a, bdidomi:"informix".dom_cce_detalle b, bdidomi:"informix".dom_status_pago c
						WHERE b.rfc_ord = a.rfc
						AND b.cve_estatus = c.cve_status
						AND b.cod_operacion = '30'
						AND b.banco_receptor = '137'
						AND b.fecha_aplica BETWEEN cFechaIniSem AND cFechaFinSem
						INTO TEMP tmp_domi_sem WITH NO LOG;
								
						--CREATE INDEX idx_tmp_domi_sem ON tmp_domi_sem (fecha_anio_mes) USING btree;
						---CREATE INDEX "informix".idx_tmp_domi_sem2 ON tmp_domi_sem (num_cte, fecha_anio_mes) USING btree;
                        begin;
						CREATE INDEX "informix".idx_tmp_domi_sem2 ON tmp_domi_sem (num_cte) ONLINE;
                        commit;

                        begin;
						CREATE INDEX "informix".idx_tmp_domi_sem3 ON tmp_domi_sem (fecha_anio_mes) ONLINE;
                        commit;

                        begin;
						CREATE INDEX "informix".idx_tmp_domi_sem3 ON tmp_domi_sem (fecha_aplica, numero_cuenta, comercio) ONLINE;
                        commit;
								
						SELECT num_cte
						FROM bdinteg:tmp_domi_sem 
						WHERE fecha_anio_mes BETWEEN cFechaIniPromSem AND cFechaFinPromSem  
						GROUP BY num_cte
						HAVING COUNT(DISTINCT(fecha_anio_mes)) = 6
						--ORDER BY  num_cte
						INTO TEMP tmp_domi_prom WITH NO LOG;
								
                        begin;
						CREATE INDEX "informix".idx_tmp_domi_prom ON tmp_domi_prom (num_cte) ONLINE;
                        commit;
						
						SELECT fecha_aplica, b.num_cte, b.numero_cuenta, b.comercio, ((importe::INTEGER)/100)::decimal(16,2) AS importe, 
								NVL((SELECT (SUM(NULLIF(capvigacum,0)/ NULLIF(diacum,0))/6)::DECIMAL(16,2) 
									 FROM bdicheq:"informix".sc_sdodiarioc n
									 WHERE n.cuenta = B.numero_cuenta 
									 AND n.aniomes  BETWEEN cFechaIniPromSem AND cFechaFinPromSem), 0) 	AS promedio_mensual, b.estado
						FROM bdinteg:tmp_domi_sem b
						WHERE b.num_cte in (select num_cte from tmp_domi_prom )
						ORDER BY 1, 2, 3 ASC
						INTO TEMP tmp_dom_sem_final WITH NO LOG;
						
						SELECT COUNT(*) 
						INTO iTotal
						FROM tmp_dom_sem_final;
						
						IF iTotal = 0 THEN
							LET cMensaje = 'NO EXISTE INFORMACION PARA GENERAR REPORTE DE DOMICIACIONES SEMESTRALES CON CARGO A CUENTA DE CAPTACION';
							LET cComando =   'echo "' || ' ' || '" >> ' || TRIM(cRutaRepor) || TRIM(cArchivo);
							SYSTEM cComando;
							LET cComando =   'echo "' || ' ' || '" >> ' || TRIM(cRutaRepor) || TRIM(cArchivo);
							SYSTEM cComando;
							LET cComando =   'echo "' || TRIM(cMensaje) || '" >> ' || TRIM(cRutaRepor) || TRIM(cArchivo);
							SYSTEM cComando;							
						ELSE							
							FOREACH 			
								SELECT fecha_aplica, num_cte, numero_cuenta, comercio, importe, promedio_mensual, estado
								INTO cFecha, cNumCte, cNumCta, cComercio, cImporte, dcPromMens4, cEstado4
								FROM bdinteg:tmp_dom_sem_final
								
								LET cComando = 'echo "' || RPAD(TRIM(cFecha), 10,' ') ||'|'|| RPAD(TRIM(cNumCte),20,' ') ||'|'|| RPAD(TRIM(cNumCta),20,' ') ||'|'|| RPAD(TRIM(cComercio),60,' ') ||'|'|| LPAD(TRIM(cImporte::CHAR(18)),18,' ')
													 ||'|'|| LPAD(TRIM((dcPromMens4::DECIMAL(16,2))::CHAR(17)),17, ' ') ||'|'|| RPAD(TRIM(cEstado4),20,' ') || '" >> ' || TRIM(cRutaRepor) || TRIM(cArchivo);
								SYSTEM cComando; 		
									
							END FOREACH;
						END IF;
							
						COMMIT;						
						LET sEnTransaccion = 0;
						
						LET cEvento = 'ACTUALIZACION FINAL DE REGISTRO EN TABLA DE CONTROL DE PROCESOS';

						UPDATE "informix".si_controlproc_indicadores 
						SET	maxfecha_cargada = dFechaFinSem, flagfinalizado = 'V', coderror = cCodRet, msgerror =  cMensaje, fecha_cargafin =  CURRENT::DATE --dFechaFinSem
						WHERE id_proc = pIdentificador
						AND tipo = pTipo
						AND nombre_proceso = cProceso
						AND fecha_procesoIni = dFechaIniSem
						AND fecha_procesoFin = dFechaFinSem;	
						
						LET cMensCodRet = 'EL PROCESO DE '||TRIM(cProceso)||' SE HA GENERADO CORRECTAMENTE';
						
						--Borrar tablas de trabajo
						DROP TABLE tmp_domi_sem;
						DROP TABLE tmp_domi_prom;
						DROP TABLE tmp_dom_sem_final;
				ELSE
					LET cCodRet = '000000';
					LET cMensCodRet  = 'EL REPORTE FUE GENERADO ANTERIORMENTE';
				END IF;
			END IF;
		ELSE
			LET cMensCodRet = 'EL REPORTE NO EXISTE O SE ENCUENTRA INACTIVO.';
		END IF;	
	END IF;
	
	RETURN cCodRet, cMensCodRet;
END;
END PROCEDURE
DOCUMENT	
'REALIZA: Reporte de domiciliaciones de tarjeta de dÃ?ÃÂ©bito y pagos programados ',
'EQUIPO:AnÃ?ÃÂ¡lisis y diseÃ?ÃÂ±o de Mannto.4',
'FECHA:24/07/2015',
'VERSION:20150724',
'MODIFICO: Ingrid Pamela CÃ?ÃÂ¡zarez Villegas',
'DESCRIPCION: Se realizan reportes de Domiciliaciones de tarjeta de dÃ?ÃÂ©bito y pagos programados en cuentas de captaciÃ?ÃÂ³n para pagar tarjetas de crÃ?ÃÂ©dito.',
'FECHA:08/09/2015',
'VERSION:20150908',
'MODIFICO: Ingrid Pamela CÃ?ÃÂ¡zarez Villegas',
'DESCRIPCION: Se realizan reportes de Domiciliaciones de tarjeta de dÃ?ÃÂ©bito y pagos programados en cuentas de captaciÃ?ÃÂ³n para pagar tarjetas de crÃ?ÃÂ©dito.',
'FECHA:05/10/2015',
'VERSION:20151005',
'DESCRIPCION: Se modifica consulta para extraer el archivo PPR.TDCBCPL.OBANCOS.AAAAMM.txt y evitar problemas en la validacion de fechas',
'MODIFICO: Antonio Cebreros PÃ?ÃÂ©rez',
'DESCRIPCION: Se agrega nuevo reporte (reporte semestral); se configura procedimiento para realizar un reporte a la vez en base a nÃ?ÃÂºmero identificador de reporte; se modifican insert a la tabla si_controlproc_indicadores debido a que se agregÃ?ÃÂ³ una nueva columna antes de id_proc: "tipo"',
'FECHA: 01/12/2015',
'VERSION: 20151201',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_domi_conciliacontable2(pNomArchivo CHAR(20), pTpoProc INTEGER, pfecini Char(10), pfecfin Char(10), pregistros INTEGER, precuperacion INTEGER)
RETURNING 
    Char(5),       -- 00.- Codigo de Retorno    
    Date,          -- 01.- Fecha Presentacion
        Integer,       --02.- Cantidad de Registros Archivo Origuinal
        Money(18,2),   --03.- Sumatoria de Reguistros Archivo Origuinal
        Integer,       --04.- Cantidad de Registros Archivo Respuesta1
        Money(18,2),   --05.- Sumatoria de Reguistros Archivo Respuesta1
        Integer,       --06.- Cantidad de Registros Archivo Respuesta2 
        Money(18,2),   --07.- Sumatoria de Reguistros Archivo Respuesta2
        Char(14),      --08.- Cuenta Contable Cargos
        Money(18,2),   --09.- Sumatoria Cuenta Contable Cargos
        Char(14),      --10.- Cuenta Contable Cargos Deudora
        Money(18,2),   --11.- Sumatoria Cuenta Contable Cargos Deudora
        Char(14),      --12.- Cuenta Contable Abonos
        Money(18,2);   --13.- Sumatoria Cuenta Contable Abonos
    

-- Declaracion de Variables
Define iSQLerr                          Integer;
Define cCodRet                          Char(5);
Define cCodRet2                         Char(5);
Define cDescError                       Char(95);

Define dFechaPresentacion               Date;
Define iContRegOriginal                 Integer;
Define mSumRegOriguinal                 Money(18,2);
Define iContRegResp1                    Integer;
Define mSumRegResp1                     Money(18,2);
Define iContRegResp2                    Integer;
Define mSumRegResp2                     Money(18,2);
Define cCuentaContableCargo             Char(14);
Define mSumCuentaContableCargo          Money(18,2);
Define cCuentaContableCargoDeudora      Char(14);
Define mSumCuentaContableCargoDeudora   Money(18,2);
Define cCuentaContableAbono             Char(14);
Define mSumCuentaContableAbono          Money(18,2);
Define cCodParam01                      Char(2);
Define cCodParam02                      Char(2);
Define cCodParam03                      Char(2);
Define dFecha_Presentacion              Date;
Define dFechaHoy                        Date;
Define cTipoP                           Char(1);
Define cCodOperacion                    Char(2);
Define cFecIni                          Char(8);
Define cFecFin                          Char(8);
Define cFecha_Presentacion              Char(8);
Define iTipoOp                          Integer;

ON EXCEPTION SET iSQLerr
    IF iSQLerr <> 0 THEN
        LET cCodRet = iSQLerr; 
        RETURN cCodRet,dFecha_Presentacion,iContRegOriginal,mSumRegOriguinal,iContRegResp1,mSumRegResp1,iContRegResp2,mSumRegResp2,
                           cCuentaContableCargo,mSumCuentaContableCargo,cCuentaContableCargoDeudora,mSumCuentaContableCargoDeudora,
                           cCuentaContableAbono,mSumCuentaContableAbono;   
        END IF
END EXCEPTION;

--Inicializacion de Variables
Let iSQLerr                                              = 0;
Let cCodRet                                              = '00000';
Let cCodRet2                                             = '00000';
Let cDescError                                           = '';

Let dFechaPresentacion               = '';
Let iContRegOriginal                 = 0;
Let mSumRegOriguinal                 = 0.00;
Let iContRegResp1                    = 0;
Let mSumRegResp1                     = 0.00;
Let iContRegResp2                    = 0;
Let mSumRegResp2                     = 0.00;
Let cCuentaContableCargo             = '';
Let mSumCuentaContableCargo          = 0.00;
Let cCuentaContableCargoDeudora      = '';
Let mSumCuentaContableCargoDeudora   = 0.00;
Let cCuentaContableAbono             = '';
Let mSumCuentaContableAbono          = 0.00;
Let cCodParam01                      = '';
Let cCodParam02                      = '';
Let cCodParam03                      = '';
Let dFecha_Presentacion              = '';
Let dFechaHoy                        = '';
Let cTipoP                           = '';
Let cCodOperacion                    = '';
Let cFecIni                          = '';
Let cFecFin                          = '';
Let cFecha_Presentacion              = '';
Let iTipoOp                          = 0;

        --SET DEBUG FILE TO "/tmp/sp_domi_ConciliaContable.out";
        --TRACE ON;     

Begin

        --Validacion de Parametros de entrada
        IF pfecini = "01/01/1900" OR pfecfin = "01/01/1900" THEN
                LET pfecini = "";
                LET pfecfin = "";               
        END IF; 
        
        IF ((pTpoProc = "") OR (pTpoProc IS NULL)) THEN 
                LET iTipoOp = -1;               
        ELSE
                LET iTipoOp = pTpoProc;         
        END IF;
        
        IF ((pfecini IS NULL) OR (pfecfin IS NULL)) THEN                        
                LET pfecini = "";
                LET pfecfin = "";
        ELSE            
                LET pfecini = pfecini;
                LET pfecfin = pfecfin;
        END IF;

        IF pNomArchivo = "" AND iTipoOp = -1 THEN 
                LET cCodRet = "02612"; -- FALTAN PARAMETROS: NOMBRE DEL ARCHIVO O TIPO DE PROCESO
                EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
                RETURN cCodRet2, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
                           cCuentaContableCargo, mSumCuentaContableCargo,cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
                           cCuentaContableAbono, mSumCuentaContableAbono;
        END IF; 
        
        IF (pNomArchivo <> "") AND (iTipoOp >= 0) THEN -- CON EL NOMBRE DEL ARCHIVO Y  TIPO DE PROCESO
                LET cCodRet = "02612"; -- ERROR EN LA ASIGNACION DE PARAMETROS: NO SE PUEDE GENERAR POR NOMBRE + TIPO DE PROCESO
                EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
                RETURN cCodRet2, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
                           cCuentaContableCargo, mSumCuentaContableCargo,cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
                           cCuentaContableAbono, mSumCuentaContableAbono;
        END IF; 
        
        If Trim(pNomArchivo) <> "" or pNomArchivo is not null Then
                Select limit 1 cod_operacion 
                Into cCodOperacion              
                From dom_cce_detalle 
                Where nombre_arch = pNomArchivo;
                
                If substr(pNomArchivo,1,1) = 'E' And cCodOperacion = '30' Then 
                        Let pTpoProc = 1;
                Elif substr(pNomArchivo,1,1) = 'E' And cCodOperacion = '34' Then 
                        Let pTpoProc = 2;
                Elif substr(pNomArchivo,1,1) = 'S' And cCodOperacion = '30' Then 
                        Let pTpoProc = 4;
                Elif substr(pNomArchivo,1,1) = 'S' And cCodOperacion = '34' Then 
                        Let pTpoProc = 5 ;
                End  if         
        End If
        
    IF pTpoProc = 1 THEN -- REPORTE PRESENTADO
        Let cTipoP = 'E';
                Let cCodOperacion = '30';               
                Let cCodParam01 = '18';
                Let cCodParam02 = '19';
    ELIF pTpoProc = 2 THEN -- REPORTE PRESENTADO
                Let cTipoP = 'E';
                Let cCodOperacion = '34';               
                Let cCodParam01 = '20';
                Let cCodParam02 = '21';
    ELIF pTpoProc = 4 THEN -- REPORTE RECIBIDO
                Let cTipoP = 'S';
                Let cCodOperacion = '30';               
                Let cCodParam01 = '22';
                Let cCodParam02 = '23';
    ELIF pTpoProc = 5 THEN -- REPORTE RECIBIDO    
                Let cTipoP = 'S';
                Let cCodOperacion = '34';                           
                Let cCodParam01 = '24';
                Let cCodParam02 = '25';
                Let cCodParam03 = '26';         
    ELSE
                LET cCodRet = '02600'; -- OPERACION DESCONOCIDA
                RETURN cCodRet, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
                           cCuentaContableCargo, mSumCuentaContableCargo,cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
                           cCuentaContableAbono, mSumCuentaContableAbono;
    END IF
        
        --Obtengo las cuenta contables para la conciliaciÃ³n
        Select valor Into cCuentaContableCargo 
        From dom_parametros Where cod_param = cCodParam01;
        
        Select valor Into cCuentaContableAbono
        From dom_parametros Where cod_param = cCodParam02;
        
        If cCodParam03 <> '' then 
                Select valor Into cCuentaContableCargoDeudora 
                From dom_parametros Where cod_param = cCodParam03;
        End if
        
        --Se validan los parametros obtenidos
        If length(cCuentaContableCargo) <> 14 then
                LET cCodRet = '02613'; -- 
                RETURN cCodRet, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
                           cCuentaContableCargo, mSumCuentaContableCargo,cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
                           cCuentaContableAbono, mSumCuentaContableAbono;
        End if
        
        If length(cCuentaContableAbono) <> 14 then
                LET cCodRet = '02613'; --
                RETURN cCodRet, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
                           cCuentaContableCargo, mSumCuentaContableCargo,cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
                           cCuentaContableAbono, mSumCuentaContableAbono;
        End if
        
        If length(cCuentaContableAbono) <> 14 and cCodParam03 <> '' then
                LET cCodRet = '02613'; --
                RETURN cCodRet, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
                           cCuentaContableCargo, mSumCuentaContableCargo,cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
                           cCuentaContableAbono, mSumCuentaContableAbono;
        End if
        
        If pNomArchivo <> "" Then               
                Select fecha_presentacion 
                Into cFecha_Presentacion
                From dom_cce_encabezado         
                Where nombre_arch = pNomArchivo;
                
                --Formateo la variable a tipo char en  yyyymmdd   de   mm/dd/yyyy
                Let cFecIni = cFecha_Presentacion; 
                Let cFecFin = cFecha_Presentacion;                      
        Else
                --Formateo la variable a tipo char en  yyyymmdd   de   mm/dd/yyyy
                Let cFecIni = substr(pfecini,7,4) || substr(pfecini,1,2) || substr(pfecini,4,2); 
                Let cFecFin = substr(pfecfin,7,4) || substr(pfecfin,1,2) || substr(pfecfin,4,2);        
        End IF  
        
        Let cCodOperacion = cCodOperacion;
        Let cTipoP  =cTipoP; 
        Let cFecIni = cFecIni;
        Let cFecFin = cFecFin;
        
        Foreach with hold
                Select skip pregistros first precuperacion Distinct(fecha_presentacion)
                Into cFecha_Presentacion
                From dom_cce_encabezado
                Where cod_operacion = cCodOperacion
                And Substr(nombre_arch,1,1) = cTipoP
                And fecha_presentacion Between cFecIni And cFecFin
                
                Let pNomArchivo = pNomArchivo;

                --Obtiene cantidad de reguistros del archivo y total en pesos del mismo
                Select Count(nombre_arch), nvl(Sum(importe::integer),0) / 100
                Into iContRegOriginal, mSumRegOriguinal
                From dom_cce_detalle 
                Where fecha_presentacion = cFecha_Presentacion
                And cod_operacion = cCodOperacion
                And Substr(nombre_arch,1,1) = cTipoP;
                
                --Obtiene cantidad de reguistros del archivo respuesta 1 y total en pesos del mismo
                Select Count(nombre_arch), nvl(Sum(importe::integer),0) / 100
                Into iContRegResp1, mSumRegResp1
                From dom_cce_detalle 
                Where fecha_presentacion = cFecha_Presentacion 
                And cod_operacion = cCodOperacion
                And Substr(nombre_arch,1,1) = cTipoP
                And cve_estatus = '02';
                
                --Obtiene cantidad de reguistros del archivo respuesta 2 y total en pesos del mismo
                Select Count(nombre_arch), nvl(Sum(importe::integer),0) / 100
                Into iContRegResp2, mSumRegResp2
                From dom_cce_detalle 
                Where fecha_presentacion = cFecha_Presentacion 
                And cod_operacion = cCodOperacion
                And Substr(nombre_arch,1,1) = cTipoP
                And cve_estatus = '01';
                
                --Obtengo la fecha de presentacion del archivo mm/dd/yyyy
                Let dFecha_Presentacion = substr(cFecha_Presentacion,5,2) || '/' || substr(cFecha_Presentacion,7,2) || '/' || substr(cFecha_Presentacion,1,4);          

                Select fecha_hoy Into dFechaHoy From bdicheq:sc_fechas;
                
                If Month(dFecha_Presentacion) = Month(dFechaHoy) then
                        
                        --Obtengo la sumatoria de los cargos para la cuenta contable de Cargos
                        Select nvl(Sum(cargos_dia),0)
                        Into mSumCuentaContableCargo
                        From bdicont:co_sdodias
                        Where ccmayor = substr(cCuentaContableCargo,1,4)
                        And ccsub = substr(cCuentaContableCargo,5,2)
                        And ccsubsub = substr(cCuentaContableCargo,7,2)
                        And ccssubsub = substr(cCuentaContableCargo,9,2)
                        And ccsssubsub = substr(cCuentaContableCargo,11,2)
                        And sector = substr(cCuentaContableCargo,13,2)
                        And mes_dia = dFecha_Presentacion;
                        
                        --Obtengo la sumatoria de los abonos para la cuenta contable de Abonos
                        Select nvl(Sum(abonos_dia),0)
                        Into mSumCuentaContableAbono
                        From bdicont:co_sdodias
                        Where ccmayor = substr(cCuentaContableAbono,1,4)
                        And ccsub = substr(cCuentaContableAbono,5,2)
                        And ccsubsub = substr(cCuentaContableAbono,7,2)
                        And ccssubsub = substr(cCuentaContableAbono,9,2)
                        And ccsssubsub = substr(cCuentaContableAbono,11,2)
                        And sector = substr(cCuentaContableAbono,13,2)
                        And mes_dia = dFecha_Presentacion;
                        
                        If cCodParam03 <> '' then
                                --Obtengo la sumatoria de los cargos para la cuenta contable Deudora de Cargos
                                Select nvl(Sum(abonos_dia),0)
                                Into mSumCuentaContableCargoDeudora
                                From bdicont:co_sdodias
                                Where ccmayor = substr(cCuentaContableCargoDeudora,1,4)
                                And ccsub = substr(cCuentaContableCargoDeudora,5,2)
                                And ccsubsub = substr(cCuentaContableCargoDeudora,7,2)
                                And ccssubsub = substr(cCuentaContableCargoDeudora,9,2)
                                And ccsssubsub = substr(cCuentaContableCargoDeudora,11,2)
                                And sector = substr(cCuentaContableCargoDeudora,13,2)
                                And mes_dia = dFecha_Presentacion;
                        End IF  

                        RETURN cCodRet, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,
                                   iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
                                   cCuentaContableCargo, mSumCuentaContableCargo,
                                   cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
                                   cCuentaContableAbono, mSumCuentaContableAbono WITH RESUME;                                   
                Else                            
                        --Obtengo la sumatoria de los cargos para la cuenta contable de Cargos de Hist
                        Select nvl(Sum(cargos_dia),0)
                        Into mSumCuentaContableCargo
                        From bdicont:co_histsdodias
                        Where ccmayor = substr(cCuentaContableCargo,1,4)
                        And ccsub = substr(cCuentaContableCargo,5,2)
                        And ccsubsub = substr(cCuentaContableCargo,7,2)
                        And ccssubsub = substr(cCuentaContableCargo,9,2)
                        And ccsssubsub = substr(cCuentaContableCargo,11,2)
                        And sector = substr(cCuentaContableCargo,13,2)
                        And mes_dia = dFecha_Presentacion;
                        
                        --Obtengo la sumatoria de los abonos para la cuenta contable de Abonos
                        Select nvl(Sum(abonos_dia),0)
                        Into mSumCuentaContableAbono
                        From bdicont:co_histsdodias
                        Where ccmayor = substr(cCuentaContableAbono,1,4)
                        And ccsub = substr(cCuentaContableAbono,5,2)
                        And ccsubsub = substr(cCuentaContableAbono,7,2)
                        And ccssubsub = substr(cCuentaContableAbono,9,2)
                        And ccsssubsub = substr(cCuentaContableAbono,11,2)
                        And sector = substr(cCuentaContableAbono,13,2)
                        And mes_dia = dFecha_Presentacion;
                        
                        If cCodParam03 <> '' then
                                --Obtengo la sumatoria de los cargos para la cuenta contable Deudora de Cargos
                                Select nvl(Sum(abonos_dia),0)
                                Into mSumCuentaContableCargoDeudora
                                From bdicont:co_histsdodias
                                Where ccmayor = substr(cCuentaContableCargoDeudora,1,4)
                                And ccsub = substr(cCuentaContableCargoDeudora,5,2)
                                And ccsubsub = substr(cCuentaContableCargoDeudora,7,2)
                                And ccssubsub = substr(cCuentaContableCargoDeudora,9,2)
                                And ccsssubsub = substr(cCuentaContableCargoDeudora,11,2)
                                And sector = substr(cCuentaContableCargoDeudora,13,2)
                                And mes_dia = dFecha_Presentacion;
                        End IF  

                        RETURN cCodRet, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,
                                   iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
                                   cCuentaContableCargo, mSumCuentaContableCargo,
                                   cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
                                   cCuentaContableAbono, mSumCuentaContableAbono WITH RESUME;                                   
                End IF  
        End Foreach
        
                
End 
End Procedure
DOCUMENT
'AUTOR: Armando Mercado Figueroa',
'Descripcion: Sumatoria por dia segun cuenta contable, las cuentas contables se encuentran parametrizadas',
'Fecha: 2009/09/02',
'Version: 20090902.1246',
'BD: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_consarch2 (pFechaIni date, pFechaFin date, pRegistros integer, pRecuperacion integer)
	RETURNING char(6),char(80),char(20),integer,money(16,2),date,char(30);

DEFINE cCodRet                  char(6);                        --CODIGO DE RETORNO
DEFINE isqlerr                  integer;                        --VARIABLE PARA CACHAR EL CODIGO DE ERRORDEFINE vsqlerr integer;
DEFINE sIsamErr                 integer;                        --VARIABLE PARA CACHAR EL CODIGO DE ERROR
DEFINE cErrorInfo               char(80);                       --VARIABLE PARA CACHAR LA DESCRIPCION DEL ERROR
DEFINE vErrorInfo               char(80);                       --VARIABLE PARA RETORNAR EL MENSAJE DE ERROR O MENSAJE DE EXITO
DEFINE cNombreArch              char(20);                       --NOMBRE DE ARCHIVO
DEFINE iTotRegistros    integer;                        --TOTAL DE REGISTROS
DEFINE iImporte                 money(16,2);            --SUMA DE IMPORTES DEL DETALLE
DEFINE dFechaPres               date;                           --FECHA DE PRESENTACION CON FORMATO DATE
DEFINE cDescripcion             char(30);                       --DESC RIPCION DEL ESTATUS
DEFINE iNumReg                  integer;                        --NUMERO DE REGSITROS QUE ARROJA UNA CONSULTA
DEFINE cCodRetMensaje   char(6);                        --CODIGO DE ERROR QUE REGRESA EL SP DE MANEJO DE ERRORES
DEFINE cFechaPres               char(8);                        --FECHA DE PRESENTACION

LET cCodRet                     = "00000";
LET isqlerr                     = 0;
LET SIsamErr                    = 0;
LET cErrorInfo                  = "";
LET vErrorInfo                  = "PROCESO EXITOSO";
LET cNombreArch                 = "";
LET iTotRegistros               = 0;
LET iImporte                    = 0;
LET dFechaPres                  = date(1);
LET cDescripcion                = "";
LET iNumReg                             = 0;
LET cCodRetMensaje              = "";
LET cFechaPres                  = "";

BEGIN

        ON EXCEPTION  SET isqlerr, sIsamErr, cErrorInfo
                IF isqlerr <> 0  THEN
                        LET  cCodRet  = isqlerr;
                        LET vErrorInfo = cErrorInfo;
                        RETURN cCodRet,vErrorInfo,cNombreArch,iTotRegistros,iImporte,dFechaPres,cDescripcion;
                END IF;
        END  EXCEPTION
/*
set debug file to "/tmp/Pulido/PRUEBAPUL.out";
trace on;
*/

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 4;

        --SE VERIFICA QUE EXISTAN REGISTROS EN EL RANGO DE FECHAS SELECCIONADO
        select limit 1 nombre_arch into cNombreArch from bdidomi:dom_cce_archivos
        where mdy(substring(fecha_presentacion from 5 for 2),substring(fecha_presentacion from 7 for 2),substring(fecha_presentacion from 1 for 4))
                between pFechaIni::date and pFechaFin::date;
        LET iNumReg=dbinfo("sqlca.sqlerrd2");

        if iNumReg > 0 then
                FOREACH
                        --SE OBTIENEN LOS ARCHIVOS DE LA TABLA bdidomi:dom_cce_archivos QUE SE ENCUENTREN DENTRO DEL RANGO DE FECHAS SELECCIONADO
                        select skip pRegistros first pRecuperacion a.nombre_arch,a.tot_registros,a.fecha_presentacion,e.descripcion
                        INTO cNombreArch,iTotRegistros,cFechaPres,cDescripcion
                        from bdidomi:dom_cce_archivos a
                            inner join bdidomi:dom_status_archcce e on a.cve_status=e.cve_status
                        where a.fecha_presentacion between to_char(pFechaIni,'%Y%m%d') and to_char(pFechaFin,'%Y%m%d')

                        --SE OBTIENE LA SUMA DE LOS IMPORTE DE LA TABLA DE DETALLE DE CADA ARCHIVO
                        select NVL(sum(importe::money(16,2)/100),0) into iImporte from bdidomi:dom_cce_detalle
                        where nombre_arch = cNombreArch and fecha_presentacion = cFechaPres;

                        --LA FECHA DE PRESENTACION SE REGRESA DE TIPO DATE
                        LET dFechaPres = mdy(substring(cFechaPres from 5 for 2),substring(cFechaPres from 7 for 2),substring(cFechaPres from 1 for 4));

                        RETURN cCodRet,vErrorInfo,cNombreArch,iTotRegistros,iImporte,dFechaPres,cDescripcion with resume;

                END FOREACH;

        else
                --SI NO EXISTEN REGISTROS SE OBTIENE EL MENSAJE DE ERROR
                LET cCodRet = '02301';
                CALL sp_obtenermensajeerror (cCodRet) RETURNING cCodRetMensaje,vErrorInfo;
                RETURN cCodRet,vErrorInfo,cNombreArch,iTotRegistros,iImporte,dFechaPres,cDescripcion;
        end if;
        --prueba
END;
END PROCEDURE
DOCUMENT
'AUTOR: Jose Luis Pulido Zepeda',
'Descripcion: CONSULTAR ARCHIVOS GENERADOS O RECIBIDOS PARA EL PROYECTO DOMI',
'Fecha: 2009/08/06',
'Version: 20090806.1022',
'BD: BDIDOMI',

'MODIFICO: Jose Luis Pulido Zepeda',
'Descripcion: SE CAMBIO EL VALOR DE RETORNO DEL IMPORTE DE INTEGER A MONEY(16,2)',
'Fecha: 2009/09/25',
'Version: 20090925.0907',
'BD: BDIDOMI',

'MODIFICO: Oscar Flores Conde',
'Descripcion: Se agrega manejo de recuperacion por bloques',
'Fecha: 2015/08/21',
'Version: 20150821.1228',
'BD: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_consarch2_totales (pFechaIni date, pFechaFin date)
	RETURNING char(6),integer;

DEFINE cCodRet                  char(6);                        --CODIGO DE RETORNO
DEFINE isqlerr                  integer;                        --VARIABLE PARA CACHAR EL CODIGO DE ERRORDEFINE vsqlerr integer;
DEFINE sIsamErr                 integer;                        --VARIABLE PARA CACHAR EL CODIGO DE ERROR
DEFINE cErrorInfo               char(80);                       --VARIABLE PARA CACHAR LA DESCRIPCION DEL ERROR
DEFINE vErrorInfo               char(80);                       --VARIABLE PARA RETORNAR EL MENSAJE DE ERROR O MENSAJE DE EXITO
DEFINE cNombreArch              char(20);                       --NOMBRE DE ARCHIVO
DEFINE iNumReg                  integer;                        --NUMERO DE REGSITROS QUE ARROJA UNA CONSULTA
DEFINE cCodRetMensaje   char(6);                        --CODIGO DE ERROR QUE REGRESA EL SP DE MANEJO DE ERRORES

LET cCodRet                     = "00000";
LET isqlerr                     = 0;
LET SIsamErr                    = 0;
LET cErrorInfo                  = "";
LET vErrorInfo                  = "PROCESO EXITOSO";
LET iNumReg                             = 0;
LET cCodRetMensaje              = "";

BEGIN

        ON EXCEPTION  SET isqlerr, sIsamErr, cErrorInfo
                IF isqlerr <> 0  THEN
                        LET  cCodRet  = isqlerr;
                        LET vErrorInfo = cErrorInfo;
                        RETURN cCodRet, isqlerr;
                END IF;
        END  EXCEPTION
/*
set debug file to "/tmp/Pulido/PRUEBAPUL.out";
trace on;
*/

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 4;

        --SE VERIFICA QUE EXISTAN REGISTROS EN EL RANGO DE FECHAS SELECCIONADO
        select limit 1 nombre_arch into cNombreArch from bdidomi:dom_cce_archivos
        where mdy(substring(fecha_presentacion from 5 for 2),substring(fecha_presentacion from 7 for 2),substring(fecha_presentacion from 1 for 4))
                between pFechaIni::date and pFechaFin::date;
        LET iNumReg=dbinfo("sqlca.sqlerrd2");

        if iNumReg > 0 then
			--SE OBTIENE EL NUMERO DE REGISTROS QUE DEVOLVERA LA CONSULTA
			select count(*)
			INTO iNumReg
			from bdidomi:dom_cce_archivos a
				inner join bdidomi:dom_status_archcce e on a.cve_status=e.cve_status
			where a.fecha_presentacion between to_char(pFechaIni,'%Y%m%d') and to_char(pFechaFin,'%Y%m%d');

			RETURN cCodRet, iNumReg;

        else
                --SI NO EXISTEN REGISTROS SE OBTIENE EL MENSAJE DE ERROR
                LET cCodRet = '02301';
                CALL sp_obtenermensajeerror (cCodRet) RETURNING cCodRetMensaje,vErrorInfo;
                RETURN cCodRet, 0;
        end if;
        --prueba
END;
END PROCEDURE
DOCUMENT
'AUTOR: Jose Luis Pulido Zepeda',
'Descripcion: CONSULTAR ARCHIVOS GENERADOS O RECIBIDOS PARA EL PROYECTO DOMI',
'Fecha: 2009/08/06',
'Version: 20090806.1022',
'BD: BDIDOMI',

'MODIFICO: Jose Luis Pulido Zepeda',
'Descripcion: SE CAMBIO EL VALOR DE RETORNO DEL IMPORTE DE INTEGER A MONEY(16,2)',
'Fecha: 2009/09/25',
'Version: 20090925.0907',
'BD: BDIDOMI',

'MODIFICO: Oscar Flores Conde',
'Descripcion: Se obtiene el numero total de registros que seran procesados',
'Fecha: 2015/08/21',
'Version: 20150821.1228',
'BD: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_consultaservicios2 (pRegistros INTEGER, pRecuperacion INTEGER)
        Returning       CHAR (5),       --Codigo de Retorno
                                CHAR (18),      --RFC
                                CHAR (60),      --Razon Social
                                CHAR (20),      --Nombre corto razon social
                                CHAR (1),       --convenio
                                CHAR (2),       --cve_canal
                                CHAR (1),       --presentador
                                CHAR (20),      --num_cte
                                CHAR (20),      --num_reintentos
                                CHAR (20),      --comision
                                CHAR (20),      --comision_dev
                                CHAR (20),      --cuenta_cargo_comision                 
                                CHAR (1),       --layout_especial
                                CHAR (4),       --cod_grupo_act
                                CHAR (4),       --cod_grupo_des
                                CHAR (4);       --cod_grupo_react
        
        --Declaracion de  Variables
        DEFINE sql_err         INTEGER;
        DEFINE cCodret         CHAR(5);
        DEFINE cRfc            CHAR (18);
        DEFINE cRazon_social   CHAR (60);
        DEFINE iContador       SMALLINT;
        DEFINE cNombre_corto   CHAR(20);
        DEFINE cCodGrupoAct    CHAR(4);
        DEFINE cCodGrupoDes        CHAR(4);
        DEFINE cCodGrupoReact  CHAR(4); 
        DEFINE cConvenio           CHAR(1);
        DEFINE cCve_canal          CHAR(2);
        DEFINE cPresentador    CHAR(1);
        DEFINE cNum_cte            CHAR(20);
        DEFINE cNum_reintentos CHAR(20);
        DEFINE cComision           CHAR(20);
        DEFINE cComision_dev   CHAR(20);
        DEFINE cCuenta_cargo_comision CHAR(20);
        DEFINE cLayout_especial CHAR(1);
        
        --Inicializo Variables
        LET sql_err            = 0;
        LET cCodret            = "00000";
        LET cRazon_social      = "";
        LET cRfc               = "";
        LET iContador          = 0;
        LET cNombre_corto          = "";
        LET cCodGrupoAct       = "";
        LET cCodGrupoDes           = "";
        LET cCodGrupoReact     = "";
        LET cConvenio              = "";
        LET cCve_canal             = "";
        LET cPresentador           = "";
        LET cNum_cte               = "";
        LET cNum_reintentos        = "";
        LET cComisioN              = "";
        LET cComision_dev      = "";
        LET cCuenta_cargo_comision = "";
        LET cLayout_especial   = "";

        BEGIN 
        --Manejo de excepciones (errores)
        ON EXCEPTION SET sql_err
                IF sql_err <> 0 THEN
                        let cCodret = sql_err;
                        RETURN cCodret, cRfc, cRazon_social,cNombre_corto,cConvenio,cCve_canal,cPresentador,cNum_cte,cNum_reintentos,cComision,cComision_dev,cCuenta_cargo_comision,cLayout_especial,cCodGrupoAct,cCodGrupoDes,cCodGrupoReact; --Regresa Resultados
                END IF;
        END EXCEPTION;

        --SET DEBUG FILE TO "/tmp/sp_Domi_ConsultaServicios.out";
        --TRACE ON;  

        FOREACH --Realiza una consulta donde obtiene los servicios 
                SELECT SKIP pRegistros FIRST pRecuperacion rfc,razon_social, nombre_corto,convenio,cve_canal,presentador,num_cte,num_reintentos,comision,comision_dev,cuenta_cargo_comision,layout_especial,cod_grupo_act,cod_grupo_des,cod_grupo_react
                INTO cRfc,cRazon_social, cNombre_corto,cConvenio,cCve_canal,cPresentador,cNum_cte,cNum_reintentos,cComision,cComision_dev,cCuenta_cargo_comision,cLayout_especial,cCodGrupoAct,cCodGrupoDes,cCodGrupoReact
                FROM bdidomi:dom_cat_servicios
                ORDER BY razon_social
                
                LET iContador = iContador + 1; --Se incrementa el contador 
                
                RETURN cCodret, cRfc, cRazon_social,cNombre_corto,cConvenio,cCve_canal,cPresentador,cNum_cte,cNum_reintentos,cComision,cComision_dev,cCuenta_cargo_comision,cLayout_especial,cCodGrupoAct,cCodGrupoDes,cCodGrupoReact WITH RESUME; --Regresa Resultados
        END FOREACH;
        IF iContador = 0 THEN  --Valida si se encontraron registros
                LET cCodret = '00001';
                RETURN cCodret, cRfc, cRazon_social,cNombre_corto,cConvenio,cCve_canal,cPresentador,cNum_cte,cNum_reintentos,cComision,cComision_dev,cCuenta_cargo_comision,cLayout_especial,cCodGrupoAct,cCodGrupoDes,cCodGrupoReact WITH RESUME; --Regresa Resultados
        END IF;
        END;
END PROCEDURE
DOCUMENT
'AUTOR      : César Valdéz Figueroa',
'DESCRIPCION: Este procedimiento se encarga de Obtener los servicios que se pueden domiciliar.',
'                         obteniendo los datos de la tabla dom_cat_servicios',          
'FECHA      : 2009/10/12',
'VERSION    : 20091012.1130',
'BD         : BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_genrep102(pNomArchivo CHAR(20), pTpoProc INTEGER, pfecini CHAR(10), pfecfin CHAR(10), pregistros INTEGER, precuperacion INTEGER)
RETURNING
         CHAR(5),       -- 001.- Codigo de Retorno
		 CHAR(130),     -- 002.- Descripcion del Error
		 CHAR(10),      -- 01.- Fecha Presentacion
		 CHAR(20),      -- 02.- Nombre Archivo
		 MONEY(15, 2),  -- 03.- Importe
		 CHAR(7),       -- 04.- Sec
		 CHAR(20),      -- 05.- Cuenta Origen
		 CHAR(20),      -- 06.- Cuenta Destino
		 CHAR(20),      -- 07.- Tipo de Cuenta
		 CHAR(20),      -- 08.- Banco Destino
		 CHAR(20),      -- 09.- Estatus
		 CHAR(2),       -- 10.- Codigo de Respuesta
		 CHAR(60),      -- 11.- Causa Rechazo
		 CHAR(2);		-- 12.- Clave del estatus

-- Declaracion de Variables
DEFINE iSQLerr        INTEGER;
DEFINE cCodRet        CHAR(5);       -- 001
DEFINE cDescError     CHAR(130);      -- 002
DEFINE cFechPresFinR  CHAR(10);      -- 01
DEFINE cNomArch       CHAR(20);      -- 02
DEFINE mImp2          MONEY(15, 2);  -- 03
DEFINE cSec           CHAR(7);       -- 04
DEFINE cCtaOrigen     CHAR(20);      -- 05
DEFINE cCtaDest       CHAR(20);      -- 06
DEFINE cTpoCta        CHAR(20);      -- 07
DEFINE cBancDest      CHAR(20);      -- 08
DEFINE cStatus        CHAR(20);      -- 09
DEFINE cCodResp       CHAR(2);       -- 10
DEFINE cCausaRech     CHAR(60);      -- 11
DEFINE cFechPresS	  CHAR(8);
DEFINE cFecInicioW    CHAR(8);
DEFINE cFecFinW       CHAR(8);
DEFINE cTipoP         CHAR(1);
DEFINE cStat_val      CHAR(2);
DEFINE cImp           CHAR(15);
DEFINE cTipoCtaCod    CHAR(30);
DEFINE cCodRet2       CHAR(5);
DEFINE iTipoOp        INTEGER;
DEFINE cClave_rastreo  CHAR(30);


ON EXCEPTION SET iSQLerr
	IF iSQLerr <> 0 THEN
		LET cCodRet = iSQLerr;
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, cDescError, cFechPresS, cNomArch, cImp, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val;
	END IF;
END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_domi_genrep10.out";
	--TRACE ON;

-- Inicializacion de Variables
LET iSQLerr        = 0;
LET cCodRet        = "00000"; -- 00
LET cFechPresFinR  = "";      -- 01
LET cNomArch       = "";      -- 02
LET cImp           = "";      -- 04
LET cSec           = "";      -- 05
LET cCtaOrigen     = "";      -- 06
LET cCtaDest       = "";      -- 07
LET cTpoCta        = "";      -- 08
LET cBancDest      = "";      -- 09
LET cStatus        = "";      -- 10
LET cCodResp       = "";      -- 11
LET cCausaRech     = "";      -- 12
LET cFechPresS	   = "";
LET cFecInicioW    = "";
LET cFecFinW       = "";
LET cTipoP         = "";
LET cStat_val      = "";
LET mImp2          = 0.00;
LET cTipoCtaCod    = "";
LET cCodRet2       = "";
LET cDescError     = "";
LET iTipoOp        = 0;
LET cClave_rastreo = '';

BEGIN

	IF pfecini = "01/01/1900" OR pfecfin = "01/01/1900" THEN
		LET pfecini = "";
		LET pfecfin = "";
	END IF;

	IF ((pTpoProc = "") OR (pTpoProc IS NULL)) THEN
		LET iTipoOp = -1;
	ELSE
		LET iTipoOp = pTpoProc;
	END IF;

	IF ((pfecini IS NULL) OR (pfecfin IS NULL)) THEN
		LET pfecini = "";
		LET pfecfin = "";
	ELSE
		LET pfecini = pfecini;
		LET pfecfin = pfecfin;
	END IF;

	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO wait 4;

	IF pNomArchivo = "" AND iTipoOp = -1 THEN
		LET cCodRet = "02600"; -- FALTAN PARAMETROS: NOMBRE DEL ARCHIVO O TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, cDescError, cFechPresS, cNomArch, cImp, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val;
	END IF;

	IF (pNomArchivo <> "") AND (iTipoOp >= 0) THEN -- CON EL NOMBRE DEL ARCHIVO Y  TIPO DE PROCESO
		LET cCodRet = "02601"; -- ERROR EN LA ASIGNACION DE PARAMETROS: NO SE PUEDE GENERAR POR NOMBRE + TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, cDescError, cFechPresS, cNomArch, cImp, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val;
	END IF;

	IF pNomArchivo <> "" AND iTipoOp = -1 THEN -- CONSULTA POR NOMBRE DEL ARCHIVO
		IF pfecini = "" AND pfecfin = "" THEN
			IF (SUBSTR(pNomArchivo, 1, 1) = 'E' AND SUBSTR(pNomArchivo, 14, 2) = 10 AND LENGTH(pNomArchivo) = 17) OR
			   (SUBSTR(pNomArchivo, 1, 1) = 'S' AND SUBSTR(pNomArchivo, 11, 2) = 10 AND LENGTH(pNomArchivo) = 16) THEN

				IF NOT EXISTS (SELECT 1 FROM bdidomi:dom_cce_detalle WHERE nombre_arch = pNomArchivo) THEN
						LET cCodRet = "02602"; -- EL ARCHIVO NO EXISTE
						EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
						RETURN cCodRet, cDescError, cFechPresS, cNomArch, cImp, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val;
				END IF;

				FOREACH WITH HOLD

					SELECT SKIP pregistros FIRST precuperacion 
						 TRIM(det.fecha_presentacion), TRIM(det.importe), TRIM(det.num_secuencia),
						 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.num_cta_rec) ELSE TRIM(det.num_cta_ord) END,
						 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.num_cta_ord) ELSE TRIM(det.num_cta_rec) END,
						 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.tipo_cta_rec) ELSE TRIM(det.tipo_cta_ord) END,
						 TRIM(ban.vchrnombrecorto), TRIM(stap.descripcion), TRIM(dev.descripcion), TRIM(det.cve_estatus),det.clave_rastreo
					INTO cFechPresS, cImp, cSec,
						 cCtaDest, cCtaOrigen, cTipoCtaCod,
						 cBancDest, cStatus, cCausaRech, cStat_val,cClave_rastreo
					FROM bdidomi:dom_cce_detalle det
					INNER JOIN bdidomi:dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
					INNER JOIN bdidomi:dom_status_pago stap ON det.cve_estatus = stap.cve_status
					INNER JOIN bdinteg:si_bancos ban ON det.banco_receptor = ban.banco
					WHERE nombre_arch = pNomArchivo
					AND cod_operacion = '10'

					SELECT descripcion
					INTO cTpoCta
					FROM bdidomi:dom_tipo_cta
					WHERE tipo_cta = cTipoCtaCod;

					IF cStat_val <> "03" THEN
						LET cCausaRech = "";
					END IF;
					--si es rechazado  colocar la causa de rechazo del codigo 11
					IF cStat_val = "02" THEN
					
						SELECT dev.descripcion 
						INTO cCausaRech 
						FROM bdidomi:dom_cce_detalle det
						INNER JOIN bdidomi:dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
						WHERE cod_operacion = '11'
						AND clave_rastreo = cClave_rastreo;

					END IF;
					IF cStat_val = '00' THEN
						LET cCodResp = '';
					ELSE
						LET cCodResp = '11';
					END IF;
				
					LET mImp2 = cImp / 100;
					LET	cFechPresFinR = TRIM(SUBSTR(cFechPresS, 7, 2) || '/' || SUBSTR(cFechPresS, 5, 2) || '/' || SUBSTR(cFechPresS, 1, 4));

					RETURN cCodRet, TRIM(cDescError), cFechPresFinR, pNomArchivo, mImp2, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val WITH RESUME;

				END FOREACH;
			ELSE
				LET cCodRet = "02604"; -- ERROR EN LA ESTRUCTURA DEL NOMBRE DEL ARCHIVO
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
				RETURN cCodRet, cDescError, cFechPresS, cNomArch, cImp, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val;
			END IF;

		ELSE
			LET cCodRet = "02605"; -- ERROR EN LA ASIGNACION DE PARAMETROS: NO SE PUEDE GENERAR POR ARCHIVO + FECHA(S) -- no se puede ejecutar nombre de archivo con fechaS
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
			RETURN cCodRet, cDescError, cFechPresS, cNomArch, cImp, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val;
		END IF;


	ELIF iTipoOp = 0 OR iTipoOp = 3 THEN -- CONSULTA POR NOMBRE DEL PROCESO
		IF pfecini <> "" AND pfecfin <> "" THEN

			-- SE FORMATEAN LAS FECHAS RECIBIDAS PARA CAMBIARLAS A 'YYYYMMDD' (SIN DIAGONALES) PARA INCLUIRLAS EN EL WHERE
			LET cFecInicioW = SUBSTR(pfecini, 7, 4) || SUBSTR(pfecini, 1, 2) || SUBSTR(pfecini, 4, 2);
			LET cFecFinW = SUBSTR(pfecfin, 7, 4) || SUBSTR(pfecfin, 1, 2) || SUBSTR(pfecfin, 4, 2);

			IF iTipoOp = 0 THEN -- REPORTE PRESENTADO
				LET cTipoP = 'E';
			ELIF iTipoOp = 3 THEN -- REPORTE RECIBIDO
				LET cTipoP = 'S';
			END IF;

			IF NOT EXISTS (SELECT 1 FROM bdidomi:dom_cce_detalle WHERE cod_operacion = '10' AND fecha_presentacion BETWEEN cFecInicioW AND cFecFinW
																						    AND nombre_arch LIKE cTipoP || '%') THEN
				LET cCodRet = "02603"; -- EL ARCHIVO NO EXISTE
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
				RETURN cCodRet, cDescError, cFechPresS, cNomArch, cImp, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val;
			END IF;

			FOREACH WITH HOLD

				SELECT SKIP pregistros FIRST precuperacion 
					 TRIM(det.fecha_presentacion), TRIM(nombre_arch), TRIM(det.importe), TRIM(det.num_secuencia),
					 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.num_cta_rec) ELSE TRIM(det.num_cta_rec) END,
					 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.num_cta_ord) ELSE TRIM(det.num_cta_ord) END,
					 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.tipo_cta_rec) ELSE TRIM(det.tipo_cta_ord) END,
					 TRIM(ban.vchrnombrecorto), TRIM(stap.descripcion), TRIM(dev.descripcion), TRIM(det.cve_estatus),det.clave_rastreo
				INTO cFechPresS, cNomArch, cImp, cSec,
					  cCtaDest, cCtaOrigen, cTipoCtaCod,
					  cBancDest, cStatus, cCausaRech, cStat_val,cClave_rastreo
				FROM bdidomi:dom_cce_detalle det
				INNER JOIN bdidomi:dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
				INNER JOIN bdidomi:dom_status_pago stap ON det.cve_estatus = stap.cve_status
				INNER JOIN bdinteg:si_bancos ban ON det.banco_receptor = ban.banco
				WHERE cod_operacion = '10'
				AND fecha_presentacion BETWEEN cFecInicioW AND cFecFinW
				AND nombre_arch LIKE cTipoP || '%'

				SELECT TRIM(descripcion)
				INTO cTpoCta
				FROM bdidomi:dom_tipo_cta
				WHERE tipo_cta = cTipoCtaCod;

				IF cStat_val <> "03" THEN
					LET cCausaRech = "";
				END IF;
				--si es rechazado  colocar la causa de rechazo del codigo 11
				IF cStat_val = "02" THEN
				
					SELECT dev.descripcion 
					INTO cCausaRech 
					FROM bdidomi:dom_cce_detalle det
					INNER JOIN bdidomi:dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
					WHERE cod_operacion = '11'
					AND clave_rastreo = cClave_rastreo
					AND fecha_presentacion BETWEEN cFecInicioW AND cFecFinW;

					
				END IF;
				IF cStat_val = '00' THEN
					LET cCodResp = '';
				ELSE
					LET cCodResp = '11';
				END IF;
				
				LET mImp2 = cImp / 100;
				LET	cFechPresFinR = TRIM(SUBSTR(cFechPresS, 7, 2) || '/' || SUBSTR(cFechPresS, 5, 2) || '/' || SUBSTR(cFechPresS, 1, 4));

				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, mImp2, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val WITH RESUME;

			END FOREACH;
		ELSE
			LET cCodRet = '02606'; -- ERROR EN LA GENERACION DEL REPORTE POR TIPO DE PROCESO: FALTAN FECHA INICIO Y/O FECHA FINAL
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
			RETURN cCodRet, cDescError, cFechPresS, cNomArch, cImp, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val;
		END IF;
	ELSE
		LET cCodRet = '02607'; -- TIPO DE OPERACION NO VALIDA PARA LA GENERACION DE REPORTES ARCHIVO 10 - VALORES 0 o 3
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, cDescError, cFechPresS, cNomArch, cImp, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val;
	END IF;
END
END PROCEDURE
DOCUMENT
'AUTOR: Clemente Angulo Ballardo',
'DESCRIPCION: Procedimiento que genera el reporte de los archivos codigo 10, ya sean presentados o recibidos',
'FECHA: 11/08/2009',
'VERSION: 20090811.1800',
'BD: Bdidomi',
'Modifico: CÃ©sar ValdÃ©z Figueroa',
'Descripcion: Se modificaron para a gregar el mensaje causa de rechazo cuando se requiera, ademas de que cuando ',
'			  no se reciba respuesta en 11 no se muestra el codigo de respuesta',
'Fecha: 2009/09/28',
'Version: 20090929.1000',
'BD: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_genrep302(pNomArchivo CHAR(20), pTpoProc INTEGER, pfecini CHAR(10), pfecfin CHAR(10), pregistros INTEGER, precuperacion INTEGER)
RETURNING
         CHAR(5),       -- 001.- Codigo de Retorno
		 CHAR(130),     -- 002.- Descripcion del Error
		 CHAR(10),      -- 01.- Fecha Presentacion
		 CHAR(20),      -- 02.- Nombre Archivo
		 CHAR(40),      -- 03.- Nombre Ordenante
		 CHAR(60),      -- 04.- Servicio
		 CHAR(7),       -- 05.- Referencia Numerica
		 MONEY(15, 2),  -- 06.- Importe
		 CHAR(20),      -- 07.- Cuenta Destino
		 CHAR(7),       -- 08.- Sec
		 CHAR(20),      -- 09.- Tipo de Cuenta
		 CHAR(20),      -- 10.- Banco Destino
		 CHAR(20),      -- 11.- Estatus
		 CHAR(60),      -- 12.- Causa Rechazo
		 CHAR(2);       -- 13.- Codigo de Respuesta

-- Declaracion de Variables
DEFINE iSQLerr        INTEGER;
DEFINE cCodRet        CHAR(5);        -- 001
DEFINE cDescError     CHAR(130);      -- 002
DEFINE cFechPresFinR  CHAR(10);       -- 01
DEFINE cNomArch       CHAR(20);       -- 02
DEFINE cNomOrd        CHAR(40);       -- 03
DEFINE cServ          CHAR(60);       -- 04
DEFINE cRef           CHAR(7);        -- 05
DEFINE mImp2          MONEY(15, 2);   -- 06
DEFINE cCtaDest       CHAR(20);       -- 07
DEFINE cSec           CHAR(7);        -- 08
DEFINE cTpoCta        CHAR(20);       -- 09
DEFINE cBancDest      CHAR(20);       -- 10
DEFINE cStatus        CHAR(20);       -- 11
DEFINE cCausaRech     CHAR(60);       -- 12
DEFINE cCodResp       CHAR(2);        -- 13
DEFINE cImp           CHAR(15);
DEFINE cFechPresS	  CHAR(8);
DEFINE cFecInicioW    CHAR(8);
DEFINE cFecFinW       CHAR(8);
DEFINE cTipoP         CHAR(1);
DEFINE cStat_val      CHAR(2);
DEFINE cTipoCtaCod    CHAR(30);
DEFINE cCodRet2       CHAR(5);
DEFINE cBancDestCod   CHAR(3);
DEFINE iTipoOp        INTEGER;
DEFINE cClave_Rastreo CHAR(30);



ON EXCEPTION SET iSQLerr
	IF iSQLerr <> 0 THEN
		LET cCodRet = iSQLerr;
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
	END IF;
END EXCEPTION;

--	SET DEBUG FILE TO "/tmp/sp_domi_genrep30.out";
--	TRACE ON;	

-- Inicializacion de Variables
LET iSQLerr        = 0;
LET cCodRet        = "00000"; -- 001
LET cDescError     = "";      -- 002
LET cFechPresFinR  = "";      -- 01
LET cNomArch       = "";      -- 02
LET cNomOrd        = "";      -- 03
LET cServ          = "";      -- 04
LET cRef           = "";      -- 05
LET mImp2          = 0.00;    -- 06
LET cCtaDest       = "";      -- 07
LET cSec           = "";      -- 08
LET cTpoCta        = "";      -- 09
LET cBancDest      = "";      -- 10
LET cStatus        = "";      -- 11
LET cCausaRech     = "";      -- 12
LET cCodResp       = "";      -- 13
LET cImp           = "";
LET cFechPresS	   = "";
LET cFecInicioW    = "";
LET cFecFinW       = "";
LET cTipoP         = "";
LET cStat_val      = "";
LET cTipoCtaCod    = "";
LET cCodRet2       = "";
LET cDescError     = "";
LET cBancDestCod   = "";
LET iTipoOp        = 0;
LET cClave_Rastreo = "";

BEGIN

	IF pfecini = "01/01/1900" OR pfecfin = "01/01/1900" THEN
		LET pfecini = "";
		LET pfecfin = "";		
	END IF;	
	
	IF ((pTpoProc = "") OR (pTpoProc IS NULL)) THEN	
		LET iTipoOp = -1;		
	ELSE
		LET iTipoOp = pTpoProc;		
	END IF;
	
	IF ((pfecini IS NULL) OR (pfecfin IS NULL)) THEN			
		LET pfecini = "";
		LET pfecfin = "";
	ELSE		
		LET pfecini = pfecini;
		LET pfecfin = pfecfin;
	END IF;
	
	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO wait 4;

	IF pNomArchivo = "" AND iTipoOp = -1 THEN 
		LET cCodRet = "02600"; -- FALTAN PARAMETROS: NOMBRE DEL ARCHIVO O TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
	END IF;	
	
	IF (pNomArchivo <> "") AND (iTipoOp >= 0) THEN -- CON EL NOMBRE DEL ARCHIVO Y  TIPO DE PROCESO
		LET cCodRet = "02601"; -- ERROR EN LA ASIGNACION DE PARAMETROS: NO SE PUEDE GENERAR POR NOMBRE + TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
	END IF;
	
	IF pNomArchivo <> "" AND iTipoOp = -1 THEN -- CONSULTA POR NOMBRE DEL ARCHIVO
		IF pfecini = "" AND pfecfin = "" THEN
			IF (SUBSTR(pNomArchivo, 1, 1) = 'E' AND SUBSTR(pNomArchivo, 14, 2) = 30 AND LENGTH(pNomArchivo) = 17) OR
			   (SUBSTR(pNomArchivo, 1, 1) = 'S' AND SUBSTR(pNomArchivo, 11, 2) = 30 AND LENGTH(pNomArchivo) = 16) THEN
				
				IF NOT EXISTS (SELECT 1 FROM bdidomi:dom_cce_detalle WHERE nombre_arch = pNomArchivo) THEN 
						LET cCodRet = "02602"; -- EL ARCHIVO NO EXISTE
						EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
						RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
				END IF;
	
				FOREACH WITH HOLD	
				
					SELECT SKIP pregistros FIRST precuperacion 
						 TRIM(det.fecha_presentacion), TRIM(nombre_rec), TRIM(ser.razon_social), TRIM(det.ref_numerica),				
						 TRIM(det.importe), TRIM(det.num_cta_rec), TRIM(det.num_secuencia), TRIM(det.tipo_cta_rec),
						 CASE WHEN SUBSTR(pNomArchivo, 1,1) = 'E' THEN TRIM(det.banco_receptor) ELSE TRIM(det.banco_presentador) END,
						 TRIM(stap.descripcion), TRIM(dev.descripcion), TRIM(det.cve_estatus), det.clave_rastreo
					INTO cFechPresS, cNomOrd, cServ, cRef,
					     cImp, cCtaDest, cSec, cTipoCtaCod, 
						 cBancDestCod, 
						 cStatus, cCausaRech, cStat_val, cClave_Rastreo
					FROM bdidomi:dom_cce_detalle det
					INNER JOIN bdidomi:dom_cat_servicios ser ON det.rfc_ord = ser.rfc
					INNER JOIN bdidomi:dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
					INNER JOIN bdidomi:dom_status_pago stap ON det.cve_estatus = stap.cve_status			
					WHERE nombre_arch = pNomArchivo
					AND cod_operacion = '30'
						LET cCodResp = '';
					SELECT TRIM(descripcion)
					INTO cTpoCta
					FROM bdidomi:dom_tipo_cta
					WHERE tipo_cta = cTipoCtaCod;
					
					SELECT TRIM(vchrnombrecorto)
					INTO cBancDest
					FROM bdinteg:si_bancos
					WHERE banco = cBancDestCod;
								
					IF cStat_val = '01' THEN
						LET cCodResp = '32';
						LET cCausaRech = "";
					ELIF cStat_val = '02' THEN
						LET cCodResp = '31';
					ELIF cStat_val = '03' OR cStat_val = '00' THEN
						LET cCodResp = "";
						LET cCausaRech = "";
					END IF;
					
					IF cCodResp = '31' THEN
						SELECT dev.descripcion 
						INTO cCausaRech
						FROM bdidomi:dom_cce_detalle AS det,bdidomi:dom_cat_devoluciones AS dev 
						WHERE clave_rastreo = cClave_Rastreo
						AND cod_operacion = '31'
						AND det.motivo_dev = dev.motivo_dev;
					END IF;
					
					LET mImp2 = cImp / 100;					
					LET	cFechPresFinR = TRIM(SUBSTR(cFechPresS, 7, 2) || '/' || SUBSTR(cFechPresS, 5, 2) || '/' || SUBSTR(cFechPresS, 1, 4));
					
					RETURN cCodRet, TRIM(cDescError), cFechPresFinR, pNomArchivo, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp WITH RESUME;
					
				END FOREACH;
			ELSE
				LET cCodRet = "02604"; -- ERROR EN LA ESTRUCTURA DEL NOMBRE DEL ARCHIVO
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
			END IF;
		ELSE
			LET cCodRet = "02605"; -- ERROR EN LA ASIGNACION DE PARAMETROS: NO SE PUEDE GENERAR POR ARCHIVO + FECHA(S) -- no se puede ejecutar nombre de archivo con fechaS
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
			RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
		END IF;		
			
	ELIF iTipoOp = 1 OR iTipoOp = 4 THEN -- CONSULTA POR NOMBRE DEL PROCESO		
		IF pfecini <> "" AND pfecfin <> "" THEN 
		
			-- SE FORMATEAN LAS FECHAS RECIBIDAS PARA CAMBIARLAS A 'YYYYMMDD' (SIN DIAGONALES) PARA INCLUIRLAS EN EL WHERE
			LET cFecInicioW = SUBSTR(pfecini, 7, 4) || SUBSTR(pfecini, 1, 2) || SUBSTR(pfecini, 4, 2);
			LET cFecFinW = SUBSTR(pfecfin, 7, 4) || SUBSTR(pfecfin, 1, 2) || SUBSTR(pfecfin, 4, 2);
		
			IF pTpoProc = 1 THEN -- REPORTE PRESENTADO
				LET cTipoP = 'E';
			ELIF pTpoProc = 4 THEN -- REPORTE RECIBIDO
				LET cTipoP = 'S';			
			END IF;
			
			IF NOT EXISTS (SELECT 1 FROM bdidomi:dom_cce_detalle WHERE cod_operacion = '30' AND fecha_presentacion BETWEEN cFecInicioW AND cFecFinW
																						    AND nombre_arch LIKE cTipoP || '%') THEN
				LET cCodRet = "02603"; -- EL ARCHIVO NO EXISTE
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
			END IF;
				
			FOREACH WITH HOLD
			
				SELECT SKIP pregistros FIRST precuperacion		
					 TRIM(det.fecha_presentacion), TRIM(nombre_arch), TRIM(nombre_rec), TRIM(ser.razon_social), TRIM(det.ref_numerica),				
					 TRIM(det.importe), TRIM(det.num_cta_rec), TRIM(det.num_secuencia), TRIM(det.tipo_cta_rec),
					 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.banco_receptor) ELSE TRIM(det.banco_presentador) END,
					 TRIM(stap.descripcion), TRIM(dev.descripcion), TRIM(det.cve_estatus), det.clave_rastreo
				INTO cFechPresS, cNomArch, cNomOrd, cServ, cRef,
				     cImp, cCtaDest, cSec, cTipoCtaCod, 
					 cBancDestCod, 
					 cStatus, cCausaRech, cStat_val, cClave_Rastreo
				FROM bdidomi:dom_cce_detalle det
				INNER JOIN bdidomi:dom_cat_servicios ser ON det.rfc_ord = ser.rfc			
				INNER JOIN bdidomi:dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
				INNER JOIN bdidomi:dom_status_pago stap ON det.cve_estatus = stap.cve_status
				WHERE cod_operacion = '30'
				AND fecha_presentacion BETWEEN cFecInicioW AND cFecFinW
				AND nombre_arch LIKE cTipoP || '%'
				
				SELECT TRIM(descripcion)
				INTO cTpoCta
				FROM bdidomi:dom_tipo_cta
				WHERE tipo_cta = cTipoCtaCod;
				
				SELECT TRIM(vchrnombrecorto)
				INTO cBancDest
				FROM bdinteg:si_bancos
				WHERE banco = cBancDestCod;
				
				IF cStat_val = '01' THEN
					LET cCodResp = '32';
					LET cCausaRech = "";
				ELIF cStat_val = '02' THEN
					LET cCodResp = '31';
				ELIF cStat_val = '03' OR cStat_val = '00' THEN
					LET cCodResp = "";
					LET cCausaRech = "";
				END IF;
				
				IF cCodResp = '31' THEN
					SELECT dev.descripcion 
					INTO cCausaRech
					FROM bdidomi:dom_cce_detalle AS det,bdidomi:dom_cat_devoluciones AS dev 
					WHERE clave_rastreo = cClave_Rastreo
					AND cod_operacion = '31'
					AND det.motivo_dev = dev.motivo_dev;
				END IF;
				
				LET mImp2 = cImp / 100;				
				LET	cFechPresFinR = TRIM(SUBSTR(cFechPresS, 7, 2) || '/' || SUBSTR(cFechPresS, 5, 2) || '/' || SUBSTR(cFechPresS, 1, 4));
				
				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp WITH RESUME;
			
			END FOREACH;
		ELSE
			LET cCodRet = '02606'; -- ERROR EN LA GENERACION DEL REPORTE POR TIPO DE PROCESO: FALTAN FECHA INICIO Y/O FECHA FINAL
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
			RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
		END IF;	
	ELSE
		LET cCodRet = '02608'; -- TIPO DE OPERACION NO VALIDA PARA LA GENERACION DE REPORTES ARCHIVO 30 - VALORES 1 o 4
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
	END IF;	
END
END PROCEDURE
DOCUMENT
'AUTOR: Clemente Angulo Ballardo',
'DESCRIPCION: Procedimiento que genera el reporte de los archivos codigo 30, ya sean presentados o recibidos',
'FECHA: 13/08/2009',
'VERSION: 20090813.1730',
'BD: Bdidomi',

'MODIFICO: Cesar Valdez Figueroa',
'DESCRIPCION: para que regresara la descrimcion del codigo 31',
'FECHA: 10/11/2009',
'VERSION: 20091110.1200',
'BD: Bdidomi';

CREATE PROCEDURE "informix".sp_domi_genrep342(pNomArchivo CHAR(20), pTpoProc INTEGER, pfecini CHAR(10), pfecfin CHAR(10), pregistros INTEGER, precuperacion INTEGER)
RETURNING
         CHAR(5),       -- 001.- Codigo de Retorno
		 CHAR(65),      -- 002.- Descripcion del Error
		 CHAR(10),      -- 01.- Fecha Presentacion
		 CHAR(20),      -- 02.- Nombre Archivo
		 CHAR(40),      -- 03.- Nombre Ordenante
		 CHAR(60),      -- 04.- Servicio
		 CHAR(7),       -- 05.- Referencia Numerica
		 MONEY(15, 2),  -- 06.- Importe
		 CHAR(20),      -- 07.- Cuenta Destino
		 CHAR(7),       -- 08.- Sec
		 CHAR(20),      -- 09.- Tipo de Cuenta
		 CHAR(20),      -- 10.- Banco Destino
		 CHAR(10),      -- 11.- Fecha Origen
		 CHAR(20),      -- 12.- Estatus
		 CHAR(4);       -- 13.- Sucursal

-- Declaracion de Variables
DEFINE iSQLerr        INTEGER;
DEFINE cCodRet        CHAR(5);        -- 001
DEFINE cDescError     CHAR(95);       -- 002
DEFINE cFechPresFinR  CHAR(10);       -- 01
DEFINE cNomArch       CHAR(20);       -- 02
DEFINE cNomOrd        CHAR(40);       -- 03
DEFINE cServ          CHAR(60);       -- 04
DEFINE cRef           CHAR(7);        -- 05
DEFINE mImp2          MONEY(15, 2);   -- 06
DEFINE cCtaDest       CHAR(20);       -- 07
DEFINE cSec           CHAR(7);        -- 08
DEFINE cTpoCta        CHAR(20);       -- 09
DEFINE cBancDest      CHAR(20);       -- 10
DEFINE cFechOrig      CHAR(10);       -- 11
DEFINE cStatus        CHAR(20);       -- 12
DEFINE cImp           CHAR(15);
DEFINE cFechPresS	  CHAR(8);
DEFINE cFecInicioW    CHAR(8);
DEFINE cFecFinW       CHAR(8);
DEFINE cFechIniS      CHAR(8);
DEFINE cTipoP         CHAR(1);
DEFINE cStat_val      CHAR(2);
DEFINE cTipoCtaCod    CHAR(30);
DEFINE cCodRet2       CHAR(5);
DEFINE cBancDestCod   CHAR(3);
DEFINE cSucursal	  CHAR(4);
DEFINE cTipo_registro CHAR(2);
DEFINE cNum_secuencia CHAR(7);
DEFINE iTipoOp        INTEGER;
DEFINE cMensaje    CHAR(300);

ON EXCEPTION SET iSQLerr
	IF iSQLerr <> 0 THEN
		LET cCodRet = iSQLerr;
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal;
	END IF;
END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_domi_genrep34.out";
	--TRACE ON;

-- Inicializacion de Variables
LET iSQLerr        = 0;
LET cCodRet        = "00000"; -- 001
LET cDescError     = "";      -- 002
LET cFechPresFinR  = "";      -- 01
LET cNomArch       = "";      -- 02
LET cNomOrd        = "";      -- 03
LET cServ          = "";      -- 04
LET cRef           = "";      -- 05
LET mImp2          = 0.00;    -- 06
LET cCtaDest       = "";      -- 07
LET cSec           = "";      -- 08
LET cTpoCta        = "";      -- 09
LET cBancDest      = "";      -- 10
LET cStatus        = "";      -- 11
LET cImp           = "";
LET cFechPresS	   = "";
LET cFecInicioW    = "";
LET cFecFinW       = "";
LET cFechIniS      = "";
LET cFechOrig      = "";
LET cTipoP         = "";
LET cStat_val      = "";
LET cTipoCtaCod    = "";
LET cCodRet2       = "";
LET cDescError     = "";
LET cBancDestCod   = "";
LET cSucursal	   = "";
LET cTipo_registro = "";
LET cNum_secuencia = "";
LET iTipoOp        = 0;

BEGIN

	IF pfecini = "01/01/1900" OR pfecfin = "01/01/1900" THEN
		LET pfecini = "";
		LET pfecfin = "";
	END IF;

	IF ((pTpoProc = "") OR (pTpoProc IS NULL)) THEN
		LET iTipoOp = -1;
	ELSE
		LET iTipoOp = pTpoProc;
	END IF;

	IF ((pfecini IS NULL) OR (pfecfin IS NULL)) THEN
		LET pfecini = "";
		LET pfecfin = "";
	ELSE
		LET pfecini = pfecini;
		LET pfecfin = pfecfin;
	END IF;

	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO wait 4;

	IF pNomArchivo = "" AND iTipoOp = -1 THEN
		LET cCodRet = "02600"; -- FALTAN PARAMETROS: NOMBRE DEL ARCHIVO O TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal;
	END IF;

	IF (pNomArchivo <> "") AND (iTipoOp >= 0) THEN -- CON EL NOMBRE DEL ARCHIVO Y  TIPO DE PROCESO
		LET cCodRet = "02601"; -- ERROR EN LA ASIGNACION DE PARAMETROS: NO SE PUEDE GENERAR POR NOMBRE + TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal;
	END IF;

	IF pNomArchivo <> "" AND iTipoOp = -1 THEN -- CONSULTA POR NOMBRE DEL ARCHIVO
		IF pfecini = "" AND pfecfin = "" THEN
			IF (SUBSTR(pNomArchivo, 1, 1) = 'E' AND SUBSTR(pNomArchivo, 14, 2) = 34 AND LENGTH(pNomArchivo) = 17) OR
			   (SUBSTR(pNomArchivo, 1, 1) = 'S' AND SUBSTR(pNomArchivo, 11, 2) = 34 AND LENGTH(pNomArchivo) = 16) THEN

				IF NOT EXISTS (SELECT 1 FROM bdidomi:dom_cce_detalle WHERE nombre_arch = pNomArchivo) THEN
					LET cCodRet = "02602"; -- EL ARCHIVO NO EXISTE
					EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
					RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal;
				END IF;

				FOREACH WITH HOLD

					SELECT SKIP pregistros FIRST precuperacion
						 TRIM(det.fecha_presentacion),
						 CASE WHEN SUBSTR(pNomArchivo, 1,1) = 'E' THEN TRIM(det.nombre_ord) ELSE TRIM(det.nombre_rec) END,
						 TRIM(ser.razon_social), TRIM(det.ref_numerica), TRIM(det.importe),  
					     CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.num_cta_ord) ELSE TRIM(det.num_cta_rec) END,
						 TRIM(det.num_secuencia), TRIM(det.tipo_cta_rec),
						 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.banco_receptor) ELSE TRIM(det.banco_receptor) END,
						 TRIM(det.fecha_pres_ini), TRIM(stap.descripcion), TRIM(det.cve_estatus),det.tipo_registro,det.num_secuencia,
						 TRIM(det.nombre_arch)
					INTO cFechPresS,
					     cNomOrd,
						 cServ, cRef, cImp, cCtaDest, cSec, cTipoCtaCod,
						 cBancDestCod,
						 cFechIniS, cStatus, cStat_val,cTipo_registro,cNum_secuencia,cNomArch
					FROM bdidomi:dom_cce_detalle det
					INNER JOIN bdidomi:dom_cat_servicios ser ON det.rfc_ord = ser.rfc
					INNER JOIN bdidomi:dom_status_pago stap ON det.cve_estatus = stap.cve_status
					WHERE det.nombre_arch = pNomArchivo
					AND cod_operacion = '34'

					SELECT TRIM(descripcion)
					INTO cTpoCta
					FROM bdidomi:dom_tipo_cta
					WHERE tipo_cta = cTipoCtaCod;

					SELECT TRIM(sucursal_sol)
					INTO cSucursal
					FROM bdidomi:dom_reversos
					WHERE nom_archivo_rev = cNomArch 
						AND fecha_presentacion_rev = cFechPresS
						AND tipo_registro = cTipo_registro
						AND num_secuencia = cNum_secuencia;

					SELECT TRIM(vchrnombrecorto)
					INTO cBancDest
					FROM bdinteg:si_bancos
					WHERE banco = cBancDestCod;

					LET mImp2 = cImp / 100;
					LET cFechOrig = TRIM(SUBSTR(cFechIniS, 7, 2) || '/' || SUBSTR(cFechIniS, 5, 2) || '/' || SUBSTR(cFechIniS, 1, 4));
					LET	cFechPresFinR = TRIM(SUBSTR(cFechPresS, 7, 2) || '/' || SUBSTR(cFechPresS, 5, 2) || '/' || SUBSTR(cFechPresS, 1, 4));

					RETURN cCodRet, TRIM(cDescError), cFechPresFinR, pNomArchivo, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal WITH RESUME;

				END FOREACH;
			ELSE
				LET cCodRet = "02604"; -- ERROR EN LA ESTRUCTURA DEL NOMBRE DEL ARCHIVO
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal;
			END IF;
		ELSE
			LET cCodRet = "02605"; -- ERROR EN LA ASIGNACION DE PARAMETROS: NO SE PUEDE GENERAR POR ARCHIVO + FECHA(S) -- no se puede ejecutar nombre de archivo con fechaS
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
			RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal;
		END IF;

	ELIF iTipoOp = 2 OR iTipoOp = 5 THEN -- CONSULTA POR NOMBRE DEL PROCESO
		IF pfecini <> "" AND pfecfin <> "" THEN

			-- SE FORMATEAN LAS FECHAS RECIBIDAS PARA CAMBIARLAS A 'YYYYMMDD' (SIN DIAGONALES) PARA INCLUIRLAS EN EL WHERE
			LET cFecInicioW = SUBSTR(pfecini, 7, 4) || SUBSTR(pfecini, 1, 2) || SUBSTR(pfecini, 4, 2);
			LET cFecFinW = SUBSTR(pfecfin, 7, 4) || SUBSTR(pfecfin, 1, 2) || SUBSTR(pfecfin, 4, 2);

			IF pTpoProc = 2 THEN -- REPORTE PRESENTADO
				LET cTipoP = 'E';
			ELIF pTpoProc = 5 THEN -- REPORTE RECIBIDO
				LET cTipoP = 'S';
			END IF;

			IF NOT EXISTS (SELECT 1 FROM bdidomi:dom_cce_detalle WHERE cod_operacion = '30' AND fecha_presentacion BETWEEN cFecInicioW AND cFecFinW
																						    AND nombre_arch LIKE cTipoP || '%') THEN
				LET cCodRet = "02603"; -- EL ARCHIVO NO EXISTE
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal;
			END IF;
--det.num_cta_rec
			FOREACH WITH HOLD

				SELECT SKIP pregistros FIRST precuperacion
					 TRIM(det.fecha_presentacion), TRIM(det.nombre_arch),
					 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.nombre_ord) ELSE TRIM(det.nombre_rec) END,
					 TRIM(ser.razon_social), TRIM(det.ref_numerica), TRIM(det.importe), 
					 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.num_cta_ord) ELSE TRIM(det.num_cta_rec) END,
					 TRIM(det.num_secuencia), TRIM(det.tipo_cta_rec),
					 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.banco_receptor) ELSE TRIM(det.banco_receptor) END,
					 TRIM(det.fecha_pres_ini), TRIM(stap.descripcion), TRIM(det.cve_estatus),det.tipo_registro,det.num_secuencia
				INTO cFechPresS, cNomArch,
				     cNomOrd,
					 cServ, cRef, cImp, cCtaDest, cSec, cTipoCtaCod,
					 cBancDestCod,
					 cFechIniS, cStatus, cStat_val,cTipo_registro,cNum_secuencia
				FROM bdidomi:dom_cce_detalle det
				INNER JOIN bdidomi:dom_cat_servicios ser ON det.rfc_ord = ser.rfc
				INNER JOIN bdidomi:dom_status_pago stap ON det.cve_estatus = stap.cve_status
				WHERE cod_operacion = '34'
				AND fecha_presentacion BETWEEN cFecInicioW AND cFecFinW
				AND det.nombre_arch LIKE cTipoP || '%'

				SELECT TRIM(descripcion)
				INTO cTpoCta
				FROM bdidomi:dom_tipo_cta
				WHERE tipo_cta = cTipoCtaCod;
				
				SELECT TRIM(sucursal_sol)
				INTO cSucursal
				FROM bdidomi:dom_reversos
				WHERE nom_archivo_rev = cNomArch 
					AND fecha_presentacion_rev = cFechPresS
					AND tipo_registro = cTipo_registro
					AND num_secuencia = cNum_secuencia;

				SELECT TRIM(vchrnombrecorto)
				INTO cBancDest
				FROM bdinteg:si_bancos
				WHERE banco = cBancDestCod;

				LET mImp2 = cImp / 100;
				LET cFechOrig = TRIM(SUBSTR(cFechIniS, 7, 2) || '/' || SUBSTR(cFechIniS, 5, 2) || '/' || SUBSTR(cFechIniS, 1, 4));
				LET	cFechPresFinR = TRIM(SUBSTR(cFechPresS, 7, 2) || '/' || SUBSTR(cFechPresS, 5, 2) || '/' || SUBSTR(cFechPresS, 1, 4));

				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal WITH RESUME;

			END FOREACH;

		ELSE
			LET cCodRet = '02606'; -- ERROR EN LA GENERACION DEL REPORTE POR TIPO DE PROCESO: FALTAN FECHA INICIO Y/O FECHA FINAL
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
			RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal;
		END IF;
	ELSE
		LET cCodRet = '02609'; -- TIPO DE OPERACION NO VALIDA PARA LA GENERACION DE REPORTES ARCHIVO 34 - VALORES 2 o 5
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal;
	END IF;
END
END PROCEDURE
DOCUMENT
'AUTOR: Clemente Angulo Ballardo',
'DESCRIPCION: Procedimiento que genera el reporte de los archivos codigo 34, ya sean presentados o recibidos',
'FECHA: 14/08/2009',
'VERSION: 20090814.1640',
'BD: Bdidomi',
'MODIFICO: Antonio Bastidas',
'DESCRIPCION: Se agrego el parametro de sucursal obtenido de la dom_reversos',
'FECHA: 24/08/2009',
'VERSION: 20090824.1115',
'BD: Bdidomi',
'Modifico: CÃ©sar ValdÃ©z Figueroa',
'Descripcion: Se modificaron los filtros de obtenian la sucursal, ademas que se intercambiaron unos datos como banco ordenate por receptor',
'Fecha: 2009/09/27',
'Version: 20090929.1000',
'BD: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_genrepservicios2 (pServicio char(18),pSucursal char(4),pFechaIni char(10),pFechaFin char(10), pregistros INTEGER, precuperacion INTEGER)
RETURNING char(6),char(80),char(10),char(20),char(80),char(20),char(60),char(4),char(20),money(16,2),smallint;
--RETURNING char(6),char(80),char(10),char(20),char(80),char(20),char(20),char(4),char(20),money(16,2),integer,integer,char(2);

-- VARIABLES PARA MANEJO DE ERRORES
DEFINE vcodRet 				char(6); 	 		-- CODIGO DE RETORNO
DEFINE vsqlerr 				integer;		 	-- VARIABLE PARA CACHAR EL CODIGO DE ERRORDEFINE vsqlerr integer;
DEFINE iIsamErr 			smallint;	 		-- VARIABLE PARA CACHAR EL CODIGO DE ERROR
DEFINE cErrorInfo 			char(80);  			-- VARIABLE PARA CACHAR LA DESCRIPCION DEL ERROR
DEFINE vErrorInfo 			char(80);	 		-- VARIABLE PARA RETORNAR EL MENSAJE DE ERROR O MENSAJE DE EXITO
DEFINE cCodRetMensaje		char(6);			-- CODIGO DE ERROR QUE REGRESA EL SP sp_obtenermensajeerror

-- VARIABLES PARA RETORNAR LOS VALORES
DEFINE cFechaAplica			char(10);			-- FECHA DE APLICACION
DEFINE cNumCte				char(20);			-- NUMERO DE CLIENTE
DEFINE cNomCte				char(80);			-- NOMBRE DEL CLIENTE
DEFINE cCuenta				char(20);			-- CUENTA
DEFINE cServicio			char(60);			-- SERVICIO
DEFINE cSucursal			char(4);			-- SUCURSAL
DEFINE cEstatus				char(20);			-- ESTATUS DEL SERVICIO
DEFINE mMontoMaximo			money(16,2);		-- MONTO MAXIMO
DEFINE cRFC					char(20);			-- RFC
DEFINE cMensaje				char(200);			-- RFC

-- VARIABLES DE AYUDA
DEFINE sNumReg				smallint;			-- PARA VER SI EXISTEN REGISTROS
DEFINE cFechaAux			char(10);			-- FECHA AUXILIAR
DEFINE sNumCve				smallint;			-- PARA CONTABILIZAR LOS REGISTROS EN EL REPORTE

LET vcodRet 				= '00000';
LET vsqlerr 				= 0;
LET iIsamErr 				= 0;
LET cErrorInfo 				= "";
LET vErrorInfo 				= "PROCESO EXITOSO";
LET cCodRetMensaje			= "";

LET cFechaAplica			= "";
LET cNumCte					= "";
LET cNomCte					= "";
LET cCuenta					= "";
LET cServicio				= "";
LET cSucursal				= "";
LET cEstatus				= "";
LET mMontoMaximo			= 0;

LET sNumReg					= 0;
LET cFechaAux				= "";
LET sNumCve					= 0;
LET cRFC					= '';

begin

	ON EXCEPTION  SET vsqlerr, iIsamErr, cErrorInfo
		IF vsqlerr <> 0  THEN
			LET  vCodRet  = vsqlerr;
			LET vErrorInfo = cErrorInfo;
			RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve;
		END IF;
	END  EXCEPTION


 --set debug file to "/tmp/Pulido/PRUEBAPUL.out";
 --trace on;


	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO wait 4;
	
	if pServicio = "" or pSucursal = "" then
		LET vCodRet = '02611';
		CALL sp_obtenermensajeerror (vCodRet) RETURNING cCodRetMensaje,vErrorInfo;
		RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve;
	end if
	
	-- SE VALIDA SI SERVICIO Y SUCURSAL TRAEN EL VALOR "TODOS" ENTONCES SOLO SE FILTRA POR EL RANGO DE FECHAS
	if pServicio = "1" and pSucursal = "0000" then
		-- SE VALIDA SI EXISTEN REGISTROS EN LA TABLA CON LOSFILTROS SELECCIONADOS
		SELECT limit 1 fecha_estatus into cFechaAux from bdidomi:dom_autorizaciones where fecha_estatus between pFechaIni and pFechaFin;
		LET sNumReg=dbinfo("sqlca.sqlerrd2");
		if sNumReg > 0 then
			FOREACH
				select skip pregistros first precuperacion a.fecha_estatus,a.num_cte,trim(c.nombre1) || ' ' || trim(c.nombre2) || ' ' || trim(c.apell_paterno) || ' ' || trim(c.apell_materno) as Cliente,
					a.cuenta,nvl(s.razon_social,'') as servicio,a.cve_sucursal,
					(select descripcion from bdidomi:dom_cat_estatusaut where cve_estatus=a.cve_estatus) as Estatus,a.imp_maximo,1
				into cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve	
				from bdidomi:dom_autorizaciones a
					inner join bdinteg:si_cliente c on c.numcte=a.num_cte
					left join bdidomi:dom_cat_servicios s on s.rfc=a.rfc
				where a.fecha_estatus between pFechaIni and pFechaFin
				order by a.fecha_estatus
				
				RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve WITH RESUME;
				
			END FOREACH;
		else
			LET vCodRet = '02610';
			CALL sp_obtenermensajeerror (vCodRet) RETURNING cCodRetMensaje,vErrorInfo;
			RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve;
		
		end if;
		
		
	-- SE VALIDA SI SERVICIO ES DIFERENTE DE "TODOS" Y SUCURSAL TRAE EL VALOR "TODOS" ENTONCES SE FILTRA POR SERVICIO y RANGO DE FECHAS
	elif pServicio <> "1" and pSucursal = "0000" then
		--SE OBTIENE EL RFC DEL NOMBRE CORTO QUE SE RECIBE
		SELECT limit 1 rfc  INTO cRFC FROM bdidomi:dom_cat_servicios WHERE razon_social = TRIM(pServicio);
		-- SE VALIDA SI EXISTEN REGISTROS EN LA TABLA CON LOSFILTROS SELECCIONADOS
		SELECT limit 1 fecha_estatus into cFechaAux from bdidomi:dom_autorizaciones 
		where rfc = TRIM(cRFC) and fecha_estatus between pFechaIni and pFechaFin;
		LET sNumReg=dbinfo("sqlca.sqlerrd2");
		if sNumReg > 0 then
			FOREACH
				select skip pregistros first precuperacion a.fecha_estatus,a.num_cte,trim(c.nombre1) || ' ' || trim(c.nombre2) || ' ' || trim(c.apell_paterno) || ' ' || trim(c.apell_materno) as Cliente,
					a.cuenta,nvl(s.razon_social,'') as servicio,a.cve_sucursal,
					(select descripcion from bdidomi:dom_cat_estatusaut where cve_estatus=a.cve_estatus) as Estatus,a.imp_maximo,1
				into cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve
				from bdidomi:dom_autorizaciones a
					inner join bdinteg:si_cliente c on c.numcte=a.num_cte
					left join bdidomi:dom_cat_servicios s on s.rfc=a.rfc
				where s.rfc = TRIM(cRFC) and a.fecha_estatus between pFechaIni and pFechaFin
				order by a.fecha_estatus
				
				RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve WITH RESUME;
				
			END FOREACH;
		else
			LET vCodRet = '02610';
			CALL sp_obtenermensajeerror (vCodRet) RETURNING cCodRetMensaje,vErrorInfo;
			RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve;
		end if;
	-- SE VALIDA SI SUCURSAL ES DIFERENTE AL VALOR "TODOS" Y SERVICIO TRAE EL VALOR "TODOS" ENTONCES SE FILTRA POR SUCURSAL y RANGO DE FECHAS
	elif pServicio = "1" and pSucursal <> "0000" then
		-- SE VALIDA SI EXISTEN REGISTROS EN LA TABLA CON LOSFILTROS SELECCIONADOS
		SELECT limit 1 fecha_estatus into cFechaAux from bdidomi:dom_autorizaciones 
		where cve_sucursal = pSucursal and fecha_estatus between pFechaIni and pFechaFin;
		LET sNumReg=dbinfo("sqlca.sqlerrd2");
		if sNumReg > 0 then
			FOREACH
				select skip pregistros first precuperacion a.fecha_estatus,a.num_cte,trim(c.nombre1) || ' ' || trim(c.nombre2) || ' ' || trim(c.apell_paterno) || ' ' || trim(c.apell_materno) as Cliente,
					a.cuenta,nvl(s.razon_social,'') as servicio,a.cve_sucursal,
					(select descripcion from bdidomi:dom_cat_estatusaut where cve_estatus=a.cve_estatus) as Estatus,a.imp_maximo,1
				into cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve
				from bdidomi:dom_autorizaciones a
					inner join bdinteg:si_cliente c on c.numcte=a.num_cte
					left join bdidomi:dom_cat_servicios s on s.rfc=a.rfc
				where a.cve_sucursal = pSucursal and a.fecha_estatus between pFechaIni and pFechaFin
				order by a.fecha_estatus
				
				RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve WITH RESUME;
				
			END FOREACH;
		else
			LET vCodRet = '02610';
			CALL sp_obtenermensajeerror (vCodRet) RETURNING cCodRetMensaje,vErrorInfo;
			RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve;
		end if;
	
		
	-- SE VALIDA SI SUCURSAL Y SERVICIO SON DIFERENTES AL VALOR "TODOS" ENTONCES SE FILTRA POR SUCURSAL y RANGO DE FECHAS
	elif pServicio <> "1" and pSucursal <> "0000" then
		--SE OBTIENE EL RFC DEL NOMBRE CORTO QUE SE RECIBE
		SELECT limit 1 rfc  INTO cRFC FROM bdidomi:dom_cat_servicios WHERE razon_social = TRIM(pServicio);
		-- SE VALIDA SI EXISTEN REGISTROS EN LA TABLA CON LOS FILTROS SELECCIONADOS
		SELECT limit 1 fecha_estatus into cFechaAux from bdidomi:dom_autorizaciones 
		where rfc = TRIM(cRFC) and cve_sucursal = pSucursal and fecha_estatus between pFechaIni and pFechaFin;
		LET sNumReg=dbinfo("sqlca.sqlerrd2");
		if sNumReg > 0 then
			FOREACH
				select skip pregistros first precuperacion a.fecha_estatus,a.num_cte,trim(c.nombre1) || ' ' || trim(c.nombre2) || ' ' || trim(c.apell_paterno) || ' ' || trim(c.apell_materno) as Cliente,
					a.cuenta,nvl(s.razon_social,'') as servicio,a.cve_sucursal,
					(select descripcion from bdidomi:dom_cat_estatusaut where cve_estatus=a.cve_estatus) as Estatus,a.imp_maximo,1
				into cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve
				from bdidomi:dom_autorizaciones a
					inner join bdinteg:si_cliente c on c.numcte=a.num_cte
					left join bdidomi:dom_cat_servicios s on s.rfc=a.rfc
				where s.rfc = TRIM(cRFC) and a.cve_sucursal = pSucursal and a.fecha_estatus between pFechaIni and pFechaFin
				order by a.fecha_estatus
				
				RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve WITH RESUME;
				
			END FOREACH;
		else
			LET vCodRet = '02610';
			CALL sp_obtenermensajeerror (vCodRet) RETURNING cCodRetMensaje,vErrorInfo;
			RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve;
		end if;
		
	end if;

end;
END PROCEDURE
DOCUMENT
'AUTOR: Jose Luis Pulido Zepeda',
'Descripcion: Regresa los datos para el reporte de Servicios Domiciliarios',
'Fecha: 2009/08/19',
'Version: 20090819.1802',
'BD: BDIDOMI',

'Modifico: Jose Luis Pulido Zepeda',
'Descripcion: Se agrego ordenamiento por la fecha de aplicacion, un conteo de los diferentes estatus, mensajes de error controlados,',
			  'tambien se cambio el tipo de dato a char(10) a los parametros de entrada de fecha',
'Fecha: 2009/08/21',
'Version: 20090821.1003',
'BD: BDIDOMI',

'Modifico: Jose Luis Pulido Zepeda',
'Descripcion: Se cambio al valor que el SP toma para mostrar todos los registros para los filtros de servicio y sucursal,',
'			  para el filtro de servicio cuando se recibe el valor de 1 significa que se mostraran todos los servicios,',
'			  para el filtro de sucursal cuando se recibe el valor de 0000 significa que se mostraran todas las sucursales.',
'Fecha: 2009/08/24',
'Version: 20090824.0951',
'BD: BDIDOMI',

'Modifico: CÃ©sar ValdÃ©z Figueroa',
'Descripcion: Se cambio para que cuando se fuera a filtrar por sucursal, se filtrara por el nombre corto que es lo que realmente recibe,',
'Fecha: 2009/09/24',
'Version: 20090924.1300',
'BD: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_subirarchivosproveedor(p_NombreArchivo VARCHAR(23), p_FechaEnvio DATE, p_NumCte VARCHAR(20), p_FechaCarga DATE, p_CveStatus CHAR(2), p_Usuario CHAR(8))
RETURNING
	CHAR(5), ---cod_ret
	CHAR(80); ---descripcion

	---DECLARACIONES
    DEFINE v_cod_ret            	CHAR(5);
    DEFINE iSqlErr              	INTEGER;
    DEFINE iSamErr              	INTEGER;

	DEFINE sDescMensajeError		VARCHAR(95);
	DEFINE sRuta					CHAR(100);
	DEFINE sCadSql					LVARCHAR(1000);
	DEFINE sLinea					LVARCHAR(500);
	DEFINE bBandArchivo				BOOLEAN;
	DEFINE iNumCaracteres			INTEGER;
	DEFINE iContador				SMALLINT;
	DEFINE iNumReg					INTEGER;

	DEFINE sEncTipoReg				CHAR(1);
	DEFINE sEncNumCte				CHAR(20);
	DEFINE sEncCtaAbono				CHAR(20);
	DEFINE sEncNumOper				CHAR(8);
	DEFINE sEncFechaIni				CHAR(8);
	DEFINE sEncFechaFin				CHAR(8);

	DEFINE sDetTipoReg				CHAR(1);
	DEFINE sDetConsecutivo			CHAR(6);
	DEFINE sDetFechaCargo			CHAR(8);
	DEFINE sDetFechaAbono			CHAR(8);
	DEFINE sDetTipoCtaCargo			CHAR(2);
	DEFINE sDetCveBancoCargo		CHAR(3);
	DEFINE sDetCtaCargo				CHAR(20);
	DEFINE sDetRFC_Cargo			CHAR(13);
	DEFINE sDetNomCargo				CHAR(50);
	DEFINE sDetCtaAbono				CHAR(20);
	DEFINE sDetImpOper				CHAR(15);
	DEFINE sDetImpIva				CHAR(15);
	DEFINE sDetRefNumerica			CHAR(7);
	DEFINE sDetRefLeyenda			CHAR(40);
	DEFINE sDetRefServicio			CHAR(40);
	DEFINE sDetRefTituServ			CHAR(40);
	DEFINE sDetAccion				CHAR(1);
	DEFINE sDetReintentarCta		CHAR(1);
	DEFINE sDetEstatus				CHAR(2);
	DEFINE sDetCausaRechazo			CHAR(50);

	DEFINE sSumTipoReg				CHAR(1);
	DEFINE sSumNumOper				CHAR(8);
	DEFINE sSumImpOper				CHAR(18);
	DEFINE sSumNumOperPend			CHAR(8);
	DEFINE sSumImpOperPend			CHAR(18);
	DEFINE sSumNumOperApli			CHAR(8);
	DEFINE sSumImpOperApli			CHAR(18);
	DEFINE sSumNumOperRecha			CHAR(8);
	DEFINE sSumImpOperRecha			CHAR(18);

	DEFINE sDia						CHAR(2);
	DEFINE sMes						CHAR(2);
	DEFINE sAnio					CHAR(4);

	DEFINE cHora					CHAR(8);
	DEFINE cFechaArchivoOUT			CHAR(15);
	DEFINE iTemporales				SMALLINT;
	DEFINE iPaso					SMALLINT;
	DEFINE cRutaIfx					CHAR(100);
	---INICIALIZACIONES
	LET v_cod_ret = '00000';
	LET sDescMensajeError	= "";
	LET sRuta						= "";
	LET sLinea						= "";
	LET sDescMensajeError			= "";
	LET bBandArchivo				= "f";
	LET iNumCaracteres				= 0;
	LET iContador					= 0;
	LET iNumReg						= 0;

	LET sEncTipoReg					= "";
	LET sEncNumCte					= "";
	LET sEncCtaAbono				= "";
	LET sEncNumOper					= "";
	LET sEncFechaIni				= "";
	LET sEncFechaFin				= "";

	LET sDetTipoReg					= "";
	LET sDetConsecutivo				= "";
	LET sDetFechaCargo				= "";
	LET sDetFechaAbono				= "";
	LET sDetTipoCtaCargo			= "";
	LET sDetCveBancoCargo			= "";
	LET sDetCtaCargo				= "";
	LET sDetRFC_Cargo				= "";
	LET sDetNomCargo				= "";
	LET sDetCtaAbono				= "";
	LET sDetImpOper					= "";
	LET sDetImpIva					= "";
	LET sDetRefNumerica				= "";
	LET sDetRefLeyenda				= "";
	LET sDetRefServicio				= "";
	LET sDetRefTituServ				= "";
	LET sDetAccion					= "";
	LET sDetReintentarCta			= "";
	LET sDetEstatus					= "";
	LET sDetCausaRechazo			= "";

	LET sSumTipoReg					= "";
	LET sSumNumOper					= "";
	LET sSumImpOper					= "";
	LET sSumNumOperPend				= "";
	LET sSumImpOperPend				= "";
	LET sSumNumOperApli				= "";
	LET sSumImpOperApli				= "";
	LET sSumNumOperRecha			= "";
	LET sSumImpOperRecha			= "";

	LET sDia						= "";
	LET sMes						= "";
	LET sAnio						= "";

	LET cHora						= TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
	LET cFechaArchivoOUT			= YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_';
	LET iTemporales					= 0;
	LET iPaso						= 0;
	LET cRutaIfx	= '';
	
BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;

        RETURN v_cod_ret, NULL;
    END EXCEPTION;

	ON EXCEPTION IN(-668) SET iSqlErr
		IF  iPaso NOT IN (4,5,6,9,10) THEN 
			LET v_cod_ret = iSqlErr;
			RETURN v_cod_ret,NULL;
		END IF;
		
	END EXCEPTION WITH RESUME;
	--SET DEBUG FILE TO "/home/sysdomi/sp_Domi_SubirArchivosProveedor.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--- OBTIENE LA RUTA DONDE SE ENCUENTRA EL ARCHIVO
	SELECT TRIM(valor)
	INTO sRuta
	FROM bdidomi: dom_parametros
	WHERE cod_param = "16";
	
	SELECT TRIM(valor)
	INTO cRutaIfx
	FROM bdidomi: dom_parametros
	WHERE cod_param = "44";	

	IF (sRuta IS NULL) OR (sRuta = "")THEN
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02400") INTO v_cod_ret, sDescMensajeError;
		RETURN v_cod_ret, sDescMensajeError;
	END IF

	IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'dom_tmp_trabajo_proveedor') THEN
		DROP TABLE dom_tmp_trabajo_proveedor;
	END IF

	--- CREAR LA TABLA DE TRABAJO
	CREATE TABLE dom_tmp_trabajo_proveedor
	(linea LVARCHAR(500));

	--- GUARDA LOS NOMBRES DE LOS ARCHIVOS EXISTENTES EN LA RUTA EL CARPETA.CAR
	LET iPaso = 1;
	LET sCadSql = 'ls ' || TRIM(sRuta) || ' > ' || TRIM(sRuta) ||cFechaArchivoOUT||'.car';
	SYSTEM sCadSql;
		
	--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
	LET iPaso = 2;
	LET sCadSql = 'echo "LOAD FROM ' || TRIM(sRuta) || cFechaArchivoOUT||'.car' || ' INSERT INTO dom_tmp_trabajo_proveedor" > '|| TRIM(sRuta) || cFechaArchivoOUT || '.sql';
	SYSTEM sCadSql;

	--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
	LET iPaso = 3;
	--PRODUCCION
	LET sCadSql = TRIM(cRutaIfx)||' bdidomi ' || TRIM(sRuta) || cFechaArchivoOUT ||'.sql > '||TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
	--DESARROLLO
	--LET sCadSql = '/informix/bin/dbaccess bdidomi ' || TRIM(sRuta) || cFechaArchivoOUT ||'.sql > '||TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
	SYSTEM sCadSql;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--- CICLO PARA BUSCAR EL NOMBRE DEL ARCHIVO
	FOREACH
		SELECT linea
		INTO sLinea
		FROM dom_tmp_trabajo_proveedor

		IF sLinea = p_NombreArchivo THEN
			LET bBandArchivo = "t";
			EXIT FOREACH;
		END IF;
	END FOREACH;

	--- BORRAR LA TABLA PARA VOLVER A USARLA
	TRUNCATE TABLE dom_tmp_trabajo_proveedor;

	LET iPaso = 4;
	LET sCadSql = 'rm ' || TRIM(sRuta) || cFechaArchivoOUT||'.car';
	SYSTEM sCadSql;
	
	--- BORRA EL ARCHIVO .SQL
	LET iPaso = 5;
	LET sCadSql = 'rm ' || TRIM(sRuta) ||TRIM(cFechaArchivoOUT)||'.sql';
	SYSTEM sCadSql;

	LET iPaso = 6;
	LET sCadSql = 'rm ' || TRIM(sRuta) ||TRIM(cFechaArchivoOUT)||'.out';
	SYSTEM sCadSql;
		
	--- VALIDA QUE EL ARCHIVO EXISTA
	IF bBandArchivo = "f" THEN
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02401") INTO v_cod_ret, sDescMensajeError;
		RETURN v_cod_ret, sDescMensajeError;
	ELSE
		--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
		LET iPaso = 7;
		LET sCadSql = 'echo "LOAD FROM ' || TRIM(sRuta) || p_NombreArchivo || ' INSERT INTO dom_tmp_trabajo_proveedor" > '|| TRIM(sRuta) ||TRIM(cFechaArchivoOUT)|| '.sql';
		SYSTEM sCadSql;

		--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
		
		LET iPaso = 8;
		--PRODUCCION
		LET sCadSql = TRIM(cRutaIfx)||' bdidomi ' || TRIM(sRuta) || cFechaArchivoOUT ||'.sql > '||TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
		
		--DESARROLLO
		--LET sCadSql = '/informix/bin/dbaccess bdidomi ' || TRIM(sRuta) || cFechaArchivoOUT ||'.sql > '||TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';

		SYSTEM sCadSql;
		
		LET iPaso = 9;
		LET sCadSql = 'rm ' || TRIM(sRuta) ||TRIM(cFechaArchivoOUT)||'.sql';
		SYSTEM sCadSql;

		LET iPaso = 10;
		LET sCadSql = 'rm ' || TRIM(sRuta) ||TRIM(cFechaArchivoOUT)||'.out';
		SYSTEM sCadSql;

		--- VALIDA QUE NO EXISTAN TIPOS DE REGISTROS AJENOS A LOS AUTORIZADOS
		IF EXISTS(SELECT linea FROM bdidomi: dom_tmp_trabajo_proveedor WHERE SUBSTR(linea,1,1) NOT IN ("E","D","S")) THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02402") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		END IF

		LET iNumReg		= 0;
		--- OBTENER EL NUMERO DE REGISTROS DE ENCABEZADO
		SELECT COUNT(*)::INTEGER
		INTO iNumReg
		FROM  dom_tmp_trabajo_proveedor
		WHERE SUBSTR(linea,1,1) = "E";

		IF iNumReg = 0 THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02403") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		ELIF iNumReg > 1 THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02404") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		END IF

		LET iNumReg		= 0;
		--- OBTENER EL NUMERO DE REGISTROS DE SUMARIO
		SELECT COUNT(*)::INTEGER
		INTO iNumReg
		FROM  dom_tmp_trabajo_proveedor
		WHERE SUBSTR(linea,1,1) = "S";

		IF iNumReg = 0 THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02405") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		ELIF iNumReg > 1 THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02406") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		END IF

		LET iNumReg		= 0;
		--- OBTENER EL NUMERO DE REGISTROS DE DETALLE
		SELECT COUNT(*)::INTEGER
		INTO iNumReg
		FROM  dom_tmp_trabajo_proveedor
		WHERE SUBSTR(linea,1,1) = "D";

		IF iNumReg = 0 THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02407") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		END IF

		--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
		IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'dom_tmp_secuencia_aut') THEN
			DROP TABLE dom_tmp_secuencia_aut;
		END IF

		--- CUENTA LA LONGITUD DE CARACTERES DE LAS CADENAS EN LA TABLA
		SELECT LENGTH(REPLACE(linea," ","*"))
		INTO iNumCaracteres
		FROM dom_tmp_trabajo_proveedor
		WHERE SUBSTR(linea,1,1) = "E";

		--- VALIDA LA LONGITUD DE LA LINEA DE ENCABEZADO
		IF iNumCaracteres NOT IN (65,66)  THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02408") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		END IF

		--- CUENTA LA LONGITUD DE CARACTERES DE LAS CADENAS EN LA TABLA
		SELECT LENGTH(REPLACE(linea," ","*"))
		INTO iNumCaracteres
		FROM dom_tmp_trabajo_proveedor
		WHERE SUBSTR(linea,1,1) = "S";

		--- VALIDA LA LONGITUD DE LA LINEA DE SUMARIO
		IF iNumCaracteres NOT IN (105,106)  THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02409") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		END IF

		LET iContador = 0;

		FOREACH
			--- CUENTA LA LONGITUD DE CARACTERES DE LAS CADENAS EN LA TABLA
			SELECT DISTINCT LENGTH(REPLACE(linea," ","*"))
			INTO iNumCaracteres
			FROM dom_tmp_trabajo_proveedor
			WHERE SUBSTR(linea,1,1) = "D"

			LET iContador = iContador + 1;
		END FOREACH
		--- VALIDA QUE NO EXISTAN DIFERENTES LONGITUDES EN LA TABLA
		IF iContador > 1 THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02410") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		--- VALLIDA QUE SI EXISTE EL MISMO NUMERO DE CARACTERES POR LINEA ESTE SEA EL ADECUADO
		ELIF iContador = 1 AND iNumCaracteres NOT IN (342,343)  THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02410") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		END IF

		--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
		IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'dom_tmp_secuencia_prov') THEN
			DROP TABLE dom_tmp_secuencia_prov;
		END IF

		--- CREAR LA TABLA DE TRABAJO
		CREATE TABLE dom_tmp_secuencia_prov
		(secuencia CHAR(6));

		INSERT INTO dom_tmp_secuencia_prov
		SELECT SUBSTR(linea,2,6) AS SECUENCIA
		FROM bdidomi: dom_tmp_trabajo_proveedor
		WHERE SUBSTR(linea,1,1) = "D";
		---VERIFICAR QUE NO VENGAN REPETIDOS LOS NUMEROS DE SECUENCIA
		IF EXISTS(SELECT SECUENCIA FROM dom_tmp_secuencia_prov GROUP BY SECUENCIA HAVING COUNT(*) > 1) THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02411") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		END IF

		INSERT INTO bdidomi: dom_cte_archivos(nombre_arch, fecha_envio, num_cte, fecha_carga, cve_status, user_insert, fecha_insert)
		VALUES(p_NombreArchivo, p_FechaEnvio, p_NumCte, p_FechaCarga, p_CveStatus, p_Usuario, CURRENT);

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT linea
			INTO sLinea
			FROM dom_tmp_trabajo_proveedor

			IF SUBSTR(sLinea,1,1) = "E" THEN --- ASIGNACIONES PARA ENCABEZADO
				LET sEncTipoReg					= SUBSTR(sLinea,1,1);
				LET sEncNumCte					= SUBSTR(sLinea,2,20);
				LET sEncCtaAbono				= SUBSTR(sLinea,22,20);
				LET sEncNumOper					= SUBSTR(sLinea,42,8);
				LET sEncFechaIni				= SUBSTR(sLinea,50,8);
				LET sEncFechaFin				= SUBSTR(sLinea,58,8);

				INSERT INTO bdidomi: dom_cte_encabezado (nombre_arch,fecha_envio,tipo_registro,num_cte,cuenta_abono,num_operaciones
														,fecha_inicial,fecha_final,user_insert,fecha_insert)
				VALUES (p_NombreArchivo,p_FechaEnvio,sEncTipoReg,sEncNumCte,sEncCtaAbono,sEncNumOper,sEncFechaIni,sEncFechaFin,p_Usuario,CURRENT);

			ELIF SUBSTR(sLinea,1,1) = "D" THEN --- ASIGNACIONES PARA DETALLE
				LET sDetTipoReg					= SUBSTR(sLinea,1,1);
				LET sDetConsecutivo				= SUBSTR(sLinea,2,6);
				LET sDetFechaCargo				= SUBSTR(sLinea,8,8);
				LET sDetFechaAbono				= SUBSTR(sLinea,16,8);
				LET sDetTipoCtaCargo			= SUBSTR(sLinea,24,2);
				LET sDetCveBancoCargo			= SUBSTR(sLinea,26,3);
				LET sDetCtaCargo				= SUBSTR(sLinea,29,20);
				LET sDetRFC_Cargo				= SUBSTR(sLinea,49,13);
				LET sDetNomCargo				= SUBSTR(sLinea,62,50);
				LET sDetCtaAbono				= SUBSTR(sLinea,112,20);
				LET sDetImpOper					= SUBSTR(sLinea,132,15);
				LET sDetImpIva					= SUBSTR(sLinea,147,15);
				LET sDetRefNumerica				= SUBSTR(sLinea,162,7);
				LET sDetRefLeyenda				= SUBSTR(sLinea,169,40);
				LET sDetRefServicio				= SUBSTR(sLinea,209,40);
				LET sDetRefTituServ				= SUBSTR(sLinea,249,40);
				LET sDetAccion					= SUBSTR(sLinea,289,1);
				LET sDetReintentarCta			= SUBSTR(sLinea,290,1);
				LET sDetEstatus					= SUBSTR(sLinea,291,2);
				LET sDetCausaRechazo			= SUBSTR(sLinea,293,50);
				/*
				LET sDia						= SUBSTR(sDetFechaCargo,1,2);
				LET sMes						= SUBSTR(sDetFechaCargo,3,2);
				LET sAnio						= SUBSTR(sDetFechaCargo,5,4);
				LET sDetFechaCargo				= sAnio || sMes || sDia;

				LET sDia						= SUBSTR(sDetFechaAbono,1,2);
				LET sMes						= SUBSTR(sDetFechaAbono,3,2);
				LET sAnio						= SUBSTR(sDetFechaAbono,5,4);
				LET sDetFechaAbono				= sAnio || sMes || sDia;*/

				INSERT INTO bdidomi: dom_cte_detalle (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo
							,cve_banco_cargo,cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda
							,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,estatus,causa_rechazo,nombre_arch_cce,fecha_presentacion_cce
							,tipo_registro_cce,numero_secuencia_cce,comision_cobrada,iva_cobrado,user_insert,fecha_insert)
				VALUES (p_NombreArchivo,p_FechaEnvio,sDetTipoReg,sDetConsecutivo,sDetFechaCargo,sDetFechaAbono,sDetTipoCtaCargo,sDetCveBancoCargo
						,sDetCtaCargo,sDetRFC_Cargo,sDetNomCargo,sDetCtaAbono,sDetImpOper,sDetImpIva,sDetRefNumerica,sDetRefLeyenda,sDetRefServicio,sDetRefTituServ,sDetAccion
						,sDetReintentarCta,sDetEstatus,sDetCausaRechazo,NULL,NULL,NULL,NULL,NULL,NULL,p_Usuario,CURRENT);

			ELIF SUBSTR(sLinea,1,1) = "S" THEN--- ASIGNACIONES PARA SUMARIO
				LET sSumTipoReg					= SUBSTR(sLinea,1,1);
				LET sSumNumOper					= SUBSTR(sLinea,2,8);
				LET sSumImpOper					= SUBSTR(sLinea,10,18);
				LET sSumNumOperPend				= SUBSTR(sLinea,28,8);
				LET sSumImpOperPend				= SUBSTR(sLinea,36,18);
				LET sSumNumOperApli				= SUBSTR(sLinea,54,8);
				LET sSumImpOperApli				= SUBSTR(sLinea,62,18);
				LET sSumNumOperRecha			= SUBSTR(sLinea,80,8);
				LET sSumImpOperRecha			= SUBSTR(sLinea,88,18);

				INSERT INTO bdidomi: dom_cte_sumario (nombre_arch,fecha_envio,tipo_registro,num_operaciones,imp_operaciones,num_oper_pend
							,imp_oper_pend,num_oper_apli,imp_oper_apli,num_oper_rech,imp_oper_rech,user_insert,fecha_insert)
				VALUES (p_NombreArchivo,p_FechaEnvio,sSumTipoReg,sSumNumOper,sSumImpOper,sSumNumOperPend,sSumImpOperPend
						,sSumNumOperApli,sSumImpOperApli,sSumNumOperRecha,sSumImpOperRecha,p_Usuario,CURRENT);
			END IF
		END FOREACH
	END IF

	RETURN v_cod_ret, sDescMensajeError;
END;
--##############################################################################
--## Procedimiento   : sp_Domi_SubirArchivosProveedor
--## Version         : 1.0
--## Creado por      : Mohamed CarreÃ?Â³n
--## Fecha creacion  : Agosto de 2009
--##Descripcion :
--##############################################################################
END PROCEDURE;