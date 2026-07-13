CREATE PROCEDURE "informix".sg_prendaria(
                         p_empresa     CHAR(3),
                         p_num_credito CHAR(20),
                         p_secuencia   INTEGER,
                         p_cod_garan   CHAR(4),
                         p_grupo_garan CHAR(4),
                         p_divisa      CHAR(2),
                         p_val_tot     MONEY(14,2),
                         p_estatus     CHAR(1),

                         p_desc        CHAR(120),
                         p_num_fact    CHAR(18),
                         p_fecha_fact  DATE,
                         p_valor_garan INTEGER,
                         p_fecha_act   DATE,
                         p_cod_depos   CHAR(1),
                         p_calle       CHAR(40),
                         p_num_ext     CHAR(10),
                         p_num_int     CHAR(10),
                         p_colonia     CHAR(30),
                         p_ciudad      CHAR(30),
                         p_estado      CHAR(18),
                         p_municipio   CHAR(18),
                         p_cod_postal  CHAR(5),
                         p_pais        CHAR(18))

   RETURNING CHAR(5), CHAR(80);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;
   DEFINE VHoy 		      DATE;

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "Sg_Prendaria.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET p_mensaje = error_info;
      RETURN  cod_ret, p_mensaje;
   END EXCEPTION;

   LET cod_ret = '000';
   LET p_mensaje = "Operacion Realizada Exitosamente";

   SELECT fecha_hoy INTO VHoy FROM bdicred:sd_fechas;

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
      sg_prend
         (empresa,
          num_credito,
          id_garan,
          descripcion,
          num_fact,
          fecha_fact,
          valor_garan,
          fecha_act,
          cod_depos,
          calle,
          num_ext,
          num_int,
          colonia,
          ciudad,
          estado,
          municipio,
          cod_postal,
          pais,
	  fecha_agaran)
   VALUES
         (p_empresa,
          p_num_credito,
          p_secuencia,
          p_desc,
          p_num_fact,
          p_fecha_fact,
          p_valor_garan,
          p_fecha_act,
          p_cod_depos,
          p_calle,
          p_num_ext,
          p_num_int,
          p_colonia,
          p_ciudad,
          p_estado,
          p_municipio,
          p_cod_postal,
          p_pais,
	  VHoy);

  RETURN cod_ret, p_mensaje;
                        
END PROCEDURE
