CREATE PROCEDURE "informix".reversion_web(pempresa  CHAR(3),
                                      psucursal CHAR(4),
                                      pusuario  CHAR(8),
                                      pfolio    CHAR(16),
                                      ptiporev  CHAR(1))
RETURNING CHAR(5);
    
	DEFINE wfechoy              DATE;
    DEFINE wnaturaleza          CHAR(1);
    DEFINE wvalida_docto        CHAR(1);
    DEFINE wtipo                CHAR(1);
    DEFINE vstatus_cta          CHAR(1);
    DEFINE vid_autor            CHAR(1);
    DEFINE vtpo_per_valida      CHAR(1);
    DEFINE cStatus              CHAR(1);
    DEFINE wedoctacnt           CHAR(1);
    DEFINE wsobregira           CHAR(1);
    DEFINE wtiptran             CHAR(2);
    DEFINE wtpcheque            CHAR(2);
    DEFINE vid_transacc         CHAR(2);
    DEFINE vid_canal            CHAR(2);
    DEFINE vestado_oper         CHAR(2);
    DEFINE vestado_cta          CHAR(2);
    DEFINE wtransacc            CHAR(4);
    DEFINE vtranusoccc          CHAR(4);
    DEFINE vtrancancta          CHAR(4);
    DEFINE vtranintccc          CHAR(4);
    DEFINE vtranusosbg          CHAR(4);
    DEFINE vtranintsbg          CHAR(4);
    DEFINE wcomision            CHAR(4);
    DEFINE wsuc_cuen            CHAR(4);
    DEFINE wproducto            CHAR(4);
    DEFINE vProdCrec            CHAR(4);
    DEFINE vtrancorrespchq      CHAR(4);
    DEFINE vtran_limit          CHAR(4);
    DEFINE cTransaccAbonoEnvio  CHAR(4);
    DEFINE cTransaccAbonoEnvioC CHAR(4);
    DEFINE vtranpagosbg         CHAR(4);
    DEFINE wsuc_tran            CHAR(4);
    DEFINE cTranRetEfect		CHAR(4);
	DEFINE cTranTraspCgo	    CHAR(4);
    DEFINE pcod_ret              CHAR(5);
    DEFINE cod_ret2             CHAR(5);
    DEFINE cRetRevSac           CHAR(5);
    DEFINE cod_ret_lim          CHAR(5);
    DEFINE vidtransacc          CHAR(5);
    DEFINE vcodret_reg          CHAR(5);
    DEFINE cCodRetIndicador		CHAR(6);
    DEFINE vfolio               CHAR(7);
    DEFINE wusuario             CHAR(8);
    DEFINE vuser_limit          CHAR(8);
    DEFINE vSQL                 CHAR(10);
    DEFINE vnum_tarjeta         CHAR(16);
    DEFINE wcuenta              CHAR(20);
    DEFINE wnum_cte             CHAR(20);
    DEFINE cCuenta              CHAR(20);
    DEFINE vclave_rastreo       CHAR(30);
    DEFINE wreferencia          CHAR(40);
    DEFINE cod_ret3             CHAR(50);
    DEFINE desc_err             CHAR(50);
    DEFINE vmsje_limites        CHAR(80);
    DEFINE sql_err              INTEGER;
    DEFINE isam_err             INTEGER;
    DEFINE wnum_serial          INTEGER;
    DEFINE wnum_cheq            INTEGER;
    DEFINE vtransaccion         INTEGER;
    DEFINE cont_exist       	INTEGER; 
    DEFINE vserial              INTEGER;
    DEFINE vvueltas             INTEGER;
    DEFINE wdias_ret            SMALLINT;
    DEFINE contador             SMALLINT;
    DEFINE wchq_exp_mes         SMALLINT;
    DEFINE iExisteTrx           SMALLINT;
    DEFINE wexiste              SMALLINT;
    DEFINE wcompend             MONEY(14,2);
    DEFINE wmonto_tot           MONEY(14,2);
    DEFINE wfirme               MONEY(14,2);
    DEFINE wen_sbc              MONEY(14,2);
    DEFINE wremesas             MONEY(14,2);
    DEFINE wimp_sbg_ccc         MONEY(14,2);
    DEFINE wimp_chq_sbg         MONEY(14,2);
    DEFINE wimp_int_ccc         MONEY(14,2);
    DEFINE wimp_int_sbg         MONEY(14,2);
    DEFINE wsaldo_cuenta        MONEY(14,2);
    DEFINE wsdo_actual          MONEY(14,2);
    DEFINE wsdo_retenido        MONEY(14,2);
    DEFINE wsdo_sbc             MONEY(14,2);
    DEFINE wsdo_cong            MONEY(14,2);
    DEFINE vfecha_operacion     DATE;
	DEFINE vcod_ret             CHAR(5);
    DEFINE vtrancorrespchqoxxo  CHAR(4);
	DEFINE vtrancorrespchqseven CHAR(4);
    DEFINE vreferencia          CHAR(40);
    DEFINE wcorresp             SMALLINT;
    DEFINE vExisLimProd         SMALLINT;
    DEFINE vTrxExentaLimProd    SMALLINT;
    DEFINE vExisAcumCtaNvl2     SMALLINT;
	--RQM 09 704.Se definen las variables requeridas para la consulta del saldo disponible.DHG
	DEFINE mImpSbgCcc       	MONEY(14,2); --Monto del importe de sobregiro de compras de comercio.
	DEFINE mSaldoSBC        	MONEY(14,2); --Monto del saldo inmovilizado (salvo buen cobro) de la cuenta.
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.	
	
  DEFINE iContTxPermRet		INTEGER;		--Contador para la validacion de transaccion con reversion de saldo inmovilizado.
	DEFINE mMontoInmov			MONEY(14,2); 	--Monto invomilizado en cuenta para reversion de abonos	
	DEFINE cReferenciaMovDia	CHAR(40);		--Referencia del movimiento del dia, se utiliza en el proceso de reversion de cobranza automatica.
	DEFINE iEstatusCtrCob		INTEGER;		--Estatus para la actualizacion de registro en tabla de control de cobranza
	DEFINE mMontoRetenido	MONEY(14,2);	--Monto pendiente por retener de la tabla de control de cobranza
	DEFINE cFolioSucInmov		CHAR(16);		--Folio suc del movimiento de inmovilizacion 
    
    LET wfechoy              = '';
    LET wnaturaleza          = '';
    LET wvalida_docto        = '';
    LET wtipo                = '';
    LET vstatus_cta          = '';
    LET vid_autor            = '';
    LET vtpo_per_valida      = '';
    LET cStatus              = '';
    LET wedoctacnt           = '';
    LET wsobregira           = '';
    LET wtiptran             = '';
    LET wtpcheque            = '';
    LET vid_transacc         = '';
    LET vid_canal            = '';
    LET vestado_oper         = '';
    LET vestado_cta          = '';
    LET wtransacc            = '';
    LET vtranusoccc          = '';
    LET vtrancancta          = '';
    LET vtranintccc          = '';
    LET vtranusosbg          = '';
    LET vtranintsbg          = '';
    LET wcomision            = '';
    LET wsuc_cuen            = '';
    LET wproducto            = '';
    LET vProdCrec            = '';
    LET vtrancorrespchq      = '';
    LET vtran_limit          = '';
    LET cTransaccAbonoEnvio  = '';
    LET cTransaccAbonoEnvioC = '';
    LET vtranpagosbg         = '';
    LET wsuc_tran            = '';
    LET cTranRetEfect		 = '';
	LET cTranTraspCgo	     = '';
    LET pcod_ret              = '00000';
    LET cod_ret2             = '';
    LET cRetRevSac           = '00000';
    LET cod_ret_lim          = '';
    LET vidtransacc          = '';
    LET vcodret_reg          = '';
    LET cCodRetIndicador     = '';
    LET vfolio               = '';
    LET wusuario             = '';
    LET vuser_limit          = '';
    LET vSQL                 = '';
    LET vnum_tarjeta         = '';
    LET wcuenta              = '';
    LET wnum_cte             = '';
    LET cCuenta              = '';
    LET vclave_rastreo       = '';
    LET wreferencia          = '';
    LET cod_ret3             = '';
    LET desc_err             = '';
    LET vmsje_limites        = '';
    LET sql_err              = 0;
    LET isam_err             = 0;
    LET wnum_serial          = 0;
    LET wnum_cheq            = 0;
    LET vtransaccion         = 0;
    LET cont_exist       	 = 0;
    LET vserial              = 0;
    LET vvueltas             = 0;
    LET wdias_ret            = 0;
    LET contador             = 0;
    LET wchq_exp_mes         = 0;
    LET iExisteTrx           = 0;
    LET wexiste              = 0;
    LET wcompend             = 0.00;
    LET wmonto_tot           = 0.00;
    LET wfirme               = 0.00;
    LET wen_sbc              = 0.00;
    LET wremesas             = 0.00;
    LET wimp_sbg_ccc         = 0.00;
    LET wimp_chq_sbg         = 0.00;
    LET wimp_int_ccc         = 0.00;
    LET wimp_int_sbg         = 0.00;
    LET wsaldo_cuenta        = 0.00;
    LET wsdo_actual          = 0.00;
    LET wsdo_retenido        = 0.00;
    LET wsdo_sbc             = 0.00;
    LET wsdo_cong            = 0.00;
	LET vfecha_operacion     = TODAY;
	LET vcod_ret             = '000';
    LET vtrancorrespchqoxxo  = '';
	LET vtrancorrespchqseven  = '';
    LET vreferencia          = '';
    LET wcorresp             = 0;
    LET vExisLimProd         = 0;
    LET vTrxExentaLimProd    = 0;
    LET vExisAcumCtaNvl2     = 0;
	--RQM 09 704. Se inicializan las variables para el llamado y retorno de consulta de saldo. DHG.
	LET mImpSbgCcc			=0.00;
	LET mSaldoSBC   		=0.00;
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';
	LET iContTxPermRet		=0;
	LET mMontoInmov			=0.00;	
	LET cReferenciaMovDia	= '';
	LET iEstatusCtrCob		= 0;
	LET mMontoRetenido	= 0.00;
	LET cFolioSucInmov		= '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        IF sql_err <> 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/reversion.err";
			TRACE ON;
            LET pcod_ret = sql_err;
            LET cod_ret2 = isam_err;
            LET cod_ret3 = desc_err;
            IF SUBSTR(cCuenta, 1, 2) <> '80' THEN
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
            END IF;
            RETURN pcod_ret;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;
    
    ON EXCEPTION IN (-211, -242, -243, -244, -311)
        LET pcod_ret = '00999';
        RETURN pcod_ret;
    END EXCEPTION WITH RESUME;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/reversion.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    LET pempresa = pempresa;
    LET psucursal = psucursal;
    LET pusuario = pusuario;
    LET pfolio =  pfolio;
    LET ptiporev = ptiporev;
    LET pcod_ret = "00000";
    LET cRetRevSac = "00000";
    LET cCodRetIndicador = "000000";
    
    SELECT {+INDEX(sc_movdia idx_movdia2a)} 
           FIRST 1 cuenta
      INTO cCuenta
      FROM sc_movdia
     WHERE folio_suc = pfolio
       AND empresa = pempresa
       AND cancelad <> 'S';
    
    -- // PARA CUENTAS TRANSFER
    IF SUBSTR(cCuenta, 1, 2) = '80' THEN
        
        LET pcod_ret = '00999';
        
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;

        RETURN pcod_ret;
        
        /* #############################################################################################################################################    
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            BEGIN WORK;
        END IF;
        
        SELECT valor
          INTO vidtransacc
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = 'TranReverTransfer';
        
        CALL sp_transfer_online_reverso( vidtransacc, cCuenta, pfolio, pusuario )
        RETURNING vcodret_reg, vserial;
        
        IF ( vcodret_reg is null OR vcodret_reg <> '000' ) OR ( vserial is null OR vserial = 0 ) THEN
            LET pcod_ret = '999';
        
            IF vtransaccion = 1 THEN
                COMMIT WORK;
                BEGIN WORK;
            ELSE
                COMMIT WORK;
            END IF;

            RETURN pcod_ret;
        END IF;
        
        COMMIT WORK;
        
        LET vvueltas = 0;
        LET cStatus = 'N';
        
        WHILE cStatus IN('N','E')
            SELECT status
              INTO cStatus
              FROM sc_transfer_online
             WHERE no_serial = vserial
               AND cuenta = cCuenta
               AND folio_suc = pfolio
               AND id_transacc = vidtransacc;
        
            IF cStatus IN('F','X') THEN
                EXIT WHILE;
            ELSE
                LET vSQL = 'sleep 3';
                SYSTEM vSQL;

                LET vvueltas = vvueltas + 1;

                IF vvueltas > 5 THEN
                    EXIT WHILE;
                END IF;
            END IF;
        END WHILE;
        
        IF ( cStatus is null OR cStatus = '' OR cStatus IN('N','E') ) THEN
            UPDATE {+INDEX(sc_transfer_online idx_transferonline_serctafoltra)}
                   sc_transfer_online
               SET status = 'T'
             WHERE no_serial = vserial
               AND cuenta = cCuenta
               AND folio_suc = pfolio
               AND id_transacc = vidtransacc;
            
            LET pcod_ret = '24';
            
            IF vtransaccion = 1 THEN
                BEGIN WORK;
            END IF;
            
            return pcod_ret;
        
        ELIF cStatus = 'X' THEN
        
            SELECT cod_ret
              INTO pcod_ret
              FROM sc_transfer_online
             WHERE no_serial = vserial
               AND cuenta = cCuenta
               AND folio_suc = pfolio
               AND id_transacc = vidtransacc;
			  
            
            IF vtransaccion = 1 THEN
                BEGIN WORK;
            END IF;
            
            return pcod_ret;
        END IF;
        
        BEGIN WORK;
        
        UPDATE {+INDEX(sc_movdia idx_movdia2a)} 
               sc_movdia
           SET cancelad = "S"
         WHERE folio_suc = pfolio
           AND empresa = pempresa;
        
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;
        ############################################################################################################################################# */
        
    ELSE
        
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            BEGIN WORK;
        END IF;
        
        SELECT {+INDEX(sc_fechas idx_fechas1)}
               fecha_hoy
          INTO wfechoy
          FROM sc_fechas
         WHERE empresa = pempresa;
        
        SELECT valor
          INTO vProdCrec
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam ="PRODCREC";
        
        -- // Abono en efectivo por Orden de Pago a Cuenta Prest
        SELECT valor
          INTO cTransaccAbonoEnvio  
          FROM bdisac:sac_param
         WHERE empresa = '001'
           AND cod_param = '5070011';
        
        -- // Abono en Cargo a cuenta por Orden de Pago
        SELECT valor
          INTO cTransaccAbonoEnvioC   
          FROM bdisac:sac_param
         WHERE empresa = '001'
           AND cod_param = '5070012';
        
        SELECT {+INDEX(sc_movdia idx_movdia2a),
                +INDEX(bdinteg:si_transacc idx_transacc2)}
               COUNT(*)
          INTO contador
          FROM sc_movdia m,
               bdinteg:si_transacc t
         WHERE m.empresa = pempresa
           AND m.folio_suc = pfolio
           AND m.cancelad <> "S"
           AND t.numero = m.transacc
           AND t.empresa = m.empresa
           AND t.reversable = "S";
        
        -- #############################  INICIO reversion de servicios  ############################# --
        IF contador = 0 THEN
            LET cont_exist = 0;
            
            SELECT COUNT (referencia1)
              INTO cont_exist
              FROM bdisac:sac_movimientos
             WHERE folio_suc = pfolio
               AND status_cancelado <> 'S';
            
            IF cont_exist > 0 THEN
                CALL bdisac:sp_ReversionSac(pempresa,psucursal,pusuario, pfolio)
                RETURNING cRetRevSac;

                IF cRetRevSac < 0 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                    LET pcod_ret = '00999';
                END IF;
            END IF;
            
            SELECT {+INDEX (bditef:tef_operaciones  idx_tef_operaciones1)} 
                   clave_rastreo
              INTO vclave_rastreo
              FROM bditef:tef_operaciones
             WHERE folio_suc = pfolio
               AND clave_rastreo <> ""
               AND fecha_trans = wfechoy
               AND cve_status = 'PE'
               AND sucursal = psucursal;
            
            IF (vclave_rastreo is not null OR vclave_rastreo <> '') THEN
                UPDATE {+INDEX (bditef:tef_operaciones  idx_tef_operaciones1)}
                       bditef:tef_operaciones
                   SET cve_status = '04'
                 WHERE folio_suc = pfolio
                   AND clave_rastreo <> ""
                   AND fecha_trans = wfechoy
                   AND cve_status = 'PE'
                   AND sucursal = psucursal;
            END IF;
        END IF;
        -- #############################  FINAL reversion de servicios  ############################# --
        
        IF (contador = 0) THEN
            SELECT COUNT(*)
              INTO contador
              FROM sc_docret_sbc
             WHERE empresa = pempresa
               AND folio_suc = pfolio
               AND fecha_alta = wfechoy;
            
            IF (contador = 0) THEN
                LET cont_exist = 0;
            
                SELECT {+INDEX (bdisuc:ss_operaciones  idx_ss_operaciones2)}
                       COUNT (folio_oper)
                  INTO cont_exist
                  FROM bdisuc:ss_operaciones
                 WHERE sucursal = psucursal
                   AND folio_sucursal = pfolio
                   AND reversado <> '1';
                
                IF cont_exist > 0 THEN
                    CALL bdisuc:reversion(pempresa,psucursal,pusuario, pfolio,ptiporev)
                    RETURNING cRetRevSac;
                END IF;
                
                RETURN pcod_ret;
            ELSE
                UPDATE sc_docret_sbc
                   SET cancelado = "S"
                 WHERE empresa = pempresa
                   AND folio_suc = pfolio
                   AND fecha_alta = wfechoy;
                
                RETURN pcod_ret;
            END IF
        END IF
        
        SELECT valor
          INTO vtrancancta
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = "trancancta";
        
        SELECT valor
          INTO vtranusoccc
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = "tranusoccc";
        
        SELECT valor
          INTO vtranintccc
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = "tranintccc";
        
        SELECT valor
          INTO vtranusosbg
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = "tranusosbg";
        
        SELECT valor
          INTO vtranintsbg
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = "tranintsbg";
        
        SELECT valor
          INTO vtrancorrespchq
          FROM bdicheq:sc_param
         WHERE empresa = pempresa
           AND codparam = "trancorrespchq";
           
        SELECT valor
          INTO vtrancorrespchqoxxo
          FROM bdicheq:sc_param
        WHERE empresa = pempresa
           AND codparam = "trancorrespchqoxxo";
		   
        SELECT valor
            INTO vtrancorrespchqseven
        FROM bdicheq:sc_param
            WHERE empresa = '001'
                AND codparam = 'trancorrespchqseven';		
				
		SELECT valor
		  INTO cTranRetEfect
		  FROM bdicheq: sc_param
		 WHERE empresa = "001"
		   AND codparam = "retefectbancefec";
		
		SELECT valor
		  INTO cTranTraspCgo
		  FROM bdicheq: sc_param
		 WHERE empresa = "001"
		   AND codparam = "traspctasbancefeccgo";
        
        SELECT valor
          INTO vtranpagosbg
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = "tranpagosbg";
        
        FOREACH
            SELECT {+INDEX(sc_movdia idx_movdia2a),
                    +INDEX(bdinteg:si_transacc idx_transacc2)}
                   md.num_serial, md.transacc, md.cuenta, md.monto_tot, md.firme, md.en_sbc, md.remesas,
                   md.dias_ret, md.num_cheq, tr.naturaleza, tr.valida_docto, tr.tipo_tran, tr.sobregira,
                   md.referencia, md.suc_cuen, md.producto, tr.tpcheque, md.usuario, md.sucursal, md.edo_cta
              INTO wnum_serial, wtransacc, wcuenta, wmonto_tot, wfirme, wen_sbc, wremesas, 
                   wdias_ret, wnum_cheq, wnaturaleza, wvalida_docto, wtiptran, wsobregira,
                   wreferencia, wsuc_cuen, wproducto, wTpCheque, wusuario, wsuc_tran, wedoctacnt
              FROM sc_movdia md,
                   bdinteg:si_transacc tr
             WHERE md.empresa = pempresa
               AND md.folio_suc = pfolio
               AND md.cancelad <> "S"
               AND tr.numero = md.transacc
               AND tr.empresa = md.empresa
               AND tr.reversable = "S"
             ORDER BY tr.naturaleza DESC
            
            SELECT tpper_valida
              INTO vtpo_per_valida
              FROM sc_producto
             WHERE producto = wproducto;
            
            LET wimp_sbg_ccc = 0;
            LET wimp_chq_sbg = 0;
            LET wimp_int_ccc = 0;
            LET wimp_int_sbg = 0;
            LET wchq_exp_mes = 0;
            LET wcompend     = 0;
            
            IF wvalida_docto = "S" AND wTpCheque = "01" THEN
                LET wchq_exp_mes  = 1;
            END IF
            
            IF   wtransacc = vtranusoccc THEN
                LET wimp_sbg_ccc = wmonto_tot;
            ELIF wtransacc = vtranusosbg THEN
                LET wimp_chq_sbg = wmonto_tot;
            ELIF wtransacc = vtranpagosbg THEN
                LET wimp_chq_sbg = wmonto_tot;
            ELIF wtransacc = vtranintccc THEN
                LET wimp_int_ccc = wmonto_tot;
            ELIF wtransacc = vtranintsbg THEN
                LET wimp_int_sbg = wmonto_tot;
            ELIF wtiptran = "05"         THEN
                LET wcompend = wmonto_tot;
                LET wcomision = TRIM(wtransacc);
            END IF;
            
            SELECT sdo_actual, status_cta, num_cte
              INTO wsdo_actual, vstatus_cta, wnum_cte
              FROM sc_maechq
             WHERE empresa = pempresa
               AND cuenta = wcuenta;
            
            IF wnaturaleza = "C" THEN
                UPDATE {+INDEX(sc_movdia idx_sc_movdia_02)} 
                       sc_movdia
                   SET cancelad = "S"
                 WHERE cancelad <> "S"
                   AND num_serial = wnum_serial;
                
                IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                    IF vtransaccion = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    EXIT FOREACH;
                END IF;
                
                INSERT INTO sc_movdia VALUES
                ( 0, pfolio, psucursal, pusuario, wfechoy, wfechoy, current hour to fraction(3), wtransacc, wsuc_cuen, wproducto, pempresa, 
                  wcuenta, " ", wnum_cheq, wmonto_tot * -1, 0, 0, 0, 0, "S", vstatus_cta, wsdo_actual, "0000", "REV", 0, vnum_tarjeta, "" ,"", vfecha_operacion);
                
				/*
                IF wedoctacnt is not null AND wedoctacnt <> '' THEN
                    UPDATE sc_maechq SET
                           sdo_actual    = sdo_actual + wmonto_tot,
                           imp_cgos_mes  = imp_cgos_mes - wmonto_tot,
                           num_cgos_mes  = num_cgos_mes - 1,
                           chq_exp_mes   = chq_exp_mes - wchq_exp_mes,
                           imp_sbg_ccc   = imp_sbg_ccc + wimp_sbg_ccc,
                           imp_int_ccc   = imp_int_ccc + wimp_int_ccc,
                           imp_chq_sbg   = imp_chq_sbg + wimp_chq_sbg,
                           imp_int_sbg   = imp_int_sbg + wimp_int_sbg,
                           com_pendiente = com_pendiente + wcompend,
                           status_cta    = wedoctacnt
                     WHERE empresa = pempresa
                       AND cuenta  = wcuenta;
                ELSE
                    UPDATE sc_maechq SET
                           sdo_actual    = sdo_actual + wmonto_tot,
                           imp_cgos_mes  = imp_cgos_mes - wmonto_tot,
                           num_cgos_mes  = num_cgos_mes - 1,
                           chq_exp_mes   = chq_exp_mes - wchq_exp_mes,
                           imp_sbg_ccc   = imp_sbg_ccc + wimp_sbg_ccc,
                           imp_int_ccc   = imp_int_ccc + wimp_int_ccc,
                           imp_chq_sbg   = imp_chq_sbg + wimp_chq_sbg,
                           imp_int_sbg   = imp_int_sbg + wimp_int_sbg,
                           com_pendiente = com_pendiente + wcompend
                     WHERE empresa = pempresa
                       AND cuenta  = wcuenta;
                END IF;
				*/
				
				UPDATE sc_maechq SET
					   sdo_actual    = sdo_actual + wmonto_tot,
					   imp_cgos_mes  = imp_cgos_mes - wmonto_tot,
					   num_cgos_mes  = num_cgos_mes - 1,
					   chq_exp_mes   = chq_exp_mes - wchq_exp_mes,
					   imp_sbg_ccc   = imp_sbg_ccc + wimp_sbg_ccc,
					   imp_int_ccc   = imp_int_ccc + wimp_int_ccc,
					   imp_chq_sbg   = imp_chq_sbg + wimp_chq_sbg,
					   imp_int_sbg   = imp_int_sbg + wimp_int_sbg,
					   com_pendiente = com_pendiente + wcompend
				 WHERE empresa = pempresa
				   AND cuenta  = wcuenta;
                
                IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                    IF vtransaccion = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    EXIT FOREACH;
                END IF;
                
                IF vstatus_cta = '2' THEN
                    IF wedoctacnt <> '8' THEN
                        UPDATE sc_maechq
                           SET status_cta = "1",
                               fec_cancelac = "",
                               motivo = " "
                         WHERE empresa = pempresa
                           AND cuenta = wcuenta;
                    ELSE
                        UPDATE sc_maechq
                           SET fec_cancelac = "",
                               motivo = " "
                         WHERE empresa = pempresa
                           AND cuenta = wcuenta;
                    END IF
                END IF
                
                IF wtiptran = "05" THEN
                    UPDATE sc_detcomis
                       SET pago_com = pago_com - wmonto_tot,
                           estado_com = "P"
                     WHERE empresa = pempresa
                       AND cuenta = wcuenta
                       AND comision = wcomision
                       AND fecult_pago = wfechoy;
                END IF;
                
                IF wvalida_docto = "S" AND wTpCheque = "01" THEN
                    UPDATE {+INDEX(sc_contch idx_contch1)} 
                           sc_contch
                       SET estado = "A",
                           importe = 0
                     WHERE empresa = pempresa
                       AND cuenta = wcuenta
                       AND numero = wnum_cheq;

                    UPDATE sc_contch_hist
                       SET status = "V"
                     WHERE empresa = pempresa
                       AND cuenta = wcuenta
                       AND numchq = wnum_cheq
                       AND folio_suc = pfolio;
                END IF;
                    
                SELECT {+INDEX (bditef:tef_operaciones  idx_tef_operaciones1)} clave_rastreo
                  INTO vclave_rastreo
                  FROM bditef:tef_operaciones
                 WHERE folio_suc = pfolio
                   AND clave_rastreo <> ""
                   AND fecha_trans = wfechoy
                   AND cve_status = 'PE'
                   AND sucursal = psucursal;
                
                IF (vclave_rastreo is not null OR vclave_rastreo <> '') THEN
                    UPDATE {+INDEX (bditef:tef_operaciones  idx_tef_operaciones1)}
                           bditef:tef_operaciones
                       SET cve_status = '04'
                     WHERE folio_suc = pfolio
                       AND clave_rastreo <> ""
                       AND fecha_trans = wfechoy
                       AND cve_status = 'PE'
                       AND sucursal = psucursal;
                END IF;
				
				IF wtransacc = cTranRetEfect THEN
					UPDATE bdicheq:sc_acumdiacorrespred
					SET monto_acum = monto_acum - wmonto_tot
					WHERE cuenta = wcuenta;
				END IF;
				
				IF wtransacc = cTranTraspCgo THEN
					UPDATE bdicheq:sc_acumdiacorresptec
					SET monto_acum = monto_acum - wmonto_tot
					WHERE cuenta = wcuenta;
				END IF;
                
                IF wtransacc = '0223' THEN
                    DELETE FROM sc_retirosefectivo
                     WHERE cuenta = wcuenta
                       AND fecha = wfechoy
                       AND transacc = '0223'
                       AND sucursal = psucursal;
                END IF;
				
            ELSE
                IF (wnaturaleza = "A") THEN
                    LET wsaldo_cuenta = 0;
                    LET wsdo_actual   = 0;
                    LET wsdo_retenido = 0;
                    LET wsdo_sbc      = 0;
                    LET wsdo_cong     = 0;
                
                    SELECT sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbc,imp_sbg_ccc,saldo_sbc
                      INTO wsdo_actual, wsdo_retenido, wsdo_cong, wsdo_sbc, mImpSbgCcc, mSaldoSBC
                      FROM sc_maechq
                     WHERE empresa = pempresa
                       AND cuenta = wcuenta;

					--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
					EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('',wsdo_actual,wsdo_retenido,wsdo_cong,mSaldoSBC,0.00,0.00,mImpSbgCcc,'F',5) INTO cCodRetConsSdo,cMensajeRetConsSdo,wsaldo_cuenta;        		
					   
					--RQM 09 704. Se agregan las validaciones para la reversion de la inmovilizacion de saldo. Daniel Hernandez Garcia
					SELECT COUNT(*) INTO iContTxPermRet 
					FROM sc_transaccs_no_permitidas_reten_cob_auto 
					WHERE transaccion = wtransacc AND estatus = '1';
					
					IF iContTxPermRet = 0 THEN
					
						LET wsaldo_cuenta = wsaldo_cuenta + mSaldoSbc;
										
					END IF;
					   
                    IF wtransacc = '0325' THEN 
                        LET wsaldo_cuenta = wsaldo_cuenta + wmonto_tot;
                    END IF;
                
                    IF wsaldo_cuenta < wfirme THEN
                        LET pcod_ret = "00413";
                        IF vtransaccion = 1 THEN
                            ROLLBACK WORK;
                            BEGIN WORK;
                        ELSE
                           ROLLBACK WORK;
                        END IF;
                        RETURN pcod_ret;
                    END IF;
                
                    UPDATE {+INDEX(sc_movdia idx_sc_movdia_02)} 
                           sc_movdia
                       SET cancelad = "S"
                     WHERE cancelad <> "S"
                       AND num_serial = wnum_serial;
                
                    IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                        IF vtransaccion = 1 THEN
                            ROLLBACK WORK;
                            BEGIN WORK;
                        ELSE
                            ROLLBACK WORK;
                        END IF;
                        EXIT FOREACH;
                    END IF;
                
                    INSERT INTO sc_movdia VALUES
                    ( 0, pfolio, psucursal, pusuario, wfechoy, wfechoy, current hour to fraction(3), wtransacc, wsuc_cuen, wproducto, pempresa, 
                      wcuenta, " ", wnum_cheq, wmonto_tot * -1, 0, 0, 0, 0, "S", vstatus_cta, wsdo_actual, "0000", "REV", 0, vnum_tarjeta, "" ,"", vfecha_operacion);
            
                    IF wen_sbc > 0 THEN
                        LET wmonto_tot = 0;
            
                        UPDATE sc_docret_sbc
                           SET cancelado = "S"
                         WHERE empresa = pempresa
                           AND cuenta = wcuenta
                           AND folio_suc = pfolio
                           AND fecha_alta = wfechoy;
                    END IF;
            
					/*
                    IF wedoctacnt is not null AND wedoctacnt <> '' THEN
                        UPDATE sc_maechq
                           SET sdo_actual     = sdo_actual - wmonto_tot,
                               imp_chq_sbc    = imp_chq_sbc - wen_sbc,
                               imp_sbg_ccc    = imp_sbg_ccc - wimp_sbg_ccc,
                               imp_chq_sbg    = imp_chq_sbg - wimp_chq_sbg,
                               num_abonos_mes = num_abonos_mes - 1,
                               imp_abonos_mes = imp_abonos_mes - wmonto_tot - wen_sbc,
                               status_cta     = wedoctacnt
                         WHERE empresa = pempresa
                           AND cuenta = wcuenta;
                    ELSE
                        UPDATE sc_maechq
                           SET sdo_actual     = sdo_actual - wmonto_tot,
                               imp_chq_sbc    = imp_chq_sbc - wen_sbc,
                               imp_sbg_ccc    = imp_sbg_ccc - wimp_sbg_ccc,
                               imp_chq_sbg    = imp_chq_sbg - wimp_chq_sbg,
                               num_abonos_mes = num_abonos_mes - 1,
                               imp_abonos_mes = imp_abonos_mes - wmonto_tot - wen_sbc
                         WHERE empresa = pempresa
                           AND cuenta = wcuenta;
                    END IF;
					*/
					
					UPDATE sc_maechq
					   SET sdo_actual     = sdo_actual - wmonto_tot,
						   imp_chq_sbc    = imp_chq_sbc - wen_sbc,
						   imp_sbg_ccc    = imp_sbg_ccc - wimp_sbg_ccc,
						   imp_chq_sbg    = imp_chq_sbg - wimp_chq_sbg,
						   num_abonos_mes = num_abonos_mes - 1,
						   imp_abonos_mes = imp_abonos_mes - wmonto_tot - wen_sbc
					 WHERE empresa = pempresa
					   AND cuenta = wcuenta;
             
					--RQM 09 704. Se agregan las validaciones para la reversion de la inmovilizacion de saldo. Daniel Hernandez Garcia
					-- SELECT COUNT(*) INTO iContTxPermRet 
					-- FROM sc_transaccs_no_permitidas_reten_cob_auto 
					-- WHERE transaccion = wtransacc AND estatus = '1';
					
					--Se valida que la transaccion no estï¿½ permitida para inmovilizar el saldo y tambien se valida que se tenga un saldo inmovilizado
					IF iContTxPermRet = 0 AND mSaldoSbc > 0  THEN
												
						--Obtenemos el monto del ultimo movimiento de retencion.
						FOREACH WITH HOLD
							SELECT monto_tot,referencia,folio_suc INTO mMontoInmov,cReferenciaMovDia,cFolioSucInmov FROM bdicheq:sc_movdia WHERE cuenta = wcuenta AND transacc = '9015' AND cancelad <> 'S'
							
							IF SUBSTR(cReferenciaMovDia,1,16) = pfolio AND mMontoInmov <= mSaldoSbc THEN
							
								--Se actualiza el saldo_sbc, donde se almacena el saldo inmovilizado en favor del proceso de cobranza automatica
								UPDATE sc_maechq 
									SET saldo_sbc = saldo_sbc - mMontoInmov
								WHERE empresa = pempresa
									AND cuenta = wcuenta; 
								
								--Se cancela el movimiento del dia de la inmovilizacion
								UPDATE sc_movdia 
								SET cancelad = 'S'
								WHERE folio_suc = cFolioSucInmov;
								
								--Se actualiza el monto_retenido de la tabla de control para que se reverse el saldo inmovilizado para la cuenta especificada.
								SELECT monto_retenido INTO mMontoRetenido FROM sc_control_cobranza_automatica WHERE cuenta_captacion = wcuenta;
								
								IF (mMontoRetenido - mMontoInmov) > 0 THEN
									LET iEstatusCtrCob = 2;
								ELIF (mMontoRetenido - mMontoInmov) = 0 THEN
									LET iEstatusCtrCob = 1;
								END IF;
								
								--Se actualiza el monto_retenido de la tabla de control para que se reverse el saldo inmovilizado para la cuenta especificada.
								UPDATE sc_control_cobranza_automatica SET
								estatus = iEstatusCtrCob,
								monto_retenido = monto_retenido - mMontoInmov,
								pendiente_a_retener = pendiente_a_retener + mMontoInmov,
								fecha_modificacion = TODAY
								WHERE cuenta_captacion = wcuenta;
								
								--En caso de encontrar el registro se finaliza el foreach.
								EXIT FOREACH;
								
							ELSE
							
								CONTINUE FOREACH;
							
							END IF;
							
						END FOREACH;
					END IF;
					
                    IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                        IF vtransaccion = 1 THEN
                            ROLLBACK WORK;
                            BEGIN WORK;
                        ELSE
                            ROLLBACK WORK;
                        END IF;
                        EXIT FOREACH;
                    END IF;
                    
                    IF (wtransacc = vtrancorrespchq OR wtransacc = vtrancorrespchqoxxo OR wtransacc = vtrancorrespchqseven) THEN
                        SELECT corresp
                          INTO wcorresp
                          FROM sc_transacc_corresp
                         WHERE transacc = wtransacc;
                         
                        UPDATE {+INDEX (bdicheq:sc_acumdiacorresp idx_acumdiacorresp_ctacorr)} 
                               sc_acumdiacorresp
                           SET monto_acum = monto_acum - wmonto_tot
                         WHERE cuenta = wcuenta
                           AND corresp = wcorresp
                           AND transacc = wtransacc;

                        UPDATE {+INDEX (bdicheq:sc_param_corresp idx_paramcorresp)} 
                               sc_param_corresp
                           SET valor = valor - wmonto_tot
                         WHERE codparam = '003'
                           AND empresa = pempresa;
                    END IF;
                    
                    -- // REVERSA ACUMULADO CUENTAS NIVEL 2
                    SELECT {+INDEX(sc_limites_producto idx_limites_producto_prod)}
                           COUNT(*)
                      INTO vExisLimProd
                      FROM sc_limites_producto
                     WHERE producto = wproducto;
                     
                    IF vExisLimProd > 0 THEN
                        SELECT {+INDEX(sc_transacc_exentas_limprod idx_transacc_exentas_limprod_trx)}
                               COUNT(*)
                          INTO vTrxExentaLimProd
                          FROM sc_transacc_exentas_limprod
                         WHERE transacc = wtransacc;
                         
                        IF vTrxExentaLimProd = 0 THEN
                            SELECT {+INDEX(sc_acummesctanvl2 idx_acummesctanvl2_cta)}
                                   COUNT(*)
                              INTO vExisAcumCtaNvl2
                              FROM sc_acummesctanvl2
                             WHERE cuenta = wcuenta;
                             
                            IF vExisAcumCtaNvl2 > 0 THEN
                                UPDATE {+INDEX(sc_acummesctanvl2 idx_acummesctanvl2_cta)} sc_acummesctanvl2
                                   SET monto_acum = monto_acum - wmonto_tot
                                 WHERE cuenta = wcuenta;
                            END IF;
                        END IF;
                    END IF;
                    
                    IF wtransacc = '0325' THEN
                        UPDATE sc_maechq
                           SET sdo_retenido = sdo_retenido - wmonto_tot
                         WHERE empresa = pempresa
                           AND cuenta = wcuenta;
                
                        DELETE FROM sc_depinterpza
                         WHERE fecha = wfechoy
                           AND num_cte = wnum_cte
                           AND cuenta = wcuenta
                           AND folio_suc = pfolio
                           AND monto_acum = wmonto_tot;
                
                        DELETE FROM sc_depositosefectivo
                         WHERE fecha = wfechoy
                           AND num_cte = wnum_cte
                           AND cuenta = wcuenta
                           AND folio_suc = pfolio
                           AND monto = wmonto_tot;
                    END IF;
                
                    IF wtransacc = '0202' AND vtpo_per_valida IN('1','3') THEN
                        DELETE FROM sc_depositosefectivo
                         WHERE fecha = wfechoy
                           AND num_cte = wnum_cte
                           AND cuenta = wcuenta
                           AND folio_suc = pfolio
                           AND monto = wmonto_tot;
                         
                        SELECT cve_estado
                          INTO vestado_oper
                          FROM bdinteg:si_ptf
                         WHERE id_ptf = wsuc_tran AND tipo <> 'C';
                            
                        /*SELECT estado
                          INTO vestado_oper
                          FROM bdinteg:si_sucursales
                         WHERE sucursal = wsuc_tran;*/
                
                        SELECT cve_estado
                          INTO vestado_cta
                          FROM bdinteg:si_ptf
                         WHERE id_ptf = wsuc_cuen AND tipo <> 'C';

                        /*SELECT estado
                          INTO vestado_cta
                          FROM bdinteg:si_sucursales
                         WHERE sucursal = wsuc_cuen;*/
                         
                        IF vestado_oper <> vestado_cta THEN
                            DELETE FROM sc_depinterpza
                             WHERE fecha = wfechoy
                               AND num_cte = wnum_cte
                               AND cuenta = wcuenta
                               AND folio_suc = pfolio
                               AND monto_acum = wmonto_tot;
                        END IF;
                    END IF;
                    
                    IF (wtransacc = '0282' OR wtransacc = '0482' OR wtransacc = '0491') AND vtpo_per_valida IN('1','3') THEN                
                        DELETE FROM sc_depositosefectivo
                         WHERE fecha = wfechoy
                           AND num_cte = wnum_cte
                           AND cuenta = wcuenta
                           AND folio_suc = pfolio
                           AND monto = wmonto_tot;
                    END IF;
                    
                    IF wtransacc = '3357' THEN
                        SELECT COUNT(*)
                          INTO wexiste
                          FROM sc_limite_sbg
                         WHERE cuenta = wcuenta;
                         
                        IF wexiste > 0 THEN
                            UPDATE sc_limite_sbg
                               SET imp_acum_sbg = imp_acum_sbg - wimp_chq_sbg
                             WHERE cuenta = wcuenta;
                        END IF;
                    END IF;
                
                    IF vProdCrec = wproducto THEN
                        UPDATE sc_maechq
                           SET marca_ret = "0",
                               status_cta = "2",
                               fec_cancelac = wfechoy
                         WHERE empresa = pempresa
                           AND cuenta = wcuenta;
                    END IF;
                    
                    SELECT {+INDEX (bditef:tef_operaciones idx_tef_operaciones1)}
                           clave_rastreo
                      INTO vclave_rastreo
                      FROM bditef:tef_operaciones
                     WHERE folio_suc = pfolio
                       AND clave_rastreo <> ""
                       AND fecha_trans = wfechoy
                       AND cve_status = 'PE'
                       AND sucursal = psucursal;
                
                    IF (vclave_rastreo is not null OR vclave_rastreo <> '') THEN
                        UPDATE {+INDEX (bditef:tef_operaciones idx_tef_operaciones1)} 
                               bditef:tef_operaciones
                           SET cve_status = '04'
                         WHERE folio_suc = pfolio
                           AND clave_rastreo <> ""
                           AND fecha_trans = wfechoy
                           AND cve_status = 'PE'
                           AND sucursal = psucursal;
                    END IF;
                END IF;
            END IF;
            
            -- // Validaciï¿½n de limites
            SELECT {+INDEX(bdinteg:si_usuario_limites idx_usualim)} usuario
              INTO vuser_limit
              FROM bdinteg:si_usuario_limites
             WHERE usuario = wusuario
               AND empresa = pempresa;
            
            IF (vuser_limit is not null OR vuser_limit <> '') THEN
                IF (vuser_limit = "intercar") THEN
                    SELECT transacc, id_transacc, id_canal
                      INTO vtran_limit, vid_transacc, vid_canal
                      FROM bdinteg:si_transacc_limites
                     WHERE transacc = wtransacc
                       AND empresa = pempresa
                       AND sistema = '01';
                ELSE
                    SELECT id_canal
                      INTO vid_canal
                      FROM bdinteg:si_canales
                     WHERE cc_canal = psucursal;
                
                    SELECT transacc, id_transacc
                      INTO vtran_limit, vid_transacc
                      FROM bdinteg:si_transacc_limites
                     WHERE transacc = wtransacc
                       AND empresa = pempresa
                       AND sistema = '01'
                       AND id_canal = vid_canal;
                END IF;
                
                IF (vtran_limit is not null OR vtran_limit <> '') THEN
                    EXECUTE PROCEDURE bdinteg:sp_reversa_acum_x(wfechoy, wnum_cte, wcuenta, vid_transacc, vid_canal, wmonto_tot)
                    INTO cod_ret_lim, vmsje_limites, vid_autor;
                END IF;
            END IF;
        END FOREACH;
            
         -- #############################  INICIO reversion de servicios #############################
		LET cont_exist = 0;
        
        SELECT COUNT (referencia1)
            INTO cont_exist
            FROM bdisac:sac_movimientos
            WHERE folio_suc = pfolio
            AND status_cancelado <> 'S';
        
		IF cont_exist > 0 THEN
            CALL bdisac:sp_ReversionSac(pempresa,psucursal,pusuario, pfolio)
            RETURNING cRetRevSac;
            
            IF  cRetRevSac < 0  THEN
                ROLLBACK WORK;
                BEGIN WORK;
                LET pcod_ret = '00999';
            ELIF  cRetRevSac = 170 then
                ROLLBACK WORK;
                BEGIN WORK;
                LET pcod_ret = '00170';
                RETURN pcod_ret;
            END IF;
        END IF;
        -- #############################  FINAL reversion de servicios  #############################
        
        IF wtransacc = '0303' THEN
            SELECT COUNT(*) 
              INTO iExisteTrx
              FROM sc_movdia 
             WHERE empresa = pempresa 
               AND folio_suc = pfolio 
               AND cancelad = 'S' 
               AND monto_tot = 500;
               
            IF iExisteTrx > 0 THEN
                SELECT referencia
                  INTO vreferencia
                  FROM sc_movdia
                 WHERE empresa = pempresa
                   AND folio_suc = pfolio
                   AND sucursal = psucursal
                   AND cancelad = 'S'
                   AND transacc = '0303'
                   AND monto_tot = 500;
                   
                LET vfolio = TRIM(SUBSTR(vreferencia, -9));

                UPDATE bdiprem:sc_promocion_kelloggs
                   SET entregado  = '0',
                       cuenta_abono = '',
                       sucursal = '',
                       usuario_entrega = '',
                       monto_premio = 0,
                       fecha_entrega = ''
                 WHERE empresa  = pempresa
                   AND folio = vfolio;
            END IF;
        END IF;
        
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
            
            -- // LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
            EXECUTE PROCEDURE sp_actualizar_indicadores(psucursal,wcuenta,wtransacc,wmonto_tot,wfechoy,"R")
            INTO cCodRetIndicador;
        END IF;
    
    END IF;
    
    END;
    
    RETURN pcod_ret;
    
END PROCEDURE
    
DOCUMENT
'DESCRIPCION: Se incluye el llamado al procedimiento de reversion sac para reversar las transacciones de Ordenes de pago',
'MODIFICO: Antonio Bastidas',
'FECHA: 21/01/2010',
'MODIFICO: Armando Mercado',
'DESCRIPCION: Se modifico para k no pueda reversar un envio ya pagado o cancelado, estatu <> 01',
'VERSION: 20100429.1905',
'MODIFICO: Dulce Ramirez',
'DESCRIPCION: Se modifico para que reversara las operaciones TEF en tef_operaciones',
'VERSION: 20110427.1551',
'MODIFICO: FRG',
'DESCRIPCION: Se modifico en ODP para que reverse en status 00 y se elimina flujo IF EXIST',
'VERSION: 20120123.1211',
'BD: bdicheq',
'FOLIO: 1392',
'AUTOR: JOSE ANGEL GAXIOLA GAXIOLA',
'FECHA: 21/02/2014',
'MODIFICACION: Se agrega "DESC"	al "ORDER BY tr.naturaleza"	de la consulta a las tablas "sc_movdia y si_transacc" para que',
'              tome cantidades correctas, se asigno "wcomision" correcta para realizar el reverso y se aplicaron reglas de programacion,',
'			   Se Agrega "ROLLBACK WORK" al momento de retornal: cod_ret = "413" para que no se afecten tablas si ocurre eror',
'SUSTENTO: Se definio en el Requerimiento: INC 24 015 Suc. reverso de comision de activacion TDD v1.0.pdf',
'SOLICITO: GUSTAVO SAUCEDA ARCE',
'BD: bdicheq',
'FOLIO.........: 1398 - HomologacionReversoComAct.TDD',
'AUTOR.........: 95526749 - Jesus Horacio Lopez Gonzalez',
'FECHA.........: 06/03/2014 - DSB20140306',
'MODIFICACION..: Homologacion del requerimiento anterior con la version productiva.',
'SUSTENTO......: Se definio por correo, el dia 06/03/2014 09:59:18, enviado por Cutberto Gonzalez para Yadira Morales.',
'SOLICITA......: Cutberto Gonzalez Perez',
'BD............: BDICHEQ',
'FECHA: 16/03/2021',
'AUTOR: Armando Garcia Ortiz',
'RQM 10 1185',
'MODIFICACION: Implementacion del reverso para Corresponsal 7Eleven',
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 19-08-2025',
'MODIFICACION: Se modifica la forma de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.8.1',
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 19-12-2025',
'MODIFICACION: Se agrega la logica para la reversion del saldo inmovilizado a las cuentas de capraciÃ³n', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.8.2';

create procedure "informix".reversion_td(pempresa  char(3),
                                         psucursal char(4),
                                         pusuario  char(8),
                                         pfolio    char(16),
                                         ptiporev  char(1))
RETURNING char(5);
    
    DEFINE sql_err             integer;
    DEFINE isam_err            integer;
    DEFINE cod_ret             char(5);
    DEFINE contador            smallint;
    DEFINE wcompend            money(14,2);
    DEFINE wtiptran            char(2);
    DEFINE wnum_serial         integer;
    DEFINE wtransacc           char(4);
    DEFINE wcuenta             char(20);
    DEFINE wmonto_tot          money(14,2);
    DEFINE wmonto_tot1         money(14,2);
    DEFINE montoaux            money(14,2);
    DEFINE wfirme              money(14,2);
    DEFINE wen_sbc             money(14,2);
    DEFINE wremesas            money(14,2);
    DEFINE wdias_ret           smallint;
    DEFINE wnum_cheq           integer;
    DEFINE wimp_sbg_ccc        money(14,2);
    DEFINE wimp_chq_sbg        money(14,2);
    DEFINE wimp_int_ccc        money(14,2);
    DEFINE wimp_int_sbg        money(14,2);
    DEFINE wchq_exp_mes        smallint;
    DEFINE wnaturaleza         char(1);
    DEFINE wvalida_docto       char(1);
    DEFINE wtipo               char(1);
    DEFINE wsaldo_cuenta       money(14,2);
    DEFINE wsdo_actual         money(14,2);
    DEFINE wsdo_retenido       money(14,2);
    DEFINE wsdo_cong           money(14,2);
    DEFINE wmontoaux           money(14,2);
    DEFINE wlim_chq_sbc        money(14,2);
    DEFINE wimp_chq_sbc        money(14,2);
    DEFINE wlim_chq_rem        money(14,2);
    DEFINE wimp_chq_rem        money(14,2);
    DEFINE wreferencia         char(40);
    DEFINE wstatus_envio       char(1);
    DEFINE wrowid              integer;
    DEFINE wfechoy             date;
    DEFINE pfolio1             char(16);
    DEFINE wtpcheque           char(2);
    DEFINE wfechahora          datetime hour to fraction(3);
    DEFINE vtranusoccc         char(4);
    DEFINE vtrancancta         char(4);
    DEFINE vtranintccc         char(4);
    DEFINE vtranusosbg         char(4);
    DEFINE vtranintsbg         char(4);
    DEFINE wcomision           char(4);
    DEFINE wsuc_cuen           char(4);
    DEFINE wproducto           char(4);
    define vnum_tarjeta        char(16);
    define vmaxsec             smallint;
    DEFINE vProdCrec           CHAR(4);
    DEFINE vstatus_cta         CHAR(1);
    DEFINE wusuario            CHAR(8);
    DEFINE vuser_limit         CHAR(8);
    DEFINE vtran_limit         CHAR(4);
    DEFINE vid_transacc        CHAR(2);
    DEFINE vid_canal           CHAR(2);
    DEFINE wnum_cte            CHAR(20);
    DEFINE vmsje_limites       CHAR(80);
    DEFINE vid_autor           CHAR(1);
    DEFINE vtranpagosbg        CHAR(4);	
	DEFINE cCodRetIndicador		CHAR(6);
    DEFINE wedoctaant           CHAR(1);
	DEFINE vfecha_operacion    date;
  --RQM 09 704. Se agregan las siguientes variable DFTL
  DEFINE mSaldoSbc       MONEY(14,2);
  DEFINE cCodRetConsSdo       CHAR(5); --Codigo de retorno de SP de consulta de saldo.
  DEFINE cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
	DEFINE iContTxPermRet		INTEGER;		--Contador para la validacion de transaccion con reversion de saldo inmovilizado.
	DEFINE mMontoInmov			MONEY(14,2); 	--Monto invomilizado en cuenta para reversion de abonos
	DEFINE cReferenciaMovDia	CHAR(40);		--Referencia del movimiento del dia, se utiliza en el proceso de reversion de cobranza automatica.
	DEFINE iEstatusCtrCob		INTEGER;		--Estatus para la actualizacion de registro en tabla de control de cobranza
	DEFINE mMontoRetenido		MONEY(14,2);	--Monto pendiente por retener de la tabla de control de cobranza
	DEFINE cFolioSucInmov		CHAR(16);		--Folio suc del movimiento de inmovilizacion 
    

    
    LET sql_err = 0;
    LET cod_ret = "000";
	LET cCodRetIndicador = "000000";
    LET wedoctaant = '';
	LET vfecha_operacion = TODAY;
  --RQM 09 704. Se agregan las siguientes variable DFTL 
  LET mSaldoSbc           = 0;
  LET cCodRetConsSdo      = '00000';
  LET cMensajeRetConsSdo  = '';
	LET iContTxPermRet		=0;
	LET mMontoInmov			=0.00;
	LET cReferenciaMovDia	= '';
	LET iEstatusCtrCob		= 0;
	LET mMontoRetenido	= 0.00;
	LET cFolioSucInmov		= '';


    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err
        IF (sql_err <> 0) THEN
            -- SET DEBUG FILE TO "reversionch.err";
            -- TRACE sql_err || " * " || isam_err;
            LET cod_ret = sql_err;
            RETURN cod_ret; 	
        END IF;
    END EXCEPTION;
    
    SELECT fecha_hoy 
      into wfechoy
      FROM sc_fechas 
     where empresa = pempresa;
    
    SELECT TRIM(valor)
      INTO vProdCrec
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam ="PRODCREC";
    
    SELECT COUNT(*) 
      INTO contador
      FROM sc_movdia m, 
           bdinteg:si_transacc t
     WHERE m.empresa = pempresa 
       and m.folio_suc = pfolio 
       and m.cancelad <> "S"
       and t.empresa = m.empresa 
       and t.numero = m.transacc
       and t.reversable = "S";
    
    IF (contador = 0) THEN
        SELECT COUNT(*) 
          INTO contador
          FROM sc_docret
         WHERE empresa = pempresa 
           and folio_suc = pfolio 
           and fecha_alta = wfechoy;
           
        IF (contador = 0) THEN
            RETURN cod_ret;
        ELSE
            update sc_docret
               set cancelado = "S"
             WHERE empresa = pempresa 
               and folio_suc = pfolio 
               and fecha_alta = wfechoy;
               
            RETURN cod_ret;
        end if
    end if
    
    select valor 
      into vtrancancta
      from sc_param
     where empresa = pempresa 
       and codparam = "trancancta";

    select valor 
      into vtranusoccc
      from sc_param
     where empresa = pempresa 
       and codparam = "tranusoccc";
    
    select valor 
      into vtranintccc
      from sc_param
     where empresa = pempresa 
       and codparam = "tranintccc";
    
    select valor 
      into vtranusosbg
      from sc_param
     where empresa = pempresa 
       and codparam = "tranusosbg";
    
    select valor 
      into vtranintsbg
      from sc_param
     where empresa = pempresa 
       and codparam = "tranintsbg";
        
    SELECT valor
      INTO vtranpagosbg
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranpagosbg";
    
    FOREACH
        select md.num_serial, md.transacc, md.cuenta, md.monto_tot, md.firme, md.en_sbc, md.remesas,
               md.dias_ret, md.num_cheq, tr.naturaleza, tr.valida_docto, tr.tipo_tran,
               md.referencia, md.suc_cuen, md.producto, md.usuario, edo_cta
          into wnum_serial, wtransacc, wcuenta, wmonto_tot, wfirme, wen_sbc,
               wremesas, wdias_ret, wnum_cheq, wnaturaleza, wvalida_docto,
               wtiptran, wreferencia, wsuc_cuen, wproducto, wusuario, wedoctaant
          FROM sc_movdia md, 
               bdinteg:si_transacc tr
         WHERE md.empresa = pempresa 
           and md.folio_suc = pfolio
           AND md.cancelad <> "S" 
           AND tr.empresa = md.empresa 
           and tr.numero = md.transacc
           and tr.reversable = "S"
         ORDER BY tr.naturaleza desc
         
        select max(secuencia) 
          into vmaxsec
          from sc_tarjeta
         where empresa = pempresa 
           and cuenta = wcuenta 
           and tipo_tarjeta = "T";
           
        select num_tarjeta 
          into vnum_tarjeta
          from sc_tarjeta
         where empresa = pempresa 
           and cuenta = wcuenta 
           and secuencia = vmaxsec;
           
        LET wimp_sbg_ccc = 0;
        LET wimp_chq_sbg = 0;
        LET wimp_int_ccc = 0;
        LET wimp_int_sbg = 0;
        LET wchq_exp_mes = 0;
        let wcompend = 0;
        
        IF wtiptran = "01" THEN
            LET wchq_exp_mes  = 1;
        ELIF wtransacc = vtranusoccc THEN
            LET wimp_sbg_ccc = wmonto_tot;
        ELIF wtransacc = vtranusosbg THEN
            LET wimp_chq_sbg = wmonto_tot;
        ELIF wtransacc = vtranpagosbg THEN
            LET wimp_chq_sbg = wmonto_tot;
        ELIF wtransacc = vtranintccc THEN
            LET wimp_int_ccc = wmonto_tot;
        ELIF wtransacc = vtranintsbg THEN
            LET wimp_int_sbg = wmonto_tot;
        ELIF wtiptran = "05" THEN
            LET wcompend = wmonto_tot;
            let wcomision = trim(wreferencia);
        END IF;
        
        select sdo_actual, status_cta 
          into wsdo_actual, vstatus_cta
          from sc_maechq
         where empresa = pempresa 
           and cuenta = wcuenta;
        
        IF wnaturaleza = "C" THEN
        
            IF wedoctaant is not null AND wedoctaant <> '' THEN
                UPDATE sc_maechq
                   SET sdo_actual = sdo_actual + wmonto_tot,
                       imp_cgos_mes = imp_cgos_mes - wmonto_tot,
                       num_cgos_mes = num_cgos_mes - 1,
                       chq_exp_mes = chq_exp_mes - wchq_exp_mes,
                       imp_sbg_ccc = imp_sbg_ccc + wimp_sbg_ccc,
                       imp_int_ccc = imp_int_ccc + wimp_int_ccc,
                       imp_chq_sbg = imp_chq_sbg + wimp_chq_sbg,
                       imp_int_sbg = imp_int_sbg + wimp_int_sbg,
                       com_pendiente = com_pendiente + wcompend,
                       status_cta = wedoctaant
                 WHERE empresa = pempresa 
                   and cuenta = wcuenta;
            ELSE

                UPDATE sc_maechq
                   SET sdo_actual = sdo_actual + wmonto_tot,
                       imp_cgos_mes = imp_cgos_mes - wmonto_tot,
                       num_cgos_mes = num_cgos_mes - 1,
                       chq_exp_mes = chq_exp_mes - wchq_exp_mes,
                       imp_sbg_ccc = imp_sbg_ccc + wimp_sbg_ccc,
                       imp_int_ccc = imp_int_ccc + wimp_int_ccc,
                       imp_chq_sbg = imp_chq_sbg + wimp_chq_sbg,
                       imp_int_sbg = imp_int_sbg + wimp_int_sbg,
                       com_pendiente = com_pendiente + wcompend
                 WHERE empresa = pempresa 
                   and cuenta = wcuenta;
            END IF
            
            --- if wtransacc = vtrancancta then
            if vstatus_cta = "2" then
                if wedoctaant <> '8' then
                    update sc_maechq
                       set status_cta = "1",
                           fec_cancelac = "",
                           motivo = " "
                     where empresa = pempresa 
                       and cuenta = wcuenta;
                else
                    update sc_maechq
                       set fec_cancelac = "",
                           motivo = " "
                     where empresa = pempresa 

                       and cuenta = wcuenta;
                end if
            end if
            
            if wtiptran = "05" then
                update sc_detcomis
                   set pago_com = pago_com - wmonto_tot,
                       estado_com = "P"
                 where empresa = pempresa 
                   and cuenta = wcuenta 
                   and comision = wcomision 
                   and fecult_pago = wfechoy;
            end if;
            
            if ptiporev = "A" then
                --- delete from sc_movdia 
                ---  where num_serial = wnum_serial;
                
                UPDATE sc_movdia
                   SET cancelad = "S"
                 WHERE empresa = pempresa
                   AND cuenta = wcuenta
                   AND num_serial = wnum_serial;
                 
                INSERT INTO sc_movdia VALUES
                ( 0, pfolio, psucursal, pusuario, wfechoy, wfechoy, current hour to fraction(3), wtransacc, wsuc_cuen, wproducto, pempresa,
                  wcuenta, " ", wnum_cheq, wmonto_tot * -1, 0, 0, 0, 0, "S", vstatus_cta, wsdo_actual, "0000", "REV", 0, vnum_tarjeta, "", "", vfecha_operacion);
            else
                UPDATE sc_movdia
                   SET cancelad = "S"
                 WHERE empresa = pempresa
                   AND cuenta = wcuenta
                   AND num_serial = wnum_serial;
                 
                INSERT INTO sc_movdia VALUES
                ( 0, pfolio, psucursal, pusuario, wfechoy, wfechoy, current hour to fraction(3), wtransacc, wsuc_cuen, wproducto, pempresa,
                  wcuenta, " ", wnum_cheq, wmonto_tot * -1, 0, 0, 0, 0, "S", vstatus_cta, wsdo_actual, "0000", "REV", 0, vnum_tarjeta, "", "", vfecha_operacion);
            end if
            
            IF wtiptran = "01" THEN
                UPDATE sc_contch
                   SET estado = "N",
                       importe = 0
                 WHERE empresa = pempresa 
                   and cuenta = wcuenta 
                   AND numero = wnum_cheq;
                   
                UPDATE sc_histch
                   SET estado = "N",
                       importe = 0
                 WHERE empresa = pempresa 
                   and cuenta = wcuenta 
                   AND numero = wnum_cheq;
            END IF;
            
        ELSE
            
            IF (wnaturaleza = "A") THEN
                LET wsaldo_cuenta       = 0;
                LET wsdo_actual         = 0;
                LET wsdo_retenido       = 0;
                LET wsdo_cong           = 0;
            
                SELECT sdo_actual,sdo_retenido,sdo_cong,saldo_sbc
                  INTO wsdo_actual,wsdo_retenido,wsdo_cong,mSaldoSbc
                  FROM sc_maechq
                 WHERE empresa = pempresa 
                   and cuenta = wcuenta;
                --RQM 09 704. Se executa el siguiente SP para el calculo del saldo disponible DFTL 
                EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', wsdo_actual, wsdo_retenido, wsdo_cong, mSaldoSbc, null, null, null, 'F', '2') 
                INTO cCodRetConsSdo, cMensajeRetConsSdo, wsaldo_cuenta; 

              --RQM 09 704. Se agregan las validaciones para la reversion de la inmovilizacion de saldo. Daniel Hernandez Garcia
                SELECT COUNT(*) INTO iContTxPermRet 
                FROM sc_transaccs_no_permitidas_reten_cob_auto 
                WHERE transaccion = wtransacc AND estatus = '1';
                
                IF iContTxPermRet = 0 THEN
                
                  LET wsaldo_cuenta = wsaldo_cuenta + mSaldoSbc;
                          
                END IF;
			
                IF wsaldo_cuenta < wfirme THEN
                    LET cod_ret = "413";
                    RETURN cod_ret;
                END IF;
                    
                IF wedoctaant is not null AND wedoctaant <> '' THEN
                    UPDATE sc_maechq
                       SET sdo_actual = sdo_actual - wmonto_tot,
                           sdo_retenido= sdo_retenido - wen_sbc,
                           imp_sbg_ccc = imp_sbg_ccc - wimp_sbg_ccc,
                           imp_chq_sbg = imp_chq_sbg - wimp_chq_sbg,
                           num_abonos_mes = num_abonos_mes - 1,
                           imp_abonos_mes = imp_abonos_mes - wmonto_tot,
                           status_cta = wedoctaant
                     WHERE empresa = pempresa 
                       AND cuenta = wcuenta;
                ELSE
                    UPDATE sc_maechq
                       SET sdo_actual = sdo_actual - wmonto_tot,
                           sdo_retenido= sdo_retenido - wen_sbc,
                           imp_sbg_ccc = imp_sbg_ccc - wimp_sbg_ccc,
                           imp_chq_sbg = imp_chq_sbg - wimp_chq_sbg,
                           num_abonos_mes = num_abonos_mes - 1,
                           imp_abonos_mes = imp_abonos_mes - wmonto_tot
                     WHERE empresa = pempresa 
                       AND cuenta = wcuenta;
                END IF
             
                if wen_sbc > 0 then
                    update sc_docret
                       set cancelado = "S"
                     where empresa = pempresa 
                       and cuenta = wcuenta
                       and folio_suc = pfolio
                       and fecha_alta = wfechoy;
                end if;
                
                IF vProdCrec = wproducto THEN
                    UPDATE sc_maechq
                       SET marca_ret = "0"
                     WHERE empresa = pempresa
                       AND cuenta = wcuenta;
                END IF
                
                IF (cod_ret = "000") THEN
                    if ptiporev = "A" then                        
                        UPDATE sc_movdia
                           SET cancelad = "S"
                         WHERE empresa = pempresa
                           AND cuenta = wcuenta
                           AND num_serial = wnum_serial;
                         
                        INSERT INTO sc_movdia VALUES
                        ( 0, pfolio, psucursal, pusuario, wfechoy, wfechoy, current hour to fraction(3), wtransacc, wsuc_cuen, wproducto, pempresa,
                          wcuenta, " ", wnum_cheq, wmonto_tot * -1, 0, 0, 0, 0, "S", vstatus_cta, wsdo_actual, "0000", "REV", 0, vnum_tarjeta, "", "", vfecha_operacion);
                    else
                        UPDATE sc_movdia
                           SET cancelad = "S"
                         WHERE empresa = pempresa
                           AND cuenta = wcuenta
                           AND num_serial = wnum_serial;
                         
                        INSERT INTO sc_movdia VALUES
                        ( 0, pfolio, psucursal, pusuario, wfechoy, wfechoy, current hour to fraction(3), wtransacc, wsuc_cuen, wproducto, pempresa,
                          wcuenta, " ", wnum_cheq, wmonto_tot * -1, 0, 0, 0, 0, "S", vstatus_cta, wsdo_actual, "0000", "REV", 0, vnum_tarjeta, "", "", vfecha_operacion);
                    end if
                END IF;
				
				--RQM 09 704. Se agregan las validaciones para la reversion de la inmovilizacion de saldo. Daniel Hernandez Garcia
					-- SELECT COUNT(*) INTO iContTxPermRet 
					-- FROM sc_transaccs_no_permitidas_reten_cob_auto 
					-- WHERE transaccion = wtransacc AND estatus = '1';
					
					--Se valida que la transaccion este habilitada para inmovilizar el saldo y tambien se valida que se tenga un saldo inmovilizado
					IF iContTxPermRet = 0 AND mSaldoSbc > 0  THEN
												
						--Obtenemos el monto del ultimo movimiento de retencion.
						FOREACH WITH HOLD
							SELECT monto_tot,referencia,folio_suc INTO mMontoInmov,cReferenciaMovDia,cFolioSucInmov FROM bdicheq:sc_movdia WHERE cuenta = wcuenta AND transacc = '9015' AND cancelad <> 'S'
							
							IF SUBSTR(cReferenciaMovDia,1,16) = pfolio AND mMontoInmov <= mSaldoSbc THEN
							
								--Se actualiza el saldo_sbc, donde se almacena el saldo inmovilizado en favor del proceso de cobranza automatica
								UPDATE sc_maechq 
									SET saldo_sbc = saldo_sbc - mMontoInmov
								WHERE empresa = pempresa
									AND cuenta = wcuenta; 
								
								--Se cancela el movimiento del dia de la inmovilizacion
								UPDATE sc_movdia 
								SET cancelad = 'S'
								WHERE folio_suc = cFolioSucInmov;
								
								--Se actualiza el monto_retenido de la tabla de control para que se reverse el saldo inmovilizado para la cuenta especificada.
								SELECT monto_retenido INTO mMontoRetenido FROM sc_control_cobranza_automatica WHERE cuenta_captacion = wcuenta;
								
								IF (mMontoRetenido - mMontoInmov) > 0 THEN
									LET iEstatusCtrCob = 2;
								ELIF (mMontoRetenido - mMontoInmov) = 0 THEN
									LET iEstatusCtrCob = 1;
								END IF;
								
								--Se actualiza el monto_retenido de la tabla de control para que se reverse el saldo inmovilizado para la cuenta especificada.
								UPDATE sc_control_cobranza_automatica SET
								estatus = iEstatusCtrCob,
								monto_retenido = monto_retenido - mMontoInmov,
								pendiente_a_retener = pendiente_a_retener + mMontoInmov,
								fecha_modificacion = TODAY
								WHERE cuenta_captacion = wcuenta;
								
								--En caso de encontrar el registro se finaliza el foreach.
								EXIT FOREACH;
								
							ELSE
							
								CONTINUE FOREACH;
							
							END IF;
							
						END FOREACH;
					END IF;
				
            END IF;
        END IF;
        
        -- // Validacion de limites 
        select usuario
          into vuser_limit
          from bdinteg:si_usuario_limites
         where usuario = wusuario
           and empresa = pempresa;
        
        if (vuser_limit is not null or vuser_limit <> '') then 
            select transacc, id_transacc, id_canal
              into vtran_limit, vid_transacc, vid_canal
              from bdinteg:si_transacc_limites
             where transacc = wtransacc
               and empresa = pempresa
               and sistema = '01';
           
            if (vtran_limit is not null or vtran_limit <> '') then
                select num_cte
                  into wnum_cte
                  from sc_maechq
                 where empresa = pempresa
                   and cuenta = wcuenta;
                   
                execute procedure bdinteg:sp_reversa_acum_x(wfechoy, wnum_cte, wcuenta, vid_transacc, vid_canal, wmonto_tot)
                into cod_ret, vmsje_limites, vid_autor;
                
                let cod_ret = '000';
            end if;
        end if;
        
    END FOREACH;
    
    END;
	
	-- LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
	EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,wcuenta,wtransacc,wmonto_tot,wfechoy,"R")
	INTO cCodRetIndicador;
    
    RETURN cod_ret;
    
END PROCEDURE
DOCUMENT
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/01',
'RAZON:                 Se agrega la nueva variable saldo_sbc (inmovilizacion por concepto de credito)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.2',
'MODIFICADO:            Luis Enrique Orozco Cosme',
'ULTIMA MODIFICACION:   2025/12/03',
'RAZON:                 Se agrega la logica para la reversion del saldo inmovilizado a las cuentas de capraciÃ³n',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.3';

CREATE PROCEDURE "informix".reversion_sif(pempresa  CHAR(3),
                                      psucursal CHAR(4),
                                      pusuario  CHAR(8),
                                      pfolio    CHAR(16),
                                      ptiporev  CHAR(1))
RETURNING CHAR(5);

DEFINE sql_err              INTEGER;
DEFINE isam_err             INTEGER;
DEFINE cod_ret              CHAR(5);
DEFINE cCodret2             CHAR(5);
DEFINE contador             SMALLINT;
DEFINE wcompend             MONEY(14,2);
DEFINE wtiptran             CHAR(2);
DEFINE wnum_serial          INTEGER;
DEFINE wtransacc            CHAR(4);
DEFINE wcuenta              CHAR(20);
DEFINE wmonto_tot           MONEY(14,2);
DEFINE wmonto_tot1          MONEY(14,2);
DEFINE montoaux             MONEY(14,2);
DEFINE wfirme               MONEY(14,2);
DEFINE wen_sbc              MONEY(14,2);
DEFINE wremesas             MONEY(14,2);
DEFINE wdias_ret            SMALLINT;
DEFINE wnum_cheq            INTEGER;
DEFINE wimp_sbg_ccc         MONEY(14,2);
DEFINE wimp_chq_sbg         MONEY(14,2);
DEFINE wimp_int_ccc         MONEY(14,2);
DEFINE wimp_int_sbg         MONEY(14,2);
DEFINE wchq_exp_mes         SMALLINT;
DEFINE wnaturaleza          CHAR(1);
DEFINE wvalida_docto        CHAR(1);
DEFINE wtipo                CHAR(1);
DEFINE wsaldo_cuenta        MONEY(14,2);
DEFINE wsdo_actual          MONEY(14,2);
DEFINE wsdo_retenido        MONEY(14,2);
DEFINE wsdo_sbc             MONEY(14,2);
DEFINE wsdo_cong            MONEY(14,2);
DEFINE wmontoaux            MONEY(14,2);
DEFINE wlim_chq_sbc         MONEY(14,2);
DEFINE wimp_chq_sbc         MONEY(14,2);
DEFINE wlim_chq_rem         MONEY(14,2);
DEFINE wimp_chq_rem         MONEY(14,2);
DEFINE wreferencia          CHAR(40);
DEFINE wstatus_envio        CHAR(1);
DEFINE wrowid               INTEGER;
DEFINE wfechoy              date;
DEFINE pfolio1              CHAR(16);
DEFINE wtpcheque            CHAR(2);
DEFINE wfechahora           datetime hour to fraction(3);
DEFINE vtranusoccc          CHAR(4);
DEFINE vtrancancta          CHAR(4);
DEFINE vtranintccc          CHAR(4);
DEFINE vtranusosbg          CHAR(4);
DEFINE vtranintsbg          CHAR(4);
DEFINE wcomision            CHAR(4);
DEFINE wsuc_cuen            CHAR(4);
DEFINE wproducto            CHAR(4);
define vnum_tarjeta         CHAR(16);
define vmaxsec              SMALLINT;
DEFINE vProdCrec            CHAR(4);
DEFINE vstatus_cta          CHAR(1);
DEFINE vtransaccion 	    INTEGER;
DEFINE vtrancorrespchq      CHAR(4);
DEFINE wusuario             CHAR(8);
DEFINE vuser_limit          CHAR(8);
DEFINE vtran_limit          CHAR(4);
DEFINE vid_transacc         CHAR(2);
DEFINE vid_canal            CHAR(2);
DEFINE wnum_cte             CHAR(20);
DEFINE vmsje_limites        CHAR(80);
DEFINE vid_autor            CHAR(1);
DEFINE cTransaccAbonoEnvio  CHAR(4);
DEFINE cTransaccAbonoEnvioC CHAR(4);
DEFINE vtranpagosbg         CHAR(4);
DEFINE vclave_rastreo       CHAR(30);
--	2012.01.23 I
DEFINE cont_exist       	INTEGER;
--	2012.01.23 F
DEFINE cClaveStatus        CHAR(2);
DEFINE wfecha_operacion     date;
--RQM 09 704. Se agregan las siguientes variable DFTL
DEFINE mImpSbgCcc      MONEY(14,2);
DEFINE mSaldoSbc       MONEY(14,2);
DEFINE cCodRetConsSdo       CHAR(5); --Codigo de retorno de SP de consulta de saldo.
DEFINE cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
DEFINE iContTxPermRet		INTEGER;		--Contador para la validacion de transaccion con reversion de saldo inmovilizado.
DEFINE mMontoInmov			MONEY(14,2); 	--Monto invomilizado en cuenta para reversion de abonos
DEFINE cReferenciaMovDia	CHAR(40);		--Referencia del movimiento del dia, se utiliza en el proceso de reversion de cobranza automatica.
DEFINE iEstatusCtrCob		INTEGER;		--Estatus para la actualizacion de registro en tabla de control de cobranza
DEFINE mMontoRetenido		MONEY(14,2);	--Monto pendiente por retener de la tabla de control de cobranza
DEFINE cFolioSucInmov		CHAR(16);		--Folio suc del movimiento de inmovilizacion 
    
--INICIALIZACION DE VARIABLES
LET sql_err				 = 0;
LET cod_ret				 = "000";
LET cCodret2 			 = "00000";
LET vtransaccion		 = 0;
LET vtrancorrespchq 	 = '';
--	2012.01.23 I
LET cont_exist 			 = 0;
--	2012.01.23 F
LET cClaveStatus 		 = "04";
LET isam_err             = 0;
LET contador             = 0;
LET wcompend             = 0.0;
LET wtiptran             = "";
LET wnum_serial          = 0;
LET wtransacc            = "";
LET wcuenta              = "";
LET wmonto_tot           = 0.0;
LET wmonto_tot1          = 0.0;
LET montoaux             = 0.0;
LET wfirme               = 0.0;
LET wen_sbc              = 0.0;
LET wremesas             = 0.0;
LET wdias_ret            = 0.0;
LET wnum_cheq            = 0.0;
LET wimp_sbg_ccc         = 0.0;
LET wimp_chq_sbg         = 0.0;
LET wimp_int_ccc         = 0.0;
LET wimp_int_sbg         = 0.0;
LET wchq_exp_mes         = 0;
LET wnaturaleza          = "";
LET wvalida_docto        = "";
LET wtipo                = "";
LET wsaldo_cuenta        = 0.0;
LET wsdo_actual          = 0.0;
LET wsdo_retenido        = 0.0;
LET wsdo_sbc             = 0.0;
LET wsdo_cong            = 0.0;
LET wmontoaux            = 0.0;
LET wlim_chq_sbc         = 0.0;
LET wimp_chq_sbc         = 0.0;
LET wlim_chq_rem         = 0.0;
LET wimp_chq_rem         = 0.0;
LET wreferencia          = "";
LET wstatus_envio        = "";
LET wrowid               = 0;
LET wfechoy              = "";
LET pfolio1              = "";
LET wtpcheque            = "";
LET wfechahora           = "";
LET vtranusoccc          = "";
LET vtrancancta          = "";
LET vtranintccc          = "";
LET vtranusosbg          = "";
LET vtranintsbg          = "";
LET wcomision            = "";
LET wsuc_cuen            = "";
LET wproducto            = "";
LET vnum_tarjeta         = "";
LET vmaxsec              = 0;
LET vProdCrec            = "";
LET vstatus_cta          = "";

LET wusuario             = "";
LET vuser_limit          = "";
LET vtran_limit          = "";
LET vid_transacc         = "";
LET vid_canal            = "";
LET wnum_cte             = "";
LET vmsje_limites        = "";
LET vid_autor            = "";
LET cTransaccAbonoEnvio  = "";
LET cTransaccAbonoEnvioC = "";
LET vtranpagosbg         = "";
LET vclave_rastreo       = "";
LET wfecha_operacion     = TODAY;
--RQM 09 704. Se agregan las siguientes variable DFTL 
LET mImpSbgCcc          = 0;
LET mSaldoSbc           = 0;
LET cCodRetConsSdo      = '00000';
LET cMensajeRetConsSdo  = '';
LET iContTxPermRet		= 0;
LET mMontoInmov			= 0.00;
LET cReferenciaMovDia	= '';
LET iEstatusCtrCob		= 0;
LET mMontoRetenido		= 0.00;
LET cFolioSucInmov		= '';

   --SET DEBUG FILE TO "/informix/frg/sp_reversion.out";
   --TRACE ON; 

    BEGIN

    ON EXCEPTION
        SET sql_err, isam_err
        IF (sql_err <> 0) THEN
            SET DEBUG FILE TO "reversionch.err";
            TRACE sql_err || " * " || isam_err;
            LET cod_ret = sql_err;
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            RETURN cod_ret;
        END IF;
    END EXCEPTION;

    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH resume;

    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 4;
  
    
	IF psucursal = "9250" THEN
		LET cClaveStatus= "05";
	END IF
	
    SELECT {+INDEX(bdicheq:"informix".sc_fechas idx_fechas1)}
           fecha_hoy
      INTO wfechoy
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = pempresa;

    SELECT TRIM(valor)
      INTO vProdCrec
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pempresa
       AND codparam ="PRODCREC";

    SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia2a),
            +INDEX(bdinteg:"informix".si_transacc idx_transacc2)}
           COUNT(*)
      INTO contador
      FROM bdicheq:"informix".sc_movdia m,
           bdinteg:"informix".si_transacc t
     WHERE m.empresa = pempresa
       AND m.folio_suc = pfolio
       AND m.cancelad <> "S"
       AND t.numero = m.transacc
       AND t.empresa = m.empresa
       AND t.reversable = "S";

    IF (contador = 0) THEN
        SELECT COUNT(*)
        INTO contador
        FROM bdicheq:"informix".sc_docret_sbc
        WHERE empresa = pempresa
        AND folio_suc = pfolio
        AND fecha_alta = wfechoy;

        IF (contador = 0) THEN
--	2012.01.23 I
			--	IF EXISTS ( SELECT referencia1
					--	FROM bdisac:sac_movimientos
                    --     WHERE folio_suc = pfolio
                    --       AND id_sucursal = psucursal
                    --       AND status_cancelado <> 'S') THEN
					--	CALL bdisac:sp_ReversionSac(pempresa,psucursal,pusuario, pfolio) RETURNING cCodret2;
            --	END IF;
		LET cont_exist = 0;
		SELECT COUNT (referencia1) INTO cont_exist
        FROM bdisac:"informix".sac_movimientos
        WHERE folio_suc = pfolio
        AND id_sucursal = psucursal
        AND status_cancelado <> 'S';
		IF cont_exist > 0 THEN
		   CALL bdisac:"informix".sp_ReversionSac(pempresa,psucursal,pusuario, pfolio) RETURNING cCodret2;		  
		END IF;
--	2012.01.23 F
			--Se modifica la busqueda para ser mas eficiente.#############################################################################################
			SELECT {+INDEX (bditef:"informix".tef_operaciones  idx_tef_operaciones1)} clave_rastreo
						INTO vclave_rastreo
                        FROM bditef:"informix".tef_operaciones
                        WHERE folio_suc = pfolio
						AND clave_rastreo <> ""
						AND fecha_trans = wfechoy 
                        AND cve_status = 'PE'
						AND sucursal = psucursal;
					
					IF (vclave_rastreo IS NOT NULL OR vclave_rastreo <> '') THEN
				        UPDATE {+INDEX (bditef:"informix".tef_operaciones  idx_tef_operaciones1)} bditef:"informix".tef_operaciones 
						SET cve_status = cClaveStatus 
						WHERE folio_suc = pfolio  
						AND clave_rastreo <> "" 
						AND fecha_trans = wfechoy 
                        AND cve_status = 'PE'
						AND sucursal = psucursal;					
					END IF;
            

            RETURN cod_ret;
        ELSE
            UPDATE bdicheq:"informix".sc_docret_sbc
               SET cancelado = "S"
             WHERE empresa = pempresa
               AND folio_suc = pfolio
               AND fecha_alta = wfechoy;

--	2012.01.23 I
			   --	IF EXISTS ( SELECT referencia1
                    --	FROM bdisac:sac_movimientos
                        -- WHERE folio_suc = pfolio
                          -- AND id_sucursal = psucursal
                           --AND status_cancelado <> 'S') THEN
						--	CALL bdisac:sp_ReversionSac(pempresa,psucursal,pusuario, pfolio) RETURNING cCodret2;
				--	END IF;
		LET cont_exist = 0;
		SELECT COUNT (referencia1) INTO cont_exist
        FROM bdisac:"informix".sac_movimientos
        WHERE folio_suc = pfolio
        AND id_sucursal = psucursal
        AND status_cancelado <> 'S';
		IF cont_exist > 0 THEN
		   CALL bdisac:"informix".sp_ReversionSac(pempresa,psucursal,pusuario, pfolio) RETURNING cCodret2;		   
		END IF;
--	2012.01.23 F
			--Se modifica la busqueda para ser mas eficiente.#############################################################################################
			SELECT {+INDEX (bditef:"informix".tef_operaciones  idx_tef_operaciones1)} clave_rastreo
						INTO vclave_rastreo
                        FROM bditef:"informix".tef_operaciones
                        WHERE folio_suc = pfolio
						AND clave_rastreo <> ""
						AND fecha_trans = wfechoy 
                        AND cve_status = 'PE'
						AND sucursal = psucursal;
						
					IF (vclave_rastreo IS NOT NULL OR vclave_rastreo <> '') THEN
				        UPDATE {+INDEX (bditef:"informix".tef_operaciones  idx_tef_operaciones1)} bditef:"informix".tef_operaciones 
						SET cve_status = cClaveStatus 
						WHERE folio_suc = pfolio  
						AND clave_rastreo <> "" 
						AND fecha_trans = wfechoy 
                        AND cve_status = 'PE'
						AND sucursal = psucursal;					
					END IF;

            RETURN cod_ret;
        END IF
    END IF

    SELECT valor
      INTO vtrancancta
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pempresa
       AND codparam = "trancancta";

    SELECT valor
      INTO vtranusoccc
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pempresa
       AND codparam = "tranusoccc";

    SELECT valor
      INTO vtranintccc
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pempresa
       AND codparam = "tranintccc";

    SELECT valor
      INTO vtranusosbg
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pempresa
       AND codparam = "tranusosbg";

    SELECT valor
      INTO vtranintsbg
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pempresa
       AND codparam = "tranintsbg";
       
    SELECT TRIM(valor) 
      INTO vtrancorrespchq
      FROM bdicheq:sc_param
     WHERE empresa = pempresa
       AND codparam = "trancorrespchq";
       
    SELECT valor
      INTO vtranpagosbg
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pempresa
       AND codparam = "tranpagosbg";
    
	-- // Valida si es un envio de Orden de Pago y su estatus no esta activo no deja reversar
	--	2012.01.23 I
	--IF EXISTS ( SELECT referencia1
		-- FROM bdisac:sac_movimientos
			-- WHERE folio_suc = pfolio
				-- AND id_sucursal = psucursal
				--   AND status_cancelado <> 'S') THEN
	LET cont_exist = 0;
	SELECT COUNT (referencia1) INTO cont_exist
    FROM bdisac:"informix".sac_movimientos
    WHERE folio_suc = pfolio
    AND id_sucursal = psucursal
    AND status_cancelado <> 'S';
	IF cont_exist > 0 THEN
	--	2012.01.23 F
	-- // Obtengo transacciones de Anono a cuenta prest,  significa que es envio
		SELECT valor INTO cTransaccAbonoEnvio  --- Abono en efectivo por Orden de Pago a Cuenta Prest
		FROM Bdisac:"informix".sac_param
		WHERE empresa = '001'
		AND cod_param='5070011';
		SELECT valor INTO cTransaccAbonoEnvioC   --- Abono en Cargo a cuenta por Orden de Pago         
		FROM Bdisac:"informix".sac_param
		WHERE empresa = '001'
		AND cod_param='5070012';
		-- // Verifica si es un Envio de Orden de Pago
		SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia2a), 
		   +INDEX(bdinteg:"informix".si_transacc idx_transacc2)} 
		   COUNT(m.transacc)
			INTO contador
			FROM bdicheq:"informix".sc_movdia m, 
			bdinteg:"informix".si_transacc t
			WHERE m.empresa = pempresa 
			AND m.folio_suc = pfolio 
			AND m.cancelad <> "S"
			AND t.numero = m.transacc
			AND t.empresa = m.empresa
			AND t.reversable = "S"
			AND (t.numero = cTransaccAbonoEnvio OR t.numero = cTransaccAbonoEnvioC);
		
			IF contador >= 1 THEN --- Si es un envio			
			-- // Verifica si el estatus del envio es diferente de activo
			--	2012.01.23 I
			--IF EXISTS (SELECT referencia1
				--   FROM bdisac:sac_movimientos mov
					--	INNER JOIN bdisac:sac_enviosdineroya env ON (TRIM(mov.referencia1) = env.no_control )
				   --WHERE mov.folio_suc = pfolio
					--	AND mov.id_sucursal = psucursal
						--AND mov.status_cancelado <> 'S'
						--	AND env.estatus <> '01') THEN
						--AND env.estatus NOT IN ('00', '01')) THEN
				-- // El envio no puede ser reversado, estatus diferente de 01-activo	
				--LET cod_ret = '170';
				--RETURN cod_ret;
			LET cont_exist = 0;
			SELECT COUNT (referencia1) INTO cont_exist
			FROM bdisac:"informix".sac_movimientos mov
				INNER JOIN bdisac:"informix".sac_enviosdineroya env ON (TRIM(mov.referencia1) = env.no_control)
			WHERE mov.folio_suc = pfolio
			AND mov.id_sucursal = psucursal
			AND mov.status_cancelado <> 'S'
			AND env.estatus NOT IN ('00', '01');
			IF cont_exist > 0 THEN
				-- // El envio no puede ser reversado, estatus diferente de 01-activo	
				LET cod_ret = '170';
				RETURN cod_ret;				
			END IF;
			--	2012.01.23 F
			--Se modifica la busqueda para ser mas eficiente.#############################################################################################
			SELECT {+INDEX (bditef:"informix".tef_operaciones  idx_tef_operaciones1)} clave_rastreo
						INTO vclave_rastreo
                        FROM bditef:"informix".tef_operaciones
                        WHERE folio_suc = pfolio
						AND clave_rastreo <> ""
						AND fecha_trans = wfechoy 
                        AND cve_status = 'PE'
						AND sucursal = psucursal;
						
					IF (vclave_rastreo IS NOT NULL OR vclave_rastreo <> '') THEN						
				        UPDATE {+INDEX (bditef:"informix".tef_operaciones  idx_tef_operaciones1)} bditef:"informix".tef_operaciones 
						SET cve_status = cClaveStatus 
						WHERE folio_suc = pfolio  
						AND clave_rastreo <> "" 
						AND fecha_trans = wfechoy 
                        AND cve_status = 'PE'
						AND sucursal = psucursal;
					END IF;	
			END IF;
	END IF;
    FOREACH
        SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia2a),
                +INDEX(bdinteg:"informix".si_transacc idx_transacc2)}
               md.num_serial, md.transacc, md.cuenta, md.monto_tot, md.firme, md.en_sbc, md.remesas,
               md.dias_ret, md.num_cheq, tr.naturaleza, tr.valida_docto, tr.tipo_tran,
               md.referencia, md.suc_cuen, md.producto, tr.tpcheque, md.usuario  -- Gpo PISA 270110
          INTO wnum_serial, wtransacc, wcuenta, wmonto_tot, wfirme, wen_sbc,
               wremesas, wdias_ret, wnum_cheq, wnaturaleza, wvalida_docto,
               wtiptran, wreferencia, wsuc_cuen, wproducto, wTpCheque, wusuario
          FROM bdicheq:"informix".sc_movdia md,
               bdinteg:"informix".si_transacc tr
         WHERE md.empresa = pempresa
           AND md.folio_suc = pfolio
           AND md.cancelad <> "S"
           AND tr.numero = md.transacc
           AND tr.empresa = md.empresa
           AND tr.reversable = "S"
         ORDER BY tr.naturaleza DESC

        SELECT MAX(secuencia)
          INTO vmaxsec
          FROM bdicheq:"informix".sc_tarjeta
         WHERE empresa = pempresa
           AND cuenta = wcuenta
           AND tipo_tarjeta = "T";

        SELECT num_tarjeta
          INTO vnum_tarjeta
          FROM bdicheq:"informix".sc_tarjeta
         WHERE empresa = pempresa
           AND cuenta = wcuenta
           AND secuencia = vmaxsec;

        LET wimp_sbg_ccc = 0;
        LET wimp_chq_sbg = 0;
        LET wimp_int_ccc = 0;
        LET wimp_int_sbg = 0;
        LET wchq_exp_mes = 0;
        LET wcompend = 0;

        IF wvalida_docto = "S" AND wTpCheque = "01" THEN --- Gpo PISA270110
            LET wchq_exp_mes  = 1;
        END IF

        IF wtransacc = vtranusoccc THEN
            LET wimp_sbg_ccc = wmonto_tot;
        ELIF wtransacc = vtranusosbg THEN
            LET wimp_chq_sbg = wmonto_tot;
        ELIF wtransacc = vtranpagosbg THEN
            LET wimp_chq_sbg = wmonto_tot;
        ELIF wtransacc = vtranintccc THEN
            LET wimp_int_ccc = wmonto_tot;
        ELIF wtransacc = vtranintsbg THEN
            LET wimp_int_sbg = wmonto_tot;
        ELIF wtiptran = "05" THEN
            LET wcompend = wmonto_tot;
            LET wcomision = TRIM(wreferencia);
        END IF;

        SELECT sdo_actual, status_cta
          INTO wsdo_actual, vstatus_cta
          FROM bdicheq:"informix".sc_maechq
         WHERE empresa = pempresa
           AND cuenta = wcuenta;

        IF wnaturaleza = "C" THEN
            --- #######################  JOM INICIO  #######################
            UPDATE {+INDEX(bdicheq:"informix".sc_movdia idx_movdia6a)} sc_movdia
               SET cancelad = "S"
             WHERE cancelad <> "S"
               AND num_serial = wnum_serial;

            IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                EXIT FOREACH;
            END IF;

            INSERT INTO bdicheq:"informix".sc_movdia
            VALUES (0,pfolio,psucursal,pusuario,wfechoy,wfechoy,
                    CURRENT HOUR TO fraction(3),wtransacc,wsuc_cuen,
                    wproducto,pempresa,wcuenta," ",wnum_cheq,
                    wmonto_tot * -1,0,0,0,0,"S"," ",wsdo_actual,"0000",
                    "REV",0,vnum_tarjeta,"","",wfecha_operacion);
            --- #######################  JOM FIN  #######################

            UPDATE bdicheq:"informix".sc_maechq SET
                   sdo_actual = sdo_actual + wmonto_tot,
                   imp_cgos_mes = imp_cgos_mes - wmonto_tot,
                   num_cgos_mes = num_cgos_mes - 1,
                   chq_exp_mes = chq_exp_mes - wchq_exp_mes,
                   imp_sbg_ccc = imp_sbg_ccc + wimp_sbg_ccc,
                   imp_int_ccc = imp_int_ccc + wimp_int_ccc,
                   imp_chq_sbg = imp_chq_sbg + wimp_chq_sbg,
                   imp_int_sbg = imp_int_sbg + wimp_int_sbg,
                   com_pendiente = com_pendiente + wcompend
             WHERE empresa = pempresa
               AND cuenta = wcuenta;

            --- IF wtransacc = vtrancancta THEN

            IF vstatus_cta = "2" THEN
                UPDATE bdicheq:"informix".sc_maechq
                   SET status_cta = "1",
                       fec_cancelac = "",
                       motivo = " "
                 WHERE empresa = pempresa
                   AND cuenta = wcuenta;
            END IF

            IF wtiptran = "05" THEN
                UPDATE bdicheq:"informix".sc_detcomis
                   SET pago_com = pago_com - wmonto_tot,
                       estado_com = "P"
                 WHERE empresa = pempresa
                   AND cuenta = wcuenta
                   AND comision = wcomision
                   AND fecult_pago = wfechoy;
            END IF;

            --- Gpo PISA 270110
            IF wvalida_docto = "S" AND wTpCheque = "01" THEN
                UPDATE {+INDEX(bdicheq:"informix".sc_contch idx_contch1)} bdicheq:"informix".sc_contch
                   SET estado = "A",
                       importe = 0
                 WHERE empresa = pempresa
                   AND cuenta = wcuenta
                   AND numero = wnum_cheq;

                UPDATE bdicheq:"informix".sc_contch_hist
                   SET status = "V"
                 WHERE empresa = pempresa
                   AND cuenta = wcuenta
                   AND numchq = wnum_cheq
                   AND folio_suc = pfolio;

            END IF;
			--Si es un movimiento de servicio reversa el servicio tambien
			--IF EXISTS ( SELECT referencia1
				--		  FROM bdisac:sac_movimientos
					--	 WHERE folio_suc = pfolio
						--   AND id_sucursal = psucursal
						  -- AND status_cancelado <> 'S') THEN
				--CALL bdisac:sp_ReversionSac(pempresa,psucursal,pusuario, pfolio) RETURNING cCodret2;
			--END IF;
			--	2012.01.23 I
			LET cont_exist = 0;
			SELECT COUNT (referencia1) INTO cont_exist
			FROM bdisac:"informix".sac_movimientos
			WHERE folio_suc = pfolio
			AND id_sucursal = psucursal
			AND status_cancelado <> 'S';
			IF cont_exist > 0 THEN
				CALL bdisac:"informix".sp_ReversionSac(pempresa,psucursal,pusuario, pfolio) RETURNING cCodret2;				
			END IF;
			--	2012.01.23 F
			SELECT {+INDEX (bditef:"informix".tef_operaciones  idx_tef_operaciones1)} clave_rastreo
						INTO vclave_rastreo
                        FROM bditef:"informix".tef_operaciones
                        WHERE folio_suc = pfolio
						AND clave_rastreo <> ""
						AND fecha_trans = wfechoy 
                        AND cve_status = 'PE'
						AND sucursal = psucursal;
					IF (vclave_rastreo IS NOT NULL OR vclave_rastreo <> '') THEN						
				        UPDATE {+INDEX (bditef:"informix".tef_operaciones  idx_tef_operaciones1)} bditef:"informix".tef_operaciones 
						SET cve_status = cClaveStatus 
						WHERE folio_suc = pfolio  
						AND clave_rastreo <> "" 
						AND fecha_trans = wfechoy 
                        AND cve_status = 'PE'
						AND sucursal = psucursal;
					END IF;
        ELSE
            IF (wnaturaleza = "A") THEN
                LET wsaldo_cuenta       = 0;
                LET wsdo_actual         = 0;
                LET wsdo_retenido       = 0;
                LET wsdo_sbc            = 0;
                LET wsdo_cong           = 0;
				
                SELECT sdo_actual,sdo_retenido,sdo_cong,imp_sbg_ccc,imp_chq_sbc,saldo_sbc
                INTO wsdo_actual,wsdo_retenido,wsdo_cong,mImpSbgCcc,wsdo_sbc,mSaldoSbc
                  FROM bdicheq:"informix".sc_maechq
                 WHERE empresa = pempresa
                   AND cuenta = wcuenta;
				
                --RQM 09 704. Se executa el siguiente SP para el calculo del saldo disponible DFTL 
                EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', wsdo_actual, wsdo_retenido, wsdo_cong, mSaldoSbc, null, null, mImpSbgCcc, 'F', '5') 
                INTO cCodRetConsSdo, cMensajeRetConsSdo, wsaldo_cuenta; 

				--RQM 09 704. Se agregan las validaciones para la reversion de la inmovilizacion de saldo. Daniel Hernandez Garcia
					SELECT COUNT(*) INTO iContTxPermRet 
					FROM sc_transaccs_no_permitidas_reten_cob_auto 
					WHERE transaccion = wtransacc AND estatus = '1';
					
					IF iContTxPermRet = 0 THEN
					
						LET wsaldo_cuenta = wsaldo_cuenta + mSaldoSbc;
										
					END IF;
				
                IF wsaldo_cuenta < wfirme THEN
                    LET cod_ret = "413";
                    RETURN cod_ret;
                END IF;

                --- #######################  JOM INICIO  #######################
                UPDATE {+INDEX(bdicheq:"informix".sc_movdia idx_movdia6a)} bdicheq:"informix".sc_movdia
                   SET cancelad = "S"
                 WHERE cancelad <> "S"
                   AND num_serial = wnum_serial;

                IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                    IF vtransaccion = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    EXIT FOREACH;
                END IF;

                INSERT INTO bdicheq:"informix".sc_movdia
                VALUES (0,pfolio,psucursal,pusuario,wfechoy,wfechoy,
                        CURRENT HOUR TO fraction(3),wtransacc,wsuc_cuen,
                        wproducto,pempresa,wcuenta," ",wnum_cheq,
                        wmonto_tot * -1,0,0,0,0,"S"," ",wsdo_actual,"0000",
                        "REV",0,vnum_tarjeta,"","",wfecha_operacion);
                --- #######################  JOM FIN  #######################
                IF wen_sbc > 0 THEN
                    LET wmonto_tot = 0;

                    UPDATE bdicheq:"informix".sc_docret_sbc
                       SET cancelado = "S"
                     WHERE empresa = pempresa
                       AND cuenta = wcuenta
                       AND folio_suc = pfolio
                       AND fecha_alta = wfechoy;
                END IF;

                UPDATE bdicheq:"informix".sc_maechq
                   SET sdo_actual     = sdo_actual - wmonto_tot,
                       imp_chq_sbc    = imp_chq_sbc - wen_sbc,
                       imp_sbg_ccc    = imp_sbg_ccc - wimp_sbg_ccc,
                       imp_chq_sbg    = imp_chq_sbg - wimp_chq_sbg,
                       num_abonos_mes = num_abonos_mes - 1,
                       imp_abonos_mes = imp_abonos_mes - wmonto_tot - wen_sbc
                 WHERE empresa = pempresa
                   AND cuenta = wcuenta;
                   
				--RQM 09 704. Se agregan las validaciones para la reversion de la inmovilizacion de saldo. Daniel Hernandez Garcia
					/* SELECT COUNT(*) INTO iContTxPermRet 
					FROM sc_transaccs_permitidas_reten_cob_auto 
					WHERE transaccion = wtransacc AND estatus = '1'; */
					
					--Se valida que la transaccion este habilitada para inmovilizar el saldo y tambien se valida que se tenga un saldo inmovilizado
					IF iContTxPermRet = 0 AND mSaldoSbc > 0  THEN
												
						--Obtenemos el monto del ultimo movimiento de retencion.
						FOREACH WITH HOLD
							SELECT monto_tot,referencia,folio_suc INTO mMontoInmov,cReferenciaMovDia,cFolioSucInmov FROM bdicheq:sc_movdia WHERE cuenta = wcuenta AND transacc = '9015' AND cancelad <> 'S'
							
							IF SUBSTR(cReferenciaMovDia,1,16) = pfolio AND mMontoInmov <= mSaldoSbc THEN
							
								--Se actualiza el saldo_sbc, donde se almacena el saldo inmovilizado en favor del proceso de cobranza automatica
								UPDATE sc_maechq 
									SET saldo_sbc = saldo_sbc - mMontoInmov
								WHERE empresa = pempresa
									AND cuenta = wcuenta; 
								
								--Se cancela el movimiento del dia de la inmovilizacion
								UPDATE sc_movdia 
								SET cancelad = 'S'
								WHERE folio_suc = cFolioSucInmov;
								
								--Se actualiza el monto_retenido de la tabla de control para que se reverse el saldo inmovilizado para la cuenta especificada.
								SELECT monto_retenido INTO mMontoRetenido FROM sc_control_cobranza_automatica WHERE cuenta_captacion = wcuenta;
								
								IF (mMontoRetenido - mMontoInmov) > 0 THEN
									LET iEstatusCtrCob = 2;
								ELIF (mMontoRetenido - mMontoInmov) = 0 THEN
									LET iEstatusCtrCob = 1;
								END IF;
								
								--Se actualiza el monto_retenido de la tabla de control para que se reverse el saldo inmovilizado para la cuenta especificada.
								UPDATE sc_control_cobranza_automatica SET
								estatus = iEstatusCtrCob,
								monto_retenido = monto_retenido - mMontoInmov,
								pendiente_a_retener = pendiente_a_retener + mMontoInmov,
								fecha_modificacion = TODAY
								WHERE cuenta_captacion = wcuenta;
								
								--En caso de encontrar el registro se finaliza el foreach.
								EXIT FOREACH;
								
							ELSE
							
								CONTINUE FOREACH;
							
							END IF;
							
						END FOREACH;
					END IF;
				   
                IF wtransacc = vtrancorrespchq THEN
                    UPDATE {+INDEX (bdicheq:"informix".sc_acumdiacorresp idx_acumdiario)} bdicheq:"informix".sc_acumdiacorresp
                       SET monto_acum = monto_acum - wmonto_tot
                     WHERE cuenta = wcuenta;
                     
                    UPDATE {+INDEX (bdicheq:"informix".sc_param_corresp idx_paramcorresp)} bdicheq:"informix".sc_param_corresp
                       SET valor = valor - wmonto_tot
                     WHERE codparam = '003'
                       AND empresa = pempresa;
                END IF;
                IF vProdCrec = wproducto THEN
                    UPDATE bdicheq:"informix".sc_maechq
                       SET marca_ret = "0",
                           status_cta = "2",
                           fec_cancelac = wfechoy
                     WHERE empresa = pempresa
                       AND cuenta = wcuenta;
                END IF;
				--	2012.01.23 I
                --IF EXISTS ( SELECT referencia1
                  --            FROM bdisac:sac_movimientos
                    --         WHERE folio_suc = pfolio
                      --         AND id_sucursal = psucursal
                        --       AND status_cancelado <> 'S') THEN
					--	CALL bdisac:sp_ReversionSac(pempresa,psucursal,pusuario, pfolio) RETURNING cCodret2;
                --	END IF;
				LET cont_exist = 0;
				SELECT COUNT (referencia1) INTO cont_exist
				FROM bdisac:"informix".sac_movimientos
				WHERE folio_suc = pfolio
				AND id_sucursal = psucursal
				AND status_cancelado <> 'S';
				IF cont_exist > 0 THEN
					CALL bdisac:"informix".sp_ReversionSac(pempresa,psucursal,pusuario, pfolio) RETURNING cCodret2;					
				END IF;
				--	2012.01.23 F
				SELECT {+INDEX (bditef:"informix".tef_operaciones  idx_tef_operaciones1)} clave_rastreo
						INTO vclave_rastreo
                        FROM bditef:"informix".tef_operaciones
                        WHERE folio_suc = pfolio
						AND clave_rastreo <> ""
						AND fecha_trans = wfechoy 
                        AND cve_status = 'PE'
						AND sucursal = psucursal;
						
					IF (vclave_rastreo IS NOT NULL OR vclave_rastreo <> '') THEN						
				        UPDATE {+INDEX (bditef:"informix".tef_operaciones  idx_tef_operaciones1)} bditef:"informix".tef_operaciones 
						SET cve_status = cClaveStatus 
						WHERE folio_suc = pfolio  
						AND clave_rastreo <> "" 
						AND fecha_trans = wfechoy 
                        AND cve_status = 'PE'
						AND sucursal = psucursal;
					END IF;
            END IF;
        END IF;
        
        -- // Validacion de limites 
        SELECT {+INDEX (bdinteg:"informix".si_usuario_limites idx_usualim)} usuario
          INTO vuser_limit
          FROM bdinteg:"informix".si_usuario_limites
         WHERE usuario = wusuario
           AND empresa = pempresa;
        
        IF (vuser_limit IS NOT NULL OR vuser_limit <> '') THEN 
            SELECT transacc, id_transacc, id_canal
              INTO vtran_limit, vid_transacc, vid_canal
              FROM bdinteg:"informix".si_transacc_limites
             WHERE transacc = wtransacc
               AND empresa = pempresa
               AND sistema = '01';
           
            IF (vtran_limit IS NOT NULL OR vtran_limit <> '') THEN
                SELECT num_cte
                  INTO wnum_cte
                  FROM bdicheq:"informix".sc_maechq
                 WHERE empresa = pempresa
                   AND cuenta = wcuenta;
                   
                EXECUTE PROCEDURE bdinteg:"informix".sp_reversa_acum_x(wfechoy, wnum_cte, wcuenta, vid_transacc, vid_canal, wmonto_tot)
                INTO cod_ret, vmsje_limites, vid_autor;
                
                LET cod_ret = '000';
            END IF;
        END IF;

    END FOREACH;

    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;

    END;

    RETURN cod_ret;

END PROCEDURE
DOCUMENT
'MODIFICO: ARMANDO MORALES BARRAZA',
'DESCRIPCION: Se crea procedimiento espejo de revision.sql a diferencia que este funciona para operaciones TEF',
'VERSION: 20120717.0909',
'BD: bdicheq',
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/03',
'RAZON:                 Se agrega la nueva variable saldo_sbc (inmovilizacion por concepto de credito)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.2',
'MODIFICADO:            Luis Enrique Orozco Cosme',
'ULTIMA MODIFICACION:   2025/12/03',
'RAZON:                 Se agrega la logica para la reversion del saldo inmovilizado a las cuentas de capraciÃ³n',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.3';

CREATE PROCEDURE "informix".reversion(pempresa  CHAR(3),
                                      psucursal CHAR(4),
                                      pusuario  CHAR(8),
                                      pfolio    CHAR(16),
                                      ptiporev  CHAR(1))
RETURNING CHAR(5);
    
	DEFINE wfechoy              DATE;
    DEFINE wnaturaleza          CHAR(1);
    DEFINE wvalida_docto        CHAR(1);
    DEFINE wtipo                CHAR(1);
    DEFINE vstatus_cta          CHAR(1);
    DEFINE vid_autor            CHAR(1);
    DEFINE vtpo_per_valida      CHAR(1);
    DEFINE cStatus              CHAR(1);
    DEFINE wedoctacnt           CHAR(1);
    DEFINE wsobregira           CHAR(1);
    DEFINE wtiptran             CHAR(2);
    DEFINE wtpcheque            CHAR(2);
    DEFINE vid_transacc         CHAR(2);
    DEFINE vid_canal            CHAR(2);
    DEFINE vestado_oper         CHAR(2);
    DEFINE vestado_cta          CHAR(2);
    DEFINE wtransacc            CHAR(4);
    DEFINE vtranusoccc          CHAR(4);
    DEFINE vtrancancta          CHAR(4);
    DEFINE vtranintccc          CHAR(4);
    DEFINE vtranusosbg          CHAR(4);
    DEFINE vtranintsbg          CHAR(4);
    DEFINE wcomision            CHAR(4);
    DEFINE wsuc_cuen            CHAR(4);
    DEFINE wproducto            CHAR(4);
    DEFINE vProdCrec            CHAR(4);
    DEFINE vtrancorrespchq      CHAR(4);
    DEFINE vtran_limit          CHAR(4);
    DEFINE cTransaccAbonoEnvio  CHAR(4);
    DEFINE cTransaccAbonoEnvioC CHAR(4);
    DEFINE vtranpagosbg         CHAR(4);
    DEFINE wsuc_tran            CHAR(4);
    DEFINE cTranRetEfect		CHAR(4);
	DEFINE cTranTraspCgo	    CHAR(4);
    DEFINE pcod_ret              CHAR(5);
    DEFINE cod_ret2             CHAR(5);
    DEFINE cRetRevSac           CHAR(5);
    DEFINE cod_ret_lim          CHAR(5);
    DEFINE vidtransacc          CHAR(5);
    DEFINE vcodret_reg          CHAR(5);
    DEFINE cCodRetIndicador		CHAR(6);
    DEFINE vfolio               CHAR(7);
    DEFINE wusuario             CHAR(8);
    DEFINE vuser_limit          CHAR(8);
    DEFINE vSQL                 CHAR(10);
    DEFINE vnum_tarjeta         CHAR(16);
    DEFINE wcuenta              CHAR(20);
    DEFINE wnum_cte             CHAR(20);
    DEFINE cCuenta              CHAR(20);
    DEFINE vclave_rastreo       CHAR(30);
    DEFINE wreferencia          CHAR(40);
    DEFINE cod_ret3             CHAR(50);
    DEFINE desc_err             CHAR(50);
    DEFINE vmsje_limites        CHAR(80);
    DEFINE sql_err              INTEGER;
    DEFINE isam_err             INTEGER;
    DEFINE wnum_serial          INTEGER;
    DEFINE wnum_cheq            INTEGER;
    DEFINE vtransaccion         INTEGER;
    DEFINE cont_exist       	INTEGER; 
    DEFINE vserial              INTEGER;
    DEFINE vvueltas             INTEGER;
    DEFINE wdias_ret            SMALLINT;
    DEFINE contador             SMALLINT;
    DEFINE wchq_exp_mes         SMALLINT;
    DEFINE iExisteTrx           SMALLINT;
    DEFINE wexiste              SMALLINT;
    DEFINE wcompend             MONEY(14,2);
    DEFINE wmonto_tot           MONEY(14,2);
    DEFINE wfirme               MONEY(14,2);
    DEFINE wen_sbc              MONEY(14,2);
    DEFINE wremesas             MONEY(14,2);
    DEFINE wimp_sbg_ccc         MONEY(14,2);
    DEFINE wimp_chq_sbg         MONEY(14,2);
    DEFINE wimp_int_ccc         MONEY(14,2);
    DEFINE wimp_int_sbg         MONEY(14,2);
    DEFINE wsaldo_cuenta        MONEY(14,2);
    DEFINE wsdo_actual          MONEY(14,2);
    DEFINE wsdo_retenido        MONEY(14,2);
    DEFINE wsdo_sbc             MONEY(14,2);
    DEFINE wsdo_cong            MONEY(14,2);
    DEFINE vfecha_operacion     DATE;
	DEFINE vcod_ret             CHAR(5);
    DEFINE vtrancorrespchqoxxo  CHAR(4);
    DEFINE vtrancorrespchqseven CHAR(4);
    DEFINE vreferencia          CHAR(40);
    DEFINE wcorresp             SMALLINT;
    DEFINE vExisLimProd         SMALLINT;
    DEFINE vTrxExentaLimProd    SMALLINT;
    DEFINE vExisAcumCtaNvl2     SMALLINT;
	--RQM 09 704.Se definen las variables requeridas para la consulta del saldo disponible.DHG
	DEFINE mImpSbgCcc       	MONEY(14,2); --Monto del importe de sobregiro de compras de comercio.
	DEFINE mSaldoSBC        	MONEY(14,2); --Monto del saldo inmovilizado (salvo buen cobro) de la cuenta.
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
	
  DEFINE iContTxPermRet		INTEGER;		--Contador para la validacion de transaccion con reversion de saldo inmovilizado.
	DEFINE mMontoInmov			MONEY(14,2); 	--Monto invomilizado en cuenta para reversion de abonos.
	DEFINE cReferenciaMovDia	CHAR(40);		--Referencia del movimiento del dia, se utiliza en el proceso de reversion de cobranza automatica.
	DEFINE iEstatusCtrCob		INTEGER;		--Estatus para la actualizacion de registro en tabla de control de cobranza
	DEFINE mMontoRetenido	MONEY(14,2);	--Monto pendiente por retener de la tabla de control de cobranza
	DEFINE cFolioSucInmov		CHAR(16);		--Folio suc del movimiento de inmovilizacion 
    
    LET wfechoy              = '';
    LET wnaturaleza          = '';
    LET wvalida_docto        = '';
    LET wtipo                = '';
    LET vstatus_cta          = '';
    LET vid_autor            = '';
    LET vtpo_per_valida      = '';
    LET cStatus              = '';
    LET wedoctacnt           = '';
    LET wsobregira           = '';
    LET wtiptran             = '';
    LET wtpcheque            = '';
    LET vid_transacc         = '';
    LET vid_canal            = '';
    LET vestado_oper         = '';
    LET vestado_cta          = '';
    LET wtransacc            = '';
    LET vtranusoccc          = '';
    LET vtrancancta          = '';
    LET vtranintccc          = '';
    LET vtranusosbg          = '';
    LET vtranintsbg          = '';
    LET wcomision            = '';
    LET wsuc_cuen            = '';
    LET wproducto            = '';
    LET vProdCrec            = '';
    LET vtrancorrespchq      = '';
    LET vtran_limit          = '';
    LET cTransaccAbonoEnvio  = '';
    LET cTransaccAbonoEnvioC = '';
    LET vtranpagosbg         = '';
    LET wsuc_tran            = '';
    LET cTranRetEfect		 = '';
	LET cTranTraspCgo	     = '';
    LET pcod_ret              = '000';
    LET cod_ret2             = '';
    LET cRetRevSac           = '00000';
    LET cod_ret_lim          = '';
    LET vidtransacc          = '';
    LET vcodret_reg          = '';
    LET cCodRetIndicador     = '';
    LET vfolio               = '';
    LET wusuario             = '';
    LET vuser_limit          = '';
    LET vSQL                 = '';
    LET vnum_tarjeta         = '';
    LET wcuenta              = '';
    LET wnum_cte             = '';
    LET cCuenta              = '';
    LET vclave_rastreo       = '';
    LET wreferencia          = '';
    LET cod_ret3             = '';
    LET desc_err             = '';
    LET vmsje_limites        = '';
    LET sql_err              = 0;
    LET isam_err             = 0;
    LET wnum_serial          = 0;
    LET wnum_cheq            = 0;
    LET vtransaccion         = 0;
    LET cont_exist       	 = 0;
    LET vserial              = 0;
    LET vvueltas             = 0;
    LET wdias_ret            = 0;
    LET contador             = 0;
    LET wchq_exp_mes         = 0;
    LET iExisteTrx           = 0;
    LET wexiste              = 0;
    LET wcompend             = 0.00;
    LET wmonto_tot           = 0.00;
    LET wfirme               = 0.00;
    LET wen_sbc              = 0.00;
    LET wremesas             = 0.00;
    LET wimp_sbg_ccc         = 0.00;
    LET wimp_chq_sbg         = 0.00;
    LET wimp_int_ccc         = 0.00;
    LET wimp_int_sbg         = 0.00;
    LET wsaldo_cuenta        = 0.00;
    LET wsdo_actual          = 0.00;
    LET wsdo_retenido        = 0.00;
    LET wsdo_sbc             = 0.00;
    LET wsdo_cong            = 0.00;
	LET vfecha_operacion     = TODAY;
	LET vcod_ret             = '000';
    LET vtrancorrespchqoxxo  = '';
    LET vtrancorrespchqseven  = '';
    LET vreferencia          = '';
    LET wcorresp             = 0;
    LET vExisLimProd         = 0;
    LET vTrxExentaLimProd    = 0;
    LET vExisAcumCtaNvl2     = 0;
	--RQM 09 704. Se inicializan las variables para el llamado y retorno de consulta de saldo. DHG.
	LET mImpSbgCcc			=0.00;
	LET mSaldoSBC   		=0.00;
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';
	LET iContTxPermRet		= 0;
	LET mMontoInmov			= 0.00;		
	LET cReferenciaMovDia	= '';
	LET iEstatusCtrCob		= 0;
	LET mMontoRetenido	= 0.00;
	LET cFolioSucInmov		= '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        IF sql_err <> 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/reversion.err";
			TRACE ON;
            LET pcod_ret = sql_err;
            LET cod_ret2 = isam_err;
            LET cod_ret3 = desc_err;
            IF SUBSTR(cCuenta, 1, 2) <> '80' THEN
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
            END IF;
            RETURN pcod_ret;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;
    
    ON EXCEPTION IN (-211, -242, -243, -244, -311)
        LET pcod_ret = '999';
        RETURN pcod_ret;
    END EXCEPTION WITH RESUME;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/reversion.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    LET pempresa = pempresa;
    LET psucursal = psucursal;
    LET pusuario = pusuario;
    LET pfolio =  pfolio;
    LET ptiporev = ptiporev;
    LET pcod_ret = "000";
    LET cRetRevSac = "00000";
    LET cCodRetIndicador = "000000";
    
    SELECT {+INDEX(sc_movdia idx_movdia2a)} 
           FIRST 1 cuenta
      INTO cCuenta
      FROM sc_movdia
     WHERE folio_suc = pfolio
       AND empresa = pempresa
       AND cancelad <> 'S';
    
    -- // PARA CUENTAS TRANSFER
    IF SUBSTR(cCuenta, 1, 2) = '80' THEN
        
        LET pcod_ret = '999';
        
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;

        RETURN pcod_ret;
        
        /* #############################################################################################################################################    
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            BEGIN WORK;
        END IF;
        
        SELECT valor
          INTO vidtransacc
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = 'TranReverTransfer';
        
        CALL sp_transfer_online_reverso( vidtransacc, cCuenta, pfolio, pusuario )
        RETURNING vcodret_reg, vserial;
        
        IF ( vcodret_reg is null OR vcodret_reg <> '000' ) OR ( vserial is null OR vserial = 0 ) THEN
            LET pcod_ret = '999';
        
            IF vtransaccion = 1 THEN
                COMMIT WORK;
                BEGIN WORK;
            ELSE
                COMMIT WORK;
            END IF;

            RETURN pcod_ret;
        END IF;
        
        COMMIT WORK;
        
        LET vvueltas = 0;
        LET cStatus = 'N';
        
        WHILE cStatus IN('N','E')
            SELECT status
              INTO cStatus
              FROM sc_transfer_online
             WHERE no_serial = vserial
               AND cuenta = cCuenta
               AND folio_suc = pfolio
               AND id_transacc = vidtransacc;
        
            IF cStatus IN('F','X') THEN
                EXIT WHILE;
            ELSE
                LET vSQL = 'sleep 3';
                SYSTEM vSQL;

                LET vvueltas = vvueltas + 1;

                IF vvueltas > 5 THEN
                    EXIT WHILE;
                END IF;
            END IF;
        END WHILE;
        
        IF ( cStatus is null OR cStatus = '' OR cStatus IN('N','E') ) THEN
            UPDATE {+INDEX(sc_transfer_online idx_transferonline_serctafoltra)}
                   sc_transfer_online
               SET status = 'T'
             WHERE no_serial = vserial
               AND cuenta = cCuenta
               AND folio_suc = pfolio
               AND id_transacc = vidtransacc;
            
            LET pcod_ret = '24';
            
            IF vtransaccion = 1 THEN
                BEGIN WORK;
            END IF;
            
            return pcod_ret;
        
        ELIF cStatus = 'X' THEN
        
            SELECT cod_ret
              INTO pcod_ret
              FROM sc_transfer_online
             WHERE no_serial = vserial
               AND cuenta = cCuenta
               AND folio_suc = pfolio
               AND id_transacc = vidtransacc;
			  
            
            IF vtransaccion = 1 THEN
                BEGIN WORK;
            END IF;
            
            return pcod_ret;
        END IF;
        
        BEGIN WORK;
        
        UPDATE {+INDEX(sc_movdia idx_movdia2a)} 
               sc_movdia
           SET cancelad = "S"
         WHERE folio_suc = pfolio
           AND empresa = pempresa;
        
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;
        ############################################################################################################################################# */
        
    ELSE
        
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            BEGIN WORK;
        END IF;
        
        SELECT {+INDEX(sc_fechas idx_fechas1)}
               fecha_hoy
          INTO wfechoy
          FROM sc_fechas
         WHERE empresa = pempresa;
        
        SELECT valor
          INTO vProdCrec
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam ="PRODCREC";
        
        -- // Abono en efectivo por Orden de Pago a Cuenta Prest
        SELECT valor
          INTO cTransaccAbonoEnvio  
          FROM bdisac:sac_param
         WHERE empresa = '001'
           AND cod_param = '5070011';
        
        -- // Abono en Cargo a cuenta por Orden de Pago
        SELECT valor
          INTO cTransaccAbonoEnvioC   
          FROM bdisac:sac_param
         WHERE empresa = '001'
           AND cod_param = '5070012';
        
        SELECT {+INDEX(sc_movdia idx_movdia2a),
                +INDEX(bdinteg:si_transacc idx_transacc2)}
               COUNT(*)
          INTO contador
          FROM sc_movdia m,
               bdinteg:si_transacc t
         WHERE m.empresa = pempresa
           AND m.folio_suc = pfolio
           AND m.cancelad <> "S"
           AND t.numero = m.transacc
           AND t.empresa = m.empresa
           AND t.reversable = "S";
        
        -- #############################  INICIO reversion de servicios  ############################# --
        IF contador = 0 THEN
            LET cont_exist = 0;
            
            SELECT COUNT (referencia1)
              INTO cont_exist
              FROM bdisac:sac_movimientos
             WHERE folio_suc = pfolio
               AND status_cancelado <> 'S';
            
            IF cont_exist > 0 THEN
                CALL bdisac:sp_ReversionSac(pempresa,psucursal,pusuario, pfolio)
                RETURNING cRetRevSac;

                IF cRetRevSac < 0 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                    LET pcod_ret = '999';
                END IF;
            END IF;
            
            SELECT {+INDEX (bditef:tef_operaciones  idx_tef_operaciones1)} 
                   clave_rastreo
              INTO vclave_rastreo
              FROM bditef:tef_operaciones
             WHERE folio_suc = pfolio
               AND clave_rastreo <> ""
               AND fecha_trans = wfechoy
               AND cve_status = 'PE'
               AND sucursal = psucursal;
            
            IF (vclave_rastreo is not null OR vclave_rastreo <> '') THEN
                UPDATE {+INDEX (bditef:tef_operaciones  idx_tef_operaciones1)}
                       bditef:tef_operaciones
                   SET cve_status = '04'
                 WHERE folio_suc = pfolio
                   AND clave_rastreo <> ""
                   AND fecha_trans = wfechoy
                   AND cve_status = 'PE'
                   AND sucursal = psucursal;
            END IF;
        END IF;
        -- #############################  FINAL reversion de servicios  ############################# --
        
        IF (contador = 0) THEN
            SELECT COUNT(*)
              INTO contador
              FROM sc_docret_sbc
             WHERE empresa = pempresa
               AND folio_suc = pfolio
               AND fecha_alta = wfechoy;
            
            IF (contador = 0) THEN
                LET cont_exist = 0;
            
                SELECT {+INDEX (bdisuc:ss_operaciones  idx_ss_operaciones2)}
                       COUNT (folio_oper)
                  INTO cont_exist
                  FROM bdisuc:ss_operaciones
                 WHERE sucursal = psucursal
                   AND folio_sucursal = pfolio
                   AND reversado <> '1';
                
                IF cont_exist > 0 THEN
                    CALL bdisuc:reversion(pempresa,psucursal,pusuario, pfolio,ptiporev)
                    RETURNING cRetRevSac;
                END IF;
                
                RETURN pcod_ret;
            ELSE
                UPDATE sc_docret_sbc
                   SET cancelado = "S"
                 WHERE empresa = pempresa
                   AND folio_suc = pfolio
                   AND fecha_alta = wfechoy;
                
                RETURN pcod_ret;
            END IF
        END IF
        
        SELECT valor
          INTO vtrancancta
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = "trancancta";
        
        SELECT valor
          INTO vtranusoccc
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = "tranusoccc";
        
        SELECT valor
          INTO vtranintccc
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = "tranintccc";
        
        SELECT valor
          INTO vtranusosbg
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = "tranusosbg";
        
        SELECT valor
          INTO vtranintsbg
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = "tranintsbg";
        
        SELECT valor
          INTO vtrancorrespchq
          FROM bdicheq:sc_param
         WHERE empresa = pempresa
           AND codparam = "trancorrespchq";
           
        SELECT valor
          INTO vtrancorrespchqoxxo
          FROM bdicheq:sc_param
        WHERE empresa = pempresa
           AND codparam = "trancorrespchqoxxo";
        
        SELECT valor
            INTO vtrancorrespchqseven
        FROM bdicheq:sc_param
            WHERE empresa = '001'
                AND codparam = 'trancorrespchqseven';
           
		SELECT valor
		  INTO cTranRetEfect
		  FROM bdicheq: sc_param
		 WHERE empresa = "001"
		   AND codparam = "retefectbancefec";
		
		SELECT valor
		  INTO cTranTraspCgo
		  FROM bdicheq: sc_param
		 WHERE empresa = "001"
		   AND codparam = "traspctasbancefeccgo";
        
        SELECT valor
          INTO vtranpagosbg
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = "tranpagosbg";
        
        FOREACH
            SELECT {+INDEX(sc_movdia idx_movdia2a),
                    +INDEX(bdinteg:si_transacc idx_transacc2)}
                   md.num_serial, md.transacc, md.cuenta, md.monto_tot, md.firme, md.en_sbc, md.remesas,
                   md.dias_ret, md.num_cheq, tr.naturaleza, tr.valida_docto, tr.tipo_tran, tr.sobregira,
                   md.referencia, md.suc_cuen, md.producto, tr.tpcheque, md.usuario, md.sucursal, md.edo_cta
              INTO wnum_serial, wtransacc, wcuenta, wmonto_tot, wfirme, wen_sbc, wremesas, 
                   wdias_ret, wnum_cheq, wnaturaleza, wvalida_docto, wtiptran, wsobregira,
                   wreferencia, wsuc_cuen, wproducto, wTpCheque, wusuario, wsuc_tran, wedoctacnt
              FROM sc_movdia md,
                   bdinteg:si_transacc tr
             WHERE md.empresa = pempresa
               AND md.folio_suc = pfolio
               AND md.cancelad <> "S"
               AND tr.numero = md.transacc
               AND tr.empresa = md.empresa
               AND tr.reversable = "S"
             ORDER BY tr.naturaleza DESC
            
            SELECT tpper_valida
              INTO vtpo_per_valida
              FROM sc_producto
             WHERE producto = wproducto;
            
            LET wimp_sbg_ccc = 0;
            LET wimp_chq_sbg = 0;
            LET wimp_int_ccc = 0;
            LET wimp_int_sbg = 0;
            LET wchq_exp_mes = 0;
            LET wcompend     = 0;
            
            IF wvalida_docto = "S" AND wTpCheque = "01" THEN
                LET wchq_exp_mes  = 1;
            END IF
            
            IF   wtransacc = vtranusoccc THEN
                LET wimp_sbg_ccc = wmonto_tot;
            ELIF wtransacc = vtranusosbg THEN
                LET wimp_chq_sbg = wmonto_tot;
            ELIF wtransacc = vtranpagosbg THEN
                LET wimp_chq_sbg = wmonto_tot;
            ELIF wtransacc = vtranintccc THEN
                LET wimp_int_ccc = wmonto_tot;
            ELIF wtransacc = vtranintsbg THEN
                LET wimp_int_sbg = wmonto_tot;
            ELIF wtiptran = "05"         THEN
                LET wcompend = wmonto_tot;
                LET wcomision = TRIM(wtransacc);
            END IF;
            
            SELECT sdo_actual, status_cta, num_cte
              INTO wsdo_actual, vstatus_cta, wnum_cte
              FROM sc_maechq
             WHERE empresa = pempresa
               AND cuenta = wcuenta;
            
            IF wnaturaleza = "C" THEN
                UPDATE {+INDEX(sc_movdia idx_sc_movdia_02)} 
                       sc_movdia
                   SET cancelad = "S"
                 WHERE cancelad <> "S"
                   AND num_serial = wnum_serial;
                
                IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                    IF vtransaccion = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    EXIT FOREACH;
                END IF;
                
                INSERT INTO sc_movdia VALUES
                ( 0, pfolio, psucursal, pusuario, wfechoy, wfechoy, current hour to fraction(3), wtransacc, wsuc_cuen, wproducto, pempresa, 
                  wcuenta, " ", wnum_cheq, wmonto_tot * -1, 0, 0, 0, 0, "S", vstatus_cta, wsdo_actual, "0000", "REV", 0, vnum_tarjeta, "" ,"", vfecha_operacion);
                
                /* ########################################################
                IF wedoctacnt is not null AND wedoctacnt <> '' THEN
                    UPDATE sc_maechq SET
                           sdo_actual    = sdo_actual + wmonto_tot,
                           imp_cgos_mes  = imp_cgos_mes - wmonto_tot,
                           num_cgos_mes  = num_cgos_mes - 1,
                           chq_exp_mes   = chq_exp_mes - wchq_exp_mes,
                           imp_sbg_ccc   = imp_sbg_ccc + wimp_sbg_ccc,
                           imp_int_ccc   = imp_int_ccc + wimp_int_ccc,
                           imp_chq_sbg   = imp_chq_sbg + wimp_chq_sbg,
                           imp_int_sbg   = imp_int_sbg + wimp_int_sbg,
                           com_pendiente = com_pendiente + wcompend,
                           status_cta    = wedoctacnt
                     WHERE empresa = pempresa
                       AND cuenta  = wcuenta;
                ELSE
                    UPDATE sc_maechq SET
                           sdo_actual    = sdo_actual + wmonto_tot,
                           imp_cgos_mes  = imp_cgos_mes - wmonto_tot,
                           num_cgos_mes  = num_cgos_mes - 1,
                           chq_exp_mes   = chq_exp_mes - wchq_exp_mes,
                           imp_sbg_ccc   = imp_sbg_ccc + wimp_sbg_ccc,
                           imp_int_ccc   = imp_int_ccc + wimp_int_ccc,
                           imp_chq_sbg   = imp_chq_sbg + wimp_chq_sbg,
                           imp_int_sbg   = imp_int_sbg + wimp_int_sbg,
                           com_pendiente = com_pendiente + wcompend
                     WHERE empresa = pempresa
                       AND cuenta  = wcuenta;
                END IF;
                ######################################################## */
                
                UPDATE sc_maechq SET
                       sdo_actual    = sdo_actual + wmonto_tot,
                       imp_cgos_mes  = imp_cgos_mes - wmonto_tot,
                       num_cgos_mes  = num_cgos_mes - 1,
                       chq_exp_mes   = chq_exp_mes - wchq_exp_mes,
                       imp_sbg_ccc   = imp_sbg_ccc + wimp_sbg_ccc,
                       imp_int_ccc   = imp_int_ccc + wimp_int_ccc,
                       imp_chq_sbg   = imp_chq_sbg + wimp_chq_sbg,
                       imp_int_sbg   = imp_int_sbg + wimp_int_sbg,
                       com_pendiente = com_pendiente + wcompend
                 WHERE empresa = pempresa
                   AND cuenta  = wcuenta;
                
                IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                    IF vtransaccion = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    EXIT FOREACH;
                END IF;
                
                IF vstatus_cta = '2' THEN
                    IF wedoctacnt <> '8' THEN
                        UPDATE sc_maechq
                           SET status_cta = "1",
                               fec_cancelac = "",
                               motivo = " "
                         WHERE empresa = pempresa
                           AND cuenta = wcuenta;
                    ELSE
                        UPDATE sc_maechq
                           SET fec_cancelac = "",
                               motivo = " "
                         WHERE empresa = pempresa
                           AND cuenta = wcuenta;
                    END IF
                END IF
                
                IF wtiptran = "05" THEN
                    UPDATE sc_detcomis
                       SET pago_com = pago_com - wmonto_tot,
                           estado_com = "P"
                     WHERE empresa = pempresa
                       AND cuenta = wcuenta
                       AND comision = wcomision
                       AND fecult_pago = wfechoy;
                END IF;
                
                IF wvalida_docto = "S" AND wTpCheque = "01" THEN
                    UPDATE {+INDEX(sc_contch idx_contch1)} 
                           sc_contch
                       SET estado = "A",
                           importe = 0
                     WHERE empresa = pempresa
                       AND cuenta = wcuenta
                       AND numero = wnum_cheq;

                    UPDATE sc_contch_hist
                       SET status = "V"
                     WHERE empresa = pempresa
                       AND cuenta = wcuenta
                       AND numchq = wnum_cheq
                       AND folio_suc = pfolio;
                END IF;
                    
                SELECT {+INDEX (bditef:tef_operaciones  idx_tef_operaciones1)} clave_rastreo
                  INTO vclave_rastreo
                  FROM bditef:tef_operaciones
                 WHERE folio_suc = pfolio
                   AND clave_rastreo <> ""
                   AND fecha_trans = wfechoy
                   AND cve_status = 'PE'
                   AND sucursal = psucursal;
                
                IF (vclave_rastreo is not null OR vclave_rastreo <> '') THEN
                    UPDATE {+INDEX (bditef:tef_operaciones  idx_tef_operaciones1)}
                           bditef:tef_operaciones
                       SET cve_status = '04'
                     WHERE folio_suc = pfolio
                       AND clave_rastreo <> ""
                       AND fecha_trans = wfechoy
                       AND cve_status = 'PE'
                       AND sucursal = psucursal;
                END IF;
				
				IF wtransacc = cTranRetEfect THEN
					UPDATE bdicheq:sc_acumdiacorrespred
					SET monto_acum = monto_acum - wmonto_tot
					WHERE cuenta = wcuenta;
				END IF;
				
				IF wtransacc = cTranTraspCgo THEN
					UPDATE bdicheq:sc_acumdiacorresptec
					SET monto_acum = monto_acum - wmonto_tot
					WHERE cuenta = wcuenta;
				END IF;
                
                IF wtransacc = '0223' THEN
                    DELETE FROM sc_retirosefectivo
                     WHERE cuenta = wcuenta
                       AND fecha = wfechoy
                       AND transacc = '0223'
                       AND sucursal = psucursal;
                END IF;
				
            ELSE
                IF (wnaturaleza = "A") THEN
                    LET wsaldo_cuenta = 0;
                    LET wsdo_actual   = 0;
                    LET wsdo_retenido = 0;
                    LET wsdo_sbc      = 0;
                    LET wsdo_cong     = 0;
                
					--RQM 09 704.Se agregan las variables de saldo a la consulta para realizar posteriormente el calculo de saldo disponible.DHG					
					SELECT sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbc,imp_sbg_ccc,saldo_sbc
                      INTO wsdo_actual, wsdo_retenido, wsdo_cong, wsdo_sbc, mImpSbgCcc, mSaldoSBC
                      FROM sc_maechq
                     WHERE empresa = pempresa
                       AND cuenta = wcuenta;

					--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
					EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('',wsdo_actual,wsdo_retenido,wsdo_cong,mSaldoSBC,0.00,0.00,mImpSbgCcc,'F',5) 
                    INTO cCodRetConsSdo,cMensajeRetConsSdo,wsaldo_cuenta;        

					--RQM 09 704. Se agregan las validaciones para la reversion de la inmovilizacion de saldo. Daniel Hernandez Garcia
					SELECT COUNT(*) INTO iContTxPermRet 
					FROM sc_transaccs_no_permitidas_reten_cob_auto 
					WHERE transaccion = wtransacc AND estatus = '1';
					
					IF iContTxPermRet = 0 THEN
					
						LET wsaldo_cuenta = wsaldo_cuenta + mSaldoSbc;
										
					END IF;

				    IF wtransacc = '0325' THEN 
                        LET wsaldo_cuenta = wsaldo_cuenta + wmonto_tot;
                    END IF;
                
                    IF wsaldo_cuenta < wfirme THEN
                        LET pcod_ret = "413";
                        IF vtransaccion = 1 THEN
                            ROLLBACK WORK;
                            BEGIN WORK;
                        ELSE
                           ROLLBACK WORK;
                        END IF;
                        RETURN pcod_ret;
                    END IF;
                
                    UPDATE {+INDEX(sc_movdia idx_sc_movdia_02)} 
                           sc_movdia
                       SET cancelad = "S"
                     WHERE cancelad <> "S"
                       AND num_serial = wnum_serial;
                
                    IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                        IF vtransaccion = 1 THEN
                            ROLLBACK WORK;
                            BEGIN WORK;
                        ELSE
                            ROLLBACK WORK;
                        END IF;
                        EXIT FOREACH;
                    END IF;
                
                    INSERT INTO sc_movdia VALUES
                    ( 0, pfolio, psucursal, pusuario, wfechoy, wfechoy, current hour to fraction(3), wtransacc, wsuc_cuen, wproducto, pempresa, 
                      wcuenta, " ", wnum_cheq, wmonto_tot * -1, 0, 0, 0, 0, "S", vstatus_cta, wsdo_actual, "0000", "REV", 0, vnum_tarjeta, "" ,"", vfecha_operacion);
            
                    IF wen_sbc > 0 THEN
                        LET wmonto_tot = 0;
            
                        UPDATE sc_docret_sbc
                           SET cancelado = "S"
                         WHERE empresa = pempresa
                           AND cuenta = wcuenta
                           AND folio_suc = pfolio
                           AND fecha_alta = wfechoy;
                    END IF;
            
                    /* ####################################################################
                    IF wedoctacnt is not null AND wedoctacnt <> '' THEN
                        UPDATE sc_maechq
                           SET sdo_actual     = sdo_actual - wmonto_tot,
                               imp_chq_sbc    = imp_chq_sbc - wen_sbc,
                               imp_sbg_ccc    = imp_sbg_ccc - wimp_sbg_ccc,
                               imp_chq_sbg    = imp_chq_sbg - wimp_chq_sbg,
                               num_abonos_mes = num_abonos_mes - 1,
                               imp_abonos_mes = imp_abonos_mes - wmonto_tot - wen_sbc,
                               status_cta     = wedoctacnt
                         WHERE empresa = pempresa
                           AND cuenta = wcuenta;
                    ELSE
                        UPDATE sc_maechq
                           SET sdo_actual     = sdo_actual - wmonto_tot,
                               imp_chq_sbc    = imp_chq_sbc - wen_sbc,
                               imp_sbg_ccc    = imp_sbg_ccc - wimp_sbg_ccc,
                               imp_chq_sbg    = imp_chq_sbg - wimp_chq_sbg,
                               num_abonos_mes = num_abonos_mes - 1,
                               imp_abonos_mes = imp_abonos_mes - wmonto_tot - wen_sbc
                         WHERE empresa = pempresa
                           AND cuenta = wcuenta;
                    END IF;
                    #################################################################### */
                    
                    UPDATE sc_maechq
                       SET sdo_actual     = sdo_actual - wmonto_tot,
                           imp_chq_sbc    = imp_chq_sbc - wen_sbc,
                           imp_sbg_ccc    = imp_sbg_ccc - wimp_sbg_ccc,
                           imp_chq_sbg    = imp_chq_sbg - wimp_chq_sbg,
                           num_abonos_mes = num_abonos_mes - 1,
                           imp_abonos_mes = imp_abonos_mes - wmonto_tot - wen_sbc
                     WHERE empresa = pempresa
                       AND cuenta = wcuenta;

					--RQM 09 704. Se agregan las validaciones para la reversion de la inmovilizacion de saldo. Daniel Hernandez Garcia
					-- SELECT COUNT(*) INTO iContTxPermRet 
					-- FROM sc_transaccs_no_permitidas_reten_cob_auto 
					-- WHERE transaccion = wtransacc AND estatus = '1';
					
					--Se valida que la transaccion este habilitada para inmovilizar el saldo y tambien se valida que se tenga un saldo inmovilizado
					IF iContTxPermRet = 0 AND mSaldoSbc > 0  THEN
												
						--Obtenemos el monto del ultimo movimiento de retencion.
						FOREACH WITH HOLD
							SELECT monto_tot,referencia,folio_suc INTO mMontoInmov,cReferenciaMovDia,cFolioSucInmov FROM bdicheq:sc_movdia WHERE cuenta = wcuenta AND transacc = '9015' AND cancelad <> 'S'
							
							IF SUBSTR(cReferenciaMovDia,1,16) = pfolio AND mMontoInmov <= mSaldoSbc THEN
							
								--Se actualiza el saldo_sbc, donde se almacena el saldo inmovilizado en favor del proceso de cobranza automatica
								UPDATE sc_maechq 
									SET saldo_sbc = saldo_sbc - mMontoInmov
								WHERE empresa = pempresa
									AND cuenta = wcuenta; 
								
								--Se cancela el movimiento del dia de la inmovilizacion
								UPDATE sc_movdia 
								SET cancelad = 'S'
								WHERE folio_suc = cFolioSucInmov;
								
								--Se actualiza el monto_retenido de la tabla de control para que se reverse el saldo inmovilizado para la cuenta especificada.
								SELECT monto_retenido INTO mMontoRetenido FROM sc_control_cobranza_automatica WHERE cuenta_captacion = wcuenta;
								
								IF (mMontoRetenido - mMontoInmov) > 0 THEN
									LET iEstatusCtrCob = 2;
								ELIF (mMontoRetenido - mMontoInmov) = 0 THEN
									LET iEstatusCtrCob = 1;
								END IF;
								
								--Se actualiza el monto_retenido de la tabla de control para que se reverse el saldo inmovilizado para la cuenta especificada.
								UPDATE sc_control_cobranza_automatica SET
								estatus = iEstatusCtrCob,
								monto_retenido = monto_retenido - mMontoInmov,
								pendiente_a_retener = pendiente_a_retener + mMontoInmov,
								fecha_modificacion = TODAY
								WHERE cuenta_captacion = wcuenta;
								
								--En caso de encontrar el registro se finaliza el foreach.
								EXIT FOREACH;
								
							ELSE
							
								CONTINUE FOREACH;
							
							END IF;
							
						END FOREACH;
					END IF;
					
                    IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                        IF vtransaccion = 1 THEN
                            ROLLBACK WORK;
                            BEGIN WORK;
                        ELSE
                            ROLLBACK WORK;
                        END IF;
                        EXIT FOREACH;
                    END IF;
                    
                    IF (wtransacc = vtrancorrespchq OR wtransacc = vtrancorrespchqoxxo OR wtransacc = vtrancorrespchqseven) THEN
                        SELECT corresp
                          INTO wcorresp
                          FROM sc_transacc_corresp
                         WHERE transacc = wtransacc;
                         
                        UPDATE {+INDEX (bdicheq:sc_acumdiacorresp idx_acumdiacorresp_ctacorr)} 
                               sc_acumdiacorresp
                           SET monto_acum = monto_acum - wmonto_tot
                         WHERE cuenta = wcuenta
                           AND corresp = wcorresp
                           AND transacc = wtransacc;

                        UPDATE {+INDEX (bdicheq:sc_param_corresp idx_paramcorresp)} 
                               sc_param_corresp
                           SET valor = valor - wmonto_tot
                         WHERE codparam = '003'
                           AND empresa = pempresa;
                    END IF;
                    
                    -- // REVERSA ACUMULADO CUENTAS NIVEL 2
                    SELECT {+INDEX(sc_limites_producto idx_limites_producto_prod)}
                           COUNT(*)
                      INTO vExisLimProd
                      FROM sc_limites_producto
                     WHERE producto = wproducto;
                     
                    IF vExisLimProd > 0 THEN
                        SELECT {+INDEX(sc_transacc_exentas_limprod idx_transacc_exentas_limprod_trx)}
                               COUNT(*)
                          INTO vTrxExentaLimProd
                          FROM sc_transacc_exentas_limprod
                         WHERE transacc = wtransacc;
                         
                        IF vTrxExentaLimProd = 0 THEN
                            SELECT {+INDEX(sc_acummesctanvl2 idx_acummesctanvl2_cta)}
                                   COUNT(*)
                              INTO vExisAcumCtaNvl2
                              FROM sc_acummesctanvl2
                             WHERE cuenta = wcuenta;
                             
                            IF vExisAcumCtaNvl2 > 0 THEN
                                UPDATE {+INDEX(sc_acummesctanvl2 idx_acummesctanvl2_cta)} sc_acummesctanvl2
                                   SET monto_acum = monto_acum - wmonto_tot
                                 WHERE cuenta = wcuenta;
                            END IF;
                        END IF;
                    END IF;
                    
                    IF wtransacc = '0325' THEN
                        UPDATE sc_maechq
                           SET sdo_retenido = sdo_retenido - wmonto_tot
                         WHERE empresa = pempresa
                           AND cuenta = wcuenta;
                
                        DELETE FROM sc_depinterpza
                         WHERE fecha = wfechoy
                           AND num_cte = wnum_cte
                           AND cuenta = wcuenta
                           AND folio_suc = pfolio
                           AND monto_acum = wmonto_tot;
                
                        DELETE FROM sc_depositosefectivo
                         WHERE fecha = wfechoy
                           AND num_cte = wnum_cte
                           AND cuenta = wcuenta
                           AND folio_suc = pfolio
                           AND monto = wmonto_tot;
                    END IF;
                
                    IF wtransacc = '0202' AND vtpo_per_valida IN('1','3') THEN
                        DELETE FROM sc_depositosefectivo
                         WHERE fecha = wfechoy
                           AND num_cte = wnum_cte
                           AND cuenta = wcuenta
                           AND folio_suc = pfolio
                           AND monto = wmonto_tot;
                         
                        SELECT cve_estado
                          INTO vestado_oper
                          FROM bdinteg:si_ptf
                         WHERE id_ptf = wsuc_tran AND tipo <> 'C';
                            
                        /*SELECT estado
                          INTO vestado_oper
                          FROM bdinteg:si_sucursales
                         WHERE sucursal = wsuc_tran;*/
                
                        SELECT cve_estado
                          INTO vestado_cta
                          FROM bdinteg:si_ptf
                         WHERE id_ptf = wsuc_cuen AND tipo <> 'C';

                        /*SELECT estado
                          INTO vestado_cta
                          FROM bdinteg:si_sucursales
                         WHERE sucursal = wsuc_cuen;*/
                         
                        IF vestado_oper <> vestado_cta THEN
                            DELETE FROM sc_depinterpza
                             WHERE fecha = wfechoy
                               AND num_cte = wnum_cte
                               AND cuenta = wcuenta
                               AND folio_suc = pfolio
                               AND monto_acum = wmonto_tot;
                        END IF;
                    END IF;
                    
                    IF (wtransacc = '0282' OR wtransacc = '0482' OR wtransacc = '0491') AND vtpo_per_valida IN('1','3') THEN                
                        DELETE FROM sc_depositosefectivo
                         WHERE fecha = wfechoy
                           AND num_cte = wnum_cte
                           AND cuenta = wcuenta
                           AND folio_suc = pfolio
                           AND monto = wmonto_tot;
                    END IF;
                    
                    IF wtransacc = '3357' THEN
                        SELECT COUNT(*)
                          INTO wexiste
                          FROM sc_limite_sbg
                         WHERE cuenta = wcuenta;
                         
                        IF wexiste > 0 THEN
                            UPDATE sc_limite_sbg
                               SET imp_acum_sbg = imp_acum_sbg - wimp_chq_sbg
                             WHERE cuenta = wcuenta;
                        END IF;
                    END IF;
                
                    IF vProdCrec = wproducto THEN
                        UPDATE sc_maechq
                           SET marca_ret = "0",
                               status_cta = "2",
                               fec_cancelac = wfechoy
                         WHERE empresa = pempresa
                           AND cuenta = wcuenta;
                    END IF;
                    
                    SELECT {+INDEX (bditef:tef_operaciones idx_tef_operaciones1)}
                           clave_rastreo
                      INTO vclave_rastreo
                      FROM bditef:tef_operaciones
                     WHERE folio_suc = pfolio
                       AND clave_rastreo <> ""
                       AND fecha_trans = wfechoy
                       AND cve_status = 'PE'
                       AND sucursal = psucursal;
                
                    IF (vclave_rastreo is not null OR vclave_rastreo <> '') THEN
                        UPDATE {+INDEX (bditef:tef_operaciones idx_tef_operaciones1)} 
                               bditef:tef_operaciones
                           SET cve_status = '04'
                         WHERE folio_suc = pfolio
                           AND clave_rastreo <> ""
                           AND fecha_trans = wfechoy
                           AND cve_status = 'PE'
                           AND sucursal = psucursal;
                    END IF;
                END IF;
            END IF;
            
            -- // Validaciï¿½n de limites
            SELECT {+INDEX(bdinteg:si_usuario_limites idx_usualim)} usuario
              INTO vuser_limit
              FROM bdinteg:si_usuario_limites
             WHERE usuario = wusuario
               AND empresa = pempresa;
            
            IF (vuser_limit is not null OR vuser_limit <> '') THEN
                IF (vuser_limit = "intercar") THEN
                    SELECT transacc, id_transacc, id_canal
                      INTO vtran_limit, vid_transacc, vid_canal
                      FROM bdinteg:si_transacc_limites
                     WHERE transacc = wtransacc
                       AND empresa = pempresa
                       AND sistema = '01';
                ELSE
                    SELECT id_canal
                      INTO vid_canal
                      FROM bdinteg:si_canales
                     WHERE cc_canal = psucursal;
                
                    SELECT transacc, id_transacc
                      INTO vtran_limit, vid_transacc
                      FROM bdinteg:si_transacc_limites
                     WHERE transacc = wtransacc
                       AND empresa = pempresa
                       AND sistema = '01'
                       AND id_canal = vid_canal;
                END IF;
                
                IF (vtran_limit is not null OR vtran_limit <> '') THEN
                    EXECUTE PROCEDURE bdinteg:sp_reversa_acum_x(wfechoy, wnum_cte, wcuenta, vid_transacc, vid_canal, wmonto_tot)
                    INTO cod_ret_lim, vmsje_limites, vid_autor;
                END IF;
            END IF;
        END FOREACH;
            
         -- #############################  INICIO reversion de servicios #############################
		LET cont_exist = 0;
        
        SELECT COUNT (referencia1)
            INTO cont_exist
            FROM bdisac:sac_movimientos
            WHERE folio_suc = pfolio
            AND status_cancelado <> 'S';
        
		IF cont_exist > 0 THEN
            CALL bdisac:sp_ReversionSac(pempresa,psucursal,pusuario, pfolio)
            RETURNING cRetRevSac;
            
            IF  cRetRevSac < 0  THEN
                ROLLBACK WORK;
                BEGIN WORK;
                LET pcod_ret = '999';
            ELIF  cRetRevSac = 170 then
                ROLLBACK WORK;
                BEGIN WORK;
                LET pcod_ret = '170';
                RETURN pcod_ret;
            END IF;
        END IF;
        -- #############################  FINAL reversion de servicios  #############################
        
        IF wtransacc = '0303' THEN
            SELECT COUNT(*) 
              INTO iExisteTrx
              FROM sc_movdia 
             WHERE empresa = pempresa 
               AND folio_suc = pfolio 
               AND cancelad = 'S' 
               AND monto_tot = 500;
               
            IF iExisteTrx > 0 THEN
                SELECT referencia
                  INTO vreferencia
                  FROM sc_movdia
                 WHERE empresa = pempresa
                   AND folio_suc = pfolio
                   AND sucursal = psucursal
                   AND cancelad = 'S'
                   AND transacc = '0303'
                   AND monto_tot = 500;
                   
                LET vfolio = TRIM(SUBSTR(vreferencia, -9));

                UPDATE bdiprem:sc_promocion_kelloggs
                   SET entregado  = '0',
                       cuenta_abono = '',
                       sucursal = '',
                       usuario_entrega = '',
                       monto_premio = 0,
                       fecha_entrega = ''
                 WHERE empresa  = pempresa
                   AND folio = vfolio;
            END IF;
        END IF;
        
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
            
            -- // LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
            EXECUTE PROCEDURE sp_actualizar_indicadores(psucursal,wcuenta,wtransacc,wmonto_tot,wfechoy,"R")
            INTO cCodRetIndicador;
        END IF;
    
    END IF;
    
    END;
    
    RETURN pcod_ret;
    
END PROCEDURE
    
DOCUMENT
'DESCRIPCION: Se incluye el llamado al procedimiento de reversion sac para reversar las transacciones de Ordenes de pago',
'MODIFICO: Antonio Bastidas',
'FECHA: 21/01/2010',
'MODIFICO: Armando Mercado',
'DESCRIPCION: Se modifico para k no pueda reversar un envio ya pagado o cancelado, estatu <> 01',
'VERSION: 20100429.1905',
'MODIFICO: Dulce Ramirez',
'DESCRIPCION: Se modifico para que reversara las operaciones TEF en tef_operaciones',
'VERSION: 20110427.1551',
'MODIFICO: FRG',
'DESCRIPCION: Se modifico en ODP para que reverse en status 00 y se elimina flujo IF EXIST',
'VERSION: 20120123.1211',
'BD: bdicheq',
'FOLIO: 1392',
'AUTOR: JOSE ANGEL GAXIOLA GAXIOLA',
'FECHA: 21/02/2014',
'MODIFICACION: Se agrega "DESC"	al "ORDER BY tr.naturaleza"	de la consulta a las tablas "sc_movdia y si_transacc" para que',
'              tome cantidades correctas, se asigno "wcomision" correcta para realizar el reverso y se aplicaron reglas de programacion,',
'			   Se Agrega "ROLLBACK WORK" al momento de retornal: cod_ret = "413" para que no se afecten tablas si ocurre eror',
'SUSTENTO: Se definio en el Requerimiento: INC 24 015 Suc. reverso de comision de activacion TDD v1.0.pdf',
'SOLICITO: GUSTAVO SAUCEDA ARCE',
'BD: bdicheq',
'FOLIO.........: 1398 - HomologacionReversoComAct.TDD',
'AUTOR.........: 95526749 - Jesus Horacio Lopez Gonzolez',
'FECHA.........: 06/03/2014 - DSB20140306',
'MODIFICACION..: Homologacion del requerimiento anterior con la version productiva.',
'SUSTENTO......: Se definio por correo, el dia 06/03/2014 09:59:18, enviado por Cutberto Gonzalez para Yadira Morales.',
'SOLICITA......: Cutberto Gonzalez Perez',
'BD............: BDICHEQ',

'FECHA: 16/03/2021',
'AUTOR: Armando Garcia Ortiz',
'RQM 10 1185',
'MODIFICACION: Implementacion del reverso para Corresponsal 7Eleven',
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 19-08-2025',
'MODIFICACION: Se modifica la forma de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.8.1',
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 19-12-2025',
'MODIFICACION: Se agrega la logica para la reversion del saldo inmovilizado a las cuentas de capraciÃ³n', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.8.2';

create procedure "informix".bloqueo_cta( pempresa     char(3),
                                         pcuenta      char(20),
                                         pmonto       money(14,2),                          
                                         pcodbloq     char(2),
                                         popbloq      integer,
                                         pfechabloq   char(10),
                                         pusuario     char(8),
                                         pclave       char(5),
										 pAreaSolic   CHAR(2),
										 pCodArea     CHAR(1),
										 pTipoBloq    CHAR(2),
										 pCodTipoBloq CHAR(1) )
returning char(5), char(5);
    
    define cod_ret          char(3);
    define cod_ret2         char(5);
    define cod_ret3         char(50);
    define sql_err          integer;
    define isam_err         integer;
    define desc_err         char(50);
    define cta_w            char (20);
    define suc_w            char (4);
    define usu_w            char (5);
    define prod_w           char (4);
    define banca_w          char (3);
    define v_long_cta       char (2);
    define mov              char (1);
    define status_w         char (1);
    define status2_w        char (1);
    define sdoc_w           money (14,2);
    define sdod_w           money (14,2);
    define sdoa_w           money (14,2);
    define fecha_w          date;
    define hora_w           char(15);
    define edo_cta_w        char (1);
    define v_cal_int_chq    char (1);
    define v_folio          char (16);
    define folio2           char(8);
    define longitud         smallint;
    define v_transacc       char(4);
    define v_clave          char(4);
    define v_mesdia         char(4);
    define vmonto_cong      money(14,2);
    define vsdoxdesbloq     money(14,2);
    define vimporte         money(14,2);
    define vrowid           integer;
    define vfecha           date;
	define vfecha_operacion date;
    define iExiste          smallint;
    -- SE AGREGAN LAS VARIABLES DE SALDO ACTUAL, SALDO RETENIDO, SALDO CONGELADO Y SALDO SBC OACM
    DEFINE cCodRet          CHAR(5);
    DEFINE cMensajeRet      CHAR(50); 
    DEFINE mSdoRetenido     MONEY(14,2);
    DEFINE mSaldoSbc        MONEY(14,2);
    DEFINE mImpChqSbg       MONEY(14,2);

    --RQM 09 704 - Luis Enrique Orozco Cosme - Fecha modificacion: 01/10/2025
    --Variables de retorno para el sp maestro de retenciones.
    DEFINE cCodRetSpReten       CHAR(5);
    DEFINE cMensajeRetSpReten   CHAR(150);
    DEFINE cNumcte              CHAR(20);
    DEFINE cProceso             CHAR(50);
    DEFINE iContTxPermRet       INTEGER;

    let cod_ret       = '';
    let cod_ret2      = '';
    let cod_ret3      = '';
    let sql_err       = 0;
    let isam_err      = 0;
    let desc_err      = '';
    let cta_w         = '';
    let suc_w         = '';
    let usu_w         = '';
    let prod_w        = '';
    let banca_w       = '';
    let v_long_cta    = '';
    let mov           = '';
    let status_w      = '';
    let status2_w     = '';
    let sdoc_w        = 0.00;
    let sdod_w        = 0.00;
    let sdoa_w        = 0.00;
    let fecha_w       = '';
    let hora_w        = '';
    let edo_cta_w     = '';
    let v_cal_int_chq = '';
    let v_folio       = '';
    let folio2        = '';
    let longitud      = 0;
    let v_transacc    = '';
    let v_clave       = '0000';
    let v_mesdia      = '';
    let vmonto_cong   = 0.00;
    let vsdoxdesbloq  = 0.00;
    let vimporte      = 0.00;
    let vrowid        = 0;
    let vfecha        = '';
	let vfecha_operacion = TODAY;
    let iExiste = 0;
    -- SE INICIALIZAN LAS VARIABLES DE SALDO ACTUAL, SALDO RETENIDO Y SALDO SBC OACM
    LET cCodRet = '00000';
    LET cMensajeRet	= 'Proceso de consulta de saldo exitoso';
    LET mSdoRetenido = 0.00;
    LET mSaldoSbc = 0.00;
    LET mImpChqSbg = 0.00;
    --RQM 09 704 - Luis Enrique Orozco Cosme - Fecha modificacion: 01/10/2025
    --Se inicializan las variables.
    LET cCodRetSpReten      = '00000';
    LET cMensajeRetSpReten  = '';
    LET cNumcte             = '';
    LET cProceso            = 'bloqueo_cta';
    LET iContTxPermRet      = 0;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/bloqueo_cta.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            LET cod_ret2 = isam_err;
            LET cod_ret3 = desc_err;
            return cod_ret, v_clave;
        END IF;
    END EXCEPTION;
    

     ---SET DEBUG FILE TO "/resplogifx/conciliachq/bloqueo_cta.out";
     --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // Verifica recepcion completa de datos
    if ( pempresa is null or pempresa = '' ) or
       ( pcuenta is null or pcuenta = '' )   or
       ( pcodbloq is null or pcodbloq = '' ) or
       ( pusuario is null or pusuario = '' ) or
       ( popbloq = 1 and ( pmonto is null or pmonto <= 0.00 ) ) or
       ( popbloq is null or ( popbloq not in ( select opcion from sc_opcionbloqueo ) ) ) then
        let cod_ret = '110';
        return cod_ret, v_clave;
    end if;
    
    -- // Obtiene la fecha del sistema
    select fecha_hoy 
      into fecha_w 
      from sc_fechas 
     where empresa = pempresa;
    
    -- // Obtiene datos de la cuenta
    select cuenta, sucursal, producto, status_cta, sdo_cong, sdo_actual, sdo_retenido, imp_chq_sbg,saldo_sbc,num_cte
      into cta_w, suc_w, prod_w, status_w, sdoc_w, sdoa_w,mSdoRetenido,mImpChqSbg,mSaldoSbc,cNumcte
      from sc_maechq
     where cuenta = pcuenta;

    -- RQM 09 704. Se almacena el saldo actual por medio de la ejecucion del SP sp_cons_sdodisp_x_tpcalculo OACM
	EXECUTE PROCEDURE BDICHEQ:sp_cons_sdodisp_x_tpcalculo(NULL,sdoa_w,mSdoRetenido,sdoc_w,mSaldoSbc,mImpChqSbg,NULL,NULL,'F',1) 
	INTO cCodRet,cMensajeRet,sdod_w;

    -- RQM 09 704. Se agrega la validacion para el codigo de retorno del SPL sp_cons_sdodisp_x_tpcalculo. EEAP.
    if (cCodRet <> '00000') then
        let cod_ret = '420';    -- Suma de montos erronea.
        return cod_ret, v_clave;
    end if;     

    -- // Verifica datos de la cuenta
    if ( cta_w is null ) then --- Verifica que la cuenta exista 
        let cod_ret = '100';
        return cod_ret, v_clave;
    elif ( status_w = '1' and pcodbloq = '00' ) then --- Verifica si la cuenta esta desbloqueada y se esta solicitando desbloquearla
        let cod_ret = '302';
        return cod_ret, v_clave;
    elif ( status_w in ('2','6','7') ) then --- Verifica que la cuenta no este cancelada
        let cod_ret = '200';
        return cod_ret, v_clave;
    elif ( status_w = '3' and pcodbloq <> '00' and popbloq in(1,2,3,4) ) then --- Verifica si la cuenta esta bloqueada y se este solicitando bloquearla nuevamente
        let cod_ret = '303';
        return cod_ret, v_clave;
    end if;
    
    -- // Elimina bloqueo para cuentas informadas
    if pcodbloq = '00' and status_w = '5' then         
        -- // Asigna un folio
        let hora_w  = current hour to fraction;
        let folio2  = hora_w[1,2] || hora_w[4,5] || hora_w[7,8] || hora_w[10,11];
        let v_folio = trim(pusuario)||folio2;
    
        -- // Inserta registro en tabla de movimientos diarios
        insert into sc_movdia values
        ( 0, v_folio, suc_w, pusuario, fecha_w, fecha_w, current hour to fraction, '3354', suc_w, prod_w, 
          pempresa, pcuenta, ' ', 0, pmonto, 0, 0, 0, 0, " ", status_w, sdod_w, '0000', ' ', 0, '', ' ', '' );
          
        -- // Actualiza la tabla maestra de cheques
        update sc_maechq
           set motivo = ''
         where cuenta = pcuenta;

        let cod_ret = '000';
        return cod_ret, v_clave;
    end if;
	   
    -- // Verifica el Saldo a Congelar de la Cuenta
    if popbloq = 1 and pcodbloq <> '00' then
        if pmonto > sdod_w then
            let cod_ret = '162';
            return cod_ret, v_clave;
        end if;
    end if;
    
    -- // Verifica el Saldo a desbloquear de la Cuenta
    if pcodbloq = '00' then
        if pmonto > sdoc_w then
            let cod_ret = '163';
            return cod_ret, v_clave;
        end if;
    end if;
    
    -- // Asigna el Status con el que quedara la Cuenta, de acuerdo al codigo recibido
    if pcodbloq = '00' then
        let status2_w = '1';
        let mov = 'D';
        let vmonto_cong = pmonto * -1;
        let v_transacc = '3354';
        
		/* ######################## 21/10/2021
        if pmonto = sdoc_w then
            let status2_w = '1';
        else
            let status2_w = '3';
        end if;
		--21102021
		######################## 21/10/2021 */
    else
        let status2_w = '3';
        let mov = 'B';
        let vmonto_cong = pmonto;
        let v_transacc = '3353';
    end if;
    
    -- // Asigna un folio
    let hora_w  = current hour to fraction;
    let folio2  = hora_w[1,2] || hora_w[4,5] || hora_w[7,8] || hora_w[10,11];
    let v_folio = trim(pusuario)||folio2;
    
    let v_mesdia = month(fecha_w) || day(fecha_w);
    let hora_w = hora_w[4,5] || hora_w[7,8];
    
    if pcodbloq = '00' then
        let v_clave = pclave;
    else
        let v_clave = v_mesdia + hora_w;
    end if;
    
    -- // Inserta registro en historico de bloqueos
    insert into sc_histbloq 
    ( empresa, cuenta, tipo_mov, motivo, opcion, importe, usuario, fecha, hora, clave, 
      status_blo, folio_suc, referencia, cve_area, cod_area, cve_tipobloq, cod_tipobloq )
    values 
    ( pempresa, pcuenta, mov, pcodbloq, popbloq, pmonto, pusuario, fecha_w, current hour to fraction, v_clave, 
      mov, v_folio, "", pAreaSolic, pCodArea, pTipoBloq, pCodTipoBloq );

    -- // Inserta registro en tabla de movimientos diarios
    insert into sc_movdia values
    ( 0, v_folio, suc_w, pusuario, fecha_w, fecha_w, current hour to fraction, v_transacc, suc_w, prod_w, 
      pempresa, pcuenta, ' ', 0, pmonto, 0, 0, 0, 0, " ", status_w, sdod_w, '0000', ' ', 0, '', ' ', '', vfecha_operacion);
    
	-- // Inserta o elimina registro en tabla de bloqueos
	IF pcodbloq <> '00' THEN
        INSERT INTO sc_ctabloqueo
        (cuenta, clave, opcion, cve_area, cod_area, cve_tipobloq, cod_tipobloq)  
        VALUES 
        (pcuenta, pcodbloq, popbloq, pAreaSolic, pCodArea, pTipoBloq, pCodTipoBloq);
        
        INSERT INTO sc_ctabloqueohist
        (cuenta, clave, opcion)
        VALUES 
        (pcuenta, pcodbloq, popbloq);
	ELSE  
        DELETE FROM bdicheq:sc_ctabloqueo 
         WHERE cuenta = pcuenta;
        
        SELECT COUNT(*)
          INTO iExiste
          FROM sc_cuentas_retiro
         WHERE cuenta = pcuenta;
         
        IF iExiste > 0 THEN
            UPDATE sc_cuentas_retiro 
               SET estatus = 'R', 
                   no_empleado = pusuario 
             WHERE cuenta = pcuenta;
        END IF;
	END IF
    
    -- // Actualiza la tabla maestra de cheques
    /*
    update sc_maechq
       set fec_cancelac = fecha_w,
           status_cta = status2_w,
           motivo = pcodbloq,
           sdo_cong = sdo_cong + vmonto_cong,
           fecha_proceso = fecha_w
     where cuenta = pcuenta;
    */
    
    if pcodbloq = '00' then
        update sc_maechq
           set fec_cancelac = fecha_w,
               status_cta = status2_w,
               motivo = '',
               sdo_cong = sdo_cong + vmonto_cong,
               fecha_proceso = fecha_w
         where cuenta = pcuenta;

        --RQM 09 704 . Luis Enrique Orozco Cosme. Fecha modificacion: 01/10/2025 
        --Conteo para validacion de transaccion permitida
        SELECT COUNT(*) 
        INTO iContTxPermRet 
        FROM sc_transaccs_no_permitidas_reten_cob_auto 
        WHERE transaccion = v_transacc AND estatus = '1';  

        --Validacion de transaccion
        IF(iContTxPermRet = 0) THEN
            --Se llama al SPL sp_retencion_cobranza_automatica para realizar la retencion.  
            EXECUTE PROCEDURE sp_retencion_cobranza_automatica(cNumcte,pcuenta,v_folio)INTO cCodRetSpReten,cMensajeRetSpReten;

            --Agregar validacion de codigo de retorno
            IF (cCodRetSpReten NOT IN ('00000','00002','00003')) THEN
                --Registro del tipo de error al ejecutar el SPL sp_retencion_cobranza_automatica.
                INSERT INTO sc_bit_error_cobranza_automatica VALUES(0, cProceso, cCodRetSpReten, cMensajeRetSpReten, cNumcte, pcuenta, fecha_w, current hour to fraction, v_folio);                         
            END IF;
        END IF;
    else
        update sc_maechq
           set fec_cancelac = fecha_w,
               status_cta = status2_w,
               motivo = pcodbloq,
               sdo_cong = sdo_cong + vmonto_cong,
               fecha_proceso = fecha_w
         where cuenta = pcuenta;
    end if;
    
    if pcodbloq = '00' then
        if pclave <>  '' and pclave <> ' ' then
            update sc_histbloq
               set status_blo = mov
             where empresa = pempresa 
               and cuenta = pcuenta
               and clave = pclave 
               and tipo_mov = 'B';
        else
            let vsdoxdesbloq = pmonto;
            
            foreach
                select rowid,importe,fecha
                  into vrowid, vimporte,vfecha
                  from sc_histbloq
                 where empresa = pempresa 
                   and cuenta = pcuenta 
                   and tipo_mov = 'B' 
                   and status_blo = 'B'
                 order by fecha
                 
                if vimporte > vsdoxdesbloq then
                    let vimporte = vimporte - vsdoxdesbloq;
                else
                    let vimporte = vimporte;
                end if
                
                update sc_histbloq
                   set status_blo = mov,
                       importe = vimporte
                 where rowid = vrowid;
                 
                let vsdoxdesbloq = vsdoxdesbloq - vimporte;
                
                if vsdoxdesbloq = 0 then
                    exit foreach;
                end if
            end foreach
        end if
    end if
    
    let cod_ret = '000';
    
    END;
    
    return cod_ret, v_clave;
    
end procedure

DOCUMENT
'DESCRIPCION: Realiza el Bloqueo de cuentas si no estan bloqueadas',
'AUTOR: Valentin Lopez',
'FECHA: Septiembre 2010',
'VERSION: 20100929.0101',
'MODIFICACION: Valida el importe de la cuenta solo en bloqueos por importe determinado',
'AUTOR: JICS',
'FECHA: 12 de julio de 2016',
'AUTOR:  Osiel Alfredo Camacho Mendoza',
'FECHA: 10 Julio del 2025',
'VERSION: 20250710.0102',
'MODIFICACION: Se modifica la formula de consulta de saldo disponible agregandole el saldo SBC por medio del sp de consulta saldo por tipo de formula',
'MODIFICADO:    Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   07-01-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           20260701.0103',
'----------------------------------------------------',
'MODIFICO :     Luis Enrique Orozco Cosme',
'FECHA :        01-02-2026',
'MODIFICACION : Se agrega la inmovilizacion de saldos a la cuenta de captacion siempre y cuando cuente con una exigencia de un pago de credito',
'PROYECTO :     RQM 09 704 Cobranza Automatica en Cuentas de Captacion',
'BD :           bdicheq',
'VERSION :      20260201.0104';

CREATE PROCEDURE "informix".bloqueo_cta_web( pempresa     char(3),
                                         pcuenta      char(20),
                                         pmonto       money(14,2),                          
                                         pcodbloq     char(2),
                                         popbloq      integer,
                                         pfechabloq   char(10),
                                         pusuario     char(8),
                                         pclave       char(5),
                                         pAreaSolic   CHAR(2),
                                         pCodArea     CHAR(1),
                                         pTipoBloq    CHAR(2),
                                         pCodTipoBloq CHAR(1) )
returning char(5), char(5);
    
    DEFINE cod_ret          char(5);
    DEFINE cod_ret2         char(5);
    DEFINE cod_ret3         char(50);
    DEFINE sql_err          integer;
    DEFINE isam_err         integer;
    DEFINE desc_err         char(50);
    DEFINE cta_w            char (20);
    DEFINE suc_w            char (4);
    DEFINE usu_w            char (5);
    DEFINE prod_w           char (4);
    DEFINE banca_w          char (3);
    DEFINE v_long_cta       char (2);
    DEFINE mov              char (1);
    DEFINE status_w         char (1);
    DEFINE status2_w        char (1);
    DEFINE sdoc_w           money (14,2);
    DEFINE sdod_w           money (14,2);
    DEFINE sdoa_w           money (14,2);
    DEFINE fecha_w          date;
    DEFINE hora_w           char(15);
    DEFINE edo_cta_w        char (1);
    DEFINE v_cal_int_chq    char (1);
    DEFINE v_folio          char (16);
    DEFINE folio2           char(8);
    DEFINE longitud         smallint;
    DEFINE v_transacc       char(4);
    DEFINE v_clave          char(4);
    DEFINE v_mesdia         char(4);
    DEFINE vmonto_cong      money(14,2);
    DEFINE vsdoxdesbloq     money(14,2);
    DEFINE vimporte         money(14,2);
    DEFINE vrowid           integer;
    DEFINE vfecha           date;
	DEFINE vfecha_operacion date;
    --RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
    DEFINE cCodRetConsSdo       CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    --RQM 09 704. Se agregan las variables para la consulta de los campos en la maestra de cheques. EEAP.
    DEFINE mSdoRetenido  money(14,2);
    DEFINE mImpChqSbg    money(14,2);
    DEFINE mSaldoSbc     money(14,2);

    --RQM 09 704 - Luis Enrique Orozco Cosme - Fecha modificacion: 01/10/2025
    --Variables de retorno para el sp maestro de retenciones.
    DEFINE cCodRetSpReten       CHAR(5);
    DEFINE cMensajeRetSpReten   CHAR(150);
    DEFINE cNumcte              CHAR(20);
    DEFINE cProceso             CHAR(50);
    DEFINE iContTxPermRet       INTEGER;
    
    LET cod_ret       = '';
    LET cod_ret2      = '';
    LET cod_ret3      = '';
    LET sql_err       = 0;
    LET isam_err      = 0;
    LET desc_err      = '';
    LET cta_w         = '';
    LET suc_w         = '';
    LET usu_w         = '';
    LET prod_w        = '';
    LET banca_w       = '';
    LET v_long_cta    = '';
    LET mov           = '';
    LET status_w      = '';
    LET status2_w     = '';
    LET sdoc_w        = 0.00;
    LET sdod_w        = 0.00;
    LET sdoa_w        = 0.00;
    LET fecha_w       = '';
    LET hora_w        = '';
    LET edo_cta_w     = '';
    LET v_cal_int_chq = '';
    LET v_folio       = '';
    LET folio2        = '';
    LET longitud      = 0;
    LET v_transacc    = '';
    LET v_clave       = '0000';
    LET v_mesdia      = '';
    LET vmonto_cong   = 0.00;
    LET vsdoxdesbloq  = 0.00;
    LET vimporte      = 0.00;
    LET vrowid        = 0;
    LET vfecha        = '';
    LET vfecha_operacion = TODAY;
    --RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
    LET cCodRetConsSdo      = '00000';
    LET cMensajeRetConsSdo  = '';
    --RQM 09 704. Se inicializan las variables los campos retornados de la maestra de cheques. EEAP.
    LET mSdoRetenido  = 0.00;
    LET mImpChqSbg    = 0.00;
    LET mSaldoSbc     = 0.00;

    --RQM 09 704 - Luis Enrique Orozco Cosme - Fecha modificacion: 01/10/2025
    --Variables de retorno para el sp maestro de retenciones.
    LET cCodRetSpReten      = '00000';
    LET cMensajeRetSpReten  = '';
    LET cNumcte             = '';
    LET cProceso            = 'bloqueo_cta_web';
    LET iContTxPermRet      = 0;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/bloqueo_cta.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            LET cod_ret2 = isam_err;
            LET cod_ret3 = desc_err;
            return cod_ret, v_clave;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/bloqueo_cta.out";
    --- TRACE ON;
        
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // Verifica recepcion completa de datos
    if ( pempresa is null or pempresa = '' ) or
       ( pcuenta is null or pcuenta = '' )   or
       ( pcodbloq is null or pcodbloq = '' ) or
       ( pusuario is null or pusuario = '' ) or
       ( popbloq = 1 and ( pmonto is null or pmonto <= 0.00 ) ) or
       ( popbloq is null or ( popbloq not in ( select opcion from sc_opcionbloqueo ) ) ) then
        let cod_ret = '00110';
        return cod_ret, v_clave;
    end if;
    
    -- // Obtiene la fecha del sistema
    select fecha_hoy 
      into fecha_w 
      from sc_fechas 
     where empresa = pempresa;
    
    -- // Obtiene datos de la cuenta
    --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
    select cuenta, sucursal, producto, status_cta, sdo_cong, sdo_actual, sdo_retenido, imp_chq_sbg, saldo_sbc,num_cte
      into cta_w, suc_w, prod_w, status_w, sdoc_w, sdoa_w, mSdoRetenido, mImpChqSbg, mSaldoSbc, cNumcte
      from sc_maechq
     where cuenta = pcuenta;

    --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
    EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', sdoa_w, mSdoRetenido, sdoc_w, mSaldoSbc, mImpChqSbg, null, null, 'F', 1) 
    INTO cCodRetConsSdo,cMensajeRetConsSdo,sdod_w;

    -- RQM 09 704. Se agrega la validacion para el codigo de retorno del SPL sp_cons_sdodisp_x_tpcalculo. EEAP.
    if (cCodRetConsSdo <> '00000') then
        let cod_ret = '00420';    --Suma de montos erronea.
        return cod_ret, v_clave;
    end if;
       
    -- // Verifica datos de la cuenta
    if ( cta_w is null ) then --- Verifica que la cuenta exista 
        let cod_ret = '00100';
        return cod_ret, v_clave;
    elif ( status_w = '1' and pcodbloq = '00' ) then --- Verifica si la cuenta esta desbloqueada y se esta solicitando desbloquearla
        let cod_ret = '00302';
        return cod_ret, v_clave;
    elif ( status_w in ('2','6','7') ) then --- Verifica que la cuenta no este cancelada
        let cod_ret = '00200';
        return cod_ret, v_clave;
    elif ( status_w = '3' and pcodbloq <> '00' and popbloq in(1,2,3,4) ) then --- Verifica si la cuenta esta bloqueada y se este solicitando bloquearla nuevamente
        let cod_ret = '00303';
        return cod_ret, v_clave;
    end if;
    
    -- // Elimina bloqueo para cuentas informadas
    if pcodbloq = '00' and status_w = '5' then         
        -- // Asigna un folio
        let hora_w  = current hour to fraction;
        let folio2  = hora_w[1,2] || hora_w[4,5] || hora_w[7,8] || hora_w[10,11];
        let v_folio = trim(pusuario)||folio2;
    
        -- // Inserta registro en tabla de movimientos diarios
        insert into sc_movdia values
        ( 0, v_folio, suc_w, pusuario, fecha_w, fecha_w, current hour to fraction, '3354', suc_w, prod_w, 
          pempresa, pcuenta, ' ', 0, pmonto, 0, 0, 0, 0, " ", status_w, sdod_w, '0000', ' ', 0, '', ' ', '' );
          
        -- // Actualiza la tabla maestra de cheques
        update sc_maechq
           set motivo = pcodbloq
         where cuenta = pcuenta;
        
        let cod_ret = '00000';
        return cod_ret, v_clave;
    end if;
       
    -- // Verifica el Saldo a Congelar de la Cuenta
    if popbloq = 1 and pcodbloq <> '00' then
        if pmonto > sdod_w then
            let cod_ret = '00162';
            return cod_ret, v_clave;
        end if;
    end if;
    
    -- // Verifica el Saldo a desbloquear de la Cuenta
    if pcodbloq = '00' then
        if pmonto > sdoc_w then
            let cod_ret = '00163';
            return cod_ret, v_clave;
        end if;
    end if;
    
    -- // Asigna el Status con el que quedara la Cuenta, de acuerdo al codigo recibido
    if pcodbloq = '00' then
        let status2_w = '1';
        let mov = 'D';
        let vmonto_cong = pmonto * -1;
        let v_transacc = '3354';
        
        if pmonto = sdoc_w then
            let status2_w = '1';
        else
            let status2_w = '3';
        end if;
    else
        let status2_w = '3';
        let mov = 'B';
        let vmonto_cong = pmonto;
        let v_transacc = '3353';
    end if;
    
    -- // Asigna un folio
    let hora_w  = current hour to fraction;
    let folio2  = hora_w[1,2] || hora_w[4,5] || hora_w[7,8] || hora_w[10,11];
    let v_folio = trim(pusuario)||folio2;
    
    let v_mesdia = month(fecha_w) || day(fecha_w);
    let hora_w = hora_w[4,5] || hora_w[7,8];
    
    if pcodbloq = '00' then
        let v_clave = pclave;
    else
        let v_clave = v_mesdia + hora_w;
    end if;
    
    -- // Inserta registro en historico de bloqueos
    insert into sc_histbloq 
    ( empresa, cuenta, tipo_mov, motivo, opcion, importe, usuario, fecha, hora, clave, 
      status_blo, folio_suc, referencia, cve_area, cod_area, cve_tipobloq, cod_tipobloq )
    values 
    ( pempresa, pcuenta, mov, pcodbloq, popbloq, pmonto, pusuario, fecha_w, current hour to fraction, v_clave, 
      mov, v_folio, "", pAreaSolic, pCodArea, pTipoBloq, pCodTipoBloq );
    
    -- // Inserta registro en tabla de movimientos diarios
    insert into sc_movdia values
    ( 0, v_folio, suc_w, pusuario, fecha_w, fecha_w, current hour to fraction, v_transacc, suc_w, prod_w, 
      pempresa, pcuenta, ' ', 0, pmonto, 0, 0, 0, 0, " ", status_w, sdod_w, '0000', ' ', 0, '', ' ', '', vfecha_operacion);
    
    -- // Inserta o elimina registro en tabla de bloqueos
    IF pcodbloq <> '00' THEN
        INSERT INTO sc_ctabloqueo
        (cuenta, clave, opcion, cve_area, cod_area, cve_tipobloq, cod_tipobloq)  
        VALUES 
        (pcuenta, pcodbloq, popbloq, pAreaSolic, pCodArea, pTipoBloq, pCodTipoBloq);
        
        INSERT INTO sc_ctabloqueohist
        (cuenta, clave, opcion)
        VALUES 
        (pcuenta, pcodbloq, popbloq);
     ELSE  
        DELETE FROM bdicheq:sc_ctabloqueo 
         WHERE cuenta = pcuenta;
    END IF
    
    -- // Actualiza la tabla maestra de cheques
    update sc_maechq
       set fec_cancelac = fecha_w,
           status_cta = status2_w,
           motivo = pcodbloq,
           sdo_cong = sdo_cong + vmonto_cong,
           fecha_proceso = fecha_w
     where cuenta = pcuenta;
     
    IF pcodbloq = '00' THEN   
        --RQM 09 704 . Luis Enrique Orozco Cosme. Fecha modificacion: 01/10/2025 
        --Conteo para validacion de transaccion permitida
        SELECT COUNT(*) 
        INTO iContTxPermRet 
        FROM sc_transaccs_no_permitidas_reten_cob_auto 
        WHERE transaccion = v_transacc AND estatus = '1';  

        --Validacion de transaccion
        IF(iContTxPermRet = 0) THEN
            --Se llama al SPL sp_retencion_cobranza_automatica para realizar la retencion.          
            EXECUTE PROCEDURE sp_retencion_cobranza_automatica(cNumcte,pcuenta,v_folio)INTO cCodRetSpReten,cMensajeRetSpReten;

            --Agregar validacion de codigo de retorno
            IF (cCodRetSpReten NOT IN ('00000','00002','00003')) THEN
                --Registro del tipo de error al ejecutar el SPL sp_retencion_cobranza_automatica.
                INSERT INTO sc_bit_error_cobranza_automatica VALUES(0, cProceso, cCodRetSpReten, cMensajeRetSpReten, cNumcte, pcuenta, fecha_w, current hour to fraction, v_folio);                         
            END IF;
        END IF;
    END IF;

    if pcodbloq = '00' then
        if pclave <>  '' and pclave <> ' ' then
            update sc_histbloq
               set status_blo = mov
             where empresa = pempresa 
               and cuenta = pcuenta
               and clave = pclave 
               and tipo_mov = 'B';
        else
            let vsdoxdesbloq = pmonto;
            
            foreach
                select rowid,importe,fecha
                  into vrowid, vimporte,vfecha
                  from sc_histbloq
                 where empresa = pempresa 
                   and cuenta = pcuenta 
                   and tipo_mov = 'B' 
                   and status_blo = 'B'
                 order by fecha
                 
                if vimporte > vsdoxdesbloq then
                    let vimporte = vimporte - vsdoxdesbloq;
                else
                    let vimporte = vimporte;
                end if
                
                update sc_histbloq
                   set status_blo = mov,
                       importe = vimporte
                 where rowid = vrowid;
                 
                let vsdoxdesbloq = vsdoxdesbloq - vimporte;
                
                if vsdoxdesbloq = 0 then
                    exit foreach;
                end if
            end foreach
        end if
    end if
    
    let cod_ret = '00000';
    
    END;
    
    return cod_ret, v_clave;
    
end procedure

DOCUMENT
'DESCRIPCION: Realiza el Bloqueo de cuentas si no estan bloqueadas',
'AUTOR: ValentÃ­n LÃ³pez',
'FECHA: Septiembre 2010',
'VERSION: 20100929.0101',
'MODIFICACION: Valida el importe de la cuenta solo en bloqueos por importe determinado',
'AUTOR: JICS',
'FECHA: 12 de julio de 2016',
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 09-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2',
'MODIFICADO:    Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   07-01-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.3',
'MODIFICO :     Luis Enrique Orozco Cosme',
'FECHA :        02-02-2025',
'MODIFICACION : Se agrega la inmovilizacion de saldos a la cuenta de captacion siempre y cuando cuente con una exigencia de un pago de credito',
'PROYECTO :     RQM 09 704 Cobranza Automatica en Cuentas de Captacion',
'BD :           bdicheq',
'VERSION :      1.4';

create procedure "informix".dias_ret(pempresa char(3), pdiaslib smallint)
RETURNING char(5);

    -- ******************************************************
    --                      dias_ret
    -- Version              1.0.0
    -- Obejtivo:            Liberacion documentos retenidos
    -- Creado por:
    -- ModIFicacion por:    Bancoppel
    -- Ultima ModIFicacion: 26 NOV 2009
    -- ******************************************************

    DEFINE vcuenta,vcta_cheques,vnum_cte                    char (20);
    DEFINE vreferencia,desc_err,vcodret3                    char(40);
    DEFINE vdias_ret                                        smallint;
    DEFINE sql_err,isam_err,vrowid                          integer;
    DEFINE vcodret,vcodret1,vcodret2                        char (5);
    DEFINE vplaza                                           char(3);
    DEFINE vsuccta,vsucursal                                char(4);
    DEFINE vusuario                                         char(8);
    DEFINE vfecha_alta,vfechoy                              date;
    DEFINE vfecha                                           date;
    DEFINE vcancelado                                       char(1);
    DEFINE vproducto,vtrandepsbc,vtranret,
           vtranlibsbc,vtranlibsbcTC,vtransuc,
           vtrancancta,vtrancanprov,vtrancapchq             char(4);
    DEFINE vsdo_actual,vmonto,vimpliberar,
           vimpmaxlib,vsdo_retenido,
           vcapital,vsdodisp,vmontoret,
           vtotcanc,vintprov                                money(14,2);
    DEFINE vfolsuc                                          char(16);
    DEFINE vdocto,vsolbcos                                  integer;
    DEFINE horax                                            datetime hour to fraction(3);
    DEFINE vcero                                            smallint;
    DEFINE vsecuencia,vdias_ori,vdifdias                    smallint;
    DEFINE vexiste, vabierto, vstatus                        char(1);
    DEFINE vmoneda,vsiglas,vsistema                         char(2);
    DEFINE vmensaje                                         char(80);
    DEFINE vnum_tarjeta                                     char(16);
    DEFINE vmaxsec                                          smallint;
    DEFINE vreferencia2                                     char(40);
    DEFINE vmonto1,vmonto2,vmonto3,
           vmonto4,vmonto5,vmonto6,
           vmonto7,vmonto8,vmonto9                          Money(14,2);
    DEFINE wSecuenciaPago                                   smallint;
    DEFINE vnum_credito                                     char(20);
    DEFINE vfechalta                                        date;
    DEFINE vcolateral                                       CHAR(1);
    DEFINE vstatus_cta                                      CHAR(1);
    DEFINE vmotivo                                          CHAR(2);
    DEFINE vtranlibctadev, vtranlibsbcA, vtranlibctadevA    CHAR(4);
    DEFINE vtranlibsbcTCA                                   CHAR(4);
    DEFINE vrowid1                                          int;
    DEFINE vrefnew                                          char(20);
    DEFINE vcvebconew                                       char(3);
    DEFINE vcomienza                                        INTEGER;
    DEFINE vexistechq                                       INTEGER;
    DEFINE vexistecta                                       CHAR(20);
    DEFINE vind_cierre, vind_dispon                         char(1);
	  DEFINE vfecha_operacion                                 date;
    --RQM 09 704 . Eric E. Armenta Perez. Fecha modificacion: 15/10/2025
	  --Variables de retorno para el sp maestro de retenciones.
    DEFINE cCodRetSpReten	      CHAR(5);
	  DEFINE cMensajeRetSpReten	  CHAR(150);
    DEFINE cNumCte              CHAR(20);
    DEFINE iContTxPermRet       INTEGER;
    DEFINE cProceso             CHAR(50);

    let pempresa = "001";
    let vabierto = "0";
    let vtransuc = "0000";
    let vdocto   = 0;
    let vcodret  = "000";
    let vcero    = 0;
    let vcuenta = "";
    let vcta_cheques = "";
    let vnum_cte = "";
    let vreferencia = "";
    let vdias_ret = 0;
    let vcodret1 = "";
    let vplaza  = "";
    let vsuccta = "";
    let vsucursal = "";
    let vusuario = "informix";
    let vfecha_alta = "";
    let vfechoy = "";
    let vfecha = "";
    let vcancelado = "";
    let vproducto = "";
    let vtrandepsbc = "";
    let vtranret = "";
    let vtranlibsbc = "";
    let vtranlibsbcTC = "";
    let vtranlibctadev = "";
    let vtransuc = "";
    let vtrancancta = "";
    let vtrancanprov = "";
    let vtrancapchq  = "";
    let vsdo_actual = 0;
    let vmonto = 0;
    let vimpliberar = 0;
    let vimpmaxlib = 0;
    let vsdo_retenido = 0;
    let vcapital = 0;
    let vsdodisp = 0;
    let vmontoret = 0;
    let vtotcanc = 0;
    let vintprov  = 0;
    let vfolsuc  = "";
    let vdocto = 0;
    let vsolbcos = 0;
    let horax  = "";
    let vsecuencia = 0;
    let vdias_ori = 0;
    let vdifdias = 0;
    let vexiste = "";
    let vabierto = "";
    let vstatus = "";
    let vmoneda = "";
    let vsiglas = "";
    let vsistema = "";
    let vmensaje = "";
    let vnum_tarjeta  = "";
    let vmaxsec = 0;
    let vreferencia2 = "";
    let wSecuenciaPago = 0;
    let vnum_credito = "";
    LET vcolateral   = "";
    LET vstatus_cta  = "";
    LET vmotivo      = "";
    let vtranlibsbcA = ""; 
    LET vtranlibctadevA = ""; 
    LET vtranlibsbcTCA= ""; 
    let vrowid = 0;
    let vrowid1 = 0;
    LET vrefnew = "";
    LET vcvebconew = "";
    LET vcomienza = -1;
    LET vexistechq = 0;
    LET vexistecta = '';
    let vind_cierre = '0';
    let vind_dispon = '0';
	  let vfecha_operacion = TODAY;

      --Variables de retorno para el sp maestro de retenciones EEAP.
	  LET cCodRetSpReten		  ='00000';
	  LET cMensajeRetSpReten	='';
    LET cNumCte             ='';
    LET iContTxPermRet	  	=0;
    LET cProceso            = 'dias_ret';


     --set debug file to "/informix/moha/dias_ret.out";
     --trace on;
    
    begin

    on exception set sql_err, isam_err, desc_err
        set debug file to "/tmp/dias_ret.err";
        trace on;
        if sql_err <> 0 then
            let vcodret = sql_err;
            let vcodret2 = isam_err;
            let vcodret3 = desc_err;
            if vabierto = "1" then
                rollback work;
            end if;
            return vcodret;
        end if;
    end exception;

    set isolation to dirty read;
    set lock mode to wait 5;

    select {+INDEX(sc_fechas idx_fechas1)} fecha_hoy, ind_cierre, ind_disponible
      into vfecha, vind_cierre, vind_dispon
      from sc_fechas
     where empresa = pempresa;
     
    if ( vind_cierre = '0' or vind_dispon = '0' ) then
        let vcodret = "004";
        return vcodret;
    end if;
    
    -- // Valida no se halla realizado liberacion
    select {+ INDEX(sc_contproc idx_contproc2)} rowid, "1"
      into vrowid1, vexiste
      from sc_contproc
     where empresa = pempresa 
       and proceso = "docret" 
       and fecha = vfecha; 
       
    if vexiste = "1" then
        let vcodret = "971";
        return vcodret;
    end if

    --select ejecutivo     -- MOHA - Se elimino el usuario informix del catÃ¡logo por lo que se inhibe esta consulta para que la variable no arroje un nulo y el movto se pueda mostrar en el SOC
      --into vusuario
      --from bdinteg:si_ejecut
     --where ejecutivo = user;

    select valor 
      into vtranlibsbc
      from sc_param
     where empresa = pempresa 
       and codparam = "tranlibsbc";

    let vtranlibsbcA = vtranlibsbc; 

    select valor 
      into vtranlibctadev
      from sc_param
     where empresa = pempresa 
       and codparam = "tranlibctadev";

    LET vtranlibctadevA = vtranlibctadev; 

    select valor 
      into vtranlibsbcTC
      from bdicred:sd_param
     where empresa = pempresa 
       and cod_param = "83";

    LET vtranlibsbcTCA = vtranlibsbcTC; 

    if weekday(vfecha) = 0 or weekday(vfecha) = 6 then
        update {+INDEX(sc_contproc idx_contproc2)} sc_contproc
           set fecha = vfecha
         where empresa = pempresa 
           and proceso = "docret"; 
           
        let vcodret = "000";
        return vcodret;
    end if

    select {+INDEX(bdinteg:si_feriado idx_feriado)} "1" 
      into vexiste
      from bdinteg:si_feriado
     where fecha = vfecha 
       and empresa = pempresa;
       
    if vexiste = "1" then
        update {+INDEX(sc_contproc idx_contproc2)} sc_contproc
           set fecha = vfecha
         where empresa = pempresa 
           and proceso = "docret";  
        
        let vcodret = "000";
        return vcodret;
    end if

    FOREACH WITH HOLD
        select {+INDEX(sc_docret_sbc idx_docret_sbc3)}
               cuenta,dias_ret,monto,folio_suc,cancelado,referencia,sucursal,num_chq,dias_ori,transacc,siglas, fecha_alta, banco, numcuenta
          into vcuenta,vdias_ret,vmonto,vfolsuc,vcancelado,vreferencia,vsucursal,vdocto,vdias_ori,vtrandepsbc,vsiglas, vfechalta, vcvebconew, vrefnew
          from sc_docret_sbc			--MOHA
         where siglas in ('SC', 'SD')
           and fecha_alta < vfecha
		   and fecha_alta >= vfecha - 1 units month
           and cancelado = "T" 
           and transacc in('0250', '6250')
         order by siglas, dias_ret
         
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            BEGIN WORK;
            LET vabierto = "1";
        END IF;

        LET vtranlibsbc    = vtranlibsbcA; 
        LET vtranlibctadev = vtranlibctadevA; 
        LET vtranlibsbcTC  = vtranlibsbcTCA; 
        
        --- LET vrefnew = vreferencia[6,25]; -- Se agrega para extraer los 20 digitos y no hacerlo en la consulta
        --- LET vrefnew = vrefnew;
        
        --- LET vrefnew = SUBSTR(vrefnew,10,11);
        --- LET vrefnew = vrefnew;
        
        --- LET vcvebconew = vreferencia[1,3]; -- Se agrega para extraer los 3 digitos de clave banco y no en la consulta
        --- LET vcvebconew = vcvebconew;

        -- // Valida si los Cheques a Liberar Fueron Presentados
		
        SELECT {+INDEX(bditef:cce_cheques_det cheques_det2)} 
               COUNT(*) 
          INTO vexistechq
          FROM bditef:cce_cheques_det
         WHERE empresa = pempresa
           AND cvebanco = vcvebconew
           AND numcuenta = vrefnew
           AND numcheque = vdocto
           AND fechapresenta <= vfecha
           AND fechapresenta >= vfecha - 1 units month
           AND monto = vmonto
           AND fecha_alta <= vfecha
           AND fecha_alta >= vfecha - 1 units month
           AND presentado = "1";

        IF vexistechq = 0 THEN
            continue foreach;
        END IF;

        let vdias_ret = vdias_ret - pdiaslib;
        let vdifdias = vdias_ori - vdias_ret;
        
        if vdias_ret < 1 then
            let vimpliberar = vmonto;
            let vstatus = "L";
        else
            let vimpliberar = 0;
        end if
        
        if vimpliberar > 0 then
        
            if vsiglas = "SC" then -- // Captacion

                select mc.sucursal, mc.producto, sdo_actual, mc.colateral, mc.status_cta, mc.motivo, mc.num_cte
                  into vsuccta, vproducto, vsdo_actual, vcolateral, vstatus_cta, vmotivo, cNumCte
                  from sc_maechq mc,
                       sc_producto pr
                 where mc.empresa = pempresa 
                   and mc.cuenta = vcuenta
                   and pr.empresa = mc.empresa 
                   and pr.producto = mc.producto;
                   
                -- // Para el caso de doctos devueltos en cuentas especiales, cambia la transaccion 
                IF vcolateral = "S" AND vstatus_cta = "3" AND vmotivo = "99" THEN                     
                    SELECT {+INDEX(bditef:cce_cheques_dev idx_chqdev)}
                           cta_deposito
                      INTO vexistecta
                      FROM bditef:cce_cheques_dev
                     WHERE numcheque = vdocto
                       AND numcuenta = vrefnew
                       AND monto = vmonto
                       AND fechapresenta >= vfechalta
                       --AND empresa = pempresa
                       AND cvebanco = vcvebconew;
                       
                    IF vexistecta is not null OR vexistecta <> '' THEN
                        LET vtranlibsbc = vtranlibctadev;
                    END IF
                END IF

                insert into sc_movdia values 
                ( 0, vfolsuc, vsucursal, vusuario, vfecha, vfecha, current hour to fraction(3), vtranlibsbc, vsuccta, vproducto, pempresa, 
                  vcuenta, " ", vdocto, vimpliberar, vimpliberar, vcero, vcero, vcero, " ", vstatus_cta, vsdo_actual, vtransuc, vreferencia, vcero, '', '', '', vfecha_operacion);
                        
                update sc_maechq
                   set imp_chq_sbc = imp_chq_sbc - vimpliberar,
                       sdo_actual = sdo_actual + vimpliberar
                 where empresa = pempresa 
                   and cuenta = vcuenta;

                call cobintcomsbg(pempresa, vcuenta, vfolsuc, vusuario, vsucursal)
                returning vcodret1;
                
                IF vcodret1 = "000" THEN
                    update sc_docret_sbc       --MOHA
                       set cancelado = vstatus,
                           dias_ret = dias_ret - pdiaslib,
                           monto = monto - vimpliberar
                     where cuenta = vcuenta
                       and num_chq = vdocto
                       and transacc = vtrandepsbc
                       and fecha_alta = vfechalta
                       and banco = vcvebconew
                       and numcuenta = vrefnew
                       and cancelado = "T";
                    --- where rowid = vrowid;
                --A.S.H.
                ELSE
                    update sc_docret_sbc       --MOHA
                       set cancelado = "A",
                           dias_ret = dias_ret - pdiaslib,
                           monto = monto - vimpliberar
                     where cuenta = vcuenta
                       and num_chq = vdocto
                       and transacc = vtrandepsbc
                       and fecha_alta = vfechalta
                       and banco = vcvebconew
                       and numcuenta = vrefnew
                       and cancelado = "T";
                    --- where rowid = vrowid;
                --A.S.H. 
              END IF

              --RQM 09 704 . Eric E. Armenta Perez. Fecha modificacion: 20/10/2025 
			        --Se realiza la validacion de las transacciones que no estan permitidas para realizar el llamado al SPL de retencion.
			        --Conteo para validacion de transaccion permitida.
			        SELECT COUNT(*) 
              INTO iContTxPermRet 
			        FROM sc_transaccs_no_permitidas_reten_cob_auto 
			        WHERE transaccion = vtranlibsbc AND estatus = '1';

             --Se valida que la transaccion realizada no exista en la tabla anterior para poder realizar el proceso de retencion. 
			         IF(iContTxPermRet = 0) THEN
               --Se llama al SPL sp_retencion_cobranza_automatica para realizar la retencion.			
			           EXECUTE PROCEDURE sp_retencion_cobranza_automatica(cNumCte,vcuenta,vfolsuc) INTO cCodRetSpReten,cMensajeRetSpReten;
                   --Validacion del codigo de retorno.
                 IF (cCodRetSpReten NOT IN ('00000','00002','00003')) THEN
                     --Registro del tipo de error al ejecutar el SPL sp_retencion_cobranza_automatica.
                    INSERT INTO sc_bit_error_cobranza_automatica VALUES(0, cProceso, cCodRetSpReten, cMensajeRetSpReten, cNumCte, vcuenta, vfecha_operacion, current hour to fraction(3), vfolsuc);
                 END IF;
             END IF;

            elif vsiglas = "SD" then -- // Credito

                -- // Ejecuta SPL Libera SBC Principalsbc
                -- // Requiere Datos del Banco y No de Cheque
                Select descripcion[1,19] 
                  Into vreferencia2
                  from bdinteg:si_bancos
                 Where banco = vreferencia[1,3];
                 
                If vreferencia2 Is NUll Then
                    Let vreferencia2 = "PAGO TDC S.B.C "||lpad(vdocto,7,'0');
                Else
                    Let vreferencia = vreferencia2;
                    Let vreferencia2 = vreferencia[1,15]||" "||lpad(vdocto,7,'0');
                End If
                
                -- // Valida la Sec de Pago para agregar al Folio la Secuencia
                SELECT num_credito 
                  INTO vnum_credito
                  FROM bdicred:sd_tarjeta
                 WHERE num_tarjeta = vcuenta;

                SELECT MAX(secuencia)
                  INTO wSecuenciaPago
                  FROM bdicred:sd_secpago
                 WHERE empresa = pEmpresa
                   AND num_credito = vnum_credito;
                   
                let vfolsuc = vfolsuc;
                
                IF (wSecuenciaPago = 0 OR wSecuenciaPago IS NULL) THEN
                    LET wSecuenciaPago = 1;
                ELSE
                    LET wSecuenciaPago = wSecuenciaPago + 1;
                END IF;

                LET vfolsuc = vfolsuc[1,14]||lpad(wSecuenciaPago::varchar(2),2,"0");
                
                call bdicred:principalrefer(pEmpresa, vcuenta, "01", vcuenta, vusuario, vsucursal, vfolsuc, vtranlibsbcTC, 0, vmonto, vreferencia2) 
                returning vcodret1, vmonto1, vmonto2, vmonto3, vmonto4, vmonto5, vmonto6, vmonto7, vmonto8, vmonto9;

                If vcodret1 = "000" Then
                    update sc_docret_sbc
                       set cancelado = vstatus,
                           dias_ret = dias_ret - pdiaslib,
                           monto = monto - vimpliberar
                     where cuenta = vcuenta
                       and num_chq = vdocto
                       and transacc = vtrandepsbc
                       and fecha_alta = vfechalta
                       and banco = vcvebconew
                       and numcuenta = vrefnew
                       and cancelado = "T";
                    --- where rowid = vrowid;
                End if

            else

                select {+INDEX(bdinvers:sv_instrum idx_instrum)}
                       mv.sucursal, mv.cod_instrum, capital, plaza, secuencia, sdo_retenido, sdo_mes_ant, num_cte, moneda, capital
                  into vsuccta, vproducto, vsdo_actual, vplaza, vsecuencia, vsdo_retenido, vintprov, vnum_cte, vmoneda, vcapital
                  from bdinvers:sv_maeinv mv,
                       bdinvers:sv_instrum pr
                 where mv.empresa = pempresa 
                   and mv.cuenta = vcuenta 
                   and pr.cod_instrum = mv.cod_instrum
                   and pr.empresa = mv.empresa
                   and status_cta <> "4";
                   
                insert into bdinvers:sv_movdia values 
                ( pempresa, 0, vfolsuc, vplaza, vsucursal, vusuario, vfecha, current hour to fraction(3), vtranlibsbc, vsuccta, 
                  vcuenta, vsecuencia, vproducto, vcero, vimpliberar, vimpliberar, vcero, vcero, " ", vsdo_actual, vtransuc );

                update bdinvers:sv_maeinv
                   set sdo_retenido = sdo_retenido - vimpliberar
                 where empresa = pempresa 
                   and cuenta = vcuenta 
                   and secuencia = vsecuencia;
                   
                if vsdo_retenido = vimpliberar then
                    select valor 
                      into vtrancancta
                      from bdinvers:sv_param
                     where codparam = "trancancta" 
                       and empresa = pempresa;
                       
                    select valor 
                      into vtrancanprov
                      from bdinvers:sv_param
                     where codparam = "trancanprov" 
                       and empresa = pempresa;
                       
                    select importe, cta_cheques, sistema
                      into vtotcanc, vcta_cheques, vsistema
                      from bdinvers:sv_maeinstrucc
                     where empresa = pempresa 
                       and cuenta = vcuenta 
                       and cap_int = "C" 
                       and aplicado = "N";
                       
                    if vtotcanc is null then
                        let vtotcanc = 0;
                    end if
                    
                    if vtotcanc > 0 then
                        let vreferencia = "CANCELACION DE CERTIFICADO " || vcuenta || " POR DEVOLUCION DE CHEQUE";
                                      
                        select valor 
                          into vtrancapchq
                          from bdinvers:sv_param
                         where codparam = "trancapchq" 
                           and empresa = pempresa;
                           
                        if vsistema = "01" then
                            call abono_ref(pempresa,vsucursal,vusuario,vtrancapchq,"0000",vfolsuc,vcta_cheques,0,vtotcanc,vtotcanc,0,0,0,vmoneda,vreferencia) 
                            returning vcodret;
                        end if
                        
                        if vcodret <> "000" or vsistema <> "01" then
                            call bdibanco:sbsp_graba_solchq(pempresa,vnum_cte,vusuario,vtotcanc,vcuenta) 
                            returning vcodret,vmensaje,vsolbcos;
                        end if
                        
                        insert into bdinvers:sv_movdia values 
                        ( pempresa, 0, vfolsuc, vplaza, vsucursal, vusuario, vfecha, current hour to fraction(3), vtrancancta, 
                          vsuccta, vcuenta, vsecuencia, vproducto, 0, vtotcanc, vtotcanc, 0, 0, " ", vcapital, "0000");
                    end if
                    
                    if vintprov > 0 then
                        insert into bdinvers:sv_movdia values 
                        ( pempresa, 0, vfolsuc, vplaza, vsucursal, vusuario, vfecha, current hour to fraction(3), vtrancanprov,
                          vsuccta, vcuenta, vsecuencia, vproducto, 0, vintprov, vintprov, 0, 0, " ", vcapital, "0000" );
                    end if
                    
                    -- // Actualiza el Maestro de Inversiones
                    update bdinvers:sv_maeinv
                       set status_cta   = "2",
                           fec_cancelac = vfecha,
                           modificado   = vusuario,
                           fecha_mod    = vfecha
                     where empresa = pempresa 
                       and cuenta = vcuenta 
                       and secuencia = vsecuencia;
                       
                    update sc_docret_sbc
                       set cancelado = vstatus,
                           dias_ret = dias_ret - pdiaslib,
                           monto = monto - vimpliberar
                     where cuenta = vcuenta
                       and num_chq = vdocto
                       and transacc = vtrandepsbc
                       and fecha_alta = vfechalta
                       and banco = vcvebconew
                       and numcuenta = vrefnew
                       and cancelado = "T";
                    --- where rowid = vrowid;
                end if
            end if

        else
            
            UPDATE sc_docret_sbc
               SET dias_ret = dias_ret - pdiaslib
             where cuenta = vcuenta
               and num_chq = vdocto
               and transacc = vtrandepsbc
               and fecha_alta = vfechalta
               and banco = vcvebconew
               and numcuenta = vrefnew
               and cancelado = "T";
            --- WHERE rowid = vrowid;
            
        end if
        
        IF vabierto = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
    end foreach
    
    update {+INDEX(sc_contproc idx_contproc2)} sc_contproc
       set fecha = vfecha
     where empresa = pempresa 
       and proceso = "docret"; 

    IF vabierto = 1 THEN
        COMMIT WORK;
    END IF;
       
    return vcodret;

    end;

end procedure

DOCUMENT 
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 20-10-2025',
'MODIFICACION : Se agrega la tabla sc_transaccs_no_permitidas_reten_cob_auto que realiza la validacion',
'               de transacciones no permitidas para llevar a cabo el proceso de retencion o inmovilizacion de saldo',
'               dependiendo de la transaccion realizada.',
'               Se agrega el SPL sp_retencion_cobranza_automatica que realiza todo el proceso',
'               de retencion de saldo.',
'               Se agrega la tabla sc_bit_error_cobranza_automatica quien se encarga de registar errores que llegaran a',
'               presentarse en la ejecucion del SPL sp_retencion_cobranza_automatica.',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2';

CREATE PROCEDURE "informix".sp_liberaretinterpza( pEmpresa CHAR(3) ) 
RETURNING CHAR(5); 
    
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vContador1       INTEGER;
    DEFINE vContador2       INTEGER;
    DEFINE vAbierto         CHAR(1);
    DEFINE vFechaAnt        DATE;
    DEFINE vFechaHoy        DATE;
    DEFINE vPriHabMes       DATE;
    DEFINE vPriDiaMes       DATE;
    DEFINE vPriDiaMesAnt    DATE;
    DEFINE vDiasRet         SMALLINT;
    DEFINE cTipoValida 	    CHAR(2);
    DEFINE iDiasRetGen      INTEGER;
    DEFINE iDiasRetSuc      INTEGER;    
    DEFINE vCuenta          CHAR(20);
    DEFINE vMontoRet        MONEY(14,2);
    DEFINE vFechaTrx        DATE;
    DEFINE vSdoRetenido     MONEY(14,2);
    DEFINE vSucursal        CHAR(4);
    DEFINE vImpSbg          MONEY(14,2);
    DEFINE cSucursalDep     CHAR(4);
    DEFINE cTrasaccDep      CHAR(4);
    DEFINE cFolioDep        CHAR(16);
    DEFINE cProcesa         CHAR(2);	
    DEFINE vCobraCom        SMALLINT;
    DEFINE vComPend         SMALLINT;
    DEFINE vHora            CHAR(15);
    DEFINE vFolioSuc        CHAR(16);
    DEFINE vCodRet4         CHAR(5);
    DEFINE vFechaIni        DATE;
    DEFINE vFechaFin        DATE;
    DEFINE vFecha1          CHAR(8);
    DEFINE vFecha2          CHAR(8);
    DEFINE vstmt            CHAR(600);
    DEFINE vsql             CHAR(200);
	--Variables de retorno para el sp maestro de retenciones DFTL.
    DEFINE cCodRetSpReten		CHAR(5);
	DEFINE cMensajeRetSpReten	CHAR(150);
    DEFINE cNumCte              CHAR(20);
   	--RQM 09 704 . Donovan Torres. Fecha modificacion: 28/10/2025
	--Variables de retorno para el sp de transacciones.
    DEFINE cProceso             CHAR(50);
    DEFINE iContTxPermRet       INTEGER;
    DEFINE ptransacc            CHAR(4);

	
    LET Sql_Err	      = 0;
    LET Isam_Err      = 0;
    LET Desc_Err      = '';
    LET vCodRet1      = '';
    LET vCodRet2      = '';
    LET vCodRet3      = '';  
    LET vContador1    = 0;
    LET vContador2    = 0;
    LET vAbierto      = '0';
    LET vFechaAnt     = '';
    LET vFechaHoy     = '';
    LET vPriHabMes    = '';
    LET vPriDiaMes    = '';
    LET vPriDiaMesAnt = '';
    LET vDiasRet      = 0;
    LET cTipoValida   = ''; 
    LET iDiasRetGen   = 0;
    LET iDiasRetSuc   = 0;
    LET vCuenta       = '';
    LET vMontoRet     = 0.00;
    LET vFechaTrx     = '';
    LET vSdoRetenido  = 0.00;
    LET vSucursal     = '';
    LET vImpSbg       = 0.00;
    LET cSucursalDep  = '';
    LET cTrasaccDep   = '';
    LET cFolioDep     = '';
    LET cProcesa 	  = '';
    LET vComPend      = 0;
    LET vCobraCom     = 0;
    LET vHora         = '';
    LET vFolioSuc     = '';   
    LET vCodRet4      = '';
    LET vFechaIni     = '';
    LET vFechaFin     = '';
    LET vFecha1       = '';
    LET vFecha2       = '';
    LET vstmt         = '';
    LET vsql          = '';
	--Variables de retorno para el sp maestro de retenciones DFTL.
	LET cCodRetSpReten		='00000';
	LET cMensajeRetSpReten	='';
    LET cNumCte       = '';
   	--RQM 09 704 . Donovan Torres. Fecha modificacion: 28/10/2025
	--Variables de retorno para el sp de transacciones.
    LET cProceso            ='sp_liberaretinterpza';
    LET iContTxPermRet      = 0;
    LET ptransacc           = '0325';
	
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_liberaretinterpza.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vAbierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_liberaretinterpza.out";
    --- TRACE ON;
    
    -- SET ISOLATION TO COMMITTED READ LAST COMMITTED;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;

    -- // OBTIENE FECHAS DEL SISTEMA DE CHEQUES 
    SELECT fecha_ant, fecha_hoy, pri_hab_mes, pri_dia_mes
      INTO vFechaAnt, vFechaHoy, vPriHabMes, vPriDiaMes
      FROM sc_fechas
     WHERE empresa = pEmpresa;
     
    LET vPriDiaMesAnt = vPriDiaMes - 1 UNITS MONTH;
     
    -- // OBTIENE PARAMETROS DE DIAS DE RETENCION 
    SELECT valor::INT
      INTO vDiasRet
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasRetInterEdo';

	-- // SE OBTIENE EL PARAMETRO DE LAS SUCURSALES 
	SELECT valor 
	  INTO cTipoValida     
	  FROM sc_param
	 WHERE empresa  = pempresa
	   AND codparam ='LimDepositoInterEsta';
    
    -- // OBTIENE DIAS PARA TIPO GENERAL 
    SELECT plazo
      INTO iDiasRetGen
      FROM sc_limitedeposito 
     WHERE sucursal = '9999';
      
    IF iDiasRetGen IS NULL OR iDiasRetGen = '' THEN  
        LET iDiasRetGen = vDiasRet;
    END IF;
    
    -- // REALIZA LIBERACION DE MONTOS RETENIDOS 
    FOREACH WITH HOLD
        SELECT dep.cuenta, dep.monto_ret, dep.fecha, mae.sdo_retenido, mae.sucursal, mae.imp_chq_sbg + mae.imp_sbg_ccc, 
               dep.sucursal, dep.transacc, dep.folio_suc, mae.num_cte
          INTO vCuenta, vMontoRet, vFechaTrx, vSdoRetenido, vSucursal, vImpSbg, 
               cSucursalDep, cTrasaccDep, cFolioDep, cNumCte
          FROM sc_depinterpza dep,
               sc_maechq mae
         WHERE dep.monto_ret > 0
           AND dep.liberado = '0'
           AND mae.cuenta = dep.cuenta
           
        BEGIN WORK;
        LET vAbierto = '1';
			 
		-- // OBTIENE LOS DIAS POR SUCURSAL
		IF cTipoValida = 'S' THEN
            SELECT plazo
			  INTO iDiasRetSuc
			  FROM sc_limitedeposito 
			 WHERE sucursal = cSucursalDep;  
			   
			IF iDiasRetSuc IS NULL OR iDiasRetSuc = '' THEN 
                LET iDiasRetSuc = iDiasRetGen; 
			END IF;
            
			IF ( vFechaHoy - vFechaTrx ) >= iDiasRetSuc THEN 
			    LET cProcesa = 'S';
			ELSE 
			    LET cProcesa = 'N';
			END IF;
        -- // TODAS LAS SUCURSALES
		ELSE  
            IF ( vFechaHoy - vFechaTrx ) >= iDiasRetGen THEN 
                  LET cProcesa = 'S';
            ELSE 
                  LET cProcesa = 'N';
            END IF; 	 
        END IF; 				
        
		-- // BANDERA PARA PROCESAR
        IF cProcesa = 'S'THEN	
            IF vSdoRetenido >= vMontoRet THEN
                UPDATE sc_maechq
                   SET sdo_retenido = sdo_retenido - vMontoRet
                WHERE cuenta = vCuenta;
                    
                UPDATE sc_depinterpza
                   SET liberado = '1'
                WHERE fecha = vFechaTrx
                   AND cuenta = vCuenta
                   AND monto_ret = vMontoRet
                   AND sucursal = cSucursalDep
                   AND transacc = cTrasaccDep
                   AND folio_suc = cFolioDep;
                   
                LET vcontador2 = vcontador2 + 1;
                   
                IF vImpSbg > 0 THEN
                    LET vCobraCom = 1;
                END IF;
                   
                IF vCobraCom = 0 THEN
                    SELECT COUNT(*)
                      INTO vComPend
                      FROM sc_detcomis
                     WHERE empresa = pEmpresa 
                       AND cuenta = vCuenta 
                       AND estado_com = "P";
                             
                    IF vComPend > 0 THEN
                        LET vCobraCom = 1;
                    END IF;
                END IF;
                   
                IF vCobraCom = 1 THEN
                    LET vHora = CURRENT HOUR TO FRACTION;
                    LET vFolioSuc = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
                    
                    CALL cobintcomsbg(pEmpresa, vCuenta, vFolioSuc, 'informix', vSucursal)
                    RETURNING vCodRet4;
                END IF;
            END IF;     
        END IF;
        
        LET vcontador1 = vcontador1 + 1;

        COMMIT WORK;
		
        --RQM 09 704 . Donovan Fernando Torres Landeros. Fecha modificacion: 14/10/2025
			--Conteo para validacion de transaccion permitida
			SELECT COUNT(*) 
            INTO iContTxPermRet 
			FROM sc_transaccs_no_permitidas_reten_cob_auto 
			WHERE transaccion = ptransacc AND estatus = '1';
        --Se llama al SPL sp_retencion_cobranza_automatica para realizar la retencion DFTL		
        IF(iContTxPermRet = 0) THEN	
            EXECUTE PROCEDURE sp_retencion_cobranza_automatica(cNumCte,vCuenta,vFolioSuc) INTO cCodRetSpReten,cMensajeRetSpReten;
		--Validacion del codigo de retorno.
            IF (cCodRetSpReten NOT IN ('00000','00002','00003')) THEN
                --Registro del tipo de error al ejecutar el SPL sp_retencion_cobranza_automatica.
                INSERT INTO sc_bit_error_cobranza_automatica VALUES(0, cProceso, cCodRetSpReten, cMensajeRetSpReten, cNumCte, vCuenta, vFechaHoy, vHora, vFolioSuc);
            END IF;
        END IF;
            
        LET vAbierto = '0';
           
        LET vCuenta       = '';
        LET vMontoRet     = 0;
        LET vFechaTrx     = '';
        LET vSdoRetenido  = 0;
        LET vSucursal     = '';
        LET vImpSbg       = 0.00;
        LET cSucursalDep  = '';
        LET cTrasaccDep   = '';
        LET cFolioDep     = '';
        LET iDiasRetSuc   = 0;
        LET cProcesa      = '';
        LET vCobraCom     = 0;
        LET vComPend      = 0;
        LET vHora         = '';
        LET vFolioSuc     = '';
        LET vCodRet4      = '';
    END FOREACH;
     
    IF vFechaHoy = vPriHabMes THEN
        FOREACH WITH HOLD
            SELECT UNIQUE cuenta
              INTO vCuenta
              FROM sc_depinterpza
             WHERE fecha < vPriDiaMesAnt 
                 
            BEGIN WORK;
            LET vAbierto = '1';
                 
            INSERT INTO sc_depinterpzahist
            SELECT *
              FROM sc_depinterpza
             WHERE cuenta = vCuenta
               AND fecha < vPriDiaMesAnt;
                 
            DELETE FROM sc_depinterpza
             WHERE cuenta = vCuenta
               AND fecha < vPriDiaMesAnt;
                 
            COMMIT WORK;
            LET vAbierto = '0';
            
            LET vCuenta = '';
        END FOREACH;
    END IF;    
    
    IF WEEKDAY (vFechaHoy) = 2 THEN
        LET vFechaIni = vFechaAnt - 7 UNITS DAY;
        LET vFechaFin = vFechaAnt - 1 UNITS DAY;
        
        LET vFecha1 = TO_CHAR(vFechaIni, '%d%m%Y');
        LET vFecha2 = TO_CHAR(vFechaFin, '%d%m%Y');
    
        LET vstmt = '';
        LET vstmt = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/MovsInterEstado_'||vFecha1||'_'||vFecha2||'.txt '||
                   'SELECT mae.num_cte, mov.cuenta, mov.monto_tot, mov.sucursal, mov.usuario, '||
                   'mov.fech_alt, mov.fech_hor, mae.sucursal, mov.sdo_cuenta + mov.monto_tot '||
                   'FROM bdicheq:sc_movhis mov, bdicheq:sc_maechq mae '||
                   'WHERE mov.fech_alt BETWEEN '''||vFechaIni||''' AND '''||vFechaFin||''' '||
                   'AND mov.transacc = ''0325'' '||
                   'AND mov.cancelad <> ''S'' '||
                   'AND mae.empresa = mov.empresa '||
                   'AND mae.cuenta = mov.cuenta; " > /resplogifx/conciliachq/movsinterpza.sql';
        SYSTEM vstmt;
        LET vstmt = '';
        
        LET vsql = '';
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/movsinterpza.sql"; 
        SYSTEM vsql;
        LET vsql = '';
	END IF; 
    
    LET vCodRet1 = '000';
    LET vCodRet2 = '000';
    LET vCodRet3 = 'PROCESO FINALIZADO';  
	    
    END; 
    
    RETURN vCodRet1;
    
END PROCEDURE
DOCUMENT
'MODIFICO :     Donovan Fernando Torres Landeros',
'FECHA :        23-07-2025',
'MODIFICACION:  Se agrega el sp sp_retencion_cobranza_automatica para la inmovilizacion del saldo',
'               y la tabla sc_bit_error_cobranza_automatica para validar y registrar errores en el mismo sp de inmovilizacion',
'PROYECTO :     RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    :        bdicheq',
'VER   :        1.1';

CREATE PROCEDURE "informix".sp_liberaretspei( pEmpresa CHAR(3) ) 
RETURNING CHAR(5); 
    
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vContador1       INTEGER;
    DEFINE vContador2       INTEGER;
    DEFINE vAbierto         CHAR(1);
    DEFINE vFechaAnt        DATE;
    DEFINE vFechaHoy        DATE;
    DEFINE vDiasRet         SMALLINT;   
    DEFINE vCuenta          CHAR(20);
    DEFINE vMontoRet        MONEY(14,2);
    DEFINE vFechaTrx        DATE;
    DEFINE vSdoRetenido     MONEY(14,2);
    DEFINE vSucursal        CHAR(4);
    DEFINE vImpSbg          MONEY(14,2);
    DEFINE cFolioDep        CHAR(16);
    DEFINE cReferencia      CHAR(40);
    DEFINE vCobraCom        SMALLINT;
    DEFINE vComPend         SMALLINT;
    DEFINE vHora            CHAR(15);
    DEFINE vFolioSuc        CHAR(16);
    DEFINE vCodRet4         CHAR(5);
    DEFINE vCodRet5         CHAR(5);
    DEFINE vSigDiaHabil     DATE;
    --RQM 09 704 . Osiel Alfredo Camacho Mendoza. Fecha modificacion: 14/10/2025
	--Variables de retorno para el sp maestro de retenciones.
	DEFINE cCodRetSpReten	CHAR(5);
	DEFINE cMensajeRetSpReten	CHAR(150);
    DEFINE cNumCte          CHAR(16);
    DEFINE cProceso             CHAR(50);
    DEFINE vfecha_operacion     DATE;
    DEFINE iContTxPermRet       INTEGER;
    DEFINE cTransacc        CHAR(50);
	
    LET Sql_Err	      = 0;
    LET Isam_Err      = 0;
    LET Desc_Err      = '';
    LET vCodRet1      = '';
    LET vCodRet2      = '';
    LET vCodRet3      = '';  
    LET vContador1    = 0;
    LET vContador2    = 0;
    LET vAbierto      = '0';
    LET vFechaAnt     = '';
    LET vFechaHoy     = '';
    LET vDiasRet      = 0;
    LET vCuenta       = '';
    LET vMontoRet     = 0.00;
    LET vFechaTrx     = '';
    LET vSdoRetenido  = 0.00;
    LET vSucursal     = '';
    LET vImpSbg       = 0.00;
    LET cFolioDep     = '';
    LET cReferencia   = '';
    LET vComPend      = 0;
    LET vCobraCom     = 0;
    LET vHora         = '';
    LET vFolioSuc     = '';   
    LET vCodRet4      = '';
    LET vCodRet5      = '';
    LET vSigDiaHabil  = '';
    --Variables de retorno para el sp maestro de retenciones OACM.
	LET cCodRetSpReten		='00000';
	LET cMensajeRetSpReten	='';
    LET cNumCte       = '';
    LET cProceso      = 'sp_liberaretspei';
    LET iContTxPermRet		=0;
    LET cTransacc  = '0273';
    
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_liberaretspei.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vAbierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_liberaretspei.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
    -- // OBTIENE FECHAS DEL SISTEMA DE CHEQUES 
    SELECT fecha_ant, fecha_hoy
      INTO vFechaAnt, vFechaHoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
     
    -- // REALIZA LIBERACION DE MONTOS RETENIDOS POR TRANSACCIONES SPEI
    FOREACH WITH HOLD
        SELECT dep.cuenta, dep.monto_ret, dep.fecha_hoy, dep.folio_suc, dep.referencia,
               mae.sdo_retenido, mae.sucursal, (mae.imp_chq_sbg + mae.imp_sbg_ccc),mae.num_cte
          INTO vCuenta, vMontoRet, vFechaTrx, cFolioDep, cReferencia, 
               vSdoRetenido, vSucursal, vImpSbg, cNumCte
          FROM sc_depositospei dep,
               sc_maechq mae
         WHERE dep.fecha_hoy < vFechaHoy
           AND dep.cuenta = mae.cuenta
           AND dep.monto_ret > 0
           AND dep.liberado = '0' 
        
        BEGIN WORK;
        LET vAbierto = '1';
        
        -- // VALIDA EL DIA DE LIBERACION
        CALL bdispei:sp_validafecha(pEmpresa, vFechaTrx)
        RETURNING vCodRet5, vSigDiaHabil;
        
        IF vFechaHoy >= vSigDiaHabil THEN
            IF vSdoRetenido >= vMontoRet THEN
                UPDATE sc_maechq
                   SET sdo_retenido = sdo_retenido - vMontoRet
                 WHERE cuenta = vCuenta;
                    
                UPDATE sc_depositospei
                   SET liberado = '1'
                 WHERE fecha_hoy = vFechaTrx
                   AND cuenta = vCuenta
                   AND monto_ret = vMontoRet
                   AND liberado = '0'
                   AND folio_suc = cFolioDep
                   AND referencia = cReferencia;
                   
                LET vcontador2 = vcontador2 + 1;
                   
                IF vImpSbg > 0 THEN
                    LET vCobraCom = 1;
                END IF;
                   
                IF vCobraCom = 0 THEN
                    SELECT COUNT(*)
                      INTO vComPend
                      FROM sc_detcomis
                     WHERE empresa = pEmpresa 
                       AND cuenta = vCuenta 
                       AND estado_com = "P";
                             
                    IF vComPend > 0 THEN
                        LET vCobraCom = 1;
                    END IF;
                END IF;
                   
                IF vCobraCom = 1 THEN
                    LET vHora = CURRENT HOUR TO FRACTION;
                    LET vFolioSuc = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
                    
                    CALL cobintcomsbg(pEmpresa, vCuenta, vFolioSuc, 'informix', vSucursal)
                    RETURNING vCodRet4;
                END IF;
            END IF; 
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
       
        COMMIT WORK;
        
        --RQM 09 704 . Osiel Alfredo Camacho Mendoza. Fecha modificacion: 29/10/2025 
		--Se realiza la validacion sobre las transacciones de pago de nomina para el llamado al sp de retenciones
		--Conteo para validacion de transaccion permitida
		SELECT COUNT(*) 
        INTO iContTxPermRet 
		FROM sc_transaccs_no_permitidas_reten_cob_auto 
		WHERE transaccion = cTransacc AND estatus = '1';

        IF(iContTxPermRet = 0) THEN
	        EXECUTE PROCEDURE sp_retencion_cobranza_automatica(cNumCte,vCuenta,vFolioSuc)INTO cCodRetSpReten,cMensajeRetSpReten;
         --Validacion del codigo de retorno.
		    IF (cCodRetSpReten NOT IN ('00000','00002','00003')) THEN
			    --Registro del tipo de error al ejecutar el SPL sp_retencion_cobranza_automatica.
                INSERT INTO sc_bit_error_cobranza_automatica VALUES(0, cProceso, cCodRetSpReten, cMensajeRetSpReten, cNumCte, vCuenta, vFechaHoy, vHora, vFolioSuc);
            END IF;
        END IF;
		LET vAbierto = '0';
        
        LET vCuenta       = '';
        LET vMontoRet     = 0;
        LET vFechaTrx     = '';
        LET vSdoRetenido  = 0;
        LET vSucursal     = '';
        LET vImpSbg       = 0.00;
        LET cFolioDep     = '';
        LET vCobraCom     = 0;
        LET vComPend      = 0;
        LET vHora         = '';
        LET vFolioSuc     = '';
        LET vCodRet4      = '';
    END FOREACH;
    
    /* ###########################################
    FOREACH WITH HOLD
        SELECT UNIQUE cuenta
          INTO vCuenta
          FROM sc_depositospei
         WHERE fecha_hoy < vFechaHoy 
           AND liberado = '1'
             
        BEGIN WORK;
        LET vAbierto = '1';
             
        INSERT INTO sc_depositospeihist
        SELECT *
          FROM sc_depositospei
         WHERE cuenta = vCuenta
           AND fecha_hoy < vFechaHoy
           AND liberado = '1';
             
        DELETE FROM sc_depositospei
         WHERE cuenta = vCuenta
           AND fecha_hoy < vFechaHoy
           AND liberado = '1';
             
        COMMIT WORK;
        LET vAbierto = '0';
        
        LET vCuenta = '';
    END FOREACH;
    ########################################### */
    
    LET vCodRet1 = '000';
    LET vCodRet2 = '000';
    LET vCodRet3 = 'PROCESO FINALIZADO';  
	    
    END; 
    
    RETURN vCodRet1;
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se agrega el sp de retencion de cobranza automatica, el cual retiene el saldo del cliente si se encuentra en la tabla de control ',
'Modificador : Osiel Alfredo Camacho Mendoza',
'FECHA : 28/10/2025',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_retiro_sd( pCuenta_eje CHAR(20),pCuenta_sd CHAR(20),pTipoMov CHAR(1), pCanal CHAR(1),pFecOper DATE,pHorOper CHAR(10),pMonRet MONEY(14,2))
						
									
	RETURNING CHAR (5), CHAR(20), CHAR(20), DATE, CHAR(8), MONEY(14,2), CHAR(10), CHAR(18), CHAR(2), CHAR(2),
				MONEY(14,2), DATE, MONEY(14,2), MONEY(14,2), INTEGER, DATE, DATE, INTEGER,  CHAR(2), CHAR(2), CHAR(10);
				  

    DEFINE vsqlerr, vEstCtaEje,vValUptMaeSd,vValUptMaeChq,vEst_sd,vValInse
		,vTransaccion,vPeriodicidad INTEGER;
	
	DEFINE vMonto_meta,vMontAboAuto,vMontoAcum,vSaldRetEj MONEY(14,2);
    
	DEFINE vFecOper,vFecha_meta,vFechUltAbo,vProxAboAut DATE;

	DEFINE iIsamErr, vProducto  SMALLINT;
	DEFINE bInicia  BOOLEAN;

    DEFINE cErrorInfo      	 CHAR(80);
	DEFINE vErrorInfo     	 CHAR(80);
    DEFINE vCodRet         	 CHAR(5);
	DEFINE vCuenta_eje	  	 CHAR(20);
	DEFINE vCuenta_sd	     CHAR(20);
	DEFINE vHorOper		     CHAR(8);
	DEFINE vCanal		     CHAR(2);
	DEFINE vSucursal         CHAR(4); 
	DEFINE vHora             CHAR(25);
	DEFINE vFolio            CHAR(16);
	DEFINE vUsuario          CHAR(8);
	DEFINE vProd             CHAR(4);
	DEFINE VusuMovRet        CHAR(10);
	DEFINE vIdPlantillaPush	 CHAR(12);
	DEFINE vNumCte           CHAR(20);
	DEFINE vSp_CodRet        CHAR(5);
	DEFINE vNombre_sd        CHAR(18);
	DEFINE vIcono	         CHAR(2);
	DEFINE vColor		     CHAR(2);
	DEFINE vTipoApartado     CHAR(2);
	DEFINE vDiaAboIni        CHAR(10);
	--RQM 09 704 - Luis Enrique Orozco Cosme - Fecha modificacion: 14/10/2025
    --Variables de retorno para el sp maestro de retenciones.
    DEFINE cCodRetSpReten       CHAR(5);
    DEFINE cMensajeRetSpReten   CHAR(150);
    DEFINE cProceso             CHAR(50);

	LET vsqlerr            = 0; 
    LET iIsamErr           = 0;
    LET cErrorInfo         = "";   
    LET vErrorInfo         = "INICIO DEL PROCESO";
    LET vCodRet            = "00000";
	LET vCuenta_eje        = TRIM(NVL(pCuenta_eje,''));
	LET vCuenta_sd         = TRIM(pCuenta_sd);
	LET vFecOper           = pFecOper;
	LET vHorOper           = TRIM(pHorOper);
	LET vCanal             = TRIM(pCanal);
	LET vEstCtaEje         = 0;
	LET vSucursal          = " ";
	LET vUsuario           = 'informix';
	LET vHora              = '';
	LET vFolio         	   = " ";
	LET vValUptMaeSd       = 0; 
	LET vValUptMaeChq      = 0;
	LET vProd              = "";
	LET vProducto		   = 0;
	LET vNombre_sd         = " ";
	LET vIcono	           = " ";
	LET vColor		       = " ";
	LET vMonto_meta        = 0;
	LET vFecha_meta        = " ";
	LET vMontAboAuto       = 0.00;
	LET vPeriodicidad      = 0;
	LET vFechUltAbo        = " ";
	LET vProxAboAut        = " ";
	LET vEst_sd            = 0;
	LET vMontoAcum         = 0;
	LET vSaldRetEj         = 0;
	LET vValInse           = 0;
	LET bInicia            = "F"; 
	LET VusuMovRet         = "";
	LET vIdPlantillaPush   = "SD_FINAP";
	LET vNumCte            = "";
	LET vSp_CodRet         = '00000';
	LET vTransaccion       = 0;
	LET vTipoApartado = "";
    LET vDiaAboIni      = '';
    --RQM 09 704 - Luis Enrique Orozco Cosme - Fecha modificacion: 14/10/2025
    --Variables de retorno para el sp maestro de retenciones.
    LET cCodRetSpReten      ='00000';
    LET cMensajeRetSpReten  ='';
    LET cProceso            = 'sp_retiro_sd';
         
    BEGIN
		ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
			IF  vsqlerr != 0 THEN
				--SET DEBUG FILE TO "/resplogifx/conciliachq/sp_retiro_sd.txt";
				--TRACE ON;
				LET vCodRet    = vsqlerr;
				LET vErrorInfo = cErrorInfo;
				LET vCuenta_eje= pCuenta_eje;
				IF bInicia = "T" THEN
				   IF vtransaccion = 1  THEN 
					  ROLLBACK WORK;
					  BEGIN WORK;
				   ELSE 
					   ROLLBACK WORK;
				   END IF;    
				END IF;
				RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,
				vFecha_meta,vMontoAcum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
			END IF;
		END EXCEPTION;
		
		ON  EXCEPTION IN (-535)
			LET vTransaccion = 1;
		END EXCEPTION WITH resume;
	
	
		--SET DEBUG FILE TO '/informix/c90186322/trace/sp_retiro_sd.txt';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;  
		
		--ESTATUS CUENTA EJE
		SELECT TRIM(NVL(status_cta,'0')), sucursal,  TRIM(NVL(producto,'')),   num_cte  
		INTO   vEstCtaEje, vSucursal, vProducto,  vNumCte
		FROM   "informix".sc_maechq 
		WHERE  cuenta = vCuenta_eje
		AND    status_cta = '1';
			
		--ESTATUS DE LA CUENTA EJE
		IF  vEstCtaEje <> '1' OR vEstCtaEje IS NULL THEN 	
			LET  vCodRet='00002';
			RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,vFecha_meta,
			vMontoAcum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
		END IF;

		-- Valida si es un producto valido para el apartados
		IF NOT EXISTS (SELECT 1 FROM "informix".sc_prodis_sd WHERE producto = vProducto) THEN
			LET vCodRet = '00003';
			RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,
				vFecha_meta,vMontoAcum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
		END IF;
		
		 -- VALIDA EL SOBRE DIGITAL Y EL ESTATUS 
		IF NOT EXISTS (SELECT 1 FROM "informix".sc_mae_sd WHERE cuenta_eje = vCuenta_eje AND cuenta_sd = vCuenta_sd AND estatus IN (1,3)) THEN
			LET  vCodRet='00010';
			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,
				vFecha_meta,vMontoAcum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
		END IF;
	
		--TIPO MOVIMIENTO
				
		--VALIDA EL TIPO DE MOVIMIENTO (RETIRO)
		IF pTipoMov <> '2' OR NOT EXISTS (SELECT id FROM "informix".sc_tmov_sd WHERE  id = pTipoMov )  THEN 
			LET  vCodRet='00013';
			RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,
				vFecha_meta,vMontoAcum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
		END IF;
	
		 --VALIDA EL TIPO DE CANAL
		IF vCanal <> '1' OR NOT EXISTS (SELECT id FROM "informix".sc_can_sd WHERE  id = vCanal)  THEN
			LET  vCodRet='00014';
			RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,
				vFecha_meta,vMontoAcum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
		END IF;	
	
		 -- SALDO DISPONIBLE PARA EL SOBRE DIGITAL 
		SELECT NVL(monto_acum,0),TRIM(nombre_sd),TRIM(icono),TRIM(color), monto_meta, fecha_meta,monto_ahor_auto, periodicidad,
			ult_fech_abo_auto, prox_fech_abo_auto,estatus, tipo_apartado,dia_del_cobro
		INTO   vMontoAcum,vNombre_sd,vIcono, vColor, vMonto_meta,vFecha_meta, vMontAboAuto,vPeriodicidad, 
			vFechUltAbo, vProxAboAut, vEst_sd,vTipoApartado,vDiaAboIni
		FROM   "informix".sc_mae_sd
		WHERE  cuenta_eje = vCuenta_eje
		AND    cuenta_sd  = vCuenta_sd
		AND    estatus IN (1,3);	
		
		--SE VALIDA EL SALDO ACUMULADO DEL SOBRE 
		IF   pMonRet > vMontoAcum THEN
			LET  vCodRet='00009';
			RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,vFecha_meta,
			vMontoAcum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
		END IF;	
		
		SELECT NVL(sdo_retenido,0)
		INTO   vSaldRetEj
		FROM   "informix".sc_maechq
		WHERE  cuenta = vCuenta_eje
		AND    status_cta = "1";
		
		--SE VALIDA QUE EL SALDO RETENIDO DE LA CUENTA EJE SEA IGUAL O MAYOR A LO QUE SE QUIERE RETIRAR 
		IF vSaldRetEj < pMonRet THEN 
			LET  vCodRet='00015';
			RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,vFecha_meta,
			vMontoAcum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
		END IF;
											
		IF  vTransaccion = 1 THEN 
			COMMIT WORK;
			BEGIN WORK;
		ELSE 
			BEGIN WORK;
		END IF; 
		
		LET bInicia = "T";
		
		LET vMontoAcum = vMontoAcum - pMonRet;

		IF  vMontoAcum = "0" THEN 
			LET vEst_sd = "2";
		END IF;

		--SE LIBERA EL SALDO RETENIDO 
		UPDATE "informix".sc_mae_sd
		SET    monto_acum = vMontoAcum,
			   estatus    = vEst_sd					   
		WHERE  cuenta_eje = vCuenta_eje
		AND    cuenta_sd  = vCuenta_sd
		AND    estatus IN (1,3);	
		
		IF    dbinfo('sqlca.sqlerrd2') > 0 THEN
			  LET vValUptMaeSd = '1';
		END IF;
		
		-- FOLIO DEL MOVIMIENTO 
		LET vHora  = CURRENT YEAR TO FRACTION;
		LET vFolio = vUsuario||vHora[6,7]||vHora[9,10]||vHora[15,16]||vHora[18,19];
		
		--CREA EL FOLIO A RETORNAR
		LET VusuMovRet =  "SD"||SUBSTR(vFolio,9,8);
		
		--INSERTA EL MOVIMIENTO 
		INSERT INTO "informix".sc_mov_sd VALUES (vCuenta_eje,vCuenta_sd,VusuMovRet,2,1,vFecOper,vHorOper,pMonRet,1);
		
		IF dbinfo('sqlca.sqlerrd2') > 0 THEN
			  LET vValInse = '1';
		END IF;
		
		--ACTUALIZA EL SALDO RETENIDO DE LA CUENTA EJE
		UPDATE "informix".sc_maechq 
		SET    sdo_retenido = sdo_retenido - pMonRet
		WHERE  cuenta       = vCuenta_eje
		AND    status_cta   = "1";
	
		IF dbinfo('sqlca.sqlerrd2') > 0 THEN
			LET vValUptMaeChq = '1';
		END IF;
											
		LET bInicia = "F";
		IF  vValUptMaeSd = "1" AND vValInse = "1" AND vValUptMaeChq = "1" THEN 
			LET vCodRet = "00000";
			COMMIT WORK;
			IF vtransaccion = 1 THEN
			   BEGIN WORK;
			END IF;
		ELSE 
			ROLLBACK WORK;
			LET vCodRet = '00011'; --ERROR AL LIBERAR EL SALDO EN LAS TABLAS MAESTRA O DETALLE
			IF vtransaccion = 1  THEN 
			   BEGIN WORK; 
			END IF; 
			   RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,vFecha_meta,vMontoAcum,
			   vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
		END IF;
		
		--RQM 09 704 . Luis Enrique Orozco Cosme. Fecha modificacion: 28/02/2025 
        --Se llama al SPL sp_retencion_cobranza_automatica para realizar la retencion.          
        EXECUTE PROCEDURE sp_retencion_cobranza_automatica(vNumCte,vCuenta_eje,VusuMovRet)INTO cCodRetSpReten,cMensajeRetSpReten;
        
        --Agregar validacion de codigo de retorno
        IF (cCodRetSpReten NOT IN ('00000','00002','00003')) THEN
    		--Registro del tipo de error al ejecutar el SPL sp_retencion_cobranza_automatica.
            INSERT INTO sc_bit_error_cobranza_automatica VALUES(0, cProceso, cCodRetSpReten, cMensajeRetSpReten, vNumCte, vCuenta_eje, vFecOper, vHorOper, VusuMovRet); 						
		END IF;

		-- SI EL ACUMULADO TERMINA en 0 SE CANCELA LA CUENTA									
		IF  vMontoAcum = "0" THEN 			
			IF vTipoApartado = "2" THEN
				LET vIdPlantillaPush = "SD_ELSPP";	
			END IF;

			--RETIRO TOTAL
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','PNS_BEX',vIdPlantillaPush,vNumCte,'','','1','','','','',vNombre_sd,
				'','','','','','','',1,0,0,0,0,'','') ----NOTIFICACION PUSH
			INTO vSp_CodRet;
		ELSE 
			--RETIRO PARCIAL
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','PNS_BEX','SD_RETIP',vNumCte,'','','1',pMonRet,'','','',
				vNombre_sd,'','','','','','','',1,0,0,0,0,'','') ----NOTIFICACION PUSH
			INTO vSp_CodRet;

		END IF;
			
		RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,vFecha_meta,
			vMontoAcum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
		
	END; 
END PROCEDURE
DOCUMENT
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA REALIZAR RETIROS A APARTADOS ACTIVOS O FINALIZADOS',
'AUTOR : 95358897 - ISARAI BOJORQUEZ',
'FECHA : 07/02/2023',
'BD: BDICHEQ',
'----------------------------------------------------',
'MODIFICO :     Luis Enrique Orozco Cosme',
'FECHA :        01-10-2025',
'MODIFICACION : Se agrega la inmovilizacion de saldos a la cuenta de captacion siempre y cuando cuente con una exigencia de un pago de credito',
'PROYECTO :     RQM 09 704 Cobranza Automatica en Cuentas de Captacion',
'BD :           bdicheq',
'VERSION :      1.0.1';

CREATE PROCEDURE "informix".cargo_comisiones(eEmpresa  CHAR(3),
                                             eCuenta   CHAR(20),
                                             eComision CHAR(4),
                                             eMonto    MONEY(14,2),
                                             eFolio    CHAR(16),
                                             eSucursal CHAR(4),
                                             eUsuario  CHAR(8),
                                             eCheque   INTEGER,
                                             eDivisa   CHAR(2),
                                             eHoy      DATE)
RETURNING CHAR(5);
    
    DEFINE eCodRet          CHAR(5);
    DEFINE eCodRet2         CHAR(5);
    DEFINE eCodRet3         CHAR(50);
    DEFINE sql_err          SMALLINT;
    DEFINE isam_err         SMALLINT;
    DEFINE error_info       CHAR(50);
    DEFINE vFormaAplic      CHAR(1);
    DEFINE vMtoAplic        MONEY(14,2);
    DEFINE vFactorAplic     DECIMAL(9,6);
    DEFINE vRangos          CHAR(1);
    DEFINE vRangoMin        DECIMAL(14,2);
    DEFINE vRangoMax        DECIMAL(14,2);
    DEFINE vGenIva          CHAR(1);
    DEFINE vTranCom         CHAR(4);
    DEFINE vTranIva         CHAR(4);
	DEFINE vNumTarjeta      CHAR(20);
	DEFINE pNumTarjeta      CHAR(20);
    DEFINE vMontoCom        MONEY(14,2);
    DEFINE vValIva          DECIMAL(9,6);
    DEFINE vDisponible      MONEY(14,2);
    DEFINE vMtoCom          MONEY(14,2);
    DEFINE vMontoPen        MONEY(14,2);
    DEFINE vMontoDif        MONEY(14,2);
    DEFINE vexistecta       SMALLINT;
    DEFINE vexistecom       SMALLINT;
	DEFINE vproducto        CHAR(4);
	DEFINE vIVA             MONEY(14,2);
    DEFINE vSdoDisp         MONEY(14,2);
    --RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
    DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    --RQM 09 704. Se agregan las variables para la consulta de los campos en la maestra de cheques. EEAP.
    DEFINE mSdoActual    money(14,2);
    DEFINE mSdoRetenido  money(14,2);
    DEFINE mSdoCong      money(14,2);
    DEFINE mImpChqSbg    money(14,2);
    DEFINE mSaldoSbc     money(14,2);

    ON EXCEPTION SET sql_err, isam_err, error_info
        SET DEBUG FILE TO "/tmp/cargo_comisiones.err";
        TRACE ON;
        LET eCodRet = sql_err;
        LET eCodRet2 = isam_err;
        LET eCodRet3 = error_info;
        RETURN eCodRet;
    END EXCEPTION;

    LET eCodRet      = "000";
    LET eCodRet2     = "000";
    LET eCodRet3     = "000";
    LET sql_err      = 0;
    LET isam_err     = 0;
    LET error_info   = '';
    LET vFormaAplic  = '';
    LET vMtoAplic    = 0;
    LET vFactorAplic = 0;
    LET vRangos      = '';
    LET vRangoMin    = 0;
    LET vRangoMax    = 0;
    LET vGenIva      = '';
    LET vTranCom     = '';
    LET vTranIva     = '';
    LET vMontoCom    = 0;
    LET vValIva      = 0;
	LET vNumTarjeta  = '';
	LET pNumTarjeta  = '';
    LET vDisponible  = 0;
    LET vMtoCom      = 0;
    LET vMontoPen    = 0;
    LET vMontoDif    = 0;
    LET vexistecta   = 0;
    LET vexistecom   = 0;
	LET vproducto    = '';
	LET vIVA         = 0;
    LET vSdoDisp     = 0;
    --RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
    LET cCodRetConsSdo		= '00000';
    LET cMensajeRetConsSdo	= '';
    --RQM 09 704. Se inicializan las variables los campos retornados de la maestra de cheques. EEAP.
    LET mSdoActual    = 0.00;
    LET mSdoRetenido  = 0.00;
    LET mSdoCong      = 0.00;
    LET mImpChqSbg    = 0.00;
    LET mSaldoSbc     = 0.00;
	
    --- SET DEBUG FILE TO "/tmp/cargo_comisiones.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA DATOS DE ENTRADA - EMPRESA
    IF eEmpresa is null OR eEmpresa = '' THEN
        LET eCodRet = '110';
        RETURN eCodRet;
    END IF;
    
    -- // VALIDA DATOS DE ENTRADA - CUENTA
    --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
    SELECT producto, sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbg, saldo_sbc
      INTO vproducto, mSdoActual, mSdoRetenido, mSdoCong, mImpChqSbg, mSaldoSbc
      FROM sc_maechq
     WHERE empresa = eEmpresa
       AND cuenta = eCuenta;
    
    --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
    EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCong, mSaldoSbc, mImpChqSbg, '', '', 'F', 1) INTO cCodRetConsSdo,cMensajeRetConsSdo,vDisponible;

    IF cCodRetConsSdo <> '00000' THEN
        LET eCodRet = '420';
        RETURN eCodRet;
    END IF;        

    IF vproducto in('1300', '1400', '1700') THEN
	   LET eCodRet = '000';
	   RETURN eCodRet;
	END IF;
	   
    --// Extrae instrumentacion de la Comision
    SELECT forma_aplica, monto_aplica, factor_aplica, rangos, rango_min, rango_max, genera_iva, transacc_com, transacc_iva
      INTO vFormaAplic, vMtoAplic, vFactorAplic, vRangos, vRangoMin, vRangoMax, vGenIva, vTranCom, vTranIva
      FROM sc_comisiones
     WHERE empresa = eEmpresa
       AND comision = eComision;
	   
	IF vFormaAplic is null OR vFormaAplic = " " THEN
       LET eCodRet = '550';
       RETURN eCodRet;
    END IF; 
	
	-- // Valida la sucursal para transacciones de aclaraciones
	IF eComision = '0343' THEN
	   SELECT sucursal 
	     INTO eSucursal
	     FROM bdinteg:si_sucursales
		WHERE sucursal = eSucursal;
	   IF eSucursal is null or eSucursal = "" THEN
	      SELECT sucursal
            INTO eSucursal		  
		    FROM bdinteg:si_ejecut 
		   WHERE ejecutivo in(SELECT num_empleado 
		                        FROM bdiaclaracion:acl_aclaracion 
							   WHERE folio_csuac = eFolio);
       END IF;
    END IF;	   
	
    SELECT valor 
      INTO vValIva 
      FROM bdinteg:si_param
     WHERE empresa = eEmpresa
       AND cod_param = 47;
		 
    -- // SE AGREGA UNA NUEVA FORMA DE APLICACION '3' VARIABLE 
    -- // Determina Forma de Aplicacion
    IF vFormaAplic = "1" THEN 
        LET vMontoCom = vMtoAplic; -- Monto Fijo de Comision
    ELIF vFormaAplic = "2" THEN  
        LET vMontoCom = eMOnto * vFactorAplic; -- Por Factor
    ELIF vFormaAplic = "3" THEN  -- Variable (JGP - Para Cheques Devueltos)
        LET vMontoDif = eMOnto - vDisponible;
        
        IF vMontoDif > vMtoAplic THEN
            LET vMontoCom = vMtoAplic;
        ELSE
            LET vMontoCom = vMontoDif;
        END IF;
    ELIF vFormaAplic = "4" THEN 
        LET vMontoCom = eMOnto; -- Aclaraciones
    END IF;

    -- // Valida los Rangos
    IF vRangos = "S" THEN
        IF vMontoCom < vRangoMin OR vMontoCom > vRangoMax THEN
            LET vMontoCom = vMtoAplic;
        END IF;
    END IF;

    IF vGenIva = "N" THEN 
        LET vValIva = 0;  
    END IF;

    IF vDisponible < (vMontoCom * (1 + vValIva)) THEN
        LET vMtoCom   = vMontoCom;
        LET vMontoCom = ROUND(vDisponible / (1 + vValIva),2);
        LET vMontoPen = vMtoCom - vMOntoCom;
		LET vIVA      = vDisponible - vMontoCom;
	ELSE
	    LET vIVA      = TRUNC((vMontoCom * vValIva),2);
    END IF;

--- //Registra nuevo numero de tarjeta en sc_movdia cuando cobra comision por reposicion de TDD
	IF vDisponible > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;
	    -- // Aplica Cargo por Comision	 
		IF vDisponible > 0 THEN 
        CALL cargon_ref(eEmpresa, eSucursal, eUsuario, vTranCom, "0000", eFolio, eCuenta, eCheque, vMontoCom, eDivisa, "", pNumTarjeta,"")
        RETURNING eCodRet, eComision;
        
        IF eCodRet <> "000" THEN
            RETURN eCodRet;
        END IF;
        
        -- // Valida Cobro de Iva
        IF vGenIva = "S" THEN
            --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
            EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo(eCuenta, '', '', '', '', '', '', '', 'T', 1) INTO cCodRetConsSdo,cMensajeRetConsSdo,vSdoDisp;
            IF cCodRetConsSdo <> '00000' THEN
                LET eCodRet = '420';
                RETURN eCodRet;
            END IF;       

--- //Registra nuevo numero de tarjeta en sc_movdia cuando cobra IVA de comision por reposicion de TDD			   
       IF vSdoDisp > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;  
            IF vSdoDisp > 0 THEN
                CALL cargon_ref(eEmpresa, eSucursal, eUsuario, vTranIva, "0000", eFolio, eCuenta, eCheque, vIVA, eDivisa, "",pNumTarjeta,"")
                RETURNING eCodRet, eComision;
            END IF;
                
            IF eCodRet <> "000" THEN
                RETURN eCodRet;
            END IF;
        END IF;
    END IF;

    -- // Registra comision pendiente si es el caso
    IF vMontoPen > 0 THEN
        INSERT INTO sc_detcomis 
        VALUES(eEmpresa, eCuenta, vTranCom, vMontoPen  , 0, eHoy, "", "P", eFolio);

        UPDATE sc_maechq
           SET com_pendiente =  com_pendiente + vMontoPen
         WHERE empresa = eEmpresa
           AND cuenta  = eCuenta;
    END IF;

    RETURN eCodRet;

END PROCEDURE

DOCUMENT
'Esta funcion se encarga de realizar los movimientos de cargo por ',
'concepto de comisiones e iva de las mismas',
'AUTOR : Procesaminto Interactivo S.A. Axl',
'FECHA : 28/01/2010',
'BD : bdicheq ',
'CLIENTE : Todos',
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 01-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2',
'MODIFICO:         Donovan Fernando Torres Landeros',
'FECHA:            10-02-2026',
'MODIFICACION:     Se agrega la validacion del codigo de retorno no exitoso(diferente de 00000)', 
'PROYECTO:         RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:               BDICHEQ',
'VERSION:          1.3';

CREATE PROCEDURE "informix".cargo_comisiones_per(eEmpresa  CHAR(3),
                                             eCuenta   CHAR(20),
                                             eComision CHAR(4),
                                             eMonto    MONEY(14,2),
                                             eFolio    CHAR(16),
                                             eSucursal CHAR(4),
                                             eUsuario  CHAR(8),
                                             eCheque   INTEGER,
                                             eDivisa   CHAR(2),
                                             eHoy      DATE)
RETURNING CHAR(5);
    
    DEFINE eCodRet          CHAR(5);
    DEFINE eCodRet2         CHAR(5);
    DEFINE eCodRet3         CHAR(50);
    DEFINE sql_err          SMALLINT;
    DEFINE isam_err         SMALLINT;
    DEFINE error_info       CHAR(50);
    DEFINE vFormaAplic      CHAR(1);
    DEFINE vMtoAplic        MONEY(14,2);
    DEFINE vFactorAplic     DECIMAL(9,6);
    DEFINE vRangos          CHAR(1);
    DEFINE vRangoMin        DECIMAL(14,2);
    DEFINE vRangoMax        DECIMAL(14,2);
    DEFINE vGenIva          CHAR(1);
    DEFINE vTranCom         CHAR(4);
    DEFINE vTranIva         CHAR(4);
	DEFINE vNumTarjeta      CHAR(20);
	DEFINE pNumTarjeta      CHAR(20);
    DEFINE vMontoCom        MONEY(14,2);
    DEFINE vValIva          DECIMAL(9,6);
    DEFINE vDisponible      MONEY(14,2);
    DEFINE vMtoCom          MONEY(14,2);
    DEFINE vMontoPen        MONEY(14,2);
    DEFINE vMontoDif        MONEY(14,2);
    DEFINE vexistecta       SMALLINT;
    DEFINE vexistecom       SMALLINT;
	DEFINE vproducto        CHAR(4);
	DEFINE vIVA             MONEY(14,2);
    DEFINE vSdoDisp         MONEY(14,2);
    --RQM 09 704. Se agregan las siguientes variable DFTL 
    DEFINE mSdoActual       MONEY(14,2);
    DEFINE mSdoRetenido     MONEY(14,2);
    DEFINE mSdoCong         MONEY(14,2);
    DEFINE mImpChqSbg       MONEY(14,2);
    DEFINE mSaldoSbc        MONEY(14,2);
    DEFINE cCodRetConsSdo       CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.

    ON EXCEPTION SET sql_err, isam_err, error_info
        SET DEBUG FILE TO "/tmp/cargo_comisiones_per.err";
        TRACE ON;
        LET eCodRet = sql_err;
        LET eCodRet2 = isam_err;
        LET eCodRet3 = error_info;
        RETURN eCodRet;
    END EXCEPTION;

    LET eCodRet      = "000";
    LET eCodRet2     = "000";
    LET eCodRet3     = "000";
    LET sql_err      = 0;
    LET isam_err     = 0;
    LET error_info   = '';
    LET vFormaAplic  = '';
    LET vMtoAplic    = 0;
    LET vFactorAplic = 0;
    LET vRangos      = '';
    LET vRangoMin    = 0;
    LET vRangoMax    = 0;
    LET vGenIva      = '';
    LET vTranCom     = '';
    LET vTranIva     = '';
    LET vMontoCom    = 0;
    LET vValIva      = 0;
	LET vNumTarjeta  = '';
	LET pNumTarjeta  = '';
    LET vDisponible  = 0;
    LET vMtoCom      = 0;
    LET vMontoPen    = 0;
    LET vMontoDif    = 0;
    LET vexistecta   = 0;
    LET vexistecom   = 0;
	LET vproducto    = '';
	LET vIVA         = 0;
    LET vSdoDisp     = 0;
   --RQM 09 704. Se agregan las siguientes variable DFTL
    LET mSdoActual          = 0;
    LET mSdoRetenido        = 0;
    LET mSdoCong            = 0;
    LET mImpChqSbg          = 0;
    LET mSaldoSbc           = 0;
    LET cCodRetConsSdo      = '00000';
    LET cMensajeRetConsSdo  = '';

	
   --SET DEBUG FILE TO "/home/c90402536/Traza/cargo_comisiones_per_modif.out";
   --TRACE ON; 
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA DATOS DE ENTRADA - EMPRESA
    IF eEmpresa is null OR eEmpresa = '' THEN
        LET eCodRet = '110';
        RETURN eCodRet;
    END IF;
    


    -- // VALIDA DATOS DE ENTRADA - CUENTA
    -- RQM 09 704. Se agrega la variable del saldo inmovilizado para el consumo del spl sp_cons_sdodisp_x_tpcalculo. DFTL
    SELECT producto, sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbg, saldo_sbc
      INTO vproducto, mSdoActual, mSdoRetenido, mSdoCong, mImpChqSbg, mSaldoSbc
      FROM sc_maechq
     WHERE empresa = eEmpresa
       AND cuenta = eCuenta;
    
    --RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL 
    EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCong, mSaldoSbc, mImpChqSbg, null, null, 'F', '1')     
    INTO cCodRetConsSdo, cMensajeRetConsSdo, vDisponible;
   
    IF cCodRetConsSdo <> '00000' THEN
        LET eCodRet = '420';
        RETURN eCodRet;
    END IF;   
    --IF vproducto in('1300', '1400', '1700') THEN
	--   LET eCodRet = '000';
	--   RETURN eCodRet;
	--END IF;
	   
    --// Extrae instrumentacion de la Comision
    SELECT forma_aplica, monto_aplica, factor_aplica, rangos, rango_min, rango_max, genera_iva, transacc_com, transacc_iva
      INTO vFormaAplic, vMtoAplic, vFactorAplic, vRangos, vRangoMin, vRangoMax, vGenIva, vTranCom, vTranIva
      FROM sc_comisiones
     WHERE empresa = eEmpresa
       AND comision = eComision;
	   
	IF vFormaAplic is null OR vFormaAplic = " " THEN
       LET eCodRet = '550';
       RETURN eCodRet;
    END IF; 
	
	-- // Valida la sucursal para transacciones de aclaraciones
	IF eComision = '0343' THEN
	   SELECT sucursal 
	     INTO eSucursal
	     FROM bdinteg:si_sucursales
		WHERE sucursal = eSucursal;
	   IF eSucursal is null or eSucursal = "" THEN
	      SELECT sucursal
            INTO eSucursal		  
		    FROM bdinteg:si_ejecut 
		   WHERE ejecutivo in(SELECT num_empleado 
		                        FROM bdiaclaracion:acl_aclaracion 
							   WHERE folio_csuac = eFolio);
       END IF;
    END IF;	   
	
    SELECT valor 
      INTO vValIva 
      FROM bdinteg:si_param
     WHERE empresa = eEmpresa
       AND cod_param = 47;
		 
    -- // SE AGREGA UNA NUEVA FORMA DE APLICACION '3' VARIABLE 
    -- // Determina Forma de Aplicacion
    /*IF vFormaAplic = "1" THEN 
        LET vMontoCom = vMtoAplic; -- Monto Fijo de Comision
    ELIF vFormaAplic = "2" THEN  
        LET vMontoCom = eMOnto * vFactorAplic; -- Por Factor
    ELIF vFormaAplic = "3" THEN  -- Variable (JGP - Para Cheques Devueltos)
        LET vMontoDif = eMOnto - vDisponible;
        
        IF vMontoDif > vMtoAplic THEN
            LET vMontoCom = vMtoAplic;
        ELSE
            LET vMontoCom = vMontoDif;
        END IF;
    ELIF vFormaAplic = "4" THEN 
        LET vMontoCom = eMOnto; -- Aclaraciones
    END IF;*/

    LET vMontoCom=eMOnto;

    -- // Valida los Rangos
    IF vRangos = "S" THEN
        IF vMontoCom < vRangoMin OR vMontoCom > vRangoMax THEN
            LET vMontoCom = vMtoAplic;
        END IF;
    END IF;

    IF vGenIva = "N" THEN 
        LET vValIva = 0;  
    END IF;

    IF vDisponible < (vMontoCom * (1 + vValIva)) THEN
        LET vMtoCom   = vMontoCom;
        LET vMontoCom = ROUND(vDisponible / (1 + vValIva),2);
        LET vMontoPen = vMtoCom - vMOntoCom;
		LET vIVA      = vDisponible - vMontoCom;
	ELSE
	    LET vIVA      = TRUNC((vMontoCom * vValIva),2);
    END IF;

--- //Registra nuevo numero de tarjeta en sc_movdia cuando cobra comision por reposicion de TDD
	IF vDisponible > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;
	    -- // Aplica Cargo por Comision	 
		IF vDisponible > 0 THEN 
        CALL cargon_ref(eEmpresa, eSucursal, eUsuario, vTranCom, "0000", eFolio, eCuenta, eCheque, vMontoCom, eDivisa, "", pNumTarjeta,"")
        RETURNING eCodRet, eComision;
        
        IF eCodRet <> "000" THEN
            RETURN eCodRet;
        END IF;
        
        -- // Valida Cobro de Iva
        IF vGenIva = "S" THEN
        --RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL 
        EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo(eCuenta, null, null, null, null, null, null, null, 'T', '1')     
        INTO cCodRetConsSdo, cMensajeRetConsSdo, vSdoDisp;

        IF cCodRetConsSdo <> '00000' THEN
            LET eCodRet = '420';
            RETURN eCodRet;
        END IF;   

--- //Registra nuevo numero de tarjeta en sc_movdia cuando cobra IVA de comision por reposicion de TDD			   
       IF vSdoDisp > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;  
            IF vSdoDisp > 0 THEN
                CALL cargon_ref(eEmpresa, eSucursal, eUsuario, vTranIva, "0000", eFolio, eCuenta, eCheque, vIVA, eDivisa, "",pNumTarjeta,"")
                RETURNING eCodRet, eComision;
            END IF;
                
            IF eCodRet <> "000" THEN
                RETURN eCodRet;
            END IF;
        END IF;
    END IF;

    -- // Registra comision pendiente si es el caso
    IF vMontoPen > 0 THEN
        INSERT INTO sc_detcomis 
        VALUES(eEmpresa, eCuenta, vTranCom, vMontoPen  , 0, eHoy, "", "P", eFolio);

        UPDATE sc_maechq
           SET com_pendiente =  com_pendiente + vMontoPen
         WHERE empresa = eEmpresa
           AND cuenta  = eCuenta;
    END IF;

    RETURN eCodRet;

END PROCEDURE

DOCUMENT
'Esta funcion se encarga de realizar los movimientos de cargo por ',
'concepto de comisiones e iva de las mismas',
'AUTOR : Procesaminto Interactivo S.A. Axl',
'FECHA : 28/01/2010',
'BD : bdicheq ',
'CLIENTE : Todos',
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/03',
'RAZON:                 Se agrega la nueva variable saldo_sbc (inmovilizacion por concepto de credito)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.2',
'MODIFICO:         Donovan Fernando Torres Landeros',
'FECHA:            10-02-2026',
'MODIFICACION:     Se agrega la validacion del codigo de retorno no exitoso(diferente de 00000)', 
'PROYECTO:         RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:               BDICHEQ',
'VERSION:          1.3';

CREATE PROCEDURE "informix".cargo_comisiones_per_web(eEmpresa  CHAR(3),
                                             eCuenta   CHAR(20),
                                             eComision CHAR(4),
                                             eMonto    MONEY(14,2),
                                             eFolio    CHAR(16),
                                             eSucursal CHAR(4),
                                             eUsuario  CHAR(8),
                                             eCheque   INTEGER,
                                             eDivisa   CHAR(2),
                                             eHoy      DATE)
RETURNING CHAR(5);
    
    DEFINE eCodRet          CHAR(5);
    DEFINE eCodRet2         CHAR(5);
    DEFINE eCodRet3         CHAR(50);
    DEFINE sql_err          SMALLINT;
    DEFINE isam_err         SMALLINT;
    DEFINE error_info       CHAR(50);
    DEFINE vFormaAplic      CHAR(1);
    DEFINE vMtoAplic        MONEY(14,2);
    DEFINE vFactorAplic     DECIMAL(9,6);
    DEFINE vRangos          CHAR(1);
    DEFINE vRangoMin        DECIMAL(14,2);
    DEFINE vRangoMax        DECIMAL(14,2);
    DEFINE vGenIva          CHAR(1);
    DEFINE vTranCom         CHAR(4);
    DEFINE vTranIva         CHAR(4);
	DEFINE vNumTarjeta      CHAR(20);
	DEFINE pNumTarjeta      CHAR(20);
    DEFINE vMontoCom        MONEY(14,2);
    DEFINE vValIva          DECIMAL(9,6);
    DEFINE vDisponible      MONEY(14,2);
    DEFINE vMtoCom          MONEY(14,2);
    DEFINE vMontoPen        MONEY(14,2);
    DEFINE vMontoDif        MONEY(14,2);
    DEFINE vexistecta       SMALLINT;
    DEFINE vexistecom       SMALLINT;
	DEFINE vproducto        CHAR(4);
	DEFINE vIVA             MONEY(14,2);
    DEFINE vSdoDisp         MONEY(14,2);
    -- SE AGREGAN LAS VARIABLES DE SALDO ACTUAL, SALDO RETENIDO, SALDO CONGELADO Y SALDO SBC OACM
    DEFINE cCodRetConsSdo          CHAR(5);
    DEFINE cMensajeRet      CHAR(50); 
    DEFINE mSdoActual       MONEY(14,2);
    DEFINE mSdoRetenido     MONEY(14,2);
    DEFINE mSdoCong         MONEY(14,2);
    DEFINE mSaldoSbc        MONEY(14,2);
    DEFINE mImpChqSbg       MONEY(14,2);

    ON EXCEPTION SET sql_err, isam_err, error_info
        SET DEBUG FILE TO "/tmp/cargo_comisiones_per.err";
        TRACE ON;
        LET eCodRet = sql_err;
        LET eCodRet2 = isam_err;
        LET eCodRet3 = error_info;
        RETURN eCodRet;
    END EXCEPTION;

    LET eCodRet      = "00000";
    LET eCodRet2     = "000";
    LET eCodRet3     = "000";
    LET sql_err      = 0;
    LET isam_err     = 0;
    LET error_info   = '';
    LET vFormaAplic  = '';
    LET vMtoAplic    = 0;
    LET vFactorAplic = 0;
    LET vRangos      = '';
    LET vRangoMin    = 0;
    LET vRangoMax    = 0;
    LET vGenIva      = '';
    LET vTranCom     = '';
    LET vTranIva     = '';
    LET vMontoCom    = 0;
    LET vValIva      = 0;
	LET vNumTarjeta  = '';
	LET pNumTarjeta  = '';
    LET vDisponible  = 0;
    LET vMtoCom      = 0;
    LET vMontoPen    = 0;
    LET vMontoDif    = 0;
    LET vexistecta   = 0;
    LET vexistecom   = 0;
	LET vproducto    = '';
	LET vIVA         = 0;
    LET vSdoDisp     = 0;
    -- SE INICIALIZAN LAS VARIABLES DE SALDO ACTUAL, SALDO RETENIDO, SALDO CONGELADO Y SALDO SBC OACM
    LET cCodRetConsSdo = '00000';
    LET cMensajeRet	= 'Proceso de consulta de saldo exitoso';
    LET mSdoActual = 0.00;
    LET mSdoRetenido = 0.00;
    LET mSdoCong  = 0.00;
    LET mSaldoSbc = 0.00;
    LET mImpChqSbg = 0.00;
	
    -- SET DEBUG FILE TO "/tmp/cargo_comisiones_per.out";
     --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA DATOS DE ENTRADA - EMPRESA
    IF eEmpresa is null OR eEmpresa = '' THEN
        LET eCodRet = '110';
        RETURN eCodRet;
    END IF;
    
    ---RQM 09 704. Se realiza la consulta de saldo congelado, el saldo retenido y el saldo sbc. OACM 
		--Consulta el saldo de la cuenta Cargo AFORE	 
	SELECT producto,sdo_actual,sdo_cong, sdo_retenido,saldo_sbc,imp_chq_sbg
	INTO vproducto,mSdoActual,mSdoCong,mSdoRetenido,mSaldoSbc,mImpChqSbg
	FROM bdicheq:"informix".sc_maechq
    WHERE empresa = eEmpresa
    AND cuenta = eCuenta;

	-- RQM 09 704. Se almacena el saldo actual por medio de la ejecucion del SP sp_cons_sdodisp_x_tpcalculo OACM
	EXECUTE PROCEDURE BDICHEQ:sp_cons_sdodisp_x_tpcalculo(NULL,mSdoActual,mSdoRetenido,mSdoCong,mSaldoSbc,mImpChqSbg,NULL,NULL,'F',1) 
	INTO cCodRetConsSdo,cMensajeRet,vDisponible;
    
    IF cCodRetConsSdo <> '00000' THEN
        LET eCodRet = '420';
        RETURN eCodRet;
    END IF;   

    --IF vproducto in('1300', '1400', '1700') THEN
	--   LET eCodRet = '000';
	--   RETURN eCodRet;
	--END IF;
	   
    --// Extrae instrumentacion de la Comision
    SELECT forma_aplica, monto_aplica, factor_aplica, rangos, rango_min, rango_max, genera_iva, transacc_com, transacc_iva
      INTO vFormaAplic, vMtoAplic, vFactorAplic, vRangos, vRangoMin, vRangoMax, vGenIva, vTranCom, vTranIva
      FROM sc_comisiones
     WHERE empresa = eEmpresa
       AND comision = eComision;
	   
	IF vFormaAplic is null OR vFormaAplic = " " THEN
       LET eCodRet = '550';
       RETURN eCodRet;
    END IF; 
	
	-- // Valida la sucursal para transacciones de aclaraciones
	IF eComision = '0343' THEN
	   SELECT sucursal 
	     INTO eSucursal
	     FROM bdinteg:si_sucursales
		WHERE sucursal = eSucursal;
	   IF eSucursal is null or eSucursal = "" THEN
	      SELECT sucursal
            INTO eSucursal		  
		    FROM bdinteg:si_ejecut 
		   WHERE ejecutivo in(SELECT num_empleado 
		                        FROM bdiaclaracion:acl_aclaracion 
							   WHERE folio_csuac = eFolio);
       END IF;
    END IF;	   
	
    SELECT valor 
      INTO vValIva 
      FROM bdinteg:si_param
     WHERE empresa = eEmpresa
       AND cod_param = 47;
		 
    -- // SE AGREGA UNA NUEVA FORMA DE APLICACION '3' VARIABLE 
    -- // Determina Forma de Aplicacion
    /*IF vFormaAplic = "1" THEN 
        LET vMontoCom = vMtoAplic; -- Monto Fijo de Comision
    ELIF vFormaAplic = "2" THEN  
        LET vMontoCom = eMOnto * vFactorAplic; -- Por Factor
    ELIF vFormaAplic = "3" THEN  -- Variable (JGP - Para Cheques Devueltos)
        LET vMontoDif = eMOnto - vDisponible;
        
        IF vMontoDif > vMtoAplic THEN
            LET vMontoCom = vMtoAplic;
        ELSE
            LET vMontoCom = vMontoDif;
        END IF;
    ELIF vFormaAplic = "4" THEN 
        LET vMontoCom = eMOnto; -- Aclaraciones
    END IF;*/

    LET vMontoCom=eMOnto;

    -- // Valida los Rangos
    IF vRangos = "S" THEN
        IF vMontoCom < vRangoMin OR vMontoCom > vRangoMax THEN
            LET vMontoCom = vMtoAplic;
        END IF;
    END IF;

    IF vGenIva = "N" THEN 
        LET vValIva = 0;  
    END IF;

    IF vDisponible < (vMontoCom * (1 + vValIva)) THEN
        LET vMtoCom   = vMontoCom;
        LET vMontoCom = ROUND(vDisponible / (1 + vValIva),2);
        LET vMontoPen = vMtoCom - vMOntoCom;
		LET vIVA      = vDisponible - vMontoCom;
	ELSE
	    LET vIVA      = TRUNC((vMontoCom * vValIva),2);
    END IF;

--- //Registra nuevo numero de tarjeta en sc_movdia cuando cobra comision por reposicion de TDD
	IF vDisponible > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;
	    -- // Aplica Cargo por Comision	 
		IF vDisponible > 0 THEN 
        CALL cargon_ref(eEmpresa, eSucursal, eUsuario, vTranCom, "0000", eFolio, eCuenta, eCheque, vMontoCom, eDivisa, "", pNumTarjeta,"")
        RETURNING eCodRet, eComision;
        
        IF eCodRet <> "000" THEN
            RETURN eCodRet;
        END IF;
        
        -- // Valida Cobro de Iva
        IF vGenIva = "S" THEN
			---RQM 09 704. Se realiza la consulta de saldo congelado, el saldo retenido y el saldo sbc. OACM 
			SELECT sdo_actual,sdo_cong, sdo_retenido,saldo_sbc,imp_chq_sbg
			INTO mSdoActual,mSdoCong,mSdoRetenido,mSaldoSbc,mImpChqSbg
			FROM bdicheq:"informix".sc_maechq
			WHERE empresa = eEmpresa
			AND cuenta = eCuenta;

			-- RQM 09 704. Se almacena el saldo actual por medio de la ejecucion del SP sp_cons_sdodisp_x_tpcalculo OACM
			EXECUTE PROCEDURE BDICHEQ:sp_cons_sdodisp_x_tpcalculo(NULL,mSdoActual,mSdoRetenido,mSdoCong,mSaldoSbc,mImpChqSbg,NULL,NULL,'F',1) 
			INTO cCodRetConsSdo,cMensajeRet,vSdoDisp;

            IF cCodRetConsSdo <> '00000' THEN
                LET eCodRet = '420';
                RETURN eCodRet;
            END IF;   
		
--- //Registra nuevo numero de tarjeta en sc_movdia cuando cobra IVA de comision por reposicion de TDD			   
       IF vSdoDisp > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;  
            IF vSdoDisp > 0 THEN
                CALL cargon_ref(eEmpresa, eSucursal, eUsuario, vTranIva, "0000", eFolio, eCuenta, eCheque, vIVA, eDivisa, "",pNumTarjeta,"")
                RETURNING eCodRet, eComision;
            END IF;
                
            IF eCodRet <> "000" THEN
                RETURN eCodRet;
            END IF;
        END IF;
    END IF;

    -- // Registra comision pendiente si es el caso
    IF vMontoPen > 0 THEN
        INSERT INTO sc_detcomis 
        VALUES(eEmpresa, eCuenta, vTranCom, vMontoPen  , 0, eHoy, "", "P", eFolio);

        UPDATE sc_maechq
           SET com_pendiente =  com_pendiente + vMontoPen
         WHERE empresa = eEmpresa
           AND cuenta  = eCuenta;
    END IF;

    RETURN '00'||eCodRet;

END PROCEDURE

DOCUMENT
'Esta funcion se encarga de realizar los movimientos de cargo por ',
'concepto de comisiones e iva de las mismas',
'AUTOR : Procesaminto Interactivo S.A. Axl',
'FECHA : 28/01/2010',
'BD : bdicheq ',
'CLIENTE : Todos',
'Modificacion Se agrega el saldo sbc en el saldo actual ',
'AUTOR : Osiel Alfredo Camacho Mendoza',
'FECHA : 08/07/2025',
'BD : bdicheq ',
'MODIFICO:         Donovan Fernando Torres Landeros',
'FECHA:            10-02-2026',
'MODIFICACION:     Se agrega la validacion del codigo de retorno no exitoso(diferente de 00000)', 
'PROYECTO:         RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:               BDICHEQ',
'VERSION:          1.3';

CREATE PROCEDURE "informix".cargo_comisiones_web(eEmpresa  CHAR(3),
                                             eCuenta   CHAR(20),
                                             eComision CHAR(4),
                                             eMonto    MONEY(14,2),
                                             eFolio    CHAR(16),
                                             eSucursal CHAR(4),
                                             eUsuario  CHAR(8),
                                             eCheque   INTEGER,
                                             eDivisa   CHAR(2),
                                             eHoy      DATE)
RETURNING CHAR(5);
    
    DEFINE eCodRet          CHAR(5);
    DEFINE eCodRet2         CHAR(5);
    DEFINE eCodRet3         CHAR(50);
    DEFINE sql_err          SMALLINT;
    DEFINE isam_err         SMALLINT;
    DEFINE error_info       CHAR(50);
    DEFINE vFormaAplic      CHAR(1);
    DEFINE vMtoAplic        MONEY(14,2);
    DEFINE vFactorAplic     DECIMAL(9,6);
    DEFINE vRangos          CHAR(1);
    DEFINE vRangoMin        DECIMAL(14,2);
    DEFINE vRangoMax        DECIMAL(14,2);
    DEFINE vGenIva          CHAR(1);
    DEFINE vTranCom         CHAR(4);
    DEFINE vTranIva         CHAR(4);
	DEFINE vNumTarjeta      CHAR(20);
	DEFINE pNumTarjeta      CHAR(20);
    DEFINE vMontoCom        MONEY(14,2);
    DEFINE vValIva          DECIMAL(9,6);
    DEFINE vDisponible      MONEY(14,2);
    DEFINE vMtoCom          MONEY(14,2);
    DEFINE vMontoPen        MONEY(14,2);
    DEFINE vMontoDif        MONEY(14,2);
    DEFINE vexistecta       SMALLINT;
    DEFINE vexistecom       SMALLINT;
	DEFINE vproducto        CHAR(4);
	DEFINE vIVA             MONEY(14,2);
    DEFINE vSdoDisp         MONEY(14,2);
    --RQM 09 704. Se agregan las siguientes variable DFTL
    DEFINE mSdoActual       MONEY(14,2);
    DEFINE mSdoRetenido     MONEY(14,2);
    DEFINE mSdoCong         MONEY(14,2);
    DEFINE mImpChqSbg       MONEY(14,2);
    DEFINE mSaldoSbc        MONEY(14,2);
    DEFINE cCodRetConsSdo       CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    DEFINE mSdoDisponible    MONEY(14,2);

    ON EXCEPTION SET sql_err, isam_err, error_info
        --SET DEBUG FILE TO "/tmp/cargo_comisiones.err";
        --TRACE ON;
        LET eCodRet = sql_err;
        LET eCodRet2 = isam_err;
        LET eCodRet3 = error_info;
        RETURN eCodRet;
    END EXCEPTION;

    LET eCodRet      = "00000";
    LET eCodRet2     = "000";
    LET eCodRet3     = "000";
    LET sql_err      = 0;
    LET isam_err     = 0;
    LET error_info   = '';
    LET vFormaAplic  = '';
    LET vMtoAplic    = 0;
    LET vFactorAplic = 0;
    LET vRangos      = '';
    LET vRangoMin    = 0;
    LET vRangoMax    = 0;
    LET vGenIva      = '';
    LET vTranCom     = '';
    LET vTranIva     = '';
    LET vMontoCom    = 0;
    LET vValIva      = 0;
	LET vNumTarjeta  = '';
	LET pNumTarjeta  = '';
    LET vDisponible  = 0;
    LET vMtoCom      = 0;
    LET vMontoPen    = 0;
    LET vMontoDif    = 0;
    LET vexistecta   = 0;
    LET vexistecom   = 0;
	LET vproducto    = '';
	LET vIVA         = 0;
    LET vSdoDisp     = 0;
   --RQM 09 704. Se agregan las siguientes variable DFTL
    LET mSdoActual          = 0;
    LET mSdoRetenido        = 0;
    LET mSdoCong            = 0;
    LET mImpChqSbg          = 0;
    LET mSaldoSbc           = 0;
    LET cCodRetConsSdo      = '00000';
    LET cMensajeRetConsSdo  = '';


   --SET DEBUG FILE TO "/home/c90402536/Traza/cargo_comisiones_web_modif.out";
   --TRACE ON; 
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- 
    IF eEmpresa is null OR eEmpresa = '' THEN
        LET eCodRet = '110';
        RETURN eCodRet;
    END IF;
    
    -- // VALIDA DATOS DE ENTRADA - CUENTA
    -- RQM 09 704. Se agrega la variable del saldo inmovilizado para el consumo del spl sp_cons_sdodisp_x_tpcalculo. DFTL
    SELECT producto, sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbg, saldo_sbc
      INTO vproducto, mSdoActual, mSdoRetenido, mSdoCong, mImpChqSbg, mSaldoSbc
      FROM sc_maechq
     WHERE empresa = eEmpresa
       AND cuenta = eCuenta;
    
    --RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL 
    EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCong, mSaldoSbc, mImpChqSbg, null, null, 'F', '1')     
    INTO cCodRetConsSdo, cMensajeRetConsSdo, vDisponible;

    IF cCodRetConsSdo <> '00000' THEN
        LET eCodRet = '420';
        RETURN eCodRet;
    END IF;   

    IF vproducto in('1300', '1400', '1700') THEN
	   LET eCodRet = '000';
	   RETURN eCodRet;
	END IF;
	   
    --
    SELECT forma_aplica, monto_aplica, factor_aplica, rangos, rango_min, rango_max, genera_iva, transacc_com, transacc_iva
      INTO vFormaAplic, vMtoAplic, vFactorAplic, vRangos, vRangoMin, vRangoMax, vGenIva, vTranCom, vTranIva
      FROM sc_comisiones
     WHERE empresa = eEmpresa
       AND comision = eComision;
	   
	IF vFormaAplic is null OR vFormaAplic = " " THEN
       LET eCodRet = '00550';
       RETURN eCodRet;
    END IF; 
	
	-- 
	IF eComision = '0343' THEN
	   SELECT sucursal 
	     INTO eSucursal
	     FROM bdinteg:si_sucursales
		WHERE sucursal = eSucursal;
	   IF eSucursal is null or eSucursal = "" THEN
	      SELECT sucursal
            INTO eSucursal		  
		    FROM bdinteg:si_ejecut 
		   WHERE ejecutivo in(SELECT num_empleado 
		                        FROM bdiaclaracion:acl_aclaracion 
							   WHERE folio_csuac = eFolio);
       END IF;
    END IF;	   
	
    SELECT valor 
      INTO vValIva 
      FROM bdinteg:si_param
     WHERE empresa = eEmpresa
       AND cod_param = 47;
		 
    -- 
    -- 
    IF vFormaAplic = "1" THEN 
        LET vMontoCom = vMtoAplic; -- Monto Fijo de Comision
    ELIF vFormaAplic = "2" THEN  
        LET vMontoCom = eMOnto * vFactorAplic; -- Por Factor
    ELIF vFormaAplic = "3" THEN  -- Variable (JGP - Para Cheques Devueltos)
        LET vMontoDif = eMOnto - vDisponible;
        
        IF vMontoDif > vMtoAplic THEN
            LET vMontoCom = vMtoAplic;
        ELSE
            LET vMontoCom = vMontoDif;
        END IF;
    ELIF vFormaAplic = "4" THEN 
        LET vMontoCom = eMOnto; -- Aclaraciones
    END IF;

    -- 
    IF vRangos = "S" THEN
        IF vMontoCom < vRangoMin OR vMontoCom > vRangoMax THEN
            LET vMontoCom = vMtoAplic;
        END IF;
    END IF;

    IF vGenIva = "N" THEN 
        LET vValIva = 0;  
    END IF;

    IF vDisponible < (vMontoCom * (1 + vValIva)) THEN
        LET vMtoCom   = vMontoCom;
        LET vMontoCom = ROUND(vDisponible / (1 + vValIva),2);
        LET vMontoPen = vMtoCom - vMOntoCom;
		LET vIVA      = vDisponible - vMontoCom;
	ELSE
	    LET vIVA      = TRUNC((vMontoCom * vValIva),2);
    END IF;

--- 
	IF vDisponible > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;
	    -- 
		IF vDisponible > 0 THEN 
        CALL cargon_ref(eEmpresa, eSucursal, eUsuario, vTranCom, "0000", eFolio, eCuenta, eCheque, vMontoCom, eDivisa, "", pNumTarjeta,"")
        RETURNING eCodRet, eComision;
        
        IF eCodRet <> "000" THEN
            LET eCodRet = '00001';
            RETURN eCodRet;
        END IF;
        
        -- 
        IF vGenIva = "S" THEN
        --RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL 
        EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo(eCuenta, null, null, null, null, null, null, null, 'T', '1')     
        INTO cCodRetConsSdo, cMensajeRetConsSdo, vSdoDisp;
---     
        IF cCodRetConsSdo <> '00000' THEN
            LET eCodRet = '420';
            RETURN eCodRet;
        END IF;

       IF vSdoDisp > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;  
            IF vSdoDisp > 0 THEN
                CALL cargon_ref(eEmpresa, eSucursal, eUsuario, vTranIva, "0000", eFolio, eCuenta, eCheque, vIVA, eDivisa, "",pNumTarjeta,"")
                RETURNING eCodRet, eComision;
            END IF;
                
            IF eCodRet <> "000" THEN
                LET eCodRet = '00001';
                RETURN eCodRet;
            END IF;
        END IF;
    END IF;

    -- 
    IF vMontoPen > 0 THEN
        INSERT INTO sc_detcomis 
        VALUES(eEmpresa, eCuenta, vTranCom, vMontoPen  , 0, eHoy, "", "P", eFolio);

        UPDATE sc_maechq
           SET com_pendiente =  com_pendiente + vMontoPen
         WHERE empresa = eEmpresa
           AND cuenta  = eCuenta;
    END IF;

    RETURN eCodRet;

END PROCEDURE

DOCUMENT
'Esta funcion se encarga de realizar los movimientos de cargo por ',
'concepto de comisiones e iva de las mismas',
'AUTOR : Procesaminto Interactivo S.A. Axl',
'FECHA : 28/01/2010',
'BD : bdicheq ',
'CLIENTE : Todos',
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/03',
'RAZON:                 Se agrega la nueva variable saldo_sbc (inmovilizacion por concepto de credito)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.2',
'MODIFICO:              Donovan Fernando Torres Landeros',
'FECHA:                 10-02-2026',
'MODIFICACION:          Se agrega la validacion del codigo de retorno no exitoso(diferente de 00000)', 
'PROYECTO:              RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:                    BDICHEQ',
'VERSION:               1.3';

create procedure "informix".cobintcomsbg(pempresa   char(3),
                                         pcuenta    char(20),
                                         pfolio_suc char(16),
                                         pusuario   char(8),
                                         psucursal  char(4))
returning char(5);

    define vcodret                      char(5);
    define vimpiva                      money(14,2);
    define vtransacc,vtraniva           char(4);
    define vtasaiva                     decimal (6,3);
    define vsqlerr,vrowid               integer;
    define vsuccta                      char(4);
    define vfecha_hoy                   date;
    define vfechacalendario             date;
    define vimp_int_ccc,vimp_sbg_ccc,
           vsdo_retenido,vsdo_cong,
           vsdo_actual,vsdo_disp,
           vtotcobro,vimp_chq_sbg,
           vimp_int_sbg,vimpcobro,
           vsdo_comision                money(14,2);
    define vreferencia                  char(20);
    define vproducto                    char(4);
    define vnumcgos                     smallint;
    define vhora datetime               hour to fraction(3);
    define vestado_com                  char(1);
    define vnum_tarjeta                 char(16);
    define vmaxsec                      smallint;
    define vtasabaseiva                 decimal(6,3);
    define vstatus_cta                  char(1);
	
	DEFINE cCodRetIndicador				CHAR(6);
	define vfecha_operacion             date;
	--RQM 09 704. Se crea la siguiente variable . DHG
	DEFINE mSaldoSBC			MONEY(14,2); --Monto del saldo invomilizado (Salvo Buen Cobro).
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
		

    let vcodret     = "000";
    let vreferencia = " ";
	
	LET cCodRetIndicador  = "000000";
	LET vfecha_operacion = TODAY;
	--RQM 09 704. Se inicializa la siguiente variable generada. DHG
	LET mSaldoSBC			= 0.00;
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';
	
    begin
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret;
        end if;
    end exception;
	
	--set debug file to '/informix/moha/cobintcomsbg.out';
	--trace on;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;
    set optimization high;
--    set pdqpriority 1;

    select {+INDEX(sc_fechas idx_fechas1)}
           fecha_hoy 
      into vfechacalendario
      from sc_fechas 
     where empresa = pempresa;

    select fecha_proceso, status_cta
      into vfecha_hoy, vstatus_cta
      from sc_maechq
     where empresa = pempresa
       and cuenta = pcuenta;

    if (vfecha_hoy is null or vstatus_cta = '4' or vstatus_cta = '5')then
        let vfecha_hoy = vfechacalendario;
    end if       

    if (vfecha_hoy < vfechacalendario ) then
        let vcodret = "549";
        return  vcodret;
    end if  
    
    if ( vstatus_cta in('2','6','7','8') ) then
        let vcodret = "549";
        return  vcodret;
    end if  

	--RQM 09 704.Se agregan la variable del saldo inmovilizado. DHG
    select sucursal,producto,imp_int_ccc,imp_sbg_ccc,sdo_retenido,
           sdo_cong, sdo_actual,saldo_sbc,imp_chq_sbg, imp_int_sbg
      into vsuccta,vproducto,vimp_int_ccc,vimp_sbg_ccc,vsdo_retenido,
           vsdo_cong,vsdo_actual,mSaldoSBC,vimp_chq_sbg, vimp_int_sbg
      from sc_maechq
     where empresa = pempresa 
       and cuenta = pcuenta;

    if vsuccta is null then
        let vcodret = "100";
        return vcodret;
    end if

    select iva 
      into vtasaiva
      from bdinteg:si_sucursales
     where empresa = pempresa 
       and sucursal = vsuccta;
       
    if vtasaiva is null then
        let vtasaiva = 0;
    end if;

    select valor 
      into vtasabaseiva
      from bdinteg:si_param
     where empresa = pempresa 
       and cod_param = 47;

    select max(secuencia) 
      into vmaxsec
      from sc_tarjeta
     where empresa = pempresa 
       and cuenta = pcuenta 
       and tipo_tarjeta = "T";

    select num_tarjeta 
      into vnum_tarjeta
      from sc_tarjeta
     where empresa = pempresa 
       and cuenta = pcuenta 
       and secuencia = vmaxsec;

    -- // Cobra interes de linea de credito
	--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
	EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('',vsdo_actual,vsdo_retenido,vsdo_cong,mSaldoSBC,0.00,0.00,0.00,'F',2) INTO cCodRetConsSdo,cMensajeRetConsSdo,vsdo_disp;        	
	--let vsdo_disp = vsdo_actual - vsdo_retenido - vsdo_cong;

    -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
        IF cCodRetConsSdo <> '00000' THEN
            let vcodret = '420';    -- Suma de montos erronea.
            RETURN vcodret;
        END IF;  

    let vnumcgos = 0;
    
    if vimp_int_ccc > 0 and vsdo_disp > 0 then
        let vimpiva = vimp_int_ccc * vtasaiva;
        let vtotcobro  = vimp_int_ccc + vimpiva;
        
        if vsdo_disp >= vtotcobro  then
            let vimpcobro = vimp_int_ccc;
        else
            let vimpcobro = vsdo_disp / (vtasaiva + 1);
            let vimpiva = vsdo_disp - vimpcobro;
            let vtotcobro = vimpcobro + vimpiva;
        end if
        
        select valor 
          into vtransacc
          from sc_param
         where empresa = pempresa 
           and codparam = "tranintccc";
        
        if vtasaiva <> vtasabaseiva then
            select trancivaesp 
              into vtransacc -- tran intccc c/iva al 10%
              from bdinteg:si_transacc
             where empresa = pempresa 
               and numero = vtransacc;
        end if 
        
        let vhora = current hour to fraction;
        
        insert into sc_movdia
        values (0,pfolio_suc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,vhora,vtransacc,vsuccta,vproducto,pempresa,pcuenta," ",0,
                vimpcobro,0,0,0,0," ",vstatus_cta,vsdo_actual," ",vreferencia,0,vnum_tarjeta,"","",vfecha_operacion);
				
		EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,vtransacc,vimpcobro,vfecha_hoy,"C")
		INTO cCodRetIndicador;
                
        let vsdo_actual = vsdo_actual - vimpcobro;
        let vnumcgos = vnumcgos + 1;
        
        if vimpiva > 0 then
            select valor 
              into vtraniva
              from sc_param
             where empresa = pempresa 
               and codparam = "tranivaccc";
               
            if vtasaiva <> vtasabaseiva then
                select trancivaesp 
                  into vtraniva -- tran ivaintccc al 10%
                  from bdinteg:si_transacc
                 where empresa = pempresa 
                   and numero = vtraniva;
            end if 
            
            let vhora = current hour to fraction;
            
            insert into sc_movdia
            values (0,pfolio_suc,psucursal,pusuario,vfecha_hoy,vfecha_hoy, vhora,vtraniva,vsuccta,vproducto,
                    pempresa,pcuenta," ",0,vimpiva,0,0,0,0," ",vstatus_cta,vsdo_actual," ",vreferencia,0,vnum_tarjeta,"","",vfecha_operacion);
                    
            let vnumcgos = vnumcgos + 1;
        end if
        
        let vsdo_actual = vsdo_actual - vimpiva;
        
        update sc_maechq
           set sdo_actual = sdo_actual - vtotcobro,
               imp_int_ccc = imp_int_ccc - vimpcobro,
               imp_cgos_mes = imp_cgos_mes + vtotcobro,
               num_cgos_mes = num_cgos_mes + vnumcgos
         where empresa = pempresa 
           and cuenta = pcuenta;
    end if

    -- // Cobra interes por sobregiro
	--RQM 09 704.Se agrega el valor del saldo inmovilizado en el calculo del saldo disponible. 
	let vsdo_disp = vsdo_actual - vsdo_retenido - vsdo_cong - mSaldoSBC;
    let vnumcgos = 0;
    
    if vimp_int_sbg > 0 and vsdo_disp > 0 then
        let vimpiva = vimp_int_sbg * vtasaiva;
        let vtotcobro  = vimp_int_sbg + vimpiva;
        
        if vsdo_disp >= vtotcobro  then
            let vimpcobro = vimp_int_sbg;
        else
            let vimpcobro = vsdo_disp / (vtasaiva + 1);
            let vimpiva = vsdo_disp - vimpcobro;
            let vtotcobro = vimpcobro + vimpiva;
        end if
        
        select valor 
          into vtransacc
          from sc_param
         where empresa = pempresa 
           and codparam = "tranintsbg";
           
        if vtasaiva <> vtasabaseiva then
            select trancivaesp 
              into vtransacc -- tran intsbg c/iva al 10%
              from bdinteg:si_transacc
             where empresa = pempresa 
               and numero = vtransacc;
        end if 
        
        let vhora = current hour to fraction;
        
        insert into sc_movdia
        values (0,pfolio_suc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,vhora,vtransacc,vsuccta,vproducto,pempresa,pcuenta," ",0,
                vimpcobro,0,0,0,0," ",vstatus_cta,vsdo_actual," ",vreferencia,0,vnum_tarjeta,"","",vfecha_operacion);
				
		EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,vtransacc,vimpcobro,vfecha_hoy,"C")
		INTO cCodRetIndicador;
                
        let vsdo_actual = vsdo_actual - vimpcobro;
        let vnumcgos = vnumcgos + 1;
        
        if vimpiva > 0 then
            select valor 
              into vtraniva
              from sc_param
             where empresa = pempresa 
               and codparam = "tranivasbg";
               
            if vtasaiva <> vtasabaseiva then
                select trancivaesp 
                  into vtraniva  -- tranivasbg al 10%
                  from bdinteg:si_transacc
                 where empresa = pempresa 
                   and numero = vtraniva;
            end if
            
            let vhora = current hour to fraction;
            
            insert into sc_movdia
            values (0,pfolio_suc,psucursal,pusuario,vfecha_hoy,vfecha_hoy, vhora,vtraniva,vsuccta,vproducto,
                    pempresa,pcuenta," ",0,vimpiva,0,0,0,0," ",vstatus_cta,vsdo_actual," ",vreferencia,0,vnum_tarjeta,"","",vfecha_operacion);
                    
            let vnumcgos = vnumcgos + 1;
        end if
        
        let vsdo_actual = vsdo_actual - vimpiva;
        
        update sc_maechq
           set sdo_actual = sdo_actual - vtotcobro,
               imp_int_sbg = imp_int_sbg - vimpcobro,
               imp_cgos_mes = imp_cgos_mes + vtotcobro,
               num_cgos_mes = num_cgos_mes + vnumcgos
         where empresa = pempresa 
           and cuenta = pcuenta;
    end if

    -- // Cobra comisiones pendientes
	--RQM 09 704.Se agrega el valor del saldo inmovilizado en el calculo del saldo disponible. 
    let vsdo_disp = vsdo_actual - vsdo_retenido - vsdo_cong - mSaldoSBC;
    
    if vsdo_disp > 0 then
        foreach
            select dc.rowid,monto_com-pago_com,transacc_com,transacc_iva
              into vrowid,vsdo_comision,vtransacc,vtraniva
              from sc_detcomis dc, sc_comisiones co
             where dc.empresa = pempresa 
               and cuenta = pcuenta 
               and estado_com = "P" 
               and dc.empresa = co.empresa 
               and dc.comision = co.comision
               
            let vnumcgos = 0;
            
			--RQM 09 704.Se agrega el valor del saldo inmovilizado en el calculo del saldo disponible. 
            select sdo_actual,sdo_retenido,sdo_cong,saldo_sbc
              into vsdo_actual,vsdo_retenido,vsdo_cong,mSaldoSBC
              from sc_maechq
             where empresa = pempresa 
               and cuenta = pcuenta;
               
			--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
			EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('',vsdo_actual,vsdo_retenido,vsdo_cong,mSaldoSBC,0.00,0.00,0.00,'F',2) INTO cCodRetConsSdo,cMensajeRetConsSdo,vsdo_disp;        	

            -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
            IF cCodRetConsSdo <> '00000' THEN
                let vcodret = '420';    -- Suma de montos erronea.
                RETURN vcodret;
            END IF;  

            if vsdo_comision > 0 and vsdo_disp > 0 then
                let vimpiva = vsdo_comision * vtasaiva;
                let vtotcobro  = vsdo_comision + vimpiva;
                
                if vsdo_disp >= vtotcobro  then
                    let vimpcobro = vsdo_comision;
                    let vestado_com = "A";
                else
                    let vimpcobro = vsdo_disp / (vtasaiva + 1);
                    let vimpiva = vsdo_disp - vimpcobro;
                    let vtotcobro = vimpcobro + vimpiva;
                    let vestado_com = "P";
                end if
                
                let vhora = current hour to fraction;
                
                if vtasaiva <> vtasabaseiva then
                    select trancivaesp 
                      into vtransacc -- tran comision al 10%
                      from bdinteg:si_transacc
                     where empresa = pempresa 
                       and numero = vtransacc;
                    
                    select trancivaesp 
                      into vtraniva -- tran ivacom al 10%
                      from bdinteg:si_transacc
                     where empresa = pempresa 
                       and numero = vtraniva;
                end if
                
                insert into sc_movdia
                values (0,pfolio_suc,psucursal,pusuario,vfecha_hoy,vfecha_hoy, vhora,vtransacc,vsuccta,vproducto,
                        pempresa,pcuenta," ",0,vimpcobro,0,0,0,0," ",vstatus_cta,vsdo_actual," ",vreferencia,0,vnum_tarjeta,"","",vfecha_operacion);
                        
                let vsdo_actual = vsdo_actual - vimpcobro;
                let vnumcgos = vnumcgos + 1;
                
                if vimpiva > 0 then
                    let vhora = current hour to fraction;
                    
                    insert into sc_movdia
                    values (0,pfolio_suc,psucursal,pusuario,vfecha_hoy,vfecha_hoy, vhora,vtraniva,vsuccta,vproducto,pempresa,
                            pcuenta," ",0,vimpiva,0,0,0,0," ",vstatus_cta,vsdo_actual," ",vreferencia,0,vnum_tarjeta,"","",vfecha_operacion);
                        
                    let vnumcgos = vnumcgos + 1;
                end if
                
                let vsdo_actual = vsdo_actual - vimpiva;
                
                update sc_maechq
                   set sdo_actual = sdo_actual - vtotcobro,
                       com_pendiente = com_pendiente - vimpcobro,
                       imp_cgos_mes = imp_cgos_mes + vtotcobro,
                       num_cgos_mes = num_cgos_mes + vnumcgos
                 where empresa = pempresa 
                   and cuenta = pcuenta;
                   
                update sc_detcomis
                   set pago_com = pago_com + vimpcobro,
                       fecult_pago = vfecha_hoy,
                       estado_com = vestado_com
                 where rowid = vrowid;
            end if
        end foreach
    end if

    -- // Cobra linea de credito
	--RQM 09 704.Se agrega el valor del saldo inmovilizado en el calculo del saldo disponible. 
	let vsdo_disp = vsdo_actual - vsdo_retenido - vsdo_cong - mSaldoSBC;
    
    if vimp_sbg_ccc > 0 and vsdo_disp > 0 then
        let vtotcobro  = vimp_sbg_ccc;
        
        if vsdo_disp >= vtotcobro  then
            let vimpcobro = vimp_sbg_ccc;
        else
            let vimpcobro = vsdo_disp;
            let vimpiva = vsdo_disp - vimpcobro;
            let vtotcobro = vimpcobro;
        end if
        
        select valor 
          into vtransacc
          from sc_param
         where empresa = pempresa 
           and codparam = "tranpagoccc";
           
        let vhora = current hour to fraction;
        
        insert into sc_movdia
        values (0,pfolio_suc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,vhora,vtransacc,vsuccta,vproducto,pempresa,pcuenta," ",0,
                vimpcobro,0,0,0,0," ",vstatus_cta,vsdo_actual," ",vreferencia,0,vnum_tarjeta,"","",vfecha_operacion);
				
		EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,vtransacc,vimpcobro,vfecha_hoy,"C")
		INTO cCodRetIndicador;
                
        let vsdo_actual = vsdo_actual - vimpcobro;
        
        update sc_maechq
           set sdo_actual = sdo_actual - vtotcobro,
               imp_sbg_ccc = imp_sbg_ccc - vimpcobro,
               imp_cgos_mes = imp_cgos_mes + vtotcobro,
               num_cgos_mes = num_cgos_mes + 1
         where empresa = pempresa 
           and cuenta = pcuenta;
    end if

    -- // Cobra sobregiro
	--RQM 09 704.Se agrega el valor del saldo inmovilizado en el calculo del saldo disponible. 
	let vsdo_disp = vsdo_actual - vsdo_retenido - vsdo_cong - mSaldoSBC;
    
    if vimp_chq_sbg > 0 and vsdo_disp > 0 then
        let vimpiva = vimp_chq_sbg;
        let vtotcobro  = vimp_chq_sbg;
        
        if vsdo_disp >= vtotcobro  then
            let vimpcobro = vimp_chq_sbg;
        else
            let vimpcobro = vsdo_disp;
            let vimpiva = vsdo_disp - vimpcobro;
            let vtotcobro = vimpcobro;
        end if
        
        select valor 
          into vtransacc
          from sc_param
         where empresa = pempresa 
           and codparam = "tranpagosbg";
           
        let vhora = current hour to fraction;
        
        insert into sc_movdia
        values (0,pfolio_suc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,vhora,vtransacc,vsuccta,vproducto,pempresa,pcuenta," ",0,
                vimpcobro,0,0,0,0," ",vstatus_cta,vsdo_actual," ",vreferencia,0,vnum_tarjeta,"","",vfecha_operacion);
				
		EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,vtransacc,vimpcobro,vfecha_hoy,"C")
		INTO cCodRetIndicador;
                
        let vsdo_actual = vsdo_actual - vimpcobro;
        
        update sc_maechq
           set sdo_actual = sdo_actual - vtotcobro,
               imp_chq_sbg = imp_chq_sbg - vimpcobro,
               imp_cgos_mes = imp_cgos_mes + vtotcobro,
               num_cgos_mes = num_cgos_mes + 1
         where empresa = pempresa 
           and cuenta = pcuenta;
    end if
    
    return vcodret;
    
    end;
    
end procedure
DOCUMENT
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 11-06-2025',
'MODIFICACION: Se modifican las formulas de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.2',
'MODIFICO:         Donovan Fernando Torres Landeros',
'FECHA:            10-02-2026',
'MODIFICACION:     Se agrega la validacion del codigo de retorno no exitoso(diferente de 00000)', 
'PROYECTO:         RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:               BDICHEQ',
'VERSION:          1.3';

create procedure "informix".cobracom(pempresa   char(3),
                                      psucursal  char(4),
                                      pusuario   char(8),
                                      ptransacc  char(4),
                                      pfolio_suc char(16),
                                      pcuenta    char(20))
   returning char(5);

   define vcodret char(5);
   define vsqlerr integer;
   define vfecha_hoy date;
   define vsdodisp money(14,2);
   define vstatus_cta char(1);
   --RQM 09 704. Se agregan las siguientes variable DFTL 
   define mSdoActual      money(14,2);
   define mSdoRetenido        money(14,2);
   define mSdoCongelado       money(14,2);
   define mSaldoSbc       MONEY(14,2);
   define cCodRetConsSdo       CHAR(5); --Codigo de retorno de SP de consulta de saldo.
   define cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.


   let vcodret = "000";
   --RQM 09 704. Se agregan las siguientes variable DFTL
   let mSdoActual         = 0;
   let mSdoRetenido           = 0;
   let mSdoCongelado          = 0;
   let mSaldoSbc           = 0;
   let cCodRetConsSdo      = '00000';
   let cMensajeRetConsSdo  = '';

   --SET DEBUG FILE TO "/home/c90402536/Traza/cobracom_modif.out";
   --TRACE ON; 

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret;
      end if
   end exception;

   select fecha_hoy into vfecha_hoy
      from sc_fechas where empresa = pempresa;

   select status_cta, sdo_actual, sdo_retenido, sdo_cong, saldo_sbc
      into vstatus_cta, mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc
      from sc_maechq
      where empresa = pempresa and cuenta = pcuenta;

   --RQM 09 704. Se executa el siguiente SP para el calculo del saldo disponible DFTL 
   EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc, null, null, null, 'F', '2') 
   INTO cCodRetConsSdo, cMensajeRetConsSdo, vsdodisp; 
   
   -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
      IF cCodRetConsSdo <> '00000' THEN
         let vcodret = '420';    -- Suma de montos erronea.
         RETURN vcodret;
      END IF;  

   if vstatus_cta is null then
      let vcodret = "100";
      return vcodret;
   end if;

   if vstatus_cta in("2","6","7") then
      let vcodret = "200";
      return vcodret;
   end if;

   call gencomtran(pempresa,pcuenta,ptransacc,pfolio_suc,0,
                   psucursal,pusuario) returning vcodret;

   if vcodret = "000" and vsdodisp > 0 then
      call cobintcomsbg(pempresa,pcuenta,pfolio_suc,pusuario,psucursal)
                        returning vcodret;
   end if
   return vcodret;
end;
end procedure
DOCUMENT
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/06/16',
'RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO: RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.2',
'MODIFIC0:              Donovan F. Torres Landeros',
'FECHA:                 10-02-2026',
'MODIFICACION:          Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'                       cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:              RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.3';

create procedure "informix".consultmovs_bf1(pempresa   char(3),
                                            pcuenta    char(20),
                                            psecuencia smallint)

returning char(5),date,char(40),money(14,2),money(14,2),money(14,2);

    define vtransacc        char(40);
    define vfecha           date;
    define vmonto           money(14,2);
    define vsdoactual       money(14,2);
    define vsdodisp         money(14,2);
    define vserial          integer;
    define vconta           smallint;
    define vciclo           smallint;
    define vcodret          char(5);
    define vsqlerr          integer;
    define vnaturaleza      char(1);
    define vultmovto        smallint;
    define cFech_param      CHAR(10);
    define cFech_param_ini  CHAR(10);
    --RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
	  define cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	  define cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
	  --RQM 09 704. Se agregan las variables para la consulta de los campos en la maestra de cheques. EEAP.
    define mSdoRetenido  money(14,2);
    define mSdoCong      money(14,2);
    define mSaldoSbc     money(14,2);

    let vcodret    = "000";
    let vtransacc  = " ";
    let vfecha     = " ";
    let vmonto     = 0;
    let vsdoactual = 0;
    let vsdodisp   = 0;
    let vciclo     = 0;
    let vultmovto  = 5;
    --RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
	  let cCodRetConsSdo		= '00000';
	  let cMensajeRetConsSdo	= '';
	  --RQM 09 704. Se inicializan las variables los campos retornados de la maestra de cheques. EEAP.
    let mSdoRetenido  = 0.00;
    let mSdoCong      = 0.00;
    let mSaldoSbc     = 0.00;		

    begin
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp;
        end if;
    end exception;
    
    SET ISOLATION TO DIRTY READ;

    --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
    select mc.sdo_actual, mc.sdo_retenido, mc.sdo_cong, mc.saldo_sbc
      into vsdoactual, mSdoRetenido, mSdoCong, mSaldoSbc
      from sc_maechq mc
     where mc.empresa = pempresa 
       and mc.cuenta = pcuenta;
    
    --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
    EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', vsdoactual, mSdoRetenido, mSdoCong, mSaldoSbc, null, null, null, 'F', 2) 
    INTO cCodRetConsSdo,cMensajeRetConsSdo,vsdodisp;

    -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
    IF cCodRetConsSdo <> '00000' THEN
        let vsdoactual = 0;
        let vsdodisp = 0;
        let vcodret = '420';    -- Suma de montos erronea.
        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp;
    END IF;  
       
    if vsdoactual is null then
        let vsdoactual = 0;
        let vsdodisp = 0;
        let vcodret = "100";
        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp;
    end if;
    
    -- // Extrae los ultimos 5 movimientos
    foreach
        select md.fech_alt, md.num_serial, md.monto_tot, md.transacc||" "||tr.descripcion, tr.naturaleza
          into vfecha, vserial, vmonto, vtransacc, vnaturaleza
          from sc_movdia md,
               bdinteg:si_transacc tr
         where md.empresa = pempresa 
           and md.cuenta = pcuenta 
           and md.cancelad not in("V","S") 
           and tr.empresa = md.empresa 
           and tr.numero = md.transacc 
           and tr.se_emite_edocta = "S"
         order by fech_alt desc, num_serial desc
         
        let vciclo = vciclo + 1;
        
        if vciclo > vultmovto then
            exit foreach;
        end if;
        
        if vmonto < 0 then
            let vtransacc = "REV "||trim(vtransacc);
        end if;
        
        if vnaturaleza = "C" then
            let vmonto = (vmonto * (-1));
        end if;
        
        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp with resume;
    end foreach;
    
    SELECT valor
      INTO cFech_param
      FROM bdicheq:sc_param
     WHERE empresa = pempresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor
      INTO cFech_param_ini
      FROM bdicheq:sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechIniCon_movhis_ol';
    
    foreach
        select {+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
               md.fech_alt, md.num_serial, md.monto_tot, md.transacc||" "||tr.descripcion, tr.naturaleza
          into vfecha,vserial,vmonto,vtransacc,vnaturaleza
          from sc_movhis md,
               bdinteg:si_transacc tr
         where md.empresa = pempresa 
           and md.cuenta = pcuenta 
           and md.fech_alt >= cFech_param
           and md.cancelad not in("V","S") 
           and md.transacc = tr.numero
           and tr.empresa = md.empresa 
           and tr.numero = md.transacc 
           and tr.se_emite_edocta = "S"
        union all
        select {+INDEX(bdicheq:sc_movhis_old movhis1)}
               md.fech_alt, md.num_serial, md.monto_tot, md.transacc||" "||tr.descripcion, tr.naturaleza
          from sc_movhis_old md,
               bdinteg:si_transacc tr
         where md.empresa = pempresa 
           and md.cuenta = pcuenta 
           and md.fech_alt >= cFech_param_ini
           and md.fech_alt < cFech_param
           and md.cancelad not in("V","S") 
           and md.transacc = tr.numero
           and tr.empresa = md.empresa 
           and tr.numero = md.transacc 
           and tr.se_emite_edocta = "S"
         order by md.fech_alt desc, md.num_serial desc
         
        let vciclo = vciclo + 1;
        
        if vciclo > vultmovto then
            exit foreach;
        end if;
        
        if vmonto < 0 then
            let vtransacc = "REV "||trim(vtransacc);
        end if;
        
        if vnaturaleza = "C" then
            let vmonto = (vmonto * (-1));
        end if;
        
        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp with resume;
    end foreach;
    
    end;
    
end procedure

DOCUMENT
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 09-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2',
'MODIFIC0:      Donovan F. Torres Landeros',
'FECHA:         10-02-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.3';

CREATE PROCEDURE "informix".sp_cobrosbg(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vfecha           DATE;
    DEFINE vhora            CHAR(15);
    DEFINE vfolio           CHAR(16);
    DEFINE vcuenta          CHAR(20);
    DEFINE vsucursal        CHAR(4);  
    DEFINE vproducto        CHAR(4);
    DEFINE vsuc_cta         CHAR(4);
    DEFINE vsdo_actual      MONEY(18,2);    
    DEFINE vsdo_retenido    MONEY(18,2);    
    DEFINE vsdo_cong        MONEY(18,2);    
    DEFINE vimp_chq_sbg     MONEY(18,2);    
    DEFINE vsdo_disp        MONEY(18,2);
	DEFINE cCodRetIndicador	CHAR(6);
    DEFINE vstatus_cta      CHAR(1);
	DEFINE vfecha_operacion DATE;
	--RQM 09 704. Se agregan las variables para el llamado y retorno de consulta de saldo. DHG.
	DEFINE mSaldoSBC			MONEY(14,2); --Monto del saldo invomilizado (Salvo Buen Cobro).
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    
    LET vcodret1	 = '000';
    LET vcodret2     = '000';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET vcomienza    = -1;
    LET ven_transacc = 0;
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vfecha  = '';
    LET vhora   = '';
    LET vfolio  = '';
    LET vcuenta       = '';
    LET vsucursal     = '9250';
    LET vproducto     = '';
    LEt vsuc_cta      = '';
    LET vsdo_actual   = 0.00;
    LET vsdo_retenido = 0.00;
    LET vsdo_cong     = 0.00;
    LET vimp_chq_sbg  = 0.00;
    LET vsdo_disp     = 0.00;
	LET cCodRetIndicador  = "000000";
    LET vstatus_cta = '';
	LET vfecha_operacion = TODAY;
	--RQM 09 704. Se inicializan las variables para el llamado y retorno de consulta de saldo. DHG.
	LET mSaldoSBC			= 0.00;
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cobrosbg.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cobrosbg.out";
    --- TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vfecha
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio = 'informix'||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    FOREACH WITH HOLD
	--RQM 09 704.Se agrega la variable del saldo inmovilizado para el calculo del saldo disponible.DHG
        SELECT cuenta, producto, sucursal, sdo_actual, sdo_retenido, sdo_cong, saldo_sbc, imp_chq_sbg, status_cta
          INTO vcuenta, vproducto, vsuc_cta, vsdo_actual, vsdo_retenido, vsdo_cong , mSaldoSBC, vimp_chq_sbg, vstatus_cta
          FROM sc_maechq
         WHERE status_cta NOT IN('2','6','7','8')
           AND imp_chq_sbg > 0.00
        
        IF (vcomienza = -1) THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
		--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
		EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('',vsdo_actual,vsdo_retenido,vsdo_cong,mSaldoSBC,0.00,0.00,0.00,'F',2) INTO cCodRetConsSdo,cMensajeRetConsSdo,vsdo_disp;
        --LET vsdo_disp = vsdo_actual - (vsdo_retenido + vsdo_cong);
        
		-- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
      	IF cCodRetConsSdo <> '00000' THEN
        	let vsdo_disp = 0;
            let vcodret1 = '420';    -- Suma de montos erronea.
            CONTINUE FOREACH;
      	END IF;  

        IF vsdo_disp > 0.00 THEN
        
            IF vsdo_disp >= vimp_chq_sbg THEN

                INSERT INTO sc_movdia VALUES
                ( 0, vfolio, vsucursal, "informix", vfecha, vfecha, vhora, '3247', vsuc_cta, vproducto, pempresa, vcuenta, 
                  " ", 0, vimp_chq_sbg, 0, 0, 0, 0, " ", vstatus_cta, vsdo_actual, '0000', "COBRO PENDIENTE DE SOBREGIRO", 0, " ", "informix", "", vfecha_operacion);
                  
                IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                    IF ven_transacc = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    CONTINUE FOREACH;
                END IF;
				
				-- LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
				EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(vsucursal,vcuenta,"3247",vimp_chq_sbg,vfecha,"C")
				INTO cCodRetIndicador;
                
                UPDATE sc_maechq
                   SET sdo_actual  = sdo_actual - vimp_chq_sbg,
                       imp_chq_sbg = 0.00
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;
                
            ELIF vsdo_disp < vimp_chq_sbg THEN
            
                INSERT INTO sc_movdia VALUES
                ( 0, vfolio, vsucursal, "informix", vfecha, vfecha, vhora, '3247', vsuc_cta, vproducto, pempresa, vcuenta, 
                  " ", 0, vsdo_disp, 0, 0, 0, 0, " ", vstatus_cta, vsdo_actual, '0000', "COBRO PENDIENTE DE SOBREGIRO", 0, " ", "informix" , "", vfecha_operacion);
                  
                IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                    IF ven_transacc = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    CONTINUE FOREACH;
                END IF;
				
				-- LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
				EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(vsucursal,vcuenta,"3247",vsdo_disp,vfecha,"C")
				INTO cCodRetIndicador;
                
                UPDATE sc_maechq
                   SET sdo_actual  = sdo_actual - vsdo_disp,
                       imp_chq_sbg = imp_chq_sbg - vsdo_disp
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;
                
            END IF;
        
            LET vcontador2 = vcontador2 + 1;
            
        END IF;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vcuenta       = '';
        LET vproducto     = '';
        LEt vsuc_cta      = '';
        LET vsdo_actual   = 0.00;
        LET vsdo_retenido = 0.00;
        LET vsdo_cong     = 0.00;
        LET vimp_chq_sbg  = 0.00;
        LET vsdo_disp     = 0.00;
        LET vstatus_cta   = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE
DOCUMENT
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 11-06-2025',
'MODIFICACION: Se modifica la forma de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.2',
'MODIFICO: Donovan Fernando Torres Landeros',
'FECHA: 09-09-2025',
'MODIFICACION: Se agrega la validacion del codigo de retorno no exitoso(diferente de 00000)', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.3',
'MODIFIC0:      Donovan F. Torres Landeros',
'FECHA:         10-02-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.4';

CREATE PROCEDURE "informix".sp_corrige_isr( pEmpresa CHAR(3), pFecha DATE ) 
RETURNING CHAR(5), INTEGER, INTEGER;
    
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iTransacc        SMALLINT;
    DEFINE iContador1       INTEGER;
    DEFINE iContador2       INTEGER;
    DEFINE dFechaHoy        DATE;
    DEFINE iAnio            INTEGER;
    DEFINE iResiduo         INTEGER;
    DEFINE iAnioBase        INTEGER;
    DEFINE dTasaISR         DECIMAL(9,6);
    DEFINE dTasa_ISR        DECIMAL(9,6);
    DEFINE cCuenta          CHAR(20);
    DEFINE cProducto        CHAR(4);
    DEFINE mSdoAcum         DECIMAL(18,2);
    DEFINE iDias            SMALLINT;
    DEFINE mIsrCobrado      DECIMAL(18,2);
    DEFINE mSdoPromedio     DECIMAL(18,2);
    DEFINE mBaseExenta      DECIMAL(18,2);
    DEFINE mBaseGravable    DECIMAL(18,2);
    DEFINE mISRCalculado    DECIMAL(14,2);
    DEFINE mDiferenciaISR   DECIMAL(14,2);
    DEFINE cHora            CHAR(15);
    DEFINE cFolio           CHAR(16);
    DEFINE cSucursal        CHAR(4);
    DEFINE cStatusCta       CHAR(1);
    DEFINE cMotivo          CHAR(2);
    DEFINE mSdoActual       DECIMAL(14,2);
    DEFINE mSdoRetenido     DECIMAL(14,2);
    DEFINE mSdoCongelado    DECIMAL(14,2);
    DEFINE mImpChqSbg       DECIMAL(14,2);
    DEFINE mSdoDisponible   DECIMAL(14,2);
    --RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
    DEFINE cCodRetConsSdo   CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    --RQM 09 704. Se agrega la variable mSaldoSbc para la consulta del campo en la maestra de cheques. EEAP.
    DEFINE mSaldoSbc            MONEY(14,2);
    
    LET cCodRet1        = '000';
    LET cCodRet2        = '';
    LET cCodRet3        = '';
    LET iSqlErr         = 0;
    LET iSamErr         = 0;
    LET cDesErr         = '';
    LET iTransacc       = 0;
    LET iContador1      = 0;
    LET iContador2      = 0;
    LET dFechaHoy       = '01/01/1900';
    LET iAnio           = 0;
    LET iResiduo        = 0;
    LET iAnioBase       = 0;
    LET dTasaISR        = 0.000000;
    LET dTasa_ISR       = 0.000000;
    LET cCuenta         = '';
    LET cProducto       = '';
    LET mSdoAcum        = 0.00;
    LET iDias           = 0;
    LET mIsrCobrado     = 0.00;
    LET mSdoPromedio    = 0.00;
    LET mBaseExenta     = 0.00;
    LET mBaseGravable   = 0.00;
    LET mISRCalculado   = 0.00;
    LET mDiferenciaISR  = 0.00;
    LET cHora           = '';
    LET cFolio          = '';
    LET cSucursal       = '';
    LET cStatusCta      = '';
    LET cMotivo         = '';
    LET mSdoActual      = 0.00;
    LET mSdoRetenido    = 0.00;
    LET mSdoCongelado   = 0.00;
    LET mImpChqSbg      = 0.00;
    LET mSdoDisponible  = 0.00;
    --RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
    LET cCodRetConsSdo    = '00000';
    LET cMensajeRetConsSdo  = '';
    --RQM 09 704. Se inicializa la variable mSaldoSbc para el campo retornado de la maestra de cheques. EEAP.
    LET mSaldoSbc           = 0.00;
  
  BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrige_isr.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            IF iTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet1, iContador1, iContador2;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrige_isr.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO dFechaHoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
    
    SELECT valor 
    INTO mBaseExenta
      FROM sc_param
   WHERE empresa = pempresa 
     AND codparam = "baseexenta"; 

  IF mBaseExenta is null THEN
    LET mBaseExenta = 0;
  END IF;
       
    LET iAnio = YEAR(pFecha);
    LET iResiduo = MOD(iAnio,4);
    
    IF iResiduo <> 0 THEN
        LET iAnioBase = 365;
    ELSE
        LET iAnioBase = 366;
    END IF;
    
    SELECT valor
      INTO dTasaISR
      FROM bdinteg:si_fechavalor
     WHERE empresa = pEmpresa 
       AND tasa = "I.S.R." 
       AND fecha = ( SELECT MAX(fecha) 
                       FROM bdinteg:si_fechavalor
                      WHERE empresa = pEmpresa 
                        AND tasa = "I.S.R."
                        AND fecha < pFecha );
                        
    LET cHora = CURRENT HOUR TO FRACTION;
    LET cFolio = 'informix'||cHora[1,2]||cHora[4,5]||cHora[7,8]||cHora[10,11];
    
    FOREACH WITH HOLD
        --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
        SELECT {+INDEX(sc_maehis maehis_ffin)}
               his.cuenta, his.producto, his.acum_sdo_pos, his.dia_sdo_pos, his.totisrcobrado,
               mae.sucursal, mae.status_cta, mae.motivo, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, mae.saldo_sbc
          INTO cCuenta, cProducto,  mSdoAcum, iDias, mIsrCobrado,
               cSucursal, cStatusCta, cMotivo, mSdoActual, mSdoRetenido, mSdoCongelado, mImpChqSbg, mSaldoSbc
          FROM sc_maehis his,
               sc_maechq mae
         WHERE his.fechafin = pFecha
           AND his.cuenta = mae.cuenta
           AND his.totisrcobrado <> 0.00
           AND his.producto <> '1200'
           AND mae.cuenta NOT IN(SELECT cuenta FROM sc_movdia WHERE transacc = '3277')
           --- AND mae.status_cta in('1','3','4','5')
        
        BEGIN WORK;
        
        LET iTransacc = 1;
               
        LET mSdoPromedio = mSdoAcum / iDias;
        
        LET mBaseGravable = mSdoPromedio - mBaseExenta;
        
        LET dTasa_ISR = TRUNC( ( ( ( dTasaISR / 100 ) * iDias ) / iAnioBase ), 6 );
        
        --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
        EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc, mImpChqSbg, null, null, 'F', 1) INTO cCodRetConsSdo,cMensajeRetConsSdo,mSdoDisponible;
    
    -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
        IF cCodRetConsSdo <> '00000' THEN
          ROLLBACK WORK; 
          LET iTransacc = 0;  
          CONTINUE FOREACH;
        END IF;  


        IF mBaseGravable > 0 THEN
        
            LET mISRCalculado = TRUNC( (mBaseGravable * dTasa_ISR ), 2);
            
            LET mDiferenciaISR = mISRCalculado - mIsrCobrado;
        
            IF ( mDiferenciaISR > 0 AND cStatusCta IN('1','4','5') AND ( mSdoDisponible >= mDiferenciaISR ) ) THEN
                INSERT INTO sc_movdia VALUES
                ( 0, cFolio, cSucursal, 'informix', dFechaHoy, dFechaHoy, current, '3277', cSucursal, cProducto, pEmpresa, cCuenta, '', 
                  0, mDiferenciaISR, mDiferenciaISR, 0.00, 0.00, 0, '', cStatusCta, mSdoActual, '0000', '', 0, '', '', '', dFechaHoy );
                  
                UPDATE sc_maechq
                   SET sdo_actual = sdo_actual - mDiferenciaISR,
                       imp_cgos_mes = imp_cgos_mes + mDiferenciaISR,
                       num_cgos_mes = num_cgos_mes + 1
                 WHERE cuenta = cCuenta;   
                
                LET iContador2 = iContador2 + 1;
            END IF;
            
            UPDATE sc_maehis
               SET totisrcobrado = mIsrCobrado + mDiferenciaISR
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND fechafin = pFecha;
            
        ELIF mBaseGravable < 0 THEN
            
            LET mDiferenciaISR = mIsrCobrado;
            
            IF ( mDiferenciaISR > 0 AND cStatusCta IN('1','4','5') ) THEN
                INSERT INTO sc_movdia VALUES
                ( 0, cFolio, cSucursal, 'informix', dFechaHoy, dFechaHoy, current, '0242', cSucursal, cProducto, pEmpresa, cCuenta, '', 
                  0, mDiferenciaISR, mDiferenciaISR, 0.00, 0.00, 0, '', cStatusCta, mSdoActual, '0000', '', 0, '', '', '', dFechaHoy );
                  
                UPDATE sc_maechq
                   SET sdo_actual = sdo_actual + mDiferenciaISR,
                       imp_abonos_mes = imp_abonos_mes + mDiferenciaISR,
                       num_abonos_mes = num_abonos_mes + 1
                 WHERE cuenta = cCuenta;   
                
                LET iContador2 = iContador2 + 1;
            END IF;
            
            UPDATE sc_maehis
               SET totisrcobrado = mIsrCobrado - mDiferenciaISR
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND fechafin = pFecha;
            
        END IF;
        
        LET iContador1 = iContador1 + 1;
        
        COMMIT WORK;
        
        LET iTransacc = 0;
        
        LET cCuenta         = '';
        LET cProducto       = '';
        LET mSdoAcum        = 0.00;
        LET iDias           = 0;
        LET mIsrCobrado     = 0.00;
        LET cSucursal       = '';
        LET cStatusCta      = '';
        LET cMotivo         = '';
        LET mSdoActual      = 0.00;
        LET mSdoRetenido    = 0.00;
        LET mSdoCongelado   = 0.00;
        LET mImpChqSbg      = 0.00;
        LET mSdoPromedio    = 0.00;
        LET mBaseGravable   = 0.00;
        LET dTasa_ISR       = 0.000000;
        LET mSdoDisponible  = 0.00;
        LET mISRCalculado   = 0.00;
        LET mDiferenciaISR  = 0.00;
    END FOREACH;
    
    END;
    
    RETURN cCodRet1, iContador1, iContador2;
    
END PROCEDURE

DOCUMENT 
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 01-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2',
'MODIFIC0:      Donovan F. Torres Landeros',
'FECHA:         10-02-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.3';

CREATE PROCEDURE "informix".sp_marcactasinactivas_3anios( pEmpresa char(3) )
RETURNING CHAR(5)  AS vCodRet1, 
          CHAR(5)  AS vCodRet2, 
          CHAR(50) AS vCodRet3, 
          INTEGER  AS vContador1, 
          INTEGER  AS vContador2,  
          INTEGER  AS vContador3,
          INTEGER  AS vContador4;
      
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vComienza        INTEGER;
    DEFINE vEnTransacc     SMALLINT;
    DEFINE vContador1       INTEGER;
    DEFINE vContador2       INTEGER;
    DEFINE vContador3       INTEGER;
    DEFINE vContador4       INTEGER;
    
    DEFINE vSql                 CHAR(500);
    DEFINE vStmt                CHAR(250);
    DEFINE vFechaHoy            DATE;
    DEFINE vDiasInformada       INTEGER;
    DEFINE vDiasConcentrada     INTEGER;
    DEFINE vDiasTraspasada      INTEGER;
    DEFINE vTrxCargoConcen      CHAR(4);
    DEFINE vTrxCargoTrasp       CHAR(4);
    DEFINE vTrxAbonoConcen      CHAR(4);
    DEFINE vCtaConcentradora    CHAR(20);
    DEFINE vCtaMinima           CHAR(20);
    DEFINE vCtaMaxima           CHAR(20);
    DEFINE vCuenta              CHAR(20);
    DEFINE vStatusCta           CHAR(1);
    DEFINE vSucursal            CHAR(4);
    DEFINE vSdoActual           DECIMAL(18,2);
    DEFINE vSdoRetenido         DECIMAL(18,2);
    DEFINE vSdoCongelado        DECIMAL(18,2);
    DEFINE vSdoSobregirado      DECIMAL(18,2);
    DEFINE vSdoDispCuenta       DECIMAL(18,2);
    DEFINE vFechaUltimoDep      DATE;
    DEFINE vFechaUltimoRet      DATE;
    DEFINE vFechaAlta           DATE;
    DEFINE vFechaCompara        DATE;
    DEFINE vDiasSinTransacc     INTEGER;
    DEFINE vHora                CHAR(15);
    DEFINE vFolio               CHAR(16);
    DEFINE vCodRetCargo         CHAR(5);
    DEFINE vCodRetAbono         CHAR(5);
    DEFINE vTransaccRetCargo    CHAR(4);
    DEFINE vFechaRetCargo       DATE;
    DEFINE vSdoDispCargo        DECIMAL(18,2);
    DEFINE vMontoRetCargo       DECIMAL(18,2);
    DEFINE vNomProducto         CHAR(40);
    DEFINE vNumCliente          CHAR(20);
    DEFINE vNumTarjeta          CHAR(16);
    DEFINE vNombreCliente       CHAR(104);
    
    -- RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. LEOC.
    DEFINE cCodRetConsSdo               CHAR(5);    -- Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo           CHAR(50);   -- Mensaje de retorno de SP de consulta de saldo.
    DEFINE mSaldoSbc                    MONEY(14,2);    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '000';
    LET vCodRet2     = '000';
    LET vCodRet3     = '';
    LET vComienza    = -1;
    LET vEnTransacc = 0;
    LET vContador1   = 0;
    LET vContador2   = 0;
    LET vContador3   = 0;
    LET vContador4   = 0;
    
    LET vSql              = '';
    LET vStmt             = '';
    LET vFechaHoy         = '';
    LET vDiasInformada    = 0;
    LET vDiasConcentrada  = 0;
    LET vDiasTraspasada   = 0;
    LET vTrxCargoConcen   = '';
    LET vTrxCargoTrasp    = '';
    LET vTrxAbonoConcen   = '';
    LET vCtaConcentradora = '';
    LET vCtaMinima        = '';
    LET vCtaMaxima        = '';
    LET vCuenta           = '';   
    LET vStatusCta        = '';
    LET vSucursal         = '';
    LET vSdoActual        = 0.00;
    LET vSdoRetenido      = 0.00;
    LET vSdoCongelado     = 0.00;
    LET vSdoSobregirado   = 0.00;
    LET vSdoDispCuenta    = 0.00;
    LET vFechaUltimoDep   = '';
    LET vFechaUltimoRet   = '';
    LET vFechaAlta        = '';
    LET vFechaCompara     = '';
    LET vDiasSinTransacc  = 0;
    LET vHora             = '';
    LET vFolio            = '';
    LET vCodRetCargo      = '';
    LET vCodRetAbono      = '';
    LET vTransaccRetCargo = '';
    LET vFechaRetCargo    = '';
    LET vSdoDispCargo     = 0.00;
    LET vMontoRetCargo    = 0.00;
    LET vNomProducto      = '';
    LET vNumCliente       = '';
    LET vNumTarjeta       = '';
    LET vNombreCliente    = '';

    -- RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. LEOC.
    LET cCodRetConsSdo      = '00000';
    LET cMensajeRetConsSdo  = '';
    LET mSaldoSbc           =0.00;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_marcactasinactivas_3anios.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2, vContador3, vContador4;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_marcactasinactivas_3anios.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctasinactivas3anios') THEN
        DROP TABLE "informix".ctasinactivas3anios;
    END IF;
    
    CREATE TABLE "informix".ctasinactivas3anios
      (
        cuenta char(20) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctainact ON "informix".ctasinactivas3anios(cuenta) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE ctasinactivas3anios;
    
    LET vSql = 'echo "LOAD FROM /resplogifx/conciliachq/ctasinactivas3anios.unl DELIMITER ''","'' INSERT INTO ctasinactivas3anios" > /resplogifx/conciliachq/cargactas.sql';
    SYSTEM vSql;
    LET vSql = '';
    
    LET vStmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/cargactas.sql';

    SYSTEM vStmt;
    LET vStmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctasinactivas3anios;
    
    -- // OBTINENE LA FECHA DE HOY
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = pEmpresa;
     
    -- // OBTIENE EL NUMERO DE DIAS INICIALES PARA CUENTAS INFORMADAS
    SELECT valor::INT
      INTO vDiasInformada
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasIniCtaInformada';
    
    -- // OBTIENE EL NUMERO DE DIAS INICIALES PARA CUENTAS CONCENTRADAS
    SELECT valor::INT
      INTO vDiasConcentrada
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasIniCtaConcentrad';
       
    -- // OBTIENE EL NUMERO DE DIAS INICIALES PARA CUENTAS CONCENTRADAS
    SELECT valor::INT
      INTO vDiasTraspasada
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasIniCtaTraspasada';
       
    -- // OBTIENE TRANSACCION PARA CUENTAS CONCENTRADAS
    SELECT valor
      INTO vTrxCargoConcen
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'TrxCgoCtaConcentrada';
       
    -- // OBTIENE TRANSACCION PARA CUENTAS CONCENTRADAS
    SELECT valor
      INTO vTrxCargoTrasp
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'TrxCgoCtaTraspasada';
        
    -- // OBTIENE TRANSACCION PARA CUENTAS CONCENTRADAS
    SELECT valor
      INTO vTrxAbonoConcen
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'TrxAboCtaConcentrada';
       
    -- // OBTIENE LA CUENTA CONCENTRADORA PARA TRASPASOS POR INACTIVIDAD
    SELECT valor
      INTO vCtaConcentradora
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'CtaConcentradorArt61';
       
    -- // OBTIENE EL NUMERO CUENTA MINIMA Y MAXIMA
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vCtaMinima, vCtaMaxima
      FROM ctasinactivas3anios;

    FOREACH WITH HOLD
        SELECT cuenta
          INTO vCuenta
          FROM ctasinactivas3anios
         WHERE cuenta BETWEEN vCtaMinima AND vCtaMaxima
          
        IF vComienza = -1 THEN
            LET vComienza = 0;
            LET vEnTransacc = 1;
            BEGIN WORK;
        END IF;    
        
        LET vContador1 = vContador1 + 1;

        -- // OBTIENE INFORMACION DE LA CUENTA
        SELECT mae.status_cta, mae.sucursal, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, 
               mae.imp_chq_sbg, mae.fecultdep, mae.fecultret, noc.fecha_alta, pro.nombre, mae.num_cte, mae.saldo_sbc
          INTO vStatusCta, vSucursal, vSdoActual, vSdoRetenido, vSdoCongelado, 
               vSdoSobregirado, vFechaUltimoDep, vFechaUltimoRet, vFechaAlta, vNomProducto, vNumCliente, mSaldoSbc
          FROM bdicheq:"informix".sc_maechq mae,
               bdicheq:"informix".sc_maenoc noc,
               bdicheq:"informix".sc_producto pro
         WHERE mae.empresa = pEmpresa
           AND mae.cuenta = vCuenta
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           AND pro.empresa = mae.empresa
           AND pro.producto = mae.producto;
           
        -- // VALIDA EL STATSU DE LA CUENTA
        IF vStatusCta IN('2','3','5','6') THEN
            ROLLBACK WORK;
            BEGIN WORK;
            CONTINUE FOREACH;
        END IF;
        
        -- // OBTIENE  FECHA DE ULTIMO DEPOSITO
        IF vFechaUltimoDep is null OR vFechaUltimoDep = '' THEN
            LET vFechaUltimoDep = vFechaAlta;
        END IF;
        
        -- // OBTIENE  FECHA DE ULTIMO RETIRO
        IF vFechaUltimoRet is null OR vFechaUltimoRet = '' THEN
            LET vFechaUltimoRet = vFechaAlta;
        END IF;
        
        -- // OBTIENE FECHA MAS RECIENTE SIN TRANSACCIONAR
        IF vFechaUltimoRet >= vFechaUltimoDep THEN
            LET vFechaCompara = vFechaUltimoRet;
        ELSE
            LET vFechaCompara = vFechaUltimoDep;
        END IF;
        
        LET vDiasSinTransacc = vFechaHoy - vFechaCompara;
        
        -- // MARCA LA CUENTA DEPENDIENDO LA INACTIVIDAD DE LA MISMA
        IF ( vDiasSinTransacc < vDiasInformada ) THEN
        
            COMMIT WORK;
            BEGIN WORK;
            CONTINUE FOREACH;
           
        ELIF ( vDiasSinTransacc >= vDiasInformada AND vDiasSinTransacc < vDiasConcentrada ) THEN
        
            UPDATE bdicheq:"informix".sc_maechq
               SET status_cta = '5', motivo = '14'
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta;
               
            LET vContador2 = vContador2 + 1;
            
            COMMIT WORK;
            BEGIN WORK;
            CONTINUE FOREACH;
            
        ELIF ( vDiasSinTransacc >= vDiasConcentrada AND vDiasSinTransacc < vDiasTraspasada ) THEN
        
            LET vHora = CURRENT HOUR TO FRACTION;
            LET vFolio = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
            -- LET vSdoDispCuenta = vSdoActual - (vSdoRetenido + vSdoCongelado + vSdoSobregirado);
            -- RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. LEOC
            EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo(NULL, vSdoActual, vSdoRetenido, vSdoCongelado, mSaldoSbc, vSdoSobregirado, NULL, NULL, 'F', 1) INTO cCodRetConsSdo, cMensajeRetConsSdo, vSdoDispCuenta;

			      -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
      		  IF cCodRetConsSdo <> '00000' THEN
         		   CONTINUE FOREACH;
      		  END IF;  
            
            IF vSdoDispCuenta > 0.00 THEN 
                CALL cargo_ref( pEmpresa, vSucursal, 'informix', vTrxCargoConcen, '0000', vFolio, 
                                vCuenta, 0, vSdoDispCuenta, '01', 'CARGO CUENTA CONCENTRADA', '', '' ) 
                RETURNING vCodRetCargo, vTransaccRetCargo, vFechaRetCargo, vSdoDispCargo, vMontoRetCargo;
                
                IF vCodRetCargo = '000' THEN
                    CALL abono_ref( pEmpresa, vSucursal, 'informix', vTrxAbonoConcen, '0000', vFolio, vCtaConcentradora, 0, 
                                    vSdoDispCuenta, vSdoDispCuenta, 0, 0, 0, '01', 'TRASPASO CTA CONCENTRADA '||vCuenta, '', '' )
                    RETURNING vCodRetAbono;
                    
                    IF vCodRetAbono = '000' THEN
                        
                    END IF;
                END IF;
            END IF;
            
            UPDATE bdicheq:"informix".sc_maechq
               SET status_cta = '6'
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta; 
            
            SELECT NVL(num_tarjeta, ' ')
              INTO vNumTarjeta
              FROM bdicheq:"informix".sc_tarjeta
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta
               AND tipo_tarjeta = 'T'
               AND status_tar = 'A'
               AND secuencia = (SELECT MAX(secuencia)
                                  FROM bdicheq:"informix".sc_tarjeta
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vCuenta
                                   AND tipo_tarjeta = 'T'
                                   AND status_tar = 'A');
                                   
            SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
              INTO vNombreCliente
              FROM bdinteg:"informix".si_cliente
             WHERE numcte = vNumCliente;
               
            INSERT INTO bdicheq:"informix".sc_cuentas_concentradas
            (grupo, folio, producto, num_cte, cuenta, tarjeta, cliente, fech_ult_dep, fech_ult_ret, sdo_concentrado, fecha_concentra, int_sdo_concentra, pago_sdo_concentra, fecha_pago_concentra, int_trasp_beneficiencia, sdo_trasp_beneficiencia, fecha_trasp_benefic)
            VALUES
            (pEmpresa, vFolio, vNomProducto, vNumCliente, vCuenta, vNumTarjeta, vNombreCliente, vFechaUltimoDep, vFechaUltimoRet, vSdoDispCuenta, vFechaHoy, null, null, null, null, null, null);
            
            LET vContador3 = vContador3 + 1;
            
            COMMIT WORK;
            BEGIN WORK;
            CONTINUE FOREACH;
                    
        ELIF vDiasSinTransacc >= vDiasTraspasada THEN
        
            LET vHora = CURRENT HOUR TO FRACTION;
            LET vFolio = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
            -- LET vSdoDispCuenta = vSdoActual - (vSdoRetenido + vSdoCongelado + vSdoSobregirado);
            -- RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. LEOC
            EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo(NULL, vSdoActual, vSdoRetenido, vSdoCongelado, mSaldoSbc, vSdoSobregirado, NULL, NULL, 'F', 1) INTO cCodRetConsSdo, cMensajeRetConsSdo, vSdoDispCuenta;
   
            -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
      		IF cCodRetConsSdo <> '00000' THEN
         		CONTINUE FOREACH;
      		END IF;  


            UPDATE bdicheq:"informix".sc_maechq
               SET status_cta = '2', motivo = '14', fec_cancelac = vFechaHoy
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta; 
            
            SELECT NVL(num_tarjeta, ' ')
              INTO vNumTarjeta
              FROM bdicheq:"informix".sc_tarjeta
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta
               AND tipo_tarjeta = 'T'
               AND status_tar = 'A'
               AND secuencia = (SELECT MAX(secuencia)
                                  FROM bdicheq:"informix".sc_tarjeta
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vCuenta
                                   AND tipo_tarjeta = 'T'
                                   AND status_tar = 'A');
                                   
            SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
              INTO vNombreCliente
              FROM bdinteg:"informix".si_cliente
             WHERE numcte = vNumCliente;
               
            INSERT INTO bdicheq:"informix".sc_cuentas_concentradas
            (grupo, folio, producto, num_cte, cuenta, tarjeta, cliente, fech_ult_dep, fech_ult_ret, sdo_concentrado, fecha_concentra, int_sdo_concentra, pago_sdo_concentra, fecha_pago_concentra, int_trasp_beneficiencia, sdo_trasp_beneficiencia, fecha_trasp_benefic)
            VALUES
            (pEmpresa, vFolio, vNomProducto, vNumCliente, vCuenta, vNumTarjeta, vNombreCliente, vFechaUltimoDep, vFechaUltimoRet, vSdoDispCuenta, vFechaHoy, null, null, null, null, null, null);
            
            LET vContador4 = vContador4 + 1;
            
            COMMIT WORK;
            BEGIN WORK;
            CONTINUE FOREACH;
            
        END IF;
        
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;
    
    IF vEnTransacc = 1 THEN
        LET vEnTransacc = 0;
        COMMIT WORK;
    END IF;
    
    END;
    
    RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2, vContador3, vContador4;
    
END PROCEDURE
DOCUMENT
'AUTOR      : N/A',
'BD         : BDICHEQ',
'MODIFICO   : Luis Enrique Orozco Cosme',
'FECHA      : 7 de julio de 2025',
'MODIFICACION: Se modifica el calculo de saldo disponible para homologarlo con el llamado a un nuevo spl sp_cons_sdodisp_x_tpcalculo',
'PROYECTO   : RQM 09 704 Cobranza Automatica en Cuentas de Captacion',
'BD         : BDICHEQ',
'VERSION    : 1.0.1',
'MODIFIC0:      Donovan F. Torres Landeros',
'FECHA:         10-02-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.0.2';

Create Procedure "informix".sp_proac_redondeoporcompra()
   returning Char(5), Char(50);

--//Definicion de variables
Define cMensajeRetRet char(50);
Define cCodRet        char(5);
Define isqlerr        integer;
Define iIsamErr       integer;
Define cErrorInfo     char(5);
Define cCuenta_eje    char(20);
Define cCuenta        char(20);
Define dFecha_hoy     date;
Define cMensajeRet    char(50);
Define cTransacCompra char(4);
DEFINE cTransacCompra2 char(4);
Define mMontoCompra   money(14,2);
Define mDecimal       money(18,5);
Define mExcedente     money(18,5);
Define cStatusEje     char(1);
Define mSaldoEje      money(14,2);
Define mRedondeo      money(18,5);
Define cStatusProac   char(1);
Define cTransacCargo  char(4);
Define cTransacAbono  char(4);
Define cSucursal      char(4);
Define cNumeroFolio   char(16);
Define cAceptab       char(1);
Define vusuario       char(8);
Define mSdodisp       money(14,2);
Define cCodRet_sp     char(5);
Define dUltima_ejec   Date;
Define cFolioRev      char(16);
Define cMontoMin      char(4);
Define dFechacargo    date;
--RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
Define cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
Define cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
--RQM 09 704. Se agregan las variables para la consulta de los campos en la maestra de cheques. EEAP.
Define mSdoActual	 money(14,2);
Define mSdoRetenido  money(14,2);
Define mSdoCong      money(14,2);
Define mSaldoSbc     money(14,2);
 
--//Asignacion de variables
Let isqlerr = 0;
Let iIsamErr = 0;
Let cErrorInfo = '';
Let cCuenta_eje  = '';
Let cCuenta = '';
Let dFecha_hoy = '';
Let cMensajeRet = '';
Let cTransacCompra = '';
LET cTransacCompra2 = '';
Let mMontoCompra = 0;
Let mDecimal = 0;
Let mExcedente = 0;
Let cStatusEje = '';
Let mSaldoEje = 0;
Let mRedondeo = 0;
Let cStatusProac = '';
Let cTransacCargo = '';
Let cTransacAbono = '';
Let cSucursal = '';
Let cNumeroFolio = '';
let cAceptab = '' ;
let vusuario = user;
Let mSdodisp = 0;
Let cMensajeRetRet = '';
Let cCodRet = '';
Let cCodRet_sp = '000';
Let dUltima_ejec = '';
Let cFolioRev = '';
Let cMontoMin = '';
Let dFechacargo = '';
--RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
Let cCodRetConsSdo		= '00000';
Let cMensajeRetConsSdo	= '';
--RQM 09 704. Se inicializan las variables los campos retornados de la maestra de cheques. EEAP.
Let mSdoActual	  = 0.00;
Let mSdoRetenido  = 0.00;
Let mSdoCong      = 0.00;
Let mSaldoSbc     = 0.00;	

--Set debug file to "/tmp/sp_PROAC_RedondeoPorCompra.out";
--trace on;

Begin

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet_sp= iSqlErr;
			LET cMensajeRetRet= cErrorInfo;
			ROLLBACK WORK;
			RETURN cCodRet_sp,cMensajeRetRet;
		END IF;
	END EXCEPTION;

	Let cCodRet_sp = '000';
	Let cMensajeRetRet = 'Proceso se ejecuto con exito: ';

	Select fecha_hoy
	Into dFecha_hoy
	From sc_fechas;

	--Valida que proceso no se ejecuto hoy
	If Exists(Select 1 from sc_proacprocesos where fecha_ejec = dfecha_hoy and proceso = 'Redondeo' ) then
		Let cCodRet_sp = '00100';
		Let cMensajeRet = 'Proceso ya ejecutado en fecha: ' || dfecha_hoy;
		Return cCodRet_sp, cMensajeRet;
	End if

	--Transac de Compra conciliada
	Select valor
	Into cTransacCompra
	From sc_param
	Where codparam = 'PROACTRANSCCOMPCONC';
    
    Select valor
	Into cTransacCompra2
	From sc_param
	Where codparam = 'PROACTRANSCCOMPINTE';

	--transac de cargo
	Select valor
	Into cTransacCargo
	From sc_param
	Where codparam = 'PROACTRANSACCCARGO';

	--transac de abono
	Select valor
	Into cTransacAbono
	From sc_param
	Where codparam = 'PROACTRANSACCABONO';
	
	-- monto minimo de compra
	Select valor
	Into cMontoMin
	From sc_param
	Where codparam = 'PROACCOMMAYOR'; 

	--Busca todas las cuentas existentes del programa
	FOREACH WITH HOLD
		Select cta_eje, cuenta, status_cta, sucursal
		Into cCuenta_eje, cCuenta, cStatusProac, cSucursal
		From sc_proac
		Where status_cta = '1'

		Let mMontoCompra = 0;

		--Busca todos los movimientos de la cuenta
		FOREACH WITH HOLD
			Select monto_tot
			Into mMontoCompra
			From sc_movdia
			Where empresa = '001'              --Index idx_movdia1a
			And cuenta = cCuenta_eje            			
			And transacc IN(cTransacCompra, cTransacCompra2)
		
			
			IF mMontoCompra <= cMontoMin then 
				Continue Foreach;			
			END IF		

			--Calculo Redondeo
			Let mRedondeo = 0;
			Let mRedondeo = mMontoCompra / 10;
			--'Let mMontoCompraEntero =  Round (mRedondeo -5); '
			Let mDecimal = trunc (mRedondeo, 5) - trunc (mRedondeo, 0);
			Let mExcedente = mDecimal * 100;
			Let mRedondeo = 100 - mExcedente;
			Let mRedondeo =  mRedondeo / 10;

			--Obtengo el saldo disponible
			--RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
			Select sdo_actual, sdo_cong, sdo_retenido, saldo_sbc, status_cta
			Into mSdoActual, mSdoCong, mSdoRetenido, mSaldoSbc, cStatusEje
			From sc_maechq
			Where empresa = '001'
			And Cuenta = cCuenta_eje;	

			--RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
    		EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCong, mSaldoSbc, null, null, null, 'F', 2) 
    		INTO cCodRetConsSdo,cMensajeRetConsSdo,mSdodisp;	

			-- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
      		IF cCodRetConsSdo <> '00000' THEN
         		CONTINUE FOREACH;
      		END IF;  

			If cStatusEje <> 1 Or cStatusProac <> 1 Or mSdodisp < mRedondeo Then
				Continue Foreach;
			End if;

			--Obtengo folio
			Call sp_generafolionomina ("informix") Returning cCodRet, cNumeroFolio;

			--Cargo (eje)
			Call cargo_ref('001', cSucursal, "informix", cTransacCargo, '0250', cNumeroFolio, cCuenta_eje, 0, mRedondeo, '01', 'Cargo x Redondeo ', '','')
			returning cCodRet,cTransacCargo,dFechacargo,mSaldoEje,mRedondeo ;
			
			Let cFolioRev = cNumeroFolio;

			If cCodRet  = '000'  Then
				--Obtengo folio
				Call sp_generafolionomina ("informix") Returning cCodRet, cNumeroFolio;

				--Abono (proac)
				Call abono_ref ('001', cSucursal, "informix", cTransacAbono,'0250', cNumeroFolio, cCuenta, 0 ,mRedondeo, mRedondeo, 0, 0, 0, '01', 'Abono x Redondeo', '0','')
				returning cCodRet;

				Let cMensajeRetRet = 'Proceso se ejecutado con exito: ';

				If cCodRet  <> '000'  Then
					--Reversion al cargo sp reverso();
					Call reversion ('001', cSucursal, "informix",cFolioRev, "C") Returning cCodRet;
					Call reversion ('001', cSucursal, "informix",cNumeroFolio, "C") Returning cCodRet;
					Continue foreach;
				End If

				--obtengo saldo de proac de maestro
				Select nvl(sdo_actual, 0)
				Into mSaldoEje
				From sc_maechq
				Where Cuenta = cCuenta;

				--actualizo nuevo saldo proac  con el del maestro
				Update sc_proac					
				Set saldo = mSaldoEje
				Where cta_eje = cCuenta_eje
				And status_cta = '1';				

			End If;
		End Foreach;
	End Foreach;

	-- Inserta registro de ejecusion
	Insert into sc_proacprocesos (proceso, status, fecha_ejec, hora_ejec) Values ('Redondeo','1',dFecha_hoy, current hour to fraction);
	RETURN cCodRet_sp,cMensajeRetRet;
	
End;
End Procedure
DOCUMENT
'AUTOR		: Yahaira Corona, Carmen orozco Ibarria',
'DESCRIPCION: Genera el proceso de redondeo en las cuentas afiliadas al PROAC',
'FECHA		: Febrero de 2009',
'VERSION	: 20090212',
'BD			: BDICHEQ',
'ModificÃ³	: Abigail Vasavilbazo CaÃ±edo',
'DESCRIPCION: Se cambio la variable para el redondeo',
'FECHA		: Marzo 2009',
'VERSION	: 200903',
'BD			: BDICHEQ',
'ModificÃ³	: Armando Mercado Figueroa',
'DESCRIPCION: Se cambio la consulta a los movimientos de la tabla historica por la tabla de movimientos del dia',
'FECHA		: Abril 2009',
'VERSION	: 200904',
'BD			: BDICHEQ',
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 09-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2',
'MODIFIC0:      Donovan F. Torres Landeros',
'FECHA:         10-02-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.3';

CREATE PROCEDURE "informix".sp_verifctasdesconcentradas( pEmpresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
       
    DEFINE Sql_Err              INTEGER;
    DEFINE Isam_Err             INTEGER;
    DEFINE Desc_Err             CHAR(50);
    DEFINE vCodRet1             CHAR(5);
    DEFINE vCodRet2             CHAR(5);
    DEFINE vCodRet3             CHAR(50);
    DEFINE vTrxAbierta          SMALLINT;
    DEFINE vContador1           INTEGER;
    DEFINE vContador2           INTEGER;
    DEFINE vFechaHoy            DATE;
    DEFINE vTrxCargo            CHAR(4);
    DEFINE vTrxAbono            CHAR(4);
    DEFINE vCtaNostro           CHAR(20);
    DEFINE vDiasDesConcentra    INTEGER;
    DEFINE vCuenta              CHAR(20);
    DEFINE vStatusCta           CHAR(1);
    DEFINE vSucursal            CHAR(4);
    DEFINE vNumCliente          CHAR(20);
    DEFINE vProducto            CHAR(4);
    DEFINE vSdoActual           DECIMAL(18,2);
    DEFINE vSdoRetenido         DECIMAL(18,2);
    DEFINE vSdoCongelado        DECIMAL(18,2);
    DEFINE vSdoSobregirado      DECIMAL(18,2);
    DEFINE vFechaUltimoDep      DATE;
    DEFINE vFechaUltimoRet      DATE;
    DEFINE vFechaDesConcentra   DATE;
    DEFINE vDiasSinTransacc     INTEGER;    
    DEFINE vSdoDispCuenta       DECIMAL(18,2);
    DEFINE vHora                CHAR(15);
    DEFINE vFolio               CHAR(16);
    DEFINE vHoraTrx             CHAR(15);
    DEFINE vProdNostro          CHAR(4);
    DEFINE vSucNostro           CHAR(4);
    DEFINE vSdoNostro           DECIMAL(18,2);
    DEFINE vInsTrxCargo         CHAR(1);
    DEFINE vUpdTrxCargo         CHAR(1);
    DEFINE vInsTrxAbono         CHAR(1);
    DEFINE vUpdTrxAbono         CHAR(1);
    DEFINE vUpdCuenta           CHAR(1);
    DEFINE vUpdConcen           CHAR(1);
    DEFINE vUpdCtaDesc          CHAR(1);
	DEFINE vFechaOperacion   	DATE;
    --RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
    DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    --RQM 09 704. Se agrega la variable mSaldoSbc para la consulta del campo en la maestra de cheques. EEAP.
    DEFINE mSaldoSbc            MONEY(14,2);

    
    LET Sql_Err	            = 0;
    LET Isam_Err            = 0;
    LET Desc_Err            = '';
    LET vCodRet1            = '000';
    LET vCodRet2            = '000';
    LET vCodRet3            = '';
    LET vTrxAbierta         = 0;
    LET vContador1          = 0;
    LET vContador2          = 0;
    LET vFechaHoy           = '';
    LET vTrxCargo           = '';
    LET vTrxAbono           = '';
    LET vCtaNostro          = '';
    LET vDiasDesConcentra   = 0;
    LET vCuenta             = '';   
    LET vStatusCta          = '';
    LET vSucursal           = '';
    LET vNumCliente         = '';
    LET vProducto           = '';
    LET vSdoActual          = 0.00;
    LET vSdoRetenido        = 0.00;
    LET vSdoCongelado       = 0.00;
    LET vSdoSobregirado     = 0.00;
    LET vFechaUltimoDep     = '';
    LET vFechaUltimoRet     = '';
    LET vFechaDesConcentra  = '';
    LET vDiasSinTransacc    = 0;
    LET vSdoDispCuenta      = 0.00;
    LET vHora               = '';
    LET vFolio              = '';
    LET vHoraTrx            = '';
    LET vProdNostro         = '';
    LET vSucNostro          = '';
    LET vSdoNostro          = 0.00;
    LET vInsTrxCargo        = '0';
    LET vUpdTrxCargo        = '0';
    LET vInsTrxAbono        = '0';
    LET vUpdTrxAbono        = '0';
    LET vUpdCuenta          = '0';
    LET vUpdConcen          = '0';
    LET vUpdCtaDesc         = '0';
	LET vFechaOperacion   	= TODAY;
    --RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
    LET cCodRetConsSdo		= '00000';
    LET cMensajeRetConsSdo	= '';
    --RQM 09 704. Se inicializa la variable mSaldoSbc para el campo retornado de la maestra de cheques. EEAP.
    LET mSaldoSbc           = 0.00;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_verifctasdesconcentradas.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vTrxAbierta = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_verifctasdesconcentradas.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // OBTINENE LA FECHA DE HOY
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
     
    -- // OBTIENE TRANSACCION DE CARGO PARA CUENTAS CONCENTRADAS
    SELECT valor
      INTO vTrxCargo
      FROM sc_param
     WHERE empresa = pEmpresa
      AND codparam = 'TrxCgoCtaConcentrada';

    -- // OBTIENE TRANSACCION DE ABONO PARA CUENTAS CONCENTRADAS
    SELECT valor
      INTO vTrxAbono
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'TrxAboCtaConcentrada';

    -- // OBTIENE LA CUENTA CONCENTRADORA PARA TRASPASOS POR INACTIVIDAD
    SELECT valor
      INTO vCtaNostro
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'CtaConcentradorArt61';
     
    -- // OBTIENE EL NUMERO DE DIAS PARA VOLVER A CONCENTRAR
    SELECT valor::INT
      INTO vDiasDesConcentra
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasCtasDesConcentra';
    
    FOREACH WITH HOLD
        -- // OBTIENE DATOS DE LA CUENTA A CONCENTRAR
        --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
		SELECT mae.cuenta, mae.status_cta, mae.sucursal, mae.num_cte, mae.producto, 
               mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, 
               mae.fecultdep, mae.fecultret, con.fecha_pago_concentra, mae.saldo_sbc
          INTO vCuenta, vStatusCta, vSucursal, vNumCliente, vProducto, 
               vSdoActual, vSdoRetenido, vSdoCongelado, vSdoSobregirado, 
               vFechaUltimoDep, vFechaUltimoRet, vFechaDesConcentra, mSaldoSbc
          FROM sc_maechq mae,
               sc_cuentas_concentradas con
         WHERE mae.empresa = pEmpresa
           AND mae.status_cta = '8'
           AND con.cuenta = mae.cuenta
    
        BEGIN WORK;
        LET vTrxAbierta = 1;
        
        LET vContador1 = vContador1 + 1;
        
        LET vDiasSinTransacc = 0;
        LET vSdoDispCuenta   = 0;
        LET vInsTrxCargo     = '0';
        LET vUpdTrxCargo     = '0';
        LET vInsTrxAbono     = '0';
        LET vUpdTrxAbono     = '0';
        LET vUpdCuenta       = '0';
        LET vUpdConcen       = '0';
        LET vUpdCtaDesc      = '0';
        
        LET vDiasSinTransacc = vFechaHoy - vFechaDesConcentra;
        
		IF ( vDiasSinTransacc > vDiasDesConcentra ) THEN
            --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
            EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', vSdoActual, vSdoRetenido, vSdoCongelado, mSaldoSbc, vSdoSobregirado, null, null, 'F', 1) INTO cCodRetConsSdo,cMensajeRetConsSdo,vSdoDispCuenta;
			
            -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
      		IF cCodRetConsSdo <> '00000' THEN
                ROLLBACK WORK;
                LET vTrxAbierta = 0;
         		CONTINUE FOREACH;
      		END IF;  
            
			IF vSdoDispCuenta > 0.00 THEN 
				LET vHora = CURRENT HOUR TO FRACTION;
				LET vFolio = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
			
				LET vHoraTrx = CURRENT HOUR TO FRACTION(3);
            
                INSERT INTO sc_movdia VALUES
                ( 0, vFolio, '9250' , 'informix', vFechaHoy, vFechaHoy, vHoraTrx, vTrxCargo, vSucursal, vProducto, pEmpresa, vCuenta, '', 0, 
                  vSdoDispCuenta, 0.00, 0.00, 0.00, 0, '', '', vSdoActual, '0000' , 'CONCENTRACION POR INACTIVIDAD ART 61 LIC', 0, '', '', '', vFechaOperacion);
                  
                IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                    LET vInsTrxCargo = '1';
                END IF;
                
                UPDATE sc_maechq
                   SET sdo_actual   = sdo_actual - vSdoDispCuenta,
                       imp_cgos_mes = imp_cgos_mes + vSdoDispCuenta,
                       num_cgos_mes = num_cgos_mes + 1,
                       fec_ult_mov  = vFechaHoy
                 WHERE empresa = pEmpresa
                   AND cuenta = vCuenta; 
                   
                IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                    LET vUpdTrxCargo = '1';
                END IF;
                
                IF vInsTrxCargo = '1' AND vUpdTrxCargo = '1' THEN
                    SELECT producto, sucursal, sdo_actual
                      INTO vProdNostro, vSucNostro, vSdoNostro
                      FROM sc_maechq 
                     WHERE empresa = pEmpresa
                       AND cuenta = vCtaNostro;
                       
                    LET vHoraTrx = CURRENT HOUR TO FRACTION(3);
                    
                    INSERT INTO sc_movdia VALUES
                    ( 0, vFolio, '9250', 'informix', vFechaHoy, vFechaHoy, vHoraTrx, vTrxAbono, vSucNostro, vProdNostro, pEmpresa, vCtaNostro, '', 0, 
                      vSdoDispCuenta, vSdoDispCuenta, 0.00, 0.00, 0, '', '', vSdoNostro, '0000', 'ABONO X CONCENTRACION DE CTA '||TRIM(vCuenta), 0, '', '', '', vFechaOperacion);
                              
                    IF dbinfo('sqlca.sqlerrd2') > 0 THEN 
                        LET vInsTrxAbono = '1'; 
                    END IF;
                    
                    UPDATE sc_maechq
                       SET sdo_actual = sdo_actual + vSdoDispCuenta,
                           imp_abonos_mes = imp_abonos_mes + vSdoDispCuenta, 
                           num_abonos_mes = num_abonos_mes + 1,
                           fec_ult_mov = vFechaHoy,
                           fecultdep = vFechaHoy
                     WHERE empresa = pEmpresa 
                       AND cuenta = vCtaNostro;
                                   
                    IF dbinfo('sqlca.sqlerrd2') > 0 THEN 
                        LET vUpdTrxAbono = '1'; 
                    END IF;
                    
                    IF vInsTrxAbono = '1' AND vUpdTrxAbono = '1' THEN
                        UPDATE sc_cuentas_concentradas
                           SET folio = vFolio,
                               sdo_concentrado = vSdoDispCuenta
                         WHERE cuenta = vCuenta;
                        
                        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                            LET vUpdConcen = '1';
                        END IF;
                        
                        UPDATE sc_maechq
						   SET status_cta = '6'
						 WHERE empresa = pEmpresa
						   AND cuenta = vCuenta; 
                           
                        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                            LET vUpdCuenta = '1';
                        END IF;
                        
                        INSERT INTO sc_ctasdescon_concentradas
                        ( num_cte, producto, cuenta, status_cta, sdo_actual, fech_ult_dep, fech_ult_ret, fecha_desmar, fecha_marc )
                        VALUES
                        ( vNumCliente, vProducto, vCuenta, vStatusCta, vSdoActual, vFechaUltimoDep, vFechaUltimoRet, vFechaDesConcentra, vFechaHoy );
                        
                        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                            LET vUpdCtaDesc = '1';
                        END IF;
                        
                        IF vUpdConcen = '1' AND vUpdCuenta = '1' AND vUpdCtaDesc = '1' THEN
                            LET vContador2 = vContador2 + 1;
                        ELSE
                            ROLLBACK WORK;
                            LET vTrxAbierta = '0';
                            CONTINUE FOREACH;
                        END IF;
                    ELSE
                        ROLLBACK WORK;
                        LET vTrxAbierta = '0';
                        CONTINUE FOREACH;
                    END IF;
                ELSE
                    ROLLBACK WORK;
                    LET vTrxAbierta = '0';
                    CONTINUE FOREACH;
                END IF;
            ELSE
                ROLLBACK WORK;
                LET vTrxAbierta = '0';
                CONTINUE FOREACH;
            END IF;
        ELSE
            ROLLBACK WORK;
            LET vTrxAbierta = '0';
            CONTINUE FOREACH;
        END IF; 
        
        COMMIT WORK;
        LET vTrxAbierta = '0';
    END FOREACH;
    
    END;
     
    RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2;
     
END PROCEDURE

DOCUMENT 
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 01-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2',
'MODIFIC0:      Donovan F. Torres Landeros',
'FECHA:         10-02-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.3';

CREATE PROCEDURE "informix".sp_actparampasecheq(pempresa CHAR(3))
RETURNING CHAR(5);
    
    --- ################################################################################
    --- ##  Nombre:              sp_actparampasecheq                                  ##
    --- ##  Version:             2.0                                                  ##
    --- ##  Objetivo:            Programa del pase contable de captacion              ##
    --- ##  Creado por:                                                               ##
    --- ##  Modificado por:      Ivan Escorza                                         ##
    --- ##  Ultima Modificacion: Marzo 2026                                           ##
    --- ################################################################################

    DEFINE vcodret       CHAR(5);
    DEFINE vcodret2      CHAR(5);
    DEFINE vcodret3      VARCHAR(50);
    DEFINE vsqlerr       INTEGER;
    DEFINE isam_err      INTEGER;
    DEFINE error_info    VARCHAR(50);
    DEFINE vpromedio     INTEGER;
    DEFINE vcont         SMALLINT;
    DEFINE vbrinca       INTEGER;
    DEFINE vserial       INTEGER;
    DEFINE vparam_serial VARCHAR(60);
    
    LET vcodret          = "000";
    LET vcodret2         = "000";
    LET vcodret3         = " ";
    LET vsqlerr          = 0;
    LET isam_err         = 0;
    LET error_info       = '';
    LET vpromedio        = 0;
    LET vcont            = 0;
    LET vbrinca          = 0;
    LET vserial          = 0;
    LET vparam_serial    = '';
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparampasecheq.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/home/c98789058/SPL_ACCENTURE/sp_actparampasecheq.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

     SELECT ROUND(COUNT(*)/6)
      INTO vpromedio
      FROM bdicheq:sc_movdia_concil
	  WHERE num_serial > 0;  

    LET vcont = 1;  
    
    WHILE vcont <= 5         
        IF vcont = 1 THEN
            LET vbrinca = vpromedio;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0
                 ORDER BY num_serial 

                LET vparam_serial = vserial;
                
                UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom1';

            END FOREACH;

        ELIF vcont = 2 THEN
            LET vbrinca = vpromedio * 2;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0 
                 ORDER BY num_serial
 
                LET vparam_serial = vserial;
                 
                 UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom2';
 
            END FOREACH;

        ELIF vcont = 3 THEN
            LET vbrinca = vpromedio * 3;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0
                 ORDER BY num_serial

                LET vparam_serial = vserial;
    
                UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom3';
  
            END FOREACH;

        ELIF vcont = 4 THEN
            LET vbrinca = vpromedio * 4;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0 
                 ORDER BY num_serial
 
                LET vparam_serial = vserial;
     
                UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom4';

            END FOREACH;

        ELIF vcont = 5 THEN
            LET vbrinca = vpromedio * 5;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0 
                 ORDER BY num_serial

                LET vparam_serial = vserial;
                 
                UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom5'; 
            END FOREACH;
        END IF;
        LET vcont = vcont + 1;  
        LET vserial = 0;
        LET vparam_serial = '';
    END WHILE;    

    RETURN vcodret;

    END;

END PROCEDURE;