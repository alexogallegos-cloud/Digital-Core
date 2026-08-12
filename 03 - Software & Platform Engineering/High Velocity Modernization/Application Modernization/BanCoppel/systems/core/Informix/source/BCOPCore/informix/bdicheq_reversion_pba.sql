CREATE PROCEDURE "informix".reversion_pba(pempresa  char(3),
                                      psucursal char(4),
                                      pusuario  char(8),
                                      pfolio    char(16),
                                      ptiporev  char(1))
RETURNING char(5);
    
    DEFINE sql_err              integer;
    DEFINE isam_err             integer;
    DEFINE cod_ret              char(5);
    DEFINE cCodret2             char(5);
    DEFINE contador             smallint;
    DEFINE wcompend             money(14,2);
    DEFINE wtiptran             char(2);
    DEFINE wnum_serial          integer;
    DEFINE wtransacc            char(4);
    DEFINE wcuenta              char(20);
    DEFINE wmonto_tot           money(14,2);
    DEFINE wmonto_tot1          money(14,2);
    DEFINE montoaux             money(14,2);
    DEFINE wfirme               money(14,2);
    DEFINE wen_sbc              money(14,2);
    DEFINE wremesas             money(14,2);
    DEFINE wdias_ret            smallint;
    DEFINE wnum_cheq            integer;
    DEFINE wimp_sbg_ccc         money(14,2);
    DEFINE wimp_chq_sbg         money(14,2);
    DEFINE wimp_int_ccc         money(14,2);
    DEFINE wimp_int_sbg         money(14,2);
    DEFINE wchq_exp_mes         smallint;
    DEFINE wnaturaleza          char(1);
    DEFINE wvalida_docto        char(1);
    DEFINE wtipo                char(1);
    DEFINE wsaldo_cuenta        money(14,2);
    DEFINE wsdo_actual          money(14,2);
    DEFINE wsdo_retenido        money(14,2);
    DEFINE wsdo_sbc             money(14,2);
    DEFINE wsdo_cong            money(14,2);
    DEFINE wmontoaux            money(14,2);
    DEFINE wlim_chq_sbc         money(14,2);
    DEFINE wimp_chq_sbc         money(14,2);
    DEFINE wlim_chq_rem         money(14,2);
    DEFINE wimp_chq_rem         money(14,2);
    DEFINE wreferencia          char(40);
    DEFINE wstatus_envio        char(1);
    DEFINE wrowid               integer;
    DEFINE wfechoy              date;
    DEFINE pfolio1              char(16);
    DEFINE wtpcheque            char(2);
    DEFINE wfechahora           datetime hour to fraction(3);
    DEFINE vtranusoccc          char(4);
    DEFINE vtrancancta          char(4);
    DEFINE vtranintccc          char(4);
    DEFINE vtranusosbg          char(4);
    DEFINE vtranintsbg          char(4);
    DEFINE wcomision            char(4);
    DEFINE wsuc_cuen            char(4);
    DEFINE wproducto            char(4);
    define vnum_tarjeta         char(16);
    define vmaxsec              smallint;
    DEFINE vProdCrec            CHAR(4);
    DEFINE vstatus_cta          CHAR(1);
    DEFINE vtransaccion 	    integer;
    DEFINE vtrancorrespchq      CHAR(4);
    DEFINE wusuario             CHAR(8);
    DEFINE vuser_limit          CHAR(8);
    DEFINE vtran_limit          CHAR(4);
    DEFINE vid_transacc         CHAR(2);
    DEFINE vid_canal            CHAR(2);
    DEFINE wnum_cte             CHAR(20);
    DEFINE vmsje_limites        CHAR(80);
    DEFINE vid_autor            CHAR(1);
    DEFINE cTransaccAbonoEnvio  char(4);
    DEFINE cTransaccAbonoEnvioC char(4);
    DEFINE vtranpagosbg         CHAR(4);
	DEFINE vclave_rastreo       CHAR(30);
    --- // 2012.01.23 // INICIO
	DEFINE cont_exist       	INTEGER;
    --- // 2012.01.23 // FIN
    DEFINE wsuc_tran            CHAR(4);
    DEFINE vestado_oper         CHAR(2);
    DEFINE vestado_cta          CHAR(2);
    DEFINE vtpo_per_valida      CHAR(1);
	
    LET sql_err = 0;
    LET cod_ret = "000";
    LET cCodret2 = "00000";
    LET vtransaccion = 0;
    LET vtrancorrespchq = '';
    --- // 2012.01.23 // INICIO
	LET cont_exist = 0;
    --- // 2012.01.23 // FIN
    LET vtpo_per_valida = '';
    LET vnum_tarjeta = ' ';

    --- SET DEBUG FILE TO "/home/informix/ivonne/reversion.out";
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        IF (sql_err <> 0) THEN
            SET DEBUG FILE TO "reversionch.err";
            TRACE sql_err || " * " || isam_err;
            LET cod_ret = sql_err;
            if vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            else
                ROLLBACK WORK;
            end if
            RETURN cod_ret;
        END IF;
    END EXCEPTION;

    on exception in (-535)
        let vtransaccion = 1;
    end exception with resume;

    if vtransaccion = 1 then
        COMMIT WORK;
        BEGIN WORK;
    else
        BEGIN WORK;
    end if;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;

    LET pempresa = pempresa;
    LET psucursal = psucursal;
    LET pusuario = pusuario;
    LET pfolio =  pfolio;
    LET ptiporev = ptiporev;
    
    SELECT {+INDEX(sc_fechas idx_fechas1)}
           fecha_hoy
      INTO wfechoy
      FROM sc_fechas
     WHERE empresa = pempresa;

    SELECT TRIM(valor)
      INTO vProdCrec
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam ="PRODCREC";

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

    IF (contador = 0) THEN
        SELECT COUNT(*)
          INTO contador
          FROM sc_docret_sbc
         WHERE empresa = pempresa
           AND folio_suc = pfolio
           AND fecha_alta = wfechoy;

        IF (contador = 0) THEN
            --- ##################################################   2012.01.23 - INICIO   ##################################################
			--- IF EXISTS ( SELECT referencia1 
            ---               FROM bdisac:sac_movimientos 
            ---              WHERE folio_suc = pfolio 
            ---                AND id_sucursal = psucursal 
            ---                AND status_cancelado <> 'S' ) THEN
            ---     CALL bdisac:sp_ReversionSac(pempresa,psucursal,pusuario, pfolio) 
            ---     RETURNING cCodret2;
            --- END IF;
            
            LET cont_exist = 0;
            
			SELECT {+INDEX(bdisuc:ss_operaciones idx_ss_operaciones2)} COUNT (folio_oper) 
              INTO cont_exist
              FROM bdisuc:ss_operaciones
             WHERE folio_sucursal = pfolio
               AND sucursal = psucursal
               AND reversado <> '1';

            
            IF cont_exist > 0 THEN
               CALL bdisuc:reversion(pempresa,psucursal,pusuario, pfolio,ptiporev) 
               RETURNING cCodret2;
            END IF;			
			
            LET cont_exist = 0;
            SELECT COUNT (referencia1) 
              INTO cont_exist
              FROM bdisac:sac_movimientos
             WHERE folio_suc = pfolio
               AND id_sucursal = psucursal
               AND status_cancelado <> 'S';
            
            IF cont_exist > 0 THEN
               CALL bdisac:sp_ReversionSac(pempresa,psucursal,pusuario, pfolio) 
               RETURNING cCodret2;
            ELSE
                -----------------------------------------------
            END IF;
            --- ##################################################   2012.01.23 - FIN   ##################################################

			-- // Se modifica la busqueda para ser mas eficiente
			SELECT {+index (bditef:tef_operaciones  idx_tef_operaciones1)} clave_rastreo
              into vclave_rastreo
              FROM bditef:"informix".tef_operaciones
             WHERE folio_suc = pfolio
               AND clave_rastreo <> ""
               AND fecha_trans = wfechoy 
               AND cve_status = 'PE'
               AND sucursal = psucursal;
					
            if (vclave_rastreo is not null or vclave_rastreo <> '') then
                UPDATE {+index (bditef:tef_operaciones  idx_tef_operaciones1)} 
                       bditef:"informix".tef_operaciones 
                   SET cve_status = '04' 
                 WHERE folio_suc = pfolio  
                   AND clave_rastreo <> "" 
                   AND fecha_trans = wfechoy 
                   AND cve_status = 'PE'
                   AND sucursal = psucursal;
            else
                --------------------------
            end if;
            
            RETURN cod_ret;
        ELSE
            UPDATE sc_docret_sbc
               SET cancelado = "S"
             WHERE empresa = pempresa
               AND folio_suc = pfolio
               AND fecha_alta = wfechoy;
            
            --- ##################################################   2012.01.23 - INICIO   ##################################################
            --- IF EXISTS ( SELECT referencia1 
            ---               FROM bdisac:sac_movimientos 
            ---              WHERE folio_suc = pfolio 
            ---                AND id_sucursal = psucursal 
            ---                AND status_cancelado <> 'S') THEN
            ---     CALL bdisac:sp_ReversionSac(pempresa,psucursal,pusuario, pfolio) 
            ---     RETURNING cCodret2;
            --- END IF;
            
            LET cont_exist = 0;
            
            SELECT COUNT (referencia1) 
              into cont_exist
              FROM bdisac:sac_movimientos
             WHERE folio_suc = pfolio
               AND id_sucursal = psucursal
               AND status_cancelado <> 'S';
               
            IF cont_exist > 0 THEN
                CALL bdisac:sp_ReversionSac(pempresa,psucursal,pusuario, pfolio) 
                RETURNING cCodret2;
            ELSE
                -----------------------
            END IF;
            --- ##################################################   2012.01.23 - FIN   ##################################################
        
			-- // Se modifica la busqueda para ser mas eficiente
			SELECT {+index (bditef:tef_operaciones  idx_tef_operaciones1)} clave_rastreo
              into vclave_rastreo
              FROM bditef:"informix".tef_operaciones
             WHERE folio_suc = pfolio
               AND clave_rastreo <> ""
               AND fecha_trans = wfechoy 
               AND cve_status = 'PE'
               AND sucursal = psucursal;
						
            if (vclave_rastreo is not null or vclave_rastreo <> '') then
                UPDATE {+index (bditef:tef_operaciones  idx_tef_operaciones1)} 
                       bditef:"informix".tef_operaciones 
                   SET cve_status = '04' 
                 WHERE folio_suc = pfolio  
                   AND clave_rastreo <> "" 
                   AND fecha_trans = wfechoy 
                   AND cve_status = 'PE'
                   AND sucursal = psucursal;
            else
                ------------------------------
            end if;

            RETURN cod_ret;
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
       
    SELECT TRIM(valor) 
      INTO vtrancorrespchq
      FROM bdicheq:sc_param
     WHERE empresa = pempresa
       AND codparam = "trancorrespchq";
       
    SELECT valor
      INTO vtranpagosbg
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranpagosbg";
    
	-- // Valida si es un envio de Orden de Pago y su estatus no esta activo no deja reversar
	--- ##################################################   2012.01.23 - INICIO   ##################################################
	--- IF EXISTS ( SELECT referencia1 
    ---               FROM bdisac:sac_movimientos 
    ---              WHERE folio_suc = pfolio 
    ---                AND id_sucursal = psucursal 
    ---                AND status_cancelado <> 'S') THEN
	LET cont_exist = 0;
    
	SELECT COUNT (referencia1) 
      into cont_exist
      FROM bdisac:sac_movimientos
     WHERE folio_suc = pfolio
       AND id_sucursal = psucursal
       AND status_cancelado <> 'S';
    
	IF cont_exist > 0 THEN
	--- ##################################################   2012.01.23 - FIN   ##################################################
    
        -- // Obtengo transacciones de Anono a cuenta prest,  significa que es envio
        SELECT valor 
          INTO cTransaccAbonoEnvio  --- Abono en efectivo por Orden de Pago a Cuenta Prest
          FROM Bdisac:sac_param
         WHERE empresa = '001'
           AND cod_param = '5070011';
           
        SELECT valor 
          INTO cTransaccAbonoEnvioC   --- Abono en Cargo a cuenta por Orden de Pago         
          FROM Bdisac:sac_param
         WHERE empresa = '001'
           AND cod_param = '5070012';
           
        -- // Verifica si es un Envio de Orden de Pago
        SELECT {+INDEX(sc_movdia idx_movdia2a), 
               +INDEX(bdinteg:si_transacc idx_transacc2)} 
               Count(m.transacc)
          INTO contador
          FROM sc_movdia m, 
               bdinteg:si_transacc t
         WHERE m.empresa = pempresa 
           AND m.folio_suc = pfolio 
           AND m.cancelad <> "S"
           AND t.numero = m.transacc
           AND t.empresa = m.empresa
           AND t.reversable = "S"
           AND (t.numero = cTransaccAbonoEnvio OR t.numero = cTransaccAbonoEnvioC);
		
        If contador >= 1 THEN --- Si es un envio			
            -- // Verifica si el estatus del envio es diferente de activo
            --- ##################################################   2012.01.23 - INICIO   ##################################################
            --- IF EXISTS (SELECT referencia1 
            ---              FROM bdisac:sac_movimientos mov 
            ---        INNER JOIN bdisac:sac_enviosdineroya env ON (Trim(mov.referencia1) = env.no_control)
            ---             WHERE mov.folio_suc = pfolio 
            ---               AND mov.id_sucursal = psucursal 
            ---               AND mov.status_cancelado <> 'S' 
            ---               AND env.estatus <> '01') THEN
            ---               AND env.estatus not in ('00', '01')) THEN
            ---     -- // El envio no puede ser reversado, estatus diferente de 01-activo	
            ---     LET cod_ret = '170';
            ---     RETURN cod_ret;
            
            LET cont_exist = 0;
            
            SELECT COUNT (referencia1) 
              into cont_exist
              FROM bdisac:sac_movimientos mov
             INNER JOIN bdisac:sac_enviosdineroya env ON (Trim(mov.referencia1) = env.no_control)
             WHERE mov.folio_suc = pfolio
               AND mov.id_sucursal = psucursal
               AND mov.status_cancelado <> 'S'
               AND env.estatus not in ('00', '01');
               
            IF cont_exist > 0 THEN
                -- // El envio no puede ser reversado, estatus diferente de 01-activo	
                LET cod_ret = '170';
                RETURN cod_ret;
            ELSE
                --------------------------------------
            END IF;
            --- ##################################################   2012.01.23 - FIN   ##################################################
            
            -- // Se modifica la busqueda para ser mas eficiente
            SELECT {+index (bditef:tef_operaciones  idx_tef_operaciones1)} clave_rastreo
              into vclave_rastreo
              FROM bditef:"informix".tef_operaciones
             WHERE folio_suc = pfolio
               AND clave_rastreo <> ""
               AND fecha_trans = wfechoy 
               AND cve_status = 'PE'
               AND sucursal = psucursal;
                            
            if (vclave_rastreo is not null or vclave_rastreo <> '') then						
                UPDATE {+index (bditef:tef_operaciones  idx_tef_operaciones1)} 
                       bditef:"informix".tef_operaciones 
                   SET cve_status = '04' 
                 WHERE folio_suc = pfolio  
                   AND clave_rastreo <> "" 
                   AND fecha_trans = wfechoy 
                   AND cve_status = 'PE'
                   AND sucursal = psucursal;
            else
                -----------------------------
            end if;	
        END IF;
	END IF;
    
    FOREACH
        SELECT {+INDEX(sc_movdia idx_movdia2a),
                +INDEX(bdinteg:si_transacc idx_transacc2)}
               md.num_serial, md.transacc, md.cuenta, md.monto_tot, md.firme, md.en_sbc, md.remesas,
               md.dias_ret, md.num_cheq, tr.naturaleza, tr.valida_docto, tr.tipo_tran,
               md.referencia, md.suc_cuen, md.producto, tr.tpcheque, md.usuario, md.sucursal  -- Gpo PISA 270110
          INTO wnum_serial, wtransacc, wcuenta, wmonto_tot, wfirme, wen_sbc,
               wremesas, wdias_ret, wnum_cheq, wnaturaleza, wvalida_docto,
               wtiptran, wreferencia, wsuc_cuen, wproducto, wTpCheque, wusuario, wsuc_tran
          FROM sc_movdia md,
               bdinteg:si_transacc tr
         WHERE md.empresa = pempresa
           AND md.folio_suc = pfolio
           AND md.cancelad <> "S"
           AND tr.numero = md.transacc
           AND tr.empresa = md.empresa
           AND tr.reversable = "S"
         ORDER BY tr.naturaleza 
         
        SELECT tpper_valida
          INTO vtpo_per_valida
          FROM sc_producto
         WHERE producto = wproducto;

        /* #############################
        SELECT MAX(secuencia)
          INTO vmaxsec
          FROM sc_tarjeta
         WHERE empresa = pempresa
           AND cuenta = wcuenta
           AND tipo_tarjeta = "T";

        SELECT num_tarjeta
          INTO vnum_tarjeta
          FROM sc_tarjeta
         WHERE empresa = pempresa
           AND cuenta = wcuenta
           AND secuencia = vmaxsec;
        ############################# */

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
            let wcomision = trim(wreferencia);
        END IF;

        SELECT sdo_actual, status_cta, num_cte
          INTO wsdo_actual, vstatus_cta, wnum_cte
          FROM sc_maechq
         WHERE empresa = pempresa
           AND cuenta = wcuenta;

        IF wnaturaleza = "C" THEN
            --- ##################################################   JOM INICIO   ##################################################
            UPDATE {+INDEX(sc_movdia idx_movdia_fechaserial)} sc_movdia
               SET cancelad = "S"
             WHERE fech_alt = TODAY
               and cancelad <> "S"
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
            ( 0, pfolio, psucursal, pusuario, wfechoy, wfechoy, current hour to fraction(3), wtransacc, wsuc_cuen, wproducto, 
              pempresa, wcuenta, " ", wnum_cheq, wmonto_tot * -1, 0, 0, 0, 0, "S", " ", wsdo_actual, "0000", "REV", 0, vnum_tarjeta, "" );
            --- ##################################################   JOM FIN   ##################################################

            UPDATE sc_maechq SET
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

            --- if wtransacc = vtrancancta then

            IF vstatus_cta = "2" THEN
                UPDATE sc_maechq
                   SET status_cta = "1",
                       fec_cancelac = "",
                       motivo = " "
                 WHERE empresa = pempresa
                   AND cuenta = wcuenta;
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

            --- Gpo PISA 270110
            IF wvalida_docto = "S" AND wTpCheque = "01" THEN
                UPDATE {+INDEX(sc_contch idx_contch1)} sc_contch
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
            
			--// Si es un movimiento de servicio reversa el servicio tambien
			--- IF EXISTS ( SELECT referencia1
            ---               FROM bdisac:sac_movimientos
            ---              WHERE folio_suc = pfolio
            ---                AND id_sucursal = psucursal
            ---                AND status_cancelado <> 'S') THEN
            ---     CALL bdisac:sp_ReversionSac(pempresa,psucursal,pusuario, pfolio) 
            ---     RETURNING cCodret2;
            --- END IF;
            
			--- ##################################################   2012.01.23 - Inicio   ##################################################
			LET cont_exist = 0;
            
			SELECT COUNT (referencia1) 
              into cont_exist
			  FROM bdisac:sac_movimientos
			 WHERE folio_suc = pfolio
			   AND id_sucursal = psucursal
			   AND status_cancelado <> 'S';
               
			IF cont_exist > 0 THEN
				CALL bdisac:sp_ReversionSac(pempresa,psucursal,pusuario, pfolio) 
                RETURNING cCodret2;
			ELSE
                ---------------------------------
			END IF;
			--- ##################################################   2012.01.23 - FIN   ##################################################
			
            SELECT {+index (bditef:tef_operaciones  idx_tef_operaciones1)} clave_rastreo
              into vclave_rastreo
              FROM bditef:"informix".tef_operaciones
             WHERE folio_suc = pfolio
               AND clave_rastreo <> ""
               AND fecha_trans = wfechoy 
               AND cve_status = 'PE'
               AND sucursal = psucursal;
               
            if (vclave_rastreo is not null or vclave_rastreo <> '') then						
			    UPDATE {+index (bditef:tef_operaciones  idx_tef_operaciones1)} 
                       bditef:"informix".tef_operaciones 
                   SET cve_status = '04' 
                 WHERE folio_suc = pfolio  
                   AND clave_rastreo <> "" 
                   AND fecha_trans = wfechoy 
                   AND cve_status = 'PE'
                   AND sucursal = psucursal;
            else
                ---------------------------------
			end if;
        ELSE
            IF (wnaturaleza = "A") THEN
                LET wsaldo_cuenta       = 0;
                LET wsdo_actual         = 0;
                LET wsdo_retenido       = 0;
                LET wsdo_sbc            = 0;
                LET wsdo_cong           = 0;

                SELECT sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc), sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbc
                  INTO wsaldo_cuenta, wsdo_actual, wsdo_retenido, wsdo_cong, wsdo_sbc
                  FROM sc_maechq
                 WHERE empresa = pempresa
                   AND cuenta = wcuenta;
                   
                IF wtransacc = '0325' THEN
                    LET wsaldo_cuenta = wsaldo_cuenta + wmonto_tot;
                END IF;

                IF wsaldo_cuenta < wfirme THEN
                    LET cod_ret = "413";
                    RETURN cod_ret;
                END IF;

                --- ##################################################   JOM INICIO   ##################################################
                UPDATE {+INDEX(sc_movdia idx_movdia_fechaserial)} sc_movdia
                   SET cancelad = "S"
                 WHERE fech_alt = TODAY
                   and cancelad <> "S"
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
                ( 0, pfolio, psucursal, pusuario, wfechoy, wfechoy, current hour to fraction(3), wtransacc, wsuc_cuen, wproducto,
                  pempresa, wcuenta, " ", wnum_cheq, wmonto_tot * -1, 0, 0, 0, 0, "S", " ", wsdo_actual, "0000", "REV", 0, vnum_tarjeta, "" );
                --- ##################################################   JOM FIN   ##################################################
                
                IF wen_sbc > 0 THEN
                    LET wmonto_tot = 0;

                    UPDATE sc_docret_sbc
                       SET cancelado = "S"
                     WHERE empresa = pempresa
                       AND cuenta = wcuenta
                       AND folio_suc = pfolio
                       AND fecha_alta = wfechoy;
                END IF;

                UPDATE sc_maechq
                   SET sdo_actual     = sdo_actual - wmonto_tot,
                       imp_chq_sbc    = imp_chq_sbc - wen_sbc,
                       imp_sbg_ccc    = imp_sbg_ccc - wimp_sbg_ccc,
                       imp_chq_sbg    = imp_chq_sbg - wimp_chq_sbg,
                       num_abonos_mes = num_abonos_mes - 1,
                       imp_abonos_mes = imp_abonos_mes - wmonto_tot - wen_sbc
                 WHERE empresa = pempresa
                   AND cuenta = wcuenta;
                   
                IF wtransacc = vtrancorrespchq THEN
                    UPDATE {+index (bdicheq:"informix".sc_acumdiacorresp idx_acumdiario)}sc_acumdiacorresp
                       SET monto_acum = monto_acum - wmonto_tot
                     WHERE cuenta = wcuenta;
                     
                    UPDATE {+index (bdicheq:"informix".sc_param_corresp idx_paramcorresp)}sc_param_corresp
                       SET valor = valor - wmonto_tot
                     WHERE codparam = '003'
                       AND empresa = pempresa;
                END IF;
                
                IF wtransacc = '0325' THEN
                    UPDATE sc_maechq
                       SET sdo_retenido = sdo_retenido - wmonto_tot
                     WHERE empresa = pempresa
                       AND cuenta = wcuenta;
                       
                    UPDATE sc_depinterpza
                       SET monto_ret = monto_ret - wmonto_tot,
                           monto_acum = monto_acum - wmonto_tot
                     WHERE fecha = wfechoy
                       AND num_cte = wnum_cte
                       AND cuenta = wcuenta;
                END IF;
                
                IF wtransacc = '0202' AND vtpo_per_valida IN('1','3') THEN
                    SELECT estado
                      INTO vestado_oper
                      FROM bdinteg:"informix".si_sucursales
                     WHERE sucursal = wsuc_tran;
                     
                    SELECT estado
                      INTO vestado_cta
                      FROM bdinteg:"informix".si_sucursales
                     WHERE sucursal = wsuc_cuen;
                     
                    IF vestado_oper <> vestado_cta THEN
                        UPDATE sc_depinterpza
                           SET monto_acum = monto_acum - wmonto_tot
                         WHERE fecha = wfechoy
                           AND num_cte = wnum_cte
                           AND cuenta = wcuenta;
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
                
				--- ##################################################   2012.01.23 - INICIO   ##################################################
                --- IF EXISTS ( SELECT referencia1
                ---               FROM bdisac:sac_movimientos
                ---              WHERE folio_suc = pfolio
                ---                AND id_sucursal = psucursal
                ---                AND status_cancelado <> 'S') THEN
                ---     CALL bdisac:sp_ReversionSac(pempresa,psucursal,pusuario, pfolio) 
                ---     RETURNING cCodret2;
                --- END IF;
                
				LET cont_exist = 0;
                
				SELECT COUNT (referencia1) 
                  into cont_exist
				  FROM bdisac:sac_movimientos
				 WHERE folio_suc = pfolio
				   AND id_sucursal = psucursal
				   AND status_cancelado <> 'S';
                   
				IF cont_exist > 0 THEN
					CALL bdisac:sp_ReversionSac(pempresa,psucursal,pusuario, pfolio) 
                    RETURNING cCodret2;
                ELSE
                    -----------------------------------
				END IF;
				--- ##################################################   2012.01.23 - FIN   ##################################################
                
				SELECT {+index (bditef:tef_operaciones  idx_tef_operaciones1)} 
                       clave_rastreo
                  into vclave_rastreo
                  FROM bditef:"informix".tef_operaciones
                 WHERE folio_suc = pfolio
                   AND clave_rastreo <> ""
                   AND fecha_trans = wfechoy 
                   AND cve_status = 'PE'
                   AND sucursal = psucursal;
						
                if (vclave_rastreo is not null or vclave_rastreo <> '') then						
				    UPDATE {+index (bditef:tef_operaciones  idx_tef_operaciones1)} bditef:"informix".tef_operaciones 
                       SET cve_status = '04' 
					 WHERE folio_suc = pfolio  
					   AND clave_rastreo <> "" 
					   AND fecha_trans = wfechoy 
                       AND cve_status = 'PE'
					   AND sucursal = psucursal;
				else
                    ---------------------------------
				end if;
            END IF;
        END IF;
        
        -- // Validación de limites 
        select {+index (bdinteg:"informix".si_usuario_limites idx_usualim)} usuario
          into vuser_limit
          from bdinteg:si_usuario_limites
         where usuario = wusuario
           and empresa = pempresa;
        
        if (vuser_limit is not null or vuser_limit <> '') then 
            IF (vuser_limit = "intercar") then
                select transacc, id_transacc, id_canal
                  into vtran_limit, vid_transacc, vid_canal
                  from bdinteg:si_transacc_limites
                 where transacc = wtransacc
                   and empresa = pempresa
                   and sistema = '01';
            ELSE
                SELECT id_canal 
                  into vid_canal
                  from bdinteg:si_canales
                 where cc_canal = psucursal;

                select transacc, id_transacc
                  into vtran_limit, vid_transacc
                  from bdinteg:si_transacc_limites
                 where transacc = wtransacc
                   and empresa = pempresa
                   and sistema = '01'
                   and id_canal = vid_canal;
            END IF;
           
            if (vtran_limit is not null or vtran_limit <> '') then
                execute procedure bdinteg:sp_reversa_acum_x(wfechoy, wnum_cte, wcuenta, vid_transacc, vid_canal, wmonto_tot)
                into cod_ret, vmsje_limites, vid_autor;
                
                let cod_ret = '000';
            end if;
        end if;

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
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_cons_prodcta(pTipo CHAR(2), pEmpresa CHAR(3), pCuenta CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	CHAR(5);  -- Producto

	--DEFINICION DE VARIABLES--
	DEFINE iSql_err		INTEGER;
	DEFINE cCodRet		CHAR(5);
	DEFINE cProducto	CHAR(5);

	--INICIALIZACION DE VARIABLES--
	LET iSql_err	= 0;
	LET cCodRet		= '00000';
	LET cProducto 	= '00000';

	-- pTipo = 1: Consulta tipo de producto para cuentas de Inversión
	-- pTipo = 2: Consulta tipo de producto para cuentas de Pagare

	--SET DEBUG FILE TO "/respaldosbd/Daniela/sp_cons_prodcta.out";
	--TRACE ON;

	IF NVL(pEmpresa, '') = '' OR NVL(pCuenta, '') = ''  THEN

		LET cCodRet = '00001';

	END IF;

	BEGIN

		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet, cProducto;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pTipo = 1 THEN
		
			IF EXISTS (SELECT cuenta FROM bdicheq:"informix".sc_maechq WHERE cuenta = pCuenta) THEN
			
				SELECT LIMIT 1 producto
				INTO cProducto
				FROM bdicheq:"informix".sc_maechq
				WHERE empresa = pEmpresa
				AND cuenta = pCuenta;
				
			ELSE
			
				LET cCodRet = '00002'; --No existe la cuenta de inversión creciente
				
			END IF;

		
		ELIF pTipo = 2 THEN
		
			IF EXISTS (SELECT cuenta FROM bdinvers:"informix".sv_maeinv WHERE empresa = pEmpresa AND cuenta = pCuenta) THEN
			
				SELECT LIMIT 1 cod_instrum
				INTO cProducto
				FROM bdinvers:"informix".sv_maeinv
				WHERE empresa = pEmpresa
				AND cuenta = pCuenta;
				
			ELIF EXISTS (SELECT cuenta FROM bdicheq:"informix".sc_maechq WHERE cuenta = pCuenta) THEN
			
				SELECT LIMIT 1 producto
				INTO cProducto
				FROM bdicheq:"informix".sc_maechq
				WHERE empresa = pEmpresa
				AND cuenta = pCuenta;
				
			END IF;
		
		END IF;

		RETURN  cCodRet, cProducto;

	END

END PROCEDURE

DOCUMENT
'Autor :Daniela Ramírez',
'FECHA : 31/08/2012',
'BD: bdicheq',
'Consulta el tipo de producto de una cuenta';

CREATE PROCEDURE "informix".sp_consultactasinversion(pOpticon INTEGER, pNumcte CHAR(20), pCuenta CHAR(20), pSecuencia SMALLINT)
	RETURNING CHAR(6) AS CodRetorno, CHAR(20) AS Cuenta, CHAR(104) AS Nombre, CHAR(1) AS Status;

--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);

