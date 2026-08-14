CREATE PROCEDURE "informix".sp_consultarinfocrediticia(pEmpresa CHAR(3),pNumCte  VARCHAR(20),pTpDirec INTEGER)
														   
--DATOS A REGRESAR---
RETURNING CHAR(5)        AS codigo_retorno,
          -- Datos Generales del Cliente
          CHAR(20)       AS numero_cliente,
          CHAR(26)       AS apell_paterno,
          CHAR(26)       AS apell_materno,
          CHAR(26)       AS nombre_1,
          CHAR(26)       AS nombre_2,
          CHAR(13)       AS rfc,
          CHAR(20)       AS NumCteCoppel,
          DATE           AS fecha_nacimiento,
          -- Domicilio de Casa y Teléfonos
          CHAR(30)       AS estado,
          CHAR(30)       AS ciudad,
          CHAR(30)       AS colonia,
          CHAR(30)       AS calle,
          CHAR(27)       AS municipio,
          CHAR(5)        AS cod_postal,
          CHAR(13)       AS telefono1,
          CHAR(13)       AS telefono2,
          CHAR(13)       AS telefono3,
          CHAR(10)       AS numeroextcalle,
          CHAR(10)       AS numerointcalle,
          CHAR(100)      AS correo_electronico,
          -- Información Crediticia
          INTEGER        AS antiguedad_cuenta,
          DATE           AS fecha_apertura,
          DECIMAL(18,2)  AS linea_credito,
          MONEY(14,2)    AS ingreso_mensual,
          DATE           AS fecha_solicitud_incremento,
          DECIMAL(14,2)  AS salario_minimo_base;
		 
--DEFINICIÓN DE VARIABLES--
DEFINE iSqlErr             INTEGER;
DEFINE iIsamErr            INTEGER;
DEFINE cErrorInfo          CHAR(80);
DEFINE cCodRet             CHAR(5);
DEFINE iRows               INTEGER;
------------------------------------

-- Datos Generales del Cliente
DEFINE cNumCte             CHAR(20);
DEFINE cApellPat           CHAR(26);
DEFINE cApellMat           CHAR(26);
DEFINE cNom1               CHAR(26);
DEFINE cNom2               CHAR(26);
DEFINE cRFC                CHAR(13);
DEFINE dtFechaNac          DATE;
DEFINE cNumCteCoppel       CHAR(20);

-- Domicilio de Casa y Teléfonos
DEFINE cTipo_dir        CHAR(1);
DEFINE cCalle           CHAR(40);
DEFINE cColonia         CHAR(60);
DEFINE cEstado          CHAR(2);
DEFINE cCiudad          CHAR(3);
DEFINE cMunicipio       CHAR(5);
DEFINE cCod_postal      CHAR(5);
DEFINE cTelefono1       CHAR(13);
DEFINE cTelefono2       CHAR(13);
DEFINE cTelefono3       CHAR(13);
DEFINE sNumerociudad    SMALLINT ;
DEFINE iNumerocalle     INT;
DEFINE iNumerocolonia   INT;
DEFINE cNumeroextcalle  CHAR(10);
DEFINE cNumerointcalle  CHAR(10);
DEFINE cNomEdo          CHAR(30);
DEFINE cNomCiudad       CHAR(30);
DEFINE cNomColonia      CHAR(30);
DEFINE cNomCalle        CHAR(30);
DEFINE cNomMunicipio    CHAR(27);
DEFINE cPais            CHAR(3);
DEFINE cCorreoElect     CHAR(100);

-- Información Crediticia
DEFINE dtFechaHoy          DATE;
DEFINE cNumCredito         CHAR(20);
DEFINE dtFechaApertura     DATE;
DEFINE iAntiguedadMeses    INTEGER;
DEFINE dMontoOtorgado      DECIMAL(18,2);
DEFINE mIngresoMensual     MONEY(14,2);
DEFINE dSalarioMin         DECIMAL(14,2);

--INICIALIZACIÓN DE VARIABLES--
LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = "Proceso exitoso";
LET cCodRet               = "00000";
LET iRows                 = 0;

