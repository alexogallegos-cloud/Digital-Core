CREATE PROCEDURE "informix".sp_seguimiento_diario_platino(pEmpresa char(3))

RETURNING  CHAR(6) AS Cod_Ret,  CHAR(80) AS Mens_Ret;

-- Creado por: Martha A H.- Reporte de seguimiento diario de la cartera de Tarjeta de Credito Platino.
-- Modificado por: David Ulises C.M.
--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cEmpresa             CHAR(3);
DEFINE cCod_ret				CHAR(6);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cdias				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivo2          CHAR(100);
DEFINE cnomarchivo3			CHAR(100);
DEFINE cSQL                 CHAR(1500);
DEFINE cSQL1                CHAR(300);
DEFINE cSQL2                CHAR(800);
DEFINE cSQL3                CHAR(100);
DEFINE pFecha               DATE;
DEFINE cMensajeRet          CHAR(125);
DEFINE cProceso             CHAR(4);
DEFINE cCod_retBit          CHAR(6);
DEFINE cdelimitador         CHAR(1);

	--SET DEBUG FILE TO "/informix/sp_seguimiento_diario_platino.out";
	--TRACE ON;

--InicializaciÃ³n de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cEmpresa                = "";
LET cCod_Ret                = "00000";
LET cruta                   = "";
LET cnombre					= "";
LET cdias					= "";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cnomarchivo2             = "";
LET cnomarchivo3			= "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cMensajeRet				= 'PROCESO EXITOSO';
LET cProceso                = '0083';
LET cCod_retBit             = '00000';
LET cdelimitador            = "";