DEFINE cNombre1 CHAR(26);
DEFINE cNombre2 CHAR(26);
DEFINE cApellPat CHAR(26);
DEFINE cApellMat CHAR(26);
DEFINE cNomCompleto CHAR(104);
DEFINE cCuenta CHAR(20);
DEFINE sCiclo SMALLINT;
DEFINE cNumProd CHAR(4);
DEFINE cStatus CHAR(1);

--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodRet = '000000';

LET cNombre1 = '';
LET cNombre2 = '';
LET cApellPat = '';
LET cApellMat = '';
LET cNomCompleto = '';
LET cCuenta = '';
LET sCiclo = 0;
LET cNumProd = '';
LET cStatus = '';


--SET DEBUG FILE TO '/respaldosbd/Martha/sp_consultactasinversion.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCuenta, cNomCompleto, cStatus;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF pOpticon = 1 THEN --Consulta Cuenas de Inversion por Numero de cliente
	
		SELECT nombre1, nombre2, apell_paterno, apell_materno
		INTO cNombre1, cNombre2, cApellPat, cApellMat
		FROM bdinteg:"informix".si_cliente WHERE numcte = pNumcte;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000279';
			RETURN cCodRet, cCuenta, cNomCompleto,cStatus;
		ELSE
			IF cNombre2 = '' THEN
				LET cNomCompleto = TRIM(cNombre1)||" "||TRIM(cApellPat)||" "||TRIM(cApellMat);
			ELSE
				LET cNomCompleto = TRIM(cNombre1)||" "||TRIM(cNombre2)||" "||TRIM(cApellPat)||" "||TRIM(cApellMat);
			END IF;
			
			FOREACH 
				SELECT cuenta INTO cCuenta FROM bdicheq:"informix".sc_maechq WHERE producto = '1100' AND num_cte = pNumcte AND status_cta <> 2
				
				LET sCiclo = sCiclo + 1;			
				IF sCiclo <= pSecuencia THEN
					CONTINUE FOREACH;
				END IF;
				
				RETURN cCodRet, cCuenta, TRIM(cNomCompleto),cStatus WITH RESUME;
				
			END FOREACH;
				
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '000272';
				RETURN cCodRet, cCuenta, cNomCompleto, cStatus;
			END IF;
						
		END IF;
		
	ELIF pOpticon = 2 THEN --Consulta cuentas de inversion y eje por numero de cuenta
		
		SELECT cuenta, producto,status_cta INTO cCuenta, cNumProd,cStatus FROM bdicheq:"informix".sc_maechq WHERE cuenta = pCuenta;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		
			LET cNumProd = SUBSTR(pCuenta,0,4);
			IF cNumProd = '1100' THEN
				LET cCodRet = '000276';
			ELSE
				LET cCodRet = '000278';
			END IF;
			
			RETURN cCodRet, cCuenta, cNomCompleto,cStatus;
					
		END IF;
		
		IF cNumProd = '1100' THEN --Cuentas Eje: si consulta por cuenta de inversion
			FOREACH
				SELECT cuentadep INTO cCuenta FROM bdicheq:"informix".sc_maeinstrucc WHERE empresa="001" and cuenta = pCuenta
			
				LET sCiclo = sCiclo + 1;			
				IF sCiclo <= pSecuencia THEN
					CONTINUE FOREACH;
				END IF;
				
				RETURN cCodRet, cCuenta, cNomCompleto, cStatus WITH RESUME;
			END FOREACH;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '000274';
				RETURN cCodRet, cCuenta, cNomCompleto,cStatus;
			END IF;
			
		ELSE --Cuentas Inversion: si consulta por cuenta eje
			
			FOREACH
				SELECT cuenta INTO cCuenta FROM bdicheq:"informix".sc_maeinstrucc WHERE cuentadep = pCuenta
			
				LET sCiclo = sCiclo + 1;			
				IF sCiclo <= pSecuencia THEN
					CONTINUE FOREACH;
				END IF;
				
				RETURN cCodRet, cCuenta, cNomCompleto,cStatus WITH RESUME;
			END FOREACH;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '000275';
				RETURN cCodRet, cCuenta, cNomCompleto,cStatus;
			END IF;
			
		END IF;
		
	END IF;
		
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Consulta las cuentas de inversion creciente del cliente por medio del numero de cliente, cuenta eje o cuenta creciente',
'AUTOR : Adrian Lara',
'FECHA : 16/05/2012',
'BD: bdicheq',
'SISTEMA : 1';

