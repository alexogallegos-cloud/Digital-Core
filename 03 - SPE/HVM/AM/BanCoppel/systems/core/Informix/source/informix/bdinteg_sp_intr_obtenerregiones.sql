CREATE PROCEDURE "informix".sp_intr_obtenerregiones(piRegNum INTEGER, piRegistroInicial INTEGER)
	RETURNING CHAR(6) AS CodRetorno,
				CHAR(3) AS NumRegion,
				CHAR(40) AS NomRegion;
		
--DEFINICION DE VARIABLES--
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);	
DEFINE cNumRegion CHAR(3);
DEFINE cRegion CHAR(40);
---------------------------	

--INICIALIZACION DE VARIABLES--
LET iSqlErr = 0;
LET cCodRet = '000000';
LET cNumRegion = '';
LET cRegion  = '';

	
--SET DEBUG FILE TO "/home/informix/sp_intr_obtenerregiones.out";
--TRACE ON;
	
SET LOCK MODE TO WAIT 3;
	
-- INICIO DEL PROCEDIMIENTO
BEGIN
	-- MANEJADOR DE ERRORES
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,	cNumRegion, cRegion;
		END IF;
	END EXCEPTION;	  
	
	IF piRegNum IS NULL OR piRegistroInicial IS NULL THEN
		LET cCodRet = '000001'; --Parametros incorrectos
		RETURN cCodRet, cNumRegion, cRegion;
	END IF;
	
-- Se realiza la consulta por Regiones		
	IF piRegNum = 0 THEN
	
		-- Se realiza la búsqueda en la tabla, todas las Regiones
		FOREACH		
			SELECT SKIP piRegistroInicial codigo_plaza, descripcion
			INTO cNumRegion, cRegion		  
			FROM bdinteg:si_plazas_cajagen				   
			ORDER BY descripcion	
			 
			RETURN cCodRet, cNumRegion, cRegion WITH RESUME;
		END FOREACH;	 
						
		-- Se valida que se haya obtenido información
		IF NVL(cNumRegion,'') = '' AND NVL(cRegion,'') = '' THEN			
			LET cCodRet = '999999';  -- No se encontró información
			--RETURN cCodRet, cNumRegion, cRegion WITH RESUME;
		END IF;		

	ELSE
		SELECT codigo_plaza, descripcion
		INTO cNumRegion, cRegion		  
		FROM bdinteg:si_plazas_cajagen
		WHERE codigo_plaza = piRegNum;		
		
		-- Se valida que se haya obtenido información
		IF NVL(cNumRegion,'') = '' AND NVL(cRegion,'') = '' THEN
			LET cCodRet = '999999';  -- No se encontró información
			--RETURN cCodRet, cNumRegion, cRegion WITH RESUME;
		END IF;
	END IF;
	
	IF cCodRet <> '000000' OR piRegNum <> 0 THEN
		RETURN cCodRet, cNumRegion, cRegion;
	END IF;
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea SP para extraer los nombres de las regiones',
'AUTOR : Jose Luis Polanco B.',
'FECHA : 01/11/2013',
'VERSION: 1.0',
'BD: BDINTEG',
'SISTEMA : INTRANET';

CREATE PROCEDURE "informix".sp_intr_obtenersucursal(numsucursal INT, pRegistroInicial INT)

--DATOS A REGRESAR---
RETURNING
CHAR(6),      -- Código de Retorno
CHAR(4),      -- Clave de la Sucursal
CHAR(40);     -- Nombre de la Sucursal
		
--DEFINICION DE VARIABLES--
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);	
---------------------------	
DEFINE cClave  CHAR(4);
DEFINE cNombre CHAR(40);

--INICIALIZACION DE VARIABLES--
LET iSqlErr = 0;
LET cCodRet = '000000';
LET cClave  = '';
LET cNombre = '';
	
	--SET DEBUG FILE TO "/home/informix/sp_intr_obtenersucursal.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cClave, cNombre;
			END IF;
		END EXCEPTION;	  
		
