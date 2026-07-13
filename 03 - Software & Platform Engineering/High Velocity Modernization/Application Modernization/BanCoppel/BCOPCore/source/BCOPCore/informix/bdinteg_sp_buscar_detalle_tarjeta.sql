CREATE PROCEDURE "informix".sp_buscar_detalle_tarjeta(p_numeroTarjeta CHAR(16))
			
    RETURNING CHAR(16) AS numeroTarjeta,CHAR(3) AS productoTarjeta, CHAR(1) AS titularTarjeta,DATE AS fechaNacimiento, CHAR(3) AS estatusTarjeta, CHAR(4) AS fechaExpiracion, CHAR(8) AS usuarioModificacion, DATETIME YEAR TO FRACTION AS fechaModificacion, CHAR(8) AS numeroReporte

	--definicion de variables--	    
    DEFINE resultado_numeroTarjeta 	 		VARCHAR(16);
    DEFINE resultado_productoTarjeta 	 	VARCHAR(3);
    DEFINE resultado_titularTarjeta	 		VARCHAR(1);
    DEFINE resultado_fechaNacimiento 	 	DATE;
    DEFINE resultado_estatusTarjeta	 		VARCHAR(3);
    DEFINE resultado_fechaExpiracion 	 	VARCHAR(4);
    DEFINE resultado_usuarioModificacion 	VARCHAR(8);
    DEFINE resultado_fechaModificacion   	DATEtime year to fraction(3);
    DEFINE resultado_numeroReporte       	VARCHAR(8);
    DEFINE iSqlErr                     	 	INTEGER;
		
     -- InicializaciÃ³n de las variables.
    LET resultado_numeroTarjeta 		= '';
	LET resultado_productoTarjeta 		= '';
	LET resultado_titularTarjeta 		= '';
	LET resultado_fechaNacimiento 		= '';
	LET resultado_estatusTarjeta 		= '';
	LET resultado_fechaExpiracion 		= '';
	LET resultado_usuarioModificacion 	= '';
    LET resultado_numeroReporte      	= '';
	--LET resultado_fechaModificacion 	= '';

    SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_buscar_detalle_tarjeta_"||p_numeroTarjeta||".out";
    --TRACE ON;
				
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_numeroTarjeta 		= '';
                    LET resultado_productoTarjeta 		= '';
					LET resultado_titularTarjeta 		= '';
					LET resultado_fechaNacimiento 		= '';
					LET resultado_estatusTarjeta 		= '';
					LET resultado_fechaExpiracion 		= '';
					LET resultado_usuarioModificacion 	= '';	
					LET resultado_numeroReporte      	= '';	
                    --LET resultado_fechaModificacion 	= '';
                    RETURN resultado_numeroTarjeta,resultado_productoTarjeta,resultado_titularTarjeta,resultado_fechaNacimiento,resultado_estatusTarjeta,resultado_fechaExpiracion,resultado_usuarioModificacion,resultado_fechaModificacion,resultado_numeroReporte;
                END IF;
        END EXCEPTION;
				
	
		SELECT DISTINCT numtarjeta,codproductotarjeta,titular,date(fechanacimiento),codstatustarjeta,fechaexp,usuarioultmodif,fechaultmodif,numreporte
        INTO resultado_numeroTarjeta,resultado_productoTarjeta,resultado_titularTarjeta,resultado_fechaNacimiento,resultado_estatusTarjeta,resultado_fechaExpiracion,resultado_usuarioModificacion,resultado_fechaModificacion,resultado_numeroReporte
        FROM intercard:tarjeta
        WHERE numtarjeta = p_numeroTarjeta;           
        
        RETURN resultado_numeroTarjeta,resultado_productoTarjeta,resultado_titularTarjeta,resultado_fechaNacimiento,resultado_estatusTarjeta,resultado_fechaExpiracion,resultado_usuarioModificacion,resultado_fechaModificacion,resultado_numeroReporte;
	END
END PROCEDURE
DOCUMENT
'Sp sp_buscar_detalle_tarjeta',
'fue creado para sistema de aclaraciones',
'Aclaraciones',
'AUTOR : Proveedor Root',
'Area: Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte II',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 07/Marzo/2012',
'VERSION: 1.0.0',
'BD    :  bdinteg',

'Se modifico para mostrar el campo numero de reporte del RQM 06 305 ',
'Autor: Proveedor Root',
'Fecha: 22/mayo/2014';

CREATE PROCEDURE "informix".sp_generar_reporte_domi_pp_tdc_servicios(dFechaHoy DATE)
RETURNING CHAR(6), CHAR(100);

--DEFINICION DE VARIABLES
DEFINE vCodRet         	  CHAR(6);
DEFINE cMensCodRet     	  CHAR(100);
DEFINE iNomErr         	  INTEGER;
DEFINE iNanErr		   	  INTEGER;
DEFINE iEnTransaccion 	  SMALLINT;
DEFINE dFechaInicial      DATETIME YEAR TO FRACTION;
DEFINE dFechaFinal        DATETIME YEAR TO FRACTION;
DEFINE dFechaIni          DATE; 
DEFINE dFechaFin          DATE; 
DEFINE dFecha_act         DATE;
DEFINE iTotal1            INTEGER;
DEFINE cRep1              CHAR(300);
DEFINE cComercio          CHAR(60);
DEFINE cEstado1           CHAR(20);
DEFINE cNum_transacciones CHAR(18);
DEFINE dMonto             DECIMAL(16,2);
DEFINE cRep2              CHAR(300);
DEFINE fFecha             DATE;
DEFINE cEstado2           CHAR(20);
DEFINE cNum_pagos         CHAR(10);
DEFINE mMonto             DECIMAL(16,2);
DEFINE cRep3              CHAR(300);
DEFINE fFecha2            DATE;
DEFINE cEstado3           CHAR(20);
DEFINE cNum_domi          CHAR(10);
DEFINE mMonto2            DECIMAL(16,2);
DEFINE cRutaRepor         CHAR(100);
DEFINE cRutaRepor1        CHAR(100);  
DEFINE cRutaRepor2        CHAR(100);
DEFINE cRutaRepor3        CHAR(100);
DEFINE cProceso			  CHAR(100);
DEFINE cEvento			  CHAR(100);
DEFINE cMensaje           CHAR(110);
DEFINE iTotal             INTEGER;
DEFINE iMaxL			  INT;
DEFINE iMaxC              INT;
DEFINE iMaxD              INT;
DEFINE cMes               CHAR(2);
DEFINE cAnio              CHAR(4);

--ASIGNACION DE VARIABLES
LET vCodRet  = '000000';
LET iEnTransaccion = 0;
LET cMensCodRet = 'EL PROCESO DE REPORTES DE DOMICILIACION SE A GENERADO CORRECTAMENTE';
LET cMes = '';
LET cAnio = '';
LET cRutaRepor  = ''; 
LET cRutaRepor1 = ''; 
LET cRutaRepor2 = ''; 
LET cRutaRepor3 = '';
LET cProceso = '';
LET cEvento = '';
LET cMensaje = '';
LET iTotal = 0;
LET iMaxL = 0;
LET iMaxC = 0;
LET iMaxD = 0;


--SET DEBUG FILE TO "/informix/Ingrid/sp_generar_reporte_domi_pp_tdc_servicios.out";
--TRACE ON;

