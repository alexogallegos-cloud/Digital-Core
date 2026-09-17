CREATE PROCEDURE "informix".sp_ipab_parte6( pFechaIni DATE, pFechaFin DATE ) 
RETURNING CHAR(5), CHAR(5), CHAR(50);
    
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
    DEFINE cNumCliente, cPais, cCteMin, cCteMax CHAR(20);
    DEFINE cMunicipio, cEstado CHAR(25);
    DEFINE cNombre, cApellido1, cApellido2 CHAR(26);
    DEFINE cNombreCalle, cColonia, cNomCiudadCte CHAR(30);
    DEFINE cArchivo1, cArchivo2, cArchivo3, cArchivo4, cArchivo5, cArchivo6 CHAR(40);
    DEFINE cCodRet3, cDesErr, cCorreo CHAR(60);
    DEFINE cStmt CHAR(200);
    DEFINE cSql CHAR(600);
    DEFINE dFechaNac DATE;
    DEFINE iCauRev, iCveUnica, iCveUnicaCrd, iExcluido, iExisteCodPos, iComit, iClasificaTitular, iCheques, iCreditos, iAnio, dNumsmdf, iNumCiudad, iCtasBloqueadas SMALLINT;
    DEFINE iComp2, iComp3, iComp4, iComp5, iComp6, iComp7, iComp8, iComp9, iComp10, iComp11, iComp12, iComp13, iComp14, iComp15, iComp16, iComp17, iComp18, iComp19, iComp20 SMALLINT;
    DEFINE iSqlErr, iSamErr, iCodPostal, iFechaNacimiento, iAniobase, iNumeroCalle, iNumColonia, iContador1, iContador2, iContador3 INTEGER;
    DEFINE dResiduo DECIMAL(6,2); 
    DEFINE dPorRetencionSuj, dPorRetSuj, dSmdf, mValorUDI DECIMAL(9,6);
    DEFINE dSdoCheques, dSdoCredito, mValorUDIS DECIMAL(14,2);
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
    LET cNumCliente =  ''; LET cPais = ''; LET cCteMin = ''; LET cCteMax = '';
    LET cMunicipio = ''; LET cEstado =  '';
    LET cNombre =  ''; LET cApellido1 =  ''; LET cApellido2 =  '';
    LET cNombreCalle =  ''; LET cColonia =  ''; LET cNomCiudadCte = '';
    LET cArchivo1 = ''; LET cArchivo2 = ''; LET cArchivo3 = ''; LET cArchivo4 = ''; LET cArchivo5 = ''; LET cArchivo6 = '';
    LET cCodRet3 = 'PROCESO FINALIZADO CORRECTAMENTE'; LET cDesErr = ''; LET cCorreo = '';
    LET cStmt = '';
    LET cSql = '';
    LET dFechaNac = '';
    LET iCauRev = ''; LET iCveUnica = 0; LET iCveUnicaCrd = 0; LET iExcluido = 0; LET iExisteCodPos = ''; LET iComit = 0; LET iClasificaTitular = 0; LET iCheques = 0; LET iCreditos = 0; LET iAnio = 0; LET dNumsmdf = 0; LET iNumCiudad = 0; LET iCtasBloqueadas = 0;
    LET iComp2 = 0; LET iComp3 = 0; LET iComp4 = 0; LET iComp5 = 0; LET iComp6 = 0; LET iComp7 = 0; LET iComp8 = 0; LET iComp9 = 0; LET iComp10 = 0;
    LET iSqlErr = 0; LET iSamErr = 0; LET iCodPostal = 0; LET iFechaNacimiento = 0; LET iAniobase = 0; LET iNumeroCalle = 0; LET iNumColonia = 0; LET iContador1 = 0; LET iContador2 = 0; LET iContador3 = 0;
    LET dResiduo = 0; 
    LET dPorRetencionSuj = 0.00; LET dPorRetSuj = 0.00; LET dSmdf = 0; LET mValorUDI = 0;
    LET dSdoCheques = 0.00; LET dSdoCredito = 0.00; LET mValorUDIS = 0.00;
    LET dSaldoCompensado = 0.00;
    LET mbase_exenta = 0; 
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_ipab_parte6.err';
        TRACE ON;
        LET cCodRet  = iSqlErr;
        LET cCodRet2 = iSamErr;
        LET cCodRet3 = cDesErr;
        LET cNumCliente = cNumCliente;
        IF iComit = 1 THEN
            ROLLBACK WORK;
        END IF;
        RETURN cCodRet, cCodRet2, cCodRet3;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_ipab_parte6.out';
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA 
    IF ( ( pFechaIni is null OR pFechaIni = '' ) OR ( pFechaFin is null OR pFechaFin = '' ) ) THEN
        LET cCodRet   = '110';
        LET cCodRet2  = '110';
        LET cCodRet3  = 'LAS FECHAS NO PUEDEN SER NULAS';
        RETURN cCodRet, cCodRet2, cCodRet3;
    ELIF pFechaFin < pFechaIni THEN
        LET cCodRet   = '110';
        LET cCodRet2  = '110';
        LET cCodRet3  = 'FECHA DE PROYECCION MENOR A LA FECHA DE INICIO';
        RETURN cCodRet, cCodRet2, cCodRet3;
    END IF;
    
    -- // CREA TABLA INFORMACIÓN PERSONAL DE LOS TITULARES
    create temp table si_infpertit_temp (
        cve_unica       char(18),
        persona         char(1),
        nombre          char(150),
        apell_paterno   char(60),
        apell_materno   char(60),
        callenum        char(90),
        colonia         char(80),
        delmun          char(60),
        ciudad          char(60),
        cod_postal      char(5),
        pais            char(50),
        estado          char(4),
        suj_retencion   char(1),
        por_retencion   decimal(6,2),
        causal_rev      smallint,
        rfc             char(13),
        curp            char(18),
        telefonos       char(30),
        correo          char(50),
        fecha_nac       char(8),
        sdo_compensado  money(15,2),
        clasif_tit      smallint,
        tipo_codpos     char(10)
    ) with no log;
    create index idxtmp_infpertitcomp_cve on si_infpertit_temp(cve_unica) using btree;
    UPDATE STATISTICS MEDIUM FOR TABLE si_infpertit_temp;
    
    -- // CREA TABLA INFORMACIÓN PATRIMONIAL DE LOS TITULARES
    create temp table si_infpattit_temp (
        numcta          char(35),
        num_inversion   char(25),
        cve_producto    char(20),
        tipo_cta        char(2),
        reg_fiscal      char(1),
        por_retencion   decimal(5,2),
        cve_sucursal    integer,
        sdo_cuenta      decimal(15,2),
        intereses       decimal(15,2),
        ret_impuestos   decimal(15,2),
        otros_accesorio decimal(15,2),
        sdo_neto        decimal(15,2),
        moneda          smallint,
        fecha_corte     char(8),
        fecha_contrata  char(8),
        plazo_opera     integer,
        tipo_tasa       smallint,
        tasa            decimal(6,3),
        inst_base       char(20),
        puntos_porc     decimal(6,3),
        operador        char(1),
        fecha_sig_corte char(8),
        sdo_prom_diario money(15,2),
        dias_ini        integer,
        saldo_ini       money(14,2),
        prom_ini        money(14,2),
        intereses_ini   money(14,2),
        isr_ini         money(14,2),
        dias_fin        integer,
        saldo_fin       money(14,2),
        prom_fin        money(14,2),
        intereses_fin   money(14,2),
        isr_fin         money(14,2),
        status_cta      char(1),
        motivo_bloq     char(2)
    ) with no log; 
    create index idxtmp_infpattitcomp_cta on si_infpattit_temp(numcta,num_inversion) using btree;
    --create index idxtmp_infpattitcomp_inv on si_infpattit_temp(num_inversion) using btree;
    UPDATE STATISTICS MEDIUM FOR TABLE si_infpattit_temp;
    
    -- // CREA TABLA CUENTAS ASOCIADAS DE LOS TITULARES
    create temp table si_ctaasotit_temp (
        numcta          char(35),
        num_inversion   char(25),
        cve_unica       char(18),
        porcentaje_tit  decimal(5,2) 
    ) with no log; 
    create index idxtmp_ctaasotitcomp_cta on si_ctaasotit_temp(numcta,num_inversion) using btree;
    --create index idxtmp_ctaasotitcomp_inv on si_ctaasotit_temp(num_inversion) using btree;
    create index idxtmp_ctaasotitcomp_cve on si_ctaasotit_temp(cve_unica) using btree;
    UPDATE STATISTICS MEDIUM FOR TABLE si_ctaasotit_temp;
    
    /* ###########################################################################################
    -- // CREA TABLA INFORMACIÓN CREDITICIA DE LOS TITULARES
    create temp table si_infcrdtit_temp (
        num_credito     char(20),
        moneda          smallint,
        segmento        smallint,
        tpo_cobranza    smallint,
        cap_vigente     decimal(15,2),
        cap_vencido     decimal(15,2),
        ints_ord_exig   decimal(15,2),
        ints_moratorios decimal(15,2),
        otros_accesorio decimal(15,2) 
    ) with no log; 
    create index idxtmp_infcrdtitcomp_crd on si_infcrdtit_temp(num_credito) using btree;
    UPDATE STATISTICS MEDIUM FOR TABLE si_infcrdtit_temp;
    
    -- // CREA TABLA CREDITOS ASOCIADOS DE LOS TITULARES
    create temp table si_crdasotit_temp (
        num_credito     char(20),
        cve_unica       char(18) 
    ) with no log;   
    create index idxtmp_crdasotitcomp_crd on si_crdasotit_temp(num_credito) using btree;
    create index idxtmp_crdasotitcomp_cve on si_crdasotit_temp(cve_unica) using btree;
    UPDATE STATISTICS MEDIUM FOR TABLE si_crdasotit_temp;   
    ########################################################################################### */
    
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
       
    SELECT valor 
	  INTO mBase_exenta
      FROM bdicheq:sc_param
	 WHERE empresa = '001' 
	   AND codparam = "baseexenta";

    IF mBase_exenta IS NULL THEN
        LET mbase_exenta = 0;
    END IF;
    
    -- // OBTIENE EL VALOR DE LA UDI A LA FECHA DE LA PROYECCIÓN
    /*
    SELECT preciocontable
      INTO mValorUDI
      FROM bdirepaut@coppelcont_tcp:sp_preciocontable
     WHERE moneda = '09'
       AND fecha = pFechaFin;
    */
    
    LET mValorUDI = 7.426776;
       
    IF mValorUDI is null THEN
        LET mValorUDI = 1;
    END IF;
    
    --- LET mValorUDI = 5.972403;
    LET mValorUDIS = mValorUDI * 400000;
    
    -- // OBTIENE CLIENTES A PROCESAR    
    SELECT valor::CHAR(20)
      INTO cCteMin
      FROM si_param
     WHERE cod_param = 226;
     
    SELECT valor::CHAR(20)
      INTO cCteMax
      FROM si_param
     WHERE cod_param = 227;
     
    -- // FOREACH CLIENTES
    FOREACH WITH HOLD
        SELECT numcte
          INTO cNumCliente
          FROM si_cliente_ipab_temp
         WHERE numcte > cCteMin
           AND numcte <= cCteMax
        
        BEGIN WORK;
        LET iComit = 1;
        
        -- // OBTIENE DATOS PERSONALES DEL CLIENTE
        SELECT TRIM(cte.rfc) AS rfc,  
               TRIM(cte.tpo_persona) AS personalidad, 
               TRIM(cte.nombre1)||' '||TRIM(cte.nombre2) || Trim(cte.razon_social) AS nombre, 
               TRIM(cte.apell_paterno) AS apellpaterno, 
               TRIM(cte.apell_materno) AS apellmaterno, 
               TRIM(ctepf.curp) AS curp,
               cte.sucursal AS succte,
               ctepf.fecha_nac
          INTO cRfc, cPersona, cNombre, cApellido1, cApellido2, cCurp, cSucCte, dFechaNac
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
            /* ###########################
            SELECT TRIM(direccion1)
              INTO cNombreCalle
              FROM bdinteg:si_sucursales 
             WHERE sucursal = cSucCte;
            ########################### */
            
            SELECT TRIM(calle)||' '||TRIM(num_ext)
              INTO cNombreCalle
              FROM bdinteg:si_ptf
             WHERE id_ptf = cSucCte
               AND tipo = 'S';
        END IF;
        
        IF ( cColonia is null OR cColonia = '' OR cColonia = ' ' ) THEN
            /* ##########################################
            SELECT d_codigo
              INTO cCodPostal
              FROM bdinteg:si_sucursales 
             WHERE sucursal = cSucCte;
             
            SELECT FIRST 1 TRIM(NVL(nombrezona,'')) 
              INTO cColonia
              FROM bdinteg:si_catzonas 
             WHERE codigopostalzona = cCodPostal;
            ########################################## */
            
            SELECT TRIM(loc.desc_colonia)
              INTO cColonia
              FROM bdinteg:si_ptf ptf,
                   bdinteg:si_localidades loc
             WHERE ptf.cp = loc.cp
               AND ptf.cve_estado = loc.cve_estado
               AND ptf.cve_mun = loc.cve_mun
               AND ptf.cve_localidad = loc.cve_localidad_cnbv
               AND ptf.cve_col = loc.cve_col
               AND ptf.id_ptf = cSucCte
               AND ptf.tipo = 'S';
             
            LET cCodPostal2 = cCodPostal;
        END IF;
        
        IF ( cMunicipio is null OR cMunicipio = '' OR cMunicipio = ' ' OR cMunicipio = 'POR ASIGNAR' ) THEN
            /* ###########################################
            SELECT d_codigo
              INTO cCodPostal
              FROM bdinteg:si_sucursales 
             WHERE sucursal = cSucCte;
             
            SELECT FIRST 1 TRIM(NVL(municipiozona,'')) 
              INTO cMunicipio
              FROM bdinteg:si_catzonas 
             WHERE codigopostalzona = cCodPostal;
            ########################################### */
            
            SELECT TRIM(loc.desc_municipio)
              INTO cMunicipio
              FROM bdinteg:si_ptf ptf,
                   bdinteg:si_localidades loc
             WHERE ptf.cp = loc.cp
               AND ptf.cve_estado = loc.cve_estado
               AND ptf.cve_mun = loc.cve_mun
               AND ptf.cve_localidad = loc.cve_localidad_cnbv
               AND ptf.cve_col = loc.cve_col
               AND ptf.id_ptf = cSucCte
               AND ptf.tipo = 'S';
        END IF;
        
        IF ( cMunicipio is null OR cMunicipio = '' OR cMunicipio = ' ' OR cMunicipio = 'POR ASIGNAR' ) THEN
            LET cMunicipio = cColonia;
        END IF;
        
        IF ( cNomCiudadCte is null OR cNomCiudadCte = '' OR cNomCiudadCte = ' ' ) THEN
            LET cNomCiudadCte = cMunicipio;
        END IF;
        
        IF ( cEstado is null OR cEstado = '' OR cEstado = ' ' ) THEN
            /* ############################
            SELECT estado
              INTO cNoEstado
              FROM bdinteg:si_sucursales 
             WHERE sucursal = cSucCte;
            ############################ */
            
            SELECT cve_estado
              INTO cNoEstado
              FROM bdinteg:si_ptf
             WHERE id_ptf = cSucCte
               AND tipo = 'S';
             
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
                
                /* ############################
                SELECT d_codigo
                  INTO cCodPostal
                  FROM bdinteg:si_sucursales
                 WHERE sucursal = vSucCta;
                ############################ */
                
                SELECT cp
                  INTO cCodPostal
                  FROM bdinteg:si_ptf
                 WHERE id_ptf = vSucCta
                   AND tipo = 'S';
                 
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
        
        -- // VERIFICA SI EL CLIENTE TIENE CUENTAS DE CHEQUES PARA REPORTARLAS
        EXECUTE PROCEDURE sp_repchequesipab_temp( cNumCliente, pFechaIni, pFechaFin, dPorRetSuj, iAniobase, mBase_exenta, cTipoPersona ) 
        INTO cCodRet6;
        
        IF ( cCodRet6 IS NULL OR cCodRet6 = '' OR cCodRet6 <> '000' ) THEN
            ROLLBACK WORK;
            LET cCodRet = cCodRet6;
            LET cCodRet2 = cCodRet6;
            LET cCodRet3 = 'ERROR EN EL PROCESAMIENTO DE CUENTAS, CLIENTE: '||TRIM(cNumCliente);
            RETURN cCodRet, cCodRet2, cCodRet3;
        END IF;
        
        -- // VERIFICA SI EL CLIENTE TIENE PAGARES PARA REPORTARLOS
        EXECUTE PROCEDURE sp_reppagaresipab_temp( cNumCliente, pFechaIni, pFechaFin, dPorRetSuj, iAniobase ) 
        INTO cCodRet7;
        
        IF ( cCodRet7 IS NULL OR cCodRet7 = '' OR cCodRet7 <> '000' ) THEN
            ROLLBACK WORK;
            LET cCodRet = cCodRet7;
            LET cCodRet2 = cCodRet7;
            LET cCodRet3 = 'ERROR EN EL PROCESAMIENTO DE PAGARES, CLIENTE: '||TRIM(cNumCliente);
            RETURN cCodRet, cCodRet2, cCodRet3;
        END IF;
        
        /* ##########################################################################################
        -- // VERIFICA SI EL CLIENTE TIENE CREDITOS PARA REPORTARLOS
        EXECUTE PROCEDURE sp_repcredsipab_temp( cNumCliente, pFechaIni ) 
        INTO cCodRet8;
        
        IF ( cCodRet8 IS NULL OR cCodRet8 = '' OR cCodRet8 NOT IN('00000','00002') ) THEN
            ROLLBACK WORK;
            LET cCodRet = cCodRet8;
            LET cCodRet2 = cCodRet8;
            LET cCodRet3 = 'ERROR EN EL PROCESAMIENTO DE CREDITOS, CLIENTE: '||TRIM(cNumCliente);
            RETURN cCodRet, cCodRet2, cCodRet3;
        END IF;
        ########################################################################################## */
        
        -- // OBTIENE EL SALDO DE LAS CUENTAS DE CHEQUES
        SELECT COUNT(*)
          INTO iCveUnica
          FROM si_ctaasotit_temp
         WHERE cve_unica = cNumCliente;
         
        IF iCveUnica > 0 THEN
            SELECT SUM(chq.sdo_neto)
              INTO dSdoCheques
              FROM si_infpattit_temp chq,
                   si_ctaasotit_temp cta
             WHERE chq.numcta = cta.numcta
               AND chq.num_inversion = cta.num_inversion
               AND cta.cve_unica = cNumCliente;
               
            LET iCheques = 1;
            
            SELECT COUNT(*)
              INTO iCtasBloqueadas
              FROM si_infpattit_temp chq,
                   si_ctaasotit_temp cta
             WHERE chq.numcta = cta.numcta
               AND chq.num_inversion = cta.num_inversion
               AND cta.cve_unica = cNumCliente
               AND chq.status_cta = '3';
        ELSE
            LET iCheques = 0;
            LET dSdoCheques = 0;
        END IF;
        
        IF dSdoCheques > mValorUDIS THEN
            LET dSdoCheques = mValorUDIS;
        END IF;
        
        -- // OBTIENE EL SALDO DE LOS CREDITOS VENCIDOS
        SELECT COUNT(*)
          INTO iCveUnicaCrd
          FROM si_crdasotit_temp
         WHERE cve_unica = cNumCliente;
         
        IF iCveUnicaCrd > 0 THEN
            SELECT SUM(crd.cap_vencido + crd.ints_ord_exig + crd.ints_moratorios + crd.otros_accesorio)
              INTO dSdoCredito
              FROM si_infcrdtit_temp crd,
                   si_crdasotit_temp cta
             WHERE crd.num_credito = cta.num_credito
               AND cta.cve_unica = cNumCliente;
            
            LET iCreditos = 1;
        ELSE
            LET iCreditos = 0;
            LET dSdoCredito = 0;
        END IF;
        
        -- // VALIDA SI EL CLIENTE ES EXCLUIDO DEL IPAB
        SELECT COUNT(*)
          INTO iExcluido
          FROM si_excluidosipab
         WHERE numcte = cNumCliente;
        
        IF   iExcluido > 0 THEN
            LET iCauRev = 1;
        ELIF iExcluido = 0 AND iCtasBloqueadas > 0 THEN
            LET iCauRev = 3;
        ELIF iExcluido = 0 AND iCtasBloqueadas = 0 THEN
            LET iCauRev = 0;
        END IF;
        
        -- // REALIZA LA COMPENSACION DE SALDOS
        LET dSaldoCompensado = dSdoCheques - dSdoCredito;
        
        IF ( dSaldoCompensado < 0 OR iCtasBloqueadas > 0 OR iCauRev IN(1, 3) )  THEN
            LET dSaldoCompensado = 0.00;
        END IF;
        
        -- // REALIZA LA CLASIFICACION DEL TITULAR
        IF ( iCheques = 1 AND iCreditos = 0 ) THEN
            LET iClasificaTitular = 1;
        ELIF ( iCheques = 0 AND iCreditos = 1 ) THEN
            LET iClasificaTitular = 2;
        ELIF ( iCheques = 1 AND iCreditos = 1 ) THEN
            LET iClasificaTitular = 3;
        END IF;
        
        -- // REASIGNA VARIABLES PARA INSERTARLAS
        LET iCodPostal = cCodPostal;
        LET iFechaNacimiento = TO_CHAR(dFechaNac, '%Y%m%d');
        
        -- // INSERTA INFORMACION PERSONAL DEL CLIENTE
        INSERT INTO si_infpertit_temp VALUES
        ( cNumCliente, cTipoPersona, cNombre, cApellido1, cApellido2, cNombreCalle, cColonia, cMunicipio, cNomCiudadCte, iCodPostal, cPais, cEstado, 
          cSujRet, dPorRetSuj, iCauRev, cRfc, cCurp, cTelefono, cCorreo, iFechaNacimiento, dSaldoCompensado, iClasificaTitular, cTipoCodPos );
        
        LET iComit = 0;
        COMMIT WORK;
        
        LET iContador1 = iContador1 + 1;
        LET iContador2 = iContador2 + 1;
        LET iContador3 = iContador3 + 1;
        
        -- // MUESTRA EN PANTALLA EL NUMERO DE REGISTROS PROCESADOS
        IF iContador2 >= 10000 THEN
            LET iContador2 = 0;
            LET cSql = 'echo "REGISTROS PROCESADOS PARTE 6: '||iContador1||'" > /resplogifx/conciliachq/ipab/regsprocpte6.txt';
            SYSTEM cSql;
        END IF;
        
        -- // REALIZA ESTADISTICAS A LAS TABLAS DE TRABAJO
        IF iContador3 >= 100000 THEN
            LET iContador3 = 0;
            
            UPDATE STATISTICS MEDIUM FOR TABLE si_infpertit_temp ;
            UPDATE STATISTICS MEDIUM FOR TABLE si_infpattit_temp ;
            UPDATE STATISTICS MEDIUM FOR TABLE si_ctaasotit_temp ;
        END IF;
        
        LET cNumCliente = ''; 
        LET cRfc = ''; 
        LET cPersona = ''; 
        LET cNombre = ''; 
        LET cApellido1 = ''; 
        LET cApellido2 = ''; 
        LET cCurp = ''; 
        LET cSucCte = '';
        LET dFechaNac = ''; 
        LET cCorreo = ''; 
        LET iNumeroCalle = 0; 
        LET cNumExtCalle = ''; 
        LET cCodPostal = ''; 
        LET cTelefono = ''; 
        LET cTelefono2 = ''; 
        LET cTelefono3 = ''; 
        LET iNumCiudad = 0; 
        LET iNumColonia = 0; 
        LET cNoEstado = ''; 
        LET cNoPais = ''; 
        LET cNombreCalle = ''; 
        LET cColonia = ''; 
        LET cMunicipio = ''; 
        LET cCodPostal2 = ''; 
        LET cNomCiudadCte = ''; 
        LET cEstado = ''; 
        LET cPais = ''; 
        LET iExisteCodPos = 0; 
        LET cTipoCodPos = ''; 
        LET vSucCta = ''; 
        LET cPfisica = ''; 
        LET cExento_isr = ''; 
        LET cTipoPersona = ''; 
        LET cSujRet = ''; 
        LET dPorRetSuj = 0; 
        LET iExcluido = 0; 
        LET iCauRev = 0; 
        LET cCodRet6 = ''; 
        LET cCodRet7 = ''; 
        LET cCodRet8 = ''; 
        LET iCveUnica = 0; 
        LET dSdoCheques = 0; 
        LET iCheques = 0; 
        LET iCveUnicaCrd = 0; 
        LET dSdoCredito = 0; 
        LET iCreditos = 0; 
        LET iCodPostal = 0; 
        LET cFechaNac = ''; 
        LET iFechaNacimiento = 0; 
        LET dSaldoCompensado = 0; 
        LET iClasificaTitular = 0;
        LET iCtasBloqueadas = 0;
    END FOREACH; 
    
    END;
    
    RETURN cCodRet, cCodRet2, cCodRet3;
    
END PROCEDURE;