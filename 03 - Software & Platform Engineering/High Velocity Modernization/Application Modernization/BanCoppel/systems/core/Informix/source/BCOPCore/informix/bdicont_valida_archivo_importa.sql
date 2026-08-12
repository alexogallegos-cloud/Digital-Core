CREATE PROCEDURE "informix".valida_archivo_importa(p_archivo CHAR(100),p_fecha_hoy DATE)
         RETURNING CHAR(5);

   DEFINE cod_ret      CHAR(5);
   DEFINE sql_err      INTEGER;
   DEFINE isam_err     INTEGER;
   DEFINE error_info   CHAR(40);
   DEFINE v_valida     INTEGER;

     ON EXCEPTION SET sql_err, isam_err, error_info
         LET cod_ret = sql_err;
         
         RETURN cod_ret;
     END EXCEPTION;

  
   LET v_valida = 0;
   LET cod_ret = "000";

   SELECT COUNT(*) INTO v_valida
   FROM bdicont:co_archivos
   WHERE bdicont:co_archivos.archivo = p_archivo
   AND bdicont:co_archivos.fecha = p_fecha_hoy;


   IF v_valida > 0 THEN
      LET cod_ret = "143";
      RETURN cod_ret;
   END IF;

   RETURN cod_ret;

END PROCEDURE;