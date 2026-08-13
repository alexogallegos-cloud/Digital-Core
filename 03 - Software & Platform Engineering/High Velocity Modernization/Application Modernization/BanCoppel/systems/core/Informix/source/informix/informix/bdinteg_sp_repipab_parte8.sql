CREATE PROCEDURE "informix".sp_repipab_parte8( pFechaIni DATE, pFechaFin DATE ) 
RETURNING CHAR(5), CHAR(40), CHAR(40), CHAR(40);
     
    DEFINE cOperArit, cTipoPersona, cPfisica, cExento_isr, cSujRet, vtasavar, vrangofecha CHAR(1);          
    DEFINE cPersona, cTpoCuenta, cMoneda, cMes, cDia, canio, cVar1, cNoEstado CHAR(2);                                                 
    DEFINE cInstbase, cPorcentaje, cSobretasa, cNoPais CHAR(3);                                                                        
    DEFINE cNumProducto, cSucursal, vSucCta CHAR(4);                                                                                   
    DEFINE P_COD_RET, P_COD_RET2, cPlazo, cCodPostal, vCodRetSdos CHAR(5);                                                             
    DEFINE cCodPostal2 CHAR(6);                                                                                                         
    DEFINE cTasa, cFecAlt, cFechaNomArc, cTipoCodPos, cNumExtCalle CHAR(10);                                                            
    DEFINE cRfc, cTelefonoCasa, cTelefonoCasa2, cTelefonoCasa3, cTelefonoCasa4, cTelefonoCasa5, cTelefonoCasa6, cTelefonoCasa7 CHAR(13);
    DEFINE cCurp CHAR(18);                                                                                                              
    DEFINE cNumCuenta, cNumCliente, cPais, vctemin, vctemax CHAR(20);                                                                   
    DEFINE cDelegacionMunicipio, cEstado CHAR(25);                                                                                      
    DEFINE cNombre1, cApellido1, cApellido2 CHAR(26);                                                                                   
    DEFINE cNombreCalle, cColonia, cNomCiudadCte CHAR(30);                                                                              
    DEFINE cNom1, cNom2, cNom3 CHAR(40);                                                                                                
    DEFINE cProducto, cCorreo, P_COD_RET3, DESC_ERR CHAR(50);                                                                           
    DEFINE vstmt CHAR(100);                                                                                                             
    DEFINE vsql CHAR(200);                                                                                                              
    DEFINE dFechaCorte, dFechaSigcorte, dFecAlta, vFecAlta, vFechaCorte, vfecha_hoy DATE;                                               
    DEFINE sCauRev, sTipoTasa, dNumsmdf, sAnio, vcve_unica, vexcluido, vexiste, vaniomes, iExisteCodPos, iNumCiudad SMALLINT;           
    DEFINE iCtaInversion, iAniobase, nComit, SQL_ERR, ISAM_ERR, iDias_Ini, iDiasProyec, vcontador, vcontador2, iNumeroCalle, iNumColonia INTEGER;
    DEFINE sResiduo DECIMAL(6,2);                                                                                                           
    DEFINE dPorRetencionSuj, dPorRetSuj, dTasa, dSmdf, porcentaje, puntos DECIMAL(9,6);                                                                       
    DEFINE dImp_isr DECIMAL(14,6);                                                                                                          
    DEFINE mInt_al_Inicio, mbase_gravable, mbase_exenta, mInt_Proyec, mSdo_Proyec, dImp_Isr_Ini MONEY(18,2);                                
    DEFINE mSdo_Prom_Ini, mSdo_Fin, dImp_Isr_Fin, mSdo_Ini, mSdo_Prom_Fin, mSdo_Promedio, mSdo_31, mInt_31 MONEY(18,2);                              
    
    LET cOperArit = NULL;           LET cTipoPersona = '';          LET cPfisica = '';              LET cExento_isr = '';           LET cSujRet = 'S';  
    LET vtasavar  = '';             LET vrangofecha  = '';          LET cPersona = '';              LET cTpoCuenta = 'CI';          LET cMoneda = '';       
    LET cMes = '';                  LET cDia = '';                  LET canio = '';                 LET cVar1 =  '';                LET cInstbase = NULL;           
    LET cPorcentaje = NULL;         LET cSobretasa = NULL;          LET cNumProducto = '';          LET cSucursal = '';             LET vSucCta = '';
    LET P_COD_RET = '00000';        LET P_COD_RET2 = '00000';       LET cPlazo = NULL;              LET cCodPostal =  '';           LET cCodPostal2 = '';           
    LET cTasa = '';                 LET cFecAlt = NULL;             LET cFechaNomArc = '';          LET cTipoCodPos = '';           LET cNumExtCalle = '';          
    LET cRfc = '';                  LET cTelefonoCasa = '';         LET cTelefonoCasa2 = '';        LET cTelefonoCasa3 = '';        LET cTelefonoCasa4 = '';        
    LET cTelefonoCasa5 = '';        LET cTelefonoCasa6 = '';        LET cTelefonoCasa7 = '';        LET cCurp = '';                 LET cNumCuenta = '';            
    LET cNumCliente =  '';          LET cPais = '';                 LET vctemin = '';               LET vctemax = '';               LET cDelegacionMunicipio = '';  
    LET cEstado =  '';              LET cNombre1 =  '';             LET cApellido1 =  '';           LET cApellido2 =  '';           LET cNombreCalle =  '';         
    LET cColonia =  '';             LET cNomCiudadCte = '';         LET cnom1 = '';                 LET cnom2 = '';                 LET cnom3 = '';                 
    LET cProducto = '';             LET cCorreo = '';               LET P_COD_RET3 = '';            LET DESC_ERR = '';              LET vstmt = '';                 
    LET vsql = '';                  LET dFechaCorte = '';           LET dFechaSigcorte =  '';       LET dFecAlta = '';              LET vFecAlta = '';              
    LET vFechaCorte = '';           LET vfecha_hoy = '';            LET sCauRev = '';               LET sTipoTasa = 1;              LET dNumsmdf = 0;               
    LET sAnio = 0;                  LET vcve_unica = 0;             LET vexcluido = 0;              LET vexiste = 0;                LET vaniomes = 0;               
    LET iExisteCodPos = '';         LET iCtaInversion = 0;          LET iAniobase = 0;              LET nComit = 0;                 LET SQL_ERR = 0;                
    LET ISAM_ERR = 0;               LET iDias_Ini = 0;              LET iDiasProyec = 0;            LET vcontador = 0;              LET vcontador2 = 0;             
    LET iNumeroCalle = 0;           LET sResiduo = 0;               LET dPorRetSuj = 0;             LET dTasa = 0;                  LET dSmdf = 0;                  
    LET porcentaje = 0;             LET puntos = 0;                 LET dImp_isr = 0;               LET mInt_al_Inicio = 0;         LET mbase_gravable = 0;         
    LET mbase_exenta = 0;           LET mInt_Proyec = 0;            LET mSdo_Proyec = 0;            LET dImp_Isr_Ini = 0;           LET mSdo_Prom_Ini = 0;          
    LET mSdo_Fin = 0;               LET dImp_Isr_Fin = 0;           LET mSdo_Ini = 0;               LET mSdo_Prom_Fin = 0;	        LET mSdo_Promedio = 0;          
    LET mSdo_31 = 0.00;             LET mInt_31 = 0.00;             LET iNumCiudad = 0;             LET iNumColonia = 0;            LET cNoEstado = ''; 
    LET cNoPais = '';               LET vCodRetSdos = '';           LET dPorRetencionSuj = 0;
        
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/jivan/ipab/sp_repipab_parte8.out';
    --- TRACE ON;
    
    BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, DESC_ERR
        SET DEBUG FILE TO '/resplogifx/conciliachq/jivan/ipab/sp_repipab_parte8.err';
        TRACE ON;
        LET P_COD_RET  = SQL_ERR;
        LET P_COD_RET2 = ISAM_ERR;
        LET P_COD_RET3 = DESC_ERR;
        LET cNumCliente = cNumCliente;
        LET cNumCuenta = cNumCuenta;
        IF nComit = 1 THEN
            ROLLBACK WORK;
        END IF;
        RETURN P_COD_RET,cNom1,cNom2,cNom3;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // VALIDA DATOS DE ENTRADA (DATOS INCOMPLETOS)
    IF (pFechaIni = '') OR (pFechaFin = '') THEN
        RETURN '110','Las fechas ','no pueden ','ser nulas ';
    END IF;

    -- // VALIDA DATOS DE ENTRADA (FECHAS INCORRECTAS)
    IF pFechaFin < pFechaIni THEN
        RETURN '100', 'Fecha Proyeccion ', 'menor a la ', 'fecha de inicio';
    END IF;
    
    -- // CREACION DE TABLAS TEMPORALES
    CREATE TEMP TABLE si_infpertit_tmp 
      (
        cve_unica       CHAR(10),   
        persona         CHAR(1),    
        nombre          CHAR(100),  
        apell_paterno   CHAR(40),   
        apell_materno   CHAR(40),   	
        callenum        CHAR(75),   
        colonia         CHAR(30),   
        delmun          CHAR(30),   
        ciudad          CHAR(30),	
        cod_postal      CHAR(5),  
        tipo_codpos     CHAR(10),
        pais            CHAR(50),   
        estado          CHAR(4),    
        suj_retencion   CHAR(1),    
        Por_retencion   CHAR(4),    
        causal_rev      SMALLINT,		
        rfc             CHAR(13),   
        curp            CHAR(18),   
        telefonos       CHAR(30),	
        correo          CHAR(50) 
      ) WITH NO LOG;
      
    CREATE TEMP TABLE si_infpattit_tmp 
      (
        numcta		    CHAR(20),       
        num_inversion	CHAR(20),       
        tipo_cta		CHAR(2),		
        reg_fiscal		CHAR(1),        
        por_retencion   CHAR(3),        
        causal_rev      SMALLINT,		
        nomprod     	CHAR(50),   	
        cve_sucursal    CHAR(7),        
        sdo_cuenta      MONEY(14,2),	
        moneda          CHAR(2),        
        fecha_corte     DATE,       	
        fecha_contra    DATE,           
        plazo_opera     CHAR(5),        
        tipo_tasa       SMALLINT,       
        tasa        	DECIMAL(9,6),	
        inst_base       CHAR(3),        
        puntos_porc     CHAR(3),        
        operador        CHAR(1),		
        fecha_sigcorte  DATE,       	
        sdo_promdiario  MONEY(14,2),
        dias_ini	    INTEGER,        
        saldo_ini	    MONEY(14,2),    
        prom_ini	    MONEY(14,2),	
        intereses_ini   MONEY(14,2),    
        isr_ini		    MONEY(14,2),
        dias_fin        INTEGER,        
        saldo_fin       MONEY(14,2),	
        prom_fin	    MONEY(14,2),	
        intereses_fin   MONEY(14,2),    
        isr_fin         MONEY(14,2) 
      ) WITH NO LOG;
      
    CREATE TEMP TABLE si_ctaasotit_tmp
      (
        numcta          CHAR(20),    
        num_inversion   CHAR(20),     
        cve_unica       CHAR(10),     
        porcentaje_tit  DECIMAL(6,2)
      ) WITH NO LOG;
    
    -- // FECHA DEL SISTEMA
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM bdinteg:si_fechas
     WHERE empresa = '001';

    -- // VALOR DEL ISR / 100 LISTO PARA CALCULOS
    SELECT valor
      INTO dPorRetencionSuj
      FROM bdinteg:si_fechavalor
     WHERE tasa = 'I.S.R.'
       AND fecha = (SELECT MAX(fecha)
                      FROM bdinteg:si_fechavalor
                     WHERE tasa = 'I.S.R.');

    -- // CALCULO DE MONTO BASE EXENTO ISR
    LET sAnio = year(pFechaFin);
    LET sResiduo = mod(sAnio, 4);

    IF sResiduo = 0 THEN
        LET iAniobase = 366;
    ELSE
        LET iAniobase = 365;
    END IF;

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

    IF mBase_exenta IS NULL THEN
        LET mbase_exenta = 0;
    END IF;
    
    -- // NUMERO DE DIAS DE LA PROYECCION
    LET iDiasProyec = (pFechaFin - pFechaIni);

    -- // TABLA TEMPORAL DE CLIENTES
    SELECT cte.numcte
      FROM bdinteg:si_cliente cte,
           bdicheq:sc_maechq mae,
           bdicheq:sc_maenoc noc
     WHERE cte.numcte = mae.num_cte
       AND ( mae.fecha_proceso >= pFechaIni OR mae.fecha_proceso IS NULL OR mae.status_cta IN('4','5','6','8') )
       AND mae.producto NOT IN('1100','2300','2800','9900','9901')
       AND noc.empresa = mae.empresa
       AND noc.cuenta = mae.cuenta
       AND noc.fecha_alta <= pFechaIni
       AND mae.num_cte >= '018518929'
       AND mae.num_cte < '021145743'
     UNION ALL
    SELECT cte.numcte
      FROM bdinteg:si_cliente cte,
           bdicheq:sc_maechq mae
     WHERE cte.numcte = mae.num_cte
       AND ( mae.fecha_proceso >= pFechaIni OR mae.fecha_proceso IS NULL OR mae.status_cta IN('4','5','6','8') )
       AND mae.producto = '1100'
       AND mae.fecultdep <= pFechaIni
       AND mae.num_cte >= '018518929'
       AND mae.num_cte < '021145743'
      INTO TEMP tmp_clientes WITH NO LOG;
    CREATE INDEX idxtmp_ctes ON tmp_clientes(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_clientes;
    
    SELECT UNIQUE numcte
      FROM tmp_clientes
      INTO TEMP tmp_clientes_ipab WITH NO LOG;
    CREATE INDEX idxtmp_ctesipab ON tmp_clientes_ipab(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_clientes_ipab;
    
    -- // TABLA TEMPORAL DE CUENTAS
    SELECT tmp.numcte AS num_cte, mae.cuenta AS cuenta, mae.producto AS producto, mae.sucursal AS sucursal, 
           NVL(noc.fecha_alta,'') fecha_alta, prod.nombre nombre_prod, SUBSTRING(nvl(prod.divisa, ' ') FROM 2 FOR 1) moneda, NVL(tasa, '') tasa, paga_dividendo
      FROM tmp_clientes_ipab tmp,
           bdicheq:sc_maechq mae,
           bdicheq:sc_maenoc noc,
           bdicheq:sc_producto prod
     WHERE tmp.numcte = mae.num_cte
       AND mae.producto NOT IN('1100','2300','2800','9900','9901')
       AND ( mae.fecha_proceso >= pFechaIni OR mae.fecha_proceso IS NULL OR mae.status_cta IN('4','5','6','8') )
       AND noc.empresa = mae.empresa
       AND noc.cuenta = mae.cuenta
       AND noc.fecha_alta <= pFechaIni
       AND prod.empresa = mae.empresa
       AND prod.producto = mae.producto
     UNION ALL
    SELECT tmp.numcte AS num_cte, mae.cuenta AS cuenta, mae.producto AS producto, mae.sucursal AS sucursal, 
           NVL(mae.fecultdep,'') fecha_alta, prod.nombre nombre_prod, SUBSTRING(nvl(prod.divisa, ' ') FROM 2 FOR 1) moneda, NVL(tasa, '') tasa, paga_dividendo
      FROM tmp_clientes_ipab tmp,
           bdicheq:sc_maechq mae,
           bdicheq:sc_producto prod
     WHERE tmp.numcte <> ''
       AND mae.num_cte = tmp.numcte
       AND mae.producto = '1100'
       AND ( mae.fecha_proceso >= pFechaIni OR mae.fecha_proceso IS NULL OR mae.status_cta IN('4','5','6') )
       AND mae.fecultdep <= pFechaIni
       AND prod.empresa = mae.empresa
       AND prod.producto = mae.producto
      INTO TEMP tmp_cuentas_ipab WITH NO LOG;
    CREATE INDEX idx_ctas ON tmp_cuentas_ipab(num_cte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_cuentas_ipab;
    
    SELECT MIN(numcte), MAX(numcte)
      INTO vctemin, vctemax
      FROM tmp_clientes_ipab; 

    -- // FOREACH CLIENTES
    FOREACH WITH HOLD
        SELECT UNIQUE numcte
          INTO cNumCliente
          FROM tmp_clientes_ipab
         WHERE numcte BETWEEN vctemin AND vctemax

        BEGIN WORK;
        LET nComit = 1;
        
        -- // OBTIENE DATOS PERSONALES DEL CLIENTE
        SELECT TRIM(cte.rfc) AS rfc,                                                          
               TRIM(cte.tpo_persona) AS personalidad,                                         
               TRIM(cte.nombre1)||' '||TRIM(cte.nombre2) || Trim(cte.razon_social) AS nombre, 
               TRIM(cte.apell_paterno) AS apellpaterno,                                       
               TRIM(cte.apell_materno) AS apellmaterno,                                       
               TRIM(ctepf.curp) AS curp                                                                       
          INTO cRfc, cPersona, cNombre1, cApellido1, cApellido2, cCurp
          FROM bdinteg:si_cliente cte
          LEFT OUTER JOIN bdinteg:si_ctepf ctepf ON (ctepf.numcte = cte.numcte)
         WHERE cte.numcte = cNumCliente;
         
        SELECT LIMIT 1 correo_elec AS correo_electronico
          INTO cCorreo  
          FROM bdinteg:si_correos
         WHERE numcte = cNumCliente
           AND tipo_correo = 1
           AND status_correo = 'A';
         
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
          INTO iNumeroCalle, cNumExtCalle, cCodPostal, cTelefonoCasa, cTelefonoCasa2, cTelefonoCasa3, iNumCiudad, iNumColonia, cNoEstado, cNoPais
          FROM bdinteg:si_direcciones_actual dir 
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel3 ON (tel3.numcte = dir.numcte AND tel3.tipo_tel = 3)
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
          INTO cColonia, cDelegacionMunicipio, cCodPostal2
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
           ( cDelegacionMunicipio is null OR cDelegacionMunicipio = '' ) OR 
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
              INTO iNumeroCalle, cNumExtCalle, cCodPostal, cTelefonoCasa, cTelefonoCasa4, cTelefonoCasa5, iNumCiudad, iNumColonia, cNoEstado, cNoPais
              FROM bdinteg:si_direcciones_actual dir 
              LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
              LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
              LEFT OUTER JOIN bdinteg:si_telefonos_actual tel3 ON (tel3.numcte = dir.numcte AND tel3.tipo_tel = 3)
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
              INTO cColonia, cDelegacionMunicipio, cCodPostal2
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
               ( cDelegacionMunicipio is null OR cDelegacionMunicipio = '' ) OR 
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
                  INTO iNumeroCalle, cNumExtCalle, cCodPostal, cTelefonoCasa, cTelefonoCasa6, cTelefonoCasa7, iNumCiudad, iNumColonia, cNoEstado, cNoPais
                  FROM bdinteg:si_direcciones_actual dir 
                  LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
                  LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
                  LEFT OUTER JOIN bdinteg:si_telefonos_actual tel3 ON (tel3.numcte = dir.numcte AND tel3.tipo_tel = 3)
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
                  INTO cColonia, cDelegacionMunicipio, cCodPostal2
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
                   ( cDelegacionMunicipio is null OR cDelegacionMunicipio = '' ) OR 
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
                      INTO iNumeroCalle, cNumExtCalle, cCodPostal, cTelefonoCasa, cTelefonoCasa2, cTelefonoCasa3, iNumCiudad, iNumColonia, cNoEstado, cNoPais
                      FROM bdinteg:si_direcciones_actual dir 
                      LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
                      LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
                      LEFT OUTER JOIN bdinteg:si_telefonos_actual tel3 ON (tel3.numcte = dir.numcte AND tel3.tipo_tel = 3)
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
                      INTO cColonia, cDelegacionMunicipio, cCodPostal2
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
        END IF;
        
        IF cDelegacionMunicipio is null OR cDelegacionMunicipio = '' THEN
            LET cDelegacionMunicipio = cColonia;
        END IF;
                    
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
                  FROM tmp_cuentas_ipab
                 WHERE num_cte = cNumCliente;
                 
                SELECT d_codigo
                  INTO cCodPostal
                  FROM bdinteg:si_sucursales
                 WHERE sucursal = vSucCta;
                 
                LET cTipoCodPos = 'SUCURSAL';
            END IF;
        END IF;
        
        -- // VALIDA SI SE OBTUVO EL TELEFONO DEL CLIENTE
        IF cTelefonoCasa is null OR cTelefonoCasa = '' THEN
            LET cTelefonoCasa = cTelefonoCasa2;
            IF cTelefonoCasa is null OR cTelefonoCasa = '' THEN
                LET cTelefonoCasa = cTelefonoCasa3;
                IF cTelefonoCasa is null OR cTelefonoCasa = '' THEN
                    LET cTelefonoCasa = cTelefonoCasa4;
                    IF cTelefonoCasa is null OR cTelefonoCasa = '' THEN
                        LET cTelefonoCasa = cTelefonoCasa5;
                        IF cTelefonoCasa is null OR cTelefonoCasa = '' THEN
                            LET cTelefonoCasa = cTelefonoCasa6;
                            IF cTelefonoCasa is null OR cTelefonoCasa = '' THEN
                                LET cTelefonoCasa = cTelefonoCasa7;
                                IF cTelefonoCasa = '' OR cTelefonoCasa is null THEN
                                    LET cTelefonoCasa = NULL;
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
          FROM bdinteg:si_tipper
         WHERE tpo_persona = cPersona;

        IF cPfisica = 'S' THEN
            LET cTipoPersona = 'F';
        ELSE
            LET cTipoPersona = 'M';
            LET cApellido1 = NULL;
            LET cApellido2 = NULL;
        END IF;
        
        IF cTipoPersona IS NULL THEN
            LET nComit = 0;
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
          INTO vexcluido
          FROM bdinteg:si_excluidosipab
         WHERE numcte = cNumCliente;

        IF vexcluido = 0 THEN
            LET sCauRev = 0;
        ELSE
            LET sCauRev = 1;
        END IF;
        
        -- // FOREACH CUENTAS POR CLIENTE
        FOREACH
            SELECT cuenta, producto, sucursal, fecha_alta, nombre_prod, moneda, tasa, paga_dividendo
              INTO cNumCuenta, cNumProducto, cSucursal, dFecAlta, cproducto, cMoneda, ctasa, vtasavar
              FROM tmp_cuentas_ipab
             WHERE num_cte = cNumCliente

            IF dFecAlta < pFechaIni THEN
                SELECT COUNT(*)
                  INTO vaniomes
                  FROM bdicheq:sc_maehis
                 WHERE empresa = '001'
                   AND cuenta = cNumCuenta
                   AND fechafin <= pFechaIni;

                IF vaniomes = 0 THEN
                    -- // SALDO SIN INTERESES A LA FECHA INICIAL DE LA PROYECCION
                    EXECUTE PROCEDURE bdicheq:sp_capintafecha(cNumCuenta, pFechaIni) 
                    INTO vCodRetSdos, mSdo_Ini, mInt_al_Inicio;
                    
                    LET iDias_Ini = (pFechaIni - dFecAlta);

                    -- // TIPO DE TASA DEL PRODUCTO
                    SELECT rangofecha
                      INTO vrangofecha
                      FROM bdinteg:si_tiptasa
                     WHERE empresa = '001'
                       AND tasa = ctasa;

                    -- // VALOR DE LA TASA
                    IF vtasavar = 'N' THEN
                        IF vrangofecha = 'F' THEN
                            SELECT NVL(valor,0)
                              INTO dTasa
                              FROM bdinteg:si_fechavalor
                             WHERE empresa = '001'
                               AND tasa = ctasa
                               AND fecha = ( SELECT max(fecha)
                                               FROM bdinteg:si_fechavalor
                                              WHERE empresa = '001'
                                                AND tasa = ctasa
                                                AND fecha <= pFechaIni );
                        ELIF vrangofecha = 'R' THEN
                            IF cTipoPersona = 'F' THEN
                                SELECT valorperfis, sobretasafis
                                  INTO porcentaje, puntos
                                  FROM bdinteg:si_tasavlor
                                 WHERE empresa = '001'
                                   AND tasa = ctasa
                                   AND rangomin <= mSdo_Ini
                                   AND rangomax >= mSdo_Ini;
                            ELSE
                                SELECT valorpermor, sobretasamor
                                  INTO porcentaje, puntos
                                  FROM bdinteg:si_tasavlor
                                 WHERE empresa = '001'
                                   AND tasa = ctasa
                                   AND rangomin <= mSdo_Ini
                                   AND rangomax >= mSdo_Ini;
                            END IF;
                            LET dTasa = porcentaje + puntos;
                        END IF;
                    ELSE
                        SELECT NVL(valor_tasa,0)
                          INTO dTasa
                          FROM bdinteg:si_tasa_mes
                         WHERE tasa = ctasa
                           AND mes = 1
                           AND tipo_tasa = 'M'
                           AND fecha = ( SELECT MAX(fecha)
                                           FROM bdinteg:si_tasa_mes
                                          WHERE tasa = ctasa
                                            AND mes = 1
                                            AND tipo_tasa = 'M'
                                            AND fecha <= pFechaIni );
                    END IF;
                    
                    IF mSdo_Ini >= 0 THEN
                        -- // CALCULA EL SALDO CON INTERESES A LA FECHA INICIAL DE LA PROYECCION
                        LET mSdo_Prom_Ini = mSdo_Ini;
                        LET mSdo_Fin = mSdo_Ini + mInt_al_Inicio;
                        LET dImp_Isr_Ini = 0.00;
                        LET mSdo_Fin = mSdo_Fin - dImp_Isr_Ini;
                        
                        -- // CALCULA EL SALDO CON INTERESES A LA FECHA FINAL DE PROYECCION
                        LET mSdo_Prom_Fin = mSdo_Fin;
                        LET mInt_Proyec = (mSdo_Prom_Fin * (dTasa/100) * iDiasProyec) / 360;
                        LET mSdo_Proyec = mSdo_Fin + mInt_Proyec;
                        LET mBase_gravable = mSdo_Prom_Fin - mbase_exenta;

                        IF dPorRetSuj <> 0 THEN
                            IF cTipoPersona = 'F' THEN
                                IF mBase_gravable > 0 THEN
                                    LET dImp_Isr_Fin = (mBase_gravable * (dPorRetSuj/100)) * iDiasProyec / iAniobase;
                                ELSE
                                    LET dImp_Isr_Fin = 0;
                                END IF;
                            ELSE
                                LET dImp_Isr_Fin = (mSdo_Prom_Fin * (dPorRetSuj/100)) * iDiasProyec / iAniobase;
                            END IF;
                        ELSE
                            LET dImp_Isr_Fin = 0;
                        END IF;

                        LET mSdo_Promedio = mSdo_Prom_Fin;
                        LET mSdo_Proyec = mSdo_Proyec - dImp_Isr_Fin;
                    ELSE
                        LET mSdo_Prom_Ini = mSdo_Ini;
                        LET mInt_al_Inicio = 0.00;
                        LET dImp_Isr_Ini = 0.00;
                        LET mSdo_Fin = mSdo_Ini + mInt_al_Inicio;
                        LET mSdo_Prom_Fin = mSdo_Fin;
                        LET mInt_Proyec = 0.00;
                        LET dImp_Isr_Fin = 0.00;
                        LET mSdo_Promedio = mSdo_Prom_Fin;
                        LET mSdo_Proyec = ( mSdo_Fin + mInt_Proyec ) - dImp_Isr_Fin;
                    END IF;

                    -- // OBTIENE LA PROXIMA FECHA DE CORTE
                    LET vFecAlta = dFecAlta - 1;
                    
                    EXECUTE PROCEDURE bdinteg:sp_cortesig(vFecAlta, 1) 
                    INTO cVar1,dFechaSigcorte;
                    
                    LET dFechaCorte = dFechaSigcorte;
                ELSE
                    -- // OBTIENE INFORMACON DEL ULTIMO MAEHIS
                    SELECT NVL(his.tasabruta, 0), his.fechafin
                      INTO dTasa, dFechaCorte
                      FROM bdicheq:sc_maehis his
                     WHERE his.empresa = '001'
                       AND his.cuenta = cNumCuenta
                       AND his.aniomes = (SELECT MAX(aniomes)
                                            FROM bdicheq:sc_maehis
                                           WHERE empresa = '001'
                                             AND cuenta = cNumCuenta
                                             AND fechafin <= pFechaIni);
                                             
                    LET dTasa = dTasa * 100;
                    
                    LET iDias_Ini = (pFechaIni - dFechaCorte);

                    IF iDias_Ini > 0 THEN
                        -- // OBTIENE EL SALDO SIN INTERESES A LA FECHA INICIAL DE LA PROYECCION
                        EXECUTE PROCEDURE bdicheq:sp_capintafecha(cNumCuenta, pFechaIni) 
                        INTO vCodRetSdos, mSdo_Ini, mInt_al_Inicio;
                        
                        IF mSdo_Ini >= 0 THEN
                            -- // OBTIENE EL SALDO PROMEDIO DE LA FECHA DE CORTE A LA FECHA INICIAL DE LA PROYECCION
                            LET vFechaCorte = dFechaCorte + 1;
                            LET mSdo_Prom_Ini = mSdo_Ini;

                            -- // CALCULA EL SALDO CON INTERESES A AL FECHA INICIAL DE LA PROYECCION
                            LET mSdo_Fin = mSdo_Ini + mInt_al_Inicio;
                            LET dImp_Isr_Ini = 0.00;
                            LET mSdo_Fin = mSdo_Fin - dImp_Isr_Ini;
                            
                            -- // CALCULA EL SALDO CON INTERESES A LA FECHA FINAL DE LA PROYECCION
                            LET mSdo_Prom_Fin = mSdo_Fin;
                            LET mInt_Proyec = (mSdo_Prom_Fin * (dTasa/100) * iDiasProyec) / 360;
                            LET mSdo_Proyec = mSdo_Fin + mInt_Proyec;
                            LET mBase_gravable = mSdo_Prom_Fin - mbase_exenta;

                            IF dPorRetSuj <> 0 THEN
                                IF cTipoPersona = 'F' THEN
                                    IF mBase_gravable > 0 THEN
                                        LET dImp_Isr_Fin = (mBase_gravable * (dPorRetSuj/100)) * iDiasProyec / iAniobase;
                                    ELSE
                                        LET dImp_Isr_Fin = 0;
                                    END IF;
                                ELSE
                                    LET dImp_Isr_Fin = (mSdo_Prom_Fin * (dPorRetSuj/100)) * iDiasProyec / iAniobase;
                                END IF;
                            ELSE
                                LET dImp_Isr_Fin = 0;
                            END IF;

                            LET mSdo_Promedio = mSdo_Prom_Fin;
                            LET mSdo_Proyec = mSdo_Proyec - dImp_Isr_Fin;
                        ELSE
                            LET mSdo_Prom_Ini = mSdo_Ini;
                            LET mInt_al_Inicio = 0.00;
                            LET dImp_Isr_Ini = 0.00;
                            LET mSdo_Fin = mSdo_Ini + mInt_al_Inicio;
                            LET mSdo_Prom_Fin = mSdo_Fin;
                            LET mInt_Proyec = 0.00;
                            LET dImp_Isr_Fin = 0.00;
                            LET mSdo_Promedio = mSdo_Prom_Fin;
                            LET mSdo_Proyec = ( mSdo_Fin + mInt_Proyec ) - dImp_Isr_Fin;
                        END IF;
                    ELIF iDias_Ini = 0 THEN
                        -- // OBTIENE EL SALDO DE LA CUENTA
                        EXECUTE PROCEDURE bdicheq:sp_capintafecha(cNumCuenta, pFechaIni) 
                        INTO vCodRetSdos, mSdo_Ini, mInt_al_Inicio;
                        
                        IF mSdo_Ini >= 0 THEN
                            LET mSdo_Prom_Ini = 0.00;
                            LET mSdo_Fin = mSdo_Ini + mInt_al_Inicio;
                            LET dImp_Isr_Ini = 0.00;
                            LET mSdo_Fin = mSdo_Fin - dImp_Isr_Ini;

                            -- // CALCULA EL SALDO CON INTERESES A LA FECHA FINAL DE LA PROYECCION
                            LET mSdo_Prom_Fin = mSdo_Fin;
                            LET mInt_Proyec = (mSdo_Prom_Fin * (dTasa/100) * iDiasProyec) / 360;
                            LET mSdo_Proyec = mSdo_Fin + mInt_Proyec;
                            LET mBase_gravable = mSdo_Prom_Fin - mbase_exenta;

                            IF dPorRetSuj <> 0 THEN
                                IF cTipoPersona = 'F' THEN
                                    IF mBase_gravable > 0 THEN
                                        LET dImp_Isr_Fin = (mBase_gravable * (dPorRetSuj/100)) * iDiasProyec / iAniobase;
                                    ELSE
                                        LET dImp_Isr_Fin = 0;
                                    END IF;
                                ELSE
                                    LET dImp_Isr_Fin = (mSdo_Prom_Fin * (dPorRetSuj/100)) * iDiasProyec / iAniobase;
                                END IF;
                            ELSE
                                LET dImp_Isr_Fin = 0;
                            END IF;

                            LET mSdo_Promedio = mSdo_Prom_Fin;
                            LET mSdo_Proyec = mSdo_Proyec - dImp_Isr_Fin;
                        ELSE
                            LET mSdo_Prom_Ini = mSdo_Ini;
                            LET mInt_al_Inicio = 0.00;
                            LET dImp_Isr_Ini = 0.00;
                            LET mSdo_Fin = mSdo_Ini + mInt_al_Inicio;
                            LET mSdo_Prom_Fin = mSdo_Fin;
                            LET mInt_Proyec = 0.00;
                            LET dImp_Isr_Fin = 0.00;
                            LET mSdo_Promedio = mSdo_Prom_Fin;
                            LET mSdo_Proyec = ( mSdo_Fin + mInt_Proyec ) - dImp_Isr_Fin;
                        END IF;
                    END IF;

                    -- // OBTIENE LA PROXIMA FECHA DE CORTE
                    EXECUTE PROCEDURE bdinteg:sp_CorteSig(dFechaCorte, 1) 
                    INTO cVar1, dFechaSigcorte;
                END IF;
            ELIF dFecAlta = pFechaIni THEN
                -- // OBTIENE EL SALDO DE LA CUENTA
                EXECUTE PROCEDURE bdicheq:sp_capintafecha(cNumCuenta, pFechaIni) 
                INTO vCodRetSdos, mSdo_Ini, mInt_al_Inicio;
                
                LET iDias_Ini = 0;
                
                -- // OBTIENE EL TIPO DE TASA DEL PRODUCTO
                SELECT rangofecha
                  INTO vrangofecha
                  FROM bdinteg:si_tiptasa
                 WHERE empresa = '001'
                   AND tasa = ctasa;

                -- // OBTIENE EL VALOR DE LA TASA
                IF vtasavar = 'N' THEN
                    IF vrangofecha = 'F' THEN
                        SELECT NVL(valor,0)
                          INTO dTasa
                          FROM bdinteg:si_fechavalor
                         WHERE empresa = '001'
                           AND tasa = ctasa
                           AND fecha = ( SELECT max(fecha)
                                           FROM bdinteg:si_fechavalor
                                          WHERE empresa = '001'
                                            AND tasa = ctasa
                                            AND fecha <= pFechaIni );
                    ELIF vrangofecha = 'R' THEN
                        IF cTipoPersona = 'F' THEN
                            SELECT valorperfis, sobretasafis
                              INTO porcentaje, puntos
                              FROM bdinteg:si_tasavlor
                             WHERE empresa = '001'
                               AND tasa = ctasa
                               AND rangomin <= mSdo_Ini
                               AND rangomax >= mSdo_Ini;
                        ELSE
                            SELECT valorpermor, sobretasamor
                              INTO porcentaje, puntos
                              FROM bdinteg:si_tasavlor
                             WHERE empresa = '001'
                               AND tasa = ctasa
                               AND rangomin <= mSdo_Ini
                               AND rangomax >= mSdo_Ini;
                        END IF;
                        LET dTasa = porcentaje + puntos;
                    END IF;
                ELSE
                    SELECT NVL(valor_tasa,0)
                      INTO dTasa
                      FROM bdinteg:si_tasa_mes
                     WHERE tasa = ctasa
                       AND mes = 1
                       AND tipo_tasa = 'M'
                       AND fecha = ( SELECT MAX(fecha)
                                       FROM bdinteg:si_tasa_mes
                                      WHERE tasa = ctasa
                                        AND mes = 1
                                        AND tipo_tasa = 'M'
                                        AND fecha <= pFechaIni );
                END IF;
                
                IF mSdo_Ini >= 0 THEN
                    -- // CALCULA EL SALDO CON INTERESES A LA FECHA INICIAL DE LA PROYECCION
                    LET mSdo_Prom_Ini = 0.00;
                    LET dImp_isr_ini = 0.00;
                    LET mSdo_Fin = mSdo_Ini;
                    LET mSdo_Prom_Fin = mSdo_Fin;

                    -- // CALCULA EL SALDO CON INTERESES A LA FECHA FINAL DE LA PROYECCION
                    LET mInt_Proyec = (mSdo_Prom_Fin * (dTasa/100) * iDiasProyec) / 360;
                    LET mSdo_Proyec = mSdo_Fin + mInt_Proyec;
                    LET mBase_gravable = mSdo_Prom_Fin - mbase_exenta;

                    IF dPorRetSuj <> 0 THEN
                        IF cTipoPersona = 'F' THEN
                            IF mBase_gravable > 0 THEN
                                LET dImp_Isr_Fin = (mBase_gravable * (dPorRetSuj/100)) * iDiasProyec / iAniobase;
                            ELSE
                                LET dImp_Isr_Fin = 0;
                            END IF;
                        ELSE
                            LET dImp_Isr_Fin = (mSdo_Prom_Fin * (dPorRetSuj/100)) * iDiasProyec / iAniobase;
                        END IF;
                    ELSE
                        LET dImp_Isr_Fin = 0;
                    END IF;

                    LET mSdo_Promedio = mSdo_Prom_Fin;
                    LET mSdo_Proyec = mSdo_Proyec - dImp_Isr_Fin;
                ELSE
                    LET mSdo_Prom_Ini = mSdo_Ini;
                    LET mInt_al_Inicio = 0.00;
                    LET dImp_Isr_Ini = 0.00;
                    LET mSdo_Fin = mSdo_Ini + mInt_al_Inicio;
                    LET mSdo_Prom_Fin = mSdo_Fin;
                    LET mInt_Proyec = 0.00;
                    LET dImp_Isr_Fin = 0.00;
                    LET mSdo_Promedio = mSdo_Prom_Fin;
                    LET mSdo_Proyec = ( mSdo_Fin + mInt_Proyec ) - dImp_Isr_Fin;
                END IF;

                -- // OBTIENE LA PROXIMA FECHA DE CORTE
                LET vFecAlta = dFecAlta - 1;
                
                EXECUTE PROCEDURE bdinteg:sp_CorteSig(vFecAlta, 1) 
                INTO cVar1, dFechaSigcorte;
                
                LET dFechaCorte = dFechaSigcorte;
            END IF;
            
            IF pFechaFin = pFechaIni THEN
                LET mSdo_Fin = 0.00;
                LET mSdo_Prom_Fin = 0.00;
                LET mInt_Proyec = 0.00;
                LET dImp_Isr_Fin = 0.00;
                LET mSdo_Proyec = mSdo_Ini + mInt_al_Inicio;
            END IF;
            
            -- // INSERTA INFORMACION PATRIMONIAL DEL CLIENTE
            INSERT INTO si_infpattit_tmp VALUES
            ( UPPER(cNumCuenta), iCtaInversion, UPPER(cTpoCuenta), 'N', cPorcentaje, '0', UPPER(cproducto), UPPER(cSucursal), NVL(mSdo_Proyec,0),
              UPPER(cMoneda), dFechaCorte, cFecAlt, cPlazo, sTipoTasa, NVL(dTasa,0), cInstbase, cSobretasa, cOperArit, dFechaSigcorte, NVL(mSdo_Promedio,0),
              iDias_Ini, mSdo_Ini, mSdo_Prom_Ini, mInt_al_Inicio, dImp_Isr_Ini, iDiasProyec, mSdo_Fin, mSdo_Prom_Fin, mInt_Proyec, dImp_Isr_Fin );

            -- // INSERTA CUENTAS ASOCIADAS DEL CLIENTE
            INSERT INTO si_ctaasotit_tmp VALUES 
            ( UPPER(cNumCuenta), iCtaInversion, UPPER(cNumCliente), '100.00' );
        END FOREACH;

        -- // VERIFICA SI EL CLIENTE TIENE PAGARES PARA REPORTARLOS
        EXECUTE PROCEDURE bdinteg:sp_repipabinver(pFechaIni, pFechaFin, cNumCliente, cPersona) 
        INTO P_COD_RET;

        IF P_COD_RET <> '00000' THEN
            RETURN P_COD_RET,cNom1,cNom2,cNom3;
        END IF;

        -- // INSERTA INFORMACION PERSONAL DEL CLIENTE
        SELECT COUNT(*)
          INTO vcve_unica
          FROM si_ctaasotit_tmp
         WHERE cve_unica = cNumCliente;
         
        IF dPorRetSuj = 0 THEN
            LET dPorRetSuj = NULL;
        END IF;

        IF vcve_unica > 0 THEN
            INSERT INTO si_infpertit_tmp VALUES
            ( cNumCliente, cTipoPersona, Trim(cNombre1), cApellido1, cApellido2, cNombreCalle, cColonia, cDelegacionMunicipio,
              cNomCiudadCte, cCodPostal, cTipoCodPos, cPais, cEstado, cSujRet, dPorRetSuj, sCauRev, cRfc, cCurp, cTelefonoCasa, cCorreo );
        END IF;
        
        LET nComit = 0;
        COMMIT WORK;
    END FOREACH;
    
    /*
    -- // DESCARGA DE ARCHIVOS
    LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/jivan/ipab/infpertit_8.txt '||
               'SELECT * FROM si_infpertit_tmp;" > /resplogifx/conciliachq/jivan/ipab/desc_ipab_81.sql';
    SYSTEM vsql;
    
    LET vstmt = 'dbaccess bdinteg /resplogifx/conciliachq/jivan/ipab/desc_ipab_81.sql';
    SYSTEM vstmt;
    
    LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/jivan/ipab/infpattit_8.txt '||
               'SELECT * FROM si_infpattit_tmp;" > /resplogifx/conciliachq/jivan/ipab/desc_ipab_82.sql';
    SYSTEM vsql;
    
    LET vstmt = 'dbaccess bdinteg /resplogifx/conciliachq/jivan/ipab/desc_ipab_82.sql';
    SYSTEM vstmt;
    
    LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/jivan/ipab/ctaasotit_8.txt '||
               'SELECT * FROM si_ctaasotit_tmp;" > /resplogifx/conciliachq/jivan/ipab/desc_ipab_83.sql';
    SYSTEM vsql;
    
    LET vstmt = 'dbaccess bdinteg /resplogifx/conciliachq/jivan/ipab/desc_ipab_83.sql';
    SYSTEM vstmt;
    */
     
    RETURN P_COD_RET, 'PROCESO', 'REALIZADO', 'CORRECTAMENTE';
    
    END;
    
END PROCEDURE;