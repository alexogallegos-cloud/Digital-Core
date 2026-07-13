CREATE PROCEDURE "informix".sp_consbloqctacre(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20))
	RETURNING CHAR(5) AS codret,
			CHAR(1) AS status_bloqueo_cta,
			SMALLINT AS tipo_bloqueo,
			CHAR(2) AS clave_bloqueo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEstatusBloqueoCta CHAR(1);
	DEFINE iTipoBloqueo SMALLINT;
	DEFINE cClaveBloqueo CHAR(2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEstatusBloqueoCta = '';
	LET iTipoBloqueo = NULL;
	LET cClaveBloqueo = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEstatusBloqueoCta, iTipoBloqueo, cClaveBloqueo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consbloqctacre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEstatusBloqueoCta, iTipoBloqueo, cClaveBloqueo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pCuenta, '06', '1') INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEstatusBloqueoCta, iTipoBloqueo, cClaveBloqueo;
		END IF;
		
		IF (SELECT COUNT(num_credito) FROM bdicred:"informix".sd_maecred WHERE empresa = '001' AND num_credito = pCuenta) = 0 THEN
			LET cCodRet = '00009'; -- LA CUENTA NO EXISTE
			RETURN cCodRet, cEstatusBloqueoCta, iTipoBloqueo, cClaveBloqueo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SELECT id_unidad_prod, cod_caract_2, case when (id_unidad_prod is null and cod_caract_2 is null) then 'D' else 'B' end as status_cta
		INTO iTipoBloqueo, cClaveBloqueo, cEstatusBloqueoCta
		FROM bdicred:"informix".sd_maecred
		WHERE empresa = '001'
			AND num_credito = pCuenta;
			
		RETURN cCodRet, cEstatusBloqueoCta, iTipoBloqueo, cClaveBloqueo;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 18/03/2014',
