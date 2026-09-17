CREATE PROCEDURE "informix".sp_ambientar_indicador_cred_crd(fecha_ejecucion DATE, vNumCredito char(12)) 


RETURNING  CHAR(6) AS Cod_Ret,  CHAR(80) AS Mens_Ret;

-- Autor: Aldo E Hernandez
-- Fecha: 07/11/2019
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
DEFINE vnum_credito      CHAR(12);
DEFINE vcredito_externo  CHAR(12);
DEFINE vimpagos_consec_h      INTEGER;
DEFINE vimpagos_consec_ch      INTEGER;
DEFINE fecha_mov    DATE;
DEFINE max_fecha_mov    DATE;
DEFINE max_fecha_mov2    DATE;
DEFINE pri_dia_mes      DATE;
DEFINE vdia_mes       INTEGER;
DEFINE int_cap2mes_tdc  DECIMAL(16,2);
DEFINE contador_commit  INTEGER;
DEFINE vdia_corte  INTEGER;
DEFINE total_indicador  DECIMAL(16,2);
DEFINE estatusCred      CHAR(2);
DEFINE etapaCred      CHAR(3);
DEFINE dias_moraCred  INTEGER;
DEFINE fecha_aperturaCred  DATE;
DEFINE UltimaFechaVigente  DATE;
DEFINE UltimaFechaVigente_old DATE;
DEFINE vdias_atraso_h  INTEGER;
DEFINE vdias_atraso_ch  INTEGER;
DEFINE vdias_atraso_ind INTEGER;
DEFINE NumProductoCred      CHAR(4);
DEFINE periodo_plazoCred    CHAR(1);
DEFINE d_capital_ven_exigible DECIMAL(10,2);
DEFINE d_capital_vig_exigible DECIMAL(10,2);
DEFINE d_saldo_cierre         DECIMAL(10,2);
DEFINE d_saldo_exigible       DECIMAL(10,2);
DEFINE d_saldo_no_exigible    DECIMAL(10,2);
DEFINE d_moratorios           DECIMAL(10,2);
DEFINE d_int_venc_exig_cierre   DECIMAL(10,2);
DEFINE mto_fin_ven_TraspCred    INTEGER;
DEFINE var_mto_fin_ven_trasp2   INTEGER;
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
DEFINE dprovision_normal DECIMAL(16,2);
DEFINE dsdo_global_int DECIMAL(16,2);
DEFINE Folio            CHAR(16);
DEFINE vdivisa          CHAR(3);
DEFINE vsucursal        CHAR(4);
DEFINE dIvaSuc           DECIMAL(5,3);
DEFINE vfecha_apertura   DATE;
DEFINE vfecha_vencim     DATE;
DEFINE MaximaFechaVigente   DATE;
DEFINE UltimaFechaHist   DATE;
DEFINE vfecha_cuota      DATE;

