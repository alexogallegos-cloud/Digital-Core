CREATE PROCEDURE "informix".sp_actualiza_curp(cNumCte CHAR(9), curpVal CHAR(18))

RETURNING CHAR(5) AS codret;

DEFINE vCodret CHAR (5);
DEFINE vSql_err INTEGER;
DEFINE vMensaje CHAR(100); 

LET vCodret  = '00000';
LET vSql_err = 0;

 BEGIN

     ON EXCEPTION SET vSql_err
        IF vSql_err <> 0 THEN
           LET vCodret = vSql_err;
           RETURN vCodret;
        END IF;
     END EXCEPTION;
     
     --SET DEBUG FILE TO "/tmp/sp_actualiza_curp.out";
     --TRACE ON;

     SET LOCK MODE TO WAIT 3;
     SET ISOLATION TO DIRTY READ;

     IF cNumCte is null or cNumCte ="" OR curpVal is null or curpVal ="" THEN 
        LET vCodret = '00002' ; -- Falta parametro de entrada
        RETURN vCodret;
     END IF;
	 
	 select trim(mensaje_resp) into vMensaje from si_bitacora_renapob where  numcte = cNumCte;
	
	  if vmensaje ='LA OPERACION SE EJECUTO.' then
	     UPDATE bdinteg:si_ctepf 
         SET curp = curpVal
         WHERE numcte = cNumCte;
	  end if;
	

     RETURN vCodret;
 END
END PROCEDURE
DOCUMENT
"Folio:			868",
"Proyecto:		Pre-evaluaciÃ³n de Solicitudes de CrÃ©dito (Complementaria - 4",
"Autor: 		98440021 - Veronica Rodriguez",
"Fecha: 		29/11/2022",
"Solicita:		Fernando Rojas",
"Descripcion:   Se crea sp para actualizar la curp del cliente cuando se valide ante renapo.",
"BD: 			bdinteg";

