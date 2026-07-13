CREATE PROCEDURE "informix".sp_reporte_prestamoflex(p_empresa CHAR(3))
RETURNING CHAR(6);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE v_cod_ret					CHAR(6);
DEFINE vsqlerr						INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet 						CHAR(6);	
DEFINE vvcodigo_retorno 			CHAR(6);
DEFINE cMensajeRet 					CHAR(80);
    

DEFINE p_flex_proc					INTEGER;
DEFINE p_pers_proc					INTEGER;
DEFINE p_d_flex_proc				INTEGER;
DEFINE p_existe_tbl_pf				INTEGER;
DEFINE p_existe_tbl_pp				INTEGER;

DEFINE v_fecha_hoy						DATE;
DEFINE v_credito					CHAR(20);
DEFINE v_disposicion				INTEGER;
DEFINE v_numcliente					CHAR(20);
DEFINE v_sucursal					CHAR(4);
DEFINE v_nombresuc					CHAR(50);
DEFINE v_monto_dispuesto			DECIMAL (18,2);
DEFINE v_estatus					CHAR(2);
DEFINE v_monto_linea				DECIMAL(18,2);


DEFINE  v_fecha_origen  			DATE;
DEFINE  v_fecha_ult_pago  			DATE;
DEFINE  v_plazo  					INTEGER;
DEFINE  v_cap_vig  					DECIMAL(18,2);
DEFINE  v_cap_trans  				DECIMAL(18,2);
DEFINE  v_cap_vdo_exig  			DECIMAL(18,2);
DEFINE  v_total_liquidacion  		DECIMAL(18,2);
DEFINE  v_pagos_vdos  				DECIMAL(18,2);
DEFINE  v_fecha_otorga				DATE;

DEFINE v_sepa               		CHAR(2);
DEFINE sMes							CHAR(2);
DEFINE sDia							CHAR(2);
DEFINE sYear						CHAR(4);
DEFINE sFechaArch					CHAR(8); --INC 25 016
DEFINE v_sql						CHAR(1000);
DEFINE v_enc						CHAR(1000);
DEFINE cRuta						char(100);

DEFINE v_fecha_dispos				CHAR(10);
DEFINE v_fecha_last_pay				CHAR(10);
DEFINE v_fecha_appertura			CHAR(10);
DEFINE v_dia_ejec					INTEGER;
DEFINE v_dia_ant					DATE;
DEFINE v_pri_dia_mes				DATE;
DEFINE v_num_autorizados			INTEGER;
DEFINE v_monto_autorizados			DECIMAL(18,2);
DEFINE v_num_dispuestos				INTEGER;
DEFINE v_monto_dispuestos			DECIMAL(18,2);

DEFINE v_fecha_cancela				DATE;
DEFINE v_activacion_bandera			CHAR(2);
DEFINE v_fecha_vencim				DATE;

DEFINE vc_fecha_cancela				CHAR(10);
DEFINE vc_fecha_vencim				CHAR(10);		
DEFINE v_Ejecutivo 					CHAR(8);	
DEFINE v_Canal 						CHAR(2);
DEFINE v_Hora_Transaccion 			LIKE bdicred:sd_linea_prestamo.fecha_ult_mod;
DEFINE v_Id_Atm 					CHAR(8);
DEFINE v_Hora_Tran					CHAR(15);
DEFINE v_Nomb_Canal					CHAR(30);
--DEFINE v_obligado							CHAR(20);
DEFINE v_fecha_hora					DATETIME YEAR to SECOND;
DEFINE v_fecha_venc_linea           DATE; 
DEFINE vc_fecha_venc_linea          CHAR(10);
DEFINE v_fecha_integ				DATE;
DEFINE v_fecha_depura				DATE;
DEFINE v_fecha_sistema				DATE;
DEFINE vc_acepto_incremento         CHAR(9);
DEFINE vd_tasa_interes_prestamo		DECIMAL(18,2);			
DEFINE v_sdo_cap_insoluto			DECIMAL(18,2);
DEFINE v_sdo_retenido				DECIMAL(18,2);
DEFINE v_sdo_intereses				DECIMAL(18,2);					

DEFINE cFolioOneClick				CHAR(14);
DEFINE cTasaFormaliza				CHAR(6);
DEFINE cSucursalFormaliza			CHAR(4);
DEFINE cPromotorFormaliza			CHAR(8);
DEFINE cCanalFormaliza				CHAR(8);
		
DEFINE dtIvaFechaPag 				DATE;
DEFINE dtFechaCuota 				DATE;
DEFINE dIvaSuc 						DECIMAL(5,3);  
DEFINE dIvaIntDevengado 			DECIMAL(18,2);
DEFINE dPagoMinimo 					DECIMAL(18,2);
DEFINE dIntVdo 						DECIMAL(18,2);
DEFINE dIntMoratorio 				DECIMAL(18,2);
DEFINE dIvaIntVdo 					DECIMAL(18,2);
DEFINE dPagosVdos 					DECIMAL(18,2);
DEFINE dIvaIntMoratorio				DECIMAL(18,2);
DEFINE dIntMes 						DECIMAL(18,2);
DEFINE dIvaIntMes 					DECIMAL(18,2);
DEFINE dIntVig 						DECIMAL(18,2);
DEFINE dIvaIntVig 					DECIMAL(18,2);
DEFINE dSdoActInt 					DECIMAL(18,2);
DEFINE dSdoActIvaInt 				DECIMAL(18,2);
DEFINE dComPend 					DECIMAL(18,2);
DEFINE dIvaCom 						DECIMAL(18,2);
		
--VARIABLES DE BITACORA
DEFINE cCodRetBit 					CHAR(6);
DEFINE cProceso 					CHAR(4);

DEFINE vRegistro		  			CHAR(2500); 
DEFINE vArchivoSql           		VARCHAR(50);
DEFINE vRep							INTEGER;
DEFINE vNomArch	           			VARCHAR(50);

DEFINE vbanderaact        			CHAR(11);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET v_cod_ret					= "000000";
LET vsqlerr						= 0;
LET iIsamErr       				= 0;
LET cErrorInfo      			= "";
LET cCodRet 					= '';
LET vvcodigo_retorno 			= '';
LET cMensajeRet 				= ''; 

LET p_flex_proc					= 0;
LET p_pers_proc					= 0;
LET p_d_flex_proc				= 0;
LET p_existe_tbl_pf				= 0;
LET p_existe_tbl_pp				= 0;

LET v_fecha_hoy					= DATE(1);
LET v_credito 					= '';
LET v_disposicion 				= 0;
LET v_numcliente 				= '';
LET v_sucursal 					= '';
LET v_nombresuc 				= '';
LET v_monto_dispuesto 			= 0;
LET v_plazo 					= 0;
LET v_estatus 					= '';
LET v_monto_linea 				= 0;

LET v_fecha_origen				= DATE(1);
LET v_fecha_ult_pago			= DATE(1);
LET v_cap_trans					= 0;
LET v_cap_vdo_exig				= 0;
LET v_total_liquidacion			= 0;
LET v_pagos_vdos				= 0;
LET v_fecha_otorga				= DATE(1);

LET v_sepa                 		= '\|';
LET sDia						= "";
LET sMes						= "";
LET sYear						= "";
LET sFechaArch					= "";
LET v_sql						= "";
LET v_enc						= "";
LET cRuta		 				= "/RESPALDOSNEW/";

LET v_fecha_dispos				= "";
LET v_fecha_last_pay			= "";
LET v_fecha_appertura			= "";
LET v_dia_ejec					= 0;
LET v_dia_ant					= DATE(1);
LET v_pri_dia_mes				= DATE(1);
LET v_num_autorizados			= 0;
LET v_monto_autorizados			= 0;
LET v_num_dispuestos			= 0;
LET v_monto_dispuestos			= 0;

LET v_fecha_cancela				= DATE(1);
LET v_activacion_bandera		= "";
LET v_fecha_vencim				= DATE(1);
LET vc_fecha_cancela			= "";
LET vc_fecha_vencim				= "";
LET v_Ejecutivo 				= "";
LET v_Canal 					= "";
--LET v_Hora_Transaccion 			LIKE bdicred:sd_linea_prestamo.fecha_ult_mod;
LET v_Id_Atm 					= "";
LET v_Hora_Tran					= "";
LET v_Nomb_Canal				= '';
--LET v_obligado						= '';
LET v_fecha_hora                = DATE(1);
LET v_fecha_venc_linea          = DATE(1); 
LET vc_fecha_venc_linea         = "";
LET vc_acepto_incremento        = "";
LET vd_tasa_interes_prestamo    = "";
LET v_sdo_cap_insoluto			= 0;
LET v_sdo_retenido				= 0;
LET v_sdo_intereses				= 0;

LET cFolioOneClick				= '';
LET cTasaFormaliza				= '';
LET cSucursalFormaliza			= '';
LET cPromotorFormaliza			= '';
LET cCanalFormaliza				= '';

LET dtIvaFechaPag 				= DATE(1);
LET dtFechaCuota 				= DATE(1);
LET dIvaSuc 					= 0;   
LET dIvaIntDevengado 			= 0;
LET dPagoMinimo 				= 0;
LET dIntVdo						= 0;
LET dIntMoratorio				= 0;
LET dIvaIntVdo 					= 0;
LET dPagosVdos 					= 0;
LET dIvaIntMoratorio			= 0;
LET dIntMes 					= 0;
LET dIvaIntMes 					= 0;
LET dIntVig 					= 0;
LET dIvaIntVig 					= 0;
LET dSdoActInt 					= 0;    
LET dSdoActIvaInt 				= 0;
LET dComPend					= 0;
LET dIvaCom 					= 0;

--VARIABLES DE BITACORA
LET cCodRetBit 					= '000000';
LET cProceso 					= '0118';

LET vRegistro      				= '';
LET vArchivoSql        			= '206_4_30_REP_PRESTAMO_FLEXIBLE_PRO';
LET vRep						= 1;
LET vNomArch					= '';

LET vbanderaact       			= '';

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

