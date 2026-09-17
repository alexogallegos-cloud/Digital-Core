CREATE PROCEDURE "informix".sp_genera_reporte_calificacion(pEmpresa	CHAR(3), pPeriodo  DATE)
RETURNING   CHAR(6) 	AS retorno,
            CHAR(100)   AS mensaje_ret,
			INT         AS regs_insertados,
			INT         AS regs_actualizados;

--  execute procedure "informix".sp_genera_reporte_calificacion('001', '08-20-2014');
--DeclaraciÃ³n de variables. 
define nuevos int;
define actualizados int;
define VcFechaFin           char(10);
define ss_vDFechaCierre      Date;
define decvalor				decimal(5,2);
define decvalor1			decimal(5,2);
define decvalor2			decimal(5,2);
define decvalor3			decimal(5,2);
define decvalor4			decimal(5,2);
define decvalor5			decimal(5,2);
define decvalor6			decimal(5,2);
define decvalor7			decimal(5,2);
define decvalor8			decimal(5,2);
define decvalor9			decimal(5,2);
define decvalor10			decimal(5,2);
define decvalor13			decimal(5,2);
--PQ
define decvalor15			decimal(5,2);
define decvalor16			decimal(5,2);
define decvalor17			decimal(5,2);
define intgrupo             smallint;
--PQ
define dEvaluacion1         decimal(14,2);
define dEvaluacion2         decimal(14,2);
define dSuma                decimal(14,2);
define iCantidad            integer;
--PQ
define decseccion1			decimal(14,2);
define decseccion2			decimal(14,2);
define decsuma				decimal(14,2);

DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr         	INTEGER;
DEFINE cErrorInfo       	CHAR(85);
DEFINE cCodRet          	CHAR(6);
DEFINE cMensajeRet    		CHAR(100);
DEFINE a_empresa 			CHAR(3);
DEFINE a_fecha_corte 		DATE;
DEFINE a_num_credito		CHAR(20);
DEFINE a_fecha_cierre		DATE;
DEFINE a_grado_riesgo		CHAR(2);
DEFINE a_fecha_apertura		DATE;
DEFINE a_antecedente_buro	CHAR(1);
DEFINE a_status_cred		CHAR(2);
DEFINE a_linea_autorizada	DECIMAL(18,2);
DEFINE a_limite_credito		DECIMAL(18,2);
DEFINE a_interes_cred_ven	DECIMAL(18,2);
DEFINE a_saldo_corte		DECIMAL(18,2);
DEFINE a_saldo_cierre		DECIMAL(18,2);
DEFINE a_pago_minimo		DECIMAL(18,2);
DEFINE a_pagos_realizados	DECIMAL(18,2);
DEFINE a_reserva_int_cred_ven	DECIMAL(18,2);
DEFINE a_reserva_buro		DECIMAL(18,2);
DEFINE a_reserva_calificacion	DECIMAL(18,2);
DEFINE a_porcentaje_reserva	DECIMAL(18,2);
DEFINE a_meses_antiguedad	DECIMAL(18,2);
DEFINE a_probabilidad_incumplimiento	DECIMAL(18,2);
DEFINE a_severidad_perdida	DECIMAL(18,2);
DEFINE a_exposicion_incumplimiento	DECIMAL(18,2);
DEFINE a_impagos_consecutivos	INTEGER;
DEFINE a_impagos_historicos	INTEGER;
DEFINE a_porcentaje_pago	DECIMAL(18,2);
DEFINE a_porcentaje_uso		DECIMAL(18,2);
DEFINE a_num_periodos		INTEGER;
DEFINE a_exposicion_inc_gradual	DECIMAL(18,5);
DEFINE a_grado_riesgo_gradual	CHAR(2);
DEFINE a_reserva_calificacion_gradual	DECIMAL(18,2);
DEFINE a_porcentaje_reserva_gradual	DECIMAL(18,2);
DEFINE a_reserva_buro_gradual	DECIMAL(18,2);
DEFINE a_reserva_int_cred_ven_gradual	DECIMAL(18,2);
DEFINE a_reserva_calif_mes_anterior	DECIMAL(18,2);
DEFINE a_grado_riesgo_bancoppel	CHAR(2);
DEFINE a_grado_riesgo_edo_resultados	CHAR(2); 
DEFINE a_reserva_edo_resultados	DECIMAL(18,2);
DEFINE a_porcentaje_reserva_edo_resultados	DECIMAL(18,2);

DEFINE a_numcte                           	CHAR(20);
DEFINE a_cta_credisolucion                	CHAR(20);
DEFINE a_cuenta_contable 					CHAR(20);
DEFINE a_status_fin_mes                   	CHAR(2);
DEFINE a_saldo_corte2                     	DECIMAL(18,2);
DEFINE a_saldo_corte3                     	DECIMAL(18,2);
DEFINE a_saldo_corte4                     	DECIMAL(18,2);
DEFINE a_pagos_realizados1                	DECIMAL(18,2);
DEFINE a_pagos_realizados2                	DECIMAL(18,2);
DEFINE a_pagos_realizados3                	DECIMAL(18,2);
DEFINE a_pagos_realizados4                	DECIMAL(18,2);
DEFINE a_saldo_corte_credisolucion        	DECIMAL(18,2);
DEFINE a_saldo_cierre_credisolucion       	DECIMAL(18,2);
DEFINE a_monto_pagar_inst                 	DECIMAL(18,2);
DEFINE a_monto_pagar_rep_sic              	DECIMAL(18,2);
DEFINE a_ant_acreditado_inst              	INTEGER;
DEFINE a_grado_riesgo_alto                	SMALLINT;
DEFINE a_grado_riesgo_medio               	SMALLINT;
DEFINE a_grado_riesgo_bajo                	SMALLINT;
DEFINE a_gveces1                          	SMALLINT;
DEFINE a_gveces2                          	SMALLINT;
DEFINE a_gveces3                          	SMALLINT;
DEFINE a_bkatr                            	INTEGER; 

DEFINE b_status_cred		CHAR(2);
DEFINE b_sucursal			CHAR(4);
DEFINE b_numcte				CHAR(20);
DEFINE d_situacion_pago		DECIMAL(5,2);
DEFINE d_grupo				CHAR(1);
DEFINE d_meses_historia		SMALLINT;
DEFINE sumcoring			DECIMAL(14,2);
DEFINE dSdoCierreGrado  	DECIMAL(18,2);
DEFINE dReserCalif      	DECIMAL(18,2);
DEFINE dReserCalifGrad  	DECIMAL(18,2);
DEFINE dReserBuro       	DECIMAL(18,2);
DEFINE dReserIntVen     	DECIMAL(18,2);
DEFINE cProducto        	CHAR(4); 
DEFINE cGradoRiesgo     	CHAR(2); 
DEFINE dPorcMin         	DECIMAL(5,2);
DEFINE dPorcMax         	DECIMAL(5,2);
DEFINE iNumCredGrado    	INTEGER;
DEFINE dTotalReserva    	DECIMAL(18,2);
DEFINE dSdoIntCredVen   	DECIMAL(18,2);    
DEFINE iNumCtesSdoFavor 	INTEGER;
DEFINE dSdoCtesSdoFavor 	DECIMAL(18,2);
DEFINE dReserCtesSdoFavor   DECIMAL(18,2);
DEFINE iNumCtesInac         INTEGER;
DEFINE dSdoCtesInac         DECIMAL(18,2);
DEFINE dReserCtesInac       DECIMAL(18,2);
DEFINE iNumCtesTotal        INTEGER;
DEFINE dSdoCtesTotal        DECIMAL(18,2);
DEFINE iDiaPeriodo          INTEGER;
DEFINE dtFechaCorte         DATE;
DEFINE dtFechaCorteAnterior DATE;
DEFINE dPeriodoAnterior 	DATE;
DEFINE dPrimerFechaMes	 	DATE;
DEFINE dUltimaFechaMes	 	DATE;
DEFINE cNumCredGrado        CHAR(20);
DEFINE cNumCtesInac         CHAR(20);
DEFINE cNumCtesSdoFavor     CHAR(20);
DEFINE cNumCtesTotal        CHAR(20);
DEFINE vDia 				CHAR(2);
DEFINE vMes 				CHAR(2);
DEFINE vAnio 				CHAR(4);
DEFINE vsql                 char(1200);
DEFINE dtFecha_cierre      	DATE;
DEFINE cMensajeRet2         char(300);
DEFINE vNumproceso          char(4);
DEFINE dFechaHoy          	DATE;
-- A.L.L.
DEFINE dtFechaCorteAnteriorT_2 DATE; 
DEFINE dtFechaCorteAnteriorT_3 DATE; 
DEFINE dtFechaCorteT_3 		DATE; 
DEFINE vNumCte				CHAR(20);
DEFINE vNumCreditoCrd		CHAR(20);
DEFINE vTotalCta_cs			SMALLINT;
DEFINE vNumCte_Ref			CHAR(20);
DEFINE vTipo_Cliente		CHAR(3);
DEFINE vPago_Vencido		DECIMAL(18,2);
DEFINE vMeses_Vencidos		SMALLINT;
DEFINE vSdo_Vigente			DECIMAL(18,2);
DEFINE vSdo_Exigible		DECIMAL(18,2);
DEFINE vSdo_Transitorio		DECIMAL(18,2);
DEFINE vSdo_noexigible		DECIMAL(18,2);
DEFINE vCap_TraspNo_Vencido DECIMAL(18,2);
DEFINE vSdoCorteCredisolucion DECIMAL(18,2);
DEFINE vSdoCierreCredisolucion DECIMAL(18,2);
DEFINE vNumCredisolucion    CHAR(20);
DEFINE vEficiencia		DECIMAL(5,2);
DEFINE vSaldoRopa			MONEY(18,2);
DEFINE vSaldoMuebles		MONEY(18,2);
DEFINE vsaldoPrestamos      MONEY(18,2);
-- NVO MACF
DEFINE dtFechaApertura          DATE;
DEFINE dComisionApertura        DECIMAL(18,2); 
DEFINE dIvaComisionApertura	    DECIMAL(5,2); 
DEFINE dComisionDisposicion	    DECIMAL(18,2);
DEFINE dIvaComisionDisposicion  DECIMAL(5,2);
DEFINE cNumCredito				CHAR(20);


---NVO MACF
--InicializaciÃ³n de variables.
	let decvalor			=0;
	let decvalor1			=0;
	let decvalor2			=0;
	let decvalor3			=0;
	let decvalor4			=0;
	let decvalor5			=0;
	let decvalor6			=0;
	let decvalor7			=0;
	let decvalor8			=0;
	let decvalor9			=0;
	let decvalor10			=0;
	let decvalor13			=0;
--PQ
	let decvalor15			=0;
	let decvalor16			=0;
	let decvalor17			=0;
--PQ
	let intgrupo            =0;
--PQ
    let dEvaluacion1        =0;
    let dEvaluacion2        =0;
    let dSuma               =0;
    let iCantidad           =0;
--PQ
	let decseccion1			=0;
	let decseccion2			=0;
	let decsuma				=0;
	
LET iSqlErr                 = 0;
LET iIsamErr              	= 0;
LET cErrorInfo            	= "";
LET cCodRet              	= "000000";
LET cMensajeRet      		= "El proceso de REPORTE DE CALIFICACION se realizÃ³ correctamente.";
LET a_empresa 				= "";
LET a_fecha_corte 			= DATE(1);
LET a_num_credito			= "";
LET a_fecha_cierre			= DATE(1);
LET a_grado_riesgo			= "";
LET a_fecha_apertura		= DATE(1);
LET a_antecedente_buro		= "";
LET a_status_cred			= "";
LET a_linea_autorizada		= 0;
LET a_limite_credito		= 0;
LET a_interes_cred_ven		= 0;
LET a_saldo_corte			= 0;
LET a_saldo_cierre			= 0;
LET a_pago_minimo			= 0;
LET a_pagos_realizados		= 0;
LET a_reserva_int_cred_ven	= 0;
LET a_reserva_buro			= 0;
LET a_reserva_calificacion	= 0;
LET a_porcentaje_reserva	= 0;
LET a_meses_antiguedad		= 0;
LET a_probabilidad_incumplimiento	= 0;
LET a_severidad_perdida		= 0;
LET a_exposicion_incumplimiento	= 0;
LET a_impagos_consecutivos	= 0;
LET a_impagos_historicos	= 0;
LET a_porcentaje_pago		= 0;
LET a_porcentaje_uso		= 0;
LET a_num_periodos			= 0;
LET a_exposicion_inc_gradual	= 0;
LET a_grado_riesgo_gradual	= "";
LET a_reserva_calificacion_gradual	= 0;
LET a_porcentaje_reserva_gradual	= 0;
LET a_reserva_buro_gradual	= 0;
LET a_reserva_int_cred_ven_gradual	= 0;
LET a_reserva_calif_mes_anterior	= 0;
LET a_grado_riesgo_bancoppel	= "";
LET a_grado_riesgo_edo_resultados	= ""; 
LET a_reserva_edo_resultados	= 0;
LET a_porcentaje_reserva_edo_resultados	= 0;

