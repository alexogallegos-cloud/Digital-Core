CREATE PROCEDURE "informix".sp_reporte_evaluacion_objetiva(pPeriodicidad char(1), pFechaIni date, pFechaFin date)
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		  CHAR(80) AS Nombre_archivo,
		  CHAR(80) AS Nombre_archivo2;  		  

-- Definicion Generacion Archivo
DEFINE cNombreArchivo	CHAR(80);
DEFINE cNombreArchivo2	CHAR(80);
DEFINE cNombreArchivo3	CHAR(80);
DEFINE cNombreArchivo4	CHAR(80);
DEFINE cNombreArchivo5	CHAR(80);
DEFINE cNombreArchivo6	CHAR(80);
DEFINE cNombreArchivo_temp	CHAR(80);
DEFINE cTipoArchivo	    CHAR(80);
DEFINE cRuta		    CHAR(80);
DEFINE dtFecha_hoy      DATE;
DEFINE cSql		 		CHAR(3500);
DEFINE cSql2	 		CHAR(4000);
DEFINE cSql3	 		CHAR(500);

DEFINE cCodRet        	CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cErrorInfo       CHAR(80);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;

DEFINE cProceso         CHAR(4);
DEFINE cMensajeFin      CHAR(100);
DEFINE vvcCod_ret       CHAR(6);


-- Definiciones Evaluacion Objetiva
DEFINE pEmpresa				CHAR(3);
DEFINE cSucursal        	CHAR(4);
DEFINE cSucursalPago    	CHAR(4);
DEFINE cSucursalConv    	CHAR(4);
DEFINE dFechaCompac			DATE;
DEFINE cCajero				CHAR(8);
DEFINE cNomCajero			CHAR(45);
DEFINE cNumcuenta       	CHAR(20); 
DEFINE cProducto			CHAR(4);
DEFINE cOrigen      		CHAR(10);
DEFINE iTipoCompac  		INTEGER;
DEFINE iPlazo       		INTEGER;
DEFINE dImporte     		DECIMAL(14,2);
DEFINE dImpPagado   		DECIMAL(14,2);
DEFINE dConvenioMonto		DECIMAL(14,2);
DEFINE dConvenioAbono		DECIMAL(14,2);
DEFINE iCteVencido  		INTEGER;
DEFINE iNumConvenios  		INTEGER;
DEFINE iNumPMRealizados 	INTEGER;
DEFINE iNumPMNoRealizados 	INTEGER;
DEFINE cCalificacion		CHAR(11);

DEFINE iSucursalConvSuc 	INTEGER;
DEFINE cOrigenSuc			CHAR(10);
DEFINE iTipoCompacSuc  		INTEGER;
DEFINE iPlazoSuc       		INTEGER;
DEFINE dConvenioMontoSuc	DECIMAL(14,2);
DEFINE dConvenioAbonoSuc	DECIMAL(14,2);
DEFINE iCteVencidoSuc		INTEGER;
DEFINE iNumConveniosSuc  	INTEGER;


DEFINE cPagoProgramado  CHAR(1);
DEFINE iNumSesion       INTEGER;

DEFINE cValor           char(1);
DEFINE vFechaMov        DATE;

DEFINE v_count_emp      CHAR(10);
DEFINE cImporte         CHAR(20);
DEFINE cImpPagado       CHAR(20);
DEFINE cFechaCompac     CHAR(20);
DEFINE cFechaIns        CHAR(20);
DEFINE cPagoProgramado_2 CHAR(45);
DEFINE cUsuario         CHAR(8);
DEFINE dt_pri_dia_mes   DATE;
DEFINE dt_ult_dia_mes   DATE;
DEFINE c_Periodicidad   CHAR(1);
DEFINE dFechaini        DATE;
DEFINE dFechafin        DATE;
DEFINE cExtArchivo      CHAR(4);
DEFINE cArch_encabezado_3 CHAR(25);
DEFINE cArch_encabezado_4 CHAR(25);
DEFINE dtFecha_dia_ant  DATE;

-- Definicion Generacion Archivo
LET cNombreArchivo		= "Reporte_PagoMin_Cajero_Nuevo_tdc_";
LET cNombreArchivo2		= "Reporte_PagoMin_Suc_Nuevo_tdc_";

LET cNombreArchivo3		= "Reporte_PagoMin_Cajero_Nuevo_crd_";
LET cNombreArchivo4		= "Reporte_PagoMin_Suc_Nuevo_crd_";

LET cNombreArchivo5		= "Reporte_PagoMin_Cajero_Nuevo_";
LET cNombreArchivo6		= "Reporte_PagoMin_Suc_Nuevo_";

