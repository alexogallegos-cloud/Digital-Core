CREATE PROCEDURE  "informix".sp_cnsif_consdirec3(cID_USUARIO CHAR(8),cID_FUNCION CHAR(10),cNUMCTE CHAR(20),cTBUSQUEDA CHAR(1),cTDOMICILIO CHAR(1),pNumRegistro INTEGER,pRecuperacion INTEGER)
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
					DATE	 AS fecha_insert,
					CHAR(4) AS sucursal,
					CHAR(20) AS empleado,
					DATE AS fecha_hr;

					
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
DEFINE cSucursal CHAR(4);
DEFINE cEmpleado CHAR(20);
DEFINE dFechaHr DATE;

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
LET cSucursal = '';
LET cEmpleado = '';
LET dFechaHr = '';

BEGIN
   ON EXCEPTION SET vsqlerr
	  IF vsqlerr <> 0 THEN
		 let vcodret = vsqlerr;
		 return vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,vciudad,
		vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal,vmanzana,
		votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert,cSucursal,cEmpleado,dFechaHr;

	  END IF;
   END EXCEPTION;
	
	--SET DEBUG FILE TO "/ifxsif01/LIP/sp_cnsif_consdirec3.out";
	--TRACE ON;
		
	IF cTBUSQUEDA <> '1' AND cTBUSQUEDA <> '0' THEN 
		LET vcodret = "00052";
		RETURN vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
		vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
		votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert,cSucursal,cEmpleado,dFechaHr;
	END IF; 	
	
	IF 	cID_USUARIO = ''OR
		cID_FUNCION =''	OR 
		cNUMCTE = 	'' 	OR 
		cTBUSQUEDA = ''	OR
		cTDOMICILIO = '' 	THEN
		LET vcodret = "00054";
		RETURN vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
			votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert,cSucursal,cEmpleado,dFechaHr;
	END IF;		

    IF pNumRegistro<0 THEN
        LET vcodret='00098';
        RETURN vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
			votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert,cSucursal,cEmpleado,dFechaHr;
    ELSE
        IF pRecuperacion<=0 THEN
            LET vcodret='00098';
            RETURN vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
                vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
                votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert,cSucursal,cEmpleado,dFechaHr;
        END IF;
    END IF;    	
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIO,cID_FUNCION, cNUMCTE,'11','2')
	INTO
	vcodret;
	IF (vcodret != '00000')  THEN
		RETURN vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			   vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
			   votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert,cSucursal,cEmpleado,dFechaHr;
	END IF;
	-- TERMINA VALIDACION		

    SELECT NVL(COUNT(numcte),0)  INTO iexiste FROM si_direcciones WHERE numcte = cNUMCTE; 

    IF iexiste = 0 THEN 
        LET vcodret = "00056";
        RETURN vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
        vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
        votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert,cSucursal,cEmpleado,dFechaHr;
    END IF;	

	IF cTBUSQUEDA = '1' THEN
 
		SELECT 	DI.numcte, DI.tipo_dir, DI.secuencia, DI.numeroextcalle, DI.numerointcalle,DI.departamento,
				DI.cod_postal, DI.numerocalle,DI.numerociudad,DI.numerocolonia,
				DI.estado,DI.ciudad,DI.pais,DI.municipio, DI.user_insert, DI.fecha_insert
		INTO    cNumcliente, vtipo_dir, vsecuencia, vnumeroextcalle, vnumerointcalle, vdepartamento,
				vcod_postal,vnumcalle,vnumerociudad,vnumerocolonia,
				vCveEstado,vCveCiudad,vCvePais,vcvemunicipio, cEmpleado, dFechaHr
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
		
		SELECT TRIM(nombre)
		INTO vciudad
		FROM bdinteg:si_ciudades
		WHERE estado = vCveEstado and ciudad = vCveCiudad;
		
		
		SELECT TRIM(nombrezona)
		INTO vcolonia
		FROM bdinteg:si_catzonas
		WHERE numerociudad = vnumerociudad
		AND numerocolonia = vnumerocolonia;
		
		SELECT TRIM(nombrecalle)
		INTO vcalle
		FROM bdinteg:si_catcalles
		WHERE numerocalle = vnumcalle;
		
		--IF TRIM(vcvemunicipio) ='00000' THEN
			--LET vcvemunicipio  = "";
			SELECT TRIM(municipiozona)
			  INTO vmunicipio
			  FROM bdinteg:si_catzonas
			 WHERE numerociudad = vnumerociudad
			   and numerocolonia  = vnumerocolonia;
		--ELSE
			--LET vmunicipio = vciudad;
		--END IF;
		
		IF cEmpleado <> '' THEN		
			SELECT sucursal
			INTO cSucursal
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo = cEmpleado;
		END IF;
		
	RETURN  	vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
				vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
				votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert,cSucursal,cEmpleado,dFechaHr;
				
    ELIF cTBUSQUEDA = '0' THEN 
	
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT SKIP pNumRegistro FIRST pRecuperacion 
				 DI.numcte,DI.tipo_dir,DI.secuencia,DI.numeroextcalle,DI.numerointcalle,DI.departamento,
				 DI.cod_postal, DI.puntocardinal,DI.manzana, DI.otros,DI.andador,DI.etapa,DI.lote,DI.entrada,
				 DI.edificio,DI.entre_calles,DI.observaciones,DI.numerocalle,DI.numerociudad,DI.numerocolonia,
				 DI.estado,DI.ciudad,DI.pais,DI.municipio,DECODE(DI.tipo_dir,"1","CASA","2","OFICINA","3","CORRESPONDENCIA"),DI.fecha_insert,
				 DI.user_insert, DI.fecha_insert
			INTO  cNumcliente,vtipo_dir,vsecuencia,vnumeroextcalle,vnumerointcalle,vdepartamento,
				  vcod_postal,vpuntocardinal, vcvemanzana,vcveotros,vcveandador,vcveetapa,vcvelote,vcveentrada,
				  vcveedificio,ventre_calles,vobservaciones,vnumcalle,vnumerociudad,vnumerocolonia,
				  vCveEstado,vCveCiudad,vCvePais,vcvemunicipio,cTipo_Dom,dfecha_insert,cEmpleado,dFechaHr
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
			
			SELECT TRIM(nombre)
			INTO vciudad
			FROM bdinteg:si_ciudades
			WHERE estado = vCveEstado and ciudad = vCveCiudad;
			
			
			SELECT TRIM(nombrezona)
			INTO vcolonia
			FROM bdinteg:si_catzonas
			WHERE numerociudad = vnumerociudad
			AND numerocolonia = vnumerocolonia;
			
			SELECT TRIM(nombrecalle)
			INTO vcalle
			FROM bdinteg:si_catcalles
			WHERE numerocalle = vnumcalle;
			
			--IF TRIM(vcvemunicipio) ='00000' THEN
				--LET vcvemunicipio  = "";

				SELECT TRIM(municipiozona)
				  INTO vmunicipio
				  FROM bdinteg:si_catzonas
				 WHERE numerociudad = vnumerociudad
				   and numerocolonia  = vnumerocolonia;
			--ELSE
				--LET vmunicipio = vciudad;
			--END IF;
			
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
			
			IF cEmpleado <> '' THEN
				SELECT sucursal
				INTO cSucursal
				FROM bdinteg:"informix".si_ejecut
				WHERE ejecutivo = cEmpleado;
			END IF;
			
            LET iCont=iCont + 1;	
			
			RETURN  vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
					vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
					votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert,cSucursal,cEmpleado,dFechaHr with resume;
			
			LET cSucursal = '';
			LET cEmpleado = '';
			LET dFechaHr = '';
			
		END FOREACH	; 
		
        IF iCont = 0 THEN
            LET vcodret = 1001; 
            RETURN  vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
			votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert,cSucursal,cEmpleado,dFechaHr;
        END IF 	
		
	END IF 
	
	
