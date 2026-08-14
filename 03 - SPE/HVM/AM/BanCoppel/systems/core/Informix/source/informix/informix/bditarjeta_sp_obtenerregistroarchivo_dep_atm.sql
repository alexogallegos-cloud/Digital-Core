CREATE PROCEDURE "informix".sp_obtenerregistroarchivo_dep_atm (
    psNomArchivo VARCHAR (30),     --  Nombre del archivo el cual se esta cargando
    psArchivoOrigen VARCHAR(3),    --  Abreviatura del archivo
    piTipoLayOut INTEGER, 		   --  Tipo de layout
    psCve_Usuario VARCHAR(10)      --  Usuario del sistema 
)

RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta, INTEGER AS Elemento;

    --****************************************************************************************************
    -- DESCRIPCION:  CARGA LA INFORMACION SIGNIFICATIVA DE LOS REGISTROS A LA TABLA TD_MOVIMIENTOS_CONCILIACION
    -- AUTOR : Victoria QuiÃ±ones
    -- FECHA : 09/06/2018
    -- BD: BdiTarjeta
    -- SISTEMA : Conciliacion MasterCard-- Automatico
    -- MODIFICADO : 
    --***************************************************************************************************


    /*  DEFINICION DE VARIABLES */
    DEFINE viSQLerr 				INTEGER ;
    DEFINE vsCodRet 				VARCHAR(5);
    DEFINE vsMensaje_Respuesta 		VARCHAR(250);
    DEFINE vsRegistro 				CHAR(500); 
    DEFINE vsFlagEnTransaccion 		VARCHAR (1);
    DEFINE viContadorRegistros 		INTEGER;

    -- Para identificar el tipo de bin 
    DEFINE vsbin 					CHAR (6);

    -- Para recuperar desde carga nÃºmero de cuenta Proceso Transfer
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
    -- Para recuperar desde carga nÃºmero de cuenta
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
    
    --SET DEBUG FILE TO "/informix/LVRQ/dep_atm/debug/sp_obtenerregistroarchivo_dep_atm.out";
    --TRACE ON;
    
    --SET DEBUG FILE TO "/RESPALDOSNEW/__argoz/cnc/mastercard/debug/debug_sp_obtenerregistro_mc.out";
    --TRACE ON;
    
    BEGIN

        ON EXCEPTION SET viSQLerr
            
            SET DEBUG FILE TO "/RESPALDOSNEW/excep_sp_obtenerregistroarchivo_dep_atm.out" WITH APPEND;
            TRACE ON;
            
            -- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
            IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
                COMMIT WORK;
                LET vsFlagEnTransaccion = 'F';
            END IF;

            --BORRA LOS REGISTROS DEL ARCHIVO ALMACENADOS EN LA TABLA DE CARGA
            BEGIN WORK;
                TRUNCATE TABLE bditarjeta:"informix".td_carga_archivo_dep_atm DROP STORAGE;
            COMMIT WORK;

            LET vsCodRet = '00200';	
            RETURN vsCodRet, ('[' || vsCodRet ||  ']ERROR NO CONTROLADO (' || viSQLerr || '). ARCHIVO (' || psNomArchivo || ') ' || TRIM(vsMensaje_Respuesta) ), 2;

        END EXCEPTION;

        LET vsFlagEnTransaccion = 'F';
        LET viContadorRegistros = 0;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        --RECORRE LA TABLA PARA OBTENER LOS REGISTROS
        FOREACH curIterarRegistro WITH HOLD FOR

            SELECT Registro
                INTO vsRegistro
            FROM bditarjeta:"informix".td_carga_archivo_dep_atm

            --ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
            IF (vsFlagEnTransaccion = 'F') THEN 
                BEGIN WORK;
                LET vsFlagEnTransaccion = 'V';
            END IF;

            LET vsMensaje_Respuesta = 'INSERTAR REGISTRO EN LA TABLA CONCILIACION_ATM_STAT06_DEPOSITADORES.';
            
            IF (piTipoLayOut = 8) THEN 

                LET vsfechalocaldia = TRIM(SUBSTRING (vsRegistro FROM 179 FOR 2 )); --FECHA_dia
                LET vsfechalocalmes = TRIM(SUBSTRING (vsRegistro FROM 182 FOR 2 )); --FECHA_mes
                LET vshoralocalhr = TRIM(SUBSTRING (vsRegistro FROM 188 FOR 2 )); --hora
                LET vshoralocalmin = TRIM(SUBSTRING (vsRegistro FROM 191 FOR 2 )); -- minutos
                LET vsSecuencia = TRIM(SUBSTRING (vsRegistro FROM 25 FOR 6 )); -- numero de cajero
                LET vsSecuencia_extendida = vsfechalocaldia||vsfechalocalmes||vshoralocalhr||vshoralocalmin||vsIDSecuencia||vsSecuencia;


				INSERT INTO Intercard:"informix".conciliacion_atm_stat06_depositadores 
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

        UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".conciliacion_atm_stat06_depositadores;
        
        --BORRA LOS REGISTROS DEL ARCHIVO ALMACENADOS EN LA TABLA DE CARGA
        LET vsMensaje_Respuesta = 'BORRAR CONTENIDO DE td_carga_archivo_dep_atm.';
        
        BEGIN WORK;
            TRUNCATE TABLE bditarjeta:"informix".td_carga_archivo_dep_atm DROP STORAGE;
        COMMIT WORK;
        
        RETURN vsCodRet, vsMensaje_Respuesta, 2;

    END