BEGIN
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo 
		IF vsqlerr != 0 THEN
			LET v_cod_ret=vsqlerr;
			EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, v_cod_ret, "ERROR SQL: "||v_cod_ret||" - ERROR: "||iIsamErr|| " - INFO: "||cErrorInfo||v_credito, '02')
			INTO cCodRetBit;
			RETURN v_cod_ret;
		END IF;  
	END EXCEPTION;
	
 	--SET DEBUG FILE TO "/tmp/preaprobados/sp_reporte_prestamoflex.out";
	-- TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	

	EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, v_cod_ret, "1_ INICIA PROCESO DE REPORTES DE PRESTAMO FLEXIBLE", '01') 
	INTO cCodRetBit;

	--SE MODIFICA LA FECHA SISTEMA A LA FECHA DE BD EN sd_fechas
	--LET v_fecha_sistema= CURRENT::DATE;
	
	
	SELECT 	fecha_hoy, fecha_hoy, fecha_ant, weekday(fecha_hoy),pri_dia_mes
	INTO v_fecha_sistema, v_fecha_hoy, v_dia_ant, v_dia_ejec,v_pri_dia_mes
	FROM  bdicred:"informix".sd_fechas
	WHERE empresa = p_empresa;
	 
	--LET  v_dia_ejec=1; --SOLO PRUEBAS
	LET sDia= DAY(v_fecha_hoy);
	LET sMes= MONTH(v_fecha_hoy);
	LET sYear= YEAR(v_fecha_hoy);
	
	IF LENGTH(sMes)<2 THEN
		LET sMes="0"||sMes;
	END IF;	
	
	IF LENGTH(sDia)<2 THEN
		LET sDia="0"||sDia;
	END IF;
	
	LET sFechaArch = sDia||sMes||sYear; --RQI 25 023

	--Se modifica la fecha de depuraciÃ³n a una semana laboral (5 dias)
	LET v_fecha_depura = (v_fecha_sistema - 5 UNITS DAY):: DATE;
	
	-- EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, v_cod_ret, "2_ Elimina tablas temporales", '02')
	-- INTO cCodRetBit;
	
	-- Inicio eliminar tablas e index temporales
	DROP TABLE IF EXISTS bdicred:tmp_reppflex;
	DROP TABLE IF EXISTS bdicred:tmp_reppersonales;
	
	DROP INDEX IF EXISTS bdicred:idx_tmp_reppersonales;
	DROP INDEX IF EXISTS bdicred:idx_temp_reppflex;
	
	-- Fin eliminar tablas e index temporales
	
-- ****************************************************************************
-- *                     OBTIENE UNIVERSO REPORTE                             *

	EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, v_cod_ret, "2_ Obtiene informacion para tabla temporal tmp_reppflex", '02')
	INTO cCodRetBit;
	
	IF v_fecha_hoy = v_pri_dia_mes  THEN
		--- Obtiene concentrado para obtener informacion de reporte Reporte_P_Flexible_DDMMYYYY.txt lineas activas
		SELECT b.num_credito as num_credito,
		d.sec_credito as disposicion,
		b.numcte as numcte,
		b.sucursal as sucursal,
		e.nombre as nombresuc,
		md.monto_otorgado as dispuesto,
		b.fecha_apertura as fechadisp,
		b.plazo as plazo,
		f.fecha_ult_pago as fecha_ult_pago,
		b.status_cred as status_cred,
		md.sdo_cap_insoluto as total_liquidacion, --SALDO UINSOLUTO (Variable TOTAL_LIQUIDACION)
		md.sdo_capital as cap_vig, 	--CAPITAL VIGENTE
		md.monto_vencido as cap_trans, --CAPITAL TRANSITORIO
		0 as cap_vdo_exig, --CAPITAL VENCIDO EXIGIBLE
		nvl(md.atr,0) as pagos_vdos, --MESES VENCIDOS
		d.fecha_otorga AS fecha_apertura,
		d.monto_linea as monto_linea,
		d.fecha_cancela as fecha_cancela,
		d.cancel_pf as bandera_act, -- PASAR A FOREACH
		b.fecha_vencim as fecha_ven_pres,
		b.ejecutivo as ejecutivo,
		b.bandera_fi_fo as canal, --Variable para onclick (canal)
		d.fecha_ult_mod as hora_transacc,
		f.localidad as localidad,
		d.fecha_venc_linea as fecha_ven_lin,
		nvl(d.acepto_incremento,'') AS acepto_incremento,
		nvl(b.tasa_interes,0) as tasa_interes,
		'' as folio_one_click,
		'' as tasa,
		'' as sucursal_formaliza,
		'' as ejecutivo_auto,
		'' as canal_formaliza,
		nvl(md.sdo_cap_insoluto,0) as sdo_cap_insoluto,
		nvl(md.sdo_retenido,0) as sdo_retenido,
		nvl(md.sdo_intereses,0) as sdo_intereses,
		0 as status_p,
		v_fecha_sistema as fecha_reporte
		FROM  bdicred:sd_maecredcrd b 
		inner join bdicred:sd_linea_prestamo d on d.num_credito = b.num_credito 
		inner join bdinteg:si_sucursales e on e.sucursal = b.sucursal 
		inner join bdicred:sd_maecredanexocrd f on f.num_credito = b.num_credito
		inner join bdicred:sd_maesdoscrd md on md.num_credito = b.num_credito
		where b.num_producto = '6800'
		AND b.fecha_apertura >= '01,01,2018'
		AND b.status_cred IN ('E1','E2','E3','FF','FC') AND d.cancel_pf is null and d.fecha_cancela is null
		and b.num_Credito not in (select num_Credito from bdicred:sd_rep_p_flexible where fecha_reporte = v_fecha_sistema)
		INTO temp tmp_reppflex with no log;
		
		insert into tmp_reppflex
		SELECT b.num_credito as num_credito,
		d.sec_credito as disposicion,
		b.numcte as numcte,
		b.sucursal as sucursal,
		e.nombre as nombresuc,
		md.monto_otorgado as dispuesto,
		b.fecha_apertura as fechadisp,
		b.plazo as plazo,
		f.fecha_ult_pago as fecha_ult_pago,
		b.status_cred as status_cred,
		md.sdo_cap_insoluto as total_liquidacion, --SALDO UINSOLUTO (Variable TOTAL_LIQUIDACION)
		md.sdo_capital as cap_vig, 	--CAPITAL VIGENTE
		md.monto_vencido as cap_trans, --CAPITAL TRANSITORIO
		0 as cap_vdo_exig, --CAPITAL VENCIDO EXIGIBLE
		nvl(md.atr,0) as pagos_vdos, --MESES VENCIDOS
		d.fecha_otorga AS fecha_apertura,
		d.monto_linea as monto_linea,
		d.fecha_cancela as fecha_cancela,
		d.cancel_pf as bandera_act, -- PASAR A FOREACH
		b.fecha_vencim as fecha_ven_pres, 
		b.ejecutivo as ejecutivo,
		b.bandera_fi_fo as canal, --Variable para onclick (canal)
		d.fecha_ult_mod as hora_transacc,
		f.localidad as localidad,
		d.fecha_venc_linea as fecha_ven_lin,
		nvl(d.acepto_incremento,'') AS acepto_incremento,
		nvl(b.tasa_interes,0) as tasa_interes,
		'' as folio_one_click,
		'' as tasa,
		'' as sucursal_formaliza,
		'' as ejecutivo_auto,	
		'' as canal_formaliza,
		nvl(md.sdo_cap_insoluto,0) as sdo_cap_insoluto,
		nvl(md.sdo_retenido,0) as sdo_retenido,
		nvl(md.sdo_intereses,0) as sdo_intereses,
		0 as status_p,
		v_fecha_sistema as fecha_reporte
		FROM  bdicred:sd_maecredcrd b 
		inner join bdicred:sd_linea_prestamo d on d.num_credito = b.num_credito 
		inner join bdinteg:si_sucursales e on e.sucursal = b.sucursal 
		inner join bdicred:sd_maecredanexocrd f on f.num_credito = b.num_credito
		inner join bdicred:sd_maesdoscrd md on md.num_credito = b.num_credito
		where b.num_producto = '6800'
		AND b.fecha_apertura >= '01,01,2018'
		AND b.status_cred IN ('E1','E2','E3','FF','FC','CV','FI') AND d.cancel_pf is not null and d.fecha_cancela is not null
		and b.num_Credito not in (select num_Credito from bdicred:sd_rep_p_flexible where fecha_reporte = v_fecha_sistema);
		
	ELSE
		--- Obtiene concentrado para obtener informacion de reporte Reporte_P_Flexible_DDMMYYYY.txt lineas activas
		SELECT b.num_credito as num_credito,
		d.sec_credito as disposicion,
		b.numcte as numcte,
		b.sucursal as sucursal,
		e.nombre as nombresuc,
		md.monto_otorgado as dispuesto,
		b.fecha_apertura as fechadisp,
		b.plazo as plazo,
		f.fecha_ult_pago as fecha_ult_pago,
		b.status_cred as status_cred,
		md.sdo_cap_insoluto as total_liquidacion, --SALDO UINSOLUTO (Variable TOTAL_LIQUIDACION)
		md.sdo_capital as cap_vig, 	--CAPITAL VIGENTE
		md.monto_vencido as cap_trans, --CAPITAL TRANSITORIO
		0 as cap_vdo_exig, --CAPITAL VENCIDO EXIGIBLE
		nvl(md.atr,0) as pagos_vdos, --MESES VENCIDOS
		d.fecha_otorga AS fecha_apertura,
		d.monto_linea as monto_linea,
		d.fecha_cancela as fecha_cancela,
		d.cancel_pf as bandera_act, -- PASAR A FOREACH
		b.fecha_vencim as fecha_ven_pres, 
		b.ejecutivo as ejecutivo,
		b.bandera_fi_fo as canal, --Variable para onclick (canal)
		d.fecha_ult_mod as hora_transacc,
		f.localidad as localidad,
		d.fecha_venc_linea as fecha_ven_lin,
		nvl(d.acepto_incremento,'') AS acepto_incremento,
		nvl(b.tasa_interes,0) as tasa_interes,
		'' as folio_one_click,
		'' as tasa,
		'' as sucursal_formaliza,
		'' as ejecutivo_auto,
		'' as canal_formaliza,
		nvl(md.sdo_cap_insoluto,0) as sdo_cap_insoluto,
		nvl(md.sdo_retenido,0) as sdo_retenido,
		nvl(md.sdo_intereses,0) as sdo_intereses,
		0 as status_p,
		v_fecha_sistema as fecha_reporte
		FROM  bdicred:sd_maecredcrd b 
		inner join bdicred:sd_linea_prestamo d on d.num_credito = b.num_credito 
		inner join bdinteg:si_sucursales e on e.sucursal = b.sucursal 
		inner join bdicred:sd_maecredanexocrd f on f.num_credito = b.num_credito
		inner join bdicred:sd_maesdoscrd md on md.num_credito = b.num_credito
		where b.num_producto = '6800'
		AND b.fecha_apertura >= '01,01,2018'
		AND b.status_cred IN ('E1','E2','E3','FF') AND d.cancel_pf is null and d.fecha_cancela is null
		and b.num_Credito not in (select num_Credito from bdicred:sd_rep_p_flexible where fecha_reporte = v_fecha_sistema)																				
		INTO temp tmp_reppflex with no log;
			
		--- Obtiene concentrado para obtener informacion de reporte Reporte_P_Flexible_DDMMYYYY.txt lineas canceladas pero con creditos activos
		insert into tmp_reppflex
		SELECT b.num_credito as num_credito,
		d.sec_credito as disposicion,
		b.numcte as numcte,
		b.sucursal as sucursal,
		e.nombre as nombresuc,
		md.monto_otorgado as dispuesto,
		b.fecha_apertura as fechadisp,
		b.plazo as plazo,
		f.fecha_ult_pago as fecha_ult_pago,
		b.status_cred as status_cred,
		md.sdo_cap_insoluto as total_liquidacion, --SALDO UINSOLUTO (Variable TOTAL_LIQUIDACION)
		md.sdo_capital as cap_vig, 	--CAPITAL VIGENTE
		md.monto_vencido as cap_trans, --CAPITAL TRANSITORIO
		0 as cap_vdo_exig, --CAPITAL VENCIDO EXIGIBLE
		nvl(md.atr,0) as pagos_vdos, --MESES VENCIDOS
		d.fecha_otorga AS fecha_apertura,
		d.monto_linea as monto_linea,
		d.fecha_cancela as fecha_cancela,
		d.cancel_pf as bandera_act, -- PASAR A FOREACH
		b.fecha_vencim as fecha_ven_pres,
		b.ejecutivo as ejecutivo,
		b.bandera_fi_fo as canal, --Variable para onclick (canal)
		d.fecha_ult_mod as hora_transacc,
		f.localidad as localidad,
		d.fecha_venc_linea as fecha_ven_lin,
		nvl(d.acepto_incremento,'') AS acepto_incremento,
		nvl(b.tasa_interes,0) as tasa_interes,
		'' as folio_one_click,
		'' as tasa,
		'' as sucursal_formaliza,
		'' as ejecutivo_auto,
		'' as canal_formaliza,
		nvl(md.sdo_cap_insoluto,0) as sdo_cap_insoluto,
		nvl(md.sdo_retenido,0) as sdo_retenido,
		nvl(md.sdo_intereses,0) as sdo_intereses,
		0 as status_p,
		v_fecha_sistema as fecha_reporte
		FROM  bdicred:sd_maecredcrd b 
		inner join bdicred:sd_linea_prestamo d on d.num_credito = b.num_credito 
		inner join bdinteg:si_sucursales e on e.sucursal = b.sucursal 
		inner join bdicred:sd_maecredanexocrd f on f.num_credito = b.num_credito
		inner join bdicred:sd_maesdoscrd md on md.num_credito = b.num_credito
		where b.num_producto = '6800'
		AND b.fecha_apertura >= '01,01,2018'
		AND b.status_cred IN ('E1','E2','E3') AND d.cancel_pf is not null and d.fecha_cancela is not null
		and b.num_Credito not in (select num_Credito from bdicred:sd_rep_p_flexible where fecha_reporte = v_fecha_sistema);
	END IF;
	
	CREATE INDEX idx_temp_reppflex on tmp_reppflex(num_credito, fecha_reporte);
	
	EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, v_cod_ret, "3_ Obtiene informacion para tabla temporal tmp_reppersonales", '02')
	INTO cCodRetBit;
	
	--AAME 2021-02-03 RQM 10 1177 Se modifica para contemplar los 2 nuevos productos de prestamo (9100,9300)
	--- Obtiene concentrado para obtener informacion de reporte Reporte_P_Personales_DDMMYYYY
	SELECT 
		b.num_credito as num_credito
		,b.numcte as numcte
		,b.sucursal as sucursal
		,e.nombre as nombresuc
		,md.monto_otorgado as dispuesto
		, b.fecha_apertura as fecha_dis
		, b.plazo as plazo
		, f.fecha_ult_pago as fech_ult_pago				
		,b.status_cred as status_cred
		--SALDO UINSOLUTO (Variable TOTAL_LIQUIDACION)
		--,0 as total_liquidacion 
		--CAPITAL VIGENTE
		,md.sdo_capital as cap_vig
		--CAPITAL TRANSITORIO
		,0 as cap_trans
		--CAPITAL VENCIDO EXIGIBLE
		,0 as cap_vdo_exig
		--MESES VENCIDOS
		,md.atr as pagos_vdos
		,b.fecha_apertura as fecha_apertura
		,a.monto_autorizado as monto_linea
		,b.fecha_vencim as fecha_cancela
		,'NO' as bandera_act
		,b.fecha_vencim as fecha_ven_pres
		,b.ejecutivo as ejecutivo
		--canal variable para subconsulta
		,b.bandera_fi_fo as canal
		,a.fecha_hora as hora_transacc
		,f.localidad as localidad    
		,nvl(md.sdo_cap_insoluto,0) as sdo_cap_insoluto
		,nvl(md.sdo_retenido,0) as sdo_retenido
		,nvl(md.sdo_intereses,0) as sdo_intereses
		,0 as status_p
		,v_fecha_sistema as fecha_reporte
	FROM  bdicred:sd_maecredcrd b 
		join bdisolic:ss_solicitudes a on a.empresa = b.empresa  AND a.num_solicitud=b.num_credito
		join bdinteg:si_sucursales e on e.sucursal = b.sucursal
		join bdicred:sd_maecredanexocrd f on f.empresa = b.empresa AND b.num_credito = f.num_credito
		join bdicred:sd_maesdoscrd md on md.num_credito = b.num_credito
	WHERE b.num_producto IN( '9100','9300') 
	and b.num_Credito not in (select num_Credito from bdicred:sd_rep_p_personales where fecha_reporte = v_fecha_sistema AND status_p = '1')
	INTO temp tmp_reppersonales with no log;
	CREATE INDEX idx_tmp_reppersonales on tmp_reppersonales(status_p, fecha_reporte);