CREATE PROCEDURE "informix".direcciones_sms_tels( pEmpresa         CHAR(3),
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
    DEFINE o_tipo_dir           CHAR(1);
    DEFINE o_calle              CHAR(40);
    DEFINE o_colonia            CHAR(60);
    DEFINE o_entre_calles       CHAR(40);
    DEFINE o_pais               CHAR(3);
    DEFINE o_estado             CHAR(2);
    DEFINE o_ciudad             CHAR(3);
    DEFINE o_municipio          CHAR(5);
    DEFINE o_cod_postal         CHAR(5);
    DEFINE o_apart_postal       CHAR(11);
    DEFINE o_telefono1          CHAR(13);
    DEFINE o_telefono2          CHAR(13);
    DEFINE o_telefono3          CHAR(13);
    DEFINE o_extension          CHAR(5);
    DEFINE o_estado_inegi       CHAR(2);
    DEFINE o_municipio_inegi    CHAR(3);
    DEFINE o_localidad_inegi    CHAR(4);
    DEFINE o_numerociudad       SMALLINT;
    DEFINE o_numeroextcalle     CHAR(10);
    DEFINE o_numerointcalle     CHAR(10);
    DEFINE o_departamento       CHAR(6);
    DEFINE o_numerocalle        INTEGER;
    DEFINE o_numerocolonia      INTEGER;
    DEFINE o_puntocardinal      CHAR(1);
    DEFINE o_unidadhabitac      CHAR(1);
    DEFINE o_manzana            SMALLINT;
    DEFINE o_otros              SMALLINT;
    DEFINE o_andador            SMALLINT;
    DEFINE o_etapa              SMALLINT;
    DEFINE o_lote               SMALLINT;
    DEFINE o_edificio           SMALLINT;
    DEFINE o_entrada            SMALLINT;
    DEFINE o_observaciones      CHAR(80);
    DEFINE v_CodRetTel          CHAR(5);
    DEFINE vTipoTel             SMALLINT;
    DEFINE vCanal               SMALLINT;
    DEFINE cSituacionEsp        CHAR(1);  --- VARIABLE DE SITUACIÃ?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã??N ESPECIAL
    DEFINE iCausa               INTEGER;  --- VARIABLE DE SITUACIÃ?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã??N ESPECIAL

        DEFINE correoCli            CHAR(100);   --vero
        DEFINE nomEstadoV           CHAR(50);
        DEFINE nomCiudadV           CHAR(50);
        DEFINE nomCalleV            CHAR(50);
        DEFINE nomEstadoN           CHAR(50);
        DEFINE nomCiudadN           CHAR(50);
        DEFINE nomCalleN            CHAR(50);
        DEFINE cCodRetSp1           CHAR(5);
        DEFINE cCodRetSp2           CHAR(5);

		DEFINE sFuncionIni			CHAR(1);	--RAEF
		DEFINE sSecuenciaIni		SMALLINT;

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
    LET cSituacionEsp     = 'N'; --- VARIABLE DE SITUACIÃ?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã??N ESPECIAL
    LET iCausa            = 0;   --- VARIABLE DE SITUACIÃ?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã??N ESPECIAL

        LET correoCli         ='';
        LET nomEstadoV        ='';
        LET nomCiudadV        ='';
        LET nomCalleV         ='';
        LET nomEstadoN        ='';
        LET nomCiudadN        ='';
        LET nomCalleN         ='';
        LET cCodRetSp1        ='00000';
        LET cCodRetSp2        ='00000';

		LET sFuncionIni		  = pFuncion;	-- RAEF
		LET sSecuenciaIni	  = pSecuencia;

    --SET DEBUG FILE TO "/informix/LIP/direcciones_sms.out";
        --TRACE ON;

    --SET DEBUG FILE TO "/pisa/pisabanco/direcciones_sms_tels.out";
    --TRACE ON;
	
    BEGIN

    ON EXCEPTION SET v_SqlErr, v_IsamErr, v_DescErr
        --SET DEBUG FILE TO "/tmp/direcciones_carrier.err";
        --TRACE ON;
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
      FROM "informix".si_cliente
     WHERE numcte = pNumCte;

    IF v_NumCte IS NULL THEN
        LET v_CodRet = "104";
        RETURN v_CodRet;
    END IF

    IF pFuncion = "C" THEN
	
		LET sFuncionIni = pFuncion;		-- RAEF		
		
        DELETE FROM "informix".si_direcciones
          WHERE numcte = pNumCte
           AND secuencia = pSecuencia;

        DELETE FROM "informix".si_direcciones_actual
          WHERE numcte = pNumCte
           AND secuencia = pSecuencia;

        LET pFuncion = "A";
    END IF

    IF pFuncion = "A" THEN
	
		IF sFuncionIni = "A" THEN --RAEF: solo si es una nueva direccion busca una secuencia nueva
                -- // CGP SE TOMA LA SECUENCIA DE LA TABLA MAESTRA si_direcciones
			SELECT MAX(secuencia)
			  INTO pSecuencia
			  FROM "informix".si_direcciones
			 WHERE numcte = pNumCte;
		ELSE
			-- RAEF: usa como base la secuencia que traes como parametro desde el inicio en  pSecuencia y que guardamos en sSecuenciaIni
			IF sSecuenciaIni<>"0" THEN
				LET pSecuencia = sSecuenciaIni - 1;
			END IF;
		END IF;

        IF pSecuencia IS NULL THEN
            LET pSecuencia = 1;
        ELSE
            LET pSecuencia = pSecuencia + 1;
            LET cSituacionEsp = 'S';
        END IF;

        -- // SE AGREGA VALIDACIÃ?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã??N PARA SI LA CLAVE DEL MUNICIPIO VIENE VACIO, LE ASIGNE  "00000".
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
          FROM "informix".si_direcciones_actual
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
            INSERT INTO "informix".si_direcciones
            ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
              estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle,
              departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros,
              andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )
            VALUES
            ( pNumCte, pSecuencia, pTipoDir, pCalle, pColonia, pEntre_Calles, pPais, pEntidad, pLocalidad, pMunicipio, pCodPostal, "",
              pEstado_Inegi, pMunicipio_Inegi, pLocalidad_Inegi, pNoCiudad, pNoExt, pNoInt,
              pDepto, pNoCalle, pNoColonia, pPuntoCar, pUniHabi, pManz, pPOtros,
              pAndador, pEtapa, pLote, pEdif, pEntrada, pObserva, pUser_Insert, pFecha_Insert );


                        SELECT correo_elec --Obtiene el correo del cliente
                        INTO correoCli
                        FROM bdinteg:"informix".si_correos
                        WHERE numcte=pNumCte AND tipo_correo=1 AND status_correo='A';
                        IF (correoCli <> '') OR (pTelefono2 <> '') THEN
                                IF (pSecuencia > 1 AND pTipoDir = 1) THEN
                                        SELECT est.nombre , ciu.nombre, ccall.nombrecalle
                                        INTO nomEstadoV , nomCiudadV, nomCalleV
                                        FROM bdinteg:"informix".si_estados est, bdinteg:"informix".si_ciudades ciu, bdinteg:"informix".si_catcalles ccall
                                        WHERE ciu.pais = o_pais AND est.estado = o_estado AND ciu.estado = o_estado AND ciu.ciudad = o_ciudad AND ccall.numerocalle = o_numerocalle;

                                        SELECT est.nombre , ciu.nombre, ccall.nombrecalle
                                        INTO nomEstadoN , nomCiudadN, nomCalleN
                                        FROM bdinteg:"informix".si_estados est, bdinteg:"informix".si_ciudades ciu, bdinteg:"informix".si_catcalles ccall
                                        WHERE ciu.pais = pPais and est.estado = pEntidad AND ciu.estado = pEntidad AND ciu.ciudad = pLocalidad AND ccall.numerocalle = pNoCalle;

                                        IF correoCli <> '' THEN
                                                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','NOT_ACT_DOM',TRIM(pNumCte),'','','1',TRIM(nomEstadoV),TRIM(nomEstadoN),
                                                TRIM(nomCiudadV),TRIM(nomCiudadN),TRIM(nomCalleV)||' '|| TRIM(o_numeroextcalle) ||' '|| TRIM(o_numerointcalle),
                                                TRIM(nomCalleN) ||' '|| TRIM(pNoExt) ||' '|| TRIM(pNoInt),'','','','',TRIM(correoCli),'',1,0,0,0,0,CURRENT,'') INTO cCodRetSp1;
                                        ELSE
                                                IF pTelefono2 <> '' THEN
                                                        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CUB_SMS','SMS_DOM',TRIM(pNumCte),'','','1','','','','','','','','','','','',TRIM(pTelefono2),1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
                                                END IF;
                                        END IF;
                                END IF;
                        END IF;
        END IF;

        -- // VALIDA LA INFORMACIÃ?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã??N DE LOS TELEFONOS DEL CLIENTE
        SELECT telefono
          INTO o_telefono1
          FROM "informix".si_telefonos_actual
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


                                --CALL "informix".sp_registra_telefonos(pEmpresa, pNumCte, pTelefono1, vTipoTel, '', 0, vCanal, pUser_Insert) RETURNING v_CodRetTel;
                                CALL "informix".sp_registra_telefonos_tels(pEmpresa, pNumCte, pTelefono1, vTipoTel, '', 0, vCanal, pUser_Insert) RETURNING v_CodRetTel;
                                IF  v_CodRetTel <> 0 THEN --SE AGREGA VALIDACION PARA FOLIO 377
                                        RETURN v_CodRetTel;
                                END IF;


            END IF;
        END IF;

        SELECT telefono
          INTO o_telefono2
          FROM "informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 2;


                IF o_telefono2 is null THEN
                        LET o_telefono2 = ' ';
                END IF;

                IF o_telefono2 <> pTelefono2 THEN
                        IF cSucursal = '5002' THEN
                                LET vCanal = 12;
                        END IF;
                        --TRACE ON;

                        IF ( ( pTipoTel2 is not null AND pTipoTel2 <> '' ) AND ( pTelefono2 is not null AND pTelefono2 <> '' ) ) THEN
                                LET vTipoTel = 2;
                                --CALL "informix".sp_registra_telefonos(pEmpresa, pNumCte, pTelefono2, vTipoTel, '', pCarrier, vCanal, pUser_Insert) RETURNING v_CodRetTel;
                                CALL "informix".sp_registra_telefonos_tels(pEmpresa, pNumCte, pTelefono2, vTipoTel, '', pCarrier, vCanal, pUser_Insert) RETURNING v_CodRetTel;
                                IF  v_CodRetTel <> 0 THEN --SE AGREGA VALIDACION PARA FOLIO 377
                                        RETURN v_CodRetTel;
                                END IF;
                        END IF;
                ELSE --SE AGREGA VALIDACION PARA FOLIO 377
                        IF ( ( pTipoTel2 is not null AND pTipoTel2 <> '' ) AND ( pTelefono2 is not null AND pTelefono2 <> '' ) ) THEN
                                LET vTipoTel = 2;
                                --CALL "informix".sp_registra_telefonos(pEmpresa, pNumCte, pTelefono2, vTipoTel, '', pCarrier, vCanal, pUser_Insert) RETURNING v_CodRetTel;
                                CALL "informix".sp_registra_telefonos_tels(pEmpresa, pNumCte, pTelefono2, vTipoTel, '', pCarrier, vCanal, pUser_Insert) RETURNING v_CodRetTel;
                                IF  v_CodRetTel <> 0 THEN --SE AGREGA VALIDACION PARA FOLIO 377
                                        RETURN v_CodRetTel;
                                END IF;
                        END IF;
                END IF;


        SELECT telefono, extension
          INTO o_telefono3, o_extension
          FROM "informix".si_telefonos_actual
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


                                --CALL "informix".sp_registra_telefonos(pEmpresa, pNumCte, pTelefono3, vTipoTel, pExtension, 0, vCanal, pUser_Insert) RETURNING v_CodRetTel;
                                CALL "informix".sp_registra_telefonos_tels(pEmpresa, pNumCte, pTelefono3, vTipoTel, pExtension, 0, vCanal, pUser_Insert) RETURNING v_CodRetTel;
                                IF  v_CodRetTel <> 0 THEN --SE AGREGA VALIDACION PARA FOLIO 377
                                        RETURN v_CodRetTel;
                                END IF;


            END IF;

        END IF;

        -- // VALIDACIÃ?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã??N DE SITUACIÃ?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã?Ã??N ESPECIAL
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

        RETURN v_CodRetTel;
    END IF;

    END;

