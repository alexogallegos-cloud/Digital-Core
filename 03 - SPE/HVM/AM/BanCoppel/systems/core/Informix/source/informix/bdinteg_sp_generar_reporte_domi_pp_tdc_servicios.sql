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
							SELECT a.razon_social AS comercio, UPPER(c.descripcion) AS estado, COUNT(b.rfc_ord) AS num_transacciones, SUM(((b.importe::INTEGER)/100)::DECIMAL(16,2)) AS monto
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
						CREATE INDEX "informix".idx_tmp_domi_sem2 ON tmp_domi_sem (num_cte, fecha_anio_mes) USING btree;
						CREATE INDEX "informix".idx_tmp_domi_sem3 ON tmp_domi_sem (fecha_aplica, num_cte, numero_cuenta, comercio) USING btree;
								
						SELECT num_cte
						FROM bdinteg:tmp_domi_sem 
						WHERE fecha_anio_mes BETWEEN cFechaIniPromSem AND cFechaFinPromSem  
						GROUP BY num_cte
						HAVING COUNT(DISTINCT(fecha_anio_mes)) = 6
						--ORDER BY  num_cte
						INTO TEMP tmp_domi_prom WITH NO LOG;
								
						CREATE INDEX "informix".idx_tmp_domi_prom ON tmp_domi_prom (num_cte) USING btree;
						
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

CREATE PROCEDURE "informix".sp_dicta_actualizastatusalerta(pNumcte CHAR(20), pSucursal CHAR(4), pStatus CHAR(1), pFecha_Insert DATE, pUsuario CHAR (20))

	--RETORNOS-
	RETURNING
	CHAR(6) AS codret,
	CHAR(30) AS mensaje;

	--DECLARACION DE VARIABLES--
	DEFINE iSql_err		    INTEGER; 
	DEFINE cCodret		    CHAR(6);
	DEFINE cMensaje         CHAR(30);
	
	--INICIALIZACION DE VARIABLES--
	LET iSql_err		     = 0;
	LET cCodret		         = '000000';
	LET cMensaje             = 'EJECUCION EXITOSA';

	--INICIO--
	BEGIN
		--CONTROL DE ERRORES--
		ON EXCEPTION SET iSql_err 
			IF iSql_err <> 0 THEN
				LET cCodret = iSql_err;
				RETURN TRIM(cCodret), TRIM(cMensaje);
			END IF;
		END EXCEPTION;
			
		--SET DEBUG FILE TO '/respaldosbd/hugovaz/1456/sp_dicta_actualizastatusalerta.out';
		--TRACE ON;
		
		  SET ISOLATION TO DIRTY READ;
		  SET LOCK MODE TO WAIT 3;
		  
		  --SE VALIDA QUE SE MANDEN TODOS LOS PARAMETROS (NO NULOS NI VACIOS) YA QUE SON NECESARIOS TODOS
		  IF NVL(pNumcte,'') = '' OR NVL(pSucursal,'') = '' OR NVL(pStatus,'') = '' OR NVL(pFecha_Insert,DATE(1)) = DATE(1) THEN
			LET cCodret = '000001'; 
			LET cMensaje = 'PARÁMETRO VACIO';
			RETURN TRIM(cCodret), TRIM(cMensaje);
			
		  END IF;		  

		 --************************************************************************************
		 ---------------****************BLOQUE DE CONSULTA*************************************
		 --************************************************************************************
		   
		UPDATE "informix".si_bitacora_comparaciones SET status_alerta = TRIM(pStatus), analista_fraudes = TRIM(pUsuario) WHERE numcte = TRIM(pNumcte) AND sucursal = TRIM(pSucursal) AND fecha_insert::DATE = pFecha_Insert;
					
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '000002'; 
			LET cMensaje = 'ERROR EN LA ACTUALIZACION';
			RETURN TRIM(cCodret), TRIM(cMensaje);
		END IF;
		
		UPDATE "informix".si_bitacora_alerta_tmp SET status_alerta = TRIM(pStatus), user_analista = TRIM(pUsuario) WHERE numcte = TRIM(pNumcte) AND sucursal = TRIM(pSucursal) AND fecha_insert::DATE = pFecha_Insert AND user_analista = TRIM(pUsuario);
					
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '000003'; 
			LET cMensaje = 'ERROR EN LA ACTUALIZACION';
			RETURN TRIM(cCodret), TRIM(cMensaje);
		END IF;		
		
		RETURN TRIM(cCodret), TRIM(cMensaje);					
					
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÓN: PROCEDIMIENTO QUE ACTUALIZA EL CAMPO STATUS_ALERTA DE LA TABLA SI_BITACORA_COMPARACIONES FILTRANDO POR NUMERO DE CLIENTE, SUCURSAL Y  FECHA_INSERT.',
'FECHA DE CREACIÓN: 06 DE NOVIEMBRE DE 2013',
'BASE DE DATOS: BDINTEG',
'CREADOR: CARLOS OCHOA VALENZUELA',
'VERSION: 20131107.1900',
'DESCRIPCION: se modifica para que tambien actualice el status 5 en la tabla si_bitacora_alerta_tmp.',
'AUTOR: Luis Alberto Madrid Castro',
'FECHA DE CREACION: 09/02/2016 ',
'VERSION: 20160209.0916',
'FOLIO: 230142-1530-Evaluación de Resultados de Comparación de Huellas en Línea en Alta de Cliente',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_consulta_correo_actualcte( pEmpresa    CHAR(3),
                                                          pNumCte     CHAR(20),
                                                          pTipoCorreo CHAR (1))