-- ****************************************************************************
-- *                 PROCESAMIENTO DE INFORMACION                             *

	SELECT count(*) into p_pers_proc from "informix".tmp_reppersonales;

	--PROCESAMIENTO DE INFORMACION Reporte_P_Personales_DDMMYYYY
	EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, v_cod_ret, "4_ Procesa informacion para Reporte_P_Personales_"||TRIM(sFechaArch)||".txt"||" Registros: "||p_pers_proc, '02')
	INTO cCodRetBit;
	
	--Procesamiento para Reporte_P_Personales_DDMMYYYY.txt		
	FOREACH WITH HOLD
	select 
	num_credito,numcte,sucursal,nombresuc,dispuesto,fecha_dis,plazo,fech_ult_pago,status_cred	-- ,total_liquidacion
	,cap_vig,cap_trans,cap_vdo_exig,pagos_vdos,fecha_apertura,monto_linea,fecha_cancela,bandera_act,fecha_ven_pres,ejecutivo,canal,hora_transacc ::DATETIME YEAR to SECOND
	,localidad,sdo_cap_insoluto,sdo_retenido,sdo_intereses
	INTO
	v_credito,v_numcliente,v_sucursal,v_nombresuc,v_monto_dispuesto,v_fecha_origen,v_plazo,v_fecha_ult_pago,v_estatus --,v_total_liquidacion
	,v_cap_vig,v_cap_trans,v_cap_vdo_exig,v_pagos_vdos,v_fecha_otorga,v_monto_linea,v_fecha_cancela,v_activacion_bandera,v_fecha_vencim,v_Ejecutivo,v_Canal,v_fecha_hora
	,v_Id_Atm,v_sdo_cap_insoluto,v_sdo_retenido,v_sdo_intereses
	from bdicred:tmp_reppersonales 
	
		IF v_fecha_ult_pago = DATE (1) or v_fecha_ult_pago is NULL THEN
			LET v_fecha_ult_pago = " ";
			LET v_fecha_last_pay = " ";
		ELSE
			LET v_fecha_last_pay = TO_CHAR(v_fecha_ult_pago,'%d/%m/%Y');
		END IF;		
	
		LET v_fecha_appertura = TO_CHAR(v_fecha_otorga,'%d/%m/%Y');
		LET vc_fecha_cancela = TO_CHAR(v_fecha_cancela,'%d/%m/%Y');
		LET vc_fecha_vencim = TO_CHAR(v_fecha_vencim,'%d/%m/%Y');
	
		if vc_fecha_cancela is null then
			let vc_fecha_cancela='';
		end if;
	
		if vc_fecha_vencim is null then
			let vc_fecha_vencim='';
		end if;
		--RQI 27 240 Se agrega el valor de Fecha de disposicion
		LET v_fecha_dispos = TO_CHAR(v_fecha_origen,'%d/%m/%Y');
	
		IF v_Ejecutivo IS NULL THEN LET v_Ejecutivo = ''; END IF;
		IF v_Canal IS NULL THEN LET v_Canal = ''; END IF;
		IF v_Id_Atm IS NULL THEN LET v_Id_Atm = ''; END IF;
		-- Consulta el nombre del canal
		SELECT nombre_canal INTO v_Nomb_Canal FROM bdinteg:si_canal WHERE cve_canal = v_Canal;
		
		IF v_Nomb_Canal = '98000' OR v_Nomb_Canal = '' OR v_Nomb_Canal IS NULL THEN LET v_Nomb_Canal = 'SMS'; END IF;
	
		LET v_nombresuc = replace(replace(replace(replace(v_nombresuc,'(',''),')',''),'|',''),'/','');
		LET v_Hora_Tran = extend(v_fecha_hora,hour to second);
	
		--===================================================================================================================================
		SELECT NVL(a.iva_fecha_pago,0), NVL(a.fecha_cuota,0)
		INTO dtIvaFechaPag,dtFechaCuota
		FROM bdicred:"informix".sd_amortiza_creditocrd a
		WHERE a.empresa = p_empresa AND a.num_credito = v_credito AND a.capital_status = "3";
	
		SELECT iva
		INTO dIvaSuc
		FROM bdinteg:"informix".si_sucursales
		WHERE sucursal = v_sucursal AND empresa  = p_empresa;

		CALL bdicred:"informix".calc_iva_grav_pp(p_empresa,v_credito,vd_tasa_interes_prestamo,dIvaSuc,v_fecha_hoy, dtIvaFechaPag,v_fecha_origen,dtFechaCuota,v_sdo_intereses)
		RETURNING cCodRet,dIvaIntDevengado,cMensajeRet;
	
		IF cCodRet <> "000000" THEN
			LET cCodRet = '000005';
		ELSE       
			CALL bdicred:"informix".sp_obtener_pagomin(p_empresa,v_credito)
			RETURNING vvcodigo_retorno, cMensajeRet, dPagoMinimo, dIntVdo, dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;
		
			LET dSdoActInt = NVL(dIntVig,0) + NVL(dIntVdo,0) + NVL(dIntMoratorio,0);
			LET dSdoActIvaInt = NVL(dIvaIntVig,0) + NVL(dIvaIntVdo,0) + NVL(dIvaIntMoratorio,0);        
		
			IF vvcodigo_retorno <> '000000' THEN
				LET cCodRet= '000008';
			ELSE
				LET dComPend = 0;
				LET dIvaCom  = 0;
				LET v_total_liquidacion = NVL(v_sdo_cap_insoluto,0) + NVL(dIntVdo,0) + NVL(dIvaIntVdo,0) + NVL(dIntMoratorio,0) + NVL(dIvaIntMoratorio,0) + NVL(v_sdo_retenido,0) + NVL(dComPend,0) + NVL(dIvaCom,0) + NVL(v_sdo_intereses,0) + NVL(dIvaIntDevengado,0) + NVL(dIntVig,0) + NVL(dIvaIntVig,0);
			
				IF ( v_total_liquidacion < 0 ) THEN
					LET v_total_liquidacion = 0;
				END IF;
			END IF;        
		END IF;

		--Actualizacion de tabla  sd_rep_p_personales
		BEGIN;	
			INSERT INTO bdicred:sd_rep_p_personales values(v_credito,v_numcliente,v_sucursal,v_nombresuc,v_monto_dispuesto,v_fecha_origen,v_plazo,v_fecha_ult_pago,v_estatus,v_total_liquidacion,v_cap_vig,v_cap_trans,v_cap_vdo_exig,v_pagos_vdos,v_fecha_otorga,v_monto_linea,v_fecha_cancela,v_activacion_bandera,v_fecha_vencim,v_Ejecutivo,v_Nomb_Canal,v_fecha_hora,v_Id_Atm,v_sdo_cap_insoluto,v_sdo_retenido,v_sdo_intereses,1,v_fecha_sistema);
		COMMIT;

	END FOREACH;

	--Conteo para validar si ya se genero el reporte Reporte_Diario_P_Flexible_DDMMYYYY.txt del dia actual
	SELECT count(*) into p_d_flex_proc FROM bdicred:sd_rep_p_diario_personales WHERE fecha_reporte = v_fecha_sistema LIMIT 1;
	
	IF p_d_flex_proc = 0 THEN
		--AJUSTAR SALIDA CON UNLOAD
		-- Crea encabezado de reporte para Reporte_Diario_P_Flexible_DDMMYYYY.txt
		LET v_sql =
		'echo '||'Fecha Consultada MM/DD/AAAA'||v_sepa||'Cantidad Prestamos Digitales Autorizados'||v_sepa||'Monto de Prestamos Autorizados'||v_sepa
			   ||'Cantidad de Prestamos Dispuestos'||v_sepa||'Monto de Prestamos Dispuestos'||' >>'||TRIM(cRuta)||'Reporte_Diario_P_Flexible_'||TRIM(sFechaArch)||'.txt';
		SYSTEM v_sql;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, v_cod_ret, "5_ Procesa informacion para Reporte_Diario_P_Flexible_"||TRIM(sFechaArch)||".txt ", '02')
		INTO cCodRetBit;
		
		select count(fecha_otorga), nvl(sum(monto_linea), 0)
		INTO v_num_autorizados,v_monto_autorizados
		from bdicred:sd_linea_prestamo
		where fecha_otorga=v_dia_ant;
					
		SELECT count(*), nvl(sum(monto),0)
		INTO  v_num_dispuestos,v_monto_dispuestos
		from bdicred:sd_movhiscrd
		where codigo_fun = '002'
		and codigo_ref in (66,119)
		and num_producto ='6800'
		and fecha_mov = v_dia_ant;
		
		--Se guarda el reporte 
		BEGIN;
			INSERT INTO bdicred:sd_rep_p_diario_personales VALUES (v_dia_ant, v_num_autorizados,v_monto_autorizados, v_num_dispuestos, v_monto_dispuestos, 1, v_fecha_sistema);
		COMMIT;
		--AJUSTAR SALIDA
		LET v_sql = 'echo '||v_dia_ant||v_sepa||v_num_autorizados||v_sepa||v_monto_autorizados||v_sepa||v_num_dispuestos||v_sepa||v_monto_dispuestos||' >>'||TRIM(cRuta)||'Reporte_Diario_P_Flexible_'||sFechaArch||'.txt';
		SYSTEM v_sql;
	END IF;
	
	SELECT count(*) into p_flex_proc from "informix".tmp_reppflex ;
	
	--PROCESAMIENTO DE INFORMACION Reporte_P_Flexible_DDMMYYYY
	EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, v_cod_ret, "6_ Procesa informacion para Reporte_P_Flexible_"||TRIM(sFechaArch)||".txt "||" Registros: "||p_flex_proc, '02')
	INTO cCodRetBit;
	
	-- Llenado de REPORTE Reporte_P_Flexible_DDMMYYYY.txt
	FOREACH WITH HOLD
	select 
	num_credito,disposicion,numcte,sucursal,nombresuc,dispuesto,fechadisp,plazo,fecha_ult_pago,status_cred	--,total_liquidacion
	,cap_vig,cap_trans,cap_vdo_exig,pagos_vdos,fecha_apertura,monto_linea,fecha_cancela,bandera_act,fecha_ven_pres,ejecutivo,canal,hora_transacc ::DATETIME YEAR to SECOND
	,localidad,fecha_ven_lin,acepto_incremento,tasa_interes,sdo_cap_insoluto,sdo_retenido,sdo_intereses
	into 
	v_credito,v_disposicion,v_numcliente,v_sucursal,v_nombresuc,v_monto_dispuesto,v_fecha_origen,v_plazo,v_fecha_ult_pago,v_estatus,	--v_total_liquidacion,
	v_cap_vig,v_cap_trans,v_cap_vdo_exig,v_pagos_vdos,v_fecha_otorga,v_monto_linea,v_fecha_cancela,vbanderaact,v_fecha_vencim,	v_Ejecutivo,v_Canal,v_Hora_Transaccion,
	v_Id_Atm,v_fecha_venc_linea,vc_acepto_incremento,vd_tasa_interes_prestamo,v_sdo_cap_insoluto,v_sdo_retenido,v_sdo_intereses
	from bdicred:tmp_reppflex
	
		--BEGIN WORK
		LET cFolioOneClick		= '';
		LET cTasaFormaliza		= '';
		LET cSucursalFormaliza	= '';
		LET cPromotorFormaliza	= '';
		LET cCanalFormaliza		= '';
	
		SELECT NVL(folio_preaprobado,''), NVL(tasa,'')
		INTO   cFolioOneClick, cTasaFormaliza
		FROM   bdicred:sd_pre_aprobados_trx 
		WHERE  numcte = v_numcliente AND solicitud = v_credito;
		
		IF cFolioOneClick = '' OR cFolioOneClick IS NULL THEN
			SELECT
			NVL(folio_preaprobado,''), NVL(tasa,'')
			INTO   cFolioOneClick, cTasaFormaliza
			FROM   bdicred:sd_pre_aprobados_his 
			WHERE  numcte = v_numcliente AND solicitud = v_credito;						
		END IF;
	
		IF cFolioOneClick IS NULL THEN LET cFolioOneClick = ''; END IF;
		IF cTasaFormaliza IS NULL THEN LET cTasaFormaliza = ''; END IF;
		
		IF cFolioOneClick <> '' THEN
			LET cSucursalFormaliza = v_sucursal;
			
			SELECT NVL(ejecutivo_auto,'0') 
			INTO   cPromotorFormaliza
			FROM   bdisolic:ss_autorizacion 
			WHERE  num_solicitud = v_credito AND status_solicitud = 'AP';
			
			IF cPromotorFormaliza = '0' OR cPromotorFormaliza = '' OR cPromotorFormaliza = 0 OR cPromotorFormaliza IS NULL THEN
				LET cCanalFormaliza = 'APP';
			ELSE
				LET cCanalFormaliza = 'SUCURSAL';
			END IF;
		END IF;
		
		IF cPromotorFormaliza IS NULL THEN LET cPromotorFormaliza = ''; END IF;
		
		IF v_disposicion = 0 THEN
			LET v_fecha_origen = '';
			LET v_fecha_dispos = "";
			LET v_monto_dispuesto = 0;
		ELSE
			LET v_fecha_dispos = TO_CHAR(v_fecha_origen,'%d/%m/%Y');
		END IF;
	
		IF v_fecha_ult_pago = DATE (1) or v_fecha_ult_pago is NULL THEN
			LET v_fecha_ult_pago = '';
			LET v_fecha_last_pay = " ";
		ELSE
			LET v_fecha_last_pay = TO_CHAR(v_fecha_ult_pago,'%d/%m/%Y');
		END IF;		
		
		LET v_fecha_appertura = TO_CHAR(v_fecha_otorga,'%d/%m/%Y');
		LET vc_fecha_cancela = TO_CHAR(v_fecha_cancela,'%d/%m/%Y');
		LET vc_fecha_vencim = TO_CHAR(v_fecha_vencim,'%d/%m/%Y');
		LET vc_fecha_venc_linea = TO_CHAR(v_fecha_venc_linea,'%d/%m/%Y');
		
		if vc_fecha_cancela is null then
			let vc_fecha_cancela='';
		end if;
		
		if vc_fecha_vencim is null then
			let vc_fecha_vencim='';
		end if;
		
		if vc_fecha_venc_linea is null then
			let vc_fecha_venc_linea='';
		end if;
		
		IF v_Ejecutivo IS NULL THEN LET v_Ejecutivo = ''; END IF;
		IF v_Canal IS NULL THEN LET v_Canal = ''; END IF;
		IF v_Id_Atm IS NULL THEN LET v_Id_Atm = ''; END IF;
		-- Consulta el nombre del canal
		SELECT nombre_canal INTO v_Nomb_Canal FROM bdinteg:si_canal WHERE cve_canal = v_Canal;
		IF v_Nomb_Canal = '98000' OR v_Nomb_Canal = '' OR v_Nomb_Canal IS NULL THEN LET v_Nomb_Canal = 'SMS'; END IF;
		
		IF vbanderaact = '1' THEN 
			LET v_activacion_bandera= 'SI'; -- Linea de credito 6800 SI cancelada
		ELSE 
			LET v_activacion_bandera= 'NO'; -- Linea de credito 6800 cancelada
		END IF;
		
		--===================================================================================================================================		
		SELECT NVL(a.iva_fecha_pago,0), NVL(a.fecha_cuota,0)
		INTO dtIvaFechaPag,dtFechaCuota
		FROM bdicred:"informix".sd_amortiza_creditocrd a
		WHERE a.empresa = p_empresa AND a.num_credito = v_credito AND a.capital_status = "3";
		
		SELECT iva
		INTO dIvaSuc
		FROM bdinteg:"informix".si_sucursales
		WHERE sucursal = v_sucursal AND empresa  = p_empresa;
	
		CALL bdicred:"informix".calc_iva_grav_pp(p_empresa,v_credito,vd_tasa_interes_prestamo,dIvaSuc,v_fecha_hoy, dtIvaFechaPag,v_fecha_origen,dtFechaCuota,v_sdo_intereses)
		RETURNING cCodRet,dIvaIntDevengado,cMensajeRet;
			
		IF cCodRet <> "000000" THEN
			LET cCodRet = '000005';
			--LET cMensajeRet = 'Ocurrio un error al realizar calculo';
		ELSE   
	
			SELECT 0,
			0,
			NVL(SUM(NVL(interes_debe - interes_pagado,0)),0),
			NVL(SUM(NVL(iva_debe - iva_pagado,0)),0)
			INTO dIntMes,
			dIvaIntMes,
			dIntVig,
			dIvaIntVig
			FROM "informix".sd_amortiza_creditocrd
			WHERE empresa        = p_empresa
			AND num_credito    = v_credito
			AND capital_status = 1;
			
			SELECT SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),
			SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),
			SUM(NVL(iva_debe,0) - NVL(iva_pagado,0)),
			COUNT(num_credito),
			SUM (((NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0))* dIvaSuc)) 
			INTO dIntVdo,
			dIntMoratorio,
			dIvaIntVdo,
			dPagosVdos,
			dIvaIntMoratorio
			FROM "informix".sd_amortiza_creditocrd
			WHERE empresa     = p_empresa
			AND num_credito = v_credito
			AND capital_status IN ('2','7','6');
		
			/*CALL bdicred:"informix".sp_obtener_pagomin(p_empresa,v_credito)
			RETURNING vvcodigo_retorno, cMensajeRet, dPagoMinimo, dIntVdo, dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;*/
				
			LET dSdoActInt = NVL(dIntVig,0) + NVL(dIntVdo,0) + NVL(dIntMoratorio,0);
			LET dSdoActIvaInt = NVL(dIvaIntVig,0) + NVL(dIvaIntVdo,0) + NVL(dIvaIntMoratorio,0);        
	
			LET dComPend = 0;
			LET dIvaCom  = 0;	
			LET v_total_liquidacion = NVL(v_sdo_cap_insoluto,0) + NVL(dIntVdo,0) + NVL(dIvaIntVdo,0) + NVL(dIntMoratorio,0) + NVL(dIvaIntMoratorio,0) + 
			NVL(v_sdo_retenido,0) + NVL(dComPend,0) + NVL(dIvaCom,0) + NVL(v_sdo_intereses,0) + NVL(dIvaIntDevengado,0) + NVL(dIntVig,0) + NVL(dIvaIntVig,0);
				
			IF ( v_total_liquidacion < 0 ) THEN
				LET v_total_liquidacion = 0;
			END IF;	     
		END IF;
		
		--===================================================================================================================================
		LET v_nombresuc = replace(replace(replace(replace(v_nombresuc,'(',''),')',''),'|',''),'/','');
		LET v_Hora_Tran = extend(v_Hora_Transaccion,hour to second);
		
		--Actualizacion de tabla 
		BEGIN;
			insert into bdicred:sd_rep_p_flexible values (v_credito, v_disposicion, v_numcliente, v_sucursal, v_nombresuc, v_monto_dispuesto, v_fecha_origen, v_plazo,v_fecha_ult_pago, v_estatus, v_total_liquidacion, v_cap_vig, v_cap_trans, v_cap_vdo_exig, v_pagos_vdos, v_fecha_otorga, v_monto_linea, v_fecha_cancela, v_activacion_bandera, v_fecha_vencim, v_Ejecutivo, NVL(v_Nomb_Canal,""), v_Hora_Transaccion, v_Id_Atm, v_fecha_venc_linea, vc_acepto_incremento, vd_tasa_interes_prestamo,
			cFolioOneClick, cTasaFormaliza, cSucursalFormaliza, cPromotorFormaliza, cCanalFormaliza, v_sdo_cap_insoluto, v_sdo_retenido, v_sdo_intereses, 1, v_fecha_sistema);
		COMMIT;
	END FOREACH;
	
