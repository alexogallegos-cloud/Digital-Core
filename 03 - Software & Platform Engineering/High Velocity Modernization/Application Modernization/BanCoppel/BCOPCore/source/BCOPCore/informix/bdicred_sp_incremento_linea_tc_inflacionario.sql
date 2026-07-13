CREATE PROCEDURE "informix".sp_incremento_linea_tc_inflacionario(
    p_empresa CHAR(3) -- Empresa
)              
RETURNING 
    CHAR(5) AS CodigoRetorno;

-- CONTROL DE CAMBIOS:
---------------------------------------------------------------------------------
-- Autor: SECP.
-- Modificacion: Registrar los clientes que son candidatos para el aumento de credito por inflacion.
-- Fecha de Modificacion: 07-10-2024.
-- Peticion: RQM 10 1647 â Incremento  linea de credito TDC por inflacion.
---------------------------------------------------------------------------------

--*************************************************************************
--                         DEFINICION DE VARIABLES
--*************************************************************************
DEFINE cCodRet   		            CHAR(5);
DEFINE vsqlerr 			            INTEGER;
DEFINE c_formato_firmado            CHAR(1);
DEFINE c_producto                   CHAR(4);
DEFINE c_considerar_vencimiento     CHAR(1);
DEFINE c_antiguedad_minima          INTEGER; 
DEFINE c_intervalo_fecha_corte      INTEGER; 
DEFINE c_utilizacion_credito_min    DECIMAL(18,2);
DEFINE d_utilizacion_credito        DECIMAL(18,2);
DEFINE c_saldo_credito              DECIMAL(18,2);
DEFINE c_saldo_vencido              DECIMAL(18,2);
DEFINE c_linea_credito_minima       DECIMAL(18,2);
DEFINE c_linea_credito_maxima       DECIMAL(18,2);
DEFINE c_porcentaje_de_inflacion    DECIMAL(18,2);
DEFINE c_porcentaje_de_incremento   DECIMAL(18,2);
DEFINE d_fecha_fin_vigencia         DATE;
DEFINE d_fecha_inicio_vigencia      DATE;
DEFINE c_bandera_aceptacion_rechazo CHAR(1);
DEFINE c_canal_aceptacion           CHAR(10);
DEFINE d_fecha_aceptacion_oferta    DATE;
DEFINE d_fecha_aplicacion           DATE;
DEFINE d_fecha_hoy                  DATE;
DEFINE c_canal_notificacion_cliente CHAR(10);
DEFINE c_envio_sms                  CHAR(1);
DEFINE c_envio_email                CHAR(1);
DEFINE c_confirma_incremento        CHAR(1);
DEFINE i_intento_notificacion       INTEGER;
DEFINE c_empleado_aplica_incremento CHAR(10);
DEFINE d_fecha_dec_behavior         DATE;
DEFINE d_fecha_dec_dirty            DATE;
DEFINE d_fecha_dec_reduccion        DATE;
DEFINE d_fecha_ult_decremento       DATE;
DEFINE c_numcte                     CHAR(20);
DEFINE c_numcredito                 CHAR(20);
DEFINE c_status_cred                CHAR(20);
DEFINE d_monto_otorgado             DECIMAL(18,2);
DEFINE d_monto_otorgado_hist        DECIMAL(18,2);
DEFINE d_sdo_cap_insoluto           DECIMAL(18,2);
DEFINE d_sdo_cap_insoluto_hist           DECIMAL(18,2);
DEFINE d_vencido_actual             DECIMAL(18,2);
DEFINE cNombreCliente               CHAR(104);
DEFINE c_telefono                   CHAR(10);
DEFINE c_correo_elec                CHAR(100);
DEFINE vNuevaLineaCredito	        DECIMAL(18,2);      -- Nueva linea de credito final del cliente al aceptar el incremento.
DEFINE dFechaAlta                   DATE;
DEFINE i_contador                   INTEGER;
DEFINE i_contador_particion         INTEGER;
DEFINE i_guardar_datos              INTEGER;
DEFINE s_valida_registro            SMALLINT;
DEFINE d_fecha_max_ciclo            DATE;  
DEFINE s_credito_activo             SMALLINT;
DEFINE d_fecha_saldo                DATE;
DEFINE d_fecha_mes_2_reduc          DATE;
DEFINE d_vencido                    DECIMAL(18,2);
DEFINE d_vencidotrasp               DECIMAL(18,2);
DEFINE d_fechaapert            		DATE;  
DEFINE c_dia_corte                  CHAR(2);
DEFINE i_dias_decremento            INTEGER;
DEFINE d_utilizacion_credsdo		DECIMAL(18,2);
DEFINE cantiguedad                  INTEGER;
DEFINE d_fecha_corte                DATE;
DEFINE d_fecha_intervalo_corte      DATE;
DEFINE v_cargado                    SMALLINT;
DEFINE v_count                      INTEGER;
DEFINE i_dias_diferencia            INTEGER;
DEFINE i_dias_ofertado              INTEGER;
-- *************************************************************************
-- *                        ASIGNACION DE VARIABLES
-- **************************************************************************

