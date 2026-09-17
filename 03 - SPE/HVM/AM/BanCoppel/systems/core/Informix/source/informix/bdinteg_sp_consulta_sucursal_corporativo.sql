CREATE PROCEDURE "informix".sp_consulta_sucursal_corporativo(p_numeroPais CHAR(4), p_numeroEstado CHAR(4), p_numeroSucursal CHAR(4), p_nombreSucursal CHAR(40), p_nEmpresa CHAR(4), p_skip INT)

     RETURNING	CHAR(5) AS numeroSucursal, CHAR(40) AS nombreSucursal, CHAR(40) AS direccion, CHAR(15) AS telefono, CHAR(30) AS nombreEstado, CHAR(40) AS nombreGerente, CHAR(10) AS numeroEmpleadoGerente, CHAR(60) AS ciudad;

	--definicion de variables--	    
	DEFINE resultado_numeroSucursal         CHAR(5);
    	DEFINE resultado_nombreSucursal         CHAR(40);
    	DEFINE resultado_direccion              CHAR(40);
    	DEFINE resultado_telefono               CHAR(15);
    	DEFINE resultado_nombreEstado           CHAR(30);
    	DEFINE resultado_nombreGerente          CHAR(40);
    	DEFINE resultado_numeroEmpleadoGerente  CHAR(10);
    	DEFINE resultado_ciudad                 CHAR(60);
        DEFINE resultado_cp                     CHAR(20);        DEFINE resultado_cvestado               CHAR(20);        DEFINE resultado_cvemun                 CHAR(20);        DEFINE resultado_cveloccnbv             CHAR(20);        DEFINE resultado_cvecol                 CHAR(20);    	DEFINE iSqlErr                          INTEGER;
		
     -- InicializaciÃ³n de las variables.
	LET resultado_numeroSucursal = '';
	LET resultado_nombreSucursal = '';
    LET resultado_direccion = '';
    LET resultado_telefono = '';
    LET resultado_nombreEstado = '';
    LET resultado_nombreGerente = '';
    LET resultado_numeroEmpleadoGerente = '';
    LET resultado_ciudad = '';
    LET resultado_cp                    = '';    LET resultado_cvestado              = '';    LET resultado_cvemun                = '';    LET resultado_cveloccnbv            = '';    LET resultado_cvecol                = '';
    SET ISOLATION TO DIRTY READ;
				
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_numeroSucursal = '';
                    LET resultado_nombreSucursal = '';
                    LET resultado_direccion = '';
                    LET resultado_telefono = '';
                    LET resultado_nombreEstado = '';
                    LET resultado_nombreGerente = '';
                    LET resultado_numeroEmpleadoGerente = '';
                    LET resultado_ciudad = '';
                    LET resultado_cp           = '';                    LET resultado_cvestado     = '';                    LET resultado_cvemun       = '';                    LET resultado_cveloccnbv   = '';                    LET resultado_cvecol       = '';                    RETURN resultado_numeroSucursal, resultado_nombreSucursal, resultado_direccion, resultado_telefono, resultado_nombreEstado, resultado_nombreGerente, resultado_numeroEmpleadoGerente, resultado_ciudad;
                END IF;
        END EXCEPTION;

        SET LOCK MODE TO WAIT 3;

        IF p_nombreSucursal IS NOT NULL AND p_nombreSucursal <> '' THEN
            FOREACH
                SELECT {+INDEX(bdinteg:si_localidades idx_silocalidades)}
                       SKIP p_skip DISTINCT suc.sucursal, suc.nombre, ptf.calle||' NUM '||ptf.num_ext as direccion1, ptf.tel1 as telefono1, si_estados.nombre, suc.gerente,si_ejecut.ejecutivo, loc.desc_municipio,
                       loc.cp, loc.cve_estado,loc.cve_mun,loc.cve_localidad_cnbv,loc.cve_col
                INTO resultado_numeroSucursal, resultado_nombreSucursal, resultado_direccion, resultado_telefono, resultado_nombreEstado, resultado_nombreGerente, resultado_numeroEmpleadoGerente, resultado_ciudad,
                     resultado_cp, resultado_cvestado, resultado_cvemun, resultado_cveloccnbv
                FROM bdinteg:si_ptf ptf 
                    INNER JOIN si_sucursales suc 
                        ON ptf.id_ptf = suc.sucursal AND ptf.tipo=suc.tipo
                    LEFT JOIN si_estados 
                        ON (ptf.cve_pais = si_estados.pais 
                            AND ptf.cve_estado = si_estados.estado)
                    LEFT JOIN si_ejecut ON (ptf.id_ptf = si_ejecut.sucursal 
                                            AND si_ejecut.nombramiento = 'GERENTE' 
                                            AND si_ejecut.password <> 'BAJA'
                                            AND si_ejecut.nombre like gerente)
                    LEFT OUTER JOIN bdinteg:si_localidades loc ON ( loc.id > 0 AND 
                                                          loc.cp = loc.cp AND
                                                          loc.cve_estado = ptf.cve_estado AND 
                                                          loc.cve_mun = ptf.cve_mun AND
                                                          loc.cve_localidad_cnbv = ptf.cve_localidad AND 
                                                          loc.cve_col = ptf.cve_col )
                    WHERE suc.tpo_sucursal = 'S' 
                    AND ptf.tipo <> 'C'
                    AND suc.empresa = p_nEmpresa
                    AND suc.nombre LIKE ('%' || (TRIM(p_nombreSucursal)) || '%')
                /*SELECT SKIP p_skip DISTINCT si_sucursales.sucursal, si_sucursales.nombre, direccion1, telefono1, si_estados.nombre, gerente, ejecutivo, si_ciudades.nombre
                INTO resultado_numeroSucursal, resultado_nombreSucursal, resultado_direccion, resultado_telefono, resultado_nombreEstado, resultado_nombreGerente, resultado_numeroEmpleadoGerente, resultado_ciudad
                FROM bdinteg:si_sucursales
                    LEFT JOIN si_estados 
                        ON (si_sucursales.pais = si_estados.pais 
                            AND si_sucursales.estado = si_estados.estado)
                    LEFT JOIN si_ejecut ON (si_sucursales.sucursal = si_ejecut.sucursal 
                                            AND si_ejecut.nombramiento = 'GERENTE' 
                                            AND si_ejecut.password <> 'BAJA'
                                            AND si_ejecut.nombre like gerente)
                    LEFT JOIN si_ciudades 
                        ON (si_sucursales.pais = si_ciudades.pais 
                            AND si_sucursales.estado = si_ciudades.estado AND si_sucursales.ciudad = si_ciudades.ciudad)
                    WHERE si_sucursales.tpo_sucursal = 'S' 
                    AND si_sucursales.empresa = p_nEmpresa
                    AND si_sucursales.nombre LIKE ('%' || (TRIM(p_nombreSucursal)) || '%')*/
                RETURN resultado_numeroSucursal, resultado_nombreSucursal, resultado_direccion, resultado_telefono, resultado_nombreEstado, resultado_nombreGerente, resultado_numeroEmpleadoGerente, resultado_ciudad WITH RESUME;
            END FOREACH;
        ELSE
            IF p_numeroSucursal IS NOT NULL AND p_numeroSucursal <> '' THEN
                FOREACH
                    SELECT {+INDEX(bdinteg:si_localidades idx_silocalidades)}
                           SKIP p_skip DISTINCT suc.sucursal, suc.nombre, ptf.calle||' NUM '||ptf.num_ext as direccion1, ptf.tel1, si_estados.nombre, gerente, ejecutivo, loc.desc_municipio,
                    loc.cp, loc.cve_estado,loc.cve_mun,loc.cve_localidad_cnbv,loc.cve_col
                    INTO resultado_numeroSucursal, resultado_nombreSucursal, resultado_direccion, resultado_telefono, resultado_nombreEstado, resultado_nombreGerente, resultado_numeroEmpleadoGerente, resultado_ciudad,
                    resultado_cp, resultado_cvestado, resultado_cvemun, resultado_cveloccnbv
                    FROM bdinteg:si_ptf ptf
                        INNER JOIN si_sucursales suc ON suc.sucursal = ptf.id_ptf  AND ptf.tipo=suc.tipo 
                        LEFT JOIN si_estados ON (ptf.cve_pais = si_estados.pais AND ptf.cve_estado = si_estados.estado)
                        LEFT JOIN si_ejecut ON (ptf.id_ptf = si_ejecut.sucursal AND si_ejecut.nombramiento = 'GERENTE' AND si_ejecut.password <> 'BAJA'
                                                AND si_ejecut.nombre like gerente)
                        LEFT OUTER JOIN bdinteg:si_localidades loc ON ( loc.id > 0 AND 
                                                          loc.cp = loc.cp AND
                                                          loc.cve_estado = ptf.cve_estado AND 
                                                          loc.cve_mun = ptf.cve_mun AND
                                                          loc.cve_localidad_cnbv = ptf.cve_localidad AND 
                                                          loc.cve_col = ptf.cve_col )
                        WHERE suc.tpo_sucursal = 'S' 
                        AND ptf.tipo <> 'C'
                        AND suc.empresa = p_nEmpresa
                        AND ptf.id_ptf = p_numeroSucursal 

                    /*SELECT SKIP p_skip DISTINCT si_sucursales.sucursal, si_sucursales.nombre, direccion1, telefono1, si_estados.nombre, gerente, ejecutivo, si_ciudades.nombre
                    INTO resultado_numeroSucursal, resultado_nombreSucursal, resultado_direccion, resultado_telefono, resultado_nombreEstado, resultado_nombreGerente, resultado_numeroEmpleadoGerente, resultado_ciudad
                    FROM bdinteg:si_sucursales
                        LEFT JOIN si_estados ON (si_sucursales.pais = si_estados.pais AND si_sucursales.estado = si_estados.estado)
                        LEFT JOIN si_ejecut ON (si_sucursales.sucursal = si_ejecut.sucursal AND si_ejecut.nombramiento = 'GERENTE' AND si_ejecut.password <> 'BAJA'
                                                AND si_ejecut.nombre like gerente)
                        LEFT JOIN si_ciudades ON (si_sucursales.pais = si_ciudades.pais AND si_sucursales.estado = si_ciudades.estado AND si_sucursales.ciudad = si_ciudades.ciudad)
                        WHERE si_sucursales.tpo_sucursal = 'S' 
                        AND si_sucursales.empresa = p_nEmpresa
                        AND si_sucursales.sucursal = p_numeroSucursal*/
                    RETURN resultado_numeroSucursal, resultado_nombreSucursal, resultado_direccion, resultado_telefono, resultado_nombreEstado, resultado_nombreGerente, resultado_numeroEmpleadoGerente, resultado_ciudad WITH RESUME;
                END FOREACH;
            ELSE
                FOREACH
                    SELECT SKIP p_skip DISTINCT suc.sucursal, suc.nombre,  ptf.calle||' NUM '||ptf.num_ext as direccion1, ptf.tel1, si_estados.nombre, suc.gerente, ejecut.ejecutivo, loc.desc_municipio
                    INTO resultado_numeroSucursal, resultado_nombreSucursal, resultado_direccion, resultado_telefono, resultado_nombreEstado, resultado_nombreGerente, resultado_numeroEmpleadoGerente, resultado_ciudad
                    FROM bdinteg:si_ptf ptf
                        INNER JOIN si_sucursales suc ON ptf.id_ptf = suc.sucursal AND ptf.tipo = suc.tipo
                        LEFT JOIN si_estados ON (ptf.cve_pais = si_estados.pais AND ptf.cve_estado = si_estados.estado)
                        LEFT JOIN si_ejecut ejecut ON (ptf.id_ptf = ejecut.sucursal AND ejecut.nombramiento = 'GERENTE' AND ejecut.password <> 'BAJA'
                                                AND ejecut.nombre like gerente)
                        LEFT OUTER JOIN bdinteg:si_localidades loc ON ( loc.id > 0 AND 
                                                          loc.cp = loc.cp AND
                                                          loc.cve_estado = ptf.cve_estado AND 
                                                          loc.cve_mun = ptf.cve_mun AND
                                                          loc.cve_localidad_cnbv = ptf.cve_localidad AND 
                                                          loc.cve_col = ptf.cve_col )
                        WHERE suc.pais = p_numeroPais
                        AND ptf.cve_estado = p_numeroEstado
                        AND suc.empresa = p_nEmpresa
                        AND suc.tpo_sucursal = 'S' 

                    /*SELECT SKIP p_skip DISTINCT si_sucursales.sucursal, si_sucursales.nombre, direccion1, telefono1, si_estados.nombre, gerente, ejecutivo, si_ciudades.nombre
                    INTO resultado_numeroSucursal, resultado_nombreSucursal, resultado_direccion, resultado_telefono, resultado_nombreEstado, resultado_nombreGerente, resultado_numeroEmpleadoGerente, resultado_ciudad
                    FROM bdinteg:si_sucursales
                        LEFT JOIN si_estados ON (si_sucursales.pais = si_estados.pais AND si_sucursales.estado = si_estados.estado)
                        LEFT JOIN si_ejecut ON (si_sucursales.sucursal = si_ejecut.sucursal AND si_ejecut.nombramiento = 'GERENTE' AND si_ejecut.password <> 'BAJA'
                                                AND si_ejecut.nombre like gerente)
                        LEFT JOIN si_ciudades ON (si_sucursales.pais = si_ciudades.pais AND si_sucursales.estado = si_ciudades.estado AND si_sucursales.ciudad = si_ciudades.ciudad)
                        WHERE si_sucursales.pais = p_numeroPais
                        AND si_sucursales.estado = p_numeroEstado
                        AND si_sucursales.empresa = p_nEmpresa
                        AND si_sucursales.tpo_sucursal = 'S'*/ 
                    RETURN resultado_numeroSucursal, resultado_nombreSucursal, resultado_direccion, resultado_telefono, resultado_nombreEstado, resultado_nombreGerente, resultado_numeroEmpleadoGerente, resultado_ciudad WITH RESUME;
                END FOREACH;
            END IF;
        END IF;
    END
END PROCEDURE;