-- ****************************************************************************
-- *              DESCARGA DE INFORMACION DE LOS REPORTES                    *
	WHILE vRep <= 2 
	
		IF vRep = 1 THEN
				
			EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, v_cod_ret, "7_ Descarga informacion para Reporte_P_Flexible_"||TRIM(sFechaArch)||".txt ", '02')
			INTO cCodRetBit;
			
			LET vNomArch = 'Reporte_P_Flexible_';
			
			--DESCARGA DE INFORMACION PARA REPORTE Reporte_P_Flexible_
			LET vRegistro = "";
			LET vRegistro = "SELECT  "
				||" num_credito "
				||",disposicion "
				||",numcte "
				||",sucursal"
				||",nombresuc"
				||",dispuesto"
				||",TO_CHAR(fechadisp,'%d/%m/%Y')"
				||",plazo "
				||",TO_CHAR(fecha_ult_pago,'%d/%m/%Y')"
				||",status_cred"
				||",total_liquidacion"
				||",cap_vig"
				||",cap_trans"
				||",cap_vdo_exig"
				||",pagos_vdos"
				||",TO_CHAR(fecha_apertura,'%d/%m/%Y')"
				||",monto_linea"
				||",fecha_cancela"
				||",bandera_act"
				||",TO_CHAR(fecha_ven_pres,'%d/%m/%Y')"
				||",ejecutivo"
				||",canal"
				||",extend(hora_transacc,hour to second)"
				||",localidad"
				||",TO_CHAR(fecha_ven_lin,'%d/%m/%Y') "
				||",acepto_incremento"
				||",tasa_interes"
				||",folio_one_click"
				||",tasa"
				||",sucursal_formaliza"
				||",ejecutivo_auto"
				||",canal_formaliza"
				||" FROM bdicred:sd_rep_p_flexible WHERE fecha_reporte = mdy('"
				||sMes||"','"||sDia||"','"||sYear||"') AND status_p = '1';";
				
			LET v_enc = '';
			LET v_enc = ' awk ''BEGIN {FS="|"; OFS="|"; print "No. de credito","No. De disposicion","No. de cliente","No. de sucursal","Nombre de sucursal","Monto dispuesto","Fecha de disposicion","plazo","Fecha de ultimo pago","Estatus","Saldo insoluto","Capital Vigente","Capital transitorio","Capital vencido exigible","Meses Vencidos","Fecha Apertura","Monto Linea","Fecha de cancelacion","Activacion de bandera","Fecha de vencimiento del prestamo","Ejecutivo","Canal","Hora Transaccion","Id ATM","Fecha Vencimiento Linea","Acepto Incremento","Tasa","Folio OneClick","Tasa","Sucursal formaliza","Ejecutivo formaliza","Canal formaliza"} {print $0} '' ';
			
		ELSE
			LET vNomArch = 'Reporte_P_Personales_';
			
			EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, v_cod_ret, "8_ Descarga informacion para Reporte_P_Personales_"||TRIM(sFechaArch)||".txt ", '02')
			INTO cCodRetBit;
			
			--DESCARGA DE INFORMACION PARA REPORTE Reporte_P_Personales_
			LET vRegistro = "";
			LET vRegistro = "SELECT  "
				||"num_credito,"
				||"numcte,"
				||"sucursal,"
				||"nombresuc,"
				||"dispuesto,"
				||"TO_CHAR(fecha_dis,'%d/%m/%Y'),"
				||"plazo,"
				||"TO_CHAR(fecha_ult_pago,'%d/%m/%Y'),"
				||"status_cred,"
				||"total_liquidacion,"
				||"cap_vig,"
				||"cap_trans,"
				||"cap_vdo_exig,"
				||"pagos_vdos,"
				||"TO_CHAR(fecha_apertura,'%d/%m/%Y'),"
				||"monto_linea,"
				||"TO_CHAR(fecha_cancela,'%d/%m/%Y'),"
				||"bandera_act,"
				||"TO_CHAR(fecha_ven_pres,'%d/%m/%Y'),"
				||"ejecutivo,"
				||"canal,"
				||"extend(hora_transacc,hour to second),"
				||"localidad"
				||" FROM bdicred:sd_rep_p_personales WHERE fecha_reporte = mdy('"
				||sMes||"','"||sDia||"','"||sYear||"') AND status_p = '1';";
				
			
			LET v_enc = '';
			LET v_enc = ' awk ''BEGIN {FS="|"; OFS="|"; print "No. de credito","No. de cliente","No. de sucursal","Nombre de sucursal","Monto dispuesto","Fecha de disposicion","plazo","Fecha de ultimo pago","Estatus","Saldo insoluto","Capital Vigente","Capital transitorio","Capital vencido exigible","Meses Vencidos","Fecha Apertura","Monto Linea","Fecha de cancelacion","Activacion de bandera","Fecha de vencimiento del prestamo","Ejecutivo","Canal","Hora Transaccion","Id ATM"} {print $0} '' ';
			
		END IF;
	
		--SE ELIMINA EL ARCHIVO SQL BASE
		LET v_sql = '';
		LET v_sql = 'rm -rf '||TRIM(cRuta)||TRIM(vArchivoSql)||'.sql';
		SYSTEM TRIM(v_sql);
		
		-- SE EJECUTA LA CONSULTA Y GUARDA EN UN ARCHIVO SQL BASE
		LET v_sql = '';
		LET v_sql = 'echo " UNLOAD TO '||TRIM(cRuta)||TRIM(vNomArch)||TRIM(sFechaArch)||'.unl'||' DELIMITER ''|'' '||TRIM(vRegistro)||' " > '||TRIM(cRuta)||TRIM(vArchivoSql)||'.sql';
		
		SYSTEM TRIM(v_sql);
		
		-- SE ORTORGAN LOS PERMISOS
		LET v_sql = '';
		LET v_sql = 'chmod 777 '||TRIM(cRuta)||TRIM(vArchivoSql)||'.sql';
		SYSTEM TRIM(v_sql);	
		
		-- SE EJECUTA EL ARCHIVO BASE
		LET v_sql = '';
		LET v_sql = 'dbaccess bdicred '||TRIM(cRuta)||TRIM(vArchivoSql)||'.sql';
		SYSTEM TRIM(v_sql);
		
		--SE ELIMINA EL ARCHIVO BASE
		LET v_sql = '';
		LET v_sql = 'rm -rf '||TRIM(cRuta)||TRIM(vArchivoSql)||'.sql';
		SYSTEM TRIM(v_sql);
		
		-- PERMISOS AL ARCHIVO UNL GENERADO
		 LET v_sql = '';
		 LET v_sql = 'chmod 777 '||TRIM(cRuta)||TRIM(vNomArch)||TRIM(sFechaArch)||'.unl';
		 SYSTEM TRIM(v_sql);
		
		LET v_sql = '';
		LET v_sql = TRIM(v_enc)||" "||TRIM(cRuta)||TRIM(vNomArch)||TRIM(sFechaArch)||".unl > " ||TRIM(cRuta)||TRIM(vNomArch)||TRIM(sFechaArch)||".txt";
		SYSTEM v_sql;
	
		--SE ELIMINA EL ARCHIVO UNL GENERADO
		LET v_sql = '';
		LET v_sql = 'rm -rf '||TRIM(cRuta)||TRIM(vNomArch)||TRIM(sFechaArch)||'.unl';
		SYSTEM TRIM(v_sql);
		
		LET vRep = vRep+1;
	END WHILE;
	
	EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, v_cod_ret, "9_ Depuracion de tablas con informacion antes del "||v_fecha_depura, '02')
	INTO cCodRetBit;
	--Limpieza de registros de 3 dias si el proceso temina con exito
	IF v_cod_ret = "000000" THEN
		delete bdicred:sd_rep_p_flexible WHERE fecha_reporte < v_fecha_depura;
		delete bdicred:sd_rep_p_personales WHERE fecha_reporte < v_fecha_depura;
		delete bdicred:sd_rep_p_diario_personales WHERE fecha_reporte < v_fecha_depura;
	END IF;
	
	EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, v_cod_ret, "10_ Eliminacion tablas temporales", '02')
	INTO cCodRetBit;
	
	--Limpieza de tablas temporales si el proceso temina con exito
	IF v_cod_ret = "000000" THEN
		DROP TABLE tmp_reppflex;
		DROP TABLE tmp_reppersonales;
	END IF;
	
