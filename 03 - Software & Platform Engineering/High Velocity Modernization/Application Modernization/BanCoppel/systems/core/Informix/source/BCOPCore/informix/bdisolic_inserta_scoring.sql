CREATE PROCEDURE "informix".inserta_scoring(v_empresa char(3),
					    v_numcte       char(20),
                                            v_fecha        date,
                                            v_calificacion char(42))
RETURNING varchar(8);

DEFINE p_codret VARCHAR(8);
DEFINE sql_err  INTEGER;

BEGIN

    ON EXCEPTION SET sql_err
       IF sql_err <> 0 then
          LET p_codret = sql_err;
          RETURN p_codret;
       END IF
    END EXCEPTION

    LET p_codret = '000';

    DELETE FROM ss_scoring WHERE numcte = v_numcte;

    INSERT INTO SS_SCORING (numcte,fecha,calificacion)
    VALUES ( v_numcte,v_fecha,v_calificacion);

END;
RETURN p_codret;
END PROCEDURE;