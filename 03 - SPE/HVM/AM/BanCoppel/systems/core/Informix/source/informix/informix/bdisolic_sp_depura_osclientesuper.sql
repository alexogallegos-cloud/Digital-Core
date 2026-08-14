CREATE PROCEDURE "informix".sp_depura_osclientesuper()
RETURNING CHAR(6);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE cCodRet      		CHAR(6); 
DEFINE vNumSOL     			VARCHAR(20,1);
DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr     		INTEGER;
DEFINE p_fecha_fin			DATE;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET cCodRet      			= '000000';
LET iSqlErr      			= 0;
LET iIsamErr     			= 0;
LET vNumSOL     			= '';
LET p_fecha_fin				= DATE(1);

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

---SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION TO DIRTY READ;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;		
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

--  SET DEBUG FILE TO '/respaldos/sp_depura_osclientesuper.out';
--  TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	

	SELECT {+INDEX(bdicred:"informix".sd_fechas)} 
	last_day (ADD_MONTHS (fecha_hoy, -4))
	INTO p_fecha_fin
	FROM  bdicred:"informix".sd_fechas
	WHERE empresa = '001';

	------ Proceso de respaldo y depuraciÃÂ³n de la tabla ss_osclientesupervisar	
	
    FOREACH WITH HOLD

		SELECT {+INDEX (bdisolic:ss_osclientesupervisar)} num_solicitud
		INTO vNumSOL
		FROM bdisolic:ss_osclientesupervisar
		WHERE fechasolicitud <= p_fecha_fin	

        BEGIN WORK;

            insert into bdisolic:"informix".ss_osclientesupervisar_old
            select * from bdisolic:"informix".ss_osclientesupervisar
            where num_solicitud = vNumSOL;

            DELETE FROM bdisolic:"informix".ss_osclientesupervisar
            where num_solicitud = vNumSOL;

        COMMIT WORK;  

    END FOREACH;

	------ Proceso de depuraciÃÂ³n de la tabla ss_os_errores	
	LET vNumSOL = '';
	
	SELECT {+INDEX(bdicred:"informix".sd_fechas)} 
	last_day (ADD_MONTHS (fecha_hoy, -1))
	INTO p_fecha_fin
	FROM  bdicred:"informix".sd_fechas
	WHERE empresa = '001';	
	
    FOREACH WITH HOLD

		SELECT {+INDEX (bdisolic:ss_os_errores)} num_solicitud
		INTO vNumSOL
		FROM bdisolic:ss_os_errores
		WHERE fechasolicitud <= p_fecha_fin	

        BEGIN WORK;

            DELETE FROM bdisolic:"informix".ss_os_errores
            where num_solicitud = vNumSOL;

        COMMIT WORK;  

    END FOREACH;	

    RETURN cCodRet;

    END
END PROCEDURE


