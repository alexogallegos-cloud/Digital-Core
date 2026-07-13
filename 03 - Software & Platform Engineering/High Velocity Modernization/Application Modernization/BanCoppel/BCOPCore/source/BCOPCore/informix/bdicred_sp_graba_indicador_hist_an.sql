CREATE PROCEDURE "informix".sp_graba_indicador_hist_an()  
       returning char(5) ,CHAR(100),char(60);
   
---pIndicador  0 Corte, 1 Mensual

--declaracion de variables
------------------------------------------------------------
DEFINE	sql_err			INTEGER;
DEFINE	isam_err		INTEGER;
DEFINE	error_info		CHAR(150);
DEFINE	cMensaje		CHAR(80);
DEFINE	cCod_ret		CHAR(6);


--DEFINE	vIndicador		LIKE bdicred:sd_indicador_cred.row;
DEFINE	vPagoCliente	CHAR(1);
DEFINE	vcantReg		SMALLINT;
------------------------------------------------
------------------------------------------------
DEFINE	vtipotrans			char(1);
DEFINE	vlSentido		    char(1);
DEFINE  vlTransaccion		CHAR(4);
DEFINE vMtoReversion		DECIMAL(16,2);
DEFINE	vlfult_respaldo		DATE;

DEFINE vFecha               DATE; 
DEFINE vlCredito            CHAR(20);
DEFINE vlIndicador          SMALLINT;



DEFINE vTransPrimerCompra 	CHAR(4);
DEFINE vfecPrimerDisp		DATE; 
DEFINE vMontoPrimerDisp		DECIMAL(16,2); 
DEFINE vTransPrimerDisp		CHAR(4);
DEFINE vFolioPosDisp		CHAR(16);  
DEFINE vFolioAtmDisp		CHAR(16);  
DEFINE vFolioVntDisp		CHAR(16); 		  			  
DEFINE vFecUltPago			DATE; 
DEFINE vMtoUltPago			DECIMAL(16,2);
DEFINE vTransUltPago		CHAR(4);	
DEFINE vFolioUltPago		CHAR(16); 
DEFINE vAtmDispMto			DECIMAL(16,2);
DEFINE vAtmDispFec			DATE;
DEFINE vAtmDispTransacc		CHAR(4);
DEFINE vPosDispMto			DECIMAL(16,2);
DEFINE vPosDispFecha		DATE;
DEFINE vPosDispTransacc		CHAR(4);
DEFINE vvntDispMto			DECIMAL(16,2);
DEFINE vvntDispFec			DATE; 
DEFINE vFecUltPagoRev		DATE; 
DEFINE vMtoUltPagoRev		DECIMAL(16,2);      
DEFINE vTransUltPagoRev		CHAR(4);
DEFINE UltPagoRev		CHAR(16); 
DEFINE vatmDispMtoRev		DECIMAL(16,2);
DEFINE vAtmDispFecRev		DATE;
DEFINE vAtmDispTransaccRev	CHAR(4);
DEFINE vFolioAtmDispRev		CHAR(16); 
DEFINE vPosDispMtoRev		DECIMAL(16,2);
DEFINE vPosDispFecRev		DATE;
DEFINE vPosDispTransaccRev	CHAR(4); 
DEFINE vFolioPosDispRev		CHAR(16); 	    
DEFINE vvntDispMtoRev		DECIMAL(16,2);
DEFINE vvntDispFecRev		DATE; 
DEFINE vFolioVntDispRev		CHAR(16);
DEFINE vfolioultpagorev		CHAR(16);
DEFINE vRevPAGO				CHAR(1);
DEFINE vRevATM				CHAR(1);
DEFINE vRevPOS				CHAR(1);
DEFINE vRevVTN				CHAR(1);
DEFINE vlnum_avisos         CHAR(1);
DEFINE vlSaldoMaximo		DECIMAL (16,2);
DEFINE	pEmpresa	char(3);

DEFINE  vMtoAcumulado	DECIMAL(18,2);
DEFINE	vNumTrans	INTEGER;
DEFINE	bContinua	Char(1);
DEFINE	vlNumVencidos		SMALLINT;

