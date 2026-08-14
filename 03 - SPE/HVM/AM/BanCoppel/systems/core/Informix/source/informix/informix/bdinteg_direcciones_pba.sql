CREATE PROCEDURE "informix".direcciones_pba( pEmpresa         CHAR(3),
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/direcciones_carrier.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET v_SqlErr, v_IsamErr, v_DescErr
        SET DEBUG FILE TO "/tmp/direcciones_carrier.err";
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
        IF pMunicipio = "" OR pMunicipio is null THEN
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
                CALL sp_registra_telefonos(pEmpresa, pNumCte, pTelefono2, vTipoTel, '', pCarrier, vCanal, pUser_Insert)
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

CREATE PROCEDURE "informix".sp_valrevtelefonos( pNumCte CHAR(20) ) 
RETURNING CHAR(5), CHAR(1), CHAR(1); 
    
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    
    DEFINE vRevision    INTEGER;
    DEFINE vFechaHoy    DATE;
    DEFINE vFechaIniMes DATE;
    DEFINE vIndTelefono CHAR(1);
    DEFINE vIndCorreo   CHAR(1);
    DEFINE vTelefono1   CHAR(13);
    DEFINE vTelefono2   CHAR(13);
    DEFINE vTelefono3   CHAR(13);
    DEFINE vTelefono4   CHAR(13);
    DEFINE vExisteCte   SMALLINT;
    
    LET vcodret1     = '000';
    LET vcodret2     = '';
    LET vcodret3     = '';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    
    LET vRevision    = 0;
    LET vFechaHoy    = '';
    LET vFechaIniMes = '';
    LET vIndTelefono = '0';
    LET vIndCorreo   = '0';
    LET vTelefono1   = '';
    LET vTelefono2   = '';
    LET vTelefono3   = '';
    LET vTelefono4   = '';
    LET vExisteCte   = 0;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_valrevtelefonos.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vIndTelefono, vIndCorreo;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_valrevtelefonos.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA ( DATOS INSUFICIENTES )
    IF ( pNumCte is null OR pNumCte = '' ) THEN
        LET vcodret1 = '110'; 
        RETURN vcodret1, vIndTelefono, vIndCorreo;
    END IF;
    
    SELECT fecha_hoy, pri_dia_mes
      INTO vFechaHoy, vFechaIniMes
      FROM si_fechas
     WHERE empresa = '001';
     
    SELECT valor::INTEGER
      INTO vRevision
      FROM si_param
     WHERE cod_param = 140;
     
    IF vRevision is null OR vRevision = 0 THEN
        
        LET vIndTelefono = '0';
        LET vIndCorreo   = '0';
        RETURN vcodret1, vIndTelefono, vIndCorreo;
        
    ELIF vRevision = 1 THEN
        
        SELECT COUNT(*)
          INTO vExisteCte
          FROM si_bitacora_tel
         WHERE numcte = pNumCte;
         
        IF vExisteCte = 0 THEN
            INSERT INTO si_bitacora_tel( numcte, ind_telefono, ind_correo, canal, sucursal, user_insert, fecha_oper )
            VALUES( pNumCte, '1', '1', 0, '0000', 'informix', CURRENT );
        ELSE
            SELECT COUNT(*)
              INTO vExisteCte
              FROM si_bitacora_tel
             WHERE numcte = pNumCte
               --- AND fecha_oper::date >= vFechaIniMes
               AND fecha_oper::date >= '01/01/'||YEAR(vFechaHoy)
               AND ( ind_telefono = '0' OR ind_correo = '0' );
               
            IF vExisteCte > 0 THEN
                LET vIndTelefono = '0';
                LET vIndCorreo   = '0';
                RETURN vcodret1, vIndTelefono, vIndCorreo;
            END IF;
        END IF;
    
        SELECT NVL(telefono, '')
          INTO vTelefono1
          FROM si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 1;
           
        SELECT NVL(telefono, '')
          INTO vTelefono2
          FROM si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 2;
           
        SELECT NVL(telefono, '')
          INTO vTelefono3
          FROM si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 3;
           
        SELECT NVL(telefono, '')
          INTO vTelefono4
          FROM si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 4;
        
        IF   ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '01' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '1' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '1' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '1' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '1' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '02' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '2' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '2' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '2' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '2' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '03' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '3' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '3' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '3' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '3' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '04' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '4' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '4' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '4' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '4' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '05' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '5' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '5' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '5' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '5' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '06' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '6' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '6' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '6' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '6' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '07' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '7' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '7' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '7' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '7' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '08' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '8' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '8' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '8' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '8' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '09' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '9' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '9' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '9' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '9' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') = '10' ) AND ( SUBSTR(vTelefono1,  LENGTH(vTelefono1)-0, 1) = '0' OR
                                                               SUBSTR(vTelefono2,  LENGTH(vTelefono2)-0, 1) = '0' OR
                                                               SUBSTR(vTelefono3,  LENGTH(vTelefono3)-0, 1) = '0' OR
                                                               SUBSTR(vTelefono4,  LENGTH(vTelefono4)-0, 1) = '0' ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        ELIF ( ( LPAD(MONTH(vFechaHoy), 2, '0') IN('11','12') ) AND ( (vTelefono1 is null OR vTelefono1 = '') OR
                                                                      (vTelefono2 is null OR vTelefono2 = '') OR
                                                                      (vTelefono3 is null OR vTelefono3 = '') OR
                                                                      (vTelefono4 is null OR vTelefono4 = '') ) ) THEN
            LET vIndTelefono = '1'; LET vIndCorreo = '1';
        END IF;
        
        UPDATE si_bitacora_tel
           SET ind_correo   = '0',
               ind_telefono = '0',
               fecha_oper   = CURRENT
         WHERE numcte = pNumCte;
    
    ELIF vRevision = 2 THEN
    
        SELECT COUNT(*)
          INTO vExisteCte
          FROM si_bitacora_tel
         WHERE numcte = pNumCte;
         
        IF vExisteCte = 0 THEN
            INSERT INTO si_bitacora_tel( numcte, ind_telefono, ind_correo, canal, sucursal, user_insert, fecha_oper )
            VALUES( pNumCte, '1', '1', 0, '0000', 'informix', CURRENT );
            
            LET vIndTelefono = '1';
            LET vIndCorreo   = '1';
        ELSE
            SELECT COUNT(*)
              INTO vExisteCte
              FROM si_bitacora_tel
             WHERE numcte = pNumCte
               --- AND fecha_oper::date >= vFechaIniMes
               AND fecha_oper::date >= '01/01/'||YEAR(vFechaHoy)
               AND ( ind_telefono = '0' OR ind_correo = '0' );
               
            IF vExisteCte > 0 THEN
                LET vIndTelefono = '0';
                LET vIndCorreo   = '0';
                RETURN vcodret1, vIndTelefono, vIndCorreo;
            ELSE
                LET vIndTelefono = '1';
                LET vIndCorreo   = '1';
            END IF;
        END IF;
        
        UPDATE si_bitacora_tel
           SET ind_correo   = '0',
               ind_telefono = '0',
               fecha_oper   = CURRENT
         WHERE numcte = pNumCte;
    
    END IF;
    
    END;
    
    RETURN vcodret1, vIndTelefono, vIndCorreo;
    
END PROCEDURE;