CREATE PROCEDURE "informix".direccionespba( pEmpresa         CHAR(3),  
                                         pFuncion         CHAR(1),   
                                         pNumCte          CHAR(20), 
                                         pSecuencia       SMALLINT, 
                                         pTipoDir         CHAR(1), 
                                         pCalle           CHAR(40),
                                         pColonia         CHAR(60), 
                                         pMunicipio       CHAR(5), 
                                         pEntre_Calles    CHAR(40),
                                         pPais            CHAR(3),
                                         pEntidad         CHAR(2),
                                         pLocalidad       CHAR(3),
                                         pCodPostal       CHAR(5),
                                         pTipoTel1        CHAR(1),
                                         pTelefono1       CHAR(13),
                                         pTipoTel2        CHAR(1),
                                         pTelefono2       CHAR(13),
                                         pTipoTel3        CHAR(1),
                                         pTelefono3       CHAR(13),
                                         pExtension       CHAR(5),
                                         pEstado_Inegi    CHAR(2),
                                         pMunicipio_Inegi CHAR(3),
                                         pLocalidad_Inegi CHAR(4),
                                         pNoCiudad        SMALLINT,
                                         pNoExt           CHAR(10),
                                         pNoInt           CHAR(10),
                                         pDepto           CHAR(6),
                                         pNoCalle         INTEGER,
                                         pNoColonia       INTEGER,
                                         pPuntoCar        CHAR(1),
                                         pUniHabi         CHAR(1),
                                         pManz            SMALLINT,
                                         pPOtros          SMALLINT,
                                         pAndador         SMALLINT,
                                         pEtapa           SMALLINT,
                                         pLote            SMALLINT,
                                         pEdif            SMALLINT,
                                         pEntrada         SMALLINT,
                                         pObserva         CHAR(80),
                                         pUser_Insert     CHAR(8),
                                         pFecha_Insert    DATE,
                                         cSucursal        CHAR(4) )
