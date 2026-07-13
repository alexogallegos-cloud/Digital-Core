create procedure "informix".sp_modmaesdos_central(pEmpresa                  CHAR(3),
                                                  pNumCred                  CHAR(20),
            								      pTipoSaldo                CHAR(2),
												  pQuitaAbono               DECIMAL(18,2),
												  pCastigoAbono             DECIMAL(18,2),
												  pQuebrantoAbono           DECIMAL(18,2),
												  pAjusteCargo              DECIMAL(18,2),
												  pAjusteAbono              DECIMAL(18,2),
												  pCondonacionAbono         DECIMAL(18,2),
												  pIvaInteresVigente	    DECIMAL(18,2),
												  pIvaInteresVencido        DECIMAL(18,2),
												  pMontoActual              DECIMAL(18,2),
												  pDescripcionMovimiento    CHAR(100),
												  pClaveEmpleadoAutorizo    CHAR(20),
                                                  cfolio                    CHAR(16))
RETURNING
   CHAR(6),        -- numero de retorno del proceso
   CHAR (80),      -- Mensaje de retorno del proceso
   DECIMAL(18,2),  -- Monto actual
   DECIMAL(18,2),  -- Cantidad para actualizar
   DECIMAL(18,2),  -- Monto Actual despues de la afectación

   CHAR(16);       -- Folio

-- Autor: David Uriel Prieto Hurtado
-- Fecha de Creación 29/01/2009
-- Observaciones: Se realiza procedimiento para actualizar los saldos de capital en el maestro de
--                saldos (tabla: "bdicred:sd_ maesdos").
-- Autor: Paul Ivan Quintero Varela
-- Fecha de creación 22/05/2009
-- Observaciones: Se modifica para contemplar que no genere movimiento contable en moratorios
--                         y no se intente modificar ivas de intereses y se recalculen de forma automatica.
-- Autor: Roque Solis Campaña
-- Fecha de Creación: 23/06/2009
-- Observaciones: Se modifica para que en la actualización de interes vencido
--                       se actualiza conforme a la misma manera en la cual es obtenida
--                       mediante el status e iva del mes correspondiente.
DEFINE iSqlErr                     INTEGER;
DEFINE iIsamErr                    INTEGER;
DEFINE cErrorInfo                  CHAR(80);
DEFINE cCodRet                     CHAR(6);
DEFINE cMensajeRet                 CHAR(80);
DEFINE dMtoActual                  DECIMAL(18,2);
DEFINE dSdoNuevo                   DECIMAL(18,2);
DEFINE dSdoNuevoAux                DECIMAL(18,2);
DEFINE dMtoActual1                 DECIMAL(18,2);
DEFINE dMtoActual2                 DECIMAL(18,2);
DEFINE dMtoActual3                 DECIMAL(18,2);
DEFINE dMtoActual4                 DECIMAL(18,2);
DEFINE dMtoActual5                 DECIMAL(18,2);
DEFINE dMtoActual6                 DECIMAL(18,2);
DEFINE dMtoActual7                 DECIMAL(18,2);
DEFINE dMtoActual8                 DECIMAL(18,2);
DEFINE dSumMtosActualizar          DECIMAL(18,2);
DEFINE dSumAbonos                  DECIMAL(18,2);
DEFINE dSumCargos                  DECIMAL(18,2);
DEFINE cIdMovto                    CHAR(1);
DEFINE cNumProducto                CHAR(4);
DEFINE cStatusCred                 CHAR(2);
DEFINE dtFecha                     DATE;
DEFINE cSucursal                   CHAR(4);
DEFINE cDivisa                     CHAR(2);
DEFINE cDescTipoMovto              CHAR(16);
DEFINE iCantReg                    INTEGER;
DEFINE dtFechaCuota                DATE;
DEFINE dtFechaComparacion          DATE;
DEFINE dtFechaCuotaAux             DATE;
DEFINE dIntVigDebe                 DECIMAL(18,2);
DEFINE dIntVigPagado               DECIMAL(18,2);
DEFINE dIvaIntVigDebe              DECIMAL(18,2);
DEFINE dIvaIntVdoPagado            DECIMAL(18,2);
DEFINE dIvaIntVig                  DECIMAL(18,2);
DEFINE dIvaIntVdo                  DECIMAL(18,2);
DEFINE dIvaDebe                    DECIMAL(18,2);
DEFINE dIvaPagado                  DECIMAL(18,2);
DEFINE dInteresMes                 DECIMAL(18,2);
DEFINE dIvaMes                     DECIMAL(18,2);
DEFINE dSumIvaIntVig               DECIMAL(18,2);
DEFINE dinteres_debe               DECIMAL(18,2);
DEFINE dinteres_pagado             DECIMAL(18,2);
DEFINE Ddiferencia                 DECIMAL (18,2);
DEFINE dPagointeres                DECIMAL(18,2);
DEFINE dMtoCapVig                  DECIMAL(18,2);
DEFINE dMtoCapTrans                DECIMAL(18,2);
DEFINE dMtoCapVdo                  DECIMAL(18,2);
DEFINE dMtoVdoNoExig               DECIMAL(18,2);
DEFINE dMtoIntVig                  DECIMAL(18,2);
DEFINE dMtoIvaIntVig          	   DECIMAL(18,2);
DEFINE dMtoIntVdo                  DECIMAL(18,2);
DEFINE dMtoIntMoraOrdi             DECIMAL(18,2);
DEFINE dMtoIntMoraCope             DECIMAL(18,2);
DEFINE iBanVigVdo                  INTEGER;
DEFINE cSdoAfectado                CHAR(20);
DEFINE cTpoMovtoQuitaA             CHAR(2);
DEFINE cTpoMovtoCatigoA            CHAR(2);
DEFINE cTpoMovtoQuebrantoA         CHAR(2);
DEFINE cTpoMovtoAjusteC            CHAR(2);
DEFINE cTpoMovtoAjusteA            CHAR(2);
DEFINE cTpoMovtoCondonacionA       CHAR(2);
DEFINE cTpoMovtoIvaInteresVigente  CHAR(2);
DEFINE cTpoMovtoIvaInteresVencido  CHAR(2);
DEFINE dMora_provi_ordi            DECIMAL (18,2);
DEFINE dMora_provi_cope            DECIMAL (18,2);
DEFINE dMora_sdo_ordi              DECIMAL (18,2);
DEFINE dMora_sdo_ordi_pag          DECIMAL (18,2);
DEFINE dMora_sdo_cope              DECIMAL (18,2);
DEFINE dMora_sdo_cope_pag          DECIMAL (18,2);
DEFINE iCodigoRef                  INTEGER;
DEFINE cCodigoFun                  CHAR(3);
DEFINE cBanCapStatus               CHAR(1);
DEFINE dCapDebeAux                 DECIMAL(18,2);
DEFINE dCapPagAux                  DECIMAL(18,2);
DEFINE dMtoCapAux                  DECIMAL(18,2);
DEFINE dIntDebeAux                 DECIMAL(18,2);
DEFINE dIntPagAux                  DECIMAL(18,2);
DEFINE dSumAbonosAux               DECIMAL(18,2);
DEFINE dAbonoCap                   DECIMAL(18,2);
DEFINE dAbonoInt                   DECIMAL(18,2);
DEFINE dAbonoIntMoraOrdiAux        DECIMAL(18,2);
DEFINE dIntMoraOrdiDebeAux         DECIMAL(18,2);
DEFINE dIntMoraOrdiPagAux          DECIMAL(18,2);
DEFINE dIntMoraOrdiProviAux        DECIMAL(18,2);
DEFINE dAbonoIntMoraCopeAux        DECIMAL(18,2);
DEFINE dIntMoraCopeDebeAux         DECIMAL(18,2);
DEFINE dIntMoraCopePagAux          DECIMAL(18,2);
DEFINE dIntMoraCopeProviAux        DECIMAL(18,2);

LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "";
LET cMensajeRet     = "";
LET dMtoActual            = 0;
LET dSdoNuevo             = 0;
LET dSdoNuevoAux          = 0;
LET dMtoActual1           = 0;
LET dMtoActual2           = 0;
LET dMtoActual3           = 0;
LET dMtoActual4           = 0;
LET dMtoActual5           = 0;
LET dMtoActual6           = 0;
LET dMtoActual7           = 0;
LET dMtoActual8           = 0;
LET dSumMtosActualizar    = 0;
LET dSumAbonos            = 0;
LET dSumCargos            = 0;
LET cIdMovto              = "";
LET cNumProducto          = "";
LET cStatusCred           = "";
LET dtFecha               = DATE(1);
LET cSucursal             = "";
LET cDivisa               = "";
LET cDescTipoMovto        = "NV";
LET iCantReg              = 0;
LET dtFechaCuota          = DATE(1);
LET dtFechaComparacion    = DATE(1);
LET dtFechaCuotaAux       = DATE(1);
LET dIntVigDebe           = 0;
LET dIntVigPagado         = 0;
LET dIvaIntVigDebe        = 0;
LET dIvaIntVdoPagado      = 0;
LET dIvaIntVig            = 0;
LET dIvaIntVdo            = 0;
LET dIvaDebe              = 0;
LET dIvaPagado            = 0;
LET dInteresMes           = 0;
LET dIvaMes               = 0;
LET dSumIvaIntVig         = 0;
LET dinteres_debe         = 0;
LET dinteres_pagado       = 0;
LET Ddiferencia           = 0;
LET dPagointeres          = 0;
LET cBanCapStatus         = '';
LET dMtoCapVig            = 0;
LET dMtoCapTrans          = 0;
LET dMtoCapVdo            = 0;
LET dMtoVdoNoExig         = 0;
LET dMtoIntVig            = 0;
LET dMtoIvaIntVig         = 0;
LET dMtoIntVdo            = 0;
LET dMtoIntMoraOrdi       = 0;
LET dMtoIntMoraCope       = 0;
LET iBanVigVdo            = 0;
LET dMora_provi_ordi      = 0;
LET dMora_provi_cope      = 0;
LET dMora_sdo_ordi        = 0;
LET dMora_sdo_ordi_pag    = 0;
LET dMora_sdo_cope        = 0;
LET dMora_sdo_cope_pag    = 0;
LET cSdoAfectado          = "" ;

-- Parametros del catalogo de tipos de movimientos
LET cTpoMovtoQuitaA             = '01'; -- Quita-Abono
LET cTpoMovtoCatigoA            = '02'; -- Castigo-Abono
LET cTpoMovtoQuebrantoA         = '03'; -- Quebranto-Abono
LET cTpoMovtoAjusteC            = '04'; -- Cargo-Ajuste
LET cTpoMovtoAjusteA            = '05'; -- Abono-Ajuste
LET cTpoMovtoCondonacionA       = '06'; -- Condonacion-Abono
LET cTpoMovtoIvaInteresVigente  = '07'; -- Recalculo de Iva de interes Vigente
LET cTpoMovtoIvaInteresVencido  = '08'; -- Recalculo de Iva de interes Vencido

-- Parametros para transacciones de movimientos.
LET iCodigoRef  = 0;
LET cCodigoFun  = "";
--
LET dCapDebeAux   = 0;
LET dCapPagAux    = 0;
LET dMtoCapAux    = 0;
LET dIntDebeAux   = 0;
LET dIntPagAux    = 0;
LET dSumAbonosAux = 0;
LET dAbonoCap     = 0;
LET dAbonoInt     = 0;

LET dAbonoIntMoraOrdiAux  = 0;
LET dIntMoraOrdiDebeAux   = 0;
LET dIntMoraOrdiPagAux    = 0;
LET dIntMoraOrdiProviAux  = 0;

LET dAbonoIntMoraCopeAux  = 0;
LET dIntMoraCopeDebeAux   = 0;
LET dIntMoraCopePagAux    = 0;
LET dIntMoraCopeProviAux  = 0;

BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      ROLLBACK WORK;
      RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/tmp/sp_ModMaesdos_Central-X.out";
--TRACE ON;
SET LOCK MODE TO WAIT 3;

BEGIN WORK;
-- Se obtiene la información correspondiente al crédito
  SELECT
		a.num_producto,       -- Número de producto
		a.status_cred,        -- Status del crédito
		a.sucursal,           -- Sucursal
		a.divisa,             -- Divisa
        b.sdo_capital,        -- Monto Capital Vigente
		b.monto_vencido,      -- Monto Capital Transitorio
		b.mto_venc_trasp,     -- Monto Capital Vencido
		b.cap_tras_no_venci,  -- Monto Capital Vencido No Exigible
        b.sdo_no_exig,        -- Monto Interes Vigente
        b.int_tra_no_exig,    -- Monto Interes Vencido
		c.fecha_hoy           -- Fecha hoy del sistema
    INTO
		cNumProducto,
		cStatusCred,
		cSucursal,
		cDivisa,
		dMtoCapVig,
		dMtoCapTrans,
		dMtoCapVdo,
		dMtoVdoNoExig,
        dMtoIntVig,
        dMtoIntVdo,
		dtFecha
	FROM
		"informix".sd_maecred a,
        "informix".sd_maesdos b,
        "informix".sd_fechas c,
        "informix".sd_definicion d,
         bdinteg:"informix".si_sucursales e
    WHERE a.empresa          = pEmpresa
	  AND a.num_credito      = pNumCred
	  AND a.bANDera_ministra = 'M'
	  AND b.empresa          = a.empresa
	  AND b.num_credito      = a.num_credito
	  AND c.empresa          = a.empresa
	  AND d.empresa          = a.empresa
	  AND d.num_producto     = a.num_producto
	  AND e.empresa			 = a.empresa
	  AND e.sucursal         = a.sucursal;

-- Se obtiene el calculo de la suma para el monto a actualizar.
LET dSumMtosActualizar = pAjusteCargo - pAjusteAbono; /*pCastigoAbono - pQuebrantoAbono - pQuitaAbono -  - pCondonacionAbono;*/
LET dSumAbonos         = pAjusteAbono;
LET dSumCargos         = pAjusteCargo;

IF NVL(cfolio,'')= '' THEN
     LET cDescTipoMovto="NV"|| LPAD(DAY(dtFecha),2,'0')||LPAD(MONTH(dtFecha),2,'0')||YEAR(dtFecha)|| REPLACE(REPLACE(REPLACE(EXTEND(CURRENT,HOUR TO fraction(3)), ':',''),'.',''),'-','');
     LET cfolio = cDescTipoMovto;
ELSE
    LET cDescTipoMovto = cfolio;
END IF;
-- Identifica el tipo de amortizacion a realizar
IF DAY(dtFecha) <= 20 THEN
    LET dtFechaComparacion = MDY(MONTH(dtFecha - 1 UNITS MONTH),20, YEAR(dtFecha));
ELSE
    LET dtFechaComparacion = MDY(MONTH(dtFecha),20, YEAR(dtFecha));
