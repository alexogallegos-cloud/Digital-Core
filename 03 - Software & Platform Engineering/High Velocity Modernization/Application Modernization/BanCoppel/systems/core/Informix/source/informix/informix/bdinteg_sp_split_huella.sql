CREATE PROCEDURE "informix".sp_split_huella(pTemplate CHAR(955))
--Retorno
RETURNING CHAR(5) AS cCodigoRet, SMALLINT AS sNfiq, SMALLINT As sMinucias,SMALLINT As sId_Excepcion,SMALLINT As sId_template, char(942) as cTemplate;

--Declaracion de variables
DEFINE pTemplate_temp  CHAR(952);
DEFINE cDelimitador CHAR(1);
DEFINE indice BIGINT;
DEFINE tampTemplate BIGINT;
DEFINE retorno SMALLINT;
DEFINE retorno2 SMALLINT;
DEFINE retorno3 SMALLINT;
DEFINE retorno4 SMALLINT;
DEFINE sSecuencia     SMALLINT;
DEFINE cEstatus       CHAR(1);
DEFINE sId_template   SMALLINT;
DEFINE cTemplate      CHAR(942);
DEFINE sNfiq          SMALLINT;
DEFINE sMinucias      SMALLINT;
DEFINE sId_Excepcion  SMALLINT;
DEFINE dFecha_insert  DATETIME YEAR TO FRACTION;
DEFINE iSqlErr INTEGER;
DEFINE cCodigoRet char(5);

--inicializacion de variables
LET indice = 0;
LET tampTemplate = LENGTH(pTemplate);
LET iSqlErr=0;
LET pTemplate_temp = pTemplate;
LET cCodigoRet = '00000';
LET sSecuencia = 0;
LET sId_template = 0;
LET cTemplate = '';
LET sNfiq = 0;
LET sMinucias = 0;
LET sId_Excepcion = 0;
LET cDelimitador = '|';
 
--SET DEBUG FILE TO '/home/sysifx/Aracely/bdinteg/sp_split_huella.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
	IF iSqlErr !=0 THEN
		RETURN TRIM (isqlerr),sNfiq,sMinucias,sId_Excepcion,sId_template,cTemplate;		
	END IF
	END EXCEPTION
	
	SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO dirty READ;
	
	--VALIDAR DATOS VACIOS
	IF  NVL(pTemplate, '') = '' THEN
	LET cCodigoRet = '00001'; 
			 RETURN cCodigoRet,sNfiq,sMinucias,sId_Excepcion,sId_template,cTemplate;
			 ELSE
			--CORTAR CADENAS DE TEMPLATES
			WHILE(1 = 1) LOOP
				-- CreaciÃ³n de Ã­ndice en SELECT para eliminar las busquedas secuenciales
				SELECT {+AVOID_FULL("informix".dual)} CHARINDEX(TRIM(cDelimitador), pTemplate_temp) into indice from dual;
				SELECT {+AVOID_FULL("informix".dual)} SUBSTR(pTemplate_temp, 0, indice - 1) into retorno from dual;
				LET sNfiq = retorno;
				
				SELECT {+AVOID_FULL("informix".dual)} SUBSTR(pTemplate_temp, indice + 1 , tampTemplate - indice) into pTemplate_temp from dual;
				SELECT {+AVOID_FULL("informix".dual)} CHARINDEX(TRIM(cDelimitador), pTemplate_temp) into indice from dual;
				SELECT {+AVOID_FULL("informix".dual)} SUBSTR(pTemplate_temp, 0, indice - 1) into retorno2 from dual;
				LET sMinucias = retorno2 ;
				
				SELECT {+AVOID_FULL("informix".dual)} SUBSTR(pTemplate_temp, indice + 1 , tampTemplate - indice) into pTemplate_temp from dual;
				SELECT {+AVOID_FULL("informix".dual)} CHARINDEX(TRIM(cDelimitador), pTemplate_temp) into indice from dual;
				SELECT {+AVOID_FULL("informix".dual)} SUBSTR(pTemplate_temp, 0, indice - 1) into retorno3 from dual;
				LET sId_Excepcion = retorno3;
				
				SELECT {+AVOID_FULL("informix".dual)} SUBSTR(pTemplate_temp, indice + 1 , tampTemplate - indice) into pTemplate_temp from dual;
				SELECT {+AVOID_FULL("informix".dual)} CHARINDEX(TRIM(cDelimitador), pTemplate_temp) into indice from dual;
				SELECT {+AVOID_FULL("informix".dual)} SUBSTR(pTemplate_temp, 0, indice - 1) into retorno4 from dual;
				LET sId_template = retorno4;
				
				SELECT {+AVOID_FULL("informix".dual)} SUBSTR(pTemplate_temp, indice + 1 , tampTemplate - indice) into pTemplate_temp from dual;
				
				LET cTemplate = pTemplate_temp;
			
				IF(indice = 0) THEN 
					--RETURN pTemplate_temp;--cCodigoRet,sNfiq,sMinucias,sId_template,cTemplate;
					--RETURN pTemplate_temp WITH RESUME;	
					EXIT;
				END IF;
		
		IF dbinfo('sqlca.sqlerrd2') = 0 THEN
			LET cCodigoRet= '00002';
		 END IF;	
	
		RETURN cCodigoRet,sNfiq,sMinucias,sId_Excepcion,sId_template,cTemplate;
		END LOOP
	END IF;
