CREATE PROCEDURE "informix".consdirec_n(pnumcte CHAR(20), pconsulta INTEGER, ptipo_dir INTEGER, pnum_direc SMALLINT)
       RETURNING CHAR(5), -- Codigo Retorno
				CHAR(20), -- numcte
				INTEGER, -- secuencia
                                CHAR(1), -- tipo_dir
                                CHAR(40), -- calle
                                CHAR(60), -- colonia
                                CHAR(40), -- entre_calles
                                CHAR(3), -- pais
                                CHAR(2), -- estado
                                CHAR(3), -- ciudad
                                CHAR(5), -- municipio
                                CHAR(5), -- cod_postal
                                CHAR(11), -- apart_postal
                                CHAR(1), -- tipo_telef1
                                CHAR(13), -- telefono1
                                CHAR(1), -- tipo_telef2
                                CHAR(13), -- telefono2
                                CHAR(1), -- tipo_telef3
                                CHAR(13), -- telefono3
                                CHAR(5), -- extension
                                CHAR(2), -- estado_inegi
                                CHAR(3), -- municipio_inegi
                                CHAR(4),-- localidad_inegi
                                SMALLINT, --numerocuidad
                                CHAR(10), -- numextcalle
                                CHAR(10), -- numintcalle
                                CHAR(6), -- departamento
                                INTEGER, -- numerocalle
                                INTEGER, -- numerocolonia
                                CHAR(1), -- puntocardinal
                                CHAR(1), -- unidadhabitac
                                SMALLINT, -- manzana
                                SMALLINT, -- otros
                                SMALLINT, -- andador
                                SMALLINT, -- etapa
                                SMALLINT, -- lote
                                SMALLINT, -- edificio
                                SMALLINT, -- entrada
                                CHAR(80), -- observaciones
                                CHAR(8), -- user_insert
                                DATE, -- fecha_insert
                                CHAR(1), -- ind_cofeteltel1
                                CHAR(1), -- ind_cofeteltel2
                                CHAR(1); -- ind_cofeteltel3

-- Define de Variables
DEFINE vcodret char(5);
DEFINE vciclo smallint;
DEFINE vsqlerr integer;

-- Define  variables de la tabla si_direcciones y si_direcciones_actual
DEFINE vnumcte CHAR(20);
DEFINE vsecuencia INTEGER;
DEFINE vtipo_dir CHAR(1);
DEFINE vcalle CHAR(40);
DEFINE vcolonia CHAR(60);
DEFINE ventre_calles CHAR(40);
DEFINE vpais CHAR(3);
DEFINE vestado CHAR(2);
DEFINE vciudad CHAR(3);
DEFINE vmunicipio CHAR(5);
DEFINE vcod_postal CHAR(5);
DEFINE vapart_postal CHAR(11);
DEFINE vtipo_telef1  CHAR(1);
DEFINE vtelefono1 CHAR(13);
DEFINE vtipo_telef2  CHAR(1);
DEFINE vtelefono2  CHAR(13);
DEFINE vtipo_telef3  CHAR(1);
DEFINE vtelefono3  CHAR(13);
DEFINE vextension CHAR(5);
DEFINE vestado_inegi  CHAR(2);
DEFINE vmunicipio_inegi CHAR(3);
DEFINE vlocalidad_inegi  CHAR(4);
DEFINE vnumerociudad SMALLINT;
DEFINE vnumeroextcalle  CHAR(10);
DEFINE vnumerointcalle  CHAR(10);
DEFINE vdepartamento  CHAR(6);
DEFINE vnumerocalle INTEGER;
DEFINE vnumerocolonia INTEGER;
DEFINE vpuntocardinal  CHAR(1);
DEFINE vunidadhabitac  CHAR(1);
DEFINE vmanzana SMALLINT;
DEFINE votros  SMALLINT;
DEFINE vandador SMALLINT;
DEFINE vetapa SMALLINT;
DEFINE vlote  SMALLINT;
DEFINE vedificio  SMALLINT;
DEFINE ventrada  SMALLINT;
DEFINE vobservaciones CHAR(80);
DEFINE vuser_insert CHAR(8);
DEFINE vfecha_insert DATE;
DEFINE vind_cofeteltel1 CHAR(1);
DEFINE vind_cofeteltel2 CHAR(1);
DEFINE vind_cofeteltel3 CHAR(1);

