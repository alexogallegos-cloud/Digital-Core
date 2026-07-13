CREATE PROCEDURE "informix".sp_consulta_dynatrace ()
RETURNING CHAR(5);
    DEFINE codRet CHAR(5);
    DEFINE viSqlErr INTEGER;
    DEFINE fechaMonitoreo CHAR(50);

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


        SELECT fecha INTO fechaMonitoreo FROM bdibei:"informix".bei_monitoreo_dynatrace;
        IF fechaMonitoreo  <> '' AND fechaMonitoreo <> 'NULL' THEN
            UPDATE bdibei:"informix".bei_monitoreo_dynatrace SET fecha = CURRENT;
        ELSE
            INSERT INTO bdibei:"informix".bei_monitoreo_dynatrace(fecha)
            VALUES(CURRENT);
        END IF;


        RETURN codRet;
    END;
END PROCEDURE
;