END

EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, v_cod_ret, "11_ FIN EXITOSO DE PROCESO DE REPORTES DE PRESTAMO FLEXIBLE", '03')
INTO cCodRetBit;

RETURN v_cod_ret;

END PROCEDURE
DOCUMENT
'Modif : Se agrega campos acepto_incremneto y tasa_interes al reporte Reporte_P_Flexible',
'Fecha : 2023-07-17',
'Autor : Arturo Acosta',
'------------------------------------------------------------------------------------------------',
'Modif : Se agregan 5 campos para la funcionalidad de One Click, (cFolioOneClick, cTasaFormaliza,',
'        cSucursalFormaliza, cPromotorFormaliza, cCanalFormaliza) al reporte Reporte_P_Flexible',
'Fecha : 2023-10-09',
'Autor : Rodolfo Javier Tortolero Varela',
'------------------------------------------------------------------------------------------------',
'Modif : Se optimiza sp_reporte_prestamoflex',
'Fecha : 2025-10-21',
'Autor : Agustin Garcia Olmos - Cinthia Aguilar',
------------------------------------------------------------------------------------------------',
'Modif : Se optimiza sp_reporte_prestamoflex, se reduce universo del reporte 6800',
'Fecha : Enero-2026',
'Autor : Cinthia Aguilar';

