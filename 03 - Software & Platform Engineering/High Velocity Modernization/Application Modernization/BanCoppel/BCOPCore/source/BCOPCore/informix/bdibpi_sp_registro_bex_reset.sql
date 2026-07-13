CREATE PROCEDURE "informix".sp_registro_bex_reset ( p_numcte VARCHAR(9) )

    returning CHAR(5) AS Cod_ret;
--Definimos variables
    DEFINE l_id_usuario INT8;
    DEFINE l_num_cliente CHAR(20);
    DEFINE l_no_celular CHAR(10);
    DEFINE l_cuenta CHAR(20);
    DEFINE l_contrasenia LVARCHAR;
    DEFINE l_contrasenia1 LVARCHAR;
    DEFINE l_contrasenia2 LVARCHAR;
    DEFINE l_correo LVARCHAR;
    DEFINE l_imei VARCHAR(50);
    DEFINE l_udid VARCHAR(50);
    DEFINE l_useragent LVARCHAR;
    DEFINE l_ipusuario CHAR(20);
    DEFINE l_modelo LVARCHAR;
    DEFINE l_carrier INTEGER;
    DEFINE l_folio_activacion CHAR(12);
    DEFINE l_estatus_servicio CHAR(1);
    DEFINE l_fecha_ulti_acceso DATETIME YEAR to SECOND;
    DEFINE l_fecha_registro DATETIME YEAR to SECOND;
    DEFINE l_fecha_modificada DATETIME YEAR to SECOND;
    DEFINE l_servicio VARCHAR(25);
    DEFINE sql_err  		INTEGER;
    DEFINE vCod_ret 		CHAR(5);

--Inicializamos Variables
    LET l_id_usuario = '';
    LET l_num_cliente = '';
    LET l_no_celular = '';
    LET l_cuenta = '';
    LET l_contrasenia = '';
    LET l_contrasenia1 = '';
    LET l_contrasenia2 = '';
    LET l_correo = '';
    LET l_imei = '';
    LET l_udid = '';
    LET l_useragent = '';
    LET l_ipusuario = '';
    LET l_modelo = '';
    LET l_carrier = 0;
    LET l_folio_activacion = '';
    LET l_estatus_servicio = '';
    LET l_servicio = '';
    LET vCod_ret = '00000';

        -- INSERT INTO TABLE_LOG VALUES (CURRENT, p_numcte,1);
   
    BEGIN

        ON EXCEPTION SET sql_err
            IF sql_err <> 0 THEN
                    LET vCod_ret = sql_err;
					RETURN vCod_ret; 
            END IF;
         END EXCEPTION;

    SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
       
    FOREACH WITH HOLD
        
        SELECT  id_usuario, num_cliente, no_celular, cuenta, contrasenia, 
                contrasenia1, contrasenia2, correo, imei, udid, useragent, 
                ipusuario, modelo, carrier, folio_activacion, estatus_servicio,
                fecha_ulti_acceso, fecha_registro, fecha_modificada, servicio   
        INTO    l_id_usuario, l_num_cliente, l_no_celular, l_cuenta, l_contrasenia, 
                l_contrasenia1, l_contrasenia2, l_correo, l_imei, l_udid, l_useragent,
                l_ipusuario, l_modelo, l_carrier, l_folio_activacion, l_estatus_servicio,
                l_fecha_ulti_acceso, l_fecha_registro, l_fecha_modificada, l_servicio
        FROM    bpi_registro_bex
        WHERE   num_cliente = p_numcte
                     
        INSERT INTO "informix".bpi_registro_bex_reset(id_usuario, num_cliente, 
                no_celular, cuenta, contrasenia, contrasenia1, contrasenia2, 
                correo, imei, udid, useragent, ipusuario, modelo, carrier, 
                folio_activacion, estatus_servicio, fecha_ulti_acceso, 
                fecha_registro, fecha_modificada, servicio)
        VALUES  (l_id_usuario, l_num_cliente, l_no_celular, l_cuenta, l_contrasenia, 
                l_contrasenia1, l_contrasenia2,l_correo, l_imei, l_udid, l_useragent, 
                l_ipusuario, l_modelo, l_carrier, l_folio_activacion, l_estatus_servicio,
                l_fecha_ulti_acceso, l_fecha_registro, l_fecha_modificada, l_servicio);

      END FOREACH;
     
      DELETE FROM "informix".bpi_registro_bex WHERE num_cliente = p_numcte;
      
    RETURN vCod_ret;
 END
END PROCEDURE
;