LET c_formato_firmado               = "";
LET c_formato_firmado               = "";
LET c_producto                      = "";
LET c_considerar_vencimiento        = "";
LET c_antiguedad_minima             = 0; 
LET c_intervalo_fecha_corte         = 0; 
LET c_utilizacion_credito_min       = 0;
LET c_saldo_credito                 = 0;
LET c_saldo_vencido                 = 0;
LET c_linea_credito_minima          = 0;
LET c_linea_credito_maxima          = 0;
LET d_fecha_fin_vigencia            = "";
LET d_fecha_inicio_vigencia         = "";
LET c_porcentaje_de_inflacion       = 0;
LET c_bandera_aceptacion_rechazo    = "";
LET c_canal_aceptacion              = "";
LET d_fecha_aceptacion_oferta       = "";
LET d_fecha_aplicacion              = "";
LET d_fecha_hoy                     = "";
LET c_canal_notificacion_cliente    = "";
LET c_envio_sms                     = "";
LET c_envio_email                   = "";
LET c_confirma_incremento           = "";
LET i_intento_notificacion          = 0;
LET c_empleado_aplica_incremento    = "";
LET d_fecha_dec_behavior            = DATE(1);
LET d_fecha_dec_dirty               = DATE(1);
LET d_fecha_dec_reduccion           = DATE(1);
LET d_fecha_ult_decremento          = DATE(1);
LET c_numcte                        = '';
LET c_numcredito                    = '' ;
LET c_status_cred                   = '';
LET d_monto_otorgado                = 0;
LET d_monto_otorgado_hist           = 0;
LET d_sdo_cap_insoluto              = 0;
LET d_sdo_cap_insoluto_hist              = 0;
LET d_vencido_actual                = 0 ;
LET cNombreCliente                  = '';
LET c_telefono                      = '';
LET c_correo_elec                   = '';
LET vNuevaLineaCredito              = 0;
LET cCodRet                         = '00000';
LET dFechaAlta                      = DATE(1);
LET c_porcentaje_de_incremento      = 0;
LET i_contador     	                = 1;
LET i_contador_particion     	    = 0;
LET i_guardar_datos                 = 1000;
LET s_valida_registro               = 0;
LET d_fecha_max_ciclo               = DATE(1); 
LET s_credito_activo                = 0;
LET d_fecha_saldo                   = DATE(1);
LET d_utilizacion_credito           = 0;
LET d_fecha_mes_2_reduc             = DATE(1);
LET d_vencido                       = 0;
LET d_vencidotrasp                  = 0;
LET d_fechaapert                    = DATE(1);
LET c_dia_corte                     = '';
LET i_dias_decremento               = 0;
LET d_utilizacion_credsdo		    = 0;
LET cantiguedad                     = 0;
LET d_fecha_corte                   = DATE(1);
LET d_fecha_intervalo_corte         = DATE(1);
LET v_cargado                       = 0;
LET v_count                         = 0;
LET i_dias_diferencia               =0;
LET i_dias_ofertado               =0;
-- **********************************************************************
-- *                        CONTROL DE ERRORES
-- ***********************************************************************
BEGIN
    ON EXCEPTION SET vsqlerr
        IF vsqlerr != 0 THEN
            LET cCodRet=vsqlerr;
             --COMMIT WORK;
            RETURN cCodRet ;
        END IF; 
    END EXCEPTION;

     -- SET DEBUG FILE TO '/home/e10000187/TRACE/sp_incremento_linea_tc_inflacionario.out';
     -- TRACE ON;

    -- **********************************************************************
    -- *                        PROGRAMA PRINCIPAL
    -- **********************************************************************
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


    SELECT fecha_hoy
        INTO d_fecha_hoy
        FROM bdicred:"informix".sd_fechas
        WHERE empresa = p_empresa;


    -- Obtenemos todos los valores a usar de la tabla bdicred:"informix".sd_param
	
  
    
    --consulta ultimo cliete procesado
    
 

        FOREACH WITH HOLD
            SELECT PARAM.producto,PARAM.considerar_vencimiento,PARAM.antiguedad_minima,PARAM.intervalo_fecha_corte,PARAM.utilizacion_credito_min,PARAM.saldo_credito,PARAM.saldo_vencido,PARAM.linea_credito_minima,CARGA.fecha_inicio_vigencia,
            PARAM.linea_credito_maxima,CARGA.porcentaje_inflacion,CARGA.fecha_fin_vigencia,DEFINICION.dia_cuota,PARAM.dias_decremento,PARAM.dias_diferencia
                INTO c_producto,c_considerar_vencimiento,c_antiguedad_minima,c_intervalo_fecha_corte,
            c_utilizacion_credito_min,c_saldo_credito,c_saldo_vencido,c_linea_credito_minima,
            d_fecha_inicio_vigencia,c_linea_credito_maxima,c_porcentaje_de_inflacion,d_fecha_fin_vigencia,c_dia_corte,i_dias_decremento,i_dias_diferencia
        FROM bdicred:"informix".sd_param_incremento_inf_tc PARAM 
        INNER JOIN bdicred:"informix".sd_carga_inflacion_tc CARGA ON CARGA.num_producto = PARAM.producto 
		INNER JOIN bdicred:"informix".sd_definicion DEFINICION  on DEFINICION.num_producto = CARGA.num_producto
        WHERE PARAM.aplica = '1' AND CARGA.fecha_inicio_vigencia <= d_fecha_hoy AND CARGA.fecha_fin_vigencia >= d_fecha_hoy


             
        SELECT cargado INTO v_cargado 
        FROM bdicred:"informix".sd_procesamiento_productos 
        WHERE producto = c_producto;   

        IF v_cargado IS NULL THEN
            INSERT INTO bdicred:"informix".sd_clientes_prospectos_inf_tc (
            producto, numcte, num_credito, status_cred, fecha_apertura, 
            monto_otorgado, sdo_cap_insoluto, monto_vencido, mto_fin_ven_trasp
        )
        SELECT 
        MAECRE.num_producto, 
        MAECRE.numcte, 
        MAECRE.num_credito, 
        MAECRE.status_cred, 
        MAECRE.fecha_apertura, 
        MAESDOS.monto_otorgado, 
        MAESDOS.sdo_cap_insoluto, 
        MAESDOS.monto_vencido, 
        MAESDOS.mto_fin_ven_trasp
        FROM bdicred:"informix".sd_maecred MAECRE
        INNER JOIN bdicred:"informix".sd_maesdos MAESDOS 
        ON MAESDOS.num_credito = MAECRE.num_credito 
        WHERE MAECRE.num_producto = c_producto 
        AND MAESDOS.monto_otorgado >= c_linea_credito_minima 
        AND MAESDOS.monto_otorgado <= c_linea_credito_maxima;

             -- Marcar como cargado en tabla de control
            INSERT INTO bdicred:"informix".sd_procesamiento_productos (producto, cargado)
            VALUES (c_producto, 1);
        END IF;




        FOREACH WITH HOLD
            SELECT numcte,num_credito, status_cred,fecha_apertura, monto_otorgado,sdo_cap_insoluto,monto_vencido,mto_fin_ven_trasp
                INTO c_numcte,c_numcredito,c_status_cred,d_fechaapert,d_monto_otorgado,d_sdo_cap_insoluto,d_vencido, d_vencidotrasp                
				FROM bdicred:"informix".sd_clientes_prospectos_inf_tc where procesado = 0 AND producto = c_producto
          
                UPDATE bdicred:"informix".sd_clientes_prospectos_inf_tc
                SET procesado = 1
                WHERE num_credito = c_numcredito;

				LET d_vencido_actual = d_vencido + d_vencidotrasp; 
				LET cantiguedad = months_between(d_fecha_hoy,d_fechaapert);
                
                IF d_monto_otorgado != 0 THEN
                     LET d_utilizacion_credsdo = ROUND((d_sdo_cap_insoluto / d_monto_otorgado) *100,2);
                END IF;

                IF d_vencido_actual > c_saldo_vencido THEN
                    CONTINUE FOREACH;
                END IF;
                
                IF 	d_utilizacion_credsdo <= c_utilizacion_credito_min THEN
				    CONTINUE FOREACH;
			    END IF;

                IF cantiguedad <  c_antiguedad_minima THEN 
                    CONTINUE FOREACH;
                END IF;

            SELECT COUNT(*)    
		INTO s_valida_registro
		FROM bdicred:"informix".sd_bitacora_incremento_inflacion
		WHERE num_credito = c_numcredito
		AND (confirma_incremento <> "1" or (d_fecha_hoy-fin_vigencia) < i_dias_diferencia)
		AND fin_vigencia >= d_fecha_hoy;

        IF s_valida_registro > 0 THEN
            CONTINUE FOREACH; 
        END IF;

            LET s_credito_activo = 0;

            IF DAY(d_fecha_hoy) <= c_dia_corte THEN
                LET d_fecha_corte = MDY(MONTH(d_fecha_hoy),c_dia_corte,YEAR(d_fecha_hoy)) - 1 UNITS MONTH;
            ELSE
                LET d_fecha_corte  = MDY(MONTH(d_fecha_hoy),c_dia_corte,YEAR(d_fecha_hoy)) ;
            END IF;

                LET d_fecha_intervalo_corte =  d_fecha_corte - c_intervalo_fecha_corte UNITS MONTH;

            FOREACH WITH HOLD
             SELECT sdo_cap_insoluto,monto_otorgado INTO d_sdo_cap_insoluto_hist,d_monto_otorgado_hist
                from bdicred:sd_maesdoshist where num_credito = c_numcredito AND fecha <= d_fecha_corte AND fecha > d_fecha_intervalo_corte 

                IF d_monto_otorgado_hist != 0  THEN 
                    LET d_utilizacion_credito = ROUND((d_sdo_cap_insoluto_hist  / d_monto_otorgado_hist) *100,2);
                END IF;

                IF  d_utilizacion_credito > c_utilizacion_credito_min THEN
                    LET s_credito_activo = 1;
                    EXIT FOREACH;
                END IF; 
            END FOREACH;

            IF s_credito_activo = 0 THEN
                CONTINUE FOREACH;
            END IF;

            LET vNuevaLineaCredito = ROUND(d_monto_otorgado + (d_monto_otorgado * (c_porcentaje_de_inflacion / 100)), -2);

			LET c_porcentaje_de_incremento = c_porcentaje_de_inflacion;

            IF vNuevaLineaCredito >= c_linea_credito_maxima THEN
                LET vNuevaLineaCredito = c_linea_credito_maxima;
                LET c_porcentaje_de_incremento = ((vNuevaLineaCredito - d_monto_otorgado)/d_monto_otorgado) * 100;
            END IF;

            SELECT TRIM(nombre1) || " " || TRIM(nombre2) || " " || TRIM(apell_paterno) || " " || TRIM(apell_materno),fecha_alta
                INTO cNombreCliente,dFechaAlta
                FROM bdinteg:"informix".si_cliente 
                WHERE numcte = c_numcte;

            SELECT telefono 
                INTO c_telefono  
                FROM bdinteg:"informix".si_telefonos_actual
                WHERE tipo_tel = 2
                AND status_tel = 'A'
                AND numcte =c_numcte
                AND secuencia = (SELECT MAX(secuencia)  FROM bdinteg:"informix".si_telefonos_actual
                WHERE tipo_tel = 2
                AND status_tel = 'A'
                AND numcte =c_numcte);

            SELECT  correo_elec 
                INTO c_correo_elec 
                FROM bdinteg:"informix".si_correos 
                WHERE numcte = c_numcte 
                AND status_correo = 'A'
                AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos 
                WHERE numcte = c_numcte 
                AND status_correo = 'A');

            SELECT MAX(fecha_insert) 
                INTO d_fecha_dec_dirty 
                FROM  bdicred:"informix".sd_bitacora_redlincred_dirty 
                WHERE num_credito = c_numcredito;
            
            IF d_fecha_dec_dirty IS NULL THEN
                LET d_fecha_dec_dirty = DATE(1);
            END IF;

            SELECT MAX(fecha_insert) 
                INTO d_fecha_dec_behavior 
                FROM bdicred:"informix".sd_reduc_behavior_creditos  
                WHERE num_credito = c_numcredito;

            IF d_fecha_dec_behavior IS NULL THEN
                LET d_fecha_dec_behavior = DATE(1);
            END IF;

            SELECT MAX(fecha_insert) 
                INTO d_fecha_dec_reduccion  
                FROM bdicred:"informix".sd_incremento_reduccion  
                WHERE num_credito = c_numcredito AND tp_parametrico = 'R' ;

            IF d_fecha_dec_behavior IS NULL THEN
                LET d_fecha_dec_behavior = DATE(1);
            END IF; 

            SELECT MAX(fecha_mes_2_reduc) 
                INTO d_fecha_mes_2_reduc
                FROM bdicred:"informix".sd_cancela_creds_nunca 
                WHERE num_credito = c_numcredito ;

            IF d_fecha_mes_2_reduc IS NULL THEN
                LET d_fecha_mes_2_reduc = DATE(1);
            END IF; 


            IF d_fecha_dec_dirty >= d_fecha_dec_behavior AND d_fecha_dec_dirty >= d_fecha_dec_reduccion AND d_fecha_dec_dirty >= d_fecha_mes_2_reduc THEN
                LET d_fecha_ult_decremento = d_fecha_dec_dirty;
            END IF;

            IF d_fecha_dec_behavior >= d_fecha_dec_dirty AND d_fecha_dec_behavior >= d_fecha_dec_reduccion AND d_fecha_dec_behavior >= d_fecha_mes_2_reduc THEN
                LET d_fecha_ult_decremento = d_fecha_dec_behavior;
            END IF;

            IF d_fecha_dec_reduccion >= d_fecha_dec_dirty AND d_fecha_dec_reduccion >= d_fecha_dec_behavior AND d_fecha_dec_reduccion >= d_fecha_mes_2_reduc THEN
                LET d_fecha_ult_decremento = d_fecha_dec_reduccion;
            END IF;

            IF d_fecha_mes_2_reduc >= d_fecha_dec_dirty AND d_fecha_mes_2_reduc >= d_fecha_dec_behavior AND d_fecha_mes_2_reduc >= d_fecha_dec_reduccion   THEN
                LET d_fecha_ult_decremento = d_fecha_dec_reduccion;
            END IF;

            IF d_fecha_hoy - d_fecha_ult_decremento > i_dias_decremento   THEN 


                IF i_contador = 1 THEN       
					BEGIN WORK;
				END IF;

                INSERT INTO bdicred:"informix".sd_bitacora_incremento_inflacion(num_cliente, nombre_cliente, num_credito, num_producto, estatus_credito, linea_actual, saldo_actual,vencido_actual,fecha_ult_decremento, formato_firmado, porcentaje_de_inflacion, linea_oferta, nueva_linea_credito, tope_maximo, bandera_aceptacion_rechazo, canal_aceptacion,fecha_aceptacion_oferta, fecha_aplicacion, fecha_notificacion_cliente, canal_notificacion_cliente, celular_cliente, envio_sms, email_cliente, envio_email, inicio_vigencia, fin_vigencia, confirma_incremento, intento_notificacion, empleado_aplica_incremento, fecha_ultimo_ofertamiento_sucursal,sucursal)
                    VALUES(NVL(c_numcte, ""), NVL(cNombreCliente, ""), NVL(c_numcredito, ""), NVL(c_producto, ""), NVL(c_status_cred, ""), NVL(d_monto_otorgado, 0.00), NVL(d_sdo_cap_insoluto, 0.00), NVL(d_vencido_actual, 0.00), NVL(d_fecha_ult_decremento, DATE(1)), NVL(c_formato_firmado, ""), NVL(c_porcentaje_de_inflacion, ""), NVL(vNuevaLineaCredito, 0.00), NVL(vNuevaLineaCredito, 0.00), NVL(c_linea_credito_maxima, 0.00), NVL(c_bandera_aceptacion_rechazo, ""), '', DATE(1), DATE(1), DATE(1), '', NVL(c_telefono, "") , '0', NVL(c_correo_elec, ""), '0', NVL(d_fecha_inicio_vigencia, DATE(1)), NVL(d_fecha_fin_vigencia, DATE(1)), '0', 0, '', DATE(1),'');

                INSERT INTO bdicred:"informix".sd_certificar_reglas_negocio ( num_cliente,nombre_cliente,num_credito,num_producto,estatus_credito,fecha_alta,linea_actual,saldo_actual,vencido_actual,fecha_ult_decremento,formato_firmado,porcentaje_inflacion,porcentaje_de_incremento,nueva_linea_credito,tope_maximo,flag_aceptacion_rechazo,canal_aceptacion,fecha_aceptacion_oferta,fecha_aplicacion,fecha_notificacion_cliente,canal_notificacion_cliente,celular_cliente,envio_sms,email_cliente,envio_email,inicio_vigencia,fin_vigencia,confirma_incremento,intento_notificacion,empleado_aplica_incremento,flag_incremento,fecha_corte)
                    VALUES (NVL(c_numcte, ""), NVL(cNombreCliente, ""), NVL(c_numcredito, ""), NVL(c_producto, ""), NVL(c_status_cred, ""), NVL(d_fechaapert, DATE(1)), NVL(d_monto_otorgado, 0.00), NVL(d_sdo_cap_insoluto, 0.00), NVL(d_vencido_actual, 0.00), NVL(d_fecha_ult_decremento, DATE(1)), NVL(c_formato_firmado, ""), NVL(c_porcentaje_de_inflacion, ""), NVL(c_porcentaje_de_incremento, ""), NVL(vNuevaLineaCredito, 0.00), NVL(c_linea_credito_maxima, 0.00), NVL(c_bandera_aceptacion_rechazo, ""), '', DATE(1), DATE(1), DATE(1),'', NVL(c_telefono, ""),'0', NVL(c_correo_elec, ""),'0',NVL(d_fecha_inicio_vigencia, DATE(1)), NVL(d_fecha_fin_vigencia, DATE(1)),'0',0,'',0,NVL(d_fecha_inicio_vigencia, DATE(1)));

                LET i_contador_particion =i_contador_particion + 1;


                IF i_contador = i_guardar_datos THEN               
					COMMIT WORK;
					LET i_contador = 1;           
				ELSE
					LET i_contador = i_contador + 1;
				END IF;          

            END IF;

            IF i_contador_particion >= 200000 THEN
                IF MOD(i_contador_particion,i_guardar_datos) != 0 THEN 
                    COMMIT WORK;
                END IF;  
                RETURN cCodRet;
             END IF;


        END FOREACH;

        
        SELECT COUNT(*) INTO v_count 
        FROM bdicred:"informix".sd_clientes_prospectos_inf_tc 
        WHERE producto = c_producto 
        AND procesado = 0; 

        IF v_count = 0 THEN
            DELETE FROM bdicred:"informix".sd_clientes_prospectos_inf_tc 
            WHERE producto = c_producto;

        END IF;   

    END FOREACH; 

    IF i_contador > 1 THEN
        COMMIT WORK;
    END IF;  

   
        DELETE FROM bdicred:"informix".sd_procesamiento_productos ;

    RETURN cCodRet;

