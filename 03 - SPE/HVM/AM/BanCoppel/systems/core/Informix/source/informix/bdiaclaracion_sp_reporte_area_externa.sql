CREATE PROCEDURE "informix".sp_reporte_area_externa(fechaInicialReporte DATE, fechaFinalReporte DATE, intTipoReporteExterno  INTEGER)

	RETURNING  
    DATE as fecha_ingreso,
    DATE AS fecha_asignacion, 
    VARCHAR(11) AS usuario_asignado, 
    NVARCHAR(200) AS area_usuario,
    CHAR(20) AS f_area_externa, 
    LVARCHAR(2000) AS comentario,
    INTEGER as tiempo_atencion, 
    VARCHAR(20) AS cuenta,
    VARCHAR(20) AS num_cliente,
    MONEY AS importe,
    VARCHAR(10) AS folio_csuac,
    VARCHAR (13) AS tarjeta;
    
    /**
    Definición de variables locales
    **/

    DEFINE v_pky_temporal INTEGER;
    DEFINE v_fechacaptura DATE;
    DEFINE v_fecha_envio_area_externa DATE;
    DEFINE v_num_empleado VARCHAR(11);
    DEFINE v_nombre_area NVARCHAR(200);
    DEFINE v_fecha_respuesta_area_externa DATE;
    DEFINE v_comentario_respuesta_area_externa LVARCHAR(1000);
    DEFINE v_tiempo_atencion CHAR;
    DEFINE v_numero_cuenta VARCHAR(20);
    DEFINE v_num_cliente VARCHAR(20);
    DEFINE v_importereclamado MONEY;
    DEFINE v_folio_csuac VARCHAR(10);
    DEFINE v_tarjeta VARCHAR (13);
    DEFINE v_fky_aclaracion INTEGER;
    DEFINE v_fky_bitacora INTEGER;
    DEFINE v_fky_resolucion INTEGER;
    DEFINE v_registro_validado SMALLINT;


    /*Inicialización de variables */

    LET v_pky_temporal =0;
    LET v_fechacaptura = NULL;
    LET v_fecha_envio_area_externa = NULL;
    LET v_num_empleado ='0';
    LET v_nombre_area = NULL;
    LET v_fecha_respuesta_area_externa = NULL;
    LET v_comentario_respuesta_area_externa = NULL;
    LET v_tiempo_atencion = NULL;
    LET v_numero_cuenta = NULL ;
    LET v_num_cliente = NULL;
    LET v_importereclamado =0;
    LET v_folio_csuac =NULL;
    LET v_fky_aclaracion = 0;
    LET v_tarjeta = NULL;
    LET v_registro_validado = '0';


    BEGIN
         
        /**
            Ciclo que consulta todas las aclaraciones que contienen almenos una solicitud de envío a área externa
            Resolución en bitacora: 5
            Donde su bitacora indique fechas de solicitudes segun los parámetros de entrada del SP
        **/

        FOREACH 
            SELECT DISTINCT(ACL.folio_csuac),pky_aclaracion,fechacaptura
            INTO v_folio_csuac,v_fky_aclaracion,v_fechacaptura
            FROM ACL_aclaracion ACL
                LEFT JOIN acl_entrada_bitacora EB ON ACL.pky_aclaracion= EB.fky_aclaracion WHERE EB.fky_accion='5' AND (DATE(eb.fechahora) between fechaInicialReporte AND fechaFinalReporte)
            
            /**
                Ciclo utilizado para recorrer la bitacora de cada folio e identificar 
                registros con solicitud y respuesta de área externa.
                EJ: folio: 080817001 con bitacora {2,3,[5],4,2,[13],6,[5],3,2,[13]} Folio con dos envíos y dos respuestas 
            **/
                    FOREACH
                        SELECT DISTINCT(folio_csuac),pky_entrada_bitacora,fky_accion
                            INTO v_folio_csuac,v_fky_bitacora,v_fky_resolucion
                            FROM acl_entrada_bitacora EB2
                            WHERE EB2.fky_aclaracion= v_fky_aclaracion AND (EB2.fky_accion='5' OR  EB2.fky_accion='13') ORDER BY EB2.pky_entrada_bitacora ASC
                            
                            IF(intTipoReporteExterno = 1) THEN -- TIPO FILTRO - INGRESO
                            
                                IF (v_fky_resolucion == '13') THEN -- RESPUESTA A.E. -- AQUI LA VALIDACION CON RESPUESTA YA QUE EN CASO DE TENERLA  DIVIDE LA SOLICITUD POSTERIOR
                                
                                   /* CONSULTA LA INFORMACION REQUERIDA PARA REGISTROS CON RESPUESTAS A SOLICITUDES */
                                    SELECT EB4.fechahora,EB4.descripcion,TO_CHAR((DATE(EB4.fechahora )-(DATE(v_fecha_envio_area_externa))+1))
                                    INTO v_fecha_respuesta_area_externa,v_comentario_respuesta_area_externa,v_tiempo_atencion
                                    FROM acl_entrada_bitacora EB4
                                    WHERE EB4.pky_entrada_bitacora = v_fky_bitacora;
                                    

                                       IF (v_registro_validado = '1') THEN  -- RETORNO DE REGiSTROS VÁLIDOS SEGUN VALOR DE BANDERA
                                                    LET v_registro_validado = '0';
                                                    RETURN  v_fechacaptura,
                                                    v_fecha_envio_area_externa,
                                                    v_num_empleado ,
                                                    v_nombre_area,
                                                    v_fecha_respuesta_area_externa,
                                                    v_comentario_respuesta_area_externa,   
                                                    v_tiempo_atencion,
                                                    v_numero_cuenta,
                                                    v_num_cliente,
                                                    v_importereclamado,
                                                    v_folio_csuac,
                                                    v_tarjeta
                                            WITH resume;
                                            --LET v_registro_validado = '0';
                                            end if;
                                       

                                END IF;

                                IF (v_fky_resolucion == '5') THEN -- SOLICITUD A.E.

                                    /* CONSULTA LA INFORMACION REQUERIDA PARA REGISTROS CON SOLICITUDES */

                                    SELECT ACL2.fechacaptura,PROD.numero_cuenta,ACL2.num_cliente,ACL2.importereclamado,ACL2.folio_csuac,PROD.numero_tarjeta
                                    INTO v_fechacaptura,v_numero_cuenta,v_num_cliente,v_importereclamado,v_folio_csuac,v_tarjeta
                                    FROM acl_aclaracion ACL2 
                                    RIGHT JOIN acl_producto PROD ON PROD.pky_producto = ACL2.fky_producto
                                    WHERE ACL2.pky_aclaracion = v_fky_aclaracion;

                                    SELECT EB3.fechahora,US.usuario,A.nombre 
                                    INTO v_fecha_envio_area_externa,v_num_empleado,v_nombre_area
                                    FROM acl_entrada_bitacora EB3
                                    RIGHT JOIN acl_usuario US ON US.pky_usuario = EB3.fky_usuario
                                    RIGHT JOIN acl_area A ON A.pky_area=EB3.fky_area
                                    WHERE EB3.pky_entrada_bitacora = v_fky_bitacora;
                                    LET v_registro_validado = '1';
                                    LET v_fecha_respuesta_area_externa = NULL ;
                                    LET v_comentario_respuesta_area_externa =NULL;
                                    LET v_tiempo_atencion=0;
                                END IF;

                            END IF; -- Opcion 1



                            IF(intTipoReporteExterno = 2) THEN -- TIPO FILTRO - INGRESO
                            
                                IF (v_fky_resolucion == '13') THEN -- RESPUESTA A.E. -- AQUI LA VALIDACION CON RESPUESTA YA QUE EN CASO DE TENERLA  DIVIDE LA SOLICITUD POSTERIOR
                                
                                    LET v_registro_validado = '0';

                                END IF;

                                IF (v_fky_resolucion == '5') THEN -- SOLICITUD A.E.

                                    /* CONSULTA LA INFORMACION REQUERIDA PARA REGISTROS CON SOLICITUDES */

                                    SELECT ACL2.fechacaptura,PROD.numero_cuenta,ACL2.num_cliente,ACL2.importereclamado,ACL2.folio_csuac,PROD.numero_tarjeta
                                    INTO v_fechacaptura,v_numero_cuenta,v_num_cliente,v_importereclamado,v_folio_csuac,v_tarjeta
                                    FROM acl_aclaracion ACL2 
                                    RIGHT JOIN acl_producto PROD ON PROD.pky_producto = ACL2.fky_producto
                                    WHERE ACL2.pky_aclaracion = v_fky_aclaracion;

                                    SELECT EB3.fechahora,US.usuario,A.nombre 
                                    INTO v_fecha_envio_area_externa,v_num_empleado,v_nombre_area
                                    FROM acl_entrada_bitacora EB3
                                    RIGHT JOIN acl_usuario US ON US.pky_usuario = EB3.fky_usuario
                                    RIGHT JOIN acl_area A ON A.pky_area=EB3.fky_area
                                    WHERE EB3.pky_entrada_bitacora = v_fky_bitacora;
                                    LET v_registro_validado = '1';
                                    LET v_fecha_respuesta_area_externa = NULL ;
                                    LET v_comentario_respuesta_area_externa =NULL;
                                    LET v_tiempo_atencion=0;
                                END IF;
                            END IF; -- Opcion 2
                        

                            IF(intTipoReporteExterno = 3) THEN -- TIPO FILTRO - SOLICITUDES CON RESPUESTA
                            
                                IF (v_fky_resolucion == '13') THEN -- RESPUESTA A.E. -- AQUI LA VALIDACION CON RESPUESTA YA QUE EN CASO DE TENERLA  DIVIDE LA SOLICITUD POSTERIOR
                                
                                   /* CONSULTA LA INFORMACION REQUERIDA PARA REGISTROS CON RESPUESTAS A SOLICITUDES */
                                    SELECT EB4.fechahora,EB4.descripcion,TO_CHAR((DATE(EB4.fechahora )-(DATE(v_fecha_envio_area_externa))+1))
                                    INTO v_fecha_respuesta_area_externa,v_comentario_respuesta_area_externa,v_tiempo_atencion
                                    FROM acl_entrada_bitacora EB4
                                    WHERE EB4.pky_entrada_bitacora = v_fky_bitacora;
                                    LET v_registro_validado = '1';

                                       IF (v_registro_validado = '1') THEN  -- RETORNO DE REGiSTROS VÁLIDOS SEGUN VALOR DE BANDERA
                                                    LET v_registro_validado = '0';
                                                    RETURN  v_fechacaptura,
                                                    v_fecha_envio_area_externa,
                                                    v_num_empleado ,
                                                    v_nombre_area,
                                                    v_fecha_respuesta_area_externa,
                                                    v_comentario_respuesta_area_externa,   
                                                    v_tiempo_atencion,
                                                    v_numero_cuenta,
                                                    v_num_cliente,
                                                    v_importereclamado,
                                                    v_folio_csuac,
                                                    v_tarjeta
                                            WITH resume;
                                            --LET v_registro_validado = '0';
                                            end if;
                                       

                                END IF;

                                IF (v_fky_resolucion == '5') THEN -- SOLICITUD A.E.

                                    /* CONSULTA LA INFORMACION REQUERIDA PARA REGISTROS CON SOLICITUDES */

                                    SELECT ACL2.fechacaptura,PROD.numero_cuenta,ACL2.num_cliente,ACL2.importereclamado,ACL2.folio_csuac,PROD.numero_tarjeta
                                    INTO v_fechacaptura,v_numero_cuenta,v_num_cliente,v_importereclamado,v_folio_csuac,v_tarjeta
                                    FROM acl_aclaracion ACL2 
                                    RIGHT JOIN acl_producto PROD ON PROD.pky_producto = ACL2.fky_producto
                                    WHERE ACL2.pky_aclaracion = v_fky_aclaracion;

                                    SELECT EB3.fechahora,US.usuario,A.nombre 
                                    INTO v_fecha_envio_area_externa,v_num_empleado,v_nombre_area
                                    FROM acl_entrada_bitacora EB3
                                    RIGHT JOIN acl_usuario US ON US.pky_usuario = EB3.fky_usuario
                                    RIGHT JOIN acl_area A ON A.pky_area=EB3.fky_area
                                    WHERE EB3.pky_entrada_bitacora = v_fky_bitacora;
                                    LET v_registro_validado = '0';
                                    
                                END IF;

                            END IF; -- Opcion 3
                    
                        

                    END FOREACH ; -- END FOREACH PARA RECORRER REGOSTROS DE BITACORA A CORDE AL FOLIO PRESENTE

                    IF (v_registro_validado = '1') THEN  -- RETORNO DE REGOSTROS VÁLIDOS SEGUN VALOR DE BANDERA
                                LET v_registro_validado = '0';
                                RETURN  v_fechacaptura,
                                v_fecha_envio_area_externa,
                                v_num_empleado ,
                                v_nombre_area,
                                v_fecha_respuesta_area_externa,
                                v_comentario_respuesta_area_externa,   
                                v_tiempo_atencion,
                                v_numero_cuenta,
                                v_num_cliente,
                                v_importereclamado,
                                v_folio_csuac,
                                v_tarjeta
                        WITH resume;
                        end if;
                     LET v_pky_temporal = 0;
                    LET v_fechacaptura = NULL;
                    LET v_fecha_envio_area_externa = NULL;
                    LET v_num_empleado ='0';
                    LET v_nombre_area =NULL;
                    LET v_fecha_respuesta_area_externa = NULL;
                    LET v_comentario_respuesta_area_externa = NULL;
                    LET v_tiempo_atencion = NULL;
                    LET v_numero_cuenta = NULL ;
                    LET v_num_cliente = NULL;
                    LET v_importereclamado =0;
                    LET v_folio_csuac =NULL;
                    LET v_fky_aclaracion = 0;
                    LET v_tarjeta = '';
                    LET v_registro_validado = '0';  
        END FOREACH;

        
    END;
END PROCEDURE;