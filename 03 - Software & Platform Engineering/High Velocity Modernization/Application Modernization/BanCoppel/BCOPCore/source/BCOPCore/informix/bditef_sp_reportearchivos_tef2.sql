CREATE PROCEDURE "informix".sp_reportearchivos_tef2 (pnombrearchivo char(20),ptipoarchivo char(4),pfechainicial char(8),pfechafinal char(8),ptiporeporte smallint,pregistros integer, precuperacion integer)
	RETURNING 
	char(5) as codigo, 
	char(10) as fecha_presentacion, 
	char(20) as nombre_arch, 
	char(2) as cod_operacion, 
	char(4) as no_sucursal, 
	char(40) as nombre_ord, 
	char(20)as num_cta_ord, 
	char(50) as tipo_operacion, 
	char(7) as ref_numerica, 
	decimal(11,2) as importe, 
	char(40) as nombre_rec, 
	char(20) as num_cta_rec, 
	char(7) as num_secuencia, 
	char(40) as tipo_cta_destino, 
	char(40) as bancodestino, 
	char(20) as status, 
	decimal(18,2) as imp_operaciones, 
	char(8) as fecha_presentacion2, 
	char(2) as motivo_dev, 
	char(50) as descripcion,
	integer as registrosCod61,
	decimal(18,2) as totalImporteCod61,
	integer as registrosCod62,
	decimal(18,2) as totalImporteCod62;


	DEFINE vsqlerr				INTEGER;
    DEFINE cCodret				CHAR(5);
	DEFINE cFechaPresentacion	CHAR(10);
	DEFINE cNombreArchivo		CHAR(20);
	DEFINE cCodOperacion		CHAR(2);
	DEFINE cSucursal			CHAR(4);
	DEFINE cNombreOrd			CHAR(40);
	DEFINE cNumCtaOrd			CHAR(20);
	DEFINE cTipoOperacion		CHAR(50);
	DEFINE cRefNumerica			CHAR(7);
	DEFINE dImporte				DECIMAL(11,2);
	DEFINE cNombreDestino		CHAR(40);
	DEFINE cNumCtaDestino		CHAR(20);
	DEFINE cSecuencia			CHAR(7);
	DEFINE cTipoCtaDestino		CHAR(40);
	DEFINE cBanco				CHAR(40);
	DEFINE cStatus				CHAR(20);
	DEFINE dImpOperaciones		DECIMAL(18,2);
	DEFINE cMotivoDev			CHAR(2);
	DEFINE cDescripcionDev		CHAR(50);
	DEFINE cRegistrosCod61		INTEGER;
	DEFINE cTotalImporteCod61	DECIMAL(18,2);
	DEFINE cRegistrosCod62		INTEGER;
	DEFINE cTotalImporteCod62	DECIMAL(18,2);
	
	
    LET cCodret	= '00000';
	LET cFechaPresentacion = '';
	LET cNombreArchivo = '';
	LET cCodOperacion = '';
	LET cSucursal = '';
	LET cNombreOrd = '';
	LET cNumCtaOrd = '';
	LET cTipoOperacion = '';
	LET cRefNumerica = '';
	LET dImporte = 0.00;
	LET cNombreDestino= '';
	LET cNumCtaDestino = '';
	LET cSecuencia = '';
	LET cTipoCtaDestino = '';
	LET cBanco = '';
	LET cStatus = '';
	LET dImpOperaciones = 0.00;
	LET cMotivoDev = '';
	LET cDescripcionDev = '';
	LET cRegistrosCod61 = 0;
	LET cTotalImporteCod61 = 0.00;
	LET cRegistrosCod62 = 0;
	LET cTotalImporteCod62 = 0.00;
	
	--SET DEBUG FILE TO "/tmp/mfinis/sp_reportearchivos_tef2.out";
	--TRACE ON;
	BEGIN
		ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN	
                LET cCodret = vsqlerr;
				
				INSERT INTO tef_errores (fecha_error, hora_error, cod_error, nombre_arch, sp_llamado, mensaje_error, user_insert, fecha_insert)
				VALUES (CURRENT, CURRENT, cCodret, pnombrearchivo, 'sp_reportearchivos_tef2', 'ERROR AL GENERAR ARCHIVO',USER, CURRENT);
				
                RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
				cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, 
				cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, cTotalImporteCod62;
								
        END IF; 
				
        END EXCEPTION; 
		
		IF (NVL(pnombrearchivo, '') <> '') OR (NVL(ptipoarchivo, '') <> '' AND pfechainicial IS NOT NULL AND pfechafinal IS NOT NULL AND NVL(ptiporeporte, 0) <> 0) THEN
			IF ptiporeporte = 1 OR ptiporeporte = 4 OR ptiporeporte = 5 OR ptiporeporte = 6 OR ptiporeporte = 7 THEN
				IF ptiporeporte = 1 OR ptiporeporte = 4 THEN
					IF ptiporeporte = 1 THEN -- Presentados Cod. 60
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
						IF pnombrearchivo = '' THEN 
							SELECT COUNT(cod_operacion), SUM(importe::decimal(18,2)) 
							INTO cRegistrosCod61, cTotalImporteCod61 
							FROM bditef:"informix".tef_cce_detalle a
							WHERE a.cod_operacion = ptipoarchivo 
									AND substr(a.nombre_arch,1,1) = 'E' 
									AND a.cve_status = '02'
									AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal;
							
							LET cTotalImporteCod61 = cTotalImporteCod61 / 100;
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							SELECT COUNT(cod_operacion), SUM(importe::decimal(18,2)) 
							INTO cRegistrosCod62, cTotalImporteCod62
							FROM bditef:"informix".tef_cce_detalle a
							WHERE a.cod_operacion = ptipoarchivo 
									AND substr(a.nombre_arch,1,1) = 'E' 
									AND a.cve_status = '01'
									AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal
									AND a.ref_confirmacion <> ''; 

							LET cTotalImporteCod62 = cTotalImporteCod62 / 100;
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
						
								SELECT sum(imp_operaciones::decimal(18,2)) 
								INTO dImpOperaciones
								FROM bditef:"informix".tef_cce_sumario
								WHERE cod_operacion = ptipoarchivo
								AND substr(nombre_arch,1,1) = 'E'
								--AND substr(nombre_arch,1,1) = 'S'
								AND fecha_presentacion BETWEEN pfechainicial AND pfechafinal;
								LET dImpOperaciones = dImpOperaciones / 100;
						ELSE
								SELECT COUNT(cod_operacion), SUM(importe::decimal(18,2)) 
								INTO cRegistrosCod61, cTotalImporteCod61 
								FROM bditef:"informix".tef_cce_detalle a
								WHERE a.cod_operacion = ptipoarchivo 
										AND substr(a.nombre_arch,1,1) = 'E' 
										AND a.cve_status = '02'
										AND a.nombre_arch = pnombrearchivo;
								
								LET cTotalImporteCod61 = cTotalImporteCod61 / 100; 
								SET LOCK MODE TO WAIT 3; 
								SET ISOLATION TO DIRTY READ; 
								SELECT COUNT(cod_operacion), SUM(importe::decimal(18,2)) 
								INTO cRegistrosCod62, cTotalImporteCod62
								FROM bditef:"informix".tef_cce_detalle a
								WHERE a.cod_operacion = ptipoarchivo 
										AND substr(a.nombre_arch,1,1) = 'E' 
										AND a.cve_status = '01'
										AND a.nombre_arch = pnombrearchivo
										AND a.ref_confirmacion <> ''; 

								LET cTotalImporteCod62 = cTotalImporteCod62 / 100;
								SET LOCK MODE TO WAIT 3;
								SET ISOLATION TO DIRTY READ;
						
								SELECT sum(imp_operaciones::decimal(18,2)) 
								INTO dImpOperaciones
								FROM bditef:"informix".tef_cce_sumario
								WHERE cod_operacion = ptipoarchivo
								AND substr(nombre_arch,1,1) = 'E'
								--AND substr(nombre_arch,1,1) = 'S'
								AND nombre_arch = pnombrearchivo;
								LET dImpOperaciones = dImpOperaciones / 100;
						END IF;	

						IF NVL(pnombrearchivo, '') <> '' THEN
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							FOREACH 
								SELECT SKIP pregistros FIRST precuperacion a.fecha_presentacion, a.nombre_arch, substr(a.clave_rastreo, 8, 4) AS no_sucursal, 
								a.nombre_ord, a.num_cta_ord, e.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, 
								a.num_secuencia, b.descripcion AS TipoCtaDestino, c.descripcion AS BancoDestino, d.descripcion AS Status, a.motivo_dev AS CausaDev, f.descripcion AS DescDev
								INTO cFechaPresentacion, cNombreArchivo, cSucursal, cNombreDestino, cNumCtaOrd, cTipoOperacion, 
								cRefNumerica, dImporte, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, cMotivoDev, cDescripcionDev
								FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_tipo_oper AS e, bditef:"informix".tef_cat_devoluciones AS f
								WHERE a.cod_operacion = ptipoarchivo 
								AND substr(a.nombre_arch,1,1) = 'E'
								--AND substr(a.nombre_arch,1,1) = 'S'
								AND a.tipo_cta_rec = b.tipo_cta 
								AND a.banco_receptor = c.banco 
								AND a.cve_status = d.cve_status 
								AND a.tipo_operacion = e.codigo 
								AND a.motivo_dev = f.motivo_dev
								AND a.nombre_arch = pnombrearchivo
								ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia
								LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
								LET dImporte = dImporte / 100;
								RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, 
								cTipoOperacion, cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, 
								cStatus, dImpOperaciones, cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, 
								cRegistrosCod62, cTotalImporteCod62 WITH RESUME;
								
							END FOREACH;
						ELSE
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
--Reporte 109 ###################################################################################################
							FOREACH 
								SELECT {+AVOID_FULL(bdinteg:"informix".si_bancos)} SKIP pregistros FIRST precuperacion a.fecha_presentacion, a.nombre_arch, substr(a.clave_rastreo, 8, 4) AS no_sucursal, 
								a.nombre_ord, a.num_cta_ord, e.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, 
								a.num_secuencia, b.descripcion AS TipoCtaDestino, c.descripcion AS BancoDestino, d.descripcion AS Status, a.motivo_dev AS CausaDev, f.descripcion AS DescDev
								INTO cFechaPresentacion, cNombreArchivo, cSucursal, cNombreDestino, cNumCtaOrd, cTipoOperacion, 
								cRefNumerica, dImporte, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, cMotivoDev, cDescripcionDev
								FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_tipo_oper AS e, bditef:"informix".tef_cat_devoluciones AS f
								WHERE a.cod_operacion = ptipoarchivo 
								AND substr(a.nombre_arch,1,1) = 'E' 
								--AND substr(a.nombre_arch,1,1) = 'S'
								AND a.tipo_cta_rec = b.tipo_cta 
								AND a.banco_receptor = c.banco 
								AND a.cve_status = d.cve_status 
								AND a.tipo_operacion = e.codigo 
								AND a.motivo_dev = f.motivo_dev 
								AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal  
								ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia 								
								LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4); 
								LET dImporte = dImporte / 100; 
								RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, 
								cTipoOperacion, cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, 
								cStatus, dImpOperaciones, cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, 
								cRegistrosCod62, cTotalImporteCod62 WITH RESUME;

							END FOREACH;
