CREATE PROCEDURE "informix".val_num(nnumero char(15))
RETURNING BOOLEAN;

-- DEFINE VARIABLES
DEFINE wnumeroi int8;
DEFINE vsqlerr INTEGER;

-- ASIGNA VALORES
LET wnumeroi = 0;
LET vsqlerr = 0;

-- CONTROL DE ERRORES
BEGIN

    ON EXCEPTION SET vsqlerr
          RETURN 'f';
    END EXCEPTION;

    LET nnumero = replace(nnumero,'.','');
    LET nnumero = replace(nnumero,',','');
    LET nnumero = replace(nnumero,'-','');
    LET wnumeroi = nnumero;

END

RETURN 't';
END PROCEDURE;