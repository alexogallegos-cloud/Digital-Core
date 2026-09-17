CREATE PROCEDURE "informix".findstr(str VARCHAR(255), ch CHAR(1))
  RETURNING INTEGER;
   DEFINE i INTEGER;

    FOR i = 1 TO length(str)
        IF str[1,1] = ch THEN
            RETURN i;
        END IF;
        LET str = str[2,255];
    END FOR;

    RETURN 0;

END PROCEDURE;