RETURNING CHAR(6)    AS vcodret1,
          CHAR(50)   AS vDescripcion,
          CHAR(100)  AS vCorreoElec,
          SMALLINT   AS vTipoCorreo,
		  CHAR(1)    AS vStatusCorreo;
		  
		  
DEFINE vcodret1      CHAR(6);
DEFINE vDescripcion  CHAR(50);
DEFINE vCorreoElec   CHAR(100);
DEFINE vTipoCorreo   SMALLINT;
DEFINE vStatusCorreo CHAR(1);
DEFINE iSqlErr       INTEGER;

LET vcodret1 = "000000";
LET vDescripcion = " ";
LET vCorreoElec = " ";
LET vTipoCorreo = 0;
LET vStatusCorreo = " ";
LET iSqlErr	 = 0;

BEGIN
  ON EXCEPTION SET iSqlErr
    IF iSqlErr <> 0 THEN
        LET vcodret1 = iSqlErr;
        RETURN vcodret1, vDescripcion, vCorreoElec, vTipoCorreo, vStatusCorreo;
    END IF;
  END EXCEPTION;

   --SET DEBUG FILE TO "/respaldosbd/nadia/sp_consulta_correo_actualcte.out";
   --TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
   
    -- VALIDA PARAMETROS DE ENTRADA
    IF (pEmpresa IS NULL OR pEmpresa = '') OR
       (pNumCte IS NULL OR pNumCte = '') OR
       (pTipoCorreo IS NULL OR pTipoCorreo = '') THEN
	   
       LET vcodret1 = "000001";
	   
	ELSE
		
		SELECT numcte 
		INTO pNumCte
		FROM bdinteg:"informix".si_cliente 
		WHERE numcte = pNumCte 
		AND empresa = pEmpresa;
		
		IF 	DBINFO('SQLCA.SQLERRD2') = 0 THEN
			
			LET vDescripcion = "Numero de cliente no existe";
			LET vcodret1 = "000002";
		
		ELSE
		
			SELECT correo_elec, tipo_correo, status_correo 
			INTO vCorreoElec, vTipoCorreo, vStatusCorreo
			FROM bdinteg:"informix".si_correos 
			WHERE  numcte = pNumcte 
			AND tipo_correo = pTipoCorreo 
			AND status_correo= "A";
		
			IF 	DBINFO('SQLCA.SQLERRD2') = 0 THEN
			
				LET vDescripcion = "Cliente sin correo";
				LET vcodret1 = "000003";
				LET vCorreoElec = " ";
				LET vTipoCorreo = 0;
				LET vStatusCorreo = " ";
				
			ELSE
		
				LET vcodret1 = "000000";
				LET vDescripcion = "Ejecucion Exitosa";
				LET vCorreoElec = vCorreoElec;
				LET vTipoCorreo = vTipoCorreo;
				LET vStatusCorreo = vStatusCorreo;

			END IF;
		END IF;
	END IF;
	
	RETURN vcodret1, vDescripcion, vCorreoElec, vTipoCorreo,vStatusCorreo;
	END;
	
