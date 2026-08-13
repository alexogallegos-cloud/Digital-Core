CREATE PROCEDURE "informix".sp_consulta_reporte_cantidades_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), 
	pOpcionCanal CHAR(1), pFecha_inicial DATE, pFecha_final DATE, pStatus CHAR(1), pCliente CHAR(20), pCuenta CHAR(20), pTarjeta CHAR(20))
	RETURNING
		CHAR(5) AS codret,
		INTEGER AS totRegistros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iTotales INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;	
	LET iTotales = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotales;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_reporte_cantidades_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pOpcionCanal = ''OR pFecha_inicial = '' OR pFecha_final = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotales;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotales;
		END IF;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pOpcionCanal = '1' THEN
			SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} COUNT(*) AS TOTALES
			INTO iTotales
			FROM bdirst:"informix".claves_retiro AS cr
			INNER JOIN bdirst:"informix".par_canal_inicial AS ci ON UPPER(ci.par_cve_canal_inicial) = UPPER(cr.cr_canal_inicial)
			INNER JOIN bdirst:"informix".par_canal_final AS cf ON UPPER(cf.par_cve_canal_final) = UPPER(cr.cr_canal_final)
			WHERE cr.cr_cliente = CASE WHEN pCliente = '' THEN cr.cr_cliente ELSE pCliente END
			AND cr.cr_cuenta = CASE WHEN pCuenta = '' THEN cr.cr_cuenta ELSE pCuenta END
			AND cr.cr_tarjeta = CASE WHEN pTarjeta = '' THEN cr.cr_tarjeta ELSE pTarjeta END
			AND cr.cr_status = CASE WHEN pStatus = '' THEN cr.cr_status ELSE pStatus END
			AND cr.cr_alta_fecha BETWEEN pFecha_inicial AND pFecha_final;
		ELIF pOpcionCanal = '2' THEN 
			SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} COUNT(*) AS TOTALES
			INTO iTotales
			FROM bdirst:"informix".claves_retiro AS cr
			INNER JOIN bdirst:"informix".par_canal_final AS cf ON UPPER(cf.par_cve_canal_final) = UPPER(cr.cr_canal_final)
			INNER JOIN bdirst:"informix".par_canal_inicial AS ci ON UPPER(ci.par_cve_canal_inicial) = UPPER(cr.cr_canal_inicial)
			WHERE cr.cr_cliente = CASE WHEN pCliente = '' THEN cr.cr_cliente ELSE pCliente END
			AND cr.cr_cuenta = CASE WHEN pCuenta = '' THEN cr.cr_cuenta ELSE pCuenta END
			AND cr.cr_tarjeta = CASE WHEN pTarjeta = '' THEN cr.cr_tarjeta ELSE pTarjeta END
			AND cr.cr_status = CASE WHEN pStatus = '' THEN cr.cr_status ELSE pStatus END
			AND cr.cr_alta_fecha BETWEEN pFecha_inicial AND pFecha_final;
		END IF;
		
		IF iTotales = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iTotales;
		
	END;		

END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR',
'FECHA: 19/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: Reporte de CancelaciÃ³n Claves Retiro',
'DESCRIPCION: SPL encargado de obtener el total del reporte cantidades totales.',
'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 30/01/2021',
'DESCRIPCION: Se realiza ajuste a procedimiento para devolver las descripciones de Canal de Cobro y Canal de GeneraciÃ³n dependiendo de la opciÃ³n',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_detalle_clave_retiro( pUsuario CHAR(8), pIdFuncion CHAR(10), pFoliooperacion CHAR(100))

	RETURNING
		CHAR(5) AS codret,
		CHAR (2) AS status,
		CHAR (40) AS descripcionStatus,
		CHAR (100) AS foliooperacion, 
		DATE AS alta_fecha, 
		DATE AS ultima_mod_fecha, 
		CHAR (20) AS cliente, 
		CHAR (20) AS cuenta, 
		CHAR (20) AS tarjeta, 
		MONEY AS monto, 
		CHAR (45) AS concepto, 
		CHAR (1) AS modalidad;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;

	DEFINE cCr_status CHAR(20);
	DEFINE cDes_status CHAR(20);
	DEFINE cFoliooperacion CHAR(6);
	DEFINE dAlta_fecha DATE;
	DEFINE dUltima_mod_fecha DATE;
	DEFINE cCliente CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cTarjeta CHAR(20);
	DEFINE iMonto INTEGER;
	DEFINE cConcepto CHAR(45);
	DEFINE cModalidad CHAR(1);
	
	LET cCr_status = '';
	LET cDes_status = '';
	LET cFoliooperacion = '';
	LET dAlta_fecha = '';
	LET dUltima_mod_fecha = '';
	LET cCliente = '';
	LET cCuenta = '';
	LET cTarjeta = '';
	LET iMonto = 0;
	LET cConcepto = '';
	LET cModalidad = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCr_status ,cDes_status ,cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_detalle_clave_retiro.out';
		-- TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pFoliooperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCr_status ,cDes_status ,cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCr_status ,cDes_status ,cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT cr_status, cr_foliooperacion, cr_alta_fecha,cr_ultima_mod_fecha, cr_cliente, cr_cuenta, cr_tarjeta, cr_monto, cr_concepto, cr_modalidad, cs.cat_descripcion_status
		INTO cCr_status , cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad , cDes_status
		FROM  bdirst:"informix".claves_retiro as cr
		inner join bdirst:"informix".cat_status as cs ON cs.cat_cod_status = cr.cr_status
		WHERE cr_foliooperacion = pFoliooperacion;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, cCr_status ,cDes_status ,cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad;
		
	END;

END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 26/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: DETALLE DE OPERACION',
'DESCRIPCION: SPL obtener detalle de CLAVES DE RETIRO',
'BD: bdirst';

CREATE PROCEDURE "informix".sp_detalle_retiro( pUsuario CHAR(8), pIdFuncion CHAR(10), pFoliooperacion CHAR(100), pStatus CHAR(2) )

	RETURNING
		CHAR(5) AS codret,
		CHAR (2) AS status,
		CHAR (40) AS descripcionStatus,
		CHAR (100) AS foliooperacion, 
		DATE AS alta_fecha, 
		DATE AS ultima_mod_fecha, 
		CHAR (20) AS cliente, 
		CHAR (20) AS cuenta, 
		CHAR (20) AS tarjeta, 
		MONEY AS monto, 
		CHAR (45) AS concepto, 
		CHAR (1) AS modalidad,
		CHAR (8) AS cajero,
		CHAR (8) AS aut_oper_retiro,
		DATE AS cobrado_fecha,
		DATE AS rechazo_fecha,
		CHAR (2) AS codigoiso_reverso,
		DATE AS canc_fecha;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;

	DEFINE cCr_status CHAR(20);
	DEFINE cDes_status CHAR(20);
	DEFINE cFoliooperacion CHAR(100);
	DEFINE dAlta_fecha DATE;
	DEFINE dUltima_mod_fecha DATE;
	DEFINE cCliente CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cTarjeta CHAR(20);
	DEFINE iMonto INTEGER;
	DEFINE cConcepto CHAR(45);
	DEFINE cModalidad CHAR(1);
	DEFINE cCajero CHAR(8);
	DEFINE cAut_oper_retiro CHAR(8);
	DEFINE dCobrado_fecha DATE;
	DEFINE dRechazo_fecha DATE;
	DEFINE cCodigoiso_reverso CHAR(2);
	DEFINE dCanc_fecha DATE;

	LET cCr_status = '';
	LET cDes_status = '';
	LET cFoliooperacion = '';
	LET dAlta_fecha = '';
	LET dUltima_mod_fecha = '';
	LET cCliente = '';
	LET cCuenta = '';
	LET cTarjeta = '';
	LET iMonto = 0;
	LET cConcepto = '';
	LET cModalidad = '';
	LET cCajero = '';
	LET cAut_oper_retiro = '';
	LET dCobrado_fecha = '';
	LET dRechazo_fecha = '';
	LET cCodigoiso_reverso = '';
	LET dCanc_fecha = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCr_status ,cDes_status ,cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad ,cCajero ,cAut_oper_retiro ,dCobrado_fecha ,dRechazo_fecha ,cCodigoiso_reverso ,dCanc_fecha;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_parametros_sistema.out';
		-- TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pFoliooperacion = '' OR pStatus = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCr_status ,cDes_status ,cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad ,cCajero ,cAut_oper_retiro ,dCobrado_fecha ,dRechazo_fecha ,cCodigoiso_reverso ,dCanc_fecha;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCr_status ,cDes_status ,cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad ,cCajero ,cAut_oper_retiro ,dCobrado_fecha ,dRechazo_fecha ,cCodigoiso_reverso ,dCanc_fecha;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF pFoliooperacion = '' OR pStatus = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCr_status ,cDes_status ,cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad ,cCajero ,cAut_oper_retiro ,dCobrado_fecha ,dRechazo_fecha ,cCodigoiso_reverso ,dCanc_fecha;
		END IF;

		--Pantalla Detalle de Consulta de Retiro.--
		IF pStatus = 'P' AND pFoliooperacion <> ''  THEN
			-- Estatus: X Cobrar -- 
			SELECT
			cr_status, cr_foliooperacion, cr_alta_fecha, cr_ultima_mod_fecha, cr_cliente, cr_cuenta, cr_tarjeta, cr_monto, cr_concepto, cr_modalidad, cs.cat_descripcion_status
			INTO 
			cCr_status,cFoliooperacion, dAlta_fecha, dUltima_mod_fecha, cCliente, cCuenta, cTarjeta, iMonto, cConcepto, cModalidad, cDes_status
			FROM  bdirst:"informix".claves_retiro as cr
			inner join bdirst:"informix".cat_status as cs ON cs.cat_cod_status = cr.cr_status
			WHERE cr_foliooperacion = pFoliooperacion;
			--  AND cr_status = 'P';
		END IF;
		
		IF pStatus = 'V' AND pFoliooperacion <> '' THEN
			-- Estatus: Vencido -- 
			SELECT 
			cr_status, cr_foliooperacion, cr_alta_fecha, cr_ultima_mod_fecha, cr_cliente, cr_cuenta, cr_tarjeta, cr_monto, cr_concepto, cr_modalidad, cs.cat_descripcion_status
			INTO
			cCr_status, cFoliooperacion, dAlta_fecha, dUltima_mod_fecha, cCliente, cCuenta, cTarjeta, iMonto, cConcepto, cModalidad, cDes_status
			FROM  bdirst:"informix".claves_retiro as cr
			inner join bdirst:"informix".cat_status as cs ON cs.cat_cod_status = cr.cr_status
			WHERE cr_foliooperacion = pFoliooperacion;
			--  AND cr_status = 'V';
		END IF;

		IF pStatus = 'X' AND pFoliooperacion <> '' THEN
			-- Estatus: Cancelado -- 
			SELECT
			cr_status, cr_ultima_mod_fecha, cs.cat_descripcion_status
			INTO
			cCr_status, dUltima_mod_fecha, cDes_status
			FROM  bdirst:"informix".claves_retiro as cr
			inner join bdirst:"informix".cat_status as cs ON cs.cat_cod_status = cr.cr_status
			WHERE cr_foliooperacion = pFoliooperacion;
			-- AND cr_status = 'X';
		END IF;

		IF pStatus = 'C' AND pFoliooperacion <> '' THEN
			-- Estatus: Cobrado -- 
			SELECT 
			cr_status, cr_foliooperacion, cr_cajero, cr_aut_oper_retiro, cr_cobrado_fecha, cs.cat_descripcion_status
			INTO
			cCr_status, cFoliooperacion, cCajero, cAut_oper_retiro, dCobrado_fecha, cDes_status
			FROM  bdirst:"informix".claves_retiro as cr
			inner join bdirst:"informix".cat_status as cs ON cs.cat_cod_status = cr.cr_status
			WHERE cr_foliooperacion = pFoliooperacion;
			-- AND cr_status = 'C';
		END IF;

		IF pStatus = 'R' AND pFoliooperacion <> '' THEN
			-- Estatus: Rechazado -- 
			SELECT 
			cr_status, cr_cajero, cr_rechazo_fecha, cr_codigoiso_reverso, cs.cat_descripcion_status
			INTO
			cCr_status, cCajero, dRechazo_fecha, cCodigoiso_reverso, cDes_status
			FROM  bdirst:"informix".claves_retiro as cr
			inner join bdirst:"informix".cat_status as cs ON cs.cat_cod_status = cr.cr_status
			WHERE cr_foliooperacion = pFoliooperacion;
			-- AND cr_status = 'R';
		END IF;

		IF pStatus = 'T' AND pFoliooperacion <> '' THEN
			-- Estatus: Transito --
			-- preguntar a Bancoppel si se va a ocupar el Estatus T	
			SELECT
			cr_status, cr_canc_fecha, cs.cat_descripcion_status
			INTO 
			cCr_status, dCanc_fecha, cDes_status
			FROM  bdirst:"informix".claves_retiro as cr
			inner join bdirst:"informix".cat_status as cs ON cs.cat_cod_status = cr.cr_status
			WHERE cr_foliooperacion = pFoliooperacion;
			-- AND cr_status = 'T';
		END IF;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, cCr_status ,cDes_status ,cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad ,cCajero ,cAut_oper_retiro ,dCobrado_fecha ,dRechazo_fecha ,cCodigoiso_reverso ,dCanc_fecha;
		
	END;

END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 18/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL obtener el detalle del retiro',
'BD: bdirst';

CREATE PROCEDURE "informix".sp_generararchivo_rst(pNombreArchivo CHAR(255), pCmdRespaldo CHAR(2000))
	RETURNING 
		CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cSql CHAR(2500);
	DEFINE cArchivoTemp CHAR(50);
	DEFINE cRutaArchivo CHAR(255);
	DEFINE ven_transacc SMALLINT;
	DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = '';
	LET cSql = '';
	LET cArchivoTemp = 'query_'||TO_CHAR(CURRENT, '%d%m%Y')||'.sql';
	LET cRutaArchivo = '/RESPALDOSNEW/archivosRST/';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			IF ven_transacc = 1 THEN
				ROLLBACK;		
			END IF;
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668,-535,-255)			
			LET bInTransaction = 't';
			COMMIT;
			BEGIN;
		END EXCEPTION WITH RESUME;
		
		BEGIN;
		IF bInTransaction = 'f' THEN
			COMMIT;
		END IF;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_generararchivo_rst.out';
		--TRACE ON;
		
		-- GENERACION DE ARCHIVO TXT

		LET cSql = '';
		LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '''||TRIM(cRutaArchivo)||TRIM(pNombreArchivo)||'.txt'' DELIMITER '||'''	'' '||TRIM(pCmdRespaldo)||' " >  /tmp/mfinis/'||cArchivoTemp;
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/chmod 777 /tmp/mfinis/'||cArchivoTemp;
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/ifxsif01/bin/dbaccess bdirst /tmp/mfinis/'||cArchivoTemp;
		--LET cSql = '/informix/bin/dbaccess bdirst /tmp/mfinis/'||cArchivoTemp;
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf /tmp/mfinis/'||cArchivoTemp;
		SYSTEM TRIM(cSql);
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN;
		END IF;
		
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 29/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de generar archivo para respaldar la informaciÃ³n sobre la tabla claves_retiro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_parametros_retiros( pUsuario CHAR(8), pIdFuncion CHAR(10), pip CHAR(20) )
	RETURNING 
		CHAR(5) AS codret,
		CHAR(20) AS monto_minimo,
		CHAR(20) AS monto_maximo,
		CHAR(20) AS codigos_activos,
		CHAR(20) AS vigencia;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	
	DEFINE cMontominimo CHAR(20);
	DEFINE cMontomaximo CHAR(20);
	DEFINE cCodigosActivos CHAR(20);
	DEFINE cVigencia CHAR(20);
	
	DEFINE campo CHAR(20);
	DEFINE valorCampo CHAR(20);
	
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE cIp CHAR(20);
		
	LET cAccion = 'CONSULTA RETIRO SIN TARJETA';
	LET cEntidad = 'parametros_sistema';
	LET cIp = pip;
	
	LET cMontominimo = '';
	LET cMontomaximo = '';
	LET cCodigosActivos = '';
	LET cVigencia = '';
	
	LET campo = '';
	LET valorCampo = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cMontominimo,cMontomaximo,cCodigosActivos,cVigencia;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_parametros_rertiro.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cMontominimo,cMontomaximo,cCodigosActivos,cVigencia;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cMontominimo,cMontomaximo,cCodigosActivos,cVigencia;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, cIp, NULL, pUsuario, 1) INTO cCodRet;
		
		IF cCodRet = '00000' THEN
			FOREACH

				SELECT {+INDEX (bdirst:parametro_sistema idx_nombre_param)} par_nombre, par_valor INTO campo, valorCampo FROM bdirst:"informix".parametro_sistema WHERE par_status = 'A'

				IF campo = 'MONTO_MINIMO' THEN
					LET cMontominimo = valorCampo;
				END IF;
				IF campo = 'MONTO_MAXIMO' THEN
					LET cMontomaximo = valorCampo;
				END IF;
				IF campo = 'CODIGOS_ACTIVOS' THEN
					LET cCodigosActivos = valorCampo;
				END IF;
				IF campo = 'VIGENCIA' THEN
					LET cVigencia = valorCampo;
				END IF;
				
			END FOREACH;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '01222';
			ELIF NVL(cMontominimo,'') = '' AND NVL(cMontomaximo,'') = '' AND NVL(cCodigosActivos,'') = '' AND NVL(cVigencia,'') = '' THEN 
				LET cCodRet = '01222';
			END IF;
		
			RETURN cCodRet,cMontominimo,cMontomaximo,cCodigosActivos,cVigencia;
			
		END IF;
		
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 26/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: PARAMETROS DE RETIRO',
'DESCRIPCION: SPL encargado de obtener el listado de parametros de retiro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_parametros_status( pUsuario CHAR(8), pIdFuncion CHAR(10), pIp CHAR(20) )
	RETURNING 
		CHAR(5) AS codret,
		CHAR(2) AS id_status,
		CHAR(1) AS cod_status,
		CHAR(30) AS descripcion_status;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	
	DEFINE cIdStatus CHAR(2);
	DEFINE cCodStatus CHAR(1);
	DEFINE cDescricpiconStatus CHAR(30);
	
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE cip CHAR(20);
	DEFINE crespaldo CHAR(50);
		
	LET cAccion = 'CONSULTA PARAMETROS STATUS';
	LET cEntidad = 'cat_status';
	LET cip = pip;
	LET crespaldo = '';
	
	LET cCodStatus = '';
	LET cDescricpiconStatus = '';
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cIdStatus, cCodStatus,cDescricpiconStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_parametros_status.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIp = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdStatus, cCodStatus,cDescricpiconStatus;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdStatus, cCodStatus,cDescricpiconStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, NULL, pUsuario, 1) INTO cCodRet;
		
		IF cCodRet = '00000' THEN 
			FOREACH
				SELECT cat_id_status, cat_cod_status, cat_descripcion_status 
				INTO cIdStatus, cCodStatus, cDescricpiconStatus 
				FROM bdirst: "informix".cat_status
				ORDER BY cat_id_status
				
				RETURN cCodRet, cIdStatus, cCodStatus,cDescricpiconStatus WITH RESUME;
			END FOREACH;
		END IF;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdStatus, cCodStatus,cDescricpiconStatus;
		END IF;	
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 22/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: ParÃ¡metros de Estatus',
'DESCRIPCION: SPL encargado de extraer informaciÃ³n en tabla cat_status',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_parametros_status_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING 
		CHAR(5) AS codret,
		CHAR(2) AS totales;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
		
	DEFINE iTotales INTEGER;
	
	LET iTotales = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iTotales;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_parametros_status_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotales;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotales;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*) 
		INTO iTotales 
		FROM bdirst:"informix".cat_status;
		
		IF NVL(iTotales,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iTotales;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 22/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: ParÃ¡metros de Estatus',
'DESCRIPCION: SPL encargado de obtener el total de registros sobre ls tsbls cat_status',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_reporte_cantidades_claves_retiro(pUsuario CHAR(8), pIdFuncion CHAR(10), 
	pOpcionCanal CHAR(1), pFecha_inicial DATE, pFecha_final DATE, pStatus CHAR(1), pCliente CHAR(20), pCuenta CHAR(20), pTarjeta CHAR(20), pIp CHAR(20), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING
		CHAR(5) AS codret,
		CHAR(20) AS canal_inicial,
		CHAR(20) AS desc_inicial,
		CHAR(20) AS canal_final,
		CHAR(20) AS desc_final,
		MONEY(16,2) AS monto;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cCanalInicial CHAR(10);
	DEFINE cCanalFinal CHAR(10);
	DEFINE iMonto MONEY;
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE cDescCanalInicial CHAR(50);
	DEFINE cDescCanalFinal CHAR(50);
	DEFINE mMonto MONEY(16,2);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;	
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cCanalInicial = '';
	LET cCanalFinal = '';
	LET mMonto = 0;
	LET cAccion = 'CONSULTA CANTIDADES CLAVES RETIROS';
	LET cEntidad = 'claves_retiro';
	LET cDescCanalInicial = '';
	LET cDescCanalFinal = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_claves_retiro.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL OR pOpcionCanal = ''OR pFecha_inicial = '' OR pFecha_final = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto;
		END IF;
		
		EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, NULL, pUsuario, 1) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pOpcionCanal = '1' THEN
			FOREACH
				SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} SKIP pRegistros FIRST pRecuperacion cr.cr_canal_inicial, ci.par_nombre_canal, cr.cr_canal_final, cf.par_nombre_canal, cr.cr_monto
				INTO cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto
				FROM bdirst:"informix".claves_retiro AS cr
				INNER JOIN bdirst:"informix".par_canal_inicial AS ci ON UPPER(ci.par_cve_canal_inicial) = UPPER(cr.cr_canal_inicial)
				INNER JOIN bdirst:"informix".par_canal_final AS cf ON UPPER(cf.par_cve_canal_final) = UPPER(cr.cr_canal_final)
				WHERE cr.cr_cliente = CASE WHEN pCliente = '' THEN cr.cr_cliente ELSE pCliente END
				AND cr.cr_cuenta = CASE WHEN pCuenta = '' THEN cr.cr_cuenta ELSE pCuenta END
				AND cr.cr_tarjeta = CASE WHEN pTarjeta = '' THEN cr.cr_tarjeta ELSE pTarjeta END
				AND cr.cr_status = CASE WHEN pStatus = '' THEN cr.cr_status ELSE pStatus END
				AND cr.cr_alta_fecha BETWEEN pFecha_inicial AND pFecha_final
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto WITH RESUME;
			END FOREACH;
		ELIF pOpcionCanal = '2' THEN 
			FOREACH
				SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} SKIP pRegistros FIRST pRecuperacion cr.cr_canal_final, cf.par_nombre_canal, cr.cr_canal_inicial, ci.par_nombre_canal, cr.cr_monto
				INTO cCanalFinal, cDescCanalFinal, cCanalInicial, cDescCanalInicial, mMonto
				FROM bdirst:"informix".claves_retiro AS cr
				INNER JOIN bdirst:"informix".par_canal_final AS cf ON UPPER(cf.par_cve_canal_final) = UPPER(cr.cr_canal_final)
				INNER JOIN bdirst:"informix".par_canal_inicial AS ci ON UPPER(ci.par_cve_canal_inicial) = UPPER(cr.cr_canal_inicial)
				WHERE cr.cr_cliente = CASE WHEN pCliente = '' THEN cr.cr_cliente ELSE pCliente END
				AND cr.cr_cuenta = CASE WHEN pCuenta = '' THEN cr.cr_cuenta ELSE pCuenta END
				AND cr.cr_tarjeta = CASE WHEN pTarjeta = '' THEN cr.cr_tarjeta ELSE pTarjeta END
				AND cr.cr_status = CASE WHEN pStatus = '' THEN cr.cr_status ELSE pStatus END
				AND cr.cr_alta_fecha BETWEEN pFecha_inicial AND pFecha_final
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto WITH RESUME;
			END FOREACH;
		END IF;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto;
		END IF;				
		
		
	END;		

END PROCEDURE
DOCUMENT 'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 19/01/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: Reporte de Cantidades de Retiro',
'DESCRIPCION: SPL encargado de extraer informaciÃ³n sobre tabla claves_retiro',
'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 29/01/2021',
'DESCRIPCION: Se realiza ajuste a procedimiento para devolver las descripciones de Canal de Cobro y Canal de GeneraciÃ³n dependiendo de la opciÃ³n',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_bitacora(pAccion CHAR(50), pEntidad CHAR(100), pIp CHAR(20), pArchivoRespaldo CHAR(100), pUsuario CHAR(10), pBandera CHAR(1))
	RETURNING 
		CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	DEFINE dAlta_Fecha DATE;
	DEFINE cOrigen CHAR(150);
	DEFINE last_bit_id INTEGER;
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE vBitEntidad CHAR(1);
	DEFINE cRutaArchivo CHAR(150);
	
	LET cCmd1 = '';
	LET cSql = '';
	LET dAlta_Fecha = CURRENT;
	LET cOrigen = 'RETIRO SIN TARJETA';
	LET cCodRet = '00000';
	LET vBitEntidad = '2';
	LET cRutaArchivo = '/RESPALDOSNEW/archivosRST/';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_bitacora.out';
		--TRACE ON;
		
		SELECT MAX(bit_id) INTO last_bit_id FROM bdirst:"informix".bitacora;
		IF last_bit_id IS NULL THEN
			LET last_bit_id = 1;
		ELSE 
			LET last_bit_id = last_bit_id + 1;
		END IF;
		
		IF pBandera = 1 THEN
			INSERT INTO bdirst:"informix".bitacora (bit_id, bit_accion, bit_entidad, bit_alta_fecha, bit_id_entidad, bit_ip, bit_origen, bit_usu_id_fk) 
			VALUES(last_bit_id, pAccion, pEntidad, dAlta_Fecha, vBitEntidad, pIp, cOrigen, pUsuario);
		ELIF pBandera = 2 THEN 
		
			SELECT MAX(bit_id) INTO last_bit_id FROM bdirst:"informix".bitacora;
			IF last_bit_id IS NULL THEN
				LET last_bit_id = 1;
			ELSE 
				LET last_bit_id = last_bit_id + 1;
			END IF;
		
			INSERT INTO bdirst:"informix".bitacora (bit_id, bit_accion, bit_entidad, bit_alta_fecha, bit_id_entidad, bit_ip, bit_origen, respaldo, bit_usu_id_fk) 
			VALUES(last_bit_id, pAccion, pEntidad, dAlta_Fecha, vBitEntidad, pIp, cOrigen, FILETOBLOB(TRIM(cRutaArchivo)||TRIM(pArchivoRespaldo)||'.txt', 'server'), pUsuario);
		END IF;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 19/01/2021',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargdo de realizar la insercion en tabla bdirst:"informix".bitacora para registrar la operacion: select, update, delete',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_spei_ctasinretencion(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pBandera CHAR(1))
		RETURNING CHAR(5) AS codret,
		CHAR(20) AS cuenta,
		CHAR(10) AS usuario,
		CHAR(1) AS estatus,
		DATE as fecha_alt,
		DATE as fecha_baj;
		
	DEFINE cCodRet CHAR(5);	
	DEFINE cCuenta CHAR(20);
	DEFINE cUsuario CHAR(10);
	DEFINE cEstatus CHAR(1);
	DEFINE dFecha_alt DATE;
	DEFINE dFecha_baj DATE;
	DEFINE iSqlErr INTEGER;
	DEFINE cBandera CHAR(1);
	
	LET cCodRet = '00000';
	LET cCuenta  = '';
	LET cUsuario = '';
	LET cEstatus = '';
	LET dFecha_alt = DATE(1);
	LET dFecha_baj = DATE(1);
	LET iSqlErr = 0;
	LET cBandera = 0;


	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCuenta,cUsuario,cEstatus,dFecha_alt,dFecha_baj;
		END EXCEPTION;
			
			
		--- SET ISOLATION TO CURSOR STABILITY;		
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_spei_ctasinretencion.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' OR pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCuenta,cUsuario,cEstatus,dFecha_alt,dFecha_baj;
		END IF;
		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCuenta,cUsuario,cEstatus,dFecha_alt,dFecha_baj;
		END IF;
		
		LET cBandera = pBandera;
		
		CASE cBandera
		
		--CASO 1 INDICA SI LA CUENTA EXISTE Y TRAE EL CAMPO DE ESTATUS'
		WHEN '1' THEN
			SELECT COUNT(*), estatus, fecha_alt,fecha_baj
			INTO cCuenta, cEstatus, dFecha_alt,dFecha_baj
			FROM bdicheq:"informix".sc_spei_cta_sin_retencion
			WHERE cuenta = pCuenta 
			GROUP BY estatus, fecha_alt,fecha_baj;
				
			IF cCuenta = 1 THEN
				LET cCuenta ='Verdadero';
			ELSE
				LET cCUenta ='Falso';
			END IF;
		
		--CASO 2 ACTUALIZA EL REGISTRO DE UNA CUENTA ACTIVA PARA DARLA DE BAJA Y ACTUALIZA LA FECHA EN QUE SE DIO DE BAJA
		WHEN '2' THEN 
			UPDATE bdicheq:"informix".sc_spei_cta_sin_retencion SET 
			estatus = 'B', 
			usuario =pUsuario, 
			fecha_baj = CURRENT 
			WHERE cuenta = pCuenta AND estatus = 'A';
		
		--CASO 3 ACTUALIZA EL REGISTRO DE UNA CUENTA INACTIVA PARA DARLA DE ALTA Y ACTUALIZA LA FECHA EN QUE SE DIO DE ALTA
		WHEN '3' THEN 
			UPDATE bdicheq:"informix".sc_spei_cta_sin_retencion SET 
			estatus = 'A', 
			usuario = pUsuario, 
			fecha_alt = CURRENT 
			WHERE cuenta = pCuenta AND estatus = 'B';
		
		--CASO 4 INSERTA UN REGISTRO NUEVO CON EL ESTATUS ACTIVO 'A' Y EL USUARIO QUE LO REGISTRO 
		WHEN '4' THEN 
			INSERT INTO bdicheq:"informix".sc_spei_cta_sin_retencion (cuenta,estatus,usuario,fecha_alt) 
			VALUES (pCuenta,'A',pUsuario,CURRENT);
		ELSE
	
		END CASE;	
		
		RETURN cCodRet,cCuenta,cUsuario,cEstatus,dFecha_alt,dFecha_baj;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes',
