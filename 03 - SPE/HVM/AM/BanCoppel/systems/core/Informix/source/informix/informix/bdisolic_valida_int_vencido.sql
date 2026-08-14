CREATE PROCEDURE "informix".valida_int_vencido( p_empresa VARCHAR(3)
                                    , p_credito VARCHAR(80))
RETURNING VARCHAR(80);

  DEFINE v_existe_int INTEGER ;
  DEFINE p_error varchar(80);
  DEFINE sql_err INTEGER;
  
  BEGIN
  
    ON EXCEPTION SET sql_err
       IF sql_err <> 0 then
          LET p_error = 'ocurrio un Error';
          RETURN p_error;
       END IF
    END EXCEPTION;
  
    LET v_existe_int = 0;
    select sum(nvl(sdo_exig_int,0)) + sum(nvl(mto_venc_int,0))
      into v_existe_int
      from sd_maesdos
     where num_credito = p_credito
       and empresa     = p_empresa;

    if v_existe_int != 0  then
      LET p_error = 'Existen intereses vencidos ';
      RETURN p_error;
    else
      LET p_error = ' exitoso ';
      RETURN p_error;
    end if;
  END;
RETURN p_error;
END PROCEDURE;