--###################################################################################################
						END IF
					ELSE -- Recibidos Cod. 60
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
						IF pnombrearchivo = '' THEN
							SELECT COUNT(cod_operacion), SUM(importe::decimal(18,2)) 
							INTO cRegistrosCod61, cTotalImporteCod61 
							FROM bditef:"informix".tef_cce_detalle a 
							WHERE a.cod_operacion = ptipoarchivo 
									AND substr(a.nombre_arch,1,1) = 'S' 
									AND a.cve_status = '02'
									AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal;
						
							LET cTotalImporteCod61 = cTotalImporteCod61 / 100;
							
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							SELECT COUNT(cod_operacion), SUM(importe::INTEGER)::decimal(18,2)
							INTO cRegistrosCod62, cTotalImporteCod62 
							FROM bditef:"informix".tef_cce_detalle a
							WHERE a.cod_operacion = ptipoarchivo 
									AND substr(a.nombre_arch,1,1) = 'S' 
									AND a.cve_status = '01'
									AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal;

							LET cTotalImporteCod62 = (cTotalImporteCod62 / 100)::decimal(18,2);
							
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							SELECT sum(imp_operaciones::decimal(18,2)) 
							INTO dImpOperaciones
							FROM bditef:"informix".tef_cce_sumario 
							WHERE cod_operacion = ptipoarchivo
							AND substr(nombre_arch,1,1) = 'S'
							--AND substr(nombre_arch,1,1) = 'E'
							AND fecha_presentacion BETWEEN pfechainicial AND pfechafinal;
							LET dImpOperaciones = dImpOperaciones / 100;											
						ELSE												
							SELECT COUNT(cod_operacion), SUM(importe::decimal(18,2)) 
							INTO cRegistrosCod61, cTotalImporteCod61 
							FROM bditef:"informix".tef_cce_detalle a 
							WHERE a.cod_operacion = ptipoarchivo 
									AND substr(a.nombre_arch,1,1) = 'S' 
									AND a.cve_status = '02'
									AND a.nombre_arch = pnombrearchivo;
						
							LET cTotalImporteCod61 = cTotalImporteCod61 / 100;
							
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							SELECT COUNT(cod_operacion), SUM(importe::INTEGER)::decimal(18,2)
							INTO cRegistrosCod62, cTotalImporteCod62 
							FROM bditef:"informix".tef_cce_detalle a
							WHERE a.cod_operacion = ptipoarchivo 
									AND substr(a.nombre_arch,1,1) = 'S' 
									AND a.cve_status = '01'
									AND a.nombre_arch = pnombrearchivo;

							LET cTotalImporteCod62 = (cTotalImporteCod62 / 100)::decimal(18,2);
							
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							SELECT sum(imp_operaciones::decimal(18,2)) 
							INTO dImpOperaciones
							FROM bditef:"informix".tef_cce_sumario 
							WHERE cod_operacion = ptipoarchivo
							AND substr(nombre_arch,1,1) = 'S'
							--AND substr(nombre_arch,1,1) = 'E'
							AND nombre_arch = pnombrearchivo;

							LET dImpOperaciones = dImpOperaciones / 100;
						END IF;	
						
						IF NVL(pnombrearchivo, '') <> '' THEN
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							FOREACH 
								SELECT SKIP pregistros FIRST precuperacion a.fecha_presentacion, a.nombre_arch, a.cod_operacion, substr(a.clave_rastreo, 8, 4) AS no_sucursal, 
								a.nombre_rec, a.num_cta_ord, e.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, 
								a.num_secuencia, b.descripcion AS TipoCtaDestino, c.descripcion AS BancoDestino, d.descripcion AS Status, a.motivo_dev AS CausaDev, f.descripcion AS DescDev
								INTO cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
								cRefNumerica, dImporte, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, cMotivoDev, cDescripcionDev
								FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_tipo_oper AS e, bditef:"informix".tef_cat_devoluciones AS f
								WHERE a.cod_operacion = ptipoarchivo 
								AND substr(a.nombre_arch,1,1) = 'S'
								--AND substr(nombre_arch,1,1) = 'E'
								AND a.tipo_cta_rec = b.tipo_cta 
								AND a.banco_receptor = c.banco 
								AND a.cve_status = d.cve_status 
								AND a.tipo_operacion = e.codigo 
								AND a.motivo_dev = f.motivo_dev
								AND a.nombre_arch = pnombrearchivo
								ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia
								
								LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
								LET dImporte = dImporte / 100;
								
								RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, 
								cTipoOperacion, cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, 
								cStatus, dImpOperaciones, cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, 
								cRegistrosCod62, cTotalImporteCod62 WITH RESUME;
							END FOREACH;
						ELSE
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							FOREACH
--Reporte 191 ###################################################################################################
								SELECT {+AVOID_FULL(bdinteg:"informix".si_bancos)} SKIP pregistros FIRST precuperacion a.fecha_presentacion, a.nombre_arch, a.cod_operacion, substr(a.clave_rastreo, 8, 4) AS no_sucursal, 
								a.nombre_rec, a.num_cta_ord, e.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, 
								a.num_secuencia, b.descripcion AS TipoCtaDestino, c.descripcion AS BancoDestino, d.descripcion AS Status, a.motivo_dev AS CausaDev, f.descripcion AS DescDev
								INTO cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
								cRefNumerica, dImporte, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, cMotivoDev, cDescripcionDev
								FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_tipo_oper AS e, bditef:"informix".tef_cat_devoluciones AS f
								WHERE a.cod_operacion = ptipoarchivo 
								AND substr(a.nombre_arch,1,1) = 'S'
								--AND substr(nombre_arch,1,1) = 'E'
								AND a.tipo_cta_rec = b.tipo_cta 
								AND a.banco_receptor = c.banco 
								AND a.cve_status = d.cve_status 
								AND a.tipo_operacion = e.codigo 
								AND a.motivo_dev = f.motivo_dev 
								AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal 
								ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia
								
								LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
								LET dImporte = dImporte / 100;
								RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, 
								cTipoOperacion, cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, 
								cStatus, dImpOperaciones, cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, 
								cRegistrosCod62, cTotalImporteCod62 WITH RESUME;
							END FOREACH; 
