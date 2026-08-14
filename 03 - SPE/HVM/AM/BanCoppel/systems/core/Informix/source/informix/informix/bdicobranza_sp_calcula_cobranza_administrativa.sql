CREATE PROCEDURE "informix".sp_calcula_cobranza_administrativa()
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
DEFINE iDia                         INTEGER;
DEFINE pUsuario                     CHAR(8);
DEFINE vnombre                      CHAR(110);
------------------------------------------------------------
DEFINE cdia                         CHAR(2);
DEFINE cmes                         CHAR(2);
------------------------------------------------------------
DEFINE vempresa                     CHAR(3);
DEFINE vnumcte                      CHAR(20);
DEFINE vnum_credito                 CHAR(20);
DEFINE vnum_tarjeta                 CHAR(20);
DEFINE vsaldo_total                 DECIMAL(18,2);
DEFINE vpago_minimo_total           DECIMAL(18,2);
DEFINE vsdo_vdo_int_mora            DECIMAL(18,2);
DEFINE vpagos_vencidos              INTEGER;
------------------------------------------------------------
DEFINE iciudad                      INTEGER;
DEFINE vtelefono_casa               CHAR (13);
DEFINE vtelefono_celular            CHAR(13);
DEFINE vtelefono_trabajo            CHAR(13);
DEFINE vext_trabajo                 CHAR(5);
------------------------------------------------------------
DEFINE v_nombre1                    CHAR(26);
DEFINE v_nombre2                    CHAR(26);
DEFINE v_apell_paterno              CHAR(26);
DEFINE v_apell_materno              CHAR(26);
------------------------------------------------------------
DEFINE vsexo                        CHAR(1);
DEFINE vestado_civil                CHAR(2);
------------------------------------------------------------
DEFINE vnombre_ref                  CHAR(110);
DEFINE vtelefono_ref                CHAR(13);
------------------------------------------------------------
DEFINE vciudad                      CHAR(20);
DEFINE vestado                      CHAR(20);
------------------------------------------------------------
DEFINE cmensajevalidador            CHAR(4);
DEFINE vdia							DATE;
DEFINE vdia2                        DATE;
DEFINE vhora						char(8);
-------------------------------------------------------------
DEFINE vsituacion                   CHAR(1);
DEFINE vcausa                       SMALLINT;
DEFINE vidaccion                    CHAR(1);
DEFINE vinstruccion                 CHAR(1);


DEFINE vinteres                     DECIMAL(18,2);
DEFINE viva_interes                 DECIMAL(18,2);
DEFINE vmoratorio                   DECIMAL(18,2);
DEFINE viva_moratorio               DECIMAL(18,2);
DEFINE v_monto_financiado           DECIMAL (18, 2);
DEFINE v_saldo_capital_insoluto     DECIMAL (18, 2);
DEFINE v_saldo_retenido             DECIMAL (18, 2);
DEFINE vfecha_monto_ultimo_pago     CHAR (20);
DEFINE dtFechaUltPago               DATE;
DEFINE monto_pago                   DECIMAL(18,2);
DEFINE v_pago_min_sin_vdo           DECIMAL(18,2);
DEFINE iva_cred                     DECIMAL(18,2);
DEFINE monto_ini                    DECIMAL(18,2); 
DEFINE monto_fin                    DECIMAL(18,2);
DEFINE v_fecha_hoy                  DATE;


--SET DEBUG FILE TO '/tmp/sp_calcula_cobranza_administrativa_pbaaaa.out';
--TRACE ON;

      LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
------------------------------------------------------------
    LET pUsuario      = user;