BEGIN
	--Manejo del error
	ON EXCEPTION SET iNomErr, iNanErr, cMensCodRet
		IF iNomErr <> 0 THEN
			LET vCodRet=iNomErr;
			
			IF iEnTransaccion = 1 THEN
				ROLLBACK;
			END IF;
			
			SELECT DBINFO('utc_to_datetime',sh_curtime)
			INTO dFechaFinal
			FROM sysmaster:"informix".sysshmvals;
			
			INSERT INTO si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
			VALUES (dFechaHoy - 1 UNITS DAY, cProceso, cEvento, vCodret, cMensCodRet);
			
			UPDATE "informix".si_controlproc_indicadores 
			SET maxfecha_cargada = dFechaFin , flagfinalizado = 'F', coderror = vCodRet, msgerror =  cMensCodRet, fecha_cargafin =  dFechaFinal
			WHERE id_proc = 9
			AND nombre_proceso = cProceso
			AND fecha_procesoIni = dFechaIni
			AND fecha_procesoFin = dFechafin;
			
			RETURN vCodRet, cMensCodRet;
		END IF;			
	END EXCEPTION;
	
	--OBTENCIÓN DE MES Y AÑO DE LOS REPORTES				
	LET dFechaFin = dFechaHoy - DAY(dFechaHoy);		       
	LET dFechaIni = dFechaFin - (DAY(dFechaFin) -1);	
	LET cMes      = LPAD(MONTH(dFechaFin), 2, 0);
	LET cAnio     = YEAR(dFechaFin);
	
	--GUARDA INFORMACIÓN INICIAL EN LA TABLA si_controlproc_indicadores			
	SELECT DBINFO('utc_to_datetime',sh_curtime)
	INTO dFechaInicial 
	FROM sysmaster:"informix".sysshmvals;
	
	LET cEvento = 'OBTENCION DE PARAMETROS';
	SELECT valor 
	INTO cRutaRepor
	FROM si_param
	WHERE cod_param = '358';
			
	SELECT valor 
	INTO cRutaRepor1
	FROM si_param
	WHERE cod_param = '355';
	
	SELECT valor 
	INTO cRutaRepor2
	FROM si_param
	WHERE cod_param = '356'; 

	SELECT valor 
	INTO cRutaRepor3
	FROM si_param
	WHERE cod_param = '357';		
	
	LET cProceso = 'REPORTE DE DOMICILIACIONES TARJETA DE DEBITO';
	LET cEvento = 'VALIDANDO GENERACION PREVIA DE REPORTE DE DOMICILIACIONES TARJETA DE DEBITO';
	IF NOT EXISTS(SELECT 1 FROM si_controlproc_indicadores WHERE id_proc = 9 AND nombre_proceso = cProceso AND fecha_procesoIni = dFechaIni AND fecha_procesoFin = dFechafin AND flagfinalizado = 'V') THEN
		LET cEvento = 'INSERTA REGISTRO INICIAL EN TABLA DE CONTROL DE PROCESOS';
		INSERT INTO "informix".si_controlproc_indicadores (fecha_procesoIni, fecha_procesoFin, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin, maxfecha_cargada,
														flagfinalizado, coderror, msgerror)
		VALUES (dFechaIni, dFechaFin, '9', cProceso, dFechaInicial, NULL, NULL, 'F', NULL, NULL );
			
		SELECT MAX(LENGTH(razon_social))
		INTO iMaxC
		FROM bdidomi:dom_cat_servicios;
		
		SELECT MAX(LENGTH(descripcion))
		INTO iMaxD
		FROM bdidomi:dom_status_pago;
		
		BEGIN WORK;
		--GENERA REPORTE DE DOMICILIACIONES TARJETA DE DÉBITO
		LET iEnTransaccion = 1;
		
		--REEMPLAZA LA FECHA EN EL NOMBRE DEL ARCHIVO
		LET cRutaRepor1 = REPLACE (cRutaRepor1, 'AAAA', cAnio);
		LET cRutaRepor1 = REPLACE (cRutaRepor1, 'MM', cMes);
			 
		--CUENTA NUMERO DE REGISTROS 
		LET cEvento = 'OBTIENE CANTIDAD DE REGISTROS DEL REPORTE DE DOMICILIACIONES TARJETA DE DEBITO';
		SELECT COUNT (a.razon_social)
			INTO iTotal 
			FROM bdidomi:dom_cat_servicios a, bdidomi:dom_cce_detalle b, bdidomi:dom_status_pago c  
			WHERE b.rfc_ord = a.rfc
			AND b.cve_estatus = c.cve_status
			AND b.cod_operacion = '30'
			AND b.banco_receptor = '137'
			AND b.tipo_cta_rec IN('03','10','40')
			--AND b.cve_estatus = '01'
			AND b.fecha_aplica BETWEEN YEAR(dFechaIni)||LPAD(MONTH(dFechaIni),2,0)||LPAD(DAY(dFechaIni),2,0) AND YEAR(dFechaFin)||LPAD(MONTH(dFechaFin),2,0)||LPAD(DAY(dFechaFin),2,0);
			 
		LET cEvento = 'GENERA ENCABEZADOS DE REPORTE DE DOMICILIACIONES TARJETA DE DEBITO';
		
		LET cRep1 =  'echo "' || RPAD('COMERCIO',iMaxC,' ') || '|' || RPAD('ESTADO',iMaxD,' ') || '|' || RPAD('NUMERO DE TRANSACCIONES',24, ' ') || '|' || 'MONTO' || '" >> ' || TRIM(cRutaRepor) || TRIM(cRutaRepor1);
		SYSTEM cRep1;
		
		IF iTotal = 0 THEN
			LET cMensaje = 'NO EXISTE INFORMACION PARA GENERAR REPORTE DE DOMICILIACIONES TARJETA DE DÉBITO';
			LET cRep1 =  'echo "' || ' ' || '" >> ' || TRIM(cRutaRepor) || TRIM(cRutaRepor1);
			SYSTEM cRep1;
			LET cRep1 =  'echo "' || ' ' || '" >> ' || TRIM(cRutaRepor) || TRIM(cRutaRepor1);
			SYSTEM cRep1;				
			LET cRep1 =  'echo "' || TRIM(cMensaje) || '" >> ' || TRIM(cRutaRepor) || TRIM(cRutaRepor1);
			SYSTEM cRep1;			
		ELSE
			LET cEvento = 'OBTENCION DE REGISTROS DEL REPORTE DE DOMICILIACIONES TARJETA DE DEBITO';
			LET cMensaje = 'REPORTE DE DOMICILIACIONES TARJETA DE DÉBITO GENERADO';
			--IMPRIME 
			--LET cRep1 =   'echo "' || 'ID COMERCIO'|| '|' || 'COMERCIO' || '|' || 'NUMERO DE TRANSACCIONES' || '|' || 'MONTO' || '" >> ' || TRIM(cRutaRepor) || TRIM(cRutaRepor1);
			FOREACH	
				--SELECT TRIM(b.rfc_ord) AS id_comercio, a.razon_social AS comercio, COUNT(b.rfc_ord) AS num_transacciones, SUM(((b.importe::INTEGER)/100)::DECIMAL(16,2)) AS monto
				--INTO cId_comercio, cComercio, cNum_transacciones, dMonto				
				SELECT a.razon_social AS comercio, UPPER(c.descripcion) AS estado, COUNT(b.rfc_ord) AS num_transacciones, SUM(((b.importe::INTEGER)/100)::DECIMAL(16,2)) AS monto
				INTO cComercio, cEstado1, cNum_transacciones, dMonto
				FROM bdidomi:dom_cat_servicios a, bdidomi:dom_cce_detalle b, bdidomi:dom_status_pago c  
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
				--LET cRep1 =  'echo "' || RPAD(TRIM(cId_comercio),iMaxL,' ')|| '|' ||  RPAD(UPPER(TRIM(cComercio)),iMaxC,' ') || '|' || RPAD(TRIM(cNum_transacciones),18,' ') || '|' || dMonto || '" >> ' || TRIM(cRutaRepor) || cRutaRepor1;
				LET cRep1 =  'echo "' ||  RPAD(UPPER(TRIM(cComercio)),iMaxC,' ') || '|' || RPAD(TRIM(cEstado1),iMaxD,' ') || '|' || RPAD(TRIM(cNum_transacciones),24,' ') || '|' || dMonto || '" >> ' || TRIM(cRutaRepor) || TRIM(cRutaRepor1);
				SYSTEM cRep1;				
			END FOREACH;
		END IF;	
		COMMIT;
		LET iEnTransaccion = 0;
	
		SELECT DBINFO('utc_to_datetime',sh_curtime)
		INTO dFechaFinal 
		FROM sysmaster:"informix".sysshmvals;
		
		LET cEvento = 'ACTUALIZACION FINAL DE REGISTRO EN TABLA DE CONTROL DE PROCESOS';	
		
		UPDATE "informix".si_controlproc_indicadores 
		SET maxfecha_cargada = dFechaFin , flagfinalizado = 'V', coderror = vCodRet, msgerror = cMensaje, fecha_cargafin =  dFechaFinal
		WHERE id_proc = 9
		AND nombre_proceso = cProceso
		AND fecha_procesoIni = dFechaIni
		AND fecha_procesoFin = dFechafin;
	END IF;
		
	LET cProceso = 'REPORTE DE PAGOS PROGRAMADOS DE TDC BANCOPPEL';
	--LET cEvento = 'INSERTA REGISTRO EN SI_CONTROLPROC_INDICADORES DE REPORTE DE PAGOS PROGRAMADOS DE TDC BANCOPPEL';
	LET cEvento = 'VALIDANDO GENERACION PREVIA DE REPORTE DE PAGOS PROGRAMADOS DE TDC BANCOPPEL';
	--GENERA REPORTE DE PAGOS PROGRAMADOS EN CUENTAS DE CAPTACIÓN DE TARJETA DE CRÉDITO BANCOPPEL VISA
	IF NOT EXISTS(SELECT 1 FROM si_controlproc_indicadores WHERE id_proc = 9 AND nombre_proceso = cProceso AND fecha_procesoIni = dFechaIni AND fecha_procesoFin = dFechafin AND flagfinalizado = 'V') THEN
		LET cEvento = 'INSERTA REGISTRO INICIAL EN TABLA DE CONTROL DE PROCESOS';
		INSERT INTO "informix".si_controlproc_indicadores (fecha_procesoIni, fecha_procesoFin, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin, maxfecha_cargada,
													flagfinalizado, coderror, msgerror)
		VALUES (dFechaIni, dFechaFin, '9', cProceso, dFechaInicial, NULL, NULL, 'F', NULL, NULL );
		
		BEGIN WORK;
		
		LET iEnTransaccion = 1;		
		
		--REEMPLAZA LA FECHA EN EL NOMBRE DEL ARCHIVO
		LET cRutaRepor2 = REPLACE (cRutaRepor2, 'AAAA', cAnio);
		LET cRutaRepor2 = REPLACE (cRutaRepor2, 'MM', cMes);
		
		--CUENTA NUMERO DE REGISTROS
		LET cEvento = 'OBTIENE CANTIDAD DE REGISTROS DEL REPORTE DE PAGOS PROGRAMADOS DE TDC BANCOPPEL';
		SELECT COUNT (a.fecha_aplic) 
			INTO iTotal
			FROM bdiprog:pp_pagospend a, bdiprog:pp_pagoprog b, bdiprog:pp_estados c
			WHERE a.cve_pagoprog = b.cve_pagoprog
			AND a.estado = c.cve_estado
			--AND a.estado = '05'
			AND b.cve_pago = '05'
			AND a.fecha_aplic BETWEEN dFechaIni AND dFechaFin;
			
		LET cEvento = 'GENERA ENCABEZADOS DE REPORTE DE PAGOS PROGRAMADOS DE TDC BANCOPPEL';
			
		LET cRep2 =  'echo "' || RPAD('FECHA',12, ' ') || '|' || RPAD('ESTADO',iMaxD, ' ') || '|' || RPAD('NUMERO DE PAGOS',16,' ') || '|' || 'MONTO' || '" >> ' || TRIM(cRutaRepor) || TRIM(cRutaRepor2);
		SYSTEM cRep2;
		
		IF iTotal = 0 THEN 
			LET cMensaje = 'NO EXISTE INFORMACION PARA GENERAR REPORTE DE PAGOS PROGRAMADOS DE TDC BANCOPPEL';
			LET cRep2 =  'echo "' || ' ' || '" >> ' || TRIM(cRutaRepor) || TRIM(cRutaRepor2);
			SYSTEM cRep2;
			LET cRep2 =  'echo "' || ' ' || '" >> ' || TRIM(cRutaRepor) || TRIM(cRutaRepor2);
			SYSTEM cRep2;
			LET cRep2 =  'echo "' || TRIM(cMensaje) || '" >> ' || TRIM(cRutaRepor) || TRIM(cRutaRepor2);
			SYSTEM cRep2;			
		ELSE
			LET cEvento = 'OBTENCION DE REGISTROS DEL REPORTE DE PAGOS PROGRAMADOS DE TDC BANCOPPEL';	
			LET cMensaje = 'REPORTE DE PAGOS PROGRAMADOS DE TDC BANCOPPEL GENERADO';
			FOREACH                                                          				
				SELECT a.fecha_aplic AS fecha, UPPER(c.descripcion) AS estado, COUNT(a.cve_pagoprog) AS num_pagos, SUM(((b.importe::INTEGER)/100)::DECIMAL(16,2)) AS monto
				INTO fFecha, cEstado2, cNum_pagos, mMonto
				FROM bdiprog:pp_pagospend a, bdiprog:pp_pagoprog b, bdiprog:pp_estados c
				WHERE a.cve_pagoprog = b.cve_pagoprog
				AND a.estado = c.cve_estado
				--AND a.estado = '05'
				AND b.cve_pago = '05'
				AND a.fecha_aplic BETWEEN dFechaIni AND dFechaFin
				GROUP BY 1,2
				ORDER BY 1
					
				--IMPRIME
				LET cRep2 = 'echo "' || RPAD(fFecha,12, ' ') || '|' || RPAD(cEstado2,iMaxD, ' ') || '|' || RPAD(cNum_pagos,16,' ') || '|' || mMonto || '" >> ' || TRIM(cRutaRepor) || TRIM(cRutaRepor2);
				SYSTEM cRep2;

			END FOREACH;
		END IF;
		COMMIT;
		LET iEnTransaccion = 0;
		
		SELECT DBINFO('utc_to_datetime',sh_curtime)
		INTO dFechaFinal
		FROM sysmaster:"informix".sysshmvals;
		
		LET cEvento = 'ACTUALIZACION FINAL DE REGISTRO EN TABLA DE CONTROL DE PROCESOS';
		
		UPDATE "informix".si_controlproc_indicadores 
		SET maxfecha_cargada = dFechaFin , flagfinalizado = 'V', coderror = vCodRet, msgerror =  cMensaje, fecha_cargafin =  dFechaFinal
		WHERE id_proc = 9
		AND nombre_proceso = cProceso
		AND fecha_procesoIni = dFechaIni
		AND fecha_procesoFin = dFechafin;				
		--END IF;
	END IF;
	
	--GENERA REPORTE DE PAGO DE TARJETA DE CRÉDITO BANCOPPEL VISA DOMICILIADOS A OTROS BANCOS
	LET cProceso = 'REPORTE DE PAGO DE TARJETA DE CREDITO VISA DOMICILIADOS A OTROS BANCOS';
	LET cEvento = 'VALIDANDO GENERACION PREVIA DE REPORTE DE PAGO DE TARJETA DE CREDITO VISA DOMICILIADOS A OTROS BANCOS';
	--LET cEvento = 'INSERTA REGISTRO EN SI_CONTROLPROC_INDICADORES DE REPORTE DE PAGO DE TARJETA DE CREDITO VISA DOMICILIADOS A OTROS BANCOS';
	IF NOT EXISTS(SELECT 1 FROM si_controlproc_indicadores WHERE id_proc = 9 AND nombre_proceso = cProceso AND fecha_procesoIni = dFechaIni AND fecha_procesoFin = dFechafin AND flagfinalizado = 'V') THEN
		LET cEvento = 'INSERTA REGISTRO INICIAL EN TABLA DE CONTROL DE PROCESOS';
		INSERT INTO "informix".si_controlproc_indicadores (fecha_procesoIni, fecha_procesoFin, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin, maxfecha_cargada,
													flagfinalizado, coderror, msgerror)
		VALUES (dFechaIni, dFechaFin, '9', cProceso, dFechaInicial, NULL, NULL, 'F', NULL, NULL );
		
		BEGIN;
		LET iEnTransaccion = 1;
		
		--REEMPLAZA LA FECHA EN EL NOMBRE DEL ARCHIVO
		LET cRutaRepor3 = REPLACE (cRutaRepor3, 'AAAA', cAnio);
		LET cRutaRepor3 = REPLACE (cRutaRepor3, 'MM', cMes);
		
		--CUENTA NUMERO DE REGISTROS
		LET cEvento = 'OBTIENE CANTIDAD DE REGISTROS DEL REPORTE DE PAGO DE TARJETA DE CREDITO VISA DOMICILIADOS A OTROS BANCOS';
		SELECT COUNT(a.fecha_aplica) 
			INTO iTotal
			FROM bdidomi:dom_cce_detalle a, bdidomi:dom_status_pago b
			WHERE a.cve_estatus = b.cve_status 
			AND a.banco_receptor <> 137
			AND a.banco_presentador = 137
			AND a.tipo_cta_ord = 05  
			AND a.cod_operacion = 30
			AND a.fecha_aplica BETWEEN YEAR(dFechaIni)||LPAD(MONTH(dFechaIni),2,0)||LPAD(DAY(dFechaIni),2,0) 
							   AND 
							   YEAR(dFechaFin)||LPAD(MONTH(dFechaFin),2,0)||LPAD(DAY(dFechaFin),2,0);
			
		
		LET cEvento = 'GENERA ENCABEZADOS DE REPORTE DE PAGO DE TARJETA DE CREDITO VISA DOMICILIADOS A OTROS BANCOS';
		
		LET cRep3 =   'echo "' || RPAD('FECHA',12, ' ') || '|' || RPAD('ESTADO',iMaxD, ' ') || '|' || RPAD('NUMERO DE DOMICILIACIONES',26,' ') || '|' || 'MONTO' || '" >> ' || TRIM(cRutaRepor) || TRIM(cRutaRepor3);
		SYSTEM cRep3;
		
		IF iTotal = 0 THEN
			LET cMensaje = 'NO EXISTE INFORMACION PARA GENERAR REPORTE DE PAGO DE TARJETA DE CREDITO VISA DOMICILIADOS A OTROS BANCOS';
			LET cRep3 =   'echo "' || ' ' || '" >> ' || TRIM(cRutaRepor) || TRIM(cRutaRepor3);
			SYSTEM cRep3;
			LET cRep3 =   'echo "' || ' ' || '" >> ' || TRIM(cRutaRepor) || TRIM(cRutaRepor3);
			SYSTEM cRep3;
			LET cRep3 =   'echo "' || TRIM(cMensaje) || '" >> ' || TRIM(cRutaRepor) || TRIM(cRutaRepor3);
			SYSTEM cRep3;
		
		ELSE
		   LET cEvento = 'OBTENCION DE REGISTROS DEL REPORTE DE PAGO DE TARJETA DE CREDITO VISA DOMICILIADOS A OTROS BANCOS';
		   LET cMensaje = 'REPORTE DE PAGO DE TARJETA DE CREDITO VISA DOMICILIADOS A OTROS BANCOS GENERADO';
			
			FOREACH 					
				SELECT a.fecha_aplica::DATE AS fecha, UPPER(b.descripcion) AS estado, COUNT(a.rfc_ord) AS numero_domi, SUM(((a.importe::INTEGER)/100)::DECIMAL(16,2)) AS monto
				INTO fFecha2, cEstado3, cNum_domi, mMonto2
				FROM bdidomi:dom_cce_detalle a, bdidomi:dom_status_pago b
				WHERE a.cve_estatus = b.cve_status 
				AND a.banco_receptor <> 137
				AND a.banco_presentador = 137
				AND a.tipo_cta_ord = 05  
				AND a.cod_operacion = 30
				AND a.fecha_aplica BETWEEN YEAR(dFechaIni)||LPAD(MONTH(dFechaIni),2,0)||LPAD(DAY(dFechaIni),2,0) AND YEAR(dFechaFin)||LPAD(MONTH(dFechaFin),2,0)||LPAD(DAY(dFechaFin),2,0)
				GROUP BY 1,2
									
				--IMPRIME
				  LET cRep3 = 'echo "' || RPAD(fFecha2,12,' ') || '|' || RPAD(cEstado3,iMaxD,' ') || '|' || RPAD(cNum_domi,26,' ') || '|' || mMonto2 || '" >> ' || TRIM(cRutaRepor) || cRutaRepor3;
				  SYSTEM cRep3; 		  
			END FOREACH;
		END IF;
		COMMIT;
		LET iEnTransaccion = 0;
	
			SELECT DBINFO('utc_to_datetime',sh_curtime)
			INTO dFechaFinal
			FROM sysmaster:"informix".sysshmvals;
			
			LET cEvento = 'ACTUALIZACION FINAL DE REGISTRO EN TABLA DE CONTROL DE PROCESOS';
			
			UPDATE "informix".si_controlproc_indicadores 
			SET maxfecha_cargada = dFechaFin , flagfinalizado = 'V', coderror = vCodRet, msgerror =  cMensaje, fecha_cargafin =  dFechaFinal
			WHERE id_proc = 9
			AND nombre_proceso = cProceso
			AND fecha_procesoIni = dFechaIni
			AND fecha_procesoFin = dFechafin;	
	END IF;
	RETURN vCodRet, cMensCodRet;