END IF;
-- Se identifica el capital a afectar,
-- y se actualiza el campo correspondiente en el maestro de saldos.
IF pTipoSaldo= "01" THEN -- Capital Vigente
       LET cSdoAfectado= 'sdo_capital';
       LET dMtoActual= dMtoCapVig;
       LET dSdoNuevo= dMtoCapVig + dSumMtosActualizar;

 IF dMtoActual = pMontoActual THEN
				IF dSdoNuevo > dMtoActual THEN
                {IF dMtoCapVig < 0 THEN
                    UPDATE "informix".sd_amortiza_credito
                       SET capital_debe = capital_debe + dSumCargos + dMtoCapVig
                     WHERE empresa    = pEmpresa
                       AND num_Credito = pNumCred
                       AND fecha_cuota = dtFechaComparacion;

                    UPDATE "informix".sd_amortiza_credito
                       SET capital_pagado = capital_pagado - dMtoCapVig
                     WHERE  empresa    = pEmpresa
                       AND num_Credito = pNumCred
                       AND fecha_cuota = dtFechaComparacion;
                 ELSE
                    UPDATE "informix".sd_amortiza_credito
                       SET capital_debe = capital_debe + dSumCargos
                     WHERE  empresa    = pEmpresa
                       AND num_Credito = pNumCred
                       AND fecha_cuota = dtFechaComparacion;
                 END IF;}
		    ELSE
                    LET dSumAbonosAux = dSumAbonos;
                    FOREACH
                        SELECT fecha_cuota, capital_debe, capital_pagado
                          INTO dtFechaCuotaAux, dCapDebeAux, dCapPagAux
                          FROM "informix".sd_amortiza_credito
                         WHERE empresa      = pEmpresa
                           AND num_credito  = pNumCred
                           AND fecha_cuota <= dtFechaComparacion
                           AND capital_status = 1
                         ORDER BY fecha_cuota ASC

							IF dSumAbonosAux > 0 THEN
                                IF dSumAbonosAux > (dCapDebeAux- dCapPagAux) THEN
                                    LET dSumAbonosAux = dSumAbonosAux - (dCapDebeAux - dCapPagAux);
                                    LET dAbonoCap = dCapDebeAux;
                                ELIF dSumAbonosAux = (dCapDebeAux- dCapPagAux) THEN
                                    LET dAbonoCap = dCapDebeAux;
                                    LET dSumAbonosAux = 0;
                                ELIF  dSumAbonosAux < (dCapDebeAux- dCapPagAux) THEN
                                    LET dAbonoCap =  dSumAbonosAux + dCapPagAux;
                                    LET dSumAbonosAux = 0;
                                END IF;

                                UPDATE "informix".sd_amortiza_credito
                                   SET capital_pagado = dAbonoCap,
									   capital_status = CASE WHEN capital_pagado >= capital_debe AND interes_pagado >= interes_debe AND iva_pagado >= iva_debe AND mora_sdo_ordi_pag >= mora_sdo_ordi + mora_provi_ordi AND mora_sdo_cope_pag >= mora_sdo_cope + mora_provi_cope AND capital_status <> '1' THEN '5' ELSE capital_status END
                                 WHERE empresa = pEmpresa
                                   AND num_Credito = pNumCred
                                   AND fecha_cuota = dtFechaCuotaAux;
						    END IF;
                     END FOREACH;
                     IF dSdoNuevo <=0 THEN
                         FOREACH
                            SELECT fecha_cuota, capital_debe, capital_pagado
                              INTO dtFechaCuotaAux, dCapDebeAux, dCapPagAux
                              FROM "informix".sd_amortiza_credito
                             WHERE empresa      = pEmpresa
                               AND num_credito  = pNumCred
                               AND fecha_cuota <= dtFechaComparacion
                               AND capital_status NOT IN ("5","7", "2")
                             ORDER BY fecha_cuota ASC

                             UPDATE "informix".sd_amortiza_credito
                                SET capital_pagado = dCapDebeAux,
								    capital_status = CASE WHEN capital_pagado >= capital_debe AND interes_pagado >= interes_debe AND iva_pagado >= iva_debe AND mora_sdo_ordi_pag >= mora_sdo_ordi + mora_provi_ordi AND mora_sdo_cope_pag >= mora_sdo_cope + mora_provi_cope AND capital_status <> '1' THEN '5' ELSE capital_status END
                              WHERE empresa = pEmpresa
                                AND num_Credito = pNumCred
                                AND fecha_cuota = dtFechaCuotaAux;
                       END FOREACH;
                   END IF;
 END IF;

  SELECT SUM (capital_debe - capital_pagado)
                INTO dMtoCapAux
                FROM "informix".sd_amortiza_credito
               WHERE empresa     = pEmpresa
                 AND num_credito = pNumCred
                 AND capital_status  in ('2','7','1');
           UPDATE "informix".sd_maesdos
                     SET sdo_capital = dSdoNuevo,
					 sdo_cap_insoluto = NVL(dSdoNuevo,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0),
                     monto_financiado =  dMtoCapAux
                   WHERE empresa= pEmpresa
                    AND num_credito= pNumCred;
	ELSE
	    LET cCodRet = '000002';
		LET cMensajeRet = 'El saldo en capital vigente se modificó en línea no es posible actualizar';
        ROLLBACK WORK;
		RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	END IF;
ELIF ptipoSaldo= "02" THEN  -- Capital Transitorio
       LET cSdoAfectado= 'monto_vencido';
       LET dMtoActual= dMtoCapTrans;
       LET dSdoNuevo= dMtoCapTrans + dSumMtosActualizar;

	IF dMtoActual = pMontoActual THEN

                SELECT MAX(fecha_cuota)
                INTO dtFechaCuotaAux
                FROM "informix".sd_amortiza_credito
               WHERE empresa     = pEmpresa
                 AND num_credito = pNumCred
                 AND fecha_cuota <= dtFechaComparacion
				 AND capital_status = '7'; -- IN ("2","7"); roque

                IF dSdoNuevo > dMtoActual THEN
                    IF dtFechaCuotaAux IS NULL THEN
                        SELECT MAX(fecha_cuota)
                          INTO dtFechaCuotaAux
                          FROM "informix".sd_amortiza_credito
                         WHERE empresa     = pEmpresa
                           AND num_credito = pNumCred
                           AND fecha_cuota <= dtFechaComparacion
            			   AND capital_status = 5;
                    END IF;
                    UPDATE "informix".sd_amortiza_credito
                       SET capital_debe = capital_debe + dSumCargos
                     WHERE empresa        = pEmpresa
                       AND num_credito    = pNumCred
                       AND fecha_cuota = dtFechaCuotaAux;

                       UPDATE "informix".sd_amortiza_credito
                       SET capital_status = CASE WHEN capital_pagado <= capital_debe THEN '7' ELSE capital_status END
                     WHERE empresa        = pEmpresa
                       AND num_credito    = pNumCred
                       AND fecha_cuota = dtFechaCuotaAux;
                 ELSE
                    UPDATE "informix".sd_amortiza_credito
                       SET capital_pagado = CASE WHEN (capital_pagado + dSumAbonos) >= capital_debe THEN capital_debe ELSE capital_pagado + dSumAbonos END
                     WHERE empresa = pEmpresa
                       AND num_credito = pNumCred
                       AND fecha_cuota = CASE WHEN NVL(dtFechaCuotaAux,DATE(1)) > DATE(1) THEN dtFechaCuotaAux ELSE dtFechaComparacion END;

					UPDATE "informix".sd_amortiza_credito
                       SET capital_status = CASE WHEN capital_pagado >= capital_debe AND interes_pagado >= interes_debe AND iva_pagado >= iva_debe AND mora_sdo_ordi_pag >= mora_sdo_ordi + mora_provi_ordi AND mora_sdo_cope_pag >= mora_sdo_cope + mora_provi_cope AND capital_status <> '1' THEN '5' ELSE capital_status END
                     WHERE empresa        = pEmpresa
                       AND num_credito    = pNumCred
                       AND fecha_cuota = CASE WHEN NVL(dtFechaCuotaAux,DATE(1)) > DATE(1) THEN dtFechaCuotaAux ELSE dtFechaComparacion END;
                 END IF;
  SELECT SUM (capital_debe - capital_pagado)
                INTO dMtoCapAux
                FROM "informix".sd_amortiza_credito
               WHERE empresa     = pEmpresa
                 AND num_credito = pNumCred
                 AND capital_status  in ('2','7','1');

            UPDATE "informix".sd_maesdos
                 SET monto_vencido = dSdoNuevo,
				     sdo_cap_insoluto = NVL(sdo_capital,0) + NVL(dSdoNuevo,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0),
					 monto_financiado =  dMtoCapAux
               WHERE empresa= pEmpresa
                 AND num_credito= pNumCred;
     ELSE
	    LET cCodRet = '000002';
		LET cMensajeRet = 'El saldo en capital transitorio se modificó en línea no es posible actualizar';
        ROLLBACK WORK;
		RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	END IF;
ELIF  pTipoSaldo= "03" THEN -- Capital Vencido
       LET cSdoAfectado= 'mto_venc_trasp';
       LET dMtoActual= dMtoCapVdo;
       LET dSdoNuevo= dMtoCapVdo + dSumMtosActualizar;

