CREATE PROCEDURE "informix".sp_reporte_ppcoppel()
RETURNING CHAR(5), CHAR(40);

    -- ****************************************************************************
    -- *                        DEFINICION DE VARIABLES                           *
    -- ****************************************************************************

    DEFINE v_cod_ret        CHAR(5);
    DEFINE vsqlerr          INTEGER;

    DEFINE iDia             INTEGER;
    DEFINE cQuery           CHAR(1000);
    DEFINE pArchDescarga    CHAR(100);
    DEFINE cSQL1            CHAR(200);
    DEFINE cnom_Sql         CHAR(100);

    DEFINE sDia             CHAR(2);
    DEFINE sMes             CHAR(2);
    DEFINE sMesArc          CHAR(2);

    DEFINE sYear            CHAR(4);

    DEFINE p_fecha          DATE;
    DEFINE p_fecha_ini      DATE;
    DEFINE p_fecha_ini_ayer DATE;
    DEFINE p_fecha_fin      DATE;

    DEFINE sFechaArch       CHAR(10);
    DEFINE sFechaCons       CHAR(10);
    DEFINE iFinMes          INTEGER;
    DEFINE sRuta_tabla      CHAR(200);
    DEFINE sMensaje         CHAR(40);
    DEFINE sMensajeStatus   CHAR(20);

    -- ****************************************************************************
    -- *                        ASIGNACION DE VARIABLES                           *
    -- ****************************************************************************

    LET v_cod_ret               = "00000";
    LET vsqlerr                 = 0;

    LET iDia                    = 0;
    LET cQuery                  = "";
    LET pArchDescarga           = "";
    LET cSQL1                   = "";

    LET cnom_Sql                = "";
    LET sDia                    = "";
    LET sMes                    = "";
    LET sMesArc                 = "";

    LET sYear                   = "";

    LET p_fecha                 = '';
    LET p_fecha_ini             = '';
    LET p_fecha_ini_ayer        = '';
    LET p_fecha_fin             = '';

    LET sFechaArch              = "";
    LET sFechaCons              = "";
    LET iFinMes                 = 0;
    LET sFechaArch              = "";
    LET sRuta_tabla             = "";
    LET sMensaje                = "REPORTE GENERADO CON ÃXITO";
    LET sMensajeStatus          = "";

    -- ****************************************************************************
    -- *                        CONTROL DE ERRORES                                *
    -- ****************************************************************************

    BEGIN
        ON EXCEPTION SET vsqlerr
        IF vsqlerr != 0 THEN
            LET v_cod_ret=vsqlerr;
            LET sMensaje = "ERROR AL GENERAR REPORTE";
            RETURN v_cod_ret, sMensaje;
        END IF;
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        --SET DEBUG FILE TO '/home/sysifx/ppcoppel/sp_reporte_ppcoppel.trc';
        --TRACE ON;

        -- ****************************************************************************
        -- *                        Genera Reporte MENSUAL                            *
        -- ****************************************************************************

        SELECT fecha_hoy
          INTO p_fecha
          FROM bdinteg:"informix".si_fechas;

        LET p_fecha_ini             = p_fecha;
        LET p_fecha_ini_ayer        = p_fecha;
        LET p_fecha_fin             = p_fecha;

        LET sDia  = DAY(p_fecha);
        LET sMes  = MONTH(p_fecha);
        LET sYear = YEAR(p_fecha_ini);

        IF LENGTH(sDia) < 2 THEN
            LET sDia="0"||sDia;
        END IF;

        IF LENGTH(sMes) < 2 THEN
            LET sMes="0"||sMes;
        END IF;

        IF sDia::INT = 1 THEN

            -- La ruta se toma de una tabla
            SELECT valor
              INTO sRuta_tabla
              FROM bdinteg:"informix".si_param 
			 WHERE cod_param = 509;

            -- Cambio de aÃ±o
            IF sMes::INT = 1 THEN
                LET p_fecha_ini = MDY(12, 1, YEAR(p_fecha)-1);
                LET sYear = YEAR(p_fecha_ini);
            ELSE
                LET p_fecha_ini = MDY(MONTH(p_fecha)-1, 1, YEAR(p_fecha));
            END IF
            LET p_fecha_ini_ayer = p_fecha - 1;

            -- Nombre del archivo es con la fecha que contenga la informaciÃ³n  --------------------
            LET sMesArc = MONTH(p_fecha_ini);
            IF LENGTH(sMesArc) < 2 THEN
                LET sMesArc = "0"||sMesArc;
            END IF;
            LET sFechaArch = sMesArc||sYear;
            LET pArchDescarga = "pp_grupo_"||TRIM(sFechaArch)||".txt";

            LET p_fecha_fin = MDY(MONTH(p_fecha), 1, YEAR(p_fecha));
            LET cnom_Sql = 'Reporte_aux_men.sql';

            LET cQuery = 'echo "UNLOAD TO '|| TRIM(sRuta_tabla) || TRIM(pArchDescarga) || ' DELIMITER ' || '''|''' || ' SELECT ''PRODUCTO'', ''NUMERO DE PROMOTOR'', ''NUMERO DE SUCURSAL'', ''FECHA DE CONTRATACION'', ''ESTATUS'', ''LINEA AUTORIZADA'' , ''LINEA DISPUESTA'' FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM  (SELECT num_producto, user_insert, sucursal ,TO_CHAR(fecha_contratacion,''%Y-%m-%d'') AS FECHA, CASE WHEN status_solicitud = ''P'' THEN ''ACLARACION'' WHEN status_solicitud = ''A'' THEN ''OTORGADO'' END AS status_solicitud,  TO_CHAR(monto_autorizado) AS Autoriza , TO_CHAR(capacidad_pres) AS Capacidad FROM bdisolic: "informix".ss_prestamoscoppel WHERE TO_CHAR(fecha_contratacion,''%Y-%m-%d'') >=''' || TO_CHAR(p_fecha_ini,"%Y-%m-%d") || ''' AND TO_CHAR(fecha_contratacion,''%Y-%m-%d'') <''' || TO_CHAR(p_fecha_fin ,"%Y-%m-%d")||''' AND (status_solicitud = ''A'' or status_solicitud = ''P'') ORDER BY FECHA);" >> '|| TRIM(sRuta_tabla) || TRIM(cnom_Sql);

            SYSTEM TRIM(cQuery);

            LET cQuery = 'dbaccess bdisolic '||TRIM(sRuta_tabla) || TRIM(cnom_Sql);
            SYSTEM TRIM(cQuery);

            LET cQuery='chmod 777 '|| TRIM(sRuta_tabla) || cnom_Sql;
            SYSTEM cQuery;

            LET cQuery='rm '|| TRIM(sRuta_tabla) || cnom_Sql;   -- Borrar el archivo temporal
            SYSTEM cQuery;

        END IF

        -- ****************************************************************************
        -- *                        Genera Reporte de Ayer ( Diario )                 *
        -- ****************************************************************************

        SELECT valor
          INTO sRuta_tabla
          FROM bdinteg:"informix".si_param
         WHERE cod_param = 508;

        LET p_fecha_ini = p_fecha - 1;

        LET sDia  = DAY(p_fecha_ini);
        LET sMes  = MONTH(p_fecha_ini);
        LET sYear = YEAR(p_fecha_ini);

        IF LENGTH(sDia) < 2 THEN
            LET sDia = "0"||sDia;
        END IF;

        IF LENGTH(sMes) < 2 THEN
            LET sMes = "0"||sMes;
        END IF;

        LET sFechaArch = sDia||sMes||sYear;
        LET pArchDescarga = "pp_grupo_"||TRIM(sFechaArch)||".txt";

        LET cnom_Sql = 'Reporte_aux.sql';

        LET cQuery = 'echo "UNLOAD TO '|| TRIM(sRuta_tabla) || TRIM(pArchDescarga) || ' DELIMITER ' || '''|''' ||' SELECT ''PRODUCTO'', ''NUMERO DE PROMOTOR'', ''NUMERO DE SUCURSAL'', ''FECHA DE CONTRATACION'', ''ESTATUS'', ''LINEA AUTORIZADA'' , ''LINEA DISPUESTA'' FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM(SELECT num_producto, user_insert, sucursal ,TO_CHAR(fecha_contratacion,''%Y-%m-%d'') AS FECHA, case WHEN status_solicitud = ''P'' THEN ''ACLARACION'' WHEN status_solicitud = ''A'' THEN ''OTORGADO'' END as status_solicitud, TO_CHAR(monto_autorizado) AS Autoriza , TO_CHAR(capacidad_pres) AS Capacidad FROM bdisolic:"informix".ss_prestamoscoppel AS presta where TO_CHAR(fecha_contratacion,''%Y-%m-%d'') =''' || TO_CHAR(p_fecha_ini,"%Y-%m-%d") || ''' AND (status_solicitud = ''A'' or status_solicitud = ''P''));" >> '|| TRIM(sRuta_tabla) || TRIM(cnom_Sql);

        SYSTEM TRIM(cQuery);

        LET cQuery = 'dbaccess bdisolic '||TRIM(sRuta_tabla) || TRIM(cnom_Sql);
        SYSTEM TRIM(cQuery);

        LET cQuery='chmod 777 '|| TRIM(sRuta_tabla) || cnom_Sql;
        SYSTEM cQuery;

        LET cQuery='rm '|| TRIM(sRuta_tabla) || cnom_Sql;   -- Borrar el archivo temporal
        SYSTEM cQuery;

        RETURN v_cod_ret, sMensaje;
    END;

END PROCEDURE;