CREATE PROCEDURE "informix".actualiza_solicitud( p_empresa   VARCHAR(3)
                              , p_solicitud VARCHAR(20))
RETURNING varchar(80);

  DEFINE P_COD_RET   VARCHAR(100);
  DEFINE P_MENSAJE   VARCHAR(150);
  DEFINE p_error     VARCHAR(80);
  DEFINE sql_err     INTEGER;


  BEGIN

    ON EXCEPTION SET sql_err
       IF sql_err <> 0 then
          LET p_error = 'ocurrio un Error';
          RETURN p_error;
       END IF
    END EXCEPTION;

      update ss_soltrat
         set status_solicitud = 'AR'
       where num_solicitud = p_solicitud
         and empresa       = p_empresa;

      LET p_error = ' exitoso ';
      
  END;
RETURN p_error;
END PROCEDURE;