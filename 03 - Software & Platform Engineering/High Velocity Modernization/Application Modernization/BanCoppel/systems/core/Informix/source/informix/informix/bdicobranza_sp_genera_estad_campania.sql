CREATE PROCEDURE "informix".sp_genera_estad_campania(pFecha  date, pCampania char(20))
       RETURNING char(6), char(80);

    DEFINE vpagosvenc         INTEGER;  
    DEFINE vmontomin          DECIMAL(18,2);
    DEFINE vnumtes            INTEGER;
    DEFINE vdia				  DATE;
    DEFINE vhora			  CHAR (8);
    DEFINE sql_err 			        INTEGER;
    DEFINE isam_err 		            INTEGER;
    DEFINE error_info		            CHAR(80);
    DEFINE cMensaje 		            CHAR(80);
    DEFINE cCod_ret                   CHAR(6);

    --Set debug file to '/pisa/pisabanco/pisa_ftes/credito/coronel/sp_os_GeneraOs.out';
    --trace on;    

    LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';


    BEGIN

      ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET cMensaje = error_info;

            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
	        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

            INSERT INTO cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
            VALUES('estadisticas '||pCampania, cCod_ret, cMensaje, USER, vdia, vhora);

			RETURN cCod_ret, cMensaje;

	    END EXCEPTION;

     DELETE FROM cb_estad_campanias where nombre_campania = pCampania and fecha_ejecucion =pFecha;

            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

            INSERT INTO cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
            VALUES('estadisticas '||pCampania, '11111', 'PROCESO INICIALIZADO', USER, vdia, vhora);

     IF pCampania ='administrativa' THEN

        FOREACH WITH HOLD        
            SELECT  cia.pago_venc,  
                b.numerico,
                count(cliente)   --rango_min , B.NUMERICO rango_max
            INTO  vpagosvenc, vmontomin, vnumtes
            FROM  cb_param_campanias B, cb_info_administrativa Cia
            WHERE  B.nombre_campania = pCampania
            AND  b.evento = 'RANGO_MONTO'
            AND  cia.fecha_ejecucion =pFecha
            AND  cia.pago_min between b.numerico+1 and  (select a.numerico from  cb_param_campanias a 
                                                        where a.nombre_campania = pCampania
                                                          and a.evento = 'RANGO_MONTO' 
                                                          and a.cod_param =b.cod_param +1  )
            GROUP BY cia.pago_venc ,B.NUMERICO
            ORDER BY cia.pago_venc,B.NUMERICO 

            INSERT INTO cb_estad_campanias
            (nombre_campania, fecha_ejecucion, pago_venc, num_ctes_venc, rango_pago_min) 
            VALUES (pCampania, pFecha, vpagosvenc,  vnumtes,vmontomin );

        END FOREACH;

     ELSE

        FOREACH WITH HOLD
        
            SELECT  cia.vencido,  
                b.numerico,
                count(cliente)   --rango_min , B.NUMERICO rango_max
            INTO  vpagosvenc, vmontomin, vnumtes
            FROM  cb_param_campanias B, cb_info_preventiva Cia
            WHERE  B.nombre_campania = pCampania
            AND  b.evento = 'RANGO_MONTO'
            AND  cia.fecha_ejecucion =pFecha
            AND  cia.pago_min between b.numerico+1 and  (select a.numerico from  cb_param_campanias a 
                                                        where a.nombre_campania = pCampania
                                                          and a.evento = 'RANGO_MONTO' 
                                                          and a.cod_param =b.cod_param +1  )
            GROUP BY cia.vencido ,B.NUMERICO
            ORDER BY cia.vencido,B.NUMERICO 

            INSERT INTO cb_estad_campanias
            (nombre_campania, fecha_ejecucion, pago_venc, num_ctes_venc, rango_pago_min) 
            VALUES (pCampania, pFecha, vpagosvenc,  vnumtes,vmontomin );

        END FOREACH;        
     END IF;

            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

            INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
            VALUES('estadisticas '||pCampania, cCod_ret, cMensaje, USER, vdia,  vhora);

		RETURN cCod_ret, cMensaje;

    END;
END PROCEDURE;