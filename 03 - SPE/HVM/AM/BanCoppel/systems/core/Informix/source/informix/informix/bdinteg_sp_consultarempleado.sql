CREATE PROCEDURE "informix".sp_consultarempleado (p_sNumEmpleado CHAR(8))
	RETURNING 	CHAR(3) AS empresa,				
				CHAR(45) AS nombre,
				CHAR(4) AS sucursal,
				CHAR (3) AS puesto,
				CHAR(20) AS nombramiento,
				CHAR (10) AS asistente,
				CHAR (40) AS password;

	DEFINE v_sEmpresa		CHAR(3);
	DEFINE v_sRazon_social	CHAR(50);
	DEFINE v_sNombre		CHAR(45);
	DEFINE v_sSucursal		CHAR(4);
	DEFINE v_sPuesto		CHAR(3);
	DEFINE v_sNombramiento	CHAR(20);
	DEFINE v_sAsistente		CHAR(10);
	DEFINE v_sPassword		CHAR(40);

	--------------------------------------------------------------------------
	-- Creado por Erick Zamora 17/12/2008
	--SET DEBUG FILE TO "/tmp/spauconsultarempleado.out";
	--TRACE ON;
	--------------------------------------------------------------------------
	
	BEGIN		
		FOREACH
			SELECT ej.empresa, ej.nombre, ej.sucursal, ej.puesto, ej.nombramiento, ej.asistente, ej.password
			INTO v_sEmpresa, v_sNombre, v_sSucursal, v_sPuesto, v_sNombramiento, v_sAsistente, v_sPassword
			FROM bdinteg:si_ejecut ej 
			WHERE ejecutivo = NVL(p_sNumEmpleado,ejecutivo)  
			ORDER BY nombre									
			
			RETURN v_sEmpresa, v_sNombre, v_sSucursal, v_sPuesto, v_sNombramiento, v_sAsistente, v_sPassword WITH RESUME;
		END FOREACH
	END
END PROCEDURE;