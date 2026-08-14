CREATE FUNCTION "informix".getint2ascii(pNumber INT)
	RETURNING CHAR(1) as cascii;
	
	DEFINE cAscii CHAR(1);
	
	LET cAscii = '';
	
	BEGIN
	
		IF pNumber = 65 THEN
			LET cAscii = 'A';
		ELIF pNumber = 66 THEN
			LET cAscii = 'B';
		ELIF pNumber = 67 THEN
			LET cAscii = 'C';
		ELIF pNumber = 68 THEN
			LET cAscii = 'D';
		ELIF pNumber = 69 THEN
			LET cAscii = 'E';
		ELIF pNumber = 70 THEN
			LET cAscii = 'F';
		ELIF pNumber = 71 THEN
			LET cAscii = 'G';
		ELIF pNumber = 72 THEN
			LET cAscii = 'H';
		ELIF pNumber = 73 THEN
			LET cAscii = 'I';
		ELIF pNumber = 74 THEN
			LET cAscii = 'J';
		ELIF pNumber = 75 THEN
			LET cAscii = 'K';
		ELIF pNumber = 76 THEN
			LET cAscii = 'L';
		ELIF pNumber = 77 THEN
			LET cAscii = 'M';
		ELIF pNumber = 78 THEN
			LET cAscii = 'N';
		ELIF pNumber = 79 THEN
			LET cAscii = 'O';
		ELIF pNumber = 80 THEN
			LET cAscii = 'P';
		ELIF pNumber = 81 THEN
			LET cAscii = 'Q';
		ELIF pNumber = 82 THEN
			LET cAscii = 'R';
		ELIF pNumber = 83 THEN
			LET cAscii = 'S';
		ELIF pNumber = 84 THEN
			LET cAscii = 'T';
		ELIF pNumber = 85 THEN
			LET cAscii = 'U';
		ELIF pNumber = 86 THEN
			LET cAscii = 'V';
		ELIF pNumber = 87 THEN
			LET cAscii = 'W';
		ELIF pNumber = 88 THEN
			LET cAscii = 'X';
		ELIF pNumber = 89 THEN
			LET cAscii = 'Y';
		ELIF pNumber = 90 THEN
			LET cAscii = 'Z';
		ELIF pNumber = 91 THEN
			LET cAscii = 'a';
		ELIF pNumber = 92 THEN
			LET cAscii = 'b';
		ELIF pNumber = 93 THEN
			LET cAscii = 'c';
		ELIF pNumber = 94 THEN
			LET cAscii = 'd';
		ELIF pNumber = 95 THEN
			LET cAscii = 'e';
		ELIF pNumber = 96 THEN
			LET cAscii = 'f';
		ELIF pNumber = 97 THEN
			LET cAscii = 'g';
		ELIF pNumber = 98 THEN
			LET cAscii = 'h';
		ELIF pNumber = 99 THEN
			LET cAscii = 'i';
		ELIF pNumber = 100 THEN
			LET cAscii = 'j';
		ELIF pNumber = 101 THEN
			LET cAscii = 'k';
		ELIF pNumber = 102 THEN
			LET cAscii = 'l';
		ELIF pNumber = 103 THEN
			LET cAscii = 'm';
		ELIF pNumber = 104 THEN
			LET cAscii = 'n';
		ELIF pNumber = 105 THEN
			LET cAscii = 'o';
		ELIF pNumber = 106 THEN
			LET cAscii = 'p';
		ELIF pNumber = 107 THEN
			LET cAscii = 'q';
		ELIF pNumber = 108 THEN
			LET cAscii = 'r';
		ELIF pNumber = 109 THEN
			LET cAscii = 's';
		ELIF pNumber = 110 THEN
			LET cAscii = 't';
		ELIF pNumber = 111 THEN
			LET cAscii = 'u';
		ELIF pNumber = 112 THEN
			LET cAscii = 'v';
		ELIF pNumber = 113 THEN
			LET cAscii = 'w';
		ELIF pNumber = 114 THEN
			LET cAscii = 'x';
		ELIF pNumber = 115 THEN
			LET cAscii = 'y';
		ELIF pNumber = 116 THEN
			LET cAscii = 'z';
		END IF;
		
		RETURN cAscii;
	END;

END FUNCTION;