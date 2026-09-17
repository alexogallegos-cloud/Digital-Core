CREATE FUNCTION "informix".sp817_random() RETURNING FLOAT
   DEFINE GLOBAL seed DECIMAL(10) DEFAULT NULL;
   DEFINE d DECIMAL(20,0);
   DEFINE x1 FLOAT;
   DEFINE x2 FLOAT;
   IF seed is NULL THEN
      EXECUTE PROCEDURE sp817_SetRandomSeed();
   END IF;   
   LET d = (seed * 1103515245) + 12345;
   LET seed = d - 4294967296 * TRUNC(d / 4294967296);
   LET x1 = MOD(TRUNC(seed / 65536), 32768);
   LET d = (seed * 1103515245) + 12345;
   LET seed = d - 4294967296 * TRUNC(d / 4294967296);
   LET x2 = MOD(TRUNC(seed / 65536), 32768);
   IF x1 > x2 then
      RETURN x2/x1;
   ELSE
      RETURN x1/x2;
   END IF;
END FUNCTION;