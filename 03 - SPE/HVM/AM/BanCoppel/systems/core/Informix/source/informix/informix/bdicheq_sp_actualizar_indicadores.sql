CREATE PROCEDURE "informix".sp_actualizar_indicadores( pSucursal	CHAR(4),
                                                       pCuenta     CHAR(20),
                                                       pTransacc	CHAR(4),
                                                       pMonto		DECIMAL(14,2),
                                                       pFechaHoy	DATE,
                                                       pTipo		CHAR(1) )
RETURNING CHAR(6) AS cod_ret
    
	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);
	DEFINE cDescRet			CHAR(80);
	DEFINE cAnioMes			CHAR(6);
	DEFINE iGrupo			SMALLINT;
    DEFINE cProducto        CHAR(4);
	
	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";
	LET cAnioMes			= "";
	LET iGrupo				= 0;
    LET cProducto           = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    --- SET DEBUG FILE TO '/informix/moha/sp_actualizar_indicadores.out';
    --- TRACE ON;

    /* ####################################################################################################################
	IF NVL(pTipo,"") = "" OR NVL(pSucursal,"") = ""  OR NVL(pCuenta,"") = "" OR NVL(pTransacc,"") = "" THEN
        LET cCodRet = "000001";
		-- "FALTA POR LO MENOS UN PARAMETRO DE ENTRADA";
        RETURN cCodRet;
	ELSE
        SELECT producto
          INTO cProducto
          FROM sc_maechq
         WHERE cuenta = pCuenta;
         
        IF cProducto IN('1200','1600','9900','9901') THEN
            LET cCodRet = "000000";
            RETURN cCodRet;
        END IF;
    
		-- OBTIENE EL AÑO Y EL MES ACTUAL, FECHA ACTUAL
		LET cAnioMes = YEAR(pFechaHoy) || LPAD(MONTH(pFechaHoy),2,"0");
	
		-- OBTIENE EL GRUPO AL QUE PERTENECE LA TRANSACCION EN LOS INDICADORES
		SELECT grupo
		INTO iGrupo
		FROM "informix".sc_transacc_indicadores 
		WHERE numero = pTransacc;
	
		IF pTipo IN("A","C") THEN
			-- ACTUALIZA LA TABLA DE LOS INDICADORES
			IF iGrupo = 1 THEN
				UPDATE "informix".sc_indicadores SET ide_cobrado = ide_cobrado + pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, ide_cobrado)
					SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pMonto
					FROM "informix".sc_indicadores
					WHERE cuenta = pCuenta;
				END IF
			ELIF iGrupo = 2 THEN
				UPDATE "informix".sc_indicadores SET comisiones = comisiones + pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, comisiones)
					SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pMonto
					FROM "informix".sc_indicadores
					WHERE cuenta = pCuenta;
				END IF
			ELIF iGrupo = 3 THEN
				UPDATE "informix".sc_indicadores SET isr_cobrado = isr_cobrado + pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, isr_cobrado)
					SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pMonto
					FROM "informix".sc_indicadores
					WHERE cuenta = pCuenta;
				END IF
			ELIF iGrupo = 4 THEN
				UPDATE "informix".sc_indicadores SET int_pagados = int_pagados + pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, int_pagados)
					SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pMonto
					FROM "informix".sc_indicadores
					WHERE cuenta = pCuenta;
				END IF
			ELIF iGrupo = 5 THEN
				UPDATE "informix".sc_indicadores SET uso_linea_ccc = uso_linea_ccc + pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, uso_linea_ccc)
					SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pMonto
					FROM "informix".sc_indicadores
					WHERE cuenta = pCuenta;
				END IF
			ELIF iGrupo = 6 THEN
				UPDATE "informix".sc_indicadores SET uso_sobregiro = uso_sobregiro + pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, uso_sobregiro)
					SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pMonto
					FROM "informix".sc_indicadores
					WHERE cuenta = pCuenta;
				END IF
			ELIF iGrupo = 7 THEN
				UPDATE "informix".sc_indicadores SET cargo_dep_cta_eje =  cargo_dep_cta_eje + pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, cargo_dep_cta_eje)
					SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pMonto
					FROM "informix".sc_indicadores
					WHERE cuenta = pCuenta;
				END IF
			ELIF iGrupo = 8 THEN
				UPDATE "informix".sc_indicadores SET pago_intereses_ccc = pago_intereses_ccc + pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pago_intereses_ccc)
					SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pMonto
					FROM "informix".sc_indicadores
					WHERE cuenta = pCuenta;
				END IF
			ELIF iGrupo = 9 THEN
				UPDATE "informix".sc_indicadores SET cobro_cta_sbg = cobro_cta_sbg + pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, cobro_cta_sbg)
					SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pMonto
					FROM "informix".sc_indicadores
					WHERE cuenta = pCuenta;
				END IF
			ELIF iGrupo = 10 THEN
				UPDATE "informix".sc_indicadores SET debito_int_cta_sbg = debito_int_cta_sbg + pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, debito_int_cta_sbg)
					SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pMonto
					FROM "informix".sc_indicadores
					WHERE cuenta = pCuenta;
				END IF
			ELIF iGrupo = 11 THEN
				UPDATE "informix".sc_indicadores SET pago_linea_ccc = pago_linea_ccc + pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pago_linea_ccc)
					SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pMonto
					FROM "informix".sc_indicadores
					WHERE cuenta = pCuenta;
				END IF
			ELIF iGrupo = 12 THEN
				UPDATE "informix".sc_indicadores SET internet = 1  WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, internet)
					SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, 1
					FROM "informix".sc_indicadores
					WHERE cuenta = pCuenta;
				END IF
			ELIF iGrupo IN (13,14,15,16,17) THEN
				UPDATE "informix".sc_indicadores 
				SET
					fec_prim_deposito_orig = (CASE WHEN fec_prim_deposito_orig IS NULL THEN pFechaHoy ELSE fec_prim_deposito_orig END),
					imp_prim_deposito_orig = (CASE WHEN imp_prim_deposito_orig IS NULL THEN pMonto ELSE imp_prim_deposito_orig END),
					fec_prim_deposito = (CASE WHEN num_depositos_mes = 0 THEN pFechaHoy ELSE fec_prim_deposito END),
					imp_prim_deposito = (CASE WHEN num_depositos_mes = 0 THEN pMonto ELSE imp_prim_deposito END),
					fec_ult_deposito = pFechaHoy,
					imp_ult_deposito = pMonto,
					num_depositos_mes = num_depositos_mes + 1,
					imp_depositos_mes = imp_depositos_mes + pMonto
				WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				IF iGrupo = 13 THEN
					UPDATE "informix".sc_indicadores
					SET
						fec_prim_deposito_vent = (CASE WHEN num_depositos_vent = 0 THEN pFechaHoy ELSE fec_prim_deposito_vent END),
						imp_prim_deposito_vent = (CASE WHEN num_depositos_vent = 0 THEN pMonto ELSE imp_prim_deposito_vent END),
						fec_ult_deposito_vent = pFechaHoy,
						imp_ult_deposito_vent = pMonto,
						num_depositos_vent = num_depositos_vent + 1,
						imp_acum_depositos_vent = imp_acum_depositos_vent + pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, fec_prim_deposito, imp_prim_deposito, fec_ult_deposito, imp_ult_deposito,num_depositos_mes, imp_depositos_mes, fec_prim_deposito_vent, imp_prim_deposito_vent, fec_ult_deposito_vent, imp_ult_deposito_vent, num_depositos_vent, imp_acum_depositos_vent)
						SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto
						FROM "informix".sc_indicadores
						WHERE cuenta = pCuenta;
					END IF
				ELIF iGrupo = 14 THEN
					UPDATE "informix".sc_indicadores
					SET
						fec_prim_deposito_corresp = (CASE WHEN num_depositos_corresp = 0 THEN pFechaHoy ELSE fec_prim_deposito_corresp END),
						imp_prim_deposito_corresp = (CASE WHEN num_depositos_corresp = 0 THEN pMonto ELSE imp_prim_deposito_corresp END),
						fec_ult_deposito_corresp = pFechaHoy,
						imp_ult_deposito_corresp = pMonto,
						num_depositos_corresp = num_depositos_corresp + 1,
						imp_acum_depositos_corresp = imp_acum_depositos_corresp + pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, fec_prim_deposito, imp_prim_deposito, fec_ult_deposito, imp_ult_deposito,num_depositos_mes, imp_depositos_mes, fec_prim_deposito_corresp, imp_prim_deposito_corresp, fec_ult_deposito_corresp, imp_ult_deposito_corresp, num_depositos_corresp, imp_acum_depositos_corresp)
						SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto
						FROM "informix".sc_indicadores
						WHERE cuenta = pCuenta;
					END IF
				ELIF iGrupo = 15 THEN
					UPDATE "informix".sc_indicadores
					SET
						fec_prim_deposito_spei = (CASE WHEN num_deposito_spei = 0 THEN pFechaHoy ELSE fec_prim_deposito_spei END),
						imp_prim_deposito_spei = (CASE WHEN num_deposito_spei = 0 THEN pMonto ELSE imp_prim_deposito_spei END),
						fec_ult_deposito_spei = pFechaHoy,
						imp_ult_deposito_spei = pMonto,
						num_deposito_spei = num_deposito_spei + 1,
						imp_acum_deposito_spei = imp_acum_deposito_spei + pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, fec_prim_deposito, imp_prim_deposito, fec_ult_deposito, imp_ult_deposito,num_depositos_mes, imp_depositos_mes, fec_prim_deposito_spei, imp_prim_deposito_spei, fec_ult_deposito_spei, imp_ult_deposito_spei, num_deposito_spei, imp_acum_deposito_spei)
						SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto
						FROM "informix".sc_indicadores
						WHERE cuenta = pCuenta;
					END IF
				ELIF iGrupo = 16 THEN
					UPDATE "informix".sc_indicadores
					SET
						fec_prim_deposito_terc = (CASE WHEN num_depositos_terc = 0 THEN pFechaHoy ELSE fec_prim_deposito_terc END),
						imp_prim_deposito_terc = (CASE WHEN num_depositos_terc = 0 THEN pMonto ELSE imp_prim_deposito_terc END),
						fec_ult_deposito_terc = pFechaHoy,
						imp_ult_deposito_terc = pMonto,
						num_depositos_terc = num_depositos_terc + 1,
						imp_acum_depositos_terc = imp_acum_depositos_terc + pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN					
						INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, fec_prim_deposito, imp_prim_deposito, fec_ult_deposito, imp_ult_deposito,num_depositos_mes, imp_depositos_mes, fec_prim_deposito_terc, imp_prim_deposito_terc, fec_ult_deposito_terc, imp_ult_deposito_terc, num_depositos_terc, imp_acum_depositos_terc)
						SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto
						FROM "informix".sc_indicadores
						WHERE cuenta = pCuenta;
					END IF
				ELIF iGrupo = 17 THEN
					UPDATE "informix".sc_indicadores
					SET
						fec_prim_deposito_entrecta = (CASE WHEN num_depositos_entrecta = 0 THEN pFechaHoy ELSE fec_prim_deposito_entrecta END),
						imp_prim_deposito_entrecta = (CASE WHEN num_depositos_entrecta = 0 THEN pMonto ELSE imp_prim_deposito_entrecta END),
						fec_ult_deposito_entrecta = pFechaHoy,
						imp_ult_deposito_entrecta = pMonto,
						num_depositos_entrecta = num_depositos_entrecta + 1,
						imp_acum_depositos_entrecta = imp_acum_depositos_entrecta + pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN					
						INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, fec_prim_deposito, imp_prim_deposito, fec_ult_deposito, imp_ult_deposito,num_depositos_mes, imp_depositos_mes, fec_prim_deposito_entrecta, imp_prim_deposito_entrecta, fec_ult_deposito_entrecta, imp_ult_deposito_entrecta, num_depositos_entrecta, imp_acum_depositos_entrecta)
						SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto
						FROM "informix".sc_indicadores
						WHERE cuenta = pCuenta;
					END IF
				END IF
			ELIF iGrupo IN (18,19,20,21,22,23,24,25) THEN
				UPDATE "informix".sc_indicadores 
				SET 
					fec_prim_retiro = (CASE WHEN num_retiro_mes = 0 THEN pFechaHoy ELSE fec_prim_retiro END),
					imp_prim_retiro = (CASE WHEN num_retiro_mes = 0 THEN pMonto ELSE imp_prim_retiro END),
					fec_ult_retiro = pFechaHoy,
					imp_ult_retiro = pMonto,
					num_retiro_mes = num_retiro_mes + 1,
					imp_retiro_mes = imp_retiro_mes + pMonto
				WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				IF iGrupo = 18 THEN
					UPDATE "informix".sc_indicadores 
					SET 
						fec_prim_retiro_vent = (CASE WHEN num_retiros_vent = 0 THEN pFechaHoy ELSE fec_prim_retiro_vent END),
						imp_prim_retiro_vent = (CASE WHEN num_retiros_vent = 0 THEN pMonto ELSE imp_prim_retiro_vent END),
						fec_ult_retiro_vent = pFechaHoy,
						imp_ult_retiro_vent = pMonto,
						num_retiros_vent = num_retiros_vent + 1,
						imp_acum_retiros_vent = imp_acum_retiros_vent + pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, fec_prim_retiro, imp_prim_retiro, fec_ult_retiro, imp_ult_retiro, num_retiro_mes, imp_retiro_mes, fec_prim_retiro_vent, imp_prim_retiro_vent, fec_ult_retiro_vent, imp_ult_retiro_vent, num_retiros_vent, imp_acum_retiros_vent)
						SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto
						FROM "informix".sc_indicadores
						WHERE cuenta = pCuenta;
					END IF
				ELIF iGrupo = 19 THEN
					UPDATE "informix".sc_indicadores 
					SET 
						fec_prim_retiro_spei = (CASE WHEN num_retiro_spei = 0 THEN pFechaHoy ELSE fec_prim_retiro_spei END),
						imp_prim_retiro_spei = (CASE WHEN num_retiro_spei = 0 THEN pMonto ELSE imp_prim_retiro_spei END),
						fec_ult_retiro_spei = pFechaHoy,
						imp_ult_retiro_spei = pMonto,
						num_retiro_spei = num_retiro_spei + 1,
						imp_acum_retiro_spei = imp_acum_retiro_spei + pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN					
						INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, fec_prim_retiro, imp_prim_retiro, fec_ult_retiro, imp_ult_retiro, num_retiro_mes, imp_retiro_mes, fec_prim_retiro_spei, imp_prim_retiro_spei, fec_ult_retiro_spei, imp_ult_retiro_spei, num_retiro_spei, imp_acum_retiro_spei)
						SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto
						FROM "informix".sc_indicadores
						WHERE cuenta = pCuenta;
					END IF					
				ELIF iGrupo = 20 THEN
					UPDATE "informix".sc_indicadores 
					SET 
						fec_prim_retiro_terc = (CASE WHEN num_retiros_terc = 0 THEN pFechaHoy ELSE fec_prim_retiro_terc END),
						imp_prim_retiro_terc = (CASE WHEN num_retiros_terc = 0 THEN pMonto ELSE imp_prim_retiro_terc END),
						fec_ult_retiro_terc = pFechaHoy,
						imp_ult_retiro_terc = pMonto,
						num_retiros_terc = num_retiros_terc + 1,
						imp_acum_retiros_terc = imp_acum_retiros_terc + pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN					
						INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, fec_prim_retiro, imp_prim_retiro, fec_ult_retiro, imp_ult_retiro, num_retiro_mes, imp_retiro_mes, fec_prim_retiro_terc, imp_prim_retiro_terc, fec_ult_retiro_terc, imp_ult_retiro_terc, num_retiros_terc, imp_acum_retiros_terc)
						SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto
						FROM "informix".sc_indicadores
						WHERE cuenta = pCuenta;
					END IF
				ELIF iGrupo = 21 THEN
					UPDATE "informix".sc_indicadores 
					SET 
						fec_prim_retiro_entrecta = (CASE WHEN num_retiros_entrecta = 0 THEN pFechaHoy ELSE fec_prim_retiro_entrecta END),
						imp_prim_retiro_entrecta = (CASE WHEN num_retiros_entrecta = 0 THEN pMonto ELSE imp_prim_retiro_entrecta END),
						fec_ult_retiro_entrecta = pFechaHoy,
						imp_ult_retiro_entrecta = pMonto,
						num_retiros_entrecta = num_retiros_entrecta + 1,
						imp_acum_retiros_entrecta = imp_acum_retiros_entrecta + pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN					
						INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, fec_prim_retiro, imp_prim_retiro, fec_ult_retiro, imp_ult_retiro, num_retiro_mes, imp_retiro_mes, fec_prim_retiro_entrecta, imp_prim_retiro_entrecta, fec_ult_retiro_entrecta, imp_ult_retiro_entrecta, num_retiros_entrecta, imp_acum_retiros_entrecta)
						SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto
						FROM "informix".sc_indicadores
						WHERE cuenta = pCuenta;
					END IF					
				ELIF iGrupo = 22 THEN
					UPDATE "informix".sc_indicadores 
					SET 
						fec_prim_retiro_atm = (CASE WHEN num_retiros_atm = 0 THEN pFechaHoy ELSE fec_prim_retiro_atm END),
						imp_prim_retiro_atm = (CASE WHEN num_retiros_atm = 0 THEN pMonto ELSE imp_prim_retiro_atm END),
						fec_ult_retiro_atm = pFechaHoy,
						imp_ult_retiro_atm = pMonto,
						num_retiros_atm = num_retiros_atm + 1,
						imp_acum_retiros_atm = imp_acum_retiros_atm + pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN					
						INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, fec_prim_retiro, imp_prim_retiro, fec_ult_retiro, imp_ult_retiro, num_retiro_mes, imp_retiro_mes, fec_prim_retiro_atm, imp_prim_retiro_atm, fec_ult_retiro_atm, imp_ult_retiro_atm, num_retiros_atm, imp_acum_retiros_atm)
						SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto
						FROM "informix".sc_indicadores
						WHERE cuenta = pCuenta;
					END IF
				ELIF iGrupo = 23 THEN
					UPDATE "informix".sc_indicadores 
					SET 
						fec_prim_retiro_cashback = (CASE WHEN num_retiros_cashback = 0 THEN pFechaHoy ELSE fec_prim_retiro_cashback END),
						imp_prim_retiro_cashback = (CASE WHEN num_retiros_cashback = 0 THEN pMonto ELSE imp_prim_retiro_cashback END),
						fec_ult_retiro_cashback = pFechaHoy,
						imp_ult_retiro_cashback = pMonto,
						num_retiros_cashback = num_retiros_cashback + 1 ,
						imp_acum_retiros_cashback = imp_acum_retiros_cashback + pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN					
						INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, fec_prim_retiro, imp_prim_retiro, fec_ult_retiro, imp_ult_retiro, num_retiro_mes, imp_retiro_mes, fec_prim_retiro_cashback, imp_prim_retiro_cashback, fec_ult_retiro_cashback, imp_ult_retiro_cashback, num_retiros_cashback, imp_acum_retiros_cashback)
						SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto
						FROM "informix".sc_indicadores
						WHERE cuenta = pCuenta;
					END IF					
				ELIF iGrupo = 24 THEN
					UPDATE "informix".sc_indicadores 
					SET 
						fec_prim_compra_pos = (CASE WHEN num_compra_pos = 0 THEN pFechaHoy ELSE fec_prim_compra_pos END),
						imp_prim_compra_pos = (CASE WHEN num_compra_pos = 0 THEN pMonto ELSE imp_prim_compra_pos END),
						fec_ult_compra_pos = pFechaHoy,
						imp_ult_compra_pos = pMonto,
						num_compra_pos = num_compra_pos + 1,
						imp_acum_compra_pos = imp_acum_compra_pos + pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN					
						INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, fec_prim_retiro, imp_prim_retiro, fec_ult_retiro, imp_ult_retiro, num_retiro_mes, imp_retiro_mes, fec_prim_compra_pos, imp_prim_compra_pos, fec_ult_compra_pos, imp_ult_compra_pos, num_compra_pos, imp_acum_compra_pos)
						SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto
						FROM "informix".sc_indicadores
						WHERE cuenta = pCuenta;
					END IF
				ELIF iGrupo = 25 THEN
					UPDATE "informix".sc_indicadores 
					SET 
						fec_prim_compra_interred = (CASE WHEN num_compra_interred = 0 THEN pFechaHoy ELSE fec_prim_compra_interred END),
						imp_prim_compra_interred = (CASE WHEN num_compra_interred = 0 THEN pMonto ELSE imp_prim_compra_interred END),
						fec_ult_compra_interred = pFechaHoy,
						imp_ult_compra_interred = pMonto,
						num_compra_interred = num_compra_interred + 1,
						imp_acum_compra_interred = imp_acum_compra_interred + pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN					
						INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, fec_prim_retiro, imp_prim_retiro, fec_ult_retiro, imp_ult_retiro, num_retiro_mes, imp_retiro_mes, fec_prim_compra_interred, imp_prim_compra_interred, fec_ult_compra_interred, imp_ult_compra_interred, num_compra_interred, imp_acum_compra_interred)
						SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto, pFechaHoy, pMonto, pFechaHoy, pMonto, 1, pMonto
						FROM "informix".sc_indicadores
						WHERE cuenta = pCuenta;
					END IF
				END IF
			ELIF iGrupo = 26 THEN
				UPDATE "informix".sc_indicadores SET depositos_x_prestamos = depositos_x_prestamos + pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN				
					INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, depositos_x_prestamos)
					SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pMonto
					FROM "informix".sc_indicadores
					WHERE cuenta = pCuenta;
				END IF
			ELIF iGrupo = 27 THEN
				UPDATE "informix".sc_indicadores SET cargos_x_prestamos = cargos_x_prestamos + pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN				
					INSERT INTO "informix".sc_indicadores (empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, cargos_x_prestamos)
					SELECT LIMIT 1 empresa, cAnioMes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig, pMonto
					FROM "informix".sc_indicadores
					WHERE cuenta = pCuenta;
				END IF
			END IF
		-- VALIDA SI ES TRANSACCION REVERSADA
		ELIF pTipo = "R" THEN
			IF iGrupo = 1 THEN
				UPDATE "informix".sc_indicadores SET ide_cobrado = ide_cobrado - pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
			ELIF iGrupo = 2 THEN
				UPDATE "informix".sc_indicadores SET comisiones = comisiones - pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
			ELIF iGrupo = 3 THEN
				UPDATE "informix".sc_indicadores SET isr_cobrado = isr_cobrado - pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
			ELIF iGrupo = 4 THEN
				UPDATE "informix".sc_indicadores SET int_pagados =  int_pagados - pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
			ELIF iGrupo = 5 THEN
				UPDATE "informix".sc_indicadores SET uso_linea_ccc = uso_linea_ccc - pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
			ELIF iGrupo = 6 THEN
				UPDATE "informix".sc_indicadores SET uso_sobregiro = uso_sobregiro - pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
			ELIF iGrupo = 7 THEN
				UPDATE "informix".sc_indicadores SET cargo_dep_cta_eje =  cargo_dep_cta_eje - pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
			ELIF iGrupo = 8 THEN
				UPDATE "informix".sc_indicadores SET pago_intereses_ccc = pago_intereses_ccc - pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
			ELIF iGrupo = 9 THEN
				UPDATE "informix".sc_indicadores SET cobro_cta_sbg = cobro_cta_sbg - pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
			ELIF iGrupo = 10 THEN
				UPDATE "informix".sc_indicadores SET debito_int_cta_sbg = debito_int_cta_sbg - pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
			ELIF iGrupo = 11 THEN
				UPDATE "informix".sc_indicadores SET pago_linea_ccc = pago_linea_ccc - pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
			ELIF iGrupo = 12 THEN
				UPDATE "informix".sc_indicadores SET internet = 0  WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
			ELIF iGrupo IN (13,14,16,17) THEN
				UPDATE "informix".sc_indicadores 
				SET
					fec_prim_deposito = (CASE WHEN num_depositos_mes = 1 THEN MDY(1,1,1900) ELSE fec_prim_deposito END),
					imp_prim_deposito = (CASE WHEN num_depositos_mes = 1 THEN 0 ELSE imp_prim_deposito END),
					fec_ult_deposito = (CASE WHEN num_depositos_mes = 1 THEN MDY(1,1,1900) ELSE fec_ult_deposito END),
					imp_ult_deposito = (CASE WHEN num_depositos_mes = 1 THEN 0 ELSE imp_ult_deposito END),
					num_depositos_mes = num_depositos_mes - 1,
					imp_depositos_mes = imp_depositos_mes - pMonto
				WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				IF iGrupo = 13 THEN
					UPDATE "informix".sc_indicadores
					SET
						fec_prim_deposito_vent = (CASE WHEN num_depositos_vent = 1 THEN MDY(1,1,1900) ELSE fec_prim_deposito_vent END),
						imp_prim_deposito_vent = (CASE WHEN num_depositos_vent = 1 THEN 0 ELSE imp_prim_deposito_vent END),
						fec_ult_deposito_vent = (CASE WHEN num_depositos_vent = 1 THEN MDY(1,1,1900) ELSE fec_ult_deposito_vent END),
						imp_ult_deposito_vent = (CASE WHEN num_depositos_vent = 1 THEN 0 ELSE imp_ult_deposito_vent END),
						num_depositos_vent = num_depositos_vent - 1,
						imp_acum_depositos_vent = imp_acum_depositos_vent - pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				ELIF iGrupo = 14 THEN
					UPDATE "informix".sc_indicadores
					SET
						fec_prim_deposito_corresp = (CASE WHEN num_depositos_corresp = 1 THEN MDY(1,1,1900) ELSE fec_prim_deposito_corresp END),
						imp_prim_deposito_corresp = (CASE WHEN num_depositos_corresp = 1 THEN 0 ELSE imp_prim_deposito_corresp END),
						fec_ult_deposito_corresp = (CASE WHEN num_depositos_corresp = 1 THEN MDY(1,1,1900) ELSE fec_ult_deposito_corresp END),
						imp_ult_deposito_corresp = (CASE WHEN num_depositos_corresp = 1 THEN 0 ELSE imp_ult_deposito_corresp END),
						num_depositos_corresp = num_depositos_corresp - 1,
						imp_acum_depositos_corresp = imp_acum_depositos_corresp - pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				ELIF iGrupo = 16 THEN
					UPDATE "informix".sc_indicadores
					SET
						fec_prim_deposito_terc = (CASE WHEN num_depositos_terc = 1 THEN MDY(1,1,1900) ELSE fec_prim_deposito_terc END),
						imp_prim_deposito_terc = (CASE WHEN num_depositos_terc = 1 THEN 0 ELSE imp_prim_deposito_terc END),
						fec_ult_deposito_terc = (CASE WHEN num_depositos_terc = 1 THEN MDY(1,1,1900) ELSE fec_ult_deposito_terc END),
						imp_ult_deposito_terc = (CASE WHEN num_depositos_terc = 1 THEN 0 ELSE imp_ult_deposito_terc END),
						num_depositos_terc = num_depositos_terc - 1,
						imp_acum_depositos_terc = imp_acum_depositos_terc - pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				ELIF iGrupo = 17 THEN
					UPDATE "informix".sc_indicadores
					SET
						fec_prim_deposito_entrecta = (CASE WHEN num_depositos_entrecta = 1 THEN MDY(1,1,1900) ELSE fec_prim_deposito_entrecta END),
						imp_prim_deposito_entrecta = (CASE WHEN  num_depositos_entrecta = 1 THEN 0 ELSE imp_prim_deposito_entrecta END),
						fec_ult_deposito_entrecta = (CASE WHEN num_depositos_entrecta = 1 THEN MDY(1,1,1900) ELSE fec_ult_deposito_entrecta END),
						imp_ult_deposito_entrecta = (CASE WHEN num_depositos_entrecta = 1 THEN 0 ELSE imp_ult_deposito_entrecta END),
						num_depositos_entrecta = num_depositos_entrecta - 1,
						imp_acum_depositos_entrecta = imp_acum_depositos_entrecta - pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				END IF
			ELIF iGrupo IN (18,20,21,22) THEN
				UPDATE "informix".sc_indicadores 
				SET 
					fec_prim_retiro = (CASE WHEN num_retiro_mes = 1 THEN MDY(1,1,1900) ELSE fec_prim_retiro END),
					imp_prim_retiro = (CASE WHEN num_retiro_mes = 1 THEN 0 ELSE imp_prim_retiro END),
					fec_ult_retiro = (CASE WHEN num_retiro_mes = 1 THEN MDY(1,1,1900) ELSE fec_ult_retiro END),
					imp_ult_retiro = (CASE WHEN num_retiro_mes = 1 THEN 0 ELSE imp_ult_retiro END),
					num_retiro_mes = num_retiro_mes - 1,
					imp_retiro_mes = imp_retiro_mes - pMonto
				WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				IF iGrupo = 18 THEN
					UPDATE "informix".sc_indicadores 
					SET 
						fec_prim_retiro_vent = (CASE WHEN num_retiros_vent = 1 THEN MDY(1,1,1900) ELSE fec_prim_retiro_vent END),
						imp_prim_retiro_vent = (CASE WHEN num_retiros_vent = 1 THEN 0 ELSE imp_prim_retiro_vent END),
						fec_ult_retiro_vent = (CASE WHEN num_retiros_vent = 1 THEN MDY(1,1,1900) ELSE fec_ult_retiro_vent END),
						imp_ult_retiro_vent = (CASE WHEN num_retiros_vent = 1 THEN 0 ELSE imp_ult_retiro_vent END),
						num_retiros_vent = num_retiros_vent - 1,
						imp_acum_retiros_vent = imp_acum_retiros_vent - pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				ELIF iGrupo = 20 THEN
					UPDATE "informix".sc_indicadores 
					SET 
						fec_prim_retiro_terc = (CASE WHEN num_retiros_terc = 1 THEN MDY(1,1,1900) ELSE fec_prim_retiro_terc END),
						imp_prim_retiro_terc = (CASE WHEN num_retiros_terc = 1 THEN 0 ELSE imp_prim_retiro_terc END),
						fec_ult_retiro_terc = (CASE WHEN num_retiros_terc = 1 THEN MDY(1,1,1900) ELSE fec_ult_retiro_terc END),
						imp_ult_retiro_terc = (CASE WHEN num_retiros_terc = 1 THEN 0 ELSE imp_ult_retiro_terc END),
						num_retiros_terc = num_retiros_terc - 1,
						imp_acum_retiros_terc = imp_acum_retiros_terc - pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				ELIF iGrupo = 21 THEN
					UPDATE "informix".sc_indicadores 
					SET 
						fec_prim_retiro_entrecta = (CASE WHEN num_retiros_entrecta = 1 THEN MDY(1,1,1900) ELSE fec_prim_retiro_entrecta END),
						imp_prim_retiro_entrecta = (CASE WHEN num_retiros_entrecta = 1 THEN 0 ELSE imp_prim_retiro_entrecta END),
						fec_ult_retiro_entrecta = (CASE WHEN num_retiros_entrecta = 1 THEN MDY(1,1,1900) ELSE fec_ult_retiro_entrecta END),
						imp_ult_retiro_entrecta = (CASE WHEN num_retiros_entrecta = 1 THEN 0 ELSE imp_ult_retiro_entrecta END),
						num_retiros_entrecta = num_retiros_entrecta - 1,
						imp_acum_retiros_entrecta = imp_acum_retiros_entrecta - pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				ELIF iGrupo = 22 THEN
					UPDATE "informix".sc_indicadores 
					SET 
						fec_prim_retiro_atm = (CASE WHEN num_retiros_atm = 1 THEN MDY(1,1,1900) ELSE fec_prim_retiro_atm END),
						imp_prim_retiro_atm = (CASE WHEN num_retiros_atm = 1 THEN 0 ELSE imp_prim_retiro_atm END),
						fec_ult_retiro_atm = (CASE WHEN num_retiros_atm = 1 THEN MDY(1,1,1900) ELSE fec_ult_retiro_atm END),
						imp_ult_retiro_atm = (CASE WHEN num_retiros_atm = 1 THEN 0 ELSE imp_ult_retiro_atm END),
						num_retiros_atm = num_retiros_atm - 1,
						imp_acum_retiros_atm = imp_acum_retiros_atm - pMonto
					WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
				END IF
			ELIF iGrupo = 26 THEN
				UPDATE "informix".sc_indicadores SET depositos_x_prestamos = depositos_x_prestamos - pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
			ELIF iGrupo = 27 THEN
				UPDATE "informix".sc_indicadores SET cargos_x_prestamos = cargos_x_prestamos - pMonto WHERE anio_mes = cAnioMes AND cuenta = pCuenta;
			END IF
		END IF
	END IF
    #################################################################################################################### */
	
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para actualizar los indicadores de captación',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Julio 2014';

