CREATE PROCEDURE "informix".sp_envio_sms_inc_tc(
    p_empresa CHAR(3) 
)
RETURNING
    CHAR(5) AS cCodRet,
    INTEGER as i_mensajes_exitosos,
    INTEGER as i_mensajes_pendientes;



DEFINE cCodRet                      CHAR(5);
DEFINE cCodRetSms                   CHAR(5);
DEFINE iSqlErr                      INTEGER;
DEFINE d_fecha_hoy                  DATE;
DEFINE cNumCte                      CHAR(20);
DEFINE cNumCredito                  CHAR(20);
DEFINE cTelefono                    CHAR(20);
DEFINE cErrorInfo                   CHAR(80);
DEFINE iSamErr                      INTEGER;
DEFINE cMensajeRet                  CHAR(125);
DEFINE d_linea_oferta               DECIMAL(18,2);        
DEFINE d_fin_vigencia               DATE;
DEFINE d_inicio_vigencia            DATE;
DEFINE i_intento_notificacion       INTEGER;
DEFINE cIncrementoActivo            CHAR(1);
DEFINE cCodRetCon                   CHAR(6);
DEFINE cLinea_credito               DECIMAL(18,2);  
DEFINE c_term_tarjeta               CHAR(20);
DEFINE cCodretConBue                CHAR(5);
DEFINE cMensaje                     CHAR(80);
DEFINE cIsCtePros                   CHAR(1);
DEFINE c_num_cte                    CHAR(20);
DEFINE cNombre                      CHAR(120);
DEFINE cRFC                         CHAR(13);
DEFINE dtFechaSol                   DATE;
DEFINE dtFechaAut                   DATE;
DEFINE dLinCredAct                  DECIMAL(18,2);
DEFINE dLinCredCal                  DECIMAL (18,2);
DEFINE cOrigen                      CHAR(1);
DEFINE cStatus                      CHAR(2);
DEFINE cDescStatus                  CHAR(40);
DEFINE cComentario                  CHAR(80);
DEFINE cNumSol                      CHAR(20);
DEFINE c_nombre_cliente             CHAR(50);
DEFINE c_num_tarjeta                CHAR(20);
DEFINE c_email_cliente              CHAR(50);
DEFINE c_num_producto               CHAR(20);
DEFINE d_linea_actual               DECIMAL(18,2);
DEFINE c_nombre_prod                CHAR(50);
DEFINE i_diferencia_dias            INTEGER;
DEFINE d_fecha_notificacion_cliente DATE;
DEFINE i_enviar_sms                 INTEGER;
DEFINE cFinVigencia                 DATE;
DEFINE s_secuencia_tarjeta          SMALLINT;
DEFINE s_envio_notificacion         SMALLINT;
DEFINE s_envio_email                SMALLINT;
DEFINE s_particionar_proceso        INTEGER;
DEFINE i_registros_proceso          INTEGER;
DEFINE i_mensajes_exitosos          INTEGER;
DEFINE i_mensajes_pendientes          INTEGER;
DEFINE cLinea_actual                DECIMAL(18,2);
DEFINE d_porcentaje_de_inflacion    DECIMAL(18,2);
DEFINE d_linea_credito_minima       DECIMAL(18,2);
DEFINE cLineaCredito                DECIMAL(18,2);
DEFINE cLinea_maxima                DECIMAL(18,2);
DEFINE d_fecha_fin_proceso          DATE;
DEFINE i_primera_notificacion       INTEGER;
DEFINE i_segunda_notificacion       INTEGER;
DEFINE s_notificacion_ejecutar      SMALLINT;
DEFINE i_dias_prim_notificacion     INTEGER;
DEFINE i_dias_seg_notificacion      INTEGER;
DEFINE c_producto                   CHAR(4);
DEFINE i_dias_diferencia            INTEGER;
DEFINE i_numero_notificaciones      INTEGER;


