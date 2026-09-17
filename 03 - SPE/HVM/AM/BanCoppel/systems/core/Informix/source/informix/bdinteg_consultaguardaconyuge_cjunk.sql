CREATE PROCEDURE "informix".consultaguardaconyuge_cjunk( cEmpresa CHAR(3),
                                                         cNumSolicitud CHAR(20),
                                                         cNumCte CHAR(20),
                                                         cNumCteConyuge CHAR(20),
                                                         cUsuario CHAR(8) )
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
    DEFINE sNumIdenti CHAR(30);
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
    
    --Set debug file to '/pisa/pisabanco/ConsultaGuardaConyuge.out';
    --trace on;
    
    -----------------------------------------
    --CREADO: Rodolfo Tortolero Varela
    --FECHA: 2011-06-10
    --FUNCIONALIDAD: Guarda la información del conyuge como referencia agregandole el número de solicitud que va relacionado.
    ----------------------------------------

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 10;

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
                 FROM bdinteg:"informix".si_refclientes a, 
                      bdinteg:"informix".si_refdirecciones b
                WHERE a.empresa = cEmpresa
                  AND a.num_solicitud = cNumSolicitud
                  AND a.numcte = cNumcte
                  AND a.numcte = b.numcte
                  AND a.secuencia = b.secuencia
                  AND a.numcte_banco = cNumCteConyuge
                  AND a.parentesco = 'E') THEN
        
        LET cCodRet = "001";
        
    ELSE
        
        LET wBegin = "N";
        
        begin work;

        update bdinteg:"informix".si_param 
           set valor = cast(valor as integer) + 1 
         where empresa = cEmpresa 
           and cod_param = 121;
           
        SELECT cast(valor as integer) 
          INTO iSecuencia 
          FROM bdinteg:"informix".si_param 
         where empresa = cEmpresa 
           and cod_param = 121;

        commit work;

        if wBegin = 'S' THEN
            begin work;
        end if;

        --- SELECT MAX(secuencia) +1 INTO iSecuencia FROM si_refclientes;
        
        SELECT fecha_hoy 
          INTO dFechaHoy 
          FROM bdinteg:"informix".si_fechas;

        SELECT a.sucursal, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, a.rfc, a.string2, b.fecha_nac, b.curp, 
               b.sexo, b.estado_civil, b.nacionalidad, b.no_fm3, b.codidentifi, b.numidentifi, a.apell_casada, a.numcte_ref 
          INTO sSucursal, sApellPaterno, sApellMaterno, sNombre1, sNombre2, sRfc, sPersDomicilio, dFechaNac, sCurp, 
               sSexo, sEstadoCivil, sNacionalidad, sNoFm, sCodigoIden, sNumIdenti, sApellCasada, sNumcteRef
          FROM bdinteg:"informix".si_cliente a, 
               bdinteg:"informix".si_ctepf b
         WHERE a.numcte = b.numcte
           AND a.numcte = cNumCteConyuge;
           
        SELECT correo_elec
          INTO sEmail
          FROM si_correos
         WHERE numcte = cNumCteConyuge
           AND tipo_correo = 1
           AND status_correo = 'A';

        INSERT INTO bdinteg:"informix".si_refclientes 
        ( empresa, num_solicitud, numcte, sucursal, secuencia, apell_paterno, apell_materno, 
          nombre1, nombre2, rfc, fecha_nac, curp, sexo, estado_civil, nacionalidad, no_fm3, codidentifi, numidentifi, pers_domicilio, 
          email, parentesco, apellido_cas, numcte_ref, numcte_banco, user_insert, fecha_insert )
        VALUES 
        ( cEmpresa, cNumSolicitud, cNumCte, sSucursal, iSecuencia, sApellPaterno, sApellMaterno, sNombre1, sNombre2,
          sRfc, dFechaNac, sCurp, sSexo, sEstadoCivil, sNacionalidad, sNoFm, sCodigoIden, sNumIdenti, sPersDomicilio, 
          sEmail, 'E', sApellCasada, sNumcteRef, cNumCteConyuge, cUsuario, dFechaHoy );

        SELECT dir.calle, dir.colonia, dir.entre_calles, dir.pais, dir.estado, dir.ciudad, dir.municipio, dir.cod_postal, dir.apart_postal, 
               tel1.tipo_tel, tel1.telefono, tel2.tipo_tel, tel2.telefono, tel3.tipo_tel, tel3.telefono, tel3.extension, 
               dir.estado_inegi, dir.localidad_inegi, dir.numerociudad, dir.numeroextcalle, dir.numerointcalle, dir.departamento, 
               dir.numerocalle, dir.numerocolonia, dir.puntocardinal, dir.unidadhabitac, dir.manzana, dir.otros, dir.andador,
               dir.etapa, dir.lote, dir.edificio, dir.entrada, dir.observaciones, dir.ind_cofeteltel1, dir.ind_cofeteltel2, dir.ind_cofeteltel3
          INTO pcalle, pcolonia, pentre_calles, ppais, pentidad, plocalidad, pmunicipio, pcodpostal,  pApart_postal, ptipotel1, ptelefono1,
               ptipotel2, ptelefono2, ptipotel3, ptelefono3, pextension, pestado_inegi, plocalidad_inegi, pnociudad, pnoext, 
               pnoint, pdepto, pnocalle, pnocolonia, ppuntocar, punihabi, pmanz, ppotros, pandador, 
               petapa, plote, pedif, pentrada, pobserva, pCofeteltel1, pCofeteltel2, pCofeteltel3
          FROM bdinteg:"informix".si_direcciones_actual dir
          LEFT OUTER JOIN si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
          LEFT OUTER JOIN si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
          LEFT OUTER JOIN si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
         WHERE dir.numcte = cNumCteConyuge
        -- AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = cNumCteConyuge);
           AND dir.tipo_dir = '1';

        INSERT INTO bdinteg:"informix".si_refdirecciones
        ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, 
          municipio, cod_postal, apart_postal, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, 
          estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, 
          numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, 
          numcte_banco, user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3 )
        VALUES	
        ( cNumCte, iSecuencia, '1', pcalle, pcolonia, pentre_calles, ppais, pentidad, plocalidad, 
          pmunicipio, pcodpostal, pApart_postal, ptipotel1, ptelefono1, ptipotel2, ptelefono2, ptipotel3, ptelefono3, pextension, 
          pestado_inegi, '', plocalidad_inegi, pnociudad, pnoext, pnoint, pdepto, pnocalle, 
          pnocolonia, ppuntocar, punihabi, pmanz, ppotros, pandador, petapa, plote, pedif, pentrada, pobserva, 
          cNumCteConyuge, cUsuario, dFechaHoy, pCofeteltel1, pCofeteltel2, pCofeteltel3 );
        
    END IF;
    
    RETURN cCodRet;

    END;
    
END PROCEDURE;