CREATE PROCEDURE "informix".sp_reportecreditoscancelacion_nocancelacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicial DATE, pFechaFinal DATE, 
		pMotivoCancelacion CHAR(3), pTipoCancelacion CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
			DATE AS fechaHoy, 
			CHAR(20) AS numCredito, 
			CHAR(2) AS resultado, 
			CHAR(45) AS descCancel, 
			DATE AS fechaCancel, 
			CHAR(8) AS ejecutivo, 
			CHAR(60) AS nombreEjecutivo, 
			CHAR(8) AS supervisor, 
			CHAR(60) AS nombreSupervisor, 
			CHAR(1) AS codTipoCancel, 
			CHAR(15) AS descTipoCancel, 
			CHAR(4) AS sucursal;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iNoRegs INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cMensaje CHAR(50);
	DEFINE dFechaHoy DATE;
	DEFINE cNumCredito CHAR(20);
	DEFINE cResultado CHAR(2);
	DEFINE cDescCancel CHAR(45);
	DEFINE dFechaCancel DATE;
	DEFINE cEjecutivo CHAR(8);
	DEFINE cNombreEjecutivo CHAR(60);
	DEFINE cSupervisor CHAR(8);
	DEFINE cNombreSupervisor CHAR(60);
	DEFINE cCodTipoCancel CHAR(1);
	DEFINE cDescTipoCancel CHAR(15);
	DEFINE cSucursal CHAR(4);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iRegistros = 0;
	LET iNoRegs = 0;
	LET cCodRetSp = '';
	LET cMensaje = '';
	LET dFechaHoy = NULL;
	LET cNumCredito = '';
	LET cResultado = '';
	LET cDescCancel = '';
	LET dFechaCancel = NULL;
	LET cEjecutivo = '';
	LET cNombreEjecutivo = '';
	LET cSupervisor = '';
	LET cNombreSupervisor = '';
	LET cCodTipoCancel = '';
	LET cDescTipoCancel = '';
	LET cSucursal = '';
	LET iRecuperacion = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFechaHoy, cNumCredito, cResultado, cDescCancel, dFechaCancel, cEjecutivo, cNombreEjecutivo, cSupervisor, 
					cNombreSupervisor, cCodTipoCancel, cDescTipoCancel, cSucursal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_reportecreditoscancelacion_nocancelacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicial = '' OR pFechaFinal = '' OR pRegistros = '' OR pRecuperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechaHoy, cNumCredito, cResultado, cDescCancel, dFechaCancel, cEjecutivo, cNombreEjecutivo, cSupervisor, 
					cNombreSupervisor, cCodTipoCancel, cDescTipoCancel, cSucursal;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechaHoy, cNumCredito, cResultado, cDescCancel, dFechaCancel, cEjecutivo, cNombreEjecutivo, cSupervisor, 
					cNombreSupervisor, cCodTipoCancel, cDescTipoCancel, cSucursal;
		END IF;
		
		FOREACH EXECUTE PROCEDURE bdicred:"informix".sp_generareportecreditoscancynocanc(pMotivoCancelacion, pFechaInicial, pFechaFinal, pTipoCancelacion)
			INTO cCodRetSp, cMensaje, dFechaHoy, cNumCredito, cResultado, cDescCancel, dFechaCancel, cEjecutivo, cNombreEjecutivo, cSupervisor, 
				cNombreSupervisor, cCodTipoCancel, cDescTipoCancel, cSucursal
				
			-- ValidaciÃ³n de los codigos de retorno
			IF cCodRetSp = '000001' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dFechaHoy, cNumCredito, cResultado, cDescCancel, dFechaCancel, cEjecutivo, cNombreEjecutivo, cSupervisor, 
							cNombreSupervisor, cCodTipoCancel, cDescTipoCancel, cSucursal;
			ELIF cCodRetSp = '000002' THEN
				LET cCodRet = '00017';
				RETURN cCodRet, dFechaHoy, cNumCredito, cResultado, cDescCancel, dFechaCancel, cEjecutivo, cNombreEjecutivo, cSupervisor, 
						cNombreSupervisor, cCodTipoCancel, cDescTipoCancel, cSucursal;
			ELIF cCodRetSp = '000000' THEN
				IF iRegistros >= pRegistros THEN
					IF iRecuperacion < pRecuperacion THEN
						LET iRecuperacion = iRecuperacion + 1;
						RETURN cCodRet, dFechaHoy, cNumCredito, cResultado, cDescCancel, dFechaCancel, cEjecutivo, cNombreEjecutivo, cSupervisor, 
								cNombreSupervisor, cCodTipoCancel, cDescTipoCancel, cSucursal WITH RESUME;
						LET iNoRegs = iNoRegs + 1;
					END IF;
				END IF;
			
				LET iRegistros = iRegistros + 1;
			ELSE
				LET cCodRet = cCodRetSp;
				RETURN cCodRet, NULL, '', '', '', NULL, '', '', '', '', '', '', '';
			END IF;
		END FOREACH;
		
		IF iNoRegs = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFechaHoy, cNumCredito, cResultado, cDescCancel, dFechaCancel, cEjecutivo, cNombreEjecutivo, cSupervisor, 
					cNombreSupervisor, cCodTipoCancel, cDescTipoCancel, cSucursal;
		ELIF iNoRegs = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, NULL, '', '', '', NULL, '', '', '', '', '', '', '';
		END IF;

	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde", 
