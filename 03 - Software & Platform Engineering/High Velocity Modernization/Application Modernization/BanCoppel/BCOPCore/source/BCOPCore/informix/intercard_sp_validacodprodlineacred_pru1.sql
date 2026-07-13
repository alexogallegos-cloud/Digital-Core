CREATE PROCEDURE "informix".sp_validacodprodlineacred_pru1 (chempresa char (3))
returning char (5),char(50);

DEFINE iSqlErr          		INTEGER;
DEFINE iIsamErr         		INTEGER;
DEFINE cInfoErr					CHAR(100);
DEFINE cCodret          		CHAR(5);
DEFINE cMensRet         		CHAR(50);
DEFINE cEmpresa          		CHAR(3);
DEFINE vnum_tarjeta				CHAR (16);
DEFINE vcodproductotarjeta    	CHAR(3);
DEFINE vmaesdos_otorgado		DECIMAL(18,2);
DEFINE vsegcodproductotarjeta   CHAR(3);
DEFINE vseglimite_min           DECIMAL(19,4);
DEFINE vseglimite_max           DECIMAL(19,4);
DEFINE vmarca                   CHAR(2);
DEFINE vbin                     CHAR(6);
DEFINE vsubbin                  CHAR(2); --Nueva variable
DEFINE vsegbin                  CHAR(6);
DEFINE icommit					INTEGER;
DEFINE vFechaCarga              DATE;
DEFINE vFechaCargaVal           CHAR(25);

  --Set debug file to "/informix/LDBZ/sp_validacodprodlineacred.out";
  --trace on;
 
 -- Base de Datos: intercard
	-- Fecha de modificacion: 14 de Marzo de 2023
	-- Autor: Luis Daniel Bautista Zamora 
	-- Comentario: Se agregan validaciones para evitar extraer registros dobles en consulta con lÃ­mites de crÃ©ditos iguales debido a nuevo producto infinite.
	-- Se implementa uso de tabla temporal para filtrar informacion y disminuir los altos costos de ejecucion.

LET cInfoErr 				= '';
LET cCodret 				= '00000';
LET cMensRet 				= 'Ejecucion sp_validacodprodlineacred exitosa.';
LET cEmpresa 				= chempresa;
LET vnum_tarjeta			= '';
LET vcodproductotarjeta    	= '';
LET vmaesdos_otorgado 		= 0;
LET vsegcodproductotarjeta  ='';
LET vseglimite_min          = 0;
LET vseglimite_max          = 0;
LET vmarca                  = '';
LET vbin                    = '';
LET vsubbin                 = '';  --Se incializa variable
LET vsegbin                 = '';
LET icommit 				= 0;
LET vFechaCarga             = CURRENT;


	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensRet = 'Error en el proceso, validar.';
					--Set debug file to "/RESPALDOSNEW/sp_validacodprodlineacred_exception.out";
					--trace on;
				RETURN cCodret,cMensRet;
			END IF;
		END EXCEPTION;

		
		DROP TABLE IF EXISTS tmp_tarjcodproducto;
		DROP TABLE IF EXISTS tmp_tarjeta;
/*-----------------------------------------------------------------------------------------------------------------
			PROCESO DE DESCARGA DE REGISTROS CON AUMENTO EN LINEA DE CREDITO DEL MES ANTERIOR (T-1):
-----------------------------------------------------------------------------------------------------------------*/

		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT   MAX(fecha_ejecucion)    
			INTO vFechaCarga
		FROM intercard:bitacoraprocesosejec
		WHERE idproceso='VALIDACODPRODTAR'
		AND estatus='TERMINADO';
	
		
		LET  vFechaCargaVal =  YEAR(vFechaCarga)||'-'||LPAD(MONTH(vFechaCarga),2, '0')||'-'||LPAD(DAY(vFechaCarga),2,'0')|| ' ' ||'00:00:00.00000';
		
		/*---------------------------------------------------------------------
		CARGA DE LA INFORMACION DE LA TABLA tarjeta a tmp_tarjeta
		----------------------------------------------------------------------*/
		SELECT numtarjeta,codstatustarjeta,codproductotarjeta,fechaasignacion,codstatusasignada FROM tarjeta
		WHERE  fechaasignacion >= vFechaCargaVal
		AND codstatustarjeta in ('ACT','INA')
		AND codstatusasignada = 'SIA'
		AND fechaexp >= vFechaCargaVal
		
		--AND substr(numtarjeta,1,6)= '426807'
		INTO TEMP tmp_tarjeta WITH NO LOG;
-------------------------------------------------------------------------------------------------------
		SELECT  
		t.numtarjeta,t.codproductotarjeta,sdm.num_credito,sdm.monto_otorgado,bi.bin--,bi.marca RQI 13 722
	    FROM tmp_tarjeta t
		INNER JOIN bdicred:sd_tarjeta sdt
		ON t.numtarjeta=sdt.num_tarjeta
		INNER JOIN bdicred:sd_maesdos sdm
		ON sdt.num_credito=sdm.num_credito
        INNER JOIN intercard:bines bi
		ON substr(t.numtarjeta,1,6)=bi.bin
		WHERE sdt.empresa='001'
		INTO TEMP tmp_tarjcodproducto with no log;


--{+ INDEX (intercard:"informix".tarjeta idx_tarjeta1) } RQI 13 722
		--{+ INDEX (intercard:"informix".tarjeta idx_tbl_tjta_codstatustarjeta) }
		--{+ INDEX (intercard:"informix".tarjeta idx_tbl_tjta_codstatusasignada) }	
		
