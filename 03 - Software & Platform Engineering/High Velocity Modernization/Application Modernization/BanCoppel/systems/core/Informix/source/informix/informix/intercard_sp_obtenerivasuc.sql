CREATE PROCEDURE "informix".sp_obtenerivasuc(Sucursal char(3))
RETURNING integer,float ;
BEGIN
    RETURN 0,15;
END;
END PROCEDURE ;