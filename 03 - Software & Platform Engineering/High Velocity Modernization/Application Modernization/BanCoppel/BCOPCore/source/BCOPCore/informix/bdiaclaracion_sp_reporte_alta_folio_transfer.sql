CREATE PROCEDURE "informix".sp_reporte_alta_folio_transfer(input_fechaIni DATE, input_fechaFin DATE)

    RETURNING 
        VARCHAR(11) AS foliocsuac,
        VARCHAR(9) AS numerocliente,
        VARCHAR (20) AS cuenta,
        VARCHAR (16) AS tarjeta,
        VARCHAR (100)AS nombrecliente,
        DATETIME YEAR to FRACTION(5) AS fechatransaccion,
        MONEY AS importe,
        VARCHAR (10)AS numerosucursal,
        VARCHAR (40)AS nombrepromotor,
        DATE AS fechaalta,
        INTEGER AS tipoalta,
        VARCHAR (2) AS acusesms,
        VARCHAR (2) AS acusecorreo,
        VARCHAR (10) AS procede
--        SMALLINT AS procede
--     AS respuestaTransfer;

     DEFINE v_folio_csuac VARCHAR(11) ;
     DEFINE v_numero_cliente VARCHAR(9) ;
     DEFINE v_numero_cuenta VARCHAR(20) ;
     DEFINE v_numero_tarjeta VARCHAR(16) ;
     DEFINE v_nombre_cliente VARCHAR(100) ;
     DEFINE v_fecha_transaccion DATETIME YEAR to FRACTION(5) ;
     DEFINE v_importe MONEY ;
     DEFINE v_numero_sucursal VARCHAR(10) ;
     DEFINE v_nombre_promotor VARCHAR(45) ;
     DEFINE v_fecha_alta DATE ;
     DEFINE v_tipo_alta INTEGER ;
     DEFINE v_acuse_sms INTEGER ;
     DEFINE v_acuse_correo INTEGER ;
     DEFINE v_procede SMALLINT;

     DEFINE str_acuseSMS VARCHAR(2);
     DEFINE str_acuseCorreo VARCHAR(2);
     DEFINE str_procede VARCHAR(10);

        SET ISOLATION TO DIRTY READ;
    
            BEGIN
                FOREACH
                    SELECT DISTINCT
                        acl.folio_csuac AS foliocsuac, 
                        acl.num_cliente AS numerocliente, 
                        aclp.numero_cuenta AS cuenta, 
                        aclp.numero_tarjeta AS tarjeta, 
                        TRIM(sc.nombre1)|| ' ' || TRIM(sc.nombre2)||' '|| TRIM (sc.apell_paterno) ||' '|| TRIM(sc.apell_materno) AS nombrecliente, 
                        aclm.fechahora AS fechatransaccion,
                        acl.importereclamado AS importe, 
                        acl.num_sucursal AS numerosucursal, 
                        acl.nombre_empleado AS nombrepromotor ,
                        acl.fechacaptura AS fechaalta, 
                        acl.fky_cat_tipo_aclaracion AS tipoalta, 
                        acln.envio_sms AS acusesms, 
                        acln.envio_correo AS acusecorreo, 
                        acl.procede AS procede
                     INTO
                        v_folio_csuac,                         
                        v_numero_cliente, 
                        v_numero_cuenta, 
                        v_numero_tarjeta, 
                        v_nombre_cliente,
                        v_fecha_transaccion,
                        v_importe, 
                        v_numero_sucursal, 
                        v_nombre_promotor, 
                        v_fecha_alta, 
                        v_tipo_alta, 
                        v_acuse_sms, 
                        v_acuse_correo, 
                        v_procede 

                            FROM acl_aclaracion acl
                            INNER JOIN acl_producto aclp 
                                ON aclp.pky_producto = acl.fky_producto
                            INNER JOIN  bdinteg:si_cliente sc 
                                ON sc.numcte = acl.num_cliente                            
                            INNER JOIN acl_movimiento aclm
                                ON acl.folio_csuac = aclm.folio_csuac                            
                            INNER JOIN acl_notificacion_det acln 
                                ON acln.folio_csuac = acl.folio_csuac
                            WHERE acl.fky_cat_tipo_aclaracion = 4 
                                AND acl.fechacaptura BETWEEN input_fechaIni AND input_fechaFin                                

                                IF (v_acuse_sms = 1) THEN
                                LET str_acuseSMS = 'SI';
                                    ELSE 
                                        LET str_acuseSMS = 'NO';
                                   
                                 END IF;

                                IF (v_acuse_correo = 1) THEN
                                LET str_acuseCorreo = 'SI';
                                    ELSE 
                                        LET str_acuseCorreo = 'NO';
                                   
                                 END IF;

                            IF (v_procede = 1) THEN
                                LET str_procede = 'A Favor';
                                    ELSE IF (v_procede = 0) THEN 
                                        LET str_procede = 'En Contra';
                                      ELSE IF (v_procede IS NULL) THEN                                               
                                        LET str_procede = 'En Proceso';
                                      END IF;      
                                   END IF;
                                 END IF;
                       RETURN v_folio_csuac, 
                              v_numero_cliente, 
                              v_numero_cuenta, 
                              v_numero_tarjeta, 
                              v_nombre_cliente,
                              v_fecha_transaccion,
                              v_importe, 
                              v_numero_sucursal, 
                              v_nombre_promotor, 
                              v_fecha_alta, 
                              v_tipo_alta, 
                              str_acuseSMS,
                              str_acuseCorreo,
                              str_procede                              
                   WITH resume;
                END FOREACH;    
            END;
END PROCEDURE
;