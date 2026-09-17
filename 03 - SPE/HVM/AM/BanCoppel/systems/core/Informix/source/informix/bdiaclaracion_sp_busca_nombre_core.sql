CREATE PROCEDURE "informix".sp_busca_nombre_core(p_empleado CHAR(10))

RETURNING  CHAR(80) AS nombre_empleado;
 
DEFINE resultado_nombre_empleado  CHAR(120);

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
           
    SELECT nombre 
    INTO resultado_nombre_empleado
    FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = p_empleado;

    return resultado_nombre_empleado;
END

END PROCEDURE 
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_saldos_deb_cre_cliente(p_sNumeroCliente CHAR(9))

    RETURNING  CHAR(20) AS sumaSaldoCredito, CHAR(20) AS sumaSaldoDebito;

    --definicion de variables--     
    DEFINE saldoCredito MONEY(18,2);
    DEFINE saldoDebito  MONEY(18,2);
    DEFINE sumSaldoCredito MONEY(18,2);
    DEFINE sumSaldoDebito  MONEY(18,2);
    DEFINE sumSaldoCreditoChar CHAR(20);
    DEFINE sumSaldoDebitoChar  CHAR(20);

    --definicion de variables--     
    DEFINE resultado_numeroProducto CHAR(6);
    DEFINE resultado_nombreProducto     CHAR(60);
    DEFINE resultado_numeroCuenta           CHAR(30);
    DEFINE resultado_numeroTarjeta          CHAR(30);

    DEFINE iSqlErr      INTEGER;


    DEFINE resultado_codigo_retorno CHAR(10);
    DEFINE resultado_mensaje_retorno CHAR(10);
    DEFINE resultado_numero_credito CHAR(10);
    DEFINE resultado_codigo_tipcred CHAR(10);
    DEFINE resultado_fecha_origen CHAR(10);
    DEFINE resultado_fecha_prox_pago CHAR(10);
    DEFINE resultado_pago_minimo CHAR(10);
    DEFINE resultado_fecha_ult_pago CHAR(10);
    DEFINE resultado_plazo CHAR(10);
    DEFINE resultado_pagos_realizados CHAR(10);
    DEFINE resultado_linea_otorgada CHAR(10);
    DEFINE resultado_tasa_interes CHAR(10);
    DEFINE resultado_tasa_moratorios CHAR(10);
    DEFINE resultado_monto_sbc CHAR(10);
    DEFINE resultado_cap_vig CHAR(10);
    DEFINE resultado_cap_trans CHAR(10);
    DEFINE resultado_cap_vdo_exig CHAR(10);
    DEFINE resultado_cap_vdo_no_exig CHAR(10); 
    DEFINE resultado_sdo_act_total_cap MONEY;
    DEFINE resultado_int_vig CHAR(10);
    DEFINE resultado_int_vdo CHAR(10);
    DEFINE resultado_int_moratorios CHAR(10);
    DEFINE resultado_int_mes CHAR(10); 
    DEFINE resultado_sdo_act_total_int CHAR(10);
    DEFINE resultado_iva_int_vig CHAR(10);
    DEFINE resultado_iva_int_vdo CHAR(10);
    DEFINE resultado_iva_int_moratorios CHAR(10);
    DEFINE resultado_iva_int_mes CHAR(10);
    DEFINE resultado_sdo_act_total_iva CHAR(10);
    DEFINE resultado_com_pend CHAR(10);
    DEFINE resultado_iva_com CHAR(10);
    DEFINE resultado_sdo_retenido CHAR(10);
    DEFINE resultado_total_liquidacion CHAR(10);
    DEFINE resultado_int_devengado CHAR(10);
    DEFINE resultado_iva_int_devengado CHAR(10);
    DEFINE resultado_linea_disponible CHAR(10);
    DEFINE resultado_pagos_vdos CHAR(10);
    DEFINE resultado_desc_status_cred CHAR(10);
    DEFINE resultado_id_bloqueo_cred CHAR(10);
    DEFINE resultado_bloqueo_cta CHAR(10);
    DEFINE resultado_id_causa_bloqueo_cred CHAR(10);
    DEFINE resultado_causa_bloqueo_cta CHAR(10);
    DEFINE resultado_id_sit_esp_cte CHAR(10);
    DEFINE resultado_id_causa_esp_cte CHAR(10); 
    DEFINE resultado_sit_esp_cte CHAR(10);
    DEFINE resultado_id_sit_esp_cred CHAR(10);
    DEFINE resultado_id_causa_esp_cred CHAR(10);
    DEFINE resultado_sit_esp_cred CHAR(10);
    
     -- Inicializacion de las variables.
    LET saldoCredito = 0;
    LET saldoDebito  = 0;
    LET sumSaldoCredito = 0;
    LET sumSaldoDebito = 0;

    LET resultado_numeroProducto ='';
    LET resultado_nombreProducto = '';
    LET resultado_numeroCuenta = '';
    LET resultado_numeroTarjeta = '';

    --SET DEBUG FILE TO "/home/rtechno/logSPFallecidos/consultacatsaldos.out"; 
    --TRACE ON;
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	        
    BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET saldoCredito = 0;
                LET saldoDebito  = 0;
                LET sumSaldoCredito = 0;
                LET sumSaldoDebito = 0;
                RETURN sumSaldoCredito,sumSaldoDebito;
            END IF;
        END EXCEPTION;

        ---FOREACH PARA OBTENER SALDO DE CREDITOS
        
