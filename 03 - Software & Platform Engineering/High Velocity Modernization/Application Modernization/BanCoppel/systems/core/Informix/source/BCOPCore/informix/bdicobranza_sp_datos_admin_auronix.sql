CREATE PROCEDURE "informix".sp_datos_admin_auronix()
       RETURNING char(6), char(80);

--declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(80);
DEFINE cMensaje 		            CHAR(80);
DEFINE cCod_ret                     CHAR(6);
------------------------------------------------------------
DEFINE pFechaEjecucion              DATE;
DEFINE vperiodo                     INTEGER;
DEFINE cmensajevalidador            CHAR(4);
------------------------------------------------------------
DEFINE cdia                         CHAR(2);
DEFINE cmes                         CHAR(2);
------------------------------------------------------------
DEFINE vempresa                     CHAR(3);
DEFINE vnumcte                      CHAR(20);
DEFINE vnum_credito                 CHAR(20);
DEFINE vnum_tarjeta                 CHAR(20);
DEFINE vciudad                      CHAR(20);
DEFINE vestado                      CHAR(20);
DEFINE vnombre1                     CHAR(26);
DEFINE vnombre2                     CHAR(26);
DEFINE vapellido_paterno            CHAR(26);
DEFINE vapellido_materno            CHAR(26);
DEFINE vsexo                        CHAR(1);
DEFINE vestado_civil                CHAR(2);
DEFINE vpagos_vencidos              INTEGER;
DEFINE vdia							DATE;
DEFINE vdia2                        DATE;
DEFINE vhora						char(8);
DEFINE vsituacion_car               CHAR(10);
-------------------------------------------------------------
DEFINE vsituacion                   CHAR(1);
DEFINE vcausa                       SMALLINT;
DEFINE vidaccion                    CHAR(1);
DEFINE vinstruccion                 CHAR(1);

DEFINE dtFechaUltPago               DATE;
DEFINE monto_pago                   DECIMAL(18,2);
DEFINE monto_min                    DECIMAL(18,2); 
DEFINE monto_max                    DECIMAL(18,2);
DEFINE v_fecha_hoy                  DATE;

--SET DEBUG FILE TO '/tmp/sp_calcula_cobranza_administrativa_pbaaaa.out';
--TRACE ON;

      LET cCod_ret        = '000000';
	  LET sql_err         = 0;
	  LET isam_err        = 0;
	  LET error_info      = '';
	  LET cMensaje        = 'PROCESO EXITOSO';
      LET pFechaEjecucion = today;
      LET vperiodo        = to_char(pFechaEjecucion,'%Y%m');

	BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET cMensaje = error_info;

            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
	        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

            INSERT INTO cb_bitacora(empresa, proceso, fh_ejecucion, cod_ret, mensaje, user_insert, fh_insert, hora_insert)
            VALUES('001', 'DATOS ADMINISTRATIVA', today, cCod_ret, cMensaje, user, vdia, vhora);

			RETURN cCod_ret, cMensaje;

	    END EXCEPTION;

      SELECT valor_numerico INTO  monto_min FROM bdicobranza:cb_param_campania where num_parametro= 1 
        and grupo_parametro= 'MONTOS';

      SELECT valor_numerico INTO  monto_max FROM bdicobranza:cb_param_campania where num_parametro= 2 
        and grupo_parametro= 'MONTOS';

      SELECT valor_alfabetico INTO vsituacion_car 
      FROM bdicobranza:cb_param_campania where num_parametro= 1 
        and grupo_parametro= 'SIT_CARTER';
               

	  SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
	  SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

        INSERT INTO cb_bitacora(empresa, proceso, fh_ejecucion, cod_ret, mensaje, user_insert, fh_insert, hora_insert)
        VALUES('001', 'DATOS ADMINISTRATIVA', today, '11111', 'PROCESO INICIALIZADO', user, vdia, vhora);

         IF ( (monto_min > monto_max) OR (monto_min IS NULL) OR (monto_max IS NULL) ) THEN
        LET cMensaje      =  'PARAMETROS NO VALIDOS';
        LET cCod_ret      =  '999';

          SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
	      SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

          INSERT INTO bdicobranza:cb_bitacora(empresa, proceso, fh_ejecucion, cod_ret, mensaje, user_insert, fh_insert, hora_insert)
          VALUES('001', 'DATOS ADMINISTRATIVA', today, cCod_ret, cMensaje, user, vdia, vhora);

            RETURN cCod_ret, cMensaje;
        END IF;

--------------------------------------------------------------------------
--se borra datos antiguos

    SELECT MAX(fecha_insert) INTO vdia2 FROM bdicobranza:cb_datos_admin_prev;
    
    IF(vdia2 = vdia ) THEN
        DELETE bdicobranza:cb_datos_admin_prev WHERE fecha_insert = vdia2;
    ELSE
        DELETE bdicobranza:cb_datos_admin_prev WHERE fecha_insert < vdia2;
    END IF;

