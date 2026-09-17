CREATE PROCEDURE "informix".sp_registra_detminis(
              p_no_detminis       SMALLINT,
              p_empresa           CHAR(3),
              p_num_solicitud     CHAR(20),
              p_fecha_prop1       DATE,
              p_monto1            MONEY(14,2),
              p_obser1            CHAR(150),
              p_fecha_prop2       DATE,
              p_monto2            MONEY(14,2),
              p_obser2            CHAR(150),
              p_fecha_prop3       DATE,
              p_monto3            MONEY(14,2),
              p_obser3            CHAR(150),
              p_fecha_prop4       DATE,
              p_monto4            MONEY(14,2),
              p_obser4            CHAR(150),
              p_fecha_prop5       DATE,
              p_monto5            MONEY(14,2),
              p_obser5            CHAR(150))
   RETURNING CHAR(5), CHAR(80);


   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

  ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "Sp_Registra_Detminis.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET p_mensaje = error_info;
      RETURN cod_ret, p_mensaje;
   END EXCEPTION;


   LET cod_ret = '000';
   LET p_mensaje = "Operacion Realizada Exitosamente";

   INSERT INTO
      ss_detminis
         (empresa,
          num_solicitud,
          fecha_programada,
          monto_otorgado,
          obser1)
   VALUES
         (p_empresa,
          p_num_solicitud,
          p_fecha_prop1,
          p_monto1,
          p_obser1) ;

   IF(p_fecha_prop2 IS NULL or p_fecha_prop2 = ' ') THEN
      RETURN cod_ret, p_mensaje;
   END IF;

   INSERT INTO
      ss_detminis
         (empresa,
          num_solicitud,
          fecha_programada,
          monto_otorgado,
          obser1)
   VALUES
         (p_empresa,
          p_num_solicitud,
          p_fecha_prop2,
          p_monto2,
          p_obser2) ;

   IF(p_fecha_prop3 IS NULL or p_fecha_prop3 = ' ') THEN
      RETURN cod_ret, p_mensaje;
   END IF;

   INSERT INTO
      ss_detminis
         (empresa,
          num_solicitud,
          fecha_programada,
          monto_otorgado,
          obser1)
   VALUES
         (p_empresa,
          p_num_solicitud,
          p_fecha_prop3,
          p_monto3,
          p_obser3) ;

   IF(p_fecha_prop4 IS NULL or p_fecha_prop4 = ' ') THEN
      RETURN cod_ret, p_mensaje;
   END IF;

   INSERT INTO
      ss_detminis
         (empresa,
          num_solicitud,
          fecha_programada,
          monto_otorgado,
          obser1)
   VALUES
         (p_empresa,
          p_num_solicitud,
          p_fecha_prop4,
          p_monto4,
          p_obser4) ;

   IF(p_fecha_prop5 IS NULL or p_fecha_prop5 = ' ') THEN
      RETURN cod_ret, p_mensaje;
   END IF;

   INSERT INTO
      ss_detminis
         (empresa,
          num_solicitud,
          fecha_programada,
          monto_otorgado,
          obser1)
   VALUES
         (p_empresa,
          p_num_solicitud,
          p_fecha_prop5,
          p_monto5,
          p_obser5) ;

   RETURN cod_ret, p_mensaje;

END PROCEDURE