/**
            SELECT SUM(monto_calculado) 
            INTO resultado_sdo_act_total_cap
            FROM fal_control_tramite tra
            INNER JOIN fal_solicitud sol ON sol.pky_solicitud = tra.fky_solicitud
            WHERE num_cliente = p_sNumeroCliente
            AND fky_tipo_tramite = 2;
**/

            SELECT SUM(saldo) 
            INTO resultado_sdo_act_total_cap
            FROM fal_saldo_anterior 
            WHERE numero_cliente = p_sNumeroCliente
            AND tipo_movimiento_credito=1
            AND fky_tipo_tramite=2;


            IF resultado_sdo_act_total_cap IS NULL THEN
                FOREACH
                    SELECT numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto
                    INTO resultado_numeroProducto, resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta
                    FROM TABLE( FUNCTION sp_fal_busca_producto_cred_cliente(p_sNumeroCliente, 0) )
                    AS a(numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto)

                    SELECT codigo_retorno, mensaje_retorno, numero_credito, codigo_tipcred, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
                                                    tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, sdo_act_total_int, 
                                                    iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, iva_int_devengado, linea_disponible, 
                                                    pagos_vdos, desc_status_cred, id_bloqueo_cred, bloqueo_cta, id_causa_bloqueo_cred, causa_bloqueo_cta, id_sit_esp_cte, id_causa_esp_cte, sit_esp_cte, id_sit_esp_cred, 
                                                    id_causa_esp_cred, sit_esp_cred 
                    INTO resultado_codigo_retorno, resultado_mensaje_retorno, resultado_numero_credito, resultado_codigo_tipcred, resultado_fecha_origen, resultado_fecha_prox_pago, resultado_pago_minimo, resultado_fecha_ult_pago, resultado_plazo, resultado_pagos_realizados, resultado_linea_otorgada, 
                                                    resultado_tasa_interes, resultado_tasa_moratorios, resultado_monto_sbc, resultado_cap_vig, resultado_cap_trans, resultado_cap_vdo_exig, resultado_cap_vdo_no_exig, resultado_sdo_act_total_cap, resultado_int_vig, resultado_int_vdo, resultado_int_moratorios, resultado_int_mes, resultado_sdo_act_total_int, 
                                                    resultado_iva_int_vig, resultado_iva_int_vdo, resultado_iva_int_moratorios, resultado_iva_int_mes, resultado_sdo_act_total_iva, resultado_com_pend, resultado_iva_com, resultado_sdo_retenido, resultado_total_liquidacion, resultado_int_devengado, resultado_iva_int_devengado, resultado_linea_disponible, 
                                                    resultado_pagos_vdos, resultado_desc_status_cred, resultado_id_bloqueo_cred, resultado_bloqueo_cta, resultado_id_causa_bloqueo_cred, resultado_causa_bloqueo_cta, resultado_id_sit_esp_cte, resultado_id_causa_esp_cte, resultado_sit_esp_cte, resultado_id_sit_esp_cred, 
                                                    resultado_id_causa_esp_cred, resultado_sit_esp_cred 
                    FROM TABLE( FUNCTION  bdicred:sp_consulta_saldos_general('001',resultado_numeroCuenta) )
                                           AS a(codigo_retorno, mensaje_retorno, numero_credito, codigo_tipcred, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
                                                    tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, sdo_act_total_int, 
                                                    iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, iva_int_devengado, linea_disponible, 
                                                    pagos_vdos, desc_status_cred, id_bloqueo_cred, bloqueo_cta, id_causa_bloqueo_cred, causa_bloqueo_cta, id_sit_esp_cte, id_causa_esp_cte, sit_esp_cte, id_sit_esp_cred, 
                                                    id_causa_esp_cred, sit_esp_cred );
                 END FOREACH;
            END IF                      
            LET sumSaldoCredito = sumSaldoCredito + resultado_sdo_act_total_cap;

 
        


        --FOREACH PARA OBTENER SALDOS DE PAGARES Y DEBITO
         SELECT SUM(monto_calculado) 
         INTO saldoDebito
         FROM fal_control_tramite tra
         INNER JOIN fal_solicitud sol ON sol.pky_solicitud = tra.fky_solicitud
         WHERE num_cliente = p_sNumeroCliente
         AND fky_tipo_tramite IN(1,3, 4);


         IF saldoDebito IS NULL THEN
            FOREACH 
                SELECT sdo_actual
                INTO saldoDebito
                FROM bdicheq:"informix".sc_maechq qc 
                WHERE num_cte = p_sNumeroCliente
                LET sumSaldoDebito = sumSaldoDebito + saldoDebito;
            END FOREACH;

            FOREACH 
                SELECT FIRST 1 capital
                INTO saldoDebito
                FROM bdinvers:"informix".sv_maeinv 
                WHERE num_cte=p_sNumeroCliente
                AND status_cta = 1
                LET sumSaldoDebito = sumSaldoDebito + saldoDebito;
            END FOREACH;
         END IF

            LET sumSaldoCreditoChar = REPLACE(TO_CHAR(sumSaldoCredito), '$', '');
            LET sumSaldoDebitoChar = REPLACE(TO_CHAR(sumSaldoDebito), '$', '');
            RETURN 
                --NVL(sumSaldoCreditoChar, '0'), 
                case when sumSaldoCreditoChar is null then '0' else sumSaldoCreditoChar end,
                --NVL(sumSaldoDebitoChar, '0');
                case when sumSaldoDebitoChar is null then '0' else sumSaldoDebitoChar end;

    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_busca_creditos_cat (fechaInicial CHAR(10), fechaFinal CHAR(10), origenEvento INTEGER, tipoEvento INTEGER, folioCsuac CHAR(20),  usuarioAnalista INTEGER, numCliente CHAR(9), estatusCorporativo INTEGER)
    RETURNING           CHAR(12)    AS folioCSUAC,
                        CHAR(20)    AS saldoCaptacion,
                        CHAR(20)    AS saldoCredito,
                        CHAR(200)   AS asignado,
                        CHAR(200)   AS origen,
                        CHAR(200)   AS evento,
                        CHAR (9)    AS numeroCliente,
                        CHAR(100)   AS estatusGeneral,
                        CHAR (20)   AS pkySolicitud;