"FECHA: 11/09/2013",
"DESCRIPCION: Procedimiento que obtiene los datos para el reporte de los crÃ©ditos cancelados o no cancelados en la aplicacion CNWEB";

CREATE PROCEDURE "informix".sp_totalescancelacioncre(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT)
	RETURNING CHAR(5) AS codret,
			DATE AS fecha_carga,
			INT AS total_registros,
			MONEY(14,2) AS total_monto,
			INT AS registros_aceptados,
			INT AS registros_rechazados,
			CHAR(150) AS nombre_archivo,
			CHAR(1) AS status_lote;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE dFechaCarga DATETIME YEAR TO FRACTION(3);
	DEFINE iTotalRegistros INT;
	DEFINE mTotalMonto money(14,2);
	DEFINE iTotalRegistrosAceptados INT;
	DEFINE iTotalRegistrosRechazados INT;
	DEFINE iExiste int;
	DEFINE cNombreEjecutivo char(45);
	DEFINE cNombreArchivoCarga char(150);
	DEFINE cSistemaCuenta char(2);
	DEFINE cStatusLote CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET dFechaCarga = NULL;
	LET iTotalRegistros = 0;
	LET mTotalMonto = NULL;
	LET iTotalRegistrosAceptados = 0;
	LET iTotalRegistrosRechazados = 0;
	LET iExiste = 0;
	LET cNombreEjecutivo = '';
	LET cNombreArchivoCarga = '';
	LET cSistemaCuenta = '';
	LET cStatusLote = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_totalescancelacioncre.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pLote = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
		END IF;
		
		-- Buscamos en la tabla de lotes
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(*)
		INTO iExiste
		FROM bdicnweb:sw_tr_totales_masivo
		WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		
		-- Buscamos el lote en la tabla de las cargas masivas
		IF iExiste = 0 THEN
			SELECT COUNT(lote)
			INTO iExiste
			FROM bdicnweb:sw_tr_cargamasiva_cancelacioncre
			WHERE lote = pLote;
			
			IF iExiste = 0 THEN
				let cCodRet = '00002';
				RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
			END IF;
			
			LET iExiste = 0;
		END IF;
		
		IF iExiste = 0 THEN
			SET ISOLATION TO DIRTY READ;
			
			SELECT COUNT(id_funcion) 
			INTO iTotalRegistrosAceptados
			FROM bdicnweb:sw_tr_cargamasiva_cancelacioncre 
			WHERE lote = pLote AND status = 'C';

			SET ISOLATION TO DIRTY READ;
			
			SELECT COUNT(id_funcion)
			INTO iTotalRegistrosRechazados
			FROM bdicnweb:sw_tr_cargamasiva_cancelacioncre
			WHERE lote = pLote AND status <> 'C';

			SET ISOLATION TO DIRTY READ;
			
			--SELECT cm.archivo, cm.fecha_carga
			--	, COUNT(cm.fecha_carga) AS total_registros
			--	, SUM(cm.monto_importe) AS total_monto
			--INTO cNombreArchivoCarga, dFechaCarga, iTotalRegistros, mTotalMonto
			--FROM bdicnweb:sw_tr_cargamasiva_cancelacioncre cm
			--WHERE cm.lote = pLote		
			--GROUP BY cm.archivo, cm.fecha_carga;
			SELECT cm.archivo, cm.fecha_carga
				, COUNT(cm.fecha_carga) AS total_registros
				, SUM(0) AS total_monto
			INTO cNombreArchivoCarga, dFechaCarga, iTotalRegistros, mTotalMonto
			FROM bdicnweb:sw_tr_cargamasiva_cancelacioncre cm
			WHERE cm.lote = pLote		
			GROUP BY cm.archivo, cm.fecha_carga;
			
			-- GUARDAMOS LOS DATOS DEL LOTE EN LA TABLA DE LOTES
			-- Busqueda del nombre del ejecutivo
			SET ISOLATION TO DIRTY READ;
			SELECT nombre
			INTO cNombreEjecutivo
			FROM bdinteg:si_ejecut
			WHERE ejecutivo = pIdUsuario;
			
			LET cSistemaCuenta = '06';
			LET cStatusLote = 'C';
			INSERT INTO bdicnweb:"informix".sw_tr_totales_masivo (id_lote, usuario, nombre_ejecutivo, nombre_archivo, fecha_carga, sistema_cuenta, total_registros, 
																total_monto, registros_aceptados, registros_rechazados, id_funcion)
			VALUES (pLote, pIdUsuario, cNombreEjecutivo, cNombreArchivoCarga, dFechaCarga, cSistemaCuenta, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, pIdFuncion);
			
			RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
		ELSE
			SELECT fecha_carga, total_registros, total_monto, registros_aceptados, registros_rechazados, nombre_archivo, sistema_cuenta, status_lote
			INTO dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cSistemaCuenta, cStatusLote
			FROM bdicnweb:sw_tr_totales_masivo
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
			
			RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
		END IF;
	
	END;