------------------------------------------------------------
    LET pFechaEjecucion = today;
    LET iDia = day(pFechaEjecucion);

	BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET cMensaje = error_info;

            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
	        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

            INSERT INTO cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
            VALUES('Cobranza Administrativa', cCod_ret, cMensaje, pUsuario, vdia, vhora);

			RETURN cCod_ret, cMensaje;

	    END EXCEPTION;


      SELECT numerico
      INTO  monto_ini
      FROM bdicobranza:cb_param_campanias where cod_param= 1;

      SELECT numerico
      INTO  monto_fin 
      FROM bdicobranza:cb_param_campanias where cod_param= 2;

	  SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
	  SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

        INSERT INTO cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
        VALUES('Cobranza Administrativa', '11111', 'PROCESO INICIALIZADO', pUsuario, vdia, vhora);


         IF ( (monto_ini > monto_fin) OR (monto_ini IS NULL) OR (monto_fin IS NULL) ) THEN
        LET cMensaje      =  'PARAMETROS NO VALIDOS';
        LET cCod_ret      =  '999';

          SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
	      SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

          INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
          VALUES('Cobranza Administrativa', cCod_ret, cMensaje, pUsuario, vdia, vhora);

            RETURN cCod_ret, cMensaje;
        END IF;

--------------------------------------------------------------------------
--se borra cb_info_administrativa datos antiguos
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
    --SELECT fecha_hoy INTO v_fecha_hoy FROM bdinteg:si_fechas;
    --SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO v_fecha_hoy from sysmaster:sysshmvals;
    --DELETE cb_info_administrativa WHERE fecha_ejecucion < v_fecha_hoy -1;
    SELECT MAX(fecha_ejecucion) INTO vdia2 FROM bdicobranza:cb_info_administrativa;
    
    IF(vdia2 = vdia ) THEN
    
    DELETE bdicobranza:cb_info_administrativa WHERE fecha_ejecucion = vdia2;
    
    ELSE
    
    DELETE bdicobranza:cb_info_administrativa WHERE fecha_ejecucion < vdia2;
    
    END IF;

    
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
----------------------------------------------
        --se obtiene la informacion
		SET ISOLATION TO dirty READ;

----------------------------------- Se obtienen DATOS del CLIENTE y SALDOS--------------------------------------------
FOREACH
            select     d.empresa,                                                        --- empresa
                       a.numcte,                                                         --- cliente
                       d.num_credito,                                                    --- credito
                       e.num_tarjeta,                                                    --- tarjeta
                       b.numerociudad || '-' || trim(j.inicialciudad) Ciudad,            --- ciudad
                       j.numeroestado || '-' || trim(j.inicialestado) Estado,            --- estado
                       trim(a.nombre1) || " " || trim(a.nombre2) || " " ||
                       trim(a.apell_paterno) || " " || trim(a.apell_materno) Nombre,     --- nombre
                       aa.sexo Sexo,                                                     --- sexo
                       aa.estado_civil Estado_Civil,                                     --- civil
                       b.telefono1 Telefono_Casa,                                        --- t_casa
                       b.telefono2 Telefono_Celular,                                     --- t_celular
                       b.telefono3 Telefono_Trabajo,                                     --- t_trabajo
                       b.extension Ext_Trabajo,                                          --- ext
                       i.nombre_ref,                                                     --- nombre_ref
                       i.telefono_ref                                                   --- t_ref
            INTO vempresa, vnumcte, vnum_credito, vnum_tarjeta, vciudad, vestado, vnombre,
                       vsexo, vestado_civil, vtelefono_casa, vtelefono_celular,
                       vtelefono_trabajo, vext_trabajo, vnombre_ref, vtelefono_ref
            from bdinteg:si_cliente a
                       ,bdinteg:si_ctepf aa
                       ,bdinteg:si_direcciones b
                       ,bdicred:sd_maecred d
                       ,bdicred:sd_tarjeta e
                       ,bdicred:sd_maesdos f
                       ,bdisolic:ss_refpersonales i
                       ,bdinteg:si_catciudades j
            where a.empresa = d.empresa
            and a.numcte = d.numcte
            and a.numcte = aa.numcte
            and a.numcte = b.numcte
            and b.tipo_dir = '1'
            and b.secuencia = ( select max(secuencia) from bdinteg:si_direcciones h
                    where tipo_dir = '1'
                      and a.numcte = h.numcte)
            and a.numcte = b.numcte
            and d.empresa = e.empresa
            and d.num_credito = e.num_credito
            and d.empresa = f.empresa
            and d.num_credito = f.num_credito
            and d.empresa = i.empresa
            and d.num_credito = i.num_solicitud
            and d.empresa = '001'
            and i.numcte_ref = 'R1'
            and e.status_tar = 'A'
            and e.tipo_tarjeta = 'T'
            and e.secuencia = ( select max(secuencia) from bdicred:sd_tarjeta ab
                    where ab.empresa = e.empresa
                      and ab.num_credito= e.num_credito)
            and b.numerociudad = j.numerociudad
            and f.mto_venc_trasp between monto_ini and monto_fin
            and d.status_cred in ('BT','BA', 'FC')             -- Estatus credito
            and d.numcte not in (select numcliente from cb_compac) -- que no tengan compromiso
            --and h.sucursal = a.sucursal 
            --and h.empresa = a.empresa

