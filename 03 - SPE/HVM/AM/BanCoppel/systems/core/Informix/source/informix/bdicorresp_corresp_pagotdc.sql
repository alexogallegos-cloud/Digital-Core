CREATE PROCEDURE "informix".corresp_pagotdc( pc_costos CHAR(4),      --- SUCURSAL
                                             pusuario CHAR(8),       --- USUARIO
                                             pfolio CHAR(16),        --- FOLIO SUC
                                             pnum_tarjeta CHAR(16),  --- TARJETA DE CREDITO
                                             pfecha DATE,            --- FECHA
                                             pmto_tot DECIMAL(14,2), --- MONTO
                                             pmoneda CHAR(3),        --- MONEDA
                                             preferencia CHAR(40) )  --- REFERENCIA
RETURNING CHAR(3),  --- CODIGO DE RETORNO
          CHAR(53), --- NOMBRE CORTO DEL CLIENTE
          CHAR(9),  --- NO. BOLETO INICIAL SORTEO MILLONARIO
          CHAR(9);  --- NO. BOLETO FINAL SORTEO MILLONARIO

    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE vcodret1     CHAR(3);
    DEFINE vcodret2     CHAR(5);
    
    DEFINE vtarjeta         CHAR(16);
    DEFINE vnum_credito     CHAR(20);
    DEFINE vstatus_tar      CHAR(1);
    DEFINE vprecio_udi      DECIMAL(14,6);   
    DEFINE vmonto_udi       DECIMAL(18,6);
    DEFINE vmtoacumcta      DECIMAL(18,6); 
    DEFINE vmtopagosudi     DECIMAL(18,6);   
    DEFINE vlim_cuenta      DECIMAL(18,6); 
    DEFINE vporcapcorres    DECIMAL(9,6);
    DEFINE vtransaccion     SMALLINT;
    DEFINE vremanente       DECIMAL(14,2);
    DEFINE vintmorcob       DECIMAL(14,2);
    DEFINE vintvencob       DECIMAL(14,2);
    DEFINE vcapvencob       DECIMAL(14,2);
    DEFINE vintvigcob       DECIMAL(14,2);
    DEFINE vcapvigcob       DECIMAL(14,2);
    DEFINE vimpcob          DECIMAL(14,2);
    DEFINE vcomcob          DECIMAL(14,2);
    DEFINE vsegcob          DECIMAL(14,2);
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha_tpcambio  DATE;
    DEFINE vtrancorrespcred CHAR(4);
    DEFINE vnomaxudis       INTEGER;
    DEFINE vfechamax        DATE;
    DEFINE vhoramax         datetime hour to minute;
    DEFINE vproducto        CHAR(4);
    DEFINE vexiste_prod     SMALLINT;
    DEFINE vcanal           INTEGER;
    DEFINE vtpo_oper        INTEGER;
    DEFINE vnum_cte         CHAR(9);
    DEFINE vcodret3         CHAR(6);
    DEFINE vmensaje         CHAR(80);
    DEFINE vnuminiboleto    INTEGER;
    DEFINE vnumfinboleto    INTEGER;   
    DEFINE vnombre          CHAR(53);
    DEFINE vnombre_cte      CHAR(53);
    DEFINE vno_ini_boleto   CHAR(9);
    DEFINE vno_fin_boleto   CHAR(9);
    DEFINE vprod            INTEGER;
    DEFINE vproceso         CHAR(1);
    DEFINE vnuminiboleto2   CHAR(9);
    DEFINE vnumfinboleto2   CHAR(9);
    DEFINE vind_cierre      CHAR(1);
    DEFINE vind_dispon      CHAR(1);
    
    LET sql_err  = 0;
    LET isam_err = 0;
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    
    LET vtarjeta         = '';
    LET vnum_credito     = '';
    LET vstatus_tar      = '';
    LET vprecio_udi      = 0.00;  
    LET vmonto_udi       = 0.00;
    LET vmtoacumcta      = 0.00;
    LET vmtopagosudi     = 0.00;
    LET vlim_cuenta      = 0.00;
    LET vtransaccion     = 0;
    LET vremanente       = 0.00;
    LET vintmorcob       = 0.00;
    LET vintvencob       = 0.00;
    LET vcapvencob       = 0.00;
    LET vintvigcob       = 0.00;
    LET vcapvigcob       = 0.00;
    LET vimpcob          = 0.00;
    LET vcomcob          = 0.00;
    LET vsegcob          = 0.00;
    LET vfecha_hoy       = '';
    LET vfecha_tpcambio  = '';
    LET vtrancorrespcred = '';
    LET vnomaxudis       = 0;
    LET vfechamax        = '';
    LET vhoramax         = '';
    LET vproducto       = '';
    LET vexiste_prod    = 0;
    LET vcanal          = 0;
    LET vtpo_oper       = 0;
    LET vnum_cte        = '';
    LET vcodret3        = '000000';
    LET vmensaje        = '';
    LET vnuminiboleto   = 0;
    LET vnumfinboleto   = 0;
    LET vnombre         = '';
    LET vnombre_cte     = '                                                     ';
    LET vno_ini_boleto  = '000000000';
    LET vno_fin_boleto  = '000000000';
    LET vprod           = 0;
    LET vproceso        = '0';
    LET vnuminiboleto2  = '000000000';
    LET vnumfinboleto2  = '000000000';
    LET vind_cierre     = '0';
    LET vind_dispon     = '0';
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_pagotdc.out";
     --SET DEBUG FILE TO "/informix/moha/corresp_pagotdc.out";
     --TRACE ON;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_pagotdc.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            --- LET vcodret1 = sql_err;
            --- LET vcodret2 = isam_err;
            IF vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            IF vproceso = '1' THEN
                LET vcodret1 = '000';
            ELSE
                LET vcodret1 = '999';
            END IF;
            RETURN vcodret1, vnombre_cte, vno_ini_boleto, vno_fin_boleto;
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
    SET LOCK MODE TO WAIT 3;
    
    -- // Obtiene fechas del sistema de cheques
    SELECT ind_cierre, ind_disponible
      INTO vind_cierre, vind_dispon
      FROM bdicred:sd_fechas 
     WHERE empresa = '001';
     
    IF ( vind_cierre = '0' OR vind_dispon = '0' ) THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '040';
        RETURN vcodret1, vnombre_cte, vno_ini_boleto, vno_fin_boleto;
    END IF;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    LET pmto_tot = pmto_tot / 100;
    
    IF (pc_costos is null OR pc_costos = '') OR
       (pusuario is null OR pusuario = '' OR LENGTH(pusuario) <> 8) OR
       (pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16) OR
       (pnum_tarjeta is null OR pnum_tarjeta = '' OR LENGTH(pnum_tarjeta) <> 16) OR
       (pfecha is null OR pfecha = '') OR
       (pmto_tot is null OR pmto_tot <= 0.00) OR
       (pmoneda is null OR pmoneda = '' OR LENGTH(pmoneda) <> 03) THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '301';
        RETURN vcodret1, vnombre_cte, vno_ini_boleto, vno_fin_boleto;
    END IF;
    
    IF LENGTH(pmoneda) = 03 THEN
        LET pmoneda = pmoneda[2,3]; 
    END IF;
    
    -- // VALIDA DATOS DEL CREDITO
    SELECT num_tarjeta, num_credito, status_tar
      INTO vtarjeta, vnum_credito, vstatus_tar
      FROM bdicred:sd_tarjeta
     WHERE num_tarjeta = pnum_tarjeta
       AND empresa = '001';
    
    IF vtarjeta is null THEN
        LET vtarjeta = ' ';
    END IF;
    
    IF vnum_credito is null THEN
        LET vnum_credito = ' ';
    END IF;
    
    IF vstatus_tar is null THEN
        LET vstatus_tar = ' ';
    END IF;
       
    IF (vtarjeta <> pnum_tarjeta) OR (vstatus_tar <> 'A')  THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '301';
        RETURN vcodret1, vnombre_cte, vno_ini_boleto, vno_fin_boleto;
    END IF;
    
    IF (vnum_credito is null OR vnum_credito = '') THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '008';
        RETURN vcodret1, vnombre_cte, vno_ini_boleto, vno_fin_boleto;
    END IF;
    
    -- // OBTIENE EL VALOR DE LA UDI
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM bdinteg:si_fechas
     WHERE empresa = '001';
       
    SELECT FIRST 1 MAX(hora_tpcambio) 
      INTO vhoramax
      FROM bdinteg:si_tpcambio 
     WHERE empresa = '001' 
       AND divisa = '09'
       AND fecha_tpcambio = vfecha_hoy;
       
    IF vhoramax is null OR vhoramax = '' THEN
        SELECT FIRST 1 precio_venta
          INTO vprecio_udi
          FROM bdinteg:si_tpcambio
         WHERE empresa = '001'
           AND divisa = '09'
           AND fecha_tpcambio = vfecha_hoy;
    ELSE
        SELECT FIRST 1 precio_venta
          INTO vprecio_udi
          FROM bdinteg:si_tpcambio
         WHERE empresa = '001'
           AND divisa = '09'
           AND fecha_tpcambio = vfecha_hoy
           AND hora_tpcambio = vhoramax;
    END IF;
       
    IF vprecio_udi is null OR vprecio_udi = '' THEN
        SELECT FIRST 1 MAX(fecha_tpcambio) 
          INTO vfecha_tpcambio
          FROM bdinteg:si_tpcambio
         WHERE empresa = '001' 
           AND divisa = '09'
           AND fecha_tpcambio <= vfecha_hoy;
           
        SELECT FIRST 1 MAX(hora_tpcambio) 
          INTO vhoramax
          FROM bdinteg:si_tpcambio 
         WHERE empresa = '001' 
           AND divisa = '09'
           AND fecha_tpcambio = vfecha_tpcambio;
           
        IF vhoramax is null OR vhoramax = '' THEN
            SELECT FIRST 1 precio_venta
              INTO vprecio_udi
              FROM bdinteg:si_tpcambio
             WHERE empresa = '001'
               AND divisa = '09'
               AND fecha_tpcambio = vfecha_tpcambio;
        ELSE
            SELECT FIRST 1 precio_venta
              INTO vprecio_udi
              FROM bdinteg:si_tpcambio
             WHERE empresa = '001'
               AND divisa = '09'
               AND fecha_tpcambio = vfecha_tpcambio
               AND hora_tpcambio = vhoramax;
        END IF;
    END IF;
    
    -- // CONVIERTE MONTO DE LA TRANSACCION EN UDIS
    LET vmonto_udi = pmto_tot / vprecio_udi;
    
    -- // OBTIENE EL VALOR MAXIMO DE UDIS PARA CREDITO
    SELECT valor
      INTO vnomaxudis
      FROM bdicheq:sc_param_corresp
     WHERE codparam = 'NUMAXUDISCRED'
       AND empresa = '001';
    
    -- // VALIDA QUE EL MONTO DE LA TRANSACCION NO REBASE EL LIMITE PERMITIDO
    IF (vmonto_udi >= vnomaxudis) THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '006';
        RETURN vcodret1, vnombre_cte, vno_ini_boleto, vno_fin_boleto;
    END IF;
    
    -- // OBTIENE EL ACUMULADO DEL DIA DEL CREDITO
    SELECT SUM(monto)
      INTO vmtoacumcta
      FROM bdicred:sd_movdia
     WHERE empresa = '001'
       AND num_credito = vnum_credito
       AND fecha_mov = pfecha
       AND reversado <> 'S'
       AND sucursal = pc_costos
       AND codigo_fun = '700'
       AND codigo_ref = 1;
     
    IF vmtoacumcta is null THEN
        LET vmtoacumcta = 0.00;
    END IF;
       
    -- // CONVIERTE ACUMULADO DEL CREDITO EN UDIS
    LET vmtopagosudi = vmtoacumcta / vprecio_udi;
    
    -- // SUMA EL MONTO DE LA TRANSACCION AL ACUMULADO DEL CREDITO
    LET vlim_cuenta = vmonto_udi + vmtopagosudi;
    
    -- // VALIDA QUE EL ACUMULADO DEL CREDITO NO REBASE EL LIMITE PERMITIDO
    IF (vlim_cuenta < vnomaxudis) THEN
        -- // OBTIENE NUMERO DE TRANSACCION
        SELECT TRIM(valor) 
          INTO vtrancorrespcred
          FROM bdicheq:sc_param
         WHERE empresa = '001' 
           AND codparam = "trancorrespcred";
           
        -- // APLICA TRANSACCION DE PAGO EN EL CREDITO
        EXECUTE PROCEDURE bdicred:principal("001", vnum_credito, 1, pmto_tot, pusuario, pc_costos, pfolio, vtrancorrespcred)
        INTO vcodret2, vremanente, vintmorcob, vintvencob, vcapvencob, vintvigcob, vcapvigcob, vimpcob, vcomcob, vsegcob;
          
        IF vcodret2 = '000' THEN 
		    LET vcodret1 = '000';
            LET vproceso = '1';
            
            -- // ACTUALIZA REFERENCIA EN LAS TRANSACCIONES
            UPDATE bdicred:sd_movdia
               SET referencia = preferencia
             WHERE empresa = '001'
               AND num_credito = vnum_credito
               AND fecha_mov = pfecha
               AND reversado <> 'S'
               AND sucursal = pc_costos
               AND codigo_fun = '700'
               AND codigo_ref = 1
               AND folio_suc = pfolio;
               
            -- // OBTIENE NOMBRE CORTO DEL CLIENTE Y PRODUCTO
            SELECT numcte, num_producto
              INTO vnum_cte, vproducto
              FROM bdicred:"informix".sd_maecred
             WHERE num_credito = vnum_credito
               AND empresa = '001';
               
            SELECT TRIM(nombre1)||' '||TRIM(apell_paterno)
              INTO vnombre
              FROM bdinteg:"informix".si_cliente
             WHERE numcte = vnum_cte;
             
            LET vnombre_cte = RPAD(vnombre, 53, ' ');
            
            -- // VALIDA SI EL PRODUCTO PARTICIPA EN EL SORTEO MILLONARIO
            SELECT COUNT(*)
              INTO vexiste_prod
              FROM bdicheq:"informix".sc_prodcorr_sortmill
             WHERE producto = vproducto;
               
            IF vexiste_prod > 0 THEN
                SELECT valor::INT
                  INTO vcanal
                  FROM bdicheq:"informix".sc_param_corresp
                 WHERE codparam = 'CanalCorrespSortMill'
                   AND empresa = '001';
                   
                SELECT valor::INT
                  INTO vtpo_oper
                  FROM bdicheq:"informix".sc_param_corresp
                 WHERE codparam = 'TpoOpeCorrCreSorMill'
                   AND empresa = '001';
                   
                LET vprod = vproducto;
                   
                EXECUTE PROCEDURE bdinteg:"informix".sp_sorteobancoppel(vcanal, vtpo_oper, vprod, vnum_cte, pc_costos, pfolio, pmto_tot, vfecha_hoy)
                INTO vcodret3, vmensaje, vnuminiboleto, vnumfinboleto;
                
                IF vcodret3 = '00000' THEN
                    LET vnuminiboleto2 = vnuminiboleto;
                    LET vnumfinboleto2 = vnumfinboleto;
                    
                    IF length(vnuminiboleto2) = 8  THEN
                        LET vno_ini_boleto = '0' || vnuminiboleto2;
                    ELSE
                        LET vno_ini_boleto =  vnuminiboleto;
                    END IF;
                    
                    IF  length(vnumfinboleto2) = 8 THEN
                        LET vno_fin_boleto ='0' || vnumfinboleto2;
                    ELSE
                        LET vno_fin_boleto = vnumfinboleto;
                    END IF;
                ELSE
                    LET vno_ini_boleto = '000000000';
                    LET vno_fin_boleto = '000000000';
                END IF;
            END IF;
        ELSE 
            IF vcodret2 = '008' THEN
                LET vcodret1 = '008';
            ELIF vcodret2 = '301' THEN
                LET vcodret1 = '009';
            ELIF vcodret2 = '110' OR vcodret2 = '00100' OR  vcodret2 = '100' OR   vcodret2 = '099' THEN
                LET vcodret1 = '301';
			ELIF vcodret2 = '1144' THEN --// VALIDACION LIMITE DE SALDO A FAVOR
                LET vcodret1 = '006';
            ELSE
                LET vcodret1 = '999';
            END IF;
            
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            
            RETURN vcodret1, vnombre_cte, vno_ini_boleto, vno_fin_boleto;
        END IF;
    ELSE
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '002';
        RETURN vcodret1, vnombre_cte, vno_ini_boleto, vno_fin_boleto;
    END IF;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
    
    RETURN vcodret1, vnombre_cte, vno_ini_boleto, vno_fin_boleto;
    
    END;

END PROCEDURE;