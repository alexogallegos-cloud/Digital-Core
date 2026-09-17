CREATE PROCEDURE "informix".sp_fal_liquidacion_cuenta_inversion(p_idSolicitud INTEGER, p_cta_cliente CHAR(20), p_cta_beneficiario CHAR(20), p_usuario char(8))

  RETURNING CHAR(6) as codigoRetorno,
            CHAR(250) as mensajeRetorno,
            CHAR(1) as tipoAccion,
            CHAR(20) AS cuentaBeneficiario,
            CHAR(20) as cuentaClienteFallecido,
            CHAR(6) as codigoRetornoCancelacion,
            CHAR(250) as mensajeRetornoCancelacion,
            CHAR(100) as nombreBeneficiario;


  -- 0) DEFINICION VARIABLES DE RETORNO
  DEFINE codigoRetorno        CHAR(6);
  DEFINE mensajeRetorno       CHAR(250);
  DEFINE tipoAccion           CHAR(1);
  DEFINE cuentaBeneficiario   CHAR(20);
  DEFINE cuentaClienteFallecido CHAR(20);
  DEFINE codigoRetornoCancelacion CHAR(6);
  DEFINE mensajeRetornoCancelacion CHAR(250);
  DEFINE nombreBeneficiario CHAR(100);

  -- 1) OBTENCION DE INFORMACION DE LA SOLICITUD
  DEFINE resultado_numero_cliente       CHAR(9);
  DEFINE resultado_foliocsuac           CHAR(12);
  DEFINE resultado_fky_usuario_analista INTEGER;
  DEFINE resultado_num_sucursal CHAR(10);

  -- 2) QUERY DE CONTROL
  DEFINE resultado_pky_control_tramite_cuenta   INTEGER;
  DEFINE resultado_num_cta_cliente              CHAR(20);
  DEFINE resultado_num_cta_beneficiario         CHAR(20);
  DEFINE resultado_porcentaje_bene              DECIMAL(9,6);
  DEFINE resultado_tramite                      INTEGER;
  DEFINE resultado_exitoso                      INTEGER;
  DEFINE resultado_tipo_cancelacion             INTEGER;
  --DEFINE resultado_fecha_vencimiento            DATE;
  DEFINE resultado_monto_original               MONEY(14,2);
  DEFINE resultado_monto_cargo					MONEY(14,2);
  DEFINE resultado_monto_inversion                 MONEY(14,2);
  DEFINE resultado_descripcion_detalle          CHAR(100);
  -- 3) NUMERO DE DOCUMENTOS DIGITALIZADOS DEL CLIENTE
  DEFINE v_numero_documentos_necesarios_beneficiario     INTEGER;
  DEFINE v_numero_documentos_digitalizados_beneficiario  INTEGER;

  DEFINE v_numero_documentos_necesarios_fallecido     INTEGER;
  DEFINE v_numero_documentos_digitalizados_fallecido  INTEGER;

  DEFINE resultado_estatus_cuenta_beneficiario  CHAR(1);
  DEFINE resultado_estatus_cuenta_cliente_fallecido CHAR(1);
  DEFINE resultado_estatus_cuenta_eje CHAR(1);
  DEFINE resultado_motivo CHAR(2);
  DEFINE resultado_motivo_eje CHAR(2);
  -- 8) CALCULO DE PORCENTAJE Y MONTO A PAGAR AL BENEFICIARIO
  DEFINE monto_pago_bene            MONEY(14,2);
  DEFINE saldo_cuenta_eje           MONEY(14,2);
  DEFINE saldo_actual           MONEY(14,2);
  -- 9) SE OBTIENE LA ACCION DE ACUERDO AL MONTO POR PAGAR DE LA REGLA DE NEGOCIO
  DEFINE resultado_accion         INTEGER;
  DEFINE resultado_num_empleado   CHAR(8);
  DEFINE resultado_num_suc        CHAR(4);
  DEFINE resultado_pky_rango_importe  INTEGER;
  DEFINE resultado_rango_inferior      MONEY;
  -- bdicheq:"informix".bloqueo_cta
  DEFINE codret_blqcta CHAR(6);
  DEFINE menret_blqcta CHAR(250);

  DEFINE codret_blqcta_eje CHAR(6);
  DEFINE menret_blqcta_eje CHAR(250);

  -- bdicheq:"informix".cargo_red
  DEFINE codret_cargo_ref      CHAR(6);
  DEFINE tranret_cargo_ref     CHAR(4);
  DEFINE fechoy_cargo_ref      DATE;
  DEFINE sdodisp_cargo_ref     MONEY(14,2);
  DEFINE montoret_cargo_ref    MONEY(14,2);
  -- bdicheq:"informix".abono_ref
  DEFINE vcodret_abono  CHAR(6);
  -- 10.2 SE GENERA EL FOLIO SUC
  DEFINE p_fecha_folio  CHAR(10);
  DEFINE p_FolioSUC     CHAR(16);
  -- 10.3 SE OBTIENE EL NUMERO DE TARJETA PARA REALIZAR EL CARGO A CLIENTE
  DEFINE num_tarjeta_cliente      CHAR(20);
  DEFINE num_tarjeta_beneficiario CHAR(20);
  -- VALIDACION DE BANDERA DE CARGO
  DEFINE resultado_cargo_bandera INTEGER;
  -- VALIDACION DE BANDERA DE ABONO
  DEFINE resultado_abono_bandera INTEGER;
  -- CONSTANTES
  DEFINE p_Empresa    CHAR(3);
  DEFINE p_Motivo     INTEGER;
  DEFINE p_Ejecutivo  CHAR(20);
  DEFINE p_tran_aplica_cargo CHAR(4);
  DEFINE p_tran_aplica_abono CHAR(4);

  DEFINE resultado_accion_cumple INTEGER;
  DEFINE resultado_accion_no_cumple INTEGER;
  DEFINE resultado_accion_procede INTEGER;
  DEFINE resultado_accion_no_procede INTEGER;

  DEFINE resultado_aplicado INTEGER;
  DEFINE motivo_cancelacion_debito CHAR(2);

  DEFINE cod_resp_cancelacion_debito CHAR(6);
  DEFINE msj_resp_cancelacion_debito CHAR(250);

  DEFINE resultado_asign_usuario INTEGER;
  DEFINE resultado_asign_num_empleado CHAR(9);

  DEFINE resultado_asign_usuario_2 INTEGER;
  DEFINE resultado_asign_num_empleado_2 CHAR(9);

  DEFINE resultado_nume_cliente CHAR(9);
  DEFINE resultado_nombreBeneficiario CHAR(100);
  DEFINE resultado_representante_legal INTEGER;

  DEFINE resultado_cuenta_abonar CHAR(20);

  DEFINE cargo_inversion  INTEGER;
  DEFINE abono_cuenta_eje INTEGER;
  DEFINE contar_cuentas_exito INTEGER;

  -- DEFINICION DE VARIABLES DE RETORNO
  DEFINE codigo_retorno_traspaso            CHAR(6);
  DEFINE mensaje_retorno_traspaso          CHAR(250);

  DEFINE resultado_cuenta_eje     CHAR(20);
  DEFINE cuenta_inv_cancelada     INTEGER;
  DEFINE saldo_congelado MONEY;
  DEFINE existe_saldo_congelado INTEGER;
  DEFINE resultado_pky_usuario INTEGER;

  DEFINE resultado_tipo_lugar_deceso INTEGER;
  DEFINE resultado_secuencia INTEGER;

  LET existe_saldo_congelado = 0;
  LET saldo_congelado = 0;

  -- 0) DEFINICION DE VARIABLES DE RETORNO
  LET codigoRetorno       = '';
  LET mensajeRetorno      = '';
  LET tipoAccion          = '';
  LET cuentaBeneficiario  = '';
  LET cuentaClienteFallecido = '';

  LET codigo_retorno_traspaso   = '';
  LET mensaje_retorno_traspaso  = '';


  -- 1) OBTENCION DE INFORMACION DE LA SOLICITUD
  LET resultado_numero_cliente = '';
  LET resultado_foliocsuac = '';

  -- 2) QUERY DE CONTROL
  LET resultado_pky_control_tramite_cuenta  = 0;
  LET resultado_num_cta_cliente             = '';
  LET resultado_num_cta_beneficiario        = '';
  LET resultado_porcentaje_bene             = 0;
  LET resultado_tramite                     = 0;
  LET resultado_exitoso                     = 0;
  LET resultado_tipo_cancelacion            = 0;
  --LET resultado_fecha_vencimiento           = DATE(1);
  LET resultado_monto_original              = 0;
  LET resultado_monto_cargo					= 0;
  LET resultado_monto_inversion                = 0;
  -- 3) NUMERO DE DOCUMENTOS DIGITALIZADOS DEL CLIENTE
  LET v_numero_documentos_necesarios_beneficiario    = 0;
  LET v_numero_documentos_digitalizados_beneficiario = 0;

  LET v_numero_documentos_necesarios_fallecido    = 0;
  LET v_numero_documentos_digitalizados_fallecido = 0;

  LET resultado_estatus_cuenta_beneficiario = '';
  LET resultado_estatus_cuenta_cliente_fallecido = '';
  LET resultado_estatus_cuenta_eje = '';
  LET resultado_motivo = '';
  -- 8) CALCULO DE PORCENTAJE Y MONTO A PAGAR AL BENEFICIARIO
  LET monto_pago_bene           = 0;
  -- 9) SE OBTIENE LA ACCION DE ACUERDO AL MONTO POR PAGAR DE LA REGLA DE NEGOCIO
  LET resultado_accion = 0;
  LET resultado_num_empleado = '';
  LET resultado_num_suc = '';
  LET resultado_pky_rango_importe = 0;
  LET resultado_rango_inferior = 0;
  -- 10.3) SE OBTIENE EL NUMERO DE TARJETA PARA REALIZAR EL CARGO A CLIENTE
  LET num_tarjeta_cliente = '';
  LET num_tarjeta_beneficiario = '';
  -- VALIDACION DE BANDERA DE CARGO
  LET resultado_cargo_bandera = 0;

  -- CONSTANTES
  LET p_Empresa   = '001';
  LET p_Ejecutivo = '001';
  LET p_Motivo    = 5;
  LET p_tran_aplica_cargo = '0409';
  LET p_tran_aplica_abono = '0408';

  LET resultado_accion_cumple = 0;
  LET resultado_accion_no_cumple = 0;
  LET resultado_accion_procede = 0;
  LET resultado_accion_no_procede = 0;
  LET resultado_aplicado = 0;

  LET motivo_cancelacion_debito = '04';

  LET resultado_asign_usuario = 0;
  LET resultado_asign_num_empleado = '';
  LET resultado_asign_usuario_2 = 0;
  LET resultado_asign_num_empleado_2 = '';

  LET resultado_nume_cliente = '';
  LET resultado_nombreBeneficiario = '';

  LET resultado_cuenta_eje = '';
  LET resultado_fky_usuario_analista = 0;
  LET cuenta_inv_cancelada = 0;
  LET resultado_pky_usuario = 0;
  LET saldo_actual = 0;
  LET nombreBeneficiario='';
  LET mensajeRetornoCancelacion = '';
  LET codigoRetornoCancelacion = '0';    

  -- SET DEBUG FILE TO "/home/rtechno/logSPFallecidos/liquidacionCuentaInversion_"||p_idSolicitud||"_"||TRIM(p_cta_beneficiario)||"_34.out";
  -- TRACE ON;
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

  BEGIN

      -- OBTENER EL PKY DEL USUARIO
    SELECT pky_usuario
    INTO resultado_pky_usuario
    FROM acl_usuario WHERE num_empleado = p_usuario;

    IF(resultado_pky_usuario) IS NULL THEN
      LET resultado_pky_usuario = 0;
    END IF


    -- VALIDACION DE PARAMETROS DE ENTRADA
    IF p_cta_cliente IS NULL THEN
      LET p_cta_cliente = '';
    END IF
    IF p_cta_beneficiario IS NULL THEN
      LET p_cta_beneficiario = '';
    END IF
    IF p_usuario IS NULL THEN
      LET p_usuario = '';
    END IF

    IF p_idSolicitud is null OR TRIM(p_cta_cliente) = '' OR TRIM(p_cta_beneficiario) = '' OR TRIM(p_usuario) = '' THEN
      LET codigoRetorno       = '000001';                       -- CODIGO DEFINIDO
      LET mensajeRetorno      = 'Información incompleta.';
      LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
      LET cuentaBeneficiario  = '';                             -- CUENTA BENEFICIARIO
      LET cuentaClienteFallecido = '';
      LET codigoRetornoCancelacion = '0';
      LET mensajeRetornoCancelacion = '';
      LET nombreBeneficiario = '';

      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación: Parametros incorrectos.',current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

    END IF

    -- OBTENCION DE INFORMACION DE LA SOLICITUD
    SELECT num_cliente,folio_csuac,fky_usuario_analista,num_sucursal
    INTO resultado_numero_cliente, resultado_foliocsuac,resultado_fky_usuario_analista,resultado_num_sucursal
    FROM fal_solicitud
    WHERE pky_solicitud = p_idSolicitud;

    -- OBTENER NOMBRE BENEFICIARIO, BANDERA DE REPRESENTANTE LEGAL
    SELECT nombre_cliente, representante_legal
    INTO resultado_nombreBeneficiario, resultado_representante_legal
    FROM  fal_beneficiario
    WHERE  pky_cuenta_beneficiario = p_cta_beneficiario
    AND pky_cuenta_cliente_fallecido = p_cta_cliente;

        -- OBTENCION DEL REGISTRO DE LA TABLA DE CONTROL (fal_control_tramite_)
    SELECT pky_control_tramite,
          cuenta_cliente_fallecido,
          cuenta_beneficiario,
          monto_porcentaje,
          tramite,
          exitoso,
          fky_tipo_tramite,
          --fecha_vencimiento_pagare,
          monto_original,
          monto_calculado,
          descripcion_detalle,
          cambio_instruccion_pagare as cargo,
          liquida_pagare as abono
    INTO resultado_pky_control_tramite_cuenta,
          resultado_num_cta_cliente,
          resultado_num_cta_beneficiario,
          resultado_porcentaje_bene,
          resultado_tramite,
          resultado_exitoso,
          resultado_tipo_cancelacion,
          --resultado_fecha_vencimiento,
          resultado_monto_original,
          resultado_monto_inversion,
          resultado_descripcion_detalle,
          cargo_inversion,
          abono_cuenta_eje
    FROM fal_control_tramite
    WHERE fky_solicitud = p_idSolicitud
    AND tramite = 1
    AND exitoso = 0
    AND fky_tipo_tramite = 4-- INVERSION
    AND cuenta_cliente_fallecido = p_cta_cliente
    AND cuenta_beneficiario = p_cta_beneficiario;

    --CONSULTAR CUENTA EJE DE LA CUENTA DE INVERSIï¿½N
    SELECT FIRST 1 cuentadep
    INTO resultado_cuenta_eje
    FROM bdicheq:"informix".sc_maechq qc
    LEFT JOIN bdicheq:"informix".sc_maeinstrucc mae ON (qc.cuenta = mae.cuenta )
    WHERE qc.cuenta = p_cta_cliente;


    --CONGELAR MONTO
    SELECT sdo_cong, sdo_actual
    INTO saldo_congelado, saldo_actual
    FROM bdicheq:"informix".sc_maechq qc
    WHERE qc.cuenta=resultado_cuenta_eje;

	SELECT sum(monto_cargo) 
	INTO resultado_monto_cargo
	FROM fal_control_tramite 
	where cuenta_cliente_fallecido=resultado_cuenta_eje;
	
    SELECT LIMIT 1 monto_original - resultado_monto_cargo
	AS monto_original
    INTO saldo_cuenta_eje
    FROM fal_control_tramite where cuenta_cliente_fallecido=resultado_cuenta_eje;



    IF TRIM(resultado_cuenta_eje) IS NULL OR  TRIM(resultado_cuenta_eje) = ''  THEN

      CALL "informix".sp_fal_liquidacion_asignar_analista(resultado_fky_usuario_analista,p_idSolicitud, p_cta_cliente, p_cta_beneficiario, p_usuario,resultado_nombreBeneficiario,resultado_pky_control_tramite_cuenta)
      RETURNING codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

      LET codigoRetorno       = codigoRetorno;                       -- CODIGO DEFINIDO
      LET mensajeRetorno      = mensajeRetorno;
      LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
      LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
      LET cuentaClienteFallecido = p_cta_cliente;
      LET codigoRetornoCancelacion = '0';
      LET mensajeRetornoCancelacion = '';
      LET nombreBeneficiario = resultado_nombreBeneficiario;

      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación: No se encontró la cuenta eje de la inversión. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
    END IF

    -- NUMERO DE DOCUMENTOS DIGITALIZADOS DEL BENEFICIARIO
    SELECT count(*)
    INTO v_numero_documentos_digitalizados_beneficiario
    FROM fal_control_digitaliza_doc FCDD
    WHERE FCDD.cuenta_cliente_fallecido = resultado_num_cta_cliente AND FCDD.cuenta_beneficiario = resultado_num_cta_beneficiario
    AND FCDD.inconsistencia = 0;

    SELECT count(*)
    INTO v_numero_documentos_necesarios_beneficiario
    FROM fal_cat_tipo_beneficiario CTB
    INNER JOIN fal_beneficiario_gpo_doc BGD ON CTB.pky_tipo_beneficiario = BGD.fky_tipo_beneficiario
    INNER JOIN fal_cat_grupo_documento CGD ON BGD.fky_grupo_documento = CGD.pky_grupo_documento
    INNER JOIN fal_grupo_documento GD ON CGD.pky_grupo_documento = GD.fky_grupo_documento
    INNER JOIN fal_cat_tipo_documento CTD ON GD.fky_tipo_documento = CTD.pky_tipo_documento
    INNER JOIN fal_beneficiario B ON CTB.pky_tipo_beneficiario = B.fky_tipo_beneficiario
    AND B.pky_cuenta_cliente_fallecido = resultado_num_cta_cliente AND B.pky_cuenta_beneficiario = resultado_num_cta_beneficiario;


    -- NUMERO DE DOCUMENTOS DIGITALIZADOS DEL CLIENTE FALLECIDO
    SELECT count(*)
    INTO v_numero_documentos_digitalizados_fallecido
    FROM fal_control_digitaliza_doc FCDD
    WHERE FCDD.cuenta_cliente_fallecido = resultado_numero_cliente AND FCDD.cuenta_beneficiario = resultado_numero_cliente
    AND FCDD.inconsistencia = 0;

    -- SE VALIDA EL TIPO DE LUGAR DE FALLECIMIENTO.
    -- SI ES EN EL EXTRANJERO SE Aï¿½ADE UN DOCUMENTO.
    SELECT fky_lugar_deceso
    INTO resultado_tipo_lugar_deceso
    FROM fal_aviso 
    WHERE fky_solicitud = p_idSolicitud;

    IF  resultado_tipo_lugar_deceso = 2 THEN
      -- SE REALIZA LA CONSULTA POR EL DOCUMENTO ADICIONAL DE LA APOSTILLA
      SELECT count(*)
      INTO v_numero_documentos_necesarios_fallecido
      FROM fal_grupo_documento GD
      INNER JOIN fal_cat_tipo_documento CTD ON GD.fky_tipo_documento = CTD.pky_tipo_documento
      WHERE GD.fky_grupo_documento in (1,2,3);
    ELSE
        
      SELECT count(*)
      INTO v_numero_documentos_necesarios_fallecido
      FROM fal_grupo_documento GD
      INNER JOIN fal_cat_tipo_documento CTD ON GD.fky_tipo_documento = CTD.pky_tipo_documento
      WHERE GD.fky_grupo_documento in (1,2);

    END IF

    --DESCOMENTAR PARA PRUEBAS DE DESARROLLO*****************************************************************************************************
        --LET v_numero_documentos_digitalizados_fallecido=1;
        --LET v_numero_documentos_necesarios_fallecido=1;
        --LET v_numero_documentos_digitalizados_beneficiario=1;
        --LET v_numero_documentos_necesarios_beneficiario=1;
    --DESCOMENTAR PARA PRUEBAS DE DESARROLLO*****************************************************************************************************




    -- ANTES DE REALIZAR LA LIQUIDACION SE VERIFICA EL ESTADO DE LA CUENTA DEL BENEFICIARIO, DEBE ESTAR ACTIVA PARA REALIZAR LA TRANSACCION
    -- ANTES DE REALIZAR LA LIQUIDACION SE VERIFICA EL ESTADO DE LA CUENTA DEL CF, DEBE ESTAR ACTIVA PARA REALIZAR LA TRANSACCION
        SELECT status_cta
        INTO resultado_estatus_cuenta_beneficiario
        FROM bdicheq:"informix".sc_maechq
        WHERE cuenta = p_cta_beneficiario;

        SELECT status_cta, motivo
        INTO resultado_estatus_cuenta_cliente_fallecido,resultado_motivo
        FROM bdicheq:"informix".sc_maechq
        WHERE cuenta = p_cta_cliente;

        SELECT status_cta, motivo
        INTO resultado_estatus_cuenta_eje,resultado_motivo_eje
        FROM bdicheq:"informix".sc_maechq
        WHERE cuenta = resultado_cuenta_eje;

       --LET resultado_pky_control_tramite_cuenta = null;
       --VALIDACIï¿½N DE PROCESO DE LA CUENTA
       IF resultado_pky_control_tramite_cuenta = 0 OR resultado_pky_control_tramite_cuenta IS NULL THEN -- VALIDACION DE PROCESO DE CUENTA

          LET codigoRetorno       = '000009';                       -- CODIGO DEFINIDO
          LET mensajeRetorno      = 'La cuenta ya se ha procesado.';
          LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
          LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
          LET cuentaClienteFallecido = p_cta_cliente;
          LET codigoRetornoCancelacion = '0';
          LET mensajeRetornoCancelacion = '';
          LET nombreBeneficiario = resultado_nombreBeneficiario;

          RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
       END IF

    -- SE VERIFICA QUE SE PUEDA TRAMITAR EL PAGO, SI EL CLIENTE FALLECIDO CUENTA CON TODA LA DOCUMENTACION
    IF v_numero_documentos_necesarios_fallecido = v_numero_documentos_digitalizados_fallecido AND v_numero_documentos_digitalizados_fallecido != 0 THEN

            -- SE VERIFICA QUE SE PUEDA TRAMITAR EL PAGO, SI EL BENEFICIARIO CUENTA CON TODA LA DOCUMENTACION
       IF v_numero_documentos_necesarios_beneficiario = v_numero_documentos_digitalizados_beneficiario AND v_numero_documentos_digitalizados_beneficiario != 0 THEN
        --LET resultado_estatus_cuenta_eje=3;
        --LET resultado_motivo_eje ='04';
        --LET resultado_estatus_cuenta_cliente_fallecido=3;
        --LET resultado_motivo ='04';

        --SI LA CUENTA YA FUE CANCELADA SE PONE LA BANDERA DE CANCELACIï¿½N
        IF (resultado_estatus_cuenta_cliente_fallecido = 2) THEN
            LET cuenta_inv_cancelada = 1;
        END IF

        IF cuenta_inv_cancelada = 0 AND (resultado_estatus_cuenta_cliente_fallecido <> 3 OR resultado_motivo <> '04') THEN
               CALL "informix".sp_fal_liquidacion_asignar_analista(resultado_fky_usuario_analista,p_idSolicitud, p_cta_cliente, p_cta_beneficiario, p_usuario,resultado_nombreBeneficiario,resultado_pky_control_tramite_cuenta)
               RETURNING codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
                  LET codigoRetorno       = codigoRetorno;
                  LET mensajeRetorno      = mensajeRetorno;
                  LET tipoAccion          = '0';
                  LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
                  LET cuentaClienteFallecido = resultado_num_cta_cliente;
                  LET codigoRetornoCancelacion = '0';
                  LET mensajeRetornoCancelacion = '';
                  LET nombreBeneficiario = resultado_nombreBeneficiario;

                  INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                  VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación: El estatus de la cuenta de inversión no está bloqueada por fallecimiento. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);


               RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
        END IF

        IF (resultado_estatus_cuenta_eje = 3 AND resultado_motivo_eje = '04')   THEN
            --VALIDAR TRASPASO DE CUENTAS DE INVERSIï¿½N A CUENTA EJE

            IF (cargo_inversion IS NULL OR cargo_inversion = 0) AND (abono_cuenta_eje IS NULL OR abono_cuenta_eje = 0) THEN
                --MANDAR LLAMAR EL SP DE TRASPASO DE CUENTAS
                CALL sp_fal_traspaso_cuentas_inversion(p_usuario, p_cta_cliente, p_idSolicitud, saldo_cuenta_eje, resultado_monto_original)
                RETURNING codigo_retorno_traspaso, mensaje_retorno_traspaso;
                    --LET codigo_retorno_traspaso = '000000';
                    IF codigo_retorno_traspaso!='000000' THEN

                        CALL "informix".sp_fal_liquidacion_asignar_analista(resultado_fky_usuario_analista,p_idSolicitud, p_cta_cliente, '', p_usuario,'',0)
                        RETURNING codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                        LET codigoRetorno       = codigoRetorno;
                        LET mensajeRetorno      = mensajeRetorno;
                        LET tipoAccion          = '0';
                        LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
                        LET cuentaClienteFallecido = resultado_num_cta_cliente;
                        LET codigoRetornoCancelacion = '0';
                        LET mensajeRetornoCancelacion = '';
                        LET nombreBeneficiario = resultado_nombreBeneficiario;

                        INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                        VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación:' || mensaje_retorno_traspaso || ' CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

                        RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
                    ELSE

                        INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                        VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Traspaso de cuentas de inversión exitoso.', current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

                        UPDATE fal_control_tramite SET cambio_instruccion_pagare = 1, liquida_pagare = 1, fecha_cancelacion = today
                        WHERE cuenta_cliente_fallecido = p_cta_cliente
                        AND fky_tipo_tramite = 4;

                        --CONGELAR MONTO
                        SELECT sdo_cong
                        INTO saldo_congelado
                        FROM bdicheq:"informix".sc_maechq qc
                        WHERE qc.cuenta=resultado_cuenta_eje;
                        LET cuenta_inv_cancelada = 1;
                    END IF
            END IF

            ELSE --IF (resultado_estatus_cuenta_eje = 3 AND resultado_motivo_eje = '04')

                         CALL "informix".sp_fal_liquidacion_asignar_analista(resultado_fky_usuario_analista,p_idSolicitud, p_cta_cliente, p_cta_beneficiario, p_usuario,resultado_nombreBeneficiario,resultado_pky_control_tramite_cuenta)
                         RETURNING codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
                         LET codigoRetorno       = codigoRetorno;
                         LET mensajeRetorno      = mensajeRetorno;
                         LET tipoAccion          = '0';
                         LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
                         LET cuentaClienteFallecido = resultado_num_cta_cliente;
                         LET codigoRetornoCancelacion = '0';
                         LET mensajeRetornoCancelacion = '';
                         LET nombreBeneficiario = resultado_nombreBeneficiario;

                         INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                         VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación: El estatus de la cuenta de eje no está bloqueada por fallecimiento. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

                         RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
            END IF --FIN IF (resultado_estatus_cuenta_eje = 3 AND resultado_motivo_eje = '04')


            --LET resultado_estatus_cuenta_beneficiario = 9;
            --VALIDACIï¿½N DE ESTATUS DE LA CUENTA DEL BENEFICIARIO
             IF TRIM(resultado_estatus_cuenta_beneficiario) not in (1,4,5) THEN
               LET codigoRetorno       = '000002';
               LET mensajeRetorno      = 'Estatus cuenta beneficiario NO ACTIVA.';
               LET tipoAccion          = '0';
               LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
               LET cuentaClienteFallecido = resultado_num_cta_cliente;
               LET codigoRetornoCancelacion = '0';
               LET mensajeRetornoCancelacion = '';
               LET nombreBeneficiario = resultado_nombreBeneficiario;

               INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
               VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación: El estatus de la cuenta del beneficiario no es ACTIVA. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

               RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
             END IF

             IF saldo_congelado > 0 THEN
                LET existe_saldo_congelado = 1;
             END IF




              --LET monto_pago_bene = 0;
              LET monto_pago_bene = resultado_monto_inversion;


              -- SE OBTIENE LA ACCION DE ACUERDO AL MONTO POR PAGAR DE LA REGLA DE NEGOCIO
              SELECT frimp.pky_rango_importe,frimp.rango_inferior
              INTO resultado_pky_rango_importe,resultado_rango_inferior
              FROM fal_solicitud fsol
              INNER JOIN fal_cat_evento ceve ON ceve.pky_evento = fsol.fky_evento AND ceve.fky_origen_evento = fsol.fky_origen_evento
              INNER JOIN fal_regla_negocio frn ON frn.fky_evento = ceve.pky_evento AND frn.fky_origen_evento = ceve.fky_origen_evento
              INNER JOIN fal_rango_importe frimp ON frimp.fky_regla_negocio = frn.pky_regla_negocio
              WHERE frimp.rango_inferior <= monto_pago_bene AND frimp.rango_mayor >= monto_pago_bene
              AND fsol.pky_solicitud = p_idSolicitud
              AND frn.activo = 1;

              -- SE OBTIENEN LAS ACCIONES A REALIZAR POR EL RANGO IMPORTE
              SELECT frimpacc.cumple,frimpacc.no_cumple,frimpacc.procede,frimpacc.no_procede
              INTO resultado_accion_cumple, resultado_accion_no_cumple, resultado_accion_procede, resultado_accion_no_procede
              FROM fal_rango_importe_accion frimpacc
              WHERE frimpacc.fky_rango_importe = resultado_pky_rango_importe;

              -- VALIDACION PARA LA LIQUIDACION A MONTOS MENORES A 1
              IF monto_pago_bene < 1 AND monto_pago_bene > 0 THEN
                LET resultado_rango_inferior = 1;
              END IF

              -- VALIDACION SI ES ACCION NO ES AUTOMATICA
              -- AUTOMATICO CUANDO EL RANGO ES MENOR
              --LET resultado_rango_inferior = 1; -- FLUJO AUTOMATICO
              IF resultado_accion_cumple != 1 THEN
                 IF existe_saldo_congelado = 1 THEN -- CORRESPONDE A BLOQUEO POR MONTO
                    CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '04', 3, today, p_usuario, '', '07', 'A', '12', 'Z')
                    RETURNING codret_blqcta_eje, menret_blqcta_eje;
                 ELSE
                    CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,'0','04',3,today,p_usuario,'','11','S','12','Z')
                    RETURNING codret_blqcta_eje,menret_blqcta_eje;
                 END IF

                  CALL "informix".sp_fal_liquidacion_asignar_analista(resultado_fky_usuario_analista,p_idSolicitud, p_cta_cliente, p_cta_beneficiario, p_usuario,resultado_nombreBeneficiario,resultado_pky_control_tramite_cuenta)
                  RETURNING codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                  LET codigoRetorno       = codigoRetorno;                  -- CODIGO DEFINIDO
                  LET mensajeRetorno      =  mensajeRetorno;
                  LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                  LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                  LET cuentaClienteFallecido = resultado_num_cta_cliente;
                  LET codigoRetornoCancelacion = '0';
                  LET mensajeRetornoCancelacion = '';
                  LET nombreBeneficiario = resultado_nombreBeneficiario;

                  INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                  VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Liquidación: La cuenta se va a central por regla de negocio.',current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

                  RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
              END IF

                        --DESBLOQUEAR LAS CUENTAS PARA HACER EL CARGO Y EL ABONO AL BENEFICIARIO
                        IF existe_saldo_congelado = 1 THEN
                            CALL bdicheq:"informix".bloqueo_cta(p_Empresa,TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '00', 0, today, p_usuario, '4469', '07', 'A', '12', 'Z' )
                            RETURNING codret_blqcta_eje,menret_blqcta_eje;
                        ELSE
                            CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,0,'00',0,today,p_usuario,'4469','07','A','12','Z' )
                            RETURNING codret_blqcta_eje,menret_blqcta_eje;
                        END IF


                       --LET codret_blqcta = '000';
                       --LET codret_blqcta_eje = '000';
                       --VALIDACIï¿½N EN CASO DE QUE NO SE PUEDAN ACTIVAR LAS CUENTAS DEL CLIENTE FALLECIDO (EJE E INVERSIï¿½N)
                       IF (TRIM(codret_blqcta_eje) !='000')  THEN
                          CALL "informix".sp_fal_liquidacion_asignar_analista(resultado_fky_usuario_analista,p_idSolicitud, p_cta_cliente, p_cta_beneficiario, p_usuario,resultado_nombreBeneficiario,resultado_pky_control_tramite_cuenta)
                          RETURNING codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                          LET codigoRetorno       = codret_blqcta_eje;                  -- CODIGO DEFINIDO
                          LET mensajeRetorno      = 'La liquidación de recursos se hará en Central. ';
                          LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                          LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                          LET cuentaClienteFallecido = resultado_num_cta_cliente;
                          LET codigoRetornoCancelacion = '0';
                          LET mensajeRetornoCancelacion = '';
                          LET nombreBeneficiario = resultado_nombreBeneficiario;

                          INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                          VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error de liquidación: Ocurrió un error con el desbloqueo de la cuenta eje.',current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

                          RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                       END IF --VALIDAR CODIGOS DE RETORNO


                       --DESPUES DE ACTIVAR LA CUENTA EJE

                        -- SE GENERA EL FOLIO SUC
                        SELECT substr((current HOUR TO SECOND),1,2) || substr((current HOUR TO SECOND),4,2) || substr((current HOUR TO SECOND),7,2)
                        INTO p_fecha_folio
                        FROM systables WHERE tabid=1;
                        LET p_FolioSUC = trim(p_fecha_folio) || lpad(resultado_foliocsuac,10,0);

                        --OBTENER NUMERO DE TARJETA DE LA CUENTA EJE
						select max(secuencia)
						into resultado_secuencia
                        from bdicheq:sc_tarjeta  st
                        where st.cuenta = resultado_cuenta_eje;
						
                        LET num_tarjeta_cliente = (
                          --select nvl(st.num_tarjeta, '')
                          select case when st.num_tarjeta is null then ''
                          else st.num_tarjeta
                          end
                          from bdicheq:sc_tarjeta  st
                          where st.cuenta = resultado_cuenta_eje
                          and secuencia = resultado_secuencia
                        );

                        -- VERIFICA SI YA SE HIZO EL CARGO AL CLIENTE -
                        SELECT cargo, exitoso
                        INTO resultado_cargo_bandera, resultado_abono_bandera
                        FROM fal_control_tramite
                        WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

                        -- VALIDAR SI LA CUENTA TIENE REPRESENTANTE LEGAL
                        LET resultado_cuenta_abonar = resultado_num_cta_beneficiario;
                        IF resultado_representante_legal = 1 THEN
                          LET resultado_cuenta_abonar = TRIM(resultado_descripcion_detalle);
                        END IF



                        IF resultado_cargo_bandera != 1 THEN -- VALIDACION EN 0 DEL CARGO AL CLIENTE
                          -- EL CARGO AL CLIENTE NO SE HA REALIZADO
                          -- SE EJECUTA EL SP DE CARGO DE MONTO AL CLIENTE
                            CALL bdicheq:"informix".cargo_ref(p_Empresa, resultado_num_sucursal, p_usuario , p_tran_aplica_cargo, '0000', p_FolioSUC, resultado_cuenta_eje, 0, monto_pago_bene, '01', resultado_folioCsuac, num_tarjeta_cliente, p_Ejecutivo)
                            RETURNING codret_cargo_ref, tranret_cargo_ref, fechoy_cargo_ref, sdodisp_cargo_ref, montoret_cargo_ref;

                             --LET codret_cargo_ref = '000';
                             -- VALIDACION DE LA EJECUCION DEL SP DE CARGO
                             IF codret_cargo_ref != '000' THEN

                                UPDATE fal_control_tramite SET cargo = 0
                                WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

                                -- CUANDO NO SE REALIZO EL CARGO AL CLIENTE\-- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE

                                IF existe_saldo_congelado = 1 THEN
                                   CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                                   RETURNING codret_blqcta_eje, menret_blqcta_eje;
                                ELSE
                                   CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,'0','04',3,today,p_usuario,'','11','S','12','Z')
                                   RETURNING codret_blqcta_eje,menret_blqcta_eje;
                                END IF

                                CALL "informix".sp_fal_liquidacion_asignar_analista(resultado_fky_usuario_analista,p_idSolicitud, p_cta_cliente, p_cta_beneficiario, p_usuario,resultado_nombreBeneficiario,resultado_pky_control_tramite_cuenta)
                                RETURNING codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;


                                LET codigoRetorno       = codigoRetorno;                       -- CODIGO DEFINIDO
                                LET mensajeRetorno      = mensajeRetorno;
                                LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                                LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                                LET cuentaClienteFallecido =  resultado_num_cta_cliente;
                                LET codigoRetornoCancelacion = '0';
                                LET mensajeRetornoCancelacion = '';
                                LET nombreBeneficiario = resultado_nombreBeneficiario;


                                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud, 'Error liquidación: No se pudo realizar el cargo al cliente. Cod: ' || codret_cargo_ref || 'Respuesta:' || tranret_cargo_ref ,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

                                RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                             END IF

                            -- ACTUALIZA TABLA DE CONTROL
                            UPDATE fal_control_tramite SET cargo_monto = monto_pago_bene, cargo = 1
                            WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

                        END IF --VALIDACION DE CARGO AL CLIENTE


                       IF resultado_abono_bandera!=1 THEN

                        -- SI SE REALIZO CORRECTAMENTE EL CARGO AL CLIENTE
						select max(secuencia)
							into resultado_secuencia
                            from bdicheq:"informix".sc_tarjeta  st
                            where st.cuenta = resultado_num_cta_beneficiario;
							
                        LET num_tarjeta_beneficiario = (
                          --select nvl(st.num_tarjeta, '')
                          select case when st.num_tarjeta is null then ''
                          else st.num_tarjeta
                          end
                          from bdicheq:"informix".sc_tarjeta  st
                          where st.cuenta = resultado_num_cta_beneficiario
                          and secuencia = resultado_secuencia                          
                        );

                        --############################################################################################################################################################################################################################################################
                        CALL bdicheq:"informix".abono_ref(p_Empresa, resultado_num_sucursal, p_usuario, p_tran_aplica_abono, '0000', p_FolioSUC, resultado_cuenta_abonar, 0, monto_pago_bene, monto_pago_bene, 0, 0, 0, '01', resultado_folioCsuac, num_tarjeta_beneficiario, p_Ejecutivo)
                        RETURNING vcodret_abono;
                        --############################################################################################################################################################################################################################################################
                            --LET vcodret_abono = '000';
                            -- VALIDACION SI SE PUDO HACER EL ABONO AL BENEFICIARIO
                            IF vcodret_abono = '000' THEN
                               -- ACTUALIZA LA TABLA DE BENEFICIARIOS

                               UPDATE fal_control_tramite SET exitoso = 1, monto_cargo = monto_pago_bene, fky_estatus_corporativo = 6 , fky_estatus_sucursal = 3, tramite_analisis = 1
                               WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

                               UPDATE fal_beneficiario  SET aplicado = 1, monto_aplicado = monto_pago_bene, fecha_tramite = sysdate, tramite_aplicado = 1
                               WHERE fky_control_tramite = resultado_pky_control_tramite_cuenta;



                               IF existe_saldo_congelado = 1 THEN
                                  CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                                  RETURNING codret_blqcta_eje, menret_blqcta_eje;
                               ELSE
                                  CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,'0','04',3,today,p_usuario,'','11','S','12','Z')
                                  RETURNING codret_blqcta_eje,menret_blqcta_eje;
                               END IF


                                            --VALIDAR SI SE LIQUIDARON LOS BENEFICIARIOS DE LA CUENTA EJE
                                            SELECT COUNT(*)
                                            INTO contar_cuentas_exito
                                            FROM fal_control_tramite
                                            WHERE cuenta_cliente_fallecido = resultado_cuenta_eje
                                            AND exitoso = 0
                                            AND fecha_cancelacion IS NULL;

                                                IF contar_cuentas_exito = 0 OR contar_cuentas_exito IS NULL THEN --VALIDACION CUENTAS EJE EXITOSAS
                                                  -- VALIDA SI SE PUEDE CANCELAR LA CUENTA:
                                                  CALL sp_fal_cancelacion_cuenta_debito( p_Empresa, TRIM(resultado_cuenta_eje),motivo_cancelacion_debito, p_usuario, TRIM(resultado_num_sucursal))
                                                  RETURNING cod_resp_cancelacion_debito, msj_resp_cancelacion_debito;

                                                  IF cod_resp_cancelacion_debito = '069' THEN --VALIDACION CANCELACION EJE
                                                                -- SE ACTUALIZA LA FECHA DE CANCELACION, ESTATUS CORP, ESTATUS SUC, ESTATUS GENERAL
                                                    UPDATE fal_control_tramite SET fecha_cancelacion = sysdate
                                                    WHERE cuenta_cliente_fallecido = resultado_cuenta_eje
                                                    AND fky_tipo_tramite = 1;

                                                    -- SI SE PUDO REALIZAR LA CANCELACION DE LA CUENTA
                                                      LET codigoRetorno       = '000000';                       -- CODIGO DEFINIDO
                                                      LET mensajeRetorno      = 'La Baja del Cliente se realizó con éxito. La liquidación de recursos se hará en Central.';
                                                      LET tipoAccion          = '1';                            -- ACCION POR REGLA DE NEGOCIO
                                                      LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                                                      LET cuentaClienteFallecido = resultado_num_cta_cliente;
                                                      LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
                                                      LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
                                                      LET nombreBeneficiario = resultado_nombreBeneficiario;

                                                      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                                                      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: La cuenta eje se ha cancelado exitosamente.',current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);
                                                      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                                                  ELSE--VALIDACION CANCELACION EJE

                                                      LET codigoRetorno       = '000000';                       -- CODIGO DEFINIDO
                                                      LET mensajeRetorno      = 'La liquidación de recursos se hará en Central.';
                                                      LET tipoAccion          = '1';                            -- ACCION POR REGLA DE NEGOCIO
                                                      LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                                                      LET cuentaClienteFallecido = resultado_num_cta_cliente;
                                                      LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
                                                      LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
                                                      LET nombreBeneficiario = resultado_nombreBeneficiario;
                                                    
                                                    /***
                                                        IF existe_saldo_congelado = 1 THEN
                                                           CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                                                           RETURNING codret_blqcta_eje, menret_blqcta_eje;
                                                        ELSE
                                                           CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,'0','04',3,today,p_usuario,'','11','S','12','Z')
                                                           RETURNING codret_blqcta_eje,menret_blqcta_eje;
                                                        END IF
                                                    **/

                                                      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                                                      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación cuenta eje: Cod:'||cod_resp_cancelacion_debito || msj_resp_cancelacion_debito,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);
                                                      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                                                  END IF--VALIDACION CANCELACION EJE
                                              END IF--VALIDACION CUENTAS EJE EXITOSAS


                                                                                    -- SI SE PUDO REALIZAR LA CANCELACION DE LA CUENTA
                               LET codigoRetorno       = '000000';                       -- CODIGO DEFINIDO
                               LET mensajeRetorno      = 'La Baja del Cliente se realizó con éxito. La liquidación de recursos se hará en Central.';
                               LET tipoAccion          = '1';                            -- ACCION POR REGLA DE NEGOCIO
                               LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                               LET cuentaClienteFallecido = resultado_num_cta_cliente;
                               LET codigoRetornoCancelacion = '';
                               LET mensajeRetornoCancelacion = '';
                               LET nombreBeneficiario = resultado_nombreBeneficiario;

                               INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                               VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Liquidación a la cuenta de beneficiario exitosa: Bloqueo cuenta eje:'||menret_blqcta_eje,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

                               RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;


                            ELSE --IF vcodret_abono = '000'

                                CALL "informix".sp_fal_liquidacion_asignar_analista(resultado_fky_usuario_analista,p_idSolicitud, p_cta_cliente, p_cta_beneficiario, p_usuario,resultado_nombreBeneficiario,resultado_pky_control_tramite_cuenta)
                                RETURNING codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                                LET codigoRetorno       = codigoRetorno;                       -- CODIGO DEFINIDO
                                LET mensajeRetorno      = mensajeRetorno;
                                LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                                LET cuentaBeneficiario  = resultado_num_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                                LET cuentaClienteFallecido =  resultado_num_cta_cliente;
                                LET codigoRetornoCancelacion = '0';
                                LET mensajeRetornoCancelacion = '';
                                LET nombreBeneficiario = resultado_nombreBeneficiario;

                                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud, 'Error liquidación: No se pudo abonar a la cuenta del beneficiario. Cod: ' || vcodret_abono ,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

                                RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                            END IF -- FIN VALIDACIï¿½N ABONO DE CLIENTE
                      ELSE -- VALIDACIï¿½N SI YA SE HIZO EL ABONO ANTERIORMENTE


                               IF existe_saldo_congelado = 1 THEN
                                  CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                                  RETURNING codret_blqcta_eje, menret_blqcta_eje;
                               ELSE
                                  CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,'0','04',3,today,p_usuario,'','11','S','12','Z')
                                  RETURNING codret_blqcta_eje,menret_blqcta_eje;
                               END IF

                               --VALIDAR SI SE LIQUIDARON LOS BENEFICIARIOS DE LA CUENTA EJE
                               SELECT COUNT(*)
                               INTO contar_cuentas_exito
                               FROM fal_control_tramite
                               WHERE cuenta_cliente_fallecido = resultado_cuenta_eje
                               AND exitoso = 0
                               AND fecha_cancelacion IS NULL;

                               IF contar_cuentas_exito = 0 OR contar_cuentas_exito IS NULL THEN --VALIDACION CUENTAS EJE EXITOSAS
                               -- VALIDA SI SE PUEDE CANCELAR LA CUENTA:
                                  CALL sp_fal_cancelacion_cuenta_debito( p_Empresa, TRIM(resultado_cuenta_eje),motivo_cancelacion_debito, p_usuario, TRIM(resultado_num_sucursal))
                                  RETURNING cod_resp_cancelacion_debito, msj_resp_cancelacion_debito;

                                  IF cod_resp_cancelacion_debito = '069' THEN --VALIDACION CANCELACION EJE
                                  -- SE ACTUALIZA LA FECHA DE CANCELACION, ESTATUS CORP, ESTATUS SUC, ESTATUS GENERAL
                                     UPDATE fal_control_tramite SET fecha_cancelacion = sysdate
                                     WHERE cuenta_cliente_fallecido = resultado_cuenta_eje
                                     AND fky_tipo_tramite = 1;

                                     -- SI SE PUDO REALIZAR LA CANCELACION DE LA CUENTA
                                     LET codigoRetorno       = '000000';                       -- CODIGO DEFINIDO
                                     LET mensajeRetorno      = 'La Baja del Cliente se realizó con éxito. La liquidación de recursos se hará en Central.';
                                     LET tipoAccion          = '1';                            -- ACCION POR REGLA DE NEGOCIO
                                     LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                                     LET cuentaClienteFallecido = resultado_num_cta_cliente;
                                     LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
                                     LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
                                     LET nombreBeneficiario = resultado_nombreBeneficiario;

                                     INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                                     VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: La cuenta eje se ha cancelado exitosamente.',current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);
                                     RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                                  ELSE--VALIDACION CANCELACION EJE
                                    LET codigoRetorno       = '000000';                       -- CODIGO DEFINIDO
                                    LET mensajeRetorno      = 'La liquidación de recursos se hará en Central.';
                                    LET tipoAccion          = '1';                            -- ACCION POR REGLA DE NEGOCIO
                                    LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                                    LET cuentaClienteFallecido = resultado_num_cta_cliente;
                                    LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
                                    LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
                                    LET nombreBeneficiario = resultado_nombreBeneficiario;

                                                    /***
                                                        IF existe_saldo_congelado = 1 THEN
                                                           CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                                                           RETURNING codret_blqcta_eje, menret_blqcta_eje;
                                                        ELSE
                                                           CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,'0','04',3,today,p_usuario,'','11','S','12','Z')
                                                           RETURNING codret_blqcta_eje,menret_blqcta_eje;
                                                        END IF
                                                    **/

                                      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                                      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación cuenta eje: Cod:'||cod_resp_cancelacion_debito || msj_resp_cancelacion_debito,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);
                                      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                                  END IF--VALIDACION CANCELACION EJE
                                END IF--VALIDACION CUENTAS EJE EXITOSAS


                               -- SI SE PUDO REALIZAR LA CANCELACION DE LA CUENTA
                               LET codigoRetorno       = '000000';                       -- CODIGO DEFINIDO
                               LET mensajeRetorno      = 'Esta cuenta ya fue liquidada.';
                               LET tipoAccion          = '1';                            -- ACCION POR REGLA DE NEGOCIO
                               LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                               LET cuentaClienteFallecido = resultado_num_cta_cliente;
                               LET codigoRetornoCancelacion = '';
                               LET mensajeRetornoCancelacion = '';
                               LET nombreBeneficiario = resultado_nombreBeneficiario;

                               RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;


                      END IF -- FIN VALIDACIï¿½N SI YA SE HIZO EL ABONO ANTERIORMENTE

            ELSE --SI NO TIENE LOS DOCUMENTOS COMPLETOS
              -- SE ACTUALIZA LA FECHA DE CANCELACION, ESTATUS CORP, ESTATUS SUC, ESTATUS GENERAL
              UPDATE fal_control_tramite SET fky_estatus_corporativo = 8 , fky_estatus_sucursal = 4
              where pky_control_tramite = resultado_pky_control_tramite_cuenta;

            -- ACCIONES EN CASO DE NO CUMPLIR CON LA CONDICION DE DOCUMENTACION COMPLETA DEL BENEFICIARIO
              LET codigoRetorno       = '000006';                       -- CODIGO DEFINIDO
              LET mensajeRetorno      = 'Se tendrá un plazo de 30 días para digitalizar, de lo contrario se cancelará el proceso.';
              LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
              LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
              LET cuentaClienteFallecido = resultado_num_cta_cliente;
              LET codigoRetornoCancelacion = '0';
              LET mensajeRetornoCancelacion = '';
              LET nombreBeneficiario = resultado_nombreBeneficiario;

              INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
              VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error Liquidación: La documentación del beneficiario está incompleta. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

              RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
            END IF --VALIDACION DE DOCUMENTACION BENEFICIARIO


    ELSE --SI NO TIENE LOS DOCUMENTOS COMPLETOS CF
      -- SE ACTUALIZA LA FECHA DE CANCELACION, ESTATUS CORP, ESTATUS SUC, ESTATUS GENERAL
      UPDATE fal_control_tramite SET fky_estatus_corporativo = 8 , fky_estatus_sucursal = 4
      where pky_control_tramite = resultado_pky_control_tramite_cuenta;

    -- ACCIONES EN CASO DE NO CUMPLIR CON LA CONDICION DE DOCUMENTACION COMPLETA DEL BENEFICIARIO
      LET codigoRetorno       = '000006';                       -- CODIGO DEFINIDO
      LET mensajeRetorno      = 'Se tendrá un plazo de 30 días para digitalizar, de lo contrario se cancelará el proceso.';
      LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
      LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
      LET cuentaClienteFallecido = resultado_num_cta_cliente;
      LET codigoRetornoCancelacion = '0';
      LET mensajeRetornoCancelacion = '';
      LET nombreBeneficiario = resultado_nombreBeneficiario;

      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación: Se tendrá un plazo de 30 días para digitalizar, de lo contrario se cancelará el proceso. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);


      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
    END IF --VALIDACION DE DOCUMENTACION

  END