END
END PROCEDURE
DOCUMENT 
'----------------------------------------------------------------------------',
'Descripcion : Registrar los clientes que son candidatos para el aumento de credito por inflacion',
'Modifico    : SECP',
'Fecha       : 07/10/2024',
'BD          : BDICRED',
'----------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_arch_cartera_pyr_opt()
RETURNING CHAR(6),
		  CHAR(150);

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(150);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_ret2			CHAR(6);
DEFINE cErrorInfo           CHAR(80);
DEFINE cSQL                 CHAR(2204);
DEFINE cCod_RetIB           CHAR(6);
define pfechacorte 			date;
define Vpri_dia_mes			date;
define Vult_dia_mes			date;
define vproceso				char(4);
--variables
DEFINE Vnumcreditortc       char(20);
DEFINE Vnumcreditotdc       char(20);
DEFINE Vnumcuentartc      	char(20);
DEFINE Vnumtarjetatdc       char(20);
DEFINE Vnumcte        		char(20);
DEFINE Vnumsucursal     	char(4);
DEFINE Vnumciudad			char(4);
DEFINE Vfechareestructura 	date;
DEFINE Vsaldoactual      	decimal(18,2);
DEFINE Vinteres       		decimal(18,2);
DEFINE Vsaldovencido     	decimal(18,2);
DEFINE Vinteresvencido   	decimal(18,2);
DEFINE vinteres_moratorio	decimal(18,2);
DEFINE Vabonobase			decimal(18,2);
DEFINE Vabonosvencidos		smallint;
DEFINE Vestadocredito		char(2);
DEFINE Vplazortc			smallint;
DEFINE Vtasainteres			decimal(18,2);
DEFINE Vfechalimitedepago	date;
DEFINE Vfechaultmov			date;
DEFINE Vtipoultimomov		char(2);
DEFINE Vfechacorte			date;
define cNombreArchivo		char(70);
define cNombreArchivo2		char(70);
define cNombreArchivoNvo	char(70);
define sPaso				integer;
define cempresa				char(3);
define Vprod				char(4);
define vmontor1				decimal(18,2);
define vmontor2				decimal(18,2);
-- RQM 09 440
DEFINE VsaldoCapital		decimal(18,2);
DEFINE VsaldoTrasp			decimal(18,2);
DEFINE VvenciNoExig			decimal(18,2);
DEFINE VvenciExig			decimal(18,2);
DEFINE VintVigente			decimal(18,2);
DEFINE VintVencido			decimal(18,2);
DEFINE dFechaInicio			date;