--CHAR (1150) AS cadena_query                        
   --RETURNING           CHAR(1150)    AS Cadena_query;

    DEFINE resultado_cadena_concatenada  CHAR(1150);
    DEFINE query char (850);
    DEFINE pky_solicitud                    CHAR (20);
    DEFINE iSqlErr                          INTEGER;
    DEFINE resultado_folioCSUAC             CHAR(12);
    DEFINE resultado_saldoCaptacion         CHAR(20);
    DEFINE resultado_saldoCredito           CHAR(20);
    DEFINE resultado_asignado               CHAR(200);
    DEFINE resultado_origen                 CHAR(200);
    DEFINE resultado_evento                 CHAR(200);
    DEFINE resultado_numeroCliente          CHAR(9);
    DEFINE resultado_estatusGeneral         CHAR(100);
    DEFINE resultado_fkySolicitud           CHAR(20);
    DEFINE resultado_cuenta_cliente_fallecido  CHAR(20);
    DEFINE resultado_numeroProducto         CHAR(6);
    DEFINE resultado_nombreProducto         CHAR(60);
    DEFINE resultado_numeroCuenta           CHAR(30);
    DEFINE resultado_numeroTarjeta          CHAR(30);
    

    

    LET resultado_folioCSUAC        = '';
    LET resultado_saldoCaptacion    = '0';
    LET resultado_saldoCredito      = '0';
    LET resultado_asignado          = '';
    LET resultado_origen            = '';
    LET resultado_evento            = '';
    LET resultado_numeroCliente     = '';
    LET resultado_estatusGeneral    = '';
    LET resultado_fkySolicitud      = '';
    LET resultado_cuenta_cliente_fallecido = '';
    LET resultado_numeroProducto = '';
    LET resultado_nombreProducto = '';
    LET resultado_numeroCuenta = '';
    LET resultado_numeroTarjeta = '';
    LET resultado_cadena_concatenada = '';
    LET query = 'SELECT pky_solicitud, TRIM(num_cliente), folio_csuac, (select nombre from fal_cat_evento where pky_evento = fky_evento) as evento,  (select nombre from fal_cat_origen_evento where pky_origen_evento = fky_origen_evento) as origen , (select nombre from fal_cat_estatus_general where pky_estatus_general = fky_estatus_general) as estatus_general, (select nombre from acl_usuario where pky_usuario=fky_usuario_analista) as analista  FROM fal_solicitud WHERE fky_estatus_general NOT IN(1)';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    BEGIN 
            ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_cadena_concatenada = '';
                    LET resultado_folioCSUAC        = '';
                    LET resultado_saldoCaptacion    = '';
                    LET resultado_saldoCredito      = '';
                    LET resultado_asignado          = '';
                    LET resultado_origen            = '';
                    LET resultado_evento            = '';
                    LET resultado_numeroCliente     = '';
                    LET resultado_estatusGeneral    = '';
                    LET resultado_fkySolicitud      = '';
                    RETURN resultado_folioCSUAC , resultado_saldoCaptacion , resultado_saldoCredito , resultado_asignado , resultado_origen, resultado_evento, resultado_numeroCliente, resultado_estatusGeneral, resultado_fkySolicitud;
                    --return resultado_cadena_concatenada;
                END IF;
            END EXCEPTION;
            
             LET fechaInicial        = CASE WHEN length(case when fechaInicial is null then '' else fechaInicial end)>0 THEN fechaInicial ELSE NULL END;
             --LET fechaInicial        = CASE WHEN length(NVL(fechaInicial,''))>0 THEN fechaInicial ELSE NULL END;
             LET fechaFinal          = CASE WHEN length(case when fechaFinal is null then '' else fechaFinal end)>0 THEN fechaFinal ELSE NULL END;
             --LET fechaFinal          = CASE WHEN length(NVL(fechaFinal,''))>0 THEN fechaFinal ELSE NULL END;
             LET origenEvento        = CASE WHEN (case when origenEvento is null then 0 else origenEvento end)>0 THEN origenEvento ELSE NULL END;
             --LET origenEvento        = CASE WHEN NVL(origenEvento, 0)>0 THEN origenEvento ELSE NULL END;
             LET tipoEvento          = CASE WHEN (case when tipoEvento is null then 0 else tipoEvento end)>0 THEN tipoEvento ELSE NULL END;
             --LET tipoEvento          = CASE WHEN NVL(tipoEvento, 0)>0 THEN tipoEvento ELSE NULL END;
             LET folioCsuac          = CASE WHEN length(case when folioCsuac is null then '' else folioCsuac end)>0 THEN folioCsuac ELSE NULL END;
             --LET folioCsuac          = CASE WHEN length(NVL(folioCsuac,''))>0 THEN folioCsuac ELSE NULL END;
             LET usuarioAnalista     = CASE WHEN (case when usuarioAnalista is null then 0 else usuarioAnalista end)>0 THEN usuarioAnalista ELSE NULL END;
             --LET usuarioAnalista     = CASE WHEN NVL(usuarioAnalista, 0)>0 THEN usuarioAnalista ELSE NULL END;
             LET numCliente          = CASE WHEN length(case when numCliente is null then '' else numCliente end)>0 THEN numCliente ELSE NULL END;
             --LET numCliente          = CASE WHEN length(NVL(numCliente, ''))>0 THEN numCliente ELSE NULL END;
             LET estatusCorporativo  = CASE WHEN (case when estatusCorporativo is null then 0 else estatusCorporativo end)>0 THEN estatusCorporativo ELSE NULL END;
             --LET estatusCorporativo  = CASE WHEN NVL(estatusCorporativo, 0)>0 THEN estatusCorporativo ELSE NULL END;

             
             
             IF fechaInicial IS NOT NULL AND fechaFinal IS NOT NULL THEN
                LET resultado_cadena_concatenada = "AND fecha_ingreso BETWEEN TO_DATE ('" || fechaInicial || "' ,'%d/%m/%Y') AND TO_DATE('" ||  fechaFinal || "','%d/%m/%Y') " ||resultado_cadena_concatenada;
             END IF;

             IF origenEvento IS NOT NULL THEN
                LET resultado_cadena_concatenada = ' AND fky_origen_evento = ' || origenEvento || ' ' ||resultado_cadena_concatenada;
             END IF;             

             IF tipoEvento IS NOT NULL THEN
                LET resultado_cadena_concatenada = ' AND fky_evento = ' || tipoEvento || ' ' ||resultado_cadena_concatenada;
             END IF;

             IF folioCsuac IS NOT NULL THEN
                LET resultado_cadena_concatenada = ' AND folio_csuac = "' || TRIM (folioCsuac) || '" ' ||resultado_cadena_concatenada;
             END IF;

             IF usuarioAnalista IS NOT NULL THEN
                LET resultado_cadena_concatenada = ' AND fky_usuario_analista = ' || usuarioAnalista || ' ' ||resultado_cadena_concatenada;
             END IF;
             
             --IF estatusCorporativo IS NOT NULL THEN
                --LET resultado_cadena_concatenada = ' AND fky_estatus_corporativo = ' || estatusCorporativo || ' ' ||resultado_cadena_concatenada;
             --END IF;
             
             IF numCliente IS NOT NULL THEN
                LET resultado_cadena_concatenada = ' AND num_cliente = "' || TRIM(numCliente) || '" ' ||resultado_cadena_concatenada;
             END IF;
            
             LET resultado_cadena_concatenada = TRIM (query) || ' '|| TRIM (resultado_cadena_concatenada);
             
             PREPARE stmt_id FROM resultado_cadena_concatenada;
             DECLARE cust_cur cursor FOR stmt_id;

             OPEN cust_cur;
               
                WHILE (1 = 1)
                    FETCH cust_cur INTO resultado_fkySolicitud, resultado_numeroCliente, resultado_folioCSUAC, resultado_evento, resultado_origen, resultado_estatusGeneral, resultado_asignado;
                    IF (SQLCODE != 100) THEN
                               IF estatusCorporativo > 1 THEN
                                   SELECT cuenta_cliente_fallecido 
                                   INTO resultado_cuenta_cliente_fallecido
                                   FROM fal_control_tramite 
                                   WHERE fky_estatus_corporativo = estatusCorporativo
                                   AND fky_solicitud = resultado_fkySolicitud
                                   AND fky_tipo_tramite = 2;
                                   IF resultado_cuenta_cliente_fallecido IS NOT NULL THEN
                                        CALL sp_fal_saldos_deb_cre_cliente(resultado_numeroCliente)
                                        returning resultado_saldoCaptacion, resultado_saldoCredito;
                                        RETURN resultado_folioCSUAC , resultado_saldoCaptacion , resultado_saldoCredito , resultado_asignado , resultado_origen, resultado_evento, resultado_numeroCliente, resultado_estatusGeneral, resultado_fkySolicitud WITH RESUME;
                                   END IF
                            --ESTATUS DE NOTIFICACIÓN
                            ELIF estatusCorporativo = 1 THEN
                                SELECT cuenta_cliente_fallecido 
                                INTO resultado_cuenta_cliente_fallecido
                                FROM fal_control_tramite 
                                WHERE fky_solicitud = resultado_fkySolicitud
                                AND fky_tipo_tramite = 2;
                                IF resultado_cuenta_cliente_fallecido IS NULL THEN
                                    SELECT numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto
                                    INTO resultado_numeroProducto, resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta
                                    FROM TABLE( FUNCTION sp_fal_busca_producto_cred_cliente(resultado_numeroCliente, 0) )
                                    AS a(numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto);
                                    IF (resultado_numeroproducto IS NOT NULL AND resultado_numeroproducto <> '' ) THEN
                                         CALL sp_fal_saldos_deb_cre_cliente(resultado_numeroCliente)
                                             returning resultado_saldoCaptacion, resultado_saldoCredito;
                                         RETURN resultado_folioCSUAC , resultado_saldoCaptacion , resultado_saldoCredito , resultado_asignado , resultado_origen, resultado_evento, resultado_numeroCliente, resultado_estatusGeneral, resultado_fkySolicitud WITH RESUME;
                                    END IF
                            END IF
                            ELSE
                               SELECT cuenta_cliente_fallecido 
                               INTO resultado_cuenta_cliente_fallecido
                               FROM fal_control_tramite 
                               WHERE fky_solicitud = resultado_fkySolicitud
                               AND fky_tipo_tramite = 2;
                               IF resultado_cuenta_cliente_fallecido IS NOT NULL THEN
                                    CALL sp_fal_saldos_deb_cre_cliente(resultado_numeroCliente)
                                    returning resultado_saldoCaptacion, resultado_saldoCredito;
                                    RETURN resultado_folioCSUAC , resultado_saldoCaptacion , resultado_saldoCredito , resultado_asignado , resultado_origen, resultado_evento, resultado_numeroCliente, resultado_estatusGeneral, resultado_fkySolicitud WITH RESUME;
                               ELSE
                                    SELECT numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto
                                    INTO resultado_numeroProducto, resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta
                                    FROM TABLE( FUNCTION sp_fal_busca_producto_cred_cliente(resultado_numeroCliente, 0) )
                                    AS a(numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto);
                                    IF (resultado_numeroproducto IS NOT NULL AND resultado_numeroproducto <> '' ) THEN
                                         CALL sp_fal_saldos_deb_cre_cliente(resultado_numeroCliente)
                                         returning resultado_saldoCaptacion, resultado_saldoCredito;
                                         RETURN resultado_folioCSUAC , resultado_saldoCaptacion , resultado_saldoCredito , resultado_asignado , resultado_origen, resultado_evento, resultado_numeroCliente, resultado_estatusGeneral, resultado_fkySolicitud WITH RESUME;
                                    END IF
                               END IF
                            END IF
                     ELSE
                            EXIT;
                     END IF
                END WHILE
             CLOSE cust_cur;
             FREE cust_cur;
             FREE stmt_id ;
 --      RETURN resultado_folioCSUAC , resultado_saldoCaptacion , resultado_saldoCredito , resultado_asignado , resultado_origen, resultado_evento, resultado_numeroCliente, resultado_estatusGeneral, resultado_fkySolicitud WITH RESUME;
      --return resultado_cadena_concatenada;
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_cancelacion_cuentas_manual(

pSucursal CHAR(4),
pCuenta CHAR(20),
pPromotor CHAR(8),
pSupervisor CHAR(8),
pky_resolucion INTEGER,
p_idSolicitud INTEGER,
pEmpresa CHAR(3),
pMotivo CHAR(2),
pTipoCuenta INTEGER)

  RETURNING CHAR(6) as codigoRetorno, CHAR(250) as mensajeRetorno;


