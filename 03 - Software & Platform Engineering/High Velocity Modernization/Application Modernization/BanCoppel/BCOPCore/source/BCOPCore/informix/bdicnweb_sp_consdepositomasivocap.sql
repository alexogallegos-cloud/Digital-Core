CREATE PROCEDURE "informix".sp_consdepositomasivocap(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT, pRegistros INT, pRecuperacion INT)
	RETURNING CHAR(5) AS codret,
		INT AS id,
		CHAR(20) AS cuenta,
		CHAR(20) AS num_cte,
		CHAR(15) AS resultado,
		CHAR(5) AS codRetSp,
		CHAR(100) AS motivo_rechazo,
		CHAR(20) AS folio, 
		MONEY(14,2) AS saldo,
		CHAR(4) AS transaccion,
		INT AS doc_cheque,
		MONEY(14,2) AS importe_depositar,
		CHAR(255) AS referencia,
		CHAR(1) AS status;
	
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE iExiste INT;
	DEFINE iIdRegistro INT;
	DEFINE cCuenta CHAR(20);
	DEFINE cResultado CHAR(15);
	DEFINE cCodRetSp CHAR(5);
	DEFINE cMotivoRechazo CHAR(100);
	DEFINE cFolio CHAR(20);
	DEFINE mSaldo money(14,2);
	DEFINE cTransacc CHAR(4);
	DEFINE cDoctoChq INT;
	DEFINE mDeposito money(14,2);
	DEFINE cReferencia CHAR(255);
	DEFINE cStatus CHAR(1);
	DEFINE iRegistros int;
	DEFINE cNumCliente char(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET iIdRegistro = 0;
	LET cCuenta = '';
	LET cResultado = '';
	LET cCodRetSp = '';
	LET cMotivoRechazo = '';
	LET cFolio = '';
	LET mSaldo = null;
	LET cTransacc = '';
	LET cDoctoChq = 0;
	LET mDeposito = 0;
	LET cReferencia = '';
	LET cStatus = '';
	LET iRegistros = 0;
	LET cNumCliente = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdRegistro, cCuenta, cNumCliente, cResultado, cCodRetSp, cMotivoRechazo, cFolio, mSaldo, cTransacc, cDoctoChq, mDeposito, cReferencia, cStatus;
		END EXCEPTION
		
		IF pUsuario = '' OR pIdFuncion = '' OR pLote = '' OR pRegistros = '' OR pRecuperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdRegistro, cCuenta, cNumCliente, cResultado, cCodRetSp, cMotivoRechazo, cFolio, mSaldo, cTransacc, cDoctoChq, mDeposito, cReferencia, cStatus;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdRegistro, cCuenta, cNumCliente, cResultado, cCodRetSp, cMotivoRechazo, cFolio, mSaldo, cTransacc, cDoctoChq, mDeposito, cReferencia, cStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(*) 
		INTO iExiste
		FROM
			(SELECT lote
				FROM bdicnweb:"informix".sw_tr_cargamasiva_deposito
				WHERE lote = pLote AND usuario = pUsuario
			UNION
				SELECT lote
				FROM bdicnweb:"informix".sw_tr_cargamasiva_deposito_hist
			WHERE lote = pLote AND usuario = pUsuario);

		IF iExiste = 0 THEN
			LET cCodRet = '00200';
			RETURN cCodRet, iIdRegistro, cCuenta, cNumCliente, cResultado, cCodRetSp, cMotivoRechazo, cFolio, mSaldo, cTransacc, cDoctoChq, mDeposito, cReferencia, cStatus;
		END IF;
		
		UPDATE bdicnweb:sw_tr_cargamasiva_deposito
		SET resultado = 'NO APLICADO',
			motivo_rechazo = 'ERROR POR VALIDACION'
		WHERE lote = pLote AND status = 'E' AND usuario = pUsuario;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion id_registro, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, folio, transaccion, descripcion1, monto_importe, descripcion2, status, monto1
			INTO iIdRegistro, cCuenta, cNumCliente, cResultado, cCodRetSp, cMotivoRechazo, cFolio, cTransacc, cDoctoChq, mDeposito, cReferencia, cStatus, mSaldo
			FROM
				(SELECT id_registro, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, folio, transaccion, descripcion1, monto_importe, descripcion2, status, monto1
				FROM bdicnweb:"informix".sw_tr_cargamasiva_deposito
				WHERE lote = pLote AND usuario = pUsuario
				UNION
				SELECT id_registro, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, folio, transaccion, descripcion1, monto_importe, descripcion2, status, monto1
				FROM bdicnweb:"informix".sw_tr_cargamasiva_deposito_hist
				WHERE lote = pLote AND usuario = pUsuario)
			ORDER BY id_registro
			
			-- Agregamos el numero de cliente
			IF cNumCliente IS NULL OR TRIM(cNumCliente) = '' THEN
				
				SELECT num_cte
				INTO cNumCliente
				FROM bdicheq:"informix".sc_maechq
				WHERE cuenta = TRIM(cCuenta);
				
				UPDATE bdicnweb:"informix".sw_tr_cargamasiva_deposito
				SET numcte = cNumCliente
				WHERE id_registro = iIdRegistro;
				
				IF dbinfo('sqlca.sqlerrd2') = 0 THEN
					UPDATE bdicnweb:"informix".sw_tr_cargamasiva_deposito_hist
					SET numcte = cNumCliente
					WHERE id_registro = iIdRegistro;
				END IF;
					
			END IF;
			
			
			LET iRegistros =  iRegistros + 1;
			
			RETURN cCodRet, iIdRegistro, cCuenta, cNumCliente, cResultado, cCodRetSp, cMotivoRechazo, cFolio, mSaldo, cTransacc, cDoctoChq, mDeposito, cReferencia, cStatus with resume;
		END FOREACH;
		
		IF iRegistros = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iIdRegistro, cCuenta, cNumCliente, cResultado, cCodRetSp, cMotivoRechazo, cFolio, mSaldo, cTransacc, cDoctoChq, mDeposito, cReferencia, cStatus;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT "Autor: M.C. Oscar Flores Conde",
"Fecha de creaciÃ³n: 06/11/2013",
"Descripcion: Consulta los registros cargados en la tabla masiva para DEPOSITO masivo de captaciÃ³n";

CREATE PROCEDURE "informix".sp_totalesretirocap(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT)
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
		FROM bdicnweb:"informix".sw_tr_totales_masivo
		WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		
		-- Buscamos el lote en la tabla de las cargas masivas
		IF iExiste = 0 THEN
			SELECT COUNT(lote)
			INTO iExiste
			FROM bdicnweb:"informix".sw_tr_cargamasiva_retiro
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
			FROM bdicnweb:"informix".sw_tr_cargamasiva_retiro 
			WHERE lote = pLote AND status = 'C';

			SET ISOLATION TO DIRTY READ;
			
			SELECT COUNT(id_funcion)
			INTO iTotalRegistrosRechazados
			FROM bdicnweb:"informix".sw_tr_cargamasiva_retiro
			WHERE lote = pLote AND status <> 'C';

			SET ISOLATION TO DIRTY READ;
			
			SELECT cm.archivo, cm.fecha_carga
				, COUNT(cm.fecha_carga) AS total_registros
				, SUM(cm.monto_importe) AS total_monto
			INTO cNombreArchivoCarga, dFechaCarga, iTotalRegistros, mTotalMonto
			FROM bdicnweb:"informix".sw_tr_cargamasiva_retiro cm
			WHERE cm.lote = pLote		
			GROUP BY cm.archivo, cm.fecha_carga;
			
			-- GUARDAMOS LOS DATOS DEL LOTE EN LA TABLA DE LOTES
			-- Busqueda del nombre del ejecutivo
			SET ISOLATION TO DIRTY READ;
			SELECT nombre
			INTO cNombreEjecutivo
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo = pIdUsuario;
			
			LET cSistemaCuenta = '01';
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
"Fecha de creacion: 11/07/2013",
"Descripcion: Procedimiento que consulta el total de registros de un lote cargado, asiÂ­ como el numero de registros cargados correctamente,",
"             el numero de regitros erroneos, el monto total de la cargas y la fecha de carga, el SP funciona para el masivo de deposito y retiro de captacion";

CREATE PROCEDURE "informix".sp_sw_ro_evalua_fecha(pFechaEvaluar char(10))
	returning date as fecha_valida;

	define dFechaEvaluada date;
	define cFecha char(10);
	define iMes smallint;
	define iAnio integer;
	define iMAxDia smallint;

	let dFechaEvaluada = null;
	let cFecha = '';
	let iMes = 0;
	let iAnio = 0;
	let iMAxDia = 0;

	begin

		on exception in (-1206, -1263)
			let cFecha = TO_CHAR(pFechaEvaluar);

			let iMes = substr(cFecha, 1, 2);

			let iAnio = substr(cFecha, 7, 4);

			if iMes < 9 then
				let cFecha = '0' || iMes;

				else
				let cFecha = iMes;
			end if;

			let cFecha = trim(cFecha)||'-01-'||iAnio;
			let dFechaEvaluada = date(trim(cFecha));
			let iMaxDia = day(last_day(dFechaEvaluada));

			let cFecha = to_char(dFechaEvaluada);
			if iMAxDia < 10 then
				let cFecha = substr(cFecha,1,2)||trim('-0'||iMAxDia)||'-'||substr(cFecha,7,4);
			else
				let cFecha = substr(cFecha,1,2)||trim('-'||iMAxDia)||'-'||substr(cFecha,7,4);
			end if;

			let dFechaEvaluada = date(trim(cFecha));
			return dFechaEvaluada;
		end exception;

		select date(pFechaEvaluar)
		into dFechaEvaluada
		from systables
		where tabid = 1;

		return dFechaEvaluada;

	end;

end procedure;