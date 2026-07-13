CREATE PROCEDURE "informix".sp_obtienereporte_ferrararelojes(piConsulta INTEGER, piRenglon INTEGER)
RETURNING CHAR(5), CHAR(100), CHAR(100), CHAR(100), CHAR(100), CHAR(40), CHAR(10), CHAR(10), CHAR(20), CHAR(20), CHAR(10), CHAR(10);

DEFINE vsCodRet				CHAR(5);
DEFINE viSqlErr				INTEGER;

DEFINE vsFecIniCamp			CHAR(100);
DEFINE vsCuenta				CHAR(100);
DEFINE vsClabe				CHAR(100);
DEFINE vsRuta				CHAR(100);

DEFINE  vsSucursal				CHAR(4);
DEFINE	vsZona_bancoppel		CHAR(50);
DEFINE	vsEstado				CHAR(30);
DEFINE	vsCiudad_municipio		CHAR(60);
DEFINE	vsNombre_sucursal		CHAR(40);
DEFINE	vsNo_depositos_acum		CHAR(10);
DEFINE	vsImporte_acum			CHAR(20);
DEFINE	vsOtorgados_cte			CHAR(10);
DEFINE	vsEntregados_suc		CHAR(10);
DEFINE	vdDonativo_prom			DECIMAL(18,2);
DEFINE  vsRelojes_existentes	CHAR(10);
DEFINE	vsFecha_reporte			CHAR(10);
DEFINE  viCantidadRegistros		INTEGER;

LET vsCodRet				= '00000';
LET viSqlErr				= 0;

LET vsFecIniCamp			= '';
LET vsCuenta				= '';
LET vsClabe					= '';
LET vsRuta				    = '';

LET vsSucursal				= '';
LET	vsZona_bancoppel		= '';
LET	vsEstado				= '';
LET	vsCiudad_municipio		= '';
LET	vsNombre_sucursal		= '';
LET	vsNo_depositos_acum		= '';
LET	vsImporte_acum			= '';
LET	vsOtorgados_cte			= '';
LET	vsEntregados_suc		= '';
LET	vdDonativo_prom			= 0.00;
LET vsRelojes_existentes	= '';
LET	vsFecha_reporte			= '';
LET viCantidadRegistros     = 10;

--SET DEBUG FILE TO "/dbexport/sp_obtienereporte_ferrararelojes.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr
	IF (viSqlErr <> 0) THEN
		RETURN NVL(viSqlErr, ''), NVL(vsSucursal, ''), NVL(vsZona_bancoppel, ''), NVL(vsEstado, ''), NVL(vsCiudad_municipio, ''), NVL(vsNombre_sucursal, ''), NVL(vsEntregados_suc, ''),
               NVL(vsNo_depositos_acum, ''), NVL(vsImporte_acum, ''), NVL(vdDonativo_prom, ''), NVL(vsRelojes_existentes, ''), NVL(vsFecha_reporte, '');
	END IF;
END EXCEPTION;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