END PROCEDURE

DOCUMENT
"DescripciÃ³n: Obtiene correo activo de un cliente",
"Autor      : Nadia Lorena Valdez Guevara",
"FECHA      : 24/09/2015",
"BD         : bdinteg";

CREATE PROCEDURE "informix".sp_consulta_act_riesgo( pEmpresa    CHAR(3),
                                                    pNumCte     CHAR(20))
                                                      
RETURNING CHAR(6)  AS cCodRet,
          CHAR(60) AS cDescripcion,
          CHAR(1)  AS cRiesgoViviendaCpl,
          CHAR(1)  AS cRiesgoViviendaBcpl,
		  CHAR(1)  AS cActRiesgoCpl,
		  CHAR(1)  AS cActRiesgoBCpl,
		  CHAR(120)   AS cDescpRiesgo;
		  
DEFINE cCodRet               CHAR(6);
DEFINE cDescripcion   		 CHAR(60);
DEFINE cRiesgoViviendaCpl    CHAR(1);
DEFINE cRiesgoViviendaBcpl   CHAR(1);
DEFINE cActRiesgoCpl         CHAR(1);
DEFINE cActRiesgoBCpl        CHAR(1);
DEFINE cTipoVivienda         CHAR(2);  
DEFINE claveopuesto			 CHAR(4);
DEFINE clavesubopuesto		 CHAR(4);
DEFINE cDescpRiesgo			 CHAR(120);
DEFINE iSqlErr               INTEGER;

LET cCodRet = "000000";
LET cDescripcion = " ";
LET cRiesgoViviendaCpl = " ";
LET cRiesgoViviendaBcpl = " ";
LET cActRiesgoCpl = " ";
LET cActRiesgoBCpl = " ";
LET cTipoVivienda = " ";
LET claveopuesto = " ";
LET clavesubopuesto = " ";
LET cDescpRiesgo = "";
LET iSqlErr	 = 0;

