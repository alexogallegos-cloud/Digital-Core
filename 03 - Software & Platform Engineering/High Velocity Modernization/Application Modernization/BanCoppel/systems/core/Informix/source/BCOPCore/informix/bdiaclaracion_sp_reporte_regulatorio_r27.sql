CREATE PROCEDURE "informix".sp_reporte_regulatorio_r27(fechaIni DATE, fechaFin DATE)

    RETURNING CHAR(11) AS folio_csuac, DATE AS fechacaptura, DATE AS fecha_movimiento, CHAR(20) AS numero_cuenta, CHAR(16) AS numero_tarjeta, CHAR(255) AS producto, CHAR(50) AS evento, CHAR(50) AS origen, MONEY(16,2) AS importereclamado, CHAR(255) AS Estatus, CHAR(50) AS Resolucion, DATE AS fecha_dictamen, CHAR(255) AS predictamen, MONEY(16,2) AS montoprocedente, DATE AS fecha_abono, MONEY(16,2) AS monto_abonoAutomatico;

	--definicion de variables--	    
	DEFINE resultado_folio_csuac                CHAR(11);
    DEFINE resultado_fechacaptura               DATE;
    DEFINE resultado_fecha_movimiento           DATE;
    DEFINE resultado_numero_cuenta              CHAR(20);
    DEFINE resultado_numero_tarjeta             CHAR(16);
    DEFINE resultado_producto                   CHAR(255);
    DEFINE resultado_evento                     CHAR(50);
    DEFINE resultado_origen                     CHAR(50);
    DEFINE resultado_importereclamado           MONEY(16,2);
    DEFINE resultado_estatus                    CHAR(255);
    DEFINE resultado_resolucion                 CHAR(50);
    DEFINE resultado_fecha_dictamen             DATE;
    DEFINE resultado_predictamen                CHAR(255);
    DEFINE resultado_montoprocedente            MONEY(16,2);
    DEFINE resultado_fecha_abono                DATE;
    DEFINE resultado_monto_abonoAutomatico      MONEY(16,2);
    DEFINE iSqlErr                              INTEGER;

    -- InicializaciÃÂ³n de las variables.
	LET resultado_folio_csuac = '';
    LET resultado_fechacaptura = '';
    LET resultado_fecha_movimiento = '';
    LET resultado_numero_cuenta = '';
    LET resultado_numero_tarjeta = '';
    LET resultado_producto = '';
    LET resultado_evento = '';
    LET resultado_origen = '';
    LET resultado_importereclamado = '';
    LET resultado_estatus = '';
    LET resultado_resolucion = '';
    LET resultado_fecha_dictamen = '';
    LET resultado_predictamen = '';
    LET resultado_montoprocedente = '';
    LET resultado_fecha_abono = '';
    LET resultado_monto_abonoAutomatico = '';

    SET ISOLATION TO dirty READ;

	BEGIN

    ON EXCEPTION
        SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_folio_csuac = '';
                LET resultado_fechacaptura = '';
                LET resultado_fecha_movimiento = '';
                LET resultado_numero_cuenta = '';
                LET resultado_numero_tarjeta = '';
                LET resultado_producto = '';
                LET resultado_evento = '';
                LET resultado_origen = '';
                LET resultado_importereclamado = '';
                LET resultado_estatus = '';
                LET resultado_resolucion = '';
                LET resultado_fecha_dictamen = '';
                LET resultado_predictamen = '';
                LET resultado_montoprocedente = '';
                LET resultado_fecha_abono = '';
                LET resultado_monto_abonoAutomatico = '';
                RETURN resultado_folio_csuac, resultado_fechacaptura, resultado_fecha_movimiento, resultado_numero_cuenta, resultado_numero_tarjeta, resultado_producto, resultado_evento, resultado_origen, resultado_importereclamado, resultado_estatus, resultado_resolucion, resultado_fecha_dictamen, resultado_predictamen, resultado_montoprocedente, resultado_fecha_abono, resultado_monto_abonoAutomatico;
            END IF;
    END EXCEPTION;

    FOREACH
        SELECT acl_aclaracion.folio_csuac, fechacaptura, fechahora AS fecha_movimiento, numero_cuenta, numero_tarjeta, acl_tipo_producto.descripcion AS producto, acl_tipo_evento.descripcion AS evento, acl_origen_evento.descripcion AS origen, importereclamado, acl_estatus_aclaracion.descripcion AS Estatus, 
        CASE WHEN acl_aclaracion.fecha_dictamen IS NULL THEN 'En anÃÂ¡lisis' ELSE CASE WHEN (acl_aclaracion.procede = 1 or acl_aclaracion.procede IS NULL) THEN 'Procedente' ELSE 'No procedente' END END AS procede,
        CASE WHEN acl_aclaracion.fecha_dictamen IS NULL THEN null ELSE acl_aclaracion.fecha_dictamen END AS fecha_dictamen,
        CASE WHEN acl_aclaracion.fecha_dictamen IS NULL THEN null ELSE (CASE WHEN acl_aclaracion.predictamen IS NULL AND acl_aclaracion.fky_estatus_corp_general = 8 THEN 'Por abono automÃÂ¡tico' ELSE acl_aclaracion.predictamen END) END AS predictamen,
        CASE WHEN acl_aclaracion.fecha_dictamen IS NULL THEN null ELSE acl_aclaracion.montoprocedente END AS montoprocedente,
        CASE WHEN acl_aclaracion.fecha_dictamen IS NULL THEN null ELSE acl_aclaracion.fecha_dictamen END AS fecha_abono,
        CASE WHEN acl_aclaracion.fky_estatus_corp_general = 8 THEN importereclamado ELSE null END AS monto_abonoAutomatico
        INTO resultado_folio_csuac, resultado_fechacaptura, resultado_fecha_movimiento, resultado_numero_cuenta, resultado_numero_tarjeta, resultado_producto, resultado_evento, resultado_origen, resultado_importereclamado, resultado_estatus, resultado_resolucion, resultado_fecha_dictamen, resultado_predictamen, resultado_montoprocedente, resultado_fecha_abono, resultado_monto_abonoAutomatico
        FROM (((acl_aclaracion INNER JOIN acl_estatus_aclaracion ON acl_estatus_aclaracion.pky_estatus_aclaracion = acl_aclaracion.fky_estatus_aclaracion)
            INNER JOIN (acl_tipo_evento 
                INNER JOIN acl_origen_evento ON acl_origen_evento.pky_origen_evento = acl_tipo_evento.fky_origen_evento)
                    ON acl_tipo_evento.pky_tipo_evento = acl_aclaracion.fky_tipo_evento)
                    INNER JOIN (acl_producto INNER JOIN acl_tipo_producto ON acl_tipo_producto.pky_tipo_producto = acl_producto.fky_tipo_producto) 
                        ON acl_producto.pky_producto = acl_aclaracion.fky_producto)
                        INNER JOIN acl_movimiento ON acl_movimiento.fky_aclaracion = acl_aclaracion.pky_aclaracion
                        WHERE acl_aclaracion.fechacaptura BETWEEN fechaIni AND fechaFin AND acl_aclaracion.fky_estatus_aclaracion > 1
						AND  acl_tipo_producto.producto not in ('6500')

						IF (SUBSTR (resultado_numero_cuenta, 0, 4) IN ('1900', '2200') AND resultado_numero_tarjeta = '' OR resultado_numero_tarjeta IS NULL) THEN
						LET resultado_producto = 'Cuentas de Cheques';
						END IF;
						
        RETURN resultado_folio_csuac, resultado_fechacaptura, resultado_fecha_movimiento, resultado_numero_cuenta, resultado_numero_tarjeta, resultado_producto, resultado_evento, resultado_origen, resultado_importereclamado, resultado_estatus, resultado_resolucion, resultado_fecha_dictamen, resultado_predictamen, resultado_montoprocedente, resultado_fecha_abono, resultado_monto_abonoAutomatico WITH RESUME;
    END FOREACH;

    END
END PROCEDURE;