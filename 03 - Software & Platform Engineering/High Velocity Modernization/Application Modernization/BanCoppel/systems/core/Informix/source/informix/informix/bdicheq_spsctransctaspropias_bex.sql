CREATE PROCEDURE "informix".spsctransctaspropias_bex(pEmpresa char(3),
                                                pSucursal char(4),
                                                pUsuario char(8),
                                                pTransCargo char(4),
                                                pTransAbono char(4),
                                                pTransSuc char(4),
                                                pFolioSuc char(16),
                                                pNumCtaOrigen char(12),
                                                pNumCtaDestino char(18),
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

    -- SP de 23 registros
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
	DEFINE vReferencia	char(40);
	DEFINE vTransCargo char(4);
	DEFINE vCliente1 CHAR(20);
	DEFINE vCuenta1 char(12);
	DEFINE vTransAbono CHAR(4);
    DEFINE cReferencia varchar(40);
    DEFINE aReferencia varchar(40);
	DEFINE vFechaProcesoOr date;
	DEFINE vFechaProcesoDe date;
	DEFINE vLogCta 			INTEGER;
	DEFINE vBin		varchar(8);
	DEFINE vStatusCtaOr  varchar(2);
	DEFINE vStatusCtaDe  varchar(2);
	  
	LET vReferencia ='' ;
   	LET vTransCargo ='';
	LET vCliente1 ='';
	LET vCuenta1 ='';
	LET vTransAbono='';
	LET vPasoCargo = '0';
	LET vcodret = '00000	';
	LET vcodretRev = '000';
	LET vMensajeRet = '';
	LET cReferencia = '';
	LET aReferencia = '';
	LET vBin = '';
	LET vLogCta=LENGTH(pNumCtaDestino);
	LET vStatusCtaOr = '';
	LET vStatusCtaDe = '';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;
	
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


	IF vLogCta <> 11 THEN
		
		IF vLogCta = 18 THEN
			SELECT cuenta INTO pNumCtaDestino FROM bdicheq:sc_maechq WHERE cuenta_clabe = pNumCtaDestino;
		ELSE IF vLogCta = 16 THEN
			    --Se quita la validacion del bin debido a que ya se encuentran cancelada 
				--LET vBin= LEFT(pNumCtaDestino, 8);
				--IF vBin = '40081904' THEN 
					--LET vcodret = '00001';
				--ELSE

				  SELECT cuenta INTO pNumCtaDestino FROM  bdicheq:sc_tarjeta WHERE empresa='001' AND num_tarjeta = pNumCtaDestino AND status_tar = 'A';
			    -- END IF
		ELSE IF vLogCta = 10 THEN	
					SELECT cuenta INTO pNumCtaDestino FROM  bdicheq:sc_cuenta_telefono WHERE telefono = pNumCtaDestino;
		ELSE
					LET vcodret = '00001'; --Cuenta no valida
			  END IF;
			END IF;			
		END IF;
		
		IF pNumCtaDestino IS NULL THEN
			LET vcodret = '00002';   --Cuenta destino en nulo
		END IF;
	END IF;	
		

	---Asignacion y concatenacion de Cuenta del Cargo/Abono y la Referencia para el Estado de Cuenta
	LET cReferencia = TRIM(pNumCtaDestino) || ' ' || pReferencia; --cargo y la Referencia 
	LET aReferencia = TRIM(pNumCtaOrigen) || ' ' || pReferenciaBe; --abono y la Referencia del Beneficiario
	
	LET vTransCargo=pTransCargo;
	LET vTransAbono=pTransAbono;

		IF pTransCargo='0239' THEN
			select count(distinct num_cte), count(cuenta)
			into vCliente1, vCuenta1
			from bdicheq:"informix".sc_maechq
			where ( cuenta=pNumCtaOrigen  or cuenta=pNumCtaDestino)
			and empresa ='001';
			
			IF vCliente1 = 1 AND vCuenta1 = 2 THEN
				LET vTransCargo='0309';
				LET vTransAbono='0313';
				LET aReferencia = TRIM(pNumCtaOrigen) || ' ' || pReferencia;			
					
			END IF
		END IF
		
		--********************Valida los estatus y fechas*********************************************--
		IF vcodret = '00000' THEN
		
			SELECT fecha_proceso,status_cta INTO vFechaProcesoOr, vStatusCtaOr FROM bdicheq:sc_maechq WHERE cuenta = pNumCtaOrigen;
			SELECT fecha_proceso,status_cta INTO vFechaProcesoDe, vStatusCtaDe FROM bdicheq:sc_maechq WHERE cuenta = pNumCtaDestino;

				IF (vStatusCtaOr IN('2','6','7','8') OR vStatusCtaDe  IN('2','6','7','8')) THEN
					
					LET vcodret = '00003'; --Cuenta  con status invalido

				ELIF (vStatusCtaOr IN('1','3','5') AND vStatusCtaDe  IN('1','3','5')) THEN
					IF (vFechaProcesoOr <> vFechaProcesoDe)  THEN
					
						LET vcodret = '00004';  --Fecha proceso de cuenta destino diferente al dia
					
					END IF;	
				END IF;
				
		END IF
		
		
		IF  vcodret = '00000'  THEN
				EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(pEmpresa,
											pSucursal,
											pUsuario,
											vTransCargo, --Envia 0309 si es entre cuentas del mismo cliente sino envia el de entrada 0239.
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
											vTransAbono, --Envia 0313 si es entre cuentas del mismo cliente sino envia el de entrada 0205.
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