--Inicializa variables
LET vciclo = 0;
LET vcodret = "000";
LET  vsqlerr = 0;
-- Inicializa variables de la tabla si_direcciones y si_direcciones_actual
LET vnumcte = "";
LET vsecuencia = 0;
LET vtipo_dir = "";
LET vcalle = "";
LET vcolonia = "";
LET ventre_calles = "";
LET vpais = "";
LET vestado = "";
LET vciudad = "";
LET vmunicipio = "";
LET vcod_postal = "";
LET vapart_postal = "";
LET vtipo_telef1 = "";
LET vtelefono1 = "";
LET vtipo_telef2 = "";
LET vtelefono2 = "";
LET vtipo_telef3 = "";
LET vtelefono3 = "";
LET vextension = "";
LET vestado_inegi = "";
LET vmunicipio_inegi = "";
LET vlocalidad_inegi = "";
LET vnumerociudad = 0;
LET vnumeroextcalle = "";
LET vnumerointcalle = "";
LET vdepartamento = "";
LET vnumerocalle = 0;
LET vnumerocolonia = 0;
LET vpuntocardinal = "";
LET vunidadhabitac = "";
LET vmanzana = 0;
LET votros  = 0;
LET vandador  = 0;
LET vetapa = 0;
LET vlote = 0;
LET vedificio  = 0;
LET ventrada = 0;
LET vobservaciones = "";
LET vuser_insert = "";
LET vfecha_insert = "";
LET vind_cofeteltel1 = "";
LET vind_cofeteltel2 = "";
LET vind_cofeteltel3 = "";

    --SET DEBUG FILE TO "/respaldosbd/consdirec_n.out";
    --TRACE ON;