-- Datos Generales del Cliente
LET cNumCte                = "";
LET cApellPat              = "";
LET cApellMat              = "";
LET cNom1                  = "";
LET cNom2                  = "";
LET cRFC                   = "";
LET dtFechaNac             = DATE(1);
LET cNumCteCoppel          = "";

-- Domicilio de Casa y Teléfonos
LET cTipo_dir          = "";
LET cCalle             = "";
LET cColonia           = "";
LET cEstado            = "";
LET cCiudad            = "";
LET cMunicipio         = "";
LET cCod_postal        = "";
LET cTelefono1         = "";
LET cTelefono2         = "";
LET cTelefono3         = "";
LET sNumerociudad      = 0;
LET iNumerocalle       = 0;
LET iNumerocolonia     = 0;
LET cNumeroextcalle    = "";
LET cNumerointcalle    = "";
LET cNomEdo            = '';
LET cNomCiudad         = '';
LET cNomColonia        = '';
LET cNomCalle          = '';
LET cNomMunicipio      = "";
LET cPais              = "001";
LET cCorreoElect       = "";

-- Información Crediticia
LET dtFechaHoy             = DATE(1);
LET cNumCredito            = "";
LET dtFechaApertura        = DATE(1);
LET iAntiguedadMeses       = 0;
LET dMontoOtorgado         = 0;
LET mIngresoMensual        = 0;
LET dSalarioMin            = 0;

-- INICIO DEL PROCEDIMIENTO
BEGIN 

	-- MANEJADOR DE ERRORES
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
		  LET cCodRet= iSqlErr;
		   RETURN cCodRet, cNumCte, cApellPat, cApellMat, cNom1, cNom2, cRFC, cNumCteCoppel, dtFechaNac,
				  cNomEdo, cNomCiudad, cNomColonia, cNomCalle, cNomMunicipio, cCod_postal, NVL(cTelefono1,''), 
				   NVL(cTelefono2,''), NVL(cTelefono3,''), cNumeroextcalle, cNumerointcalle, NVL(cCorreoElect,''), 
				  NVL(iAntiguedadMeses,0), NVL(dtFechaApertura,DATE(1)), NVL(dMontoOtorgado,0), 
				  NVL(mIngresoMensual,0), NVL(dtFechaHoy,DATE(1)), NVL(dSalarioMin,0);
		END IF;
			
	END EXCEPTION;
		  
	--SET DEBUG FILE TO '/tmp/sp_consultarinfocrediticia_ofi.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 10;
	
	-- Se valida que los parámetros de entrada no vengan vacíos
	IF NVL(pNumCte,"") = "" OR NVL(pEmpresa,"") = "" THEN 
		-- Parámetros de entrada vacíos
		LET cCodRet = "00001";
	   RETURN cCodRet, cNumCte, cApellPat, cApellMat, cNom1, cNom2, cRFC, cNumCteCoppel, dtFechaNac,
	          cNomEdo, cNomCiudad, cNomColonia, cNomCalle, cNomMunicipio, cCod_postal, NVL(cTelefono1,''), 
			  NVL(cTelefono2,''), NVL(cTelefono3,''), cNumeroextcalle, cNumerointcalle, NVL(cCorreoElect,''), 
	          NVL(iAntiguedadMeses,0), NVL(dtFechaApertura,DATE(1)), NVL(dMontoOtorgado,0), 
			  NVL(mIngresoMensual,0), NVL(dtFechaHoy,DATE(1)), NVL(dSalarioMin,0);		  
			  
	END IF;
	
	
	--- DATOS GENERALES DEL CLIENTE
	
    -- Se obtiene la información del cliente
	SELECT a.numcte, 
	       apell_paterno, 
		   apell_materno, 
		   nombre1, 
		   nombre2, 
		   a.rfc, 
		   a.numcte_ref,
		   b.fecha_nac
	  INTO cNumCte, 
	       cApellPat, 
		   cApellMat, 
		   cNom1, 
		   cNom2, 
		   cRFC, 
		   cNumCteCoppel,
		   dtFechaNac
	  FROM bdinteg:"informix".si_cliente a,
		   bdinteg:"informix".si_ctepf b
	 WHERE a.numcte = b.numcte
	   AND b.numcte = pNumCte;
	   
		LET iRows = DBINFO("sqlca.sqlerrd2");
		IF iRows = 0 THEN
		   -- No se encontraron Clientes.
		   LET cCodRet= '00002';
		   RETURN cCodRet, cNumCte, cApellPat, cApellMat, cNom1, cNom2, cRFC, cNumCteCoppel, dtFechaNac,
				  cNomEdo, cNomCiudad, cNomColonia, cNomCalle, cNomMunicipio, cCod_postal, NVL(cTelefono1,''), 
				  NVL(cTelefono2,''), NVL(cTelefono3,''), cNumeroextcalle, cNumerointcalle, NVL(cCorreoElect,''), 
				  NVL(iAntiguedadMeses,0), NVL(dtFechaApertura,DATE(1)), NVL(dMontoOtorgado,0), 
				  NVL(mIngresoMensual,0), NVL(dtFechaHoy,DATE(1)), NVL(dSalarioMin,0);
		END IF;
		
		
    --- DOMICILIO DE CASA Y TELÉFONOS
		
	-- Se obtiene el domicilio de casa y teléfonos
	SELECT tipo_dir, 
	       calle, 
		   colonia, 
		   estado, 
		   ciudad,
		   municipio, 
		   cod_postal, 
		 --  telefono1, 
