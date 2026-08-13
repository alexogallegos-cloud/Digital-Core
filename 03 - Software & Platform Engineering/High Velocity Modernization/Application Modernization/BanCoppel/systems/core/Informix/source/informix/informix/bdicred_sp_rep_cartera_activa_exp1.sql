CREATE PROCEDURE "informix".sp_rep_cartera_activa_exp1(pEmpresa char(3))
returning 
          CHAR(06) AS resultado,
          CHAR(80) AS mensaje;
--************************ Definicion de variables *****************************
    define iSql_err                  integer;
    define cSql                      char(2080);
    define dPrimerDiaMes             date;
    define dUltimoDiaMesAnterior             date;
    define cNumCte                   char(20);
    define cNum_Credito              char(20);
    define cCreditoREES              char(20);
    define cStatus_CreditoREES       char(20);
    define cStatus_Credito           char(15);
    define cHit                      char(6);
    define dFecha_Nac                date;
    define cRfc                      char(13);
    define cSexo                     char(10);
    define cEstado_Civil             char(15);
    define cEmail                    char(70);
    define cNumeroEstado             char(2);
    define cNombreEstado             char(30);
    define sNumeroCiudad, sNumeroCiudadCpl smallint;
    define cNombreCiudad, cNombreCiudadCpl char(30);
    define iNumeroColonia            integer; 
    define cMunicipioZona            char(27);   
    define cTelefono1                char(13);           
    define cTelefono2                char(13);      
    define cTelefono3                char(13);     
    define cExtension                char(5);       
    define mIngreso_Mensual          money;     
    define cSucursal, cNum_Producto  char(4);    
    define cTiempo_Ocupacion_Act     char(50);     
    define dUltima_Disposicion       date;                        
    define dUltimo_Movimiento        date;                         
    define dUltimo_Vencido           date;               
    define cTipo_Ult_Mov             char(3);
    define dultimo_pago              date;
    define dSaldo_Actual             decimal(18,2);     
    define dSaldo_Vencido            decimal(18,2);     
    define dSdo_Capital              decimal(18,2);     
    define dMonto_Vencido            decimal(18,2);     
    define dMto_Venc_Trasp           decimal(18,2);     
    define dCap_Tras_No_Venci        decimal(18,2);     
    define dSaldo_Cierre             decimal(18,2);     
    define dMeses_Vencidos           decimal(18,2);     
    define cNum_Tarjeta              char(20);           
    define cNumCte_Ref               char(20);            
    define dFecha_Apertura           date;     
    define dSituacion_Pago           decimal(5,2);     
    define sMeses_Historia           smallint;
    define dfecha_hoy                date;
    define cMensajeRet               char(80);
    define cCodRet,vvcCod_ret        char(6); 
	define cCod_ret2				 char(6);
    define cNum_dia                  char(02);
    define cNum_mes                  char(02);
    define cNum_anio,cProceso        char(04);
    define dFechaVtaRees             date;
    define dFecha                    date;
    define contador_commit INTEGER;
    define sCommit      SMALLINT;
    define actualiza_esta integer;
    define cTipoReporte             char(02);
    define dUltDisp_atm             date;
    define dUltDisp_pos             date;
    define dUltDisp_vnt             date;
    define vCurrent                 char(25);
    define vdia                     char(10);
    define vhora                    char(8);
    define vHora3                   char(22); 
    define cPaso                    char(01); 
	define cMotivo					char(5);
	
	DEFINE dEvaluacion1        decimal(18,2);
	DEFINE dEvaluacion2         decimal(18,2);
	DEFINE dEvaluacion3         decimal(18,2);
	DEFINE dEvaluacion4         decimal(18,2);
	DEFINE dEvaluacion5         decimal(18,2);
	DEFINE cStatus_Ini CHAR(2);
	DEFINE cRevisado CHAR(2);
	DEFINE cIdbox smallint;
	DEFINE cIfe CHAR(2);
	DEFINE iNumPagos			INTEGER;
	DEFINE dMontoPagos  		decimal(18,2);
	DEFINE cGrupo				CHAR(2);
	DEFINE sFlag2creditoicc		SMALLINT;
	
	-- RQM 09 476 - 2 ADENDUM 
	DEFINE dLineaOrigen			decimal(18,2);
	DEFINE dLineaActual			decimal(18,2);
	DEFINE iSolicitudOS			integer;
	DEFINE iSolicitudOS_Gpo5	integer;
	DEFINE iSolicitudOS_P		integer;
	DEFINE iMarcaOS				integer;
	DEFINE cTipoFac				char(1);
     
    let iSql_err = 0;
    let cSql    = '';
    let cNumCte = '';
    let	cNum_Credito = '';
    let cNum_Credito = '';
    let cCreditoREES = '';
    let	cStatus_Credito	= '';
    let cHit = '';
    let dFecha_Nac = DATE(1);
    let cRfc = '';
    let cSexo ='';
    let cEstado_Civil = '';
    let cEmail = '';
    let cNumeroEstado = '';
    let cNombreEstado = '';
    let sNumeroCiudad = 0;
    let cNombreCiudad = '';
    let sNumeroCiudadCpl = 0;
    let cNombreCiudadCpl = '';
    let iNumeroColonia = 0;
    let cMunicipioZona = '';
    let cTelefono1 = '';
    let cTelefono2 = '';
    let cTelefono3 = '';
    let cExtension = '';
    let cSucursal = '';
    let cTiempo_Ocupacion_Act = '';
    let dUltima_Disposicion = DATE(1);
    let dUltimo_Movimiento = DATE(1);
    let dUltimo_Vencido = ' ';
    let cTipo_Ult_Mov = '';
    let dUltimo_pago = DATE(1);
    let dSaldo_Actual = 0.0;
    let dSaldo_Vencido = 0.0;
    let dSdo_Capital = 0.0;
    let dMonto_Vencido = 0.0;
    let dMto_Venc_Trasp = 0.0;
    let dCap_Tras_No_Venci = 0.0;
    let dSaldo_Cierre = 0.0;
    let dMeses_Vencidos = 0.0;
    let cNum_Tarjeta = '';
    let cNumCte_Ref = '';
    let dFecha_Apertura = DATE(1);
    let dSituacion_Pago = 0.0;
    let sMeses_Historia = 0;
    let dFecha_hoy = DATE(1);
    let dPrimerDiaMes = DATE(1);
    let dUltimoDiaMesAnterior = DATE(1);
    let cMensajeRet= 'El reporte de CARTERA ACTIVA se realizo correctamente';
    let cCodRet    = '000000';
	let cCod_ret2  = '000000';
    let cNum_dia   = '';
    let cNum_mes   = '';
    let cNum_anio  = '';
    let dFechaVtaRees  = DATE(1);
    let dFecha         = DATE(1);
    let contador_commit = 0;
    let sCommit         = 0;
    let actualiza_esta = 0;
    let cTipoReporte = '';
    let cProceso = '0033';
    let vvcCod_ret = '';
    let mIngreso_Mensual = 0;
    let dUltDisp_atm = date(1); let dUltDisp_pos = date(1); let dUltDisp_vnt = date(1);
    let vCurrent = ''; let vdia = '';   let vhora = '';  let vHora3 = '';
    let cPaso = '';  LET cNum_Producto = '';
	let cMotivo = '';
	
	let dEvaluacion1        =0;
	let dEvaluacion2        =0;
	let dEvaluacion3        =0;
	let dEvaluacion4        =0;
	let dEvaluacion5        =0;
	LET cStatus_Ini = "";
	LET cRevisado = "";
	LET cIdbox = 0;
	LET cIfe = "";
	LET iNumPagos			= 0;
	LET dMontoPagos			= 0;
	LET cGrupo				= '';
	LET sFlag2creditoicc	= 0;
	
	-- RQM 09 476 - 2 ADENDUM 
	LET dLineaOrigen		= 0.00;
	LET dLineaActual		= 0.00;
	LET iSolicitudOS		= 0;
	LET iSolicitudOS_Gpo5	= 0;
	LET iSolicitudOS_P		= 0;
	LET iMarcaOS			= 0;
	LET cTipoFac			= '';
	
