CREATE PROCEDURE "informix".valida_ministracion( p_empresa VARCHAR(3)
                                     , p_credito VARCHAR(20))
RETURNING VARCHAR(80);

  DEFINE v_existe INTEGER;
  DEFINE p_error VARCHAR(80);
  DEFINE sql_err INTEGER;
  
  BEGIN
  
    ON EXCEPTION SET sql_err
       IF sql_err <> 0 then
          LET p_error = 'ocurrio un Error';
          RETURN p_error;
       END IF
    END EXCEPTION;
  
     LET v_existe = 0;
    select count(*)
      into v_existe
      from sd_detminis
     where status_ministra  = 'P'
       and num_credito      = p_credito
       and empresa          = p_empresa;

    if v_existe != 0  then
      LET p_error = 'El credito aun no se ha ministrado en su totalidad ';
      RETURN p_error;
    else
      LET p_error = ' exitoso ';
      RETURN p_error;
    end if;
  END;
RETURN p_error;
END PROCEDURE;