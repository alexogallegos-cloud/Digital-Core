CREATE PROCEDURE "informix".sp_tpoaire_transfer()
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



BEGIN
     ON EXCEPTION SET iSql_err
          IF iSql_err <> 0 THEN
               LET cCodRet = iSql_err;
			   LET cMsjRetorno = "ERROR DE BASE DE DATOS";
               RETURN cCodRet, cMsjRetorno;
          END IF;
     END EXCEPTION;
	 
	 --SET DEBUG FILE TO "/informix/CHVN/sp_tpoaire_transfer.out";
	 --TRACE ON;
	 
	 SET ISOLATION TO DIRTY READ;
	 SELECT imp_com_trans_conv, iva_convenio, imp_com_trans_cte 
	 INTO mImpComisionConvenio, mIVAComision, mImpComisionCte
	 FROM bdisac:sac_convenios
	 WHERE numcategoria = '02'
	 AND numconvenio = '002';
	 
	 SET ISOLATION TO DIRTY READ;
	 SELECT imp_com_trans_conv, iva_convenio, imp_com_trans_cte 
	 INTO mImpComisionConvenio, mIVAComision, mImpComisionCte
	 FROM bdisac:sac_convenios
	 WHERE numcategoria = '02'
	 AND numconvenio = '002';
	 
	 SET ISOLATION TO DIRTY READ;
	 SELECT fecha_ant
	 INTO dFechaAyer
	 FROM bdinteg:si_fechas;
	 
	 
	 SET ISOLATION TO DIRTY READ;
	 SELECT count(*)
	 INTO iRegistros
	 FROM bdicheq:sc_movhis
	 WHERE fech_alt = dFechaAyer
	 AND transacc = '8006'
	 AND usuario = 'systrans'
	 AND producto = '8000';
	 	 
	 IF iRegistros > 0 THEN
		 SET ISOLATION TO DIRTY READ;
		 FOREACH
		 SELECT fech_alt, monto_tot, cuenta, folio_suc, transacc, referencia
		 INTO dFecha, mMonto, cCuenta, cFolioSuc, cTransaccion, cReferencia2
		 FROM bdicheq:sc_movhis
		 WHERE fech_alt = dFechaAyer
		 AND transacc = '8006'
		 AND usuario = 'systrans'
		 AND producto = '8000'
		 
		 SELECT telefono 
		 INTO cTelefono
		 FROM bditransfer:tf_maecte
		 WHERE cuenta_tf = cCuenta;
		 
		 LET mIVAComisionConv = mImpComisionConvenio * (mIVAComision/100);
		 LET mComisionCte = mMonto * (mImpComisionCte/100);
		 LET mIVAComisionCte = mComisionCte * (mIVAComision/100);
		 
		 SET ISOLATION TO DIRTY READ;
		 INSERT INTO bdisac:sac_movimientoshistorial (id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago, importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte, cuenta_cargo, usuario, folio_suc, transacc_suc, flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert, status_cancelado)
		 VALUES ('5001', '02', '002', cTelefono, cReferencia2, 2, mMonto, mImpComisionConvenio, mIVAComisionConv, mComisionCte, mIVAComisionCte, cCuenta, 'TRANSFER', cFolioSuc, cTransaccion, cIntegridad, cAplicacion, dFecha, CURRENT, cStatus);
		 
		 END FOREACH;

		 RETURN cCodRet,cMsjRetorno;
	 ELSE
		LET cCodRet = '00003';
		LET cMsjRetorno = 'NO SE ENCONTRARON REGISTROS A CARGAR';
		RETURN cCodRet,cMsjRetorno;
	 END IF;
END
END PROCEDURE;