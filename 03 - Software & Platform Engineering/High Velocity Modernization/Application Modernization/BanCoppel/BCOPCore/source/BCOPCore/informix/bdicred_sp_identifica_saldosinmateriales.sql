CREATE PROCEDURE "informix".sp_identifica_saldosinmateriales(pEmpresa CHAR(3) )

RETURNING CHAR(5),     -- Codigo de Retorno
          CHAR(80);   -- Mensaje de retorno
		    

---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(5);
DEFINE cMensajeRet		CHAR(80);

DEFINE iDiasVencido	    INTEGER;
DEFINE iMontoVencido	INTEGER;
DEFINE cNumcte 			CHAR(20);
DEFINE cNumCred 		CHAR(20);
DEFINE cRuta 			CHAR(100);
DEFINE cNum_producto	CHAR(4);
---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_bloqueocuenta
DEFINE cBCCodret		CHAR(6);   
DEFINE CBCMensajeRet	CHAR(80); 
-----

DEFINE cNomCte     	CHAR(150);
define wdiacorte        SMALLINT;
define iBandera         INT8;
define dtFechaHoy DATE;
---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
DEFINE cCsg_codigo_ret			CHAR(6);
DEFINE cCsg_mensaje_ret			CHAR(80);
DEFINE cCsg_num_credito			CHAR(20);
DEFINE cCsg_cod_tipcred			CHAR(2);
DEFINE cStatus					CHAR(2);
DEFINE cAct                     INTEGER;
DEFINE cAtr                     INTEGER;
DEFINE dtCsg_fec_origen			DATE;
DEFINE dtCsg_fec_prox_pago		DATE;
DEFINE mCsg_pago_min			MONEY(18,2);
DEFINE dtCsg_fec_ult_pago		DATE;
DEFINE iCsg_plazo				INTEGER;
DEFINE iCsg_pagos_realizados	INTEGER;
DEFINE mCsg_linea_otorgada		MONEY(18,2);
DEFINE mCsg_tasa_interes			DECIMAL(9,6);
DEFINE dCsg_tasa_moratorios		DECIMAL(9,6);
DEFINE dCsg_monto_sbc			DECIMAL(14,2);
DEFINE mCsg_cap_vig				MONEY(18,2);
DEFINE mCsg_cap_trans			MONEY(18,2);
DEFINE mCsg_cap_vdo_exig		MONEY(18,2);
DEFINE mCsg_cap_vdo_no_exig		MONEY(18,2);
DEFINE mCsg_sdo_act_total_cap	MONEY(18,2);
DEFINE mCsg_int_vig				MONEY(18,2);
DEFINE mCsg_int_vdo				MONEY(18,2);
DEFINE mCsg_int_moratorios		MONEY(18,2);
DEFINE mCsg_int_mes				MONEY(18,2);
DEFINE mCsg_sdo_act_total_int	MONEY(18,2);
DEFINE mCsg_iva_int_vig			MONEY(18,2);
DEFINE mCsg_iva_int_vdo			MONEY(18,2);
DEFINE mCsg_iva_int_moratorios	MONEY(18,2);
DEFINE mCsg_iva_int_mes			MONEY(18,2);
DEFINE mCsg_sdo_act_total_iva	MONEY(18,2);
DEFINE mCsg_com_pend			MONEY(18,2);
DEFINE mCsg_iva_com				MONEY(18,2);
DEFINE mCsg_sdo_retenido		MONEY(18,2);
DEFINE mCsg_tot_liquidacion		MONEY(18,2);
DEFINE mCsg_int_devengado		MONEY(18,2);
DEFINE mCsg_iva_int_devengado	MONEY(18,2);
DEFINE mCsg_linea_disp			MONEY(18,2);
DEFINE mCsg_pagos_vdos			MONEY(18,2);
DEFINE cCsg_desc_status_cred	CHAR(60);
DEFINE iCsg_id_bloqueo_cred		INTEGER;
DEFINE cCsg_bloqueo_cta			CHAR(60);
DEFINE cCsg_id_causa_bloq_cred	CHAR(3);
DEFINE cCsg_causa_bloqueo_cta	CHAR(50);
DEFINE cCsg_id_sit_esp_cte		CHAR(1);
DEFINE iCsg_id_causa_esp_cte	INTEGER;
DEFINE cCsg_sit_esp_cte			CHAR(75);
DEFINE cCsg_id_sit_esp_cred		CHAR(1);
DEFINE iCsg_id_causa_esp_cred	INTEGER;
DEFINE cCsg_sit_esp_cred		CHAR(75);

DEFINE vInteresVencido_bal		MONEY(18,2);
DEFINE vIvaInteresVencido_bal		MONEY(18,2);
DEFINE vInteresVencido	MONEY(18,2);
DEFINE vIvaInteresVencido			MONEY(18,2);
DEFINE vMontoLineaNoDispuesta			MONEY(18,2);

DEFINE cSql            	CHAR(2500);
DEFINE cNombreArchivo  	CHAR(100);
DEFINE cNombreArchivo1  CHAR(100);
DEFINE cConsulta		CHAR(2300);
DEFINE cEncabezado		CHAR(600);

DEFINE psaldoInteresApoyo DECIMAL(14,2);
DEFINE psaldoIvaApoyo 	DECIMAL(14,2);

DEFINE v_fecha_vencido  DATE;
DEFINE v_num_vencidos   INTEGER;
DEFINE dPagosVdos       INTEGER;
DEFINE v_dias_vencido   INTEGER;    
DEFINE dUltDisp_atm     DATE;
DEFINE dUltDisp_pos     DATE;
DEFINE dUltDisp_vnt     DATE;
DEFINE dUltima_Disposicion DATE;

---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '00000';
LET cMensajeRet			= 'Proceso Exitoso';
LET cNumcte 			= "";
LET cNumCred 			= "";
LET cRuta 				= "";
LET cNum_producto		= "";
LET cNomCte     		= "";
LET iDiasVencido		= 0;
LET iMontoVencido		= 0;
LET dtFechaHoy		    = DATE(1);
---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_bloqueocuenta
LET cBCCodret		= "";
LET CBCMensajeRet   = "";





