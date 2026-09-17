CREATE PROCEDURE "informix".sp_random() RETURNING INTEGER;
DEFINE GLOBAL seed DECIMAL(10) DEFAULT 1;
DEFINE d DECIMAL(20,0);
DEFINE aux DECIMAL(10);

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
LET aux=0;

    while aux<1000
        LET d = (seed * 1103515245) + 12345;
        -- MOD function does not handle 20-digit values...  Dammit!!
        LET seed = d - 4294967296 * TRUNC(d / 4294967296);
        LET aux=seed;
    end while;
    
    
RETURN MOD(TRUNC(seed / 65536), 32768);
END PROCEDURE;