END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_actualiza_estatus_cuenta(p_cuenta CHAR(20),p_cliente CHAR(9),p_producto INT, p_tipo INT)

    RETURNING CHAR(100) AS estatus_cta;

    DEFINE iSqlErr            INTEGER;

    DEFINE estatus_cuenta     CHAR(100);
    DEFINE movito_bloqueo     CHAR(80);  
    DEFINE res_status_cta     CHAR(50);
    DEFINE codigo_estatus_cta INT;
    DEFINE producto_debito    INT;
    DEFINE producto_credito   INT;
    DEFINE secuenciaMax       CHAR(4);
    

    LET res_status_cta = '';
    LET estatus_cuenta      = '';
    LET codigo_estatus_cta = '0';
    
    LET movito_bloqueo      = '';
    LET producto_credito    = '1';
    LET producto_debito     = '2';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
    BEGIN -- inciando estrutura de SP

        --Instrucciones para el manejo de excepciones
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET estatus_cuenta = '';
                RETURN  'Error: '||iSqlErr; --RETURNING
            END IF;
        END EXCEPTION;
        
--        SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_fal_actualiza_estatus_cuenta"||"_"||TRIM(p_cuenta)||"_34.out"; --> TRACE DESDE APP
--        TRACE ON;

        IF(p_tipo=1) THEN

            IF(p_producto = producto_credito) THEN -- La cuenta de entrada es de tipo ¿CREDITO? (1)

                --Consulta el estatus de la cuenta de Credito. (Tipo bloqueo y Motivo bloqueo)
                SELECT 
                --nvl(tc.descripcion,''),
                case when tc.descripcion is null then ''
                else tc.descripcion
                end,
                --nvl(cb.causa_bloq,'')
                case when cb.causa_bloq is null then ''
                else cb.causa_bloq
                end
                INTO res_status_cta,movito_bloqueo
                FROM bdicred:"informix".sd_maecred mcrd
                RIGHT JOIN bdicred:"informix".sd_tipocartera tc ON tc.status_cred = mcrd.status_cred
                LEFT JOIN bdicred:"informix".sd_causa_bloqueo cb ON cb.cod_causa = mcrd.Cod_caract_2
                WHERE mcrd.numcte = p_cliente
                AND num_credito = p_cuenta;

                --Actualizando la cuenta del cliente CREDITO
                UPDATE fal_saldo_anterior SET estatus_cuenta = res_status_cta,motivo_estatus = movito_bloqueo 
                WHERE num_cuenta_titular = p_cuenta AND numero_cliente = p_cliente;

                --Asignación de información de salida
                LET estatus_cuenta = res_status_cta||'*'||movito_bloqueo;


            END IF;

            IF (p_producto = producto_debito) THEN  
            
                --Consulta el estatus de la cuenta de Debito. (Tipo bloqueo y Motivo bloqueo)
                SELECT 
                --nvl(mst.descripcion,''),
                case when mst.descripcion is null then ''
                else mst.descripcion
                end,
                --nvl(cb.descripcion,'') 
                case when cb.descripcion is null then ''
                else cb.descripcion
                end
                INTO res_status_cta,movito_bloqueo
                FROM bdicheq:"informix".sc_maechq mchq
                RIGHT JOIN bdicheq:"informix".sc_mae_estatus mst ON mst.cod_estatus=mchq.status_cta 
                LEFT JOIN  bdicheq:"informix".sc_bloqueo cb ON cb.codigo=mchq.motivo
                WHERE mchq.num_cte = p_cliente
                AND mchq.cuenta = p_cuenta;

                --Actualizando la cuenta del cliente DEBITO
                UPDATE fal_saldo_anterior SET estatus_cuenta = res_status_cta,motivo_estatus = movito_bloqueo 
                WHERE num_cuenta_titular = p_cuenta AND numero_cliente = p_cliente;

                --Asignación de información de salida

                LET  estatus_cuenta = res_status_cta||'*'||movito_bloqueo;


            END IF;
          RETURN estatus_cuenta;
        END IF;

        IF(p_tipo=2) THEN
            
            --LET estatus_cuenta = '2';
            -- Buscando en DEBITO x cuenta
            SELECT FIRST 1 mchq.status_cta
            INTO codigo_estatus_cta
            FROM bdicheq:sc_maechq mchq
            RIGHT JOIN bdicheq:"informix".sc_mae_estatus mst ON mst.cod_estatus=mchq.status_cta
            LEFT OUTER JOIN bdicheq:"informix".sc_maechq qc ON (qc.num_cte = mchq.num_cte) 
            LEFT OUTER JOIN bdicheq:"informix".sc_producto pr ON (qc.producto = pr.producto ) 
            LEFT JOIN  bdicheq:"informix".sc_bloqueo cb ON cb.codigo=mchq.motivo
            WHERE mchq.cuenta = p_cuenta
            AND pr.producto IN (1300, 1400, 1700, 1900, 2000, 2500);

             LET estatus_cuenta = codigo_estatus_cta;

            IF (codigo_estatus_cta <>'0' AND (codigo_estatus_cta = '1' OR codigo_estatus_cta='4' OR codigo_estatus_cta='5')) THEN
                LET estatus_cuenta = 'CUENTA_VALIDA';
            ELSE
                LET estatus_cuenta = 'CUENTA_NO_VALIDA';
            END IF;

                RETURN  estatus_cuenta;
        END IF;
        
    
        

    END


