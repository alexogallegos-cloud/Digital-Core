CREATE PROCEDURE "informix".direcciones_sols( pEmpresa         CHAR(3),
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
                                         cSucursal        CHAR(4),
                                         pCarrier         SMALLINT )
RETURNING CHAR(5), SMALLINT;
    
    DEFINE cCodRet             CHAR(5);
    DEFINE cCodRet2            CHAR(5);
    DEFINE cCodRet3            CHAR(50);
    DEFINE iSqlErr             INTEGER;
    DEFINE iIsamErr            INTEGER;
    DEFINE cDescErr            CHAR(50);
    DEFINE cNumCte             CHAR(20);
    DEFINE iCoincide_dir        SMALLINT;
    DEFINE cTipoDir       	CHAR(1);
    DEFINE cCalle          	CHAR(40);
    DEFINE cColonia        	CHAR(60);
    DEFINE cEntreCalles   	CHAR(40);
    DEFINE cPais           	CHAR(3);
    DEFINE cEstado         	CHAR(2);
    DEFINE cCiudad         	CHAR(3);
    DEFINE cMunicipio      	CHAR(5);
    DEFINE cCodPostal     	CHAR(5);
    DEFINE cApartPostal   	CHAR(11);
    DEFINE cTelefono1      	CHAR(13);
    DEFINE cTelefono2      	CHAR(13);
    DEFINE cTelefono3      	CHAR(13);
    DEFINE cExtension      	CHAR(5);
    DEFINE cEstadoInegi   	CHAR(2);
    DEFINE cMunicipioInegi	CHAR(3);
    DEFINE cLocalidadInegi    CHAR(4);
    DEFINE iNumeroCiudad   	SMALLINT;
    DEFINE cNumeroExtCalle 	CHAR(10);
    DEFINE cNumeroIntCalle 	CHAR(10);
    DEFINE cDepartamento   	CHAR(6);
    DEFINE iNumeroCalle    	INTEGER;
    DEFINE iNumeroColonia  	INTEGER;
    DEFINE cPuntoCardinal  	CHAR(1);
    DEFINE cUnidadHabitac  	CHAR(1);
    DEFINE iManzana        	SMALLINT;
    DEFINE iOtros          	SMALLINT;
    DEFINE iAndador        	SMALLINT;
    DEFINE iEtapa          	SMALLINT;
    DEFINE iLote           	SMALLINT;
    DEFINE iEdificio       	SMALLINT;
    DEFINE iEntrada        	SMALLINT;
    DEFINE cObservaciones  	CHAR(80);
    DEFINE cCodRetTel          CHAR(5);
    DEFINE iTipoTel             SMALLINT;
    DEFINE iCanal               SMALLINT;
    DEFINE cSituacionEsp        CHAR(1);  --- VARIABLE DE SITUACIÃN ESPECIAL
    DEFINE iCausa               INTEGER;  --- VARIABLE DE SITUACIÃN ESPECIAL
    
    LET cCodRet          = '';
    LET cCodRet2         = '';
    LET cCodRet3         = '';
    LET iSqlErr          = 0;
    LET iIsamErr         = 0;
    LET cDescErr         = '';
    LET cNumCte          = '';
    LET iCoincide_dir     = 0;
    LET cTipoDir        = '';
    LET cCalle           = '';
    LET cColonia         = '';
    LET cEntreCalles    = '';
    LET cPais            = '';
    LET cEstado          = '';
    LET cCiudad          = '';
    LET cMunicipio       = '';
    LET cCodPostal      = '';
    LET cApartPostal    = '';
    LET cTelefono1       = '';
    LET cTelefono2       = '';
    LET cTelefono3       = '';
    LET cExtension       = '';
    LET cEstadoInegi    = '';
    LET cMunicipioInegi = '';
    LET cLocalidadInegi = '';
    LET iNumeroCiudad    = 0;
    LET cNumeroExtCalle  = '';
    LET cNumeroIntCalle  = '';
    LET cDepartamento    = '';
    LET iNumeroCalle     = 0;
    LET iNumeroColonia   = 0;
    LET cPuntoCardinal   = '';
    LET cUnidadHabitac   = '';
    LET iManzana         = 0;
    LET iOtros           = 0;
    LET iAndador         = 0;
    LET iEtapa           = 0;
    LET iLote            = 0;
    LET iEdificio        = 0;
    LET iEntrada         = 0;
    LET cObservaciones   = '';
    LET cCodRetTel       = '';
    LET iTipoTel          = 0;
    LET iCanal            = 1;
    LET cSituacionEsp     = 'N'; --- VARIABLE DE SITUACIÃN ESPECIAL
    LET iCausa            = 0;   --- VARIABLE DE SITUACIÃN ESPECIAL
    
     --SET DEBUG FILE TO "/tmp/Victor/direcciones_out.sql";
     --TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        --SET DEBUG FILE TO "/tmp/direcciones_carrier.err";
        --TRACE ON;
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cDescErr;
            RETURN cCodRet, pSecuencia;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    LET cCodRet = "000";
    LET pEntidad = CAST( LPAD (TRIM(pEntidad), 2 ,  "0") AS CHAR(2));

    SELECT numcte 
      INTO cNumCte 
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = pNumCte;
     
    IF cNumCte IS NULL THEN
        LET cCodRet = "104";
        RETURN cCodRet, pSecuencia;
    END IF

    IF pFuncion = "C" THEN
        DELETE FROM bdinteg:"informix".si_direcciones
         WHERE numcte = pNumCte 
           AND secuencia = pSecuencia;
           
        DELETE FROM bdinteg:"informix".si_direcciones_actual
         WHERE numcte = pNumCte 
           AND secuencia = pSecuencia;
           
        LET pFuncion = "A";
    END IF

    IF pFuncion = "A" THEN
        SELECT MAX(secuencia) 
          INTO pSecuencia
          FROM bdinteg:"informix".si_direcciones_actual
         WHERE numcte = pNumCte;
         
        IF pSecuencia IS NULL THEN
            LET pSecuencia = 1;
        ELSE
            LET pSecuencia = pSecuencia + 1;
            LET cSituacionEsp = 'S';
        END IF;
        
        -- // SE AGREGA VALIDACIÃN PARA SI LA CLAVE DEL MUNICIPIO VIENE VACIO, LE ASIGNE  "00000".
        IF pMunicipio = "" OR pMunicipio is null THEN
            LET pMunicipio = LPAD(TRIM(NVL(pMunicipio,"00000")),5,"0");
        END IF;
        
        -- // VALIDA LA INFORMACION DE LA DIRECCION DEL CLIENTE
        SELECT tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
               estado_inegi, municipio_inegi, localidad_inegi, numerociudad, 
               numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
               puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones
          INTO cTipoDir, cCalle, cColonia, cEntreCalles, cPais, cEstado, cCiudad, cMunicipio, cCodPostal, cApartPostal,
               cEstadoInegi, cMunicipioInegi, cLocalidadInegi, iNumeroCiudad, 
               cNumeroExtCalle, cNumeroIntCalle, cDepartamento, iNumeroCalle, iNumeroColonia, 
               cPuntoCardinal, cUnidadHabitac, iManzana, iOtros, iAndador, iEtapa, iLote, iEdificio, iEntrada, cObservaciones
          FROM bdinteg:"informix".si_direcciones_actual
         WHERE numcte = pNumCte
           AND tipo_dir = pTipoDir;
           
        IF ( cTipoDir is not null 
             AND cCalle = pCalle 
             AND cColonia = pColonia 
             AND cEntreCalles = pEntre_Calles 
             AND cPais = pPais 
             AND cEstado = pEntidad  
             AND cCiudad = pLocalidad  
             AND cMunicipio = pMunicipio  
             AND cCodPostal = pCodPostal 
             AND cEstadoInegi = pEstado_Inegi
             AND cMunicipioInegi = pMunicipio_Inegi
             AND cLocalidadInegi = pLocalidad_Inegi
             AND iNumeroCiudad = pNoCiudad
             AND cNumeroExtCalle = pNoExt
             AND cNumeroIntCalle = pNoInt
             AND cDepartamento = pDepto
             AND iNumeroCalle = pNoCalle
             AND iNumeroColonia = pNoColonia
             AND cPuntoCardinal = pPuntoCar
             AND cUnidadHabitac = pUniHabi
             AND iManzana = pManz
             AND iOtros = pPOtros
             AND iAndador  = pAndador
             AND iEtapa = pEtapa
             AND iLote = pLote
             AND iEdificio = pEdif
             AND iEntrada = pEntrada
             AND cObservaciones = pObserva ) THEN
            LET iCoincide_dir = 1;
			LET cCodRet = "001";
        ELSE
            LET iCoincide_dir = 0;
        END IF;

        IF ( iCoincide_dir <= 0 ) THEN
            INSERT INTO bdinteg:"informix".si_direcciones
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
        
        -- // VALIDA LA INFORMACIÃN DE LOS TELEFONOS DEL CLIENTE
        SELECT telefono
          INTO cTelefono1
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 1;
           
        IF cTelefono1 is null THEN
            LET cTelefono1 = ' ';
        END IF;
           
        IF cTelefono1 <> pTelefono1 THEN
            IF cSucursal = '5002' THEN
                LET iCanal = 12;
            END IF;
              
            IF ( ( pTipoTel1 is not null AND pTipoTel1 <> '' ) AND ( pTelefono1 is not null AND pTelefono1 <> '' ) ) THEN
                LET iTipoTel = 1;
                CALL bdinteg:"informix".sp_registra_telefonos(pEmpresa, pNumCte, pTelefono1, iTipoTel, '', 0, iCanal, pUser_Insert)
                RETURNING cCodRetTel;
            END IF;
        END IF;
           
        SELECT telefono
          INTO cTelefono2
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 2;
           
        IF cTelefono2 is null THEN
            LET cTelefono2 = ' ';
        END IF;
           
        IF cTelefono2 <> pTelefono2 THEN
            IF cSucursal = '5002' THEN
                LET iCanal = 12;
            END IF;
              
            IF ( ( pTipoTel2 is not null AND pTipoTel2 <> '' ) AND ( pTelefono2 is not null AND pTelefono2 <> '' ) ) THEN
                LET iTipoTel = 2;
                CALL bdinteg:"informix".sp_registra_telefonos(pEmpresa, pNumCte, pTelefono2, iTipoTel, '', pCarrier, iCanal, pUser_Insert)
                RETURNING cCodRetTel;
            END IF;
        END IF;
           
        SELECT telefono, extension
          INTO cTelefono3, cExtension
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 3;
           
        IF cTelefono3 is null THEN
            LET cTelefono3 = ' ';
        END IF;
           
        IF cTelefono3 <> pTelefono3 THEN
            IF cSucursal = '5002' THEN
                LET iCanal = 12;
            END IF;
              
            IF ( ( pTipoTel3 is not null AND pTipoTel3 <> '' ) AND ( pTelefono3 is not null AND pTelefono3 <> '' ) ) THEN
                LET iTipoTel = 3;
                CALL bdinteg:"informix".sp_registra_telefonos(pEmpresa, pNumCte, pTelefono3, iTipoTel, pExtension, 0, iCanal, pUser_Insert)
                RETURNING cCodRetTel;
            END IF;
        END IF;
        
        -- // VALIDACIÃN DE SITUACIÃN ESPECIAL
        IF pTipoDir = '1' AND cSituacionEsp = 'S' THEN
            SELECT LIMIT 1 NVL(situacion,''), causa
              INTO cSituacionEsp, iCausa
              FROM bdisitesp:"informix".se_ctessitespcte
             WHERE numcte = pNumCte;

            IF cSituacionEsp = 'L' THEN
                DELETE FROM bdisitesp:"informix".se_ctessitespcte 
                 WHERE numcte = pNumCte 
                   AND situacion = 'L';

                INSERT INTO bdisitesp:"informix".se_ctessitespcte_his
                (empresa, sucursal, numcte, situacion, causa, tipomovto, empleadoefectuo, usralta, fchmodifica)
                VALUES
                (pEmpresa, cSucursal, pNumCte, cSituacionEsp, iCausa, 'B', pUser_Insert, pUser_Insert, pFecha_Insert);
            END IF;
        END IF;

        RETURN cCodRet, pSecuencia;
    END IF;
    
    END;
    