--		   telefono2,
		   --telefono3,
		   numerociudad,
		   numeroextcalle, 
		   numerointcalle, 
		   numerocalle, 
		   numerocolonia
	  INTO cTipo_dir, 
	       cCalle, 
		   cColonia, 
		   cEstado, 
		   cCiudad, 
		   cMunicipio, 
		   cCod_postal, 
		--   cTelefono1, 
		 -- - cTelefono2, 
		   --cTelefono3, 
		   sNumerociudad,
		   cNumeroextcalle, 
		   cNumerointcalle, 
		   iNumerocalle, 
		   iNumerocolonia
	  FROM bdinteg:"informix".si_direcciones_actual
	 WHERE numcte   = pNumCte            
	   AND tipo_dir = pTpDirec;	
	      
		LET iRows = DBINFO("sqlca.sqlerrd2");
		IF iRows = 0 THEN
		   -- No se encontraron datos del domicilio del cliente.
		   LET cCodRet= '00003';
		   RETURN cCodRet, cNumCte, cApellPat, cApellMat, cNom1, cNom2, cRFC, cNumCteCoppel, dtFechaNac,
				  cNomEdo, cNomCiudad, cNomColonia, cNomCalle, cNomMunicipio, cCod_postal, NVL(cTelefono1,''), 
				  NVL(cTelefono2,''), NVL(cTelefono3,''), cNumeroextcalle, cNumerointcalle, NVL(cCorreoElect,''), 
				  NVL(iAntiguedadMeses,0), NVL(dtFechaApertura,DATE(1)), NVL(dMontoOtorgado,0), 
				  NVL(mIngresoMensual,0), NVL(dtFechaHoy,DATE(1)), NVL(dSalarioMin,0);
		END IF;	   

		-- Se Obtienen los Teléfono del cliente.
		SELECT  telefono
		  INTO  cTelefono1
		  FROM bdinteg:"informix".si_telefonos_actual
		 WHERE numcte = pNumCte
           AND tipo_tel = '1'
		   AND status_tel = 'A';

         SELECT  telefono
		  INTO  cTelefono2 
		  FROM bdinteg:"informix".si_telefonos_actual
		 WHERE numcte = pNumCte   
          AND tipo_tel = '2'
		  AND status_tel = 'A';

        SELECT  telefono
		  INTO  cTelefono3
		  FROM bdinteg:"informix".si_telefonos_actual
		 WHERE numcte = pNumCte
          AND tipo_tel = '3'
		  AND status_tel = 'A';
        
	   -- Se obtiene Nombre del Estado
        SELECT TRIM(nombre) 
          INTO cNomEdo 
          FROM bdinteg:"informix".si_estados
         WHERE pais   = cPais
		   AND estado = cEstado;
		 
		IF NVL(cNomEdo,"") = "" THEN 
		   -- No se encontró el Nombre del Estado 
		   LET cCodRet  = "00004";
		   RETURN cCodRet, cNumCte, cApellPat, cApellMat, cNom1, cNom2, cRFC, cNumCteCoppel, dtFechaNac,
				  cNomEdo, cNomCiudad, cNomColonia, cNomCalle, cNomMunicipio, cCod_postal, NVL(cTelefono1,''), 
				  NVL(cTelefono2,''), NVL(cTelefono3,''), cNumeroextcalle, cNumerointcalle, NVL(cCorreoElect,''), 
				  NVL(iAntiguedadMeses,0), NVL(dtFechaApertura,DATE(1)), NVL(dMontoOtorgado,0), 
				  NVL(mIngresoMensual,0), NVL(dtFechaHoy,DATE(1)), NVL(dSalarioMin,0);
		END IF;		 

		-- Se obtiene Nombre de la Ciudad
        SELECT TRIM(nombre)
          INTO cNomCiudad
          FROM bdinteg:"informix".si_ciudades
         WHERE estado = cEstado 
           AND ciudad = cCiudad;
		   
		IF NVL(cNomCiudad,"") = "" THEN 
		   -- No se encontró el Nombre de la Ciudad
		   LET cCodRet  = "00005";
		   RETURN cCodRet, cNumCte, cApellPat, cApellMat, cNom1, cNom2, cRFC, cNumCteCoppel, dtFechaNac,
				  cNomEdo, cNomCiudad, cNomColonia, cNomCalle, cNomMunicipio, cCod_postal, NVL(cTelefono1,''), 
				  NVL(cTelefono2,''), NVL(cTelefono3,''), cNumeroextcalle, cNumerointcalle, NVL(cCorreoElect,''), 
				  NVL(iAntiguedadMeses,0), NVL(dtFechaApertura,DATE(1)), NVL(dMontoOtorgado,0), 
				  NVL(mIngresoMensual,0), NVL(dtFechaHoy,DATE(1)), NVL(dSalarioMin,0);
		END IF;			   

		-- Se obtiene el Nombre de la Colonia
        SELECT TRIM(nombrezona) 
          INTO cNomColonia 
          FROM bdinteg:"informix".si_catzonas
         WHERE numerociudad = sNumerociudad 
           AND numerocolonia = iNumerocolonia;
		   
		IF NVL(cNomColonia,"") = "" THEN 
		   -- No se encontró el Nombre de la Colonia
		   LET cCodRet  = "00006";
		   RETURN cCodRet, cNumCte, cApellPat, cApellMat, cNom1, cNom2, cRFC, cNumCteCoppel, dtFechaNac,
				  cNomEdo, cNomCiudad, cNomColonia, cNomCalle, cNomMunicipio, cCod_postal, cTelefono1, 
				  cTelefono2, NVL(cTelefono3,''), cNumeroextcalle, cNumerointcalle, NVL(cCorreoElect,''), 
				  NVL(iAntiguedadMeses,0), NVL(dtFechaApertura,DATE(1)), NVL(dMontoOtorgado,0), 
				  NVL(mIngresoMensual,0), NVL(dtFechaHoy,DATE(1)), NVL(dSalarioMin,0);
		END IF;			   

		-- Se obtiene el Nombre de la Calle
        SELECT TRIM(nombrecalle) 
          INTO cNomCalle 
          FROM bdinteg:"informix".si_catcalles
         WHERE numerocalle = iNumerocalle;
		 
		IF NVL(cNomCalle,"") = "" THEN 
		   -- No se encontró el Nombre de la Calle
		   LET cCodRet  = "00007";
		   RETURN cCodRet, cNumCte, cApellPat, cApellMat, cNom1, cNom2, cRFC, cNumCteCoppel, dtFechaNac,
				  cNomEdo, cNomCiudad, cNomColonia, cNomCalle, cNomMunicipio, cCod_postal, NVL(cTelefono1,''), 
				  NVL(cTelefono2,''), NVL(cTelefono3,''), cNumeroextcalle, cNumerointcalle, NVL(cCorreoElect,''), 
				  NVL(iAntiguedadMeses,0), NVL(dtFechaApertura,DATE(1)), NVL(dMontoOtorgado,0), 
				  NVL(mIngresoMensual,0), NVL(dtFechaHoy,DATE(1)), NVL(dSalarioMin,0);
		END IF;			 

        IF TRIM(cMunicipio) ='00000' THEN     
            LET CMunicipio  = "";     

			-- Se obtiene el Nombre del municipio si en la tabla si_direcciones_actual no se encontró
            SELECT TRIM(municipiozona) 
              INTO cNomMunicipio 
              FROM bdinteg:"informix".si_catzonas
             WHERE numerociudad = sNumerociudad 
               AND numerocolonia  = iNumerocolonia;
			   
			IF NVL(cNomMunicipio,"") = "" THEN 
			   -- No se encontró el Nombre del municipio
			   LET cCodRet  = "00008";
			   RETURN cCodRet, cNumCte, cApellPat, cApellMat, cNom1, cNom2, cRFC, cNumCteCoppel, dtFechaNac,
					  cNomEdo, cNomCiudad, cNomColonia, cNomCalle, cNomMunicipio, cCod_postal, NVL(cTelefono1,''), 
				      NVL(cTelefono2,''), NVL(cTelefono3,''), cNumeroextcalle, cNumerointcalle, NVL(cCorreoElect,''), 
					  NVL(iAntiguedadMeses,0), NVL(dtFechaApertura,DATE(1)), NVL(dMontoOtorgado,0), 
					  NVL(mIngresoMensual,0), NVL(dtFechaHoy,DATE(1)), NVL(dSalarioMin,0);
			END IF;				   
			   
        ELSE
            LET cNomMunicipio = cNomCiudad;     
        END IF; 	   

		-- Se obtiene el Correo Electronico del Cliente.
		SELECT correo_elec INTO cCorreoElect
		FROM bdinteg:"informix".si_correos 
		WHERE empresa = pEmpresa AND numcte = pNumCte AND status_correo = 'A' 
		AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos WHERE empresa = pEmpresa AND numcte = pNumCte);
		
		IF NVL(cCorreoElect,"") = "" THEN 
			LET cCorreoElect = "";
		END IF;
	
	
		--- INFORMACIÓN CREDITICIA

		-- Fecha de solicitud de incremento
		SELECT fecha_hoy 
		  INTO dtFechaHoy
		  FROM bdicred:"informix".sd_fechas
		 WHERE empresa = pEmpresa;
		 
		IF NVL(dtFechaHoy,"") = "" THEN 
		   -- No se encontró la Fecha de solicitud de incremento
		   LET cCodRet  = "00009";
		   RETURN cCodRet, cNumCte, cApellPat, cApellMat, cNom1, cNom2, cRFC, cNumCteCoppel, dtFechaNac,
				  cNomEdo, cNomCiudad, cNomColonia, cNomCalle, cNomMunicipio, cCod_postal, NVL(cTelefono1,''), 
				  NVL(cTelefono2,''), NVL(cTelefono3,''), cNumeroextcalle, cNumerointcalle, NVL(cCorreoElect,''), 
				  NVL(iAntiguedadMeses,0), NVL(dtFechaApertura,DATE(1)), NVL(dMontoOtorgado,0), 
				  NVL(mIngresoMensual,0), NVL(dtFechaHoy,DATE(1)), NVL(dSalarioMin,0);
		END IF;				 
	 
	   -- Antigüedad de la Cuenta, Fecha Apertura
		FOREACH WITH HOLD
			SELECT LIMIT 1 num_credito,fecha_apertura, 
			               ((YEAR(TODAY) - YEAR(fecha_apertura)) * 12) + (MONTH(TODAY) - MONTH(fecha_apertura)) - CASE WHEN DAY(TODAY) > DAY(fecha_apertura) THEN 0 ELSE 1 END
			INTO cNumCredito, dtFechaApertura, iAntiguedadMeses
			FROM bdicred:"informix".sd_maecred
			WHERE numcte = pNumCte
			ORDER BY fecha_apertura DESC
		END FOREACH;
	
		
		IF NVL(cNumCredito,"") = "" OR NVL(dtFechaApertura,"") = "" OR NVL(iAntiguedadMeses,"") = "" THEN 
		   -- No se encontró la Antigüedad de la Cuenta o Fecha Apertura
		   LET cCodRet  = "00010";
		   RETURN cCodRet, cNumCte, cApellPat, cApellMat, cNom1, cNom2, cRFC, cNumCteCoppel, dtFechaNac,
				  cNomEdo, cNomCiudad, cNomColonia, cNomCalle, cNomMunicipio, cCod_postal, NVL(cTelefono1,''), 
				  NVL(cTelefono2,''), NVL(cTelefono3,''), cNumeroextcalle, cNumerointcalle, NVL(cCorreoElect,''), 
				  NVL(iAntiguedadMeses,0), NVL(dtFechaApertura,DATE(1)), NVL(dMontoOtorgado,0), 
				  NVL(mIngresoMensual,0), NVL(dtFechaHoy,DATE(1)), NVL(dSalarioMin,0);
		END IF;		
		
		-- Línea de Crédito
		SELECT monto_otorgado
		  INTO dMontoOtorgado
		  FROM bdicred:"informix".sd_maesdos 
		 WHERE num_credito = cNumCredito
		   AND empresa     = pEmpresa;
		   
		   IF dMontoOtorgado IS NULL THEN 
			 LET dMontoOtorgado = 0;
		   END IF;

		-- Ingreso mensual
		SELECT ingreso_mensual 
		  INTO mIngresoMensual
		  FROM bdisolic:"informix".ss_resum_scor_fin
		 WHERE empresa       = pEmpresa
		   AND num_solicitud = cNumCredito;
		   
		   IF mIngresoMensual IS NULL THEN 
			  LET mIngresoMensual = 0;
		   END IF;

	   -- Salario mínimo
	   SELECT valor
		 INTO dSalarioMin
		 FROM bdisolic:"informix".ss_param
		WHERE empresa   = pEmpresa
		  AND secuencia = 303;
			  
		   IF dSalarioMin IS NULL OR dSalarioMin < 0 THEN 
			   -- El Salario Mínimo Base no es válido
			   LET cCodRet  = "00011";
			   RETURN cCodRet, cNumCte, cApellPat, cApellMat, cNom1, cNom2, cRFC, cNumCteCoppel, dtFechaNac,
					  cNomEdo, cNomCiudad, cNomColonia, cNomCalle, cNomMunicipio, cCod_postal, NVL(cTelefono1,''), 
				      NVL(cTelefono2,''), NVL(cTelefono3,''), cNumeroextcalle, cNumerointcalle, NVL(cCorreoElect,''), 
					  NVL(iAntiguedadMeses,0), NVL(dtFechaApertura,DATE(1)), NVL(dMontoOtorgado,0), 
					  NVL(mIngresoMensual,0), NVL(dtFechaHoy,DATE(1)), NVL(dSalarioMin,0);
		   END IF;

	   RETURN cCodRet, cNumCte, cApellPat, cApellMat, cNom1, cNom2, cRFC, cNumCteCoppel, dtFechaNac,
			  cNomEdo, cNomCiudad, cNomColonia, cNomCalle, cNomMunicipio, cCod_postal, NVL(cTelefono1,''), 
		      NVL(cTelefono2,''), NVL(cTelefono3,''), cNumeroextcalle, cNumerointcalle, NVL(cCorreoElect,''), 
			  NVL(iAntiguedadMeses,0), NVL(dtFechaApertura,DATE(1)), NVL(dMontoOtorgado,0), 
			  NVL(mIngresoMensual,0), NVL(dtFechaHoy,DATE(1)), NVL(dSalarioMin,0);
	   