let cNombreArchivo_temp = '';
LET cExtArchivo         = '.txt';
LET cTipoArchivo 		= 'txt';
LET cRuta				= '';
LET dtFecha_hoy			= DATE(1);

LET cSql				= '';
LET cSql2				= '';
LET cSql3               = '';
LET cCodRet             = "000000";
LET cMensajeRet         = "PROCESO EXITOSO";
LET cErrorInfo          = "";
LET iSqlErr             = 0;
LET iIsamErr            = 0;

LET cProceso            = '2078';
LET cMensajeFin         = 'PROCESO TERMINADO EXITOSAMENTE';
LET vvcCod_ret          = '';

 
-- Inicializacion Evaluacion Objetiva
LET pEmpresa			= '001';
LET cSucursal           = '';
LET cSucursalPago       = '';
LET cSucursalConv       = '';
LET dFechaCompac        = DATE(1);
LET cCajero				= '';
LET cNomCajero			= '';
LET cNumcuenta          = '';
LET cProducto			= '';
LET cOrigen             = '';
LET iTipoCompac         = 0;
LET iPlazo              = 0;
LET dImporte            = 0;
LET dImpPagado          = 0;
LET dConvenioMonto		= 0;
LET dConvenioAbono		= 0;
LET iCteVencido  		= 0;
LET iNumConvenios  		= 0;
LET iNumPMRealizados 	= 0;
LET iNumPMNoRealizados 	= 0;
LET cCalificacion		= '';

LET iSucursalConvSuc	= 0;
LET cOrigenSuc			= '';
LET iTipoCompacSuc      = 0;
LET iPlazoSuc           = 0;
LET dConvenioMontoSuc	= 0;
LET dConvenioAbonoSuc	= 0;
LET iCteVencidoSuc 		= 0;
LET iNumConveniosSuc	= 0;



LET cPagoProgramado     = '';
LET iNumSesion          = 0;

LET cValor              = '';
LET vFechaMov           = DATE(1);
LET v_count_emp         = '';
LET cImporte            = '';
LET cImpPagado          = '';
LET cFechaCompac        = '';
LET cFechaIns           = '';
LET cPagoProgramado_2   = '';
LET cUsuario            = '';

