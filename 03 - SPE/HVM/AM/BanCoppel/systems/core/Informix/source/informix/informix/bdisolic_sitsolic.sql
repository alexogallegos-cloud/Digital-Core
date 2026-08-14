CREATE PROCEDURE "informix".sitsolic(
             p_empresa         CHAR(3),
             pnum_solicitud    CHAR(20))

   RETURNING CHAR(5),  CHAR(80), CHAR(20), CHAR(60),CHAR(30),
             CHAR(40), CHAR(40), CHAR(20), CHAR(40), MONEY(14,2);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   DEFINE v_numcte            CHAR(20);
   DEFINE v_cliente           CHAR(60);
   DEFINE cNomEjecutivo       CHAR(30);
   DEFINE cNomDivisa          CHAR(40);
   DEFINE v_nombre_prod       CHAR(40);
   DEFINE solicitud           CHAR(20);
   DEFINE status              CHAR(40);
   DEFINE v_monto_autorizado  MONEY(14,2);

   DEFINE v_num_solicitud     CHAR(20);
   DEFINE v_secuencia         SMALLINT;
   DEFINE v_tipo_solicitud    CHAR(2);
   DEFINE v_status_solici     CHAR(2);
   DEFINE v_apell_paterno     CHAR(15);
   DEFINE v_apell_materno     CHAR(15);
   DEFINE v_nombre1           CHAR(15);
   DEFINE v_nombre2           CHAR(15);
   DEFINE v_razon_social      CHAR(60);
   DEFINE v_num_producto      CHAR(4);
   DEFINE cCveEjecutivo       CHAR(8);
   DEFINE cCveDivisa          CHAR(2);
   DEFINE v_comenaper         CHAR(300);

  ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "SitSolic.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      RETURN cod_ret, p_mensaje, v_numcte, v_cliente, cNomEjecutivo, cNomDivisa,
             v_nombre_prod, solicitud, status, v_monto_autorizado;
   END EXCEPTION;


   LET cod_ret = '000';
   LET p_mensaje = "Operacion Realizada Exitosamente";
   LET v_numcte = ' ';
   LET v_cliente = ' ';
   LET cNomEjecutivo = ' ';
   LET cNomDivisa = ' ' ;
   LET v_nombre_prod = ' ';
   LET solicitud = ' ';
   LET status = ' ';
   LET v_monto_autorizado = 0;
   LET v_num_solicitud = ' ';

   IF(pnum_solicitud IS NULL OR pnum_solicitud = ' ') THEN
      LET cod_ret = '201';
      LET p_mensaje = 'Numero de Solicitud nulo o en blancos';
      RETURN cod_ret, p_mensaje, v_numcte, v_cliente, cNomEjecutivo, cNomDivisa,
             v_nombre_prod, solicitud, status, v_monto_autorizado;
   END IF;

   SELECT
      COUNT(*)
   INTO
      nrows
   FROM
      ss_solicitudes
   WHERE
      empresa = p_empresa
   AND
      num_solicitud = pnum_solicitud;

   IF (nrows = 0) THEN
      LET cod_ret = '202';
      LET p_mensaje = 'Solicitud No Existe';
      RETURN cod_ret, p_mensaje, v_numcte, v_cliente, cNomEjecutivo, cNomDivisa,
             v_nombre_prod, solicitud, status, v_monto_autorizado;
   END IF;

   SELECT
      tipo_solicitud,
      status_solicitud,
      numcte,
      num_producto,
      monto_solicitado,
      ejecutivo_sol,
      nvl(divisa,"01"),
      monto_solicitado
   INTO
      v_tipo_solicitud,
      v_status_solici,
      v_numcte,
      v_num_producto,
      v_monto_autorizado,
      cCveEjecutivo,
      cCveDivisa,
      v_monto_autorizado
   FROM
      ss_solicitudes,
      ss_anexosol
   WHERE
        ss_solicitudes.empresa = ss_anexosol.empresa
   AND  ss_solicitudes.num_solicitud = ss_anexosol.num_solicitud
   AND  ss_solicitudes.empresa = p_empresa
   AND ss_solicitudes.num_solicitud = pnum_solicitud;

   LET nrows = dbinfo('sqlca.sqlerrd2');
   IF(nrows <> 1) THEN
      LET cod_ret = '202';
      LET p_mensaje = 'Error Al extraer informacion de solicitud';
      RETURN cod_ret, p_mensaje, v_numcte, v_cliente, cNomEjecutivo, cNomDivisa,
             v_nombre_prod, solicitud, status, v_monto_autorizado;
   END IF;

   SELECT
      nombre
   INTO
      cNomEjecutivo
   FROM
      bdinteg:si_ejecut
   WHERE
      empresa = p_empresa
   AND
      ejecutivo = cCveEjecutivo;

   LET nrows = dbinfo("sqlca.sqlerrd2");
   IF(nrows = 0) THEN
      LET cod_ret = '203';
      LET p_mensaje = 'Ejecutivo de Solicitud no Registrado';
      RETURN cod_ret, p_mensaje, v_numcte, v_cliente, cNomEjecutivo, cNomDivisa,
             v_nombre_prod, solicitud, status, v_monto_autorizado;
   END IF;

   SELECT
      descripcion
   INTO
      cNomDivisa
   FROM
      bdinteg:si_divisas
   WHERE
      empresa = p_empresa
   AND
      divisa = cCveDivisa;

   LET nrows = dbinfo("sqlca.sqlerrd2");
   IF(nrows = 0) THEN
      LET cod_ret = '204';
      LET p_mensaje = 'Divisa de Solicitud no Registrada';
      RETURN cod_ret, p_mensaje, v_numcte, v_cliente, cNomEjecutivo, cNomDivisa,
             v_nombre_prod, solicitud, status, v_monto_autorizado;
   END IF;

   IF(v_tipo_solicitud = 'E') THEN
      LET solicitud = 'EMPRESARIAL';
   END IF;
   IF(v_tipo_solicitud = 'T') THEN
      LET solicitud = 'TARJETA DE  CREDITO';
   END IF;
   IF(v_tipo_solicitud = 'M') THEN
      LET solicitud = 'LINEAS MASIVAS';
   END IF;
   IF(v_tipo_solicitud = 'Q') THEN
      LET solicitud = 'PRESTAMO QUIROGRAFARIO';
   END IF;
   IF(v_tipo_solicitud = 'U') THEN
      LET solicitud = 'UNION DE CREDITO';
   END IF;
   IF(v_tipo_solicitud = 'N') THEN
      LET solicitud = 'NORMAL';
   END IF;

   IF (v_status_solici = 'AT') THEN
      LET status = 'AUTORIZADA';
   END IF;
   IF (v_status_solici = 'AP') THEN
      LET status = 'APERTURADO';
   END IF;
   IF (v_status_solici = 'RE') THEN
      LET status = 'RECHAZADA';
   END IF;
   IF (v_status_solici = 'EE') THEN
      LET status = 'EN ESTUDIO';
   END IF;
   IF (v_status_solici = 'AI') THEN
      LET status = 'AUTORIZADA CON INDIVIDUALIZACION';
   END IF;
   IF (v_status_solici = 'DI') THEN
      LET status = 'DISPONIBLE';
   END IF;
   IF (v_status_solici = 'AR') THEN
      LET status = 'APROBADA EN RESOLUCION';
   END IF;
   IF (v_status_solici = 'AD') THEN
      LET status = 'APROBADA POR EL DIRECTORIO';
   END IF;

   SELECT
      numcte,
      apell_paterno,
      apell_materno,
      nombre1,
      nombre2,
      razon_social
   INTO
      v_numcte,
      v_apell_paterno,
      v_apell_materno,
      v_nombre1,
      v_nombre2,
      v_razon_social
   FROM
      bdinteg:si_cliente
   WHERE
      empresa = p_empresa
   AND
      numcte = v_numcte;

   LET nrows = dbinfo("sqlca.sqlerrd2");
   IF (nrows = 0) THEN
      LET cod_ret = '205';
      LET p_mensaje = 'Cliente no Existe';
      RETURN cod_ret, p_mensaje, v_numcte, v_cliente, cNomEjecutivo, cNomDivisa,
             v_nombre_prod, solicitud, status, v_monto_autorizado;
   END IF;

   IF(v_razon_social IS NULL OR v_razon_social = ' ') THEN
      IF(v_nombre1 IS NULL) THEN
         LET v_nombre2 =' ';
      END IF;
      LET v_cliente = TRIM(v_nombre1)||' '||TRIM(v_nombre2)||' '||
                      TRIM(v_apell_paterno)||' '||TRIM(v_apell_materno);
  ELSE
      LET v_cliente = v_razon_social;
  END IF;

  IF (v_monto_autorizado IS NULL) THEN
     LET v_monto_autorizado = 0;
  END IF;
   IF(v_status_solici = 'AP') THEN
      LET v_monto_autorizado = 0;
   END IF;


