CREATE PROCEDURE "informix".sp_ambientar_indicador_cred(fecha_ejecucion DATE, vNumCredito char(12)) 

RETURNING  CHAR(6) AS Cod_Ret,  CHAR(80) AS Mens_Ret;

-- Autor: Aldo E Hernandez
-- Fecha: 25/05/2021
-- Ambientacion para la tabla bdicred:sd_indicador_cred_crd para indicadores de impagos consecutivos

DEFINE sql_err          INTEGER;
DEFINE isam_err         INTEGER;
DEFINE error_info       CHAR(80);
DEFINE cEmpresa         CHAR(3);
DEFINE pEmpresa         CHAR(3);
DEFINE cProceso         CHAR(4);
DEFINE cCod_ret         CHAR(6);
DEFINE cCod_retBit      CHAR(6);
DEFINE cMensajeRet      CHAR(125); 
DEFINE vnum_credito     CHAR(12);
DEFINE vnum_producto    CHAR(4);
DEFINE vcredito_externo  CHAR(12);
DEFINE vimpagos_consec_h      DECIMAL(16,2);
DEFINE vimpagos_consec_h_aux  DECIMAL(16,2);
DEFINE vimpagos_consec_ch      DECIMAL(16,2);
DEFINE fecha_mov    DATE;
DEFINE max_fecha_mov    DATE;
DEFINE max_fecha_mov2    DATE;
DEFINE fecha_hoy        DATE;
DEFINE fecha_mes_ant    DATE;
DEFINE vdia_mes       INTEGER;
DEFINE int_cap2mes_tdc  DECIMAL(16,2);
DEFINE contador_commit  INTEGER;
DEFINE vdia_corte  INTEGER;
DEFINE total_indicador  DECIMAL(16,2);
DEFINE estatusCred      CHAR(2);
DEFINE etapaCred      CHAR(2);
DEFINE etapaCred_aux      INTEGER;
DEFINE vdias_atraso_h  INTEGER;
DEFINE vdias_atraso_ch  INTEGER;
DEFINE vdias_atraso_ind INTEGER;
DEFINE mto_fin_ven_TraspCred    DECIMAL(16,2);
DEFINE UltimaFechaVigente   DATE;
DEFINE UltimaFechaVigente_old   DATE;
DEFINE MaximaFechaVigente   DATE;
DEFINE UltimaFechaHist   DATE;
DEFINE vfecha_apertura   DATE;
DEFINE vfecha_vencim     DATE;
DEFINE vfecha_cuota      DATE;

DEFINE dCapVig          DECIMAL(16,2);
DEFINE dSdoActCap       DECIMAL(16,2);
DEFINE dCapTrans        DECIMAL(16,2);
DEFINE dCapVdoExig      DECIMAL(16,2);
DEFINE dCapVdoNoExig    DECIMAL(16,2);
DEFINE dIntVig          DECIMAL(16,2);
DEFINE dIvaIntVig       DECIMAL(16,2);
DEFINE dIntVdo          DECIMAL(16,2);
DEFINE dIntMoratorio    DECIMAL(16,2);
DEFINE dIvaIntVdo       DECIMAL(16,2);
DEFINE dIntMoratorio_d  DECIMAL(16,2);
DEFINE dIvaIntMoratorio DECIMAL(16,2);
DEFINE Folio            CHAR(16);
DEFINE vdivisa          CHAR(3);
DEFINE vsucursal        CHAR(4);
DEFINE dIvaSuc           DECIMAL(5,3);
DEFINE cred_ini,cred_fin  		 CHAR(20);