BEGIN
    ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vcodret,vnumcte,vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,vciudad,vmunicipio,vcod_postal,vapart_postal,
                         vtipo_telef1,vtelefono1,vtipo_telef2,vtelefono2,vtipo_telef3,vtelefono3,vextension,vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,
                         vnumerociudad,vnumeroextcalle,vnumerointcalle,vdepartamento,vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,
                         vmanzana,votros,vandador,vetapa,vlote,vedificio,ventrada,vobservaciones,vuser_insert,vfecha_insert,vind_cofeteltel1,
                         vind_cofeteltel2,vind_cofeteltel3;
     END IF;
   END EXCEPTION;

   SET LOCK MODE TO WAIT 3;

   IF pconsulta = 1 THEN
        FOREACH
            SELECT  dir.numcte,dir.secuencia,dir.tipo_dir,dir.calle,dir.colonia,dir.entre_calles,dir.pais,dir.estado,dir.ciudad,dir.municipio,dir.cod_postal,dir.apart_postal,
                    tel1.tipo_tel,tel1.telefono,tel2.tipo_tel,tel2.telefono,tel3.tipo_tel,tel3.telefono,tel3.extension,
                    dir.estado_inegi,dir.municipio_inegi,dir.localidad_inegi,dir.numerociudad,dir.numeroextcalle,dir.numerointcalle,
                    dir.departamento,dir.numerocalle,dir.numerocolonia,dir.puntocardinal,dir.unidadhabitac,dir.manzana,dir.otros,dir.andador,dir.etapa,dir.lote,dir.edificio,
                    dir.entrada,dir.observaciones,dir.user_insert,dir.fecha_insert,dir.ind_cofeteltel1,dir.ind_cofeteltel2,dir.ind_cofeteltel3
            INTO    vnumcte,vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,vciudad,vmunicipio,vcod_postal,vapart_postal,vtipo_telef1,
                    vtelefono1,vtipo_telef2,vtelefono2,vtipo_telef3,vtelefono3,vextension,vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,vnumerociudad,
                    vnumeroextcalle,vnumerointcalle,vdepartamento,vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,vmanzana,votros,
                    vandador,vetapa,vlote,vedificio,ventrada,vobservaciones,vuser_insert,vfecha_insert,vind_cofeteltel1,vind_cofeteltel2,vind_cofeteltel3
            FROM bdinteg:"informix".si_direcciones_actual dir
            LEFT OUTER JOIN si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
            LEFT OUTER JOIN si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
            LEFT OUTER JOIN si_telefonos_actual tel3 ON (tel3.numcte = dir.numcte AND tel3.tipo_tel = 3)
            WHERE dir.numcte = pnumcte
            ORDER BY dir.tipo_dir

            LET vciclo = vciclo+1;

            IF vciclo <= pnum_direc THEN
                CONTINUE FOREACH;
            END IF
	  
            RETURN vcodret,vnumcte,vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,vciudad,vmunicipio,vcod_postal,vapart_postal,
                            vtipo_telef1,vtelefono1,vtipo_telef2,vtelefono2,vtipo_telef3,vtelefono3,vextension,vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,
                            vnumerociudad,vnumeroextcalle,vnumerointcalle,vdepartamento,vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,
                            vmanzana,votros,vandador,vetapa,vlote,vedificio,ventrada,vobservaciones,vuser_insert,vfecha_insert,vind_cofeteltel1,
                            vind_cofeteltel2,vind_cofeteltel3  WITH RESUME;

        END FOREACH;
  END IF

  IF pconsulta = 2 THEN
        FOREACH
            SELECT dir.numcte,dir.secuencia,dir.tipo_dir,dir.calle,dir.colonia,dir.entre_calles,dir.pais,dir.estado,dir.ciudad,dir.municipio,dir.cod_postal,dir.apart_postal,
                   tel1.tipo_tel,tel1.telefono,tel2.tipo_tel,tel2.telefono,tel3.tipo_tel,tel3.telefono,tel3.extension,
                   dir.estado_inegi,dir.municipio_inegi,dir.localidad_inegi,dir.numerociudad,dir.numeroextcalle,dir.numerointcalle,dir.departamento,
                   dir.numerocalle,dir.numerocolonia,dir.puntocardinal,dir.unidadhabitac,dir.manzana,dir.otros,dir.andador,dir.etapa,dir.lote,dir.edificio,
                   dir.entrada,dir.observaciones,dir.user_insert,dir.fecha_insert,dir.ind_cofeteltel1,dir.ind_cofeteltel2,dir.ind_cofeteltel3
            INTO   vnumcte,vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,vciudad,vmunicipio,vcod_postal,vapart_postal,vtipo_telef1,
                   vtelefono1,vtipo_telef2,vtelefono2,vtipo_telef3,vtelefono3,vextension,vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,vnumerociudad,
                   vnumeroextcalle,vnumerointcalle,vdepartamento,vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,vmanzana,votros,
                   vandador,vetapa,vlote,vedificio,ventrada,vobservaciones,vuser_insert,vfecha_insert,vind_cofeteltel1,vind_cofeteltel2,vind_cofeteltel3
            FROM bdinteg:"informix".si_direcciones dir
            LEFT OUTER JOIN si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
            LEFT OUTER JOIN si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
            LEFT OUTER JOIN si_telefonos_actual tel3 ON (tel3.numcte = dir.numcte AND tel3.tipo_tel = 3)
            WHERE dir.numcte = pnumcte
            ORDER BY dir.secuencia

            LET vciclo = vciclo+1;

            IF vciclo <= pnum_direc THEN
                CONTINUE FOREACH;
            END IF
	  
            RETURN vcodret,vnumcte,vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,vciudad,vmunicipio,vcod_postal,vapart_postal,
                            vtipo_telef1,vtelefono1,vtipo_telef2,vtelefono2,vtipo_telef3,vtelefono3,vextension,vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,
                            vnumerociudad,vnumeroextcalle,vnumerointcalle,vdepartamento,vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,
                            vmanzana,votros,vandador,vetapa,vlote,vedificio,ventrada,vobservaciones,vuser_insert,vfecha_insert,vind_cofeteltel1,
                            vind_cofeteltel2,vind_cofeteltel3  WITH RESUME;

        END FOREACH;
  END IF

  IF  pconsulta = 3 THEN
        FOREACH
            SELECT dir.numcte,dir.secuencia,dir.tipo_dir,dir.calle,dir.colonia,dir.entre_calles,dir.pais,dir.estado,dir.ciudad,dir.municipio,dir.cod_postal,dir.apart_postal,
                   tel1.tipo_tel,tel1.telefono,tel2.tipo_tel,tel2.telefono,tel3.tipo_tel,tel3.telefono,tel3.extension,
                   dir.estado_inegi,dir.municipio_inegi,dir.localidad_inegi,dir.numerociudad,dir.numeroextcalle,dir.numerointcalle,dir.departamento,
                   dir.numerocalle,dir.numerocolonia,dir.puntocardinal,dir.unidadhabitac,dir.manzana,dir.otros,dir.andador,dir.etapa,dir.lote,dir.edificio,
                   dir.entrada,dir.observaciones,dir.user_insert,dir.fecha_insert,dir.ind_cofeteltel1,dir.ind_cofeteltel2,dir.ind_cofeteltel3
            INTO   vnumcte,vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,vciudad,vmunicipio,vcod_postal,vapart_postal,vtipo_telef1,
                   vtelefono1,vtipo_telef2,vtelefono2,vtipo_telef3,vtelefono3,vextension,vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,vnumerociudad,
                   vnumeroextcalle,vnumerointcalle,vdepartamento,vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,vmanzana,votros,
                   vandador,vetapa,vlote,vedificio,ventrada,vobservaciones,vuser_insert,vfecha_insert,vind_cofeteltel1,vind_cofeteltel2,vind_cofeteltel3
            FROM bdinteg:"informix".si_direcciones dir
            LEFT OUTER JOIN si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
            LEFT OUTER JOIN si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
            LEFT OUTER JOIN si_telefonos_actual tel3 ON (tel3.numcte = dir.numcte AND tel3.tipo_tel = 3)
            WHERE dir.numcte = pnumcte
            AND dir.tipo_dir = ptipo_dir
            ORDER BY dir.secuencia
            
            LET vciclo = vciclo+1;

            IF vciclo <= pnum_direc THEN
                CONTINUE FOREACH;
            END IF
	  
            RETURN vcodret,vnumcte,vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,vciudad,vmunicipio,vcod_postal,vapart_postal,
                            vtipo_telef1,vtelefono1,vtipo_telef2,vtelefono2,vtipo_telef3,vtelefono3,vextension,vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,
                            vnumerociudad,vnumeroextcalle,vnumerointcalle,vdepartamento,vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,
                            vmanzana,votros,vandador,vetapa,vlote,vedificio,ventrada,vobservaciones,vuser_insert,vfecha_insert,vind_cofeteltel1,
                            vind_cofeteltel2,vind_cofeteltel3  WITH RESUME;

        END FOREACH;

   END IF