END;
END PROCEDURE

DOCUMENT
"Peticion: 420",
"AutOR : 92473997 Isaac Salomon Quintero Serrano",
"FECHA : 31/08/2018",
"DescripciÃÂ³n: Store Procedure para recibir un string y seperar minucias, dedos, templates, etc. y retornarlos",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_guardadomiciliocliente2( pTipo CHAR(1),      
                                                       pEmpresa CHAR(3),  
                                                       pPromotor CHAR(8), 
                                                       pNumCte CHAR(20), 
                                                       pNumCredito CHAR(20), 
                                                       pEstado CHAR(30),
                                                       pCiudad CHAR(60),         
                                                       pCiudadCoppel INT, 
                                                       pZona CHAR(30),    
                                                       pCalle CHAR(30),  
                                                       pCodPostal CHAR(5),   
                                                       pComplemento CHAR(80),
                                                       pNumeroExtCalle CHAR(10), 
                                                       pNumeroIntCalle CHAR(10), 
                                                       pEdificio INT, 
                                                       pDepartamento CHAR(6),
                                                       pEntreCalles CHAR(40))
--DATOS A REGRESAR--
RETURNING CHAR(5);  -- Codigo de Retorno

        -- DEFINICION DE VARIABLES--
        DEFINE iSql_Err INT;
        DEFINE cCodRet CHAR(5);
        DEFINE iSecuencia INT;
        DEFINE cTipo_Dir CHAR(1);
        DEFINE cCalle CHAR(40);
        DEFINE cColonia CHAR(60);
        DEFINE cEntre_Calles CHAR(40);
        DEFINE cPais CHAR(3);
        DEFINE cMunicipio CHAR(5);
        DEFINE cApart_Postal CHAR(11);
        DEFINE cTipo_Telef1 CHAR(1);
        DEFINE cTelefono1 CHAR(13);
        DEFINE cTipo_Telef2 CHAR(1);
        DEFINE cTelefono2 CHAR(13);
        DEFINE cTipo_Telef3 CHAR(1);
        DEFINE cTelefono3 CHAR(13);
        DEFINE cExtension CHAR(5);
        DEFINE cEstado_Inegi CHAR(2);
        DEFINE cMunicipio_Inegi CHAR(3);
        DEFINE cLocalidad_Inegi CHAR(4);
        DEFINE cPuntoCardinal CHAR(1);
        DEFINE cUnidadHabitac CHAR(1);
        DEFINE iManzana INT;
        DEFINE iOtros INT;
        DEFINE iAndador INT;
        DEFINE iEtapa INT;
        DEFINE iLote INT;
        DEFINE iEntrada INT;
        DEFINE dFechaHoy DATE;
        DEFINE cIndCofetelTel1 CHAR(1);
        DEFINE cIndCofetelTel2 CHAR(1);
        DEFINE cIndCofetelTel3 CHAR(1);
        --DSB 12/04/2011
		DEFINE siOrigen SMALLINT;
		DEFINE cNumSucursal CHAR(4);

        -- INICIALIZACION DE VARIABLES--
        LET iSql_Err = 0;
        LET cCodRet = '000';
        LET iSecuencia = 0;
        LET cTipo_Dir = '';
        LET cCalle = '';
        LET cColonia = '';
        LET cEntre_Calles = '';
        LET cPais = '';
        LET cMunicipio = '';
        LET cApart_Postal = '';
        LET cTipo_Telef1 = '';
        LET cTelefono1 = '';
        LET cTipo_Telef2 = '';
        LET cTelefono2 = '';
        LET cTipo_Telef3 = '';
        LET cTelefono3 = '';
        LET cExtension = '';
        LET cEstado_Inegi = '';
        LET cMunicipio_Inegi = '';
        LET cLocalidad_Inegi = '';
        LET cPuntoCardinal = '';
        LET cUnidadHabitac = '';
        LET iManzana = 0;
        LET iOtros = 0;
        LET iAndador = 0;
        LET iEtapa = 0;
        LET iLote = 0;
        LET iEntrada = 0;
        LET dFechaHoy = '01-01-1900';
        LET cIndCofetelTel1 = '';
        LET cIndCofetelTel2 = '';
        LET cIndCofetelTel3 = '';
		--DSB 12/04/2011
		LET siOrigen = 0;
		LET cNumSucursal = '';

        --SET DEBUG FILE TO "/informix/CHVN/sp_GuardaDomicilioCliente.out";
        --TRACE ON;

        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        BEGIN
    
		ON EXCEPTION SET iSql_Err
        IF iSql_Err <> 0 THEN
            LET cCodRet = iSql_Err;
            RETURN cCodRet;
        END IF;
		END EXCEPTION;

		SELECT fecha_hoy 
		INTO dFechaHoy 
		FROM bdinteg:"informix".si_fechas 
		WHERE empresa = pEmpresa;

		-- GUARDA CAMBIOS DE DOMICILIO PARTICULAR O TRABAJO DEL CLIENTE
		IF TRIM(pNumCte) = '' THEN
			IF TRIM(pNumCredito) = '' THEN
				LET cCodRet = '001';
			ELSE
				SELECT numcte
				INTO pNumCte
				FROM bdicred:"informix".sd_maecred
				WHERE num_credito = pNumCredito;
			END IF;
		END IF;

		SELECT MAX(secuencia + 1) 
		INTO iSecuencia 
		FROM bdinteg:"informix".si_direcciones_actual 
		WHERE numcte = pNumCte;
	 
		IF iSecuencia IS NULL THEN
			LET iSecuencia = 1;
		END IF;

        --Actualizamos el entre calle de la direccion actual
        UPDATE bdinteg:"informix".si_direcciones_actual
        SET entre_calles = pEntreCalles
        WHERE numcte = pNumCte AND tipo_dir = pTipo;

		
		SELECT calle, colonia, entre_calles, pais, municipio, apart_postal, 
           /* tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, */
           estado_inegi, municipio_inegi, localidad_inegi, puntocardinal, 
           unidadhabitac, manzana, otros, andador, etapa, lote, entrada, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3
		INTO cCalle, cColonia, cEntre_Calles, cPais, cMunicipio, cApart_Postal, 
           /* cTipo_Telef1, cTelefono1, cTipo_Telef2, cTelefono2, cTipo_Telef3, cTelefono3, cExtension, */
           cEstado_Inegi, cMunicipio_Inegi, cLocalidad_Inegi, cPuntoCardinal, 
           cUnidadHabitac, iManzana, iOtros, iAndador, iEtapa, iLote, iEntrada, cIndCofetelTel1, cIndCofetelTel2, cIndCofetelTel3
		FROM bdinteg:"informix".si_direcciones_actual
		WHERE numcte = pNumCte 
		AND tipo_dir = pTipo;
		--- AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:si_direcciones WHERE numcte = pNumCte AND tipo_dir = pTipo);
        
        IF cPais IS NULL THEN
            LET cPais = '001';
        END IF;
                
		INSERT INTO bdinteg:"informix".si_direcciones
		( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal, 
		/* tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, */
		estado_inegi, municipio_inegi, localidad_inegi, numerociudad,
		numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador,
		etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3 )
		VALUES 
		( pNumCte, iSecuencia, pTipo, cCalle, cColonia, pEntreCalles, cPais, pEstado, pCiudad, cMunicipio, pCodPostal, cApart_Postal,
		/* cTipo_Telef1, cTelefono1, cTipo_Telef2, cTelefono2, cTipo_Telef3, cTelefono3, cExtension, */
		cEstado_Inegi, cMunicipio_Inegi,
		cLocalidad_Inegi, pCiudadCoppel, pNumeroExtCalle, pNumeroIntCalle, pDepartamento, pCalle, pZona, cPuntoCardinal, cUnidadHabitac,
		iManzana, iOtros, iAndador, iEtapa, iLote, pEdificio, iEntrada, pComplemento, pPromotor, dFechaHoy, cIndCofetelTel1, 
		cIndCofetelTel2, cIndCofetelTel3 );

		-- DSB 12/04/2011
		-- Se llena variable con el tipo de origen -> 1 = Tienda, 2 = Sucursal, 3 = CAT, 5 = SIF
		LET siOrigen = 5;

		-- Se ejecuta el siguiente SP para insertar en la tabla si_bitacora_cambiosdom los registros
		-- correspondientes a los movimientos relacionados con los cambios de domicilio (Bitï¿½cora)
		EXECUTE PROCEDURE "informix".sp_registramodifdomicilio(pNumCte, siOrigen, pTipo, iSecuencia, cNumSucursal, dFechaHoy, pPromotor, pPromotor) 
		INTO cCodRet;                                                                                               

		RETURN cCodRet;
                
       END
    