IF(piConsulta = 0) THEN
	SELECT valor INTO vsFecIniCamp FROM bdinteg:"informix".si_ferrara_relojes_param WHERE id_param = '1';
	SELECT valor INTO vsCuenta FROM bdinteg:"informix".si_ferrara_relojes_param WHERE id_param = '4';
	SELECT valor INTO vsClabe FROM bdinteg:"informix".si_ferrara_relojes_param WHERE id_param = '5';
	SELECT valor INTO vsRuta FROM bdinteg:"informix".si_ferrara_relojes_param WHERE id_param = '6';

	RETURN NVL(vsCodRet, ''), NVL(vsFecIniCamp, ''), NVL(vsCuenta, ''), NVL(vsClabe, ''), NVL(vsRuta, ''), NVL(vsNombre_sucursal, ''), NVL(vsEntregados_suc, ''), NVL(vsNo_depositos_acum, ''), NVL(vsImporte_acum, ''),
		   NVL(vdDonativo_prom, ''), NVL(vsRelojes_existentes, ''), NVL(vsFecha_reporte, '') WITH RESUME;	   
		   
	SELECT COUNT(sucursal), '', '', '', '', SUM(entregados_suc), SUM(no_depositos_acum), SUM(importe_acum),
		   SUM(donativo_prom), SUM(relojes_existentes), ''
	INTO   vsSucursal, vsZona_bancoppel, vsEstado, vsCiudad_municipio, vsNombre_sucursal, vsEntregados_suc, 
	       vsNo_depositos_acum, vsImporte_acum, vdDonativo_prom, vsRelojes_existentes, vsFecha_reporte
	FROM bdinteg:"informix".si_ferrara_relojes WHERE fecha_reporte = CURRENT::DATE;
	
	LET vdDonativo_prom = (vdDonativo_prom / vsSucursal);	
	RETURN NVL(vsCodRet, ''), NVL(vsSucursal, ''), NVL(vsZona_bancoppel, ''), NVL(vsEstado, ''), NVL(vsCiudad_municipio, ''), NVL(vsNombre_sucursal, ''), NVL(vsEntregados_suc, ''),
           NVL(vsNo_depositos_acum, ''), NVL(vsImporte_acum, ''), NVL(vdDonativo_prom, ''), NVL(vsRelojes_existentes, ''), NVL(vsFecha_reporte, '') WITH RESUME;	   
END IF;

IF(piConsulta = 1) THEN  
	FOREACH
		SELECT SKIP piRenglon FIRST viCantidadRegistros sucursal, zona_bancoppel, estado, ciudad_municipio, nombre_sucursal, entregados_suc, no_depositos_acum, importe_acum,
			   donativo_prom, relojes_existentes, fecha_reporte	   
		INTO vsSucursal, vsZona_bancoppel, vsEstado, vsCiudad_municipio, vsNombre_sucursal, vsEntregados_suc, vsNo_depositos_acum, vsImporte_acum,
			 vdDonativo_prom, vsRelojes_existentes, vsFecha_reporte
		FROM bdinteg:"informix".si_ferrara_relojes WHERE fecha_reporte = CURRENT::DATE
		ORDER BY sucursal
		
		RETURN NVL(vsCodRet, ''), NVL(vsSucursal, ''), NVL(vsZona_bancoppel, ''), NVL(vsEstado, ''), NVL(vsCiudad_municipio, ''), NVL(vsNombre_sucursal, ''), NVL(vsEntregados_suc, ''),
               NVL(vsNo_depositos_acum, ''), NVL(vsImporte_acum, ''), NVL(vdDonativo_prom, ''), NVL(vsRelojes_existentes, ''), NVL(vsFecha_reporte, '') WITH RESUME;
	END FOREACH	
END IF;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'PROYECTO: Donativos Fundación Ferrara', 
'SOLICITÓ: José Arturo Cruz Espino',
'DESCRIPCIÓN: ',
'FECHA: 2012/08/10',
'VERSIÓN: 20120810.1800',
'BD: bdinteg';

CREATE PROCEDURE "informix".direcciones_pba( pEmpresa CHAR(3),
                                         pFuncion CHAR(1),
                                         pNumCte CHAR(20),
                                         pSecuencia SMALLINT,
                                         pTipoDir CHAR(1),
                                         pCalle CHAR(40),
                                         pColonia CHAR(60),
                                         pMunicipio CHAR(5),
                                         pEntre_Calles CHAR(40),
                                         pPais CHAR(3),
                                         pEntidad CHAR(2),
                                         pLocalidad CHAR(3),
                                         pCodPostal CHAR(5),
                                         pTipoTel1 CHAR(1),
                                         pTelefono1 CHAR(13),
                                         pTipoTel2 CHAR(1),
                                         pTelefono2 CHAR(13),
                                         pTipoTel3 CHAR(1),
                                         pTelefono3 CHAR(13),
                                         pExtension CHAR(5),
                                         pEstado_Inegi CHAR(2),
                                         pMunicipio_Inegi CHAR(3),
                                         pLocalidad_Inegi CHAR(4),
                                         pNoCiudad SMALLINT,
                                         pNoExt CHAR(10),
                                         pNoInt CHAR(10),
                                         pDepto CHAR(6),
                                         pNoCalle INTEGER,
                                         pNoColonia INTEGER,
                                         pPuntoCar CHAR(1),
                                         pUniHabi CHAR(1),
                                         pManz SMALLINT,
                                         pPOtros SMALLINT,
                                         pAndador SMALLINT,
                                         pEtapa SMALLINT,
                                         pLote SMALLINT,
                                         pEdif SMALLINT,
                                         pEntrada SMALLINT,
                                         pObserva CHAR(80),
                                         pUser_Insert CHAR(8),
                                         pFecha_Insert DATE,
                                         cSucursal CHAR(4) )