'FECHA: 29/12/2020',
'MODULO: EXCEPCION RETENIDOS SPEI | SOC',
'FUNCIONALIDAD: Nueva funcionalidad en el sistema SOC que permita agregar o quitar cuentas para excepciones de retenciÃ³n de saldo',
'DESCRIPCION: SPL encargado de Consultar-Dar de alta- Dar de baja cuentas sin retenciÃ³n para SPEI ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_bccc_detsolicitudeslincred_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjecucion SMALLINT, pTipoSolicitud CHAR(2),
pNumSolicitud CHAR(20), pNumCliente CHAR(20), pFechaInicio DATE, pFechaFin DATE, pEstatus CHAR(2), pProducto CHAR(4), pCveGrupo CHAR(2), 
pSegmento CHAR(2), pEtiqueta CHAR(2), pAnalista CHAR(8), pComentario CHAR(100), pTramaEjecucion CHAR(250))
    RETURNING CHAR(5) AS codRet,
		INTEGER AS operaciones_enviadas,
		INTEGER AS operaciones_exitosas,
		CHAR(1) AS hay_errores,
		CHAR(2) AS estatus;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cTipoSolicitud CHAR(30);
	DEFINE cNumsolicitud CHAR(20);
	DEFINE vNumsolicitud CHAR(20);
	DEFINE dFecha DATE;
	DEFINE dHora DATETIME HOUR TO FRACTION;
	DEFINE cCliente CHAR(20);
	DEFINE cEstatus CHAR(2);
	DEFINE cComentario CHAR(100);
	DEFINE iTotalRegistros INTEGER;
	DEFINE cClaveGrupo CHAR(2);
	DEFINE cSegmento CHAR(2);
	DEFINE cEtiqueta CHAR(2);
	DEFINE dFechaHoy DATE;
	DEFINE cPuesto CHAR(2);
	DEFINE iNumRegistros INTEGER;
	
	DEFINE cIdRegistro CHAR(11);
	DEFINE iIdRegistro INTEGER;
	DEFINE iRegMixtos INTEGER;
	DEFINE iTotalEnviadas INTEGER;
	DEFINE iTotalExitosas INTEGER;
	DEFINE cDescIdCodRet CHAR(100);
	DEFINE dHoraHoy DATETIME HOUR TO SECOND;
	DEFINE cProducto CHAR(4);
	DEFINE cTipoMov CHAR(1);
	DEFINE cHayErrores CHAR(1);
	

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cTipoSolicitud = '';
	LET cNumsolicitud = '';
	LET vNumsolicitud = '';
	LET dFecha = '';
	LET dHora = '';
	LET cCliente = '';
	LET cEstatus = '';
	LET cComentario = '';
	LET iTotalRegistros = 0;
	LET cClaveGrupo = '';
	LET cSegmento = '';
	LET cEtiqueta = '';
	LET dFechaHoy = DATE(CURRENT);
	LET cPuesto = '';
	LET iNumRegistros = 0;

	LET cIdRegistro = '';
	LET iIdRegistro = 0;
	LET iRegMixtos = 0;
	LET iTotalEnviadas = 0;
	LET iTotalExitosas = 0;
	LET cDescIdCodRet = '';
	LET dHoraHoy = CURRENT;
	LET cProducto = '';
	LET cTipoMov = '';
	LET cHayErrores = 'N';
	
	--SET DEBUG FILE TO '/RESPALDOSNEW/gpe/sp_bccc_detsolicitudeslincred_totales.out';
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				
				--SET LOCK MODE TO WAIT 3;
				UPDATE bdicnweb:"informix".sw_buro_statusmonitorbccc
                SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
				
				RETURN cCodRet,iTotalEnviadas,iTotalExitosas,cHayErrores,'';
			END IF;
		END EXCEPTION;
		

		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjecucion IS NULL OR pTipoSolicitud = '' THEN
			LET cCodRet = '00003';
			
			--SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_buro_statusmonitorbccc
            SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			
			RETURN cCodRet,iTotalEnviadas,iTotalExitosas,cHayErrores,'';
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			
			--SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_buro_statusmonitorbccc
            SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			
			RETURN cCodRet,iTotalEnviadas,iTotalExitosas,cHayErrores,'';
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- Consulta Grid
		IF pEjecucion = 1 THEN
		
			-- SE LIMPIA TABLA POR USUARIO VALIDACION DE ESTATUS DEL PROCESO 
            SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
            DELETE FROM bdicnweb:"informix".sw_buro_statusmonitorbccc WHERE usuario = pUsuario;
            
            -- SE INSERTA A TABLA PARA EL MONITOREO DEL ESTATUS DEL PROCESO
            SET LOCK MODE TO WAIT 3; 
            INSERT INTO bdicnweb:"informix".sw_buro_statusmonitorbccc(usuario,status,altas_total,total_exitosas,existe_error,estatus,error_proceso,error)
            VALUES(pUsuario, 'I', iTotalEnviadas, iTotalExitosas, cHayErrores, '', '', '');  
			
			-- SE LIMPIA TABLA POR USUARIO
			DELETE FROM bdicnweb:"informix".sw_buro_conslineacred WHERE usuario_insert = pUsuario;
			
			-- SE LIMPIA TABLA POR USUARIO (PRODUCTIVA)
			SET LOCK MODE TO WAIT 3; 
			DELETE FROM bdicred:"informix".sd_numsolici_datos_tmp2 WHERE user_insert = pUsuario;
			
			FOREACH
				EXECUTE PROCEDURE bdicred:"informix".sp_mon_buro_conssolcredlincred2(1, pTipoSolicitud, pNumSolicitud, pNumCliente, 
				pFechaInicio, pFechaFin, pEstatus, pProducto, pCveGrupo, pSegmento, pEtiqueta, pUsuario, pComentario)
				INTO cCodRetSp,cTipoSolicitud,cNumSolicitud,dFecha,dHora,cCliente,cEstatus,cComentario,iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta
			
				IF cCodRetSp <> 'TOTAL' THEN
				
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_mon_buro_conssolcredlincred';
					ELIF cCodRetSp::INTEGER > 0 THEN
					
						IF cCodRetSp::INTEGER = 1 THEN
							LET cCodRet = '00003'; --FALTA ALGUN PARAMETRO DE ENTRADA
						ELIF cCodRetSp::INTEGER = 2 THEN
							LET cCodRet = '00450'; --'VALOR DE PARAMETRO INVALIDO
						ELIF cCodRetSp::INTEGER = 3 THEN
							LET cCodRet = '00914'; --EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO
						ELIF cCodRetSp::INTEGER = 4 THEN
							LET cCodRet = '00426'; --EL PERIODO INDICADO NO ES EL CORRECTO, LA FECHA INICIAL NO PUEDE SER MAYOR A LA FINAL
						ELIF cCodRetSp::INTEGER = 5 THEN
							LET cCodRet = '00017'; --NO SE OBTUVIERON RESULTADOS
						ELIF cCodRetSp::INTEGER = 6 THEN
							LET cCodRet = '00914'; --EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO
						ELIF cCodRetSp::INTEGER = 7 THEN
							LET cCodRet = '00003'; --FALTA ALGUN PARAMETRO DE ENTRADA
						ELIF cCodRetSp::INTEGER = 8 THEN
							LET cCodRet = '00017'; --NO SE OBTUVIERON RESULTADOS
						ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo = '08' THEN
							LET cCodRet = '00283'; --ERROR AL ACTUALIZAR EL REGISTRO
						ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'CC' THEN
							LET cCodRet = '00915'; --EL ESTATUS DE LA SOLICITUD ES INCORRECTO
						ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'BC' THEN
							LET cCodRet = '00917'; --OCURRIO UN ERROR EN LA EJECUCIÃN DEL SP bdiburo:"informix".ins_buro_credito
						END IF;	
						
						--
						UPDATE bdicnweb:"informix".sw_buro_statusmonitorbccc
						SET status = 'E', error_proceso = 'S', altas_total = NVL(iTotalEnviadas,0), total_exitosas = NVL(iTotalExitosas,0), existe_error = cHayErrores, error = cCodRet WHERE usuario = pUsuario;	
					
						RETURN cCodRet,iTotalEnviadas,iTotalExitosas,cHayErrores,'';
						
					END IF;
					
				END IF;
				
				SELECT sol.num_producto,res.tipo_movimiento INTO cProducto,cTipoMov
				FROM bdisolic:"informix".ss_solicitudes AS sol, bdisolic:"informix".ss_resum_scor_fin AS res
				WHERE sol.numcte = cCliente AND sol.num_solicitud = res.num_solicitud AND sol.num_solicitud = cNumSolicitud;
				
				INSERT INTO bdicnweb:"informix".sw_buro_conslineacred(tipo_solicitud,num_solicitud,fecha,hora,cliente,estatus,comentario,total_registros,clave_grupo,segmento,etiqueta,producto,tipo_mov,usuario_insert,fecha_insert)
				VALUES (cTipoSolicitud,cNumSolicitud,dFecha,dHora,cCliente,cEstatus,cComentario,iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta,NVL(cProducto,''),NVL(cTipoMov,''),pUsuario,dFechaHoy);
				
/*				IF NVL(cCliente,'') IN (SELECT cliente FROM bdicnweb:"informix".sw_buro_conslineacred
									   WHERE tipo_mov = 'M' AND usuario_insert = TRIM(pUsuario)
									   GROUP BY cliente,estatus
									   HAVING COUNT(*) > 0) AND NVL(cProducto,'') <> '6001' THEN*/
				--Omite las solicitudes generadas de forma mixta con producto diferente a 6001
				IF cProducto = '6500' AND cTipoMov = 'M' THEN
					SELECT num_solicitud_ref INTO vNumSolicitud
					FROM bdisolic:"informix".ss_resum_scor_fin 
					WHERE empresa = '001' AND num_solicitud = cNumSolicitud;

					IF EXISTS (SELECT 1 FROM bdisolic:"informix".ss_solicitudes WHERE empresa = "001" AND num_solicitud = vNumSolicitud AND status_solicitud = cEstatus) THEN
						DELETE FROM bdicnweb:"informix".sw_buro_conslineacred WHERE num_solicitud = cNumSolicitud AND tipo_mov = 'M' AND usuario_insert = pUsuario;
					END IF;
				END IF;
				
			END FOREACH;
			
			SELECT DISTINCT puesto INTO cPuesto FROM bdicred:"informix".sd_perfiles_cac_aumlincred WHERE ejecutivo = pUsuario;
			IF (NVL(cPuesto,'') IN ('01','03','04')) AND pNumSolicitud = '' AND pNumCliente = '' THEN
			
				SELECT COUNT(*)
				INTO iTotalEnviadas
				FROM bdicnweb:"informix".sw_buro_conslineacred
				WHERE UPPER(comentario) <> 'EN PROCESO DE CONSULTA'
				AND usuario_insert = pUsuario AND fecha_insert = dFechaHoy;
				--WHERE LOWER(TRIM(comentario)) <> LOWER('En proceso de Consulta')
			
			ELSE
				
				SELECT COUNT(*)
				INTO iTotalEnviadas
				FROM bdicnweb:"informix".sw_buro_conslineacred
				WHERE usuario_insert = pUsuario AND fecha_insert = dFechaHoy;
			
			END IF;
			
			IF (NVL(iTotalEnviadas,0) - 1) = 0 THEN
				LET cCodRet = '00017';
			END IF;
			
			UPDATE bdicnweb:"informix".sw_buro_statusmonitorbccc
            SET status = 'T', error_proceso = 'N', altas_total = (NVL(iTotalEnviadas,0) - 1), total_exitosas = NVL(iTotalExitosas,0), existe_error = cHayErrores WHERE usuario = pUsuario;
			
			RETURN cCodRet,(NVL(iTotalEnviadas,0) - 1),NVL(iTotalExitosas,0),cHayErrores,'';
			
		--Reenvio Solicitudes (pantalla principal)
		ELIF pEjecucion = 2 THEN		
		
			-- SE LIMPIA TABLA POR USUARIO VALIDACION DE ESTATUS DEL PROCESO 
            SET LOCK MODE TO WAIT 3;
            DELETE FROM bdicnweb:"informix".sw_buro_statusmonitorbccc WHERE usuario = pUsuario;
            
            -- SE INSERTA A TABLA PARA EL MONITOREO DEL ESTATUS DEL PROCESO
            SET LOCK MODE TO WAIT 3; 
            INSERT INTO bdicnweb:"informix".sw_buro_statusmonitorbccc(usuario,status,altas_total,total_exitosas,existe_error,estatus,error_proceso,error)
            VALUES(pUsuario, 'I', iTotalEnviadas, iTotalExitosas, cHayErrores, '', '', '');  
			
			-- SE LIMPIA TABLA POR USUARIO
			DELETE FROM bdicnweb:"informix".sw_buro_bitacoraerror WHERE user_insert = pUsuario;
			
			FOREACH
			
				EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pTramaEjecucion, '|')
				INTO cIdRegistro				
				
				LET iIdRegistro = cIdRegistro::INTEGER;
				SELECT num_solicitud, estatus, comentario, clave_grupo, segmento, etiqueta
				INTO cNumSolicitud, cEstatus, cComentario, cClaveGrupo, cSegmento, cEtiqueta
				FROM bdicnweb:"informix".sw_buro_conslineacred
				WHERE usuario_insert = pUsuario AND fecha_insert = dFechaHoy AND id_serial = cIdRegistro::INTEGER;
				
				IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
					LET iTotalEnviadas = iTotalEnviadas + 1;
				END IF;
				FOREACH
				EXECUTE PROCEDURE bdicred:"informix".sp_mon_buro_conssolcredlincred2(2, pTipoSolicitud, TRIM(cNumSolicitud), '',
				'', '', cEstatus, '', cClaveGrupo, cSegmento, cEtiqueta, pUsuario, cComentario)
				INTO cCodRetSp,cTipoSolicitud,cNumSolicitud,dFecha,dHora,cCliente,cEstatus,cComentario,iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta
			END FOREACH;
				IF cCodRetSp <> 'TOTAL' THEN
				
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_mon_buro_conssolcredlincred';
					ELIF cCodRetSp::INTEGER = 1 THEN
						--LET cCodRet = '00003';
						LET cDescIdCodRet = 'FALTA ALGUN PARAMETRO DE ENTRADA';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 2 THEN
						--LET cCodRet = '00450';
						LET cDescIdCodRet = 'VALOR DE PARAMETRO INVALIDO';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 3 THEN
						--LET cCodRet = '00914';
						LET cDescIdCodRet = 'EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 4 THEN
						--LET cCodRet = '00426';
						LET cDescIdCodRet = 'EL PERIODO INDICADO NO ES EL CORRECTO, LA FECHA INICIAL NO PUEDE SER MAYOR A LA FINAL';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 5 THEN
						--LET cCodRet = '00017';
						LET cDescIdCodRet = 'NO SE OBTUVIERON RESULTADOS';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 6 THEN
						--LET cCodRet = '00914';
						LET cDescIdCodRet = 'EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 7 THEN
						--LET cCodRet = '00003';
						LET cDescIdCodRet = 'FALTA ALGUN PARAMETRO DE ENTRADA';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 8 THEN
						--LET cCodRet = '00017';
						LET cDescIdCodRet = 'NO SE OBTUVIERON RESULTADOS';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo = '08' THEN
						--LET cCodRet = '00283';
						LET cDescIdCodRet = 'ERROR AL ACTUALIZAR EL REGISTRO';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'CC' THEN
						--LET cCodRet = '00915';
						LET cDescIdCodRet = 'EL ESTATUS DE LA SOLICITUD ES INCORRECTO';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'BC' THEN
						--LET cCodRet = '00917';
						LET cDescIdCodRet = 'OCURRIO UN ERROR EN LA EJECUCIÃN DEL SP bdiburo:"informix".ins_buro_credito';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					END IF;	

					IF cCodRetSp::INTEGER = 0 THEN
						LET iTotalExitosas = iTotalExitosas + 1;
					END IF;
					
				END IF;
			
			END FOREACH;
			
			--SET LOCK MODE TO WAIT 3;
			
			IF NVL(iTotalEnviadas,0) <> NVL(iTotalExitosas,0) THEN
				LET cHayErrores = 'S';
			END IF;
			
			UPDATE bdicnweb:"informix".sw_buro_statusmonitorbccc
            SET status = 'T', error_proceso = 'N', altas_total = NVL(iTotalEnviadas,0), total_exitosas = NVL(iTotalExitosas,0), existe_error = cHayErrores WHERE usuario = pUsuario;
			
			RETURN cCodRet,NVL(iTotalEnviadas,0),NVL(iTotalExitosas,0),cHayErrores,'';
		
		--Actualiza Estatus		
		ELIF pEjecucion = 3 THEN

            FOREACH
		
			EXECUTE PROCEDURE bdicred:"informix".sp_mon_buro_conssolcredlincred2(3, pTipoSolicitud, pNumSolicitud, '', 
			'', '', '', '', '', '', '', '', '')
			INTO cCodRetSp,cTipoSolicitud,cNumSolicitud,dFecha,dHora,cCliente,cEstatus,cComentario,iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta
		
			IF cCodRetSp <> 'TOTAL' THEN
			
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_mon_buro_conssolcredlincred';
				ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00003'; --FALTA ALGUN PARAMETRO DE ENTRADA
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00450'; --'VALOR DE PARAMETRO INVALIDO
				ELIF cCodRetSp::INTEGER = 3 THEN
					LET cCodRet = '00914'; --EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO
				ELIF cCodRetSp::INTEGER = 4 THEN
					LET cCodRet = '00426'; --EL PERIODO INDICADO NO ES EL CORRECTO, LA FECHA INICIAL NO PUEDE SER MAYOR A LA FINAL
				ELIF cCodRetSp::INTEGER = 5 THEN
					LET cCodRet = '00017'; --NO SE OBTUVIERON RESULTADOS
				ELIF cCodRetSp::INTEGER = 6 THEN
					LET cCodRet = '00914'; --EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO
				ELIF cCodRetSp::INTEGER = 7 THEN
					LET cCodRet = '00003'; --FALTA ALGUN PARAMETRO DE ENTRADA
				ELIF cCodRetSp::INTEGER = 8 THEN
					LET cCodRet = '00916'; --NO HAY RESPUESTA DE BURO DE CREDITO
				ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo = '08' THEN
					LET cCodRet = '00283'; --ERROR AL ACTUALIZAR EL REGISTRO
				ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'CC' THEN
					LET cCodRet = '00915'; --EL ESTATUS DE LA SOLICITUD ES INCORRECTO
				ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'BC' THEN
					LET cCodRet = '00917'; --OCURRIO UN ERROR EN LA EJECUCIÃN DEL SP bdiburo:"informix".ins_buro_credito
				END IF;
				
			END IF;
		
            
			RETURN cCodRet,NVL(iTotalEnviadas,0),NVL(iTotalExitosas,0),cHayErrores,UPPER(cEstatus) WITH RESUME;
			
            END FOREACH;
		--ActualizaciÃ³n a tabla como enviada (no retorna nada)	
		ELIF pEjecucion = 4 THEN
		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".sp_mon_buro_conssolcredlincred2(4, '0', pNumSolicitud, '', 
			'', '', '', '', '', '', '', '', '')
			INTO cCodRetSp,cTipoSolicitud,cNumSolicitud,dFecha,dHora,cCliente,cEstatus,cComentario,iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta
		
			IF cCodRetSp <> 'TOTAL' THEN
			
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_mon_buro_conssolcredlincred';
				ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00003'; --FALTA ALGUN PARAMETRO DE ENTRADA
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00450'; --'VALOR DE PARAMETRO INVALIDO
				ELIF cCodRetSp::INTEGER = 3 THEN
					LET cCodRet = '00914'; --EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO
				ELIF cCodRetSp::INTEGER = 4 THEN
					LET cCodRet = '00426'; --EL PERIODO INDICADO NO ES EL CORRECTO, LA FECHA INICIAL NO PUEDE SER MAYOR A LA FINAL
				ELIF cCodRetSp::INTEGER = 5 THEN
					LET cCodRet = '00017'; --NO SE OBTUVIERON RESULTADOS
				ELIF cCodRetSp::INTEGER = 6 THEN
					LET cCodRet = '00914'; --EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO
				ELIF cCodRetSp::INTEGER = 7 THEN
					LET cCodRet = '00003'; --FALTA ALGUN PARAMETRO DE ENTRADA
				ELIF cCodRetSp::INTEGER = 8 THEN
					LET cCodRet = '00916'; --NO HAY RESPUESTA DE BURO DE CREDITO
				ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo = '08' THEN
					LET cCodRet = '00283'; --ERROR AL ACTUALIZAR EL REGISTRO
				ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'CC' THEN
					LET cCodRet = '00915'; --EL ESTATUS DE LA SOLICITUD ES INCORRECTO
				ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'BC' THEN
					LET cCodRet = '00917'; --OCURRIO UN ERROR EN LA EJECUCIÃN DEL SP bdiburo:"informix".ins_buro_credito
				END IF;
				
			END IF;
		
			RETURN cCodRet,NVL(iTotalEnviadas,0),NVL(iTotalExitosas,0),cHayErrores,'' WITH RESUME;
		END FOREACH;
		--Reenvio Solicitudes (pantalla modal)
		ELIF pEjecucion = 5 THEN		
		
			FOREACH
			
				EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pTramaEjecucion, '|')
				INTO cIdRegistro				
				
				LET iIdRegistro = cIdRegistro::INTEGER;
				SELECT num_solicitud, estatus, comentario, clave_grupo, segmento, etiqueta
				INTO cNumSolicitud, cEstatus, cComentario, cClaveGrupo, cSegmento, cEtiqueta
				FROM bdicnweb:"informix".sw_buro_conslineacred
				WHERE usuario_insert = pUsuario AND fecha_insert = dFechaHoy AND id_serial = cIdRegistro::INTEGER;
				
				IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
					LET iTotalEnviadas = iTotalEnviadas + 1;
				END IF;
				
				EXECUTE PROCEDURE bdicred:"informix".sp_mon_buro_conssolcredlincred2(2, pTipoSolicitud, TRIM(cNumSolicitud), '',
				'', '', cEstatus, '', cClaveGrupo, cSegmento, cEtiqueta, pUsuario, cComentario)
				INTO cCodRetSp,cTipoSolicitud,cNumSolicitud,dFecha,dHora,cCliente,cEstatus,cComentario,iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta;
			
				IF cCodRetSp <> 'TOTAL' THEN
				
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_mon_buro_conssolcredlincred';
					ELIF cCodRetSp::INTEGER = 1 THEN
						LET cCodRet = '00003'; --FALTA ALGUN PARAMETRO DE ENTRADA
					ELIF cCodRetSp::INTEGER = 2 THEN
						LET cCodRet = '00450'; --'VALOR DE PARAMETRO INVALIDO
					ELIF cCodRetSp::INTEGER = 3 THEN
						LET cCodRet = '00914'; --EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO
					ELIF cCodRetSp::INTEGER = 4 THEN
						LET cCodRet = '00426'; --EL PERIODO INDICADO NO ES EL CORRECTO, LA FECHA INICIAL NO PUEDE SER MAYOR A LA FINAL
					ELIF cCodRetSp::INTEGER = 5 THEN
						LET cCodRet = '00017'; --NO SE OBTUVIERON RESULTADOS
					ELIF cCodRetSp::INTEGER = 6 THEN
						LET cCodRet = '00914'; --EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO
					ELIF cCodRetSp::INTEGER = 7 THEN
						LET cCodRet = '00003'; --FALTA ALGUN PARAMETRO DE ENTRADA
					ELIF cCodRetSp::INTEGER = 8 THEN
						LET cCodRet = '00017'; --NO SE OBTUVIERON RESULTADOS
					ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo = '08' THEN
						LET cCodRet = '00283'; --ERROR AL ACTUALIZAR EL REGISTRO
					ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'CC' THEN
						LET cCodRet = '00915'; --EL ESTATUS DE LA SOLICITUD ES INCORRECTO
					ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'BC' THEN
						LET cCodRet = '00917'; --OCURRIO UN ERROR EN LA EJECUCIÃN DEL SP bdiburo:"informix".ins_buro_credito
					END IF;	

					IF cCodRetSp::INTEGER = 0 THEN
						LET iTotalExitosas = iTotalExitosas + 1;
					END IF;
					
				END IF;
			
			END FOREACH;
			
			--SET LOCK MODE TO WAIT 3;
			
			IF NVL(iTotalEnviadas,0) <> NVL(iTotalExitosas,0) THEN
				LET cHayErrores = 'S';
			END IF;
		
			RETURN cCodRet,NVL(iTotalEnviadas,0),NVL(iTotalExitosas,0),cHayErrores,'';		
		END IF;		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA 22/11/2016',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: MONITOR DE LA SITUACIÃN DE LOS ENVÃOS A BC Y CC',
'DESCRIPCION: Spl encargado de consultar el nÃºmero total de solicitudes de los envÃ­os a BC y CC.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA 01/02/2017',
'DESCRIPCION: Se modifica SPL para agregar filtro por usuario_insert al momento de hacer consultas y/o fectaciones a la tabla sw_buro_conslineacred.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA 16/02/2017',
'DESCRIPCION: Se modifica SPL para agregar filtro por pUsuario al momento de generar la consulta del grid.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualizareportespendientesarqueosuc(pUsuario CHAR(8), pIdFuncion CHAR(10),pNombreReporte CHAR(100))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;	
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_actualizareportespendientesarqueosuc.out';
		-- TRACE ON;
		
		
		--VALIDACION PARAMETROS DE ENTRADA
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;	
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		UPDATE {+INDEX (bdicnweb:sw_ctrlgenreportesarqueos idx_sw_ctrlgenreportesarqueos)} bdicnweb:"informix".sw_ctrlgenreportesarqueos set status='1' WHERE usuario_insert = pUsuario and nombre_reporte = pNombreReporte;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '01005';		--ERROR AL ACTUALIZAR EL ESTATUS DEL REPORTE
			RETURN cCodRet; 
		ELSE 			
			RETURN cCodRet;
		END IF;		
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 12/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: ACTUALIZA EL ESTATUS DEL REPORTE A 1 PARA INDICAR QUE YA FUE DESCARGADO',
'DESCRIPCION: ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualizareportespendientesentradasalida(pUsuario CHAR(8), pIdFuncion CHAR(10),pNombreReporte CHAR(100))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;	
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_actualizareportespendientesentradasalida.out';
		-- TRACE ON;
		
		
		--VALIDACION PARAMETROS DE ENTRADA
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;	
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		UPDATE {+INDEX (bdicnweb:sw_ctrlgenreportesentradasalida idx_sw_ctrlgenreportesentradasalida)} bdicnweb:"informix".sw_ctrlgenreportesentradasalida set status='1' WHERE usuario_insert = pUsuario and nombre_reporte = pNombreReporte;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '01005';		--ERROR AL ACTUALIZAR EL ESTATUS DEL REPORTE
			RETURN cCodRet; 
		ELSE 			
			RETURN cCodRet;
		END IF;		
		
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 12/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: ACTUALIZA EL ESTATUS DEL REPORTE A 1 PARA INDICAR QUE YA FUE DESCARGADO',
'DESCRIPCION: ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consreportearqueosuc(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(100) AS nombre_reporte,
		DATE AS fecha_reporte,
		DATETIME HOUR TO SECOND AS hr_reporte,
		CHAR(1) AS status;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cNombre_reporte CHAR(100);
	DEFINE dFecha_reporte DATE;
	DEFINE dHr_reporte DATETIME HOUR TO SECOND;
	DEFINE iRecuperacion INTEGER;
	DEFINE cStatus CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha = '';
	LET cNombre_reporte = '';
	LET dFecha_reporte = '';
	LET dHr_reporte = '';
	LET iRecuperacion = 0;
	LET cStatus ='0';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consreportearqueosuc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT {+INDEX (bdicnweb:sw_ctrlgenreportesarqueos idx_sw_ctrlgenreportesarqueos)} SKIP pRegistros FIRST pRecuperacion 
			nombre_reporte, fecha_reporte, hr_reporte, status
			INTO cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus
			FROM bdicnweb:"informix".sw_ctrlgenreportesarqueos
			WHERE fecha_reporte = DATE(CURRENT)
			AND usuario_insert = pUsuario
			ORDER BY hr_reporte ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END IF;	
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 05/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: ARQUEO DE SUCURSALES',
'DESCRIPCION: SPL encargado de consultar el detalle de los reportes generados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consreportearqueosuc_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cNombre_reporte CHAR(100);
	DEFINE dFecha_reporte DATE;
	DEFINE dHr_reporte DATETIME HOUR TO SECOND;
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha = '';
	LET cNombre_reporte = '';
	LET dFecha_reporte = '';
	LET dHr_reporte = '';
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consreportearqueosuc_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT {+INDEX (bdicnweb:sw_ctrlgenreportesarqueos idx_sw_ctrlgenreportesarqueos)} COUNT(*)
		INTO iNumRegistros
		FROM bdicnweb:"informix".sw_ctrlgenreportesarqueos
		WHERE fecha_reporte = DATE(CURRENT)
		AND usuario_insert = pUsuario;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;	
		
		RETURN cCodRet,iNumRegistros;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 05/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: ARQUEO DE SUCURSALES',