--###################################################################################################
						END IF
					END IF
				END IF
				IF ptiporeporte = 7 THEN -- Recibidos Cod. 63
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
					IF pnombrearchivo = '' THEN
						SELECT sum(imp_operaciones::decimal(18,2)) 
						INTO dImpOperaciones
						FROM bditef:"informix".tef_cce_sumario
						WHERE cod_operacion = ptipoarchivo
						--AND substr(nombre_arch,1,1) = 'E'
						AND substr(nombre_arch,1,1) = 'S'
						AND fecha_presentacion BETWEEN pfechainicial AND pfechafinal;
						LET dImpOperaciones = dImpOperaciones / 100;
					ELSE
						SELECT sum(imp_operaciones::decimal(18,2)) 
						INTO dImpOperaciones
						FROM bditef:"informix".tef_cce_sumario
						WHERE cod_operacion = ptipoarchivo
						--AND substr(nombre_arch,1,1) = 'E'
						AND substr(nombre_arch,1,1) = 'S'
						AND nombre_arch = pnombrearchivo;
						LET dImpOperaciones = dImpOperaciones / 100;
					END IF;		
					IF NVL(pnombrearchivo, '') <> '' THEN
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
							FOREACH
							SELECT SKIP pregistros FIRST precuperacion a.fecha_presentacion, a.nombre_arch, a.cod_operacion, substr(a.clave_rastreo, 8, 4) AS no_sucursal, 
							a.nombre_ord, a.num_cta_ord, e.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, 
							a.num_secuencia, b.descripcion AS TipoCtaOrdenante, c.descripcion AS BancoDestino, d.descripcion AS Status, a.motivo_dev AS CausaDev, f.descripcion AS DescDev
							INTO cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
							cRefNumerica, dImporte, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, cMotivoDev, cDescripcionDev
							FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_tipo_oper AS e, bditef:"informix".tef_cat_devoluciones AS f
							WHERE a.cod_operacion = ptipoarchivo 
							--AND substr(a.nombre_arch,1,1) = 'E'
							AND substr(a.nombre_arch,1,1) = 'S'
							AND a.tipo_cta_ord = b.tipo_cta 
							AND a.banco_presentador = c.banco 
							AND a.cve_status = d.cve_status 
							AND a.tipo_operacion = e.codigo
							AND a.motivo_dev = f.motivo_dev
							AND a.nombre_arch = pnombrearchivo
							ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia
							LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
							LET dImporte = dImporte / 100;
							RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
							cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, 
							cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, 
							cTotalImporteCod62 WITH RESUME;
						END FOREACH;
					ELSE
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
							FOREACH
