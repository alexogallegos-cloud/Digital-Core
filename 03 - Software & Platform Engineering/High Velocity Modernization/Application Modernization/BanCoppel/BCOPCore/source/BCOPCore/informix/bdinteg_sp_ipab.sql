CREATE PROCEDURE "informix".sp_ipab( pFechaIni DATE, pFechaFin DATE, pNumCliente CHAR(20) ) 
RETURNING CHAR(5), CHAR(30), CHAR(30), CHAR(30), CHAR(30), CHAR(30), CHAR(30);
    
    DEFINE cTipoPersona, cPfisica, cExento_isr, cSujRet CHAR(1);
    DEFINE cPersona, cMes, cDia, canio, cNoEstado CHAR(2);
    DEFINE cNoPais CHAR(3);
    DEFINE cSucCta, cSucCte, vSucCta CHAR(4);
    DEFINE cCodRet, cCodRet2, cCodRet4, cCodRet5, cCodRet6, cCodRet7, cCodRet8 CHAR(5);
    DEFINE cCodPostal, cCodPostal2 CHAR(6);
    DEFINE cFechaNac CHAR(8);
    DEFINE cFecha, cTipoCodPos, cNumExtCalle CHAR(10);
    DEFINE cRfc, cTelefono, cTelefono2, cTelefono3, cTelefono4, cTelefono5, cTelefono6, cTelefono7 CHAR(13);
    DEFINE cCurp CHAR(18);
    DEFINE cNumCliente, cPais CHAR(20);
    DEFINE cMunicipio, cEstado CHAR(25);
    DEFINE cNombre, cApellido1, cApellido2 CHAR(26);
    DEFINE cNombreCalle, cColonia, cNomCiudadCte CHAR(30);
    DEFINE cArchivo1, cArchivo2, cArchivo3, cArchivo4, cArchivo5, cArchivo6 CHAR(40);
    DEFINE cCodRet3, cDesErr, cCorreo CHAR(60);
    DEFINE cStmt CHAR(200);
    DEFINE cSql CHAR(600);
    DEFINE dFechaNac DATE;
    DEFINE iCauRev, iCveUnica, iCveUnicaCrd, iExcluido, iExisteCodPos, iComit, iClasificaTitular, iCheques, iCreditos, iAnio, dNumsmdf, iNumCiudad SMALLINT;
    DEFINE iSqlErr, iSamErr, iCodPostal, iFechaNacimiento, iAniobase, iNumeroCalle, iNumColonia INTEGER;
    DEFINE dResiduo DECIMAL(6,2); 
    DEFINE dPorRetencionSuj, dPorRetSuj, dSmdf DECIMAL(9,6);
    DEFINE dSdoCheques, dSdoCredito DECIMAL(14,2);
    DEFINE dSaldoCompensado DECIMAL(15,2);
    DEFINE mbase_exenta MONEY(18,2);
    
    LET cTipoPersona = ''; LET cPfisica = ''; LET cExento_isr = ''; LET cSujRet = 'S';
    LET cPersona = ''; LET cMes = ''; LET cDia = ''; LET canio = ''; LET cNoEstado = '';
    LET cNoPais = '';
    LET cSucCta = ''; LET cSucCte = ''; LET vSucCta = '';
    LET cCodRet = '000'; LET cCodRet2 = '000'; LET cCodPostal = ''; LET cCodPostal2 = ''; LET cCodRet4 = ''; LET cCodRet5 = ''; LET cCodRet6 = ''; LET cCodRet7 = ''; LET cCodRet8 = '';
    LET cFechaNac = '';
    LET cFecha = ''; LET cTipoCodPos = ''; LET cNumExtCalle = '';
    LET cRfc = ''; LET cTelefono = ''; LET cTelefono2 = ''; LET cTelefono3 = ''; LET cTelefono4 = ''; LET cTelefono5 = ''; LET cTelefono6 = ''; LET cTelefono7 = '';
    LET cCurp = '';
    LET cNumCliente =  ''; LET cPais = '';
    LET cMunicipio = ''; LET cEstado =  '';
    LET cNombre =  ''; LET cApellido1 =  ''; LET cApellido2 =  '';
    LET cNombreCalle =  ''; LET cColonia =  ''; LET cNomCiudadCte = '';
    LET cArchivo1 = ''; LET cArchivo2 = ''; LET cArchivo3 = ''; LET cArchivo4 = ''; LET cArchivo5 = ''; LET cArchivo6 = '';
    LET cCodRet3 = ''; LET cDesErr = ''; LET cCorreo = '';
    LET cStmt = '';
    LET cSql = '';
    LET dFechaNac = '';
    LET iCauRev = ''; LET iCveUnica = 0; LET iCveUnicaCrd = 0; LET iExcluido = 0; LET iExisteCodPos = ''; LET iComit = 0; LET iClasificaTitular = 0; LET iCheques = 0; LET iCreditos = 0; LET iAnio = 0; LET dNumsmdf = 0; LET iNumCiudad = 0;
    LET iSqlErr = 0; LET iSamErr = 0; LET iCodPostal = 0; LET iFechaNacimiento = 0; LET iAniobase = 0; LET iNumeroCalle = 0; LET iNumColonia = 0;
    LET dResiduo = 0; 
    LET dPorRetencionSuj = 0.00; LET dPorRetSuj = 0.00; LET dSmdf = 0; 
    LET dSdoCheques = 0.00; LET dSdoCredito = 0.00;
    LET dSaldoCompensado = 0.00;
    LET mbase_exenta = 0; 
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_ipab.err';
        TRACE ON;
        LET cCodRet  = iSqlErr;
        LET cCodRet2 = iSamErr;
        LET cCodRet3 = cDesErr;
        LET cNumCliente = cNumCliente;
        IF iComit = 1 THEN
            ROLLBACK WORK;
        END IF;
        RETURN cCodRet, cArchivo1, cArchivo2, cArchivo3, cArchivo4, cArchivo5, cArchivo6; 
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_ipab.out';
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // VALIDA PARAMETROS DE ENTRADA 
    IF ( ( pFechaIni is null OR pFechaIni = '' ) OR ( pFechaFin is null OR pFechaFin = '' ) ) THEN
        LET cCodRet   = '110';
        RETURN cCodRet, 'LAS ', 'FECHAS', ' NO ', 'PUEDEN', ' SER ', 'NULAS'; 
    ELIF pFechaFin < pFechaIni THEN
        LET cCodRet   = '110';
        RETURN cCodRet, 'FECHA DE ', 'PROYECCION', ' MENOR', ' A LA ', 'FECHA DE', ' INICIO'; 
    ELIF ( pNumCliente is null OR pNumCliente = '' OR LENGTH(pNumCliente) <> 9 ) THEN
        LET cCodRet   = '110';
        RETURN cCodRet, 'DEBE ', 'CAPTURAR', ' UN ', 'NUMERO', ' DE ', 'CLIENTE'; 
    END IF;
    
    -- // INICIALIZA TABLAS DE TRABAJO
    EXECUTE PROCEDURE sp_ipab_borratablas(pNumCliente)
    INTO cCodRet4;
    
    IF cCodRet4 <> '000' THEN
        LET cCodRet  = '999';
        RETURN cCodRet, 'ERROR ', 'EN LA ', 'CREACION', ' DE LAS ', 'TABLAS DE', ' TRABAJO'; 
    END IF;
    
    -- // OBTENCION DE CLIENTES A PROCESAR
    EXECUTE PROCEDURE sp_ipab_obtienectes( pFechaIni, pNumCliente )
    INTO cCodRet5;
    
    IF cCodRet5 <> '000' THEN
        LET cCodRet  = '999';
        RETURN cCodRet, 'ERROR ', 'EN EL ', 'PROCESO', ' DE ', 'OBTENCION DE', ' CLIENTES'; 
    END IF;
    
    -- // CALCULO DE MONTO BASE EXENTO ISR
    LET iAnio = year(pFechaFin);
    LET dResiduo = mod(iAnio, 4);

    IF dResiduo = 0 THEN
        LET iAniobase = 366;
    ELSE
        LET iAniobase = 365;
    END IF;
    
    -- // VALOR DEL ISR / 100 LISTO PARA CALCULOS
    SELECT valor
      INTO dPorRetencionSuj
      FROM si_fechavalor
     WHERE tasa = 'I.S.R.'
       AND fecha = (SELECT MAX(fecha) FROM si_fechavalor WHERE tasa = 'I.S.R.');
	   
