CREATE PROCEDURE "informix".sp_cobra_comision_cap_com4(p_empresa char(3))
    RETURNING   CHAR(5);
    
    DEFINE v_c_vcomienza    SMALLINT;
	DEFINE v_c_vcomienza_c2 SMALLINT;
	DEFINE ven_transacc_c2  SMALLINT;
    DEFINE v_c_vcontador    INTEGER;
	DEFINE v_c_vcontador_c2 INTEGER;	
    DEFINE vsqlerr          INTEGER;
    DEFINE iIsamErr         SMALLINT;
    DEFINE cErrorInfo       CHAR(80);
	DEFINE vErrorInfo       CHAR(80);
    DEFINE vcodret          CHAR(5);
	DEFINE v_fecha_ini      DATE; 
	DEFINE v_fecha_fin      DATE;
	DEFINE v_fecha_aniomes  DATE; 
	DEFINE v_num_cte_cargo  CHAR(20);
	DEFINE v_cuenta         CHAR(20);
	DEFINE v_producto       CHAR(4);
	DEFINE v_aniomes        CHAR(6);
	DEFINE v_sdo_prom       MONEY (14,2);
	DEFINE v_valida_inv_cre INTEGER;
	DEFINE v_valida_pagare  INTEGER;
	DEFINE v_cte_mov        CHAR(20);
	DEFINE v_cta_mov        CHAR(20);
	DEFINE v_fecha_movhis    DATE;
	DEFINE v_fecha_movhisold DATE;
	DEFINE v_sdo_prom_car    MONEY (14,2);
	DEFINE v_fecha_ant       DATE;
	DEFINE vcliente_max      CHAR(20);
	DEFINE vcliente_min      CHAR(20);
	DEFINE vinicio_proceso   SMALLINT;
	DEFINE v_val_tbl_ctas_serv4 INTEGER;
	DEFINE vporta_mov        INTEGER;
	DEFINE vporta_mov_old    INTEGER;
	DEFINE vportamovtot      INTEGER;
	DEFINE v_num_cte        CHAR(20);
	DEFINE ven_transacc     SMALLINT;
	DEFINE v_sdprom         INTEGER;
	DEFINE vini_complents   SMALLINT;
	DEFINE vcontador1       INTEGER;
	DEFINE vcontador2       INTEGER;
	
    LET v_c_vcomienza       = -1;	
	LET v_c_vcomienza_c2    = -1;
	LET ven_transacc_c2     = 0;
    LET v_c_vcontador       = 0;
	LET v_c_vcontador_c2    = 0;
    LET vsqlerr             = 0; 
    LET iIsamErr            = 0;
    LET cErrorInfo          = "";   
    LET vcodret             = "00000";
	LET vErrorInfo          = "INICIO DEL PROCESO";
	LET vinicio_proceso     = 0;
	LET v_num_cte_cargo     = "";
	LET v_cta_mov           = "";
	LET vporta_mov          = 0;
	LET vporta_mov_old      = 0;
	LET vportamovtot        = 0;
	LET v_num_cte           = ""; 
    LET ven_transacc        = 0;
    LET v_sdprom            = 0;
	LET vini_complents      = 0;
	LET vcontador1       = 0;
    LET vcontador2       = 0;

    BEGIN
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	    IF  vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cobra_comision_cap_com4.err";
	 	    TRACE ON;
			LET vcodret    = vsqlerr;
            LET vErrorInfo = cErrorInfo;
            LET v_num_cte_cargo = v_num_cte_cargo;
            LET v_cta_mov  = v_cta_mov;
            IF v_c_vcomienza = 1 OR ven_transacc_c2 = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodRet;
        END IF;
    END EXCEPTION;
	
	--SET   DEBUG FILE TO '/resplogifx/conciliachq/sp_cobra_comision_cap_com4.txt';
	--SET   DEBUG FILE TO '/RESPALDOSNEW/opti/sp_cobra_comision_cap_com4.txt';
    --TRACE ON;
	
   	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3; 
	
    SELECT DATE(pri_dia_mes - 1 UNITS MONTH), DATE(pri_dia_mes - 1  UNITS DAY), DATE(fecha_hoy - 1 UNITS MONTH), fecha_ant
	INTO   v_fecha_ini,                       v_fecha_fin,                      v_fecha_aniomes,                 v_fecha_ant
	FROM   sc_fechas; 
	
	LET v_aniomes = TO_CHAR(v_fecha_aniomes,'%Y%m');
	
	--TABLA TEMPORAL UTILIZADA PARA LAS CUENTAS DE PORTABILIDAD
    CREATE TEMP TABLE tmp_portab_dts4 (
	cliente      CHAR(20),
	cuenta       CHAR(20),
	num_tarjeta  CHAR(20),
	saldo_promedio MONEY (14,2));
	
	
	---ESPERAN A QUE SE TRUNQUE LA TABLA sc_ctas_total PARA QUE TODOS LOS COMPLEMENTOS LA PUEDAN UTILIZAR
	WHILE  vini_complents = 0
           SET ISOLATION TO DIRTY READ;
           SELECT COUNT(*)
           INTO   vini_complents
           FROM   sc_contproc
           WHERE  empresa = p_empresa
           AND    proceso = 'ini_complents'
           AND    fecha = v_fecha_ant;
    END WHILE;
	
	
	--SE OBTIENE EL SALDO PROMEDIO DE LAS CUENTAS RELACIONDAS CON EL PRODUCTO CONSIDERADO
	FOREACH WITH HOLD
 
            SELECT a.num_cte, a.cuenta, a.producto
		    INTO   v_num_cte, v_cuenta, v_producto
		    FROM   sc_maechq AS a,
                   sc_maenoc AS b 
            WHERE  a.cuenta     = b.cuenta  
		    AND    a.status_cta = "5"
			AND    a.producto   = "2000"
		---	AND    a.producto   IN (SELECT producto FROM sc_productos_com)
	        AND    b.fecha_alta < v_fecha_ini 
			
			-- Abre la transaccion 
		    IF  (v_c_vcomienza = -1) THEN
                LET v_c_vcomienza = 0;
                LET ven_transacc = 1;
                BEGIN WORK;
            END IF;
				
			SELECT (capvigacum / diacum)
			INTO   v_sdo_prom
			FROM   sc_sdodiarioc
			WHERE  cuenta  = v_cuenta
			AND    aniomes = v_aniomes;
				
			INSERT INTO sc_ctas_total VALUES (v_num_cte,v_cuenta,v_producto,v_sdo_prom);
									
			LET v_c_vcontador = v_c_vcontador + 1;
			--Realiza commit cada 5000 registros 
			IF (v_c_vcontador >= 500) THEN
               LET v_c_vcontador = 0;
               COMMIT WORK;
               BEGIN WORK;
            END IF; 
			
    END FOREACH;
	
	--Si la transaccion esta abierta realiza el commit
	IF  ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;	 
	
    
	--MARCA QUE YA TERMINO EL COMPLEMENTO 1 PARA PODER INICIAR EL PROCESO DE PARAM 
    UPDATE sc_contproc
    SET    fecha   =  v_fecha_ant
    WHERE  proceso = "idencobcom4";
	
		
	---MIENTRAS LA BANDERA SEA 0 VA A SEGUIR ESPERANDO.
	WHILE  vinicio_proceso = 0
           SET ISOLATION TO DIRTY READ;
           SELECT COUNT(*)
           INTO   vinicio_proceso
           FROM   sc_contproc
           WHERE  empresa = p_empresa
           AND    proceso = 'ini_iden_cob_com'
           AND    fecha = v_fecha_ant;
    END WHILE;
	
		   			
    SELECT valor
	INTO   v_fecha_movhisold
	FROM   sc_param 
	WHERE  codparam = "FechIniCon_movhis_ol";
	
	SELECT valor
	INTO   v_fecha_movhis
	FROM   sc_param 
	WHERE  codparam = "fechcon_movhis";
	
			
	 -- // OBTIENE VALORES PARA RANGO DE SERIALES A PROCESAR
    SELECT valor
      INTO vcliente_min
      FROM sc_param
     WHERE empresa = p_empresa
       AND codparam = 'CteIniCobComComp4';
	   
	
    FOREACH WITH HOLD
	
	        SELECT cliente 
			INTO   v_num_cte_cargo
			FROM   sc_cliente_si_cargo
			WHERE  cliente >= vcliente_min
			
			-- Abre la transaccion 
		    IF  (v_c_vcomienza_c2    = -1) THEN
                LET v_c_vcomienza_c2 = 0;
                LET ven_transacc_c2  = 1;
                BEGIN WORK;
            END IF;
			
            SELECT COUNT(*) 
			INTO   v_valida_inv_cre      --------- INVERSION  1
			FROM   sc_maechq 
			WHERE  producto = '1100'
			AND    num_cte  = v_num_cte_cargo      
			AND    status_cta = '1';
			   			   
			IF  v_valida_inv_cre = 0 THEN 
			    SELECT COUNT(*) 
				INTO   v_valida_pagare    --------- PAGARE  2
				FROM   bdinvers:sv_maeinv
				WHERE  cod_instrum = '3000'
				AND    num_cte     = v_num_cte_cargo 
				AND    status_cta  = '1'; 
				
				IF  v_valida_pagare =  0 THEN 
				    LET vcontador1   = 0;
					LET vcontador2   = 0;
					LET vportamovtot = 0;
					---TRUNCATE TABLE tmp_portab_dts;

					FOREACH WITH HOLD    ----------- PORTABILIDAD DE NOMINA 3
					    SELECT cuenta,    saldo_prom
						INTO   v_cta_mov, v_sdo_prom_car
						FROM   sc_ctas_total
						WHERE  cliente = v_num_cte_cargo
						
						INSERT INTO tmp_portab_dts4 VALUES (v_num_cte_cargo,v_cta_mov,"",v_sdo_prom_car );

				        IF  v_fecha_ini >= v_fecha_movhis THEN
                            SELECT COUNT(*) 
			                INTO   vporta_mov
			                FROM   bdicheq:sc_movhis 
				            WHERE  empresa  = p_empresa
			                AND    cuenta   = v_cta_mov
			                AND    fech_alt BETWEEN v_fecha_ini AND v_fecha_fin
				            AND    cancelad <> 'S'
                            AND    transacc = "0273"
                            AND    referencia LIKE "%NNNN%"; 

							LET vcontador1 = vcontador1 + vporta_mov; 
							LET vporta_mov = 0;
					    ELSE 
					        SELECT COUNT(*) 
			                INTO   vporta_mov
			                FROM   bdicheq:sc_movhis
				            WHERE  empresa  = p_empresa
			                AND    cuenta   = v_cta_mov
			                AND    fech_alt BETWEEN v_fecha_ini AND v_fecha_fin
				            AND    cancelad <> 'S'
                            AND    transacc = "0273"
                            AND    referencia LIKE "%NNNN%";
					        
					        SELECT COUNT(*) 
			                INTO   vporta_mov_old
			                FROM   bdicheq:sc_movhis_old
				            WHERE  empresa  = p_empresa
			                AND    cuenta   = v_cta_mov
			                AND    fech_alt BETWEEN v_fecha_ini AND v_fecha_fin
				            AND    cancelad <> 'S'
                            AND    transacc = "0273"
                            AND    referencia LIKE "%NNNN%";
							
							LET vcontador2 = vcontador2 + vporta_mov + vporta_mov_old;
							LET vporta_mov = 0;
							LET vporta_mov_old = 0;
					    END IF; 
				    END FOREACH;
					LET vportamovtot = vcontador1 + vcontador2; 
					
					IF vportamovtot = 0 THEN     
					   INSERT INTO sc_ctas_sin_movimientos
					   SELECT * FROM tmp_portab_dts4;
					   
					   DELETE FROM tmp_portab_dts4
					   WHERE cliente = v_num_cte_cargo;
					ELSE 
					   DELETE FROM tmp_portab_dts4
					   WHERE cliente = v_num_cte_cargo;
				    END IF;
			    END IF; 
		    END IF;
			
			LET v_c_vcontador_c2 = v_c_vcontador_c2 + 1;
			--Realiza commit cada 500 registros 
			IF (v_c_vcontador_c2 >= 500) THEN
               LET v_c_vcontador_c2 = 0;
               COMMIT WORK;
               BEGIN WORK;
            END IF; 
	END FOREACH;
	
		--Si la transaccion esta abierta realiza el commit
	IF  ven_transacc_c2     = 1 THEN
        LET ven_transacc_c2 = 0;
        COMMIT WORK;
    END IF;	
	
	--ACTUALIZA LA BANDERA DE FIN DE PROCESO COMPLEMENTO 4
	UPDATE sc_contproc
    SET    fecha   = v_fecha_ant
    WHERE  empresa = p_empresa
    AND    proceso = 'cobcomcomp4';	
	
RETURN  vcodret;
END; 
END PROCEDURE;