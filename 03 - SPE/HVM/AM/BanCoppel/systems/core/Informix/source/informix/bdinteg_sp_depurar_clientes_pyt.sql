CREATE PROCEDURE "informix".sp_depurar_clientes_pyt()
RETURNING INTEGER AS rSqlErr, INTEGER AS IsamErr, CHAR(255) AS DescErr ;

    DEFINE dfecha_inicio DATETIME YEAR TO FRACTION(5);
    DEFINE dfecha_fin DATETIME YEAR TO FRACTION(5);
    DEFINE id_control INT;
    DEFINE contador INT;
    DEFINE secuencia_borrar INT;
	DEFINE total_a_borrar INT;
    DEFINE itotal_borrados INT;
	DEFINE bEnTransaccion BOOLEAN;
	
	--DEFINE rSqlErr CHAR(5);
    --DEFINE DescErr CHAR(255);
	
	DEFINE rSqlErr  			INTEGER;
	DEFINE iIsamErr 			INTEGER;
	DEFINE DescErr 				CHAR(255);
	
	LET rSqlErr	 = 0;
	LET iIsamErr = 0;
	LET DescErr = '';

    -- Inicializar variables
    LET contador = 0;
	LET total_a_borrar = 0;
    LET itotal_borrados = 0;
	LET bEnTransaccion = 'f';

	
