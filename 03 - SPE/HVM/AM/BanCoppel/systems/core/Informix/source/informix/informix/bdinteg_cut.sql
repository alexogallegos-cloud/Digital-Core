CREATE PROCEDURE "informix".cut (string VARCHAR(255), delimiter CHAR(1))
  RETURNING VARCHAR(255);
  DEFINE i INTEGER;
  DEFINE loc INTEGER;
  DEFINE res VARCHAR(255);

  LET loc = FindStr(string, delimiter);
  IF loc = 0 THEN
    RETURN string;
  END IF;

  LET res = '';

  FOR i = 1 TO loc - 1
    LET res = res || string[1,1];
    LET string = string[2,255];
  END FOR;

  RETURN res;
END PROCEDURE;