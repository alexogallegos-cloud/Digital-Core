CREATE PROCEDURE "informix".corresp_pagotdc_cargocta( 
pc_costos 	CHAR(4),        --- SUCURSAL
pusuario 	CHAR(8),        --- USUARIO
pfolio 		CHAR(16),       --- FOLIO SUC
pctacargo 	CHAR(20),  		--- CUENTA CARGO
ptarjcargo 	CHAR(16),  		--- TARJETA CARGO
pnum_tdc 	CHAR(16),  		--- TARJETA DE CREDITO
pfecha 		CHAR(8),		--- FECHA
pmto_tot 	DECIMAL(14,2),	--- MONTO
pmoneda 	CHAR(3),		--- MONEDA
preferencia CHAR(40) )  	--- REFERENCIA
RETURNING CHAR(3),  --- CODIGO DE RETORNO
		  CHAR(4),  --- TERMINACION CARGO
		  CHAR(4),  --- TERMINACION ABONO
		  CHAR(53), --- NOMBRE CORTO DEL CLIENTE TDD
          CHAR(53); --- NOMBRE CORTO DEL CLIENTE TDC
		  
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE vcodret1     CHAR(3);
    DEFINE vcodret2     CHAR(5);
	DEFINE vtransaccion     SMALLINT;
	DEFINE vproceso         CHAR(1);
    
	DEFINE cTerminacionCgo	CHAR(4);
	DEFINE cNombreCortoCgo	CHAR(53);
	DEFINE cTerminacionAbo	CHAR(4);
	DEFINE cNombreCortoAbo	CHAR(53);
	DEFINE cTranCargoDeb	CHAR(4);
	DEFINE cTranPagoTDC		CHAR(4);
	DEFINE cCodRetCR		CHAR(5);
	DEFINE cComisionCR		CHAR(4);
	DEFINE cNumCredito		CHAR(20);
	DEFINE cStatusTar		CHAR(1);
	DEFINE cTarjeta			CHAR(16);
	DEFINE cNumCteCgo		CHAR(20);
	DEFINE cNumCteAbo		CHAR(20);
	DEFINE cStatusCta		CHAR(1);
	
	--// VARIABLES DEL PROCESO PRINCIPAL DE CREDITO
	DEFINE prCodRet			CHAR(5);
	DEFINE prRemanente		MONEY(14,2);
	DEFINE prIntMoratorio	MONEY(14,2);
	DEFINE prIntVencido		MONEY(14,2);
	DEFINE prCapVencido		MONEY(14,2);
	DEFINE prIntVigente		MONEY(14,2);
	DEFINE prCapVigente		MONEY(14,2);
	DEFINE prImpuesto		MONEY(14,2);
	DEFINE prComisiones		MONEY(14,2);
	DEFINE prSeguro			MONEY(14,2);
	
    DEFINE vprecio_udi      DECIMAL(14,6);   
    DEFINE vmonto_udi       DECIMAL(18,6);
    DEFINE vmtoacumcta      DECIMAL(18,6); 
    DEFINE vmtopagosudi     DECIMAL(18,6);   
    DEFINE vlim_cuenta      DECIMAL(18,6); 
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha_tpcambio  DATE;
    DEFINE vtrancorrespcred CHAR(4);
    DEFINE vnomaxudis       INTEGER;
    DEFINE vfechamax        DATE;
    DEFINE vhoramax         datetime hour to minute;
	DEFINE cCodRetRev       char(3);
	
    
    LET sql_err  = 0;
    LET isam_err = 0;
    LET vcodret1 = '000';
    LET vcodret2 = '000';
	LET vtransaccion	= 0;
	LET vproceso		= "0";
	
	LET cTerminacionCgo	= "";
	LET cNombreCortoCgo	= "";
	LET cTerminacionAbo	= "";
	LET cNombreCortoAbo	= "";
	LET cTranCargoDeb	= "";
	LET cTranPagoTDC	= "";
	LET cCodRetCR		= "000";
	LET cComisionCR     = "";
	LET cNumCredito		= "";
	LET cStatusTar		= "";
	LET cTarjeta		= "";
	LET cNumCteCgo		= "";
	LET cNumCteAbo		= "";
	LET cStatusCta		= "";
	
	--// VARIABLES DEL PROCESO PRINCIPAL DE CREDITO
	LET prCodRet			= "";
	LET prRemanente			= 0.0;
	LET prIntMoratorio		= 0.0;
	LET prIntVencido		= 0.0;
	LET prCapVencido		= 0.0;
	LET prIntVigente		= 0.0;
	LET prCapVigente		= 0.0;
	LET prImpuesto			= 0.0;
	LET prComisiones		= 0.0;
	LET prSeguro			= 0.0;
	
    LET vprecio_udi      = 0.00;  
    LET vmonto_udi       = 0.00;
    LET vmtoacumcta      = 0.00;
    LET vmtopagosudi     = 0.00;
    LET vlim_cuenta      = 0.00;
    LET vfecha_hoy       = '';
    LET vfecha_tpcambio  = '';
    LET vtrancorrespcred = '';
    LET vnomaxudis       = 0;
    LET vfechamax        = '';
    LET vhoramax         = '';	
	LET cCodRetRev 		 = "000";
  
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_pagotdc_cargocta.out";
    --SET DEBUG FILE TO "/informix/moha/corresp_pagotdc_cargocta.out";
    --TRACE ON;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_pagotdc_cargocta.err";
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
			RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
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
    
	-- OBTIENE LA TRANSACCION PARA EL CARGO DE LA CUENTA DE DEBITO
	SELECT TRIM(valor)
	INTO cTranCargoDeb
	FROM bdicheq: "informix".sc_param
	WHERE empresa = "001"
	AND codparam = "cargopagotdcbancv";
	
	-- OBTIENE LA TRANSACCION PARA EL PAGO DE LA TARJETA DE CREDITO
	SELECT TRIM(valor)
	INTO cTranPagoTDC
	FROM bdicheq: "informix".sc_param
	WHERE empresa = "001"
	AND codparam = "pagotdcbancv";
    
    IF (pc_costos is null OR pc_costos = '') OR
       (pusuario is null OR pusuario = '' OR LENGTH(pusuario) <> 8) OR
       (pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16) OR
	   (pctacargo = '' AND ptarjcargo = '') OR
	   (pnum_tdc IS NULL OR pnum_tdc = '' OR LENGTH(pnum_tdc) <> 16) OR
       (pfecha is null OR pfecha = '') OR
       (pmto_tot is null OR pmto_tot <= 0.00) OR
       (pmoneda is null OR pmoneda = '' OR LENGTH(pmoneda) <> 03) OR
	   (preferencia is null OR preferencia = '') THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '110';
        RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
    END IF;
	