CREATE PROCEDURE "informix".sp_consinstruvenci(pEmpresa CHAR(3), pCuenta CHAR(20))
	--DATOS A REGRESAR
	RETURNING
	CHAR(5)  AS CodigoRetorno,
	CHAR(40) AS Descripcion;

	DEFINE iSql_err	  	INTEGER;
	DEFINE cCodRet      CHAR(5);
	DEFINE cDescripcion	CHAR(40);
	DEFINE cInstrucc    CHAR(2);
	
	LET iSql_err     = 0;
	LET cCodRet      = '00000';
	LET cDescripcion = '';
	LET cInstrucc    = '';

	--SET DEBUG FILE TO "/respaldosbd/Daniela/sp_consinstruvenci.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet, cDescripcion; 
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pEmpresa IS NULL OR pEmpresa = '' THEN
			LET cCodRet = '00001';  --Falta el Campo Empresa.
        ELIF pCuenta IS NULL OR pCuenta = '' THEN
			LET cCodRet = '00002';  --Falta el Número de Cuenta.
		ELSE
			SELECT instrucc INTO cInstrucc
			FROM bdicheq: "informix".sc_maeinstrucc WHERE empresa = pEmpresa AND cuenta = pCuenta;
			
			IF cInstrucc IS NULL OR cInstrucc = '' THEN
				LET cCodRet = '00003';  --No Existe Intrucción para esa Cuenta.
			ELSE
				SELECT descripcion INTO cDescripcion
				FROM bdicheq: "informix".sc_instrucc WHERE empresa = pEmpresa AND instrucc = cInstrucc;
				
				IF cDescripcion IS NULL OR cDescripcion = '' THEN
					LET cCodRet = '00004';  --No Existe Descripción para esa Intrucción.
				END IF;
			END IF;
		END IF;
		
		RETURN cCodRet, cDescripcion;
		
	END