END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para realizar la consulta de la información del cliente                       ',
'que muestre los datos requeridos para la solicitud de incremento de línea de crédito                   ',
'AUTOR : Nancy Sevilla Camacho                                                                          ',
'FECHA : 19/10/2011                                                                                     ',
'BD    : BDIINTEG                                                                                       ',
'                                                                                                       ',
'MODIFICA    : Martín Eduardo Miranda                                                                   ',
'FECHA       : 09 de Julio 2012                                                                         ',
'DESCRIPCIÓN : Se modifica Procedimiento Almacenado para que regrese el Teléfono de oficina del Cliente ',
'              para en el caso de que el Cliente consultado haya proporcionado el mismo.                ',
'																										',
'MODIFICA    : Martín Eduardo Miranda																	',
'FECHA       : 20 de Septiempre 2012																	',
'DESCRIPCIÓN : Se modifica procecedimiento almacenado para que valide la fecha_apertura para evitar que ',
'              se presente el error de informix "-284", al momento de que se consulte el num_credito.   ',
'			  * Se cambia procedimiento de la Base de Datos "BDINTEG" a "BDICRED".                      ',
'BD          : BDICRED 																					',
'																										',
'MODIFICA    : Rodolfo Tortolero Varela																	',
'FECHA       : 07 de Enero 2013																	        ',
'DESCRIPCIÓN : Se modifica procecedimiento almacenado para obtener el correo electronico del cliente,   ',
'              obtiene el campo correo_elec de la tabla bdinteg: si_correos y que status_correo sea A.  ',
'              Se agrega un parametro mas de salida.                                                    ',
'BD          : BDICRED 																					';

