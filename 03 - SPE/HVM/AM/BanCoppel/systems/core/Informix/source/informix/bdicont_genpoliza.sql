CREATE PROCEDURE "informix".genpoliza(poliza_ori integer, pusuario_ori varchar (8), fec_cap_ori date, pusuario_des varchar (8), fec_hoy date)
     RETURNING CHAR(5),char(255);

    --Variables de Retorno
DEFINE r_codret   char(5);
DEFINE r_mensaje  varchar(255);

	--DEFINE vempresa 		CHAR(3);
DEFINE v_numpoliza      INTEGER;

DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;
DEFINE vDesErr          VARCHAR(60); 

	ON EXCEPTION
        SET iSqlErr, iSamErr,vDesErr
        IF iSqlErr <> 0 THEN
			ROLLBACK WORK;
            LET r_codret = iSqlErr;
			LET r_mensaje = vDesErr;
        END IF;
        RETURN r_codret, r_mensaje; 
    END EXCEPTION;  

BEGIN WORK;

    -- ********** Inicializacion de Variables **********
    LET r_codret = '000';
    LET r_mensaje = 'PROCESO SATISFACTORIO';

    LET v_numpoliza = 0;

    --SET debug file to "/tmp/genpol.out";
    --TRACE ON;

	SELECT * FROM bdicont:co_mensual 
			WHERE usuario=pusuario_ori 
			  AND control_poliza= poliza_ori 
		      AND fecha_captura=fec_cap_ori
		      AND secuencia > 0 
              AND empresa= '001'
              AND naturaleza = "D"
    INTO TEMP tmp_natori_d WITH NO LOG;

	SELECT * FROM bdicont:co_mensual 
	        WHERE usuario=pusuario_ori 
			  AND control_poliza = poliza_ori 
			  AND fecha_captura= fec_cap_ori
			  AND secuencia > 0 
	          AND empresa= '001'
	          AND naturaleza = "C"
	INTO TEMP tmp_natori_c WITH NO LOG;

	UPDATE tmp_natori_c
	   SET fecha_captura = fec_hoy, naturaleza = "D";

	UPDATE tmp_natori_d
	   SET fecha_captura = fec_hoy, naturaleza = "C";

	SELECT * 
	  FROM tmp_natori_d
    INTO TEMP pol_comp WITH NO LOG;

	INSERT INTO pol_comp
	SELECT * 
	  FROM tmp_natori_c;

	SELECT MAX(numero) + 1
	  INTO v_numpoliza
	  FROM co_ctrlpoliza
	 WHERE num_sec = "1";

	UPDATE co_ctrlpoliza
       SET numero = v_numpoliza
     WHERE  num_sec = "1";

	UPDATE pol_comp 
       SET control_poliza = v_numpoliza;
	 
	INSERT INTO bdicont:co_detpol
		 SELECT pusuario_des,
				control_poliza,
				fecha_captura,
				secuencia,
				empresa,
				ccmayor,
				ccsub,
				ccsubsub,
				ccssubsub,
				ccsssubsub,
				sector,
				ciudad,
				sucursal,
				nro_auxiliar,
				naturaleza,
				monto,
				descripcion,
				fecha_valida,
				moneda,
				0, --valor_cambio,
				0, --valor_div_cambio,
				" ",
				poliza_usuario,
				tipo_mov,
				ccosto_orig
	       FROM pol_comp;

	EXECUTE PROCEDURE gen_encab("001", pusuario_des, fec_hoy ,v_numpoliza)
                 INTO r_codret;

	IF r_codret <> '000' THEN
        ROLLBACK WORK;
        LET r_mensaje = 'ERROR en gen_encab';
        RETURN r_codret,r_mensaje;
	END IF

COMMIT WORK;

	DROP TABLE tmp_natori_c;
	DROP TABLE tmp_natori_d;
	DROP TABLE pol_comp;

    --    LET r_codret = '000';
    LET r_mensaje = 'PROCESO SATISFACTORIO';
    RETURN r_codret, r_mensaje;
 
END PROCEDURE;