--Reporte 258 ###################################################################################################
							SELECT {+AVOID_FULL(bdinteg:"informix".si_bancos)}SKIP pregistros FIRST precuperacion a.fecha_presentacion, a.nombre_arch, a.cod_operacion, substr(a.clave_rastreo, 8, 4) AS no_sucursal, 
							a.nombre_ord, a.num_cta_ord, e.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, 
							a.num_secuencia, b.descripcion AS TipoCtaOrdenante, c.descripcion AS BancoDestino, d.descripcion AS Status, a.motivo_dev AS CausaDev, f.descripcion AS DescDev
							INTO cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
							cRefNumerica, dImporte, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, cMotivoDev, cDescripcionDev
							FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_tipo_oper AS e, bditef:"informix".tef_cat_devoluciones AS f
							WHERE a.cod_operacion = ptipoarchivo 
							--AND substr(a.nombre_arch,1,1) = 'E'
							AND substr(a.nombre_arch,1,1) = 'S'
							AND a.cve_status = d.cve_status 
							AND a.tipo_operacion = e.codigo
							AND a.motivo_dev = f.motivo_dev
							AND a.tipo_cta_ord = b.tipo_cta 
							AND a.banco_presentador = c.banco 
							AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal
							ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia
							
							LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
							LET dImporte = dImporte / 100;
							RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
							cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, 
							cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, 
							cTotalImporteCod62 WITH RESUME;
						END FOREACH;