DEFINE vdias_atraso  smallint;
DEFINE vdias_atraso_mar  smallint;
DEFINE v_periodos_incumplimiento DECIMAL(18,2); 
DEFINE v_incumplimiento  DECIMAL(18,2);
DEFINE v_incumplimiento_old DECIMAL(18,2);
DEFINE vstatus_fin	char(2);
--vPagoCliente|| '-Indicador-'||pIndicador||'-vtipotrans-'|| vtipotrans  

DEFINE pPeriodo date;
DEFINE pPeriodo_ant date;
DEFINE vfecha_proceso	date;
DEFINE cMtoVen DECIMAL(18,2);
------------------------------------------------

  --SET DEBUG FILE TO '/RESPALDOS/INFOSAT/RIESGOS/AN/INDICADORES/sp_graba_indicador_an.out';
  --TRACE ON;

    LET cCod_ret      = '00000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = '';
	LET cMensaje      = 'RESPALDO INDICADODES ANTICIPO EXITOSO';	
	
	LET vPagoCliente  = '';
	
	
	LET vtipotrans = '';		
	
	LET vTransPrimerCompra 	='';
	LET vfecPrimerDisp		=DATE(1);
	LET vMontoPrimerDisp	=0;
	LET vTransPrimerDisp	='';
	LET vFolioUltPago		='';
	LET vFolioPosDisp		='';
	LET vFolioAtmDisp		='';
	LET vFolioVntDisp		='';
	LET vFecUltPago			=DATE(1);
	LET vMtoUltPago			=0;
	LET vTransUltPago		='';
	LET vFolioUltPago		='';
	LET vAtmDispMto			=0;
	LET vAtmDispFec			=DATE(1);
	LET vAtmDispTransacc	='';
	LET vFolioAtmDisp		='';
	LET vPosDispMto			=0;
	LET vPosDispFecha		=DATE(1);
	LET vPosDispTransacc	='';
	LET vvntDispMto			=0;
	LET vvntDispFec			=DATE(1);	
	LET vFecUltPagoRev		=DATE(1);
	LET vMtoUltPagoRev		=0;
	LET vTransUltPagoRev	='';
	LET vFolioUltPagoRev	='';
	    
	LET vatmDispMtoRev		=0;
	LET vAtmDispFecRev		=DATE(1);
	LET vAtmDispTransaccRev	='';
	LET vFolioAtmDispRev	='';
	LET vPosDispMtoRev		=0;
	LET vPosDispFecRev		=DATE(1);
	LET vPosDispTransaccRev	='';
	LET vFolioPosDispRev	='';
	LET vvntDispMtoRev		=0;
	LET vvntDispFecRev		=DATE(1);
	LET vFolioVntDispRev	='';	
	LET bContinua = 'V';		
	LET vlSentido = '';
	LET vMtoReversion = 0;  
	LET	vlNumVencidos = 0;
	LET vRevPAGO = '';
	LET vRevATM = '';
	LET vRevPOS = '';
	LET vRevVTN = '';
    LET vlnum_avisos = 0;
	LET vlSaldoMaximo = 0.0;
	let pEmpresa = '001';
    LET vlIndicador = 10;
	
	
	LET vdias_atraso = 0;
	LET vdias_atraso_mar   = 0;
	LET v_periodos_incumplimiento  = 0;
	LET v_incumplimiento  = 0;
	LET v_incumplimiento_old  = 0;
	LET vstatus_fin = '';
	
	LET pPeriodo = date(0);
	LET pPeriodo_ant = date(0);
	LET vfecha_proceso = date(0);
	LET cMtoVen = 0;
BEGIN
        ON EXCEPTION SET sql_err, isam_err, error_info
            LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			--insert into bdicobranza:cb_bitacora (mensaje) values  (error_info);		
           -- RETURN cCod_ret;
			RETURN cCod_ret,vlCredito,cMensaje;
        END EXCEPTION;		
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;		
		