/*-----------------------------------------------------------------------------------------------------------------
			PROCESO DE VALIDACION DE LINEAS DE CREDITO:
-----------------------------------------------------------------------------------------------------------------*/
		FOREACH WITH HOLD
			SELECT numtarjeta,codproductotarjeta,monto_otorgado/*,marca*/,bin,SUBSTR (numtarjeta,7,2)
				INTO vnum_tarjeta,vcodproductotarjeta,vmaesdos_otorgado/*,vmarca*/,vbin,vsubbin
			FROM tmp_tarjcodproducto
			
			SELECT 
			--{+AVOID_FULL (intercard:binproducto)}  RQI 13 722
			--{+ INDEX (intercard:"informix".segmentoproducto idx_sgmtoprod) } RQI 13 722
			DISTINCT sp.codproductotarjeta,limite_min,limite_max,bi.bin
				INTO vsegcodproductotarjeta,vseglimite_min,vseglimite_max,vsegbin
			FROM intercard:segmentoproducto sp
            INNER JOIN intercard:binproducto bp
            ON sp.codproductotarjeta=bp.codproductotarjeta
            INNER JOIN intercard:bines bi 
            ON bp.bin=bi.bin
            INNER JOIN tmp_tarjcodproducto tmp
            ON  SUBSTR (vnum_tarjeta,7,2)=(select pi.producto 
                from intercard:tipotarjeta tt
                join intercard:productoimagen pi
                on tt.clave = pi.clave
                where tt.bin = '426807'
                and pi.producto= vsubbin)
			WHERE tipo_producto='C'
			--AND sp.codproductotarjeta=001
			--AND bi.marca='VS'
			AND bi.bin= '426807'
            and SUBSTR (vnum_tarjeta,7,2)=bp.producto
			AND limite_min <= vmaesdos_otorgado
			AND limite_max >= vmaesdos_otorgado;
			--GROUP BY 1,2,3;
			---------------------------------------------------------------------------------------------------------------------------
			
			
			----------------------------------------------------------------------------------------------------------------------------
			BEGIN WORK;
				if icommit = 1000
					then
						COMMIT WORK;
						LET icommit = 0;
						CONTINUE FOREACH;
					else
				end if;
				
			IF vcodproductotarjeta!=vsegcodproductotarjeta and vbin=vsegbin THEN
						UPDATE intercard:tarjeta set codproductotarjeta=vsegcodproductotarjeta
						WHERE numtarjeta=vnum_tarjeta;
	    					LET icommit = icommit+1;
			END IF
			
				
			/*IF vmarca='VS' THEN 
					IF vcodproductotarjeta!=vsegcodproductotarjeta THEN
						UPDATE intercard:tarjeta set codproductotarjeta=vsegcodproductotarjeta
						WHERE numtarjeta=vnum_tarjeta;
					END IF
			ELSE IF vmarca='MC' THEN
					IF vcodproductotarjeta!=vsegcodproductotarjeta THEN
						UPDATE intercard:tarjeta set codproductotarjeta=vsegcodproductotarjeta
						WHERE numtarjeta=vnum_tarjeta;
					END IF
			END IF;*/
				
			COMMIT WORK;				
			
			
					
		END FOREACH;
		
		BEGIN;
		INSERT INTO intercard:bitacoraprocesosejec (idproceso,fecha_ejecucion,fechahora_ultejecucion,estatus,descripcion,usuario)
			VALUES ('VALIDACODPRODTAR',CURRENT,CURRENT,'TERMINADO','Proceso que valida codigo de producto de las tarjetas asignadas','informix');
		COMMIT;

		

		RETURN cCodret,cMensRet;

    END;
END PROCEDURE
--'BD: intercard'
--'AUTOR: Edgar Ivan Cisneros Yescas'
--'Proyecto: RQI 10 1017 Actualizacion de producto INTERCARD'
--'Fecha: 2018/05/04'
--''
--'AUTOR: Marcos Gerardo Ayala Ponce'
--'Proyecto: RQI 13 722 - OptimizaciÃÂ³n sp_validacodprodlineacred
--'Fecha: 2020/07/14'
--'BD: intercard - JOB 630'
;