END PROCEDURE
DOCUMENT
'Armando Garcia ',
'Coord. Admon. Tarjetas - Gerencia I ',
'Descripcion: Es implementado el commit por cada 1000 afectaciones',
'   en la tabla td_carga_archivo_dep_atm con el objetivo de disminuir los bloqueos',
'Fecha de modificaciÃ³n: 13 de agosto del 2021',
'BD: BdiTarjeta'
;

CREATE PROCEDURE "informix".sp_obtenerregistroarchivo_mc (
    psNomArchivo VARCHAR (30),     --  Nombre del archivo el cual se esta cargando
    psArchivoOrigen VARCHAR(3),    --  Abreviatura del archivo
    piTipoLayOut INTEGER,   --  Tipo de layout
    psCve_Usuario VARCHAR(10)      --  Usuario del sistema 
)

RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta, INTEGER AS Elemento;

    DEFINE viSQLerr 			INTEGER ;
    DEFINE vsCodRet 			VARCHAR(5);
    DEFINE vsMensaje_Respuesta 	VARCHAR(250);
    DEFINE vsRegistro 			CHAR(250); 
    DEFINE vsFlagEnTransaccion 	VARCHAR (1);
    DEFINE viContadorRegistros 	INTEGER;
    -- Para identificar el tipo de bin 
    DEFINE vsbin 				CHAR (6);
    -- Para recuperar desde carga número de cuenta Proceso Transfer
    DEFINE vscuenta 			CHAR (12);
    DEFINE vsnumtarjetaini 		CHAR(16);
    DEFINE vsMonto				VARCHAR(14); 
    DEFINE vsAmtLocal			VARCHAR(14); 
    DEFINE vsHora				VARCHAR(8); 
    DEFINE vsfechalocaldia CHAR(2);  -- Secuencia_extendida
    DEFINE vsfechalocalmes CHAR(2);  -- Secuencia_extendida
    DEFINE vshoralocalhr CHAR(2);  -- secuencia_extendida
    DEFINE vshoralocalmin  CHAR(2);  -- secuencia_extendida
    DEFINE vsIDSecuencia CHAR(1);  -- secuencia_extendida
    DEFINE vsSecuencia CHAR(6);  -- secuencia_extendida
    DEFINE vsSecuencia_extendida CHAR(15);  -- secuencia_extendida
 
    /* INICIALIZACION DE VARIABLES */
    LET viSQLerr = 0;    
    LET vsCodRet = '00000';
    LET vsMensaje_Respuesta = '';
    LET vsRegistro  = '';
    LET vsFlagEnTransaccion = '';
    LET viContadorRegistros = 0;
    -- Para identificar el tipo de bin 
    LET vsbin = '';
    -- Para recuperar desde carga número de cuenta
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
    
    BEGIN

        ON EXCEPTION SET viSQLerr

            IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                COMMIT WORK;
                LET vsFlagEnTransaccion = 'F';
            END IF

            --BORRA LOS REGISTROS DEL ARCHIVO ALMACENADOS EN LA TABLA DE CARGA
            BEGIN WORK;        
                TRUNCATE TABLE BdiTarjeta:"informix".Td_Carga_Archivo_mc DROP STORAGE;
            COMMIT WORK;

            --BORRA LOS REGISTROS QUE SE INSERTARON EN LA TABLA.
            BEGIN WORK;
                DELETE FROM BdiTarjeta:"informix".Td_Movimientos_Conciliacion_mc
                    WHERE NombreArchivo = psNomArchivo 
                        AND Archivo_Origen = psArchivoOrigen;
            COMMIT WORK;

            LET vsCodRet = '00200';	
            RETURN vsCodRet, ('[' || vsCodRet ||  ']ERROR NO CONTROLADO (' || viSQLerr || '). ARCHIVO (' || psNomArchivo || ') ' || TRIM(vsMensaje_Respuesta) ), 2;

        END EXCEPTION;


        LET vsFlagEnTransaccion = 'F';
        LET viContadorRegistros = 0;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        --RECORRE LA TABLA PARA OBTENER LOS REGISTROS
        FOREACH curRegistrosMC WITH HOLD FOR

            SELECT Registro
                INTO vsRegistro
            FROM BdiTarjeta:"informix".Td_Carga_Archivo_mc

            IF (piTipoLayOut = 1) THEN -- POS 325 INTERREDES, PRESTAMOS, CORRESPONSALES y PNC
                LET vsbin =  TRIM(SUBSTR (vsRegistro,33,6));
                LET vsnumtarjetaini = TRIM(SUBSTR (vsRegistro,33,16));

                LET vsMonto = TRIM(SUBSTR (vsRegistro,176,12));
                LET vsMonto = (vsMonto::MONEY)/100;


                LET vsAmtLocal = TRIM(SUBSTR (vsRegistro,220,12));
                LET vsAmtLocal = (vsAmtLocal::MONEY)/100;

                LET vsHora =TRIM(SUBSTR (vsRegistro,25,6));
                LET vsHora= SUBSTR(vsHora,1,2)||':'||SUBSTR(vsHora,3,2)||':'||SUBSTR(vsHora,5,2);

            END IF

            --  se obtiene numero de cuenta para regitrp
            IF psArchivoOrigen IN ('MCO') THEN

                SELECT FIRST 1 numcuenta 
                    INTO vscuenta 
                FROM Intercard:"informix".tarjetacuenta
                    WHERE  numcuenta != ''
                        AND numtarjeta = vsnumtarjetaini;

            END IF
            
            --ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
            IF (vsFlagEnTransaccion = 'F') THEN 
                 BEGIN WORK;
                 LET vsFlagEnTransaccion = 'V';
            END IF;
            
            LET vsMensaje_Respuesta = 'INSERTAR REGISTRO EN LA TABLA TD_MOVIMIENTOS_CONCILIACION/CONCILIACION_MASTERCARD_OXXO.';

            --  ########################## MASTERCARD - OXXO #############################################
            IF (piTipoLayOut = 1) THEN 
                
                LET vsfechalocaldia = TRIM(SUBSTRING (vsRegistro FROM 19 FOR 2 )); --FECHA_dia
                LET vsfechalocalmes = TRIM(SUBSTRING (vsRegistro FROM 21 FOR 2 )); --FECHA_mes
                LET vshoralocalhr = TRIM(SUBSTRING (vsRegistro FROM 25 FOR 2 )); --hora
                LET vshoralocalmin = TRIM(SUBSTRING (vsRegistro FROM 27 FOR 2 )); -- minutos
                LET vsSecuencia = TRIM(SUBSTRING (vsRegistro FROM 119 FOR 6 )); -- autorizacion
                
                LET vsSecuencia_extendida = vsfechalocaldia||vsfechalocalmes||vshoralocalhr||vshoralocalmin||vsIDSecuencia||vsSecuencia;
                
        
                INSERT INTO Intercard:"informix".conciliacion_mc_oxxo 
                ( 
                    fecha_conciliacion,
                    archivoorigen,
                    nombrearchivo,
                    tipo_txn,
                    num_serial_sw,
                    tipo_procesador,
                    id_procesador,
                    fecha_txn,
                    hora_txn,
                    length_pan,
                    num_tarjeta,
                    numcuenta,
                    cod_procesa,
                    num_seguimiento,
                    mcc,
                    pos_entry,
                    num_referencia,
                    id_adquirente,
                    id_terminal,
                    cod_respuesta,
                    marca,
                    formato_txn,
                    tipo_mnd_cambio,
                    autorizacion,
                    tipo_mnd,
                    num_decimal_txn,
                    monto_txn_completo,
                    monto_txn_completo_dc_cr,
                    cash_back,
                    cash_back_dr_cr,
                    cuota_por_txn,
                    cuota_por_txn_dr_cr,
                    cod_mnd_liq,
                    imp_decimal_set,
                    cnv_rate_set,
                    monto_txn,
                    tipo_deb_cred,
                    interch_fee,
                    interch_fee_dr_cr,
                    serv_lvl_ind,
                    codigo_respuesta,
                    pstv_id_ind,
                    crss_bord_ind,
                    crss_bord_crcy_ind,
                    rqst_amt_txn_local,
                    sec_extendida_archivo
                )
                VALUES 
                (
                    CURRENT,
                    TRIM(psArchivoOrigen),
                    TRIM(psNomArchivo),
                    TRIM(SUBSTRING (vsRegistro FROM 1 FOR 4 )), --tipo_txn          			
                    TRIM(SUBSTRING (vsRegistro FROM 5 FOR 9 )),	--num_serial_sw     			
                    TRIM(SUBSTRING (vsRegistro FROM 14 FOR 1 )), --tipo_procesador   			
                    TRIM(SUBSTRING (vsRegistro FROM 15 FOR 4 )), --id_procesador     			
                    TRIM(SUBSTRING (vsRegistro FROM 19 FOR 6 )), -- fecha_txn         			
                    vsHora, -- hora_txn          			
                    TRIM(SUBSTRING (vsRegistro FROM 31 FOR 2 )), -- length_pan        			
                    TRIM(SUBSTRING (vsRegistro FROM 33 FOR 19 )), -- num_tarjeta        			
                    TRIM(vscuenta), -- numcuenta          	        
                    TRIM(SUBSTRING (vsRegistro FROM 52 FOR 6 )), -- cod_procesa        			
                    TRIM(SUBSTRING (vsRegistro FROM 58 FOR 6 )), -- num_seguimiento    			
                    TRIM(SUBSTRING (vsRegistro FROM 64 FOR 4 )), -- mcc                			
                    TRIM(SUBSTRING (vsRegistro FROM 68 FOR 3 )), -- pos_entry          			
                    TRIM(SUBSTRING (vsRegistro FROM 71 FOR 12 )), -- num_referencia     			
                    TRIM(SUBSTRING (vsRegistro FROM 83 FOR 10 )), -- id_adquirente      			
                    TRIM(SUBSTRING (vsRegistro FROM 93 FOR 10 )), -- id_terminal        			
                    TRIM(SUBSTRING (vsRegistro FROM 103 FOR 2 )), -- cod_respuesta      			
                    TRIM(SUBSTRING (vsRegistro FROM 105 FOR 3 )), -- marca              			
                    TRIM(SUBSTRING (vsRegistro FROM 108 FOR 7 )), -- formato_txn        			
                    TRIM(SUBSTRING (vsRegistro FROM 115 FOR 4 )), -- tipo_mnd_cambio    			
                    TRIM(SUBSTRING (vsRegistro FROM 119 FOR 6 )), -- autorizacion       			
                    TRIM(SUBSTRING (vsRegistro FROM 125 FOR 3 )), -- tipo_mnd           			
                    TRIM(SUBSTRING (vsRegistro FROM 128 FOR 1 )), -- num_decimal_txn    			
                    TRIM(SUBSTRING (vsRegistro FROM 129 FOR 12 )), -- monto_txn_completo          
                    TRIM(SUBSTRING (vsRegistro FROM 141 FOR 1 )), -- monto_txn_completo_dc_cr    
                    TRIM(SUBSTRING (vsRegistro FROM 142 FOR 12 )), -- cash_back					
                    TRIM(SUBSTRING (vsRegistro FROM 154 FOR 1 )), -- cash_back_dr_cr				
                    TRIM(SUBSTRING (vsRegistro FROM 155 FOR 8 )),  -- cuota_por_txn               
                    TRIM(SUBSTRING (vsRegistro FROM 163 FOR 1 )), -- cuota_por_txn_dr_cr         
                    TRIM(SUBSTRING (vsRegistro FROM 164 FOR 3 )), -- cod_mnd_liq					
                    TRIM(SUBSTRING (vsRegistro FROM 167 FOR 1 )), -- imp_decimal_set             
                    TRIM(SUBSTRING (vsRegistro FROM 168 FOR 8 )), -- cnv_rate_set                
                    vsMonto, -- monto_txn                   
                    TRIM(SUBSTRING (vsRegistro FROM 188 FOR 1 )), -- tipo_deb_cred               
                    TRIM(SUBSTRING (vsRegistro FROM 189 FOR 10 )), -- interch_fee					
                    TRIM(SUBSTRING (vsRegistro FROM 199 FOR 1 )), -- interch_fee_dr_cr			
                    TRIM(SUBSTRING (vsRegistro FROM 200 FOR 3 )), -- serv_lvl_ind                
                    TRIM(SUBSTRING (vsRegistro FROM 203 FOR 2 )), -- codigo_respuesta            
                    TRIM(SUBSTRING (vsRegistro FROM 215 FOR 1 )), -- pstv_id_ind                 
                    TRIM(SUBSTRING (vsRegistro FROM 217 FOR 1 )), -- crss_bord_ind               
                    TRIM(SUBSTRING (vsRegistro FROM 218 FOR 1 )), -- crss_bord_crcy_ind          
                    vsAmtLocal, -- rqst_amt_txn_local  
                    vsSecuencia_extendida
                );

                --Se agrega la Inserción en td_movimientos_conciliación para registros del Stat06 LAGS
                INSERT INTO BdiTarjeta:"informix".Td_Movimientos_Conciliacion_mc
                (
                    NombreArchivo,
                    Archivo_Origen,
                    id_procesador,
                    NumTarjeta,
                    ban_bin,
                    Secuencia325,
                    Monto325,
                    MontoSurcharge325,
                    NumCuenta,
                    estransfer,
                    IdComercio325,
                    NomComercio325,
                    TipoTransaccion325,
                    Referencia23_325,
                    RFC325,
                    Divisa325,
                    Monto_Divisa325,
                    ISO323, 
                    MovRev325,
                    Cve_Usuario,
                    sec_extendida_archivo
                )
                VALUES
                (
                    psNomArchivo,
                    psArchivoOrigen,
                    CASE 	
                        WHEN  	TRIM(SUBSTRING (vsRegistro FROM 15 FOR 4 )) = '2249' THEN  'OXXO' 
                        WHEN  	TRIM(SUBSTRING (vsRegistro FROM 15 FOR 4 )) = '2588' THEN  'SEVEN'
                        ELSE
                            '  '
                    END,  --id_procesador
                    TRIM(SUBSTRING (vsRegistro FROM 33 FOR 19 )), -- num_tarjeta
                    vsbin,
                    TRIM(SUBSTRING (vsRegistro FROM 119 FOR 6 )), -- autorizacion 
                    vsMonto,  --MONTO
                    TRIM(SUBSTRING (vsRegistro FROM 189 FOR 10 )), -- interch_fee
                    TRIM(vscuenta), -- numcuenta
                    '',
                    TRIM(SUBSTRING (vsRegistro FROM 83 FOR 10 )), -- id_adquirente
                    '',  --NOMCOMERCIO
                    TRIM(SUBSTRING (vsRegistro FROM 1 FOR 4 )), --TIPOTRANSACCION
                    TRIM(SUBSTRING (vsRegistro FROM 71 FOR 12 )), -- num_referencia
                    '',  --RFC
                    TRIM(SUBSTRING (vsRegistro FROM 125 FOR 3 )), -- tipo_mnd
                    vsAmtLocal,
                    '', 
                    '', 
                    psCve_Usuario,
                    vsSecuencia_extendida
                );
                
                    
            END IF;
            
            LET viContadorRegistros = viContadorRegistros + 2;
            LET vsMensaje_Respuesta = 'TERMINAR TRANSACCION';
            
            IF (viContadorRegistros >= 1000) THEN
                COMMIT WORK;
                LET vsFlagEnTransaccion = 'F';
                LET viContadorRegistros = 0;
                CONTINUE FOREACH;
            END IF;
            
        END FOREACH;
        
        UPDATE STATISTICS MEDIUM FOR TABLE bditarjeta:"informix".td_movimientos_conciliacion_mc;
        UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".conciliacion_mc_oxxo;
        
        
        LET vsMensaje_Respuesta = 'TERMINAR TRANSACCION';
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN
            COMMIT WORK;
            LET vsFlagEnTransaccion = 'F';
        END IF;

        LET vsMensaje_Respuesta = 'BORRAR CONTENIDO DE Td_Carga_Archivo_mc.';
        BEGIN WORK;
            TRUNCATE TABLE BdiTarjeta:"informix".Td_Carga_Archivo_mc DROP STORAGE;
        COMMIT WORK;
    
        LET vsMensaje_Respuesta = '';
        RETURN vsCodRet, vsMensaje_Respuesta, 2;

    END

