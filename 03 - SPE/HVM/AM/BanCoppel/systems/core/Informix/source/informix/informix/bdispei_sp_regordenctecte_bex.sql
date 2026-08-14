CREATE PROCEDURE "informix".sp_regordenctecte_bex(pEmpresa  CHAR(3),
                                                 pchrSucursal CHAR(4),
                                                 pchrUsuario CHAR(8),
                                                 pintBancoDest INTEGER,
                                                 pmnyImporte MONEY(14,2),
                                                 pchrTransuc  CHAR(4),
                                                 pchrFolioSuc CHAR(16),
                                                 pdtfechacaptura DATE,
                                                 pmnyComision MONEY(14,2),
                                                 pmnyIvaComis MONEY(14,2),
                                                 pvchrNombreOrd VARCHAR(40),
                                                 pintTipoCtaOrd INTEGER,
                                                 pvchrCuentaOrd VARCHAR(20),
                                                 pvchrRfcOrd VARCHAR(18),
                                                 pvchrNombreBenef VARCHAR(40),
                                                 pintTipoCtaBenef INTEGER,
                                                 pvchrCtaBenef VARCHAR(20),
                                                 pvchrRFCBenef VARCHAR(18),
                                                 pvchrConceptoPago VARCHAR(40),
                                                 pmnyIVA MONEY(14,2),
                                                 pdecRefNum DECIMAL(7,0),
                                                 pvchrRefCobranza1 VARCHAR(40))

RETURNING CHAR(5), CHAR(30);

    --// ***************************************************************************
    --// sp_regordenctecte
    --// Version              1.0.0
    --// Obejtivo:            Registro de orden spei cliente - cliente
    --// Parametros de Entrada:
    --//          pchrUsuario      : Clave del usuario de promocion que registra la operacion
    --//          pchrSucursal     : Sucursal que registra el movimiento
    --//          pintTipoCtaOrd   : Clave del tipo de Cuenta del Ordenante.
    --//          pvchrCuentaOrd   : Numero de cuenta del cliente.
    --//          pvchrNombreOrd   : Nombre del cliente.
    --//          pvchrRfcOrd      : Rfc del cliente.
    --//          pintTipoCtaBenef : Clave del tipo de Cuenta del Beneficiario.
    --//          pvchrCtaBenef    : CLABE del beneficiario de la orden.
    --//          pvchrNombreBenef : Nombre del beneficiario de la orden.
    --//          pvchrRFCBenef    : (opcional) RFC del beneficiario de la orden.
    --//          pintBancoDest    : Clave CESIF del banco beneficiario de la orden.
    --//          pmnyImporte      : Importe de la orden que se desea enviar.
    --//          pmnyIVA          : Importe del iva.
    --//          pvchrConceptoPago: Instrucciones o referencia del pago para el cliente o banco beneficiario.
    --//          pdecRefNum       : Dato numerico que servira de referencia al beneficiario para indicar el concepto del pago.
    --//          pchrFolioSuc     : Folio Sucursal.
    --//          pvchrRefCobranza1: Se usara obligatoriamente para cuentas concentradoras de cobranza.
    --//          pdtfechacaptura  : Fecha Captura.
    --// Parametros de Salida:
    --// 	Codigo de Retorno      : '000' - Si la orden pudo ser registrada correctamente.
    --// 				<> '000' - Indica el error ocurrido al tratar de registrar la orden de pago.
    --//    Descripcion            : Descripcion del error.
    --//    Clave de Rastreo       : Entrega la clave de rastreo generada para la orden de pago registrada.
    --// Creado por:          Alejandro Rueda Sanchez
    --// ModIFicado por:
    --// Ultima Modificacion: Marzo - 2011 Se modifica para que en la tabla tblpago se guarde la cuenta ordenante corespondiente al tipo de cuenta asignado
    --//                      Creación de SPL
	--//
    --// ***************************************************************************

    -- // Definicion de variables
    DEFINE cVarDataErr      CHAR(100);
    DEFINE vchrcodret 	    CHAR(5);
    DEFINE vchrcodret2 	    CHAR(5);
    DEFINE vcharcodret3     CHAR(50);
    DEFINE vintcodret	    INTEGER;
    DEFINE vintcodret2	    INTEGER;
    DEFINE vchrcodret3      CHAR(50);
    DEFINE vchrCveRastreo	CHAR(30);
    DEFINE vintPermiteCta11 INTEGER;
    DEFINE vchrFuente       CHAR(7);
    DEFINE vchrTranscargo   CHAR(4);
    DEFINE vchrComis        CHAR(4);
    DEFINE vchrIvaComis     CHAR(4);
    DEFINE vchrtranret      CHAR(4);
    DEFINE dteFechacargo    DATE;
    DEFINE vmnySdoDisp      MONEY(14,2);
    DEFINE vmnyMontoRet     MONEY(14,2);
    DEFINE vchrTarjeta      CHAR(20);
    DEFINE vtransaccion     INTEGER;
    DEFINE vchrparametro    VARCHAR(255);
    DEFINE vchrFechaValor   VARCHAR(10);
    DEFINE dIva             DECIMAL(5,3);
    DEFINE vmnyMontoLibre   MONEY(14,2);
    DEFINE vdigitoverifica  SMALLINT;
    DEFINE vexiste_suc      CHAR(4);
	DEFINE vchrCtaOrdClabe  VARCHAR(20);
    
    DEFINE intcontador      INTEGER;
    DEFINE v_montomin	    MONEY;
    DEFINE chrtopologia     CHAR(1);
    DEFINE intBancoOrd      INTEGER;
    DEFINE inttpooper       INTEGER;
    DEFINE chrabonachq      CHAR(1);
    DEFINE vintCveCesif     INTEGER;
    DEFINE vintfolioop	    INTEGER;
    DEFINE intpktblpago     INTEGER;
    DEFINE vsintLongCveRast SMALLINT;
    DEFINE vdigverif        CHAR(1);
    DEFINE vind_dispon      CHAR(1);
    
    DEFINE vchrTelefono     CHAR(10); 
    DEFINE vhora            DATETIME HOUR TO FRACTION(3);
    DEFINE vchrProdTrnf     CHAR(4);
	DEFINE dtFechaOperacion DATE;

	DEFINE vchTpoCta	    CHAR(2);
    DEFINE vchFlagSpei		CHAR(3);

	DEFINE vchrestatusenvio	CHAR(1);
    DEFINE vfecha_hoy		DATE;
    DEFINE vcodret1         CHAR(5);
	DEFINE vfechaHabil		DATE;
    DEFINE vchrFechaVal     CHAR(10);
    DEFINE wmnyImporte 		DECIMAL (14,2);
    DEFINE wmnyIVA 			DECIMAL (14,2);
	DEFINE vsuc_cta         CHAR(4);
	DEFINE vclabe           CHAR(4);
	
	-- // FIRMA
	DEFINE wmedioent        CHAR(3);
	DEFINE ret				INTEGER;
	DEFINE wvchrfirma 		CHAR(512);
	DEFINE wchrcadena_00	CHAR(3000);
	DEFINE wchrcadena_01	CHAR(200);
	DEFINE wchrcadena_02	CHAR(200);
	DEFINE wchrcadena_03	CHAR(200);
	DEFINE wchrcadena_04	CHAR(200);
	DEFINE wvchrnombre		CHAR(30);
	DEFINE vchrFechaValor2	VARCHAR(10);
	DEFINE pvchrNombreBene2 VARCHAR(40);

    LET vtransaccion    = 0;
    LET cVarDataErr     = '';
    LET vdigitoverifica = 0;
    LET vexiste_suc     = '';
    
    LET intcontador = 0;
    LET v_montomin  = 0;
    LET vdigverif   = '';
    LET vind_dispon = '0';
	LET dtFechaOperacion = TODAY;

    LET vchTpoCta	     = '';
	LET vchFlagSpei		 = '';
	LET vchrestatusenvio = 'N';
	LET vfecha_hoy       = '';
	LET vcodret1         = "00000";
    LET vchrFechaVal     = '';
	LET vsuc_cta         = pchrSucursal;
	LET vclabe           = '';
	
	-- // FIRMA
	LET wmedioent     = '';
	LET ret           = 0;
	LET wvchrfirma    = '';
	LET wchrcadena_00 = '';
	LET wchrcadena_01 = '';
	LET wchrcadena_02 = '';
	LET wchrcadena_03 = '';
	LET wchrcadena_04 = '';
	LET wvchrnombre   = '';
	