END PROCEDURE

DOCUMENT
'Actualiza el Domicilio Particular y del Trabajo del Cliente',
'AUTOR: Iris Arias Zazueta',
'FECHA: 23/10/2008',
'MODIFICO: Iris Arias Zazueta',
'FECHA: 28/03/2011 - Se modifica para agregar parametros de entrada',
'MODIFICO: Iris Arias Zazueta',
'FECHA: 05/05/2011 - Se modifica consulta para obtener los indicadores de cofetel',
'y modificar la validaciï¿½n de la secuencia',
'BD   : bdinteg',
'VER  : 1.0',
'Modificacion: actualiza para realizar consulta sobre si_direcciones',
'modifico: Sergio Fernandez Cordero',
'Fecha: Enero 2012',
'Modificaciï¿½n: Se actualiza SPL para estandarizar codificacion y asignar valor 1 al campo Secuencia cuando se recupera valor nulo',
'Fecha: 02/09/2016',
'Autor: Sandra Cano',
'Modificaciï¿½n: Se Crea el SP clon de sp_guardadomiciliocliente para actualizar anexa el parametro entre calles para las tablas si_direcciones y si_direcciones_actual',
'Fecha: 22/12/2023',
'Autor: JosÃ© Antonio RamÃ­rez Franco';