-- Se realiza la consulta por Sucursales		
		IF numsucursal = 0 THEN
		
			-- Se realiza la búsqueda en la tabla de todas las sucursales de tipo "S" (Activas)	
			FOREACH		
				                SELECT SKIP pRegistroInicial {+INDEX(si_sucursales idx_sucursal2)} sucursal, nombre
                INTO cClave, cNombre		  
				FROM bdinteg:si_sucursales				   
				WHERE tpo_sucursal = 'S'
				ORDER BY sucursal
				 
				RETURN cCodRet, cClave, cNombre	WITH RESUME;				  
			END FOREACH;	 
							
			-- Se valida que se haya obtenido información			
            IF nvl(cClave,'') = '' AND nvl(cNombre,'') = '' THEN			
				LET cCodRet = '999999';  -- No se encontró información			
				RETURN cCodRet, cClave, cNombre	WITH RESUME;				  
			END IF;
-- Se realiza la consulta por Tiendas Matriz
		ELSE		
			-- Se realiza la búsqueda en la tabla de las tiendas matriz
			FOREACH		
				                SELECT SKIP pRegistroInicial FIRST 1 {+INDEX(si_sucursales idx_sucursal2)} sucursal, nombre
                INTO cClave, cNombre		  
                FROM bdinteg:si_sucursales
                --WHERE tpo_sucursal = 'S' and sucursal = numsucursal AND tienda_matriz != 0
                WHERE tpo_sucursal = 'S' and sucursal = numsucursal
                ORDER BY sucursal
				
                RETURN cCodRet, cClave, cNombre WITH RESUME;				  
			END FOREACH;	 
							
			-- Se valida que se haya obtenido información
			IF nvl(cClave,'') = '' AND nvl(cNombre,'') = '' THEN			
				LET cCodRet = '999999';  -- No se encontró información			
				RETURN cCodRet, cClave, cNombre	WITH RESUME;				  
			END IF;			
		
		END IF;
					
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea SP para extraer los nombres de las sucursales',
'AUTOR : Jose Luis Polanco B.',
'FECHA : 01/11/2013',
'VERSION: 1.0',
'BD: BDINTEG',
'SISTEMA : INTRANET';

CREATE PROCEDURE  "informix".sp_cnsif_consdirec(cID_USUARIO CHAR(8),cID_FUNCION CHAR(10),cNUMCTE CHAR(20),cTBUSQUEDA CHAR(1),cTDOMICILIO CHAR(1),pNumRegistro INTEGER,pRecuperacion INTEGER)
       returning 	CHAR(5)  AS Cod_Retorno,
					CHAR(20) AS Numero_Cliente,
					CHAR(1)  AS Tipo_Direccion,
					INTEGER  AS Secuencia,
					CHAR(40) AS Calle,
					CHAR(10) AS Numero_Exterior_Calle,
					CHAR(10) AS Numero_Interior_Calle,
					CHAR(6)  AS Departamento,
					CHAR(60) AS Colonia,
					CHAR(60) AS Municipio,
					CHAR(60) AS Ciudad,
					CHAR(30) AS Estado,
					CHAR(20) AS Pais,
					CHAR(5)  AS Codigo_Postal,
					CHAR(13) AS Telefono_1,
					CHAR(13) AS Telefono_2,
					CHAR(13) AS Telefono_3,
					CHAR (5) AS Extension,
					CHAR(1)  AS Punto_Cardinal,
					CHAR(30) AS Manzana,
					CHAR(30) AS Otros,
					CHAR(30) AS Andador,
					CHAR(30) AS Etapa,
					CHAR(30) AS Lote,
					CHAR(30) AS Entrada,
					CHAR(30) AS Edificio,
					CHAR(40) AS Complemento,
					CHAR(80) AS Entre_Calles,
                    CHAR(15) AS Tipo_Dom,
					DATE	 AS fecha_insert;

					
DEFINE vcodret CHAR(5);
DEFINE vciclo SMALLINT;
DEFINE vsqlerr INTEGER;