END;
END PROCEDURE
DOCUMENT	
'REALIZA: Reporte de domiciliaciones de tarjeta de débito y pagos programados ',
'EQUIPO:Análisis y diseño de Mannto.4',
'FECHA:24/07/2015',
'VERSION:20150724',
'MODIFICO: Ingrid Pamela Cázarez Villegas',
'DESCRIPCION: Se realizan reportes de Domiciliaciones de tarjeta de débito y pagos programados en cuentas de captación para pagar tarjetas de crédito.',
'FECHA:08/09/2015',
'VERSION:20150908',
'MODIFICO: Ingrid Pamela Cázarez Villegas',
'DESCRIPCION: Se realizan reportes de Domiciliaciones de tarjeta de débito y pagos programados en cuentas de captación para pagar tarjetas de crédito.',
'FECHA:05/10/2015',
'VERSION:20151005',
'MODIFICO: Jose Angel Lopez Adams',
'DESCRIPCION: Se modifica consulta para extraer el archivo PPR.TDCBCPL.OBANCOS.AAAAMM.txt y evitar problemas en la validacion de fechas';

CREATE PROCEDURE "informix".sp_obtengrupocliente_pba(pnumcte CHAR(20)) 
	RETURNING 
	CHAR(5) AS codret,
	--CHAR(80) AS Mensaje,
	Char(1) AS grupoCliente;
	

	---DECLARACION DE VARIABLES
	DEFINE cCodRet CHAR(5);
	DEFINE ptipogrupo CHAR(1);
	DEFINE phit CHAR(6);
	DEFINE VSQL  CHAR(6000);
	DEFINE iSqlErr INTEGER;
	DEFINE dPaso  SMALLINT;
	DEFINE error_info CHAR(80);
	DEFINE isam_err INTEGER;	
	DEFINE vlCteLargo SMALLINT;
	DEFINE vlFecha	DATE;
	DEFINE	vlGrupoCte CHAR(1);
	
	--SET DEBUG FILE TO "/informix/marcov/sp_obtienegrupo.out";
	--TRACE ON;

	---INICIALIZACION DE VARIABLES
	LET cCodRet  = '00000';
	LET ptipogrupo = '';
	LET phit = '';
	LET VSQL = '';
	LET iSqlErr = 0;
	LET dPaso = 0;	
	LET vlCteLargo ='';
	LET	vlFecha = DATE(1);
	LET vlGrupoCte = '';

	BEGIN

	ON EXCEPTION SET iSqlErr, isam_err, error_info
	LET cCodRet = iSqlErr;
		RETURN cCodRet,'';
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT fecha_hoy 
	  into vlFecha
	 FROM bdicred:sd_fechas
	 WHERE empresa = '001';
		
	SELECT count(*) into vlCteLargo
	FROM "informix".ss_clienteslargos
	WHERE numcte = pNumCte
	  AND fecha_vig_ini<= vlFecha 
	  AND fecha_vig_fin >= vlFecha
	  AND status ='AC';
	if vlCteLargo is null then let vlCteLargo = 0; end if;  
	if vlCteLargo >0 then  LET vlGrupoCte = '8'; END IF;  

	RETURN cCodRet, vlGrupoCte;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener numero de grupo al que pertenece un cliente',