END

END PROCEDURE
DOCUMENT
"Consulta de direcciones del cliente a la si_direcciones_actual y si_direcciones",
"Autor : Daniela Viridiana Ramirez Perez",
"FECHA : 13/07/2011",
"BD    : bdinteg";

CREATE PROCEDURE "informix".consultaguardaconyuge( cEmpresa CHAR(3), cNumCte CHAR(20), cNumCteConyuge CHAR(20), cUsuario CHAR(8) )
RETURNING char(5);
    
    DEFINE cCodRet char(5);
    DEFINE iSqlErr INTEGER;
    
    DEFINE sSucursal CHAR(4);
    DEFINE sApellPaterno CHAR(26);
    DEFINE sApellMaterno CHAR(26);
    DEFINE sNombre1 CHAR(26);
    DEFINE sNombre2 CHAR(26);
    DEFINE sRfc CHAR(13);
    DEFINE dFechaNac DATE;
    DEFINE sCurp CHAR(20);
    DEFINE sSexo CHAR(1);
    DEFINE sEstadoCivil CHAR(2);
    DEFINE sNacionalidad CHAR(3);
    DEFINE sNoFm CHAR(18);
    DEFINE sCodigoIden CHAR(2);
    DEFINE sPersDomicilio CHAR(2);
    DEFINE sEmail CHAR(60);
    DEFINE sParentesco CHAR(2);
    DEFINE sApellCasada CHAR(26);
    DEFINE sNumcteRef CHAR(20);
    
    DEFINE pcalle char(40);
    DEFINE pcolonia char(60);
    DEFINE pmunicipio char(5);
    DEFINE pentre_calles char(40);
    DEFINE ppais char(3);
    DEFINE pentidad char(2);
    DEFINE plocalidad char(3);
    DEFINE pcodpostal char(5);
    DEFINE ptipotel1 char(1);
    DEFINE ptelefono1 char(13);
    DEFINE ptipotel2 char(1);
    DEFINE ptelefono2 char(13);
    DEFINE ptipotel3 char(1);
    DEFINE ptelefono3 char(13);
    DEFINE pextension char(5);
    DEFINE pestado_inegi char(2);
    DEFINE pmunicipio_inegi char(3);
    DEFINE plocalidad_inegi char(4);
    DEFINE pnociudad smallint;
    DEFINE pnoext char(10);
    DEFINE pnoint char(10);
    DEFINE pdepto char(6);
    DEFINE pnocalle integer;
    DEFINE pnocolonia integer;
    DEFINE ppuntocar char(1);
    DEFINE punihabi char(1);
    DEFINE pmanz smallint;
    DEFINE ppotros smallint;
    DEFINE pandador smallint;
    DEFINE petapa smallint;
    DEFINE plote smallint;
    DEFINE pedif smallint;
    DEFINE pentrada smallint;
    DEFINE pobserva char(80);
    DEFINE iSecuencia integer;
    DEFINE pCofeteltel1 char(1);
    DEFINE pCofeteltel2 char(1);
    DEFINE pCofeteltel3 char(1);
    DEFINE pApart_postal char (11);
    DEFINE dFechaHoy DATE;
    DEFINE wBegin CHAR(1);
    
    LET cCodRet = "000";
    
    --- Set debug file to '/pisa/pisabanco/ConsultaGuardaConyuge.out';
    --- trace on;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            ROLLBACK WORK;
            IF (wBegin = "S") THEN
                BEGIN WORK;
            END IF;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET wBegin = "S";
        COMMIT WORK;
        BEGIN WORK;
    END EXCEPTION WITH RESUME;
    
    IF EXISTS( SELECT 1 
                 FROM si_refclientes a, si_refdirecciones b 
                WHERE a.empresa = cEmpresa 
                  AND a.numcte = cNumcte 
                  AND a.numcte = b.numcte 
                  AND a.secuencia = b.secuencia
                  AND a.numcte_banco = cNumCteConyuge
                  AND a.parentesco = 'E') THEN
        LET cCodRet = "001";
    ELSE
        LET wBegin = "N";
    
        begin work;
    
        update si_param 
           set valor = cast(valor as integer) + 1 
         where empresa = cEmpresa 
           and cod_param = 121;
            
        SELECT cast(valor as integer) 
          INTO iSecuencia 
          FROM bdinteg:si_param 
         where empresa = cEmpresa 
           and cod_param = 121;
    
        commit work;
    
        if wBegin = 'S' THEN
            begin work;
        end if;
        
        /* #########################
        SELECT MAX(secuencia) + 1 
          INTO iSecuencia 
          FROM si_refclientes;
        ######################### */

        SELECT fecha_hoy 
          INTO dFechaHoy 
          FROM si_fechas;

        SELECT a.sucursal, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, a.rfc, a.string2, b.fecha_nac, 
               b.curp, b.sexo, b.estado_civil, b.nacionalidad, b.no_fm3, b.codidentifi, a.apell_casada, a.numcte_ref 
          INTO sSucursal, sApellPaterno, sApellMaterno, sNombre1, sNombre2, sRfc, sPersDomicilio, dFechaNac, 
               sCurp, sSexo, sEstadoCivil, sNacionalidad, sNoFm, sCodigoIden, sApellCasada, sNumcteRef
          FROM si_cliente a, 
               si_ctepf b
         WHERE a.numcte = b.numcte
           AND a.numcte = cNumCteConyuge;
           
        SELECT correo_elec
          INTO sEmail
          FROM si_correos
         WHERE numcte = cNumCteConyuge
           AND tipo_correo = 1
           AND status_correo = 'A';

        INSERT INTO si_refclientes VALUES
        ( cEmpresa, cNumCte ,sSucursal, iSecuencia, sApellPaterno, sApellMaterno, sNombre1, sNombre2,
          sRfc, dFechaNac, sCurp, sSexo, sEstadoCivil, sNacionalidad, sNoFm, sCodigoIden, sPersDomicilio, 
          sEmail, 'E', sApellCasada, sNumcteRef, cNumCteConyuge, cUsuario, dFechaHoy );

        SELECT dir.calle, dir.colonia, dir.entre_calles, dir.pais, dir.estado, dir.ciudad, dir.municipio, dir.cod_postal, dir.apart_postal, 
               tel1.tipo_tel, tel1.telefono, tel2.tipo_tel, tel2.telefono, tel3.tipo_tel, tel3.telefono, tel3.extension, 
               dir.estado_inegi, dir.localidad_inegi, dir.numerociudad, dir.numeroextcalle, dir.numerointcalle, dir.departamento, 
               dir.numerocalle, dir.numerocolonia, dir.puntocardinal, dir.unidadhabitac, dir.manzana, dir.otros, dir.andador,
               dir.etapa, dir.lote, dir.edificio, dir.entrada, dir.observaciones, dir.ind_cofeteltel1, dir.ind_cofeteltel2, dir.ind_cofeteltel3
          INTO pcalle, pcolonia, pentre_calles, ppais, pentidad, plocalidad, pmunicipio, pcodpostal,  pApart_postal, 
               ptipotel1, ptelefono1, ptipotel2, ptelefono2, ptipotel3, ptelefono3, pextension, 
               pestado_inegi, plocalidad_inegi, pnociudad, pnoext, 
               pnoint, pdepto, pnocalle, pnocolonia, ppuntocar, punihabi, pmanz, ppotros, pandador, 
               petapa, plote, pedif, pentrada, pobserva, pCofeteltel1, pCofeteltel2, pCofeteltel3
          FROM si_direcciones_actual dir
          LEFT OUTER JOIN si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
          LEFT OUTER JOIN si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
          LEFT OUTER JOIN si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
         WHERE dir.numcte = cNumCteConyuge
           AND dir.tipo_dir = '1';

        INSERT INTO si_refdirecciones VALUES
        ( cNumCte , iSecuencia, '1', pcalle, pcolonia, pentre_calles, ppais, pentidad, plocalidad, pmunicipio, pcodpostal,  
          pApart_postal, ptipotel1, ptelefono1, ptipotel2, ptelefono2, ptipotel3, ptelefono3, pextension, pestado_inegi,'', plocalidad_inegi, 
          pnociudad, pnoext, pnoint, pdepto, pnocalle, pnocolonia, ppuntocar, punihabi, pmanz, ppotros, pandador, 
          petapa, plote, pedif, pentrada, pobserva, cNumCteConyuge, cUsuario, dFechaHoy, pCofeteltel1, pCofeteltel2, pCofeteltel3 );
    END IF;
    
    RETURN cCodRet;

    END;
END PROCEDURE;