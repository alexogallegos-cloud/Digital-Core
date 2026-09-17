create function "informix".cajero_cierreest(pempresaid  char(3),
                                           pusuarioid  char(8),
                                           pestado     smallint)
   returning integer;

   define cod_ret      integer;

   define wtotal       integer;
   define sql_err      integer;
BEGIN
   ON EXCEPTION SET sql_err
      if sql_err <> 0 then
         let cod_ret = sql_err;
         RETURN cod_ret;
      end if
   END EXCEPTION;

   SELECT count(*) into wtotal
   FROM so_usuariostatus
   WHERE  empresaid= pempresaid
   AND  usuarioid= pusuarioid;

      IF (wtotal > 0) then
      --- Actualizamos el estado del cajero firmado acorde con lo especificado
         UPDATE so_usuariostatus
         SET cajerocierreest=pestado
         WHERE  empresaid= pempresaid
   	    AND  usuarioid= pusuarioid;

         LET cod_ret = 0;
         RETURN cod_ret;
      ELSE
         LET cod_ret = 2;
         RETURN cod_ret;
      END IF
   END
end function;