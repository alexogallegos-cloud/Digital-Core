CREATE PROCEDURE "informix".valida_gracia( p_empresa VARCHAR(3)
                               , p_credito VARCHAR(20))
RETURNING VARCHAR(80);

  DEFINE v_existe INTEGER;
  DEFINE sql_err INTEGER;
  DEFINE p_error varchar(80);

  BEGIN

    LET v_existe = 0;

    select count(*)
      into v_existe
      from sd_maecred
     where nvl(gracia_capital,0) != 0
       and num_credito            = p_credito
       and empresa                = p_empresa;

    if v_existe != 0  then
      LET p_error = 'Credito con gracia de capital ';
      RETURN p_error;
    else
      LET p_error = ' exitoso ';
      RETURN p_error;
    end if;
  END;
RETURN p_error;
END PROCEDURE;