CREATE PROCEDURE "informix".sp_genera_carteraenlinea_tab_tdc(pEmpresa char(3)) 

RETURNING  CHAR(6) AS Cod_Ret,  CHAR(80) AS Mens_Ret;

-- Creador por: MAHR. Abril 2012. Se crea la informacion de la Cartera en linea dentro de la tabla sd_sdos_cartera_linea, a fin de que los 
--             diversos procesos que explotan la misma informacion la obtengan de dicha tabla, optimizando los tiempos de consulta.
-- Servicios: 1.- Tarjeta de Credito, 2.- Prestamo Personal y Reestructura 3.- AMBOS.

-- Se modifica el proceso para agregar campos solicitados en el RQM 09 463 - Agosto 2017. ADLM.
--Declaracion de variables
-- V.2 JAHJ Septiembre 2023  
DEFINE sql_err          INTEGER;
DEFINE isam_err         INTEGER;
DEFINE error_info       CHAR(80);
DEFINE cEmpresa         CHAR(3);
DEFINE cProceso         CHAR(4);
DEFINE cCod_ret         CHAR(6);
DEFINE cCod_retBit      CHAR(6);
DEFINE cMensajeRet      CHAR(125);  
DEFINE cruta            CHAR(100);
DEFINE cSQL             CHAR(8204);
DEFINE cSQL1            CHAR(6204);
DEFINE cSQL2            CHAR(6204);
DEFINE vcliente         CHAR(20);
DEFINE vcredito         CHAR(20);
DEFINE vtarjeta         CHAR(20);
DEFINE vcta_eje         CHAR(20);
DEFINE vproducto        CHAR(4);
DEFINE vstatuscred      CHAR(2);
DEFINE vsucursal        CHAR(4);
DEFINE vcat             CHAR(6);
DEFINE dFecha_hoy       DATE;
DEFINE dFecha_max       DATE;
DEFINE dFecha_min       DATE;
DEFINE dFecha_ayer      DATE;
DEFINE dFecha_today 	DATE;
DEFINE vfechaultpago	DATE;
DEFINE vfch_apertura    DATE;
DEFINE vproxfchpago     DATE;
DEFINE cfechavencto, cfechavencto1, cfechavencto2, cfechavencto3, cfechavencto4, cfechavencto5 DATE;
DEFINE cfecha_habil1, cfecha_habil2, cfecha_habil3, cfecha_habil4, cfecha_habil5 DATE;
DEFINE vtasainteres     DECIMAL(9,6);
DEFINE ctasamora        DECIMAL(9,6);
DEFINE vmontootorgado,  vsdo_intereses, vmensualidad_act	 DECIMAL(18,2);
DEFINE vsdo_capital,   vmonto_vencido, vmtovenctrasp, vcaptrasnovenci, vsdocapinsoluto	DECIMAL(18,2);
DEFINE montofinanciado,vsdomoratorio,  vinteresiva,   vmoras,          pagounamora    	DECIMAL(18,2);
DEFINE cSaldovencido1, cSaldovencido2, cSaldovencido3,cSaldovencido4,  cSaldovencido5   MONEY(18,2);
DEFINE cSaldovencido6, cInteresmoratorio1, cInteresmoratorio2, cInteresmoratorio3       MONEY(18,2);
DEFINE cInteresmoratorio4, cInteresmoratorio5, cInteresmoratorio6, cInteresV            MONEY(18,2);
DEFINE mIvaSucursal     MONEY(5,3);
DEFINE sAbonosVdos      INTEGER;
DEFINE sDiasTrans       INTEGER;
DEFINE sDiaCorte        SMALLINT;
DEFINE vgrupo			CHAR(1);
DEFINE vantiguedad		INTEGER;
DEFINE vbcscore			DECIMAL(5,2);
DEFINE vscoreprop		DECIMAL(5,2);
DEFINE vficoscore		DECIMAL(5,2);
DEFINE vbhscore			DECIMAL(5,2);
DEFINE vnovencidos1		INTEGER;
DEFINE vnovencidos2		INTEGER;
DEFINE vnovencidos3		INTEGER;
DEFINE vnovencidos4		INTEGER;
DEFINE vnovencidos5		INTEGER;
DEFINE vnovencidos6		INTEGER;
DEFINE vcelular			CHAR(13);
DEFINE vivatrasp		DECIMAL(18,2);
DEFINE vretenido        DECIMAL(18,2);
DEFINE cAct                     INTEGER;
DEFINE cAtr                     INTEGER;

DEFINE v_fecha_vencido  DATE;
DEFINE v_num_vencidos   INTEGER;
DEFINE dPagosVdos       INTEGER;
DEFINE v_dias_vencido   INTEGER;
DEFINE dUltDisp_atm     DATE;
DEFINE dUltDisp_pos     DATE;
DEFINE dUltDisp_vnt     DATE;
DEFINE dUltima_Disposicion DATE;
DEFINE v_ejecutivo CHAR(8);
DEFINE v_cuenta_bloque  integer;

--SET DEBUG FILE TO "/ifxsif01/PEDRO/cartelinea/sp_genera_carteraenlinea_tab.out";
--TRACE ON;

--Inicializacion de variables
LET sql_err         = 0;
LET isam_err        = 0;
LET error_info      = "";
LET cEmpresa        = "";
LET cProceso        = '0201';
LET cCod_Ret        = '00000';
LET cCod_retBit     = '00000';
LET cMensajeRet     = 'PROCESO EXITOSO';
LET cSQL            = '';
LET cSQL1           = '';
LET cSQL2           = '';
LET cruta           = '';
LET	vcliente        = '';
LET	vcredito        = '';
LET	vtarjeta        = '';
LET	vcta_eje        = '';
LET	vproducto       = '';
LET	vstatuscred     = '';
LET	vsucursal       = '';
LET	vcat            = '';
LET	vsdo_capital    = 0;    LET vmonto_vencido	= 0;    LET vmtovenctrasp  = 0;     LET vcaptrasnovenci    = 0; LET vsdocapinsoluto     = 0; 
LET pagounamora     = 0;    LET montofinanciado = 0;    LET vsdomoratorio  = 0;     LET vinteresiva        = 0; LET vmoras              = 0; 
LET vmontootorgado  = 0;    LET vtasainteres    = 0;    LET ctasamora      = 0;     LET cSaldovencido1     = 0; LET cSaldovencido2      = 0; 
LET cSaldovencido3  = 0;    LET cSaldovencido4  = 0;    LET cSaldovencido5 = 0;     LET cSaldovencido6     = 0; LET cInteresmoratorio1  = 0; 
LET cInteresmoratorio2 = 0; LET cInteresmoratorio3 = 0; LET cInteresmoratorio4 = 0; LET cInteresmoratorio5 = 0; LET cInteresmoratorio6  = 0; 
LET mIvaSucursal       = 0; LET sAbonosVdos     = 0;    LET sDiasTrans     = 0;     LET vsdo_intereses     = 0; LET vmensualidad_act   = 0;
LET sDiaCorte          = 0; 
LET vgrupo			= "";
LET vantiguedad		= 0;
LET vbcscore		= 0;
LET vscoreprop		= 0;
LET vficoscore		= 0;
LET vbhscore		= 0;
LET vnovencidos1	= 0;
LET vnovencidos2	= 0;
LET vnovencidos3	= 0;
LET vnovencidos4	= 0;
LET vnovencidos5	= 0;
LET vnovencidos6	= 0;
LET vcelular		="";
LET vivatrasp		= 0;
LET vretenido       = 0;
LET dFecha_hoy      = date(1);
LET dFecha_max      = date(1);
LET dFecha_min      = date(1);
LET dFecha_ayer		= date(1);
LET dFecha_today	= date(1);
LET cAct                        = 0;
LET cAtr                        = 0;