--**************************** Control de errores ******************************
    begin
    on exception set iSql_err
		if iSql_err <> 0 then
           let cCodRet= iSql_err;
           let cMensajeRet= 'ERROR en la ejecucion del reporte de CARTERA ACTIVA' || cNum_Credito;
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeRet, '02') returning cCod_ret2;
--           SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora3 from sysmaster:sysshmvals;
           return cCodRet,cMensajeRet;
		end if;
	end exception;


	SET DEBUG FILE TO "/tmp/sp_rep_cartera_activa.out";
	TRACE ON;

    SELECT today, current INTO vdia, vCurrent 
      FROM systables
      where tabid=1;

      LET vhora = vCurrent[12,19];      


--*************************** Programa principal *******************************
    set isolation to dirty read;
    set lock mode to wait 3;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeRet, '01') returning cCod_ret2;	
	
    select fecha_hoy, pri_dia_mes into dFecha_hoy,dPrimerDiaMes from bdicred:sd_fechas where empresa = pEmpresa;

--temporal para pruebas
   --let dFecha_hoy = mdy('11','01','2018');
   --let dPrimerDiaMes = mdy('11','01','2018');
--temporal para pruebas

    let dUltimoDiaMesAnterior = dPrimerDiaMes - 1 units day;
    let dPrimerDiaMes = dPrimerDiaMes - 1 units month;								

    let cNum_dia  = lpad(DAY(dUltimoDiaMesAnterior),2,'0');
    let cNum_mes  = lpad(MONTH(dUltimoDiaMesAnterior),2,'0');
    let cNum_anio = lpad(YEAR(dUltimoDiaMesAnterior),4,'0');
 
/* 
    IF NOT EXISTS (select idxname from sysindices where idxname='idx_numcredito_repcartactiva') THEN
       CREATE INDEX idx_numcredito_repcartactiva on bdicred:"informix".sd_rep_cartera_activa(fecha,tipo_reporte,num_credito);
    END IF;
*/
    select valor into cPaso from bdicred:sd_param where cod_param = '079' and empresa = pEmpresa;

    select first 1 fecha into dFecha from bdicred:"informix".sd_rep_cartera_activa WHERE fecha > DATE(1);

    IF dFecha != dUltimoDiaMesAnterior THEN
        truncate table "informix".sd_rep_cartera_activa;
    END IF;
    