'AUTOR: Faviola Martinez Juarez',
'FECHA: 09/12/2013',
'BD: BDISOLIC';

CREATE PROCEDURE "informix".sp_cnsif_condetfol(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMFOLIO CHAR(16), cSISTEMACUENTA CHAR(10))
				returning CHAR(5)  AS Cod_Retorno,
                          CHAR(16) AS Folio,
                          CHAR(4)  AS Sucursal,
                          CHAR(08) AS Usuario,
                          DATE     AS Fecha,
                          DATETIME HOUR to FRACTION(3) AS Hora,
                          CHAR(1)  AS Cancelada,
                          CHAR(16) AS Numero_Tarjeta,
                          CHAR(08) AS Usuario_Autoriza,
                          CHAR(3)  AS Plaza,
                          CHAR(2)  AS Divisa,
                          DECIMAL(14,6) AS Tipo_Cambio,
                          CHAR(20) AS RFC_Comercial;

DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;							
--VARIABLES
DEFINE cFolio 			CHAR(16);
DEFINE cSucursal 	 	CHAR(4);
DEFINE cUsuario		    CHAR(08);
DEFINE dFecha	 		DATE;
DEFINE dHora 			DATETIME HOUR to FRACTION(3);
DEFINE cCancelada		CHAR(1);
DEFINE cNumtarjeta		CHAR(16);
DEFINE cUsuarioAutoriza CHAR(08);
DEFINE cPlaza           CHAR(03);
DEFINE cDivisa          CHAR(02);
DEFINE dTipoCambio      DECIMAL(14,6);
DEFINE cRfc_Comer       CHAR(20);
DEFINE cSistemaCuenta_1	CHAR(10);
DEFINE sNUMSERIAL       INT8;


--inicializando variables
LET  iexiste = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ;
LET cFolio 			= "";
LET cSucursal 	 	= "";
LET cUsuario	    = "";	
LET dFecha	 		= "";
LET dHora 			= "";
LET cCancelada		= "";
LET cNumtarjeta	    = "";
LET cUsuarioAutoriza    = "";
LET cPlaza          = "";
LET cDivisa         = "";
LET dTipoCambio     = 0;
LET cRfc_Comer      = "";
LET cSistemaCuenta_1	= "";
LET sNUMSERIAL          =  0;



BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet,cFolio,cSucursal,cUsuario,dFecha,dHora,cCancelada,cNumtarjeta,cUsuarioAutoriza,cPlaza,cDivisa,dTipoCambio,cRfc_Comer;
		END IF;
	END EXCEPTION;

	
		--  SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_condetfol.out";
		--  TRACE ON;

	LET cSISTEMACUENTA = TRIM(cSISTEMACUENTA);


	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMFOLIO  = ''	OR  
		cSISTEMACUENTA = '' THEN 
		LET cCodRet = "00045";
		RETURN
		cCodRet,cFolio,cSucursal,cUsuario,dFecha,dHora,cCancelada,cNumtarjeta,cUsuarioAutoriza,cPlaza,cDivisa,dTipoCambio,cRfc_Comer;
	END IF;	

	IF cSISTEMACUENTA <> 'CAPTACION' AND cSISTEMACUENTA <> 'CREDITO'  AND cSISTEMACUENTA <> 'INVERSION' THEN
		LET cCodRet = "00048";
		RETURN 
		cCodRet,cFolio,cSucursal,cUsuario,dFecha,dHora,cCancelada,cNumtarjeta,cUsuarioAutoriza,cPlaza,cDivisa,dTipoCambio,cRfc_Comer;
	END IF;     	   

	EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
	INTO cCodRet;
	  
	IF cCodRet = '00028' THEN 
		RETURN cCodRet,cFolio,cSucursal,cUsuario,dFecha,dHora,cCancelada,cNumtarjeta,cUsuarioAutoriza,cPlaza,cDivisa,dTipoCambio,cRfc_Comer;
	END IF;	

	IF cSISTEMACUENTA = 'CAPTACION' THEN 
			SELECT NVL(COUNT(folio_suc),0)  
			into iexiste
			FROM bdicheq:"informix".sc_movdia 
			WHERE folio_suc  = cNUMFOLIO AND empresa='001';
			IF iexiste  = 0 THEN 
				SELECT NVL(COUNT(folio_suc),0)  
				into iexiste
				FROM bdicheq:"informix".sc_movhis 
				WHERE folio_suc  = cNUMFOLIO AND empresa='001';
				IF iexiste  = 0 THEN
					SELECT NVL(COUNT(folio_suc),0)  
					into iexiste
					FROM bdicheq:"informix".sc_movhis_old 
					WHERE folio_suc  = cNUMFOLIO AND empresa='001';
					IF iexiste  = 0 THEN
						SELECT NVL(COUNT(folio_suc),0)  
						into iexiste
						FROM bdicheq:"informix".sc_movhis_old2 
						WHERE folio_suc  = cNUMFOLIO AND empresa='001';
						IF iexiste  = 0 THEN
							SELECT NVL(COUNT(folio_suc),0)  
							into iexiste
							FROM bdicheq:"informix".sc_movhis_old3 
							WHERE folio_suc  = cNUMFOLIO AND empresa='001';
							IF iexiste  = 0 THEN
								SELECT NVL(COUNT(folio_suc),0)  
								into iexiste
								FROM bdicheq:"informix".sc_movhis_old4 
								WHERE folio_suc  = cNUMFOLIO AND empresa='001';
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;

			IF iexiste  = 0 THEN
				LET cCodRet = "00017";
				RETURN 
				cCodRet,cFolio,cSucursal,cUsuario,dFecha,dHora,cCancelada,cNumtarjeta,cUsuarioAutoriza,cPlaza,cDivisa,dTipoCambio,cRfc_Comer;
			END IF;

			FOREACH			
			SELECT LIMIT 1 mm.folio_suc as Folio,mm.Sucursal,mm.usuario,mm.fech_alt,mm.fech_hor,mm.cancelad,
				   NVL(mm.num_tarjeta,''),mm.usuautoriza,mm.num_serial
			INTO 		
			cFolio,cSucursal,cUsuario,dFecha,dHora,cCancelada,cNumtarjeta,cUsuarioAutoriza,sNUMSERIAL	
				FROM  bdicheq:"informix".sc_movdia mm
				WHERE mm.folio_suc = cNUMFOLIO AND mm.empresa='001'
			UNION
				SELECT mm.folio_suc as Folio,mm.Sucursal,mm.usuario,mm.fech_alt,mm.fech_hor,mm.cancelad,
					  mm.num_tarjeta,mm.usuautoriza,mm.num_serial
				  FROM bdicheq:"informix".sc_movhis AS mm
				 WHERE mm.folio_suc = cNUMFOLIO AND mm.empresa='001'
			UNION
				SELECT mm.folio_suc as Folio,mm.Sucursal,mm.usuario,mm.fech_alt,mm.fech_hor,mm.cancelad,
					   mm.num_tarjeta,mm.usuautoriza,mm.num_serial
				  FROM bdicheq:"informix".sc_movhis_old AS mm 
				 WHERE mm.folio_suc = cNUMFOLIO AND mm.empresa='001'
			UNION
				SELECT mm.folio_suc as Folio,mm.Sucursal,mm.usuario,mm.fech_alt,mm.fech_hor,mm.cancelad,
					   mm.num_tarjeta,mm.usuautoriza,mm.num_serial
				  FROM bdicheq:"informix".sc_movhis_old2 AS mm
				 WHERE mm.folio_suc = cNUMFOLIO AND mm.empresa='001'
			UNION
				SELECT mm.folio_suc as Folio,mm.Sucursal,mm.usuario,mm.fech_alt,mm.fech_hor,mm.cancelad,
					mm.num_tarjeta,mm.usuautoriza,mm.num_serial
				  FROM bdicheq:"informix".sc_movhis_old3 AS mm
				 WHERE mm.folio_suc = cNUMFOLIO AND mm.empresa='001'
			UNION
				SELECT mm.folio_suc as Folio,mm.Sucursal,mm.usuario,mm.fech_alt,mm.fech_hor,mm.cancelad,
					   mm.num_tarjeta,mm.usuautoriza,mm.num_serial
				  FROM bdicheq:"informix".sc_movhis_old4 AS mm
				 WHERE mm.folio_suc = cNUMFOLIO AND mm.empresa='001'
			ORDER BY mm.num_serial

            IF cNumtarjeta="0" THEN
                LET cNumtarjeta="";
            END IF;

			RETURN 
			cCodRet,cFolio,cSucursal,cUsuario,dFecha,dHora,cCancelada,cNumtarjeta,cUsuarioAutoriza,cPlaza,cDivisa,dTipoCambio,cRfc_Comer WITH RESUME;
			END FOREACH;

	ELIF cSISTEMACUENTA = 'CREDITO' THEN 
		SELECT NVL(COUNT(folio_suc),0)  
		into iexiste
		FROM bdicred:sd_movdia 
		WHERE folio_suc = cNUMFOLIO AND empresa='001';
		IF iexiste  = 0 THEN 
			SELECT NVL(COUNT(folio_suc),0)  
			into iexiste
			FROM bdicred:sd_movhis 
			WHERE folio_suc = cNUMFOLIO AND empresa='001';
			IF iexiste  = 0 THEN 
				SELECT NVL(COUNT(folio_suc),0)  
				into iexiste
				FROM bdicred:sd_movhis_new 
				WHERE folio_suc = cNUMFOLIO AND empresa='001';
				IF iexiste  = 0 THEN 
					SELECT NVL(COUNT(folio_suc),0)  
					into iexiste
					FROM bdicred:sd_movdiacrd 
					WHERE folio_suc = cNUMFOLIO AND empresa='001';
					IF iexiste  = 0 THEN 
						SELECT NVL(COUNT(folio_suc),0)  
						into iexiste
						FROM bdicred:sd_movhiscrd 
						WHERE folio_suc = cNUMFOLIO AND empresa='001';					
					END IF;	
				END IF;
			END IF;
		END IF;

		IF iexiste  = 0 THEN 
			LET cCodRet = "00017";
			RETURN 
			cCodRet,cFolio,cSucursal,cUsuario,dFecha,dHora,cCancelada,cNumtarjeta,cUsuarioAutoriza,cPlaza,cDivisa,dTipoCambio,cRfc_Comer;
		END IF;

		FOREACH
		SELECT LIMIT 1  mm.folio_suc as Folio,mm.Sucursal,mm.usuario,mm.fecha_mov,mm.hora_mov,mm.reversado,
				   NVL(mm.nro_tarjeta,''),mm.plaza,mm.divisa,mm.tipo_cambio,mm.rfc_comer		
			INTO 		
			cFolio,cSucursal,cUsuario,dFecha,dHora,cCancelada,cNumtarjeta,cPlaza,cDivisa,dTipoCambio,cRfc_Comer	 
			FROM bdicred:sd_movdia  as mm
			WHERE mm.folio_suc  = cNUMFOLIO AND mm.empresa='001'			
		UNION
				SELECT mm.folio_suc as Folio,mm.Sucursal,mm.usuario,mm.fecha_mov,mm.hora_mov,mm.reversado,
						  mm.nro_tarjeta,mm.plaza,mm.divisa,mm.tipo_cambio,mm.rfc_comer
				FROM bdicred:sd_movhis  as mm
				WHERE mm.folio_suc  = cNUMFOLIO AND mm.empresa='001'			
		UNION
				SELECT mm.folio_suc as Folio,mm.sucursal,mm.usuario,mm.fecha_mov,mm.hora_mov,mm.reversado,
						  mm.nro_tarjeta,mm.plaza,mm.divisa,mm.tipo_cambio,mm.rfc_comer
				FROM bdicred:sd_movhis_new  as mm
				WHERE mm.folio_suc  = cNUMFOLIO AND mm.empresa='001'		
		UNION 	
				SELECT mm.folio_suc as Folio,mm.Sucursal,mm.usuario,mm.fecha_mov,mm.hora_mov,mm.reversado,
						  mm.nro_tarjeta,mm.plaza,mm.divisa,mm.tipo_cambio,mm.rfc_comer
				FROM   bdicred:sd_movdiacrd    as mm
				WHERE mm.folio_suc  = cNUMFOLIO AND mm.empresa='001'
		UNION
				SELECT mm.folio_suc as Folio,mm.Sucursal,mm.usuario,mm.fecha_mov,mm.hora_mov,mm.reversado,
						  mm.nro_tarjeta,mm.plaza,mm.divisa,mm.tipo_cambio,mm.rfc_comer
				FROM bdicred:sd_movhiscrd as mm
				WHERE mm.folio_suc  = cNUMFOLIO AND mm.empresa='001'

                IF cNumtarjeta="0" THEN
                    LET cNumtarjeta="";
                END IF;

				RETURN 
				cCodRet,cFolio,cSucursal,cUsuario,dFecha,dHora,cCancelada,cNumtarjeta,cUsuarioAutoriza,cPlaza,cDivisa,dTipoCambio,cRfc_Comer WITH RESUME;							
		END FOREACH;
	ELIF cSISTEMACUENTA = 'INVERSION' THEN
		SELECT {+INDEX (bdinvers:sv_movdia ix161_2)} NVL(COUNT(folio_suc),0)  
		into iexiste
		FROM bdinvers:sv_movdia 
		WHERE folio_suc  = cNUMFOLIO AND empresa='001';

		IF iexiste  = 0 THEN 
			SELECT {+INDEX (bdinvers:sv_movhis idx_svfolsuc)} NVL(COUNT(folio_suc),0)  
			into iexiste
			FROM bdinvers:sv_movhis 
			WHERE folio_suc  = cNUMFOLIO AND empresa='001';
			IF iexiste  = 0 THEN
				LET cCodRet = "00017";
				RETURN 
				cCodRet,cFolio,cSucursal,cUsuario,dFecha,dHora,cCancelada,cNumtarjeta,cUsuarioAutoriza,cPlaza,cDivisa,dTipoCambio,cRfc_Comer;
			END IF;
		END IF;

		FOREACH			
			SELECT {+INDEX (bdinvers:sv_movdia ix161_2)} LIMIT 1 mm.folio_suc as Folio,mm.Sucursal,mm.usuario,mm.fech_alt,mm.fech_hor,mm.cancelad,mm.plaza,
				   mm.num_serial
			INTO 		
			cFolio,cSucursal,cUsuario,dFecha,dHora,cCancelada,cPlaza,sNUMSERIAL	
				FROM  bdinvers:sv_movdia mm
				WHERE mm.folio_suc = cNUMFOLIO AND mm.empresa='001'
			UNION
				SELECT {+INDEX (bdinvers:sv_movhis idx_svfolsuc)} mm.folio_suc as Folio,mm.Sucursal,mm.usuario,mm.fech_alt,mm.fech_hor,mm.cancelad,mm.plaza,
					  mm.num_serial
				  FROM bdinvers:sv_movhis AS mm
				 WHERE mm.folio_suc = cNUMFOLIO AND mm.empresa='001'
			ORDER BY mm.num_serial DESC

			RETURN 
			cCodRet,cFolio,cSucursal,cUsuario,dFecha,dHora,cCancelada,cNumtarjeta,cUsuarioAutoriza,cPlaza,cDivisa,dTipoCambio,cRfc_Comer WITH RESUME;
		END FOREACH;

	END IF;
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de Datos Complementarios y Adicionales (para el caso de cuentas de Crédito). ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  Folio",
"FECHA : 13-02-2012",
"BD    : bdinteg",
"VER   : 2.0";

