CREATE PROCEDURE "informix".arregsdo_ctacopp(pempresa CHAR(3))

  RETURNING CHAR(5), INTEGER;

    DEFINE vcodret     		CHAR(5);
    DEFINE sql_err     		INTEGER;
    DEFINE vcuenta   		CHAR(20);
    DEFINE vsdo_cuenta		MONEY(14,2);
    DEFINE vtransacc		CHAR(4);
    DEFINE vmonto_tot		MONEY(14,2); 
    DEFINE vprimera		INTEGER;
    DEFINE vsdo_inicial		MONEY(14,2);
    DEFINE vsdo_actual		MONEY(14,2);
    DEFINE vnum_serial		INTEGER;
    DEFINE vcontador  		INTEGER;
    DEFINE vcuantos		INTEGER;
  
    LET vcodret = "000";
    LET sql_err = 0;
    LET vcontador = -1;
    LET vcuantos = 0;
    LET vsdo_cuenta = 0.00;
    LET vprimera = 0;
    LET vsdo_inicial = 0.00;
    LET vsdo_actual = 0.00;

    BEGIN

       ON EXCEPTION SET sql_err
          IF sql_err <> 0 THEN
             LET vcodret = sql_err;
             RETURN vcodret, vcuantos;
          END IF;
       END EXCEPTION;

       SET DEBUG FILE TO "./arregsdo_ctacopp.out";
       TRACE ON;

       SET ISOLATION TO DIRTY READ;
       SET LOCK MODE TO WAIT 3;

       SELECT {+ INDEX (sc_movhis idx_movhisnew4)} LIMIT 25 *
         FROM sc_movhis
        WHERE empresa = "001"
          AND cuenta = "16000000012"
          AND fech_alt BETWEEN "02012009" AND "02282009"
          AND cancelad <> "S"
          AND transacc IN ("0270","0274","0297","0250", 
                           "3280","0263","0290","3246","0202")
          AND causa_dev <> "XX"
       ORDER BY fech_alt, num_serial
       INTO TEMP tmp_ctacopp WITH NO LOG;
       CREATE INDEX idx_ctacopp ON tmp_ctacopp(empresa,cuenta) USING BTREE FILLFACTOR 99;
       UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctacopp;

       -- ********************** FOREACH PRINCIPAL **********************

       FOREACH WITH HOLD

          SELECT num_serial,cuenta,sdo_cuenta,transacc,monto_tot
            INTO vnum_serial,vcuenta,vsdo_cuenta,vtransacc,vmonto_tot
            FROM tmp_ctacopp
           WHERE empresa = pempresa
             AND cuenta = "16000000012"
          ORDER BY fech_alt, num_serial


          IF (vcontador = -1) THEN
             BEGIN WORK;
             LET vcontador = 0;
          END IF;


	  IF vprimera = 0 THEN
             LET vsdo_inicial = 107470245.04;
	     LET vsdo_actual = vsdo_inicial;
             LET vprimera = 1;
          End IF;


	  IF vsdo_cuenta <> vsdo_actual THEN
	     UPDATE {+ INDEX (sc_movhis idx_movhisnew4)} sc_movhis
	        SET sdo_cuenta = vsdo_actual,
                    causa_dev = "XX"
              WHERE empresa = "001"
                AND cuenta = "16000000012"
                AND fech_alt BETWEEN "02012009" AND "02282009"
                AND cancelad <> "S"
                AND transacc IN ("0270","0274","0297","0250", 
                                 "3280","0263","0290","3246","0202")
	       AND num_serial = vnum_serial;
	  End IF;


	  IF vtransacc = "0202" OR vtransacc = "0263" OR
             vtransacc = "3246" THEN

	      LET vsdo_actual = vsdo_actual + vmonto_tot;

	  END IF;


	  IF vtransacc = "0270" OR vtransacc = "0274" OR
             vtransacc = "0290" OR vtransacc = "0297" OR
             vtransacc = "3280" THEN
	
	      LET vsdo_actual = vsdo_actual - vmonto_tot;

	  END IF;  


          LET vcontador = vcontador + 1;


          IF (Vcontador >= 70000) THEN
             LET vcuantos = vcuantos + vcontador;
	     LET vcontador = 0;
             COMMIT WORK;
             BEGIN WORK;
          END IF;        
	     
       END FOREACH;

       -- ********************** FOREACH PRINCIPAL **********************
       
       LET vcuantos = vcuantos + vcontador;

       IF (vcontador > 0) THEN
          COMMIT WORK;
       END IF;

    END;

    RETURN vcodret, vcuantos;

END PROCEDURE;