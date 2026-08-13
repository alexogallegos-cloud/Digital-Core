CREATE PROCEDURE "informix".sp_credisol_cancel_manual(pempresa CHAR(3))
   RETURNING CHAR(6), CHAR(80);

DEFINE iSqlErr                  INTEGER;
DEFINE iIsamErr                 INTEGER;
DEFINE cErrorInfo               CHAR(100);
DEFINE CodRet                   CHAR(6);
DEFINE Mensaje                  CHAR(80);
DEFINE CSnum_credito,cCredito_promo         CHAR(20);
DEFINE v_total_cap_cs, v_total_mto_cs, v_mto_pag_cs, v_capital_cs, v_interes_cs, v_iva_cs, v_monto_actual, v_monto_int_iva DECIMAL(14,2);
DEFINE cfolio_mov_promo,cfolio_suc_promo    CHAR(16);
DEFINE cCharAux                 CHAR(80);
DEFINE dtDateAux                DATE;
DEFINE dDecAux                  DECIMAL(18,2);
DEFINE iIntAux, itip_promo      INTEGER;
DEFINE dPagoCom,dPagoIvaCom,dSdoAdeudTotal,dIntDevengado,dIvaIntDevengado,vcap_vig,dSdoAdeudTotalAct   DECIMAL(18,2);
DEFINE dtFechaApertura,dtFechaProxPago, dFecha_Hoy      DATE;
DEFINE dPagoMinAct              DECIMAL(18,2);
DEFINE vd_sdo_retenido          DECIMAL(18,2);
DEFINE cSucursal                CHAR(4);

--CREDISOLUCIONES


LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = "";
LET CodRet       = "000000";
LET Mensaje   = "Se realizó el proceso exitosamente";
LET CSnum_credito,cCredito_promo = '','';
LET v_total_cap_cs, v_total_mto_cs, v_mto_pag_cs, v_capital_cs, v_interes_cs, v_iva_cs, v_monto_actual, v_monto_int_iva = 0,0,0,0,0,0,0,0;
LET cfolio_mov_promo,cfolio_suc_promo = '','';
LET cCharAux       = "";
LET dtDateAux      = DATE(1);
LET dDecAux        = 0; LET iIntAux = 0; LET dPagoCom = 0; LET dPagoIvaCom = 0; LET dSdoAdeudTotal = 0; LET dIntDevengado = 0; LET dIvaIntDevengado = 0; LET vcap_vig = 0;
LET dtFechaApertura  = DATE(1); LET dtFechaProxPago = DATE(1); LET dPagoMinAct = 0; LET dSdoAdeudTotalAct = 0;
LET vd_sdo_retenido = 0;    LET dFecha_Hoy = DATE(1);   LET itip_promo = 0;     LET cSucursal = '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
          LET CodRet  = iSqlErr;
          LET Mensaje = cErrorInfo;
       RETURN CodRet,Mensaje;
   END IF;
