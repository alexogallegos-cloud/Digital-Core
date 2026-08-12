CREATE PROCEDURE "informix".sp_consctascancelacionmasivocre(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT, pRegistros INT, pRecuperacion INT)
	RETURNING CHAR(5) AS codret,
		INT AS id,
		CHAR(1) AS status,
		CHAR(20) AS cuenta,
		CHAR(20) AS numcte,
		CHAR(15) AS resultado,
		CHAR(5) AS codRetSp,
		CHAR(100) AS motivo_rechazo,
		CHAR(20) AS folio, 
		MONEY(14,2) AS saldo,
		CHAR(3) as codigo_cancelacion,
		DATE AS fecha_cancelacion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE iExiste INT;
	DEFINE iIdRegistro INT;
	DEFINE cStatus CHAR(1);
	DEFINE cCuenta CHAR(20);
	DEFINE cResultado CHAR(15);
	DEFINE cCodRetProc CHAR(5);
	DEFINE cMotivoRechazo CHAR(100);
	DEFINE cFolioCancelacion CHAR(20);
	DEFINE mSaldo MONEY(14,2);
	DEFINE cClaveCancelacion CHAR(3);
	DEFINE dFechaCancelacion DATE;
	DEFINE cNumCliente CHAR(20);
	DEFINE iRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET iIdRegistro = 0;
	LET cStatus = '';
	LET cCuenta = '';
	LET cResultado = '';
	LET cCodRetProc = '';
	LET cMotivoRechazo = '';
	LET cFolioCancelacion = '';
	LET mSaldo = NULL;
	LET cClaveCancelacion = '';
	LET dFechaCancelacion = NULL;
	LET cNumCliente = '';
	LET iRegistros = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdRegistro, cStatus, cCuenta, cNumCliente, cResultado, cCodRetProc, cMotivoRechazo, 
					cFolioCancelacion, mSaldo, cClaveCancelacion, dFechaCancelacion;
		END EXCEPTION
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consctascancelacionmasivocre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pLote = '' OR pRegistros = '' OR pRecuperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdRegistro, cStatus, cCuenta, cNumCliente, cResultado, cCodRetProc, cMotivoRechazo, 
					cFolioCancelacion, mSaldo, cClaveCancelacion, dFechaCancelacion;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdRegistro, cStatus, cCuenta, cNumCliente, cResultado, cCodRetProc, cMotivoRechazo, 
					cFolioCancelacion, mSaldo, cClaveCancelacion, dFechaCancelacion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(*) 
		INTO iExiste
		FROM
			(SELECT lote
				FROM bdicnweb:sw_tr_cargamasiva_cancelacioncre
				WHERE lote = pLote AND usuario = pUsuario
			UNION
				SELECT lote
				FROM bdicnweb:sw_tr_cargamasiva_cancelacioncre_hist
			WHERE lote = pLote AND usuario = pUsuario);

		IF iExiste = 0 THEN
			LET cCodRet = '00200';
			RETURN cCodRet, iIdRegistro, cStatus, cCuenta, cNumCliente, cResultado, cCodRetProc, cMotivoRechazo, 
					cFolioCancelacion, mSaldo, cClaveCancelacion, dFechaCancelacion;
		END IF;
		
		UPDATE bdicnweb:sw_tr_cargamasiva_cancelacioncre
		SET resultado = 'NO APLICADO',
			motivo_rechazo = 'ERROR POR VALIDACION'
		WHERE lote = pLote AND status = 'E' AND usuario = pUsuario;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion id_registro, status, cuenta, resultado, codret_proceso, motivo_rechazo, folio, saldo, codigo_cancelacion, fecha_cancelacion, numcte
			INTO iIdRegistro, cStatus, cCuenta, cResultado, cCodRetProc, cMotivoRechazo, cFolioCancelacion, mSaldo, cClaveCancelacion, dFechaCancelacion, cNumCliente
			FROM
				(SELECT id_registro, status, cuenta, resultado, codret_proceso, motivo_rechazo, folio, saldo, codigo_cancelacion, fecha_cancelacion, numcte
				FROM bdicnweb:sw_tr_cargamasiva_cancelacioncre
				WHERE lote = pLote AND usuario = pUsuario
				UNION
				SELECT id_registro, status, cuenta, resultado, codret_proceso, motivo_rechazo, folio, saldo, codigo_cancelacion, fecha_cancelacion, numcte
				FROM bdicnweb:sw_tr_cargamasiva_cancelacioncre_hist
				WHERE lote = pLote AND usuario = pUsuario)
			ORDER BY id_registro
			
			-- Agregamos el numero de cliente
			IF cNumCliente IS NULL OR TRIM(cNumCliente) = '' THEN
				SELECT numcte
				INTO cNumCliente
				FROM bdicred:"informix".sd_maecred
				WHERE num_credito = TRIM(cCuenta);
				
				UPDATE bdicnweb:"informix".sw_tr_cargamasiva_cancelacioncre
				SET numcte = cNumCliente
				WHERE id_registro = iIdRegistro;
				
				IF dbinfo('sqlca.sqlerrd2') = 0 THEN
					UPDATE bdicnweb:"informix".sw_tr_cargamasiva_cancelacioncre_hist
					SET numcte = cNumCliente
					WHERE id_registro = iIdRegistro;
				END IF;
			END IF;
			
			LET iRegistros =  iRegistros + 1;
			
			RETURN cCodRet, iIdRegistro, cStatus, cCuenta, cNumCliente, cResultado, cCodRetProc, cMotivoRechazo, 
					cFolioCancelacion, mSaldo, cClaveCancelacion, dFechaCancelacion WITH RESUME;
		END FOREACH;
		
		IF iRegistros = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iIdRegistro, cStatus, cCuenta, cNumCliente, cResultado, cCodRetProc, cMotivoRechazo, 
					cFolioCancelacion, mSaldo, cClaveCancelacion, dFechaCancelacion;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT "Autor: M.C. Oscar Flores Conde",
