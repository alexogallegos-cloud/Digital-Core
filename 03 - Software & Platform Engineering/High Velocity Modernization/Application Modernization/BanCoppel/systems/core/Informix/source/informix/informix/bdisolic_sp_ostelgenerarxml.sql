CREATE PROCEDURE "informix".sp_ostelgenerarxml(p_empresa CHAR(3), p_secuencia INTEGER)
                RETURNING CHAR(5)    AS cod_ret,
                          CHAR(7500) AS trama;

--------------------------DECLARACION DE VARIABLES
DEFINE vCod_Ret                         VARCHAR (5);
DEFINE iSqlErr                          INTEGER;
DEFINE iContadorSecuencia               INTEGER;

--variables para la tabla bdisolic:ss_osclientessupervisartel
DEFINE v_cte_secuenciaostel             INTEGER;
DEFINE v_cte_numcte                     CHAR(20);
DEFINE v_cte_nombre1                    CHAR(26);
DEFINE v_cte_nombre2                    CHAR(26);
DEFINE v_cte_apell_paterno              CHAR(26);
DEFINE v_cte_apell_materno              CHAR(26);
DEFINE v_cte_lugartrabajo               CHAR(60);
DEFINE v_cte_estadotrabajo              CHAR(5);
DEFINE v_cte_estadotrabajo_nombre       CHAR(30);
DEFINE v_cte_municipiotrabajo           CHAR(5);
DEFINE v_cte_municipiotrabajo_nombre    CHAR(30);
DEFINE v_cte_numerociudadtrabajo        SMALLINT;
DEFINE v_cte_ciudadtrabajo_nombre       CHAR(100);
DEFINE v_cte_coloniatrabajo             INTEGER;
DEFINE v_cte_coloniatrabajo_nombre      CHAR(60);
DEFINE v_cte_calletrabajo               INTEGER;
DEFINE v_cte_calletrabajo_nombre        CHAR(40);
DEFINE v_cte_numeroextcalletrabajo      CHAR(10);
DEFINE v_cte_Nombre1conyuge             CHAR(26);
DEFINE v_cte_Nombre2conyuge             CHAR(26);
DEFINE v_cte_apell_paternoconyuge       CHAR(26);
DEFINE v_cte_apell_maternoconyuge       CHAR(26);
DEFINE v_cte_ciudadantigua              CHAR(1);
DEFINE v_cte_conyugetrabaja             CHAR(1);

--variables para la tabla bdisolic:ss_ostelreferencias
DEFINE v_ref_nombre1                    CHAR(26);
DEFINE v_ref_nombre2                    CHAR(26);
DEFINE v_ref_apell_paterno              CHAR(26);
DEFINE v_ref_apell_materno              CHAR(26);
DEFINE v_ref_parentesco                 CHAR(20);
DEFINE v_ref_secuencia                  INTEGER; --esta variable no ira en la trama pero es necesaria para recuperar el telefono de la ref

--variables para la tabla bdisolic:ss_osteltelefonos
DEFINE v_tel_tipo_telef                 CHAR(1);
DEFINE v_tel_telefono                   CHAR(10);
DEFINE v_tel_extension                  CHAR(5);
DEFINE v_tel_destino                    CHAR(1);
DEFINE v_tel_secuenciatelefono          SMALLINT;

--variables para el domicilio
DEFINE v_calle                          INTEGER;
DEFINE v_calle_nombre                   CHAR(40);
DEFINE v_numeroextcalle                 CHAR(10);
DEFINE v_numerociudad                   INTEGER;
DEFINE v_ciudad_nombre                  CHAR(100);
DEFINE v_municipio                      CHAR(5);
DEFINE v_municipio_nombre               CHAR(30);
DEFINE v_estado                         CHAR(5);
DEFINE v_estado_nombre                  CHAR(30);
DEFINE v_colonia                        INTEGER;
DEFINE v_colonia_nombre                 CHAR(60);
DEFINE v_cod_postal                     CHAR(5);
DEFINE v_unidadhabitac                  CHAR(1);

--variables para la unidad habitacional
DEFINE v_manzana                        SMALLINT;
DEFINE v_manzana_nombre                 CHAR(30);
DEFINE v_otros                          SMALLINT;
DEFINE v_otros_nombre                   CHAR(30);
DEFINE v_andador                        SMALLINT;
DEFINE v_andador_nombre                 CHAR(30);
DEFINE v_etapa                          SMALLINT;
DEFINE v_etapa_nombre                   CHAR(30);
DEFINE v_lote                           SMALLINT;
DEFINE v_lote_nombre                    CHAR(30);
DEFINE v_entrada                        SMALLINT;
DEFINE v_entrada_nombre                 CHAR(30);
DEFINE v_edificio                       SMALLINT;
DEFINE v_edificio_nombre                CHAR(30);

--variables para el producto
DEFINE v_num_producto                   CHAR(4);
DEFINE v_nombre_prod                    CHAR(40);

--variables para el armado de la trama
DEFINE c_encabezado                     CHAR(193);
DEFINE c_cuerpo                         CHAR(7290);
DEFINE c_cola                           CHAR(17);
DEFINE c_salida                         CHAR(7500);

--vaiables que se mandan en la trama y no estan en las tablas de OSTel
DEFINE tCteFechaNac                     DATE;
DEFINE cCteSexoCodigo                   CHAR(1);
DEFINE cCteEstadoCivilCodigo            CHAR(2);
DEFINE tConyugeFechaNac                 DATE;
DEFINE cConyugeSexoCodigo               CHAR(1);
DEFINE cNumCteBanco                     CHAR(20);
DEFINE cReferenciaNumCte                CHAR(20);
DEFINE tReferenciaFechaNac              DATE;
DEFINE cReferenciaSexoCodigo            CHAR(1);
DEFINE cReferenciaEstadoCivilCodigo     CHAR(2);
DEFINE cTipoDomicilio                   CHAR(2);
DEFINE cNumeroDepartamento              CHAR(6);
DEFINE cComplementoDireccion            CHAR(80);
DEFINE cPuestoTrabajo                   CHAR(30);
DEFINE cSucursalCodigo                  CHAR(4);
DEFINE cSucursalDescripcion             CHAR(40);
DEFINE cNumSolicitud                    CHAR(20);
DEFINE sTipoCliente                     SMALLINT;

--VARIABLE PARA MANDAR EL CORREO ELECTRONICO EN LA TRAMA
DEFINE cEmail                           CHAR(100);
-----VARIABLE PARA GUARDAR LA PRIORIDAD
DEFINE sPrioridad                       SMALLINT;
DEFINE cCodret_prioridad                CHAR(6);
--HMBR
DEFINE cNombreConyuge                   CHAR(30);
DEFINE cParentesco						CHAR(1); 


--------------------------INICIALIZACION DE VARIABLES
LET vCod_Ret                            = '000';
LET iSqlErr                             = 0;
LET iContadorSecuencia                  = 1;

--variables para la tabla bdisolic:ss_osclientessupervisartel
LET v_cte_secuenciaostel                = 0;
LET v_cte_numcte                        = '';
LET v_cte_nombre1                       = '';
LET v_cte_nombre2                       = '';
LET v_cte_apell_paterno                 = '';
LET v_cte_apell_materno                 = '';
LET v_cte_lugartrabajo                  = '';
LET v_cte_estadotrabajo                 = '';
LET v_cte_estadotrabajo_nombre          = '';
LET v_cte_municipiotrabajo              = '';
LET v_cte_municipiotrabajo_nombre       = '';
LET v_cte_numerociudadtrabajo           = 0;
LET v_cte_ciudadtrabajo_nombre          = '';
LET v_cte_coloniatrabajo                = 0;
LET v_cte_coloniatrabajo_nombre         = '';
LET v_cte_calletrabajo                  = 0;
LET v_cte_calletrabajo_nombre           = '';
LET v_cte_numeroextcalletrabajo         = '';
LET v_cte_Nombre1conyuge                = '';
LET v_cte_Nombre2conyuge                = '';
LET v_cte_apell_paternoconyuge          = '';
LET v_cte_apell_maternoconyuge          = '';
LET v_cte_ciudadantigua                 = '';
LET v_cte_conyugetrabaja                = '';