END
END PROCEDURE
DOCUMENT
"Autor : ARTURO CERVANTES PEÃÂA",
"FECHA : 01/MARZO/2012",
"FUNCIONAMIENTO:Dependiento del tipo de busqueda y del numero de usuario hara una busqueda de domicilio del cliente, la busqueda tipo 1",
"devolvera una sola direccion que sera la actual del cliente, se considerara la actual como la direccion con mayor secuencia dentro de la base",
"el tipo de busqueda 0 regresara todas las direcciones que el cliente tiene registradas dentro de la base de datos",
"Autor : L. Montserrat LeÃÂ³n Amador",
"FECHA : 17/05/2019",
"MODIFICACIÃÂN: Se realiza clonaciÃÂ³n de SPL sp_cnsif_consdirec para agregar nuevos campos de retorno (cSucursal,cEmpleado,dFechaHr).",
"Ver.  : 1.0",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_autoriza_datos_contacto(pcliente CHAR(20), pejecutivo CHAR(8), psucursal CHAR(4), pcanal CHAR(1), pintentos char(1), prespuesta CHAR(1), popcion CHAR(1))
   RETURNING CHAR(3);

    -- ****************************************************************************
	-- *                        DEFINICION DE VARIABLES                           *
	-- ****************************************************************************
	
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cNumCte CHAR(20);
	DEFINE sExiste CHAR(9);

	-- ****************************************************************************
	-- *                        ASIGNACION DE VARIABLES                           *
	-- ****************************************************************************
	
	LET iSqlErr = 0;
	LET cCodRet = '';
	LET sExiste='';
	
	BEGIN

		ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
		   IF iSqlErr <> 0 THEN
			   LET cCodRet = iSqlErr;
			   RETURN cCodRet;
		   END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		--SET DEBUG FILE TO '/tmp/anj/sp_autoriza_datos_contacto.sql';
		--	TRACE ON;
	
        SELECT COUNT(numcte) INTO sExiste  
		FROM si_autoriza_datos_contacto 
		WHERE (numcte=pcliente AND flag='1')
		OR (numcte=pcliente AND flag='0' AND canal='1')
		OR (numcte=pcliente AND flag='0' AND fecha_confirma IS NOT NULL);
							 
        IF popcion=1 AND sExiste<> 0 THEN
           LET cCodRet = '001'; --CLIENTE YA ESTA CON LA BANDERA EN 1
        ELIF popcion=2 THEN
				SELECT COUNT(numcte) INTO sExiste  
				FROM si_autoriza_datos_contacto WHERE numcte=pcliente;

                IF sExiste='0' THEN
                   IF prespuesta='0' then
                      INSERT INTO si_autoriza_datos_contacto VALUES ('001', pcliente, pejecutivo, psucursal, pcanal, pintentos, 0, CURRENT, CURRENT, NULL, prespuesta);
                   ELSE
                      INSERT INTO si_autoriza_datos_contacto VALUES ('001', pcliente, pejecutivo, psucursal, pcanal, pintentos, 0, CURRENT, CURRENT, CURRENT, prespuesta);
                   END IF;
                ELSE
                   IF prespuesta='0' THEN
                      UPDATE si_autoriza_datos_contacto SET ejecutivo= pejecutivo, sucursal=psucursal, canal=pcanal, intentos=intentos+pintentos, fecha_consulta=CURRENT, flag=prespuesta where numcte=pcliente;
                   ELSE
                      UPDATE si_autoriza_datos_contacto SET ejecutivo= pejecutivo, sucursal=psucursal, canal=pcanal, intentos=intentos+pintentos, fecha_consulta=CURRENT, fecha_confirma=CURRENT, flag=prespuesta where numcte=pcliente;
                   END IF;
				   
                END IF;
                LET cCodRet = '000';
        ELSE
           LET cCodRet = '000';
        END IF;