--###################################################################################################
					END IF
				END IF
				IF ptiporeporte = 5 OR ptiporeporte = 6 THEN
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
					IF pnombrearchivo = '' THEN
						SELECT sum(imp_operaciones::decimal(18,2)) 
						INTO dImpOperaciones
						FROM bditef:"informix".tef_cce_sumario 
						WHERE cod_operacion = ptipoarchivo
						AND fecha_presentacion BETWEEN pfechainicial AND pfechafinal;
						LET dImpOperaciones = dImpOperaciones / 100;
					ELSE
						SELECT sum(imp_operaciones::decimal(18,2)) 
						INTO dImpOperaciones
						FROM bditef:"informix".tef_cce_sumario 
						WHERE cod_operacion = ptipoarchivo
						AND nombre_arch = pnombrearchivo;
						LET dImpOperaciones = dImpOperaciones / 100;
					END IF;	
					IF NVL(pnombrearchivo, '') <> '' THEN
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
							FOREACH 
							SELECT SKIP pregistros FIRST precuperacion a.fecha_presentacion, a.nombre_arch, a.cod_operacion, substr(a.clave_rastreo, 8, 4) AS no_sucursal, 
							a.nombre_ord, a.num_cta_ord, e.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, 
							a.num_secuencia, b.descripcion AS TipoCtaDestino, c.descripcion AS BancoDestino, d.descripcion AS Status 
							INTO cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
							cRefNumerica, dImporte, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus 
							FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_tipo_oper AS e 
							WHERE a.cod_operacion = ptipoarchivo 
							AND a.tipo_cta_rec = b.tipo_cta 
							AND a.banco_receptor = c.banco 
							AND a.cve_status = d.cve_status 
							AND a.tipo_operacion = e.codigo 
							AND a.nombre_arch = pnombrearchivo
							ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia
							LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
                                                        LET dImporte = dImporte / 100;

							RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
							cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, 
							cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, 
							cTotalImporteCod62 WITH RESUME;
						END FOREACH;
					ELSE
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
							FOREACH