END PROCEDURE

DOCUMENT
"Alta de direcciones del cliente",
"Autor : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Manuel HernÃ?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Hector BojÃ?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â³rquez",
"FECHA : 17/Junio/2009",
"MODIFICACION: En la actualizaciÃ?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â³n de domicilios se identifica si el cliente",
"              tiene una situaciÃ?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â³n especial L, de ser asi lo desmarca",
"Ver.  : 1.2",
"MODIFICO : Frank Gaxiola Gaxiola",
"FECHA : 28/Octubre/2009",
"MODIFICACION: Se quita funcionalidad de desmarcaje L, solicitado por Alfonso",
"              VelÃ?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â¡zquez",
"Ver.  : 1.3",
"MODIFICO : Rodolfo Tortolero Varela",
"FECHA : 06/Abril/2010",
"MODIFICACION: Se implementa validaciÃ?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â³n para formatear el campo municipio con",
"                             0 cuando este sea vacio o null, para que no inserte nuevo registro.",
"solicitado por Daniel Zambada",
"Ver.  : 1.4",
"MODIFICO : Rodolfo GÃ?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â³mez HernÃ?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â¡ndez",
"FECHA : Mayo/2010",
"MODIFICACION: Se optimiza sp guardando la direcciÃ?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â³n del cliente en variables",
"              para la comparaciÃ?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â³n si hay algÃ?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Âºn cambio en la direcciÃ?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â³n del cliente",
"Ver.  : 1.5",
"MODIFICO : Marco A. Campos",
"FECHA: 08-Ago-2011",
"MODIFICACION: Reactivar funcionalidad de desmarcaje situaciÃ?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â?Ã?Â³n especial L.",
"solicitado por Fernando Rojas",
"Ver.  : 1.6",
"MODIFICO : Romel A. Evans F.",
"FECHA : Marzo/2023",
"MODIFICACION: Se habilita nuevamente los delet+e en el tipo de funcionalidad C para actualizar las direcciones de clientes que tienen los campos de calle y colonia vacios";

