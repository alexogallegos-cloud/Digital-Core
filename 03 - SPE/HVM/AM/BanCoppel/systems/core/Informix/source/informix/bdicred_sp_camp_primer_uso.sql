CREATE PROCEDURE "informix".sp_camp_primer_uso(pempresa CHAR(3))
RETURNING CHAR(6);

--Creado: MAHR. Mayo 2012. Campaña de Primer uso. Campañas dirigidas a los clientes que no han realizad operaciones con su tarjeta de credito entregada.
-- Subcampaña: 2 LlamadaBienvenida, 3 CorreoDirecto, 4 CrediEfectivo, 5 Recomprensa, 6 LlamadaPreCanc, 7 PreCanc-1erBim, 8 PreCanc-2doBim, 
--  9 Ctas_por_cancelar, 10 cierre de numeros de campaña 9.


--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE iGenero_info         INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE vempresa				CHAR(3);
DEFINE vproceso				CHAR(4);
DEFINE cempresa             CHAR(3);
DEFINE cCod_RetIB           CHAR(6);
DEFINE dFechaHoy            DATE;
DEFINE dFecha_1_anio        DATE;
DEFINE sDia5_correcamp      SMALLINT;
DEFINE sDia21_correcamp     SMALLINT;
DEFINE sMessinactAnt        SMALLINT;
DEFINE cdelimitador         CHAR(1);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoejecsql   CHAR(100);
DEFINE cSQL                 CHAR(2500);
DEFINE cSQL1                CHAR(1000);
DEFINE cSQL2                CHAR(1000);
DEFINE cSQL3                CHAR(500);


