CREATE PROCEDURE "informix".sp_consultarcatalogodireccion(iTipoCatalogo INTEGER, iTipoConsulta INTEGER, cConsulta CHAR(50), cEstadoLocal CHAR(2),
														cCiudadCoppelLocal CHAR(4), iZona INTEGER, iRegistros INTEGER)

	RETURNING
	CHAR(5),      -- Código de Retorno
	CHAR(3),      -- Clave del Estado
	CHAR(60),     -- Nombre del Estado
	SMALLINT,     -- Clave de la Zona, Edificio y Ciudad Coppel
	INTEGER,      -- Clave de la Calle
	CHAR(27);     -- Nombre del Municipio Zona

	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cClave  CHAR(3);
	DEFINE cNombre CHAR(60);
	DEFINE isClave SMALLINT;
	DEFINE iClave  INTEGER;
	DEFINE cMunicipioZona CHAR(27);

	--INICIALIZACION DE VARIABLES--
	LET iSqlErr = 0;
	LET cCodRet = '000';
	LET cClave  = '';
	LET cNombre = '';
	LET isClave = 0;
	LET iClave = 0;	
	LET cMunicipioZona = '';	

	--SET DEBUG FILE TO "/home/informix/sp_ConsultarCatalogoDireccion.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cClave, cNombre, isClave, iClave, cMunicipioZona;
			END IF;
		END EXCEPTION;

		-- CONSULTA DEL CATÁLOGO DE ESTADO
		IF iTipoCatalogo = 1 THEN	
			-- Tipo de consulta general
			IF iTipoConsulta = 1 THEN
				FOREACH
					SELECT estado, nombre INTO cClave, cNombre 
					FROM "informix".si_estados WHERE pais != '' AND estado != '' 
					ORDER BY nombre ASC	

					RETURN cCodRet, cClave, cNombre, isClave, iClave, cMunicipioZona WITH RESUME;
				END FOREACH;

				IF cClave = '' AND cNombre = '' THEN
					LET cCodRet = '001';
					RETURN cCodRet, cClave, cNombre, isClave, iClave, cMunicipioZona;
				END IF;
			-- Tipo de consulta por un parámetro determinado				
			ELSE 
				FOREACH
					SELECT estado, nombre INTO cClave, cNombre 
					FROM "informix".si_estados 
					WHERE pais != '' AND estado != '' AND nombre LIKE '%' || TRIM(cConsulta) || '%' 
					ORDER BY nombre ASC

					RETURN cCodRet, cClave, cNombre, isClave, iClave, cMunicipioZona WITH RESUME;
				END FOREACH;

				IF cClave = '' AND cNombre = '' THEN
					LET cCodRet = '001';
					RETURN cCodRet, cClave, cNombre, isClave, iClave, cMunicipioZona;
				END IF;
			END IF;

		-- CONSULTA DEL CATÁLOGO DE CIUDAD
		ELIF iTipoCatalogo = 2 THEN		
			-- Tipo de consulta general
			IF iTipoConsulta = 1 THEN
				FOREACH
					SELECT ciudad, nombre, ciudad_coppel INTO cClave, cNombre, isClave
					FROM "informix".si_ciudades 
					WHERE estado = cEstadolocal AND ciudad != '' AND nombre != '' 
					ORDER BY nombre ASC

					RETURN cCodRet, cClave, cNombre, isClave, iClave, cMunicipioZona WITH RESUME;
				END FOREACH;

				IF cClave = '' AND cNombre = '' AND isClave = 0 THEN
					LET cCodRet = '001';
					RETURN cCodRet, cClave, cNombre, isClave, iClave, cMunicipioZona;
				END IF;
			-- Tipo de consulta por un parámetro determinado	
			ELSE
				FOREACH
					SELECT ciudad, nombre, ciudad_coppel INTO cClave, cNombre, isClave 
					FROM "informix".si_ciudades 
					WHERE estado = cEstadolocal AND ciudad != '' AND nombre LIKE '%' || TRIM(cConsulta) || '%' 
					ORDER BY nombre ASC

					RETURN cCodRet, cClave, cNombre, isClave, iClave, cMunicipioZona WITH RESUME;
				END FOREACH;	

				IF cClave = '' AND cNombre = '' AND isClave = 0 THEN
					LET cCodRet = '001';
					RETURN cCodRet, cClave, cNombre, isClave, iClave, cMunicipioZona;
				END IF;						
			END IF;	

		-- CONSULTA DEL CATÁLOGO DE ZONA
		ELIF iTipoCatalogo = 3 THEN		
			-- Tipo de consulta general
			IF iTipoConsulta = 1 THEN	
				FOREACH
					SELECT numerocolonia, nombrezona, municipiozona  INTO isClave, cNombre, cMunicipioZona 
					FROM "informix".si_catzonas 
					WHERE numerociudad = cCiudadCoppelLocal AND numerocolonia != 0 
					ORDER BY nombrezona ASC

					RETURN cCodRet, cClave, cNombre, isClave, iClave, cMunicipioZona WITH RESUME;
				END FOREACH;

				IF isClave = 0 AND cNombre = '' AND cMunicipioZona = '' THEN		
					LET cCodRet = '001';
					RETURN cCodRet, cClave, cNombre, isClave, iClave, cMunicipioZona;
				END IF;	
			-- Tipo de consulta por un parámetro determinado
			ELSE						
				FOREACH
					SELECT numerocolonia, nombrezona, municipiozona INTO isClave, cNombre, cMunicipioZona 
					FROM "informix".si_catzonas 
					WHERE numerociudad = cCiudadCoppelLocal AND numerocolonia != 0 AND nombrezona LIKE '%' || TRIM(cConsulta) || '%' 
					ORDER BY nombrezona ASC	

					RETURN cCodRet, cClave, cNombre, isClave, iClave, cMunicipioZona WITH RESUME;
				END FOREACH;	

				IF isClave = 0 AND cNombre = ''AND cMunicipioZona = '' THEN
					LET cCodRet = '001';
					RETURN cCodRet, cClave, cNombre, isClave, iClave, cMunicipioZona;
				END IF;
			END IF;

		-- CONSULTA DEL CATÁLOGO DE CALLE
		ELIF iTipoCatalogo = 4 THEN
			-- Tipo de consulta por un parámetro determinado
			FOREACH
				SELECT SKIP iRegistros FIRST 1000 numerocalle, nombrecalle INTO iClave, cNombre 
				FROM "informix".si_catcalles 
				WHERE numerocalle != 0 AND nombrecalle LIKE '%' || TRIM(cConsulta) || '%' 
				ORDER BY nombrecalle ASC			

				RETURN cCodRet, cClave, cNombre, isClave, iClave, cMunicipioZona WITH RESUME;
			END FOREACH;

			IF iClave = 0 AND cNombre = '' THEN
				LET cCodRet = '001';
				RETURN cCodRet, cClave, cNombre, isClave, iClave, cMunicipioZona;
			END IF;	

		-- CONSULTA DEL CATÁLOGO DE EDIFICIO
		ELIF iTipoCatalogo = 5 THEN
			-- Tipo de consulta general
			IF iTipoConsulta = 1 THEN
				FOREACH
					SELECT nombredomicilio, complementoclave INTO cNombre, isClave 
					FROM "informix".si_catdomicilios 
					WHERE numerociudad = cCiudadCoppelLocal AND numerocolonia = iZona AND clavedomicilio = 5 
					ORDER BY nombredomicilio ASC 

					RETURN cCodRet, cClave, cNombre, isClave, iClave, cMunicipioZona WITH RESUME;
				END FOREACH;

				IF cNombre = '' THEN
					LET cCodRet = '001';
					RETURN cCodRet, cClave, cNombre, isClave, iClave, cMunicipioZona;
				END IF;
			-- Tipo de consulta por un parámetro determinado				
			ELSE						
				-- Si existe se realiza la consulta
				FOREACH
					SELECT nombredomicilio, complementoclave INTO cNombre, isClave 
					FROM "informix".si_catdomicilios 
					WHERE numerociudad = cCiudadCoppelLocal AND numerocolonia = iZona 
					AND clavedomicilio = 5 AND nombredomicilio LIKE '%' || TRIM(cConsulta) || '%' 
					ORDER BY nombredomicilio ASC 

					RETURN cCodRet, cClave, cNombre, isClave, iClave, cMunicipioZona WITH RESUME;
				END FOREACH;

				IF cNombre = '' THEN
					LET cCodRet = '001';
					RETURN cCodRet, cClave, cNombre, isClave, iClave, cMunicipioZona;
				END IF;
			END IF;	
		END IF;
	END