RETURNING CHAR(5);

    DEFINE v_CodRet CHAR(5);
    DEFINE v_RowId INTEGER;
    DEFINE v_TipoDir CHAR(1);
    DEFINE v_Calle CHAR(40);
    DEFINE v_Colonia CHAR(60);
    DEFINE v_Delegacion CHAR(20);
    DEFINE v_Entre_Calles CHAR(40);
    DEFINE v_Pais CHAR(3);
    DEFINE v_Entidad CHAR(2);
    DEFINE v_Localidad CHAR(3);
    DEFINE v_CodPostal CHAR(5);
    DEFINE v_Telefono1 CHAR(20);
    DEFINE v_Telefono2 CHAR(20);
    DEFINE v_Estado_Inegi CHAR(2);
    DEFINE v_Municipio_Inegi CHAR(3);
    DEFINE v_Localidad_Inegi CHAR(4);
    DEFINE v_Fax CHAR(20);
    DEFINE v_Nombre CHAR(40);
    DEFINE v_Longitud, v_LongCte, v_Secuencia SMALLINT;
    DEFINE v_NumCte CHAR(20);
    DEFINE v_Existe CHAR(1);
    DEFINE v_SqlErr, v_IsamErr INTEGER;
    
    define pSecuencia_compara integer;
    define pcoincide integer;

    DEFINE o_tipo_dir       	CHAR(1);
    DEFINE o_calle          	CHAR(40);
    DEFINE o_colonia        	CHAR(60);
    DEFINE o_entre_calles   	CHAR(40);
    DEFINE o_pais           	CHAR(3);
    DEFINE o_estado         	CHAR(2);
    DEFINE o_ciudad         	CHAR(3);
    DEFINE o_municipio      	CHAR(5);
    DEFINE o_cod_postal     	CHAR(5);
    DEFINE o_apart_postal   	CHAR(11);
    DEFINE o_tipo_telef1    	CHAR(1);
    DEFINE o_telefono1      	CHAR(13);
    DEFINE o_tipo_telef2    	CHAR(1);
    DEFINE o_telefono2      	CHAR(13);
    DEFINE o_tipo_telef3    	CHAR(1);
    DEFINE o_telefono3      	CHAR(13);
    DEFINE o_extension      	CHAR(5);
    DEFINE o_estado_inegi   	CHAR(2);
    DEFINE o_municipio_inegi	CHAR(3);
    DEFINE o_localidad_inegi	CHAR(4);
    DEFINE o_numerociudad   	SMALLINT;
    DEFINE o_numeroextcalle 	CHAR(10);
    DEFINE o_numerointcalle 	CHAR(10);
    DEFINE o_departamento   	CHAR(6);
    DEFINE o_numerocalle    	INTEGER;
    DEFINE o_numerocolonia  	INTEGER;
    DEFINE o_puntocardinal  	CHAR(1);
    DEFINE o_unidadhabitac  	CHAR(1);
    DEFINE o_manzana        	SMALLINT;
    DEFINE o_otros          	SMALLINT;
    DEFINE o_andador        	SMALLINT;
    DEFINE o_etapa          	SMALLINT;
    DEFINE o_lote           	SMALLINT;
    DEFINE o_edificio       	SMALLINT;
    DEFINE o_entrada        	SMALLINT;
    DEFINE o_observaciones  	CHAR(80);

    --Definición de Variables para actualización de Situación Especial
    DEFINE cSituacionEsp CHAR(1);
    DEFINE cCodRet CHAR(6);
    DEFINE cNumCte CHAR(20);
    DEFINE cApellPat CHAR(26);
    DEFINE cApellMat CHAR(26);
    DEFINE cNombre1 CHAR(26);
    DEFINE cNombre2 CHAR(26);
    DEFINE cSituacion CHAR(1);
    DEFINE iCausa INTEGER;
    DEFINE cTelefono CHAR(13);
    DEFINE cZona CHAR(7);
    DEFINE dFecha DATE;
    DEFINE cNombreEmpleado CHAR(45);

    --Inicialización de Variables para actualización de Situación Especial
    LET cSituacionEsp = 'N';
    LET cCodRet = '000001';
    LET cNumCte = '';
    LET cApellPat = '';
    LET cApellMat = '';
    LET cNombre1 = '';
    LET cNombre2 = '';
    LET cSituacion = '';
    LET iCausa = 0;
    LET cTelefono = '';
    LET cZona = '';
    LET dFecha = '01/01/1900';
    LET cNombreEmpleado = '';
    
    LET pSecuencia_compara = 0;
    LET pcoincide = 0;

    LET o_tipo_dir = '';
    LET o_calle = '';
    LET o_colonia = '';
    LET o_entre_calles = '';
    LET o_pais = '';
    LET o_estado = '';
    LET o_ciudad = '';
    LET o_municipio = '';
    LET o_cod_postal = '';
    LET o_apart_postal = '';
    LET o_tipo_telef1 = '';
    LET o_telefono1 = '';
    LET o_tipo_telef2 = '';
    LET o_telefono2 = '';
    LET o_tipo_telef3 = '';
    LET o_telefono3 = '';
    LET o_extension = '';
    LET o_estado_inegi = '';
    LET o_municipio_inegi = '';
    LET o_localidad_inegi = '';
    LET o_numerociudad = 0;
    LET o_numeroextcalle = '';
    LET o_numerointcalle = '';
    LET o_departamento = '';
    LET o_numerocalle = 0;
    LET o_numerocolonia = 0;
    LET o_puntocardinal = '';
    LET o_unidadhabitac = '';
    LET o_manzana = 0;
    LET o_otros = 0;
    LET o_andador = 0;
    LET o_etapa = 0;
    LET o_lote = 0;
    LET o_edificio = 0;
    LET o_entrada = 0;
    LET o_observaciones = '';