--SET DEBUG FILE TO '/resplogifx/conciliachq/spei/sp_regordenctecte_bex.out';
--TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET vintcodret, vintcodret2, vchrcodret3
        IF vintcodret <> 0 THEN
		    SET DEBUG FILE TO "/resplogifx/conciliachq/spei/sp_regordenctecte_bex.err";
            TRACE ON;
            LET vchrcodret = vintcodret;
            LET vchrcodret2 = vintcodret2;
            LET vcharcodret3 = vchrcodret3;
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            RETURN vchrcodret, '';
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN(-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;
    
    -- // Iniciar la transaccion
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    

    -- // Inicializacion de variables
    LET vchrcodret = '000';
    LET vchrCveRastreo = '';
    LET vchrTarjeta = '';
	LET pvchrNombreBene2 = pvchrNombreBenef;
    
    IF pvchrNombreOrd IS NULL OR pvchrNombreOrd = '' OR
       pintTipoCtaOrd = 0 OR pintTipoCtaOrd IS NULL OR
       pvchrCuentaOrd IS NULL OR pvchrCuentaOrd = '' OR
       pvchrRFCOrd IS NULL OR pvchrRFCOrd = '' OR
       pvchrNombreBenef IS NULL OR pvchrNombreBenef = '' OR
       pintTipoCtaBenef = 0 OR pintTipoCtaBenef IS NULL OR
       pvchrCtaBenef IS NULL OR pvchrCtaBenef = '' OR
       pvchrConceptoPago IS NULL OR pvchrConceptoPago = '' THEN
            
	IF pvchrNombreBenef = " " THEN
		INSERT INTO tblspeican(vchrnombreord, vchrcuentaord, vchrnombrebenef, vchrcuentabenef, vchrnombrebenem)
		VALUES (pvchrNombreOrd, pvchrCuentaOrd, pvchrNombreBenef, pvchrCtaBenef, pvchrNombreBene2);
	END IF;
		
		LET vchrcodret = '011';
        --LET cVarDataErr = 'Faltan campos obligatorios para el tipo de pago';
        RETURN vchrcodret, '';
    END IF;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT ind_disponible, fecha_hoy
      INTO vind_dispon, vfecha_hoy
      FROM bdicheq:sc_fechas 
     WHERE empresa = pEmpresa;
	 
    LET vchrFechaValor2 = to_char(vfecha_hoy, '%Y%m%d');
     
    IF vind_dispon = '0' THEN
        LET vchrcodret = '004';
        --LET cVarDataErr = 'SISTEMA DE CHEQUES NO DISPONIBLE.';
        RETURN vchrcodret, '';
    END IF;

    {--
	-- // Valida que no esté bloqueada la base de datos
    SELECT vchrvalor
      INTO vchrparametro
      FROM tblparametros
     WHERE vchrcveparametro = 'BLOQUEO_A_USUARIOS';

    IF vchrparametro IS NULL THEN
        LET vchrcodret = '011';
        --LET cVarDataErr = 'Parametro no encontrado';
        RETURN vchrcodret, '';
    END IF;

    IF (vchrparametro * 1) = 1 THEN
        LET vchrcodret = '013';
        --LET cVarDataErr = 'Operacion fuera de horario de servicio';
        RETURN vchrcodret, '';
    END IF;
    --}    
    
    {--
	-- // valida canal internet
    IF pchrSucursal = '5003' THEN
        EXECUTE PROCEDURE sp_validaspei_bpi(pvchrCuentaOrd, pvchrCtaBenef)
        INTO vchrcodret, cVarDataErr;
        
        IF TRIM(vchrcodret) <> '000' THEN
            RETURN vchrcodret, '';    
        END IF;
    END IF;
    --}
	
    -- // Valida la fecha del Movimiento
    IF (pdtfechacaptura is null) OR (pdtfechacaptura = '') then
        LET vchrcodret = '001'; -- Falta parametro Fecha de Operacion
        --LET cVarDataErr = 'Falta parametro Fecha de Operacion';
        RETURN vchrcodret, '';
    END IF
    
    -- // Verifica horario de operación SPEI y reglas para horario extendido.
    EXECUTE PROCEDURE spei_validaoperacion(pvchrCuentaOrd, pmnyImporte, pchrSucursal)
    INTO vchFlagSpei, vchTpoCta;
    
    IF vchFlagSpei <> '000' THEN   
        LET vchrcodret = '013';   
        --LET cVarDataErr = 'Operacion fuera de horario de servicio';
        RETURN vchrcodret, '';
    END IF;
	
    -- // Obtiene el numero de tarjeta
    IF pintTipoCtaOrd = 3 THEN
        SELECT num_tarjeta, cuenta
          INTO vchrTarjeta, pvchrCuentaOrd
          FROM bdicheq:sc_tarjeta
         WHERE empresa = pEmpresa
           AND num_tarjeta = pvchrCuentaOrd
           AND status_tar = 'A';
        
        IF (vchrTarjeta is null) OR (vchrTarjeta = '') THEN
            LET vchrcodret = '019'; -- Tarjeta no vigente ó no asignada
            --LET cVarDataErr = 'Tarjeta no vigente ó no asignada';
            RETURN vchrcodret, '';
        ELSE
            -- // Verifica si se encuentra activa la cuenta de cheques
			IF SUBSTR(pvchrCuentaOrd, 1, 2) <> '80' THEN
                SELECT cuenta, sucursal, substr(cuenta_clabe, 15,4)
                  INTO pvchrCuentaOrd, vsuc_cta, vclabe
                  FROM bdicheq:sc_maechq
                 WHERE cuenta = pvchrCuentaOrd
                   AND status_cta NOT IN("2", "6");
            END IF;			   
		
            IF pvchrCuentaOrd IS NULL OR pvchrCuentaOrd = '' THEN
                LET vchrcodret = '020'; -- La cuenta Ord. no se encuentra activa
                --LET cVarDataErr = 'La cuenta Ord. no se encuentra activa';
                RETURN vchrcodret, '';
            END IF
        END IF
    END IF
    
    -- // Verifica  la cuenta a 18 digitos
    IF pintTipoCtaOrd = 40 THEN
        IF SUBSTR(pvchrCuentaOrd, 1, 2) <> '80' THEN
            SELECT cuenta_clabe, sucursal, substr(cuenta_clabe, 15,4)
              INTO vchrCtaOrdClabe, vsuc_cta, vclabe
              FROM bdicheq:sc_maechq
             WHERE cuenta = pvchrCuentaOrd
               AND status_cta NOT IN("2", "6");
        END IF;

        IF vchrCtaOrdClabe IS NULL THEN
            LET vchrcodret = '021'; -- No se tiene cuenta clabe.
            --LET cVarDataErr = 'Cuenta No valida. ';
            RETURN vchrcodret, '';
        END IF;

        IF vchrCtaOrdClabe IS NOT NULL THEN
			IF LENGTH(vchrCtaOrdClabe) >= 16 AND LENGTH(vchrCtaOrdClabe) < 18 THEN
				LET vchrCtaOrdClabe = LPAD(vchrCtaOrdClabe,18,'0');
            ELIF LENGTH(vchrCtaOrdClabe) > 18 THEN
                LET vchrcodret = '020'; -- La cuenta debe ser de 18 digitos.
                --LET cVarDataErr = 'La cuenta Clave del Ord. debe ser de 18 digitos';
                RETURN vchrcodret, '';
            END IF;
        ELIF LENGTH(pvchrCuentaOrd) = 11 THEN
            LET vchrcodret = '020'; -- La cuenta Ord. no permite 11 digitos.
            --LET cVarDataErr = 'La cuenta Ord. no permite solo 11 digitos';
            RETURN vchrcodret, '';
        END IF;
    END IF;
    
    IF pintTipoCtaOrd = 10 THEN
        IF LENGTH(pvchrCuentaOrd) = 10 THEN
            LET vchrTelefono = pvchrCuentaOrd;
            
            SELECT cuenta
              INTO pvchrCuentaOrd
              FROM bdicheq:sc_cuenta_telefono
             WHERE telefono = vchrTelefono;

			IF pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN
				SELECT cuenta_tf
					INTO pvchrCuentaOrd
					FROM bditransfer:tf_maecte
				WHERE telefono = vchrTelefono
					AND status_cta = "1";
			END IF;
		ELSE
            SELECT telefono
              INTO vchrTelefono
              FROM bdicheq:sc_cuenta_telefono
             WHERE cuenta = pvchrCuentaOrd;
        END IF;

		SELECT cuenta, sucursal, substr(cuenta_clabe, 15,4)
          INTO pvchrCuentaOrd, vsuc_cta, vclabe
          FROM bdicheq:sc_maechq
         WHERE cuenta = pvchrCuentaOrd
           AND status_cta NOT IN("2", "6");
		
        IF vchrTelefono is null OR vchrTelefono = '' OR pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN
             LET vchrcodret = '020'; -- // La cuenta Ord. no existe.
             --LET cVarDataErr = 'La cuenta Ord. no esta asociada a un telefono';
             RETURN vchrcodret, '';
		END IF;
		
	END IF;
    
    -- // Verifica la longitud de la cta benef
    IF pintTipoCtaBenef = 40 THEN
        IF LENGTH(pvchrCtaBenef) >= 16 AND LENGTH(pvchrCtaBenef) < 18 THEN
            LET pvchrCtaBenef = LPAD(pvchrCtaBenef,18,'0');
            
            EXECUTE PROCEDURE sp_validadv(pvchrCtaBenef)
            INTO vchrcodret, vdigitoverifica;
            
            IF vdigitoverifica = 0 THEN
                LET vchrcodret = '020'; -- La Cuenta Clabe del Benefciario es Invalida
                --LET cVarDataErr = 'La Cuenta Clabe del Benefciario es Invalida ';
                RETURN vchrcodret, '';
            END IF
        ELIF LENGTH(pvchrCtaBenef) <> 18 THEN
            LET vchrcodret = '020'; -- La cuenta Benef debe ser de 18 digitos.
            --LET cVarDataErr = 'La cuenta Benef debe ser de 18 digitos';
            RETURN vchrcodret, '';
        END IF;
    END IF;
    
    -- // Compara la clave del banco en la clabe del beneficiario, si es por cuenta CLABE.
    IF pintTipoCtaBenef = 40 THEN
        IF SUBSTR(pvchrCtaBenef, 1, 3) <> SUBSTRING(TRIM(pintBancoDest::VARCHAR(10)) FROM LENGTH(TRIM(pintBancoDest::VARCHAR(10))) -2) THEN
            LET vchrcodret = '025';
            --LET cVarDataErr = 'Existe un error en la captura de la cuenta clabe ó el banco que se capturó es incorrecto';
            RETURN vchrcodret, '';
        END IF;
    END IF;
    
    -- // Obtiene el Iva General
    SELECT valor
      INTO dIva
      FROM bdinteg:si_param
     WHERE cod_param = 47
       AND empresa = pEmpresa;
     
    IF dIva IS NULL THEN
        LET vchrcodret = '011';
        --LET cVarDataErr = 'Parametro no encontrado';
        RETURN vchrcodret, '';
    END IF;

    -- // Obtiene la fecha de operacion de spei
    SELECT vchrvalor
      INTO vchrFechaVal
	  FROM tblparametros
	 WHERE vchrcveparametro = 'FECHA_OPERACION';
     
    LET vchrFechaValor = SUBSTR(vchrFechaVal,4,2) || '/' || SUBSTR(vchrFechaVal,1,2) || '/' || SUBSTR(vchrFechaVal,7,4);
	LET vchrFechaValor2 = SUBSTR(vchrFechaVal,7,4) || SUBSTR(vchrFechaVal,4,2) || SUBSTR(vchrFechaVal,1,2);	
    
    -- // Obtiene la topologia por default
    SELECT vchrvalor
      INTO vchrparametro
      FROM tblparametros
     WHERE vchrcveparametro = 'DEFAULT_TOPOLOGIA';
     
    IF vchrparametro IS NULL THEN
        LET vchrcodret = '011';
        --LET cVarDataErr = 'Parametro no encontrado';
        RETURN vchrcodret, '';
    END IF;
    
    LET chrtopologia = TRIM(vchrparametro);
    
    -- // Obtiene el banco ordenante (Bancoppel)
    SELECT vchrvalor
      INTO vchrparametro
      FROM tblparametros
     WHERE vchrcveparametro ='@CVECESIFBCO';
     
    IF vchrparametro IS NULL THEN
        LET vchrcodret = '011';
        --LET cVarDataErr = 'Parametro no encontrado';
        RETURN vchrcodret, '';
    END IF;
    
    LET intBancoOrd = (vchrparametro * 1);
    
    -- // Valida que exista la sucursal en central
    SELECT COUNT(*)
      INTO intcontador
      FROM bdinteg:si_sucursales
     WHERE sucursal = pchrSucursal;
      
    IF intcontador = 0 THEN
        LET vchrcodret = '016';
        --LET cVarDataErr = 'Sucursal no valida ó no existe en central';
        RETURN vchrcodret, '';
    END IF;
    
    -- // Valida que exista el usuario en central
    SELECT COUNT(*)
      INTO intcontador
      FROM bdinteg:si_ejecut
     WHERE ejecutivo = pchrUsuario;
      
    IF intcontador = 0 THEN
        LET vchrcodret = '017';
        --LET cVarDataErr = 'Usuario no valido';
        RETURN vchrcodret, '';
    END IF;
    
    -- // Valida que exista el tipo de pago
    SELECT COUNT(*)
      INTO intcontador
      FROM tbltipopago
     WHERE intcvetipopago = 1;
     
    IF intcontador = 0 THEN
        LET vchrcodret = '018';
        --LET cVarDataErr = 'No existe el tipo de pago';
        RETURN vchrcodret, '';
    END IF;
    
    -- // Valida que exista el tipo de operacion
    SELECT intcontatoper, chrdevabonachq
      INTO inttpooper, chrabonachq
      FROM tbltipopago
     WHERE intcvetipopago = 1;
     
    IF inttpooper = 1 THEN
        SELECT COUNT(*)
          INTO intcontador
          FROM tbltipooperacion
         WHERE intcvetpooperacion = pintTipoOper;
        
        IF intcontador = 0 THEN
            LET vchrcodret = '019';
            --LET cVarDataErr = 'No existe tipo de operacion';
            RETURN vchrcodret, '';
        END IF;
    END IF;

    -- // Valida monto minimo permitido para la operacion
    SELECT mnymontomin
      INTO v_montomin
      FROM tbltipopago
     WHERE intcvetipopago = 1;
     
    IF pmnyImporte < v_montomin THEN
        LET vchrcodret = '020';
        --LET cVarDataErr = 'Monto menor al minimo permitido para el tipo de pago';
        RETURN vchrcodret, '';
    END IF;
    
    -- // Valida el banco
    SELECT cvecesif
      INTO vintCveCesif
      FROM tblbanco
     WHERE cvecesif = pintBancoDest
	   AND chredobco = 'A'
       AND intindice >= 0;
       
    IF vintCveCesif IS NULL THEN
        LET vchrcodret = '021';
        --LET cVarDataErr = 'Banco no Valido';
        RETURN vchrcodret, '';
    -- // Se agrega validación 40137
    ELSE
        IF vintCveCesif = intBancoOrd THEN
			LET vchrcodret = '021';
			--LET cVarDataErr = 'Banco no Valido';
			RETURN vchrcodret, '';
		END IF;
    END IF;
    
    -- // Valida que no se repita el folio de sucursal para la fecha de operacion
    SELECT {+INDEX(tblpago idx_fv)}
           COUNT(*)
      INTO intcontador
      FROM tblpago
     WHERE dtfechavalor = pdtfechacaptura
       AND chrfolioprom = pchrFolioSuc;
       
    IF intcontador > 0 THEN
        LET vchrcodret = '023';
        --LET cVarDataErr = 'El Folio de sucursal ya existe para esta fecha';
        RETURN vchrcodret, '';
    END IF;

    -- // Trae la transaccion de Cargo.
    SELECT vchrValor
      INTO vchrTranscargo
      FROM tblparametros
     WHERE vchrcveparametro = 'TRANSACC_CARGO';

    -- // Valida que error si la transaccion no tiene valor
    IF vchrTranscargo IS NULL OR vchrTranscargo = '' THEN
        LET vchrcodret = '022';
        --LET cVarDataErr = 'No existe la Transaccion';
        RETURN vchrcodret, '';
    END IF;

    -- // Justifica con ceros la transaccion.
    IF TRIM(vchrTranscargo) <> '' THEN
        LET vchrTranscargo = LPAD(TRIM(vchrTranscargo), 4, '0');
    END IF;
    
    -- // Trae la transaccion de la Comision
    SELECT vchrValor
      INTO vchrComis
      FROM tblparametros
     WHERE vchrcveparametro = 'TRANSACC_COMISION';

    IF vchrComis IS NULL OR vchrCOmis = '' THEN
        LET vchrcodret = '023'; -- Falta parametro de transaccion comision.
        RETURN vchrcodret, '';
    END IF;

    -- // Trae la transaccion del IVA de la Comision
    SELECT vchrValor
      INTO vchrIvaComis
      FROM tblparametros
     WHERE vchrcveparametro = 'TRANSACC_IVACOM';
	 
    IF vchrIvaComis IS NULL OR vchrIvaComis = '' THEN
        LET vchrcodret = '023'; -- Falta parametro de transaccion iva.
        RETURN vchrcodret, '';
    END IF;

    -- // Valida si existe la transaccion de la sucursal
    IF TRIM(pchrTransuc) = '' THEN
        LET pchrTransuc = '0000';
    END IF;
    
    -- // Busca si aplica comision e iva especial
    SELECT suc.sucursal
      INTO vexiste_suc
      FROM bdinteg:si_sucursales suc, 
           bdinteg:si_param par 
     WHERE par.cod_param = 47
       AND suc.sucursal = pchrSucursal
       AND par.valor = suc.iva
       AND par.empresa = suc.empresa
       AND par.empresa = pEmpresa;
       
    IF vexiste_suc is null OR vexiste_suc = '' THEN
        -- // Trae la transaccion de la Comision especial
        SELECT trancivaesp
          INTO vchrtranret
          FROM bdinteg:si_transacc
         WHERE numero = vchrComis
           AND empresa = pEmpresa
           AND sistema = '01';
           
        LET vchrComis = trim(vchrtranret);
        
        -- // Trae la transaccion del IVA especial
        SELECT trancivaesp
          INTO vchrtranret
          FROM bdinteg:si_transacc
         WHERE numero = vchrIvaComis
           AND empresa = pEmpresa
           AND sistema = '01';
           
        LET vchrIvaComis = trim(vchrtranret);
    END IF
    
	LET vchrComis = 0;
	LET vchrIvaComis = 0;
	LET pmnyComision = 0;
    LET pmnyIvaComis = 0;
	
    -- // Genera la clave de Rastreo
    EXECUTE PROCEDURE sp_obtsigfolioop('FOLIO_CVERASTREO')
    INTO vchrcodret, vintfolioop;
    
    EXECUTE PROCEDURE bdicheq:digver11(pvchrCuentaOrd)
    INTO vchrcodret, vdigverif;
    
    IF pvchrConceptoPago LIKE 'PORTABILIDAD DE NOMINA%' THEN
	    IF TRIM(pchrSucursal)  = "5011" THEN 
	      LET vchrCveRastreo = TRIM(pchrSucursal) || TRIM(vclabe) || UPPER(TRIM(pchrUsuario)) || LPAD(vintfolioop||'', 7, '0') || vdigverif;
        ELSE 
		 LET vchrCveRastreo = TO_CHAR(pdtfechacaptura, '%Y%m%d')||'40137'||'NNNN'||'COPL' || LPAD(vintfolioop||'', 8, '0') || vdigverif;
		END IF;  
    ELSE
        --LET vchrCveRastreo = 'COPL' || TRIM(vsuc_cta) || UPPER(TRIM(pchrUsuario)) || LPAD(vintfolioop||'', 7, '0') || vdigverif;
		LET vchrCveRastreo = TRIM(pchrSucursal) || TRIM(vclabe) || UPPER(TRIM(pchrUsuario)) || LPAD(vintfolioop||'', 7, '0') || vdigverif;
    END IF;
    
    -- // Valida que no se repita la clave de rastreo para la fecha de operacion
    SELECT {+INDEX(tblpago idx_cr)}
           COUNT(*)
      INTO intcontador
      FROM tblpago
     WHERE vchrclaverastreo = vchrCveRastreo;
       
    IF intcontador > 0 THEN
        LET vchrcodret = '024';
        --LET cVarDataErr = 'Clave de rastreo duplicada';
        RETURN vchrcodret, '';
    END IF;

    LET vsintLongCveRast = LENGTH(vchrCveRastreo);
    
    LET intpktblpago = vintfolioop;
    
    IF pdecRefNum IS NULL or pdecRefNum = 0 THEN
        LET pdecRefNum = SUBSTR(LPAD(intpktblpago, 12, '0'), -7); 
    END IF;
    
    -- // Aplicar el Cargo de la operacion - Ejecutar cargo a cheques
    IF SUBSTR(pvchrCuentaOrd, 1, 2) <> '80' THEN
        EXECUTE PROCEDURE bdicheq:cargo_ref(pEmpresa,pchrSucursal,pchrUsuario,vchrTranscargo,pchrTransuc,pchrFolioSuc,pvchrCuentaOrd,0,pmnyImporte,"01",vchrCveRastreo,vchrTarjeta,pchrUsuario)
        INTO vchrcodret, vchrtranret, dteFechacargo, vmnySdoDisp, vmnyMontoRet;

        -- // Valida si se pudo realizar el cargo
        IF trim(vchrcodret) <> '000' THEN
            --LET cVarDataErr = 'No fue posible ejecutar el cargo a la cuenta de cheques';
            
            IF vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            
            RETURN vchrcodret, '';
        ELSE
            -- // Registra el detalle de la transaccion del pago
            INSERT INTO tbldetranpago(folio_suc, sucursal, usuario, fech_alt, transacc, empresa, cuenta, monto_tot, clave_rastreo)
            VALUES(pchrFolioSuc, pchrSucursal, pchrUsuario, pdtfechacaptura, vchrTranscargo, pEmpresa, pvchrCuentaOrd, pmnyImporte, vchrCveRastreo);
        END IF;
    END IF; 
    
    -- // Aplicar la Comision de la operacion
    IF pmnyComision > 0 THEN
        IF SUBSTR(pvchrCuentaOrd, 1, 2) <> '80' THEN
            EXECUTE PROCEDURE bdicheq:cargo_ref(pEmpresa,pchrSucursal,pchrUsuario,vchrComis,pchrTransuc,pchrFolioSuc,pvchrCuentaOrd,0,pmnyComision,"01",vchrCveRastreo,vchrTarjeta,pchrUsuario)
            INTO vchrcodret, vchrtranret, dteFechacargo, vmnySdoDisp, vmnyMontoRet;
            
            -- // Valida si se pudo realizar el cargo
            IF trim(vchrcodret) <> '000' THEN
                --LET cVarDataErr = 'No fue posible ejecutar el cargo a la cuenta de cheques';
                
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                
                RETURN vchrcodret, '';
            ELSE
                -- // Registra el detalle de la transaccion de la comision
                INSERT INTO tbldetranpago(folio_suc,sucursal, usuario, fech_alt, transacc, empresa, cuenta, monto_tot, clave_rastreo)
                VALUES(pchrFolioSuc, pchrSucursal, pchrUsuario, pdtfechacaptura, vchrComis, pEmpresa, pvchrCuentaOrd, pmnyComision, vchrCveRastreo);
            END IF;
        END IF;
    END IF;
    
    -- // Aplicar el IVA de la Comision
    IF pmnyIvaComis > 0 THEN
        IF SUBSTR(pvchrCuentaOrd, 1, 2) <> '80' THEN
            EXECUTE PROCEDURE bdicheq:cargo_ref(pEmpresa,pchrSucursal,pchrUsuario,vchrIvaComis,pchrTransuc,pchrFolioSuc,pvchrCuentaOrd,0,pmnyIvaComis,"01",vchrCveRastreo,vchrTarjeta,pchrUsuario)
            INTO vchrcodret, vchrtranret, dteFechacargo, vmnySdoDisp, vmnyMontoRet;
            
            -- // Valida si se pudo realizar el cargo
            IF trim(vchrcodret) <> '000' THEN
                --LET cVarDataErr = 'No fue posible ejecutar el cargo a la cuenta de cheques';
                
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                
                RETURN vchrcodret, '';
            ELSE
                -- // Registra el detalle de la transaccion del iva de la comision
                INSERT INTO tbldetranpago(folio_suc, sucursal, usuario, fech_alt, transacc, empresa, cuenta, monto_tot, clave_rastreo)
                VALUES(pchrFolioSuc, pchrSucursal, pchrUsuario, pdtfechacaptura, vchrIvaComis, pEmpresa, pvchrCuentaOrd, pmnyIvaComis, vchrCveRastreo);
            END IF;
        END IF;
    END IF;
    
    -- // GUARDA REGISTRO EN bdispei:tblpago 
    IF pintTipoCtaOrd = '40' THEN
		LET pvchrCuentaOrd = vchrCtaOrdClabe;
    ELIF pintTipoCtaOrd = '10' THEN
        LET pvchrCuentaOrd = vchrTelefono;
    ELSE
		LET pvchrCuentaOrd = vchrTarjeta;
    END IF;
    
	IF CURRENT HOUR TO fraction > '17:58:00' AND CURRENT HOUR TO fraction < '19:00:00' THEN
		SELECT vchrvalor
		  INTO vchrparametro
		  FROM tblparametros
		  WHERE vchrcveparametro = 'BLOQUEO_A_USUARIOS';
				  
		IF vchrparametro IS NOT NULL THEN
			IF (vchrparametro * 1) = 1 THEN
				--LET vchrestatusenvio ='E';
        
				CALL "informix".sp_validafecha(pEmpresa, vfecha_hoy)
					RETURNING vcodret1, vfechaHabil;
        
				LET vchrFechaValor = to_char(vfechaHabil, '%m/%d/%Y');
			LET vchrFechaValor2 = to_char(vfechaHabil, '%Y%m%d');
			END IF;
		END IF;
	END IF;
	
	
	-- // NUEVOS CAMBIOS PARA GENERAR EL CIFRADO
	IF pmnyImporte > 400000.00 THEN
		LET wmedioent = 'h2h';
	ELSE
		LET wmedioent = '';
	END IF;
	
	EXECUTE PROCEDURE bdinteg:sp_quitar_acentos(pvchrNombreOrd)
	INTO pvchrNombreOrd;
	
	--EXECUTE PROCEDURE bdinteg:sp_quitar_acentos(pvchrNombreBenef)
	--INTO pvchrNombreBenef;

	/* #####
	
	LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Ñ', 'N');
	LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Á', 'A');
	LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'É', 'E');
	LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Í', 'I');
	LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Ó', 'O');
	LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Ú', 'U');
	LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Ü', 'U');
	LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'ý', 'X');
	LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Ý', 'X');
	LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Ã', 'A');
	
	##### */
	
	LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Ñ', 'N');
	LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'ñ', 'n');
	LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'á', 'a');
	LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'é', 'e');
	LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'í', 'i');
	LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'ó', 'o');
	LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'ú', 'u');
	LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Á', 'A');
	LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'É', 'E');
	LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Í', 'I');
	LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Ó', 'O');
	LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Ú', 'U');
	LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Ü', 'U');
	LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'ý', 'X');
	LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Ý', 'X');
	LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Ã', 'A');
	
	LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Ñ', 'N');
	LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'ñ', 'n');
	LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'á', 'a');
	LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'é', 'e');
	LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'í', 'i');
	LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'ó', 'o');
	LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'ú', 'u');
	LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Á', 'A');
	LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'É', 'E');
	LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Í', 'I');
	LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Ó', 'O');
	LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Ú', 'U');
	LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Ü', 'U');
	LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'ý', 'X');
	LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Ý', 'X');
	LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Ã', 'A');
	
	LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Ñ', 'N');
	LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'ñ', 'n');
	LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'á', 'a');
	LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'é', 'e');
	LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'í', 'i');
	LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'ó', 'o');
	LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'ú', 'u');
	LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Á', 'A');
	LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'É', 'E');
	LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Í', 'I');
	LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Ó', 'O');
	LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Ú', 'U');
	LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Ü', 'U');
	LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'ý', 'X');
	LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Ý', 'X');
	LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Ã', 'A');
			
	LET pvchrRFCBenef = REPLACE(pvchrRFCBenef, 'Ñ', 'N');
	LET pvchrRFCBenef = REPLACE(pvchrRFCBenef, 'ý', 'X');
	LET pvchrRFCBenef = REPLACE(pvchrRFCBenef, 'Ý', 'X');
	LET pvchrRFCBenef = REPLACE(pvchrRFCBenef, 'Ã', 'A');
	
	LET pvchrRFCOrd   = REPLACE(pvchrRFCOrd, 'Ñ', 'N');
	LET pvchrRFCOrd   = REPLACE(pvchrRFCOrd, 'ý', 'X');
	LET pvchrRFCOrd   = REPLACE(pvchrRFCOrd, 'Ý', 'X');
	LET pvchrRFCOrd   = REPLACE(pvchrRFCOrd, 'Ã', 'A');
	
    LET wmnyImporte = pmnyImporte;
    LET wmnyIVA = pmnyIVA;

	LET wchrcadena_01 = '||'||vintCveCesif||'|'||'Bancoppel'||'|'||vchrFechaValor2||'|'||'|'||TRIM(vchrCveRastreo)||'|'||intBancoOrd||'|';
	LET wchrcadena_02 = wmnyImporte||'|'||'1'::integer||'|'||pintTipoCtaOrd||'|'||TRIM(pvchrNombreOrd)||'|'||TRIM(pvchrCuentaOrd)||'|'||TRIM(pvchrRFCOrd)||'|';
	LET wchrcadena_03 = pintTipoCtaBenef||'|'||TRIM(pvchrNombreBenef)||'|'||TRIM(pvchrCtaBenef)||'|'||TRIM(pvchrRFCBenef)||'||||||'||TRIM(pvchrConceptoPago)||'|||||'||TRIM(pvchrRefCobranza1)||'|';
	LET wchrcadena_04 = pdecRefNum||'||'||TRIM(chrtopologia)||'|'||''||TRIM(wmedioent)||'|'||'|'||'0'||'|'||wmnyIVA||'||';
	LET wchrcadena_00 = TRIM(wchrcadena_01)||TRIM(wchrcadena_02)||TRIM(wchrcadena_03)||TRIM(wchrcadena_04);