----------------------------------------------------------------------
                LET vtelefono_celular = '045' || substr(vtelefono_celular,length(vtelefono_celular)-9,10);

                IF vtelefono_celular = '045' THEN
                    LET vtelefono_celular = '';
                END IF;

----------------------------------------------------------------------

                SELECT 
                --NVL (SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),0),                            -- Interes Vencido
                --NVL (SUM(NVL(iva_debe,0) - NVL(iva_pagado,0)),0),                                           -- Iva Interes Vencido
                --NVL (SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) -
                --NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),0),         -- Moratorios
                COUNT(*)                                                                                    -- Pagos Vencidos
                INTO 
                     --vinteres,
                     --viva_interes,
                     --vmoratorio,
                     vpagos_vencidos
                FROM bdicred:sd_amortiza_credito
                WHERE empresa     = '001'
                AND num_credito = vnum_credito
                AND capital_status IN ('2','7');

                --LET viva_moratorio= (vmoratorio * iva_cred);                                                --- iva_mora
                --LET vpago_minimo_total = v_monto_financiado + vinteres + viva_interes +
                --                         vmoratorio + viva_moratorio + 1;                                   --- Pago minimo

                -- el ultimo digito con valor 1 es a peticion de la gerencia de credito para redondear el pago minimo


                --LET vsaldo_total= vinteres + viva_interes + vmoratorio + viva_moratorio +
                  --                v_saldo_retenido + v_saldo_capital_insoluto;

---------------FECHA Y MONTO ULTIMO DE PAGO----------------------------------------------------------

                /*SELECT fecha_ult_pago
                INTO dtFechaUltPago
                FROM bdicred:sd_maecredanexo
                WHERE num_credito = vnum_credito
                AND empresa = '001';

                SELECT NVL(sum (monto),0)
                INTO monto_pago
                FROM bdicred:sd_movhis
                WHERE empresa = '001'
                AND fecha_mov = dtFechaUltPago 
                AND num_credito = vnum_credito
                AND codigo_fun IN ('033','334','335','336','901','337')
                AND codigo_ref IN ( 1, 901)
                AND reversado = 'N';*/


                --LET vfecha_monto_ultimo_pago        = dtFechaUltPago || '-' || monto_pago;
                --LET v_pago_min_sin_vdo              = vpago_minimo_total - vsdo_vdo_int_mora;  


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

---------------SE INCERTAN DATOS GENERADOS----------------------------------------------------------

			 INSERT INTO cb_info_administrativa (cliente, credito, tarjeta, ciudad, estado, nombre, sexo, civil,
                                        t_casa, t_celular, t_trabajo, ext, nombre_ref, t_ref, pago_venc, 
                                        fecha_ejecucion)
			  VALUES(vnumcte, vnum_credito, vnum_tarjeta, vciudad, vestado, vnombre, vsexo, vestado_civil,
                                        vtelefono_casa, vtelefono_celular, vtelefono_trabajo, vext_trabajo, vnombre_ref, vtelefono_ref,
                                        vpagos_vencidos, current);
                    END IF;

END FOREACH;
	  SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
	  SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

        INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
        VALUES('Cobranza Administrativa', cCod_ret, cMensaje, pUsuario, vdia,  vhora);

		RETURN cCod_ret, cMensaje;

	END;
END PROCEDURE;