/* ##################################################	   
       
    -- // SALARIO MINIMO
    SELECT valor
      INTO dSmdf
      FROM bdicheq:sc_param
     WHERE empresa = '001'
       AND codparam = 'smdf';

    -- // NUMERO DE VECES PARA EL SALARIO MINIMO
    SELECT valor
      INTO dNumsmdf
      FROM bdicheq:sc_param
     WHERE empresa = '001'
       AND codparam = 'numsmdf';

    -- // BASE EXENTA DE IMPUESTO DE ISR PARA PF
    LET mBase_exenta = dSmdf * dNumsmdf * iAniobase;
	
################################################## */

	select valor 
	  into mBase_exenta
      from bdicheq:sc_param
	 where empresa = '001' 
	   and codparam = "baseexenta"; 	

    IF mBase_exenta IS NULL THEN
        LET mbase_exenta = 0;
    END IF;
    
    -- // FOREACH CLIENTES
    FOREACH WITH HOLD
        SELECT numcte
          INTO cNumCliente
          FROM si_cliente_ipab
        
        BEGIN WORK;
        LET iComit = 1;
        
        -- // OBTIENE DATOS PERSONALES DEL CLIENTE
        SELECT TRIM(cte.rfc) AS rfc,  
               TRIM(cte.tpo_persona) AS personalidad, 
               TRIM(cte.nombre1)||' '||TRIM(cte.nombre2) || Trim(cte.razon_social) AS nombre, 
               TRIM(cte.apell_paterno) AS apellpaterno, 
               TRIM(cte.apell_materno) AS apellmaterno, 
               TRIM(ctepf.curp) AS curp,
               cte.sucursal AS succte
          INTO cRfc, cPersona, cNombre, cApellido1, cApellido2, cCurp, cSucCte
          FROM bdinteg:si_cliente cte
          LEFT OUTER JOIN bdinteg:si_ctepf ctepf ON (ctepf.numcte = cte.numcte)
         WHERE cte.numcte = cNumCliente;
        
        SELECT correo_elec
          INTO cCorreo 
          FROM bdinteg:si_correos
         WHERE numcte = cNumCliente
           AND tipo_correo = 1
           AND status_correo = 'A'
           AND secuencia = ( SELECT MAX(secuencia) FROM bdinteg:si_correos WHERE numcte = cNumCliente AND tipo_correo = 1 AND status_correo = 'A' );
        
        -- // OBTIENE DIRECCIÓN DEL CLIENTE
        SELECT dir.numerocalle AS no_calle,
               TRIM(dir.numeroextcalle) AS no_ext_calle,     
               TRIM(dir.cod_postal) AS cod_postal,         
               TRIM(tel1.telefono) AS tel_casa,       
               TRIM(tel2.telefono) AS tel_casa2,      
               TRIM(tel3.telefono) AS tel_casa3,
               dir.numerociudad AS no_ciudad,
               dir.numerocolonia AS no_colonia,
               dir.estado AS no_estado,
               dir.pais AS no_pais
          INTO iNumeroCalle, cNumExtCalle, cCodPostal, cTelefono, cTelefono2, cTelefono3, iNumCiudad, iNumColonia, cNoEstado, cNoPais
          FROM bdinteg:si_direcciones_actual dir 
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
         WHERE dir.numcte = cNumCliente
           AND dir.tipo_dir = '1';
        
        IF iNumeroCalle = 644537 THEN
            LET iNumeroCalle = 134176;
        END IF;
        
        SELECT TRIM(calle.nombrecalle)||' '||cNumExtCalle AS calle
          INTO cNombreCalle
          FROM bdinteg:si_catcalles calle
         WHERE calle.numerocalle = iNumeroCalle;
         
        SELECT TRIM(NVL(zon.nombrezona,'')) AS colonia, 
               CASE WHEN (zon.numerocolonia = 8000) THEN 'POR ASIGNAR' ELSE TRIM(nvl(zon.municipiozona, '')) END AS municipio,   
               zon.codigopostalzona AS cod_postal2
          INTO cColonia, cMunicipio, cCodPostal2
          FROM bdinteg:si_catzonas zon 
         WHERE zon.numerociudad = iNumCiudad
           AND zon.numerocolonia = iNumColonia;
           
        SELECT TRIM(ciudad.nombreciudad) AS nomciudad
          INTO cNomCiudadCte
          FROM bdinteg:si_catciudades ciudad 
         WHERE ciudad.numerociudad = iNumCiudad;
         
        SELECT TRIM(edo.siglas) AS estado
          INTO cEstado
          FROM bdinteg:si_estadosipab edo 
         WHERE edo.estado = cNoEstado;
         
        SELECT TRIM(pai.nombre) AS nom_pais
          INTO cPais
          FROM bdinteg:si_paises pai 
         WHERE pai.pais = cNoPais;
         
        IF ( cNombreCalle is null OR cNombreCalle = '' ) OR 
           ( cColonia is null OR cColonia = '' ) OR 
           ( cMunicipio is null OR cMunicipio = '' ) OR 
           ( cNomCiudadCte is null OR cNomCiudadCte = '' ) THEN
         
            SELECT dir.numerocalle AS no_calle,
                   TRIM(dir.numeroextcalle) AS no_ext_calle,     
                   TRIM(dir.cod_postal) AS cod_postal,         
                   TRIM(tel1.telefono) AS tel_casa,       
                   TRIM(tel2.telefono) AS tel_casa2,      
                   TRIM(tel3.telefono) AS tel_casa3,
                   dir.numerociudad AS no_ciudad,
                   dir.numerocolonia AS no_colonia,
                   dir.estado AS no_estado,
                   dir.pais AS no_pais
              INTO iNumeroCalle, cNumExtCalle, cCodPostal, cTelefono, cTelefono4, cTelefono5, iNumCiudad, iNumColonia, cNoEstado, cNoPais
              FROM bdinteg:si_direcciones_actual dir 
              LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
              LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
              LEFT OUTER JOIN bdinteg:si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
             WHERE dir.numcte = cNumCliente
               AND dir.tipo_dir = '2';
               
            IF iNumeroCalle = 644537 THEN
                LET iNumeroCalle = 134176;
            END IF;
            
            SELECT TRIM(calle.nombrecalle)||' '||cNumExtCalle AS calle
              INTO cNombreCalle
              FROM bdinteg:si_catcalles calle
             WHERE calle.numerocalle = iNumeroCalle;
             
            SELECT TRIM(NVL(zon.nombrezona,'')) AS colonia, 
                   CASE WHEN (zon.numerocolonia = 8000) THEN 'POR ASIGNAR' ELSE TRIM(nvl(zon.municipiozona, '')) END AS municipio,   
                   zon.codigopostalzona AS cod_postal2
              INTO cColonia, cMunicipio, cCodPostal2
              FROM bdinteg:si_catzonas zon 
             WHERE zon.numerociudad = iNumCiudad
               AND zon.numerocolonia = iNumColonia;
               
            SELECT TRIM(ciudad.nombreciudad) AS nomciudad
              INTO cNomCiudadCte
              FROM bdinteg:si_catciudades ciudad 
             WHERE ciudad.numerociudad = iNumCiudad;
             
            SELECT TRIM(edo.siglas) AS estado
              INTO cEstado
              FROM bdinteg:si_estadosipab edo 
             WHERE edo.estado = cNoEstado;
             
            SELECT TRIM(pai.nombre) AS nom_pais
              INTO cPais
              FROM bdinteg:si_paises pai 
             WHERE pai.pais = cNoPais;
             
            IF ( cNombreCalle is null OR cNombreCalle = '' ) OR 
               ( cColonia is null OR cColonia = '' ) OR 
               ( cMunicipio is null OR cMunicipio = '' ) OR 
               ( cNomCiudadCte is null OR cNomCiudadCte = '' ) THEN
               
                SELECT dir.numerocalle AS no_calle,
                       TRIM(dir.numeroextcalle) AS no_ext_calle,     
                       TRIM(dir.cod_postal) AS cod_postal,         
                       TRIM(tel1.telefono) AS tel_casa,       
                       TRIM(tel2.telefono) AS tel_casa2,      
                       TRIM(tel3.telefono) AS tel_casa3,
                       dir.numerociudad AS no_ciudad,
                       dir.numerocolonia AS no_colonia,
                       dir.estado AS no_estado,
                       dir.pais AS no_pais
                  INTO iNumeroCalle, cNumExtCalle, cCodPostal, cTelefono, cTelefono6, cTelefono7, iNumCiudad, iNumColonia, cNoEstado, cNoPais
                  FROM bdinteg:si_direcciones_actual dir 
                  LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
                  LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
                  LEFT OUTER JOIN bdinteg:si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
                 WHERE dir.numcte = cNumCliente
                   AND dir.tipo_dir = '3';
                   
                IF iNumeroCalle = 644537 THEN
                    LET iNumeroCalle = 134176;
                END IF;
                
                SELECT TRIM(calle.nombrecalle)||' '||cNumExtCalle AS calle
                  INTO cNombreCalle
                  FROM bdinteg:si_catcalles calle
                 WHERE calle.numerocalle = iNumeroCalle;
                 
                SELECT TRIM(NVL(zon.nombrezona,'')) AS colonia, 
                       CASE WHEN (zon.numerocolonia = 8000) THEN 'POR ASIGNAR' ELSE TRIM(nvl(zon.municipiozona, '')) END AS municipio,   
                       zon.codigopostalzona AS cod_postal2
                  INTO cColonia, cMunicipio, cCodPostal2
                  FROM bdinteg:si_catzonas zon 
                 WHERE zon.numerociudad = iNumCiudad
                   AND zon.numerocolonia = iNumColonia;
                   
                SELECT TRIM(ciudad.nombreciudad) AS nomciudad
                  INTO cNomCiudadCte
                  FROM bdinteg:si_catciudades ciudad 
                 WHERE ciudad.numerociudad = iNumCiudad;
                 
                SELECT TRIM(edo.siglas) AS estado
                  INTO cEstado
                  FROM bdinteg:si_estadosipab edo 
                 WHERE edo.estado = cNoEstado;
                 
                SELECT TRIM(pai.nombre) AS nom_pais
                  INTO cPais
                  FROM bdinteg:si_paises pai 
                 WHERE pai.pais = cNoPais;
            END IF;
        END IF;
        
        ---  #############################  DIRECCIONES DE LA SUCURSAL DEL CLIENTE  #############################  ---
        IF ( cNombreCalle is null OR cNombreCalle = '' OR cNombreCalle = ' ' ) THEN
            SELECT TRIM(direccion1)
              INTO cNombreCalle
              FROM bdinteg:si_sucursales 
             WHERE sucursal = cSucCte;
        END IF;
        
        IF ( cColonia is null OR cColonia = '' OR cColonia = ' ' ) THEN
            SELECT d_codigo
              INTO cCodPostal
              FROM bdinteg:si_sucursales 
             WHERE sucursal = cSucCte;
             
            SELECT FIRST 1 TRIM(NVL(nombrezona,'')) 
              INTO cColonia
              FROM bdinteg:si_catzonas 
             WHERE codigopostalzona = cCodPostal;
             
            LET cCodPostal2 = cCodPostal;
        END IF;
        
        IF ( cMunicipio is null OR cMunicipio = '' OR cMunicipio = ' ' OR cMunicipio = 'POR ASIGNAR' ) THEN
            SELECT d_codigo
              INTO cCodPostal
              FROM bdinteg:si_sucursales 
             WHERE sucursal = cSucCte;
             
            SELECT FIRST 1 TRIM(NVL(municipiozona,'')) 
              INTO cMunicipio
              FROM bdinteg:si_catzonas 
             WHERE codigopostalzona = cCodPostal;
        END IF;
        
        IF ( cMunicipio is null OR cMunicipio = '' OR cMunicipio = ' ' OR cMunicipio = 'POR ASIGNAR' ) THEN
            LET cMunicipio = cColonia;
        END IF;
        
        IF ( cNomCiudadCte is null OR cNomCiudadCte = '' OR cNomCiudadCte = ' ' ) THEN
            LET cNomCiudadCte = cMunicipio;
        END IF;
        
        IF ( cEstado is null OR cEstado = '' OR cEstado = ' ' ) THEN
            SELECT estado
              INTO cNoEstado
              FROM bdinteg:si_sucursales 
             WHERE sucursal = cSucCte;
             
            SELECT TRIM(edo.siglas) AS estado
              INTO cEstado
              FROM bdinteg:si_estadosipab edo 
             WHERE edo.estado = cNoEstado;
        END IF;
        
        IF ( cPais is null OR cPais = '' OR cPais = ' ' ) THEN
            SELECT TRIM(pai.nombre) AS nom_pais
              INTO cPais
              FROM bdinteg:si_paises pai 
             WHERE pai.pais = '001';
        END IF;
        ---  #############################  DIRECCIONES DE LA SUCURSAL DEL CLIENTE  #############################  --- 
          
        SELECT COUNT(*) 
          INTO iExisteCodPos
          FROM bdinteg:si_catsepomex
         WHERE d_codigo = cCodPostal;
         
        IF iExisteCodPos > 0 THEN
            LET cTipoCodPos = 'DIRECCION';
        ELSE
            SELECT COUNT(*) 
              INTO iExisteCodPos
              FROM bdinteg:si_catsepomex
             WHERE d_codigo = cCodPostal2;
             
            IF iExisteCodPos > 0 THEN
                LET cTipoCodPos = 'CATZONAS';
                LET cCodPostal = cCodPostal2;
            ELSE
                SELECT LIMIT 1 sucursal
                  INTO vSucCta
                  FROM bdicheq:sc_maechq
                 WHERE num_cte = cNumCliente;
                 
                SELECT d_codigo
                  INTO cCodPostal
                  FROM bdinteg:si_sucursales
                 WHERE sucursal = vSucCta;
                 
                LET cTipoCodPos = 'SUCURSAL';
            END IF;
        END IF;
        
        -- // VALIDA SI SE OBTUVO EL TELEFONO DEL CLIENTE
        IF cTelefono is null OR cTelefono = '' THEN
            LET cTelefono = cTelefono2;
            IF cTelefono is null OR cTelefono = '' THEN
                LET cTelefono = cTelefono3;
                IF cTelefono is null OR cTelefono = '' THEN
                    LET cTelefono = cTelefono4;
                    IF cTelefono is null OR cTelefono = '' THEN
                        LET cTelefono = cTelefono5;
                        IF cTelefono is null OR cTelefono = '' THEN
                            LET cTelefono = cTelefono6;
                            IF cTelefono is null OR cTelefono = '' THEN
                                LET cTelefono = cTelefono7;
                                IF cTelefono = '' OR cTelefono is null THEN
                                    LET cTelefono = NULL;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
        
        -- // OBTIENE EL TIPO DE CLIENTE
        SELECT es_fisica, exento_isr
          INTO cPfisica, cExento_isr
          FROM si_tipper
         WHERE tpo_persona = cPersona;
        
        IF cPfisica = 'S' THEN
            LET cTipoPersona = 'F';
        ELSE
            LET cTipoPersona = 'M';
            LET cApellido1 = NULL;
            LET cApellido2 = NULL;
        END IF;
        
        IF cTipoPersona IS NULL THEN
            LET iComit = 0;
            COMMIT WORK;
            CONTINUE FOREACH;
        END IF;
        
        -- // VALIDA SI ES EXENTO DE ISR
        IF cExento_isr = 'N' THEN
            LET cSujRet = 'S';
        ELSE
            LET cSujRet = 'N';
        END IF;
        
        IF cSujRet <> 'S' THEN
            LET dPorRetSuj = 0;
        ELSE
            LET dPorRetSuj = dPorRetencionSuj;
        END IF;
        
        -- // VALIDA DATOS
        IF cApellido2 = '' THEN
            LET cApellido2 = NULL;
        END IF;
        
        IF cCurp = '' OR LENGTH(cCurp) = 0 THEN
            LET cCurp = NULL;
        END IF;
        
        IF LENGTH(cCorreo) = 0 THEN
            LET cCorreo = NULL;
        END IF;
        
        -- // VALIDA SI EL CLIENTE ES EXCLUIDO DEL IPAB
        SELECT COUNT(*)
          INTO iExcluido
          FROM si_excluidosipab
         WHERE numcte = cNumCliente;
        
        IF iExcluido = 0 THEN
            LET iCauRev = 0;
        ELSE
            LET iCauRev = 1;
        END IF;
        
        -- // VERIFICA SI EL CLIENTE TIENE CUENTAS DE CHEQUES PARA REPORTARLAS
        EXECUTE PROCEDURE sp_repchequesipab( cNumCliente, pFechaIni, pFechaFin, dPorRetSuj, iAniobase, mBase_exenta, 0 ) 
        INTO cCodRet6;
        
        IF ( cCodRet6 IS NULL OR cCodRet6 = '' OR cCodRet6 <> '000' ) THEN
            ROLLBACK WORK;
            LET cCodRet = cCodRet6;
            RETURN cCodRet, 'ERROR', ' EN ', ' EL ', 'PROCESAMIENTO', ' DE ', 'CUENTAS'; 
        END IF;
        
        -- // VERIFICA SI EL CLIENTE TIENE PAGARES PARA REPORTARLOS
        EXECUTE PROCEDURE sp_reppagaresipab( cNumCliente, pFechaIni, pFechaFin, dPorRetSuj, iAniobase, 0 ) 
        INTO cCodRet7;
        
        IF ( cCodRet7 IS NULL OR cCodRet7 = '' OR cCodRet7 <> '000' ) THEN
            ROLLBACK WORK;
            LET cCodRet = cCodRet7;
            RETURN cCodRet, 'ERROR', ' EN ', ' EL ', 'PROCESAMIENTO', ' DE ', 'PAGARES'; 
        END IF;
        
        -- // VERIFICA SI EL CLIENTE TIENE CREDITOS PARA REPORTARLOS
        EXECUTE PROCEDURE sp_repcredsipab( cNumCliente, 0 ) 
        INTO cCodRet8;
        
        IF ( cCodRet8 IS NULL OR cCodRet8 = '' OR cCodRet8 NOT IN('00000','00002') ) THEN
            ROLLBACK WORK;
            LET cCodRet = cCodRet8;
            RETURN cCodRet, 'ERROR', ' EN ', ' EL ', 'PROCESAMIENTO', ' DE ', 'CREDITOS'; 
        END IF;
        
        -- // INSERTA INFORMACION PERSONAL DEL CLIENTE
        SELECT COUNT(*)
          INTO iCveUnica
          FROM si_ctaasotit
         WHERE cve_unica = cNumCliente;
         
        IF iCveUnica > 0 THEN
            SELECT SUM(chq.sdo_neto)
              INTO dSdoCheques
              FROM si_infpattit chq,
                   si_ctaasotit cta
             WHERE chq.numcta = cta.numcta
               AND chq.num_inversion = cta.num_inversion
               AND cta.cve_unica = cNumCliente;
               
            LET iCheques = 1;
        ELSE
            LET iCheques = 0;
        END IF;
         
         SELECT COUNT(*)
          INTO iCveUnicaCrd
          FROM si_crdasotit
         WHERE cve_unica = cNumCliente;
         
        IF iCveUnicaCrd > 0 THEN
            SELECT SUM(crd.cap_vigente + crd.cap_vencido + crd.ints_ord_exig + crd.ints_moratorios + crd.otros_accesorio)
              INTO dSdoCredito
              FROM si_infcrdtit crd,
                   si_crdasotit cta
             WHERE crd.num_credito = cta.num_credito
               AND cta.cve_unica = cNumCliente;
            
            LET iCreditos = 1;
        ELSE
            LET iCreditos = 0;
        END IF;
        
        IF ( iCheques = 1 OR iCreditos = 1 ) THEN
            LET iCodPostal = cCodPostal;
            LET cFechaNac = TO_CHAR(dFechaNac, '%Y%m%d');
            LET iFechaNacimiento = cFechaNac;
            LET dSaldoCompensado = dSdoCheques - dSdoCredito;
            
            IF ( iCheques = 1 AND iCreditos = 0 ) THEN
                LET iClasificaTitular = 1;
            ELIF ( iCheques = 0 AND iCreditos = 1 ) THEN
                LET iClasificaTitular = 2;
            ELIF ( iCheques = 1 AND iCreditos = 1 ) THEN
                LET iClasificaTitular = 3;
            END IF;
            
            IF dPorRetSuj = 0 THEN
                LET dPorRetSuj = NULL;
            END IF;
        
            INSERT INTO si_infpertit VALUES
            ( cNumCliente, cTipoPersona, cNombre, cApellido1, cApellido2, cNombreCalle, cColonia, cMunicipio, cNomCiudadCte, iCodPostal, cPais, cEstado, 
              cSujRet, dPorRetSuj, iCauRev, cRfc, cCurp, cTelefono, cCorreo, iFechaNacimiento, dSaldoCompensado, iClasificaTitular, cTipoCodPos );
        END IF;
        
        LET iComit = 0;
        COMMIT WORK;
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE si_infpertit;
    UPDATE STATISTICS MEDIUM FOR TABLE si_infpattit;
    UPDATE STATISTICS MEDIUM FOR TABLE si_ctaasotit;
    UPDATE STATISTICS MEDIUM FOR TABLE si_infcrdtit;
    UPDATE STATISTICS MEDIUM FOR TABLE si_crdasotit;
    UPDATE STATISTICS MEDIUM FOR TABLE si_prdchqtit;
    
    -- // CREACION DE ARCHIVOS
    LET cFecha = to_char(pFechaFin, '%Y/%m/%d');
    LET canio = cFecha[3,4];
    LET cmes  = cFecha[6,7];
    LET cdia  = cFecha[9,10];
    
    LET cArchivo1 = '01'||canio||cmes||cdia||'_'||trim(pNumCliente)||'.137';
    LET cArchivo2 = '02'||canio||cmes||cdia||'_'||trim(pNumCliente)||'.137';
    LET cArchivo3 = '03'||canio||cmes||cdia||'_'||trim(pNumCliente)||'.137';
    LET cArchivo4 = '04'||canio||cmes||cdia||'_'||trim(pNumCliente)||'.137';
    LET cArchivo5 = '05'||canio||cmes||cdia||'_'||trim(pNumCliente)||'.137';
    LET cArchivo6 = '06'||canio||cmes||cdia||'_'||trim(pNumCliente)||'.137';
    
    -- // PRIMER ARCHIVO (INFORMACION PERSONAL DEL CLIENTE)
    LET cSql = '';
    LET cSql = 'echo "UNLOAD TO ' || ("/resplogifx/conciliachq/ipab/"||TRIM(cArchivo1)) ||
               ' SELECT cve_unica, persona, nombre, apell_paterno,  apell_materno, callenum, colonia, delmun, ciudad, cod_postal, pais, estado, '||
               ' suj_retencion, por_retencion, causal_rev, rfc, curp, telefonos, correo, fecha_nac, sdo_compensado, clasif_tit '||
               ' FROM si_infpertit;" > /resplogifx/conciliachq/ipab/desc_ipab1.sql';
    SYSTEM cSql;
    
    LET cStmt = '';
    LET cStmt = '/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/ipab/desc_ipab1.sql';
    SYSTEM cStmt;
    
    -- // SEGUNDO ARCHIVO (INFORMACION PATRIMONIAL DEL CLIENTE)
    LET cSql = '';
    LET cSql = 'echo "UNLOAD TO ' || ("/resplogifx/conciliachq/ipab/"||TRIM(cArchivo2)) ||
               ' SELECT numcta, num_inversion, cve_producto, tipo_cta, reg_fiscal, por_retencion, cve_sucursal, '||
               ' sdo_cuenta, intereses, ret_impuestos, otros_accesorio, sdo_neto, moneda, fecha_corte, fecha_contrata, '||
               ' plazo_opera, tipo_tasa, tasa, inst_base, puntos_porc, operador, fecha_sig_corte, sdo_prom_diario '||
               ' FROM si_infpattit;" > /resplogifx/conciliachq/ipab/desc_ipab2.sql';
    SYSTEM cSql;
    
    LET cStmt = '';
    LET cStmt = '/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/ipab/desc_ipab2.sql';
    SYSTEM cStmt;
    
    -- // TERCER ARCHIVO (CUENTAS ASOCIADAS DEL CLIENTE)
    LET cSql = '';
    LET cSql = 'echo "UNLOAD TO ' || ("/resplogifx/conciliachq/ipab/"||TRIM(cArchivo3)) ||
               ' SELECT numcta, num_inversion, cve_unica, porcentaje_tit '||
               ' FROM si_ctaasotit;" > /resplogifx/conciliachq/ipab/desc_ipab3.sql';
    SYSTEM cSql;
    
    LET cStmt = '';
    LET cStmt = '/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/ipab/desc_ipab3.sql';
    SYSTEM cStmt;
        
    -- // CUARTO ARCHIVO (INFORMACION CREDITICIA DEL CLIENTE)
    LET cSql = '';
    LET cSql = 'echo "UNLOAD TO ' || ("/resplogifx/conciliachq/ipab/"||TRIM(cArchivo4)) ||
               ' SELECT num_credito, moneda, segmento, tpo_cobranza, cap_vigente, cap_vencido, ints_ord_exig, ints_moratorios, otros_accesorio '||
               ' FROM si_infcrdtit;" > /resplogifx/conciliachq/ipab/desc_ipab4.sql';
    SYSTEM cSql;
    
    LET cStmt = '';
    LET cStmt = '/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/ipab/desc_ipab4.sql';
    SYSTEM cStmt;
    
    -- // QUINTO ARCHIVO (CREDITOS ASOCIADOS DEL CLIENTE)
    LET cSql = '';
    LET cSql = 'echo "UNLOAD TO ' || ("/resplogifx/conciliachq/ipab/"||TRIM(cArchivo5)) ||
               ' SELECT num_credito, cve_unica '||
               ' FROM si_crdasotit;" > /resplogifx/conciliachq/ipab/desc_ipab5.sql';
    SYSTEM cSql;
    
    LET cStmt = '';
    LET cStmt = '/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/ipab/desc_ipab5.sql';
    SYSTEM cStmt;
    
    -- // SEXTO ARCHIVO (CATALOGO DE PRODUCTOS DE CAPTACION)
    LET cSql = '';
    LET cSql = 'echo "UNLOAD TO ' || ("/resplogifx/conciliachq/ipab/"||TRIM(cArchivo6)) ||
               ' SELECT cve_producto, nombre_producto, clasificacion, nivel_producto '||
               ' FROM si_prdchqtit;" > /resplogifx/conciliachq/ipab/desc_ipab6.sql';
    SYSTEM cSql;
    
    LET cStmt = '';
    LET cStmt = '/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/ipab/desc_ipab6.sql';
    SYSTEM cStmt;
    
    END;
    
    RETURN cCodRet, cArchivo1, cArchivo2, cArchivo3, cArchivo4, cArchivo5, cArchivo6; 
    
END PROCEDURE;