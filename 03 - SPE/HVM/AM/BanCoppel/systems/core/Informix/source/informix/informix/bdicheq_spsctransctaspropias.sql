CREATE PROCEDURE "informix".spsctransctaspropias(pEmpresa char(3),
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

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Transferencia entre cuentas propias
    -- Solicitó  : Diana Castellanos
    -- Fecha     :  20/05/2008
	--******************************************************
	-- Modificó		: Nydia Payán
	-- Actividad	: Se agrega validación para Asignación y concatenación de Cuenta del Cargo y/o
    --                la Cuenta Abono, y la Referencia para el Estado de Cuenta    
	-- Solicitó		: Alejandro vazquez
	-- Fecha		: 27/04/2015
	--******************************************************

       DEFINE vcodret   char(5);
       DEFINE vcodretRev   char(5);
       DEFINE sql_err   integer;
       DEFINE vTrans    char(4);
       DEFINE vFechaHoy date;
       DEFINE vSdoDisp  money(14,2);
       DEFINE vMontoRet money(14,2);
       DEFINE vPasoCargo char(1);
       DEFINE vMensajeRet char(100);
	   
	   DEFINE cReferencia varchar(40); 
       DEFINE aReferencia varchar(40);

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        IF vPasoCargo = '1' THEN
            EXECUTE PROCEDURE reversion(pEmpresa,
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

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


LET vPasoCargo = '0';
LET vcodret = '000';
LET vcodretRev = '000';
LET vMensajeRet = '';
--set debug file to '/controlcambios/P-BD-21042021-01/traspasobanco/bpi_trasacciones_21042021.out';
--trace on;

LET cReferencia = '';
LET aReferencia = '';

---Asignación y concatenación de Cuenta del Cargo/Abono y la Referencia para el Estado de Cuenta
LET cReferencia = TRIM(pNumCtaDestino) || ' ' || pReferencia;LET aReferencia = TRIM(pNumCtaOrigen) || ' ' || pReferencia;
BEGIN

    EXECUTE PROCEDURE sp_validatransferencias_bpi(pEmpresa, pNumCtaOrigen, pNumCtaDestino)
    INTO vcodret, vMensajeRet ;

    IF  vcodret = '00000'  THEN
            EXECUTE PROCEDURE cargo_ref(pEmpresa,
                                        pSucursal,
                                        pUsuario,
                                        pTransCargo,
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

            EXECUTE PROCEDURE abono_ref(pEmpresa,
                                        pSucursal,
                                        pUsuario,
                                        pTransAbono,
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
                EXECUTE PROCEDURE reversion(pEmpresa,
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