IF dMtoActual = pMontoActual THEN
             UPDATE "informix".sd_maesdos
               SET mto_venc_trasp = dSdoNuevo,
				   sdo_cap_insoluto = NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(dSdoNuevo,0) + NVL(cap_tras_no_venci,0)				   
				 --monto_financiado =  dMtoCapAux
             WHERE empresa= pEmpresa
               AND num_credito= pNumCred;

 	IF dSdoNuevo <= dMtoActual THEN --abono
					LET dSumAbonosAux = dSumAbonos;
                    FOREACH
                        SELECT fecha_cuota, capital_debe, capital_pagado
                          INTO dtFechaCuotaAux, dCapDebeAux, dCapPagAux
                          FROM "informix".sd_amortiza_credito
                         WHERE empresa      = pEmpresa
                           AND num_credito  = pNumCred
                           AND fecha_cuota <= dtFechaComparacion
                           AND capital_status = '2' -- IN ('2','7') roque
                         ORDER BY fecha_cuota ASC

					IF dSumAbonosAux > 0 THEN
                                IF dSumAbonosAux > (dCapDebeAux- dCapPagAux) THEN
                                    LET dSumAbonosAux = dSumAbonosAux - (dCapDebeAux - dCapPagAux);
                                    LET dAbonoCap = dCapDebeAux;
                                ELIF dSumAbonosAux = (dCapDebeAux- dCapPagAux) THEN
                                    LET dAbonoCap = dCapDebeAux;
                                    LET dSumAbonosAux = 0;
                                ELIF  dSumAbonosAux < (dCapDebeAux- dCapPagAux) THEN
                                    LET dAbonoCap =  dSumAbonosAux + dCapPagAux;
                                    LET dSumAbonosAux = 0;
                                END IF;

                                UPDATE "informix".sd_amortiza_credito
                                   SET capital_pagado = dAbonoCap,
									   capital_status = CASE WHEN capital_pagado >= capital_debe AND interes_pagado >= interes_debe AND iva_pagado >= iva_debe AND mora_sdo_ordi_pag >= mora_sdo_ordi + mora_provi_ordi AND mora_sdo_cope_pag >= mora_sdo_cope + mora_provi_cope AND capital_status <> '1' THEN '5' ELSE capital_status END
                                 WHERE empresa = pEmpresa
                                   AND num_Credito = pNumCred
                                   AND fecha_cuota = dtFechaCuotaAux;
						    END IF;
                     END FOREACH;
            ELSE
         SELECT MAX(fecha_cuota)
                INTO dtFechaCuotaAux
                FROM "informix".sd_amortiza_credito
               WHERE empresa     = pEmpresa
                 AND num_credito = pNumCred
                 AND fecha_cuota <= dtFechaComparacion
				 AND capital_status = ("2");

                 IF dtFechaCuotaAux IS NULL THEN
                    SELECT MAX(fecha_cuota)
                      INTO dtFechaCuotaAux
                      FROM "informix".sd_amortiza_credito
                     WHERE empresa     = pEmpresa
                       AND num_credito = pNumCred
                       AND fecha_cuota <= dtFechaComparacion
                       AND capital_status = "7";

                         IF dtFechaCuotaAux IS NULL THEN
                            SELECT MAX(fecha_cuota)
                              INTO dtFechaCuotaAux
                              FROM "informix".sd_amortiza_credito
                             WHERE empresa     = pEmpresa
                               AND num_credito = pNumCred
                               AND fecha_cuota <= dtFechaComparacion
                               AND capital_status = "5";
                         END IF;
                 END IF;

                UPDATE "informix".sd_amortiza_credito
                   SET capital_debe = capital_debe + dSumCargos
                 WHERE empresa        = pEmpresa
                   AND num_credito    = pNumCred
                   AND fecha_cuota = dtFechaCuotaAux;

                   UPDATE "informix".sd_amortiza_credito
                   SET capital_status = CASE WHEN capital_pagado <= capital_debe THEN '2' ELSE capital_status END
                 WHERE empresa        = pEmpresa
                   AND num_credito    = pNumCred
                   AND fecha_cuota = dtFechaCuotaAux;
			END IF;
              SELECT SUM (capital_debe - capital_pagado)
                INTO dMtoCapAux
                FROM "informix".sd_amortiza_credito
               WHERE empresa     = pEmpresa
                 AND num_credito = pNumCred
                 AND capital_status  in ('2','7','1');
            --    AND fecha_cuota = dtFechaComparacion;
               UPDATE "informix".sd_maesdos
               SET  monto_financiado =  dMtoCapAux
             WHERE empresa= pEmpresa
               AND num_credito= pNumCred;

	ELSE
	    LET cCodRet = '000002';
		LET cMensajeRet = 'El saldo en capital vencido se modificó en línea no es posible actualizar';
        ROLLBACK WORK;
		RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	END IF;
ELIF pTipoSaldo= "04" THEN -- Capital Vencido No Exigible
       LET cSdoAfectado= 'cap_tras_no_venci';
       LET dMtoActual= dMtoVdoNoExig;
       LET dSdoNuevo= dMtoVdoNoExig + dSumMtosActualizar;
	    IF dMtoActual = pMontoActual THEN
		    UPDATE "informix".sd_maesdos
		       SET cap_tras_no_venci= dSdoNuevo,
				   sdo_cap_insoluto = NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(dSdoNuevo,0)
		     WHERE empresa= pEmpresa
		       AND num_credito= pNumCred;
			   	   IF dSdoNuevo <= dMtoActual THEN
					LET dSumAbonosAux = dSumAbonos;
                   { FOREACH
                        SELECT fecha_cuota, capital_debe, capital_pagado
                          INTO dtFechaCuotaAux, dCapDebeAux, dCapPagAux
                          FROM "informix".sd_amortiza_credito
                         WHERE empresa      = pEmpresa
                           AND num_credito  = pNumCred
                           AND fecha_cuota <= dtFechaComparacion
                           AND capital_status IN ('2','7')
                         ORDER BY fecha_cuota ASC

							IF dSumAbonosAux > 0 THEN
                                IF dSumAbonosAux > (dCapDebeAux- dCapPagAux) THEN
                                    LET dSumAbonosAux = dSumAbonosAux - (dCapDebeAux - dCapPagAux);
                                    LET dAbonoCap = dCapDebeAux;
                                ELIF dSumAbonosAux = (dCapDebeAux- dCapPagAux) THEN
                                    LET dAbonoCap = dCapDebeAux;
                                    LET dSumAbonosAux = 0;
                                ELIF  dSumAbonosAux < (dCapDebeAux- dCapPagAux) THEN
                                    LET dAbonoCap =  dSumAbonosAux + dCapPagAux;
                                    LET dSumAbonosAux = 0;
                                END IF;

                                UPDATE "informix".sd_amortiza_credito
                                   SET capital_pagado = dAbonoCap
                                 WHERE empresa = pEmpresa
                                   AND num_Credito = pNumCred
                                   AND fecha_cuota = dtFechaCuotaAux;
								   UPDATE "informix".sd_amortiza_credito
                                   SET capital_status = CASE WHEN capital_pagado >= capital_debe AND interes_pagado >= interes_debe AND iva_pagado >= iva_debe AND mora_sdo_ordi_pag >= mora_sdo_ordi + mora_provi_ordi AND mora_sdo_cope_pag >= mora_sdo_cope + mora_provi_cope AND capital_status <> '1' THEN '5' ELSE capital_status END
                                 WHERE empresa = pEmpresa
                                   AND num_Credito = pNumCred
                                   AND fecha_cuota = dtFechaCuotaAux;
						    END IF;
                     END FOREACH;

					IF dSumAbonosAux > 0 THEN
                        UPDATE "informix".sd_amortiza_credito
                           SET capital_pagado = capital_debe,
						       capital_status = CASE WHEN capital_pagado >= capital_debe AND interes_pagado >= interes_debe AND iva_pagado >= iva_debe AND mora_sdo_ordi_pag >= mora_sdo_ordi + mora_provi_ordi AND mora_sdo_cope_pag >= mora_sdo_cope + mora_provi_cope AND capital_status <> '1' THEN '5' ELSE capital_status END
                         WHERE empresa = pEmpresa
                           AND num_Credito = pNumCred
                           AND fecha_cuota = dtFechaComparacion;
                     END IF;}-- roque
			END IF;
--Se agreaga el cargo al monto financiado
              SELECT (capital_debe - capital_pagado + pAjusteCargo)
                INTO dMtoCapAux
                FROM "informix".sd_amortiza_credito
               WHERE empresa     = pEmpresa
                 AND num_credito = pNumCred
                 AND fecha_cuota = dtFechaComparacion;

                {UPDATE "informix".sd_maesdos
                   SET monto_financiado =   monto_financiado + dSumMtosActualizar --dSdoNuevo + dMtoCapAux
                 WHERE num_credito = pNumCred
                   AND empresa     = pEmpresa;}
		ELSE
            LET cCodRet = '000002';
            LET cMensajeRet = 'El saldo en capital no exigible se modificó en línea no es posible actualizar';
            ROLLBACK WORK;
            RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	    END IF;
ELIF pTipoSaldo= "05" THEN -- Interes Vigente
         SELECT SUM(interes_debe), SUM(interes_pagado)
          INTO dIntVigDebe, dIntVigPagado
          FROM "informix".sd_amortiza_credito
         WHERE empresa = pEmpresa
           AND num_credito = pNumCred
           AND capital_status IN('7', '1')
           AND fecha_cuota <=dtFechaComparacion;
           LET dMtoIntVig = dIntVigDebe - dIntVigPagado;
	   LET dSdoNuevo= pMontoActual + dSumMtosActualizar;
    IF dMtoIntVig = pMontoActual THEN
             LET cSdoAfectado = 'sdo_no_exig';
                UPDATE bdicred:sd_Maesdos
                   SET sdo_no_exig = CASE WHEN sdo_no_exig = dMtoIntVig THEN dSdoNuevo ELSE  dMtoIntVig + dSdoNuevo END ----checar
                 WHERE empresa = pEmpresa
                   AND num_credito = pNumCred;
                   IF dSumMtosActualizar = 0 THEN
                       UPDATE bdicred:sd_Maesdos
                          SET sdo_no_exig = int_tra_no_exig,
                              int_tra_no_exig =dSumMtosActualizar
                        WHERE empresa = pEmpresa
                          AND num_credito = pNumCred
                          AND sdo_no_exig = 0;
			       END IF;
                   IF dSdoNuevo > pMontoActual THEN
                        UPDATE "informix".sd_amortiza_credito
                           SET interes_debe = interes_debe  + dSumCargos
                         WHERE empresa        = pEmpresa
                           AND num_credito    = pNumCred
                           AND fecha_cuota    = dtFechaComparacion; -- - 1 units month; -------
                   ELSE
                        UPDATE "informix".sd_amortiza_credito
                           SET interes_pagado = CASE WHEN dSdoNuevo = pMontoActual THEN interes_debe ELSE interes_pagado + dSumAbonos END
                         WHERE empresa = pEmpresa
                           AND num_credito = pNumCred
                           AND fecha_cuota = dtFechaComparacion;
                   END IF;
    	ELSE
            LET cCodRet = '000002';
            LET cMensajeRet = 'El saldo en interes vigente se modificó en línea no es posible actualizar';
            ROLLBACK WORK;
            RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	    END IF;
