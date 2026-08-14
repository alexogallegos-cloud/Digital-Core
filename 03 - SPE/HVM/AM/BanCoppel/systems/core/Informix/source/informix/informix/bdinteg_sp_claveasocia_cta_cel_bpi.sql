CREATE FUNCTION "informix".sp_claveasocia_cta_cel_bpi(pNumCel char(10))				  

RETURNING
    -- CodigoRetorno    
    CHAR(6);       
	
	-- Declarar variables 
	DEFINE cCodRet 		CHAR(6);
	DEFINE iSql_err 	INTEGER;
    DEFINE iExist       INTEGER;
	DEFINE ifcha        DATETIME YEAR to FRACTION(3);
	
	DEFINE cUno		    CHAR(1);
	DEFINE cDos		    CHAR(1);
	DEFINE cTre		    CHAR(1);
	DEFINE cInit		CHAR(10);
	DEFINE cResp		CHAR(10);
	DEFINE dHora        DATETIME HOUR TO SECOND;
	DEFINE GLOBAL seed DEC( 10 ) DEFAULT 1;
    DEFINE d DEC( 20, 0 );
    DEFINE noMTU        CHAR(2);

    --Asignacion de variables
	LET iExist	    =   0;    
	LET cCodRet     =   '';
    LET noMTU       =   '01';
	
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
		LET cCodRet = '556822';
		RETURN cCodRet;
	END IF	
	
	SELECT Count(*), MAX(fecha) into iExist, ifcha
	FROM bdinteg:"informix".si_bitsmstelsms_bpi WHERE  telefono=pNumCel AND DATE(fecha)=DATE(current) AND bandera='f' AND tipo_flujo=noMTU;
	
	IF iExist > 0 THEN
		
		SELECT digito_ver into cCodRet
		FROM bdinteg:"informix".si_bitsmstelsms_bpi WHERE  telefono=pNumCel AND fecha=ifcha AND bandera='f';
		
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
	LET cInit = SUBSTR(dHora, 7,2)||SUBSTR(dHora, 4,2)||cUno||cDos||cTre; 
	LET d = cInit::INT;
	LET d = seed * 1103515245 + d;
	LET seed = d - 4294967296 * TRUNC( d / 4294967296 );	
	LET cResp = MOD( TRUNC( seed / 65536 ), 32768 );
	
	LET cCodRet = trim(cResp) || trim(cInit);
	
	IF LEN(cCodRet) < 6 THEN
	     LET cCodRet = TRIM(RIGHT(pNumCel,2)) || trim(cCodRet) || trim(cResp)|| TRIM(LEFT(pNumCel,2)) ;
	END IF
		
		
	RETURN cCodRet;
	
END 
END FUNCTION;