-- SE COMENTA 28 01 2026 PARA COMENTAR EL USO DE BINARIO FIRMA Y vchrfirma = wchrcadena_00
	
	--LET wvchrfirma = space(512);
	
	--EXECUTE function bdispei:syn_sign(TRIM(wchrcadena_00), wvchrfirma, 21) 
	--INTO ret;
	
	--IF ret = 0 THEN 
		INSERT INTO tblpago(intpkpago, mnyimporte, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, 
							intcvetipoctabene, vchrcuentabenef, vchrrfcbenef, mnyiva, intrefnumerica, vchrconceptopago2, vchrrefcobranza, 
							chrusuarioprom, intcvetipopago, chrsentidopago, dtfechavalor, vchrclaverastreo, chrfolioprom, dtfechacaptura, 
							chrmotivocanc, chrmotivodev, chrtopologia, chrprioridad, cvecesifbcoord, cvecesifbcodest, chrtxop, sintlongcverastreo, vchrfirma )
		VALUES (intpktblpago, pmnyImporte, vchrestatusenvio, pvchrNombreOrd, pvchrCuentaOrd, pvchrRFCOrd, pintTipoCtaOrd, pvchrNombreBenef,
				pintTipoCtaBenef, pvchrCtaBenef, pvchrRFCBenef, pmnyIVA, pdecRefNum, pvchrConceptoPago, pvchrRefCobranza1,
				pchrUsuario, 1, 'E', vchrFechaValor, vchrCveRastreo, pchrFolioSuc, pdtfechacaptura, 
				'', '', chrtopologia, '0', intBancoOrd, vintCveCesif, vchrTranscargo, vsintLongCveRast, wchrcadena_00 );
    --END IF;
-- SE COMENTA 28 01 2026 PARA COMENTAR EL USO DE BINARIO FIRMA Y vchrfirma = wchrcadena_00
		
	IF pvchrNombreBenef = " " THEN
		INSERT INTO tblspeican(vchrnombreord, vchrcuentaord, vchrnombrebenef, vchrcuentabenef, vchrnombrebenem)
		VALUES (pvchrNombreOrd, pvchrCuentaOrd, pvchrNombreBenef, pvchrCtaBenef, pvchrNombreBene2);
	END IF;
    
    -- // Aplica la transaccion
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
    
    -- // Entrega el codigo de retorno y clave de rastreo.
    RETURN vchrcodret, vchrCveRastreo;
    
    END;
    
END PROCEDURE;