CREATE PROCEDURE "informix".sp_cancela_telefonos_cte(
	pEmpresa     CHAR(3),
    pNumCte      CHAR(20), 
    pTelefono    CHAR(13),
    pTipoTel     SMALLINT)
	
	RETURNING CHAR(5) AS cCodRet1;
    
	--DEFINICION DE VARIABLES
    DEFINE cCodRet1 	    CHAR(5);
    DEFINE cCodRet2 		CHAR(5);
    DEFINE cCodRet3 		CHAR(50);
    DEFINE iSqlErr  		INTEGER;
    DEFINE iSamErr  		INTEGER;
    DEFINE cDesErr  		CHAR(50);
	DEFINE iOtroTipoTel     SMALLINT;
	DEFINE vSecuencia		SMALLINT;		
	
	--INICIALIZA VARIABLES
    LET cCodRet1		 = '000';
    LET cCodRet2		 = '';
    LET cCodRet3		 = '';
    LET iSqlErr			 = 0;
    LET iSamErr			 = 0;
    LET cDesErr			 = '';
	LET iOtroTipoTel	 = 0;
	LET vSecuencia		 ='0';
	
	--SET DEBUG FILE TO "/pisa/pisabanco/sp_cancela_telefonos_cte.out";
	--TRACE ON;
	
    BEGIN
	    
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_registra_telefonos.err";
        --TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;
    		
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pEmpresa is null OR pEmpresa = '') OR (pNumCte is null OR pNumCte = '') OR
       (pTelefono is null OR pTelefono = '') OR (pTipoTel is null OR pTipoTel = 0) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1;
    END IF;
    
    -- // VERIFICA SI EXISTE EL NUMERO PARA OTRO TIPO DE TELEFONO PARA EL MISMO CLIENTE
    
	--Valida que el numero en cuestion no este registrado para ese cliente, pero con otro tipo de telefono
	IF pTipoTel IN (1, 2) THEN					   
		--SELECT COUNT(*)
		SELECT tipo_tel
		INTO iOtroTipoTel
		FROM "informix".si_telefonos
		WHERE numcte = pNumCte
		AND telefono = pTelefono
		AND tipo_tel != pTipoTel
		AND status_tel = 'A'
		AND tipo_tel IN (1,2)
		;

		IF iOtroTipoTel is null OR iOtroTipoTel = '' THEN
			LET cCodRet1 = '110';
			RETURN cCodRet1;
		END IF;

		SELECT secuencia INTO vSecuencia FROM bdinteg:"informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel=iOtroTipoTel AND status_tel = 'A' AND numcte = pNumCte;
	
		UPDATE "informix".si_telefonos
		   SET status_tel = 'C',
			fecha_actualiza = CURRENT::DATE		   
		 WHERE telefono = pTelefono
		   AND tipo_tel = iOtroTipoTel
		   AND status_tel = 'A'
		   AND secuencia = vSecuencia
		   AND numcte = pNumCte;


		SELECT secuencia INTO vSecuencia FROM bdinteg:"informix".si_telefonos_actual WHERE telefono=pTelefono AND tipo_tel=iOtroTipoTel AND status_tel = 'A' AND numcte = pNumCte;
			
		DELETE bdinteg:"informix".si_telefonos_actual
		WHERE telefono=pTelefono
		AND tipo_tel=iOtroTipoTel
		AND status_tel = 'A'
		AND secuencia = vSecuencia
		AND numcte = pNumCte;
		   
	ELSE
		LET cCodRet1 = '000';
	END IF;
	
    RETURN cCodRet1;
	
	END;
    
