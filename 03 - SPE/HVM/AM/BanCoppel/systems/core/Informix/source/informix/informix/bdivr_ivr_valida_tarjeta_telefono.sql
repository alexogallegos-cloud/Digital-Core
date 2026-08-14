CREATE PROCEDURE "informix".ivr_valida_tarjeta_telefono( pTelefono CHAR(10), pTarjeta CHAR(16) )
RETURNING CHAR(5),  --- Codigo de Retorno
          CHAR(10); --- Número de Cliente

    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vdFechaHoy       DATE;
    DEFINE vcTarjeta        CHAR(20);
    DEFINE vcNumCliente     CHAR(10);
    DEFINE vcProducto       CHAR(4);
    DEFINE viExisteCte      SMALLINT;
    DEFINE viExisteTel      SMALLINT;
    DEFINE viExisCteIVR     SMALLINT;
    DEFINE vcStatusCte      CHAR(1);
    DEFINE vSecMax          INTEGER;
    DEFINE vcNumTarjeta     CHAR(20);
    DEFINE vcStatusAcceso   CHAR(1);
    DEFINE vcTarjetaReg     CHAR(20);
    DEFINE vindcierrechq    CHAR(1);
    DEFINE vinddisponchq    CHAR(1);
    DEFINE vindcierrecrd    CHAR(1);
    DEFINE vinddisponcrd    CHAR(1);

    LET Sql_Err	       = 0;
    LET Isam_Err       = 0;
    LET Desc_Err       = '';
    LET vCodRet1       = '00000';
    LET vCodRet2       = '';
    LET vCodRet3       = '';
    LET vdFechaHoy     = '';
    LET vcTarjeta      = '';
    LET vcNumCliente   = '';
    LET vcProducto     = '';
    LET viExisteCte    = 0;
    LET viExisteTel    = 0;
    LET viExisCteIVR   = 0;
    LET vcStatusCte    = '';
    LET vSecMax        = 0;
    LET vcNumTarjeta   = '';
    LET vcStatusAcceso = '';
    LET vcTarjetaReg   = '';
    LET vindcierrechq  = '0';
    LET vinddisponchq  = '0';
    LET vindcierrecrd  = '0';
    LET vinddisponcrd  = '0';

    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/ivr_valida_tarjeta_telefono.err";
        --- TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1, vcNumCliente;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/home/sysifx/vladi/ivr_valida_tarjeta_telefono.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pTelefono is null OR pTelefono = '' ) OR
       ( pTarjeta is null OR pTarjeta = '' ) THEN
        LET vCodRet1    = '00017';
        LET vcNumCliente = '';
        RETURN vCodRet1, vcNumCliente;
    END IF;
    
    -- // OBTIENE LA FECHA DEL DIA
    SELECT fecha_hoy
      INTO vdFechaHoy
      FROM bdinteg:"informix".si_fechas
     WHERE empresa = '001';
     
    SELECT ind_cierre, ind_disponible
      INTO vindcierrechq, vinddisponchq
      FROM bdicheq:sc_fechas 
     WHERE empresa = '001';
     
    SELECT ind_cierre, ind_disponible
      INTO vindcierrecrd, vinddisponcrd
      FROM bdicred:sd_fechas 
     WHERE empresa = '001';
     
    IF ( vindcierrechq = '0' OR vinddisponchq = '0' OR vindcierrecrd = '0' OR vinddisponcrd = '0' ) THEN
        LET vCodRet1 = '017';
        LET vcNumCliente = '';
        RETURN vCodRet1, vcNumCliente;
    END IF;

    -- // VERIFICA SI LA TARJETA ES DE DEBITO O CREDITO
    SELECT NVL(tar.num_tarjeta, ' '), NVL(tar.numcte, ' '), NVL(chq.producto, ' ')
      INTO vcTarjeta, vcNumCliente, vcProducto
      FROM bdicheq:"informix".sc_tarjeta tar,
           bdicheq:"informix".sc_maechq chq
     WHERE tar.empresa = chq.empresa
       AND tar.num_tarjeta = pTarjeta
       AND tar.tipo_tarjeta = 'T'
       AND tar.status_tar = 'A'
       AND chq.cuenta = tar.cuenta
       AND chq.num_cte = tar.numcte;

    IF vcTarjeta is null OR vcTarjeta = '' OR vcTarjeta = ' ' OR vcTarjeta <> pTarjeta THEN
        SELECT NVL(tar.num_tarjeta, ' '), NVL(tar.numcte, ' '), NVL(crd.num_producto, ' ')
          INTO vcTarjeta, vcNumCliente, vcProducto
          FROM bdicred:"informix".sd_tarjeta tar,
               bdicred:"informix".sd_maecred crd
         WHERE tar.empresa = crd.empresa
           AND tar.num_tarjeta = pTarjeta
           AND tar.tipo_tarjeta = 'T'
           AND tar.status_tar = 'A'
           AND crd.num_credito = tar.num_credito
           AND crd.numcte = tar.numcte;

        IF vcTarjeta is null OR vcTarjeta = '' OR vcTarjeta = ' ' OR vcTarjeta <> pTarjeta THEN
            LET vCodRet1    = '00001';
            LET vcNumCliente = '';
            RETURN vCodRet1, vcNumCliente;
        END IF;
    END IF;

    -- // VERIFICA SI EL CLIENTE EXISTE EN TABLA DE CLIENTES IVR
    SELECT COUNT(*)
      INTO viExisCteIVR
      FROM bdinteg:"informix".si_cliente_ivr
     WHERE numcte = vcNumCliente;

    IF viExisCteIVR > 0 THEN
        -- // VERIFICA BANDERA DE ACCESO
        SELECT status_acceso, num_tarjeta
          INTO vcStatusAcceso, vcTarjetaReg
          FROM bdinteg:"informix".si_cliente_ivr
         WHERE numcte = vcNumCliente;
         
        IF vcStatusAcceso is null OR vcStatusAcceso = '' OR vcStatusAcceso <> '0' THEN
            LET vCodRet1 = '00001';
            LET vcNumCliente = '';
            RETURN vCodRet1, vcNumCliente;
        END IF;
        
        IF vcTarjeta <> vcTarjetaReg THEN
            UPDATE bdinteg:"informix".si_cliente_ivr
               SET num_tarjeta = vcTarjeta
             WHERE numcte = vcNumCliente;
        END IF;
    ELSE
        -- // VERIFICA QUE EL CLIENTE EXISTA
        SELECT COUNT(*)
          INTO viExisteCte
          FROM bdinteg:"informix".si_cliente
         WHERE numcte = vcNumCliente;

        IF viExisteCte = 0 THEN
            LET vCodRet1 = '00002';
            LET vcNumCliente = '';
            RETURN vCodRet1, vcNumCliente;
        END IF;

        -- // VERIFICA QUE EL TELEFONO SEA DE CASA O CELULAR
        SELECT COUNT(*)
          INTO viExisteTel
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = vcNumCliente
           AND telefono = pTelefono
           AND tipo_tel = 1;

        IF viExisteTel = 0 THEN
            SELECT COUNT(*)
              INTO viExisteTel
              FROM bdinteg:"informix".si_telefonos_actual
             WHERE numcte = vcNumCliente
               AND telefono = pTelefono
               AND tipo_tel = 2;
        
            IF viExisteTel = 0 THEN
                LET vCodRet1 = '00003';
                LET vcNumCliente = '';
                RETURN vCodRet1, vcNumCliente;
            END IF;
        END IF;

        INSERT INTO bdinteg:"informix".si_cliente_ivr VALUES
        ( vcNumCliente, 'P', pTelefono, pTarjeta, vcProducto, '', '', 0, vdFechaHoy, '0' );
    END IF;

    -- // GUARDA REGISTRO EN BITACORA
    SELECT MAX(secuencia)
      INTO vSecMax
      FROM bdinteg:"informix".si_bitacora_ivr
     WHERE DATE(fecha_oper) = CURRENT::DATE
       AND numcte = vcNumCliente;

    IF vSecMax is null THEN
        LET vSecMax = 0;
    END IF;

    LET vSecMax = vSecMax + 1;

    INSERT INTO bdinteg:"informix".si_bitacora_ivr VALUES
    ( current, vSecMax, 'VALIDA_TARJ_TEL', pTarjeta, vcNumCliente, pTelefono );

    END;

    RETURN vCodRet1, vcNumCliente;

END PROCEDURE;