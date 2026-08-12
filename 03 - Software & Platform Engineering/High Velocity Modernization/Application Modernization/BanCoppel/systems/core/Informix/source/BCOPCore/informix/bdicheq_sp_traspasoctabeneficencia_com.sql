CREATE PROCEDURE "informix".sp_traspasoctabeneficencia_com(p_empresa char(3))
    RETURNING   CHAR(5);
														
    
    DEFINE cCodRet CHAR(5);
    DEFINE cCodRet2 CHAR(5);
    DEFINE cCodRet3 CHAR(50);
    DEFINE iSqlErr INTEGER;
    DEFINE iSamErr INTEGER;
    DEFINE cDesErr CHAR(50);
    DEFINE dValorSM DECIMAL(14,2);
    DEFINE iTotalCuentas INTEGER;
    DEFINE dTotalSaldo DECIMAL(14,2);
    DEFINE iNoAnios SMALLINT;
    DEFINE cCodRetSp CHAR(5);
    DEFINE iCodRetSp INTEGER;
    DEFINE cMensajeError CHAR(100);
    DEFINE cCveRastreo CHAR(30);
    DEFINE cCodRetTEF CHAR(5);
    DEFINE cSucursalEmpleado CHAR(4);
    DEFINE cCuenta CHAR(20);
    DEFINE cCuentaOrden CHAR(20);
    DEFINE cCuentaOrdentef CHAR (20);
    DEFINE cNombreOrden CHAR(40);
    DEFINE cRFCOrden CHAR(18);
    DEFINE bInTransaction BOOLEAN;
    
    -- VARIABLES DEL SPL DE TRANSFERENCIA SPEI
    DEFINE cEmpresa CHAR(3);
    DEFINE cSucursalSPEI CHAR(4);
    DEFINE cFolioSucursalSPEI CHAR(16);
    DEFINE iBancoDestinoSPEI INTEGER;
    DEFINE dFechaCapturaSPEI DATE;
    DEFINE iTipoPagoSPEI INTEGER;
    DEFINE iTipoOperacionSPEI INTEGER;
    DEFINE mImporteOperacionSPEI MONEY(18,2);
    DEFINE cNombreOrdenSPEI CHAR(40);
    DEFINE cCuentaOrdenSPEI CHAR(20);
    DEFINE cRFCOrdenSPEI CHAR(18);
    DEFINE cNombreBeneficiarioSPEI CHAR(40);
    DEFINE cCuentaBeneficiarioSPEI CHAR(20);
    DEFINE cRFCBeneficiarioSPEI CHAR(18);
    DEFINE mImporteIVASPEI MONEY(18,2);
    DEFINE dReferenciaNumero DECIMAL(7,0);
    DEFINE cReferenciaCobranza1SPEI CHAR(40);
    DEFINE cConceptoPagoSPEI CHAR(210);
    DEFINE cClavePagoSPEI CHAR(10);
    DEFINE cNombreBeneficiario2SPEI CHAR(40);
    DEFINE cCuentaBeneficiario2SPEI CHAR(20);
    DEFINE cRFCBeneficiario2SPEI CHAR(18);
    DEFINE cConceptoPago2SPEI CHAR(40);
    DEFINE cTransaccionSPEI CHAR(4);
    DEFINE iTipoCuentaOrdenSPEI INTEGER;
    DEFINE iTipoCuentaBeneficiarioSPEI INTEGER;
    DEFINE iSerialFolioSPEI INTEGER;
    
    -- VARIABLES DE ENTRADA PARA TEF
    DEFINE cTipoTEF CHAR(1);
    DEFINE cEmpresaTEF CHAR(3);
    DEFINE dFechaTransTEF DATE;
    DEFINE cFolioSucTEF CHAR(16);
    DEFINE cSucursalTEF CHAR(4); 
    DEFINE cNumCtaOrdTEF CHAR(20);
    DEFINE cTipoCtaOrdTEF CHAR(2);
    DEFINE dFechaProgTEF DATE;
    DEFINE cTipoOperTEF CHAR(2);
    DEFINE cCveRastreoTEF CHAR(30);
    DEFINE cNombreCteOrdTEF CHAR(30);
    DEFINE cRfcCteOrd CHAR(15);
    DEFINE cImpTEF CHAR(10);
    DEFINE cComisionTEF CHAR(5);
    DEFINE cIvaTEF CHAR(5);
    DEFINE cImpTotTEF CHAR(10);
    DEFINE cTipoCtaBenTEF CHAR(2);
    DEFINE cNombreBenTEF CHAR(30);
    DEFINE cNumCtaTarjBenTEF CHAR(20);
    DEFINE cCveBancoRecTEF CHAR(3);
    DEFINE cRfcBenTEF CHAR(15);
    DEFINE cConcepPagoTEF CHAR(50);
    DEFINE cRefNumTEF CHAR(7);
    DEFINE cReferenciaTEF CHAR(40);
    DEFINE cCveCanalTEF CHAR(2);
    DEFINE cMotivoDevTEF CHAR(2); 
    DEFINE cDivisaTEF CHAR(2);
    DEFINE cTransacSucTEF CHAR(4);
    DEFINE cNumTarjetaTEF CHAR(16);
    
    -- // VARIABLES ADEMDUM RQM 06 303-2
    DEFINE iTraspaso SMALLINT;
    DEFINE dFechaHoy DATE;
    DEFINE cTrxRefer CHAR(4);
    DEFINE cHora CHAR(15);
    DEFINE cFolio CHAR(16);
    DEFINE cProducto CHAR(4);
    DEFINE cSucursal CHAR(4);
    DEFINE mMontoConcentrado DECIMAL(14,2);
    DEFINE cTarjeta CHAR(16);
    DEFINE cNumCte CHAR(20);
    DEFINE cNombreCte CHAR(100);
    DEFINE dFechaAlta DATE;
    DEFINE dFechaUltDep DATE;
    DEFINE dFechaUltRet DATE;
    DEFINE dFechaConcentra DATE;
    DEFINE cCtaConcentradora CHAR(20);
	DEFINE dFechaOperacion DATE;
    
    -- // VARIABLES CARGO CUENTA CONCENTRADORA
    DEFINE cCodRetCgo CHAR(5);
    DEFINE cTrxCgo CHAR(4);
    DEFINE dFechaCgo DATE;
    DEFINE mSdoDispCgo DECIMAL(14,2);
    DEFINE mMontoCgo DECIMAL(14,2);
	
	DEFINE vsqlerr  INTEGER;
	DEFINE iIsamErr SMALLINT;
	DEFINE cErrorInfo  CHAR(80);
	DEFINE vcodret  CHAR(5);
	DEFINE vErrorInfo CHAR(80);
	DEFINE v_c_vcomienza    SMALLINT;
	DEFINE ven_transacc     SMALLINT;
	DEFINE v_c_vcontador    INTEGER;
	DEFINE v_sql CHAR(500);
	
    
    LET cCodRet = '00000';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
    LET iSqlErr = 0;
    LET iSamErr = 0;
    LET cDesErr = '';
    LET dValorSM = 0.0;
    LET iTotalCuentas = 0;
    LET dTotalSaldo = 0.0;
    LET iNoAnios = 3;
    LET cCodRetSp = '';
    LET iCodRetSp = 0;
    LET cMensajeError = '';
    LET cCveRastreo = '';
    LET cCodRetTEF = '';
    LET cSucursalEmpleado = '';
    LET cCuenta = '';
    LET cCuentaOrden = '';
    LET cCuentaOrdentef ='';
    LET cNombreOrden = '';
    LET cRFCOrden = '';
    LET bInTransaction = 'f';
    
    -- VARIABLES DEL SPL DE TRANSFERENCIA SPEI
    LET cEmpresa = '001';
    LET cSucursalSPEI = '';
    LET cFolioSucursalSPEI = '';
    LET iBancoDestinoSPEI = 0;
    LET dFechaCapturaSPEI = NULL;
    LET iTipoPagoSPEI = 0;
    LET iTipoOperacionSPEI = 0;
    LET mImporteOperacionSPEI = 0.0;
    LET cNombreOrdenSPEI = '';
    LET cCuentaOrdenSPEI = '';
    LET cRFCOrdenSPEI = '';
    LET cNombreBeneficiarioSPEI = '';
    LET cCuentaBeneficiarioSPEI = '';
    LET cRFCBeneficiarioSPEI = '';
    LET mImporteIVASPEI = 0.0;
    LET dReferenciaNumero = 0.0;
    LET cReferenciaCobranza1SPEI = '';
    LET cConceptoPagoSPEI = '';
    LET cClavePagoSPEI = '';
    LET cNombreBeneficiario2SPEI = '';
    LET cCuentaBeneficiario2SPEI = '';
    LET cRFCBeneficiario2SPEI = '';
    LET cConceptoPago2SPEI = '';
    LET cTransaccionSPEI = '';
    LET iTipoCuentaOrdenSPEI = 0;
    LET iTipoCuentaBeneficiarioSPEI = 0;
    LET iSerialFolioSPEI = 0;
    
    -- VARIABLES DEL SPL DE LA TRANSFERENCIA TEF
    LET cTipoTEF = '';
    LET cEmpresaTEF = '';
    LET dFechaTransTEF = NULL;
    LET cFolioSucTEF = '';
    LET cSucursalTEF = ''; 
    LET cNumCtaOrdTEF = '';
    LET cTipoCtaOrdTEF = '';
    LET dFechaProgTEF = NULL;
    LET cTipoOperTEF = '';
    LET cCveRastreoTEF = '';
    LET cNombreCteOrdTEF = '';
    LET cRfcCteOrd = '';
    LET cImpTEF = '';
    LET cComisionTEF = '';
    LET cIvaTEF = '';
    LET cImpTotTEF = '';
    LET cTipoCtaBenTEF = '';
    LET cNombreBenTEF = '';
    LET cNumCtaTarjBenTEF = '';
    LET cCveBancoRecTEF = '';
    LET cRfcBenTEF = '';
    LET cConcepPagoTEF = '';
    LET cRefNumTEF = '';
    LET cReferenciaTEF = '';
    LET cCveCanalTEF = '';
    LET cMotivoDevTEF = ''; 
    LET cDivisaTEF = '';
    LET cTransacSucTEF = '';
    LET cNumTarjetaTEF = '';
    
    -- // VARIABLES ADEMDUM RQM 06 303-2
    LET iTraspaso = 0;
    LET dFechaHoy = '';
    LET cTrxRefer = '';
    LET cHora = '';
    LET cFolio = '';  
    LET cProducto = '';
    LET cSucursal = '';
    LET mMontoConcentrado = 0.00;
    LET cTarjeta = '';
    LET cNumCte = '';
    LET cNombreCte = '';
    LET dFechaAlta = '';
    LET dFechaUltDep = '';
    LET dFechaUltRet = '';
    LET dFechaConcentra = '';
    LET cCtaConcentradora = '';
	LET dFechaOperacion = TODAY;
    
    -- // VARIABLES CARGO CUENTA CONCENTRADORA
    LET cCodRetCgo = '';
    LET cTrxCgo = '';
    LET dFechaCgo = '';
    LET mSdoDispCgo = 0.00;
    LET mMontoCgo = 0.00;
	
	LET vsqlerr  = 0; 
	LET iIsamErr = 0;
	LET cErrorInfo  = ""; 
    LET vcodret   = "00000";
	LET vErrorInfo = "INICIO DEL PROCESO";			  
	LET v_c_vcomienza  = -1;	
	LET ven_transacc  = 0;
	LET v_c_vcontador = 0;
	LET v_sql = "";
    
    BEGIN
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	    IF  vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/sp_traspasoctabeneficencia_com.err";
	 	    TRACE ON;
			LET vcodret    = vsqlerr;
            LET vErrorInfo = cErrorInfo;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodRet;
        END IF;
    END EXCEPTION;
      
    --- SET DEBUG FILE TO /resplogifx/conciliachq/sp_traspasoctabeneficencia_com.out'; 
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	CREATE TABLE ctas_trasp(
    cuenta CHAR(20));
	
	LET v_sql = 'echo "LOAD FROM /resplogifx/conciliachq/cuentas.txt INSERT INTO ctas_trasp;" > /resplogifx/conciliachq/inserta.sql';
	SYSTEM v_sql;
	LET v_sql = "/ifxsif01/bin/dbaccess bdicheq  /resplogifx/conciliachq/inserta.sql";
	SYSTEM v_sql;

	
	SELECT fecha_hoy
    INTO   dFechaHoy
    FROM   bdicheq:sc_fechas
    WHERE  empresa = p_empresa;
	
	SELECT valor
    INTO   cTrxRefer
    FROM   bdicheq:sc_param
    WHERE  empresa = p_empresa
    AND    codparam = 'TrxRefTraspBeneART61';
	
	LET cHora = CURRENT HOUR TO FRACTION;
    LET cFolio = 'informix'||cHora[1,2]||cHora[4,5]||cHora[7,8]||cHora[10,11]; 
	 
    FOREACH WITH HOLD
	
	        SELECT con.cuenta, mae.producto, mae.sucursal, con.sdo_concentrado, con.tarjeta, con.num_cte, con.cliente, 
                   noc.fecha_alta, con.fech_ult_dep, con.fech_ult_ret, con.fecha_concentra
		      INTO cCuenta, cProducto, cSucursal, mMontoConcentrado, cTarjeta, cNumCte, cNombreCte, 
                   dFechaAlta, dFechaUltDep, dFechaUltRet, dFechaConcentra
              FROM bdicheq:sc_cuentas_concentradas con, 
                   bdicheq:sc_maechq mae,
                   bdicheq:sc_maenoc noc
             WHERE mae.cuenta = con.cuenta
               AND mae.status_cta = '6'
               AND noc.empresa = mae.empresa
               AND noc.cuenta  = mae.cuenta
               AND mae.cuenta IN (SELECT ctas.cuenta FROM ctas_trasp AS ctas)
			   
			   -- Abre la transaccion 
		    IF  (v_c_vcomienza = -1) THEN
                LET v_c_vcomienza = 0;
                LET ven_transacc = 1;
                BEGIN WORK;
            END IF;

            INSERT INTO bdicheq:sc_movdia VALUES
            ( 0, cFolio, '9250', 'informix', dFechaHoy, dFechaHoy, cHora, cTrxRefer, cSucursal, cProducto, '001', 
              cCuenta, '', 0, mMontoConcentrado, 0, 0, 0, 0, '', '', 0.00, '0000', 'TRASPASO A LA BENEFICENCIA', 0, '', '', '', dFechaOperacion);
            
            INSERT INTO bdicheq:sc_cuentas_traspbenef VALUES
            ( cCuenta, cProducto, cTarjeta, cNumCte, cNombreCte, dFechaAlta, dFechaUltDep, dFechaUltRet, 
              dFechaConcentra, dFechaHoy, mMontoConcentrado, 'TRANSFERIDA', cFolio, 'SATISFACTORIO' ); 
            
            UPDATE bdicheq:sc_cuentas_concentradas
               SET sdo_trasp_beneficiencia = mMontoConcentrado,
                   int_trasp_beneficiencia = 0.00,
                   fecha_trasp_benefic = dFechaHoy
             WHERE cuenta = cCuenta;
             
            UPDATE bdicheq:sc_maechq
               SET status_cta = '2', 
                   motivo = '14', 
                   fec_cancelac = dFechaHoy
             WHERE empresa = '001'
               AND cuenta = cCuenta; 
			   
			  LET v_c_vcontador = v_c_vcontador + 1;
			--Realiza commit cada 1000 registros 
			IF (v_c_vcontador >= 5000) THEN
               LET v_c_vcontador = 0;
               COMMIT WORK;
               BEGIN WORK;
            END IF;  
  
    END FOREACH; 
	
	IF  ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;	 
	
	DROP TABLE ctas_trasp;

RETURN vcodret;
END;
END PROCEDURE;