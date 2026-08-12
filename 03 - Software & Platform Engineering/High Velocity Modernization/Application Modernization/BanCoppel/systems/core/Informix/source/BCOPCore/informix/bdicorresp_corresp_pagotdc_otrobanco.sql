CREATE PROCEDURE "informix".corresp_pagotdc_otrobanco(
pmodopago		CHAR(1),		--- MODO DE PAGO: E = EFECTIVO, C = CARGO EN CUENTA
pc_costos 		CHAR(4),		--- SUCURSAL
pusuario 		CHAR(8),		--- USUARIO
pfolio 			CHAR(16),		--- FOLIO SUC
pnum_cuenta 	CHAR(20),		--- CUENTA DE DEBITO
pnum_tarjdeb 	CHAR(16),		--- TARJETA DE DEBITO
pnum_tarjcred 	CHAR(16),		--- TARJETA DE CREDITO DE OTRO BANCO
pfecha 			CHAR(10),			--- FECHA
pmto_tot 		DECIMAL(14,2),	--- MONTO
pmoneda 		CHAR(3),       	--- MONEDA
preferencia 	CHAR(40) )  	--- REFERENCIA
RETURNING CHAR(3),  --- CODIGO DE RETORNO
		  CHAR(4),  --- TERMINACION TARJETA/CUENTA DEBITO
		  CHAR(4),  --- TERMINACION TARJETA CREDITO
		  CHAR(40), --- DESCRIPCION DE OTRO BANCO
          CHAR(53); --- NOMBRE CORTO DEL CLIENTE


    DEFINE sql_err      	INTEGER;
    DEFINE isam_err     	INTEGER;
    DEFINE vcodret1     	CHAR(3);
	DEFINE vtransaccion     SMALLINT;
	DEFINE vproceso         CHAR(1);
    
	DEFINE cTerminacionCgo	CHAR(4);
	DEFINE cTerminacionAbo	CHAR(4);
	DEFINE cDescOtroBanco	CHAR(25);
	DEFINE cNombreCortoCgo	CHAR(53);
	DEFINE cStatusTar		CHAR(1);
	DEFINE cTranAbono  		CHAR(4);
	DEFINE cTranCargoCta	CHAR(4);
	DEFINE cTranAboCargoCta	CHAR(4);
	DEFINE cTranEfectivo	CHAR(4);
	DEFINE cTranaAboEfectivo	CHAR(4);
	DEFINE cNumCte			CHAR(20);
	DEFINE cHora            DATETIME HOUR TO FRACTION;
	DEFINE cCtaConcent		CHAR(20);
	
	DEFINE CodRetVBT		CHAR(5);
	
	DEFINE cCodRetAR		CHAR(5);
	
	DEFINE cCodRetDV		CHAR(5);
	DEFINE cDigitoDV		CHAR(1);

	DEFINE crCodRet      	CHAR(5);
	DEFINE crTrans        	CHAR(4);
	DEFINE crFecha        	DATE;
	DEFINE crSaldo        	DECIMAL(14,2);
	DEFINE crMonto        	DECIMAL(14,2);
	DEFINE cStatusCta		CHAR(1);
	DEFINE cNumCteCgo		CHAR(20);
	DEFINE cTarjeta15c		CHAR(15);
	DEFINE cTarjeta1c		CHAR(1);
	DEFINE vfecha_hoy       DATE;
	DEFINE vhoramax         datetime hour to minute;
	DEFINE vprecio_udi      DECIMAL(14,6); 
	DEFINE vfecha_tpcambio  DATE;
	DEFINE vmonto_udi       DECIMAL(18,6);
	DEFINE vnomaxudis       INTEGER;
	DEFINE vlim_cuenta      DECIMAL(18,6);
	DEFINE vexiste          CHAR(20);
	DEFINE cTarjetaAEconDV	CHAR(16);

    
    LET sql_err  			= 0;
    LET isam_err 			= 0;
    LET vcodret1 			= '000';
	LET vtransaccion		= 0;
	LET vproceso			= "0";
    
	LET cTerminacionCgo		= "";
	LET cTerminacionAbo		= "";
	LET cDescOtroBanco		= "";
	LET cNombreCortoCgo		= "";
	LET cStatusTar			= "";
	LET cTranAbono  		= "";
	LET cTranCargoCta		= "";
	LET cTranAboCargoCta	= "";
	LET cTranEfectivo		= "";
	LET cTranaAboEfectivo	= "";
	LET cNumCte				= "";
	LET cHora        		= CURRENT HOUR TO FRACTION;
	LET cCtaConcent			= "";

	LET CodRetVBT			= "00000";
	
	LET cCodRetAR			= "000";
	
	LET cCodRetDV			= "000";
	LET cDigitoDV			= "";
	
	LET crCodRet      		= "000";
	LET crTrans        		= "";
	LET crFecha        		= DATE(1);
	LET crSaldo        		= 0.0;
	LET crMonto        		= 0.0;
	LET cStatusCta			= "";
	LET cNumCteCgo			= "";
	LET cTarjeta15c			= "";
	LET cTarjeta1c			= "";
	LET vfecha_hoy      = '';
	LET vhoramax        = '';
	LET vprecio_udi     = 0.00;
	LET vfecha_tpcambio = '';
	LET vmonto_udi      = 0.00;
	LET vnomaxudis      = 0;
	LET vlim_cuenta     = 0.00;
	LET vexiste         = '';
	LET cTarjetaAEconDV	= "";
	

    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_pagotdc_otrobanco.out";
    --SET DEBUG FILE TO "/informix/moha/corresp_pagotdc_otrobanco.out";
    --TRACE ON;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_pagotdc_otrobanco.err";
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
            RETURN vcodret1, cTerminacionCgo, cTerminacionAbo , cDescOtroBanco, cNombreCortoCgo;
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
	

	
	-- OBTIENE LA TRANSACCION DE PAGO DE TDC DE OTRO BANCO EN EFECTIVO (CARGO)
	SELECT TRIM(valor)
	INTO cTranEfectivo
	FROM bdicheq: "informix".sc_param
	WHERE empresa = "001"
	AND codparam = "pagotdcotrobcoefec";
	
	-- OBTIENE LA TRANSACCION PARA EL ABONO EN CTA EJE DE PAGO DE TDC DE OTRO BANCO EN EFECTIVO (CARGO)
	SELECT TRIM(valor)
	INTO cTranaAboEfectivo
	FROM bdicheq: "informix".sc_param
	WHERE empresa = "001"
	AND codparam = "abotdcotrobcoefec";
	
	-- OBTIENE LA TRANSACCION DE PAGO DE TDC DE OTRO BANCO A CUENTA EFECTIVA (CARGO)
	SELECT TRIM(valor)
	INTO cTranCargoCta
	FROM bdicheq: "informix".sc_param
	WHERE empresa = "001"
	AND codparam = "pagotdcotrobcocta";
	
	-- OBTIENE LA TRANSACCION PARA EL ABONO EN CTA EJE DE PAGO DE TDC DE OTRO BANCO A CUENTA EFECTIVA (CARGO)
	SELECT TRIM(valor)
	INTO cTranAboCargoCta
	FROM bdicheq: "informix".sc_param
	WHERE empresa = "001"
	AND codparam = "abotdcotrobcocta";
	
	-- OBTIENE LA CUENTA PARA EL ABONO EN CTA EJE DE PAGO DE TDC DE OTRO BANCO
	SELECT TRIM(valor) 
	INTO cCtaConcent 
	FROM bdisac: "informix".sac_param 
	where cod_param = '33009';

    IF (pmodopago IS NULL OR pmodopago NOT IN ('E','C')) OR
	   (pc_costos IS NULL OR pc_costos = '') OR
       (pusuario IS NULL OR pusuario = '' OR LENGTH(pusuario) <> 8) OR
       (pfolio IS NULL OR pfolio = '' OR LENGTH(pfolio) <> 16) OR
       (pnum_cuenta = '' AND pnum_tarjdeb = '' AND pmodopago = 'C') OR
	   (pnum_tarjcred IS NULL OR pnum_tarjcred = '') OR
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
        RETURN vcodret1, cTerminacionCgo, cTerminacionAbo , cDescOtroBanco, cNombreCortoCgo;
    END IF;
	
	---RSV
	IF SUBSTR(pnum_cuenta, 1, 2) = '11' THEN
		IF vtransaccion = 1 THEN
			ROLLBACK WORK;
			BEGIN WORK;
		ELSE
			ROLLBACK WORK;
		END IF;
		LET vcodret1 = '100';
		RETURN vcodret1, cTerminacionCgo, cTerminacionAbo , cDescOtroBanco, cNombreCortoCgo;
	END IF;
	---RSV
	
	LET pmto_tot = pmto_tot / 100;
    
    IF LENGTH(pmoneda) = 03 THEN
        LET pmoneda = pmoneda[2,3]; 
    END IF;
	
	IF LENGTH(pnum_tarjcred) = 15 THEN  --// VALIDA QUE ES AMERICAN EXPRESS
		LET cTarjetaAEconDV =  "0" || pnum_tarjcred;
		LET cTarjeta15c	= SUBSTR(cTarjetaAEconDV,1,15);
		LET cTarjeta1c = SUBSTR(cTarjetaAEconDV,16,1);
	ELSE  --// TODAS LAS TARJETAS BANAMEX, BANCOMER, ETC.
		LET cTarjeta15c	= SUBSTR(pnum_tarjcred,1,15);
		LET cTarjeta1c = SUBSTR(pnum_tarjcred,16,1);	
	END IF
	
	-- VALIDA EL DIGITO VERIFICADOR DE LA TARJETA DE CREDITO
	EXECUTE PROCEDURE bdicheq:"informix".digver10(cTarjeta15c)
	INTO cCodRetDV, cDigitoDV;
	IF cCodRetDV::SMALLINT <> 0 THEN
		IF vtransaccion = 1 THEN
			ROLLBACK WORK;
			BEGIN WORK;
		ELSE
			ROLLBACK WORK;
		END IF;
		LET vcodret1 = "999";
		RETURN vcodret1, cTerminacionCgo, cTerminacionAbo , cDescOtroBanco, cNombreCortoCgo;
	ELSE
		IF cTarjeta1c <> cDigitoDV THEN
			IF vtransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			LET vcodret1 = "060";
			RETURN vcodret1, cTerminacionCgo, cTerminacionAbo , cDescOtroBanco, cNombreCortoCgo;
		END IF
	END IF
	
	--// VALIDA EL BIN DE LA TARJETA Y OBTIENE EL NOMBRE DEL BANCO FORANEO
	EXECUTE PROCEDURE bdicheq: "informix".sp_validarbintarjeta(pnum_tarjcred)
	INTO CodRetVBT, cDescOtroBanco;
	IF CodRetVBT::SMALLINT < 0 THEN
		IF vtransaccion = 1 THEN
			ROLLBACK WORK;
			BEGIN WORK;
		ELSE
			ROLLBACK WORK;
		END IF;
		LET vcodret1 = "999";
		RETURN vcodret1, cTerminacionCgo, cTerminacionAbo , cDescOtroBanco, cNombreCortoCgo;
	ELIF CodRetVBT::SMALLINT > 0 THEN
		IF CodRetVBT::SMALLINT = 58 THEN
			IF vtransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			LET vcodret1 = "058";
			RETURN vcodret1, cTerminacionCgo, cTerminacionAbo , cDescOtroBanco, cNombreCortoCgo;
		ELIF CodRetVBT::SMALLINT = 59 THEN
			IF vtransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			LET vcodret1 = "059";
			RETURN vcodret1, cTerminacionCgo, cTerminacionAbo , cDescOtroBanco, cNombreCortoCgo;
		END IF
	END IF
	
	IF pmodopago = "C" THEN	
		-- // OBTIENE DATOS DE LA CUENTA DESTINO DE CHEQUES
		IF pnum_cuenta is null OR pnum_cuenta = '' THEN
			SELECT cuenta, status_tar
			  INTO pnum_cuenta, cStatusTar
			  FROM bdicheq:"informix".sc_tarjeta
			 WHERE empresa = '001'
			   AND num_tarjeta = pnum_tarjdeb;
			   
			IF cStatusTar <> 'A' THEN
				IF vtransaccion = 1 THEN
					ROLLBACK WORK;
					BEGIN WORK;
				ELSE
					ROLLBACK WORK;
				END IF;
				LET vcodret1 = '009';
				RETURN vcodret1, cTerminacionCgo, cTerminacionAbo , cDescOtroBanco, cNombreCortoCgo;
			END IF;
			
			SELECT num_cte
			INTO cNumCte
			FROM bdicheq:"informix".sc_maechq 
			WHERE empresa = '001' 
			AND cuenta = pnum_cuenta;
			
			LET cTerminacionCgo = SUBSTR(pnum_tarjdeb,13,4);
			LET preferencia = pnum_tarjdeb;
		ELSE
			SELECT status_cta, num_cte
			INTO cStatusCta, cNumCte
			FROM bdicheq:"informix".sc_maechq 
			WHERE empresa = '001' 
			AND cuenta = pnum_cuenta;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				IF vtransaccion = 1 THEN
					ROLLBACK WORK;
					BEGIN WORK;
				ELSE
					ROLLBACK WORK;
				END IF;
				LET vcodret1 = "100";
				RETURN vcodret1, cTerminacionCgo, cTerminacionAbo , cDescOtroBanco, cNombreCortoCgo;
			END IF
			
			IF cStatusCta <> '1' THEN
				IF vtransaccion = 1 THEN
					ROLLBACK WORK;
					BEGIN WORK;
				ELSE
					ROLLBACK WORK;
				END IF;
				LET vcodret1 = '009';
				RETURN vcodret1, cTerminacionCgo, cTerminacionAbo , cDescOtroBanco, cNombreCortoCgo;
			END IF;
			
			LET cTerminacionCgo = SUBSTR(pnum_cuenta,8,4);
			LET preferencia = pnum_cuenta;
		END IF;
		
		IF SUBSTR(pnum_cuenta, 1, 2) = '80' THEN
			IF vtransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			LET vcodret1 = '200';
			RETURN vcodret1, cTerminacionCgo, cTerminacionAbo , cDescOtroBanco, cNombreCortoCgo;
		END IF;
		
	END IF

	LET cTerminacionAbo = SUBSTR(pnum_tarjcred,13,4);	
	LET cNumCte = NVL(cNumCte,'');
	
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

    -- // OBTIENE EL VALOR MAXIMO DE UDIS PARA CAPTACION
    SELECT {+INDEX(bdicheq:"informix".sc_param_corresp idx_paramcorresp)} valor
      INTO vnomaxudis
      FROM bdicheq:"informix".sc_param_corresp
     WHERE codparam = 'NUMAXUDISPAGTDCOBCO'
       AND empresa = '001';
       
    -- // SUMA EL MONTO DE LA TRANSACCION AL ACUMULADO DE LA CUENTA
    LET vlim_cuenta = vmonto_udi;
    
    -- // VALIDA QUE EL ACUMULADO DE LA CUENTA NO REBASE EL LIMITE PERMITIDO
    IF vlim_cuenta > vnomaxudis THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '002';
        RETURN vcodret1, cTerminacionCgo, cTerminacionAbo , cDescOtroBanco, cNombreCortoCgo;
    END IF;
	
	-- VALIDA SI EL MODO DE PAGO ES CON CARGO A CUENTA
	IF pmodopago = "C" THEN		
		---Se aplica cargo por el importe operacion de Pago InterBancario
		EXECUTE PROCEDURE bdicheq:"informix".cargo_ref ("001", pc_costos, pusuario, cTranCargoCta, "", pfolio, pnum_cuenta, 0, pmto_tot,  pmoneda, pnum_tarjcred, "", "")
		INTO crCodRet, crTrans, crFecha, crSaldo, crMonto;
		IF crCodRet::INTEGER <> 0 THEN
			IF vTransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			IF crCodRet::INTEGER = 400 THEN
				LET vcodret1 = "010";
			ELSE
				LET vcodret1 = "999";
			END IF
			RETURN vcodret1, cTerminacionCgo, cTerminacionAbo , cDescOtroBanco, cNombreCortoCgo;
		END IF
		
		-- // OBTIENE NOMBRE CORTO DEL CLIENTE
		SELECT TRIM(nombre1)||' '||TRIM(apell_paterno)
		INTO cNombreCortoCgo
		FROM bdinteg:"informix".si_cliente
		WHERE numcte = cNumCte;
		
		LET cNombreCortoCgo = RPAD(cNombreCortoCgo, 53, " ");
		
		LET cTranAbono = cTranAboCargoCta;			
	ELIF pmodopago = "E" THEN
		/*
		INSERT INTO bdicheq: "informix".sc_movdia (num_serial, folio_suc, sucursal, usuario, fech_alt, fech_val, fech_hor, transacc, suc_cuen, producto, empresa, cuenta, causa_dev, num_cheq, monto_tot, firme, en_sbc, remesas, dias_ret, cancelad, edo_cta, sdo_cuenta, transacc_suc, referencia, tasa_aplicada, num_tarjeta, usuautoriza, referencia_23)
		VALUES(0, pfolio, pc_costos, pusuario, pfecha, pfecha, cHora, cTranEfectivo, "0000", "0000", "001", "", " ", 0, 0, 0, 0, 0, 0, "", "", "", "", preferencia, 0, "", pusuario, "");
		*/
		LET cTranAbono = cTranaAboEfectivo;
	END IF
	
	-- // APLICA TRANSACCION DE ABONO EN LA CUENTA DE DEBITO
	EXECUTE PROCEDURE bdicheq: "informix".abono_ref ("001", pc_costos, pusuario, cTranAbono, "0000", pfolio, cCtaConcent, 0, pmto_tot, pmto_tot, 0, 0, 0, pmoneda, pnum_tarjcred, '0', '')
	INTO cCodRetAR;
	IF cCodRetAR::INTEGER = 0 THEN  
		-- // INICIALIZA BANDERA DE CARGO EXITOSO
		LET vproceso = '1';
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
		
		RETURN vcodret1, cTerminacionCgo, cTerminacionAbo , cDescOtroBanco, cNombreCortoCgo;
	END IF
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
    
    RETURN vcodret1, cTerminacionCgo, cTerminacionAbo , cDescOtroBanco, cNombreCortoCgo;
    
    END;

END PROCEDURE;