--Reporte 325 ###################################################################################################
							SELECT {+AVOID_FULL(bdinteg:"informix".si_bancos)}SKIP pregistros FIRST precuperacion a.fecha_presentacion, a.nombre_arch, a.cod_operacion, substr(a.clave_rastreo, 8, 4) AS no_sucursal, 
							a.nombre_ord, a.num_cta_ord, e.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, 
							a.num_secuencia, b.descripcion AS TipoCtaDestino, c.descripcion AS BancoDestino, d.descripcion AS Status 
							INTO cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
							cRefNumerica, dImporte, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus 
							FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_tipo_oper AS e 
							WHERE a.cod_operacion = ptipoarchivo 
							AND a.tipo_cta_rec = b.tipo_cta 
							AND a.banco_receptor = c.banco 
							AND a.cve_status = d.cve_status 
							AND a.tipo_operacion = e.codigo 
							AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal 
							ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia
							
							
							LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
							LET dImporte = dImporte / 100;
							RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
							cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, 
							cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, 
							cTotalImporteCod62 WITH RESUME;
							END FOREACH;
--###################################################################################################
					END IF
				END IF
			END IF
			IF ptiporeporte = 2 THEN -- Presentados Cod. 63
				IF NVL(pnombrearchivo, '') <> '' THEN
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
						FOREACH

						SELECT SKIP pregistros FIRST precuperacion a.fecha_presentacion, a.nombre_arch, a.cod_operacion, substr(a.clave_rastreo, 8, 4) AS no_sucursal, a.nombre_rec, 
						f.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, a.num_secuencia, 
						b.descripcion AS TipoCtaDestino, c.descripcion AS BancoDestino, d.descripcion AS Status, a.motivo_dev, e.descripcion 
						INTO cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreDestino, cTipoOperacion, cRefNumerica, dImporte, 
						cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, cMotivoDev, cDescripcionDev 
						FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_cat_devoluciones as e, 
						tef_tipo_oper AS f 
						WHERE a.cod_operacion = ptipoarchivo 
						--AND substr(a.nombre_arch,1,1) = 'S' 
						AND substr(a.nombre_arch,1,1) = 'E' 
						AND a.tipo_cta_rec = b.tipo_cta 
						AND a.banco_receptor = c.banco 
						AND a.cve_status = d.cve_status 
						AND a.motivo_dev = e.motivo_dev 
						AND a.tipo_operacion = f.codigo 
						AND a.nombre_arch = pnombrearchivo 
						ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia 

						LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
						LET dImporte = dImporte / 100; 
						RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
						cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, 
						cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, cTotalImporteCod62 
						WITH RESUME; 

					END FOREACH;
				ELSE 
					SET LOCK MODE TO WAIT 3; 
					SET ISOLATION TO DIRTY READ; 
						FOREACH