CREATE PROCEDURE "informix".sp_camp_registrar_notificaciones_pru1( pTipoTransacc VARCHAR(2), pTipoEnvio CHAR(3) )
    RETURNING VARCHAR(5) as rCODIGO_RETORNO, VARCHAR(80) as rMENSAJE_RESPUESTA;

    DEFINE SQL_ERR   INTEGER;
    DEFINE ISAM_ERR   INTEGER;
    DEFINE ERROR_INFO  CHAR(80);
    
    DEFINE vCodigoRetorno VARCHAR(5);
    DEFINE vMensajeRespuesta VARCHAR(80);
    
    DEFINE vNumCliente VARCHAR(20);
    DEFINE vNumTarjeta VARCHAR(16);
    DEFINE vTipoTarjetaPin_ant CHAR(1);
    DEFINE vTipoChipPinOffline_ant CHAR(1);
    DEFINE vCodEstatusTarj_ant VARCHAR(3);    
    
    DEFINE vCodEstatusTarj_actual VARCHAR(3);
    DEFINE vTipoTarjetaPin_actual CHAR(1);
    DEFINE vTipoChipPinOffline_actual CHAR(1);
    
    
    DEFINE TIPO_TARJETA_A CHAR(1);
    DEFINE TIPO_TARJETA_B CHAR(1);
    DEFINE TIPO_TARJETA_C CHAR(1);
    DEFINE vCVVDinamico CHAR(1);
    DEFINE vCVVDinam_esActivo SMALLINT;
    
    ----Variables para datos actuales

    DEFINE vNumEnvioSMS SMALLINT;
    DEFINE vNumEnvioCorreo SMALLINT;
    DEFINE PROCESO_INICIAL CHAR(1);
    DEFINE PROCESO_TERMINADO CHAR(1);
    DEFINE PROCESO_NOTIFICADO CHAR(1);
    DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(30);
    
    DEFINE NOTIF_SMS CHAR(3);
    DEFINE NOTIF_CORREO_ELEC CHAR(3);
    DEFINE INCREMENTO_CONT_SMS SMALLINT;
    DEFINE INCREMENTO_CONT_CORREO SMALLINT;
    DEFINE vID_Plantilla VARCHAR(12);
    DEFINE vEstatusProceso CHAR(1);
    DEFINE vFechaProceso DATETIME YEAR TO FRACTION(5);
    DEFINE vNumRegPendientes INTEGER;
    DEFINE vTipoTransacc VARCHAR(3);
    DEFINE MOVS_TARJ_PRESENTE VARCHAR(2);
    DEFINE MOVS_TARJ_NO_PRESENTE VARCHAR(2);
    DEFINE TIPO_TRANSACC_T_PRESENTE VARCHAR(3);
    DEFINE TIPO_TRANSACC_TN_PRESENTE VARCHAR(3);
    
    ------Variables usadas como parametros para el registro de mensajes.
    DEFINE vNumTelefono CHAR(13);    
    DEFINE vTerminacionTarjeta CHAR(4);
    DEFINE vCorreoElect CHAR(100);
    DEFINE vTipoCorreo SMALLINT;
    DEFINE vEstatusCorreo CHAR(1);
    
    
    ---proceso de notificacion y conteo de sms o correo electronico
    DEFINE vFechaSistema  DATETIME YEAR TO FRACTION(5);
    DEFINE vContadorTransacciones SMALLINT;
    DEFINE vsFlagEnTransaccion 	VARCHAR(1);
    DEFINE viContadorRegistros 	INTEGER;
    DEFINE vConteo INTEGER;
    DEFINE vContrato VARCHAR(10);
    
    ---Nombre del cliente
    DEFINE vPrimerNombre VARCHAR(26);
    DEFINE vSegundoNombre VARCHAR(26);
    DEFINE vNombreAsignado VARCHAR(26);
    DEFINE vTotalEnvios INTEGER;
    DEFINE vMaxNotificaciones SMALLINT;
    
    LET SQL_ERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';    
    LET NOTIF_SMS = 'SMS';
    LET NOTIF_CORREO_ELEC = 'CEC';
    LET INCREMENTO_CONT_SMS = 0;
    LET INCREMENTO_CONT_CORREO = 0;
    LET vNumRegPendientes = 0;
    
    LET vTipoTarjetaPin_ant = '';
    LET vTipoChipPinOffline_ant = '';
    LET vCodEstatusTarj_ant = '';
    
    LET TIPO_TARJETA_A = 'A';
    LET TIPO_TARJETA_B = 'B';
    LET TIPO_TARJETA_C = 'C';
    LET vFechaProceso = '';
    
    LET vNumCliente = '';
    LET vCodigoRetorno  = '00000';
    LET vMensajeRespuesta = 'Proceso ejecutado exitosamente.';
    LET vCodEstatusTarj_actual = '';
    LET vNumTarjeta = '';
    
    LET vNumEnvioSMS = 0;
    LET vNumEnvioCorreo = 0;
    LET PROCESO_TERMINADO = 'T';
    LET PROCESO_NOTIFICADO = 'N';
    LET PROCESO_INICIAL = 'I';
    LET vCVVDinamico = '';
    LET vCVVDinam_esActivo = 0;
    LET vID_Plantilla = NULL;
    LET vEstatusProceso = '';
    LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';

    ------Variables usadas como parametros para el registro de mensajes.
    LET vNumTelefono = '0';    
    LET vTerminacionTarjeta = '0000';
    LET vCorreoElect = '0';
    LET vEstatusCorreo = '';
    LET vTipoCorreo = 0;

    LET vTipoTransacc = '';
    LET MOVS_TARJ_PRESENTE = '01';
    LET MOVS_TARJ_NO_PRESENTE = '02';
    LET TIPO_TRANSACC_T_PRESENTE = 'TP';
    LET TIPO_TRANSACC_TN_PRESENTE = 'TNP';
    
    LET vFechaSistema  = sysdate;  
    LET vContadorTransacciones = 1000;    
    LET vsFlagEnTransaccion = 'F';
    LET viContadorRegistros = 0;
    LET vConteo = 0;    
    LET vContrato = '';
     
    LET vPrimerNombre = '';
    LET vSegundoNombre = '';
    LET vNombreAsignado = '';
    LET vTotalEnvios = 0;
    LET vMaxNotificaciones = 0;
    
    BEGIN
    
        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO        
            SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "excep_sp_camp_reg_notif.err.out" WITH APPEND;
            TRACE ON;
            
            IF ( SQL_ERR <> 0 ) THEN
                LET vCodigoRetorno = SQL_ERR;
                LET vMensajeRespuesta = ISAM_ERR|| ERROR_INFO;
                RETURN vCodigoRetorno, vMensajeRespuesta;
            END IF;
        END EXCEPTION;
        
        --SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS||"debug_sp_camp_registrar_notifi.out" WITH APPEND;
        --TRACE ON;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;        
        
        DROP TABLE IF EXISTS tmp_reg_pendientes;
        
        SELECT COUNT(*) as reg_pendientes
            FROM intercard:"informix".tbl_campania_notif_tarjeta_ctes
                WHERE estatus_proceso IN ( PROCESO_INICIAL, PROCESO_NOTIFICADO )
            GROUP BY estatus_proceso 
                INTO TEMP tmp_reg_pendientes WITH NO LOG;
        
        SELECT SUM(reg_pendientes) as reg_pendientes
            INTO vNumRegPendientes
        FROM tmp_reg_pendientes;

        IF ( vNumRegPendientes = 0 ) THEN
            LET vCodigoRetorno = '00000';
            LET vMensajeRespuesta = 'No hay informacion pendiente de notificar a nuevos clientes.';
            RETURN vCodigoRetorno, vMensajeRespuesta;
        END IF

        IF ( pTipoTransacc = MOVS_TARJ_PRESENTE ) THEN
            
            LET vTipoTransacc = TIPO_TRANSACC_T_PRESENTE;
            
        ELIF ( pTipoTransacc = MOVS_TARJ_NO_PRESENTE ) THEN
            
            LET vTipoTransacc = TIPO_TRANSACC_TN_PRESENTE;
            
        END IF

        FOREACH cur_buscar_ctes WITH HOLD FOR            
                
            ---Paso 1. 
            ---Iterar todos los registros previamente cargados en el sp_camp_obtener_movs_tnp
            ---y los clientes que todavía no han actualizado su tarjeta de procesos anteriores.
            SELECT DISTINCT num_cliente, numtarjeta, tipo_tarjeta_carga, pin_offline_carga, codestatus_tarjeta_carga
                INTO vNumCliente, vNumTarjeta, vTipoTarjetaPin_ant, vTipoChipPinOffline_ant, vCodEstatusTarj_ant
            FROM intercard:tbl_campania_notif_tarjeta_ctes
                WHERE estatus_proceso IN (PROCESO_INICIAL, PROCESO_NOTIFICADO)
                    AND tipo_transacc_carga = vTipoTransacc
                    
            ---Paso 2.
            ---Buscar el registro que coincida con la iteracion correspondiente
            ---para obtener los datos actuales y comparar si han sufrido algun cambio.
            SELECT DISTINCT a.codstatustarjeta, b.card_type, b.pin_offline
                INTO vCodEstatusTarj_actual, vTipoTarjetaPin_actual, vTipoChipPinOffline_actual
            FROM intercard:tarjeta a INNER JOIN intercard:hsmcard b
                ON(a.numtarjeta = b.card_no)
            WHERE numcliente = vNumCliente
                AND numtarjeta = vNumTarjeta;

            IF (vsFlagEnTransaccion = 'F') THEN
                BEGIN WORK;
                LET vsFlagEnTransaccion = 'V';
            END IF

            LET vFechaProceso = current;
            
            --Paso 3.
            --Flujos de validación por tipo de transacción: Tarjeta Presente y Tarjeta No Presente.
            --Si la tarjeta es diferente a activada, bloqueada o bloqueo temporal
            --se deja de notificar a dicha tarjeta pero sí al resto de las tarjetas asociadas al cliente.
            IF ( vCodEstatusTarj_actual IN ( 'ACT' , 'BLO', 'BLT' ) ) THEN
                    
                IF ( pTipoTransacc = MOVS_TARJ_PRESENTE ) THEN
                
                    ---Paso 3.1
                    ---Si los valores son iguales entonces la tarjeta NO tiene firma electronica activa.
                    
                    IF ( vTipoTarjetaPin_ant = vTipoTarjetaPin_actual AND 
                            vTipoChipPinOffline_ant = vTipoChipPinOffline_actual ) THEN
                                                                    
                        IF ( pTipoEnvio = NOTIF_SMS ) THEN
                        
                            IF ( vTipoTarjetaPin_ant = TIPO_TARJETA_A ) THEN
                                LET vID_Plantilla = 'CMS_TP_FE_A';
                            END IF
                            
                            IF ( vTipoTarjetaPin_ant IN ( TIPO_TARJETA_B, TIPO_TARJETA_C ) ) THEN
                                LET vID_Plantilla = 'CMS_TP_FE_BC';                                        
                            END IF
                            
                        END IF
                                    
                                    
                        IF (  pTipoEnvio = NOTIF_CORREO_ELEC ) THEN
                            
                            IF ( vTipoTarjetaPin_ant = TIPO_TARJETA_A ) THEN
                                LET vID_Plantilla = 'CMC_TP_FE_A';                                        
                            END IF
                            
                            IF ( vTipoTarjetaPin_ant IN ( TIPO_TARJETA_B, TIPO_TARJETA_C ) ) THEN
                                LET vID_Plantilla = 'CMC_TP_FE_BC';                                        
                            END IF
                            
                        END IF

                        UPDATE intercard:"informix".tbl_campania_notif_tarjeta_ctes
                            SET estatus_proceso = PROCESO_NOTIFICADO,                                 
                                    fecha_proceso = vFechaProceso,
                                desc_plantilla = vID_Plantilla
                        WHERE num_cliente = vNumCliente
                            AND numtarjeta = vNumTarjeta
                                AND tipo_transacc_carga = vTipoTransacc;
                                
                        LET vID_Plantilla = NULL;
                    
                    ELSE
                    
                        UPDATE intercard:"informix".tbl_campania_notif_tarjeta_ctes
                            SET tipo_tarjeta_proc = vTipoTarjetaPin_actual,
                                    pin_offline_proc = vTipoChipPinOffline_actual,
                                codestatus_tarjeta_proc = vCodEstatusTarj_actual,
                                    estatus_proceso = PROCESO_TERMINADO,                                 
                                fecha_proceso = vFechaProceso,
                                    desc_plantilla = 'FINALIZADO'
                        WHERE num_cliente = vNumCliente
                            AND numtarjeta = vNumTarjeta
                                AND tipo_transacc_carga = vTipoTransacc;
                            
                    END IF
                    
                END IF ---Cierre de tarjeta presente (pTipoTransacc = MOVS_TARJ_PRESENTE)
                    
                --Paso 3.2
                ---Validar si la tarjeta tiene CVV dinamico activo o firma electronica activa
                IF ( pTipoTransacc = MOVS_TARJ_NO_PRESENTE ) THEN                        
                        
                    LET vID_Plantilla = 'FINALIZADO';
                    LET vEstatusProceso = PROCESO_TERMINADO;
                    
                    SELECT cvv2dinamico
                        INTO vCVVDinamico
                    FROM intercard:tarjeta_indicadores
                        WHERE numtarjeta = vNumTarjeta
                            AND cvv2dinamico = 'V';                    
                    
                    LET vCVVDinam_esActivo = dbinfo("sqlca.sqlerrd2");                    

                    --La tarjeta NO tiene CVV Dinamico activo (sin enrolamiento), o bien, ni siquiera hay registro en 
                    --tarjeta indicadores.
                    IF ( vCVVDinam_esActivo = 0 ) THEN
                        
                        LET vEstatusProceso = PROCESO_NOTIFICADO;
                        
                        ---Si los valores son iguales entonces la tarjeta NO tiene firma electronica activa.
                        --IF ( vTipoTarjetaPin_ant = vTipoTarjetaPin_actual AND 
                          --      vTipoChipPinOffline_ant = vTipoChipPinOffline_actual ) THEN
                                
                                IF (  pTipoEnvio = NOTIF_SMS ) THEN
                                    LET vID_Plantilla = 'CMS_TNP_FECD';
                                ELIF (  pTipoEnvio = NOTIF_CORREO_ELEC ) THEN
                                    LET vID_Plantilla = 'CMC_TNP_FECD';
                                END IF
                        --END IF
                        
                    END IF
                                   
                    UPDATE intercard:"informix".tbl_campania_notif_tarjeta_ctes
                        SET estatus_proceso = vEstatusProceso, 
                                tipo_tarjeta_proc = vTipoTarjetaPin_actual,
                            pin_offline_proc = vTipoChipPinOffline_actual,
                                codestatus_tarjeta_proc = vCodEstatusTarj_actual,
                            fecha_proceso = vFechaProceso,
                                desc_plantilla = vID_Plantilla
                    WHERE num_cliente = vNumCliente
                        AND numtarjeta = vNumTarjeta
                            AND tipo_transacc_carga = vTipoTransacc;


                END IF ---Cierre de tarjeta NO presente (pTipoTransacc = MOVS_TARJ_NO_PRESENTE)
                    
            ELSE
                
                --El estatus de la tarjeta no cumple con las condiciones
                --y deja de notificarse al cliente solo con esta tarjeta asignada 
                --ya sea Tarjeta Presente o Tarjeta No Presente.
                UPDATE intercard:"informix".tbl_campania_notif_tarjeta_ctes
                    SET tipo_tarjeta_proc = vTipoTarjetaPin_actual,
                        pin_offline_proc = vTipoChipPinOffline_actual,
                            codestatus_tarjeta_proc = vCodEstatusTarj_actual,
                        estatus_proceso = PROCESO_TERMINADO,
                        desc_plantilla = 'FINALIZADO',
                        fecha_proceso = vFechaProceso
                WHERE num_cliente = vNumCliente
                    AND numtarjeta = vNumTarjeta
                        AND tipo_transacc_carga = vTipoTransacc;                       
            END IF
        
            LET vConteo = dbinfo("sqlca.sqlerrd2") + vConteo;
            IF (vConteo >= vContadorTransacciones) THEN
                COMMIT WORK;
                LET vsFlagEnTransaccion = 'F';
                LET viContadorRegistros = 0;
                CONTINUE FOREACH;
            END IF
            
            --Reinicio de variable para el siguiente ciclo.
            LET vCVVDinam_esActivo = 0;
            LET vFechaProceso = NULL;
        
        END FOREACH


        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN
            COMMIT WORK;
            LET vsFlagEnTransaccion = 'F';
        END IF;

        UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".tbl_campania_notif_tarjeta_ctes;

        LET vID_Plantilla = '';
        LET vConteo = 1;
        LET vFechaProceso = NULL;
        
        --Paso 4. Registro y conteo de notificaciones para los clientes.
       
        IF ( pTipoEnvio = NOTIF_SMS ) THEN
            ---Contrato Latinia: Campania SMS por proceso batch.
            LET vContrato = 'CMPS_BATCH';
        END IF
        IF ( pTipoEnvio = NOTIF_CORREO_ELEC ) THEN
            ---Contrato Latinia: Campania Correo electronico por proceso batch.
            LET vContrato = 'CMPC_BATCH';
        END IF
        
        ---Obtener número máximo de notificaciones 
        ---para considerar el envío de mensajes de texto o correo electrónico hacia los clientes.
        SELECT camp_max_notificaciones 
            INTO vMaxNotificaciones
        FROM intercard:parametros;
        
        
        IF ( pTipoEnvio = NOTIF_SMS ) THEN      
    
            FOREACH cur_enviar_notif WITH HOLD FOR        

                SELECT num_cliente, desc_plantilla, numtarjeta, NVL(b.telefono, 0) as num_telefono, 
                    MAX(num_registro_sms) as sms,
                        MAX(num_registro_correo_elec) as correo, 
                            ( MAX(num_registro_sms) + MAX(num_registro_correo_elec) ) as total_envios
                    INTO vNumCliente, vID_Plantilla, vNumTarjeta, vNumTelefono, vNumEnvioSMS, vNumEnvioCorreo, vTotalEnvios
                FROM intercard:"informix".tbl_campania_notif_tarjeta_ctes a 
                    INNER JOIN bdinteg:"informix".si_telefonos_actual b
                        ON (a.num_cliente = b.numcte)
                WHERE a.estatus_proceso = PROCESO_NOTIFICADO
                    AND a.tipo_transacc_carga = vTipoTransacc
                        AND b.tipo_tel = '2' 
                    AND b.status_tel = 'A'                    
                GROUP BY num_cliente, desc_plantilla, numtarjeta, b.telefono                
                
                IF (vsFlagEnTransaccion = 'F') THEN
                    BEGIN WORK;
                    LET vsFlagEnTransaccion = 'V';
                END IF                
                        
                LET vFechaProceso = sysdate;                
                
                IF ( vNumTelefono <> '' AND vNumTelefono <> '0' AND vTotalEnvios < vMaxNotificaciones ) THEN
                    
                    SELECT nombre1, nombre2
                        INTO vPrimerNombre, vSegundoNombre
                    FROM bdinteg:si_cliente
                        WHERE numcte = vNumCliente;
                    
                    LET vNombreAsignado = TRIM(vPrimerNombre);
                    
                    IF ( LENGTH ( TRIM(vPrimerNombre)) < 3 ) THEN
                        LET vNombreAsignado = TRIM(vSegundoNombre);
                    END IF
                    
                    LET vTerminacionTarjeta = SUBSTR( vNumTarjeta, 13, 4 );
                    
                    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2', vContrato, vID_Plantilla, vNumCliente,'','','2',vNombreAsignado,vTerminacionTarjeta,'','','','','','','','','',vNumTelefono,0,0,0,0,0,vFechaSistema,vFechaSistema)
                        INTO vCodigoRetorno;                        
                    
                    IF ( vCodigoRetorno = '00000' ) THEN
                    
                        LET INCREMENTO_CONT_SMS = 1;
                        
                        INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso, tarjeta, fecha_insert, estatus_envio, tipo_envio, cod_ret, descripcion)
                            VALUES ( vID_Plantilla, vNumTarjeta, vFechaProceso, 'V' ,'2', vCodigoRetorno, vTipoTransacc );
                    END IF
                    
                END IF                
        
                UPDATE intercard:"informix".tbl_campania_notif_tarjeta_ctes
                    SET num_registro_sms = vNumEnvioSMS + INCREMENTO_CONT_SMS, 
                        num_registro_correo_elec = vNumEnvioCorreo + INCREMENTO_CONT_CORREO,
                        fecha_proceso = vFechaProceso,
                        estatus_proceso = PROCESO_NOTIFICADO
                WHERE num_cliente = vNumCliente
                    AND numtarjeta = vNumTarjeta
                        AND tipo_transacc_carga = vTipoTransacc;
                 
                LET INCREMENTO_CONT_SMS = 0 ;
                LET INCREMENTO_CONT_CORREO = 0;
                LET vID_Plantilla = NULL;
                LET vFechaProceso = NULL;
                LET vTerminacionTarjeta = NULL;
                LET vNumTarjeta = NULL;
                LET vNombreAsignado = NULL;
                
                LET vConteo = dbinfo("sqlca.sqlerrd2") + vConteo;
                
                IF (vConteo >= vContadorTransacciones) THEN
                    COMMIT WORK;
                    LET vsFlagEnTransaccion = 'F';
                    LET viContadorRegistros = 0;
                    LET vConteo = 1; ---reinicio del contador
                    CONTINUE FOREACH;
                END IF;

            END FOREACH
            
        END IF
    
   
                            
        IF ( pTipoEnvio = NOTIF_CORREO_ELEC ) THEN
    
            FOREACH cur_enviar_notif WITH HOLD FOR
        
                SELECT num_cliente, desc_plantilla, numtarjeta,  NVL(c.correo_elec, 0) as correo_elec, 
                        MAX(num_registro_correo_elec) as max_correo,
                            MAX(num_registro_sms) as sms,
                                ( MAX(num_registro_sms) + MAX(num_registro_correo_elec) ) as total_envios
                        INTO vNumCliente, vID_Plantilla, vNumTarjeta, vCorreoElect, vNumEnvioCorreo, vNumEnvioSMS, vTotalEnvios
                    FROM intercard:"informix".tbl_campania_notif_tarjeta_ctes a 
                        INNER JOIN bdinteg:"informix".si_correos c
                            ON (a.num_cliente = c.numcte)		
                WHERE a.estatus_proceso = PROCESO_NOTIFICADO
                    AND a.tipo_transacc_carga = vTipoTransacc
                        AND c.tipo_correo = 1
                    AND c.status_correo = 'A'                    
                GROUP BY num_cliente, desc_plantilla, numtarjeta, c.correo_elec
                
                IF (vsFlagEnTransaccion = 'F') THEN
                    BEGIN WORK;
                    LET vsFlagEnTransaccion = 'V';
                END IF                
            
                LET vFechaProceso = sysdate;
                        
                IF ( vCorreoElect <> '' AND vCorreoElect <> '0' AND vTotalEnvios < vMaxNotificaciones ) THEN                            
                    
                    SELECT nombre1, nombre2
                        INTO vPrimerNombre, vSegundoNombre
                    FROM bdinteg:si_cliente
                        WHERE numcte = vNumCliente;
                    
                    LET vNombreAsignado = TRIM(vPrimerNombre);
                    
                    IF ( LENGTH ( TRIM(vPrimerNombre)) < 3 ) THEN
                        LET vNombreAsignado = TRIM(vSegundoNombre);
                    END IF
                    
                    LET vTerminacionTarjeta = SUBSTR( vNumTarjeta, 13, 4 );
                    
                    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1',vContrato, vID_Plantilla, vNumCliente,'','','2',vNombreAsignado,vTerminacionTarjeta,'','','','','','','','',vCorreoElect,'',0,0,0,0,0,vFechaSistema,vFechaSistema)
                        INTO  vCodigoRetorno;                    
                    
                    IF ( vCodigoRetorno = '00000' ) THEN
                        LET INCREMENTO_CONT_CORREO = 1;
                        
                        INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso, tarjeta, fecha_insert, estatus_envio, tipo_envio, cod_ret, descripcion)
                            VALUES ( vID_Plantilla, vNumTarjeta , vFechaProceso , 'V' ,'2', vCodigoRetorno, vTipoTransacc );
                    END IF
                    
                END IF
                
                UPDATE intercard:"informix".tbl_campania_notif_tarjeta_ctes
                    SET num_registro_sms = vNumEnvioSMS + INCREMENTO_CONT_SMS, 
                        num_registro_correo_elec = vNumEnvioCorreo + INCREMENTO_CONT_CORREO,
                        fecha_proceso = vFechaProceso,
                        estatus_proceso = PROCESO_NOTIFICADO
                WHERE num_cliente = vNumCliente
                    AND numtarjeta = vNumTarjeta
                        AND tipo_transacc_carga = vTipoTransacc;
                 
                LET INCREMENTO_CONT_SMS = 0 ;
                LET INCREMENTO_CONT_CORREO = 0;
                LET vID_Plantilla = NULL;
                LET vFechaProceso = NULL;
                LET vTerminacionTarjeta = NULL;
                LET vNumTarjeta = NULL;
                LET vNombreAsignado = NULL;
                
                LET vConteo = dbinfo("sqlca.sqlerrd2") + vConteo;
                IF (vConteo >= vContadorTransacciones) THEN
                    COMMIT WORK;
                    LET vsFlagEnTransaccion = 'F';
                    LET viContadorRegistros = 0;
                    LET vConteo = 1; ---reinicio del contador
                    CONTINUE FOREACH;
                END IF;        
        
            END FOREACH

        END IF
    
        LET vCodigoRetorno = '00000';
        
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN
            COMMIT WORK;
            LET vsFlagEnTransaccion = 'F';
        END IF;

        UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".tbl_campania_notif_tarjeta_ctes;
        UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".bitacoraenvios_tjts;        
        
        RETURN 	vCodigoRetorno,vMensajeRespuesta; 
        
        
        
    END

