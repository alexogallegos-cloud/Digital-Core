CREATE PROCEDURE "informix".sp_obtienecompingresos_mc()
       RETURNING CHAR(60) as Comprobantes;

DEFINE iSqlErr		INTEGER;
DEFINE sCodRet          CHAR(5);
DEFINE sErrProc		CHAR(5);
DEFINE sComprobantes     CHAR(60);
--DEFINE sNombreEmpleado    CHAR(60);
--DEFINE sNombreEmp         CHAR(25);
--DEFINE sApellPEmp         CHAR(15);
--DEFINE sApellMEmp         CHAR(15);

LET iSqlErr          =0;
--LET sCodRet          ='00000';
LET sErrProc         ='';
LET sComprobantes     ='';
--LET sNombreEmpleado  ='';
--LET sNombreEmp        = '';
--LET sApellPEmp    = '';
--LET sApellMEmp = '';


BEGIN
	ON EXCEPTION SET iSqlErr

	IF iSqlErr <> 0 THEN
		RETURN sComprobantes;
        END IF;

	END EXCEPTION;

-- SET DEBUG FILE TO '/tmp/anj/movil/sp_cons_folio_movil2.sql';
-- TRACE ON;

        FOREACH
                        SELECT nombre_documento INTO sComprobantes
                        FROM bdisolic:ss_comp_ingresos_cte 
                       
        
                        RETURN NVL(sComprobantes,'') WITH RESUME;
        END FOREACH 

        
END
END PROCEDURE;