DEFINE codigoRetorno        CHAR(6);
DEFINE mensajeRetorno       CHAR(250);
DEFINE tipoCuentaCredito    INTEGER;
DEFINE cancelacionManual    INTEGER;
DEFINE resultado_pky_usuario INTEGER;
DEFINE resultado_foliocsuac CHAR (11);

DEFINE iSqlErr              INTEGER;

--Variables de retorno Credito

DEFINE codigoRetornoCrd CHAR(6);
DEFINE mensajeRetornoCrd CHAR(250);
DEFINE numeroCredito CHAR(20);
DEFINE numeroTarjeta CHAR(16);

DEFINE codigoRetornoDeb CHAR(6);
DEFINE mensajeRetornoDeb CHAR(250);


--Obteniendo pky de cuenta de crédito
LET tipoCuentaCredito = (SELECT pky_tipo_tramite from fal_cat_tipo_tramite where nombre ='Crédito');
LET resultado_pky_usuario = (SELECT pky_usuario FROM acl_usuario where usuario= pPromotor);
LET cancelacionManual ='1';
LET resultado_foliocsuac = (select folio_csuac from fal_solicitud WHERE pky_solicitud = p_idSolicitud);

--SET DEBUG FILE TO "/home/rtechno/logSPFallecidos/sp_fal_cancelacion_cuentas_manual"||p_idSolicitud||".out"; 
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
	