END PROCEDURE
---#1
---Base de datos: intercard
---Autor: Armando Garcia Ortiz
---Creacion: 30 de julio del 2020
---Descripcion: Proceso para registrar las notificaciones de mensajes de texto o correo electronico 
---a los numeros de clientes previamente registrados.

---#2
---Modificacion: 17 de septiembre del 2020
---Descripcion: Se agrega el registro en la tabla de bitacora de envio de mensajes 
---considerando los registros para mensajes de texto o correo electronico de la campaña

---#3
---Modificacion: 30 de diciembre del 2020
---Descripcion: Se agrega funcionalidad para personalizar los mensajes de la campaña.
---Y validacion del maximo número de notificaciones.

---Este componente es ejecutado por los jobs:
--=> 843_01_1_CORREO_NOTIF_CTES_TP_PRO
--=> 843_01_2_SMS_NOTIF_CTES_TP_PRO
--=> 843_02_1_CORREO_NOTIF_CTES_TNP_PRO
--=> 843_02_2_SMS_NOTIF_CTES_TNP_PRO
;

CREATE PROCEDURE "informix".sp_registra_evento(pIdProceso VARCHAR(20))
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;

	-- Base de Datos: intercard
	-- Fecha de modificacion: 06 de Julio de 2023
	-- Autor: Luis Daniel Bautista Zamora, Eleazir Gabriel Gomez PeÃ±a
	-- Comentario: Se Reestructura SP  para tomar en cuenta nueva tabla creada con usuarios de PdF por cambios en el sistema de cancelacion usado por Fraudes y se optimizan costos de consultas.
	