END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Descripción	: 	Sp que actualiza los estatus de las cuentas en bdiaclaracion:fal_saldo_anterior',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Enero/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_consulta_direccion_cte(p_sNumeroCliente CHAR(20))

     RETURNING CHAR(3) AS codigo, CHAR(100) AS calle,  CHAR(100) AS colonia, 
     CHAR(100) AS municipio, CHAR(100) AS estado, CHAR(100) AS ciudad,  CHAR(10) AS cp ;


    --definicion de variables--     
    DEFINE resultado_codigo                    CHAR(3);
    DEFINE resultado_calle                     CHAR(100);
    DEFINE resultado_colonia                   CHAR(100);
    DEFINE resultado_municipio                 CHAR(100);
    DEFINE resultado_estado                    CHAR(100);
    DEFINE resultado_ciudad                    CHAR(100);
    DEFINE resultado_cp                        CHAR(10);

    DEFINE iSqlErr                             INTEGER;
    
     -- Inicializacion de las variables.
    LET resultado_codigo ='';
    LET resultado_calle = '';
    LET resultado_colonia ='';
    LET resultado_municipio = '';
    LET resultado_estado = '';
    LET resultado_ciudad = '';
    LET resultado_cp = '';



    SET ISOLATION TO DIRTY READ;
            
    BEGIN


        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_codigo = '001';
                LET resultado_calle = '';
                LET resultado_colonia ='';
                LET resultado_municipio = '';
                LET resultado_estado = '';
                LET resultado_ciudad = '';
                LET resultado_cp = '';
                RETURN resultado_codigo, resultado_calle, resultado_colonia, resultado_municipio, resultado_estado, resultado_ciudad, resultado_cp;
            END IF;
        END EXCEPTION;


        LET resultado_codigo ='000';
        SELECT first 1 
        --NVL(Trim(ct.nombrecalle), ' ') as calle, 
        case when ct.nombrecalle is null then ' ' else ct.nombrecalle end as calle,
        --NVL(Trim(sz.nombrezona), ' ') as colonia,  
        case when sz.nombrezona is null then ' ' else sz.nombrezona end as colonia,
        --NVL(Trim(sz.municipiozona), ' ') as municipio, 
        case when sz.municipiozona is null then ' ' else sz.municipiozona end as municipio,
        --NVL(Trim(edo.nombre), ' ') as estado, 
        case when edo.nombre is null then ' ' else edo.nombre end as estado,
        --NVL(ciu.nombre,' ') as ciudad, 
        case when ciu.nombre is null then ' ' else ciu.nombre end as ciudad,
        --NVL(sd.cod_postal,' ')
        case when sd.cod_postal is null then ' ' else sd.cod_postal end
        INTO resultado_calle, resultado_colonia, resultado_municipio, resultado_estado, resultado_ciudad, resultado_cp
        FROM bdinteg:"informix".si_cliente sc
                 Left Outer Join bdinteg:"informix".si_direcciones_actual sd on sc.numcte = sd.numcte and tipo_dir = '1'
                 Left Outer Join bdinteg:"informix".si_estados edo on edo.estado = sd.estado
                 Left Outer Join bdinteg:"informix".si_catcalles ct on ct.numerocalle = sd.numerocalle
                 Left Outer Join bdinteg:"informix".si_catzonas sz on sz.numerociudad = sd.numerociudad and sz.numerocolonia = sd.numerocolonia
                 Left Outer Join bdinteg:"informix".si_ciudades  ciu on ciu.ciudad = sd.numerociudad
        where sc.NUMCTE = p_sNumeroCliente;

        RETURN resultado_codigo, resultado_calle, resultado_colonia, resultado_municipio, resultado_estado, resultado_ciudad, resultado_cp;


    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_busca_nombre_core(p_empleado CHAR(10))

