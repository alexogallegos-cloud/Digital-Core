CREATE PROCEDURE "informix".sp_recauda(
                   p_empresa       CHAR(3),
                   p_num_credito   CHAR(20),
                   v_documen_req1   CHAR(3),
                   v_fecha_entrega1 DATE,
                   v_documen_req2   CHAR(3),
                   v_fecha_entrega2 DATE,
                   v_documen_req3   CHAR(3),
                   v_fecha_entrega3 DATE,
                   v_documen_req4   CHAR(3),
                   v_fecha_entrega4 DATE,
                   v_documen_req5   CHAR(3),
                   v_fecha_entrega5 DATE)

   RETURNING CHAR(5), CHAR(80);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "Sp_Recauda.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET p_mensaje = error_info;
      RETURN  cod_ret, p_mensaje;
   END EXCEPTION;

   LET cod_ret = '000';
   LET p_mensaje = "Operacion Realizada Exitosamente";

   INSERT INTO
      bdicred:sd_detdocum
   VALUES
      (p_empresa,
      p_num_credito,
      v_documen_req1,
      v_fecha_entrega1,
      USER,
      CURRENT);

   IF(v_documen_req2 IS NOT NULL AND v_documen_req2 <> ' ') THEN
      INSERT INTO
         bdicred:sd_detdocum
      VALUES
         (p_empresa,
         p_num_credito,
         v_documen_req2,
         v_fecha_entrega2,
         USER,
         CURRENT);
   END IF;

   IF(v_documen_req3 IS NOT NULL AND v_documen_req3 <> ' ') THEN
      INSERT INTO
         bdicred:sd_detdocum
      VALUES
         (p_empresa,
         p_num_credito,
         v_documen_req3,
         v_fecha_entrega3,
         USER,
         CURRENT);
   END IF;

   IF(v_documen_req4 IS NOT NULL AND v_documen_req4 <> ' ') THEN
      INSERT INTO
         bdicred:sd_detdocum
      VALUES
         (p_empresa,
         p_num_credito,
         v_documen_req4,
         v_fecha_entrega4,
         USER,
         CURRENT);
   END IF;

   IF(v_documen_req5 IS NOT NULL AND v_documen_req5 <> ' ') THEN
      INSERT INTO
         bdicred:sd_detdocum
      VALUES
         (p_empresa,
         p_num_credito,
         v_documen_req5,
         v_fecha_entrega5,
         USER,
         CURRENT);
   END IF;
  RETURN cod_ret, p_mensaje;

END PROCEDURE