----------------------------------- Se obtienen DATOS del CLIENTE y SALDOS--------------------------------------------
    SET ISOLATION TO dirty READ;

FOREACH

            select d.empresa,                                                        --- empresa
                   a.numcte,                                                         --- cliente
                   d.num_credito,                                                    --- credito
                   e.num_tarjeta,                                                    --- tarjeta
                   b.numerociudad || '-' || trim(j.inicialciudad) Ciudad,            --- ciudad
                   j.numeroestado || '-' || trim(j.inicialestado) Estado,            --- estado
                   trim(a.nombre1),
                   trim(a.nombre2),
                   trim(a.apell_paterno),
                   trim(a.apell_materno),
                   aa.sexo Sexo,                                                     --- sexo
                   aa.estado_civil Estado_Civil                                      --- civil
            INTO vempresa 
                 ,vnumcte
                 ,vnum_credito
                 ,vnum_tarjeta
                 ,vciudad
                 ,vestado
                 ,vnombre1
                 ,vnombre2
                 ,vapellido_paterno
                 ,vapellido_materno
                 ,vsexo
                 ,vestado_civil
            from bdinteg:si_cliente a
                       ,bdinteg:si_ctepf aa
                       ,bdinteg:si_direcciones b
                       ,bdicred:sd_maecred d
                       ,bdicred:sd_tarjeta e
                       ,bdicred:sd_maesdos f
                       ,bdinteg:si_catciudades j
            where a.empresa = d.empresa
            and a.numcte = d.numcte
            and a.numcte = aa.numcte
            and a.numcte = b.numcte
            and a.numcte = b.numcte
            and d.empresa = e.empresa
            and d.num_credito = e.num_credito
            and d.empresa = f.empresa
            and d.num_credito = f.num_credito
            and b.numerociudad = j.numerociudad
            and b.tipo_dir = '1'
            and b.secuencia = ( select max(secuencia) from bdinteg:si_direcciones h
                    where tipo_dir = '1'
                      and a.numcte = h.numcte)
            and d.empresa = '001'
            and e.status_tar = 'A'
            and e.tipo_tarjeta = 'T'
            and e.secuencia = ( select max(secuencia) from bdicred:sd_tarjeta ab
                    where ab.empresa = d.empresa
                      and ab.num_credito= d.num_credito)
            --and e.secuencia = ( select max(secuencia) from bdicred:sd_tarjeta h
              --          where tipo_dir = '1'
                --        and a.numcte = aa.numcte)
            and f.mto_venc_trasp between monto_min and monto_max
            and d.status_cred in ('BT','BA', 'FC')                   
            and d.numcte not in (select numcliente from cb_compac)   


            SELECT 
                COUNT(*)                                             -- Pagos Vencidos
            INTO vpagos_vencidos
            FROM bdicred:sd_amortiza_credito
            WHERE empresa     = '001'
            AND num_credito = vnum_credito
            AND capital_status IN ('2','7');
                      
                
            IF (vpagos_vencidos = 0) THEN
                   CONTINUE FOREACH;
            END IF;

            LET vsituacion = NULL;
            LET vcausa     = NULL;

            SELECT  FIRST 1 situacion,  causa
            INTO    vsituacion, vcausa
            FROM    bdisitesp:se_ctessitespcte
            WHERE   numcte = vnumcte;

            LET vinstruccion = 1;

                    IF ((vsituacion IS NOT NULL) AND (vcausa IS NOT NULL)) THEN

                                SELECT FIRST 1 instruccion
                                INTO   vinstruccion
                                FROM   bdisitesp:se_situacionaccion
                                WHERE  situacion= vsituacion
                                AND    causa= vcausa
                                AND    idaccion = 9;

                    END IF;

                    IF (vinstruccion = 1) THEN

			 INSERT INTO bdicobranza:cb_datos_admin_prev (empresa, periodo, tipo_campania, numcte, credito, tarjeta, ciudad, estado, 
                                                nombre1, nombre2, apellido_paterno, apellido_materno, sexo, estado_civil, pago_venc, estatus, 
                                                fecha_insert, user_insert)
			  VALUES(vempresa, vperiodo, 1, vnumcte, vnum_credito, vnum_tarjeta, vciudad, vestado, vnombre1, vnombre2, vapellido_paterno, 
                     vapellido_materno, vsexo, vestado_civil, vpagos_vencidos, vsituacion_car, TODAY, USER);
                    END IF;

END FOREACH;

	  SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
	  SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

        INSERT INTO bdicobranza:cb_bitacora(empresa, proceso, fh_ejecucion, cod_ret, mensaje, user_insert, fh_insert, hora_insert)
        VALUES('001', 'DATOS ADMINISTRATIVA', today, cCod_ret, cMensaje, user, vdia,  vhora);

        RETURN cCod_ret, cMensaje;

	END;
END PROCEDURE;