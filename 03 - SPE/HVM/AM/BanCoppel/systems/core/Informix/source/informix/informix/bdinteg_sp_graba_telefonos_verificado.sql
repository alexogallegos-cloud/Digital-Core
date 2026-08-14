CREATE PROCEDURE "informix".sp_graba_telefonos_verificado(  pNumCte      CHAR(20),  -- NO. CLIENTE
														    pTelefono    CHAR(13),  -- TELEFONO
															pTipoTel     SMALLINT,  -- TIPO TELEFONO
															pExtension   CHAR(5),   -- EXTENSION
															pCarrier     SMALLINT,  -- CARRIER
															pCanal       SMALLINT,  -- CANAL
															pUserInsert  CHAR(8),   -- USUARIO
															pSucursal    CHAR(4),   -- Sucursal
															pVerificador CHAR(1))  -- Verificador de celular
RETURNING CHAR(5); -- CODIGO DE RETORNO
    
    DEFINE cCodret1  CHAR(5);
    DEFINE cCodret2  CHAR(5);
    DEFINE cCodret3  CHAR(50);
    DEFINE iSql_err  INTEGER;
    DEFINE iSam_err  INTEGER;
    DEFINE cDesc_err CHAR(50);
    
    DEFINE iExisteCte       INTEGER;
    DEFINE iExisteCanal     INTEGER;
    DEFINE cCofetel         CHAR(1);
    DEFINE iExisteCarrier   INTEGER;
    DEFINE dfecha_insert    DATE;
    DEFINE sMaxSecTel       SMALLINT;
    DEFINE sContacto        SMALLINT;
    DEFINE iExisteTelefono  INTEGER;
    DEFINE iTelInvalido     INTEGER;
	DEFINE cMovilFijo       CHAR(1);
    DEFINE cStatusTel       CHAR(1);
	DEFINE cVerificado      CHAR(1);
	DEFINE cMarcatel        CHAR(1);
	DEFINE dFechaActualiza  DATE; 
	DEFINE cTelConfirmado   CHAR(1);
	DEFINE dFechCconfirmado DATE;
	
	DEFINE cCodRetSp2  CHAR(5); --EPG 021621
	DEFINE celularCli  CHAR(13);
	DEFINE nrows       SMALLINT;    
    LET cCodret1  = '000';
    LET cCodret2  = '000';
    LET cCodret3  = '';
    LET iSql_err  = 0;
    LET iSam_err  = 0;
    LET cDesc_err = '';
    
    LET iExisteCte       = 0;
    LET iExisteCanal     = 0;
    LET cCofetel         = 'V';
    LET iExisteCarrier   = 0;
    LET dfecha_insert    = '';
    LET sMaxSecTel       = 0;
    LET sContacto        = 0;
    LET iExisteTelefono  = 0;
    LET iTelInvalido     = 0;
	LET cMovilFijo 	     = '0';
    LET cStatusTel 	     = '';
    LET cVerificado      = pVerificador;
	LET cMarcatel        = '';
	LET dFechaActualiza  = ''; 
	LET cTelConfirmado   = '';
	LET dFechCconfirmado = '';
	
    LET cCodRetSp2     = '00000'; --EPG 021621
	LET celularCli     = '';
	LET nrows          = 0;       --EPG 021621
    
    BEGIN
    
     ON EXCEPTION SET iSql_err, iSam_err, cDesc_err
        IF iSql_err <> 0 THEN
            LET cCodret1 = iSql_err;
            LET cCodret2 = iSam_err;
            LET cCodret3 = cDesc_err;
            RETURN cCodret1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/informix/tmp/sp_graba_telefonos_verificado.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pNumCte is null OR pNumCte = '') OR (pTelefono is null OR pTelefono = '') OR (pTipoTel is null OR pTipoTel = 0) OR (pCarrier is null) OR (pCanal is null OR pCanal = 0 ) OR
       (pUserInsert is null OR pUserInsert = '') OR (pVerificador is null OR pVerificador = '') THEN
        LET cCodret1 = '110'; -- DATOS INSUFICIENTES
        RETURN cCodret1;
    END IF;

    -- // VERIFICA SI EXISTE EL NUMERO DE CLIENTE
	SELECT COUNT(*)
	INTO iExisteCte
	FROM bdinteg:"informix".si_cliente
	WHERE numcte = pNumCte;
     
    IF iExisteCte = 0 THEN
        LET cCodret1 = '104'; -- NUM DE CLIENTE NO EXISTE
        RETURN cCodret1;
    END IF;
    
    -- // VERIFICA SI EXISTE EL NUMERO PARA EL TIPO INDICADO
	SELECT COUNT(*)
	INTO iExisteTelefono
	FROM bdinteg:"informix".si_telefonos_actual
	WHERE numcte = pNumCte
	AND tipo_tel = pTipoTel
	AND telefono = pTelefono
	AND carrier   = pCarrier
	AND extension = pExtension;
       
    IF iExisteTelefono > 0 THEN
        LET cCodret1 = '160'; -- TELEFONO EXISTE PARA TIPO INDICADO
        RETURN cCodret1;
    END IF;
    
    -- // VALIDA EL CANAL DE PROCEDENCIA
	SELECT COUNT(*)
	INTO iExisteCanal
	FROM bdinteg:"informix".si_canal
	WHERE cve_canal = pCanal;
     
    IF iExisteCanal = 0 THEN
        LET cCodret1 = '161'; -- CANAL DE PROCEDENCIA INVALIDO
        RETURN cCodret1;
    END IF;
    
    -- // VALIDA EL CARRIER PARA NUMEROS CELULARES
    IF pCarrier > 0 THEN
		SELECT COUNT(*)
		INTO iExisteCarrier
		FROM bdinteg:"informix".si_carriers
		WHERE cve_carrier = pCarrier;
         
        IF iExisteCarrier = 0 THEN
            LET cCodret1 = '162'; -- CARRIER DE CELULAR INVALIDO
            RETURN cCodret1;
        END IF;
    END IF;

    
	-- // VALIDA EL TELEFONO EN TABLA DE TELEFONOS INVALIDOS
	SELECT COUNT(*)
	INTO iTelInvalido
	FROM bdinteg:"informix".si_telefonos_invalidos
	WHERE telefono = pTelefono;
     
    IF iTelInvalido > 0 THEN
        LET cCodret1 = '164'; -- TELEFONO INVALIDO
        RETURN cCodret1;
    END IF;
	
    SELECT telefono  --Obtiene el numero viejo del celular del cliente --EPG 021621 
	INTO celularCli 
	FROM bdinteg:"informix".si_telefonos 
	WHERE numcte = pNumCte	AND tipo_tel='2' AND status_tel='A'; 
	
	LET nrows = dbinfo("sqlca.sqlerrd2");  --EPG 021621
    
    -- // OBTIENE LA FECHA DEL SISTEMA
	SELECT fecha_hoy
	INTO dfecha_insert
	FROM bdinteg:"informix".si_fechas
	WHERE empresa = '001';
    
    -- // INSERTA EN TABLA DE TELEFONOS
	SELECT MAX(secuencia)
	INTO sMaxSecTel
	FROM bdinteg:"informix".si_telefonos
	WHERE numcte = pNumCte;
             
    IF sMaxSecTel is null OR sMaxSecTel = '' THEN
        LET sMaxSecTel = 0;
    END IF;
    
    LET sMaxSecTel = sMaxSecTel + 1;
    
	UPDATE bdinteg:"informix".si_telefonos
	SET status_tel = 'C'
	WHERE numcte = pNumCte
	AND tipo_tel = pTipoTel;
    
    INSERT INTO bdinteg:"informix".si_telefonos
    (empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza, tel_confirmado, fech_confirmado)
    VALUES
    ('001', pNumCte, pTelefono, pTipoTel, 'A', sMaxSecTel, pExtension, pCarrier, pCanal, sContacto, cCofetel, current, pUserInsert, cMovilFijo, cStatusTel, cVerificado, cMarcatel, dFechaActualiza, cTelConfirmado, dFechCconfirmado);
    
	--INFORMAMOS ACTUALIZACION DE TELEFONO AL TELEFONO ACTUAL --EPG 021621
	EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CUB_SMS','SMS_TELCOR',TRIM(pNumCte),'','','1','','','','','','','','','','','',TRIM(pTelefono),1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
	--EXECUTE PROCEDURE "informix".sp_registra_evento( 'sp_graba_telefonos_verificado_cub', pTelefono,'Nuevo') INTO cCodRetSp2;
	
	IF (nrows > 0) THEN
		--INFORMAMOS ACTUALIZACION DE TELEFONO SI TIENE UN TELEFONO VIEJO
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CUB_SMS','SMS_TELCOR',TRIM(pNumCte),'','','1','','','','','','','','','','','',TRIM(celularCli),1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
		--EXECUTE PROCEDURE "informix".sp_registra_evento( 'sp_graba_telefonos_verificado_cub', celularCli,'Viejo') INTO cCodRetSp2;	
	END IF; --EPG 021621	
	
	SELECT COUNT(*)
	INTO iExisteCte
	FROM bdinteg:"informix".si_bitacora_tel
	WHERE numcte = pNumCte;
     
    IF iExisteCte = 0 THEN
        INSERT INTO bdinteg:"informix".si_bitacora_tel
        (numcte, ind_telefono, ind_correo, canal, sucursal, user_insert, fecha_oper)
        VALUES
        (pNumCte, '0', '0', pCanal, pSucursal, pUserInsert, CURRENT);
    ELSE 
        UPDATE bdinteg:"informix".si_bitacora_tel
           SET ind_telefono = '0',
               ind_correo   = '0',
               canal        = pCanal,
               sucursal     = pSucursal,
               user_insert  = pUserInsert,
               fecha_oper   = CURRENT
         WHERE numcte = pNumCte;
    END IF;
    
    END;
    
    RETURN cCodret1;
    
