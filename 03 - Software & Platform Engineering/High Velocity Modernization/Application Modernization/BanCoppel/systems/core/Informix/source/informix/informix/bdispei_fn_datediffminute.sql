CREATE FUNCTION "informix".fn_datediffminute(pFecha1 DATETIME YEAR to SECOND, pFecha2 DATETIME YEAR to SECOND, pTipo INTEGER)
	RETURNING
            integer; -- Resp
	
	DEFINE vDias		integer;
	DEFINE vHorasf1		integer;
	DEFINE vHorasf2		integer;
	DEFINE vMinutosf1 	integer;
	DEFINE vMinutosf2 	integer;
	DEFINE vSegundosf1	integer;
	DEFINE vSegundosf2	integer;
    DEFINE vResultadof1	integer;
	DEFINE vResultadof2	integer;
    DEFINE vDifMins		integer; 

	LET vDias			=0;
	LET vHorasf1		=0;
	LET vHorasf2		=0;
	LET vMinutosf1		=0;
	LET vMinutosf2		=0;
	LET vSegundosf1		=0;
	LET vSegundosf2		=0;
    LET vResultadof1	=0;
	LET vResultadof2	=0;
    LET vDifMins		=0;

BEGIN
	
    --LET vDias 		= day(pFecha1) - day(pFecha2);
	LET vHorasf1 	= substr(extend(pFecha1, hour to second),1,2)::integer * 3600;
	LET	vHorasf2 	= substr(extend(pFecha2, hour to second),1,2)::integer * 3600;
	LET vMinutosf1 	= substr(extend(pFecha1, hour to second),4,2)::integer * 60;
	LET vMinutosf2 	= substr(extend(pFecha2, hour to second),4,2)::integer * 60;
    LET vSegundosf1 = substr(extend(pFecha1, hour to second),7,2)::integer;
	LET vSegundosf2 = substr(extend(pFecha2, hour to second),7,2)::integer;

	LET vResultadof1 = vHorasf1 + vMinutosf1 + vSegundosf1;
	LET vResultadof2 = vHorasf2 + vMinutosf2 + vSegundosf2;

	IF (pTipo = 16) OR (pTipo = 18) THEN
		LET vDifMins = ROUND((((vResultadof1 - vResultadof2 ) - 30 ) / 60),0);
	ELIF pTipo = 10 THEN
		LET vDifMins = ROUND((((vResultadof1 - vResultadof2 ) - 5 ) / 60),0);
	ELSE
		LET vDifMins=0;
	END IF;
     	
    RETURN vDifMins;

END;
END FUNCTION
;