RETURNING  CHAR(80) AS nombre_empleado;
 
DEFINE resultado_nombre_empleado  CHAR(120);

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
           
    SELECT nombre 
    INTO resultado_nombre_empleado
    FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = p_empleado;

    return resultado_nombre_empleado;
END

END PROCEDURE 
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_saldos_deb_cre_cliente(p_sNumeroCliente CHAR(9))

    RETURNING  CHAR(20) AS sumaSaldoCredito, CHAR(20) AS sumaSaldoDebito;

    --definicion de variables--     
    DEFINE saldoCredito MONEY(18,2);
    DEFINE saldoDebito  MONEY(18,2);
    DEFINE sumSaldoCredito MONEY(18,2);
    DEFINE sumSaldoDebito  MONEY(18,2);
    DEFINE sumSaldoCreditoChar CHAR(20);
    DEFINE sumSaldoDebitoChar  CHAR(20);

    --definicion de variables--     
    DEFINE resultado_numeroProducto CHAR(6);
    DEFINE resultado_nombreProducto     CHAR(60);
    DEFINE resultado_numeroCuenta           CHAR(30);
    DEFINE resultado_numeroTarjeta          CHAR(30);

    DEFINE iSqlErr      INTEGER;


    DEFINE resultado_codigo_retorno CHAR(10);
    DEFINE resultado_mensaje_retorno CHAR(10);
    DEFINE resultado_numero_credito CHAR(10);
    DEFINE resultado_codigo_tipcred CHAR(10);
    DEFINE resultado_fecha_origen CHAR(10);
    DEFINE resultado_fecha_prox_pago CHAR(10);
    DEFINE resultado_pago_minimo CHAR(10);
    DEFINE resultado_fecha_ult_pago CHAR(10);
    DEFINE resultado_plazo CHAR(10);
    DEFINE resultado_pagos_realizados CHAR(10);
    DEFINE resultado_linea_otorgada CHAR(10);
    DEFINE resultado_tasa_interes CHAR(10);
    DEFINE resultado_tasa_moratorios CHAR(10);
    DEFINE resultado_monto_sbc CHAR(10);
    DEFINE resultado_cap_vig CHAR(10);
    DEFINE resultado_cap_trans CHAR(10);
    DEFINE resultado_cap_vdo_exig CHAR(10);
    DEFINE resultado_cap_vdo_no_exig CHAR(10); 
    DEFINE resultado_sdo_act_total_cap MONEY;
    DEFINE resultado_int_vig CHAR(10);
    DEFINE resultado_int_vdo CHAR(10);
    DEFINE resultado_int_moratorios CHAR(10);
    DEFINE resultado_int_mes CHAR(10); 
    DEFINE resultado_sdo_act_total_int CHAR(10);
    DEFINE resultado_iva_int_vig CHAR(10);
    DEFINE resultado_iva_int_vdo CHAR(10);
    DEFINE resultado_iva_int_moratorios CHAR(10);
    DEFINE resultado_iva_int_mes CHAR(10);
    DEFINE resultado_sdo_act_total_iva CHAR(10);
    DEFINE resultado_com_pend CHAR(10);
    DEFINE resultado_iva_com CHAR(10);
    DEFINE resultado_sdo_retenido CHAR(10);
    DEFINE resultado_total_liquidacion CHAR(10);
    DEFINE resultado_int_devengado CHAR(10);
    DEFINE resultado_iva_int_devengado CHAR(10);
    DEFINE resultado_linea_disponible CHAR(10);
    DEFINE resultado_pagos_vdos CHAR(10);
    DEFINE resultado_desc_status_cred CHAR(10);
    DEFINE resultado_id_bloqueo_cred CHAR(10);
    DEFINE resultado_bloqueo_cta CHAR(10);
    DEFINE resultado_id_causa_bloqueo_cred CHAR(10);
    DEFINE resultado_causa_bloqueo_cta CHAR(10);
    DEFINE resultado_id_sit_esp_cte CHAR(10);
    DEFINE resultado_id_causa_esp_cte CHAR(10); 
    DEFINE resultado_sit_esp_cte CHAR(10);
    DEFINE resultado_id_sit_esp_cred CHAR(10);
    DEFINE resultado_id_causa_esp_cred CHAR(10);
    DEFINE resultado_sit_esp_cred CHAR(10);
    
     -- Inicializacion de las variables.
    LET saldoCredito = 0;
    LET saldoDebito  = 0;
    LET sumSaldoCredito = 0;
    LET sumSaldoDebito = 0;

    LET resultado_numeroProducto ='';
    LET resultado_nombreProducto = '';
    LET resultado_numeroCuenta = '';
    LET resultado_numeroTarjeta = '';

    --SET DEBUG FILE TO "/home/rtechno/logSPFallecidos/consultacatsaldos.out"; 
    --TRACE ON;
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	        
    BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET saldoCredito = 0;
                LET saldoDebito  = 0;
                LET sumSaldoCredito = 0;
                LET sumSaldoDebito = 0;
                RETURN sumSaldoCredito,sumSaldoDebito;
            END IF;
        END EXCEPTION;

        ---FOREACH PARA OBTENER SALDO DE CREDITOS
        
