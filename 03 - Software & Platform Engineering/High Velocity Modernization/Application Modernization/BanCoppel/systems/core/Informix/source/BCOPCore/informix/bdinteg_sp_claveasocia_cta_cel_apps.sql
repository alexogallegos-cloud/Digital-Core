CREATE PROCEDURE "informix".sp_claveasocia_cta_cel_apps(pNumCel char(10))	
								  
-- Genera una clave de confirmaciÃ³n para validar el nÃºmero de celular que se desea asociar a una cuenta.
-- AUTOR : Keevyn Adrian Gil Valenzuela
-- FECHA : 16/11/2016
-- BD    : bdinteg
-- AJUSTE: IREB --> SE ACTUALIZA USUARIO PARA LA VALIDACION  A ITUNES


RETURNING
    CHAR(4);        -- CodigoRetorno
	

	-- Declarar variables 
	DEFINE cCodRet 		CHAR(4);
	DEFINE iSql_err 	INTEGER;
    DEFINE iExist       INTEGER;
	DEFINE ifcha        DATETIME YEAR to FRACTION(3);
	
	DEFINE cUno		CHAR(1);
	DEFINE cDos		CHAR(1);
	DEFINE cTre		CHAR(1);
	DEFINE cInit		CHAR(4);
	DEFINE cResp		CHAR(6);
	DEFINE dHora        DATETIME HOUR TO SECOND;
	DEFINE GLOBAL seed DEC( 10 ) DEFAULT 1;
    DEFINE d DEC( 20, 0 );


	LET iExist	    =   0;    
	
BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			let cCodRet = iSql_err;
            RETURN cCodRet;
		END IF;
	END EXCEPTION ;
	
	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;


	
	IF pNumCel = '5591902135' or pNumCel='5576650768' or pNumCel='6444165101' THEN  --Para la validacion de itunes
		
		LET cCodRet = '5511';
				
		RETURN cCodRet;

	END IF	
	
	LET cCodRet = '';
	
	SELECT Count(*), MAX(fecha) into iExist, ifcha
	FROM bdinteg:"informix".si_bitsmstelsms WHERE  telefono=pNumCel AND DATE(fecha)=DATE(current) AND bandera='f';
	
	IF iExist > 0 THEN
		
		SELECT digito_ver into cCodRet
		FROM bdinteg:"informix".si_bitsmstelsms WHERE  telefono=pNumCel AND fecha=ifcha AND bandera='f';
		
		IF cCodRet <> '' THEN
			RETURN cCodRet;
		END IF	
		
	END IF
	
	
		LET dHora = current hour to fraction;
		LET d = SUBSTR(dHora, 7,1);	
		LET cUno =  SUBSTR( pNumCel, d,1);
		LET d = SUBSTR(dHora, 4,1);	
		LET cDos =  SUBSTR( pNumCel, d,1);
		LET d = SUBSTR(dHora, 2,1);	
		LET cTre =  SUBSTR( pNumCel, d,1);
		LET cInit = SUBSTR(dHora, 7,2)||SUBSTR(dHora, 4,2); 
		LET d = cInit::INT;
		LET d = seed * 1103515245 + d;
		LET seed = d - 4294967296 * TRUNC( d / 4294967296 );
		LET cResp = MOD( TRUNC( seed / 65536 ), 32768 );
		
		LET cCodRet = LEFT(cResp,4);
		
		
		IF LEN(cCodRet) < 4 THEN
			LET cCodRet = trim(cCodRet) || cTre;
			LET cCodRet = LEFT(cCodRet,4);
		END IF;
		
		IF LEN(cCodRet) = 4 THEN 
			RETURN cCodRet;	
		END IF;
		
		LET cCodRet = LEFT(cCodRet,6);
		
		
	RETURN cCodRet;
	
END 
END PROCEDURE;