'DESCRIPCION: SPL encargado de consultar el nÃºmero total de los reportes generados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consreportesentradasalida(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(100) AS nombre_reporte,
		DATE AS fecha_reporte,
		DATETIME HOUR TO SECOND AS hr_reporte,
		CHAR(1) AS status;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cNombre_reporte CHAR(100);
	DEFINE dFecha_reporte DATE;
	DEFINE dHr_reporte DATETIME HOUR TO SECOND;
	DEFINE iRecuperacion INTEGER;
	DEFINE cStatus CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha = '';
	LET cNombre_reporte = '';
	LET dFecha_reporte = '';
	LET dHr_reporte = '';
	LET iRecuperacion = 0;
	LET cStatus='0';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consreportesentradasalida.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT {+INDEX (bdicnweb:sw_ctrlgenreportesentradasalida idx_sw_ctrlgenreportesentradasalida)} SKIP pRegistros FIRST pRecuperacion 
			nombre_reporte, fecha_reporte, hr_reporte, status
			INTO cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus
			FROM bdicnweb:"informix".sw_ctrlgenreportesentradasalida
			WHERE fecha_reporte = DATE(CURRENT)
			AND usuario_insert = pUsuario
			ORDER BY hr_reporte ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END IF;	
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 05/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: ARQUEO DE SUCURSALES',
'DESCRIPCION: SPL encargado de consultar el detalle de los reportes generados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consreportesentradasalida_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cNombre_reporte CHAR(100);
	DEFINE dFecha_reporte DATE;
	DEFINE dHr_reporte DATETIME HOUR TO SECOND;
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha = '';
	LET cNombre_reporte = '';
	LET dFecha_reporte = '';
	LET dHr_reporte = '';
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consreportesentradasalida_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT {+INDEX (bdicnweb:sw_ctrlgenreportesentradasalida idx_sw_ctrlgenreportesentradasalida)} COUNT(*)
		INTO iNumRegistros
		FROM bdicnweb:"informix".sw_ctrlgenreportesentradasalida
		WHERE fecha_reporte = DATE(CURRENT)
		AND usuario_insert = pUsuario;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;	
		
		RETURN cCodRet,iNumRegistros;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 05/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: ARQUEO DE SUCURSALES',
'DESCRIPCION: SPL encargado de consultar el nÃºmero total de los reportes generados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainfentradasalidacaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSucursal CHAR(1), pIdSucursal CHAR(4), 
			pIdPlaza CHAR(3), pFechaInic DATE, pFechaFin DATE, pMes CHAR(2), pAnio CHAR(4), pIdStatus CHAR(2), pRegistros INTEGER, pRecuperacion INTEGER)
		
		RETURNING CHAR(5) AS codret,  			
		         CHAR(50) AS caja_general,     	
                 CHAR(8) AS folio_ope,	     	
		         CHAR(40) AS status,		    
                 CHAR(50) AS sucursal,	      	
                 CHAR(16) AS folio_suc,	     	
		         DATE AS fecha_solicitud,       
		         CHAR(8) AS us_solicito,     	
		         DATE AS fecha_envio,	      	
		         CHAR(8) AS us_envio,	     	
		         DATE AS fecha_recepcion,     	
		         CHAR(8) AS us_recepcion,  	   	
		         MONEY(14,2) AS monto,	     	
		         DATE AS fecha_reversion,      	
		         CHAR(8) AS us_reversion,          	
		         CHAR(40) AS plaza,				
				 CHAR(10) AS tpo_suc;  	     	
		
		 
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		
		DEFINE cCajaGeneral CHAR(50);
		DEFINE cFolioOpe CHAR(8);
		DEFINE cStatus CHAR(40);
        DEFINE cSucursal CHAR(50);
        DEFINE cFolioSuc CHAR(16);
		DEFINE dFechaSolicitud DATE;
		DEFINE cUsSolicitud CHAR(8); 
		DEFINE dFechaEnvio DATE;
		DEFINE cUsEnvio CHAR(8);     
		DEFINE dFechaRecepcion DATE;
		DEFINE cUsRecepcion CHAR(8); 
		DEFINE cOtroStatus CHAR(40); 
		DEFINE mMonto MONEY(14,2);
		DEFINE dFechaReversion DATE; 
		DEFINE cUsReversion CHAR(8);   
		DEFINE cPlaza CHAR(40);
		DEFINE cTpoSucRSP CHAR(1); 
		DEFINE cTpoSuc CHAR(10); 
		DEFINE iExisteSuc INTEGER;
		DEFINE iExisteATM INTEGER;
		
        DEFINE cEmpresa CHAR(3);
        DEFINE iNoRegistros INTEGER; 
        DEFINE iRecuperacion INTEGER;
        DEFINE iRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		
		LET cCajaGeneral = '';
		LET cFolioOpe = '';
		LET cStatus = '';
		LET cSucursal = '';
		LET cFolioSuc = '';
		LET dFechaSolicitud = '';
		LET cUsSolicitud = '';   
		LET dFechaEnvio = ''; 	 
		LET cUsEnvio = '';       
		LET dFechaRecepcion = '';
		LET cUsRecepcion = '';   
		LET cOtroStatus = '';    
		LET mMonto = '';         
		LET dFechaReversion = '';   
		LET cUsReversion = '';   
		LET cPlaza = '';   
		LET cTpoSuc = '';
		LET cTpoSucRSP = '';
		LET iExisteSuc = 0;
		LET iExisteATM = 0;
		
		LET cEmpresa = '001';
        LET iNoRegistros = 0; 
        LET iRecuperacion = 0;
        LET iRegistros = 0;


		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, cCajaGeneral, cFolioOpe, cStatus, cSucursal, cFolioSuc, dFechaSolicitud, cUsSolicitud, 
					   dFechaEnvio, cUsEnvio, dFechaRecepcion, cUsRecepcion, mMonto, dFechaReversion, cUsReversion, cPlaza, cTpoSuc;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultainfentradasalidacaja.out';
            --TRACE ON;
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
            
			IF pUsuario = '' OR pIdFuncion = '' OR pTipoSucursal = '' OR pIdPlaza = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCajaGeneral, cFolioOpe, cStatus, cSucursal, cFolioSuc, dFechaSolicitud, cUsSolicitud, 
					   dFechaEnvio, cUsEnvio, dFechaRecepcion, cUsRecepcion, mMonto, dFechaReversion, cUsReversion, cPlaza, cTpoSuc;
            END IF;
            
            -- VALIDACIÃN DE LOS DATOS DE PAGINACION
            IF pRegistros < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cCajaGeneral, cFolioOpe, cStatus, cSucursal, cFolioSuc, dFechaSolicitud, cUsSolicitud, 
					   dFechaEnvio, cUsEnvio, dFechaRecepcion, cUsRecepcion, mMonto, dFechaReversion, cUsReversion, cPlaza, cTpoSuc;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cCajaGeneral, cFolioOpe, cStatus, cSucursal, cFolioSuc, dFechaSolicitud, cUsSolicitud, 
					   dFechaEnvio, cUsEnvio, dFechaRecepcion, cUsRecepcion, mMonto, dFechaReversion, cUsReversion, cPlaza, cTpoSuc;
			END IF;
			
			IF pTipoSucursal = 'S' OR pTipoSucursal = 'C' THEN
					
				FOREACH SELECT {+INDEX (bdicnweb:tmp_entradasalida idx_tmp_entradasalida)} SKIP pRegistros FIRST pRecuperacion codproveedor, foloper, desstatus, sucursal, folsuc, fecsol, usuariosol,
							fecenvio,usuarioenv, fecrecepcion, usuariorecep, monto, fecrever, vusuariorever, nomplaza, tipo_suc
					INTO cCajaGeneral, cFolioOpe, cStatus, cSucursal, cFolioSuc, dFechaSolicitud, cUsSolicitud, 
					dFechaEnvio, cUsEnvio, dFechaRecepcion, cUsRecepcion, mMonto, dFechaReversion, cUsReversion, cPlaza, cTpoSucRSP
					FROM bdicnweb:"informix".tmp_entradasalida  
					WHERE id_usuario = pUsuario
				
					-- RENOMBRA TIPO
					IF cTpoSucRSP = 'S' THEN
						LET cTpoSuc = 'SUCURSAL';
					ELIF cTpoSucRSP = 'C' THEN
						LET cTpoSuc = 'ATM';
					END IF;
				
					RETURN cCodRet, UPPER(cCajaGeneral), cFolioOpe, UPPER(cStatus), UPPER(cSucursal), cFolioSuc, dFechaSolicitud, cUsSolicitud, 
					       dFechaEnvio, cUsEnvio, dFechaRecepcion, cUsRecepcion, mMonto, dFechaReversion, cUsReversion, UPPER(cPlaza), UPPER(cTpoSuc) WITH RESUME;
					LET iRecuperacion = iRecuperacion + 1;
														
				END FOREACH;
				
				IF iRecuperacion = 0 AND pRegistros = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '';	
				ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
					LET cCodRet = '1001';
					RETURN cCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '';	
				END IF;			
				
			ELIF pTipoSucursal = 'A' THEN
						
				
				FOREACH SELECT {+INDEX (bdicnweb:tmp_entradasalida idx_tmp_entradasalida)} SKIP pRegistros FIRST pRecuperacion codproveedor, foloper, desstatus, sucursal, folsuc, fecsol, usuariosol,
							fecenvio,usuarioenv, fecrecepcion, usuariorecep, monto, fecrever, vusuariorever, nomplaza, tipo_suc
					INTO cCajaGeneral, cFolioOpe, cStatus, cSucursal, cFolioSuc, dFechaSolicitud, cUsSolicitud, 
					dFechaEnvio, cUsEnvio, dFechaRecepcion, cUsRecepcion, mMonto, dFechaReversion, cUsReversion, cPlaza, cTpoSucRSP
					FROM bdicnweb:"informix".tmp_entradasalida  
					WHERE id_usuario = pUsuario
				
					-- RENOMBRA TIPO
					IF cTpoSucRSP = 'S' THEN
						LET cTpoSuc = 'SUCURSAL';
					ELIF cTpoSucRSP = 'C' THEN
						LET cTpoSuc = 'ATM';
					END IF;
				
					RETURN cCodRet, UPPER(cCajaGeneral), cFolioOpe, UPPER(cStatus), UPPER(cSucursal), cFolioSuc, dFechaSolicitud, cUsSolicitud, 
					       dFechaEnvio, cUsEnvio, dFechaRecepcion, cUsRecepcion, mMonto, dFechaReversion, cUsReversion, UPPER(cPlaza), UPPER(cTpoSuc) WITH RESUME;
					LET iRecuperacion = iRecuperacion + 1;
														
				END FOREACH;
				
				IF iRecuperacion = 0 AND pRegistros = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '';	
				ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
					LET cCodRet = '1001';
					RETURN cCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '';	
				END IF;			
			
			
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/02/2020',
'DESCRIPCION: SPL que realiza la consulta para el llenado del grid Listado de Registros y Detalle de Saldo por Plaza, Consultas Entrada Salida Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_totalesentradasalidacaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSucursal CHAR(1), pIdSucursal CHAR(4), 
        pIdPlaza CHAR(3), pFechaInic DATE, pFechaFin DATE, pMes CHAR(2), pAnio CHAR(4), pIdStatus CHAR(2),
        pMac CHAR(18), pIp VARCHAR(16))
        RETURNING CHAR(5) AS codret,
                INTEGER AS totalRegistros;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(5);
        DEFINE cEmpresa CHAR(3);
        DEFINE iTotalRegistros_S INTEGER;
        DEFINE iTotalRegistros_C INTEGER;
        DEFINE iTotalRegistros INTEGER;

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET cEmpresa = '001';
        LET iTotalRegistros_S = 0;
        LET iTotalRegistros_C = 0;
        LET iTotalRegistros = 0;

        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
					    SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
                        RETURN cCodRet, iTotalRegistros;
                END EXCEPTION;
				
				SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
            
                --SET DEBUG FILE TO '/tmp/mfinis/sp_totalesentradasalidacaja.out';
                --TRACE ON;
                
                -- SE LIMPIA TABLA POR USUARIO
                DELETE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} FROM bdicnweb:"informix".sw_verificastatusentradasalida WHERE usuario_insert = TRIM(pUsuario);
                
                -- SE INSERTA PROCESO
                INSERT INTO bdicnweb:"informix".sw_verificastatusentradasalida(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);

                DELETE {+INDEX (bdicnweb:tmp_entradasalida idx_tmp_entradasalida)} FROM bdicnweb:"informix".tmp_entradasalida  where id_usuario = pUsuario;
				
                IF pUsuario = '' OR pIdFuncion = '' OR pIdPlaza = '' THEN
                        LET cCodRet = '00003';
                        --Actualiza proceso erroneo
                         UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
					     SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
                
                        RETURN cCodRet, iTotalRegistros;
                END IF;

                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        --Actualiza proceso erroeo
                          UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
						  SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
                        
                        RETURN cCodRet, iTotalRegistros;
                END IF;
				
                IF pTipoSucursal = 'S' OR pTipoSucursal = 'C' THEN
                
                        FOREACH EXECUTE PROCEDURE bdisuc:"informix".sp_entrada_salida(pUsuario,pIdFuncion,cEmpresa, pTipoSucursal, pIdSucursal, pIdPlaza, pFechaInic, pFechaFin, pMes, pAnio, pIdStatus, '1')
                                        INTO cCodRetSp, iTotalRegistros
                                        
                                        IF cCodRetSp::INTEGER < 0 THEN -- Hubo una excepcion
                                                        RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_entrada_salida';
                                        ELIF cCodRetSp::INTEGER = 0 THEN 
                                                        ---Actualiza proceso exitoso
                                                      UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
													  SET status = 'T', error_proceso = 'N', num_registros = iTotalRegistros WHERE usuario_insert = pUsuario;
                                                      RETURN cCodRet, iTotalRegistros;
                                        END IF;
                        END FOREACH;
                
                ELIF pTipoSucursal = 'A' THEN
                
                        LET pTipoSucursal = 'S';
                        FOREACH EXECUTE PROCEDURE bdisuc:"informix".sp_entrada_salida(pUsuario,pIdFuncion,cEmpresa, pTipoSucursal, pIdSucursal, pIdPlaza, pFechaInic, pFechaFin, pMes, pAnio, pIdStatus, '1')
                                        INTO cCodRetSp, iTotalRegistros_S
                                        
                                        IF cCodRetSp::INTEGER < 0 THEN
                                                        RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_entrada_salida';
                                        END IF;
                        END FOREACH;
                        
                        LET pTipoSucursal = 'C';
                        FOREACH EXECUTE PROCEDURE bdisuc:"informix".sp_entrada_salida(pUsuario,pIdFuncion,cEmpresa, pTipoSucursal, pIdSucursal, pIdPlaza, pFechaInic, pFechaFin, pMes, pAnio, pIdStatus, '2')
                                        INTO cCodRetSp, iTotalRegistros_C
                                        
                                        IF cCodRetSp::INTEGER < 0 THEN
                                                        RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_entrada_salida';
                                        END IF;
                        END FOREACH;
                        
                        LET iTotalRegistros = (iTotalRegistros_S + iTotalRegistros_C);
                        TRACE iTotalRegistros;
                        
                        --Actualiza proceso exitoso
                        UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
						SET status = 'T', error_proceso = 'N', num_registros = iTotalRegistros WHERE usuario_insert = pUsuario;
                        RETURN cCodRet, iTotalRegistros;
                
                END IF;
                
                IF iTotalRegistros = 0 THEN
                        LET cCodRet = '00017';
                        --Actualiza proceso erroneo
                        UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
						SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;

                        RETURN cCodRet, iTotalRegistros;
                END IF;
 
    END;

END PROCEDURE 
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/02/2021',
'DESCRIPCION: SPL que consulta el total de registros para el llenado del grid Listado de registros y detalle de saldo por plaza, Consultas Entrada Salida Caja General',
'AUTOR: Saul Ortiz Baeza',
'FECHA: 26/04/2016',
'DESCRIPCION: Se realizo el ajuste para consultar el total de registros por monitoreo de proceso.',
'AUTOR: Julio Martinez',
'FECHA: 05/04/2017',
'DESCRIPCION: Se realiza el tratamiento de la inserccion de totales en el monitor de procesos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificareportespendientesarqueosuc(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET iNumRegistros = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;	
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_verificareportespendientesarqueosuc.out';
		-- TRACE ON;
		
		
		--VALIDACION PARAMETROS DE ENTRADA
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;	
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		select {+INDEX (bdicnweb:sw_ctrlgenreportesarqueos idx_sw_ctrlgenreportesarqueos)} count (status) as filas 
		INTO iNumRegistros
		FROM bdicnweb:"informix".sw_ctrlgenreportesarqueos WHERE usuario_insert = pUsuario and status ='0';
		
	    RETURN cCodRet,iNumRegistros;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 12/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: VERIFICA SI EL USUARIO TIENE REPORTES POR DESCARGAR --ESTATUS 0 ',
'DESCRIPCION: ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificareportespendientesentradasalida(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET iNumRegistros = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;	
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_verificareportespendientesentradasalida.out';
		-- TRACE ON;
		
		
		--VALIDACION PARAMETROS DE ENTRADA
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;	
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		select {+INDEX (bdicnweb:sw_ctrlgenreportesentradasalida idx_sw_ctrlgenreportesentradasalida)} count (status) as filas 
		INTO iNumRegistros
		FROM bdicnweb:"informix".sw_ctrlgenreportesentradasalida WHERE usuario_insert = pUsuario and status ='0';
		
	    RETURN cCodRet,iNumRegistros;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 12/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: VERIFICA SI EL USUARIO TIENE REPORTES POR DESCARGAR --ESTATUS 0 ',
'DESCRIPCION: ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusentradasalida(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusentradasalida.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM bdicnweb:sw_verificastatusentradasalida WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: VERIFICA EL ESTATUS DEL PROCESO ',
'DESCRIPCION: ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_ejecutaquery(pUsuario CHAR(8),pIdFuncion CHAR(10),pCteTitular CHAR(20),pCteTraspasa CHAR(20),pUsEjecuta CHAR(8),pIdEjecucion CHAR(1))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cValor CHAR(100);
	DEFINE iNoRegistros INTEGER;
	DEFINE cTipo_clienteTit CHAR(1);
	DEFINE cTipo_clienteTras CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cValor = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_ejecutaquery.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEjecucion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pIdEjecucion = '1' THEN
--Inicio CC 49391
/*
			UPDATE bdinteg:"informix".si_cliente SET tipo_cliente = '1' WHERE numcte = pCteTitular AND empresa = cEmpresa;
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			END IF;
*/
			--Se consulta el tipo de cliente de ambos clientes
			SELECT {+AVOID_FULL (bdinteg:"informix".si_cliente)}
			tipo_cliente
			INTO cTipo_clienteTit
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = pCteTitular
			;
			
			SELECT {+AVOID_FULL (bdinteg:"informix".si_cliente)}
			tipo_cliente
			INTO cTipo_clienteTras
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = pCteTraspasa
			;
			
			IF cTipo_clienteTras IS NULL THEN
				SELECT {+AVOID_FULL (bdinteg:"informix".si_fuscliente)}
				tipo_cliente
				INTO cTipo_clienteTras
				FROM bdinteg:"informix".si_fuscliente
				WHERE numcte = pCteTraspasa
				;
			END IF;
			
			IF (cTipo_clienteTit = '2' AND cTipo_clienteTras = '1') THEN
				UPDATE bdinteg:"informix".si_cliente SET tipo_cliente = '1' WHERE numcte = pCteTitular AND empresa = cEmpresa;
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				END IF;
			END IF;
--Fin CC 49391
		ELIF pIdEjecucion = '2' THEN
			INSERT INTO bdinteg:"informix".si_fusclientes_ide (cliente_tit, cliente_tras, fecha) VALUES (pCteTitular,pCteTraspasa,CURRENT);
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			END IF;
		END IF;

		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de ejecutar una instruccion.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cancelacion_claves_retiro( pUsuario CHAR(8), pIdFuncion CHAR(10), 
	pFoliooperacion CHAR(100), pCliente CHAR(20), pCuenta CHAR(20), pTarjeta CHAR(19), pFecha_inicial DATE, pFecha_final DATE, pIp CHAR(20), pRegistros INTEGER, pRecuperacion INTEGER)
	
	RETURNING
		CHAR(5) AS codret,
		CHAR(100) AS folio,
		DATETIME YEAR TO SECOND AS fecha,
		CHAR(20) AS numCliente,
		CHAR(20) AS numCuenta,
		CHAR(20) AS numTarjeta,
		MONEY(16,2) AS monto,
		CHAR(10) AS canalCobro,
		CHAR(1) AS status,
		CHAR(20) AS descStatus;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE condition CHAR(200);
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE vFolio CHAR(100);
	DEFINE dFecha DATETIME YEAR TO FRACTION(3);
	DEFINE vNumCliente CHAR(20);
	DEFINE vNumCuenta CHAR(20);
	DEFINE vNumTarjeta CHAR(20);
	DEFINE mMonto MONEY(16,2);
	DEFINE vCanalCobro CHAR(10);
	DEFINE cStatus CHAR(1);
	DEFINE vDescStatus CHAR(20);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET condition = '';
	LET cAccion = 'CONSULTA CANCELACION CLAVES RETIROS';
	LET cEntidad = 'claves_retiro';
	LET vFolio = '';
	LET dFecha = '';
	LET vNumCliente = '';
	LET vNumCuenta = '';
	LET vNumTarjeta = '';
	LET mMonto = 0;
	LET vCanalCobro = '';
	LET cStatus = '';
	LET vDescStatus = '';
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, vFolio, dFecha, vNumCliente, vNumCuenta, vNumTarjeta, mMonto, vCanalCobro, cStatus, vDescStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cancelacion_claves_retiro.out';
		--TRACE ON;
		
		IF pUsuario = '' OR  pIdFuncion = '' OR pIp = '' OR pFecha_inicial = '' OR pFecha_final = ''THEN
			LET cCodRet = '00003';
			RETURN cCodRet, vFolio, dFecha, vNumCliente, vNumCuenta, vNumTarjeta, mMonto, vCanalCobro, cStatus, vDescStatus;
		END IF;

		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, vFolio, dFecha, vNumCliente, vNumCuenta, vNumTarjeta, mMonto, vCanalCobro, cStatus, vDescStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, vFolio, dFecha, vNumCliente, vNumCuenta, vNumTarjeta, mMonto, vCanalCobro, cStatus, vDescStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, NULL, pUsuario, 1) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, vFolio, dFecha, vNumCliente, vNumCuenta, vNumTarjeta, mMonto, vCanalCobro, cStatus, vDescStatus;
		END IF;

		FOREACH
			SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} SKIP pRegistros FIRST pRecuperacion cr.cr_foliooperacion, cr.cr_alta_fecha, cr.cr_cliente, cr.cr_cuenta, cr.cr_tarjeta, cr.cr_monto, cr.cr_canal_final, cr.cr_status, cs.cat_descripcion_status 
			INTO vFolio, dFecha, vNumCliente, vNumCuenta, vNumTarjeta, mMonto, vCanalCobro, cStatus, vDescStatus
			FROM bdirst:"informix".claves_retiro AS cr
			INNER JOIN bdirst:"informix".cat_status AS cs ON cs.cat_cod_status = cr.cr_status
			WHERE cr.cr_foliooperacion = CASE WHEN pFoliooperacion = '' THEN cr.cr_foliooperacion ELSE pFoliooperacion END
			AND cr.cr_cliente = CASE WHEN pCliente = '' THEN cr.cr_cliente ELSE pCliente END
			AND cr.cr_cuenta = CASE WHEN pCuenta = '' THEN cr.cr_cuenta ELSE pCuenta END
			AND cr.cr_tarjeta = CASE WHEN pTarjeta = '' THEN cr.cr_tarjeta ELSE pTarjeta END
			AND DATE(cr.cr_alta_fecha) BETWEEN DATE(pFecha_inicial) AND DATE(pFecha_final)
			AND cr.cr_status = 'P'
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, vFolio, dFecha, vNumCliente, vNumCuenta, vNumTarjeta, mMonto, vCanalCobro, cStatus, vDescStatus WITH RESUME;
		END FOREACH;

		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, vFolio, dFecha, vNumCliente, vNumCuenta, vNumTarjeta, mMonto, vCanalCobro, cStatus, vDescStatus WITH RESUME;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, vFolio, dFecha, vNumCliente, vNumCuenta, vNumTarjeta, mMonto, vCanalCobro, cStatus, vDescStatus WITH RESUME;
		END IF;
		
	END;		

END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR',
'FECHA: 19/12/2020',
'MODULO: ADMINISTRACION DE ATM',
'FUNCIONALIDAD: Cancelacion Claves Retiro',
'DESCRIPCION: SPL encargado de extraer informaciÃÂ³n sobre la tabla claves_retiro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cancelacion_claves_retiro_totales( pUsuario CHAR(8), pIdFuncion CHAR(10), 
	pFoliooperacion CHAR(100), pCliente CHAR(20), pCuenta CHAR(20), pTarjeta CHAR(20), pFecha_inicial DATE, pFecha_final DATE)
	
	RETURNING
		CHAR(5) AS codret,
		INTEGER AS 	totRegistros;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iTotales INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iTotales = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotales;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cancelacion_claves_retiro_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR  pIdFuncion = '' OR pFecha_inicial = '' OR pFecha_final = ''THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotales;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotales;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} COUNT(*) AS totales
		INTO iTotales
		FROM bdirst:"informix".claves_retiro AS cr
		INNER JOIN bdirst:"informix".cat_status AS cs ON cs.cat_cod_status = cr.cr_status
		WHERE cr.cr_foliooperacion = CASE WHEN pFoliooperacion = '' THEN cr.cr_foliooperacion ELSE pFoliooperacion END
		AND cr.cr_cliente = CASE WHEN pCliente = '' THEN cr.cr_cliente ELSE pCliente END
		AND cr.cr_cuenta = CASE WHEN pCuenta = '' THEN cr.cr_cuenta ELSE pCuenta END
		AND cr.cr_tarjeta = CASE WHEN pTarjeta = '' THEN cr.cr_tarjeta ELSE pTarjeta END
		AND DATE(cr.cr_alta_fecha) BETWEEN DATE(pFecha_inicial) AND DATE(pFecha_final)
		AND cr.cr_status = 'P';
		

		IF iTotales = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iTotales;

	END;		

END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR',
'FECHA: 19/12/2020',
'MODULO: ADMINISTRACION DE ATM',
'FUNCIONALIDAD: CancelaciÃÂ³n Claves Retiro',
'DESCRIPCION: SPL encargado de obtener el total de registros en tabla claves_retiro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_abm_canal_cobro( pUsuario CHAR(8), pIdFuncion CHAR(10), pid_canal_final VARCHAR(2), pcve_canal_final VARCHAR(30), pnombre_canal VARCHAR(30), pcobrar_otp VARCHAR(1), pBandera integer, pIp VARCHAR(20))
	RETURNING 
		CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE pcodigoStatus CHAR(2);
	DEFINE pdescripcionstatus CHAR(20);
	DEFINE calta_fecha DATE;
	DEFINE cultima_mod_fecha DATE;
	DEFINE cCodigoStatusExistente CHAR(2);
	DEFINE iExiste INTEGER;
	DEFINE lastIdCanalFinal CHAR(2);
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cArchivoRespaldo CHAR(50);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET calta_fecha = CURRENT;
	LET cultima_mod_fecha = CURRENT;
	LET cAccion = '';
	LET cEntidad = 'par_canal_final';
	LET cCmd1 = '';
	LET cArchivoRespaldo = 'ParamRet_'||pUsuario||TO_CHAR(CURRENT, '%d%m%Y');

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_abm_canal_cobro.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pcve_canal_final = '' OR pnombre_canal= ''  OR pBandera IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = 1 THEN
			LET cAccion = 'AGREGA CANAL DE COBRO';
			
			SELECT COUNT(par_cve_canal_final) INTO iExiste 
			FROM bdirst:"informix".par_canal_final
			WHERE UPPER(par_nombre_canal) = UPPER(pnombre_canal); --par_cve_canal_final = pcve_canal_final OR 
			
			IF NVL(iexiste,0) > 0 THEN
				UPDATE bdirst:"informix".par_canal_final
						SET 
						par_cobrar_otp = 'V',
						par_ultima_mod_fecha = cultima_mod_fecha, 
						par_usuario_mod_id_fk = pUsuario 
						WHERE UPPER(par_nombre_canal) = UPPER(pnombre_canal);
				RETURN cCodRet;
			ELSE
				EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, NULL, pUsuario, 1) INTO cCodRet;
				
				IF cCodRet = '00000' THEN 
				FOREACH
					SELECT  first 1 par_id_canal_final INTO lastIdCanalFinal FROM bdirst:"informix".par_canal_final order by par_id_canal_final::INTEGER desc
					END FOREACH;
					IF NVL(lastIdCanalFinal,'') = '' THEN
						LET lastIdCanalFinal = 1;
					ELSE
						LET lastIdCanalFinal = lastIdCanalFinal + 1;
					END IF;
				
					INSERT INTO bdirst:"informix".par_canal_final (par_id_canal_final, par_cve_canal_final, par_nombre_canal, par_alta_fecha, par_cobrar_otp, par_usuario_alta_id_fk )
					VALUES(lastIdCanalFinal, pcve_canal_final, pnombre_canal, calta_fecha, pcobrar_otp , pUsuario);
				ELSE
					LET cCodRet = '99999';
					RETURN cCodRet;
				END IF;
				
			END IF;
		END IF;
		
		IF pBandera = 2 THEN
			LET cAccion = 'MODIFICA CANAL DE COBRO';
			
			LET cCmd1 ="";	
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'par_id_canal_final','par_cve_canal_final', 'par_nombre_canal', 'par_alta_fecha', 'par_cobrar_otp', 'par_ultima_mod_fecha', 'par_usuario_alta_id_fk', 'par_usuario_mod_id_fk'";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT par_id_canal_final, par_cve_canal_final, par_nombre_canal, par_alta_fecha::VARCHAR(10), par_cobrar_otp, par_ultima_mod_fecha::VARCHAR(10), par_usuario_alta_id_fk::VARCHAR(10), par_usuario_mod_id_fk::VARCHAR(10)";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".par_canal_final WHERE par_id_canal_final = '"||TRIM(pid_canal_final)||"' AND par_cve_canal_final = '"||TRIM(pcve_canal_final)||"')";
			
			EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
			IF cCodRet = '00000' THEN 
				EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
				
				IF (pid_canal_final <> '' AND pcve_canal_final <> '') OR (pcve_canal_final IS NOT NULL AND pid_canal_final IS NOT NULL) THEN -- VALIDAR CON JOHN SI SE REALIZA LA VALIDACION CON NULL
					IF pcobrar_otp <>'' THEN
						UPDATE bdirst:"informix".par_canal_final
						SET par_nombre_canal = pnombre_canal,
						par_cobrar_otp = pcobrar_otp,
						par_ultima_mod_fecha = cultima_mod_fecha, 
						par_usuario_mod_id_fk = pUsuario 
						WHERE par_cve_canal_final = pcve_canal_final AND par_id_canal_final = pid_canal_final;
					ELSE
						UPDATE bdirst:"informix".par_canal_final
						SET par_nombre_canal = pnombre_canal,
						par_ultima_mod_fecha = cultima_mod_fecha, 
						par_usuario_mod_id_fk = pUsuario 
						WHERE par_cve_canal_final = pcve_canal_final AND par_id_canal_final = pid_canal_final;
					END IF;
					
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00283';
						RETURN cCodRet;
					END IF;
				ELSE
					LET cCodRet = '00003';
					RETURN cCodRet;
				END IF;
			ELSE
				LET cCodRet = '99999';
				RETURN cCodRet;
			END IF;
			
		END IF;
		
		IF pBandera = 3 THEN
			LET cAccion = 'ELIMINA CANAL DE COBRO';
			
			LET cCmd1 ="";	
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'par_id_canal_final','par_cve_canal_final', 'par_nombre_canal', 'par_alta_fecha', 'par_cobrar_otp', 'par_ultima_mod_fecha', 'par_usuario_alta_id_fk', 'par_usuario_mod_id_fk'";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT par_id_canal_final, par_cve_canal_final, par_nombre_canal, par_alta_fecha::VARCHAR(10), par_cobrar_otp, par_ultima_mod_fecha::VARCHAR(10), par_usuario_alta_id_fk::VARCHAR(10), par_usuario_mod_id_fk::VARCHAR(10)";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".par_canal_final WHERE par_id_canal_final = '"||TRIM(pid_canal_final)||"' AND par_cve_canal_final = '"||TRIM(pcve_canal_final)||"')";
			
			EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
			IF cCodRet = '00000' THEN 
				EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
				
				IF pid_canal_final <> '' THEN
					UPDATE bdirst:"informix".par_canal_final
						SET 
						par_cobrar_otp = 'F',
						par_ultima_mod_fecha = cultima_mod_fecha, 
						par_usuario_mod_id_fk = pUsuario 
						WHERE par_cve_canal_final = pcve_canal_final;
					
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00862';
						RETURN cCodRet;
					END IF;
				ELSE
					LET cCodRet = '00003';
					RETURN cCodRet;
				END IF;
			ELSE
				LET cCodRet = '99999';
				RETURN cCodRet;
			END IF;
		END IF;
		
		RETURN cCodRet;
	END