---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
LET cCsg_codigo_ret				= "00000";
LET cCsg_mensaje_ret			= "";
LET cCsg_num_credito			= "";
LET cCsg_cod_tipcred			= "";
LET cStatus						= "";
LET cAct                        = 0;
LET cAtr                        = 0;
LET dtCsg_fec_origen			= MDY(1,1,1900);
LET dtCsg_fec_prox_pago			= MDY(1,1,1900);
LET mCsg_pago_min				= 0.0;
LET dtCsg_fec_ult_pago			= MDY(1,1,1900);
LET iCsg_plazo					= 0;
LET iCsg_pagos_realizados		= 0;
LET mCsg_linea_otorgada			= 0.0;
LET mCsg_tasa_interes			= 0.0;
LET dCsg_tasa_moratorios		= 0.0;
LET dCsg_monto_sbc				= 0.0;
LET mCsg_cap_vig				= 0.0;
LET mCsg_cap_trans				= 0.0;
LET mCsg_cap_vdo_exig			= 0.0;
LET mCsg_cap_vdo_no_exig		= 0.0;
LET mCsg_sdo_act_total_cap		= 0.0;
LET mCsg_int_vig				= 0.0;
LET mCsg_int_vdo				= 0.0;
LET mCsg_int_moratorios			= 0.0;
LET mCsg_int_mes				= 0.0;
LET mCsg_sdo_act_total_int		= 0.0;
LET mCsg_iva_int_vig			= 0.0;
LET mCsg_iva_int_vdo			= 0.0;
LET mCsg_iva_int_moratorios		= 0.0;
LET mCsg_iva_int_mes			= 0.0;
LET mCsg_sdo_act_total_iva		= 0.0;
LET mCsg_com_pend				= 0.0;
LET mCsg_iva_com				= 0.0;
LET mCsg_sdo_retenido			= 0.0;
LET mCsg_tot_liquidacion		= 0.0;
LET mCsg_int_devengado			= 0.0;
LET mCsg_iva_int_devengado		= 0.0;
LET mCsg_linea_disp				= 0.0;
LET mCsg_pagos_vdos				= 0.0;
LET cCsg_desc_status_cred		= "";
LET iCsg_id_bloqueo_cred		= 0;
LET cCsg_bloqueo_cta			= "";
LET cCsg_id_causa_bloq_cred		= "";
LET cCsg_causa_bloqueo_cta		= "";
LET cCsg_id_sit_esp_cte			= "";
LET iCsg_id_causa_esp_cte		= 0;
LET cCsg_sit_esp_cte			= "";
LET cCsg_id_sit_esp_cred		= "";
LET iCsg_id_causa_esp_cred		= 0;
LET iBandera		= 0;
LET cCsg_sit_esp_cred			= "";


LET vInteresVencido_bal		= 0;
LET vIvaInteresVencido_bal		= 0;
LET vInteresVencido = 0;
LET vIvaInteresVencido			= 0;
LET vMontoLineaNoDispuesta			= 0;

LET cSql			= '';
LET cNombreArchivo  = '';
LET cNombreArchivo1  = '';
LET cConsulta		= '';
LET cEncabezado		= '';

LET psaldoInteresApoyo 	= 0;
LET psaldoIvaApoyo 		= 0;