ELIF pTipoSaldo= "06" THEN -- Iva de Interes Vigente
        SELECT iva_debe, iva_pagado
          INTO dIvaIntVigDebe, dIvaIntVdoPagado
          FROM "informix".sd_amortiza_credito
         WHERE empresa = pEmpresa
           AND num_credito = pNumCred
           AND capital_status= '1'
           AND fecha_cuota = dtFechaComparacion;

		   LET dSumIvaIntVig= (dIvaIntVigDebe - dIvaIntVdoPagado);
		   LET dMtoActual= dSumIvaIntVig;

		IF  dMtoActual = pMontoActual  THEN
		   IF pIvaInteresVigente > dMtoActual THEN
		            LET cSdoAfectado = 'iva_debe';
					LET dSdoNuevo = pIvaInteresVigente - dMtoActual;
				    UPDATE sd_amortiza_credito
				       SET iva_debe = iva_debe + dSdoNuevo
			         WHERE empresa = pEmpresa
				       AND num_credito = pNumCred
				       AND fecha_cuota =  dtFechaComparacion; -- - 1 units month;
			ELSE
		            LET cSdoAfectado = 'iva_pagado';
					LET dSdoNuevo= dMtoActual - pIvaInteresVigente;
					UPDATE sd_amortiza_credito
					   SET iva_pagado = CASE WHEN pIvaInteresVigente=dMtoActual THEN iva_debe ELSE iva_pagado + dSdoNuevo END
					 WHERE empresa = pEmpresa
					   AND num_credito = pNumCred
					   AND fecha_cuota = dtFechaComparacion;
			END IF;
		ELSE
            LET cCodRet = '000002';
            LET cMensajeRet = 'El saldo en iva de interes vigente se modificó en línea no es posible actualizar';
            ROLLBACK WORK;
            RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	    END IF;
ELIF pTipoSaldo= "07" THEN  -- Interes Vencido
       LET cSdoAfectado= 'int_tra_no_exig';
       LET dSdoNuevo= dMtoIntVdo + dSumMtosActualizar;

    SELECT NVL(SUM(b.interes_debe - b.interes_pagado),0)
      INTO dInteresMes
      FROM "informix".sd_amortiza_credito b
     WHERE b.empresa = pEmpresa
       AND b.num_credito = pNumCred
       AND capital_status = '1';

	   IF cStatusCred = "BT" THEN
		  IF dMtoIntVdo - dInteresMes > 0 THEN
             LET dMtoIntVdo = dMtoIntVdo - dInteresMes;
		  ELSE
		     LET dMtoIntVdo = 0;
		  END IF;
	   END IF;
         LET dSdoNuevoAux= dMtoIntVdo + dSumMtosActualizar;
         LET dMtoActual= dMtoIntVdo;
	   IF dMtoIntVdo = pMontoActual OR dMtoIntVdo = dSdoNuevoAux THEN
                   IF dSdoNuevoAux > dMtoActual THEN
                        IF cStatusCred = "BT" THEN
                           LET dSdoNuevoAux = dSdoNuevoAux + dInteresMes;
                        END IF;
                 UPDATE "informix".sd_maesdos
                         SET int_tra_no_exig= dSdoNuevoAux + sdo_no_exig,
                             sdo_no_exig = 0
                       WHERE empresa= pEmpresa
                          AND num_credito= pNumCred;

                          SELECT MAX(fecha_cuota)
                            INTO dtFechaCuotaAux
                            FROM "informix".sd_amortiza_credito
                           WHERE  empresa    = pEmpresa
                             AND  num_credito = pNumCred
                             AND capital_status="2";

                            IF dtFechaCuotaAux IS NULL THEN
                                LET dtFechaCuotaAux = dtFechaComparacion - 1 UNITS MONTH;
                            END IF;

                         UPDATE "informix".sd_amortiza_credito
                            SET interes_debe = interes_debe + dSumCargos,
                                capital_status = CASE WHEN capital_status <>  "2"  THEN "2"  ELSE capital_status END
                          WHERE  empresa    = pEmpresa
                            AND  num_Credito = pNumCred
                            AND fecha_cuota = dtFechaCuotaAux;
                   ELSE
                        UPDATE "informix".sd_maesdos
                           SET int_tra_no_exig = int_tra_no_exig - dSumAbonos
                         WHERE empresa= pEmpresa
                           AND num_credito= pNumCred;

                        IF cStatusCred = "BT" THEN
                            UPDATE "informix".sd_maesdos
                               SET int_tra_no_exig = CASE WHEN int_tra_no_exig <= dInteresMes THEN 0 ELSE int_tra_no_exig END,
                                   sdo_no_exig = CASE WHEN int_tra_no_exig <= dInteresMes THEN  dInteresMes ELSE 0 END
                             WHERE empresa= pEmpresa
                               AND num_credito= pNumCred;
                        END IF;

                        LET dSumAbonosAux = dSumAbonos;
                        FOREACH
                            SELECT fecha_cuota, interes_debe, interes_pagado
                              INTO dtFechaCuotaAux, dIntDebeAux, dIntPagAux
                              FROM "informix".sd_amortiza_credito
                             WHERE empresa      = pEmpresa
                               AND num_credito  = pNumCred
                               AND fecha_cuota <= dtFechaComparacion
                               AND capital_status = '2' --IN ('1','7') roque
                          ORDER BY fecha_cuota ASC

                             IF dSumAbonosAux > 0 then
                                IF dSumAbonosAux > (dIntDebeAux- dIntPagAux) THEN
                                    LET dSumAbonosAux = dSumAbonosAux - (dIntDebeAux - dIntPagAux);
                                    LET dAbonoInt = dIntDebeAux;
                                ELIF dSumAbonosAux = (dIntDebeAux- dIntPagAux) THEN
                                    LET dAbonoInt = dIntDebeAux;
                                    LET dSumAbonosAux = 0;
                                ELIF  dSumAbonosAux < (dIntDebeAux- dIntPagAux) THEN
                                    LET dAbonoInt =  dSumAbonosAux + dIntPagAux;
                                    LET dSumAbonosAux = 0;
                                END IF;
                                UPDATE "informix".sd_amortiza_credito
                                   SET interes_pagado = dAbonoInt
                                 WHERE empresa = pEmpresa
                                   AND num_Credito = pNumCred
                                   AND fecha_cuota = dtFechaCuotaAux;

                             END IF;
                        END FOREACH;
                   END IF;
	   ELSE
           LET cCodRet = '000002';
           LET cMensajeRet = 'El saldo en interes vencido se modificó en línea no es posible actualizar';
           ROLLBACK WORK;
		   RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	   END IF;

ELIF pTipoSaldo= "08" THEN --  Iva de Interes Vencido
   SELECT NVL(SUM(iva_debe - iva_pagado),0)
     INTO dIvaIntVdo
	 FROM "informix".sd_amortiza_credito
	WHERE empresa = pEmpresa
      AND num_credito = pNumCred
	  AND capital_status = "2";  --IN ('2','7');
   SELECT NVL(SUM(b.iva_debe - b.iva_pagado),0)
     INTO dIvaMes
     FROM "informix".sd_amortiza_credito b
    WHERE b.empresa = pEmpresa
      AND b.num_credito = pNumCred
      AND capital_status = '1';

    LET dMtoActual= dIvaIntVdo;
    IF  dIvaIntVdo = pMontoActual THEN
            IF pIvaInteresVencido > dMtoActual THEN  -- Identifica un cargo
                LET cIdMovto = "C";
                LET cSdoAfectado = "iva_debe";
                LET dSdoNuevo = pIvaInteresVencido - dMtoActual;
            ELSE
                LET cIdMovto = "A";
                LET cSdoAfectado = "iva_pagado";
                LET dSdoNuevo = dMtoActual - pIvaInteresVencido ;
            END IF;
            EXECUTE PROCEDURE "informix".sp_actualizaivaintvdo(pEmpresa,pNumCred,pIvaInteresVencido)
                         INTO cCodRet,cMensajeRet;
                           IF cCodRet <> "000000" THEN
                              LET cCodRet = '000001';
                              LET cMensajeRet = 'Ocurrió error al actualizar el IVA DE INTERES VENCIDO';
                              ROLLBACK WORK;
                              RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
                         END IF;
    ELSE
       LET cCodRet = '000002';
       LET cMensajeRet = 'El saldo en iva de interes vencido se modificó en línea no es posible actualizar';
       ROLLBACK WORK;
       RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
    END IF;