--Inicializacion de variables
LET sql_err         = 0;
LET isam_err        = 0;
LET error_info      = "";
LET cEmpresa        = "";
LET pEmpresa        = "";
LET cProceso        = '0024';
LET cCod_Ret        = '000';
LET cCod_retBit     = '000';
LET cMensajeRet     = 'PROCESO EXITOSO';
LET vnum_credito    = "";
LET vnum_producto   = "";
LET vcredito_externo = "";
LET vimpagos_consec_h     = 0;
LET vimpagos_consec_h_aux = 0;
LET vimpagos_consec_ch     = 0;
LET fecha_mov   = DATE(0);
LET max_fecha_mov   = DATE(0);
LET max_fecha_mov2  = DATE(0);
LET fecha_hoy       = DATE(0);
LET fecha_mes_ant   = DATE(0);
LET vdia_mes        = 0;
LET int_cap2mes_tdc = 0;
LET contador_commit = 0;
LET vdia_corte      = 0;
LET total_indicador = 0;
LET estatusCred     = '';
LET etapaCred       = '';
LET etapaCred_aux       = 0;
LET vdias_atraso_h   = 0;
LET vdias_atraso_ch   = 0;
LET vdias_atraso_ind    = 0;
LET mto_fin_ven_TraspCred = 0;
LET UltimaFechaVigente = DATE(0);
LET UltimaFechaVigente_old = DATE(0);
LET MaximaFechaVigente = DATE(0);
LET UltimaFechaHist = DATE(0);
LET vfecha_apertura   = DATE(0);
LET vfecha_vencim     = DATE(0);
LET vfecha_cuota      = DATE(0);

LET dCapVig          =0;
LET dSdoActCap       =0;
LET dCapTrans        =0;
LET dCapVdoExig      =0;
LET dCapVdoNoExig    =0;
LET dIntVig          =0;
LET dIvaIntVig       =0;
LET dIntVdo          =0;
LET dIntMoratorio    =0;
LET dIvaIntVdo       =0;
LET dIntMoratorio_d  =0;
LET dIvaIntMoratorio =0;
LET Folio            =0;
LET vdivisa          ='';
LET vsucursal        ='';
LET dIvaSuc          =0;
LET cred_ini         = '';      
LET cred_fin         = '';

