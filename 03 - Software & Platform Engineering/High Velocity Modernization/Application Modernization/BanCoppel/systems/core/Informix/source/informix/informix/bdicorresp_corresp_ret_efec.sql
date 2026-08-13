CREATE PROCEDURE "informix".corresp_ret_efec ( pc_costos 	CHAR(4),		--- SUCURSAL
                                              pusuario 		CHAR(8),       	--- USUARIO
                                              pfolio 		CHAR(16),       --- FOLIO SUC
                                              pcuenta		CHAR(20),       --- CUENTA
                                              pnum_tarjeta	CHAR(16),  		--- TARJETA
                                              pfecha 		CHAR(8),        --- FECHA
                                              pmto_tot 		DECIMAL(14,2), 	--- MONTO
                                              pmoneda 		CHAR(3),        --- MONEDA
                                              preferencia 	CHAR(40) )  	--- REFERENCIA
RETURNING CHAR(3),	--- CODIGO DE RETORNO
          CHAR(4),	--- TERMINACION
          CHAR(53); --- NOMBRE CORTO DEL CLIENTE
    
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcodret1         CHAR(3);
    DEFINE vcodret2         CHAR(5);
	DEFINE vtransaccion     SMALLINT;
    DEFINE vproceso         CHAR(1);
	
	DEFINE cTerminacion		CHAR(4);
	DEFINE cNombreCorto		CHAR(53);
	DEFINE cCodRetCR		CHAR(5);
	DEFINE cComisionCR		CHAR(4);
	DEFINE cDescTranRef		CHAR(40);
	DEFINE cNombreCte		CHAR(53);
	DEFINE cNumCte         	CHAR(9);
	DEFINE cTranRetEfect	CHAR(4);
	DEFINE cStatusTar		CHAR(1);
	DEFINE cStatusCta		CHAR(1);
	DEFINE vmtoacumcta      DECIMAL(18,6);
	DEFINE vlim_cuenta      DECIMAL(18,6);
	DEFINE iLimitePesos		INT8;
	DEFINE vexiste          CHAR(20);
	DEFINE vcodret          CHAR(5);
        
    LET sql_err  = 0;
    LET isam_err = 0;
    LET vcodret1 = '000';
    LET vcodret2 = '000';
	LET vtransaccion	= 0;
    LET vproceso = '0';
    
	LET cTerminacion	= "";
	LET cNombreCorto	= "";
	LET cCodRetCR		= "000";
	LET cComisionCR     = "";
	LET cDescTranRef	= "";
	LET cNombreCte      = '';
	LET cNumCte        	= '';
	LET cTranRetEfect	= "";
	LET cStatusTar		= "";
	LET cStatusCta		= "";
	LET vmtoacumcta     = 0.00;
	LET vlim_cuenta     = 0.00;
	LET iLimitePesos	= 0;
	LET vexiste         = '';
    LET vcodret         = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        --SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_ret_efec.err";
        --TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
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
            RETURN vcodret1, cTerminacion, cNombreCorto;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH resume;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_ret_efec.out";
	 --SET DEBUG FILE TO "/informix/moha/corresp_ret_efec.out";
     --TRACE ON;

    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	-- OBTIENE LA TRANSACCION PARA RETIRO DE EFECTIVO
	SELECT TRIM(valor)
	INTO cTranRetEfect
	FROM bdicheq: "informix".sc_param
	WHERE empresa = "001"
	AND codparam = "retefectbancefec";
    
    IF (pc_costos is null OR pc_costos = '' OR LENGTH(pc_costos) <> 4) OR
       (pusuario is null OR pusuario = '' OR LENGTH(pusuario) <> 8) OR
       (pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16) OR
	   (pcuenta IS NULL) OR
	   (pnum_tarjeta IS NULL) OR
	   (pcuenta = "" AND pnum_tarjeta = "" ) OR
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
        
    END IF;
	
	----RSV
	IF SUBSTR(pcuenta, 1, 2) = '11' THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '100';
        RETURN vcodret1, cTerminacion, cNombreCorto;
    END IF;
	-----RSV
	
	LET pmto_tot = pmto_tot / 100;
    
    IF LENGTH(pmoneda) = 03 THEN
        LET pmoneda = pmoneda[2,3]; 
    END IF;
    
    -- // OBTIENE DATOS DE LA CUENTA DE CHEQUES
    IF pcuenta is null OR pcuenta = '' THEN
        SELECT cuenta, status_tar
          INTO pcuenta, cStatusTar
          FROM bdicheq:"informix".sc_tarjeta
         WHERE empresa = '001'
           AND num_tarjeta = pnum_tarjeta;
		   
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			IF vtransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			LET vcodret1 = "100";
			RETURN vcodret1, cTerminacion, cNombreCorto;
		END IF
		   
           
        IF cStatusTar <> 'A' THEN
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET vcodret1 = '009';
            RETURN vcodret1, cTerminacion, cNombreCorto;
        END IF;
		
		LET cTerminacion = SUBSTR(pnum_tarjeta,13,4);
    END IF;
    
    IF pnum_tarjeta is null OR pnum_tarjeta = '' THEN
		SELECT cuenta
		INTO cStatusCta
		FROM bdicheq:"informix".sc_maechq 
		WHERE empresa = '001' 
		AND cuenta = pcuenta;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			IF vtransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			LET vcodret1 = "100";
			RETURN vcodret1, cTerminacion, cNombreCorto;
		END IF
		
		IF cStatusCta NOT IN ('1','4','5') THEN
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET vcodret1 = "009";
			RETURN vcodret1, cTerminacion, cNombreCorto;
        END IF;
	
        SELECT num_tarjeta
          INTO pnum_tarjeta
          FROM bdicheq:"informix".sc_tarjeta
         WHERE empresa = '001'
           AND cuenta = pcuenta
           AND secuencia = (SELECT max(secuencia)
                              FROM bdicheq:"informix".sc_tarjeta
                             WHERE empresa = '001'
                               AND cuenta = pcuenta)
           AND status_tar = 'A';
           
        IF pnum_tarjeta IS NULL THEN
            LET pnum_tarjeta = '';
        END IF;
		
		LET cTerminacion = SUBSTR(pcuenta,8,4);
    END IF;
    
    IF SUBSTR(pcuenta, 1, 2) = '80' THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '200';
        RETURN vcodret1, cTerminacion, cNombreCorto;
    END IF;
    
    --- 21/06/2021 JICS
    EXECUTE PROCEDURE bdicheq:sp_cargo_val(pcuenta)
    INTO vcodret;

    IF vcodret <> '00000' THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '002';
        RETURN vcodret1, cTerminacion, cNombreCorto;
    END IF;
	--- 21/06/2021 JICS
	
    -- // OBTIENE EL ACUMULADO DE LA CUENTA
    SELECT monto_acum
      INTO vmtoacumcta
      FROM bdicheq:"informix".sc_acumdiacorrespred
     WHERE cuenta = pcuenta;
     
    IF vmtoacumcta is null THEN
        LET vmtoacumcta = 0.00;
    END IF;
     
    -- // OBTIENE EL VALOR MAXIMO DE UDIS PARA CAPTACION
    SELECT valor
      INTO iLimitePesos
      FROM bdicheq:"informix".sc_param_corresp
     WHERE codparam = 'NUMAXPESRETEFECDEB'
       AND empresa = '001';
       
    -- // SUMA EL MONTO DE LA TRANSACCION AL ACUMULADO DE LA CUENTA
    LET vlim_cuenta = pmto_tot + vmtoacumcta;
    
    -- // VALIDA QUE EL ACUMULADO DE LA CUENTA NO REBASE EL LIMITE PERMITIDO
    IF vlim_cuenta > iLimitePesos THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '002';
        RETURN vcodret1, cTerminacion, cNombreCorto;
    END IF;
	
	-- // APLICA TRANSACCION DE CARGO EN LA CUENTA DE DEBITO
	EXECUTE PROCEDURE bdicheq:"informix".cargon_ref("001", pc_costos, pusuario, cTranRetEfect, "0000", pfolio, pcuenta, 0, pmto_tot, pmoneda, preferencia, pnum_tarjeta, "")
	INTO cCodRetCR, cComisionCR;
    
	IF cCodRetCR = "000" THEN  
		-- // INICIALIZA BANDERA DE CARGO EXITOSO
		LET vproceso = '1';
		-- // ACUMULA MONTO EN LA CUENTA DE CHEQUES
		SELECT cuenta
		  INTO vexiste
		  FROM bdicheq:"informix".sc_acumdiacorrespred
		 WHERE cuenta = pcuenta;
		 
		IF vexiste is null OR vexiste = '' THEN
			INSERT INTO bdicheq:"informix".sc_acumdiacorrespred 
			VALUES (pcuenta, pmto_tot);
		ELSE
			UPDATE bdicheq:"informix".sc_acumdiacorrespred
			   SET monto_acum = monto_acum + pmto_tot
			 WHERE cuenta = pcuenta;
		END IF;
        
		-- // OBTIENE NOMBRE CORTO DEL CLIENTE Y PRODUCTO
		SELECT num_cte
		INTO cNumCte
		FROM bdicheq:"informix".sc_maechq
		WHERE empresa = '001'
		AND cuenta = pcuenta;

		SELECT TRIM(nombre1)||' '||TRIM(apell_paterno)
		INTO cNombreCte
		FROM bdinteg:"informix".si_cliente
		WHERE numcte = cNumCte;
		
		LET cNombreCorto = RPAD(cNombreCte, 53, " ");
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
		
		RETURN vcodret1, cTerminacion, cNombreCorto;
	END IF;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
        
    RETURN vcodret1, cTerminacion, cNombreCorto;

    END; 

END PROCEDURE;