---VARIABLES PARA CAPTURAR ERRORES
DEFINE vNumTarjeta          Varchar(16);
DEFINE vsnumcte 	        CHAR (20);
DEFINE vsCodRet1            CHAR(5);
DEFINE vsCodRet2            CHAR(5);
DEFINE vstelefono	        CHAR(13);
DEFINE vstipotel 	        SMALLINT;
DEFINE vsSecuencia          SMALLINT;
DEFINE vsStatustel	        CHAR(1);
DEFINE vsextension 	   	    CHAR(5);
DEFINE vscarrier	   	    SMALLINT;
DEFINE vsnombrecarrier 	    CHAR(20);
DEFINE vsStatusvalidacion   SMALLINT;
DEFINE vscorreo			    CHAR(100);
DEFINE vstipocorreo		    SMALLINT;
DEFINE vsStatuscorreo       CHAR(1);
DEFINE vsMensaje            CHAR(200);
DEFINE vsString1            VARCHAR(50);  
DEFINE cCodRet              CHAR(5);
DEFINE vsecuencial          integer; 
DEFINE valerta1             varchar(10);
DEFINE valerta2             varchar(10);
DEFINE vIdPlantilla1        varchar(15); 
DEFINE vIdPlantilla2        varchar(15); 
DEFINE vdFechaInsert        DATETIME YEAR TO FRACTION(5);
DEFINE vdFechaHoy           DATETIME YEAR TO FRACTION(5);
DEFINE vdFechaValidabita    DATETIME YEAR TO FRACTION(5);
DEFINE vUsuario             CHAR(10);
DEFINE vfechahora           DATETIME YEAR TO FRACTION(5);
DEFINE vmaxfecha            DATETIME YEAR TO FRACTION(5);
--DEFINE vcDepartamento        CHAR(3);
DEFINE venvios_sms          integer; 
DEFINE venvios_email        integer; 
DEFINE venvios_error        integer; 
DEFINE vtotal_envios        integer; 
DEFINE wcount               integer;     --variable no utilizada
 
 
	--  Variables de Errores y datos de SP
	define  sql_err          integer;
	define  isam_err         integer;
	define  error_info       varchar(80);
	define  p_cod_ret        varchar(6);
	define  p_mensaje        varchar(80);
	
