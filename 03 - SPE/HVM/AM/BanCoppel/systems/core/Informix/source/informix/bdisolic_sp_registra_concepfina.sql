CREATE PROCEDURE "informix".sp_registra_concepfina(
                 p_no_concepfina     SMALLINT,
                 p_empresa           CHAR(3),
                 p_num_solicitud     CHAR(20),
                 p_fecha_programada1  DATE,
                 p_cod_inversion1    CHAR(4),
                 p_cod_conagre1      CHAR(4),
                 p_cod_unidad1       CHAR(4),
                 p_cantidad1         SMALLINT,
                 p_monto_concepto1   MONEY(14,2),
                 p_fecha_programada2  DATE,
                 p_cod_inversion2    CHAR(4),
                 p_cod_conagre2      CHAR(4),
                 p_cod_unidad2       CHAR(4),
                 p_cantidad2         SMALLINT,
                 p_monto_concepto2   MONEY(14,2),
                 p_fecha_programada3  DATE,
                 p_cod_inversion3    CHAR(4),
                 p_cod_conagre3      CHAR(4),
                 p_cod_unidad3       CHAR(4),
                 p_cantidad3         SMALLINT,
                 p_monto_concepto3   MONEY(14,2),
                 p_fecha_programada4  DATE,
                 p_cod_inversion4    CHAR(4),
                 p_cod_conagre4      CHAR(4),
                 p_cod_unidad4       CHAR(4),
                 p_cantidad4         SMALLINT,
                 p_monto_concepto4   MONEY(14,2),
                 p_fecha_programada5  DATE,
                 p_cod_inversion5    CHAR(4),
                 p_cod_conagre5      CHAR(4),
                 p_cod_unidad5       CHAR(4),
                 p_cantidad5         SMALLINT,
                 p_monto_concepto5   MONEY(14,2))

   RETURNING CHAR(5), CHAR(80);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

  ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "Sp_Registra_Unidad_Prod.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      RETURN cod_ret, p_mensaje;
   END EXCEPTION;

   LET cod_ret = '000';
   LET p_mensaje = "Operacion Realizada Exitosamente";

   INSERT INTO 
      ss_concepfina
         (empresa,
          num_solicitud,
          fecha_programada,
          cod_inversion,
          cod_conagre,
          cantidad,
          monto_concepto,
          user_insert,
          fecha_insert)
   VALUES
         (p_empresa,
          p_num_solicitud,
          p_fecha_programada1,
          p_cod_inversion1,
          p_cod_conagre1,
          p_cantidad1,
          p_monto_concepto1,
          USER,
          CURRENT);

   IF(p_fecha_programada2 IS NULL OR p_fecha_programada2 = ' ') THEN
      RETURN cod_ret, p_mensaje;
   END IF;          

   INSERT INTO 
      ss_concepfina
         (empresa,
          num_solicitud,
          fecha_programada,
          cod_inversion,
          cod_conagre,
          cantidad,
          monto_concepto,
          user_insert,
          fecha_insert)
   VALUES
         (p_empresa,
          p_num_solicitud,
          p_fecha_programada2,
          p_cod_inversion2,
          p_cod_conagre2,
          p_cantidad2,
          p_monto_concepto2,
          USER,
          CURRENT);
  
   IF(p_fecha_programada3 IS NULL OR p_fecha_programada3 = ' ') THEN
      RETURN cod_ret, p_mensaje;
   END IF;          

   INSERT INTO 
      ss_concepfina
         (empresa,
          num_solicitud,
          fecha_programada,
          cod_inversion,
          cod_conagre,
          cantidad,
          monto_concepto,
          user_insert,
          fecha_insert)
   VALUES
         (p_empresa,
          p_num_solicitud,
          p_fecha_programada3,
          p_cod_inversion3,
          p_cod_conagre3,
          p_cantidad3,
          p_monto_concepto3,
          USER,
          CURRENT);

   IF(p_fecha_programada4 IS NULL OR p_fecha_programada4 = ' ') THEN
      RETURN cod_ret, p_mensaje;
   END IF;          

   INSERT INTO 
      ss_concepfina
         (empresa,
          num_solicitud,
          fecha_programada,
          cod_inversion,
          cod_conagre,
          cantidad,
          monto_concepto,
          user_insert,
          fecha_insert)
   VALUES
         (p_empresa,
          p_num_solicitud,
          p_fecha_programada4,
          p_cod_inversion4,
          p_cod_conagre4,
          p_cantidad4,
          p_monto_concepto4,
          USER,
          CURRENT);

   IF(p_fecha_programada5 IS NULL OR p_fecha_programada5 = ' ') THEN
      RETURN cod_ret, p_mensaje;
   END IF;          

   INSERT INTO 
      ss_concepfina
         (empresa,
          num_solicitud,
          fecha_programada,
          cod_inversion,
          cod_conagre,
          cantidad,
          monto_concepto,
          user_insert,
          fecha_insert)
   VALUES
         (p_empresa,
          p_num_solicitud,
          p_fecha_programada5,
          p_cod_inversion5,
          p_cod_conagre5,
          p_cantidad5,
          p_monto_concepto5,
          USER,
          CURRENT);

   RETURN cod_ret, p_mensaje;
END PROCEDURE
