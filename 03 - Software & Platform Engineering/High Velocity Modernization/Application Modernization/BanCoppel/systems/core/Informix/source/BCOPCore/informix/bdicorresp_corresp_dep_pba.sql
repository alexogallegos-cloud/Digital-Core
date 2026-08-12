CREATE PROCEDURE "informix".corresp_dep_pba( pc_costos CHAR(4),      --- SUCURSAL
                                         pusuario CHAR(8),       --- USUARIO
                                         pfolio CHAR(16),        --- FOLIO SUC
                                         pcuenta CHAR(20),       --- CUENTA
                                         pnum_tarjeta CHAR(16),  --- TARJETA
                                         pfecha DATE,            --- FECHA
                                         pmto_tot DECIMAL(14,2), --- MONTO
                                         pmoneda CHAR(3),        --- MONEDA
                                         preferencia CHAR(40) )  --- REFERENCIA
RETURNING CHAR(3),  --- CODIGO DE RETORNO
          CHAR(11), --- CUENTA
          CHAR(53), --- NOMBRE CORTO DEL CLIENTE
          CHAR(9),  --- NO. BOLETO INICIAL SORTEO MILLONARIO
          CHAR(9);  --- NO. BOLETO FINAL SORTEO MILLONARIO
    
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcodret1         CHAR(3);
    DEFINE vcodret2         CHAR(5);
    DEFINE vproceso         CHAR(1);
    
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha_tpcambio  DATE;
    DEFINE vprecio_udi      DECIMAL(14,6);   
    DEFINE vmonto_udi       DECIMAL(18,6);
    DEFINE vmtoacumcta      DECIMAL(18,6); 
    DEFINE vmtopagosudi     DECIMAL(18,6);   
    DEFINE vlim_cuenta      DECIMAL(18,6); 
    DEFINE vporcapcorres    DECIMAL(9,6);
    DEFINE vmtoglobcap      DECIMAL(20,6);
    DEFINE vmtomensacum     DECIMAL(20,6);
    DEFINE vexiste          CHAR(20);
    DEFINE vtransaccion     SMALLINT;
    DEFINE vtrancorrespchq  CHAR(4);
    DEFINE vnomaxudis       INTEGER;
    DEFINE vhoramax         datetime hour to minute;
    DEFINE wcuenta          CHAR(20);
    DEFINE vstatus_tar      CHAR(1);
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
	
    DEFINE vnuminiboleto2   CHAR(9);
    DEFINE vnumfinboleto2   CHAR(9);  

    
    LET sql_err  = 0;
    LET isam_err = 0;
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vproceso = '0';
    
    LET vfecha_hoy      = '';
    LET vfecha_tpcambio = '';
    LET vprecio_udi     = 0.00;  
    LET vmonto_udi      = 0.00;
    LET vmtoacumcta     = 0.00;
    LET vmtopagosudi    = 0.00;
    LET vlim_cuenta     = 0.00;
    LET vporcapcorres   = 0.00;
    LET vmtoglobcap     = 0.00;
    LET vmtomensacum    = 0.00;
    LET vexiste         = '';
    LET vtransaccion    = 0;
    LET vnomaxudis      = 0;
    LET vhoramax        = '';
    LET vtrancorrespchq = '';
    LET wcuenta         = '';
    LET vstatus_tar     = '';
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


    LET vnuminiboleto2  = '000000000';
    LET vnumfinboleto2  = '000000000';
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_dep.out";
    -- SET DEBUG FILE TO "/tmp/corresp_dep.out";
    -- TRACE ON;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_dep.err";
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
            RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;
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
    
    -- // VALIDACION DE PARAMETROS
    LET pmto_tot = pmto_tot / 100;
    
    IF (pc_costos is null OR pc_costos = '' OR LENGTH(pc_costos) <> 4) OR
       (pusuario is null OR pusuario = '' OR LENGTH(pusuario) <> 8) OR
       (pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16) OR
       ((pcuenta is null OR pcuenta = '' OR LENGTH(pcuenta) <> 11) AND (pnum_tarjeta is null OR pnum_tarjeta = '' OR LENGTH(pnum_tarjeta) <> 16)) OR
       (pfecha is null OR pfecha = '') OR
       (pmto_tot is null OR pmto_tot <= 0.00) OR
       (pmoneda is null OR pmoneda = '' OR LENGTH(pmoneda) <> 03) THEN
        
        LET vcodret1 = '110';
        
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        
        RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;
    END IF;
    
    IF LENGTH(pmoneda) = 03 THEN
        LET pmoneda = pmoneda[2,3]; 
    END IF;
    
    -- // OBTIENE DATOS DE LA CUENTA DE CHEQUES
    IF pcuenta is null OR pcuenta = '' THEN
        SELECT cuenta, status_tar
          INTO pcuenta, vstatus_tar
          FROM bdicheq:"informix".sc_tarjeta
         WHERE empresa = '001'
           AND num_tarjeta = pnum_tarjeta;
           
        IF vstatus_tar <> 'A' THEN
            LET vcodret1 = '200';
            
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            
            RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;
        END IF;
    END IF;
    
    IF pnum_tarjeta is null OR pnum_tarjeta = '' THEN
        SELECT num_tarjeta
          INTO pnum_tarjeta
          FROM bdicheq:"informix".sc_tarjeta
         WHERE empresa = '001'
           AND cuenta = pcuenta
           AND secuencia = (SELECT max(secuencia)
                              FROM bdicheq:"informix".sc_tarjeta
                             WHERE empresa = '001'
                               AND cuenta = pcuenta)
           AND status_tar = 'A';
           
        IF pnum_tarjeta IS NULL THEN
            LET pnum_tarjeta = '';
        END IF;
    END IF;
    
    -- // OBTIENE EL VALOR DE LA UDI
    SELECT {+INDEX(bdinteg:si_fechas idx_si_fechas)} fecha_hoy
      INTO vfecha_hoy
      FROM bdinteg:"informix".si_fechas
     WHERE empresa = '001';
       
    SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} FIRST 1 MAX(hora_tpcambio) 
      INTO vhoramax
      FROM bdinteg:"informix".si_tpcambio 
     WHERE empresa = '001' 
       AND divisa = '09'
       AND fecha_tpcambio = vfecha_hoy;
       
    IF vhoramax is null OR vhoramax = '' THEN
        SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} FIRST 1 precio_venta
          INTO vprecio_udi
          FROM bdinteg:"informix".si_tpcambio
         WHERE empresa = '001'
           AND divisa = '09'
           AND fecha_tpcambio = vfecha_hoy;
    ELSE
        SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} FIRST 1 precio_venta
          INTO vprecio_udi
          FROM bdinteg:"informix".si_tpcambio
         WHERE empresa = '001'
           AND divisa = '09'
           AND fecha_tpcambio = vfecha_hoy
           AND hora_tpcambio = vhoramax;
    END IF;
       
    IF vprecio_udi is null OR vprecio_udi = '' THEN
        SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} FIRST 1 MAX(fecha_tpcambio) 
          INTO vfecha_tpcambio
          FROM bdinteg:"informix".si_tpcambio
         WHERE empresa = '001' 
           AND divisa = '09'
           AND fecha_tpcambio <= vfecha_hoy;
           
        SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} FIRST 1 MAX(hora_tpcambio) 
          INTO vhoramax
          FROM bdinteg:"informix".si_tpcambio 
         WHERE empresa = '001' 
           AND divisa = '09'
           AND fecha_tpcambio = vfecha_tpcambio;
           
        IF vhoramax is null OR vhoramax = '' THEN
            SELECT {+INDEX(bdinteg:"informix".si_tpcambio idx_si_tpcambio2)} FIRST 1 precio_venta
              INTO vprecio_udi
              FROM bdinteg:"informix".si_tpcambio
             WHERE empresa = '001'
               AND divisa = '09'
               AND fecha_tpcambio = vfecha_tpcambio;
        ELSE
            SELECT {+INDEX(bdinteg:"informix".si_tpcambio idx_si_tpcambio2)} FIRST 1 precio_venta
              INTO vprecio_udi
              FROM bdinteg:"informix".si_tpcambio
             WHERE empresa = '001'
               AND divisa = '09'
               AND fecha_tpcambio = vfecha_tpcambio
               AND hora_tpcambio = vhoramax;
        END IF;
    END IF;
           
    -- // CONVIERTE MONTO DE LA TRANSACCION EN UDIS
    LET vmonto_udi = pmto_tot / vprecio_udi;
    
    -- // OBTIENE EL ACUMULADO DE LA CUENTA
    SELECT {+INDEX(bdicheq:"informix".sc_acumdiacorresp idx_acumdiario)} monto_acum
      INTO vmtoacumcta
      FROM bdicheq:"informix".sc_acumdiacorresp
     WHERE cuenta = pcuenta;
     
    IF vmtoacumcta is null THEN
        LET vmtoacumcta = 0.00;
    END IF;
    
    -- // CONVIERTE ACUMULADO DE LA CUENTA EN UDIS
    LET vmtopagosudi = vmtoacumcta / vprecio_udi;
     
    -- // OBTIENE EL VALOR MAXIMO DE UDIS PARA CAPTACION
    SELECT {+INDEX(bdicheq:"informix".sc_param_corresp idx_paramcorresp)} valor
      INTO vnomaxudis
      FROM bdicheq:"informix".sc_param_corresp
     WHERE codparam = 'NUMAXUDISCHQ'
       AND empresa = '001';
       
    -- // SUMA EL MONTO DE LA TRANSACCION AL ACUMULADO DE LA CUENTA
    LET vlim_cuenta = vmonto_udi + vmtopagosudi;
    
    -- // VALIDA QUE EL ACUMULADO DE LA CUENTA NO REBASE EL LIMITE PERMITIDO
    IF vlim_cuenta > vnomaxudis THEN
        LET vcodret1 = '002';
        
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        
        RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;
    END IF;
    
    -- // OBTIENE EL PORCENTAJE PARA CORRESPONSALES
    SELECT {+INDEX(bdicheq:"informix".sc_param_corresp idx_paramcorresp)} valor
      INTO vporcapcorres
      FROM bdicheq:"informix".sc_param_corresp
     WHERE codparam = '002'
       AND empresa = '001';
       
    -- // OBTIENE MONTO GLOBAL DE LA CAPTACION MENSUAL
    SELECT {+INDEX(bdicheq:"informix".sc_param_corresp idx_paramcorresp)} valor
      INTO vmtoglobcap
      FROM bdicheq:"informix".sc_param_corresp
     WHERE codparam = '001'
       AND empresa = '001';
       
    -- // OBTIENE EL MONTO MENSUAL ACUMULADO DEL CORRESPONSAL
    SELECT {+INDEX(bdicheq:"informix".sc_param_corresp idx_paramcorresp)} valor
      INTO vmtomensacum
      FROM bdicheq:"informix".sc_param_corresp
     WHERE codparam = '003'
       AND empresa = '001';
     
    -- // VALIDA QUE EL MONTO MENSUAL ACUMULADO DEL CORRESPONSAL NO REBASE EL LIMITE PERMITIDO
    IF (pmto_tot + vmtomensacum) < (vmtoglobcap * (vporcapcorres / 100)) THEN
        SELECT {+INDEX(bdicheq:"informix".sc_ctas_sin_corresp idx_ctassincorr)} cuenta
          INTO wcuenta
          FROM bdicheq:"informix".sc_ctas_sin_corresp
         WHERE cuenta = pcuenta;
         
        IF wcuenta = pcuenta THEN
            LET vcodret1 = '302';
            
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            
            RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;
        END IF;
        
        -- // OBTIENE NUMERO DE TRANSACCION
        SELECT {+INDEX(bdicheq:"informix".sc_param_corresp idx_paramcorresp)} TRIM(valor) 
          INTO vtrancorrespchq
          FROM bdicheq:"informix".sc_param
         WHERE empresa = '001'
           AND codparam = "trancorrespchq";
           
        IF vtrancorrespchq is null OR vtrancorrespchq = '' THEN
            LET vcodret1 = '110';
            
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            
            RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;
        END IF;
    
        -- // APLICA TRANSACCION DE ABONO EN LA CUENTA DE CHEQUES
        EXECUTE PROCEDURE bdicheq:"informix".abono_ref( "001",           --- EMPRESA
                                                        pc_costos,       --- SUCURSAL
                                                        pusuario,        --- USUARIO
                                                        vtrancorrespchq, --- TRANSACCION
                                                        "0204",          --- TRANSACC SUC
                                                        pfolio,          --- FOLIO SUC
                                                        pcuenta,         --- CUENTA
                                                        0,               --- CHEQUE
                                                        pmto_tot,        --- MONTO TOT
                                                        pmto_tot,        --- MONTO FIRME
                                                        0,               --- MONTO SBC
                                                        0,               --- MONTO REM
                                                        0,               --- DIAS RET
                                                        pmoneda,         --- MONEDA
                                                        preferencia,     --- REFERENCIA
                                                        pnum_tarjeta,    --- TARJETA
                                                        " " )            --- USUARIO AUTORIZA
        INTO vcodret1;
        
        IF vcodret1 = '000' THEN  
            -- // INICIALIZA BANDERA DE DEPOSITO EXITOSO
            LET vproceso = '1';
            
            -- // OBTIENE NOMBRE CORTO DEL CLIENTE Y PRODUCTO
            SELECT num_cte, producto
              INTO vnum_cte, vproducto
              FROM bdicheq:"informix".sc_maechq
             WHERE empresa = '001'
               AND cuenta = pcuenta;
               
            SELECT TRIM(nombre1)||' '||TRIM(apell_paterno)
              INTO vnombre
              FROM bdinteg:"informix".si_cliente
             WHERE numcte = vnum_cte;
             
            LET vnombre_cte = RPAD(vnombre, 53, ' ');
            
            -- // ACUMULA MONTO EN LA CUENTA DE CHEQUES
            SELECT {+INDEX(bdicheq:"informix".sc_acumdiacorresp idx_acumdiario)} cuenta
              INTO vexiste
              FROM bdicheq:"informix".sc_acumdiacorresp
             WHERE cuenta = pcuenta;
             
            IF vexiste is null OR vexiste = '' THEN
                INSERT INTO bdicheq:"informix".sc_acumdiacorresp VALUES
                (pcuenta, pmto_tot);
            ELSE
                UPDATE {+INDEX(bdicheq:"informix".sc_acumdiacorresp idx_acumdiario)} bdicheq:"informix".sc_acumdiacorresp
                   SET monto_acum = monto_acum + pmto_tot
                 WHERE cuenta = pcuenta;
            END IF;
            
            -- // ACUMULA MONTO MENSUAL DEL CORRESPONSAL
            UPDATE {+INDEX(bdicheq:"informix".sc_param_corresp idx_paramcorresp)} bdicheq:"informix".sc_param_corresp
               SET valor = valor + pmto_tot
             WHERE codparam = '003'
               AND empresa = '001';
               
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
                 WHERE codparam = 'TpoOpeCorrDebSorMill'
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
            IF vcodret1 = '110' OR
               vcodret1 = '106' OR
               vcodret1 = '420' OR
               vcodret1 = '552' OR
               vcodret1 = '959' OR
               vcodret1 = '956' OR
               vcodret1 = '401' OR
               vcodret1 = '549' THEN
                LET vcodret1 = '110';
            ELIF vcodret1 = '100' THEN
                LET vcodret1 = '100';
            ELIF vcodret1 = '200' THEN
                LET vcodret1 = '200';
            ELIF vcodret1 = '951' THEN
                LET vcodret1 = '951';
            ELIF vcodret1 = '301' THEN
                LET vcodret1 = '302';
            ELSE 
                LET vcodret1 = '999';
            END IF;            
            
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            
            RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;
        END IF;
    ELSE
        LET vcodret1 = '001';
        
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        
        RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;
    END IF;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
        
    RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;

    END; 

END PROCEDURE;