BEGIN
  ON EXCEPTION SET iSqlErr
    IF iSqlErr <> 0 THEN
        LET cCodRet = iSqlErr;
        RETURN cCodRet, cDescripcion, cRiesgoViviendaCpl, cRiesgoViviendaBcpl, cActRiesgoCpl, cActRiesgoBCpl, cDescpRiesgo;
    END IF;
  END EXCEPTION;

   --SET DEBUG FILE TO "/respaldosbd/nadia/sp_consulta_act_riesgo.out";
   --TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
   
      -- VALIDA PARAMETROS DE ENTRADA
    IF (pEmpresa IS NULL OR pEmpresa = '') OR
       (pNumCte IS NULL OR pNumCte = '') THEN
	   
       LET cCodRet = "000001";
	   LET cDescripcion = "Parametros de entrada vacios";
	   
	ELSE
	
		SELECT habita_en 
		INTO cTipoVivienda
		FROM bdinteg:"informix".si_ctepf
		WHERE empresa = pEmpresa
		AND numcte = pNumCte;
   
		IF 	DBINFO('SQLCA.SQLERRD2') = 0 THEN
			
			LET cCodRet = "000002";
			LET cDescripcion = "No se encontraron registros";
			
		ELSE
		
		-- altoriesgocp/cRiesgoViviendaCpl   = 0 = EL CLIENTE NO PRESENTA PROBLEMAS CON EL TIPO DE VIVIENDA PARA COPPEL
		-- altoriesgocp/cRiesgoViviendaCpl   = 1 = EL TIPO DE VIVIENDA DEL CLIENTE ESTA MARCADO COMO INESTABILIDAD PARA COPPEL
		-- altoriesgobcp/cRiesgoViviendaBcpl = 0 = EL CLIENTE NO PRESENTA PROBLEMAS CON EL TIPO DE VIVIENDA PARA BANCOPPEL
		-- altoriesgobcp/cRiesgoViviendaBcpl = 1 = EL TIPO DE VIVIENDA DEL CLIENTE ESTA MARCADO COMO INESTABILIDAD PARA BANCOPPEL
		
			SELECT altoriesgocp, altoriesgobcp
			INTO cRiesgoViviendaCpl, cRiesgoViviendaBcpl
			FROM bdinteg:"informix".si_habitaen
			WHERE habita_en = cTipoVivienda;
			
			IF 	DBINFO('SQLCA.SQLERRD2') = 0 THEN
			
			LET cCodRet = "000002";
			LET cDescripcion = "No se encontraron registros";
			LET cRiesgoViviendaCpl = " ";
			LET cRiesgoViviendaBcpl = " ";
		
			END IF;
		
		END IF;
			
	SELECT claveopcionpuesto, clavesubopcionpuesto
	INTO claveopuesto, clavesubopuesto
	FROM bdinteg:"informix".si_ingresos a 
	WHERE a.numcte = pNumCte
	AND a.tipo_ingreso = 'T'
	AND a.sec_ingreso = (SELECT MAX (sec_ingreso)
	FROM bdinteg:"informix".si_ingresos b
	WHERE b.numcte = a.numcte
	AND b.tipo_ingreso = 'T');
	
	IF 	DBINFO('SQLCA.SQLERRD2') = 0 THEN
	
		LET cCodRet = "000002";
		LET cDescripcion = "No se encontraron registros";    
		
	ELSE
	
	-- altoriesgocredcp/cActRiesgoCpl  = 0 = EL CLIENTE NO PRESENTA OCUPACION DE ALTO RIESGO PARA COPPEL
	-- altoriesgocredcp/cActRiesgoCpl  = 1 = EL TIPO DE ACTIVIDAD DE CLIENTE ESTA MARCADO COMO ALTO RIESGO PARA COPPEL
	-- altoriesgocred/cActRiesgoBCpl   = 0 = EL CLIENTE NO PRESENTA OCUPACION DE ALTO RIESGO PARA BANCOPPEL
	-- altoriesgocred/cActRiesgoBCpl   = 1 = EL TIPO DE ACTIVIDAD DE CLIENTE ESTA MARCADO COMO ALTO RIESGO PARA BANCOPPEL
	
		SELECT altoriesgocredcp, altoriesgocred,descrip
		INTO cActRiesgoCpl, cActRiesgoBCpl, cDescpRiesgo
		FROM bdinteg:"informix".si_actsubact 
		WHERE id_act = claveopuesto
		AND id_subact = clavesubopuesto;
	
	END IF;
	END IF;
	
	IF cCodRet = '000000' THEN
		LET cDescripcion = "Ejecucion Exitosa";
	END IF;	
	
	RETURN cCodRet, cDescripcion, cRiesgoViviendaCpl, cRiesgoViviendaBcpl, cActRiesgoCpl, cActRiesgoBCpl, cDescpRiesgo;
	END;
	
END PROCEDURE

DOCUMENT
"DescripciÃ³n: Consulta si un cliente cuenta con una actividad de riesgo e inestabilidad en la vivienda",
"Autor      : Carolina Elizabeth Verdugo Gastelum",
"FECHA      : 28/12/2015",
"BD         : bdinteg";

CREATE PROCEDURE "informix".sp_actualiza_rfc()

    --DATOS A REGRESAR---
RETURNING CHAR(5) AS CodRet;  -- Codigo de Retorno

	--DEFINICION DE VARIABLES--
DEFINE iSql_err 			INTEGER;
DEFINE cCodRet 				CHAR(5);
DEFINE cNumcte          	CHAR(26);
DEFINE cRfc              	CHAR(26);
DEFINE cRFCcte              CHAR(26);
DEFINE iContartme			INTEGER;
DEFINE iTotal				INTEGER;
DEFINE iContar				INTEGER;
DEFINE iContar2				INTEGER;
DEFINE cCte                 CHAR (26);
DEFINE cRFC_alterno			CHAR (26);

	--INICIALIZACION DE VARIABLES--
