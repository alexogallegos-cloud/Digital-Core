CREATE PROCEDURE "informix".calsdoinvcrec(pempresa char(3))
    RETURNING CHAR(5);

    DEFINE vcodret		CHAR(5);
    DEFINE vsqlerr		INTEGER;
    DEFINE vfecha_hoy		DATE;
    DEFINE vcuenta		CHAR(20);
    DEFINE vsdo_actual		DECIMAL(14,2);
    DEFINE vsdo_nuevo		DECIMAL(14,2);
    DEFINE vint_acum		DECIMAL(14,2);
    DEFINE visr			DECIMAL(14,2);
    DEFINE vintereses		DECIMAL(14,2);
    DEFINE vmonto_apertura	DECIMAL(14,2);
    DEFINE vhoraw       	CHAR(15);
    DEFINE vhora        	DATETIME HOUR TO FRACTION;
    DEFINE vfolio_suc   	CHAR(16);
    DEFINE vsucursal		CHAR(4);
    DEFINE vproducto		CHAR(4);
    DEFINE vstatus		CHAR(1);
    DEFINE vdiferencia		DECIMAL(14,2);
	DEFINE vfecha_operacion	DATE;

    LET vcodret = "000";
    LET vhora = current hour to fraction;
    LET vhoraw = vhora;
    LET vhoraw = vhoraw[1,2]||vhoraw[4,5]||vhoraw[7,8]||vhoraw[10,11];
    LET vfolio_suc = "informix" ||vhoraw[1,8];
	LET vfecha_operacion = TODAY;

    --SET DEBUG FILE TO "/informix/moha/calsdoinvcrec";
    --TRACE ON;

    BEGIN
        ON EXCEPTION SET vsqlerr
            IF vsqlerr <> 0 THEN
                LET vcodret = vsqlerr;
                RETURN vcodret;
            END IF;
   	END EXCEPTION;

	CREATE TEMP TABLE tmp_transacc(cuenta char(20)) WITH NO LOG;

	INSERT INTO tmp_transacc
	SELECT cuenta FROM sc_movhis
	WHERE producto = "1100"
	AND transacc in("3280","0270","0239","0223","0205")
	AND cancelad <> "S"
	AND empresa = pempresa;

	SELECT fecha_hoy
        INTO vfecha_hoy
        FROM sc_fechas
        WHERE empresa = pempresa;

        --******************************************
	--           FOREACH PRINCIPAL
	--******************************************

	FOREACH
	    SELECT chq.cuenta,chq.imp_chq_rem,chq.sdo_actual,
                   chq.sucursal,chq.producto,chq.status_cta
	    INTO vcuenta,vmonto_apertura,vsdo_actual,
                 vsucursal,vproducto,vstatus
	    FROM sc_maechq chq,
                 sc_maenoc noc
	    WHERE chq.cuenta = noc.cuenta
            AND chq.producto = "1100"
	    AND chq.status_cta = "1"
	    AND chq.cuenta NOT IN(SELECT cuenta FROM tmp_transacc)
            AND day(noc.fecha_alta) = "09"

	    IF vsdo_actual is NULL THEN
	        LET vsdo_actual = 0.00;
	    END IF

	    LET vintereses = 0.00;
	    LET vsdo_nuevo = 0.00;
            LET vint_acum  = 0.00;
            LET visr       = 0.00;

	    SELECT SUM(int_acum), SUM(isr)
	    INTO vint_acum, visr
	    FROM sc_tasa_var_hist
	    WHERE empresa = pempresa
	    AND cuenta = vcuenta
	    AND inicio_periodo < vfecha_hoy
	    AND tipo_tasa in("M","P");

            IF vint_acum is NULL THEN
	        LET vint_acum = 0.00;
	    END IF

	    IF visr is NULL THEN
	        LET visr = 0.00;
	    END IF

	    LET vintereses = vint_acum - visr;
            LET vint_acum  = 0.00;
            LET visr       = 0.00;

            SELECT SUM(int_acum), SUM(isr)
	    INTO vint_acum, visr
	    FROM sc_tasa_variable
	    WHERE empresa = pempresa
	    AND cuenta = vcuenta
	    AND inicio_periodo < vfecha_hoy
	    AND tipo_tasa in("M","P")
	    AND fin_periodo < vfecha_hoy;

	    IF vint_acum is NULL THEN
	        LET vint_acum = 0.00;
	    END IF

	    IF visr is NULL THEN
	        LET visr = 0.00;
	    END IF

	    LET vintereses = vintereses + (vint_acum - visr);

	    LET vsdo_nuevo = vmonto_apertura + vintereses;
            LET vdiferencia = 0.00;

	    IF vsdo_nuevo <> vsdo_actual THEN
                LET vdiferencia = vsdo_nuevo - vsdo_actual;

	        IF vdiferencia > 0.00 THEN
	            INSERT INTO sc_movdia VALUES(0, vfolio_suc, vsucursal,
		        "informix", vfecha_hoy, vfecha_hoy, vhora, "3276",
			vsucursal, vproducto, pempresa,vcuenta, "", 0, 
			vdiferencia, vdiferencia, 0, 0, 0, "", vstatus,
		        vsdo_actual, "0000", "", 0, "", "", "", vfecha_operacion);

	            INSERT INTO sc_movdia VALUES(0, vfolio_suc, vsucursal,
		        "informix", vfecha_hoy, vfecha_hoy, vhora, "3381",
			vsucursal, vproducto, pempresa, vcuenta, "", 0,
			vdiferencia, vdiferencia, 0, 0, 0, "", vstatus,
		    	vsdo_actual, "0000", "", 0, "", "", "", vfecha_operacion);
                END IF

	        UPDATE sc_maechq
	        SET sdo_actual = vsdo_nuevo
	        WHERE cuenta = vcuenta;
	    END IF
	END FOREACH
	DROP TABLE tmp_transacc;
    END
    RETURN vcodret;
END PROCEDURE;