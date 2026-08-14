CREATE PROCEDURE "informix".dia_festivo( p_dia     DATE
                      , p_empresa VARCHAR(3))

RETURNING varchar(80);

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

      LET  v_existe = 0;

      --Funcion que indica si la fecha del parametro es un dia feriado

      select count(*) dia_feriado
        into v_existe
        from si_feriado
       where fecha   = P_DIA
         and empresa = p_empresa;

      If v_existe = 0 Then
         LET p_error = 'N';
         RETURN p_error;
      Else
         LET p_error = 'S';
         RETURN p_error;
      End If;
  END;
RETURN p_error;
END PROCEDURE;