CREATE PROCEDURE "informix".sp_ambientar_indicador_7800(fecha_ejecucion DATE, vNumCredito CHAR(12)) 



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
DEFINE vimpagos_consec_ch      DECIMAL(16,2);
DEFINE fecha_mov    DATE;
DEFINE max_fecha_mov    DATE;
DEFINE max_fecha_mov2    DATE;
DEFINE fecha_hoy        DATE;
DEFINE fecha_primer_dia DATE;
DEFINE fecha_mes_ant    DATE;
DEFINE vdia_mes       INTEGER;
DEFINE int_cap2mes_tdc  DECIMAL(16,2);
DEFINE contador_commit  INTEGER;
DEFINE vdia_corte  INTEGER;
DEFINE total_indicador  DECIMAL(16,2);
DEFINE estatusCred      CHAR(2); 
DEFINE etapaCred      CHAR(2);
DEFINE vdias_atraso  INTEGER;
DEFINE mto_fin_ven_TraspCred    DECIMAL(16,2);
DEFINE UltimaFechaVigente   DATE;
DEFINE UltimaFechaVigente_old   DATE;
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

DEFINE dperiodo_plazo   CHAR(1);
DEFINE dfecha_corte     DATE;
DEFINE dfecha_corte_aux DATE;
DEFINE dfecha_venc     DATE;
DEFINE dDia_habil       CHAR(3);
DEFINE vUltimoDia_aux  DATE;
DEFINE vDiaQuincena_aux  DATE;
DEFINE vUltimoDia  DATE;
DEFINE vDiaQuincena  DATE;

DEFINE vCodigoRef_1NoExig_AA	INTEGER;
DEFINE vCodigoRef_1Exig_AA		INTEGER;
DEFINE vCodigoRef_1NoExig_BA	INTEGER;
DEFINE vCodigoRef_1Exig_BA		INTEGER;
DEFINE vCodigoRef_1NoExig_BT	INTEGER;
DEFINE vCodigoRef_1Exig_BT		INTEGER;
DEFINE vCodigoRef_3NoExig_BA	INTEGER;
DEFINE vCodigoRef_3Exig_BA		INTEGER;
DEFINE vCodigoRef_3NoExig_BT	INTEGER;
DEFINE vCodigoRef_3Exig_BT		INTEGER;

DEFINE vCapital_status          CHAR(1);


--Inicializacion de variables
LET sql_err         = 0;
LET isam_err        = 0;
LET error_info      = "";
LET cEmpresa        = "";
LET pEmpresa        = "";
LET cProceso        = '0024';
LET cCod_Ret        = '000000';
LET cCod_retBit     = '000000';
LET cMensajeRet     = 'PROCESO EXITOSO';
LET vnum_credito    = "";
LET vnum_producto   = "";
LET vcredito_externo = "";
LET vimpagos_consec_h     = 0;
LET vimpagos_consec_ch     = 0;
LET fecha_mov   = DATE(0);
LET max_fecha_mov   = DATE(0);
LET max_fecha_mov2  = DATE(0);
LET fecha_hoy       = DATE(0);
LET fecha_primer_dia = DATE(0);
LET fecha_mes_ant   = DATE(0);
LET vdia_mes        = 0;
LET int_cap2mes_tdc = 0;
LET contador_commit = 0;
LET vdia_corte      = 0;
LET total_indicador = 0;
LET estatusCred     = '';
LET etapaCred       = '';
LET vdias_atraso   = 0;
LET mto_fin_ven_TraspCred = 0;
LET UltimaFechaVigente = DATE(0);
LET UltimaFechaVigente_old = DATE(0);
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

LET dperiodo_plazo   ='';
LET dfecha_corte     =DATE(0);
LET dfecha_corte_aux =DATE(0);
LET dfecha_venc      =DATE(0);
LET dDia_habil       ='';
let vUltimoDia_aux = DATE(0);
let vDiaQuincena_aux = DATE(0);
let vUltimoDia = DATE(0);
let vDiaQuincena = DATE(0);

LET vCodigoRef_1NoExig_AA	= 0;
LET vCodigoRef_1Exig_AA		= 0;
LET vCodigoRef_1NoExig_BA	= 0;
LET vCodigoRef_1Exig_BA		= 0;
LET vCodigoRef_1NoExig_BT	= 0;
LET vCodigoRef_1Exig_BT		= 0;
LET vCodigoRef_3NoExig_BA	= 0;
LET vCodigoRef_3Exig_BA		= 0;
LET vCodigoRef_3NoExig_BT	= 0;
LET vCodigoRef_3Exig_BT		= 0;

--SET DEBUG FILE TO "/ifxsif01/aldo/etapas/sp_ambientar_indicador_7800.out";
--TRACE ON;