LET a_numcte                           	= '';
LET a_cta_credisolucion                	= '';
LET a_cuenta_contable					= '';
LET a_status_fin_mes                   	= '';
LET a_saldo_corte2                     	= 0;
LET a_saldo_corte3                     	= 0;
LET a_saldo_corte4                     	= 0;
LET a_pagos_realizados1                	= 0;
LET a_pagos_realizados2                	= 0;
LET a_pagos_realizados3                	= 0;
LET a_pagos_realizados4                	= 0;
LET a_saldo_corte_credisolucion        	= 0;
LET a_saldo_cierre_credisolucion       	= 0;
LET a_monto_pagar_inst                 	= 0;
LET a_monto_pagar_rep_sic              	= 0;
LET a_ant_acreditado_inst              	= 0;
LET a_grado_riesgo_alto                	= 0;
LET a_grado_riesgo_medio               	= 0;
LET a_grado_riesgo_bajo                	= 0;
LET a_gveces1                          	= 0;
LET a_gveces2                          	= 0;
LET a_gveces3                          	= 0;
LET a_bkatr                            	= 0;

LET b_status_cred			= "";
LET b_sucursal				= "";
LET b_numcte				= "";
LET d_situacion_pago		= 0;
LET d_grupo					= "";
LET d_meses_historia		= 0;
LET sumcoring				= 0;
LET dSdoCierreGrado     	= 0;
LET dReserCalif             = 0;
LET dReserCalifGrad         = 0;
LET dReserBuro              = 0;
LET dReserIntVen            = 0;
LET cProducto               = "";
LET cGradoRiesgo            = "";
LET dPorcMin                = 0;
LET dPorcMax                = 0;
LET iNumCredGrado       	= 0;
LET dTotalReserva           = 0;
LET dSdoIntCredVen       	= 0;
LET iNumCtesSdoFavor        = 0;
LET dSdoCtesSdoFavor        = 0;
LET dReserCtesSdoFavor      = 0;
LET iNumCtesInac            = 0;
LET dSdoCtesInac            = 0;
LET dReserCtesInac          = 0;
LET iNumCtesTotal           = 0;
LET dSdoCtesTotal           = 0;
LET iDiaPeriodo             = 0;
LET dtFechaCorte            = DATE(1);
LET dtFechaCorteAnterior    = DATE(1);
LET dPeriodoAnterior	    = DATE(1);
LET dPrimerFechaMes		    = DATE(1);
LET dUltimaFechaMes		    = DATE(1);
LET cNumCredGrado           = "";
LET cNumCtesInac            = "";
LET cNumCtesSdoFavor        = "";
LET cNumCtesTotal           = "";
LET vDia = "" ;
LET vMes = "";
LET vAnio = "";
LET vsql = '';
LET dtFecha_cierre        = DATE(1);
LET cMensajeRet2           = '';
LET vNumproceso            = '0055';
LET dFechaHoy   = mdy(month(today),1,year(today)) - 1 units day;

--temporal solo para pruebas
--let dFechaHoy = mdy(05,31,2017); 
--temporal solo para pruebas

LET dtFechaCorteAnteriorT_2 = DATE(1);
LET dtFechaCorteAnteriorT_3 = DATE(1);
LET dtFechaCorteT_3 = DATE(1);
LET vNumCte					='';
LET vTotalCta_cs			=0;
LET vNumCte_Ref				='';
LET vTipo_Cliente			='';
LET vPago_Vencido			=0;
LET vMeses_Vencidos			=0;
LET vSdo_Vigente			=0;
LET vSdo_Exigible			=0;
LET vSdo_Transitorio		=0;
LET vSdo_noexigible			=0;
LET vSdoCorteCredisolucion  =0;
LET vSdoCierreCredisolucion =0;
LET vNumCredisolucion		='';
LET vEficiencia				=0;
LET vSaldoRopa				=0;
LET vSaldoMuebles			=0;
LET vsaldoPrestamos			=0;
LET dtFechaApertura 		= DATE(1);

LET dtFechaApertura         = 0;
LET dComisionApertura       = 0; 
LET dIvaComisionApertura	= 0; 
LET dComisionDisposicion	= 0;
LET dIvaComisionDisposicion = 0;
LEt ss_vDFechaCierre 		= DATE(1);
LET VcFechaFin        		= DATE(1);
LET nuevos = 0;
LET actualizados = 0;
LET cNumCredito = '';


BEGIN
--Errores no controlados.
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
      LET cCodRet= iSqlErr;
      LET cMensajeRet= trim(cErrorInfo)||' '||cNumCredito;
     
      RETURN cCodRet, cMensajeRet, nuevos, actualizados;
END EXCEPTION;
	
	--Rastrea actividad.
--SET DEBUG FILE TO "sp_genera_reporte_calificacion.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

 --UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_hist_reserva;  
 --UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_movhis_calif;  


--Valida la integridad de los datos.
/*
IF NVL(pPeriodo, "") = "" OR NVL(pEmpresa ,"") = "" THEN
	LET cCodRet = "000001";
	LET cMensajeRet = "No se han proporcionado correctamente los datos de entrada.";
	RETURN cCodRet, cMensajeRet;
END IF;
*/
--Valida que la empresa se encuentre registrada en el catÃ¡logo de empresas.
/*IF NOT EXISTS(SELECT empresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa) THEN
	LET cCodRet = "000002";
	LET cMensajeRet = "La empresa proporcionada no existe.";
	
	RETURN cCodRet, cMensajeRet;
END IF;
*/
--Consulta la 1er fecha y Ãºltima del mes periodo.


EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio(MONTH(dFechaHoy), YEAR(dFechaHoy)) INTO cCodRet,dPrimerFechaMes,dUltimaFechaMes;

LET  iDiaPeriodo = DAY(dUltimaFechaMes);
LET dPeriodoAnterior = MDY(MONTH(dPrimerFechaMes - 1 units MONTH), "20", YEAR(dPrimerFechaMes - 1 units  MONTH));

--Consulta la 1er fecha y Ãºltima del mes periodo anterior.
EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio(MONTH(dPeriodoAnterior), YEAR(dPeriodoAnterior)) INTO cCodRet,dPrimerFechaMes,dPeriodoAnterior;

--Realiza la consulta si la fecha es dÃ­a corte para evaluar si se tiene que ir al corte anterior o debe consultar sobre la info del mes.
IF iDiaPeriodo >= 20 THEN
	LET dtFechaCorte = MDY(MONTH(dFechaHoy), "20", YEAR(dFechaHoy));
	LET dtFechaCorteAnterior = MDY(MONTH(dtFechaCorte - 1 units month ), "20", YEAR(dtFechaCorte- 1 units MONTH)); 
ELSE
    LET dtFechaCorte = MDY(MONTH(dFechaHoy - 1 units month), "20", YEAR(dFechaHoy-1 units  MONTH));
    LET dtFechaCorteAnterior = MDY(MONTH(dtFechaCorte - 1 units MONTH), "20", YEAR(dtFechaCorte-1 units  MONTH)); 
END IF;

--Valida que la fecha cierre no se encuentre en el periodo que se desea consultar.
IF EXISTS (SELECT fecha_cierre FROM bdicred:"informix".sd_reporte_calificacion WHERE fecha_cierre = dFechaHoy) THEN
    LET cCodRet = "000003";
    LET cMensajeRet = "El reporte de calificaciÃ³n de TDC ya estÃ¡ generado para el mes de  " || dUltimaFechaMes ;
    RETURN cCodRet, cMensajeRet , nuevos, actualizados;
END IF;

foreach WITH HOLD
					
	select a.empresa, a.fecha_corte, a.num_credito, a.fecha_cierre, a.grado_riesgo, a.fecha_apertura, a.antecedente_buro, a.status_cred, a.linea_autorizada,
					a.limite_credito, a.interes_cred_ven, a.saldo_corte, a.saldo_cierre, a.pago_minimo, a.pagos_realizados, a.reserva_int_cred_ven, a.reserva_buro,
					a.reserva_calificacion, a.porcentaje_reserva, a.meses_antiguedad, a.probabilidad_incumplimiento, a.severidad_perdida, nvl(a.exposicion_incumplimiento,0),
					a.impagos_consecutivos, a.impagos_historicos, a.porcentaje_pago, a.porcentaje_uso, a.num_periodos, a.exposicion_inc_gradual, a.grado_riesgo_gradual,
					a.reserva_calificacion_gradual, a.porcentaje_reserva_gradual, a.reserva_buro_gradual, a.reserva_int_cred_ven_gradual, a.reserva_calif_mes_anterior,
					a.grado_riesgo_bancoppel, a.grado_riesgo_edo_resultados, a.reserva_edo_resultados, a.porcentaje_reserva_edo_resultados, a.numcte, a.cta_credisolucion,
					a.status_fin_mes, a.saldo_corte2, a.saldo_corte3, a.saldo_corte4, a.pagos_realizados1, a.pagos_realizados2, a.pagos_realizados3, a.pagos_realizados4, a.saldo_corte_credisolucion,
					a.saldo_cierre_credisolucion, a.monto_pagar_inst, a.monto_pagar_rep_sic, a.ant_acreditado_inst, a.grado_riesgo_alto, a.grado_riesgo_medio, a.grado_riesgo_bajo,
					a.gveces1, a.gveces2, a.gveces3, a.bkatr, b.fecha_cierre
			INTO	a_empresa, a_fecha_corte, a_num_credito, a_fecha_cierre, a_grado_riesgo, a_fecha_apertura, a_antecedente_buro, a_status_cred, a_linea_autorizada,
					a_limite_credito, a_interes_cred_ven, a_saldo_corte, a_saldo_cierre, a_pago_minimo, a_pagos_realizados, a_reserva_int_cred_ven, a_reserva_buro,
					a_reserva_calificacion, a_porcentaje_reserva, a_meses_antiguedad, a_probabilidad_incumplimiento, a_severidad_perdida, a_exposicion_incumplimiento,
					a_impagos_consecutivos, a_impagos_historicos, a_porcentaje_pago, a_porcentaje_uso, a_num_periodos, a_exposicion_inc_gradual, a_grado_riesgo_gradual,
					a_reserva_calificacion_gradual, a_porcentaje_reserva_gradual, a_reserva_buro_gradual, a_reserva_int_cred_ven_gradual, a_reserva_calif_mes_anterior,
					a_grado_riesgo_bancoppel, a_grado_riesgo_edo_resultados, a_reserva_edo_resultados, a_porcentaje_reserva_edo_resultados, a_numcte, a_cta_credisolucion,
					a_status_fin_mes, a_saldo_corte2, a_saldo_corte3, a_saldo_corte4, a_pagos_realizados1, a_pagos_realizados2, a_pagos_realizados3, a_pagos_realizados4, a_saldo_corte_credisolucion,
					a_saldo_cierre_credisolucion, a_monto_pagar_inst, a_monto_pagar_rep_sic, a_ant_acreditado_inst, a_grado_riesgo_alto, a_grado_riesgo_medio, a_grado_riesgo_bajo,
					a_gveces1, a_gveces2, a_gveces3, a_bkatr, ss_vDFechaCierre
	FROM bdicred:sd_hist_reserva a
	left outer join bdicred:sd_sumascor b on (a.empresa = b.empresa and a.num_credito = b.num_credito)
	WHERE a.empresa = pEmpresa
	and a.fecha_cierre = dFechaHoy 
	and a.num_credito not in (select num_credito from sd_sumascor where fecha_cierre = dFechaHoy)
	AND a.grado_riesgo IS NOT NULL
