CREATE PROCEDURE "informix".sp_cobra_comision_cap(p_empresa char(3))
    RETURNING   CHAR(5);
    
    DEFINE v_c_vcomienza    SMALLINT;
	DEFINE v_c_vcomienza_c2 SMALLINT;
    DEFINE ven_transacc     SMALLINT;
	DEFINE ven_transacc_c2  SMALLINT;
    DEFINE v_c_vcontador    INTEGER;
	DEFINE v_c_vcontador_c2 INTEGER;	
    DEFINE vsqlerr          INTEGER;
    DEFINE iIsamErr         SMALLINT;
    DEFINE cErrorInfo       CHAR(80);
	DEFINE vErrorInfo       CHAR(80);
    DEFINE vcodret          CHAR(5);
    DEFINE vsql             CHAR(500);
	DEFINE v_fecha_ini      DATE; 
	DEFINE v_fecha_fin      DATE;
	DEFINE v_fecha_aniomes  DATE; 
	DEFINE v_num_cte        CHAR(20);
	DEFINE v_num_cte_cargo  CHAR(20);
	DEFINE v_cuenta         CHAR(20);
	DEFINE v_producto       CHAR(4);
	DEFINE v_aniomes        CHAR(6);
	DEFINE v_sdo_prom       MONEY (14,2);
	DEFINE v_val_tbl_ctas_total   INTEGER;
	DEFINE v_val_tbl_ctas_sin_mov INTEGER;
	DEFINE v_val_tbl_ctas_serv    INTEGER;
	DEFINE v_valida_inv_cre  INTEGER;
	DEFINE v_valida_pagare   INTEGER;
	DEFINE v_cta_mov         CHAR(20);
	DEFINE v_fecha_movhis    DATE;
	DEFINE v_fecha_movhisold DATE;
	DEFINE v_sdo_prom_car    MONEY (14,2);
    DEFINE v_codretparam     CHAR(5);
	DEFINE v_fecha_ant       DATE;
	DEFINE vcliente_max      CHAR(20);
	DEFINE vprocesocomp1     SMALLINT;
    DEFINE vprocesocomp2     SMALLINT;
	DEFINE vprocesocomp3     SMALLINT;
    DEFINE vprocesocomp4     SMALLINT;
	DEFINE vporta_mov        INTEGER;
	DEFINE vporta_mov_old    INTEGER;
	DEFINE vportamovtot      INTEGER;
	DEFINE vprimerdiames     DATE;
	DEFINE vprocecomp1  SMALLINT;
    DEFINE vprocecomp2  SMALLINT;
	DEFINE vprocecomp3  SMALLINT;
    DEFINE vprocecomp4  SMALLINT;
	DEFINE vprocecomp5  SMALLINT;
	DEFINE vcontador1   INTEGER;
	DEFINE vcontador2   INTEGER;
	
    LET v_c_vcomienza    = -1;	
	LET v_c_vcomienza_c2 = -1;
    LET ven_transacc     = 0;
	LET ven_transacc_c2  = 0;
    LET v_c_vcontador    = 0;
	LET v_c_vcontador_c2 = 0;
    LET vsqlerr          = 0; 
    LET iIsamErr         = 0;
    LET cErrorInfo       = "";   
    LET vcodret          = "00000";
    LET vsql             = '';
	LET vErrorInfo       = "INICIO DEL PROCESO";
	LET v_codretparam    = '';
	LET vprocesocomp1    = 0;
    LET vprocesocomp2    = 0;
	LET vprocesocomp3    = 0;
    LET vprocesocomp4    = 0;
	LET v_num_cte        = "";  
	LET v_num_cte_cargo  = "";  
	LET v_cta_mov        = "";
	LET vporta_mov       = 0;
	LET vporta_mov_old   = 0;
	LET vportamovtot     = 0;
	LET vprimerdiames    = "";
	LET v_sdo_prom_car   = 0;
	LET vprocecomp1      = 0;
    LET vprocecomp2      = 0;
	LET vprocecomp3      = 0;
    LET vprocecomp4      = 0;
    LET vprocecomp5      = 0;
	LET vcontador1       = 0;
    LET vcontador2       = 0;
	

    BEGIN
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	    IF  vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cobra_comision_cap.err";
	 	    TRACE ON;
			LET vcodret    = vsqlerr;
            LET vErrorInfo = cErrorInfo;
			LET v_num_cte  = v_num_cte;
            LET v_num_cte_cargo = v_num_cte_cargo;
            LET v_cta_mov  = v_cta_mov;
            IF ven_transacc = 1 OR ven_transacc_c2 = 1  THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodRet;
        END IF;
    END EXCEPTION;
	
	--SET   DEBUG FILE TO '/ifxsif01/rsv/comisionfull/comision.txt';
    --TRACE ON;
	
   	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;   
		
	
	SELECT DATE(pri_dia_mes - 1 UNITS MONTH), DATE(pri_dia_mes - 1  UNITS DAY), DATE(fecha_hoy - 1 UNITS MONTH), fecha_ant  , pri_dia_mes               
	INTO   v_fecha_ini,                       v_fecha_fin,                      v_fecha_aniomes,                 v_fecha_ant, vprimerdiames
	FROM   sc_fechas
	WHERE  empresa = "001";
		
	LET v_aniomes = TO_CHAR(v_fecha_aniomes,'%Y%m');
	
	--SE INICIALIZA LA TABLA QUE TIENE LOS NIVELES DEL PROCESO
	TRUNCATE TABLE sc_contproc_com;
		
    SELECT COUNT(*) 
	INTO   v_val_tbl_ctas_total
	FROM   sysmaster:systabnames 
    WHERE  partnum > 0 
	AND    tabname = 'sc_ctas_total';
	   
	--INICIALIZA LA TABLA 	   
	IF v_val_tbl_ctas_total > 0 THEN 
	   TRUNCATE TABLE sc_ctas_total;
	END IF; 
	
    -- // SE TRUCO LA TABLA sc_ctas_total SE LIBERAR LA BANDERA PARA QUE LOS COMPLEMENTOS LA PUEDAN UTILIZAR
    UPDATE sc_contproc
	SET    fecha   = v_fecha_ant
    WHERE  empresa = p_empresa
    AND    proceso = 'ini_complents';
		
		
	SELECT COUNT(*) 
	INTO   v_val_tbl_ctas_sin_mov
	FROM   sysmaster:systabnames 
    WHERE  partnum > 0 
	AND    tabname = 'sc_ctas_sin_movimientos';
	   
	--INICIALIZA LA TABLA 	   
	IF v_val_tbl_ctas_sin_mov > 0 THEN 
	   TRUNCATE TABLE sc_ctas_sin_movimientos;
	END IF; 
		
    SELECT valor
	INTO   v_fecha_movhisold
	FROM   sc_param 
	WHERE  codparam = "FechIniCon_movhis_ol";
	
	SELECT valor
	INTO   v_fecha_movhis
	FROM   sc_param 
	WHERE  codparam = "fechcon_movhis";
	
    --TABLA TEMPORAL UTILIZADA PARA LAS CUENTAS DE PORTABILIDAD
    CREATE TEMP TABLE tmp_portab_dts (
	cliente      CHAR(20),
	cuenta       CHAR(20),
	num_tarjeta  CHAR(20),
	saldo_promedio MONEY (14,2));
	
   	--SE OBTIENE EL SALDO PROMEDIO DE LAS CUENTAS RELACIONDAS CON EL PRODUCTO CONSIDERADO
	FOREACH WITH HOLD
	
            SELECT a.num_cte, a.cuenta, a.producto
		    INTO   v_num_cte, v_cuenta, v_producto
		    FROM   sc_maechq AS a,
                   sc_maenoc AS b 
            WHERE  a.cuenta     = b.cuenta  
		    AND    a.status_cta IN ('1','3','4','5')
			AND    a.producto   IN("1900","2400","2500")
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
    WHERE  proceso = "idencobcom";
	
	--ESPERA MIENTRAS TERMINAN TODOS LOS COMPLEMENTOS DE OBTENER EL SALDO PROMEDIO DE LAS CUENTAS RELACIONADAS A LOS PRODUCTOS	
	WHILE ( vprocecomp1 = 0 OR vprocecomp2 = 0 OR vprocecomp3 = 0 OR vprocecomp4 = 0 OR vprocecomp5 = 0 )
        SET ISOLATION TO DIRTY READ;
        SELECT COUNT(*)
        INTO   vprocecomp1
        FROM   sc_contproc
        WHERE  empresa = p_empresa
        AND    proceso = 'idencobcom'
        AND    fecha = v_fecha_ant;
          
        SELECT COUNT(*)
        INTO   vprocecomp2
        FROM   sc_contproc
        WHERE  empresa = p_empresa
        AND    proceso = 'idencobcom1'
        AND    fecha = v_fecha_ant;
		   
		SELECT COUNT(*)
        INTO   vprocecomp3
        FROM   sc_contproc
        WHERE  empresa = p_empresa
        AND    proceso = 'idencobcom2'
        AND    fecha = v_fecha_ant;
		   
		SELECT COUNT(*)
        INTO   vprocecomp4
        FROM   sc_contproc
        WHERE  empresa = p_empresa
        AND    proceso = 'idencobcom3'
        AND    fecha = v_fecha_ant;
		   
		   
		SELECT COUNT(*)
        INTO   vprocecomp5
        FROM   sc_contproc
        WHERE  empresa = p_empresa
        AND    proceso = 'idencobcom4'
        AND    fecha = v_fecha_ant;
		   		   
    END WHILE;
	
	--SE ABANDERA lA ETAPA 1, TODOS LOS COMPLEMENTOS TERMINARON DE INDETIFICAR CUENTAS
	INSERT INTO sc_contproc_com VALUES (vprimerdiames,"1","F",CURRENT HOUR TO SECOND);
	
	--EJECUTA EL PROCESO QUE REPARTE LAS CUENTAS A PROCESAR 	
	EXECUTE PROCEDURE "informix".sp_cobra_comision_param(p_empresa)
	INTO v_codretparam;
	
	IF v_codretparam <> '000' THEN 
	   LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA LOS RANGOS';
       LET vcodret = '975';
	   RETURN vcodret;
	ELSE 
	--SE ABANDERA LA ETAPA 2, EL PROCESO QUE SE ENCARGA DE REPARTIR LAS CUENTAS TERMINO EN OK 
    INSERT INTO sc_contproc_com VALUES (vprimerdiames,"2","F",CURRENT HOUR TO SECOND);
    END IF;
	
	-- // ACTUALIZA BANDERA DE INICIO DE PROCESO PARA COMENZAR A BUSCAR MOVIMIENTOS DE CUENTAS EN TODOS LOS COMPLEMENTOS 
    UPDATE sc_contproc
    SET    fecha   = v_fecha_ant
    WHERE  empresa = p_empresa
    AND    proceso = 'ini_iden_cob_com';
	
		 -- // OBTIENE VALORES PARA RANGO DE CUENTAS  A PROCESAR
    SELECT valor
    INTO   vcliente_max
    FROM   sc_param
    WHERE  empresa = p_empresa
    AND    codparam = 'CteIniCobComComp1';
	
	
    FOREACH WITH HOLD
	        SELECT cliente 
			INTO   v_num_cte_cargo
			FROM   sc_cliente_si_cargo
			WHERE  cliente < vcliente_max
			
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
						
						INSERT INTO tmp_portab_dts VALUES (v_num_cte_cargo,v_cta_mov,"",v_sdo_prom_car );
						
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
					   SELECT * FROM tmp_portab_dts;
					   
					   DELETE FROM tmp_portab_dts
					   WHERE cliente = v_num_cte_cargo;
					ELSE 
					   DELETE FROM tmp_portab_dts
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
	
    --SI LA TRANSACCION ESTA ABIERTA REALIZA EL COMMIT
	IF  ven_transacc_c2     = 1 THEN
        LET ven_transacc_c2 = 0;
        COMMIT WORK;
    END IF;	
	
	
	--SE ESPERA A QUE TODOS LOS COMPLEMENTOS TERMINEN PARA GENERAR LA BANDERA DE FIN DE PROCESO GENERAL 
	WHILE ( vprocesocomp1 = 0 OR vprocesocomp2 = 0 OR vprocesocomp3 = 0 OR vprocesocomp4 = 0 )
        SET ISOLATION TO DIRTY READ;
        SELECT COUNT(*)
        INTO   vprocesocomp1
        FROM   sc_contproc
        WHERE  empresa = p_empresa
        AND    proceso = 'cobcomcomp1'
        AND    fecha = v_fecha_ant;
          
        SELECT COUNT(*)
        INTO   vprocesocomp2
        FROM   sc_contproc
        WHERE  empresa = p_empresa
        AND    proceso = 'cobcomcomp2'
        AND    fecha = v_fecha_ant;
		   
		SELECT COUNT(*)
        INTO   vprocesocomp3
        FROM   sc_contproc
        WHERE  empresa = p_empresa
        AND    proceso = 'cobcomcomp3'
        AND    fecha = v_fecha_ant;
		   
		SELECT COUNT(*)
        INTO   vprocesocomp4
        FROM   sc_contproc
        WHERE  empresa = p_empresa
        AND    proceso = 'cobcomcomp4'
        AND    fecha = v_fecha_ant;	   		   
    END WHILE;
	
	--SE ABANDERA EL PROCESO 3, TODOS LOS PROCESOS TERMINARON DE FORMA EXITOSA DE BUSCAR MOVIMIENTOS DE CUENTAS 
    INSERT INTO sc_contproc_com VALUES (vprimerdiames,"3","F",CURRENT HOUR TO SECOND);	
	
RETURN  vcodret;
END; 
END PROCEDURE;