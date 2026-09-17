CREATE PROCEDURE "informix".spsdpagotarcredpropia_mib(pEmpresa char(3),
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
                                                pUsuAutoriza char(8),
                                                pTiPago smallint)
        RETURNING char(5), char(5);

	-- Realizo   	: Javier Humberto Calderon Zazueta
	-- Actividad 	: Pago Tarjeta Credito Bancoppel
	-- Solicito: Diana Castellanos
	-- Fecha     	: 26/05/2008
	-- Modificacion : 08/04/2025 Cambio para no permitir los pagos de productos '7800','6900','8900'

	DEFINE vcodret   char(5);
	DEFINE vcodretRev   char(5);
	DEFINE sql_err   integer;
	DEFINE vTrans    char(4);
	DEFINE vFechaHoy date;
	DEFINE vSdoDisp  money(14,2);
	DEFINE vMontoRet money(14,2);
	DEFINE vPasoCargo char(1);
	DEFINE vRemanente money(14,2);
	DEFINE vIntMoratorio money(14,2);
	DEFINE vIntVencido money(14,2);
	DEFINE vCapitalVencido money(14,2);
	DEFINE vInteresVigente money(14,2);
	DEFINE vCapitalVigente money(14,2);
	DEFINE vImpuestos money(14,2);
	DEFINE vComisiones money(14,2);
	DEFINE vSeguroCobrado money(14,2);
	define vtransaccion         integer;
	DEFINE cNumProd			CHAR(04);
	   
	   --LET  vtransaccion = 0;

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
		
		if vtransaccion = 1 then
  		    ROLLBACK WORK;
			BEGIN WORK;
		else
			ROLLBACK WORK;
        end if;
		
        RETURN vcodret, vcodretRev;
       END IF;
END EXCEPTION;

on exception in (-535)
    let vtransaccion = 1;
end exception with resume;

LET vtransaccion = 0;
LET vPasoCargo = '0';
LET vcodret = '000';
LET vcodretRev = '000';
  --Set debug file to '/home/SP/spsdpagotarcredpropia_mib.out';				
  --trace on;
BEGIN

	BEGIN WORK;

	--ObtenciÃ³n de producto para validaciÃ³n del 7800
	SELECT nvl(num_producto,'') INTO cNumProd
	FROM bdicred:sd_maecred WHERE  num_credito = pNumCtaDestino;
	
	IF NVL(TRIM(cNumProd),'') = '7800' THEN 
		LET vcodret = '001';	ELSE
		EXECUTE PROCEDURE bdicred:sp_validapagotdc_bpi(pNumCtaOrigen, pNumCtaDestino)
		INTO vcodret;
	END IF;

--
	IF NVL(TRIM(cNumProd),'') = '7800' THEN 
		LET vcodret = '001';	ELIF NVL(TRIM(cNumProd),'') = '' THEN
		SELECT nvl(num_producto,'') INTO cNumProd --ObtenciÃ³n de producto para validaciÃ³n del 7800
		FROM bdicred:sd_maecredcrd WHERE  num_credito = pNumCtaDestino;
		
		IF NVL(TRIM(cNumProd),'') IN ('6900','8900') THEN 
			LET vcodret = '001';		END IF;
		
	END IF;
	
	IF vcodret = '000' THEN
		EXECUTE PROCEDURE bdicred:sp_validapagotdc_bpi(pNumCtaOrigen, pNumCtaDestino)
		INTO vcodret;
    ELSE 
       IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;	
		
        RETURN vcodret, vcodretRev;
    END IF;

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
	      if vtransaccion = 1 then
            COMMIT WORK;
            BEGIN WORK;
        else
            COMMIT WORK;
        end if;
        RETURN vcodret, vcodretRev;
    ELSE
        LET vPasoCargo = '1';
    END IF;

	
	--SE MANDA A LLAMAR EL SPL. principalrefer a sugerencia del á²¥a de cré¤©to en lugar del sp principal
    --EXECUTE PROCEDURE bdicred:principal(pEmpresa,pNumCtaDestino,pTiPago,pMonto,pUsuario,pSucursal,pFolioSuc,pTransAbono) 
	--INTO vcodret,vRemanente,vIntMoratorio,vIntVencido,vCapitalVencido,vInteresVigente,vCapitalVigente,vImpuestos,vComisiones,vSeguroCobrado;
	
	EXECUTE PROCEDURE bdicred:principalrefer(pEmpresa,
											 pNumCtaDestino,
											 pTiPago,
											 '',
											 pUsuario,
											 pSucursal,
											 pFolioSuc,
											 pTransAbono,
											 0.00,
											 pMonto,
											 '') INTO vcodret,
													  vRemanente,
													  vIntMoratorio,
													  vIntVencido,
													  vCapitalVencido,
													  vInteresVigente,
													  vCapitalVigente,
													  vImpuestos,
													  vComisiones,
													  vSeguroCobrado;														  
    IF vcodret <> '000' THEN
        EXECUTE PROCEDURE bdicheq:reversion(pEmpresa,
                                            pSucursal,
                                            pUsuario,
                                            pFolioSuc,
                                            'A') INTO vcodretRev;
        IF vcodretRev = '000' THEN
            LET vcodretRev = '001';
        END IF;
		if vtransaccion = 1 then
            COMMIT WORK;
            BEGIN WORK;
        else
            COMMIT WORK;
        end if;
        RETURN vcodret, vcodretRev;
    END IF;

	if vtransaccion = 1 then
		COMMIT WORK;
		BEGIN WORK;
	else
		COMMIT WORK;
	end if;


END;
RETURN vcodret, vcodretRev;


END PROCEDURE;