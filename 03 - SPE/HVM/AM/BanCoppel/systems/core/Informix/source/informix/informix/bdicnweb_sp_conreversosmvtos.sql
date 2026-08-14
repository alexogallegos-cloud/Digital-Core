CREATE PROCEDURE "informix".sp_conreversosmvtos(pUsuario char(10),
                                                pIdFuncion char(10),
                                                pFolioMovimiento char(16),
                                                pRegistros int,
                                                pRecuperacion int)
      RETURNING char(5) as codRet,
		char(16) as folio,
		char(60) as descripcion,
		char(20) as cuenta,
		int as no_cheque,
		money(14,2) as monto,
		char(1) as cancelado,
		char(4) as sucursal;

DEFINE cCodRet char(5);
DEFINE cFolio char(16);
DEFINE cDescripcion char(60);
DEFINE cCuenta char(20);
DEFINE iNoCheque integer;
DEFINE mMonto money(14,2);
DEFINE cCancelado char(1);
DEFINE cNoSucursal char(4);
DEFINE iSqlErr int;
DEFINE cEmpresa char(3);
DEFINE iNoRegistros int;

LET cCodRet = '00000';
LET cFolio = '';
LET cDescripcion = '';
LET cCuenta = '';
LET iNoCheque = 0;
LET mMonto = 0;
LET cCancelado = '';
LET cNoSucursal = '';
LET iSqlErr = 0;
LET cEmpresa = '001';
LET iNoRegistros = 0;

SET ISOLATION TO DIRTY READ;

BEGIN

	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,
                               cFolio,
                               cDescripcion,
                               cCuenta,
                               iNoCheque,
                               mMonto,
                               cCancelado,
                               cNoSucursal;
		END IF;
	END EXCEPTION;

	IF pUsuario = '' or
           pIdFuncion = '' or
           pFolioMovimiento = '' or
           pRegistros = '' or
           pRecuperacion = '' THEN
		LET cCodRet = '00003';
		RETURN cCodRet,
			cFolio,
			cDescripcion,
			cCuenta,
			iNoCheque,
			mMonto,
			cCancelado,
			cNoSucursal;
	END IF;

	-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
	EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion)
		INTO cCodRet;
	IF cCodRet <> '00000' THEN
		RETURN cCodRet,
			cFolio,
			cDescripcion,
			cCuenta,
			iNoCheque,
			mMonto,
			cCancelado,
			cNoSucursal;
	END IF;

	FOREACH SELECT skip pRegistros FIRST pRecuperacion
			folio_suc
			,trim(transacc)||' '||trim(descripcion)
			,cuenta
			,num_cheq
			,monto_tot
			,cancelad
			,sucursal
		INTO    cFolio,
			cDescripcion,
			cCuenta,
			iNoCheque,
			mMonto,
			cCancelado,
			cNoSucursal
		FROM bdicheq:"informix".sc_movdia m,bdinteg:"informix".si_transacc t
		WHERE m.empresa = cEmpresa
		  and m.empresa = t.empresa
		  and folio_suc = pFolioMovimiento
		  and transacc = numero

		RETURN cCodRet,
			cFolio,
			cDescripcion,
			cCuenta,
			iNoCheque,
			mMonto,
			cCancelado,
			cNoSucursal with resume;
		LET iNoRegistros = iNoRegistros + 1;
	END FOREACH;

	IF iNoRegistros = 0 THEN
		LET cCodRet = '1001';
		RETURN cCodRet,
			cFolio,
			cDescripcion,
			cCuenta,
			iNoCheque,
			mMonto,
			cCancelado,
			cNoSucursal;
	END IF;
END;
END PROCEDURE;