END PROCEDURE

DOCUMENT
"Alta de direcciones del cliente",
"Autor : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Manuel HernÂ ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Hector BojÃ³rquez",
"FECHA : 17/Junio/2009",
"MODIFICACION: En la actualizaciÃ³n de domicilios se identifica si el cliente",
"              tiene una situaciÃ³n especial L, de ser asi lo desmarca",
"Ver.  : 1.2",
"MODIFICO : Frank Gaxiola Gaxiola",
"FECHA : 28/Octubre/2009",
"MODIFICACION: Se quita funcionalidad de desmarcaje L, solicitado por Alfonso",
"              VelÃ¡zquez",
"Ver.  : 1.3",
"MODIFICO : Rodolfo Tortolero Varela",
"FECHA : 06/Abril/2010",
"MODIFICACION: Se implementa validaciÃ³n para formatear el campo municipio con",
"                             0 cuando este sea vacio o null, para que no inserte nuevo registro.",
"solicitado por Daniel Zambada",
"Ver.  : 1.4",
"MODIFICO : Rodolfo GÃ³mez HernÃ¡ndez",
"FECHA : Mayo/2010",
"MODIFICACION: Se optimiza sp guardando la direcciÃ³n del cliente en variables",
"              para la comparaciÃ³n si hay algÃºn cambio en la direcciÃ³n del cliente",
"Ver.  : 1.5",
"MODIFICO : Marco A. Campos",
"FECHA: 08-Ago-2011",
"MODIFICACION: Reactivar funcionalidad de desmarcaje situaciÃ³n especial L.",
"MODIFICO : Victor Hugo NuÃ±ez",
"FECHA: 08/05/2013",
"MODIFICACION: Se aÃ±ade validacion en caso de coincidencia devuelva 001";