CREATE PROCEDURE "informix".sp_obtener_10dias
(
pFecha	DATE
)
RETURNING
	CHAR(6)		AS cod_ret,
	DATE		AS fecha_10dias
	
	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cCodRet			CHAR(6);
	DEFINE dtFecha10		DATE;
	DEFINE iContador		SMALLINT;
	
	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cCodRet             = "000000";
	LET dtFecha10			= NULL;
	LET iContador			= 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dtFecha10;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--  SET DEBUG FILE TO "/informix/PORTABILIDAD_NOMINA/sp_obtener_10dias.out";
	--  TRACE ON;
	
	WHILE dtFecha10 IS NULL
	
		LET pFecha = pFecha + 1 UNITS DAY;
		
		IF NOT EXISTS(SELECT fecha FROM bdinteg:"informix".si_feriado 
						WHERE fecha = pFecha AND empresa = '001'AND laborable = 'N') THEN
			
			IF WEEKDAY(pFecha) IN (1,2,3,4,5) THEN
				LET iContador = iContador + 1;
			END IF
			
		END IF
		
		IF iContador = 10 THEN
			LET dtFecha10 = pFecha;
			EXIT WHILE;
		END IF
		
	
	END WHILE
	
	
	RETURN cCodRet, dtFecha10;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: ',
'BD: bdinteg', 
'AUTOR: Alex Villela ',
'FECHA: septiembre 2015';

CREATE PROCEDURE "informix".sp_cnsif_consultamovtosdiarioscta3_pba(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),dPERIODOI DATE,dPERIODOF DATE, cSISTEMACUENTA CHAR(20), pUsuario CHAR(8),cSuc CHAR(4),mImporte MONEY(14,2), pNumRegistro INTEGER,pRecuperacion INTEGER)

                    returning CHAR(5)  AS Cod_Retorno,
                                DATE     AS Fecha,
                                DATETIME HOUR to FRACTION(3) AS Hora,
                                CHAR(4)  AS CveTransaccion,
                                CHAR(50) AS Desc_Transaccion,
                                CHAR(16) AS Folio,
                                DATE     AS Periodo_Inicial,
                                MONEY(14,2) AS Monto,
                                DATE     AS Periodo_Final,
                                CHAR(20) AS Sistema_Cuenta,
                                CHAR(1)  AS Naturaleza,
                                CHAR(40) AS Referencia,
                                CHAR(1)  AS Reversos,
                                CHAR(4)  AS Sucursal,
                                CHAR(20) AS CveProcedencia,
                                CHAR(50) AS Desc_Procedencia,
                                MONEY(14,2) AS Saldo,
                                CHAR(20) AS Numero_Tarjeta,
                                CHAR(1)  AS Reversados,
                          CHAR(8)  AS Usuario,
                                CHAR(23) AS Referencia23;

DEFINE iexiste                INT;
DEFINE cCodRet                CHAR(5);
DEFINE iSql_err           INT;                                  
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE dFecha               DATE;
DEFINE dHora                DATETIME HOUR to FRACTION(3);
DEFINE cTransaccion          CHAR(4);
DEFINE cD_Transaccion     CHAR(50);
DEFINE mMonto               MONEY(14,2);
DEFINE cNaturaleza          CHAR(1);
DEFINE mSaldo                MONEY(14,2);
DEFINE cReferencia           CHAR(40);
DEFINE cReversos          CHAR(1);
DEFINE cReversados          CHAR(1);
DEFINE cSucursal           CHAR(4);
DEFINE cFolio                CHAR(16);
DEFINE cProcedencia          CHAR(20);
DEFINE cD_Procedencia     CHAR(50);
DEFINE dPeriodoI_1          DATE;
DEFINE dPeriodoF_1          DATE;
DEFINE sNUMSERIAL       INT8;
DEFINE sNumSecuencia    INT8;
DEFINE cUsuario         CHAR(8);
DEFINE cReferencia23    CHAR(23);
--SISTEMA DE CUENTA 06 VARIABLES
DEFINE cNumtarjeta          CHAR(20);
--VARIABLES PARA FECHAS HISTORICAS
DEFINE cconsmovhis      CHAR(10);
DEFINE cconsmovhisold   CHAR(10);
DEFINE cconsmovhisold2  CHAR(10);
DEFINE cconsmovhisold3  CHAR(10);
DEFINE cconsmovhisold4  CHAR(10);
--VARIABLES DE PAGINACION
DEFINE iCont            INT;
--VARIABLE PARA LA EMPRESA
DEFINE pEmpresa     CHAR(3);
DEFINE cCodfun          CHAR(3);
DEFINE cCodref          INTEGER;
DEFINE iExisteCta       INT;
DEFINE iKiosko			INT;
DEFINE iAbierto			INT;
--inicializando variables
LET  iexiste = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ;    
LET dFecha               = "";
LET dHora                = "";
LET cTransaccion     = "";
LET cD_Transaccion     = "";
LET mMonto               = 0;
LET cNaturaleza          = "";
LET mSaldo                = 0;
LET cReferencia          = "";
LET cReversos          = "";
LET cReversados          = "";
LET cSucursal           = "";
LET cFolio                = "";
LET cProcedencia     = "";
LET cD_Procedencia     = "";
LET dPeriodoI_1          = "";
LET dPeriodoF_1          = "";
LET sNUMSERIAL      =  0;
LET sNumSecuencia     =  0;
LET cUsuario        = "";
LET cReferencia23   = "";
--SISTEMA DE CUENTA 06 VARIABLES
LET cNumtarjeta     = "";
--VARIABLES PARA FECHAS HISTORICAS
LET cconsmovhis     = '';
LET cconsmovhisold  = '';
LET cconsmovhisold2 = '';
LET cconsmovhisold3 = '';
LET cconsmovhisold4 = '';
--VARIABLES DE PAGINACION
LET iCont       = 0;
LET pEmpresa   = '001';
LET cCodfun               ='';
LET cCodref               =0;
LET  iExisteCta = 0;
LET iKiosko               =0;
LET iAbierto              =0;

