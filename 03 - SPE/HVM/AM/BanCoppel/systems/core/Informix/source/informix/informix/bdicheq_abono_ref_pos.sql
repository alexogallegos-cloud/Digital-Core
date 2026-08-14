CREATE PROCEDURE "informix".abono_ref_pos( pempresa     CHAR(3),
                                           psucursal    CHAR(4),
                                           pusuario     CHAR(8),
                                           ptransacc    CHAR(4),
                                           ptransuc     CHAR(4),
                                           pfolio_suc   CHAR(16),
                                           pcuenta      CHAR(20),
                                           pdocto       INTEGER,
                                           pmto_tot     MONEY(14,2),
                                           pmto_firme   MONEY(14,2),
                                           pmto_sbc     MONEY(14,2),
                                           pmto_rem     MONEY(14,2),
                                           pdias_ret    SMALLINT,
                                           pdivisa      CHAR(2),
                                           preferencia  CHAR(40),
                                           pnum_tarjeta CHAR(16),
                                           pusuautoriza CHAR(8),
                                           preferencia23 CHAR(23) )
RETURNING CHAR(5);
    
    -- ********************************************************************
    -- Nombre:              abono_ref
    -- Version:             1.0.1
    -- Objetivo:            Deposito a cuenta de cheques desde sucursal...
    -- Supuestos:           Ninguno
    -- Creado por:          
    -- Modificado por:      Alejandro Rueda S.
    -- Ultima Modificacion: Mayo 2010
    --                      Reingenieria de SPL
    -- ********************************************************************

    DEFINE vcodret              CHAR(5);
    DEFINE cCodRet3             CHAR(5);
	DEFINE cCodRet4             CHAR(5);
    DEFINE vsqlerr              INTEGER;
    DEFINE vsuccta              CHAR(4);
    DEFINE vexiste              CHAR(1);
    DEFINE vproducto            CHAR(4);
    DEFINE vgencom              CHAR(1);
    DEFINE vcobracom            CHAR(1);
    DEFINE vvaldoc              CHAR(1);
    DEFINE vnat                 CHAR(1);
    DEFINE vstatus              CHAR(1);
    DEFINE vaceptab             CHAR(1);
    DEFINE vmotivo              CHAR(2);
    DEFINE vmoneda              CHAR(2);
    DEFINE vmontotran           MONEY(14,2);
    DEFINE vsdo_actual          MONEY(14,2);
    DEFINE vimpsbg              MONEY(14,2);
    DEFINE vtotal_sbc           MONEY(14,2);
    DEFINE vdepinic             MONEY(14,2);
    DEFINE vfecha_hoy           DATE;
    DEFINE vfecha_prox          DATE;
    DEFINE vfecha_sistema       DATE;
    DEFINE vhora                DATETIME HOUR TO FRACTION(3);
    DEFINE vusuario             CHAR(8);
    DEFINE vtasa_aplicada       DECIMAL(9,6);
    DEFINE vmarca_ret           CHAR(1);
    DEFINE vdepinicial          MONEY(14,2);
    DEFINE vmtominape           MONEY(14,2);
    DEFINE vdepminini           MONEY(14,2);
    DEFINE vacepta_depositos    CHAR(1);
    DEFINE vper_depositos       CHAR(1);
    DEFINE vdiasultdep          SMALLINT;
    DEFINE vdiasdep             SMALLINT;
    DEFINE vfecultmov           DATE;
    DEFINE vfecultdep           DATE;
    DEFINE vfecultret           DATE;
    DEFINE vtranpagint          CHAR(4);
    DEFINE vtranusoccc          CHAR(4);
    DEFINE vtranusosbg          CHAR(4);
    DEFINE vtranabocol          CHAR(4);
    DEFINE vnumcte              CHAR(20);
    DEFINE vmto_apertura        MONEY(14,2);
    DEFINE vtransaccion         INTEGER;
    DEFINE vfech_spei           CHAR(10);
    DEFINE vfech_val            DATE;
    DEFINE vfecha_proc          DATE;
    
    DEFINE vestado_oper         CHAR(2);
    DEFINE vestado_cta          CHAR(2);
    DEFINE vmonto_acum          DECIMAL(18,2);
    DEFINE vmonto_perm          DECIMAL(16,2);
    DEFINE vacumula             CHAR(1);
    DEFINE vinterpza            CHAR(1);
    DEFINE vaumentaret          CHAR(1);
    DEFINE vexiste_acum         SMALLINT;
    DEFINE vtpo_per_valida      CHAR(1);
    
    DEFINE vlimdepefec          DECIMAL(18,2);
    DEFINE vmtodepacum          DECIMAL(18,2);
	DEFINE vfecha_operacion		DATE;

    LET vusuario        = USER;
    LET vcodret         = "000";
    LET vsqlerr         = 0;
    LET vtransaccion    = 0;
    LET vmonto_acum     = 0;
    LET vmonto_perm     = 0;
    LET vacumula        = '0';
    LET vinterpza       = '0';
    LET vaumentaret     = '0';
    LET vexiste_acum    = 0;
    LET vtpo_per_valida = '';
    
    LET vlimdepefec = 0.00;
    LET vmtodepacum = 0.00;
	LET vfecha_operacion = TODAY;

    BEGIN
    
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF 
            RETURN vcodret;
        END IF
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;
    
    --- SET ISOLATION TO CURSOR STABILITY;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    --- SET DEBUG FILE TO "/tmp/abono_ref.out";
    --- TRACE ON;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    LET vtasa_aplicada = 0;
    LET vgencom = 0;
    LET vcobracom = "0";
    LET vmto_apertura = 0;
    
    -- // Valida la informacion de entrada
    IF psucursal  = "" OR pusuario   = "" OR 
       ptransacc  = "" OR pfolio_suc = "" OR 
       pcuenta    = "" OR pmto_tot   = 0  OR 
       pmto_firme < 0  OR pmto_sbc   < 0  OR 
       pmto_rem   < 0  OR pdias_ret  < 0  THEN
        LET vcodret = 110;
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vcodret;
    END IF;
    
    -- // Obtiene fechas del sistema de cheques
    SELECT {+INDEX(sc_fechas idx_fechas1)} 
           fecha_hoy, prox_fecha, fecha_hoy
      INTO vfecha_hoy, vfecha_prox, vfecha_sistema
      FROM sc_fechas 
     WHERE empresa = pempresa;
     
    -- // Valida la suma de los montos
    LET vmontotran = pmto_firme + pmto_sbc + pmto_rem;
    IF vmontotran != pmto_tot OR pmto_tot = 0 THEN
        LET vcodret = "420";
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vcodret;
    END IF;
    
    IF ptransacc = '1193' or ptransacc = '1195' THEN
        EXECUTE PROCEDURE  bdicheq:sp_validahorariopitdc() 
        INTO cCodRet3, cCodRet4;
        
        IF CAST(cCodRet3 AS INTEGER) <> 0 THEN
            LET vcodret  = cCodRet3;
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN vcodret;
        ELIF CAST(cCodRet4 AS INTEGER) <> 0 THEN
            LET vcodret = "233";
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN vcodret;
        END IF;
	END IF;

    -- // Valida que exista la transaccion
    SELECT naturaleza, valida_docto, dias_ret
      INTO vnat, vvaldoc, pdias_ret
      FROM bdinteg:si_transacc
     WHERE empresa = pempresa 
       AND numero = ptransacc;

    IF vnat IS NULL THEN
        LET vcodret = "552";
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vcodret;
    END IF;

    -- // Valida que la naturaleza sea de abono
    IF vnat != "A" THEN
        LET vcodret = "552";
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vcodret;
    END IF;

	-- // Valida la sucursal para transacciones de aclaraciones
	IF ptransacc IN('0340', '0345') THEN
	   SELECT sucursal 
	     INTO psucursal
	     FROM bdinteg:si_sucursales
		WHERE sucursal = psucursal;
        
        IF psucursal is null or psucursal = "" THEN
            SELECT sucursal
              INTO psucursal		  
		      FROM bdinteg:si_ejecut 
		     WHERE ejecutivo in(SELECT num_empleado 
		                          FROM bdiaclaracion:acl_aclaracion 
							     WHERE folio_csuac = preferencia);
        END IF;
    END IF;	   
		
    -- // Inicializa los dias de retencion
    IF pdias_ret IS NULL THEN
        LET pdias_ret = 0;
    END IF;

    -- // Valida exista la cuenta
    SELECT status_cta, fecha_proceso, producto, sucursal, num_cte
      INTO vstatus, vfecha_hoy, vproducto, vsuccta, vnumcte
      FROM sc_maechq
     WHERE empresa = pempresa 
       AND cuenta = pcuenta;
       
    SELECT tpper_valida
      INTO vtpo_per_valida
      FROM sc_producto
     WHERE producto = vproducto;

	IF vproducto = '2300' AND ptransacc = '0202' THEN
	   LET vcodret = '100';
	   RETURN vcodret;
	END IF
    
    IF vproducto = '2800' AND ptransacc = '0202' THEN
	   LET vcodret = '403';
	   RETURN vcodret;
	END IF
	   
    IF vstatus IS NULL THEN
        LET vcodret = "100";
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vcodret;
    END IF
    
    IF vstatus = '6' AND ptransacc = '0324' THEN
        LET vstatus = '1';
        LET vfecha_hoy = vfecha_sistema;
    END IF;

    -- // Valida que la cuenta no este cancelada
    IF vstatus in ("2","6","7","8") THEN
        LET vcodret = "200";
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vcodret;
    END IF
    
    -- // Valida cuentas inactivas
    IF vstatus IN("4","5") THEN
        LET vfecha_hoy = vfecha_sistema;
    END IF

    -- // Trae la fecha del dia de hoy en cheques...
    IF vfecha_hoy IS NULL THEN
        LET vfecha_hoy = vfecha_sistema;
    END IF
    
    IF ptransacc = '0202' AND vtpo_per_valida IN('1','3') AND vproducto <> '1100' THEN
        -- // VALIDA MONTO MENSUAL ACUMULADO POR CLIENTE DE DEPOSITOS EN EFECTIVO
        SELECT valor
          INTO vlimdepefec
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = 'LimDepositosEfetivo';
    
        SELECT SUM(monto)
          INTO vmtodepacum
          FROM sc_depositosefectivo
         WHERE num_cte = vnumcte;
         
        IF vmtodepacum is null THEN
            LET vmtodepacum = 0.00;
        END IF;
        
        LET vmtodepacum = vmtodepacum + pmto_tot;
        
        IF vmtodepacum > vlimdepefec THEN
            LET vcodret = '397';
            RETURN vcodret;
        END IF;
    
        -- // VALIDACIONES INTERESTADO
        SELECT cve_estado
          INTO vestado_oper
          FROM bdinteg:"informix".si_ptf
         WHERE id_ptf = psucursal 
           AND tipo = 'S';
        
        /*SELECT estado
          INTO vestado_oper
          FROM bdinteg:"informix".si_sucursales
         WHERE sucursal = psucursal;*/
         
        SELECT cve_estado
          INTO vestado_cta
          FROM bdinteg:"informix".si_ptf
         WHERE id_ptf = vsuccta 
           AND tipo = 'S';
        
        /*SELECT estado
          INTO vestado_cta
          FROM bdinteg:"informix".si_sucursales
         WHERE sucursal = vsuccta;*/
         
        IF vestado_oper <> vestado_cta THEN
            SELECT monto_acum
              INTO vmonto_acum
              FROM sc_depinterpza
             WHERE fecha = vfecha_sistema
               AND num_cte = vnumcte
               AND cuenta = pcuenta;
               
            IF vmonto_acum is null THEN
                LET vmonto_acum = 0.00;
            END IF;
               
            LET vmonto_acum = vmonto_acum + pmto_tot;
               
            SELECT valor
              INTO vmonto_perm
              FROM sc_param
             WHERE empresa = pempresa
               AND codparam = 'MontoDepInterPlaza';
               
            IF vmonto_acum >= vmonto_perm THEN
                LET vcodret = '371';
                RETURN vcodret;
            END IF;
            
            LET vacumula  = '1';
            LET vinterpza = '1';
        END IF;
    END IF;
    
    IF ptransacc = '0325' THEN
        -- // VALIDA MONTO MENSUAL ACUMULADO POR CLIENTE DE DEPOSITOS EN EFECTIVO
        SELECT valor
          INTO vlimdepefec
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = 'LimDepositosEfetivo';
    
        SELECT SUM(monto)
          INTO vmtodepacum
          FROM sc_depositosefectivo
         WHERE num_cte = vnumcte;
         
        IF vmtodepacum is null THEN
            LET vmtodepacum = 0.00;
        END IF;
        
        LET vmtodepacum = vmtodepacum + pmto_tot;
        
        IF vmtodepacum > vlimdepefec THEN
            LET vcodret = '397';
            RETURN vcodret;
        END IF;
        
        -- // VALIDACIONES INTERESTADO
        IF vtpo_per_valida IN ('2','4') THEN
            LET vcodret = '375';
            RETURN vcodret;
        END IF;
    
        SELECT cve_estado
          INTO vestado_oper
          FROM bdinteg:"informix".si_ptf
         WHERE id_ptf = psucursal 
           AND tipo = 'S'; 
        
        /*SELECT estado
          INTO vestado_oper
          FROM bdinteg:"informix".si_sucursales
         WHERE sucursal = psucursal;*/
         
        SELECT cve_estado
          INTO vestado_cta
          FROM bdinteg:"informix".si_ptf
         WHERE id_ptf = vsuccta 
           AND tipo = 'S';

        /*SELECT estado
          INTO vestado_cta
          FROM bdinteg:"informix".si_sucursales
         WHERE sucursal = vsuccta;*/
         
        IF vestado_oper = vestado_cta THEN
            LET vcodret = '374';
            RETURN vcodret;
        END IF;  
        
        SELECT monto_acum
          INTO vmonto_acum
          FROM sc_depinterpza
         WHERE fecha = vfecha_sistema
           AND num_cte = vnumcte
           AND cuenta = pcuenta;
           
        IF vmonto_acum is null THEN
            LET vmonto_acum = 0.00;
        END IF;
           
        LET vmonto_acum = vmonto_acum + pmto_tot;
           
        SELECT valor
          INTO vmonto_perm
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = 'MontoDepInterPlaza';
           
        IF vmonto_acum < vmonto_perm THEN
            LET vcodret = '374';
            RETURN vcodret;
        END IF;
        
        LET vacumula    = '1';
        LET vinterpza   = '1';
        LET vaumentaret = "1";
    END IF;

    -- // Extrae los datos de la cuenta de cheques...
    FOREACH abono_cursor FOR
        SELECT status_cta, motivo, sucursal, producto, sdo_actual, marca_ret, fec_ult_mov, fecultdep, fecultret, imp_chq_sbg + imp_sbg_ccc, num_cte, imp_chq_rem, fecha_proceso
          INTO vstatus, vmotivo, vsuccta, vproducto, vsdo_actual, vmarca_ret, vfecultmov, vfecultdep, vfecultret, vimpsbg, vnumcte, vmto_apertura, vfecha_proc
          FROM sc_maechq
         WHERE empresa = pempresa 
           AND cuenta = pcuenta

        -- // Valida el tipo de divisa del producto...
        SELECT divisa, acepta_depositos, mtominape, per_depositos[1,1], per_depositos[3,5]
          INTO vmoneda, vacepta_depositos, vmtominape, vper_depositos, vdiasdep
          FROM sc_producto
         WHERE empresa = pempresa 
           AND producto = vproducto;

        IF vmoneda != pdivisa THEN
            LET vcodret = "951";
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN vcodret;
        END IF;

        -- // Para deposito inicial
        IF vmarca_ret = "0" THEN  
            IF vacepta_depositos ="N" AND vper_depositos = "U" THEN
                IF vmto_apertura <>  pmto_tot THEN
                    LET vcodret = "959";
                    IF vtransaccion = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    RETURN vcodret;
                END IF
            END IF

            LET vdepinicial = vsdo_actual + pmto_tot;

            -- // Valida para un monto de apertura, que no sea menor al indicado en el producto
            IF vdepinicial >= vmtominape THEN
                LET vmarca_ret = "1";
                IF vacepta_depositos ="N" AND vper_depositos = "U" THEN
                    IF vmto_apertura <>  pmto_tot THEN
                        LET vcodret = "959";
                        IF vtransaccion = 1 THEN
                            ROLLBACK WORK;
                            BEGIN WORK;
                        ELSE
                            ROLLBACK WORK;
                        END IF;
                        RETURN vcodret;
                    END IF
                ELSE -- // Realiza Busqueda de Premio
                    UPDATE sc_premio
                       SET sucursal = psucursal,
                           numcte = vnumcte,
                           fecha_otorgo = vfecha_hoy,
                           folio_operacion = pfolio_suc
                     WHERE empresa = pempresa
                       AND cuenta = pcuenta
                       AND fecha_vigencia >= vfecha_hoy;
                END IF
            ELSE --//El deposito inicial es menor que el indicado en la definicion del producto
                LET vcodret = "959";
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                    END IF;
                RETURN vcodret;
            END IF;
        ELSE
            IF vacepta_depositos = "N" THEN
                -- // Si aún no tienen saldo y por alguna razón el marca_ret > 0
                IF NOT(vper_depositos = "U" AND vsdo_actual = 0) THEN
                   LET vcodret = "956";
                   IF vtransaccion = 1 THEN
                      ROLLBACK WORK;
                      BEGIN WORK;
                   ELSE
                      ROLLBACK WORK;
                   END IF;
                   RETURN vcodret;
                END IF
            ELSE
                LET vdiasultdep = vfecha_hoy - vfecultdep;
                IF vdiasultdep < vdiasdep THEN
                   LET vcodret = "956";
                   IF vtransaccion = 1 THEN
                      ROLLBACK WORK;
                      BEGIN WORK;
                   ELSE
                      ROLLBACK WORK;
                   END IF;
                   RETURN vcodret;
                END IF;
            END IF;
        END IF

        -- // Para una cuenta bloqueada, verifica el tipo de bloqueo....
        IF vstatus = 3 THEN
            SELECT "1" 
              INTO vexiste
              FROM sc_ctabloqueo 
             WHERE cuenta = pcuenta;

            IF vexiste = "1" THEN 
                SELECT opcion 
                  INTO vaceptab
                  FROM sc_ctabloqueo 
                 WHERE cuenta = pcuenta;

                IF vaceptab = 4 THEN
                    LET vcodret = "301";
                    IF vtransaccion = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;

                    RETURN vcodret;
                ELSE
                    IF vaceptab = 2 THEN
                        LET vcodret = "301";
                        IF vtransaccion = 1 THEN
                            ROLLBACK WORK;
                            BEGIN WORK;
                        ELSE
                            ROLLBACK WORK;
                        END IF;
                        RETURN vcodret;
                    END IF;
                END IF;
            ELSE
                SELECT abono 
                  INTO vaceptab
                  FROM sc_bloqueo 
                 WHERE codigo = vmotivo;

                IF vaceptab = "N" THEN
                    LET vcodret = "301";
                    IF vtransaccion = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    RETURN vcodret;
                END IF;
            END IF;
        END IF;

        LET vhora = CURRENT HOUR TO FRACTION;

        SELECT {+INDEX(sc_transcomis idx_transcomis1)} 1 
          INTO vgencom
          FROM sc_transcomis
         WHERE empresa = pempresa 
           AND transacc = ptransacc;

        IF vgencom IS NULL THEN
            LET vgencom = 0;
            LET vcobracom = "0";
        END IF

        --- // JOM INICIO 
        IF (ptransuc = '0201' and pmto_sbc <= 0) THEN
            LET vcodret = "401";
            IF vtransaccion = 1 THEN
               ROLLBACK WORK;
               BEGIN WORK;
            ELSE
               ROLLBACK WORK;
            END IF;
            RETURN vcodret;
        END IF;
        --- // JOM FIN

        IF pmto_sbc > 0 THEN
            SELECT SUM(NVL(monto,0)) 
              INTO vtotal_sbc			--MOHA
              FROM sc_docret_sbc
             WHERE empresa = pempresa 
               AND cuenta = pcuenta 
               AND folio_suc = pfolio_suc 
               AND fecha_alta = vfecha_hoy 
               AND siglas = "SC";

            IF NVL(vtotal_sbc, 0) <> pmto_sbc THEN
                LET vcodret="401";
                IF vtransaccion = 1 THEN
                   ROLLBACK WORK;
                   BEGIN WORK;
                ELSE
                   ROLLBACK WORK;
                END IF;
                RETURN vcodret;
            END IF;
        END IF;
        
        IF ptransacc = '0273' THEN
            SELECT vchrvalor
              INTO vfech_spei
              FROM bdispei:tblparametros
             WHERE vchrcveparametro = 'FECHA_OPERACION'; 
             
            LET vfech_val = SUBSTR(vfech_spei, 4, 2) || '/' || SUBSTR(vfech_spei, 1, 2) || '/' || SUBSTR(vfech_spei, 7, 4);
             
            -- // Inserta el movimiento en la tabla de movimientos diarios...
            INSERT INTO sc_movdia VALUES
            (0, pfolio_suc, psucursal, pusuario, vfecha_hoy, vfech_val, vhora, ptransacc, vsuccta, vproducto, pempresa, pcuenta, "", 0, pmto_tot,
             pmto_firme, pmto_sbc, pmto_rem, pdias_ret, "", vstatus, vsdo_actual, ptransuc, preferencia, vtasa_aplicada, pnum_tarjeta, pusuautoriza, preferencia23, vfecha_operacion);
        ELSE
            -- // Inserta el movimiento en la tabla de movimientos diarios...
            INSERT INTO sc_movdia VALUES
            (0, pfolio_suc, psucursal, pusuario, vfecha_hoy, vfecha_hoy, vhora, ptransacc, vsuccta, vproducto, pempresa, pcuenta, "", 0, pmto_tot,
             pmto_firme, pmto_sbc, pmto_rem, pdias_ret, "", vstatus, vsdo_actual, ptransuc, preferencia, vtasa_aplicada, pnum_tarjeta, pusuautoriza, preferencia23, vfecha_operacion);
        END IF;
        
        -- // Actualiza el Maestro de Cheques...
        UPDATE sc_maechq
           SET fec_ult_mov = vfecha_hoy,
               num_abonos_mes = num_abonos_mes + 1,
               imp_abonos_mes = imp_abonos_mes + pmto_tot, -- Aqui se podria restar el SBC
               sdo_actual = sdo_actual + pmto_tot - pmto_sbc,
               imp_chq_sbc = imp_chq_sbc + pmto_sbc, -- Cambia a SBC No Utiliza Retenido
               marca_ret = vmarca_ret,
               fecultdep = vfecha_hoy
         WHERE empresa = pempresa 
           AND cuenta = pcuenta;
           
        /* ###########################################################
        -- // Actualiza Cuentas Inactivas (Status 4)
        IF ( vstatus = '4' AND vfecha_proc = vfecha_sistema ) THEN
            UPDATE sc_maechq
               SET status_cta = '1',
                   fecha_proceso = vfecha_hoy
             WHERE empresa = pempresa 
               AND cuenta = pcuenta;
        END IF;   
        ########################################################### */
        
        -- // Actualiza Cuentas Informadas (Status 5)
        IF vstatus IN('4','5') THEN
            UPDATE sc_maechq
               SET status_cta = '1',
                   fecha_proceso = vfecha_hoy
             WHERE empresa = pempresa 
               AND cuenta = pcuenta;
        END IF; 

        -- // Genera comision por transaccion
        IF vgencom = "1" THEN
            CALL gencomtran(pempresa, pcuenta, ptransacc, pmto_tot, pfolio_suc, psucursal, pusuario)
            RETURNING vcodret;
            LET vcobracom = "1";
        END IF
        
        IF (ptransacc = '0202' OR ptransacc = '0325') AND vproducto <> '1100' THEN 
            IF vtpo_per_valida IN('1','3') THEN
                INSERT INTO sc_depositosefectivo(fecha, hora, folio_suc, transacc, num_cte, cuenta, sucursal, suc_cuenta, monto)
                VALUES(vfecha_hoy, vhora, pfolio_suc, ptransacc, vnumcte, pcuenta, psucursal, vsuccta, pmto_tot);
            END IF;
            
            IF vinterpza = '1' THEN
                SELECT COUNT(*)
                  INTO vexiste_acum
                  FROM sc_depinterpza
                 WHERE fecha = vfecha_sistema
                   AND num_cte = vnumcte
                   AND cuenta = pcuenta;
                   
                IF ( vexiste_acum = 0 AND ( vacumula = '1' AND vaumentaret = '0' ) ) THEN
                
                    INSERT INTO sc_depinterpza( fecha, num_cte, cuenta, monto_acum, monto_ret, liberado ) 
                    VALUES( vfecha_sistema, vnumcte, pcuenta, pmto_tot, 0, '0' );
                    
                ELIF ( vexiste_acum = 0 AND ( vacumula = '1' AND vaumentaret = '1' ) ) THEN
                
                    INSERT INTO sc_depinterpza( fecha, num_cte, cuenta, monto_acum, monto_ret, liberado ) 
                    VALUES( vfecha_sistema, vnumcte, pcuenta, pmto_tot, pmto_tot, '0' );
                    
                    UPDATE sc_maechq
                       SET sdo_retenido = sdo_retenido + pmto_tot
                     WHERE empresa = pempresa 
                       AND cuenta = pcuenta;
                    
                ELIF ( vexiste_acum > 0 AND ( vacumula = '1' AND vaumentaret = '0' ) ) THEN
                
                    UPDATE sc_depinterpza
                       SET monto_acum = monto_acum + pmto_tot
                     WHERE num_cte = vnumcte
                       AND cuenta = pcuenta
                       AND fecha = vfecha_sistema;
                       
                ELIF ( vexiste_acum > 0 AND ( vacumula = '1' AND vaumentaret = '1' ) ) THEN
                
                    UPDATE sc_depinterpza
                       SET monto_acum = monto_acum + pmto_tot,
                           monto_ret = monto_ret + pmto_tot
                     WHERE num_cte = vnumcte
                       AND cuenta = pcuenta
                       AND fecha = vfecha_sistema;
                
                    UPDATE sc_maechq
                       SET sdo_retenido = sdo_retenido + pmto_tot
                     WHERE empresa = pempresa 
                       AND cuenta = pcuenta;
                       
                END IF;
            END IF;
        END IF;        
        
        -- // Obtiene los parametros generales
        SELECT valor 
          INTO vtranpagint
          FROM sc_param
         WHERE empresa = pempresa 
           AND codparam = "tranpagint";

        SELECT valor 
          INTO vtranusoccc
          FROM sc_param
         WHERE empresa = pempresa 
           AND codparam = "tranusoccc";

        SELECT valor 
          INTO vtranabocol
          FROM sc_param
         WHERE empresa = pempresa 
           AND codparam = "tranabocol";

        SELECT valor 
          INTO vtranusosbg
          FROM sc_param
         WHERE empresa = pempresa 
           AND codparam = "tranusosbg";

        -- // Cobra comisiones pendientes
        IF ptransacc = vtranpagint or ptransacc = vtranabocol OR
           ptransacc = vtranusoccc or ptransacc = vtranusosbg THEN
            LET vcobracom = "0";
        ELSE
            IF vimpsbg > 0 THEN
                LET vcobracom = "1";
            END IF
            
            IF vcobracom = "0" THEN
                SELECT UNIQUE 1 
                  INTO vcobracom
                  FROM sc_detcomis
                 WHERE empresa = pempresa 
                   AND cuenta = pcuenta 
                   AND estado_com = "P";

                IF vcobracom IS NULL THEN
                   LET vcobracom = "0";
                ELSE
                   LET vcobracom = "1";
                END IF
            END IF
        END IF
        
        IF vcobracom = "1" THEN
            CALL cobintcomsbg(pempresa, pcuenta, pfolio_suc, pusuario, psucursal)
            RETURNING vcodret;
        END IF
        
    END FOREACH;

    IF vcodret = "000" THEN
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;
    ELSE
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
    END IF

    RETURN vcodret;

    END;

END PROCEDURE;