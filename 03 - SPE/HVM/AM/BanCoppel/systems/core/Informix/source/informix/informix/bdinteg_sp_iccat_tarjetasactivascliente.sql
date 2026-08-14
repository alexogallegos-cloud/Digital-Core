CREATE PROCEDURE "informix".sp_iccat_tarjetasactivascliente(pnum_cliente VARCHAR(13))
        RETURNING CHAR(9) AS cod_ret,
				  CHAR(16) AS numtarjeta;

        DEFINE cCodRet 	  	CHAR(9);
		DEFINE cNumTarjeta 	CHAR(16);
        DEFINE iSqlErr 		INTEGER;

        LET cCodRet = '000000000';
		LET cNumTarjeta = '';
        LET iSqlErr = 0;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        BEGIN

			ON EXCEPTION SET iSqlErr
					LET cCodRet = iSqlErr;
					RETURN cCodRet, NVL(cNumTarjeta,'');
			END EXCEPTION;

			--SET DEBUG FILE TO '/home/sysifx/MarcoRivera/logs/sp_iccat_tarjetasActivasCliente.out';
			--TRACE ON;

			IF NVL(pnum_cliente,'') = '' THEN
					LET cCodRet = '000000001'; --Parametros incompletos
					RETURN cCodRet, cNumTarjeta;
			END IF;
			
			IF EXISTS(SELECT numtarjeta FROM intercard:tarjeta WHERE numcliente = pnum_cliente AND codstatustarjeta = 'ACT') THEN
				FOREACH
					SELECT numtarjeta INTO cNumTarjeta FROM intercard:tarjeta 
					WHERE numcliente = pnum_cliente AND codstatustarjeta = 'ACT'
					
					RETURN cCodRet, NVL(cNumTarjeta,'') WITH RESUME;
					
				END FOREACH;
			ELSE
				LET cCodRet = '000000002'; --No se encontraron tarjetas para el cliente
				RETURN cCodRet, NVL(cNumTarjeta,'');
			END IF;
        END;

END PROCEDURE
DOCUMENT
'AUTOR: Marco Rivera',
'FECHA: 24/01/2022',
'DESCRIPCION: Procedimiento para obtener las tarjetas activas del cliente ICCAT';

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