CREATE PROCEDURE "informix".sp_generaredoctaejeencabezado_movtos( pEmpresa CHAR(3), 
                                                                     pCuenta CHAR(20), 
                                                                     pAniomes CHAR(6) )
RETURNING CHAR(5)       AS vcodret, 
          DECIMAL(16,2) AS mSaldoAnterior,
          DECIMAL(16,2) AS mDepositos,
          DECIMAL(16,2) AS mInteresesPagados,
          DECIMAL(16,2) AS mRetiros,
          DECIMAL(16,2) AS mOtrosCargos,
          DECIMAL(16,2) AS mIvaOtrosCargos,
          DECIMAL(16,2) AS mSaldoCorte,
          DECIMAL(16,2) AS mSaldoPromedio,
          DECIMAL(16,2) AS mRetencionIsr,              
          DECIMAL(16,2) AS mInteresesNetos,
          SMALLINT      AS iDias,             
          DECIMAL(9, 6) AS dTasaBruta,
          DECIMAL(16,2) AS mTotOtrosCargos,
          DECIMAL(9, 6) AS dGAT;
		  
  
          DEFINE vcodret              CHAR(5);
          DEFINE vexiste_maehis       CHAR(6);
          DEFINE vsqlerr              INTEGER;  
          DEFINE visamerr             INTEGER;  
          DEFINE iDias                SMALLINT;             
          DEFINE dTasaBruta           DECIMAL(9, 6);
          DEFINE dGAT                 DECIMAL(9, 6);
          DEFINE mSaldoAnterior       DECIMAL(18,2);
          DEFINE mDepositos           DECIMAL(18,2);
          DEFINE mInteresesPagados    DECIMAL(18,2);
          DEFINE mRetiros             DECIMAL(18,2);
          DEFINE mOtrosCargos         DECIMAL(18,2);
          DEFINE mIvaOtrosCargos      DECIMAL(18,2);
          DEFINE mSaldoCorte          DECIMAL(18,2);
          DEFINE mSaldoPromedio       DECIMAL(18,2);
          DEFINE mRetencionIsr        DECIMAL(18,2);
          DEFINE mInteresesNetos      DECIMAL(18,2);
          DEFINE mAux1                DECIMAL(18,2);
          DEFINE mTotOtrosCargos      DECIMAL(18,2);
	
    
          LET vcodret = "000";                              
          LET mSaldoPromedio= 0;                  
          LET mDepositos = 0;
          LET mInteresesNetos = 0;                
          LET mSaldoAnterior = 0;                     
          LET mRetiros = 0;                       
          LET mInteresesPagados = 0;                  
          LET mOtrosCargos = 0;                   
          LET mRetencionIsr = 0;
          LET mIvaOtrosCargos = 0;                
          LET mSaldoCorte = 0;                        
          LET iDias = 0;                          
          LET dTasaBruta = 0;                         
          LET mAux1 = 0;                          
          LET pCuenta = TRIM(pCuenta);                
          LET mTotOtrosCargos = 0;
          LET dGAT = 0;


          --- SET debug FILE TO "/tmp/sp_generaredoctaejeencabezado_movtos.out";
          --- trace on;

          BEGIN
          
          ON EXCEPTION SET vsqlerr, visamerr
              IF vsqlerr != 0 THEN
                  --SET DEBUG FILE TO "./sp_generaredoctaejeencabezado_movtos.err";
                  --TRACE ON;
                  LET vcodret = vsqlerr;
                  RETURN vcodret,mSaldoAnterior,mDepositos,mInteresesPagados,mRetiros, mOtrosCargos,mIvaOtrosCargos,
                         mSaldoCorte,mSaldoPromedio,mRetencionIsr,mInteresesNetos,iDias,dTasaBruta,mTotOtrosCargos,dGAT;
              END IF;
          END EXCEPTION;
          
          SET ISOLATION TO DIRTY READ;
          SET LOCK MODE TO WAIT 2;

          -- // Validar que los parámetros se hayan recibido correctamente
          IF (TRIM(pEmpresa) = "" OR pEmpresa IS NULL) THEN
              LET vcodret = "001";
               RETURN vcodret,mSaldoAnterior,mDepositos,mInteresesPagados,mRetiros, mOtrosCargos,mIvaOtrosCargos,
                       mSaldoCorte,mSaldoPromedio,mRetencionIsr,mInteresesNetos,iDias,dTasaBruta,mTotOtrosCargos,dGAT;
          END IF;
          
          IF (TRIM(pCuenta) = "" OR pCuenta IS NULL) THEN
              LET vcodret = "002";
              RETURN vcodret,mSaldoAnterior,mDepositos,mInteresesPagados,mRetiros, mOtrosCargos,mIvaOtrosCargos,
                     mSaldoCorte,mSaldoPromedio,mRetencionIsr,mInteresesNetos,iDias,dTasaBruta,mTotOtrosCargos,dGAT;
          END IF;
    
         SELECT FIRST 1 aniomes 
           INTO vexiste_maehis
           FROM bdicheq:sc_maehis mc 
          WHERE mc.empresa = pEmpresa 
            AND mc.cuenta = pCuenta 
            AND mc.aniomes = pAniomes;
            
         IF vexiste_maehis is null OR vexiste_maehis = '' THEN
             LET vcodret = "003";
             RETURN vcodret,mSaldoAnterior,mDepositos,mInteresesPagados,mRetiros, mOtrosCargos,mIvaOtrosCargos,
                    mSaldoCorte,mSaldoPromedio,mRetencionIsr,mInteresesNetos,iDias,dTasaBruta,mTotOtrosCargos,dGAT;
         END IF
    
         -- // OBTENER EL ESTADO DE CUENTA
         -- SELECT LIMIT 1
                -- TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto, mc.num_tarjeta, 
                -- TRIM(mc.num_cte), mc.cuenta_clabe, NVL(mc.fechaini, MDY(1, 1, 1900)), NVL(mc.fechafin, MDY(1, 1, 1900)),
                -- NVL(sdo_mes_ant, 0), NVL(totdepositos, 0), NVL(totintpag, 0), NVL(totretiros, 0), NVL(totcomcobrada, 0), NVL(totivacobrado, 0), 
                -- NVL(sdo_actual, 0), NVL(totisrcobrado, 0), NVL(dia_sdo_pos, 0), NVL(tasabruta, 0), NVL(acum_sdo_pos, 0), mc.producto,
                -- NVL(totretirosefec, 0), NVL(tototroscargos, 0), NVL(gat, 0), NVL(gat_real, 0)  
           -- INTO cMensajeProducto, cNum_Tarjeta, 
                -- cNum_cte, cClabe, dFechaInicio, dFecha_emision, 
                -- mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos, mIvaOtrosCargos, 
                -- mSaldoCorte, mRetencionIsr, iDias, dTasaBruta, mAux1, cNumProducto,
                -- mTotRetirosEfec, mTotOtrosCargos, dGAT, dGATReal
           -- FROM bdicheq:sc_maehis AS mc,
                -- bdicheq:sc_producto AS ap
          -- WHERE mc.empresa = pEmpresa 
            -- AND mc.cuenta = pCuenta 
            -- AND mc.aniomes = pAniomes 
            -- AND ap.empresa = mc.empresa 
            -- AND ap.producto = mc.producto;

    	   -------rsv 
	    SELECT LIMIT 1
               NVL(sdo_mes_ant, 0),
	    	   NVL(totdepositos, 0),
	    	   NVL(totintpag, 0),
	    	   NVL(totretiros, 0),
	    	   NVL(totcomcobrada, 0),
	    	   NVL(totivacobrado, 0), 
	    	   NVL(sdo_actual, 0),
	    	   NVL(totisrcobrado, 0),
               NVL(dia_sdo_pos, 0), 		   
	    	   NVL(tasabruta, 0),
	    	   NVL(tototroscargos, 0), 
	    	   NVL(gat, 0),
	    	   NVL(acum_sdo_pos, 0)
	      INTO mSaldoAnterior, 
               mDepositos, 
               mInteresesPagados, 
               mRetiros, 
               mOtrosCargos, 
               mIvaOtrosCargos, 
               mSaldoCorte,
               mRetencionIsr, 
               iDias, 
               dTasaBruta, 
               mTotOtrosCargos,  
               dGAT, 
	    	   mAux1
          FROM bdicheq:sc_maehis AS mc,
               bdicheq:sc_producto AS ap
         WHERE mc.empresa = pEmpresa 
           AND mc.cuenta = pCuenta 
           AND mc.aniomes = pAniomes 
           AND ap.empresa = mc.empresa 
           AND ap.producto = mc.producto;
	       

          IF iDias = 0 THEN
              LET mSaldoPromedio = 0;
          ELSE
              LET mSaldoPromedio = mAux1 / iDias;
          END IF;

          LET mInteresesNetos = mInteresesPagados - mRetencionIsr;

	      RETURN vcodret,mSaldoAnterior,mDepositos,mInteresesPagados,mRetiros, mOtrosCargos,mIvaOtrosCargos,
                 mSaldoCorte,mSaldoPromedio,mRetencionIsr,mInteresesNetos,iDias,dTasaBruta,mTotOtrosCargos,dGAT;
    
END;
    
END PROCEDURE;