DEFINE iTotalCuentasProcesadas	INTEGER;
DEFINE iCuentasInsertadas		INTEGER;
DEFINE iCuentasActualizadas		INTEGER;


DEFINE Vppyrnumcreditortc	char(20);
DEFINE Vppyrestadocredito	char(02);
DEFINE Vppyrtipoultimomov	char(02);
DEFINE Vppyrfechaultmov		date;
DEFINE dfechaultpago		date;
DEFINE vfecha_apertura		date;
DEFINE cNumCredito			char(20);

DEFINE cMensajeBitacora 	CHAR(80);

--SET DEBUG FILE TO "sp_arch_cartera_pyr_opt.out";
--TRACE ON; 

--Inicializacion de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cCod_ret2				= "000000";
LET cMensaje                = 'PROCESO EXITOSO.';
LET cSQL                    = "";
LET cCod_RetIB              = "000000";
let vproceso				='2071'; --'2069';
--variables
LET	Vnumcreditortc			= '';
LET Vnumcreditotdc			= '';
LET Vnumcuentartc			= '';
LET	Vnumtarjetatdc			= '';
LET	Vnumcte           	    = '';
LET	Vnumsucursal			= 0;
LET	Vnumciudad	            = '';
LET Vfechareestructura		= DATE(1);
LET Vsaldoactual			= 0;
LET Vinteres                = 0;
LET Vsaldovencido           = 0;
LET Vinteresvencido         = 0;
LET Vabonobase              = 0;
LET Vabonosvencidos         = 0;
LET vinteres_moratorio		= 0;
LET Vestadocredito          = 0;
LET Vplazortc      			= 0;
LET Vtasainteres   		    = 0;
LET Vfechalimitedepago      = DATE(1);
LET	Vfechaultmov            = DATE(1);
LET Vtipoultimomov          = '';
LET Vfechacorte             = DATE(1);
let cempresa 				= '001';
let Vprod					='';
let vmontor1				= 0;
let vmontor2				= 0;
-- RQM 09 440
LET VsaldoCapital			= 0;
LET VsaldoTrasp				= 0;
LET VvenciNoExig			= 0;
LET VvenciExig				= 0;
LET VintVigente				= 0;
LET VintVencido				= 0;
LET dFechaInicio			= DATE(1);
LET iTotalCuentasProcesadas	= 0;
LET iCuentasInsertadas		= 0;
LET iCuentasActualizadas	= 0;