--   SELECT
--      monto_auto_cont
--   INTO
--      v_monto_autorizado
--   FROM
--      bdicred:sd_maecontrato
--   WHERE
--      empresa = p_empresa
--   AND
--      num_contrato[1,11] = v_num_solicitud;


   SELECT
      nombre_prod
   INTO
      v_nombre_prod
   FROM
      bdicred:sd_definicion
   WHERE
      empresa = p_empresa
   AND
      num_producto = v_num_producto;


   LET v_nombre_prod = TRIM(v_num_producto)||' '||TRIM(v_nombre_prod);

   SELECT
      comentario
   INTO
      v_comenaper
   FROM
      ss_autorizacion
   WHERE
      empresa = p_empresa
   AND
      num_solicitud = v_num_solicitud;

   LET nrows = dbinfo("sqlca.sqlerrd2");
   IF(nrows = 0) THEN
      LET v_comenaper = ' ';
   END IF;

   IF (v_numcte IS NULL) THEN
      LET v_numcte = ' ';
   END IF;

   IF(v_cliente IS NULL) THEN
      LET v_cliente = ' ';
   END IF;

   IF (cNomDivisa IS NULL) THEN
      LET cNomDivisa = ' ';
   END IF;

   IF (cNomEjecutivo IS NULL) THEN
      LET cNomEjecutivo = ' ';
   END IF;

   IF (v_nombre_prod IS NULL) THEN
      LET v_nombre_prod = ' ';
   END IF;

      RETURN cod_ret, p_mensaje, v_numcte, v_cliente, cNomEjecutivo, cNomDivisa,
             v_nombre_prod, solicitud, status, v_monto_autorizado;

END PROCEDURE
