CREATE PROCEDURE "informix".sp_regordenctecte_pba( pEmpresa  CHAR(3),               --- EMPRESA
                                               pchrSucursal CHAR(4),            --- SUCURSAL
                                               pchrUsuario CHAR(8),             --- USUARIO
                                               pintBancoDest INTEGER,           --- NUMERO DEL BANCO DESTINO
                                               pmnyImporte MONEY(14,2),         --- IMPORTE TRANSACCION
                                               pchrTransuc  CHAR(4),            --- TRANSACCION
                                               pchrFolioSuc CHAR(16),           --- FOLIO
                                               pdtfechacaptura DATE,            --- FECHA CAPTURA
                                               pmnyComision MONEY(14,2),        --- COMISION
                                               pmnyIvaComis MONEY(14,2),        --- IVA DE LA COMISION
                                               pvchrNombreOrd VARCHAR(40),      --- NOMBRE DEL ORDENANTE
                                               pintTipoCtaOrd INTEGER,          --- TIPO DE CUENTA DEL ORDENANTE
                                               pvchrCuentaOrd VARCHAR(20),      --- CUENTA DEL ORDENANTE
                                               pvchrRfcOrd VARCHAR(18),         --- RFC DEL ORDENANTE
                                               pvchrNombreBenef VARCHAR(40),    --- NOMBRE DEL BENEFICIARIO
                                               pintTipoCtaBenef INTEGER,        --- TIPO DE CUENTA DEL BEBEFICIARIO
                                               pvchrCtaBenef VARCHAR(20),       --- CUENTA DEL BENEFICIARIO
                                               pvchrRFCBenef VARCHAR(18),       --- RFC DEL BENEFICIARIO
                                               pvchrConceptoPago VARCHAR(40),   --- CONCEPTO DEL PAGO
                                               pmnyIVA MONEY(14,2),             --- IVA
                                               pdecRefNum DECIMAL(7,0),         --- REFERENCIA NUMERICA
                                               pvchrRefCobranza1 VARCHAR(40) )  --- REFERENCIA COBRANZA