'DESCRIPCION: Consulta el estatus de bloque de una cuenta de credito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_constotalbloqueomasivocre(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT)
	RETURNING CHAR(5) AS codret,
			INT AS total_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdRegistro INTEGER;
	DEFINE cNoCuenta CHAR(20);
	DEFINE cNoCliente CHAR(20);
	DEFINE cResultado CHAR(15);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cMotivoRechazo CHAR(80);
	DEFINE mSaldo MONEY(14,2);
	DEFINE cNombreCliente CHAR(107);
	DEFINE iTipoBloqueo INTEGER;
	DEFINE cCausaBloqueo CHAR(2);
	DEFINE dFechaBloqueo DATE;
	DEFINE cEmpleado CHAR(8);
	DEFINE cNombreEmpleado CHAR(45);
	DEFINE cStatusRegistro CHAR(1);
	DEFINE iExiste INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdRegistro = 0;
	LET cNoCuenta = '';
	LET cNoCliente = '';
	LET cResultado = '';
	LET cCodRetSp = '';
	LET cMotivoRechazo = '';
	LET mSaldo = NULL;
	LET cNombreCliente = '';
	LET iTipoBloqueo = 0;
	LET cCausaBloqueo = '';
	LET dFechaBloqueo = NULL;
	LET cEmpleado = '';
	LET cNombreEmpleado = '';
	LET cStatusRegistro = '';
	LET iExiste = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_constotalbloqueomasivocre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pLote IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(id_registro)
		INTO iExiste
		FROM 
			(SELECT id_registro
			FROM bdicnweb:"informix".sw_tr_cargamasiva_bloqueocre
			WHERE lote = pLote
			UNION
			SELECT id_registro
			FROM bdicnweb:"informix".sw_tr_cargamasiva_bloqueocre_hist
			WHERE lote = pLote);
		
		IF iExiste = 0 THEN
			LET cCodRet = '00200';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT id_registro, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, saldo_cuenta, 
					tipo_bloqueo, causa_bloqueo, fecha_bloqueo, usuario, status
			INTO iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo,
					iTipoBloqueo, cCausaBloqueo, dFechaBloqueo, cEmpleado, cStatusRegistro
			FROM
				(SELECT id_registro, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, saldo_cuenta, 
						tipo_bloqueo, causa_bloqueo, fecha_bloqueo, usuario, usuario, status
				FROM bdicnweb:sw_tr_cargamasiva_bloqueocre
				WHERE usuario = pUsuario
					AND lote = pLote
				UNION
				SELECT id_registro, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, saldo_cuenta, 
						tipo_bloqueo, causa_bloqueo, fecha_bloqueo, usuario, usuario, status
				FROM bdicnweb:sw_tr_cargamasiva_bloqueocre_hist
				WHERE usuario = pUsuario
					AND lote = pLote)
			ORDER BY id_registro
			
			LET iNoRegistros = iNoRegistros + 1;
			
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iNoRegistros;
		
	END;
			
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 23/07/2014',
'DESCRIPCION: Consulta de los registros de un lote masivo de cuentas a ser bloqueadas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_constotaldesbloqueomasivocre(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT)
	RETURNING CHAR(5) AS codret,
			INT AS no_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdRegistro INTEGER;
	DEFINE cNoCuenta CHAR(20);
	DEFINE cNoCliente CHAR(20);
	DEFINE cResultado CHAR(15);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cMotivoRechazo CHAR(80);
	DEFINE mSaldo MONEY(14,2);
	DEFINE cNombreCliente CHAR(107);
	DEFINE dFechaDesbloqueo DATE;
	DEFINE cEmpleado CHAR(8);
	DEFINE cNombreEmpleado CHAR(45);
	DEFINE cStatusRegistro CHAR(1);
	DEFINE iExiste INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdRegistro = 0;
	LET cNoCuenta = '';
	LET cNoCliente = '';
	LET cResultado = '';
	LET cCodRetSp = '';
	LET cMotivoRechazo = '';
	LET mSaldo = NULL;
	LET cNombreCliente = '';
	LET dFechaDesbloqueo = NULL;
	LET cEmpleado = '';
	LET cNombreEmpleado = '';
	LET cStatusRegistro = '';
	LET iExiste = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_constotaldesbloqueomasivocre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pLote IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(id_registro)
		INTO iExiste
		FROM 
			(SELECT id_registro
			FROM bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocre
			WHERE lote = pLote
			UNION
			SELECT id_registro
			FROM bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocre_hist
			WHERE lote = pLote);
		
		IF iExiste = 0 THEN
			LET cCodRet = '00200';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT id_registro, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, saldo_cuenta, fecha_desbloqueo, usuario, status
			INTO iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, dFechaDesbloqueo, cEmpleado, cStatusRegistro
			FROM
				(SELECT id_registro, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, saldo_cuenta, fecha_desbloqueo, usuario, usuario, status
				FROM bdicnweb:sw_tr_cargamasiva_desbloqueocre
				WHERE usuario = pUsuario
					AND lote = pLote
				UNION
				SELECT id_registro, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, saldo_cuenta, fecha_desbloqueo, usuario, usuario, status
				FROM bdicnweb:sw_tr_cargamasiva_desbloqueocre_hist
				WHERE usuario = pUsuario
					AND lote = pLote)
			ORDER BY id_registro
			
			LET iNoRegistros = iNoRegistros + 1;
			
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iNoRegistros;
		
	END;
			
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 23/07/2014',
'DESCRIPCION: Consulta de los registros de un lote masivo de cuentas a ser bloqueadas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultactabloqueodesbloqueocre(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCuenta CHAR(20), pTipoConsulta CHAR(1))
	RETURNING CHAR(5) AS codret,
			CHAR(20) AS num_cliente,
			CHAR(20) AS num_cuenta,
			CHAR(50) AS nombre_cliente,
			CHAR(4) AS sucursal,
			CHAR(30) AS bloqueo,
			CHAR(50) AS causa,
			CHAR(2) AS status,	
			DATE AS fecha_bloqueo;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeError CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumCuenta CHAR(20);
	DEFINE cNumCliente CHAR(20);
	DEFINE cNombreCliente CHAR(50);
	DEFINE cSucursal CHAR(4);
	DEFINE cBloqueo CHAR(30);
	DEFINE cCausa CHAR(50);
	DEFINE cStatus CHAR(2);
	DEFINE dFechaApertura DATE;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensajeError = '';
	LET cEmpresa = '001';
	LET cNumCuenta = '';
	LET cNumCliente = '';
	LET cNombreCliente = '';
	LET cSucursal = '';
	LET cBloqueo = '';
	LET cCausa = '';
	LET cStatus = '';
	LET dFechaApertura = NULL;

	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCliente, cNumCuenta, cNombreCliente, cSucursal, cBloqueo, cCausa, cStatus, dFechaApertura;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultactabloqueodesbloqueocre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCuenta = '' OR pTipoConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCliente, cNumCuenta, cNombreCliente, cSucursal, cBloqueo, cCausa, cStatus, dFechaApertura;
		END IF;
		
		IF pTipoConsulta NOT IN ('0', '1') THEN
			LET cCodRet = '00044';
			RETURN cCodRet, cNumCliente, cNumCuenta, cNombreCliente, cSucursal, cBloqueo, cCausa, cStatus, dFechaApertura;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD Y A LA CUENTA
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pNumCuenta, '06', '1') INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumCliente, cNumCuenta, cNombreCliente, cSucursal, cBloqueo, cCausa, cStatus, dFechaApertura;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_consultacuenta(cEmpresa, pNumCuenta) 
		INTO cCodRetSp, cMensajeError, cEmpresa, cNumCuenta, cNumCliente, cNombreCliente, cSucursal, cBloqueo, cCausa, cStatus, dFechaApertura;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultacuenta';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 2 AND cStatus <> 'CV' THEN
			LET cCodRet = '00070';
		ELIF iCodRetSp = 2 AND cStatus = 'CV' THEN
			LET cCodRet = '00033';
		ELIF iCodRetSp = 3 THEN -- CREDITO BLOQUEADO MANUALMENTE
			LET cCodRet = '00018';
		ELIF iCodRetSp = 4 THEN -- CREDITO YA HA SIDO BLOQUEADO, NO PODRA BLOQUEAR NUEVAMENTE
			IF pTipoConsulta = '0' THEN
				LET cCodRet = '00019';
			END IF;
		ELIF iCodRetSp = 6 THEN -- LA CUENTA YA ESTA DESBLOQUEADA
			LET cCodRet = '00032';
		END IF;
		
		RETURN cCodRet, cNumCliente, cNumCuenta, cNombreCliente, cSucursal, cBloqueo, cCausa, cStatus, dFechaApertura;
		
	END;
			
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 13/03/2014',
'DESCRIPCION: Consulta el historial de bloqueo/desbloqueo de la cuenta',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultarchivochequesdevueltoscap(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			DATE AS fecha_actualizacion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dFechaUltActualizacion DATE;
	
	LET cCodRet = '';
	LET iSqlErr = 0;
	LET dFechaUltActualizacion = NULL;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFechaUltActualizacion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultarchivochequesdevueltoscap.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechaUltActualizacion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechaUltActualizacion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SELECT max(fecha_entrada)
		INTO dFechaUltActualizacion
		FROM bditef:cce_propios_det;
			
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, dFechaUltActualizacion;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 26/03/2014',
'DESCRIPCION: Consulta la fecha del ultimo archivo que se utilizo en el proceso de cheques devueltos de la cuenta dada',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_totalesbloqueocre(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT)
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
		
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_totalesbloqueocre.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pLote = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
		END IF;
		
		-- Buscamos en la tabla de lotes
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(*)
		INTO iExiste
		FROM bdicnweb:"informix".sw_tr_totales_masivo
		WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		
		-- Buscamos el lote en la tabla de las cargas masivas
		IF iExiste = 0 THEN
			SELECT COUNT(id_registro)
			INTO iExiste
			FROM 
				(SELECT id_registro
				FROM bdicnweb:"informix".sw_tr_cargamasiva_bloqueocre
				WHERE lote = pLote
				UNION
				SELECT id_registro
				FROM bdicnweb:"informix".sw_tr_cargamasiva_bloqueocre_hist
				WHERE lote = pLote);
			
			IF iExiste = 0 THEN
				let cCodRet = '00200';
				RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
			END IF;
			
			LET iExiste = 0;
		END IF;
		
		IF iExiste = 0 THEN
			SET ISOLATION TO DIRTY READ;
			
			SELECT COUNT(id_funcion) 
			INTO iTotalRegistrosAceptados
			FROM bdicnweb:"informix".sw_tr_cargamasiva_bloqueocre
			WHERE lote = pLote AND status = 'C';

			SET ISOLATION TO DIRTY READ;
			
			SELECT COUNT(id_funcion)
			INTO iTotalRegistrosRechazados
			FROM bdicnweb:"informix".sw_tr_cargamasiva_bloqueocre
			WHERE lote = pLote AND status <> 'C';

			SET ISOLATION TO DIRTY READ;
			
			SELECT cm.archivo, cm.fecha_carga
				, COUNT(cm.fecha_carga) AS total_registros
				, 0 AS total_monto
			INTO cNombreArchivoCarga, dFechaCarga, iTotalRegistros, mTotalMonto
			FROM bdicnweb:"informix".sw_tr_cargamasiva_bloqueocre cm
			WHERE cm.lote = pLote		
			GROUP BY cm.archivo, cm.fecha_carga;
			
			-- GUARDAMOS LOS DATOS DEL LOTE EN LA TABLA DE LOTES
			-- Busqueda del nombre del ejecutivo
			SET ISOLATION TO DIRTY READ;
			SELECT nombre
			INTO cNombreEjecutivo
			FROM bdinteg:"informix".si_ejecut
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
			FROM bdicnweb:"informix".sw_tr_totales_masivo
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
			
			RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
		END IF;
	
	END;
END PROCEDURE
DOCUMENT "Autor: M.C. Oscar Flores Conde",
"Fecha de creaciÃ³n: 11/07/2013",
"DescripciÃ³n: Procedimiento que consulta el total de registros de un lote cargado, asÃ­ como el nÃºmero de registros cargados correctamente,",
"             el nÃºmero de regitros erroneos, el monto total de la cargas y la fecha de carga, el SP funciona para el masivo de deposito y retiro de captaciÃ³n";

CREATE PROCEDURE "informix".sp_totalesdesbloqueocre(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT)
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
		
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_totalesdesbloqueocre.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pLote = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
		END IF;
		
		-- Buscamos en la tabla de lotes
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(*)
		INTO iExiste
		FROM bdicnweb:"informix".sw_tr_totales_masivo
		WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		
		-- Buscamos el lote en la tabla de las cargas masivas
		IF iExiste = 0 THEN
			SELECT COUNT(id_registro)
			INTO iExiste
			FROM 
				(SELECT id_registro
				FROM bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocre
				WHERE lote = pLote
				UNION
				SELECT id_registro
				FROM bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocre_hist
				WHERE lote = pLote);
			
			IF iExiste = 0 THEN
				let cCodRet = '00200';
				RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
			END IF;
			
			LET iExiste = 0;
		END IF;
		
		IF iExiste = 0 THEN
			SET ISOLATION TO DIRTY READ;
			
			SELECT COUNT(id_funcion) 
			INTO iTotalRegistrosAceptados
			FROM bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocre
			WHERE lote = pLote AND status = 'C';

			SET ISOLATION TO DIRTY READ;
			
			SELECT COUNT(id_funcion)
			INTO iTotalRegistrosRechazados
			FROM bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocre
			WHERE lote = pLote AND status <> 'C';

			SET ISOLATION TO DIRTY READ;
			
			SELECT cm.archivo, cm.fecha_carga
				, COUNT(cm.fecha_carga) AS total_registros
				, 0 AS total_monto
			INTO cNombreArchivoCarga, dFechaCarga, iTotalRegistros, mTotalMonto
			FROM bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocre cm
			WHERE cm.lote = pLote		
			GROUP BY cm.archivo, cm.fecha_carga;
			
			-- GUARDAMOS LOS DATOS DEL LOTE EN LA TABLA DE LOTES
			-- Busqueda del nombre del ejecutivo
			SET ISOLATION TO DIRTY READ;
			SELECT nombre
			INTO cNombreEjecutivo
			FROM bdinteg:"informix".si_ejecut
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
			FROM bdicnweb:"informix".sw_tr_totales_masivo
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
			
			RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
		END IF;
	
	END;
END PROCEDURE
DOCUMENT "Autor: M.C. Oscar Flores Conde",
"Fecha de creaciÃ³n: 11/07/2013",
"DescripciÃ³n: Procedimiento que consulta el total de registros de un lote cargado, asÃ­ como el nÃºmero de registros cargados correctamente,",
"             el nÃºmero de regitros erroneos, el monto total de la cargas y la fecha de carga, el SP funciona para el masivo de deposito y retiro de captaciÃ³n";

CREATE PROCEDURE "informix".sp_consultachequesdevueltoscap(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pCausalesDevolucion CHAR(100), pCodigosAlertamiento CHAR(30), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
			DATE AS fecha,
			CHAR(20) AS cuenta_deposito,
			CHAR(2) AS cod_alertamiento,
			CHAR(35) AS desc_cod_alertamiento,
			CHAR(20) AS cuenta_cheque,
			CHAR(45) AS banco_emisor,
			CHAR(40) AS nombre_beneficiario,
			INTEGER AS numero_cheque,
			CHAR(3) AS cve_banco,
			MONEY(16,2) AS monto_cheque;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dFecha DATE;
	DEFINE cCuentaDeposito CHAR(20);
	DEFINE cCodigoAlertamiento CHAR(2);
	DEFINE cDescCodAlertamiento CHAR(35);
	DEFINE cCuentaCheque CHAR(20);
	DEFINE cBancoEmisor CHAR(45);
	DEFINE cNombreBeneficiario CHAR(40);
	DEFINE iNoRegistros INTEGER;
	DEFINE cQuery CHAR(250);
	DEFINE cFromQuery CHAR(450);
	DEFINE cWhereQuery CHAR(500);
	DEFINE i INTEGER;
	DEFINE cCaracter CHAR(1);
	DEFINE iNoCheque INTEGER;
	-- DATOS PARA EL VISOR
	DEFINE cveBanco CHAR(3);
	DEFINE mMontoCheque MONEY(16, 2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET dFecha = NULL;
	LET cCuentaDeposito = '';
	LET cCodigoAlertamiento = '';
	LET cDescCodAlertamiento = '';
	LET cCuentaCheque = '';
	LET cBancoEmisor = '';
	LET cNombreBeneficiario = '';
	LET iNoRegistros = 0;
	LET cQuery = '';
	LET cFromQuery = '';
	LET cWhereQuery = '';
	LET i = 0;
	LET cCaracter = '';
	LET iNoCheque = 0;
	LET cveBanco = '';
	LET mMontoCheque = NULL;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha, cCuentaDeposito, cCodigoAlertamiento, cDescCodAlertamiento, cCuentaCheque, cBancoEmisor, cNombreBeneficiario, iNoCheque, cveBanco, mMontoCheque;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultachequesdevueltoscap.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, cCuentaDeposito, cCodigoAlertamiento, cDescCodAlertamiento, cCuentaCheque, cBancoEmisor, cNombreBeneficiario, iNoCheque, cveBanco, mMontoCheque;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dFecha, cCuentaDeposito, cCodigoAlertamiento, cDescCodAlertamiento, cCuentaCheque, cBancoEmisor, cNombreBeneficiario, iNoCheque, cveBanco, mMontoCheque;
		END IF;
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD	
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_permisosejecutivo (pUsuario, pIdFuncion, pCuenta, '01', 1) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFecha, cCuentaDeposito, cCodigoAlertamiento, cDescCodAlertamiento, cCuentaCheque, cBancoEmisor, cNombreBeneficiario, iNoCheque, cveBanco, mMontoCheque;
		END IF;	
		
		LET cQuery = "SELECT SKIP "||pRegistros||" FIRST "||pRecuperacion||" a.fechapresenta, a.cta_deposito AS CUENTA, c.codigo, c.descripcion, a.numcuenta, d.banco||' '||d.descripcion AS BANCO, b.nombre_ben, a.numcheque as numcheque, a.cvebanco, a.monto";
		LET cFromQuery = "FROM ((bditef:cce_cheques_dev a INNER JOIN bditef:cce_detalle b ON b.cuenta_dep = a.cta_deposito AND b.num_cheque = a.numcheque AND MDY(SUBSTRING(b.fecha_presini FROM 5 FOR 2), SUBSTRING(b.fecha_presini FROM 7 FOR 2), SUBSTRING(b.fecha_presini FROM 1 FOR 4)) = a.fechapresenta) INNER JOIN bdinteg:si_coddevcam c ON c.codigo = a.motivo) INNER JOIN bdinteg:si_bancos d ON d.banco = a.cvebanco";
		LET cWhereQuery = "WHERE a.cta_deposito = '"||TRIM(pCuenta)||"' AND a.fechapresenta BETWEEN '"||pFechaInicial||"' AND '"||pFechaFinal||"'";
		
		IF pCausalesDevolucion <> '' THEN
			LET cWhereQuery = TRIM(cWhereQuery)||" AND a.motivo IN ('";
			FOR i = 1 TO LENGTH(TRIM(pCausalesDevolucion))
				LET cCaracter = SUBSTR(TRIM(pCausalesDevolucion), i, 1);
				IF cCaracter <> '|' THEN
					LET cWhereQuery = TRIM(cWhereQuery)||cCaracter;
				ELSE
					LET cWhereQuery = TRIM(cWhereQuery)||"', '";
				END IF;
			END FOR;
			
			LET cWhereQuery = TRIM(cWhereQuery)||"')";
		END IF;
		
		IF pCodigosAlertamiento <> '' THEN
			LET cWhereQuery = TRIM(cWhereQuery)||" AND b.alertamiento IN ('";
			FOR i = 1 TO LENGTH(TRIM(pCodigosAlertamiento))
				LET cCaracter = SUBSTR(TRIM(pCodigosAlertamiento), i, 1);
				IF cCaracter <> '|' THEN
					LET cWhereQuery = TRIM(cWhereQuery)||cCaracter;
				ELSE
					LET cWhereQuery = TRIM(cWhereQuery)||"', '";
				END IF;
			END FOR;
			
			LET cWhereQuery = TRIM(cWhereQuery)||"')";
		END IF;
		
		LET cWhereQuery = TRIM(cWhereQuery)||' ORDER BY a.fechapresenta';
		
		
		PREPARE stmtId FROM TRIM(TRIM(cQuery)||' '||TRIM(cFromQuery)||' '||TRIM(cWhereQuery));
		DECLARE custCur CURSOR FOR stmtId;
		OPEN custCur;
		
		FETCH custCur INTO dFecha, cCuentaDeposito, cCodigoAlertamiento, cDescCodAlertamiento, cCuentaCheque, cBancoEmisor, cNombreBeneficiario, iNoCheque, cveBanco, mMontoCheque;
		WHILE (SQLCODE == 0)
			RETURN cCodRet, dFecha, cCuentaDeposito, cCodigoAlertamiento, cDescCodAlertamiento, cCuentaCheque, cBancoEmisor, cNombreBeneficiario, iNoCheque, cveBanco, mMontoCheque WITH RESUME;
			LET iNoRegistros = iNoRegistros + 1;
			FETCH custCur INTO dFecha, cCuentaDeposito, cCodigoAlertamiento, cDescCodAlertamiento, cCuentaCheque, cBancoEmisor, cNombreBeneficiario, iNoCheque, cveBanco, mMontoCheque;
		END WHILE;
		
		CLOSE custCur;
		FREE custCur;
		FREE stmtId;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFecha, cCuentaDeposito, cCodigoAlertamiento, cDescCodAlertamiento, cCuentaCheque, cBancoEmisor, cNombreBeneficiario, iNoCheque, cveBanco, mMontoCheque;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFecha, cCuentaDeposito, cCodigoAlertamiento, cDescCodAlertamiento, cCuentaCheque, cBancoEmisor, cNombreBeneficiario, iNoCheque, cveBanco, mMontoCheque;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 19/03/2014',
'DESCRIPCION: Consulta de los posibles cheques devueltos para la detección de fraudes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultatotchequesdevueltoscap(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pCausalesDevolucion CHAR(100), pCodigosAlertamiento CHAR(30))
	RETURNING CHAR(5) AS codret,
			INTEGER AS no_registros;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dFecha DATE;
	DEFINE cCuentaDeposito CHAR(20);
	DEFINE cCodigoAlertamiento CHAR(2);
	DEFINE cDescCodAlertamiento CHAR(35);
	DEFINE cCuentaCheque CHAR(20);
	DEFINE cBancoEmisor CHAR(45);
	DEFINE cNombreBeneficiario CHAR(40);
	DEFINE iNoRegistros INTEGER;
	DEFINE cQuery CHAR(200);
	DEFINE cFromQuery CHAR(450);
	DEFINE cWhereQuery CHAR(500);
	DEFINE cCaracter CHAR(1);
	DEFINE i INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET dFecha = NULL;
	LET cCuentaDeposito = '';
	LET cCodigoAlertamiento = '';
	LET cDescCodAlertamiento = '';
	LET cCuentaCheque = '';
	LET cBancoEmisor = '';
	LET cNombreBeneficiario = '';
	LET iNoRegistros = 0;
	LET cQuery = '';
	LET cFromQuery = '';
	LET cWhereQuery = '';
	LET cCaracter = '';
	LET i = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultatotchequesdevueltoscap.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD	
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_permisosejecutivo (pUsuario, pIdFuncion, pCuenta, '01', 1) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;	
		
		LET cQuery = "SELECT count(*)";
		LET cFromQuery = "FROM ((bditef:cce_cheques_dev a INNER JOIN bditef:cce_detalle b ON b.cuenta_dep = a.cta_deposito AND b.num_cheque = a.numcheque AND MDY(SUBSTRING(b.fecha_presini FROM 5 FOR 2), SUBSTRING(b.fecha_presini FROM 7 FOR 2), SUBSTRING(b.fecha_presini FROM 1 FOR 4))= a.fechapresenta) INNER JOIN bdinteg:si_coddevcam c ON c.codigo = a.motivo) INNER JOIN bdinteg:si_bancos d ON d.banco = a.cvebanco";
		LET cWhereQuery = "WHERE a.cta_deposito = '"||TRIM(pCuenta)||"' AND a.fechapresenta BETWEEN '"||pFechaInicial||"' AND '"||pFechaFinal||"'";
		
		IF pCausalesDevolucion <> '' THEN
			LET cWhereQuery = TRIM(cWhereQuery)||" AND a.motivo IN ('";
			FOR i = 1 TO LENGTH(TRIM(pCausalesDevolucion))
				LET cCaracter = SUBSTR(TRIM(pCausalesDevolucion), i, 1);
				IF cCaracter <> '|' THEN
					LET cWhereQuery = TRIM(cWhereQuery)||cCaracter;
				ELSE
					LET cWhereQuery = TRIM(cWhereQuery)||"', '";
				END IF;
			END FOR;
			
			LET cWhereQuery = TRIM(cWhereQuery)||"')";
		END IF;
		
		IF pCodigosAlertamiento <> '' THEN
			LET cWhereQuery = TRIM(cWhereQuery)||" AND b.alertamiento IN ('";
			FOR i = 1 TO LENGTH(TRIM(pCodigosAlertamiento))
				LET cCaracter = SUBSTR(TRIM(pCodigosAlertamiento), i, 1);
				IF cCaracter <> '|' THEN
					LET cWhereQuery = TRIM(cWhereQuery)||cCaracter;
				ELSE
					LET cWhereQuery = TRIM(cWhereQuery)||"', '";
				END IF;
			END FOR;
			
			LET cWhereQuery = TRIM(cWhereQuery)||"')";
		END IF;
		
		PREPARE stmtId FROM TRIM(cQuery)||' '||TRIM(cFromQuery)||' '||TRIM(cWhereQuery);
		DECLARE custCur cursor FOR stmtId;
		OPEN custCur;
		
		FETCH custCur INTO iNoRegistros;
		
		CLOSE custCur;
		FREE custCur;
		FREE stmtId;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		RETURN cCodRet, iNoRegistros;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 19/03/2014',
'DESCRIPCION: Consulta el total de los posibles cheques devueltos para la detección de fraudes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualizastatusnvasfuncre(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCredito CHAR(20))
		RETURNING CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cMensajeRetorno CHAR(120);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cMensajeRetorno = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_actualizastatusnvasfuncre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCredito = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pNumCredito, '06', '1') INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_actualizastatuscred(cEmpresa, pNumCredito)
		INTO cCodRetSp, cMensajeRetorno;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_actualizastatuscred';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00276';
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00277';
		END IF;
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 31/03/2014',
'DESCRIPCION: Realizar la actualizacion del estatus de credito de acuerdo al cuadre de credito proporcionado',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultamovtosnvasfuncre(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCredito CHAR(20))
		RETURNING CHAR(5) AS codret,
				CHAR(20) AS numcte,
				CHAR(4) AS sucursal,
				CHAR(2) AS statuscred,
				INTEGER AS plazo,
				DATE AS fechaapertura,
				DATE AS fechavencimiento,
				DECIMAL(9,6) AS tasainteres,
				DECIMAL(9,6) AS tasamoratorios,
				DECIMAL(18,2) AS sdoretenido,
				DECIMAL(18,2) AS sdonoexig,
				DECIMAL(18,2) AS sdocontabmora,
				DECIMAL(18,2) AS sdocapital,
				DECIMAL(18,2) AS sdocapinsoluto,
				DECIMAL(18,2) AS sdomtovdo,
				DECIMAL(18,2) AS mtovdotrasp,
				DECIMAL(18,2) AS mtofinanciado,
				DECIMAL(18,2) AS mtootorgado,
				DECIMAL(18,2) AS captrasnovdo,
				DECIMAL(18,2) AS mtovdoint,
				DECIMAL(18,2) AS mtovdotrasint,
				DECIMAL(18,2) AS inttranoexig,
				CHAR(60) AS desctpocart,
				CHAR(2) AS codtpocred,
				DECIMAL(5,3) AS porciva,
				DECIMAL(18,2) AS moratorio,
				DECIMAL(18,2) AS ivamoratorio,
				DECIMAL(18,2) AS ivaintvenc,
				DECIMAL(18,2) AS interesmes,
				DECIMAL(18,2) AS ivames,
				DECIMAL(18,2) AS totalliquidacion,
				DECIMAL(18,2) AS intmoracope,
				DECIMAL(18,2) AS ivaintmoracope,
				DECIMAL(18,2) AS intmorabase,
				DECIMAL(18,2) AS ivaintmorabase,
				DECIMAL(18,2) AS ivaintmoracopebase,
				DECIMAL(18,2) AS capitaltotal,
				DECIMAL(18,2) AS interesvigente,
				DECIMAL(18,2) AS ivainteresvigente;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRetorno CHAR(120);
	DEFINE cEmpresa CHAR(3);
	-- VARIABLES DEL SP
	DEFINE cNumCliente CHAR(20);
	DEFINE cSucursal CHAR(4);
	DEFINE cStatusCred CHAR(2);
	DEFINE iPlazo INTEGER;
	DEFINE dFechaApertura DATE;
	DEFINE dFechaVencimiento DATE;
	DEFINE dTasaInteres DECIMAL(9,6);
	DEFINE dTasaMoratorios DECIMAL(9,6);
	DEFINE dSdoRetenido DECIMAL(18,2);
	DEFINE dSdoNoExig DECIMAL(18,2);
	DEFINE dSdoContabMora DECIMAL(18,2);
	DEFINE dSdoCapital DECIMAL(18,2);
	DEFINE dSdoCapInsoluto DECIMAL(18,2);
	DEFINE dSdoMtoVdo DECIMAL(18,2);
	DEFINE dMtoVdoTrasp DECIMAL(18,2);
	DEFINE dMtoFinanciado DECIMAL(18,2);
	DEFINE dMtoOtorgado DECIMAL(18,2);
	DEFINE dCapTrasnoVdo DECIMAL(18,2);
	DEFINE dMtoVdoInt DECIMAL(18,2);
	DEFINE dMtoVdoTrasInt DECIMAL(18,2);
	DEFINE dIntTraNoExig DECIMAL(18,2);
	DEFINE cDescTpoCart CHAR(60);
	DEFINE cCodTpoCred CHAR(2);
	DEFINE dPorcIva DECIMAL(5,3);
	DEFINE dMoratorio DECIMAL(18,2);
	DEFINE dIvaMoratorio DECIMAL(18,2);
	DEFINE dIvaIntVenc DECIMAL(18,2);
	DEFINE dInteresMes DECIMAL(18,2);
	DEFINE dIvaMes DECIMAL(18,2);
	DEFINE dTotalLiquidacion DECIMAL(18,2);
	DEFINE dIntMoraCope DECIMAL(18,2);
	DEFINE dIvaIntMoraCope DECIMAL(18,2);
	DEFINE dIntMoraBase DECIMAL(18,2);
	DEFINE dIvaIntMoraBase DECIMAL(18,2);
	DEFINE dIvaIntMoraCopeBase DECIMAL(18,2);
	DEFINE dCapitalTotal DECIMAL(18,2);
	DEFINE dInteresVigente DECIMAL(18,2);
	DEFINE dIvaInteresVigente DECIMAL(18,2);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensajeRetorno = '';
	LET cEmpresa = '001';
	-- VARIABLES DEL SP
	LET cNumCliente = '';
	LET cSucursal = '';
	LET cStatusCred = '';
	LET iPlazo = 0;
	LET dFechaApertura = NULL;
	LET dFechaVencimiento = NULL;
	LET dTasaInteres = NULL;
	LET dTasaMoratorios = NULL;
	LET dSdoRetenido = NULL;
	LET dSdoNoExig = NULL;
	LET dSdoContabMora = NULL;
	LET dSdoCapital = NULL;
	LET dSdoCapInsoluto = NULL;
	LET dSdoMtoVdo = NULL;
	LET dMtoVdoTrasp = NULL;
	LET dMtoFinanciado = NULL;
	LET dMtoOtorgado = NULL;
	LET dCapTrasnoVdo = NULL;
	LET dMtoVdoInt = NULL;
	LET dMtoVdoTrasInt = NULL;
	LET dIntTraNoExig = NULL;
	LET cDescTpoCart = '';
	LET cCodTpoCred = '';
	LET dPorcIva = NULL;
	LET dMoratorio = NULL;
	LET dIvaMoratorio = NULL;
	LET dIvaIntVenc = NULL;
	LET dInteresMes = NULL;
	LET dIvaMes = NULL;
	LET dTotalLiquidacion = NULL;
	LET dIntMoraCope = NULL;
	LET dIvaIntMoraCope = NULL;
	LET dIntMoraBase = NULL;
	LET dIvaIntMoraBase = NULL;
	LET dIvaIntMoraCopeBase = NULL;
	LET dCapitalTotal = NULL;
	LET dInteresVigente = NULL;
	LET dIvaInteresVigente = NULL;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCliente, cSucursal, cStatusCred, iPlazo, dFechaApertura, dFechaVencimiento, dTasaInteres, dTasaMoratorios, dSdoRetenido, 
					dSdoNoExig, dSdoContabMora, dSdoCapital, dSdoCapInsoluto, dSdoMtoVdo, dMtoVdoTrasp, dMtoFinanciado, dMtoOtorgado, dCapTrasnoVdo, dMtoVdoInt, 
					dMtoVdoTrasInt, dIntTraNoExig, cDescTpoCart, cCodTpoCred, dPorcIva, dMoratorio, dIvaMoratorio, dIvaIntVenc, dInteresMes, dIvaMes, dTotalLiquidacion, 
					dIntMoraCope, dIvaIntMoraCope, dIntMoraBase, dIvaIntMoraBase, dIvaIntMoraCopeBase, dCapitalTotal, dInteresVigente, dIvaInteresVigente;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultamovtosnvasfuncre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCredito = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCliente, cSucursal, cStatusCred, iPlazo, dFechaApertura, dFechaVencimiento, dTasaInteres, dTasaMoratorios, dSdoRetenido, 
					dSdoNoExig, dSdoContabMora, dSdoCapital, dSdoCapInsoluto, dSdoMtoVdo, dMtoVdoTrasp, dMtoFinanciado, dMtoOtorgado, dCapTrasnoVdo, dMtoVdoInt, 
					dMtoVdoTrasInt, dIntTraNoExig, cDescTpoCart, cCodTpoCred, dPorcIva, dMoratorio, dIvaMoratorio, dIvaIntVenc, dInteresMes, dIvaMes, dTotalLiquidacion, 
					dIntMoraCope, dIvaIntMoraCope, dIntMoraBase, dIvaIntMoraBase, dIvaIntMoraCopeBase, dCapitalTotal, dInteresVigente, dIvaInteresVigente;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pNumCredito, '06', '1') INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumCliente, cSucursal, cStatusCred, iPlazo, dFechaApertura, dFechaVencimiento, dTasaInteres, dTasaMoratorios, dSdoRetenido, 
					dSdoNoExig, dSdoContabMora, dSdoCapital, dSdoCapInsoluto, dSdoMtoVdo, dMtoVdoTrasp, dMtoFinanciado, dMtoOtorgado, dCapTrasnoVdo, dMtoVdoInt, 
					dMtoVdoTrasInt, dIntTraNoExig, cDescTpoCart, cCodTpoCred, dPorcIva, dMoratorio, dIvaMoratorio, dIvaIntVenc, dInteresMes, dIvaMes, dTotalLiquidacion, 
					dIntMoraCope, dIvaIntMoraCope, dIntMoraBase, dIvaIntMoraBase, dIvaIntMoraCopeBase, dCapitalTotal, dInteresVigente, dIvaInteresVigente;
		END IF;
		
		
		EXECUTE PROCEDURE bdicred:"informix".sp_cargamovtosnvasfunc(cEmpresa, pNumCredito)
		INTO cCodRetSp, cMensajeRetorno, cNumCliente, cSucursal, cStatusCred, iPlazo, dFechaApertura, dFechaVencimiento, dTasaInteres, dTasaMoratorios, 
			dSdoRetenido, dSdoNoExig, dSdoContabMora, dSdoCapital, dSdoCapInsoluto, dSdoMtoVdo, dMtoVdoTrasp, dMtoFinanciado, dMtoOtorgado, dCapTrasnoVdo, 
			dMtoVdoInt, dMtoVdoTrasInt, dIntTraNoExig, cDescTpoCart, cCodTpoCred, dPorcIva, dMoratorio, dIvaMoratorio, dIvaIntVenc, dInteresMes, dIvaMes, 
			dTotalLiquidacion, dIntMoraCope, dIvaIntMoraCope, dIntMoraBase, dIvaIntMoraBase, dIvaIntMoraCopeBase, dCapitalTotal, dInteresVigente, dIvaInteresVigente;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, cMensajeRetorno;
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00009';
		END IF;
		
		RETURN cCodRet, cNumCliente, cSucursal, cStatusCred, iPlazo, dFechaApertura, dFechaVencimiento, dTasaInteres, dTasaMoratorios, dSdoRetenido, 
					dSdoNoExig, dSdoContabMora, dSdoCapital, dSdoCapInsoluto, dSdoMtoVdo, dMtoVdoTrasp, dMtoFinanciado, dMtoOtorgado, dCapTrasnoVdo, dMtoVdoInt, 
					dMtoVdoTrasInt, dIntTraNoExig, cDescTpoCart, cCodTpoCred, dPorcIva, dMoratorio, dIvaMoratorio, dIvaIntVenc, dInteresMes, dIvaMes, dTotalLiquidacion, 
					dIntMoraCope, dIvaIntMoraCope, dIntMoraBase, dIvaIntMoraBase, dIvaIntMoraCopeBase, dCapitalTotal, dInteresVigente, dIvaInteresVigente;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 31/03/2014',
'DESCRIPCION: Consulta de los movimientos de saldos maestros de credito de una cuenta',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_modmaesdoscentralnvasfuncre(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCredito CHAR(20), pTipoSaldo CHAR(2), pQuitaAbono DECIMAL(18,2),
													pCastigoAbono DECIMAL(18,2), pQuebrantoAbono DECIMAL(18,2), pAjusteCargo DECIMAL(18,2), pAjusteAbono DECIMAL(18,2),
													pCondonacionAbono DECIMAL(18,2), pIvaInteresVigente DECIMAL(18,2), pIvaInteresVencido DECIMAL(18,2), pMontoActual DECIMAL(18,2),
													pDescripcionMovimiento CHAR(100))
		RETURNING CHAR(5) AS codret,
				CHAR(80) AS mensaje_retorno,
				DECIMAL(18,2) AS monto_actual,
				DECIMAL(18,2) AS cantidad_actualizar,
				DECIMAL(18,2) AS monto_actual_despues_afectacion,
				CHAR(16) AS folio;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cMensajeretorno CHAR(80);
	DEFINE dMontoActual DECIMAL(18,2);
	DEFINE dCantidadActuaizar DECIMAL(18,2);
	DEFINE dMontoActualDespuesAfectacion DECIMAL(18,2);
	DEFINE cFolio CHAR(16);
	DEFINE bInTransaction BOOLEAN;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cMensajeretorno = '';
	LET dMontoActual = NULL;
	LET dCantidadActuaizar = NULL;
	LET dMontoActualDespuesAfectacion = NULL;
	LET cFolio = '';
	LET bInTransaction = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			
			IF bInTransaction = 'f' THEN
				BEGIN;
			END IF;
			
			RETURN cCodRet, UPPER(cMensajeretorno), NVL(dMontoActual, 0), NVL(dCantidadActuaizar, 0), NVL(dMontoActualDespuesAfectacion, 0), cFolio;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-255)
			LET bInTransaction = 'f';
		END EXCEPTION WITH RESUME;
		
		BEGIN;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_modmaesdoscentralnvasfuncre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCredito = '' OR pTipoSaldo = '' OR pAjusteCargo IS NULL OR pAjusteAbono IS NULL OR 
				pCondonacionAbono IS NULL OR pIvaInteresVigente IS NULL OR 
				pIvaInteresVencido IS NULL OR pMontoActual IS NULL THEN
			LET cCodRet = '00003';
			
			IF bInTransaction THEN
				BEGIN WORK;
			ELSE
				ROLLBACK;
			END IF;
			
			RETURN cCodRet, UPPER(cMensajeretorno), NVL(dMontoActual, 0), NVL(dCantidadActuaizar, 0), NVL(dMontoActualDespuesAfectacion, 0), cFolio;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pNumCredito, '06', '1') INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, UPPER(cMensajeretorno), NVL(dMontoActual, 0), NVL(dCantidadActuaizar, 0), NVL(dMontoActualDespuesAfectacion, 0), cFolio;
		END IF;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_modmaesdos_central(cEmpresa, pNumCredito, pTipoSaldo, pQuitaAbono, pCastigoAbono, pQuebrantoAbono, pAjusteCargo, pAjusteAbono, 
															pCondonacionAbono, pIvaInteresVigente, pIvaInteresVencido, pMontoActual, pDescripcionMovimiento, pUsuario, '')
		INTO cCodRetSp, cMensajeretorno, dMontoActual, dCantidadActuaizar, dMontoActual, cFolio;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_modmaesdos_central';
		ELIF iCodRetSp > 0 THEN
			LET cCodRet = '90000';
		END IF;
		
		IF bInTransaction THEN
			BEGIN;
		END IF;
		
		IF bInTransaction = 'f' THEN
			BEGIN;
		END IF;
		
		RETURN cCodRet, UPPER(cMensajeretorno), NVL(dMontoActual, 0), NVL(dCantidadActuaizar, 0), NVL(dMontoActualDespuesAfectacion, 0), cFolio;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 31/03/2014',
