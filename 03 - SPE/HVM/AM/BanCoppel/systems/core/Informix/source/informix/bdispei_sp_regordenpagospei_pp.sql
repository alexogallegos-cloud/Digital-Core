CREATE PROCEDURE "informix".sp_regordenpagospei_pp(pEmpresa         CHAR(3),
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

RETURNING CHAR(5), CHAR(100), CHAR(30);

    --// ***************************************************************************
    --// sp_regordenpagospei
    --// Version              1.0.0
    --// Obejtivo:            Registra un pago de SPEI en tblpago dependiendo del tipo de pago
    --// Parametros de Entrada:
    --//          pchrUsuario      : Clave del usuario de promocion que registra la operacion.
    --//          pchrSucursal     : Sucursal que registra el movimiento.
    --//          pchrFolioSuc     : Folio de la Sucursal.
    --//          pintBancoDestino : Clave CESIF del banco beneficiario de la orden.
    --//          pdFechaCaptura   : Fecha Captura
    --//          pintTipoPago     : Clave tipo de pago.
    --//          pintTipoOper     : Clave tipo de operacion.
    --//          pmnyImporteOP    : Importe de la operacion.
    --//          pvchrNombreOrd   : Nombre del cliente ordenante.
    --//          pvchrCuentaOrd   : Numero de cuenta del cliente ordenante.
    --//          pvchrNombreBenef : Nombre del beneficiario de la orden.
    --//          pvchrCtaBenef    : CLABE del beneficiario de la orden.
    --//          pvchrRFCBenef    : (opcional) RFC del beneficiario de la orden.
    --//          pmnyImporteIVA   : Importe del Iva.
    --//          pdecRefNum       : Dato numerico que servira de referencia al beneficiario para indicar el concepto del pago.
    --//          pvchrRefCobranza1: Se usara obligatoriamente para cuentas concentradoras de cobranza.
    --//          pvchrConceptoPago: Concepto de pago a 210 pos.
    --//          pvchrClavePago   : Clave que el usuario utilizará para identificarse.
    --//          pvchrNombreBenef2: Nombre del beneficiario 2 de la orden.
    --//          pvchrRFCBenef2   : (opcional) RFC del beneficiario 2 de la orden.
    --//          pvchrCtaBenef2   : CLABE del beneficiario 2 de la orden.
    --//          pvchrConceptoPago2:Concepto de pago a 40 pos.
    --//          pchrTransaccion  : Transaccion de Cargo.
    --//          pintTipoCtaOrd   : Clave del tipo de Cuenta del Ordenante.
    --//          pintTipoCtaBenef : Clave del tipo de Cuenta del Beneficiario.
    --//          pvchrRFCOrd      : Rfc del cliente.
    --// Parametros de Salida:
    --// 	Codigo de Retorno      : '000' - Si la orden pudo ser registrada correctamente.
    --// 				<> '000' - Indica el error ocurrido al tratar de registrar la orden de pago.
    --//    Descripcion            : Descripcion del error.
    --//    Clave de Rastreo       : Entrega la clave de rastreo generada para la orden de pago registrada.
    --// Creado por:          Alejandro Rueda Sanchez
    --// ModIFicado por:
    --// Ultima Modificacion: Agosto - 2007
    --//                      Creación de SPL
    --// ***************************************************************************

    --//Definicion de variables
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
    DEFINE chrtopologia      CHAR(1);
    DEFINE intBancoOrd       INTEGER;
    DEFINE vchrCLABEOrd      VARCHAR(18);
    DEFINE intTpoCtaOpcional INTEGER;
    DEFINE chrabonachq       CHAR(1);
    DEFINE vintCveCesif      INTEGER;
    DEFINE vsintLongCveRast  SMALLINT;
    DEFINE vintfolioop	     INTEGER;
    DEFINE v_montomin	     MONEY;
    DEFINE vchrCveRastreo    VARCHAR(30);
	DEFINE wmnyImporte 		 DECIMAL (14,2);
    DEFINE wmnyIVA 			 DECIMAL (14,2);
		
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
	
    ON EXCEPTION SET intcodret, intcodret2, chrcodret3
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/sp_regordenpagospei_pp.err";
        TRACE ON;
        IF intcodret <> 0 THEN
            LET chrcodret = intcodret;
            LET chrcodret2 = intcodret2;
            LET charcodret3 = chrcodret3;
            RETURN chrcodret, 'ERROR DE B/D', '';
        END IF;
    END EXCEPTION;

	--- SET DEBUG FILE TO '/resplogifx/conciliachq/spei/sp_regordenpagospei_pp.out';
    --- TRACE ON;

    --Inicializacion de variables
    LET chrcodret = '000';
    LET intcontador = 0;
    LET v_montomin = 0;

    set isolation to dirty read;
    set lock mode to wait 3;

    --//Genera la clave de Rastreo
    EXECUTE PROCEDURE sp_obtsigfolioop('FOLIO_CVERASTREO')
    INTO chrCodRet, vintfolioop;
    
    LET vchrCveRastreo = 'COPL' || TRIM(pchrSucursal) || UPPER(TRIM(pchrUsuario)) || LPAD(vintfolioop||'', 7, '0');

    --LET vchrFechaValor=pdFechaCaptura;   

      SELECT vchrvalor
           INTO vchrFechaValor
          FROM bdispei:tblparametros
          WHERE vchrcveparametro = 'FECHA_OPERACION'; 
                 
     LET vchrFechaValor = SUBSTR(vchrFechaValor, 4, 2) || '/' || SUBSTR(vchrFechaValor, 1, 2) || '/' || SUBSTR(vchrFechaValor, 7, 4);
	 LET vchrFechaValor2 = SUBSTR(vchrFechaValor,7,4) || SUBSTR(vchrFechaValor,1,2) || SUBSTR(vchrFechaValor,4,2);
	 
	{
	--24/09/2021
    --//Verifica que la operacion se encuentre dentro del horario de servicio.
    SELECT COUNT(*)
      INTO intcontador
      FROM tblhorario
     WHERE intpkhorario = 1
       AND CURRENT BETWEEN tmhorainicio AND tmhoralimite;
     
    IF intcontador = 0 THEN
        LET chrcodret = '013';
        LET cVarDataErr = 'Operacion fuera de horario de servicio';
        RETURN chrcodret, cVarDataErr, '';
    END IF;
	-- 24/09/2021
	}

    --//Obtiene la topologia por default
    SELECT vchrvalor
      INTO vchrparametro
      FROM tblparametros
     WHERE vchrcveparametro = 'DEFAULT_TOPOLOGIA';
     
    IF vchrparametro IS NULL THEN
        LET chrcodret = '011';
        LET cVarDataErr = 'Parametro no encontrado';
        RETURN chrcodret, cVarDataErr, '';
    END IF;
    
    LET chrtopologia = TRIM(vchrparametro);

    --//Obtiene el banco ordenante (Bancoppel)
    SELECT vchrvalor
      INTO vchrparametro
      FROM tblparametros
     WHERE vchrcveparametro ='@CVECESIFBCO';
     
    IF vchrparametro IS NULL THEN
        LET chrcodret = '011';
        LET cVarDataErr = 'Parametro no encontrado';
        RETURN chrcodret, cVarDataErr, '';
    END IF;
    
    LET intBancoOrd = (vchrparametro * 1);
    
    { **************************************************
    --//Valida que no se haya realizado el pase contable
    SELECT chrstatus
      INTO chrEstadoProceso
      FROM tblctrlproceso
     WHERE intcveproceso = 2
       AND dtfecha = vchrFechaValor;
       
    IF chrEstadoProceso = '1' THEN
        LET chrcodret = '015';
        LET cVarDataErr = 'Ya se realizo el pase contable';
        RETURN chrcodret, cVarDataErr, '';
    END IF;
    ************************************************** }
    
    --//Valida que exista la sucursal en central
    SELECT count(*)
      INTO intcontador
      FROM bdinteg:si_sucursales
      WHERE sucursal = pchrSucursal;
      
    IF intcontador = 0 THEN
        LET chrcodret = '016';
        LET cVarDataErr = 'Sucursal no valida ó no existe en central';
        RETURN chrcodret, cVarDataErr, '';
    END IF;

    --// Valida que exista el usuario en central
    SELECT count(*)
      INTO intcontador
      FROM bdinteg:si_ejecut
      WHERE ejecutivo = pchrUsuario;
      
    IF intcontador = 0 THEN
        LET chrcodret = '017';
        LET cVarDataErr = 'Usuario no valido';
        RETURN chrcodret, cVarDataErr, '';
    END IF;

    --Valida que exista el tipo de pago
    SELECT COUNT(*)
      INTO intcontador
      FROM tbltipopago
     WHERE intcvetipopago = pintTipoPago;
     
    IF intcontador = 0 THEN
        LET chrcodret = '018';
        LET cVarDataErr = 'No existe el tipo de pago';
        RETURN chrcodret, cVarDataErr, '';
    END IF;

    --Valida que exista el tipo de operacion
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
            RETURN chrcodret, cVarDataErr, '';
        END IF;
    END IF;

    --//Valida monto minimo permitido para la operacion
    SELECT mnymontomin
      INTO v_montomin
      FROM tbltipopago
     WHERE intcvetipopago = pintTipoPago;
     
    IF pmnyImporteOP < v_montomin THEN
        LET chrcodret = '020';
        LET cVarDataErr = 'Monto menor al minimo permitido para el tipo de pago';
        RETURN chrcodret, cVarDataErr, '';
    END IF;

    --//Valida el banco
    SELECT cvecesif
      INTO vintCveCesif
      FROM tblbanco
     WHERE cvecesif = pintBancoDestino
       AND intindice >= 0;
       
    IF vintCveCesif IS NULL THEN
        LET chrcodret = '021';
        LET cVarDataErr = 'Banco no Valido';
        RETURN chrcodret, cVarDataErr, '';
    END IF;

    --//Valida que error si la transaccion no tiene valor
    IF pchrTransaccion IS NULL OR pchrTransaccion = '' THEN
        LET chrcodret = '022';
        LET cVarDataErr = 'No existe la Transaccion';
        RETURN chrcodret, cVarDataErr, '';
    END IF;

    --//Justifica con ceros la transaccion.
    IF TRIM(pchrTransaccion) <> '' THEN
        LET pchrTransaccion = LPAD(TRIM(pchrTransaccion), 4, '0');
    END IF;

    --//Valida que no se repita el folio de sucursal para la fecha de operacion
    SELECT COUNT(*)
      INTO intcontador
      FROM tblpago
     WHERE intpkpago > 0
       AND chrfolioprom = pchrFolioSuc
       AND dtfechacaptura = pdFechaCaptura;
       
    IF intcontador > 0 THEN
        LET chrcodret = '023';
        LET cVarDataErr = 'El Folio de sucursal ya existe para esta fecha';
        RETURN chrcodret, cVarDataErr, '';
    END IF;

    --//Valida que no se repita la clave de rastreo para la fecha de operacion
    SELECT COUNT(*)
      INTO intcontador
      FROM tblpago
     WHERE intpkpago > 0
       AND vchrclaverastreo = vchrCveRastreo
       AND dtfechavalor = vchrFechaValor;
       
    IF intcontador > 0 THEN
        LET chrcodret = '024';
        LET cVarDataErr = 'Clave de rastreo duplicada';
        RETURN chrcodret, cVarDataErr, '';
    END IF;

    LET vsintLongCveRast = LENGTH(vchrCveRastreo);

    --//TERCERO a TERCERO
    IF pintTipoPago = 1 THEN --TERCERO a TERCERO
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
                RETURN chrcodret, cVarDataErr, '';
        END IF;

        --//Compara la clave del banco en la clabe del beneficiario, si es por cuenta CLABE.
        IF pintTipoCtaBenef = 40 THEN
            IF SUBSTR(pvchrCtaBenef, 1, 3) <> substring(trim(pintBancoDestino::VARCHAR(10))
                FROM LENGTH(trim(pintBancoDestino::VARCHAR(10))) -2) THEN
                    LET chrcodret = '025';
                    LET cVarDataErr = 'Existe un error en la captura de la cuenta clabe ó el banco que se capturó es incorrecto';
                    RETURN chrcodret, cVarDataErr, '';
            END IF;
        END IF;
		
		{*****
        --//Obtiene folio del pago
        EXECUTE PROCEDURE sp_obtsigfolioop('FOLIO_CVERASTREO') 
        INTO chrcodret, intpktblpago;
        
        IF (chrcodret * 1) <> 0 THEN
            LET cVarDataErr = 'Faltan Campos obligatorios para el pago';
            RETURN chrcodret, cVarDataErr, '';
        END IF;
		*****}

		LET intpktblpago = vintfolioop;
        IF pdecRefNum IS NULL or pdecRefNum = 0 THEN
            LET pdecRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);
        END IF;

		
	-- // NUEVOS CAMBIOS PARA GENERAR EL CIFRADO
	IF pmnyImporteOP > 400000.00 THEN
		LET wmedioent = 'h2h';
	ELSE
		LET wmedioent = '';
	END IF;
	
	EXECUTE PROCEDURE bdinteg:sp_quitar_acentos(pvchrNombreOrd)
	INTO pvchrNombreOrd;
	
	EXECUTE PROCEDURE bdinteg:sp_quitar_acentos(pvchrNombreBenef)
	INTO pvchrNombreBenef;

	LET pvchrConceptoPago2 = REPLACE(pvchrConceptoPago2, 'Ñ', 'N');
	LET pvchrConceptoPago2 = REPLACE(pvchrConceptoPago2, 'ñ', 'n');
	LET pvchrConceptoPago2 = REPLACE(pvchrConceptoPago2, 'á', 'a');
	LET pvchrConceptoPago2 = REPLACE(pvchrConceptoPago2, 'é', 'e');
	LET pvchrConceptoPago2 = REPLACE(pvchrConceptoPago2, 'í', 'i');
	LET pvchrConceptoPago2 = REPLACE(pvchrConceptoPago2, 'ó', 'o');
	LET pvchrConceptoPago2 = REPLACE(pvchrConceptoPago2, 'ú', 'u');
	LET pvchrConceptoPago2 = REPLACE(pvchrConceptoPago2, 'Á', 'A');
	LET pvchrConceptoPago2 = REPLACE(pvchrConceptoPago2, 'É', 'E');
	LET pvchrConceptoPago2 = REPLACE(pvchrConceptoPago2, 'Í', 'I');
	LET pvchrConceptoPago2 = REPLACE(pvchrConceptoPago2, 'Ó', 'O');
	LET pvchrConceptoPago2 = REPLACE(pvchrConceptoPago2, 'Ú', 'U');
	LET pvchrConceptoPago2 = REPLACE(pvchrConceptoPago2, 'Ü', 'U');
	LET pvchrConceptoPago2 = REPLACE(pvchrConceptoPago2, 'ý', 'X');
	LET pvchrConceptoPago2 = REPLACE(pvchrConceptoPago2, 'Ý', 'X');
	LET pvchrConceptoPago2 = REPLACE(pvchrConceptoPago2, 'Ã', 'A');
	
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
	
    LET wmnyImporte = pmnyImporteOP;
    LET wmnyIVA = pmnyImporteIVA;

	LET wchrcadena_01 = '||'||vintCveCesif||'|'||'Bancoppel'||'|'||vchrFechaValor2||'|'||'|'||TRIM(vchrCveRastreo)||'|'||intBancoOrd||'|';
	LET wchrcadena_02 = wmnyImporte||'|'||'1'::integer||'|'||pintTipoCtaOrd||'|'||TRIM(pvchrNombreOrd)||'|'||TRIM(pvchrCuentaOrd)||'|'||TRIM(pvchrRFCOrd)||'|';
	LET wchrcadena_03 = pintTipoCtaBenef||'|'||TRIM(pvchrNombreBenef)||'|'||TRIM(pvchrCtaBenef)||'|'||TRIM(pvchrRFCBenef)||'||||||'||TRIM(pvchrConceptoPago2)||'|||||'||TRIM(pvchrRefCobranza1)||'|';
	LET wchrcadena_04 = pdecRefNum||'||'||TRIM(chrtopologia)||'|'||''||TRIM(wmedioent)||'|'||'|'||'0'||'|'||wmnyIVA||'||';
	LET wchrcadena_00 = TRIM(wchrcadena_01)||TRIM(wchrcadena_02)||TRIM(wchrcadena_03)||TRIM(wchrcadena_04);
	
