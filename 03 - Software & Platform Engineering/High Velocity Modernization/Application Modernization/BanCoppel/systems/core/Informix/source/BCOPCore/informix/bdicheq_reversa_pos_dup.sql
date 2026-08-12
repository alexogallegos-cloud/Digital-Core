CREATE PROCEDURE "informix".reversa_pos_dup()

  RETURNING CHAR(5), INTEGER;

    -- // DECLARACION DE VARIABLES

    DEFINE vcodret     		CHAR(5);
    DEFINE sql_err     		INTEGER;
    DEFINE vcontador		INTEGER;
    DEFINE vcuantos  		INTEGER;

    DEFINE vcuenta		    CHAR(20);
	DEFINE vfolio_suc       CHAR(16);
	DEFINE vimporte         MONEY(14,2);
	DEFINE vsdo_actual      MONEY(14,2);
	DEFINE vimp_chq_sbg     MONEY(14,2);
	DEFINE vsaldo           MONEY(14,2);
	DEFINE vsbg             MONEY(14,2);
	
        -- // INICIALIZACION DE VARIABLES

    LET vcodret	  = "000";
    LET sql_err	  = 0;
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

    -- SET DEBUG FILE TO "./reversa_pos_dup.out";
    -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

     -- ********************* FOREACH PRINCIPAL ***********************

    FOREACH WITH HOLD
	  SELECT cuenta, folio_suc, importe
        INTO vcuenta, vfolio_suc, vimporte	
	    FROM bdicheq:mov_reversar_pos  
	
      IF (vcontador = -1) THEN
         BEGIN WORK;
         LET vcontador = 0;
      END IF;

	  UPDATE bdicheq:sc_movdia SET cancelad = "S"
	   WHERE cuenta = vcuenta
	     AND folio_suc = vfolio_suc;
		 
	  SELECT sdo_actual, imp_chq_sbg
        INTO vsdo_actual, vimp_chq_sbg	  
	    FROM bdicheq:sc_maechq
	   WHERE cuenta = vcuenta;
	   
	  LET vsaldo = 0;
      LET vsbg   = 0;
	  
	  IF vimp_chq_sbg > 0 THEN
         LET vsaldo = (vsdo_actual + vimporte) - vimp_chq_sbg;
	 	 LET vsbg = 0;
 	  ELSE
		 LET vsaldo = vsdo_actual + vimporte;
	  END IF;
	  
	  UPDATE bdicheq:sc_maechq 
	     SET sdo_actual = vsaldo, imp_chq_sbg = vsbg
	   WHERE cuenta = vcuenta;
            		 
	  LET vcontador = vcontador + 1;

      IF (vcontador >= 5000) THEN
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