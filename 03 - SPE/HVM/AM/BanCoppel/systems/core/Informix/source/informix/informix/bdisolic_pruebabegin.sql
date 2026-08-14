create procedure "informix".pruebabegin()

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN;
   END IF;
END EXCEPTION;


begin work;

execute procedure sp_os_integracion("600000672490", "11/11/2006");


end ;



end procedure
;