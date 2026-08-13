CREATE PROCEDURE "informix".genera_numero()
RETURNING CHAR(5), CHAR(20);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE sql_err      SMALLINT;
DEFINE isam_err     SMALLINT;
DEFINE error_info   CHAR(100);
DEFINE vsqlerr      INTEGER;
DEFINE s_sig_numero CHAR(20);
DEFINE v_registros  INTEGER;
DEFINE v_digito     CHAR(1);
DEFINE v_numsol     CHAR(20);
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET s_sig_numero = "???????????";
LET v_registros  = 0;
LET v_digito     = "?";
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CargoLineaCredito.err";
   --   TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET scod_ret = sql_err;
      INSERT INTO ax_paso values ("genera numero", sql_err);
      RETURN scod_ret, s_sig_numero;
   END EXCEPTION;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************



 SELECT COUNT(*) INTO v_registros FROM bdisolic:ss_solicitudes ;

 IF v_registros > 0 THEN

	SELECT MAX(num_solicitud) INTO v_numsol
	  FROM ss_solicitudes;

	LET v_numsol = SUBSTR(v_numsol[1,11],2);
	LET v_registros = v_numsol;
	LET v_registros = v_registros + 1;
	LET v_numsol = v_registros;
	LET s_sig_numero = "6" || LPAD(TRIM(v_numsol),10,"0");
	

 	{CREATE TEMP TABLE sig_numero ( numsol INTEGER );

 	INSERT INTO sig_numero SELECT SUBSTR(num_solicitud[1,11],2)
			         FROM bdisolic:ss_solicitudes
                                WHERE num_solicitud= (SELECT MAX(num_solicitud)
					         FROM bdisolic:ss_solicitudes);

  	SELECT  "6" || LPAD(numsol+1,10,"0")
    	  INTO s_sig_numero
    	  FROM  sig_numero;}
 ELSE
	LET s_sig_numero = "1";
	LET s_sig_numero = "6" || LPAD(TRIM(s_sig_numero),10,"0");
 END IF

      EXECUTE PROCEDURE bdicred:digvermod10(s_sig_numero)
         INTO scod_ret, v_digito;

      LET s_sig_numero = TRIM(s_sig_numero)|| v_digito;



END
	RETURN scod_ret, s_sig_numero;

END PROCEDURE
;