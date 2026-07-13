CREATE PROCEDURE "informix".calc_interes(pempresa CHAR(3))

  RETURNING CHAR(5), INTEGER;

    -- // DECLARACION DE VARIABLES

    DEFINE vcodret     		CHAR(5);
    DEFINE sql_err     		INTEGER;
    DEFINE vprimera	 	INTEGER;
    DEFINE vcontador		INTEGER;
    DEFINE vcuantos  		INTEGER;

    DEFINE vcuenta              CHAR(20);
    DEFINE vacum_sdo_pos	MONEY(14,2);
    DEFINE vdia_sdo_pos		INTEGER;
    DEFINE vsdo_promedio	MONEY(14,2);
    DEFINE vcalc_int		MONEY(14,2);
    DEFINE vhora		CHAR(15);
    DEFINE vfolio		CHAR(20);
    DEFINE vsucursal		CHAR(4);
    DEFINE vproducto		CHAR(4);
    DEFINE vstatus_cta		CHAR(1);
    DEFINE vsdo_actual		MONEY(14,2);
    DEFINE vtotintpag		MONEY(14,2);
    DEFINE vpremio		MONEY(14,2);
    DEFINE vtasa		DECIMAL(9,6);
    DEFINE vmaxsec 		SMALLINT;
    DEFINE vtarjeta		CHAR(16);
    DEFINE vintereses		MONEY(14,2);

    -- // INICIALIZACION DE VARIABLES

    LET vcodret	  = "000";
    LET sql_err	  = 0;
    LET vprimera  = 0;
    LET vcontador = -1;
    LET vcuantos  = 0;

    BEGIN

    ON EXCEPTION
	SET sql_err
	IF sql_err <> 0 THEN
	    LET vcodret = sql_err;
            RETURN vcodret, vcuantos;
	END IF;
    END EXCEPTION;

    -- SET DEBUG FILE TO "./calc_interes.out";
    -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- ********************* FOREACH PRINCIPAL ***********************

    FOREACH WITH HOLD
        SELECT {+INDEX(sc_maenoc ix137_1)} noc.cuenta, 
	       chq.sucursal, chq.producto, chq.status_cta, chq.sdo_actual,
	       his.acum_sdo_pos, his.dia_sdo_pos, his.tasabruta, his.totintpag
	  INTO vcuenta, 
	       vsucursal, vproducto, vstatus_cta, vsdo_actual,
	       vacum_sdo_pos, vdia_sdo_pos, vtasa, vtotintpag
          FROM sc_maenoc noc,
	       sc_maechq chq,
	       sc_maehis his
         WHERE noc.empresa = chq.empresa
           AND noc.cuenta = chq.cuenta
	   AND noc.empresa = his.empresa
	   AND noc.cuenta = his.cuenta
	   AND chq.empresa = his.empresa
	   AND chq.cuenta = his.cuenta
           AND noc.empresa = pempresa
	   AND DAY(noc.fecha_alta) = "02"
	   AND noc.fecha_alta = "07022009"
	   AND his.fechafin = "07012009"
	   AND chq.status_cta IN("1","3")
	   AND (noc.fecha_mod = "" OR noc.fecha_mod is null)
           AND chq.producto = "1100"

        LET vhora = current hour to fraction;
        LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];

        LET vsdo_promedio = 0.00;
        LET vcalc_int     = 0.00;

        IF (vcontador = -1) THEN
            BEGIN WORK;
            LET vcontador = 0;
        END IF;

        LET vsdo_promedio = vacum_sdo_pos / vdia_sdo_pos;

	IF (vproducto = "2000" OR vproducto = "1400" OR 
            vproducto = "1500" OR vproducto = "1700") THEN

    	    IF (vsdo_promedio <= 200.00) THEN

	        LET vtasa = 0.00;
	        LET vcalc_int = ((vacum_sdo_pos / vdia_sdo_pos) * vtasa) * vdia_sdo_pos / 360;

	    ELIF (vsdo_promedio >= 200.01 AND vsdo_promedio <= 1000.00) THEN

	        LET vtasa = 0.02;
	        LET vcalc_int = ((vacum_sdo_pos / vdia_sdo_pos) * vtasa) * vdia_sdo_pos / 360;

	    ELIF (vsdo_promedio >= 1000.01) THEN

	        LET vtasa = 0.04;
	        LET vcalc_int = ((vacum_sdo_pos / vdia_sdo_pos) * vtasa) * vdia_sdo_pos / 360;

	    END IF;

        ELIF (vproducto = "1100" OR vproducto = "1200" OR
              vproducto = "1300" OR vproducto = "1600" OR
              vproducto = "1800") THEN

	    IF (vtasa IS NULL OR vtasa = "") THEN

		IF (vproducto = "1100") THEN
		    SELECT valor_tasa 
		      INTO vtasa
		      FROM sc_tasa_variable
		     WHERE empresa = pempresa
		       AND cuenta = vcuenta
		       AND vfecha_ant BETWEEN inicio_periodo AND fin_periodo
		       AND tipo_tasa = "M";
		ELIF (vproducto = "1200") THEN
		    LET vtasa = 0.0472;
		ELIF (vproducto = "1300") THEN
		    LET vtasa = 0.085;
		ELIF (vproducto = "1600") THEN
		    LET vtasa = 0.000;
		ELIF (vproducto = "1800") THEN
		    LET vtasa = 0.075;
		END IF

	    END IF

	    LET vcalc_int = ((vacum_sdo_pos / vdia_sdo_pos) * vtasa) * vdia_sdo_pos / 360;

        END IF;

	IF (vcalc_int < vtotintpag AND vproducto = "1100") THEN

	    SELECT MAX(secuencia)
              INTO vmaxsec
              FROM sc_tarjeta
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND tipo_tarjeta = "T";

            SELECT num_tarjeta
              INTO vtarjeta
              FROM sc_tarjeta
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND secuencia = vmaxsec;

	    SELECT int_acum
	      INTO vpremio
	      FROM sc_tasa_var_hist
	     WHERE empresa = "001"
	       AND cuenta = vcuenta
	       AND tipo_tasa = "P";

	    LET vtotintpag = vtotintpag - vpremio;
            LET vintereses = vcalc_int - vtotintpag;

	    INSERT INTO sc_movdia
            VALUES (0, vfolio, vsucursal, "informix", "07022009",
                    "07022009", vhora, "3276", vsucursal,
                    vproducto, pempresa, vcuenta, "", 0, vintereses,
                    vintereses, 0, 0, 0, "", vstatus_cta,
                    vsdo_actual, "0000", " ", vtasa,vtarjeta,"","");

	    UPDATE sc_maechq
	       SET sdo_actual = sdo_actual + vintereses
	     WHERE empresa = pempresa
	       AND cuenta = vcuenta;

	    UPDATE sc_maehis
	       SET totintpag = vpremio + vcalc_int
	     WHERE empresa = pempresa
	       AND cuenta = vcuenta
               AND fechafin = "07012009";

        ELIF (vcalc_int > vtotintpag) THEN

	    SELECT MAX(secuencia)
              INTO vmaxsec
              FROM sc_tarjeta
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND tipo_tarjeta = "T";

            SELECT num_tarjeta
              INTO vtarjeta
              FROM sc_tarjeta
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND secuencia = vmaxsec;

            LET vintereses = vcalc_int - vtotintpag;

	    INSERT INTO sc_movdia
            VALUES (0, vfolio, vsucursal, "informix", "07022009",
                    "07022009", vhora, "3276", vsucursal,
                    vproducto, pempresa, vcuenta, "", 0, vintereses,
                    vintereses, 0, 0, 0, "", vstatus_cta,
                    vsdo_actual, "0000", " ", vtasa,vtarjeta,"","");

	    UPDATE sc_maechq
	       SET sdo_actual = sdo_actual + vintereses
	     WHERE empresa = pempresa
	       AND cuenta = vcuenta;

	    UPDATE sc_maehis
	       SET totintpag = vcalc_int
	     WHERE empresa = pempresa
	       AND cuenta = vcuenta
               AND fechafin = "07012009";

	END IF

        LET vcontador = vcontador + 1;

        IF (vcontador >= 50000) THEN
            LET vcuantos = vcuantos + vcontador;
	    LET vcontador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;

    END FOREACH;

    -- ************************* FOREACH PRINCIPAL *************************

    LET vcuantos = vcuantos + vcontador;

    IF (vcontador > 0) THEN
        COMMIT WORK;
    END IF;

    END;

    RETURN vcodret, vcuantos;

END PROCEDURE;