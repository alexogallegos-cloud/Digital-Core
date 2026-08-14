CREATE PROCEDURE "informix".sp_reporte_pagos_rechazados(p_empresa char(3))
    RETURNING CHAR(6)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje;

-- Fecha CreaciÃ³n: Octubre 2024
-- Reporte con los pagos rechazados por rebasar el monto maximo de Saldo a Favor RQI 25 379
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
DEFINE cSQL                 CHAR(1000);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(700);
DEFINE cSQL3                CHAR(100);
DEFINE cruta                CHAR(100);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE cProceso             CHAR(4);
DEFINE dFechaHoy            DATE;
DEFINE dFechaIniMes         DATE;
DEFINE dFechaIni            DATE;
DEFINE dFechaFin            DATE;

--InicializaciÃ³n de variables
LET sql_err             = 0;
LET isam_err            = 0;
LET error_info          = "";
LET cCod_Ret            = '00000';
LET cCod_retIB          = '00000';
LET cMensaje            = 'PROCESO EXITOSO';
LET cruta               = "";
LET cnombre				= "Pagos_rechazados_sdo_favor_";
LET cnomarchivo         = "";
LET cnomarchivo1		= "";
LET cnomarchivoEjecSql  = "";
LET cSQL                = "";
LET cSQL1               = "";
LET cSQL2               = "";
LET cSQL3               = "";
LET cProceso            = '0086';
LET dFechaHoy           = DATE(1);
LET dFechaIniMes        = DATE(1);
LET dFechaIni           = DATE(1);
LET dFechaFin           = DATE(1);

--SET DEBUG FILE TO "/informix/sp_reporte_pagos_rechazados.out";
--TRACE ON;

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
    SELECT TRIM(valor)  INTO cruta FROM bdicred:sd_param WHERE empresa = p_empresa AND cod_param = '033';
    -- Obtiene la fecha del dia de hoy
    SELECT fecha_hoy, pri_dia_mes INTO dFechaHoy, dFechaIniMes FROM bdinteg:"informix".si_fechas WHERE empresa = p_empresa;

    LET cFechaGenArchivo = to_char(dFechaHoy,'%d%m%Y');
    LET dFechaFin = dFechaIniMes - 1 units day;
    LET dFechaIni = mdy(month(dFechaFin),1,year(dFechaFin));

	--Validar que existe el archivo	
	LET cnomarchivo1 = trim(cnombre)||'Aux_'||cFechaGenArchivo||'.txt ';
    LET cnomarchivo =  trim(cnombre)||cFechaGenArchivo||'.txt ';
    LET cnomarchivoEjecSql = 'Exec_Rep_PagosRechaSdoFavor.sql';

    LET cSQL='';
    LET cSQL = 'echo "Num Credito'||'|'||'Sucursal Pago'||'|'||'Fecha Pago Rechazado'||'|'||'Monto Pago Rechazado'||'|'||'Saldo Total'||'|'||'Monto Otorgado'
               || ' " >' || TRIM(cruta) || TRIM(cnomarchivo)||'';
    SYSTEM cSQL;

    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1);

    LET cSQL2 = " SELECT num_credito, sucursal, fecha_pago_rech, monto_pago_rech, sdo_total_liquidacion, monto_otorgado "        
                || " FROM bdicred:sd_pagos_rech_sdo_favor WHERE fecha_pago_rech >= '" ||dFechaIni|| "' AND fecha_pago_rech <= '" ||dFechaFin||"'";
                
    LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoEjecSql;
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
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

    LET cCod_Ret = '00000';
    LET cMensaje = 'PROCESO EXITOSO';

    CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCod_ret, 'TERMINA REPORTE PAGOS RECHAZADOS', '02') Returning cCod_RetIB;

    RETURN cCod_Ret, cMensaje;

 END;   --begin        

END PROCEDURE;