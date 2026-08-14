CREATE PROCEDURE "informix".sp_obtenerdomiciliocliente(pEmpresa CHAR(3), pNumCte CHAR(20), pNumCredito CHAR (20), pTipoDir CHAR(1))

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
	CHAR(30)   AS nombreEdificio; 

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

	--SET DEBUG FILE TO "/home/informix/sp_ObtenerDomicilioCliente.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cNumCte, cNumCredito, cNombreCte, cEstado, cNomEstado, cCiudad, siNumCiudad, cNomCiudad,
					cCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, siEdificio, cDepartamento, 
					cCodPostal, cObservaciones, cNumExt, cNumInt, cNombreEdificio;
			END IF;
		END EXCEPTION;

		IF NVL(pNumCte, '') = '' AND NVL(pNumCredito, '') = '' THEN
			LET cCodRet = '001';
			RETURN cCodRet, cNumCte, cNumCredito, cNombreCte, cEstado, cNomEstado, cCiudad, siNumCiudad, cNomCiudad,
				cCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, siEdificio, cDepartamento, 
				cCodPostal, cObservaciones, cNumExt, cNumInt, cNombreEdificio;
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
					cCodPostal, cObservaciones, cNumExt, cNumInt, cNombreEdificio;
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
					cCodPostal, cObservaciones, cNumExt, cNumInt, cNombreEdificio;
			END IF;

			SELECT TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno)
			INTO cNombreCte
			FROM "informix".si_cliente 
			WHERE empresa = pEmpresa 
			AND numcte = cNumCte;
		END IF;

		SELECT numcte, estado, ciudad, numerociudad, numerocolonia, numerocalle, numeroextcalle, 
			numerointcalle, edificio, departamento, cod_postal, observaciones
		INTO cNumCte, cEstado, cCiudad, siNumCiudad, iNumColonia, iNumCalle, cNumExt, cNumInt, 
			siEdificio, cDepartamento, cCodPostal, cObservaciones
		FROM "informix".si_direcciones_actual
		WHERE numcte = cNumCte
		AND secuencia = (SELECT MAX(secuencia) FROM "informix".si_direcciones_actual WHERE numcte = cNumCte 					AND tipo_dir = pTipoDir);
		
		IF cNumCte IS NULL OR TRIM(cNumCte) = '' THEN
			LET cCodRet = '004';
			RETURN cCodRet, cNumCte, cNumCredito, cNombreCte, cEstado, cNomEstado, cCiudad, siNumCiudad, cNomCiudad,
				cCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, siEdificio, cDepartamento, 
				cCodPostal, cObservaciones, cNumExt, cNumInt, cNombreEdificio;
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
			cCodPostal, cObservaciones, cNumExt, cNumInt, cNombreEdificio;
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
'MODIFICÓ: CARLOS OCHOA VALENZUELA',
'DESCRIPCIÓN: Se aplican reglas de informix, asi como se sustituye la obtención de datos',
'             de la si_direcciones, por si_direcciones_actual.';

CREATE PROCEDURE "informix".sp_elimina_campanias(pEmpresa CHAR(3), pIDCamp SMALLINT, pIDJerarquia SMALLINT)
RETURNING	CHAR(5) AS CodRet;	

	-- DEFINICION DE VARIABLES
    DEFINE	cCodRet			CHAR(5);
	DEFINE	iSqlErr			INTEGER;
	DEFINE	sIDMensaje 		SMALLINT;
		
	--INICIALIZACION DE VARIABLES--
    LET cCodRet			= "00000";
    LET iSqlErr			= 0;
	LET	sIDMensaje		= 0;
		
	--SET DEBUG FILE TO '/respaldosbd/obed/sp_elimina_campania.out';
	--TRACE ON;
	
    BEGIN

        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				RETURN cCodRet;
            END IF;
        END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF LENGTH(TRIM(NVL(pEmpresa,""))) = 0 OR NVL(pIDCamp, 0) = 0 OR NVL(pIDJerarquia, 0) = 0  THEN
			--PARÁMETROS INCORRECTOS
			LET cCodRet = "00001";
			RETURN cCodRet;
		ELSE
			--SE OBTIENE EL ID DEL MENSAJE
			SELECT FIRST 1 idmensaje
			INTO sIDMensaje
			FROM bdinteg:"informix".si_maecamp
			WHERE idcamp = pIDCamp 
			AND idjerarquia = pIDJerarquia
			AND empresa = TRIM(pEmpresa);
			
			--SE BORRAN LAS CAMPAÑAS 
			DELETE FROM bdinteg:"informix".si_maecamp
			WHERE idcamp = pIDCamp 
			AND idjerarquia = pIDJerarquia
			AND empresa = TRIM(pEmpresa);
			
			--SE BORRA EL MENSAJE
			DELETE FROM bdinteg:"informix".si_detcamp
			WHERE empresa = TRIM(pEmpresa)
			AND  idmensaje = sIDMensaje
			AND orden <> 0 ;
			
			RETURN cCodRet;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'AUTOR : Obed Vega',