LET cCodRet                         = "00000";
LET cCodRetSms                      = "";
LET iSqlErr                         = 0;
LET d_fecha_hoy                     = DATE(1); 
LET d_fecha_notificacion_cliente    = DATE(1);
LET cNumCte                         = '';
LET cNumCredito                     = '';
LET cTelefono                       = '';
LET cErrorInfo                      = '';
LET iSamErr                         = 0;
LET cMensajeRet                     = '';
LET d_linea_oferta                  = 0;        
LET d_fin_vigencia                  = DATE(1);
LET d_inicio_vigencia               = DATE(1);
LET i_intento_notificacion          = 0;
LET cIncrementoActivo               = "";
LET cCodRetCon                      = "";
LET cLinea_credito                  = 0;
LET c_term_tarjeta                  = "";
LET cCodretConBue                   = "";
LET cMensaje                        = "";
LET cIsCtePros                      = "";
LET c_num_cte                       = "";
LET cNombre                         = "";
LET cRFC                            = "";
LET dtFechaSol                      = DATE(1);
LET dtFechaAut                      = DATE(1);
LET dLinCredAct                     =0;
LET dLinCredCal                     =0;
LET c_nombre_cliente                =0;
LET cOrigen                         ="";
LET cStatus                         ="";
LET cDescStatus                     ="";
LET cComentario                     ="";
LET cNumSol                         = "";
LET c_num_tarjeta                   = "";
LET c_email_cliente                 = "";
LET c_num_producto                  = "";
LET d_linea_actual                  = 0;
LET c_nombre_prod                   = "";
LET i_enviar_sms                    = 0;
LET i_diferencia_dias               = 0;
LET cFinVigencia                    = DATE(1);
LET s_secuencia_tarjeta             =0;
LET s_envio_notificacion            = 0;
let s_envio_email                   = 0;
LET s_particionar_proceso           =0;
LET i_registros_proceso             =30000;
LET i_mensajes_exitosos             =0;
LET i_mensajes_pendientes           =0;
LET cLinea_actual                   =0;
LET d_porcentaje_de_inflacion       =0;
LET d_linea_credito_minima          =0;
LET cLineaCredito                   =0;
LET cLinea_maxima                   =0;
LET d_fecha_fin_proceso             = DATE(1);
LET i_primera_notificacion          =0;
LET i_segunda_notificacion          =0;
LET s_notificacion_ejecutar         =0;
LET i_dias_prim_notificacion        =0;
LET i_dias_seg_notificacion         =0;
LET c_producto                      ="";
LET i_dias_diferencia               =0;
LET i_numero_notificaciones         =0;


