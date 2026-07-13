CREATE PROCEDURE "informix".sp_regordenpagospei_exp1(pEmpresa         CHAR(3),
                                                pchrUsuario      CHAR(8),
                                                pchrSucursal     CHAR(4),
                                                pchrFolioSuc     CHAR(16),
                                                pintBancoDestino INTEGER,
                                                pdFechaCaptura    DATE,
                                                pintTipoPago     INTEGER,
                                                pintTipoOper     INTEGER,
                                                pmnyImporteOP    MONEY(18,2),
                                                pvchrNombreOrd   VARCHAR(40),
                                                pvchrCuentaOrd   VARCHAR(20),
                                                pvchrRFCOrd      VARCHAR(18),
                                                pvchrNombreBenef VARCHAR(40),
                                                pvchrCtaBenef    VARCHAR(20),
                                                pvchrRFCBenef    VARCHAR(18),
                                                pmnyImporteIVA   MONEY(18,2),
                                                pdecRefNum       DECIMAL(7,0),
                                                pvchrRefCobranza1 VARCHAR(40),
                                                pvchrConceptoPago VARCHAR(210),
                                                pvchrClavePago   VARCHAR(10),
                                                pvchrNombreBenef2 VARCHAR(40),
                                                pvchrRFCBenef2   VARCHAR(18),
                                                pvchrCtaBenef2   VARCHAR(20),
                                                pvchrConceptoPago2 VARCHAR(40),
                                                pchrTransaccion  CHAR(4),
                                                pintTipoCtaOrd   INTEGER,
                                                pintTipoCtaBenef INTEGER)