--  Variables para control de contadores
define  vsflagentransaccion 	char(1);
define 	vicontadorregistros 	integer;
define  vmaxnumregistros integer;   

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET P_COD_RET    = SQL_ERR;
	LET P_MENSAJE  = ERROR_INFO;
	
    RETURN 	P_COD_RET,P_MENSAJE;
		
   END EXCEPTION; 
 
 ---INICIALIZAN VARIABLES PARA QUERYS
LET vsnumcte           = '';
LET vsCodRet1          = '00000';
LET vsCodRet2          = '00000';
LET vstelefono         = '';
LET vsMensaje          = ''; 
LET vstipotel          = 0;
LET vsSecuencia        = 0;
LET vsStatustel        = '';
LET vsextension        = '';
LET vscarrier          = 0;   
LET vsnombrecarrier    = '';
LET vsStatusvalidacion = 0;
LET vscorreo           = '';
LET vsStatuscorreo     = '';
LET vstipocorreo       = 0;
LET cCodRet = '00000';
LET vsecuencial = 0; 
LET vdFechaInsert      =  sysdate;  
LET vdFechaHoy         =  sysdate;  
LET vdFechaValidabita  =  sysdate;  
LET vdFechaValidabita =  vdFechaValidabita::DATE;

LET vUsuario = '';
LET vNumTarjeta = '';
LET vfechahora = '';
LET venvios_sms        = 0;
LET venvios_email      = 0;
LET venvios_error      = 0;
LET vtotal_envios      = 0;
LET wcount             = 0;
  
