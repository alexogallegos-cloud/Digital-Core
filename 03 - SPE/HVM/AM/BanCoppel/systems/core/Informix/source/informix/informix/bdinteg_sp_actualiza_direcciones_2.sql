CREATE PROCEDURE "informix".sp_actualiza_direcciones_2(pempresa CHAR(3))
    
    RETURNING CHAR(5), CHAR(5), INTEGER;
    
    DEFINE vcodret          CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador        INTEGER;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vsql CHAR(200);
    DEFINE vnumcte CHAR(20);
    DEFINE vtipo_dir CHAR(1);  
    DEFINE vsecuencia_tmp SMALLINT;   
    DEFINE vsecuencia SMALLINT;
    DEFINE vcalle char(40);
    DEFINE vcolonia char(60);
    DEFINE ventre_calles char(40);
    DEFINE vpais char(3);
    DEFINE vestado char(2);
    DEFINE vciudad char(3);
    DEFINE vmunicipio char(5);
    DEFINE vcod_postal char(5);
    DEFINE vapart_postal char(11);
    DEFINE vtipo_telef1 char(1);
    DEFINE vtelefono1 char(13);
    DEFINE vtipo_telef2 char(1);
    DEFINE vtelefono2 char(13);
    DEFINE vtipo_telef3 char(1);
    DEFINE vtelefono3 char(13);
    DEFINE vextension char(5);
    DEFINE vestado_inegi char(2);
    DEFINE vmunicipio_inegi char(3);
    DEFINE vlocalidad_inegi char(4);
    DEFINE vnumerociudad smallint;
    DEFINE vnumeroextcalle char(10);
    DEFINE vnumerointcalle char(10);
    DEFINE vdepartamento char(6);
    DEFINE vnumerocalle integer;
    DEFINE vnumerocolonia integer;
    DEFINE vpuntocardinal char(1);
    DEFINE vunidadhabitac char(1);
    DEFINE vmanzana smallint;
    DEFINE votros smallint;
    DEFINE vandador smallint;
    DEFINE vetapa smallint;
    DEFINE vlote smallint;
    DEFINE vedificio smallint;
    DEFINE ventrada smallint;
    DEFINE vobservaciones char(80);
    DEFINE vuser_insert char(8) ;
    DEFINE vfecha_insert date; 
    DEFINE vind_cofeteltel1 char(1); 
    DEFINE vind_cofeteltel2 char(1); 
    DEFINE vind_cofeteltel3 char(1); 
    DEFINE vmaxsecuencia smallint;
    
    LET vcodret	     = '000';
    LET vcodret2     = '000';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET vcontador    = -1;
    LET ven_transacc = 0;
    
    LET vsql = '';
    LET vnumcte = '';
    LET vtipo_dir = '';
    LET vsecuencia_tmp = 0;
    LET vsecuencia = 0;
    LET vcalle = '';
    LET vcolonia = '';
    LET ventre_calles = '';
    LET vpais = '';
    LET vestado = '';
    LET vciudad = '';
    LET vmunicipio = '';
    LET vcod_postal = '';
    LET vapart_postal = '';
    LET vtipo_telef1 = '';
    LET vtelefono1 = '';
    LET vtipo_telef2 = '';
    LET vtelefono2 = '';
    LET vtipo_telef3 = '';
    LET vtelefono3 = '';
    LET vextension = '';
    LET vestado_inegi = '';
    LET vmunicipio_inegi = '';
    LET vlocalidad_inegi = '';
    LET vnumerociudad = 0;
    LET vnumeroextcalle = '';
    LET vnumerointcalle = '';
    LET vdepartamento = '';
    LET vnumerocalle = 0;
    LET vnumerocolonia = 0;
    LET vpuntocardinal = '';
    LET vunidadhabitac = '';
    LET vmanzana = 0;
    LET votros = 0;
    LET vandador = 0;
    LET vetapa = 0;
    LET vlote = 0;
    LET vedificio = 0;
    LET ventrada = 0;
    LET vobservaciones = '';
    LET vuser_insert = '';
    LET vfecha_insert = '';
    LET vind_cofeteltel1 = '';
    LET vind_cofeteltel2 = '';
    LET vind_cofeteltel3 = '';
    LET vmaxsecuencia = 0;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualiza_direcciones_2.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret = sql_err;
            LET vcodret2 = isam_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret, vcodret2, vcontador;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualiza_direcciones_2.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD
        SELECT UNIQUE numcte
          INTO vnumcte
          FROM si_direcciones_tmp
                
        IF (vcontador = -1) THEN
            BEGIN WORK;
            LET vcontador = 0;
            LET ven_transacc = 1;
        END IF;
        
        FOREACH
            SELECT UNIQUE tipo_dir
              INTO vtipo_dir
              FROM si_direcciones
             WHERE numcte = vnumcte
             
            SELECT MAX(secuencia)
              INTO vmaxsecuencia
              FROM si_direcciones
             WHERE numcte = vnumcte
               AND tipo_dir = vtipo_dir;
             
            SELECT secuencia, calle, colonia, entre_calles, pais, estado, ciudad, municipio, 
                   cod_postal, apart_postal, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension,
                   estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento,
                   numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote,
                   edificio, entrada, observaciones, user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3
              INTO vsecuencia, vcalle, vcolonia, ventre_calles, vpais, vestado, vciudad, vmunicipio, 
                   vcod_postal, vapart_postal, vtipo_telef1, vtelefono1, vtipo_telef2, vtelefono2, vtipo_telef3, vtelefono3, vextension,
                   vestado_inegi, vmunicipio_inegi, vlocalidad_inegi, vnumerociudad, vnumeroextcalle, vnumerointcalle, vdepartamento,
                   vnumerocalle, vnumerocolonia, vpuntocardinal, vunidadhabitac, vmanzana, votros, vandador, vetapa, vlote,
                   vedificio, ventrada, vobservaciones, vuser_insert, vfecha_insert, vind_cofeteltel1, vind_cofeteltel2, vind_cofeteltel3
              FROM si_direcciones
             WHERE numcte = vnumcte
               AND tipo_dir = vtipo_dir
               AND secuencia = vmaxsecuencia;
               
            EXECUTE PROCEDURE "informix".sp_direcc_actual
            ( vnumcte, vsecuencia, vtipo_dir, vcalle, vcolonia, ventre_calles, vpais, vestado, vciudad, vmunicipio, 
              vcod_postal, vapart_postal, vtipo_telef1, vtelefono1, vtipo_telef2, vtelefono2, vtipo_telef3, vtelefono3, vextension,
              vestado_inegi, vmunicipio_inegi, vlocalidad_inegi, vnumerociudad, vnumeroextcalle, vnumerointcalle, vdepartamento,
              vnumerocalle, vnumerocolonia, vpuntocardinal, vunidadhabitac, vmanzana, votros, vandador, vetapa, vlote,
              vedificio, ventrada, vobservaciones, vuser_insert, vfecha_insert, vind_cofeteltel1, vind_cofeteltel2, vind_cofeteltel3 );
        
            LET vtipo_dir = '';
            LET vsecuencia_tmp = 0;
            LET vsecuencia = 0;
            LET vcalle = '';
            LET vcolonia = '';
            LET ventre_calles = '';
            LET vpais = '';
            LET vestado = '';
            LET vciudad = '';
            LET vmunicipio = '';
            LET vcod_postal = '';
            LET vapart_postal = '';
            LET vtipo_telef1 = '';
            LET vtelefono1 = '';
            LET vtipo_telef2 = '';
            LET vtelefono2 = '';
            LET vtipo_telef3 = '';
            LET vtelefono3 = '';
            LET vextension = '';
            LET vestado_inegi = '';
            LET vmunicipio_inegi = '';
            LET vlocalidad_inegi = '';
            LET vnumerociudad = 0;
            LET vnumeroextcalle = '';
            LET vnumerointcalle = '';
            LET vdepartamento = '';
            LET vnumerocalle = 0;
            LET vnumerocolonia = 0;
            LET vpuntocardinal = '';
            LET vunidadhabitac = '';
            LET vmanzana = 0;
            LET votros = 0;
            LET vandador = 0;
            LET vetapa = 0;
            LET vlote = 0;
            LET vedificio = 0;
            LET ventrada = 0;
            LET vobservaciones = '';
            LET vuser_insert = '';
            LET vfecha_insert = '';
            LET vind_cofeteltel1 = '';
            LET vind_cofeteltel2 = '';
            LET vind_cofeteltel3 = '';
            LET vmaxsecuencia = 0;
        
        END FOREACH;
        
        LET vcontador = vcontador + 1;
    
        COMMIT WORK;
        BEGIN WORK;
            
        LET vnumcte = '';
        
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret, vcodret2, vcontador;

END PROCEDURE;