IF cPaso = '1' THEN
    select 'CA' tipo_reporte, fecha, empresa, num_credito, numcte, sucursal, status_cred, fecha_apertura, num_producto
     from bdicred:sd_maecredcont 
     where fecha = dUltimoDiaMesAnterior 
       and num_credito not in (select num_credito from bdicred:sd_rep_cartera_activa)
	   and empresa = pEmpresa 
       and campo_trab3 <> 'BAJA'
     into temp paso_maecredcont with no log; 

    CREATE INDEX idx_paso_maecredcont on paso_maecredcont (fecha, empresa, num_credito); 
    UPDATE statistics medium FOR TABLE "informix".paso_maecredcont;
    
	
    FOREACH WITH HOLD
        select a.tipo_reporte, a.numcte, a.num_credito,
             (case when a.status_cred = 'AA' then 'VIGENTE' else
              case when a.status_cred = 'BA' then 'TRANSITORIO' else 
              case when a.status_cred = 'BT' then 'VENCIDO' else
              case when a.status_cred = 'CV' then 'VENDIDO' else
              case when a.status_cred = 'FC' then 'REESTRUCTURADO' else 'LIQUIDADO' end end end end end) estatus_credito,
             (case when h.evalua_cc = '1' then 'Hit' else
              case when h.evalua_cc = '0' then 'Hit' else
              case when h.evalua_cc = '2' then 'Hit' else
              case when h.evalua_cc = '4' then 'Hit' else
              case when h.evalua_cc = 'X' then 'No Hit' else
              case when h.evalua_cc = '' then 'No Hit' else 'No Hit' end end end end end end) hit,
             h.ingreso_mensual, 
             a.sucursal,
             0 saldo_actual, 
             i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_vencido, 
             i.sdo_capital, i.monto_vencido, i.mto_venc_trasp, i.cap_tras_no_venci, 
             i.sdo_capital + i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_cierre, 
             i.mto_fin_ven_trasp meses_vencidos, 
             a.fecha_apertura, h.situacion_pago, h.meses_historia, a.num_producto, nvl(h.grupo,'')
         INTO cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cHit, mIngreso_Mensual, cSucursal, dSaldo_Actual, dSaldo_Vencido, dSdo_Capital,  
              dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cNum_Producto, cGrupo
         from paso_maecredcont a
              join bdicred:sd_maesdoscont i on i.fecha = a.fecha and i.empresa = a.empresa and i.num_credito = a.num_credito
              left outer join bdisolic:ss_resum_scor_fin h on (h.empresa = a.empresa and h.num_solicitud = a.num_credito)
				
           
           BEGIN WORK;
               insert into "informix".sd_rep_cartera_activa (fecha, tipo_reporte, numcte, num_credito, estatus_credito, num_producto, hit, fecha_nac, rfc, sexo, estado_civil, 
                  email, numeroestado, nombreestado, numerociudad, nombreciudad, numciudad_cpl, nombreciudad_cpl, numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension, 
                  ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion, ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido,
                  sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta, numcte_ref, fecha_apertura, situacion_pago,
                  meses_historia, motivo, flag2credito, grupo, num_pagos, monto_pagos,linea_origen,linea_actual,marca_os,tipo_facturacion)
               values (dUltimoDiaMesAnterior, cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cNum_Producto, cHit, dFecha_Nac, cRfc, cSexo, cEstado_Civil,
                  cEmail, cNumeroEstado, cNombreEstado, sNumeroCiudad, cNombreCiudad, sNumeroCiudadCpl, cNombreCiudadCpl, iNumeroColonia, cMunicipioZona, cTelefono1, cTelefono2, cTelefono3, cExtension,
                  mIngreso_Mensual, cSucursal, cTiempo_Ocupacion_Act, dUltima_Disposicion, dUltimo_Movimiento, dUltimo_Vencido, cTipo_Ult_Mov, dSaldo_Actual, 
                  dSaldo_Vencido, dSdo_Capital, dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, cNum_Tarjeta, cNumCte_Ref, 
                  dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cMotivo, sFlag2creditoicc, cGrupo, iNumPagos, dMontoPagos,dLineaOrigen,dLineaActual,iMarcaOS,cTipoFac);
          COMMIT WORK;
    
    END FOREACH;
	---Se Agrega bloque de credisoluciones (6900) RQM 09 212-2  Adendum Reporte Cartera Activa JMAH
	
	select 'CA' tipo_reporte, fecha, empresa, num_credito, numcte, sucursal, status_cred, fecha_apertura, num_producto
     from bdicred:sd_maecredcontcrd
     where fecha = dUltimoDiaMesAnterior and empresa = pEmpresa 
       and num_credito not in (select num_credito from bdicred:sd_rep_cartera_activa)
       and campo_trab3 <> 'BAJA'
	   and num_producto ='6900'
     into temp paso_maecredcontcrd with no log; 

    CREATE INDEX idx_paso_maecredcontcrd on paso_maecredcontcrd (fecha, empresa, num_credito); 
    UPDATE statistics medium FOR TABLE "informix".paso_maecredcontcrd;
	
	
	
	 FOREACH WITH HOLD
        select a.tipo_reporte, a.numcte, a.num_credito,
             (case when a.status_cred = 'AA' then 'VIGENTE' else
              case when a.status_cred = 'BA' then 'TRANSITORIO' else 
              case when a.status_cred = 'BT' then 'VENCIDO' else
              case when a.status_cred = 'CV' then 'VENDIDO' else
              case when a.status_cred = 'FC' then 'REESTRUCTURADO' else 'LIQUIDADO' end end end end end) estatus_credito,
             (case when h.evalua_cc = '1' then 'Hit' else
              case when h.evalua_cc = '0' then 'Hit' else
              case when h.evalua_cc = '2' then 'Hit' else
              case when h.evalua_cc = '4' then 'Hit' else
              case when h.evalua_cc = 'X' then 'No Hit' else
              case when h.evalua_cc = '' then 'No Hit' else 'No Hit' end end end end end end) hit,
             h.ingreso_mensual, 
             a.sucursal,
             0 saldo_actual, 
             i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_vencido, 
             i.sdo_capital, i.monto_vencido, i.mto_venc_trasp, i.cap_tras_no_venci, 
             i.sdo_capital + i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_cierre, 
             i.mto_fin_ven_trasp meses_vencidos, 
             a.fecha_apertura, h.situacion_pago, h.meses_historia, a.num_producto, h.grupo
         INTO cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cHit, mIngreso_Mensual, cSucursal, dSaldo_Actual, dSaldo_Vencido, dSdo_Capital,  
              dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cNum_Producto, cGrupo
         from paso_maecredcontcrd a
              join bdicred:sd_maesdoscontcrd i on i.fecha = a.fecha and i.empresa = a.empresa and i.num_credito = a.num_credito
              left outer join bdisolic:ss_resum_scor_fin h on (h.empresa = a.empresa and h.num_solicitud = a.num_credito)
    
           
           BEGIN WORK;
               insert into "informix".sd_rep_cartera_activa (fecha, tipo_reporte, numcte, num_credito, estatus_credito, num_producto, hit, fecha_nac, rfc, sexo, estado_civil, 
                  email, numeroestado, nombreestado, numerociudad, nombreciudad, numciudad_cpl, nombreciudad_cpl, numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension, 
                  ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion, ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido,
                  sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta, numcte_ref, fecha_apertura, situacion_pago,
                  meses_historia, motivo, flag2credito, grupo, num_pagos, monto_pagos)
               values (dUltimoDiaMesAnterior, cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cNum_Producto, cHit, dFecha_Nac, cRfc, cSexo, cEstado_Civil,
                  cEmail, cNumeroEstado, cNombreEstado, sNumeroCiudad, cNombreCiudad, sNumeroCiudadCpl, cNombreCiudadCpl, iNumeroColonia, cMunicipioZona, cTelefono1, cTelefono2, cTelefono3, cExtension,
                  mIngreso_Mensual, cSucursal, cTiempo_Ocupacion_Act, dUltima_Disposicion, dUltimo_Movimiento, dUltimo_Vencido, cTipo_Ult_Mov, dSaldo_Actual, 
                  dSaldo_Vencido, dSdo_Capital, dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, cNum_Tarjeta, cNumCte_Ref, 
                  dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cMotivo, sFlag2creditoicc, cGrupo, iNumPagos, dMontoPagos);
          COMMIT WORK;
    
    END FOREACH;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='2'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '2';
