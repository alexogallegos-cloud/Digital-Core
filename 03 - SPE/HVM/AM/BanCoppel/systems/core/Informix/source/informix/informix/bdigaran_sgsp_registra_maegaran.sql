CREATE PROCEDURE "informix".sgsp_registra_maegaran(
                         p_empresa           CHAR(3),
                         p_num_credito       CHAR(20),
                         v_secuencial_garan  INTEGER,
                         v_cod_garan         CHAR(4),
                         v_grupo_garan       CHAR(4),
                         v_divisa            CHAR(2),
                         v_val_garantot      MONEY(14,2),
                         v_statusgar         CHAR(1),
                         v_descripcion       CHAR(120),
                         v_valor_garan       MONEY(14,2),
                         v_tipo_doc          CHAR(2),
                         v_fecha_doc         CHAR(2),
                         v_calle             CHAR(40),
                         v_num_ext           CHAR(10),
                         v_num_int           CHAR(10),
                         v_colonia           CHAR(30),
                         v_ciudad            CHAR(30),
                         v_estado            CHAR(18),
                         v_municipio         CHAR(18),
                         v_cod_postal        CHAR(5),
                         v_pais              CHAR(18),
                         v_id_notario        CHAR(30),
                         v_num_escrit        CHAR(18),
                         v_beneficiario      CHAR(30),
                         v_fecha_avaluo      DATE,

                         v_fideicomisa       CHAR(40),
                         v_fideicomiten      CHAR(40),

                         v_num_fact          CHAR(18),
                         v_fecha_fact        DATE,
                         v_fecha_act         DATE,
                         v_cod_depos         CHAR(1),

                         v_fecha_aseg         DATE,
                         v_vig_seg           DATE,
                         v_comp_aseg         CHAR(18),
                         v_num_pol           CHAR(20),

                         v_num_rpp           CHAR(1),
                         v_estado_rpp        CHAR(1),
                         v_val_des           SMALLINT,

                         v_emisor            CHAR(18),
                         v_val_avaluo        CHAR(18),
                         v_fecha_actu        DATE,

                         v_fecha_cobr        DATE,
                         v_fechahoy          DATE)

   RETURNING CHAR(5), CHAR(80);
   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "Sp_Obtiene_Unidad_Prod.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      RETURN  cod_ret, p_mensaje;
   END EXCEPTION;


   LET cod_ret = '000';
   LET p_mensaje = "Operacion Realizada Exitosamente";

   INSERT INTO SG_MAEGARAN
             (EMPRESA,
              NUM_CREDITO,
              ID_GARAN,
              COD_GARAN,
              GRUPO_GARAN,
              DIVISA,
              VAL_GARANTOT,
              STATUSGAR)
   VALUES
             (P_EMPRESA,
              P_NUM_CREDITO,
              V_SECUENCIAL_GARAN,
              V_COD_GARAN,
              V_GRUPO_GARAN,
              V_DIVISA,
              V_VAL_GARANTOT,
              V_STATUSGAR);

   IF (v_fideicomisa IS NOT NULL and v_fideicomisa <> ' ') THEN
         INSERT INTO SG_FIDUC
                (EMPRESA,
                 NUM_CREDITO,
                 ID_GARAN,
                 DESCRIPCION,
                 VALOR_GARAN,
                 FIDEICOMISA,
                 FIDEICOMITEN,
                 ID_NOTARIO,
                 NUM_ESCRIT,
     	         VAL_REMANENTE,
		 FECHA_AGARAN)
         VALUES
                (P_EMPRESA,
                 P_NUM_CREDITO,
                 V_SECUENCIAL_GARAN,
                 V_DESCRIPCION,
                 V_VALOR_GARAN,
                 V_FIDEICOMISA,
                 V_FIDEICOMITEN,
                 V_ID_NOTARIO,
                 V_NUM_ESCRIT,
		 0,
		 V_FECHAHOY);
   END IF;

   IF (v_num_fact IS NOT NULL AND v_num_fact <> ' ') THEN
             INSERT INTO SG_PREND
                (EMPRESA,
                 NUM_CREDITO,
                 ID_GARAN,
                 DESCRIPCION,
                 NUM_FACT,
                 FECHA_FACT,
                 VALOR_GARAN,
                 FECHA_ACT,
                 COD_DEPOS,
                 CALLE,
                 NUM_EXT,
                 NUM_INT,
                 COLONIA,
                 CIUDAD,
                 ESTADO,
                 MUNICIPIO,
                 COD_POSTAL,
                 PAIS,
		 VAL_REMANENTE,
		 FECHA_AGARAN)
         VALUES
                (P_EMPRESA,
                 P_NUM_CREDITO,
                 V_SECUENCIAL_GARAN,
                 V_DESCRIPCION,
                 V_NUM_FACT,
                 V_FECHA_FACT,
                 V_VALOR_GARAN,
                 V_FECHA_ACT,
                 V_COD_DEPOS,
                 V_CALLE,
                 V_NUM_EXT,
                 V_NUM_INT,
                 V_COLONIA,
                 V_CIUDAD,
                 V_ESTADO,
                 V_MUNICIPIO,
                 V_COD_POSTAL,
                 V_PAIS,
		 0,
		 V_FECHAHOY);
   END IF;

   IF(v_num_pol IS NOT NULL AND v_num_pol <> ' ') THEN
         INSERT INTO SG_SEGUR
                (EMPRESA,
                 NUM_CREDITO,
                 ID_GARAN,
                 DESCRIPCION,
                 VALOR_GARAN,
                 FECHA_ASEG,
                 VIG_SEG,
                 COMP_ASEG,
                 NUM_POL,
                 BENEFICIARIO,
		 VAL_REMANENTE,
		 FECHA_AGARAN)
         VALUES
                (P_EMPRESA,
                 P_NUM_CREDITO,
                 V_SECUENCIAL_GARAN,
                 V_DESCRIPCION,
                 V_VALOR_GARAN,
                 V_FECHA_ASEG,
                 V_VIG_SEG,
                 V_COMP_ASEG,
                 V_NUM_POL,
                 V_BENEFICIARIO,
		 0,
		 V_FECHAHOY);
   END IF;

   IF(v_descripcion IS NOT NULL AND v_descripcion <> ' ') THEN
            INSERT INTO SG_HIPOT
                (EMPRESA,
                 NUM_CREDITO,
                 ID_GARAN,
                 DESCRIPCION,
                 CALLE,
                 NUM_EXT,
                 NUM_INT,
                 COLONIA,
                 CIUDAD,
                 ESTADO,
                 MUNICIPIO,
                 COD_POSTAL,
                 PAIS,
                 NUM_RPP,
                 ESTADO_RPP,
                 ID_NOTARIO,
                 NUM_ESCRIT,
                 VALOR_GARAN,
                 VAL_DES,
                 FECHA_AVALUO,
		 VAL_REMANENTE,
		 FECHA_AGARAN)
         VALUES
                (P_EMPRESA,
                 P_NUM_CREDITO,
                 V_SECUENCIAL_GARAN,
                 V_DESCRIPCION,
                 V_CALLE,
                 V_NUM_EXT,
                 V_NUM_INT,
                 V_COLONIA,
                 V_CIUDAD,
                 V_ESTADO,
                 V_MUNICIPIO,
                 V_COD_POSTAL,
                 V_PAIS,
                 V_NUM_RPP,
                 V_ESTADO_RPP,
                 V_ID_NOTARIO,
                 V_NUM_ESCRIT,
                 V_VALOR_GARAN,
                 V_VAL_DES,
                 V_FECHA_AVALUO,
		 0,
		 V_FECHAHOY);

   END IF;

   IF (v_tipo_doc IS NOT NULL AND v_tipo_doc <> ' ') THEN
               INSERT INTO SG_COMER
                (EMPRESA,
                 NUM_CREDITO,
                 ID_GARAN,
                 DESCRIPCION,
                 TIPO_DOC,
                 VALOR_GARAN,
                 FECHA_DOC,
                 EMISOR,
                 BENEFICIARIO,
                 VAL_AVALUO,
                 FECHA_AVALUO,
                 FECHA_ACTU,
		 VAL_REMANENTE,
		 FECHA_AGARAN)
         VALUES
                (P_EMPRESA,
                 P_NUM_CREDITO,
                 V_SECUENCIAL_GARAN,
                 V_DESCRIPCION,
                 V_TIPO_DOC,
                 V_VALOR_GARAN,
                 V_FECHA_DOC,
                 V_EMISOR,
                 V_BENEFICIARIO,
                 V_VAL_AVALUO,
                 V_FECHA_AVALUO,
                 V_FECHA_ACTU,
		 0,
		 V_FECHAHOY);
   END IF;
   IF (v_fecha_cobr IS NOT NULL AND v_fecha_cobr <>  '  ') THEN

               INSERT INTO SG_FINAN
                (EMPRESA,
                 NUM_CREDITO,
                 ID_GARAN,
                 DESCRIPCION,
                 TIPO_DOC,
                 VALOR_GARAN,
                 FECHA_DOC,
                 BENEFICIARIO,
                 FECHA_COBR,
                 DIVISA,
		 VAL_REMANENTE,
		 FECHA_AGARAN)
         VALUES
                (P_EMPRESA,
                 P_NUM_CREDITO,
                 V_SECUENCIAL_GARAN,
                 V_DESCRIPCION,
                 V_TIPO_DOC,
                 V_VALOR_GARAN,
                 V_FECHA_DOC,
                 V_BENEFICIARIO,
                 V_FECHA_COBR,
                 V_DIVISA,
		 0,
		 V_FECHAHOY);
   END IF;

   RETURN cod_ret, p_mensaje;
END PROCEDURE