BEGIN

 ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                
                RETURN  iSqlErr,'Error SQL'; --RETURNING
            END IF;
 END EXCEPTION;

    -- VALIDACIÓN DE CANCELACIÓN PARA CREDITO

    IF (pTipoCuenta = tipoCuentaCredito) THEN 
        
            CALL sp_fal_cancelacion_cuenta_credito(p_idSolicitud,pCuenta,pPromotor,pSupervisor,pSucursal,pky_resolucion,'1')
            RETURNING codigoRetornoCrd,mensajeRetornoCrd,numeroCredito,numeroTarjeta;

            IF(codigoRetornoCrd = '000000') THEN 
                
                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación manual: La cuenta '||pCuenta||' se ha cancelado exitosamente.',today,resultado_foliocsuac,'CANCELACION MANUAL CREDITO EXITOSA',resultado_pky_usuario,pPromotor);
                
                UPDATE fal_control_tramite SET fecha_cancelacion = CURRENT WHERE cuenta_cliente_fallecido = pCuenta;

                LET codigoRetorno = '000000';
                LET mensajeRetorno = 'Se ha cancelado exitosamente la cuenta.';
                
                ELSE IF (codigoRetornoCrd <> '000000') THEN 

                    INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                    VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación manual: La cuenta '||pCuenta||' no se ha cancelado.',today,resultado_foliocsuac,'CANCELACION MANUAL CREDITO NO EXITOSA',resultado_pky_usuario,pPromotor);
                    
                LET codigoRetorno = '000001';
                LET mensajeRetorno = 'No se cancelo exitosamente la cuenta.';    
                END IF;

                RETURN codigoRetorno,mensajeRetorno;
            END IF;

        ELSE IF (pTipoCuenta <> tipoCuentaCredito) THEN
      
                CALL "informix".sp_fal_cancelacion_cuenta_debito( pEmpresa,pCuenta, pMotivo,pPromotor,pSucursal)
                RETURNING codigoRetornoDeb,mensajeRetornoDeb;

                    IF(codigoRetornoDeb = '069') THEN
                
                            INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                            VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación manual: La cuenta '||pCuenta||' se ha cancelado exitosamente.',today,resultado_foliocsuac,'CANCELACION MANUAL EXITOSA',resultado_pky_usuario,pPromotor);

                            UPDATE fal_control_tramite SET fecha_cancelacion = CURRENT WHERE cuenta_cliente_fallecido = pCuenta;

                            LET codigoRetorno = '000000';
                            LET mensajeRetorno = 'Se ha cancelado exitosamente la cuenta.';
                
                
                     ELSE IF (codigoRetornoDeb <> '069') THEN 

                        INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                        VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación manual: La cuenta '||pCuenta||' no se ha cancelado.',today,resultado_foliocsuac,'CANCELACION MANUAL NO EXITOSA',resultado_pky_usuario,pPromotor);
                        
                        LET codigoRetorno = '000001';
                        LET mensajeRetorno = 'No se cancelo exitosamente la cuenta.';

                      END IF;                  END IF; -- Cancelacion correcta de debito.
            RETURN codigoRetorno,mensajeRetorno;        END IF;    END IF;END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_buscarclientespornumero (p_sNumeroCliente CHAR(30))

     RETURNING	CHAR(20) AS noCliente, CHAR(30) AS primerApellido, CHAR(30) AS segundoApellido, CHAR(30) AS primerNombre, CHAR(30) AS segundoNombre;

	--definicion de variables--
	DEFINE resultado_numeroCliente 		CHAR(20);
	DEFINE resultado_primerApellido		CHAR(30);
	DEFINE resultado_segundoApellido	CHAR(30);
    DEFINE resultado_primerNombre		CHAR(30);
    DEFINE resultado_segundoNombre		CHAR(30);
    DEFINE resultado_numerotransfer     CHAR(30);

    DEFINE iSqlErr                      INTEGER;

     	-- Inicializacion de las variables.
	LET resultado_numeroCliente = '';
	LET resultado_primerApellido = '';
	LET resultado_segundoApellido = '';
	LET resultado_primerNombre = '';
	LET resultado_segundoNombre = '';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_numeroCliente = '';
                    LET resultado_primerApellido = '';
                    LET resultado_segundoApellido = '';
                    LET resultado_primerNombre = '';
                    LET resultado_segundoNombre = '';

                    RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;
                END IF;
        END EXCEPTION;

	SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno
		INTO resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido
		FROM bdinteg:si_cliente
		WHERE p_sNumeroCliente = numcte and tipo_cliente=1;


   IF ( resultado_primerNombre IS NULL) THEN

      SELECT bditransfer:tf_maecte.numcte
      INTO resultado_numerotransfer
         FROM bditransfer:tf_maecte
        WHERE bditransfer:tf_maecte.numcte_tf = p_sNumeroCliente;

     SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno
		INTO resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido
		FROM bdinteg:si_cliente
		WHERE resultado_numerotransfer = numcte and tipo_cliente=1;


    END IF;



   RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;



	END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_buscarclientesportelefonotransfer (p_sNumeroTelefonoTransfer CHAR(30))

     RETURNING	CHAR(20) AS noCliente, CHAR(30) AS primerApellido, CHAR(30) AS segundoApellido, CHAR(30) AS primerNombre, CHAR(30) AS segundoNombre;

	--definicion de variables--
	DEFINE resultado_numeroCliente 		CHAR(20);
	DEFINE resultado_primerApellido		CHAR(30);
	DEFINE resultado_segundoApellido	CHAR(30);
	DEFINE resultado_primerNombre		CHAR(30);
	DEFINE resultado_segundoNombre		CHAR(30);
	DEFINE telefono_Transfer		CHAR(30);
	DEFINE iSqlErr                     	INTEGER;

    -- Inicialización de las variables.
	LET resultado_numeroCliente = '';
	LET resultado_primerApellido = '';
	LET resultado_segundoApellido = '';
	LET resultado_primerNombre = '';
	LET resultado_segundoNombre = '';
	LET telefono_Transfer = '';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_numeroCliente = '';
                    LET resultado_primerApellido = '';
                    LET resultado_segundoApellido = '';
                    LET resultado_primerNombre = '';
                    LET resultado_segundoNombre = '';
                    RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;
                END IF;
        END EXCEPTION;

            SELECT numcte
            INTO resultado_numeroCliente
            FROM bditransfer:tf_maecte
            WHERE empresa = '001'
              AND telefono = p_sNumeroTelefonoTransfer;



		IF ( resultado_numeroCliente IS NULL ) THEN
           let resultado_numeroCliente = '';
        ELSE
            SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno
              INTO resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido
              FROM bdinteg:si_cliente
             WHERE numcte = resultado_numeroCliente
             AND tipo_cliente=1;
{
            IF ( resultado_numeroCliente IS NULL ) THEN

				LET resultado_numeroCliente = '';
				LET resultado_primerApellido = '';
				LET resultado_segundoApellido = '';
				LET resultado_primerNombre = '';
				LET resultado_segundoNombre = '';

            END IF;
}
        END IF;

        RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;

	END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_busca_productos_deb_cte_fallecido(p_sNumeroCliente CHAR(20))

     RETURNING  
                        CHAR(6) AS numeroProducto,
                        CHAR(60) AS nombreProducto, 
                        CHAR(30) AS numeroCuenta, 
                        CHAR(30) AS estatus , 
                        CHAR(100) AS motivo,
                        MONEY(16)   AS montoActual,
                        CHAR(30) AS numeroCuentaDeposito,
                        CHAR(30) AS fechaVenc;

    --definicion de variables--     
    DEFINE resultado_numeroProducto CHAR(6);
    DEFINE resultado_nombreProducto     CHAR(60);
    DEFINE resultado_numeroCuenta       CHAR(30);
    DEFINE resultado_estatus                CHAR(30);
    DEFINE resultado_motivo                 CHAR(100);
    DEFINE resultado_montoActual           MONEY(16);
    DEFINE resultado_cuentaDeposito          CHAR(30);
    DEFINE resultado_fechaVenc               CHAR(30);
    DEFINE iSqlErr                                INTEGER;
    
     -- Inicializacion de las variables.
    LET resultado_numeroProducto ='';
    LET resultado_nombreProducto = '';
    LET resultado_numeroCuenta = '';
    LET resultado_estatus = '';
    LET resultado_motivo = '';
    LET resultado_montoActual = 0;
    LET resultado_cuentaDeposito = '';
    LET resultado_fechaVenc = '';
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	        
    BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto = '';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_estatus = '';
                LET resultado_motivo = '';
                LET resultado_montoActual = 0;
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_estatus,resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc;
            END IF;
        END EXCEPTION;

        FOREACH
   
            SELECT DISTINCT qc.producto as numeroProducto, 
                        pr.nombre AS nombreProducto,
                        qc. cuenta AS cuentaProducto,
                        --qc.status_cta as estatus,
                        stc.descripcion as estatus,
                        bl.descripcion as motivo,
                        qc.sdo_actual,
                        mae.cuentadep as cuentaDeposito ,
                        vin.fecha_vencimiento as fechaDepostio
                        INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_estatus,resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc
                        FROM bdicheq:sc_maechq qc
                        LEFT JOIN bdicheq:"informix".sc_bloqueo bl ON (qc.motivo = bl.codigo)
                        LEFT JOIN bdicheq:"informix".sc_producto pr ON (qc.producto = pr.producto ) 
                        LEFT JOIN fal_cat_estatus_cuenta stc ON (qc.status_cta = stc.pky_estatus_cuenta )
                        LEFT JOIN bdicheq:"informix".sc_maeinstrucc mae ON (qc.cuenta = mae.cuenta )  
                        LEFT JOIN bdicheq:"informix".sc_vencinvpag vin ON (vin.numcta = mae.cuenta )                
                        WHERE qc.num_cte = p_sNumeroCliente
                        AND qc.status_cta not in (2)