CREATE PROCEDURE "informix".sp_consultactasgral_1(pEmpresa CHAR(3), 
									 pNumCte CHAR(20), 
									 pCuenta CHAR(20), 
									 pTarjeta CHAR(20),
									 pTipoCuenta CHAR(8),
									 pTpo  SMALLINT,
									 pLimit INTEGER,
									 pEjecucion INTEGER,
									 pProducto CHAR(4))
									
--DATOS A REGRESAR---
RETURNING CHAR(5)   AS Retorno, 
          CHAR(104) AS Nombre,
		  CHAR(20)  AS Cuenta, 
		  CHAR(20)  AS Tarjeta,
		  CHAR(4)   AS Sucursal,  
		  INTEGER	AS Cod_Producto, -- se agrega 
		  CHAR(40)  AS Producto, 
		  DATE      AS Fech_Alta, 
		  DATE 		AS Fech_Venc,     
		  CHAR(20)  AS Estatus,
		  CHAR(20)  AS NumCte,
		  INTEGER   AS Tipo,
		  INTEGER   AS iSkip,
		  INTEGER   AS iEjecucion,
		  DATE      AS FechaCancela,
		  CHAR(8)   AS PromotorCancela,
		  CHAR(40)  AS MotivoCancela,
		  CHAR(22)  AS FolioCancela,
		  MONEY(16,2)  AS SaldoRetenido,
		  MONEY(16,2)  AS SaldoDisponible,
		  DECIMAL(14,2)  AS Abono_mes,
		  MONEY(16,2)  AS Cargo_mes,
		  CHAR(8)	   AS Tipo_Cuenta;
		  
		  
	-- DEFINICION DE VARIABLES
	DEFINE cCod_ret      	 CHAR(5);
	DEFINE cRazon       	 CHAR(36);
    DEFINE cNumCte      	 CHAR(20);
    DEFINE cNombre1     	 CHAR(26);
	DEFINE cNombre2			 CHAR(26);
	DEFINE cMaterno			 CHAR(26);
	DEFINE cPaterno			 CHAR(26);
	DEFINE cCompleto    	 CHAR(36);
	DEFINE cSucursal    	 CHAR(4);
	DEFINE cCodigoProducto	 INTEGER; -- nuevo que se agrega
    DEFINE cProducto    	 CHAR(40);
    DEFINE cCuenta      	 CHAR(20);
    DEFINE cEstatus     	 CHAR(20);
	DEFINE cStatusCred  	 CHAR(2);
	DEFINE cTarjeta      	 CHAR(20);
	DEfine sTipo 			 SMALLINT;
	DEFINE iSqlErr      	 INTEGER;
	DEFINE iLimit 			 INTEGER;
	DEFINE iCantReg 		 INTEGER;
	DEFINE iSistema     	 INTEGER;
	DEFINE iTipo			 INTEGER;
	DEFINE iSkip			 INTEGER;
	DEFINE iEjecucion	     INTEGER;
	DEFINE dFecha_alta       DATE;
	DEFINE dFecha_venc  	 DATE;
	DEFINE dFec_cancelo 	 DATE;
	DEFINE cPromotor_cancelo CHAR (8);
	DEFINE cMotivo_cancelo 	 CHAR(3); 
	DEFINE cFolio_cancelo    CHAR(22);
	DEFINE cDescMot_cancelo  CHAR(40);
	DEFINE cSdo_disp         money(14,2);
	DEFINE cSdo_ret          money(14,2);
	DEFINE abono_mes         DECIMAL(14,2); 	-- nuevo
	DEFINE cargo_mes         DECIMAL(14,2);	-- nuevo
	DEFINE tipo_cuenta       CHAR(8);	-- nuevo
	DEFINE tipo_sistema      CHAR(8);	-- nuevo
	DEFINE v_abono           DECIMAL(14,2);  -- nuevo   
	DEFINE v_cargo           DECIMAL(14,2); -- nuevo
	DEFINE cod_ret           CHAR(5); -- nuevo
	--DEFINE aNumCred          CHAR(20); -- nuevo
	DEFINE temporal_pCuenta  CHAR(20);
	DEFINE temporal_pTarjeta CHAR(20);


	
	-- sp_consulta_saldos_general
	DEFINE cCodRet           CHAR(6);
	DEFINE cMensajeRet       CHAR(80);
	DEFINE cNumCredito       CHAR(20);
	DEFINE cCodTipCred       CHAR(2);
	DEFINE dtFechaOrigen     DATE;
	DEFINE dtFechaProxPago   DATE;
	DEFINE dPagoMinimo       DECIMAL(18,2);
	DEFINE dtFechaUltPago    DATE;
	DEFINE iPlazo            INTEGER;
	DEFINE iPagosRealizados  INTEGER;
	DEFINE dLineaOtorgada    DECIMAL(18,2);
	DEFINE dTasaInteres      DECIMAL(9,6);
	DEFINE dTasaMoratorios   DECIMAL(9,6);
	DEFINE dMontoSBC         DECIMAL(14,2);
	DEFINE dCapVig           DECIMAL(18,2);
	DEFINE dCapTrans         DECIMAL(18,2);
	DEFINE dCapVdoExig       DECIMAL(18,2);
	DEFINE dCapVdoNoExig     DECIMAL(18,2);
	DEFINE dSdoActCap        DECIMAL(18,2);
	DEFINE dIntVig           DECIMAL(18,2);
	DEFINE dIntVdo           DECIMAL(18,2);
	DEFINE dIntMoratorio     DECIMAL(18,2);
	DEFINE dIntMes           DECIMAL(18,2);
	DEFINE dSdoActInt        DECIMAL(18,2);
	DEFINE dIvaIntVig        DECIMAL(18,2);
	DEFINE dIvaIntVdo        DECIMAL(18,2);
	DEFINE dIvaIntMoratorio  DECIMAL(18,2);
	DEFINE dIvaIntMes        DECIMAL(18,2);
	DEFINE dSdoActIvaInt     DECIMAL(18,2);
	DEFINE dComPend          DECIMAL(18,2);
	DEFINE dIvaCom           DECIMAL(18,2);
	DEFINE dSdoRetenido      DECIMAL(18,2);
	DEFINE dSdoTotalLiq      DECIMAL(18,2);
	DEFINE dIntDevengado     DECIMAL(18,2);
	DEFINE dIvaIntDevengado  DECIMAL(18,2);
	DEFINE dLineaDisponible  DECIMAL(18,2);
	DEFINE dPagosVdos        DECIMAL(18,2);
	DEFINE cDescStatusCred   CHAR(60);
	DEFINE cDescBloqueoCta       CHAR(60);
	DEFINE cDescCausaBloqueoCta  CHAR(50);
	DEFINE cSitCte               CHAR(1);
	DEFINE cCausaCte             INTEGER;
	DEFINE iIdUnidadProd    	 INTEGER;
	DEFINE cCodCaract2      	 CHAR(3);
	DEFINE cDescSitEspCte        CHAR(75);
	DEFINE cSitCred              CHAR(1);
	DEFINE cCausaCred            INTEGER;
	DEFINE cDescSitEspCred       CHAR(75);
		
	-- CONS_SDOS1	
	DEFINE vcod_ret             char(5);
	DEFINE vcuenta              char(20);
	DEFINE vnum_cte             char(20);
	DEFINE vapell_pat           char(26);
	DEFINE vapell_mat           char(26);
	DEFINE vnombre1             char(26);
	DEFINE vnombre2             char(26);
	DEFINE vrazon_soc           char(60);
	DEFINE vedo_cta             char(1);
	DEFINE vsdo_disp            money(14,2);
	DEFINE vsdo_ret             money(14,2);
	DEFINE vsdo_ccc             money(14,2);
	DEFINE vsdo_disp_ccc        money(14,2);
	DEFINE vsdo_cta             money(14,2);
	DEFINE vtipo_linea          char(1);
	DEFINE vdescrip1            char(40);
	DEFINE vdescrip2            char(40);
	DEFINE vsdo_t1              money(14,2);
	DEFINE vsdo_cong            money(14,2);
	DEFINE vimp_chq_sbc         money(14,2);
	DEFINE vusubloq             char(8);
	DEFINE vfecbloq             date;
	DEFINE vnum_tarjeta         char(16);
	DEFINE vcta_clabe           char(18);
	DEFINE CodRet				CHAR(5);



	
	
	--INICIALIZACION DE VARIABLES
	LET cCod_ret     	  = "00000";
	LET cCompleto    	  = "";
	LET cRazon    	 	  = "";
	LET cNumCte    	 	  = "";
	LET cNombre1     	  = "";
	LET cNombre2     	  = "";
	LET cMaterno     	  = "";
	LET cPaterno     	  = "";
	LET cSucursal    	  = "";
	LET cCodigoProducto   = ""; -- se acaba de agregar
    LET cProducto    	  = "";
    LET cCuenta      	  = "";
	LET cEstatus     	  = "";
	LET cStatusCred	      = "";
	LET cTarjeta     	  = "";
	LET sTipo        	  = 0;
	LET iSqlErr      	  = 0;
	LET iLimit       	  = 0;
	LET iCantReg 	 	  = 0;
	LET iSistema     	  = 0;
	LET iTipo        	  = 0;
	LET iSkip        	  = 0;
	LET iEjecucion   	  = 0;
	LET dFecha_alta       = DATE(1);
	LET dFecha_venc  	  = DATE(1);
	LET dFec_cancelo  	  = DATE(1);
	LET cPromotor_cancelo = "";
	LET cMotivo_cancelo   = "";
	LET cFolio_cancelo    = "";
	LET cDescMot_cancelo  = "";
	LET cSdo_disp 		  = 0 ;
    LET cSdo_ret   		  = 0 ;
	LET abono_mes 		  = 0 ; -- nuevo
    LET cargo_mes  		  = 0 ; -- nuevo
	LET tipo_cuenta		  = ""; -- nuevo
	LET tipo_sistema	  = ""; -- nuevo
	LET cod_ret           = "00000";
	--LET cNumCredito       = "";
	
	-- sp_consulta_saldos_general
	LET cCodRet          	 = '';
	LET cMensajeRet          = '';
	LET cNumCredito          = '';
	LET cCodTipCred          = '';
	LET dtFechaOrigen         = DATE(1);
	LET dtFechaProxPago       = DATE(1);
	LET dPagoMinimo           = 0;
	LET dtFechaUltPago        = DATE(1);
	LET iPlazo                = 0;
	LET iPagosRealizados      = 0;
	LET dLineaOtorgada        = 0;
	LET dTasaInteres          = 0;
	LET dTasaMoratorios       = 0;
	LET dMontoSBC             = 0;
	LET dCapVig               = 0;
	LET dCapTrans             = 0;
	LET dCapVdoExig           = 0;
	LET dCapVdoNoExig         = 0;
	LET dSdoActCap            = 0;
	LET dIntVig               = 0;
	LET dIntVdo               = 0;
	LET dIntMoratorio         = 0;
	LET dIntMes               = 0;
	LET dSdoActInt            = 0;
	LET dIvaIntVig            = 0;
	LET dIvaIntVdo            = 0;
	LET dIvaIntMoratorio      = 0;
	LET dIvaIntMes            = 0;
	LET dSdoActIvaInt         = 0;
	LET dComPend              = 0;
	LET dIvaCom               = 0;
	LET dSdoRetenido          = 0;
	LET dSdoTotalLiq          = 0;
	LET dIvaIntDevengado      = 0;
	LET dIntDevengado         = 0;
	LET dLineaDisponible      = 0;
	LET dPagosVdos            = 0;
	LET cDescSitEspCte        = '';
	LET cSitCred              = '';
	LET cCausaCred            = 0;
	LET cDescBloqueoCta       = '';
	LET cDescCausaBloqueoCta  = '';
	LET cDescSitEspCred       = '';
	LET cSitCte               = '';
	LET cCausaCte             = 0;
	LET cDescStatusCred       = '';
	LET iIdUnidadProd         = 0;
	LET cCodCaract2           = '';
	LET cCodRet				  = '00000';


	
