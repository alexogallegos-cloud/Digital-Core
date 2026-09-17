CREATE PROCEDURE "informix".sp_del_solic_const (pempresa char(3)) 
    RETURNING CHAR(5) AS v_sCodRet
	
    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
		
	DEFINE v_numcte 			CHAR(20);
	DEFINE v_cuenta 			CHAR(20);
	DEFINE v_ejercicio		    CHAR(4);
	DEFINE v_fecha_recepcion    DATE;
	DEFINE v_fecha_hoy			DATE;
	
	-- Optimizacion de SPL declaracion
	define vsflagentransaccion 	char(1);
	define viconsecutivo        integer;
	define vicontadorregistros  integer;
	
    --SET DEBUG FILE TO  "sp_del_solic_const.out"; 
    --TRACE ON;
	
	LET v_sCodRet = '000';
	LET v_numcte = ''; 			
	LET v_cuenta = '';
	LET v_ejercicio = '';	
	LET v_fecha_recepcion = TODAY;
	LET v_fecha_hoy = TODAY;
	
	-- Optimizacion de SPL inicializaciÃ³n
	let vsflagentransaccion = '';
	let viconsecutivo = 0;
	let vicontadorregistros = 0; 
	

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;
		
		SELECT fecha_hoy INTO v_fecha_hoy 
			FROM bdinteg:si_fechas 
				WHERE empresa = '001';
		
		let vsflagentransaccion = 'F';
		
		FOREACH cusor1 with hold for
		--FOREACH WITH HOLD 
			SELECT b.numcte,b.cuenta,b.ejercicio 
					INTO v_numcte,v_cuenta,v_ejercicio
				FROM bdiedoelec:edelec_solic_const a
				    join bdiedoelec:edelec_log_solic_const b 
				      on a.numcte = b.numcte and a.cuenta = b.cuenta
					WHERE 	a.fecha_vigencia < v_fecha_hoy
							AND NOT EXISTS ( SELECT 1 FROM bdiedoelec:edelec_log_solic_const c 
													WHERE 	c.empresa = pempresa
															AND c.numcte = a. numcte 
															AND c.ejercicio = a.ejercicio 
															AND c.status_envio_edocta = 'AE')
				GROUP BY b.numcte,b.cuenta,b.ejercicio 
				ORDER BY ejercicio ASC
			
			/*SELECT b.numcte,b.cuenta,b.ejercicio 
					INTO v_numcte,v_cuenta,v_ejercicio
				FROM bdiedoelec:edelec_solic_const a, bdiedoelec:edelec_log_solic_const b 
					WHERE 	a. numcte = b. numcte
							AND a.cuenta = b.cuenta
							AND a. fecha_vigencia < v_fecha_hoy
							AND NOT EXISTS ( SELECT 1 FROM bdiedoelec:edelec_log_solic_const c 
													WHERE 	c.empresa = pempresa
															AND c.numcte = a. numcte 
															AND c.ejercicio = a.ejercicio 
															AND c.status_envio_edocta = 'AE')
				GROUP BY b.numcte,b.cuenta,b.ejercicio 
				ORDER BY ejercicio ASC*/
				
			if (vsflagentransaccion = 'F') then 
				begin work;
				let vsflagentransaccion = 'V';
			end if;
			
			INSERT INTO bdiedoelec:edelec_solic_const_ne (empresa,numcte,cuenta,ejercicio,fecha_recepcion,fecha_modificacion)
				  VALUES (pempresa,v_numcte,v_cuenta,v_ejercicio,v_fecha_recepcion,TODAY);
			
			DELETE FROM bdiedoelec:edelec_solic_const 
			      WHERE numcte = v_numcte
					AND cuenta = v_cuenta
					AND ejercicio = v_ejercicio;
			
			DELETE FROM bdiedoelec:edelec_log_solic_const
				  WHERE numcte = v_numcte
					AND cuenta = v_cuenta
					AND ejercicio = v_ejercicio;
					
			if (vicontadorregistros = 500) then --verifica si alcanzo el maximo de transacciones por bloque
				commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
				continue foreach;
			end if;
			
		--CONTINUE FOREACH;
		END FOREACH;
		
		if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
			commit work;
			let vsflagentransaccion = 'F';
		end if;	
		
		RETURN v_sCodRet;    
    END
END PROCEDURE;