LET Vppyrnumcreditortc		= '';
LET Vppyrestadocredito		= '';
LET Vppyrtipoultimomov		= '';
LET Vppyrfechaultmov		= DATE(1);
LET dfechaultpago			= DATE(1);
LET vfecha_apertura			= DATE(1);
LET cNumCredito				= '';
LET cMensajeBitacora 		= '';

--LET cNombreArchivo1= 'DirectorioCtesBancoppel' || LPAD(TRIM(DAY(CURRENT::DATE)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(CURRENT::DATE)::CHAR(2)),2,'0') ||YEAR(CURRENT::DATE) || '.txt';
--LET cNombreArchivo2= 'CifrasControlCarterasPPyRTC' || LPAD(TRIM(DAY(CURRENT::DATE)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(CURRENT::DATE)::CHAR(2)),2,'0') ||YEAR(CURRENT::DATE) || '.txt';
--LET cNombreArchivo ='cartera_reestructura_prestamo' || LPAD(TRIM(DAY(CURRENT::DATE)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(CURRENT::DATE)::CHAR(2)),2,'0') ||YEAR(CURRENT::DATE) || '.txt';
        

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
--            LET cMensaje = error_info;
			LET cMensaje = 'ERROR en el proceso: ' || TRIM(cNumCredito) || '   ' || 'columna ' || TRIM(error_info);
--            CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '02');
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '02') returning cCod_ret2;
        RETURN cCod_ret,cMensaje;
	END EXCEPTION;

	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

--    CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01');
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01') returning cCod_ret2;
	
	SELECT fecha_hoy, fecha_hoy - 1 units DAY --fecha_ant, pri_dia_mes 
	INTO pfechacorte,Vult_dia_mes -- ,Vpri_dia_mes 
	FROM bdicred:sd_fechas WHERE empresa = '001';
--temporal solo para pruebas
--let pfechacorte = mdy('06','03','2024');
--temporal solo para pruebas
	-- corre dias 3, 18 y 21
	SELECT COUNT(tabid) INTO sPaso FROM systables WHERE tabname= 'productos';
		IF NVL(sPaso,0) > 0 THEN
			DROP TABLE productos;
		END IF;
	
	CREATE TEMP TABLE productos(
	num_producto	CHAR(4)) WITH NO LOG;
	
	IF (day(pfechacorte) in(3,18)) OR ( day(pfechacorte) <= 20 ) THEN
		INSERT INTO productos VALUES ('6011');
		IF ( DAY(pfechacorte) < 17 ) THEN
		  let Vfechacorte = 2;
		ELSE 
		  let Vfechacorte = 17;
		END IF;
--		let Vfechainicio = Vfechacorte - 1 units MONTH;
	END IF;
	IF ( day(pfechacorte) > 20 ) THEN
		INSERT INTO productos VALUES ('6300');
		INSERT INTO productos VALUES ('7600');
		INSERT INTO productos VALUES ('7700');
		let Vfechacorte = 20;	
	END IF;

	let Vfechacorte = mdy(MONTH(pfechacorte), DAY(Vfechacorte), YEAR(pfechacorte));

	LET cNombreArchivo2= 'CifrasControlCarterasPPyRTC' ||to_char(Vfechacorte,'%d%m%Y')||'.txt';
	LET cNombreArchivo ='cartera_reestructura_prestamo'||to_char(Vfechacorte,'%d%m%Y')||'.txt';
	LET cNombreArchivoNvo ='cartera_reestructura_prestamo'||to_char(Vfechacorte,'%d%m%Y')||'_Ant.txt';
  