RETURNING CHAR(5);

    DEFINE v_CodRet             CHAR(5);
    DEFINE v_CodRet2            CHAR(5);
    DEFINE v_CodRet3            CHAR(50);
    DEFINE v_SqlErr             INTEGER;
    DEFINE v_IsamErr            INTEGER;
    DEFINE v_DescErr            CHAR(50);
    DEFINE v_NumCte             CHAR(20);
    DEFINE pcoincide_dir        SMALLINT;
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
    DEFINE o_telefono1      	CHAR(13);
    DEFINE o_telefono2      	CHAR(13);
    DEFINE o_telefono3      	CHAR(13);
    DEFINE o_extension      	CHAR(5);
    DEFINE o_estado_inegi   	CHAR(2);
    DEFINE o_municipio_inegi	CHAR(3);
    DEFINE o_localidad_inegi    CHAR(4);
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
    DEFINE v_CodRetTel          CHAR(5);
    DEFINE vTipoTel             SMALLINT;
    DEFINE vCanal               SMALLINT;
    DEFINE cSituacionEsp        CHAR(1);  --- VARIABLE DE SITUACIÓN ESPECIAL
    DEFINE iCausa               INTEGER;  --- VARIABLE DE SITUACIÓN ESPECIAL

    LET v_CodRet          = '';
    LET v_CodRet2         = '';
    LET v_CodRet3         = '';
    LET v_SqlErr          = 0;
    LET v_IsamErr         = 0;
    LET v_DescErr         = '';
    LET v_NumCte          = '';
    LET pcoincide_dir     = 0;
    LET o_tipo_dir        = '';
    LET o_calle           = '';
    LET o_colonia         = '';
    LET o_entre_calles    = '';
    LET o_pais            = '';
    LET o_estado          = '';
    LET o_ciudad          = '';
    LET o_municipio       = '';
    LET o_cod_postal      = '';
    LET o_apart_postal    = '';
    LET o_telefono1       = '';
    LET o_telefono2       = '';
    LET o_telefono3       = '';
    LET o_extension       = '';
    LET o_estado_inegi    = '';
    LET o_municipio_inegi = '';
    LET o_localidad_inegi = '';
    LET o_numerociudad    = 0;
    LET o_numeroextcalle  = '';
    LET o_numerointcalle  = '';
    LET o_departamento    = '';
    LET o_numerocalle     = 0;
    LET o_numerocolonia   = 0;
    LET o_puntocardinal   = '';
    LET o_unidadhabitac   = '';
    LET o_manzana         = 0;
    LET o_otros           = 0;
    LET o_andador         = 0;
    LET o_etapa           = 0;
    LET o_lote            = 0;
    LET o_edificio        = 0;
    LET o_entrada         = 0;
    LET o_observaciones   = '';
    LET v_CodRetTel       = '';
    LET vTipoTel          = 0;
    LET vCanal            = 1;
    LET cSituacionEsp     = 'N'; --- VARIABLE DE SITUACIÓN ESPECIAL
    LET iCausa            = 0;   --- VARIABLE DE SITUACIÓN ESPECIAL

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/direcciones.out";
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET v_SqlErr, v_IsamErr, v_DescErr
        SET DEBUG FILE TO "/tmp/direcciones.err";
        TRACE ON;
        IF v_SqlErr != 0 THEN
            LET v_CodRet = v_SqlErr;
            LET v_CodRet2 = v_IsamErr;
            LET v_CodRet3 = v_DescErr;
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
        SELECT MAX(secuencia) 
          INTO pSecuencia
          FROM si_direcciones_actual
         WHERE numcte = pNumCte;
         
        IF pSecuencia IS NULL THEN
            LET pSecuencia = 1;
        ELSE
            LET pSecuencia = pSecuencia + 1;
            LET cSituacionEsp = 'S';
        END IF;

        -- // SE AGREGA VALIDACIÓN PARA SI LA CLAVE DEL MUNICIPIO VIENE VACIO, LE ASIGNE  "00000".
        IF pMunicipio = "" OR pMunicipio is null  THEN
            LET pMunicipio = LPAD(TRIM(NVL(pMunicipio,"00000")),5,"0");
        END IF;
        
        -- // VALIDA LA INFORMACION DE LA DIRECCION DEL CLIENTE
        SELECT tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
               estado_inegi, municipio_inegi, localidad_inegi, numerociudad, 
               numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
               puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones
          INTO o_tipo_dir, o_calle, o_colonia, o_entre_calles, o_pais, o_estado, o_ciudad, o_municipio, o_cod_postal, o_apart_postal,
               o_estado_inegi, o_municipio_inegi, o_localidad_inegi, o_numerociudad, 
               o_numeroextcalle, o_numerointcalle, o_departamento, o_numerocalle, o_numerocolonia, 
               o_puntocardinal, o_unidadhabitac, o_manzana, o_otros, o_andador, o_etapa, o_lote, o_edificio, o_entrada, o_observaciones
          FROM si_direcciones_actual
         WHERE numcte = pNumCte
           AND tipo_dir = pTipoDir;
        
        IF ( o_tipo_dir is not null               
             AND o_calle = pCalle                     
             AND o_colonia = pColonia                 
             AND o_entre_calles = pEntre_Calles       
             AND o_pais = pPais                       
             AND o_estado = pEntidad                  
             AND o_ciudad = pLocalidad                
             AND o_municipio = pMunicipio             
             AND o_cod_postal = pCodPostal            
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
            LET pcoincide_dir = 1;
        ELSE
            LET pcoincide_dir = 0;
        END IF;
        
        IF ( pcoincide_dir <= 0 ) THEN
			INSERT INTO si_direcciones
            ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
              estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, 
              departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, 
              andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )
            VALUES
            ( pNumCte, pSecuencia, pTipoDir, pCalle, pColonia, pEntre_Calles, pPais, pEntidad, pLocalidad, pMunicipio, pCodPostal, "",
              pEstado_Inegi, pMunicipio_Inegi, pLocalidad_Inegi, pNoCiudad, pNoExt, pNoInt,
              pDepto, pNoCalle, pNoColonia, pPuntoCar, pUniHabi, pManz, pPOtros,
              pAndador, pEtapa, pLote, pEdif, pEntrada, pObserva, pUser_Insert, pFecha_Insert );
        END IF;
        
        -- // VALIDA LA INFORMACIÓN DE LOS TELEFONOS DEL CLIENTE
        SELECT telefono
          INTO o_telefono1
          FROM si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 1;
           
        IF o_telefono1 is null THEN
            LET o_telefono1 = ' ';
        END IF;
           
        IF o_telefono1 <> pTelefono1 THEN
            IF cSucursal = '5002' THEN
                LET vCanal = 12;
            END IF;
              
            IF ( ( pTipoTel1 is not null AND pTipoTel1 <> '' ) AND ( pTelefono1 is not null AND pTelefono1 <> '' ) ) THEN
                LET vTipoTel = 1;
                CALL sp_registra_telefonos(pEmpresa, pNumCte, pTelefono1, vTipoTel, '', 0, vCanal, pUser_Insert)
                RETURNING v_CodRetTel;
            END IF;
        END IF;
           
        SELECT telefono
          INTO o_telefono2
          FROM si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 2;
           
        IF o_telefono2 is null THEN
            LET o_telefono2 = ' ';
        END IF;
           
        IF o_telefono2 <> pTelefono2 THEN
            IF cSucursal = '5002' THEN
                LET vCanal = 12;
            END IF;
              
            IF ( ( pTipoTel2 is not null AND pTipoTel2 <> '' ) AND ( pTelefono2 is not null AND pTelefono2 <> '' ) ) THEN
                LET vTipoTel = 2;
                CALL sp_registra_telefonos(pEmpresa, pNumCte, pTelefono2, vTipoTel, '', 0, vCanal, pUser_Insert)
                RETURNING v_CodRetTel;
            END IF;
        END IF;
           
        SELECT telefono, extension
          INTO o_telefono3, o_extension
          FROM si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 3;
           
        IF o_telefono3 is null THEN
            LET o_telefono3 = ' ';
        END IF;
           
        IF o_telefono3 <> pTelefono3 THEN
            IF cSucursal = '5002' THEN
                LET vCanal = 12;
            END IF;
              
            IF ( ( pTipoTel3 is not null AND pTipoTel3 <> '' ) AND ( pTelefono3 is not null AND pTelefono3 <> '' ) ) THEN
                LET vTipoTel = 3;
                CALL sp_registra_telefonos(pEmpresa, pNumCte, pTelefono3, vTipoTel, pExtension, 0, vCanal, pUser_Insert)
                RETURNING v_CodRetTel;
            END IF;
        END IF;
        
        -- // VALIDACIÓN DE SITUACIÓN ESPECIAL
        IF pTipoDir = '1' AND cSituacionEsp = 'S' THEN
            SELECT LIMIT 1 NVL(situacion,''), causa
              INTO cSituacionEsp, iCausa
              FROM bdisitesp:se_ctessitespcte
             WHERE numcte = pNumCte;
			
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

