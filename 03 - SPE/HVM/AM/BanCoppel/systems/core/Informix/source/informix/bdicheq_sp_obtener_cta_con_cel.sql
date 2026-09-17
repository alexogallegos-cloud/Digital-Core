CREATE PROCEDURE "informix".sp_obtener_cta_con_cel(pNumCte CHAR(10))
											  
-- Valida si el cliente tiene un número de celular asociado a una cuenta
-- AUTOR : Keevyn Adrian Gil Valenzuela
-- FECHA : 29/11/2016
-- BD    : bdicheq

RETURNING
    CHAR(5),
	CHAR(10),
	CHAR(20);        
	
	-- Declarar variables 
	DEFINE cCodRet char(5);
	DEFINE cNumCel char(10);
	DEFINE cCuenta char(20);
	DEFINE iSql_err integer;

	-- Inicializar variables 
	LET cCodRet  = "";
	LET cNumCel  = "";
	LET cCuenta  = "";
	LET iSql_err = 0;

	
BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			let cCodRet = iSql_err;
            RETURN cCodRet,cNumCel,cCuenta;
		END IF;
	END EXCEPTION ;
	
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/respaldosbd/Keevyn/sp_obtener_cta_con_cel.out";
	--TRACE ON;
	
	SELECT cuenta,telefono INTO cCuenta,cNumCel FROM bdicheq:"informix".sc_cuenta_telefono WHERE num_cte=pNumCte;
	IF (TRIM(cCuenta) <> "" OR cCuenta IS NOT NULL) THEN--Tiene celular asociado
		LET cCodRet="00000";
	ELSE
		LET cCodRet = "00001";	END IF	
	RETURN cCodRet,cNumCel,cCuenta;

END
END PROCEDURE;