--EXECUTE PROCEDURE sp_ambientar_indicador_7800(mdy(08,31,2021));

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


    LET vCodigoRef_1NoExig_AA	= 14;
    LET vCodigoRef_1Exig_AA		= 60;
    LET vCodigoRef_1NoExig_BA	= 17;
    LET vCodigoRef_1Exig_BA		= 18;
    LET vCodigoRef_1NoExig_BT	= 61;
    LET vCodigoRef_1Exig_BT		= 62;
    LET vCodigoRef_3NoExig_BA	= 37;
    LET vCodigoRef_3Exig_BA		= 38;
    LET vCodigoRef_3NoExig_BT	= 39;
    LET vCodigoRef_3Exig_BT		= 40;

    select a.num_credito, a.num_producto, a.status_cred,a.divisa,a.sucursal,b.dia_corte,c.impagos_consec_h,c.dias_atraso,d.mto_fin_ven_Trasp,a.fecha_apertura,a.fecha_vencim,
        NVL(d.sdo_capital,0) CapVig, NVL(d.sdo_cap_insoluto,0) CapAct, NVL(d.monto_vencido,0) CapTrans, NVL(d.mto_venc_trasp,0) CapVdoExig, NVL(d.cap_tras_no_venci,0) CapVdoNoExig,
        periodo_plazo
        FROM sd_maecred a,sd_maecredanexo b, sd_indicador_cred c, sd_maesdos d
         WHERE a.num_credito   = b.num_credito 
           AND c.num_credito   = a.num_credito
           AND d.num_credito   = a.num_credito
           AND a.empresa       = b.empresa
           AND c.empresa       = a.empresa
           AND d.empresa       = a.empresa
           AND a.empresa       = pEmpresa
           AND a.num_producto = '7800' 
           and a.num_credito = vNumCredito
        into temp univ_ree with no log;         
            
    --LET fecha_ejecucion = fecha_hoy;

    FOREACH WITH HOLD
        select *
        INTO vnum_credito, vnum_producto, estatusCred, vdivisa, vsucursal, vdia_corte, vimpagos_consec_h,vdias_atraso,mto_fin_ven_TraspCred,vfecha_apertura,vfecha_vencim,
            dCapVig, dSdoActCap, dCapTrans, dCapVdoExig, dCapVdoNoExig, dperiodo_plazo
        FROM univ_ree
            
            /*
            UPDATE bdicred:sd_maesdos SET sdo_capital=dCapVig, sdo_cap_insoluto=dSdoActCap, monto_vencido = dCapTrans, 
                mto_venc_trasp =dCapVdoExig, cap_tras_no_venci =dCapVdoNoExig
                where empresa = pEmpresa
                    AND num_credito=vNumCredito;*/


            SELECT USER||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(current,3,2)||SUBSTR(CURRENT,12,2)||substr(current,15,2)||SUBSTR(current,18,2) INTO Folio FROM dual;

            SELECT fecha_ult_disp,CASE WHEN frecuencia_pgo = 1 THEN 'M' WHEN frecuencia_pgo = 2 THEN 'Q' ELSE 'M' END frecuencia_pgo  
                INTO vfecha_apertura, dperiodo_plazo
            FROM bdisolic:ss_adn_solicitudcuenta 
            where empresa     = pEmpresa
            AND num_solicitud = vnum_credito;

            IF (vfecha_apertura IS NULL) OR (vfecha_apertura > fecha_ejecucion) OR (estatusCred='AA') THEN

                LET vimpagos_consec_h=0;
                LET vdias_atraso = 0; 
                LET etapaCred = 'E1';

            ELSE 

                let vUltimoDia_aux = last_day(vfecha_apertura);
                let vDiaQuincena_aux = mdy(month(vfecha_apertura),15,year(vfecha_apertura));

                LET dDia_habil = WEEKDAY(vUltimoDia_aux);
                IF(dDia_habil=6) THEN
                    LET vUltimoDia=vUltimoDia_aux- 1 UNITS DAY;
                ELIF(dDia_habil=0) THEN
                    LET vUltimoDia=vUltimoDia_aux- 2 UNITS DAY;
                ELSE
                    LET vUltimoDia=vUltimoDia_aux;
                END IF;

                LET dDia_habil = WEEKDAY(vDiaQuincena_aux);
                IF(dDia_habil=6) THEN
                    LET vDiaQuincena=vDiaQuincena_aux- 1 UNITS DAY;
                ELIF(dDia_habil=0) THEN
                    LET vDiaQuincena=vDiaQuincena_aux- 2 UNITS DAY;
                ELSE
                    LET vDiaQuincena=vDiaQuincena_aux;
                END IF;

                IF (dperiodo_plazo='M') THEN

                    IF (vfecha_apertura = vUltimoDia) THEN
                        LET dfecha_corte_aux = last_day(vfecha_apertura + 1 UNITS MONTH);    
                    ELSE
                        LET dfecha_corte_aux = vUltimoDia_aux;
                    END IF;

                ELIF (dperiodo_plazo='Q') THEN

                    IF (vfecha_apertura >= vDiaQuincena) THEN
                        IF (vfecha_apertura = vUltimoDia) THEN
                            LET dfecha_corte_aux = mdy((month(vfecha_apertura + 1 UNITS MONTH)),15,year(vfecha_apertura));    
                        ELSE
                            LET dfecha_corte_aux = vUltimoDia_aux;
                        END IF;
                    ELSE
                            LET dfecha_corte_aux = mdy(month(vfecha_apertura),15,year(vfecha_apertura));
                    END IF;

                END IF;

                LET dDia_habil = WEEKDAY(dfecha_corte_aux);

                IF(dDia_habil=6) THEN
                    LET dfecha_corte=dfecha_corte_aux- 1 UNITS DAY;
                ELIF(dDia_habil=0) THEN
                    LET dfecha_corte=dfecha_corte_aux- 2 UNITS DAY;
                ELSE
                    LET dfecha_corte=dfecha_corte_aux;
                END IF;

                IF fecha_ejecucion >= dfecha_corte THEN
                    
                    IF (dperiodo_plazo='Q') THEN
                        
                        select TRUNC(months_between(fecha_ejecucion,dfecha_corte) * 2 ) +1
                            INTO vimpagos_consec_h
                            from bdicred:sd_fechas
                            WHERE empresa = pEmpresa; 

                    ELSE

                        select TRUNC(months_between(fecha_ejecucion,dfecha_corte)) + 1
                            INTO vimpagos_consec_h
                            from bdicred:sd_fechas
                            WHERE empresa = pEmpresa; 

                    END IF;

                    LET vdias_atraso=  fecha_ejecucion-dfecha_corte;
                ELSE
                    LET vimpagos_consec_h = 0;
                    LET vdias_atraso = 0;
                END IF;

                IF dfecha_corte >= fecha_ejecucion THEN
                    LET vdias_atraso = 0; 
                END IF;
                
                IF vdias_atraso>=30 THEN
                    LET etapaCred = 'E3';
                ELSE
                    LET etapaCred = 'E1';
                END IF;

            END IF;

            select max(fecha_cuota)
                INTO vfecha_cuota
                FROM "informix".sd_amortiza_credito
                WHERE empresa     = pEmpresa
                AND num_credito = vnum_credito;

            select capital_status
                INTO vCapital_status
                FROM "informix".sd_amortiza_credito
                WHERE empresa     = pEmpresa
                AND num_credito = vnum_credito
                AND fecha_cuota=vfecha_cuota;

            --BEGIN WORK;

                IF vfecha_cuota IS NOT NULL THEN

                    INSERT INTO bdicred:"informix".sd_amortiza_credito_adn
                        SELECT * FROM bdicred: "informix".sd_amortiza_credito
                        WHERE empresa = pEmpresa
                            AND num_credito = vnum_credito
                            AND fecha_cuota not in (vfecha_cuota);

                    DELETE "informix".sd_amortiza_credito
                        WHERE empresa     = pEmpresa
                        AND num_credito = vnum_credito 
                        AND fecha_cuota not in (vfecha_cuota);

                    IF (vfecha_apertura IS NOT NULL) AND (vfecha_apertura <= fecha_ejecucion) THEN
                        
                        IF etapaCred='E3' THEN 
                            UPDATE bdicred:sd_amortiza_credito SET fecha_cuota=dfecha_corte_aux,capital_status_ant = capital_status, capital_status='6'
                                WHERE empresa = pEmpresa AND num_credito = vnum_credito AND fecha_cuota=vfecha_cuota;
                        ELSE
                            UPDATE bdicred:sd_amortiza_credito SET fecha_cuota=dfecha_corte_aux
                                WHERE empresa = pEmpresa AND num_credito = vnum_credito AND fecha_cuota=vfecha_cuota;
                        END IF;
                    END IF;

                END IF;


                IF estatusCred = 'AA' THEN
                    
                    IF dCapVig > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, vCodigoRef_1NoExig_AA, '500', fecha_mov, dCapVig, Folio, vSucursal, vDivisa, '0000') 
                            INTO cCod_Ret, cMensajeRet; --"MONTO CAPITAL VIGENTE POSITIVO"
                    END IF;
                    IF dCapTrans > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, vCodigoRef_1Exig_AA, '500', fecha_mov, dCapTrans, Folio, vSucursal, vDivisa, '0000')
                            INTO cCod_Ret, cMensajeRet; --"MONTO VENCIDO"
                    END IF;


                ELIF (estatusCred = 'BA' AND etapaCred='E1') THEN
                    
                    IF dCapVig > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, vCodigoRef_1NoExig_BA, '500', fecha_mov, dCapVig, Folio, vSucursal, vDivisa, '0000') 
                            INTO cCod_Ret, cMensajeRet; --"MONTO CAPITAL VIGENTE POSITIVO"
                    END IF;
                    IF dCapTrans > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, vCodigoRef_1Exig_BA, '500', fecha_mov, dCapTrans, Folio, vSucursal, vDivisa, '0000')
                            INTO cCod_Ret, cMensajeRet; --"MONTO VENCIDO"
                    END IF;

                ELIF (estatusCred = 'BT' AND etapaCred='E1') THEN                                       
                    
                    IF dCapVdoNoExig > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, vCodigoRef_1NoExig_BT, '500', fecha_mov, dCapVdoNoExig, Folio, vSucursal, vDivisa, '0000')
                        INTO cCod_Ret, cMensajeRet; --"MONTO CAPITAL VENCIDO NO EXIGIBLE"
                    END IF;
                    IF dCapVdoExig > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, vCodigoRef_1Exig_BT, '500', fecha_mov, dCapVdoExig, Folio, vSucursal, vDivisa, '0000')
                        INTO cCod_Ret, cMensajeRet; --"MONTO CAPITAL VENCIDO EXIGIBLE"
                    END IF;

                ELIF (estatusCred = 'BA' AND etapaCred='E3') THEN
                    
                    IF dCapVig > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, vCodigoRef_3NoExig_BA, '500', fecha_mov, dCapVig, Folio, vSucursal, vDivisa, '0000') 
                            INTO cCod_Ret, cMensajeRet; --"MONTO CAPITAL VIGENTE POSITIVO"
                    END IF;
                    IF dCapTrans > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, vCodigoRef_3Exig_BA, '500', fecha_mov, dCapTrans, Folio, vSucursal, vDivisa, '0000')
                            INTO cCod_Ret, cMensajeRet; --"MONTO VENCIDO"
                    END IF;

                ELIF (estatusCred = 'BT' AND etapaCred='E3') THEN
                    
                    IF dCapVdoNoExig > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, vCodigoRef_3NoExig_BT, '500', fecha_mov, dCapVdoNoExig, Folio, vSucursal, vDivisa, '0000')
                        INTO cCod_Ret, cMensajeRet; --"MONTO CAPITAL VENCIDO NO EXIGIBLE"
                    END IF;
                    IF dCapVdoExig > 0 THEN
                        EXECUTE PROCEDURE genmov_ifrs(pEmpresa, vnum_credito, vnum_producto, vCodigoRef_3Exig_BT, '500', fecha_mov, dCapVdoExig, Folio, vSucursal, vDivisa, '0000')
                        INTO cCod_Ret, cMensajeRet; --"MONTO CAPITAL VENCIDO EXIGIBLE"
                    END IF;

                END IF; 


                IF (vimpagos_consec_h=0 and etapaCred='E1') THEN
                    UPDATE bdicred:sd_maecredanexo SET fecha_vencto = null  
                    WHERE empresa = pEmpresa AND num_credito = vnum_credito;
                END IF;

                UPDATE bdicred:sd_maesdos SET act=vimpagos_consec_h, sdo_capital = sdo_capital + dCapVdoNoExig, monto_vencido = monto_vencido + dCapVdoExig, cap_tras_no_venci=0, mto_venc_trasp=0
                    WHERE empresa = pEmpresa AND num_credito = vnum_credito;

                UPDATE bdicred:sd_indicador_cred SET dias_atraso=vdias_atraso  
                    WHERE empresa = pEmpresa AND num_credito = vnum_credito;

                UPDATE bdicred:sd_maecred SET status_cred=etapaCred
                    WHERE empresa = pEmpresa AND num_credito = vnum_credito; 

                INSERT INTO bdicred:etapas_cred(empresa, tipo, num_producto, sucursal, num_credito, etapa, status_cred, act, dias_act, atr, dias_atr, 
                             IntVig, IvaIntVig, IntVdo, IvaIntVdo) 
	                VALUES('001', '3', vnum_producto, vsucursal, vnum_credito, etapaCred, estatusCred, vimpagos_consec_h, vdias_atraso,mto_fin_ven_TraspCred, vdias_atraso,
                             dIntVig, dIvaIntVig, dIntVdo, dIvaIntVdo);  

                LET contador_commit = contador_commit + 1;
            
            --COMMIT WORK;

            LET vimpagos_consec_h =0;
            LET vdias_atraso   =0;
            LET vimpagos_consec_ch =0;
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
        
    END FOREACH;

    drop table univ_ree;
    LET cCod_Ret = '000';
    LET cMensajeRet = 'PROCESO CONCLUIDO, REGISTROS ACTUALIZADOS '||contador_commit;
    
    RETURN cCod_ret,cMensajeRet;

END;
END PROCEDURE;