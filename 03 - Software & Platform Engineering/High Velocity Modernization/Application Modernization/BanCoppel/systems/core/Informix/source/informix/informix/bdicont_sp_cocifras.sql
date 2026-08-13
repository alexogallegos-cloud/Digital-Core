CREATE PROCEDURE "informix".sp_cocifras(p_sempresa CHAR(3), p_sfecha CHAR(10), p_susuario CHAR(8))

RETURNING CHAR(3), CHAR (30), CHAR(4), MONEY(18,2), CHAR(1), CHAR(2), CHAR(30), CHAR(8), CHAR(45), CHAR(40), DATE,
          CHAR(4), CHAR(40), CHAR(3), CHAR(40);

    DEFINE v_sempresa           CHAR(30);
    DEFINE v_scmayor            CHAR(4);
    DEFINE v_imonto             MONEY(18,2);    
    DEFINE v_snaturaleza        CHAR(1);
    DEFINE v_idivisa            CHAR(2);
    DEFINE v_smoneda            CHAR(30);
    DEFINE v_susuario           CHAR(8);
    DEFINE v_snombre            CHAR(45);
    DEFINE v_sgerente           CHAR(40);
    DEFINE v_dfecha_captura     DATE;
    DEFINE v_sccosto_orig       CHAR(4);
    DEFINE v_snombrecc_orig     CHAR(40);
    DEFINE v_sregional          CHAR(3);
    DEFINE v_snombrereg         CHAR(40);
    DEFINE v_senl_cc_mayor      CHAR(4);
	DEFINE vfecha_cont  	   	DATE;

    DEFINE v_dfechanueva        DATE;
    DEFINE v_splaza             CHAR(3);

    --SET DEBUG FILE TO "/tmp/sp_cocifras.out";                                                                                               
    --TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    BEGIN

        IF NVL(p_susuario, '') = '' THEN
            LET p_susuario = NULL;
        END IF;

		SELECT fecha_hoy 
		  INTO vfecha_cont
          FROM bdicont:co_fechas;

        SELECT razon_social
        INTO v_sempresa
        FROM bdinteg:si_empresas
        WHERE empresa = p_sempresa;

        SELECT TRIM(enl_cc_mayor)
        INTO v_senl_cc_mayor
        FROM bdicont:co_param
        WHERE empresa = p_sempresa;

        LET v_dfechanueva = p_sfecha::DATE;

	    FOREACH
	        SELECT ccmayor, sum(monto), naturaleza, moneda, usuario, fecha_captura
	        INTO v_scmayor, v_imonto, v_snaturaleza, v_idivisa, v_susuario, v_dfecha_captura
	        FROM bdicont:co_detpol
	        WHERE usuario = p_susuario 
			  AND control_poliza > 0
			  AND fecha_captura = v_dfechanueva 
			  AND secuencia > 0
	          AND empresa = p_sempresa
	          AND ccmayor <> v_senl_cc_mayor
	          AND usuario <> ccosto_orig
	        GROUP BY empresa, ccmayor, moneda, naturaleza, usuario, fecha_captura
	        ORDER BY fecha_captura, moneda, usuario, ccmayor

	        SELECT descripcion INTO v_smoneda FROM bdinteg:si_divisas WHERE divisa = v_idivisa AND empresa = p_sempresa;
	        SELECT NVL(nombre,''), sucursal INTO v_snombre, v_sccosto_orig FROM bdinteg:si_ejecut WHERE ejecutivo = v_susuario AND empresa = p_sempresa;
	        SELECT gerente, nombre, plaza INTO v_sgerente, v_snombrecc_orig, v_splaza FROM bdinteg:si_sucursales WHERE sucursal= v_sccosto_orig AND empresa = p_sempresa;
	        SELECT regional INTO v_sregional FROM bdinteg:si_plazas WHERE plaza = v_splaza AND empresa = p_sempresa;
	        SELECT nombre INTO v_snombrereg FROM bdinteg:si_regional WHERE regional = v_sregional AND empresa = p_sempresa;

	        IF v_snombre IS NULL THEN
	            SELECT nombre INTO v_snombre FROM bdinteg:si_sucursales WHERE sucursal = v_susuario AND empresa = p_sempresa;
	        END IF
	        
	        RETURN p_sempresa, v_sempresa, v_scmayor, v_imonto, v_snaturaleza, v_idivisa, v_smoneda, v_susuario, v_snombre, v_sgerente, v_dfecha_captura,
	        v_sccosto_orig, v_snombrecc_orig, v_sregional, v_snombrereg WITH RESUME;

	    END FOREACH;

	    FOREACH
	        SELECT ccmayor, sum(monto), naturaleza, moneda, usuario, ccosto_orig, fecha_captura
	        INTO v_scmayor, v_imonto, v_snaturaleza, v_idivisa, v_susuario,v_sccosto_orig, v_dfecha_captura
	        FROM bdicont:co_mensual
	        WHERE usuario = p_susuario 
			  AND control_poliza > 0
			  AND fecha_captura = v_dfechanueva 
			  AND secuencia > 0
	          AND empresa = p_sempresa
	          AND ccmayor <> v_senl_cc_mayor
			  AND usuario <> ccosto_orig

	        GROUP BY empresa, ccmayor, moneda, naturaleza, usuario, ccosto_orig, fecha_captura
	        ORDER BY fecha_captura, moneda, usuario, ccmayor

	        SELECT descripcion INTO v_smoneda FROM bdinteg:si_divisas WHERE divisa = v_idivisa AND empresa = p_sempresa;
	        SELECT gerente, nombre, plaza INTO v_sgerente, v_snombrecc_orig, v_splaza FROM bdinteg:si_sucursales WHERE sucursal= v_sccosto_orig AND empresa = p_sempresa;
	        SELECT regional INTO v_sregional FROM bdinteg:si_plazas WHERE plaza = v_splaza AND empresa = p_sempresa;
	        SELECT nombre INTO v_snombrereg FROM bdinteg:si_regional WHERE regional = v_sregional AND empresa = p_sempresa;
	        SELECT nombre INTO v_snombre FROM bdinteg:si_ejecut WHERE ejecutivo = v_susuario AND empresa = p_sempresa;

	        IF v_snombre IS NULL THEN
	             SELECT nombre INTO v_snombre FROM bdinteg:si_sucursales WHERE sucursal = v_susuario AND empresa = p_sempresa;
	        END IF
	        
	        RETURN p_sempresa, v_sempresa, v_scmayor, v_imonto, v_snaturaleza, v_idivisa, v_smoneda, v_susuario, v_snombre, v_sgerente, v_dfecha_captura,
	               v_sccosto_orig, v_snombrecc_orig, v_sregional, v_snombrereg WITH RESUME;
	    END FOREACH;

	    FOREACH
	        SELECT ccmayor, sum(monto), naturaleza, moneda, usuario, ccosto_orig, fecha_captura
	        INTO v_scmayor, v_imonto, v_snaturaleza, v_idivisa, v_susuario,v_sccosto_orig, v_dfecha_captura
	        FROM bdicont:co_historico
	        WHERE usuario = p_susuario 
			  AND control_poliza > 0
			  AND fecha_captura = v_dfechanueva 
			  AND secuencia > 0
	          AND empresa = p_sempresa
	          AND ccmayor <> v_senl_cc_mayor
	          AND usuario <> ccosto_orig

	        GROUP BY empresa, ccmayor, moneda, naturaleza, usuario, ccosto_orig, fecha_captura
	        ORDER BY fecha_captura, moneda, usuario, ccmayor

	        SELECT descripcion INTO v_smoneda FROM bdinteg:si_divisas WHERE divisa = v_idivisa AND empresa = p_sempresa;
	        SELECT gerente, nombre, plaza INTO v_sgerente, v_snombrecc_orig, v_splaza FROM bdinteg:si_sucursales WHERE sucursal= v_sccosto_orig AND empresa = p_sempresa;
	        SELECT regional INTO v_sregional FROM bdinteg:si_plazas WHERE plaza = v_splaza AND empresa = p_sempresa;
	        SELECT nombre INTO v_snombrereg FROM bdinteg:si_regional WHERE regional = v_sregional AND empresa = p_sempresa;
	        SELECT nombre INTO v_snombre FROM bdinteg:si_ejecut WHERE ejecutivo = v_susuario AND empresa = p_sempresa;

	        IF v_snombre IS NULL THEN
	            SELECT nombre INTO v_snombre FROM bdinteg:si_sucursales WHERE sucursal = v_susuario AND empresa = p_sempresa;
	        END IF
	        
	        RETURN p_sempresa, v_sempresa, v_scmayor, v_imonto, v_snaturaleza, v_idivisa, v_smoneda, v_susuario, v_snombre, v_sgerente, v_dfecha_captura,
	               v_sccosto_orig, v_snombrecc_orig, v_sregional, v_snombrereg WITH RESUME;
	    END FOREACH;

    END
END PROCEDURE;