LET v_fecha_vencido  = DATE(1);
LET v_num_vencidos   =0;
LET dPagosVdos       =0;
LET v_dias_vencido   =0; 
LET dUltDisp_atm  = DATE(1);
LET dUltDisp_pos  = DATE(1);
LET dUltDisp_vnt  = DATE(1);
LET dUltima_Disposicion = DATE(1);
LET v_ejecutivo ="";
LET v_cuenta_bloque = 0;

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensajeRet = error_info;        
            -- Validamos si ya se encuentra creada la tabla
					
		DROP TABLE IF EXISTS "informix".creditossl_tab2;	
			
--       IF EXISTS( SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'creditossl_tab2' ) THEN
--          DROP TABLE creditossl_tab2;
--		 END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet || ' Error en cart_tab', '02') RETURNING cCod_retBit;
        RETURN cCod_ret,cMensajeRet;
    END EXCEPTION;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'INICIA sp_genera_carteraenlinea_tab ', '02') RETURNING cCod_retBit;       

    --Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- Obtener la fecha del dia de hoy
    SELECT fecha_hoy, fecha_ant INTO dFecha_hoy, dFecha_ayer FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa; 
	IF dFecha_hoy IS NULL THEN
        LET dFecha_hoy = Today;
		LET dFecha_ayer = today - 1;
    END IF
    
    --LET dFecha_hoy = MDY(10,15,2025);
	--LET dFecha_ayer = MDY(10,14,2025);
	
	--Validacion de la empresa
    SELECT empresa INTO cEmpresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa;
    IF NVL (cEmpresa, '') = '' OR cEmpresa IS NULL THEN
        LET pEmpresa = '001';
		LET dFecha_ayer = today - 1;
    END IF;

CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'Empresa validada', '02') RETURNING cCod_retBit;  
	--Obtener ruta del archivo
    SELECT TRIM(valor_alfabetico) INTO cruta
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pEmpresa AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS'AND num_parametro = 34;  
    IF NVL (cruta,'') = '' THEN     --Valida que exista la carpeta
        LET cCod_Ret= '104005';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'Ruta incorrecta - sp_genera_carteraenlinea_tab', '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;
	
--	LET cruta='/ifxsif01/90260202/marco/';							--  <--    ***********************  comentar esta linea 
	
	-- Validamos si ya se encuentra creada la tabla.
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'ruta validada', '02') RETURNING cCod_retBit;  
	DROP TABLE  IF EXISTS creditossl_tab2;
	

    -- Elimina la informacion almacenada, generada el dia anterior. -- Se modifica para que no borre lo que ya existe si ya existe informacion procesada del dia.
     --Delete from bdicred:"informix".sd_sdos_cartera_linea;
	SELECT max(fecha), min(fecha) INTO dFecha_max, dFecha_min FROM bdicred:sd_sdos_cartera_linea;
	LET dFecha_today = today;

	IF dFecha_max = dFecha_min AND dFecha_max = dFecha_ayer AND dFecha_max = (dFecha_today - 1)
			THEN
	--	LET pServicio = '2';										-- Si ya existe informacion no elimine tabla y solo ejecute prestamo.
		LET dFecha_hoy = dFecha_ayer;
	ELSE
		TRUNCATE bdicred:"informix".sd_sdos_cartera_linea;   		-- Elimine si es un nuevo dia. 
	END IF;
	

	
    -- | Cliente | Credito | Tarjeta | Cuenta eje | Producto | sdo_capital | monto_vencido | mto_venc_trasp | cap_tras_no_venci | sdo_cap_insoluto | 
    -- | monto financiado | Int moratorio | interes_iva | No moras | status_cred | fecha_ult_pago | pago una mora | Sucursal | Fecha_apertura |  
    -- | monto_otorgado | tasa_interes | prox_fecha_pago | Cat | saldovencido1 |saldovencido2 |saldovencido3 | saldovencido4 | saldovencido5 |
    -- | saldovencido6 | interesmoratorio1 | interesmoratorio2 | interesmoratorio3 | interesmoratorio4 | interesmoratorio5 | interesmoratorio6 |


	    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'Paso 1: Obtiene info TDC', '02') RETURNING cCod_retBit;  


        --LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';


        LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || 'creditos_tab2.txt' 
                || ' select  {+INDEX(sd_maecred maesta)} a.empresa, a.numcte, a.num_credito , a.sucursal, a.status_cred, a.num_producto,'
                || ' a.fecha_apertura, a.tasa_interes, a.tasa_moratorios, (select max(b.fecha) from sd_maesdoshist b) fecha_his, a.ejecutivo '
                || ' from bdicred:sd_maecred a, bdicred:sd_maesdos d'
				--IFRS || ' where a.empresa = ''001'' '
				|| ' where a.num_credito = d.num_credito'
                || ' and (a.status_cred in (''BT'',''BA'',''E1'',''E2'',''E3'') and (d.monto_vencido + d.mto_venc_trasp) > 0 );  '
                --|| ' create temp table bdicred:creditossl_tab2 ' 
                || ' create table bdicred:creditossl_tab2 '
                || '(empresa 		char(3), '
                || ' numcte 		char(20), '
                || ' num_credito 	char(20), '
                || ' sucursal 		char(4), '
                || ' status_cred 	char(2), '
                || ' num_producto 	char(4), '
                || ' fecha_apertura date, '
                || ' tasa_interes   decimal(9,6), '
                || ' tasa_moratorios decimal(9,6), '
		        || ' fecha_his 		date, '
		        || ' ejecutivo 		char(8) '
                --|| ') with no log; ' 
                || '); '  
                || ' load from '|| TRIM(cruta) ||'creditos_tab2.txt insert into creditossl_tab2;  '
                || ' create unique index inx_creditossl_tab2 on creditossl_tab2(numcte,sucursal,num_credito);'
                || ' update statistics medium for table creditossl_tab2 resolution 1.6; ' ;
                /*||' SELECT {+INDEX(creditoss1 inx_creditoss1), +INDEX(bdinteg:si_direcciones_actual idx_diract_ctetpo)} a.*, numerociudad '
                ||' FROM creditossl a,  bdinteg:si_direcciones_actual d '
                || ' WHERE d.numcte = a.numcte '
                || ' AND d.tipo_dir = ''1'' '
                || ' into temp CreditoCiudad with no log; '*/
                --|| ' unload to '|| TRIM(cruta) || TRIM(cnomarchivo) ;



        LET cSQL2 = '">' || TRIM(cRuta) || 'Ejecuta_cart_linea_creatabla.sql';
        LET cSQL = trim(cSQL1) || cSQL2;
        SYSTEM cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)|| 'Ejecuta_cart_linea_creatabla.sql';
        SYSTEM cSQL;

        LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta_cart_linea_creatabla.sql';
        SYSTEM cSQL;

        --Borra el archivo de control.
        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || 'creditos_tab2.txt ' || TRIM(cruta) || 'Ejecuta_cart_linea_creatabla.sql';
        SYSTEM cSQL;


		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'Paso 3: Inicia Foreach Obtener info REVS monto,saldos,etc', '02') RETURNING cCod_retBit;  

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
        FOREACH WITH HOLD                
            SELECT a.numcte, a.num_credito, nvl(c.num_tarjeta,'0'), 0 Cuenta_eje, a.num_producto, b.sdo_capital, b.monto_vencido, 
                b.mto_venc_trasp, b.cap_tras_no_venci, b.sdo_cap_insoluto, b.monto_financiado, 
                round((b.sdo_moratorio + b.sdo_contab_mora) * (1+ s.iva),2) moratorio, nvl((select sum(interes_debe - interes_pagado) + 
                sum(iva_debe - iva_pagado) from bdicred:sd_amortiza_credito where a.empresa = empresa and a.num_credito = num_credito 
                and capital_status in ('2','7','6')),0) interes_iva, b.mto_fin_ven_trasp::integer mora_actual, a.status_cred, d.fecha_ult_pago, 
                nvl((select capital_debe - capital_pagado from bdicred:sd_amortiza_credito where a.empresa = empresa 
                and a.num_credito = num_credito and fecha_cuota = (select min(fecha_cuota) from bdicred:sd_amortiza_credito 
                where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6'))) + 
                round((b.sdo_moratorio + b.sdo_contab_mora) * (1+ s.iva),2) + (select sum(interes_debe - interes_pagado) + 
                sum(iva_debe - iva_pagado) from bdicred:sd_amortiza_credito where a.empresa = empresa and a.num_credito = num_credito 
                and capital_status in ('2','7','6')),0) pago_una_mora, a.sucursal, a.fecha_apertura, b.monto_otorgado, a.tasa_interes, 
                d.prox_fecha_pago, nvl((SELECT trim(valor) FROM bdicred:sd_param WHERE a.empresa = empresa and cod_param= '034'),'0') cat,
                1 + s.iva, a.tasa_moratorios, d.fecha_vencto, round(NVL(b.sdo_intereses,0) * (1 + s.iva),2),
                (b.monto_financiado - b.monto_vencido - b.mto_venc_trasp) mensualidad_actual, d.dia_corte, 
				(select resum.grupo from bdisolic:ss_resum_scor_fin resum where a.num_credito=resum.num_solicitud) grupo,
				trunc((dfecha_hoy - a.fecha_apertura)/30) antiguedad, 
				nvl(scr1.evaluacion,0), nvl(scr2.evaluacion,0), nvl(scr3.evaluacion,0), nvl(scr4.evaluacion,0),    --  ***************    cambio jahj Julio 2023
				nvl(mahis1.mto_fin_ven_trasp,0), nvl(mahis2.mto_fin_ven_trasp,0), nvl(mahis3.mto_fin_ven_trasp,0), --  ***************    cambio jahj Julio 2023
				nvl(mahis4.mto_fin_ven_trasp,0), nvl(mahis5.mto_fin_ven_trasp,0), nvl(mahis6.mto_fin_ven_trasp,0), --  ***************    cambio jahj Julio 2023
				cel.telefono, 0.00, CASE WHEN nvl(b.sdo_retenido,0) > 0 then nvl(b.sdo_retenido,0) else 0.00 end sdo_retenido,	b.act, 
				a.ejecutivo --  ***************    cambio jahj Julio 2023
                INTO
                vcliente, vcredito, vtarjeta, vcta_eje, vproducto, vsdo_capital, vmonto_vencido, vmtovenctrasp, vcaptrasnovenci, 
                vsdocapinsoluto, montofinanciado, vsdomoratorio, vinteresiva, vmoras, vstatuscred, vfechaultpago, pagounamora, vsucursal, 
                vfch_apertura, vmontootorgado, vtasainteres, vproxfchpago, vcat, mIvaSucursal, ctasamora, cfechavencto, vsdo_intereses,
                vmensualidad_act, sDiaCorte, vgrupo, vantiguedad, 
				vbcscore, vscoreprop, vficoscore, vbhscore,        									 --  ***************    cambio jahj Julio 2023
				vnovencidos1, vnovencidos2, vnovencidos3, vnovencidos4, vnovencidos5, vnovencidos6,      --  ***************    cambio jahj Julio 2023
				vcelular, vivatrasp, vretenido, cAct, 
				v_ejecutivo --  ***************    cambio jahj Julio 2023
            	from bdicred:creditossl_tab2 a       -- sd_maecred a   --  ***************    cambio jahj Julio 2023
                join bdicred:sd_maesdos b on (a.empresa = b.empresa and a.num_credito = b.num_credito) 
    			join bdicred:sd_maecredanexo d on (a.empresa = d.empresa and a.num_credito = d.num_credito) 
        		left outer join bdicred:sd_tarjeta c on (a.empresa = c.empresa and a.num_credito = c.num_credito and c.tipo_tarjeta = 'T' 
                                and secuencia = (select max(secuencia) from bdicred:sd_tarjeta where a.empresa = empresa 
                                and a.num_credito = num_credito and tipo_tarjeta = 'T')) 
				join bdinteg:si_sucursales s on ( s.empresa = a.empresa and s.sucursal = a.sucursal)
				
				left outer join bdisolic:ss_resumen_scoring scr1 on (a.num_credito=scr1.num_solicitud and scr1.seccion=1)
				left outer join bdisolic:ss_resumen_scoring scr2 on (a.num_credito=scr2.num_solicitud and scr2.seccion=2)
				left outer join bdisolic:ss_resumen_scoring scr3 on (a.num_credito=scr3.num_solicitud and scr3.seccion=3)
				left outer join bdisolic:ss_resumen_scoring scr4 on (a.num_credito=scr4.num_solicitud and scr4.seccion=4) 
				left outer join bdicred:sd_maesdoshist mahis1 on(a.num_credito=mahis1.num_credito and mahis1.fecha=add_months(a.fecha_his,-1)) --***** cambio jahj Julio 2023
				left outer join bdicred:sd_maesdoshist mahis2 on(a.num_credito=mahis2.num_credito and mahis2.fecha=add_months(a.fecha_his,-2)) --***** cambio jahj Julio 2023
				left outer join bdicred:sd_maesdoshist mahis3 on(a.num_credito=mahis3.num_credito and mahis3.fecha=add_months(a.fecha_his,-3)) --***** cambio jahj Julio 2023
				left outer join bdicred:sd_maesdoshist mahis4 on(a.num_credito=mahis4.num_credito and mahis4.fecha=add_months(a.fecha_his,-4)) --***** cambio jahj Julio 2023
				left outer join bdicred:sd_maesdoshist mahis5 on(a.num_credito=mahis5.num_credito and mahis5.fecha=add_months(a.fecha_his,-5)) --***** cambio jahj Julio 2023
				left outer join bdicred:sd_maesdoshist mahis6 on(a.num_credito=mahis6.num_credito and mahis6.fecha=add_months(a.fecha_his,-6)) --***** cambio jahj Julio 2023
				left outer join bdinteg:si_telefonos_actual cel on(a.numcte=cel.numcte and cel.secuencia=(select max(secuencia) 
																											from bdinteg:si_telefonos_actual
																											where a.numcte=numcte and tipo_tel=2 and status_tel='A'))
														
            IF NOT EXISTS (SELECT fecha, num_credito FROM bdicred:"informix".sd_sdos_cartera_linea 
                                                                      WHERE fecha = dFecha_hoy AND num_credito = vcredito) THEN

                -- Obtiene las fechas de meses de vencimiento
                IF cfechavencto IS NULL THEN LET cfechavencto = date(1); END IF;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 1 , sDiaCorte) INTO cCod_Ret, cfechavencto1, sDiasTrans;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 2 , sDiaCorte) INTO cCod_Ret, cfechavencto2, sDiasTrans;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 3 , sDiaCorte) INTO cCod_Ret, cfechavencto3, sDiasTrans;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 4 , sDiaCorte) INTO cCod_Ret, cfechavencto4, sDiasTrans;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 5 , sDiaCorte) INTO cCod_Ret, cfechavencto5, sDiasTrans;

                -- Valida que las fechas sean fechas habiles, si no obtiene la fecha habil correcta.
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto1,'+') INTO cCod_Ret, cfecha_habil1;
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto2,'+') INTO cCod_Ret, cfecha_habil2;
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto3,'+') INTO cCod_Ret, cfecha_habil3;
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto4,'+') INTO cCod_Ret, cfecha_habil4;
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto5,'+') INTO cCod_Ret, cfecha_habil5;
                IF cfechavencto1 <> cfecha_habil1 THEN LET cfechavencto1 = cfecha_habil1; END IF;
                IF cfechavencto2 <> cfecha_habil2 THEN LET cfechavencto2 = cfecha_habil2; END IF;
                IF cfechavencto3 <> cfecha_habil3 THEN LET cfechavencto3 = cfecha_habil3; END IF;
                IF cfechavencto4 <> cfecha_habil4 THEN LET cfechavencto4 = cfecha_habil4; END IF;
                IF cfechavencto5 <> cfecha_habil5 THEN LET cfechavencto5 = cfecha_habil5; END IF;

                SELECT
                    sum(case when fecha_cuota = cfechavencto then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota = cfechavencto1 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto1 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota = cfechavencto2 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto2 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota = cfechavencto3 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto3 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota = cfechavencto4 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto4 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota >= cfechavencto5 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota >= cfechavencto5 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0)), count(*)
                    INTO
                    cSaldovencido1, cInteresmoratorio1, cSaldovencido2, cInteresmoratorio2,cSaldovencido3, cInteresmoratorio3, cSaldovencido4, 
                    cInteresmoratorio4, cSaldovencido5, cInteresmoratorio5, cSaldovencido6, cInteresmoratorio6, cInteresV, sAbonosVdos
                    from bdicred:sd_amortiza_credito
                    where empresa = pEmpresa and num_credito = vcredito and fecha_cuota >= cfechavencto and capital_status in ('2','7','6');
                    
                    --NUEVOS CAMPOS ADENDUM RQM 04 127
              
                    SELECT num_vencidos, dias_atraso, nvl(atm_disp_fecha_h,''), nvl(pos_disp_fecha_h,''), nvl(vnt_disp_fecha_h,'') --fecha_vencido, 
                    INTO  v_num_vencidos, v_dias_vencido, dUltDisp_atm, dUltDisp_pos, dUltDisp_vnt  --v_fecha_vencido,
                    FROM sd_indicador_cred
                    WHERE num_credito=vcredito;
					