RETURNING CHAR(5), char(100), CHAR(30);

    DEFINE cVarDataErr      CHAR(100);
    DEFINE vchrcodret 	    CHAR(5);
    DEFINE vintcodret	    INTEGER;
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
    DEFINE vexiste_cta      CHAR(20);
    DEFINE vexiste_suc      CHAR(4);
	DEFINE vchrCtaOrdClabe  VARCHAR(20);
	DEFINE vchrCtaOrdtblp   VARCHAR(20);
    DEFINE vchrTelefono     CHAR(10);
    DEFINE intpktblpago     INTEGER;
    DEFINE vchrtopologia    CHAR(1);
    DEFINE intBancoOrd      INTEGER;
    DEFINE vintCveCesif     INTEGER;
    DEFINE vsintLongCveRast SMALLINT;
    DEFINE vdecRefNum       DECIMAL(7,0);
    DEFINE vexiste_clave    CHAR(40);
    DEFINE vind_dispon      CHAR(1);
    DEFINE vchrExisteCta    SMALLINT;
	DEFINE pvchrCuentaBenef	CHAR(20);
	DEFINE pvchrCveTransfer INTEGER;
	DEFINE vchrestatusenvio CHAR(1);
	DEFINE vfecha_hoy		DATE;
	DEFINE vcodret1         CHAR(5);
	DEFINE vfechaHabil		DATE;

    LET vtransaccion = 0;
    LET cVarDataErr = '';
    LET vdigitoverifica = 0;
    LET vexiste_cta = '';
    LET vexiste_suc = '';
    LET vchrExisteCta = 0;
	LET pvchrCuentaBenef='';
	LET pvchrCveTransfer = 90684;
	LET vchrestatusenvio = 'N';
	LET vfecha_hoy      = '';
	LET vcodret1       = "00000";


    BEGIN

    ON EXCEPTION SET vintcodret
        IF vintcodret <> 0 THEN
            LET vchrcodret = vintcodret;
            if vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            else
                ROLLBACK WORK;
            end if
            RETURN vchrcodret, cVarDataErr, '';
        END IF;
    END EXCEPTION;

    on exception in (-535)
        let vtransaccion = 1;
    end exception with resume;

    -- // Iniciar la transaccion
    if vtransaccion = 1 then
        COMMIT WORK;
        BEGIN WORK;
    else
        BEGIN WORK;
    end if;

    --- DEBUG FLAG
     --SET debug file to "/informix/ifg/sp_regordenctecte.out";
     --TRACE ON;

    -- // Inicializacion de variables
    LET vchrcodret = '000';
    LET vchrCveRastreo = '';
    LET vchrTarjeta = '';
    LET vind_dispon = '0';

    set isolation to dirty read;
    set lock mode to wait 3;

    LET pintTipoCtaOrd = pintTipoCtaOrd;
    LET pvchrCuentaOrd = pvchrCuentaOrd;

    SELECT ind_disponible, fecha_hoy
      INTO vind_dispon, vfecha_hoy
      FROM bdicheq:sc_fechas
     WHERE empresa = pEmpresa;

    IF vind_dispon = '0' THEN
        LET vchrcodret = '004'; -- // Falta parametro Fecha de Operacion
        LET cVarDataErr = 'SISTEMA DE CHEQUES NO DISPONIBLE.';
        RETURN vchrcodret, cVarDataErr, '';
    END IF

    -- // valida canal internet
    IF SUBSTR(pvchrCuentaOrd, 1, 2) <> '80' THEN
        if pchrSucursal = '5003' then
            EXECUTE PROCEDURE sp_validaspei_bpi(pvchrCuentaOrd, pvchrCtaBenef)
            INTO vchrcodret, cVarDataErr;

            IF trim(vchrcodret) <> '000' THEN
                RETURN vchrcodret, cVarDataErr, '';
            end if;
        end if;
    END IF;

    -- // Obtiene el numero de tarjeta
    IF pintTipoCtaOrd = 3 THEN
        SELECT num_tarjeta
          INTO vchrTarjeta
          FROM bdicheq:sc_tarjeta
         WHERE empresa = pEmpresa
           AND num_tarjeta = trim(pvchrCuentaOrd)
           AND status_tar = 'A';

        IF (vchrTarjeta is null) OR (vchrTarjeta = '') then
            LET vchrcodret = '019'; -- // Tarjeta no vigente Ã³ no asignada
            LET cVarDataErr = 'Tarjeta no vigente Ã³ no asignada';
            RETURN vchrcodret, cVarDataErr, '';
        ELSE
            -- // Verifica si se encuentra activa la cuenta de cheques
            IF SUBSTR(pvchrCuentaOrd, 1, 2) <> '80' THEN
                SELECT mae.cuenta
                  INTO pvchrCuentaOrd
                  FROM bdicheq:sc_maechq mae,
                       bdicheq:sc_tarjeta tar
                 WHERE mae.empresa = pEmpresa
                   AND mae.cuenta = tar.cuenta
                   AND mae.status_cta <> "2"
                   AND tar.empresa = pEmpresa
                   AND tar.num_tarjeta = vchrTarjeta
                   AND tar.status_tar = 'A';
            ELSE
                SELECT mae.cuenta_tf
                  INTO pvchrCuentaOrd
                  FROM bditransfer:tf_maecte mae,
                       bdicheq:sc_tarjeta tar
                 WHERE mae.cuenta_tf = tar.cuenta
                   AND mae.status_cta = "1"
                   AND tar.empresa = pEmpresa
                   AND tar.num_tarjeta = vchrTarjeta
                   AND tar.status_tar = 'A';
            END IF;

            IF pvchrCuentaOrd IS NULL OR pvchrCuentaOrd = '' THEN
                LET vchrcodret = '020'; -- // La cuenta Ord. no se encuentra activa
                LET cVarDataErr = 'La cuenta Ord. no se encuentra activa';
                RETURN vchrcodret, cVarDataErr, '';
            END IF
        END IF
    END IF

    -- // Valida la fecha del Movimiento
    IF (pdtfechacaptura is null) or (pdtfechacaptura = '') then
        LET vchrcodret = '001'; -- // Falta parametro Fecha de Operacion
        LET cVarDataErr = 'Falta parametro Fecha de Operacion';
        RETURN vchrcodret, cVarDataErr, '';
    END IF

    -- // Obtiene el Iva General
    SELECT valor
      INTO dIva
      FROM bdinteg:si_param
     WHERE cod_param = 47
       AND empresa = pEmpresa;

    IF dIva IS NULL THEN
        LET vchrcodret = '011';
        LET cVarDataErr = 'Parametro no encontrado';
        RETURN vchrcodret, cVarDataErr, '';
    END IF;

    -- // Obtiene la fecha de operacion
    SELECT vchrvalor
      INTO vchrparametro
      FROM tblparametros
     WHERE vchrcveparametro = 'FECHA_OPERACION';

    IF vchrparametro IS NULL THEN
        LET vchrcodret = '011';
        LET cVarDataErr = 'Parametro no encontrado';
        RETURN vchrcodret, cVarDataErr, '';
    END IF;

    -- // Formatea la fecha a mm/dd/aaaa
    LET vchrFechaValor = SUBSTR(TRIM(vchrparametro),4,2) || '/' || SUBSTR(TRIM(vchrparametro),0,2) || '/' || SUBSTR(TRIM(vchrparametro),7,4);

       -- // Verifica  la cuenta del ordenante a 18 digitos
    IF pintTipoCtaOrd = 40 THEN
        IF SUBSTR(pvchrCuentaOrd, 1, 2) <> '80' THEN
            SELECT cuenta_clabe
              INTO vchrCtaOrdClabe
              FROM bdicheq:sc_maechq
             WHERE cuenta = pvchrCuentaOrd;
        ELSE
            SELECT cta_clabe
              INTO vchrCtaOrdClabe
              FROM bditransfer:tf_maecte
             WHERE cuenta_tf = pvchrCuentaOrd;
        END IF;

        IF vchrCtaOrdClabe IS NULL THEN
            LET vchrCtaOrdClabe = '021'; -- // No se tiene cuenta clabe.
            LET cVarDataErr = 'Cuenta No valida. ';
            RETURN vchrcodret, cVarDataErr, '';
        END IF;

        IF vchrCtaOrdClabe IS NOT NULL THEN
			IF LENGTH(vchrCtaOrdClabe) >= 16 AND LENGTH(vchrCtaOrdClabe) < 18 THEN
				LET vchrCtaOrdClabe = LPAD(vchrCtaOrdClabe,18,'0');
            ELIF LENGTH(vchrCtaOrdClabe) > 18 THEN
                LET vchrcodret = '020'; -- // La cuenta debe ser de 18 digitos.
                LET cVarDataErr = 'La cuenta Clave del Ord. debe ser de 18 digitos';
                RETURN vchrcodret, cVarDataErr, '';
            END IF;

            -- // Verifica si existe la cuenta de cheques
            IF SUBSTR(pvchrCuentaOrd, 1, 2) <> '80' THEN
                SELECT cuenta
                  INTO vexiste_cta
                  FROM bdicheq:sc_maechq
                 WHERE empresa = pEmpresa
                   AND cuenta = pvchrCuentaOrd
                   AND status_cta <> "2";
            ELSE
                SELECT cuenta
                  INTO vexiste_cta
                  FROM bditransfer:tf_maecte
                 WHERE cuenta_tf = pvchrCuentaOrd
                   AND status_cta = "1";
            END IF;

            IF vexiste_cta is null OR vexiste_cta = '' THEN
                LET vchrcodret = '020'; -- // La cuenta Ord. no existe.
                LET cVarDataErr = 'La cuenta Ord. no existe Ã³ no se encuentra activa';
                RETURN vchrcodret, cVarDataErr, '';
            END IF
        ELIF LENGTH(pvchrCuentaOrd) = 11 THEN
            LET vchrcodret = '020'; -- // La cuenta Ord. no permite 11 digitos.
            LET cVarDataErr = 'La cuenta Ord. no permite solo 11 digitos';
            RETURN vchrcodret, cVarDataErr, '';
        END IF;
    END IF;

    IF pintTipoCtaOrd = 10 THEN
        IF LENGTH(pvchrCuentaOrd) = 10 THEN
            SELECT cuenta, telefono
              INTO vexiste_cta, vchrTelefono
              FROM bdicheq:sc_cuenta_telefono
             WHERE telefono = pvchrCuentaOrd;
        ELIF LENGTH(pvchrCuentaOrd) = 11 THEN
            SELECT cuenta, telefono
              INTO vexiste_cta, vchrTelefono
              FROM bdicheq:sc_cuenta_telefono
             WHERE cuenta = pvchrCuentaOrd;
        ELSE
            LET vchrcodret = '020'; -- // La cuenta Ord. no existe.
            LET cVarDataErr = 'La cuenta ordenante no existe';
            RETURN vchrcodret, cVarDataErr, '';
        END IF;

        IF vexiste_cta is null OR vexiste_cta = '' THEN
            LET vchrcodret = '020'; -- // La cuenta Ord. no existe.
            LET cVarDataErr = 'La cuenta Ord. no existe Ã³ no se encuentra activa';
            RETURN vchrcodret, cVarDataErr, '';
        END IF;

        SELECT cuenta
          INTO pvchrCuentaOrd
          FROM bdicheq:sc_maechq
         WHERE empresa = pEmpresa
           AND cuenta = vexiste_cta
           AND status_cta <> "2";

        IF pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN
            LET vchrcodret = '020'; -- // La cuenta Ord. no existe.
            LET cVarDataErr = 'La cuenta Ord. no existe Ã³ no se encuentra activa';
            RETURN vchrcodret, cVarDataErr, '';
        END IF;
    END IF;

    -- // Verifica la longitud de la cta benef
    IF pintTipoCtaBenef = 40 THEN
        IF LENGTH(pvchrCtaBenef) >= 16 AND LENGTH(pvchrCtaBenef) < 18 THEN
            LET pvchrCtaBenef = LPAD(pvchrCtaBenef,18,'0');

            EXECUTE PROCEDURE sp_validadv(pvchrCtaBenef)
            INTO vchrcodret, vdigitoverifica;

            IF vdigitoverifica = 0 THEN
                LET vchrcodret = '020'; -- // La Cuenta Clabe del Benefciario es Invalida
                LET cVarDataErr = 'La Cuenta Clabe del Benefciario es Invalida ';
                RETURN vchrcodret, cVarDataErr, '';
            END IF
        ELIF LENGTH(pvchrCtaBenef) <> 18 THEN
            LET vchrcodret = '020'; -- // La cuenta Benef debe ser de 18 digitos.
            LET cVarDataErr = 'La cuenta Benef debe ser de 18 digitos';
            RETURN vchrcodret, cVarDataErr, '';
        END IF;
	ELIF pintTipoCtaBenef = 10 AND pintBancoDest = pvchrCveTransfer  THEN
		SELECT cuenta_tf
			INTO pvchrCuentaBenef
			FROM bditransfer:tf_maecte
		WHERE telefono = pvchrCtaBenef
			AND status_cta = "1";
			IF pvchrCuentaBenef is null OR pvchrCuentaBenef = '' THEN
				SELECT cuenta
					INTO pvchrCuentaBenef
					FROM bdicheq:sc_cuenta_telefono
				WHERE telefono =pvchrCtaBenef;
			END IF;
			IF LENGTH(pvchrCuentaBenef) > 0 THEN
				LET vchrcodret = '1168';
				LET cVarDataErr = 'Cuenta destino Transfer, ingresa al menÃº: Transfer/Traspaso a cuenta Transfer';
                 RETURN vchrcodret, cVarDataErr, '';
			END IF;
    END IF;

    -- // Trae la transaccion de Cargo.
    SELECT vchrValor
      INTO vchrTranscargo
      FROM tblparametros
     WHERE vchrcveparametro = 'TRANSACC_CARGO';

    IF vchrTranscargo IS NULL OR vchrTranscargo = '' THEN
        LET vchrcodret = '022'; -- // Falta parametro de transaccion comision.
        RETURN vchrcodret, cVarDataErr, '';
    END IF;

    FOREACH WITH HOLD
        -- // Trae la transaccion de la Comision
        SELECT vchrValor
          INTO vchrComis
          FROM tblparametros
         WHERE vchrcveparametro = 'TRANSACC_COMISION'

        IF vchrComis IS NULL OR vchrCOmis = '' THEN
            LET vchrcodret = '023'; -- // Falta parametro de transaccion comision.
            RETURN vchrcodret, cVarDataErr, '';
        END IF;

        -- // Trae la transaccion del IVA de la Comision
        SELECT vchrValor
          INTO vchrIvaComis
          FROM tblparametros
         WHERE vchrcveparametro = 'TRANSACC_IVACOM';

        IF vchrIvaComis IS NULL OR vchrIvaComis = '' THEN
            LET vchrcodret = '023'; -- // Falta parametro de transaccion iva.
            RETURN vchrcodret, cVarDataErr, '';
        END IF;

        -- // Valida si existe la transaccion de la sucursal
        IF TRIM(pchrTransuc) = '' THEN
            --- LET pchrTransuc = LPAD(TRIM(vchrTranscargo), 4, '0');
            LET pchrTransuc = '0000';
        END IF;

		-- // GUARDA REGISTRO EN BDISPEI:TBLPAGO
		IF pintTipoCtaOrd = '40' THEN
			LET vchrCtaOrdtblp = vchrCtaOrdClabe;
        ELIF pintTipoCtaOrd = '10' THEN
			LET vchrCtaOrdtblp = vchrTelefono;
		ELSE
			LET vchrCtaOrdtblp = vchrTarjeta;
		END IF;

        EXECUTE PROCEDURE sp_regordenpagospei_pba(pEmpresa,         --- Empresa.
                                              pchrUsuario,      --- Usuario.
                                              pchrSucursal,     --- Sucursal.
                                              pchrFolioSuc,     --- Folio Sucursal.
                                              pintBancoDest,    --- Clave Banco Beneficiario.
                                              pdtfechacaptura,  --- Fecha Valor.
                                              1,                --- Tipo de pago CLIENTE-CLIENTE.
                                              NULL,             --- Clave de tipo de operacion.
                                              pmnyImporte,      --- Importe de la operacion.
                                              pvchrNombreOrd,   --- Nombre del Ordenante.
                                              vchrCtaOrdtblp,   --- Cuenta del ordenante.
                                              pvchrRfcOrd,      --- Rfc del Ordenante
                                              pvchrNombreBenef, --- Nombre del Beneficiario.
                                              pvchrCtaBenef,    --- Cuenta del Beneficiario.
                                              pvchrRFCBenef,    --- Rfc del Beneficiario.
                                              pmnyIVA,          --- Importe del Iva.
                                              pdecRefNum,       --- Referencia Numerica.
                                              pvchrRefCobranza1,--- Referencia de cobranza.
                                              NULL,             --- Concepto de pago con longitud de 210 pos.
                                              NULL,             --- Clave para el pago.
                                              NULL,             --- Nombre del beneficiario2.
                                              NULL,             --- Rfc Beneficiario2.
                                              NULL,             --- Concepto de pago2 a 40 pos.
                                              pvchrConceptoPago,--- Concepto de pago con longitud de 40 pos.
                                              vchrTranscargo,   --- chrtxop.
                                              pintTipoCtaOrd,   --- Tipo cuenta Ordenante.
                                              pintTipoCtaBenef) --- Tipo cuenta Beneficiario.
        INTO vchrcodret, cVarDataErr, vchrCveRastreo, intpktblpago, vchrFechaValor, vchrtopologia, intBancoOrd, vintCveCesif, vsintLongCveRast, vdecRefNum;

        IF trim(vchrcodret) <> '000' THEN
            if vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            else
                ROLLBACK WORK;
            end if;

            RETURN vchrcodret, cVarDataErr, '';
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

        -- // Aplicar el Cargo de la operacion SPEI - Ejecutar cargo a cheques
        EXECUTE PROCEDURE bdicheq:cargo_ref( pEmpresa,       --- empresa
                                             pchrSucursal,   --- sucursal
                                             pchrUsuario,    --- usuario
                                             vchrTranscargo, --- transaccion
                                             pchrTransuc,    --- transaccion suc
                                             pchrFolioSuc,   --- folio suc
                                             pvchrCuentaOrd, --- cuenta
                                             0,              --- no. cheque
                                             pmnyImporte,    --- monto
                                             '01',           --- divisa
                                             vchrCveRastreo, --- referencia
                                             vchrTarjeta,    --- no. tarjeta
                                             pchrUsuario)    --- usuario autoriza
        INTO vchrcodret, vchrtranret,dteFechacargo,vmnySdoDisp,vmnyMontoRet;

        -- // Valida si se pudo realizar el cargo
        IF trim(vchrcodret) <> '000' THEN
            LET cVarDataErr = 'No fue posible ejecutar el cargo a la cuenta de cheques';

            IF vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;

            RETURN vchrcodret, cVarDataErr, '';
        END IF;

        -- // Registra el detalle de la transaccion del pago
        INSERT INTO tbldetranpago(folio_suc, sucursal, usuario, fech_alt, transacc, empresa, cuenta, monto_tot, clave_rastreo)
        VALUES(pchrFolioSuc, pchrSucursal, pchrUsuario, pdtfechacaptura, vchrTranscargo, pEmpresa, pvchrCuentaOrd, pmnyImporte, vchrCveRastreo);

        -- // Aplicar la Comision de la operacion
        IF pmnyComision > 0 THEN
            EXECUTE PROCEDURE bdicheq:cargo_ref( pEmpresa,       --- empresa
                                                 pchrSucursal,   --- sucursal
                                                 pchrUsuario,    --- usuario
                                                 vchrComis,      --- transaccion
                                                 pchrTransuc,    --- transaccion suc
                                                 pchrFolioSuc,   --- folio suc
                                                 pvchrCuentaOrd, --- cuenta
                                                 0,              --- no. cheque
                                                 pmnyComision,   --- monto
                                                 "01",           --- divisa
                                                 vchrCveRastreo, --- referencia
                                                 vchrTarjeta,    --- no. tarjeta
                                                 pchrUsuario)    --- usuario autoriza
            INTO vchrcodret, vchrtranret,dteFechacargo,vmnySdoDisp,vmnyMontoRet;

            -- // Valida si se pudo realizar el cargo
            IF trim(vchrcodret) <> '000' THEN
                LET cVarDataErr = 'No fue posible ejecutar el cargo a la cuenta de cheques';

                if vtransaccion = 1 then
                    ROLLBACK WORK;
                    BEGIN WORK;
                else
                    ROLLBACK WORK;
                end if;

                RETURN vchrcodret, cVarDataErr, '';
            END IF;

            -- // Registra el detalle de la transaccion de la comision
            INSERT INTO tbldetranpago(folio_suc, sucursal, usuario, fech_alt, transacc, empresa, cuenta, monto_tot, clave_rastreo)
            VALUES(pchrFolioSuc, pchrSucursal, pchrUsuario, pdtfechacaptura, vchrComis, pEmpresa, pvchrCuentaOrd, pmnyComision, vchrCveRastreo);
        END IF;

        -- // Aplicar el IVA de la Comision
        IF pmnyIvaComis > 0 THEN
            EXECUTE PROCEDURE bdicheq:cargo_ref( pEmpresa,       --- empresa
                                                 pchrSucursal,   --- sucursal
                                                 pchrUsuario,    --- usuario
                                                 vchrIvaComis,   --- transaccion
                                                 pchrTransuc,    --- transaccion suc
                                                 pchrFolioSuc,   --- folio suc
                                                 pvchrCuentaOrd, --- cuenta
                                                 0,              --- no. cheque
                                                 pmnyIvaComis,   --- monto
                                                 "01",           --- divisa
												vchrCveRastreo, --- referencia
                                                 vchrTarjeta,    --- no. tarjeta
                                                 pchrUsuario)    --- usuario autoriza
            INTO vchrcodret, vchrtranret,dteFechacargo,vmnySdoDisp,vmnyMontoRet;

            -- // Valida si se pudo realizar el cargo
            IF trim(vchrcodret) <> '000' THEN
                LET cVarDataErr = 'No fue posible ejecutar el cargo a la cuenta de cheques';

                if vtransaccion = 1 then
                    ROLLBACK WORK;
                    BEGIN WORK;
                else
                    ROLLBACK WORK;
                end if;

                RETURN vchrcodret, cVarDataErr, '';
            END IF;

            -- // Registra el detalle de la transaccion del iva de la comision
            INSERT INTO tbldetranpago(folio_suc, sucursal, usuario, fech_alt, transacc, empresa, cuenta, monto_tot, clave_rastreo)
            VALUES(pchrFolioSuc, pchrSucursal, pchrUsuario, pdtfechacaptura, vchrIvaComis, pEmpresa, pvchrCuentaOrd, pmnyIvaComis, vchrCveRastreo);
        END IF;

        SELECT referencia
          INTO vexiste_clave
          FROM bdicheq:sc_movdia
         WHERE empresa = pEmpresa
           AND cuenta = pvchrCuentaOrd
           AND transacc = vchrTranscargo
           AND cancelad <> 'S'
           AND referencia = vchrCveRastreo;

        IF vexiste_clave = vchrCveRastreo THEN

           -- CONTROL DE ESTATUS DE ENVIO EN HORARIO DE LIQUIDACION FINAL
		IF CURRENT HOUR TO fraction > '17:58:00' AND CURRENT HOUR TO fraction < '18:05:00' THEN
			LET vchrestatusenvio='E';
			CALL "informix".sp_validafecha(pEmpresa, vfecha_hoy)
			RETURNING vcodret1, vfechaHabil;
			LET vchrFechaValor = to_char(vfechaHabil, '%m/%d/%Y');

		END IF;

            -- // INSERTA REGISTRO DE LA OPERACION EN LA TBLPAGO
            INSERT INTO tblpago(intpkpago, mnyimporte, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef,
                                intcvetipoctabene, vchrcuentabenef, vchrrfcbenef, mnyiva, intrefnumerica, vchrconceptopago2, vchrrefcobranza,
                                chrusuarioprom, intcvetipopago, chrsentidopago, dtfechavalor, vchrclaverastreo, chrfolioprom, dtfechacaptura,
                                chrmotivocanc, chrmotivodev, chrtopologia, chrprioridad, cvecesifbcoord, cvecesifbcodest, chrtxop, sintlongcverastreo)
            VALUES(intpktblpago, pmnyImporte, vchrestatusenvio, pvchrNombreOrd, vchrCtaOrdtblp, pvchrRFCOrd, pintTipoCtaOrd, pvchrNombreBenef,
                   pintTipoCtaBenef, pvchrCtaBenef, pvchrRFCBenef, pmnyIVA, vdecRefNum, pvchrConceptoPago, pvchrRefCobranza1,
                   pchrUsuario, 1, 'E', vchrFechaValor, vchrCveRastreo, pchrFolioSuc, pdtfechacaptura,
                   '', '', vchrtopologia, '0', intBancoOrd, vintCveCesif, vchrTranscargo, vsintLongCveRast);
        END IF;
    END FOREACH;

    -- // Aplica la transaccion
    if vtransaccion = 1 then
        COMMIT WORK;
        BEGIN WORK;
    else
        COMMIT WORK;
    end if;

    -- // Regresa el codigo de retorno y clave de rastreo.
    RETURN vchrcodret, cVarDataErr, vchrCveRastreo;

    END;

END PROCEDURE;