END PROCEDURE
DOCUMENT
'Consulta los catálogos de dirección: Estado, Ciudad, Zona, Calle y Edificio',
'AUTOR: Nancy Sevilla Camacho',
'FECHA: 04/04/2011',
'DSB 04/05/2011 - Se modifica la longitud del dato clave y nombre',
'y la consulta del catalogo de edificios para obtener el complemento clave',
'MODIFICO: Iris Arias Zazueta',
'DSB 25/05/2011 - Se modifica la longitud del dato ciudad coppel',
'MODIFICO: Iris Arias Zazueta',
'BD   : bdinteg',
'VER  : 1.0';

CREATE PROCEDURE "informix".sp_bitacora_cambiosdomcobranza(pNumSucursal CHAR(4),
														   pTipoCatalogo INTEGER,
														   pFechaIni CHAR(10),
														   pFechaFin CHAR(10),
														   pTiendaMatriz CHAR(5)) 

--DATOS A REGRESAR---
RETURNING
CHAR(5),      -- Código de Retorno
CHAR(104),    -- Nombre
CHAR(30),     -- Estado
CHAR(316),    -- Ciudad
CHAR(5),      -- Tda Matriz
DATE,         -- Fecha
CHAR(8),      -- #Empleado Cob
CHAR(20),     -- #Empleado Tda
CHAR(15),     -- Tipo Domicilio
INTEGER,      -- Cantidad (Count)
CHAR(30),     -- Nombre Región
CHAR(4);      -- Sucursal

