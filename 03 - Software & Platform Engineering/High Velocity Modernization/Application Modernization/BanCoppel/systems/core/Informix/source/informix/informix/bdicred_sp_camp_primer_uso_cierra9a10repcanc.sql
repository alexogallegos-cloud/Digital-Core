CREATE PROCEDURE "informix".sp_camp_primer_uso_cierra9a10repcanc(pempresa CHAR(3), pServicio CHAR(2), pMessinact SMALLINT, pdFechaHoy DATE)

RETURNING CHAR(6);

--Creado: MAHR. Diciembre 2012 
-- Servicio 10-> Campaña;10 Cierre de cifras de campaña 9, y creacion de reporte de cuentas canceladas "automaticamente".


--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE vproceso				CHAR(4);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnombreTelef			CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivo_tel1     CHAR(100);
DEFINE cnomarchivo_tel      CHAR(100);
DEFINE cnomarchivoejecsql   CHAR(100);
DEFINE cSQL                 CHAR(8204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(3000);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cCod_RetIB           CHAR(6);
DEFINE cCod_Promocion       CHAR(3);
DEFINE dfecha_gen_camp      DATE;
DEFINE dfecha_ejec_camp     DATE;
DEFINE dfecha_ent_desde     DATE;
DEFINE dfecha_ent_hasta     DATE;
DEFINE sParamNombArch       SMALLINT;
DEFINE sParamNombArchTelef  SMALLINT;
DEFINE sParamRutaArch       SMALLINT;
DEFINE sNum_logica          SMALLINT;
DEFINE sNumCampania         SMALLINT;
DEFINE itot_tarj_inact      INTEGER;


--SET DEBUG FILE TO "sp_camp_primer_uso_cierra9a10repcanc.out";
--TRACE ON;

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = '000000';
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0601';
LET cruta                   = "";
LET cnombre					= "";
LET cnombreTelef            = "";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cnomarchivo_tel1        = "";
LET cnomarchivo_tel         = "";
LET cnomarchivoejecsql      = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "";
LET cdelimitador            = "";
LET cCod_RetIB              = '000000';
LET sParamNombArch          = 0;
LET sParamNombArchTelef     = 0;
LET sParamRutaArch          = 0;
LET sNumCampania            = 0;
LET cCod_Promocion          = "";
LET sNum_logica             = 0;
LET itot_tarj_inact         = 0;


BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, trim(cMensaje) || 'PROCESO' || pServicio, '02') Returning cCod_RetIB;
        RETURN cCod_ret;
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, 'PROCESO INICIALIZADO ' || pServicio , '02') Returning cCod_RetIB;

	-- Validacion de parámetros de entrada
	IF (NVL(pEmpresa,"") = "" OR NVL(pServicio, "") = "" OR pMessinact = 0 ) THEN
        LET cCod_Ret= '104001'; 
        SELECT descripcion INTO cMensaje
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje || pServicio, '02') Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

	--Validación de la empresa
	SELECT empresa INTO cempresa FROM bdinteg:si_empresas WHERE empresa = pempresa;
	IF NVL (cempresa, '') = '' THEN
        LET cCod_Ret = '104002';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje || pServicio, '02') Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;
  
	--Obtener caracter delimitador
	SELECT trim(valor_alfabetico) INTO cdelimitador FROM bdicobranza:"informix".cb_param_campania WHERE empresa = pempresa
        AND tipo_campania = 1 AND grupo_parametro = 'ARCHIVOS' AND num_parametro = 26;
	IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje || pServicio, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

    -- Asigna parametros con nombres de archivos y ruta, dependiendo del servicio (subcampaña).
    LET sParamRutaArch = 1;
    LET sParamNombArch = 43;
    LET sParamNombArchTelef = 44;
    LET sNumCampania = pServicio::SMALLINT; -- Asigna el numero de campaña en base al servicio


    -- Obtiene las fechas: Fecha de campaña, fecha entregada desde, fecha entregadas hasta de la campaña correspondiente para la campaña 2
        -- se realiza el calculo de manera distinta.
    LET dfecha_ejec_camp = pdFechaHoy - pMessinact units month; -- Se obtiene la fecha de campaña de la campaña anterior ejecutada en el mes calculado
    SELECT first 1 fecha_gen_campania, fecha_entreg_desde, fecha_entreg_hasta INTO dfecha_gen_camp, dfecha_ent_desde, dfecha_ent_hasta
        FROM bdicred:"informix".sd_camp_primer_uso WHERE month(fecha_ejecucion) = month(dfecha_ejec_camp)
        AND year(fecha_ejecucion) = year(dfecha_ejec_camp) AND num_campania = (sNumCampania - 1);
    IF dfecha_gen_camp IS NULL THEN     --  Termina proceso, ya que no existe campaña generada para esta fecha.
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, 'SIN CAMPAÑA ' || pServicio, '02') Returning cCod_RetIB;
        LET cCod_Ret = '000001';
        RETURN cCod_Ret;
    END IF;

    -- Obtiene la ruta del archivo
	SELECT TRIM(valor_alfabetico) INTO cruta FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
        AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = sParamRutaArch; 
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret = '104005';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje || pServicio, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

	-- Obtiene el nombre del archivo a generar con datos del cliente.
	SELECT TRIM(valor_alfabetico) INTO cnombre FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
        AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = sParamNombArch; 
	IF NVL (cnombre,'') = '' THEN
        LET cCod_Ret= '102002';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje || pServicio, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

	-- Obtiene el nombre del archivo de telefonos a generar.
	SELECT TRIM(valor_alfabetico) INTO cnombreTelef FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
       AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = sParamNombArchTelef; 
	IF NVL (cnombreTelef,'') = '' THEN
        LET cCod_Ret= '102002';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje || pServicio, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;


    -- Obtiene el codigo de la promocion y numero de logica de la misma.
    SELECT TRIM(valor_alfabetico) INTO cCod_Promocion FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'TIPO_PROM' AND num_parametro = 8;
    SELECT num_parametro INTO sNum_logica FROM sd_param_campania WHERE grupo_parametro = 'TIPOLOGICA' AND num_parametro = 8;


    -- Finaliza cifras de campaña 9 para medir efectividad.
    SELECT COUNT(a.num_credito) INTO itot_tarj_inact    --  Obtiene el total de tarjetas inactivas al momento 
        FROM bdicred:sd_camp_primer_uso a JOIN bdicred:sd_indicador_cred ind on ( a.empresa = ind.empresa and a.num_credito = ind.num_credito) 
																							   
																																															  
        JOIN bdicred:sd_maecred cred ON ( a.empresa = cred.empresa and a.num_credito = cred.num_credito and cred.status_cred IN ('AA','E1')) 
        WHERE a.empresa = pempresa
        AND a.fecha_gen_campania = dfecha_gen_camp AND a.fecha_entreg_desde = dfecha_ent_desde AND a.fecha_entreg_hasta = dfecha_ent_hasta
        AND a.num_campania = (sNumCampania - 1) 
        AND a.status_tarj = 'INACT'
        AND ( ind.f_primer_compra IS NULL OR ind.f_primer_compra = date(1) )
        AND ( ind.f_primer_disp IS NULL OR ind.f_primer_disp = date(1) );


    -- Se actualizan datos de la campaña anterior. Las inactivas restantes de la campaña anterior = Las entregadas de esta campaña
    UPDATE bdicred:cb_1eruso_rep_seguim SET tot_tarj_inactivas = itot_tarj_inact, tot_tarj_activas = (tot_tarj_entregadas - itot_tarj_inact),
                porcentaje_efec = (((tot_tarj_entregadas - itot_tarj_inact) / tot_tarj_entregadas) * 100)::INTEGER
        WHERE fecha_gen_campania = dfecha_gen_camp AND fecha_entreg_desde = dfecha_ent_desde AND fecha_entreg_hasta = dfecha_ent_hasta 
		  AND sub_campania = (sNumCampania - 1); 


    -- Genera el ARCHIVO con los datos de los clientes a partir de los almacenado. Asigna nombre de archivo, segun parametro y la fecha correspondiente
    LET cnomarchivo1 =  trim(cnombre)||'Aux'||substr(year(pdFechaHoy),3)||to_char(pdFechaHoy,'%m%d')||'.txt';
    LET cnomarchivo  =  trim(cnombre)||substr(year(pdFechaHoy),3)||to_char( pdFechaHoy,'%m%d')||'.txt';
    LET cnomarchivoejecsql = 'Ejecuta_gen_arch_Camp_primer_uso.sql';
    LET cSql='';
    LET cSql = 'echo "tipo_promocion'||';'||'tipo_logica'||';'||'fecha_insercion'||';'||'num_credito'||';'||'sucursal'||';'||'num_cliente'||';'
            ||'no_tarjeta'||';'|| 'status_prom'||';'||'prioridad'||';'||'ap_paterno'||';'||'ap_materno' ||';'|| 'primer_nombre' ||';'
            ||'segundo_nombre'||';'|| 'sexo' ||';'|| 'estado_civil' ||';'|| 'email' ||';'|| 'estado' ||';'|| 'municipio/delegacion' ||';'
            || ' " >' ||TRIM(cruta)|| cnomarchivo;
    SYSTEM csql;


    -- Genera el ARCHIVO con los telefonos de los clientes. Asigna nombre de archivo, segun parametro y la fecha correspondiente
    LET cnomarchivo_tel1 =  trim(cnombreTelef)|| 'Aux'|| substr(year(pdFechaHoy),3) || to_char(pdFechaHoy,'%m%d') || '.txt';
    LET cnomarchivo_tel  =  trim(cnombreTelef)|| substr(year(pdFechaHoy),3) || to_char(pdFechaHoy,'%m%d') || '.txt';
    LET cSql='';
    LET cSql = 'echo "Num_Credito'||';'||'num_cliente'||';'||'tipo_telefono'||';'||'tipo_red'||';'||'telefono_original'||';'
            ||'telefono_reconstruido'||';'  ||'carrier'||';'|| 'extension' ||';' || ' " >' ||TRIM(cruta)|| cnomarchivo_tel;
    SYSTEM csql;

	
    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; ';
                                                            -- Se obtienen los registros de los clientes y sus telefonos 
    LET cSQL2 = " SELECT '" || pempresa || "' as empresa, '" || cCod_Promocion || "' as Cod_prom, '" || sNum_logica::CHAR || "' as logica, " 
            || " a.fecha_gen_campania, a.num_credito, a.sucursal, a.numcte, a.num_tarjeta, a.statusprom, a.prioridad, a.ap_paterno, a.ap_materno, "
            || " a.primer_nombre, a.segundo_nombre, a.sexo, a.estado_civil, a.email, a.estado, a.ciudad, a.fecha_apertura, '0' as stat "
            || " FROM bdicred:sd_camp_primer_uso a JOIN bdicred:sd_indicador_cred ind on ( a.empresa = ind.empresa and a.num_credito = ind.num_credito) "
																										
            || " JOIN bdicred:sd_maecred cred ON ( a.empresa = cred.empresa and a.num_credito = cred.num_credito and cred.status_cred IN ('AA','E1')) " 
            || " WHERE a.empresa = '" || pempresa || "'"
            || " AND a.fecha_gen_campania = '" || dfecha_gen_camp ||"' AND a.fecha_entreg_desde  = '"||dfecha_ent_desde
            || "' AND a.fecha_entreg_hasta = '" || dfecha_ent_hasta ||"'"
            || " AND a.num_campania = " || (sNumCampania - 1) 
            || " AND a.status_tarj = 'INACT' "
            || " AND ( ind.f_primer_compra IS NULL OR ind.f_primer_compra = date(1) ) "
            || " AND ( ind.f_primer_disp IS NULL OR ind.f_primer_disp = date(1) ) "
            || " INTO temp temp_clientes_1eruso with no log; "
            || " CREATE INDEX ix_ctes_1eruso on temp_clientes_1eruso (empresa, numcte); "
            || " UPDATE STATISTICS medium FOR TABLE temp_clientes_1eruso;       "       -- Marca los clientes que no tienen telefono..
            || " SELECT prim.num_credito as num_credito, prim.numcte as numcte, tel.tipo_tel::CHAR as tipo_tel, "
            || " decode(tel.tipo_tel,1,'F',3,'F','M') as tipo_red, substr(tel.telefono,length(tel.telefono)-9,10) as telefono_original, "
            || " substr(tel.telefono,length(tel.telefono)-9,10) as telefono_Reconstruido, NVL(tel.carrier,'') as carrier, NVL(tel.extension, '') as extension "
            || " FROM temp_clientes_1eruso prim JOIN bdinteg:si_telefonos_actual tel ON (prim.empresa = tel.empresa AND prim.numcte = tel.numcte ) "
            || " WHERE tel.status_tel = 'A' AND tel.cofetel = 'V' AND trim(tel.telefono) <> '' "
            || " INTO temp temp_telefonos with no log;      " 
            || " UPDATE temp_clientes_1eruso SET stat = '1' WHERE numcte NOT IN (Select numcte from temp_telefonos group by numcte );       "
            || " UNLOAD TO " || TRIM(cruta) || TRIM(cnomarchivo1) || " DELIMITER '" || cdelimitador || "' "
            || " SELECT Cod_prom, logica, fecha_gen_campania, num_credito, sucursal, numcte, num_tarjeta, "
            || " statusprom, prioridad, ap_paterno, ap_materno, primer_nombre, segundo_nombre, sexo, estado_civil, email, estado, ciudad "
            || " FROM temp_clientes_1eruso "
            || " WHERE stat = '0' "
            || " ORDER BY prioridad, fecha_apertura ASC; "
            || " UNLOAD TO " || TRIM(cruta) || TRIM(cnomarchivo_tel1) || " DELIMITER '" || cdelimitador || "' "
            || " SELECT * from temp_telefonos ORDER BY num_credito; ";


    LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoejecsql;
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    SYSTEM cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoejecsql;
    SYSTEM cSQL;

    LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoejecsql;
    SYSTEM cSQL;

    LET cSql = "";
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;

    LET cSql = "";
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo_tel1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo_tel);
    SYSTEM cSql;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || '  ' || TRIM(cruta) || cnomarchivo1 || '  ' || TRIM(cRuta) || TRIM(cnomarchivo_tel1);
    SYSTEM cSQL;

    --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, 'PROCESO INICIALIZADO ' || pServicio, '02') Returning cCod_RetIB;

	RETURN cCod_ret;

END;
END PROCEDURE;