END PROCEDURE

DOCUMENT
'Consultar la descripción de la instrucción de vencimiento del cliente.',
'Autor :Rodolfo Tortolero Varela',
'FECHA :17/Diciembre/2012',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_consultarinversioncreciente(cNumCta CHAR(20), cEmpresa CHAR(3))
RETURNING CHAR(5),      -- Código de Retorno
          CHAR(104),    -- Nombre del cliente
          CHAR(20),     -- Tipo de persona
          CHAR(40),     -- Producto
          MONEY(14,2),  -- Capital
          DECIMAL(9,6), -- Taza Bruta Meta
          DATE,         -- Fecha de Apertura
          DATE,         -- Fecha Vencimiento
          CHAR(20),     -- Cuenta Referencia
          CHAR(45),     -- Promotor
          CHAR(1),      -- Estatus de la cuenta
		  CHAR(20);		-- Número de Cliente 'DSB 30/07/2012
          
    --DEFINICION DE VARIABLES--
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRet CHAR(5);	
    ---------------------------	
    DEFINE cNomCliente    CHAR(104);
    DEFINE cTipoPersona   CHAR(20);
    DEFINE cDescProducto  CHAR(40);
    DEFINE cProducto      CHAR(4);
    DEFINE mCapital       MONEY(14,2);
    DEFINE dTazaBruta     DECIMAL(9,6);
    DEFINE dFechaAper     DATE;
    DEFINE dFechaVen      DATE;
    DEFINE cCtaReferencia CHAR(20);
    DEFINE cPromotor      CHAR(45);
    DEFINE cEstatusCta    CHAR(1);
    DEFINE cProductoParam CHAR (60);
	DEFINE cNumCte		  CHAR(20); --'DSB 30/07/2012

    --INICIALIZACION DE VARIABLES-- 
    LET iSqlErr        = 0;
    LET cCodRet        = '00000';
    LET cNomCliente    = '';
    LET cTipoPersona   = '';
    LET cDescProducto      = '';
    LET cProducto      = '';
    LET mCapital       = 0;
    LET dTazaBruta     = 0;
    LET dFechaAper      = '';
    LET dFechaVen       = '';
    LET cCtaReferencia = '';
    LET cPromotor      = '';
    LET cEstatusCta    = '';
	LET cNumCte			= ''; --'DSB 30/07/2012

     
	 --SET DEBUG FILE TO "/respaldosbd/Martha/sp_consultarinversioncreciente.out";
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN 
    
    ON EXCEPTION SET iSqlErr 
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cNomCliente, cTipoPersona, cDescProducto, mCapital, dTazaBruta, dFechaAper, dFechaVen, cCtaReferencia, cPromotor, cEstatusCta, cNumCte;   
        END IF;    
    END EXCEPTION;	

    IF cNumCta IS NULL OR cNumCta = '' OR cEmpresa IS NULL OR cEmpresa = '' THEN
        LET cCodRet = "102"; -- Parámetros de entrada vacíos 
    ELSE
        -- Obtiene datos del cliente
        SELECT TRIM(b.nombre1) || ' ' || TRIM(b.nombre2) || ' ' || TRIM(b.apell_paterno) || ' ' || TRIM(b.apell_materno),
               c.descripcion, a.status_cta, a.imp_chq_rem, d.nombre, d.producto, Trim(b.numcte)
          INTO cNomCliente, cTipoPersona, cEstatusCta, mCapital, cDescProducto, cProducto, cNumCte
          FROM bdicheq:"informix".sc_maechq a,
               bdinteg:"informix".si_cliente b,
               bdinteg:"informix".si_tipper c,
               bdicheq:"informix".sc_producto d
         WHERE a.cuenta = cNumCta
           AND a.num_cte = b.numcte           
           AND b.tpo_persona = c.tpo_persona
           AND a.producto = d.producto;

        IF cNomCliente IS NULL OR cNomCliente = '' OR cTipoPersona IS NULL OR cTipoPersona = '' OR 
           cEstatusCta IS NULL OR cEstatusCta = '' OR mCapital IS NULL OR mCapital = '' OR 
           cDescProducto IS NULL OR cDescProducto  = '' OR cProducto IS NULL OR cProducto  = '' THEN
            LET cCodRet = "100"; --  No se encontró información referente a los datos de la cuenta
        ELSE
            -- Consulta de parametro producto inversion creciente 
			  SELECT TRIM(valor)
              INTO cProductoParam
              FROM bdicheq:"informix".sc_param 
             WHERE empresa = cEmpresa 
               AND codparam = 'PRODCREC'; 

            IF cProductoParam IS NULL OR cProductoParam ="" THEN
                LET cCodRet = "101";
            ELSE
                IF cProducto <> cProductoParam THEN
                    LET cCodRet = "104";
                ELSE
                    -- Obtiene Promotor, Fecha de Apertura y Fecha de Vencimiento
                    SELECT a.nombre, b.fecha_alta, b.fecha_mod
                      INTO cPromotor, dFechaAper, dFechaVen
                      FROM bdinteg:"informix".si_ejecut a,
                           bdicheq:"informix".sc_maenoc b
                     WHERE b.empresa = cEmpresa
                       AND b.cuenta = cNumCta
                       AND b.ejecutivo = a.ejecutivo;

                    IF cPromotor IS NULL OR cPromotor = '' OR dFechaAper IS NULL OR dFechaAper = '' OR dFechaVen IS NULL OR dFechaVen = '' THEN
                        LET cCodRet = "101"; -- No se encontró información 
                    ELSE
                        -- Obtiene la Cuenta de Referencia 
                        SELECT cuentadep
                          INTO cCtaReferencia
                          FROM bdicheq:"informix".sc_maeinstrucc
                         WHERE empresa = cEmpresa
                           AND cuenta = cNumCta;

                        IF cCtaReferencia IS NULL OR cCtaReferencia = '' THEN
                            LET cCodRet = "103"; -- No se encontró información
                        ELSE
                            --  Se obtiene el valor de la Taza Bruta Meta 
                            SELECT valor_tasa
                              INTO dTazaBruta
                              FROM bdicheq:"informix".sc_tasa_variable
                             WHERE empresa = cEmpresa
                               AND cuenta = cNumCta
                               AND tipo_tasa = 'P';

                            IF dTazaBruta IS NULL OR dTazaBruta = '' THEN
                                LET cCodRet = "101"; -- No se encontró información
                            END IF;
                        END IF;					
                    END IF;
                END IF;
            END IF;
        END IF;	
    END IF;

    RETURN cCodRet, cNomCliente, cTipoPersona, cDescProducto, mCapital, dTazaBruta, dFechaAper, dFechaVen, cCtaReferencia, cPromotor, cEstatusCta,cNumCte;

    END;
    