CREATE PROCEDURE "informix".sp_obtenerdomiciliocliente2(pEmpresa CHAR(3), pNumCte CHAR(20), pNumCredito CHAR (20), pTipoDir CHAR(1))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5)    AS Cod_ret, 
	CHAR(20)   AS numeroCte, 
	CHAR(20)   AS numCredito, 
	CHAR(104)  AS nomCte, 
	CHAR(2)    AS estado, 
	CHAR(30)   AS nombreEstado, 
	CHAR(3)    AS ciudad, 
	SMALLINT   AS numeroCiudad, 
	CHAR(60)   AS nombreCiudad, 
	SMALLINT   AS ciudadCoppel, 
	INTEGER    AS numeroColonia, 
	CHAR(32)   AS nombrecolonia, 
	CHAR(27)   AS municipio, 
	INTEGER    AS numeroCalle, 
	CHAR(30)   AS nombreCalle, 
	SMALLINT   AS edificio, 
	CHAR(6)    AS departamento, 
	CHAR(5)    AS codigoPostal, 
	CHAR(80)   AS observaciones, 
	CHAR(10)   AS numeroExterior,
	CHAR(10)   AS numeroInterior, 
	CHAR(30)   AS nombreEdificio,
	CHAR(40)   AS entreCaller; 

	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr             INTEGER;
	DEFINE cCodRet             CHAR(5);
	DEFINE cNumCte             CHAR(20);
	DEFINE cNombreCte          CHAR(104);
	DEFINE cNumCredito         CHAR(20);
	DEFINE cEstado             CHAR(2);
	DEFINE cCiudad             CHAR(3);
	DEFINE siNumCiudad         SMALLINT;
	DEFINE iNumCalle           INTEGER;
	DEFINE siEdificio          SMALLINT;
	DEFINE cDepartamento       CHAR(6);
	DEFINE cCodPostal          CHAR(5);
	DEFINE cObservaciones      CHAR(80);
	DEFINE cNumExt             CHAR(10);
	DEFINE cNumInt             CHAR(10);
	DEFINE cNomEstado          CHAR(30);
	DEFINE cNomCiudad          CHAR(60);
	DEFINE cCiudadCoppel       SMALLINT;
	DEFINE iNumColonia         INTEGER;
	DEFINE cNomColonia         CHAR(32);
	DEFINE cMunicipio          CHAR(27);
	DEFINE cNomCalle           CHAR(30);
	DEFINE cNombreEdificio     CHAR(30);
	DEFINE cEntre_Calles	   CHAR(40);

	--INICIALIZACION DE VARIABLES--
	LET iSqlErr                = 0;
	LET cCodRet                = '000';
	LET cNumCte                = '';
	LET cNombreCte             = '';
	LET cNumCredito            = '';
	LET cEstado                = '';
	LET cCiudad                = '';
	LET siNumCiudad            = 0;
	LET iNumCalle              = 0;
	LET siEdificio             = 0;
	LET cDepartamento          = '';
	LET cCodPostal             = '';
	LET cObservaciones         = '';
	LET cNumExt                = '';
	LET cNumInt                = '';
	LET cNomEstado             = '';
	LET cNomCiudad             = '';
	LET cCiudadCoppel          = 0;
	LET iNumColonia            = 0;
	LET cNomColonia            = '';
	LET cMunicipio             = '';
	LET cNomCalle              = '';
	LET cNombreEdificio        = '';
	LET cEntre_Calles		   = '';

	--SET DEBUG FILE TO "/tmp/mfinis/sp_ObtenerDomicilioCliente2.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cNumCte, cNumCredito, cNombreCte, cEstado, cNomEstado, cCiudad, siNumCiudad, cNomCiudad,
					cCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, siEdificio, cDepartamento, 
					cCodPostal, cObservaciones, cNumExt, cNumInt, cNombreEdificio, cEntre_Calles;
			END IF;
		END EXCEPTION;

		IF NVL(pNumCte, '') = '' AND NVL(pNumCredito, '') = '' THEN
			LET cCodRet = '001';
			RETURN cCodRet, cNumCte, cNumCredito, cNombreCte, cEstado, cNomEstado, cCiudad, siNumCiudad, cNomCiudad,
				cCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, siEdificio, cDepartamento, 
				cCodPostal, cObservaciones, cNumExt, cNumInt, cNombreEdificio, cEntre_Calles;
		END IF;

		IF NVL(pNumCte, '') <> '' THEN
			SELECT numcte, TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno)
			INTO cNumCte, cNombreCte
			FROM "informix".si_cliente 
			WHERE empresa = pEmpresa 
			AND numcte = pNumCte;

			IF cNumCte IS NULL OR TRIM(cNumCte) = '' THEN
				LET cCodRet = '002';
				RETURN cCodRet, cNumCte, cNumCredito, cNombreCte, cEstado, cNomEstado, cCiudad, siNumCiudad, cNomCiudad,
					cCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, siEdificio, cDepartamento, 
					cCodPostal, cObservaciones, cNumExt, cNumInt, cNombreEdificio, cEntre_Calles;
			END IF;

			IF NVL(pNumCredito, '') <> '' THEN
				SELECT num_credito 
				INTO cNumCredito
				FROM bdicred:"informix".sd_maecred 
				WHERE empresa = pEmpresa 
				AND num_credito = pNumCredito;
			ELSE
				SELECT FIRST 1 num_credito 
				INTO cNumCredito
				FROM bdicred:"informix".sd_maecred 
				WHERE empresa = pEmpresa 
				AND numcte = pNumCte;
			END IF;

		ELIF NVL(pNumCredito, '') <> '' THEN
			SELECT num_credito, numcte 
			INTO cNumCredito, cNumCte
			FROM bdicred:"informix".sd_maecred 
			WHERE empresa = pEmpresa 
			AND num_credito = pNumCredito;

			IF cNumCredito IS NULL OR TRIM(cNumCredito) = '' THEN
				LET cCodRet = '003';
				RETURN cCodRet, cNumCte, cNumCredito, cNombreCte, cEstado, cNomEstado, cCiudad, siNumCiudad, cNomCiudad,
					cCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, siEdificio, cDepartamento, 
					cCodPostal, cObservaciones, cNumExt, cNumInt, cNombreEdificio, cEntre_Calles;
			END IF;

			SELECT TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno)
			INTO cNombreCte
			FROM "informix".si_cliente 
			WHERE empresa = pEmpresa 
			AND numcte = cNumCte;
		END IF;

		SELECT numcte, estado, ciudad, numerociudad, numerocolonia, numerocalle, numeroextcalle, 
			numerointcalle, edificio, departamento, cod_postal, observaciones,entre_calles
		INTO cNumCte, cEstado, cCiudad, siNumCiudad, iNumColonia, iNumCalle, cNumExt, cNumInt, 
			siEdificio, cDepartamento, cCodPostal, cObservaciones, cEntre_Calles
		FROM "informix".si_direcciones_actual
		WHERE numcte = cNumCte
		AND secuencia = (SELECT MAX(secuencia) FROM "informix".si_direcciones_actual WHERE numcte = cNumCte AND tipo_dir = pTipoDir);
		
		IF cNumCte IS NULL OR TRIM(cNumCte) = '' THEN
			LET cCodRet = '004';
			RETURN cCodRet, cNumCte, cNumCredito, cNombreCte, cEstado, cNomEstado, cCiudad, siNumCiudad, cNomCiudad,
				cCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, siEdificio, cDepartamento, 
				cCodPostal, cObservaciones, cNumExt, cNumInt, cNombreEdificio, cEntre_Calles;
		END IF;

		SELECT nombre INTO cNomEstado
		FROM "informix".si_estados WHERE estado = cEstado;

		SELECT nombre, ciudad_coppel 
		INTO cNomCiudad, cCiudadCoppel
		FROM "informix".si_ciudades 
		WHERE ciudad = cCiudad 
		AND estado = cEstado;

		SELECT nombrezona, municipiozona 
		INTO cNomColonia, cMunicipio
		FROM "informix".si_catzonas 
		WHERE numerociudad = siNumCiudad 
		AND numerocolonia = iNumColonia;

		SELECT nombrecalle 
		INTO cNomCalle 
		FROM "informix".si_catcalles 
		WHERE numerocalle = iNumCalle;
		
		--DSB 04/05/2011
		SELECT nombredomicilio 
		INTO cNombreEdificio
		FROM "informix".si_catdomicilios 
		WHERE numerociudad = siNumCiudad 
		AND numerocolonia = iNumColonia 
		AND clavedomicilio = 5
		AND complementoclave = siEdificio;

		RETURN cCodRet, cNumCte, cNumCredito, cNombreCte, cEstado, cNomEstado, cCiudad, siNumCiudad, cNomCiudad,
			cCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, siEdificio, cDepartamento, 
			cCodPostal, cObservaciones, cNumExt, cNumInt, cNombreEdificio, cEntre_Calles;
	END
