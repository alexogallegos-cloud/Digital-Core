CREATE PROCEDURE "informix".inserta_bitacora_cob(vempresa CHAR(3),
                                            vproceso CHAR(4), cCod_ret CHAR(5), cMensaje CHAR(80), t_eje CHAR(2))
--declaracion de variables
----------------------------------------------------------------------------------------------
     DEFINE sql_err 			        INTEGER;
     DEFINE isam_err 		        INTEGER;
     DEFINE error_info		        CHAR(80);
     DEFINE vdia						DATE;
     DEFINE vhora					CHAR(8);

     LET sql_err       = 0;
	   LET isam_err      = 0;
	   LET error_info    = '';
	                          
	BEGIN

    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

    IF (t_eje = '01') THEN

            INSERT INTO cb_bitacora(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
            VALUES(vempresa, vproceso, today, '000000', 'PROCESO INICIALIZADO', user, vdia, vhora);
	    
    ELIF (t_eje = '02') THEN

        INSERT INTO cb_bitacora(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
        VALUES(vempresa, vproceso, today, cCod_ret, cMensaje, user, vdia, vhora);
    
    ELIF (t_eje = '03') THEN

        INSERT INTO bdicobranza:cb_bitacora(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
        VALUES(vempresa, vproceso, today, '000000', 'PROCESO FINALIZADO', user, vdia,  vhora);

    END IF;

	END;
END PROCEDURE;