END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 22/12/2020',
'MODULO: ADMINISTRACIÃÂN DE ATM',
'FUNCIONALIDAD:  Cabales de cobro',
'DESCRIPCION: SPL de la Alta, Actualizacion y delete de Canales de cobro',
'BD: bdirst';

CREATE PROCEDURE "informix".sp_abm_canal_generacion( pUsuario CHAR(8), pIdFuncion CHAR(10), pId_canal_inicial VARCHAR(2), pCve_canal_inicial VARCHAR(30), pNombre_canal VARCHAR(30), pGenerar_otp VARCHAR(1), pBandera INTEGER, pIp VARCHAR(20))
	RETURNING 
		CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE pcodigoStatus CHAR(2);
	DEFINE pdescripcionstatus CHAR(20);
	DEFINE calta_fecha DATE;
	DEFINE cultima_mod_fecha DATE;
	DEFINE cCodigoStatusExistente CHAR(2);
	DEFINE iExiste INTEGER;
	DEFINE lastIdCanalInicial CHAR(2);
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE cIp CHAR(20);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cArchivoRespaldo CHAR(50);
	DEFINE cNombre_canal CHAR(30);
	
	LET cNombre_canal = TRIM(pNombre_canal);	
	LET cAccion = '';
	LET cEntidad = 'par_canal_inicial';
	LET cIp = pIp;
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET calta_fecha = CURRENT;
	LET cultima_mod_fecha = CURRENT;
	LET cCmd1 = '';
	LET cArchivoRespaldo = 'ParamRet_'||pUsuario||TO_CHAR(CURRENT, '%d%m%Y');

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_abm_canal_generacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCve_canal_inicial = ''  OR pNombre_canal= '' OR pBandera IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = 1 THEN
			SELECT {+INDEX (bdirst:par_canal_inicial idx_nombre_canal_inicial)} COUNT(par_cve_canal_inicial) INTO iExiste 
			FROM bdirst:"informix".par_canal_inicial
			WHERE UPPER(par_nombre_canal) = UPPER(cNombre_canal);			
			LET cAccion = 'AGREGA CANAL DE GENERACION';
			
			IF NVL(iexiste,0) > 0 THEN
				
				UPDATE bdirst:"informix".par_canal_inicial
							SET 
							par_generar_otp = 'V',
							par_ultima_mod_fecha = cultima_mod_fecha, 
							par_usuario_mod_id_fk = pUsuario 
							WHERE UPPER(par_nombre_canal) = UPPER(cNombre_canal);
				
				RETURN cCodRet;
			ELSE
				EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, NULL, pUsuario, 1) INTO cCodRet;
				
				IF cCodRet = '00000' THEN 
				
                FOREACH
					SELECT {+INDEX (bdirst:par_canal_inicial idx_nombre_canal_inicial)} first 1 par_id_canal_inicial INTO lastIdCanalInicial FROM bdirst:"informix".par_canal_inicial order by par_id_canal_inicial::INTEGER desc
            	END FOREACH;			
					IF NVL(lastIdCanalInicial,'') = '' THEN
						LET lastIdCanalInicial = 1;
					ELSE
						LET lastIdCanalInicial = lastIdCanalInicial + 1;
					END IF;
				
					INSERT INTO bdirst:"informix".par_canal_inicial (par_id_canal_inicial, par_cve_canal_inicial, par_nombre_canal, par_alta_fecha, par_generar_otp, par_usuario_alta_id_fk )
					VALUES(lastIdCanalInicial, pcve_canal_inicial, pnombre_canal, calta_fecha, pgenerar_otp , pUsuario);
				ELSE
					LET cCodRet = '99999';
				END IF;
			END IF;
		END IF;
			
		IF pBandera = 2 THEN
		
			SELECT {+INDEX (bdirst:par_canal_inicial idx_nombre_canal_inicial)} COUNT(par_cve_canal_inicial) INTO iExiste 
			FROM bdirst:"informix".par_canal_inicial
			WHERE par_nombre_canal = cNombre_canal;			
			IF NVL(iexiste,0) > 0 THEN
				LET cCodRet = '00004';
				RETURN cCodRet;
			ELSE
			
				LET cAccion = 'MODIFICA CANAL DE GENERACION';
			
				LET cCmd1 ="";	
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'par_id_canal_inicial', 'par_cve_canal_inicial', 'par_nombre_canal', 'par_alta_fecha', 'par_generar_otp', 'par_ultima_mod_fecha', 'par_usuario_alta_id_fk', 'par_usuario_mod_id_fk'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT par_id_canal_inicial, par_cve_canal_inicial, par_nombre_canal, par_alta_fecha::VARCHAR(10), par_generar_otp, par_ultima_mod_fecha::VARCHAR(10), par_usuario_alta_id_fk::VARCHAR(10), par_usuario_mod_id_fk::VARCHAR(10)";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".par_canal_inicial WHERE par_id_canal_inicial = '"||TRIM(pid_canal_inicial)||"' AND par_cve_canal_inicial = '"||TRIM(pcve_canal_inicial)||"')";
			
				EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
				IF cCodRet = '00000' THEN 
					EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, cIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
					IF (pid_canal_inicial <> '' AND pcve_canal_inicial <> '') OR (pcve_canal_inicial IS NOT NULL AND pid_canal_inicial IS NOT NULL) THEN -- VALIDAR CON JOHN SI SE REALIZA LA VALIDACION CON NULL
						IF pgenerar_otp <>'' THEN
							UPDATE bdirst:"informix".par_canal_inicial
							SET par_nombre_canal = pnombre_canal,
							par_generar_otp = pgenerar_otp,
							par_ultima_mod_fecha = cultima_mod_fecha, 
							par_usuario_mod_id_fk = pUsuario 
							WHERE par_cve_canal_inicial = pcve_canal_inicial AND par_id_canal_inicial = pid_canal_inicial;
						ELSE
							UPDATE bdirst:"informix".par_canal_inicial
							SET par_nombre_canal = pnombre_canal,
							par_ultima_mod_fecha = cultima_mod_fecha, 
							par_usuario_mod_id_fk = pUsuario 
							WHERE par_cve_canal_inicial = pcve_canal_inicial AND par_id_canal_inicial = pid_canal_inicial;
						END IF;
						
						IF DBINFO("sqlca.sqlerrd2") = 0 THEN
							LET cCodRet = '00283';
							RETURN cCodRet;
						END IF;
				
					ELSE
						LET cCodRet = '00003';
						RETURN cCodRet;
					END IF;
				ELSE
					LET cCodRet = '99999';
					RETURN cCodRet;
				END IF;
			END IF;
		END IF;
		
		IF pBandera = 3 THEN
			LET cAccion = 'ELIMINA CANAL DE GENERACION';
			
			LET cCmd1 ="";	
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'par_id_canal_inicial', 'par_cve_canal_inicial', 'par_nombre_canal', 'par_alta_fecha', 'par_generar_otp', 'par_ultima_mod_fecha', 'par_usuario_alta_id_fk', 'par_usuario_mod_id_fk'";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT par_id_canal_inicial, par_cve_canal_inicial, par_nombre_canal, par_alta_fecha::VARCHAR(10), par_generar_otp, par_ultima_mod_fecha::VARCHAR(10), par_usuario_alta_id_fk::VARCHAR(10), par_usuario_mod_id_fk::VARCHAR(10)";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".par_canal_inicial WHERE par_id_canal_inicial = '"||TRIM(pid_canal_inicial)||"' AND par_cve_canal_inicial = '"||TRIM(pcve_canal_inicial)||"')";
			
			EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
			IF cCodRet = '00000' THEN 
				EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, cIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
				
				IF pid_canal_inicial <> '' THEN
					
					UPDATE bdirst:"informix".par_canal_inicial
							SET 
							par_generar_otp = 'F',
							par_ultima_mod_fecha = cultima_mod_fecha, 
							par_usuario_mod_id_fk = pUsuario 
							WHERE par_cve_canal_inicial = pcve_canal_inicial AND par_id_canal_inicial = pid_canal_inicial;
					
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00862';
						RETURN cCodRet;
					END IF;
				
				ELSE
					LET cCodRet = '00003';
					RETURN cCodRet;
				END IF;
			ELSE
				LET cCodRet = '99999';
				RETURN cCodRet;
			END IF;
		END IF;
		
		RETURN cCodRet;
	END

END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 22/12/2020',
'MODULO: ADMINISTRACIÃÂN DE ATM',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL de la Alta, Actualizacion y delete de Canales de generaciÃÂ³n',
'BD: bdirst';

CREATE PROCEDURE "informix".sp_abm_parametro_status( pUsuario CHAR(8), pIdFuncion CHAR(10),
	pIdStatus VARCHAR(2), pCodigoStatus VARCHAR(2), pDescripcionstatus VARCHAR(20), pBandera INTEGER, pIp VARCHAR(20))
	
	RETURNING 
		CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cAlta_fecha DATE;
	DEFINE cultima_mod_fecha DATE;
	DEFINE iExiste INTEGER;
	DEFINE lastIdStatus CHAR(2);
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE cip CHAR(20);
	DEFINE crespaldo CHAR(50);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cArchivoRespaldo CHAR(50);
	DEFINE cCdigoEstatus CHAR(2);
	DEFINE cDescripcionstatus CHAR(20);
		
	LET cDescripcionstatus = TRIM(pDescripcionstatus);
	LET cAccion = '';
	LET cEntidad = 'cat_status';
	LET cip = pip;
	LET crespaldo = '';
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cAlta_fecha = CURRENT;
	LET cultima_mod_fecha = CURRENT;
	LET cCmd1 = '';
	LET cArchivoRespaldo = 'ParamRet_'||pUsuario||TO_CHAR(CURRENT, '%d%m%Y');
	LET cCdigoEstatus = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_abm_parametro_status.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDescripcionstatus= '' OR pBandera IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = 1 THEN
			LET cAccion = 'AGREGA PARAMETRO ESTATUS';
			
			SELECT {+INDEX (bdirst:cat_status idx_cat_status)} COUNT(cat_cod_status) INTO iExiste 
			FROM bdirst:"informix".cat_status 
			WHERE UPPER(cat_descripcion_status) = UPPER(cDescripcionstatus); --cat_cod_status = pCodigoStatus OR 
			
			IF NVL(iexiste,0) > 0 THEN
				LET cCodRet = '00004';
				RETURN cCodRet;
			ELSE
				EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, NULL, pUsuario, 1) INTO cCodRet;
				
				IF cCodRet = '00000' THEN 
					SELECT {+INDEX (bdirst:cat_status idx_cat_status)} MAX (cat_id_status::INTEGER) INTO lastIdStatus FROM bdirst:"informix".cat_status;
					
					IF NVL(lastIdStatus, 0) = 0 THEN 
						LET lastIdStatus =  1;
					ELSE 
						LET lastIdStatus = lastIdStatus + 1;
					END IF;
				
					INSERT INTO bdirst:"informix".cat_status (cat_id_status, cat_cod_status, cat_descripcion_status, cat_alta_fecha, cat_usuario_alta_id_fk)
					VALUES(lastIdStatus, cCdigoEstatus, pDescripcionstatus, cAlta_fecha, pUsuario);
				ELSE 
					LET cCodRet = '99999'; 
				END IF;
				
			END IF;
		END IF;
		
		IF pBandera = 2 THEN
			
			SELECT {+INDEX (bdirst:cat_status idx_cat_status)} COUNT(cat_cod_status) INTO iExiste 
			FROM bdirst:"informix".cat_status 
			WHERE cat_descripcion_status = cDescripcionstatus; --cat_cod_status = pCodigoStatus OR 
			
			IF NVL(iexiste,0) > 0 THEN
				LET cCodRet = '00004';
				RETURN cCodRet;
			ELSE
				LET cAccion = 'MODIFICACION PARAMETROS ESTATUS';
				LET cCmd1 ="";	
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'cat_id_status', 'cat_cod_status', 'cat_descripcion_status', 'cat_alta_fecha', 'cat_ultima_mod_fecha', 'cat_usuario_alta_id_fk', 'cat_usuario_mod_id_fk'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT cat_id_status, cat_cod_status, cat_descripcion_status, cat_alta_fecha::VARCHAR(10), cat_ultima_mod_fecha::VARCHAR(10), cat_usuario_alta_id_fk::VARCHAR(11), cat_usuario_mod_id_fk::VARCHAR(11)";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".cat_status WHERE cat_cod_status = '"||pCodigoStatus||"' AND cat_id_status = '"||pIdStatus||"')";
			
				EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
				IF cCodRet = '00000' THEN 
					EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, cIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
					
					UPDATE bdirst:"informix".cat_status 
					SET cat_descripcion_status = pDescripcionstatus,
					cat_ultima_mod_fecha = cultima_mod_fecha, 
					cat_usuario_mod_id_fk = pUsuario 
					WHERE cat_cod_status = pCodigoStatus AND cat_id_status = pIdStatus;
				
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00283';
						RETURN cCodRet;
					END IF;
			
				ELSE
					LET cCodRet = '99999';
					RETURN cCodRet;
				END IF;
			END IF;
		END IF;
		
		IF pBandera = 3 THEN
			LET caccion = 'ELIMINA PARAMETROS ESTATUS';
			
			LET cCmd1 ="";	
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'cat_id_status', 'cat_cod_status', 'cat_descripcion_status', 'cat_alta_fecha', 'cat_ultima_mod_fecha', 'cat_usuario_alta_id_fk', 'cat_usuario_mod_id_fk'";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT cat_id_status, cat_cod_status, cat_descripcion_status, cat_alta_fecha::VARCHAR(10), cat_ultima_mod_fecha::VARCHAR(10), cat_usuario_alta_id_fk::VARCHAR(11), cat_usuario_mod_id_fk::VARCHAR(11)";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".cat_status WHERE cat_cod_status = '"||pCodigoStatus||"' AND cat_id_status = '"||pIdStatus||"')";
			
			EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
			IF cCodRet = '00000' THEN 
				EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, cIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
				DELETE FROM bdirst:"informix".cat_status WHERE cat_cod_status = pCodigoStatus AND cat_id_status = pIdStatus;
				
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00862';
					RETURN cCodRet;
				END IF;
			ELSE
				LET cCodRet = '99999';
				RETURN cCodRet;
			END IF;
			
		END IF;
		
		RETURN cCodRet;
	END

END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 22/12/2020',
'MODULO: ADMINISTRACIÃÂN DE ATM',
'FUNCIONALIDAD: Parametros Status',
'DESCRIPCION: SP para el alta, actualizaciÃÂ³n y eliminacion de un parametros estatus',
'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 19/01/2021',
'DESCRIPCION: Se realiza ajuste a procedimiento para realizar la insercion de valor vacÃÂ­o sobre campo cat_cod_status.',
'BD: bdirst';

CREATE PROCEDURE "informix".sp_canal_cobro( pUsuario CHAR(8), pIdFuncion CHAR(10), pIp CHAR(20) )
	RETURNING 
		CHAR(5) AS codret,
		CHAR(2) AS idCanalFinal,
		CHAR(30) AS cveCanalFinal,
		CHAR(30) AS nombreCanal,
		CHAR(1) AS cobrarOtp;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cIdCanalFinal CHAR(2);
	DEFINE cCveCanalFinal CHAR(30);
	DEFINE cNombreCanal CHAR(30);
	DEFINE cCobrarOtp CHAR(1);
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE crespaldo CHAR(50);
	
	LET cIdCanalFinal = '';
	LET cCveCanalFinal = '';
	LET cNombreCanal = '';
	LET cCobrarOtp = '';
	LET cAccion = 'CONSULTA CANAL DE COBRO';
	LET cEntidad = 'par_canal_final';
	LET crespaldo = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cIdCanalFinal, cCveCanalFinal,cNombreCanal, cCobrarOtp;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_canal_cobro.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cIdCanalFinal, cCveCanalFinal,cNombreCanal, cCobrarOtp;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cIdCanalFinal, cCveCanalFinal,cNombreCanal, cCobrarOtp;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, NULL, pUsuario, 1) INTO cCodRet;
		
		IF cCodRet = '00000' THEN
			FOREACH
		
				SELECT par_id_canal_final, par_cve_canal_final, par_nombre_canal, par_cobrar_otp
				INTO cIdCanalFinal, cCveCanalFinal, cNombreCanal, cCobrarOtp
				FROM bdirst: "informix".par_canal_final where par_cobrar_otp ='V'
			
				RETURN cCodRet,cIdCanalFinal, cCveCanalFinal,cNombreCanal, cCobrarOtp WITH RESUME;
			END FOREACH;
		END IF;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cIdCanalFinal, cCveCanalFinal,cNombreCanal, cCobrarOtp;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 24/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: Canal de Cobro',
'DESCRIPCION: SPL encargado de consultar informaciÃ³n en tabla par_canal_final',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_canal_cobro_totales( pUsuario CHAR(8), pIdFuncion CHAR(10) )
	RETURNING 
		CHAR(5) AS codret,
		CHAR(2) AS totales;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
		
	DEFINE iTotales INTEGER;
	
	LET iTotales = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iTotales;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_canal_cobro_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotales;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotales;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*) 
		INTO iTotales 
		FROM bdirst: "informix".par_canal_final where par_cobrar_otp ='V';
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iTotales;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 22/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: Canal de Cobro',
'DESCRIPCION: SPL encargado de devolver el total de registros de la consulta canal de cobro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_canal_generacion( pUsuario CHAR(8), pIdFuncion CHAR(10), pIp CHAR(20) )
	RETURNING 
		CHAR(5) AS codret,
		CHAR(2) AS idCanalInicial,
		CHAR(30) AS cveCanalInicial,
		CHAR(30) AS nombreCanal;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	
	DEFINE cIdCanalInicial CHAR(2);
	DEFINE cCveCanalInicial CHAR(30);
	DEFINE cNombreCanal CHAR(30);
	
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE cIp CHAR(20);
	DEFINE crespaldo CHAR(50);
	LET cIdCanalInicial = '';
	LET cCveCanalInicial = '';
	LET cNombreCanal = '';
	
	LET cAccion = 'CONSULTA CANAL DE GENERACION';
	LET cEntidad = 'par_canal_inicial';
	LET cIp = pIp;
	LET crespaldo = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cIdCanalInicial, cCveCanalInicial,cNombreCanal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_canal_generacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdCanalInicial, cCveCanalInicial,cNombreCanal;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdCanalInicial, cCveCanalInicial,cNombreCanal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, NULL, pUsuario, 1) INTO cCodRet;
		
		IF cCodRet = '00000' THEN 
			FOREACH
				SELECT par_id_canal_inicial, par_cve_canal_inicial, par_nombre_canal 
				INTO cIdCanalInicial, cCveCanalInicial, cNombreCanal
				FROM bdirst: "informix".par_canal_inicial where par_generar_otp ='V'
				
				RETURN cCodRet, cIdCanalInicial, cCveCanalInicial,cNombreCanal WITH RESUME;
			END FOREACH;
		END IF;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdCanalInicial, cCveCanalInicial,cNombreCanal;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 24/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: Canal de GeneraciÃ³n',