END IF;

IF cPaso = '2' THEN
    FOREACH WITH HOLD
        select  'CV' tipo_reporte,a.numcte, a.num_credito,
             (case when a.status_cred = 'AA' then 'VIGENTE' else
              case when a.status_cred = 'BA' then 'TRANSITORIO' else 
              case when a.status_cred = 'BT' then 'VENCIDO' else
              case when a.status_cred = 'CV' then 'VENDIDO' else
              case when a.status_cred = 'FC' then 'REESTRUCTURADO' else 'LIQUIDADO' end end end end end) estatus_credito,
             (case when h.evalua_cc = '1' then 'Hit' else
              case when h.evalua_cc = '0' then 'Hit' else
              case when h.evalua_cc = '2' then 'Hit' else
              case when h.evalua_cc = '4' then 'Hit' else
              case when h.evalua_cc = 'X' then 'No Hit' else
              case when h.evalua_cc = '' then 'No Hit' else 'No Hit' end end end end end end) hit,
             h.ingreso_mensual, a.sucursal,
             i.sdo_capital + i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_actual,
             i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_vencido,
             i.sdo_capital, i.monto_vencido, i.mto_venc_trasp, i.cap_tras_no_venci, 0 saldo_cierre,
             i.mto_fin_ven_trasp meses_vencidos, --j.num_tarjeta, 
             a.fecha_apertura, h.situacion_pago, h.meses_historia, a.num_producto
         INTO cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cHit, mIngreso_Mensual, cSucursal, dSaldo_Actual, dSaldo_Vencido, dSdo_Capital,  
              dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cNum_Producto
         from bdicred:sd_maecred_vendida a
              join bdicred:sd_maesdos_vendida i on (a.fecha = i.fecha and a.empresa = i.empresa and a.num_credito = i.num_credito)
              left outer join bdisolic:ss_resum_scor_fin h on (h.empresa = a.empresa and h.num_solicitud = a.num_credito)
        where a.fecha between dPrimerDiaMes and dUltimoDiaMesAnterior and a.empresa = pEmpresa and a.num_credito>=''
          and a.num_credito in (select num_credito from bdicred:"informix".sd_maecred where empresa=pEmpresa and num_credito=a.num_credito and status_cred='CV') 
          and a.num_credito not in (select num_credito from bdicred:sd_rep_cartera_activa)
			
          BEGIN WORK;
               insert into "informix".sd_rep_cartera_activa (fecha, tipo_reporte, numcte, num_credito, estatus_credito, num_producto, hit, fecha_nac, rfc, sexo, estado_civil, 
                  email, numeroestado, nombreestado, numerociudad, nombreciudad, numciudad_cpl, nombreciudad_cpl, numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension, 
                  ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion, ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido,
                  sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta, numcte_ref, fecha_apertura, situacion_pago,
                  meses_historia, motivo)
               values (dUltimoDiaMesAnterior, cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cNum_Producto, cHit, dFecha_Nac, cRfc, cSexo, cEstado_Civil,
                  cEmail, cNumeroEstado, cNombreEstado, sNumeroCiudad, cNombreCiudad, sNumeroCiudadCpl, cNombreCiudadCpl, iNumeroColonia, cMunicipioZona, cTelefono1, cTelefono2, cTelefono3, cExtension,
                  mIngreso_Mensual, cSucursal, cTiempo_Ocupacion_Act, dUltima_Disposicion, dUltimo_Movimiento, dUltimo_Vencido, cTipo_Ult_Mov, dSaldo_Actual, 
                  dSaldo_Vencido, dSdo_Capital, dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, cNum_Tarjeta, cNumCte_Ref, 
                  dFecha_Apertura, dSituacion_Pago, sMeses_Historia,cMotivo);
          COMMIT WORK;
  
    END FOREACH;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='3'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '3';
END IF;

IF cPaso = '3' THEN
    UPDATE statistics medium FOR TABLE "informix".sd_rep_cartera_activa;

    FOREACH WITH HOLD

