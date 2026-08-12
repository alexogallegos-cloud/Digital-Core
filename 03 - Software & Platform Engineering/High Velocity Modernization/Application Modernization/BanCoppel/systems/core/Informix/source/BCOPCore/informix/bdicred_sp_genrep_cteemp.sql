CREATE PROCEDURE "informix".sp_genrep_cteemp()
RETURNING CHAR(5) AS cod_ret;

--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************
DEFINE CodRet		CHAR(5);
DEFINE sql_err		INTEGER;
DEFINE isam_err		INTEGER;
DEFINE CMensaje    CHAR(80);
DEFINE vsql			CHAR(2000);
DEFINE v_DiaActual	INTEGER;
DEFINE v_MesActual	INTEGER;
DEFINE v_AnioActual	INTEGER;
DEFINE v_TotalEmpActivos INTEGER;
DEFINE v_FechaHoy	DATE;
--*****************************************************
--- Inicializar variables
--*****************************************************
LET CodRet		= '';
LET sql_err		= 0 ;
LET isam_err	= 0 ;
LET CMensaje	= '';

	
--SET DEBUG FILE TO "/aplicacion/ifxsif01/Control-M/sp_genrep_cteemp.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET sql_err,isam_err,CMensaje
		LET CodRet = sql_err;
		RETURN CodRet;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
      
	--- Se obtiene la fecha actual del proceso
	SELECT 	DAY(fecha_hoy),		-- Dia actual
			MONTH(fecha_hoy),	-- Mes actual
			YEAR(fecha_hoy),	-- Año actual
			fecha_hoy			-- Fecha actual
	INTO	v_DiaActual,
			v_MesActual,
			v_AnioActual,
			v_FechaHoy 
	FROM	bdicred:"informix".sd_fechas
	WHERE	empresa = '001';

--- se valida si hay campañas activas en el mes actual
	SELECT COUNT(1)
	into v_TotalEmpActivos														-- Variable para contador de Campañas activas
	FROM bdinteg:"informix".si_rel_cte_empleado
	WHERE empresa = '001' AND status_emp = '1'; 

	--- Se valida si hay empleados activas
	IF	(v_TotalEmpActivos <> 0) THEN			
	
			/*
			-- Creacion de tabla que se va a usar temporalmente
			CREATE TABLE bdicred:"informix".sd_cte_empleado(                             
				numcte_banco	VARCHAR(10),   
				num_empleado	VARCHAR(10));

			select numcte_banco, num_empleado
			FROM bdinteg:"informix".si_rel_cte_empleado
			WHERE empresa = '001' AND status_emp = '1'
			INTO bdicred:"informix".sd_cte_empleado  WITH NO LOG;

			-- Generacion del reporte de empleados activos (RelEmpleadosTDCGC_AAAAMMDD.txt)
			let vsql = '';
			let vsql = 'echo "Empleado|Cliente">/resplogifx/Credito_GC/RelEmpleadosTDCGC_'||year(v_FechaHoy)||LPAD (MONTH(v_FechaHoy),2,"0")||day(v_FechaHoy)||'.txt';  
			system vsql;  
			*/
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/Credito_GC/QA_BajaArchivo.unl select distinct(num_empleado) from bdinteg:"informix".si_rel_cte_empleado where empresa = "001" AND status_emp = "1";">/resplogifx/Credito_GC/QA_BajaScript.sql';      
			system vsql;
					
			let vsql='chmod a+rwx /resplogifx/Credito_GC/QA_BajaScript.sql';
			System vsql;
					
			let vsql = '';
			let vsql= 'dbaccess bdicred /resplogifx/Credito_GC/QA_BajaScript.sql';
			system vsql;
					
			let vsql = vsql;
			let vsql ='rm /resplogifx/Credito_GC/QA_BajaScript.sql';
					
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/Credito_GC/QA_BajaArchivo.unl >>/resplogifx/Credito_GC/RelEmpleadosTDCGC_"||LPAD(MONTH(v_FechaHoy),2,"0")||LPAD(day(v_FechaHoy),2,"0")||year(v_FechaHoy)||'.txt';
			
			system vsql;
			let vsql ='rm /resplogifx/Credito_GC/QA_BajaArchivo.unl';
			system vsql; 
					
			-- Se elimina tabla Temporal
			--DROP TABLE bdicred:"informix".sd_cte_empleado; 
			
		ELSE
			--Generacion de Reporte y Resumen de Campañas de Recompensa Inmediata sin información a reportar
			let vsql = '';
			let vsql = 'echo " <<< No hay información a reportar >>> ">/resplogifx/Credito_GC/RelEmpleadosTDCGC_'||LPAD(MONTH(v_FechaHoy),2,"0")||LPAD(day(v_FechaHoy),2,"0")||year(v_FechaHoy)||'.txt';
			system vsql;
	END IF;	
	
	LET CodRet = '00000'; --> Proceso concluyo exitosamente
	LET CMensaje = 'El archivo se genero correctamente';
	END;
	
	RETURN CodRet;

END PROCEDURE;