CREATE PROCEDURE "informix".sp_obt_dir_admtoken_web(pCliente char(9), pSecuencia integer )
   returning char(5), char(9), char(30), char(60), char(25), char(30), char(30), char(30), char(100), char(10), char(10), char(22), char(5),char(6),char(6),char(6),char(6),char(6),char(6),char(6),char(80),char(5);

--------------------------------------------------------------------------------------------
-- RealizÃ³: Pedro Enrique Zavala Valdez
-- Actividad: Obtiene la direcciÃ³n del cliente del AdmToken
-- SolicitÃ³: Mauricio LeÃ³n
-- Fecha de Solicitud: 09/11/2009
--11/03/2011 se modifica para obtener departamento y forzar a consultar domicilio mÃ¡s actual  IHM
--16/03/2011 Se modifica cuando el tipo de domicilio es 1 o 2 consulta la tabla si_direcciones_actual
--                      cuando es tipo 3 se consulta si_direcciones, se concatena el telefono y se cambia
--                      el tamaÃ±o del telefono a 22.   Saul Ivanhoe Valdespino Hernandez.       
-- Se modifica para que consulte los datos telÃ©fono y correo de las nuevas tablas si_telefonos_actual y si_correos. Viridiana Rosas.    
-- DIC 2012 

-- RealizÃ³: Jose Ruben Lopez
-- Actividad: Retorna datos adicionales para el domicilio
-- SolicitÃ³: Jose de Jesus Nevarez
-- Fecha de Solicitud: 19/08/2014  

-- Folio.........: 1557 - INC_AdmonToken
-- Autor.........: 95519203 - Ivan Garcia
-- Fecha.........: 04/02/2015 --DSB20140204
-- ModificaciÃ³n..: Se modifica para que cuando un cliente no cuente con domicilio, deje continuar el proceso del jar -- para la generacion masiva de guias.
-- Solicita......: Gabriela Aguilar Mendoza
-- BD............: Bdibpi       

-- Fecha.........: 05/01/2016 
-- ModificaciÃ³n..: Se modifica la consulta del correo.
-- Autor.........: 94362416 - AVF
---------------------------------------------------------------------------------------------
--Modifico: HÃ©ctor RamÃ³n Moreno Moreno
--Actividad: Se cambia campo vEmail a 100 caracteres.
--Fecha: 13-09-2016
--SolicitÃ³: Gabriela Aguilar
----------------------------------------------------------------------------------------------
--Modifico: Gabriela Aguilar
--Actividad: Se agrega un campo de retorno para obtener el id_estado para Logify.
--Fecha: 02-04-2018
---------------------------------------------------------------------------------------------

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
	DEFINE vid_estado char(5);
    DEFINE vEstado  char(30);
    DEFINE vCiudad char(60);
    DEFINE vMunicipio char(25);
    DEFINE vColonia char(30);
    DEFINE vCalle char(30);
    DEFINE vCalleCom char(30);
    DEFINE vEmail char(100);
    DEFINE vNumExterior char(10);
    DEFINE vNumInterior char(10);
    DEFINE vTelefono char(10);
    DEFINE vTelefono2 char(10);
    DEFINE vTelefono3 char(10);
    DEFINE vTel char(22);
    DEFINE vCodPostal char(5);
    DEFINE vDepto char(6);
    DEFINE vTipoDir char(1);
	--Datos Adicionales
	DEFINE vManzana 		CHAR(6);
	DEFINE vAndador 		CHAR(6);
	DEFINE vEtapa   		CHAR(6);
	DEFINE vLote    		CHAR(6);
	DEFINE vEdificio 		CHAR(6);
	DEFINE vEntrada			CHAR(6);
	DEFINE vOtros			CHAR(6);
	DEFINE vObservaciones 	CHAR(80);
	
   

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
    LET cod_ret  = '00000';

    --LET vSecuencia = 0;
    LET vCalle = '';
    LET vCalleCom = '';
    LET vNumExterior = '';
    LET vNumInterior = '';
    LET vColonia = '';
    LET vMunicipio = '';
    LET vCodPostal = '';
    LET vCiudad = '';
	LET vid_estado='';
    LET vEstado = '';
    LET vEmail = '';
    LET vDepto = '';
    LET vTipoDir = '';
    LET vTelefono = '';
    LET vTelefono2 = '';
    LET vTelefono3 = '';
    LET vTel = '';
	
	LET vManzana ='';
	LET vAndador ='';
	LET vEtapa ='';  
	LET vLote ='';
	LET vEdificio ='';
	LET vEntrada ='';
	LET vOtros ='';
	LET vObservaciones ='';

