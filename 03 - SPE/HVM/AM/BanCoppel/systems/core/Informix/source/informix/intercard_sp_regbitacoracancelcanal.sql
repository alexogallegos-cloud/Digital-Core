CREATE PROCEDURE "informix".sp_regbitacoracancelcanal(pNumcte CHAR(20),pNumTarjeta CHAR(16),pCanal CHAR(2), pFolio CHAR(16), pFechaReg DATETIME YEAR to FRACTION(5))

    
	DEFINE vNumcte				CHAR(20);
    DEFINE vNumTarjeta  		CHAR(16);
    DEFINE vCanal        		CHAR(2);
    DEFINE vFolio        		CHAR(16);
    DEFINE vFechaReg 			DATETIME YEAR to FRACTION(5);
	
	LET vNumcte = pNumcte;
	LET vNumTarjeta = pNumTarjeta;
	LET vCanal =pCanal;
	LET vFolio = pFolio;
	LET vFechaReg = pFechaReg;

--SET DEBUG FILE TO "/informix/KIAS/CancelaTarjetaCanal/bitacora.out";
--TRACE ON;

BEGIN
  INSERT INTO bitacora_cancelatarjetacanal VALUES(0, vNumcte, vNumTarjeta, vCanal,  vFolio, vFechaReg);
END
END PROCEDURE;