/**
            SELECT SUM(monto_calculado) 
            INTO resultado_sdo_act_total_cap
            FROM fal_control_tramite tra
            INNER JOIN fal_solicitud sol ON sol.pky_solicitud = tra.fky_solicitud
            WHERE num_cliente = p_sNumeroCliente
            AND fky_tipo_tramite = 2;
**/

            SELECT SUM(saldo) 
            INTO resultado_sdo_act_total_cap
            FROM fal_saldo_anterior 
            WHERE numero_cliente = p_sNumeroCliente
            AND tipo_movimiento_credito=1
            AND fky_tipo_tramite=2;


            IF resultado_sdo_act_total_cap IS NULL THEN
                FOREACH
                    SELECT numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto
                    INTO resultado_numeroProducto, resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta
                    FROM TABLE( FUNCTION sp_fal_busca_producto_cred_cliente(p_sNumeroCliente, 0) )
                    AS a(numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto)

                    SELECT codigo_retorno, mensaje_retorno, numero_credito, codigo_tipcred, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
                                                    tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, sdo_act_total_int, 
                                                    iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, iva_int_devengado, linea_disponible, 
                                                    pagos_vdos, desc_status_cred, id_bloqueo_cred, bloqueo_cta, id_causa_bloqueo_cred, causa_bloqueo_cta, id_sit_esp_cte, id_causa_esp_cte, sit_esp_cte, id_sit_esp_cred, 
                                                    id_causa_esp_cred, sit_esp_cred 
                    INTO resultado_codigo_retorno, resultado_mensaje_retorno, resultado_numero_credito, resultado_codigo_tipcred, resultado_fecha_origen, resultado_fecha_prox_pago, resultado_pago_minimo, resultado_fecha_ult_pago, resultado_plazo, resultado_pagos_realizados, resultado_linea_otorgada, 
                                                    resultado_tasa_interes, resultado_tasa_moratorios, resultado_monto_sbc, resultado_cap_vig, resultado_cap_trans, resultado_cap_vdo_exig, resultado_cap_vdo_no_exig, resultado_sdo_act_total_cap, resultado_int_vig, resultado_int_vdo, resultado_int_moratorios, resultado_int_mes, resultado_sdo_act_total_int, 
                                                    resultado_iva_int_vig, resultado_iva_int_vdo, resultado_iva_int_moratorios, resultado_iva_int_mes, resultado_sdo_act_total_iva, resultado_com_pend, resultado_iva_com, resultado_sdo_retenido, resultado_total_liquidacion, resultado_int_devengado, resultado_iva_int_devengado, resultado_linea_disponible, 
                                                    resultado_pagos_vdos, resultado_desc_status_cred, resultado_id_bloqueo_cred, resultado_bloqueo_cta, resultado_id_causa_bloqueo_cred, resultado_causa_bloqueo_cta, resultado_id_sit_esp_cte, resultado_id_causa_esp_cte, resultado_sit_esp_cte, resultado_id_sit_esp_cred, 
                                                    resultado_id_causa_esp_cred, resultado_sit_esp_cred 
                    FROM TABLE( FUNCTION  bdicred:sp_consulta_saldos_general('001',resultado_numeroCuenta) )
                                           AS a(codigo_retorno, mensaje_retorno, numero_credito, codigo_tipcred, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
                                                    tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, sdo_act_total_int, 
                                                    iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, iva_int_devengado, linea_disponible, 
                                                    pagos_vdos, desc_status_cred, id_bloqueo_cred, bloqueo_cta, id_causa_bloqueo_cred, causa_bloqueo_cta, id_sit_esp_cte, id_causa_esp_cte, sit_esp_cte, id_sit_esp_cred, 
                                                    id_causa_esp_cred, sit_esp_cred );
                 END FOREACH;
            END IF                      
            LET sumSaldoCredito = sumSaldoCredito + resultado_sdo_act_total_cap;

 
        


        --FOREACH PARA OBTENER SALDOS DE PAGARES Y DEBITO
         SELECT SUM(monto_calculado) 
         INTO saldoDebito
         FROM fal_control_tramite tra
         INNER JOIN fal_solicitud sol ON sol.pky_solicitud = tra.fky_solicitud
         WHERE num_cliente = p_sNumeroCliente
         AND fky_tipo_tramite IN(1,3, 4);


         IF saldoDebito IS NULL THEN
            FOREACH 
                SELECT sdo_actual
                INTO saldoDebito
                FROM bdicheq:"informix".sc_maechq qc 
                WHERE num_cte = p_sNumeroCliente
                LET sumSaldoDebito = sumSaldoDebito + saldoDebito;
            END FOREACH;

            FOREACH 
                SELECT FIRST 1 capital
                INTO saldoDebito
                FROM bdinvers:"informix".sv_maeinv 
                WHERE num_cte=p_sNumeroCliente
                AND status_cta = 1
                LET sumSaldoDebito = sumSaldoDebito + saldoDebito;
            END FOREACH;
         END IF

            LET sumSaldoCreditoChar = REPLACE(TO_CHAR(sumSaldoCredito), '$', '');
            LET sumSaldoDebitoChar = REPLACE(TO_CHAR(sumSaldoDebito), '$', '');
            RETURN 
                --NVL(sumSaldoCreditoChar, '0'), 
                case when sumSaldoCreditoChar is null then '0' else sumSaldoCreditoChar end,
                --NVL(sumSaldoDebitoChar, '0');
                case when sumSaldoDebitoChar is null then '0' else sumSaldoDebitoChar end;

    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_busca_creditos_cat (fechaInicial CHAR(10), fechaFinal CHAR(10), origenEvento INTEGER, tipoEvento INTEGER, folioCsuac CHAR(20),  usuarioAnalista INTEGER, numCliente CHAR(9), estatusCorporativo INTEGER)
    RETURNING           CHAR(12)    AS folioCSUAC,
                        CHAR(20)    AS saldoCaptacion,
                        CHAR(20)    AS saldoCredito,
                        CHAR(200)   AS asignado,
                        CHAR(200)   AS origen,
                        CHAR(200)   AS evento,
                        CHAR (9)    AS numeroCliente,
                        CHAR(100)   AS estatusGeneral,
                        CHAR (20)   AS pkySolicitud;
