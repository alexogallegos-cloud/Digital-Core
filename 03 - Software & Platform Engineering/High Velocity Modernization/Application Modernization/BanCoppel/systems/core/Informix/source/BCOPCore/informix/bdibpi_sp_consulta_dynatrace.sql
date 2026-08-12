CREATE PROCEDURE "informix".sp_consulta_dynatrace ()
RETURNING CHAR(5);
    DEFINE codRet CHAR(5);
    DEFINE viSqlErr INTEGER;
    DEFINE fechaMonitoreo CHAR(60);

    LET codRet = '00000';
    LET viSqlErr = 0;
    LET fechaMonitoreo = CURRENT;
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    BEGIN
        ON EXCEPTION SET viSqlErr
            IF viSqlErr <> 0 then
                LET codRet = viSqlErr;
                RETURN codRet;
            END IF;	
        END EXCEPTION;
	--SET DEBUG FILE TO "/informix/JuanRivera/Traces/sp_consulta_dynatrace.out";
	--TRACE ON;
-- cambiar que consulta a la bdibpi:bpi_param
	SELECT f_fin INTO fechaMonitoreo FROM bdibpi:"informix".bpi_param where id_param ='24';
        IF fechaMonitoreo  <> '' AND fechaMonitoreo <> 'NULL' THEN
		
            UPDATE bdibpi:"informix".bpi_param SET f_fin = CURRENT where id_param ='24';

        END IF;


        RETURN codRet;
    END;
END PROCEDURE
;