ELIF pTipoSaldo = "09" THEN -- Interes Moratorio Base
	   SELECT NVL(SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag),0)
		 INTO dMtoIntMoraOrdi
		 FROM "informix".sd_amortiza_credito
		WHERE empresa = pEmpresa
		  AND num_credito = pNumCred
          AND capital_status IN (2,7);

		  LET dMtoActual= dMtoIntMoraOrdi;
IF 	dMtoActual =  pMontoActual THEN
		FOREACH
			SELECT LIMIT 1 fecha_cuota
			  INTO dtFechaCuotaAux
			  FROM "informix".sd_amortiza_credito
			 WHERE empresa = pEmpresa
			   AND capital_status in  ("2","7")
			   AND num_credito = pNumCred
			   AND fecha_cuota <= dtFecha
		  ORDER BY fecha_cuota ASC
		END FOREACH;

		   IF dSumCargos > 0 THEN
			 UPDATE "informix".sd_amortiza_credito
				SET mora_provi_ordi = mora_provi_ordi + dSumCargos
					--mora_provi_ordi = 0
			  WHERE empresa = pEmpresa
				AND num_credito = pNumCred
				AND fecha_cuota = CASE WHEN NVL(dtFechaCuotaAux,DATE(1)) > DATE(1) THEN dtFechaCuotaAux ELSE dtFechaComparacion END;

			  UPDATE "informix".sd_amortiza_credito
				 SET mora_iva_debe = (mora_provi_ordi + mora_provi_cope) * 0.15, --(mora_sdo_cope + mora_sdo_ordi) * 0.15,
					 mora_iva_pagado = (mora_sdo_cope_pag + mora_sdo_ordi_pag) * 0.15
			   WHERE empresa = pEmpresa
				AND num_credito = pNumCred
				 AND fecha_cuota = CASE WHEN NVL(dtFechaCuotaAux,DATE(1)) > DATE(1) THEN dtFechaCuotaAux ELSE dtFechaComparacion END;

				{UPDATE "informix".sd_maesdos
				   SET sdo_contab_mora = dSumCargos
				 WHERE num_credito = pNumCred;}

				 LET cSdoAfectado= 'mora_sdo_ordi';
				 LET dSdoNuevo= dMtoIntMoraOrdi + dSumCargos;
		   ELSE
				   LET dSumAbonosAux = dSumAbonos;
				   LET cSdoAfectado= 'mora_sdo_ordi_pag';
				   FOREACH
						SELECT fecha_cuota, mora_sdo_ordi, mora_sdo_ordi_pag, mora_provi_ordi --, capital_status
						  INTO dtFechaCuotaAux, dIntMoraOrdiDebeAux, dIntMoraOrdiPagAux, dIntMoraOrdiProviAux --, cBanCapStatus
						  FROM "informix".sd_amortiza_credito
						 WHERE empresa      = pEmpresa
						   AND num_credito  = pNumCred
						   AND fecha_cuota <= dtFechaComparacion
						   AND capital_status IN (2,7)
					  ORDER BY fecha_cuota ASC

						   LET dIntMoraOrdiDebeAux = dIntMoraOrdiDebeAux + dIntMoraOrdiProviAux;
						UPDATE "informix".sd_amortiza_credito
						   SET mora_sdo_ordi= dIntMoraOrdiDebeAux,
							   mora_provi_ordi = 0
						 WHERE empresa = pEmpresa
						  AND num_credito = pNumCred
						  AND fecha_cuota = dtFechaCuotaAux;

						IF dSumAbonosAux > 0 then
							IF dSumAbonosAux > (dIntMoraOrdiDebeAux- dIntMoraOrdiPagAux) THEN
								LET dSumAbonosAux = dSumAbonosAux - (dIntMoraOrdiDebeAux - dIntMoraOrdiPagAux);
								LET dAbonoIntMoraOrdiAux = (dIntMoraOrdiDebeAux - dIntMoraOrdiPagAux); --dIntMoraOrdiDebeAux;
							ELIF dSumAbonosAux = (dIntMoraOrdiDebeAux- dIntMoraOrdiPagAux) THEN
								LET dAbonoIntMoraOrdiAux = (dIntMoraOrdiDebeAux - dIntMoraOrdiPagAux); --dIntMoraOrdiDebeAux;
								LET dSumAbonosAux = 0;
							ELIF  dSumAbonosAux < (dIntMoraOrdiDebeAux- dIntMoraOrdiPagAux) THEN
								LET dAbonoIntMoraOrdiAux =  dSumAbonosAux + dIntMoraOrdiPagAux;
								LET dSumAbonosAux = 0;
							END IF;

							UPDATE "informix".sd_amortiza_credito
							   SET mora_sdo_ordi_pag = mora_sdo_ordi_pag + dAbonoIntMoraOrdiAux --,capital_status = cBanCapStatus
							 WHERE empresa = pEmpresa
							   AND num_Credito = pNumCred
							   AND fecha_cuota = dtFechaCuotaAux;

							UPDATE "informix".sd_amortiza_credito
							   SET mora_iva_debe = (mora_sdo_cope + mora_sdo_ordi) * 0.15,
								   mora_iva_pagado = (mora_sdo_cope_pag + mora_sdo_ordi_pag) * 0.15,
								   capital_status = CASE WHEN capital_pagado >= capital_debe AND interes_pagado >= interes_debe AND iva_pagado >= iva_debe AND mora_sdo_ordi_pag >= mora_sdo_ordi + mora_provi_ordi AND mora_sdo_cope_pag >= mora_sdo_cope + mora_provi_cope  AND capital_status <> '1' THEN '5' ELSE capital_status END
							 WHERE  empresa = pEmpresa
							  AND num_credito = pNumCred
							  AND fecha_cuota = dtFechaCuotaAux;

							   LET dSdoNuevo= (dIntMoraOrdiDebeAux - dIntMoraOrdiPagAux) - dSumAbonosAux;
						 END IF;
				   END FOREACH;
		   END IF;

		   SELECT  NVL(SUM(mora_provi_ordi+ mora_provi_cope),0), NVL(SUM(mora_sdo_ordi + mora_sdo_cope),0)
			 INTO dIntMoraOrdiProviAux , dIntMoraOrdiDebeAux
			 FROM "informix".sd_amortiza_credito
			WHERE empresa      = pEmpresa
			  AND num_credito  = pNumCred
			  AND fecha_cuota <= dtFechaComparacion
			  AND capital_status IN ("2","7");

		  UPDATE "informix".sd_maesdos
			SET sdo_moratorio = dIntMoraOrdiDebeAux,
				sdo_contab_mora =  dIntMoraOrdiProviAux
		  WHERE num_credito = pNumCred;
ELSE
   LET cCodRet = '000002';
   LET cMensajeRet = 'El saldo en interes moratorio base se modificó en línea no es posible actualizar';
   ROLLBACK WORK;
   RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