--SET DEBUG FILE TO "/informix/gpe/sp_camp_primer_uso.out";
--TRACE ON;

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET iGenero_info            = 0;
LET error_info              = '';
LET cCod_Ret                = '000000';
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0600';
LET vempresa				= '001';
LET cempresa                = '';
LET cCod_RetIB              = '000000';
LET dFechaHoy               = DATE(1);
LET dFecha_1_anio           = DATE(1);
LET sDia5_correcamp         = 0; 
LET sDia21_correcamp        = 0; 
LET sMessinactAnt           = 0;
--LET iNum_tarjetas_ent       = 0;
LET cdelimitador            = '';
LET cruta                   = '';
LET cnombre                 = '';
LET cnomarchivo             = '';
LET cnomarchivo1			= '';
LET cnomarchivoejecsql      = '';
LET cSQL                    = '';
LET cSQL1                   = '';
LET cSQL2                   = '';
LET cSQL3                   = '';

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        RETURN cCod_ret;
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '01') Returning cCod_RetIB;

    -- Validacion de parámetros de entrada
    IF NVL(pEmpresa,"") = "" THEN
        LET cCod_Ret= '104001';
        SELECT descripcion INTO cMensaje 
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

	--Validación de la empresa
	SELECT empresa INTO cempresa
	FROM bdinteg:si_empresas WHERE empresa = pempresa;
	IF NVL (cempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        SELECT descripcion INTO cMensaje 
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN LET cMensaje = "";  END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

    -- Obtiene los dias en que se ejecuta este proceso para asignar el aviso correspondiente
    SELECT TRIM(valor_alfabetico)::SMALLINT, valor_numerico::SMALLINT INTO sDia5_correcamp, sDia21_correcamp
        FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 12;
    IF (NVL(sDia5_correcamp,0) = 0 OR NVL(sDia21_correcamp,0) = 0 ) THEN
        LET cCod_Ret= '104001';
        SELECT descripcion INTO cMensaje 
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = "";  END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        Return cCod_Ret;
    END IF;

    -- Obtiene la fecha del dia de hoy
   SELECT fecha_hoy INTO dFechaHoy FROM bdinteg:"informix".si_fechas WHERE empresa = pempresa;
	
    -- Campaña 2: LlamadaBienvenida: Se ejecuta dia 5 del mes
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN    

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch(vempresa, '02', 1, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;
    END IF;

   -- Campaña 3:  CorreoDirecto    Se ejecuta el dia 21 (despues del corte) de cada mes.
 IF (DAY(dFechaHoy) = sDia21_correcamp) OR (DAY(dFechaHoy) = sDia21_correcamp - 1) THEN   

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 14;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch(vempresa, '03', sMessinactAnt, dFechaHoy) Returning cCod_RetIB;

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;                    
    END IF;

   -- Campaña 4: CrediEfectivo     Se ejecuta dia 5 del mes
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 15;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch(vempresa, '04', sMessinactAnt, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;                    
    END IF;

    -- Campaña 5: Recomprensa       Se ejecuta los dias 21 de cada mes.
   IF (DAY(dFechaHoy) = sDia21_correcamp) OR (DAY(dFechaHoy) = sDia21_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 16;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch(vempresa, '05', sMessinactAnt, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;
    END IF;

    -- Campaña 6: Llamada de precancelacion     Se ejecuta dia 5 del mes
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 17;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch (vempresa, '06', sMessinactAnt, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero información y se creara el reporte de seguimiento
        END IF;
    END IF;

    -- Campaña 7: Seguimiento 1er Bimestre Pre-Cancelacion.
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 27;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch (vempresa, '07', sMessinactAnt, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;
    END IF;

    -- Campaña 8: Seguimiento 2do Bimestre Pre-Cancelacion.
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 37;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch (vempresa, '08', sMessinactAnt, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;
    END IF;

    -- Campaña 9: Cuentas por cancelar
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 38;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch (vempresa, '09', sMessinactAnt, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;
    END IF;

    -- Campaña 10: Cierre de cifras de campaña 9: Cuentas por cancelar, y genera de reporte de cuentas canceladas.
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt 
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 39;

        CALL bdicred:"informix".sp_camp_primer_uso_cierra9a10RepCanc (vempresa, '10', 0, dFechaHoy) Returning cCod_RetIB; 

         IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;
    END IF;

    -- GENERA REPORTE DE SEGUIMIENTO DE LAS CAMPAÑAS
    IF iGenero_info = 1 THEN
                --Obtener caracter delimitador
        SELECT trim(valor_alfabetico) INTO cdelimitador FROM bdicobranza:"informix".cb_param_campania WHERE empresa = pempresa
            AND tipo_campania = 1 AND grupo_parametro = 'ARCHIVOS' AND num_parametro = 26;
        IF NVL(cDelimitador,'') = '' THEN
            LET cCod_Ret= '104004';
            SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
            IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
            RETURN cCod_Ret;
        END IF;

        -- Obtiene la ruta del archivo
        SELECT TRIM(valor_alfabetico) INTO cruta FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
            AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 1; 
    	IF NVL (cruta,'') = '' THEN
            LET cCod_Ret= '104005';
            SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
            IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
            RETURN cCod_Ret;
        END IF;

    	-- Obtiene el nombre del archivo con el reporte de seguimiento.
        SELECT TRIM(valor_alfabetico) INTO cnombre FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
            AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 24; 
        IF NVL (cnombre,'') = '' THEN
            LET cCod_Ret= '102002';
            SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
            IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
            RETURN cCod_Ret;
    	END IF;

        -- Asigna nombre de archivo, segun el nombre asignado en el parametro y la fecha correspondiente
        LET cnomarchivo1 =  trim(cnombre)||'Aux'||substr(year(dFechaHoy),3)||to_char(dFechaHoy,'%m%d')||'.txt';
        LET cnomarchivo  =  trim(cnombre)||substr(year(dFechaHoy),3)||to_char( dFechaHoy,'%m%d')||'.txt';
        LET cnomarchivoejecsql = 'Ejecuta_rep_seguim_1er_uso.sql';

        LET cSql='';
        LET cSql = 'echo "fecha_campaña'||';'||'entregadas desde'||';'||'entregadas hasta'||';'||'nombre campaña'||';'||'tarjetas entregadas'
                         ||';'||'tarjetas_con_telefono'||';'||'tarjetas_sin_telefono'||';'||'tarjetas_activas_con_telefono'
						 ||';'||'tarjetas_activas_sin_telefono'||';'||'tarjetas_inactivas_con_telefono'||';'||'tarjetas_inactivas_sin_telefono'
						 ||';'||'tarjetas_actcontel_canceladas'||';'||'tarjetas_actsintel_canceladas'||';'||'tarjetas_inactcontel_canceladas'||';'||'tarjetas_inactsintelcanceladas'
						 || ' " >' ||TRIM(cruta)|| cnomarchivo;
        System csql;

        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
        --LET dFecha_1_anio = dFechaHoy - 2 units year;
		

        LET cSQL2 = " SELECT fecha_gen_campania, fecha_entreg_desde, fecha_entreg_hasta, trim(param.valor_alfabetico), tot_tarj_entreg_ina, "
                || " tot_tarj_contel,tot_tarj_sintel, tot_tarj_activas_contel, "
				|| " tot_tarj_activas_sintel,tot_tarj_inactivas_contel, tot_tarj_inactivas_sintel, "
				|| " tot_tarj_act_contel_canceladas,tot_tarj_act_sintel_canceladas,tot_tarj_inact_contel_canceladas,tot_tarj_inact_sintel_canceladas "
                || " FROM bdicred:cb_1eruso_rep_seguim seguim, bdicred:sd_param_campania param "
                || " WHERE param.grupo_parametro = 'ARCH1ERUSO' AND param.num_parametro in (18, 19, 20, 21, 22, 23, 40, 41, 42) "
                || " AND seguim.sub_campania = param.valor_numerico "
                || " AND seguim.fecha_gen_campania >= mdy(12,05,2015) "
                || " ORDER BY seguim.fecha_gen_campania, seguim.fecha_ejecucion, seguim.sub_campania ";

        LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoejecsql;
        LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
        System cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoejecsql;
        System cSQL;

        let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoejecsql;
        System cSQL;

        LET cSql = cSql;
        LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
        SYSTEM cSql;

    	LET cSQL = '' ;
    	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || ' ' || TRIM(cruta) || cnomarchivo1  ; 
        SYSTEM cSQL;

    END IF;

    -- Valida si existen las tablas temporales y las borra.
    IF EXISTS( SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'sd_temp_1er_uso_telef' ) THEN
        DROP TABLE bdicred:sd_temp_1er_uso_telef;
    END IF;
 
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '03')
        Returning cCod_RetIB;

	RETURN cCod_ret;

END;
END PROCEDURE;