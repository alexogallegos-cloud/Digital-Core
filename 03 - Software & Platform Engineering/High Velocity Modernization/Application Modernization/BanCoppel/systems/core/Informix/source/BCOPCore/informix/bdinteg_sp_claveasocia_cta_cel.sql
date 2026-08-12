CREATE PROCEDURE "informix".sp_claveasocia_cta_cel(pNumCel CHAR(10))
											  
-- Genera una clave de confirmación para validar el número de celular que se desea asociar a una cuenta.
-- AUTOR : Keevyn Adrian Gil Valenzuela
-- FECHA : 16/11/2016
-- BD    : bdinteg

RETURNING
    CHAR(6);        -- CodigoRetorno
	

	-- Declarar variables 
	DEFINE cCodRet 		CHAR(6);
	DEFINE iSql_err 	INTEGER;
	
	DEFINE cUno			CHAR(2);
	DEFINE cDos			CHAR(2);
	DEFINE cTres		CHAR(2);
	DEFINE dHora        DATETIME HOUR TO SECOND;
	
	
BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			let cCodRet = iSql_err;
            RETURN cCodRet;
		END IF;
	END EXCEPTION ;
	
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/respaldosbd/Keevyn/sp_claveasocia_cta_cel.out";
	--TRACE ON;
	
	LET dHora = current hour to fraction;
	LET cUno = SUBSTR(pNumCel,3,2);
	LET cDos = SUBSTR(pNumCel,7,2);
	LET cTres = SUBSTR(dHora, 7,2);
	LET cCodRet = cUno || cDos || cTres;
	
		
	RETURN cCodRet;
	
END 
END PROCEDURE;