'DESCRIPCION: Actualiza los saldos de capital en el maestro de saldos de credito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultahuellascte(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4), pNumCliente CHAR(20))
		RETURNING CHAR(5) AS codret,
				CHAR(942) AS mapad,
				CHAR(942) AS mapai;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cHuellaDerecha CHAR(942);
	DEFINE cHuellaIzquierda CHAR(942);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cHuellaDerecha = '';
	LET cHuellaIzquierda = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cHuellaDerecha, cHuellaIzquierda;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultahuellascte.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' OR pNumCliente = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cHuellaDerecha, cHuellaIzquierda;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cHuellaDerecha, cHuellaIzquierda;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_conhuella(cEmpresa, pSucursal, pUsuario, pNumCliente)
		INTO cCodRetSp, cHuellaDerecha, cHuellaIzquierda;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_conhuella';
		ELIF iCodRetSp = 110 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 112 THEN
			LET cCodRet = '00006';
		ELIF iCodRetSp = 132 THEN
			LET cCodRet = '00312';
		END IF;
		
		RETURN cCodRet, cHuellaDerecha, cHuellaIzquierda;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 18/06/2014',
'DESCRIPCION: Consulta las huellas de un cliente fÃ­sico',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_guardacausaimpresionedocta(pUsuario CHAR(8), pIdFuncion CHAR(10), pNoCliente CHAR(20), pNoCuenta CHAR(20), pSistemaCuenta CHAR(2), pIdMotivo INTEGER)
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iRegs INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iRegs = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_guardacausaimpresionedocta.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNoCliente = '' OR pNoCuenta = '' OR pSistemaCuenta = '' OR pIdMotivo IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		INSERT INTO "informix".kw_motivos_impresion_cfdi(cliente, cuenta, sistema_cuenta, id_motivo)
		VALUES (pNoCliente, pNoCuenta, pSistemaCuenta, pIdMotivo);
		
		LET iRegs = DBINFO('sqlca.sqlerrd2');
		IF iRegs = 0 THEN
			LET cCodRet = '00282';
		END IF;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 23/07/2014',
