CREATE PROCEDURE "informix".bajasaldos_tc()
   RETURNING CHAR(5), CHAR(20), CHAR(1), CHAR(4), MONEY(14,2);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);

   DEFINE NumCredito          CHAR(20);
   DEFINE StatusCred          CHAR(1);
   DEFINE NumProducto         CHAR(4);
   DEFINE Saldo               MONEY(14,2);

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "BajaSaldos.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;

      RETURN cod_ret, NumCredito, StatusCred, NumProducto, Saldo;
   END EXCEPTION;

   LET cod_ret = "000";
   FOREACH
      SELECT
         unique a.num_credito,
         a.status_cred[1,1],
         b.num_producto,
         c.monto_otorgado - sdo_cap_insoluto
      INTO
         NumCredito,
         StatusCred,
         NumProducto,
         Saldo
      FROM
         sd_maecred a,
         sd_definicion b,
         sd_maesdos c --,
--	 bdicheq:sc_tarjeta d
      WHERE
         b.maneja_linea = "S"
      AND
         a.num_producto = b.num_producto
      AND
         c.num_credito = a.num_credito
--      AND
--         d.num_credito = a.num_credito
      ORDER BY 1


      RETURN cod_ret, NumCredito, StatusCred, NumProducto, Saldo
              WITH RESUME;

   END FOREACH;

END PROCEDURE;