LET p_cod_ret = '00000';
LET p_mensaje = 'Proceso Exitoso';

LET 	vsflagentransaccion = 'F';
LET		vicontadorregistros = 0;
LET     vmaxnumregistros=1000;  


--set debug file to "/RESPALDOSNEW/LDBZ/sp_registra_evento.out";
--trace on;	

IF (pIdProceso = 'CAN_PF') THEN        
   
   ---------------------------------------------------------------------------
   
        
        select   count(*) into wcount 
		FROM intercard:bitacora_control_envios_can where date(fecha_insert) = today;
			
		--if wcount = 0 then  
		--   update statistics medium for table intercard:"informix".bitacoracambiostarjeta;   
        --end if;			
   ----------------------------------------------------------------- ----------
    
	 
     Select  MAX (fecha_insert) 
	 INTO vmaxfecha  FROM  intercard:bitacora_control_envios_can; 
     
	  if( vmaxfecha = '' or vmaxfecha is null) then 
		  let vmaxfecha = SUBSTRING(sysdate FROM 1 FOR 10) || ' 00:00:00';
	  end if; 	  
      
   -- let vcDepartamento = pDepartamento; 
------------------------------------------------------------------------------------------------	

SELECT 	bt.tarjeta, bt.numcliente,bts.fechahora, bts.usuario
FROM intercard:bitacoracambiostarjeta bt
INNER JOIN intercard:bitacoracambiosstatustarjeta bts
ON bts.tarjeta=bt.tarjeta
WHERE bts.fechahora >= TODAY 
AND bt.tabla = 'Intercard:tarjeta' 
AND bt.campo = 'codstatustarjeta'
AND bt.valoranterior !=   'CAN' 
AND bt.valornuevo =   'CAN'
AND bt.identificadorcambio = '1'
AND bts.codstatustarjetanvo = bt.valornuevo
INTO TEMP tmp_bitacoracambios WITH NO LOG;

