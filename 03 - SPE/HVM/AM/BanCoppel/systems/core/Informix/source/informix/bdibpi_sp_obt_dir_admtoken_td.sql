CREATE PROCEDURE "informix".sp_obt_dir_admtoken_td(pCliente char(9), pSecuencia integer )
   returning char(5), char(9), char(30), char(60), char(25), char(30), char(30), char(30), char(100), char(10), char(10), char(22), char(5),char(6),char(6),char(6),char(6),char(6),char(6),char(6),char(80),char(1);

--------------------------------------------------------------------------------------------
-- Folio: 1564 - ADMTokenGeneraGuias
-- Realizo: Manuel Ramos
-- Actividad: Se clona procedimiento almacenado "sp_obt_dir_admtoken" para que retorne el tipo direccion (tipo_dir) ya sea de la si_direcciones o si_direcciones_actual.
-- Solicito: Gabriela Aguilar
-- Fecha de Solicitud: 05/06/2015
-- BD: Bdibpi
---------------------------------------------------------------------------------------------
--Modifico: Hector Ramon Moreno Moreno
--Actividad: Se cambia campo vEmail a 100 caracteres.
--Fecha: 13-09-2016
--SolicitÃ³: Gabriela Aguilar
---------------------------------------------------------------------------------------------
-- ***************************************************************************
-- Define variables
-- ***************************************************************************
    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
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
	DEFINE vTipoDirActual 	char(1);
	
   

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
    LET cod_ret  = '000';

    --LET vSecuencia = 0;
    LET vCalle = '';
    LET vCalleCom = '';
    LET vNumExterior = '';
    LET vNumInterior = '';
    LET vColonia = '';
    LET vMunicipio = '';
    LET vCodPostal = '';
    LET vCiudad = '';
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
	LET vTipoDirActual ='';

	--SET DEBUG FILE TO "/informix/gaby/spl_obt_dir_admtoken_td.out";
	--TRACE ON;

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, pCliente, vEstado, vCiudad, vMunicipio, vColonia, vCalle,
                            vCalleCom, vEmail, vNumExterior, vNumInterior, vTelefono, vCodPostal,vManzana,vAndador,vEtapa,vLote,vEdificio,vEntrada,vOtros,vObservaciones,vTipoDir;
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
                TRIM(cd.nombre) as ciudad, -- Ciudad
                nvl(z.municipiozona, '') AS municipio,  -- Municipio / Delegacion
                nvl(z.nombrezona,'')    AS colonia, --Colonia
                nvl(c.nombrecalle,'')   AS calle, --Calle
                replace(nvl(d.entre_calles,''),',','-')   AS calle_com, --Calle_Complemento
               -- nvl(m.correo_elec,'')   AS email, --Email
                TRIM(d.numeroextcalle) AS numextcalle,   -- Numero exterior
                TRIM(d.numerointcalle) AS numintecalle,  -- Numero interior
                TRIM(d.departamento) AS depto,  -- Departamento
                --rpad(nvl(d.telefono1,''), 10, ' ') AS Telefono, --Telefono1
                --rpad(nvl(d.telefono2,''), 10, ' ') AS Telefono2, --Telefono2
                --rpad(nvl(d.telefono3,''), 10, ' ') AS Telefono3, --Telefono3
                lpad(TRIM(d.cod_postal),5,'0') AS cod_postal,     -- Codigo postal
				TRIM(NVL(d.tipo_dir, '')) as tipoDir	--Tipo direcciÃ³n
            INTO vEstado, vCiudad, vMunicipio, vColonia, vCalle, vCalleCom, /*vEmail,*/ vNumExterior, vNumInterior, vDepto, /*vTelefono, vTelefono2, vTelefono3,*/ vCodPostal, vTipoDirActual
            FROM bdinteg:"informix".si_cliente a
                LEFT OUTER JOIN bdinteg:"informix".si_direcciones_actual d ON (d.numcte = a.numcte)
                LEFT OUTER JOIN bdinteg:"informix".si_ciudades cd ON (cd.ciudad = d.ciudad) AND (cd.estado = d.estado)  and (cd.pais = d.pais)      
                LEFT OUTER JOIN bdinteg:"informix".si_estados e ON (e.estado = d.estado) and (e.pais = d.pais) 
                LEFT OUTER JOIN bdinteg:"informix".si_catzonas z ON (d.numerociudad = z.numerociudad AND d.numerocolonia = z.numerocolonia)
                LEFT OUTER JOIN bdinteg:"informix".si_catcalles c ON (d.numerocalle  = c.numerocalle)
                --LEFT OUTER JOIN bdinteg:si_ctepf cte ON (a.NumCte  = cte.numcte)
			--	LEFT OUTER JOIN bdinteg:"informix".si_correos m ON (a.numcte  = m.numcte) AND (m.status_correo = 'A')
            WHERE a.NumCte = pCliente
            AND nvl(d.tipo_dir,'') = TRIM(vTipoDir);
			
			LET vTipoDir = vTipoDirActual;
			
			SELECT FIRST 1 nvl(m.correo_elec,'') AS email --Email
			INTO vEmail
			FROM bdinteg:"informix".si_correos m 
			WHERE m.numcte=pCliente AND m.status_correo = 'A';
			

    ELIF vTipoDir = "3" THEN
             SELECT 
                rpad(TRIM(nvl(e.nombre,'')),30,' ') as estado, -- Estado
                TRIM(cd.nombre) as ciudad, -- Ciudad
                nvl(z.municipiozona, '') AS municipio,  -- Municipio / Delegacion
                nvl(z.NombreZona,'')    AS colonia, --Colonia
                nvl(c.nombrecalle,'')   AS calle, --Calle
                replace(nvl(d.entre_calles,''),',','-')   AS calle_com, --Calle_Complemento
                --nvl(m.correo_elec,'')   AS email, --Email
                TRIM(d.numeroextcalle) AS numextcalle,   -- Numero exterior
                TRIM(d.numerointcalle) AS numintecalle,  -- Numero interior
                TRIM(d.departamento) AS depto,  -- Departamento
                --rpad(nvl(d.telefono1,''), 10, ' ') AS Telefono, --Telefono1
                --rpad(nvl(d.telefono2,''), 10, ' ') AS Telefono2, --Telefono2
                --rpad(nvl(d.telefono3,''), 10, ' ') AS Telefono3, --Telefono3
                lpad(TRIM(d.cod_postal),5,'0') AS cod_postal     -- Codigo postal
             INTO vEstado, vCiudad, vMunicipio, vColonia, vCalle, vCalleCom, /*vEmail,*/ vNumExterior, vNumInterior, vDepto, /*vTelefono, vTelefono2, vTelefono3,*/ vCodPostal
             FROM bdinteg:"informix".si_cliente a
                 LEFT OUTER JOIN bdinteg:"informix".si_direcciones d ON (d.numcte = a.numcte)
                 LEFT OUTER JOIN bdinteg:"informix".si_ciudades cd ON (cd.ciudad = d.ciudad) AND (cd.estado = d.estado)  and (cd.pais = d.pais)      
                 LEFT OUTER JOIN bdinteg:"informix".si_estados e ON (e.estado = d.estado) and (e.pais = d.pais) 
                 LEFT OUTER JOIN bdinteg:"informix".si_catzonas z ON (d.numerociudad = z.numerociudad AND d.numerocolonia = z.numerocolonia)
                 LEFT OUTER JOIN bdinteg:"informix".si_catcalles c ON (d.numerocalle  = c.numerocalle)
                 --LEFT OUTER JOIN bdinteg:si_ctepf cte ON (a.NumCte  = cte.numcte)
				 -- LEFT OUTER JOIN bdinteg:"informix".si_correos m ON (m.numcte  = a.numcte) AND (m.status_correo = 'A')
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
                            vCalleCom, vEmail, vNumExterior, vNumInterior, vTel, vCodPostal,vManzana,vAndador,vEtapa,vLote,vEdificio,vEntrada,vOtros,vObservaciones,vTipoDir;

END

END PROCEDURE;