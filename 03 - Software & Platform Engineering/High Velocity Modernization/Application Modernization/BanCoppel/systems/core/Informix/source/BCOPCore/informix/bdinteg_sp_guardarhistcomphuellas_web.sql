CREATE PROCEDURE "informix".sp_guardarhistcomphuellas_web(p_sNoEmpleado CHAR(8), p_sSucursal CHAR(4), p_sNoCteBancoppel CHAR(20), p_sTipoProducto CHAR(4))
RETURNING	 VARCHAR(5) --Codigo de Retorno

	DEFINE iSqlErr			INTEGER;

	-----------------------------------------------------------------------------------------------------
	-- AUTOR: Erick Zamora
	-- FECHA: 13-03-2009
	-- Guarda en la tabla bdinteg:si_histcomhuellas los datos los empleados que hayan 
	--	validado un cliente con su propia huella
	-- SET DEBUG FILE TO "/tmp/sp_guardarhistcomphuellas.out;
	-- TRACE ON;
	------------------------------------------------------------------------------------------------------
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		INSERT INTO bdinteg:si_histcomphuellas VALUES(p_sNoEmpleado, p_sSucursal, CURRENT, LPAD(TRIM(p_sNoCteBancoppel),9,'0'), p_sTipoProducto);
		RETURN '00000';
	END
END PROCEDURE;