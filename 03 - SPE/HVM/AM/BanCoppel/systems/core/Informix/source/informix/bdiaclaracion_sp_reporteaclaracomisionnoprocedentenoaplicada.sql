CREATE PROCEDURE "informix".sp_reporteaclaracomisionnoprocedentenoaplicada(e_fechaIni DATE, e_fechaFin DATE,e_producto INTEGER,e_tipoBusqueda INTEGER)

RETURNING   
                           VARCHAR(11) AS folio_csuac,
                           DATETIME YEAR to FRACTION(5) AS fecha_trans,
                           VARCHAR (9) AS cliente,
                           VARCHAR (20) AS cuenta,
                           VARCHAR (16) AS tarjeta,
                           VARCHAR (100) AS nombre_cliente,
                           MONEY AS total_cobro_comision,
                           MONEY AS monto_cargado_comision,
                           MONEY AS monto_no_aplicado_comision,
                           MONEY AS total_cobro_iva,
                           MONEY AS monto_cargado_iva,
                           MONEY AS monto_no_aplicado_iva,
                           MONEY AS suma_tcc,
                           MONEY AS suma_mcc,
                           MONEY AS suma_mnac,
                           MONEY AS suma_tci,
                           MONEY AS suma_mci,
                           MONEY AS suma_mnai;

    /* Variables internas */                       
    DEFINE v_folio_csuac VARCHAR(11) ;
    DEFINE v_fecha_trans DATETIME YEAR to FRACTION(5);
    DEFINE v_cliente VARCHAR (9);
    DEFINE v_cuenta VARCHAR (20) ;
    DEFINE v_tarjeta VARCHAR (16) ;
    DEFINE v_nombre_cliente  VARCHAR(100);
    DEFINE v_total_cobro_comision MONEY;
    DEFINE v_monto_cargado_comision MONEY;
    DEFINE v_monto_no_aplicado_comision MONEY;
    DEFINE v_total_cobro_iva MONEY;
    DEFINE v_monto_cargado_iva MONEY;
    DEFINE v_monto_no_aplicado_iva MONEY;
    DEFINE v_suma_tcc MONEY;
    DEFINE v_suma_mcc MONEY;
    DEFINE v_suma_mnac MONEY;
    DEFINE v_suma_tci MONEY;
    DEFINE v_suma_mci MONEY;
    DEFINE v_suma_mnai MONEY;
    

	SET ISOLATION TO DIRTY READ;

    BEGIN
                  IF e_producto = 1 THEN --BUSQUEDA DE ACLARACIONES CON CREDITO
                    
                         FOREACH
                                SELECT  acl.folio_csuac, acl.fechacaptura,pro.num_cliente,pro.numero_cuenta,pro.numero_tarjeta,
                                                trim(sc.nombre1)|| ' ' ||trim(sc.nombre2)||' '||trim (sc.apell_paterno) ||' '||trim(sc.apell_materno) AS nombre_cliente,
                                                rec.total_comision, rec.comision_recuperada, (rec. total_comision-comision_recuperada)AS montoNoAplicadoComision,
                                                rec.total_iva, rec.iva_recuperada, (rec. total_iva-iva_recuperada)AS montoNoAplicadoIva,SUM(rec.total_comision) AS suma_tcc,
                                                SUM(rec.comision_recuperada)AS suma_mcc, SUM(rec.total_comision - rec.comision_recuperada) AS suma_mnac, 
                                                sum(rec.total_iva) AS suma_tci,SUM (rec.iva_recuperada) AS suma_mci,SUM (rec.total_iva - rec.iva_recuperada) AS suma_mnai
                                INTO   v_folio_csuac, v_fecha_trans, v_cliente, v_cuenta, v_tarjeta, v_nombre_cliente, v_total_cobro_comision, v_monto_cargado_comision,
                                            v_monto_no_aplicado_comision, v_total_cobro_iva, v_monto_cargado_iva, v_monto_no_aplicado_iva,v_suma_tcc,v_suma_mcc,v_suma_mnac,v_suma_tci,v_suma_mci,v_suma_mnai
                                FROM bdiaclaracion:acl_recuperacion_saldos rec
                                    INNER JOIN bdiaclaracion:acl_aclaracion acl  ON acl.folio_csuac = rec.folio_csuac
                                    INNER JOIN bdiaclaracion:acl_producto pro ON acl.fky_producto = pro.pky_producto
                                    INNER JOIN bdiaclaracion:acl_tipo_producto tp ON tp.pky_tipo_producto=pro.fky_tipo_producto
                                    INNER JOIN bdiaclaracion:acl_movimiento mov ON (mov.folio_csuac=rec.folio_csuac AND mov.fky_padre IS not NULL AND mov.cargo=1)
                                    INNER JOIN  bdinteg:si_cliente sc ON sc.numcte = acl.num_cliente
                               WHERE 
                                    rec.abono_irrecuperable=1 AND tp.tipo_producto=1 AND rec.total_comision<>0 
                                    AND pky_recuperacion = (SELECT max (pky_recuperacion) FROM bdiaclaracion:acl_recuperacion_saldos WHERE folio_csuac =acl.folio_csuac)
                                    AND ((e_tipoBusqueda = 1 AND acl.fechacaptura BETWEEN e_fechaIni AND e_fechaFin)
                                    OR   (e_tipoBusqueda = 2 AND date(acl.fecha_dictamen) BETWEEN e_fechaIni  AND e_fechaFin) 
                                    OR    (e_tipoBusqueda = 3 AND date(mov.fechahora) BETWEEN e_fechaIni AND e_fechaFin))
                                    GROUP BY  acl.folio_csuac, acl.fechacaptura,pro.num_cliente,pro.numero_cuenta,pro.numero_tarjeta,
                                                nombre_cliente,rec.total_comision, rec.comision_recuperada, montoNoAplicadoComision,
                                                rec.total_iva, rec.iva_recuperada, montoNoAplicadoIva
                                
                                RETURN v_folio_csuac,v_fecha_trans,v_cliente,v_cuenta,v_tarjeta,v_nombre_cliente, v_total_cobro_comision,v_monto_cargado_comision,v_monto_no_aplicado_comision,
                                                v_total_cobro_iva,v_monto_cargado_iva,v_monto_no_aplicado_iva,v_suma_tcc,v_suma_mcc,v_suma_mnac,v_suma_tci,v_suma_mci,v_suma_mnai
                                 WITH resume;
                          END FOREACH;

                END IF ---BUSQUEDA DE ACLARACIONES CON CREDITO
           
                IF e_producto = 2 THEN --BUSQUEDA DE ACLARACIONES CON DEBITO
                    
                                       FOREACH
                                SELECT  acl.folio_csuac, acl.fechacaptura,pro.num_cliente,pro.numero_cuenta,pro.numero_tarjeta,
                                                trim(sc.nombre1)|| ' ' ||trim(sc.nombre2)||' '||trim (sc.apell_paterno) ||' '||trim(sc.apell_materno) AS nombre_cliente,
                                                rec.total_comision, rec.comision_recuperada, (rec. total_comision-comision_recuperada)AS montoNoAplicadoComision,
                                                rec.total_iva, rec.iva_recuperada, (rec. total_iva-iva_recuperada)AS montoNoAplicadoIva,SUM(rec.total_comision) AS suma_tcc,
                                                SUM(rec.comision_recuperada)AS suma_mcc, SUM(rec.total_comision - rec.comision_recuperada) AS suma_mnac, 
                                                sum(rec.total_iva) AS suma_tci,SUM (rec.iva_recuperada) AS suma_mci,SUM (rec.total_iva - rec.iva_recuperada) AS suma_mnai
                                INTO   v_folio_csuac, v_fecha_trans, v_cliente, v_cuenta, v_tarjeta, v_nombre_cliente, v_total_cobro_comision, v_monto_cargado_comision,
                                            v_monto_no_aplicado_comision, v_total_cobro_iva, v_monto_cargado_iva, v_monto_no_aplicado_iva,v_suma_tcc,v_suma_mcc,v_suma_mnac,v_suma_tci,v_suma_mci,v_suma_mnai
                                FROM bdiaclaracion:acl_recuperacion_saldos rec
                                    INNER JOIN bdiaclaracion:acl_aclaracion acl  ON acl.folio_csuac = rec.folio_csuac
                                    INNER JOIN bdiaclaracion:acl_producto pro ON acl.fky_producto = pro.pky_producto
                                    INNER JOIN bdiaclaracion:acl_tipo_producto tp ON tp.pky_tipo_producto=pro.fky_tipo_producto
                                    INNER JOIN bdiaclaracion:acl_movimiento mov ON (mov.folio_csuac=rec.folio_csuac AND mov.fky_padre IS not NULL AND mov.cargo=1)
                                    INNER JOIN  bdinteg:si_cliente sc ON sc.numcte = acl.num_cliente
                               WHERE 
                                    rec.abono_irrecuperable=1 AND tp.tipo_producto=2 AND rec.total_comision<>0 
                                    AND pky_recuperacion = (SELECT max (pky_recuperacion) FROM bdiaclaracion:acl_recuperacion_saldos WHERE folio_csuac =acl.folio_csuac)
                                    AND ((e_tipoBusqueda = 1 AND acl.fechacaptura BETWEEN e_fechaIni AND e_fechaFin)
                                    OR   (e_tipoBusqueda = 2 AND date(acl.fecha_dictamen) BETWEEN e_fechaIni AND e_fechaFin) 
                                    OR    (e_tipoBusqueda = 3 AND date(mov.fechahora) BETWEEN e_fechaIni AND e_fechaFin))
                                    GROUP BY  acl.folio_csuac, acl.fechacaptura,pro.num_cliente,pro.numero_cuenta,pro.numero_tarjeta,
                                                nombre_cliente,rec.total_comision, rec.comision_recuperada, montoNoAplicadoComision,
                                                rec.total_iva, rec.iva_recuperada, montoNoAplicadoIva
                                
                                RETURN v_folio_csuac,v_fecha_trans,v_cliente,v_cuenta,v_tarjeta,v_nombre_cliente, v_total_cobro_comision,v_monto_cargado_comision,v_monto_no_aplicado_comision,
                                                v_total_cobro_iva,v_monto_cargado_iva,v_monto_no_aplicado_iva,v_suma_tcc,v_suma_mcc,v_suma_mnac,v_suma_tci,v_suma_mci,v_suma_mnai
                                 WITH resume;
                          END FOREACH;

                        
                END IF ---BUSQUEDA DE ACLARACIONES CON DEBITO
 
                IF e_producto = 3 THEN --BUSQUEDA DE ACLARACIONES AMBOS
    FOREACH
                                SELECT  acl.folio_csuac, acl.fechacaptura,pro.num_cliente,pro.numero_cuenta,pro.numero_tarjeta,
                                                trim(sc.nombre1)|| ' ' ||trim(sc.nombre2)||' '||trim (sc.apell_paterno) ||' '||trim(sc.apell_materno) AS nombre_cliente,
                                                rec.total_comision, rec.comision_recuperada, (rec. total_comision-comision_recuperada)AS montoNoAplicadoComision,
                                                rec.total_iva, rec.iva_recuperada, (rec. total_iva-iva_recuperada)AS montoNoAplicadoIva,SUM(rec.total_comision) AS suma_tcc,
                                                SUM(rec.comision_recuperada)AS suma_mcc, SUM(rec.total_comision - rec.comision_recuperada) AS suma_mnac, 
                                                sum(rec.total_iva) AS suma_tci,SUM (rec.iva_recuperada) AS suma_mci,SUM (rec.total_iva - rec.iva_recuperada) AS suma_mnai
                                INTO   v_folio_csuac, v_fecha_trans, v_cliente, v_cuenta, v_tarjeta, v_nombre_cliente, v_total_cobro_comision, v_monto_cargado_comision,
                                            v_monto_no_aplicado_comision, v_total_cobro_iva, v_monto_cargado_iva, v_monto_no_aplicado_iva,v_suma_tcc,v_suma_mcc,v_suma_mnac,v_suma_tci,v_suma_mci,v_suma_mnai
                                FROM bdiaclaracion:acl_recuperacion_saldos rec
                                    INNER JOIN bdiaclaracion:acl_aclaracion acl  ON acl.folio_csuac = rec.folio_csuac
                                    INNER JOIN bdiaclaracion:acl_producto pro ON acl.fky_producto = pro.pky_producto
                                    INNER JOIN bdiaclaracion:acl_tipo_producto tp ON tp.pky_tipo_producto=pro.fky_tipo_producto
                                    INNER JOIN bdiaclaracion:acl_movimiento mov ON (mov.folio_csuac=rec.folio_csuac AND mov.fky_padre IS not NULL AND mov.cargo=1)
                                    INNER JOIN  bdinteg:si_cliente sc ON sc.numcte = acl.num_cliente
                               WHERE 
                                    rec.abono_irrecuperable=1 AND (tp.tipo_producto=1 OR tp.tipo_producto=2) AND rec.total_comision<>0 
                                    AND pky_recuperacion = (SELECT max (pky_recuperacion) FROM bdiaclaracion:acl_recuperacion_saldos WHERE folio_csuac =acl.folio_csuac)
                                    AND ((e_tipoBusqueda = 1 AND acl.fechacaptura BETWEEN e_fechaIni AND e_fechaFin)
                                    OR   (e_tipoBusqueda = 2 AND date(acl.fecha_dictamen) BETWEEN e_fechaIni  AND e_fechaFin) 
                                    OR    (e_tipoBusqueda = 3 AND date(mov.fechahora) BETWEEN e_fechaIni AND e_fechaFin))
                                    GROUP BY  acl.folio_csuac, acl.fechacaptura,pro.num_cliente,pro.numero_cuenta,pro.numero_tarjeta,
                                                nombre_cliente,rec.total_comision, rec.comision_recuperada, montoNoAplicadoComision,
                                                rec.total_iva, rec.iva_recuperada, montoNoAplicadoIva
                                
                                RETURN v_folio_csuac,v_fecha_trans,v_cliente,v_cuenta,v_tarjeta,v_nombre_cliente, v_total_cobro_comision,v_monto_cargado_comision,v_monto_no_aplicado_comision,
                                                v_total_cobro_iva,v_monto_cargado_iva,v_monto_no_aplicado_iva,v_suma_tcc,v_suma_mcc,v_suma_mnac,v_suma_tci,v_suma_mci,v_suma_mnai
                                 WITH resume;
                          END FOREACH;

                END IF -----BUSQUEDA DE ACLARACIONES AMBOS
END; --end begin

END PROCEDURE;