CREATE PROCEDURE "informix".monthadd(d DATE, i INTEGER)
     RETURNING DATE;

     DEFINE d1 DATE;
     DEFINE rv DATE;
     DEFINE rv2 DATE;

     LET d1 = MDY(MONTH(d), 1, YEAR(d)); -- First day of given month
     LET rv2 = EXTEND(d1, YEAR TO DAY) + i UNITS MONTH; -- Add i months
     LET rv = rv2 + (d - d1); -- Add the days back
     IF MONTH(rv) != MONTH(rv2) THEN -- If the month changed
     LET rv = rv - DAY(rv); -- Subtract the number of days
     -- to get last day of prior month
     END IF;
     RETURN rv;
END PROCEDURE;