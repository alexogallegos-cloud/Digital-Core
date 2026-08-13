CREATE PROCEDURE "informix".proximafecha()
RETURNING int,date;
BEGIN
    RETURN 0,TO_DATE("1980/12/24", "%Y/%m/%d");
END;
END PROCEDURE;