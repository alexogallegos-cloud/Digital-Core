CREATE PROCEDURE "informix".sp_random() RETURNING INTEGER;
	DEFINE GLOBAL seed DECIMAL(10) DEFAULT 1;
	DEFINE d DECIMAL(20,0);
	LET d = (seed * 1103515245) + 12345;
	-- La funcion MOD no maneja valores de 20 digitos
	LET seed = d - 4294967296 * TRUNC(d / 4294967296);
	RETURN MOD(TRUNC(seed / 65536), 32768);
END PROCEDURE;