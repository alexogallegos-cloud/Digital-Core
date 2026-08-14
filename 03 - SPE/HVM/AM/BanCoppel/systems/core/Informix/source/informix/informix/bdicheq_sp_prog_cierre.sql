CREATE PROCEDURE "informix".sp_prog_cierre()
    RETURNING CHAR(5) AS vCodRet1, CHAR(1000) AS vCodRet2, CHAR(1000) AS vCodRet3;

    DEFINE Sql_Err         INTEGER;
    DEFINE Isam_Err        INTEGER;
    DEFINE vCodRet1        CHAR(5);
    DEFINE vCodRet2        CHAR(1000);
    DEFINE vCodRet3        CHAR(1000);
    DEFINE vFechaHoy       DATE;
    DEFINE vTotal          INTEGER;
    DEFINE vOrigen         CHAR(4);
    DEFINE vDestino        CHAR(4);
	DEFINE vOrigen_c       CHAR(4);
    DEFINE vDestino_c      CHAR(4);
    DEFINE vestatus1       INTEGER;
    DEFINE vestatus0       INTEGER;
    DEFINE v_contador      INT;
    DEFINE v_contador2      INT;
    DEFINE iIsamErr        SMALLINT;
    DEFINE cDescErr        CHAR(80);
    DEFINE vsqlerr         INTEGER;
	DEFINE vErrorInfo      CHAR(80);
	DEFINE vstatus		   INTEGER;

    -- Retorno de SP interno
    DEFINE vRetCod         CHAR(5);
    DEFINE vRetMsg         CHAR(1000);
    DEFINE vRetDetalle     CHAR(1000);
    DEFINE vLog            CHAR(1000);
    DEFINE cErrorInfo      CHAR(80);
	DEFINE vstatus_maximo  CHAR(1);

    -- Acumulador de mensajes
    LET Sql_Err    = 0;
    LET Isam_Err   = 0;
    LET vCodRet1   = '00000';
    LET vCodRet2   = 'OPERACION EXITOSA';
    LET vCodRet3   = '';
    LET vLog       = 'No hay sucursales por procesar No hay registros con estatus 0 ni 1.';
    LET vestatus0  = 0;
    LET vestatus1  = 1;
    LET v_contador = 0;
    LET v_contador2 = 0;
    LET iIsamErr   = 0; 
    LET vsqlerr    = 0; 
    LET vErrorInfo = "INICIO DEL PROCESO";
    LET cErrorInfo = "";   


    BEGIN


        ON EXCEPTION SET vsqlerr, iIsamErr, cDescErr
            SET DEBUG FILE TO "/RESPALDOSNEW/sp_control_cierre_sucursal.err";
            TRACE ON;
            IF vsqlerr <> 0 THEN
                LET vCodRet1   = vsqlerr;
                LET vErrorInfo = cErrorInfo;
             RETURN vCodRet1, vCodRet2, vCodRet3;
            END IF;
        END EXCEPTION;

		--SET DEBUG FILE TO "/RESPALDOSNEW/sp_cierre_reproceso.out";
		--TRACE ON;

   
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        SELECT fecha_hoy INTO vFechaHoy
        FROM informix.sc_fechas
        WHERE empresa = '001';
		
		--LET vFechaHoy = '07082025';

        -- Validar si hay registros con estatus 0 o 1
        SELECT COUNT(*) INTO vTotal
        FROM sc_prog_cierre
        WHERE estatus IN (0,1);

        IF vTotal = 0 THEN
            LET vCodRet3 = vLog;
			RETURN vCodRet1, vCodRet2, vCodRet3;
        END IF;

        -- Procesar estatus 0 y fecha = hoy
        SELECT COUNT(*) INTO vTotal
        FROM sc_prog_cierre
        WHERE estatus = 0 AND fecha_proceso = vFechaHoy;

        IF vTotal > 0 THEN
            FOREACH c0 WITH HOLD FOR
                SELECT origen, destino
                INTO vOrigen, vDestino
                FROM sc_prog_cierre
                WHERE estatus = 0 AND fecha_proceso = vFechaHoy

                CALL sp_control_cierre_sucursal(vOrigen, vDestino)
                RETURNING vRetCod,vRetDetalle;
                
                --LET vRetCod = '00000';

                IF vRetCod <> '00000' THEN
					
					IF  vRetCod = -668 THEN
					    
						UPDATE sc_prog_cierre
						SET estatus = '0'
						WHERE origen = vOrigen
						AND destino = vDestino 
						AND fecha_proceso = vFechaHoy;
						
						
						UPDATE bdicheq:sc_ctrl_cierre_suc
						SET 
						extrae_cuentas = '0'  -- Nuevo valor para el campo extrae_cuentas
						WHERE sucursal_origen = vOrigen
						AND sucursal_destino = vDestino;
					
					END  IF;
				
				
					LET vCodRet1 =  vRetCod;
                    LET vCodRet2 = 'DESCRIPCION  cierres con estatus 0 ' || vRetDetalle;
					
                    RETURN vCodRet1, vCodRet2, vCodRet3;
					
                END IF;
                 LET v_contador = v_contador + 1;
            END FOREACH;
            LET vLog =   'Procesados cierres con estatus 0. ' || v_contador;
			
			UPDATE bdicheq:sc_prog_cierre
			SET 
			estatus = '2'  -- se cambia el estatus a 2 si el proceso corrio exitosamente
			WHERE origen = vOrigen
			AND destino = vDestino
			AND fecha_proceso = vFechaHoy;
			
        END IF;

        -- Procesar estatus 1 y fecha = hoy (reproceso)
        SELECT COUNT(*) INTO vTotal
        FROM sc_prog_cierre
        WHERE estatus = 1 AND fecha_proceso = vFechaHoy;

        IF vTotal > 0 THEN
 
			SELECT origen, destino
            INTO vOrigen, vDestino
            FROM sc_prog_cierre
            WHERE estatus = 1 AND fecha_proceso = vFechaHoy;
				
			SELECT 
				MAX(GREATEST(
					NVL(extrae_cuentas, 0),
					NVL(ejecuta_bdicheq, 0),
					NVL(ejecuta_bdibpi, 0),
					NVL(ejecuta_bdicred, 0),
					NVL(ejecuta_bdicred_crd, 0),
					NVL(ejecuta_bdinteg, 0),
					NVL(ejecuta_bdinvers, 0),
					NVL(ejecuta_bdisolic, 0),
					NVL(ejecuta_bdicheq_comp, 0)
				))  AS status_maximo
			INTO vstatus_maximo
			FROM sc_ctrl_cierre_suc
			WHERE sucursal_origen = vOrigen 
    		AND sucursal_destino = vDestino;

			
            LET v_contador = 0;
			
            FOREACH c1 WITH HOLD FOR
                SELECT origen, destino
                INTO vOrigen, vDestino
                FROM sc_prog_cierre
                WHERE estatus = 1 AND fecha_proceso = vFechaHoy
				
                CALL sp_cierre_reproceso(vOrigen, vDestino,vstatus_maximo)
                RETURNING vRetCod, vRetMsg, vRetDetalle, vstatus;

                --LET vRetCod = '00000';

                IF vRetCod <> '00000' THEN

					IF  vRetCod = -668 THEN
					    
						UPDATE sc_prog_cierre
						SET estatus = '0'
						WHERE origen = vOrigen
						AND destino = vDestino 
						AND fecha_proceso = vFechaHoy;

						UPDATE bdicheq:sc_ctrl_cierre_suc
						SET 
						extrae_cuentas = '0'  -- Nuevo valor para el campo extrae_cuentas
						WHERE sucursal_origen = vOrigen
						AND sucursal_destino = vDestino;
					
					END  IF;
					
                    LET vCodRet1 =  vRetCod;
                    LET vCodRet2 = 'DESCRIPCION Reprocesados cierres con estatus 1' || vRetDetalle;
                    LET vCodRet3 = 'Error en el bloque: ' || vstatus;
					
                    RETURN vCodRet1, vCodRet2, vCodRet3;
                END IF;
                LET v_contador = v_contador + 1;
            END FOREACH;
			
			UPDATE bdicheq:sc_prog_cierre
			SET 
			estatus = '2'  -- se cambia el estatus a 2 si el proceso corrio exitosamente 
			WHERE origen = vOrigen
			AND destino = vDestino
			AND fecha_proceso = vFechaHoy;
			
            LET vLog =  'Reprocesados cierres con estatus 1 : ' || v_contador;
        END IF;

        
        -- Resultado final
        LET vCodRet1 = '00000';
        LET vCodRet2 = 'EJECUCION COMPLETA';
        LET vCodRet3 = vLog;

        RETURN vCodRet1, vCodRet2, vCodRet3;

    END;

END PROCEDURE;