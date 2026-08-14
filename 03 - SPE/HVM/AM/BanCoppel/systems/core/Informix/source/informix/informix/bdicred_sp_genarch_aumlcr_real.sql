CREATE PROCEDURE "informix".sp_genarch_aumlcr_real (pempresa CHAR(3), pfechacorte date)

RETURNING CHAR(6);

----------------------------------------------------------------------------------------------------------------
-- Creado por: Martha A. Hernandez 
-- 06 Octubre 2011
-- Proceso para la creacion del archivo con los aumentos de lcr aceptadoss por los clientes en el mes anterior
----------------------------------------------------------------------------------------------------------------

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE vproceso				CHAR(30);
DEFINE vprocesoIncLcr		CHAR(30);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cSQL                 CHAR(8204);
DEFINE cSQL1                CHAR(6204);
DEFINE cSQL2                CHAR(6204);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cCod_RetIB           CHAR(6);
DEFINE dFechaProcIni        DATE;
DEFINE dFechaProcFin        DATE;
DEFINE dFechaHoy            DATE;
DEFINE cCodRetMesAnt        CHAR(6);
DEFINE cFechaMesAnt         DATE;
DEFINE sDiasTransMesAnt     INT;


--SET DEBUG FILE TO "/informix/mahr/sp_genarch_aumlcr_real.out";
--TRACE ON;

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0021';  -- proceso de incrementos realizados en el mes previo.
LET vprocesoIncLcr			= '0104';  -- proceso de incremento de lcr preautorizado ( sp_cat_genarch_aumlincred ) (ant 0020)
LET cruta                   = "";
LET cnombre					= "";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = "";
LET cCod_RetIB              = "000000";
LET dFechaProcIni           = DATE(1);
LET dFechaProcFin           = DATE(1);
LET cCodRetMesAnt           = "";
LET sDiasTransMesAnt        = 0;

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
                Returning cCod_RetIB;
        RETURN cCod_ret;
    END EXCEPTION;
	
    --Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '01')
            Returning cCod_RetIB;

	-- Validacion de parámetros de entrada
    IF NVL(pEmpresa,"") = "" OR NVL(pfechacorte, "") = "" THEN
        LET cCod_Ret= "104001";

        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3  AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
            Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

	--Validación de la empresa
    SELECT empresa INTO cempresa
        FROM bdinteg:"informix".si_empresas WHERE empresa = pempresa;

        IF NVL (cempresa, '') = '' OR cempresa IS NULL THEN
        LET cCod_Ret= '104002';
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
            Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

    -- Obtiene las fechas para obtener la consulta de los datos entregados como preautorizados en el mes anterior.
    SELECT pri_dia_mes, fecha_hoy INTO dFechaProcIni, dFechaProcFin
      FROM bdinteg:"informix".si_fechas  WHERE empresa = pempresa;

    IF dFechaProcIni IS NULL OR dFechaProcFin IS NULL THEN
        LET cCod_Ret=  '20013';
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 2 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
            Returning cCod_RetIB;
        Return cCod_Ret;
    END IF
    LET dFechaHoy = dFechaProcFin; --dFechaHoy fecha de ejecucion y que lleve la fecha en el nombre del arch

    --LET dFechaProcIni = dFechaHoy - 1 UNITS MONTH;
    EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(dFechaHoy, -1 , day(dFechaHoy)) INTO cCodRetMesAnt, cFechaMesAnt, sDiasTransMesAnt;
    LET dFechaProcIni = cFechaMesAnt;

    LET dFechaProcIni = MDY(MONTH(dFechaProcIni),1, YEAR(dFechaProcIni)); -- 1er dia del mes anterior. 

            --obtiene la ultima fecha_OK de proceso de incrementos preautorizados del mes anterior.
    SELECT MAX(fecha_ejecucion) INTO dFechaProcFin FROM bdicobranza:"informix".cb_bitacora
        WHERE empresa = pempresa AND num_proceso = vprocesoIncLcr 
            AND (fecha_ejecucion >= dFechaProcIni AND fecha_ejecucion <= cFechaMesAnt ) --(dFechaHoy - 1 UNITS MONTH))
        AND cod_ret = '000000' and mensaje = 'PROCESO FINALIZADO';

    IF dFechaProcFin IS NULL THEN
            -- en caso de NO obtener la ultima fecha OK del mes anterior. Fecha fin = Hoy - 1 mes
        LET dFechaProcFin = cFechaMesAnt; -- dFechaHoy - 1 UNITS MONTH;
    END IF;
   
	--Obtener caracter delimitador  (mismo que el arch con el aum de lcr preautorizados)
    SELECT trim(valor_alfabetico)  INTO cdelimitador
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pempresa AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS' AND num_parametro = 26;   

                            --Valida que exista el caracter
	IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        
        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
            Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

	--Obtener ruta del archivo:  /resplogifx/archivoscartera/   (mismo que el arch con el aum de lcr preautorizados)
    SELECT TRIM(valor_alfabetico) INTO cruta
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pempresa AND tipo_campania = 1 
        AND grupo_parametro = 'ARCHIVOS' AND num_parametro = 36; 

                    --Valida que exista la carpeta
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion INTO cMensaje 
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3 AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
            Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

	--Obtener el nombre del archivo
    SELECT TRIM(valor_alfabetico) INTO cnombre
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pempresa AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS' AND num_parametro = 37; --

		--Validar que existe el archivo
    LET cnomarchivo1 =  trim(cnombre)||'Aux'||substr(year(dFechaHoy),3)||to_char(dFechaHoy,'%m%d')||'.txt';
    LET cnomarchivo =  trim(cnombre)||substr(year(dFechaHoy),3)||to_char(dFechaHoy,'%m%d')||'.txt';

	--se ejecuta para ponerle el encabezado
	LET cSql='';
    LET cSql = 'echo "cliente' || cdelimitador || 'tarjeta' || cdelimitador || 'lcr_anterior' || cdelimitador || 'lcr_actual' || 
                    cdelimitador || 'sucursal' || ' " >' ||TRIM(cruta)|| cnomarchivo;
	system csql;
	
	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';

    --      Cliente || Tarjeta || LCR Anterior || LCR Actual || Sucursal

    LET cSQL2 = " SELECT trim(aum.numcte) AS Cliente, substr(trim(t.num_tarjeta),13) AS Tarjeta, "
        || " aum.lincred_actual AS LCR_Anterior, dos.monto_otorgado AS LCR_actual, trim(aum.sucursal) AS Sucursal "
        || " FROM bdicred:sd_bitacora_aumlincred aum, "
        || " bdicred:sd_tarjeta t, "
        || " bdicred:sd_maesdos dos "
        || " WHERE "
        || " (aum.dfecha_cobranza >= mdy(" || month(dFechaProcIni) || "," || day(dFechaProcIni) || "," ||
                                       year(dFechaProcIni)
        || ") and aum.dfecha_cobranza <= mdy(" || month(dFechaProcFin) || "," || day(dFechaProcFin)
        || "," || year(dFechaProcFin) || ")) AND "
        || " aum.num_solicitud = t.num_credito AND "
--        || " aum.status = 'AP'  AND "
        || " aum.empresa = t.empresa AND aum.numcte = t.numcte AND "
        || " t.secuencia = (Select max(secuencia) from bdicred:sd_tarjeta "      
        || " Where empresa = aum.empresa and num_credito = aum.num_solicitud and "
        || " numcte = aum.numcte  and tipo_tarjeta = 'T' and status_tar = 'A' ) AND "
        || " dos.empresa = aum.empresa AND dos.num_credito = aum.num_solicitud ";
 

	LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_resp_aumlcr.sql';
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_resp_aumlcr.sql';
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta_resp_aumlcr.sql';
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;

	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_resp_aumlcr.sql';
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '03')
        Returning cCod_RetIB;

	RETURN cCod_ret;

END;
END PROCEDURE;