--    SET DEBUG FILE TO "/resplogifx/archivoscartera/direcciones.out";
--    TRACE ON;

    BEGIN

    ON EXCEPTION SET v_SqlErr, v_IsamErr
        IF v_SqlErr != 0 THEN
            LET v_CodRet=v_SqlErr;
            RETURN v_CodRet;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    LET v_CodRet = "000";

    LET pEntidad = CAST( LPAD (TRIM(pEntidad), 2 ,  "0") AS CHAR(2));

    SELECT numcte 
      INTO v_NumCte 
      FROM si_cliente
     WHERE numcte = pNumCte;
     
    IF v_NumCte IS NULL THEN
        LET v_CodRet = "104";
        RETURN v_CodRet;
    END IF

    IF pFuncion = "C" THEN
        DELETE FROM si_direcciones
         WHERE numcte = pNumCte 
           AND secuencia = pSecuencia;
           
        DELETE FROM si_direcciones_actual
         WHERE numcte = pNumCte 
           AND secuencia = pSecuencia;
           
        LET pFuncion = "A";
    END IF

    IF pFuncion = "A" THEN

        /* #########################
        SELECT nombre 
          INTO v_Nombre
          FROM si_paises
         WHERE pais = pPais;
         
        IF v_Nombre IS NULL THEN
            LET v_CodRet="121";
            RETURN v_CodRet;
        END IF;

        SELECT nombre 
          INTO v_Nombre
          FROM si_estados
         WHERE pais=pPais 
           and estado=pEntidad;

        IF v_Nombre IS NULL THEN
            LET v_CodRet="122";
            RETURN v_CodRet;
        END IF;

        SELECT nombre 
          INTO v_Nombre
          FROM si_ciudades
         WHERE pais=pPais 
           and estado=pEntidad 
           and ciudad=pLocalidad;
           
        IF v_Nombre IS NULL THEN
            LET v_CodRet="123";
            RETURN v_CodRet;
        END IF;
        ######################### */

        SELECT max(secuencia) 
          INTO pSecuencia
          FROM si_direcciones_actual
         WHERE numcte = pNumCte;
         
        IF pSecuencia IS NULL THEN
            LET pSecuencia = 1;
        ELSE
            LET pSecuencia = pSecuencia + 1;
            LET cSituacionEsp = 'S';
        END IF;

        -- // Se agrega validación para si la clave del municipio viene vacio, le asigne  "00000".
        IF pMunicipio = "" OR pMunicipio is null  THEN
            LET pMunicipio = lpad(trim(nvl(pMunicipio,"00000")),5,"0");
        END IF;
        
        /* ############################ 
        SELECT max(secuencia)
          INTO pSecuencia_compara
          FROM si_direcciones_actual
         WHERE numcte = pNumCte
           and tipo_dir = pTipoDir;
        ############################ */

        SELECT tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
               tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, 
               estado_inegi, municipio_inegi, localidad_inegi, numerociudad, 
               numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
               puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones
          into o_tipo_dir, o_calle, o_colonia, o_entre_calles, o_pais, o_estado, o_ciudad, o_municipio, o_cod_postal, o_apart_postal,
               o_tipo_telef1, o_telefono1, o_tipo_telef2, o_telefono2, o_tipo_telef3, o_telefono3, o_extension, 
               o_estado_inegi, o_municipio_inegi, o_localidad_inegi, o_numerociudad, 
               o_numeroextcalle, o_numerointcalle, o_departamento, o_numerocalle, o_numerocolonia, 
               o_puntocardinal, o_unidadhabitac, o_manzana, o_otros, o_andador, o_etapa, o_lote, o_edificio, o_entrada, o_observaciones
          FROM si_direcciones_actual
         where numcte = pNumCte
       --- and secuencia = pSecuencia_compara
           and tipo_dir = pTipoDir;
        
        IF ( o_tipo_dir is not null 
         AND o_calle = pCalle 
         AND o_colonia = pColonia 
         AND o_entre_calles = pEntre_Calles 
         AND o_pais = pPais 
         AND o_estado = pEntidad  
         AND o_ciudad = pLocalidad  
         AND o_municipio = pMunicipio  
         AND o_cod_postal = pCodPostal 
         AND o_tipo_telef1 = pTipoTel1
         AND o_telefono1 = pTelefono1
         AND o_tipo_telef2 = pTipoTel2
         AND o_telefono2 = pTelefono2
         AND o_tipo_telef3 = pTipoTel3
         AND o_telefono3 = pTelefono3
         AND o_extension = pExtension
         AND o_estado_inegi = pEstado_Inegi
         AND o_municipio_inegi = pMunicipio_Inegi
         AND o_localidad_inegi = pLocalidad_Inegi
         AND o_numerociudad = pNoCiudad
         AND o_numeroextcalle = pNoExt
         AND o_numerointcalle = pNoInt
         AND o_departamento = pDepto
         AND o_numerocalle = pNoCalle
         AND o_numerocolonia = pNoColonia
         AND o_puntocardinal = pPuntoCar
         AND o_unidadhabitac = pUniHabi
         AND o_manzana = pManz
         AND o_otros = pPOtros
         AND o_andador  = pAndador
         AND o_etapa = pEtapa
         AND o_lote = pLote
         AND o_edificio = pEdif
         AND o_entrada = pEntrada
         AND o_observaciones = pObserva ) THEN
            LET pcoincide = 1;
        ELSE
            LET pcoincide = 0;
        END IF;

        if ( pcoincide <= 0 ) then
			IF pTipoDir = '1' THEN
				LET pTipoTel3 = '';
				LET pTelefono3 = '';
				LET pExtension = '';
			ELIF pTipoDir = '2' THEN
				LET pTipoTel1 = '';
				LET pTelefono1 = '';
				LET pTipoTel2 = '';
				LET pTelefono2 = '';
			END IF;
            INSERT INTO si_direcciones
            ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
              tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, 
              estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, 
              departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, 
              andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )
            VALUES
            ( pNumCte, pSecuencia, pTipoDir, pCalle, pColonia, pEntre_Calles, pPais, pEntidad, pLocalidad, pMunicipio, pCodPostal, "",
              pTipoTel1, pTelefono1, pTipoTel2, pTelefono2, pTipoTel3, pTelefono3, pExtension,
              pEstado_Inegi, pMunicipio_Inegi, pLocalidad_Inegi, pNoCiudad, pNoExt, pNoInt,
              pDepto, pNoCalle, pNoColonia, pPuntoCar, pUniHabi, pManz, pPOtros,
              pAndador, pEtapa, pLote, pEdif, pEntrada, pObserva, pUser_Insert, pFecha_Insert );
        end if;

         --#################################################################################################################################################
        IF pTipoDir = '1' AND cSituacionEsp = 'S' THEN

          select limit 1 nvl(situacion,''), causa
            into cSituacionEsp, iCausa
            from bdisitesp:se_ctessitespcte
           where numcte = pNumCte;
			
    			IF cSituacionEsp = 'L' THEN
    									 
      				DELETE FROM bdisitesp:se_ctessitespcte 
      				 WHERE numcte = pNumCte 
      				   AND situacion = 'L';
      				   
      				INSERT INTO bdisitesp:se_ctessitespcte_his
      				(empresa, sucursal, numcte, situacion, causa, tipomovto, empleadoefectuo, usralta, fchmodifica)
      				VALUES
      				(pEmpresa, cSucursal, pNumCte, cSituacionEsp, iCausa, 'B', pUser_Insert, pUser_Insert, pFecha_Insert);
    			END IF;
    			
        END IF;
        --################################################################################################################################################# */

        RETURN v_CodRet;
    
    END IF;
    
    END;
    