/*
                    SELECT monto_original
                    INTO v_monto_original
                    FROM fal_control_tramite fct
                    WHERE fct.cuenta_cliente_fallecido = qc. cuenta
                    AND tramite = 1;

                    IF v_monto_original <> NULL THEN
                        LET 
                    ELSE
                        RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta ,resultado_estatus, resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc WITH RESUME;
                    END IF*/
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta ,resultado_estatus, resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc WITH RESUME;
        
        END FOREACH;
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_busca_productos_deb_cte_fallecido_1(p_sNumeroCliente CHAR(20))

     RETURNING  
                        CHAR(6) AS numeroProducto,
                        CHAR(60) AS nombreProducto, 
                        CHAR(30) AS numeroCuenta, 
                        CHAR(30) AS estatus , 
                        CHAR(100) AS motivo,
                        MONEY(16)   AS montoActual,
                        CHAR(30) AS numeroCuentaDeposito,
                        CHAR(30) AS fechaVenc;

    --definicion de variables--     
    DEFINE resultado_numeroProducto CHAR(6);
    DEFINE resultado_nombreProducto     CHAR(60);
    DEFINE resultado_numeroCuenta       CHAR(30);
    DEFINE resultado_estatus                CHAR(30);
    DEFINE resultado_motivo                 CHAR(100);
    DEFINE resultado_montoActual           MONEY(16);
    DEFINE resultado_cuentaDeposito          CHAR(30);
    DEFINE resultado_fechaVenc               CHAR(30);
    DEFINE iSqlErr                                INTEGER;
    
     -- Inicializacion de las variables.
    LET resultado_numeroProducto ='';
    LET resultado_nombreProducto = '';
    LET resultado_numeroCuenta = '';
    LET resultado_estatus = '';
    LET resultado_motivo = '';
    LET resultado_montoActual = 0;
    LET resultado_cuentaDeposito = '';
    LET resultado_fechaVenc = '';
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	        
    BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto = '';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_estatus = '';
                LET resultado_motivo = '';
                LET resultado_montoActual = 0;
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_estatus,resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc;
            END IF;
        END EXCEPTION;

        FOREACH

                SELECT DISTINCT qc.producto as numeroProducto, 
                pr.nombre AS nombreProducto,
                        qc. cuenta AS cuentaProducto,
                        --qc.status_cta as estatus,
                        stc.descripcion as estatus,
                        bl.descripcion as motivo,
                        qc.sdo_actual,
                        mae.cuentadep as cuentaDeposito ,
                        vin.fecha_vencimiento as fechaDepostio
                        INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_estatus,resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc
                        FROM bdicheq:sc_maechq qc
                        LEFT JOIN bdicheq:"informix".sc_bloqueo bl ON (qc.motivo = bl.codigo)
                        LEFT JOIN bdicheq:"informix".sc_producto pr ON (qc.producto = pr.producto ) 
                        LEFT JOIN fal_cat_estatus_cuenta stc ON (qc.status_cta = stc.pky_estatus_cuenta )
                        LEFT JOIN bdicheq:"informix".sc_maeinstrucc mae ON (qc.cuenta = mae.cuenta )  
                        LEFT JOIN bdicheq:"informix".sc_vencinvpag vin ON (vin.numcta = mae.cuenta )
                        INNER JOIN bdicheq:"informix".sc_maechq cd ON cd.cuenta = mae.cuentadep
                        INNER JOIN fal_control_tramite con ON con.cuenta_cliente_fallecido = qc.cuenta
                        WHERE qc.num_cte = p_sNumeroCliente 
                        AND cd.status_cta not in( 2)
                        AND qc.status_cta = 2
                        AND pr.producto = '1100'


                        RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta ,resultado_estatus, resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc WITH RESUME;

        END FOREACH;
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_mueve_aclaraciones_historico_pendiente()

