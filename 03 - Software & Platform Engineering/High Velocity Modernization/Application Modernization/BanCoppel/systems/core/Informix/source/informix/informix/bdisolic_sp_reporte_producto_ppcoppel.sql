CREATE PROCEDURE "informix".sp_reporte_producto_ppcoppel()
RETURNING CHAR(5), CHAR(40);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE v_cod_ret			CHAR(5);
DEFINE vsqlerr				INTEGER;

DEFINE iDia				    INTEGER;
DEFINE cQuery				CHAR(1000);
DEFINE pArchDescarga		CHAR(100);
DEFINE cSQL1				CHAR(200);
DEFINE cnom_Sql				CHAR(100);

DEFINE sDia					CHAR(2);
DEFINE sMes					CHAR(2);
DEFINE sMesArc				CHAR(2);

DEFINE sYear				CHAR(4);

DEFINE p_fecha			    DATE;
DEFINE p_fecha_ini		    DATE;
DEFINE p_fecha_ini_ayer	    DATE;
DEFINE p_fecha_fin		    DATE;

DEFINE sFechaArch			CHAR(10);
DEFINE sFechaCons			CHAR(10);
DEFINE iFinMes			    INTEGER;
DEFINE sRuta_tabla			char(200);
DEFINE sMensaje			    char(40);
DEFINE sMensajeStatus	    char(20);




-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************


LET v_cod_ret				= "00000";
LET vsqlerr					= 0;

LET iDia					= 0;
LET cQuery					= "";
LET pArchDescarga			= "";
LET cSQL1					= "";

LET cnom_Sql				= "";
LET sDia					= "";
LET sMes					= "";
LET sMesArc					= "";

LET sYear					= "";

LET p_fecha				    = TODAY;
LET p_fecha_ini			    = TODAY;
LET p_fecha_ini_ayer	    = TODAY;
LET p_fecha_fin			    = TODAY;

LET sFechaArch				= "";
LET sFechaCons              = "";
LET iFinMes                 = 0;
LET sFechaArch				= "";
LET sRuta_tabla				= "";
LET sMensaje				= "REPORTE GENERADO CON ÃXITO";
LET sMensajeStatus			= "";


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
	
	--SET DEBUG FILE TO '/INFORMIXDUMP/sp_reporte_producto_ppcoppel.trc';
    --TRACE ON;

-- ****************************************************************************
-- *                        Genera Reporte MENSUAL                            *
-- ****************************************************************************	

     SELECT fecha_hoy
            INTO p_fecha
        FROM bdinteg: si_fechas;

    LET p_fecha_ini			    = p_fecha;
    LET p_fecha_ini_ayer	    = p_fecha;
    LET p_fecha_fin			    = p_fecha;

    LET sDia= DAY(p_fecha);
    LET sMes= MONTH(p_fecha);
    LET sYear= YEAR(p_fecha_ini);
    
    IF LENGTH(sDia) < 2 THEN
        LET sDia="0"||sDia;
    END IF;

    IF LENGTH(sMes) < 2 THEN
        LET sMes="0"||sMes;
    END IF;

    -- ****************************************************************************
    -- *                        Genera Reporte de Ayer ( Diario )                 *
    -- ****************************************************************************	
	
	SELECT valor
        INTO pArchDescarga
    FROM bdinteg:si_param WHERE cod_param = 510;

    SELECT valor
        INTO sRuta_tabla
    FROM bdinteg:si_param WHERE cod_param = 511;

    LET p_fecha_ini = p_fecha - 1;

    LET sDia = DAY(p_fecha_ini);
    LET sMes = MONTH(p_fecha_ini);
    LET sYear = YEAR(p_fecha_ini);
    
    IF LENGTH(sDia) < 2 THEN
        LET sDia="0"||sDia;
    END IF;

    IF LENGTH(sMes) < 2 THEN
        LET sMes="0"||sMes;
    END IF;

    LET sFechaArch = sDia||sMes||sYear;
    LET pArchDescarga = TRIM(pArchDescarga) || "_" || TRIM(sFechaArch) || ".txt";

    LET cnom_Sql = 'Reporte_aux.sql';

    LET cQuery = 'echo "UNLOAD TO '|| TRIM(sRuta_tabla) || TRIM(pArchDescarga) || ' DELIMITER ' || '''|''' ||' SELECT TRIM(user_insert), TRIM(sucursal), TRIM(numcte_ref), TRIM(folio_prestamo), TRIM(TO_CHAR(fecha_contratacion,''%Y-%m-%d'')), TRIM(TO_CHAR(monto_autorizado)), TRIM(TO_CHAR(plazo)), TRIM(TO_CHAR(ciudad)), TRIM(TO_CHAR(region)) FROM bdisolic: ss_prestamoscoppel AS pre WHERE TO_CHAR(fecha_contratacion,''%Y-%m-%d'') = ''' || p_fecha_ini || ''' AND (status_solicitud = ''A'' OR status_solicitud = ''P'');" > '|| TRIM(sRuta_tabla) || TRIM(cnom_Sql);
	
    SYSTEM TRIM(cQuery);

    LET cQuery = 'dbaccess bdisolic '||TRIM(sRuta_tabla) || TRIM(cnom_Sql); 	
    SYSTEM TRIM(cQuery);
            
    LET cQuery='chmod 777 '|| TRIM(sRuta_tabla) || cnom_Sql;
    System cQuery;

    LET cQuery='rm '|| TRIM(sRuta_tabla) || cnom_Sql;   -- Borrar el archivo temporal
    System cQuery;

    RETURN v_cod_ret, sMensaje;	
END;	

END PROCEDURE