---RSV
	IF SUBSTR(pctacargo, 1, 2) = '11' THEN
		IF vtransaccion = 1 THEN
			ROLLBACK WORK;
			BEGIN WORK;
		ELSE
			ROLLBACK WORK;
		END IF;
		LET vcodret1 = '100';
		RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
	END IF;
--RSV
	
	LET pmto_tot = pmto_tot / 100;
    
    IF LENGTH(pmoneda) = 03 THEN
        LET pmoneda = pmoneda[2,3]; 
    END IF;
	
	-- // VALIDA DATOS DEL CREDITO
	SELECT num_tarjeta, num_credito, status_tar, numcte
	  INTO cTarjeta, cNumCredito, cStatusTar, cNumCteAbo
	  FROM bdicred: "informix".sd_tarjeta
	 WHERE num_tarjeta = pnum_tdc
	   AND empresa = '001';

	IF cTarjeta is null THEN
		LET cTarjeta = ' ';
	END IF;
	
	IF cNumCredito is null THEN
		LET cNumCredito = ' ';
	END IF;
	
	IF cStatusTar is null THEN
		LET cStatusTar = ' ';
	END IF;
	   
	IF cStatusTar <> 'A'   THEN
		IF vtransaccion = 1 THEN
			ROLLBACK WORK;
			BEGIN WORK;
		ELSE
			ROLLBACK WORK;
		END IF;
		LET vcodret1 = '009';
		RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
	END IF;
	
	IF (cNumCredito is null OR cNumCredito = '') THEN
		IF vtransaccion = 1 THEN
			ROLLBACK WORK;
			BEGIN WORK;
		ELSE
			ROLLBACK WORK;
		END IF;
		LET vcodret1 = '008';
		RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
	END IF;
	
    -- // OBTIENE EL VALOR DE LA UDI
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM bdinteg:si_fechas
     WHERE empresa = '001';
       
    SELECT FIRST 1 MAX(hora_tpcambio) 
      INTO vhoramax
      FROM bdinteg:si_tpcambio 
     WHERE empresa = '001' 
       AND divisa = '09'
       AND fecha_tpcambio = vfecha_hoy;
       
    IF vhoramax is null OR vhoramax = '' THEN
        SELECT FIRST 1 precio_venta
          INTO vprecio_udi
          FROM bdinteg:si_tpcambio
         WHERE empresa = '001'
           AND divisa = '09'
           AND fecha_tpcambio = vfecha_hoy;
    ELSE
        SELECT FIRST 1 precio_venta
          INTO vprecio_udi
          FROM bdinteg:si_tpcambio
         WHERE empresa = '001'
           AND divisa = '09'
           AND fecha_tpcambio = vfecha_hoy
           AND hora_tpcambio = vhoramax;
    END IF;
       
    IF vprecio_udi is null OR vprecio_udi = '' THEN
        SELECT FIRST 1 MAX(fecha_tpcambio) 
          INTO vfecha_tpcambio
          FROM bdinteg:si_tpcambio
         WHERE empresa = '001' 
           AND divisa = '09'
           AND fecha_tpcambio <= vfecha_hoy;
           
        SELECT FIRST 1 MAX(hora_tpcambio) 
          INTO vhoramax
          FROM bdinteg:si_tpcambio 
         WHERE empresa = '001' 
           AND divisa = '09'
           AND fecha_tpcambio = vfecha_tpcambio;
           
        IF vhoramax is null OR vhoramax = '' THEN
            SELECT FIRST 1 precio_venta
              INTO vprecio_udi
              FROM bdinteg:si_tpcambio
             WHERE empresa = '001'
               AND divisa = '09'
               AND fecha_tpcambio = vfecha_tpcambio;
        ELSE
            SELECT FIRST 1 precio_venta
              INTO vprecio_udi
              FROM bdinteg:si_tpcambio
             WHERE empresa = '001'
               AND divisa = '09'
               AND fecha_tpcambio = vfecha_tpcambio
               AND hora_tpcambio = vhoramax;
        END IF;
    END IF;
    
    -- // CONVIERTE MONTO DE LA TRANSACCION EN UDIS
    LET vmonto_udi = pmto_tot / vprecio_udi;
    
    -- // OBTIENE EL VALOR MAXIMO DE UDIS PARA CREDITO
    SELECT valor
      INTO vnomaxudis
      FROM bdicheq:sc_param_corresp
     WHERE codparam = 'NUMAXUDISCRED'
       AND empresa = '001';
    
    -- // VALIDA QUE EL MONTO DE LA TRANSACCION NO REBASE EL LIMITE PERMITIDO
    IF (vmonto_udi > vnomaxudis) THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '006';
        RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
    END IF;
    
    -- // OBTIENE EL ACUMULADO DEL DIA DEL CREDITO
    SELECT SUM(monto)
      INTO vmtoacumcta
      FROM bdicred:sd_movdia
     WHERE empresa = '001'
       AND num_credito = cNumCredito
       AND fecha_mov = pfecha
       AND reversado <> 'S'
       AND sucursal = pc_costos
       AND (transacc_suc = '8104' AND codigo_fun = '068' AND codigo_ref = 1);
     
    IF vmtoacumcta is null THEN
        LET vmtoacumcta = 0.00;
    END IF;
       
    -- // CONVIERTE ACUMULADO DEL CREDITO EN UDIS
    LET vmtopagosudi = vmtoacumcta / vprecio_udi;
    
    -- // SUMA EL MONTO DE LA TRANSACCION AL ACUMULADO DEL CREDITO
    LET vlim_cuenta = vmonto_udi + vmtopagosudi;
	
	-- // VALIDA QUE EL ACUMULADO DEL CREDITO NO REBASE EL LIMITE PERMITIDO
    IF (vlim_cuenta < vnomaxudis) THEN
		-- // OBTIENE DATOS DE LA CUENTA DE CHEQUES
		IF pctacargo is null OR pctacargo = '' THEN
			SELECT cuenta, status_tar
			  INTO pctacargo, cStatusTar
			  FROM bdicheq:"informix".sc_tarjeta
			 WHERE empresa = '001'
			   AND num_tarjeta = ptarjcargo;
			   
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				IF vtransaccion = 1 THEN
					ROLLBACK WORK;
					BEGIN WORK;
				ELSE
					ROLLBACK WORK;
				END IF;
				LET vcodret1 = "100";
				RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
			END IF
			   
			IF cStatusTar <> 'A' THEN
				IF vtransaccion = 1 THEN
					ROLLBACK WORK;
					BEGIN WORK;
				ELSE
					ROLLBACK WORK;
				END IF;
				LET vcodret1 = '009';
				RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
			END IF;
			
			LET cTerminacionCgo = SUBSTR(ptarjcargo,13,4);
		END IF;
		
		IF ptarjcargo is null OR ptarjcargo = '' THEN
			SELECT status_cta
			INTO cStatusCta
			FROM bdicheq:"informix".sc_maechq 
			WHERE empresa = '001' 
			AND cuenta = pctacargo;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				IF vtransaccion = 1 THEN
					ROLLBACK WORK;
					BEGIN WORK;
				ELSE
					ROLLBACK WORK;
				END IF;
				LET vcodret1 = "100";
				RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
			END IF
		
			SELECT num_tarjeta
			  INTO ptarjcargo
			  FROM bdicheq:"informix".sc_tarjeta
			 WHERE empresa = '001'
			   AND cuenta = pctacargo
			   AND secuencia = (SELECT max(secuencia)
								  FROM bdicheq:"informix".sc_tarjeta
								 WHERE empresa = '001'
								   AND cuenta = pctacargo)
			   AND status_tar = 'A';
			   
			IF ptarjcargo IS NULL THEN
				LET ptarjcargo = '';
			END IF;
			
			LET cTerminacionCgo = SUBSTR(pctacargo,8,4);
		END IF;
		
		IF SUBSTR(pctacargo, 1, 2) = '80' THEN
			IF vtransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			LET vcodret1 = '200';
			RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
		END IF;
		
		
		-- // APLICA TRANSACCION DE CARGO EN LA CUENTA DE DEBITO
		EXECUTE PROCEDURE bdicheq:"informix".cargon_ref("001", pc_costos, pusuario, cTranCargoDeb, "0000", pfolio, pctacargo, 0, pmto_tot, pmoneda, preferencia, ptarjcargo, "")
		INTO cCodRetCR, cComisionCR;
		IF cCodRetCR <> "000" THEN  
			IF vtransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			IF cCodRetCR::INTEGER > 0 THEN
				IF cCodRetCR = "400" THEN
					LET vcodret1 = "010";
				ELSE
					LET vcodret1 = "999";
				END IF
			ELSE
				LET vcodret1 = "999";
			END IF
			RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
		ELSE
			-- // APLICA TRANSACCION DE PAGO EN EL CREDITO
			EXECUTE PROCEDURE bdicred: principalrefer("001", cNumCredito, 1, pnum_tdc, pusuario, pc_costos, pfolio, cTranPagoTDC, 0, pmto_tot, preferencia)
			INTO prCodRet, prRemanente, prIntMoratorio, prIntVencido, prCapVencido, prIntVigente, prCapVigente, prImpuesto, prComisiones, prSeguro;
			IF prCodRet <> '000' THEN
				IF prCodRet = '1144' THEN -- // VALIDA EL ERROR 1144 DE CREDITO QUE SIGNIFICA QUE EL MONTO SOBREPASA EL LIMITE DE SALDO A FAVOR
					LET vcodret1 = '006';
					-- // EL MONTO DE LA TRANSACCION NO REBASE EL LIMITE PERMITIDO
					IF vtransaccion = 1 THEN
						ROLLBACK WORK;
						BEGIN WORK;
					ELSE
						ROLLBACK WORK;
					END IF;
					
					EXECUTE PROCEDURE bdicheq:"informix".reversion('001',pc_costos,pusuario,pfolio,'A')
					INTO cCodRetRev;
					
					RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
				ELSE
					LET vcodret1 = '999'; -- // ERROR GENERICO
				
					IF vtransaccion = 1 THEN
						ROLLBACK WORK;
						BEGIN WORK;
					ELSE
						ROLLBACK WORK;
					END IF;
					
					EXECUTE PROCEDURE bdicheq:"informix".reversion('001',pc_costos,pusuario,pfolio,'A')
					INTO cCodRetRev;
				
					RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
				END IF
			ELSE 
				-- // INICIALIZA BANDERA DE CARGO EXITOSO
				LET vproceso = '1';
				
				SELECT num_cte
				INTO cNumCteCgo
				FROM bdicheq:"informix".sc_maechq
				WHERE empresa = '001'
				AND cuenta = pctacargo;
			
				--// OBTIENE EL NOMRE DEL CLIENTE AL QUE SE LE HIZO EL CARGO
				SELECT TRIM(nombre1)||' '||TRIM(apell_paterno)
				INTO cNombreCortoCgo
				FROM bdinteg:"informix".si_cliente
				WHERE numcte = cNumCteCgo;
				
				LET cNombreCortoCgo = RPAD(cNombreCortoCgo, 53, ' ');
				
				--// OBTIENE EL NOMRE DEL CLIENTE AL QUE SE LE HIZO EL PAGO
				SELECT TRIM(nombre1)||' '||TRIM(apell_paterno)
				INTO cNombreCortoAbo
				FROM bdinteg:"informix".si_cliente
				WHERE numcte = cNumCteAbo;
				
				--// OBTIENE EL NOMBRE DE LA TARJETA A LA QUE SE LE HACE EL PAGO
				LET cNombreCortoAbo  = RPAD(cNombreCortoAbo, 53, ' ');
				
				LET cTerminacionAbo = SUBSTR(pnum_tdc,13,4);
			END IF;
		END IF;
    ELSE
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '002';
        RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
    END IF;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
    
    RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
    
    END;

END PROCEDURE;