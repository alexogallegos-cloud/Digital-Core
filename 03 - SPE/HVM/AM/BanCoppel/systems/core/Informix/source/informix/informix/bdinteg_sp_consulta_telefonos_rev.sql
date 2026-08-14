CREATE PROCEDURE "informix".sp_consulta_telefonos_rev( pNumCte CHAR(20) ) -- NO. CLIENTE
RETURNING CHAR(5),   -- CODIGO DE RETORNO
          CHAR(10),  -- TELEFONO CASA
          SMALLINT,  -- TIPO TELEFONO CASA
          CHAR(1),   -- VALIDACION COFETEL CASA
          CHAR(10),  -- TELEFONO CELULAR
          SMALLINT,  -- TIPO TELEFONO CELULAR
          CHAR(1),   -- VALIDACION COFETEL CELULAR
          CHAR(10),  -- TELEFONO TRABAJO
          SMALLINT,  -- TIPO TELEFONO TRABAJO
          CHAR(5),   -- EXTENSION TELEFONO TRABAJO
          CHAR(1),   -- VALIDACION COFETEL TRABAJO
          CHAR(10),  -- TELEFONO OTRO
          SMALLINT,  -- TIPO TELEFONO OTRO
          CHAR(1),   -- VALIDACION COFETEL OTRO
          CHAR(100), -- CORREO ELECTRONICO
          CHAR(30),  -- CARRIER TELEFONO CELULAR
          CHAR(1),   -- INDICADOR TELEFONO
          CHAR(1);   -- INDICADOR CORREO
        
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    
    DEFINE vExisteCte       INTEGER;
    DEFINE vTelefono        CHAR(13);
    DEFINE vTipoTel         SMALLINT;
    DEFINE vCarrier         SMALLINT;
    DEFINE vExtension       CHAR(5);
    DEFINE vCofetel         CHAR(1);
    DEFINE vValCofetel      CHAR(1);
    DEFINE vTelefono1       CHAR(13);
    DEFINE vTipoTel1        SMALLINT;
    DEFINE vValCofetel1     CHAR(1);
    DEFINE vTelefono2       CHAR(13);
    DEFINE vTipoTel2        SMALLINT;
    DEFINE vNombreCarrier   CHAR(30);
    DEFINE vValCofetel2     CHAR(1);
    DEFINE vTelefono3       CHAR(13);
    DEFINE vTipoTel3        SMALLINT;
    DEFINE vExtension3      CHAR(5);
    DEFINE vValCofetel3     CHAR(1);
    DEFINE vTelefono4       CHAR(13);
    DEFINE vTipoTel4        SMALLINT;
    DEFINE vValCofetel4     CHAR(1);
    DEFINE vCorreo          CHAR(100);
    DEFINE vIndTelefono     CHAR(1);
    DEFINE vIndCorreo       CHAR(1);
    DEFINE vCodRetRev       CHAR(5);
    
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vcodret3 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    
    LET vExisteCte       = 0;
    LET vTelefono        = '';
    LET vTipoTel         = 0;
    LET vCarrier         = 0;
    LET vExtension       = '';
    LET vCofetel         = '';
    LET vValCofetel      = '';
    LET vTelefono1       = '';
    LET vTipoTel1        = 0;
    LET vValCofetel1     = '';
    LET vTelefono2       = '';
    LET vTipoTel2        = 0;
    LET vNombreCarrier   = '';
    LET vValCofetel2     = '';
    LET vTelefono3       = '';
    LET vTipoTel3        = 0;
    LET vExtension3      = '';
    LET vValCofetel3     = '';
    LET vTelefono4       = '';
    LET vTipoTel4        = 0;
    LET vValCofetel4     = '';
    LET vCorreo          = '';
    LET vIndTelefono     = '';
    LET vIndCorreo       = '';
    LET vCodRetRev       = '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consulta_telefonos_rev.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, 
                   vTelefono1, vTipoTel1, vValCofetel1, 
                   vTelefono2, vTipoTel2, vValCofetel2, 
                   vTelefono3, vTipoTel3, vExtension3, vValCofetel3, 
                   vTelefono4, vTipoTel4, vValCofetel4, 
                   vCorreo, vNombreCarrier, vIndTelefono, vIndCorreo;
                   
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consulta_telefonos_rev.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF ( pNumCte is null OR pNumCte = '' ) THEN
        LET vcodret1 = '110'; --- DATOS INSUFICIENTES
        RETURN vcodret1, 
               vTelefono1, vTipoTel1, vValCofetel1, 
               vTelefono2, vTipoTel2, vValCofetel2, 
               vTelefono3, vTipoTel3, vExtension3, vValCofetel3, 
               vTelefono4, vTipoTel4, vValCofetel4, 
               vCorreo, vNombreCarrier, vIndTelefono, vIndCorreo;
    END IF;

    -- // VALIDA EXISTA NUMERO DE CLIENTE
    SELECT COUNT(*)
      INTO vExisteCte
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = pNumCte;

    IF vExisteCte = 0 THEN
        LET vcodret1 = '104'; --- NO DE CLIENTE NO EXISTE
        RETURN vcodret1, 
               vTelefono1, vTipoTel1, vValCofetel1, 
               vTelefono2, vTipoTel2, vValCofetel2, 
               vTelefono3, vTipoTel3, vExtension3, vValCofetel3, 
               vTelefono4, vTipoTel4, vValCofetel4, 
               vCorreo, vNombreCarrier, vIndTelefono, vIndCorreo;
    END IF;
    
    FOREACH
        SELECT telefono, tipo_tel, extension, carrier, cofetel
          INTO vTelefono, vTipoTel, vExtension, vCarrier, vCofetel
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           
        IF vCofetel = 'V' THEN
            LET vValCofetel = '1';
        ELSE
            LET vValCofetel = '2';
        END IF;
        
        IF vTipoTel = 1 THEN
            LET vTelefono1    = vTelefono;
            LET vTipoTel1     = vTipoTel;
            LET vValCofetel1  = vValCofetel;
        END IF;
        
        IF vTipoTel = 2 THEN
            SELECT nombre_carrier
              INTO vNombreCarrier
              FROM bdinteg:"informix".si_carriers
             WHERE cve_carrier = vCarrier;

            IF vNombreCarrier is null THEN
                LET vNombreCarrier = ' ';
            END IF;
            
            LET vTelefono2     = vTelefono;
            LET vTipoTel2      = vTipoTel;
            LET vNombreCarrier = vCarrier ||' '|| vNombreCarrier;
            LET vValCofetel2   = vValCofetel;
        END IF;
        
        IF vTipoTel = 3 THEN
            LET vTelefono3    = vTelefono;
            LET vTipoTel3     = vTipoTel;
            LET vExtension3   = vExtension;
            LET vValCofetel3  = vValCofetel;            
        END IF;
        
        IF vTipoTel = 4 THEN
            LET vTelefono4    = vTelefono;
            LET vTipoTel4     = vTipoTel;
            LET vValCofetel4  = vValCofetel;
        END IF;
        
        LET vTelefono    = '';
        LET vTipoTel     = 0;
        LET vExtension   = '';
        LET vCarrier     = 0;
        LET vCofetel     = '';
        LET vValCofetel  = '';
    END FOREACH;
    
	-- CGP 09/02/2015
	-- Se aÃ±ade la maxima secuencia de los correos para evitar los errores -284
    SELECT correo_elec
      INTO vCorreo
      FROM "informix".si_correos
     WHERE numcte = pNumCte
       AND tipo_correo = 1
       AND status_correo = 'A'
	   and secuencia = 
	   (select max(secuencia)
	    FROM "informix".si_correos
		WHERE numcte = pNumCte
		AND tipo_correo = 1
		AND status_correo = 'A');
       
    IF vCorreo is null THEN
        LET vCorreo = ' ';
    END IF;
    
    EXECUTE PROCEDURE "informix".sp_valrevtelefonos(pNumCte)
    INTO vCodRetRev, vIndTelefono, vIndCorreo;
    
    END;
    
    RETURN vcodret1, 
           vTelefono1, vTipoTel1, vValCofetel1, 
           vTelefono2, vTipoTel2, vValCofetel2, 
           vTelefono3, vTipoTel3, vExtension3, vValCofetel3, 
           vTelefono4, vTipoTel4, vValCofetel4, 
           vCorreo, vNombreCarrier, vIndTelefono, vIndCorreo;
    
END PROCEDURE;