END PROCEDURE
DOCUMENT
'Valida si el Cliente existe y consulta su domicilio de casa o trabajo',
'AUTOR: Iris Arias Zazueta',
'FECHA: 24/03/2011',
'DSB 04/05/2011 - Se modifica para obtener el nombre del edificio',
'MODIFICO: Iris Arias Zazueta',
'BD   : bdinteg',
'VER  : 1.0',
'MODIFICï¿½: CARLOS OCHOA VALENZUELA',
'DESCRIPCIN: Se aplican reglas de informix, asi como se sustituye la obtenciï¿½n de datos',
'             de la si_direcciones, por si_direcciones_actual.',
'FECHA: 22/12/2023',
'MODIFICï¿½: JosÃ© Antonio RamÃ­rez Franco',
'DESCRIPCIï¿½N: Se realiza la clonacion del SP sp_obtenerdomiciliocliente para regresar el campo de Entre calles';

CREATE PROCEDURE "informix".sp_clientescoppelpaytdc()
	RETURNING
     CHAR(6); ---cod_ret

    DEFINE v_cod_ret            CHAR(6);
    DEFINE iSqlErr              INTEGER;
    DEFINE vsSQL LVARCHAR (32739);
	DEFINE vsql2 LVARCHAR (32739);
	DEFINE cFecha_hoy CHAR(8);
	DEFINE cFechaSistema DATE;
	DEFINE sNombreArchivoFinal VARCHAR(100);
	DEFINE sNombreArchivo	   VARCHAR(100);
	DEFINE vDirectorio CHAR(100);
	DEFINE cCLienteCoppel CHAR(20);
	DEFINE sNombredeArchivo	   VARCHAR(100);
	
	
	LET vsSQL = '' ;
	LET vsql2 = '' ;
	LET cFecha_hoy = '19000101';
	LET cFechaSistema = DATE(1);
	LET sNombreArchivoFinal ='';
	LET sNombreArchivo		='';
	LET vDirectorio = '';
	LET cCLienteCoppel = '';
	LET v_cod_ret='';
	LET sNombredeArchivo='';


	SET ISOLATION TO DIRTY READ;

	BEGIN

	   ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
					LET v_cod_ret = iSqlErr;
			END IF;
			RETURN v_cod_ret;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;


		--SET DEBUG FILE TO "/tmp/efrain/bdinteg/sp_clientescoppelpaytdc.out";
		--TRACE ON;
			
		select valor 
			into vDirectorio
		from bdinteg: si_param 
		where cod_param = '521' 
		and empresa = '001';
		
		IF vDirectorio IS NULL THEN
		  LET v_cod_ret='000001';
		  RETURN v_cod_ret;
		ELSE
	
			SELECT fecha_hoy 
				INTO cFechaSistema 
			FROM bdinteg:"informix".si_fechas 
			WHERE empresa = '001';
			
			LET cFecha_hoy = LPAD(DAY(cFechaSistema),2,0)||LPAD(MONTH(cFechaSistema),2,0)||YEAR(cFechaSistema);
			
			select valor 
				into sNombredeArchivo
			from bdinteg: si_param 
			where cod_param = '522' 
			and empresa = '001';
			
			
			IF sNombredeArchivo IS NULL THEN
			  LET v_cod_ret='000002';
			  RETURN v_cod_ret;
			ELSE
				LET sNombreArchivo = trim(sNombredeArchivo) ||'.txt' ;
				LET sNombreArchivoFinal = trim(sNombredeArchivo)||cFecha_hoy ||'.txt' ;
				

				LET vsSQL = 'echo "unload TO '|| TRIM(vDirectorio) || TRIM(sNombreArchivo) ||'  delimiter ''|'' select lpad(Trim(cliente),20,0) ,fecha_asigna_coppelapla,sucursal_CoppelAPla  from bdinteg: si_relacion_ctebcplcpl where  fecha_asigna_coppelapla is not null and envio_CoppelAPla =''0''" | dbaccess bdinteg';
				system vsSQL;

				LET vsSQL ='';
				LET vsSQL = "sed -e 's/[|]*$/| /' "|| TRIM(vDirectorio)|| TRIM(sNombreArchivo) || " >> "|| TRIM(vDirectorio)||TRIM(sNombreArchivoFinal);
				system vsSQL;

				LET vsSQL = '';
				LET vsSQL = "rm " ||TRIM(vDirectorio)|| TRIM(sNombreArchivo);	
				SYSTEM vsSQL;
				
				update bdinteg: "informix".si_relacion_ctebcplcpl set envio_CoppelAPla = 1  where fecha_asigna_coppelapla is not null and envio_CoppelAPla = '0';
				
				LET v_cod_ret = '000000';
			

				RETURN v_cod_ret;
			END IF;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'MODIFICACION: 94206041 - Jesús Rosario López Castro',
