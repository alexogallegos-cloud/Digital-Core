CREATE PROCEDURE "informix".sp_porta_cal_ult_dia_hab(p_empresa char(3),p_fecha date)
    RETURNING  CHAR(5),
               DATE;

    DEFINE vsqlerr        INTEGER;
    DEFINE iIsamErr       SMALLINT;
    DEFINE cErrorInfo     CHAR(80);
    DEFINE vcodret        CHAR(5);
    DEFINE vErrorInfo     CHAR(80);
    DEFINE i,j            INTEGER;
    DEFINE siFeriado      INTEGER;
    DEFINE v_Noferiado    INTEGER;
    DEFINE vFechaActual   DATE;

    LET vsqlerr           = 0; 
    LET iIsamErr          = 0;
    LET cErrorInfo        = "";
    LET vcodret           = "00000";
    LET vErrorInfo        = "INICIO DEL PROCESO";
    LET vFechaActual      = '';
    LET i                 = 0;
    LET j                 = 0;	
    LET v_Noferiado       = 0; 

    BEGIN
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	   IF  vsqlerr != 0 THEN
	       SET DEBUG FILE TO "/resplogifx/conciliachq/sp_porta_cal_ult_dia_hab.txt";
		   TRACE ON;
		   LET vcodret    = vsqlerr;
           LET vErrorInfo = cErrorInfo;
           RETURN vcodret,vFechaActual;
	   END IF;
    END EXCEPTION;
	
    --SET DEBUG FILE TO '/RESPALDOSNEW/rsv/portabilidad/_____sp_porta_cal_ult_dia_hab.txt';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	WHILE v_Noferiado = 0 
	LET vFechaActual  = p_fecha - j;
	LET siFeriado     = 0;

	IF (WEEKDAY(vFechaActual) >= 1 AND WEEKDAY(vFechaActual) <= 5) THEN
        SELECT COUNT(*) 
	    INTO   siFeriado       
	    FROM   bdinteg:si_feriado
	    WHERE  fecha = vFechaActual;
	   
	    
		IF siFeriado IS NULL OR siFeriado = 0 THEN
	       LET v_Noferiado = 1;
	    ELSE 
	       LET v_Noferiado = 0;
	    END IF;
	ELSE 
	    LET v_Noferiado = 0;
    END IF; 
	
	LET j = j + 1;
    END WHILE

RETURN  vcodret,vFechaActual;
END; 
END PROCEDURE;