DEFINE cNumcliente CHAR (20);
DEFINE vtipo_dir CHAR(1);
DEFINE vsecuencia INT;
DEFINE vcalle CHAR(40);
DEFINE vnumeroextcalle  CHAR(10);
DEFINE vnumerointcalle  CHAR(10);
DEFINE vdepartamento  CHAR(6);
DEFINE vcolonia CHAR(60);
DEFINE vmunicipio CHAR(60);
DEFINE vciudad CHAR(60);
DEFINE vestado CHAR(30);
DEFINE vpais CHAR(20);
DEFINE vcod_postal CHAR(5);
DEFINE vtelefono1 CHAR(13);
DEFINE vtelefono2  CHAR(13);
DEFINE vtelefono3  CHAR(13);
DEFINE vextension CHAR(5);
DEFINE vpuntocardinal  CHAR(1);
DEFINE vunidadhabitac  CHAR(1);
DEFINE vmanzana CHAR(30);
DEFINE votros  CHAR(30);
DEFINE vandador CHAR(30);
DEFINE vetapa CHAR(30);
DEFINE vlote  CHAR(30);
DEFINE ventrada  CHAR(30);
DEFINE vedificio  CHAR(30);
DEFINE ventre_calles CHAR(80);
DEFINE vobservaciones CHAR(40);
DEFINE iMaxdomicilio INTEGER;
DEFINE iexiste INTEGER;
DEFINE iCont INTEGER;
DEFINE dfecha_insert DATE;

--VARIABLES AUXILIARES
DEFINE vCvePais   CHAR(3);
DEFINE vCveEstado CHAR(2);
DEFINE vCveCiudad CHAR(3);
DEFINE vnumcalle  INTEGER;
DEFINE vnumerocolonia   INT;
DEFINE vnumerociudad    SMALLINT ;
DEFINE vcvemunicipio  CHAR(5);
DEFINE vCdCoppel        SMALLINT;
DEFINE vcvemanzana   SMALLINT;
DEFINE vcveotros     SMALLINT;
DEFINE vcveandador   SMALLINT;
DEFINE vcveetapa     SMALLINT;
DEFINE vcveedificio  SMALLINT;
DEFINE vcveentrada   SMALLINT;
DEFINE vcvelote      SMALLINT;

--VARIABLE PARA LOS TELEFONOS
DEFINE	vcodrett         CHAR(5);
DEFINE	vTelefono        CHAR(13);
DEFINE	vTipoTel         SMALLINT;
DEFINE	vSecuenciaTel    SMALLINT;
DEFINE	vStatus_Tel      CHAR(1);
DEFINE	vExtensionTel    CHAR(5);
DEFINE	vNombreCarrier   CHAR(20);
DEFINE	StatusValidacion SMALLINT;
DEFINE vCarrier         SMALLINT;
DEFINE cTipo_Dom        CHAR(15);

let vciclo = 0;
let vcodret = "00000";
let  vsqlerr = 0;

LET cNumcliente= "";
LET vtipo_dir = "";
LET vsecuencia = 0 ;
LET vcalle = "";
LET vnumeroextcalle  = "";
LET vnumerointcalle  = "";
LET vdepartamento  = "";
LET vcolonia = "";
LET vmunicipio = "";
LET vciudad = "";
LET vestado = "";
LET vpais = "";
LET vcod_postal  = "";
LET vtelefono1  = "";
LET vtelefono2   = "";
LET vtelefono3   = "";
LET vextension  = "";
LET vpuntocardinal   = "";
LET vunidadhabitac   = "";
LET vmanzana  = "";
LET votros   = "";
LET vandador  = "";
LET vetapa  = "";
LET vlote   = "";
LET ventrada   = "";
LET vedificio   = "";
LET ventre_calles = "";
LET vobservaciones = "";
LET iMaxdomicilio = 0;
LET iexiste = 0;
LET iCont=0;

--VARIABLES AUXILIARES
LET vCvePais   = "";
LET vCveEstado = "";
LET vCveCiudad = "";
LET vnumcalle  = 0;
LET vnumerocolonia = 0;
LET vnumerociudad = 0;
LET vcvemunicipio = "";
LET vCdCoppel = 0;
LET vcvemanzana = 0;
LET vcveotros = 0;
LET vcveandador = 0;
LET vcveetapa  = 0;
LET vcveedificio = 0;
LET vcveentrada = 0;
LET vcvelote    =0;

