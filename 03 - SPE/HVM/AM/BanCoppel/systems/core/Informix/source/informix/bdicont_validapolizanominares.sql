CREATE PROCEDURE "informix".validapolizanominares(p_empresa   CHAR(3),
                                                   p_usuario   CHAR(8))

   RETURNING CHAR(5),integer;

   DEFINE p_fecha_hoy               DATE;
   DEFINE sql_err                   INTEGER;
   DEFINE isam_err                  INTEGER;
   DEFINE error_info                CHAR(40);
   DEFINE v_directorio              CHAR(30);
   DEFINE v_sql                     CHAR(200);

   DEFINE v_poliza                  INTEGER;
   DEFINE v_ctrl_poliza             INTEGER;
   DEFINE v_ctrolpoliza             INTEGER;
   DEFINE v_numpoliza               INTEGER;
   DEFINE cod_ret                   CHAR(3);
   DEFINE v_correlativa             CHAR(4);
   DEFINE v_orden                   CHAR(4);
   DEFINE tmensaje                  CHAR(50);

   DEFINE v_usuariotmp              CHAR(8);
   DEFINE v_usuario                 CHAR(8);
   DEFINE v_control_poliza          INTEGER;
   DEFINE v_fecha_captura           DATE;
   DEFINE v_secuencia               INTEGER;
   DEFINE v_empresa                 CHAR(3);
   DEFINE v_ccmayor                 CHAR(4);
   DEFINE v_ccsub                   CHAR(2);
   DEFINE v_ccsubsub                CHAR(2);
   DEFINE v_ccssubsub               CHAR(2);
   DEFINE v_ccsssubsub              CHAR(2);
   DEFINE v_sector                  CHAR(2);
   DEFINE v_ciudad                  CHAR(3);
   DEFINE v_sucursal                CHAR(4);
   DEFINE v_nro_auxiliar            CHAR(12);
   DEFINE v_naturaleza              CHAR(1);
   DEFINE v_monto                   MONEY(18,2);
   DEFINE v_descripcion_det         CHAR(80);
   DEFINE v_fecha_valida            DATE;
   DEFINE v_moneda                  CHAR(2);
   DEFINE v_ccosto_orig             CHAR(4);

   DEFINE v_empresa_d               CHAR(3);
   DEFINE v_usuario_d               CHAR(8);
   DEFINE v_control_poliza_d        INTEGER;
   DEFINE v_fecha_captura_d         DATE;
   DEFINE v_cifra_control_d         MONEY(18,2);
   DEFINE v_sumacargos              MONEY(18,2);
   DEFINE v_moneda_d                CHAR(2);
   DEFINE v_descripcion_det_d       CHAR(80);

   DEFINE v_empresa_c               CHAR(3);
   DEFINE v_usuario_c               CHAR(8);
   DEFINE v_control_poliza_c        INTEGER;
   DEFINE v_fecha_captura_c         DATE;
   DEFINE v_cifra_control_c         MONEY(18,2);
   DEFINE v_sumaabonos              MONEY(18,2);
   DEFINE v_moneda_c                CHAR (2);
   DEFINE v_descripcion_det_c       CHAR(80);

   DEFINE v_errors                  INTEGER;
   DEFINE v_sumacorre               MONEY(18,2);
   DEFINE v_sumaorden               MONEY(18,2);
   DEFINE v_bandera                 INTEGER;
   DEFINE v_registros               INTEGER;
   DEFINE v_sectoriza_ctacat        CHAR(1);
   DEFINE v_cta_restringida_destcat CHAR(1);
   DEFINE v_cta_restringida_origcat CHAR(1);
   DEFINE v_monedacat               CHAR(2);
   DEFINE v_auxiliarcat             CHAR(12);
   DEFINE v_tipo_cuentacat          CHAR(1);
   DEFINE v_cancelacion             CHAR(1);

   DEFINE v_ccmayor_corr            CHAR(4);
   DEFINE v_ccsub_corr              CHAR(2);
   DEFINE v_ccsubsub_corr           CHAR(2);
   DEFINE v_ccssubsub_corr          CHAR(2);
   DEFINE v_ccsssubsub_corr         CHAR(2);
   DEFINE v_sector_corr             CHAR(2);
   DEFINE v_naturaleza_corr         CHAR(1);
   DEFINE v_monto_corr              MONEY(18,2);
   DEFINE v_sucursal_corr           CHAR(4);

   DEFINE v_ccmayor_orden            CHAR(4);
   DEFINE v_ccsub_orden              CHAR(2);
   DEFINE v_ccsubsub_orden           CHAR(2);
   DEFINE v_ccssubsub_orden          CHAR(2);
   DEFINE v_ccsssubsub_orden         CHAR(2);
   DEFINE v_sector_orden             CHAR(2);
   DEFINE v_naturaleza_orden         CHAR(1);
   DEFINE v_monto_orden              MONEY(18,2);
   DEFINE v_sucursal_orden           CHAR(4);

   DEFINE v_enl_cc_mayor            CHAR(4);
   DEFINE v_enl_cc_sub              CHAR(2);
   DEFINE v_enl_cc_ss               CHAR(2);
   DEFINE v_enl_cc_sss              CHAR(2);
   DEFINE v_enl_cc_ssss             CHAR(2);
   DEFINE v_enl_cc_sector           CHAR(2);
   DEFINE v_ctaord_ini              CHAR(4);
   DEFINE v_ctaord_fin              CHAR(4);
   DEFINE v_ctacor_ini              CHAR(4);
   DEFINE v_ctacor_fin              CHAR(4);

   DEFINE v_hora_inicio             DATETIME HOUR TO FRACTION(5);
   DEFINE v_fecha_hoy               DATE;
   DEFINE v_ult_hab_mes             DATE;

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      SET DEBUG FILE TO "ErrPoliza.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;

      RETURN cod_ret,v_control_poliza;
   END EXCEPTION;