'DESCRIPCION: Elimina una campaña existente',
'EJECUTADO O LLAMADO POR: Aplicativo it004006',
'BD: BDINTEG',
'FECHA : 13 de Septiembre 2013',
'VERSION: 20130913';

CREATE PROCEDURE "informix".sp_modificaguardacampania(cEmpresa CHAR(3), cSucursal CHAR(5), cZona CHAR(5), cSistema CHAR(2), cProducto CHAR(5), sTransaccion SMALLINT, cEstatus CHAR(1), sNivel SMALLINT, sActiva SMALLINT, sAct_Zona SMALLINT, sCombinable SMALLINT, sCampania SMALLINT, sJerarquia SMALLINT, cMensaje1 CHAR(55), cMensaje2 CHAR(55), cMensaje3 CHAR(55), cMensaje4 CHAR(55), cMensaje5 CHAR(55), cMensaje6 CHAR(55),cNomCamp CHAR(40), cCampNueva CHAR(1)) --DSB 20-08-2013 SE AGREGA EL PARAMETRO CNOMCAMP Y CCAMPNUEVA
--------------------------------------------------------------------
--DOCUMENTACIÓN
--Guarda o modifica la información de la campaña
--Realizó: Nancy Sevilla Camacho
 
--MODIFICACION: 
--DSB 20-08-2013
--DESCRIPCION: Se modifica para que inserte nombre de campaña y cree un solo mensaje por campaña
--MODIFICO: Obed Vega
--FECHA MODIFICACION: 20/Agosto/2013
--------------------------------------------------------------------

--DATOS A REGRESAR---
RETURNING
CHAR(5);   -- Código_retorno

--DEFINICION DE VARIABLES--
DEFINE iSqlErr      INTEGER;
DEFINE cCodRet      CHAR(5);

---------------------------	
DEFINE sIdMensajeMax SMALLINT;
DEFINE sIdMensaje SMALLINT;

