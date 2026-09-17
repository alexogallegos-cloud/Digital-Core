CREATE PROCEDURE "informix".mod_movsatm(pempresa CHAR(3))

  RETURNING CHAR(5), INTEGER;

    -- // DECLARACION DE VARIABLES

    DEFINE vcodret     		CHAR(5);
    DEFINE sql_err     		INTEGER;
    DEFINE vprimera	 	INTEGER;
    DEFINE vcontador		INTEGER;
    DEFINE vcuantos  		INTEGER;

    DEFINE vcuenta		CHAR(20);
    DEFINE vstatus_cta		CHAR(1);
    DEFINE vsdo_actual		MONEY(14,2);
    DEFINE vfolio_suc		CHAR(16);
    DEFINE vsucursal		CHAR(4);
    DEFINE vusuario		CHAR(8);
    DEFINE vtransacc		CHAR(4);
    DEFINE vsuc_cuenta		CHAR(4);
    DEFINE vproducto		CHAR(4);
    DEFINE vmonto_tot		MONEY(14,2);
    DEFINE vtransacc_suc	CHAR(4);
    DEFINE vreferencia		CHAR(40);
    DEFINE vnum_tarjeta		CHAR(16);
    DEFINE vhora		CHAR(15);
    DEFINE vfolio		CHAR(20);
    DEFINE vmonto_transacc	MONEY(14,2);

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

    -- SET DEBUG FILE TO "./mod_movsatm.out";
    -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT {+ INDEX(intercard:movimiento idx_movimientonew1a)} *
      FROM intercard:movimiento
     WHERE substr(numtarjeta,1,4) = "4008"
       AND movconciliado = "F"
       AND fechahorainauth >= "2009-07-02 00:00:01"
       AND fechahorainauth <= "2009-07-02 21:00:00"
       AND codigoiso = "00"
       AND codtran = "01"
       AND movreversado = "F"
    INTO TEMP tmp_movimiento WITH NO LOG;
    CREATE INDEX idx_movto ON tmp_movimiento(numtarjeta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_movimiento;

    -- ********************* FOREACH PRINCIPAL ***********************

    FOREACH WITH HOLD
        SELECT his.folio_suc, his.sucursal, his.usuario, his.transacc, 
	       his.suc_cuen, his.producto, his.cuenta, his.monto_tot, 
               his.transacc_suc, his.referencia, his.num_tarjeta
	  INTO vfolio_suc, vsucursal, vusuario, vtransacc, 
	       vsuc_cuenta, vproducto, vcuenta, vmonto_tot, 
	       vtransacc_suc, vreferencia, vnum_tarjeta
	  FROM tmp_movimiento mov,
	       bdicheq:sc_movhis his
	 WHERE mov.numtarjeta = his.num_tarjeta
	   AND SUBSTR(mov.secuencia,2,6) = SUBSTR(his.folio_suc,10,6)
	   AND his.empresa = pempresa
	   AND his.cuenta IS NOT NULL
	   AND his.fech_alt = "07022009"
	   AND his.cancelad <> "S"
	   
 	IF (vcontador = -1) THEN
            BEGIN WORK;
            LET vcontador = 0;
        END IF;

	SELECT status_cta, sdo_actual
	  INTO vstatus_cta, vsdo_actual
	  FROM bdicheq:sc_maechq
	 WHERE empresa = pempresa
	   AND cuenta = vcuenta;
	     
	    LET vhora = current hour to fraction;
            LET vfolio = "informix" || vhora[1,2] || 
                                       vhora[4,5] ||
				       vhora[7,8] ||
				       vhora[10,11];

	    LET vmonto_transacc = vmonto_tot * -1;

	    INSERT INTO sc_movdia
            VALUES (0, vfolio, vsucursal, "informix", "07032009",
                    "07032009", vhora, vtransacc, vsuc_cuenta,
                    vproducto, pempresa, vcuenta, "", 0, vmonto_transacc,
                    vmonto_transacc, 0, 0, 0, "", vstatus_cta,
                    vsdo_actual, "0000", " ", 0.000000, vnum_tarjeta,"","");

	    UPDATE bdicheq:sc_maechq
	       SET sdo_actual = sdo_actual + vmonto_tot
	     WHERE empresa = pempresa
	       AND cuenta = vcuenta;	

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