RETURN cCodRet;
END;
END PROCEDURE
	DOCUMENT
	'----------------------------------------------------------------------------',
	'--Autor: 97523641 Alberto Sanchez',
	'--Folio: 869.1- Cuestionario de PLD en Apertura de Productos Complementaria 5.',
	'--Fecha: 25/02/2023.',
	'--Solicita:', 
	'--Descripcion: Se crea procedimiento almacenado para registro de autorizacion',
	'-- de compartir datos con coppel',
	'--BD: bdinteg.',
	'-- --------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_consultarostroslinea_pa(pNumCte CHAR(20))

--DATOS A REGRESAR---
RETURNING             	
	CHAR(5) 	AS CodRet,
	CHAR(3) 	AS empresa,
	SMALLINT 	AS secuencia,
	CHAR(20) 	AS numcte,
	CHAR(4) 	AS sucursal,
	CHAR(20) 	AS fecha_consulta,
	CHAR(15) 	AS ip,
	CHAR(1)		AS sexo,
	SMALLINT	AS tipo_mov,
	CHAR(1)		AS validate_ine;

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_consultarostroslinea_pa "
Folio.........: 712.1 - EnvÃ­o de decÃ¡logo de huellas.
Autor.........: 90127902 - Carlos VÃ¡zquez Mitre
Fecha.........: 27/01/2021
Solicita......: Juan Francisco Ponce Damian
BD............: bdinteg
VersiÃ³n.......: 20/08/2021
-------------------

