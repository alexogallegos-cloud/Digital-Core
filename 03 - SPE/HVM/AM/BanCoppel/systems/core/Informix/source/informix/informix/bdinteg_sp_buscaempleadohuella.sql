CREATE PROCEDURE "informix".sp_buscaempleadohuella (p_sNumeroEmpleado CHAR(8), p_sNumeroEmpresa CHAR(3))

     RETURNING	CHAR(45) AS nombreEmpleado,  CHAR(3) AS puesto, CHAR(4) AS sucursal, CHAR(40) AS nombreSucursal, CHAR(30) AS nombreEstado, CHAR(60) AS nombreCiudad, CHAR(20) AS nombramiento

	-- Definicion de variables
	DEFINE resultado_nombreEmpleado     CHAR(45);
	DEFINE resultado_puesto             CHAR(3);
	DEFINE resultado_sucursal           CHAR(4);
	DEFINE resultado_nombreSucursal 	CHAR(40);
	DEFINE resultado_nombreEstado 		CHAR(30);
	DEFINE resultado_nombreCiudad		CHAR(60);
	DEFINE resultado_nombramiento		CHAR(20);
	DEFINE resultado_cp					CHAR(20);
	DEFINE resultado_cvestado			CHAR(20);
	DEFINE resultado_cvemun	 			CHAR(20);
	DEFINE resultado_cveloccnbv	 		CHAR(20);
	DEFINE resultado_cvecol	 		    CHAR(20);
    DEFINE iSqlErr                  	INTEGER;
	
	DEFINE v_activo 			        SMALLINT;
	
    -- InicializaciÃ³n de las variables.
	LET resultado_nombreEmpleado 		= '';
	LET resultado_puesto 				= '';
	LET resultado_sucursal 				= '';
	LET resultado_nombreSucursal 		= '';
	LET resultado_nombreEstado 			= '';
	LET resultado_nombreCiudad 			= '';
	LET resultado_nombramiento 			= '';
	LET resultado_cp		 			= '';
	LET resultado_cvestado 				= '';
	LET resultado_cvemun 				= '';
	LET resultado_cveloccnbv 			= '';
	LET resultado_cvecol     			= '';

	LET v_activo 			   			= '';
	
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ValidaciÃ³n de usuarios no registrados 06/01/2013
-- Se agrega la validaciÃ³n para que no ingresen usuarios de corporativo no registrados en el sistema.
-- SADVC 
	
    SET ISOLATION TO DIRTY READ;
			
	BEGIN

        ON EXCEPTION
            
			SET iSqlErr
            IF iSqlErr <> 0 THEN
            LET resultado_nombreEmpleado = '';
			LET resultado_puesto = '';
			LET resultado_sucursal = '';
			LET resultado_nombreSucursal = '';
			LET resultado_nombreEstado = '';
			LET resultado_nombreCiudad = '';
			LET resultado_nombramiento = '';
			LET resultado_cp		   = '';
			LET resultado_cvestado     = '';
			LET resultado_cvemun       = '';
			LET resultado_cveloccnbv   = '';
			LET resultado_cvecol 	   = '';

			RETURN resultado_nombreEmpleado, resultado_puesto, resultado_sucursal, resultado_nombreSucursal, resultado_nombreEstado, resultado_nombreCiudad, resultado_nombramiento;

			END IF;

        END EXCEPTION;

        SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Se agrega validaciÃ³n para usuarios no permitidos / registrados.