RETURNING CHAR(5), CHAR(100), CHAR(30), INTEGER, VARCHAR(10), CHAR(1), INTEGER, INTEGER, SMALLINT, DECIMAL(7,0);

    -- // #############################################################################################################################
    -- // sp_regordenpagospei
    -- // Version              1.0.0
    -- // Obejtivo:            Registra un pago de SPEI en tblpago dependiendo del tipo de pago
    -- // Parametros de Entrada:
    -- //          pchrUsuario      : Clave del usuario de promocion que registra la operacion.
    -- //          pchrSucursal     : Sucursal que registra el movimiento.
    -- //          pchrFolioSuc     : Folio de la Sucursal.
    -- //          pintBancoDestino : Clave CESIF del banco beneficiario de la orden.
    -- //          pdFechaCaptura   : Fecha Captura
    -- //          pintTipoPago     : Clave tipo de pago.
    -- //          pintTipoOper     : Clave tipo de operacion.
    -- //          pmnyImporteOP    : Importe de la operacion.
    -- //          pvchrNombreOrd   : Nombre del cliente ordenante.
    -- //          pvchrCuentaOrd   : Numero de cuenta del cliente ordenante.
    -- //          pvchrNombreBenef : Nombre del beneficiario de la orden.
    -- //          pvchrCtaBenef    : CLABE del beneficiario de la orden.
    -- //          pvchrRFCBenef    : (opcional) RFC del beneficiario de la orden.
    -- //          pmnyImporteIVA   : Importe del Iva.
    -- //          pdecRefNum       : Dato numerico que servira de referencia al beneficiario para indicar el concepto del pago.
    -- //          pvchrRefCobranza1: Se usara obligatoriamente para cuentas concentradoras de cobranza.
    -- //          pvchrConceptoPago: Concepto de pago a 210 pos.
    -- //          pvchrClavePago   : Clave que el usuario utilizará para identificarse.
    -- //          pvchrNombreBenef2: Nombre del beneficiario 2 de la orden.
    -- //          pvchrRFCBenef2   : (opcional) RFC del beneficiario 2 de la orden.
    -- //          pvchrCtaBenef2   : CLABE del beneficiario 2 de la orden.
    -- //          pvchrConceptoPago2:Concepto de pago a 40 pos.
    -- //          pchrTransaccion  : Transaccion de Cargo.
    -- //          pintTipoCtaOrd   : Clave del tipo de Cuenta del Ordenante.
    -- //          pintTipoCtaBenef : Clave del tipo de Cuenta del Beneficiario.
    -- //          pvchrRFCOrd      : Rfc del cliente.
    -- // Parametros de Salida:
    -- // 	Codigo de Retorno      : '000' - Si la orden pudo ser registrada correctamente.
    -- // 				<> '000' - Indica el error ocurrido al tratar de registrar la orden de pago.
    -- //    Descripcion            : Descripcion del error.
    -- //    Clave de Rastreo       : Entrega la clave de rastreo generada para la orden de pago registrada.
    -- // Creado por:          Alejandro Rueda Sanchez
    -- // ModIFicado por:
    -- // Ultima Modificacion: Agosto - 2007
    -- //                      Creación de SPL
    -- // #############################################################################################################################

    -- // Definicion de variables
    DEFINE cVarDataErr       VARCHAR(100);
    DEFINE vchrparametro     VARCHAR(255);
    DEFINE chrcodret         CHAR(5);
    DEFINE chrcodret2        CHAR(5);
    DEFINE charcodret3       CHAR(50);
    DEFINE intcodret         INTEGER;
    DEFINE intcodret2        INTEGER;
    DEFINE chrcodret3        CHAR(50);
    DEFINE vchrFechaValor    VARCHAR(10);
    DEFINE chrEstadoProceso  CHAR(1);
    DEFINE intcontador       INTEGER;
    DEFINE inttpooper        INTEGER;
    DEFINE intpktblpago      INTEGER;
    DEFINE chrspl            CHAR(7);
    DEFINE vchrtopologia     CHAR(1);
    DEFINE intBancoOrd       INTEGER;
    DEFINE vchrCLABEOrd      VARCHAR(18);
    DEFINE intTpoCtaOpcional INTEGER;
    DEFINE chrabonachq       CHAR(1);
    DEFINE vintCveCesif      INTEGER;
    DEFINE vsintLongCveRast  SMALLINT;
    DEFINE vintfolioop	     INTEGER;
    DEFINE v_montomin	     MONEY;
    DEFINE vchrCveRastreo    VARCHAR(30);
    DEFINE vdigverif         CHAR(1);
    DEFINE vdecRefNum        DECIMAL(7,0);

	DEFINE vchTpoCta	    CHAR(2);
    DEFINE vchFlagSpei		CHAR(3);

    ON EXCEPTION SET intcodret, intcodret2, chrcodret3
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_regordenpagospei.err";
        TRACE ON;
        IF intcodret <> 0 THEN
            LET chrcodret = intcodret;
            LET chrcodret2 = intcodret2;
            LET charcodret3 = chrcodret3;
            RETURN chrcodret, 'ERROR DE B/D', '', 0, '', '', 0, 0, 0, 0;
        END IF;
    END EXCEPTION;

    -- DEBUG FLAG
    --SET debug file to "/informix/sp_regordenpagospei.out";
    --TRACE ON;

    -- // Inicializacion de variables
    LET chrcodret = '000';
    LET intcontador = 0;
    LET v_montomin = 0;
    LET vdigverif = '';
    LET vdecRefNum = pdecRefNum;

    LET vchTpoCta	    = '';
	LET vchFlagSpei		= '';

    set isolation to dirty read;
    SET LOCK MODE TO WAIT 3;
	
	-- // TERCERO a TERCERO
    IF pintTipoPago = 1 THEN 
        IF pvchrNombreOrd IS NULL OR pvchrNombreOrd = '' OR
           pintTipoCtaOrd = 0 OR pintTipoCtaOrd IS NULL OR
           pvchrCuentaOrd IS NULL OR pvchrCuentaOrd = '' OR
           pvchrRFCOrd IS NULL OR pvchrRFCOrd = '' OR
           pvchrNombreBenef IS NULL OR pvchrNombreBenef = '' OR
           pintTipoCtaBenef = 0 OR pintTipoCtaBenef IS NULL OR
           pvchrCtaBenef IS NULL OR pvchrCtaBenef = '' OR
           pvchrConceptoPago2 IS NULL OR pvchrConceptoPago2 = '' THEN
       --- pdecRefNum IS NULL OR pdecRefNum = 0 THEN
                LET chrcodret = '011';
                LET cVarDataErr = 'Faltan campos obligatorios para el tipo de pago';
                RETURN chrcodret, cVarDataErr, '', '', 0, '', '', 0, 0, 0;
        END IF;
    END IF;

    -- // Obtiene la fecha de operacion
    SELECT vchrvalor
      INTO vchrparametro
      FROM tblparametros
     WHERE vchrcveparametro = 'FECHA_OPERACION';
     
    IF vchrparametro IS NULL THEN
        LET chrcodret = '011';
        LET cVarDataErr = 'Parametro no encontrado';
        RETURN chrcodret, cVarDataErr, '', '', 0, '', '', 0, 0, 0;
    END IF;

    -- // Formatea la fecha a mm/dd/aaaa
    LET vchrFechaValor = SUBSTR(TRIM(vchrparametro),4,2) || '/' ||
    SUBSTR(TRIM(vchrparametro),0,2) || '/' || SUBSTR(TRIM(vchrparametro),7,4);

    {
	---31/01/2020
	-- // Valida que no esté bloqueada la base de datos
    SELECT vchrvalor
      INTO vchrparametro
      FROM tblparametros
     WHERE vchrcveparametro = 'BLOQUEO_A_USUARIOS';
     
    IF vchrparametro IS NULL THEN
        LET chrcodret = '011';
        LET cVarDataErr = 'Parametro no encontrado';
        RETURN chrcodret, cVarDataErr, '', '', 0, '', '', 0, 0, 0;
    END IF;
    
    IF (vchrparametro * 1) = 1 THEN
        LET chrcodret = '012';
        LET cVarDataErr = 'Por el momento, SPEI no recibe pagos; favor de intentar mas tarde....';
        RETURN chrcodret, cVarDataErr, '', '', 0, '', '', 0, 0, 0;
    END IF;
	--- 31/01/2020
	}

    -- // Verifica horario de operación SPEI y reglas para horario extendido.
    EXECUTE PROCEDURE spei_validaoperacion(pvchrCuentaOrd, pmnyImporteOP, pchrSucursal)
    INTO vchFlagSpei, vchTpoCta;

    IF vchFlagSpei <> '000' THEN   
	   LET chrcodret = '013';
	   LET cVarDataErr = 'Operacion fuera de horario de servicio';
	   RETURN chrcodret, cVarDataErr, '', '', 0, '', '', 0, 0, 0;
	END IF;
	
    -- // Obtiene la topologia por default
    SELECT vchrvalor
      INTO vchrparametro
      FROM tblparametros
     WHERE vchrcveparametro = 'DEFAULT_TOPOLOGIA';
     
    IF vchrparametro IS NULL THEN
        LET chrcodret = '011';
        LET cVarDataErr = 'Parametro no encontrado';
        RETURN chrcodret, cVarDataErr, '', '', 0, '', '', 0, 0, 0;
    END IF;
    
    LET vchrtopologia = TRIM(vchrparametro);

    -- // Obtiene el banco ordenante (Bancoppel)
    SELECT vchrvalor
      INTO vchrparametro
      FROM tblparametros
     WHERE vchrcveparametro ='@CVECESIFBCO';
     
    IF vchrparametro IS NULL THEN
        LET chrcodret = '011';
        LET cVarDataErr = 'Parametro no encontrado';
        RETURN chrcodret, cVarDataErr, '', '', 0, '', '', 0, 0, 0;
    END IF;
    
    LET intBancoOrd = (vchrparametro * 1);
    
     -- // Valida que exista la sucursal en central
    SELECT count(*)
      INTO intcontador
      FROM bdinteg:si_sucursales
     WHERE sucursal = pchrSucursal;
     
    IF intcontador = 0 THEN
        LET chrcodret = '016';
        LET cVarDataErr = 'Sucursal no valida ó no existe en central';
        RETURN chrcodret, cVarDataErr, '', '', 0, '', '', 0, 0, 0;
    END IF;

    -- // Valida que exista el usuario en central
    SELECT count(*)
      INTO intcontador
      FROM bdinteg:si_ejecut
     WHERE ejecutivo = pchrUsuario;
     
    IF intcontador = 0 THEN
        LET chrcodret = '017';
        LET cVarDataErr = 'Usuario no valido';
        RETURN chrcodret, cVarDataErr, '', '', 0, '', '', 0, 0, 0;
    END IF;

    -- // Valida que exista el tipo de pago
    SELECT COUNT(*)
      INTO intcontador
      FROM tbltipopago
     WHERE intcvetipopago = pintTipoPago;
     
    IF intcontador = 0 THEN
        LET chrcodret = '018';
        LET cVarDataErr = 'No existe el tipo de pago';
        RETURN chrcodret, cVarDataErr, '', '', 0, '', '', 0, 0, 0;
    END IF;

    -- // Valida que exista el tipo de operacion
    SELECT intcontatoper,chrdevabonachq
      INTO inttpooper,chrabonachq
      FROM tbltipopago
     WHERE intcvetipopago = pintTipoPago;
     
    IF inttpooper = 1 THEN
        SELECT COUNT(*)
          INTO intcontador
          FROM tbltipooperacion
         WHERE intcvetpooperacion = pintTipoOper;
        
        IF intcontador = 0 THEN
            LET chrcodret = '019';
            LET cVarDataErr = 'No existe tipo de operacion';
            RETURN chrcodret, cVarDataErr, '', '', 0, '', '', 0, 0, 0;
        END IF;
    END IF;

    -- // Valida monto minimo permitido para la operacion
    SELECT mnymontomin
      INTO v_montomin
      FROM tbltipopago
     WHERE intcvetipopago = pintTipoPago;
     
    IF pmnyImporteOP < v_montomin THEN
        LET chrcodret = '020';
        LET cVarDataErr = 'Monto menor al minimo permitido para el tipo de pago';
        RETURN chrcodret, cVarDataErr, '', '', 0, '', '', 0, 0, 0;
    END IF;

    -- // Valida el banco
    SELECT cvecesif
      INTO vintCveCesif
      FROM tblbanco
     WHERE cvecesif = pintBancoDestino
       AND intindice >= 0;
       
    IF vintCveCesif IS NULL THEN
        LET chrcodret = '021';
        LET cVarDataErr = 'Banco no Valido';
        RETURN chrcodret, cVarDataErr, '', '', 0, '', '', 0, 0, 0;
 -- // Se agrega validación 40137
    ELSE
        IF  vintCveCesif = intBancoOrd THEN
			LET chrcodret = '021';
			LET cVarDataErr = 'Banco no Valido';
			RETURN chrcodret, cVarDataErr, '', '', 0, '', '', 0, 0, 0;
		END IF;
    END IF;

    -- // Valida que error si la transaccion no tiene valor
    IF pchrTransaccion IS NULL OR pchrTransaccion = '' THEN
        LET chrcodret = '022';
        LET cVarDataErr = 'No existe la Transaccion';
        RETURN chrcodret, cVarDataErr, '', '', 0, '', '', 0, 0, 0;
    END IF;

    -- // Justifica con ceros la transaccion.
    IF TRIM(pchrTransaccion) <> '' THEN
        LET pchrTransaccion = LPAD(TRIM(pchrTransaccion), 4, '0');
    END IF;

    -- // Valida que no se repita el folio de sucursal para la fecha de operacion
    SELECT COUNT(*)
      INTO intcontador
      FROM tblpago
     WHERE intpkpago > 0
       AND chrfolioprom = pchrFolioSuc;
       
    IF intcontador > 0 THEN
        LET chrcodret = '023';
        LET cVarDataErr = 'El Folio de sucursal ya existe para esta fecha';
        RETURN chrcodret, cVarDataErr, '', '', 0, '', '', 0, 0, 0;
    END IF;
	
    -- // Compara la clave del banco en la clabe del beneficiario, si es por cuenta CLABE.
    IF pintTipoCtaBenef = 40 THEN
       IF SUBSTR(pvchrCtaBenef, 1, 3) <> substring(trim(pintBancoDestino::VARCHAR(10))
          FROM LENGTH(trim(pintBancoDestino::VARCHAR(10))) -2) THEN
               LET chrcodret = '025';
               LET cVarDataErr = 'Existe un error en la captura de la cuenta clabe ó el banco que se capturó es incorrecto';
               RETURN chrcodret, cVarDataErr, '', '', 0, '', '', 0, 0, 0;
       END IF;
    END IF;
	
	-- // Obtiene folio del pago
    EXECUTE PROCEDURE sp_obtsigfolioop('TBLPAGO') 
    INTO chrcodret, intpktblpago;
        
    IF (chrcodret * 1) <> 0 THEN
       LET cVarDataErr = 'Faltan Campos obligatorios para el pago';
       RETURN chrcodret, cVarDataErr, '', '', 0, '', '', 0, 0, 0;
    END IF;

    IF vdecRefNum IS NULL or vdecRefNum = 0 THEN
       LET vdecRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);
    END IF;
	
	-- // Genera la clave de Rastreo
    EXECUTE PROCEDURE sp_obtsigfolioop('FOLIO_CVERASTREO')
    INTO chrCodRet, vintfolioop;
    
    EXECUTE PROCEDURE bdicheq:digver11(pvchrCuentaOrd)
    INTO chrCodRet, vdigverif;
    
    LET vchrCveRastreo = 'COPL' || TRIM(pchrSucursal) || UPPER(TRIM(pchrUsuario)) || LPAD(vintfolioop||'', 7, '0') || vdigverif;

    -- // Valida que no se repita la clave de rastreo para la fecha de operacion
    SELECT COUNT(*)
      INTO intcontador
      FROM tblpago
     WHERE intpkpago > 0
       AND vchrclaverastreo = vchrCveRastreo;
       
    IF intcontador > 0 THEN
        LET chrcodret = '024';
        LET cVarDataErr = 'Clave de rastreo duplicada';
        RETURN chrcodret, cVarDataErr, '', '', 0, '', '', 0, 0, 0;
    END IF;

    LET vsintLongCveRast = LENGTH(vchrCveRastreo);

    RETURN chrcodret, '', vchrCveRastreo, intpktblpago, vchrFechaValor, vchrtopologia, intBancoOrd, vintCveCesif, vsintLongCveRast, vdecRefNum;

END PROCEDURE;