--CHAR (1150) AS cadena_query                        
   --RETURNING           CHAR(1150)    AS Cadena_query;

    DEFINE resultado_cadena_concatenada  CHAR(1150);
    DEFINE query char (850);
    DEFINE pky_solicitud                    CHAR (20);
    DEFINE iSqlErr                          INTEGER;
    DEFINE resultado_folioCSUAC             CHAR(12);
    DEFINE resultado_saldoCaptacion         CHAR(20);
    DEFINE resultado_saldoCredito           CHAR(20);
    DEFINE resultado_asignado               CHAR(200);
    DEFINE resultado_origen                 CHAR(200);
    DEFINE resultado_evento                 CHAR(200);
    DEFINE resultado_numeroCliente          CHAR(9);
    DEFINE resultado_estatusGeneral         CHAR(100);
    DEFINE resultado_fkySolicitud           CHAR(20);
    DEFINE resultado_cuenta_cliente_fallecido  CHAR(20);
    DEFINE resultado_numeroProducto         CHAR(6);
    DEFINE resultado_nombreProducto         CHAR(60);
    DEFINE resultado_numeroCuenta           CHAR(30);
    DEFINE resultado_numeroTarjeta          CHAR(30);
    

    

    LET resultado_folioCSUAC        = '';
    LET resultado_saldoCaptacion    = '0';
    LET resultado_saldoCredito      = '0';
    LET resultado_asignado          = '';
    LET resultado_origen            = '';
    LET resultado_evento            = '';
    LET resultado_numeroCliente     = '';
    LET resultado_estatusGeneral    = '';
    LET resultado_fkySolicitud      = '';
    LET resultado_cuenta_cliente_fallecido = '';
    LET resultado_numeroProducto = '';
    LET resultado_nombreProducto = '';
    LET resultado_numeroCuenta = '';
    LET resultado_numeroTarjeta = '';
    LET resultado_cadena_concatenada = '';
    LET query = 'SELECT pky_solicitud, TRIM(num_cliente), folio_csuac, (select nombre from fal_cat_evento where pky_evento = fky_evento) as evento,  (select nombre from fal_cat_origen_evento where pky_origen_evento = fky_origen_evento) as origen , (select nombre from fal_cat_estatus_general where pky_estatus_general = fky_estatus_general) as estatus_general, (select nombre from acl_usuario where pky_usuario=fky_usuario_analista) as analista  FROM fal_solicitud WHERE fky_estatus_general NOT IN(1)';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    BEGIN 
            ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_cadena_concatenada = '';
                    LET resultado_folioCSUAC        = '';
                    LET resultado_saldoCaptacion    = '';
                    LET resultado_saldoCredito      = '';
                    LET resultado_asignado          = '';
                    LET resultado_origen            = '';
                    LET resultado_evento            = '';
                    LET resultado_numeroCliente     = '';
                    LET resultado_estatusGeneral    = '';
                    LET resultado_fkySolicitud      = '';
                    RETURN resultado_folioCSUAC , resultado_saldoCaptacion , resultado_saldoCredito , resultado_asignado , resultado_origen, resultado_evento, resultado_numeroCliente, resultado_estatusGeneral, resultado_fkySolicitud;
                    --return resultado_cadena_concatenada;
                END IF;
            END EXCEPTION;
            
             LET fechaInicial        = CASE WHEN length(case when fechaInicial is null then '' else fechaInicial end)>0 THEN fechaInicial ELSE NULL END;
             --LET fechaInicial        = CASE WHEN length(NVL(fechaInicial,''))>0 THEN fechaInicial ELSE NULL END;
             LET fechaFinal          = CASE WHEN length(case when fechaFinal is null then '' else fechaFinal end)>0 THEN fechaFinal ELSE NULL END;
             --LET fechaFinal          = CASE WHEN length(NVL(fechaFinal,''))>0 THEN fechaFinal ELSE NULL END;
             LET origenEvento        = CASE WHEN (case when origenEvento is null then 0 else origenEvento end)>0 THEN origenEvento ELSE NULL END;
             --LET origenEvento        = CASE WHEN NVL(origenEvento, 0)>0 THEN origenEvento ELSE NULL END;
             LET tipoEvento          = CASE WHEN (case when tipoEvento is null then 0 else tipoEvento end)>0 THEN tipoEvento ELSE NULL END;
             --LET tipoEvento          = CASE WHEN NVL(tipoEvento, 0)>0 THEN tipoEvento ELSE NULL END;
             LET folioCsuac          = CASE WHEN length(case when folioCsuac is null then '' else folioCsuac end)>0 THEN folioCsuac ELSE NULL END;
             --LET folioCsuac          = CASE WHEN length(NVL(folioCsuac,''))>0 THEN folioCsuac ELSE NULL END;
             LET usuarioAnalista     = CASE WHEN (case when usuarioAnalista is null then 0 else usuarioAnalista end)>0 THEN usuarioAnalista ELSE NULL END;
             --LET usuarioAnalista     = CASE WHEN NVL(usuarioAnalista, 0)>0 THEN usuarioAnalista ELSE NULL END;
             LET numCliente          = CASE WHEN length(case when numCliente is null then '' else numCliente end)>0 THEN numCliente ELSE NULL END;
             --LET numCliente          = CASE WHEN length(NVL(numCliente, ''))>0 THEN numCliente ELSE NULL END;
             LET estatusCorporativo  = CASE WHEN (case when estatusCorporativo is null then 0 else estatusCorporativo end)>0 THEN estatusCorporativo ELSE NULL END;
             --LET estatusCorporativo  = CASE WHEN NVL(estatusCorporativo, 0)>0 THEN estatusCorporativo ELSE NULL END;

             
             
             IF fechaInicial IS NOT NULL AND fechaFinal IS NOT NULL THEN
                LET resultado_cadena_concatenada = "AND fecha_ingreso BETWEEN TO_DATE ('" || fechaInicial || "' ,'%d/%m/%Y') AND TO_DATE('" ||  fechaFinal || "','%d/%m/%Y') " ||resultado_cadena_concatenada;
             END IF;

             IF origenEvento IS NOT NULL THEN
                LET resultado_cadena_concatenada = ' AND fky_origen_evento = ' || origenEvento || ' ' ||resultado_cadena_concatenada;
             END IF;             

             IF tipoEvento IS NOT NULL THEN
                LET resultado_cadena_concatenada = ' AND fky_evento = ' || tipoEvento || ' ' ||resultado_cadena_concatenada;
             END IF;

             IF folioCsuac IS NOT NULL THEN
                LET resultado_cadena_concatenada = ' AND folio_csuac = "' || TRIM (folioCsuac) || '" ' ||resultado_cadena_concatenada;
             END IF;

             IF usuarioAnalista IS NOT NULL THEN
                LET resultado_cadena_concatenada = ' AND fky_usuario_analista = ' || usuarioAnalista || ' ' ||resultado_cadena_concatenada;
             END IF;
             
             --IF estatusCorporativo IS NOT NULL THEN
                --LET resultado_cadena_concatenada = ' AND fky_estatus_corporativo = ' || estatusCorporativo || ' ' ||resultado_cadena_concatenada;
             --END IF;
             
             IF numCliente IS NOT NULL THEN
                LET resultado_cadena_concatenada = ' AND num_cliente = "' || TRIM(numCliente) || '" ' ||resultado_cadena_concatenada;
             END IF;
            
             LET resultado_cadena_concatenada = TRIM (query) || ' '|| TRIM (resultado_cadena_concatenada);
             
             PREPARE stmt_id FROM resultado_cadena_concatenada;
             DECLARE cust_cur cursor FOR stmt_id;

             OPEN cust_cur;
               
                WHILE (1 = 1)
                    FETCH cust_cur INTO resultado_fkySolicitud, resultado_numeroCliente, resultado_folioCSUAC, resultado_evento, resultado_origen, resultado_estatusGeneral, resultado_asignado;
                    IF (SQLCODE != 100) THEN
                               IF estatusCorporativo > 1 THEN
                                   SELECT cuenta_cliente_fallecido 
                                   INTO resultado_cuenta_cliente_fallecido
                                   FROM fal_control_tramite 
                                   WHERE fky_estatus_corporativo = estatusCorporativo
                                   AND fky_solicitud = resultado_fkySolicitud
                                   AND fky_tipo_tramite = 2;
                                   IF resultado_cuenta_cliente_fallecido IS NOT NULL THEN
                                        CALL sp_fal_saldos_deb_cre_cliente(resultado_numeroCliente)
                                        returning resultado_saldoCaptacion, resultado_saldoCredito;
                                        RETURN resultado_folioCSUAC , resultado_saldoCaptacion , resultado_saldoCredito , resultado_asignado , resultado_origen, resultado_evento, resultado_numeroCliente, resultado_estatusGeneral, resultado_fkySolicitud WITH RESUME;
                                   END IF
                            --ESTATUS DE NOTIFICACIÓN
                            ELIF estatusCorporativo = 1 THEN
                                SELECT cuenta_cliente_fallecido 
                                INTO resultado_cuenta_cliente_fallecido
                                FROM fal_control_tramite 
                                WHERE fky_solicitud = resultado_fkySolicitud
                                AND fky_tipo_tramite = 2;
                                IF resultado_cuenta_cliente_fallecido IS NULL THEN
                                    SELECT numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto
                                    INTO resultado_numeroProducto, resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta
                                    FROM TABLE( FUNCTION sp_fal_busca_producto_cred_cliente(resultado_numeroCliente, 0) )
                                    AS a(numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto);
                                    IF (resultado_numeroproducto IS NOT NULL AND resultado_numeroproducto <> '' ) THEN
                                         CALL sp_fal_saldos_deb_cre_cliente(resultado_numeroCliente)
                                             returning resultado_saldoCaptacion, resultado_saldoCredito;
                                         RETURN resultado_folioCSUAC , resultado_saldoCaptacion , resultado_saldoCredito , resultado_asignado , resultado_origen, resultado_evento, resultado_numeroCliente, resultado_estatusGeneral, resultado_fkySolicitud WITH RESUME;
                                    END IF
                            END IF
                            ELSE
                               SELECT cuenta_cliente_fallecido 
                               INTO resultado_cuenta_cliente_fallecido
                               FROM fal_control_tramite 
                               WHERE fky_solicitud = resultado_fkySolicitud
                               AND fky_tipo_tramite = 2;
                               IF resultado_cuenta_cliente_fallecido IS NOT NULL THEN
                                    CALL sp_fal_saldos_deb_cre_cliente(resultado_numeroCliente)
                                    returning resultado_saldoCaptacion, resultado_saldoCredito;
                                    RETURN resultado_folioCSUAC , resultado_saldoCaptacion , resultado_saldoCredito , resultado_asignado , resultado_origen, resultado_evento, resultado_numeroCliente, resultado_estatusGeneral, resultado_fkySolicitud WITH RESUME;
                               ELSE
                                    SELECT numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto
                                    INTO resultado_numeroProducto, resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta
                                    FROM TABLE( FUNCTION sp_fal_busca_producto_cred_cliente(resultado_numeroCliente, 0) )
                                    AS a(numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto);
                                    IF (resultado_numeroproducto IS NOT NULL AND resultado_numeroproducto <> '' ) THEN
                                         CALL sp_fal_saldos_deb_cre_cliente(resultado_numeroCliente)
                                         returning resultado_saldoCaptacion, resultado_saldoCredito;
                                         RETURN resultado_folioCSUAC , resultado_saldoCaptacion , resultado_saldoCredito , resultado_asignado , resultado_origen, resultado_evento, resultado_numeroCliente, resultado_estatusGeneral, resultado_fkySolicitud WITH RESUME;
                                    END IF
                               END IF
                            END IF
                     ELSE
                            EXIT;
                     END IF
                END WHILE
             CLOSE cust_cur;
             FREE cust_cur;
             FREE stmt_id ;
 --      RETURN resultado_folioCSUAC , resultado_saldoCaptacion , resultado_saldoCredito , resultado_asignado , resultado_origen, resultado_evento, resultado_numeroCliente, resultado_estatusGeneral, resultado_fkySolicitud WITH RESUME;
      --return resultado_cadena_concatenada;
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_cancelacion_cuentas_manual(

pSucursal CHAR(4),
pCuenta CHAR(20),
pPromotor CHAR(8),
pSupervisor CHAR(8),
pky_resolucion INTEGER,
p_idSolicitud INTEGER,
pEmpresa CHAR(3),
pMotivo CHAR(2),
pTipoCuenta INTEGER)

  RETURNING CHAR(6) as codigoRetorno, CHAR(250) as mensajeRetorno;