'DESCRIPCION: SPL encargado de consultar informaciÃ³n en tabla par_canal_inicial',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_canal_generacion_totales( pUsuario CHAR(8), pIdFuncion CHAR(10) )
	RETURNING 
		CHAR(5) AS codret,
		CHAR(2) AS totales;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
		
	DEFINE iTotales INTEGER;
	
	LET iTotales = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iTotales;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_canal_generacion_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotales;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotales;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*) 
		INTO iTotales 
		FROM bdirst: "informix".par_canal_inicial where par_generar_otp ='V';
		
		IF NVL(iTotales,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iTotales;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 22/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: Canal de Generacion',
'DESCRIPCION: SPL encargado de obtener el total de registros sobre la tabla par_canal_inicial',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_modifica_parametros_retiros( pUsuario CHAR(8), pIdFuncion CHAR(10), pMonto_minimo VARCHAR(100), pMonto_maximo VARCHAR(100), pCodigo_activo VARCHAR(100), pVigencia VARCHAR(100), pip VARCHAR(20))
	RETURNING 
		CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;	
	DEFINE iExiste INTEGER;
	
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE cip CHAR(20);
	DEFINE crespaldo CHAR(50);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cArchivoRespaldo CHAR(50);
	
	LET iExiste = 0;
	LET cAccion = '';
	LET cEntidad = 'parametro_sistema';
	LET cip = pip;
	LET crespaldo = '';
	LET cCmd1 = '';
	LET cArchivoRespaldo = 'ParamRet_'||pUsuario||TO_CHAR(CURRENT, '%d%m%Y');
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/calizarraga/sp_modifica_parametros_retiros.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pip = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pMonto_minimo <> '' THEN
			SELECT COUNT(par_id) INTO iExiste FROM bdirst:"informix".parametro_sistema WHERE par_status = 'A' AND par_nombre = 'MONTO_MINIMO';
			
			IF NVL(iexiste,0) > 0 THEN
				LET cAccion = 'MODIFICA MONTO MINIMO';
				
				LET cCmd1 ="";	
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'par_id', 'par_alta_fecha', 'par_ultima_mod_fecha', 'par_status', 'par_nombre', 'par_valor', 'par_descripcion', 'par_usuario_alta_id_fk', 'par_usuario_mod_id_fk'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT par_id::VARCHAR(10), par_alta_fecha::VARCHAR(10), par_ultima_mod_fecha::VARCHAR(10), par_status, par_nombre, par_valor, par_descripcion, par_usuario_alta_id_fk::VARCHAR(10), par_usuario_mod_id_fk::VARCHAR(10)";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".parametro_sistema WHERE par_status = 'A' and par_nombre = 'MONTO_MINIMO')";
				
				EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
				IF cCodRet = '00000' THEN 
					EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, cIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
					
					UPDATE bdirst:"informix".parametro_sistema 
					SET par_valor = pMonto_minimo 
					WHERE par_nombre = 'MONTO_MINIMO' AND par_status = 'A';
					
				ELSE
					LET cCodRet = '99999';
					RETURN cCodRet;
				END IF; 
			ELSE
				-- SE AGREGA EL REGISTRO SI ES QUE NO EXISTE Y HAY VALOR DEL MONTO MINIMO --
				INSERT INTO bdirst:"informix".parametro_sistema(par_alta_fecha, par_status, par_nombre, par_valor, 
				par_descripcion, par_usuario_alta_id_fk) 
				VALUES( CURRENT, 'A', 'MONTO_MINIMO', pMonto_minimo, 'MONTO MINIMO', pUsuario);
			END IF;
			
		END IF;
		
		IF pMonto_maximo <> '' THEN
			SELECT COUNT(par_id) INTO iExiste FROM bdirst: "informix".parametro_sistema WHERE par_status = 'A' AND par_nombre = 'MONTO_MAXIMO';
			
			IF NVL(iexiste,0) > 0 THEN
				LET cAccion = 'MODIFICA MONTO MAXIMO';
				
				LET cCmd1 ="";	
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'par_id', 'par_alta_fecha', 'par_ultima_mod_fecha', 'par_status', 'par_nombre', 'par_valor', 'par_descripcion', 'par_usuario_alta_id_fk', 'par_usuario_mod_id_fk'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT par_id::VARCHAR(10), par_alta_fecha::VARCHAR(10), par_ultima_mod_fecha::VARCHAR(10), par_status, par_nombre, par_valor, par_descripcion, par_usuario_alta_id_fk::VARCHAR(10), par_usuario_mod_id_fk::VARCHAR(10)";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".parametro_sistema WHERE par_status = 'A' and par_nombre = 'MONTO_MAXIMO')";
				
				EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
				IF cCodRet = '00000' THEN 
					EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, cIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
					
					UPDATE bdirst:"informix".parametro_sistema 
					SET par_valor = pMonto_maximo 
					WHERE par_nombre = 'MONTO_MAXIMO' AND par_status = 'A';
					
				ELSE
					LET cCodRet = '99999';
					RETURN cCodRet;
				END IF;

			ELSE
				-- SE AGREGA EL REGISTRO SI ES QUE NO EXISTE Y HAY VALOR DEL MONTO MAXIMO --
				INSERT INTO bdirst:"informix".parametro_sistema(par_alta_fecha, par_status, par_nombre, par_valor, 
				par_descripcion, par_usuario_alta_id_fk) 
				VALUES( CURRENT, 'A', 'MONTO_MAXIMO', pMonto_maximo, 'MONTO MAXIMO', pUsuario);
				
			END IF;
		END IF;
		
		IF pCodigo_activo <> '' THEN
			SELECT COUNT(par_id) INTO iExiste FROM bdirst: "informix".parametro_sistema WHERE par_status = 'A' AND par_nombre = 'CODIGOS_ACTIVOS';
			
			IF NVL(iexiste,0) > 0 THEN
				LET caccion = 'MODIFICA CODIGOS ACTIVOS';
				
				LET cCmd1 ="";	
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'par_id', 'par_alta_fecha', 'par_ultima_mod_fecha', 'par_status', 'par_nombre', 'par_valor', 'par_descripcion', 'par_usuario_alta_id_fk', 'par_usuario_mod_id_fk'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT par_id::VARCHAR(10), par_alta_fecha::VARCHAR(10), par_ultima_mod_fecha::VARCHAR(10), par_status, par_nombre, par_valor, par_descripcion, par_usuario_alta_id_fk::VARCHAR(10), par_usuario_mod_id_fk::VARCHAR(10)";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".parametro_sistema WHERE par_status = 'A' and par_nombre = 'CODIGOS_ACTIVOS')";
				
				EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
				IF cCodRet = '00000' THEN 
					EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, cIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
					
					UPDATE bdirst:"informix".parametro_sistema 
					SET par_valor = pCodigo_activo 
					WHERE par_nombre = 'CODIGOS_ACTIVOS' AND par_status = 'A';
					
				ELSE
					LET cCodRet = '99999';
					RETURN cCodRet;
				END IF;
				
			ELSE
				-- SE AGREGA EL REGISTRO SI ES QUE NO EXISTE Y HAY VALOR DEL CODIGOS ACTIVOS --
				
				INSERT INTO bdirst:"informix".parametro_sistema(par_alta_fecha, par_status, par_nombre, par_valor, 
				par_descripcion, par_usuario_alta_id_fk) 
				VALUES( CURRENT, 'A', 'CODIGOS_ACTIVOS', pCodigo_activo, 'CODIGOS ACTIVOS', pUsuario);
				
			END IF;
		END IF;
		
		IF pVigencia <> '' THEN
			SELECT COUNT(par_id) INTO iExiste FROM bdirst: "informix".parametro_sistema WHERE par_status = 'A' AND par_nombre = 'VIGENCIA';
			
			IF NVL(iexiste,0) > 0 THEN
				LET caccion = 'MODIFICA VIGENCIA';
				
				LET cCmd1 ="";	
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'par_id', 'par_alta_fecha', 'par_ultima_mod_fecha', 'par_status', 'par_nombre', 'par_valor', 'par_descripcion', 'par_usuario_alta_id_fk', 'par_usuario_mod_id_fk'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT par_id::VARCHAR(10), par_alta_fecha::VARCHAR(10), par_ultima_mod_fecha::VARCHAR(10), par_status, par_nombre, par_valor, par_descripcion, par_usuario_alta_id_fk::VARCHAR(10), par_usuario_mod_id_fk::VARCHAR(10)";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".parametro_sistema WHERE par_status = 'A' and par_nombre = 'VIGENCIA')";
				
				EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
				IF cCodRet = '00000' THEN 
					EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, cIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
					
					UPDATE bdirst:"informix".parametro_sistema 
					SET par_valor = pVigencia 
					WHERE par_nombre = 'VIGENCIA' AND par_status = 'A';
					
				ELSE
					LET cCodRet = '99999';
					RETURN cCodRet;
				END IF;
				
			ELSE
				-- SE AGREGA EL REGISTRO SI ES QUE NO EXISTE Y HAY VALOR DEL VIGENCIA --
				
				INSERT INTO bdirst:"informix".parametro_sistema(par_alta_fecha, par_status, par_nombre, par_valor, par_descripcion, par_usuario_alta_id_fk) 
				VALUES( CURRENT, 'A', 'VIGENCIA', pVigencia, 'VIGENCIA', pUsuario);
				
			END IF;
		END IF;
		
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 15/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: Retiro sin Tarjeta',
'DESCRIPCION: SPL encargado de actualizar los parameros retiro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_actualizainsertaprodtransaccion(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1),
		pCccmayor CHAR(10), pCccsub CHAR(10), pCccsubsub CHAR(10), pCccsssub CHAR(10), pCccssssub CHAR(10), pCsector CHAR(10), 
		pAccmayor CHAR(10),	pAccsub CHAR(10), pAccsubsub CHAR(10), pAccsssub CHAR(10), pAccssssub CHAR(10), pAsector CHAR(10),
		pSistema CHAR(10), pSecuencia CHAR(10), pTransaccion CHAR(10), pProducto CHAR(10))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iTotales INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iTotales = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		SET DEBUG FILE TO '/tmp/mfinis/sp_ris_actualizainsertaprodtransaccion.out';
		TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' OR pCccmayor = '' OR pCccsub = '' OR pCccsubsub = '' OR pCccsssub = '' OR pCccssssub = '' OR pCsector = '' OR 
		pAccmayor = '' OR pAccsub = '' OR  pAccsubsub = '' OR pAccsssub = '' OR pAccssssub = '' OR  pAsector = '' OR pSistema = '' OR pSecuencia = '' OR pTransaccion = '' OR pProducto  = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		IF pBandera = '1' THEN

			UPDATE bdinteg:"informix".si_prodtran SET
			c_ccmayor = pCccmayor,
			c_ccsub = pCccsub,
			c_ccsubsub = pCccsubsub,
			c_ccsssub = pCccsssub,
			c_ccssssub = pCccssssub,
			c_sector = pCsector,
			a_ccmayor = pAccmayor,
			a_ccsub = pAccsub,
			a_ccsubsub = pAccsubsub,
			a_ccsssub = pAccsssub,
			a_ccssssub = pAccssssub,
			a_sector = pAsector
			WHERE empresa = cEmpresa
			AND sistema = pSistema
			AND producto = pProducto
			AND transaccion = pTransaccion
			AND secuencia = pSecuencia;
		
		ELIF pBandera = '2' THEN
		
			DELETE FROM bdinteg:"informix".si_prodtran 
			WHERE empresa = cEmpresa
			AND sistema = pSistema
			AND producto = pProducto
			AND transaccion = pTransaccion
			AND secuencia = pSecuencia;
			
		ELIF pBandera = '3' THEN
		
			INSERT INTO bdinteg:"informix".si_prodtran (empresa,  producto,  sistema,  transaccion,  secuencia,  c_ccmayor,  c_ccsub, c_ccsubsub,  c_ccsssub,  c_ccssssub,  c_sector, a_ccmayor,  a_ccsub,  a_ccsubsub, a_ccsssub,  a_ccssssub,  a_sector, user_insert, fecha_insert)
			VALUES (cEmpresa, pProducto, pSistema, pTransaccion, pSecuencia, pCccmayor, pCccsub, pCccsubsub, pCccsssub, pCccssssub, pCsector,  pAccmayor,	pAccsub, pAccsubsub, pAccsssub, pAccssssub, pAsector, pUsuario, CURRENT);
		
		ELSE 
		
			SELECT COUNT(*) 
			INTO iTotales
			FROM bdinteg:"informix".si_prodtran
            WHERE empresa = cEmpresa
			AND sistema = pSistema
			AND producto = pProducto
			AND transaccion = pTransaccion
			AND secuencia = pSecuencia;
			
			IF iTotales > 0 THEN
		
				LET cCodRet = '99999';
		
			END IF
		END IF;
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Insertar, Actualizar y eliminar una transacciÃ³n',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusgenrepsistema(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(150) AS nombre_archivo,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cNombreArchivo CHAR(150);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET cNombreArchivo = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,cNombreArchivo,cErrorProceso,cError;	
		END EXCEPTION;
	 
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusgenrepsistema.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cNombreArchivo,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cNombreArchivo,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status, nombre_archivo, error_proceso, error
		INTO cStatus, cNombreArchivo, cErrorProceso, cError
		FROM "informix".sw_verificastatusrepxsist WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet, 'I', '', '', ''; 
		ELSE 			
			RETURN cCodRet, cStatus, cNombreArchivo, cErrorProceso, cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 15/01/2021',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado verificar el status de la generacion del reporte.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_consultatransacciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistema CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(4) AS numero,
			CHAR(50) AS descripcion,
			CHAR(15) AS naturaleza;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumero CHAR(4);
	DEFINE cDescripcion CHAR(50);
	DEFINE cNaturaleza CHAR(15);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cNumero = '';
	LET cDescripcion = '';
	LET cNaturaleza = '';
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumero, cDescripcion, cNaturaleza;
		END EXCEPTION;
		
		SET DEBUG FILE TO '/tmp/mfinis/sp_ris_consultatransacciones.out';
		TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistema = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumero, cDescripcion, cNaturaleza;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumero, cDescripcion, cNaturaleza;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumero, cDescripcion, cNaturaleza;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion 
			numero, descripcion, NVL(DECODE(naturaleza, 'A','ABONO','C','CARGO','R','REFERENCIAL'), 'ABONO') naturaleza 
			INTO cNumero, cDescripcion, cNaturaleza
			FROM bdinteg:"informix".si_transacc
			WHERE empresa = cEmpresa 
			AND sistema = pSistema 
			ORDER BY numero ASC

			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cNumero, cDescripcion, cNaturaleza WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cNumero, cDescripcion, cNaturaleza;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNumero, cDescripcion, cNaturaleza;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar los las Transacciones por sistema',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_consultatransaccion(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistema CHAR(10), pSecuencia CHAR(10), pTransaccion CHAR(10), pProducto CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(3) AS sistema, 
			CHAR(4) AS producto, 
			CHAR(4) AS transaccion,
			CHAR(50) AS descTran,
			CHAR(1) AS naturaleza,
			INTEGER AS secuencia, 
			CHAR(10) AS c_ccmayor, 
			CHAR(10) AS c_ccsub, 
			CHAR(10) AS c_ccsubsub, 
			CHAR(10) AS c_ccsssub, 
			CHAR(10) AS c_ccssssub, 
			CHAR(10) AS c_sector, 
			CHAR(10) AS a_ccmayor, 
			CHAR(10) AS a_ccsub, 
			CHAR(10) AS a_ccsubsub, 
			CHAR(10) AS a_ccsssub, 
			CHAR(10) AS a_ccssssub, 
			CHAR(10) AS a_sector;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	--DEFINE iNoRegistros INTEGER;
	--DEFINE iRegistros INTEGER;
	--DEFINE iRecuperacion INTEGER;
	DEFINE cSistema CHAR(3);
	DEFINE cProducto CHAR(4);
	DEFINE cTransaccion CHAR(4);
	DEFINE cDescTran CHAR(50);
	DEFINE cNaturaleza CHAR(1);
	DEFINE iSecuencia INTEGER;
	DEFINE cCccmayor CHAR(10);
	DEFINE cCccsub CHAR(10);
	DEFINE cCccsubsub CHAR(10);
	DEFINE cCccsssub CHAR(10);
	DEFINE cCccssssub CHAR(10);
	DEFINE cCsector CHAR(10);
	DEFINE cAccmayor CHAR(10);
	DEFINE cAccsub CHAR(10);
	DEFINE cAccsubsub CHAR(10);
	DEFINE cAccsssub CHAR(10);
	DEFINE cAccssssub CHAR(10); 
	DEFINE cAsector CHAR(10);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	--LET iNoRegistros = 0;
	--LET iRegistros = 0;
	--LET iRecuperacion = 0;
	LET cSistema = '';
	LET cProducto = '';
	LET cTransaccion = '';
	LET cDescTran = '';
	LET cNaturaleza = '';
	LET iSecuencia = 0;
	LET cCccmayor = '';
	LET cCccsub = '';
	LET cCccsubsub = '';
	LET cCccsssub = '';
	LET cCccssssub = '';
	LET cCsector = '';
	LET cAccmayor = '';
	LET cAccsub = '';
	LET cAccsubsub = '';
	LET cAccsssub = '';
	LET cAccssssub = '';
	LET cAsector = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cSistema, cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector;
		END EXCEPTION;
		
		SET DEBUG FILE TO '/tmp/mfinis/sp_ris_consultatransaccion.out';
		TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistema = '' OR pSecuencia = '' OR pTransaccion = '' OR pProducto = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSistema, cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSistema, cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT a.sistema, a.producto, transaccion, TRIM(c.descripcion)trandesc, NVL(DECODE(naturaleza, 'A','ABONO','C','CARGO','R','REFERENCIAL'), 'ABONO') naturaleza, 
		secuencia, c_ccmayor, c_ccsub, c_ccsubsub, c_ccsssub, c_ccssssub, c_sector, a_ccmayor, a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, a_sector
		INTO cSistema, cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector
		FROM bdinteg:"informix".si_prodtran a, bdinteg:"informix".si_transacc c 
		WHERE c.empresa = a.empresa 
		AND c.numero = a.transaccion 
		AND c.sistema = a.sistema 
		AND a.secuencia = pSecuencia
		AND a.transaccion = pTransaccion
		AND a.producto = pProducto 
		AND a.sistema = pSistema
		AND a.empresa = cEmpresa;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, cSistema, cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar una Transaccion',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_consultaprodtransaccion(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistema CHAR(10), pSecuencia CHAR(10), pTransaccion CHAR(10), pProducto CHAR(10))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iTotales INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iTotales = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--DEBUG FILE TO '/tmp/mfinis/sp_ris_consultaprodtransaccion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistema = '' OR pSecuencia = '' OR pTransaccion = '' OR pProducto  = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		

		SELECT COUNT(*) 
		INTO iTotales
		FROM bdinteg:"informix".si_prodtran
        WHERE empresa = cEmpresa
		AND sistema = pSistema
		AND producto = pProducto
		AND transaccion = pTransaccion
		AND secuencia = pSecuencia;
			
		IF iTotales > 0 THEN
			LET cCodRet = '99999';
		END IF;
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃÂ¡nchez',
'FECHA: 25/02/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar una transacciÃÂ³n',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_consultanombrecatalogo(pUsuario CHAR(8), pIdFuncion CHAR(10), pCcmayor CHAR(10), pCcsub CHAR(10), pCcsubsub CHAR(10), pCcssubsub CHAR(10), pCcsssubsub CHAR(10), pSector CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(50) AS nombre;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNombre CHAR(50);
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNombre = '';
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombre;
		END EXCEPTION;
		
		SET DEBUG FILE TO '/tmp/mfinis/sp_ris_consultanombrecatalogo.out';
		TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCcmayor = '' OR pCcsub = '' OR pCcsubsub = '' OR pCcssubsub = '' OR pCcsssubsub = '' OR pSector = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombre;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombre;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT NVL(TRIM(nombre), 'CTA CONTABLE NO EXISTE')
		INTO cNombre 
		FROM bdinteg:si_catalog
        WHERE empresa = cEmpresa
        AND ccmayor = pCcmayor
        AND ccsub = pCcsub
        AND ccsubsub = pCcsubsub
        AND ccssubsub = pCcssubsub
        AND ccsssubsub = pCcsssubsub
        AND sector = pSector;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, cNombre;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar EL CATALOGO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_generarepentradasalidacaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSucursal CHAR(1), pRutaDescarga CHAR(100))
		 RETURNING CHAR(5) AS codret,
			CHAR(100) AS reporte_xls;		
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;
	
	DEFINE cQuery CHAR(255);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE cNombreRepXls CHAR(100);
	DEFINE cNombreRepTxt CHAR(45);
	DEFINE cRutaGralXls CHAR(150);
	DEFINE cRutaGralTxt CHAR(150);
	DEFINE cTpoSuc CHAR(10);
	DEFINE cNombreReporteHist CHAR(100);
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO MINUTE;
	DEFINE dHoy DATE;
	DEFINE cStr7 CHAR(50);
	DEFINE cStr9 CHAR(50);
	DEFINE cIdPlantilla CHAR(5);
	--DEFINE ven_transacc SMALLINT;
	--DEFINE bInTransaction BOOLEAN;
		
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;

	LET cQuery = '';
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cRutaInformix = '/ifxsif01/bin/';
	LET cUsrBin = '/usr/bin/';
	LET cNombreRepXls = '';
	LET cNombreRepTxt = '';
	LET cRutaGralXls = '';
	LET cRutaGralTxt = '';
	LET cTpoSuc = '';
	LET cNombreReporteHist = '';
	LET dFechaHoy = '';
	LET dFechaHoy = '';
	LET dHoraHoy = '';
	LET cIdPlantilla = '';
	--LET bInTransaction = 'f';
	--LET ven_transacc = 0;

		BEGIN
		
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				--IF ven_transacc = 1 THEN
					--ROLLBACK ;		
				--END IF;
				RETURN cCodRet,cNombreRepXls;
			END EXCEPTION;
		
			ON EXCEPTION IN (-668)			
				
			END EXCEPTION WITH RESUME;
			
			--SET DEBUG FILE TO '/tmp/mfinis/sp_generarepentradasalidacaja.out';
			--TRACE ON;
		
			IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet,cNombreRepXls;
			END IF;
		
			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet,cNombreRepXls;
			END IF;
			
			--BEGIN;
			--IF bInTransaction = 'f' THEN
				--COMMIT;
			--END IF;
			
			-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR		
			LET cNombreRepXls = 'ENTRADASSALIDAS_'||pUsuario||"_"||TO_CHAR(CURRENT, '%d%m%Y')||'.xls';
			LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
			LET cRutaGralXls = TRIM(pRutaDescarga)||TRIM(cNombreRepXls);

			LET dFechaHoy = CURRENT;
			LET dHoraHoy = CURRENT;	
			
			-- SE ELIMINAN TODOS LOS REGISTROS GENERADOS MENORES A LA FECHA HOY (T-1)
			FOREACH
			
				SELECT {+INDEX (bdicnweb:sw_ctrlgenreportesentradasalida idx_sw_ctrlgenreportesentradasalida)} nombre_reporte
				INTO cNombreReporteHist
				FROM bdicnweb:"informix".sw_ctrlgenreportesentradasalida 
				WHERE usuario_insert = pUsuario
				AND fecha_reporte < dFechaHoy
				
				LET cSql = '';
				LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||TRIM(cNombreReporteHist);
				SYSTEM TRIM(cSql);
				
				DELETE {+INDEX (bdicnweb:sw_ctrlgenreportesentradasalida idx_sw_ctrlgenreportesentradasalida)} FROM  bdicnweb:"informix".sw_ctrlgenreportesentradasalida WHERE nombre_reporte = TRIM(cNombreReporteHist);
				
			END FOREACH;
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;  
			
			LET cCmd1 ="";
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'TIPO', 'DIA SOLICITUD', 'DIA ENVIO', 'DIA RECEPCION', 'PLAZA', 'SUCURSAL', 'CAJA GENERAL', 'MONTO', 'STATUS', 'FOLIO SUCURSAL', 'FOLIO OPERACION', 'USUARIO SOLICITO', 'USUARIO ENVIO', 'USUARIO RECIBIO', 'DIA REVISION', 'USUARIO REVERSO'";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT CASE WHEN tipo_suc = 'S' THEN 'SUCURSAL' WHEN tipo_suc = 'C' THEN 'ATM' END , TO_CHAR(fecsol, '%d/%m/%Y'), TO_CHAR(fecenvio, '%d/%m/%Y'), TO_CHAR(fecrecepcion, '%d/%m/%Y'), nomplaza::CHAR(50), ''''||sucursal::CHAR(50), codproveedor::CHAR(50), monto::CHAR(50), desstatus::CHAR(50), ''''||folsuc::CHAR(50), ''''||foloper::CHAR(50), ''''||usuariosol::CHAR(50), ''''||usuarioenv::CHAR(50), ''''||usuariorecep::CHAR(50), TO_CHAR(fecrever, '%d/%m/%Y'), ''''||vusuariorever::CHAR(50)";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".tmp_entradasalida ";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE id_usuario = '"|| pUsuario ||"' ORDER BY id_registro ASC)";
			
			--GENERACION DE ARCHIVO XLS
			LET cSql = '';
			LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGralXls)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de linea
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGralXls);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGralXls)||" > "||TRIM(cRutaGralXls)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo original
			LET cSql = '';
			LET cSql = "rm -rf "||TRIM(cRutaGralXls);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGralXls)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el caracter delimitador ';' al final de la linea
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGralXls)||".tmp > "||TRIM(cRutaGralXls);
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de linea
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGralXls);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGralXls)||" > "||TRIM(cRutaGralXls)||".tmp";
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGralXls)||".tmp";
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGralXls)||'; /usr/bin/mv '||TRIM(cRutaGralXls)||'.tmp '||TRIM(cRutaGralXls);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGralXls);
			SYSTEM TRIM(cSql);
			
			DELETE {+INDEX (bdicnweb:sw_ctrlgenreportesentradasalida idx_sw_ctrlgenreportesentradasalida)} FROM   bdicnweb:"informix".sw_ctrlgenreportesentradasalida WHERE nombre_reporte = TRIM(cNombreRepXls);
			
			INSERT INTO bdicnweb:"informix".sw_ctrlgenreportesentradasalida(nombre_reporte,fecha_reporte,hr_reporte,usuario_insert)
			VALUES(TRIM(cNombreRepXls),dFechaHoy,dHoraHoy,pUsuario);
		
			/*
			-- NOTIFICACIÃN VÃA CORREO ELECTRÃNICO EXITOSO
			LET cStr7 = 'GENERACIÃN DEL ARCHIVO XLS';
			LET cStr9 = 'CAJA GENERAL';
			LET dHoy = CURRENT;
			
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(
			'1', 
			TRIM(cIdPlantilla),
			TRIM(cIdPlantilla), 
			pUsuario, 
			'',
			'', 
			'1', 
			'',
			'',
			'',
			'',
			'',
			TRIM(pTituloPlantilla),
			TRIM(cStr7),
			'',
			TRIM(cStr9),
			'',
			'',
			'',
			'0',
			'0',
			'0',
			'0',
			'0',
			dHoy,
			dHoy) INTO cCodRetSp;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdimnsj:sp_registra_evento';
			ELIF iCodRetSp > 0 THEN
				LET cCodRet = '01018'; --OCURRIO UN ERROR EN LA EJECUCIÃN DEL SP bdimnsj:"informix".sp_registra_evento, VERIFIQUE
			END IF;
			*/
			
			--LET ven_transacc = 0;
			--IF bInTransaction = 't' THEN
				--BEGIN;
			--END IF;
		
			RETURN cCodRet,cNombreRepXls;
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 05/02/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: ENTRADAS SALIDAS DE CAJA GENERAL',
'DESCRIPCION: SPL que genera el reporte de Entrada Salida Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreportexlsdepositoscoppel(pUsuario CHAR(8), pIdFuncion CHAR(10), pRutaDescarga CHAR(100))
    RETURNING CHAR(5) AS codret,
				CHAR(50) AS nombreArchivo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreReporte CHAR(100);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;

	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaInformix = '/ifxsif01/bin/';
	LET cRutaGral = '';
	LET cNombreReporte = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;

	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;	
			RETURN cCodRet, cNombreReporte;
		END EXCEPTION;
			
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genreportexlsdepositoscoppel.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' THEN	
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreReporte;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreReporte;
		END IF;	
		
		-- SE ASIGNAN VALORES PARA LA GENERACION DEL REPORTE
		LET cNombreReporte = 'DepositosCoppelProcesados_'||TO_CHAR(CURRENT,'%Y%m%d%H%M%S')||'.xls';		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		LET cCmd1 ="";
		LET cCmd1 = "SELECT 'FOLIO','FECHA','FOLIO COMPROBANTE','NO. SUC / ATM','NO. CAJA GENERAL','PLAZA','IMPORTE COMPROBANTE','IMPORTE FICHA(S)','BILLETE \$1000',";
		LET cCmd1 =""||TRIM(cCmd1)||"'BILLETE \$500','BILLETE \$200','BILLETE \$100','BILLETE \$50', 'BILLETE \$20', 'MORRALLA','FALTANTE','SOBRANTE', 'ESTATUS' FROM systables WHERE tabid = 1";
		LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT folio_oper, NVL(TO_CHAR(fecha, '%d/%m/%Y'), ''), comprobante, suc_coppel, caja_general, plaza, imp_comprobante::CHAR(21), ";
		LET cCmd1 =""||TRIM(cCmd1)||" imp_ficha::CHAR(21), cantidad_1::CHAR(11), cantidad_2::CHAR(11), cantidad_3::CHAR(11), cantidad_4::CHAR(11), cantidad_5::CHAR(11), ";
		LET cCmd1 =""||TRIM(cCmd1)||" cantidad_6::CHAR(11), cantidad_7::CHAR(11), faltante::CHAR(21), sobrante::CHAR(21), estatus FROM bdisuc:""informix"".ss_temp_deposito_coppel";
			
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreReporte);
			
		LET cSql = '';
		LET cSql = '/usr/bin/echo "UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER ''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'depcoppel.sql';
		SYSTEM TRIM(cSql);
			
		LET cSql = '';
		LET cSql = TRIM(cRutaInformix)||'dbaccess bdicnweb '||TRIM(pRutaDescarga)||'depcoppel.sql';
		SYSTEM TRIM(cSql);
			
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'depcoppel.sql';
		SYSTEM TRIM(cSql);
		
		--DELETE FROM bdisuc:"informix".ss_temp_deposito_coppel;
		
		RETURN cCodRet, cNombreReporte;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 12/09/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: DEPOSITOS COPPEL',