--		SELECT  pri_dia_mes - 1 units day, (pri_dia_mes -1 units month)-1 units day
	--	INTO  pPeriodo, pPeriodo_ant
		SELECT mdy(month(prox_fecha),'01',year(prox_fecha))
		INTO vfecha_proceso
		FROM bdicred:sd_fechas;
		
		LET pPeriodo =  vfecha_proceso- 1 units day;
		LET pPeriodo_ant = (vfecha_proceso -1 units month)-1 units day;

			FOREACH WITH HOLD
				select a.num_credito , status_cred
				into vlCredito,  vstatus_fin
				from bdicred:sd_maecredcont  a inner join sd_indicador_cred b
				on a.empresa = b.empresa and a.num_Credito = b.num_credito
				where fecha = pPeriodo
				and num_producto = '7800'
				and a.num_Credito not in (select num_Credito from sd_indicador_cred_hist where fecha = pPeriodo )
				
				--IFRS
				Select NVL(monto_vencido + mto_venc_trasp,0) into cMtoVen From bdicred:sd_maesdoscont Where fecha = pPeriodo and empresa = '001' and num_credito = vlCredito;
				
				--Incumplimientos						
				select moras_hist_h into v_periodos_incumplimiento
				from sd_indicador_cred_hist
				where fecha = pPeriodo_ant
				and num_credito = vlCredito; 

				IF v_periodos_incumplimiento is null THEN
					LET v_periodos_incumplimiento = 0;
				END IF;	

				IF (cMtoVen > 0) THEN	
					LET v_periodos_incumplimiento = v_periodos_incumplimiento + 1;  				
				END IF;	
				
				 
					BEGIN WORK;
					INSERT INTO sd_indicador_cred_hist			
					(empresa,   fecha,  num_credito,    num_vencidos,   fecha_ultimo_pago,  monto_ultimo_pago,
					fecha_ultima_compra,   monto_ultima_compra,        atm_disp_monto,     atm_disp_fecha , 
					atm_disp_transacc,     pos_disp_monto,             pos_disp_fecha,     pos_disp_transacc,
					vnt_disp_monto,        vnt_disp_fecha,             saldo_maximo,       fecha_sdo_maximo, 
					saldo_max_facturado,   pago_mayor, num_atm,        monto_atm,          num_pos,    
					monto_pos,             num_vtn,                    monto_vtn,          num_pagos,
					monto_pagos,           monto_ult_convenio  ,       fecha_ult_convenio, comportamiento,dias_atraso,impagos_consec_h,moras_hist_h,
					
					sdo_tot_liquidar, pago_minimo, sdo_tot_vencido, limite_credito, comision_anualidad, fecha_comision_anualidad,
					--comision_disp_efectivo, comision_apertura, fecha_comision_apertura, monto_devoluciones,
					comision_disp_efectivo_ch, comision_apertura, fecha_comision_apertura, monto_devoluciones,
					monto_otras_trnx, total_comisiones, max_mora_hist, saldo_maximo_hist, num_veces_mora1, num_veces_mora2,
					num_veces_mora3, num_veces_mora4, peor_mora_12m, fecha_ultima_mora, fecha_promesa_rota, num_pagos_hist,
					num_convenios_hist, promesa_pago, dias_act)
					select   
					empresa,   pPeriodo,  num_credito,    num_vencidos_his,   fecha_ultimo_pago_h,  monto_ultimo_pago_h,
					fecha_ultima_compra_h,   monto_ultima_compra_h,        atm_disp_monto_h,     atm_disp_fecha_h , 
					atm_disp_transacc_h,     pos_disp_monto_h,             pos_disp_fecha_h,     pos_disp_transacc_h,
					vnt_disp_monto_h,        vnt_disp_fecha_h,             saldo_maximo_h,       fecha_sdo_maximo_h, 
					saldo_max_facturado_h,   pago_mayor_h, num_atm_h,        monto_atm_h,          num_pos_h,    
					monto_pos_h,             num_vtn_h,                    monto_vtn_h,          num_pagos_h,
					monto_pagos_h,           monto_ult_convenio_h,			fecha_ult_convenio_h,comportamiento,dias_atraso,impagos_consec_h,v_periodos_incumplimiento,
					sdo_tot_liquidar_h, pago_minimo_h, sdo_tot_vencido_h, limite_credito_h, comision_anualidad, fecha_comision_anualidad,
					--comision_disp_efectivo, comision_apertura, fecha_comision_apertura, monto_devoluciones,
					comision_disp_efectivo_ch, comision_apertura, fecha_comision_apertura, monto_devoluciones,
					monto_otras_trnx, total_comisiones, max_mora_hist, saldo_maximo_hist, num_veces_mora1, num_veces_mora2,
					num_veces_mora3, num_veces_mora4, peor_mora_12m, fecha_ultima_mora, fecha_promesa_rota, num_pagos_hist,
					num_convenios_hist, promesa_pago, dias_act
					FROM "informix".sd_indicador_cred
					WHERE empresa = pEmpresa
					  and num_credito = vlCredito;  
					  
					
					update 	sd_indicador_cred set fecha_ult_respaldo = pPeriodo
					WHERE empresa = pEmpresa
					  and num_credito = vlCredito;  	  
		  
					COMMIT WORK;  
			
			END FOREACH;     
		--END IF;
		--insert into bdicobranza:cb_bitacora (mensaje) values  (pCodigoFun||'-Primer Compra-'||pTransacc);		
		---Consulta indicadores que pueden tener reversiÃ³n
    RETURN cCod_ret,cMensaje,'';
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se generan los indicadores_historicos de anticipo de nomina',
'AUTOR : Pamela CÃ¡rdemas',
'FECHA : 2019/06/12';