END PROCEDURE

DOCUMENT
'Modifico: Angeles Pérez',
'Fecha: 04/10/2024',
'BDD: bdinteg',
"Descripcion: Se cancela el telefono que tiene registrado el cliente con otro tipo de telefono";

CREATE PROCEDURE "informix".sp_valida_cel_repetido_tels(pNumCel CHAR(10), pNumCte CHAR(9), pSucursal CHAR(5))
RETURNING CHAR(5) as Cod_Ret, INTEGER as Repetidos;

DEFINE sCodRet		CHAR(5);
DEFINE iCantRep     INTEGER;
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE iDias        INTEGER;
DEFINE iValidaDiasTu    INTEGER;
DEFINE sTelefonoAct CHAR(13);
--TEls
DEFINE sNumcte 		CHAR(9);
--DEFINE sStatus_tel	CHAR(1);
DEFINE CodRet		CHAR(5);
DEFINE sTipoCte		CHAR(1);
DEFINE sSecuencia	CHAR(3);

LET sCodRet     =   '00000';
LET iCantRep    =   0;
LET iSqlErr		=   0;
LET iSamErr     =   0;
LET iDias       =   0;
LET iValidaDiasTu    = 0;
LET sTelefonoAct     = 0;
--TEls
LET sNumcte			= '';
--LET sStatus_tel		= '';
LET CodRet			= '00000';
LET sTipoCte		= '';
LET sSecuencia		= '';