'DESCRIPCION: SPL encargado de generar el reporte de la carga de archivos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusexpedientes(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusexpedientes.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM bdicnweb:"informix".sw_verificastatusexpediente WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/05/2021',
'MODULO: ',
'FUNCIONALIDAD: VERIFICA EL ESTATUS DEL PROCESO ',
'DESCRIPCION: ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_cuentadoctos(pUsuario CHAR(8),pIdFuncion CHAR(10),pNumCte CHAR(20),pTipoCte SMALLINT)
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE iIsamErrorSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cValor CHAR(100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET iIsamErrorSp = 0;
	LET cEmpresa = '001';
	LET cValor = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_cuentadoctos.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cuentadoctos_soc(pNumCte,pTipoCte) 
		INTO cCodRetSp,iIsamErrorSp,cDescCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_cuentadoctos_soc';
		ELIF iCodRetSp = 99999 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 100 THEN
			LET cCodRet = '01163'; --EL CLIENTE [CLIENTE 1] ES UN CLIENTE MORAL
		ELIF iCodRetSp = 200 THEN
			LET cCodRet = '01164'; --CLIENTE [CLIENTE 1] CON ADEUDO IDE, NO SE PUEDE EFECTUAR LA FUSIÓN
		ELIF iCodRetSp = 300 THEN
			LET cCodRet = '01165'; --CLIENTE [CLIENTE 1] CON BANCA ELECTRÓNICA AVANZADA, NO SE PUEDE EFECTUAR LA FUSIÓN
		ELIF iCodRetSp = 400 THEN
			LET cCodRet = '01166'; --CLIENTE [CLIENTE 1] FUSIONADO, NO SE PUEDE EFECTUAR LA FUSIÓN
		ELIF iCodRetSp = 500 THEN
			LET cCodRet = '01167'; --EXISTEN PROBLEMAS CON EL EXPEDIENTE DEL CLIENTE. FAVOR DE AVISAR A SISTEMAS
		ELIF iCodRetSp <> 0 THEN
			LET cCodRet = '01168'; --ERROR, FAVOR DE AVISAR A SISTEMAS
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de realizar la validacion de imagen de los clientes a fusionar.',
'BD: bdicnweb',
'MODIFICÓ: Daniel Reyes Guillen 13-05-2021 Se descomenta línea de error 200';

CREATE PROCEDURE "informix".sp_ris_consultaproductos(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistema CHAR(2))
		RETURNING CHAR(5) AS codret,
				CHAR(10) AS codigo,
				CHAR(100) AS descProd;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iInicioReg INTEGER;
	DEFINE iTamReg INTEGER;
	DEFINE iPosCaracter INTEGER;
	DEFINE iPosCaracter2 INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cTabla CHAR(50);
	DEFINE cDato2 CHAR(50);
	DEFINE cCampo1 CHAR(50);
	DEFINE cCampo2 CHAR(50);
	DEFINE cBase CHAR(50);
	DEFINE cDescripcion CHAR(100);
	DEFINE cUsrBin CHAR(15);
	DEFINE cIfxBin CHAR(15);
	DEFINE cCmd1 CHAR(1000);
	DEFINE cFile CHAR(100);
	DEFINE cCodigo CHAR(10);
	DEFINE cDescProd CHAR(100);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iInicioReg = 1;
	LET iTamReg = 0;
	LET iPosCaracter = 0;
	LET iRecuperacion = 0;
	LET cEmpresa = '001';
	LET cTabla = '';
	LET cDato2 = '';
	LET cCampo1 = '';
	LET cCampo2 = '';
	LET iPosCaracter2 = '';
	LET cBase = '';
	LET cDescripcion = '';
	LET cUsrBin = '/usr/bin/';
	LET cIfxBin = '/ifxsif01/bin/';
	LET cCmd1 = '';
	LET cFile = 'Data_'||TO_CHAR(CURRENT,'%Y%m%d%H%M%S')||'.sql';
	LET cCodigo = '';
	LET cDescProd = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodigo, cDescProd;
		END EXCEPTION;

		SET DEBUG FILE TO '/tmp/mfinis/sp_ris_consultaproductos.out';
		TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pSistema = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodigo, cDescProd;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodigo, cDescProd;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		DELETE FROM "informix".sw_ristras_cmbproducto WHERE usuario_insert = pUsuario;

		SELECT base_datos, NVL(tabla_productos, 'SIN DATO') descripcion
		INTO cBase, cDescripcion
		FROM bdinteg:si_sistema
		WHERE sistema = pSistema;

		LET iTamReg = LENGTH(TRIM(cDescripcion));
		LET iPosCaracter = INSTR(cDescripcion, ":");
		LET cTabla = SUBSTR(TRIM(cDescripcion), iInicioReg, (iPosCaracter - 1));
		LET cDato2 = SUBSTR(TRIM(cDescripcion), (iPosCaracter + 1), (iTamReg - iPosCaracter));
		LET iPosCaracter2 = INSTR(cDato2, ":");
		LET cCampo1 = SUBSTR(TRIM(cDato2), iInicioReg, (iPosCaracter2 - 1));
		LET cCampo2 = SUBSTR(TRIM(cDato2), (iPosCaracter2 + 1), (iTamReg - iPosCaracter2));

		LET cCmd1 = TRIM(cUsrBin)||"echo " || '"' || "INSERT INTO bdicnweb:""informix"".sw_ristras_cmbproducto (usuario_insert, codigo, descripcion) SELECT '" || pUsuario || "'," || TRIM(cCampo1) || ", " || TRIM(cCampo2) || " FROM " || TRIM(cBase) || ":""informix""." || TRIM(cTabla) || " WHERE empresa = '" || cEmpresa || "'; "" > /tmp/mfinis/" || cFile;

		SYSTEM TRIM(cCmd1);

		LET cCmd1 = "";
		LET cCmd1 = TRIM(cIfxBin)||"dbaccess bdicnweb < /tmp/mfinis/" || cFile;
		SYSTEM TRIM(cCmd1);

		LET cCmd1 = "";
		LET cCmd1 = TRIM(cUsrBin)||"rm -rf /tmp/mfinis/" || TRIM(cFile);
		SYSTEM TRIM(cCmd1);

		FOREACH
			SELECT codigo, descripcion
			INTO cCodigo, cDescProd
			FROM "informix".sw_ristras_cmbproducto
			WHERE usuario_insert = pUsuario
            ORDER BY codigo ASC

			LET cDescProd = cDescProd || " [" || cCodigo || "]";

			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cCodigo, cDescProd WITH RESUME;

		END FOREACH;

		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCodigo, cDescProd;
		END IF;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃÂ¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar los Productos por Sistema',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_consultacriteriostransacciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistema CHAR(2), pProducto CHAR(10),  pTransaccion CHAR(4), pDescripcion CHAR(50), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(100) AS dato1,
				CHAR(100) AS dato2,
				CHAR(100) AS dato3,
				CHAR(10) AS dato4,
				CHAR(10) AS dato5,
				CHAR(10) AS dato6,
				CHAR(10) AS dato7,
				CHAR(10) AS dato8,
				CHAR(10) AS dato9,
				CHAR(10) AS dato10,
				CHAR(10) AS dato11,
				CHAR(10) AS dato12,
				CHAR(10) AS dato13,
				CHAR(10) AS dato14,
				CHAR(10) AS dato15,
				CHAR(10) AS dato16;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iInicioReg INTEGER;
	DEFINE iTamReg INTEGER;
	DEFINE iPosCaracter INTEGER;
	DEFINE iPosCaracter2 INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cTabla CHAR(50);
	DEFINE cDato2 CHAR(50);
	DEFINE cCampo1 CHAR(50);
	DEFINE cCampo2 CHAR(50);
	DEFINE cBase CHAR(50);
	DEFINE cDescripcion CHAR(100);
	DEFINE cUsrBin CHAR(15);
	DEFINE cIfxBin CHAR(15);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cCmd2 CHAR(2000);
	DEFINE cCmd3 CHAR(2000);
	DEFINE cCmd4 CHAR(2000);
	DEFINE cCmd5 CHAR(2000);
	DEFINE cCmd6 CHAR(2000);
	DEFINE cFile CHAR(100);
	DEFINE cCodigo CHAR(10);
	DEFINE cDescProd CHAR(100);
	DEFINE cDato1 CHAR(100);
	DEFINE cDato2_2 CHAR(100);
	DEFINE cDato3 CHAR(100);
	DEFINE cDato4 CHAR(10);
	DEFINE cDato5 CHAR(10);
	DEFINE cDato6 CHAR(10);
	DEFINE cDato7 CHAR(10);
	DEFINE cDato8 CHAR(10);
	DEFINE cDato9 CHAR(10);
	DEFINE cDato10 CHAR(10);
	DEFINE cDato11 CHAR(10);
	DEFINE cDato12 CHAR(10);
	DEFINE cDato13 CHAR(10);
	DEFINE cDato14 CHAR(10);
	DEFINE cDato15 CHAR(10);
	DEFINE cDato16 CHAR(10);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iInicioReg = 1;
	LET iTamReg = 0;
	LET iPosCaracter = 0;
	LET iRecuperacion = 0;
	LET cEmpresa = '001';
	LET cTabla = '';
	LET cDato2 = '';
	LET cCampo1 = '';
	LET cCampo2 = '';
	LET iPosCaracter2 = '';
	LET cBase = '';
	LET cDescripcion = '';
	LET cUsrBin = '/usr/bin/';
	LET cIfxBin = '/ifxsif01/bin/';
	LET cCmd1 = '';
	LET cCmd2 = '';
	LET cCmd3 = '';
	LET cCmd4 = '';
	LET cCmd5 = '';
	LET cCmd6 = '';
	LET cFile = 'Data_'||TO_CHAR(CURRENT,'%Y%m%d%H%M%S')||'.sql';
	LET cCodigo = '';
	LET cDescProd = '';
	LET cDato1 = '';
	LET cDato2_2 = '';
	LET cDato3 = '';
	LET cDato4 = '';
	LET cDato5 = '';
	LET cDato6 = '';
	LET cDato7 = '';
	LET cDato8 = '';
	LET cDato9 = '';
	LET cDato10 = '';
	LET cDato11 = '';
	LET cDato12 = '';
	LET cDato13 = '';
	LET cDato14 = '';
	LET cDato15 = '';
	LET cDato16 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ris_consultacriteriostransacciones.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistema = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pRegistros = 0 THEN
			DELETE FROM "informix".sw_ristras_consultacriteriostransacciones WHERE usuario_insert = pUsuario;
		
			SELECT base_datos, NVL(tabla_productos, 'SIN DATO') descripcion 
			INTO cBase, cDescripcion
			FROM bdinteg:si_sistema 
			WHERE sistema = pSistema;
			
			LET iTamReg = LENGTH(TRIM(cDescripcion));
			LET iPosCaracter = INSTR(cDescripcion, ":");
			LET cTabla = SUBSTR(TRIM(cDescripcion), iInicioReg, (iPosCaracter - 1));
			LET cDato2 = SUBSTR(TRIM(cDescripcion), (iPosCaracter + 1), (iTamReg - iPosCaracter));
			LET iPosCaracter2 = INSTR(cDato2, ":");
			LET cCampo1 = SUBSTR(TRIM(cDato2), iInicioReg, (iPosCaracter2 - 1));
			LET cCampo2 = SUBSTR(TRIM(cDato2), (iPosCaracter2 + 1), (iTamReg - iPosCaracter2));
		
			LET cCmd1 = TRIM(cUsrBin)||"echo " || '"' || "INSERT INTO bdicnweb:""informix"".sw_ristras_consultacriteriostransacciones (usuario_insert,dato1,dato2,dato3,dato4,dato5,dato6,dato7,dato8,dato9,dato10,dato11,dato12,dato13,dato14,dato15,dato16) SELECT '" || pUsuario || "'," || " TRIM(b.descripcion) || ' [' || TRIM(a.sistema) || ']', " || "d." || Trim(cCampo2) || "|| ' [' || a.producto || ']', '[' || transaccion || '] ' || TRIM(c.descripcion), secuencia, c_ccmayor, c_ccsub, c_ccsubsub, c_ccsssub, c_ccssssub, c_sector, a_ccmayor, a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, a_sector FROM bdinteg:si_prodtran a, bdinteg:si_sistema b, bdinteg:si_transacc c, " || Trim(cBase) || ":" || Trim(cTabla) || " d";
			LET cCmd2 = "" || TRIM(cCmd1) || " WHERE d.empresa = a.empresa AND d." || Trim(cCampo1) || " = a.producto AND c.empresa = a.empresa AND c.numero = a.transaccion AND b.sistema = a.sistema";
		
			IF pProducto <> '' THEN
				LET cCmd3 = TRIM(cCmd2) || " AND a.producto LIKE '" || TRIM(pProducto) || "%'";
			ELSE
				LET cCmd3 = TRIM(cCmd2);
			END IF;
		
			IF pTransaccion <> '' THEN
				LET cCmd4 = TRIM(cCmd3) || " AND a.transaccion LIKE '" || TRIM(pTransaccion) || "%'";
			ELSE
				LET cCmd4 = TRIM(cCmd3);
			END IF;
		
			IF pDescripcion <> '' THEN
				LET cCmd5 = TRIM(cCmd4) || " AND c.descripcion LIKE '" || TRIM(pDescripcion) || "%'";
			ELSE
				LET cCmd5 = TRIM(cCmd4);
			END IF;
		
			LET cCmd6 = TRIM(cCmd5) || " ORDER BY 1,2,3, a.secuencia"" > /tmp/mfinis/" || cFile;
		
			SYSTEM TRIM(cCmd6);
		
			LET cCmd1 = "";
			LET cCmd1 = TRIM(cIfxBin)||"dbaccess bdicnweb < /tmp/mfinis/" || cFile;
			SYSTEM TRIM(cCmd1);
		
			LET cCmd1 = "";
			LET cCmd1 = TRIM(cUsrBin)||"rm -rf /tmp/mfinis/" || TRIM(cFile);
			SYSTEM TRIM(cCmd1);
		END IF;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion  
			dato1, dato2, dato3, dato4, dato5, dato6, dato7, dato8, dato9, dato10, dato11, dato12, dato13, dato14, dato15, dato16
			INTO cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16
			FROM "informix".sw_ristras_consultacriteriostransacciones
			WHERE usuario_insert = pUsuario
			ORDER BY 3,4
			
			LET iRecuperacion = iRecuperacion + 1;
			
			RETURN cCodRet, cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16 WITH RESUME;
		
		END FOREACH;
			
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16;
		END IF;	
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃÂ¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar los por diferentes criterios de busqueda',
'AUTOR: VerÃÂ³nica SÃÂ¡nchez Tlacomulco',
'FECHA: 04/03/2021',
'DESCRIPCION: Se realiza ajuste a SP para realizar ordenamiento de informaciÃÂ³n por secuencia.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_consultasistemas(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			 CHAR(2) AS sistema,
			 CHAR(35) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cSistema CHAR(2);
	DEFINE cDescripcion CHAR(35);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cSistema = '';
	LET cDescripcion = '';
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cSistema, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ris_consultasistemas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSistema, cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSistema, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
			SELECT sistema, descripcion  
			INTO cSistema, cDescripcion 
			FROM bdinteg:si_sistema
			WHERE utiliza_productos = 'S' 
			--AND descripcion NOT IN ('TRANSFERENCIAS') 
			ORDER BY descripcion
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cSistema, cDescripcion WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cSistema, cDescripcion;
		END IF;	
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar los Sistemas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_formararchivodedeclaracion(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaXML CHAR(6), pDeclaracion CHAR(1), pTipoDeclaracion CHAR(1))
		RETURNING CHAR(5) AS codret,
			CHAR(20) AS archivo;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cArchivo CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cArchivo = '';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_formararchivodedeclaracion' AND fecha_fin IS NULL; 
			
			UPDATE "informix".sw_verificastatusformarchivo
			SET status = 'E', error = cCodRet
			WHERE usuario_insert = pUsuario;

			RETURN cCodRet, cArchivo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/ifxsif01/ilopez/IDE_MENSUAL_ANUAL/bdicnweb/sp_ope_formararchivodedeclaracion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaXML = '' OR pDeclaracion = '' OR pTipoDeclaracion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cArchivo;
		END IF;

		DELETE FROM "informix".sw_verificastatusformarchivo WHERE usuario_insert = pUsuario;
		
		INSERT INTO "informix".sw_verificastatusformarchivo(usuario_insert, status,	error_proceso, error, nombre_archivo) VALUES(pUsuario,'I','','','');

		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_formararchivodedeclaracion', CURRENT, null);
		


		LET pFechaXML=pFechaXML;
		LET pDeclaracion=pDeclaracion;
		LET pTipoDeclaracion=pTipoDeclaracion;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_formararchivodedeclaracion' AND fecha_fin IS NULL; 
			RETURN cCodRet, cArchivo;

			UPDATE "informix".sw_verificastatusformarchivo
			SET status = 'E', error = cCodRet
			WHERE usuario_insert = pUsuario;
		END IF;

		
		
		LET pFechaXML=pFechaXML;
		LET pDeclaracion=pDeclaracion;
		LET pTipoDeclaracion=pTipoDeclaracion;

		EXECUTE PROCEDURE bdilide:"informix".sp_formararchivodedeclaracion2(pFechaXML, pDeclaracion, pTipoDeclaracion)
		--EXECUTE PROCEDURE bdilide:"informix".sp_formararchivodedeclaracion(pFechaXML, pDeclaracion, pTipoDeclaracion)
		INTO cCodRetSp, cArchivo;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_formararchivodedeclaracion";
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00017';
		END IF;
		
		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_formararchivodedeclaracion' AND fecha_fin IS NULL; 
		
		IF cCodRet = '00000' THEN
			UPDATE "informix".sw_verificastatusformarchivo
			SET status = 'T', error = cCodRet, nombre_archivo = cArchivo
			WHERE usuario_insert = pUsuario;
		ELSE
			UPDATE "informix".sw_verificastatusformarchivo
			SET status = 'E', error = cCodRet
			WHERE usuario_insert = pUsuario;
		END IF;

		RETURN cCodRet, cArchivo;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 05/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Declaracion Informativa IDE',
'DESCRIPCION: SPL encargado de generar archivo declarcacion IDE',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusarchivodeclaracionide(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(25) AS nom_archivo,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cNomArchivo CHAR(25);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET cNomArchivo = '';
	

	SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,cNomArchivo,cErrorProceso,cError;	
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusentradasalida.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cNomArchivo,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cNomArchivo,cErrorProceso,cError;
		END IF;
		
		
		
		SELECT status,nom_archivo,error_proceso,error
		INTO cStatus,cNomArchivo,cErrorProceso,cError
		FROM bdicnweb:sw_verificastatusarchivodeclaracionide WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,cNomArchivo,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: VERIFICA EL ESTATUS DEL PROCESO ',
'DESCRIPCION: ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_escribirarchivodedeclaracionide(pUsuario CHAR(8), pIdFuncion CHAR(10), pArchivo CHAR(20))
		RETURNING CHAR(5) AS codret,
			CHAR(25) AS nombreArchivo;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cFile CHAR(25);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cFile = '';
	
	SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_escribirarchivodedeclaracionide' AND fecha_fin IS NULL;
			
			UPDATE bdicnweb:"informix".sw_verificastatusarchivodeclaracionide
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;            

			RETURN cCodRet, cFile;
			
                        
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_escribirarchivodedeclaracionide.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
         DELETE FROM bdicnweb:"informix".sw_verificastatusarchivodeclaracionide WHERE usuario_insert = TRIM(pUsuario);
                
        -- SE INSERTA PROCESO
         INSERT INTO bdicnweb:"informix".sw_verificastatusarchivodeclaracionide(usuario_insert,status,nom_archivo,error_proceso,error) VALUES(pUsuario,'I','','',cCodRet);
		
		IF pUsuario = '' OR pIdFuncion = '' OR pArchivo = '' THEN
			LET cCodRet = '00003';
			  --Actualiza proceso erroneo
                     UPDATE bdicnweb:"informix".sw_verificastatusarchivodeclaracionide
					 SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, cFile;
		END IF;
		
		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_escribirarchivodedeclaracionide', CURRENT, null);

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_escribirarchivodedeclaracionide' AND fecha_fin IS NULL;
			 --Actualiza proceso erroneo
                    UPDATE bdicnweb:"informix".sw_verificastatusarchivodeclaracionide
				    SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, cFile;
		END IF;
		
		
		
		EXECUTE PROCEDURE bdilide:"informix".sp_escribirarchivodedeclaracionide2(pArchivo)
		INTO cCodRetSp, cFile;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_escribirarchivodedeclaracionide";
			--Actualiza proceso erroneo
            UPDATE bdicnweb:"informix".sw_verificastatusarchivodeclaracionide
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			
		END IF;

		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_escribirarchivodedeclaracionide' AND fecha_fin IS NULL;
		---Actualiza proceso exitoso
        UPDATE bdicnweb:"informix".sw_verificastatusarchivodeclaracionide
	    SET status = 'T', error_proceso = 'N', nom_archivo = cFile WHERE usuario_insert = pUsuario;
		
		RETURN cCodRet, cFile;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 05/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Declaracion Informativa IDE',
'DESCRIPCION: SPL encargado de escribir archivo declarcacion IDE',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusformaarchivoide(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,
		CHAR(20) AS nombre_archivo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cNombreArch CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET cNombreArch = '';
	
	SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatus, cErrorProceso, cError, cNombreArch;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/ifxsif01/ilopez/IDE_MENSUAL_ANUAL/bdicnweb/sp_verificastatusformaarchivoide.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatus, cErrorProceso, cError, cNombreArch;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cStatus, cErrorProceso, cError, cNombreArch;
		END IF;
		
		
		
		SELECT status,error_proceso,error, nombre_archivo
		INTO cStatus, cErrorProceso, cError, cNombreArch
		FROM "informix".sw_verificastatusformarchivo WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet, cStatus, cErrorProceso, cError, cNombreArch;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 14/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Declaracion IDE',
'DESCRIPCION: SPL encargado verificar el status del proceso de creacion del archivo.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultafechaprocesoanual(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaProceso DATE)
		RETURNING CHAR(5) AS codret,
			DATE AS fecha,
			CHAR(5) AS status,
			CHAR(50) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cDescripcion CHAR(50);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFecha DATE;
	DEFINE cStatus CHAR(1);
	DEFINE dUltimoDiaMes DATE;
	DEFINE iexisteFechaProceso INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cDescripcion = '';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET dFecha = DATE(1);
	LET cStatus = '';
	LET dUltimoDiaMes = DATE(1);
	LET iexisteFechaProceso = 0;
	


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultafechaprocesoanual' AND fecha_fin IS NULL;

			RETURN cCodRet, dFecha, cStatus, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/ifxsif01/ilopez/IDE_MENSUAL_ANUAL/bdicnweb/sp_ope_consultafechaprocesoanual.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaProceso IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, cStatus, cDescripcion;
		END IF;

		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_consultafechaprocesoanual', CURRENT, null);
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultafechaprocesoanual' AND fecha_fin IS NULL;
			RETURN cCodRet, dFecha, cStatus, cDescripcion;
		END IF;
		
		
		
		SELECT COUNT(a.fech_proceso) 
		INTO iexisteFechaProceso
		FROM bdilide:"informix".sl_procesos a
		WHERE a.proceso = 'decanual' AND a.fech_proceso = pFechaProceso;
		
		SELECT LAST_DAY(pFechaProceso)
		INTO dUltimoDiaMes
		FROM systables WHERE tabid = 1;
		
		IF iexisteFechaProceso > 0 THEN -- LA COMPARACIÃN DEBERÃ SER CON LA VARIABLE DEL INTO, DEJE ESTA SOLO COMO EJEMPLO PARA LA LOGICA DEL SPL
			
			SELECT a.fech_proceso, a.status
			INTO dFecha, cStatus
			FROM bdilide:"informix".sl_procesos a
			WHERE a.proceso = 'decanual' AND a.fech_proceso = dUltimoDiaMes;
			
			IF dFecha = dUltimoDiaMes OR cStatus = '1' THEN
		
				EXECUTE PROCEDURE "informix".sp_ope_consultarutalmacenamientoxml(pUsuario, pIdFuncion)
				INTO cCodRetSp, cDescripcion;
				
				LET cDescripcion = cDescripcion || (SELECT year(pFechaProceso) FROM systables WHERE tabid = 1);
			ELSE
				LET cCodRet = '01221'; -- PRIMERO DEBE GENERAR EL REPORTE PARA PODER GENERAR EL ARCHIVO XML, VERIFIQUE.	
			END IF;
		
		ELIF iexisteFechaProceso = 0 THEN
			LET cCodRet = '01221'; -- PRIMERO DEBE GENERAR EL REPORTE PARA PODER GENERAR EL ARCHIVO XML, VERIFIQUE.	
		END IF;
		
		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultafechaprocesoanual' AND fecha_fin IS NULL;

		RETURN cCodRet, dFecha, cStatus, cDescripcion;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 03/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Declaracion Informativa',
'DESCRIPCION: SPL encargado de consulta para obtener el valor correspondiente a fecha de proceso (DECLARACIÃN ANUAL)',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultarutalmacenamientoxml(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(50) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cDescripcion CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cDescripcion = '';

	SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultarutalmacenamientoxml' AND fecha_fin IS NULL;
		
			RETURN cCodRet, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultarutalmacenamientoxml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDescripcion;
		END IF;

		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_consultarutalmacenamientoxml', CURRENT, null);
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultarutalmacenamientoxml' AND fecha_fin IS NULL;
			RETURN cCodRet, cDescripcion;
		END IF;

		
		
		SELECT a.desc_valor
		INTO cDescripcion
		FROM bdilide:"informix".sl_parametros a
		WHERE a.cve_param = '13' AND a.valor = '01';
		
		IF cDescripcion = ''  THEN
			LET cCodRet = '00017';
		END IF;

		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultarutalmacenamientoxml' AND fecha_fin IS NULL;
		
		RETURN cCodRet, cDescripcion;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 03/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Transmision archivos SAT',
'DESCRIPCION: SPL encargado de consulta para obtener el valor correspondiente a la ruta en donde se almacenan los archivos xml',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultacomboparametro(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			   	CHAR(8) AS cve_param,
				CHAR(80) AS desc_valor;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cCveParam CHAR(8);
	DEFINE cDescValor CHAR(80);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iRecuperacion = 0;
	LET cCveParam = '';
	LET cDescValor = '';

	SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;

			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultacomboparametro' AND fecha_fin IS NULL;

			RETURN cCodRet, cCveParam, cDescValor;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultacomboparametro.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCveParam, cDescValor;
		END IF;
		
		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_consultacomboparametro', CURRENT, null);
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultacomboparametro' AND fecha_fin IS NULL;
			RETURN cCodRet, cCveParam, cDescValor;
		END IF;

		
		
		FOREACH
		
			SELECT SKIP pRegistros FIRST pRecuperacion A.cve_param, B.descripcion 
			INTO cCveParam, cDescValor
			FROM bdilide:"informix".sl_parametros AS A 
			INNER JOIN bdilide:"informix".sl_cveparam AS B ON A.cve_param = B.cve_param 
			WHERE A.cve_param IN ('08', '11', '13', '18', '20', '24') 
			GROUP BY A.cve_param, B.descripcion 
			ORDER BY 1, 2			
		
			LET iRecuperacion = iRecuperacion + 1;
			
			RETURN cCodRet, cCveParam, cDescValor WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 

			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultacomboparametro' AND fecha_fin IS NULL;

			RETURN cCodRet, cCveParam, cDescValor;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';

			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultacomboparametro' AND fecha_fin IS NULL;

			RETURN cCodRet, cCveParam, cDescValor;
		END IF;	
		
		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultacomboparametro' AND fecha_fin IS NULL;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 05/10/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Administrador de Parametros',
'DESCRIPCION: SPL encargado de consular el combo seleccion parametro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_actualizaparametrosgral(pUsuario CHAR(8), pIdFuncion CHAR(10), pCveParametro CHAR(8), cValor CHAR(10), cDescValor CHAR(50), pActaulizaValor CHAR(1))
		RETURNING CHAR(5) AS codret;						
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cDescValorAnt CHAR(50);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cDescValorAnt = '';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			
			UPDATE "informix".sw_bitacoractualizaciondatos 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND fecha_fin IS NULL;

			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/ifxsif01/ilopez/IDE_MENSUAL_ANUAL/Componentes_a_liberar_IDE/bdicnweb/SPL_PROBADOS_PARA_PRODUCCION/sp_ope_actualizaparametrosgral.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pCveParametro = '' OR cValor = '' OR pActaulizaValor = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		
		
		IF pActaulizaValor = '1' THEN
			SELECT desc_valor INTO cDescValorAnt
			FROM bdilide:"informix".sl_parametros
			WHERE cve_param = pCveParametro AND valor = cValor;
			
			INSERT INTO "informix".sw_bitacoractualizaciondatos(usuario_insert, nombre_tabla, valor_antes, valor_despues, fecha_inicio, fecha_fin) 
			VALUES(pUsuario, 'sl_parametros', cDescValorAnt, null, CURRENT, null);

			UPDATE bdilide:"informix".sl_parametros SET desc_valor = cDescValor WHERE cve_param = pCveParametro AND valor = cValor;
			
			UPDATE "informix".sw_bitacoractualizaciondatos 
			SET fecha_fin = CURRENT, valor_despues = cDescValor
			WHERE usuario_insert = pUsuario AND fecha_fin IS NULL;
		ELSE
			SELECT valor INTO cDescValorAnt
			FROM bdilide:"informix".sl_parametros
			WHERE cve_param = pCveParametro
			AND valor=cValor;
			
			INSERT INTO "informix".sw_bitacoractualizaciondatos(usuario_insert, nombre_tabla, valor_antes, valor_despues, fecha_inicio, fecha_fin) 
			VALUES(pUsuario, 'sl_parametros', cDescValorAnt, null, CURRENT, null);

			UPDATE bdilide:"informix".sl_parametros SET desc_valor = cDescValor WHERE valor = cValor AND cve_param = pCveParametro;

			UPDATE "informix".sw_bitacoractualizaciondatos 
			SET fecha_fin = CURRENT, valor_despues = cValor
			WHERE usuario_insert = pUsuario AND fecha_fin IS NULL;
		END IF;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 05/10/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Administrador de Parametros',
'DESCRIPCION: SPL encargado de actualizar los parametros',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusdeclide(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,
		CHAR(80) AS mensaje;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cMensaje CHAR(80);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET cMensaje = '';


	SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatus, cErrorProceso, cError, cMensaje;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusdeclide.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatus, cErrorProceso, cError, cMensaje;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cStatus, cErrorProceso, cError, cMensaje;
		END IF;
		
		
		
		SELECT status,error_proceso,error,mensaje
		INTO cStatus, cErrorProceso, cError, cMensaje
		FROM "informix".sw_verificastatusdeclide WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet, cStatus, cErrorProceso, cError, cMensaje;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 14/09/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: DEPOSITOS COPPEL',
'DESCRIPCION: SPL encargado verificar el status del proceso de carga de archivo coppel.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_obtienenombrempresa(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(50) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cDescripcion CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cDescripcion = '';
	


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_obtienenombrempresa' AND fecha_fin IS NULL;
			RETURN cCodRet, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_obtienenombrempresa.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDescripcion;
		END IF;

		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_obtienenombrempresa', CURRENT, null);
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_obtienenombrempresa' AND fecha_fin IS NULL;
			RETURN cCodRet, cDescripcion;
		END IF;
		
		
		
		SELECT a.desc_valor
		INTO cDescripcion
		FROM bdilide:"informix".sl_parametros a
		WHERE a.cve_param = '08' AND a.valor = '02';
		
		IF NVL(cDescripcion,'') = ''  THEN
			LET cCodRet = '00017';
		END IF;
		
		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_obtienenombrempresa' AND fecha_fin IS NULL;
		
RETURN cCodRet, cDescripcion;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 03/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Declaracion Informativa',
'DESCRIPCION: SPL encargado de Consulta Para Obtener El Nombre De La Empresa Bancoppel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultaparametroxsd(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(50) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE existe_ArchivoXSD INTEGER;
	DEFINE cDescripcion CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET existe_ArchivoXSD = 0;
	LET cDescripcion = '';


		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametroxsd' AND fecha_fin IS NULL;
			RETURN cCodRet, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultaparametroxsd.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDescripcion;
		END IF;
		
		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_consultaparametroxsd', CURRENT, null);

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametroxsd' AND fecha_fin IS NULL;
			RETURN cCodRet, cDescripcion;
		END IF;
		
	
		
		SELECT COUNT (a.desc_valor) 
		INTO existe_ArchivoXSD 
		FROM bdilide:"informix".sl_parametros a
		WHERE a.cve_param = '20' AND a.valor = '01';

		IF existe_ArchivoXSD > 0 THEN 
			SELECT a.desc_valor
			INTO cDescripcion
			FROM bdilide:"informix".sl_parametros a
			WHERE a.cve_param = '20' AND a.valor = '01';
		ELSE
			LET cCodRet = '00017';
		END IF
		
		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametroxsd' AND fecha_fin IS NULL;
		
		RETURN cCodRet, cDescripcion;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 03/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Declaracion Informativa',
'DESCRIPCION: SPL encargado de Consulta Para Validar La Existencia Del ParÃ¡metro Archivo XSD',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultaparametrosgralide(pUsuario CHAR(8), pIdFuncion CHAR(10), pCveParam CHAR(8), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			   	CHAR(8) AS cve_param,
				CHAR(10) AS valor,
				CHAR(50) AS desc_valor;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iRecuperacion INTEGER;	
	DEFINE cCveParam CHAR(8);
	DEFINE cValor CHAR(10);
	DEFINE cDescValor CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iRecuperacion = 0;
	LET cCveParam = '';
	LET cValor = '';
	LET cDescValor = '';
	


		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametrosgralide' AND fecha_fin IS NULL;
			RETURN cCodRet, cCveParam, cValor, cDescValor;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultaparametrosgralide.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCveParam = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCveParam, cValor, cDescValor;
		END IF;
		
		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_consultaparametrosgralide', CURRENT, null);

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametrosgralide' AND fecha_fin IS NULL;
			RETURN cCodRet, cCveParam, cValor, cDescValor;
		END IF;
		
	
		
		IF pCveParam = '08' THEN
		
			FOREACH
			
				SELECT SKIP pRegistros FIRST pRecuperacion cve_param, valor, desc_valor 
				INTO cCveParam, cValor, cDescValor
				FROM bdilide:"informix".sl_parametros 
				WHERE cve_param = pCveParam AND valor IN ('01','02','03','04','05','06','07') 
				ORDER BY 1, 2
				
				LET iRecuperacion = iRecuperacion + 1;
				
				RETURN cCodRet, cCveParam, cValor, cDescValor WITH RESUME;
				
			END FOREACH;
		
		ELIF pCveParam = '11' THEN
		
			FOREACH
			
				SELECT SKIP pRegistros FIRST pRecuperacion cve_param, valor, desc_valor 
				INTO cCveParam, cValor, cDescValor
				FROM bdilide:"informix".sl_parametros 
				WHERE cve_param = pCveParam AND valor = '01' ORDER BY 1, 2
				
				LET iRecuperacion = iRecuperacion + 1;
				
				RETURN cCodRet, cCveParam, cValor, cDescValor WITH RESUME;
				
			END FOREACH;
		
		ELIF pCveParam = '13' THEN
		
			FOREACH
			
				SELECT SKIP pRegistros FIRST pRecuperacion cve_param, valor, desc_valor 
				INTO cCveParam, cValor, cDescValor
				FROM bdilide:"informix".sl_parametros 
				WHERE cve_param = pCveParam	AND valor IN ('01','03') ORDER BY 1, 2
				
				LET iRecuperacion = iRecuperacion + 1;
				
				RETURN cCodRet, cCveParam, cValor, cDescValor WITH RESUME;
				
			END FOREACH;
		
		ELIF pCveParam = '18' THEN
		
			FOREACH
			
				SELECT SKIP pRegistros FIRST pRecuperacion cve_param, valor, desc_valor 
				INTO cCveParam, cValor, cDescValor
				FROM bdilide:"informix".sl_parametros 
				WHERE cve_param = pCveParam AND valor IN ('01','02','03','04') ORDER BY 1, 2
				
				LET iRecuperacion = iRecuperacion + 1;
				
				RETURN cCodRet, cCveParam, cValor, cDescValor WITH RESUME;
				
			END FOREACH;
		
		ELIF pCveParam = '20' THEN
		
			FOREACH
			
				SELECT SKIP pRegistros FIRST pRecuperacion cve_param, valor, desc_valor 
				INTO cCveParam, cValor, cDescValor
				FROM bdilide:"informix".sl_parametros 
				WHERE cve_param = pCveParam AND valor = '01' ORDER BY 1, 2
				
				LET iRecuperacion = iRecuperacion + 1;
				
				RETURN cCodRet, cCveParam, cValor, cDescValor WITH RESUME;
				
			END FOREACH;
		
		ELIF pCveParam = '24' THEN
		
			FOREACH
			
				SELECT SKIP pRegistros FIRST pRecuperacion cve_param, valor, desc_valor 
				INTO cCveParam, cValor, cDescValor
				FROM bdilide:"informix".sl_parametros 
				WHERE cve_param = pCveParam ORDER BY 1, 2
				
				LET iRecuperacion = iRecuperacion + 1;
				
				RETURN cCodRet, cCveParam, cValor, cDescValor WITH RESUME;
				
			END FOREACH;
		
		END IF;	
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametrosgralide' AND fecha_fin IS NULL;
			RETURN cCodRet, cCveParam, cValor, cDescValor;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametrosgralide' AND fecha_fin IS NULL;
			RETURN cCodRet, cCveParam, cValor, cDescValor;
		END IF;	
		
		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametrosgralide' AND fecha_fin IS NULL;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 05/10/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Administrador de Parametros',
'DESCRIPCION: SPL encargado de Consular el grid de parametros',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultaparametrosenviosat(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(8) AS cve_param,
			CHAR(10) AS valor,
			CHAR(50) AS descripcion;
		
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr 				INTEGER;
	DEFINE existenParametros 	INTEGER;
	DEFINE cCveParam 			CHAR(8);
	DEFINE cValor 				CHAR(10);
	DEFINE cDescripcion 		CHAR(50);
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET existenParametros 		= 0;
	LET cCveParam 				= '';
	LET cValor 					= '';
	LET cDescripcion 			= '';
	
	SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametrosenviosat' AND fecha_fin IS NULL;
			RETURN cCodRet, cCveParam, cValor, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultaparametrosenviosat.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCveParam, cValor, cDescripcion;
		END IF;

		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_consultaparametrosenviosat', CURRENT, null);
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametrosenviosat' AND fecha_fin IS NULL;
			RETURN cCodRet, cCveParam, cValor, cDescripcion;
		END IF;

		
		
		SELECT COUNT(*) 
		INTO existenParametros
		FROM bdilide:"informix".sl_parametros a
		WHERE a.cve_param = '18';
		
		IF existenParametros >= 3 THEN
		
			FOREACH 
				SELECT a.cve_param, a.valor, a.desc_valor
				INTO cCveParam, cValor, cDescripcion
				FROM bdilide:"informix".sl_parametros a
				WHERE a.cve_param = '18'
				ORDER BY a.valor DESC
				
				RETURN cCodRet, cCveParam, cValor, cDescripcion WITH RESUME;
			
			END FOREACH;
		
		ELSE 
			LET cCodRet = '01220'; -- NO EXISTEN LOS PARÃMETROS NECESARIOS PARA ENVIAR EL ARCHIVO AL SAT, FAVOR DE REVISAR EN EL ADMINISTRADOR DE PARÃMETROS.
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametrosenviosat' AND fecha_fin IS NULL;
			RETURN cCodRet, cCveParam, cValor, cDescripcion;
		END IF	
		
		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametrosenviosat' AND fecha_fin IS NULL;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 03/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Transmision archivos SAT',
'DESCRIPCION: SPL encargado de consulta para obtener los parÃ¡metros a mostrar en la pantalla transmisiÃ³n del archivo al SAT',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultaiprutacarga(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(50) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cDescripcion CHAR(50);
	DEFINE iRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cDescripcion = '';
	LET iRegistros = 0;
	

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;

			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaiprutacarga' AND fecha_fin IS NULL;
			
			RETURN cCodRet, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultaiprutacarga.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDescripcion;
		END IF;
		
		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_consultaiprutacarga', CURRENT, null);

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaiprutacarga' AND fecha_fin IS NULL;
			RETURN cCodRet, cDescripcion;
		END IF;
		
	
		
		FOREACH 
			SELECT a.desc_valor 
			INTO cDescripcion
			FROM bdilide:"informix".sl_parametros a
			WHERE (a.cve_param = '11' AND a.valor = '01') OR (a.cve_param = '13' AND a.valor = '03')

			LET iRegistros = iRegistros + 1;

			RETURN cCodRet, cDescripcion WITH RESUME;
		END FOREACH;
		
		IF iRegistros = 0  THEN
			LET cCodRet = '00017';
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaiprutacarga' AND fecha_fin IS NULL;
			RETURN cCodRet, cDescripcion;
		END IF;	

		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaiprutacarga' AND fecha_fin IS NULL;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 03/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Transmision archivos SAT',
'DESCRIPCION: SPL encargado de consulta para obtener la ip y la ruta de descarga del archivo .gz',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultafechaproceso(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaProceso DATE)
		RETURNING CHAR(5) AS codret,
			DATE AS fecha,
			CHAR(1) AS status,
			CHAR(50) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cDescripcion CHAR(50);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFecha DATE;
	DEFINE cStatus CHAR(1);
	DEFINE dUltimoDiaMes DATE;
	DEFINE iexisteFechaProceso INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cDescripcion = '';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET dFecha = DATE(1);
	LET cStatus = '';
	LET dUltimoDiaMes = DATE(1);
	LET iexisteFechaProceso = 0;
	

	SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultafechaproceso' AND fecha_fin IS NULL;
			RETURN cCodRet, dFecha, cStatus, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultafechaproceso.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaProceso IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, cStatus, cDescripcion;
		END IF;

		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_consultafechaproceso', CURRENT, null);
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultafechaproceso' AND fecha_fin IS NULL;
			RETURN cCodRet, dFecha, cStatus, cDescripcion;
		END IF;
		
		
		
		SELECT COUNT(a.fech_proceso) 
		INTO iexisteFechaProceso
		FROM bdilide:"informix".sl_procesos a
		WHERE a.proceso = 'decmensual' AND a.fech_proceso = pFechaProceso;
		
		SELECT LAST_DAY(pFechaProceso)
		INTO dUltimoDiaMes
		FROM systables WHERE tabid = 1;
		
		IF iexisteFechaProceso > 0 THEN -- LA COMPARACIÃN DEBERÃ SER CON LA VARIABLE DEL INTO, DEJE ESTA SOLO COMO EJEMPLO PARA LA LOGICA DEL SPL
			
			SELECT a.fech_proceso, a.status
			INTO dFecha, cStatus
			FROM bdilide:"informix".sl_procesos a
			WHERE a.proceso = 'decmensual' AND a.fech_proceso = dUltimoDiaMes;
			
			IF dFecha = dUltimoDiaMes OR cStatus = '1' THEN
		
				EXECUTE PROCEDURE "informix".sp_ope_consultarutalmacenamientoxml(pUsuario, pIdFuncion)
				INTO cCodRetSp, cDescripcion;
				
				LET cDescripcion = cDescripcion || (SELECT year(pFechaProceso) FROM systables WHERE tabid = 1);
			ELSE
				LET cCodRet = '01221'; -- PRIMERO DEBE GENERAR EL REPORTE PARA PODER GENERAR EL ARCHIVO XML, VERIFIQUE.	
			END IF;
		
		ELIF iexisteFechaProceso = 0 THEN
			LET cCodRet = '01221'; -- PRIMERO DEBE GENERAR EL REPORTE PARA PODER GENERAR EL ARCHIVO XML, VERIFIQUE.	
		END IF;
		
		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultafechaproceso' AND fecha_fin IS NULL;
		
		RETURN cCodRet, dFecha, cStatus, cDescripcion;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 03/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Declaracion Informativa',
'DESCRIPCION: SPL encargado de consulta para obtener el valor correspondiente a fecha de proceso (DECLARACION MENSUAL)',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_altamodificacion_piezas_bym(pUsuario CHAR(8), pIdFuncion CHAR(10),pOpcion CHAR(1), pIdDenominacion INTEGER,pNumRecibo CHAR(10), pTipoPieza CHAR(1), pSerie CHAR(40), pFolio CHAR(40), pFechaEmision DATE, pNumPiezas INTEGER, pNota CHAR(200), pNumGuia CHAR(12),pFolioBanxico CHAR(40), pDictamenBanxico INTEGER,pNumLoteBanxico CHAR(40), pEstatus INTEGER, pIdPieza INTEGER, pTrama CHAR(500))
    RETURNING CHAR(5) AS CodRet;
	
	DEFINE iSqlErr               INTEGER;
	DEFINE iSamErr               INTEGER;
	DEFINE cDesErr               CHAR(80);
	DEFINE cCodRet               CHAR(5);
	DEFINE cCodRetSp 			 CHAR(6);
	DEFINE cMensaje              CHAR(80);
	DEFINE iRecuperacion 		 INTEGER;
	DEFINE cEmpresa 			 CHAR(3);
	DEFINE iNoRegistros        	 INTEGER;
	DEFINE cFolio 				 INTEGER;
	DEFINE cNumRecibo			 CHAR(10);
	DEFINE dFechaEmision      	 DATE;
	DEFINE iNumPiezas            INTEGER;
	DEFINE iCvePieza             INTEGER;
	DEFINE iDictamen             INTEGER;	
		
	LET iSqlErr                 = 0;
	LET iSamErr                 = 0;
	LET cDesErr                 = '';
	LET cCodRet                 = '00000';
	LET cCodRetSp				= '000000';
	LET cMensaje                = '';
	LET iRecuperacion			= 0;
	LET cEmpresa 				= '001';
	LET iNoRegistros			= 0;
	LET cFolio					= 0;
	LET cNumRecibo			    = '';
	LET dFechaEmision      	  	= DATE(1);
	LET iNumPiezas            	= 0;
	LET iCvePieza             	= 0;
	LET iDictamen             	= 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_altamodificacion_piezas_bym.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pOpcion=''  OR (pOpcion=4 AND pTrama='') THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pOpcion = 4 THEN 
		
			FOREACH 
				EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pTrama, ',')
				INTO cFolio
				
				SELECT {+INDEX (bdicnweb:sw_cg_billetesfalsos idx_sw_cg_billetesfalsos)}  cve_pieza,num_piezas,num_recibo,fecha_emision, NVL(cd.id_dictamen,'0' ) 
				INTO iCvePieza,iNumPiezas,cNumRecibo,dFechaEmision,iDictamen 
				FROM "informix".sw_cg_billetesfalsos s LEFT JOIN bdisuc:"informix".ss_cat_dictamen_bym_falsos cd ON cd.desc_dictamen=s.dictamen_banxico
				WHERE us_insert = TRIM(pUsuario)
				AND id_serial=cFolio::INTEGER;
				
				UPDATE {+INDEX (bdicnweb:sw_cg_billetesfalsos idx_sw_cg_billetesfalsos)} "informix".sw_cg_billetesfalsos SET
				indicador=1
				WHERE us_insert = TRIM(pUsuario)
				AND id_serial=cFolio::INTEGER;
				
				EXECUTE PROCEDURE bdisuc:"informix".sp_altamodificacion_piezas_bym('4', '0',cNumRecibo,'','','',  dFechaEmision, iNumPiezas, '','','', iDictamen,'', '2', pUsuario, iCvePieza)
				INTO cCodRetSp, cMensaje;
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_altamodificacion_piezas_bym';
				ELIF cCodRetSp::INTEGER = 1   THEN
					LET cCodRet = '00003';
				ELIF cCodRetSp::INTEGER = 262 THEN		--262	El archivo se cargÃ³ satisfactoriamente.           
					LET cCodRet = '00000';
				ELIF cCodRetSp::INTEGER = 263 THEN		--263	El archivo se generÃ³ satisfactoriamente.          
					LET cCodRet = '00000';
				ELIF cCodRetSp::INTEGER = 264 THEN		--264	El archivo ya fue procesado con anterioridad.     
					LET cCodRet = '00492';
				ELIF cCodRetSp::INTEGER = 265 THEN		--265	La informaciÃ³n ha sido guardada                   
					LET cCodRet = '00000';
				ELIF cCodRetSp::INTEGER = 266 THEN		--266 satisfactoriamente.                               
					LET cCodRet = '00000';
				ELIF cCodRetSp::INTEGER = 2 THEN		--2                               
					LET cCodRet = '00017';
				END IF;
				
			END FOREACH;
			
		ELSE
			
			EXECUTE PROCEDURE bdisuc:"informix".sp_altamodificacion_piezas_bym(pOpcion, pIdDenominacion,pNumRecibo, pTipoPieza, pSerie, pFolio,
			pFechaEmision, pNumPiezas, pNota, pNumGuia,pFolioBanxico, pDictamenBanxico,pNumLoteBanxico, pEstatus, pUsuario, pIdPieza)
			INTO cCodRetSp, cMensaje;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_altamodificacion_piezas_bym';
			ELIF cCodRetSp::INTEGER = 1   THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 262 THEN		--262	El archivo se cargÃ³ satisfactoriamente.           
				LET cCodRet = '00000';
			ELIF cCodRetSp::INTEGER = 263 THEN		--263	El archivo se generÃ³ satisfactoriamente.          
				LET cCodRet = '00000';
			ELIF cCodRetSp::INTEGER = 264 THEN		--264	El archivo ya fue procesado con anterioridad.     
				LET cCodRet = '00492';
			ELIF cCodRetSp::INTEGER = 265 THEN		--265	La informaciÃ³n ha sido guardada                   
				LET cCodRet = '00000';
			ELIF cCodRetSp::INTEGER = 266 THEN		--266 satisfactoriamente.                               
				LET cCodRet = '00000';
			ELIF cCodRetSp::INTEGER = 2 THEN		--2                               
				LET cCodRet = '00017';
				
			END IF;
			
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00282';
		END IF;
		
		RETURN cCodRet; 
    
	END;    
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 15/12/2016',
'MODULO: CAJA GENERAL ',
'FUNCIONALIDAD: BILLETES PRESUNTAMENTE FALSOS EN SUCURSAL',
'DESCRIPCION:SPL Intermedio que actualiza el registro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consulta_catdenominacion_bym(pUsuario CHAR(8), pIdFuncion CHAR(10),pOpcion CHAR(1), pDato CHAR(1))
    RETURNING CHAR(5) AS codret,
		INTEGER  AS IdDenominacion,
		CHAR(1)  AS CvePieza,
		CHAR(7)  AS TipoPieza,
		CHAR(10) AS Denominacion;
		
	DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
    DEFINE iCodRetSp INTEGER;
    
	DEFINE iIdDenominacion INTEGER;
	DEFINE cCvePieza       CHAR(1);
	DEFINE cTipoPieza      CHAR(7);
	DEFINE cDenominacion   CHAR(10);
	DEFINE iRecuperacion INTEGER;
        
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '000000';
    LET iCodRetSp = 0;
    LET iIdDenominacion=0;
	LET cCvePieza     =''; 
	LET cTipoPieza    =''; 
	LET cDenominacion =''; 
	LET iRecuperacion = 0;
   	
	BEGIN
     
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdDenominacion, cCvePieza,cTipoPieza,cDenominacion;
		END EXCEPTION;
      
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consulta_catdenominacion_bym.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pOpcion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdDenominacion, cCvePieza,cTipoPieza,cDenominacion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdDenominacion, cCvePieza,cTipoPieza,cDenominacion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		FOREACH
            EXECUTE PROCEDURE bdisuc:"informix".sp_consulta_catdenominacion_bym(pOpcion, pDato)  
            INTO cCodRetSp, iIdDenominacion, cCvePieza,cTipoPieza,cDenominacion
			
            LET iCodRetSp = cCodRetSp::INTEGER;
            IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_consulta_catdenominacion_bym';
            ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
            ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00017';
            END IF;
            
			LET iRecuperacion = iRecuperacion + 1;
            RETURN cCodRet, iIdDenominacion, cCvePieza,cTipoPieza,cDenominacion WITH RESUME;
        END FOREACH;
		
		LET iRecuperacion = DBINFO('sqlca.sqlerrd2');
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdDenominacion, cCvePieza,cTipoPieza,cDenominacion;
		END IF;
		
    END; 
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 22/12/2016',
'MODULO: CAJA GENERAL ',
'FUNCIONALIDAD: BILLETES PRESUNTAMENTE FALSOS EN SUCURSAL',
'DESCRIPCION:SPL Intermedio que consulta el catalogo de Denominaciones',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultacat_estatus_bym(pUsuario CHAR(8), pIdFuncion CHAR(10),pOpcion CHAR(1), pDato INTEGER)
	RETURNING CHAR(5) AS codret,
        INTEGER AS cve_Dictamen,
		CHAR(20) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
    DEFINE iCodRetSp INTEGER;
    DEFINE cMensaje CHAR(80);
    DEFINE iCveEstatus INTEGER;
    DEFINE cDescripcion CHAR(20);      
    DEFINE iRecuperacion INTEGER;
        
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '000000';
    LET iCodRetSp = 0;
    LET cMensaje = '';
    LET iCveEstatus = 0;
    LET cDescripcion = '';
    LET iRecuperacion = 0;
   	
	BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iCveEstatus, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultacat_estatus_bym.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pOpcion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iCveEstatus, cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN  cCodRet, iCveEstatus, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
            EXECUTE PROCEDURE bdisuc:"informix".sp_consultacat_estatus_bym(pOpcion, pDato)  
            INTO cCodRetSp, cMensaje, iCveEstatus, cDescripcion
			
            LET iCodRetSp = cCodRetSp::INTEGER;
            IF iCodRetSp < 0 THEN
                    RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_consultacat_estatus_bym';
            ELIF cCodRetSp::INTEGER = 1 THEN
                    LET cCodRet = '00003';
            ELIF cCodRetSp::INTEGER = 2 THEN
                    LET cCodRet = '00017';
            END IF;
            
			LET iRecuperacion = iRecuperacion + 1;
            RETURN cCodRet, iCveEstatus,  UPPER(TRIM(cDescripcion)) WITH RESUME;           
        END FOREACH;
		
		LET iRecuperacion = DBINFO('sqlca.sqlerrd2');
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iCveEstatus, cDescripcion;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 14/12/2016',
'MODULO: CAJA GENERAL ',
'FUNCIONALIDAD: BILLETES PRESUNTAMENTE FALSOS EN SUCURSAL',
'DESCRIPCION:SPL Intermedio que consulta el catalogo de Estatus(ss_cat_estatus_bym_falsos)',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultadatospiezas_bym_totales(pUsuario CHAR(8), pIdFuncion CHAR(10),pFechaCaptura DATE, pFechaIni DATE, pFechaFin DATE, pSucursal CHAR(4), pNumRecibo CHAR(10), pNumGuia CHAR(12), pEstatus INTEGER, pDictamen INTEGER, pTipoConsulta INTEGER)
       RETURNING  	CHAR(5) 	AS CodRet,
	   INTEGER     AS total;
	
	DEFINE iSqlErr               INTEGER;
	DEFINE iSamErr               INTEGER;
	DEFINE cDesErr               CHAR(80);
	DEFINE cCodRet               CHAR(5);
	DEFINE cCodRetSp 			 CHAR(6);
	DEFINE cMensaje              CHAR(80);
	DEFINE iRecuperacion 		 INTEGER;
	DEFINE iCvePieza             INTEGER;
	DEFINE dFechaCaptura         DATE;
	DEFINE cNumRecibo            CHAR(10);
	DEFINE iNumPiezas            INTEGER;
	DEFINE cTipoPieza            CHAR(1);
	DEFINE cDenominacion         CHAR(10);
	DEFINE iCveDenominacion      INTEGER;
	DEFINE cSerie                CHAR(40);
	DEFINE cFolio                CHAR(40);
	DEFINE dFechaEmision         DATE;
	DEFINE cNota                 CHAR(200);
	DEFINE cEstatus              CHAR(20);
	DEFINE cDictamenBanxico      CHAR(20);
	DEFINE cNumLoteBanxico       CHAR(40);
	DEFINE cFolioBanxico         CHAR(40);
	DEFINE dFechaPago            DATE;
	DEFINE cFormaPago            CHAR(20);
	DEFINE cNumCta               CHAR(11);
	DEFINE cNumSuc               CHAR(4);
	DEFINE cNombreSuc            CHAR(40);
	DEFINE cDomSuc               CHAR(80);
	DEFINE cNomOperador          CHAR(45);
	DEFINE cApellidoTenedor1     CHAR(40);
	DEFINE cApellidoTenedor2     CHAR(40);
	DEFINE cNomTenedor1          CHAR(40);
	DEFINE cNomTenedor2          CHAR(40);
	DEFINE cIdentificacion       CHAR(50);
	DEFINE cNumIdentificacion    CHAR(40);
	DEFINE cCalle                CHAR(30);
	DEFINE cNumCasa              CHAR(10);
	DEFINE cColonia              CHAR(32);
	DEFINE cDelegacion           CHAR(60);
	DEFINE cCodPostal            CHAR(5);
	DEFINE cCiudad               CHAR(60);
	DEFINE cEstado               CHAR(2);
	DEFINE cTelefono             CHAR(13);
	DEFINE cEmail                CHAR(30); 
	DEFINE dFechaInicio          DATE;
	DEFINE dFechaFin             DATE;
	DEFINE cNumReciboCon         CHAR(10);
	DEFINE iIdTenedor            INTEGER;
	DEFINE cNumSucursalReten     CHAR(4);
	DEFINE cNombre1              CHAR(40);
	DEFINE cNombre2              CHAR(40);
	DEFINE cApPaterno            CHAR(40);
	DEFINE cApMaterno            CHAR(40);
	DEFINE cCalleCon             CHAR(40);
	DEFINE cNumeroCalle          CHAR(10);
	DEFINE cColoniaCon           CHAR(6);
	DEFINE cDelegacionPoblacion  CHAR(3);
	DEFINE cCodPostalCon         CHAR(5);
	DEFINE cCiudadCon            CHAR(3);
	DEFINE cEstadoCon            CHAR(2);
	DEFINE cTelefonoCon          CHAR(13);
	DEFINE cEmailCon             CHAR(30);
	DEFINE cEjecutivoInsert      CHAR(8);
	DEFINE cIdentificacionCon    CHAR(20);
	DEFINE cIdentificacionDes    CHAR(50);
	DEFINE cNumIdentificacionCon CHAR(40);
	DEFINE cIdPieza              INTEGER;
	DEFINE dFechaRecepcion       DATE;
	DEFINE iIdDenominacion       INTEGER;
	DEFINE cSerieCon             CHAR(40);
	DEFINE cFolioCon             CHAR(40);
	DEFINE dFechaEmisionCon      DATE;
	DEFINE iNumPiezasCon         INTEGER;
	DEFINE cNotaCon              CHAR(200);
	DEFINE cFolioBanxicoCon      CHAR(40);
	DEFINE iDictamenBanxico      INTEGER;
	DEFINE cNumLoteBanxicoCon    CHAR(40);
	DEFINE dFechaPagoCon         DATE;
	DEFINE iTipoPago             INTEGER;
	DEFINE cNumCtaCliente        CHAR(11);
	DEFINE iEstatus              INTEGER;
	DEFINE dFechaInsert          DATE;
	DEFINE cNombreScucursal      CHAR(40);
	DEFINE cDireccion1           CHAR(40);
	DEFINE cNombreOperador       CHAR(45);
	DEFINE cDesCvePieza          CHAR(1); 
	DEFINE cDenominacionCon      CHAR(10);
	DEFINE cDesDictamen          CHAR(20);  
	DEFINE cDesTipoPago          CHAR(20);
	DEFINE cDesEstatus           CHAR(20);
	DEFINE cCodigo               CHAR(3);
	DEFINE cPromotor             CHAR(8);
	DEFINE cCiudadoDelegacion    CHAR(3);
	DEFINE cCiudadoCoppel        INTEGER;
	DEFINE cNombreCidDel         CHAR(60);
	DEFINE cNombreCol		     CHAR(32);
	DEFINE cNombreCalle          CHAR(30);	
	DEFINE cNombreCiudad         CHAR(60);
	DEFINE cNombreDelegacion     CHAR(60);
	DEFINE cEstadoDes            CHAR(30);
	DEFINE cEstadoDesRes         CHAR(30);
	DEFINE cEstadoBanxico        CHAR(3);
	DEFINE iRegistros2 			 INTEGER;
	DEFINE iTermino 			 INTEGER;
	DEFINE cEmpresa 			 CHAR(3);
	DEFINE dFechaHoy 			 DATE;
	DEFINE iNoRegistros			 INTEGER;

	LET cEmpresa 				='001';
	LET iNoRegistros			= 0;
	LET dFechaHoy               = DATE(CURRENT);

	LET iSqlErr                 = 0;
	LET iSamErr                 = 0;
	LET cDesErr                 = '';
	LET cCodRet                 = '00000';
	LET cCodRetSp				= '000000';
	LET cMensaje                = '';
	LET iRecuperacion			= 0;
	LET iCvePieza               = 0;
	LET dFechaCaptura           = DATE(1);
	LET cNumRecibo              = '';
	LET iNumPiezas              = 0;
	LET cTipoPieza              = '';
	LET cDenominacion           = '';
	LET iCveDenominacion        = 0;  
	LET cSerie                  = '';
	LET cFolio                  = '';
	LET dFechaEmision           = DATE(1);
	LET cNota                   = '';
	LET cEstatus                = '';  
	LET cDictamenBanxico        = '';  
	LET cNumLoteBanxico         = '';
	LET cFolioBanxico           = '';
	LET dFechaPago              = DATE(1);
	LET cFormaPago              = ''; 
	LET cNumCta                 = '';
	LET cNumSuc                 = '';
	LET cNombreSuc              = '';
	LET cDomSuc                 = ''; 
	LET cNomOperador            = '';
	LET cApellidoTenedor1       = ''; 
	LET cApellidoTenedor2       = '';                                                                                                                               
	LET cNomTenedor1            = '';
	LET cNomTenedor2            = '';
	LET cIdentificacion         = '';
	LET cNumIdentificacion      = ''; 
	LET cCalle                  = '';
	LET cNumCasa                = '';                                             
	LET cColonia                = '';
	LET cDelegacion             = '';
	LET cCodPostal              = '';
	LET cCiudad                 = '';
	LET cEstado                 = '';
	LET cTelefono               = '';
	LET cEmail                  = '';
	LET cPromotor               = '';
	LET cEstadoDesRes           = '';       
	LET iRegistros2 			= 0;
	LET iTermino 				= 0;
	LET iNoRegistros			= 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultadatospiezas_bym_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pTipoConsulta IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		IF pTipoConsulta = 0 THEN	--LLENA TABLA DE GRID PRINCIPAL
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;

			DELETE {+INDEX (bdicnweb:sw_cg_billetesfalsos idx_sw_cg_billetesfalsos)}  FROM "informix".sw_cg_billetesfalsos WHERE us_insert = TRIM(pUsuario);
			
			DELETE {+INDEX (bdicnweb:sw_cg_validaestatusbf idx_sw_cg_validaestatusbf)}  FROM bdicnweb:"informix".sw_cg_validaestatusbf WHERE usuario_inserta = pUsuario;
	
			INSERT INTO bdicnweb:"informix".sw_cg_validaestatusbf(id_status, desc_status, usuario_inserta, fecha)
			VALUES ('I', 'INICIA_PROCESO', pUsuario, CURRENT);
	
			FOREACH 
				EXECUTE PROCEDURE bdisuc:"informix".sp_consultadatospiezas_bym2(pFechaCaptura, pFechaIni, pFechaFin, pSucursal, pNumRecibo, pNumGuia, pEstatus, pDictamen, cEmpresa)
				INTO cCodRetSp, cMensaje, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes,iRegistros2, iTermino

				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_consultadatospiezas_bym2';
				ELIF cCodRetSp::INTEGER = 1 THEN
					UPDATE {+INDEX (bdicnweb:sw_cg_validaestatusbf idx_sw_cg_validaestatusbf)}  bdicnweb:"informix".sw_cg_validaestatusbf
					SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
					WHERE usuario_inserta = pUsuario;
		
					LET cCodRet = '00003';
					RETURN cCodRet,iNoRegistros;
				ELIF cCodRetSp::INTEGER = 2 THEN
					UPDATE {+INDEX (bdicnweb:sw_cg_validaestatusbf idx_sw_cg_validaestatusbf)}  bdicnweb:"informix".sw_cg_validaestatusbf
					SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
					WHERE usuario_inserta = pUsuario;
								
					LET cCodRet = '00017';
					RETURN cCodRet,iNoRegistros;
				ELIF cCodRetSp::INTEGER = 0 THEN
					LET iRecuperacion = iRecuperacion + 1;
					INSERT INTO "informix".sw_cg_billetesfalsos(id_serial, cve_pieza, fecha_captura,num_recibo, num_piezas, tipo_pieza, denominacion,cve_denominacion,serie, folio, fecha_emision,nota,
					estatus,dictamen_banxico,num_lote_banxico, folio_banxico, fecha_pago, forma_pago, num_cta, num_suc, nombre_suc,dom_suc, nom_operador,apellido_tenedor1,apellido_tenedor2,
					nom_tenedor1,  nom_tenedor2, identificacion,num_identificacion,calle, numcasa,colonia, delegacion,codpostal, ciudad, estado, telefono,email,operador,estado_desc,us_insert,fecha_insert) VALUES 
					(iRecuperacion,iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes, pUsuario,dFechaHoy);
				END IF;
			END FOREACH;
			
			SELECT COUNT(*) INTO iNoRegistros
			FROM "informix".sw_cg_billetesfalsos
			WHERE us_insert = TRIM(pUsuario);
			
			UPDATE {+INDEX (bdicnweb:sw_cg_validaestatusbf idx_sw_cg_validaestatusbf)}  bdicnweb:"informix".sw_cg_validaestatusbf
			SET id_status = 'F', desc_status = 'FINALIZA_PROCESO'
			WHERE usuario_inserta = pUsuario;				
		
		ELIF pTipoConsulta = 1 THEN	 --GRID PRINCIPAL
			
			SELECT {+INDEX (bdicnweb:sw_cg_billetesfalsos idx_sw_cg_billetesfalsos)}  COUNT(*) INTO iNoRegistros
			FROM "informix".sw_cg_billetesfalsos
			WHERE us_insert = TRIM(pUsuario);

		ELIF pTipoConsulta = 2 THEN	 --GRID REPORTE

			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			EXECUTE PROCEDURE bdisuc:"informix".sp_consultadatospiezas_bym3_totales(pFechaCaptura, pFechaIni, pFechaFin, pSucursal, pNumRecibo, pNumGuia, pEstatus, pDictamen, cEmpresa)
			INTO cCodRetSp, iNoRegistros;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_consultadatospiezas_bym3_totales';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 2 THEN		
				LET cCodRet = '00017';
			END IF;
		
	    END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;

		RETURN cCodRet,iNoRegistros; 
    
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 15/12/2016',
'MODULO: CAJA GENERAL ',
'FUNCIONALIDAD: BILLETES PRESUNTAMENTE FALSOS EN SUCURSAL',
'DESCRIPCION:SPL Intermedio que obtiene el total de los registros para el llenado de grid',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultastatusprocesobf(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		CHAR(1) AS id_status,
		CHAR(30) AS desc_status;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdStatus CHAR(1);
	DEFINE cDescStatus CHAR(30);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdStatus = '';
	LET cDescStatus = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdStatus, cDescStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultastatusprocesobf.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 10;
		
		SELECT {+INDEX (bdicnweb:sw_cg_validaestatusbf idx_sw_cg_validaestatusbf)}  id_status, desc_status
		INTO cIdStatus, cDescStatus
		FROM "informix".sw_cg_validaestatusbf
		WHERE usuario_inserta = pUsuario;
			
		IF cIdStatus  = '' THEN
			RETURN cCodRet, 'I', 'INICIA_PROCESO';
		ELSE 
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 03/01/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: Caja Gral Billetes Falsos',
'DESCRIPCION: SPL que realiza la consulta de los estatus para monitorear el proceso del spl de sp_cg_consultadatospiezas_bym_totales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consutacat_dictamen_bym(pUsuario CHAR(8), pIdFuncion CHAR(10),pOpcion CHAR(1), pDato INTEGER)
        RETURNING CHAR(5) AS codret,
        INTEGER AS cve_Dictamen,
		CHAR(20) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
    DEFINE iCodRetSp INTEGER;
    DEFINE cMensaje CHAR(80);
    DEFINE iCveDictamen INTEGER;
    DEFINE cDescripcion CHAR(20);      
    DEFINE iRecuperacion INTEGER;
        
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '000000';
    LET iCodRetSp = 0;
    LET cMensaje = '';
    LET iCveDictamen = 0;
    LET cDescripcion = '';
    LET iRecuperacion = 0;
   	
	BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iCveDictamen, cDescripcion;
		END EXCEPTION;
        
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consutacat_dictamen_bym.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pOpcion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iCveDictamen, cDescripcion;
		END IF;
        
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN  cCodRet, iCveDictamen, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
            EXECUTE PROCEDURE bdisuc:"informix".sp_consutacat_dictamen_bym(pOpcion, pDato)  
            INTO cCodRetSp, cMensaje, iCveDictamen, cDescripcion
			
            LET iCodRetSp = cCodRetSp::INTEGER;
            IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_consutacat_dictamen_bym';
            ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
            ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00017';
            END IF;
            
			LET iRecuperacion = iRecuperacion + 1;
            RETURN cCodRet, iCveDictamen,  UPPER(TRIM(cDescripcion)) WITH RESUME;           
        END FOREACH;
		
		LET iRecuperacion = DBINFO('sqlca.sqlerrd2');
		
		IF iRecuperacion = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iCveDictamen, cDescripcion;
		END IF;
		
    END;  
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 14/12/2016',
'MODULO: CAJA GENERAL ',
'FUNCIONALIDAD: BILLETES PRESUNTAMENTE FALSOS EN SUCURSAL',
'DESCRIPCION:SPL Intermedio que consulta el catalogo de Dictamenes(ss_cat_dictamen_bym_falsos)',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_genera_archivo_bym(pUsuario CHAR(8), pIdFuncion CHAR(10),pOpcion CHAR(1), pRuta CHAR(100))
    RETURNING CHAR(5) AS codret,
        CHAR(100) AS ruta,
		CHAR(30)  AS nombreArchivo;
		
	DEFINE cCodRet   CHAR(5);
    DEFINE iSqlErr   INTEGER;
    DEFINE iCodRetSp INTEGER;
    DEFINE iRecuperacion INTEGER;
	DEFINE cNombreArchivo CHAR(30);
	DEFINE cCmd1 CHAR(2500);
    DEFINE cSql    CHAR(2500);
	DEFINE pRutaGra CHAR(100);
	DEFINE cDelFile CHAR(200);
	DEFINE cFolio INTEGER;
	
	DEFINE bInTransaction BOOLEAN; --
	DEFINE ven_transacc SMALLINT; --
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET iCodRetSp = 0;
    LET iRecuperacion = 0;
	LET cNombreArchivo   ='';
   	LET cCmd1='';
	LET cSql='';
	LET pRutaGra='';
	LET cDelFile='';
	LET cFolio=0;
	
	LET bInTransaction = 'f'; --
	LET ven_transacc = 0; --
	
	BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			
			IF ven_transacc = 1 THEN
				ROLLBACK WORK; --		
			END IF;
			
			RETURN cCodRet, pRuta, cNombreArchivo;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
  
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_genera_archivo_bym.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pOpcion = '' OR (pOpcion =1 AND pRuta='') THEN
			LET cCodRet = '00003';
			RETURN cCodRet, pRuta, cNombreArchivo;
		END IF;
 
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN  cCodRet, pRuta, cNombreArchivo;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF pOpcion = 0 THEN --limpiar selecccion
		
			UPDATE {+INDEX (bdicnweb:sw_cg_billetesfalsos idx_sw_cg_billetesfalsos)} "informix".sw_cg_billetesfalsos SET
			indicador=0
			WHERE us_insert = TRIM(pUsuario);
			
			RETURN  cCodRet, pRuta, cNombreArchivo;
			
		ELIF pOpcion = 1 THEN --genera archivo
		
			BEGIN WORK;
				LET ven_transacc = 1;
			
				LET cNombreArchivo   ='ArchivoBanxicoBilletes.txt';
				LET pRutaGra = TRIM(pRuta)||TRIM(cNombreArchivo);
				
				LET cCmd1 ="  "|| "SELECT '40137'||LPAD(day(fecha_captura),2,'0')||LPAD( month(fecha_captura),2,'0' )||year(fecha_captura)||RPAD(num_suc,8)|| 'F'||";
				LET cCmd1 =""||TRIM(cCmd1)||"RPAD((RTRIM(NVL(nom_tenedor1,'')) ||' '|| RTRIM(NVL(nom_tenedor2,'')) ),'70',' ')||RPAD(NVL(apellido_tenedor1,''),30)||";
				LET cCmd1 =""||TRIM(cCmd1)||"RPAD(NVL(apellido_tenedor2,''),30)||RPAD( (RTRIM(NVL(calle,''))||' '||RTRIM(NVL(numcasa,''))), 40)||";
				LET cCmd1 =""||TRIM(cCmd1)||"RPAD(NVL(colonia,''),30)||RPAD(NVL(delegacion,''),30)||LPAD(NVL(estado,''),2)||RPAD(NVL(ciudad,''),30)||";
				LET cCmd1 =""||TRIM(cCmd1)||"RPAD(NVL(codpostal,''),5)||RPAD((RTRIM(NVL(nom_operador,''))||' '||RTRIM(NVL(operador,''))),80)||RPAD(NVL(tipo_pieza,''),1)|| ''||";
				LET cCmd1 =""||TRIM(cCmd1)||"RPAD(NVL('1',''),1)||LPAD(denominacion::DECIMAL(6,2),8,'0')||LPAD(NVL(num_piezas,'')::CHAR,5,'0')||";
				LET cCmd1 =""||TRIM(cCmd1)||"LPAD(day(fecha_emision),2,'0')||LPAD( month(fecha_emision),2,'0' )||year(fecha_emision)||RPAD(NVL(serie,''),14)||";
				LET cCmd1 =""||TRIM(cCmd1)||"RPAD(NVL(folio,''),20)||RPAD(NVL(nota,''),278)||'*'||LPAD(NVL(num_recibo,''),11,0)";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:sw_cg_billetesfalsos WHERE indicador='1' AND us_insert="||pUsuario;
				
				LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(pRutaGra)||' '||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query07.sql';
				SYSTEM TRIM(cSql);
			
				LET cDelFile = '/usr/bin/chmod 777 '||TRIM(pRuta)||'query07.sql';
				SYSTEM TRIM(cDelFile);
				
				LET cSql = '';
				LET cSql = '/informix/bin/dbaccess sysmaster '||TRIM(pRuta)||'query07.sql';
				--COMMIT WORK;
				SYSTEM TRIM(cSql);  
				--BEGIN WORK;
			
				LET cSql = '';
				LET cSql = 'rm -rf '||TRIM(pRuta)||'query07.sql';
				SYSTEM TRIM(cSql);
				
				LET cSql= "sed 's/|$//g;/^$/d' " ||  TRIM(pRuta) ||  cNombreArchivo || " > " || TRIM(pRuta) || TRIM(cNombreArchivo)||'2.txt';
				SYSTEM TRIM(cSql);
				
				LET cDelFile = '/usr/bin/chmod 777 '||TRIM(pRuta) || TRIM(cNombreArchivo)||'2.txt';
				SYSTEM TRIM(cDelFile);
				
				SYSTEM "sed "||"'s/$'""/`/usr/bin/echo \\\r`/"" "|| TRIM(pRuta) || TRIM(cNombreArchivo)||'2.txt'||" > "||TRIM(pRuta) || TRIM(cNombreArchivo)||'3.txt';
				
				LET cDelFile = '/usr/bin/chmod 777 '||TRIM(pRuta) || TRIM(cNombreArchivo)||'3.txt';
				SYSTEM TRIM(cDelFile);
				
				-- Eliminamos el archivo original
				SYSTEM "rm -rf "||TRIM(pRutaGra);
				SYSTEM "rm -rf "||TRIM(pRuta) || TRIM(cNombreArchivo)||'2.txt';
				
				-- Se renombra el archivo temporal por el nombre original
				SYSTEM "mv "|| TRIM(pRuta)||TRIM(cNombreArchivo)||"3.txt "||TRIM(pRutaGra);
			
			COMMIT WORK;
			
			LET ven_transacc = 0;
			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;
			
			RETURN  cCodRet, pRuta, cNombreArchivo;
			
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 23/12/2016',
'MODULO: CAJA GENERAL ',
'FUNCIONALIDAD: BILLETES PRESUNTAMENTE FALSOS EN SUCURSAL',
'DESCRIPCION: SPL Intermedio que actualiza el campo indicador para generar el archivo',
'AUTOR: L. Montserrat León Amador',
'FECHA: 27/02/2017',
'DESCRIPCION: Se modifica SPL para dar tratado a transacciones y asignación de permisos a los archivos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ca_cargaarchivoxml(pUsuario CHAR(8), pIdFuncion CHAR(10), pRutaCarga CHAR(100), pArchivoProcesar CHAR(100))
	RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCmd CHAR(2000);
	DEFINE cArchivoTmp CHAR(250);
	DEFINE cScriptCarga CHAR(250);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cNombreArchivoTmp CHAR(50);
	DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd = '';
	LET cArchivoTmp = TRIM(pArchivoProcesar)||'.tmp';
	LET cScriptCarga = '';
	LET cRutaInformix = '/ifxsif01/bin/';
	--LET cRutaInformix = '/informix/bin/';
	LET cNombreArchivoTmp = 'scriptofixml'||TO_CHAR(CURRENT, '%Y%m%d%H%M%S')||'.sql';
	LET bInTransaction = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668,-535,-255)
			LET bInTransaction = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ca_cargaarchivoxml.out';
		--TRACE ON;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRutaCarga = '' OR pArchivoProcesar = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		BEGIN WORK;
		IF bInTransaction = 'f' THEN
			COMMIT WORK;
		END IF;
		
		-- Se convierte el archivo de FORMATO UTF-8 a IBM-1252
		LET cCmd = "iconv -s -f UTF-8 -t IBM-1252 "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||" > "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.iconv';
		SYSTEM TRIM(cCmd);
		
		LET cCmd = "/usr/bin/mv "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.iconv '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar);
		SYSTEM TRIM(cCmd);
		
		LET cCmd = "/usr/bin/rm -rf "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.iconv';
		SYSTEM TRIM(cCmd);
		
		-- Se eliminan tags innecesarios
		LET cCmd = "sed '/<?xml/d' "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||" | awk '{if($1 ~ /<Expediente/) $1 = ""<Expediente>""; print $0}' | awk '{if($2 ~ /xmlns/) $2 = """"; print $0}' | awk '{if($2 ~ /xmlns/) $2 = """"; print $0}' | awk '{if($2 ~ /xmlns/) $2 = """"; print $0}' | awk '{if($2 ~ /xsi/) $2 = """"; print $0}' > "||TRIM(pRutaCarga)||TRIM(cArchivoTmp);
		SYSTEM TRIM(cCmd);
		
		-- Eliminamos el archivo pivote
		LET cCmd = '/usr/bin/rm -rf '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'; /usr/bin/mv '||TRIM(pRutaCarga)||TRIM(cArchivoTmp)||' '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar);
		SYSTEM TRIM(cCmd);
		
		-- Se eliminan caracteres de retorno de carro (DOS)
		LET cCmd = '/usr/bin/tr "\r" " " < '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||' > '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.tr';
		SYSTEM TRIM(cCmd);
		
		LET cCmd = "/usr/bin/rm -rf "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'; /usr/bin/mv '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.tr '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar);
		SYSTEM TRIM(cCmd);
		
		-- Se eliminan caracteres de tabuladores
		LET cCmd = '/usr/bin/tr "\t" " " < '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||' > '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.tr';
		SYSTEM TRIM(cCmd);
		
		LET cCmd = "/usr/bin/rm -rf "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'; /usr/bin/mv '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.tr '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar);
		SYSTEM TRIM(cCmd);
		
		LET cScriptCarga = "echo 'LOAD FROM "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||" INSERT INTO bdicnweb:""informix"".sw_ca_archivoxml_tmp(xmlfile_data);' > "||TRIM(pRutaCarga)||TRIM(cNombreArchivoTmp);
		SYSTEM TRIM(cScriptCarga);
				
		DELETE FROM bdicnweb:"informix".sw_ca_archivoxml_tmp;	
		
		LET cCmd = TRIM(cRutaInformix)||'dbaccess bdicnweb < '||TRIM(pRutaCarga)||TRIM(cNombreArchivoTmp);
		SYSTEM TRIM(cCmd);
		
		UPDATE STATISTICS MEDIUM FOR TABLE bdicnweb:"informix".sw_ca_archivoxml_tmp;
		
		LET cCmd = '/usr/bin/rm -rf '||TRIM(pRutaCarga)||TRIM(cNombreArchivoTmp);
		SYSTEM TRIM(cCmd);
		
		-- SE ELIMINA EL ARCHIVO ORIGINAL
		--LET cCmd = '/usr/bin/rm -rf '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar);
		--SYSTEM TRIM(cCmd);
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 21/11/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CARGA AUTOMÁTICA DE ARCHIVOS XML', 
'DESCRIPCION: SPL encargado de hacer la limpieza del archivo xml, para que posteriormente sea cargado en la tabla bdicnweb:sw_ca_archivoxml_tmp.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 28/06/2018',
'DESCRIPCION: Se coloca tratado para el código de error -668.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultadatospiezas_bym(pUsuario CHAR(8), pIdFuncion CHAR(10),pFechaCaptura DATE, pFechaIni DATE, pFechaFin DATE, pSucursal CHAR(4), pNumRecibo CHAR(10), pNumGuia CHAR(12), pEstatus INTEGER, pDictamen INTEGER, pTipoConsulta INTEGER, pRegistros INTEGER,pRecuperacion INTEGER)
    RETURNING CHAR(5) AS CodRet,
		INTEGER 	AS CvePieza,
		DATE 		AS FechaCaptura,
		CHAR(10) 	AS NumRecibo,
		INTEGER 	AS NumPiezas,
		CHAR(1) 	AS TipoPieza,
		CHAR(10) 	AS Denominacion,
		INTEGER 	AS CveDenominacion,
		CHAR(40) 	AS Serie,
		CHAR(40) 	AS Folio,
		DATE 		AS FechaEmision,
		CHAR(200) 	AS Nota,
		CHAR(20) 	AS Estatus,
		CHAR(20) 	AS DictamenBanxico,
		CHAR(40) 	AS NumLoteBanxico,
		CHAR(40) 	AS FolioBanxico,
		DATE 		AS FechaPago,
		CHAR(20) 	AS FormaPago,
		CHAR(11) 	AS NumCta,
		CHAR(4) 	AS NumSuc,
		CHAR(40) 	AS NombreSuc,
		CHAR(80) 	AS DomSuc,
		CHAR(45) 	AS NomOperador,
		CHAR(40) 	AS ApellidoTenedor1,
		CHAR(40) 	AS ApellidoTenedor2,
		CHAR(40) 	AS NomTenedor1,
		CHAR(40) 	AS NomTenedor2,
		CHAR(50) 	AS Identificacion,
		CHAR(40) 	AS NumIdentificacion,
		CHAR(30) 	AS Calle,
		CHAR(10) 	AS NumCasa,
		CHAR(32) 	AS Colonia,
		CHAR(60) 	AS Delegacion,
		CHAR(5) 	AS CodPostal,
		CHAR(60) 	AS Ciudad,
		CHAR(2) 	AS Estado,
		CHAR(13) 	AS Telefono,
		CHAR(30) 	AS Email,
		CHAR(8)     AS Operador,
		CHAR(30)    AS EstadoDesc;
			
	DEFINE iSqlErr               INTEGER;
	DEFINE iSamErr               INTEGER;
	DEFINE cDesErr               CHAR(80);
	DEFINE cCodRet               CHAR(5);
	DEFINE cCodRetSp 			 CHAR(6);
	DEFINE cMensaje              CHAR(80);
	DEFINE iRecuperacion 		 INTEGER;
	DEFINE iCvePieza             INTEGER;
	DEFINE dFechaCaptura         DATE;
	DEFINE cNumRecibo            CHAR(10);
	DEFINE iNumPiezas            INTEGER;
	DEFINE cTipoPieza            CHAR(1);
	DEFINE cDenominacion         CHAR(10);
	DEFINE iCveDenominacion      INTEGER;
	DEFINE cSerie                CHAR(40);
	DEFINE cFolio                CHAR(40);
	DEFINE dFechaEmision         DATE;
	DEFINE cNota                 CHAR(200);
	DEFINE cEstatus              CHAR(20);
	DEFINE cDictamenBanxico      CHAR(20);
	DEFINE cNumLoteBanxico       CHAR(40);
	DEFINE cFolioBanxico         CHAR(40);
	DEFINE dFechaPago            DATE;
	DEFINE cFormaPago            CHAR(20);
	DEFINE cNumCta               CHAR(11);
	DEFINE cNumSuc               CHAR(4);
	DEFINE cNombreSuc            CHAR(40);
	DEFINE cDomSuc               CHAR(80);
	DEFINE cNomOperador          CHAR(45);
	DEFINE cApellidoTenedor1     CHAR(40);
	DEFINE cApellidoTenedor2     CHAR(40);
	DEFINE cNomTenedor1          CHAR(40);
	DEFINE cNomTenedor2          CHAR(40);
	DEFINE cIdentificacion       CHAR(50);
	DEFINE cNumIdentificacion    CHAR(40);
	DEFINE cCalle                CHAR(30);
	DEFINE cNumCasa              CHAR(10);
	DEFINE cColonia              CHAR(32);
	DEFINE cDelegacion           CHAR(60);
	DEFINE cCodPostal            CHAR(5);
	DEFINE cCiudad               CHAR(60);
	DEFINE cEstado               CHAR(2);
	DEFINE cTelefono             CHAR(13);
	DEFINE cEmail                CHAR(30); 

	DEFINE dFechaInicio          DATE;
	DEFINE dFechaFin             DATE;
	DEFINE iBandFecha            INTEGER;
	DEFINE iBandInicio           INTEGER;
	DEFINE iBandRegistros        INTEGER;
	DEFINE iRegistros            INTEGER;
	DEFINE iRegCon               INTEGER;
	DEFINE iContador             INTEGER;
	DEFINE iTermino              INTEGER;
	DEFINE cNumReciboCon         CHAR(10);
	DEFINE iIdTenedor            INTEGER;
	DEFINE cNumSucursalReten     CHAR(4);
	DEFINE cNombre1              CHAR(40);
	DEFINE cNombre2              CHAR(40);
	DEFINE cApPaterno            CHAR(40);
	DEFINE cApMaterno            CHAR(40);
	DEFINE cCalleCon             CHAR(40);
	DEFINE cNumeroCalle          CHAR(10);
	DEFINE cColoniaCon           CHAR(6);
	DEFINE cDelegacionPoblacion  CHAR(3);
	DEFINE cCodPostalCon         CHAR(5);
	DEFINE cCiudadCon            CHAR(3);
	DEFINE cEstadoCon            CHAR(2);
	DEFINE cTelefonoCon          CHAR(13);
	DEFINE cEmailCon             CHAR(30);
	DEFINE cEjecutivoInsert      CHAR(8);
	DEFINE cIdentificacionCon    CHAR(20);
	DEFINE cIdentificacionDes    CHAR(50);
	DEFINE cNumIdentificacionCon CHAR(40);
	DEFINE cIdPieza              INTEGER;
	DEFINE dFechaRecepcion       DATE;
	DEFINE iIdDenominacion       INTEGER;
	DEFINE cSerieCon             CHAR(40);
	DEFINE cFolioCon             CHAR(40);
	DEFINE dFechaEmisionCon      DATE;
	DEFINE iNumPiezasCon         INTEGER;
	DEFINE cNotaCon              CHAR(200);
	DEFINE cFolioBanxicoCon      CHAR(40);
	DEFINE iDictamenBanxico      INTEGER;
	DEFINE cNumLoteBanxicoCon    CHAR(40);
	DEFINE dFechaPagoCon         DATE;
	DEFINE iTipoPago             INTEGER;
	DEFINE cNumCtaCliente        CHAR(11);
	DEFINE iEstatus              INTEGER;
	DEFINE dFechaInsert          DATE;
	DEFINE cNombreScucursal      CHAR(40);
	DEFINE cDireccion1           CHAR(40);
	DEFINE cNombreOperador       CHAR(45);
	DEFINE cDesCvePieza          CHAR(1); 
	DEFINE cDenominacionCon      CHAR(10);
	DEFINE cDesDictamen          CHAR(20);  
	DEFINE cDesTipoPago          CHAR(20);
	DEFINE cDesEstatus           CHAR(20);
	DEFINE cCodigo               CHAR(3);
	DEFINE cPromotor             CHAR(8);
	DEFINE cCiudadoDelegacion    CHAR(3);
	DEFINE cCiudadoCoppel        INTEGER;
	DEFINE cNombreCidDel         CHAR(60);
	DEFINE cNombreCol		     CHAR(32);
	DEFINE cNombreCalle          CHAR(30);	
	DEFINE cNombreCiudad         CHAR(60);
	DEFINE cNombreDelegacion     CHAR(60);
	DEFINE cEstadoDes            CHAR(30);
	DEFINE cEstadoDesRes         CHAR(30);
	DEFINE cEstadoBanxico        CHAR(3);
	DEFINE cEmpresa 			 CHAR(3);
	DEFINE dFechaHoy 			 DATE;

	LET iSqlErr                 = 0;
	LET iSamErr                 = 0;
	LET cDesErr                 = '';
	LET cCodRet                 = '00000';
	LET cCodRetSp				= '000000';
	LET cMensaje                = '';
	LET iRecuperacion			= 0;
	LET iCvePieza               = 0;
	LET dFechaCaptura           = DATE(1);
	LET cNumRecibo              = '';
	LET iNumPiezas              = 0;
	LET cTipoPieza              = '';
	LET cDenominacion           = '';
	LET iCveDenominacion        = 0;  
	LET cSerie                  = '';
	LET cFolio                  = '';
	LET dFechaEmision           = DATE(1);
	LET cNota                   = '';
	LET cEstatus                = '';  
	LET cDictamenBanxico        = '';  
	LET cNumLoteBanxico         = '';
	LET cFolioBanxico           = '';
	LET dFechaPago              = DATE(1);
	LET cFormaPago              = ''; 
	LET cNumCta                 = '';
	LET cNumSuc                 = '';
	LET cNombreSuc              = '';
	LET cDomSuc                 = ''; 
	LET cNomOperador            = '';
	LET cApellidoTenedor1       = ''; 
	LET cApellidoTenedor2       = '';                                                                                                                               
	LET cNomTenedor1            = '';
	LET cNomTenedor2            = '';
	LET cIdentificacion         = '';
	LET cNumIdentificacion      = ''; 
	LET cCalle                  = '';
	LET cNumCasa                = '';                                             
	LET cColonia                = '';
	LET cDelegacion             = '';
	LET cCodPostal              = '';
	LET cCiudad                 = '';
	LET cEstado                 = '';
	LET cTelefono               = '';
	LET cEmail                  = '';

	LET dFechaInicio            = DATE(1);
	LET dFechaFin               = DATE(1);
	LET iBandFecha              = 0;
	LET iBandInicio             = 0;
	LET iBandRegistros          = 0;
	LET iRegistros              = 0;
	LET iRegCon                 = 0;
	LET iContador               = 0;
	LET iTermino                = 0;
	LET cNumReciboCon			= '';
	LET iIdTenedor				= 0;
	LET cNumSucursalReten		= '';
	LET cNombre1				= '';
	LET cNombre2				= '';
	LET cApPaterno				= '';
	LET cApMaterno				= '';
	LET cCalleCon				= '';
	LET cNumeroCalle			= '';
	LET cColoniaCon				= '';
	LET cDelegacionPoblacion	= '';
	LET cCodPostalCon			= '';
	LET cCiudadCon				= '';
	LET cEstadoCon				= '';
	LET cTelefonoCon			= '';
	LET cEmailCon				= '';
	LET cEjecutivoInsert		= '';
	LET cIdentificacionCon		= '';
	LET cIdentificacionDes 	    = '';
	LET cNumIdentificacionCon	= '';
	LET cIdPieza				= 0;
	LET dFechaRecepcion			= DATE(1);
	LET iIdDenominacion			= 0;
	LET cSerieCon				= '';
	LET cFolioCon				= '';
	LET dFechaEmisionCon		= DATE(1);
	LET iNumPiezasCon			= 0;
	LET cNotaCon				= '';
	LET cFolioBanxicoCon		= '';
	LET iDictamenBanxico		= 0;
	LET cNumLoteBanxicoCon		= '';
	LET dFechaPagoCon           = DATE(1);
	LET iTipoPago				= 0;
	LET cNumCtaCliente			= '';
	LET iEstatus				= 0;
	LET dFechaInsert            = DATE(1);
	LET cNombreScucursal        = '';
	LET cDireccion1             = '';
	LET cNombreOperador         = '';
	LET cDesCvePieza            = '';
	LET cDenominacionCon        = ''; 
	LET cDesDictamen            = ''; 
	LET cDesTipoPago            = ''; 
	LET cDesEstatus             = ''; 
	LET cCodigo                 = ''; 
	LET cPromotor               = '';
	LET cCiudadoDelegacion      = '';
	LET cCiudadoCoppel          = 0;
	LET cNombreCidDel           = '';
	LET cNombreCol		        = '';
	LET cNombreCalle            = '';
	LET cNombreCiudad           = '';	
	LET cNombreDelegacion       = '';
	LET cEstadoDes              = '';
	LET cEstadoDesRes           = '';
	LET cEstadoBanxico          =  '';
	LET cEmpresa 				= '001';
	LET dFechaHoy 				= DATE(CURRENT);

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultadatospiezas_bym.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL OR pTipoConsulta IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
		   RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
		END IF;

		IF pTipoConsulta = 1 THEN --GRID PRINCIPAL
		
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;

			FOREACH 
				
				SELECT {+INDEX (bdicnweb:sw_cg_billetesfalsos idx_sw_cg_billetesfalsos)} SKIP pRegistros FIRST pRecuperacion 
				cve_pieza,fecha_captura,num_recibo,num_piezas,tipo_pieza,denominacion,cve_denominacion,serie,folio,fecha_emision,nota,estatus,dictamen_banxico,num_lote_banxico,folio_banxico,fecha_pago,
				forma_pago,num_cta,num_suc,nombre_suc,dom_suc,nom_operador,apellido_tenedor1, apellido_tenedor2, nom_tenedor1,nom_tenedor2,
				identificacion,num_identificacion,calle, numcasa,colonia,delegacion,codpostal, ciudad,estado,telefono,email,operador,estado_desc  
				INTO iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, 
				cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,
				cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes
				FROM bdicnweb:"informix".sw_cg_billetesfalsos
				WHERE us_insert=pUsuario
				ORDER BY id_serial ASC

				LET iRecuperacion = iRecuperacion + 1;	
				RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes WITH RESUME;           
		
			END FOREACH;
		
		ELSE --GRID REPORTE
		
			FOREACH 
			
				EXECUTE PROCEDURE bdisuc:"informix".sp_consultadatospiezas_bym3(pFechaCaptura, pFechaIni, pFechaFin, pSucursal, pNumRecibo, pNumGuia, pEstatus, pDictamen, cEmpresa,pRegistros,pRecuperacion )
				INTO cCodRetSp, cMensaje, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes,iRegistros, iTermino
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_consultadatospiezas_bym3';
				ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00003';
					RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
				ELIF cCodRetSp::INTEGER = 2 AND pRegistros = 0  THEN		
					LET cCodRet = '00017';
					RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
				ELIF cCodRetSp::INTEGER = 2 AND pRegistros > 0 THEN		
					LET cCodRet = '1001';
					RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
				END IF;
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes WITH RESUME;           
	
			END FOREACH;
		
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 15/12/2016',
'MODULO: CAJA GENERAL ',
'FUNCIONALIDAD: BILLETES PRESUNTAMENTE FALSOS EN SUCURSAL',
'DESCRIPCION:SPL Intermedio que obtiene informacion para llenado de grid',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 07/04/2016',
'MODIFICACION: Se agrega validación para la recuperación de registros a retornar.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consulta_sac_reportediario( pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha_inicial DATE,pFecha_final DATE,pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,DATE AS FechaProceso, INTEGER AS num_mesesvent, MONEY(16,2) AS importe_vent, 
	INTEGER AS num_mesesdomi,MONEY(16,2) AS Importe_domi, INTEGER AS num_meses,MONEY(16,2) AS importe_total,MONEY(16,2) AS comision,
	MONEY(16,2) AS iva,MONEY(16,2) AS importe_pago_coppel;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotales INTEGER;
	DEFINE dFechaProceso DATE;
	DEFINE iNum_mesesvent INTEGER;
	DEFINE mImporte_vent MONEY(16,2);
	DEFINE iNum_mesesdomi INTEGER;
	DEFINE mImporte_domi MONEY(16,2);
	DEFINE iNum_meses INTEGER;
	DEFINE mImporte_total MONEY(16,2);
	DEFINE mComision MONEY(16,2);
	DEFINE mIva MONEY(16,2);
	DEFINE mImporte_pago_coppel MONEY(16,2);
    DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotales = 0;
	LET dFechaProceso=DATE(1);
	LET iNum_mesesvent =0;
	LET mImporte_vent =0;
	LEt iNum_mesesdomi=0;
	LET mImporte_domi=0;
	LET iNum_meses=0;
	LET mImporte_total=0;
	LET mComision=0;
	LET mIva=0;
	LET mImporte_pago_coppel=0;
	LET iRecuperacion=0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,iNum_meses,mImporte_domi,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_sac_reportediario.out';
		--TRACE ON;
		
		IF pUsuario = '' OR  pIdFuncion = '' OR pFecha_inicial = '' OR pFecha_final = ''THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

       FOREACH

		SELECT SKIP pRegistros FIRST pRecuperacion fecha_proceso,num_mesesvent,importe_vent ,num_mesesdomi,importe_domi,num_meses,importe_total,comision,iva,importe_pago_coppel
		INTO dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel
		FROM bdisac:sac_reportediario_seg  
     	WHERE fecha_proceso BETWEEN pFecha_inicial AND pFecha_final and reportesoc ='1'
      ORDER BY fecha_proceso ASC

       LET iRecuperacion = iRecuperacion + 1;
        
      RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel WITH RESUME;
       END FOREACH;

		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		END IF;	
		

	END;		

END PROCEDURE;