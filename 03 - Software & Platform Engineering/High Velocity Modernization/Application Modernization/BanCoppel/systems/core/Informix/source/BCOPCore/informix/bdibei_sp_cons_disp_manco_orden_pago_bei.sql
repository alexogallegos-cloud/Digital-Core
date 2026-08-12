CREATE PROCEDURE "informix".sp_cons_disp_manco_orden_pago_bei(pIdOperacion INTEGER)
RETURNING CHAR(5), CHAR(10), CHAR(20), CHAR(17), CHAR(10), CHAR(20),
        CHAR(3), CHAR(4), INTEGER, INTEGER, INTEGER, INTEGER,INTEGER,    
        SMALLINT, SMALLINT,MONEY(14,2),INTEGER,CHAR(30),INTEGER, DECIMAL(18,2),
        DECIMAL(18,2), MONEY(14,2), MONEY(14,2), MONEY(14,2);

    
    DEFINE sql_err INTEGER;
	DEFINE cCod_ret CHAR (5);
    DEFINE vf_aplicacion       CHAR(10);
    DEFINE vcuenta_origen      CHAR(20);        
    DEFINE vnombre_archivo     CHAR(17);
    DEFINE vf_dispersion       CHAR(10);
    DEFINE vcte_empresa        CHAR(20);
    DEFINE vid_empresa         CHAR(3);  
    DEFINE vid_oper            CHAR(4);
    DEFINE vid_catOperacion    INTEGER;
    DEFINE vid_usuario         INTEGER;
    DEFINE vtamano_archivo     INTEGER;
    DEFINE vtipo_archivo       INTEGER;
    DEFINE vtipo_cuentas       INTEGER;   
    DEFINE vtipo_oper          SMALLINT;
    DEFINE vstatus_archivo     SMALLINT;
    DEFINE vmontoTotal         MONEY(14,2);
	DEFINE vCantidadEmpleados	INTEGER;
	DEFINE vConcepto			CHAR(30);
	DEFINE vTipoDispersion		INTEGER;	
	DEFINE vcargoDispersion     DECIMAL(18,2);
	DEFINE vtotalSinComision	DECIMAL (18,2);
    DEFINE vComsion             MONEY(14,2);	
	DEFINE viva                 MONEY(14,2);
	DEFINE vivaComsion			MONEY(14,2);


    LET cCod_ret = '00000';
    LET vf_aplicacion = TODAY;
    LET vcuenta_origen = '';
    LET vnombre_archivo = '';
    LET vf_dispersion = TODAY;
    LET vcte_empresa = '';
    LET vid_empresa = '';
    LET vid_oper = '';
    LET vid_catOperacion = 0;
    LET vid_usuario = 0;
    LET vtamano_archivo = 0;
    LET vtipo_archivo = 0;
    LET vtipo_cuentas = 0;
    LET vtipo_oper = 0;
    LET vstatus_archivo = 0;
    LET vmontoTotal = 0;
    LET vCantidadEmpleados	= 0;
	LET vConcepto			= '';
	LET vTipoDispersion		= 0;
	LET vcargoDispersion	= 0;
	LET vtotalSinComision	= 0;
    LET vComsion = 0;
    LET viva        = 0;
    LET vivaComsion = 0;
  ---------------------------------------------------
	-- 06 Junio 2014 
	-- Se actualiza para manejo de formatos de fecha --
  ---------------------------------------------------

BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret, vf_aplicacion, vcuenta_origen, vnombre_archivo, vf_dispersion,
                vcte_empresa, vid_empresa, vid_oper, vid_catOperacion, vid_usuario,
                vtamano_archivo, vtipo_archivo, vtipo_cuentas, vtipo_oper,
                vstatus_archivo, vmontoTotal, vCantidadEmpleados, vConcepto,
                vTipoDispersion, vcargoDispersion,vtotalSinComision, vComsion,
                viva,vivaComsion;
      END IF ;
    END EXCEPTION ;

     SELECT to_char(f_aplicacion,"%iY-%m-%d") as f_aplicacion, cuenta_origen, archivos.nombre_archivo, to_char(f_dispersion,"%iY-%m-%d") as f_dispersion,
            cte_empresa, id_empresa, id_oper, id_cat_operacion, 
            operacionesmancomunadasoperador.id_usuario, tamano_archivo, 
            tipo_archivo, tipo_cuentas, tipo_oper, status_archivo, montoTotal,
			cantidadEmpleados, referencia, tipoDispersion, cargoDispersion, totalSinComision,
            comision, valor_iva, ivacomision
     INTO vf_aplicacion, vcuenta_origen, vnombre_archivo, vf_dispersion,
        vcte_empresa, vid_empresa, vid_oper, vid_catOperacion, vid_usuario,
        vtamano_archivo, vtipo_archivo, vtipo_cuentas, vtipo_oper,
        vstatus_archivo, vmontoTotal, vCantidadEmpleados, vConcepto,
		vTipoDispersion, vcargoDispersion,vtotalSinComision, vComsion,
        viva,vivaComsion
    FROM "informix".bei_operacionesmancomunadasoperador AS operacionesmancomunadasoperador
       INNER JOIN "informix".bei_archivos_orden_pago AS archivos 
        ON (operacionesmancomunadasoperador.nombre_archivo = archivos.nombre_archivo AND
    operacionesmancomunadasoperador.id_cliente = archivos.cte_empresa)
    WHERE operacionesmancomunadasoperador.ID_OPERACION = to_char(pIdOperacion);

    RETURN cCod_ret, vf_aplicacion, vcuenta_origen, vnombre_archivo, vf_dispersion,
                vcte_empresa, vid_empresa, vid_oper, vid_catOperacion, vid_usuario,
                vtamano_archivo, vtipo_archivo, vtipo_cuentas, vtipo_oper,
                vstatus_archivo, vmontoTotal, vCantidadEmpleados, vConcepto,
                vTipoDispersion, vcargoDispersion,vtotalSinComision, vComsion,
                viva,vivaComsion;

END

END PROCEDURE;