CREATE PROCEDURE "informix".sp_registra_unidadprod(
                     p_empresa          LIKE ss_solicitudes.empresa,
                     p_num_solicitud    LIKE ss_solicitudes.num_solicitud,
                     p_numcte           LIKE ss_solicitudes.numcte,
                     p_nombre_unidad    LIKE ss_unidadprod.nombre_unidad,
                     p_sup_total        DECIMAL(9,3),
                     p_sup_aprovechable DECIMAL(9,3),
                     p_sup_cultivada    DECIMAL(9,3),
                     p_sup_solicitada   DECIMAL(9,3),
                     p_direccion        LIKE ss_unidadprod.direccion,
                     p_punto_ref        LIKE ss_unidadprod.punto_ref,
                     p_pais             LIKE ss_unidadprod.pais,
                     p_estado           LIKE ss_unidadprod.estado,
                     p_ciudad           LIKE ss_unidadprod.ciudad,
                     p_municipio        LIKE ss_unidadprod.municipio,
                     p_parcela          CHAR(60),
                     p_caserio          CHAR(60),
                     p_asentamiento     CHAR(60),
                     p_gral_norte       LIKE ss_unidadprod.gral_norte,
                     p_gral_sur         LIKE ss_unidadprod.gral_sur,
                     p_gral_este        LIKE ss_unidadprod.gral_este,
                     p_gral_oeste       LIKE ss_unidadprod.gral_oeste,
                     p_part_norte       LIKE ss_unidadprod.part_norte,
                     p_part_sur         LIKE ss_unidadprod.part_sur,
                     p_part_este        LIKE ss_unidadprod.part_este,
                     p_part_oeste       LIKE ss_unidadprod.part_oeste,
                     p_latitud_norte    LIKE ss_unidadprod.latitud_norte,
                     p_latitud_sur      LIKE ss_unidadprod.latitud_sur,
                     p_latitud_este     LIKE ss_unidadprod.latitud_este,
                     p_latitud_oeste    LIKE ss_unidadprod.latitud_oeste,
                     p_tenen_oficina    LIKE ss_unidadprod.tenen_oficina,
                     p_sector_tenencia  LIKE ss_unidadprod.sector_tenencia,
                     p_tenen_numero     LIKE ss_unidadprod.tenen_numero,
                     p_clas_tenencia    LIKE ss_unidadprod.clas_tenencia,
                     p_tenen_tomo       LIKE ss_unidadprod.tenen_tomo,
                     p_tenen_protocolo  LIKE ss_unidadprod.tenen_protocolo,
                     p_tenen_trimestre  LIKE ss_unidadprod.tenen_trimestre,
                     p_tenen_fecha_ins  LIKE ss_unidadprod.tenen_protocolo,
                     p_fecha_inicio     DATE,
                     p_fecha_culminacion DATE,
                     p_user_insert      CHAR(8))

   RETURNING CHAR(5), CHAR(80);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   DEFINE v_paso              SMALLINT;

  ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "Sp_Registra_Unidad_Prod.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      RETURN cod_ret, p_mensaje;
   END EXCEPTION;

   LET cod_ret = '000';
   LET p_mensaje = "Operacion Realizada Exitosamente";

   SELECT
      COUNT(*)
   INTO
      v_paso
   FROM
      ss_unidadprod
   WHERE
       latitud_norte = p_latitud_norte
   AND latitud_sur = p_latitud_sur
   AND latitud_Este = p_latitud_este
   AND latitud_oeste = p_latitud_oeste
   AND num_solicitud = p_num_solicitud
   AND numcte = p_numcte
   AND empresa = p_empresa;

   IF(v_paso > 0) THEN
      LET cod_ret = 100;
      LET p_mensaje = 'ERROR: Unidad de produccion ya dada de Alta';
      RETURN cod_ret, p_mensaje;
   END IF;

   INSERT INTO
      ss_unidadprod
       (EMPRESA, NUMCTE, NUM_SOLICITUD, NOMBRE_UNIDAD, SUP_TOTAL,
        SUP_APROVECHABLE, SUP_CULTIVADA, SUP_SOLICITADA, DIRECCION,
        PUNTO_REF, PAIS, ESTADO,  CIUDAD, MUNICIPIO, PARCELA,
        CASERIO, ASENTAMIENTO, GRAL_NORTE, GRAL_SUR, GRAL_ESTE,
        GRAL_OESTE, PART_NORTE, PART_SUR, PART_ESTE, PART_OESTE,
        LATITUD_NORTE, LATITUD_SUR, LATITUD_ESTE, LATITUD_OESTE,
        TENEN_OFICINA, SECTOR_TENENCIA, TENEN_NUMERO, CLAS_TENENCIA,
         TENEN_TOMO,
        TENEN_PROTOCOLO, TENEN_TRIMESTRE,  TENEN_FECHA_INS,REGISTRADO,
        FECHA_INICIO, FECHA_CULMINACION, USER_INSERT)
   VALUES
       (P_EMPRESA, P_NUMCTE, P_NUM_SOLICITUD, P_NOMBRE_UNIDAD, P_SUP_TOTAL,
        P_SUP_APROVECHABLE, P_SUP_CULTIVADA,  P_SUP_SOLICITADA, P_DIRECCION,
        P_PUNTO_REF, P_PAIS, P_ESTADO, P_CIUDAD, P_MUNICIPIO,
        P_PARCELA, P_CASERIO, P_ASENTAMIENTO, P_GRAL_NORTE, P_GRAL_SUR,
        P_GRAL_ESTE, P_GRAL_OESTE, P_PART_NORTE, P_PART_SUR, P_PART_ESTE,
        P_PART_OESTE, P_LATITUD_NORTE, P_LATITUD_SUR,  P_LATITUD_ESTE,
        P_LATITUD_OESTE, P_TENEN_OFICINA, P_SECTOR_TENENCIA,
        P_TENEN_NUMERO, P_CLAS_TENENCIA,P_TENEN_TOMO,  P_TENEN_PROTOCOLO,
        P_TENEN_TRIMESTRE,P_TENEN_FECHA_INS, NULL ,P_FECHA_INICIO,
        P_FECHA_CULMINACION, P_USER_INSERT) ;

   RETURN cod_ret, p_mensaje;
END PROCEDURE