--	and a.num_credito in ('600078302467','600078450068','600079026750')

	LET cNumCredito = a_num_credito;

	select sucursal,numcte
	into b_sucursal,b_numcte
	from bdicred:sd_maecredcont 
	where fecha = dFechaHoy
	and empresa = a_empresa
	and num_credito = a_num_credito;

	  --A.L.L. vPago_Vencido
		select monto_vencido, mto_fin_ven_trasp
		  into vPago_Vencido, vMeses_Vencidos
		  from bdicred:sd_maesdoshist
		 where empresa 		= pEmpresa
		   and num_credito 	= a_num_credito
		   and fecha 		= dtFechaCorte;

		IF vPago_Vencido 	IS NULL OR vPago_Vencido 	= '' THEN LET vPago_Vencido = 0; 	END IF;
		IF vMeses_Vencidos 	IS NULL OR vMeses_Vencidos 	= '' THEN LET vMeses_Vencidos = 0; 	END IF;


		select sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci
		  into vSdo_Vigente, vSdo_Transitorio, vSdo_Exigible, vSdo_noexigible 
		  from bdicred:sd_maesdoshist
		 where empresa 		= pEmpresa
		   and num_credito 	= a_num_credito
		   and fecha 		= dtFechaCorteAnterior;
			
		IF vSdo_Vigente 	IS NULL OR vSdo_Vigente 	= '' THEN LET vSdo_Vigente = 0; 	END IF;
		IF vSdo_Transitorio IS NULL OR vSdo_Transitorio = '' THEN LET vSdo_Transitorio = 0; END IF;
		IF vSdo_Exigible 	IS NULL OR vSdo_Exigible 	= '' THEN LET vSdo_Exigible = 0; 	END IF;
		IF vSdo_noexigible 	IS NULL OR vSdo_noexigible 	= '' THEN LET vSdo_noexigible = 0; 	END IF;

	-- A.L.L.se quita lo de credisolucion
		--A.L.L.
		  --IF vNumCte != '' THEN
			select numcte_ref
			into vNumCte_Ref
			from bdinteg:si_cliente 
			--Se cambio variable--
			where numcte = b_numcte;
			
			IF vNumCte_Ref IS NULL or vNumCte_Ref = '' THEN LET vNumCte_Ref = '0'; END IF;
		 --END IF;
	  --end A.L.L.  
	
	if ss_vDFechaCierre is not null or ss_vDFechaCierre != "" then
	   BEGIN WORK;
	   LET actualizados = actualizados + 1;

		update bdicred:sd_sumascor set    /*empresa = a_empresa,*/ cta_credisolucion = a_cta_credisolucion , fecha_corte = a_fecha_corte , fecha_cierre = a_fecha_cierre, /*num_credito = a_num_credito,*/ 
												numcte = b_numcte, numcte_coppel = vNumCte_Ref, linea_autorizada = a_linea_autorizada, limite_credito = a_limite_credito , saldo_corte = a_saldo_corte, 
												saldo_cierre = a_saldo_cierre, saldo_vigente = vSdo_Vigente, saldo_transitorio = vSdo_Transitorio, saldo_exigible = vSdo_Exigible, 
												saldo_noexigible = vSdo_noexigible, saldo_corte_credisolucion = a_saldo_corte_credisolucion, saldo_cierre_credisolucion = a_saldo_cierre_credisolucion, interes_cred_ven = a_interes_cred_ven, 
												pago_minimo = a_pago_minimo, pagos_realizados = a_pagos_realizados, pago_vencido = vPago_Vencido, impagos_consecutivos = a_impagos_consecutivos, impagos_historicos = a_impagos_historicos,
												probabilidad_incumplimiento = a_probabilidad_incumplimiento, severidad_perdida = a_severidad_perdida, exposicion_incumplimiento = a_exposicion_incumplimiento, 
												reserva_calif_mes_anterior = a_reserva_calif_mes_anterior, reserva_edo_resultados = a_reserva_edo_resultados, reserva_calificacion = a_reserva_calificacion, reserva_buro = a_reserva_buro,
												reserva_int_cred_ven = a_reserva_int_cred_ven, porcentaje_reserva = a_porcentaje_reserva, porcentaje_pago = a_porcentaje_pago, porcentaje_uso = a_porcentaje_uso,
												saldo_corteT_1 = a_saldo_corte2, saldo_corteT_2 = a_saldo_corte3, saldo_corteT_3 = a_saldo_corte4,
												pagos_realizadosT_1 = a_pagos_realizados1, pagos_realizadosT_2 = a_pagos_realizados2, pagos_realizadosT_3 = a_pagos_realizados3,
												grado_riesgo = a_grado_riesgo, grado_riesgo_edo_resultados = a_grado_riesgo_edo_resultados, fecha_apertura = a_fecha_apertura, antecedente_buro = a_antecedente_buro, status_cred = a_status_cred,
												status_fin_mes = a_status_fin_mes, --tipo_cliente, grupo, situacion_pago, eficiencia,
												meses_antiguedad = a_meses_antiguedad, /*meses_historia,*/ meses_vencidos = vMeses_Vencidos, /*seccion1, seccion2, sumascor,*/
												--sucursal, saldo_ropa, saldo_muebles, saldo_prestamo,
												monto_pagar_inst = a_monto_pagar_inst, monto_pagar_rep_sic = a_monto_pagar_rep_sic, ant_acreditado_inst = a_ant_acreditado_inst, 
												grado_riesgo_alto = a_grado_riesgo_alto, grado_riesgo_medio = a_grado_riesgo_medio, grado_riesgo_bajo = a_grado_riesgo_bajo, gveces1 = a_gveces1, gveces2 = a_gveces2, gveces3 = a_gveces3, bkatr = a_bkatr --NVO MACF
	      										/*comision_apertura, iva_comision_apertura, comision_disposicion, iva_comision_disposicion,	  --NVO MACF												comision_cobranza, iva_comision_cobranza*/
												where num_credito = a_num_credito;
		COMMIT WORK;
	else
	
		let nuevos = nuevos + 1;

		SELECT 	NVL(situacion_pago,0),NVL(grupo,""), 
				NVL(meses_historia,0), NVL(saldoropa,0), 
				NVL(saldomuebles,0), NVL(saldoprestamos,0)
		INTO 	vEficiencia,d_grupo, 
				d_meses_historia, vSaldoRopa, 
				vSaldoMuebles, vsaldoPrestamos 
		FROM 	bdisolic:ss_resum_scor_fin 
		WHERE 	empresa = a_empresa 
		AND		num_solicitud = a_num_credito;

		if vEficiencia = '' or vEficiencia is null then
		let vEficiencia = 0;
		end if;
		if d_grupo = '' or d_grupo is null then
		let d_grupo = '';
		end if;
		if d_meses_historia = '' or d_meses_historia is null then
		let d_meses_historia = 0;
		end if;
		if vSaldoRopa = '' or vSaldoRopa is null then
		let vSaldoRopa = 0;
		end if;
		if vSaldoMuebles = '' or vSaldoMuebles is null then
		let vSaldoMuebles = 0;
		end if;
		if vsaldoPrestamos = '' or vsaldoPrestamos is null then
		let vsaldoPrestamos = 0;
		end if;

		LET vTipo_Cliente  =  	CASE WHEN d_meses_historia >= 13 AND vEficiencia >= 85 THEN 'I' ELSE 
								CASE WHEN d_meses_historia >= 6 and vEficiencia >= 85 THEN 'II' ELSE 'III' END END;

		foreach WITH HOLD
			select nvl(b.valor,0),a.grupo
			into decvalor,intgrupo
			from bdisolic:ss_scoring_grupo a, bdisolic:ss_detalle_scoring b
			where a.empresa = '001' and a.seccion = 2
			and b.num_solicitud = a_num_credito
			and b.tpo_persona = '01'
			and a.empresa = b.empresa
			and a.grupo <> 25 --JCP Grupo OS Telefonica
			and a.grupo = b.grupo
			and a.seccion = b.seccion
			order by b.seccion, b.grupo, b.elemento

			if intgrupo = 2 then
				let decvalor1 = decvalor;
			elif intgrupo = 3 then
				let decvalor2 = decvalor;
			elif intgrupo = 4 then
				let decvalor3 = decvalor;
			elif intgrupo = 5 then
				let decvalor4 = decvalor;
			elif intgrupo = 6 then
				let decvalor5 = decvalor;
			elif intgrupo = 7 then
				let decvalor6 = decvalor;
			elif intgrupo = 8 then
				let decvalor7 = decvalor;
			elif intgrupo = 9 then
				let decvalor8 = decvalor;
			elif intgrupo = 10 then
				let decvalor9 = decvalor;
			elif intgrupo = 11 then
				let decvalor10 = decvalor;
			--PQ
			elif intgrupo = 16 then
				let decvalor13 = decvalor;
			--PQ
			elif intgrupo = 21  then
				let decvalor15 = decvalor;
			elif intgrupo = 22  then
				let decvalor16 = decvalor;
			elif intgrupo = 23  then
				let decvalor17 = decvalor;
			--PQ
			end if;
			
		end foreach;
	  
		--PQ
		SELECT
		nvl(SUM(decode(seccion, '1', nvl(evaluacion,0), 0)),0) AS seccion1,
		nvl(SUM(decode(seccion, '2', nvl(evaluacion,0), 0)),0) AS seccion2,
		nvl(SUM(nvl(evaluacion, 0)),0) AS Suma,
		COUNT(num_solicitud) AS Cantidad
		INTO dEvaluacion1, dEvaluacion2, dSuma, iCantidad --A.L.L. ya saca la seccion 1 y 2
		FROM bdisolic:ss_resumen_scoring
		WHERE empresa= '001'
		AND seccion in ('1', '2')
		AND num_solicitud = a_num_credito;
		--PQ
		
		--PQ
		IF iCantidad = 2 THEN
			let decseccion1= dEvaluacion1;
			let decseccion2= dEvaluacion2;
			let sumcoring = dSuma; 
		ELSE
		{
		--Obtiene el total del scoring de la seccion 1 vEficiencia
			select nvl(sum(nvl(puntuacion,0)),0)/*A.L.L.*/, rsf.situacion_pago, rsf.saldoropa, rsf.saldomuebles, rsf.saldoprestamos/*A.L.L.*/
			into decseccion1 110/*A.L.L.*/, vEficiencia, vSaldoRopa, vSaldoMuebles, vsaldoPrestamos /*A.L.L.*/
			from bdisolic:ss_scoring_financ sf, bdisolic:ss_resum_scor_fin rsf
			where rsf.empresa = '001' and rsf.num_solicitud = a_num_credito and rsf.empresa = sf.empresa
			and upper(sf.tp_solicitud) = 'T' and sf.circulo_credito = evalua_cc
			and sf.min_mes_hist <= rsf.meses_historia
			and sf.max_mes_hist >= rsf.meses_historia
			and sf.min_porc_pago <= rsf.situacion_pago
			and sf.max_porc_pago >= rsf.situacion_pago group by 2,3,4,5;
		}
		--Obtiene el total del scoring de la seccion 2
		--PQ

		let decseccion2 = decvalor1 + decvalor2 + decvalor3 + decvalor4 + decvalor5 + decvalor6 + decvalor7 +
						  decvalor8 + decvalor9 + decvalor10 + decvalor13 +
						  decvalor15 +  decvalor16 + decvalor17;
		--PQ
		LET decseccion1 = dEvaluacion2 - decseccion2;

		--Obtiene el total del scoring del cliente
		let sumcoring = decseccion1 + decseccion2;

		END IF;
		--PQ
		
		----- OBTENER LOS DATOS PARA LA CALIFICACION ANTICIPO DE NÃMINA    MACF 20160621 
		 select fecha_apertura into dtFechaApertura 
		 from bdicred:sd_maecred where num_credito = a_num_credito;
		
	   IF dtFechaApertura >= dPrimerFechaMes AND dtFechaApertura <= dUltimaFechaMes THEN
		  --- COMISION X ACTIVACION   1 sola vez
		  SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} NVL(SUM(monto),0)  INTO dComisionApertura
		  FROM bdicred:sd_movhis
		  WHERE empresa = '001'
		   and num_credito = a_num_credito
		   and codigo_fun = '339' and codigo_ref = '98'
		   and fecha_mov >= dtFechaApertura and fecha_mov <= dUltimaFechaMes 
		   and reversado = 'N';
		  
		  -- IVA COMISION X ACTIVACION 1 sola vez
		  SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} NVL(SUM(monto),0) INTO dIvaComisionApertura
		  FROM bdicred:sd_movhis
		  WHERE empresa = '001'
		   and num_credito = a_num_credito
		   and codigo_fun = '340' and codigo_ref = '28'
		   and fecha_mov >= dtFechaApertura and fecha_mov <= dUltimaFechaMes
		   and reversado = 'N'; 
	   END IF;

		--- COMISION X DISPOSICIÃN  (calcular la del perÃ­odo) 
		SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} NVL(SUM(monto),0) INTO dComisionDisposicion
		FROM bdicred:sd_movhis
		WHERE empresa = '001'
		 and num_credito = a_num_credito
		 and codigo_fun = '339' and codigo_ref = '99'
		 and fecha_mov >= dPrimerFechaMes and fecha_mov <= dUltimaFechaMes
		 and reversado = 'N';
		 
		--- IVA COMISION X DISPOSICIÃN (calcular la del perÃ­odo) 
		SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} NVL(SUM(monto),0) INTO dIvaComisionDisposicion
		FROM bdicred:sd_movhis
		WHERE empresa = '001'
		 and num_credito = a_num_credito
		 and codigo_fun = '340' and codigo_ref = '29'
		 and fecha_mov >= dPrimerFechaMes and fecha_mov <= dUltimaFechaMes
		 and reversado = 'N';
		----- OBTENER LOS DATOS PARA LA CALIFICACION ANTICIPO DE NÃMINA    MACF 20160621
							
		BEGIN WORK; --cs = credisolucion

		insert into bdicred:sd_sumascor    (empresa, cta_credisolucion, fecha_corte, fecha_cierre, num_credito, 
											numcte, numcte_coppel, linea_autorizada, limite_credito, saldo_corte, 
											saldo_cierre, saldo_vigente, saldo_transitorio, saldo_exigible, 
											saldo_noexigible, saldo_corte_credisolucion, saldo_cierre_credisolucion, interes_cred_ven, 
											pago_minimo, pagos_realizados, pago_vencido, impagos_consecutivos, impagos_historicos,
											probabilidad_incumplimiento, severidad_perdida, exposicion_incumplimiento, 
											reserva_calif_mes_anterior, reserva_edo_resultados, reserva_calificacion, reserva_buro,
											reserva_int_cred_ven, porcentaje_reserva, porcentaje_pago, porcentaje_uso,
											saldo_corteT_1, saldo_corteT_2, saldo_corteT_3,
											pagos_realizadosT_1, pagos_realizadosT_2, pagos_realizadosT_3,
											grado_riesgo, grado_riesgo_edo_resultados, fecha_apertura, antecedente_buro, status_cred,
											status_fin_mes, tipo_cliente, grupo, situacion_pago, eficiencia,
											meses_antiguedad, meses_historia, meses_vencidos, seccion1, seccion2, sumascor,
											sucursal, /*cuenta_contable,*/ saldo_ropa, saldo_muebles, saldo_prestamo,
											monto_pagar_inst, monto_pagar_rep_sic, ant_acreditado_inst, 
											--grado_riesgo_alto, grado_riesgo_medio, grado_riesgo_bajo, gveces1, gveces2, gveces3, bkatr)
											grado_riesgo_alto, grado_riesgo_medio, grado_riesgo_bajo, gveces1, gveces2, gveces3, bkatr, --NVO MACF
											comision_apertura, iva_comision_apertura, comision_disposicion, iva_comision_disposicion,	  --NVO MACF
											comision_cobranza, iva_comision_cobranza) 

							values 			(a_empresa, a_cta_credisolucion, a_fecha_corte, a_fecha_cierre, a_num_credito, 
											b_numcte, vNumCte_Ref, a_linea_autorizada, a_limite_credito, a_saldo_corte, 
											a_saldo_cierre, vSdo_Vigente, vSdo_Transitorio, vSdo_Exigible, 
											vSdo_noexigible, a_saldo_corte_credisolucion, a_saldo_cierre_credisolucion, a_interes_cred_ven, 
											a_pago_minimo, a_pagos_realizados, vPago_Vencido, a_impagos_consecutivos, a_impagos_historicos,
											a_probabilidad_incumplimiento, a_severidad_perdida, a_exposicion_incumplimiento, 
											a_reserva_calif_mes_anterior, a_reserva_edo_resultados, a_reserva_calificacion, a_reserva_buro,
											a_reserva_int_cred_ven, a_porcentaje_reserva, a_porcentaje_pago, a_porcentaje_uso,
--											a_saldo_corte, a_saldo_corte2, a_saldo_corte3,
											a_saldo_corte2, a_saldo_corte3, a_saldo_corte4,
											a_pagos_realizados1, a_pagos_realizados2, a_pagos_realizados3,
											a_grado_riesgo, a_grado_riesgo_edo_resultados, a_fecha_apertura, a_antecedente_buro, a_status_cred,
											a_status_fin_mes, vTipo_Cliente, d_grupo, d_situacion_pago, vEficiencia,
											a_meses_antiguedad, d_meses_historia, vMeses_Vencidos, dEvaluacion1, dEvaluacion2, sumcoring,
											b_sucursal, /*a_cuenta_contable,*/ vSaldoRopa, vSaldoMuebles, vsaldoPrestamos,
											a_monto_pagar_inst, a_monto_pagar_rep_sic, a_ant_acreditado_inst, 
											a_grado_riesgo_alto, a_grado_riesgo_medio, a_grado_riesgo_bajo, a_gveces1, a_gveces2, a_gveces3, a_bkatr, 
											dComisionApertura, dIvaComisionApertura, dComisionDisposicion, dIvaComisionDisposicion,0,0);	--- Nuevas cols. MACF 20160621
		COMMIT WORK;
	
