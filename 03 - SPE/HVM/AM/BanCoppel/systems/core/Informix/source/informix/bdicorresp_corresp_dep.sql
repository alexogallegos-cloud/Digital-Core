CREATE PROCEDURE "informix".corresp_dep( psucursal   CHAR(4),       --- SUCURSAL
                                         pusuario    CHAR(8),       --- USUARIO
                                         pfolio      CHAR(16),      --- FOLIO SUC
                                         pcuenta     CHAR(20),      --- CUENTA
                                         ptarjeta    CHAR(16),      --- TARJETA
                                         pfecha      DATE,          --- FECHA
                                         pmonto      DECIMAL(14,2), --- MONTO
                                         pmoneda     CHAR(3),       --- MONEDA
                                         preferencia CHAR(40) )     --- REFERENCIA
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
    DEFINE vtransaccion     SMALLINT;
    DEFINE vtrxcorresp      CHAR(4);
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
    DEFINE vind_cierre      CHAR(1);
    DEFINE vind_dispon      CHAR(1);
    DEFINE vcorresp         SMALLINT;
    DEFINE vudis_perm       DECIMAL(14,2);
    DEFINE vexiste          SMALLINT;
    DEFINE vmtoacumcoppel   DECIMAL(18,6);
    DEFINE vmtopagoscoppel  DECIMAL(18,6);
    DEFINE vlimctacoppel    DECIMAL(18,6);
    
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
    LET vtransaccion    = 0;
    LET vnomaxudis      = 0;
    LET vhoramax        = '';
    LET vtrxcorresp     = '';
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
    LET vind_cierre     = '0';
    LET vind_dispon     = '0';
    LET vcorresp        = 0;
    LET vudis_perm      = 0.00;
    LET vexiste         = 0;
    LET vmtoacumcoppel  = 0;
    LET vmtopagoscoppel = 0;
    LET vlimctacoppel   = 0;
    
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_dep.out";
    --- TRACE ON;

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
      FROM bdicheq:sc_fechas 
     WHERE empresa = '001';
     
    IF ( vind_cierre = '0' OR vind_dispon = '0' ) THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '004';
        RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;
    END IF;
    
    -- // VALIDACION DE PARAMETROS
    LET pmonto = pmonto / 100;
    
    IF ( psucursal is null OR psucursal = '' OR LENGTH(psucursal) <> 4 ) OR
       ( pusuario is null OR pusuario = '' OR LENGTH(pusuario) <> 8 ) OR
       ( pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16 ) OR
       ( ( pcuenta is null OR pcuenta = '' OR LENGTH(pcuenta) <> 11 ) AND ( ptarjeta is null OR ptarjeta = '' OR LENGTH(ptarjeta) <> 16 ) ) OR
       ( pfecha is null OR pfecha = '' ) OR
       ( pmonto is null OR pmonto <= 0.00 ) OR
       ( pmoneda is null OR pmoneda = '' OR LENGTH(pmoneda) <> 03 ) THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '110';
        RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;
    END IF;
	
	IF SUBSTR(pcuenta, 1, 2) = '11' THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '100';
        RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;
    END IF;
    
    IF LENGTH(pmoneda) = 03 THEN
        LET pmoneda = pmoneda[2,3]; 
    END IF;
    
    -- // OBTIENE DATOS DE LA CUENTA DE CHEQUES
    IF pcuenta is null OR pcuenta = '' THEN
        SELECT cuenta, status_tar
          INTO pcuenta, vstatus_tar
          FROM bdicheq:sc_tarjeta
         WHERE num_tarjeta = ptarjeta;
           
        IF vstatus_tar <> 'A' THEN
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET vcodret1 = '200';
            RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;
        END IF;
    END IF;
    
    IF ptarjeta is null OR ptarjeta = '' THEN
        SELECT num_tarjeta
          INTO ptarjeta
          FROM bdicheq:sc_tarjeta
         WHERE cuenta = pcuenta
           AND tipo_tarjeta = 'T'
           AND status_tar = 'A'
           AND secuencia = (SELECT MAX(secuencia)
                              FROM bdicheq:sc_tarjeta
                             WHERE cuenta = pcuenta
                               AND tipo_tarjeta = 'T'
                               AND status_tar = 'A');
           
        IF ptarjeta IS NULL THEN
            LET ptarjeta = '';
        END IF;
    END IF;
    
    IF SUBSTR(pcuenta, 1, 2) = '80' THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '200';
        RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;
    END IF;
	
	-- // RQM 10 877  Mensaje Depositos Corresponsalia Coppel
	-- // INC 11 1966 ModificaciÃ³n a las transacciÃ³n de traspaso entre cuentas efectivas a traves de corresponsales para no permitir cuentas de personas morales
    IF pcuenta <> '12000002648' THEN
		IF SUBSTR(pcuenta, 1, 4) IN ("1200","1600","2200","2600","9900","9901","2300","2800","2700") THEN
			IF vtransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			LET vcodret1 = '100';
			RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;
		END IF;
        
		-- // OBTIENE EL VALOR DE LA UDI
		SELECT fecha_hoy
		  INTO vfecha_hoy
		  FROM bdinteg:si_fechas
		 WHERE empresa = '001';
        
		SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
               FIRST 1 MAX(hora_tpcambio) 
		  INTO vhoramax
		  FROM bdinteg:si_tpcambio 
		 WHERE empresa = '001' 
		   AND divisa = '09'
		   AND fecha_tpcambio = vfecha_hoy;
        
		IF vhoramax is null OR vhoramax = '' THEN
			SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
                   FIRST 1 precio_venta
			  INTO vprecio_udi
			  FROM bdinteg:si_tpcambio
			 WHERE empresa = '001'
			   AND divisa = '09'
			   AND fecha_tpcambio = vfecha_hoy;
		ELSE
			SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
                   FIRST 1 precio_venta
			  INTO vprecio_udi
			  FROM bdinteg:si_tpcambio
			 WHERE empresa = '001'
			   AND divisa = '09'
			   AND fecha_tpcambio = vfecha_hoy
			   AND hora_tpcambio = vhoramax;
		END IF;
       
		IF vprecio_udi is null OR vprecio_udi = '' THEN
			SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
                   FIRST 1 MAX(fecha_tpcambio) 
			  INTO vfecha_tpcambio
			  FROM bdinteg:si_tpcambio
			 WHERE empresa = '001' 
			   AND divisa = '09'
			   AND fecha_tpcambio <= vfecha_hoy;
           
			SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
                   FIRST 1 MAX(hora_tpcambio) 
			  INTO vhoramax
			  FROM bdinteg:si_tpcambio 
			 WHERE empresa = '001' 
			   AND divisa = '09'
			   AND fecha_tpcambio = vfecha_tpcambio;
            
			IF vhoramax is null OR vhoramax = '' THEN
				SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
                       FIRST 1 precio_venta
				  INTO vprecio_udi
				  FROM bdinteg:si_tpcambio
				 WHERE empresa = '001'
				   AND divisa = '09'
				   AND fecha_tpcambio = vfecha_tpcambio;
			ELSE
				SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
                       FIRST 1 precio_venta
				  INTO vprecio_udi
				  FROM bdinteg:si_tpcambio
				 WHERE empresa = '001'
				   AND divisa = '09'
				   AND fecha_tpcambio = vfecha_tpcambio
				   AND hora_tpcambio = vhoramax;
			END IF;
		END IF;
           
		-- // OBTIENE NUMERO DE TRANSACCION
        SELECT TRIM(valor) 
          INTO vtrxcorresp
          FROM bdicheq:sc_param
         WHERE empresa = '001'
           AND codparam = "trancorrespchq";
           
        IF vtrxcorresp is null OR vtrxcorresp = '' THEN
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET vcodret1 = '110';
            RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;
        END IF;
        
        -- // OBTIENE EL VALOR MAXIMO DE UDIS PARA CAPTACION
		SELECT {+INDEX(bdicheq:sc_param_corresp idx_paramcorresp)} 
               valor
		  INTO vnomaxudis
		  FROM bdicheq:sc_param_corresp
		 WHERE codparam = 'NUMAXUDISCHQ'
		   AND empresa = '001';
           
        IF vnomaxudis is null THEN
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET vcodret1 = '110';
            RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;
        END IF;
        
        -- // OBTIENE EL ACUMULADO GENERAL DE LA CUENTA
		SELECT {+INDEX(bdicheq:sc_acumdiacorresp idx_acumdiario)} 
               SUM(monto_acum)
		  INTO vmtoacumcta
		  FROM bdicheq:sc_acumdiacorresp
		 WHERE cuenta = pcuenta;
     
		IF vmtoacumcta is null THEN
			LET vmtoacumcta = 0.00;
		END IF;
        
        -- // CONVIERTE MONTO DE LA TRANSACCION EN UDIS
		LET vmonto_udi = pmonto / vprecio_udi;
    
		-- // CONVIERTE ACUMULADO DE LA CUENTA EN UDIS
		LET vmtopagosudi = vmtoacumcta / vprecio_udi;
        
        -- // SUMA EL MONTO DE LA TRANSACCION AL ACUMULADO DE LA CUENTA
		LET vlim_cuenta = vmonto_udi + vmtopagosudi;
        
        -- // VALIDA QUE EL ACUMULADO DE LA CUENTA NO REBASE EL LIMITE PERMITIDO PARA EL CORRESPONSAL
        IF ( vlim_cuenta > vnomaxudis ) THEN
			IF vtransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			LET vcodret1 = '002';
			RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;
		END IF; 
        
        -- // OBTIENE EL CANAL DEL CORRESPONSAL Y EL LIMITE PERMITIDO
        SELECT corresp, udis_perm
          INTO vcorresp, vudis_perm
          FROM bdicheq:sc_transacc_corresp
         WHERE transacc = vtrxcorresp;
         
        IF vcorresp is null THEN
            LET vcorresp = 1;
        END IF;
        
        IF vudis_perm is null THEN
            LET vudis_perm = vnomaxudis;
        END IF;
        
        -- // OBTIENE EL ACUMULADO DEL CORRESPONSAL
		SELECT {+INDEX(bdicheq:sc_acumdiacorresp idx_acumdiacorresp_ctacorr)} 
               monto_acum
		  INTO vmtoacumcoppel
		  FROM bdicheq:sc_acumdiacorresp
		 WHERE cuenta = pcuenta
           AND corresp = vcorresp;
     
		IF vmtoacumcoppel is null THEN
			LET vmtoacumcoppel = 0.00;
		END IF;
        
        -- // CONVIERTE MONTO DE LA TRANSACCION EN UDIS
		LET vmonto_udi = pmonto / vprecio_udi;
        
        -- // CONVIERTE ACUMULADO DE LA CUENTA EN UDIS
		LET vmtopagoscoppel = vmtoacumcoppel / vprecio_udi;
        
        -- // SUMA EL MONTO DE LA TRANSACCION AL ACUMULADO DE LA CUENTA
		LET vlimctacoppel = vmonto_udi + vmtopagoscoppel;
        
        IF ( vlimctacoppel > vudis_perm ) THEN
            IF vtransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			LET vcodret1 = '002';
			RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;
		END IF; 
    END IF;
	
    -- // OBTIENE EL PORCENTAJE PARA CORRESPONSALES
    SELECT {+INDEX(bdicheq:sc_param_corresp idx_paramcorresp)} 
           valor
      INTO vporcapcorres
      FROM bdicheq:sc_param_corresp
     WHERE codparam = '002'
       AND empresa = '001';
       
    -- // OBTIENE MONTO GLOBAL DE LA CAPTACION MENSUAL
    SELECT {+INDEX(bdicheq:sc_param_corresp idx_paramcorresp)} 
           valor
      INTO vmtoglobcap
      FROM bdicheq:sc_param_corresp
     WHERE codparam = '001'
       AND empresa = '001';
       
    -- // OBTIENE EL MONTO MENSUAL ACUMULADO DEL CORRESPONSAL
    SELECT {+INDEX(bdicheq:sc_param_corresp idx_paramcorresp)} 
           valor
      INTO vmtomensacum
      FROM bdicheq:sc_param_corresp
     WHERE codparam = '003'
       AND empresa = '001';
     
    -- // VALIDA QUE EL MONTO MENSUAL ACUMULADO DEL CORRESPONSAL NO REBASE EL LIMITE PERMITIDO
    IF ( ( pmonto + vmtomensacum ) < ( vmtoglobcap * ( vporcapcorres / 100 ) ) ) THEN
        SELECT {+INDEX(bdicheq:sc_ctas_sin_corresp idx_ctassincorr)} 
               cuenta
          INTO wcuenta
          FROM bdicheq:sc_ctas_sin_corresp
         WHERE cuenta = pcuenta;
         
        IF wcuenta = pcuenta THEN
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET vcodret1 = '302';
            RETURN vcodret1, TRIM(pcuenta), vnombre_cte, vno_ini_boleto, vno_fin_boleto;
        END IF;
        
        -- // APLICA TRANSACCION DE ABONO EN LA CUENTA DE CHEQUES
        EXECUTE PROCEDURE bdicheq:abono_ref('001',psucursal,pusuario,vtrxcorresp,'0204',pfolio,pcuenta,0,pmonto,pmonto,0,0,0,pmoneda,preferencia,ptarjeta,'') 
        INTO vcodret1;
        
        IF vcodret1 = '000' THEN  
            -- // INICIALIZA BANDERA DE DEPOSITO EXITOSO
            LET vproceso = '1';
            
            -- // OBTIENE NOMBRE CORTO DEL CLIENTE Y PRODUCTO
            SELECT num_cte, producto
              INTO vnum_cte, vproducto
              FROM bdicheq:sc_maechq
             WHERE cuenta = pcuenta;
               
            SELECT TRIM(nombre1)||' '||TRIM(apell_paterno)
              INTO vnombre
              FROM bdinteg:si_cliente
             WHERE numcte = vnum_cte;
             
            LET vnombre_cte = RPAD(vnombre, 53, ' ');

            IF pcuenta = '12000002648' THEN
                LET vnombre = 'DONATIVO CRUZ ROJA MEXICANA';
                LET vnombre_cte = RPAD(vnombre, 53, ' ');
            END IF;
            
            -- // ACUMULA MONTO EN TABLA DE ACUMULADO DIARIO DE CORRESPONSALES
            SELECT {+INDEX(bdicheq:sc_acumdiacorresp idx_acumdiacorresp_ctacorr)} 
                   COUNT(*)
              INTO vexiste
              FROM bdicheq:"informix".sc_acumdiacorresp
             WHERE cuenta = pcuenta
               AND corresp = vcorresp
               AND transacc = vtrxcorresp;

            IF vexiste = 0 THEN
                INSERT INTO bdicheq:sc_acumdiacorresp 
                ( cuenta, monto_acum, corresp, transacc )
                VALUES
                ( pcuenta, pmonto, vcorresp, vtrxcorresp );
            ELSE
                UPDATE {+INDEX(bdicheq:sc_acumdiacorresp idx_acumdiacorresp_ctacorr)} 
                       bdicheq:sc_acumdiacorresp
                   SET monto_acum = monto_acum + pmonto
                 WHERE cuenta = pcuenta
                   AND corresp = vcorresp
                   AND transacc = vtrxcorresp;
            END IF;
            
            -- // ACUMULA MONTO MENSUAL DEL CORRESPONSAL
            UPDATE {+INDEX(bdicheq:sc_param_corresp idx_paramcorresp)} 
                   bdicheq:sc_param_corresp
               SET valor = valor + pmonto
             WHERE codparam = '003'
               AND empresa = '001';
               
            -- // VALIDA SI EL PRODUCTO PARTICIPA EN EL SORTEO MILLONARIO
            SELECT COUNT(*)
              INTO vexiste_prod
              FROM bdicheq:sc_prodcorr_sortmill
             WHERE producto = vproducto;
               
            IF vexiste_prod > 0 THEN
                SELECT valor::INT
                  INTO vcanal
                  FROM bdicheq:sc_param_corresp
                 WHERE codparam = 'CanalCorrespSortMill'
                   AND empresa = '001';
                   
                SELECT valor::INT
                  INTO vtpo_oper
                  FROM bdicheq:sc_param_corresp
                 WHERE codparam = 'TpoOpeCorrDebSorMill'
                   AND empresa = '001';
                   
                LET vprod = vproducto;
                   
                EXECUTE PROCEDURE bdinteg:sp_sorteobancoppel( vcanal, vtpo_oper, vprod, vnum_cte, psucursal, pfolio, pmonto, vfecha_hoy )
                INTO vcodret3, vmensaje, vnuminiboleto, vnumfinboleto;
                
                IF vcodret3 = '00000' THEN
                    LET vnuminiboleto2 = vnuminiboleto;
                    LET vnumfinboleto2 = vnumfinboleto;

                    IF LENGTH(vnuminiboleto2) = 8  THEN
                        LET vno_ini_boleto = '0' || vnuminiboleto2;
                    ELSE
                        LET vno_ini_boleto =  vnuminiboleto;
                    END IF;
                    
                    IF LENGTH(vnumfinboleto2) = 8 THEN
                        LET vno_fin_boleto = '0' || vnumfinboleto2;
                    ELSE
                        LET vno_fin_boleto = vnumfinboleto;
                    END IF;
                ELSE
                    LET vno_ini_boleto = '000000000';
                    LET vno_fin_boleto = '000000000';
                END IF;
            END IF;
        ELSE
            IF vcodret1 IN('110','106','420','552','959','956','401','549') THEN
                LET vcodret1 = '110';
            ELIF vcodret1 = '100' THEN
                LET vcodret1 = '100';
            ELIF vcodret1 = '200' THEN
                LET vcodret1 = '200';
            ELIF vcodret1 = '951' THEN
                LET vcodret1 = '951';
            ELIF vcodret1 = '301' THEN
                LET vcodret1 = '302';
            ELIF vcodret1 = '397' THEN
                LET vcodret1 = '001';
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
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '001';
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