BEGIN
	ON EXCEPTION 
		SET rSqlErr, iIsamErr, DescErr
		--SET DEBUG FILE TO "/tmp/pruebas_coordinacion/ambientacion_clientes/debug_log.txt";
		--TRACE ON;

		SET DEBUG FILE TO "/RESPALDOSNEW/prevfraudes/debug_log.txt";
		TRACE ON;
		
        --LET rSqlErr = SQLCODE;
        --LET DescErr = ERRMSG(rSqlErr);
        --ROLLBACK WORK;

        --UPDATE control_ejecucion_sp_depurar_clientes_pyt
        --   SET fecha_fin_ejecucion = CURRENT,
        --       codigo_error = rSqlErr,
        --       descripcion_error = DescErr,
        --       total_registros_borrados = itotal_borrados
        -- WHERE id_control = id_control;
		 
		UPDATE control_ejecucion_sp_depurar_clientes_pyt
		SET
			fecha_fin_ejecucion = CURRENT,
			status = 0,
			codigo_error = rSqlErr,
			descripcion_error = DescErr,
			total_registros_borrados = itotal_borrados
		WHERE id_control = id_control;
		
		--IF itotal_borrados = 0 THEN
        --    ROLLBACK WORK;
        --END IF;
		
		IF bEnTransaccion = 't' THEN
			ROLLBACK WORK;
			LET bEnTransaccion = 'f';
			--LET dFechaCargaini = 0;
			--LET dFechaCargafin = 0;
			--LET iFechaMax_Cargada = 0;
			--LET vreg_insertados = 0;
			
			--UPDATE control_ejecucion_sp_depurar_clientes_pyt
			--SET (fecha_fin_ejecucion, fecha_cargaini, fecha_cargafin, fechamax_cargada, reg_insertados, status_proc, cod_err, descripcion_err)
			--= (dFechaProcesofin, dFechaCargaini, dFechaCargafin, iFechaMax_Cargada, vreg_insertados, vstatus_proc, cCodRet1, cCodRet3)
			--where id_proceso = iId_proceso AND status_proc = '1';
		ELSE
			ROLLBACK WORK;
			LET bEnTransaccion = 'f';
			--INSERT INTO ctrl_info_insert_tde_sendmsgs_tar_hist (id_proceso,fecha_procesoIni, fecha_fin_ejecucion, nombre_proceso,
			--fecha_cargaini, fecha_cargafin, fechamax_cargada, reg_insertados, status_proc, cod_err, descripcion_err)
			--VALUES (iId_proceso,dFechaProcesoini, dFechaProcesofin, NVL(cProceso1,''), dFechaCargaini, dFechaCargafin, iFechaMax_Cargada,
			--		vreg_insertados, vstatus_proc,cCodRet1,cCodRet3);
		END IF

        --RETURN rSqlErr, DescErr;
		RETURN rSqlErr, iIsamErr, DescErr;
    END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/pruebas_coordinacion/ambientacion_clientes/debug_log.txt";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    -- Obtener el rango de fechas
    SELECT fecha_inicio, fecha_fin
      INTO dfecha_inicio, dfecha_fin
      FROM fechas_sp_depurar_clientes_pyt
     WHERE id_configuracion = 1;

    -- Validar que las fechas sean vÃ¡lidas
	IF dfecha_inicio IS NULL OR dfecha_fin IS NULL THEN
		LET rSqlErr = -0001;
		LET DescErr = 'Fechas no configuradas en tabla';
		--RETURN rSqlErr, DescErr;
		RETURN rSqlErr, iIsamErr, DescErr;
	END IF;

	IF dfecha_inicio > dfecha_fin THEN
		LET rSqlErr = -0002;
		LET DescErr = 'Rango de fechas invÃ¡lido';
		--RETURN rSqlErr, DescErr;
		RETURN rSqlErr, iIsamErr, DescErr;
	END IF;
	
	LET rSqlErr = 00001;
	LET DescErr = 'DepuraciÃ³n en ejecuciÃ³n';

	-- Insertar registro inicial en tabla de control
    INSERT INTO control_ejecucion_sp_depurar_clientes_pyt(
        fecha_inicio_ejecucion, fecha_inicio_periodo, fecha_fin_periodo, status, codigo_error, descripcion_error)
    VALUES (
        CURRENT YEAR TO FRACTION(5), dfecha_inicio, dfecha_fin, 1, rSqlErr, DescErr
    );
	
    LET id_control = DBINFO('sqlca.sqlerrd1'); -- Recuperar el id de control
	--SELECT DBINFO('sqlca.sqlerrd1') INTO id_control FROM systables WHERE tabid = 1;
	
    -- 1. Identificar los numcte dentro del rango configurado
    SELECT DISTINCT t.numcte
      FROM info_clientes_pyt t
     WHERE t.fecha_ctrl BETWEEN dfecha_inicio AND dfecha_fin
    INTO TEMP temp_numcte_rango WITH NO LOG;

    CREATE INDEX idx_temp_numcte_rango ON temp_numcte_rango(numcte);
	
	UPDATE STATISTICS MEDIUM FOR TABLE temp_numcte_rango;


    -- 2. Identificar la fecha mÃ¡s reciente para CLI y CPF globalmente
    SELECT t.numcte, t.tbl_orig, MAX(t.fecha_ctrl) AS max_fecha_ctrl
      FROM info_clientes_pyt t
           INNER JOIN temp_numcte_rango tmp
               ON t.numcte = tmp.numcte
     WHERE t.tbl_orig IN ('CLI', 'CPF')
     GROUP BY t.numcte, t.tbl_orig
    INTO TEMP temp_fechas_recientes WITH NO LOG;

    CREATE INDEX idx_temp_fechas_recientes ON temp_fechas_recientes(numcte, tbl_orig);

	UPDATE STATISTICS MEDIUM FOR TABLE temp_fechas_recientes;	
	
    -- 3. Identificar registros a mantener (fecha mÃ¡s reciente global)
    SELECT t.secuencia
      FROM info_clientes_pyt t
           INNER JOIN temp_fechas_recientes tmp
               ON t.numcte = tmp.numcte
              AND t.tbl_orig = tmp.tbl_orig
              AND t.fecha_ctrl = tmp.max_fecha_ctrl
    INTO TEMP temp_registros_a_mantener WITH NO LOG;

    CREATE INDEX idx_temp_mantener ON temp_registros_a_mantener(secuencia);

    UPDATE STATISTICS MEDIUM FOR TABLE temp_registros_a_mantener;


    -- 4. Identificar registros a borrar (excluyendo los registros a mantener)
    SELECT t.secuencia
      FROM info_clientes_pyt t
           INNER JOIN temp_numcte_rango tmp
               ON t.numcte = tmp.numcte
     WHERE t.tbl_orig IN ('CLI', 'CPF')
       AND NOT EXISTS (
           SELECT 1
             FROM temp_registros_a_mantener tmp2
            WHERE tmp2.secuencia = t.secuencia
       )
    INTO TEMP temp_registros_a_borrar WITH NO LOG;

    CREATE INDEX idx_temp_borrar ON temp_registros_a_borrar(secuencia);
	
    UPDATE STATISTICS MEDIUM FOR TABLE temp_registros_a_borrar;


	-- Calcular total de registros a borrar
	SELECT COUNT(*) INTO total_a_borrar FROM temp_registros_a_borrar;
	
	-- Actualizar control con total de registros a borrar
	UPDATE control_ejecucion_sp_depurar_clientes_pyt
	SET total_registros_a_borrar = total_a_borrar
	WHERE id_control = id_control;
	
	DROP TABLE temp_numcte_rango;
	DROP TABLE temp_fechas_recientes;
	DROP TABLE temp_registros_a_mantener;
	
    -- Procesar los registros en bloques
    BEGIN WORK;
		LET bEnTransaccion = 't';
		FOREACH WITH HOLD
			SELECT secuencia
			INTO secuencia_borrar
			FROM temp_registros_a_borrar
			
			insert into bdinteg:info_clientes_pyt_resp
            select * from bdinteg:info_clientes_pyt
            where secuencia = secuencia_borrar;
			
			--secuencia,empresa,numcte,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_insert,fecha_alta,sexo,fecha_nac,accion,fecha_ctrl,tbl_orig     
			
			DELETE FROM info_clientes_pyt
			WHERE secuencia = secuencia_borrar;
			
			-- Confirmar cada 5,000 registros
			IF contador >= 5000 THEN
				COMMIT WORK;
				LET contador = 0;
				BEGIN WORK;
			ELSE
				LET contador = contador + 1;
				LET itotal_borrados = itotal_borrados + 1;
			END IF;

		END FOREACH;
	
    COMMIT WORK;

	LET bEnTransaccion = 'f';

	UPDATE STATISTICS MEDIUM FOR TABLE info_clientes_pyt;
	UPDATE STATISTICS MEDIUM FOR TABLE info_clientes_pyt_resp;
	
	LET rSqlErr = 00000;
	LET DescErr = 'DepuraciÃ³n Exitosa';
	 
	-- Finalizar ejecuciÃ³n del SP
	UPDATE control_ejecucion_sp_depurar_clientes_pyt
	SET
        fecha_fin_ejecucion = CURRENT YEAR TO FRACTION(5),
		status = 0,
		codigo_error = rSqlErr,
		descripcion_error = DescErr,
		total_registros_borrados = itotal_borrados
	WHERE id_control = id_control;
	
	DROP table temp_registros_a_borrar;
	
	--RETURN rSqlErr, DescErr;
	RETURN rSqlErr, iIsamErr, DescErr;
END
END PROCEDURE;