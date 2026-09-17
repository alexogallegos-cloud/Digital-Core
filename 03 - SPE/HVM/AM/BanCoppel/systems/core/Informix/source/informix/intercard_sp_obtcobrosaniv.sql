CREATE PROCEDURE "informix".sp_obtcobrosaniv(pdtFechaOp datetime year to fraction(5))
RETURNING int,money,char(6),char(13);
define intCantTarjetas integer;
define ImpComAnualidad money;
define  TransCom char(6);
define NumCuenta char(13);
BEGIN
    let intCantTarjetas = 2;
    let ImpComAnualidad = 23;
    let TransCom = "";
    let NumCuenta = '4357690106753014';
    RETURN intCantTarjetas,ImpComAnualidad,TransCom,NumCuenta;
END;
END PROCEDURE;