LET v_fecha_vencido  = DATE(1);
LET v_num_vencidos   =0;
LET dPagosVdos       =0;
LET v_dias_vencido   =0;  
LET dUltDisp_atm  = DATE(1);
LET dUltDisp_pos  = DATE(1);
LET dUltDisp_vnt  = DATE(1);
LET dUltima_Disposicion = DATE(1);

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = iIsamErr;
          RETURN cCodRet, cMensajeRet;
       END IF;
    END EXCEPTION;
	
	--SET LOCK MODE TO WAIT 3;
    --SET ISOLATION TO COMMITTED READ LAST COMMITTED;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
    
	
	IF NVL(pEmpresa,'') = ''  THEN
		LET cCodRet	= '00001';
		LET cMensajeRet	= 'PARAMETRO DE ENTRADA INVALIDOS';
		RETURN cCodRet,cMensajeRet;
	END IF;
    --RUTA PARA GENERAR EL ARCHIVO
	SELECT valor
	INTO cRuta
	FROM "informix".sd_param  
	WHERE empresa = '001' 
	AND cod_param='081';
	
	--let cRuta = '/ifxsif01/PEDRO_PRUEBAS/reportes_pruebas/';----PRUEBA
	--SINO EXISTE LA RUTA DEL ARCHIVO	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00001';
		LET cMensajeRet ='NO EXISTE PARAMETRO DE LA RUTA PARA GENERAR EL ARCHIVO';
		RETURN cCodRet,cMensajeRet;
	END IF;	 

	-- OBTIENE LA FECHA DEL DIA
	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM "informix".sd_fechas
	WHERE empresa = '001';
	
	--Let dtFechaHoy = mdy('06','21','2022'); -- fecha de prueba 
	
	--SET DEBUG FILE TO "/ifxsif01/PEDRO_PRUEBAS/sps_pruebas/sp_identifica_saldosinmaterialesv1.out";
	--TRACE ON;	
	
	--Saldo para reporte de saldos inmateriales
	SELECT valor
	INTO iMontoVencido
	FROM "informix".sd_param  
	WHERE empresa = '001' 
	AND cod_param='083';
	
	
	---NO EXISTE PARAMETRO SALDO PARA REPORTE DE SALDOS INMATERIALES
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00003';
		LET cMensajeRet ='NO EXISTE PARAMETRO SALDO PARA REPORTE DE SALDOS INMATERIALES';
		RETURN cCodRet,cMensajeRet;
	END IF;	
	
	
		--dias de vencido reporte de saldos inmateriales
	SELECT valor
	INTO iDiasVencido
	FROM "informix".sd_param  
	WHERE empresa = '001' 
	AND cod_param='082';
                                                                                        
	
	---NO EXISTE PARAMETRO SALDO PARA REPORTE DE SALDOS INMATERIALES
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00003';
		LET cMensajeRet ='NO EXISTE PARAMETRO SALDO PARA REPORTE DE SALDOS INMATERIALES';
		RETURN cCodRet,cMensajeRet;
	END IF;	
	
	--traspaso
	INSERT INTO sd_saldos_inmateriales_hist
	SELECT * FROM sd_saldos_inmateriales;
	
	TRUNCATE TABLE "informix".sd_saldos_inmateriales;
	
	----INI se realiza identificacion de los clientes a reportar para saldos inmateriales
	
	SELECT mae.numcte,mae.num_credito,mae.num_producto,mae.status_cred, dos.act, 0 as atr
	FROM "informix".sd_maecred mae, "informix".sd_maesdos dos
	WHERE mae.num_credito = dos.num_credito
	AND mae.empresa = dos.empresa
	---- Se agrega condiciÃÂ³n para no considerar el producto 7800
	AND mae.num_producto NOT IN (7800)
	AND dos.sdo_cap_insoluto > 0
	AND dos.sdo_cap_insoluto < iMontoVencido
	AND mae.campo_trab3 = ''
	AND dtFechaHoy  >= (SELECT NVL(MIN(fecha_cuota),dtFechaHoy) + iDiasVencido units day FROM "informix".sd_amortiza_credito  amort  
	WHERE  amort.empresa     = '001'  AND amort.num_credito = mae.num_credito
	AND amort.capital_status IN ('2','7','6') )	
	AND mae.status_cred not in ('FF','FC','CV')	
	UNION ALL
	--INICIO-- Se agrega bloque para incluir producto 7800 considerando monto total
	SELECT mae.numcte,mae.num_credito,mae.num_producto,mae.status_cred, dos.act, 0 as atr---,dos.sdo_cap_insoluto
	FROM "informix".sd_maecred mae, "informix".sd_maesdos dos
	WHERE mae.num_credito = dos.num_credito
	AND mae.empresa = dos.empresa
	AND mae.num_producto IN (7800)
	AND dos.sdo_cap_insoluto > 0
	--AND dos.sdo_cap_insoluto < 500 -- se elimina, se debe considerar todo el monto
	AND mae.campo_trab3 = ''
	AND dtFechaHoy  >= (SELECT NVL(MIN(fecha_cuota),dtFechaHoy) + iDiasVencido units day FROM "informix".sd_amortiza_credito  amort  
	WHERE  amort.empresa     = '001'  AND amort.num_credito = mae.num_credito
	AND amort.capital_status IN ('2','7','6') )	
	AND mae.status_cred not in ('FF','FC','CV')
	--FIN-- Se agrega bloque para incluir producto 7800 considerando monto total
	UNION ALL
	SELECT maecrd.numcte,maecrd.num_credito,maecrd.num_producto,maecrd.status_cred, 0 as act, doscrd.atr
	FROM "informix".sd_maecredcrd maecrd, "informix".sd_maesdoscrd doscrd 
	WHERE maecrd.num_credito = doscrd.num_credito
	AND doscrd.sdo_cap_insoluto > 0
	AND doscrd.sdo_cap_insoluto < iMontoVencido
	AND maecrd.campo_trab3 = ''
	AND dtFechaHoy  >= (SELECT  NVL(MIN(fecha_cuota),dtFechaHoy) + iDiasVencido units day FROM "informix".sd_amortiza_creditocrd  amorcrd2  
	WHERE  amorcrd2.empresa     = '001'  AND amorcrd2.num_credito = maecrd.num_credito
	AND amorcrd2.capital_status IN ('2','7','6') )
		AND maecrd.status_cred  not in ('FF','FC','CV')	
	INTO TEMP tme_saldosinmateriales WITH NO LOG;

	
	CREATE INDEX inx_cred_sdoinmaterial ON tme_saldosinmateriales (num_credito) ONLINE;
	CREATE INDEX inx_cte_sdoinmaterial ON tme_saldosinmateriales (numcte) ONLINE;
	
	
	UPDATE STATISTICS medium FOR TABLE tme_saldosinmateriales;
		
		
	--************ SE ELIMINAN CLIENTES EN PROCESO DE ACLARACION ************
	DELETE FROM  tme_saldosinmateriales WHERE numcte IN (SELECT  num_cliente		
													FROM bdiaclaracion:"informix".acl_aclaracion
													WHERE num_cliente  IN (SELECT  numcte FROM tme_saldosinmateriales)
													AND fky_estatus_aclaracion ='2');

	--************ SE ELIMINAN CLIENTES FALLECIDO ************
	
	DELETE FROM  tme_saldosinmateriales WHERE numcte IN ( SELECT numcte		
														FROM bdisitesp:"informix".se_ctessitespcte
														WHERE empresa = '001'
														AND numcte IN (SELECT  numcte FROM tme_saldosinmateriales)
														AND situacion = 'F'
														AND causa = 42);
													
	--************ SE ELIMINAN CLIENTES CON  UN COMPROMISO VIGENTE ************
	DELETE FROM  tme_saldosinmateriales WHERE num_credito IN (SELECT {+INDEX(bdicobranza:cb_compac idx_compac1)} numcuenta                  
													FROM bdicobranza:cb_compac 
													WHERE empresa = '001' 
													AND numcuenta IN (SELECT  num_credito FROM tme_saldosinmateriales)
													AND activo <> '0');
													
	
	
	
	----FIN se realiza identificacion de los clientes a reportar para saldos inmateriales
	FOREACH WITH HOLD
		SELECT  numcte,num_credito,num_producto,status_cred, act, atr
		INTO cNumcte,cNumCred,cNum_producto,cStatus, cAct, cAtr
		FROM tme_saldosinmateriales
		WHERE num_credito > ''
		
	

		-- OBTIENE LOS SALDOS DEL  TDC/PRESTAMO/REESTRUCTURA/CREDINOMINA
		EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa,cNumCred)
		INTO  cCsg_codigo_ret,cCsg_mensaje_ret,cCsg_num_credito,cCsg_cod_tipcred,dtCsg_fec_origen,dtCsg_fec_prox_pago,mCsg_pago_min,
			dtCsg_fec_ult_pago,iCsg_plazo,iCsg_pagos_realizados,mCsg_linea_otorgada,mCsg_tasa_interes,dCsg_tasa_moratorios,
			dCsg_monto_sbc,mCsg_cap_vig,mCsg_cap_trans,mCsg_cap_vdo_exig,mCsg_cap_vdo_no_exig,mCsg_sdo_act_total_cap,mCsg_int_vig,
			mCsg_int_vdo,mCsg_int_moratorios,mCsg_int_mes,mCsg_sdo_act_total_int,mCsg_iva_int_vig,mCsg_iva_int_vdo,mCsg_iva_int_moratorios,
			mCsg_iva_int_mes,mCsg_sdo_act_total_iva,mCsg_com_pend,mCsg_iva_com,mCsg_sdo_retenido,mCsg_tot_liquidacion,mCsg_int_devengado,
			mCsg_iva_int_devengado,mCsg_linea_disp,mCsg_pagos_vdos,cCsg_desc_status_cred,iCsg_id_bloqueo_cred,cCsg_bloqueo_cta,
			cCsg_id_causa_bloq_cred,cCsg_causa_bloqueo_cta,cCsg_id_sit_esp_cte,iCsg_id_causa_esp_cte,cCsg_sit_esp_cte,cCsg_id_sit_esp_cred,
			iCsg_id_causa_esp_cred,cCsg_sit_esp_cred;
		--IF cCsg_codigo_ret::INTEGER <> 0 OR mCsg_pagos_vdos < 6 THEN
			--LET cCodRet = '000005';
			--LET cMensajeRet= cCsg_mensaje_ret;
			--RETURN cCodRet,cMensajeRet;
		--CONTINUE FOREACH;
		--END IF
			
		--IF 	cNum_producto ="6001" THEN
		IF cNum_producto in ('6001','8500','7800','7000','8100') then 
			-- SE REALIZA EL BLOQUEO DE LA CUENTA
	
				UPDATE "informix".sd_maecred
					SET campo_trab3 ='INMATERIAL',
					id_unidad_prod ='1'
				WHERE empresa = pEmpresa
				AND num_credito = cNumCred;		
				
				SELECT monto_otorgado - (sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci)
				-- Se obtiene el monto de la LINEA DE CREDITO NO DISPUESTA
				INTO   vMontoLineaNoDispuesta
				FROM "informix".sd_maesdos               
				WHERE empresa        = pEmpresa
				AND num_credito      = cNumCred;            
			  
			
		ELSE		
			UPDATE "informix".sd_maecredcrd
				SET id_origen = 1, campo_trab3 ='INMATERIAL'
			WHERE empresa = pEmpresa
			AND num_credito = cNumCred;		
			
			
			IF cNum_producto = '6011' THEN 		
				--IF cStatus = 'BT'  THEN
				-- IFSR se ajusta para que contemple las etapas
				IF cStatus in ('BT','E2','E3')  THEN
					--creditos BT
					--balanza
					select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) 
					INTO vInteresVencido_bal, vIvaInteresVencido_bal
					from bdicred:sd_amortiza_creditocrd
					where empresa = pEmpresa
					and num_credito = cNumCred
					and capital_status in ('2','7','6')
					AND campo_trabajo3 = '';
					/*and fecha_cuota <= (
										select max(fecha_mov)
										from bdicred:sd_movhiscrd
										where empresa = pEmpresa
										and num_credito = cNumCred
										and codigo_fun = '601'
										and codigo_ref = 3
										and reversado = 'N');*/

					--orden
					select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0)
					INTO vInteresVencido, vIvaInteresVencido
					from bdicred:sd_amortiza_creditocrd
					where empresa = pEmpresa
					and num_credito = cNumCred
					and capital_status in ('2','7','6')
					AND campo_trabajo3 = 'V';
					/*and fecha_cuota > (
										select max(fecha_mov)
										from bdicred:sd_movhiscrd
										where empresa = pEmpresa
										and num_credito = cNumCred
										and codigo_fun = '601'
										and codigo_ref = 3
										and reversado = 'N');*/

				ELSE
					select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido, vIvaInteresVencido
					FROM bdicred:sd_amortiza_creditocrd
					WHERE empresa = pEmpresa
					AND num_credito= cNumCred
					AND capital_status in ('2','7','6');

				END IF;
			 ELSE
					 SELECT NVL(SUM(interes_debe - interes_pagado),0), NVL(SUM(iva_debe - iva_pagado),0) INTO vInteresVencido_bal, vIvaInteresVencido_bal
					from bdicred:sd_amortiza_creditocrd
					where empresa = pEmpresa
					and num_credito = cNumCred
					and capital_status in ('2','7','6')
					AND campo_trabajo3 = '';
					/*and fecha_cuota <= (
										select max(fecha_mov)
										from bdicred:sd_movhiscrd
										where empresa = pEmpresa
										and num_credito = cNumCred
										and codigo_fun = '026'
										and codigo_ref = 3
										and reversado = 'N');*/

					--orden
					--select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido, vIvaInteresVencido 08/06/2012 PARA PP POR RSS
					select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido, vIvaInteresVencido
					from bdicred:sd_amortiza_creditocrd
					where empresa = pEmpresa
					and num_credito = cNumCred
					and capital_status in ('2','7','6')
					AND campo_trabajo3 = 'V';
					/*and fecha_cuota > (
										select max(fecha_mov)
										from bdicred:sd_movhiscrd
										where empresa = pEmpresa
										and num_credito = cNumCred
										and codigo_fun = '026'
										and codigo_ref = 3
										and reversado = 'N');*/

			 
					IF cNum_producto in ('6300','7600','7700') THEN 
					
						--- se obtienen los  montos de INT e IVA de la maeretenido del programa de apoyo
						SELECT monto
							INTO psaldoInteresApoyo
						FROM bdicred:sd_maeretenido 
						WHERE num_credito = cNumCred
							AND transacc = '8374'
							AND estatus = 'R';

							IF psaldoInteresApoyo IS NULL THEN
								LET psaldoInteresApoyo = 0;
							END IF;

						SELECT monto
							INTO psaldoIvaApoyo
						FROM bdicred:sd_maeretenido 
						WHERE num_credito = cNumCred
							AND transacc ='8375'
							AND estatus = 'R';

						IF psaldoIvaApoyo IS NULL THEN
							LET psaldoIvaApoyo = 0;
						END IF;
				
						LET vInteresVencido_bal = vInteresVencido_bal + psaldoInteresApoyo;
						LET vIvaInteresVencido = vIvaInteresVencido + psaldoIvaApoyo;
				
					END IF;
				 
			 END IF;
			
		END IF;
			
		SELECT TRIM(apell_paterno)|| ' ' ||TRIM(apell_materno)||' '||TRIM(nombre1)||' '||TRIM(nombre2) Nombre_Cliente
		INTO cNomCte
		FROM bdinteg:"informix".si_cliente
		WHERE empresa = pEmpresa
		AND numcte = cNumcte;	
		
		--NUEVOS CAMPOS ADENDUM RQM 04 127
		IF cNum_producto in ('6001','8500','7800','7000','8100') then
            SELECT fecha_vencido, num_vencidos, dias_atraso, nvl(atm_disp_fecha_h,''), nvl(pos_disp_fecha_h,''), nvl(vnt_disp_fecha_h,'')
            INTO v_fecha_vencido, v_num_vencidos, v_dias_vencido, dUltDisp_atm, dUltDisp_pos, dUltDisp_vnt
            FROM sd_indicador_cred
            WHERE num_credito=cNumCred;
                        
            if dUltDisp_atm is null then let dUltDisp_atm = ''; end if;
            if dUltDisp_pos is null then let dUltDisp_pos = ''; end if;
            if dUltDisp_vnt is null then let dUltDisp_vnt = ''; end if;
            
            IF cNum_producto='7800' THEN
				SELECT MAX(fecha_mov) INTO dUltima_Disposicion
				FROM SD_MOVHIS
				where num_credito=cNumCred AND codigo_fun='002' AND codigo_ref=111;
			ELSE
				IF (dUltDisp_atm > dUltDisp_pos) THEN
					IF (dUltDisp_atm >= dUltDisp_vnt) THEN
					   LET dUltima_Disposicion = dUltDisp_atm;
					ELSE
					   LET dUltima_Disposicion = dUltDisp_vnt;
					END IF;
				ELIF (dUltDisp_atm = dUltDisp_pos) THEN    
					IF (dUltDisp_pos >= dUltDisp_vnt) THEN
						LET dUltima_Disposicion = dUltDisp_pos;
					ELSE
						LET dUltima_Disposicion = dUltDisp_vnt;
					END IF;
				END IF;
			END IF;
					
            
           /* SELECT COUNT(num_credito)
            INTO dPagosVdos
            FROM "informix".sd_amortiza_credito
            WHERE empresa     = pEmpresa
            AND num_credito = cNumCred
            AND capital_status IN ('2','7','6');*/  --QUITAR
        ELSE 
		    SELECT fecha_vencido, num_vencidos_ch, dias_atraso
            INTO v_fecha_vencido, v_num_vencidos, v_dias_vencido
            FROM sd_indicador_cred_crd
            WHERE num_credito=cNumCred;
			
			IF cNum_producto='6800' THEN
				SELECT MAX(fecha_insert) INTO dUltima_Disposicion
				FROM sd_maecredcrd_flex
				where num_credito=cNumCred;
			ELSE
				SELECT fecha_apertura INTO dUltima_Disposicion
				FROM sd_maecredcrd WHERE num_credito=cNumCred;
			END IF;

        END IF;
		
		
		
		INSERT INTO "informix".sd_saldos_inmateriales 
		(empresa,fecha_reporte,numcte ,num_credito ,nombre_cte ,estatus ,estatus_desc,saldo_capital,meses_vencidos ,
		vencido_exigible ,vencido_noexigible ,interes_vencido ,iva_interes_vencido ,interes_vencido_bal ,	
		iva_interes_vencido_bal ,	interes_vencido_orden ,	iva_interes_vencido_orden  ,interes_moratorio ,	iva_interes_moratorio ,
		saldo_total,lineanodispuesta ,	causa_cancelacion ,aplica_si  ,comentarios,user_insert ,fecha_insert, atr, act, fecha_vencido, 
		dias_vencido, fecha_ult_dispo)
		VALUES(pEmpresa,dtFechaHoy,cNumcte,cNumCred,cNomCte,cStatus,cCsg_desc_status_cred,mCsg_sdo_act_total_cap,mCsg_pagos_vdos,
		mCsg_cap_trans,mCsg_cap_vdo_exig, mCsg_int_vdo,mCsg_iva_int_vdo,vInteresVencido_bal, vIvaInteresVencido_bal,vInteresVencido,	vIvaInteresVencido,mCsg_int_moratorios,mCsg_iva_int_moratorios,mCsg_tot_liquidacion,vMontoLineaNoDispuesta,"SI","0","",USER,dtFechaHoy,
		cAtr, cAct, v_fecha_vencido,v_dias_vencido, dUltima_Disposicion);
		LET iBandera = iBandera +1;
		
		LET vInteresVencido_bal		= 0;
		LET vIvaInteresVencido_bal		= 0;
		LET vInteresVencido = 0;
		LET vIvaInteresVencido			= 0;
		LET vMontoLineaNoDispuesta			= 0;
		
		
	END FOREACH;
	
	
	--SET DEBUG FILE TO "/informix/jesus/sp_identifica_saldosinmateriales.out";
	--TRACE ON;	
	IF iBandera > 0 THEN
	
		--GENERA EL NOMBRE DEL ARCHIVO
		LET cNombreArchivo = TRIM('SaldosInmateriales')||TO_CHAR(dtFechaHoy,'%d%m%y')|| '.txt';
		LET cNombreArchivo1 = TRIM('SaldosInmateriales_aux')||TO_CHAR(dtFechaHoy,'%d%m%y')|| '.txt';
		
		--SELECCIONA LOS DATOS QUE FUERON INSERTADOS EN LA TABLA tme_rptmensualcondonaciones
		LET cConsulta = "SELECT a.fecha_reporte,TRIM(a.numcte) ,TRIM(a.num_credito) ,TRIM(a.nombre_cte) ,TRIM(a.estatus),TRIM(a.estatus_desc),a.saldo_capital ,a.meses_vencidos, a.dias_vencido, a.atr, a.act, to_char( a.fecha_vencido,'%d/%m/%Y') fecha_vencido, a.fecha_ult_dispo ,a.vencido_exigible ,a.vencido_noexigible ,a.interes_vencido ,a.iva_interes_vencido ,a.interes_vencido_bal ,	a.iva_interes_vencido_bal ,a.interes_vencido_orden ,	a.iva_interes_vencido_orden, a.interes_moratorio ,		a.iva_interes_moratorio ,a.saldo_total ,a.lineanodispuesta, a.causa_cancelacion, b.sucursal FROM 'informix'.sd_saldos_inmateriales a left join bdisolic:ss_solicitudes b on (a.empresa = b.empresa and a.num_credito = b.num_solicitud) WHERE a.empresa = '001' and a.fecha_reporte  = today " ;

	---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo "Fecha de reporte'||'|'||'No. de Cliente'||'|'||'No. de CrÃÂ©dito'||'|'||'Nombre del Cliente'||'|'||'Estatus'||'|'||'Descripcion Estatus'||'|'||'Saldo Capital'||'|'||'Meses Vencidos'||'|'||'Dias Vencidos'||'|'||'ATR'||'|'||'ACT'||'|'||'Fecha_vencido'||'|'||'Fecha_Ult_Disp'||'|'||'Vencido Exigible'||'|'||'Vencido No Exigible'||'|'||'Interes Vencido Ordinario'||'|'||'IVA Interes Vencido Ordinario'||'|'||'Interes Vencido Balanza'||'|'||'IVA Interes Vencido Balanza'||'|'||'Interes Vencido Orden'||'|'||'IVA Interes Vencido Orden'||'|'||'Interes Moratorio'||'|'||'IVA Interes Moratorio'||'|'||'Saldo Total a Aplicar'||'|'||'LinÃÂ©a No Dispuesta'||'|'||'Causa de la CancelaciÃÂ³n'||'|'||'Sucursal Origen'||'|'|| '" > '||TRIM(cruta)|| cNombreArchivo;  
		SYSTEM cEncabezado;

		
		--CREACION DE TEMPORALESS USADOS PARA LA CREACION DE ARCHIVO
		LET cSql = '';
		LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRuta)||TRIM(cNombreArchivo1)||' DELIMITER '||'''|'''||' '||TRIM(cConsulta)||' "> '|| TRIM(cRuta) ||'query1.sql';
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = "dbaccess bdicred "|| TRIM(cRuta) || "query1.sql";
		SYSTEM TRIM(cSql);

		LET cSql = cSql;
		LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNombreArchivo1) || " >> " || TRIM(cRuta) || TRIM(cNombreArchivo);
		SYSTEM cSql;

		
		--BORRADO DE TEMPORALES QUE FUERON USADOS PARA LA CREACION DE ARCHIVO
		LET cSql = '';
		LET cSQL = "rm "||TRIM(cRuta)||'query1.sql';		
		SYSTEM TRIM(cSql); 
		
		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cruta) || cNombreArchivo1;
		SYSTEM cSQL;   
	ELSE
		LET cCodRet = '00004';
		LET cMensajeRet ='NO EXISTE INFORMACION PARA REPORTE DE SALDOS INMATERIALES';
		RETURN cCodRet,cMensajeRet;
	END IF
	
	
	RETURN cCodRet,cMensajeRet;
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para ', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'FECHA: 21 Mayo 2014',
'VERSION: 20140521.1645',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_gen_rep_acumulado_quitacondonaciones()
RETURNING CHAR(6) AS cod_ret
--DECLARACION Y DEFINICION DE VARIABLES
	DEFINE vExiste 		INTEGER;
	DEFINE vExiste2		INTEGER;
	DEFINE vRutaArchivo CHAR(100);
	DEFINE vNombreArchivoCondonacion CHAR(26);
	DEFINE vNombreArchivoQuita	CHAR(20);
	DEFINE vFechaHoy DATE;
	DEFINE vFechaMesAnterior DATE;
	DEFINE vEmpresa CHAR(3);
	DEFINE vCommand CHAR(4000);
	DEFINE vDia 		CHAR(2);
	DEFINE vMes 		CHAR(2);
	DEFINE vAnio		CHAR(4);

	LET vDia = '';
	LET vMes = '';
	LET vAnio = '';
	LET vExiste = 0;
	LET vExiste2 = 0;
	LET vRutaArchivo = ''; --PARAMETRO PRUEBA  /informix/roman/reportes/
	LET vNombreArchivoCondonacion = 'Credito_CondonacionCierre_';
	LET vNombreArchivoQuita = 'Credito_QuitaCierre_';
	LET vEmpresa = '001';
	LET vCommand = '';

	BEGIN
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO "/informix/sp_gen_rep_acumulado_quitacondonaciones.out";
		--TRACE ON;
		SELECT TRIM(valor) INTO vRutaArchivo FROM bdicred:"informix".sd_param WHERE cod_param = 994;

		SELECT fecha_hoy, DAY(fecha_hoy), MONTH(fecha_hoy), YEAR(fecha_hoy) 
		INTO vFechaHoy, vDia, vMes, vAnio
		FROM bdicred:"informix".sd_fechas
		WHERE empresa = vEmpresa;
		
		/*LET vFechaHoy = to_date('01/10/2020', "%d/%m/%Y");
		LET vAnio = YEAR(vFechaHoy);
		LET vMes = MONTH(vFechaHoy);
		LET vDia = DAY(vFechaHoy);*/
		
		IF MONTH(vFechaHoy) < 10 THEN
			LET vMes = '0' || TRIM(vMes);
		END IF;

		IF DAY(vFechaHoy) < 10 THEN
			LET vDia = '0' || TRIM(vDia);
		END IF;

		LET vFechaMesAnterior = vFechaHoy - 1 UNITS MONTH;

		--IF pReporte = '1' THEN
			SELECT COUNT(*) 
			INTO vExiste
			FROM bdicred:sd_bitacora_quitacondonacion 
			WHERE fecha_insert >= vFechaMesAnterior AND indicador_proceso = 'C';
		
			IF (vExiste > 0) THEN 
				LET vCommand  = 'echo "UNLOAD TO ' || TRIM(vRutaArchivo) || TRIM(vNombreArchivoCondonacion) || vDia || vMes || vAnio || "_1.txt DELIMITER " ||  "'" || '|' || "'" || '" > ' || TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_condonacion.sql;';
				system TRIM(vCommand);

				LET vCommand = '';
				LET vCommand = 'echo "SELECT CAST(ROW_NUMBER() OVER (ORDER BY A.num_credito) AS INT) num, A.* FROM (' ||
				               'SELECT  b.num_credito, b.numcte,c.sucursal, b.meses_vencidos,c.fecha_apertura,' ||
							   'YEAR(c.fecha_apertura) anio, CASE WHEN MONTH(c.fecha_apertura) < 10 THEN ' || '''0''' || ' || MONTH(c.fecha_apertura) ' ||
							   'ELSE MONTH(c.fecha_apertura) || ''' || '''' || 'END mes, b.meses_historia, d.monto_otorgado,c.num_producto,g.grupo, ' ||							   
							   'b.sdo_credito,b.cap_vigente,b.cap_vencido,b.int_vigente, b.int_vencido,b.int_moratorio,b.iva_int_vigente,b.iva_int_vencido,' ||
							   'b.iva_int_mora,b.monto_condonado,b.pago_realizado,b.cap_vigente_cq, b.cap_vencido_cq,b.int_vigente_cq,b.int_vencido_cq,b.int_moratorio_cq, ' ||   
							   'b.iva_int_vigente_cq,b.iva_int_vencido_cq,b.iva_int_mora_cq,b.fecha_pago,g.evalua_cc,c.num_producto producto, g.score_prop score_originacion_interno,g.bs_score score_buro,' ||
							   'today fecha_reporte,c.tasa_interes tasa_contrato ' ||							   
							   'FROM bdicred:sd_bitacora_quitacondonacion b  ' ||
							   'INNER JOIN bdicred:sd_maecred c ON c.num_credito = b.num_credito ' ||
							   'INNER JOIN bdicred:sd_maesdos d ON d.num_credito = b.num_credito ' ||
							   'LEFT JOIN bdisolic:ss_revision_determinacion g ON g.empresa=''001'' AND g.num_solicitud = b.num_credito  ' ||						   
							   'WHERE b.indicador_proceso = ''C''' || ' AND b.fecha_insert >= mdy(' || MONTH(vFechaMesAnterior) || ',' || DAY(vFechaMesAnterior) ||',' || YEAR(vFechaMesAnterior) || ') ' ||
							   'UNION ' ||							   
							   'SELECT b.num_credito, b.numcte,c.sucursal, b.meses_vencidos,c.fecha_apertura,' ||
							   'YEAR(c.fecha_apertura) anio, CASE WHEN MONTH(c.fecha_apertura) < 10 THEN ' || '''0''' || ' || MONTH(c.fecha_apertura) ' ||
							   'ELSE MONTH(c.fecha_apertura) || ''' || '''' || 'END mes, b.meses_historia, d.monto_otorgado,c.num_producto,g.grupo, ' ||
							   'b.sdo_credito,b.cap_vigente,b.cap_vencido,b.int_vigente, b.int_vencido,b.int_moratorio,b.iva_int_vigente,b.iva_int_vencido, ' ||
							   'b.iva_int_mora,b.monto_condonado,b.pago_realizado,b.cap_vigente_cq, b.cap_vencido_cq,b.int_vigente_cq,b.int_vencido_cq,b.int_moratorio_cq, ' ||
							   'b.iva_int_vigente_cq,b.iva_int_vencido_cq,b.iva_int_mora_cq,b.fecha_pago,g.evalua_cc,i.producto, g.score_prop score_originacion_interno,g.bs_score score_buro,' ||
							   'today fecha_reporte,c.tasa_interes tasa_contrato ' ||
							   'FROM bdicred:sd_bitacora_quitacondonacion b ' ||
							   'INNER JOIN bdicred:sd_maecredcrd c ON c.num_credito = b.num_credito ' ||
							   'INNER JOIN bdicred:sd_maesdoscrd d ON d.num_credito = b.num_credito ' ||
							   'LEFT JOIN bdisolic:ss_revision_determinacion g ON g.empresa=''001'' AND g.num_solicitud = b.num_credito ' ||
							   'LEFT JOIN bdicheq:sc_maechq i ON i.num_cte = b.numcte AND i.status_cta= 1 AND i.cuenta= b.num_cuenta_chq ' ||
							   'WHERE b.indicador_proceso = ''C''' || ' AND b.fecha_insert >= mdy(' || MONTH(vFechaMesAnterior) || ',' || DAY(vFechaMesAnterior) ||',' || YEAR(vFechaMesAnterior) || ') )A' ||						   
							   '; " >> ' ||  TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_condonacion.sql;';
					
				system TRIM(vCommand);
				
				LET vCommand = 'chmod 777 '  || TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_condonacion.sql;';
				system TRIM(vCommand);
								
				LET vCommand = 'dbaccess bdicred ' || TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_condonacion.sql;';
				system TRIM(vCommand);
								
				system "sed 's/|$//g' " || TRIM(vRutaArchivo) || TRIM(vNombreArchivoCondonacion) || vDia || vMes || vAnio || "_1.txt > " ||  TRIM(vRutaArchivo) || TRIM(vNombreArchivoCondonacion) || vDia || vMes || vAnio || ".txt";
				system 'rm ' || TRIM(vRutaArchivo) || TRIM(vNombreArchivoCondonacion) || vDia || vMes || vAnio || "_1.txt";
				--system 'rm ' || TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_condonacion.sql;';
				
			ELSE 
				system "touch " || TRIM(vRutaArchivo) ||  TRIM(vNombreArchivoCondonacion) || vDia || vMes || vAnio || ".txt";	
			END IF;
		--END IF;
		
		/*LET vFechaHoy = to_date('01/09/2020', "%d/%m/%Y");
		LET vAnio = YEAR(vFechaHoy);
		LET vMes = MONTH(vFechaHoy);
		LET vDia = DAY(vFechaHoy);
		
		IF MONTH(vFechaHoy) < 10 THEN
			LET vMes = '0' || TRIM(vMes);
		END IF;

		IF DAY(vFechaHoy) < 10 THEN
			LET vDia = '0' || TRIM(vDia);
		END IF;
		
		LET vFechaMesAnterior = vFechaHoy - 1 UNITS MONTH;*/
		
		--IF pReporte = '2' THEN
			SELECT COUNT(*) 
			INTO vExiste2
			FROM bdicred:sd_bitacora_quitacondonacion 
			WHERE fecha_insert >= vFechaMesAnterior AND indicador_proceso = 'Q';
		

			IF (vExiste2 > 0) THEN 
				LET vCommand  = 'echo "UNLOAD TO ' || TRIM(vRutaArchivo) || TRIM(vNombreArchivoQuita) || vDia || vMes || vAnio || "_1.txt DELIMITER " ||  "'" || '|' || "'" || '" > ' || TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_quita.sql;';
				system TRIM(vCommand);

				LET vCommand = '';
				LET vCommand = 'echo "SELECT CAST(ROW_NUMBER() OVER (ORDER BY A.num_credito) AS INT) num, A.* FROM (' ||
				               'SELECT b.num_credito, b.numcte,b.fecha_ult_disp_com,c.sucursal,b.monto_ult_disp_comp, ' ||
							   'b.abono_mensual_al_quita,d.fecha_ult_mov,b.tipo_ult_mov, b.meses_vencidos,j.num_tarjeta,c.fecha_apertura, '||
							   'YEAR(c.fecha_apertura) anio, CASE WHEN MONTH(c.fecha_apertura) < 10 THEN ' || '''0''' || ' || MONTH(c.fecha_apertura) '||
							   'ELSE MONTH(c.fecha_apertura)||''' || ''''||' END mes, b.meses_historia, d.monto_otorgado, ' ||
							   'c.num_producto,g.grupo, b.sdo_credito,b.cap_vigente,b.cap_vencido,b.int_vigente,b.int_vencido,b.int_moratorio, ' ||
							   'b.iva_int_vigente,b.iva_int_vencido,b.iva_int_mora,b.mto_quita,b.cap_vigente_cq,b.cap_vencido_cq, ' ||
							   'b.int_vigente_cq,b.int_vencido_cq, b.int_moratorio_cq, b.iva_int_vigente_cq ,b.iva_int_vencido_cq, ' ||
							   'b.iva_int_mora_cq,b.sdo_remanente_dq,b.cap_vigente_dq,b.cap_vencido_dq,b.int_vigente_dq,b.int_vencido_dq, ' ||
							   'b.int_moratorio_dq,b.iva_int_vigente_dq,b.iva_int_vencido_dq,b.iva_int_mora_dq,b.fecha_liquidacion, ' ||
							   'b.fecha_negociacion,b.porc_quita,b.porc_recuperado,d.mto_capitalizado monto_recuperado,g.evalua_cc,c.num_producto, ' ||
							   'g.score_prop score_originacion_interno,g.bs_score score_buro,today fecha_reporte,c.tasa_interes tasa_contrato ' ||
							   'FROM bdicred:sd_bitacora_quitacondonacion b ' ||
							   'INNER JOIN bdicred:sd_maecred c ON c.num_credito = b.num_credito ' ||
							   'INNER JOIN bdicred:sd_maesdos d ON d.num_credito = b.num_credito ' ||
							   'LEFT JOIN bdisolic:ss_revision_determinacion g ON g.empresa=''001'' AND g.num_solicitud = b.num_credito ' ||
							   'LEFT JOIN bdicred:sd_tarjeta j ON j.num_credito = b.num_credito ' || 							   
							   'WHERE b.indicador_proceso = ''Q''' || ' AND b.fecha_insert >= mdy(' || MONTH(vFechaMesAnterior) || ',' || DAY(vFechaMesAnterior) ||',' || YEAR(vFechaMesAnterior) || ') ' ||
							   'AND j.status_tar = ''A'' AND j.secuencia = (' ||
							   'SELECT MAX(secuencia) FROM bdicred:sd_tarjeta WHERE num_credito = b.num_credito)' ||
							   'UNION ' ||
							   'SELECT b.num_credito, b.numcte,b.fecha_ult_disp_com,c.sucursal,b.monto_ult_disp_comp, ' ||
							   'b.abono_mensual_al_quita,d.fecha_ult_mov,b.tipo_ult_mov, b.meses_vencidos,j.num_tarjeta,c.fecha_apertura, ' ||
							   'YEAR(c.fecha_apertura) anio, CASE WHEN MONTH(c.fecha_apertura) < 10 THEN ' || '''0''' || ' || MONTH(c.fecha_apertura) '||
							   'ELSE MONTH(c.fecha_apertura)||''' || ''''||' END mes, b.meses_historia, d.monto_otorgado, ' ||
							   'c.num_producto,g.grupo, b.sdo_credito,b.cap_vigente,b.cap_vencido,b.int_vigente,b.int_vencido,b.int_moratorio, ' ||
							   'b.iva_int_vigente,b.iva_int_vencido,b.iva_int_mora,b.mto_quita,b.cap_vigente_cq,b.cap_vencido_cq, ' ||
							   'b.int_vigente_cq,b.int_vencido_cq, b.int_moratorio_cq, b.iva_int_vigente_cq ,b.iva_int_vencido_cq, ' ||
							   'b.iva_int_mora_cq,b.sdo_remanente_dq,b.cap_vigente_dq,b.cap_vencido_dq,b.int_vigente_dq,b.int_vencido_dq, ' ||
							   'b.int_moratorio_dq,b.iva_int_vigente_dq,b.iva_int_vencido_dq,b.iva_int_mora_dq,b.fecha_liquidacion, ' ||
							   'b.fecha_negociacion,b.porc_quita,b.porc_recuperado,d.mto_capitalizado monto_recuperado,g.evalua_cc,i.producto,  ' ||
							   'g.score_prop score_originacion_interno,g.bs_score score_buro,today fecha_reporte,c.tasa_interes tasa_contrato  ' ||
							   'FROM bdicred:sd_bitacora_quitacondonacion b ' ||
							   'INNER JOIN bdicred:sd_maecredcrd c ON c.num_credito = b.num_credito ' ||
							   'INNER JOIN bdicred:sd_maesdoscrd d ON d.num_credito = b.num_credito ' ||
							   'LEFT JOIN bdisolic:ss_revision_determinacion g ON g.empresa=''001'' AND g.num_solicitud = b.num_credito  ' ||
							   'LEFT JOIN bdicheq:sc_maechq i ON i.num_cte = b.numcte AND i.status_cta= 1 AND i.cuenta= b.num_cuenta_chq ' ||
							   'LEFT JOIN bdicred:sd_tarjeta j ON j.num_credito = b.num_credito ' ||
							   'WHERE b.indicador_proceso = ''Q''' || ' AND b.fecha_insert >= mdy(' || MONTH(vFechaMesAnterior) || ',' || DAY(vFechaMesAnterior) ||',' || YEAR(vFechaMesAnterior) || ') ' ||						   
							   'AND j.status_tar = ''A'' AND j.secuencia = (' ||
							   'SELECT MAX(secuencia) FROM bdicred:sd_tarjeta WHERE num_credito = b.num_credito) )A' ||
							   '; " >> ' ||  TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_quita.sql;';
							   
				system TRIM(vCommand);
				
				LET vCommand = 'chmod 777 '  || TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_quita.sql;';
				system TRIM(vCommand);
								
				LET vCommand = 'dbaccess bdicred ' || TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_quita.sql;';
				system TRIM(vCommand);
								
				system "sed 's/|$//g' " || TRIM(vRutaArchivo) || TRIM(vNombreArchivoQuita) || vDia || vMes || vAnio || "_1.txt > " ||  TRIM(vRutaArchivo) || TRIM(vNombreArchivoQuita) || vDia || vMes || vAnio || ".txt";
				system 'rm ' || TRIM(vRutaArchivo) || TRIM(vNombreArchivoQuita) || vDia || vMes || vAnio || "_1.txt";
				--system 'rm ' || TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_quita.sql;';
			ELSE 
				system "touch " || TRIM(vRutaArchivo) ||  TRIM(vNombreArchivoQuita) || vDia || vMes || vAnio || ".txt";	
			END IF;
		--END IF;

			RETURN "000000";
	END
END PROCEDURE;