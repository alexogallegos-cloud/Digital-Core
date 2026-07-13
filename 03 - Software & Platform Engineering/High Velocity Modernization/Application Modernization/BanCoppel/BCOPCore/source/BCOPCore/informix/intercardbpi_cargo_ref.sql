CREATE PROCEDURE "informix".cargo_ref(Sucursal char(3),Usuario char(8), TransacCentral char(4), TransacSucursal char(4),
    FolioSuc char(15), NumCuenta char(13), Documento integer, Importe money, Moneda char(2), Descripcion char(40))
RETURNING char(5), char(4), char(10), money, integer, char(5);
BEGIN
    RETURN "00000","1234","06/01/2004",123.45,100,"00000";
END;
END PROCEDURE;