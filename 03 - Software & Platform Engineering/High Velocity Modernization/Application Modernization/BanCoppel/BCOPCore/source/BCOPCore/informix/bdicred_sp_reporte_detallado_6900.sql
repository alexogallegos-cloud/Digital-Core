CREATE PROCEDURE "informix".sp_reporte_detallado_6900(p_empresa char(3), pfechacorte DATE)
    RETURNING CHAR(6)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje;         

--Proceso para la generación del reporte dellado de Credisoluciones RQM 10 412 
--Modificado: Febrero 2015

DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_retIB			CHAR(6);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoEjecSql   CHAR(100);
DEFINE cSQL                 CHAR(3050);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2750);
DEFINE cSQL3                CHAR(100);
DEFINE cruta                CHAR(100);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE cProceso             CHAR(4);
DEFINE cFechaHoy            DATE; --CHAR(8);


--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cCod_retIB              = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET cruta                   = "";
LET cnombre					= "Credisol_Det_";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cnomarchivoEjecSql      = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cProceso                = '0084';


-- SET DEBUG FILE TO "/informix/mahr/sp_reporte_detallado_6900.out";
-- TRACE ON;


SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;

 BEGIN
  ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;       
        CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCod_ret, trim(cMensaje)||'-'||isam_err::CHAR, '02') Returning cCod_retIB;
        RETURN cCod_ret, cMensaje;
    END EXCEPTION;

    CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCod_ret, 'INICIA CREACION REPORTE', '02') Returning cCod_RetIB;

	--Obtener ruta del archivo
    SELECT TRIM(valor) INTO cruta
      FROM bdicred:sd_param WHERE empresa = p_empresa
       AND cod_param = '033';

    -- Obtiene la fecha del dia de hoy
    SELECT fecha_hoy INTO cFechaHoy FROM bdinteg:"informix".si_fechas WHERE empresa = p_empresa;

    LET cFechaGenArchivo =  to_char(pfechacorte,'%d%m%Y');

	--Validar que existe el archivo	
	LET cnomarchivo1 = trim(cnombre)||cFechaGenArchivo||'_Aux_'||'.txt ';
    LET cnomarchivo =  trim(cnombre)||cFechaGenArchivo||'.txt ';
    LET cnomarchivoEjecSql = 'Exec_Rep_Det_6900' || '.sql';


    LET cSQL='';
    LET cSQL = 'echo "Num Credito'||'|'||'Num Cliente'||'|'||'Num Credisoluciones'||'|'||'Fecha Contratacion'||'|'||'Sucursal'||'|'||'Nombre Promocion'||'|'||'Tasa'
              ||'|'||'Monto Contratado'||'|'||'Comision por disposicion'||'|'||'Plazo'||'|'||'Saldo Insoluto'||'|'||'Capital Insoluto'||'|'||'Interes por pagar'
			  ||'|'||'Iva por Pagar'||'|'||'Estatus Credisolucion'||'|'||'Mensualidades Por Pagar'||'|'||'Monto por mensualidad'||'|'||'Intereses Cargados Acumulados'||'|'||'Iva Cargados'
              ||' " >' || TRIM(cruta) || TRIM(cnomarchivo)||'';
    SYSTEM cSQL;

    LET cSQL1 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1);
    LET cSQL2 = " SELECT a.num_credito, a.num_cte, a.num_sol_prestamo, a.fecha fecha_contratacion, a.sucursal, a.nombre_promo, crd.tasa_interes tasa, "
        || " dos.monto_otorgado, case when NVL(f.monto,0) > 0 then NVL(f.monto,0) else NVL(fa.monto,0) end comision_x_disposicion, a.plazo, "
        || " round((dos.sdo_cap_insoluto + dos.sdo_intereses) + (dos.sdo_intereses *.16),2) sdo_insoluto, dos.sdo_capital cap_insoluto, "
        || " (select nvl(sum(am11.interes_debe),0) from bdicred:sd_amortiza_creditocrd am11 where a.empresa = am11.empresa and a.num_sol_prestamo = am11.num_credito "
        || " and am11.capital_status!= 5) int_x_pagar, "
        || " (select nvl(sum(am12.iva_debe),0) from bdicred:sd_amortiza_creditocrd am12 where a.empresa = am12.empresa and a.num_sol_prestamo = am12.num_credito "
        || " and am12.capital_status!= 5) iva_x_pagar, "
        || " crd.status_cred status_credisolucion, nvl(trim(cn.motivo_de_cancelacion),'') motivo_de_cancelacion, "
        || " case when (a.plazo - (select max(num_pago) from bdicred:sd_amortiza_creditocrd amor where a.empresa = amor.empresa and a.num_sol_prestamo = amor.num_credito "
        || " and capital_status = '5')) > 0 then (a.plazo - (select max(num_pago) from bdicred:sd_amortiza_creditocrd amor where a.empresa = amor.empresa "
        || " and a.num_sol_prestamo = amor.num_credito and capital_status = '5')) else 0 end mensualidades_por_cubrir, mensualidad, "
        || " (select nvl(sum(am51.interes_pagado),0) from bdicred:sd_amortiza_creditocrd am51 where a.empresa = am51.empresa and a.num_sol_prestamo = am51.num_credito "
        || " and am51.capital_status = 5) int_cargados, "
        || " (select nvl(sum(am52.iva_pagado),0) from bdicred:sd_amortiza_creditocrd am52 where a.empresa = am52.empresa and a.num_sol_prestamo = am52.num_credito "
        || " and am52.capital_status = 5) iva_cargados "
        || " FROM bdicred:sd_promocion_credito a "
        || " JOIN bdicred:sd_maecredcrd crd ON (a.empresa = crd.empresa AND a.num_sol_prestamo = crd.num_credito and a.num_pro_prestamo = '6900' AND a.empresa = '001') "
        || " JOIN bdicred:sd_maesdoscrd dos ON (a.empresa = dos.empresa AND a.num_sol_prestamo = dos.num_credito) "
        || " LEFT OUTER JOIN bdicred:sd_movhis f ON (a.empresa = f.empresa and a.num_credito = f.num_credito and f.codigo_fun ='339' and f.codigo_ref='50' "
        || " and f.transacc_suc='6901' and f.folio_suc = a.folio_movto and reversado = 'N') "
        || " LEFT OUTER JOIN bdicred:sd_movhis_new fa ON (a.empresa = fa.empresa and a.num_credito = fa.num_credito and fa.codigo_fun ='339' and fa.codigo_ref='50' "
        || " and fa.transacc_suc='6901' and fa.folio_suc = a.folio_movto and fa.reversado = 'N') "
        || " LEFT OUTER JOIN bdicred:sd_cancela_credisol cn ON (a.empresa = cn.empresa and a.num_sol_prestamo = cn.num_credito ) "
        || " WHERE a.status in (0,2,6,7) "
        || " AND a.num_sol_prestamo != '' AND dos.num_credito != '' AND crd.num_credito != ''; ";

    LET cSQL='';
    LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoEjecSql;
    LET cSQL = trim(cSQL1) || ' ' || trim(cSQL2) || ' ' || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoEjecSql;
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoEjecSql;
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/|$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
    SYSTEM cSql;

    --Borra el archivo de control.
    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || ' ' || TRIM(cruta) || cnomarchivo1;
    SYSTEM cSQL;

    LET cCod_Ret = '000000';
    LET cMensaje = 'PROCESO EXITOSO';

    CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCod_ret, 'TERMINA CREACION REPORTE', '02') Returning cCod_RetIB;

    RETURN cCod_Ret, cMensaje;

 END;   --begin        

END PROCEDURE;