BEGIN
     ON EXCEPTION SET iSql_err
          IF iSql_err <> 0 THEN
               LET cCodRet = iSql_err;
               RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
               cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
          END IF;
     END EXCEPTION;
                

	SET ISOLATION TO COMMITTED READ LAST COMMITTED;

    --SET DEBUG FILE TO "/informix/CHVN/sp_cnsif_consultamovtosdiarioscta3.out";
    --TRACE ON;
              
     IF cID_USUARIOC = ''      OR
        cID_FUNCIONC = ''      OR
        cNUMCUENTA  = ''     OR
        dPERIODOI   IS NULL OR
        dPERIODOF      IS NULL     OR
        cSISTEMACUENTA = '' THEN
        LET cCodRet = "00036";
        RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
        cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
     END IF;

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
          RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
          cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;                        
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
            cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
        END IF;
    END IF; 
     IF cSISTEMACUENTA <> 'CAPTACION' AND cSISTEMACUENTA <> 'CREDITO'  AND cSISTEMACUENTA <> 'INVERSIONES' THEN
          LET cCodRet = "00037";
          RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
          cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
     END IF;

     --VALIDACION
	IF cSISTEMACUENTA = 'CAPTACION' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'01','1')
		INTO cCodRet;
	END IF;

	IF cSISTEMACUENTA = 'CREDITO' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
		INTO cCodRet;
	END IF;

	IF cSISTEMACUENTA = 'INVERSIONES' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'03','1')
		INTO cCodRet;
	END IF;

	IF (cCodRet != '00000')  THEN
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
			  cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
	END IF;
     -- TERMINA VALIDACION
	
	IF cSISTEMACUENTA = 'CAPTACION' THEN
	IF pNumRegistro = 0 THEN
		DELETE FROM "informix".si_tempomovs WHERE ejecutivosif = cID_USUARIOC AND no_cuenta = cNUMCUENTA;
        SET ISOLATION TO DIRTY READ;
		SELECT valor
		INTO cconsmovhis
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'fechcon_movhis';

		SELECT valor
		INTO cconsmovhisold
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'FechIniCon_movhis_ol';

		SELECT valor
		INTO cconsmovhisold2
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'FechaIniMovhisOld2';

		SELECT valor
		INTO cconsmovhisold3
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'vfechconmovhisold3';
		
		SELECT valor
		INTO cconsmovhisold4
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'FechaIniMovhisOld4';
		
		LET iAbierto = 1;
		IF dPERIODOF = TODAY THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH WITH HOLD
			SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
			MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
			INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
			cNumtarjeta,cUsuario,cReferencia23
			FROM bdicheq:"informix".sc_movdia MO
			LEFT JOIN bdinteg:si_transacc TR
			ON TR.empresa = '001'
			AND TR.numero = MO.transacc
			AND TR.sistema = '01'
			WHERE MO.fech_alt = dPERIODOF AND MO.empresa='001' AND MO.cuenta = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
						
			LET iCont=iCont+1;
			
			INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
				sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
			VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
				mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
			IF iCont >= 1000 THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			END FOREACH;
		END IF;

		IF (dPERIODOI < TODAY AND dPERIODOF >= cconsmovhis) THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH WITH HOLD
			SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
			MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
			INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
			cNumtarjeta,cUsuario,cReferencia23
			FROM bdicheq:"informix".sc_movhis MO
			LEFT JOIN bdinteg:si_transacc TR
			ON TR.empresa = '001'
			AND TR.numero = MO.transacc
			AND TR.sistema = '01'
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa='001' AND MO.cuenta  = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
						
			LET iCont=iCont+1;
			
			INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
				sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
			VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
				mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
			IF iCont >= 1000 THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			END FOREACH;
		END IF;
		
		IF (dPERIODOI < cconsmovhis AND dPERIODOF >= cconsmovhisold) THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH WITH HOLD
			SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
			MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
			INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
			cNumtarjeta,cUsuario,cReferencia23
			FROM bdicheq:"informix".sc_movhis_old MO
			LEFT JOIN bdinteg:si_transacc TR
			ON TR.empresa = '001'
			AND TR.numero = MO.transacc
			AND TR.sistema = '01'
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa = '001' AND MO.cuenta  = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
						
			LET iCont=iCont+1;
			
			INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
				sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
			VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
				mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
			IF iCont >= 1000 THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			END FOREACH;
		END IF;
		
		IF (dPERIODOI < cconsmovhisold AND dPERIODOF >= cconsmovhisold2) THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH WITH HOLD
			SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
			MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
			INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
			cNumtarjeta,cUsuario,cReferencia23
			FROM bdicheq:"informix".sc_movhis_old2 MO
			LEFT JOIN bdinteg:si_transacc TR
			ON TR.empresa = '001'
			AND TR.numero = MO.transacc
			AND TR.sistema = '01'
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa = '001' AND MO.cuenta  = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
			
			LET iCont=iCont+1;
			
			INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
				sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
			VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
				mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
			IF iCont >= 1000 THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			END FOREACH;
		END IF;

		SET ISOLATION TO DIRTY READ;
			SELECT {+INDEX (bdicheq:sc_maechq idx_sc_maechq)} NVL(COUNT(cuenta),0) 
			INTO iExisteCta
			FROM bdicheq:sc_maechq 
			WHERE cuenta  = cNUMCUENTA
			AND producto IN ('1200', '9901', '1600', '2200', '2600');
		
		IF iExisteCta = 0 THEN
			IF (dPERIODOI < cconsmovhisold2 AND dPERIODOF >= cconsmovhisold3) THEN
				SET ISOLATION TO DIRTY READ;
				FOREACH WITH HOLD
				SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
				MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
				INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
				cNumtarjeta,cUsuario,cReferencia23
				FROM bdicheq:"informix".sc_movhis_old3 MO
				LEFT JOIN bdinteg:si_transacc TR
				ON TR.empresa = '001'
				AND TR.numero = MO.transacc
				AND TR.sistema = '01'
				WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa='001' AND MO.cuenta  = cNUMCUENTA
				AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
				
				LET iCont=iCont+1;
				
				INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
					sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
				VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
					mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
				IF iCont >= 1000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				END FOREACH;
			END IF;
			IF (dPERIODOI < cconsmovhisold3 AND dPERIODOF >= cconsmovhisold4) THEN
				SET ISOLATION TO DIRTY READ;
				FOREACH WITH HOLD
				SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
				MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
				INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
				cNumtarjeta,cUsuario,cReferencia23
				FROM bdicheq:"informix".sc_movhis_old4 MO
				LEFT JOIN bdinteg:si_transacc TR
				ON TR.empresa = '001'
				AND TR.numero = MO.transacc
				AND TR.sistema = '01'
				WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa='001' AND MO.cuenta  = cNUMCUENTA
				AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
				
				LET iCont=iCont+1;
				
				INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
					sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
				VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
					mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
				IF iCont >= 1000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				END FOREACH;
			END IF;
		END IF;
		
		IF TRIM(SUBSTRING(cNUMCUENTA FROM 1 FOR 1)) = '8' THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH WITH HOLD
			SELECT MO.fecha_alt as fech_alt,extend(MO.fech_hor_fin,HOUR to FRACTION(3)),MO.transacc,TR.descripcion,MO.monto,DECODE(MO.tpo_mov,"D","A","C","C"),
			MO.sdo_cuenta_origen,MO.referencia,'','',MO.secuencia,'','TRANSFER',''
			INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
			cNumtarjeta,cUsuario,cReferencia23
			FROM bditransfer:tf_success_transac  MO
			LEFT JOIN bditransfer:tf_cat_transac_mps TR
			ON MO.transacc = TR.transac
			WHERE MO.cuenta = cNUMCUENTA
			AND MO.fecha_alt BETWEEN dPERIODOI AND dPERIODOF
			AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
			AND MO.fecha_alt < to_date('20/03/2015','%d/%m/%Y')
			
			LET iCont=iCont+1;
			
			INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
				sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
			VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
				mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
			IF iCont >= 1000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
			END IF;
			END FOREACH;
		END IF;
		
		IF iAbierto = 1 THEN
			LET iAbierto = 0;
			COMMIT WORK;
			BEGIN WORK;
		END IF;
		
		LET iCont = 0;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT SKIP pNumRegistro FIRST pRecuperacion codret, ejecutivosif, no_cuenta, fech_alt, 
			fech_hor, transacc, descripcion, monto_tot, naturaleza, sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_tarjeta, usuario, 
			referencia_23
			INTO cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
				cNumtarjeta,cUsuario,cReferencia23
			FROM "informix".si_tempomovs
			WHERE ejecutivosif = cID_USUARIOC AND no_cuenta = cNUMCUENTA
			ORDER BY fech_alt DESC,fech_hor DESC
			
			IF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia 
				WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia 
				WHERE transacc=cTransaccion AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE sucursal=cSucursal AND transacc='')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia 
				WHERE sucursal=cSucursal AND transacc='';
			ELSE
				LET cProcedencia="";
				LET cD_Procedencia="";
			END IF;
			
			
			LET iCont=iCont+1;
			
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
				  cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH RESUME;
		END FOREACH;
		IF iCont = 0 THEN
			LET cCodRet = '1001'; 
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
				  cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		END IF;
	ELSE
		FOREACH
			SELECT {+INDEX (bdinteg:"informix".si_tempomovs idx_tempomovs)} SKIP pNumRegistro FIRST pRecuperacion codret, ejecutivosif, no_cuenta, fech_alt, 
			fech_hor, transacc, descripcion, monto_tot, naturaleza, sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_tarjeta, usuario, 
			referencia_23
			INTO cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
				cNumtarjeta,cUsuario,cReferencia23
			FROM "informix".si_tempomovs
			WHERE ejecutivosif = cID_USUARIOC AND no_cuenta = cNUMCUENTA
			ORDER BY fech_alt DESC,fech_hor DESC
			
			IF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia 
				WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia 
				WHERE transacc=cTransaccion AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE sucursal=cSucursal AND transacc='')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia 
				WHERE sucursal=cSucursal AND transacc='';
			ELSE
				LET cProcedencia="";
				LET cD_Procedencia="";
			END IF;
			
			
			LET iCont=iCont+1;
			
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
				  cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH resume;
		END FOREACH;
		IF iCont = 0 THEN
			LET cCodRet = '1001'; 
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		END IF
	END IF;
		
	ELIF cSISTEMACUENTA = 'CREDITO' THEN
		SET ISOLATION TO DIRTY READ;
		SELECT NVL(COUNT(num_credito),0) 
		INTO iExisteCta
		FROM bdicred:sd_maecred
		WHERE empresa = '001' AND num_credito = cNUMCUENTA;		

		IF iExisteCta > 0 THEN
			FOREACH
				SELECT SKIP pNumRegistro FIRST pRecuperacion {+INDEX (bdicred:sd_movdia mov4)} MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
				MO.transacc_suc,TR.descripcion,MO.referencia,
				MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				INTO          
				cCodfun,cCodref,dFecha,dHora,cNumtarjeta,cFolio,cTransaccion,cD_Transaccion,cReferencia,mMonto,cNaturaleza,cReversos,cSucursal,
				dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cUsuario,cReferencia23
				FROM bdicred:sd_movdia MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END     
			UNION
				SELECT {+INDEX (bdicred:sd_movhis inx_movhis4)} MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
				MO.transacc_suc,TR.descripcion,MO.referencia,
				MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				FROM bdicred:sd_movhis  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END                    
			ORDER BY MO.secuencia DESC

			IF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE sucursal=cSucursal AND transacc='')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE sucursal=cSucursal AND transacc='';
			ELSE
				LET cProcedencia="";
				LET cD_Procedencia="";
			END IF;
			  
			LET iCont=iCont+1;

			IF cCodfun ='001' AND cCodref in (1,2,3) THEN
				IF iCont>0 THEN
					 LET iCont=iCont - 1;
				END IF;
			ELIF cCodfun ='002' AND cCodref =1 THEN
				IF iCont>0 THEN
					 LET iCont=iCont - 1;
				END IF;
			ELSE
				RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH resume;
			END IF;

			END FOREACH;
		ELSE
			FOREACH
				SELECT SKIP pNumRegistro FIRST pRecuperacion MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
				MO.transacc_suc,TR.descripcion,MO.referencia,
				MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				INTO          
				cCodfun,cCodref,dFecha,dHora,cNumtarjeta,cFolio,cTransaccion,cD_Transaccion,cReferencia,mMonto,cNaturaleza,cReversos,cSucursal,
				dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cUsuario,cReferencia23
				FROM bdicred:sd_movdiacrd  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END     
			UNION
				SELECT MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
				MO.transacc_suc,TR.descripcion,MO.referencia,
				MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				FROM bdicred:sd_movhiscrd  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END     
			ORDER BY MO.secuencia DESC

			IF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE sucursal=cSucursal AND transacc='')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE sucursal=cSucursal AND transacc='';
			ELSE
				LET cProcedencia="";
				LET cD_Procedencia="";
			END IF;
			  
			LET iCont=iCont+1;

			IF cCodfun ='001' AND cCodref in (1,2,3) THEN
				IF iCont>0 THEN
					 LET iCont=iCont - 1;
				END IF;
			ELIF cCodfun ='002' AND cCodref =1 THEN
				IF iCont>0 THEN
					 LET iCont=iCont - 1;
				END IF;
			ELSE
				RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH resume;
			END IF;

			END FOREACH;
		END IF;
						
		IF iCont = 0 AND pNumRegistro=0 THEN
		   LET cCodRet = '00039';
				RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
						cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		ELIF iCont = 0 THEN
		   LET cCodRet = '1001';
				RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
						cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
	END IF
	ELIF cSISTEMACUENTA = 'INVERSIONES' THEN
	 SET ISOLATION TO DIRTY READ;
	  FOREACH
		   SELECT SKIP pNumRegistro FIRST pRecuperacion     
		   MO.fech_alt,MO.fech_hor,MO.folio_suc,MO.transacc,TR.descripcion,MO.monto_tot,MO.cancelad,dPERIODOI,dPERIODOF,MO.secuencia,MO.sucursal,MO.usuario,MO.num_serial
		   INTO
		   dFecha,dHora,cFolio,cTransaccion,cD_Transaccion,mMonto,cReversados,dPeriodoI_1,dPeriodoF_1,sNumSecuencia,cSucursal,cUsuario,sNUMSERIAL
		   FROM bdinvers:sv_maeinv MC
		   LEFT JOIN bdinvers:sv_movdia MO
		   ON MC.cuenta = MO.cuenta
		   LEFT JOIN bdinteg:si_transacc TR
		   ON MO.transacc = TR.numero 
		   WHERE MO.cuenta = cNUMCUENTA
		   AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
		AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
		AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
		AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END     
		   UNION
		   SELECT MO.fech_alt,MO.fech_hor,MO.folio_suc,MO.transacc,TR.descripcion,MO.monto_tot,MO.cancelad,dPERIODOI,dPERIODOF,MO.secuencia,MO.sucursal,MO.usuario,MO.num_serial
		   FROM bdinvers:sv_maeinv MC
		   LEFT JOIN bdinvers:sv_movhis MO
		   ON MC.cuenta = MO.cuenta
		   LEFT JOIN bdinteg:si_transacc TR
		   ON MO.transacc = TR.numero 
		   WHERE MO.cuenta = cNUMCUENTA
		   AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
		AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
		AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
		AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END     
		ORDER BY MO.num_serial DESC

		LET iCont=iCont+1;    
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
		cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH resume;
			   
	  END FOREACH;

	  IF iCont = 0 THEN
	  LET cCodRet = '1001';
		   RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				   cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
	  END IF
	END IF
