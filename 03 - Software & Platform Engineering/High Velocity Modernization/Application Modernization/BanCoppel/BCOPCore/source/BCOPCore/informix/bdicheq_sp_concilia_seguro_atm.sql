CREATE PROCEDURE "informix".sp_concilia_seguro_atm()
RETURNING CHAR(3);

    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(80);
    DEFINE vcodret4     CHAR(5);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(80);
    DEFINE vcontador1   INTEGER;
    DEFINE vcontador2   INTEGER;
    DEFINE vcomienza    SMALLINT;
    DEFINE iTransacc    SMALLINT;
    DEFINE vsql         CHAR(1200);
    DEFINE vstmt        CHAR(300);
    DEFINE vexiste      SMALLINT;
    DEFINE dFechaHoy    DATE;
    DEFINE dFechaAnt    DATE;
    DEFINE dFecha       DATE;
    DEFINE cFolio       CHAR(16);
    DEFINE cTransac     CHAR(4);
    DEFINE cCuenta      CHAR(20);
    DEFINE mMonto       DECIMAL(14,2);
	DEFINE mMonto_spei  DECIMAL(14,2);
    DEFINE cTransac2    CHAR(4);
    DEFINE cCuenta2     CHAR(20);
    DEFINE mMonto2      DECIMAL(14,2);
	DEFINE vfecha2      CHAR(8);
	DEFINE vnombrearchivo CHAR(100);
	DEFINE pempresa     CHAR(3);
	DEFINE vIvaBase     DECIMAL(9,6);
	DEFINE vMontoIVA    DECIMAL(14,2);
	DEFINE mMonto_Comision DECIMAL(14,2);
    
    -- // VARIABLES PARA TRANSFERENCIA SPEI
    DEFINE cSucursalSPEI CHAR(4);
    DEFINE cFolioSucursalSPEI CHAR(16);
    DEFINE iBancoDestinoSPEI INTEGER;
    DEFINE dFechaCapturaSPEI DATE;
    DEFINE iTipoPagoSPEI INTEGER;
    DEFINE iTipoOperacionSPEI INTEGER;
    DEFINE mImporteOperacionSPEI MONEY(18,2);
    DEFINE cNombreOrdenSPEI CHAR(40);
    DEFINE cCuentaOrdenSPEI CHAR(20);
	DEFINE cCuentaOrden CHAR(20);
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
    DEFINE cCodRetSp CHAR(5);
	DEFINE cCodRetSp2 CHAR(4);
    DEFINE cMensajeError CHAR(100);
    DEFINE cCveRastreo CHAR(30);
	DEFINE cIva DECIMAL(14,2);
    
    -- // VARIABLES CARGO EN CUENTA 
    DEFINE cCodRetCgo CHAR(5);
    DEFINE cTrxCgo CHAR(4);
    DEFINE dFechaCgo DATE;
    DEFINE mSdoDispCgo DECIMAL(14,2);
    DEFINE mMontoCgo DECIMAL(14,2);
    
	DEFINE vfechaproc DATE;
	DEFINE vproceso CHAR(20);
    LET vcodret1    = '000';
    LET vcodret2    = '';
    LET vcodret3    = '';
    LET vcodret4    = '';
    LET sql_err	    = 0;
    LET isam_err    = 0;
    LET desc_err    = '';
    LET vcontador1  = 0;
    LET vcontador2  = 0;
    LET vcomienza   = -1;
    LET iTransacc   = 0;
    LET vsql        = '';
    LET vstmt       = '';
    LET vexiste     = 0;
    LET dFechaHoy   = '';
    LET dFechaAnt   = '';
    LET dFecha      = '';
    LET cFolio      = '';
    LET cTransac    = '';
    LET cCuenta     = '';
    LET mMonto      = 0.00;
    LET cTransac2   = '';
    LET cCuenta2    = '';
    LET mMonto2     = 0.00;
	LET mMonto_spei = 0.00;
	LET pEmpresa    = '001';
    
    -- // VARIABLES PARA TRANSFERENCIA SPEI
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
    LET cCodRetSp = '';
    LET cMensajeError = '';
    LET cCveRastreo = '';
    
    -- // VARIABLES CARGO EN CUENTA
    LET cCodRetCgo = '';
    LET cTrxCgo = '';
    LET dFechaCgo = '';
    LET mSdoDispCgo = 0.00;
    LET mMontoCgo = 0.00;
	LET cIva = 0.00;
	
	LET vnombrearchivo = '';
	LET vproceso  = "concisegatm";
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/RESPALDOSNEW/sp_concilia_seguro_atm.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/RESPALDOSNEW/sp_concilia_seguro_atm.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy, fecha_ant
      INTO dFechaHoy, dFechaAnt
      FROM sc_fechas
     WHERE empresa = pEmpresa;
	 
	LET vfecha2 = TO_CHAR(dFechaAnt, '%d%m%Y');
	
	-- // VERIFICA CONTROL DE PROCESOS EN CHEQUES
    select fecha
      into vfechaproc
      from sc_contproc
     where empresa = pempresa
       and proceso = vproceso;

    if vfechaproc = dFechaHoy then
	   let vcodret1 = '000';
       return vcodret1;
    end if;
	
	SELECT valor 
	  INTO vIvaBase
      FROM bdinteg:si_param
     WHERE empresa = pEmpresa
       AND cod_param = 47;

	IF vIvaBase IS NULL THEN
       LET vIvaBase = 0;
	END IF

	LET dFechaAnt = vfechaproc;
	
	select sum(monto_tot)
	  into mMonto
      from sc_movhis
     where transacc = "0393"
       and fech_alt >= dFechaAnt
       and cancelad <> "S";
	   
	IF mMonto > 0 THEN
	  
	   LET mMonto_spei = TRUNC(mMonto * .6, 2);
	   LET mMonto_Comision = mMonto - mMonto_spei;
	   LET cIva = vIvaBase + 1;
	   LET mMonto_Comision = ROUND(mMonto_Comision / cIva, 2);
	   LET vMontoIVA =  ROUND(mMonto_Comision * vIvaBase ,2);
	   
	   --LET vMontoIVA = ROUND(mMonto_spei * cIva, 2);
	   --LET mMonto_Comision = ROUND(mMonto_spei - vMontoIVA, 2);
	   
	END IF;
	
	IF mMonto_spei > 0 THEN
      
    -- // TRANSFERENCIA SPEI
		LET cCuentaOrden = '99000000490';
		LET cCuentaOrdenSPEI = '137180990000004909';
		LET cNombreOrdenSPEI = 'ARSA ASESORIA INTEGRAL PROFESIONAL';
		LET cRFCOrdenSPEI = 'AIP900419FI1';
		LET cSucursalSPEI = '9250';
		LET iBancoDestinoSPEI = 40012;
		LET dFechaCapturaSPEI = CURRENT;
		LET iTipoPagoSPEI = 1;
		LET iTipoOperacionSPEI = 0;
		LET mImporteOperacionSPEI = mMonto_spei;
		LET cNombreBeneficiarioSPEI = 'ARSA ASESORIA INTEGRAL PROFESIONAL';
		LET cCuentaBeneficiarioSPEI = '012914002015968882';
		LET cRFCBeneficiarioSPEI = 'AIP900419FI1';
		LET mImporteIVASPEI = 0.0;
		LET dReferenciaNumero = 0;
		LET cReferenciaCobranza1SPEI = '';
		LET cConceptoPagoSPEI = 'COBBCOP67 ARSA AS';
		LET cClavePagoSPEI = '';
		LET cNombreBeneficiario2SPEI = '';
		LET cCuentaBeneficiario2SPEI = '';
		LET cRFCBeneficiario2SPEI = '';
		LET cConceptoPago2SPEI = 'COBBCOP67 ARSA AS';
		LET cTransaccionSPEI = '0274';
		LET iTipoCuentaOrdenSPEI = 40;
		LET iTipoCuentaBeneficiarioSPEI = 40;
    
		EXECUTE PROCEDURE bdispei:sp_obtfoliosuc("conciatm") 
		INTO cCodRetSp, iSerialFolioSPEI, cFolioSucursalSPEI;
    
		IF cCodRetSp = '000' THEN
            -- // REALIZA EL CARGO A LA CUENTA DE CHEQUES
			EXECUTE PROCEDURE cargo_ref(pempresa, cSucursalSPEI, "informix", cTransaccionSPEI, '0000', cFolioSucursalSPEI, cCuentaOrden, 0, mImporteOperacionSPEI, '01', cCveRastreo, '', "informix")
			INTO cCodRetCgo, cTrxCgo, dFechaCgo, mSdoDispCgo, mMontoCgo;
            
			IF cCodRetCgo <> '000' THEN
				LET vcodret1 = cCodRetCgo; 
				RETURN vcodret1;
			END IF;
				
			-- // EJECUTA LA TRANSFERENCIA SPEI
			EXECUTE PROCEDURE bdispei:sp_regordenpagospei_pp( pempresa, "informix", cSucursalSPEI, cFolioSucursalSPEI, iBancoDestinoSPEI, dFechaCapturaSPEI, iTipoPagoSPEI, 
															iTipoOperacionSPEI, mImporteOperacionSPEI, cNombreOrdenSPEI, cCuentaOrdenSPEI, cRFCOrdenSPEI, cNombreBeneficiarioSPEI, 
															cCuentaBeneficiarioSPEI, cRFCBeneficiarioSPEI, mImporteIVASPEI, dReferenciaNumero, cReferenciaCobranza1SPEI, 
															cConceptoPagoSPEI, cClavePagoSPEI, cNombreBeneficiario2SPEI, cCuentaBeneficiario2SPEI, cRFCBeneficiario2SPEI,
															cConceptoPago2SPEI, cTransaccionSPEI, iTipoCuentaOrdenSPEI, iTipoCuentaBeneficiarioSPEI )
			INTO cCodRetSp, cMensajeError, cCveRastreo;
        
			IF cCodRetSp <> '000' THEN
				LET vcodret1 = cCodRetSp; 
				RETURN vcodret1;
			END IF;
			
			UPDATE bdicheq:sc_movdia SET referencia = cCveRastreo
			 WHERE folio_suc = cFolioSucursalSPEI;

			CALL cargon_ref(pempresa, cSucursalSPEI, "informix", "0501", "0000", cFolioSucursalSPEI, cCuentaOrden, 0, mMonto_Comision, "01", cConceptoPagoSPEI, "","")
			RETURNING cCodRetSp, cCodRetSp2;
			
			IF cCodRetSp <> '000' THEN
				LET vcodret1 = cCodRetSp; 
				RETURN vcodret1;
			END IF;			
			
			CALL cargon_ref(pempresa, cSucursalSPEI, "informix", "0335", "0000", cFolioSucursalSPEI, cCuentaOrden, 0, vMontoIVA, "01", cConceptoPagoSPEI, "","")
			RETURNING cCodRetSp, cCodRetSp2;
			
			IF cCodRetSp <> '000' THEN
				LET vcodret1 = cCodRetSp; 
				RETURN vcodret1;
			END IF;			
			 
		ELSE
			LET vcodret1 = cCodRetSp;
			RETURN vcodret1;
		END IF;
	END IF;
	
	-- // REGISTRA FINALIZACION DEL PROCESO
    update sc_contproc
       set fecha = dFechaHoy
     where empresa = pempresa
       and proceso = vproceso;
    
    END;
    
    RETURN vcodret1;
    
END PROCEDURE;