END PROCEDURE
DOCUMENT
'AUTOR : Victoria Quiñones',
'FECHA : 09/06/2018',
'SISTEMA : Conciliacion MasterCard-- Automatico',
'DESCRIPCION:  CARGA LA INFORMACION SIGNIFICATIVA DE LOS REGISTROS A LA TABLA TD_MOVIMIENTOS_CONCILIACION',
'BD: BdiTarjeta',
'#2',
'Armando Garcia ',
'Coord. Admon. Tarjetas - Gerencia I ',
'Descripcion: Es implementado el commit por cada 1000 afectaciones',
'   en la tabla td_movimientos_conciliacion con el objetivo de disminuir los bloqueos',
'Fecha de modificación: 18 de agosto del 2021',
'BD: BdiTarjeta'
;

CREATE PROCEDURE "informix".sp_obtenerregistroarchivo_colaborapp (
psNomArchivo VARCHAR (30),     
psArchivoOrigen VARCHAR(3),   
piTipoLayOut INTEGER, 		   
psCve_Usuario VARCHAR(10)       
)

RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta, INTEGER AS Elemento;
---
DEFINE viSQLerr 				INTEGER ;
DEFINE vsCodRet 				VARCHAR(5);
DEFINE vsMensaje_Respuesta 		VARCHAR(250);	
DEFINE vsRegistro 				CHAR(500); 
DEFINE vsFlagEnTransaccion 		VARCHAR (1);
DEFINE viContadorRegistros 		INTEGER;

     --SET DEBUG FILE TO "/informix/mgap/trace_registros_colaborapp.out";
	 --TRACE ON;