LET iSql_err 				= 0;
LET cCodRet 				= '00001';
LET cNumcte         		= '';
LET cRfc                    = '';
LET cRFCcte                 = '';
LET iContartme				= 0;
LET iTotal					= 0;
LET iContar					= 0;
LET iContar2				= 0;
LET cCte                    = '';
LET cRFC_alterno            = '';

--SET DEBUG FILE TO "/tmp/rvd/sp_actualiza_rfc.out";
--TRACE ON;
BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			ROLLBACK WORK;
			RETURN  cCodRet;
		END IF;
	END EXCEPTION;
	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	BEGIN WORK;
	
        SELECT COUNT(numcte) INTO iContar FROM bdinteg:"informix".info_sat;
	
	

           FOREACH Cursos_RFC WITH HOLD FOR
            	SELECT numcte,rfc
                INTO cNumcte,cRfc
                FROM bdinteg:"informix".info_sat 
                ORDER BY numcte,rfc

                SELECT numcte, trim(rfc_alterno) as rfc_alterno,rfc
                INTO cCte, cRFC_alterno,cRFCcte
                FROM "informix".si_cliente
                WHERE empresa='001' and numcte = cNumcte;

				
                IF (cRFC_alterno= '') OR (cRFC_alterno IS NULL) OR (cRFC_alterno <> cRfc) OR (cRFCcte <> cRfc)  THEN
                    UPDATE bdinteg:"informix".si_cliente SET rfc_alterno = cRfc WHERE numcte = cNumcte and rfc<>cRfc;
				END IF;	
				
				UPDATE bdinteg:"informix".info_sat   SET actualizado = 1    WHERE numcte = cNumcte;		
				
			END FOREACH;

        
		LET cCodRet = '00000';
	COMMIT WORK;
	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'Creó:Rosalba Vargas Díaz',
'Descripción: Actualiza RFC Alterno en base a información proporcionada por el SAT',
'FECHA : 11/03/2015',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_actualiza_lugarnac()
RETURNING 
CHAR(5) AS cCodRet ,
CHAR(100) AS cMensajeREt;

--DECLARACIÃN DE VARIABLE
DEFINE cCodRet		CHAR(5);
DEFINE cMensajeREt	CHAR(100);
DEFINE cSql         CHAR(6000);
DEFINE iSqlErr      INTEGER;
DEFINE Cnumcte		CHAR(20);
DEFINE Cnumctetmp		CHAR(20);
DEFINE Clugar_nac	CHAR(2);
DEFINE Clugar_nac_new CHAR(2);
--INICIALIZACIÃN DE VARIABLE

LET cCodRet ='00000';
LET cMensajeREt ='Proceso Exitoso';
LET iSqlErr = 0;
LET cSql = '';
LET Cnumcte	='';
LET Clugar_nac ='';
LET Clugar_nac_new ='';
LET Cnumctetmp ='';

--SET DEBUG FILE TO "/informix/c92962301/lugarnacimiento/Detalle_error_caso1.out";
--TRACE ON;
BEGIN

ON EXCEPTION SET iSqlErr
				IF iSqlErr !=0 THEN
					 LET cCodRet = iSqlErr;
					 LET cMensajeRet = "Ocurrio un Error";
					 --TRUNCATE TABLE 	bdidigital:clientes_depuracion;	
					RETURN cCodRet,cMensajeRet;
				END IF;
			END EXCEPTION;
				

SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
					
		--Se optiene el numero de cliente de la tabla pivote
		SELECT num_credito INTO Cnumctetmp FROM bdicred:"informix".sd_param_movhis_dep WHERE proceso ='6';
				
	
		FOREACH  WITH HOLD
		SELECT numcte,lugar_nac INTO Cnumcte,Clugar_nac 
		FROM bdinteg:"informix".si_ctepf WHERE empresa = '001' AND numcte > Cnumctetmp AND lugar_nac <> '' AND fecha_insert <= '12-09-2015' order by numcte asc
	 	
