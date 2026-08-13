CREATE PROCEDURE "informix".getrandomcode()
	RETURNING INT, CHAR(8);
	
	DEFINE m INT8;
	DEFINE a INT8;
	DEFINE time INT8;
	DEFINE x INT8;
	DEFINE _x DECIMAL(24);
	DEFINE c INT8;
	DEFINE k INT8;
	DEFINE _rnd CHAR(8);
	DEFINE i INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cCadRnds CHAR(64);
	DEFINE cAscii CHAR(1);
	DEFINE iRows INTEGER;
	DEFINE y INT8;
	
	LET m = 4294967296;
	LET a = 65537;
	LET c = 214748364;
	LET k = 16;
	LET _rnd = '';
	LET iSqlErr = 0;
	LET cCadRnds = '';
	LET cAscii  = '';
	LET iRows = 0;
	LET _x = 0.0;
	LET x = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET _rnd = iSqlErr;
			RETURN iSqlErr, _rnd;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/getRandomCode.out';
		--TRACE ON;
		
		SELECT ((CURRENT YEAR TO SECOND) - (EXTEND(DATETIME(2013-1-1) YEAR TO DAY, YEAR TO SECOND)))::INTERVAL SECOND(9) TO SECOND::CHAR(10)::INT
		INTO x
		FROM systables WHERE tabid = 1;

		WHILE LENGTH(TRIM(cCadRnds)) < 70
			LET x = (a * x) + c;
			LET x = MOD(x, m);
			LET _x = x / m;
			
			LET y = 65 + (_x * (116 - 65));
			EXECUTE FUNCTION getint2ascii(y::INT) INTO cAscii;
			LET cCadRnds = TRIM(cCadRnds)||cAscii;
			
			IF LENGTH(TRIM(cCadRnds)) = 64 THEN
				EXIT WHILE;
			END IF;
		END WHILE;
		
		LET iRows = 0;
		FOR i=0 TO LENGTH(cCadRnds) STEP 8
			RETURN iRows, SUBSTR(cCadRnds, i, 8) WITH RESUME;
			LET iRows = iRows + 1;
			IF iRows = 8 THEN
				EXIT FOR;
			END IF;
		END FOR;
		
	END;
	
END PROCEDURE;