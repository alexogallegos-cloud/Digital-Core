CREATE PROCEDURE "informix".sp_consultasucursales(p_skip INT, p_sNumeroEmpresa CHAR(3))

     RETURNING	CHAR(30) AS numeroSucursal, CHAR(30) AS nombreSucursal;

	--definicion de variables--	    
	DEFINE resultado_numeroSucursal 	CHAR(30);
    	DEFINE resultado_nombreSucursal		CHAR(30);
   	DEFINE iSqlErr                      	INTEGER;
		
     -- InicializaciÃ³n de las variables.
	LET resultado_numeroSucursal = '';
	LET resultado_nombreSucursal = '';

    SET ISOLATION TO dirty READ;
				
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_numeroSucursal = '';
                    LET resultado_nombreSucursal = '';
                    RETURN resultado_numeroSucursal, resultado_nombreSucursal;
                END IF;
        END EXCEPTION;

		FOREACH       
	     	SELECT SKIP p_skip DISTINCT sucursal, nombre
	          INTO resultado_numeroSucursal, resultado_nombreSucursal
	          FROM bdinteg:si_sucursales
              WHERE bdinteg:si_sucursales.empresa = p_sNumeroEmpresa
              ORDER BY sucursal
	          RETURN resultado_numeroSucursal, resultado_nombreSucursal WITH RESUME;
		END FOREACH;
	END
END PROCEDURE;