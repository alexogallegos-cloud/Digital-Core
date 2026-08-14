CREATE PROCEDURE "informix".spei_validafecha() 

RETURNING CHAR(5);
    
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    
    DEFINE wfecha_hoy       CHAR(10);
    DEFINE wfecha_spei      CHAR(10);
    DEFINE wfecha_habil     CHAR(10);
    DEFINE wvchrvalor       CHAR(1);
	DEFINE iFlagDiaLabo		INTEGER;
	DEFINE cEmpresa			CHAR(3);

    LET sql_err  = 0;
    LET isam_err = 0;
    LET vcodret1 = "000";
    LET vcodret2 = "000";
    
    LET wfecha_hoy   = '';
    LET wfecha_spei  = '';
    LET wfecha_habil = '';
    LET wvchrvalor   = '';
	LET iFlagDiaLabo =  0;
    LET cEmpresa	 = '001';

    --- SET DEBUG FILE TO "/tmp/spei_validafecha.out";
    --- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
     
    LET wfecha_hoy = CURRENT::DATE; 

     -- VERIFICA DIA NO LABORABLE
    SELECT COUNT(*)
		INTO iFlagDiaLabo
		FROM bdinteg:'informix'.si_feriado
	  WHERE empresa = cEmpresa
		AND laborable = 'N'
		AND fecha = wfecha_hoy;

	IF  iFlagDiaLabo = 0 THEN
        LET wvchrvalor = 0;
    ELSE   
        LET wvchrvalor = 1;
    END IF;
    
    UPDATE "informix".tblparametros 
       SET vchrvalor = wvchrvalor
     WHERE vchrcveparametro = 'BLOQUEO_A_USUARIOS'; 
    
    RETURN vcodret1;
    
    END;
    
END PROCEDURE;