BEGIN
    ON EXCEPTION SET iSqlErr 
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet, iCantRep;
        END IF;
    END EXCEPTION; 	
 
--SET DEBUG FILE TO '/informix/LMendoza/sp_valida_cel_repetido.out';
--SET DEBUG FILE TO '/pisa/pisabanco/sp_valida_cel_repetido_tels.out';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;  
    SET LOCK MODE TO WAIT 3;
	
	SELECT telefono INTO sTelefonoAct FROM bdinteg:"informix".si_telefonos_actual WHERE numcte=pNumCte AND tipo_tel=2;
		IF (TRIM(sTelefonoAct) == TRIM(pNumCel)) THEN RETURN sCodRet, iCantRep;
			END IF;
	
	--Se cosulta el tipo de cliente que tiene el telefono celular
	SELECT first 1 numcte INTO sNumcte FROM bdinteg:"informix".si_telefonos 
		WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel = 'A' AND verificado='V';
	
	EXECUTE PROCEDURE bdinteg:cons_tipo_cte('001',sNumcte)
		   INTO CodRet, sTipoCte, sSecuencia;
	
	SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='543';

/*	RQM 10 1768 Mantto tels
	SELECT COUNT(*) INTO iCantRep FROM bdinteg:"informix".si_telefonos 
	WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel IN ('A','C') AND verificado='V'	AND ((DATE(CURRENT) - DATE(fecha_hora) < iValidaDiasTu) OR (DATE(CURRENT) - DATE(fecha_actualiza) < iValidaDiasTu));

	IF iCantRep>=1 THEN
		LET sCodRet='288';
	END IF;
	
*/
	--Se identifica si el cliente es titular, aplica la regla de los 30 dÃ­as, de lo contrario puede registrar el celular del prospecto
	IF sTipoCte = '1' THEN
		SELECT COUNT(*) INTO iCantRep FROM bdinteg:"informix".si_telefonos 
		WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel = 'A' AND verificado='V'	AND ((DATE(CURRENT) - DATE(fecha_hora) < iValidaDiasTu) OR (DATE(CURRENT) - DATE(fecha_actualiza) < iValidaDiasTu));
		
		IF iCantRep>=1 THEN
			LET sCodRet='288';
		END IF;
	END IF;

	
RETURN sCodRet, iCantRep;

END
END PROCEDURE;