CREATE PROCEDURE "informix".sp_random()
RETURNING INTEGER;
    
    DEFINE GLOBAL seed DECIMAL(10) DEFAULT 1;
    DEFINE d DECIMAL(20,0);
    
    LET d = (seed * 1103515245) + 12345;
    
    --- MOD function does not handle 20-digit values...
    
    LET seed = d - 4294967296 * TRUNC(d / 4294967296);
    
    Return MOD(TRUNC(seed / 65536), 99);
    
END PROCEDURE;