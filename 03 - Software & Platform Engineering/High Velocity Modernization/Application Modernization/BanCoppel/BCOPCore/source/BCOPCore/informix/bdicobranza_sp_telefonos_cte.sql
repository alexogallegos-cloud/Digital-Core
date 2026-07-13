CREATE PROCEDURE "informix".sp_telefonos_cte(vtipo_campania INTEGER)
       RETURNING char(6), char(80);

--declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(80);
DEFINE cMensaje 		            CHAR(80);
DEFINE cCod_ret                     CHAR(6);
DEFINE vempresa                     CHAR(3);
DEFINE vnumcte                      CHAR(20);
DEFINE vtelefono_casa               CHAR (13);
DEFINE vtelefono_celular            CHAR(13);
DEFINE vtelefono_trabajo            CHAR(13);
DEFINE vtelefono                    CHAR(13);
DEFINE vextension                   CHAR(5);
DEFINE vdia							DATE;
DEFINE vhora						char(8);

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
            VALUES('001', 'sp_telefono_cte', today, cCod_ret, cMensaje, user, vdia, vhora);

			RETURN cCod_ret, cMensaje;

	    END EXCEPTION;
     

	  SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
	  SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

        INSERT INTO cb_bitacora(empresa, proceso, fh_ejecucion, cod_ret, mensaje, user_insert, fh_insert, hora_insert)
        VALUES('001', 'sp_telefono_cte', today, '11111', 'PROCESO INICIALIZADO', user, vdia, vhora);

----------------------------------- Se obtienen DATOS del CLIENTE y SALDOS--------------------------------------------
FOREACH

            SELECT     a.empresa,                                     --- empresa
                       a.numcte,                                      --- cliente
                       b.telefono1,                                   --- t_casa
                       b.telefono2,                                   --- t_celular
                       b.telefono3,                                   --- t_trabajo
                       b.extension                                    --- ext
            INTO vempresa, vnumcte, vtelefono_casa, vtelefono_celular,
                 vtelefono_trabajo, vextension
            FROM bdicobranza:cb_datos_admin_prev a
                 ,bdinteg:si_direcciones b
            WHERE a.empresa = '001'
            AND a.tipo_campania = vtipo_campania
            AND a.numcte = b.numcte
            AND b.tipo_dir = '1'
            AND b.secuencia = ( select max(secuencia) from bdinteg:si_direcciones h
                    where tipo_dir = '1'
                      and a.numcte = h.numcte)
 
                LET vtelefono_celular = '045' || substr(vtelefono_celular,length(vtelefono_celular)-9,10);

                IF vtelefono_celular = '045' THEN
                    LET vtelefono_celular = '';
                END IF;

------------------------------------------------------------------------------------------------------
---------------------------------SE INCERTAN DATOS GENERADOS------------------------------------------
------------------------------------------------------------------------------------------------------

            IF NOT EXISTS(SELECT * FROM cb_telefonos 
                          WHERE numcte = vnumcte AND telefono = vtelefono_casa) THEN

                            IF vtelefono_casa <> '' AND vtelefono_casa <> '0' THEN
                                INSERT INTO cb_telefonos (empresa, numcte, tipo_telefono, telefono, extension, 
                                                           estatus, fecha_insert, user_insert)
                                VALUES(vempresa, vnumcte, 1, vtelefono_casa, '', 'AC', today, user);
                            ELSE
                            END IF;
            ELSE
            END IF;

            IF NOT EXISTS(SELECT * FROM cb_telefonos 
                          WHERE numcte = vnumcte AND telefono = vtelefono_celular) THEN

                            IF vtelefono_celular <> '' AND vtelefono_celular <> '0' THEN
                            INSERT INTO cb_telefonos (empresa, numcte, tipo_telefono, telefono, extension, 
                                       estatus, fecha_insert, user_insert)
                            VALUES(vempresa, vnumcte, 2, vtelefono_celular, '', 'AC', today, user);               
                        ELSE
                        END IF;
            ELSE
            END IF;

            IF NOT EXISTS(SELECT * FROM cb_telefonos 
                          WHERE numcte = vnumcte AND telefono = vtelefono_trabajo) THEN

                        IF vtelefono_trabajo <> '' AND vtelefono_trabajo <> '0'  THEN
                        INSERT INTO cb_telefonos (empresa, numcte, tipo_telefono, telefono, extension, 
                                       estatus, fecha_insert, user_insert)
                        VALUES(vempresa, vnumcte, 3, vtelefono_trabajo, vextension, 'AC', today, user);               
                        ELSE
                        END IF;
            ELSE
            END IF;
                      
END FOREACH;

	    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
	    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

        INSERT INTO bdicobranza:cb_bitacora(empresa, proceso, fh_ejecucion, cod_ret, mensaje, user_insert, fh_insert, hora_insert)
        VALUES('001', 'sp_telefono_cte', today, cCod_ret, cMensaje, user, vdia,  vhora);

        RETURN cCod_ret, cMensaje;

	END;
END PROCEDURE;