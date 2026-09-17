CREATE PROCEDURE "informix".sp_cat_auronix_target_phone(ptipo_cobranza CHAR(1), pfecha_insert DATE)
       RETURNING char(6), char(150);

DEFINE sql_err 			    INTEGER;
DEFINE isam_err 		    INTEGER;
DEFINE error_info		    CHAR(150);
DEFINE cMensaje 		    CHAR(150);
DEFINE cCod_ret             CHAR(6);
DEFINE vempresa             CHAR(3);
DEFINE cproceso             CHAR(4);
DEFINE vvcCod_ret           CHAR(6);
DEFINE vnumcte              CHAR(20);
DEFINE vnum_credito         CHAR(20);
DEFINE vpago_venc           INTEGER;
DEFINE vvvccod_ret          CHAR(6);
DEFINE vvvcmensaje 		    CHAR(150);
DEFINE vpago_minimo_total   DECIMAL (18,2);
DEFINE vsaldo_total         DECIMAL(18,2);
DEFINE v_mto_venc_trasp     DECIMAL(18,2);
DEFINE v_monto_financiado   DECIMAL (18, 2);
DEFINE v_sdo_retenido       DECIMAL(18,2);
DEFINE v_sdo_cap_insoluto   DECIMAL(18,2);
DEFINE v_sucursal           CHAR(4);
DEFINE vinteres             DECIMAL(18,2);
DEFINE viva_interes         DECIMAL(18,2);
DEFINE vmoratorio           DECIMAL(18,2);
DEFINE viva_moratorio       DECIMAL(18,2);
DEFINE v_iva                DECIMAL(18,2);
DEFINE v_sdo_venc_int_mora  DECIMAL(18,2);
DEFINE v_pago_min_sin_vdo   DECIMAL(18,2);
DEFINE vdia					DATE;
DEFINE vdia2                DATE;
DEFINE v_celular            CHAR(13);
DEFINE pfecha_insertt       DATE;
DEFINE pfch_corte           DATE;
DEFINE vciudad              CHAR(20);
DEFINE vestado              CHAR(20);

--SET DEBUG FILE TO '/tmp/sp_cat_auronix_target_phone.out';
--TRACE ON;

      LET cCod_ret          = '000000';
	  LET sql_err           = 0;
	  LET isam_err          = 0;
	  LET error_info        = '';
	  LET cMensaje          = 'PROCESO EXITOSO';
      LET vempresa          = '001';
      LET cproceso          = '0026';
      LET v_sucursal        = '';
      LET pfecha_insertt    = pfecha_insert - 1 units month;
      LET pfch_corte        = pfecha_insertt + 8 units day;


    BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET cMensaje = error_info;
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02')
            RETURNING vvcCod_ret;
			RETURN cCod_ret, cMensaje;
	    END EXCEPTION;


            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01')
            RETURNING vvcCod_ret;

        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
        SELECT {+FULL} MAX(fecha_ejecucion) INTO vdia2 FROM bdicobranza:cb_info_administrativa;
 
        IF(vdia2 = vdia ) THEN
            DELETE {+INDEX(cb_info_administrativa idx_cbinfoadmin)} bdicobranza:cb_info_administrativa WHERE fecha_ejecucion = vdia2;
        ELSE
            DELETE {+INDEX(cb_info_administrativa idx_cbinfoadmin)} bdicobranza:cb_info_administrativa WHERE fecha_ejecucion < vdia2;
        END IF;
    
        SET ISOLATION TO dirty READ;
        FOREACH

            SELECT a.numcte, a.num_credito, a.pago_venc, NVL(b.mto_venc_trasp + b.monto_vencido, 0), NVL(b.monto_financiado, 0)
                   ,NVL(b.sdo_retenido, 0), NVL(b.sdo_cap_insoluto, 0), d.sucursal, NVL(e.iva, 0), f.telefono
                   ,h.numerociudad || '-' || trim(i.inicialciudad) Ciudad
                   ,i.numeroestado || '-' || trim(i.inicialestado) Estado
            INTO vnumcte, vnum_credito, vpago_venc, v_mto_venc_trasp, v_monto_financiado, v_sdo_retenido
                 ,v_sdo_cap_insoluto, v_sucursal, v_iva, v_celular, vciudad, vestado
            FROM bdicobranza:cb_cat_directorio_cte a
            LEFT JOIN bdicred:sd_maesdos b ON (b.empresa = a.empresa AND b.num_credito = a.num_credito)
            LEFT JOIN bdinteg:si_cliente d ON (d.numcte = a.numcte)
            LEFT JOIN bdinteg:si_sucursales e ON (e.empresa = a.empresa AND e.sucursal = v_sucursal)
            --LEFT JOIN bdicobranza:cb_telefonos f ON (f.numcte = a.numcte AND f.tipo_telefono = 2 AND f.fecha_insert <> '2010-11-21')
            LEFT JOIN bdicobranza:cb_telefonos f ON (f.numcte = a.numcte AND f.tipo_telefono = 2 AND f.fecha_insert is not null)
            LEFT JOIN bdinteg:si_direcciones h ON (h.numcte = a.numcte AND h.secuencia = (select max(secuencia) from bdinteg:si_direcciones l
                                                                                          where l.numcte = h.numcte AND l.tipo_dir = '1')
                                                                                          AND h.tipo_dir = '1')
            LEFT JOIN bdinteg:si_catciudades i ON ( i.numerociudad = h.numerociudad)
            WHERE a.tipo_cobranza = ptipo_cobranza
            AND a.fecha_insert =  pfch_corte
            AND a.status_cliente = 'AC'

            IF v_celular IS NOT NULL THEN

                    SELECT {+INDEX(bdicred:sd_amortiza_credito amorst)} NVL (SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),0),
                    NVL (SUM(NVL(iva_debe,0) - NVL(iva_pagado,0)),0),
                    NVL (SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) -
                    NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),0)
                    INTO vinteres, viva_interes, vmoratorio
                    FROM bdicred:sd_amortiza_credito
                    WHERE empresa = vempresa
                    AND num_credito = vnum_credito
                    AND capital_status IN ('2','7','6');


                    LET viva_moratorio = (vmoratorio * v_iva);
                    LET v_sdo_venc_int_mora = v_mto_venc_trasp + vmoratorio + viva_moratorio;
                    LET vpago_minimo_total = v_monto_financiado + vinteres + viva_interes +
                                            vmoratorio + viva_moratorio;
                    LET v_pago_min_sin_vdo = vpago_minimo_total - v_sdo_venc_int_mora;
            
                    INSERT INTO informix.cb_info_administrativa(cliente, credito, tarjeta, ciudad, estado, nombre, sexo, civil, t_casa, t_celular, t_trabajo, ext, nombre_ref, t_ref, sdo_total, pago_min, sdo_venc_int_mora, f_ult_pago_monto, pago_venc, pago_min_sin_vdo, fecha_ejecucion, causa, situacion) 
                    VALUES(vnumcte, vnum_credito, '', vciudad, vestado, '', '', '', '', v_celular, '', '', '', '', 0, vpago_minimo_total, v_sdo_venc_int_mora, '', vpago_venc, v_pago_min_sin_vdo, TODAY, 0, '');
                    
            END IF;
END FOREACH;

            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '03')
            RETURNING vvcCod_ret;
	  
		RETURN cCod_ret, cMensaje;

	END;
END PROCEDURE;