--        select {+INDEX(bdicred:sd_rep_cartera_activa sd_repcartera_activa1)} tipo_reporte, numcte, num_credito 
        select tipo_reporte, numcte, num_credito 
          INTO cTipoReporte, cNumCte, cNum_Credito  
	        from "informix".sd_rep_cartera_activa 
           where fecha = dUltimoDiaMesAnterior
             and (sexo is null or sexo = '')
         
         select nvl(a.correo_elec,'')  into cEmail 
           from bdinteg:si_correos a
          where a.empresa = pEmpresa
            and a.numcte = cNumCte
            and a.secuencia = (select max(secuencia) from bdinteg:si_correos where empresa = a.empresa and numcte = a.numcte); 

         select c.fecha_nac, b.rfc, (case when c.sexo = 'M' then 'MASCULINO' else 'FEMENINO' end) sexo, 
               (case when c.estado_civil = 'C' then 'Casado' else
                case when c.estado_civil = 'D' then 'Divorciado' else
                case when c.estado_civil = 'S' then 'Soltero' else
                case when c.estado_civil = 'U' then 'Union Libre' else 'Viudo' end end end end) estado_civil,
                b.numcte_ref
             into dFecha_Nac, cRfc, cSexo, cEstado_Civil, cNumCte_Ref
            from bdinteg:si_cliente b 
            left outer join bdinteg:si_ctepf c on (c.numcte = b.numcte)
            where b.numcte = cNumCte;

         select a.num_tarjeta into cNum_Tarjeta
           from bdicred:sd_tarjeta a
          where a.empresa = pEmpresa 
            and a.num_credito = cNum_Credito
            and a.tipo_tarjeta = 'T' and secuencia = (select max(secuencia) from bdicred:sd_tarjeta 
    	                                                 where empresa = a.empresa and num_credito = a.num_credito and tipo_tarjeta = 'T');

         select limit 1 d1.estado, e.nombre, d1.numerociudad CdCpl, catcd.nombreciudad NomCdCpl, d1.ciudad NumCdBcpl,cds.nombre NomCdBcpl,d1.numerocolonia, g.municipiozona,
                nvl(tel1.telefono,''), nvl(tel2.telefono,''), nvl(tel3.telefono,''), nvl(tel3.extension,'')
           into cNumeroEstado, cNombreEstado, sNumeroCiudadCpl, cNombreCiudadCpl, sNumeroCiudad, cNombreCiudad, iNumeroColonia,
                cMunicipioZona, cTelefono1, cTelefono2, cTelefono3, cExtension 
           from bdinteg:si_direcciones_actual d1 
                left outer join bdinteg:si_direcciones_actual d2 on (d2.numcte = d1.numcte and d2.tipo_dir = '2')
                left outer join bdinteg:si_estados e on (e.estado = d1.estado)
                left outer join bdinteg:si_catciudades catcd on (catcd.numerociudad = d1.numerociudad )
                left outer join bdinteg:si_ciudades cds on (cds.estado = d1.estado and cds.ciudad_coppel = d1.numerociudad and cds.ciudad = d1.ciudad)
                left outer join bdinteg:si_catzonas g on (g.numerociudad = d1.numerociudad and g.numerocolonia = d1.numerocolonia)
                Left outer join bdinteg:si_telefonos_actual tel1 on tel1.numcte= d1.numcte 
                     and tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual where numcte = d1.numcte and tipo_tel = 1 and cofetel ='V')
                     and tel1.tipo_tel = 1 and tel1.cofetel ='V'
                left outer join bdinteg:si_telefonos_actual tel2 on tel2.numcte= d1.numcte 
                     and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual where numcte = d1.numcte and tipo_tel = 2 and cofetel ='V')
                     and tel2.tipo_tel = 2 and tel2.cofetel ='V'
                left outer join bdinteg:si_telefonos_actual tel3 on tel3.numcte= d1.numcte 
                     and tel3.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual where numcte = d1.numcte and tipo_tel = 3 and cofetel ='V')
                     and tel3.tipo_tel = 3 and tel3.cofetel ='V'    
          where d1.numcte = cNumCte
            and d1.tipo_dir = '1';
 /*
     select fecha_ult_pago,fecha_vencto into dUltimo_pago,dUltimo_Vencido from bdicred:sd_maecredanexo where empresa = pEmpresa and num_credito = cNum_Credito ;

     if dUltimo_pago is null then let dUltimo_pago = ''; end if;
     if dUltimo_Vencido is null then let dUltimo_Vencido = ''; end if;
 */
    -- obtener la ocupacion actual
         select sel.descripcion into cTiempo_Ocupacion_Act from bdisolic:ss_detalle_scoring  dsc 
             inner join bdisolic:ss_scoring_grupo sgr on sgr.empresa=dsc.empresa and sgr.grupo=dsc.grupo and sgr.seccion=dsc.seccion
             inner join bdisolic:ss_scoring_element sel on sel.empresa=dsc.empresa and sel.grupo=dsc.grupo and sel.elemento=dsc.elemento 
                        and sel.seccion=dsc.seccion
          where dsc.empresa = pEmpresa and dsc.grupo = '8' and dsc.seccion = '2' and dsc.num_solicitud = cNum_Credito 
            and sel.elemento = (select max(elemento) 
                                  from bdisolic:ss_detalle_scoring 
                                 where empresa= dsc.empresa and grupo = dsc.grupo and seccion = dsc.seccion and num_solicitud = dsc.num_solicitud); 