--DEFINICION DE VARIABLES--
DEFINE iSqlErr    INTEGER;
DEFINE cCodRet    CHAR(5);	
---------------------------	
DEFINE cNombre       CHAR(104);    -- Nombre
DEFINE cNombreEstado CHAR(30);     -- Estado
DEFINE cCiudad       CHAR(316);    -- Ciudad
DEFINE cTdaMatriz    CHAR(5);      -- Tda Matriz
DEFINE dFecha        DATE;         -- Fecha
DEFINE cEmpleadoCob  CHAR(8);      -- #Empleado Cob
DEFINE cEmpleadoTda  CHAR(20);     -- #Empleado Tda
DEFINE cTipoDir      CHAR(15);     -- Tipo Domicilio
DEFINE cCantidad     INTEGER;      -- Cantidad (Count)
DEFINE cNombreRegion CHAR(30);     -- Nombre Región
DEFINE cSucursal     CHAR(4);      -- Sucursal

--INICIALIZACION DE VARIABLES--
LET iSqlErr    = 0;
LET cCodRet    = '000';
-------------------------------
LET cNombre    = '';  
LET cNombreEstado = '';
LET cCiudad = '';     
LET cTdaMatriz = '';
LET dFecha = '01-01-1900';      
LET cEmpleadoCob = '';
LET cEmpleadoTda = '';
LET cTipoDir = '';    
LET cCantidad = 0;   
LET cNombreRegion = '';
LET cSucursal = '';   

	--SET DEBUG FILE TO "/home/informix/sp_Bitacora_CambiosDomCobranza.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
					RETURN cCodRet,
						   cNombre,      
						   cNombreEstado,
						   cCiudad,      
						   cTdaMatriz,   
						   dFecha,       
						   cEmpleadoCob, 
						   cEmpleadoTda, 
						   cTipoDir,     
						   cCantidad,    
						   cNombreRegion,
						   cSucursal;
			END IF;
		END EXCEPTION;	  
		