-----------------------------------------------------------------------------------------------

 set lock mode to wait 3;
 set isolation to dirty read;
 
 FOREACH WITH HOLD

		 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		   SELECT  bt.tarjeta,bt.numcliente,bt.usuario
		    INTO vNumTarjeta,vsnumcte,vUsuario
			FROM tmp_bitacoracambios as bt 
			INNER JOIN intercard:usuarios_pfraudes as up
			ON up.numempleado=bt.usuario
			WHERE 
			bt.tarjeta NOT IN (
									select 
									tarjeta 
									from intercard:bitacoraenvios_tjts
									where date(fecha_insert)= vdFechaValidabita
									and bt.tarjeta=tarjeta
									)
            AND bt.fechahora >= vmaxfecha
			
		 
		 
		 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		
		--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
		if (vsFlagEnTransaccion = 'F') then
		  begin work;
		  let vsFlagEnTransaccion = 'V';
		end if;	 
 
        -----------------------------------------------------------
		
		 LET vIdPlantilla1 ='CANTJTMAIL';   -- plantilla email    
		 LET valerta1      ='CANTJTMAIL';    -- alerta email 
		 LET vIdPlantilla2 ='CANTJT_SMS';    -- plantilla sms    
         LET valerta2      ='CANTJT_SMS';    -- alerta sms   		         
 
       INSERT 
		INTO intercard:"informix".bitacoraenvios_tjts VALUES ( 0, pIdProceso,vNumTarjeta,vdFechaInsert,'P','','','');   
 
        SET ISOLATION TO DIRTY READ;
        SELECT --{+INDEX(bitacoraenvios_tjts idx_bitacoraenvios_tjts1} 
		FIRST 1 secuencial,fecha_insert  INTO  vsecuencial,vdFechaInsert 
		FROM intercard:"informix".bitacoraenvios_tjts  
		where id_proceso= pIdProceso AND  fecha_insert = vdFechaInsert AND estatus_envio = 'P' AND tarjeta = vNumTarjeta; 

	       EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_telefonos("001",vsnumcte,2,"0") 
		   INTO vsCodRet1,vstelefono,vstipotel,vsSecuencia,vsStatustel,vsextension,vscarrier,vsnombrecarrier,vsStatusvalidacion;
		   
	        IF ((vsCodRet1 = '000') and (vstelefono <> '' AND vstelefono is not null))  THEN   
			
			     LET  vsString1  =  SUBSTR(vNumTarjeta,13,4); 
				    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento  ('1',valerta2,vIdPlantilla2,'000000000','',vNumTarjeta,'1',vsString1,'','','','','','','','','','',vstelefono,0,0,0,0,0,vdFechaHoy,'')
                    INTO 	cCodRet;
							
						 IF  ( cCodRet <> '00000' )  THEN 
                             LET vsCodRet1 = '004';
							 LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                             UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                              WHERE secuencial = vsecuencial; 
	                     END IF; 
							
							UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = '000',estatus_envio = 'V',tipo_envio = '1',descripcion = 'Se enviÃÂ³ SMS al titular.' 
                            WHERE secuencial = vsecuencial;
			
              ELSE  
			  
			     EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos("001",vsnumcte,1,"0")
				 INTO vsCodRet2,vscorreo,vstipocorreo,vsStatuscorreo;     
			 
			    IF ( (vsCodRet2 = '000') and (vscorreo <> '' AND vscorreo is not null) ) THEN  
			 
			         ---  INVOCAR  SP REGISTRA EVENTO (EMAIL)
                     LET  vsString1  =  SUBSTR(vNumTarjeta,13,4); 
                     EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento  ('1',valerta1,vIdPlantilla1,'000000000','',vNumTarjeta,'1',vsString1,'','','','','','','','','',vscorreo,'',0,0,0,0,0,vdFechaHoy,'')
                     INTO 	cCodRet;
												
						 IF  ( cCodRet <> '00000' )  THEN 
                            LET vsCodRet1 = '004';
							LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                            UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                            WHERE secuencial = vsecuencial; 
	                     END IF;  
													
						UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = '000',estatus_envio = 'V',tipo_envio = '2',descripcion = 'Se enviÃÂ³ Correo al titular.' 
                         WHERE secuencial = vsecuencial; 			        
			 
			      ELSE  --De no encontrar ningun medio de contacto genera bitacora de error.
			 
			         LET vsCodRet1 = '002';
                     LET vsMensaje   = 'Titular no tiene registrado celular o correo electrÃÂ³nico.';
				     UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1, estatus_envio = 'E', descripcion = vsMensaje 
                     WHERE secuencial = vsecuencial; 
                                             
	            END IF;			 
			 
			END IF;							
			     ---------------------
	
	let vicontadorregistros = vicontadorregistros + 1;   
	
	if (vicontadorregistros = vmaxnumregistros) then
	    commit work;
		let vsflagentransaccion = 'F';
		let vicontadorregistros = 0;
		continue foreach;
	end if;		
	
 END FOREACH;
 
 		if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
				commit work;
				let vsflagentransaccion = 'F';
		end if;       
		
		SET ISOLATION TO DIRTY READ;
	    SELECT    SUM ( sms_enviados) as sms_enviados,
               	   SUM (email_enviados) as email_enviados,  
				   SUM (error) as error_en_envio, 
                   SUM (sms_enviados + email_enviados + error) as total_envios
                   INTO  venvios_sms,venvios_email,venvios_error,vtotal_envios
		FROM  TABLE ( MULTISET ( 
            SELECT   tarjeta,
             CASE WHEN (tipo_envio  = '1' and estatus_envio = 'V' ) THEN COUNT (tarjeta) ELSE 0 END AS sms_enviados, 
             CASE WHEN (tipo_envio  = '2' and estatus_envio = 'V') THEN COUNT (tarjeta) ELSE 0 END AS email_enviados,
             CASE WHEN estatus_envio = 'E'  THEN COUNT (tarjeta) ELSE 0 END AS error
            FROM intercard:bitacoraenvios_tjts
            WHERE fecha_insert = vdFechaInsert
            GROUP BY tarjeta,tipo_envio,estatus_envio
        ) ); 
   
				  insert   into intercard:"informix".bitacora_control_envios_can 
						                           ( 
			                                        secuencial,
													fecha_insert,
													total_envios,
												    envios_sms,
													envios_email,
													envios_error
													)
											values 
													( 
													0,
													vdFechaInsert,
													NVL(vtotal_envios,0),
													NVL(venvios_sms,0),
													NVL(venvios_email,0),
													NVL(venvios_error,0)
													);
												
	
 
  ELSE    ---  EN ESPERA DE CONSTRUCCIÃâN  PARA OTROS PROCESOS    
 
        let p_cod_ret = '00001';
        let p_mensaje = 'Nombre del proceso incorrecto, favor de verificar.';

END IF; 	

	RETURN 	P_COD_RET,P_MENSAJE; 
----------------------------------------------------------------------------------------------------------------------------------------------------
   
end;
end procedure;