/*
-- obtener la ultima disposicion
    select {+INDEX(bdicred:sd_movhis inx_movhis)} nvl(max(fecha_mov),dFecha_Apertura) into dUltima_Disposicion 
      from bdicred:sd_movhis 
     where empresa = pEmpresa 
       AND fecha_mov >= dFecha_Apertura 
       AND fecha_mov <= dUltimoDiaMesAnterior
       and num_credito = cNum_Credito 
       and codigo_fun = '002' 
       and codigo_ref in (50,60,30,40,41,42,61,62,63,64)
       and reversado = 'N';
*/
		---Se Agrega bloque de credisoluciones (6900) RQM 09 212-2  Adendum Reporte Cartera Activa JMAH
		IF SUBSTR(cNum_Credito,1,2) = '69' THEN
			let dUltDisp_atm = ''; 
			let dUltDisp_pos = ''; 
			let dUltDisp_vnt = ''; 
			let dUltimo_pago = ''; 
			let dUltimo_Vencido = ''; 
		ELSE
         SELECT nvl(atm_disp_fecha_h,''), nvl(pos_disp_fecha_h,''), nvl(vnt_disp_fecha_h,''), nvl(fecha_ultimo_pago_h,''), 
               nvl(fecha_vencido,'')
          INTO dUltDisp_atm, dUltDisp_pos, dUltDisp_vnt, dUltimo_pago, dUltimo_Vencido
          FROM bdicred:sd_indicador_cred
         WHERE empresa = pEmpresa 
           AND num_credito = cNum_Credito;
		END IF;
		
        if dUltDisp_atm is null then let dUltDisp_atm = ''; end if;
        if dUltDisp_pos is null then let dUltDisp_pos = ''; end if;
        if dUltDisp_vnt is null then let dUltDisp_vnt = ''; end if;
        if dUltimo_pago is null then let dUltimo_pago = ''; end if;
        if dUltimo_Vencido is null then let dUltimo_Vencido = ''; end if;
       
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


    -- obtener ultimo pago
        if(dUltima_Disposicion > dUltimo_pago) then
            let dUltimo_Movimiento = dUltima_Disposicion;
            let cTipo_Ult_Mov = '002';
        elif (dUltimo_pago > dUltima_Disposicion) then
            let dUltimo_Movimiento = dUltimo_pago;
            let cTipo_Ult_Mov = '052';
        elif(dUltima_Disposicion = dUltimo_pago) then
            let dUltimo_Movimiento = dUltima_Disposicion;
            let cTipo_Ult_Mov = '002';
        end if;
		
	-- obtener causa solicitud
		
		select limit 1 nvl(a.causa_solicitud,'') into cMotivo
		from bdisolic:ss_autorizacion a
		where a.empresa = pEmpresa
		and a.num_solicitud = cNum_Credito
		and fecha_hora = (select max(fecha_hora) from bdisolic:ss_autorizacion where num_solicitud = cNum_Credito and status_solicitud = 'AT')
		and a.status_solicitud = 'AT';
			
	 ---Se Agrega bloque de credisoluciones (6900) RQM 09 212-2  Adendum Reporte Cartera Activa JMAH
		SELECT
				nvl(SUM(decode(seccion, '1', nvl(evaluacion,0), 0)),0) AS seccion1,
				nvl(SUM(decode(seccion, '2', nvl(evaluacion,0), 0)),0) AS seccion2,
				nvl(SUM(decode(seccion, '3', nvl(evaluacion,0), 0)),0) AS seccion3,
				nvl(SUM(decode(seccion, '4', nvl(evaluacion,0), 0)),0) AS seccion4,
				nvl(SUM(decode(seccion, '5', nvl(evaluacion,0), 0)),0) AS seccion5                        
		INTO dEvaluacion1, dEvaluacion2, dEvaluacion3, dEvaluacion4,dEvaluacion5
		FROM bdisolic:ss_resumen_scoring
		WHERE empresa= '001'
		AND seccion in ('1', '2','3', '4','5')
		AND num_solicitud = cNum_Credito;
		
					-- MODIFICACION REPORTE RQM 09 459-2 (INICIO)
			SELECT status_ini
			 INTO cStatus_Ini
			 FROM bdisolic:"informix".ss_solicitudes_mc
			WHERE empresa = '001'
			 AND num_solicitud = cNum_Credito;
			 
			IF cStatus_Ini IS NULL THEN
			   LET cStatus_Ini = ' ';
			END IF;
			
			SELECT CASE WHEN revisado = 'N' THEN 'C'ELSE 'R' END
			 INTO cRevisado
			 FROM bdisolic:"informix".ss_solicitudes_mc
			WHERE empresa = '001'
			 AND num_solicitud = cNum_Credito;
			 
			IF cRevisado IS NULL THEN
			   LET cRevisado = ' ';
			END IF;
			
			SELECT COUNT(*) 
			 INTO cIdbox
			 FROM bdisolic:"informix".ss_solicitudes_mc a
			 RIGHT OUTER JOIN bdinteg:si_bitacora_ife b on ( a.numcte = b.numcte and b.fecha = (select max(fecha) from bdinteg:si_bitacora_ife where numcte=a.numcte))   
			WHERE empresa = '001'
			 AND num_solicitud = cNum_Credito;
			 			
			IF cIdbox >= 1 THEN 
			   LET cIFE = 'Si';
			ELSE   
			   LET cIFE = 'No'; 
			END IF;	
			-- MODIFICACION REPORTE RQM 09 459-2 (FIN)				
		
			SELECT nvl(flag2creditoicc,0) INTO sFlag2creditoicc 
			FROM bdisolic:ss_revision_determinacion
			WHERE empresa = '001'
			  AND num_solicitud = cNum_Credito;

         SELECT nvl(num_pagos,0),nvl(monto_pagos,0)
          INTO iNumPagos, dMontoPagos
          FROM bdicred:sd_indicador_cred_hist
         WHERE empresa = pEmpresa 
		   AND fecha = dUltimoDiaMesAnterior
           AND num_credito = cNum_Credito;
		   
			-- RQM 09 476 - 2 ADENDUM 
			SELECT monto_solicitado INTO dLineaOrigen FROM bdisolic:ss_solicitudes	
			WHERE empresa=pEmpresa AND num_solicitud=cNum_Credito; 

			SELECT monto_otorgado INTO dLineaActual FROM bdicred:sd_maesdos 
			WHERE empresa=pEmpresa AND num_credito=cNum_Credito; 
			
			SELECT COUNT(num_solicitud) INTO iSolicitudOS FROM bdisolic:ss_solicitud_os
			WHERE empresa=pEmpresa AND num_solicitud=cNum_Credito;
			
			SELECT COUNT(num_solicitud) INTO iSolicitudOS_Gpo5 FROM bdisolic:bitacora_os_gpo5 
			WHERE empresa=pEmpresa AND num_solicitud=cNum_Credito;
			  
			IF iSolicitudOS > 0 THEN 
			
				LET iMarcaOS = 1;		-- ADD
				
				SELECT COUNT(num_solicitud) INTO iSolicitudOS_P FROM bdisolic:ss_solicitud_os
				WHERE empresa=pEmpresa AND num_solicitud=cNum_Credito AND status='P';
				
				IF iSolicitudOS_P > 0 THEN
					LET iMarcaOS = 1;
				ELSE
					IF iSolicitudOS_Gpo5 >0 THEN
						LET iMarcaOS = 2;
					ELSE
						LET iMarcaOS = 0;
					END IF;	
				END IF;
			ELSE	
				IF iSolicitudOS_Gpo5 >0 THEN
					LET iMarcaOS = 2;
				ELSE
					LET iMarcaOS = 0;
				END IF;	
			END IF;
			
			if dUltDisp_atm is null or dUltDisp_atm = '' then let dUltDisp_atm = date(1); end if;
			if dUltDisp_pos is null or dUltDisp_pos = '' then let dUltDisp_pos = date(1); end if;
			if dUltDisp_vnt is null or dUltDisp_vnt = '' then let dUltDisp_vnt = date(1); end if;
			
			--	Indicaremos "D" si el cliente durante el mes realizÃÂÃÂ³ SOLO disposiciones en efectivo.((ATM OR VNT)OR (ATM AND VNT))AND NOT POS
			IF ((dUltDisp_atm BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) OR  (dUltDisp_vnt BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) OR
				 ((dUltDisp_atm BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) AND (dUltDisp_vnt BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior)))AND	
				 (dUltDisp_pos<dPrimerDiaMes OR dUltDisp_pos>dUltimoDiaMesAnterior)THEN
					LET cTipoFac = 'D';
			-- Indicaremos "C" si el cliente durante el mes realizÃÂÃÂ³ SOLO compras en terminal punto de venta.
			--	((POS)AND(ATM<PriDiaMes OR ATM>UltDiaMes) or AMBAS)AND (VNT<PriDiaMes OR VNT>UltDiaMes) or AMBAS)
			ELIF (dUltDisp_pos BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) AND 
				 (dUltDisp_atm<dPrimerDiaMes OR dUltDisp_atm>dUltimoDiaMesAnterior) AND 
				 (dUltDisp_vnt<dPrimerDiaMes OR dUltDisp_vnt>dUltimoDiaMesAnterior ) THEN
					LET cTipoFac = 'C';
			--	Indicaremos "M" si el cliente durante el mes realizÃÂÃÂ³ compras y disposiciones (cajero y/o ventanilla) en efectivo.(ATM AND VNT AND POS)
			ELIF (dUltDisp_atm BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) AND (dUltDisp_vnt BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) AND
				   (dUltDisp_pos BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) THEN
						LET cTipoFac = 'M';
			ELSE 
				LET cTipoFac = ' ';
			END IF;
						
        BEGIN WORK;
            UPDATE "informix".sd_rep_cartera_activa
               SET  fecha_nac = dFecha_Nac, rfc = cRfc, sexo = cSexo, estado_civil = cEstado_Civil, email = cEmail, numeroestado = cNumeroEstado, 
                    nombreestado = cNombreEstado, numerociudad=sNumeroCiudad, nombreciudad=cNombreCiudad, numciudad_cpl=sNumeroCiudadCpl, nombreciudad_cpl=cNombreCiudadCpl, numerocolonia=iNumeroColonia, 
                    municipiozona = cMunicipioZona, telefono1 = cTelefono1, telefono2 = cTelefono2, telefono3 = cTelefono3, extension = cExtension, 
                    tiempo_ocupacion_act = NVL(cTiempo_Ocupacion_Act,''), ultima_disposicion = dUltima_Disposicion, ultimo_movimiento = dUltimo_Movimiento,
                    ultimo_vencido = dUltimo_Vencido, tipo_ult_mov = cTipo_Ult_Mov, num_tarjeta = NVL(cNum_Tarjeta,''), numcte_ref = cNumCte_Ref, motivo = NVL(cMotivo  ,''),
					bscore = dEvaluacion1, scoreprop= dEvaluacion2, ficoscore = dEvaluacion3, ficoextended = dEvaluacion4,icc =dEvaluacion5,
					status = cStatus_Ini, revisado = cRevisado, ife = cIFE, num_pagos = nvl(iNumPagos,0), monto_pagos = nvl(dMontoPagos,0), flag2credito = nvl(sFlag2creditoicc,0),
					num_pagos = nvl(iNumPagos,0), monto_pagos = nvl(dMontoPagos,0),linea_origen=dLineaOrigen,linea_actual=dLineaActual,marca_os=iMarcaOS,tipo_facturacion=nvl(cTipoFac,'')
             WHERE numcte = cNumCte 
			 AND num_credito = cNum_Credito ;
        COMMIT WORK;
    	
    
        let dFecha_Nac = '';
        let cRfc  = '';
        let cSexo = '';
        let cEstado_Civil = '';
        let cEmail = '';
        let cNumeroEstado = '';
        let cNombreEstado = '';
        let sNumeroCiudad = '';
        let cNombreCiudad  = '';
        let sNumeroCiudadCpl=''; let cNombreCiudadCpl='';
        let iNumeroColonia = '';
        let cMunicipioZona = '';
        let cTelefono1 = '';
        let cTelefono2 = '';
        let cTelefono3 = '';
        let cExtension = '';
        let cTiempo_Ocupacion_Act  = '';
        let dUltima_Disposicion  = '';
        let dUltimo_Movimiento = '';
        let dUltimo_Vencido = '';
        let cTipo_Ult_Mov = '';
        let cNum_Tarjeta  = '';
        let cNumCte_Ref  = '';
		let cMotivo = '';
		let sFlag2creditoicc = 0;
        let contador_commit = contador_commit  + 1;
        let actualiza_esta = actualiza_esta + 1;
		let dLineaOrigen=0;
		let dLineaActual=0;
		let iMarcaOS=0;
   end foreach;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='4'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '4';