CREATE PROCEDURE "informix".sp_menos_plazocrd(p_Empresa     CHAR(3),
                                           p_NumCredito  CHAR(20),
                                           p_Monto       MONEY(14,2))

   RETURNING CHAR(5),     -- Codigo de Retorno
             MONEY(14,2); -- Remanente

   DEFINE GLOBAL g_SdoRetenido     MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_StCred          CHAR(2)       DEFAULT ' ';
   DEFINE GLOBAL g_Remanente     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Cubre_Cuota     CHAR(1)       DEFAULT ' ';

   DEFINE  CodRet            CHAR(5);
   DEFINE  v_fcuota          DATE;
   DEFINE  vMtoPagado        MONEY(14,2);
   DEFINE  vMtoInteres       MONEY(14,2);
   DEFINE  vFechaHoy         date;
   DEFINE  vNumPag           INTEGER;
   DEFINE   vStatus           CHAR(1);

   --SET DEBUG FILE TO "/tmp/menosplazo.out";
   --TRACE ON;

   LET CodRet     = "000";
   let vFechaHoy  = '';
   LET vNumPag    = 0;
   LET vStatus    = '';
   LET g_Cubre_Cuota = '0';

   SELECT fecha_hoy INTO vFechaHoy FROM sd_fechas WHERE empresa = p_Empresa;
   FOREACH
         SELECT fecha_cuota INTO v_fcuota FROM sd_amortiza_creditocrd
         WHERE empresa = p_Empresa and num_credito = p_NumCredito and
               capital_status  IN ("1","2","3","6") 
         Order by fecha_cuota  DESC
         IF g_Remanente > 0 THEN
            IF g_StCred IN ("VP","BT","E3") THEN
               CALL cobracapvencidocrd(v_fcuota) RETURNING CodRet;
            ELSE
               CALL cobracapvigentecrd (v_fcuota) RETURNING CodRet;
            END IF;
            IF CodRet <> '000' THEn
               Return CodRet,g_Remanente;
{            ELSE
               Let vNumPag  = vNumPag + 1;
               UPDATE sd_amortiza_creditocrd set capital_status = '5',
                                           capital_status_ant = '3'
               wHERE num_credito = p_Numcredito and empresa = p_Empresa and fecha_cuota = v_fcuota;}
            END IF;
         END IF;
    END FOREACH;
 return CodRet,g_Remanente;

END PROCEDURE
;