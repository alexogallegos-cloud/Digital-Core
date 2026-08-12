CREATE PROCEDURE "informix".sp_borra_operaciones( pfecha DATE )
RETURNING CHAR(5), INTEGER;

    DEFINE vcodret1        	 	CHAR(5);
    DEFINE vcodret2         	CHAR(5);
	DEFINE vcodret3         	CHAR(50);
    DEFINE sql_err          	INTEGER;
    DEFINE isam_err         	INTEGER;
	DEFINE desc_err         	CHAR(50);
    DEFINE vContador1           INTEGER;
    DEFINE vContador2           INTEGER;
    DEFINE vComienza            SMALLINT;
    DEFINE vAbierto             CHAR(1);
	DEFINE wvchrclaverastreo	VARCHAR(30,0);
    
    LET vcodret1           = '000';
    LET vcodret2           = '000';
    LET sql_err	           = 0;
    LET isam_err           = 0;
	LET desc_err           = '';
    LET vContador1         = 0;
    LET vContador2         = 0;
    LET vComienza          = -1;
    LET vAbierto           = '0';
	LET wvchrclaverastreo  = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/sp_borra_operaciones.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
			LET vcodret3 = desc_err;
			IF vAbierto = '1' THEN
                ROLLBACK WORK;
            END IF;
			RETURN vcodret1, vcontador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/spei/sp_borra_operaciones.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD
        SELECT {+INDEX(tblhistpago idx_hfv)}
			   vchrclaverastreo
          INTO wvchrclaverastreo
          FROM tblhistpago
         WHERE dtfechavalor = pfecha
           
        IF vComienza = -1 THEN
            LET vComienza = 0;
            BEGIN WORK;
            LET vAbierto = '1';
        END IF;
        
        DELETE FROM tblhistpago 
         WHERE dtfechavalor = pfecha
		   AND vchrclaverastreo = wvchrclaverastreo;
         
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;
        
        IF vcontador2 >= 100 THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
    END FOREACH;
	
	IF vAbierto = '1' THEN
        COMMIT WORK;
        LET vAbierto = '0';
    END IF;

    END;

    RETURN vcodret1, vcontador1;

END PROCEDURE;