--Reporte 385 ###################################################################################################
						SELECT {+AVOID_FULL(bdinteg:"informix".si_bancos)}SKIP pregistros FIRST precuperacion a.fecha_presentacion, a.nombre_arch, a.cod_operacion, substr(a.clave_rastreo, 8, 4) AS no_sucursal, a.nombre_rec, 
						f.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, a.num_secuencia, 
						b.descripcion AS TipoCtaDestino, c.descripcion AS BancoDestino, d.descripcion AS Status, a.motivo_dev, e.descripcion 
						INTO cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreDestino, cTipoOperacion, cRefNumerica, dImporte, 
						cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, cMotivoDev, cDescripcionDev 
						FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_cat_devoluciones as e, 
						tef_tipo_oper AS f 
						WHERE a.cod_operacion = ptipoarchivo 
						--AND substr(a.nombre_arch,1,1) = 'S'
						AND substr(a.nombre_arch,1,1) = 'E'
						AND a.tipo_cta_rec = b.tipo_cta 
						AND a.banco_receptor = c.banco 
						AND a.cve_status = d.cve_status 
						AND a.tipo_operacion = f.codigo
						AND a.motivo_dev = e.motivo_dev 
						AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal
						ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia
						
						LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
						LET dImporte = dImporte / 100;

						RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
						cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, 
						cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, cTotalImporteCod62 
						WITH RESUME;

					END FOREACH;