end if;	
end foreach;

-- Se genera un archivo plano con la informaciÃ³n de reservas que inserta en la tabla sd_hist_reserva.
  LET vDia = lpad(DAY(dFechaHoy),2,'00');
  LET vMes = lpad(MONTH(dFechaHoy),2,'00');
  LET vAnio = YEAR(dFechaHoy);
  LET VcFechaFin = vMes || ',' || vDia || ',' || vAnio;
-->Codigo Pruebas Borrar

 let vsql = 'echo " unload to '''|| '/resplogifx/burodecredito/calificacion.unl'''||" delimiter '|' "||
             '" > /resplogifx/burodecredito/calificacion.sql';
  system vsql;
  let vsql = '';
  let vsql = 'echo "'||
             ' select * FROM sd_sumascor where fecha_cierre = mdy(' || VcFechaFin || ') '||					
             ' " >> /resplogifx/burodecredito/calificacion.sql';
  system trim(vsql); 

  let vsql = 'dbaccess bdicred /resplogifx/burodecredito/calificacion.sql';
  system vsql;

  let vsql = "cp /resplogifx/burodecredito/calificacion.unl /resplogifx/burodecredito/sd_hist_reserva_"|| vDia || vMes || vAnio ||".txt ";
  system vsql;

  let vsql = "gzip /resplogifx/burodecredito/sd_hist_reserva_"|| vDia || vMes || vAnio ||".txt ";
  system vsql;

  let vsql = "rm /resplogifx/burodecredito/calificacion.unl ";
  system vsql;
 ---

/*
  let vsql = 'echo " unload to '''|| '/resplogifx/burodecredito/calificacion.unl'''||" delimiter '|' "||
             '" > /resplogifx/burodecredito/calificacion.sql';
  system vsql;
  
  let vsql = 'echo "'||
             ' select * FROM sd_sumascor where fecha_cierre = mdy(' || VcFechaFin || ') '||						
             ' " >> /resplogifx/burodecredito/calificacion.sql';
  system trim(vsql); 

  let vsql = 'dbaccess bdicred /resplogifx/burodecredito/calificacion.sql';
  system vsql;

  let vsql = "cp /resplogifx/burodecredito/calificacion.unl /resplogifx/burodecredito/sd_hist_reserva_"|| vDia || vMes || vAnio ||".txt ";
  system vsql;

  let vsql = "gzip /resplogifx/burodecredito/sd_hist_reserva_"|| vDia || vMes || vAnio ||".txt ";
  system vsql;

  let vsql = "rm /resplogifx/burodecredito/calificacion.unl ";
  system vsql;
*/
 
    LET cCodRet     = "000000";
    LET cMensajeRet = "El proceso de REPORTE DE CALIFICACION se realizÃ³ correctamente";

	RETURN cCodRet, cMensajeRet, nuevos, actualizados;
END 
END PROCEDURE
DOCUMENT
"DescripciÃ³n: Procedimiento que obtiene la informaciÃ³n de calificaciÃ³n de reserva procesada al dÃ­a de cierre y la almacena para la generaciÃ³n",
            " del reporte",
"Autor: Viridiana Osobampo A.",
"BD: bdicred",
"Fecha: 01-04-2011",
'Modifico: Antonio Bastidas',
'Fecha: 13/06/2011',
'Version: 20110613.1059',
'DescripciÃ³n: Se modifica la consulta para obtener el saldo_corte de lo siguiente: total ctes inactivos, Saldo cierre ctes inactivos,',
' reserva ctes inactivos,Clientes totaleros y Saldo al cierre ctes totaleros',
'BD: bdicred',
'Modifico: Maria Elena Angulo',
'Fecha: 24/06/2011',
'Version: 20110624.1219',
'DescripciÃ³n: Se modifica la consulta para obtener el primer bloque de datos de la fecha corte del mes actual y para el bloque de datos de los ',
'clientes inactivos se obtienen de la fecha corte de un mes anterior y ademas tomando el pago realizado del mes actual',
'BD: bdicred',
'Fecha: 2013/08/01. ModificaciÃ³n: Cambiar la lÃ³gica de programaciÃ³n y eliminar la sentencia insert select para evitar crear candados y afectar la operativa.',
'ModificÃ³: Marco A. Campos',
'Fecha: 2016/06/21. Modificaciones para incluir los datos del producto Anticipo de NÃ³mina.',
'ModificÃ³: Marco A. Campos';

CREATE PROCEDURE "informix".sp_consulta_tdc_general(pEmpresa      CHAR(3),
                                                    pTransacc     CHAR(4),
													pCentroCosto  CHAR(4),
													pUsuario      CHAR(8),
													pFolio        CHAR(16),
													pNumTarjeta   CHAR(16),
													pCuenta       VARCHAR(20,1),
													pReferencia   VARCHAR(40,1))
RETURNING CHAR(5)         AS codigo_retorno,
          CHAR(4)         AS terminacion_tarjeta,
		  CHAR(60)        AS nombre_cte,
		  DECIMAL(14,2)   AS saldo_total,
		  DECIMAL(14,2)   AS pago_minimo,
		  DECIMAL(14,2)   AS pago_no_generar_interes,
          CHAR(10)	      AS fecha_limite_pago;
		  
DEFINE nrows             INTEGER;
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE cCodRet           CHAR(5);

DEFINE vCodRet           CHAR(5);
DEFINE vMensaje          VARCHAR(100,1);
DEFINE vCuenta           CHAR(20);
DEFINE vTarjeta          CHAR(20);
DEFINE vNumCte           CHAR(20);
DEFINE vSdoDisponible    DECIMAL(14,2);
DEFINE vNombreCte        CHAR(60);
DEFINE vPagoMin          DECIMAL(14,2);
DEFINE vFechaCorte       CHAR(10);
DEFINE vFechaPago        CHAR(10);
DEFINE vDisponible       DECIMAL(14,2);
DEFINE vSdoRetenido      DECIMAL(14,2);
DEFINE vIntMora          DECIMAL(14,2);
DEFINE vIvaIntMora       DECIMAL(14,2);
DEFINE sFecExp           DATE;
DEFINE vSdoTotal         DECIMAL(14,2);
DEFINE vTerminacion      CHAR(4);

LET nrows                = 0;
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = '';
LET cCodRet              = '000';

LET vCodRet              = '000';
LET vMensaje             = '';
LET vCuenta              = '';
LET vTarjeta             = '';
LET vNumCte              = '';
LET vSdoDisponible       = 0;
LET vNombreCte           = '';
LET vPagoMin             = 0;
LET vFechaCorte          = '';
LET vFechaPago           = '';
LET vDisponible          = 0;
LET vSdoRetenido         = 0;
LET vIntMora             = 0;
LET vIvaIntMora          = 0;
LET sFecExp              = DATE(1);
LET vSdoTotal            = 0;
LET vTerminacion         = '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
		LET vCodRet = iSqlErr;
		RETURN vCodRet, vTerminacion, vNombreCte, vSdoDisponible, vPagoMin, vSdoTotal, vFechaPago;
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/paulq/sp_consulta_tdc_general.out';
--TRACE ON;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

IF NOT EXISTS( SELECT empresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa) THEN
	LET vCodRet = "1070";
	RETURN vCodRet, vTerminacion, vNombreCte, vSdoDisponible, vPagoMin, vSdoTotal, vFechaPago;
END IF;

IF NOT EXISTS(SELECT numero FROM bdinteg:"informix".si_transacc WHERE sistema = '06' and numero = pTransacc) THEN
	LET vCodRet = "1071";
	RETURN vCodRet, vTerminacion, vNombreCte, vSdoDisponible, vPagoMin, vSdoTotal, vFechaPago;
END IF;

IF TRIM(NVL(pCentroCosto,'')) = '' THEN 
	LET vCodRet = "1072";
	RETURN vCodRet, vTerminacion, vNombreCte, vSdoDisponible, vPagoMin, vSdoTotal, vFechaPago;
END IF;

IF TRIM(NVL(pUsuario,'')) = '' THEN
	LET vCodRet = "1073";
	RETURN vCodRet, vTerminacion, vNombreCte, vSdoDisponible, vPagoMin, vSdoTotal, vFechaPago;
END IF;

IF TRIM(NVL(pFolio,'')) = '' THEN
	LET vCodRet = "1074";
	RETURN vCodRet, vTerminacion, vNombreCte, vSdoDisponible, vPagoMin, vSdoTotal, vFechaPago;
END IF;

IF TRIM(NVL(pReferencia,'')) = '' THEN
	LET vCodRet = "1075";
	RETURN vCodRet, vTerminacion, vNombreCte, vSdoDisponible, vPagoMin, vSdoTotal, vFechaPago;