-- validaciÃ³n que se encuentren en la BD de aclaraciones y que pertenezcan a una sucursal.
-- SADVC 
	
	 SELECT activo
	   INTO v_activo
	   FROM bdiaclaracion:acl_usuario where num_empleado = p_sNumeroEmpleado;
		
	IF (v_activo = 1) THEN  
		
	 
	SELECT DISTINCT {+INDEX(bdinteg:si_localidades idx_silocalidades)}
					 si_ejecut.nombre, si_ejecut.puesto, si_ejecut.sucursal, suc.nombre, si_estados.nombre, loc.desc_municipio AS ciudad,
					 loc.cp, loc.cve_estado,loc.cve_mun,loc.cve_localidad_cnbv,loc.cve_col, si_ejecut.nombramiento
				INTO resultado_nombreEmpleado, resultado_puesto, resultado_sucursal, resultado_nombreSucursal, resultado_nombreEstado, resultado_nombreCiudad, 
				resultado_cp, resultado_cvestado, resultado_cvemun, resultado_cveloccnbv, resultado_nombramiento 
				FROM si_ejecut
				JOIN si_ptf ptf ON ptf.id_ptf = si_ejecut.sucursal
				JOIN si_sucursales suc ON ptf.id_ptf = suc.sucursal AND ptf.tipo=suc.tipo AND suc.empresa = p_sNumeroEmpresa
				JOIN si_localidades loc ON (ptf.cve_estado = loc.cve_estado AND ptf.cve_localidad = loc.cve_localidad_cnbv AND ptf.cve_col = loc.cve_col)
                JOIN si_estados ON si_estados.estado = suc.estado
	           WHERE si_ejecut.ejecutivo = p_sNumeroEmpleado
			     AND si_ejecut.empresa = p_sNumeroEmpresa
			     AND ptf.tipo <> 'C' 
				 AND si_ejecut.password <> "BAJA";

     /*SELECT DISTINCT si_ejecut.nombre, si_ejecut.puesto, si_ejecut.sucursal, si_sucursales.nombre, si_estados.nombre, si_ciudades.nombre, si_ejecut.nombramiento
				INTO resultado_nombreEmpleado, resultado_puesto, resultado_sucursal, resultado_nombreSucursal, resultado_nombreEstado, resultado_nombreCiudad, resultado_nombramiento
				FROM si_ejecut
				JOIN ((si_sucursales JOIN si_ciudades ON si_ciudades.ciudad = si_sucursales.ciudad AND  si_ciudades.estado = si_sucursales.estado AND  si_ciudades.pais = si_sucursales.pais)
				JOIN si_estados ON si_estados.estado = si_sucursales.estado) ON (si_sucursales.sucursal = si_ejecut.sucursal AND si_sucursales.empresa = p_sNumeroEmpresa)
	           WHERE ejecutivo = p_sNumeroEmpleado 
			     AND si_ejecut.empresa = p_sNumeroEmpresa 
				 AND password <> "BAJA";*/

				ELSE 
		
	SELECT DISTINCT {+INDEX(bdinteg:si_localidades idx_silocalidades)} 
				ejecut.nombre, ejecut.puesto, ejecut.sucursal, suc.nombre , si_estados.nombre as estado,
                NVL(loc.desc_municipio,'') AS ciudad,  loc.cp, loc.cve_estado, loc.cve_mun,loc.cve_localidad_cnbv,loc.cve_col,
                ejecut.nombramiento
                INTO resultado_nombreEmpleado, resultado_puesto, resultado_sucursal, resultado_nombreSucursal, resultado_nombreEstado, resultado_nombreCiudad, resultado_cp, resultado_cvestado, resultado_cvemun, resultado_cveloccnbv, resultado_nombramiento
				FROM si_ejecut ejecut
				JOIN si_ptf ptf ON ptf.id_ptf = ejecut.sucursal 
				JOIN si_sucursales suc ON ptf.id_ptf = suc.sucursal AND ptf.tipo=suc.tipo AND  suc.empresa = p_sNumeroEmpresa
				JOIN si_estados ON si_estados.estado = ptf.cve_estado
				LEFT OUTER JOIN bdinteg:si_localidades loc ON ( loc.id > 0 AND 
                                                          loc.cp = loc.cp AND
                                                          loc.cve_estado = ptf.cve_estado AND 
                                                          loc.cve_mun = ptf.cve_mun AND
                                                          loc.cve_localidad_cnbv = ptf.cve_localidad AND 
                                                          loc.cve_col = ptf.cve_col )
	           WHERE ejecut.ejecutivo = p_sNumeroEmpleado  
			     AND ejecut.empresa = p_sNumeroEmpresa 
			     AND suc.tpo_sucursal = 'S' --> ValidaciÃ³n de la sucursal
                 AND ptf.tipo <> 'C'
				 AND ejecut.password <> "BAJA" ;

	/* SELECT DISTINCT si_ejecut.nombre, si_ejecut.puesto, si_ejecut.sucursal, si_sucursales.nombre, si_estados.nombre, si_ciudades.nombre, si_ejecut.nombramiento
				INTO resultado_nombreEmpleado, resultado_puesto, resultado_sucursal, resultado_nombreSucursal, resultado_nombreEstado, resultado_nombreCiudad, resultado_nombramiento
				FROM si_ejecut
				JOIN ((si_sucursales JOIN si_ciudades ON si_ciudades.ciudad = si_sucursales.ciudad AND  si_ciudades.estado = si_sucursales.estado AND  si_ciudades.pais = si_sucursales.pais)
				JOIN si_estados ON si_estados.estado = si_sucursales.estado) ON (si_sucursales.sucursal = si_ejecut.sucursal AND si_sucursales.empresa = p_sNumeroEmpresa)
	           WHERE ejecutivo = p_sNumeroEmpleado 
			     AND si_ejecut.empresa = p_sNumeroEmpresa 
			     AND tpo_sucursal = 'S' --> ValidaciÃ³n de la sucursal
				 AND password <> "BAJA"; */
				
				END IF;
	   
	   RETURN resultado_nombreEmpleado, resultado_puesto, resultado_sucursal, resultado_nombreSucursal, resultado_nombreEstado, resultado_nombreCiudad, resultado_nombramiento;
	
	END

END PROCEDURE;