END PROCEDURE
DOCUMENT
'AUTOR: 96591307-Viridiana Paredes Romero',
'CENTRO: 230142',
'FOLIO: 289',
'DESCRIPCION: Se crea sp para grabar el numero de celular verificado',
'RQM: RQM 10 747-2 Adendum Actualizacion de Telefonos o Correo a Solicitud del Cliente en el CAT',
'FECHA: 14/Agosto/2017',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_graba_telefonos_web( pNumCte     CHAR(20),  -- NO. CLIENTE
                                                pTelefono   CHAR(13),  -- TELEFONO
                                                pTipoTel    SMALLINT,  -- TIPO TELEFONO
                                                pExtension  CHAR(5),   -- EXTENSION
                                                pCarrier    SMALLINT,  -- CARRIER
                                                pCanal      SMALLINT,  -- CANAL
                                                pUserInsert CHAR(8),   -- USUARIO
                                                pSucursal   CHAR(4) )  -- SUCURSAL
RETURNING CHAR(5); -- CODIGO DE RETORNO
    
    DEFINE vcodret1 CHAR(5);
    DEFINE vcodret2 CHAR(5);
    DEFINE vcodret3 CHAR(50);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
    
    DEFINE vExisteCte       INTEGER;
    DEFINE vExisteCanal     INTEGER;
    DEFINE vCodRetValTel    CHAR(5);
    DEFINE vValCasa         CHAR(1);
    DEFINE vValCelular      CHAR(1);
    DEFINE vValOficina      CHAR(1);
    DEFINE vCofetel         CHAR(1);
    DEFINE vExisteCarrier   INTEGER;
    DEFINE vfecha_insert    DATE;
    DEFINE vMaxSecTel       SMALLINT;
    DEFINE vContacto        SMALLINT;
    DEFINE vSecMaxDir       INTEGER;
    DEFINE vExisteTelefono  INTEGER;
    DEFINE vTelInvalido     INTEGER;
	DEFINE cMovilFijo       CHAR(1);
    DEFINE cStatusTel       CHAR(1);
	DEFINE vverificado      CHAR(1);
	DEFINE vmarcatel        CHAR(1);
	DEFINE vfecha_actualiza DATE; 
	DEFINE v_tel_confirmado CHAR(1);
	DEFINE vfech_confirmado DATE;
	
	DEFINE cCodRetSp2  CHAR(5);  --EPG 021621
	DEFINE celularCli  CHAR(13);
	DEFINE nrows       SMALLINT; --EPG 021621
    
    LET vcodret1 = '00000';
    LET vcodret2 = '000';
    LET vcodret3 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    
    LET vExisteCte       = 0;
    LET vExisteCanal     = 0;
    LET vCodRetValTel    = '';
    LET vValCasa         = '';
    LET vValCelular      = '';
    LET vValOficina      = '';
    LET vCofetel         = '';
    LET vExisteCarrier   = 0;
    LET vfecha_insert    = '';
    LET vMaxSecTel       = 0;
    LET vContacto        = 0;
    LET vSecMaxDir       = 0;
    LET vExisteTelefono  = 0;
    LET vTelInvalido     = 0;
	LET cMovilFijo 	     = '0';
    LET cStatusTel 	     = '';
    LET vverificado      = '';
	LET vmarcatel        = '';
	LET vfecha_actualiza = ''; 
	LET v_tel_confirmado = '';
	LET vfech_confirmado = '';
	
    LET cCodRetSp2     = '00000'; --EPG 021621
	LET celularCli     = '';
	LET nrows          = 0;       --EPG 021621
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_graba_telefonos.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_graba_telefonos.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF ( pNumCte is null OR pNumCte = '' ) OR
       ( pTelefono is null OR pTelefono = '' ) OR
       ( pTipoTel is null OR pTipoTel = 0 ) OR
       ( pCarrier is null ) OR
       ( pCanal is null OR pCanal = 0 ) OR
       ( pUserInsert is null OR pUserInsert = '' ) THEN
        LET vcodret1 = '00110'; -- DATOS INSUFICIENTES
        RETURN vcodret1;
    END IF;

    -- // VERIFICA SI EXISTE EL NUMERO DE CLIENTE
    SELECT COUNT(*)
      INTO vExisteCte
      FROM si_cliente
     WHERE numcte = pNumCte;
     
    IF vExisteCte = 0 THEN
        LET vcodret1 = '00104'; -- NUM DE CLIENTE NO EXISTE
        RETURN vcodret1;
    END IF;
    
    -- // VERIFICA SI EXISTE EL NUMERO PARA EL TIPO INDICADO
    SELECT COUNT(*)
      INTO vExisteTelefono
      FROM si_telefonos_actual
     WHERE numcte = pNumCte
       AND tipo_tel = pTipoTel
       AND telefono = pTelefono
       AND carrier   = pCarrier
       AND extension = pExtension;
       
    IF vExisteTelefono > 0 THEN
        LET vcodret1 = '00160'; -- TELEFONO EXISTE PARA TIPO INDICADO
        RETURN vcodret1;
    END IF;
    
    -- // VALIDA EL CANAL DE PROCEDENCIA
    SELECT COUNT(*)
      INTO vExisteCanal
      FROM si_canal
     WHERE cve_canal = pCanal;
     
    IF vExisteCanal = 0 THEN
        LET vcodret1 = '00161'; -- CANAL DE PROCEDENCIA INVALIDO
        RETURN vcodret1;
    END IF;
    
    -- // VALIDA EL CARRIER PARA NUMEROS CELULARES
    IF pCarrier > 0 THEN
        SELECT COUNT(*)
          INTO vExisteCarrier
          FROM si_carriers
         WHERE cve_carrier = pCarrier;
         
        IF vExisteCarrier = 0 THEN
            LET vcodret1 = '00162'; -- CARRIER DE CELULAR INVALIDO
            RETURN vcodret1;
        END IF;
    END IF;
    
    -- // VALIDA SI EL TELEFONO ES VALIDO PARA COFETEL
    EXECUTE PROCEDURE sp_validatelefono('001', pTelefono, pTelefono, pTelefono)
    INTO vCodRetValTel, vValCasa, vValCelular, vValOficina;
    
    IF vValCasa = '1' OR vValCelular = '1' OR vValOficina = '1' THEN
        LET vCofetel = 'V';
    ELSE
        --- LET vCofetel = 'F';
        LET vcodret1 = '00163'; -- TELEFONO NO VALIDO PARA COFETEL
        RETURN vcodret1;
    END IF; 
    
    -- // VALIDA EL TELEFONO EN TABLA DE TELEFONOS INVALIDOS
    SELECT COUNT(*)
      INTO vTelInvalido
      FROM si_telefonos_invalidos
     WHERE telefono = pTelefono;
     
    IF vTelInvalido > 0 THEN
        LET vcodret1 = '00164'; -- TELEFONO INVALIDO
        RETURN vcodret1;
    END IF;
	             
    SELECT telefono  --Obtiene el numero viejo del celular del cliente --EPG 021621 
	INTO celularCli 
	FROM bdinteg:"informix".si_telefonos 
	WHERE numcte = pNumCte	AND tipo_tel='2' AND status_tel='A'; 
	
	LET nrows = dbinfo("sqlca.sqlerrd2");  --EPG 021621
    
    -- // OBTIENE LA FECHA DEL SISTEMA
    SELECT fecha_hoy
      INTO vfecha_insert
      FROM si_fechas
     WHERE empresa = '001';
    
    -- // INSERTA EN TABLA DE TELEFONOS
    SELECT MAX(secuencia)
      INTO vMaxSecTel
      FROM si_telefonos
     WHERE numcte = pNumCte;
	
	IF vMaxSecTel is null OR vMaxSecTel = '' THEN
        LET vMaxSecTel = 0;
    END IF;
    
    LET vMaxSecTel = vMaxSecTel + 1;
    
    UPDATE si_telefonos
       SET status_tel = 'C'
     WHERE numcte = pNumCte
       AND tipo_tel = pTipoTel;
    
    INSERT INTO si_telefonos
    (empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza, tel_confirmado, fech_confirmado)
    VALUES
    ('001', pNumCte, pTelefono, pTipoTel, 'A', vMaxSecTel, pExtension, pCarrier, pCanal, vContacto, vCofetel, current, pUserInsert, cMovilFijo, cStatusTel, vverificado, vmarcatel, vfecha_actualiza, v_tel_confirmado, vfech_confirmado);
    
	--INFORMAMOS ACTUALIZACION DE TELEFONO AL TELEFONO ACTUAL --EPG 021621
	EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CUB_SMS','SMS_TELCOR',TRIM(pNumCte),'','','1','','','','','','','','','','','',TRIM(pTelefono),1,0,0,0,0,CURRENT,'') INTO cCodRetSp2; 
	--EXECUTE PROCEDURE "informix".sp_registra_evento( 'sp_graba_telefonos_web_cub', pTelefono,'Nuevo') INTO cCodRetSp2;
	
	IF (nrows > 0) THEN
		--INFORMAMOS ACTUALIZACION DE TELEFONO SI TIENE UN TELEFONO VIEJO
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CUB_SMS','SMS_TELCOR',TRIM(pNumCte),'','','1','','','','','','','','','','','',TRIM(celularCli),1,0,0,0,0,CURRENT,'') INTO cCodRetSp2; 
		--EXECUTE PROCEDURE "informix".sp_registra_evento( 'sp_graba_telefonos_web_cub', celularCli,'Viejo') INTO cCodRetSp2;
	END IF; --EPG 021621
	
    SELECT COUNT(*)
      INTO vExisteCte
      FROM si_bitacora_tel
     WHERE numcte = pNumCte;
     
    IF vExisteCte = 0 THEN
        INSERT INTO si_bitacora_tel
        ( numcte, ind_telefono, ind_correo, canal, sucursal, user_insert, fecha_oper )
        VALUES
        ( pNumCte, '0', '0', pCanal, pSucursal, pUserInsert, CURRENT );
    ELSE 
        UPDATE si_bitacora_tel
           SET ind_telefono = '0',
               ind_correo   = '0',
               canal        = pCanal,
               sucursal     = pSucursal,
               user_insert  = pUserInsert,
               fecha_oper   = CURRENT
         WHERE numcte = pNumCte;
    END IF;
    
    END;
    
    RETURN vcodret1;
    
END PROCEDURE;