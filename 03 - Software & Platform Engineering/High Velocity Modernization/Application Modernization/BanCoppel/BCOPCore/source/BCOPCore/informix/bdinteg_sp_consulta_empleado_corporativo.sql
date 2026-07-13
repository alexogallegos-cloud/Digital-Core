CREATE PROCEDURE "informix".sp_consulta_empleado_corporativo(p_numeroEmpleado CHAR(10), p_nombreEmpleado CHAR(50), p_nEmpresa CHAR(4), p_skip INT)

     RETURNING	CHAR(50) AS nombre, CHAR(10) AS numero, CHAR(5) AS numeroSucursal, CHAR(40) AS nombreSucursal, CHAR(20) AS puesto, CHAR(40) AS password, DATE AS fechaBaja;

	--definicion de variables--	    
	DEFINE resultado_nombre             CHAR(50);
    	DEFINE resultado_numero             CHAR(10);
    	DEFINE resultado_numeroSucursal     CHAR(5);
    	DEFINE resultado_nombreSucursal     CHAR(40);
    	DEFINE resultado_puesto             CHAR(20);
    	DEFINE resultado_password           CHAR(40);
    	DEFINE resultado_fechaBaja          DATE;
    	DEFINE iSqlErr                      INTEGER;
		
     -- InicializaciÃ³n de las variables.
	LET resultado_nombre = '';
	LET resultado_numero = '';
    	LET resultado_numeroSucursal = '';
    	LET resultado_nombreSucursal = '';
    	LET resultado_puesto = '';
    	LET resultado_password = '';
    	LET resultado_fechaBaja = '';

    SET ISOLATION TO DIRTY READ;
				
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_nombre = 'dd';
                    LET resultado_numero = '';
                    LET resultado_numeroSucursal = '';
                    LET resultado_nombreSucursal = '';
                    LET resultado_puesto = '';
                    LET resultado_password = '';
                    LET resultado_fechaBaja = '';
                    RETURN resultado_nombre, resultado_numero, resultado_numeroSucursal, resultado_nombreSucursal, resultado_puesto, resultado_password, resultado_fechaBaja;
                END IF;
        END EXCEPTION;

        IF p_nombreEmpleado IS NOT NULL AND p_nombreEmpleado <> '' THEN
            FOREACH
                SELECT SKIP p_skip DISTINCT si_ejecut.nombre, si_ejecut.ejecutivo, si_ejecut.sucursal, si_sucursales.nombre, si_ejecut.nombramiento, si_ejecut.password, si_ejecut.vigencia
                INTO resultado_nombre, resultado_numero, resultado_numeroSucursal, resultado_nombreSucursal, resultado_puesto, resultado_password, resultado_fechaBaja
                FROM bdinteg:si_ejecut
                    LEFT JOIN si_sucursales 
                        ON (si_sucursales.sucursal = si_ejecut.sucursal)
                WHERE si_sucursales.empresa = p_nEmpresa
                    AND si_ejecut.nombre LIKE ('%' || TRIM(p_nombreEmpleado) || '%')
                RETURN resultado_nombre, resultado_numero, resultado_numeroSucursal, resultado_nombreSucursal, resultado_puesto, resultado_password, resultado_fechaBaja WITH RESUME;
            END FOREACH;
        ELSE
            SELECT SKIP p_skip DISTINCT si_ejecut.nombre, si_ejecut.ejecutivo, si_ejecut.sucursal, si_sucursales.nombre, si_ejecut.nombramiento, si_ejecut.password, si_ejecut.vigencia
            INTO resultado_nombre, resultado_numero, resultado_numeroSucursal, resultado_nombreSucursal, resultado_puesto, resultado_password, resultado_fechaBaja
            FROM bdinteg:si_ejecut
                LEFT JOIN si_sucursales ON (si_sucursales.empresa = p_nEmpresa 
                            AND si_sucursales.sucursal = si_ejecut.sucursal)
            WHERE si_sucursales.empresa = p_nEmpresa
               AND si_ejecut.ejecutivo = p_numeroEmpleado;
            RETURN resultado_nombre, resultado_numero, resultado_numeroSucursal, resultado_nombreSucursal, resultado_puesto, resultado_password, resultado_fechaBaja;
        END IF;
	END
END PROCEDURE;