--**************************************************
-- Creado por Fabiola Corrales Tapia 06/Mar/2007 --*
-- Debug del Procedure                           --*
SET DEBUG FILE TO "/tmp/validapoliza.out";       --*
TRACE ON;                                        --*
--**************************************************
{***************************************************************************
 **   OBTENCION DE INFORMACION GENERAL PARA EL PROCESO                    **
 ***************************************************************************}
   LET v_hora_inicio = CURRENT;

   --LET g_usuario = USER;
   --LET g_mora_codret = "000";
   --LET g_intvenc_codret = "000";
   --LET contador         = 1;
   --LET g_archivo = TRIM(p_archivo);
   --LET v_contador = 0;
   --LET g_detalle  = " ";

   LET v_directorio              = "";
   LET v_sql                     = "";
   LET p_fecha_hoy               = MDY(MONTH(CURRENT), DAY(CURRENT), YEAR(CURRENT));
   LET tmensaje                  = "";

   LET cod_ret                   = "";
   LET v_poliza                  = 0;
   LET v_ctrl_poliza             = 0;
   LET v_ctrolpoliza             = 0;
   LET v_numpoliza               = 0;
   LET cod_ret                   = "";

   LET v_usuariotmp              = "";
   LET v_usuario                 = "";
   LET v_control_poliza          = 0;
   LET v_secuencia               = 0;
   LET v_empresa                 = "";
   LET v_ccmayor                 = "";
   LET v_ccsub                   = "";
   LET v_ccsubsub                = "";
   LET v_ccssubsub               = "";
   LET v_ccsssubsub              = "";
   LET v_sector                  = "";
   LET v_ciudad                  = "";
   LET v_sucursal                = "";
   LET v_nro_auxiliar            = "";
   LET v_naturaleza              = "";
   LET v_monto                   = 0;
   LET v_descripcion_det         = "";
   --LET v_fecha_valida            DATE;
   LET v_moneda                  = "";
   LET v_ccosto_orig             = "";

   LET v_empresa_d               = "";
   LET v_usuario_d               = "";
   LET v_control_poliza_d        = 0;
   --LET v_fecha_captura_d         DATE;
   LET v_cifra_control_d         = 0;
   LET v_sumacargos              = 0;
   LET v_moneda_d                = "";
   LET v_descripcion_det_d       = "";

   LET v_empresa_c               = "";
   LET v_usuario_c               = "";
   LET v_control_poliza_c        = 0;
   --LET v_fecha_captura_c         DATE;
   LET v_cifra_control_c         = 0;
   LET v_sumaabonos              = 0;
   LET v_moneda_c                = "";
   LET v_descripcion_det_c       = "";

   LET v_errors                  = 0;
   LET v_sumacorre               = 0;
   LET v_sumaorden               = 0;
   LET v_bandera                 = 0;
   LET v_registros               = 0;

   LET v_sectoriza_ctacat        = "";
   LET v_cta_restringida_destcat = "";
   LET v_cta_restringida_origcat = "";
   LET v_monedacat               = "";
   LET v_auxiliarcat             = "";
   LET v_tipo_cuentacat          = "";

   LET v_ccmayor_corr            = "";
   LET v_ccsub_corr              = "";
   LET v_ccsubsub_corr           = "";
   LET v_ccssubsub_corr          = "";
   LET v_ccsssubsub_corr         = "";
   LET v_sector_corr             = "";
   LET v_naturaleza_corr         = "";
   LET v_monto_corr              = 0;
   LET v_sucursal_corr           = "";

   LET v_ccmayor_orden           = "";
   LET v_ccsub_orden             = "";
   LET v_ccsubsub_orden          = "";
   LET v_ccssubsub_orden         = "";
   LET v_ccsssubsub_orden        = "";
   LET v_sector_orden            = "";
   LET v_naturaleza_orden        = "";
   LET v_monto_orden             = 0;
   LET v_sucursal_orden          = "";


   LET v_enl_cc_mayor            = "";
   LET v_enl_cc_sub              = "";
   LET v_enl_cc_ss               = "";
   LET v_enl_cc_sss              = "";
   LET v_enl_cc_ssss             = "";
   LET v_enl_cc_sector           = "";
   LET v_ctaord_ini              = "";
   LET v_ctaord_fin              = "";
   LET v_ctacor_ini              = "";
   LET v_ctacor_fin              = "";

   --LET v_fecha_hoy               DATE;
   --LET v_ult_hab_mes             DATE;

   SELECT
      fecha_hoy, ult_hab_mes
   INTO
      v_fecha_hoy, v_ult_hab_mes
   FROM
      bdicont:co_fechas
   WHERE
      bdicont:co_fechas.empresa = p_empresa;

   LET cod_ret = "000";

   --inicia nuevo proceso
   SELECT trim(enl_cc_mayor),
          trim(enl_cc_sub),
          trim(enl_cc_ss),
          trim(enl_cc_sss),
          trim(enl_cc_ssss),
          trim(enl_cc_sector),
          trim(cta_ord_inic),
          trim(cta_ord_final),
          trim(cta_correl_inic),
          trim(cta_correl_final)
     INTO v_enl_cc_mayor,
          v_enl_cc_sub,
          v_enl_cc_ss,
          v_enl_cc_sss,
          v_enl_cc_ssss,
          v_enl_cc_sector,
          v_ctaord_ini,
          v_ctaord_fin,
          v_ctacor_ini,
          v_ctacor_fin
     FROM bdicont:co_param
     WHERE empresa = p_empresa;


  DELETE FROM bdicont:tmpco_auditerr;

 -- determinar si la poliza esta cuadrada
 LET cod_ret = "000";

 FOREACH
    --SELECT DISTINCT control_poliza, usuario INTO v_ctrolpoliza, v_usuariotmp FROM bdicont:tmpco_detpol
    SELECT control_poliza, usuario INTO v_ctrolpoliza, v_usuariotmp FROM bdicont:tmpco_detpol GROUP BY control_poliza, usuario ORDER BY control_poliza, usuario

    SELECT SUM(monto) INTO v_sumaabonos FROM tmpco_detpol
    WHERE naturaleza = "D" AND control_poliza = v_ctrolpoliza;
    IF v_sumaabonos IS NULL THEN
        LET v_sumaabonos = 0;
    END IF

    SELECT SUM(monto) INTO v_sumacargos FROM tmpco_detpol
    WHERE naturaleza = "C" AND control_poliza = v_ctrolpoliza;
    IF v_sumacargos IS NULL THEN
        LET v_sumacargos = 0;
    END IF

   --poliza descuadrada
    IF v_sumaabonos != v_sumacargos THEN
        LET cod_ret = "106"; --OK
        SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
        INSERT INTO bdicont:tmpco_auditerr
                    (control_poliza, cod_ret, mensaje)
             VALUES (v_control_poliza, cod_ret, tmensaje);
        --RETURN  cod_ret, v_control_poliza;
    END IF

   --validaciones

    FOREACH WITH HOLD
        SELECT usuario,
               control_poliza,
               fecha_captura,
               secuencia,
               empresa,
               ccmayor,
               ccsub,
               ccsubsub,
               ccssubsub,
               ccsssubsub,
               sector,
               ciudad,
               sucursal,
               nro_auxiliar,
               naturaleza,
               monto,
               descripcion_det,
               fecha_valida,
               moneda,
               ccosto_orig
          INTO v_usuario,
               v_control_poliza,
               v_fecha_captura,
               v_secuencia,
               v_empresa,
               v_ccmayor,
               v_ccsub,
               v_ccsubsub,
               v_ccssubsub,
               v_ccsssubsub,
               v_sector,
               v_ciudad,
               v_sucursal,
               v_nro_auxiliar,
               v_naturaleza,
               v_monto,
               v_descripcion_det,
               v_fecha_valida,
               v_moneda,
               v_ccosto_orig
          FROM bdicont:tmpco_detpol
         WHERE control_poliza = v_ctrolpoliza


        --VALIDANDO USUARIO
        IF v_usuario IS NULL OR trim(v_usuario) = "" THEN
            LET cod_ret = "99a"; --OK
            SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
            INSERT INTO bdicont:tmpco_auditerr
                  (usuario,
                  control_poliza,
                  fecha_captura,
                  secuencia,
                  empresa,
                  ccmayor,
                  ccsub,
                  ccsubsub,
                  ccssubsub,
                  ccsssubsub,
                  sector,
                  auxiliar,
                  cod_ret,
                  mensaje)
           VALUES (v_usuario,
                  v_control_poliza,
                  p_fecha_hoy,
                  v_secuencia,
                  v_empresa,
                  v_ccmayor,
                  v_ccsub,
                  v_ccsubsub,
                  v_ccssubsub,
                  v_ccsssubsub,
                  v_sector,
                  v_nro_auxiliar,
                  cod_ret,
                  tmensaje);
            --RETURN cod_ret,v_control_poliza;
        ELSE
            SELECT COUNT(*) INTO v_registros FROM bdinteg:si_ejecut
            WHERE empresa = p_empresa
            AND ejecutivo = v_usuario;
            IF v_registros = 0 THEN
                LET cod_ret = "999";
                SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
                INSERT INTO bdicont:tmpco_auditerr
                    (usuario,
                    control_poliza,
                    fecha_captura,
                    secuencia,
                    empresa,
                    ccmayor,
                    ccsub,
                    ccsubsub,
                    ccssubsub,
                    ccsssubsub,
                    sector,
                    auxiliar,
                    cod_ret,
                    mensaje)
             VALUES (v_usuario,
                    v_control_poliza,
                    p_fecha_hoy,
                    v_secuencia,
                    v_empresa,
                    v_ccmayor,
                    v_ccsub,
                    v_ccsubsub,
                    v_ccssubsub,
                    v_ccsssubsub,
                    v_sector,
                    v_nro_auxiliar,
                    cod_ret,
                    tmensaje);
                --RETURN cod_ret,v_control_poliza;
            END IF
        END IF

        --VALIDANDO EMPRESA
        IF v_empresa IS NULL OR trim(v_empresa) = "" THEN
            LET cod_ret = "98a"; --ok
            SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
            INSERT INTO bdicont:tmpco_auditerr
                  (usuario,
                  control_poliza,
                  fecha_captura,
                  secuencia,
                  empresa,
                  ccmayor,
                  ccsub,
                  ccsubsub,
                  ccssubsub,
                  ccsssubsub,
                  sector,
                  auxiliar,
                  cod_ret,
                  mensaje)
           VALUES (v_usuario,
                  v_control_poliza,
                  p_fecha_hoy,
                  v_secuencia,
                  v_empresa,
                  v_ccmayor,
                  v_ccsub,
                  v_ccsubsub,
                  v_ccssubsub,
                  v_ccsssubsub,
                  v_sector,
                  v_nro_auxiliar,
                  cod_ret,
                  tmensaje);
            --RETURN cod_ret,v_control_poliza;
        ELSE
            SELECT COUNT(*) INTO v_registros FROM bdinteg:si_empresas
            WHERE empresa = p_empresa;
            IF v_registros = 0 THEN
                LET cod_ret = "998"; --ok
                SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
                INSERT INTO bdicont:tmpco_auditerr
                    (usuario,
                    control_poliza,
                    fecha_captura,
                    secuencia,
                    empresa,
                    ccmayor,
                    ccsub,
                    ccsubsub,
                    ccssubsub,
                    ccsssubsub,
                    sector,
                    auxiliar,
                    cod_ret,
                    mensaje)
             VALUES (v_usuario,
                    v_control_poliza,
                    p_fecha_hoy,
                    v_secuencia,
                    v_empresa,
                    v_ccmayor,
                    v_ccsub,
                    v_ccsubsub,
                    v_ccssubsub,
                    v_ccsssubsub,
                    v_sector,
                    v_nro_auxiliar,
                    cod_ret,
                    tmensaje);
                --RETURN cod_ret,v_control_poliza;
            END IF
        END IF

        --VALIDANDO EXISTA LA CUENTA CONTABLE
        IF (v_ccmayor IS NULL OR trim(v_ccmayor) = "") OR (v_ccsub IS NULL OR trim(v_ccsub) = "") OR (v_ccsubsub IS NULL OR trim(v_ccsubsub) = "") OR
           (v_ccssubsub IS NULL OR trim(v_ccssubsub) = "") OR (v_ccsssubsub IS NULL OR trim(v_ccsssubsub) = "") OR (v_sector IS NULL OR trim(v_sector) = "") THEN
            LET cod_ret = "100"; --ok
            SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
            INSERT INTO bdicont:tmpco_auditerr
                  (usuario,
                  control_poliza,
                  fecha_captura,
                  secuencia,
                  empresa,
                  ccmayor,
                  ccsub,
                  ccsubsub,
                  ccssubsub,
                  ccsssubsub,
                  sector,
                  auxiliar,
                  cod_ret,
                  mensaje)
           VALUES (v_usuario,
                  v_control_poliza,
                  p_fecha_hoy,
                  v_secuencia,
                  v_empresa,
                  v_ccmayor,
                  v_ccsub,
                  v_ccsubsub,
                  v_ccssubsub,
                  v_ccsssubsub,
                  v_sector,
                  v_nro_auxiliar,
                  cod_ret,
                  tmensaje);
            --RETURN cod_ret,v_control_poliza;
        ELSE
            SELECT COUNT(*) INTO v_registros FROM bdinteg:si_catalog
            WHERE empresa = p_empresa AND ccmayor = v_ccmayor AND ccsub = v_ccsub
            AND ccsubsub = v_ccsubsub AND ccssubsub = v_ccssubsub AND ccsssubsub = v_ccsssubsub
            AND sector = v_sector;

            IF v_registros = 0 THEN
                LET cod_ret = "100";
                SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
                INSERT INTO bdicont:tmpco_auditerr
                    (usuario,
                    control_poliza,
                    fecha_captura,
                    secuencia,
                    empresa,
                    ccmayor,
                    ccsub,
                    ccsubsub,
                    ccssubsub,
                    ccsssubsub,
                    sector,
                    auxiliar,
                    cod_ret,
                    mensaje)
            VALUES (v_usuario,
                    v_control_poliza,
                    p_fecha_hoy,
                    v_secuencia,
                    v_empresa,
                    v_ccmayor,
                    v_ccsub,
                    v_ccsubsub,
                    v_ccssubsub,
                    v_ccsssubsub,
                    v_sector,
                    v_nro_auxiliar,
                    cod_ret,
                    tmensaje);
                --RETURN cod_ret,v_control_poliza;
            -- VALIDANDO QUE LA CUENTA CONTABLE SEA DE DETALLE
            ELSE
                SELECT moneda, tipo_cuenta, cta_restringida_orig, cta_restringida_dest, auxiliar, sectoriza_cta, cancelacion
                INTO v_monedacat, v_tipo_cuentacat, v_cta_restringida_origcat, v_cta_restringida_destcat, v_auxiliarcat, v_sectoriza_ctacat, v_cancelacion
                FROM bdinteg:si_catalog
                WHERE empresa = p_empresa AND ccmayor = v_ccmayor AND ccsub = v_ccsub
                AND ccsubsub = v_ccsubsub AND ccssubsub = v_ccssubsub AND ccsssubsub = v_ccsssubsub
                AND sector = v_sector;
                IF TRIM(v_tipo_cuentacat) <> 'D' THEN
                    LET cod_ret = "144"; --ok
                    SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
                    INSERT INTO bdicont:tmpco_auditerr
                        (usuario,
                        control_poliza,
                        fecha_captura,
                        secuencia,
                        empresa,
                        ccmayor,
                        ccsub,
                        ccsubsub,
                        ccssubsub,
                        ccsssubsub,
                        sector,
                        auxiliar,
                        cod_ret,
                        mensaje)
                VALUES (v_usuario,
                        v_control_poliza,
                        p_fecha_hoy,
                        v_secuencia,
                        v_empresa,
                        v_ccmayor,
                        v_ccsub,
                        v_ccsubsub,
                        v_ccssubsub,
                        v_ccsssubsub,
                        v_sector,
                        v_nro_auxiliar,
                        cod_ret,
                        tmensaje);
                        --RETURN cod_ret,v_control_poliza;
                END IF
                --VALIDANDO QUE LA CTA CONTABLE SEA AFLECTABLE POR LA MONEDA
                IF v_monedacat::INTEGER <> v_moneda::INTEGER THEN
                    IF v_monedacat::INTEGER <> 3 THEN
                        LET cod_ret = "144"; --ok
                        INSERT INTO bdicont:tmpco_auditerr
                            (usuario,
                            control_poliza,
                            fecha_captura,
                            secuencia,
                            empresa,
                            ccmayor,
                            ccsub,
                            ccsubsub,
                            ccssubsub,
                            ccsssubsub,
                            sector,
                            auxiliar,
                            cod_ret,
                            mensaje)
                    VALUES (v_usuario,
                            v_control_poliza,
                            p_fecha_hoy,
                            v_secuencia,
                            v_empresa,
                            v_ccmayor,
                            v_ccsub,
                            v_ccsubsub,
                            v_ccssubsub,
                            v_ccsssubsub,
                            v_sector,
                            v_nro_auxiliar,
                            cod_ret,
                            tmensaje);
                            --RETURN cod_ret,v_control_poliza;
                    END IF
                END IF

                --VALIDANDO RESTRICCION DEL CENTRO DE COSTOS ORIGEN
                IF v_cta_restringida_origcat = 'S' THEN

                    SELECT count(*) INTO v_registros FROM bdicont:co_cta_ccorig WHERE empresa = p_empresa AND ccmayor = v_ccmayor AND ccsub = v_ccsub
                    AND ccsubsub = v_ccsubsub AND ccssubsub = v_ccssubsub AND ccsssubsub = v_ccsssubsub AND sector = v_sector AND sucursal = v_ccosto_orig;

                    IF v_registros = 0 THEN
                        LET cod_ret = "148"; --ok
                        INSERT INTO bdicont:tmpco_auditerr
                            (usuario,
                            control_poliza,
                            fecha_captura,
                            secuencia,
                            empresa,
                            ccmayor,
                            ccsub,
                            ccsubsub,
                            ccssubsub,
                            ccsssubsub,
                            sector,
                            auxiliar,
                            cod_ret,
                            mensaje)
                    VALUES (v_usuario,
                            v_control_poliza,
                            p_fecha_hoy,
                            v_secuencia,
                            v_empresa,
                            v_ccmayor,
                            v_ccsub,
                            v_ccsubsub,
                            v_ccssubsub,
                            v_ccsssubsub,
                            v_sector,
                            v_nro_auxiliar,
                            cod_ret,
                            tmensaje);
                            --RETURN cod_ret,v_control_poliza;
                    END IF
                END IF

                --VALIDANDO RESTRICCION DEL CENTRO DE COSTOS DESTINO
                IF v_cta_restringida_destcat = 'S' THEN

                    SELECT count(*) INTO v_registros FROM bdicont:co_cta_ccorig WHERE empresa = p_empresa AND ccmayor = v_ccmayor AND ccsub = v_ccsub AND ccsubsub = v_ccsubsub
                    AND ccssubsub = v_ccssubsub AND ccsssubsub = v_ccsssubsub AND sector = v_sector AND sucursal = v_sucursal;

                    IF v_registros = 0 THEN
                        LET cod_ret = "149"; --ok
                        SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
                        INSERT INTO bdicont:tmpco_auditerr
                            (usuario,
                            control_poliza,
                            fecha_captura,
                            secuencia,
                            empresa,
                            ccmayor,
                            ccsub,
                            ccsubsub,
                            ccssubsub,
                            ccsssubsub,
                            sector,
                            auxiliar,
                            cod_ret,
                            mensaje)
                    VALUES (v_usuario,
                            v_control_poliza,
                            p_fecha_hoy,
                            v_secuencia,
                            v_empresa,
                            v_ccmayor,
                            v_ccsub,
                            v_ccsubsub,
                            v_ccssubsub,
                            v_ccsssubsub,
                            v_sector,
                            v_nro_auxiliar,
                            cod_ret,
                            tmensaje);
                        --RETURN cod_ret,v_control_poliza;
                    END IF
                END IF

                -- VALIDANDO EL SECTOR
                IF v_sectoriza_ctacat = 'N' AND v_sector != '00' THEN
                    LET cod_ret = "117"; --ok
                    SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
                    INSERT INTO bdicont:tmpco_auditerr
                        (usuario,
                        control_poliza,
                        fecha_captura,
                        secuencia,
                        empresa,
                        ccmayor,
                        ccsub,
                        ccsubsub,
                        ccssubsub,
                        ccsssubsub,
                        sector,
                        auxiliar,
                        cod_ret,
                        mensaje)
                 VALUES (v_usuario,
                        v_control_poliza,
                        p_fecha_hoy,
                        v_secuencia,
                        v_empresa,
                        v_ccmayor,
                        v_ccsub,
                        v_ccsubsub,
                        v_ccssubsub,
                        v_ccsssubsub,
                        v_sector,
                        v_nro_auxiliar,
                        cod_ret,
                        tmensaje);
                        --RETURN cod_ret,v_control_poliza;
                END IF
                -- VALIDANDO SI LA CUENTA ESTA CANCELADA.
                IF v_cancelacion <> 'N' THEN
                    LET cod_ret = "176"; --ok
                    SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
                    INSERT INTO bdicont:tmpco_auditerr
                        (usuario,
                        control_poliza,
                        fecha_captura,
                        secuencia,
                        empresa,
                        ccmayor,
                        ccsub,
                        ccsubsub,
                        ccssubsub,
                        ccsssubsub,
                        sector,
                        auxiliar,
                        cod_ret,
                        mensaje)
                 VALUES (v_usuario,
                        v_control_poliza,
                        p_fecha_hoy,
                        v_secuencia,
                        v_empresa,
                        v_ccmayor,
                        v_ccsub,
                        v_ccsubsub,
                        v_ccssubsub,
                        v_ccsssubsub,
                        v_sector,
                        v_nro_auxiliar,
                        cod_ret,
                        tmensaje);
                        --RETURN cod_ret,v_control_poliza;
                END IF

                --VALIDANDO EL NUMERO DE AUXILIAR
                IF (TRIM(v_nro_auxiliar) != "") THEN
                    IF v_auxiliarcat = 'N' THEN
                        LET cod_ret = "166"; --OK
                        SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
                        INSERT INTO bdicont:tmpco_auditerr
                            (usuario,
                            control_poliza,
                            fecha_captura,
                            secuencia,
                            empresa,
                            ccmayor,
                            ccsub,
                            ccsubsub,
                            ccssubsub,
                            ccsssubsub,
                            sector,
                            auxiliar,
                            cod_ret,
                            mensaje)
                    VALUES (v_usuario,
                            v_control_poliza,
                            p_fecha_hoy,
                            v_secuencia,
                            v_empresa,
                            v_ccmayor,
                            v_ccsub,
                            v_ccsubsub,
                            v_ccssubsub,
                            v_ccsssubsub,
                            v_sector,
                            v_nro_auxiliar,
                            cod_ret,
                            tmensaje);
                    ELSE
                        SELECT COUNT(*) INTO v_registros FROM bdicont:co_auxiliar
                        WHERE empresa = p_empresa
                        AND nro_auxiliar = v_nro_auxiliar;

                        IF v_registros = 0 THEN
                            LET cod_ret = "102"; --OK
                            SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
                            INSERT INTO bdicont:tmpco_auditerr
                                (usuario,
                                control_poliza,
                                fecha_captura,
                                secuencia,
                                empresa,
                                ccmayor,
                                ccsub,
                                ccsubsub,
                                ccssubsub,
                                ccsssubsub,
                                sector,
                                auxiliar,
                                cod_ret,
                                mensaje)
                        VALUES (v_usuario,
                                v_control_poliza,
                                p_fecha_hoy,
                                v_secuencia,
                                v_empresa,
                                v_ccmayor,
                                v_ccsub,
                                v_ccsubsub,
                                v_ccssubsub,
                                v_ccsssubsub,
                                v_sector,
                                v_nro_auxiliar,
                                cod_ret,
                                tmensaje);
                                --RETURN cod_ret,v_control_poliza;
                        END IF
                    END IF
                ELSE -- esto no se ha agregado
                    IF v_auxiliarcat = 'S' THEN
                        LET cod_ret = "173"; --OK cambiar el codigo
                        SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
                        INSERT INTO bdicont:tmpco_auditerr
                            (usuario,
                            control_poliza,
                            fecha_captura,
                            secuencia,
                            empresa,
                            ccmayor,
                            ccsub,
                            ccsubsub,
                            ccssubsub,
                            ccsssubsub,
                            sector,
                            auxiliar,
                            cod_ret,
                            mensaje)
                    VALUES (v_usuario,
                            v_control_poliza,
                            p_fecha_hoy,
                            v_secuencia,
                            v_empresa,
                            v_ccmayor,
                            v_ccsub,
                            v_ccsubsub,
                            v_ccssubsub,
                            v_ccsssubsub,
                            v_sector,
                            v_nro_auxiliar,
                            cod_ret,
                            tmensaje);
                    END IF --  hasta aqui
                END IF
            END IF
        END IF

        --VALIDANDO QUE EL CENTRO DE COSTOS DESTINO EXISTA
        IF v_sucursal IS NULL OR TRIM(v_sucursal) = "" THEN
            LET cod_ret = "103"; --ok
            INSERT INTO bdicont:tmpco_auditerr
                  (usuario,
                  control_poliza,
                  fecha_captura,
                  secuencia,
                  empresa,
                  ccmayor,
                  ccsub,
                  ccsubsub,
                  ccssubsub,
                  ccsssubsub,
                  sector,
                  auxiliar,
                  cod_ret,
                  mensaje)
           VALUES (v_usuario,
                  v_control_poliza,
                  p_fecha_hoy,
                  v_secuencia,
                  v_empresa,
                  v_ccmayor,
                  v_ccsub,
                  v_ccsubsub,
                  v_ccssubsub,
                  v_ccsssubsub,
                  v_sector,
                  v_nro_auxiliar,
                  cod_ret,
                  tmensaje);
            --RETURN cod_ret,v_0control_poliza;
        ELSE
            SELECT COUNT(*) INTO v_registros FROM bdinteg:si_sucursales
            WHERE empresa = p_empresa
            AND sucursal = v_sucursal;
            IF v_registros = 0 THEN
                LET cod_ret = "103"; --ok
                SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
                INSERT INTO bdicont:tmpco_auditerr
                    (usuario,
                    control_poliza,
                    fecha_captura,
                    secuencia,
                    empresa,
                    ccmayor,
                    ccsub,
                    ccsubsub,
                    ccssubsub,
                    ccsssubsub,
                    sector,
                    auxiliar,
                    cod_ret,
                    mensaje)
            VALUES (v_usuario,
                    v_control_poliza,
                    p_fecha_hoy,
                    v_secuencia,
                    v_empresa,
                    v_ccmayor,
                    v_ccsub,
                    v_ccsubsub,
                    v_ccssubsub,
                    v_ccsssubsub,
                    v_sector,
                    v_nro_auxiliar,
                    cod_ret,
                    tmensaje);
                --RETURN cod_ret,v_control_poliza;
            END IF
        END IF

        --VALIDANDO QUE LA DESCRIPCION NO SE NULA
        IF v_descripcion_det IS NULL OR trim(v_descripcion_det) = "" THEN
            LET cod_ret = "997"; --OK
            SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
            INSERT INTO bdicont:tmpco_auditerr
                  (usuario,
                  control_poliza,
                  fecha_captura,
                  secuencia,
                  empresa,
                  ccmayor,
                  ccsub,
                  ccsubsub,
                  ccssubsub,
                  ccsssubsub,
                  sector,
                  auxiliar,
                  cod_ret,
                  mensaje)
           VALUES (v_usuario,
                  v_control_poliza,
                  p_fecha_hoy,
                  v_secuencia,
                  v_empresa,
                  v_ccmayor,
                  v_ccsub,
                  v_ccsubsub,
                  v_ccssubsub,
                  v_ccsssubsub,
                  v_sector,
                  v_nro_auxiliar,
                  cod_ret,
                  tmensaje);
            --RETURN cod_ret, v_control_poliza;
        END IF

        --VALIDANDO QUE EXISTA LA MONEDA
        IF v_moneda IS NULL OR trim(v_moneda) = "" THEN
            LET cod_ret = "96a"; --OK
            SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
            INSERT INTO bdicont:tmpco_auditerr
                  (usuario,
                  control_poliza,
                  fecha_captura,
                  secuencia,
                  empresa,
                  ccmayor,
                  ccsub,
                  ccsubsub,
                  ccssubsub,
                  ccsssubsub,
                  sector,
                  auxiliar,
                  cod_ret,
                  mensaje)
           VALUES (v_usuario,
                  v_control_poliza,
                  p_fecha_hoy,
                  v_secuencia,
                  v_empresa,
                  v_ccmayor,
                  v_ccsub,
                  v_ccsubsub,
                  v_ccssubsub,
                  v_ccsssubsub,
                  v_sector,
                  v_nro_auxiliar,
                  cod_ret,
                  tmensaje);
            --RETURN cod_ret, v_control_poliza;
        ELSE
            SELECT COUNT(*) INTO v_registros FROM bdinteg:si_divisas
            WHERE empresa = p_empresa
            AND divisa = v_moneda;
            IF v_registros = 0 THEN
                LET cod_ret = "996"; --OK
                SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
                INSERT INTO bdicont:tmpco_auditerr
                    (usuario,
                    control_poliza,
                    fecha_captura,
                    secuencia,
                    empresa,
                    ccmayor,
                    ccsub,
                    ccsubsub,
                    ccssubsub,
                    ccsssubsub,
                    sector,
                    auxiliar,
                    cod_ret,
                    mensaje)
            VALUES (v_usuario,
                    v_control_poliza,
                    p_fecha_hoy,
                    v_secuencia,
                    v_empresa,
                    v_ccmayor,
                    v_ccsub,
                    v_ccsubsub,
                    v_ccssubsub,
                    v_ccsssubsub,
                    v_sector,
                    v_nro_auxiliar,
                    cod_ret,
                    tmensaje);
                --RETURN cod_ret,v_control_poliza;

            END IF
        END IF

        --VALIDANDO QUE EXISTA EL CENTRO DE COSTO ORIGEN
        IF v_ccosto_orig IS NULL OR trim(v_ccosto_orig) = "" THEN
            LET cod_ret = "165"; --OK
            SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
            INSERT INTO bdicont:tmpco_auditerr
                  (usuario,
                  control_poliza,
                  fecha_captura,
                  secuencia,
                  empresa,
                  ccmayor,
                  ccsub,
                  ccsubsub,
                  ccssubsub,
                  ccsssubsub,
                  sector,
                  auxiliar,
                  cod_ret,
                  mensaje)
           VALUES (v_usuario,
                  v_control_poliza,
                  p_fecha_hoy,
                  v_secuencia,
                  v_empresa,
                  v_ccmayor,
                  v_ccsub,
                  v_ccsubsub,
                  v_ccssubsub,
                  v_ccsssubsub,
                  v_sector,
                  v_nro_auxiliar,
                  cod_ret,
                  tmensaje);
            --RETURN cod_ret,v_control_poliza;
        ELSE
            SELECT COUNT(*) INTO v_registros FROM bdinteg:si_sucursales
            WHERE empresa = p_empresa
            AND sucursal = v_ccosto_orig;
            IF v_registros = 0 THEN
                LET cod_ret = "165"; --OK
                SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
                INSERT INTO bdicont:tmpco_auditerr
                    (usuario,
                    control_poliza,
                    fecha_captura,
                    secuencia,
                    empresa,
                    ccmayor,
                    ccsub,
                    ccsubsub,
                    ccssubsub,
                    ccsssubsub,
                    sector,
                    auxiliar,
                    cod_ret,
                    mensaje)
            VALUES (v_usuario,
                    v_control_poliza,
                    p_fecha_hoy,
                    v_secuencia,
                    v_empresa,
                    v_ccmayor,
                    v_ccsub,
                    v_ccsubsub,
                    v_ccssubsub,
                    v_ccsssubsub,
                    v_sector,
                    v_nro_auxiliar,
                    cod_ret,
                    tmensaje);
                --RETURN cod_ret,v_control_poliza;
            END IF
        END IF
    --END FOREACH

        --VALIDANDO QUE ESTEN NIVELADAS LA CUENTA DE ORDEN
        LET v_bandera = 0;
        IF v_ccmayor >= v_ctaord_ini AND v_ccmayor <= v_ctaord_fin THEN
            --LET v_correlativa = substr(v_ctacor_ini(4),1,1)||substr(v_ccmayor(4),2,4);
            LET v_correlativa = v_ctacor_ini[1,1]||v_ccmayor[2,4];
            FOREACH
                SELECT ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, naturaleza, monto, sucursal
                INTO v_ccmayor_corr, v_ccsub_corr, v_ccsubsub_corr, v_ccssubsub_corr, v_ccsssubsub_corr, v_sector_corr, v_naturaleza_corr, v_monto_corr, v_sucursal_corr
                FROM bdicont:tmpco_detpol WHERE empresa = p_empresa AND control_poliza = v_ctrolpoliza AND usuario = v_usuario AND ccmayor = v_correlativa

                IF v_correlativa = v_ccmayor_corr AND v_ccsub = v_ccsub_corr AND v_ccsubsub = v_ccsubsub_corr AND v_ccssubsub = v_ccssubsub_corr
                AND v_ccsssubsub = v_ccsssubsub_corr AND v_sector = v_sector_corr  AND v_monto = v_monto_corr AND v_naturaleza != v_naturaleza_corr
                AND v_sucursal = v_sucursal_corr THEN
                    LET v_bandera = 1;

                    IF v_monto <> v_monto_corr THEN
                        LET cod_ret = "167";
                        SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
                        INSERT INTO bdicont:tmpco_auditerr
                            (usuario,
                            control_poliza,
                            fecha_captura,
                            secuencia,
                            empresa,
                            ccmayor,
                            ccsub,
                            ccsubsub,
                            ccssubsub,
                            ccsssubsub,
                            sector,
                            auxiliar,
                            cod_ret,
                            mensaje)
                    VALUES (v_usuario,
                            v_control_poliza,
                            p_fecha_hoy,
                            v_secuencia,
                            v_empresa,
                            v_ccmayor,
                            v_ccsub,
                            v_ccsubsub,
                            v_ccssubsub,
                            v_ccsssubsub,
                            v_sector,
                            v_nro_auxiliar,
                            cod_ret,
                            tmensaje);
                        --RETURN cod_ret,v_control_poliza;
                    END IF
                END IF
            END FOREACH;
            IF v_bandera != 1 THEN
                LET cod_ret = "146";
                SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
                INSERT INTO bdicont:tmpco_auditerr
                    (usuario,
                    control_poliza,
                    fecha_captura,
                    secuencia,
                    empresa,
                    ccmayor,
                    ccsub,
                    ccsubsub,
                    ccssubsub,
                    ccsssubsub,
                    sector,
                    auxiliar,
                    cod_ret,
                    mensaje)
            VALUES (v_usuario,
                    v_control_poliza,
                    p_fecha_hoy,
                    v_secuencia,
                    v_empresa,
                    v_ccmayor,
                    v_ccsub,
                    v_ccsubsub,
                    v_ccssubsub,
                    v_ccsssubsub,
                    v_sector,
                    v_nro_auxiliar,
                    cod_ret,
                    tmensaje);
                --RETURN cod_ret,v_control_poliza;
            END IF
        END IF

        --VALIDANDO QUE ESTE NIVELADA LA CUENTA CORRELATIVA
        LET v_bandera = 0;

        IF v_ccmayor >= v_ctacor_ini AND v_ccmayor <= v_ctacor_fin THEN
            LET v_orden = v_ctaord_ini[1,1]||v_ccmayor[2,4];
            FOREACH
                SELECT ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, naturaleza, monto, sucursal
                INTO v_ccmayor_orden, v_ccsub_orden, v_ccsubsub_orden, v_ccssubsub_orden, v_ccsssubsub_orden, v_sector_orden, v_naturaleza_orden, v_monto_orden, v_sucursal_orden
                FROM bdicont:tmpco_detpol WHERE empresa = p_empresa AND control_poliza = v_ctrolpoliza AND usuario = v_usuario AND ccmayor = v_orden

                IF v_orden = v_ccmayor_orden AND v_ccsub = v_ccsub_orden AND v_ccsubsub = v_ccsubsub_orden AND v_ccssubsub = v_ccssubsub_orden
                AND v_ccsssubsub = v_ccsssubsub_orden AND v_sector = v_sector_orden  AND v_monto = v_monto_orden AND v_naturaleza != v_naturaleza_orden
                AND v_sucursal = v_sucursal_orden THEN
                    LET v_bandera = 1;

                    IF v_monto <> v_monto_orden THEN
                        LET cod_ret = "167";
                        SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
                        INSERT INTO bdicont:tmpco_auditerr
                            (usuario,
                            control_poliza,
                            fecha_captura,
                            secuencia,
                            empresa,
                            ccmayor,
                            ccsub,
                            ccsubsub,
                            ccssubsub,
                            ccsssubsub,
                            sector,
                            auxiliar,
                            cod_ret,
                            mensaje)
                    VALUES (v_usuario,
                            v_control_poliza,
                            p_fecha_hoy,
                            v_secuencia,
                            v_empresa,
                            v_ccmayor,
                            v_ccsub,
                            v_ccsubsub,
                            v_ccssubsub,
                            v_ccsssubsub,
                            v_sector,
                            v_nro_auxiliar,
                            cod_ret,
                            tmensaje);
                        --RETURN cod_ret,v_control_poliza;
                    END IF
                END IF
            END FOREACH;

            IF v_bandera != 1 THEN
                LET cod_ret = "146";
                SELECT descripcion INTO tmensaje FROM bdinteg:si_codret WHERE codigo_retorno = cod_ret AND sistema = '07';
                INSERT INTO bdicont:tmpco_auditerr
                    (usuario,
                    control_poliza,
                    fecha_captura,
                    secuencia,
                    empresa,
                    ccmayor,
                    ccsub,
                    ccsubsub,
                    ccssubsub,
                    ccsssubsub,
                    sector,
                    auxiliar,
                    cod_ret,
                    mensaje)
            VALUES (v_usuario,
                    v_control_poliza,
                    p_fecha_hoy,
                    v_secuencia,
                    v_empresa,
                    v_ccmayor,
                    v_ccsub,
                    v_ccsubsub,
                    v_ccssubsub,
                    v_ccsssubsub,
                    v_sector,
                    v_nro_auxiliar,
                    cod_ret,
                    tmensaje);
                --RETURN cod_ret,v_control_poliza;
            END IF
        END IF
    END FOREACH;

               --v_fecha_captura,
               --v_secuencia
               --v_regional,
               --v_naturaleza,
               --v_monto,
               --v_fecha_valida,
               --v_tip_movimiento,

    --VALIDANDO QUE EL MONTO DE LA CUENTA CORRELATIVA Y LA DE ORDEN ESTEN CUADRADOS
    --SELECT NVL(SUM(monto),0) INTO v_sumaorden FROM bdicont:tmpco_detpol WHERE ccmayor >= v_ctaord_ini
    --AND ccmayor <= v_ctaord_fin AND empresa = p_empresa AND control_poliza = v_control_poliza;

    --SELECT NVL(SUM(monto),0) INTO v_sumacorre FROM bdicont:tmpco_detpol WHERE ccmayor >= v_ctacor_ini
    --AND ccmayor <= v_ctacor_fin AND empresa = p_empresa AND control_poliza = v_control_poliza;

    --IF v_sumaorden <> v_sumacorre then
        --LET cod_ret = "167";
        --INSERT INTO bdicont:tmpco_auditerr
            --(usuario,
            --control_poliza,
            --fecha_captura,
            --secuencia,
            --empresa,
            --ccmayor,
            --ccsub,
            --ccsubsub,
            --ccssubsub,
            --ccsssubsub,
            --sector,
            --auxiliar,
            --cod_ret)
     --VALUES (v_usuario,
            --v_control_poliza,
            --v_fecha_captura,
            --v_secuencia,
            --v_empresa,
            --v_ccmayor,
            --v_ccsub,
            --v_ccsubsub,
            --v_ccssubsub,
            --v_ccsssubsub,
            --v_sector,
            --v_nro_auxiliar,
            --cod_ret);
    --END IF