--variables para la tabla bdisolic:ss_ostelreferencias
LET v_ref_nombre1                       = '';
LET v_ref_nombre2                       = '';
LET v_ref_apell_paterno                 = '';
LET v_ref_apell_materno                 = '';
LET v_ref_parentesco                    = '';
LET v_ref_secuencia                     = 0;

--variables para la tabla bdisolic:ss_osteltelefonos
LET v_tel_tipo_telef                    = '';
LET v_tel_telefono                      = '';
LET v_tel_extension                     = '';
LET v_tel_destino                       = '';
LET v_tel_secuenciatelefono             = 0;

--variables para el domicilio
LET v_calle                             = 0;
LET v_calle_nombre                      = '';
LET v_numeroextcalle                    = '';
LET v_numerociudad                      = 0;
LET v_ciudad_nombre                     = '';
LET v_municipio                         = '';
LET v_municipio_nombre                  = '';
LET v_estado                            = '';
LET v_estado_nombre                     = '';
LET v_colonia                           = 0;
LET v_colonia_nombre                    = '';
LET v_cod_postal                        = '';
LET v_unidadhabitac                     = '';

--variables para la unidad habitacional
LET v_manzana                           = 0;
LET v_manzana_nombre                    = '';
LET v_otros                             = 0;
LET v_otros_nombre                      = '';
LET v_andador                           = 0;
LET v_andador_nombre                    = '';
LET v_etapa                             = 0;
LET v_etapa_nombre                      = '';
LET v_lote                              = 0;
LET v_lote_nombre                       = '';
LET v_entrada                           = 0;
LET v_entrada_nombre                    = '';
LET v_edificio                          = 0;
LET v_edificio_nombre                   = '';

--variables para el producto
LET v_num_producto                      = '';
LET v_nombre_prod                       = '';

--vaiables que se mandan en la trama y no estan en las tablas de OSTel
LET tCteFechaNac                        = '01-01-1900';
LET cCteSexoCodigo                      = '';
LET cCteEstadoCivilCodigo               = '';
LET tConyugeFechaNac                    = '01-01-1900';
LET cConyugeSexoCodigo                  = '';
LET cNumCteBanco                        = '';
LET cReferenciaNumCte                   = '';
LET tReferenciaFechaNac                 = '01-01-1900';
LET cReferenciaSexoCodigo               = '';
LET cReferenciaEstadoCivilCodigo        = '';
LET cTipoDomicilio                      = '';
LET cNumeroDepartamento                 = '';
LET cComplementoDireccion               = '';
LET cPuestoTrabajo                      = '';
LET cSucursalCodigo                     = '';
LET cSucursalDescripcion                = '';
LET cNumSolicitud                       = '';
--VARIABLE PARA RETORNAR EL CORREO ELECTRONICO EN LA TRAMA
LET cEmail                              = '';
--VARIABLE PARA RETORNAR LA PRIORIDAD
LET sPrioridad                          = 0;
LET cCodret_prioridad                   = '';
LET sTipoCliente                        = '';
--HMBR
LET cNombreConyuge                      = '';
LET cParentesco							= ''; 


-- armar el encabezado del xml
LET c_encabezado = "<?xml version='1.0' encoding='utf-8' ?>";
LET c_encabezado = SUBSTR(c_encabezado, 1, LENGTH(c_encabezado))
        || "<COsTelefonica xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns='http://ostelefonica.coppel.com'>";