END IF;

IF TRIM(NVL(pNumTarjeta,'')) = '' AND TRIM(NVL(pCuenta,'')) = '' THEN
	LET vCodRet = "1076";
	RETURN vCodRet, vTerminacion, vNombreCte, vSdoDisponible, vPagoMin, vSdoTotal, vFechaPago;
END IF;

CALL "informix".cons_sdos2 (pEmpresa,pCuenta,pNumTarjeta)
RETURNING vCodRet, vCuenta, vTarjeta, vNumCte, vSdoDisponible,
		  vNombreCte, vPagoMin, vFechaCorte, vFechaPago, vDisponible,
		  vSdoRetenido, vIntMora, vIvaIntMora, sFecExp;
	
	IF vCodRet = "000" THEN
	    LET vTerminacion = SUBSTR(vTarjeta,LENGTH(vTarjeta)-3,LENGTH(vTarjeta));
		
		CALL "informix".sp_consultasaldocortemin(pEmpresa,vCuenta,2)
		RETURNING vCodRet, vSdoTotal;
		
		IF vCodRet = "00000" AND TRIM(pReferencia) <> 'CON' THEN 
			CALL "informix".genmov(pEmpresa,vCuenta,'6001',0,'000',TODAY,0,pFolio,pCentroCosto,'01',pTransacc)
			RETURNING vCodRet, vMensaje;
		END IF;
	END IF;		  
	
IF vCodRet = "00000" THEN
  LET vCodRet = "000";
END IF;

IF vSdoDisponible < 0 THEN
  LET vSdoDisponible = 0;
END IF;

IF vPagoMin < 0 THEN
  LET vPagoMin = 0;
END IF;

IF vSdoTotal < 0 THEN
  LET vSdoTotal = 0;
END IF;
	
RETURN vCodRet, vTerminacion, vNombreCte, vSdoDisponible, vPagoMin, vSdoTotal, vFechaPago;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento realizar invocar la',
'consulta de saldos TDC',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 08/09/2015',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_obtener_prospectos_aumlincred_ofi
(
	pEmpresa CHAR(3),	
	pSucursal  CHAR(4),
	pNumCredito CHAR(20),
	pNumProd	CHAR(4),
	pNumcte    CHAR(20),
	pNumcte_cop CHAR(20),
	pLincredSolicitada DECIMAL(18,2),
	pComprobanteIngresos  CHAR(2),
	pMensaje CHAR(250),
	pFechaHoyAumlincred DATE,
	pEjecutivo CHAR(8),
	pIngresoMensual DECIMAL(18,2)
)
RETURNING CHAR(6)  AS codigo_retorno, CHAR(80) AS mensaje_retorno;           
          
DEFINE cCodRet     CHAR(6); 
DEFINE cMensajeRet CHAR(150);
DEFINE iSqlErr     INTEGER;
DEFINE iIsamErr    INTEGER;
DEFINE cErrorInfo  CHAR(80);
DEFINE dMontoOtor  DECIMAL(18,2);
DEFINE iBandera INTEGER;
DEFINE cOrigen CHAR(1);

LET cCodRet      = "000000";
LET cMensajeRet  = "Se realizÃ³ la consulta correctamente";
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET cErrorInfo   = "";
LET dMontoOtor   = 0;
LET iBandera = 0;
LET cOrigen = "S";


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
       LET cCodRet= iSqlErr;
       LET cMensajeRet= cErrorInfo;
       RETURN cCodRet, cMensajeRet;     
   END IF;
END EXCEPTION;


--SET DEBUG FILE TO '/informix/jesus/incrementos/sp_obtener_prospectos_aumlincred_ofi.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,"") = ""  OR NVL(pSucursal,"") = "" OR NVL(pNumCredito,"") = "" OR NVL(pNumcte,"") = "" 
	OR NVL(pLincredSolicitada,0) = 0 OR NVL(pComprobanteIngresos,"") = "" THEN
		LET cCodRet                  = '000001';
		LET cMensajeRet              = 'Parametro requerido esta vacio';
		RETURN cCodRet, cMensajeRet;
	END IF;
 	
	IF NOT EXISTS (SELECT num_solicitud FROM  "informix".sd_bitacora_aumlincred WHERE  empresa = pEmpresa AND   num_solicitud = pNumCredito AND  numcte =  pNumcte AND  fecha_insert =  pFechaHoyAumlincred   ) THEN	
	
		SELECT b.monto_otorgado
		INTO dMontoOtor
		FROM "informix".sd_maecred a 
		INNER JOIN "informix".sd_maesdos b ON a.empresa = b.empresa AND a.num_credito = b.num_credito
		WHERE a.empresa     = pEmpresa
		AND a.num_credito = pNumCredito;
		
			