'DESCRIPCION: Guarda el motivo de impresiÃ³n de un estado de cuenta CFDI en el kiosko',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaperiodosreportesespecialesac(pUsuario CHAR(8), pIdFuncion CHAR(10), pConvenio CHAR(5),  pTipoPeriodo CHAR(1)) --S => Semanal, M => Mensual
	RETURNING CHAR(5) AS codigoRetorno,
	CHAR(10) AS fecIniperiodo,
	CHAR(10) AS fecFinperiodo,
	INTEGER AS consecutivoconvenio;

	DEFINE cCodRet CHAR(5);
	DEFINE isqlerr INTEGER;
	DEFINE cFecIniperiodo CHAR(10);
	DEFINE cFecFinperiodo CHAR(10);
	DEFINE iNumRows INTEGER;
	DEFINE iConsecutivoConvenio INTEGER;
	DEFINE cQuery CHAR(1500);
	DEFINE cTabla CHAR(200);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cFecIniperiodo = '';
	LET cFecFinperiodo = '';
	LET iNumRows = 0;
	LET iConsecutivoConvenio = 0;
	LET cTabla = '';
	LET cQuery = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iConsecutivoConvenio, cFecIniperiodo, cFecFinperiodo;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinissp_consultaperiodosreportesespecialesac.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pConvenio = '' OR pTipoPeriodo = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iConsecutivoConvenio, cFecIniperiodo, cFecFinperiodo;
		END IF;

		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
				RETURN cCodRet, cFecIniperiodo, cFecFinperiodo, iConsecutivoConvenio;
		END IF;

		IF pTipoPeriodo = 'S' THEN --SEMANAL
			SELECT COUNT(id_convenio) INTO iNumRows FROM bdisac:sac_liquidacionsemanal WHERE id_convenio = pConvenio;
			IF iNumRows <> 0 THEN
				FOREACH
					SELECT consecutivo_convenio, to_char(fec_iniperiodo, '%d/%m/%Y'), to_char(fec_finperiodo, '%d/%m/%Y')
					INTO iConsecutivoConvenio, cFecIniperiodo, cFecFinperiodo
					FROM bdisac:sac_liquidacionsemanal WHERE id_convenio =  pConvenio
					RETURN cCodRet, cFecIniperiodo, cFecFinperiodo, iConsecutivoConvenio WITH RESUME;
				END FOREACH;
			ELSE
				LET cCodRet = '00017';
				RETURN cCodRet, cFecIniperiodo, cFecFinperiodo, iConsecutivoConvenio;
			END IF;
		ELIF pTipoPeriodo  = 'M' THEN --MENSUAL
			SELECT COUNT(id_convenio) INTO iNumRows FROM bdisac:sac_liquidacionmensual WHERE id_convenio = pConvenio;
			IF iNumRows <> 0 THEN
				LET cTabla = TRIM(cTabla)||"sac_liquidacionmensual WHERE id_convenio = '"||TRIM(pConvenio)||"'GROUP BY id_convenio, aniomes ORDER BY aniomes;";
			ELIF pConvenio = '06001' THEN
				LET cTabla = ' sac_liquidacionmensualsky GROUP BY 1,2 ORDER BY 2';
			ELIF pConvenio = '06002' THEN
				LET cTabla = 'sac_liquidacionmensualdish GROUP BY 1,2 ORDER BY 2';
				ELIF pConvenio = '06003' THEN
				LET cTabla = 'sac_liquidacionmensualmastv GROUP BY 1,2 ORDER BY 2';
			ELSE
				LET cCodRet = '00017';
				RETURN cCodRet, cFecIniperiodo, cFecFinperiodo, iConsecutivoConvenio;
			END IF;
			LET cQuery = "SELECT DECODE(SUBSTRING(aniomes FROM 5 FOR 2), '01', 'ENERO', '02', 'FEBRERO', '03', 'MARZO',  '04', 'ABRIL', '05', 'MAYO',";
			LET cQuery = TRIM(cQuery)||" '06', 'JUNIO', '07', 'JULIO', '08', 'AGOSTO', '09', 'SEPTIEMBRE', '10', 'OCTUBRE', '11', 'NOVIEMBRE', '12', 'DICIEMBRE')";
			LET cQuery = TRIM(cQuery)||" as periodo, SUBSTRING(aniomes FROM 1 FOR 4) as aniomes";
			LET cQuery = TRIM(cQuery)||" FROM bdisac:"||TRIM(cTabla);

			PREPARE countQry FROM TRIM(cQuery);
			DECLARE countcur CURSOR FOR countQry;
			OPEN countcur;
			FETCH countcur INTO cFecIniperiodo, cFecFinperiodo;
			IF (SQLCODE = 100) THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cFecIniperiodo, cFecFinperiodo, iConsecutivoConvenio;
			END IF;
			WHILE(SQLCODE = 0)
				RETURN cCodRet, iConsecutivoConvenio, cFecIniperiodo, cFecFinperiodo WITH RESUME;
				FETCH countcur INTO cFecIniperiodo, cFecFinperiodo;
			END WHILE
			CLOSE countcur;
			FREE countcur;
			FREE countQry;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martín';

