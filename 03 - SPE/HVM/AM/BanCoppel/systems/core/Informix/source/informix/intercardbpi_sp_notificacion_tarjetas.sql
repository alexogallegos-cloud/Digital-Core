CREATE PROCEDURE "informix".sp_notificacion_tarjetas()
        RETURNING
            CHAR(5)  AS vCodRetorno1, 
            CHAR(50) AS vDescCodRetorno1,            
            DATE AS vFechaActual;            
            
            DEFINE vCodRetorno1 CHAR(5);
            DEFINE vDescCodRetorno1 CHAR(50);  
            DEFINE vFechaActual DATE;
            DEFINE vFechaInsert DATE;
            DEFINE vIdProceso VARCHAR(50);    
            DEFINE vPrimerAviso INTEGER;
            DEFINE vSegundoAviso INTEGER;
            DEFINE vTercerAviso INTEGER;
            DEFINE vTotalRegistros INTEGER;
            DEFINE vNumeroTarjeta VARCHAR(16);
            DEFINE vCodRetornoExt1 CHAR(5);
            DEFINE vUsuario CHAR(12);            
            DEFINE vMsjRetornoExt1 CHAR(50);
            
            DEFINE vMsjRecSuc  VARCHAR(15);
            DEFINE vMsjNotif_2 VARCHAR(15);
            DEFINE vMsjNotif_3 VARCHAR(15);
            DEFINE vMsjNotif_4 VARCHAR(15);
            
            
            DEFINE vMonto MONEY (16,2);
            DEFINE vFechaCompleta DATETIME YEAR to SECOND;
            DEFINE vComercioGiro VARCHAR(50);
            
            LET vCodRetorno1 = '00000';
            LET vDescCodRetorno1 = '00000 Ejecucion exitosa';    
            LET vFechaActual = '';
            LET vFechaInsert = sysdate;
            LET vIdProceso = '';
            LET vPrimerAviso = 0;
            LET vSegundoAviso = 0;
            LET vTercerAviso = 0;
            LET vTotalRegistros = 0;
            LET vNumeroTarjeta = '0000000000000000';
    
            LET vCodRetornoExt1 = '';
            LET vMsjRetornoExt1 = '';
            LET vUsuario = '';
            
            LET vMsjRecSuc  = 'REC_SUC';
            LET vMsjNotif_2 = 'MSJ_NOTIF_2';
            LET vMsjNotif_3 = 'MSJ_NOTIF_3';
            LET vMsjNotif_4 = 'MSJ_NOTIF_4';
            
            LET vMonto = 0;
            LET vFechaCompleta = '';
            LET vComercioGiro = '';
    
            --Parametros utilizados en el procedimiento almacenado sp_registro_bitacora_envio_mensajes
            
        BEGIN
            --SET DEBUG FILE TO "/informix/argoz/sp_notificacion_tarjetas.out";
            --TRACE ON;
            
            SET ISOLATION TO DIRTY READ;
            SET LOCK MODE TO WAIT 3;
            
            DROP TABLE IF EXISTS tmp_tarjetas_personalizadas_por_notificar;
            
            -- Construir la tabla temporal 
            SELECT { +INDEX(tarjeta idx_tarpri)} --Recomendacion de optimizacion
            DISTINCT b.fecha_insert, b.id_proceso, b.tarjeta        
            FROM bitacoraenvios_tjts b, tarjeta t
            WHERE 
                b.id_proceso IN ( vMsjRecSuc, vMsjNotif_2, vMsjNotif_3, vMsjNotif_4 ) --Recomendacion de optimizacion
                AND b.estatus_envio = 'V'
                AND t.codstatusasignada = 'NOA' 
                AND t.codstatustarjeta = 'INA'
                AND b.tarjeta = t.numtarjeta        
            ORDER BY fecha_insert DESC
            INTO TEMP tmp_tarjetas_personalizadas_por_notificar with no log;
            
            --Validar si hay registros en la tabla temporal.
            SELECT COUNT(*) TotalReg, user usuario
            INTO vTotalRegistros, vUsuario
            FROM tmp_tarjetas_personalizadas_por_notificar;
            
            IF( vTotalRegistros = 0 ) THEN            
                LET vCodRetorno1 = '00001';
                LET vDescCodRetorno1 = '00001|Sin registros en la tabla temporal';
                RETURN vCodRetorno1, vDescCodRetorno1, vFechaActual;
            END IF;            
            
            --Obtener fecha actual y numero de dias en cada aviso.
            SELECT fecha_hoy, user usuario INTO vFechaActual, vUsuario
            FROM bdinteg:"informix".si_fechas;
           
            SELECT valor1 INTO vPrimerAviso 
            FROM bditarjeta:"informix".td_parametro
            WHERE clave = vMsjNotif_2;
            
            SELECT valor1 INTO vSegundoAviso 
            FROM bditarjeta:"informix".td_parametro
            WHERE clave = vMsjNotif_3;
            
            SELECT valor1 INTO vTercerAviso 
            FROM bditarjeta:"informix".td_parametro
            WHERE clave = vMsjNotif_4;
            
            FOREACH
                --C1: REC_SUC to NOTIF_2 / 2do. Aviso
                SELECT fecha_insert, tarjeta
                INTO vFechaInsert, vNumeroTarjeta
                FROM  tmp_tarjetas_personalizadas_por_notificar
                WHERE id_proceso = vMsjRecSuc
                    
                IF ( vFechaInsert + vPrimerAviso units day = vFechaActual ) THEN
                    LET vCodRetorno1 = '00000';
                    LET vDescCodRetorno1 = '00000|Invocar sp_registro_bitacora_envio_mensajes';
                    EXECUTE PROCEDURE intercard:"informix".sp_registro_bitacora_envio_mensajes(vMsjNotif_2,vNumeroTarjeta, vUsuario, vFechaInsert, vMonto, vFechaCompleta, vComercioGiro)
                    INTO vCodRetornoExt1, vMsjRetornoExt1;
                END IF;
            END FOREACH;
            
            
            FOREACH                
                --C2: NOTIF_2 to NOTIF_3 / 3er. Aviso
                SELECT fecha_insert, tarjeta
                INTO vFechaInsert, vNumeroTarjeta
                FROM tmp_tarjetas_personalizadas_por_notificar
                WHERE id_proceso = vMsjRecSuc
                AND tarjeta IN (
                    SELECT tarjeta
                    FROM tmp_tarjetas_personalizadas_por_notificar
                    WHERE id_proceso = vMsjNotif_2)            
                
                IF ( vFechaInsert + vSegundoAviso units day = vFechaActual ) THEN
                    LET vCodRetorno1 = '00000';
                    LET vDescCodRetorno1 = '00000|Invocar sp_registro_bitacora_envio_mensajes';
                    EXECUTE PROCEDURE intercard:"informix".sp_registro_bitacora_envio_mensajes(vMsjNotif_3,vNumeroTarjeta, vUsuario, vFechaInsert, vMonto, vFechaCompleta, vComercioGiro)
                    INTO vCodRetornoExt1, vMsjRetornoExt1;            
                END IF;
                
            END FOREACH;  
             
            
            FOREACH  
                --C3: NOTIF_3 to NOTIF_4 / 4to. Aviso
                SELECT fecha_insert, tarjeta
                INTO vFechaInsert, vNumeroTarjeta
                FROM tmp_tarjetas_personalizadas_por_notificar
                WHERE id_proceso = vMsjRecSuc 
                AND tarjeta IN (
                    SELECT tarjeta
                    FROM tmp_tarjetas_personalizadas_por_notificar 
                    WHERE id_proceso = vMsjNotif_3)
                
                IF (  vFechaInsert + vTercerAviso units day = vFechaActual ) THEN
                    LET vCodRetorno1 = '00000';
                    LET vDescCodRetorno1 = '00000|Invocar sp_registro_bitacora_envio_mensajes';
                    EXECUTE PROCEDURE intercard:"informix".sp_registro_bitacora_envio_mensajes(vMsjNotif_4,vNumeroTarjeta, vUsuario, vFechaInsert, vMonto, vFechaCompleta, vComercioGiro)
                    INTO vCodRetornoExt1, vMsjRetornoExt1;            
                END IF;
                
            END FOREACH;            
            
            
            RETURN vCodRetorno1, vDescCodRetorno1, vFechaActual;
        END;
        
END PROCEDURE;