BEGIN
    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensajeRet = error_info;            
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') Returning cCod_retBit;
        RETURN cCod_ret,cMensajeRet;
    END EXCEPTION;

    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_ret, cMensajeRet, '01') Returning cCod_retBit;
	
    --Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- Obtener la fecha del dia anterior
    --SELECT fecha_hoy INTO pFecha FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;
	SELECT fecha_ant INTO pFecha FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;
    IF pFecha IS NULL THEN
        LET cCod_Ret=  '20013';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 2 AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') Returning cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF

	-- Validacion de parÃ¡metros de entrada
    IF NVL(pEmpresa,"") = "" THEN
        LET cCod_Ret= '104001';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3  AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') Returning cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
	END IF;

	--ValidaciÃ³n de la empresa
    SELECT empresa INTO cEmpresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa;
    IF NVL (cEmpresa, '') = '' OR cEmpresa IS NULL THEN
        LET cCod_Ret= '104002';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') Returning cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;

	--Obtener caracter delimitador
	SELECT trim(valor_alfabetico) INTO cdelimitador FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
        AND tipo_campania = 61 AND grupo_parametro = 'ARCHIVOSEP' AND num_parametro = 336;
	IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') Returning cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
	END IF;

	--Obtener ruta del archivo
    SELECT trim(valor) INTO cruta FROM bdicred:"informix".sd_param where cod_param = '49';
    IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') Returning cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;
    
	--Obtener el nombre del archivo
    SELECT trim(valor) INTO cnombre FROM bdicred:"informix".sd_param where cod_param = '088';
    IF NVL (cnombre,'') = '' THEN
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = '104006';
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') Returning cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;
	
	--Obtener dias de ejecucion del archivo Estatus_TDC_Platino
	SELECT trim(valor) INTO cdias FROM bdicred:"informix".sd_param where cod_param = '146';
    IF NVL (cdias,'') = '' THEN
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = '102002';
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') Returning cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;

    --                 Obtiene la informacion de la Cartera de Tarjeta de Credito Platino                            -
    ------------------------------------------------------------------------------------------------------------------
    -- Credito |Estatus del Credito | Capital Vigente | Capital Transitorio | Vencido exigible | Vencido no exigible -- 

    -- Asigna nombre del archivo (reporte) 
    LET cnomarchivo =  trim(cnombre)||'Aux'||to_char(pFecha,'%d%m%Y')||'.txt';
    LET cnomarchivo1 =  trim(cnombre)||to_char(pFecha,'%d%m%Y')||'.txt';

    LET cSQL1='';
    LET cSQL1 = 'echo "Credito'||cdelimitador||'Estatus credito'||cdelimitador||'Capital vigente'||cdelimitador||'Capital transitorio'||cdelimitador
    ||'Vencido exigible'||cdelimitador|| 'Vencido no exigible' ||cdelimitador || '" >' ||TRIM(cruta)|| cnomarchivo1;
    SYSTEM cSQL1;

    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';  
    LET cSQL2 = " SELECT cred.num_credito, (case when cred.status_cred = 'AA' then 'VIGENTE'  "
        ||  "  when cred.status_cred = 'BA' then 'TRANSITORIO'  "
        ||  "  when cred.status_cred = 'BT' then 'VENCIDO'  "
        ||  "  when cred.status_cred = 'E1' then 'ETAPA 1'  "
        ||  "  when cred.status_cred = 'E2' then 'ETAPA 2'  "
		||  "  when cred.status_cred = 'E3' then 'ETAPA 3'  "
        ||  "  when cred.status_cred = 'CV' then 'VENDIDO'  "
		||  "  when cred.status_cred = 'FI' then 'CANCELADA SALDOS INMATERIALES'  "
        ||  "  when cred.status_cred = 'FC' then 'REESTRUCTURADO' else 'LIQUIDADO' end) estatus_credito, "
        ||  " dos.sdo_capital cap_vig, dos.monto_vencido cap_trans, dos.mto_venc_trasp vdo_exigible, dos.cap_tras_no_venci vdo_no_exigible "
        ||  " FROM bdicred:sd_maecred cred "
        ||  " JOIN bdicred:sd_maesdos dos ON (cred.num_credito = dos.num_credito and cred.num_producto = '7000') ";

    LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_GenArchTdcPlatino.sql';

    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    SYSTEM cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_GenArchTdcPlatino.sql';
    SYSTEM cSQL;

    LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta_GenArchTdcPlatino.sql';
    SYSTEM cSQL;

    LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || cnomarchivo || " >> " || TRIM(cRuta) || cnomarchivo1;
    SYSTEM cSql;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_GenArchTdcPlatino.sql';
    SYSTEM cSQL;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo;
    SYSTEM cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta) || cnomarchivo1;
    System cSQL;

	-- Se genera archivo Estatus_TDC_PlatinoDDMMYYYY.txt  para el area de productos RQM 10 1678 - AutomatizaciÃ³n Reporte Clientes TDC Platinum ELS
	SELECT fecha_hoy INTO pFecha FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;
	
	IF day(pFecha) = SUBSTR(cdias,1,2) or day(pFecha) = SUBSTR(cdias,4,4) THEN
        
		LET cnomarchivo2 =  'Estatus_'||trim(cnombre)||'Aux'||to_char(pFecha,'%d%m%Y')||'.txt';
		LET cnomarchivo3 =  'Estatus_'||trim(cnombre)||to_char(pFecha,'%d%m%Y')||'.txt';

		LET cSQL1='';
		LET cSQL1 = 'echo "Credito'||cdelimitador||'Num producto'||cdelimitador||'Num cliente'||cdelimitador||'Sucursal'||cdelimitador
		||'Fecha apertura'||cdelimitador|| 'Estatus cuenta' ||cdelimitador || '" >' ||TRIM(cruta)|| cnomarchivo3;
		SYSTEM cSQL1;

		LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo2) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';  
		LET cSQL2 = " SELECT cred.num_credito, num_producto , cred.numcte, cred.sucursal, cred.fecha_apertura, (case when cred.status_cred = 'AA' then 'VIGENTE'  "
			||  "  when cred.status_cred = 'BA' then 'TRANSITORIO'  "
			||  "  when cred.status_cred = 'BT' then 'VENCIDO'  "
			||  "  when cred.status_cred = 'E1' then 'ETAPA 1'  "
			||  "  when cred.status_cred = 'E2' then 'ETAPA 2'  "
			||  "  when cred.status_cred = 'E3' then 'ETAPA 3'  "
			||  "  when cred.status_cred = 'CV' then 'VENDIDO'  "
			||  "  when cred.status_cred = 'FI' then 'CANCELADA SALDOS INMATERIALES'  "
			||  "  when cred.status_cred = 'FC' then 'REESTRUCTURADO' else 'LIQUIDADO' end) estatus_credito "
			||  " FROM bdicred:sd_maecred cred "
			||  " JOIN bdicred:sd_maesdos dos ON (cred.num_credito = dos.num_credito and cred.num_producto = '7000') ";

		LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_GenArchTdcPlatinoEstatus.sql';

		LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
		SYSTEM cSQL;

		LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_GenArchTdcPlatinoEstatus.sql';
		SYSTEM cSQL;

		LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta_GenArchTdcPlatinoEstatus.sql';
		SYSTEM cSQL;

		LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || cnomarchivo2 || " >> " || TRIM(cRuta) || cnomarchivo3;
		SYSTEM cSql;

		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_GenArchTdcPlatinoEstatus.sql';
		SYSTEM cSQL;

		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo2;
		SYSTEM cSQL;

		LET cSQL='chmod 777 '|| TRIM(cRuta) || cnomarchivo3;
		System cSQL;
		
    END IF;

    LET cCod_Ret = '00000';
    LET cMensajeRet = 'PROCESO CONCLUIDO';

    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') Returning cCod_retBit;
    RETURN cCod_ret,cMensajeRet;

END;
END PROCEDURE;