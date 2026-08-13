CREATE PROCEDURE "informix".sp_inserta_respuesta_club_web(
	pEmpresa 			CHAR(03),
	pSucursal 			CHAR(04),
	pNumCteBancoppel	CHAR(20),
	pNumCteCoppel		CHAR(20),
	pRespuesta			CHAR(01)
)

RETURNING
	CHAR(05) AS cCodRet;

--DECLARACIÃN DE VARIABLES
DEFINE iSql_err		INTEGER;
DEFINE cCodRet		CHAR(05);

--INICIALIZACIÃN DE VARIABLES
LET cCodRet = '00000';

--SET DEBUG FILE TO '/respaldosbd/Ernesto/out/sp_inserta_respuesta_club.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;

	--VALIDAR PARÃMETROS VACÃOS Y NULOS
	LET pEmpresa  			= TRIM(pEmpresa);
	LET pSucursal 			= TRIM(pSucursal);
	LET pNumCteBancoppel 	= TRIM(pNumCteBancoppel);
	LET pNumCteCoppel 		= TRIM(pNumCteCoppel);
	LET pRespuesta 			= TRIM(pRespuesta);
	
	IF NVL(pEmpresa, '') = '' OR NVL(pSucursal, '') = '' OR NVL(pNumCteBancoppel, '') = '' OR NVL(pNumCteCoppel, '') = '' OR NVL(pRespuesta, '') = '' THEN
		LET cCodRet = '00001';
		RETURN cCodRet;
	END IF;
	
	INSERT INTO "informix".si_club_bitacora(empresa, sucursal, numcte, numcte_coppel, respuesta, fecha)
	VALUES(pEmpresa, pSucursal, pNumCteBancoppel, pNumCteCoppel, pRespuesta, CURRENT);
	RETURN cCodRet;

END;
END PROCEDURE

DOCUMENT
'Inserta la respuesta en la tabla si_club_bitacora cuando el cliente contesta el cuestionario de salud cuando se le ofrece el Club de ProtecciÃ³n coppel',
'AUTOR : 95579737 - JosÃ© Ernesto Raygoza Villa',
'FECHA : --/--/2014-02',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_parentesco_club_web(
	pEmpresa CHAR(03)
)

RETURNING
	CHAR(05) AS cCodRet,
	CHAR(01) AS cParentesco,
	CHAR(30) AS cDescripcion;

--DECLARACIÃN DE VARIABLES
DEFINE iSql_err		INTEGER;
DEFINE cCodRet		CHAR(05);
DEFINE cParentesco	CHAR(01);
DEFINE cDescripcion CHAR(30);

--INICIALIZACIÃN DE VARIABLES
LET cCodRet			= '00000';
LET cParentesco		= '';
LEt cDescripcion	= '';

--SET DEBUG FILE TO '/respaldosbd/Ernesto/sp_error_trama_tf.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, cParentesco, cDescripcion;
		END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;

	--VALIDAR PARÃMETROS VACÃOS Y NULOS
	LET pEmpresa = TRIM(pEmpresa);
	
	IF NVL(pEmpresa, '') = '' THEN
		LET cCodRet = '00001';
		RETURN cCodRet, cParentesco, cDescripcion;
	END IF;
	
	FOREACH
		SELECT parentesco, descripcion
		INTO cParentesco, cDescripcion
		FROM "informix".si_club_parentesco
		WHERE empresa = pEmpresa
		RETURN cCodRet, cParentesco, cDescripcion WITH RESUME;
	END FOREACH;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00002';
		RETURN cCodRet, cParentesco, cDescripcion;
	END IF

END;
END PROCEDURE

DOCUMENT
'Retorna el catÃ¡logo de parentescos en la definiciÃ³n de los',
'beneficiarios de la pÃ³liza del club de protecciÃ³n.',
'AUTOR : 95579737 - JosÃ© Ernesto Raygoza Villa',
'FECHA : --/--/2014-06',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_permite_mensajes_cel_web( pNumCte CHAR(20) ) -- NO. CLIENTE
RETURNING CHAR(5), -- CODIGO DE RETORNO
          CHAR(1); -- INDICADOR DE MENSAJES
    
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vsms_cel     CHAR(1);
    DEFINE vExisteCte   INTEGER;
    
    LET vcodret1   = '00000';
    LET vcodret2   = '000';
    LET vcodret3   = '';
    LET sql_err	   = 0;
    LET isam_err   = 0;
    LET desc_err   = '';
    LET vsms_cel   = '';
    LET vExisteCte = 0;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_permite_mensajes_cel.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vsms_cel;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_permite_mensajes_cel.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF ( pNumCte is null OR pNumCte = '' ) THEN
        LET vcodret1 = '00110'; --- DATOS INSUFICIENTES
        RETURN vcodret1, vsms_cel;
    END IF;

    -- // VALIDA EXISTA NUMERO DE CLIENTE
    SELECT COUNT(*)
      INTO vExisteCte
      FROM bdinteg:"informix".si_ctepf
     WHERE numcte = pNumCte;

    IF vExisteCte = 0 THEN
        LET vcodret1 = '00104'; --- NO DE CLIENTE NO EXISTE
        RETURN vcodret1, vsms_cel;
    END IF;
    
    SELECT sms_cel
      INTO vsms_cel
      FROM bdinteg:"informix".si_ctepf
     WHERE numcte = pNumCte;
    
    IF vsms_cel is null OR vsms_cel = '' THEN
        LET vsms_cel = 'N';
    END IF;
    
    END; 
    
    RETURN vcodret1, vsms_cel;
    
END PROCEDURE;