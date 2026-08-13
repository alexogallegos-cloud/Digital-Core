CREATE PROCEDURE "informix".sp_get_fecha_estadistica()
            RETURNING char(10);
BEGIN
 RETURN to_char(current - 1 UNITS DAY,'%Y-%m-%d');
 END;
END PROCEDURE
;