--SET DEBUG FILE TO "/tmp/sp_obt_dir_admtoken.out";
  --TRACE ON;

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, pCliente, vEstado, vCiudad, vMunicipio, vColonia, vCalle,
                            vCalleCom, vEmail, vNumExterior, vNumInterior, vTelefono, vCodPostal,vManzana,vAndador,vEtapa,vLote,vEdificio,vEntrada,vOtros,vObservaciones,vid_estado;
      END IF ;
   END EXCEPTION ;
   
  SET LOCK MODE TO WAIT 3;
  SET ISOLATION TO DIRTY READ;

   SELECT tipo_dir   INTO vTipoDir
        FROM bdinteg:si_direcciones
        WHERE numcte = pCliente
        AND nvl(secuencia,0) = pSecuencia;
        
   IF nvl(vTipoDir,'') = '' THEN
        LET vTipoDir = "1";
    END IF;
    
    IF vTipoDir = "1" OR vTipoDir = "2" THEN
           
            SELECT 
                rpad(TRIM(nvl(e.nombre,'')),30,' ') as estado, -- Estado
				TRIM(e.estado) as id_estado, --id Estado
                TRIM(cd.nombre) as ciudad, -- Ciudad
                nvl(z.municipiozona, '') AS municipio,  -- Municipio / Delegacion
                nvl(z.nombrezona,'')    AS colonia, --Colonia
                nvl(c.nombrecalle,'')   AS calle, --Calle
                replace(nvl(d.entre_calles,''),',','-')   AS calle_com, --Calle_Complemento                
                TRIM(d.numeroextcalle) AS numextcalle,   -- Numero exterior
                TRIM(d.numerointcalle) AS numintecalle,  -- Numero interior
                TRIM(d.departamento) AS depto,  -- Departamento
                --rpad(nvl(d.telefono1,''), 10, ' ') AS Telefono, --Telefono1
                --rpad(nvl(d.telefono2,''), 10, ' ') AS Telefono2, --Telefono2
                --rpad(nvl(d.telefono3,''), 10, ' ') AS Telefono3, --Telefono3
                lpad(TRIM(d.cod_postal),5,'0') AS cod_postal     -- Codigo postal
            INTO vEstado, vid_estado, vCiudad, vMunicipio, vColonia, vCalle, vCalleCom, vNumExterior, vNumInterior, vDepto, /*vTelefono, vTelefono2, vTelefono3,*/ vCodPostal
            FROM bdinteg:"informix".si_cliente a
                LEFT OUTER JOIN bdinteg:"informix".si_direcciones_actual d ON (d.numcte = a.numcte)
                LEFT OUTER JOIN bdinteg:"informix".si_ciudades cd ON (cd.ciudad = d.ciudad) AND (cd.estado = d.estado)  and (cd.pais = d.pais)      
                LEFT OUTER JOIN bdinteg:"informix".si_estados e ON (e.estado = d.estado) and (e.pais = d.pais) 
                LEFT OUTER JOIN bdinteg:"informix".si_catzonas z ON (d.numerociudad = z.numerociudad AND d.numerocolonia = z.numerocolonia)
                LEFT OUTER JOIN bdinteg:"informix".si_catcalles c ON (d.numerocalle  = c.numerocalle)
                --LEFT OUTER JOIN bdinteg:si_ctepf cte ON (a.NumCte  = cte.numcte)
				
            WHERE a.NumCte = pCliente
            AND nvl(d.tipo_dir,'') = TRIM(vTipoDir);
			
			SELECT FIRST 1 nvl(m.correo_elec,'') AS email --Email
				INTO vEmail
				FROM bdinteg:"informix".si_correos m 
				WHERE m.numcte=pCliente AND m.status_correo = 'A';

    ELIF vTipoDir = "3" THEN
             SELECT 
                rpad(TRIM(nvl(e.nombre,'')),30,' ') as estado, -- Estado
				TRIM(e.estado) as id_estado, --id Estado
                TRIM(cd.nombre) as ciudad, -- Ciudad
                nvl(z.municipiozona, '') AS municipio,  -- Municipio / Delegacion
                nvl(z.NombreZona,'')    AS colonia, --Colonia
                nvl(c.nombrecalle,'')   AS calle, --Calle
                replace(nvl(d.entre_calles,''),',','-')   AS calle_com, --Calle_Complemento                
                TRIM(d.numeroextcalle) AS numextcalle,   -- Numero exterior
                TRIM(d.numerointcalle) AS numintecalle,  -- Numero interior
                TRIM(d.departamento) AS depto,  -- Departamento
                --rpad(nvl(d.telefono1,''), 10, ' ') AS Telefono, --Telefono1
                --rpad(nvl(d.telefono2,''), 10, ' ') AS Telefono2, --Telefono2
                --rpad(nvl(d.telefono3,''), 10, ' ') AS Telefono3, --Telefono3
                lpad(TRIM(d.cod_postal),5,'0') AS cod_postal     -- Codigo postal
             INTO vEstado, vid_estado, vCiudad, vMunicipio, vColonia, vCalle, vCalleCom, vNumExterior, vNumInterior, vDepto, /*vTelefono, vTelefono2, vTelefono3,*/ vCodPostal
             FROM bdinteg:"informix".si_cliente a
                 LEFT OUTER JOIN bdinteg:"informix".si_direcciones d ON (d.numcte = a.numcte)
                 LEFT OUTER JOIN bdinteg:"informix".si_ciudades cd ON (cd.ciudad = d.ciudad) AND (cd.estado = d.estado)  and (cd.pais = d.pais)      
                 LEFT OUTER JOIN bdinteg:"informix".si_estados e ON (e.estado = d.estado) and (e.pais = d.pais) 
                 LEFT OUTER JOIN bdinteg:"informix".si_catzonas z ON (d.numerociudad = z.numerociudad AND d.numerocolonia = z.numerocolonia)
                 LEFT OUTER JOIN bdinteg:"informix".si_catcalles c ON (d.numerocalle  = c.numerocalle)
                 --LEFT OUTER JOIN bdinteg:si_ctepf cte ON (a.NumCte  = cte.numcte)				 
             WHERE a.NumCte = pCliente
             AND nvl(d.secuencia,0) = pSecuencia;
			 
			 SELECT FIRST 1 nvl(m.correo_elec,'') AS email --Email
				INTO vEmail
				FROM bdinteg:"informix".si_correos m 
				WHERE m.numcte=pCliente AND m.status_correo = 'A';


    END IF;

    -- IF (vEstado == "") THEN --DSB20140204
	 IF (NVL(vEstado,'')) = '' THEN --DSB20140204
           LET cod_ret = '001'; -- No se encontro el domicilio
     END IF;

      IF TRIM(NVL(vDepto, '')) <> '' THEN
           LET vNumInterior = TRIM(vNumInterior) || "-" || TRIM(vDepto);
      END IF;

                    --CONSULTA LOS NUEVOS TELEFONOS
      LET vTelefono = '';
      LET vTelefono2 = '';
      LET vTelefono3 = '';

      SELECT telefono INTO vTelefono ---TELEFONO PARTICULAR
      FROM bdinteg:"informix".si_telefonos_actual
      WHERE numcte = pCliente AND tipo_tel = 1;

      SELECT telefono INTO vTelefono2  ---TELEFONO CELULAR
      FROM bdinteg:"informix".si_telefonos_actual
      WHERE numcte = pCliente AND tipo_tel = 2;

      SELECT telefono  INTO vTelefono3 ---TELEFONO TRABAJO
      FROM bdinteg:"informix".si_telefonos_actual
      WHERE numcte = pCliente AND tipo_tel = 3;



      IF (vTelefono <> "") AND  (vTelefono2 <> "") THEN
            LET vTel = vTelefono || "-" || vTelefono2;
      ELIF (vTelefono <> "") AND  (vTelefono3 <> "") THEN
                 LET vTel = vTelefono || "-" || vTelefono3;
      ELIF (vTelefono2 <> "") AND  (vTelefono3 <> "") THEN
                  LET vTel = vTelefono2 || "-" || vTelefono3;
      ELIF (vTelefono <> "") THEN
                  LET vTel = vTelefono;
      ELIF (vTelefono2 <> "") THEN
                  LET vTel = vTelefono2;
      ELIF (vTelefono3 <> "") THEN
                  LET vTel = vTelefono3;
      END IF;
	  
	--Obteniendo datos adicionales para el domicilio
	SELECT 'Mz ' || nvl(manzana,'') , 'Ot ' || nvl(otros,''), 'An ' || nvl(andador,''), 'Et' || nvl(etapa,''), 'Lt ' || nvl(lote,''), 'Ed ' || nvl(edificio,''), 'En ' || nvl(entrada,''), '' || nvl(observaciones,'') 
	INTO vManzana, vOtros, vAndador, vEtapa, vLote, vEdificio, vEntrada, vObservaciones
	FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = pCliente AND unidadhabitac = 'S' AND nvl(tipo_dir,'') = TRIM(vTipoDir);
			
   RETURN cod_ret, pCliente, vEstado, vCiudad, vMunicipio, vColonia, vCalle,
                            vCalleCom, vEmail, vNumExterior, vNumInterior, vTel, vCodPostal,vManzana,vAndador,vEtapa,vLote,vEdificio,vEntrada,vOtros,vObservaciones,vid_estado;

END

END PROCEDURE;