--variables para los telefonos
LET	vcodrett         = "";
LET	vTelefono        = "";
LET	vTipoTel         = 0;
LET	vSecuenciaTel    = 0;
LET	vStatus_Tel      = "";
LET	vExtensionTel    = "";
LET	vNombreCarrier   = "";
LET	StatusValidacion = 0;
LET	vCarrier = 0;
LET cTipo_Dom="";
LET dfecha_insert=TODAY;

BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         let vcodret = vsqlerr;
         return vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,vciudad,
		vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal,vmanzana,
		votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert;

      END IF;
   END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consdirec_2.out";
	--TRACE ON;
		
	IF cTBUSQUEDA <> '1' AND cTBUSQUEDA <> '0' THEN 
		LET vcodret = "00052";
		RETURN vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
		vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
		votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert;
	END IF; 	
	
	IF 	cID_USUARIO = ''OR
		cID_FUNCION =''	OR 
		cNUMCTE = 	'' 	OR 
		cTBUSQUEDA = ''	OR
		cTDOMICILIO = '' 	THEN
		LET vcodret = "00054";
		RETURN vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
			votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert;
	END IF;		

    IF pNumRegistro<0 THEN
        LET vcodret='00098';
        RETURN vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
			votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert;
    ELSE
        IF pRecuperacion<=0 THEN
            LET vcodret='00098';
            RETURN vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
                vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
                votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert;
        END IF;
    END IF;    	
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIO,cID_FUNCION, cNUMCTE,'11','2')
	INTO
	vcodret;
	IF (vcodret != '00000')  THEN
		RETURN vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			   vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
			   votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert;
	END IF;
	-- TERMINA VALIDACION		

    SELECT NVL(COUNT(numcte),0)  INTO iexiste FROM si_direcciones WHERE numcte = cNUMCTE; 

    IF iexiste = 0 THEN 
        LET vcodret = "00056";
        RETURN vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
        vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
        votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert;
    END IF;	

	IF cTBUSQUEDA = '1' THEN
 
		SELECT 	DI.numcte, DI.tipo_dir, DI.secuencia, DI.numeroextcalle, DI.numerointcalle,DI.departamento,
				DI.cod_postal, DI.numerocalle,DI.numerociudad,DI.numerocolonia,
				DI.estado,DI.pais,DI.municipio
		INTO    cNumcliente, vtipo_dir, vsecuencia, vnumeroextcalle, vnumerointcalle, vdepartamento,
				vcod_postal,vnumcalle,vnumerociudad,vnumerocolonia,
				vCveEstado,vCvePais,vcvemunicipio
		FROM si_direcciones_actual DI 		
		WHERE DI.numcte = cNUMCTE 		
		AND tipo_dir = cTDOMICILIO;
		
		EXECUTE PROCEDURE "informix".sp_consulta_telefonos('001',cNUMCTE,1,'0')
		INTO
		vcodrett, vTelefono, vTipoTel, vSecuenciaTel, vStatus_Tel, vExtensionTel,vCarrier, vNombreCarrier, StatusValidacion;
		
		LET vtelefono1 = vTelefono;
		
		EXECUTE PROCEDURE "informix".sp_consulta_telefonos('001',cNUMCTE,2,'0')
		INTO
		vcodrett, vTelefono, vTipoTel, vSecuenciaTel, vStatus_Tel, vExtensionTel,vCarrier, vNombreCarrier, StatusValidacion;
		
		LET vtelefono2 = vTelefono;
		LET vextension = vExtensionTel;
		
		EXECUTE PROCEDURE "informix".sp_consulta_telefonos('001',cNUMCTE,3,'0')
		INTO
		vcodrett, vTelefono, vTipoTel, vSecuenciaTel, vStatus_Tel, vExtensionTel,vCarrier, vNombreCarrier, StatusValidacion;
		
		LET vtelefono3 = vTelefono;
		
		SELECT nombre
		INTO vpais
		FROM si_paises
		WHERE pais = vCvePais;

		SELECT TRIM(nombre)
		INTO vestado
		FROM bdinteg:si_estados
		WHERE estado = vCveEstado;

		SELECT TRIM(nombreciudad), numerociudadcoppel
		INTO vciudad,vCdCoppel
		FROM bdinteg:si_catciudades
		WHERE numerociudad = vnumerociudad;		
		
		SELECT TRIM(nombrezona)
		INTO vcolonia
		FROM bdinteg:si_catzonas
		WHERE numerociudad = vnumerociudad
		AND numerocolonia = vnumerocolonia;
		
		SELECT TRIM(nombrecalle)
		INTO vcalle
		FROM bdinteg:si_catcalles
		WHERE numerocalle = vnumcalle;
		
		IF TRIM(vcvemunicipio) ='00000' THEN
			LET vcvemunicipio  = "";
			SELECT TRIM(municipiozona)
			  INTO vmunicipio
			  FROM bdinteg:si_catzonas
			 WHERE numerociudad = vnumerociudad
			   and numerocolonia  = vnumerocolonia;
		ELSE
			LET vmunicipio = vciudad;
		END IF;
		
		
	RETURN  	vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
				vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
				votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert;
				
    ELIF cTBUSQUEDA = '0' THEN 
	
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT SKIP pNumRegistro FIRST pRecuperacion 
				 DI.numcte,DI.tipo_dir,DI.secuencia,DI.numeroextcalle,DI.numerointcalle,DI.departamento,
				 DI.cod_postal, DI.puntocardinal,DI.manzana, DI.otros,DI.andador,DI.etapa,DI.lote,DI.entrada,
				 DI.edificio,DI.entre_calles,DI.observaciones,DI.numerocalle,DI.numerociudad,DI.numerocolonia,
				 DI.estado,DI.pais,DI.municipio,DECODE(DI.tipo_dir,"1","CASA","2","OFICINA","3","CORRESPONDENCIA"),fecha_insert
			INTO  cNumcliente,vtipo_dir,vsecuencia,vnumeroextcalle,vnumerointcalle,vdepartamento,
				  vcod_postal,vpuntocardinal, vcvemanzana,vcveotros,vcveandador,vcveetapa,vcvelote,vcveentrada,
				  vcveedificio,ventre_calles,vobservaciones,vnumcalle,vnumerociudad,vnumerocolonia,
				  vCveEstado,vCvePais,vcvemunicipio,cTipo_Dom,dfecha_insert
			FROM si_direcciones DI
			WHERE numcte = cNUMCTE
            ORDER BY 3 DESC
			
			EXECUTE PROCEDURE "informix".sp_consulta_telefonos('001',cNUMCTE,1,'0')
			INTO
			vcodrett, vTelefono, vTipoTel, vSecuenciaTel, vStatus_Tel, vExtensionTel,vCarrier, vNombreCarrier, StatusValidacion;
			
			LET vtelefono1 = vTelefono;
			
			EXECUTE PROCEDURE "informix".sp_consulta_telefonos('001',cNUMCTE,2,'0')
			INTO
			vcodrett, vTelefono, vTipoTel, vSecuenciaTel, vStatus_Tel, vExtensionTel,vCarrier, vNombreCarrier, StatusValidacion;
			
			LET vtelefono2 = vTelefono;
			LET vextension = vExtensionTel;
			
			EXECUTE PROCEDURE "informix".sp_consulta_telefonos('001',cNUMCTE,3,'0')
			INTO
			vcodrett, vTelefono, vTipoTel, vSecuenciaTel, vStatus_Tel, vExtensionTel,vCarrier, vNombreCarrier, StatusValidacion;
			
			LET vtelefono3 = vTelefono;
			
			SELECT nombre
			INTO vpais
			FROM si_paises
			WHERE pais = vCvePais;
		
			SELECT TRIM(nombre)
			INTO vestado
			FROM bdinteg:si_estados
			WHERE estado = vCveEstado;

			SELECT TRIM(nombreciudad), numerociudadcoppel
			INTO vciudad,vCdCoppel
			FROM bdinteg:si_catciudades
			WHERE numerociudad = vnumerociudad;
			
			SELECT TRIM(nombrezona)
			INTO vcolonia
			FROM bdinteg:si_catzonas
			WHERE numerociudad = vnumerociudad
			AND numerocolonia = vnumerocolonia;
			
			SELECT TRIM(nombrecalle)
			INTO vcalle
			FROM bdinteg:si_catcalles
			WHERE numerocalle = vnumcalle;
			
			IF TRIM(vcvemunicipio) ='00000' THEN
				LET vcvemunicipio  = "";

				SELECT TRIM(municipiozona)
				  INTO vmunicipio
				  FROM bdinteg:si_catzonas
				 WHERE numerociudad = vnumerociudad
				   and numerocolonia  = vnumerocolonia;
			ELSE
				LET vmunicipio = vciudad;
			END IF;
			
			 IF vcvemanzana > 0 THEN
				SELECT TRIM(nombredomicilio)
				  INTO vmanzana
				  FROM bdinteg:si_catdomicilios
				 WHERE numerociudad = vCdCoppel
				   AND numerocolonia = vnumerocolonia
				   AND clavedomicilio = 1
				   AND complementoclave = vcvemanzana;
			END IF;
			
			IF vcveotros > 0 THEN
				SELECT TRIM(nombredomicilio)
				  INTO votros
				  FROM bdinteg:si_catdomicilios
				 WHERE numerociudad = vCdCoppel
				   AND numerocolonia = vnumerocolonia
				   AND clavedomicilio = 2
				   AND complementoclave = vcveotros;
			END IF;

			IF vcveandador > 0 THEN
				SELECT TRIM(nombredomicilio)
				  INTO vandador
				  FROM bdinteg:si_catdomicilios
				 WHERE numerociudad = vCdCoppel
				   AND numerocolonia = vnumerocolonia
				   AND clavedomicilio = 3
				   AND complementoclave = vcveandador;
			END IF;

			IF vcveetapa > 0 THEN
				SELECT TRIM(nombredomicilio)
				  INTO vetapa
				  FROM bdinteg:si_catdomicilios
				 WHERE numerociudad = vCdCoppel
				   AND numerocolonia = vnumerocolonia
				   AND clavedomicilio = 4
				   AND complementoclave = vcveetapa;
			END IF;

			IF vcveedificio > 0 THEN
				SELECT TRIM(nombredomicilio)
				  INTO vedificio
				  FROM bdinteg:si_catdomicilios
				 WHERE numerociudad = vCdCoppel
				   AND numerocolonia = vnumerocolonia
				   AND clavedomicilio = 5
				   AND complementoclave = vcveedificio;
			END IF;

			IF vcveentrada > 0 THEN
				SELECT TRIM(nombredomicilio)
				  INTO ventrada
				  FROM bdinteg:si_catdomicilios
				 WHERE numerociudad = vCdCoppel
				   AND numerocolonia = vnumerocolonia
				   AND clavedomicilio = 6
				   AND complementoclave = vcveentrada;
			END IF;

			IF vcvelote > 0 THEN
				SELECT TRIM(nombredomicilio)
				  INTO vlote
				  FROM bdinteg:si_catdomicilios
				 WHERE numerociudad = vCdCoppel
				   AND numerocolonia = vnumerocolonia
				   AND clavedomicilio = 7
				   AND complementoclave = vcvelote;
			END IF;

            LET iCont=iCont + 1;	
			
			RETURN  vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
					vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
					votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert with resume;
					
		END FOREACH	; 
		
        IF iCont = 0 THEN
            LET vcodret = 1001; 
            RETURN  vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
			votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert;
        END IF 	
		
	END IF 
	
	