--###################################################################################################
				END IF
			END IF

			IF ptiporeporte = 3 THEN -- Recibidos Cod. 10
				IF NVL(pnombrearchivo, '') <> '' THEN
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
						FOREACH
						SELECT SKIP pregistros FIRST precuperacion a.fecha_presentacion, a.nombre_arch, a.num_cta_ord, a.importe::decimal(11,2), a.num_cta_rec, 
						e.descripcion AS TipoCtaDestino, a.num_secuencia, b.descripcion AS BancoDestino, c.descripcion AS Status, a.motivo_dev, 
						d.descripcion 
						INTO cFechaPresentacion, cNombreArchivo, cNumCtaOrd, dImporte, cNumCtaDestino, cTipoCtaDestino, cSecuencia, cBanco, 
						cStatus, cMotivoDev, cDescripcionDev 
						FROM bditef:"informix".tef_cce_detalle AS a, bdinteg:"informix".si_bancos AS b, bditef:"informix".tef_status_pago AS c, bditef:"informix".tef_cat_devoluciones as d, bditef:"informix".tef_tipo_cta AS e
						WHERE a.cod_operacion = ptipoarchivo 
						AND a.banco_receptor = b.banco 
						AND a.cve_status = c.cve_status 
						AND a.motivo_dev = d.motivo_dev 
						AND a.tipo_cta_rec = e.tipo_cta 
						AND a.nombre_arch = pnombrearchivo
						ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia

						LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
						LET dImporte = dImporte / 100;
						RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
						cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, 
						cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, cTotalImporteCod62 
						WITH RESUME;
					END FOREACH;
				ELSE
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
						FOREACH

--Reporte 445 ###################################################################################################
						SELECT {+AVOID_FULL(bdinteg:"informix".si_bancos)} SKIP pregistros FIRST precuperacion a.fecha_presentacion, a.nombre_arch, a.num_cta_ord, a.importe::decimal(11,2), a.num_cta_rec, 
						e.descripcion AS TipoCtaDestino, a.num_secuencia, b.descripcion AS BancoDestino, c.descripcion AS Status, a.motivo_dev, 
						d.descripcion 
						INTO cFechaPresentacion, cNombreArchivo, cNumCtaOrd, dImporte, cNumCtaDestino, cTipoCtaDestino, cSecuencia, cBanco, 
						cStatus, cMotivoDev, cDescripcionDev 
						FROM bditef:"informix".tef_cce_detalle AS a, bdinteg:"informix".si_bancos AS b, bditef:"informix".tef_status_pago AS c, bditef:"informix".tef_cat_devoluciones as d, bditef:"informix".tef_tipo_cta AS e
						WHERE a.cod_operacion = ptipoarchivo 
						AND a.tipo_cta_rec = e.tipo_cta 
						AND a.banco_receptor = b.banco 
						AND a.cve_status = c.cve_status 
						AND a.motivo_dev = d.motivo_dev 
						AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal 
						ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia
						
						LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || 
						substr(cFechaPresentacion,1,4);
						LET dImporte = dImporte / 100;
						RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
						cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, 
						cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, cTotalImporteCod62 
						WITH RESUME;
					END FOREACH;

--###################################################################################################
				END IF
			END IF
		ELSE
			LET cCodret = '00001';
			
			RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, cRefNumerica, 
			dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, cFechaPresentacion, 
			cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, cTotalImporteCod62;
		END IF
	END;
END PROCEDURE;