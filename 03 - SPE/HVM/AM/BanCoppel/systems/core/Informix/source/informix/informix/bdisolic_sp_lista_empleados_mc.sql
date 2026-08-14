CREATE PROCEDURE "informix".sp_lista_empleados_mc()
       RETURNING CHAR(60) as Nombre_Empleado;

DEFINE iSqlErr		INTEGER;
DEFINE sCodRet          CHAR(5);
DEFINE sErrProc		CHAR(5);
DEFINE sNombreEmpleado    CHAR(60);
DEFINE sNombreEmp         CHAR(25);
DEFINE sApellPEmp         CHAR(15);
DEFINE sApellMEmp         CHAR(15);

LET iSqlErr          =0;
--LET sCodRet          ='00000';
LET sErrProc         ='';
LET sNombreEmpleado  ='';
LET sNombreEmp        = '';
LET sApellPEmp    = '';
LET sApellMEmp = '';


BEGIN
	ON EXCEPTION SET iSqlErr

	IF iSqlErr <> 0 THEN
		RETURN sNombreEmpleado;
        END IF;

	END EXCEPTION;

-- SET DEBUG FILE TO '/tmp/anj/movil/sp_cons_folio_movil2.sql';
-- TRACE ON;

        FOREACH
                        SELECT TRIM(nombre_empleado) ||' '|| TRIM(apellidop_empleado) ||' '|| TRIM(apellidom_empleado) INTO sNombreEmpleado
                        FROM bdisolic:ss_emp_revingresos_mc 
                       
        
                        RETURN NVL(sNombreEmpleado,'') WITH RESUME;
        END FOREACH 

        
END
END PROCEDURE;