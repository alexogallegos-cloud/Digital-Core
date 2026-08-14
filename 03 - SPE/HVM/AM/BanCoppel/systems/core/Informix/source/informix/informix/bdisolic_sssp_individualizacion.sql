CREATE PROCEDURE "informix".sssp_individualizacion(
                    p_empresa        CHAR(3),
                    p_solicitud      CHAR(20),
                    p_numcte         CHAR(20),
                    vp_numcte1       CHAR(20),
                    vp_monto1        MONEY(14,2),
                    vp_numcte2       CHAR(20),
                    vp_monto2        MONEY(14,2),
                    vp_numcte3       CHAR(20),
                    vp_monto3        MONEY(14,2),
                    vp_numcte4       CHAR(20),
                    vp_monto4        MONEY(14,2),
                    vp_numcte5       CHAR(20),
                    vp_monto5        MONEY(14,2),
                    p_cantdet        CHAR(10),
                    p_usuario        CHAR(8))

  RETURNING CHAR(5), CHAR(80);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "SsSp_Individualizacion.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET p_mensaje = error_info;
      RETURN  cod_ret, p_mensaje;
   END EXCEPTION;

   LET cod_ret = '000';
   LET p_mensaje = "Operacion Realizada Exitosamente";

   SELECT
      COUNT(*)
   INTO
      nrows
   FROM
      bdisolic:ss_solicitudes
   WHERE
      numcte = p_numcte
   AND
      num_solicitud = p_solicitud
   AND
      empresa = p_empresa;

   IF (nrows = 0) THEN
      LET cod_ret = 100;
      LET p_mensaje = 'No Existe Solicitud';
      RETURN cod_ret, p_mensaje;
   END IF;

   SELECT
      COUNT(*)
   INTO
      nrows
   FROM
      bdinteg:si_cliente
   WHERE
      numcte = p_numcte
   AND
      empresa = p_empresa;

   IF(nrows = 0) THEN
      LET cod_ret = '101';
      LET p_mensaje = 'Cliente '||' '||p_numcte||' '||'No Existe';
      RETURN cod_ret, p_mensaje;
   END IF;

   SELECT
      COUNT(*)
   INTO
      nrows
   FROM
      ss_sujetos
   WHERE
      empresa = p_empresa
   AND
      num_solicitud = p_solicitud
   AND
      numcte = p_numcte;

   IF (nrows = 0) THEN

      INSERT INTO
         ss_sujetos
             (empresa,
              num_solicitud,
              numcte,
              total_integrantes,
              user_insert,
              fecha_insert)
       VALUES
             (p_empresa,
              p_solicitud,
              p_numcte,
              p_cantdet,
              p_usuario,
              CURRENT);
   END IF;
--------------------------------------------------------
   SELECT
      COUNT(*)
   INTO
      nrows
   FROM
      ss_integrantes
   WHERE
      num_cte_int = vp_numcte1
   AND
      num_solicitud = p_solicitud
   AND
      empresa = p_empresa;

   IF(nrows = 0) THEN
      INSERT INTO
         ss_integrantes
             (empresa,
              num_solicitud,
              num_cte_int,
              numcte,
              monto_solicitado,
              user_insert,
              fecha_insert)
      VALUES
            (p_empresa,
             p_solicitud,
             vp_numcte1,
             p_numcte,
             vp_monto1,
             p_usuario,
             CURRENT);
   END IF;
-------------------------------------------------------------------------
   SELECT
      COUNT(*)
   INTO
      nrows
   FROM
      ss_integrantes
   WHERE
      num_cte_int = vp_numcte2
   AND
      num_solicitud = p_solicitud
   AND
      empresa = p_empresa;

   IF(nrows = 0) THEN
      INSERT INTO
         ss_integrantes
             (empresa,
              num_solicitud,
              num_cte_int,
              numcte,
              monto_solicitado,
              user_insert,
              fecha_insert)
      VALUES
            (p_empresa,
             p_solicitud,
             vp_numcte2,
             p_numcte,
             vp_monto2,
             p_usuario,
             CURRENT);
   END IF;
-------------------------------------------------------------------------
   SELECT
      COUNT(*)
   INTO
      nrows
   FROM
      ss_integrantes
   WHERE
      num_cte_int = vp_numcte3
   AND
      num_solicitud = p_solicitud
   AND
      empresa = p_empresa;

   IF(nrows = 0) THEN
      INSERT INTO
         ss_integrantes
             (empresa,
              num_solicitud,
              num_cte_int,
              numcte,
              monto_solicitado,
              user_insert,
              fecha_insert)
      VALUES
            (p_empresa,
             p_solicitud,
             vp_numcte3,
             p_numcte,
             vp_monto3,
             p_usuario,
             CURRENT);
   END IF;
-------------------------------------------------------------------------
   SELECT
      COUNT(*)
   INTO
      nrows
   FROM
      ss_integrantes
   WHERE
      num_cte_int = vp_numcte4
   AND
      num_solicitud = p_solicitud
   AND
      empresa = p_empresa;

   IF(nrows = 0) THEN
      INSERT INTO
         ss_integrantes
             (empresa,
              num_solicitud,
              num_cte_int,
              numcte,
              monto_solicitado,
              user_insert,
              fecha_insert)
      VALUES
            (p_empresa,
             p_solicitud,
             vp_numcte4,
             p_numcte,
             vp_monto4,
             p_usuario,
             CURRENT);
   END IF;
-------------------------------------------------------------------------
   SELECT
      COUNT(*)
   INTO
      nrows
   FROM
      ss_integrantes
   WHERE
      num_cte_int = vp_numcte5
   AND
      num_solicitud = p_solicitud
   AND
      empresa = p_empresa;

   IF(nrows = 0) THEN
      INSERT INTO
         ss_integrantes
             (empresa,
              num_solicitud,
              num_cte_int,
              numcte,
              monto_solicitado,
              user_insert,
              fecha_insert)
      VALUES
            (p_empresa,
             p_solicitud,
             vp_numcte5,
             p_numcte,
             vp_monto5,
             p_usuario,
             CURRENT);
   END IF;
-------------------------------------------------------------------------

   RETURN cod_ret, p_mensaje;


END PROCEDURE