END PROCEDURE
DOCUMENT
"Autor : Martha Aguirre",
"FECHA : 25/05/2012",
"Descripcion: Consulta las datos de inversión creciente ",
" cuando la cuenta está en estatus cancelada",
"Ver.  : 1.0",
"BD    : bdicheq",

"Modifico : Daniela Ramirez (DSB 30/07/2012)",
"FECHA : 30/07/2012",
"Descripcion: Se agrega parametro de retorno numero de cliente";

CREATE PROCEDURE "informix".sp_cce_actualizarfechacheques
(
pEmpresa            CHAR(3),
pFechaPresentacion  CHAR(10),
pCtaDelCheque       CHAR(20),
pNumCheque          CHAR(7),
pMonto              DECIMAL(14,2)
)
RETURNING
	CHAR(6) 		AS cod_ret,
    CHAR(80) 		AS desc_ret

	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cDescRet		    CHAR(80);
    DEFINE cCodRet			CHAR(6);

	DEFINE mImporte		    MONEY(14,2);
	DEFINE cNumCuenta		CHAR(20);
	DEFINE cBanco			CHAR(3);
	DEFINE cDescBanco		CHAR(40);
    DEFINE dtFechaHoy       DATE;

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= "";
    LET cDescRet		    = "PROCESO EXITOSO";
	LET cCodRet				= "000000";

    LET mImporte		    = 0.0;
	LET cNumCuenta			= "";
	LET cBanco				= "";
	LET cDescBanco			= "";
    LET dtFechaHoy          = DATE(1);


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
            LET cDescRet = cErrorInfo;
			RETURN cCodRet,cDescRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/respaldosbd/has/sp_cce_actualizarfechacheques.out';
	--TRACE ON;

	IF NVL(pEmpresa,"") = "" OR NVL(pFechaPresentacion,"") = "" OR NVL(pCtaDelCheque,"") = "" OR NVL(pNumCheque,"") = "" OR pMonto IS NULL THEN
        LET cCodRet = "000001";
        LET cDescRet = "FALTAN PARAMETROS DE ENTRADA";
	ELSE
        SELECT fecha_hoy
        INTO dtFechaHoy
        FROM "informix".sc_fechas
        WHERE empresa = pEmpresa;
    
        UPDATE bditef:"informix".cce_cheques_det
        SET fechapresenta = dtFechaHoy
        WHERE fechapresenta = pFechaPresentacion
        AND presentado = "0"
        AND numcuenta::INT8 = pCtaDelCheque::INT8
        AND numcheque = pNumCheque
        AND monto = pMonto;

        IF dbinfo("sqlca.sqlerrd2") = 0 THEN
            LET cCodRet = "000002";
            LET cDescRet = "NO SE ENCUENTRA EL CHEQUE PARA ACTUALIZAR";
            RETURN cCodRet,cDescRet;
        END IF
	END IF
    
    RETURN cCodRet,cDescRet;
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para actusalizar la fecha de presentacion del cheque para que sea tomado en cuenta por el proceso de la presentacion', 
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Febrero 2013',
'VERSION: 20130226.1911';

