CREATE PROCEDURE "informix".spsldecanual(pFechaProceso 	    DATE,
									     pUsuario 		    VARCHAR(8), 
									     pTipoDecl  		CHAR(1),
									     pFechaPresentacion DATE, 
									     pNumFolio 		    VARCHAR(16))
										  			  		  
RETURNING VARCHAR(5), VARCHAR (80);

    -- ********************************************************************************************************************************
    -- Creado por Fabiola Corrales Tapia 19/MAY/2007 	                        
    -- Modificó: Anselmo Verdugo			
    -- Actividad: Hace el llenado a las tablas para la generación del archivo XML anual.
    -- Solicitó: Aymme Osuna 			
    -- Fecha: 05/SEP/2008 			
    -- Modificó: Marcos Cuevas			
    -- Actividad: Se elimina la validacion que indicaba si el monto del movimiento era mayor o igual al monto minimo y se optimiza.
    -- Fecha: 16/04/2010 				
    -- ********************************************************************************************************************************
    DEFINE v_scodret 	VARCHAR(5);
    DEFINE v_smensaje 	VARCHAR(80);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE error_info   VARCHAR(40);
    DEFINE v_sstatus    CHAR(1);
    DEFINE v_sstatusmen	CHAR(1);
    DEFINE v_ianio		INTEGER;
    DEFINE v_saniomes	VARCHAR(6);
    DEFINE v_smesenero	VARCHAR(6);
    DEFINE v_dfecha_hoy	DATE;
    DEFINE viNumComple  INTEGER;
	--DSB 20/01/2020--
	DEFINE vTable1      VARCHAR(70);
	DEFINE vAnioMes     VARCHAR(6);
	--DSB 20/01/2020--
   
    LET v_scodret    = '00001';
    LET v_smensaje   = 'EL REPORTE SE GENERO CON ERRORES, NO GENERAR XML';
    LET sql_err      = 0;
    LET isam_err     = 0;
    LET error_info   = 0;
	LET v_sstatus    = '';
	LET v_sstatusmen = '';
    LET v_ianio      = YEAR(pFechaProceso);
    LET v_saniomes   = v_ianio || '13'; --LPAD(v_imes,2,0); --
    LET v_smesenero  = v_ianio || '01';
    LET v_dfecha_hoy = CURRENT::DATE;
    LET viNumComple  = 0;
	--DSB 20/01/2020--
	LET vTable1      = '';
	LET vAnioMes     = '';	
	--DSB 20/01/2020--
	
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
		LET v_scodret = sql_err;
		LET v_smensaje = sql_err||" * "||isam_err|| " * "||error_info|| v_smensaje;
		
		--DSB 20/01/2020 INICIO
		LET vTable1 = '';
		SELECT tabname INTO vTable1 FROM bdilide:"informix".systables WHERE tabname = 'tmp_insertadatoslidecte';
		IF dbinfo("sqlca.sqlerrd2") = 1 THEN
			TRUNCATE TABLE bdilide:"informix".tmp_insertadatoslidecte;
		END IF;
		
		LET vTable1 = '';
		
		SELECT tabname INTO vTable1 FROM bdilide:"informix".systables WHERE tabname = 'tmp_paso_datos_anualxml';
		IF dbinfo("sqlca.sqlerrd2") = 1 THEN
			TRUNCATE TABLE bdilide:"informix".tmp_paso_datos_anualxml;
		END IF;
		--DSB 20/01/2020 FIN
			   
		RETURN v_scodret, v_smensaje;
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/resplogifx/conciliachq/IDE/spsldecanual.out";
	--SET DEBUG FILE TO "/tmp/JoseLuisPolancko0/spsldecanual.out";
    --TRACE ON;  

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--DSB 20/01/2020 INICIO
	LET vTable1 = '';
	SELECT tabname INTO vTable1 FROM bdilide:"informix".systables WHERE tabname = 'tmp_insertadatoslidecte';
	IF dbinfo("sqlca.sqlerrd2") = 1 THEN
		TRUNCATE TABLE bdilide:"informix".tmp_insertadatoslidecte;
	END IF;

	LET vTable1 = '';
	
	SELECT tabname INTO vTable1 FROM bdilide:"informix".systables WHERE tabname = 'tmp_paso_datos_anualxml';
	IF dbinfo("sqlca.sqlerrd2") = 1 THEN
		TRUNCATE TABLE bdilide:"informix".tmp_paso_datos_anualxml;
	END IF;	
	
    -- // SI EL TIPO DE DECLARACIÓN ES COMPLEMENTARIA ENTONCES SE OBTIENE EL NÚMERO DE FOLIO.
    --UPDATE STATISTICS MEDIUM FOR TABLE bdilide:"informix".sl_anualxml;					
    --UPDATE STATISTICS MEDIUM FOR TABLE bdilide:"informix".sl_ctas;					
	--UPDATE STATISTICS MEDIUM FOR TABLE bdilide:"informix".sl_detlide;
	--UPDATE STATISTICS MEDIUM FOR TABLE bdilide:"informix".sl_retlide;		
    --DSB 20/01/2020 FIN
	
    IF pTipoDecl = 'C' THEN
        /*IF NOT EXISTS (SELECT aniomes 
                         FROM bdilide:"informix".sl_declinfor 
                        WHERE aniomes = v_saniomes 
                          AND normal = 'N' 
                          AND no_compl = '0' ) THEN*/ --DSB 20/01/2020
	
		SELECT {+INDEX(bdilide:"informix".sl_declinfor 115_105)} --DSB 20/01/2020 INICIO
			   aniomes
		INTO vAnioMes
		FROM bdilide:"informix".sl_declinfor 
		WHERE aniomes = v_saniomes 
		AND normal = 'N' 
		AND no_compl = '0';
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN --DSB 20/01/2020 INICIO
			LET v_scodret = '00007';
			LET v_smensaje = 'No se puede generar Declaración complementaria sin hacer primero la Normal';
			RETURN v_scodret, v_smensaje;
        END IF;

		SELECT {+INDEX(bdilide:"informix".sl_declinfor 115_105)} --DSB 20/01/2020 INICIO
				NVL(MAX(no_compl),0) + 1 
		INTO viNumComple 
		FROM bdilide:"informix".sl_declinfor 
		WHERE aniomes = v_saniomes 
		AND normal = 'C';
		
    ELSE
        LET pFechaPresentacion = '';
        LET pNumFolio = '';
    END IF;

    IF viNumComple > 9 THEN
        LET v_scodret = '00006';
        LET v_smensaje = 'Se han generado el número de  Declaracines informativas complementarias permitidas';
        RETURN v_scodret, v_smensaje;
    END IF;
	
	-- // Valida que se haya echo la declaracion mensual del ultimo mes del año a generar
	-->> 1 row(s)
	SELECT {+INDEX(bdilide:"informix".sl_procesos 109_70)} --DSB 20/01/2020 INICIO
		   status 
	INTO v_sstatusmen 
	FROM bdilide:"informix".sl_procesos 
	WHERE proceso = 'decmensual' 
	AND fech_proceso = pFechaProceso;
	 
	--DSB 20/01/2020 INICIO
	/*DELETE bdilide:"informix".sl_ctas 
	WHERE num_cte is not null
	AND num_cta is not null
	AND fechaxml = v_saniomes;
     
	DELETE bdilide:"informix".sl_movctas 
	WHERE keyx > 0 
	AND fechaxml = v_saniomes;*/
	
	TRUNCATE TABLE bdilide:"informix".sl_ctas;
	TRUNCATE TABLE bdilide:"informix".sl_movctas;
	--DSB 20/01/2020 FIN

    IF v_sstatusmen IS NOT NULL OR v_sstatusmen <> 0 THEN
        -- // Valida que el proceso de la declaración anual haya sido generado
		-->> 1 row(s)
		SELECT {+INDEX(bdilide:"informix".sl_procesos 109_70)} --DSB 20/01/2020 INICIO
			   status 
		INTO v_sstatus 
		FROM bdilide:"informix".sl_procesos 
		WHERE proceso = 'decanual' 
		AND fech_proceso = pFechaProceso;
			  
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN --DSB 20/01/2020 INICIO
            INSERT INTO bdilide:"informix".sl_procesos (proceso, fech_proceso, status, user_insert, fecha_insert)
            VALUES ('decanual', pFechaProceso, '0', pUsuario, v_dfecha_hoy);
        ELSE
			--DSB 20/01/2020 INICIO
			/*DELETE bdilide:"informix".sl_anualxml 
			WHERE num_cte is not null
			AND fechaxml = v_saniomes;*/

			TRUNCATE TABLE bdilide:"informix".sl_anualxml;
			--DSB 20/01/2020 FIN

			DELETE bdilide:"informix".sl_declinfor 
			WHERE aniomes = v_saniomes 
			AND normal = pTipoDecl 
			AND no_compl = viNumComple;
               
            IF v_sstatus = "1" THEN
				UPDATE bdilide:"informix".sl_procesos 
				--SET status = 0, fecha_insert = CURRENT::DATE --DSB 20/01/2020
				SET status = 0, fecha_insert = v_dfecha_hoy
				WHERE proceso = 'decanual' 
				AND fech_proceso = pFechaProceso;
            END IF				
        END IF
    ELSE
        LET v_scodret = '00001';
        LET v_smensaje = 'EL REPORTE DE LA DECLARACION MENSUAL DE DICIEMBRE NO SE HA GENERADO';
		
        RETURN v_scodret, v_smensaje;
    END IF	
	
														--DSB 20/01/2020 INICIO
	LET vTable1 = '';	
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	--SE ELIMINAN INDEX DE idx_tmp_cte 
	SELECT idxname INTO vTable1 FROM sysindices WHERE IDXNAME = 'idx_tmp_cte';
	IF dbinfo("sqlca.sqlerrd2") = 1 THEN
		DROP INDEX bdilide:"informix".idx_tmp_cte;
	END IF;	
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	-->> 757,292 row(s)
	INSERT INTO bdilide:"informix".tmp_paso_datos_anualxml
	SELECT {+INDEX(bdilide:"informix".sl_menxml 116_375)}  
		   num_cte, MAX(fechaxml) AS fechamax,
		   SUM(NVL(ROUND(montoexcedente,0),0)) AS montoexcedente, SUM(NVL(ROUND(impdeterminado,0),0)) AS impdeterminado, 
		   SUM(NVL(ROUND(imprecaudado,0),0)) AS imprecaudado, SUM(NVL(ROUND(recpendiente,0),0)) AS recpendiente, 
		   v_saniomes AS fechaxml
	FROM bdilide:"informix".sl_menxml
	WHERE fechaxml >= v_smesenero
	AND fechaxml < v_saniomes
	GROUP BY num_cte;
	
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	--CREACION DE INDEX EN TABLA "tmp_paso_datos_anualxml"
	LET vTable1 = '';
	SELECT idxname INTO vTable1 FROM sysindices WHERE IDXNAME = 'idx_tmp_cte';
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		BEGIN;
		CREATE INDEX bdilide:"informix".idx_tmp_cte
		ON bdilide:"informix".tmp_paso_datos_anualxml(num_cte);
		COMMIT;
	END IF;
	
	UPDATE STATISTICS MEDIUM FOR TABLE bdilide:"informix".tmp_paso_datos_anualxml;
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	--SE ELIMINAN INDEX DE idx_anualxml , idx_anualxml02
	LET vTable1 = '';
	SELECT idxname INTO vTable1 FROM sysindices WHERE IDXNAME = 'idx_anualxml';
	IF dbinfo("sqlca.sqlerrd2") = 1 THEN
		DROP INDEX bdilide:"informix".idx_anualxml;
	END IF;
	
	LET vTable1 = '';
	
	SELECT idxname INTO vTable1 FROM sysindices WHERE IDXNAME = 'idx_anualxml02';
	IF dbinfo("sqlca.sqlerrd2") = 1 THEN
		DROP INDEX bdilide:"informix".idx_anualxml02;
	END IF;	
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	-->> 754,195 row(s)
	INSERT INTO bdilide:"informix".sl_anualxml
	SELECT {+AVOID_FULL(bdilide:sl_menxml),+INDEX(bdilide:"informix".tmp_paso_datos_anualxml idx_tmp_cte)}
		   
		   anualxml.num_cte, a.tpo_persona, a.rfc, a.curp, a.razon_soc, a.apell_pat, a.apell_mat, 
	       a.nombre1, a.nombre2, c.nombrecalle AS nombrecalle,d.numerointcalle AS numerointcalle, 
	       d.numeroextcalle AS numeroextcalle, z.nombrezona AS nombrezona, d.cod_postal AS cod_postal, 
	       anualxml.montoexcedente, anualxml.impdeterminado, anualxml.imprecaudado, anualxml.recpendiente, 
	       anualxml.fechaxml
	FROM bdilide:"informix".tmp_paso_datos_anualxml AS anualxml,
		 bdinteg:"informix".si_direcciones_actual d,
		 bdinteg:"informix".si_catcalles c,
		 bdinteg:"informix".si_catzonas z,
		 bdilide:"informix".sl_menxml a
	WHERE anualxml.num_cte = d.numcte
	AND  d.numcte = anualxml.num_cte
	AND d.tipo_dir = 1
	AND d.numerocalle = c.numerocalle
	AND d.numerociudad = z.numerociudad 
	AND d.numerocolonia = z.numerocolonia
	AND a.num_cte = anualxml.num_cte
	AND a.fechaxml = anualxml.fechamax;	
	
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	--SE ELIMINAN INDEX idx_tmp_lidecte
	LET vTable1 = '';
	SELECT idxname INTO vTable1 FROM sysindices WHERE IDXNAME = 'idx_tmp_lidecte';
	IF dbinfo("sqlca.sqlerrd2") = 1 THEN
		DROP INDEX bdilide:"informix".idx_tmp_lidecte;
	END IF;
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	------------Q U E R Y S   P A R A   O B T E N E R    M O V I M I E N T O S   D E   C U E N T A S   D E   L O S   C L I E N T E S------------
	
	-->> 0 row(s)
	INSERT INTO bdilide:"informix".tmp_insertadatoslidecte
	SELECT {+INDEX(bdilide:"informix".tmp_paso_datos_anualxml idx_tmp_cte)}  
		   a.num_credito AS cuenta, a.numcte AS numcte,b.fecha_ret AS fecha, NVL(ROUND(b.imp_recaudado,0),0) AS importe, '02' AS tipo
	FROM   bdilide:"informix".sl_detlide b,
		   bdilide:"informix".tmp_paso_datos_anualxml c,
		   bdicred:"informix".sd_maecred a
	WHERE b.aniomes >= v_smesenero  
    AND b.aniomes  < v_saniomes
    AND b.num_cte = c.num_cte
    AND b.cuenta_ret = a.num_credito
    AND c.num_cte = b.num_cte
    AND a.numcte = c.num_cte
    AND a.num_credito = b.cuenta_ret
    AND a.empresa = '001';
	----------------------------------------------------------------------------------------------------------------------------------------
	
	-->> 110,690 row(s)
	INSERT INTO bdilide:"informix".tmp_insertadatoslidecte
	SELECT {+INDEX(bdilide:"informix".tmp_paso_datos_anualxml idx_tmp_cte)}
	      a.num_credito AS cuenta, a.numcte AS numcte , b.fecha_mov AS fecha, NVL(ROUND(b.imp_tot_dep,0),0) AS importe, '01' AS tipo
    FROM  bdilide:"informix".sl_movefec_his b,
	      bdilide:"informix".tmp_paso_datos_anualxml c,
	      bdicred:"informix".sd_maecred a		   
    WHERE b.aniomes >= v_smesenero  
    AND b.aniomes  < v_saniomes
    AND b.num_cte = c.num_cte
    AND b.num_serial IS NOT NULL
    AND c.num_cte = b.num_cte
    AND a.numcte = b.num_cte
    AND a.num_credito = b.num_cta
    AND a.empresa = '001'; 
	 
	----------------------------------------------------------------------------------------------------------------------------------------
	
	-->> 0 row(s)
	INSERT INTO bdilide:"informix".tmp_insertadatoslidecte
	SELECT {+INDEX(bdilide:"informix".tmp_paso_datos_anualxml idx_tmp_cte)}  
	       a.cuenta AS cuenta, a.num_cte AS numcte, b.fecha_ret AS fecha, NVL(ROUND(b.imp_recaudado,0),0) AS importe, '02' AS tipo
	FROM   bdilide:"informix".sl_detlide b,
	       bdilide:"informix".tmp_paso_datos_anualxml c,
	       bdicheq:"informix".sc_maechq a              
	WHERE b.aniomes >= v_smesenero  
	AND b.aniomes  < v_saniomes
	AND b.num_cte = c.num_cte
	AND b.cuenta_ret = a.cuenta
	AND c.num_cte = b.num_cte
	AND a.num_cte = c.num_cte
	AND a.cuenta = b.cuenta_ret
	AND a.empresa = '001';
	
	----------------------------------------------------------------------------------------------------------------------------------------
	
	-->> 24,350,339 row(s)
	INSERT INTO bdilide:"informix".tmp_insertadatoslidecte
	SELECT {+INDEX(bdilide:"informix".tmp_paso_datos_anualxml idx_tmp_cte)}
		   a.cuenta AS cuenta, a.num_cte AS numcte, b.fecha_mov AS fecha, NVL(ROUND(b.imp_tot_dep,0),0) AS importe, '01' AS tipo
	FROM   bdilide:"informix".sl_movefec_his b,
		   bdilide:"informix".tmp_paso_datos_anualxml c,
		   bdicheq:"informix".sc_maechq a               
	WHERE b.aniomes >= v_smesenero  
	AND b.aniomes  < v_saniomes
	AND b.num_cte = c.num_cte
	AND b.num_cta = a.cuenta
	AND b.num_serial IS NOT NULL
	AND c.num_cte = b.num_cte
	AND a.num_cte = c.num_cte
	AND a.cuenta = b.num_cta
	AND a.empresa = '001';
	
	------------Q U E R Y S   P A R A   O B T E N E R    M O V I M I E N T O S   D E   C U E N T A S   D E   L O S   C L I E N T E S------------
	
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	--CREACION DE INDEX EN TABLA "tmp_insertadatoslidecte"
	LET vTable1 = '';
	SELECT idxname INTO vTable1 FROM sysindices WHERE IDXNAME = 'idx_tmp_lidecte';
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		BEGIN;
		CREATE INDEX bdilide:"informix".idx_tmp_lidecte
		ON bdilide:"informix".tmp_insertadatoslidecte(cuenta,numcte);
		COMMIT;
	END IF;

	UPDATE STATISTICS MEDIUM FOR TABLE bdilide:"informix".tmp_insertadatoslidecte;
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	--SE ELIMINAN INDEX idx_sl_movctas , idx_sl_movctas01
	LET vTable1 = '';
	SELECT idxname INTO vTable1 FROM sysindices WHERE IDXNAME = 'idx_sl_movctas';
	IF dbinfo("sqlca.sqlerrd2") = 1 THEN
		DROP INDEX bdilide:"informix".idx_sl_movctas;
	END IF;
	
	LET vTable1 = '';
	
	SELECT idxname INTO vTable1 FROM sysindices WHERE IDXNAME = 'idx_sl_movctas01';
	IF dbinfo("sqlca.sqlerrd2") = 1 THEN
		DROP INDEX bdilide:"informix".idx_sl_movctas01;
	END IF;
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	-->> 24,461,029 row(s)
	INSERT INTO bdilide:"informix".sl_movctas
	SELECT {+INDEX(bdilide:"informix".tmp_insertadatoslidecte idx_tmp_lidecte)}
	       ROWID , numcte, cuenta, tipo, importe, fecha, v_saniomes
	FROM bdilide:"informix".tmp_insertadatoslidecte
	WHERE numcte > ''
	AND cuenta > '';
	 
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	--SE ELIMINAN INDEX idx_sl_ctas01
	LET vTable1 = '';
	SELECT idxname INTO vTable1 FROM sysindices WHERE IDXNAME = 'idx_sl_ctas01';
	IF dbinfo("sqlca.sqlerrd2") = 1 THEN
		DROP INDEX bdilide:"informix".idx_sl_ctas01;
	END IF;
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	-->> 850,044 row(s)
	INSERT INTO bdilide:"informix".sl_ctas (num_cta, num_cte, cotitulares, porcion, imprecaudado, fechaxml)
	SELECT {+INDEX(bdilide:"informix".tmp_insertadatoslidecte idx_tmp_lidecte)}
		  DISTINCT(TRIM(cuenta)), numcte,'0', '100.0000', SUM(importe) , v_saniomes
	FROM bdilide:"informix".tmp_insertadatoslidecte
	WHERE importe >= 1
	GROUP BY cuenta,numcte;
	
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	--CREACION DE INDEX "sl_anualxml"
	LET vTable1 = '';
	SELECT idxname INTO vTable1 FROM sysindices WHERE IDXNAME = 'idx_anualxml';
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		BEGIN;
		CREATE INDEX bdilide:"informix".idx_anualxml
		ON bdilide:"informix".sl_anualxml(fechaxml);
		COMMIT;
	END IF;
	
	LET vTable1 = '';
	
	SELECT idxname INTO vTable1 FROM sysindices WHERE IDXNAME = 'idx_anualxml02';
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		BEGIN;
		CREATE INDEX bdilide:"informix".idx_anualxml02
		ON bdilide:"informix".sl_anualxml(fechaxml,tpo_persona);
		COMMIT;
	END IF;
	
	UPDATE STATISTICS MEDIUM FOR TABLE bdilide:"informix".sl_anualxml;
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	-->> 1 row(s)
	INSERT INTO bdilide:"informix".sl_declinfor (aniomes, normal, no_compl, total_oper, total_depositos, 
	                                             total_ide, total_rec, total_pend, total_reman,total_entero,
												 fecha_genera, fecha_pres, no_folio_ant, pend_generar, user_insert, 
												 fecha_insert )
	SELECT {+INDEX(bdilide:"informix".sl_anualxml idx_anualxml)}
		 v_saniomes, pTipoDecl, viNumComple, COUNT(num_cte),SUM(ROUND(montoexcedente,0)),SUM(ROUND(impdeterminado,0)),
		 0, SUM(ROUND(impdeterminado,0)), 0, 0, pFechaProceso, pFechaPresentacion,pNumFolio, 'N', pUsuario, v_dfecha_hoy
	FROM bdilide:"informix".sl_anualxml
	WHERE fechaxml = v_saniomes; 
		   
	UPDATE bdilide:"informix".sl_procesos
	SET status = 1,  fecha_insert = v_dfecha_hoy 
	WHERE proceso = 'decanual' 
	AND fech_proceso = pFechaProceso;
	
	
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	--CREACION DE INDEX EN LA TABLA "sl_movctas"
	LET vTable1 = '';
	SELECT idxname INTO vTable1 FROM sysindices WHERE IDXNAME = 'idx_sl_movctas';
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		BEGIN;
		CREATE INDEX bdilide:"informix".idx_sl_movctas
		ON bdilide:"informix".sl_movctas(num_cte,num_cta,fechaxml);
		COMMIT;
	END IF;
	
	LET vTable1 = '';
	
	SELECT idxname INTO vTable1 FROM sysindices WHERE IDXNAME = 'idx_sl_movctas01';
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		BEGIN;
		CREATE INDEX bdilide:"informix".idx_sl_movctas01
		ON bdilide:"informix".sl_movctas(num_cte,keyx,fechaxml);
		COMMIT;
	END IF;

	UPDATE STATISTICS MEDIUM FOR TABLE bdilide:"informix".sl_movctas;
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	--CREACION DE INDEX EN LA TABLA "sl_ctas"
	LET vTable1 = '';
	SELECT idxname INTO vTable1 FROM sysindices WHERE IDXNAME = 'idx_sl_ctas01';
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		BEGIN;
		CREATE INDEX bdilide:"informix".idx_sl_ctas01
		ON bdilide:"informix".sl_ctas(num_cte,fechaxml);
		COMMIT;
	END IF;

	UPDATE STATISTICS MEDIUM FOR TABLE bdilide:"informix".sl_ctas;
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	LET v_scodret = '00000';
    LET v_smensaje = 'REPORTE EXITOSO EL ARCHIVO XML PUEDE SER GENERADO';		

END		
    
	TRUNCATE TABLE tmp_insertadatoslidecte;
	TRUNCATE TABLE tmp_paso_datos_anualxml;
	
	
																--DSB 20/01/2020 FIN	
    RETURN v_scodret, v_smensaje;
    
END PROCEDURE