RETURNING CHAR(5);

-- *********************************************************************
-- *                        DEFINICION DE VARIABLES                    *
-- *********************************************************************
DEFINE scod_ret         CHAR(5);
DEFINE vsqlerr          INTEGER;
DEFINE v_pky_aclaracion CHAR(20);
DEFINE icontador        INTEGER;
DEFINE v_folio_csuac    VARCHAR(11);
DEFINE v_sol_eglobal    INTEGER;
DEFINE v_res_eglobal    INTEGER;
DEFINE v_fecha_limit    DATE;
DEFINE vsql	        	char(3000);
Define cCadena 			CHAR(1000);
DEFINE respuesta_repetida_e_global	INTEGER;
DEFINE solicitud_faltante_e_global	INTEGER;
DEFINE cRuta CHAR(100);
DEFINE horaActual     datetime year to fraction;
DEFINE horafinal     datetime year to fraction;
DEFINE v_pky_movimiento CHAR(20);
DEFINE v_pky_movimiento2 CHAR(20);
DEFINE v_pky_bitacora CHAR(20);
DEFINE v_resul_mov INTEGER;

LET v_resul_mov = NULL;
LET scod_ret  = "00000";
LET vsqlerr = 0;
LET icontador=1;
		--SET DEBUG FILE TO "/ifxsif01/reydavid/mover.out";
		--TRACE ON;
		
		IF EXISTS( SELECT * FROM systables WHERE tabname ='temp_mov_2') THEN
			DROP TABLE "informix".temp_mov_2;
		END IF;
