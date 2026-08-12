CREATE PROCEDURE "informix".sp_pgservicios_transfer()
				returning 
				CHAR(5)     AS Cod_Retorno,
				CHAR(100)   AS Msj_Retorno;
				
DEFINE cCodRet		CHAR(5);
DEFINE cMsjRetorno	CHAR(100);
DEFINE iSql_err     INT; 
DEFINE iRegistros   INT; 
DEFINE dFecha		DATE;
DEFINE iConsecutivo	INT;
DEFINE mMonto		MONEY(6);
DEFINE cTelefono	CHAR(12);
DEFINE cTransaccion	CHAR(4);
DEFINE cFolioSuc	CHAR(16);
DEFINE cIntegridad	CHAR(1);
DEFINE cAplicacion	CHAR(1);
DEFINE cCuenta		CHAR(20);
DEFINE cReferencia2	CHAR(40);
DEFINE cStatus		CHAR(1);
DEFINE mImpComisionConvenio    MONEY(16,2);
DEFINE mIVAComision			   MONEY(16,2);
DEFINE mIVAComisionConv		   MONEY(16,2);
DEFINE mImpComisionCte         MONEY(16,2);
DEFINE mComisionCte			   MONEY(16,2);
DEFINE mIVAComisionCte		   MONEY(16,2);
DEFINE dFechaAyer	DATE;
DEFINE cNumCategoria CHAR(2);
DEFINE cNumConvenio CHAR(3);



LET cCodRet = "00000";
LET cMsjRetorno = "PROCESO EXITOSO";
LET iSql_err = 0 ; 
LET iRegistros = 0 ; 
LET mMonto = 0;
LET cTelefono = '';
LET cTransaccion = '';
LET cFolioSuc = '';
LET cIntegridad	= '1';
LET cAplicacion	= '1';
LET cCuenta = '';
LET cStatus = 'N';
LET mImpComisionConvenio = 0;
LET mIVAComision = 0;
LET mIVAComisionConv = 0;
LET mImpComisionCte = 0;
LET mComisionCte = 0;
LET mIVAComisionCte = 0;
LET iConsecutivo = 0;
LET cReferencia2 = '';
LET dFechaAyer = '';
LET cNumConvenio = '';
LET cNumCategoria = '10';



BEGIN
     ON EXCEPTION SET iSql_err
          IF iSql_err <> 0 THEN
               LET cCodRet = iSql_err;
			   LET cMsjRetorno = "ERROR DE BASE DE DATOS";
               RETURN cCodRet, cMsjRetorno;
          END IF;
     END EXCEPTION;
	 
	 --SET DEBUG FILE TO "/tmp/cristo/sp_pgservicios_transfer.out";
	 --TRACE ON;
	 

	 SET ISOLATION TO DIRTY READ;
	 SELECT fecha_ant
	 INTO dFechaAyer
	 FROM bdinteg:"informix".si_fechas 
	 WHERE empresa='001';
	 
	 
	 
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT a.fech_alt, a.monto_tot, a.cuenta, a.folio_suc, a.transacc, a.referencia,b.imp_com_trans_conv, b.iva_convenio, b.imp_com_trans_cte,b.numconvenio 
		INTO dFecha, mMonto, cCuenta, cFolioSuc, cTransaccion, cReferencia2,mImpComisionConvenio, mIVAComision, mImpComisionCte,cNumConvenio
		FROM bdicheq:"informix".sc_movhis a
		LEFT JOIN bdisac:"informix".sac_convenios b ON a.transacc = b.trans_suc_cargo
		WHERE a.fech_alt = dFechaAyer
		AND a.usuario = 'systrans'
		AND a.producto = '8000'
		AND b.numcategoria = cNumCategoria
		AND b.statusconvenio = 'A'

					 
		SELECT FIRST 1 telefono 
		INTO cTelefono
		FROM "informix".tf_maecte
		WHERE cuenta_tf = cCuenta;
		 
		LET mIVAComisionConv = mImpComisionConvenio * (mIVAComision/100);
		LET mComisionCte = mMonto * (mImpComisionCte/100);
		LET mIVAComisionCte = mComisionCte * (mIVAComision/100);
		 
		SET ISOLATION TO DIRTY READ;
		INSERT INTO bdisac:"informix".sac_movimientoshistorial (id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago, importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte, cuenta_cargo, usuario, folio_suc, transacc_suc, flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert, status_cancelado)
		VALUES ('5001', cNumCategoria, cNumConvenio, cTelefono, cReferencia2, 2, mMonto, mImpComisionConvenio, mIVAComisionConv, mComisionCte, mIVAComisionCte, cCuenta, 'TRANSFER', cFolioSuc, cTransaccion, cIntegridad, cAplicacion, dFecha, CURRENT, cStatus);
		 
		LET iRegistros = iRegistros+1;
		
	END FOREACH;

	IF iRegistros = 0 THEN
		LET cCodRet = '00003';
		LET cMsjRetorno = 'NO SE ENCONTRARON REGISTROS A CARGAR';
	END IF;
	
	RETURN cCodRet,cMsjRetorno;
	
	
END
END PROCEDURE;