-- Se valida que query se va a ejecutar	
		IF pTipoCatalogo = 1 THEN

		-- Totales Clientes-Periodo
			FOREACH
				SELECT DECODE(tipo_dir,'1','Particular','2','Trabajo'), 
				       COUNT(*)
				  INTO cTipoDir,
					   cCantidad
				  FROM bdinteg:si_bitacora_cambiosdom
				 WHERE fecha BETWEEN pFechaIni AND pFechaFin
				 GROUP BY tipo_dir
				 
					RETURN cCodRet,
						   cNombre,      
						   cNombreEstado,
						   cCiudad,      
						   cTdaMatriz,   
						   dFecha,       
						   cEmpleadoCob, 
						   cEmpleadoTda, 
						   cTipoDir,     
						   cCantidad,    
						   cNombreRegion,
						   cSucursal
					  WITH RESUME;			 
				 
			END FOREACH;	 
			 
			 IF cTipoDir IS NULL THEN
			 
				LET cCodRet = "101"; -- No se encontró información
				
				RETURN cCodRet,
				       cNombre,      
				       cNombreEstado,
				       cCiudad,      
				       cTdaMatriz,   
				       dFecha,       
				       cEmpleadoCob, 
				       cEmpleadoTda, 
				       cTipoDir,     
				       cCantidad,    
			           cNombreRegion,
			           cSucursal
				  WITH RESUME;	
				  
			END IF;
	                   
		ELIF pTipoCatalogo = 2 THEN	 
		-- Detallado Clientes-Periodo
			FOREACH
				SELECT TRIM(b.nombre1) || ' ' || TRIM(b.nombre2) || ' ' || TRIM(b.apell_paterno) || ' ' || TRIM(b.apell_materno),
					   e.nombre,
					   i.nombre,
             s.tienda_matriz,					   
					   a.fecha,
					   a.usr_captura,
					   a.usr_autoriza,
					   DECODE(a.tipo_dir,'1','Particular','2','Trabajo')
				  INTO cNombre,
					   cNombreEstado,				  
					   cCiudad,				  
					   cTdaMatriz,    
					   dFecha,      
					   cEmpleadoCob,
					   cEmpleadoTda,
					   cTipoDir
				  FROM bdinteg:si_bitacora_cambiosdom a,
					   bdinteg:si_cliente b,
					   bdinteg:si_estados e,
					   bdinteg:si_ciudades i,
					   bdinteg:si_direcciones_actual d,
					   bdinteg:si_sucursales s
				 WHERE a.cliente = b.numcte
				   AND i.estado = e.estado
				   AND a.cliente = d.numcte
				   AND d.tipo_dir = a.tipo_dir	
				   AND s.sucursal = a.sucursal				   
				   AND a.fecha BETWEEN pFechaIni AND pFechaFin				   
				   AND d.numerociudad = i.ciudad_coppel

					RETURN cCodRet,
						   cNombre,      
						   cNombreEstado,
						   cCiudad,      
						   cTdaMatriz,   
						   dFecha,       
						   cEmpleadoCob, 
						   cEmpleadoTda, 
						   cTipoDir,     
						   cCantidad,    
						   cNombreRegion,
						   cSucursal
					  WITH RESUME;			 
				 
			END FOREACH;	 
			 
			 IF cNombre IS NULL THEN
			 
				LET cCodRet = "102"; -- No se encontró información
				
				RETURN cCodRet,
				       cNombre,      
				       cNombreEstado,
				       cCiudad,      
				       cTdaMatriz,   
				       dFecha,       
				       cEmpleadoCob, 
				       cEmpleadoTda, 
				       cTipoDir,     
				       cCantidad,    
			           cNombreRegion,
			           cSucursal
				  WITH RESUME;	
				  
			END IF;			   
	   
		ELIF pTipoCatalogo = 3 THEN	   
		-- Totales Tienda Matriz - No. Tienda Matriz
			FOREACH
				SELECT s.tienda_matriz,
					   DECODE(a.tipo_dir,'1','Particular','2','Trabajo'),
					   count(*)
				  INTO cTdaMatriz,
					   cTipoDir,
					   cCantidad
				  FROM bdinteg:si_bitacora_cambiosdom a,
				       bdinteg:si_sucursales s
				 WHERE a.sucursal = s.tienda_matriz
				   AND a.fecha BETWEEN pfechaIni AND pFechaFin
				 GROUP BY s.tienda_matriz, a.tipo_dir ORDER BY s.tienda_matriz
				 
					RETURN cCodRet,
						   cNombre,      
						   cNombreEstado,
						   cCiudad,      
						   cTdaMatriz,   
						   dFecha,       
						   cEmpleadoCob, 
						   cEmpleadoTda, 
						   cTipoDir,     
						   cCantidad,    
						   cNombreRegion,
						   cSucursal
					  WITH RESUME;			 
				 
			END FOREACH;	 
			 
			 IF cTdaMatriz IS NULL THEN
			 
				LET cCodRet = "103"; -- No se encontró información
				
				RETURN cCodRet,
				       cNombre,      
				       cNombreEstado,
				       cCiudad,      
				       cTdaMatriz,   
				       dFecha,       
				       cEmpleadoCob, 
				       cEmpleadoTda, 
				       cTipoDir,     
				       cCantidad,    
			           cNombreRegion,
			           cSucursal
				  WITH RESUME;	
				  
			END IF;					 
	 
		ELIF pTipoCatalogo = 4 THEN	 
		-- Totales Tienda Matriz - Región Cobranza
			FOREACH
				SELECT r.nombre_region,
					   s.tienda_matriz,
					   DECODE(a.tipo_dir,'1','Particular','2','Trabajo'),
					   COUNT(*)
				  INTO cNombreRegion,
					   cTdaMatriz,
					   cTipoDir,
					   cCantidad
				  FROM bdinteg:si_bitacora_cambiosdom a,
					   bdinteg:si_ciudades ci,
					   bdinteg:si_catciudades cat,
					   bdinteg:si_regiones r,
					   bdinteg:si_sucursales s
				 WHERE s.tienda_matriz = a.sucursal
				   AND s.estado = ci.estado
				   AND s.ciudad = ci.ciudad
				   AND cat.numerociudad = ci.ciudad_coppel
				   AND cat.numero_region = r.numero_region
				   AND a.fecha BETWEEN pFechaIni AND pFechaFin
				 GROUP BY r.nombre_region, s.tienda_matriz, a.tipo_dir 
				 ORDER BY r.nombre_region, s.tienda_matriz, 3
			 
					RETURN cCodRet,
						   cNombre,      
						   cNombreEstado,
						   cCiudad,      
						   cTdaMatriz,   
						   dFecha,       
						   cEmpleadoCob, 
						   cEmpleadoTda, 
						   cTipoDir,     
						   cCantidad,    
						   cNombreRegion,
						   cSucursal
					  WITH RESUME;			 
				 
			END FOREACH;	 
			 
			 IF cNombreRegion IS NULL THEN
			 
				LET cCodRet = "104"; -- No se encontró información
				
				RETURN cCodRet,
				       cNombre,      
				       cNombreEstado,
				       cCiudad,      
				       cTdaMatriz,   
				       dFecha,       
				       cEmpleadoCob, 
				       cEmpleadoTda, 
				       cTipoDir,     
				       cCantidad,    
			           cNombreRegion,
			           cSucursal
				  WITH RESUME;	
				  
			END IF;					 
			 
		ELIF pTipoCatalogo = 5 THEN	 
		-- Detallado Tienda Matriz
			FOREACH
				SELECT TRIM(b.nombre1) || ' ' || TRIM(b.nombre2) || ' ' || TRIM(b.apell_paterno) || ' ' || TRIM(b.apell_materno),
					   e.nombre,
					   i.nombre,					   
					   s.tienda_matriz,
					   a.fecha,
					   a.usr_captura,
					   a.usr_autoriza,
					   DECODE(a.tipo_dir,'1','Particular','2','Trabajo')
			      INTO cNombre,
					   cNombreEstado,
					   cCiudad,					   
					   cTdaMatriz,
					   dFecha,    
             cEmpleadoCob,
					   cEmpleadoTda,
					   cTipoDir					   
				  FROM bdinteg:si_bitacora_cambiosdom a,
					   bdinteg:si_cliente b,
					   bdinteg:si_estados e,
					   bdinteg:si_ciudades i,
					   bdinteg:si_sucursales s,
					   bdinteg:si_direcciones_actual d
				 WHERE a.cliente = b.numcte
				   AND i.estado = e.estado
				   AND d.numcte = a.cliente				   
				   AND d.numerociudad = i.ciudad_coppel
				   AND s.sucursal = a.sucursal			 
				   AND a.fecha BETWEEN pFechaIni AND pFechaFin
                   AND s.tienda_matriz = pTiendaMatriz					   

					RETURN cCodRet,
						   cNombre,      
						   cNombreEstado,
						   cCiudad,      
						   cTdaMatriz,   
						   dFecha,       
						   cEmpleadoCob, 
						   cEmpleadoTda, 
						   cTipoDir,     
						   cCantidad,    
						   cNombreRegion,
						   cSucursal
					  WITH RESUME;			 
				 
			END FOREACH;	 
			 
			 IF cNombre IS NULL THEN
			 
				LET cCodRet = "105"; -- No se encontró información
				
				RETURN cCodRet,
				       cNombre,      
				       cNombreEstado,
				       cCiudad,      
				       cTdaMatriz,   
				       dFecha,       
				       cEmpleadoCob, 
				       cEmpleadoTda, 
				       cTipoDir,     
				       cCantidad,    
			           cNombreRegion,
			           cSucursal
				  WITH RESUME;	
				  
			END IF;							   
	   
		ELIF pTipoCatalogo = 6 THEN	   
		-- Totales Sucursal
			FOREACH
				SELECT a.sucursal,
					   DECODE(a.tipo_dir,'1','Particular','2','Trabajo'),
					   COUNT(*) 
				  INTO cSucursal,
					   cTipoDir,
					   cCantidad
				  FROM bdinteg:si_bitacora_cambiosdom a
				 WHERE a.origen = 2
				   AND a.fecha BETWEEN pFechaIni AND pFechaFin
				 GROUP BY a.sucursal, a.tipo_dir
				 ORDER BY a.sucursal, 2
				 
					RETURN cCodRet,
						   cNombre,      
						   cNombreEstado,
						   cCiudad,      
						   cTdaMatriz,   
						   dFecha,       
						   cEmpleadoCob, 
						   cEmpleadoTda, 
						   cTipoDir,     
						   cCantidad,    
						   cNombreRegion,
						   cSucursal
					  WITH RESUME;			 
				 
			END FOREACH;	 
			 
			 IF cSucursal IS NULL THEN
			 
				LET cCodRet = "106"; -- No se encontró información
				
				RETURN cCodRet,
				       cNombre,      
				       cNombreEstado,
				       cCiudad,      
				       cTdaMatriz,   
				       dFecha,       
				       cEmpleadoCob, 
				       cEmpleadoTda, 
				       cTipoDir,     
				       cCantidad,    
			           cNombreRegion,
			           cSucursal
				  WITH RESUME;	
				  
			END IF;					 
	 
		ELIF pTipoCatalogo = 7 THEN	 
		-- Detallado Sucursal
			FOREACH
				SELECT TRIM(b.nombre1) || ' ' || TRIM(b.nombre2) || ' ' || TRIM(b.apell_paterno) || ' ' || TRIM(b.apell_materno),
					   e.nombre,
					   i.nombre,					   
					   s.tienda_matriz,
					   a.fecha,
					   a.usr_captura,
					   a.usr_autoriza,
					   DECODE(a.tipo_dir,'1','Particular','2','Trabajo')
				  INTO cNombre,
					   cNombreEstado,
					   cCiudad,					   
					   cTdaMatriz,
					   dFecha,  
					   cEmpleadoCob,				   
					   cEmpleadoTda,
					   cTipoDir
				  FROM bdinteg:si_bitacora_cambiosdom a,
					   bdinteg:si_cliente b,
					   bdinteg:si_estados e,
					   bdinteg:si_ciudades i,
					   bdinteg:si_sucursales s,
					   bdinteg:si_direcciones_actual d
				 WHERE a.cliente = b.numcte
				   AND i.estado = e.estado
				   AND d.numerociudad = i.ciudad_coppel
				   AND d.numcte = a.cliente
				   AND s.sucursal = a.sucursal
				   AND a.fecha BETWEEN pFechaIni AND pFechaFin
				   AND a.sucursal = pNumSucursal
				   
					RETURN cCodRet,
						   cNombre,      
						   cNombreEstado,
						   cCiudad,      
						   cTdaMatriz,   
						   dFecha,       
						   cEmpleadoCob, 
						   cEmpleadoTda, 
						   cTipoDir,     
						   cCantidad,    
						   cNombreRegion,
						   cSucursal
					  WITH RESUME;			 
				 
			END FOREACH;	 
			 
			 IF cNombre IS NULL THEN
			 
				LET cCodRet = "107"; -- No se encontró información
				
				RETURN cCodRet,
				       cNombre,      
				       cNombreEstado,
				       cCiudad,      
				       cTdaMatriz,   
				       dFecha,       
				       cEmpleadoCob, 
				       cEmpleadoTda, 
				       cTipoDir,     
				       cCantidad,    
			           cNombreRegion,
			           cSucursal
				  WITH RESUME;	
				  
			END IF;					   
			   
		ELIF pTipoCatalogo = 8 THEN
		-- Detallado Sucursal - Genera Excel (Todas las sucursales)
			FOREACH
				SELECT TRIM(b.nombre1) || ' ' || TRIM(b.nombre2) || ' ' || TRIM(b.apell_paterno) || ' ' || TRIM(b.apell_materno),
					   e.nombre,
					   i.nombre,					   
					   s.tienda_matriz,
					   a.fecha,
					   a.usr_captura,
					   a.usr_autoriza,
					   DECODE(a.tipo_dir,'1','Particular','2','Trabajo')
				  INTO cNombre,
					   cNombreEstado,
					   cCiudad,					   
					   cTdaMatriz,
					   dFecha,  
					   cEmpleadoCob,				   
					   cEmpleadoTda,
					   cTipoDir
				  FROM bdinteg:si_bitacora_cambiosdom a,
					   bdinteg:si_cliente b,
					   bdinteg:si_estados e,
					   bdinteg:si_ciudades i,
					   bdinteg:si_sucursales s,
					   bdinteg:si_direcciones_actual d
				 WHERE a.cliente = b.numcte
				   AND i.estado = e.estado
				   AND d.numerociudad = i.ciudad_coppel
				   AND d.numcte = a.cliente
				   AND s.sucursal = a.sucursal
				   AND a.fecha BETWEEN pFechaIni AND pFechaFin

					RETURN cCodRet,
						   cNombre,      
						   cNombreEstado,
						   cCiudad,      
						   cTdaMatriz,   
						   dFecha,       
						   cEmpleadoCob, 
						   cEmpleadoTda, 
						   cTipoDir,     
						   cCantidad,    
						   cNombreRegion,
						   cSucursal
					  WITH RESUME;			 
				 
			END FOREACH;	 
			 
			 IF cNombre IS NULL THEN
			 
				LET cCodRet = "108"; -- No se encontró información
				
				RETURN cCodRet,
				       cNombre,      
				       cNombreEstado,
				       cCiudad,      
				       cTdaMatriz,   
				       dFecha,       
				       cEmpleadoCob, 
				       cEmpleadoTda, 
				       cTipoDir,     
				       cCantidad,    
			           cNombreRegion,
			           cSucursal
				  WITH RESUME;	
				  
			END IF;			   
			   
		END IF;
				
	END