CREATE PROCEDURE "informix".sp_reportesemanalconveniosac(pUsuario CHAR(8), pIdFuncion CHAR(10), pConvenio CHAR (5), pKeyCons INTEGER)
	RETURNING
	CHAR(5) AS codigoRetorno,
	INTEGER AS recLunes,
	INTEGER AS recMartes,
	INTEGER AS recMiercoles,
	INTEGER AS recJueves,
	INTEGER AS recViernes,
	INTEGER AS recSabado,
	INTEGER AS recDomingo,
	MONEY(16,2) AS cobLunes,
	MONEY(16,2) AS cobMartes,
	MONEY(16,2) AS cobMiercoles,
	MONEY(16,2) AS cobJueves,
	MONEY(16,2) AS cobViernes,
	MONEY(16,2) AS cobSabado,
	MONEY(16,2) AS cobDomingo,
	INTEGER AS recEfectivo,
	INTEGER AS recChequemb,
	INTEGER AS recChequeob,
	INTEGER AS recTarcred,
	MONEY(16,2) AS cobEfectivo,
	MONEY(16,2) AS cobCheqmb,
	MONEY(16,2) AS cobCheqob,
	MONEY(16,2) AS cobTarcred,
	MONEY(16,2) AS liqLunes,
	MONEY(16,2) AS liqMartes,
	MONEY(16,2) AS liqMiercoles,
	MONEY(16,2) AS liqJueves,
	MONEY(16,2) AS liqViernes,
	MONEY(16,2) AS liqSabado,
	MONEY(16,2) AS liqDomingo,
	MONEY(16,2) AS aclaraciones,
	MONEY(16,2) AS comision,
	MONEY(16,2) AS ivaComision,
	DATE AS fecIniperiodo,
	DATE AS fecFinperiodo,
	INTEGER AS iKeyx;

	DEFINE cCodRet CHAR (5);
	DEFINE cCodRetSp CHAR (6);
	DEFINE iSqlErr INTEGER;
	DEFINE iNumRows INTEGER;
	DEFINE iRecLunes INTEGER;
	DEFINE iRecMartes INTEGER;
	DEFINE iRecMiercoles INTEGER;
	DEFINE iRecJueves INTEGER;
	DEFINE iRecViernes INTEGER;
	DEFINE iRecSabado INTEGER;
	DEFINE iRecDomingo INTEGER;
	DEFINE mCobLunes MONEY(16,2);
	DEFINE mCobMartes MONEY(16,2);
	DEFINE mCobMiercoles MONEY(16,2);
	DEFINE mCobJueves MONEY(16,2);
	DEFINE mCobViernes MONEY(16,2);
	DEFINE mCobSabado MONEY(16,2);
	DEFINE mCobDomingo MONEY(16,2);
	DEFINE iRecEfectivo INTEGER;
	DEFINE iRecChequemb INTEGER;
	DEFINE iRecChequeob INTEGER;
	DEFINE iRecTarcred INTEGER;
	DEFINE mCobEfectivo INTEGER;
	DEFINE mCobCheqmb MONEY(16,2);
	DEFINE mCobCheqob MONEY(16,2);
	DEFINE mCobTarcred MONEY(16,2);
	DEFINE mLiqLunes MONEY(16,2);
	DEFINE mLiqMartes MONEY(16,2);
	DEFINE mLiqMiercoles MONEY(16,2);
	DEFINE mLiqJueves MONEY(16,2);
	DEFINE mLiqViernes MONEY(16,2);
	DEFINE mLiqSabado MONEY(16,2);
	DEFINE mLiqDomingo MONEY(16,2);
	DEFINE mAclaraciones MONEY(16,2);
	DEFINE mComision MONEY(16,2);
	DEFINE mIvaComision MONEY(16,2);
	DEFINE dFecIniPeriodo DATE;
	DEFINE dFecFinPeriodo DATE;
	DEFINE iKeyx INTEGER;

	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET iNumRows = 0;
	LET iRecLunes  = 0;
	LET iRecMartes  = 0;
	LET iRecMiercoles  = 0;
	LET iRecJueves  = 0;
	LET iRecViernes  = 0;
	LET iRecSabado  = 0;
	LET iRecDomingo  = 0;
	LET mCobLunes  = 0;
	LET mCobMartes  = 0;
	LET mCobMiercoles  = 0;
	LET mCobJueves  = 0;
	LET mCobViernes  = 0;
	LET mCobSabado  = 0;
	LET mCobDomingo  = 0;
	LET iRecEfectivo  = 0;
	LET iRecChequemb  = 0;
	LET iRecChequeob  = 0;
	LET iRecTarcred  = 0;
	LET mCobEfectivo  = 0;
	LET mCobCheqmb  = 0;
	LET mCobCheqob  = 0;
	LET mCobTarcred  = 0;
	LET mLiqLunes  = 0;
	LET mLiqMartes  = 0;
	LET mLiqMiercoles  = 0;
	LET mLiqJueves  = 0;
	LET mLiqViernes  = 0;
	LET mLiqSabado  = 0;
	LET mLiqDomingo  = 0;
	LET mAclaraciones  = 0;
	LET mComision  = 0;
	LET mIvaComision  = 0;
	LET dFecIniPeriodo = NULL;
	LET dFecFinPeriodo = NULL;
	LET iKeyx = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
					LET cCodRet = iSqlErr;
					RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred,
					mCobEfectivo, mCobCheqmb, mCobCheqob, mCobTarcred,  mLiqLunes, mLiqMartes, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqSabado, mLiqDomingo, mAclaraciones, mComision, mIvaComision, dFecIniperiodo, dFecFinperiodo, iKeyx;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_reportesemanalconveniosac_dos.out';
		--TRACE ON;

		IF pUsuario = '' OR  pIdFuncion = '' OR pConvenio = '' OR pKeyCons = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
				mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred,
				mCobEfectivo, mCobCheqmb, mCobCheqob, mCobTarcred,   mLiqLunes, mLiqMartes, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqSabado, 
				mLiqDomingo, mAclaraciones, mComision, mIvaComision, dFecIniperiodo, dFecFinperiodo, iKeyx;
		END IF;

		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF      cCodRet <> '00000' THEN
				RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
				mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred,
				mCobEfectivo, mCobCheqmb, mCobCheqob, mCobTarcred,  mLiqLunes, mLiqMartes, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqSabado, mLiqDomingo, mAclaraciones, mComision, mIvaComision, dFecIniperiodo, dFecFinperiodo, iKeyx;
		END IF;

		SELECT COUNT(*)
		INTO iNumRows
		FROM bdisac:sac_liquidacionsemanal
		WHERE id_convenio = pConvenio AND  consecutivo_convenio  = pKeyCons;
		IF iNumRows <> 0 THEN
			FOREACH
				EXECUTE PROCEDURE bdisac:sp_sacreportesemanal(pConvenio ,pKeyCons)
				INTO cCodRetSp,iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, mCobEfectivo,
						mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision,
						mIvaComision, dFecIniPeriodo, dFecFinPeriodo, pKeyCons
					IF cCodRetSp = '000000' THEN
						RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo,
						mCobLunes, mCobMartes,
						mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, 
					iRecChequeob, iRecTarcred, mCobEfectivo, mCobCheqmb, mCobCheqob, mCobTarcred,  mLiqLunes, mLiqMartes, 
						mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqSabado, mLiqDomingo,
						mAclaraciones, mComision, mIvaComision, dFecIniperiodo, dFecFinperiodo, iKeyx WITH RESUME;
					ELSE
						LET cCodRet = cCodRetSp;
						RETURN cCodRet, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0,0, 0, 0, NULL, NULL, 0;
					END IF;
			END FOREACH;
		ELSE
			LET cCodRet = '00017';
			RETURN cCodRet, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0,0, 0, 0, NULL, NULL, 0;
		END IF;
	END;
END PROCEDURE;