LET dFechaini           = DATE(1);
LET dFechafin           = DATE(1);
LET dt_pri_dia_mes      = DATE(1);
LET dt_ult_dia_mes      = DATE(1);
LET c_Periodicidad      = pPeriodicidad;
LET cArch_encabezado_3  = 'encabezado_pmsv_caj.txt';
LET cArch_encabezado_4  = 'encabezado_pmsv_suc.txt';
LET dtFecha_dia_ant     = DATE(1);

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		LET cCodRet= iSqlErr;
		LET cMensajeRet = cErrorInfo;
		
	  RETURN cCodRet, cMensajeRet,"","";
	END EXCEPTION;

	--SET DEBUG FILE TO '/ifxsif01/macf/sp_reporte_evaluacion_objetiva.trc';
	--TRACE ON;
  
	--CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeFin, '01') RETURNING vvcCod_ret;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
 	
	IF  (pFechaIni <> '' and  pFechaFin <> '') and (c_Periodicidad = '' or c_Periodicidad = 'P') then
	   LET dFechaini = pFechaIni;
	   LET dFechafin = pFechaFin;
	   LET dtFecha_dia_ant = today-1;
	ELSE

		SELECT fecha_hoy, pri_dia_mes, ult_dia_mes 
		  INTO dtFecha_hoy, dt_pri_dia_mes, dt_ult_dia_mes
		  FROM bdinteg:si_fechas
		 WHERE empresa = pEmpresa;

		--LET dtFecha_hoy = MDY(9,1,2019);  -- SOLO TEST 
		--let dt_pri_dia_mes = MDY(9,1,2019);  -- SOLO TEST 
		
		IF c_Periodicidad = 'D' then

		   --LET dFechaini = dt_pri_dia_mes;
		   --LET dFechaini = dtFecha_hoy -1 units day;
		   --LET dFechafin = dtFecha_hoy -1 units day; 
		   --LET dFechafin = dt_ult_dia_mes;
		   
		   if day(dtFecha_hoy) = 1 then
              let dFechafin = date(dt_pri_dia_mes -1 units day);
              let dFechaini = month(dFechafin)||'/01/'||year(dFechafin);
		   else
              let dFechaini = dt_pri_dia_mes;
              let dFechafin = dt_ult_dia_mes;
		   end if;
		   
		   LET dtFecha_dia_ant = today-1;
		   
		elif c_Periodicidad = 'S' then
		   LET dFechaini = dtFecha_hoy - 7 units day;
		   LET dFechafin = dtFecha_hoy - 1 units day;
		elif c_Periodicidad = 'M' then
		   LET dFechafin = dt_pri_dia_mes - 1 units day;
		   LET dFechaini = LPAD(TRIM(MONTH(dFechafin)::CHAR(2)),2,'0') ||'/01/'|| YEAR(dtFecha_hoy);
		end if;
	
	END IF;
	
	--LET dFechaini = MDY(8,14,2019);  -- SOLO TEST 
	--LET dFechafin = MDY(8,14,2019); -- SOLO TEST 
	
	
	SELECT TRIM(valor_alfabetico) INTO cRuta
	  FROM bdicobranza:cb_param_campania
	 WHERE tipo_campania = 11  
	   AND grupo_parametro = 'RUTAS'
	   AND num_parametro =1;
	
	--LET cRuta = "/ifxsif01/macf/";   -- SOLO TEST
	
	
	LET cNombreArchivo= TRIM(cNombreArchivo)|| LPAD(TRIM(DAY(dtFecha_dia_ant)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_dia_ant)::CHAR(2)),2,'0') || substr(YEAR(dtFecha_dia_ant),3,2);
  
    --LET cSql = 'echo "sucursal|fecha_insert|empleado_captura|nombre_efectuo|origen|tipo_compac|plazo|num_credito|num_producto|cte_con_vencido|num_convenios|pct_ctes_convenios|convenio_miles|abono_miles|pct_rec_convenio|calificacion|" > '|| TRIM(cRuta) || trim(cArch_encabezado);
	--SYSTEM trim(cSql);
	
	LET cSql3 = 'echo "sucursal_origen|fecha_insert|cajero|nom_cajero|num_credito|num_producto|monto_pago_minimo|monto_recup_pm|pct_cumplimiento_pm|num_pago_completo_pm|' 
	           --|| 'num_pago_parcial_pm|pct_cump_num_pm|monto_saldo_vencido|monto_recup_sv|pct_cumplim_sv|num_pago_completo_sv|num_pago_parcial_sv|'
			   || 'num_pago_parcial_pm|monto_saldo_vencido|monto_recup_sv|pct_cumplim_sv|num_pago_completo_sv|num_pago_parcial_sv|'
			   --|| 'pct_cump_nums_sv|pct_rec_cartera" > '|| TRIM(cRuta) || trim(cArch_encabezado_3);
			   || 'pct_rec_cartera" > '|| TRIM(cRuta) || trim(cArch_encabezado_3);
	SYSTEM trim(cSql3);
	
	let cNombreArchivo_temp = 'Reporte_PagoMin_Cajero_Nuevo_tdc_temp';

	LET cSql3 = '';
	--------------------------------------- Reporte de Pago Minimo y Saldo vencido         CAJERO   TDC  
	--LET cSql = 'echo "UNLOAD TO '''||trim(cNombreArchivo)||'.'||trim(cTipoArchivo) || ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query1.sql';
	
	LET cSql3 = 'echo " SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '''|| TRIM(cRuta) || trim(cNombreArchivo_temp)|| cExtArchivo || ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query1.sql';
	SYSTEM trim(cSql3);
	LET cSql3 = '';
	
	LET cSql = '';
		
	--LET cSql = 'echo "SELECT sucursal_origen, fecha_insert, cajero, nom_cajero, num_producto,' 
	--LET cSql = 'echo "SELECT cajero, nom_cajero, fecha_insert, num_producto, sucursal_origen,'
	LET cSql = 'echo "SELECT a.sucursal_origen, to_char(a.fecha_insert, ''' || '%d/%m/%Y' || '''), a.cajero, a.nom_cajero, a.num_credito, a.num_producto, '
		   ||   'round(sum(a.monto_pago_minimo),2) MONTO_PAGO_MINIMO, '
		   ||   'round(sum(a.monto_recup_pm),2) MONTO_RECUP_PM, ' 
           ||   'case when sum(a.monto_recup_pm) <= 0 then 0 '
           ||   ' else ( case when round( (sum(a.monto_recup_pm)/sum(a.monto_pago_minimo))*100,2) > 100 then 100 ' 
           ||   ' else round( (sum(a.monto_recup_pm)/sum(a.monto_pago_minimo))*100,2) end) end PCT_CUMPLIMIENTO_PM,'
		   --||   'round(sum(pct_cump_pm),2) PCT_CUMPLIMIENTO_PM, '
           ||   'round(sum(a.num_pm_realizados),2) NUM_PM_REALIZADOS, round(sum(a.num_pm_no_realizados),2) NUM_PM_NO_REALIZADOS, ' 
           ||   'round(sum(a.monto_saldo_vencido),2) MONTO_SALDO_VENCIDO, round(sum(a.monto_recup_sv),2) MONTO_RECUP_SV, '
           ||   'case when sum(a.monto_saldo_vencido) <= 0 then 0 '
           ||   ' else (case when round( (sum(a.monto_recup_sv)/sum(a.monto_saldo_vencido) )*100, 2) > 100 then 100 '
           ||   '  else round( (sum(a.monto_recup_sv)/sum(a.monto_saldo_vencido))*100, 2) end) end PCT_CUMPLIM_SV,'
		   --||   'round(sum(pct_cump_sv),2) PCT_CUMPLIM_SV, '
	       ||   'round(sum(a.num_sv_realizados),2) NUM_SV_REALIZADOS, round(sum(a.num_sv_no_realizados),2) NUM_SV_NO_REALIZADOS,' 
		   ||   'case when (nvl(sum(a.pct_cump_pm),0) + nvl(sum(a.pct_cump_sv),0)) / 2 >100 then 100 '
		   ||   ' else (nvl(sum(a.pct_cump_pm),0) + nvl(sum(a.pct_cump_sv),0)) / 2 end PCT_REC_CARTERA '
           || 'FROM BDICOBRANZA:CB_EVALUACION_OBJETIVA_NUEVA a, BDINTEG:si_ejecut b, BDINTEG:si_sucursales c '
           || 'WHERE a.fecha_insert between ' || "'" || dFechaini || "'" || ' and ' || "'" || dFechafin || "' "
           || ' AND a.cajero = b.ejecutivo AND b.sucursal = c.sucursal and c.tipo = ''' || 'S' || "'"
           --|| ' AND a.cajero = b.ejecutivo AND b.ejecutivo like ''' || '9%' || "'" 
           || ' GROUP BY 1,2,3,4,5,6;' || '" >> ' || trim(cRuta)|| 'query1.sql';
	
	       --insert into "informix".cb_temp_evalobj(cadena) values(cSql);  -- SOLO TEST
	
	SYSTEM trim(cSql);
	LET cSql = ''; 
	
	LET cSql3 = 'dbaccess bdicobranza ' ||trim(cRuta)|| 'query1.sql'; 
	SYSTEM trim(cSql3);
	LET cSql3 = '';
	
	-- BORRADO DE TEMPORALES USADOS PARA CREAR ARCHIVO
	--LET cSql3 = "rm " ||trim(cRuta)||'query1.sql';   --- COMENTADO SOLO TEST
	--SYSTEM trim(cSql3); 
	--LET cSql3  = '';

	--LET cNombreArchivo  = trim(cNombreArchivo)|| cExtArchivo;
    
    LET cSql3 = '';
	
	LET cSql3 = 'cat ' || trim(cRuta) || trim(cArch_encabezado_3) || ' ' || trim(cRuta) || trim(cNombreArchivo_temp) || trim(cExtArchivo) || '>' ||trim(cRuta) || trim(cNombreArchivo) || cExtArchivo; 
	SYSTEM trim(cSql3);
	LET cSql3 = '';
	
    LET cSql3 = "gzip -f " ||trim(cRuta)|| trim(cNombreArchivo) || cExtArchivo;  --- COMENTADO SOLO TEST
    SYSTEM trim(cSql3);
      LET cNombreArchivo  = trim(cNombreArchivo)||'.gz';
	LET cSql3 = '';
	
	LET cSql3 = "rm " || trim(cRuta)|| trim(cNombreArchivo_temp) || trim(cExtArchivo);
    SYSTEM trim(cSql3);
	LET cSql3 = '';
	
	---------------------------------------------------------------- PM-SV  CAJERO   TDC

	-------------------------------------------------------------------- PM CAJERO NUEVO CRD  INI
	LET cNombreArchivo3= TRIM(cNombreArchivo3)|| LPAD(TRIM(DAY(dtFecha_dia_ant)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_dia_ant)::CHAR(2)),2,'0') || substr(YEAR(dtFecha_dia_ant),3,2);
	LET cSql3 = '';
	
	let cNombreArchivo_temp = 'Reporte_PagoMin_Cajero_Nuevo_crd_temp';
	
	-- Reporte de Pago Minimo y Saldo vencido por Cajero CRD
	--LET cSql = 'echo "UNLOAD TO '''||trim(cNombreArchivo)||'.'||trim(cTipoArchivo) || ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query2.sql';
	
	LET cSql3 = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '''|| TRIM(cRuta) || trim(cNombreArchivo_temp)|| cExtArchivo || ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query2.sql';
	SYSTEM trim(cSql3);
	LET cSql3 = '';
	
	LET cSql = '';
	LET cSql = 'echo "SELECT a.sucursal_origen, to_char(a.fecha_insert, ''' || '%d/%m/%Y' || '''), a.cajero, a.nom_cajero, a.num_credito, a.num_producto, '
		   ||   'round(sum(a.monto_pago_minimo),2) MONTO_PAGO_MINIMO, '
		   ||   'round(sum(a.monto_recup_pm),2) MONTO_RECUP_PM, ' 
           ||   'case when sum(a.monto_recup_pm) <= 0 then 0 '
           ||   ' else ( case when round( (sum(a.monto_recup_pm)/sum(a.monto_pago_minimo))*100,2) > 100 then 100 ' 
           ||   ' else round( (sum(a.monto_recup_pm)/sum(a.monto_pago_minimo))*100,2) end) end PCT_CUMPLIMIENTO_PM,'
		   --||   'round(sum(pct_cump_pm),2) PCT_CUMPLIMIENTO_PM, '
           ||   'round(sum(a.num_pm_realizados),2) NUM_PM_REALIZADOS, round(sum(a.num_pm_no_realizados),2) NUM_PM_NO_REALIZADOS, ' 
           ||   'round(sum(a.monto_saldo_vencido),2) MONTO_SALDO_VENCIDO, round(sum(a.monto_recup_sv),2) MONTO_RECUP_SV, '
           ||   'case when sum(a.monto_saldo_vencido) <= 0 then 0 '
           ||   ' else (case when round( (sum(a.monto_recup_sv)/sum(a.monto_saldo_vencido))*100, 2) > 100 then 100 '
           ||   '  else round( (sum(a.monto_recup_sv)/sum(a.monto_saldo_vencido))*100, 2) end) end PCT_CUMPLIM_SV,'
		   --||   'round(sum(pct_cump_sv),2) PCT_CUMPLIM_SV, '
	       ||   'round(sum(a.num_sv_realizados),2) NUM_SV_REALIZADOS, round(sum(a.num_sv_no_realizados),2) NUM_SV_NO_REALIZADOS,' 
		   ||   'case when (nvl(sum(a.pct_cump_pm),0) + nvl(sum(a.pct_cump_sv),0)) / 2 >100 then 100 '
		   ||   ' else (nvl(sum(a.pct_cump_pm),0) + nvl(sum(a.pct_cump_sv),0)) / 2 end PCT_REC_CARTERA '
           ||  'FROM BDICOBRANZA:CB_EVALUACION_OBJETIVA_CRD a, BDINTEG:SI_EJECUT b, BDINTEG:SI_SUCURSALES c '
           || 'WHERE a.fecha_insert between ' || "'" || dFechaini || "'" || ' and ' || "'" || dFechafin || "' "
		   || ' AND a.cajero = b.ejecutivo AND b.sucursal = c.sucursal and c.tipo = ''' || 'S' || "'" 
           || ' GROUP BY 1,2,3,4,5,6;' || '" >> ' || trim(cRuta)|| 'query2.sql';
          
	
	SYSTEM trim(cSql);
    LET cSql = ''; 
	
	LET cSql3 = '';
	LET cSql3 = 'dbaccess bdicobranza ' ||trim(cRuta)|| 'query2.sql'; 
	SYSTEM trim(cSql3);
	
	-- BORRADO DE TEMPORALES USADOS PARA CREAR ARCHIVO
	--LET cSql3 = "rm " ||trim(cRuta)||'query2.sql';   -- COMENTADO SOLO TEST
	--SYSTEM trim(cSql3); 
	LET cSql3  = '';

	--LET cNombreArchivo3  = trim(cNombreArchivo3)|| cExtArchivo;
    
	LET cSql3 = 'cat ' || trim(cRuta) || trim(cArch_encabezado_3) || ' ' || trim(cRuta) || trim(cNombreArchivo_temp) || trim(cExtArchivo) || '>' ||trim(cRuta) || trim(cNombreArchivo3) || cExtArchivo; 
	SYSTEM trim(cSql3);
	LET cSql3  = '';
	
    LET cSql = '';
    LET cSQL = "gzip -f " ||trim(cRuta)|| trim(cNombreArchivo3) || cExtArchivo;  -- COMENTADO SOLO TEST
    SYSTEM trim(cSql);
    LET cNombreArchivo  = trim(cNombreArchivo)||'.gz';
	
	LET cSql3 = "rm " || trim(cRuta)|| trim(cNombreArchivo_temp) || trim(cExtArchivo);
    SYSTEM trim(cSql3);
	LET cSql3 = '';
	
	------------------------------------------------------------------- PM CAJERO NUEVO CRD  FIN
	


	--------------------------------------------------------------------- PM Sucursal TDC  INI

	LET cSql3 = 'echo "sucursal_origen|fecha_insert|monto_pago_minimo|monto_recup_pm|pct_cumplimiento_pm|num_pago_completo_pm|' 
	           --|| 'num_pago_parcial_pm|pct_cump_num_pm|monto_saldo_vencido|monto_recup_sv|pct_cumplim_sv|num_pago_completo_sv|num_pago_parcial_sv|'
			   || 'num_pago_parcial_pm|monto_saldo_vencido|monto_recup_sv|pct_cumplim_sv|num_pago_completo_sv|num_pago_parcial_sv|'
			   --|| 'pct_cump_nums_sv|pct_rec_cartera" > '|| TRIM(cRuta) || trim(cArch_encabezado_4);
			   || 'pct_rec_cartera" > '|| TRIM(cRuta) || trim(cArch_encabezado_4);
	SYSTEM trim(cSql3);		   
	LET cSql3  = '';
	
	let cNombreArchivo_temp = 'Reporte_PagoMin_Suc_Nuevo_tdc_temp';
	
	LET cNombreArchivo2 = TRIM(cNombreArchivo2)|| LPAD(TRIM(DAY(dtFecha_dia_ant)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_dia_ant)::CHAR(2)),2,'0') || substr(YEAR(dtFecha_dia_ant),3,2);
	--LET cSql2 = 'echo "UNLOAD TO '''||trim(cNombreArchivo2)||'.'||trim(cTipoArchivo) || ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query3.sql';
	
	LET cSql3 = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '''|| trim(cRuta) || trim(cNombreArchivo_temp)|| cExtArchivo || ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query3.sql';
	SYSTEM trim(cSql3);
	LET cSql3  = '';
	
	LET cSql2 = ''; 
	LET cSql2 = 'echo "SELECT a.sucursal_origen, to_char(a.fecha_insert, ''' || '%d/%m/%Y' || '''), '
		   ||   'round(sum(a.monto_pago_minimo),2) MONTO_PAGO_MINIMO, '
		   ||   'round(sum(a.monto_recup_pm),2) MONTO_RECUP_PM, ' 
           ||   'case when sum(a.monto_recup_pm) <= 0 then 0 '
           ||   ' else ( case when round( (sum(a.monto_recup_pm)/sum(a.monto_pago_minimo))*100,2) > 100 then 100 ' 
           ||   ' else round( (sum(a.monto_recup_pm)/sum(a.monto_pago_minimo))*100,2) end) end PCT_CUMPLIMIENTO_PM,'
		   --||   'round(sum(pct_cump_pm),2) PCT_CUMPLIMIENTO_PM, '
           ||   'round(sum(a.num_pm_realizados),2) NUM_PM_REALIZADOS, round(sum(a.num_pm_no_realizados),2) NUM_PM_NO_REALIZADOS, ' 
           ||   'round(sum(a.monto_saldo_vencido),2) MONTO_SALDO_VENCIDO, round(sum(a.monto_recup_sv),2) MONTO_RECUP_SV, '
           ||   'case when sum(a.monto_saldo_vencido) <= 0 then 0 '
           ||   ' else (case when round( (sum(a.monto_recup_sv)/sum(a.monto_saldo_vencido))*100, 2) > 100 then 100 '
           ||   '  else round( (sum(a.monto_recup_sv)/sum(a.monto_saldo_vencido))*100, 2) end) end PCT_CUMPLIM_SV,'
		   --||   'round(sum(pct_cump_sv),2) PCT_CUMPLIM_SV, '
	       ||   'round(sum(a.num_sv_realizados),2) NUM_SV_REALIZADOS, round(sum(a.num_sv_no_realizados),2) NUM_SV_NO_REALIZADOS,' 
		   ||   'case when (nvl(sum(a.pct_cump_pm),0) + nvl(sum(a.pct_cump_sv),0)) / 2 >100 then 100 '
		   ||   ' else (nvl(sum(a.pct_cump_pm),0) + nvl(sum(a.pct_cump_sv),0)) / 2 end PCT_REC_CARTERA '
           ||  'FROM BDICOBRANZA:CB_EVALUACION_OBJETIVA_NUEVA a, BDINTEG:SI_EJECUT b, BDINTEG:SI_SUCURSALES c '
           || 'WHERE a.fecha_insert between ' || "'" || dFechaini || "'" || ' and ' || "'" || dFechafin || "' "
		   ||  ' AND a.cajero = b.ejecutivo AND b.sucursal = c.sucursal and c.tipo = ''' || 'S' || "'"
		   || ' GROUP BY 1,2;' || '" >> ' || trim(cRuta)|| 'query3.sql';
	
	   
	
	SYSTEM trim(cSql2); 
	LET cSql2 = '';
	
	LET cSql3 = "dbaccess bdicobranza "||trim(cRuta)|| 'query3.sql'; 
	SYSTEM trim(cSql3);
    LET cSql3  = '';

	-- BORRADO DE TEMPORALES USADOS PARA CREAR ARCHIVO
	--LET cSql3 = "rm " ||trim(cRuta)||'query3.sql';  --COMENTADO SOLO TEST
	--SYSTEM trim(cSql3);
	LET cSql3 = '';

	--LET cNombreArchivo2 = trim(cNombreArchivo2)|| cExtArchivo;
    LET cSql3 = 'cat ' || trim(cRuta) || trim(cArch_encabezado_4) || ' ' || trim(cRuta) || trim(cNombreArchivo_temp) || trim(cExtArchivo) || '>' ||trim(cRuta) || trim(cNombreArchivo2) || cExtArchivo; 
	SYSTEM trim(cSql3);
	LET cSql3  = '';
		
    LET cSql3 = "gzip -f " ||trim(cRuta)|| trim(cNombreArchivo2)|| cExtArchivo;    --COMENTADO SOLO TEST
    SYSTEM trim(cSql3);
	LET cNombreArchivo2 = trim(cNombreArchivo2)||'.gz';
	LET cSql3 = '';
    
	LET cSql3 = "rm " || trim(cRuta)|| trim(cNombreArchivo_temp) || trim(cExtArchivo);
    SYSTEM trim(cSql3);
	LET cSql3 = '';
	--------------------------------------------------------------------- PM Sucursal TDC  FIN
	
	
	---------------------------------------------------------------------  PM SUCURSAL CRD INI

   let cNombreArchivo_temp = 'Reporte_PagoMin_Suc_Nuevo_crd_';
	
   LET cNombreArchivo4 = TRIM(cNombreArchivo4)|| LPAD(TRIM(DAY(dtFecha_dia_ant)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_dia_ant)::CHAR(2)),2,'0') || substr(YEAR(dtFecha_dia_ant),3,2);
	--LET cSql2 = 'echo "UNLOAD TO '''||trim(cNombreArchivo2)||'.'||trim(cTipoArchivo) || ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query4.sql';

	LET cSql3 = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '''|| trim(cRuta) || trim(cNombreArchivo_temp)|| cExtArchivo || ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query4.sql';
	SYSTEM trim(cSql3);

	LET cSql2 = ''; 
	--LET cSql2 = 'echo "SELECT sucursal_origen, fecha_insert,'
	--LET cSql2 = 'echo "SELECT sucursal_origen, to_char(fecha_insert, '" || '%d/%m/%Y' || "'),'
	
	LET cSql2 = 'echo "SELECT a.sucursal_origen, to_char(a.fecha_insert, ''' || '%d/%m/%Y' || '''), '
		   ||   'round(sum(a.monto_pago_minimo),2) MONTO_PAGO_MINIMO, '
		   ||   'round(sum(a.monto_recup_pm),2) MONTO_RECUP_PM, ' 
           ||   'case when sum(a.monto_recup_pm) <= 0 then 0 '
           ||   ' else ( case when round( (sum(a.monto_recup_pm)/sum(a.monto_pago_minimo))*100,2) > 100 then 100 ' 
           ||   ' else round( (sum(a.monto_recup_pm)/sum(a.monto_pago_minimo))*100,2) end) end PCT_CUMPLIMIENTO_PM,'
		   --||   'round(sum(pct_cump_pm),2) PCT_CUMPLIMIENTO_PM, '
		   ||   'round(sum(a.num_pm_realizados),2) NUM_PM_REALIZADOS, round(sum(a.num_pm_no_realizados),2) NUM_PM_NO_REALIZADOS, ' 
           ||   'round(sum(a.monto_saldo_vencido),2) MONTO_SALDO_VENCIDO, round(sum(a.monto_recup_sv),2) MONTO_RECUP_SV, '
           ||   'case when sum(a.monto_saldo_vencido) <= 0 then 0 '
           ||   ' else (case when round( (sum(a.monto_recup_sv)/sum(a.monto_saldo_vencido))*100, 2) > 100 then 100 '
           ||   '  else round( (sum(a.monto_recup_sv)/sum(a.monto_saldo_vencido) ) *100, 2) end) end PCT_CUMPLIM_SV,'
		   --||   'round(sum(pct_cump_sv),2) PCT_CUMPLIM_SV, '
	       ||   'round(sum(a.num_sv_realizados),2) NUM_SV_REALIZADOS, round(sum(a.num_sv_no_realizados),2) NUM_SV_NO_REALIZADOS,' 
		   ||   'case when (nvl(sum(a.pct_cump_pm),0) + nvl(sum(a.pct_cump_sv),0)) / 2 >100 then 100 '
		   ||   ' else (nvl(sum(a.pct_cump_pm),0) + nvl(sum(a.pct_cump_sv),0)) / 2 end PCT_REC_CARTERA '
           || 'FROM BDICOBRANZA:CB_EVALUACION_OBJETIVA_CRD a, BDINTEG:SI_EJECUT b, BDINTEG:SI_SUCURSALES c '
           || 'WHERE a.fecha_insert between ' || "'" || dFechaini || "'" || ' and ' || "'" || dFechafin || "' "
		   ||  ' AND a.cajero = b.ejecutivo AND b.sucursal = c.sucursal and c.tipo = ''' || 'S' || "'"
           || ' GROUP BY 1,2;' || '" >> ' || trim(cRuta)|| 'query4.sql';

	
	SYSTEM trim(cSql2); 
	LET cSql2 ='';
	
	LET cSql3 = '';
	LET cSql3 = "dbaccess bdicobranza "||trim(cRuta)|| 'query4.sql'; 
	SYSTEM trim(cSql3);

	--LET cNombreArchivo2 = trim(cNombreArchivo2)|| cExtArchivo;
    LET cSql3 = 'cat ' || trim(cRuta) || trim(cArch_encabezado_4) || ' ' || trim(cRuta) || trim(cNombreArchivo_temp) || trim(cExtArchivo) || '>' ||trim(cRuta) || trim(cNombreArchivo4) || cExtArchivo; 
	SYSTEM trim(cSql3);
	LET cSql3  = '';
		
    LET cSql3 = "gzip -f " ||trim(cRuta)|| trim(cNombreArchivo4)||cExtArchivo;    
    SYSTEM trim(cSql3);
	LET cNombreArchivo2 = trim(cNombreArchivo4)||'.gz';
	LET cSql3 = '';
    
	LET cSql3 = "rm " || trim(cRuta)|| trim(cNombreArchivo_temp) || trim(cExtArchivo);
    SYSTEM trim(cSql3);
	LET cSql3 = '';
	
	--LET cNombreArchivo4 = trim(cNombreArchivo4)|| cExtArchivo;
	   
	-----------------------------------------------------------  SUCURSAL NUEVO CRD FIN
	
	
	/*let cNombreArchivo6  = TRIM(cNombreArchivo6)|| LPAD(TRIM(DAY(dtFecha_hoy)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_hoy)::CHAR(2)),2,'0') || substr(YEAR(dtFecha_hoy),3,2);
	
	LET cSql3 = '';
	--LET cSql = 'cat ' ||trim(cRuta) || trim(cNombreArchivo2) || ' ' ||trim(cRuta) || trim(cNombreArchivo4) || '>' ||trim(cRuta) || trim(cNombreArchivo6); 
	LET cSql3 = 'cat ' || trim(cRuta) || trim(cArch_encabezado_4) || ' ' || trim(cRuta) || trim(cNombreArchivo2) || ' ' || trim(cRuta) || trim(cNombreArchivo4) || '>' ||trim(cRuta) || trim(cNombreArchivo6) || cExtArchivo; 
	SYSTEM trim(cSql3);
	LET cSql3 = '';
	
	--- PARA BORRAR LOS ARCHIVOS TEMPORALES
	LET cSql3 = "rm " || trim(cRuta)|| trim(cNombreArchivo) || ' ' || trim(cRuta) || trim(cNombreArchivo2) || ' ' || trim(cRuta) || trim(cNombreArchivo3) || ' '  || trim(cRuta) || trim(cNombreArchivo4);
    SYSTEM trim(cSql3);
	LET cSql3 = '';
	
    --LET cNombreArchivo		= "Reporte_PagoMin_Cajero_Nuevo_tdc_";
    --LET cNombreArchivo2		= "Reporte_PagoMin_Suc_Nuevo_tdc_";
    --LET cNombreArchivo3		= "Reporte_PagoMin_Cajero_Nuevo_crd";
    --LET cNombreArchivo4		= "Reporte_PagoMin_Suc_Nuevo_crd";
	*/
	
    --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeFin, '03')  RETURNING vvcCod_ret;
       
		RETURN cCodRet, cMensajeRet,cNombreArchivo5,cNombreArchivo6;
END
END PROCEDURE
 
;