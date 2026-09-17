CREATE PROCEDURE "informix".abona_ctas(pempresa CHAR(3))

  RETURNING CHAR(5), INTEGER;

    -- // DECLARACION DE VARIABLES

    DEFINE vcodret     		CHAR(5);
    DEFINE sql_err     		INTEGER;
    DEFINE vprimera	 	INTEGER;
    DEFINE vcontador		INTEGER;
    DEFINE vcuantos  		INTEGER;

    DEFINE vfecha_hoy		DATE;
    DEFINE vhora		CHAR(15);
    DEFINE vfolio		CHAR(20);
    DEFINE vnum_serial		CHAR(16);
    DEFINE vcuenta              CHAR(20);
    DEFINE vmonto		MONEY(14,2);
    DEFINE vnum_tarjeta		CHAR(40);
    DEFINE vsucursal		CHAR(4);
    DEFINE vproducto		CHAR(4);
    DEFINE vstatus		CHAR(1);
    DEFINE vsdo_actual		MONEY(14,2);
    DEFINE vsdo_cuenta		MONEY(14,2);
    DEFINE vimp_sobregiro	MONEY(14,2);
    DEFINE vmonto_sobregiro	MONEY(14,2);

    -- // INICIALIZACION DE VARIABLES

    LET vcodret	= "000";
    LET sql_err	= 0;
    LET vprimera = 0;
    LET vcontador =-1;
    LET vcuantos = 0;

    BEGIN

    ON EXCEPTION
	SET sql_err
	IF sql_err <> 0 THEN
	    LET vcodret = sql_err;
            RETURN vcodret, vcuantos;
	END IF;
    END EXCEPTION;

    -- SET DEBUG FILE TO "./abona_ctas.out";
    -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;

    -- ********************* FOREACH PRINCIPAL ***********************

    FOREACH WITH HOLD
        SELECT num_serial, cuenta, monto_tot, num_tarjeta
	  INTO vnum_serial, vcuenta, vmonto, vnum_tarjeta
          FROM sc_movhis
	 WHERE transacc = "0219"
           AND fech_alt = "06082009"
           AND referencia = "Cancelacion al movto. del 04/Jun/2009"

        IF (vcontador = -1) THEN
            BEGIN WORK;
            LET vcontador = 0;
        END IF;

	LET vhora = current hour to fraction;
        LET vfolio = "informix" || vhora[1,2] || vhora[4,5] ||
			           vhora[7,8] || vhora[10,11];

	SELECT sucursal, producto, status_cta, sdo_actual, imp_chq_sbg
	  INTO vsucursal, vproducto, vstatus, vsdo_actual, vimp_sobregiro
	  FROM sc_maechq
	 WHERE empresa = pempresa
 	   AND cuenta = vcuenta;

	LET vsdo_cuenta = vmonto;

	IF vimp_sobregiro > 0 THEN
	    IF vmonto >= vimp_sobregiro THEN
		LET vmonto_sobregiro = vimp_sobregiro;
		LET vsdo_cuenta = vmonto - vimp_sobregiro;
		LET vimp_sobregiro = 0;
	    ELSE
	        LET vsdo_cuenta = 0;
		LET vmonto_sobregiro = vmonto;
		LET vimp_sobregiro = vimp_sobregiro - vmonto;
	    END IF;

	    INSERT INTO sc_movdia
            VALUES (0, vfolio, vsucursal, "informix","06092009","06092009",
                    vhora, "3247", vsucursal, vproducto, pempresa, vcuenta, 
		    "", 0, vmonto_sobregiro, vmonto_sobregiro, 0,0,0, "", 
		    vstatus, vsdo_actual, "0000", 
		    "Cancelacion de sobregiro del 04/Jun/2009",
		    0.000000, vnum_tarjeta, " ","");
	END IF;		

	UPDATE sc_maechq
	   SET sdo_actual = sdo_actual + vsdo_cuenta,
	       imp_chq_sbg = vimp_sobregiro
	 WHERE empresa = pempresa
	   AND cuenta = vcuenta;

        LET vcontador = vcontador + 1;

        IF (vcontador >= 1500) THEN
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