--    CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, 'Inicia Foreach', '02');
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, 'Inicia Foreach', '02') returning cCod_ret2;

	FOREACH WITH HOLD
		SELECT  NVL(a.num_producto,0),NVL(a.num_credito,0),NVL(a.credito_externo,0),NVL(cta.num_cta,0),NVL(tar.num_tarjeta,0), NVL(a.numcte,0),NVL(a.sucursal,0),NVL(s.ciudad,0),a.fecha_apertura,
				NVL(b.sdo_capital,0) + NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0) + NVL(b.cap_tras_no_venci,0)
				,NVL(b.mto_fin_ven_trasp,0),NVL(a.status_cred,''),NVL(a.plazo,0),NVL(a.tasa_interes,0) ,NVL(c.prox_fecha_pago,'01/01/1900')
				,c.fecha_ult_pago, 
				(CASE WHEN (a.status_cred IN ('AA','E1')) THEN (sdo_intereses + sdo_no_exig) ELSE 0 END),
				(CASE WHEN (a.status_cred NOT IN ('AA','E1')) THEN (sdo_intereses + sdo_no_exig + int_tra_no_exig) ELSE 0 END) --,today--,(b.sdo_exig_int + b.mto_venc_tra_int)
		INTO 	Vprod,Vnumcreditortc, Vnumcreditotdc, Vnumcuentartc,Vnumtarjetatdc ,Vnumcte,	Vnumsucursal,Vnumciudad, Vfechareestructura ,     
				Vsaldoactual,Vabonosvencidos ,Vestadocredito ,Vplazortc,Vtasainteres,Vfechalimitedepago,
				Vfechaultmov,Vinteres, Vinteresvencido   --Vfechacorte -- ,Vinteresvencido
		FROM bdicred:sd_maecredcrd a
			LEFT JOIN bdicred:sd_maesdoscrd b ON a.empresa = b.empresa AND a.num_credito = b.num_credito
			LEFT JOIN bdicred:sd_ctascarg cta ON a.num_credito = cta.num_credito AND cta.naturaleza = 'A'
			LEFT JOIN bdicred:sd_tarjeta tar ON  a.empresa = tar.empresa AND a.credito_externo = tar.num_credito AND tar.tipo_tarjeta ='T' AND tar.secuencia = (SELECT MAX(tar2.secuencia)
							FROM bdicred:sd_tarjeta tar2
							WHERE tar2.empresa = '001' 
							AND tar2.num_credito = a.credito_externo
							AND tar2.tipo_tarjeta ='T' )
			LEFT JOIN bdinteg:si_sucursales s ON (a.empresa = s.empresa AND a.sucursal = s.sucursal)
			LEFT JOIN bdicred:sd_maecredanexocrd c ON(a.empresa = c.empresa AND a.num_credito = c.num_credito)
		WHERE a.empresa ='001'
			AND a.num_producto IN (SELECT num_producto FROM productos)
			AND a.status_cred IN ('AA','BA','BT','VP','E1','E2','E3')
			AND a.campo_trab3 <> 'BAJA'
	
	
		IF Vnumcreditortc IS NULL OR Vnumcreditortc = '' THEN CONTINUE FOREACH; END IF;
		IF Vfechaultmov IS NULL OR Vfechaultmov = '' THEN LET Vfechaultmov = DATE(1); END IF;
		IF Vfechareestructura IS NULL OR Vfechareestructura = '' THEN LET Vfechareestructura = DATE(1); END IF;
		IF Vppyrnumcreditortc IS NULL OR Vppyrnumcreditortc = '' THEN LET Vppyrnumcreditortc = ''; END IF;
		IF Vppyrestadocredito IS NULL OR Vppyrestadocredito = '' THEN LET Vppyrestadocredito = ''; END IF;
		IF Vppyrtipoultimomov IS NULL OR Vppyrtipoultimomov = '' THEN LET Vppyrtipoultimomov = ''; END IF;
		IF Vppyrfechaultmov IS NULL OR Vppyrfechaultmov = '' THEN LET Vppyrfechaultmov = DATE(1); END IF;
		
		LET cNumCredito = Vnumcreditortc;
		LET iTotalCuentasProcesadas = iTotalCuentasProcesadas + 1;
	
		SELECT ppyr.numcreditortc,ppyr.estadocredito,ppyr.tipoultimomov,ppyr.fechaultmov
		INTO Vppyrnumcreditortc,Vppyrestadocredito,Vppyrtipoultimomov,Vppyrfechaultmov
		FROM bdicred:sd_pagosydisposicionescrd_carteras ppyr 
		WHERE ppyr.numcreditortc = Vnumcreditortc;

		IF Vppyrnumcreditortc IS NULL OR Vppyrnumcreditortc = '' THEN LET Vppyrnumcreditortc = '-1';  END IF;
		IF Vppyrestadocredito IS NULL OR Vppyrestadocredito = '' THEN LET Vppyrestadocredito = '';    END IF;
		IF Vppyrtipoultimomov IS NULL OR Vppyrtipoultimomov = '' THEN LET Vppyrtipoultimomov = '';    END IF;
		IF Vppyrfechaultmov   IS NULL OR Vppyrfechaultmov = ''   THEN LET Vppyrfechaultmov = DATE(1); END IF;
		
		-------------------------BUSCAR ULTIMO MOVIMIENTO DEL CLIENTE-------------------------
		IF (Vprod = '6300' OR Vprod = '7600' OR Vprod = '7700') THEN
	/*		if exists(select num_credito 
				from bdicred:sd_movhiscrd 
				where empresa = '001'
				and num_credito = Vnumcreditortc
				and codigo_ref = 1 and codigo_fun   in ('020','021','022','023','024','025','027','028')
				and fecha_mov = Vfechaultmov 
				AND num_producto in ('6300','7600','7700'))then */
			IF dFechaUltPago >= dFechaInicio AND dFechaUltPago <= Vfechacorte THEN
				LET Vtipoultimomov = 'P'; -- Pago
			ELSE
				IF Vfechareestructura >= dFechaInicio AND Vfechareestructura <= Vfechacorte THEN
		/*		elif 
				exists(select num_credito 
					from bdicred:sd_movhiscrd 
					where empresa = '001'
					and num_credito = Vnumcreditortc
					and codigo_ref = 3 and codigo_fun  = '001'
					and fecha_mov = (select max(fecha_mov)from bdicred:sd_movhiscrd where codigo_ref = 3 and codigo_fun  = '001' and num_credito = Vnumcreditortc)
					AND num_producto in ('6300','7600','7700')) then*/
			
					LET Vtipoultimomov = 'A'; -- Apertura
					LET Vfechaultmov = Vfechareestructura;
		/*		elif
				exists(select num_credito 
					from bdicred:sd_movhiscrd 
					where empresa = '001'
					and num_credito = Vnumcreditortc
					and codigo_ref = 66 and codigo_fun  ='002'
					and fecha_mov = (select max(fecha_mov)from bdicred:sd_movhiscrd where codigo_ref = 66 and codigo_fun  ='002' and num_credito = Vnumcreditortc)
					AND num_producto in ('6300','7600','7700')) then
					
					select LIMIT 1 fecha_mov into  Vfechaultmov
					from bdicred:sd_movhiscrd 
					where empresa = '001'	and num_credito = Vnumcreditortc	and codigo_ref = 66 and codigo_fun  ='002'
					and fecha_mov = (select max(fecha_mov)from bdicred:sd_movhiscrd where codigo_ref = 66 and codigo_fun  ='002' and num_credito = Vnumcreditortc)
					AND num_producto in ('6300','7600','7700');

					LET Vtipoultimomov = 'D'; -- DisposiciÃ³n
					LET Vfechaultmov = Vfechaultmov;*/

--					LET Vtipoultimomov = ''; -- Sin movimiento
--					LET Vfechaultmov = '';*/
				END IF;
			END IF;
		END IF;			

		IF (Vprod = '6011') THEN
		--obtienes el interes vencido cargado a la reestruc   --intereses moratorios
		/*
			select limit 1 NVL(monto,0) into vmontor1
			FROM bdicred:sd_movhis 
			where empresa = '001' and num_credito = Vnumcreditortc 
			and codigo_fun = '338' and codigo_ref = 21 and reversado = 'N'
			and fecha_mov = (select max(fecha_mov) from bdicred:sd_movhis  where num_credito = Vnumcreditortc and codigo_fun = '338' and codigo_ref = 21 and reversado = 'N');
		
			select limit 1 NVL(monto,0) into vmontor2
			FROM bdicred:sd_movhis 
			where empresa = '001' and num_credito = Vnumcreditortc 
			and codigo_fun = '338' and codigo_ref = 22 and reversado = 'N'
			and fecha_mov = (select max(fecha_mov) from bdicred:sd_movhis  where num_credito = Vnumcreditortc and codigo_fun = '338' and codigo_ref = 22 and reversado = 'N'); 
			*/
			--let Vinteres = vmontor1 + vmontor2;
			--if   Vinteres is null then let Vinteres = 0; end if;
			IF dFechaUltPago >= dFechaInicio AND dFechaUltPago <= Vfechacorte THEN
	/*		if exists(select num_credito 
				from bdicred:sd_movhiscrd 
				where empresa = '001'
				and num_credito = Vnumcreditortc
				and codigo_fun in ('225','222')	and codigo_ref = 1
				and fecha_mov = Vfechaultmov --(select max(fecha_mov)from bdicred:sd_movhiscrd )
				AND num_producto = '6011') then*/
				LET Vtipoultimomov = 'P'; -- Pago
			ELSE
				IF vfecha_apertura >= dFechaInicio AND vfecha_apertura <= pfechacorte THEN
	/*		elif
			exists(select num_credito 
				from bdicred:sd_movhiscrd 
				where empresa = '001'
				and num_credito = Vnumcreditortc
				and codigo_ref in(1,2) and codigo_fun  in ('001','002')
				and fecha_mov = (select max(fecha_mov)from bdicred:sd_movhiscrd where codigo_ref in(1,2) and codigo_fun  in ('001','002') and num_credito = Vnumcreditortc)
				AND num_producto = '6011') then*/
		
					LET Vtipoultimomov = 'A'; -- Apertura
	--			LET Vfechaultmov = Vfechareestructura;