CREATE PROCEDURE "informix".sp_cce_consultarchequexpresentar
(
pEmpresa            CHAR(3),
pCtaDeposito        CHAR(20),
pNumCheque          INTEGER,
pFechaPresentacion  CHAR(10)
)
RETURNING
	CHAR(6)         AS cod_ret,
    CHAR(80)        AS desc_ret,
	MONEY(14,2)     AS importe,
	CHAR(20)        AS cuenta_cheque,
    CHAR(3)         AS cve_banco,
	CHAR(40)        AS desc_banco

	---DECLARACIONES
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cErrorInfo       CHAR(80);
    DEFINE cDescRet         CHAR(80);
    DEFINE cCodRet          CHAR(6);

	DEFINE mImporte         MONEY(14,2);
	DEFINE cNumCuenta       CHAR(20);
	DEFINE cBanco           CHAR(3);
	DEFINE cDescBanco       CHAR(40);

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= "";
    LET cDescRet		    = "PROCESO EXITOSO";
	LET cCodRet				= "000000";

    LET mImporte		    = 0.0;
	LET cNumCuenta			= "";
	LET cBanco				= "";
	LET cDescBanco			= "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
            LET cDescRet = cErrorInfo;
			RETURN cCodRet,cDescRet,mImporte,cNumCuenta,cBanco,cDescBanco;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/respaldosbd/has/sp_cce_consultarchequexpresentar.out';
	--TRACE ON;

	IF NVL(pEmpresa,"") = "" OR NVL(pCtaDeposito,"") = "" OR NVL(pNumCheque,"") = ""  OR NVL(pFechaPresentacion,"") = "" THEN
        LET cCodRet = "000001";
        LET cDescRet = "FALTAN PARAMETROS DE ENTRADA";
		RETURN cCodRet,cDescRet,mImporte,cNumCuenta,cBanco,cDescBanco;
	ELSE
        FOREACH	WITH HOLD
            SELECT doc.monto, doc.numcuenta, ba.banco, ba.descripcion
            INTO mImporte, cNumCuenta, cBanco, cDescBanco
            FROM "informix".sc_docret_sbc doc, bditef:"informix".cce_cheques_det cce, bdinteg:"informix".si_bancos ba
            WHERE doc.empresa = pEmpresa
            AND doc.banco = ba.banco
            AND doc.transacc IN (SELECT transacc FROM bditef:cce_mapeo_cecoban where empresa = pEmpresa and transacc = transacc and tipo_cta_dep = tipo_cta_dep)
            AND doc.cancelado = "T"
            AND doc.banco = cce.cvebanco
            AND doc.numcuenta::INT8 = cce.numcuenta::INT8
            AND doc.num_chq = cce.numcheque::INTEGER
            AND cce.fechapresenta = pFechaPresentacion
            AND cce.presentado = "0"
            AND doc.cuenta::INT8 = pCtaDeposito::INT8
            AND doc.num_chq = pNumCheque
			
            RETURN cCodRet,cDescRet,NVL(mImporte,0),NVL(cNumCuenta,""),NVL(cBanco,""),NVL(cDescBanco,"") WITH RESUME;
        END FOREACH	
        IF dbinfo("sqlca.sqlerrd2") = 0 THEN
            LET cCodRet = "000002";
            LET cDescRet = "NO EXISTEN DATOS";
            RETURN cCodRet,cDescRet,mImporte,cNumCuenta,cBanco,cDescBanco;
        END IF
	END IF
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener los datos de los cheques que no se encuentran presentados porque tienen fecha de presentacion anterior a la fecha de hoy del sistema', 
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Febrero 2013',
'VERSION: 20130222.1720';