Autor::::::: Gabriel Romero Cuauhitzo
Descripcion.....: Se agrega campo origen_ticket, para ser contemplado para guardar en la tabla si_rostro_linea_hist
RQI.......: 63 720
Version.......: 26/10/2021
--------------------
Autor::::::: Jesus Daniel Guerrero Benitez, Gabriel Romero Cuauhitzo, Jahaziel Eduardo Heredia Hinojosa 
Descripcion.....: Se elimino el FOREACH y se aÃ±adiÃ³ el limit 1 para que devolviera solo un cliente, tambiÃ©n se excluyo a los clientes BEX y se aÃ±adiÃ³ el cÃ³digo retorno 00002 para excluir las imÃ¡genes que se estÃ©n volviendo a mandar.
RQI.......: 63 895
Version.......: 24/01/2023
Solicita......: Juan Francisco Ponce Damian
-------------------
Autor::::::: Gabriel Romero Cuauhitzo 
Descripcion.....: Se hace una mejora en lÃ³gica para cambiar el valor de iTipoMov en los casos siguientes

	 * Caso 1 Alta de cliente: sin registro en la si_rostro_linea y registrado en la si_cte_rostro con secuencia_control = 1 -> insert cliente en la si_rostro_linea con tipo_mov = 1
	 
	 * Caso 2 Cliente ya con captura de rostro: registro en la si_cte_rostro con secuencia_control = 3 y registro en la si_rostro_linea con secuencia = 2 y tipo_mov = 3 -> insert cliente en la si_rostro_linea con tipo_mov = 1
	 
	 * Caso 3 Cliente Mantenimiento tipo_mov = 3 : registro en la si_cte_rostro con secuencia_control = 4 y registro en la si_rostro_linea con secuencia = 3 y tipo_mov = 1 -> insert cliente en la si_rostro_linea con tipo_mov = 3
     
	 lineas modificas de la 114 a 118
RQI.......: 63914
Version.......: 16/03/2023
Solicita......: Juan Francisco Ponce Damian
*/

-- DEFINICION DE VARIABLES.
DEFINE cCodRet			CHAR(5);
DEFINE iSqlErr			INTEGER;
DEFINE cEmpresa			CHAR(3);
DEFINE shSecuencia		SMALLINT;
DEFINE cNumCte			CHAR(20);
DEFINE cSucursal		CHAR(4);
DEFINE cIp				CHAR(15);
DEFINE cFechaConsulta	DATE;
DEFINE iContador		INTEGER;
DEFINE cSexo			CHAR(1);
DEFINE iTipoMov			SMALLINT;
DEFINE cValidateIne		CHAR(1);
DEFINE cTicket			CHAR(50);

--SET DEBUG FILE TO '/informix/jfponce/gabriel/err/sp_consultarostroslinea_pa.out';
--TRACE ON;

