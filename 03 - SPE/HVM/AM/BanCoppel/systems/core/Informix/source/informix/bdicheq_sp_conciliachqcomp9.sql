CREATE PROCEDURE "informix".sp_conciliachqcomp9( pempresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
        
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vcontador1   INTEGER;
    DEFINE vcontador2   INTEGER;
    DEFINE vcontador3   INTEGER;
    DEFINE vcomienza1   SMALLINT;
    DEFINE ven_transacc SMALLINT;
    
    DEFINE vsql          LVARCHAR(600);
    DEFINE vstmt         VARCHAR(250);
    DEFINE vfecha        VARCHAR(8);
    DEFINE vfecha_hoy    DATE;
    DEFINE vfecha_ant    DATE;
    DEFINE vpri_hab_mes  DATE;
    DEFINE vfecha_actual DATE;
    DEFINE vproceso      VARCHAR(16);
    DEFINE vsistema      CHAR(2);
    DEFINE vexiste       INTEGER;
    DEFINE vexistefin    INTEGER;
    DEFINE vusuario      VARCHAR(10);
    DEFINE vfechaprocsdo DATE;
    
    DEFINE vcuenta      VARCHAR(20);
    DEFINE vnum_cte     VARCHAR(20);
    DEFINE vsucursal    CHAR(4);
    DEFINE vejecutivo   VARCHAR(8);
    DEFINE vproducto    CHAR(4);
    
    DEFINE vcapital_anterior    MONEY(18,2);
    DEFINE vcapital_calculado   MONEY(18,2);
    DEFINE vmovs_cargo_capital  MONEY(18,2);
    DEFINE vmovs_abono_capital  MONEY(18,2);
    DEFINE vcapital_actual      MONEY(18,2);
    DEFINE vdiferencia_capital  MONEY(18,2);
    
    DEFINE vinteres_anterior    MONEY(18,2);
    DEFINE vinteres_calculado   MONEY(18,2);
    DEFINE vmovs_cargo_interes  MONEY(18,2);
    DEFINE vmovs_abono_interes  MONEY(18,2);
    DEFINE vinteres_actual      MONEY(18,2);
    DEFINE vdiferencia_interes  MONEY(18,2);
    
    DEFINE vcuentaini           VARCHAR(20);
    DEFINE vcuentafin           VARCHAR(20);
    
    DEFINE vcuenta_cargo        VARCHAR(14);  
    DEFINE vcuenta_abono        VARCHAR(14);  
    DEFINE vmonto_tot           MONEY(14,2);
    DEFINE vexiste_cta          SMALLINT;
    DEFINE vgenero              CHAR(1);
    
    LET vcodret1     = '000';
    LET vcodret2     = '000';
    LET vcodret3     = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vcontador3   = 0;
    LET vcomienza1   = -1;
    LET ven_transacc = 0; 
    
    LET vsql          = '';
    LET vstmt         = '';
    LET vfecha        = '';
    LET vfecha_hoy    = ''; 
    LET vfecha_ant    = '';
    LET vpri_hab_mes  = '';
    LET vfecha_actual = '';
    LET vproceso      = 'conciliachqcomp9';
    LET vsistema      = '01';
    LET vexiste       = 0;
    LET vexistefin    = 0;
    LET vusuario      = user;
    LET vfechaprocsdo = '';
    
    LET vcuenta      = ''; 
    LET vproducto    = '';
    LET vnum_cte     = '';
    LET vsucursal    = '';
    LET vejecutivo   = '';
    
    LET vcapital_anterior   = 0.00;
    LET vcapital_calculado  = 0.00;
    LET vmovs_cargo_capital = 0.00;
    LET vmovs_abono_capital = 0.00;
    LET vcapital_actual     = 0.00;
    LET vdiferencia_capital = 0.00;
    
    LET vinteres_anterior   = 0.00;
    LET vinteres_calculado  = 0.00;
    LET vmovs_cargo_interes = 0.00;
    LET vmovs_abono_interes = 0.00;
    LET vinteres_actual     = 0.00;
    LET vdiferencia_interes = 0.00;
    
    LET vcuentaini = '';
    LET vcuentafin = '';
     
    LET vcuenta_cargo = '';
    LET vcuenta_abono = '';
    LET vmonto_tot    = 0.00;
    LET vexiste_cta   = 0;
    LET vgenero       = '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
      SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliachqcomp9.err";
      TRACE ON;

      IF sql_err <> 0 THEN
         LET vcodret1 = sql_err;
         LET vcodret2 = isam_err;
         LET vcodret3 = desc_err;

         IF ven_transacc = 1 THEN
            ROLLBACK WORK;
         END IF;

         UPDATE bdinteg:sx_contproc
            SET ejecutivo   = vusuario,
                status_proc = 'C',
                codret      = vcodret1,
                hora_fin    = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
          WHERE empresa = pempresa
            AND proceso = vproceso
            AND fecha   = vfecha_hoy
            AND sistema = vsistema;

         RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;

      END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/home/c98789058/SPL_ACCENTURE/sp_conciliachqcomp9.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE LAS FECHAS DEL SISTEMA
    SELECT fecha_hoy, fecha_ant, pri_hab_mes, fecha_hoy
      INTO vfecha_hoy, vfecha_ant, vpri_hab_mes, vfecha_actual
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    -- // VALIDA LA FECHA DE AYER
    LET vfecha_hoy = vfecha_hoy - 1 UNITS DAY;
    
    CALL sp_valfechabil(vfecha_hoy, '-') 
    RETURNING vcodret1, vfecha_hoy;
    
    -- // VALIDA LA FECHA DE ANTIER
    LET vfecha_ant = vfecha_ant - 1 UNITS DAY;
    
    CALL sp_valfechabil(vfecha_ant, '-') 
    RETURNING vcodret1, vfecha_ant;

	-- // GUARDA REGISTRO DE CONTROL EN TABLA DE INTEGRAL
    IF NOT EXISTS (SELECT empresa FROM bdinteg:sx_contproc
				   WHERE empresa = pempresa
					 AND proceso = vproceso
					 AND fecha   = vfecha_hoy
					 AND sistema = vsistema) THEN

	  INSERT INTO bdinteg:sx_contproc
		   VALUES (pempresa, vproceso, vfecha_hoy, vsistema, 'I', vusuario,
				  (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);

    ELSE
	  IF NOT EXISTS (SELECT empresa FROM bdinteg:sx_contproc
					  WHERE empresa     = pempresa
						AND proceso     = vproceso
						AND fecha       = vfecha_hoy
						AND sistema     = vsistema
						AND status_proc = "F") THEN

		 UPDATE bdinteg:sx_contproc
			SET ejecutivo   = vusuario,
				status_proc = 'I',
				codret      = ' ',
				hora_fin    = ' ',
				hora_ini    = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
		  WHERE empresa = pempresa
			AND proceso = vproceso
			AND fecha   = vfecha_hoy
			AND sistema = vsistema;
			
	  ELSE
		 LET vcodret1 = "958";
		 LET vcodret2 = "958";

		 SELECT descripcion INTO vcodret3
		   FROM bdinteg:si_codret
		  WHERE sistema = vsistema
			AND codigo_retorno = vcodret1;

		 RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
	  END IF;
    END IF;
    
	--Se quita Directiva
    --Se tiene Sequential Scan pero con DYNAMIC HASH JOIN (Build Outer)
	--Productos distintos a 2000 y 1100
    -- // TABLA TEMPORAL DE MOVIMIENTOS
    SELECT 
           mov.cuenta, mov.transacc, mov.monto_tot,
           TRIM(prod.c_ccmayor)||TRIM(prod.c_ccsub)||TRIM(prod.c_ccsubsub)||TRIM(prod.c_ccsssub)||TRIM(prod.c_ccssssub)||TRIM(prod.c_sector) AS cta_cargo,
           TRIM(prod.a_ccmayor)||TRIM(prod.a_ccsub)||TRIM(prod.a_ccsubsub)||TRIM(prod.a_ccsssub)||TRIM(prod.a_ccssssub)||TRIM(prod.a_sector) AS cta_abono
      FROM sc_movdia_concil mov,
           bdinteg:si_transacc tra,
           bdinteg:si_prodtran prod
     WHERE mov.fech_alt = vfecha_hoy
       AND mov.cancelad != 'S'
       AND mov.producto NOT IN('2000','1100')
       AND tra.empresa = mov.empresa
       AND tra.numero = mov.transacc
       AND tra.se_contabiliza = 'S'
       AND tra.sistema = '01'
       AND prod.transaccion = tra.numero
       AND prod.producto = mov.producto
       AND prod.sistema = tra.sistema
      INTO TEMP tmp_concilia WITH NO LOG;

   CREATE INDEX idx_concilia1 ON tmp_concilia(cuenta) ONLINE;
    
   IF vfecha_actual = vpri_hab_mes THEN
		--Se agrega Directiva para tomar INDEX PATH.
        FOREACH cur_1 WITH HOLD FOR
            SELECT {+INDEX(sc_maechq idxscmaechqpba )}
			chq.cuenta, chq.producto, chq.num_cte, chq.sucursal, noc.ejecutivo
              INTO vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo
              FROM sc_maechq chq,
                   sc_maenoc noc
             WHERE chq.producto NOT IN('2000','1100')
               AND ( chq.status_cta <> '2' OR chq.fecha_proceso >= vfecha_hoy )
               AND noc.cuenta = chq.cuenta
               AND noc.fecha_alta < vfecha_actual
               
            IF vcomienza1 = -1 THEN
                LET vcomienza1 = 0;
                LET ven_transacc = 1; 
                BEGIN WORK;
            END IF;
            
            SELECT sexo
              INTO vgenero
              FROM bdinteg:si_ctepf 
             WHERE numcte = vnum_cte;
             
            IF vgenero is null OR vgenero = '' OR vgenero NOT IN('F','M') THEN
                LET vgenero = 'E';
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE sp_capintafecha(vcuenta, vfecha_ant) 
            INTO vcodret1, vcapital_anterior, vinteres_anterior;
            
            IF vcodret1 = '100' THEN
                LET vcapital_anterior = 0.00;
                LET vinteres_anterior = 0.00;
                LET vcodret1 = '000';
            END IF;
            
            LET vcapital_calculado = vcapital_anterior;
            LET vinteres_calculado = vinteres_anterior;
            
			--Se quita Directiva,busqueda OK, con INDEX
            -- // OBTIENE LOS MOVIMIENTOS DE CAPITAL E INTERES
            FOREACH cur_1_1 WITH HOLD FOR
                SELECT --{+INDEX(tmp_concilia idx_concilia)} 
                       cta_cargo, cta_abono, monto_tot
                  INTO vcuenta_cargo, vcuenta_abono, vmonto_tot
                  FROM tmp_concilia
                 WHERE cuenta = vcuenta
                 
                IF vcuenta_cargo IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo IN('CAPITAL','SOBREGIRO') ) THEN
                    LET vcapital_calculado = vcapital_calculado - vmonto_tot;
                    LET vmovs_cargo_capital = vmovs_cargo_capital + vmonto_tot;
                END IF;
                        
                IF vcuenta_abono IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo IN('CAPITAL','SOBREGIRO') ) THEN   
                    LET vcapital_calculado = vcapital_calculado + vmonto_tot;
                    LET vmovs_abono_capital = vmovs_abono_capital + vmonto_tot;
                END IF;
                    
                IF vcuenta_cargo IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo = 'INTERES' ) THEN
                    LET vinteres_calculado = vinteres_calculado - vmonto_tot;
                    LET vmovs_cargo_interes = vmovs_cargo_interes + vmonto_tot;
                END IF;
                    
                IF vcuenta_abono IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo = 'INTERES' ) THEN
                    LET vinteres_calculado = vinteres_calculado + vmonto_tot;
                    LET vmovs_abono_interes = vmovs_abono_interes + vmonto_tot;
                END IF;
                
                LET vcuenta_cargo = '';
                LET vcuenta_abono = '';
                LET vmonto_tot    = 0.00;
            END FOREACH;
			--Fin de FOREACH cur_1_1
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE sp_capintafecha(vcuenta, vfecha_hoy) 
            INTO vcodret1, vcapital_actual, vinteres_actual;
            
            IF vcodret1 = '100' THEN
                LET vcapital_actual = 0.00;
                LET vinteres_actual = 0.00;
                LET vcodret1 = '000';
            END IF;
            
            -- // OBTIENE DIFERENCIAS
            LET vdiferencia_capital = vcapital_actual - vcapital_calculado;
            LET vdiferencia_interes = vinteres_actual - vinteres_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            /*SELECT COUNT(*)
              INTO vexiste_cta
              FROM conciliachq
             WHERE cuenta = vcuenta;*/
             
            --IF vexiste_cta > 0 THEN
			IF EXISTS (SELECT 1 FROM bdicheq:conciliachq WHERE cuenta = vcuenta) THEN
                UPDATE conciliachq
                   SET fecha              = vfecha_hoy,
                       capital_anterior   = vcapital_anterior,
                       movs_cargo         = vmovs_cargo_capital,
                       movs_abono         = vmovs_abono_capital,
                       capital_calculado  = vcapital_calculado,
                       capital_actual     = vcapital_actual,
                       diferencia_capital = vdiferencia_capital,
                       interes_anterior   = vinteres_anterior,
                       movs_cargo_interes = vmovs_cargo_interes,
                       movs_abono_interes = vmovs_abono_interes,
                       interes_calculado  = vinteres_calculado,
                       interes_actual     = vinteres_actual,
                       diferencia_interes = vdiferencia_interes
                 WHERE cuenta = vcuenta;
            ELSE
                INSERT INTO conciliachq VALUES
                (vfecha_hoy, vcuenta, vproducto, vnum_cte, vgenero, vsucursal, vejecutivo,
                 vcapital_anterior, vmovs_cargo_capital, vmovs_abono_capital, vcapital_calculado, vcapital_actual, vdiferencia_capital, 
                 vinteres_anterior, vmovs_cargo_interes, vmovs_abono_interes, vinteres_calculado, vinteres_actual, vdiferencia_interes);
            END IF;
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF (vdiferencia_capital != 0.00 OR vdiferencia_interes != 0.00) THEN
                INSERT INTO conciliachq_dif VALUES
                (vfecha_hoy, vcuenta, vproducto, vnum_cte, vgenero, vsucursal, vejecutivo,
                 vcapital_anterior, vmovs_cargo_capital, vmovs_abono_capital, vcapital_calculado, vcapital_actual, vdiferencia_capital, 
                 vinteres_anterior, vmovs_cargo_interes, vmovs_abono_interes, vinteres_calculado, vinteres_actual, vdiferencia_interes); 
                 
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 10000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
            
            LET vcuenta      = ''; 
            LET vproducto    = '';
            LET vnum_cte     = '';
            LET vsucursal    = '';
            LET vejecutivo   = '';
            
            LET vcapital_anterior   = 0.00;
            LET vcapital_calculado  = 0.00;
            LET vmovs_cargo_capital = 0.00;
            LET vmovs_abono_capital = 0.00;
            LET vcapital_actual     = 0.00;
            LET vdiferencia_capital = 0.00;
            
            LET vinteres_anterior   = 0.00;
            LET vinteres_calculado  = 0.00;
            LET vmovs_cargo_interes = 0.00;
            LET vmovs_abono_interes = 0.00;
            LET vinteres_actual     = 0.00;
            LET vdiferencia_interes = 0.00;
            
            LET vcuenta_cargo = '';
            LET vcuenta_abono = '';
            LET vmonto_tot    = 0.00;
            LET vexiste_cta   = 0;
            LET vgenero       = '';
        END FOREACH;
		--Fin de FOREACH cur_1
        
    ELSE
		--Se agrega Directiva para tomar INDEX PATH.
        FOREACH cur_2 WITH HOLD FOR
            SELECT {+INDEX(sc_maechq idxscmaechqpba )} 
			chq.cuenta, chq.producto, chq.num_cte, chq.sucursal, noc.ejecutivo
              INTO vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo
              FROM sc_maechq chq,
                   sc_maenoc noc
             WHERE chq.producto NOT IN('2000','1100')
               AND ( chq.status_cta <> '2' OR chq.fecha_proceso >= vfecha_hoy )
               AND noc.cuenta = chq.cuenta
               AND noc.fecha_alta < vfecha_actual
               
            IF vcomienza1 = -1 THEN
                LET vcomienza1 = 0;
                LET ven_transacc = 1; 
                BEGIN WORK;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE sp_capintafecha(vcuenta, vfecha_ant) 
            INTO vcodret1, vcapital_anterior, vinteres_anterior;
            
            IF vcodret1 = '100' THEN
                LET vcapital_anterior = 0.00;
                LET vinteres_anterior = 0.00;
                LET vcodret1 = '000';
            END IF;
            
            LET vcapital_calculado = vcapital_anterior;
            LET vinteres_calculado = vinteres_anterior;
            
			--Se quita Directiva, bÃºsqueda OK, con INDEX
            -- // OBTIENE LOS MOVIMIENTOS DE CAPITAL E INTERES
            FOREACH cur_2_1 WITH HOLD FOR
                SELECT --{+INDEX(tmp_concilia idx_concilia)} 
                       cta_cargo, cta_abono, monto_tot
                  INTO vcuenta_cargo, vcuenta_abono, vmonto_tot
                  FROM tmp_concilia
                 WHERE cuenta = vcuenta
                 
                IF vcuenta_cargo IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo IN('CAPITAL','SOBREGIRO') ) THEN
                    LET vcapital_calculado = vcapital_calculado - vmonto_tot;
                    LET vmovs_cargo_capital = vmovs_cargo_capital + vmonto_tot;
                END IF;
                        
                IF vcuenta_abono IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo IN('CAPITAL','SOBREGIRO') ) THEN   
                    LET vcapital_calculado = vcapital_calculado + vmonto_tot;
                    LET vmovs_abono_capital = vmovs_abono_capital + vmonto_tot;
                END IF;
                    
                IF vcuenta_cargo IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo = 'INTERES' ) THEN
                    LET vinteres_calculado = vinteres_calculado - vmonto_tot;
                    LET vmovs_cargo_interes = vmovs_cargo_interes + vmonto_tot;
                END IF;
                    
                IF vcuenta_abono IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo = 'INTERES' ) THEN
                    LET vinteres_calculado = vinteres_calculado + vmonto_tot;
                    LET vmovs_abono_interes = vmovs_abono_interes + vmonto_tot;
                END IF;
                
                LET vcuenta_cargo = '';
                LET vcuenta_abono = '';
                LET vmonto_tot    = 0.00;
            END FOREACH;
			--Fin de FOREACH cur_2_1
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE sp_capintafecha(vcuenta, vfecha_hoy) 
            INTO vcodret1, vcapital_actual, vinteres_actual;
            
            IF vcodret1 = '100' THEN
                LET vcapital_actual = 0.00;
                LET vinteres_actual = 0.00;
                LET vcodret1 = '000';
            END IF;
            
            -- // OBTIENE DIFERENCIAS
            LET vdiferencia_capital = vcapital_actual - vcapital_calculado;
            LET vdiferencia_interes = vinteres_actual - vinteres_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            /*SELECT COUNT(*)
              INTO vexiste_cta
              FROM conciliachq
             WHERE cuenta = vcuenta;*/
             
            --IF vexiste_cta > 0 THEN
			IF EXISTS (SELECT 1 FROM bdicheq:conciliachq WHERE cuenta = vcuenta) THEN
                UPDATE conciliachq
                   SET fecha              = vfecha_hoy,
                       capital_anterior   = vcapital_anterior,
                       movs_cargo         = vmovs_cargo_capital,
                       movs_abono         = vmovs_abono_capital,
                       capital_calculado  = vcapital_calculado,
                       capital_actual     = vcapital_actual,
                       diferencia_capital = vdiferencia_capital,
                       interes_anterior   = vinteres_anterior,
                       movs_cargo_interes = vmovs_cargo_interes,
                       movs_abono_interes = vmovs_abono_interes,
                       interes_calculado  = vinteres_calculado,
                       interes_actual     = vinteres_actual,
                       diferencia_interes = vdiferencia_interes
                 WHERE cuenta = vcuenta;
            ELSE
                INSERT INTO conciliachq VALUES
                (vfecha_hoy, vcuenta, vproducto, vnum_cte, vgenero, vsucursal, vejecutivo,
                 vcapital_anterior, vmovs_cargo_capital, vmovs_abono_capital, vcapital_calculado, vcapital_actual, vdiferencia_capital, 
                 vinteres_anterior, vmovs_cargo_interes, vmovs_abono_interes, vinteres_calculado, vinteres_actual, vdiferencia_interes);
            END IF;
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF (vdiferencia_capital != 0.00 OR vdiferencia_interes != 0.00) THEN
                INSERT INTO conciliachq_dif VALUES
                (vfecha_hoy, vcuenta, vproducto, vnum_cte, vgenero, vsucursal, vejecutivo,
                 vcapital_anterior, vmovs_cargo_capital, vmovs_abono_capital, vcapital_calculado, vcapital_actual, vdiferencia_capital, 
                 vinteres_anterior, vmovs_cargo_interes, vmovs_abono_interes, vinteres_calculado, vinteres_actual, vdiferencia_interes); 
                 
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 10000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
            
            LET vcuenta      = ''; 
            LET vproducto    = '';
            LET vnum_cte     = '';
            LET vsucursal    = '';
            LET vejecutivo   = '';
            
            LET vcapital_anterior   = 0.00;
            LET vcapital_calculado  = 0.00;
            LET vmovs_cargo_capital = 0.00;
            LET vmovs_abono_capital = 0.00;
            LET vcapital_actual     = 0.00;
            LET vdiferencia_capital = 0.00;
            
            LET vinteres_anterior   = 0.00;
            LET vinteres_calculado  = 0.00;
            LET vmovs_cargo_interes = 0.00;
            LET vmovs_abono_interes = 0.00;
            LET vinteres_actual     = 0.00;
            LET vdiferencia_interes = 0.00;
            
            LET vcuenta_cargo = '';
            LET vcuenta_abono = '';
            LET vmonto_tot    = 0.00;
            LET vexiste_cta   = 0;
            LET vgenero       = '';
        END FOREACH;
		--Fin de FOREACH cur_2
    END IF;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE bdinteg:sx_contproc
      SET ejecutivo = vusuario,
          status_proc = 'F',
          codret      = vcodret1,
          hora_fin    = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas)
    WHERE empresa = pempresa
      AND proceso = vproceso
      AND fecha   = vfecha_hoy
      AND sistema = vsistema;
           
    END;
    
    RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
    
END PROCEDURE;