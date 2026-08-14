CREATE PROCEDURE "informix".valida_credito( p_empresa VARCHAR(3)
                                , p_credito VARCHAR(20))
RETURNING VARCHAR(80);

  DEFINE v_status varchar(30);
  DEFINE p_error varchar(80);
  DEFINE sql_err integer;

  BEGIN

    ON EXCEPTION SET sql_err
       IF sql_err <> 0 then
          LET p_error = 'ocurrio un Error';
          RETURN p_error;
       END IF
    END EXCEPTION;

    LET v_status = ' ';
  
    select status_cred
      into v_status
      from sd_maecred
     where status_cred in ('AC','AR','BC','BR','CE','CC','CO'
                          ,'FF','FC','FR','FE','TC','TR','TE'
                          )
       and num_credito   = p_credito
       and empresa   = p_empresa
       and rownum    < 2;
       
    LET p_error = ' exitoso ';
    if v_status != ' '  then
      LET p_error = 'El credito se encuentra en status '|| v_status;
      RETURN p_error;
    else
      LET p_error = ' exitoso ';
      RETURN p_error;
    end if;
  END;
RETURN p_error;
END PROCEDURE;