-- INICIALIZACION DE VARIABLE.
LET cCodRet				= '00001';
LET iSqlErr				= 0;
LET cEmpresa			= '';
LET shSecuencia			= 0;
LET cNumCte				= '';
LET cSucursal			= '';
LET cIp					= '';
LET iContador			= 0;
LET cSexo				= '';
LET iTipoMov			= 1;
LET cValidateIne		= 'F';
LET cFechaConsulta 		= CURRENT::DATE;
LET cTicket				= '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF(iSqlErr != 0) THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEmpresa,shSecuencia, cNumCte, cSucursal,cIp, cFechaConsulta, cSexo, iTipoMov, cValidateIne;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	
	SELECT LIMIT 1 empresa,secuencia_control, numcte, sucursal,ip 
	INTO cEmpresa, shSecuencia, cNumCte, cSucursal, cIp 
	FROM bdirostros@coppelimg_tcp:"informix".si_cte_rostro
	--FROM  "informix".si_cte_rostro
	--FROM  bdirostros:si_cte_rostro 
	WHERE numcte = pNumCte AND ip != '' AND secuencia = 1 AND usuario != 'BEX' AND estado = 'A';
	
	
	IF cNumCte <> '' THEN 

		IF(shSecuencia <> 1) THEN
			
			IF EXISTS(SELECT numcte FROM "informix".si_rostro_linea WHERE numcte = pNumCte AND tipo_mov='1') THEN
			  
                LET iTipoMov = 3;
				
            END IF;
			
		END IF;
			
		SELECT LIMIT 1 sexo INTO cSexo FROM "informix".si_ctepf WHERE numcte = pNumCte;
			
		IF EXISTS(SELECT numcte FROM "informix".si_bitacora_huella_ine WHERE numcte = pNumCte) THEN
				LET cValidateIne = 'T';
		END IF;
			
			--
		IF EXISTS(SELECT numcte FROM "informix".si_rostro_linea WHERE secuencia >= shSecuencia AND (status_consulta = '2' OR status_consulta = '3') AND numcte = pNumCte) THEN
			 LET cCodRet = '00002';
		ELSE
				-- 
				IF(NVL(cSexo,'') = '' )THEN
						LET cCodRet = '00003';
				ELSE	
						LET cCodRet = '00000';
						
					IF EXISTS (SELECT numcte FROM "informix".si_rostro_linea WHERE secuencia = shSecuencia AND numcte = pNumCte) THEN
						INSERT INTO "informix".si_rostro_linea_hist(secuencia, numcte, sucursal, fecha_consulta, sexo, ip, tipo_mov, ticket, status_consulta, ine, origen_ticket, origen_result, fecha_result, 
																	status_result, desc_result, match_result, num_match_result, codret_result, code_service, fecha_env, fecha_resp) 
						SELECT secuencia, numcte, sucursal, fecha_consulta, sexo, ip, tipo_mov, ticket, status_consulta, ine, origen_ticket, origen_result, fecha_result, status_result, desc_result, 
								match_result, num_match_result, codret_result, code_service, fecha_env, fecha_resp
						FROM "informix".si_rostro_linea WHERE secuencia = shSecuencia AND numcte = pNumCte;
						
						SELECT ticket INTO cTicket FROM "informix".si_rostro_linea WHERE secuencia = shSecuencia AND numcte = pNumCte;
						
						IF (NVL(cTicket, '') <> '') THEN
							INSERT INTO "informix".si_rostro_linea_result_hist(id_hist, ticket, numcte_match, empresa_match, 
																			   sitesp_match, porc_match,Fecha_insert,
																				   origen_result,num_match_result) 
							SELECT id, ticket, numcte_match, empresa_match, sitesp_match, porc_match,Fecha_insert,
								   origen_result,num_match_result
							FROM "informix".si_rostro_linea_result WHERE ticket = cTicket;
							
							DELETE FROM "informix".si_rostro_linea_result WHERE ticket = cTicket;
						END IF;	
						
						DELETE FROM "informix".si_rostro_linea WHERE secuencia = shSecuencia AND numcte = pNumCte;
					END IF;
					
					
					INSERT INTO "informix".si_rostro_linea (secuencia, numcte, sucursal, fecha_consulta, sexo, ip, tipo_mov, ticket, status_consulta, ine)
					VALUES(shSecuencia, pNumCte, cSucursal, cFechaConsulta, cSexo, cIp, iTipoMov, '', '0', cValidateIne);
					
				END IF;
		END IF;
		RETURN cCodRet, cEmpresa, shSecuencia, cNumCte, cSucursal, cFechaConsulta, cIp, cSexo, iTipoMov, cValidateIne WITH RESUME;
	ELSE
		RETURN cCodRet, cEmpresa, shSecuencia, cNumCte, cSucursal, cFechaConsulta, cIp, cSexo, iTipoMov, cValidateIne WITH RESUME;
	END IF;
	
	--IF (iContador <= 0) THEN
	--RETURN cCodRet, cEmpresa, shSecuencia, cNumCte, cSucursal, cFechaConsulta, cIp, cSexo, iTipoMov, cValidateIne WITH RESUME;
	--END IF;
	
END;
END PROCEDURE;