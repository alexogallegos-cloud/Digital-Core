CREATE PROCEDURE "informix".incr_date(pBeg_date DATE, pIncr_mos INTEGER)
       RETURNING DATE;

-- Increment or decrement a date by a specified number of months. If the
-- computed date is beyond the last day of the month, return the last day
-- of the month.

DEFINE pComp_date  DATE;
DEFINE pAdj_days   SMALLINT;

BEGIN
      LET pAdj_days = 0;
      WHILE 1 = 1

          -- If the computed day is beyond the last day of the month,
          -- then subtract one day at a time until we find the last day
          -- of that month.

          ON EXCEPTION IN (-1267)
              LET pAdj_days = pAdj_days + 1;
          END EXCEPTION

          LET pComp_date =
              DATE (EXTEND (pBeg_date, YEAR TO DAY)
                    - pAdj_days UNITS DAY
                    + pIncr_mos UNITS MONTH);
          EXIT WHILE;
      END WHILE

      RETURN pComp_date;

END

END PROCEDURE;