IF Clugar_nac ='01' THEN
LET Clugar_nac_new ='18';
	ELIF	Clugar_nac ='02' THEN
	LET Clugar_nac_new ='25';
	    ELIF	Clugar_nac ='03' THEN
		LET Clugar_nac_new ='26';
			ELIF	Clugar_nac ='04' THEN
			LET Clugar_nac_new ='02';
				ELIF	Clugar_nac ='05' THEN
				LET Clugar_nac_new ='10';
					ELIF	Clugar_nac ='06' THEN
					LET Clugar_nac_new ='05';
						ELIF	Clugar_nac ='07' THEN
						LET Clugar_nac_new ='08';
							ELIF	Clugar_nac ='08' THEN
							LET Clugar_nac_new ='33';
								ELIF	Clugar_nac ='09' THEN
								LET Clugar_nac_new ='01';
								ELIF	Clugar_nac ='10' THEN
									LET Clugar_nac_new ='14';
										ELIF	Clugar_nac ='11' THEN
										LET Clugar_nac_new ='24';
											ELIF	Clugar_nac ='12' THEN
											LET Clugar_nac_new ='16';
												ELIF	Clugar_nac ='13' THEN
												LET Clugar_nac_new ='06';
													ELIF	Clugar_nac ='14' THEN
													LET Clugar_nac_new ='11';
														ELIF	Clugar_nac ='15' THEN
														LET Clugar_nac_new ='32';
															ELIF	Clugar_nac ='16' THEN
															LET Clugar_nac_new ='12';
																ELIF	Clugar_nac ='17' THEN
																LET Clugar_nac_new ='28';
																	ELIF	Clugar_nac ='18' THEN
																	LET Clugar_nac_new ='21';
																		ELIF	Clugar_nac ='19' THEN
																		LET Clugar_nac_new ='03';
																			ELIF	Clugar_nac ='20' THEN
																			LET Clugar_nac_new ='19';
																				ELIF	Clugar_nac ='21' THEN
																				LET Clugar_nac_new ='17';
																					ELIF	Clugar_nac ='22' THEN
																					LET Clugar_nac_new ='13';
																						ELIF	Clugar_nac ='23' THEN
																						LET Clugar_nac_new ='30';
																							ELIF	Clugar_nac ='24' THEN
																							LET Clugar_nac_new ='27';
																								ELIF	Clugar_nac ='25' THEN
																								LET Clugar_nac_new ='09';
																									ELIF	Clugar_nac ='26' THEN
																									LET Clugar_nac_new ='15';
																										ELIF	Clugar_nac ='27' THEN
																										LET Clugar_nac_new ='07';
																											ELIF	Clugar_nac ='28' THEN
																											LET Clugar_nac_new ='22';
																												ELIF	Clugar_nac ='29' THEN
																												LET Clugar_nac_new ='04';
																													ELIF	Clugar_nac ='30' THEN
																													LET Clugar_nac_new ='31';
																														ELIF	Clugar_nac ='31' THEN
																														LET Clugar_nac_new ='20';
																															ELIF	Clugar_nac ='32' THEN
																															LET Clugar_nac_new ='29';
																																ELIF	Clugar_nac ='33' THEN
																																LET Clugar_nac_new ='23';
																																ELSE 
																																LET Clugar_nac_new ='';
 END IF;
 --Fin Del Bloque--
 
 IF Clugar_nac_new <>'' THEN
  
	BEGIN;
	--Se Actualiza el cliente con el valor nuevo de lugar de nacimiento																																
						
		UPDATE bdinteg:"informix".si_ctepf SET lugar_nac = Clugar_nac_new WHERE empresa = '001' AND numcte = Cnumcte ;
	--Se actualiza el valor de la tabla pivote
		UPDATE  bdicred:"informix".sd_param_movhis_dep SET num_credito = Cnumcte WHERE proceso ='6';

	COMMIT;
	
END IF;
LET Clugar_nac_new = '';
		
	END FOREACH;	

			
			RETURN cCodRet,cMensajeRet;
				
END;
END PROCEDURE

;