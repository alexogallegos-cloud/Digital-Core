CREATE PROCEDURE "informix".sp_camp_tdc_inactivas_nuncas(pempresa CHAR(3))

RETURNING CHAR(6);

--Creado: MAHR. Julio 2013.- Creacion de campaña de Tarjetas Inactivas y Nuncas.
-- Febrero 2016: MAHR.- Se cancela la creación de las campañas Nuncas, a solicitud del usuario, ya que debido a las condiciones de la misma, ya no existen
--                      registros que formen parte de ellas.

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE iDiasTrans           INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE vproceso				CHAR(4);
DEFINE cCod_RetIB           CHAR(6);
DEFINE cempresa             CHAR(3);
DEFINE sDia_Eje_Camp        SMALLINT;
DEFINE dFechaHoy            DATE;
DEFINE dFechaIniMes         DATE;
DEFINE dFechaFinMesAnt      DATE;
DEFINE dFecha6meses         DATE;
DEFINE sMessinactAnt        SMALLINT;
DEFINE iDiasInact           SMALLINT;
DEFINE cdelimitador         CHAR(1);
DEFINE cruta                CHAR(100);
DEFINE cNombreInac  		CHAR(100);
DEFINE cNombreNunc  		CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoejecsql   CHAR(100);
DEFINE cSQL                 CHAR(2500);
DEFINE cSQL1                CHAR(1000);
DEFINE cSQL2                CHAR(1000);
DEFINE cSQL3                CHAR(500);

