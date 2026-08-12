CREATE PROCEDURE "informix".sg_hipotecaria(
                         p_empresa     CHAR(3),
                         p_num_credito CHAR(20),
                         p_secuencia   INTEGER,
                         p_cod_garan   CHAR(4),
                         p_grupo_garan CHAR(4),
                         p_divisa      CHAR(2),
                         p_val_tot     MONEY(14,2),
                         p_estatus     CHAR(1),
                         p_desc        CHAR(120),
                         p_calle       CHAR(40),
                         p_numext      CHAR(10),
                         p_numint      CHAR(10),
                         p_colonia     CHAR(30),
                         p_ciudad      CHAR(30),
                         p_estado      CHAR(20),
                         p_municipio   CHAR(18),
                         p_cod_postal  CHAR(5),
                         p_pais        CHAR(20),
                         p_numrpp      CHAR(18),
                         p_estadorpp   CHAR(1),
                         p_idnotario   CHAR(30),
                         p_numescrit   CHAR(18),
                         p_valor_garan INTEGER,
                         p_val_des     INTEGER,
                         p_fechaavaluo DATE)

   RETURNING CHAR(5), CHAR(80);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;


   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "Sg_Hipotecaria.err";
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
      sg_hipot
         (empresa,
          num_credito,
          id_garan,
          descripcion,
          calle,
          num_ext,
          num_int,
          colonia,
          ciudad,
          estado,
          municipio,
          cod_postal,
          pais,
          num_rpp,
          estado_rpp,
          id_notario,
          num_escrit,
          valor_garan,
          val_des,
          fecha_avaluo)
   VALUES
         (p_empresa,
          p_num_credito,
          p_secuencia,
          p_desc,
          p_calle,
          p_numext,
          p_numint,
          p_colonia,
          p_ciudad,
          p_estado,
          p_municipio,
          p_cod_postal,
          p_pais,
          p_numrpp,
          p_estadorpp,
          p_idnotario,
          p_numescrit,
          p_valor_garan,
          p_val_des,
          p_fechaavaluo);

  RETURN cod_ret, p_mensaje;

END PROCEDURE
