CREATE PROCEDURE "informix".sp_cancela_solportab()
    --CODIGO RETORNO
    RETURNING CHAR(3);  
	
	DEFINE sql_err		INTEGER;
    DEFINE vcodret1     CHAR(5);
    DEFINE dtFechaHoy	DATE;
    DEFINE dtFechaVen	DATE;
	DEFINE vFechacal	CHAR(10);
	
	LET vcodret1 	= "000";
    LET sql_err  	= 0;
	LET dtFechaHoy  = DATE(1);
	LET dtFechaVen  = DATE(1);
	LET vFechacal 	= "";

BEGIN
	
	ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            Let vcodret1 = sql_err;    
            RETURN vcodret1;
        END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/vamilan/sp_cancela_solportab.out";
	--TRACE ON;
  
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy
	INTO dtFechaHoy
	FROM bdicheq:"informix".sc_fechas
	WHERE empresa = '001';

    LET dtFechaVen = dtFechaHoy - 6 UNITS DAY;     
    LET vFechacal = TO_CHAR(dtFechaVen, '%Y%m%d');  
    

	UPDATE {+ INDEX(sc_portacec_solicitud idx_sc_portacec_solicitud)} bdicheq:"informix".sc_portacec_solicitud set estatus_portabilidad=6, clave_sentido=0 , fecha_solca_portabilidad= TO_CHAR(dtFechaHoy, '%Y%m%d')
		WHERE fecha_solicitud < vFechacal and estatus_portabilidad=2 and clave_origen in (1, 2);
		
		
		
    RETURN vcodret1;

END;
END PROCEDURE
;