BEGIN
    ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
        IF iSqlErr != 0 THEN
            LET cCodRet=iSqlErr;
            LET cMensajeRet = cErrorInfo||' '||iSamErr;
            RETURN cCodRet,i_mensajes_exitosos,i_mensajes_pendientes;
        END IF;
    END EXCEPTION;
   
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    
    SELECT fecha_hoy INTO d_fecha_hoy FROM bdicred:"informix".sd_fechas WHERE empresa = p_empresa;

    SELECT MAX(fecha_fin_vigencia) INTO d_fecha_fin_proceso FROM bdicred:"informix".sd_carga_inflacion_tc;

     FOREACH WITH HOLD
       SELECT num_producto, fecha_inicio_vigencia
        INTO c_producto, d_inicio_vigencia
        FROM bdicred:"informix".sd_carga_inflacion_tc where  fecha_inicio_vigencia <= d_fecha_hoy AND fecha_fin_vigencia >= d_fecha_hoy
        

        
        SELECT dias_prim_notificacion, dias_seg_notificacion, numero_notificaciones, descripcion,linea_credito_minima
        INTO i_dias_prim_notificacion,i_dias_seg_notificacion,i_numero_notificaciones,c_nombre_prod,d_linea_credito_minima
        FROM bdicred:"informix".sd_param_incremento_inf_tc 
        WHERE producto = c_producto;
               
        LET i_dias_diferencia = d_fecha_hoy - d_inicio_vigencia;

        IF i_dias_diferencia < i_dias_prim_notificacion THEN
            LET s_notificacion_ejecutar = 0;
        ELSE
         IF i_dias_diferencia < i_dias_seg_notificacion THEN
            LET s_notificacion_ejecutar =1;
         ELSE
            LET s_notificacion_ejecutar =2;
         END IF;
        END IF;

          FOREACH WITH HOLD
            SELECT FIRST i_numero_notificaciones num_cliente, num_credito, celular_cliente, linea_oferta, fin_vigencia , intento_notificacion , num_producto, nombre_cliente,linea_actual,email_cliente,fecha_notificacion_cliente,inicio_vigencia,envio_email,fin_vigencia,porcentaje_de_inflacion,tope_maximo
                INTO cNumCte, cNumCredito, cTelefono, d_linea_oferta, d_fin_vigencia, i_intento_notificacion, c_num_producto,c_nombre_cliente, d_linea_actual, c_email_cliente,d_fecha_notificacion_cliente,d_inicio_vigencia,s_envio_email,cFinVigencia,d_porcentaje_de_inflacion,cLinea_maxima
                FROM bdicred:"informix".sd_bitacora_incremento_inflacion
                WHERE confirma_incremento = 0 and intento_notificacion = s_notificacion_ejecutar and fin_vigencia >= d_fecha_hoy and num_producto = c_producto

                       	EXECUTE PROCEDURE bdicred:"informix".sp_consultarctesincrementolincred_web("001",cNumCte,"","","1","",0,0) 
			            INTO cCodretConBue, cMensaje, cIsCtePros, c_num_cte, cNombre, cRFC, dtFechaSol, dtFechaAut, dLinCredAct, dLinCredCal, cOrigen, cStatus, cDescStatus, cComentario, cNumSol;
                        
                        IF cCodretConBue = "00000" THEN
                            LET i_mensajes_pendientes = i_mensajes_pendientes +1;
                            INSERT INTO bdicred:"informix".sd_bitacora_sms_incremento(num_credito,cod_ret,plantilla,fecha) Values (cNumCredito,'00004','SMS_INCSAL',d_fecha_hoy); 
			                CONTINUE FOREACH;
                        END IF;


                	SELECT monto_otorgado  	
		                INTO cLinea_actual  
		                FROM bdicred:"informix".sd_maesdos
		                WHERE num_credito = cNumCredito;

                    IF cLinea_actual != d_linea_actual THEN 
		            	LET cLineaCredito = ROUND(cLinea_actual + (cLinea_actual * (d_porcentaje_de_inflacion / 100)),-2);

			            IF cLineaCredito >  cLinea_maxima THEN
				            LET cLineaCredito = cLinea_maxima;
			            END IF;

                        IF cLineaCredito < d_linea_credito_minima THEN 
                            LET i_mensajes_pendientes = i_mensajes_pendientes +1;
                              INSERT INTO bdicred:"informix".sd_bitacora_sms_incremento(num_credito,cod_ret,plantilla,fecha) Values (cNumCredito,'00007','SMS_INCSAL',d_fecha_hoy); 

                            CONTINUE FOREACH;
                        END IF;

                    ELSE 
                      LET cLineaCredito = d_linea_oferta;
			        END IF;

                    SELECT MAX(secuencia)
                        INTO s_secuencia_tarjeta
                        FROM bdicred:"informix".sd_tarjeta
                        WHERE num_credito = cNumCredito  AND tipo_tarjeta = 'T' AND status_tar = 'A';

                    SELECT num_tarjeta
                        INTO c_num_tarjeta
                        FROM bdicred:"informix".sd_tarjeta
                        WHERE num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A' AND secuencia = s_secuencia_tarjeta;

                    LET i_diferencia_dias = d_fecha_hoy - d_inicio_vigencia;  

                    IF i_diferencia_dias >=0 AND i_intento_notificacion =0 THEN
                        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','SMS_RECI','SMS_INCSAL',cNumCte,'',SUBSTR(c_num_tarjeta,13),'2',cLineaCredito,cFinVigencia,'','',c_nombre_prod,'','','','','',
                                '','',0,0,0,0,0,'','') INTO cCodRetSms;

                        IF cCodRetSms = '00000' THEN
                            LET i_enviar_sms  = 1;
                        ELSE 
                            LET i_mensajes_pendientes = i_mensajes_pendientes +1;
                              INSERT INTO bdicred:"informix".sd_bitacora_sms_incremento(num_credito,cod_ret,plantilla,fecha) Values (cNumCredito,cCodRetSms,'SMS_INCSAL',d_fecha_hoy); 
                        END IF;

                      

                    END IF;

                    IF i_diferencia_dias >= i_dias_prim_notificacion AND i_intento_notificacion = 1 THEN
                        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','SMS_RECI','SMS_INC30N' ,cNumCte,'',SUBSTR(c_num_tarjeta,13),'2',cLineaCredito,cFinVigencia,'','','','','','','','',
                                '','',0,0,0,0,0,'','') INTO cCodRetSms;

                        IF cCodRetSms = '00000' THEN
                            LET i_enviar_sms  = 1;
                        ELSE
                            LET i_mensajes_pendientes = i_mensajes_pendientes +1;
                            INSERT INTO bdicred:"informix".sd_bitacora_sms_incremento(num_credito,cod_ret,plantilla,fecha) Values (cNumCredito,cCodRetSms,'SMS_INC30N',d_fecha_hoy); 
                        END IF;


                   
                    END IF;

                   
                    IF i_diferencia_dias >= i_dias_seg_notificacion AND i_intento_notificacion = 2 THEN
                        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','SMS_RECI','SMS_INC30N2',cNumCte,'',SUBSTR(c_num_tarjeta,13),'2',cLineaCredito,cFinVigencia,'','','','','','','','',
                                '','',0,0,0,0,0,'','') INTO cCodRetSms;

                        IF cCodRetSms = '00000' THEN
                            LET i_enviar_sms  = 1;
                          ELSE
                            LET i_mensajes_pendientes = i_mensajes_pendientes +1;
                            INSERT INTO bdicred:"informix".sd_bitacora_sms_incremento(num_credito,cod_ret,plantilla,fecha) Values (cNumCredito,cCodRetSms,'SMS_INC30N2',d_fecha_hoy);
                        END IF;


                    END IF;

                    IF i_diferencia_dias >= 15 AND s_envio_email = 0 THEN
                        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CRED_EMAIL','INC_NOACTP',cNumCte,'',SUBSTR(c_num_tarjeta,13),'2',d_linea_actual,cLineaCredito,cFinVigencia,d_linea_actual,'','','','','','',
                                '','',0,0,0,0,0,'','') INTO cCodRetSms;
                        IF cCodRetSms = '00000' THEN
                            UPDATE bdicred:"informix".sd_bitacora_incremento_inflacion SET envio_email = 1   WHERE num_credito = cNumCredito AND confirma_incremento = 0  and fin_vigencia >= d_fecha_hoy;
                            UPDATE bdicred:"informix".sd_certificar_reglas_negocio SET  envio_email = 1 WHERE num_credito = cNumCredito  AND confirma_incremento = 0  and fin_vigencia >= d_fecha_hoy;
                            LET s_envio_notificacion = 1;
                        ELSE 
                            INSERT INTO bdicred:"informix".sd_bitacora_sms_incremento(num_credito,cod_ret,plantilla,fecha) Values (cNumCredito,cCodRetSms,'INC_NOACTP',d_fecha_hoy);
                        END IF;      
                   
                    END IF;

                    IF i_enviar_sms = 1 THEN
                        LET s_envio_notificacion = 1;
                        LET i_enviar_sms  = 0;
                        LET i_mensajes_exitosos = i_mensajes_exitosos + 1;
                        UPDATE bdicred:"informix".sd_bitacora_incremento_inflacion SET  envio_sms = 1 , intento_notificacion = i_intento_notificacion +1,fecha_notificacion_cliente = d_fecha_hoy,canal_notificacion_cliente = '9',nueva_linea_credito = cLineaCredito, linea_oferta = cLineaCredito WHERE num_credito = cNumCredito  AND confirma_incremento = 0  and fin_vigencia >= d_fecha_hoy;
                        UPDATE bdicred:"informix".sd_certificar_reglas_negocio SET  envio_sms = 1 , intento_notificacion = i_intento_notificacion +1,canal_notificacion_cliente = '9',nueva_linea_credito = cLineaCredito WHERE num_credito = cNumCredito  AND confirma_incremento = 0  and fin_vigencia >= d_fecha_hoy ;
                    END IF;
                    
        END FOREACH;

    END FOREACH;

    IF s_envio_notificacion = 0 THEN
        IF d_fecha_hoy + 1 != d_fecha_fin_proceso THEN 
            LET cCodRet = '00001';
        END IF;
    END IF;

    IF d_fecha_fin_proceso < d_fecha_hoy THEN 
        TRUNCATE TABLE bdicred:"informix".sd_bitacora_sms_incremento;
    END IF;

   RETURN cCodRet,i_mensajes_exitosos,i_mensajes_pendientes;
END
END PROCEDURE;