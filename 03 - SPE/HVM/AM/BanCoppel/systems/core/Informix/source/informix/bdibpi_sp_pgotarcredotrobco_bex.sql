CREATE PROCEDURE "informix".sp_pgotarcredotrobco_bex(pEmpresa char(3),
                                                pSucursal char(4),
                                                pUsuario char(8),
                                                pTransCargo char(4),
                                                pTransAbono char(4),
                                                pTransSuc char(4),
                                                pFolioSuc char(16),
                                                pNumCtaOrigen char(12),
                                                pNumCtaDestino char(16),
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

    -- Actividad : Pago de Tarjeta de Credito de Otro Banco
    -- Ajuste  : Se realizo la copia del SPL sp_pgotarcredotrobco solo se modifico el llamado sp_validatransferencias_bpi
    -- Fecha     :  16/06/2010

       DEFINE vcodret   char(5);
       DEFINE vcodretRev   char(5);
       DEFINE sql_err   integer;
       DEFINE vTrans    char(4);
       DEFINE vFechaHoy date;
       DEFINE vSdoDisp  money(14,2);
       DEFINE vMontoRet money(14,2);
       DEFINE vPasoCargo char(1);
       DEFINE vMensajeRet char(100);
	   DEFINE vCtaConc char(20);

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        IF vPasoCargo = '1' THEN
            EXECUTE PROCEDURE bdicheq:reversion(pEmpresa,
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


LET vPasoCargo = '0';
LET vcodret = '000';
LET vcodretRev = '000';
LET vMensajeRet = '';

--SET debug FILE TO "/informix/ireb/bdibpi/bex/sp_pgotarcredotrobco_bex.out";
--Trace ON;

BEGIN

    --EXECUTE PROCEDURE sp_validatransferencias_bpi(pEmpresa, pNumCtaOrigen, pNumCtaDestino)
    --INTO vcodret, vMensajeRet ;

    IF  vcodret = '000'  THEN
            EXECUTE PROCEDURE bdicheq:cargo_ref(pEmpresa,
                                        pSucursal,
                                        pUsuario,
                                        pTransCargo,
                                        pTransSuc,
                                        pFolioSuc,
                                        pNumCtaOrigen,
                                        pCheque,
                                        pMonto,
                                        pMoneda,
                                        pReferencia,
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
			
			select trim(valor) INTO vCtaConc from bdisac:sac_param where cod_param = '33009';

            EXECUTE PROCEDURE bdicheq:abono_ref(pEmpresa,
                                        pSucursal,
                                        pUsuario,
                                        pTransAbono,
                                        pTransSuc,
                                        pFolioSuc,
                                        vCtaConc,
                                        pDocto,
                                        pMontoTotal,
                                        pMontoFirme,
                                        pMontoSBC,
                                        pMontoRem,
                                        pDiasRet,
                                        pMoneda,
                                        pReferencia,
                                        pNumTarjetaDestino,
                                        pUsuAutoriza) INTO vcodret;

            IF vcodret <> '000' THEN
                EXECUTE PROCEDURE bdicheq:reversion(pEmpresa,
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