CREATE PROCEDURE "informix".execmuestraedocta(pempresa CHAR(3),pfechahoy DATE)
RETURNING CHAR(5);
 
 
DEFINE v_empresa        CHAR(3);
DEFINE v_num_credito    CHAR(20);
 
 
DEFINE v_id_registro    CHAR(3);
DEFINE v_marca                              CHAR(3);
 
DEFINE sql_err          INTEGER;
DEFINE v_cod_ret         CHAR(5);
 
DEFINE v_descripcion          CHAR(50);
DEFINE v_fechamov             CHAR(50);
 
LET v_fechamov        = "";
 
--SET DEBUG FILE TO "muestra.out";
--TRACE ON;
 
BEGIN
 
 
  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_cod_ret = sql_err;
 
            RETURN v_cod_ret;
        END IF
   END EXCEPTION;
 
            -------------------------------------------------------
            --SE INICIALIZA TABLA PARA EDOCTAS
            ------------------------------------------------------
            TRUNCATE SD_MOVHISEDOCTA;
        --------------------------------------------------------
            --SE OBTIENE FECHA HOY MENOS UN MES
            --------------------------------------------------------
            CALL CALCULAFECHA(PFECHAHOY) RETURNING V_FECHAMOV;
            --------------------------------------------------------
            --         PREPARA LA TABLA  PARA EDOCTAS
            -------------------------------------------------------
 
            insert into sd_movhisedocta
                        select a.empresa,a.secuencia,a.fecha_mov,a.hora_mov,a.sucursal,
                       a.num_credito,a.plaza,a.transacc_suc,a.usuario,a.monto,
                       a.codigo_fun,a.codigo_ref,a.divisa,a.reversado,a.folio_suc,a.num_producto,
                               a.nro_tarjeta,a.referencia,a.tipo_cambio,a.monto_dls,a.suc_origen,
                               a.rfc_comer,a.referencia23
                from sd_movhis a, sd_transfun b , bdinteg:si_transacc  c
                        where a.empresa = pempresa
                    and a.num_credito in (select num_credito from muestra)
                and a.codigo_fun = b.codigo_fun
                        and a.codigo_ref  = b.codigo_ref
                        and c.numero = b.transacc
                        and c.se_emite_edocta = "S"
						and c.sistema ="06"
                        and fecha_mov > v_fechamov
                        and fecha_mov <= pfechahoy
                        and reversado <> "S";
 
            -------------------------------------------------------
        --SE ARREGLAN TRANSACCIONES
        ------------------------------------------------------
            CALL ARR_MOVHIS();
            -------------------------------------------------------
        --SE CORRE ACTUALIZACION DE ESTADISTICAS
        ------------------------------------------------------
            UPDATE STATISTICS HIGH FOR TABLE SD_MOVHISEDOCTA;
 
            LET v_cod_ret = "000";
 
            --------------------------------------------------------
            --         GENERA LOS ENCABEZADOS DE LOS ARCHIVOS
            -------------------------------------------------------
 
            LET v_id_registro = "000";
            LET v_marca       = "0";
 
            IF NOT EXISTS(SELECT * FROM sd_encabezado_edocta
                        WHERE fecha_emision = pfechahoy
                        AND num_credito = v_id_registro) THEN
 
                        INSERT INTO sd_encabezado_edocta
                                   (
                                    fecha_emision,num_credito, numcte,
                                    num_tarjeta, nombre_cte,direccion_cn,
                                    direccion_col,direccion_del,edo_cd,
                                     sucursal_nombre,sucursal_gerente,
                                     sucursal_tel,fecha_corte,rfc,
                                     cl_cobra,CP,ruta
                                   )
                        VALUES  (
                                    pfechahoy,v_id_registro,v_marca,
                                     "0","0","0",
                                    "0","0","0",
                                    "0","0",
                                    "0",pfechahoy,"0",
                                    "0","0","0"
                                   );
            END IF
 
 
            LET v_id_registro = "100";
            LET v_marca       = "0";
 
 
            IF NOT EXISTS(SELECT * FROM sd_encabezado_edocta
                              WHERE fecha_emision = pfechahoy
                              AND num_credito = v_id_registro) THEN
 
                        INSERT INTO sd_encabezado_edocta
                                   (
                                    fecha_emision,num_credito, numcte,
                                    num_tarjeta, nombre_cte,direccion_cn,
                                    direccion_col,direccion_del,edo_cd,
                                     sucursal_nombre,sucursal_gerente,
                                     sucursal_tel,fecha_corte,rfc,
                                     cl_cobra,CP,ruta
                                   )
                        VALUES  (
                                    pfechahoy,v_id_registro,v_marca,
                                     "0","0","0",
                                    "0","0","0",
                                    "0","0",
                                    "0",pfechahoy,"0",
                                    "0","0","0"
                                   );
             END IF
 
 
            LET v_id_registro = "200";
            LET v_marca       = "0";
 
 
            IF NOT EXISTS(SELECT * FROM sd_encabezado2_edocta
                              WHERE fecha_emision = pfechahoy
                              AND num_credito = v_id_registro) THEN
 
                        INSERT INTO sd_encabezado2_edocta
                                   (
                                    fecha_emision, num_credito, sdo_pagar,
                                    sdo_debe, sdo_disponible, pago_antes_de,
                                    fecha_corte, menos_abonos, menos_o_abonos,
                                    mas_compras, mas_o_cargos, mas_disp_efectivo,
                                    mas_intereses, usted_debia, mas_iva,
                                    usted_debe, mas_rendimientos
                                   )
                        VALUES
                                   (
                                    pfechahoy, v_id_registro, v_marca,
                                    "0", "0", pfechahoy,
                                    pfechahoy, "0", "0",
                                    "0", "0", "0",
                                    "0", "0", "0",
                                    "0", "0"
                                   );
            END IF
 
 
            --CONTROL DEL ARCHIVO
 
            LET v_id_registro = "300";
            LET v_marca       = "0";
 
            IF NOT EXISTS(SELECT * FROM sd_detalle_edocta
                              WHERE fecha_emision = pfechahoy
                              AND num_credito = v_id_registro) THEN
 
                        INSERT INTO sd_detalle_edocta
                                   (
                                   fecha_emision, num_credito, secuencia,
                                   fecha_mov, concepto, cargos,
                                   abonos, nlinea
                                   )
                        VALUES
                        (
                        pfechahoy,v_id_registro,v_marca,
                        "0", "0", "0",
                                               "0", "0"
                        );
 
            END IF
 
 
            LET v_id_registro = "400";
            LET v_marca       = "0";
 
            IF NOT EXISTS(SELECT * FROM sd_pie_edocta
                              WHERE fecha_emision = pfechahoy
                              AND num_credito = v_id_registro) THEN
 
                        INSERT INTO sd_pie_edocta
                                   (
                                   fecha_emision,num_credito,tasa_mensual,
                                   tasa_anual, cat, saldo_promedio,
                                   dias_periodo
                                   )
                        VALUES  (
                                   pfechahoy, v_id_registro, v_marca,
                                   "0", "0", "0",
                                   "0"
                                   );
              END IF
 
 
            --------------------------------------------------------
            --         GENERA UNO A UNO LOS ESTADOS DE CUENTA
            -------------------------------------------------------
            FOREACH SELECT empresa,num_credito
                                   INTO v_empresa,v_num_credito
                                   FROM sd_maesdoshist
            WHERE fecha = pfechahoy
            AND empresa = pempresa
            AND num_credito NOT IN
            (SELECT num_credito FROM sd_encabezado_edocta
             WHERE fecha_emision = pfechahoy)
                AND num_credito in (select num_credito from muestra)
 
                        EXECUTE PROCEDURE ugenera_edocuenta
                                                           (
                                                           v_empresa,
                                                           v_num_credito,
                                                           pfechahoy
                                                           ) INTO v_cod_ret;
 
            IF v_cod_ret <> "000" THEN
                        SELECT descripcion
                        INTO v_descripcion
                        FROM bdinteg:si_codret
                        WHERE codigo_retorno = v_cod_ret
                        AND sistema  ="06";
 
                        INSERT INTO sd_valedocta
                                   (empresa,num_credito,cod_ret,descripcion,fecha_proc,tipo)
                        VALUES
                                   (v_empresa,v_num_credito,v_cod_ret,v_descripcion,pfechahoy,"E");
 
                        END IF
            END FOREACH;
 
END;
 
            RETURN "000";
 
END PROCEDURE ;