END PROCEDURE

DOCUMENT
"Alta de direcciones del cliente",
"Autor : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Hector Bojórquez",
"FECHA : 17/Junio/2009",
"MODIFICACION: En la actualización de domicilios se identifica si el cliente",
"              tiene una situación especial L, de ser asi lo desmarca",
"Ver.  : 1.2",
"MODIFICO : Frank Gaxiola Gaxiola",
"FECHA : 28/Octubre/2009",
"MODIFICACION: Se quita funcionalidad de desmarcaje L, solicitado por Alfonso",
"              Velázquez",
"Ver.  : 1.3",
"MODIFICO : Rodolfo Tortolero Varela",
"FECHA : 06/Abril/2010",
"MODIFICACION: Se implementa validación para formatear el campo municipio con",
"                             0 cuando este sea vacio o null, para que no inserte nuevo registro.",
"solicitado por Daniel Zambada",
"Ver.  : 1.4",
"MODIFICO : Rodolfo Gómez Hernández",
"FECHA : Mayo/2010",
"MODIFICACION: Se optimiza sp guardando la dirección del cliente en variables",
"              para la comparación si hay algún cambio en la dirección del cliente",
"Ver.  : 1.5",
"MODIFICO : Marco A. Campos",
"FECHA: 08-Ago-2011",
"MODIFICACION: Reactivar funcionalidad de desmarcaje situación especial L.";