END PROCEDURE
DOCUMENT
'Consulta Clientes/Periodo, Tienda Matriz y Sucursales por Totales y Detallado',
'AUTOR: Nancy Sevilla Camacho',
'FECHA: 03/Mayo/2011',
'BD   : bdinteg',
'VER  : 1.0';

CREATE PROCEDURE "informix".sp_obtenersucursales(iTipoCatalogo INT)

--DATOS A REGRESAR---
RETURNING
CHAR(5),      -- Código de Retorno
CHAR(4),      -- Clave de la Sucursal
CHAR(40);     -- Nombre de la Sucursal
		
--DEFINICION DE VARIABLES--
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);	
---------------------------	
DEFINE cClave  CHAR(4);
DEFINE cNombre CHAR(40);

--INICIALIZACION DE VARIABLES--
LET iSqlErr = 0;
LET cCodRet = '000';
LET cClave  = '';
LET cNombre = '';
	
	--SET DEBUG FILE TO "/home/informix/sp_ObtenerSucursales.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,
					   cClave,
					   cNombre;
			END IF;
		END EXCEPTION;	  
		
-- Se realiza la consulta por Sucursales		
		IF iTipoCatalogo = 1 THEN
		
			-- Se realiza la búsqueda en la tabla de todas las sucursales de tipo "S" (Activas)	
			FOREACH		
				SELECT {+INDEX(si_sucursales idx_sucursal2)} sucursal, nombre
				  INTO cClave, cNombre		  
				  FROM bdinteg:si_sucursales
				 WHERE empresa = '001'
				   AND sucursal != '0000'				   
				   AND tpo_sucursal = 'S'
				 --ORDER BY sucursal	
				 
				RETURN cCodRet,
					   cClave,
					   cNombre	
				  WITH RESUME;		
				  
			END FOREACH;	 
							
			-- Se valida que se haya obtenido información
			IF cClave = '' AND cNombre = '' THEN
			
				LET cCodRet = '001';  -- No se encontró información
			
				RETURN cCodRet,
					   cClave,
					   cNombre	
				  WITH RESUME;
				  
			END IF;		