END

END PROCEDURE

DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Este sp realizara la busqueda por tipo de cuenta, dependiendo de tipo de cuenta regresara los datos correspondientes, para captacion o cuenta de cheques, para cuentas tipo credito 06 que seran de credito y las cuentas tipo 03 que son de  tipo inversiones",
"FECHA : 09-02-2012",
"ACTUALIZO: Victor Hugo Sánchez M.",
"MODIFICACION: Se agregaron los parametros empleado,sucursal e importe para filtrar movimientos",
"FECHA: 04/07/2012",
"ACTUALIZO: Oscar Flores Conde (M-Finis Soluciones y Servicios Financieros)",
"MODIFICACION: Se agregaron el parametro de entrada para filtrar los movimientos reversados, se agrega en los parametros de salida la referencia a 23 posiciones",
"FECHA: 02/12/2013",
"BD    : bdinteg",
"VER   : 3.0";

CREATE PROCEDURE "informix".sp_altamasivaempnet_busca_pba()
RETURNING CHAR(5);
    
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE vcCodRet     CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    
    DEFINE vcCodEmpresa     CHAR(3);
    DEFINE vcNombreArchivo  CHAR(30);
    DEFINE vcNumCte         CHAR(9);
    DEFINE vcCodRetAlta     CHAR(5);
    
    LET viSqlErr    = 0;
    LET viIsamErr   = 0;
    LET vcDescErr   = '';
    LET vcCodRet    = '000';
    LET vcCodRet2   = '';
    LET vcCodRet3   = '';
    
    LET vcCodEmpresa    = '';
    LET vcNombreArchivo = '';
    LET vcNumCte        = '';
    LET vcCodRetAlta    = '';
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_busca.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_busca.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            RETURN vcCodRet;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // PROCESA LOS ARCHIVOS QUE ESTEN PENDIENTES
    FOREACH WITH HOLD 
        SELECT alta.cod_empresa, alta.nombre_archivo, emp.numcte
          INTO vcCodEmpresa, vcNombreArchivo, vcNumCte
          FROM bdinteg:si_altamasivaempnet_ctrl alta,
               bdicheq:sc_nominaempresas emp
         WHERE alta.cod_empresa = emp.codigo
           AND alta.status = '0'
           
        CALL sp_altamasivaempnet_procesa( vcCodEmpresa, vcNumCte, vcNombreArchivo )
        RETURNING vcCodRetAlta;
    END FOREACH;
    
    RETURN vcCodRet;
    
    END;
    
END PROCEDURE;