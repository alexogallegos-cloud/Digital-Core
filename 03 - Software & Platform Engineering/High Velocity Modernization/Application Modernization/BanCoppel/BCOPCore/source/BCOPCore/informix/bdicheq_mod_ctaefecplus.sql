CREATE PROCEDURE "informix".mod_ctaefecplus(pempresa CHAR(3))

  RETURNING CHAR(5);

    -- // DECLARACION DE VARIABLES

    DEFINE vcodret     		CHAR(5);
    DEFINE sql_err     		INTEGER;
    DEFINE vprimera	 	INTEGER;
    DEFINE vcontador		INTEGER;
    DEFINE vcuantos  		INTEGER;

    DEFINE vfecha_hoy		DATE;
    DEFINE vhora		CHAR(15);
    DEFINE vfolio		CHAR(20);
    DEFINE vcuenta              CHAR(20);
    DEFINE vsucursal		CHAR(4);
    DEFINE vproducto		CHAR(4);
    DEFINE vstatus_cta		CHAR(1);
    DEFINE vsdo_actual		MONEY(14,2);
    DEFINE vmaxsec 		SMALLINT;
    DEFINE vtarjeta		CHAR(16);
    DEFINE vacum_sdo_pos	MONEY(14,2);
    DEFINE vacum_sdo_int	MONEY(14,2);
    DEFINE vcalc_int		MONEY(14,2);
    DEFINE vdesprov		MONEY(14,2);
    
    -- // INICIALIZACION DE VARIABLES

    LET vcodret	= "000";
    LET sql_err	= 0;
    LET vprimera = 0;
    LET vcontador =-1;
    LET vcuantos = 0;

    LET vacum_sdo_pos = 0.00;
    LET vacum_sdo_int = 0.00;
        
    BEGIN

    ON EXCEPTION
	SET sql_err
	IF sql_err <> 0 THEN
	    LET vcodret = sql_err;
            RETURN vcodret;
	END IF;
    END EXCEPTION;

    -- SET DEBUG FILE TO "./mod_ctaefecplus.out";
    -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;

    -- ********************* FOREACH PRINCIPAL ***********************

    FOREACH WITH HOLD
        SELECT noc.cuenta, noc.acum_sdo_pos, noc.acum_sdo_int, 
	       chq.sucursal, chq.producto, chq.status_cta, chq.sdo_actual
	  INTO vcuenta, vacum_sdo_pos, vacum_sdo_int,
	       vsucursal, vproducto, vstatus_cta, vsdo_actual
          FROM sc_maenoc noc,
	       sc_maechq chq
         WHERE noc.empresa = chq.empresa
           AND noc.cuenta = chq.cuenta
	   AND chq.status_cta = "1"
	   AND chq.producto IN ("1800")
	   AND noc.acum_sdo_int > 0.00
	   AND noc.fecha_alta <> vfecha_hoy
         AND day(noc.fecha_alta) <> "01"
	   
        IF (vcontador = -1) THEN
            BEGIN WORK;
            LET vcontador = 0;
        END IF;

	LET vhora = current hour to fraction;
        LET vfolio = "informix" || vhora[1,2] ||
		     vhora[4,5] || vhora[7,8] || vhora[10,11];

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


        LET vcalc_int = 0.00;
        LET vdesprov  = 0.00;

	LET vcalc_int = ((vacum_sdo_pos * 0.075) / 360);

	IF (vacum_sdo_int > vcalc_int) THEN
	
	    LET vdesprov = vacum_sdo_int - vcalc_int;

	    INSERT INTO sc_movdia
            VALUES (0, vfolio, vsucursal, "informix", "07012009",
                    "07012009", vhora, "3382", vsucursal,
                    vproducto, pempresa, vcuenta, "", 0, vdesprov,
                    vdesprov, 0, 0, 0, "", vstatus_cta,
                    vsdo_actual, "0000", " ", 7.500000, vtarjeta,"","");

	END IF;

        UPDATE sc_maenoc
	   SET acum_sdo_int = vcalc_int
	 WHERE empresa = pempresa
	   AND cuenta = vcuenta;

        LET vcontador = vcontador + 1;

        IF (vcontador >= 10000) THEN
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

    RETURN vcodret;

END PROCEDURE;