END EXCEPTION;

    --SET DEBUG FILE TO "/informix/sp_credisoluciones_revol.out";
    --TRACE ON;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        --SET PDQPRIORITY 10;

        SELECT fecha_hoy INTO dFecha_Hoy FROM bdicred:sd_fechas;


        FOREACH WITH HOLD  --FMV 13ago14: Se adiciona with hold, ya que solo cancelaba 1 credisolucion en dia 20.
                SELECT cred.num_credito,a.num_sol_prestamo, a.monto_actual, a.monto_int_iva,a.folio_movto,a.folio_suc, a.num_promo, a.sucursal
                INTO CSnum_credito,cCredito_promo, v_monto_actual, v_monto_int_iva,cfolio_mov_promo,cfolio_suc_promo, itip_promo, cSucursal
                  FROM bdicred:"informix".sd_promocion_credito a
                     --  bdicred:"informix".sd_maesdos dos
                     --  bdicred:"informix".sd_maecred cred
				  INNER JOIN bdicred:sd_maecred cred on (a.num_credito = cred.num_credito)
				  INNER JOIN bdicred:sd_maesdos dos on (cred.num_credito = dos.num_credito AND (dos.monto_vencido + dos.mto_venc_trasp) > 0)
                 WHERE a.empresa = '001'
                   AND a.sistema = '06'
                   AND a.num_credito = cred.num_credito
                   AND a.status = 2
                   AND cred.status_cred in ('BA','BT','E1','E2','E3')
				   --AND cred.monto_financiado > 0              -- cancele los creditos que no pagaron y caeran a transitorio (BA)
                   --AND b.status_cred = 'AA'  FMV 13ago14: Se modifica estatus para que filtre estatus transitorios al dia del corte 20
                                                        -- antes del cierre de tarjeta
        
                --SE OBTIENE EL ADEUDO DEL CLIENTE DE CREDISOLUCIONES HASTA ESE MOMENTO
                EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(pEmpresa,cCredito_promo)
                 INTO CodRet,Mensaje,cCharAux,cCharAux,dtFechaApertura,dtFechaProxPago,dPagoMinAct,dtDateAux,
                      iIntAux,iIntAux,dDecAux,dDecAux,dDecAux,dDecAux,vcap_vig,dDecAux,dDecAux,dDecAux,
                      dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
                      dDecAux,dDecAux,dDecAux,dDecAux,dSdoAdeudTotalAct,dIntDevengado,dIvaIntDevengado,
                      dDecAux,dDecAux,cCharAux,iIntAux,cCharAux,cCharAux,cCharAux,cCharAux,iIntAux,
                      cCharAux,cCharAux,iIntAux,cCharAux;
                BEGIN WORK;
                    IF  dSdoAdeudTotalAct > 0 THEN
                --SE REALIZA EL PAGO POR EL MONTO CORRESPONDIENTE AL MES CORRIENTE DE CREDISOLUCIONES
                            CALL "informix".sp_cargo_abono_palzo(pEmpresa,cCredito_promo,'',dSdoAdeudTotalAct,USER,'9290','4210',3,'')
                            RETURNING CodRet, Mensaje;

                            -- CodRet = '-268' Mensaje = 'c92357113.u1346_6799' / Mensaje = 'informix.u263_1226')
                            IF (CodRet <> "000000") THEN
                                ROLLBACK WORK;
                                CONTINUE FOREACH;
                                --RETURN CodRet,Mensaje;
                            ELSE
                                LET CodRet = "000000";
                                LET Mensaje ="Se realizó el proceso de pago anticipado total exitosamente, producto 6900";
                            END IF;

                          IF CodRet = "000000" THEN  
                            SELECT sdo_retenido
                              INTO vd_sdo_retenido
                              FROM bdicred:sd_maesdos
                             WHERE empresa = '001'
                               AND num_credito = CSnum_credito;                     
                          
                              IF NVL(vd_sdo_retenido,0) >= (v_monto_actual + v_monto_int_iva) THEN
                                UPDATE bdicred:sd_maesdos
                                   SET sdo_retenido = sdo_retenido - (v_monto_actual + v_capital_cs)
                                 WHERE empresa = '001' 
                                   AND num_credito = CSnum_credito;

                                UPDATE bdicred:sd_promocion_credito
                                   SET status = 7
                                 WHERE empresa = '001'
                                   AND num_sol_prestamo = cCredito_promo;

                                -- Inserta en la tabla, el registro de la cancelacion con motivo "Cancelacion automatica"
                                INSERT INTO bdicred:sd_cancela_credisol
                                (empresa, num_credito, folio_movto, fecha_cancela, motivo_de_cancelacion, tipo_promo, sucursal, fecha_insert, user_insert)
                                VALUES('001',cCredito_promo,cfolio_mov_promo,dFecha_Hoy,'CANCELACION AUTOMATICA',itip_promo,cSucursal,TODAY,USER);

                                UPDATE bdicred:sd_maeretenido
                                   SET estatus = 'S'
                                 WHERE empresa = '001'
                                   AND num_credito = CSnum_credito
                                   AND folio_suc = cfolio_mov_promo;

                                UPDATE bdicred:sd_maeretenido
                                   SET estatus = 'S'
                                 WHERE empresa = '001'
                                   AND num_credito = CSnum_credito
                                   AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo;

                              END IF; --NVL(vd_sdo_retenido,0) >= (v_monto_actual + v_monto_int_iva) THEN
                          END IF; -- IF CodRet = "000" THEN 

                            IF dIvaIntDevengado <> 0 THEN
                                CALL "informix".sp_cargo_abono_palzo(pEmpresa,CSnum_credito,'',dIvaIntDevengado,USER,'9290','4202',1,'')
                                RETURNING CodRet, Mensaje;

                                IF (CodRet <> "000000") THEN
                                    ROLLBACK WORK;
                                    CONTINUE FOREACH;
                                    --RETURN CodRet,Mensaje;
                                ELSE
                                    LET CodRet = "000000";
                                    LET Mensaje ="Se realizó el proceso de Cargo Iva a TDC exitosamente, producto 6900";
                                END IF;
                            END IF;

                            IF dIntDevengado <> 0 THEN
                                CALL "informix".sp_cargo_abono_palzo(pEmpresa,CSnum_credito,'',dIntDevengado,USER,'9290','4201',1,'')
                                  RETURNING CodRet, Mensaje;

                                  IF (CodRet <> "000000") THEN
                                     ROLLBACK WORK;
                                     CONTINUE FOREACH;
                                    -- RETURN CodRet,Mensaje;
                                  ELSE
                                     LET CodRet = "000000";
                                     LET Mensaje ="Se realizó el proceso de Cargo Ints.Deven a TDC exitosamente, producto 6900";
                                  END IF;
                            END IF;

                            IF vcap_vig <> 0 THEN
                                CALL "informix".sp_cargo_abono_palzo(pEmpresa,CSnum_credito,'',vcap_vig,USER,'9290','4200',1,'')
                                  RETURNING CodRet, Mensaje;

                                  IF (CodRet <> "000000") THEN
                                       ROLLBACK WORK;
                                       CONTINUE FOREACH;
                                       --RETURN CodRet,Mensaje;
                                  ELSE
                                     LET CodRet = "000000";
                                     LET Mensaje ="Se realizó el proceso de Cargo Cap.Vig. TDC exitosamente, producto 6900";
                                  END IF;
                            END IF;
                    END IF;
                COMMIT WORK;
            CONTINUE FOREACH;
                    LET dSdoAdeudTotalAct = 0;
                    LET vcap_vig = 0;
                    LET dIntDevengado = 0;
                    LET dIvaIntDevengado = 0;

        END FOREACH;

	RETURN CodRet,Mensaje;

END;
END PROCEDURE;