/*			elif
			exists(select num_credito 
				from bdicred:sd_movhiscrd 
				where empresa = '001'
				and num_credito = Vnumcreditortc
				and codigo_ref = 4 and codigo_fun  ='001'
				and fecha_mov = (select max(fecha_mov)from bdicred:sd_movhiscrd where codigo_ref = 4 and codigo_fun  ='001' and num_credito = Vnumcreditortc) 
				AND num_producto = '6011') then
				
				select LIMIT 1 fecha_mov INTO Vfechaultmov
				from bdicred:sd_movhiscrd 
				where empresa = '001'	and num_credito = Vnumcreditortc	and codigo_ref = 4 and codigo_fun  ='001'
				and fecha_mov = (select max(fecha_mov)from bdicred:sd_movhiscrd where codigo_ref = 4 and codigo_fun  ='001' and num_credito = Vnumcreditortc) 
				AND num_producto = '6011';
				
				LET Vtipoultimomov = 'L'; -- LiquidaciÃ³n TC por Reestructura
				LET Vfechaultmov = Vfechaultmov;
				LET Vtipoultimomov = ''; -- Sin movimiento
				LET Vfechaultmov = '';*/
				END IF;
			END IF;
		END IF;
		
		SELECT NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0) 
			,NVL(sdo_capital,0)
			,NVL(monto_vencido,0)
			,NVL(cap_tras_no_venci,0)
			,NVL(mto_venc_trasp,0)
			,NVL(sdo_intereses,0) + NVL(sdo_no_exig,0)
			,NVL(int_tra_no_exig,0)
		INTO Vsaldovencido
			,VsaldoCapital
			,VsaldoTrasp
			,VvenciNoExig
			,VvenciExig
			,VintVigente
			,VintVencido
		FROM sd_maesdoscrd 
		WHERE empresa = '001'
		  AND num_credito = Vnumcreditortc;
		
		SELECT NVL(capital_mto_cuota,0)
		INTO Vabonobase
		FROM bdicred:sd_amortiza_creditocrd 
		WHERE num_credito = Vnumcreditortc
		  AND fecha_cuota = (SELECT MAX(fecha_cuota) FROM bdicred:sd_amortiza_creditocrd WHERE num_credito = Vnumcreditortc);
		
		IF (Vabonobase = '') THEN 
			LET Vabonobase = 0; 
		END IF;
		
		SELECT NVL(SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),0),
				   NVL(SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),0)
		INTO Vinteresvencido,
			  vinteres_moratorio
		FROM "informix".sd_amortiza_creditocrd
		WHERE empresa     = '001'
			AND num_credito = Vnumcreditortc
			AND capital_status IN ('2','7','6')
			AND fecha_cuota = (SELECT MAX(fecha_cuota) FROM bdicred:sd_amortiza_creditocrd WHERE num_credito = Vnumcreditortc);

		IF Vppyrnumcreditortc = '-1' THEN
			INSERT INTO sd_pagosydisposicionescrd_carteras  
				(num_producto, numcreditortc, numcreditotdc, numcuentartc, numtarjetatdc, numcte, numsucursal, numciudad,
				fechareestructura, saldoactual, interes, saldovencido, interesvencido, interes_moratorio,
				abonobase, abonosvencidos, estadocredito, plazortc, tasainteres,
				fechalimitedepago, fechaultmov, tipoultimomov, fechacorte,
				sdo_cap_vigente, sdo_cap_trasp_vigente, sdo_cap_noexig_vencido, sdo_cap_exig_vencido, sdo_int_vigente, sdo_int_vencido)
			VALUES
				(Vprod,Vnumcreditortc, Vnumcreditotdc, Vnumcuentartc, Vnumtarjetatdc, Vnumcte, Vnumsucursal, Vnumciudad,
				Vfechareestructura, Vsaldoactual, Vinteres, Vsaldovencido, Vinteresvencido, vinteres_moratorio,
				Vabonobase, Vabonosvencidos, Vestadocredito, Vplazortc, Vtasainteres,
				Vfechalimitedepago, Vfechaultmov, Vtipoultimomov, Vfechacorte,
				VsaldoCapital, VsaldoTrasp, VvenciNoExig, VvenciExig, VintVigente, VintVencido);
			
			LET iCuentasInsertadas = iCuentasInsertadas + 1;
		ELSE
			UPDATE bdicred:sd_pagosydisposicionescrd_carteras 
				SET
					numcreditotdc	= Vnumcreditotdc,
					numcuentartc	= Vnumcuentartc,
					numtarjetatdc	= Vnumtarjetatdc ,
					numcte			=	Vnumcte ,
				--	numsucursal		=	Vnumsucursal,
					numciudad		= Vnumciudad,
					fechareestructura	= Vfechareestructura , 
					saldoactual		= Vsaldoactual  ,
					interes			= Vinteres   ,
					saldovencido	= Vsaldovencido ,
					interesvencido	= Vinteresvencido,
					interes_moratorio	= vinteres_moratorio,
					abonobase		= Vabonobase ,
					abonosvencidos	= Vabonosvencidos ,
					estadocredito	= Vestadocredito ,
					plazortc		= Vplazortc ,
					tasainteres		= Vtasainteres ,
					fechalimitedepago	= Vfechalimitedepago,
					fechaultmov		= Vfechaultmov,
					tipoultimomov	= Vtipoultimomov, 
					fechacorte		= Vfechacorte, 
					sdo_cap_vigente	= VsaldoCapital, 
					sdo_cap_trasp_vigente	= VsaldoTrasp,
					 sdo_cap_noexig_vencido	= VvenciNoExig, 
					 sdo_cap_exig_vencido	= VvenciExig, 
					 sdo_int_vigente		= VintVigente, 
					 sdo_int_vencido		= VintVencido
				WHERE numcreditortc = Vnumcreditortc;
				LET iCuentasActualizadas	= iCuentasActualizadas + 1;
		END IF;
		
		LET	Vnumcreditortc		= '';	LET Vnumcreditotdc		= '';	LET Vnumcuentartc		= '';
		LET	Vnumtarjetatdc		= '';	LET	Vnumcte           	= '';	LET	Vnumsucursal		= 0;
		LET	Vnumciudad	        = '';	LET Vfechareestructura	= DATE(1);	LET Vsaldoactual	= 0;	LET Vinteres        = 0;
		LET Vsaldovencido       = 0;	LET Vinteresvencido     = 0;	LET Vabonobase          = 0;	LET Vabonosvencidos	= 0;
		LET vinteres_moratorio	= 0;	LET Vestadocredito      = 0;	LET Vplazortc      		= 0;	LET Vtasainteres   	= 0;
		LET Vfechalimitedepago  = DATE(1);	LET	Vfechaultmov    = DATE(1);	LET Vtipoultimomov  = '';
		LET vmontor1			= 0;	LET vmontor2			= 0;
		
		LET VsaldoCapital		= 0;	LET VsaldoTrasp			= 0;	LET VvenciNoExig		= 0;	LET VvenciExig		= 0;
		LET VintVigente			= 0;	LET VintVencido			= 0;	LET dFechaInicio		= DATE(1);

		LET Vppyrnumcreditortc	= '';	LET Vppyrestadocredito	= ''; LET vfecha_apertura		= DATE(1);
		LET Vppyrtipoultimomov	= '';	LET Vppyrfechaultmov	= DATE(1);	LET dfechaultpago	= DATE(1);

	END FOREACH

    let cMensajeBitacora = 'TOTAL Cuentas procesadas : ' || iTotalCuentasProcesadas;
--    CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, trim(cMensajeBitacora), '02');
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensajeBitacora, '02') returning cCod_ret2;
    let cMensajeBitacora = 'Cuentas insertadas: ' || iCuentasInsertadas;
    let cMensajeBitacora = trim(cMensajeBitacora) ||'    Cuentas actualizadas: ' || iCuentasActualizadas;
