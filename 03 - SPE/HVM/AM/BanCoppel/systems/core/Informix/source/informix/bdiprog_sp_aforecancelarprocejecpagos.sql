CREATE PROCEDURE "informix".sp_aforecancelarprocejecpagos(p_NombreArchivo CHAR(30), p_Usuario CHAR(8), p_TipoMovimiento SMALLINT, pTipoarch CHAR(1))
	RETURNING CHAR(6); --cod retorno
	--p_TipoMovimiento: 1.- Suspencion Temporal, 2.- Cancelacion(o suspencion definitiva)

	--Declaracion de variables
	DEFINE v_codret 	CHAR(6);
	DEFINE v_sqlerr 	INTEGER;
    DEFINE v_SamErr		INTEGER;
    DEFINE v_DesErr		CHAR(100);

	DEFINE v_fecha_hoy 	DATE;
	DEFINE v_Status		CHAR(2);
	DEFINE cNomProceso 	CHAR(10);
	DEFINE cProceso     CHAR(10); --DSB 25/03/2014


	--SET DEBUG FILE TO '/tmp/sp_AforeCancelarProcEjecPagos.out';
	--TRACE ON;

	--Inicializacion de variables
	LET v_codret = "00000";
	LET v_sqlerr = 0;
	LET cNomProceso = '';
	LET cProceso = ''; --DSB 25/03/2014
	
	BEGIN
	    ON EXCEPTION SET v_sqlerr, v_SamErr, v_DesErr
	        IF v_sqlerr != 0 THEN
	            LET v_codret = v_sqlerr;
	            RETURN v_codret;
	        END IF;
	    END EXCEPTION;

		--El procedimiento obtiene la fecha del sistema central.
		SELECT fecha_hoy INTO v_fecha_hoy FROM bdinteg:si_fechas WHERE empresa = '001';
		
		IF p_TipoMovimiento = 1 THEN
			IF pTipoarch = '1' THEN  --DSB 25/03/2014
				LET cNomProceso = 'AforeSus'|| SUBSTR(p_NombreArchivo, 23, 2);
				LET cProceso = 'AforeVal' || SUBSTR(p_NombreArchivo, 23, 2);
			ELIF pTipoarch = '2' THEN
				LET cNomProceso = 'AfoSusOB'|| SUBSTR(p_NombreArchivo, 25, 2);
				LET cProceso = 'AfoValOB' || SUBSTR(p_NombreArchivo, 25, 2);
			END IF;
		ELIF p_TipoMovimiento = 2 THEN
			IF pTipoarch = '1' THEN --DSB 25/03/2014
				LET cNomProceso = 'AforeCan'||SUBSTR(p_NombreArchivo, 23, 2);
				LET cProceso = 'AforeVal' || SUBSTR(p_NombreArchivo, 23, 2);
			ELIF pTipoarch = '2' THEN
				LET cNomProceso = 'AfoCanOB'||SUBSTR(p_NombreArchivo, 25, 2);
				LET cProceso = 'AfoValOB' || SUBSTR(p_NombreArchivo, 25, 2);
			END IF;
		END IF 

		IF p_NombreArchivo = '' OR p_NombreArchivo IS NULL OR p_Usuario = '' OR p_Usuario IS NULL OR p_TipoMovimiento IS NULL OR NVL(pTipoarch,'') = '' THEN  --DSB 25/03/2014

			LET v_codret = '10015'; --Faltan parametros

			--El procedimiento guarda el error en bitacora del sistema.
			INSERT INTO bdiprog:pp_bitacora (proceso, archivo, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
			VALUES (cNomProceso, TRIM(p_NombreArchivo), v_codret, 'Faltan parametros', p_Usuario, v_fecha_hoy, SUBSTR(CURRENT, 12, 8));

			RETURN v_codret;

		ELSE
			--El procedimiento valida que el proceso de recepción de archivo ya ha sido ejecutado.
			IF EXISTS (SELECT proceso FROM bdiprog:pp_procesos WHERE proceso = TRIM(cProceso) AND fech_proceso = v_fecha_hoy ) THEN  --DSB 25/03/2014
				--El procedimiento valida que el proceso de Cancelación de la Ejecución de Pagos Pendientes ya ha sido ejecutado.
				IF EXISTS (SELECT proceso FROM bdiprog:pp_procesos WHERE proceso = cNomProceso AND fech_proceso = v_fecha_hoy) THEN

					--El procedimiento recupera el satutus del proceso de Cancelación de la Ejecución de Pagos Pendientes
					SELECT NVL(status, '0')
					INTO v_Status
					FROM bdiprog:pp_procesos
					WHERE proceso = cNomProceso
						AND fech_proceso = v_fecha_hoy;

					--El procedimiento valida que el proceso de Cancelación de la Ejecución de Pagos Pendientes termino de manera incorrecta.
					IF v_Status = '1' THEN
						--Tipo de cancelación "Suspensión Temporal".
						IF p_TipoMovimiento = 1 THEN
							--El procedimiento modifica el estado del archivo a procesar a estado 09 en la lista de archivos de afore.
							UPDATE bdiprog:pp_arch_afore
							SET status = '09'
							WHERE nombre_arch = TRIM(p_NombreArchivo);

							--El procedimiento guarda el fin del procedimiento de Cancelación de la Ejecución de Pagos Pendientes.
							UPDATE bdiprog:pp_procesos
							SET status = '2'
							WHERE proceso = cNomProceso
								AND fech_proceso = v_fecha_hoy;

						--Tipo de cancelación "Cancelación".
						ELIF p_TipoMovimiento = 2 THEN
							--El procedimiento modifica el estado del archivo a procesar a estado 08 en la lista de archivos de afore.
							UPDATE bdiprog:pp_arch_afore
							SET status = '08'
							WHERE nombre_arch = TRIM(p_NombreArchivo);

							--El procedimiento modifica el estado de los registros incluidos en el archivo en la seccion de detalles a estado 08.
							UPDATE bdiprog:pp_detalle
							SET status = '08'
							WHERE nombre_arch = TRIM(p_NombreArchivo);

							--El procedimiento guarda el fin del procedimiento de Cancelación de la Ejecución de Pagos Pendientes.
							UPDATE bdiprog:pp_procesos
							SET status = '2'
							WHERE proceso = cNomProceso
								AND fech_proceso = v_fecha_hoy;

						ELSE
							LET v_codret = '10025';	--Tipo de movimiento incorrecto

							--El procedimiento guarda el error en bitacora del sistema.
							INSERT INTO bdiprog:pp_bitacora (proceso, archivo, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
							VALUES (cNomProceso, TRIM(p_NombreArchivo), v_codret, 'Tipo de movimiento incorrecto', p_Usuario, v_fecha_hoy, SUBSTR(CURRENT, 12, 8));

							RETURN v_codret;
						END IF;

					ELIF v_Status = '2' THEN
						LET v_codret = '10028';	--Ya fue cancelado el archivo

						INSERT INTO bdiprog:pp_bitacora (proceso, archivo, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
						VALUES (cNomProceso, TRIM(p_NombreArchivo), v_codret, 'Ya fue cancelado el archivo', p_Usuario, v_fecha_hoy, SUBSTR(CURRENT, 12, 8));

						RETURN v_codret;

					ELSE
						LET v_codret = '10026';	--Status incorrecto

						--El procedimiento guarda el error en bitacora del sistema.
						INSERT INTO bdiprog:pp_bitacora (proceso, archivo, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
						VALUES (cNomProceso, TRIM(p_NombreArchivo), v_codret, 'Status incorrecto', p_Usuario, v_fecha_hoy, SUBSTR(CURRENT, 12, 8));

						RETURN v_codret;
					END IF;
				ELSE
					--El procedimiento registra el inicio del proceso en la lista de procesos.
					INSERT INTO bdiprog:pp_procesos (proceso, fech_proceso, status, user_insert, fecha_insert)
					VALUES (cNomProceso, v_fecha_hoy, '1', p_Usuario, v_fecha_hoy);

					--Tipo de cancelación "Suspensión Temporal".
					IF p_TipoMovimiento = 1 THEN
						--El procedimiento modifica el estado del archivo a procesar a estado 09 en la lista de archivos de afore.
						UPDATE bdiprog:pp_arch_afore
						SET status = '09'
						WHERE nombre_arch = TRIM(p_NombreArchivo);

						--El procedimiento guarda el fin del procedimiento.
						UPDATE bdiprog:pp_procesos
						SET status = '2'
						WHERE proceso = cNomProceso
							AND fech_proceso = v_fecha_hoy;

					--Tipo de cancelación "Cancelación".
					ELIF p_TipoMovimiento = 2 THEN
						--El procedimiento modifica el estado del archivo a procesar a estado 08 en la lista de archivos de afore.
						UPDATE bdiprog:pp_arch_afore
						SET status = '08'
						WHERE nombre_arch = TRIM(p_NombreArchivo);

						--El procedimiento modifica el estado de los registros incluidos en el archivo en la seccion de detalles a estado 08.
						UPDATE bdiprog:pp_detalle
						SET status = '08'
						WHERE nombre_arch = TRIM(p_NombreArchivo);

						--El procedimiento guarda el fin del procedimiento.
						UPDATE bdiprog:pp_procesos
						SET status = '2'
						WHERE proceso = cNomProceso
							AND fech_proceso = v_fecha_hoy;

					ELSE
						LET v_codret = '10025';	--Tipo de movimiento incorrecto

						--El procedimiento guarda el error en bitacora del sistema.
						INSERT INTO bdiprog:pp_bitacora (proceso, archivo, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
						VALUES (cNomProceso, TRIM(p_NombreArchivo), v_codret, 'Tipo de movimiento incorrecto', p_Usuario, v_fecha_hoy, SUBSTR(CURRENT, 12, 8));

						RETURN v_codret;
					END IF;
				END IF;
			ELSE
				--- No se a ejecutado el proceso de recepción de archivo
				LET v_codret = '10024';

				INSERT INTO bdiprog:pp_bitacora (proceso, archivo, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
				VALUES (cNomProceso,TRIM(p_NombreArchivo), v_codret,'No se Ejecuto el proceso de Recepcion de Archivos con anterioridad', p_Usuario, v_fecha_hoy, SUBSTR(CURRENT, 12, 8));		

				RETURN v_codret;
			END IF;
			RETURN v_codret;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Suspender de manera provisional y/o cancelar de manera definitiva la ejecución del proceso automático Ejecución de', 
'Pagos Pendientes que se encarga de realizar la dispersión de pagos pendientes enviados por Afore Coppel',
'Solicito : Armando Mercado',
'AUTOR: Abraham Ayala Aguilar',
'FECHA: 20 Mayo 2009',
'VERSION: 20090520',
'BD: BDIPROG',
'DESCRIPCION: Se realizo la separacion de procesos dado a que un proceso se puede suspender temporalmente y cancelar definitivo,',
'se analizo que era necesario separarse en Aforesus## y Aforecan## para cumplir con la necesidad del cliente.',
'Solicito : Armando Mercado',
'MODIFICO: ANTONIO BASTIDAS',
'FECHA: 23 junio 2009',
'VERSION: 20090623.1827',
'BD: BDIPROG',
'MODIFICO   : Josue Zepeda - 92802036',
'FOLIO      : 1411',
'DESCRIPCION: Se agrega proceso para otros bancos para la Cancelacion del proceso',
'FECHA      : 25 de Marzo de 2014',
'SUSTENTO   : Se definio con Leonardo Hernández Moreno y Yuridia Espinoza en el requerimiento',
'RQM 06 292 Creacion de archivo Afore Coppel para dispersar pagos a otros Bancos',
'BD         : BDIPROG';

CREATE PROCEDURE "informix".sp_aforeconsultaarchivos(pNombre CHAR(30), pTipoarch CHAR(1)) -- DSB 26/03/2014

RETURNING CHAR(5),CHAR(1),CHAR(10),DATE,DATE, DATE,CHAR(9),CHAR(232),CHAR(2),CHAR(11),CHAR(40),
	CHAR(40),CHAR(40),CHAR(1),CHAR(18),DATE,CHAR(15),CHAR(15),CHAR(11),CHAR(8),CHAR(4),CHAR(3),CHAR(10),
	CHAR(18),CHAR(10),CHAR(16),CHAR(2), CHAR(17),CHAR(17),CHAR(17),CHAR(17),CHAR(17),DATE, CHAR(2),INTEGER, 
	MONEY(10,2),MONEY(12,2);

--DECLARACION DE VARIABLES----------------------
DEFINE vCodRet							CHAR(5);
DEFINE vSqlErr							INTEGER;
DEFINE cTipoRegistro					CHAR(1);
DEFINE cFinLinea						CHAR(2);
DEFINE dFecha_Hoy						DATE;
DEFINE cCURP							CHAR(18);
--ENCABEZADO
DEFINE cNoContratoEmpresa 				CHAR(10);
DEFINE dFechaGen				 		DATE;
DEFINE dFechaInicialInformacion 		DATE;
DEFINE dFechaFinalInformacion 			DATE;
DEFINE cNoMovimientosContenidos 		CHAR(9);
DEFINE cFiller							CHAR(232);
--DETALLE
DEFINE cNSS 							CHAR(11);
DEFINE cNombreBeneficiario 				CHAR(40);
DEFINE cApellidoPaternoBeneficiario 	CHAR(40);
DEFINE cApellidoMaternoBeneficiario 	CHAR(40);
DEFINE cFormasPago 						CHAR(1);
DEFINE cCLABE 							CHAR(18);
DEFINE dFechaCaptura 					DATE;
DEFINE cImporteDocumentoNetoPagar 		CHAR(15);
DEFINE cImporteDocumentoAntesImpuesto 	CHAR(15);
DEFINE cImpuestoRetenido 				CHAR(11);
DEFINE cNumeroFolioServicio 			CHAR(8);
DEFINE cNumeroTienda 					CHAR(4);
DEFINE cTipoRetiro 						CHAR(3);
DEFINE cConsecutivoRetiro 				CHAR(10);
DEFINE cRFC 							CHAR(10);
DEFINE cStatus 							CHAR(2);
DEFINE cNombre 							CHAR(30);
DEFINE cFolio_suc 						CHAR(16);

--SUMARIO
DEFINE cNumeroTotalMovimientosContenidos	CHAR(9);
DEFINE cImporteTotalNeto					CHAR(17);
DEFINE cImporteTotalAntesImpuesto			CHAR(17);
DEFINE cImporteRetenido						CHAR(17);
DEFINE cImporteTotalRetirosPagadosEfectivo  CHAR(17);
DEFINE cImporteTotalRetirosPagadosDeposito	CHAR(17);

--Encabezado
DEFINE dFechaMovimientos 	DATE; 
--detalle
DEFINE cNumeroMovimientos	CHAR(4);
DEFINE cMonto 				MONEY(10,2);DEFINE v_Cuenta CHAR(11);
--sumario
DEFINE iSumamon 			MONEY(12,2);DEFINE iSumamov INTEGER;

--INICIALIZACION DE VARIABLES-------------------------
LET cTipoRegistro 	= '';
LET cFinLinea		= '';
LET dFecha_Hoy 		= '';
LET cNombre 		= '';
--ENCABEZADO
LET vCodRet						= "0000";
LET cNoContratoEmpresa 			= '';
LET dFechaGen 					= '';
LET dFechaInicialInformacion 	= '';
LET dFechaFinalInformacion 		= '';
LET cNoMovimientosContenidos 	= '';
LET cFiller						= '';
--DETALLE
LET cNSS 						= '';
LET cNombreBeneficiario 		= '';
LET cApellidoPaternoBeneficiario = '';
LET cApellidoMaternoBeneficiario = '';
LET cFormasPago 				= '';
LET cCLABE 						= '';
LET dFechaCaptura 				= '';
LET cImporteDocumentoNetoPagar 	= '';
LET cImporteDocumentoAntesImpuesto = '';
LET cImpuestoRetenido 			= '';
LET cNumeroFolioServicio 		= '';
LET cNumeroTienda 				= '';
LET cTipoRetiro 				= '';
LET cConsecutivoRetiro 			= '';
LET cRFC 						= '';
LET cStatus 					= '';
LET cFolio_suc 					= '';

--SUMARIO
LET cNumeroTotalMovimientosContenidos	= '';
LET cImporteTotalNeto					= '';
LET cImporteTotalAntesImpuesto			= '';
LET cImporteRetenido					= '';
LET cImporteTotalRetirosPagadosEfectivo = '';
LET cImporteTotalRetirosPagadosDeposito	= '';
--CONTROL 
LET dFechaMovimientos 	= ''; 
LET cNumeroMovimientos 	= '';
LET cMonto 				= '';
LET iSumamon 			= '0';
LET iSumamov			= '0';

--SET DEBUG FILE TO "/tmp/sp_AforeConsultaArchivos.out";
--TRACE ON;

    BEGIN
		--MANEJO DE ERRRORES
		ON EXCEPTION SET vSqlErr
			IF vSqlErr != 0 THEN
				LET vCodRet = vSqlErr;
				RETURN vCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion,
				dFechaFinalInformacion, cNoMovimientosContenidos, cFiller, cFinLinea, '', '', '', '', '',
				'', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 0, 0, 0;
			END IF;
		END EXCEPTION;

		--VALIDA QUE EL ARCHIVO EXISTA
		IF NOT EXISTS (SELECT nombre_arch FROM bdiprog:pp_arch_afore WHERE nombre_arch = pNombre ) THEN
			LET vCodRet='10000';
			RETURN vCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion,
			dFechaFinalInformacion, cNoMovimientosContenidos, cFiller, cFinLinea, '', '', '', '', '',
			'', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 0, 0, 0;
		END IF;

		IF pNombre LIKE 'PAGOS%' OR pNombre LIKE 'CONF%' THEN 

			IF pNombre LIKE 'CONF%' THEN
			
				IF pTipoarch = '1' THEN  -- DSB 26/03/2014
					LET cNombre = 'PAGOS'||SUBSTR(pNombre,5,9)||'A'||SUBSTR(pNombre,15,30);
				ELIF pTipoarch = '2' THEN
					LET cNombre = 'PAGOS' || SUBSTR(pNombre,7,9) || 'OBA' || SUBSTR(pNombre,17,30);
				END IF; -- DSB 26/03/2014
				
			ELSE
				LET cNombre = pNombre;
			END IF;

			--DATOS DEL ENCABEZADO
			SELECT 
				tipo_reg,contrato, fecha_gen, fecha_ini, fecha_fin, no_mov, filler, fin_linea
			INTO 
				cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion, dFechaFinalInformacion,
				cNoMovimientosContenidos, cFiller, cFinLinea
			FROM bdiprog:pp_Encabezado
			WHERE nombre_arch = cNombre; 

			RETURN vCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion,
				dFechaFinalInformacion, cNoMovimientosContenidos, cFiller, cFinLinea, '', '', '', '',
				'', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',	'', 0, 0, 0 WITH RESUME;

			LET cTipoRegistro 	= '';
			LET cFiller 		= '';
			LET cFinLinea		= '';

			FOREACH WITH HOLD
				--DATOS DEL DETALLE
				SELECT {+INDEX(bdiprog:pp_detalle idxdetalle19c)} SUBSTR(a.clabe, 7, 11), a.tipo_reg, a.nss, 
					a.forma_pago, a.clabe, a.fecha_captura, a.imp_netopagar, a.imp_antimpuesto, a.imp_retenido, a.num_folioservicio,
					a.num_tienda, a.tipo_retiro, a.consecutivo_ret, a.curp, a.rfc, a.status, a.filler, a.folio_suc, a.fin_linea,
					a.nom_benef ,a.apell_pat ,a.apell_mat
				INTO v_Cuenta, cTipoRegistro, cNSS, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar,
					cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda,
					cTipoRetiro, cConsecutivoRetiro, cCURP, cRFC, cStatus, cFiller, cFolio_suc, cFinLinea,
					cNombreBeneficiario, cApellidoPaternoBeneficiario, cApellidoMaternoBeneficiario-- se agregaron estor tres campos para obtener el nombre completo de la ppdetalle
				FROM bdiprog:pp_Detalle a
				WHERE a.nombre_arch = cNombre

				IF cNombre = pNombre THEN -- si se trata de archivos PAGOS:::
				
					RETURN vCodRet, cTipoRegistro, '', '', '', '', '', cFiller, cFinLinea, cNSS, cNombreBeneficiario,
						cApellidoPaternoBeneficiario, cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura,
						cImporteDocumentoNetoPagar, cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio,
						cNumeroTienda, cTipoRetiro, cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, '', '', '', '', '', '', '', '01', 0, 0, 0 WITH RESUME;
				ELSE  -- si se trata de archivos CONF:::
					IF pTipoarch = '1' THEN -- DSB 26/03/2014
					-- se obtiene el nombre del cliente en la bd
						SELECT NVL(TRIM(c.nombre1) ||' '|| TRIM(c.nombre2), ''), NVL(TRIM(c.apell_paterno), ''), NVL(TRIM(c.apell_materno), '')
						INTO cNombreBeneficiario, cApellidoPaternoBeneficiario, cApellidoMaternoBeneficiario
						FROM bdicheq:sc_maechq b
						INNER JOIN bdinteg:si_cliente c ON b.num_cte = c.numcte
						WHERE b.empresa = '001'
						AND b.cuenta = v_Cuenta;

						IF cNombreBeneficiario IS NULL THEN
							LET cNombreBeneficiario = "";
						END IF;
						IF cApellidoPaternoBeneficiario IS NULL THEN
							LET cApellidoPaternoBeneficiario = "";
						END IF;
						IF cApellidoMaternoBeneficiario IS NULL THEN
							LET cApellidoMaternoBeneficiario = "";
						END IF;

						RETURN vCodRet, cTipoRegistro, '', '', '', '', '', cFiller, cFinLinea, cNSS, cNombreBeneficiario,
							cApellidoPaternoBeneficiario, cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura,
							cImporteDocumentoNetoPagar, cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio,
							cNumeroTienda, cTipoRetiro, cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, '', '', '', '', '', '', '', cstatus, 0, 0,0 WITH RESUME;
					ELIF pTipoarch = '2' THEN -- DSB 26/03/2014
						RETURN vCodRet, cTipoRegistro, '', '', '', '', '', cFiller, cFinLinea, cNSS, cNombreBeneficiario,
						cApellidoPaternoBeneficiario, cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura,
						cImporteDocumentoNetoPagar, cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio,
						cNumeroTienda, cTipoRetiro, cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, '', '', '', '', '', '', '', '01', 0, 0, 0 WITH RESUME;
					END IF;
				END IF;
			END FOREACH
			
			LET cFiller		= '';
			LET cFinLinea 	= '';

			--DATOS DEL SUMARIO
			SELECT 
				total_mov, tipo_reg, total_imp_neto, total_imp_antimp, total_imp_retenido, imp_tot_efectivo,
				imp_tot_deposito, filler, fin_linea
			INTO 
				cNumeroTotalMovimientosContenidos, cTipoRegistro, cImporteTotalNeto, cImporteTotalAntesImpuesto, 
				cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, cImporteTotalRetirosPagadosDeposito, 
				cFiller, cFinLinea
			FROM bdiprog:pp_Sumario
			WHERE nombre_arch = cNombre;  

			RETURN vCodRet, cTipoRegistro, '', '', '', '', '', cFiller, cFinLinea , '', '', '', '', '', '', '', '',
				'', '', '', '', '', '', '', '', '', cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
				cImporteTotalAntesImpuesto,	cImporteRetenido, cImporteTotalRetirosPagadosEfectivo,
				cImporteTotalRetirosPagadosDeposito, '', '', 0, 0, 0 WITH RESUME; 
		ELSE 
			--DATOS DEL ENCABEZADO
			LET cTipoRegistro = 'E';

			SELECT fecha_hoy INTO dFecha_Hoy FROM Bdinteg:si_fechas;

			LET dFechaGen = dFecha_Hoy;
			LET dFechaMovimientos = dFecha_Hoy;

			RETURN vCodRet, cTipoRegistro, '', dFechaGen, '', '', '', '', '', '', '', '', '', '', '', '', '', '',
				'', '', '', '', '', '', '', '', '', '', '', '', '', '', dFechaMovimientos, '', 0, 0, 0 WITH RESUME;
			
			IF pTipoarch = '1' THEN -- DSB 26/03/2014
				LET cNombre = 'PAGOS'||SUBSTR(pNombre,5,9)||'A'||SUBSTR(pNombre,15,30);
			ELIF pTipoarch = '2' THEN
				LET cNombre = 'PAGOS' || SUBSTR(pNombre,7,9) || 'OBA' || SUBSTR(pNombre,17,30);
			END IF; -- DSB 26/03/2014
				
			FOREACH	WITH HOLD
				--SE OBTIENEN LOS DATOS DEL DETALLE
				SELECT DISTINCT(status), COUNT(status), SUM(imp_netopagar)
				INTO cStatus, cNumeroMovimientos, cMonto
				FROM bdiprog:pp_detalle
				WHERE nombre_arch  = cNombre
				GROUP BY status

				LET cTipoRegistro = 'D';
				LET iSumamon = iSumamon + cMonto;
				LET iSumamov = iSumamov + 1; 

				--se obtiene el status con la descripcion
				select status || '-'|| descripcion into cStatus from bdiprog:pp_status_afore where status = trim(cStatus);
				RETURN vCodRet, cTipoRegistro, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
					'', '', '', '', '', '', '', '', '', '', '', '', '', dFechaMovimientos, cstatus, cNumeroMovimientos, 
					cMonto, 0 WITH RESUME;

			END FOREACH

			-- SE OBTIENEN LOS DATOS DEL SUMARIO
			LET cTipoRegistro = 'S';

			RETURN vCodRet,cTipoRegistro, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
				'', '', '', '', '', '', '', '', '', '', '', '', '', iSumamov, 0, iSumamon WITH RESUME;

		END IF;
	END	
END PROCEDURE
DOCUMENT
'Consulta los archivos de pagos, confirmacion y control Afore',
'AUTOR: Abigail Vasavilbazo Cañedo',
'FECHA: Mayo 2009',
'BD: BDIPROG',
'CAMBIOS: Este Sp se modificaron el tipo de la variable monto con el fin de que lña retornara con un formato Money',
'         tambien se modifico que cuanso se va a mostrar un archivo dePAGOS.. el nombre delo beneficioario lo obtenga ',
'         de la tabla pp_detalle, y cuandosea un archivo de confirmacion lo obtiene de la si_clientes, tambien se modifico',
'         que regresara el numeron real de movimientos para los archivos de cifras de control ya que regresaba el total ',
'         de de movimientos en el de confirmacion, ademas se modifico variable que mostraba el numero de movimientos ya que la ',
'         retornaba como CHAR(1) y lo mostraba incompleto el numero. tambien se modifico que en la variable estado agragara la',
'         descripcion del mismo.',
'MODIFICO: César Valdéz Figueroa',
'FECHA: 16/Junio/2009',
'VERSION: 20090616',
'MODIFICO   : Josue Zepeda - 92802036',
'FOLIO      : 1411',
'DESCRIPCION: Se agrega proceso para otros bancos y parametro pTipoarch',
'FECHA      : 26 de Marzo de 2014',
'SUSTENTO   : Se definio con Leonardo Hernández Moreno y Yuridia Espinoza en el requerimiento',
'RQM 06 292 Creacion de archivo Afore Coppel para dispersar pagos a otros Bancos',
'BD         : BDIPROG';

CREATE PROCEDURE "informix".sp_aforegenerarreportedetallepagosdiarios(pFecha DATE)
	RETURNING CHAR(5),CHAR(18),CHAR(40),CHAR(120), MONEY(17,2),MONEY(17,2),decimal(18,2),CHAR(30),CHAR(2),DATE,INTEGER,MONEY(17,2),INTEGER,MONEY(17,2),
	CHAR(1); -- DSB 31/03/2014
	
--------------------------------------------------------------------------------------------------
------------------------------------GENERALES -----------------------------------------------
DEFINE cTipoRegistro 				CHAR(1);
DEFINE cFinLinea					CHAR(2);
DEFINE iSqlErr              		INTEGER;
DEFINE cCodRet              		CHAR(5);
DEFINE dFecha_Hoy           		DATE;
Define cSQL                 		CHAR(100);
DEFINE cProceso						CHAR(10);
DEFINE cNombreArchivoSalida 		CHAR(30);
DEFINE cRenglon						CHAR(30);
DEFINE cStatus						CHAR(1);
DEFINE dHora  datetime HOUR TO SECond;
--------------------------------------------------------------------------------------------------

DEFINE cCLABE		CHAR(18);
DEFINE cTipoCuenta  CHAR(40);
DEFINE cNombreCliente CHAR(120);
DEFINE cImporte   MONEY(17,2);
DEFINE dIva  decimal(18,2);
DEFINE cEstado  CHAR(2);
DEFINE cEstatusPago  CHAR(30);
DEFINE cTransaccCargo CHAR(4);
DEFINE mComision MONEY(17,2);
DEFINE iNumTotalPagados INTEGER;
DEFINE mImpTotalPagados MONEY(17,2);
DEFINE iNumNoPagados INTEGER;
DEFINE mImpTotalNoPagados MONEY(17,2);
DEFINE cCuenta CHAR(11);

DEFINE cIdentificadorArchivo CHAR(2); -- DSB 31/03/2014
DEFINE cTipoArchivo CHAR(1); -- DSB 31/03/2014
DEFINE cBandera1 CHAR(1);    -- DSB 31/03/2014
DEFINE cBandera2 CHAR(1);    -- DSB 31/03/2014

LET cCuenta = '';
LET iNumNoPagados = 0;
LET mImpTotalNoPagados = 0.00;
LET iNumTotalPagados = 0;
LET mImpTotalPagados = 0.00;
LET cTransaccCargo = '';
LET mComision =0.00;
LET cEstado		= '';
LET cCLABE		= '';
LET cTipoCuenta  = '';
LET cNombreCliente = '';
LET cImporte  = '';
LET dIva  = 0.00;
LET cEstatusPago  = '';

LET cTipoRegistro = '';
LET cFinLinea = '';
LET iSqlErr = 0;
LET cCodRet = '00000';
LET dFecha_Hoy = '';
LET cSQL = '';
LET cProceso = '';
LET cStatus = '';
LET cNombreArchivoSalida = '';
LET dhora = CURRENT HOUR TO SECOND;

LET cIdentificadorArchivo = ''; -- DSB 31/03/2014
LET cTipoArchivo = ''; -- DSB 31/03/2014
LET cBandera1 = '0';   -- DSB 31/03/2014
LET cBandera2 = '0';   -- DSB 31/03/2014

--------------------------------------------------------------------------------------------------


	--SET DEBUG FILE TO "/respaldosbd/ceav/sp_aforegenerarreportedetallepagosdiarios.out";
	--TRACE ON;	

BEGIN
   -------Crea el control de errores
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCLABE,cTipoCuenta,cNombreCliente,cImporte,mComisiON,dIva,cEstatusPago,cEstado,dFecha_Hoy,
			        iNumTotalPagados,mImpTotalPagados,iNumNoPagados,mImpTotalNoPagados,cTipoArchivo;
		END IF;
	END EXCEPTION;
	--No Encontro El Archivo o No Exixte
	ON EXCEPTION IN (-668)
		Let cCodRet = '10010';
		RETURN cCodRet,cCLABE,cTipoCuenta,cNombreCliente,cImporte,mComision,dIva,cEstatusPago,cEstado,dFecha_Hoy,
		       iNumTotalPagados,mImpTotalPagados,iNumNoPagados,mImpTotalNoPagados,cTipoArchivo;
	END EXCEPTION WITH resume;	
	
	/*---------------------ERRORES
		let cCodRet = '10010'; no se encontro el archivo
	*/
	LET dhora = CURRENT;
	--se obtiene el cargo de la transaccion de la tabla parametros
	SELECT valor INTO cTransaccCargo FROM bdiprog:pp_parametros WHERE cve_param ='103';
	------------- Se  obtiene la fecha del sistema   
	SELECT fecha_hoy INTO dFecha_Hoy FROM bdinteg:si_fechas;
	
			-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	FOREACH
		SELECT det.clabe, det.imp_netopagar,det.status,  NVL(det.comision,0), NVL(det.iva_comision,0), 
			CASE WHEN SUBSTR(det.nombre_arch,15,2) = 'AC' THEN '1'
				WHEN SUBSTR(det.nombre_arch,15,2) = 'OB' THEN '2'
			END
		INTO cCLABE,cImporte,cEstado,mComision,dIva,cTipoArchivo
		FROM bdiprog:pp_detalle det 
			WHERE det.fecha_ejec = pFecha
			ORDER BY 6 ASC -- ORDENAR POR TIPO DE ARCHIVO
		
		IF cTipoArchivo = '1' THEN   -- DSB 31/03/2014
			LET cBandera1 = '1';
		ELIF cTipoArchivo = '2' THEN
			LET cBandera2 = '1';
		END IF;
		
		IF cTipoArchivo = '1' THEN -- DSB 31/03/2014
			LET cIdentificadorArchivo = 'AC'; -- DSB 31/03/2014
			
			--- es esta seleccion se obtiene el nombre del beneficiario completo en base a la CLABE para obtener los datos reales de la cuenta  NVL(h.sdo_actual, 0),
			LET cCuenta = SUBSTR(cCLABE,7,11);
			--- es esta seleccion se obtiene el nombre del beneficiario completo en base a la CLABE para obtener los datos reales de la cuenta  NVL(h.sdo_actual, 0),
			SELECT TRIM(NVL(cte.nombre1, '')) || ' ' || TRIM(NVL(cte.nombre2, '')) || ' ' ||TRIM(NVL(cte.apell_paterno, '')) || ' ' ||TRIM(NVL(cte.apell_materno, ''))
			INTO cNombreCliente
			FROM bdicheq:sc_maechq mae
			INNER JOIN bdinteg:si_cliente cte ON mae.num_cte = cte.numcte
			WHERE mae.empresa = '001' AND mae.cuenta = cCuenta;
			---si la CLABE no es valida retorna puros valores nulos en el nombre del beneficiario!! y en la descripcion de el tipo de cuenta
			IF  (cNombreCliente is NULL OR TRIM(cNombreCliente) = '') THEN
				LET cNombreCliente = '  ';
				LET cTipoCuenta = '  ';
			ELSE --De lo contrario ya tenemos el nombre del cliente ahi q buscar la descripcion del producto o del tipo de cuenta
				SELECT pro.nombre INTO cTipoCuenta
				FROM bdicheq:sc_maechq mae
				INNER JOIN bdicheq:sc_producto pro ON mae.producto= pro.producto
				WHERE mae.cuenta = cCuenta;
			END IF;
		ELIF cTipoArchivo = '2' THEN -- DSB 31/03/2014
			LET cIdentificadorArchivo = 'OB'; -- DSB 31/03/2014
		
			-- TOMAR EL NOMBRE DEL CLIENTE
			SELECT DISTINCT(TRIM(nom_benef) || ' ' || TRIM(apell_pat) || ' ' || TRIM(apell_mat)) 
			INTO cNombreCliente
			FROM 'informix'.pp_detalle
			WHERE clabe = TRIM(cCLABE); -- DSB 31/03/2014
			
			LET cTipoCuenta = SUBSTR(cCLABE,7,11); -- DSB 31/03/2014
		END IF; -- DSB 31/03/2014
		--se selecciona la descripcion del estado de la tabla estados
		SELECT descripcion
		INTO cEstatusPago
		FROM bdiprog:pp_status_afore
		WHERE status = cEstado;
		
		--selecciona el numero de detalle con estado 2  
		SELECT COUNT(status),NVL(SUM(imp_netopagar),0) INTO iNumTotalPagados,mImpTotalPagados FROM bdiprog:pp_detalle 
		WHERE status = '02' AND fecha_ejec = pFecha
		AND SUBSTR(nombre_arch,15,2) = cIdentificadorArchivo; -- DSB 31/03/2014
		
		--selecciona el numero de detalle con estado distinto a 2  
		SELECT COUNT(status),NVL(SUM(imp_netopagar),0) INTO iNumNoPagados,mImpTotalNoPagados FROM bdiprog:pp_detalle 
		WHERE status <> '02' AND fecha_ejec = pFecha
		AND SUBSTR(nombre_arch,15,2) = cIdentificadorArchivo; -- DSB 31/03/2014
		
		IF cTipoArchivo <> '1' and cBandera1 = '0' THEN  -- DSB 31/03/2014
			RETURN cCodRet,'','','','0',0.00,0.00,'','',dFecha_Hoy,0,0.00,0,0.00,'1' WITH resume;
			LET cBandera1 = '1';
		END IF;
		
		--Regresa resultados
		RETURN cCodRet,cCLABE,cTipoCuenta,cNombreCliente,cImporte,mComision,dIva,cEstatusPago,cEstado,dFecha_Hoy,
		       iNumTotalPagados,mImpTotalPagados,iNumNoPagados,mImpTotalNoPagados,cTipoArchivo WITH resume;
	END FOREACH;
	
		IF cTipoArchivo <> '1' and cBandera1 = '0' THEN  -- DSB 31/03/2014
			RETURN cCodRet,'','','','0',0.00,0.00,'','',dFecha_Hoy,0,0.00,0,0.00,'1' WITH resume;
			LET cBandera1 = '1';
		END IF;
		
		IF cTipoArchivo <> '2' and cBandera2 = '0' THEN  -- DSB 31/03/2014
			RETURN cCodRet,'','','','0',0.00,0.00,'','',dFecha_Hoy,0,0.00,0,0.00,'2' WITH resume;
			LET cBandera2 = '1';
		END IF;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera un reporte a detalle  de los pagos diarios de una fecha espesifica', 
'..........................................................',
'Solicito : Armando Mercado',	
'AUTOR: César Valdéz Figueroa',
'FECHA: 21 de Mayo 2009',
'BD: BDIPROG',
'CAMBIOS: Este Sp obtenia el nombre del beneficiario de la si_clientes, por medio de la cuenta, pero cuando esta no existia ',
'         ignoraba completamente este registro y no lo retornaba. por lo que se realizo esta modificacion y cuando la cuenta ',
'		  no existe se retorna el nombre en blanco ',
'MODIFICO: César Valdéz Figueroa',
'FECHA: 16/Junio/2009',
'VERSION: 20090616',
'MODIFICO   : Josue Zepeda - 92802036',
'FOLIO      : 1411',
'DESCRIPCION: Se agrega proceso para otros bancos y parametro pTipoarch',
'FECHA      : 26 de Marzo de 2014',
'SUSTENTO   : Se definio con Leonardo Hernández Moreno y Yuridia Espinoza en el requerimiento',
'RQM 06 292 Creacion de archivo Afore Coppel para dispersar pagos a otros Bancos',
'BD         : BDIPROG';

CREATE PROCEDURE "informix".sp_aforegenerarreporteresumpagproc(p_FechaReporte DATE)
	RETURNING CHAR(6), DATE, DATE, INTEGER, DECIMAL(16, 2), DECIMAL(16, 2), DECIMAL(16, 2), 
	CHAR(1); -- DSB 31/03/2014
	--cod retorno, fecha servidor, fecha mov, Num operacion, Comision cobrada, IVA obrado, Total.

	--Declaracion de variables
	DEFINE v_codret				CHAR(6);
	DEFINE v_sqlerr				INTEGER;

	DEFINE v_fecha_hoy			DATE;
	DEFINE v_FechaPago			DATE;
	DEFINE v_NumOperacion		INTEGER;
	DEFINE v_TotNumOperacion	INTEGER;
	DEFINE v_Comision			DECIMAL(16, 2);
	DEFINE dAcumulado		DECIMAL(16, 2);
	DEFINE v_IVA				DECIMAL(16, 4);
	DEFINE dTotalIva			DECIMAL(16, 2);
	DEFINE dTotal				DECIMAL(16, 2);
	DEFINE cTipoArchivo 		CHAR(1); -- DSB 31/03/2014
	DEFINE cBandera1			CHAR(1);    -- DSB 31/03/2014
	DEFINE cBandera2			CHAR(1);    -- DSB 31/03/2014
	
	
	--SET DEBUG FILE TO '/tmp/sp_AforeGenerarReporteResumPagProc.out';
	--TRACE ON;
	
	--Inicializacion de variables
	LET v_codret 			= "00000";
	LET v_sqlerr 			= 0;
	
	LET v_fecha_hoy			= DATE(1);
	LET v_FechaPago			= DATE(1);
	LET v_NumOperacion		= 0;
	LET v_TotNumOperacion	= 0;
	LET v_Comision			= 0.00;
	LET dAcumulado   		= 0.00;
	LET v_IVA				= 0.00;
	LET dTotalIva			= 0.00;
	LET dTotal				= 0.00;
	LET cTipoArchivo = ''; -- DSB 31/03/2014
	LET cBandera1 = '0';   -- DSB 31/03/2014
	LET cBandera2 = '0';   -- DSB 31/03/2014
        
	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr != 0 THEN
	            LET v_codret = v_sqlerr;
	            RETURN v_codret, v_fecha_hoy, v_FechaPago, v_NumOperacion, v_Comision, dTotalIva, dTotal, cTipoArchivo;
	        END IF;
	    END EXCEPTION;

		IF p_FechaReporte = DATE(1) OR p_FechaReporte IS NULL THEN

			LET v_codret = '10015';	--Faltan parametros
			RETURN v_codret, v_fecha_hoy, v_FechaPago, v_NumOperacion, v_Comision, dTotalIva, dTotal, cTipoArchivo;
		ELSE
			--El procedimiento obtiene la fecha del sistema central.
			SELECT fecha_hoy 
			INTO v_fecha_hoy 
			FROM bdinteg:si_fechas 
			WHERE empresa = '001';

			SELECT valor  
			INTO v_IVA 
			FROM bdinteg:si_param 
			WHERE cod_param= '47';

			FOREACH
				SELECT DISTINCT a.fecha_procesado, COUNT(b.consecutivo), NVL(SUM(b.comision),0),  -- DSB 31/03/2014
				CASE WHEN SUBSTR(a.nombre_arch,15,2) = 'AC' THEN '1'
					WHEN SUBSTR(a.nombre_arch,15,2) = 'OB' THEN '2'
				END
				INTO v_FechaPago, v_NumOperacion, v_Comision, cTipoArchivo
				FROM bdiprog:pp_arch_afore a
				INNER JOIN bdiprog:pp_detalle b ON (a.nombre_arch = b.nombre_arch)
				WHERE (a.status = '02' OR a.status = '03')
					AND a.tipo = 'P'
					AND MONTH(a.fecha_procesado) = MONTH(p_FechaReporte)
					AND YEAR(a.fecha_procesado) = YEAR(p_FechaReporte)
				GROUP BY 4, 1
				ORDER BY 4, 1 ASC
				
				IF cTipoArchivo = '1' THEN   -- DSB 31/03/2014
					LET cBandera1 = '1';
				ELIF cTipoArchivo = '2' THEN
					LET cBandera2 = '1';
				END IF;

				LET dAcumulado= dAcumulado + v_Comision;
				LET dTotalIva= dAcumulado * v_IVA;
				LET dTotal= dTotalIva + dAcumulado;
				
				IF cTipoArchivo <> '1' and cBandera1 = '0' THEN  -- DSB 31/03/2014
					RETURN v_codret, v_fecha_hoy, '', '0', 0.00, 0.00, 0.00, '1' WITH RESUME;
					LET cBandera1 = '1';
				END IF;

				RETURN v_codret, v_fecha_hoy, v_FechaPago, v_NumOperacion, v_Comision, dTotalIva, dTotal, cTipoArchivo WITH RESUME;
				LET dAcumulado   		= 0.00;
				LET dTotalIva			= 0.00;
				LET dTotal				= 0.00;
			END FOREACH;
			
			IF cTipoArchivo <> '1' and cBandera1 = '0' THEN  -- DSB 31/03/2014
				RETURN v_codret, v_fecha_hoy, '', '0', 0.00, 0.00, 0.00, '1' WITH RESUME;
				LET cBandera1 = '1';
			END IF;
			
			IF cTipoArchivo <> '2' and cBandera2 = '0' THEN  -- DSB 31/03/2014
				RETURN v_codret, v_fecha_hoy, '', '0', 0.00, 0.00, 0.00, '2' WITH RESUME;
				LET cBandera2 = '1';
			END IF;
			
		END IF;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION:',
'* Tener un procedimiento que permita generar, imprimir y exportar un reporte de pagos mensuales, totalizados por día.',
'* Mostrar la cantidad de pagos que fueron procesados diariamente.',
'* Mostrar el detalle diario de las comisiones a cobrar  por el procesamiento de pagos.',
'SOLICITO : Armando Mercado',	
'AUTOR: Abraham Ayala Aguilar',
'FECHA: 21 Mayo 2009',
'VERSION: 20090521',
'BD: BDIPROG',
'MODIFICO: Abigail Vasavilbazo Cañedo',
'FECHA: DICIEMBRE 2009',
'VERSION: 20091216.1638',
'MODIFICACION: Se modifica para regresar el iva total calculado en base al total de la comision en el mes y regresar el total de comision mas iva en el mes',
'MODIFICO   : Josue Zepeda - 92802036',
'FOLIO      : 1411',
'DESCRIPCION: Se agrega proceso para otros bancos y parametro de retorno cTipoArchivo',
'FECHA      : 26 de Marzo de 2014',
'SUSTENTO   : Se definio con Leonardo Hernández Moreno y Yuridia Espinoza en el requerimiento',
'RQM 06 292 Creacion de archivo Afore Coppel para dispersar pagos a otros Bancos',
'BD         : BDIPROG';

CREATE PROCEDURE "informix".sp_aforegeneraarchivosob(pUsuario CHAR(8) )

RETURNING CHAR(5),-->Codigo de Retorno CHAR(5) AS CodigoRet, 
	      CHAR(50);
DEFINE vcodret       CHAR(5);
DEFINE vCodRet1      CHAR(5);
DEFINE vsqlerr       INTEGER;
DEFINE dFechaActual	 DATE;
DEFINE cHoraActual	 DATETIME HOUR TO SECOND;
DEFINE cMensaje		CHAR(50);
DEFINE cNomProceso  CHAR(10);
DEFINE cFechaFormat CHAR(8);
DEFINE pNombreArchivo CHAR(30);
DEFINE cIndicadorNomArch CHAR(2);

LET vcodret = '00000';
LET dFechaActual = '';
LET vcodret1 = '00000';
LET cMensaje = '';
LET cNomProceso = '';
LET cFechaFormat = '';
LET pNombreArchivo = '';
LET cIndicadorNomArch = '';
LET cHoraActual = CURRENT HOUR TO SECOND;


-- SET DEBUG FILE TO "/home/informix/sp_AforeGeneraArchivosOB.out";
-- TRACE ON;

BEGIN

	ON EXCEPTION
	   SET vsqlerr
	   LET vcodret = vsqlerr;

	   RETURN vcodret,cMensaje;
	END EXCEPTION;
	ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET cMensaje = 'Ocurrio un error no controlado';
			INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cNomProceso,pNombreArchivo,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
            Return vcodret,cMensaje;
        END IF;
    END EXCEPTION;
	
		--consulta la fecha actual del sistema de integral	
		SELECT {+  INDEX(bdicheq:sc_fechas idx_fechas1) } fecha_hoy INTO dFechaActual FROM bdicheq:sc_fechas;
		
		LET cFechaFormat = LPAD(DAY(dFechaActual),2,0) || LPAD(MONTH(dFechaActual),2,0) || YEAR(dFechaActual);	
		LET cNomProceso = 'AfoEPPOB'; 
		LET cIndicadorNomArch = 'OB';
		
		FOREACH WITH HOLD
			SELECT nombre_arch INTO pNombreArchivo FROM bdiprog:pp_arch_afore 
			WHERE SUBSTR(nombre_arch,1,5) = 'PAGOS' 
			AND SUBSTR(nombre_arch,6,8) = cFechaFormat 
			AND SUBSTR(nombre_arch,15,2) = TRIM(cIndicadorNomArch)
			AND status = '20'
			AND tipo = 'P'
					
			CALL sp_aforearchconfob(pNombreArchivo,pUsuario)Returning vcodret,cMensaje;
			LET cMensaje = TRIM (cMensaje);
			IF vCodRet <> 0 THEN
				CONTINUE FOREACH;						
			END IF;
		END FOREACH;
		
		IF pNombreArchivo = '' OR pNombreArchivo IS NULL THEN
			LET cMensaje = 'No existen archivos por procesar';
		END IF;
		
		UPDATE pp_arch_afore SET status = '02',fecha_procesado = dFechaActual WHERE nombre_arch = pNombreArchivo;
		RETURN vcodret,cMensaje;

END
END PROCEDURE;