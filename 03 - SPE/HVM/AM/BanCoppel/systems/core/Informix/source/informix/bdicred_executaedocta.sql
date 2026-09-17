CREATE PROCEDURE "informix".executaedocta(
							pempresa CHAR(3),
							pfechahoy DATE,
							ptipo CHAR(1))
RETURNING CHAR(5);


DEFINE v_cod_ret	        CHAR(5);
DEFINE sql_err          INTEGER;
DEFINE v_cuantos		INTEGER;


DEFINE vStProc         	CHAR(1);
DEFINE v_nameProcess	CHAR(20);

--SET DEBUG FILE TO "ExecutaEdoCta.out";
--TRACE ON;

BEGIN


  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_cod_ret = sql_err;

			UPDATE sd_contproc
			SET status_proc = "C",
			   hora_fin    = CURRENT,
			   cod_ret     = v_cod_ret,
			   mensaje     = "Estados de Cuenta Sin Generar"
			WHERE proceso     = v_nameProcess			
			AND fecha       = pfechahoy
			AND empresa     = pEmpresa;
                       
			UPDATE bdinteg:sx_contproc
			SET status_proc = "C",
			 	hora_fin    = CURRENT,
			 	codret      = v_cod_ret
			WHERE proceso  = v_nameProcess
			AND empresa = pEmpresa
			AND fecha    = pfechahoy;

            RETURN v_cod_ret;
        END IF
   END EXCEPTION;


	LET v_nameProcess = "GeneraEdoCta";
	LET v_cod_ret = "000";

	--------------------------------------------------------
	--	PREGUNTA POR EL CONTROL  DE PROCESOS
	-------------------------------------------------------
	SELECT status_proc INTO vStProc
	FROM sd_contproc
	WHERE proceso  = v_nameProcess
	AND fecha    = pfechahoy
	AND empresa = pEmpresa;
	   
	IF vStProc IS NULL THEN
        	INSERT INTO sd_contproc
  	 	 		(empresa, proceso, fecha, 
  	 	 		 status_proc, ejecutivo,
          	  	 hora_inicio, hora_fin, 
          	  	 cod_ret, mensaje)
        	VALUES
	 	 		(pEmpresa, v_nameProcess, pfechahoy, 
	 	 		'I', USER,
	 	 		CURRENT, NULL, 
	 	 		NULL, NULL);

			INSERT INTO bdinteg:sx_contproc
		 		(empresa, proceso, fecha, 
		 		sistema, status_proc,
	        	ejecutivo, hora_ini, 
	        	hora_fin, codret)
			VALUES
		 		(pEmpresa, v_nameProcess, pfechahoy, 
		 		'06', 'I', 
		 		USER, CURRENT, 
		 		NULL, '000');
	ELIF vStProc = "F" THEN
         	RETURN v_cod_ret;
	END IF
	


	IF ptipo = "G" THEN
		EXECUTE PROCEDURE ExecutaEdoCtaGeneral
			(pempresa,
			 pfechahoy)
			INTO v_cod_ret;
	ELIF ptipo = "S" THEN
		EXECUTE PROCEDURE ExecutaEdoCtaGeneral
			(pempresa,
			 pfechahoy,
			 ptipo)
			INTO v_cod_ret;	
	ELIF ptipo = "E" THEN
		EXECUTE PROCEDURE ExecutaEdoCtaGeneral
			(pempresa,
			 pfechahoy,
			 ptipo)
			INTO v_cod_ret;	
	END IF
	

	SELECT COUNT(*) 
		INTO v_cuantos
	FROM sd_valedocta
		WHERE empresa = pempresa
		AND fecha_proc = pfechahoy
		AND tipo <> "0"	;



    IF v_cuantos > 0 THEN
        UPDATE sd_contproc
           SET status_proc = "C",
               hora_fin    = CURRENT,
               cod_ret     = v_cod_ret,
               mensaje     = v_cuantos || "Estados de Cuenta Sin Generar"
         WHERE proceso     = v_nameProcess
           AND fecha       = pfechahoy
           AND empresa     = pEmpresa;

        UPDATE bdinteg:sx_contproc
           SET status_proc = "C",
               hora_fin    = CURRENT,
               codret      = v_cod_ret
         WHERE proceso  = v_nameProcess
           AND empresa = pEmpresa
           AND fecha    = pfechahoy;
    ELSE
	    UPDATE sd_contproc
	       SET status_proc = "F",
	           hora_fin    = CURRENT,
        	   cod_ret     = v_cod_ret,
      	       mensaje     = "Proceso Concluido"
  	     WHERE proceso     = v_nameProcess
	       AND empresa     = pEmpresa
	       AND fecha       = pfechahoy;

          UPDATE bdinteg:sx_contproc
             SET status_proc = "F",
                 hora_fin    = CURRENT,
                 codret      = v_cod_ret
           WHERE proceso  = v_nameProcess
            AND empresa = pEmpresa
            AND fecha    = pfechahoy;
    END IF

END;

	RETURN v_cod_ret;

END PROCEDURE ;