CREATE PROCEDURE "informix".sp_cce_consultarchqsxpresentar
(
pEmpresa            CHAR(3)
)
RETURNING
	CHAR(6)         AS cod_ret,
    CHAR(80)        AS desc_ret,
	CHAR(4)         AS sucursal,
	CHAR(40)        AS desc_sucursal,
	CHAR(10)        AS fecha_presentacion,
	CHAR(20)        AS cuenta_deposito,
	CHAR(3)         AS cve_banco,
	CHAR(40)        AS desc_banco,
	CHAR(20)        AS cuenta_cheque,
	INTEGER        	AS numero_cheque,
	MONEY(14,2)     AS importe,
	CHAR(10)		AS fecha_hoy
	
	---DECLARACIONES
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cErrorInfo       CHAR(80);
    DEFINE cDescRet         CHAR(80);
    DEFINE cCodRet          CHAR(6);

	DEFINE cSucursal		CHAR(4);
	DEFINE cDescSucursal	CHAR(40);
	DEFINE cFechaPres		CHAR(10);
	DEFINE cCtaDeposito		CHAR(20);
	DEFINE cBanco           CHAR(3);
	DEFINE cDescBanco       CHAR(40);
	DEFINE cCtaDelCheque    CHAR(20);
	DEFINE iNumCheque    	INTEGER;
	DEFINE mImporte         MONEY(14,2);
	DEFINE cFechaHoy		CHAR(10);

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= "";
    LET cDescRet		    = "PROCESO EXITOSO";
	LET cCodRet				= "000000";
	
	LET cSucursal			= "";
	LET cDescSucursal		= "";
	LET cFechaPres			= "";
	LET cCtaDeposito		= "";
	LET cBanco				= "";
	LET cDescBanco			= "";
	LET cCtaDelCheque		= "";
	LET iNumCheque    		= 0;
    LET mImporte		    = 0.0;
	LET cFechaHoy			= "";
	


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
            LET cDescRet = cErrorInfo;
			RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/respaldosbd/has/sp_cce_consultarchqsxpresentar.out';
	--TRACE ON;

	IF NVL(pEmpresa,"") = "" THEN
        LET cCodRet = "000001";
        LET cDescRet = "FALTAN PARAMETROS DE ENTRADA";
		RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy;
	ELSE
		--OBTIENE LA FECHA DEL SISTEMA
		SELECT fecha_hoy
		INTO cFechaHoy
		FROM "informix".sc_fechas;
		
        FOREACH	WITH HOLD
			SELECT doc.sucursal, suc.nombre, cce.fechapresenta, doc.cuenta AS CTA_DEPOSITO, ba.banco, ba.descripcion, doc.numcuenta AS CTA_CHEQUE, doc.num_chq, doc.monto
			INTO cSucursal, cDescSucursal, cFechaPres, cCtaDeposito, cBanco, cDescBanco, cCtaDelCheque, iNumCheque, mImporte
			FROM "informix".sc_docret_sbc doc, bditef:"informix".cce_cheques_det cce, bdinteg:"informix".si_bancos ba, bdinteg:"informix".si_sucursales suc
			WHERE doc.empresa = pEmpresa
			AND doc.banco = ba.banco
			AND doc.transacc IN (SELECT transacc FROM bditef:cce_mapeo_cecoban where empresa = pEmpresa and transacc = transacc and tipo_cta_dep = tipo_cta_dep)
			AND doc.cancelado = "T"
			AND doc.banco = cce.cvebanco
			AND doc.numcuenta::INT8 = cce.numcuenta::INT8
			AND doc.num_chq = cce.numcheque::INTEGER
			AND cce.fechapresenta < cFechaHoy
			AND cce.presentado = "0"
			AND doc.sucursal = suc.sucursal
			
            RETURN cCodRet,cDescRet,NVL(cSucursal,""),NVL(cDescSucursal,""),
				SUBSTR(cFechaPres,7,4) || "/" || SUBSTR(cFechaPres,1,2) || "/" || SUBSTR(cFechaPres,4,2),
				NVL(cCtaDeposito,""),NVL(cBanco,""),NVL(cDescBanco,""),NVL(cCtaDelCheque,""),NVL(iNumCheque,0),NVL(mImporte,0.0)
				,NVL(SUBSTR(cFechaHoy,7,4) || "/" || SUBSTR(cFechaHoy,1,2) || "/" || SUBSTR(cFechaHoy,4,2),"") 
			WITH RESUME;
        END FOREACH	
        IF dbinfo("sqlca.sqlerrd2") = 0 THEN
            LET cCodRet = "000002";
            LET cDescRet = "NO EXISTEN DATOS";
            RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy;
        END IF
	END IF
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener los datos de los cheques que no se encuentran presentados porque tienen fecha de presentacion anterior a la fecha de hoy del sistema', 
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Febrero 2013',
'VERSION: 20130222.1720';