--SET DEBUG FILE TO "/informix/sp_camp_tdc_inactivas_nuncas.out";
--TRACE ON;

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET iDiasTrans              = 0;
LET error_info              = '';
LET cCod_Ret                = '000000';
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0504';
LET cCod_RetIB              = '000000';
LET cempresa                = '';
LET sDia_Eje_Camp           = 0; 
LET dFechaHoy               = DATE(1);
LET dFechaIniMes            = DATE(1);
LET dFechaFinMesAnt         = DATE(1);
LET dFecha6meses            = DATE(1);
LET sMessinactAnt           = 0;
LET iDiasInact              = 0;
LET cdelimitador            = '';
LET cruta                   = '';
LET cNombreInac             = '';
LET cNombreNunc             = '';
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
        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje||'-'||isam_err::CHAR , '02') Returning cCod_RetIB;
        RETURN cCod_ret;
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje, '01') Returning cCod_RetIB;

    -- Validacion de parámetros de entrada
    IF NVL(pempresa,"") = "" THEN
        LET cCod_Ret= '104001';
        SELECT descripcion INTO cMensaje 
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje||'-'||isam_err::CHAR , '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

	--Validación de la empresa
	SELECT empresa INTO cempresa FROM bdinteg:si_empresas WHERE empresa = pempresa;
	IF NVL (cempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        SELECT descripcion INTO cMensaje 
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = "";  END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje||'-'||isam_err::CHAR , '02') Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

    -- Obtiene los dias en que se ejecuta este proceso. Se ejecuta los dias 5 de c/mes.
    SELECT valor_numerico INTO sDia_Eje_Camp FROM bdicred:"informix".sd_param_campania 
        WHERE empresa = pempresa AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 1;
    IF (NVL(sDia_Eje_Camp,0) = 0 ) THEN
        LET cCod_Ret= '104001';
        SELECT descripcion INTO cMensaje 
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = "";  END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje||'-'||isam_err::CHAR , '02') Returning cCod_RetIB;
        Return cCod_Ret;
    END IF;

    -- Obtiene la fecha del dia de hoy
    SELECT fecha_hoy, pri_dia_mes INTO dFechaHoy, dFechaIniMes FROM bdicred:"informix".sd_fechas WHERE empresa = pempresa;
	LET dFechaFinMesAnt = dFechaIniMes - 1 units day;

    -- Calcula fecha previa ( 6 meses antes )
    SELECT NVL(valor_numerico,0) INTO iDiasInact FROM bdicred:"informix".sd_param_campania WHERE empresa = pEmpresa 
       AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 25;

    EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(dFechaHoy, iDiasInact , day(dFechaHoy)) INTO cCod_RetIB, dFecha6meses, iDiasTrans;


    --IF (DAY(dFechaHoy) = sDia_Eje_Camp) OR (DAY(dFechaHoy) = sDia_Eje_Camp - 1) THEN

        --------------------- Campaña 1: Llamada de seguimiento ---------------------
        LET sMessinactAnt = 0;
        SELECT valor_numerico::SMALLINT INTO sMessinactAnt FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa 
            AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 8;

        /*IF NVL(sMessinactAnt, 0 ) != 0 THEN
            CALL bdicred:"informix".sp_camp_tdc_inact_nunc_crea_camp(pempresa, 'INA', '01', sMessinactAnt, dFechaHoy, dFecha6meses) Returning cCod_RetIB; 

            --CALL bdicred:"informix".sp_camp_tdc_inact_nunc_crea_camp(pempresa, 'NUN', '01', sMessinactAnt, dFechaHoy, dFecha6meses) Returning cCod_RetIB; 
        ELSE
            CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, 'Parametros incorrectos - Duracion Campaña 1.', '02') Returning cCod_RetIB;
        END IF;         -  Se elimina creacion de campañas inactivas Ene 2018 -  */


        --------------------- Campaña 2: Credisoluciones --------------------- 
        LET sMessinactAnt = 0;
        SELECT valor_numerico::SMALLINT INTO sMessinactAnt FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa 
            AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 9;

        /*IF NVL(sMessinactAnt,0) != 0 THEN
            CALL bdicred:"informix".sp_camp_tdc_inact_nunc_crea_camp(pempresa, 'INA', '02', sMessinactAnt, dFechaHoy, dFecha6meses) Returning cCod_RetIB; 

            --CALL bdicred:"informix".sp_camp_tdc_inact_nunc_crea_camp(pempresa, 'NUN', '02', sMessinactAnt, dFechaHoy, dFecha6meses) Returning cCod_RetIB; 
        ELSE
            CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, 'Parametros incorrectos - Duracion Campaña 2.', '02') Returning cCod_RetIB;
        END IF;         -  Se elimina creacion de campañas inactivas  -  */


        --------------------- Campaña 3: Promociones temporada 3 --------------------- 
        LET sMessinactAnt = 0;
        SELECT valor_numerico::SMALLINT INTO sMessinactAnt FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa 
            AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 10;

        /*IF NVL(sMessinactAnt,0) != 0 THEN
            CALL bdicred:"informix".sp_camp_tdc_inact_nunc_crea_camp(pempresa, 'INA', '03', sMessinactAnt, dFechaHoy, dFecha6meses) Returning cCod_RetIB; 

            --CALL bdicred:"informix".sp_camp_tdc_inact_nunc_crea_camp(pempresa, 'NUN', '03', sMessinactAnt, dFechaHoy, dFecha6meses) Returning cCod_RetIB; 
        ELSE
            CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, 'Parametros incorrectos - Duracion Campaña 3.', '02') Returning cCod_RetIB;
        END IF;         -  Se elimina creacion de campañas inactivas  -  */


        --------------------- Campaña 4: Promociones temporada 4 --------------------- 
        LET sMessinactAnt = 0;
        SELECT valor_numerico::SMALLINT INTO sMessinactAnt FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa 
            AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 11;

        /*IF NVL(sMessinactAnt,0) != 0 THEN
            CALL bdicred:"informix".sp_camp_tdc_inact_nunc_crea_camp(pempresa, 'INA', '04', sMessinactAnt, dFechaHoy, dFecha6meses) Returning cCod_RetIB; 

            ---CALL bdicred:"informix".sp_camp_tdc_inact_nunc_crea_camp(pempresa, 'NUN', '04', sMessinactAnt, dFechaHoy, dFecha6meses) Returning cCod_RetIB; 
        ELSE
            CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, 'Parametros incorrectos - Duracion Campaña 4.', '02') Returning cCod_RetIB;
        END IF;         -  Se elimina creacion de campañas inactivas  -  */


        --------------------- Campaña 5: Promociones temporada 5 --------------------- 
        LET sMessinactAnt = 0;
        SELECT valor_numerico::SMALLINT INTO sMessinactAnt FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa 
            AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 12;

        /*IF NVL(sMessinactAnt,0) != 0 THEN
            CALL bdicred:"informix".sp_camp_tdc_inact_nunc_crea_camp(pempresa, 'INA', '05', sMessinactAnt, dFechaHoy, dFecha6meses) Returning cCod_RetIB; 

            --CALL bdicred:"informix".sp_camp_tdc_inact_nunc_crea_camp(pempresa, 'NUN', '05', sMessinactAnt, dFechaHoy, dFecha6meses) Returning cCod_RetIB; 
        ELSE
            CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, 'Parametros incorrectos - Duracion Campaña 5.', '02') Returning cCod_RetIB;
        END IF;         -  Se elimina creacion de campañas inactivas  -  */


        --------------------- Campaña 6: Pre-Cancelacion --------------------- 
        LET sMessinactAnt = 0;
        SELECT valor_numerico::SMALLINT INTO sMessinactAnt FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa 
            AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 13;

        /*IF NVL(sMessinactAnt,0) != 0 THEN
            CALL bdicred:"informix".sp_camp_tdc_inact_nunc_crea_camp(pempresa, 'INA', '06', sMessinactAnt, dFechaHoy, dFecha6meses) Returning cCod_RetIB; 

            --CALL bdicred:"informix".sp_camp_tdc_inact_nunc_crea_camp(pempresa, 'NUN', '06', sMessinactAnt, dFechaHoy, dFecha6meses) Returning cCod_RetIB; 
        ELSE
            CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, 'Parametros incorrectos - Duracion Campaña 6.', '02') Returning cCod_RetIB;
        END IF;         -  Se elimina creacion de campañas inactivas  -  */

        --------------------- Campaña 7: Cierra campaña 6 --------------------- 
        LET sMessinactAnt = 0;
        SELECT valor_numerico::SMALLINT INTO sMessinactAnt FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa 
            AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 26;

        /*IF NVL(sMessinactAnt, 0 ) != 0 THEN
            CALL bdicred:"informix".sp_camp_tdc_inact_nunc_crea_camp(pempresa, 'INA', '07', sMessinactAnt, dFechaHoy, dFecha6meses) Returning cCod_RetIB; 

            --CALL bdicred:"informix".sp_camp_tdc_inact_nunc_crea_camp(pempresa, 'NUN', '07', sMessinactAnt, dFechaHoy, dFecha6meses) Returning cCod_RetIB; 
        ELSE
            CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, 'Parametros incorrectos - Duracion Campaña 7.', '02') Returning cCod_RetIB;
        END IF;         -  Se elimina creacion de campañas inactivas  -  */


        -----------------------------------------------------------------------------------------
        --------------------- GENERA REPORTE DE SEGUIMIENTO DE LAS CAMPAÑAS ---------------------
                --Obtener caracter delimitador
        SELECT trim(valor_alfabetico) INTO cdelimitador FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa 
            AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 14;
        IF NVL(cDelimitador,'') = '' THEN
            LET cCod_Ret= '104004';
            SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
            IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
            CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje||'-'||isam_err::CHAR , '02') Returning cCod_RetIB;
            RETURN cCod_Ret;
        END IF;

        -- Obtiene la ruta del archivo
        SELECT TRIM(valor_alfabetico) INTO cruta FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
            AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 1; 
        IF NVL (cruta,'') = '' THEN
            LET cCod_Ret= '104005';
            SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
            IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
            CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje||'-'||isam_err::CHAR , '02') Returning cCod_RetIB;
            RETURN cCod_Ret;
        END IF;

        -- Obtiene el nombre del archivo del reporte de seguimiento - Tarjetas Inactivas.
        SELECT TRIM(valor_alfabetico) INTO cNombreInac  FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
            AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 23; 
        IF NVL (cNombreInac,'') = '' THEN
            LET cCod_Ret= '102002';
            SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
            IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
            CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje||'-'||isam_err::CHAR , '02') Returning cCod_RetIB;
            RETURN cCod_Ret;
        END IF;

    	-- Obtiene el nombre del archivo del reporte de seguimiento - Tarjetas Nuncas.
        SELECT TRIM(valor_alfabetico) INTO cNombreNunc  FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
            AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 24; 
        IF NVL (cNombreNunc,'') = '' THEN
            LET cCod_Ret= '102002';
            SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
            IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
            CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje||'-'||isam_err::CHAR , '02') Returning cCod_RetIB;
            RETURN cCod_Ret;
    	END IF;

        ------------------------------
        -- Reporte TARJETAS INACTIVAS. 
        ------------------------------
        LET cnomarchivoejecsql = 'Ejecuta_rep_camp_inactivas.sql';
        LET cnomarchivo1 =  trim(cNombreInac)||'_Aux_'|| lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || substr(year(dFechaHoy),3,4) || '.txt';
        LET cnomarchivo  =  trim(cNombreInac)|| '_' || lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || substr(year(dFechaHoy),3,4) || '.txt';

        LET cSql='';
        LET cSql = 'echo "Fecha campaña'||';'||'Inactivas Desde'||';'||'Inactivas Hasta'||';'||'Nombre Campaña'||';'||'Tarjetas Inactivas'
                         ||';'||'Tarjetas Activas'||';'||'Tarjetas Remanentes'||';'||'% Efectividad'|| ' " >' ||TRIM(cruta)|| cnomarchivo;
        SYSTEM csql;

        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';

        LET cSQL2 = " SELECT rep.fecha_gen_campania, rep.fecha_entreg_desde, rep.fecha_entreg_hasta, trim(param.valor_alfabetico), "
                || " rep.tot_tarj_entregadas, rep.tot_tarj_activas, rep.tot_tarj_inactivas, rep.porcentaje_efec "
                || " FROM bdicred:sd_camp_inactiv_nuncas_reporte rep JOIN bdicred:sd_param_campania param "
                || "   ON ( rep.num_sub_campania = param.valor_numerico AND rep.tipo_campania = 'INA' ) "
                || " WHERE param.grupo_parametro = 'CAMPINCNUN' AND param.num_parametro in (2, 3, 4, 5, 6, 7) "
                || " ORDER BY rep.fecha_gen_campania, rep.fecha_ejecucion, rep.num_sub_campania ";

        LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoejecsql;
        LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
        SYSTEM cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoejecsql;
        SYSTEM cSQL;

        let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoejecsql;
        SYSTEM cSQL;

        LET cSql = cSql;
        LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
        SYSTEM cSql;

    	LET cSQL = '' ;
    	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || ' ' || TRIM(cruta) || cnomarchivo1  ; 
        SYSTEM cSQL;

        
        ---------------------------
        -- Reporte TARJETAS NUNCAS.
        -- SE CANCELA LA CREACION DE ESTE REPORTE, YA QUE LAS CAMPAÑAS YA NO SE GENERARAN
        ---------------------------
        /*LET cnomarchivoejecsql = 'Ejecuta_rep_camp_nuncas.sql';
        LET cnomarchivo1 =  trim(cNombreNunc)||'_Aux_'|| lpad(day(dFechaHoy),2,'0')||lpad(month(dFechaHoy),2,'0')||substr(year(dFechaHoy),3,4) ||'.txt';
        LET cnomarchivo  =  trim(cNombreNunc)|| '_' || lpad(day(dFechaHoy),2,'0')||lpad(month(dFechaHoy),2,'0')||substr(year(dFechaHoy),3,4) ||'.txt';
        
        LET cSql='';
        LET cSql = 'echo "Fecha campaña'||';'||'Nunca Desde'||';'||'Nunca Hasta'||';'||'Nombre Campaña'||';'||'Tarjetas Nunca'
                         ||';'||'Tarjetas Activas'||';'||'Tarjetas Remanentes'||';'||'% Efectividad'|| ' " >' ||TRIM(cruta)|| cnomarchivo;
        SYSTEM csql;

        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';

        LET cSQL2 = " SELECT rep.fecha_gen_campania, rep.fecha_entreg_desde, rep.fecha_entreg_hasta, trim(param.valor_alfabetico), "
                || " rep.tot_tarj_entregadas, rep.tot_tarj_activas, rep.tot_tarj_inactivas, rep.porcentaje_efec "
                || " FROM bdicred:sd_camp_inactiv_nuncas_reporte rep JOIN bdicred:sd_param_campania param "
                || " ON ( rep.num_sub_campania = param.valor_numerico AND rep.tipo_campania = 'NUN' ) " 
                || " WHERE param.grupo_parametro = 'CAMPINCNUN' AND param.num_parametro in (2, 3, 4, 5, 6, 7) "
                || " ORDER BY rep.fecha_gen_campania, rep.fecha_ejecucion, rep.num_sub_campania "; 

        LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoejecsql;
        LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
        SYSTEM cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoejecsql;
        SYSTEM cSQL;

        let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoejecsql;
        SYSTEM cSQL;

        LET cSql = cSql;
        LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
        SYSTEM cSql;

    	LET cSQL = '' ;
    	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || ' ' || TRIM(cruta) || cnomarchivo1  ; 
        SYSTEM cSQL;*/

        ------------------------------------------------
        -- CONCENTRADO REPORTE DE CUENTAS INACTIVAS
        ------------------------------------------------

        LET cSQL = ''; LET cSQL1 = ''; LET cSQL2 = ''; LET cSQL3 = '';

        LET cnomarchivoejecsql = 'Ejecuta_rep_conc_inac.sql';
        LET cnomarchivo1 =  trim(cNombreInac)||'_CONC_Aux_'|| lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || substr(year(dFechaHoy),3,4) || '.txt';
        LET cnomarchivo  =  trim(cNombreInac)|| '_CONCENTRADO_' || lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || substr(year(dFechaHoy),3,4) || '.txt';

        LET cSql='';
        LET cSql = 'echo "Año de activacion'||';'||'Mes'||';'||'Numero de tarjetas'|| ' " >' ||TRIM(cruta)|| cnomarchivo;
        SYSTEM csql;

        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';

        LET cSQL2 = " SELECT year(cred.fecha_apertura), month(cred.fecha_apertura), count(cred.num_credito) "
                || " FROM bdicred:sd_maecred cred, bdicred:sd_indicador_cred_hist ind, bdicred:sd_maesdos dos "
                || " WHERE cred.empresa = ind.empresa AND cred.num_credito = ind.num_credito AND cred.status_cred IN ('AA','E1') "
                || " AND cred.fecha_apertura < '" || dFechaIniMes || "'"
                || " AND ind.fecha_ultima_compra <= '" || dFecha6meses || "'"
                || " AND ind.fecha_ultimo_pago <= '" || dFecha6meses || "'" 
                || " AND nvl(ind.fecha_ultima_compra, date(1)) != date(1) "
                || " AND ind.fecha = '" || dFechaFinMesAnt || "'"
                || " AND cred.empresa = dos.empresa AND cred.num_credito = dos.num_credito AND dos.sdo_cap_insoluto <= 0 "
                || " GROUP BY 1,2 ORDER BY 1,2 ";

        LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoejecsql;
        LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
        SYSTEM cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoejecsql;
        SYSTEM cSQL;

        let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoejecsql;
        SYSTEM cSQL;

        LET cSql = cSql;
        LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
        SYSTEM cSql;

    	LET cSQL = '' ;
    	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || ' ' || TRIM(cruta) || cnomarchivo1  ; 
        SYSTEM cSQL;


        ------------------------------------------------
        -- CONCENTRADO REPORTE DE CUENTAS NUNCAS
        -- SE CANCELA LA CREACION DE ESTE REPORTE, YA QUE LAS CAMPAÑAS YA NO SE GENERARAN
        ------------------------------------------------

        LET cSQL = ''; LET cSQL1 = ''; LET cSQL2 = ''; LET cSQL3 = '';

        LET cnomarchivoejecsql = 'Ejecuta_rep_conc_nunca.sql';
        LET cnomarchivo1 =  trim(cNombreNunc)||'_CONC_Aux_'|| lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || substr(year(dFechaHoy),3,4) || '.txt';
        LET cnomarchivo  =  trim(cNombreNunc)|| '_CONCENTRADO_' || lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || substr(year(dFechaHoy),3,4) || '.txt';

        LET cSql='';
        LET cSql = 'echo "Año de activacion'||';'||'Mes'||';'||'Numero de tarjetas'|| ' " >' ||TRIM(cruta)|| cnomarchivo;
        SYSTEM csql;

        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';

        LET cSQL2 = " SELECT year(cred.fecha_apertura), month(cred.fecha_apertura), count(cred.num_credito) "
                    || " FROM bdicred:sd_maecred cred, bdicred:sd_indicador_cred_hist ind, bdicred:sd_maesdos dos "
                    || " WHERE cred.empresa = ind.empresa AND cred.num_credito = ind.num_credito AND cred.status_cred IN ('AA','E1') "
                    || " AND cred.fecha_apertura < '" || dFechaIniMes || "'"
                    || " AND nvl(ind.fecha_ultima_compra, date(1)) = date(1) "
                    || " AND ind.fecha = '" || dFechaFinMesAnt || "'"
                    || " AND cred.empresa = dos.empresa AND cred.num_credito = dos.num_credito AND dos.sdo_cap_insoluto <= 0 " 
                    || " GROUP BY 1,2  ORDER BY 1,2 ";

        LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoejecsql;
        LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
        SYSTEM cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoejecsql;
        SYSTEM cSQL;

        let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoejecsql;
        SYSTEM cSQL;

        LET cSql = cSql;
        LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
        SYSTEM cSql;

    	LET cSQL = '' ;
    	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || ' ' || TRIM(cruta) || cnomarchivo1  ; 
        SYSTEM cSQL;



    --ELSE
    --    CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, 'Dia erroneo de ejecución.', '02') Returning cCod_RetIB;
    --END IF;

    CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje, '03') Returning cCod_RetIB;

	RETURN cCod_ret;

END;
END PROCEDURE;