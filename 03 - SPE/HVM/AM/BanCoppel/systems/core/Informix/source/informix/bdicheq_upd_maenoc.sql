CREATE PROCEDURE "informix".upd_maenoc(pempresa CHAR(3))

  RETURNING CHAR(5);

    -- // DECLARACION DE VARIABLES

    DEFINE vcodret     		CHAR(5);
    DEFINE sql_err     		INTEGER;
    DEFINE vprimera	 	INTEGER;
    DEFINE vcontador		INTEGER;
    DEFINE vcuantos  		INTEGER;

    DEFINE vfecha_hoy		DATE;
    DEFINE vcuenta              CHAR(20);
    DEFINE vacum_sdo_pos	MONEY(14,2);
    DEFINE vdia_sdo_pos		INTEGER;
    DEFINE vsdo_promedio	MONEY(14,2);
    DEFINE vacum_sdo_int	MONEY(14,2);

    -- // INICIALIZACION DE VARIABLES

    LET vcodret	= "000";
    LET sql_err	= 0;
    LET vprimera = 0;
    LET vcontador =-1;
    LET vcuantos = 0;

    LET vacum_sdo_pos = 0.00;
    LET vdia_sdo_pos = 0;
    LET vsdo_promedio = 0.00;
    LET vacum_sdo_int = 0.00;

    BEGIN

    ON EXCEPTION
	SET sql_err
	IF sql_err <> 0 THEN
	    LET vcodret = sql_err;
            RETURN vcodret;
	END IF;
    END EXCEPTION;

    -- SET DEBUG FILE TO "./upd_maenoc.out";
    -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;

    -- ********************* FOREACH PRINCIPAL ***********************

    FOREACH WITH HOLD
        SELECT noc.cuenta, noc.acum_sdo_pos, noc.dia_sdo_pos
	  INTO vcuenta, vacum_sdo_pos, vdia_sdo_pos
          FROM sc_maenoc noc,
	       sc_maechq chq
         WHERE noc.empresa = chq.empresa
           AND noc.cuenta = chq.cuenta
	   AND chq.status_cta <> "2"
	   AND chq.producto IN ("2000","1400","1500","1700")
	   AND noc.fecha_alta <> vfecha_hoy

        IF (vcontador = -1) THEN
            BEGIN WORK;
            LET vcontador = 0;
        END IF;

        LET vsdo_promedio = vacum_sdo_pos / vdia_sdo_pos;

	IF (vsdo_promedio <= 200.00) THEN
	
	    LET vacum_sdo_int = ((vacum_sdo_pos / vdia_sdo_pos) * 0) * vdia_sdo_pos / 360;

	END IF;

	IF (vsdo_promedio >= 200.01 AND vsdo_promedio <= 1000.00) THEN
	
	    LET vacum_sdo_int = ((vacum_sdo_pos / vdia_sdo_pos) * 0.02) * vdia_sdo_pos / 360;

	END IF;

	IF (vsdo_promedio >= 1000.01) THEN
	
	    LET vacum_sdo_int = ((vacum_sdo_pos / vdia_sdo_pos) * 0.04) * vdia_sdo_pos / 360;

	END IF;

        UPDATE sc_maenoc
	   SET acum_sdo_int = vacum_sdo_int
	 WHERE empresa = pempresa
	   AND cuenta = vcuenta;

        LET vcontador = vcontador + 1;

        IF (vcontador >= 100000) THEN
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