END IF;
ELIF pTipoSaldo = "10" THEN  -- Interes Moratorio Copete
      SELECT NVL(SUM(mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag),0)
	    INTO dMtoIntMoraCope
	    FROM "informix".sd_amortiza_credito
	   WHERE empresa = pEmpresa
		 AND num_credito = pNumCred;

    	 LET dMtoActual = dMtoIntMoraCope;

       IF dMtoIntMoraCope = pMontoActual THEN
		    FOREACH
			    SELECT LIMIT 1 fecha_cuota
				  INTO dtFechaCuotaAux
		          FROM "informix".sd_amortiza_credito
		         WHERE  empresa = pEmpresa
                 AND num_credito = pNumCred
                 AND capital_status in  ("2","7")
		         AND fecha_cuota <= dtFecha
		      ORDER BY fecha_cuota ASC
			END FOREACH;

			IF dSumCargos > 0 THEN
		         UPDATE "informix".sd_amortiza_credito
		            SET mora_provi_cope = mora_provi_cope + dSumCargos
					    --mora_provi_cope = 0
		          WHERE empresa = pEmpresa
                   AND num_credito = pNumCred
		        	AND fecha_cuota = CASE WHEN NVL(dtFechaCuotaAux,DATE(1)) > DATE(1) THEN dtFechaCuotaAux ELSE dtFechaComparacion END;

                  UPDATE "informix".sd_amortiza_credito
		             SET mora_iva_debe = (mora_provi_ordi + mora_provi_cope) * 0.15, --(mora_sdo_cope + mora_sdo_ordi) * 0.15,
                         mora_iva_pagado = (mora_sdo_cope_pag + mora_sdo_ordi_pag) * 0.15
		           WHERE empresa = pEmpresa
                     AND   num_credito = pNumCred
		            AND fecha_cuota = CASE WHEN NVL(dtFechaCuotaAux,DATE(1)) > DATE(1) THEN dtFechaCuotaAux ELSE dtFechaComparacion END;

					 LET cSdoAfectado= 'mora_sdo_cope';
		             LET dSdoNuevo= dMtoIntMoraCope + dSumCargos;

                     SELECT mora_iva_debe
                       INTO dIvaDebe
                       FROM "informix".sd_amortiza_credito
                      WHERE   empresa = pEmpresa
                       AND num_credito = pNumCred
		               AND fecha_cuota = CASE WHEN NVL(dtFechaCuotaAux,DATE(1)) > DATE(1) THEN dtFechaCuotaAux ELSE dtFechaComparacion END;
			 ELSE
					 LET dSumAbonosAux = dSumAbonos;
				     LET cSdoAfectado= 'mora_sdo_cope_pag';
			  		 FOREACH
                            SELECT fecha_cuota, mora_sdo_cope, mora_sdo_cope_pag, mora_provi_cope
                              INTO dtFechaCuotaAux, dIntMoraCopeDebeAux, dIntMoraCopePagAux, dIntMoraCopeProviAux
                              FROM "informix".sd_amortiza_credito
                             WHERE empresa      = pEmpresa
                               AND num_credito  = pNumCred
                               AND fecha_cuota <= dtFechaComparacion
                               AND capital_status IN (2,7)
                          ORDER BY fecha_cuota ASC

                               LET dIntMoraCopeDebeAux = dIntMoraCopeDebeAux + dIntMoraCopeProviAux;
                            UPDATE "informix".sd_amortiza_credito
		                       SET mora_sdo_cope= dIntMoraCopeDebeAux,
					               mora_provi_cope = 0
                             WHERE  empresa = pEmpresa
                              AND num_credito = pNumCred
		                      AND fecha_cuota = dtFechaCuotaAux;

							IF dSumAbonosAux > 0 then
                                IF dSumAbonosAux > (dIntMoraCopeDebeAux- dIntMoraCopePagAux) THEN
                                    LET dSumAbonosAux = dSumAbonosAux - (dIntMoraCopeDebeAux - dIntMoraCopePagAux);
                                    LET dAbonoIntMoraCopeAux = (dIntMoraCopeDebeAux - dIntMoraCopePagAux);
                                ELIF dSumAbonosAux = (dIntMoraCopeDebeAux- dIntMoraCopePagAux) THEN
                                    LET dAbonoIntMoraCopeAux = (dIntMoraCopeDebeAux - dIntMoraCopePagAux);
                                    LET dSumAbonosAux = 0;
                                ELIF dSumAbonosAux < (dIntMoraCopeDebeAux- dIntMoraCopePagAux) THEN
                                    LET dAbonoIntMoraCopeAux =  dSumAbonosAux+ dIntMoraCopePagAux;
                                    LET dSumAbonosAux = 0;
                                END IF;
                                UPDATE "informix".sd_amortiza_credito
                                   SET mora_sdo_cope_pag = mora_sdo_cope_pag + dAbonoIntMoraCopeAux
                                 WHERE empresa = pEmpresa
                                   AND num_Credito = pNumCred
                                   AND fecha_cuota = dtFechaCuotaAux;

						        UPDATE "informix".sd_amortiza_credito
		                           SET mora_iva_debe = (mora_sdo_cope + mora_sdo_ordi) * 0.15,
                                       mora_iva_pagado = (mora_sdo_cope_pag + mora_sdo_ordi_pag) * 0.15,
									   capital_status = CASE WHEN capital_pagado >= capital_debe AND interes_pagado >= interes_debe AND iva_pagado >= iva_debe AND mora_sdo_ordi_pag >= mora_sdo_ordi + mora_provi_ordi AND mora_sdo_cope_pag >= mora_sdo_cope + mora_provi_cope AND capital_status <> '1' THEN '5' ELSE capital_status END
		                         WHERE empresa = pEmpresa
                                   AND num_credito = pNumCred
		                           AND fecha_cuota = dtFechaCuotaAux;

								   LET dSdoNuevo = (dIntMoraCopeDebeAux - dIntMoraCopeDebeAux) - dSumAbonosAux;
                            END IF;
			  		   END FOREACH;
			 END IF;
            SELECT  NVL(SUM(mora_provi_ordi+ mora_provi_cope),0), NVL(SUM(mora_sdo_ordi + mora_sdo_cope),0)
                 INTO dIntMoraOrdiProviAux , dIntMoraOrdiDebeAux
                 FROM "informix".sd_amortiza_credito
                WHERE empresa      = pEmpresa
                  AND num_credito  = pNumCred
                  AND fecha_cuota <= dtFechaComparacion
                  AND capital_status IN ("2","7");

             UPDATE "informix".sd_maesdos
				SET sdo_moratorio = dIntMoraOrdiDebeAux,
				    sdo_contab_mora =  dIntMoraOrdiProviAux
			  WHERE num_credito = pNumCred;
    ELSE
       LET cCodRet = '000002';
       LET cMensajeRet = 'El saldo en interes moratorio copete se modificó en línea no es posible actualizar';
       ROLLBACK WORK;
       RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	END IF;
END IF;

IF pTipoSaldo = "11" THEN
   LET cSdoAfectado= 'iva_int_mor';
END IF;

LET dMtoActual1 = dMtoActual  - pQuitaAbono;
LET dMtoActual2 = dMtoActual1 - pCastigoAbono;
LET dMtoActual3 = dMtoActual2 - pQuebrantoAbono;
LET dMtoActual4 = dMtoActual3 + pAjusteCargo;
LET dMtoActual5 = dMtoActual4 - pAjusteAbono;
LET dMtoActual6 = dMtoActual5 - pCondonacionAbono;

IF pQuitaAbono > 0 THEN
	SELECT codigo_fun,codigo_ref
	INTO  cCodigoFun,iCodigoRef
	FROM sd_transacc_nvas_func
	WHERE empresa= pEmpresa
	AND tipo_movto = cTpoMovtoQuitaA
	AND tipo_saldo = pTipoSaldo;

  IF cCodigoFun IS NULL OR cCodigoFun = '' THEN
	LET cCodigoFun = '040';
  END IF;

   IF iCodigoRef IS NULL OR iCodigoRef = '' THEN
	 LET iCodigoRef = '99';
   END IF;

   CALL "informix".GENMOV (pEmpresa, pNumCred, cNumProducto,
						   iCodigoRef, cCodigoFun, dtFecha,
						   pQuitaAbono, cDescTipoMovto, cSucursal,
						   cDivisa, "0000")
	  RETURNING cCodRet, cMensajeRet;

   IF cCodRet <> "00000" THEN
	   LET cMensajeRet= "Ocurrió un problema al generar el movimiento(GENMOV) de QUITA-ABONO";
	   ROLLBACK WORK;
	   RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
   ELSE
	   EXECUTE PROCEDURE "informix".sp_GenMovBitacoraMovimientos ( pEmpresa,
																pNumCred,
																cTpoMovtoQuitaA,
																cSdoAfectado,
																dMtoActual,
																pQuitaAbono * -1,
																dMtoActual1,
																pDescripcionMovimiento,
																pClaveEmpleadoAutorizo,
																dtFecha)
					INTO cCodRet,cMensajeRet;
		  IF cCodRet <> "000000" THEN
			 LET cCodRet = '000001';
			 LET cMensajeRet = 'Ocurrió un error al ejecutar el GENERAR bitacora MOVIMIENTO';
			 ROLLBACK WORK;
			 RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
		  END IF;
   END IF;
END IF;
IF pCastigoAbono > 0  THEN
		SELECT codigo_fun,codigo_ref
		INTO  cCodigoFun,iCodigoRef
		FROM sd_transacc_nvas_func
		WHERE empresa= pEmpresa
        AND tipo_movto = cTpoMovtoCatigoA
		AND tipo_saldo = pTipoSaldo;

		  IF cCodigoFun IS NULL OR cCodigoFun = '' THEN
		     LET cCodigoFun = '040';
		   END IF;

           IF iCodigoRef IS NULL OR iCodigoRef = '' THEN
             LET iCodigoRef = '99';
           END IF;

   CALL "informix".GENMOV (pEmpresa,
						   pNumCred,
						   cNumProducto,
						   iCodigoRef,
						   cCodigoFun,
						   dtFecha,
						   pCastigoAbono,
						   cDescTipoMovto,
						   cSucursal,
						   cDivisa,
						   "0000")
	  RETURNING cCodRet, cMensajeRet;

	   IF cCodRet <> "00000" THEN
		   LET cMensajeRet= "Ocurrió un problema al generar el movimiento(GENMOV) de CASTIGO-ABONO";
		   ROLLBACK WORK;
		   RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	   ELSE
			   EXECUTE PROCEDURE "informix".sp_GenMovBitacoraMovimientos ( pEmpresa,
																		pNumCred,
																		cTpoMovtoCatigoA,
																		cSdoAfectado,
																		dMtoActual1,
																		pCastigoAbono * -1,
																		dMtoActual2,
																		pDescripcionMovimiento,
																		pClaveEmpleadoAutorizo,
																		dtFecha)
							INTO cCodRet,cMensajeRet;
			  IF cCodRet <> "000000" THEN
				 LET cCodRet = '000001';
				 LET cMensajeRet = 'Ocurrió un problema al ejecutar el GENERAR bitacora MOVIMIENTO';
				 ROLLBACK WORK;
				 RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
			  END IF;
		END IF;