--Verificar tabla fisica
		IF EXISTS( SELECT * FROM systables WHERE tabname ='temp_bitacora') THEN
			DROP TABLE "informix".temp_bitacora;
		END IF;
		IF EXISTS( SELECT * FROM systables WHERE tabname ='temp_mov') THEN
			DROP TABLE "informix".temp_mov;
		END IF;
--Verificar tabla fisica
		IF EXISTS( SELECT * FROM systables WHERE tabname ='temp_mov_3') THEN
			DROP TABLE "informix".temp_mov_3;
		END IF;

	CREATE /*TEMP*/ table temp_mov(
		pky_movimiento    integer,
		fky_padre integer);
---	CREATE /*TEMP*/ table temp_mov_2(
--		pky_movimiento    integer);
--	CREATE /*TEMP*/ table temp_mov_3(
--		pky_movimiento   integer,
--		fky_padre integer);
	CREATE /*TEMP*/ table temp_bitacora(
		pky_bitacora   integer);

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
	   LET scod_ret=vsqlerr;
	   ROLLBACK WORK;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;


			INSERT INTO temp_bitacora		
			select pky_bitacora from "informix".acl_sistema_bitacora_his;
----------------
			INSERT INTO temp_mov
			SELECT pky_movimiento, fky_padre
			FROM "informix".acl_movimiento_his where (fky_aclaracion in(select pky_aclaracion from temp_aclara) or folio_csuac in(select folio_csuac from temp_aclara where folio_csuac is not null)) and fky_padre is not null order by fky_padre asc; 
			--fky_padre is not null;
			INSERT INTO temp_mov
			SELECT pky_movimiento,fky_padre
			FROM "informix".acl_movimiento_his where (fky_aclaracion in(select pky_aclaracion from temp_aclara) or folio_csuac in(select folio_csuac from temp_aclara where folio_csuac is not null)) and fky_padre is null order by pky_movimiento asc;
			--fky_padre is null;
			
			INSERT INTO temp_mov
			SELECT pky_movimiento, fky_padre
			FROM "informix".acl_movimiento_his where fky_aclaracion is null and folio_csuac is null and fechahora <= (select last_day(add_months(((today) - 1 units year),-(month(today)))) from bdinteg:"informix".si_fechas where empresa=001)  order by pky_movimiento asc;
		
FOREACH WITH HOLD
			
			select pky_aclaracion, folio_csuac
			into v_pky_aclaracion,v_folio_csuac
			from temp_aclara 
		BEGIN WORK;	
			INSERT INTO "informix".acl_documento_his 
			select * from "informix".acl_documento WHERE fky_aclaracion =v_pky_aclaracion and folio_csuac = v_folio_csuac;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_aclaracion, folio_csuac
			into v_pky_aclaracion,v_folio_csuac
			from temp_aclara
		BEGIN WORK;	
        		 --********************Eliminacion de historico en entrada bitacora
			delete from "informix".acl_entrada_bitacora WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico en documentos
			delete from "informix".acl_documento WHERE  fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico en documentos
			delete from "informix".acl_recuperacion_saldos WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico de solicitud E-GALOBAL
			--********************Eliminacion de historico de control de aclaraciones via telefonica
			delete from "informix".acl_control_aclaracion_tel WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico de regulatorio 27
			delete from "informix".acl_regulatorio27 WHERE folio_csuac = v_folio_csuac;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_movimiento
			into v_pky_movimiento
			from temp_mov where fky_padre is not null --order by pky_movimiento desc
		BEGIN WORK;	
			LET v_resul_mov = v_pky_movimiento;
			--********************Eliminacion de historico en movimiento
			UPDATE "informix".acl_movimiento SET fky_padre = NULL WHERE pky_movimiento = v_pky_movimiento;
			LET v_resul_mov = NULL;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_movimiento
			into v_pky_movimiento
			from temp_mov order by fky_padre desc
		BEGIN WORK;	
			LET v_resul_mov = v_pky_movimiento;
			--********************Eliminacion de historico en movimiento
			delete from "informix".acl_movimiento WHERE pky_movimiento = v_pky_movimiento;
			LET v_resul_mov = NULL;
		COMMIT WORK;
END FOREACH;


FOREACH WITH HOLD		
			select pky_solicitud_e_global
			into v_sol_eglobal
			from temp_solic
		BEGIN WORK;	
			--********************Eliminacion de historico de Solicitud E-GALOBAL
			delete from "informix".acl_solicitud_e_global WHERE pky_solicitud_e_global = v_sol_eglobal;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD		
			select pky_respuesta_e_global
			into v_res_eglobal
			from temp_respues
		BEGIN WORK;	
    	--********************Eliminacion de historico de respuesta E-GALOBAL
			delete from "informix".acl_respuesta_e_global WHERE pky_respuesta_e_global = v_res_eglobal;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_aclaracion
			into v_pky_aclaracion
			from temp_aclara
		BEGIN WORK;	
		---********* Se elimina la informacion principal de aclaraciones********
			delete from "informix".acl_aclaracion WHERE  pky_aclaracion = v_pky_aclaracion;
		COMMIT WORK;
END FOREACH;
			
FOREACH WITH HOLD
			select pky_bitacora
			into v_pky_bitacora
			from temp_bitacora
		BEGIN WORK;		
			--------------------Elimina historico del bitacora del sistema----------------------
			delete from "informix".acl_sistema_bitacora WHERE pky_bitacora = v_pky_bitacora;
		COMMIT WORK;
END FOREACH;

RETURN scod_ret;
END
END PROCEDURE;