CREATE PROCEDURE "informix".ugenera_edocuenta (
				pempresa char(3),
				pnum_credito char(20),
				pfechahoy date)
RETURNING CHAR(5);


DEFINE cod_ret         char(5);
DEFINE cod_ret1         char(5);
DEFINE cod_ret2         char(5);
DEFINE cod_ret3         char(5);
DEFINE cod_ret4         char(5);

DEFINE sql_err         integer;
DEFINE v_fechahoy      date;

-- SET DEBUG FILE TO "ugenera_edocuenta.out";
-- TRACE ON;

  BEGIN


  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
        END IF
   END EXCEPTION;

   LET cod_ret = "000";

    EXECUTE PROCEDURE informix.uencabezadolayout_edocuenta(pempresa,pnum_credito,pfechahoy)  INTO cod_ret1;
    IF cod_ret =  "000"  THEN
    	LET cod_ret =cod_ret1;
    END IF
	EXECUTE PROCEDURE informix.uencabezado2layout_edocuenta(pempresa,pnum_credito,pfechahoy) INTO cod_ret2;
    IF cod_ret =  "000"  THEN
    	LET cod_ret =cod_ret2;
    END IF
	EXECUTE PROCEDURE informix.udetallelayout_edocuenta(pempresa,pnum_credito,pfechahoy) INTO cod_ret3;
    IF cod_ret =  "000"  THEN
    	LET cod_ret =cod_ret3;
    END IF
	EXECUTE PROCEDURE informix.upielayout_edocuenta(pempresa,pnum_credito,pfechahoy) INTO cod_ret4;
    IF cod_ret =  "000"  THEN
    	LET cod_ret =cod_ret4;
    END IF

  END;

  RETURN cod_ret;

END PROCEDURE ;