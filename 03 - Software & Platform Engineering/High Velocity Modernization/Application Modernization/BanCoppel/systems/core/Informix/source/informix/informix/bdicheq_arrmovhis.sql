CREATE PROCEDURE "informix".arrmovhis(pempresa CHAR(3))
    RETURNING CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret		CHAR(5);
    DEFINE vsqlerr		INTEGER;
    DEFINE vrowid		INTEGER;
    DEFINE vcuenta		CHAR(20);
    DEFINE wcuenta		CHAR(20);
    DEFINE vtransacc		CHAR(4);
    DEFINE wtransacc		CHAR(4);
    DEFINE vmonto_tot		MONEY(14,2);
    DEFINE wmonto_tot		MONEY(14,2);
    DEFINE vnum_serial		INTEGER;
    DEFINE wnum_serial		INTEGER;
    DEFINE contador		INTEGER;
    DEFINE vt_cuantos  		INTEGER;

    LET vcodret = "000";
    LET wcuenta = "";
    LET wtransacc = "";
    LET wmonto_tot = 0.00;
    LET wnum_serial = 0;
    LET contador =-1;
    LET vt_cuantos = 0;

    --SET DEBUG FILE TO "arrmovhis.txt";
    --TRACE ON;

    BEGIN
        ON EXCEPTION SET vsqlerr
            IF vsqlerr <> 0 THEN
                LET vcodret = vsqlerr;
                RETURN vcodret,vt_cuantos,vrowid;
            END IF;
   	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;

        SELECT max(rowid) linea,cuenta,transacc,monto_tot,num_serial,count(*) cont
        FROM sc_movhis
        WHERE empresa = "001"
        AND cuenta IS NOT NULL
        AND fech_alt = "01162009"
        AND transacc in("3381","3276","3277")
        AND num_serial >= 35249673
        AND num_serial <= 37795782
        AND cancelad <> "S"
        group by 2,3,4,5
        HAVING count(*) > 1
        INTO TEMP paso WITH NO LOG;

	-- **************** FOREACH PRINCIPAL ******************

	FOREACH WITH HOLD
	   SELECT linea,cuenta,transacc,monto_tot,num_serial
	     INTO vrowid,vcuenta,vtransacc,vmonto_tot,vnum_serial
	     FROM paso

            IF (contador = -1) THEN
                BEGIN WORK;
                LET contador = 0;
            END IF;

	    UPDATE sc_movhis
	    SET cancelad = "S"
	    WHERE empresa = pempresa AND
                  cuenta = vcuenta AND
		  transacc = vtransacc AND
		  monto_tot = vmonto_tot AND
		  num_serial = vnum_serial AND
                  rowid = vrowid;

            LET contador = contador + 1;

            IF (contador >= 70000) THEN
               LET vt_cuantos = vt_cuantos + contador;
	       LET contador = 0;
               COMMIT WORK;
               BEGIN WORK;
            END IF;
	END FOREACH;

        LET vt_cuantos = vt_cuantos + contador;

        -- **************** FOREACH PRINCIPAL ******************

        IF (contador > 0) THEN
            COMMIT WORK;
        END IF;
    END;
    RETURN vcodret, vt_cuantos, vrowid;
END PROCEDURE;