END
END PROCEDURE
DOCUMENT
"Autor : ARTURO CERVANTES PEÑA",
"FECHA : 01/MARZO/2012",
"FUNCIONAMIENTO:Dependiento del tipo de busqueda y del numero de usuario hara una busqueda de domicilio del cliente, la busqueda tipo 1",
"devolvera una sola direccion que sera la actual del cliente, se considerara la actual como la direccion con mayor secuencia dentro de la base",
"el tipo de busqueda 0 regresara todas las direcciones que el cliente tiene registradas dentro de la base de datos",
"Ver.  : 1.0",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cons_ref_cop(p_empresa char(3), p_sucursal char(4), p_usuario char(8), p_numcte char(20), p_referencia char(20),p_apellpat char(20),
											p_apellmat char(20),p_nom1 char(20),p_nom2 char(20), p_rfc char(13))
            RETURNING 
            char(5),char(1);

   DEFINE v_codret          char(5);
   DEFINE v_referencia		char(20);
   DEFINE v_apellpat		char(20);
   DEFINE v_apellmat		char(20);
   DEFINE v_nom1			char(20);
   DEFINE v_nom2			char(20);
   DEFINE v_rfc				char(13);
   DEFINE v_result			char(1);
   DEFINE sql_err,isam_err  int;
   DEFINE v_cuantos			int;
 
 -- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

        let v_codret            = "000";
        let v_referencia        = " ";        
        let v_apellpat          = " ";
		let v_apellmat          = " ";
        let v_nom1         		= " ";
        let v_nom2          	= " ";
		let v_rfc				= " ";
		let v_result			= " ";