DEFINE vCodigoRef_1NoExig_AA		INTEGER;
DEFINE vCodigoRef_1Int_Vig_AA		INTEGER;
DEFINE vCodigoRef_1Iva_Vig_AA		INTEGER;
DEFINE vCodigoRef_1NoExig_BA		INTEGER;
DEFINE vCodigoRef_1Exig_BA		INTEGER;
DEFINE vCodigoRef_1Int_Vig_BA		INTEGER;
DEFINE vCodigoRef_1Iva_Vig_BA		INTEGER;
DEFINE vCodigoRef_1NoExig_BT		INTEGER;
DEFINE vCodigoRef_1Exig_BT		INTEGER;
DEFINE vCodigoRef_1Int_Vig_BT		INTEGER;
DEFINE vCodigoRef_1Iva_Vig_BT		INTEGER;
DEFINE vCodigoRef_2NoExig_BA		INTEGER;
DEFINE vCodigoRef_2Exig_BA		INTEGER;
DEFINE vCodigoRef_2Int_Venc_BA 	INTEGER;
DEFINE vCodigoRef_2Iva_Venc_BA	INTEGER;
DEFINE vCodigoRef_2Int_Vig_BA		INTEGER;
DEFINE vCodigoRef_2Iva_Vig_BA		INTEGER;
DEFINE vCodigoRef_2NoExig_BT		INTEGER;
DEFINE vCodigoRef_2Exig_BT		INTEGER;
DEFINE vCodigoRef_2Int_Venc_BT 	INTEGER;
DEFINE vCodigoRef_2Iva_Venc_BT	INTEGER;
DEFINE vCodigoRef_2Int_Vig_BT		INTEGER;
DEFINE vCodigoRef_2Iva_Vig_BT		INTEGER;
DEFINE vCodigoRef_3NoExig_BA		INTEGER;
DEFINE vCodigoRef_3Exig_BA		INTEGER;
DEFINE vCodigoRef_3Int_Venc_BA 	INTEGER;
DEFINE vCodigoRef_3Iva_Venc_BA	INTEGER;
DEFINE vCodigoRef_3Int_Vig_BA		INTEGER;
DEFINE vCodigoRef_3Iva_Vig_BA		INTEGER;
DEFINE vCodigoRef_3NoExig_BT		INTEGER;
DEFINE vCodigoRef_3Exig_BT		INTEGER;
DEFINE vCodigoRef_3Int_Venc_BT 	INTEGER;
DEFINE vCodigoRef_3Iva_Venc_BT	INTEGER;
DEFINE vCodigoRef_3Int_Vig_BT		INTEGER;
DEFINE vCodigoRef_3Iva_Vig_BT		INTEGER;
DEFINE vCodigoRef_3NoExig_VP		INTEGER;
DEFINE vCodigoRef_3Exig_VP		INTEGER;
DEFINE vCodigoRef_3Int_Venc_VP 	INTEGER;
DEFINE vCodigoRef_3Iva_Venc_VP	INTEGER;
DEFINE vCodigoRef_3Int_Vig_VP		INTEGER;
DEFINE vCodigoRef_3Iva_Vig_VP		INTEGER;

DEFINE v_atr                INTEGER;
DEFINE wbandera_apoyo 	CHAR(1);

--Inicializacion de variables
LET sql_err         = 0;
LET isam_err        = 0;
LET error_info      = "";
LET cEmpresa        = "001";
LET pEmpresa        = "";
LET cProceso        = '0024';
LET cCod_Ret        = '000000';
LET cCod_retBit     = '000000';
LET cMensajeRet     = 'PROCESO EXITOSO';
LET vnum_credito     = "";
LET vcredito_externo = "";
LET vimpagos_consec_h     = 0;
LET vimpagos_consec_ch     = 0;
LET fecha_mov   = DATE(0);
LET max_fecha_mov   = DATE(0);
LET max_fecha_mov2   = DATE(0);
LET vdia_mes        = 0;
LET int_cap2mes_tdc = 0;
LET contador_commit = 0;
LET vdia_corte      = 0;
LET total_indicador = 0;
LET estatusCred     = '';
LET etapaCred       = '';
LET dias_moraCred   = 0;
LET fecha_aperturaCred = DATE(0);
LET UltimaFechaVigente = DATE(0);
LET UltimaFechaVigente_old = DATE(0);
LET vdias_atraso_h = 0;
LET vdias_atraso_ch = 0;
LET vdias_atraso_ind =0;
LET NumProductoCred = '';
LET periodo_plazoCred = '';
LET d_capital_ven_exigible =0;
LET d_capital_vig_exigible =0;
LET d_saldo_cierre         =0;
LET d_saldo_exigible       =0;
LET d_saldo_no_exigible    =0;
LET d_moratorios           =0;
LET d_int_venc_exig_cierre =0;
LET pri_dia_mes     = DATE(0);
LET mto_fin_ven_TraspCred  =0;
LET var_mto_fin_ven_trasp2 =0;
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
LET dprovision_normal =0;
LET dsdo_global_int  =0;
LET Folio            =0;
LET vdivisa          ='';
LET vsucursal        ='';
LET dIvaSuc          =0;
LET vfecha_apertura   = DATE(0);
LET vfecha_vencim     = DATE(0);
LET MaximaFechaVigente = DATE(0);
LET UltimaFechaHist = DATE(0);
LET vfecha_cuota      = DATE(0);
LET v_atr             = 0;
LET wbandera_apoyo = '';

