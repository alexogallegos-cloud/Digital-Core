CREATE PROCEDURE "informix".speicentral() 

RETURNING CHAR(5);
    
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcodret1         CHAR(5);
	DEFINE vexiste          INTEGER;
	
      
    DEFINE vcountresult     INTEGER;
   

    LET sql_err  = 0;
    LET isam_err = 0;
    LET vcodret1 = "000";
	LET vexiste  = 0;
       
	
	-- SET DEBUG FILE TO "/ifxsif01/scripts/speicentral.out";
     
	-- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
     
	 
	 SELECT COUNT(*) 
	  INTO vexiste
	  FROM bdinteg:si_feriado
	 WHERE
	 fecha::DATE = CURRENT::DATE;
	 
	 IF vexiste = 0 THEN
        SELECT count(*) 
			INTO vcountresult
			FROM tblpago
		   WHERE dtfechavalor = today;
   
		IF vcountresult = 0 THEN
			LET vcodret1 = '00000';
		ELSE
			--LET vcodret1 = '11111';
			LET vcodret1 = '00000'; 
		END IF;
	 
	 ELSE
	 
		LET vcodret1 = '22222';
	 
	 END IF
       
    RETURN vcodret1;
    
    END;
    
END PROCEDURE;