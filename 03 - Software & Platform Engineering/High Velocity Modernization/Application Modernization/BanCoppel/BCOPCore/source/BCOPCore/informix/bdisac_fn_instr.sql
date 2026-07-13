CREATE FUNCTION "informix".fn_instr(pString VARCHAR(255),pToken VARCHAR(255),pStar INTEGER DEFAULT 1 )
RETURNING SMALLINT ;

	DEFINE i,j SMALLINT ;
	DEFINE w_1 VARCHAR(255) ;

	IF ( pString IS NULL) OR (pToken IS NULL ) THEN
		RETURN -1 ;
	END IF ;
	LET j = LENGTH(pString);
	FOR i = pStar TO j 
		IF ( SUBSTR(pString,I,1) = SUBSTR(pToken,1,1) ) THEN
			LET w_1 = SUBSTR(pString,i,LENGTH(pToken)) ;
			IF ( w_1 = pToken) THEN
				RETURN i ;
			END IF ;
		END IF ;
	END FOR ;
RETURN 0 ;
END FUNCTION ;