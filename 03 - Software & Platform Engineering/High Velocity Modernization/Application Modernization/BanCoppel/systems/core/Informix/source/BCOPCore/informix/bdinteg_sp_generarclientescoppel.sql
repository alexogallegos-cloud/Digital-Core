CREATE PROCEDURE "informix".sp_generarclientescoppel(p_dFechaInicial DATE, p_dFechaFinal DATE)
	RETURNING 		CHAR(6);
					
	DEFINE v_sValorRetorno					CHAR(6);
	DEFINE v_iSqlError						INTEGER;
	DEFINE v_sEmpresa						CHAR(3);
	DEFINE v_sNumClienteBancoppel			CHAR(20);
	DEFINE v_sNumClienteCoppel				CHAR(20);
	DEFINE v_sTipo							CHAR(2);
	DEFINE v_sStatus						CHAR(1);
	DEFINE v_dFechaInsert					DATE;
	DEFINE v_dFechaCambio					DATE;
	DEFINE v_sNumClienteCoppelConfirmado	CHAR(20);
	
	--------------------------------------------------------------------------
	-- Creado por Erick Zamora 19/02/2008
	--SET DEBUG FILE TO "/tmp/sp_generarclientescoppel.out";
	--TRACE ON;
	--------------------------------------------------------------------------
	
	LET v_sValorRetorno = '000';
	LET v_sEmpresa = '001';
	LET v_sTipo = '01';
	LET v_sStatus = 'A';
	LET v_dFechaInsert = CURRENT::DATE;
	LET v_dFechaCambio = v_dFechaInsert;
	LET v_sNumClienteCoppelConfirmado = '';
	
	BEGIN
	
		ON EXCEPTION SET v_iSqlError
			IF v_iSqlError <> 0 THEN
				RETURN v_iSqlError;
			END IF;
		END EXCEPTION;
			
			IF EXISTS(SELECT * FROM sysmaster:systabnames 
                                  WHERE partnum > 0 
                                  and dbsname = 'bdinteg' 
                                  AND tabname = 'tmp_si_clientecomparacionbanco') THEN
				DROP TABLE tmp_si_clientecomparacionbanco;
			END IF;
			
			SELECT numcte, referencia
			FROM bdinteg:si_clientecomparacionbanco
			WHERE fechamov BETWEEN p_dFechaInicial AND p_dFechaFinal
			INTO TEMP tmp_si_clientecomparacionbanco
			WITH NO LOG;
		
		FOREACH
			SELECT numcte, referencia
			INTO v_sNumClienteBancoppel, v_sNumClienteCoppel
			FROM tmp_si_clientecomparacionbanco
			/*
			SELECT numcte, referencia
			INTO v_sNumClienteBancoppel, v_sNumClienteCoppel
			FROM si_clientecomparacionbanco
			WHERE fechamov BETWEEN p_dFechaInicial AND p_dFechaFinal
			*/
			
			SELECT {+INDEX (si_clienteconfirmado idx_clienteconfirmado2)} TRIM(numctecoppel) 
			INTO v_sNumClienteCoppelConfirmado
			FROM bdinteg:si_clienteconfirmado WHERE empresa = v_sEmpresa AND numctebancoppel = v_sNumClienteBancoppel AND numctecoppel IS NOT NULL;
			
			--SI NO EXISTE
			IF v_sNumClienteCoppelConfirmado IS NULL THEN
			
				--INSERTAR
				INSERT INTO bdinteg:si_clienteconfirmado (empresa, numctebancoppel, numctebancoppelformat, numctecoppel, tipo, status, fechainsert, fechacambio)
				VALUES (v_sEmpresa, v_sNumClienteBancoppel, LPAD(TRIM(v_sNumClienteBancoppel), 9, '0'), v_sNumClienteCoppel, v_sTipo, v_sStatus, v_dFechaInsert, v_dFechaCambio);
				
			--SI EXISTE PERO LA REFERENCIA ES DISTINTA
			ELIF v_sNumClienteCoppel <> v_sNumClienteCoppelConfirmado THEN
			
				--ACTUALIZAR
				UPDATE {+INDEX (si_clienteconfirmado idx_clienteconfirmado2)} bdinteg:si_clienteconfirmado SET status = 'D', fechaCambio =  v_dFechaCambio
				WHERE empresa = v_sEmpresa AND numctebancoppel = v_sNumClienteBancoppel
				AND numctecoppel = v_sNumClienteCoppelConfirmado;
				
			END IF;
			
		END FOREACH;
		
		DROP TABLE tmp_si_clientecomparacionbanco;
		RETURN v_sValorRetorno;
	END;
END PROCEDURE;