CREATE PROCEDURE "informix".sp_actvalidacioncofetel_pba ( cEmpresa CHAR(3),cNumCte CHAR(9), cFlagTelefonoCasa CHAR(1), cFlagTelefonoCelular CHAR(1),
                                                     cflagTelefonoOficina CHAR(1), cTipoDireccion CHAR(1), cTipo CHAR(1))
    RETURNING
    CHAR(5);
	
    -- Definicion de Variables
    DEFINE cCodRet CHAR(5);
    DEFINE iSql_err INT;
    DEFINE iMaxSecuencia INT;
    DEFINE iMaxSecuencia_actual INT;
	
    -- Inicializa variables
    LET cCodRet = "00000";
    LET iSql_err = 0;
    LET iMaxSecuencia = 0;
    LET iMaxSecuencia_actual = 0;
	
    -----------------------------------------
	--CREACION: Hector Bojorquez
	--FECHA: 2009-02-18
	--FUNCIONALIDAD: Actualiza un registro en la bdinteg:"informix".si_direcciones si el teléfono 
	--                            proporcionado por el cliente en alta de la dirección fue 
	--                            validado por la COFETEL
	----------------------------------------
	--MODIFICACIÓN: Rodolfo Tortolero Varela
	--FECHA: 2011-09-28
	--FUNCIONALIDAD: Se agrega para que tambien actualize en la tabla bdinteg:"informix".si_direcciones_actual.
	----------------------------------------

    --SET DEBUG FILE TO "/tmp/Sp_ActValidacionCofetel.out";
    --TARCE ON;
	SET LOCK MODE TO WAIT 10;
	
    BEGIN
        ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;

        IF ctipo = "1" THEN
			SELECT max(secuencia) INTO iMaxSecuencia  from bdinteg:"informix".si_direcciones  WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion;
			SELECT max(secuencia) INTO iMaxSecuencia_actual  from bdinteg:"informix".si_direcciones_actual  WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion;

			 IF cFlagTelefonoCasa = "1" and cTipoDireccion = "1" THEN
				UPDATE bdinteg:"informix".si_direcciones SET ind_COFETELtel1 = "V" WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
				UPDATE bdinteg:"informix".si_direcciones_actual SET ind_COFETELtel1 = "V" WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia_actual;
			END IF

			IF cFlagTelefonoCelular = "1" and cTipoDireccion = "1" THEN
				UPDATE bdinteg:"informix".si_direcciones SET ind_COFETELtel2 = "V" WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
				UPDATE bdinteg:"informix".si_direcciones_actual SET ind_COFETELtel2 = "V" WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia_actual;
			END IF

			IF cFlagTelefonoOficina = "1" and cTipoDireccion = "2" THEN
				UPDATE bdinteg:"informix".si_direcciones SET ind_COFETELtel3 = "V" WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
				UPDATE bdinteg:"informix".si_direcciones_actual SET ind_COFETELtel3 = "V" WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia_actual;
			END IF
		ELIF ctipo = "0" THEN
			LET iMaxSecuencia = 0;
				SELECT max(secuencia) INTO iMaxSecuencia  from bdinteg:"informix".si_refdirecciones  WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion;
				IF cFlagTelefonoCasa = "1" and cTipoDireccion = "1" THEN
					UPDATE bdinteg:"informix".si_refdirecciones SET ind_COFETELtel1 = "V" WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
				END IF

				IF cFlagTelefonoCelular = "1"and cTipoDireccion = "1" THEN
					UPDATE bdinteg:"informix".si_refdirecciones SET ind_COFETELtel2 = "V" WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
				END IF

				IF cFlagTelefonoOficina = "1" and cTipoDireccion = "1" THEN
					UPDATE bdinteg:"informix".si_refdirecciones SET ind_COFETELtel3 = "V" WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
				END IF
		END IF
		
		RETURN cCodRet;
    END;
END PROCEDURE;