IF EXISTS(SELECT ejecutivo FROM "informix".sd_perfiles_cac_aumlincred where empresa = 	pEmpresa AND ejecutivo = pEjecutivo) 
	THEN
		LET cOrigen = 'C';
	ELSE
		LET cOrigen = 'S';
	END IF

	
		INSERT INTO  "informix".sd_bitacora_aumlincred (empresa, num_solicitud, numcte, num_producto, status, causa_status, fecha_status, hora_status, sucursal,lincred_actual, lincred_sugerida, smb_lincred,grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert,	fecha_insert,	numcte_cop, lincred_solicitada, comp_ingreso)	
		VALUES (pEmpresa, pNumCredito, pNumcte, pNumProd, "PC", "",pFechaHoyAumlincred, CURRENT, pSucursal, dMontoOtor, 0, 0, "", 0,"","",pMensaje,"","",cOrigen, pEjecutivo, pFechaHoyAumlincred,pNumcte_cop,pLincredSolicitada,pComprobanteIngresos);		
		
		INSERT INTO "informix".sd_autorizacion_aumlincred
		(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
		VALUES(pEmpresa, pNumCredito, "PC", "", pEjecutivo, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
		
		UPDATE bdisolic:"informix".ss_resum_scor_fin
			SET ingreso_mensual = pIngresoMensual
		WHERE num_solicitud = pNumCredito;
		
		EXECUTE PROCEDURE "informix".sp_identificar_clientes_ofi(pEmpresa,pNumCredito)
		INTO cCodRet, cMensajeRet;
	END IF
     
RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para el registro de la solicitud de incremento de clientes desde sucursal',
'AUTOR : JesÃºs Manuel Aguilar Heredia',
'FECHA : 08/Noviembre/2011',
'BD    : BDICRED',
'Modificacion: Se agrega el monto otorgado en el campo lincred_actual de la bitacora en lugar de insertarlo en cero.',
'AUTOR : Mohamed CarreÃ³n',
'FECHA : 25/Julio/2012',
'BD    : bdicred',
'VERSION:20120826.0940',
'Modificacion:  se  agrega  validacion  para que verifÃ­que  que exista registro en la tabla  "informix".sd_bitacora_aumlincred antes de insertarlo',
'AUTOR :  Mario Gallardo',
'FECHA : 17/05/2013',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_obteninfosolincred_mc(pEmpresa CHAR(3), pNumCredito CHAR(20), pNumcte CHAR(20))
														   
RETURNING CHAR(6)           AS cod_ret,
          VARCHAR(107,1)    AS mensaje_ret,
	      VARCHAR(20,1)     AS numero_credito,
		  VARCHAR(20,1)     AS numero_cte,
		  VARCHAR(4,1)      AS sucursal,
		  VARCHAR(4,1)      AS numero_producto;	

DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cErrorInfo      VARCHAR(255,1);
DEFINE cCodRet         CHAR(6);
DEFINE cMensajeRet     VARCHAR(107,1);

DEFINE vNumCredito     VARCHAR(20,1);
DEFINE vNumcte         VARCHAR(20,1);
DEFINE vSucursal       VARCHAR(4,1);
DEFINE vNumProd        VARCHAR(4,1);

LET iSqlErr            = 0;
LET iIsamErr           = 0;
LET cErrorInfo         = "";
LET cCodRet            = "000000";
LET cMensajeRet        = "CONSULTA EXITOSA";

LET vNumCredito        = "";
LET vNumcte            = "";
LET vSucursal          = "";
LET vNumProd           = "";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet     = iSqlErr;
	 LET cMensajeRet = cErrorInfo;
     RETURN NVL(cCodRet,''),NVL(cMensajeRet,''), NVL(vNumCredito,''), NVL(vNumcte,''), NVL(vSucursal,''), NVL(vNumProd,'');
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/paulq/sp_obteninfosolincre_mc.out';
	--TRACE ON;

	IF NVL(pEmpresa,"") = "" OR (NVL(pNumCredito,"") = "" AND NVL(pNumcte,"") = "" ) THEN
	 LET cCodRet = "000001";
	 LET cMensajeRet = "PARAMETROS DE ENTRADA INVALIDOS";
	 RETURN NVL(cCodRet,''),NVL(cMensajeRet,''), NVL(vNumCredito,''), NVL(vNumcte,''), NVL(vSucursal,''), NVL(vNumProd,'');
	END IF;

	IF TRIM(NVL(pNumCredito,'')) = '' THEN LET pNumCredito = ''; END IF;
	IF TRIM(NVL(pNumcte,'')) = '' THEN LET pNumcte = ''; END IF;
	
	FOREACH WITH HOLD
	SELECT LIMIT 1 num_credito,numcte,sucursal,num_producto
	  INTO vNumCredito, vNumcte, vSucursal, vNumProd
      FROM "informix".sd_maecred
     WHERE empresa = pEmpresa
       AND num_credito =  (CASE WHEN pNumCredito > '' THEN pNumCredito ELSE num_credito END)
       AND numcte = (CASE WHEN pNumcte > '' THEN pNumcte ELSE numcte END)	   
	   
	   RETURN NVL(cCodRet,''),NVL(cMensajeRet,''), NVL(vNumCredito,''), NVL(vNumcte,''), NVL(vSucursal,''), NVL(vNumProd,'') WITH RESUME;
	   
    END FOREACH;
	   
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		 LET cCodRet = "000002";
		 LET cMensajeRet = "NO HAY INFORMACIÒN CON EL FILTRO INDICADO";
		 RETURN NVL(cCodRet,''),NVL(cMensajeRet,''), NVL(vNumCredito,''), NVL(vNumcte,''), NVL(vSucursal,''), NVL(vNumProd,'');
	END IF;	
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para la informaciòn de la solicitud.',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 01/OCT/2016',
'BD: BDICRED',
'VERSION:20161001.0001';

CREATE PROCEDURE "informix".cargoref_tc_ofi(o_empresa  CHAR(3),
				 o_sucursal CHAR(4),
				 o_usuario  CHAR(8),
				 o_tarjeta  CHAR(20),
				 o_monto    DECIMAL(14,2),
				 o_folio    CHAR(16),
				 o_transuc  CHAR(4))

RETURNING CHAR(5),       -- Codigo Retorno
	  DECIMAL(14,2), -- Saldo Disponible 
          DECIMAL(14,2), -- Importe Cargado
	  DECIMAL(14,2), -- Importe Comision
          DECIMAL(14,2); -- Iva de Comisiones

-- **************************************************************************
-- *                      DEFINICION DE VARIABLES                           *
-- **************************************************************************
DEFINE cod_ret            CHAR(5);
DEFINE cod_ret2           CHAR(5);
DEFINE sql_err            SMALLINT;
DEFINE isam_err           SMALLINT;
DEFINE error_info         CHAR(40);
DEFINE Saldo              MONEY(14,2);
DEFINE SaldoCom           MONEY(14,2);
DEFINE v_monto		      MONEY(14,2);
DEFINE v_codparam	   	  CHAR(4);
DEFINE v_fecha            DATE;
DEFINE v_num_credito      CHAR(20);
DEFINE v_divisa		  	  CHAR(2);
DEFINE MtoCgo		  	  MONEY(14,2);
DEFINE MtoCom		   	  MONEY(12,2);
DEFINE v_faplica          CHAR(1);
DEFINE v_factor		 	  DECIMAL(9,6);
DEFINE v_rangos		 	  CHAR(1);
DEFINE v_rmax	          MONEY(14,2);
DEFINE vIva		  		  MONEY(14,2);
DEFINE dMonto		 	  DECIMAL(18,2);
DEFINE cFolioPromo		  CHAR(16);
DEFINE cCodRetGenMov	  CHAR(10);
DEFINE cMsjeGenMov		  CHAR(80);
DEFINE v_dv               CHAR(2);
DEFINE v_tipocambio       DECIMAL(14,6);
DEFINE vsucorig           CHAR(4);
DEFINE vBloqueo           INTEGER;
DEFINE dfh_pre_devol_an   DATE;
DEFINE dfh_devol_an       DATE;
DEFINE dSdoCapInsol       DECIMAL(18,2);
DEFINE cCodRetDevol		  CHAR(5);
DEFINE cMen_retDevol      CHAR(80);
DEFINE dMntoDevol         DECIMAL(16,2);

-- **************************************************************************
-- *                      CONTROL DE ERRORES                                *
-- **************************************************************************

ON EXCEPTION SET sql_err, isam_err, error_info
   SET DEBUG FILE TO "CargoLineaCredito.err";
--   TRACE sql_err||" * "||isam_err||" * "||error_info;
   LET cod_ret = sql_err;
   LET Saldo = 0;
   RETURN cod_ret, SaldoCom, MtoCgo, MtoCom, vIva;
END EXCEPTION;



-- **************************************************************************
-- *                      ASIGNACION DE VARIABLES                           *
-- **************************************************************************

LET cod_ret             = "000";
LET Saldo               = 0;
LET cod_ret2            = "000";
LET SaldoCom            = 0;
LET MtoCgo              = 0;
LET MtoCom              = 0;
LET vIva                = 0;
LET dMonto              = 0;
LET cFolioPromo         = "";
LET cCodRetGenMov		= "";
LET cMsjeGenMov		    = "";
LET v_dv                = "00";
LET v_tipocambio        = 0;
LET vsucorig            ="";
LET vBloqueo            = 0;
LET dfh_pre_devol_an    = date(1);
LET dfh_devol_an        = date(1);
LET dSdoCapInsol = 0;
LET cCodRetDevol		= "";
LET cMen_retDevol       = ""; 
LET dMntoDevol          = 0;

--SET DEBUG FILE TO "/tmp/cargofi.out";
--TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	-- **************************
	-- **************************
	SELECT a.num_credito, b.divisa, b.sucursal, b.id_unidad_prod
	  INTO v_num_credito, v_divisa, vsucorig,   vBloqueo
	  FROM bdicred:"informix".sd_tarjeta a, bdicred:"informix".sd_maecred b
	 WHERE a.empresa = o_empresa
	   AND a.num_tarjeta = o_tarjeta
	   AND b.empresa = a.empresa
	   AND b.num_credito = a.num_credito;

	IF v_num_credito IS NULL THEN
		LET cod_ret = "008";
	        RETURN cod_ret, SaldoCom, MtoCgo, MtoCom, vIva;
	END IF

	EXECUTE PROCEDURE bdicred:"informix".cargo_ref_cel(o_tarjeta, o_sucursal, o_usuario,
					o_transuc, o_transuc,  o_folio,
					v_num_credito, 1, o_monto, 0,
					" ", " ", v_divisa, "",  
					o_sucursal, o_usuario, "",
					"", "", v_num_credito,
					1, 0, v_divisa, " ", "2",
					"F"," ", " ", " ", 0, 0, " ", " ")
	INTO cod_ret, v_codparam, v_fecha, Saldo, MtoCgo, 
	     cod_ret2, v_codparam, v_fecha, SaldoCom, MtoCom;

	SELECT SUM(monto_com) INTO vIva 
          FROM bdicred:"informix".sd_detcomi
	 WHERE num_credito = v_num_credito
           AND cod_comis IN ("6260","6261")
	   AND num_solicitud = o_folio
           AND empresa = o_empresa
	   AND num_credito=v_num_credito;

	SELECT SUM(monto_com) INTO MtoCom 
          FROM bdicred:"informix".sd_detcomi
	 WHERE num_credito = v_num_credito
           AND cod_comis IN ("6902","6901")
	   AND num_solicitud = o_folio
           AND empresa = o_empresa
	   AND num_credito=v_num_credito;

       SELECT sdo_cap_insoluto + sdo_retenido    
         INTO SaldoCom                        
         FROM bdicred:"informix".sd_maesdos                         
        WHERE empresa = o_empresa
          AND num_credito=v_num_credito;

	IF MtoCom IS NULL THEN
		LET MtoCom = 0;
		LET vIva   = 0;
	END IF
	
	--JMAH 
	-- OBTIENE EL FOLIO DE LA PROMOCION Y EL MONTO DE LOS INTERESES DE CREDISOLUCIONES
	SELECT folio_movto, monto_int_iva
	INTO cFolioPromo, dMonto
	FROM bdicred:"informix".sd_promocion_credito
	WHERE num_credito = v_num_credito 
	AND folio_movto = o_folio 
	AND status = 6;
	-- VALIDA SI EL CARGO TUVO UNA CREDISOLUCION DE EFECTIVO LIGADA
	IF NVL(cFolioPromo,"") <> "" THEN

        SELECT valor INTO v_dv FROM bdinteg:si_param WHERE cod_param = 17;

		SELECT precio_venta INTO v_tipocambio
	          FROM bdinteg:si_tpcambio
		 WHERE empresa = "001"
		   AND divisa = v_dv
		   AND clase_tpcambio = "O"
		   AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
					   FROM bdinteg:si_tpcambio
					  WHERE empresa = "001"
					    AND divisa = v_dv);

		UPDATE bdicred:"informix".sd_maesdos SET sdo_retenido = sdo_retenido + dMonto
		WHERE empresa = o_empresa
		AND num_credito = v_num_credito;

		INSERT INTO bdicred:"informix".sd_maeretenido
		(empresa, num_credito, folio_suc, fecha, hora, transacc, dias_ret,monto, usuario, estatus, referencia, sucursal, dias_ori)
		VALUES(o_empresa, v_num_credito, o_folio, CURRENT, CURRENT HOUR TO FRACTION(3),"6837", 0, dMonto, o_usuario, "R", trim(cFolioPromo) || ' RET. CREDISOLUCIONES', o_sucursal, 0);	
		
		UPDATE bdicred:"informix".sd_promocion_credito
			SET status = 0
		WHERE num_credito = v_num_credito
		AND folio_movto = o_folio;		

--     GENERAMOS EL MOVIMIENTO DEL RETENIDO DE LOS INTERESES
		EXECUTE PROCEDURE bdicred:"informix".genmov_tc('001',v_num_credito,'6001',TODAY,dMonto,o_folio,o_sucursal,v_divisa,'6837',o_tarjeta,'RET. CREDISOLUCIONES',v_tipocambio,0,o_usuario,vsucorig,'','')
		INTO cCodRetGenMov, cMsjeGenMov;

	END IF;

	-- Devolucion anualidad RQM 10 850 INI
	-- Obtiene marcas de creditos pre-cancelados por devolucion de anualidad
	SELECT nvl(date(ind.fecha_pre_devol_anual),date(1)), nvl(date(ind.fecha_devol_anual),date(1)), dos.sdo_cap_insoluto 
      INTO dfh_pre_devol_an,                       dfh_devol_an,                       dSdoCapInsol
      FROM bdicred:sd_indicador_cred ind JOIN bdicred:sd_maesdos dos ON (ind.empresa = dos.empresa and ind.num_credito = dos.num_credito )
     WHERE ind.empresa = '001' AND ind.num_credito = v_num_credito;
	 
	-- Si el credito tiene devolucion de anualidad, y el retiro termino correctamente, que proceda a marcar el credito como devolucion realizada.
	IF vBloqueo = 4 AND nvl(dfh_pre_devol_an,date(1)) > date(1) AND nvl(dfh_devol_an,date(1)) = date(1) AND dSdoCapInsol = 0 THEN
		-- Reinicia fecha para validaciones correctas en caso de retiro despues de un reverso del 1er retiro.
        EXECUTE PROCEDURE "informix".sp_comision_anual_devolucion(o_empresa, v_num_credito, o_usuario) INTO cCodRetDevol, cMen_retDevol, dMntoDevol;
		IF (cCodRetDevol = '00000' OR cCodRetDevol = '1208') AND dMntoDevol = 0 THEN
            LET cod_ret = '1208'; -- Retiro de devolucion correcto. Credito se cancelara.
			--LET cod_ret = '0000'; -- Retiro de devolucion correcto. Credito se cancelara.
		END IF

	END IF;
	-- Devolucion anualidad RQM 10 850 FIN

   RETURN cod_ret, SaldoCom, MtoCgo, MtoCom, vIva;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se modifica para contemplar movimientos diferidos, en el proceso de realizar el cargo al crédito', 
'AUTOR: Jesús Aguilar ',
'FECHA: 08 FEBRERO 2012',
'BD: BDICRED',
'DESCRIPCION MODIFICACION: Se cambia el proceso para que guarde la transaccion 6837 en los retenidos de los intereses en lugar de la transaccion de disposición',
'MODIFICO: Mohamed Carreón',
'VERSION: 20120607.0919';

CREATE PROCEDURE "informix".sp_ticket_credisoluciones (pEmpresa CHAR(3), pfolioSuc CHAR(20))
RETURNING CHAR (5)      AS CodRet,
		  CHAR (104)    AS Nombre,
		  CHAR (20)     AS CrediSoluccion,
		  CHAR (20)     AS Cliente,
		  DECIMAL(18,2) AS Monto,
		  CHAR (20)     AS Cuenta,
		  DECIMAL(18,2) AS SaldoActual,
		  DATE          AS FechaProximo,
		  INT           AS Tipo;
		  

	DEFINE iSqlErr       INT;
	DEFINE cCodRet       CHAR(5);	  
	DEFINE cNombre       CHAR(104);
    DEFINE cCrediSol     CHAR(20);
	DEFINE cCrediSol2    CHAR(20);
	DEFINE cCliente      CHAR(20);
	DEFINE cCliente2     CHAR(20);
	DEFINE dMonto        DECIMAL(18,2);
	DEFINE dMonto2       DECIMAL(18,2);
	DEFINE cCuenta       CHAR(20);
	DEFINE cCuenta2      CHAR(20);
	
	DEFINE cNombre1      CHAR(26);
	DEFINE cNombre2      CHAR(26);
	DEFINE cApPat        CHAR(26);
	DEFINE cApMat        CHAR(26);
	
	DEFINE dSaldoActual  DECIMAL(18,2);
	DEFINE dSaldoActual2 DECIMAL(18,2);
	DEFINE dfechaproxi   DATE;
	DEFINE dfechaproxi2  DATE;
	DEFINE ctransac      CHAR(4);
	DEFINE iTipo         INT;
	
	LET iSqlErr       = 0;
	LET cCodRet       = '00000';	  
	LET cNombre       = '';
    LET cCrediSol     = '';
	LET cCrediSol2    = '';
	LET cCliente      = '';
	LET cCliente2     = '';
	LET dMonto        = 0.00;
	LET dMonto2       = 0.00;
	LET cCuenta       = '';
	LET cCuenta2      = '';
	
	LET cNombre1      = '';
	LET cNombre2      = '';
    LET cApPat        = '';	
	LET cApMat        = '';	  
		  
	LET dSaldoActual  = 0.00;
	LET dSaldoActual2 = 0.00;
	LET dfechaproxi   = DATE(1);
	LET dfechaproxi2  = DATE(1);
	LET ctransac 	  = '';
	LET iTipo         = 0;
	  
--SET DEBUG FILE TO '/respaldosbd/felipe/sp_ticket_credisoluciones_test.out';
--TRACE ON;  
BEGIN
    ON EXCEPTION SET iSqlErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet, cNombre, cCrediSol, cCliente, dMonto, cCuenta, dSaldoActual, dfechaproxi, iTipo;
       END IF;
    END EXCEPTION;
		  
		  
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;		  
		  
	IF TRIM(NVL(pEmpresa,'')) <> '' AND TRIM(NVL(pfolioSuc,'')) <> '' THEN
	
		SELECT num_credito, monto
		INTO cCrediSol2, dMonto2
		FROM bdicred:"informix".sd_movdiacrd 
		WHERE folio_suc = pfolioSuc 
		AND codigo_ref= 1;
		
		IF TRIM(NVL(cCrediSol2,'')) <> '' THEN
			
			SELECT b.numcte, b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno 
			INTO cCliente2, cNombre1, cNombre2, cApPat, cApMat
			FROM bdicred:"informix".sd_promocion_credito a, bdinteg:"informix".si_cliente b
			WHERE a.num_cte = b.numcte
			AND a.empresa = b.empresa
			AND a.empresa = pEmpresa
			AND a.num_sol_prestamo = cCrediSol2; 
			
			IF TRIM(NVL(cNombre1,'')) <> '' AND TRIM(NVL(cApPat,'')) <> '' THEN
				
				SELECT saldo_actual, fechaproximopago, transaccion
				INTO dSaldoActual2, dfechaproxi2, ctransac
				FROM bdicred:"informix".sd_pago_anticipado_cs
				WHERE empresa = pEmpresa
				AND folio_suc = pfolioSuc;
				
				IF TRIM(NVL(ctransac,'')) <> '' THEN
					
					IF TRIM(NVL(ctransac,'')) = '618' THEN --efectivo
						LET iTipo = 1;
					ELIF TRIM(NVL(ctransac,'')) = '623' THEN-- cargo
						LET iTipo = 2;
					END IF;
					
					IF iTipo = 2 THEN
						SELECT cuenta
						INTO cCuenta2
						FROM bdicheq:"informix".sc_movdia
						WHERE empresa = pEmpresa
						AND folio_suc = pfolioSuc;
					END IF;
				
					LET cNombre = TRIM(NVL(cNombre1,'')) || ' ' || TRIM(NVL(cNombre2,''));
					LET cNombre = TRIM(cNombre) || ' ' || TRIM(NVL(cApPat,'')) || ' ' || TRIM(NVL(cApMat,''));
					LET cNombre = TRIM(cNombre);
					LET cCrediSol = cCrediSol2;
					LET cCliente = cCliente2;
					LET dMonto = dMonto2;
					LET cCuenta = cCuenta2;
					LET dSaldoActual = dSaldoActual2;
					LET dfechaproxi = dfechaproxi2;
					
					RETURN cCodRet, NVL(cNombre,''), NVL(cCrediSol, ''), NVL(cCliente, ''), NVL(dMonto, 0.00), NVL(cCuenta, ''), NVL(dSaldoActual, 0.00), NVL(dfechaproxi, DATE(1)), NVL(iTipo,0);
				ELSE
					LET cCodRet = '00004';
				END IF;
			ELSE
				LET cCodRet = '00003';
			END IF;
		ELSE
			LET cCodRet = '00002';
		END IF;
	ELSE
		LET cCodRet = '00001';
	END IF;
	
	IF cCodRet <> '00000' THEN
		RETURN cCodRet, NVL(cNombre,''), NVL(cCrediSol, ''), NVL(cCliente, ''), NVL(dMonto, 0.00), NVL(cCuenta, ''), NVL(dSaldoActual, 0.00), NVL(dfechaproxi, DATE(1)), NVL(iTipo,0);
	END IF;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: se crea para datos para la reimpresion de ticket de pago de credisoluciones',
'AUTOR : Felipe Urias',
'FECHA : 28/11/2015',
'BD    : bdicred';

CREATE PROCEDURE "informix".totcomp(o_empresa CHAR(3), o_usuario CHAR(8), o_sucursal CHAR(4), o_num_total SMALLINT)

	RETURNING	CHAR(5),
				CHAR(2),
				MONEY(16, 2),
				MONEY(16, 2),
				MONEY(16, 2),
				MONEY(16, 2),
				CHAR(40),
				INTEGER,
				INTEGER,
				INTEGER,
				INTEGER;

	-- ============================================================================
	-- =                        DEFINICION DE VARIABLES                           =
	-- ============================================================================
	DEFINE v_monto_cargo		MONEY(16, 2);
	DEFINE v_monto_firme		MONEY(16, 2);
	DEFINE v_monto_firme_crd 	MONEY(16, 2);
	DEFINE v_monto_sbc			MONEY(16, 2);
	DEFINE v_monto_rem			MONEY(16, 2);
	DEFINE v_movto_cargo		INTEGER;
	DEFINE v_movto_firme		INTEGER;
	DEFINE v_movto_firme_crd	INTEGER;
	DEFINE v_movto_sbc			INTEGER;
	DEFINE v_movto_rem			INTEGER;
	DEFINE v_descripcion		CHAR(40);
	DEFINE v_contador			SMALLINT;
	DEFINE v_fecha				DATE;
	DEFINE v_row				INTEGER;
	DEFINE v_codret				CHAR(5);
	DEFINE v_empresa			CHAR(3);
	DEFINE w_plaza				CHAR(3);
	DEFINE w_sucursal			CHAR(4);
	DEFINE v_producto			CHAR(4);
	DEFINE v_ciclo				SMALLINT;
	DEFINE v_divisa				CHAR(2);
	DEFINE v_cal_int_chq		CHAR(1);
	DEFINE sql_err				INTEGER;
	DEFINE v_usuario			CHAR(8);
	DEFINE v_existe				CHAR(1);
	DEFINE iContador			INTEGER;

	-- ============================================================================
	-- =                        ASIGNACION DE VALORES                             =
	-- ============================================================================
	LET v_monto_cargo		= 0;
	LET v_monto_firme		= 0;
	LET v_monto_firme_crd 	= 0;
	LET v_monto_sbc			= 0;
	LET v_monto_rem			= 0;
	LET v_movto_cargo		= 0;
	LET v_movto_firme		= 0;
	LET v_movto_firme_crd	= 0;
	LET v_movto_sbc			= 0;
	LET v_movto_rem			= 0;
	LET v_descripcion		= "";
	LET v_contador			= 0;
	LET v_fecha				= DATE(1);
	LET v_row				= 0;
	LET v_codret			= "00000";
	LET v_empresa			= "";
	LET w_plaza				= "";
	LET w_sucursal			= "";
	LET v_producto			= "";
	LET v_ciclo				= 0;
	LET v_divisa			= "";
	LET v_cal_int_chq		= "";
	LET sql_err				= 0;
	LET v_usuario			= "";
	LET v_existe			= "";
	LET iContador			= 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/tmp/totcomp.out";
	--TRACE ON;

	--"223" Efectivo, pago normal.
	--"020" Efectivo, pago anticipado prestamo personal.
	--"221" Efectivo, pago anticipado reestructura.

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_coDret = sql_err;
					RETURN v_codret, v_divisa, v_monto_cargo, v_monto_firme, v_monto_sbc, v_monto_rem, v_descripcion,
					v_movto_cargo, v_movto_firme, v_movto_sbc, v_movto_rem;
			END IF
		END EXCEPTION;

		SELECT {+INDEX(sd_fechas idx_sdfechas)} fecha_hoy INTO v_fecha
		FROM bdicred:sd_fechas WHERE empresa = o_empresa;

		FOREACH WITH HOLD

			SELECT divisa, descripcion INTO v_divisa, v_descripcion
			FROM bdinteg:"informix".si_divisas WHERE divisa = divisa AND empresa = o_empresa

			SELECT {+INDEX(sd_movdia idx_movdia2)}
			NVL(SUM(CASE WHEN codigo_fun = '002' THEN monto END), 0),
			NVL(SUM(CASE WHEN codigo_fun = '002' THEN 1 END), 0),
			NVL(SUM(CASE WHEN codigo_fun IN ('033', '333', '067') THEN monto END), 0),
			NVL(SUM(CASE WHEN codigo_fun IN ('033', '333','067') THEN 1 END), 0),
			NVL(SUM(CASE WHEN codigo_fun = "336" AND codigo_ref = 20 THEN monto END), 0),
			NVL(SUM(CASE WHEN codigo_fun = "336" AND codigo_ref = 20 THEN 1 END), 0)
			INTO v_monto_cargo,
			v_movto_cargo,
			v_monto_firme,
			v_movto_firme,
			v_monto_sbc,
			v_movto_sbc
			FROM bdicred:"informix".sd_movdia a
			WHERE usuario = o_usuario
			AND sucursal = o_sucursal
			AND ((codigo_fun IN ("033", "333", "067") AND codigo_ref = 1)
			OR (codigo_fun = "336" AND codigo_ref = 20)
			OR (codigo_fun = "002" AND codigo_ref IN (50, 60)))
			AND reversado <> "S"
			AND fecha_mov = v_fecha
			AND empresa = o_empresa
			AND divisa = v_divisa;
			--AAME 07/03/2017 RQM 10 282 Se contemplan codigo fun de pagos anticipados de credisolucion 076 y 077 desde la caja
			SELECT {+INDEX(sd_movdiacrd idx_movdiacrd2)}
			NVL(SUM(CASE WHEN codigo_fun IN ('027','028','225','077') THEN monto END), 0),
			NVL(SUM(CASE WHEN codigo_fun IN ('027','028','225','077') THEN 1 END), 0)
			INTO v_monto_firme_crd,
			v_movto_firme_crd
			FROM bdicred:"informix".sd_movdiacrd a
			WHERE usuario = o_usuario
			AND sucursal = o_sucursal
			AND (codigo_fun IN ("027","028","225","077") AND codigo_ref = 1)
			AND reversado <> "S"
			AND fecha_mov = v_fecha
			AND empresa = o_empresa
			AND divisa = v_divisa;

			LET v_monto_firme = NVL(v_monto_firme,0) + NVL(v_monto_firme_crd,0);
			LET v_movto_firme = NVL(v_movto_firme,0) + NVL(v_movto_firme_crd,0);

			IF NOT (v_monto_cargo = 0 AND v_movto_cargo = 0 AND v_monto_firme = 0 AND v_movto_firme= 0
			AND v_monto_sbc = 0 AND v_movto_sbc = 0 ) THEN
				LET iContador = iContador + 1;
				RETURN v_codret, v_divisa, v_monto_cargo, v_monto_firme, v_monto_sbc, v_monto_rem, TRIM(v_descripcion),
				v_movto_cargo, v_movto_firme, v_movto_sbc, v_movto_rem WITH RESUME;
			END IF;
		END FOREACH;    

		--IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		--	LET v_codret = "00001"; --"No existen divisas cargadas en el catalogo para iniciar las consultas.";
		--ELIF iContador = 0 THEN
		--	LET v_codret = "00002"; --"No existe información con las divisas consultadas.";
		--END IF;

		--IF v_codret <> "00000" THEN
		--	RETURN v_codret, v_divisa, v_monto_cargo, v_monto_firme, v_monto_sbc, v_monto_rem, TRIM(v_descripcion),
		--	v_movto_cargo, v_movto_firme, v_movto_sbc, v_movto_rem;
		--END IF;
	END
END PROCEDURE
DOCUMENT
'Fecha: 17/06/2011',
'Modifico: Paul Ivan Quintero Varela',
'Observaciones: Se modifica para contemplar los pagos de préstamo personal',
'pago de anticipo y los pagos de reesturctura para obtener el total de',
'pagos de este proceso del totales de computador.';

CREATE PROCEDURE "informix".sp_gen_arch_auto_sinrecogertc_vencidas(pEmpresa CHAR(3))
RETURNING CHAR(5) AS CodigoRetorno, 
		  CHAR(80) AS Mensaje;	

DEFINE cod_ret     CHAR(5);
DEFINE sql_err     SMALLINT;
DEFINE vMen        CHAR(80);
DEFINE cErrorInfo  CHAR(80);
DEFINE iIsamErr    SMALLINT;
DEFINE  dtFechaHoy     	DATE;
DEFINE  cNomArchivo 	CHAR(50);
DEFINE  cSQL            CHAR(4000);
DEFINE  cSQLEncabezado		CHAR(300);
DEFINE  cSQLEncabezadofin	CHAR(300);
DEFINE  cRuta			CHAR(100);

LET cod_ret        = "00000";
LET sql_err        = 0;
LET vMen           = "El archivo Autorizas_sinrecogerTC_vencidas se generÃ³ correctamente";
LET cErrorInfo     = "";
LET iIsamErr       = 0;
LET dtFechaHoy  = DATE(1);
LET cNomArchivo = '';
LET cSQL        = '';
LET cSQLEncabezado	= '';
LET cSQLEncabezadofin = '';
LET cRuta       = '';

BEGIN
	
	ON EXCEPTION SET sql_err, iIsamErr, cErrorInfo
		IF sql_err != 0 THEN
			LET cod_ret = sql_err;
			LET vMen= 'Error al generar archivo de Autorizas_sinrecogerTC_vencidas ';
        RETURN cod_ret, vMen;	
		END IF;
END EXCEPTION;


--	SET DEBUG FILE TO "sp_genera_archivo_tdcexpiradas.out";
 --   TRACE ON; 
	
	SELECT fecha_hoy - 1 units month
	INTO dtFechaHoy
    FROM bdicred:"informix".sd_fechas
    WHERE empresa = '001';
	
	--let dtFechaHoy = mdy('02','05','2013'); --para pruebas
	LET cRuta = '/resplogifx/archivoscartera/';
	
	---Encabezado de archivo
	
	LET cSql = ' echo "Numero de solicitud;Fecha de solicitud;Fecha de vencimiento;Nombre; Linea de credito autorizada;Estado;Sucursal;Numero cliente;"'||' >'|| TRIM(cRuta)||'Autorizas_sinrecogerTC_vencidas_'||to_char(dtFechaHoy,'%m%Y')||'.txt';		
	SYSTEM cSql;
	--Generacion de archivo Autorizas_sinrecogerTC_vencidas	
			LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || SUBSTR(cRuta,1,LENGTH(cRuta)) ||'Autorizas_sinrecogerTC_vencidas.unl' || ' DELIMITER ' || ''';'''  ||
			' select a.num_solicitud,date(a.fecha_insert - 120 units day),a.fecha_insert,'||
			' TRIM(c.nombre1)||'||''' '''||'||TRIM(c.nombre2)||'||''' '''||'||TRIM(c.apell_paterno)||'||''' '''||'||TRIM(c.apell_materno),'||
			' b.monto_solicitado as Linea_de_credito_solicitada,e.nombre,b.sucursal,c.numcte'|| 
			' from bdisolic:ss_autorizacion a,'||
			' bdisolic:ss_solicitudes b,'||
			' bdinteg:si_cliente c,'||
			' bdinteg:si_direcciones_actual d,'||
			' bdinteg:si_estados e'||
			' where a.empresa = b.empresa'||
			' and c.empresa = b.empresa'||
			' and a.num_solicitud = b.num_solicitud'||
			' and b.numcte = c.numcte'||
			' and d.numcte = b.numcte'||
			' and b.num_producto =''6001'''||
			' and a.status_solicitud =''CN'''||
			' and a.causa_solicitud =''CV'''||
			' and d.tipo_dir = ''1'''||
			' and e.estado = d.estado'||
			' and e.pais = ''001'''||
			' and year (a.fecha_insert) = year('''||dtFechaHoy||''')'||
			' and month (a.fecha_insert) = month('''||dtFechaHoy||''');'||
			'" > '||TRIM(cRuta)||'Autorizas_sinrecogerTC_vencidas.sql';	
 
 
 		
			
            SYSTEM cSql;

            LET cSql = '';
            LET cSql = 'dbaccess bdicred '||TRIM(cRuta)||'Autorizas_sinrecogerTC_vencidas.sql';
            SYSTEM cSql;

            --Se une el encabezado con la informaciÃ³n.
			LET cSql = '';
			LET cSql= "sed 's/;$//g' " ||TRIM(cRuta)||"Autorizas_sinrecogerTC_vencidas.unl"||" >> "||TRIM(cRuta)||'Autorizas_sinrecogerTC_vencidas_'||to_char(dtFechaHoy,'%m%Y')||'.txt';
			SYSTEM cSql;
			
	
			LET cSql ='rm '|| TRIM(cruta)||'Autorizas_sinrecogerTC_vencidas.sql ' ||TRIM(cruta)||'Autorizas_sinrecogerTC_vencidas.unl';
			SYSTEM cSql; 


			LET vMen = 'El archivo Autorizas_sinrecogerTC_vencidas se generÃ³ correctamente';
			LET cod_ret = '00000';	
	
			RETURN cod_ret, vMen;

END;
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento generar archivo con informaciÃ³n de Tarjetas de crÃ©dito autorizadas, pero no han sido recogidas',
'AUTOR : Guadalupe de Jesus Espinoza Valenzuela ',
'FECHA : 01/Abril/2013',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_rep_estadisticas_tdc_latinia()

RETURNING 
          CHAR(06) AS resultado,
          CHAR(80) AS mensaje;
          
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);

DEFINE vnumcte			CHAR(20);
DEFINE vnum_credito		CHAR(20);
DEFINE vtelefono		CHAR(20);
DEFINE vtarjeta 		CHAR(20);
DEFINE vapellido_pat	CHAR(30);
DEFINE vfecha			DATE;
DEFINE dtFecha          DATE;
DEFINE vdia2 			SMALLINT;
DEFINE vdia7			SMALLINT;
DEFINE vdia14			SMALLINT;
DEFINE vdia15			SMALLINT;
DEFINE vdia21			SMALLINT;
DEFINE vdia28			SMALLINT;
define vtotal			integer;
define vtotal2			integer;
define vtotal1			integer;
DEFINE iTotalRegistros  integer;
define vregistros		integer;
define vproceso			char(4);
define vvalor			smallint;
define vcontador		integer;
define vfechas			char(6);
define vpri_dia_mes 	date;
define VlDescripcion    char(50); 
define vlValorAlfa      char(50); 
define vlValorAlfabetico char(50);
define  vlCDummy        integer;

LET vproceso	='2083';
LET iSqlErr    	= 0;
LET iIsamErr   	= 0;
LET cErrorInfo 	= "";
LET cCodRet   	= '000000';
LET cMensajeRet	= 'El proceso se realizÃ³ correctamente';

LET vnumcte			= "";
LET vnum_credito	= "";
LET vtelefono		= "";
LET vtarjeta 		= "";
LET vapellido_pat	= "";
LET vfecha			= DATE(0);  
LET dtFecha    		= DATE(0);  
let vtotal			= 0;
let vtotal1			= 0;
let vdia2 			= 0;
let vdia7			= 0;
let vdia14			= 0;
let vdia15			= 0;
let vdia21			= 0;
let vdia28			= 0;
LET iTotalRegistros = 0;
let vregistros		=0;
let vvalor 			= 0;
let vcontador 		= 0;
let vfechas			 = '';
let vpri_dia_mes	= DATE(0); 
let VlDescripcion   = '';
let vlValorAlfabetico = '';
let vlCDummy = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= 'ERROR en la ejecuciÃ³n';
	 CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensajeRet, '02')RETURNING cCodRet;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensajeRet, '01')RETURNING cCodRet;
    
--SET DEBUG FILE TO "/informix/gpe/Pruebas_de_carta_por_prioridad/sp_rep_estadisticas_tdc_latinia.out";
--TRACE ON;

	SELECT a.fecha_hoy, a.pri_dia_mes
		INTO dtFecha ,vpri_dia_mes
	FROM bdicred:sd_fechas a
	WHERE a.empresa = '001';
--let dtFecha = '04-05-2014';----------------------------------------pruebas
	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;

  	select valor_numerico into vregistros
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 57;
	--Dia nuevos
	select valor_numerico into vdia2
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 70;
	
	select valor_numerico into vdia7
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 64;
	select valor_numerico into vdia14
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 65;
	select valor_numerico into vdia15
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 66;
	--RQM 10 637 20150917 AAME Se agregan 2 parametros nuevos de fecha de envÃ­o
	select valor_numerico into vdia21
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 68;
	select valor_numerico into vdia28
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 69;
	
		
	select count(*) into vtotal
	from bdimnsj:mnsjr_trx_batch 
	where id_mensaje = 'AUT_SINREC' 
	 and to_char(fecha_hora_registro,'%m%Y') = to_char(vpri_dia_mes,'%m%Y') ;
	
	select count(*) into vtotal2
	from bdimnsj:mnsjr_trx_batch_his 
	where id_mensaje = 'AUT_SINREC' 
	  and to_char(fecha_hora_registro,'%m%Y') = to_char(vpri_dia_mes,'%m%Y');
	
	let vtotal = nvl(vtotal,0) + nvl(vtotal2,0);
	if (vtotal < vregistros) then
		LET vtotal1 = vregistros - vtotal;
	end if;
	if (day(dtFecha) = 1 ) then 
		let vtotal1 = vregistros; --delete from bdicobranza:cb_administativa_latinia where num_campania = 1;
	end if;
	select valor into vvalor from bdisolic:ss_param where secuencia = '21';

if (vtotal1  >= 1) then
FOREACH
  
	SELECT /* limit vtotal1 */sol.numcte,/*SUBSTR(tel2.telefono,(LENGTH(tel2.telefono) + 1 - 10),10),*/ --SUBSTR(cte.nombre1,1,10) --cte.nombre1
		CASE WHEN LENGTH(cte.nombre1) <=  3 THEN TRIM(cte.nombre1)||' '||TRIM(SUBSTR(cte.nombre2,1,9 - LENGTH(cte.nombre1))) ELSE
																					SUBSTR(cte.nombre1,1,10) END nombre
			,sol.num_solicitud
		INTO vnumcte, /*vtelefono, */ vapellido_pat,vnum_credito
	FROM bdisolic:ss_solicitudes sol
	JOIN bdinteg:si_cliente cte ON cte.empresa = sol.empresa AND cte.numcte = sol.numcte
	JOIN bdisolic:ss_autorizacion aut ON aut.empresa= sol.empresa and aut.num_solicitud = sol.num_solicitud AND aut.status_solicitud = sol.status_solicitud
		AND (aut.fecha_entrada = date(dtFecha) - vdia2 units day or aut.fecha_entrada = date(dtFecha) - vdia7 units day or aut.fecha_entrada = date(dtFecha) - vdia14 units day or aut.fecha_entrada = date(dtFecha) - vdia21 units day or aut.fecha_entrada = date(dtFecha) - vdia28 units day) 
		AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
                                    FROM bdisolic:"informix".ss_autorizacion aut_aux
                                    WHERE aut_aux.empresa= sol.empresa
                                    AND aut_aux.num_solicitud= sol.num_solicitud
                                    AND aut_aux.status_solicitud= sol.status_solicitud)
	/*join bdinteg:si_telefonos_actual tel2 on (tel2.empresa = sol.empresa and tel2.numcte= sol.numcte and tel2.tipo_tel = 2 and tel2.cofetel ='V' and tel2.status_tel = 'A'
							and tel2.telefono is not null and tel2.telefono <> ''
                            and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = sol.numcte and tipo_tel = 2 and cofetel ='V' and status_tel = 'A'))
	*/WHERE sol.empresa = '001' 
		AND sol.num_solicitud = sol.num_solicitud 
		AND sol.status_solicitud = 'AT'
		and sol.tipo_solicitud = 'T'
	order by sol.monto_autorizado desc
	
	select limit 1 SUBSTR(tel2.telefono,(LENGTH(tel2.telefono) + 1 - 10),10) into vtelefono
	from bdinteg:si_telefonos_actual tel2 
	where tel2.empresa = '001' 
	and tel2.numcte = vnumcte
	and tel2.tipo_tel = 2 and tel2.cofetel ='V' and tel2.status_tel = 'A'
	and tel2.telefono is not null and tel2.telefono <> ''
    and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                        where numcte = vnumcte and tipo_tel = 2 and cofetel ='V' and status_tel = 'A');
	
	if 	(vtelefono is not null and vtelefono <> '') then
	
		let vfecha = date(dtFecha) + vdia15 units day;
		let vfechas = lpad(day(vfecha),2,'0')||'-'|| decode (month(vfecha),01,'Ene',02,'Feb',03,'Mar',04,'Abr',05,'May',06,'Jun',
																   07,'Jul',08,'Ago',09,'Sep',10,'Oct',11,'Nov',12,'Dic');
   
		/*insert into bdicobranza:cb_administativa_latinia(num_campania,numcte,num_credito,telefono,tarjeta ,apellido_pat,fecha,fecha_insert)
		values (1,vnumcte,vnum_credito, vtelefono, '', vapellido_pat, vfecha,today);*/
		call bdimnsj:"informix".sp_registra_evento (2, 'AUT_SINREC' , vnumcte, vnum_credito,'', 2,
							vapellido_pat,vfechas,'','','',0,0,0,0,0, '', '')RETURNING cCodRet;
		let vcontador = vcontador + 1 ;
	end if;
	if (vcontador = vtotal1) then	exit FOREACH; end if;
 End ForEach;
end if;	
  if (day(dtFecha) <= 8 ) then
  
  FOREACH  
    select descripcion,  trim(valor_alfabetico)
      into VlDescripcion, vlValorAlfabetico
      from bdicred:sd_param_campania 
     where tipo_campania = 60  AND GRUPO_PARAMETRO = 'TELSMSFIJO'
	 and num_parametro in (1,2,3)
	 
	 select  count(*) into vlCDummy   
      from bdimnsj:"informix".mnsjr_trx_batch 
     where tipo_mensaje = 2  
      and to_char(fecha_hora_registro,'%m%Y') = to_char( dtFecha,'%m%Y' )
      and id_mensaje  ='AUT_SINREC'
	  and cuenta = vlValorAlfabetico;
      
      if vlCDummy > 0 then continue foreach; end if; 
	 
	 select numcte,num_credito
	  into vnumcte,vnum_credito
	  from bdicred:sd_maecred
	 where num_credito =vlValorAlfabetico;  --in ('600109267697','600030001041','600109267432')
	 

	 
	 select CASE WHEN LENGTH(a.nombre1) <=  3 THEN TRIM(a.nombre1)||' '||TRIM(SUBSTR(a.nombre2,1,9 - LENGTH(a.nombre1))) ELSE
																					SUBSTR(a.nombre1,1,10) END nombre into vapellido_pat
    from bdinteg:si_cliente a where numcte = vnumcte;
	 
	   call bdimnsj:"informix".sp_registra_evento (2, 'AUT_SINREC' , vnumcte, vnum_credito,'', 2,
							vapellido_pat,vfechas,'','','',0,0,0,0,0,'','')RETURNING cCodRet;

  END FOREACH;
	end if;

	/*if (vcontador  >= 1) then 
	CALL bdicobranza:"informix".sp_sms_reporte(1,0,0,0) RETURNING 	cCodRet;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, 'Reporte sms', '02')RETURNING cCodRet;
	end if;*/
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensajeRet, '03')RETURNING cCodRet;
	RETURN cCodRet,cMensajeRet;

END
END PROCEDURE;