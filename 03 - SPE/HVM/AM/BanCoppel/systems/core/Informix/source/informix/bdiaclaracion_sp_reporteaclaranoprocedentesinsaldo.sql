CREATE PROCEDURE "informix".sp_reporteaclaranoprocedentesinsaldo(e_fechaIni CHAR(15), e_fechaFin CHAR(15),e_producto INTEGER,e_tipoBusqueda INTEGER)

RETURNING   
                           CHAR(11) AS folio_csuac,
                           DATETIME YEAR to FRACTION(5) AS fecha_trans,
                           DATETIME YEAR to FRACTION(5) AS fecha_abono_trans,
                           CHAR (20) AS cuenta,
                           CHAR (16) AS tarjeta,
                           CHAR (100) AS nombre_cliente,
                           MONEY AS importe_reclamado,
                           MONEY AS importe_abonado,
                           MONEY AS importe_recuperado,
                           MONEY AS importe_quebranto,
                           MONEY AS interes_pagado,
                           MONEY AS interes_recuperado,
                           DATE AS inicio_recuperacion,
                           DATE AS termino_recuperacion;

    DEFINE v_folio_csuac CHAR(11) ;
    DEFINE v_fecha_trans DATETIME YEAR to FRACTION(5);
    DEFINE v_fecha_abono_trans DATETIME YEAR to FRACTION(5);
    DEFINE v_cuenta CHAR (20) ;
    DEFINE v_tarjeta CHAR (16) ;
    DEFINE v_nombre_cliente  CHAR(100);
    DEFINE v_importe_reclamado MONEY ;
    DEFINE v_importe_abonado MONEY;
    DEFINE v_importe_recuperado MONEY;
    DEFINE v_importe_quebranto MONEY;
    DEFINE v_interes_pagado MONEY;
    DEFINE v_interes_recuperado MONEY;
    DEFINE v_inicio_recuperacion DATE;
    DEFINE v_termino_recuperacion DATE;
    DEFINE p_interes_abonado MONEY;
    DEFINE fecha_inicial_convertida DATE;
    DEFINE fecha_final_convertida DATE;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN
             LET fecha_inicial_convertida =(TO_DATE(e_fechaIni,'%Y-%m-%d')) ;
             LET fecha_final_convertida = (TO_DATE(e_fechaFin,'%Y-%m-%d'));

                IF e_producto = 1 THEN --BUSQUEDA DE ACLARACIONES CON CREDITO
                            
                            FOREACH
                                SELECT  DISTINCT 
                                    acl.folio_csuac,
                                    date(mov.fechahora) as fecha,
                                    mov.fecha_afectacion,
                                    pro.numero_cuenta,
                                    pro.numero_tarjeta,
                                    trim(sc.nombre1)|| ' ' ||trim(sc.nombre2)||' '||trim (sc.apell_paterno) ||' '||trim(sc.apell_materno) AS nombre_cliente,
                                    acl.importereclamado,
                                    rec.total_abono,
                                    rec.abono_recuperado,
                                    (acl.importereclamado - rec.abono_recuperado)AS quebranto,
                                    rec.total_interes,
                                    rec.interes_recuperado,
                                    rec.f_recuperacion,
                                    rec.fa_recuperacion
                                INTO 
                                    v_folio_csuac,
                                    v_fecha_trans,
                                    v_fecha_abono_trans,
                                    v_cuenta,
                                    v_tarjeta,
                                    v_nombre_cliente,
                                    v_importe_reclamado,
                                    v_importe_abonado,
                                    v_importe_recuperado,
                                    v_importe_quebranto,  
                                    v_interes_pagado,
                                    v_interes_recuperado,
                                    v_inicio_recuperacion,
                                    v_termino_recuperacion
                                FROM "informix".acl_recuperacion_saldos rec
                                    INNER JOIN "informix".acl_aclaracion acl  ON acl.folio_csuac = rec.folio_csuac
                                    INNER JOIN "informix".acl_producto pro ON acl.fky_producto = pro.pky_producto
                                    INNER JOIN "informix".acl_tipo_producto tp ON tp.pky_tipo_producto=pro.fky_tipo_producto
                                    INNER JOIN "informix".acl_movimiento mov ON (mov.folio_csuac=rec.folio_csuac AND mov.fky_padre IS NULL AND mov.cargo=0)
                                    INNER JOIN  bdinteg:si_cliente sc ON sc.numcte = acl.num_cliente
                                WHERE rec.abono_irrecuperable=1 AND tp.tipo_producto=1 AND rec.total_abono<>0
                                AND pky_recuperacion = (SELECT max (pky_recuperacion) FROM "informix".acl_recuperacion_saldos WHERE folio_csuac =acl.folio_csuac)
                                AND ((e_tipoBusqueda = 1 AND acl.fechacaptura BETWEEN fecha_inicial_convertida AND fecha_final_convertida)
                                    OR   (e_tipoBusqueda = 2 AND date(acl.fecha_dictamen) BETWEEN fecha_inicial_convertida  AND fecha_final_convertida) 
                                    OR    (e_tipoBusqueda = 3 AND date(mov.fechahora) BETWEEN fecha_inicial_convertida AND fecha_final_convertida))
                                
                                    RETURN v_folio_csuac, v_fecha_trans, v_fecha_abono_trans, v_cuenta, v_tarjeta,  v_nombre_cliente, v_importe_reclamado,  v_importe_abonado, v_importe_recuperado, v_importe_quebranto,v_interes_pagado,v_interes_recuperado, v_inicio_recuperacion, v_termino_recuperacion
                                WITH resume;
                           END FOREACH;
                            
                END IF ---BUSQUEDA DE ACLARACIONES CON CREDITO

                IF e_producto = 2 THEN --BUSQUEDA DE ACLARACIONES CON DEBITO
                    
                             FOREACH
                                SELECT  DISTINCT 
                                acl.folio_csuac,
                                date(mov.fechahora) as fecha,
                                mov.fecha_afectacion,
                                pro.numero_cuenta,
                                pro.numero_tarjeta,
                                trim(sc.nombre1)|| ' ' ||trim(sc.nombre2)||' '||trim (sc.apell_paterno) ||' '||trim(sc.apell_materno) AS nombre_cliente,
                                acl.importereclamado,
                                rec.total_abono,
                                rec.abono_recuperado,
                                rec.total_interes,
                                rec.interes_recuperado,
                                (acl.importereclamado - rec.abono_recuperado)AS quebranto,
                                rec.f_recuperacion,
                                rec.fa_recuperacion
                                
                                INTO 
                                v_folio_csuac,
                                v_fecha_trans,
                                v_fecha_abono_trans,
                                v_cuenta,
                                v_tarjeta,
                                v_nombre_cliente,
                                v_importe_reclamado,
                                v_importe_abonado,
                                v_importe_recuperado,
                                v_importe_quebranto,   
                                v_interes_pagado,
                                v_interes_recuperado,
                                v_inicio_recuperacion,
                                v_termino_recuperacion
                                FROM "informix".acl_recuperacion_saldos rec
                                INNER JOIN "informix".acl_aclaracion acl  ON acl.folio_csuac = rec.folio_csuac
                                INNER JOIN "informix".acl_producto pro ON acl.fky_producto = pro.pky_producto
                                INNER JOIN "informix".acl_tipo_producto tp ON tp.pky_tipo_producto=pro.fky_tipo_producto
                                INNER JOIN "informix".acl_movimiento mov ON (mov.folio_csuac=rec.folio_csuac AND mov.fky_padre IS NULL AND mov.cargo=0)
                                INNER JOIN  bdinteg:si_cliente sc ON sc.numcte = acl.num_cliente
                                WHERE rec.abono_irrecuperable=1 AND tp.tipo_producto=2 AND rec.total_abono<>0 
                                AND pky_recuperacion = (SELECT max (pky_recuperacion) FROM "informix".acl_recuperacion_saldos WHERE folio_csuac =acl.folio_csuac)
                                AND ((e_tipoBusqueda = 1 AND acl.fechacaptura BETWEEN fecha_inicial_convertida AND fecha_final_convertida)
                                    OR   (e_tipoBusqueda = 2 AND date(acl.fecha_dictamen) BETWEEN fecha_inicial_convertida  AND fecha_final_convertida) 
                                    OR    (e_tipoBusqueda = 3 AND date(mov.fechahora) BETWEEN fecha_inicial_convertida AND fecha_final_convertida))
                                
                                RETURN v_folio_csuac, v_fecha_trans, v_fecha_abono_trans, v_cuenta, v_tarjeta,  v_nombre_cliente, v_importe_reclamado,  v_importe_abonado, v_importe_recuperado,v_importe_quebranto,v_interes_pagado,v_interes_recuperado,  v_inicio_recuperacion, v_termino_recuperacion
                                 WITH resume;
                            END FOREACH;
                        
                END IF ---BUSQUEDA DE ACLARACIONES CON DEBITO

                IF e_producto = 3 THEN --BUSQUEDA DE ACLARACIONES AMBOS
                                FOREACH
                                    
                                    SELECT  DISTINCT 
                                        acl.folio_csuac,
                                        date(mov.fechahora) as fecha,
                                        mov.fecha_afectacion,
                                        pro.numero_cuenta,
                                        pro.numero_tarjeta,
                                        trim(sc.nombre1)|| ' ' ||trim(sc.nombre2)||' '||trim (sc.apell_paterno) ||' '||trim(sc.apell_materno) AS nombre_cliente,
                                        acl.importereclamado,
                                        rec.total_abono,
                                        rec.abono_recuperado,
                                        (acl.importereclamado - rec.abono_recuperado)AS quebranto,
                                        rec.total_interes,
                                        rec.interes_recuperado,
                                        rec.f_recuperacion,
                                        rec.fa_recuperacion
                                        INTO 
                                        v_folio_csuac,
                                        v_fecha_trans,
                                        v_fecha_abono_trans,
                                        v_cuenta,
                                        v_tarjeta,
                                        v_nombre_cliente,
                                        v_importe_reclamado,
                                        v_importe_abonado,
                                        v_importe_recuperado,
                                        v_importe_quebranto,   
                                        v_interes_pagado,
                                        v_interes_recuperado,
                                        v_inicio_recuperacion,
                                        v_termino_recuperacion                                        
                                        FROM "informix".acl_recuperacion_saldos rec
                                        INNER JOIN "informix".acl_aclaracion acl  ON acl.folio_csuac = rec.folio_csuac
                                        INNER JOIN "informix".acl_producto pro ON acl.fky_producto = pro.pky_producto
                                        INNER JOIN "informix".acl_tipo_producto tp ON tp.pky_tipo_producto=pro.fky_tipo_producto
                                        INNER JOIN "informix".acl_movimiento mov ON (mov.folio_csuac=rec.folio_csuac AND mov.fky_padre IS NULL AND mov.cargo=0)
                                        INNER JOIN  bdinteg:si_cliente sc ON sc.numcte = acl.num_cliente
                                        WHERE rec.abono_irrecuperable=1 AND (tp.tipo_producto=2 OR tp.tipo_producto=1) AND rec.total_abono<>0
                                        AND pky_recuperacion = (SELECT max (pky_recuperacion) FROM "informix".acl_recuperacion_saldos WHERE folio_csuac =acl.folio_csuac)
                                        AND ((e_tipoBusqueda = 1 AND acl.fechacaptura BETWEEN fecha_inicial_convertida AND fecha_final_convertida)
                                            OR   (e_tipoBusqueda = 2 AND date(acl.fecha_dictamen) BETWEEN fecha_inicial_convertida  AND fecha_final_convertida) 
                                            OR    (e_tipoBusqueda = 3 AND date(mov.fechahora) BETWEEN fecha_inicial_convertida AND fecha_final_convertida))
                                                                                
                                        RETURN v_folio_csuac, v_fecha_trans, v_fecha_abono_trans, v_cuenta, v_tarjeta,  v_nombre_cliente, v_importe_reclamado,  v_importe_abonado, v_importe_recuperado,v_importe_quebranto,v_interes_pagado,v_interes_recuperado,  v_inicio_recuperacion, v_termino_recuperacion
                                         WITH resume;
                                END FOREACH;
                END IF -----BUSQUEDA DE ACLARACIONES AMBOS
END; --end begin


END PROCEDURE;