DEFINE codigoRetorno        CHAR(6);
DEFINE mensajeRetorno       CHAR(250);
DEFINE tipoCuentaCredito    INTEGER;
DEFINE cancelacionManual    INTEGER;
DEFINE resultado_pky_usuario INTEGER;
DEFINE resultado_foliocsuac CHAR (11);

DEFINE iSqlErr              INTEGER;

--Variables de retorno Credito

DEFINE codigoRetornoCrd CHAR(6);
DEFINE mensajeRetornoCrd CHAR(250);
DEFINE numeroCredito CHAR(20);
DEFINE numeroTarjeta CHAR(16);

DEFINE codigoRetornoDeb CHAR(6);
DEFINE mensajeRetornoDeb CHAR(250);


--Obteniendo pky de cuenta de crédito
LET tipoCuentaCredito = (SELECT pky_tipo_tramite from fal_cat_tipo_tramite where nombre ='Crédito');
LET resultado_pky_usuario = (SELECT pky_usuario FROM acl_usuario where usuario= pPromotor);
LET cancelacionManual ='1';
LET resultado_foliocsuac = (select folio_csuac from fal_solicitud WHERE pky_solicitud = p_idSolicitud);

--SET DEBUG FILE TO "/home/rtechno/logSPFallecidos/sp_fal_cancelacion_cuentas_manual"||p_idSolicitud||".out"; 
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
	
BEGIN

 ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                
                RETURN  iSqlErr,'Error SQL'; --RETURNING
            END IF;
 END EXCEPTION;

    -- VALIDACIÓN DE CANCELACIÓN PARA CREDITO

    IF (pTipoCuenta = tipoCuentaCredito) THEN 
        
            CALL sp_fal_cancelacion_cuenta_credito(p_idSolicitud,pCuenta,pPromotor,pSupervisor,pSucursal,pky_resolucion,'1')
            RETURNING codigoRetornoCrd,mensajeRetornoCrd,numeroCredito,numeroTarjeta;

            IF(codigoRetornoCrd = '000000') THEN 
                
                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación manual: La cuenta '||pCuenta||' se ha cancelado exitosamente.',today,resultado_foliocsuac,'CANCELACION MANUAL CREDITO EXITOSA',resultado_pky_usuario,pPromotor);
                
                UPDATE fal_control_tramite SET fecha_cancelacion = CURRENT WHERE cuenta_cliente_fallecido = pCuenta;

                LET codigoRetorno = '000000';
                LET mensajeRetorno = 'Se ha cancelado exitosamente la cuenta.';
                
                ELSE IF (codigoRetornoCrd <> '000000') THEN 

                    INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                    VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación manual: La cuenta '||pCuenta||' no se ha cancelado.',today,resultado_foliocsuac,'CANCELACION MANUAL CREDITO NO EXITOSA',resultado_pky_usuario,pPromotor);
                    
                LET codigoRetorno = '000001';
                LET mensajeRetorno = 'No se cancelo exitosamente la cuenta.';    
                END IF;

                RETURN codigoRetorno,mensajeRetorno;
            END IF;

        ELSE IF (pTipoCuenta <> tipoCuentaCredito) THEN
      
                CALL "informix".sp_fal_cancelacion_cuenta_debito( pEmpresa,pCuenta, pMotivo,pPromotor,pSucursal)
                RETURNING codigoRetornoDeb,mensajeRetornoDeb;

                    IF(codigoRetornoDeb = '069') THEN
                
                            INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                            VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación manual: La cuenta '||pCuenta||' se ha cancelado exitosamente.',today,resultado_foliocsuac,'CANCELACION MANUAL EXITOSA',resultado_pky_usuario,pPromotor);

                            UPDATE fal_control_tramite SET fecha_cancelacion = CURRENT WHERE cuenta_cliente_fallecido = pCuenta;

                            LET codigoRetorno = '000000';
                            LET mensajeRetorno = 'Se ha cancelado exitosamente la cuenta.';
                
                
                     ELSE IF (codigoRetornoDeb <> '069') THEN 

                        INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                        VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación manual: La cuenta '||pCuenta||' no se ha cancelado.',today,resultado_foliocsuac,'CANCELACION MANUAL NO EXITOSA',resultado_pky_usuario,pPromotor);
                        
                        LET codigoRetorno = '000001';
                        LET mensajeRetorno = 'No se cancelo exitosamente la cuenta.';

                      END IF;                  END IF; -- Cancelacion correcta de debito.
            RETURN codigoRetorno,mensajeRetorno;        END IF;    END IF;END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_buscarclientespornumero (p_sNumeroCliente CHAR(30))

     RETURNING	CHAR(20) AS noCliente, CHAR(30) AS primerApellido, CHAR(30) AS segundoApellido, CHAR(30) AS primerNombre, CHAR(30) AS segundoNombre;

	--definicion de variables--
	DEFINE resultado_numeroCliente 		CHAR(20);
	DEFINE resultado_primerApellido		CHAR(30);
	DEFINE resultado_segundoApellido	CHAR(30);
    DEFINE resultado_primerNombre		CHAR(30);
    DEFINE resultado_segundoNombre		CHAR(30);
    DEFINE resultado_numerotransfer     CHAR(30);

    DEFINE iSqlErr                      INTEGER;

     	-- Inicializacion de las variables.
	LET resultado_numeroCliente = '';
	LET resultado_primerApellido = '';
	LET resultado_segundoApellido = '';
	LET resultado_primerNombre = '';
	LET resultado_segundoNombre = '';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_numeroCliente = '';
                    LET resultado_primerApellido = '';
                    LET resultado_segundoApellido = '';
                    LET resultado_primerNombre = '';
                    LET resultado_segundoNombre = '';

                    RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;
                END IF;
        END EXCEPTION;

	SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno
		INTO resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido
		FROM bdinteg:si_cliente
		WHERE p_sNumeroCliente = numcte and tipo_cliente=1;


   IF ( resultado_primerNombre IS NULL) THEN

      SELECT bditransfer:tf_maecte.numcte
      INTO resultado_numerotransfer
         FROM bditransfer:tf_maecte
        WHERE bditransfer:tf_maecte.numcte_tf = p_sNumeroCliente;

     SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno
		INTO resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido
		FROM bdinteg:si_cliente
		WHERE resultado_numerotransfer = numcte and tipo_cliente=1;


    END IF;



   RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;



	END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_buscarclientesportelefonotransfer (p_sNumeroTelefonoTransfer CHAR(30))

     RETURNING	CHAR(20) AS noCliente, CHAR(30) AS primerApellido, CHAR(30) AS segundoApellido, CHAR(30) AS primerNombre, CHAR(30) AS segundoNombre;

	--definicion de variables--
	DEFINE resultado_numeroCliente 		CHAR(20);
	DEFINE resultado_primerApellido		CHAR(30);
	DEFINE resultado_segundoApellido	CHAR(30);
	DEFINE resultado_primerNombre		CHAR(30);
	DEFINE resultado_segundoNombre		CHAR(30);
	DEFINE telefono_Transfer		CHAR(30);
	DEFINE iSqlErr                     	INTEGER;

    -- Inicialización de las variables.
	LET resultado_numeroCliente = '';
	LET resultado_primerApellido = '';
	LET resultado_segundoApellido = '';
	LET resultado_primerNombre = '';
	LET resultado_segundoNombre = '';
	LET telefono_Transfer = '';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_numeroCliente = '';
                    LET resultado_primerApellido = '';
                    LET resultado_segundoApellido = '';
                    LET resultado_primerNombre = '';
                    LET resultado_segundoNombre = '';
                    RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;
                END IF;
        END EXCEPTION;

            SELECT numcte
            INTO resultado_numeroCliente
            FROM bditransfer:tf_maecte
            WHERE empresa = '001'
              AND telefono = p_sNumeroTelefonoTransfer;



		IF ( resultado_numeroCliente IS NULL ) THEN
           let resultado_numeroCliente = '';
        ELSE
            SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno
              INTO resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido
              FROM bdinteg:si_cliente
             WHERE numcte = resultado_numeroCliente
             AND tipo_cliente=1;
{
            IF ( resultado_numeroCliente IS NULL ) THEN

				LET resultado_numeroCliente = '';
				LET resultado_primerApellido = '';
				LET resultado_segundoApellido = '';
				LET resultado_primerNombre = '';
				LET resultado_segundoNombre = '';

            END IF;
}
        END IF;

        RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;

	END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_busca_productos_deb_cte_fallecido(p_sNumeroCliente CHAR(20))

     RETURNING  
                        CHAR(6) AS numeroProducto,
                        CHAR(60) AS nombreProducto, 
                        CHAR(30) AS numeroCuenta, 
                        CHAR(30) AS estatus , 
                        CHAR(100) AS motivo,
                        MONEY(16)   AS montoActual,
                        CHAR(30) AS numeroCuentaDeposito,
                        CHAR(30) AS fechaVenc;

    --definicion de variables--     
    DEFINE resultado_numeroProducto CHAR(6);
    DEFINE resultado_nombreProducto     CHAR(60);
    DEFINE resultado_numeroCuenta       CHAR(30);
    DEFINE resultado_estatus                CHAR(30);
    DEFINE resultado_motivo                 CHAR(100);
    DEFINE resultado_montoActual           MONEY(16);
    DEFINE resultado_cuentaDeposito          CHAR(30);
    DEFINE resultado_fechaVenc               CHAR(30);
    DEFINE iSqlErr                                INTEGER;
    
     -- Inicializacion de las variables.
    LET resultado_numeroProducto ='';
    LET resultado_nombreProducto = '';
    LET resultado_numeroCuenta = '';
    LET resultado_estatus = '';
    LET resultado_motivo = '';
    LET resultado_montoActual = 0;
    LET resultado_cuentaDeposito = '';
    LET resultado_fechaVenc = '';
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	        
    BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto = '';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_estatus = '';
                LET resultado_motivo = '';
                LET resultado_montoActual = 0;
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_estatus,resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc;
            END IF;
        END EXCEPTION;

        FOREACH
   
            SELECT DISTINCT qc.producto as numeroProducto, 
                        pr.nombre AS nombreProducto,
                        qc. cuenta AS cuentaProducto,
                        --qc.status_cta as estatus,
                        stc.descripcion as estatus,
                        bl.descripcion as motivo,
                        qc.sdo_actual,
                        mae.cuentadep as cuentaDeposito ,
                        vin.fecha_vencimiento as fechaDepostio
                        INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_estatus,resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc
                        FROM bdicheq:sc_maechq qc
                        LEFT JOIN bdicheq:"informix".sc_bloqueo bl ON (qc.motivo = bl.codigo)
                        LEFT JOIN bdicheq:"informix".sc_producto pr ON (qc.producto = pr.producto ) 
                        LEFT JOIN fal_cat_estatus_cuenta stc ON (qc.status_cta = stc.pky_estatus_cuenta )
                        LEFT JOIN bdicheq:"informix".sc_maeinstrucc mae ON (qc.cuenta = mae.cuenta )  
                        LEFT JOIN bdicheq:"informix".sc_vencinvpag vin ON (vin.numcta = mae.cuenta )                
                        WHERE qc.num_cte = p_sNumeroCliente
                        AND qc.status_cta not in (2)
