CREATE PROCEDURE "informix".sp_obtenerregistroarchivoatm_stat06_pagos (
    psNomArchivo VARCHAR (30),     --  Nombre del archivo el cual se esta cargando
    psArchivoOrigen VARCHAR(3),    --  Abreviatura del archivo
    piTipoLayOut INTEGER, 		   --  Tipo de layout
    psCve_Usuario VARCHAR(10)      --  Usuario del sistema 
)

RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta, INTEGER AS Elemento;


    /*  DEFINICION DE VARIABLES */
    DEFINE viSQLerr 				INTEGER ;
    DEFINE vsCodRet 				VARCHAR(5);
    DEFINE vsMensaje_Respuesta 		VARCHAR(250);
    DEFINE vsRegistro 				CHAR(500); 
    DEFINE vsFlagEnTransaccion 		VARCHAR (1);
    DEFINE viContadorRegistros 		INTEGER;

    -- Para identificar el tipo de bin 
    DEFINE vsbin 					CHAR (6);

    -- Para recuperar desde carga numero de cuenta Proceso Transfer
    Define vscuenta 				CHAR (12);
    define vsnumtarjetaini 			CHAR(16);
    DEFINE vsMonto					VARCHAR(14); 
    DEFINE vsAmtLocal				VARCHAR(14); 
    DEFINE vsHora					VARCHAR(8); 
    DEFINE vsfechalocaldia 			CHAR(2);  -- Secuencia_extendida
    DEFINE vsfechalocalmes 			CHAR(2);  -- Secuencia_extendida
    DEFINE vshoralocalhr 			CHAR(2);  -- secuencia_extendida
    DEFINE vshoralocalmin  			CHAR(2);  -- secuencia_extendida
    DEFINE vsIDSecuencia 			CHAR(1);  -- secuencia_extendida
    DEFINE vsSecuencia 				CHAR(6);  -- secuencia_extendida
    DEFINE vsSecuencia_extendida 	CHAR(15);  -- secuencia_extendida

    /* INICIALIZACION DE VARIABLES */
    LET viSQLerr = 0;    
    LET vsCodRet = '00000';
    LET vsMensaje_Respuesta = '';
    LET vsRegistro  = '';
    LET vsFlagEnTransaccion = '';
    LET viContadorRegistros = 0;
    -- Para identificar el tipo de bin 
    LET vsbin = '';
    -- Para recuperar desde carga numero de cuenta
    let vscuenta = '';
    let vsnumtarjetaini = '';
    LET vsMonto='';
    LET vsAmtLocal='';
    LET vsHora='';
    LET vsfechalocaldia = '';  -- Secuencia_extendida
    LET vsfechalocalmes = '';  -- Secuencia_extendida
    LET vshoralocalhr = '';  -- secuencia_extendida
    LET vshoralocalmin = '';  -- secuencia_extendida
    LET vsIDSecuencia = '1';  -- secuencia_extendida
    LET vsSecuencia = '';  -- secuencia_extendida
    LET vsSecuencia_extendida = '';  -- secuencia_extendida
    
    --SET DEBUG FILE TO "/RESPALDOSNEW/e10000656/prueba.out";
    --TRACE ON;
    
    BEGIN

        ON EXCEPTION SET viSQLerr
            
            --SET DEBUG FILE TO "/RESPALDOSNEW/sp_obtenerregistroarchivoatm_stat06_pagos.out" WITH APPEND;
            --TRACE ON;
            
            -- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
            IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
                COMMIT WORK;
                LET vsFlagEnTransaccion = 'F';
            END IF;

            --BORRA LOS REGISTROS DEL ARCHIVO ALMACENADOS EN LA TABLA DE CARGA
            BEGIN WORK;
                TRUNCATE TABLE bditarjeta:"informix".td_carga_archivo_atm_stat06_pagos DROP STORAGE;
            COMMIT WORK;

            LET vsCodRet = '00200';	
            RETURN vsCodRet, ('[' || vsCodRet ||  ']ERROR NO CONTROLADO (' || viSQLerr || '). ARCHIVO (' || psNomArchivo || ') ' || TRIM(vsMensaje_Respuesta) ), 2;

        END EXCEPTION;

        LET vsFlagEnTransaccion = 'F';
        LET viContadorRegistros = 0;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        --RECORRE LA TABLA PARA OBTENER LOS REGISTROS
        FOREACH WITH HOLD

            SELECT Registro
                INTO vsRegistro
            FROM bditarjeta:"informix".td_carga_archivo_atm_stat06_pagos

            --ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
            IF (vsFlagEnTransaccion = 'F') THEN 
                BEGIN WORK;
                LET vsFlagEnTransaccion = 'V';
            END IF;

            LET vsMensaje_Respuesta = 'INSERTAR REGISTRO EN LA TABLA CONCILIACION_ATM_STAT06_PAGOS.';
            
            IF (piTipoLayOut = 8) THEN 

                LET vsfechalocaldia = TRIM(SUBSTRING (vsRegistro FROM 180 FOR 2 )); --FECHA_dia
                LET vsfechalocalmes = TRIM(SUBSTRING (vsRegistro FROM 183 FOR 2 )); --FECHA_mes
                LET vshoralocalhr = TRIM(SUBSTRING (vsRegistro FROM 189 FOR 2 )); --hora
                LET vshoralocalmin = TRIM(SUBSTRING (vsRegistro FROM 192 FOR 2 )); -- minutos
                LET vsSecuencia = TRIM(SUBSTRING (vsRegistro FROM 25 FOR 6 )); -- numero de cajero
                LET vsSecuencia_extendida = vsfechalocaldia||vsfechalocalmes||vshoralocalhr||vshoralocalmin||vsIDSecuencia||vsSecuencia;


				INSERT INTO Intercard:"informix".conciliacion_atm_stat06_pagos 
				( 
					fecha_conciliacion,
					archivoorigen,
					nombrearchivo,
					emisor,
					cajero,
					num_cuenta,
					entradaDep,
					cuenta_origen,
					cuenta_destino,
					tipo_txn,
					reversal,
					descripcion,
					resp,
					CR,
					sequen,
					fecha,
					hora,
					orden,
					red,
					monto_retiro,
					monto_deposito,
					monto_ingresado,
					monto_cambio,
					dolares,
					surcharge,
					donativo,
					emp,
					autorizacion,
					folio_dep,
					compania,
					com_emisora,
					PEM,
					serivce_code,
					terminal_capability,
					ARQC,
					ARPC,
					ARQC_Verify,
					sec_extendida_archivo
				)
				VALUES 
				(
					CURRENT, -- fecha_conciliacion
					TRIM(psArchivoOrigen), -- archivoorigen
					TRIM(psNomArchivo), -- nombrearchivo
					TRIM(SUBSTRING (vsRegistro FROM 3 FOR 4 )),     -- emisor,
					TRIM(SUBSTRING (vsRegistro FROM 25 FOR 10 )),   -- cajero,
					TRIM(SUBSTRING (vsRegistro FROM 37 FOR 22 )),   -- num_cuenta,
					TRIM(SUBSTRING (vsRegistro FROM 69 FOR 2 )),    -- entradaDep,
					TRIM(SUBSTRING (vsRegistro FROM 75 FOR 19 )),   -- cuenta_origen,
					TRIM(SUBSTRING (vsRegistro FROM 97 FOR 19 )),   -- cuenta_destino,
					TRIM(SUBSTRING (vsRegistro FROM 118 FOR 2 )),   -- tipo_txn,
					TRIM(SUBSTRING (vsRegistro FROM 121 FOR 8 )),   -- reversal,
					TRIM(SUBSTRING (vsRegistro FROM 132 FOR 15 )),  -- descripcion,
					TRIM(SUBSTRING (vsRegistro FROM 150 FOR 1 )),   -- resp,
					TRIM(SUBSTRING (vsRegistro FROM 155 FOR 3 )),   -- CR,
					TRIM(SUBSTRING (vsRegistro FROM 161 FOR 4 )),   -- sequen,
					TRIM(SUBSTRING (vsRegistro FROM 178 FOR 10)),   -- fecha,
					TRIM(SUBSTRING (vsRegistro FROM 188 FOR 8 )),   -- hora,
					TRIM(SUBSTRING (vsRegistro FROM 199 FOR 4 )),   -- orden,
					TRIM(SUBSTRING (vsRegistro FROM 205 FOR 4 )),   -- red,
					TRIM(SUBSTRING (vsRegistro FROM 210 FOR 10 )),  -- monto_retiro,
					TRIM(SUBSTRING (vsRegistro FROM 221 FOR 10 )),  -- monto_deposito,
					TRIM(SUBSTRING (vsRegistro FROM 232 FOR 10 )),  -- monto_ingresado,
					TRIM(SUBSTRING (vsRegistro FROM 243 FOR 10 )),  -- monto_cambio,
					TRIM(SUBSTRING (vsRegistro FROM 254 FOR 10 )),   -- dolares, le movi
					TRIM(SUBSTRING (vsRegistro FROM 265 FOR 10 )),  -- surcharge,
					TRIM(SUBSTRING (vsRegistro FROM 276 FOR 9 )),   -- donativo,
					TRIM(SUBSTRING (vsRegistro FROM 287 FOR 4 )),   -- emp,
					TRIM(SUBSTRING (vsRegistro FROM 293 FOR 6 )),   -- autorizacion,
					TRIM(SUBSTRING (vsRegistro FROM 300 FOR 16 )),  -- folio_dep,
					TRIM(SUBSTRING (vsRegistro FROM 317 FOR 10 )),  -- compania,
					TRIM(SUBSTRING (vsRegistro FROM 328 FOR 10 )),  -- com_emisora,
					TRIM(SUBSTRING (vsRegistro FROM 350 FOR 3 )),   -- PEM,
					TRIM(SUBSTRING (vsRegistro FROM 354 FOR 1 )),   -- serivce_code,
					TRIM(SUBSTRING (vsRegistro FROM 356 FOR 8 )),   -- terminal_capability,
					TRIM(SUBSTRING (vsRegistro FROM 365 FOR 16 )),  -- ARQC,
					TRIM(SUBSTRING (vsRegistro FROM 382 FOR 32 )),  -- ARPC,
					TRIM(SUBSTRING (vsRegistro FROM 415 FOR 1 )),   -- ARQC_Verify,
					TRIM(vsSecuencia_extendida)                     -- sec_extendida_archivo
				);
                
                
			END IF;
			
            LET viContadorRegistros = viContadorRegistros + 1;
            
            --TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
            
            LET vsMensaje_Respuesta = 'TERMINAR TRANSACCION';
            IF (viContadorRegistros >= 1000) THEN --VERIFICA SI ALCANZO EL MAXIMO DE TRANSACCIONES POR BLOQUE
                COMMIT WORK;
                LET viContadorRegistros = 0;
                LET vsFlagEnTransaccion = 'F';
                CONTINUE FOREACH;
            END IF;

        END FOREACH;

        -- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
        
        LET vsMensaje_Respuesta = 'TERMINAR TRANSACCION';    
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
            COMMIT WORK;
            LET viContadorRegistros = 0;
            LET vsFlagEnTransaccion = 'F';
        END IF;

        UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".conciliacion_atm_stat06_pagos;
        
        --BORRA LOS REGISTROS DEL ARCHIVO ALMACENADOS EN LA TABLA DE CARGA
        LET vsMensaje_Respuesta = 'BORRAR CONTENIDO DE td_carga_archivo_atm_stat06_pagos.';
        
        BEGIN WORK;
            TRUNCATE TABLE bditarjeta:"informix".td_carga_archivo_atm_stat06_pagos DROP STORAGE;
        COMMIT WORK;
        
        RETURN vsCodRet, vsMensaje_Respuesta, 2;

    END

END PROCEDURE;