CREATE PROCEDURE "informix".sp_actualiza_indicadorcred()

returning
          char(06) as resultado,
          char(80) as mensaje;

define Sql_error                              integer;
define vEmpresa                               char(3);
define vNumproceso                            char(4);
define cCodRet                                char(6);
define vHora                                  char(8);
define vMes                                   char(12);
define vNumcredito                            char(20);
define iCodRet, isam_err                      integer;
define cMensajeRet, cMensajeBita, error_info  char(80);
define vfecha, df_primer_compra               date;

define vmonto_primer_compra                   decimal(18,2);


let Sql_error = 0;
let cCodRet = '000000';
let iCodRet = 0;
let cMensajeRet = 'EL PROCESO SE REALIZÓ EXITOSAMENTE';
let vfecha = date(1);
let vMes = '';                let vNumcredito = '';
let vNumproceso = '0051';     let vHora = '';
let isam_err = 0;             let error_info = '';
let cMensajeBita = '';        let vEmpresa = '001';

BEGIN
    ON EXCEPTION SET iCodRet, isam_err, error_info
            IF iCodRet <> 0 THEN
            let cCodRet = iCodRet;
            let cMensajeRet = error_info;

            --SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora from sysmaster:sysshmvals;
            --INSERT INTO "informix".sd_bitacora_mec(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert) 
            --     VALUES(vEmpresa, vNumproceso, today, cCodRet, cMensajeRet, 'informix', today, vHora);
            
            return cCodRet,cMensajeRet ;
        end if;
    end exception;

  --Set debug file to "/informix/macf/sp_actualiza_indicadorcred.trc";
  --Trace on;
  
  --SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora from sysmaster:sysshmvals;
  --INSERT INTO "informix".sd_bitacora_mec(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert) 
  --    VALUES(vEmpresa, vNumproceso, today, cCodRet, 'Proceso Inicializado', 'informix', today, vHora);


  SET ISOLATION TO dirty READ;
  SELECT num_credito, 
         nvl(f_primer_compra, date(1)) as f_primer_compra, 
         nvl(monto_primer_compra,0) as monto_primer_compra
    FROM bdicred:sd_indicador_cred
   WHERE empresa = vEmpresa
     AND nvl(f_primer_compra, date(1)) <> date(1)
     AND nvl(fecha_ultima_compra,date(1)) = date(1)
     INTO temp paso_compras with no log;

  CREATE UNIQUE INDEX inx_paso_compras ON paso_compras(num_credito);
  
  UPDATE statistics medium FOR TABLE paso_compras; 

  FOREACH WITH HOLD
      SELECT num_credito, f_primer_compra, monto_primer_compra
        INTO vNumcredito, df_primer_compra, vmonto_primer_compra
        FROM paso_compras
        
        BEGIN WORK;
              UPDATE bdicred:sd_indicador_cred
                 SET fecha_ultima_compra = df_primer_compra , monto_ultima_compra = vmonto_primer_compra
                WHERE empresa = vEmpresa  AND num_credito =  vNumcredito; 
        COMMIT WORK;  

  END FOREACH;
  
  UPDATE statistics medium FOR TABLE bdicred:sd_indicador_cred;
  
  
  --SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora from sysmaster:sysshmvals;
  --INSERT INTO "informix".sd_bitacora_mec(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert) 
  --  VALUES(vEmpresa, vNumproceso, today, cCodRet, 'Proceso Finalizado', 'informix', today, vHora);

  RETURN cCodRet,cMensajeRet ;

END;

END PROCEDURE;