'Folio: ',
'RQM: TDC Coppel Plazos fijos ',
'Descripcion: Validar que el cliente se diero de alta  TDC Coppel Pay Mastercard',
'Solicito: Luis Gil',
'Fecha: 07/03/2022',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_reporte_huellas(pFechaIni DATE,pFechaFin DATE)
	RETURNING
	CHAR(6) 	AS 	COD_RET,
	CHAR(80) 	AS MENSAJE_RET;

	--DECLARACION DE VARIABLES
	DEFINE cCodret 		 	CHAR(6);
	DEFINE iSqlErr        	INTEGER;
	DEFINE cMensaje       	CHAR(80);
	DEFINE cNumCte1			CHAR(20);
	DEFINE cApellPat1		CHAR(26);
	DEFINE cApellMat1		CHAR(26);
	DEFINE cNom1			CHAR(26);
	DEFINE cNom2			CHAR(26);
	DEFINE cRFC1			CHAR(13);
	DEFINE dtFechaNac1		DATE;
	DEFINE cNumCte2			VARCHAR(9);
	DEFINE cApellPat2		CHAR(26);
	DEFINE cApellMat2		CHAR(26);
	DEFINE cNom1_2			CHAR(26);
	DEFINE cNom2_2			CHAR(26);
	DEFINE cRFC2			CHAR(13);
	DEFINE dtFechaNac2		DATE;
	DEFINE cTicket			CHAR(20);
	DEFINE dtFechaCons		DATE;
	
