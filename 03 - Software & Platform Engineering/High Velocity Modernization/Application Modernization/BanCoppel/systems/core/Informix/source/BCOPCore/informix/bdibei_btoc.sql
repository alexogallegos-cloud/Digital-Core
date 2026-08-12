create function "informix".btoc(v1 BOOLEAN)
RETURNING CHAR(1);

DEFINE r1 CHAR(1);

IF v1 THEN
LET r1 = 't';
ELSE
LET r1 = 'f';
END IF;

RETURN r1;
END FUNCTION;