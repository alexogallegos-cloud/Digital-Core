CREATE PROCEDURE "informix".sp_obtenerid(p_usuario CHAR(10))

RETURNING INTEGER;

DEFINE v_idreporte INTEGER;

SET LOCK MODE TO WAIT 4;
SET ISOLATION TO DIRTY READ;

LET v_idreporte = 0;

    BEGIN

        SELECT MAX(id_reporte) 
        INTO v_idreporte
        FROM bdicont:"informix".co_libmadet
        WHERE usuario_rep = p_usuario;
        
        IF v_idreporte = 0 OR v_idreporte IS NULL THEN
            LET v_idreporte = 1;
        ELSE
            LET v_idreporte = v_idreporte + 1;
        END IF;
        
        RETURN v_idreporte;
    END

END PROCEDURE;