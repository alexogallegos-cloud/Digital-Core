CREATE PROCEDURE "informix".sp_obtieneinfprod2(Tipot CHAR(1), pBin CHAR(6),pSubBin CHAR(2), pCodProdCta CHAR(4), pClavetp CHAR(3))
   RETURNING CHAR(5), CHAR(5), CHAR(6), CHAR(2), CHAR(3), CHAR(4), CHAR(3);
      
   DEFINE cCodRet       CHAR(5);
   DEFINE iSqlErr       INTEGER;
   DEFINE cIdBin        CHAR(5);
   DEFINE cCodBin       CHAR(6);
   DEFINE cProd         CHAR(2);
   DEFINE cCodProd      CHAR(3);
   DEFINE cCodProdCta	CHAR(4);
   DEFINE cClavetp      CHAR(3);
   DEFINE cProdCuenta	CHAR(4);
     
   LET cCodRet        ='00000';   
   LET cIdBin		  ='00000';
   LET cCodBin        ='000000';
   LET cProd		  ='00';
   LET cCodProd       ='000';
   LET cCodProdCta    ='0000';
   LET cClavetp       ='000';
   LET cProdCuenta    ='0000';
   
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
										   
			RETURN cCodRet, cIdBin, cCodBin, cProd, cCodProd, cCodProdCta, cClavetp;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF pBin='416916' AND pSubBin='10' THEN
		LET pClavetp='042';
	END IF;

	IF pBin='416916' AND pSubBin='10' AND pClavetp = '003'  THEN
		LET pClavetp='042';
	END IF;	

	SELECT DISTINCT codprodcta 
	INTO cProdCuenta
	FROM intercard:binproducto a INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
	WHERE a.bin= pBin AND codprodcta = pCodProdCta;

	IF cProdCuenta <> '' OR cProdCuenta IS NOT NULL THEN 

		SELECT DISTINCT idbinproducto, a.bin, a.producto, a.codproductotarjeta, a.codprodcta, clave 
		INTO cIdBin, cCodBin, cProd, cCodProd, cCodProdCta, cClavetp
		FROM intercard:binproducto a
		INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
		WHERE a.bin = pBin 
		AND a.producto= pSubBin 
		AND b.clave = pClavetp
		AND a.codprodcta = pCodProdCta;
	ELSE
		--RETURN '00002';
		LET  cCodRet = '00001';
	END IF;         

	IF cCodBin IS NULL or cCodProd IS NULL THEN
		LET  cCodRet = '00001';
	END IF;

	RETURN cCodRet, cIdBin, cCodBin, cProd, cCodProd, cCodProdCta, cClavetp;
END;
END PROCEDURE;