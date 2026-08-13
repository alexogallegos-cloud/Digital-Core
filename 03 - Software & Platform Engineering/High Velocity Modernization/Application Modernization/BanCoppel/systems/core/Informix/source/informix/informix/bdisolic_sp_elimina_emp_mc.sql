CREATE PROCEDURE "informix".sp_elimina_emp_mc(sNumEmpleado CHAR(8))

DEFINE iSqlErr		INTEGER;
DEFINE sCodRet          CHAR(5);
DEFINE sErrProc		CHAR(5);

LET iSqlErr          =0;
LET sCodRet          ='00000';
LET sErrProc         ='';

BEGIN
	ON EXCEPTION SET iSqlErr

	IF iSqlErr <> 0 THEN
		RETURN;
        END IF;

	END EXCEPTION;

-- SET DEBUG FILE TO '/tmp/anj/movil/sp_cons_folio_movil2.sql';
-- TRACE ON;

    DELETE FROM bdisolic:ss_emp_revingresos_mc where num_empleado = sNumEmpleado;
        
END
END PROCEDURE;