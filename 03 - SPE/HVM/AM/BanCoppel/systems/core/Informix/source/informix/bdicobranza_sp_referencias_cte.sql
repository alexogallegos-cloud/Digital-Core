CREATE PROCEDURE "informix".sp_referencias_cte()
       RETURNING char(6), char(80);

--declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(80);
DEFINE cMensaje 		            CHAR(80);
DEFINE cCod_ret                     CHAR(6);
DEFINE vdia							DATE;
DEFINE vhora						char(8);
DEFINE vempresa                     CHAR(3);
DEFINE vnumcte                      CHAR(20);
DEFINE vcredito                     CHAR(10);
DEFINE vnombre_ref                  CHAR(110);
DEFINE vtelefono_ref                CHAR(13);

--SET DEBUG FILE TO '/tmp/sp_calcula_cobranza_administrativa_pbaaaa.out';
--TRACE ON;

      LET cCod_ret        = '000000';
	  LET sql_err         = 0;
	  LET isam_err        = 0;
	  LET error_info      = '';
	  LET cMensaje        = 'PROCESO EXITOSO';


      --LET pFechaEjecucion = today;
      --LET vperiodo        = to_char(pFechaEjecucion,'%Y%m');

	BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET cMensaje = error_info;

            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
	        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

            INSERT INTO cb_bitacora(empresa, proceso, fh_ejecucion, cod_ret, mensaje, user_insert, fh_insert, hora_insert)
            VALUES('001', 'REFERENCIAS CLIENTE', today, cCod_ret, cMensaje, user, vdia, vhora);

			RETURN cCod_ret, cMensaje;

	    END EXCEPTION;
     

	  SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
	  SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

        INSERT INTO cb_bitacora(empresa, proceso, fh_ejecucion, cod_ret, mensaje, user_insert, fh_insert, hora_insert)
        VALUES('001', 'REFERENCIAS CLIENTE', today, '11111', 'PROCESO INICIALIZADO', user, vdia, vhora);

----------------------------------- Se obtienen DATOS del CLIENTE y SALDOS--------------------------------------------
FOREACH
            select     a.empresa,                                                        --- empresa
                       a.numcte,                                                         --- cliente
                       a.credito,
                       i.nombre_ref,                                                     --- nombre_ref
                       i.telefono_ref                                                    --- t_ref
            INTO vempresa, vnumcte, vcredito, vnombre_ref, vtelefono_ref
            from bdicobranza:cb_datos_admin_prev a, bdisolic:ss_refpersonales i
            where a.empresa = i.empresa
            and a.credito = i.num_solicitud
            and i.numcte_ref = 'R1'
            
---------------SE INCERTAN DATOS GENERADOS----------------------------------------------------------

        IF NOT EXISTS(SELECT * FROM bdicobranza:cb_referencias 
                          WHERE numcte = vnumcte AND nombre_ref = vnombre_ref) THEN

                                INSERT INTO bdicobranza:cb_referencias(empresa, numcte, num_referencia, nombre_ref, tipo_telefono, telefono, estatus, fecha_insert, user_insert) 
                                VALUES('001', vnumcte, 1, vnombre_ref, 1, vtelefono_ref, 1, today, user);               
         ELSE
         END IF;


        

END FOREACH;

	    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
	    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

        INSERT INTO bdicobranza:cb_bitacora(empresa, proceso, fh_ejecucion, cod_ret, mensaje, user_insert, fh_insert, hora_insert)
        VALUES('001', 'REFERENCIAS CLIENTE', today, cCod_ret, cMensaje, user, vdia,  vhora);

        RETURN cCod_ret, cMensaje;

	END;
END PROCEDURE;