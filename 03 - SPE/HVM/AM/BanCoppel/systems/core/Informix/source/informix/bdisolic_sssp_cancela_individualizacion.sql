CREATE PROCEDURE "informix".sssp_cancela_individualizacion(
                                    p_empresa   CHAR(3),
                                    p_solicitud CHAR(20),
                                    p_numcte    CHAR(20))
  
  RETURNING CHAR(5), CHAR(80);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "SsSp_Cancela_Individualizacion.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET p_mensaje = error_info;
      RETURN  cod_ret, p_mensaje;
   END EXCEPTION;

   LET cod_ret = '000';
   LET p_mensaje = "Operacion Realizada Exitosamente";

   DELETE FROM
      ss_integrantes
   WHERE
      numcte = p_numcte
   AND
      num_solicitud = p_solicitud
   AND
      empresa = p_empresa;


   DELETE FROM
      ss_sujetos
   WHERE
      numcte = p_numcte
   AND
      num_solicitud = p_solicitud
   AND
      empresa = p_empresa;

   RETURN cod_ret, p_mensaje;      


END PROCEDURE