END IF;
IF pQuebrantoAbono > 0  THEN
	SELECT codigo_fun,codigo_ref
	INTO  cCodigoFun,iCodigoRef
	FROM sd_transacc_nvas_func
	WHERE empresa= pEmpresa
	AND tipo_movto = cTpoMovtoQuebrantoA
	AND tipo_saldo = pTipoSaldo;

	   IF cCodigoFun IS NULL OR cCodigoFun = '' THEN
		   LET cCodigoFun = '040';
		END IF;

	   IF iCodigoRef IS NULL OR iCodigoRef = '' THEN
		 LET iCodigoRef = '99';
	   END IF;

   CALL "informix".GENMOV (pEmpresa, pNumCred, cNumProducto,
						   iCodigoRef, cCodigoFun, dtFecha,
						   pQuebrantoAbono, cDescTipoMovto, cSucursal,
						   cDivisa,"0000")
	  RETURNING cCodRet, cMensajeRet;

	   IF cCodRet <> "00000" THEN
		   LET cMensajeRet= "Ocurrió un problema al generar el movimiento(GENMOV) de QUEBRANTO-ABONO";
		   ROLLBACK WORK;
		   RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	   ELSE
			   EXECUTE PROCEDURE "informix".sp_GenMovBitacoraMovimientos (pEmpresa,
																		  pNumCred,
																		  cTpoMovtoQuebrantoA,
																		  cSdoAfectado,
																		  dMtoActual2,
																		  pQuebrantoAbono * -1,
																		  dMtoActual3,
																		  pDescripcionMovimiento,
																		  pClaveEmpleadoAutorizo,
																		  dtFecha)
							INTO cCodRet,cMensajeRet;
			  IF cCodRet <> "000000" THEN
				 LET cCodRet = '000001';
				 LET cMensajeRet = 'Ocurrió un error al ejecutar el GENERAR bitacora MOVIMIENTO';
				 ROLLBACK WORK;
				 RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
			  END IF;
		END IF;
END IF;
IF pAjusteCargo  > 0 THEN
	SELECT codigo_fun,codigo_ref
	INTO  cCodigoFun,iCodigoRef
	FROM sd_transacc_nvas_func
	WHERE empresa= pEmpresa
	AND tipo_movto = cTpoMovtoAjusteC
	AND tipo_saldo = pTipoSaldo;

	 IF cCodigoFun IS NULL OR cCodigoFun = '' THEN
	   LET cCodigoFun = '040';
	 END IF;

	 IF iCodigoRef IS NULL OR iCodigoRef = '' THEN
	  LET iCodigoRef = '99';
	 END IF;

	 CALL "informix".GENMOV (pEmpresa, pNumCred, cNumProducto,
							 iCodigoRef,cCodigoFun, dtFecha,
						   pAjusteCargo, cDescTipoMovto, cSucursal,
						   cDivisa, "0000")
	  RETURNING cCodRet, cMensajeRet;

		   IF cCodRet <> "00000" THEN
			   LET cMensajeRet= "Ocurrió un problema al generar el movimiento(GENMOV) de AJUSTE-CARGO";
			   ROLLBACK WORK;
			   RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
		   END IF;
		   EXECUTE PROCEDURE "informix".sp_GenMovBitacoraMovimientos ( pEmpresa,
																	pNumCred,
																	cTpoMovtoAjusteC,
																	cSdoAfectado,
																	dMtoActual3,
																	pAjusteCargo,
																	dMtoActual4,
																	pDescripcionMovimiento,
																	pClaveEmpleadoAutorizo,
																	dtFecha)
						INTO cCodRet,cMensajeRet;
		  IF cCodRet <> "000000" THEN
			 LET cCodRet = '000001';
			 LET cMensajeRet = 'Ocurrió un error al ejecutar el GENERAR bitacora MOVIMIENTO';
			 ROLLBACK WORK;
			 RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
		  END IF;
END IF;
IF pAjusteAbono > 0 THEN
		SELECT codigo_fun,codigo_ref
		INTO  cCodigoFun,iCodigoRef
		FROM sd_transacc_nvas_func
		WHERE empresa= pEmpresa
        AND tipo_movto = cTpoMovtoAjusteA
		AND tipo_saldo = pTipoSaldo;

		 IF cCodigoFun IS NULL OR cCodigoFun = '' THEN
			LET cCodigoFun = '040';
         END IF;

		 IF iCodigoRef IS NULL OR iCodigoRef = '' THEN
		    LET iCodigoRef = '99';
		 END IF;
      CALL "informix".GENMOV (pEmpresa, pNumCred, cNumProducto,
                    iCodigoRef, cCodigoFun, dtFecha,
                    pAjusteAbono, cDescTipoMovto, cSucursal,
                    cDivisa, "0000")
          RETURNING cCodRet, cMensajeRet;

           IF cCodRet <> "00000" THEN
               LET cMensajeRet= "Ocurrió un problema al generar el movimiento(GENMOV) de AJUSTE-ABONO";
               ROLLBACK WORK;
               RETURN cCodRet,cMensajeRet,dMtoActual,dSumMtosActualizar, dSdoNuevo, cfolio;
           END IF;
		   EXECUTE PROCEDURE "informix".sp_GenMovBitacoraMovimientos ( pEmpresa,pNumCred,
																	cTpoMovtoAjusteA,cSdoAfectado,
																	dMtoActual4,pAjusteAbono * -1,
																	dMtoActual5,pDescripcionMovimiento,
																	pClaveEmpleadoAutorizo,dtFecha)
		INTO cCodRet,cMensajeRet;

		  IF cCodRet <> "000000" THEN
			 LET cCodRet = '000001';
			 LET cMensajeRet = 'Ocurrió un error al ejecutar el GENERAR bitacora MOVIMIENTO';
             ROLLBACK WORK;
			 RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
		  END IF;
END IF;
IF pCondonacionAbono > 0 THEN
		SELECT codigo_fun,codigo_ref
		INTO  cCodigoFun,iCodigoRef
		FROM sd_transacc_nvas_func
		WHERE empresa= pEmpresa
		AND tipo_movto = cTpoMovtoCondonacionA
		AND tipo_saldo = pTipoSaldo;

	   IF cCodigoFun IS NULL OR cCodigoFun = '' THEN
		   LET cCodigoFun = '040';
	   END IF;

	   IF iCodigoRef IS NULL OR iCodigoRef = '' THEN
		 LET iCodigoRef = '99';
	   END IF;
       CALL "informix".GENMOV (pEmpresa,
                    pNumCred,
                    cNumProducto,
                    iCodigoRef,
                    cCodigoFun,
                    dtFecha,
                    pCondonacionAbono,
                    cDescTipoMovto,
                    cSucursal,
                    cDivisa,
                    "0000")
          RETURNING cCodRet, cMensajeRet;

           IF cCodRet <> "00000" THEN
               LET cMensajeRet= "Ocurrió un problema al generar el movimiento(GENMOV) de CONDONACION-ABONO";
               ROLLBACK WORK;
               RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
           END IF;
		   EXECUTE PROCEDURE "informix".sp_GenMovBitacoraMovimientos ( pEmpresa,
                                                    pNumCred,
                                                    cTpoMovtoCondonacionA,
                                                    cSdoAfectado,
                                                    dMtoActual5,
                                                    pCondonacionAbono * -1,
                                                    dMtoActual6,
                                                    pDescripcionMovimiento,
                                                    pClaveEmpleadoAutorizo,
                                                   dtFecha)
						INTO cCodRet,cMensajeRet;
		  IF cCodRet <> "000000" THEN
			 LET cCodRet = '000001';
			 LET cMensajeRet = 'Ocurrió un error al ejecutar el GENERAR bitacora MOVIMIENTO';
             ROLLBACK WORK;
			 RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
		  END IF;
END IF;
COMMIT WORK;
IF cCodRet <> "00000" THEN
  LET cCodRet = "000000";
  LET cMensajeRet= "Se realizó actualización correctamente";
END IF;
  RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
END;
END PROCEDURE;