--set debug file to "/tmp/sp_cons_ref_cop.txt";
--trace on;

BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
		 let v_result = '1';
         RETURN v_codret,v_result;
      end if;
   end exception;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  p_empresa is null or
        p_referencia is null or 
		p_apellpat is null or
		p_nom1 is null or		
		p_rfc is null
		then
       -- datos de entrada incompletos     
       let v_codret = 110; 
	   let v_result = '1';
       RETURN v_codret,v_result;
    END IF;

-- ****************************************************************************
-- Consultar datos
-- ****************************************************************************

	SELECT COUNT(numcte) INTO v_cuantos FROM bdinteg:si_cliente WHERE numcte_ref = p_referencia;

	IF v_cuantos <= 1 THEN

		IF EXISTS (SELECT numcte_ref FROM bdinteg:si_cliente WHERE numcte_ref = p_referencia) THEN
			SELECT numcte_ref, rfc, nombre1, nombre2, apell_paterno, apell_materno
			INTO v_referencia, v_rfc, v_nom1, v_nom2, v_apellpat, v_apellmat
			FROM bdinteg:si_cliente
			WHERE numcte_ref = p_referencia;
			IF 	TRIM(p_referencia) = TRIM(v_referencia)
				AND TRIM(p_rfc) = TRIM(v_rfc)
				AND TRIM(p_nom1) = TRIM(v_nom1)
				AND TRIM(p_nom2) = TRIM(v_nom2)
				AND TRIM(p_apellpat) = TRIM(v_apellpat)
				AND	TRIM(p_apellmat) = TRIM(v_apellmat)
			THEN
				LET v_codret = '000';
                        LET v_result = '0';
			ELSE
				LET v_codret = '000';
				LET v_result = '1';
				INSERT INTO bdinteg:si_bitacora_refcop(empresa, numcte, numcte_ref, rfc, sucursal, usuario, apell_paterno, apell_materno, nombre1, nombre2, fecha_insert)
					VALUES(p_empresa,p_numcte,p_referencia,p_rfc,p_sucursal, p_usuario,p_apellpat,p_apellmat,p_nom1,p_nom2, CURRENT);
			END IF;
		ELSE
				LET v_codret = '000';
				LET v_result = '0';	
		END IF;
	
	ELSE
		LET v_codret = '000';
		LET v_result = '1';
		INSERT INTO bdinteg:si_bitacora_refcop(empresa, numcte, numcte_ref, rfc, sucursal, usuario, apell_paterno, apell_materno, nombre1, nombre2, fecha_insert)
			VALUES(p_empresa,p_numcte,p_referencia,p_rfc,p_sucursal, p_usuario,p_apellpat,p_apellmat,p_nom1,p_nom2, CURRENT);
	END IF;		
	
	RETURN v_codret,v_result;

END;    
END PROCEDURE;