CREATE PROCEDURE "informix".spsctransctaspropias_trans(pEmpresa char(3),
                                                pSucursal char(4),
                                                pUsuario char(8),
                                                pTransCargo char(4),
                                                pTransAbono char(4),
                                                pTransSuc char(4),
                                                pFolioSuc char(16),
                                                pNumCtaOrigen char(12),
                                                pNumCtaDestino char(12),
                                                pCheque integer,
                                                pMonto money(14,2),
                                                pMoneda char(2),
                                                pReferencia char(40),
												pReferenciaBe char(40),
                                                pNumTarjetaOrigen char(16),
                                                pNumTarjetaDestino char(16),
                                                pUsuAutoriza char(8),
                                                pMontoTotal money(14,2),
                                                pMontoFirme money(14,2),
                                                pMontoSBC money(14,2),
                                                pMontoRem money(14,2),
                                                pDiasRet smallint,
                                                pDocto integer)
        RETURNING char(5), char(5);

	--******************************************************
	-- ModificÃ³     : RenÃ© Aldana HernÃ¡ndez
	-- Actividad    : Utiliza transacciones para cuentas transfer, realiza la transacciones de cuentas BanCoppel a cuentas trasnfer BanCoppel
	--                8018	ABONO POR TRASPASO TRANSFER 
	--                8019	CARGO POR TRSAPASO TRANSFER                       
    

	DEFINE vcodret   char(5);
       	DEFINE vcodretRev   char(5);
       	DEFINE sql_err   integer;
       	DEFINE vTrans    char(4);
	DEFINE vFechaHoy date;
	DEFINE vSdoDisp  money(14,2);
	DEFINE vMontoRet money(14,2);
	DEFINE vPasoCargo char(1);
	DEFINE vMensajeRet char(100);
	DEFINE vReferencia	char(40);
	DEFINE vTransCargo char(4);
	DEFINE vCliente1 CHAR(20);
	DEFINE vCuenta1 char(12);
	DEFINE vTransAbono CHAR(4);
    DEFINE cReferencia varchar(40);
    DEFINE aReferencia varchar(40);
	   
	LET vReferencia ='' ;
   	LET vTransCargo ='';
	  
	LET vCliente1 ='';
	LET vCuenta1 ='';
	LET vTransAbono='';
	   
	
--set debug file to "/informix/bdicheq/spsctransctaspropias_trans.out";
--trace on;	
	
BEGIN
ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        IF vPasoCargo = '1' THEN
            EXECUTE PROCEDURE bdicheq:"informix".reversion(pEmpresa,
                                        pSucursal,
                                        pUsuario,
                                        pFolioSuc,
                                        'A') INTO vcodretRev;
        END IF;
        IF vcodretRev = '000' THEN
            LET vcodretRev = '001';
        END IF;

        LET vcodret = sql_err;
        RETURN vcodret, vcodretRev;
       END IF;
END EXCEPTION;

SET ISOLATION DIRTY READ;
SET LOCK MODE TO WAIT 3;

LET vPasoCargo = '0';
LET vcodret = '000';
LET vcodretRev = '000';
LET vMensajeRet = '';

LET cReferencia = '';
LET aReferencia = '';

  /*IF pReferenciaBe  = '' THEN
		LET vReferencia = pReferencia;
    ELSE
		LET vReferencia = pReferenciaBe;
    END IF;*/

---AsignaciÃ³n y concatenaciÃ³n de Cuenta del Cargo/Abono y la Referencia para el Estado de Cuenta
LET cReferencia = TRIM(pNumCtaDestino) || ' ' || pReferencia; --cargo y la Referencia 
LET aReferencia = TRIM(pNumCtaOrigen) || ' ' || pReferenciaBe; --abono y la Referencia del Beneficiario


	EXECUTE PROCEDURE bdicheq:"informix".sp_validatransferencias_bpi_trans(pEmpresa, pNumCtaOrigen, pNumCtaDestino)
    INTO vcodret, vMensajeRet ;
	--*********************************************************************--
	
	LET vTransCargo=pTransCargo;
	LET vTransAbono=pTransAbono;		
	
	
	--*********************************************************************--
		
	
    IF  vcodret = '00000'  THEN
            EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(pEmpresa,
                                        pSucursal,
                                        pUsuario,
                                        vTransCargo, --Envia 8019 
                                        pTransSuc,
                                        pFolioSuc,
                                        pNumCtaOrigen,
                                        pCheque,
                                        pMonto,
                                        pMoneda,
                                        cReferencia,
                                        pNumTarjetaOrigen,
                                        pUsuAutoriza) INTO vcodret,
                                                           vTrans,
                                                           vFechaHoy,
                                                           vSdoDisp,
                                                           vMontoRet;

            IF vcodret <> '000' THEN
                RETURN vcodret, vcodretRev;
            ELSE
                LET vPasoCargo = '1';
            END IF;

            EXECUTE PROCEDURE bdicheq:"informix".abono_ref(pEmpresa,
                                        pSucursal,
                                        pUsuario,
                                        vTransAbono, --Envia 8018 
                                        pTransSuc,
                                        pFolioSuc,
                                        pNumCtaDestino,
                                        pDocto,
                                        pMontoTotal,
                                        pMontoFirme,
                                        pMontoSBC,
                                        pMontoRem,
                                        pDiasRet,
                                        pMoneda,
                                        aReferencia,
                                        pNumTarjetaDestino,
                                        pUsuAutoriza) INTO vcodret;

            IF vcodret <> '000' THEN
                EXECUTE PROCEDURE bdicheq:"informix".reversion(pEmpresa,
                                            pSucursal,
                                            pUsuario,
                                            pFolioSuc,
                                            'A') INTO vcodretRev;
                IF vcodretRev = '000' THEN
                    LET vcodretRev = '001';
                END IF;
                RETURN vcodret, vcodretRev;
            END IF;
    ELSE
        RETURN vcodret, vcodretRev;
    END IF;

END;
RETURN vcodret, vcodretRev;
END PROCEDURE;