--  				***************    cambio jahj Julio 2023	 se toma la consulta en la parte de arriba		
--					select fecha_vencto
--					into v_fecha_vencido
--					from bdicred:sd_maecredanexo
--					where num_credito=vcredito;
                    
					Let v_fecha_vencido = cfechavencto;       --  ***************    cambio jahj Julio 2023
					
					
					if dUltDisp_atm is null then let dUltDisp_atm = ''; end if;
					if dUltDisp_pos is null then let dUltDisp_pos = ''; end if;
					if dUltDisp_vnt is null then let dUltDisp_vnt = ''; end if;
					
					IF vproducto='7800' THEN
						SELECT MAX(fecha_mov) INTO dUltima_Disposicion
						FROM SD_MOVHIS
						where num_credito=vcredito AND codigo_fun='002' AND codigo_ref=111;
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

--  				***************    cambio jahj Julio 2023				la consulta se coloca arriba en el txt	
--					SELECT ejecutivo INTO v_ejecutivo
--					FROM sd_maecred
--					WHERE num_credito=vcredito;
				
                BEGIN;
                INSERT INTO bdicred:"informix".sd_sdos_cartera_linea 
                    (fecha,numcte,num_credito,num_tarjeta,num_cta,num_producto,sdo_capital,monto_vencido,mto_venc_trasp,cap_tras_no_venci,
                    sdo_cap_insoluto,monto_financiado,moratorio,interes_iva,mto_fin_ven_trasp,status_cred,fecha_ult_pago,pago_una_mora,
                    sucursal,fecha_apertura,monto_otorgado,tasa_interes,prox_fecha_pago,cat, saldovencido1, saldovencido2, saldovencido3, 
                    saldovencido4, saldovencido5, saldovencido6, interesmoratorio1, interesmoratorio2, interesmoratorio3, interesmoratorio4, 
                    interesmoratorio5, interesmoratorio6, sdo_intereses, mensualidad_actual, grupo, antiguedad, bcscore, scoreprop, ficoscore,
					bhscore, novencidos1, novencidos2, novencidos3, novencidos4, novencidos5, novencidos6, celular, iva_int_trasp,sdo_retenido,
					dias_vencido, atr, act, fecha_vencido, fecha_ult_dispo, ejecutivo)
                    VALUES(dFecha_hoy, vcliente, vcredito, vtarjeta, vcta_eje, vproducto, vsdo_capital, vmonto_vencido, vmtovenctrasp, 
                    vcaptrasnovenci, vsdocapinsoluto, montofinanciado, vsdomoratorio, vinteresiva, vmoras, vstatuscred, vfechaultpago, 
                    pagounamora, vsucursal, vfch_apertura, vmontootorgado, vtasainteres, vproxfchpago, vcat, cSaldovencido1, cSaldovencido2, 
                    cSaldovencido3, cSaldovencido4, cSaldovencido5, cSaldovencido6, cInteresmoratorio1, cInteresmoratorio2, cInteresmoratorio3,  
                    cInteresmoratorio4, cInteresmoratorio5, cInteresmoratorio6, vsdo_intereses, vmensualidad_act, vgrupo, vantiguedad, vbcscore,
					vscoreprop, vficoscore, vbhscore, vnovencidos1, vnovencidos2, vnovencidos3, vnovencidos4, vnovencidos5, vnovencidos6, vcelular,
					vivatrasp,vretenido, v_dias_vencido, 0, cAct, v_fecha_vencido, dUltima_Disposicion,v_ejecutivo );
				COMMIT;
				
				LET v_cuenta_bloque = v_cuenta_bloque+1;
				
				IF v_cuenta_bloque = 30000 THEN 
				   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, '  Cuenta bloque REVS', '02') RETURNING cCod_retBit;   
				   LET v_cuenta_bloque = 0;
				END IF;
            END IF;

        END FOREACH;    

		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'Paso 3: Termina Foreach Obtener info REVS monto,saldos,etc', '02') RETURNING cCod_retBit;  
		
        DROP TABLE bdicred:creditossl_tab2;
    LET cCod_Ret = '00000';
    LET cMensajeRet = 'PROCESO CONCLUIDO';
    
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'FINALIZA sp_genera_carteraenlinea_tab', '02') RETURNING cCod_retBit;       
    RETURN cCod_ret,cMensajeRet;

END;
END PROCEDURE;