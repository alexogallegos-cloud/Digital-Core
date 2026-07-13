CREATE PROCEDURE "informix".consppes_n_web (pempresa char(3), pnumcte char(20), pnum_direc smallint)
            RETURNING CHAR(5), -- Codigo Retorno
                                     CHAR(3), -- Empresa
                                     CHAR(20), -- NumCte
                                     CHAR(1), -- Tipo_ppes
                                     CHAR(2), -- puesto_ppes
                                     CHAR(26), -- Apell_paterno
                                     CHAR(26), -- Apell_materno
                                     CHAR(26), -- Nombre1
                                     CHAR(26), -- Nombre2
                                     DECIMAL(14,2), --Participacion
                                     CHAR(80), -- Domicilio
                                     CHAR(20), -- Telefono
                                     CHAR(8), -- User_insert
                                     DATE, -- Fecha_insert
                                     INTEGER, -- NumeroRegistro
                                     CHAR(40); -- Asociacion_civil

-- Definicion de Variables
DEFINE vcodret CHAR(5);
DEFINE vciclo SMALLINT;
DEFINE vsqlerr INTEGER;
-- si_cteppes
DEFINE vempresa CHAR(3);
DEFINE vnumcte CHAR(20);
DEFINE vtipo_ppes CHAR(1);
DEFINE vpuesto_ppes  CHAR(2);
DEFINE vapell_paterno  CHAR(26);
DEFINE vapell_materno CHAR(26);
DEFINE vnombre1  CHAR(26);
DEFINE vnombre2  CHAR(26);
DEFINE vparticipacion DECIMAL(14,2);
DEFINE vdomicilio  CHAR(80);
DEFINE vtelefono  CHAR(20);
DEFINE vuser_insert CHAR(8);
DEFINE vfecha_insert DATE;
DEFINE vnumeroregistro  INTEGER ;
DEFINE vasociacioncivil CHAR(40);

-- Inicializacion de Variables
LET vciclo = 0;
LET vcodret = "00000";
LET  vsqlerr = 0;
-- si_cteppes
LET vempresa = "";
LET vnumcte = "";
LET vtipo_ppes = "";
LET vpuesto_ppes = "";
LET vapell_paterno = "";
LET vapell_materno = "";
LET vnombre1 = "";
LET vnombre2 = "";
LET vparticipacion = 0;
LET vdomicilio = "";
LET vtelefono = "";
LET vuser_insert = "";
LET vfecha_insert = "";
LET vnumeroregistro = 0;
LET vasociacioncivil = "";

   -- SET DEBUG FILE TO "/informix/JesusBueno/servicios/SpsModificados/consppes_n.out";
   -- TRACE ON;

BEGIN
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret,vempresa,vnumcte,vtipo_ppes,vpuesto_ppes,vapell_paterno,vapell_materno,vnombre1,vnombre2,
                            vparticipacion,vdomicilio,vtelefono,vuser_insert,vfecha_insert,vnumeroregistro,vasociacioncivil;
        END IF;
    END EXCEPTION;

    SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    FOREACH
        SELECT empresa, numcte,tipo_ppes,puesto_ppes,apell_paterno,apell_materno,nombre1,nombre2,
                        participacion,domicilio,telefono,user_insert,fecha_insert,numeroregistro,asociacion_civil
             INTO  vempresa,vnumcte,vtipo_ppes,vpuesto_ppes,vapell_paterno,vapell_materno,vnombre1,vnombre2,
                        vparticipacion,vdomicilio,vtelefono,vuser_insert,vfecha_insert,vnumeroregistro,vasociacioncivil
           FROM bdinteg:"informix".si_cteppes
        WHERE numcte = pnumcte AND empresa = pempresa
        ORDER BY numeroregistro
        
        LET vciclo = vciclo+1;
        
        IF vciclo <= pnum_direc THEN
            CONTINUE FOREACH;
        END IF
        
        RETURN vcodret,vempresa,vnumcte,vtipo_ppes,vpuesto_ppes,vapell_paterno,vapell_materno,vnombre1,vnombre2,
                        vparticipacion,vdomicilio,vtelefono,vuser_insert,vfecha_insert,vnumeroregistro,vasociacioncivil WITH RESUME;
	
    END FOREACH;
	
	IF vciclo = 0 THEN
		LET vcodret = '00001';
		 RETURN vcodret,vempresa,vnumcte,vtipo_ppes,vpuesto_ppes,vapell_paterno,vapell_materno,vnombre1,vnombre2,
                        vparticipacion,vdomicilio,vtelefono,vuser_insert,vfecha_insert,vnumeroregistro,vasociacioncivil;
		
	END IF 
END
END PROCEDURE
DOCUMENT
"Consulta de personas politicas",
"Autor : Daniela Viridiana Ramirez Perez",
"FECHA : 15/07/2011",
"BD    : bdinteg";

CREATE PROCEDURE "informix".direcciones_web( pEmpresa         CHAR(3),  
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

    DEFINE cCodRet             CHAR(5);
    DEFINE cCodRet2            CHAR(5);
    DEFINE cCodRet3            CHAR(50);
    DEFINE iSqlErr             INTEGER;
    DEFINE iIsamErr            INTEGER;
    DEFINE cDescErr            CHAR(50);
    DEFINE cNumCte             CHAR(20);
    DEFINE iCoincide_dir        SMALLINT;
    DEFINE cTipoDir         	CHAR(1);
    DEFINE cCalle            	CHAR(40);
    DEFINE cColonia         	CHAR(60);
    DEFINE cEntreCalles     	CHAR(40);
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
    DEFINE cSituacionEsp        CHAR(1);  --- VARIABLE DE SITUACION ESPECIAL
    DEFINE iCausa               INTEGER;  --- VARIABLE DE SITUACION ESPECIAL

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
    LET cSituacionEsp     = 'N'; --- VARIABLE DE SITUACION ESPECIAL
    LET iCausa            = 0;   --- VARIABLE DE SITUACION ESPECIAL

     --SET DEBUG FILE TO "/informix/tmp/direcciones.out";
     --TRACE ON;

    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        --SET DEBUG FILE TO "/tmp/direcciones.err";
        --TRACE ON;
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cDescErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    LET cCodRet = "00000";
    LET pEntidad = CAST( LPAD (TRIM(pEntidad), 2 ,  "0") AS CHAR(2));

    SELECT numcte 
      INTO cNumCte 
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = pNumCte;
     
    IF cNumCte IS NULL THEN
        LET cCodRet = "00104";
        RETURN cCodRet;
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

        -- // SE AGREGA VALIDACION PARA SI LA CLAVE DEL MUNICIPIO VIENE VACIO, LE ASIGNE  "00000".
        IF pMunicipio = "" OR pMunicipio is null  THEN
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
			LET cCodRet = "00001";
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
        
        -- // VALIDA LA INFORMACION DE LOS TELEFONOS DEL CLIENTE
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
                CALL bdinteg:"informix".sp_registra_telefonos(pEmpresa, pNumCte, pTelefono2, iTipoTel, '', 0, iCanal, pUser_Insert)
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
        
        -- // VALIDACION DE SITUACION ESPECIAL
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
        RETURN cCodRet;
    END IF;
    END;
END PROCEDURE;