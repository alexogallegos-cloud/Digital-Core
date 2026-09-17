CREATE PROCEDURE "informix".sp_consulta_datos_sucursal_numero (p_numeroSuc CHAR(4), p_sNumeroEmpresa CHAR(3))

     RETURNING	CHAR(4) AS sucursal, CHAR(40) AS nombreSucursal, CHAR(30) AS nombreEstado, CHAR(60) AS nombreCiudad;

	--definicion de variables--	    
	DEFINE resultado_numeroSucursal 	CHAR(4);
    DEFINE resultado_nombreSucursal		CHAR(40);
    DEFINE resultado_nombreEstado		CHAR(30);
    DEFINE resultado_nombreCiudad		CHAR(60);

    DEFINE iSqlErr                     	INTEGER;
		
     -- InicializaciÃ³n de las variables.
	LET resultado_numeroSucursal = '';
	LET resultado_nombreSucursal = '';
	LET resultado_nombreEstado = '';
	LET resultado_nombreCiudad = '';

	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
				
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    	LET resultado_numeroSucursal = '';
						LET resultado_nombreSucursal = '';
						LET resultado_nombreEstado = '';
						LET resultado_nombreCiudad = '';
                    RETURN resultado_numeroSucursal, resultado_nombreSucursal, resultado_nombreEstado, resultado_nombreCiudad;
                END IF;
        END EXCEPTION;
      
			SELECT DISTINCT si_ptf.id_ptf, si_sucursales.nombre, si_estados.nombre, loc.desc_municipio as nombre
	        INTO resultado_numeroSucursal, resultado_nombreSucursal, resultado_nombreEstado, resultado_nombreCiudad
			FROM bdinteg:si_ptf
			JOIN bdinteg:si_sucursales ON (si_ptf.id_ptf = si_sucursales.sucursal AND si_ptf.tipo = si_sucursales.tipo)
			JOIN bdinteg:si_estados ON bdinteg:si_estados.estado = bdinteg:si_ptf.cve_estado                
            LEFT OUTER JOIN bdinteg:si_localidades loc ON ( loc.id > 0 AND 
                                                          loc.cp = loc.cp AND
                                                          loc.cve_estado = si_ptf.cve_estado AND 
                                                          loc.cve_mun = si_ptf.cve_mun AND
                                                          loc.cve_localidad_cnbv = si_ptf.cve_localidad AND 
                                                          loc.cve_col = si_ptf.cve_col )
            WHERE si_sucursales.empresa = p_sNumeroEmpresa
                AND si_ptf.id_ptf = p_numeroSuc AND  si_ptf.tipo <> 'C';
            /*SELECT DISTINCT sucursal, si_sucursales.nombre, si_estados.nombre, si_ciudades.nombre
	        INTO resultado_numeroSucursal, resultado_nombreSucursal, resultado_nombreEstado, resultado_nombreCiudad
			FROM (bdinteg:si_sucursales JOIN bdinteg:si_ciudades ON bdinteg:si_ciudades.ciudad = bdinteg:si_sucursales.ciudad
				AND  bdinteg:si_ciudades.estado = bdinteg:si_sucursales.estado 
				AND  bdinteg:si_ciudades.pais = bdinteg:si_sucursales.pais) JOIN bdinteg:si_estados 
				ON bdinteg:si_estados.estado = bdinteg:si_sucursales.estado                
            WHERE empresa = p_sNumeroEmpresa
                AND sucursal = p_numeroSuc;*/
	        RETURN resultado_numeroSucursal, resultado_nombreSucursal, resultado_nombreEstado, resultado_nombreCiudad WITH RESUME;
	END
END PROCEDURE;