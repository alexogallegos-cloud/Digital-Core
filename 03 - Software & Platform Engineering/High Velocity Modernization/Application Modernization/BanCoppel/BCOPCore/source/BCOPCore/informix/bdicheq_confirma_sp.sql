CREATE PROCEDURE "informix".confirma_sp(pempresa char(3),
                                        p_rastreo char(16))
RETURNING char(5);


DEFINE v_codret char(5);
DEFINE sql_err  integer;

LET v_codret = "000";

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET v_codret = sql_err;
         RETURN v_codret;
      END IF
   END EXCEPTION;

   UPDATE bdispeua:sp_pagoenviar 
      SET status_envio = " "
      WHERE clave_rastreo = p_rastreo;
   RETURN v_codret;
END
END PROCEDURE;