/* INICIALIZACION DE VARIABLES */
LET viSQLerr = 0;    
LET vsCodRet = '00000';
LET vsMensaje_Respuesta = '';
LET vsRegistro  = '';
LET vsFlagEnTransaccion = '';
LET viContadorRegistros = 0;

BEGIN

ON EXCEPTION SET viSQLerr
	
	-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
	IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
		COMMIT WORK;
		LET vsFlagEnTransaccion = 'F';
	END IF;
	
	BEGIN WORK;
	--BORRA LOS REGISTROS DEL ARCHIVO ALMACENADOS EN LA TABLA DE CARGA
	DELETE FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp;
	COMMIT WORK;
	
	
	LET vsCodRet = '00200';	
	RETURN vsCodRet, ('[' || vsCodRet ||  ']ERROR NO CONTROLADO (' || viSQLerr || '). ARCHIVO (' || psNomArchivo || ') ' || TRIM(vsMensaje_Respuesta) ), 2;
	
END EXCEPTION;
	
	
	LET vsFlagEnTransaccion = 'F';
	LET viContadorRegistros = 0;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	
	IF (piTipoLayOut = 9) THEN 
	 ELSE 
	  LET vsMensaje_Respuesta = 'ERROR LAYOUT';
	  LET vsCodRet = '00100';
	  RETURN vsCodRet, vsMensaje_Respuesta, 2;
	END IF; 
	 -- begin 
	DELETE FROM  bditarjeta:"informix".conciliacion_depositos_colaborapp  WHERE nombrearchivo = psNomArchivo; 	

	 LET vsMensaje_Respuesta = 'INSERTAR REGISTRO EN LA TABLA CONCILIACION_COLABORAPP';
	--RECORRE LA TABLA PARA OBTENER LOS REGISTROS
	FOREACH WITH HOLD 
	
		SELECT Registro	INTO vsRegistro
		FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp
		
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			
			IF (vsFlagEnTransaccion = 'F') THEN 
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;
			
			--   DEPOSITOS COLABORAPP 
			--IF (piTipoLayOut = 9) THEN 
				INSERT INTO bditarjeta:"informix".conciliacion_depositos_colaborapp
				( 
				   fecha_conciliacion,
				   archivoorigen,
				   nombrearchivo,
				   banco_emisor,
				   banco_receptor,
				   folio,
				   tipo_txn,
				   importe_total,
				   forma_pago,
				   fecha_proceso,
				   referencia_txn,
				   secuencia_aut,
				   fecha_consumo,
				   colaborador
				 ) 
				VALUES 
				(
					CURRENT, -- fecha_conciliacion
					TRIM(psArchivoOrigen), -- archivoorigen
					TRIM(psNomArchivo), -- nombrearchivo
					TRIM(SUBSTRING (vsRegistro FROM 1 FOR 2 )),  -- banco emisor,
					TRIM(SUBSTRING (vsRegistro FROM 3 FOR 2 )),  -- banco receptor,
					TRIM(SUBSTRING (vsRegistro FROM 5 FOR 16 )),  -- Folio,
					TRIM(SUBSTRING (vsRegistro FROM 21 FOR 2 )),  -- tipo_txn,
					--TRIM(SUBSTRING (vsRegistro FROM 23 FOR 13 )),  -- importe  
					(((SUBSTR(vsregistro,23,13))::MONEY)/100),  --importe 
					TRIM(SUBSTRING (vsRegistro FROM 36 FOR 2 )),   -- forma_pago,
					TRIM(SUBSTRING (vsRegistro FROM 38 FOR 6 )),   -- fecha_proceso
					TRIM(SUBSTRING (vsRegistro FROM 44 FOR 24 )),   --  Referencia 
					TRIM(SUBSTRING (vsRegistro FROM 68 FOR 6 )),   --  autorizacion 
					TRIM(SUBSTRING (vsRegistro FROM 74 FOR 6 )),   --  Fecha_consumo  
					TRIM(SUBSTRING (vsRegistro FROM 80 FOR 9 ))   -- colaborador 
					);
				   
					 			
			--END IF;
			
			--IF (piTipoLayOut = 9) THEN
		--	LET viContadorRegistros = viContadorRegistros + 2;
			--ELSE 
			LET viContadorRegistros = viContadorRegistros + 1;
			
			--END IF;
			--LET vsMensaje_Respuesta = 'TERMINAR TRANSACCION';
			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros >= 1000) THEN --VERIFICA SI ALCANZO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;
		
	END FOREACH;
	
	LET vsMensaje_Respuesta = 'TERMINAR TRANSACCION';
	-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
	IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
		COMMIT WORK;
		LET vsFlagEnTransaccion = 'F';
	END IF;
	
		UPDATE STATISTICS MEDIUM FOR TABLE bditarjeta:"informix".conciliacion_depositos_colaborapp;
	
	LET vsMensaje_Respuesta = 'BORRAR CONTENIDO DE td_carga_archivo_colaborapp.';
	BEGIN WORK;	
	LET vsFlagEnTransaccion = 'V';
	--BORRA LOS REGISTROS DEL ARCHIVO ALMACENADOS EN LA TABLA DE CARGA
	TRUNCATE TABLE BdiTarjeta:"informix".td_carga_archivo_colaborapp DROP STORAGE;
	
	COMMIT WORK;
	
	LET vsFlagEnTransaccion = 'F';
	LET vsMensaje_Respuesta = '';
		
	RETURN vsCodRet, vsMensaje_Respuesta, 2;
	
END

END PROCEDURE;