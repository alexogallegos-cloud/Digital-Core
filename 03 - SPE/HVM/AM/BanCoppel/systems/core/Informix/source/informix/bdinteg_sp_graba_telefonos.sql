CREATE PROCEDURE "informix".sp_graba_telefonos( pNumCte     CHAR(20),  -- NO. CLIENTE
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
    
    LET vcodret1 = '000';
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
        LET vcodret1 = '110'; -- DATOS INSUFICIENTES
        RETURN vcodret1;
    END IF;

    -- // VERIFICA SI EXISTE EL NUMERO DE CLIENTE
    SELECT COUNT(*)
      INTO vExisteCte
      FROM si_cliente
     WHERE numcte = pNumCte;
     
    IF vExisteCte = 0 THEN
        LET vcodret1 = '104'; -- NUM DE CLIENTE NO EXISTE
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
        LET vcodret1 = '160'; -- TELEFONO EXISTE PARA TIPO INDICADO
        RETURN vcodret1;
    END IF;
    
    -- // VALIDA EL CANAL DE PROCEDENCIA
    SELECT COUNT(*)
      INTO vExisteCanal
      FROM si_canal
     WHERE cve_canal = pCanal;
     
    IF vExisteCanal = 0 THEN
        LET vcodret1 = '161'; -- CANAL DE PROCEDENCIA INVALIDO
        RETURN vcodret1;
    END IF;
    
    -- // VALIDA EL CARRIER PARA NUMEROS CELULARES
    IF pCarrier > 0 THEN
        SELECT COUNT(*)
          INTO vExisteCarrier
          FROM si_carriers
         WHERE cve_carrier = pCarrier;
         
        IF vExisteCarrier = 0 THEN
            LET vcodret1 = '162'; -- CARRIER DE CELULAR INVALIDO
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
        LET vcodret1 = '163'; -- TELEFONO NO VALIDO PARA COFETEL
        RETURN vcodret1;
    END IF; 
    
    -- // VALIDA EL TELEFONO EN TABLA DE TELEFONOS INVALIDOS
    SELECT COUNT(*)
      INTO vTelInvalido
      FROM si_telefonos_invalidos
     WHERE telefono = pTelefono;
     
    IF vTelInvalido > 0 THEN
        LET vcodret1 = '164'; -- TELEFONO INVALIDO
        RETURN vcodret1;
    END IF;
    
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