-- Se realiza la consulta por Tiendas Matriz
		ELSE
		
			-- Se realiza la búsqueda en la tabla de las tiendas matriz
			FOREACH		
				SELECT sucursal, nombre
				  INTO cClave, cNombre		  
				  FROM bdinteg:si_sucursales
				 WHERE tpo_sucursal = 'S'
				   AND tienda_matriz != 0
				 ORDER BY sucursal	
				 
				RETURN cCodRet,
					   cClave,
					   cNombre	
				  WITH RESUME;		
				  
			END FOREACH;	 
							
			-- Se valida que se haya obtenido información
			IF cClave = '' AND cNombre = '' THEN
			
				LET cCodRet = '001';  -- No se encontró información
			
				RETURN cCodRet,
					   cClave,
					   cNombre	
				  WITH RESUME;
				  
			END IF;			
		
		END IF;
					
	END
END PROCEDURE
DOCUMENT
'Se obtiene listado de Sucursales y Tiendas Matriz',
'FECHA: 20/Abril/2011',
'BD   : bdinteg',
'VER  : 1.0';

CREATE PROCEDURE "informix".sp_insert_autor_privacidad(pempresa CHAR(3), pnumcte CHAR(20), psucursal CHAR(4), 
                                                       prespuesta char(1), pmensaje VARCHAR(200))
   returning char(5);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNumCte CHAR(20);

LET iSqlErr = 0;
LET cCodRet = "00000";
LET cNumCte = '';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF iSqlErr <> 0 THEN
            RETURN iSqlErr;
        END IF;
    END EXCEPTION;

    IF pempresa = '' OR pempresa IS NULL THEN
       LET cCodRet = '00001';
       RETURN cCodRet;
    END IF;

    IF pnumcte = '' OR pnumcte IS NULL THEN
       LET cCodRet = '00001';
       RETURN cCodRet;
    END IF;

    IF psucursal = '' OR psucursal IS NULL THEN
       LET cCodRet = '00001';
       RETURN cCodRet;
    END IF;

    IF prespuesta = '' OR prespuesta IS NULL THEN
       LET cCodRet = '00001';
       RETURN cCodRet;
    END IF;

    IF pmensaje = '' OR pmensaje IS NULL THEN
       LET cCodRet = '00001';
       RETURN cCodRet;
    END IF;

    INSERT INTO si_autorizacion_privacidad(empresa,numcte,sucursal,respuesta,mensaje,fecha)
    VALUES (pempresa,pnumcte,psucursal,prespuesta,pmensaje,current);

RETURN cCodRet;

END
END PROCEDURE;