--{+OPTIMIZACION STK202310-12}
	DEFINE pRegsxTransaccion		INTEGER;
	DEFINE dtFechaInsert			DATETIME YEAR TO FRACTION(3);
	DEFINE iCont					INTEGER;
--{+OPTIMIZACION STK202310-12}

	--INICIALIZACION DE VARIABLES
	LET cCodret			= '00000';
	LET iSqlErr 		= 0;
	LET cMensaje		= 'PROCESO EXITOSO';
	LET cNumCte1		= '';
	LET cApellPat1		= '';
	LET cApellMat1		= '';
	LET cNom1			= '';
	LET cNom2			= '';
	LET cRFC1			= '';
	LET dtFechaNac1		= DATE(1);
	LET cNumCte2		= '';
	LET cApellPat2		= '';
	LET cApellMat2		= '';
	LET cNom1_2			= '';
	LET cNom2_2			= '';
	LET cRFC2			= '';
	LET dtFechaNac2		= DATE(1);
	LET cTicket			= '';
	LET dtFechaCons		= DATE(1);
	LET dtFechaInsert	= DATE(1);

--{+OPTIMIZACION STK202310-12}
	LET pRegsxTransaccion	  = 2000;  --valor en codigo duro para el control de la transaccion, sugerido por el area de BD de BanCoppel
	LET iCont				  = 0;