CREATE PROCEDURE "informix".sp_ipab_pagare(pFechaIni DATE, pFechaFin DATE, pNumCliente CHAR(20), pPersona CHAR(2))
RETURNING CHAR(5);
    
    DEFINE cPfisica, cExento_isr, cRegFiscal, cTipoTasa, cOperArit, cSujRet CHAR(1);
    DEFINE cTpoCuenta, cDivisa CHAR(2);    
    DEFINE cPorcentaje, cInstbase, cSobretasa CHAR(3);   
    DEFINE cNumProducto, cSucursal CHAR(4);
    DEFINE dSdo_PromInv, cPlazo, P_COD_RET, P_COD_RET2 CHAR(5); 
    DEFINE cNumCuenta, cCtaInversion CHAR(20);           
    DEFINE cNomProducto, DESC_ERR, P_COD_RET3 CHAR(40);           
    DEFINE dFechaCorte, dFechaSigCorte, dFechaContratacion DATE;               
    DEFINE sAnio, sCauRev, vexcluido SMALLINT;           
    DEFINE iDias_Proy, iAniobase, SQL_ERR, ISAM_ERR, iDias_Ini INTEGER;
    DEFINE sResiduo DECIMAL(9,3);
    DEFINE dtasa, dPorRetencionSuj, dtasax2 DECIMAL(9,6); 
    DEFINE mISR_Proy, mInt_Proy, mSdo_Inv_Proy, mInt_al_Inicio, mCapital, mSdo_Ini, mSdo_Prom_Ini, dImp_Isr_Ini, mSdo_Prom_Fin MONEY(18,2);

    LET cPfisica           = "";            LET cExento_isr        = "";            LET cRegFiscal         = "N";
    LET cTipoTasa          = "1";           LET cOperArit          = NULL;          LET cSujRet            = "S";
    LET cTpoCuenta         = "CI";          LET cDivisa            = "";            LET cPorcentaje        = NULL;
    LET cInstbase          = NULL;          LET cSobretasa         = NULL;          LET cNumProducto       = "";            
    LET cSucursal          = "";            LET dSdo_PromInv       = NULL;          LET cPlazo             = "";            
    LET P_COD_RET          = "00000";       LET P_COD_RET2         = "00000";       LET cNumCuenta         = "";            
    LET cCtaInversion      = "";            LET cNomProducto       = "";            LET DESC_ERR           = "";            
    LET P_COD_RET3         = "";            LET dFechaCorte        = NULL;          LET dFechaSigCorte     = NULL;          
    LET dFechaContratacion = "01-01-1900";  LET sAnio              = 0;             LET sCauRev            = 0;             
    LET vexcluido          = 0;             LET iDias_Proy         = 0;             LET iAniobase          = 0;             
    LET SQL_ERR            = 0;             LET ISAM_ERR           = 0;             LET iDias_Ini 		   = 0;             
    LET sResiduo           = 0;             LET dtasa              = 0;             LET dPorRetencionSuj   = 0;      
    LET dtasax2            = 0;             LET mISR_Proy          = 0;             LET mInt_Proy          = 0;             
    LET mSdo_Inv_Proy      = 0;             LET mInt_al_Inicio 	   = 0;             LET mCapital           = 0.00;          
    LET mSdo_Ini 		   = 0;             LET mSdo_Prom_Ini 	   = 0;             LET dImp_Isr_Ini 	   = 0;             
    LET mSdo_Prom_Fin 	   = 0;
                      
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_ipab_pagare.out';
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, DESC_ERR
        SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_ipab_pagare.err';
        TRACE ON;
        LET P_COD_RET = SQL_ERR;
        LET P_COD_RET2 = ISAM_ERR;
        LET P_COD_RET3 = DESC_ERR;
        RETURN P_COD_RET;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;

    SELECT valor
      INTO dPorRetencionSuj
      FROM bdinteg:si_fechavalor
     WHERE tasa = "I.S.R." 
       AND fecha = (SELECT max(fecha)
                      FROM bdinteg:si_fechavalor
                     WHERE tasa = "I.S.R.");

    LET sAnio = year(pFechaFin);
    LET sResiduo = mod(sAnio, 4);

    IF sResiduo = 0 THEN
        LET iAniobase = 366;
    ELSE
        LET iAniobase = 365;
    END IF;

    LET dPorRetencionSuj = dPorRetencionSuj / 100;

    FOREACH
        SELECT nvl(cta_cheques, ''), nvl(cuenta, ''), nvl(capital , 0), nvl(cod_instrum, ''), 
               nvl(sucursal, ''), nvl(fecha_alta, '05/01/2007'), nvl(tasa, 0), nvl(plazo, 0)
          INTO cNumCuenta, cCtaInversion, mCapital, cNumProducto, cSucursal, dFechaContratacion, dtasa, cPlazo
          FROM bdinvers:sv_maeinv 
         WHERE num_cte = pNumCliente
           AND fecha_alta <= pFechaIni 
           AND fecha_venc > pFechaIni
           AND ( fec_cancelac > pFechaIni or fec_cancelac is null )
        
        SELECT es_fisica, exento_isr
          INTO cPfisica, cExento_isr
          FROM bdinteg:si_tipper
         WHERE tpo_persona = pPersona;

        IF cExento_isr = 'N' THEN
            LET cSujRet = 'S';
        ELSE
            LET cSujRet = 'N';
        END IF;

        IF cSujRet <> 'S' THEN                
            LET dPorRetencionSuj = 0;
        END IF;   

        SELECT COUNT(*)
          INTO vexcluido
          FROM bdinteg:si_excluidosipab 
         WHERE numcte = pNumCliente;

        IF vexcluido > 0 THEN
            LET sCauRev = 1;
        ELSE
            LET sCauRev = 0;
        END IF;
        
        LET dtasax2 = dtasa / 100;

        -- // OBTIENE EL NOMBRE DEL PRODUCTO Y LA MONEDA
        SELECT nombre, substring (nvl(moneda, ' ') from 2 for 1)
          INTO cNomProducto, cDivisa
          FROM bdinvers:sv_instrum
         WHERE cod_instrum  = cNumProducto;
        
        -- // OBTIENE SALDO PROYECTADO A AL FECHA FINAL DE LA PROYECCION
        LET mSdo_Prom_Fin = mCapital;
        LET iDias_Proy = (pFechaFin - dFechaContratacion) + 1;
        LET mInt_Proy = (mCapital * dtasax2 * iDias_Proy) / 360;
        
        IF dPorRetencionSuj <> 0 THEN
            LET mISR_Proy = (((mCapital * dPorRetencionSuj) * iDias_Proy) / iAniobase);
        ELSE
            LET mISR_Proy = 0;
        END IF;
        
        IF pFechaIni = pFechaFin THEN
            LET mSdo_Inv_Proy = mCapital + mInt_Proy;
        ELSE
            LET mSdo_Inv_Proy = ( mCapital + mInt_Proy ) - mISR_Proy;
        END IF;

        -- // INSERTA INFORMACION PATRIMONIAL DEL CLIENTE
        INSERT INTO si_infpattit_ipab VALUES
        ( UPPER(cNumCuenta), UPPER(cCtaInversion),  UPPER(cTpoCuenta), UPPER(cRegFiscal), cPorcentaje, NVL(sCauRev, 0), UPPER(cNomProducto), UPPER(cSucursal), 
          NVL(mSdo_Inv_Proy,0), UPPER(cDivisa), dFechaCorte, dFechaContratacion, cPlazo, cTipoTasa, NVL(dtasa,0), cInstbase, cSobretasa, cOperArit, dFechaSigCorte, 
          dSdo_PromInv, iDias_Ini, mSdo_Ini, mSdo_Prom_Ini, mInt_al_Inicio, dImp_Isr_Ini, iDias_Proy, mCapital, mSdo_Prom_Fin, mInt_Proy, mISR_Proy );

        -- // INSERTA CUENTAS ASOCIADAS DEL CLIENTE
        INSERT INTO si_ctaasotit_ipab VALUES
        ( UPPER(cNumCuenta), UPPER(cCtaInversion), UPPER(pNumCliente), 100.00 );
    END FOREACH;

    RETURN P_COD_RET;

    END;

END PROCEDURE;