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