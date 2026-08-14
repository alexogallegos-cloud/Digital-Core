CREATE PROCEDURE "informix".sp_validaproducto(pEmpresa CHAR(3), pNumCuenta CHAR(20), pTipo CHAR(1))

RETURNING CHAR(6), CHAR(1), CHAR(1), SMALLINT;

--28/11/2008
--Rodolfo Tortolero Varela
--Valida que el nùmero de cuenta se le pueda asignar una tarjeta adicional

--02/12/2008
--Rodolfo Tortolero Varela
--Se modifico para tambien recibir tarjetas de crédito.

--14/10/2009
--Rodolfo Tortolero Varela
--Se agrega validación para cuando la consulta de producto se haga por número de tarjeta

--DEFINICION DE VARIABLES--
	DEFINE iSqlErr INTEGER;
	DEFINE vCodRet CHAR(6);
	DEFINE vProducto CHAR(4);
	DEFINE vFlagAdic CHAR(1);
	DEFINE vFlagTar CHAR(1);
	DEFINE vTotAdic SMALLINT;
	DEFINE vProd CHAR(4);

--Set debug file to '/tmp/sp_consultacuentas.out';
--trace on;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET vCodRet = iSqlErr;
				RETURN vCodRet, vFlagAdic, vFlagTar, vTotAdic;
			END IF;
		END EXCEPTION;
	
--INICIALIZACION DE VARIABLES--
	LET iSqlErr = 0;
	LET vCodRet = '000';	--Si Existe el tipo de producto
	LET vProducto = "";
	LEt vFlagAdic = "";
	LET vFlagTar = "";
	LEt vTotAdic = 0;
	LEt vProd = "";
		
	IF pNumCuenta = "" THEN
		LET vCodRet = '999'; --Falta el parametro nùmero de cuenta
			LET vFlagAdic = NULL;
			LET vFlagTar = NULL;
			LET vTotAdic = NULL;
		RETURN vCodRet, vFlagAdic, vFlagTar, vTotAdic;
	END IF;
	
	--Se selecciona el producto de la cuenta
	IF pTipo = "1" THEN --Productos de Débito
		IF LENGTH(pNumCuenta) = 11 THEN
			SELECT producto INTO vProd FROM bdicheq:sc_maechq 
			 WHERE cuenta = pNumCuenta;
		ELSE
			SELECT b.producto INTO vProd FROM bdicheq:sc_tarjeta a, bdicheq:sc_maechq b
			WHERE a.empresa = pEmpresa 
			  AND a.num_tarjeta = pNumCuenta 
			  AND a.cuenta = b.cuenta;
		END IF;
	ELIF pTipo = "2" THEN --Productos de Inversión
		SELECT cod_instrum INTO vProd FROM bdinvers:sv_maeinv WHERE cuenta = pNumCuenta;
	ELIF pTipo = "3" THEN --Productos de Crédito Bancoppel
		SELECT b.num_producto INTO vProd FROM bdicred:sd_tarjeta a, bdicred:sd_maecred b
		WHERE a.empresa = pEmpresa 
		  AND a.num_tarjeta = pNumCuenta 
		  AND a.empresa = b.empresa
		  AND a.num_credito = b.num_credito;
	ELIF pTipo = "4" THEN --Producto de Crédito Coppel
		LET vProd = "6500";
	END IF;
	
	SELECT producto, flagadicional, flagtarjeta, totadicional
	INTO vProducto, vFlagAdic, vFlagTar, vTotAdic
	FROM si_catvalidaprod
	WHERE empresa = pEmpresa
	AND producto = vProd;
        
	IF vFlagAdic = '0'  THEN
		LET vFlagTar = '0';
		LET vTotAdic = '0';
	END IF;        
        
	IF vProducto IS NULL THEN
		LET  vCodRet = '001'; --No Existe el producto en la tabla si_catvalidaprod
	END IF;
		
	RETURN vCodRet, vFlagAdic, vFlagTar, vTotAdic;

	END;
END PROCEDURE;