LET vCodigoRef_1NoExig_AA		= 0;
LET vCodigoRef_1Int_Vig_AA		= 0;
LET vCodigoRef_1Iva_Vig_AA		= 0;
LET vCodigoRef_1NoExig_BA		= 0;
LET vCodigoRef_1Exig_BA		= 0;
LET vCodigoRef_1Int_Vig_BA		= 0;
LET vCodigoRef_1Iva_Vig_BA		= 0;
LET vCodigoRef_1NoExig_BT		= 0;
LET vCodigoRef_1Exig_BT		= 0;
LET vCodigoRef_1Int_Vig_BT		= 0;
LET vCodigoRef_1Iva_Vig_BT		= 0;
LET vCodigoRef_2NoExig_BA		= 0;
LET vCodigoRef_2Exig_BA		= 0;
LET vCodigoRef_2Int_Venc_BA 	= 0;
LET vCodigoRef_2Iva_Venc_BA	= 0;
LET vCodigoRef_2Int_Vig_BA		= 0;
LET vCodigoRef_2Iva_Vig_BA		= 0;
LET vCodigoRef_2NoExig_BT		= 0;
LET vCodigoRef_2Exig_BT		= 0;
LET vCodigoRef_2Int_Venc_BT 	= 0;
LET vCodigoRef_2Iva_Venc_BT	= 0;
LET vCodigoRef_2Int_Vig_BT		= 0;
LET vCodigoRef_2Iva_Vig_BT		= 0;
LET vCodigoRef_3NoExig_BA		= 0;
LET vCodigoRef_3Exig_BA		= 0;
LET vCodigoRef_3Int_Venc_BA 	= 0;
LET vCodigoRef_3Iva_Venc_BA	= 0;
LET vCodigoRef_3Int_Vig_BA		= 0;
LET vCodigoRef_3Iva_Vig_BA		= 0;
LET vCodigoRef_3NoExig_BT		= 0;
LET vCodigoRef_3Exig_BT		= 0;
LET vCodigoRef_3Int_Venc_BT 	= 0;
LET vCodigoRef_3Iva_Venc_BT	= 0;
LET vCodigoRef_3Int_Vig_BT		= 0;
LET vCodigoRef_3Iva_Vig_BT		= 0;
LET vCodigoRef_3NoExig_VP		= 0;
LET vCodigoRef_3Exig_VP		= 0;
LET vCodigoRef_3Int_Venc_VP 	= 0;
LET vCodigoRef_3Iva_Venc_VP	= 0;
LET vCodigoRef_3Int_Vig_VP		= 0;
LET vCodigoRef_3Iva_Vig_VP		= 0;

    --SET DEBUG FILE TO "/ifxsif01/aldo/etapas/sp_ambientar_indicador_cred_crd.out";
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
    LET fecha_mov =mdy(01,02,2021); --FECHA DE MOVIMIENTO DE MIGRACION EN movdiacrd_ifrs
    LET pri_dia_mes = mdy(month(fecha_ejecucion),01,year(fecha_ejecucion));

    select a.num_credito, a.fecha_apertura, a.num_producto, a.status_cred,a.divisa,a.sucursal,b.mto_fin_ven_Trasp,c.fecha_vencto,
        NVL(b.sdo_capital,0) CapVig, NVL(b.sdo_cap_insoluto,0) CapAct, NVL(b.monto_vencido,0) CapTrans, NVL(b.mto_venc_trasp,0) CapVdoExig, NVL(b.cap_tras_no_venci,0) CapVdoNoExig,
        NVL(b.provision_normal,0) IntProv, NVL(b.sdo_global_int,0) IvaProv
        FROM sd_maecredcrd a, sd_maesdoscrd b, sd_maecredanexocrd c
        WHERE a.num_credito   = b.num_credito
        AND a.num_credito   = c.num_credito
        AND a.empresa       = b.empresa
        AND a.empresa       = c.empresa
        AND a.empresa       = pEmpresa
        AND a.num_credito   = vNumCredito
        AND a.status_cred in ('AA','BA','BT','VP')
        into temp univ_ree with no log; 
			
    FOREACH WITH HOLD
		select *
		INTO vnum_credito, fecha_aperturaCred, NumProductoCred, estatusCred, vdivisa, vsucursal, mto_fin_ven_TraspCred,vfecha_vencim,
            dCapVig, dSdoActCap, dCapTrans, dCapVdoExig, dCapVdoNoExig,
            dprovision_normal, dsdo_global_int
		FROM univ_ree       

        SELECT NVL(dias_atraso,0)
            INTO vdias_atraso_ind
            FROM "informix".sd_indicador_cred_crd 
            WHERE empresa=pEmpresa
                AND num_credito=vnum_credito;

        SELECT USER||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(current,3,2)||SUBSTR(CURRENT,12,2)||substr(current,15,2)||SUBSTR(current,18,2) INTO Folio FROM dual;

            SELECT max(fecha)
                INTO UltimaFechaHist
                FROM bdicred:sd_maesdoshistcrd 
                WHERE empresa = pEmpresa
                    AND num_credito = vnum_credito
                    AND fecha <= fecha_ejecucion;


            SELECT max(fecha)
                INTO MaximaFechaVigente
                FROM bdicred:sd_maesdoshistcrd
                WHERE empresa = pEmpresa
                    AND num_credito = vnum_credito
                    AND monto_vencido = 0 
                    AND mto_venc_trasp = 0;


            SELECT max(a.fecha)
                INTO UltimaFechaVigente
                FROM bdicred:sd_maesdoshistcrd a, bdicred:sd_amortiza_creditocrd b
                WHERE  a.empresa=b.empresa and a.num_credito=b.num_credito and a.fecha=b.fecha_cuota
                    AND a.empresa = pEmpresa
                    AND a.num_credito = vnum_credito    
                    AND a.monto_vencido = 0 
                    AND a.mto_venc_trasp = 0
                    AND a.fecha <= fecha_ejecucion;
  

            LET vdias_atraso_ch=vdias_atraso_h;
            LET vimpagos_consec_ch = vimpagos_consec_h;

            /*IF NumProductoCred='6800' THEN 
                LET vfecha_vencim = fecha_aperturaCred + 1 UNITS year;
            END IF;*/

            LET v_atr=0;

            SELECT bandera INTO wbandera_apoyo
				  FROM sd_programa_apoyo2021crd
				 WHERE num_credito = vnum_credito;

			IF ( wbandera_apoyo is null ) THEN LET wbandera_apoyo = ''; END IF;

            IF wbandera_apoyo = 'A' THEN

                LET v_atr = mto_fin_ven_TraspCred;
 
            ELIF vfecha_vencim <= fecha_ejecucion THEN

                  SELECT MIN(fecha_cuota) INTO vfecha_vencim
                            FROM sd_amortiza_creditocrd 
                            WHERE empresa = pEmpresa
                            AND num_credito =vnum_credito
                            AND capital_status in ('2','7');   
                    

                    /*IF vfecha_vencim = fecha_ejecucion THEN
                        LET var_mto_fin_ven_trasp2=1; 
                    ELSE
                        select case WHEN TRUNC(months_between(fecha_ejecucion,vfecha_vencim),0) <> months_between(fecha_ejecucion,vfecha_vencim) 
                                THEN TRUNC(months_between(fecha_ejecucion,vfecha_vencim),0)+1
                                ELSE TRUNC(months_between(fecha_ejecucion,vfecha_vencim),0)  END as atr
                                INTO var_mto_fin_ven_trasp2
                            from bdicred:sd_fechas
                            WHERE empresa = '001'; 
                    END IF;*/

                IF vfecha_vencim <= fecha_ejecucion THEN
                    select TRUNC(months_between(fecha_ejecucion,vfecha_vencim),0)+1
                            INTO var_mto_fin_ven_trasp2
                        from bdicred:sd_fechas
                        WHERE empresa = '001';
                ELSE
                    LET var_mto_fin_ven_trasp2=0;
                END IF;

                LET v_atr  = var_mto_fin_ven_trasp2;  

                IF (v_atr IS NULL or v_atr='') THEN
                    LET v_atr=0;
                END IF;

            ELSE
                LET v_atr = mto_fin_ven_TraspCred;
            END IF;
                
            IF estatusCred ='AA' THEN
                LET v_atr=0;
                LET vdias_atraso_ind=0;
            END IF;

            IF ( (MaximaFechaVigente is NOT null) AND (UltimaFechaVigente is NOT null) AND (UltimaFechaVigente < MaximaFechaVigente) ) THEN
                LET etapaCred='E1';
                LET vimpagos_consec_h = 0;
                LET vdias_atraso_h=0;
            END IF;

            IF (estatusCred = "AA" ) THEN
                LET vimpagos_consec_h = 0;
                LET vdias_atraso_h=0;
                LET etapaCred='E1';
            ELIF estatusCred='VP' THEN
                LET etapaCred = 'VP';
            ELIF (v_atr > 3) THEN
                LET etapaCred = 'E3';
            ELIF ((v_atr <= 1 AND estatusCred != 'BT') or (fecha_aperturaCred >= pri_dia_mes)) THEN
                LET etapaCred = 'E1';
            ELSE
                LET etapaCred = 'E2';
            END IF;


			IF estatusCred = 'AA' THEN

				LET dIntVig=0;
				LET dIvaIntVig=0;

                SELECT NVL(SUM(NVL(interes_debe - interes_pagado,0)),0),NVL(SUM(NVL(iva_debe - iva_pagado,0)),0)
				INTO dIntVig, dIvaIntVig
				FROM "informix".sd_amortiza_creditocrd
				WHERE empresa        = pEmpresa
					AND num_credito    = vnum_credito
					AND capital_status  IN ('1','7','2');

                IF dprovision_normal > 0 THEN
                    LET dIntVig = dIntVig + dprovision_normal;
                END IF;
                IF dsdo_global_int > 0 THEN
                    LET dIvaIntVig = dIvaIntVig + dsdo_global_int;
                END IF;

                LET dIntVdo = 0;
                LET dIvaIntVdo = 0;

			ELIF estatusCred = 'BA' THEN 

				SELECT NVL(SUM(NVL(interes_debe - interes_pagado,0)),0),NVL(SUM(NVL(iva_debe - iva_pagado,0)),0)
				INTO dIntVig, dIvaIntVig
				FROM "informix".sd_amortiza_creditocrd
				WHERE empresa        = pEmpresa
					AND num_credito    = vnum_credito
					AND capital_status  IN ('1','7','2');

				LET dIntVdo = 0;
                LET dIvaIntVdo = 0;

                IF dprovision_normal > 0 THEN
                    LET dIntVig = dIntVig + dprovision_normal;
                END IF;
                IF dsdo_global_int > 0 THEN
                    LET dIvaIntVig = dIvaIntVig + dsdo_global_int;
                END IF;

			ELIF estatusCred = 'BT' THEN 

				SELECT NVL(SUM(NVL(interes_debe - interes_pagado,0)),0),NVL(SUM(NVL(iva_debe - iva_pagado,0)),0)
				INTO dIntVig, dIvaIntVig
				FROM "informix".sd_amortiza_creditocrd
				WHERE empresa        = pEmpresa
					AND num_credito    = vnum_credito
					AND campo_trabajo3 <> 'V'
					AND capital_status IN ('6','2','7','1');

				SELECT NVL(SUM(NVL(interes_debe - interes_pagado,0)),0),NVL(SUM(NVL(iva_debe - iva_pagado,0)),0)
					INTO dIntVdo,dIvaIntVdo
					FROM "informix".sd_amortiza_creditocrd
					WHERE empresa   = pEmpresa
					AND num_credito = vnum_credito
                    AND campo_trabajo3 = 'V'
					AND capital_status IN ('2','6','7','1');

                IF dprovision_normal > 0 THEN
                    LET dIntVdo = dIntVdo + dprovision_normal;
                END IF;
                IF dsdo_global_int > 0 THEN
                    LET dIvaIntVdo = dIvaIntVdo + dsdo_global_int;
                END IF;

			ELIF estatusCred = 'VP' THEN 

				LET dIntVig = 0;
                LET dIvaIntVig = 0;

				SELECT NVL(SUM(NVL(interes_debe - interes_pagado,0)),0),NVL(SUM(NVL(iva_debe - iva_pagado,0)),0)
					INTO dIntVdo,dIvaIntVdo
					FROM "informix".sd_amortiza_creditocrd
					WHERE empresa   = pEmpresa
					AND num_credito = vnum_credito
					AND capital_status IN ('2','6','7','1');

                IF dprovision_normal > 0 THEN
                    LET dIntVdo = dIntVdo + dprovision_normal;
                END IF;
                IF dsdo_global_int > 0 THEN
                    LET dIvaIntVdo = dIvaIntVdo + dsdo_global_int;
                END IF;
					
			END IF;


                LET vCodigoRef_1NoExig_AA	= 14;
                LET vCodigoRef_1Int_Vig_AA	= 15;
                LET vCodigoRef_1Iva_Vig_AA	= 16;
                LET vCodigoRef_1NoExig_BA	= 17;
                LET vCodigoRef_1Exig_BA		= 18;
				LET vCodigoRef_1Int_Vig_BA	= 19;
                LET vCodigoRef_1Iva_Vig_BA	= 20;
                LET vCodigoRef_2NoExig_BA	= 25;
                LET vCodigoRef_2Exig_BA		= 26;
                LET vCodigoRef_2NoExig_BT	= 27;
                LET vCodigoRef_2Exig_BT		= 28;
                LET vCodigoRef_2Int_Venc_BA = 29;
                LET vCodigoRef_2Iva_Venc_BA	= 30;
                LET vCodigoRef_2Int_Vig_BA	= 31;
                LET vCodigoRef_2Iva_Vig_BA	= 32;
                LET vCodigoRef_2Int_Venc_BT	= 33;
                LET vCodigoRef_2Iva_Venc_BT	= 34;
                LET vCodigoRef_2Int_Vig_BT	= 35;
                LET vCodigoRef_2Iva_Vig_BT	= 36;
                LET vCodigoRef_3NoExig_BA	= 37;
                LET vCodigoRef_3Exig_BA		= 38;
                LET vCodigoRef_3NoExig_BT	= 39;
                LET vCodigoRef_3Exig_BT		= 40;
                LET vCodigoRef_3Int_Venc_BA = 41;
                LET vCodigoRef_3Iva_Venc_BA	= 42;
                LET vCodigoRef_3Int_Vig_BA	= 43;
                LET vCodigoRef_3Iva_Vig_BA	= 44;
                LET vCodigoRef_3Int_Venc_BT = 45;
                LET vCodigoRef_3Iva_Venc_BT	= 46;
                LET vCodigoRef_3Int_Vig_BT	= 47;
                LET vCodigoRef_3Iva_Vig_BT	= 48;

                LET vCodigoRef_3NoExig_VP	= 49;
                LET vCodigoRef_3Exig_VP		= 50;
                LET vCodigoRef_3Int_Venc_VP = 51;
                LET vCodigoRef_3Iva_Venc_VP	= 52;
                LET vCodigoRef_3Int_Vig_VP	= 53;
                LET vCodigoRef_3Iva_Vig_VP	= 54;
                
                    

            --BEGIN WORK;

                IF estatusCred = 'AA' THEN
                    
                    IF dCapVig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred,vCodigoRef_1NoExig_AA,"500",fecha_mov, dCapVig, Folio,vsucursal, vdivisa, "0000",'MONTO CAPITAL VIGENTE POSITIVO','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIntVig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_1Int_Vig_AA,"500",fecha_mov,dIntVig, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES VIGENTE','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIvaIntVig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_1Iva_Vig_AA,"500",fecha_mov,dIvaIntVig, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES IVA VIGENTE','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;

                ELIF (estatusCred = 'BA' AND etapaCred='E1') THEN
                    
                    IF dCapVig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred,vCodigoRef_1NoExig_BA,"500",fecha_mov, dCapVig, Folio,vsucursal, vdivisa, "0000",'MONTO CAPITAL VIGENTE POSITIVO','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dCapTrans > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred,vCodigoRef_1Exig_BA,"500",fecha_mov,dCapTrans, Folio,vsucursal, vdivisa, "0000",'MONTO VENCIDO','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
					IF dIntVig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_1Int_Vig_BA,"500",fecha_mov,dIntVig, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES VIGENTE','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIvaIntVig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_1Iva_Vig_BA,"500",fecha_mov,dIvaIntVig, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES IVA VIGENTE','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;

                ELIF (estatusCred = 'BA' AND etapaCred='E2') THEN

                    IF dCapVig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred,vCodigoRef_2NoExig_BA,"500",fecha_mov, dCapVig, Folio,vsucursal, vdivisa, "0000",'MONTO CAPITAL VIGENTE POSITIVO','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dCapTrans > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred,vCodigoRef_2Exig_BA,"500",fecha_mov,dCapTrans, Folio,vsucursal, vdivisa, "0000",'MONTO VENCIDO','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
					IF dIntVig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_2Int_Vig_BA,"500",fecha_mov,dIntVig, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES VIGENTE','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIvaIntVig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_2Iva_Vig_BA,"500",fecha_mov,dIvaIntVig, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES IVA VIGENTE','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIntVdo > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_2Int_Venc_BA,"500",fecha_mov,dIntVdo, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES VENCIDO','')
                        RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIvaIntVdo > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_2Iva_Venc_BA,"500",fecha_mov,dIvaIntVdo, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES IVA VENCIDO','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;

                ELIF (estatusCred = 'BT' AND etapaCred='E2') THEN
                    
                    IF dCapVdoNoExig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_2NoExig_BT,"500",fecha_mov,dCapVdoNoExig, Folio,vsucursal, vdivisa, "0000",'MONTO CAPITAL VENCIDO NO EXIGIBLE','')
                        RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dCapVdoExig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_2Exig_BT,"500",fecha_mov,dCapVdoExig, Folio,vsucursal, vdivisa, "0000",'MONTO CAPITAL VENCIDO EXIGIBLE','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIntVig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_2Int_Vig_BT,"500",fecha_mov,dIntVig, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES VIGENTE','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIvaIntVig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_2Iva_Vig_BT,"500",fecha_mov,dIvaIntVig, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES IVA VIGENTE','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIntVdo > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_2Int_Venc_BT,"500",fecha_mov,dIntVdo, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES VENCIDO','')
                        RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIvaIntVdo > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_2Iva_Venc_BT,"500",fecha_mov,dIvaIntVdo, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES IVA VENCIDO','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;

                ELIF (estatusCred = 'BA' AND etapaCred='E3') THEN
                    
                    IF dCapVig > 0 THEN 
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_3NoExig_BA,"500",fecha_mov,dCapVig, Folio,vsucursal, vdivisa, "0000",'MONTO CAPITAL VENCIDO NO EXIGIBLE','')
                        RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dCapTrans > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_3Exig_BA,"500",fecha_mov,dCapTrans, Folio,vsucursal, vdivisa, "0000",'MONTO CAPITAL VENCIDO EXIGIBLE','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIntVig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_3Int_Vig_BA,"500",fecha_mov,dIntVig, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES VIGENTE','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIvaIntVig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_3Iva_Vig_BA,"500",fecha_mov,dIvaIntVig, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES IVA VIGENTE','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIntVdo > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_3Int_Venc_BA,"500",fecha_mov,dIntVdo, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES VENCIDO','')
                        RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIvaIntVdo > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_3Iva_Venc_BA,"500",fecha_mov,dIvaIntVdo, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES IVA VENCIDO','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;

                ELIF (estatusCred = 'BT' AND etapaCred='E3') THEN

                    IF dCapVdoNoExig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_3NoExig_BT,"500",fecha_mov,dCapVdoNoExig, Folio,vsucursal, vdivisa, "0000",'MONTO CAPITAL VENCIDO NO EXIGIBLE','')
                        RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dCapVdoExig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_3Exig_BT,"500",fecha_mov,dCapVdoExig, Folio,vsucursal, vdivisa, "0000",'MONTO CAPITAL VENCIDO EXIGIBLE','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIntVig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_3Int_Vig_BT,"500",fecha_mov,dIntVig, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES VIGENTE','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIvaIntVig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_3Iva_Vig_BT,"500",fecha_mov,dIvaIntVig, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES IVA VIGENTE','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIntVdo > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_3Int_Venc_BT,"500",fecha_mov,dIntVdo, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES VENCIDO','')
                        RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIvaIntVdo > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_3Iva_Venc_BT,"500",fecha_mov,dIvaIntVdo, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES IVA VENCIDO','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;

                ELIF etapaCred='VP' THEN

                    IF dCapVdoNoExig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_3NoExig_VP,"500",fecha_mov,dCapVdoNoExig, Folio,vsucursal, vdivisa, "0000",'MONTO CAPITAL VENCIDO NO EXIGIBLE','')
                        RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dCapVdoExig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_3Exig_VP,"500",fecha_mov,dCapVdoExig, Folio,vsucursal, vdivisa, "0000",'MONTO CAPITAL VENCIDO EXIGIBLE','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIntVig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_3Int_Vig_VP,"500",fecha_mov,dIntVig, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES VIGENTE','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIvaIntVig > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_3Iva_Vig_VP,"500",fecha_mov,dIvaIntVig, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES IVA VIGENTE','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIntVdo > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_3Int_Venc_VP,"500",fecha_mov,dIntVdo, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES VENCIDO','')
                        RETURNING cCod_ret,cMensajeRet;
                    END IF;
                    IF dIvaIntVdo > 0 THEN
                        CALL "informix".genmovcrd_ifrs(pEmpresa,vnum_credito,NumProductoCred, vCodigoRef_3Iva_Venc_VP,"500",fecha_mov,dIvaIntVdo, Folio,vsucursal, vdivisa, "0000",'MONTO INTERES IVA VENCIDO','')
                            RETURNING cCod_ret,cMensajeRet;
                    END IF;

                END IF;

                IF (etapaCred = 'E3' or etapaCred = 'VP') THEN
                    
                    FOREACH WITH HOLD
                        select fecha_cuota
                            INTO vfecha_cuota
                            FROM "informix".sd_amortiza_creditocrd
                          WHERE empresa     = pEmpresa
                            AND num_credito = vnum_credito
                            AND capital_status IN ('7','2') 

                        UPDATE bdicred:sd_amortiza_creditocrd SET capital_status='6', capital_status_ant = '2'
                            WHERE empresa = pEmpresa AND num_credito = vnum_credito AND fecha_cuota=vfecha_cuota and capital_status in ('7','2');
                    END FOREACH; 

                    IF etapaCred = 'VP' THEN

                        UPDATE bdicred:sd_amortiza_creditocrd SET campo_trabajo3 = 'V'
                            WHERE empresa = pEmpresa AND num_credito = vnum_credito and capital_status <> '3';

                    END IF;

                END IF;

                UPDATE bdicred:sd_maesdoscrd SET atr=v_atr, sdo_capital = sdo_capital + dCapVdoNoExig, monto_vencido = monto_vencido + dCapVdoExig, cap_tras_no_venci=0, mto_venc_trasp=0
                    WHERE empresa = pEmpresa AND num_credito = vnum_credito;
                    

                UPDATE bdicred:sd_maecredcrd SET status_cred=etapaCred
                    WHERE empresa = pEmpresa and num_credito = vnum_credito;

                INSERT INTO bdicred:etapas_cred(empresa, tipo, num_producto, sucursal, num_credito, etapa, status_cred, act, dias_act, atr, dias_atr, 
                             IntVig, IvaIntVig, IntVdo, IvaIntVdo) 
	                VALUES('001', '2', NumProductoCred, vsucursal, vnum_credito, etapaCred, estatusCred, vimpagos_consec_h, vdias_atraso_h,v_atr, vdias_atraso_ind,
                            dIntVig, dIvaIntVig, dIntVdo, dIvaIntVdo);   

				LET contador_commit = contador_commit + 1;
			
            --COMMIT WORK;    
			

            LET vimpagos_consec_h     = 0;
            LET vimpagos_consec_ch     = 0;
            LET vdias_atraso_h = 0;
            LET vdias_atraso_ch = 0;
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