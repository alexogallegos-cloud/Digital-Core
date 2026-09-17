CREATE PROCEDURE "informix".sp_inserta_bitacora_cob_2(pempresa CHAR(3), pproceso CHAR(4),pCod_ret CHAR(6)
                                                             ,pMensaje CHAR(150), p_tipoejecucion CHAR(2)) 
       RETURNING char(6);

--declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			  INTEGER;
DEFINE isam_err 		  INTEGER;
DEFINE error_info		  CHAR(150);
DEFINE cMensaje 		  CHAR(80);
DEFINE cCod_ret           CHAR(6);
DEFINE vdia               DATE;
DEFINE vhora              CHAR(8);


 --SET DEBUG FILE TO '/ifxsif01/macf/sp_inserta_bitacora_cob_2.trc';
 --TRACE ON;

    LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
    
    
 
BEGIN
        ON EXCEPTION SET sql_err, isam_err, error_info
            LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            RETURN cCod_ret;
        END EXCEPTION;

        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

		
        IF (p_tipoejecucion = '01') THEN
            let cMensaje = 'PROCESO INICIALIZADO ' || TRIM(pMensaje);     
            INSERT INTO cb_bitacora(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
            --VALUES(pempresa, pproceso, today, '000000', 'PROCESO INICIALIZADO', user, vdia, vhora);
			VALUES(pempresa, pproceso, today, '000000', cMensaje, user, vdia, vhora);
                
        ELIF (p_tipoejecucion = '02') THEN

            INSERT INTO cb_bitacora(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
            VALUES(pempresa, pproceso, today, pCod_ret, pMensaje, user, vdia, vhora);
    
        ELIF (p_tipoejecucion = '03') THEN
            let cMensaje = 'PROCESO FINALIZADO ' || TRIM(pMensaje);
            INSERT INTO bdicobranza:cb_bitacora(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
            --VALUES(pempresa, pproceso, today, '000000', 'PROCESO FINALIZADO', user, vdia,  vhora);
			VALUES(pempresa, pproceso, today, '000000', cMensaje, user, vdia,  vhora);

        END IF;

    RETURN cCod_ret;
    END;
END PROCEDURE;