--armar la cola del xml
LET c_cola = "</COsTelefonica>";
LET c_cuerpo = "";
LET c_salida="";

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET vCod_Ret = iSqlErr;
                RETURN vCod_Ret, c_salida;
            END IF;
        END EXCEPTION;
		
		--SET debug FILE TO '/resplogifx/archivoscartera/altaunica/envios/sp_ostelgenerarxml.out';
		--TRACE ON;
		
	   SET ISOLATION TO DIRTY READ;
	   SET LOCK MODE TO WAIT 3;

        IF TRIM(p_empresa) = "" OR p_empresa IS NULL OR p_secuencia IS NULL OR p_secuencia < 1 THEN
            LET vCod_Ret = "001";
            RETURN vCod_Ret, c_salida;
        END IF;

        --validar si existe registro para el cliente
        IF EXISTS(SELECT numcte FROM "informix".ss_osclientesupervisartel WHERE secuenciaostel = p_secuencia) THEN
            --recuperar los datos del cliente
            SELECT 
            NVL(secuenciaostel,0), NVL(numcte,""), NVL(nombre1,""), NVL(nombre2,""),
            NVL(apell_paterno,""), NVL(apell_materno,""), NVL(calle,0), NVL(calle_nombre,""),
            NVL(numeroextcalle,"0"), NVL(numerociudad,0), NVL(ciudad_nombre,""), NVL(municipio,"0"),
            NVL(municipio_nombre,""), NVL(estado,"0"), NVL(estado_nombre,""), NVL(colonia,0),
            NVL(colonia_nombre,""), NVL(cod_postal,"0"), NVL(unidadhabitac,""),
            NVL(lugartrabajo,""), NVL(estadotrabajo,"0"), NVL(estadotrabajo_nombre,""), NVL(municipiotrabajo,"0"),
            NVL(municipiotrabajo_nombre,""), NVL(numerociudadtrabajo,0), NVL(ciudadtrabajo_nombre,""),
            NVL(coloniatrabajo,0), NVL(coloniatrabajo_nombre,""), NVL(calletrabajo,0),
            NVL(calletrabajo_nombre,""), NVL(numeroextcalletrabajo,"0"), NVL(Nombre1conyuge,""),
            NVL(Nombre2conyuge,""), NVL(apell_paternoconyuge,""), NVL(apell_maternoconyuge,""), NVL(ciudadantigua,"0"),
            NVL(conyugetrabaja,"0")
            INTO
            v_cte_secuenciaostel, v_cte_numcte, v_cte_nombre1, v_cte_nombre2,
            v_cte_apell_paterno, v_cte_apell_materno, v_calle, v_calle_nombre,
            v_numeroextcalle, v_numerociudad, v_ciudad_nombre, v_municipio,
            v_municipio_nombre, v_estado, v_estado_nombre, v_colonia,
            v_colonia_nombre, v_cod_postal, v_unidadhabitac,
            v_cte_lugartrabajo, v_cte_estadotrabajo, v_cte_estadotrabajo_nombre, v_cte_municipiotrabajo,
            v_cte_municipiotrabajo_nombre, v_cte_numerociudadtrabajo, v_cte_ciudadtrabajo_nombre,
            v_cte_coloniatrabajo, v_cte_coloniatrabajo_nombre, v_cte_calletrabajo,
            v_cte_calletrabajo_nombre, v_cte_numeroextcalletrabajo, v_cte_Nombre1conyuge,
            v_cte_Nombre2conyuge, v_cte_apell_paternoconyuge, v_cte_apell_maternoconyuge, v_cte_ciudadantigua,
            v_cte_conyugetrabaja
            FROM "informix".ss_osclientesupervisartel
            WHERE secuenciaostel = p_secuencia;

			IF v_cte_secuenciaostel = '' OR v_cte_secuenciaostel IS NULL THEN
				LET v_cte_secuenciaostel = 0;
			END IF
			IF v_calle = '' OR v_calle IS NULL THEN
				LET v_calle = 0;
			END IF
			IF v_numeroextcalle = '' OR v_numeroextcalle IS NULL THEN
				LET v_numeroextcalle = '0';
			END IF
			IF v_numerociudad = '' OR v_numerociudad IS NULL THEN
				LET v_numerociudad = 0;
			END IF
			IF v_municipio = '' OR v_municipio IS NULL THEN
				LET v_municipio = '0';
			END IF
			IF v_estado = '' OR v_estado IS NULL THEN
				LET v_estado = '0';
			END IF
			IF v_colonia = '' OR v_colonia IS NULL THEN
				LET v_colonia = 0;
			END IF
			IF v_cod_postal = '' OR v_cod_postal IS NULL THEN
				LET v_cod_postal = '0';
			END IF
			IF v_cte_estadotrabajo = '' OR v_cte_estadotrabajo IS NULL THEN
				LET v_cte_estadotrabajo = '0';
			END IF
			IF v_cte_municipiotrabajo = '' OR v_cte_municipiotrabajo IS NULL THEN
				LET v_cte_municipiotrabajo = '0';
			END IF
			IF v_cte_numeroextcalletrabajo = '' OR v_cte_numeroextcalletrabajo IS NULL THEN
				LET v_cte_numeroextcalletrabajo = '0';
			END IF
			IF v_cte_ciudadantigua = '' OR v_cte_ciudadantigua IS NULL THEN
				LET v_cte_ciudadantigua = '0';
			END IF
			IF v_cte_conyugetrabaja ='' OR v_cte_conyugetrabaja IS NULL THEN
				LET v_cte_conyugetrabaja='0';
			END IF;

            SELECT NVL(fecha_nac,'01-01-1900'), NVL(sexo,''), NVL(estado_civil,''), NVL(habita_en,'')
            INTO tCteFechaNac, cCteSexoCodigo, cCteEstadoCivilCodigo, cTipoDomicilio
            FROM bdinteg:"informix".si_ctepf
            WHERE numcte = v_cte_numcte;

            SELECT NVL(departamento,'0'), NVL(observaciones,'')
            INTO cNumeroDepartamento, cComplementoDireccion
            FROM bdinteg:"informix".si_direcciones
            WHERE numcte = v_cte_numcte
            AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_direcciones WHERE numcte =  v_cte_numcte AND tipo_dir = 1);
		
			--Se Metio .....HMBR
			IF cNumeroDepartamento = '' OR cNumeroDepartamento IS NULL THEN
				LET cNumeroDepartamento = '0';
			END IF
			
            SELECT NVL(b.descrip,'')
			INTO cPuestoTrabajo
			FROM bdinteg:"informix".si_ingresos AS a, bdinteg:"informix".si_actsubact AS b
			WHERE a.claveopcionpuesto = b.id_act
			AND a.clavesubopcionpuesto = b.id_subact
			AND a.empresa = p_empresa
			AND numcte = v_cte_numcte
			AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = v_cte_numcte);

            IF cPuestoTrabajo is null then
                SELECT NVL(b.descripcion,'')
                INTO cPuestoTrabajo
                FROM bdinteg:"informix".si_ingresos AS a, bdinteg:"informix".si_puestos AS b
                WHERE a.puesto = b.puesto
                AND a.empresa = b.empresa
                AND a.empresa = p_empresa
                AND numcte = v_cte_numcte
                AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = v_cte_numcte);
            end if;

            IF cPuestoTrabajo is null then
                LET cPuestoTrabajo = '';
            END IF;

            LET cPuestoTrabajo = 'EMPRESA';
            --verificar si es cliente coppel nuevo, coppel < 13 meses ó coppel >= 13 meses
            SELECT limit 1 num_solicitud
            INTO cNumSolicitud
            FROM "informix".ss_ostelrefsolicitud
            WHERE secuenciaostel = p_secuencia
            GROUP BY num_solicitud;
			
			SELECT (CASE WHEN meses_historia >= 13 AND situacion_pago >= 85 THEN 0
			WHEN meses_historia BETWEEN 6 AND 12 AND situacion_pago >= 85 THEN 1
			WHEN meses_historia BETWEEN 0 AND 5 AND situacion_pago >= 85 THEN 2
			WHEN meses_historia >= 13 AND situacion_pago < 85 THEN 3
			WHEN meses_historia = 0 THEN 4 END) 	
			INTO sTipoCliente
			FROM "informix".ss_resum_scor_fin 
			WHERE empresa = p_empresa
			AND fuente = 'T' -- T=Coppel
			AND num_solicitud = cNumSolicitud;
			
			--Si el numero de solicitud no existe  cae en el ultimo grupo			
			IF sTipoCliente IS NULL THEN
				LET sTipoCliente = 4;
			END IF;

			SELECT TRIM(correo_elec)
			INTO cEmail
			FROM bdinteg:"informix".si_correos
			WHERE empresa = TRIM(p_empresa)
			AND numcte = TRIM(v_cte_numcte)
			AND tipo_correo= '1'
			AND status_correo = 'A';
			
			IF cEmail IS NULL THEN
				LET cEmail= '';
			END IF;
			

            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                    || "<Secuencia>" || v_cte_secuenciaostel || "</Secuencia>";
			
			CALL "informix".fnsolonumerosychar(SUBSTR(v_cte_numcte, 1, LENGTH(v_cte_numcte))) RETURNING  v_cte_numcte;
			
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                    || "<NumeroCliente>" || v_cte_numcte || "</NumeroCliente>";
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                    || "<Solicitud>" ||"0"|| "</Solicitud>";
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                    || "<Solicitante>";
					
			CALL "informix".fnsolonumerosychar (SUBSTR(v_cte_nombre1, 1, LENGTH(v_cte_nombre1))) RETURNING v_cte_nombre1;
			
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                        || "<NombreUno>" || v_cte_nombre1 || "</NombreUno>";
			CALL "informix".fnsolonumerosychar (SUBSTR(v_cte_nombre2, 1, LENGTH(v_cte_nombre2))) RETURNING v_cte_nombre2;
			
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                        || "<NombreDos>" || v_cte_nombre2 || "</NombreDos>";

			CALL "informix".fnsolonumerosychar (SUBSTR(v_cte_apell_paterno, 1, LENGTH(v_cte_apell_paterno))) RETURNING v_cte_apell_paterno;			
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                        || "<ApellidoPaterno>" || v_cte_apell_paterno || "</ApellidoPaterno>";

			CALL "informix".fnsolonumerosychar (SUBSTR(v_cte_apell_materno, 1, LENGTH(v_cte_apell_materno))) RETURNING v_cte_apell_materno;
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                        || "<ApellidoMaterno>" || v_cte_apell_materno || "</ApellidoMaterno>"  ;
						
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                        || "<FechaNacimiento>" || tCteFechaNac || "</FechaNacimiento>"  ;
						
			CALL "informix".fnsolonumerosychar (SUBSTR(cCteSexoCodigo, 1, LENGTH(cCteSexoCodigo))) RETURNING cCteSexoCodigo;			
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                        || "<Sexo>" || cCteSexoCodigo || "</Sexo>"  ;
						
			CALL "informix".fnsolonumerosychar (SUBSTR(cCteEstadoCivilCodigo, 1, LENGTH(cCteEstadoCivilCodigo))) RETURNING cCteEstadoCivilCodigo;			
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                        || "<EstadoCivil>" || cCteEstadoCivilCodigo || "</EstadoCivil>"  ;

			CALL "informix".fnsolonumerosychar (SUBSTR(v_cte_ciudadantigua, 1, LENGTH(v_cte_ciudadantigua))) RETURNING v_cte_ciudadantigua;			
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                        || "<CiudadVieja>" || v_cte_ciudadantigua || "</CiudadVieja>"  ;
						
			CALL "informix".fnsolonumerosychar (SUBSTR(v_cte_conyugetrabaja, 1, LENGTH(v_cte_conyugetrabaja))) RETURNING v_cte_conyugetrabaja;			
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                        || "<ConyugeTrabaja>" || v_cte_conyugetrabaja || "</ConyugeTrabaja>"  ;
			  LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                        || "<TipoCliente>" || sTipoCliente || "</TipoCliente>"  ;
						
		
            
			----------------Etiqueta para correo electronico 
			LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                        || "<Email>" || SUBSTR(cEmail, 1, LENGTH(cEmail))  || "</Email>"  ;
						
			--------------------Etiqueta para la prioridad
			EXECUTE PROCEDURE "informix".sp_ostelprioridadcte(v_cte_secuenciaostel)
			INTO cCodret_prioridad, sPrioridad;
			LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                        || "<Prioridad>" || sPrioridad || "</Prioridad>"  ;
			
			LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                        || "<Domicilio>";
						
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<NumeroCalle>" || v_calle || "</NumeroCalle>";
							
			CALL "informix".fnsolonumerosychar (SUBSTR(v_calle_nombre, 1, LENGTH(v_calle_nombre))) RETURNING v_calle_nombre;				
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<Calle>" || v_calle_nombre || "</Calle>";
							
            CALL "informix".fnsolonumerosychar (SUBSTR(v_numeroextcalle, 1, LENGTH(v_numeroextcalle))) RETURNING v_numeroextcalle;		
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<NumeroCasa>" || v_numeroextcalle || "</NumeroCasa>";
							
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<NumeroCiudad>" || v_numerociudad || "</NumeroCiudad>";
							
            CALL "informix".fnsolonumerosychar (SUBSTR(v_ciudad_nombre, 1, LENGTH(v_ciudad_nombre))) RETURNING v_ciudad_nombre;							
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<Ciudad>" || v_ciudad_nombre || "</Ciudad>";
            
			CALL "informix".fnsolonumerosychar (SUBSTR(v_municipio, 1, LENGTH(v_municipio))) RETURNING v_municipio;
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<NumeroMunicipio>" || v_municipio || "</NumeroMunicipio>";

            CALL "informix".fnsolonumerosychar (SUBSTR(v_municipio_nombre, 1, LENGTH(v_municipio_nombre))) RETURNING v_municipio_nombre;		
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<Municipio>" || v_municipio_nombre || "</Municipio>";
			
			CALL "informix".fnsolonumerosychar (SUBSTR(v_estado, 1, LENGTH(v_estado))) RETURNING v_estado;		
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<NumeroEstado>" || v_estado || "</NumeroEstado>";
			
			CALL "informix".fnsolonumerosychar (SUBSTR(v_estado_nombre, 1, LENGTH(v_estado_nombre))) RETURNING v_estado_nombre;
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<Estado>" || v_estado_nombre || "</Estado>";
							
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<NumeroColonia>" || v_colonia || "</NumeroColonia>";

			CALL "informix".fnsolonumerosychar (SUBSTR(v_colonia_nombre, 1, LENGTH(v_colonia_nombre))) RETURNING v_colonia_nombre;						
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<Colonia>" || v_colonia_nombre || "</Colonia>";

            CALL "informix".fnsolonumerosychar (SUBSTR(v_cod_postal, 1, LENGTH(v_cod_postal))) RETURNING v_cod_postal;							
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<CodigoPostal>" || v_cod_postal || "</CodigoPostal>";
							
			CALL "informix".fnsolonumerosychar (SUBSTR(cTipoDomicilio, 1, LENGTH(cTipoDomicilio))) RETURNING cTipoDomicilio;				
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<TipoDomicilio>" || cTipoDomicilio || "</TipoDomicilio>";
							
			CALL "informix".fnsolonumerosychar (SUBSTR(cNumeroDepartamento, 1, LENGTH(cNumeroDepartamento))) RETURNING cNumeroDepartamento;
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<NumeroDepartamento>" || cNumeroDepartamento || "</NumeroDepartamento>";
			
            CALL "informix".fnsolonumerosychar (SUBSTR(cComplementoDireccion, 1, LENGTH(cComplementoDireccion))) RETURNING cComplementoDireccion;			
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<Complemento>" || cComplementoDireccion || "</Complemento>";

            IF (v_unidadhabitac = "S") THEN

                SELECT
                NVL(manzana,0), NVL(manzana_nombre,""), NVL(otros,0), NVL(otros_nombre,""), NVL(andador,0),
                NVL(andador_nombre,""), NVL(etapa,0), NVL(etapa_nombre,""), NVL(lote,0), NVL(lote_nombre,""),
                NVL(edificio,0), NVL(edificio_nombre,""), NVL(entrada,0), NVL(entrada_nombre,"")
                INTO
                v_manzana, v_manzana_nombre, v_otros, v_otros_nombre, v_andador,
                v_andador_nombre, v_etapa, v_etapa_nombre, v_lote, v_lote_nombre,
                v_entrada, v_entrada_nombre, v_edificio, v_edificio_nombre
                FROM "informix".ss_osclientesupervisartel
                WHERE secuenciaostel = p_secuencia;

                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<UnidadHabitacional>";
                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<Manzana>" || v_manzana || "</Manzana>";
									
									
				CALL "informix".fnsolonumerosychar (SUBSTR(v_manzana_nombre, 1, LENGTH(v_manzana_nombre))) RETURNING v_manzana_nombre;					
                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<DescripcionManzana>" || v_manzana_nombre || "</DescripcionManzana>";
									
									
                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<Otros>" || v_otros || "</Otros>";

				CALL "informix".fnsolonumerosychar (SUBSTR(v_otros_nombre, 1, LENGTH(v_otros_nombre))) RETURNING v_otros_nombre;					
                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<DescripcionOtros>" || v_otros_nombre || "</DescripcionOtros>";
									
                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<Andador>" || v_andador || "</Andador>";
									
				CALL "informix".fnsolonumerosychar (SUBSTR(v_andador_nombre, 1, LENGTH(v_andador_nombre))) RETURNING v_andador_nombre;
                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<DescripcionAndador>" || v_andador_nombre || "</DescripcionAndador>";
									
                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<Etapa>" || v_etapa || "</Etapa>";
									
				CALL "informix".fnsolonumerosychar (SUBSTR(v_etapa_nombre, 1, LENGTH(v_etapa_nombre))) RETURNING v_etapa_nombre;
                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<DescripcionEtapa>" || v_etapa_nombre || "</DescripcionEtapa>";
									
                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<Lote>" || v_lote || "</Lote>";
									
				CALL "informix".fnsolonumerosychar (SUBSTR(v_lote_nombre, 1, LENGTH(v_lote_nombre))) RETURNING v_lote_nombre;					
                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<DescripcionLote>" || v_lote_nombre || "</DescripcionLote>";
									
                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<Edificio>" || v_edificio || "</Edificio>";
									
				CALL "informix".fnsolonumerosychar (SUBSTR(v_edificio_nombre, 1, LENGTH(v_edificio_nombre))) RETURNING v_edificio_nombre;				
                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<DescripcionEdificio>" || v_edificio_nombre || "</DescripcionEdificio>";
									
                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<Entrada>" || v_entrada || "</Entrada>";
									
                CALL "informix".fnsolonumerosychar (SUBSTR(v_entrada_nombre, 1, LENGTH(v_entrada_nombre))) RETURNING v_entrada_nombre;									
                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<DescripcionEntrada>" || v_entrada_nombre || "</DescripcionEntrada>";
									
                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "</UnidadHabitacional>";
            END IF;
            --cerrar la etiqueta del domicilio
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo)) || "</Domicilio>";

            --se verifica si existe algun registro de la referencia del cliente
			IF EXISTS(SELECT {+ INDEX ("informix".ss_ostelreferencias idx_secostelref)} secuencia FROM "informix".ss_ostelreferencias WHERE secuenciaostel = p_secuencia) THEN
                FOREACH
                    SELECT {+ INDEX ("informix".ss_ostelreferencias idx_secostelref)}
                    NVL(nombre1,""), NVL(nombre2,""), NVL(apell_paterno,""),
                    NVL(apell_materno,""), NVL(parentesco_nombre,"0"), NVL(secuencia,0),
                    NVL(numerocalle,0), NVL(calle_nombre,""),
                    NVL(numeroextcalle,"0"), NVL(numerociudad,0), NVL(ciudad_nombre,""), NVL(municipio,"0"),
                    NVL(municipio_nombre,""), NVL(estado,"0"), NVL(estado_nombre,""), NVL(numerocolonia,0),
                    NVL(colonia_nombre,""), NVL(unidadhabitac,""), NVL(parentesco,"")
                    INTO
                    v_ref_nombre1, v_ref_nombre2, v_ref_apell_paterno, v_ref_apell_materno,
                    v_ref_parentesco, v_ref_secuencia,
                    v_calle, v_calle_nombre,
                    v_numeroextcalle, v_numerociudad, v_ciudad_nombre, v_municipio,
                    v_municipio_nombre, v_estado, v_estado_nombre, v_colonia,
                    v_colonia_nombre, v_unidadhabitac, cParentesco
                    FROM "informix".ss_ostelreferencias
                    WHERE secuenciaostel = p_secuencia
                    ORDER BY secuencia ASC
                    let v_ref_secuencia = v_ref_secuencia;
                    let v_cte_Nombre1conyuge = v_cte_Nombre1conyuge;
					
					--SE METIO ...HMBR
					IF v_ref_nombre1 IS NULL THEN
						LET v_ref_nombre1 = '';
					END IF

					IF v_ref_nombre2 IS NULL THEN
						LET v_ref_nombre2 = '';
					END IF
					
					IF v_ref_apell_paterno IS NULL THEN
						LET v_ref_apell_paterno = '0';
					END IF

					IF v_ref_apell_materno IS NULL THEN
						LET v_ref_apell_materno = '0';
					END IF

					IF v_ref_parentesco = '' OR v_ref_parentesco IS NULL THEN
						LET v_ref_parentesco = '0';
					END IF
					
					IF v_ref_secuencia = '' OR v_ref_secuencia IS NULL THEN
						LET v_ref_secuencia = 0;
					END IF					

					IF v_calle = '' OR v_calle IS NULL THEN
						LET v_calle = 0;
					END IF					

					IF v_calle_nombre = '' OR v_calle_nombre IS NULL THEN
						LET v_calle_nombre = '0';
					END IF

					IF v_numeroextcalle = '' OR v_numeroextcalle IS NULL THEN
						LET v_numeroextcalle = '0';
					END IF					
					
					IF v_numerociudad = '' OR v_numerociudad IS NULL THEN
						LET v_numerociudad = 0;
					END IF					
					
					IF v_ciudad_nombre IS NULL THEN
						LET v_ciudad_nombre = '';
					END IF					
					
					IF v_municipio = '' OR v_municipio IS NULL THEN
						LET v_municipio = '0';
					END IF
					
					IF v_municipio_nombre IS NULL THEN
						LET v_municipio_nombre = '';
					END IF					
					
					IF v_estado = '' OR v_estado IS NULL THEN
						LET v_estado = '0';
					END IF
					
					IF v_estado_nombre IS NULL THEN
						LET v_estado_nombre = '';
					END IF	

					IF v_colonia = '' OR v_colonia IS NULL THEN
						LET v_colonia = 0;
					END IF

					IF v_colonia_nombre IS NULL THEN
						LET v_colonia_nombre = '';
					END IF
					
					IF v_unidadhabitac IS NULL THEN
						LET v_unidadhabitac = '';
					END IF	

					SELECT {+ INDEX (bdinteg:"informix".si_refclientes idx_si_refclientes2)}
                        NVL(numcte,''), NVL(fecha_nac,'01-01-1900'), NVL(sexo,''), NVL(estado_civil,''), NVL(numcte_banco,'')
                    INTO cReferenciaNumCte, tReferenciaFechaNac, cReferenciaSexoCodigo, cReferenciaEstadoCivilCodigo, cNumCteBanco
                    FROM bdinteg:"informix".si_refclientes
                    WHERE secuencia = v_ref_secuencia;					
					
					
					IF TRIM(cNumCteBanco) <> '' THEN
                        LET tConyugeFechaNac = tReferenciaFechaNac;
                        LET cConyugeSexoCodigo = cReferenciaSexoCodigo;
                    END IF;

					IF LENGTH(v_cte_Nombre1conyuge) > 0 AND TRIM(cParentesco) = 'E' THEN
                        LET iContadorSecuencia = iContadorSecuencia + 1;
                        CONTINUE Foreach;
                    END IF;

                    SELECT NVL(departamento,''), NVL(observaciones,'')
                    INTO cNumeroDepartamento, cComplementoDireccion
                    FROM bdinteg:"informix".si_refdirecciones
                    WHERE numcte = cReferenciaNumCte
                    AND secuencia = v_ref_secuencia;
					
					--Se Metio .....HMBR
					IF cNumeroDepartamento = '' OR cNumeroDepartamento IS NULL THEN
						LET cNumeroDepartamento = '0';
					END IF

                    LET cTipoDomicilio = '';

                    --verificar si la referencia es el conyuge para guardar su fecha de nacimiento y sexo
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<Referencias>";
							
					CALL "informix".fnsolonumerosychar (SUBSTR(v_ref_nombre1, 1, LENGTH(v_ref_nombre1))) RETURNING v_ref_nombre1;		
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<NombreUno>" || v_ref_nombre1 || "</NombreUno>";
					
					CALL "informix".fnsolonumerosychar (SUBSTR(v_ref_nombre2, 1, LENGTH(v_ref_nombre2))) RETURNING v_ref_nombre2;
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<NombreDos>" || v_ref_nombre2 || "</NombreDos>";
								
					CALL "informix".fnsolonumerosychar (SUBSTR(v_ref_apell_paterno, 1, LENGTH(v_ref_apell_paterno))) RETURNING v_ref_apell_paterno;			
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<ApellidoPaterno>" || v_ref_apell_paterno || "</ApellidoPaterno>";
								
					CALL "informix".fnsolonumerosychar (SUBSTR(v_ref_apell_materno, 1, LENGTH(v_ref_apell_materno))) RETURNING v_ref_apell_materno;			
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<ApellidoMaterno>" || v_ref_apell_materno || "</ApellidoMaterno>";
								
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<FechaNacimiento>" || tReferenciaFechaNac || "</FechaNacimiento>"  ;
								
					CALL "informix".fnsolonumerosychar (SUBSTR(cReferenciaSexoCodigo, 1, LENGTH(cReferenciaSexoCodigo))) RETURNING cReferenciaSexoCodigo;			
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<Sexo>" || cReferenciaSexoCodigo || "</Sexo>"  ;
								
					CALL "informix".fnsolonumerosychar (SUBSTR(cReferenciaEstadoCivilCodigo, 1, LENGTH(cReferenciaEstadoCivilCodigo))) RETURNING cReferenciaEstadoCivilCodigo;			
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<EstadoCivil>" || cReferenciaEstadoCivilCodigo || "</EstadoCivil>"  ;
								
					CALL "informix".fnsolonumerosychar (SUBSTR(v_ref_parentesco, 1, LENGTH(v_ref_parentesco))) RETURNING v_ref_parentesco;			
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<Parentesco>" || v_ref_parentesco || "</Parentesco>";
								
								
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<SecuenciaReferencia>" || iContadorSecuencia || "</SecuenciaReferencia>";
								
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<Domicilio>";
								
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<NumeroCalle>" || v_calle || "</NumeroCalle>";
									
					CALL "informix".fnsolonumerosychar (SUBSTR(v_calle_nombre, 1, LENGTH(v_calle_nombre))) RETURNING v_calle_nombre;				
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<Calle>" || v_calle_nombre || "</Calle>";
									
					CALL "informix".fnsolonumerosychar (SUBSTR(v_numeroextcalle, 1, LENGTH(v_numeroextcalle))) RETURNING v_numeroextcalle;				
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<NumeroCasa>" || v_numeroextcalle || "</NumeroCasa>";
									
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<NumeroCiudad>" || v_numerociudad || "</NumeroCiudad>";
					
					CALL "informix".fnsolonumerosychar (SUBSTR(v_ciudad_nombre, 1, LENGTH(v_ciudad_nombre))) RETURNING v_ciudad_nombre;
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<Ciudad>" || v_ciudad_nombre || "</Ciudad>";
									
					CALL "informix".fnsolonumerosychar (SUBSTR(v_municipio, 1, LENGTH(v_municipio))) RETURNING v_municipio;				
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<NumeroMunicipio>" || v_municipio || "</NumeroMunicipio>";
									
					CALL "informix".fnsolonumerosychar (SUBSTR(v_municipio_nombre, 1, LENGTH(v_municipio_nombre))) RETURNING v_municipio_nombre;				
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<Municipio>" || v_municipio_nombre || "</Municipio>";
									
					CALL "informix".fnsolonumerosychar (SUBSTR(v_estado, 1, LENGTH(v_estado))) RETURNING v_estado;				
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<NumeroEstado>" || v_estado || "</NumeroEstado>";
									
					CALL "informix".fnsolonumerosychar (SUBSTR(v_estado_nombre, 1, LENGTH(v_estado_nombre))) RETURNING v_estado_nombre;				
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<Estado>" || v_estado_nombre || "</Estado>";
									
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<NumeroColonia>" || v_colonia || "</NumeroColonia>";

					CALL "informix".fnsolonumerosychar (SUBSTR(v_colonia_nombre, 1, LENGTH(v_colonia_nombre))) RETURNING v_colonia_nombre;				
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<Colonia>" || v_colonia_nombre || "</Colonia>";
									
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<CodigoPostal>" || "0" || "</CodigoPostal>";
					
					CALL "informix".fnsolonumerosychar (SUBSTR(cTipoDomicilio, 1, LENGTH(cTipoDomicilio))) RETURNING cTipoDomicilio;
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<TipoDomicilio>" || cTipoDomicilio || "</TipoDomicilio>";
									
					CALL "informix".fnsolonumerosychar (SUBSTR(cNumeroDepartamento, 1, LENGTH(cNumeroDepartamento))) RETURNING cNumeroDepartamento;				
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<NumeroDepartamento>" || cNumeroDepartamento || "</NumeroDepartamento>";
									
					CALL "informix".fnsolonumerosychar (SUBSTR(cComplementoDireccion, 1, LENGTH(cComplementoDireccion))) RETURNING cComplementoDireccion;			
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<Complemento>" || cComplementoDireccion || "</Complemento>";

                    LET iContadorSecuencia = iContadorSecuencia + 1;

                    --se verifica si la referencia vive en unidad habitacional para agregar los datos a la trama
                    IF (v_unidadhabitac = "S") THEN

                        --se agregan los datos de la unidad habitacional a la trama
                        SELECT
                        NVL(manzana,0), NVL(manzana_nombre,""), NVL(otros,0), NVL(otros_nombre,""), NVL(andador,0),
                        NVL(andador_nombre,""), NVL(etapa,0), NVL(etapa_nombre,""), NVL(lote,0), NVL(lote_nombre,""),
                        NVL(edificio,0), NVL(edificio_nombre,""), NVL(entrada,0), NVL(entrada_nombre,"")
                        INTO
                        v_manzana, v_manzana_nombre, v_otros, v_otros_nombre, v_andador,
                        v_andador_nombre, v_etapa, v_etapa_nombre, v_lote, v_lote_nombre,
                        v_entrada, v_entrada_nombre, v_edificio, v_edificio_nombre
                        FROM "informix".ss_ostelreferencias
                        WHERE secuenciaostel = p_secuencia
                        AND secuencia = v_ref_secuencia;

                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                        || "<UnidadHabitacional>";
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                            || "<Manzana>" || v_manzana || "</Manzana>";
						
						CALL "informix".fnsolonumerosychar (SUBSTR(v_manzana_nombre, 1, LENGTH(v_manzana_nombre))) RETURNING v_manzana_nombre;
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                            || "<DescripcionManzana>" || v_manzana_nombre || "</DescripcionManzana>";
											
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                            || "<Otros>" || v_otros || "</Otros>";
											
						CALL "informix".fnsolonumerosychar (SUBSTR(v_otros_nombre, 1, LENGTH(v_otros_nombre))) RETURNING v_otros_nombre;
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                            || "<DescripcionOtros>" || v_otros_nombre || "</DescripcionOtros>";
											
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                            || "<Andador>" || v_andador || "</Andador>";
											
						CALL "informix".fnsolonumerosychar (SUBSTR(v_andador_nombre, 1, LENGTH(v_andador_nombre))) RETURNING v_andador_nombre;					
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                            || "<DescripcionAndador>" || v_andador_nombre || "</DescripcionAndador>";
											
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                            || "<Etapa>" || v_etapa || "</Etapa>";
											
						CALL "informix".fnsolonumerosychar (SUBSTR(v_etapa_nombre, 1, LENGTH(v_etapa_nombre))) RETURNING v_etapa_nombre;
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                            || "<DescripcionEtapa>" || v_etapa_nombre || "</DescripcionEtapa>";
											
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                            || "<Lote>" || v_lote || "</Lote>";
											
						CALL "informix".fnsolonumerosychar (SUBSTR(v_lote_nombre, 1, LENGTH(v_lote_nombre))) RETURNING v_lote_nombre;					
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                            || "<DescripcionLote>" || v_lote_nombre || "</DescripcionLote>";
											
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                            || "<Edificio>" || v_edificio || "</Edificio>";
											
						CALL "informix".fnsolonumerosychar (SUBSTR(v_edificio_nombre, 1, LENGTH(v_edificio_nombre))) RETURNING v_edificio_nombre;				
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                            || "<DescripcionEdificio>" || v_edificio_nombre || "</DescripcionEdificio>";
											
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                            || "<Entrada>" || v_entrada || "</Entrada>";
											
						CALL "informix".fnsolonumerosychar (SUBSTR(v_entrada_nombre, 1, LENGTH(v_entrada_nombre))) RETURNING v_entrada_nombre;					
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                            || "<DescripcionEntrada>" || v_entrada_nombre || "</DescripcionEntrada>";
											
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                        || "</UnidadHabitacional>";
                    END IF;
                    --cerrar la etiqueta del domicilio
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo)) || "</Domicilio>";

					IF EXISTS(SELECT {+ INDEX ("informix".ss_solicitudes idx_numctempresa)}
                            secuenciatelefono FROM "informix".ss_osteltelefonos
                            WHERE secuenciaostel = p_secuencia AND secuencia = v_ref_secuencia) THEN

                        FOREACH

                            SELECT {+ INDEX ("informix".ss_osteltelefonos idx_secostelsectel)}
                            NVL(tipo_telef,""), NVL(telefono,""), NVL(extension,""), NVL(destino,"0"), NVL(secuenciatelefono,0)
                            INTO v_tel_tipo_telef, v_tel_telefono, v_tel_extension, v_tel_destino, v_tel_secuenciatelefono
                            FROM "informix".ss_osteltelefonos
                            WHERE secuenciaostel = p_secuencia
                            AND secuencia = v_ref_secuencia

                            IF TRIM(v_tel_telefono) <> "" THEN

                                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<Telefonos>";

                                IF TRIM(v_tel_tipo_telef) = "F" THEN
                                    LET v_tel_tipo_telef = "2";
                                ELSE
                                    IF TRIM(v_tel_tipo_telef) = "M" THEN
                                        LET v_tel_tipo_telef = "1";
                                    END IF;
                                END IF;
								
								CALL "informix".fnsolonumerosychar (SUBSTR(v_tel_tipo_telef, 1, LENGTH(v_tel_tipo_telef))) RETURNING v_tel_tipo_telef;
                                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<TipoTelefono>" || v_tel_tipo_telef || "</TipoTelefono>";
								
								CALL "informix".fnsolonumerosychar (SUBSTR(v_tel_telefono, 1, LENGTH(v_tel_telefono))) RETURNING v_tel_telefono;	
                                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<Telefono>" || v_tel_telefono || "</Telefono>";
									
								CALL "informix".fnsolonumerosychar (SUBSTR(v_tel_extension, 1, LENGTH(v_tel_extension))) RETURNING v_tel_extension;	
                                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<Extension>" || v_tel_extension || "</Extension>";
									
								CALL "informix".fnsolonumerosychar (SUBSTR(v_tel_destino, 1, LENGTH(v_tel_destino))) RETURNING v_tel_destino;	
                                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<Destino>" || v_tel_destino || "</Destino>";
									
                                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                    || "<SecuenciaTelefono>" || v_tel_secuenciatelefono || "</SecuenciaTelefono>";
									
                                LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "</Telefonos>";

                            END IF;

                        END FOREACH;
                    END IF;
                    --cerrar la etiqueta de la referencia
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo)) || "</Referencias>";
                END FOREACH;
            ELSE
                LET vCod_Ret = "003";
                RETURN vCod_Ret, c_salida;
            END IF;
            IF EXISTS(SELECT  {+ INDEX ("informix".ss_osteltelefonos idx_secostelsectel)}
                    secuenciatelefono FROM "informix".ss_osteltelefonos
                    WHERE secuenciaostel = p_secuencia AND secuencia = 0) THEN
                FOREACH
                    SELECT {+ INDEX ("informix".ss_osteltelefonos idx_secostelsectel)}
                    NVL(tipo_telef,""), NVL(telefono,""), NVL(extension,""), NVL(destino,"0"), NVL(secuenciatelefono,0)
                    INTO v_tel_tipo_telef, v_tel_telefono, v_tel_extension, v_tel_destino, v_tel_secuenciatelefono
                    FROM "informix".ss_osteltelefonos
                    WHERE secuenciaostel = p_secuencia
                    AND secuencia = 0

                    IF TRIM(v_tel_telefono) <> "" THEN

                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                        || "<Telefonos>";

                        IF TRIM(v_tel_tipo_telef) = "F" THEN
                            LET v_tel_tipo_telef = "2";
                        ELSE
                            IF TRIM(v_tel_tipo_telef) = "M" THEN
                                LET v_tel_tipo_telef = "1";
                            END IF;
                        END IF;

						CALL "informix".fnsolonumerosychar (SUBSTR(v_tel_tipo_telef, 1, LENGTH(v_tel_tipo_telef))) RETURNING v_tel_tipo_telef;	
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<TipoTelefono>" || v_tel_tipo_telef || "</TipoTelefono>";
						
						CALL "informix".fnsolonumerosychar (SUBSTR(v_tel_telefono, 1, LENGTH(v_tel_telefono))) RETURNING v_tel_telefono;	
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<Telefono>" || v_tel_telefono || "</Telefono>";
							
						CALL "informix".fnsolonumerosychar (SUBSTR(v_tel_extension, 1, LENGTH(v_tel_extension))) RETURNING v_tel_extension;	
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<Extension>" || v_tel_extension || "</Extension>";
							
						CALL "informix".fnsolonumerosychar (SUBSTR(v_tel_destino, 1, LENGTH(v_tel_destino))) RETURNING v_tel_destino;	
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<Destino>" || v_tel_destino || "</Destino>";
							
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<SecuenciaTelefono>" || v_tel_secuenciatelefono || "</SecuenciaTelefono>";
							
                        LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                        || "</Telefonos>";

                    END IF;

                END FOREACH;
            END IF;

            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<Conyuge>";
			CALL "informix".fnsolonumerosychar (SUBSTR(v_cte_Nombre1conyuge, 1, LENGTH(v_cte_Nombre1conyuge))) RETURNING v_cte_Nombre1conyuge;
			CALL "informix".fnsolonumerosychar (SUBSTR(v_cte_Nombre2conyuge, 1, LENGTH(v_cte_Nombre2conyuge))) RETURNING v_cte_Nombre2conyuge;
			--HMBR
			LET cNombreConyuge = SUBSTR((TRIM(v_cte_Nombre1conyuge) || " "
                                || TRIM(v_cte_Nombre2conyuge)),1, 30);
								
			LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<NombreConyuge>" || cNombreConyuge || "</NombreConyuge>";								
			----
			CALL "informix".fnsolonumerosychar (SUBSTR(v_cte_apell_paternoconyuge, 1, LENGTH(v_cte_apell_paternoconyuge))) RETURNING v_cte_apell_paternoconyuge;
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<ApellidoPaternoConyuge>" || v_cte_apell_paternoconyuge || "</ApellidoPaternoConyuge>";
			
			CALL "informix".fnsolonumerosychar (SUBSTR(v_cte_apell_maternoconyuge, 1, LENGTH(v_cte_apell_maternoconyuge))) RETURNING v_cte_apell_maternoconyuge;
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<ApellidoMaternoConyuge>" || v_cte_apell_maternoconyuge || "</ApellidoMaternoConyuge>";
								
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<FechaNacimiento>" || tConyugeFechaNac || "</FechaNacimiento>"  ;

			CALL "informix".fnsolonumerosychar (SUBSTR(cConyugeSexoCodigo, 1, LENGTH(cConyugeSexoCodigo))) RETURNING cConyugeSexoCodigo;
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<Sexo>" || cConyugeSexoCodigo || "</Sexo>"  ;
								
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "</Conyuge>";

            --concatenar la trama del trabajo
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<TrabajoSolicitante>";
		
			CALL "informix".fnsolonumerosychar (SUBSTR(v_cte_lugartrabajo, 1, LENGTH(v_cte_lugartrabajo))) RETURNING v_cte_lugartrabajo;
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<LugarTrabajo>" || v_cte_lugartrabajo || "</LugarTrabajo>";
								
			CALL "informix".fnsolonumerosychar (SUBSTR(v_cte_estadotrabajo, 1, LENGTH(v_cte_estadotrabajo))) RETURNING v_cte_estadotrabajo;				
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<EstadoTrabajo>" || v_cte_estadotrabajo || "</EstadoTrabajo>";
								
			CALL "informix".fnsolonumerosychar (SUBSTR(v_cte_estadotrabajo_nombre, 1, LENGTH(v_cte_estadotrabajo_nombre))) RETURNING v_cte_estadotrabajo_nombre;
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<EstadoTrabajoNombre>" || v_cte_estadotrabajo_nombre || "</EstadoTrabajoNombre>";
								
			CALL "informix".fnsolonumerosychar (SUBSTR(v_cte_municipiotrabajo, 1, LENGTH(v_cte_municipiotrabajo))) RETURNING v_cte_municipiotrabajo;
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<MunicipioTrabajo>" || v_cte_municipiotrabajo || "</MunicipioTrabajo>";
								
			CALL "informix".fnsolonumerosychar (SUBSTR(v_cte_municipiotrabajo_nombre, 1, LENGTH(v_cte_municipiotrabajo_nombre))) RETURNING v_cte_municipiotrabajo_nombre;					
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<MunicipioTrabajoNombre>" || v_cte_municipiotrabajo_nombre || "</MunicipioTrabajoNombre>";
								
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<NumeroCiudadTrabajo>" || v_cte_numerociudadtrabajo || "</NumeroCiudadTrabajo>";
								
            CALL "informix".fnsolonumerosychar (SUBSTR(v_cte_ciudadtrabajo_nombre, 1, LENGTH(v_cte_ciudadtrabajo_nombre))) RETURNING v_cte_ciudadtrabajo_nombre;								
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<CiudadTrabajoNombre>" || v_cte_ciudadtrabajo_nombre || "</CiudadTrabajoNombre>";

								
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<ColoniaTrabajo>" || v_cte_coloniatrabajo || "</ColoniaTrabajo>";
								
			CALL "informix".fnsolonumerosychar (SUBSTR(v_cte_coloniatrabajo_nombre, 1, LENGTH(v_cte_coloniatrabajo_nombre))) RETURNING v_cte_coloniatrabajo_nombre;					
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<ColoniaTrabajoNombre>" || v_cte_coloniatrabajo_nombre || "</ColoniaTrabajoNombre>";
								
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<CalleTrabajo>" || v_cte_calletrabajo || "</CalleTrabajo>";
								
			CALL "informix".fnsolonumerosychar (SUBSTR(v_cte_calletrabajo_nombre, 1, LENGTH(v_cte_calletrabajo_nombre))) RETURNING v_cte_calletrabajo_nombre;					
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<CalleTrabajoNombre>" || v_cte_calletrabajo_nombre || "</CalleTrabajoNombre>";
								
			CALL "informix".fnsolonumerosychar (SUBSTR(v_cte_numeroextcalletrabajo, 1, LENGTH(v_cte_numeroextcalletrabajo))) RETURNING v_cte_numeroextcalletrabajo;					
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<NumeroCalleTrabajo>" || v_cte_numeroextcalletrabajo || "</NumeroCalleTrabajo>";
								
			CALL "informix".fnsolonumerosychar (SUBSTR(cPuestoTrabajo, 1, LENGTH(cPuestoTrabajo))) RETURNING cPuestoTrabajo;
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                                || "<Puesto>" || cPuestoTrabajo || "</Puesto>";
								
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "</TrabajoSolicitante>";

            --cerrar la etiqueta del solicitante
            LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo)) || "</Solicitante>";

            --se verifica si existen productos en los registros para el cliente
            IF EXISTS(SELECT {+ INDEX ("informix".ss_solicitudes idx_numctesolic)}
                num_producto FROM "informix".ss_solicitudes WHERE numcte = v_cte_numcte AND empresa = p_empresa AND status_solicitud = 'PC') THEN
                --se recupera cada producto del cliente y se agrega a la trama
                FOREACH
                    SELECT  {+ INDEX ("informix".ss_solicitudes idx_numctempresa)}
                    DISTINCT NVL(a.num_producto,""), NVL(c.descripcion,""),  NVL(a.sucursal,"")
                    INTO v_num_producto, v_nombre_prod, cSucursalCodigo
                    FROM "informix".ss_solicitudes AS a
                    INNER JOIN "informix".ss_solic_producto AS b ON (a.num_producto = b.num_producto AND a.empresa = b.empresa)
                    INNER JOIN "informix".ss_tp_solicitud AS c ON (b.tp_solicitud = c.tp_solicitud AND a.empresa = c.empresa)
					INNER JOIN "informix".ss_ostelrefsolicitud AS d ON (a.num_solicitud = d.num_solicitud)
                    WHERE  a.numcte = v_cte_numcte
                    AND a.empresa = p_empresa
                    AND a.status_solicitud = 'PC'
					AND d.secuenciaostel = p_secuencia

                    IF v_num_producto <> '6500' THEN
                        LET v_num_producto = '6001';
                    END IF;

                    SELECT NVL(nombre,'')
                    INTO cSucursalDescripcion
                    FROM bdinteg:"informix".si_sucursales
                    WHERE sucursal = cSucursalCodigo
                    AND empresa = p_empresa;

                    --eliminar el prefijo SUC. si existe en el nombre de la sucursal
                    IF SUBSTR(cSucursalDescripcion,1,5) = 'SUC. ' THEN
                        LET cSucursalDescripcion = SUBSTR(cSucursalDescripcion,6,LENGTH(cSucursalDescripcion));
                    END IF;

                    --armar el formato requerido para el nombre de la sucursal
                    LET cSucursalDescripcion = 'SUC: ' || cSucursalCodigo || ' ' || TRIM(cSucursalDescripcion);

                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                        || "<Productos>";
						
					CALL "informix".fnsolonumerosychar (SUBSTR(v_num_producto, 1, LENGTH(v_num_producto))) RETURNING v_num_producto;	
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<Tipo>" || v_num_producto || "</Tipo>";
					
					CALL "informix".fnsolonumerosychar (SUBSTR(v_nombre_prod, 1, LENGTH(v_nombre_prod))) RETURNING v_nombre_prod;
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<Producto>" || v_nombre_prod || "</Producto>";
							
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<Empresa>" || "2" || "</Empresa>";
							
					CALL "informix".fnsolonumerosychar (SUBSTR(cSucursalDescripcion, 1, LENGTH(cSucursalDescripcion))) RETURNING cSucursalDescripcion;
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                            || "<Sucursal>" || cSucursalDescripcion || "</Sucursal>";
							
                    LET c_cuerpo = SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo))
                        || "</Productos>";

                END FOREACH;
            ELSE
                LET vCod_Ret = "006";
                RETURN vCod_Ret, c_salida;
            END IF;

            LET c_salida = c_encabezado || SUBSTR(c_cuerpo, 1, LENGTH(c_cuerpo)) || c_cola;
            RETURN vCod_Ret,c_salida;
        ELSE
            LET vCod_Ret = "002";
            RETURN vCod_Ret, c_salida;
        END IF;
    END;
END PROCEDURE