--{+OPTIMIZACION STK202310-12}

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			LET cMensaje = "ERROR NO CONTROLADO";
			RETURN cCodret, cMensaje;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--{+OPTIMIZACION STK202310-12}

	SELECT 
		lpad(TRIM(cliente::CHAR(9)), 9,'0') cliente, ticket ticket, fecha fecha, num_mensaje num_mensaje, empresa empresa
	FROM si_huella_linea_resultado
	WHERE fecha >= pFechaIni and fecha <= pFechaFin
	AND num_mensaje = '602' AND empresa = '5'
	INTO TEMP temp_si_huella_linea_resultado WITH NO LOG;

	CREATE INDEX "informix".idx_temp_si_huella_linea_resultado
		ON "informix".temp_si_huella_linea_resultado(cliente) ONLINE;

	SELECT 
		DISTINCT a.cliente numcte2, a.ticket, a.fecha,
					cte1.apell_paterno apell_pat_2,cte1.apell_materno apell_mat_2, cte1.nombre1 nom1_2, cte1.nombre2 nom2_2,
					cte1.rfc rfc_2,
					pf.fecha_nac fecha_nac2
	FROM temp_si_huella_linea_resultado a, si_cliente cte1, si_ctepf pf
	WHERE a.cliente = cte1.numcte
	AND a.cliente = pf.numcte and pf.fecha_nac <= '01-01-1995'
	AND a.cliente = cte1.numcte
	INTO TEMP clientes_bcpl_dupl_2 WITH NO LOG;

	CREATE INDEX "informix".idx_clientes_bcpl_dupl_2
		ON "informix".clientes_bcpl_dupl_2(ticket, fecha) ONLINE;

	SET ISOLATION TO DIRTY READ;
	SELECT 
		a.numcte numcte1, a.ticket, a.fecha_consulta, cte1.apell_paterno apell_pat_1, cte1.apell_materno apell_mat_1,
		cte1.nombre1 nom1_1, cte1.nombre2 nom2_1, cte1.rfc rfc_1, pf.fecha_nac fecha_nac1
	FROM si_huella_linea a, si_cliente cte1, si_ctepf pf
	WHERE a.fecha_consulta >= pFechaIni and a.fecha_consulta <= pFechaFin
	AND a.ticket IN (SELECT ticket FROM clientes_bcpl_dupl_2)
	AND a.numcte = cte1.numcte
	AND a.numcte = pf.numcte
	INTO TEMP clientes_bcpl_dupl_1 WITH NO LOG;

	CREATE INDEX "informix".idx_clientes_bcpl_dupl_1
		ON "informix".clientes_bcpl_dupl_1(ticket, fecha_consulta) ONLINE;

	BEGIN WORK;
	LET iCont = 0;
	FOREACH WITH HOLD
		SELECT 
				a.numcte1, a.apell_pat_1, a.apell_mat_1, a.nom1_1, a.nom2_1, a.rfc_1, a.fecha_nac1, b.numcte2,
				b.apell_pat_2, b.apell_mat_2, b.nom1_2, b.nom2_2, b.rfc_2, b.fecha_nac2, a.ticket, a.fecha_consulta, CURRENT AS fecha_insert
			INTO cNumCte1, cApellPat1, cApellMat1, cNom1, cNom2, cRFC1, dtFechaNac1, cNumCte2,
					cApellPat2, cApellMat2, cNom1_2, cNom2_2, cRFC2, dtFechaNac2, cTicket, dtFechaCons, dtFechaInsert
			FROM clientes_bcpl_dupl_1 a, clientes_bcpl_dupl_2 b
			WHERE a.ticket = b.ticket
			AND a.fecha_consulta = b.fecha

		INSERT INTO "informix".si_clientes_huellas_dupl(numcte1, apell_pat_1, apell_mat_1, nom1_1, nom2_1, rfc_1, fecha_nac1, numcte2,
									apell_pat_2, apell_mat_2, nom1_2, nom2_2, rfc_2, fecha_nac2, ticket, fecha_consulta, fecha_insert)
		VALUES(cNumCte1, cApellPat1, cApellMat1, cNom1, cNom2, cRFC1, dtFechaNac1, cNumCte2,
				cApellPat2, cApellMat2, cNom1_2, cNom2_2, cRFC2, dtFechaNac2, cTicket, dtFechaCons, dtFechaInsert);

		LET iCont = iCont + 1;
		IF iCont = pRegsxTransaccion THEN
			COMMIT WORK;
			LET iCont = 0;
			BEGIN WORK;
		END IF;
	END FOREACH;
	COMMIT WORK;

	--{+OPTIMIZACION STK202310-12}

	EXECUTE PROCEDURE "informix".sp_compara_nombres()
	INTO cCodret;

	RETURN cCodret, cMensaje;
END;
END PROCEDURE;