CREATE PROCEDURE "informix".sp_borrar_sc_docret
( 
)
RETURNING 
	CHAR(5), 
	CHAR(5), 
	CHAR(50), 
	INTEGER;
    
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vempieza         SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vCuenta CHAR(20);
    DEFINE vmin_serial      INTEGER;
    DEFINE vmax_serial      INTEGER;
    
    LET vcodret1     = '000';
    LET vcodret2     = '000';
    LET vcodret3     = 'PROCESO REALIZADO SATISFACTORIAMENTE';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vempieza     = -1;
    LET ven_transacc = 0; 
    
    LET vCuenta = "";
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_borrar_sc_docret.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_borrar_sc_docret.out";
    --- TRACE ON;
    
    set optimization high;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH cursor_borra WITH HOLD FOR
		SELECT UNIQUE cuenta
		INTO vCuenta
		FROM sc_docret
		WHERE siglas IN ('SC','SD')
		AND transacc IN ('0250','6250')
           
        IF vempieza = -1 THEN
            LET vempieza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        DELETE FROM sc_docret 
        WHERE cuenta = vCuenta
		AND siglas IN ('SC','SD')
		AND transacc IN ('0250','6250');
         
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;
        
        IF vcontador2 >= 5000 THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        COMMIT WORK;
        LET vcontador2 = 0;
        LET ven_transacc = 0;
    END IF;
       
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1;

END PROCEDURE;