-- SE COMENTA 12 03 2026 PARA COMENTAR EL USO DE BINARIO FIRMA Y vchrfirma = wchrcadena_00
	--LET wvchrfirma = space(512);
	
	--EXECUTE function bdispei:syn_sign(TRIM(wchrcadena_00), wvchrfirma, 21) 
	--INTO ret;
	
	  --IF ret = 0 THEN		
        INSERT INTO tblpago(intpkpago, mnyimporte, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, 
                            intcvetipoctabene, vchrcuentabenef, vchrrfcbenef, mnyiva, intrefnumerica, vchrconceptopago2, vchrrefcobranza, 
                            chrusuarioprom, intcvetipopago, chrsentidopago, dtfechavalor, vchrclaverastreo, chrfolioprom, dtfechacaptura, 
                            chrmotivocanc, chrmotivodev, chrtopologia, chrprioridad, cvecesifbcoord, cvecesifbcodest, chrtxop, sintlongcverastreo, vchrfirma)
        VALUES (intpktblpago, pmnyImporteOP, 'N', pvchrNombreOrd, pvchrCuentaOrd, pvchrRFCOrd, pintTipoCtaOrd, pvchrNombreBenef,
                pintTipoCtaBenef, pvchrCtaBenef, pvchrRFCBenef, pmnyImporteIVA, pdecRefNum, pvchrConceptoPago2, pvchrRefCobranza1,
                pchrUsuario, pintTipoPago, 'E', vchrFechaValor, vchrCveRastreo, pchrFolioSuc, pdFechaCaptura, 
                '', '', chrtopologia, '0', intBancoOrd, vintCveCesif, pchrTransaccion, vsintLongCveRast, wchrcadena_00);

                --Se agrega al sp la inserción en ésta tabla.
		INSERT INTO tbldetranpago(folio_suc, sucursal, usuario, fech_alt, transacc, empresa, cuenta, monto_tot, clave_rastreo)
		VALUES(pchrFolioSuc, pchrSucursal, pchrUsuario, pdfechacaptura, pchrTransaccion, pEmpresa, pvchrCuentaOrd, pmnyImporteop, vchrCveRastreo);
      --END IF;
-- SE COMENTA 12 03 2026 PARA COMENTAR EL USO DE BINARIO FIRMA Y vchrfirma = wchrcadena_00
		
    end if;

    RETURN chrcodret, '', vchrCveRastreo;

END PROCEDURE;