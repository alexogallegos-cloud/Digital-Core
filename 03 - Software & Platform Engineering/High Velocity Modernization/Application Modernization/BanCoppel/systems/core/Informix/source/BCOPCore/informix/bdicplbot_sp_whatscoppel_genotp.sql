CREATE PROCEDURE "informix".sp_whatscoppel_genotp( pCteCoppel CHAR(9), pNumCel char(10) )				  
RETURNING CHAR(5), CHAR(9), CHAR(6); 
	
	DEFINE cCodRet 		CHAR(5);
    DEFINE cCodRet2		CHAR(5);
    DEFINE cCodRet3		CHAR(80);
	DEFINE iSql_err 	INTEGER;
    DEFINE iSam_err 	INTEGER;
    DEFINE cDes_err 	CHAR(80);
    DEFINE iExist       INTEGER;
	DEFINE ifcha        DATETIME YEAR to FRACTION(3);
	DEFINE cUno		    CHAR(1);
	DEFINE cDos		    CHAR(1);
	DEFINE cTre		    CHAR(1);
	DEFINE cInit		CHAR(10);
	DEFINE cResp		CHAR(10);
	DEFINE dHora        DATETIME HOUR TO SECOND;
	DEFINE GLOBAL seed  DEC(10) DEFAULT 1;
    DEFINE d            DEC(20,0);
    DEFINE cOTP         CHAR(6);
    
    LET cCodRet  = '00000';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
    LET iSql_err = 0;
    LET iSam_err = 0;
    LET cDes_err = '';
	LET iExist	 = 0;    
    LET ifcha    = '';
    LET cUno     = '';
    LET cDos     = '';
    LET cTre     = '';
    LET cInit    = '';
    LET cResp    = '';
    LET dHora    = '';
    LET seed     = 1;
    LET d        = 0;
    LET cOTP     = '';
	
    BEGIN
    
	ON EXCEPTION SET iSql_err, iSam_err, cDes_err
        --SET DEBUG FILE TO "/informix/ids_10UC11/jivan/whatscoppel/sp_whatscoppel_genotp.err";
        --TRACE ON;
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
            LET cCodRet2 = iSam_err;
            LET cCodRet3 = cDes_err;
            RETURN cCodRet, pCteCoppel, cOTP;
		END IF;
	END EXCEPTION;
    
    --SET DEBUG FILE TO "/informix/ids_10UC11/jivan/whatscoppel/sp_whatscoppel_genotp.out";
    --TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
    IF ( pCteCoppel is null OR pCteCoppel = '' ) OR
       ( pNumCel is null OR pNumCel = '' OR LENGTH(pNumCel) <> 10 ) THEN
        LET cCodRet = '00110';
        RETURN cCodRet, pCteCoppel, cOTP;
    END IF;
    
	LET dHora = current hour to fraction;
	LET d     = SUBSTR(dHora, 7,1);	
	LET cUno  = SUBSTR( pNumCel, d,1);
	LET d     = SUBSTR(dHora, 4,1);	
	LET cDos  = SUBSTR( pNumCel, d,1);
	LET d     = SUBSTR(dHora, 2,1);	
	LET cTre  = SUBSTR( pNumCel, d,1);
	LET cInit = SUBSTR(dHora, 7,2)||SUBSTR(dHora, 4,2)||cUno||cDos||cTre; 
	LET d     = cInit::INT;
	LET d     = seed * 1103515245 + d;
	LET seed  = d - 4294967296 * TRUNC( d / 4294967296 );	
	LET cResp = MOD( TRUNC( seed / 65536 ), 32768 );
    
	LET cOTP = TRIM(cResp)||TRIM(cInit);
    
	IF LEN(cOTP) < 6 THEN
	     LET cOTP = TRIM(RIGHT(pNumCel,2))||TRIM(cOTP)||TRIM(cResp)||TRIM(LEFT(pNumCel,2)) ;
	END IF
    
	RETURN cCodRet, pCteCoppel, cOTP;
    
    END;
    
END PROCEDURE;