--SET DEBUG FILE TO "/ifxsif01/aldo/etapas/sp_ambientar_indicador_cred.out";
--TRACE ON;

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensajeRet = error_info;        
        RETURN cCod_ret,cMensajeRet;
    END EXCEPTION;

    --Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3; 

    LET pEmpresa = '001';
    LET fecha_mov =mdy(01,02,2021); --FECHA DE MOVIMIENTO DE MIGRACION EN movdia_ifrs

    
    select a.num_credito, a.num_producto, a.status_cred,a.divisa,a.sucursal,b.dia_corte,c.impagos_consec_h,c.dias_atraso,d.mto_fin_ven_Trasp,a.fecha_apertura,a.fecha_vencim,
        NVL(d.sdo_capital,0) CapVig, NVL(d.sdo_cap_insoluto,0) CapAct, NVL(d.monto_vencido,0) CapTrans, NVL(d.mto_venc_trasp,0) CapVdoExig, NVL(d.cap_tras_no_venci,0) CapVdoNoExig
        FROM sd_maecred a,sd_maecredanexo b, sd_indicador_cred c, sd_maesdos d
         WHERE a.num_credito   = b.num_credito 
           AND c.num_credito   = a.num_credito
           AND d.num_credito   = a.num_credito
           AND a.empresa       = b.empresa
           AND c.empresa       = a.empresa
           AND d.empresa       = a.empresa
           AND a.empresa       = pEmpresa
           AND a.num_credito = vNumCredito
        into temp univ_ree with no log;         
            
    FOREACH WITH HOLD
        select *
        INTO vnum_credito, vnum_producto, estatusCred, vdivisa, vsucursal, vdia_corte, vimpagos_consec_h,vdias_atraso_ind,mto_fin_ven_TraspCred,vfecha_apertura,vfecha_vencim,
            dCapVig, dSdoActCap, dCapTrans, dCapVdoExig, dCapVdoNoExig
        FROM univ_ree
            

            LET dIntVig          =0;
            LET dIvaIntVig       =0;
            LET dIntVdo          =0;
            LET dIntMoratorio    =0;
            LET dIvaIntVdo       =0;
            LET dIntMoratorio_d  =0;
            LET dIvaIntMoratorio =0;
            LET dIvaSuc          =0;

            SELECT USER||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(current,3,2)||SUBSTR(CURRENT,12,2)||substr(current,15,2)||SUBSTR(current,18,2) INTO Folio FROM dual;


            IF (estatusCred = "AA" ) THEN
                LET vimpagos_consec_h = 0;
                LET vdias_atraso_h=0;
                LET etapaCred='E1';

            ELSE

                SELECT max(fecha)
                    INTO UltimaFechaHist
                    FROM bdicred:sd_maesdoshist 
                    WHERE empresa = pEmpresa
                        AND num_credito = vnum_credito
                        AND fecha <= fecha_ejecucion;

                SELECT max(fecha)
                    INTO UltimaFechaVigente
                    FROM bdicred:sd_maesdoshist 
                    WHERE empresa = pEmpresa
                        AND num_credito = vnum_credito
                        AND monto_vencido > 0 
                        AND mto_venc_trasp = 0
                        AND fecha <= fecha_ejecucion;

                SELECT max(fecha)
                    INTO MaximaFechaVigente
                    FROM bdicred:sd_maesdoshist
                    WHERE empresa = pEmpresa
                        AND num_credito = vnum_credito
                        AND monto_vencido = 0 
                        AND mto_venc_trasp = 0;


                IF UltimaFechaVigente is null THEN

                    SELECT max(fecha)
                        INTO UltimaFechaVigente_old
                        FROM bdicred:sd_maesdoshist_old
                        WHERE empresa = pEmpresa
                            AND num_credito = vnum_credito
                            AND monto_vencido > 0 
                            AND mto_venc_trasp = 0;

                    IF UltimaFechaVigente_old is null THEN
                        LET vimpagos_consec_h=41;
                        LET vdias_atraso_h=1230;
                    ELSE 
                        SELECT count(*)
                            INTO vimpagos_consec_h 
                            FROM bdicred:sd_maesdoshist_old b 
                            WHERE b.empresa = pEmpresa
                                AND b.num_credito = vnum_credito
                                AND b.fecha >= UltimaFechaVigente_old
                                AND b.fecha <= fecha_ejecucion;

                        SELECT count(*)
                            INTO vimpagos_consec_h_aux
                            FROM bdicred:sd_maesdoshist b 
                            WHERE b.empresa = pEmpresa
                                AND b.num_credito = vnum_credito
                                AND b.fecha >= UltimaFechaVigente_old
                                AND b.fecha <= fecha_ejecucion;

                        LET vimpagos_consec_h = vimpagos_consec_h + vimpagos_consec_h_aux;

                        LET vdias_atraso_h = fecha_ejecucion -UltimaFechaVigente_old;

                    END IF;        
                ELSE
                    SELECT count(*)
                        INTO vimpagos_consec_h
                        FROM bdicred:sd_maesdoshist 
                        WHERE empresa = pEmpresa
                            AND num_credito = vnum_credito
                            AND fecha >= UltimaFechaVigente
                            AND fecha <= fecha_ejecucion;

                    SELECT fecha_ejecucion - min(fecha)
                        INTO vdias_atraso_h
                        FROM bdicred:sd_maesdoshist
                        WHERE empresa = pEmpresa
                            AND num_credito = vnum_credito
                            AND fecha >= UltimaFechaVigente
                            AND fecha <= fecha_ejecucion; 

                    IF vdias_atraso_h is null THEN
                        LET vdias_atraso_h=0;
                    END IF;

                END IF;

                LET vdias_atraso_ch=vdias_atraso_h;
                LET vimpagos_consec_ch = vimpagos_consec_h;

                IF ( (MaximaFechaVigente is NOT null) AND (UltimaFechaVigente is NOT null) AND (UltimaFechaVigente < MaximaFechaVigente) ) THEN
                
                    LET vimpagos_consec_h = 0;
                    LET vdias_atraso_h=0;
                    LET etapaCred='E1';

                END IF;
                
                IF ((vimpagos_consec_h > 3) or (vdias_atraso_h>90)) THEN
                    LET etapaCred = 'E3';
                ELIF (vimpagos_consec_h <= 1 AND estatusCred != 'BT') THEN
                    LET etapaCred = 'E1';
                ELSE
                    LET etapaCred = 'E2';
                END IF;
              
            END IF;


            SELECT SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),
                SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),
                SUM(NVL(iva_debe,0) - NVL(iva_pagado,0))
            INTO dIntVdo,dIntMoratorio,dIvaIntVdo
            FROM "informix".sd_amortiza_credito
            WHERE empresa     = pEmpresa
            AND num_credito = vnum_credito
            AND capital_status IN ('2','7');  

            SELECT iva
                INTO dIvaSuc
                FROM bdinteg:"informix".si_sucursales
                WHERE sucursal = vSucursal
                AND empresa  = pEmpresa;   

            LET dIntMoratorio_d=0; 


            --BEGIN WORK;

                IF estatusCred = 'AA' THEN
                    
                    IF dCapVig > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, 2, '500', fecha_mov, dCapVig, Folio, vSucursal, vDivisa, '0000') 
                            INTO cCod_Ret, cMensajeRet; --"MONTO CAPITAL VIGENTE POSITIVO"
                    ELIF dCapVig < 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, 1, '500', fecha_mov, ((dCapVig)*(-1) ), Folio, vSucursal, vDivisa, '0000') 
                            INTO cCod_Ret, cMensajeRet; --"MONTO CAPITAL VIGENTE NEGATIVO"
                    END IF;

                ELIF estatusCred = 'BA' THEN
                    
                    IF dCapVig > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, 4, '500', fecha_mov, dCapVig, Folio, vSucursal, vDivisa, '0000') 
                            INTO cCod_Ret, cMensajeRet; --"MONTO CAPITAL VIGENTE POSITIVO"
                    END IF;
                    IF dCapTrans > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, 5, '500', fecha_mov, dCapTrans, Folio, vSucursal, vDivisa, '0000')
                            INTO cCod_Ret, cMensajeRet; --"MONTO VENCIDO"
                    END IF;

                ELIF (estatusCred = 'BT' AND etapaCred='E2') THEN
                    
                    IF dCapVdoNoExig > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, 6, '500', fecha_mov, dCapVdoNoExig, Folio, vSucursal, vDivisa, '0000')
                        INTO cCod_Ret, cMensajeRet; --"MONTO CAPITAL VENCIDO NO EXIGIBLE"
                    END IF;
                    IF dCapVdoExig > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, 7, '500', fecha_mov, dCapVdoExig, Folio, vSucursal, vDivisa, '0000')
                        INTO cCod_Ret, cMensajeRet; --"MONTO CAPITAL VENCIDO EXIGIBLE"
                    END IF;
                    IF dIntVdo > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, 8, '500', fecha_mov, dIntVdo, Folio, vSucursal, vDivisa, '0000')
                        INTO cCod_Ret, cMensajeRet;	--"MONTO INTERES VENCIDO"
                    END IF;
                    IF dIvaIntVdo > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, 9, '500', fecha_mov, dIvaIntVdo, Folio, vSucursal, vDivisa, '0000')
                        INTO cCod_Ret, cMensajeRet; --"MONTO IVA INTERES VENCIDO"
                    END IF;

                ELIF (estatusCred = 'BT' AND etapaCred='E3') THEN 
                    
                    IF dCapVdoNoExig > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, 10, '500', fecha_mov, dCapVdoNoExig, Folio, vSucursal, vDivisa, '0000')
                        INTO cCod_Ret, cMensajeRet; --"MONTO CAPITAL VENCIDO NO EXIGIBLE"
                    END IF;
                    IF dCapVdoExig > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, 11, '500', fecha_mov, dCapVdoExig, Folio, vSucursal, vDivisa, '0000')
                        INTO cCod_Ret, cMensajeRet; --"MONTO CAPITAL VENCIDO EXIGIBLE"
                    END IF;
                    IF dIntVdo > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, 12, '500', fecha_mov, dIntVdo, Folio, vSucursal, vDivisa, '0000')
                        INTO cCod_Ret, cMensajeRet;	--"MONTO INTERES VENCIDO"
                    END IF;
                    IF dIvaIntVdo > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, 13, '500', fecha_mov, dIvaIntVdo, Folio, vSucursal, vDivisa, '0000')
                        INTO cCod_Ret, cMensajeRet; --"MONTO IVA INTERES VENCIDO"
                    END IF;

                END IF;  

                IF etapaCred = 'E3' THEN
                    
                    FOREACH WITH HOLD
                        select fecha_cuota
                            INTO vfecha_cuota
                            FROM "informix".sd_amortiza_credito
                          WHERE empresa     = pEmpresa
                            AND num_credito = vnum_credito
                            AND capital_status IN ('2') 

                        UPDATE bdicred:sd_amortiza_credito SET capital_status='6', capital_status_ant = '2' 
                            WHERE empresa = pEmpresa AND num_credito = vnum_credito AND fecha_cuota=vfecha_cuota;
                    END FOREACH; 

                END IF;

                IF vimpagos_consec_h = 2 THEN
                    UPDATE bdicred:sd_maesdos SET act=vimpagos_consec_h, sdo_capital = sdo_capital + dCapVdoNoExig, monto_vencido = monto_vencido + dCapVdoExig,
                         cap_tras_no_venci=0, mto_venc_trasp=0, sdo_no_exig=sdo_no_exig+int_tra_no_exig, int_tra_no_exig=0
                        WHERE empresa = pEmpresa AND num_credito = vnum_credito;
                ELSE
                    UPDATE bdicred:sd_maesdos SET act=vimpagos_consec_h, sdo_capital = sdo_capital + dCapVdoNoExig, monto_vencido = monto_vencido + dCapVdoExig, cap_tras_no_venci=0, mto_venc_trasp=0
                        WHERE empresa = pEmpresa AND num_credito = vnum_credito;
                END IF;

                
                UPDATE bdicred:sd_indicador_cred SET dias_act=vdias_atraso_h
                    WHERE empresa = pEmpresa AND num_credito = vnum_credito; 

                UPDATE bdicred:sd_maecred SET status_cred=etapaCred
                    WHERE empresa = pEmpresa AND num_credito = vnum_credito; 

                INSERT INTO bdicred:etapas_cred(empresa, tipo, num_producto, sucursal, num_credito, etapa, status_cred, act, dias_act, atr, dias_atr,
                             IntVig, IvaIntVig, IntVdo, IvaIntVdo) 
	                VALUES('001', '1', vnum_producto, vsucursal, vnum_credito, etapaCred, estatusCred, vimpagos_consec_h, vdias_atraso_h,mto_fin_ven_TraspCred, vdias_atraso_ind, 
                             dIntVig, dIvaIntVig, dIntVdo, dIvaIntVdo);  

                LET contador_commit = contador_commit + 1;

            --COMMIT WORK;

            LET vimpagos_consec_h =0;
            LET vdias_atraso_h   =0;
            LET vimpagos_consec_ch =0;
            LET vdias_atraso_ch   =0;
            LET dCapVig          =0;
            LET dSdoActCap       =0;
            LET dCapTrans        =0;
            LET dCapVdoExig      =0;
            LET dCapVdoNoExig    =0;
            LET dIntVig          =0;
            LET dIvaIntVig       =0;
            LET dIntVdo          =0;
            LET dIntMoratorio    =0;
            LET dIvaIntVdo       =0;
            LET dIntMoratorio_d  =0;
            LET dIvaIntMoratorio =0;
            LET Folio            =0;
        
        --END IF;

    END FOREACH;

    drop table univ_ree;
    LET cCod_Ret = '000';
    LET cMensajeRet = 'PROCESO CONCLUIDO, REGISTROS ACTUALIZADOS '||contador_commit;
    
    RETURN cCod_ret,cMensajeRet;

END;
END PROCEDURE;