END FOREACH;

    SElECT COUNT(*) INTO v_errors FROM bdicont:tmpco_auditerr;

    IF v_errors <> 0 THEN
    --IF cod_ret <> '000' THEN
        --UNLOAD TO tmpco_auditerr.txt SELECT * FROM bdicont:tmpco_auditerr;
        LET v_directorio ="/tmp/tmpco_auditerr.txt";

        LET v_directorio = TRIM(v_directorio);

        LET v_sql = 'echo "UNLOAD TO ' || TRIM(v_directorio) ||
                    ' SELECT * FROM tmpco_auditerr" > query.sql';
        SYSTEM v_sql;
        LET v_sql = "dbaccess bdicont query.sql ";
        SYSTEM v_sql;
    ELSE
        LET cod_ret = '005';
        --LET v_numreg = 0;

        SELECT max(numero) INTO v_poliza FROM co_ctrlpoliza;
        FOREACH
            --select para el ciclo de la cantidad de polizas
            SELECT control_poliza, usuario
            INTO v_numpoliza, v_usuario
            FROM bdicont:tmpco_detpol
            GROUP BY control_poliza, usuario
            ORDER BY control_poliza, usuario

            --SELECT DISTINCT control_poliza, usuario
            --INTO v_numpoliza
            --FROM bdicont:tmpco_detpol
            --ORDER BY control_poliza

            --select para traer el maximo registro del numero de poliza
            SELECT MAX(control_poliza) INTO v_control_poliza
            FROM bdicont:co_detpol;

                IF v_control_poliza IS NULL THEN
                    LET v_control_poliza = 1;
                ELSE
                    LET v_control_poliza = v_control_poliza + 1;
                END IF

            --WHERE usuario = p_usuario
            --AND fecha_captura = p_fecha_hoy
            --AND empresa = p_empresa;

            SELECT max(numero) INTO v_ctrl_poliza FROM co_ctrlpoliza;
               IF v_ctrl_poliza IS NULL THEN
                    LET v_ctrl_poliza = 1;
               END IF

            IF v_control_poliza = v_ctrl_poliza THEN

                --LET v_control_poliza = v_control_poliza + 1;
                --LET v_control2 = v_control_poliza + 1;

             /* SELECT NVL(SUM(monto),0), usuario, fecha_captura, empresa, moneda
                INTO v_sumaabonos, v_usuario_d, v_fecha_captura_d, v_empresa_d, v_moneda_d
                FROM bdicont:tmpco_detpol
                WHERE naturaleza = "D" AND control_poliza = v_numpoliza
                GROUP BY usuario, fecha_captura, empresa, fecha_valida, moneda;

                IF v_sumaabonos IS NULL THEN
                    LET v_sumaabonos = 0;
                END IF

                SELECT NVL(SUM(monto),0), usuario, fecha_captura, empresa, moneda
                INTO v_sumacargos, v_usuario_c, v_fecha_captura_c, v_empresa_c, v_moneda_c
                FROM bdicont:tmpco_detpol
                WHERE naturaleza = "C" AND control_poliza = v_numpoliza
                GROUP BY usuario, fecha_captura, empresa, fecha_valida, moneda;

                IF v_sumacargos IS NULL THEN
                    LET v_sumacargos = 0;
                END IF

                UPDATE co_ctrlpoliza SET numero = v_control_poliza;

                LET v_descripcion_det_c = 'ENCABEZADO DE LA POLIZA DE NOMINA';

                INSERT INTO bdicont:co_poliza
                            (empresa,
                            usuario,
                            control_poliza,
                            fecha_captura,
                            cifra_control,
                            capturado_cargo,
                            capturado_abono,
                            moneda,
                            descripcion)
                    VALUES (v_empresa_c,
                            v_usuario_c,
                            v_control_poliza,
                            v_fecha_captura_c,
                            v_sumacargos,
                            v_sumacargos,
                            v_sumaabonos,
                            v_moneda_c,
                            v_descripcion_det_c); */
                FOREACH
                    SELECT usuario, control_poliza,
                           fecha_captura, secuencia,
                           empresa, ccmayor, ccsub,
                           ccsubsub, ccssubsub, ccsssubsub,
                           sector, ciudad, sucursal,
                           nro_auxiliar, naturaleza, monto,
                           descripcion_det, fecha_valida,
                           moneda, ccosto_orig
                      INTO v_usuario, v_ctrolpoliza,
                           v_fecha_captura, v_secuencia,
                           v_empresa, v_ccmayor, v_ccsub,
                           v_ccsubsub, v_ccssubsub, v_ccsssubsub,
                           v_sector, v_ciudad, v_sucursal,
                           v_nro_auxiliar, v_naturaleza, v_monto,
                           v_descripcion_det, v_fecha_valida,
                           v_moneda, v_ccosto_orig
                      FROM bdicont:tmpco_detpol
                     WHERE control_poliza = v_numpoliza
                     ORDER BY secuencia

                    --no hay errores, se realiza la insercion

                    INSERT INTO bdicont:co_detpol
                                (usuario, control_poliza,
                                 fecha_captura, secuencia,
                                 empresa, ccmayor, ccsub,
                                 ccsubsub, ccssubsub, ccsssubsub,
                                 sector, ciudad, sucursal,
                                 nro_auxiliar, naturaleza, monto,
                                 descripcion_det, fecha_valida,
                                 moneda, valor_cambio, valor_div_cambio,
                                 mca_aplic, poliza_usuario, tipo_mov, ccosto_orig)
                         VALUES (v_usuario, v_control_poliza,
                                p_fecha_hoy, v_secuencia,
                                v_empresa, v_ccmayor, v_ccsub,
                                v_ccsubsub, v_ccssubsub, v_ccsssubsub,
                                v_sector, v_ciudad, v_sucursal,
                                v_nro_auxiliar, v_naturaleza, v_monto,
                                v_descripcion_det, v_fecha_valida,
                                v_moneda, '',  '', '', v_usuario, v_naturaleza,
                                v_ccosto_orig);
                END FOREACH;
                -------nivelacion por centros de costo -----------
                CALL bdicont:nivelacion_ccostos(p_empresa, p_fecha_hoy) RETURNING cod_ret;

                SELECT NVL(SUM(monto),0), usuario, fecha_captura, empresa, moneda
                INTO v_sumaabonos, v_usuario_d, v_fecha_captura_d, v_empresa_d, v_moneda_d
                FROM bdicont:co_detpol
                WHERE naturaleza = "D" AND control_poliza = v_control_poliza
                GROUP BY usuario, fecha_captura, empresa, fecha_valida, moneda;

                IF v_sumaabonos IS NULL THEN
                    LET v_sumaabonos = 0;
                END IF

                SELECT NVL(SUM(monto),0), usuario, fecha_captura, empresa, moneda
                INTO v_sumacargos, v_usuario_c, v_fecha_captura_c, v_empresa_c, v_moneda_c
                FROM bdicont:co_detpol
                WHERE naturaleza = "C" AND control_poliza = v_control_poliza
                GROUP BY usuario, fecha_captura, empresa, fecha_valida, moneda;

                IF v_sumacargos IS NULL THEN
                    LET v_sumacargos = 0;
                END IF

                UPDATE co_ctrlpoliza SET numero = v_control_poliza + 1;

                LET v_descripcion_det_c = 'ENCABEZADO DE LA POLIZA DE NOMINA';

                INSERT INTO bdicont:co_poliza
                            (empresa,
                            usuario,
                            control_poliza,
                            fecha_captura,
                            cifra_control,
                            capturado_cargo,
                            capturado_abono,
                            moneda,
                            descripcion)
                    VALUES (v_empresa_c,
                            v_usuario_c,
                            v_control_poliza,
                            v_fecha_captura_c,
                            v_sumacargos,
                            v_sumacargos,
                            v_sumaabonos,
                            v_moneda_c,
                            v_descripcion_det_c);
            END IF
        END FOREACH;

        --LET cod_ret = '000';
        IF cod_ret = '000' THEN
            DELETE FROM bdicont:tmpco_detpol;
        ELSE
            DELETE FROM bdicont:co_detpol WHERE empresa = p_empresa AND fecha_captura = p_fecha_hoy AND usuario = p_usuario;
            DELETE FROM bdicont:co_poliza WHERE empresa = p_empresa AND fecha_captura = p_fecha_hoy AND usuario = p_usuario;
            UPDATE bdicont:co_ctrlpoliza SET numero = v_poliza;
            --Si el cod_ret es '005' error al insert
        END IF
    END IF

RETURN cod_ret, v_control_poliza;

END PROCEDURE;