-- 	SP CONS_SDOS1
	let vcod_ret   = "000";
	let vcuenta    = pCuenta;
	let vnum_cte   = "";
	let vapell_pat = " ";
	let vapell_mat = " ";
	let vnombre1   = " ";
	let vnombre2   = " ";
	let vrazon_soc = " ";
	let vedo_cta   = "";
	let vsdo_disp  = 0 ;
	let vsdo_ret   = 0 ;
	let vsdo_ccc   = 0 ;
	let vsdo_disp_ccc = 0 ;
	let vsdo_cta   = 0 ;
	let vtipo_linea = " ";
	let vdescrip1 = "";
	let vdescrip2 = "";
	let vsdo_t1 =  0 ;
	let vsdo_cong  = 0 ;
	let vimp_chq_sbc = 0;
	let vusubloq = " ";
	let vfecbloq = "";
	let vnum_tarjeta = "";
	let vcta_clabe = "";
	
		
-- 	//////////////////////////////////////////////////////////////////////////


		
	--SET DEBUG FILE TO '/informix/sp_consultactasgralcheck2.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- INICIO DEL PROCEDIMIENTO
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','','','','','','','','','','','','','','';
			END IF;
		END EXCEPTION;		  

		IF NVL(pEmpresa,'') = '' THEN
			LET cCod_ret = '00001';
			LET iTipo = 20; 
			RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo,cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;	
		ELIF NVL(pNumCte,'') = '' AND (NVL(pCuenta,'') = '' AND NVL(pTarjeta,'') = '' AND NVL(pTipoCuenta,'') = '' ) THEN
			LET cCod_ret = '00001';
			LET iTipo = 20;
			RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo,cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;
		ELIF NVL(pTpo,'') = '' THEN
			LET cCod_ret = '00001';
			LET iTipo = 20;
			RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo,cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;
		ELIF NVL(pLimit,'') = '' THEN
			LET cCod_ret = '00001';
			LET iTipo = 20;
			RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo,cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;
		ELIF NVL(pEjecucion,'') = '' THEN
			LET cCod_ret = '00001';
			LET iTipo = 20;
	/* 		RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo,cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;
	ELIF NVL(pTipoCuenta,'') = '' THEN
			LET cCod_ret = '00001';
			LET iTipo = 20; */
			RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo,cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;
	ELSE
			IF pCuenta <> '' THEN
				SELECT num_cte,cuenta 
				INTO cNumCte,cCuenta 
				FROM bdicheq:"informix".sc_maechq 
				WHERE cuenta = pCuenta;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					SELECT numcte,num_credito 
					INTO cNumCte,cCuenta 
					FROM bdicred:"informix".sd_maecred 
					WHERE num_credito = pCuenta;
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						SELECT num_cte,cuenta
						INTO cNumCte,cCuenta 
						FROM bdinvers:"informix".sv_maeinv 
						WHERE empresa = "001"
						AND cuenta = pCuenta
						AND secuencia IS NOT NULL;
						
						IF dbinfo("sqlca.sqlerrd2") = 0 THEN
							SELECT numcte,num_credito 
							INTO cNumCte,cCuenta 
							FROM bdicred:"informix".sd_maecredcrd 
							WHERE num_credito = pCuenta;
							
							IF dbinfo("sqlca.sqlerrd2") = 0 THEN
								LET cCod_ret = '00100';
								LET iTipo = 12;
								RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo,cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;
							ELSE
								LET iSistema = 7;
							END IF;
						ELSE
							LET iSistema = 3;
						END IF;
					ELSE
						LET iSistema = 6;
					END IF;
				ELSE
					LET iSistema = 1;
				END IF;
				
			ELIF pTarjeta <> '' THEN
			
				SELECT numcte,cuenta
				INTO cNumCte,cCuenta 
				FROM bdicheq:"informix".sc_tarjeta 
				WHERE empresa = "001"
				AND num_tarjeta = pTarjeta
				AND status_tar = "A";
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					SELECT numcte,num_credito 
					INTO cNumCte,cCuenta 
					FROM bdicred:"informix".sd_tarjeta 
					WHERE num_tarjeta = pTarjeta
					AND status_tar = "A";
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						LET cCod_ret = '00100';
						LET iTipo = 6;
						RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo,cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;
					ELSE
						LET iSistema = 6;
					END IF;
					
				ELSE
					LET iSistema = 1;
				END IF;
				
			ELIF pNumCte <> '' THEN
				LET cNumCte = pNumCte;
						
			/* ELIF pTipoCuenta <> '' THEN
				LET tipo_sistema = pTipoCuenta; */
			END IF;
			
			SELECT numcte,apell_paterno,apell_materno,nombre1,nombre2,razon_social
			INTO cNumCte,cPaterno,cMaterno,cNombre1,cNombre2,cRazon
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = cNumCte;

			IF cNumCte IS NULL THEN
				LET cCod_ret = "00137";
				LET iTipo = 11;
				RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo,cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;
			END IF;

			IF (cRazon IS NULL) OR (TRIM(cRazon) = "") THEN
				LET cCompleto = TRIM(cNombre1)||" "||TRIM(cNombre2)||" "||TRIM(cPaterno)||" "||TRIM(cMaterno);
			ELSE
				LET cCompleto = cRazon;
			END IF;		

			LET iLimit = pLimit;
			LET sTipo = pTpo;
			LET iEjecucion = pEjecucion;
			

				-- *****************************************************************
				-- Extrae la informacion del Sistema de Cheques
				-- *****************************************************************
			IF iEjecucion = 0 THEN
				IF pNumCte <> '' OR iSistema = 1 THEN
					IF isistema = 1 THEN
						LET iLimit = 1;
						LEt sTipo = 0;
					END IF;
					LET tipo_sistema = pTipoCuenta;
					FOREACH
						SELECT skip sTipo LIMIT iLimit
						mc.cuenta,sucursal,mc.producto,pr.nombre,ps.sistema,mc.imp_cgos_mes, mc.imp_abonos_mes,
						CASE WHEN status_cta = "1" AND marca_ret = "0" THEN
								"Sin Deposito Inicial"
							WHEN status_cta = "1" AND marca_ret = "1" THEN
								"Activa"
							WHEN status_cta = "2" THEN
								"Cancelada" 
							WHEN status_cta = "3" THEN
								"Bloqueada"
							WHEN status_cta = "4" THEN
								"Inactiva"
							WHEN status_cta = "5" THEN
								"Informada"
							WHEN status_cta = "6" THEN
								"Concentrada"
							WHEN status_cta = "7" THEN
								"Traspasada"
							END
						INTO cCuenta,cSucursal,cCodigoProducto,cProducto,tipo_cuenta,cargo_mes,abono_mes,cEstatus
						FROM bdicheq:"informix".sc_maechq mc,
							 bdicheq:"informix".sc_producto pr,
							 bdinteg:"informix".si_productos_sistemas ps
							 
						WHERE num_cte = cNumCte 
						AND mc.empresa = "001"
						AND mc.cuenta = CASE WHEN iSistema <> 1 THEN mc.cuenta ELSE cCuenta END
						AND mc.producto = pr.producto 
						AND mc.producto = ps.producto
						AND pr.producto = pProducto
						AND sistema = pTipoCuenta
						ORDER BY cuenta 
						
						SELECT fecha_alta,fecha_mod
						INTO dFecha_alta,dFecha_venc
						FROM bdicheq:"informix".sc_maenoc
						WHERE empresa = "001" 
						AND cuenta = cCuenta;

						SELECT num_tarjeta
						INTO  cTarjeta
						FROM bdicheq:"informix".sc_tarjeta
						WHERE numcte = cNumCte
						AND cuenta = cCuenta 
						AND secuencia = (SELECT MAX(secuencia) FROM bdicheq:"informix".sc_tarjeta WHERE numcte = cNumCte  AND cuenta = cCuenta); 
						
						IF  cEstatus = "Cancelada" THEN
							SELECT NVL(fec_cancelac,"01/01/1900"), NVL(motivo, '') 
							INTO dFec_cancelo, cMotivo_cancelo 
							FROM bdicheq:"informix".sc_maechq 
							WHERE empresa = pEmpresa 
							AND cuenta = cCuenta;
							
							SELECT descripcion 
							INTO cDescMot_cancelo
							FROM bdicheq:"informix".sc_motivocancel
							WHERE clave = cMotivo_cancelo;
		   
							SELECT NVL(promotor_cancelo,''), NVL(folio_cancelacion,'') 
							INTO cPromotor_cancelo, cFolio_cancelo 
							FROM bdicheq:"informix".sc_ctacancelada
							WHERE empresa = pEmpresa 
							AND cuenta = cCuenta 
							AND folio_cancelacion > 0;
						ELSE
							--Se inicializan las variables cuando sea el estatus diferente de cancelada.
							LET dFec_cancelo      = DATE(1);
							LET cPromotor_cancelo = "";
							LET cMotivo_cancelo   = "";
							LET cFolio_cancelo    = "";
							LET cDescMot_cancelo   = ""; 
						Call bdicheq:"informix".cons_sdos1(pEmpresa,cCuenta,cTarjeta) 
						
						RETURNING vcod_ret,vcuenta,vnum_cte,vapell_pat,vapell_mat, vnombre1,vnombre2,vrazon_soc,vedo_cta,cSdo_disp,cSdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,vtipo_linea, vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc, vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe;
							
							
						END IF;
																																						
						LET iCantReg = iCantReg + 1;
						LET iSkip = iCantReg;
						
								
					
									
						RETURN cCod_ret, NVL(cCompleto,""),NVL(cCuenta,""),NVL(cTarjeta,""),NVL(cSucursal,""),NVL(cCodigoProducto,""),NVL(cProducto,""),NVL(dFecha_alta,DATE(1)) ,NVL(dFecha_venc, DATE(1)),NVL(cEstatus,""),NVL(cNumCte,""),iTipo,iSkip+sTipo,iEjecucion,NVL(dFec_cancelo,"01/01/1900"),NVL(cPromotor_cancelo,""),NVL(cDescMot_cancelo,""),NVL(cFolio_cancelo,""), NVL(cSdo_ret,""), NVL(cSdo_disp,""),NVL(abono_mes,""),NVL(cargo_mes,""),NVL(tipo_cuenta,"") WITH RESUME;												
					END FOREACH;
				END IF;	
			END IF;
			IF iCantReg < iLimit  THEN
				LET iLimit = iLimit - iCantReg;
				LET iCantReg = 0;
				IF isistema = 3 THEN
					LET iLimit = 1;
					LEt sTipo = 0;
				END IF;
				IF iEjecucion = 0 THEN
					LET sTipo = 0;
				END IF;
				IF iEjecucion in (0,1) THEN
					IF pNumCte <> '' OR iSistema = 3 THEN
						FOREACH
						-- *********************************************************************
						-- Extrae la informacion del Sistema de Inversiones
						-- *********************************************************************
						
							SELECT skip sTipo LIMIT iLimit
							   cuenta,mv.sucursal,mv.cod_instrum,pr.nombre,
							   mv.fecha_alta,fecha_venc, mv.capital,mv.sdo_retenido,ps.sistema,
							   NVL(DECODE(status_cta, "1","Activa","2","Cancelada"),'') AS estatus
							INTO cCuenta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,
							   dFecha_venc, cSdo_disp, cSdo_ret, tipo_cuenta, cEstatus
							FROM bdinvers:"informix".sv_maeinv mv,
								 bdinvers:"informix".sv_instrum pr,
	 							 bdinteg:"informix".si_productos_sistemas ps
							WHERE mv.num_cte = cNumCte
							AND mv.cod_instrum = pr.cod_instrum
							AND mv.cod_instrum = ps.producto
							AND mv.empresa = "001"
							AND mv.status_cta = "1"
							AND sistema = pTipoCuenta
							AND ps.producto = pProducto
							AND mv.cuenta = CASE WHEN iSistema <> 3 THEN mv.cuenta ELSE cCuenta END
							AND mv.secuencia IS NOT NULL
							
							ORDER BY mv.cuenta				

											
							LET dFec_cancelo      = DATE(1);
							LET cPromotor_cancelo = "";
							LET cMotivo_cancelo   = "";
							LET cFolio_cancelo    = "";
							LET cDescMot_cancelo   = "";
													
							LET iCantReg = iCantReg + 1;
							LET iSkip = iCantReg;
							LET iEjecucion = 1;

							RETURN cCod_ret, NVL(cCompleto,""),NVL(cCuenta,""),NVL(cTarjeta,""),NVL(cSucursal,""),NVL(cCodigoProducto,""),NVL(cProducto,""),NVL(dFecha_alta,DATE(1)) ,NVL(dFecha_venc, DATE(1)),NVL(cEstatus,""),NVL(cNumCte,""),iTipo,iSkip+sTipo,iEjecucion,NVL(dFec_cancelo,"01/01/1900"),NVL(cPromotor_cancelo,""),NVL(cDescMot_cancelo,""),NVL(cFolio_cancelo,""),NVL(cSdo_ret,""),NVL(cSdo_disp,""),NVL(abono_mes,""),NVL(cargo_mes,""),NVL(tipo_cuenta,"") WITH RESUME;
							
						END FOREACH;
					END IF;	
				END IF;
				IF iCantReg < iLimit  THEN
					LET iLimit = iLimit - iCantReg;
					LET iCantReg = 0;
					IF isistema = 6 THEN
						LET iLimit = 1;
						LEt sTipo = 0;
					END IF;
					IF iEjecucion = 1 THEN
						LET sTipo = 0;
					END IF;
					IF iEjecucion in (0,1,2) THEN
						IF pNumCte <> '' OR iSistema = 6 THEN
							FOREACH
						-- *********************************************************************
						-- Extrae la informacion del Sistema de Credito
						-- *********************************************************************

							SELECT skip sTipo LIMIT iLimit
							   mc.num_credito,sucursal,mc.num_producto,pr.nombre_prod,
							   fecha_apertura,fecha_vencim, tc.descripcion, mc.status_cred,ps.sistema
							INTO cCuenta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,
							   dFecha_venc,cEstatus,cStatusCred,tipo_cuenta

							FROM bdicred:"informix".sd_maecred mc,
							   bdicred:"informix".sd_definicion pr,
							   bdicred:"informix".sd_tipocartera tc,
							   bdinteg:"informix".si_productos_sistemas ps
							WHERE numcte = cNumCte 
							AND mc.num_credito = CASE WHEN iSistema <> 6 THEN mc.num_credito ELSE cCuenta END
							AND mc.num_producto = pr.num_producto
							AND mc.num_producto = ps.producto
							AND mc.status_cred = tc.status_cred
							AND sistema = pTipoCuenta
							AND ps.producto = pProducto
							ORDER BY 1
							
							SELECT num_tarjeta
							INTO cTarjeta
							FROM bdicred:"informix".sd_tarjeta
							WHERE numcte = cNumCte
							AND num_credito = cCuenta
							AND secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta WHERE numcte = cNumCte AND num_credito = cCuenta);  
													
							IF  TRIM(cStatusCred) = "FF" THEN
								SELECT NVL(fecha_can,"01/01/1900"), motivo_can, ejecutivo, folio_cancelacion 
								INTO  dFec_cancelo,cMotivo_cancelo,cPromotor_cancelo, cFolio_cancelo
								FROM bdicred:"informix".sd_cred_can
								WHERE num_credito = cCuenta
								AND folio_cancelacion <> '';
																
								SELECT descripcion
								INTO cDescMot_cancelo
								FROM bdicred:"informix". sd_cat_cancred
								WHERE codigo = TRIM(cMotivo_cancelo);
							ELSE
								LET dFec_cancelo      = DATE(1);
								LET cPromotor_cancelo = "";
								LET cMotivo_cancelo   = "";
								LET cFolio_cancelo    = "";								
								LET cDescMot_cancelo   = "";
							END IF;
	
							LET iCantReg = iCantReg + 1;
							LET iSkip = iCantReg;
							LET iEjecucion = 2;
							
							
							Call bdicred:"informix".sp_consulta_saldos_general(pEmpresa,cCuenta) -- se ejecuta consulta de saldos general para obtener saldo_actual y retenido
							RETURNING cCodRet, cMensajeRet, cNumCredito, cCodTipCred, dtFechaOrigen, dtFechaProxPago, dPagoMinimo, dtFechaUltPago, iPlazo, iPagosRealizados, dLineaOtorgada, dTasaInteres, dTasaMoratorios, dMontoSBC, dCapVig, dCapTrans, dCapVdoExig, dCapVdoNoExig, dSdoActCap, dIntVig, dIntVdo, dIntMoratorio, dIntMes, dSdoActInt, dIvaIntVig,dIvaIntVdo, dIvaIntMoratorio, dIvaIntMes, dSdoActIvaInt, dComPend, dIvaCom ,cSdo_disp, cSdo_ret,dIntDevengado, dIvaIntDevengado, dLineaDisponible, dPagosVdos, cDescStatusCred, iIdUnidadProd, cDescBloqueoCta, cCodCaract2,cDescCausaBloqueoCta, cSitCte, cCausaCte, cDescSitEspCte, cSitCred, cCausaCred, cDescSitEspCred;
							
							--FOREACH
                            Call bdicred:"informix".sp_cargo_abono_mes_tdc(pEmpresa,cCuenta) --se agregan abonos y cargo del mes para TDC
							RETURNING cod_ret,v_abono,v_cargo; -- v_abono -- v_cargo	
		                       
							--END FOREACH;
							IF cod_ret = "00000" THEN
							LET abono_mes = v_abono;
							LET cargo_mes = v_cargo;
							END IF;
							
							RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip+sTipo,iEjecucion, NVL(dFec_cancelo,"01/01/1900"),NVL(cPromotor_cancelo,""),NVL(cDescMot_cancelo,""),NVL(cFolio_cancelo,""),cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta WITH RESUME;
							
							END FOREACH;
						END IF;	
					END IF;	
					IF iCantReg < iLimit THEN
						LET iLimit = iLimit - iCantReg;
						LET iCantReg = 0;
						LET cTarjeta = "";
						IF isistema = 7 THEN
							LET iLimit = 1;
							LEt sTipo = 0;
						END IF;
						IF iEjecucion = 2 THEN
							LET sTipo = 0;
						END IF;
						-- **********************************************************************************
						-- Extrae la informacion del Sistema de Prestamo personal, credinomina y reestructura
						-- **********************************************************************************
						LET tipo_sistema = pTipoCuenta;

						IF pNumCte <> '' OR iSistema = 7 THEN
							FOREACH
								SELECT skip sTipo LIMIT iLimit
								   mcd.num_credito,mcd.sucursal,mcd.num_producto,df.nombre_prod,
								   mcd.fecha_apertura, mcd.fecha_vencim, tc.descripcion, ps.sistema
								INTO cCuenta,cSucursal,cCodigoProducto, cProducto,
								   dFecha_alta,dFecha_venc,cEstatus,tipo_cuenta
								FROM bdicred:"informix".sd_maecredcrd mcd,
								   bdicred:"informix".sd_definicion df,
								   bdicred:"informix".sd_tipocartera tc,
								   bdinteg:"informix".si_productos_sistemas ps
								WHERE numcte = cNumCte 
								AND mcd.num_producto = df.num_producto
								AND mcd.num_producto = ps.producto
								AND mcd.status_cred = tc.status_cred
                                --AND mcd.num_credito = cCuenta
								AND sistema = pTipoCuenta
								AND ps.producto = pProducto
								ORDER BY 1
								
				
							

							LET dFec_cancelo      = DATE(1);
							LET cPromotor_cancelo = "";
							LET cMotivo_cancelo   = "";
							LET cFolio_cancelo    = "";								
						    LET cDescMot_cancelo   = "";
							
							LET iCantReg = iCantReg + 1;
							LET iSkip = iCantReg;
							LET iEjecucion = 3;
							
							Call bdicred:"informix".sp_consulta_saldos_general(pEmpresa,cCuenta) 
							RETURNING cCodRet, cMensajeRet, cNumCredito, cCodTipCred, dtFechaOrigen, dtFechaProxPago, dPagoMinimo, dtFechaUltPago, iPlazo, iPagosRealizados, dLineaOtorgada, dTasaInteres, dTasaMoratorios, dMontoSBC, dCapVig, dCapTrans, dCapVdoExig, dCapVdoNoExig, dSdoActCap, dIntVig, dIntVdo, dIntMoratorio, dIntMes, dSdoActInt, dIvaIntVig, dIvaIntVdo, dIvaIntMoratorio, dIvaIntMes, dSdoActIvaInt, dComPend, dIvaCom ,cSdo_disp, cSdo_ret,dIntDevengado, dIvaIntDevengado, dLineaDisponible, dPagosVdos, cDescStatusCred, iIdUnidadProd, cDescBloqueoCta, cCodCaract2,cDescCausaBloqueoCta, cSitCte, cCausaCte, cDescSitEspCte, cSitCred, cCausaCred, cDescSitEspCred;
							--LET cSdo_disp = dSdoTotalLiq;
							--LET cSdo_ret = dSdoRetenido;
							Call bdicred:"informix".sp_abonoAct_credPlazos(pEmpresa, cCuenta)					
                            RETURNING CodRet, abono_mes;	
                             LET cargo_mes = 0;
				RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip+sTipo,iEjecucion,NVL(dFec_cancelo,"01/01/1900"),NVL(cPromotor_cancelo,""),NVL(cDescMot_cancelo,""),NVL(cFolio_cancelo,""),cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta WITH RESUME;
							END FOREACH;
						END IF;
					END IF;
				END IF;
			END IF;
			IF iSkip = 0 THEN
				LET cCod_ret = "00127";
				LET iTipo = 11;
				
								
				RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,NVL(dFec_cancelo,"01/01/1900"),NVL(cPromotor_cancelo,""),NVL(cDescMot_cancelo,""),NVL(cFolio_cancelo,""), cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;
			END IF;
		END IF;				
	END
END PROCEDURE             
DOCUMENT
"DESCRIPCION: Se agrega el saldo retenido, saldo disponible, abono_mes,cargo_mes,tipo_cuenta a la consulta general",
"REALIZÃÂ: Jorge Lara",
"FECHA: 03/Enero/2016",
"BD:          bdinteg";

CREATE PROCEDURE "informix".sp_adm_encript_borra(e_mac CHAR(20))  
returning char(5);

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    LET cod_ret  = "00000";

BEGIN
ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
           RETURN  cod_ret;
      END IF ;
   END EXCEPTION ;

SET LOCK MODE TO WAIT 4;

	IF NVL(e_mac,'') =='' THEN 
	 	  LET cod_ret = '00001'; -- No contiene Dato de MAC
                    RETURN  cod_ret;
	END IF;
	
	DELETE FROM bdinteg:"informix".adm_encryption
	WHERE mac_address = e_mac;

	RETURN  cod_ret;
END
END PROCEDURE;