END IF;


IF cPaso = '4' THEN
   let sCommit = 0;
--Reporte de cartera activa
    let cSql = 'echo "Set isolation to dirty read; UNLOAD TO ' || '/resplogifx/archivoscartera/Rep_cartera_activa_'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
--  let cSql = 'echo "UNLOAD TO ' || 'Rep_cartera_activa_'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
    'DELIMITER ' || '''|''' ||
       ' select num_producto, numcte, num_credito, estatus_credito, hit, numeroestado, nombreestado, ' ||
       ' numciudad_cpl, nombreciudad_cpl, numerociudad, nombreciudad, ' ||
       ' sucursal, saldo_actual, saldo_vencido, sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, ' ||
       ' saldo_cierre, meses_vencidos, fecha_apertura, situacion_pago, meses_historia, motivo, ' ||
	   ' case when (select excluye_validacion from bdisolic:'''||'informix'||'''.ss_revision_determinacion where empresa = '''||'001'||''' and num_solicitud = num_credito)  ' || 
	   ' = 1 then '''||'Excepcion de validacion telefonica por puntaje'||'''  else '''||' '||''' end case , ' ||	 
	   ' bscore , scoreprop, ficoscore , ficoextended ,icc,status , revisado, ife, flag2credito, grupo, num_pagos, monto_pagos,	   ' ||	
	   ' linea_origen,linea_actual,marca_os,tipo_facturacion,ultima_disposicion	'||
       ' from sd_rep_cartera_activa where tipo_reporte = '''||'CA'||''' and saldo_cierre > 0;"' ||
       ' > /resplogifx/archivoscartera/query_cartera_activa.sql';
       /*' select numcte, num_credito, estatus_credito, hit, fecha_nac, rfc, sexo,' ||
       ' estado_civil, email, numeroestado, nombreestado, numerociudad, nombreciudad,' ||
       ' numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension,' ||
       ' ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion,' ||
       ' ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido, sdo_capital,' || 
       ' monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta,' ||
       ' numcte_ref, fecha_apertura, situacion_pago, meses_historia, flag2credito, grupo, num_pagos, monto_pagos from sd_rep_cartera_activa where tipo_reporte = '''||'CA'||''' and saldo_cierre > 0;"' ||
       ' > /resplogifx/archivoscartera/query_cartera_activa.sql'; */
--     ' > query_cartera_activa.sql';
    system cSql;
    let cSql='';
    let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/query_cartera_activa.sql';
--  let cSql = 'dbaccess bdicred query_cartera_activa.sql';
    system cSql;
    LET cSql = 'rm /resplogifx/archivoscartera/query_cartera_activa.sql';
--  LET cSql = 'rm query_cartera_activa.sql';
    SYSTEM cSql;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='5'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '5';
END IF;

IF cPaso = '5' THEN
--Reporte de creditos inactivos o con saldo a favor
    let cSql = 'echo "Set isolation to dirty read; UNLOAD TO ' || '/resplogifx/archivoscartera/Rep_clientes_inactivos_'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
--  let cSql = 'echo "UNLOAD TO ' || 'Rep_clientes_inactivos_'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
    'DELIMITER ' || '''|''' ||
       ' select numcte, num_credito, estatus_credito, hit, fecha_nac, rfc, sexo,' ||
       ' estado_civil, email, numeroestado, nombreestado, numerociudad, nombreciudad,' ||
       ' numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension,' ||
       ' ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion,' ||
       ' ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido, sdo_capital,' || 
       ' monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta,' ||
       ' numcte_ref, fecha_apertura, situacion_pago, meses_historia from sd_rep_cartera_activa where tipo_reporte = '''||'CA'||''' and saldo_cierre <= 0;"' ||
       ' > /resplogifx/archivoscartera/query_clientes_inactivos.sql';
--     ' > query_clientes_inactivos.sql';
    system cSql;
    let cSql='';
    let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/query_clientes_inactivos.sql';
--  let cSql = 'dbaccess bdicred query_clientes_inactivos.sql';
    system cSql;
    LET cSql = 'rm /resplogifx/archivoscartera/query_clientes_inactivos.sql';
--  LET cSql = 'rm query_clientes_inactivos.sql';
    SYSTEM cSql;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='6'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '6';
END IF;

IF cPaso = '6' THEN
--Reporte de cartera vendida
    let cSql = 'echo "Set isolation to dirty read; UNLOAD TO ' || '/resplogifx/archivoscartera/Rep_cartera_vendida'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
--  let cSql = 'echo "UNLOAD TO ' || 'Rep_cartera_vendida'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
    'DELIMITER ' || '''|''' ||
       ' select numcte, num_credito, estatus_credito, hit, fecha_nac, rfc, sexo,' ||
       ' estado_civil, email, numeroestado, nombreestado, numerociudad, nombreciudad,' ||
       ' numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension,' ||
       ' ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion,' ||
       ' ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido, sdo_capital,' || 
       ' monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta,' ||
       ' numcte_ref, fecha_apertura, situacion_pago, meses_historia from sd_rep_cartera_activa where tipo_reporte ='''||'CV'||''';"' ||
       ' > /resplogifx/archivoscartera/query_cartera_vendida.sql';
--     ' > query_cartera_vendida.sql';
    system cSql;
    let cSql='';
    let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/query_cartera_vendida.sql';
--  let cSql = 'dbaccess bdicred query_cartera_vendida.sql';
    system cSql;
    LET cSql = 'rm /resplogifx/archivoscartera/query_cartera_vendida.sql';
--  LET cSql = 'rm query_cartera_vendida.sql';
    SYSTEM cSql;
END IF;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='1'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
--    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora3 from sysmaster:sysshmvals;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeRet, '03') returning cCod_ret2;
    return cCodRet,cMensajeRet;
end;
end procedure;