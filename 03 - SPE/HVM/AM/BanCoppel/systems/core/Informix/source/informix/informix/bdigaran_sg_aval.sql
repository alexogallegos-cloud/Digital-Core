CREATE PROCEDURE "informix".sg_aval(
                         p_empresa     CHAR(3),
                         p_num_credito CHAR(20),
                         p_secuencia   INTEGER,
                         p_cod_garan   CHAR(4),
                         p_grupo_garan CHAR(4),
                         p_divisa      CHAR(2),
                         p_val_tot     MONEY(14,2),
                         p_estatus     CHAR(1),
                         p_numcte      CHAR(18))

   RETURNING CHAR(5), CHAR(80);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;


   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "Sg_Aval.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET p_mensaje = error_info;
      RETURN  cod_ret, p_mensaje;
   END EXCEPTION;


   LET cod_ret = '000';
   LET p_mensaje = "Operacion Realizada Exitosamente";


   INSERT INTO
      sg_maegaran
         (empresa,
          num_credito,
          id_garan,
          cod_garan,
          grupo_garan,
          divisa,
          val_garantot,
          statusgar)
   VALUES
         (p_empresa,
          p_num_credito,
          p_secuencia,
          p_cod_garan,
          p_grupo_garan,
          p_divisa,
          p_val_tot,
          p_estatus);

   INSERT INTO
      sg_aval
         (empresa,
          num_credito,
          id_garan,
          apellido_p)
   VALUES
         (p_empresa,
          p_num_credito,
          p_secuencia,
          p_numcte);

  RETURN cod_ret, p_mensaje;

END PROCEDURE
