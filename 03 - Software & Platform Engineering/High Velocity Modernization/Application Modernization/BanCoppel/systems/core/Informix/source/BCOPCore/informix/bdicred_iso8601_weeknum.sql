CREATE PROCEDURE "informix".iso8601_weeknum(dateval DATE DEFAULT TODAY) RETURNING CHAR(8);
DEFINE rv CHAR(8);
DEFINE yyyy CHAR(4);
DEFINE ww CHAR(2);
DEFINE d1w1 DATE;
DEFINE tv DATE;
DEFINE wn INTEGER;
DEFINE yn INTEGER;
-- Calculate year and week number.
LET yn = YEAR(dateval);
LET d1w1 = day_one_week_one(yn);
IF dateval < d1w1 THEN
-- Date is in early January and is in last week of prior year
LET yn = yn - 1;
LET d1w1 = day_one_week_one(yn);
ELSE
LET tv = day_one_week_one(yn + 1);
IF dateval >= tv THEN
-- Date is in late December and is in the first week of next year
LET yn = yn + 1;
LET d1w1 = tv;
END IF;
END IF;
LET wn = TRUNC((dateval - d1w1) / 7) + 1;
-- Calculation complete: yn is year number and wn is week number.
-- Format result.
LET yyyy = yn;
IF wn < 10 THEN
LET ww = '0' || wn;
ELSE
LET ww = wn;
END IF
LET rv = yyyy || '-W' || ww;
RETURN rv;
END PROCEDURE;