"Fecha de creaciÃ³n: 12/09/2013",
"Descripcion: Consulta los registros cargados en la tabla masiva para la CANCELACIÃN MASIVA DE CUENTAS DE CRÃDITO";

CREATE PROCEDURE "informix".sp_consinstventocap(pUsuario char(8), pIdFuncion char(10), pCuenta CHAR(20), pNumMotivo SMALLINT)
	RETURNING CHAR(5) AS codret, 
			CHAR(20) AS cuenta, 
			CHAR(7) AS nom_cap_int, 
			SMALLINT AS inst_vento, 
			CHAR(30) AS desc_inst_vento, 
			MONEY(14,2) AS importe,
			CHAR(35) AS nombre_sistema, 
			CHAR(20) AS cuenta_traspaso, 
			CHAR(1) AS aplicado, 
			DATE AS fecha_vencimiento;

	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCodRet CHAR(5);
	DEFINE cCuenta CHAR(20); 
	DEFINE cNomCapInt CHAR(7);
	DEFINE iInstVento SMALLINT;
	DEFINE cDescInstVento CHAR(30);
	DEFINE mImporte MONEY(14,2);
	DEFINE cNombreSistema CHAR(35);
	DEFINE cCuentaTraspaso CHAR(20);
	DEFINE cAplicado CHAR(1);
	DEFINE dFechaVencimiento DATE;
	DEFINE iRegs INTEGER;
	
	LET iSqlErr = 0;
	LET cCodRet = '';
	LET cEmpresa = '001';
	LET cCuenta = '';
	LET cNomCapInt = '';
	LET iInstVento = 0;
	LET cDescInstVento = '';
	LET mImporte = NULL;
	LET cNombreSistema = '';
	LET cCuentaTraspaso = '';
	LET cAplicado = '';
	LET dFechaVencimiento = NULL;
	LET iRegs = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCuenta, cNomCapInt, iInstVento, cDescInstVento, mImporte, cNombreSistema, cCuentaTraspaso, cAplicado, dFechaVencimiento;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consinstventocap.out';
		--TRACE ON;
		
		IF pUsuario = '' or pIdFuncion = '' OR pCuenta = '' OR pNumMotivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCuenta, cNomCapInt, iInstVento, cDescInstVento, mImporte, cNombreSistema, cCuentaTraspaso, cAplicado, dFechaVencimiento;
		END IF;
		
		--EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pCuenta, '03', '1') INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCuenta, cNomCapInt, iInstVento, cDescInstVento, mImporte, cNombreSistema, cCuentaTraspaso, cAplicado, dFechaVencimiento;
		END IF;
		
		FOREACH EXECUTE PROCEDURE bdinvers:"informix".cons_instvento(cEmpresa, pCuenta, pNumMotivo)
			INTO cCodRet, cCuenta, cNomCapInt, iInstVento, cDescInstVento, mImporte, cNombreSistema, cCuentaTraspaso, cAplicado, dFechaVencimiento
		
			IF cCodRet = '000' THEN
				LET cCodRet = '00000';
			ELIF cCodRet = '142' THEN
				-- La cuenta no existe
				LET cCodRet = '00009';
			END IF;
			LET iRegs = iRegs + 1;
			
			RETURN cCodRet, cCuenta, cNomCapInt, iInstVento, cDescInstVento, mImporte, cNombreSistema, cCuentaTraspaso, cAplicado, dFechaVencimiento WITH RESUME;
		
		END FOREACH;
		
		IF iRegs = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCuenta, cNomCapInt, iInstVento, cDescInstVento, mImporte, cNombreSistema, cCuentaTraspaso, cAplicado, dFechaVencimiento;
		END IF;
		
	END;
	
END PROCEDURE;