/*
                    SELECT monto_original
                    INTO v_monto_original
                    FROM fal_control_tramite fct
                    WHERE fct.cuenta_cliente_fallecido = qc. cuenta
                    AND tramite = 1;

                    IF v_monto_original <> NULL THEN
                        LET 
                    ELSE
                        RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta ,resultado_estatus, resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc WITH RESUME;
                    END IF*/
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta ,resultado_estatus, resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc WITH RESUME;
        
        END FOREACH;
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_busca_productos_deb_cte_fallecido_1(p_sNumeroCliente CHAR(20))

     RETURNING  
                        CHAR(6) AS numeroProducto,
                        CHAR(60) AS nombreProducto, 
                        CHAR(30) AS numeroCuenta, 
                        CHAR(30) AS estatus , 
                        CHAR(100) AS motivo,
                        MONEY(16)   AS montoActual,
                        CHAR(30) AS numeroCuentaDeposito,
                        CHAR(30) AS fechaVenc;

    --definicion de variables--     
    DEFINE resultado_numeroProducto CHAR(6);
    DEFINE resultado_nombreProducto     CHAR(60);
    DEFINE resultado_numeroCuenta       CHAR(30);
    DEFINE resultado_estatus                CHAR(30);
    DEFINE resultado_motivo                 CHAR(100);
    DEFINE resultado_montoActual           MONEY(16);
    DEFINE resultado_cuentaDeposito          CHAR(30);
    DEFINE resultado_fechaVenc               CHAR(30);
    DEFINE iSqlErr                                INTEGER;
    
     -- Inicializacion de las variables.
    LET resultado_numeroProducto ='';
    LET resultado_nombreProducto = '';
    LET resultado_numeroCuenta = '';
    LET resultado_estatus = '';
    LET resultado_motivo = '';
    LET resultado_montoActual = 0;
    LET resultado_cuentaDeposito = '';
    LET resultado_fechaVenc = '';
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	        
    BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto = '';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_estatus = '';
                LET resultado_motivo = '';
                LET resultado_montoActual = 0;
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_estatus,resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc;
            END IF;
        END EXCEPTION;

        FOREACH

                SELECT DISTINCT qc.producto as numeroProducto, 
                pr.nombre AS nombreProducto,
                        qc. cuenta AS cuentaProducto,
                        --qc.status_cta as estatus,
                        stc.descripcion as estatus,
                        bl.descripcion as motivo,
                        qc.sdo_actual,
                        mae.cuentadep as cuentaDeposito ,
                        vin.fecha_vencimiento as fechaDepostio
                        INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_estatus,resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc
                        FROM bdicheq:sc_maechq qc
                        LEFT JOIN bdicheq:"informix".sc_bloqueo bl ON (qc.motivo = bl.codigo)
                        LEFT JOIN bdicheq:"informix".sc_producto pr ON (qc.producto = pr.producto ) 
                        LEFT JOIN fal_cat_estatus_cuenta stc ON (qc.status_cta = stc.pky_estatus_cuenta )
                        LEFT JOIN bdicheq:"informix".sc_maeinstrucc mae ON (qc.cuenta = mae.cuenta )  
                        LEFT JOIN bdicheq:"informix".sc_vencinvpag vin ON (vin.numcta = mae.cuenta )
                        INNER JOIN bdicheq:"informix".sc_maechq cd ON cd.cuenta = mae.cuentadep
                        INNER JOIN fal_control_tramite con ON con.cuenta_cliente_fallecido = qc.cuenta
                        WHERE qc.num_cte = p_sNumeroCliente 
                        AND cd.status_cta not in( 2)
                        AND qc.status_cta = 2
                        AND pr.producto = '1100'


                        RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta ,resultado_estatus, resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc WITH RESUME;

        END FOREACH;
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_mueve_aclaraciones_historico_pendiente()

RETURNING CHAR(5);

-- *********************************************************************
-- *                        DEFINICION DE VARIABLES                    *
-- *********************************************************************
DEFINE scod_ret         CHAR(5);
DEFINE vsqlerr          INTEGER;
DEFINE v_pky_aclaracion CHAR(20);
DEFINE icontador        INTEGER;
DEFINE v_folio_csuac    VARCHAR(11);
DEFINE v_sol_eglobal    INTEGER;
DEFINE v_res_eglobal    INTEGER;
DEFINE v_fecha_limit    DATE;
DEFINE vsql	        	char(3000);
Define cCadena 			CHAR(1000);
DEFINE respuesta_repetida_e_global	INTEGER;
DEFINE solicitud_faltante_e_global	INTEGER;
DEFINE cRuta CHAR(100);
DEFINE horaActual     datetime year to fraction;
DEFINE horafinal     datetime year to fraction;
DEFINE v_pky_movimiento CHAR(20);
DEFINE v_pky_movimiento2 CHAR(20);
DEFINE v_pky_bitacora CHAR(20);
DEFINE v_resul_mov INTEGER;

LET v_resul_mov = NULL;
LET scod_ret  = "00000";
LET vsqlerr = 0;
LET icontador=1;
		--SET DEBUG FILE TO "/ifxsif01/reydavid/mover.out";
		--TRACE ON;
		
		IF EXISTS( SELECT * FROM systables WHERE tabname ='temp_mov_2') THEN
			DROP TABLE "informix".temp_mov_2;
		END IF;
--Verificar tabla fisica
		IF EXISTS( SELECT * FROM systables WHERE tabname ='temp_bitacora') THEN
			DROP TABLE "informix".temp_bitacora;
		END IF;
		IF EXISTS( SELECT * FROM systables WHERE tabname ='temp_mov') THEN
			DROP TABLE "informix".temp_mov;
		END IF;
--Verificar tabla fisica
		IF EXISTS( SELECT * FROM systables WHERE tabname ='temp_mov_3') THEN
			DROP TABLE "informix".temp_mov_3;
		END IF;

	CREATE /*TEMP*/ table temp_mov(
		pky_movimiento    integer,
		fky_padre integer);
---	CREATE /*TEMP*/ table temp_mov_2(
--		pky_movimiento    integer);
--	CREATE /*TEMP*/ table temp_mov_3(
--		pky_movimiento   integer,
--		fky_padre integer);
	CREATE /*TEMP*/ table temp_bitacora(
		pky_bitacora   integer);

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
	   LET scod_ret=vsqlerr;
	   ROLLBACK WORK;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;


			INSERT INTO temp_bitacora		
			select pky_bitacora from "informix".acl_sistema_bitacora_his;
----------------
			INSERT INTO temp_mov
			SELECT pky_movimiento, fky_padre
			FROM "informix".acl_movimiento_his where (fky_aclaracion in(select pky_aclaracion from temp_aclara) or folio_csuac in(select folio_csuac from temp_aclara where folio_csuac is not null)) and fky_padre is not null order by fky_padre asc; 
			--fky_padre is not null;
			INSERT INTO temp_mov
			SELECT pky_movimiento,fky_padre
			FROM "informix".acl_movimiento_his where (fky_aclaracion in(select pky_aclaracion from temp_aclara) or folio_csuac in(select folio_csuac from temp_aclara where folio_csuac is not null)) and fky_padre is null order by pky_movimiento asc;
			--fky_padre is null;
			
			INSERT INTO temp_mov
			SELECT pky_movimiento, fky_padre
			FROM "informix".acl_movimiento_his where fky_aclaracion is null and folio_csuac is null and fechahora <= (select last_day(add_months(((today) - 1 units year),-(month(today)))) from bdinteg:"informix".si_fechas where empresa=001)  order by pky_movimiento asc;
		
FOREACH WITH HOLD
			
			select pky_aclaracion, folio_csuac
			into v_pky_aclaracion,v_folio_csuac
			from temp_aclara 
		BEGIN WORK;	
			INSERT INTO "informix".acl_documento_his 
			select * from "informix".acl_documento WHERE fky_aclaracion =v_pky_aclaracion and folio_csuac = v_folio_csuac;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_aclaracion, folio_csuac
			into v_pky_aclaracion,v_folio_csuac
			from temp_aclara
		BEGIN WORK;	
        		 --********************Eliminacion de historico en entrada bitacora
			delete from "informix".acl_entrada_bitacora WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico en documentos
			delete from "informix".acl_documento WHERE  fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico en documentos
			delete from "informix".acl_recuperacion_saldos WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico de solicitud E-GALOBAL
			--********************Eliminacion de historico de control de aclaraciones via telefonica
			delete from "informix".acl_control_aclaracion_tel WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico de regulatorio 27
			delete from "informix".acl_regulatorio27 WHERE folio_csuac = v_folio_csuac;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_movimiento
			into v_pky_movimiento
			from temp_mov where fky_padre is not null --order by pky_movimiento desc
		BEGIN WORK;	
			LET v_resul_mov = v_pky_movimiento;
			--********************Eliminacion de historico en movimiento
			UPDATE "informix".acl_movimiento SET fky_padre = NULL WHERE pky_movimiento = v_pky_movimiento;
			LET v_resul_mov = NULL;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_movimiento
			into v_pky_movimiento
			from temp_mov order by fky_padre desc
		BEGIN WORK;	
			LET v_resul_mov = v_pky_movimiento;
			--********************Eliminacion de historico en movimiento
			delete from "informix".acl_movimiento WHERE pky_movimiento = v_pky_movimiento;
			LET v_resul_mov = NULL;
		COMMIT WORK;
END FOREACH;


FOREACH WITH HOLD		
			select pky_solicitud_e_global
			into v_sol_eglobal
			from temp_solic
		BEGIN WORK;	
			--********************Eliminacion de historico de Solicitud E-GALOBAL
			delete from "informix".acl_solicitud_e_global WHERE pky_solicitud_e_global = v_sol_eglobal;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD		
			select pky_respuesta_e_global
			into v_res_eglobal
			from temp_respues
		BEGIN WORK;	
    	--********************Eliminacion de historico de respuesta E-GALOBAL
			delete from "informix".acl_respuesta_e_global WHERE pky_respuesta_e_global = v_res_eglobal;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_aclaracion
			into v_pky_aclaracion
			from temp_aclara
		BEGIN WORK;	
		---********* Se elimina la informacion principal de aclaraciones********
			delete from "informix".acl_aclaracion WHERE  pky_aclaracion = v_pky_aclaracion;
		COMMIT WORK;
END FOREACH;
			
FOREACH WITH HOLD
			select pky_bitacora
			into v_pky_bitacora
			from temp_bitacora
		BEGIN WORK;		
			--------------------Elimina historico del bitacora del sistema----------------------
			delete from "informix".acl_sistema_bitacora WHERE pky_bitacora = v_pky_bitacora;
		COMMIT WORK;
END FOREACH;

RETURN scod_ret;
END
END PROCEDURE;