--    CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, trim(cMensajeBitacora), '02');
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensajeBitacora, '02') returning cCod_ret2;

--	if (day(pfechacorte) in(3,18,21)) then --CREAR  ARCHIVO
	if (day(pfechacorte) in (3,18)) then --CREAR  ARCHIVO
		 
             LET cSql = '';
             --LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/Pagos1.unl''' || ' DELIMITER ' || '''|'''  ||
			 LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/cart_reest_prest_temp.unl''' || ' DELIMITER ' || '''|'''  || 
--                ' select * from sd_pagosydisposicionescrd_carteras;'||
				' select num_producto, numcreditortc, numcreditotdc, numcuentartc, numtarjetatdc, numcte, numsucursal, numciudad, fechareestructura, '||
				' saldoactual, interes, saldovencido, interesvencido, interes_moratorio, abonobase, abonosvencidos, estadocredito, plazortc, tasainteres, '||
				' fechalimitedepago, fechaultmov, tipoultimomov, '|| ''''|| Vfechacorte || ''''||', sdo_cap_vigente, sdo_cap_trasp_vigente, '||
				' sdo_cap_noexig_vencido, sdo_cap_exig_vencido, sdo_int_vigente, sdo_int_vencido '||
                ' from sd_pagosydisposicionescrd_carteras where num_producto = "6011";'||
                ' " > /resplogifx/archivoscartera/Pagosydisposiciones2crdClon.sql';
              SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/Pagosydisposiciones2crdClon.sql';
              SYSTEM cSql;

              LET cSql = '';
              --LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/Pagos1.unl > /resplogifx/archivoscartera/" || trim(cNombreArchivo);
			  LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/cart_reest_prest_temp.unl > /resplogifx/archivoscartera/" || trim(cNombreArchivo);
              SYSTEM cSql;

              let cSql = '';
              --LET cSql = "rm /resplogifx/archivoscartera/Pagos1.unl /resplogifx/archivoscartera/Pagosydisposiciones2crdClon.sql";
			  LET cSql = "rm /resplogifx/archivoscartera/cart_reest_prest_temp.unl /resplogifx/archivoscartera/Pagosydisposiciones2crdClon.sql";
              SYSTEM cSql;
	
		 -- para Generar el archvio de Cifras.
             LET cSql = '';
             LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/DirectorioCifrasControlRegistros.unl''' || ' DELIMITER ' || '''|'''  ||
--                ' SELECT count(*)::integer, sum(saldoactual), sum(saldovencido), fechacorte  FROM bdicred:sd_pagosydisposicionescrd_carteras group by fechacorte ' ||
                ' SELECT count(*)::integer, sum(saldoactual), sum(saldovencido), '|| ''''|| Vfechacorte || ''''||'  FROM bdicred:sd_pagosydisposicionescrd_carteras WHERE num_producto = "6011" ' ||
                ' " > /resplogifx/archivoscartera/DirectorioCifrasControlQuerysClon.sql';
              SYSTEM cSql;

	elif (day(pfechacorte) in (21)) then --CREAR  ARCHIVO
             LET cSql = '';
             --LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/Pagos1.unl''' || ' DELIMITER ' || '''|'''  ||
			 LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/cart_reest_prest_temp.unl''' || ' DELIMITER ' || '''|'''  ||
--                ' select * from sd_pagosydisposicionescrd_carteras;'||
				' select num_producto, numcreditortc, numcreditotdc, numcuentartc, numtarjetatdc, numcte, numsucursal, numciudad, fechareestructura, '||
				' saldoactual, interes, saldovencido, interesvencido, interes_moratorio, abonobase, abonosvencidos, estadocredito, plazortc, tasainteres, '||
				' fechalimitedepago, fechaultmov, tipoultimomov, '|| ''''|| Vfechacorte || ''''||', sdo_cap_vigente, sdo_cap_trasp_vigente, '||
				' sdo_cap_noexig_vencido, sdo_cap_exig_vencido, sdo_int_vigente, sdo_int_vencido '||
                ' from sd_pagosydisposicionescrd_carteras where num_producto in ("6300","7600","7700");'||
                ' " > /resplogifx/archivoscartera/Pagosydisposiciones2crdClon.sql';
              SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/Pagosydisposiciones2crdClon.sql';
              SYSTEM cSql;

              LET cSql = '';
              --LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/Pagos1.unl > /resplogifx/archivoscartera/" || trim(cNombreArchivo);
			  LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/cart_reest_prest_temp.unl > /resplogifx/archivoscartera/" || trim(cNombreArchivo);
              SYSTEM cSql;

              let cSql = '';
              --LET cSql = "rm /resplogifx/archivoscartera/Pagos1.unl /resplogifx/archivoscartera/Pagosydisposiciones2crdClon.sql";
			  LET cSql = "rm /resplogifx/archivoscartera/cart_reest_prest_temp.unl /resplogifx/archivoscartera/Pagosydisposiciones2crdClon.sql";
              SYSTEM cSql;
	
	
		 -- para Generar el archvio de Cifras.
             LET cSql = '';
             LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/DirectorioCifrasControlRegistros.unl''' || ' DELIMITER ' || '''|'''  ||
--                ' SELECT count(*)::integer, sum(saldoactual), sum(saldovencido), fechacorte  FROM bdicred:sd_pagosydisposicionescrd_carteras group by fechacorte ' ||
                ' SELECT count(*)::integer, sum(saldoactual), sum(saldovencido), '|| ''''|| Vfechacorte || ''''||'  FROM bdicred:sd_pagosydisposicionescrd_carteras WHERE num_producto in ("6300","7600","7700")' ||
                ' " > /resplogifx/archivoscartera/DirectorioCifrasControlQuerysClon.sql';
              SYSTEM cSql;
	end if;

	if (day(pfechacorte) in(3,18,21)) then
		LET cSql = '';
		LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/DirectorioCifrasControlQuerysClon.sql';
		SYSTEM cSql;

		LET cSql = '';
		LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/DirectorioCifrasControlRegistros.unl > /resplogifx/archivoscartera/" || trim(cNombreArchivo2);
		SYSTEM cSql;

		LET cSql = '';
		LET cSql = "rm /resplogifx/archivoscartera/DirectorioCifrasControlRegistros.unl /resplogifx/archivoscartera/DirectorioCifrasControlQuerysClon.sql";
		SYSTEM cSql;
				  
		LET cSql = '';
		LET cSql = "cut -f 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 -d '|' /resplogifx/archivoscartera/" || trim(cNombreArchivo) || " > /resplogifx/archivoscartera/" || trim(cNombreArchivoNvo);
		SYSTEM cSql;
		
        LET cSql = '';
        LET cSql = "gzip /resplogifx/archivoscartera/" || trim(cNombreArchivo);
        SYSTEM cSql;

        LET cSql = '';
        LET cSql = "gzip /resplogifx/archivoscartera/" || trim(cNombreArchivoNvo);
        SYSTEM cSql;
	end if;
		
--	CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '03');
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '03') returning cCod_ret2;

	let cMensaje = trim(cMensaje) || ' TOTAL Cuentas procesadas: '|| iTotalCuentasProcesadas;
	
	RETURN cCod_ret,cMensaje;

	
END;
END PROCEDURE;