--INICIALIZACION DE VARIABLES--
LET iSqlErr       = 0;
LET cCodRet       = '00000';
LET sIdMensajeMax = 0;
LET sIdMensaje    = 0;

	--SET DEBUG FILE TO "/respaldosbd/obed/sp_modificaguardacampania.out";
	--TRACE ON;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;	
		
		IF NVL(cEmpresa, '') = '' OR NVL(sCampania, 0) = '' OR NVL(sJerarquia, 0) = '' THEN
		
			LET cCodRet = '00002';
			RETURN cCodRet;	
		
		ELSE
				
			IF TRIM(cCampNueva) <> "1" THEN --SI NO ES UNA NUEVA CAMPAÑA
			
				IF TRIM(cProducto) = "0" THEN
					LET cProducto = "T";
				END IF;
	
				--ACTUALIZA EL REGISTRO EN LA TABLA SI_MAECAMP 
				UPDATE bdinteg:"informix".si_maecamp 
				   SET num_producto = TRIM(cProducto), 
					   sistema = cSistema, 
					   estatus = cEstatus, 
					   idnivel = sNivel,					   
					   activa = sActiva, 
					   combinable = sCombinable,
					   tran_nro = sTransaccion,
					   nombre = cNomCamp
				 WHERE idcamp = sCampania
				   AND idJerarquia = sJerarquia
				   AND empresa = cEmpresa
				   AND sucursal IS NOT NULL;			
				
				SELECT FIRST 1 idmensaje
				  INTO sIdMensaje
				  FROM bdinteg:"informix".si_maecamp
				 WHERE idcamp = sCampania
				   AND idJerarquia = sJerarquia
				   AND empresa = cEmpresa
				   AND sucursal IS NOT NULL;
				   
				-- ACTUALIZA EL MENSAJE EN LA TABLA SI_DETCAMP PARA LA CAMPAÑA QUE SE MODIFICA
				IF NVL(sIdMensaje,0) <> '' Or sIdMensaje IS NOT NULL THEN
					DELETE FROM bdinteg:"informix".si_detcamp 
					WHERE empresa = cEmpresa 
					AND idmensaje = sIdMensaje
					AND orden IS NOT NULL;
									
					IF TRIM(NVL(cMensaje1,'')) <> '' OR TRIM(NVL(cMensaje2,'')) <> '' OR TRIM(NVL(cMensaje3,'')) <> '' OR  TRIM(NVL(cMensaje4,'')) <> '' 
					   OR  TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensaje, cMensaje1, 1);	
					END IF;
					
					IF TRIM(NVL(cMensaje2,'')) <> '' OR TRIM(NVL(cMensaje3,'')) <> '' OR  TRIM(NVL(cMensaje4,'')) <> '' 
					   OR  TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensaje, cMensaje2, 2);	
					END IF;
					
					IF TRIM(NVL(cMensaje3,'')) <> '' OR  TRIM(NVL(cMensaje4,'')) <> '' OR  TRIM(NVL(cMensaje5,'')) <> '' 
					   OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensaje, cMensaje3, 3);	
					END IF;
					
					IF TRIM(NVL(cMensaje4,'')) <> '' OR  TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensaje, cMensaje4, 4);	
					END IF;
					
					IF TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensaje, cMensaje5, 5);	
					END IF;
					
					IF TRIM(NVL(cMensaje6,'')) <> '' THEN						   			   

						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensaje, cMensaje6, 6);							   		   
					END IF;					   
					RETURN cCodRet;
				ELSE
					--NO SE ENCONTRÓ EL IDMENSAJE PARA ESA CAMPAÑA Y JERARQUÍA
					LET cCodRet = '00001';
					RETURN cCodRet;
				END IF;
			
			ELSE
				SELECT FIRST 1 idmensaje
				  INTO sIdMensaje
				  FROM bdinteg:"informix".si_maecamp
				 WHERE idcamp = sCampania
				   AND idJerarquia = sJerarquia
				   AND empresa = cEmpresa
				   AND sucursal IS NOT NULL;
				
				IF NVL(sIdMensaje,0) <> '' Or sIdMensaje IS NOT NULL THEN
					-- INSERTA EN LA TABLA SI_MAECAMP LOS DATOS QUE CORRESPONDEN A LA CAMPAÑA CREADA
					INSERT INTO bdinteg:"informix".si_maecamp
							   (empresa, sucursal, num_producto, sistema, estatus, idcamp, idjerarquia, idnivel, idzona, activa, act_zona, combinable, idmensaje, tran_nro, nombre)
						 VALUES
							   (cEmpresa, cSucursal, cProducto, cSistema, cEstatus, sCampania, sJerarquia, sNivel, cZona, sActiva, sAct_Zona, sCombinable, sIdMensaje, sTransaccion, cNomCamp);
				
				ELSE
					-- SE OBTIENE EL VALOR MÁXIMO DEL ID MENSAJE
					SELECT MAX(idmensaje)
					  INTO sIdMensajeMax
					  FROM bdinteg:"informix".si_maecamp;
									
					IF NVL(sIdMensajeMax,0) = "" OR sIdMensajeMax IS NULL THEN
						LET sIdMensajeMax = 1;			
					ELSE
						LET sIdMensajeMax = sIdMensajeMax + 1;
					END IF;
				
					-- INSERTA EN LA TABLA SI_MAECAMP LOS DATOS QUE CORRESPONDEN A LA CAMPAÑA CREADA
					INSERT INTO bdinteg:"informix".si_maecamp
							   (empresa, sucursal, num_producto, sistema, estatus, idcamp, idjerarquia, idnivel, idzona, activa, act_zona, combinable, idmensaje, tran_nro, nombre)
						 VALUES
							   (cEmpresa, cSucursal, cProducto, cSistema, cEstatus, sCampania, sJerarquia, sNivel, cZona, sActiva, sAct_Zona, sCombinable, sIdMensajeMax, sTransaccion, cNomCamp);   
				
					-- INSERTA EN LA TABLA SI_DETCAMP LOS DATOS QUE CORRESPONDEN A LA CAMPAÑA CREADA
					IF TRIM(NVL(cMensaje1,'')) <> '' OR TRIM(NVL(cMensaje2,'')) <> '' OR TRIM(NVL(cMensaje3,'')) <> '' OR  TRIM(NVL(cMensaje4,'')) <> '' 
					   OR  TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensajeMax, cMensaje1, 1);	
					END IF;
					
					IF TRIM(NVL(cMensaje2,'')) <> '' OR TRIM(NVL(cMensaje3,'')) <> '' OR  TRIM(NVL(cMensaje4,'')) <> '' 
					   OR  TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensajeMax, cMensaje2, 2);	
					END IF;
					
					IF TRIM(NVL(cMensaje3,'')) <> '' OR  TRIM(NVL(cMensaje4,'')) <> '' OR  TRIM(NVL(cMensaje5,'')) <> '' 
					   OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensajeMax, cMensaje3, 3);	
					END IF;
					
					IF TRIM(NVL(cMensaje4,'')) <> '' OR  TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensajeMax, cMensaje4, 4);	
					END IF;
					
					IF TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensajeMax, cMensaje5, 5);	
					END IF;
					
					IF TRIM(NVL(cMensaje6,'')) <> '' THEN						   			   

						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensajeMax, cMensaje6, 6);							   		   
					END IF;					   
				END IF;
				RETURN cCodRet;		
			END IF;
		END IF;
	END;
END PROCEDURE;