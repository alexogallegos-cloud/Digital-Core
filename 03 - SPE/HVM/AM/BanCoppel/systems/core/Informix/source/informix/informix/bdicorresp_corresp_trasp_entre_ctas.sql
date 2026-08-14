CREATE PROCEDURE "informix".corresp_trasp_entre_ctas(
pc_costos 		CHAR(4),      	--- SUCURSAL
pusuario 		CHAR(8),       	--- USUARIO
pfolio 			CHAR(16),       --- FOLIO SUC
pctacargo 		CHAR(20),       --- CUENTA CARGO
pnum_tarjcargo 	CHAR(16),  		--- TARJETA CARGO
pctaabono 		CHAR(20),       --- CUENTA ABONO
pnum_tarjabono 	CHAR(16),  		--- TARJETA ABONO
pfecha 			CHAR(8),        --- FECHA
pmto_tot 		DECIMAL(14,2), 	--- MONTO
pmoneda 		CHAR(3),        --- MONEDA
preferencia 	CHAR(40) )  	--- REFERENCIA
RETURNING CHAR(3),  --- CODIGO DE RETORNO
          CHAR(4),	--- TERMINACION CARGO
		  CHAR(4),	--- TERMINACION ABONO
          CHAR(53), --- NOMBRE CORTO DEL CLIENTE CARGO
		  CHAR(53); --- NOMBRE CORTO DEL CLIENTE ABONO

    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcodret1         CHAR(3);
    DEFINE vcodret2         CHAR(5);
    DEFINE vproceso         CHAR(1);

	DEFINE cTerminacionCgo	CHAR(4);
	DEFINE cNombreCortoCgo	CHAR(53);
	DEFINE cTerminacionAbo	CHAR(4);
	DEFINE cNombreCortoAbo	CHAR(53);
	DEFINE cTranTraspCgo	CHAR(4);
	DEFINE cTranTraspAbo	CHAR(4);
	DEFINE cCodRetCR		CHAR(5);
	DEFINE cComisionCR		CHAR(4);
	DEFINE cCodRetAR		CHAR(5);
	DEFINE cStatusTar		CHAR(1);
	DEFINE vtransaccion     SMALLINT;
	DEFINE cNumCteCargo		CHAR(20);
	DEFINE cNumCteAbono		CHAR(20);
	DEFINE cStatusCta		CHAR(1);
	DEFINE vfecha_hoy       DATE;
	DEFINE vhoramax         datetime hour to minute;
	DEFINE vprecio_udi      DECIMAL(14,6); 
	DEFINE vfecha_tpcambio  DATE;
	DEFINE vmonto_udi       DECIMAL(18,6);
	DEFINE vmtoacumcta      DECIMAL(18,6);
	DEFINE vmtoacumudi      DECIMAL(18,6);
	DEFINE vnomaxudis       INTEGER;
	DEFINE vlim_cuenta      DECIMAL(18,6);
	DEFINE vexiste          CHAR(20);


    LET sql_err  = 0;
    LET isam_err = 0;
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vproceso = '0';

	LET cTerminacionCgo	= "";
	LET cNombreCortoCgo	= "";
	LET cTerminacionAbo	= "";
	LET cNombreCortoAbo	= "";
	LET cTranTraspCgo	= "";
	LET cTranTraspAbo	= "";
	LET cCodRetCR		= "000";
	LET cComisionCR     = "";
	LET cCodRetAR		= "000";
	LET cStatusTar		= "";
	LET vtransaccion	= 0;
	LET cNumCteCargo	= "";
	LET cNumCteAbono	= "";
	LET cStatusCta		= "";
	LET vfecha_hoy      = '';
	LET vhoramax        = '';
	LET vprecio_udi     = 0.00;
	LET vfecha_tpcambio = '';
	LET vmonto_udi      = 0.00;
	LET vmtoacumcta     = 0.00;
	LET vmtoacumudi    = 0.00;
	LET vnomaxudis      = 0;
	LET vlim_cuenta     = 0.00;
	LET vexiste         = '';


    --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_trasp_entre_ctas.out";
     --SET DEBUG FILE TO "/informix/moha/corresp_trasp_entre_ctas.out";
     --TRACE ON;

    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_trasp_entre_ctas.err";
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

	-- OBTIENE LA TRANSACCION DE TRASPASO ENTRE CUENTAS (CARGO)
	SELECT TRIM(valor)
	INTO cTranTraspCgo
	FROM bdicheq: "informix".sc_param
	WHERE empresa = "001"
	AND codparam = "traspctasbancefeccgo";

	-- OBTIENE LA TRANSACCION DE TRASPASO ENTRE CUENTAS (ABONO)
	SELECT TRIM(valor)
	INTO cTranTraspAbo
	FROM bdicheq: "informix".sc_param
	WHERE empresa = "001"
	AND codparam = "traspctasbancefecabo";

    IF (pc_costos is null OR pc_costos = '' OR LENGTH(pc_costos) <> 4) OR
       (pusuario is null OR pusuario = '' OR LENGTH(pusuario) <> 8) OR
       (pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16) OR
	   (pctacargo IS NULL) OR (pnum_tarjcargo IS NULL) OR (pctacargo = "" AND pnum_tarjcargo = "" ) OR
	   (pctaabono IS NULL) OR (pnum_tarjabono IS NULL) OR (pctaabono = "" AND pnum_tarjabono = "" ) OR
       (pfecha is null OR pfecha = '') OR
       (pmto_tot is null OR pmto_tot <= 0.00) OR
       (pmoneda is null OR pmoneda = '' OR LENGTH(pmoneda) <> 03) OR
	   (preferencia IS NULL OR preferencia = '') THEN
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
	IF SUBSTR(pctacargo, 1, 2) = '11' OR SUBSTR(pctaabono, 1, 2) = '11' THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '100';
        RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
    END IF;
	---RSV	

	LET pmto_tot = pmto_tot / 100;

    IF LENGTH(pmoneda) = 03 THEN
        LET pmoneda = pmoneda[2,3];
    END IF;
	
	-- //VALIDA QUE NO SEA LA MISMA CUENTA DEL CLIENTE
	LET pctacargo = NVL(pctacargo,"");
	LET pnum_tarjcargo = NVL(pnum_tarjcargo,"");
	LET pctaabono = NVL(pctaabono,"");
	LET pnum_tarjabono = NVL(pnum_tarjabono,"");
	
	IF pctacargo <> "" AND pctaabono <> "" THEN
		IF pctacargo = pctaabono THEN
			IF vtransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			LET vcodret1 = "120";
			RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
		END IF
	END IF
	
	IF pnum_tarjcargo <> "" AND pnum_tarjabono <> "" THEN
		IF pnum_tarjcargo = pnum_tarjabono THEN
			IF vtransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			LET vcodret1 = "120";
			RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
		END IF
	END IF

    -- // OBTIENE DATOS DE LA CUENTA ORIGEN DE CHEQUES
    IF pctacargo is null OR pctacargo = '' THEN
        SELECT cuenta, status_tar, numcte
          INTO pctacargo, cStatusTar, cNumCteCargo
          FROM bdicheq:"informix".sc_tarjeta
         WHERE empresa = '001'
           AND num_tarjeta = pnum_tarjcargo;

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

		LET cTerminacionCgo = SUBSTR(pnum_tarjcargo,13,4);
    END IF;

    IF pnum_tarjcargo is null OR pnum_tarjcargo = '' THEN
		SELECT status_cta
		INTO cStatusCta
		FROM bdicheq:"informix".sc_maechq
		WHERE empresa = '001'
		AND cuenta = pctacargo
		AND status_cta = "1";

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
		
		IF cStatusCta NOT IN ('1','4','5') THEN
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET vcodret1 = "009";
			RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
        END IF;

        SELECT num_tarjeta, numcte
          INTO pnum_tarjcargo, cNumCteCargo
          FROM bdicheq:"informix".sc_tarjeta
         WHERE empresa = '001'
           AND cuenta = pctacargo
           AND secuencia = (SELECT max(secuencia)
                              FROM bdicheq:"informix".sc_tarjeta
                             WHERE empresa = '001'
                               AND cuenta = pctacargo)
           AND status_tar = 'A';

        IF pnum_tarjcargo IS NULL THEN
            LET pnum_tarjcargo = '';
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

	
    -- // OBTIENE DATOS DE LA CUENTA DESTINO DE CHEQUES
    IF pctaabono is null OR pctaabono = '' THEN
        SELECT cuenta, status_tar, numcte
          INTO pctaabono, cStatusTar, cNumCteAbono
          FROM bdicheq:"informix".sc_tarjeta
         WHERE empresa = '001'
           AND num_tarjeta = pnum_tarjabono;
		   
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

		LET cTerminacionAbo = SUBSTR(pnum_tarjabono,13,4);
    END IF;

    IF pnum_tarjabono is null OR pnum_tarjabono = '' THEN

        SELECT num_tarjeta, numcte
          INTO pnum_tarjabono, cNumCteAbono
          FROM bdicheq:"informix".sc_tarjeta
         WHERE empresa = '001'
           AND cuenta = pctaabono
           AND secuencia = (SELECT max(secuencia)
                              FROM bdicheq:"informix".sc_tarjeta
                             WHERE empresa = '001'
                               AND cuenta = pctaabono)
           AND status_tar = 'A';

        IF pnum_tarjabono IS NULL THEN
            LET pnum_tarjabono = '';
        END IF;
		
		SELECT status_cta, num_cte
		INTO cStatusCta, cNumCteAbono
		FROM bdicheq:"informix".sc_maechq
		WHERE empresa = '001'
		AND cuenta = pctaabono;
		--AND status_cta = "1";

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
		
		IF cStatusCta NOT IN ('1','4','5') THEN
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET vcodret1 = "009";
			RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
        END IF;

		LET cTerminacionAbo = SUBSTR(pctaabono,8,4);
    END IF;
	
	IF SUBSTR(pctaabono, 1, 2) = '80' THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '200';
        RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
    END IF;
	
	-- INC 11 1966 ModificaciÃ³n a las transacciÃ³n de traspaso entre cuentas efectivas a traves de corresponsales para no permitir cuentas de personas morales
    IF SUBSTR(pctacargo, 1, 4) IN ("1200","1600","2200","2600","9900","9901","2300","2800","2700") OR SUBSTR(pctaabono, 1, 4) IN ("1200","1600","2200","2600","9900","9901","2300","2800","2700") THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
		
		LET vcodret1 = "100";
		RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
    END IF;
	
    -- // OBTIENE EL VALOR DE LA UDI
    SELECT {+INDEX(bdinteg:si_fechas idx_si_fechas)} fecha_hoy
      INTO vfecha_hoy
      FROM bdinteg:"informix".si_fechas
     WHERE empresa = '001';
       
    SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} FIRST 1 MAX(hora_tpcambio) 
      INTO vhoramax
      FROM bdinteg:"informix".si_tpcambio 
     WHERE empresa = '001' 
       AND divisa = '09'
       AND fecha_tpcambio = vfecha_hoy;
       
    IF vhoramax is null OR vhoramax = '' THEN
        SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} FIRST 1 precio_venta
          INTO vprecio_udi
          FROM bdinteg:"informix".si_tpcambio
         WHERE empresa = '001'
           AND divisa = '09'
           AND fecha_tpcambio = vfecha_hoy;
    ELSE
        SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} FIRST 1 precio_venta
          INTO vprecio_udi
          FROM bdinteg:"informix".si_tpcambio
         WHERE empresa = '001'
           AND divisa = '09'
           AND fecha_tpcambio = vfecha_hoy
           AND hora_tpcambio = vhoramax;
    END IF;
       
    IF vprecio_udi is null OR vprecio_udi = '' THEN
        SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} FIRST 1 MAX(fecha_tpcambio) 
          INTO vfecha_tpcambio
          FROM bdinteg:"informix".si_tpcambio
         WHERE empresa = '001' 
           AND divisa = '09'
           AND fecha_tpcambio <= vfecha_hoy;
           
        SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} FIRST 1 MAX(hora_tpcambio) 
          INTO vhoramax
          FROM bdinteg:"informix".si_tpcambio 
         WHERE empresa = '001' 
           AND divisa = '09'
           AND fecha_tpcambio = vfecha_tpcambio;
           
        IF vhoramax is null OR vhoramax = '' THEN
            SELECT {+INDEX(bdinteg:"informix".si_tpcambio idx_si_tpcambio2)} FIRST 1 precio_venta
              INTO vprecio_udi
              FROM bdinteg:"informix".si_tpcambio
             WHERE empresa = '001'
               AND divisa = '09'
               AND fecha_tpcambio = vfecha_tpcambio;
        ELSE
            SELECT {+INDEX(bdinteg:"informix".si_tpcambio idx_si_tpcambio2)} FIRST 1 precio_venta
              INTO vprecio_udi
              FROM bdinteg:"informix".si_tpcambio
             WHERE empresa = '001'
               AND divisa = '09'
               AND fecha_tpcambio = vfecha_tpcambio
               AND hora_tpcambio = vhoramax;
        END IF;
    END IF;
           
    -- // CONVIERTE MONTO DE LA TRANSACCION EN UDIS
    LET vmonto_udi = pmto_tot / vprecio_udi;
    
    -- // OBTIENE EL ACUMULADO DE LA CUENTA
    SELECT monto_acum
      INTO vmtoacumcta
      FROM bdicheq:"informix".sc_acumdiacorresptec
     WHERE cuenta = pctacargo;
     
    IF vmtoacumcta is null THEN
        LET vmtoacumcta = 0.00;
    END IF;
    
    -- // CONVIERTE ACUMULADO DE LA CUENTA EN UDIS
    LET vmtoacumudi = vmtoacumcta / vprecio_udi;
     
    -- // OBTIENE EL VALOR MAXIMO DE UDIS PARA CAPTACION
    SELECT {+INDEX(bdicheq:"informix".sc_param_corresp idx_paramcorresp)} valor
      INTO vnomaxudis
      FROM bdicheq:"informix".sc_param_corresp
     WHERE codparam = 'NUMAXUDISTRASPDEB'
       AND empresa = '001';
       
    -- // SUMA EL MONTO DE LA TRANSACCION AL ACUMULADO DE LA CUENTA
    LET vlim_cuenta = vmonto_udi + vmtoacumudi;
    
    -- // VALIDA QUE EL ACUMULADO DE LA CUENTA NO REBASE EL LIMITE PERMITIDO
    IF vlim_cuenta > vnomaxudis THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '002';
        RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
    END IF;
	
	-- // APLICA TRANSACCION DE CARGO EN LA CUENTA DE DEBITO
	EXECUTE PROCEDURE bdicheq: "informix".cargon_ref ("001", pc_costos, pusuario, cTranTraspCgo, "0000", pfolio, pctacargo, 0, pmto_tot, pmoneda, preferencia, pnum_tarjcargo,"")
	INTO cCodRetCR, cComisionCR;
	IF cCodRetCR = "000" THEN
		-- // APLICA TRANSACCION DE ABONO EN LA CUENTA DE DEBITO
		EXECUTE PROCEDURE bdicheq: "informix".abono_ref ("001", pc_costos, pusuario,  cTranTraspAbo, "0000", pfolio, pctaabono, 0, pmto_tot, pmto_tot, 0, 0, 0, pmoneda, preferencia, pnum_tarjabono, pusuario)
		INTO cCodRetAR;
		IF cCodRetAR = "000" THEN
			-- // INICIALIZA BANDERA DE CARGO EXITOSO
			LET vproceso = '1';
			
			-- // ACUMULA MONTO EN LA CUENTA DE CHEQUES
			SELECT cuenta
			  INTO vexiste
			  FROM bdicheq:"informix".sc_acumdiacorresptec
			 WHERE cuenta = pctacargo;
			 
			IF vexiste is null OR vexiste = '' THEN
				INSERT INTO bdicheq:"informix".sc_acumdiacorresptec 
				VALUES (pctacargo, pmto_tot);
			ELSE
				UPDATE bdicheq:"informix".sc_acumdiacorresptec
				   SET monto_acum = monto_acum + pmto_tot
				 WHERE cuenta = pctacargo;
			END IF;
			
			-- // OBTIENE NOMBRE CORTO DEL CLIENTE
			SELECT TRIM(nombre1)||' '||TRIM(apell_paterno)
			INTO cNombreCortoCgo
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = cNumCteCargo;

			LET cNombreCortoCgo = RPAD(cNombreCortoCgo, 53, " ");

			-- // OBTIENE NOMBRE CORTO DEL CLIENTE
			SELECT TRIM(nombre1)||' '||TRIM(apell_paterno)
			INTO cNombreCortoAbo
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = cNumCteAbono;

			LET cNombreCortoAbo = RPAD(cNombreCortoAbo, 53, " ");
		ELSE
			IF cCodRetAR::INTEGER > 0 THEN
				LET vcodret1 = cCodRetAR;
			ELSE
				LET vcodret1 = "999";
			END IF

			IF vtransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;

			RETURN vcodret1, cTerminacionCgo, cTerminacionAbo, cNombreCortoCgo, cNombreCortoAbo;
		END IF
	ELSE
		IF cCodRetCR::INTEGER > 0 THEN
			IF cCodRetCR = "400" THEN
				LET vcodret1 = "010";
			ELSE
				LET vcodret1 = "999";
			END IF
		ELSE
			LET vcodret1 = "999";
		END IF

		IF vtransaccion = 1 THEN
			ROLLBACK WORK;
			BEGIN WORK;
		ELSE
			ROLLBACK WORK;
		END IF;

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