END PROCEDURE
DOCUMENT "Autor: M.C. Oscar Flores Conde",
"Fecha de creaciÃ³n: 12/08/2013",
"DescripciÃ³n: Procedimiento que consulta el total de registros de un lote cargado, asÃ­ como el nÃºmero de registros cargados correctamente,",
"             el nÃºmero de regitros erroneos, el monto total de la cargas y la fecha de carga, el SP funciona para el masivo de cancelacion de cuentas de crÃ©dito";

CREATE PROCEDURE "informix".sp_tr_actualizastatusmasivo(pUsuario CHAR(8), pIdFunciON CHAR(10), pStatus CHAR(2), pIdRegistros VARCHAR(255))
	RETURNING
		CHAR(5) AS codret,
		INT AS exitosos, 
		INT AS fracasos
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE iExitosos INT;
	DEFINE iFracasos INT;
	DEFINE iCount INT;
	DEFINE iStart INT;
	DEFINE iLength INT;
	DEFINE iRow INT;
	DEFINE cBaseDatos CHAR(50);
	DEFINE cTablaDst CHAR(50);
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExitosos = 0;
	LET iFracasos = 0;
	LET iLength = LENGTH(pIdRegistros);	
	LET iRow = 0;
	LET cBaseDatos = '';
	LET cTablaDst = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iExitosos, iFracasos;
			END IF;
		END EXCEPTION;

		IF pUsuario = '' OR pIdFunciON = ''
				OR pStatus = ''
				OR pIdRegistros = ''
			THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iExitosos, iFracasos;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iExitosos, iFracasos;
		END IF;
		
		LET iStart = 1;
		--set debug file to 'masiva.out';
		--trace on;
		
		SELECT base_datos, tabla
		INTO cBaseDatos, cTablaDst
		FROM sw_tr_info_tablas WHERE id_funcion = pIdFuncion;		
		
		IF cBaseDatos IS NULL OR cBaseDatos = '' THEN
			LET cCodRet = '00154';
			RETURN cCodRet, iExitosos, iFracasos;
		END IF;
		
		FOR iCount = 1 TO iLength
			IF SUBSTR(pIdRegistros, iCount, 1) = '|' THEN
				LET iRow = SUBSTR(pIdRegistros, iStart, iCount - iStart);
				EXECUTE IMMEDIATE "UPDATE " || TRIM(cBaseDatos) || ":" || TRIM(cTablaDst) || " SET status='"|| TRIM(pStatus) ||"' WHERE id_registro=" || iRow;
				LET iRow = dbinfo('sqlca.sqlerrd2');
				
				IF iRow > 0 THEN
					LET iExitosos = iExitosos + 1;
				ELSE
					LET iFracasos = iFracasos + 1;
				END IF;
				LET iStart = iCount + 1;
				
			ELIF iCount = iLength THEN
			
				LET iRow = SUBSTR(pIdRegistros, iStart);
				EXECUTE IMMEDIATE "UPDATE " || TRIM(cBaseDatos) || ":" || TRIM(cTablaDst) || " SET status='"|| TRIM(pStatus) ||"' WHERE id_registro=" || iRow;
				LET iRow = dbinfo('sqlca.sqlerrd2');
				
				IF iRow > 0 THEN
					LET iExitosos = iExitosos + 1;
				ELSE
					LET iFracasos = iFracasos + 1;
				END IF;
				LET iStart = iCount + 1;
			END IF;
		END FOR;
		--trace off;
		RETURN cCodRet, iExitosos, iFracasos;
	END
END PROCEDURE;