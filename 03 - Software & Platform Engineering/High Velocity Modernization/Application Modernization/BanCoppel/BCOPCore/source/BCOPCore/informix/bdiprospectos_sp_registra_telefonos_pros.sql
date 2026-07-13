CREATE PROCEDURE "informix".sp_registra_telefonos_pros( pEmpresa     CHAR(3),
                                                        pNumCte      CHAR(20), 
                                                        pTelefono    CHAR(13),
                                                        pTipoTel     SMALLINT,
                                                        pExtension   CHAR(5),
                                                        pCarrier     SMALLINT,
                                                        pCanal       SMALLINT,
                                                        pUserInsert  CHAR(8) )
RETURNING CHAR(5) AS cCodRet1;
    
    DEFINE cCodRet1 		CHAR(5);
    DEFINE iSqlErr  		INTEGER;
    DEFINE iExisteCte       INTEGER;
    DEFINE iExisteCanal     INTEGER;
    DEFINE cCodRetValTel    CHAR(5);
    DEFINE cValCasa         CHAR(1);
    DEFINE cValCelular      CHAR(1);
    DEFINE cValOficina      CHAR(1);
    DEFINE cCofetel         CHAR(1);
    DEFINE iExisteCarrier   INTEGER;
    DEFINE dFechaInsert		DATE;
    DEFINE sMaxSecTel       SMALLINT;
    DEFINE sContacto        SMALLINT;
    DEFINE iSecMaxDir       INTEGER;
    DEFINE iExisteTelefono  INTEGER;
    DEFINE iFijoMovil  		INTEGER;
    DEFINE cDescFijoMovil  	CHAR(5);
    DEFINE cResulFijoMovil	CHAR(5);
    
    LET cCodRet1		= '000';
    LET iSqlErr			= 0;
    LET iExisteCte		= 0;
    LET iExisteCanal	= 0;
    LET cCodRetValTel	= '';
    LET cValCasa		= '';
    LET cValCelular		= '';
    LET cValOficina		= '';
    LET cCofetel		= '';
    LET iExisteCarrier	= 0;
    LET dFechaInsert	= '';
    LET sMaxSecTel		= 0;
    LET sContacto		= 0;
    LET iSecMaxDir		= 0;
    LET iExisteTelefono	= 0;
    LET iFijoMovil		= 0;
    LET cDescFijoMovil	= '';
    LET cResulFijoMovil	= '';
    
	
--SET DEBUG FILE TO "/respaldosbd/Leslie/sp_telefonos.out";
--TRACE ON;
	
    BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pEmpresa is null OR pEmpresa = '') OR (pNumCte is null OR pNumCte = '') OR
       (pTelefono is null OR pTelefono = '') OR (pTipoTel is null OR pTipoTel = 0) OR
       (pCarrier is null) OR (pCanal is null OR pCanal = 0) OR
       (pUserInsert is null OR pUserInsert = '') THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1;
    END IF;
    
    -- // VERIFICA SI EXISTE EL NUMERO DE CLIENTE
    SELECT COUNT(*)
      INTO iExisteCte
      FROM "informix".pr_cliente
     WHERE numcte_pros = pNumCte;
     
    IF iExisteCte = 0 THEN
        LET cCodRet1 = '104';
        RETURN cCodRet1;
    END IF;
    
    -- // VERIFICA SI EXISTE EL NUMERO PARA EL TIPO INDICADO
	
    SELECT COUNT(*)
      INTO iExisteTelefono
      FROM "informix".pr_telefonos
     WHERE numcte_pros = pNumCte
       AND tipo_tel = pTipoTel;
      -- AND telefono = pTelefono
	--   AND status_tel='A';
     
   /* IF iExisteTelefono > 0 THEN
       LET cCodRet1 = '999'; 
        RETURN cCodRet1;
    END IF;*/
    
    -- // VALIDA EL CANAL DE PROCEDENCIA
    SELECT COUNT(*)
      INTO iExisteCanal
      FROM bdinteg:"informix".si_canal
     WHERE cve_canal = pCanal;
     
    IF iExisteCanal = 0 THEN
        LET cCodRet1 = '104';
        RETURN cCodRet1;
    END IF;
    
    -- // VALIDA EL CARRIER PARA NUMEROS CELULARES
    IF pCarrier > 0 THEN
        SELECT COUNT(*)
          INTO iExisteCarrier
          FROM bdinteg:"informix".si_carriers
         WHERE cve_carrier = pCarrier;
         
        IF iExisteCarrier = 0 THEN
            LET cCodRet1 = '104';
            RETURN cCodRet1;
        END IF;
    END IF;
    
    -- // VALIDA SI EL TELEFONO ES VALIDO PARA COFETEL
    EXECUTE PROCEDURE bdinteg:"informix".sp_validatelefono(pEmpresa, pTelefono, pTelefono, pTelefono)
    INTO cCodRetValTel, cValCasa, cValCelular, cValOficina;
    
    IF cValCasa = '1' OR cValCelular = '1' OR cValOficina = '1' THEN
        LET cCofetel = 'V';
    ELSE
        LET cCofetel = 'F';
    END IF;
    
    -- // OBTIENE LA FECHA DEL SISTEMA
    SELECT fecha_hoy
      INTO dFechaInsert
      FROM bdinteg:"informix".si_fechas
     WHERE empresa = pEmpresa;
    
    -- // INSERTA EN TABLA DE TELEFONOS
    SELECT MAX(secuencia)
      INTO sMaxSecTel
      FROM "informix".pr_telefonos
     WHERE numcte_pros = pNumCte;
             
    IF sMaxSecTel is null OR sMaxSecTel = '' THEN
        LET sMaxSecTel = 0;
    END IF;
    
    LET sMaxSecTel = sMaxSecTel + 1;
    
    UPDATE "informix".pr_telefonos
       SET status_tel = 'C'
     WHERE numcte_pros = pNumCte
       AND tipo_tel = pTipoTel;
    
    -- // VERIFICA SI ES MOVIL O FIJO   
    EXECUTE PROCEDURE bdinteg:"informix".sp_tipored(pEmpresa, pTelefono) 
    INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil;
    
    IF cDescFijoMovil = 'FIJO' THEN
        LET iFijoMovil = 0;
    ELIF cDescFijoMovil = 'MOVIL' THEN
        LET iFijoMovil = 1;
    ELSE
        LET iFijoMovil = 0;
    END IF;
    IF iExisteTelefono=1 THEN
		UPDATE bdiprospectos:"informix".pr_telefonos
		SET telefono=pTelefono, extension=pExtension,status_tel='A'
		WHERE numcte_pros = pNumCte
        AND tipo_tel = pTipoTel
		AND secuencia=(SELECT MAX(secuencia)from bdiprospectos:"informix".pr_telefonos where numcte_pros=pNumCte
		AND tipo_tel = pTipoTel);
	ELSE 
    INSERT INTO "informix".pr_telefonos
    ( empresa, numcte_pros, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel )
    VALUES
    ( pEmpresa, pNumCte, pTelefono, pTipoTel, 'A', sMaxSecTel, pExtension, pCarrier, pCanal, sContacto, cCofetel, CURRENT, pUserInsert, iFijoMovil, '' );
    END IF;
    RETURN cCodRet1;
	
	END;
    
END PROCEDURE;