CREATE PROCEDURE "informix".sp_actnumcheques() 
RETURNING CHAR(5), CHAR(80);
--DEFINICION DE VARIABLES
DEFINE vc_CodRet			CHAR(5);
DEFINE vi_SqlErr			INTEGER;
DEFINE vi_iSAMErr			INTEGER;
DEFINE vi_iSAMData			CHAR(80);
DEFINE vc_Mensaje			CHAR(80);
DEFINE cCuenta			    CHAR(20);
DEFINE inumeroconteo		INTEGER;
DEFINE inumerochq			INTEGER;
--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET vi_iSAMErr=0;
LET vi_iSAMData="";
LET vc_Mensaje = "EL PROCESO SE EFECTUO CORRECTAMENTE";
LET cCuenta="";
LET inumeroconteo=0;
LET inumerochq=0;


    BEGIN

    ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            LET vc_Mensaje = "ERROR NO CONTROLADO";
            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/informix/VH/chequeras/sp_actnumcheques.out";
    --TRACE ON;

	SET ISOLATION TO DIRTY READ;
	FOREACH

		SELECT cuenta,max(numero) INTO cCuenta,inumeroconteo FROM sc_contch
		WHERE cuenta IN (
		SELECT DISTINCT cuenta FROM sc_contch)
		GROUP BY cuenta
		ORDER BY cuenta

		SELECT ult_chq INTO inumerochq FROM sc_maechq WHERE empresa='001' AND cuenta=cCuenta;
		
		IF inumeroconteo<>inumerochq THEN
			UPDATE "informix".sc_maechq SET ult_chq = inumeroconteo WHERE empresa='001' AND cuenta=cCuenta;
		END IF;

	END FOREACH;  

	RETURN vc_CodRet, vc_Mensaje;
END;
END PROCEDURE;