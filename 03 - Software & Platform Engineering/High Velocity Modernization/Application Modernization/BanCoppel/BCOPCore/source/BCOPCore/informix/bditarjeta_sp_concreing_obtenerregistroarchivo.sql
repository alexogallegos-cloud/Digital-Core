CREATE PROCEDURE "informix".sp_concreing_obtenerregistroarchivo (
psNomArchivo VARCHAR (23),     --  Nombre del archivo el cual se esta cargando
psArchivoOrigen VARCHAR(3),    --  Abreviatura del archivo
piTipoLayOut INTEGER, 		   --  Tipo de layout
psCve_Usuario VARCHAR(10)      --  Usuario del sistema 
)

RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta, INTEGER AS Elemento;

--****************************************************************************************************
-- DESCRIPCION:  CARGA LA INFORMACION SIGNIFICATIVA DE LOS REGISTROS A LA TABLA TD_MOVIMIENTOS_CONCILIACION
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 21/06/2011
-- BD: BdiTarjeta
-- SISTEMA : Reingenieria Conciliacion -- Automatico
-- MODIFICADO : 
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */

DEFINE viSQLerr 				INTEGER ;
DEFINE vsCodRet 				VARCHAR(5);
DEFINE vsMensaje_Respuesta 		VARCHAR(250);	
DEFINE vsRegistro 				CHAR(500);  		-- Se actualizo de 325 a 500
DEFINE vsfechalocaldia 			CHAR(2);  			
DEFINE vsfechalocalmes 			CHAR(2);  			
DEFINE vshoralocalhr 			CHAR(2);  			
DEFINE vshoralocalmin  			CHAR(2);  			
DEFINE vsIDSecuencia 			CHAR(1);  			
DEFINE vsSecuencia 				CHAR(6);  			
DEFINE vsSecuencia_extendida 	CHAR(15);  			

-- Para CashBack
DEFINE vsRegistroMontototal 		Char(13);
DEFINE vsRegistroMontoCashBack 		Char (13);
DEFINE vsRegistroComprareal 		Char(13);
DEFINE viconcaracteres 				integer;
define a 							integer;
DEFINE vmRegistroMontototal 		money;
DEFINE vmRegistroMontoCashBack 		money;
DEFINE vmRegistroComprareal 		money;

DEFINE vsFlagEnTransaccion 			VARCHAR (1);
DEFINE viContadorRegistros 			INTEGER;

-- Para identificar el tipo de bin 
DEFINE vsbin 					char (6);
DEFINE vsbbin 					char (3);
DEFINE vstpotarjeta 			char(1);
DEFINE vsprefijo 				char(10);
DEFINE vsfoliocorresponsales 	char(16); -- Para extraer folio suc
DEFINE vsnumtarjeta 			char(16);
DEFINE vsnocredito 				char(20);
DEFINE vsinicredito 			char(1);

-- Para recuperar desde carga nÃÂÃÂºmero de cuenta Proceso Transfer
Define vscuenta 				char (12);
define vsnumtarjetaini 			char(16);
define vsvalor 					char(90);
define vsestransfer 			char(1);

/* Variable para cajeros idenfificar bines no propios */
DEFINE vsCompania 				CHAR (01);

--Fechas para identificar procesos en layout 1 y 6 Coppel Pay
DEFINE dFechaProceso 			DATETIME YEAR to SECOND;
DEFINE dFechaReproceso 			DATETIME YEAR to SECOND;
DEFINE dFechaProcesoAux 		DATETIME YEAR to SECOND;
DEFINE iTotRegistrosAux 		INTEGER;
DEFINE iTotRegEglobal 			INTEGER;	

	--SET DEBUG FILE TO "/informix/LVRQ/SecuenciayATM/debug/obtieneregistro.out";
	--TRACE ON;

/* INICIALIZACION DE VARIABLES */
LET viSQLerr 				= 0;    
 
LET vsCodRet 				= '00000';
LET vsMensaje_Respuesta 	= '';
LET vsRegistro  			= '';
LET vsfechalocaldia 		= '';  
LET vsfechalocalmes 		= '';  
LET vshoralocalhr 			= '';  
LET vshoralocalmin 			= '';  
LET vsIDSecuencia 			= '1';  
LET vsSecuencia 			= '';  
LET vsSecuencia_extendida 	= '';  


--Para CashBack
LET vsRegistroMontototal 	= '';
LET vsRegistroMontoCashBack = '';
LET vsRegistroComprareal 	= '';
LET viconcaracteres 		= 0;
let a 						= 0;
LET vmRegistroMontototal 	= 0.0;
LET vmRegistroMontoCashBack = 0.0;
LET vmRegistroComprareal 	= 0.0;

LET vsFlagEnTransaccion 	= '';
LET viContadorRegistros 	= 0;

-- Para identificar el tipo de bin 
LET vsbin 						= '';
LET vsbbin 						= '';
LET vstpotarjeta 				= '';
LET vsprefijo 					= '';
LET vsfoliocorresponsales 		= '';
LET vsnumtarjeta 				= '';
let vsnocredito 				= '';
let vsinicredito 				= '';

-- Para recuperar desde carga numero de cuenta
let vscuenta 			= '';
let vsnumtarjetaini 	= '';
let vsvalor 			= '';
let	vsestransfer 		= '';

/* Variable para cajeros idenfificar bines no propios */
LET vsCompania 	= '';

--Fechas para identificar procesos en layout 1 y 6 Coppel Pay
LET dFechaProceso = CURRENT;
LET dFechaReproceso = CURRENT;
LET iTotRegistrosAux = 0;
LET iTotRegEglobal = 0;

BEGIN

ON EXCEPTION SET viSQLerr
	--SET DEBUG FILE TO "/RESPALDOSNEW/exc_sp_cnc_obtener_registro_archivo.err.out" WITH APPEND;
            --TRACE ON;
            TRUNCATE TABLE bditarjeta:"informix".td_carga_archivo DROP STORAGE;
	-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
            BEGIN WORK;
                DELETE FROM BdiTarjeta:"informix".Td_Movimientos_Conciliacion 
                    WHERE NombreArchivo = psNomArchivo 
                        AND Archivo_Origen = psArchivoOrigen;
	-- TERMINA EL ULTIMO BLEQUE DE TRANSACCIONPENDIENTE PARA TABLA td_movimientos_cnc_coppel_pay.								
				DELETE FROM BdiTarjeta:"informix".td_movimientos_cnc_coppel_pay 
                    WHERE NombreArchivo = psNomArchivo 
                        AND Archivo_Origen = psArchivoOrigen;                  		
            COMMIT
 WORK;
	IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
		COMMIT WORK;
		LET vsFlagEnTransaccion = 'F';
	END IF;
	
	BEGIN WORK;
	--BORRA LOS REGISTROS DEL ARCHIVO ALMACENADOS EN LA TABLA DE CARGA
	TRUNCATE TABLE BdiTarjeta:"informix".Td_Carga_Archivo;
	COMMIT WORK;
	
	BEGIN WORK;
	--BORRA LOS REGISTROS QUE SE INSERTARON EN LA TABLA.
	DELETE FROM BdiTarjeta:"informix".Td_Movimientos_Conciliacion WHERE NombreArchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;
	--BORRA LOS REGISTROS QUE SE INSERTARON EN LA TABLA td_movimientos_cnc_coppel_pay.
	DELETE FROM BdiTarjeta:"informix".td_movimientos_cnc_coppel_pay WHERE NombreArchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;
	COMMIT WORK;
	
	LET vsCodRet = '00200';	
	RETURN vsCodRet, ('[' || vsCodRet ||  ']ERROR NO CONTROLADO (' || viSQLerr || '). ARCHIVO (' || psNomArchivo || ') ' || TRIM(vsMensaje_Respuesta) ), 2;
	
END EXCEPTION;
	
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
	
	LET vsFlagEnTransaccion = 'F';
	LET viContadorRegistros = 0;
	
	SELECT COUNT(*) 
	INTO iTotRegEglobal
	FROM td_carga_archivo; 
	
	SELECT COUNT(*) 
	INTO iTotRegistrosAux
	FROM Td_Movimientos_Conciliacion 
	WHERE NombreArchivo = psNomArchivo 
	AND Archivo_Origen = psArchivoOrigen;

	IF iTotRegistrosAux = iTotRegEglobal AND iTotRegEglobal <> 0 THEN
	
		--REPROCESO.
		SELECT FIRST 1
		fecha_proceso
		INTO dFechaProcesoAux
		FROM td_movimientos_cnc_coppel_pay 
		WHERE NombreArchivo = psNomArchivo 
		AND Archivo_Origen = psArchivoOrigen;
		
		DELETE FROM Td_Movimientos_Conciliacion 
		WHERE NombreArchivo = psNomArchivo 
		AND Archivo_Origen = psArchivoOrigen;
		
		DELETE FROM td_movimientos_cnc_coppel_pay 
		WHERE NombreArchivo = psNomArchivo 
		AND Archivo_Origen = psArchivoOrigen;
	
	end if
	
    FOREACH curRegistrar WITH HOLD FOR

		-- RECORRE LA TABLA PARA OBTENER LOS REGISTROS
		-- Esta tabla es de paso, y se emplea para carga la informacion de los archivos de conciliacion
		-- solo tiene un campo, por tanto es esperado el sequential scan
		SELECT Registro
			INTO vsRegistro
		FROM BdiTarjeta:"informix".Td_Carga_Archivo
		
		IF (vsFlagEnTransaccion = 'F') THEN 
			 BEGIN WORK;
			 LET vsFlagEnTransaccion = 'V';
		END IF;

		IF (piTipoLayOut = 1) THEN -- POS 325 INTERREDES, PRESTAMOS, CORRESPONSALES y PNC
			LET vsbin =  TRIM(SUBSTR (vsRegistro,5,6));
			LET vsnumtarjetaini = TRIM(SUBSTR (vsRegistro,5,16));
		elif (piTipoLayOut = 2) THEN -- ATM EGLOBAL
			LET vsbin =  TRIM(SUBSTR (vsRegistro,25,6));
			LET vsnumtarjetaini = TRIM(SUBSTR (vsRegistro,25,16));
		elif (piTipoLayOut = 3) THEN -- ATM PROSA
			LET vsbin =  TRIM(SUBSTR (vsRegistro,25,6));
			LET vsnumtarjetaini = TRIM(SUBSTR (vsRegistro,25,16));
		elif ((piTipoLayOut = 4) or (piTipoLayOut = 7)) THEN -- ATM BANCOPPEL y ATM IST
			LET vsbin =  TRIM(SUBSTR (vsRegistro,37,6));
			LET vsnumtarjetaini = TRIM(SUBSTR (vsRegistro,37,16));
		elif (piTipoLayOut = 6) THEN -- POS 500 DOMESTICOS E INTERNACIONALES VISA y MASTERCARD 
			LET vsbin =  TRIM(SUBSTR (vsRegistro,5,6));
			LET vsnumtarjetaini = TRIM(SUBSTR (vsRegistro,5,16));
		END IF
	
		-- ##################################  Para llenar el campo de Numero de cuenta relacionado a la tarjeta y preveer los campos 0 #################
		if psArchivoOrigen not in ('CCP', 'CCD', 'TPD') then
			
			-- OBTENCION DE NUMERO CUENTA DEBIDO A QUE TRAIA MAS DE UNA CUENTA EL REGISTRO 
			SELECT FIRST 1 numcuenta  
				INTO vscuenta 
			FROM Intercard:"informix".tarjetacuenta
			where  numcuenta != ''
			AND numtarjeta = vsnumtarjetaini;
		END IF

		if vscuenta is null or vscuenta = '' then
			let vscuenta = '000000000000';
		END IF
		
		SELECT TRIM(valor) 
			INTO vsvalor 
		FROM bditarjeta:"informix".td_param_conciliacion_concreing
		WHERE codigo = '701' 
		AND descripcion LIKE '%TRANSFER%';
		
		if trim(substr(vscuenta,1,1)) = vsvalor then 
			let vsestransfer = 'V';
		else 
			let vsestransfer = 'F';
		END IF
			
		--  #################################   Para proceso de identificacion de BIN en Corresponsales ################################ 27062014
		IF ( psArchivoOrigen = 'CCP' ) THEN
			let vsfoliocorresponsales = TRIM(SUBSTR (vsRegistro,5,16));

			SELECT FIRST 1 nro_tarjeta, num_credito 
				INTO vsnumtarjeta, vsnocredito 
			FROM bdicred:"informix".sd_movhis
			WHERE folio_suc = vsfoliocorresponsales 
			AND referencia LIKE 'TIENDA%';
					
			if ((vsnumtarjeta is null) or (vsnumtarjeta = '')) then 
				-- ######    Para recuperar la ultima tarjeta relacionada con el credito cuando es titular y esta activa ###############
				SELECT SKIP 0 FIRST 1  num_tarjeta 
					INTO vsnumtarjeta 
				FROM Bdicred:"informix".sd_tarjeta
				WHERE num_credito = vsnocredito
				AND tipo_tarjeta = 'T'; 
				
				--order by secuencia desc; se uso skip para realizar misma funcion 
				if (vsnumtarjeta is null) or (vsnumtarjeta = '')  then 
					let vsbin = 'NPT';
				else 
					let vsbin = trim(substr(vsnumtarjeta,1,6));
				END IF
				-- ######################################################################################################################
			else
				let vsbin = trim(substr(vsnumtarjeta,1,6));		
			END IF
	
		elif psArchivoOrigen = 'CCD' then 
		
			let vsfoliocorresponsales = TRIM(SUBSTR (vsRegistro,5,16));
		
			SELECT FIRST 1 num_tarjeta 
				INTO vsnumtarjeta 
			FROM bdicheq:"informix".sc_movhis
			WHERE folio_suc = vsfoliocorresponsales 
			AND referencia LIKE 'TIENDA%';
			
			if vsnumtarjeta is null or vsnumtarjeta = '' then 
					let vsbin = 'NPT';
			else
				let vsbin = trim(substr(vsnumtarjeta,1,6));
			END IF
			-- ###############################################################################################################################
		END IF
		
		if (vsbin <> 'NPT')  then
			select creditodebito, prefijo 
			into vstpotarjeta, vsprefijo 
			from Intercard:"informix".bines 
			where bin = vsbin;
		END IF

		if ((vsbin <> '') and (vsbin <> 'NPT')) then
			LET vsbbin = 	
			CASE 	
				WHEN (vstpotarjeta = 'D') and (vsprefijo = 'DEBC') THEN 
					'VDE' 	--VISA DEBITO
				WHEN (vstpotarjeta = 'C') and (vsprefijo = 'CRED') THEN 
					'VCR'	-- VISA CREDITO
				WHEN ((vstpotarjeta = 'D') and (vsprefijo = 'MDP')) OR ((vstpotarjeta = 'D') and (vsprefijo = 'MPG')) THEN 
					'MDE'	--  MASTERCARD DEBITO
				WHEN ((vstpotarjeta = 'C') and (vsprefijo = 'MPL')) OR ((vstpotarjeta = 'C') and (vsprefijo = 'MSC')) OR  ((vstpotarjeta = 'C') and (vsprefijo = 'MCPL'))THEN 
					'MCR'	--  MASTERCARD CREDITO
				ELSE 
					'BNI'
			END;
		elif vsbin = 'NPT' then
			LET vsbbin = 'NPT';
		else
			LET vsbbin = 'BNI';
		end if;
	
		--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (vsFlagEnTransaccion = 'F') THEN 
			 BEGIN WORK;
			 LET vsFlagEnTransaccion = 'V';
		END IF;
		
		LET vsMensaje_Respuesta = 'INSERTAR REGISTRO EN LA TABLA TD_MOVIMIENTOS_CONCILIACION/CONCILIACION_ATM_STAT06.';
		
		IF (piTipoLayOut = 1) THEN -- POS325
			
			--FECHA DE CONSUMO AAMMDD
			LET vsfechalocaldia = TRIM(SUBSTRING (vsRegistro FROM 238 FOR 2 )); --FECHA_dia
			LET vsfechalocalmes = TRIM(SUBSTRING (vsRegistro FROM 236 FOR 2 )); --FECHA_mes
			
			-- HORA DE LA TRANSACCION
			LET vshoralocalhr 	='00'; --TRIM(SUBSTRING (vsRegistro FROM 186 FOR 2 )); --hora y minutos				
			LET vshoralocalmin 	='00'; --TRIM(SUBSTRING (vsRegistro FROM 188 FOR 2 )); -- minutos
			
			--Numero de autorizacion
			LET vsSecuencia	 	= TRIM(SUBSTRING (vsRegistro FROM 210 FOR 6 )); -- autorizacion

			LET vsSecuencia_extendida = vsfechalocalmes||vsfechalocaldia||vshoralocalhr||vshoralocalmin||vsIDSecuencia||vsSecuencia;

			-- ###################### PROCESO PARA GUARDAR MONTO REAL DE COMPRA ###################################
			LET vsRegistroMontoCashBack = TRIM(SUBSTR(vsRegistro, 52,13)); -- MONTO CASH BACK;
			
			IF ( vsRegistroMontoCashBack <> '0000000000000' ) THEN --IF vmRegistroMontoCashBack > 0.0 THEN
				LET vsRegistroMontototal 	= TRIM(SUBSTRING (vsRegistro FROM 39 FOR 13 ));
				LET	vmRegistroMontototal 	= (( REPLACE( vsRegistroMontototal,'.',''))::MONEY/100 );
				LET vmRegistroMontoCashBack = (( REPLACE( vsRegistroMontoCashBack,'.',''))::MONEY/100 );
				LET vmRegistroComprareal 	= vmRegistroMontototal - vmRegistroMontoCashBack;
				LET vsRegistroComprareal 	= CAST(vmRegistroComprareal as CHAR(13));
				LET vsRegistroComprareal 	= REPLACE(REPLACE(vsRegistroComprareal,'$',''),'.',''); 
				LET viconcaracteres 		= Length(vsRegistroComprareal);
				
				FOR  a = viconcaracteres  TO 12 STEP 1
					LET vsRegistroComprareal = '0'||vsRegistroComprareal;
				END FOR
			END IF

		
		IF iTotRegistrosAux = iTotRegEglobal AND iTotRegEglobal <> 0 THEN
			
			INSERT INTO BdiTarjeta:"informix".Td_Movimientos_Conciliacion 
				(
				NombreArchivo,
				Archivo_Origen,
				NumTarjeta,
				ban_bin,
				Secuencia325,
				Monto325,
				montocashback325,
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
				Cve_Usuario
				)
				VALUES
				(
				psNomArchivo,
				psArchivoOrigen,
				TRIM(SUBSTRING (vsRegistro FROM 5 FOR 16 )), --NUMTARJETA
				vsbbin,
				TRIM(SUBSTRING (vsRegistro FROM 210 FOR 6 )), --SECUENCIAAUTH
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 52,13))) <> '0000000000000' THEN 
							vsRegistroComprareal --monto compra real menos cashback
						ELSE 
							(TRIM(SUBSTR(vsRegistro, 39,13))) --monto compra
						END, 
				TRIM(SUBSTR(vsRegistro, 52,13)), -- MONTO CASH BACK
				TRIM(SUBSTRING (vsRegistro FROM 78 FOR 1 )), --MONTOSURCHARGE325 / FORMADEPAGO [PNC]
				CASE 	WHEN psArchivoOrigen not in ('CCP', 'CCD', 'TPD') then -- Para poner valor original 
							trim(vscuenta) --NUMCUENTA
						else
							' '
						end,
				trim(vsestransfer),
				TRIM(SUBSTRING (vsRegistro FROM 95 FOR 9 )),  --IDCOMERCIO
				TRIM(SUBSTRING (vsRegistro FROM 104 FOR 30 )),  --NOMCOMERCIO
				TRIM(SUBSTRING (vsRegistro FROM 37 FOR 2 )),  --TIPOTRANSACCION
				TRIM(SUBSTRING (vsRegistro FROM 142 FOR 23 )),  --REFTRANSACCION
				TRIM(SUBSTRING (vsRegistro FROM 216 FOR 16 )),  --RFC
				TRIM(SUBSTRING (vsRegistro FROM 309 FOR 3 )),  --DIVISA
				TRIM(SUBSTRING (vsRegistro FROM 292 FOR 11 )),  --MONTODIVISA
				'', --ISO325 
				'', --MOVREV325 
				psCve_Usuario
				);

				-- llenado de tabla td_movimientos_cnc_coppel_pay separando campos nuevos 
				--Filtrando por nommbre de archivo origen y por bin
				IF (psArchivoOrigen = 'PNC' AND TRIM(SUBSTRING (vsRegistro FROM 5 FOR 6 )) = '514014') THEN
					INSERT INTO BdiTarjeta:"informix".td_movimientos_cnc_coppel_pay 
					(	
						NombreArchivo,
						Archivo_Origen,
						referencia23_325,
						banco_receptor,
						banco_emisor,
						num_autorizacion,
						secuencia_extendida,-- SE LLENA PARA MOSTRAR EN PAGOS INTERBANCARIOS
						fecha_proceso,
						fecha_reproceso,
						conciliacionCoppel

					)
					VALUES
					(
						psNomArchivo,
						psArchivoOrigen,
						TRIM(SUBSTRING (vsRegistro FROM 142 FOR 23 )),  -- REFTRANSACCION
						TRIM(SUBSTRING (vsRegistro FROM 3 FOR 2 )),		-- Banco Adquiriente (receptor)****banco_receptor****
						TRIM(SUBSTRING (vsRegistro FROM 1 FOR 2 )), 	-- Banco emisor*******banco_emisor***********
						TRIM(SUBSTRING (vsRegistro FROM 210 FOR 6 )), 	-- NÃÂºmero de AutorizaciÃÂ³n****num_autorizacion****
						vsSecuencia_extendida,
						dFechaProcesoAux,
						dFechaReproceso,
						'P'
					);
				END IF
		
	ELSE

		INSERT INTO BdiTarjeta:"informix".Td_Movimientos_Conciliacion 
		(
		NombreArchivo,
		Archivo_Origen,
		NumTarjeta,
		ban_bin,
		Secuencia325,
		Monto325,
		montocashback325,
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
		Cve_Usuario
		)
		VALUES
		(
		psNomArchivo,
		psArchivoOrigen,
		TRIM(SUBSTRING (vsRegistro FROM 5 FOR 16 )), --NUMTARJETA
		vsbbin,
		TRIM(SUBSTRING (vsRegistro FROM 210 FOR 6 )), --SECUENCIAAUTH
		CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 52,13))) <> '0000000000000' THEN 
					vsRegistroComprareal --monto compra real menos cashback
				ELSE 
					(TRIM(SUBSTR(vsRegistro, 39,13))) --monto compra
				END, 
		TRIM(SUBSTR(vsRegistro, 52,13)), -- MONTO CASH BACK
		TRIM(SUBSTRING (vsRegistro FROM 78 FOR 1 )), --MONTOSURCHARGE325 / FORMADEPAGO [PNC]
		CASE 	WHEN psArchivoOrigen not in ('CCP', 'CCD', 'TPD') then -- Para poner valor original 
					trim(vscuenta) --NUMCUENTA
				else
					' '
				end,
		trim(vsestransfer),
		TRIM(SUBSTRING (vsRegistro FROM 95 FOR 9 )),  --IDCOMERCIO
		TRIM(SUBSTRING (vsRegistro FROM 104 FOR 30 )),  --NOMCOMERCIO
		TRIM(SUBSTRING (vsRegistro FROM 37 FOR 2 )),  --TIPOTRANSACCION
		TRIM(SUBSTRING (vsRegistro FROM 142 FOR 23 )),  --REFTRANSACCION
		TRIM(SUBSTRING (vsRegistro FROM 216 FOR 16 )),  --RFC
		TRIM(SUBSTRING (vsRegistro FROM 309 FOR 3 )),  --DIVISA
		TRIM(SUBSTRING (vsRegistro FROM 292 FOR 11 )),  --MONTODIVISA
		'', --ISO325 
		'', --MOVREV325 
		psCve_Usuario
		);

		-- llenado de tabla td_movimientos_cnc_coppel_pay separando campos nuevos 
		--Filtrando por nommbre de archivo origen y por bin
		IF (psArchivoOrigen = 'PNC' AND TRIM(SUBSTRING (vsRegistro FROM 5 FOR 6 )) = '514014') THEN
			INSERT INTO BdiTarjeta:"informix".td_movimientos_cnc_coppel_pay 
			(	
				NombreArchivo,
				Archivo_Origen,
				referencia23_325,
				banco_receptor,
				banco_emisor,
				num_autorizacion,
				secuencia_extendida,-- SE LLENA PARA MOSTRAR EN PAGOS INTERBANCARIOS
				fecha_proceso,
				conciliacionCoppel

			)
			VALUES
			(
				psNomArchivo,
				psArchivoOrigen,
				TRIM(SUBSTRING (vsRegistro FROM 142 FOR 23 )),  -- REFTRANSACCION
				TRIM(SUBSTRING (vsRegistro FROM 3 FOR 2 )),		-- Banco Adquiriente (receptor)****banco_receptor****
				TRIM(SUBSTRING (vsRegistro FROM 1 FOR 2 )), 	-- Banco emisor*******banco_emisor***********
				TRIM(SUBSTRING (vsRegistro FROM 210 FOR 6 )), 	-- NÃÂºmero de AutorizaciÃÂ³n****num_autorizacion****
				vsSecuencia_extendida,
				dFechaProceso,
				'P'
			);
		END IF
	END IF
				
		ELIF (piTipoLayOut = 2) THEN -- ATM E_GLOBAL
			
			INSERT INTO BdiTarjeta:"informix".Td_Movimientos_Conciliacion 
			(
				NombreArchivo,
				Archivo_Origen,
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
				Cve_Usuario
			)
			VALUES
			(
				psNomArchivo,
				psArchivoOrigen,
				TRIM(SUBSTRING (vsRegistro FROM 25 FOR 16 )),  --NUMTARJETA
				vsbbin,
				TRIM(SUBSTRING (vsRegistro FROM 10 FOR 6 )), --SECUENCIAAUTH 
				TRIM(SUBSTRING (vsRegistro FROM 183 FOR 10 )),  --MONTO
				TRIM(SUBSTRING (vsRegistro FROM 200 FOR 10 )) ,  --MONTOSURCHARGE
				trim(vscuenta), --NUMCUENTA Se cambio para recuperar de todos los registros y no solo de quellos que lo traen el 325
				trim(vsestransfer),
				'',  --IDCOMERCIO
				'',  --NOMCOMERCIO
				TRIM(SUBSTRING (vsRegistro FROM 91 FOR 15 )),  --TIPOTRANSACCION
				'',  --REFTRANSACCION
				'',  --RFC
				'',  --DIVISA
				'',  --MONTODIVISA
				TRIM(SUBSTRING (vsRegistro FROM 115 FOR 3 )), --ISO325 
				CASE WHEN (TRIM(SUBSTRING (vsRegistro FROM 70 FOR 19 )) = 'REVERSAL') THEN 'T' 
					 WHEN (TRIM(SUBSTRING (vsRegistro FROM 70 FOR 19 )) = 'REVERSAL          P') THEN 'P' 
					 ELSE 'F' END, --MOVREV325 
				psCve_Usuario

				
			);
			
			
			
		ELIF (piTipoLayOut = 3) THEN -- ATM PROSA STAT07
			
			INSERT INTO BdiTarjeta:"informix".Td_Movimientos_Conciliacion 
			(
				NombreArchivo,
				Archivo_Origen,
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
				Cve_Usuario
			)
			VALUES
			(
				psNomArchivo,
				psArchivoOrigen,
				TRIM(SUBSTRING (vsRegistro FROM 25 FOR 16 )),  --NUMTARJETA
				vsbbin,
				TRIM(SUBSTRING (vsRegistro FROM 10 FOR 6 )), --SECUENCIAAUTH 
				TRIM(REPLACE(SUBSTRING (vsRegistro FROM 181 FOR 10 ), '.', '')),  --MONTO
				TRIM(SUBSTRING (vsRegistro FROM 233 FOR 10 )),  --MONTOSURCHARGE
				trim(vscuenta), --NUMCUENTA Se cambio para recuperar de todos los registros y no solo de quellos que lo traen el 325
				trim(vsestransfer),
				'',  --IDCOMERCIO
				'',  --NOMCOMERCIO
				TRIM(SUBSTRING (vsRegistro FROM 91 FOR 15 )),  --TIPOTRANSACCION
				'',  --REFTRANSACCION
				'',  --RFC
				'',  --DIVISA
				'',  --MONTODIVISA
				TRIM(SUBSTRING (vsRegistro FROM 115 FOR 3 )), --ISO325 
				CASE WHEN (TRIM(SUBSTRING (vsRegistro FROM 70 FOR 19 )) MATCHES('REVERSAL*') ) THEN 'V' ELSE 'F' END, --MOVREV325 
				psCve_Usuario
			);
			
		ELIF (piTipoLayOut = 4) THEN -- ATM PROSA STAT06
			
			
			INSERT INTO Intercard:"informix".Conciliacion_ATM_Stat06 
			( 
				FechaConciliacion, 
				ArchivoOrigen, 
				NombreArchivo, 
				Emisor, 
				NumCajero, 
				NumTarjeta, 
				NumCuenta, 
				IndicadordeReversa, 
				Descripcion, 
				Respuesta, 
				CodigoISO, 
				Secuencia, 
				Fecha, 
				Hora, 
				Orden, 
				Red, 
				Monto, 
				Dolares, 
				ComisionSurcharge, 
				Donativo, 
				Emp, 
				Autorizacion, 
				Compania, 
				Comision_LoyaltyFee, 
				Comision_UsoLinea
			)
			VALUES 
			(
				CURRENT,
				psArchivoOrigen,
				TRIM(psNomArchivo),
				TRIM(SUBSTRING (vsRegistro FROM 3 FOR 4 )), --EMISOR
				TRIM(SUBSTRING (vsRegistro FROM 25 FOR 12 )), --NUMCANERO
				TRIM(SUBSTRING (vsRegistro FROM 37 FOR 16 )), -- NUMTARJETA
				/*TRIM(SUBSTRING (vsRegistro FROM 60 FOR 20 )),	--*/trim(vscuenta), --NUMCUENTA Se cambio para recuperar de todos los registros y no solo de quellos que lo traen el 325
				TRIM(SUBSTRING (vsRegistro FROM 82 FOR 19 )), --INDICADORDEREVERSA
				TRIM(SUBSTRING (vsRegistro FROM 103 FOR 15 )), --DESCRIPCION
				TRIM(SUBSTRING (vsRegistro FROM 121 FOR 6 )), --RESPUESTA
				TRIM(SUBSTRING (vsRegistro FROM 128 FOR 2 )), --CODIGOISO   --- SE detecto desface 127
				TRIM(SUBSTRING (vsRegistro FROM 133 FOR 12 )), --SECUENCIA
				TRIM(SUBSTRING (vsRegistro FROM 150 FOR 8 )), --FECHA
				TRIM(SUBSTRING (vsRegistro FROM 159 FOR 8 )), --HORA
				TRIM(SUBSTRING (vsRegistro FROM 170 FOR 6 )), --ORDEN
				TRIM(SUBSTRING (vsRegistro FROM 176 FOR 4 )), --RED 
				TRIM(SUBSTRING (vsRegistro FROM 181 FOR 10 )),  --MONTO
				TRIM(SUBSTRING (vsRegistro FROM 192 FOR 7 )),  --DOLARES
				TRIM(SUBSTRING (vsRegistro FROM 200 FOR 10 )),  --COMISIONSURCHARGE
				TRIM(SUBSTRING (vsRegistro FROM 211 FOR 10 )),  --DONATIVO
				TRIM(SUBSTRING (vsRegistro FROM 222 FOR 4 )),  --EMP
				TRIM(SUBSTRING (vsRegistro FROM 227 FOR 6 )),  --AUTORIZACION
				vsbbin,  --TRIM(SUBSTRING (vsRegistro FROM 234 FOR 10 )), --COMPAÃÂ?IA  -- SE QUITA Y PONE BANDERA DE BIN
				TRIM(SUBSTRING (vsRegistro FROM 245 FOR 10 )),  --COMISION_LOYALTYFEE
				TRIM(SUBSTRING (vsRegistro FROM 256 FOR 10 ))  --COMISION_USOLINEA
			);
  		--  ########################## -- ATM IST BANCOPPEL STAT06 #############################################
		ELIF (piTipoLayOut = 7) THEN 
			
			LET vsfechalocaldia = TRIM(SUBSTRING (vsRegistro FROM 150 FOR 2 )); --FECHA_dia
			LET vsfechalocalmes = TRIM(SUBSTRING (vsRegistro FROM 153 FOR 2 )); --FECHA_mes
			LET vshoralocalhr = TRIM(SUBSTRING (vsRegistro FROM 159 FOR 2 )); --hora
			LET vshoralocalmin = TRIM(SUBSTRING (vsRegistro FROM 162 FOR 2 )); -- minutos
			LET vsSecuencia = TRIM(SUBSTRING (vsRegistro FROM 227 FOR 6 )); -- autorizacion
			
			LET vsSecuencia_extendida = vsfechalocalmes||vsfechalocaldia||vshoralocalhr||vshoralocalmin||vsIDSecuencia||vsSecuencia;
			
			LET vsCompania = TRIM(SUBSTRING (vsRegistro FROM 234 FOR 1 ));
			
			IF (vsbbin = 'BNI') THEN 
			
				IF (vsCompania = 'D') THEN
				
					LET vsbbin ='BND';
				
				ELIF (vsCompania ='C') THEN
				
					LET vsbbin ='BNC';
				
				END IF;
			 
			END IF;
			
			INSERT INTO Intercard:"informix".Conciliacion_ATM_Stat06 
			( 
				FechaConciliacion, 
				ArchivoOrigen, 
				NombreArchivo, 
				Emisor, 
				NumCajero, 
				NumTarjeta, 
				NumCuenta, 
				IndicadordeReversa, 
				Descripcion, 
				Respuesta, 
				CodigoISO, 
				Secuencia, 
				Fecha, 
				Hora, 
				Orden, 
				Red, 
				Monto, 
				Dolares, 
				ComisionSurcharge, 
				Donativo, 
				Emp, 
				Autorizacion, 
				Compania, 
				Comision_LoyaltyFee, 
				Comision_UsoLinea,
				pos_entry_mode,
				service_code,
				terminal_capability,
				arqc, 
				arpc,
				arqc_verify,
				secuenciaextendida
			)
			VALUES 
			(
				CURRENT,
				psArchivoOrigen,
				TRIM(psNomArchivo),
				TRIM(SUBSTRING (vsRegistro FROM 3 FOR 4 )), --EMISOR
				TRIM(SUBSTRING (vsRegistro FROM 25 FOR 12 )), --NUMCANERO
				TRIM(SUBSTRING (vsRegistro FROM 37 FOR 16 )), -- NUMTARJETA
				TRIM(SUBSTRING (vsRegistro FROM 60 FOR 20 )),	--NUMCUENTA
				TRIM(SUBSTRING (vsRegistro FROM 82 FOR 19 )), --INDICADORDEREVERSA
				TRIM(SUBSTRING (vsRegistro FROM 103 FOR 15 )), --DESCRIPCION
				TRIM(SUBSTRING (vsRegistro FROM 121 FOR 6 )), --RESPUESTA
				TRIM(SUBSTRING (vsRegistro FROM 128 FOR 2 )), --CODIGOISO
				TRIM(SUBSTRING (vsRegistro FROM 133 FOR 12 )), --SECUENCIA
				TRIM(SUBSTRING (vsRegistro FROM 150 FOR 8 )), --FECHA
				TRIM(SUBSTRING (vsRegistro FROM 159 FOR 8 )), --HORA
				TRIM(SUBSTRING (vsRegistro FROM 170 FOR 6 )), --ORDEN
				TRIM(SUBSTRING (vsRegistro FROM 176 FOR 4 )), --RED 
				TRIM(SUBSTRING (vsRegistro FROM 181 FOR 10 )),  --MONTO
				TRIM(SUBSTRING (vsRegistro FROM 192 FOR 7 )),  --DOLARES
				TRIM(SUBSTRING (vsRegistro FROM 200 FOR 10 )),  --COMISIONSURCHARGE
				TRIM(SUBSTRING (vsRegistro FROM 211 FOR 10 )),  --DONATIVO
				TRIM(SUBSTRING (vsRegistro FROM 222 FOR 4 )),  --EMP
				TRIM(SUBSTRING (vsRegistro FROM 227 FOR 6 )),  --AUTORIZACION
				vsbbin,  --TRIM(SUBSTRING (vsRegistro FROM 234 FOR 10 )), --COMPAÃÂ?IA  -- SE QUITA Y PONE BANDERA DE BIN
				TRIM(SUBSTRING (vsRegistro FROM 245 FOR 10 )),  --COMISION_LOYALTYFEE
				TRIM(SUBSTRING (vsRegistro FROM 256 FOR 10 )),  --COMISION_USOLINEA
				TRIM(SUBSTR(vsRegistro, 271, 3)), -- POS ENTRY MODE
				TRIM(SUBSTR(vsRegistro, 275, 1)), -- SERVICE CODE
				TRIM(SUBSTR(vsRegistro, 277, 8)), -- Terminal capability
				TRIM(SUBSTR(vsRegistro, 286, 16)), -- ARQC
				TRIM(SUBSTR(vsRegistro, 303, 32)), -- ARPC
				TRIM(SUBSTR(vsRegistro, 336, 1)), -- ARQC verification
				vsSecuencia_extendida -- secuencia extendida generada del archivo
			);				
			
			--Se agrega la InserciÃÂÃÂ³n en td_movimientos_conciliaciÃÂÃÂ³n para registros del Stat06 LAGS
			INSERT INTO BdiTarjeta:"informix".Td_Movimientos_Conciliacion 
			(
				NombreArchivo,
				Archivo_Origen,
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
				secuencia_ext_archivo
			)
			VALUES
			(
				psNomArchivo,
				psArchivoOrigen,
				TRIM(SUBSTRING (vsRegistro FROM 37 FOR 16 )),  --NUMTARJETA
				vsbbin,
				TRIM(SUBSTRING (vsRegistro FROM 227 FOR 6 )), --SECUENCIAAUTH 
				TRIM(SUBSTRING (vsRegistro FROM 181 FOR 10 )),  --MONTO
				TRIM(SUBSTRING (vsRegistro FROM 200 FOR 10 )),  --MONTOSURCHARGE
				TRIM(SUBSTRING (vsRegistro FROM 60 FOR 20 )),	--NUMCUENTA LVRQ se obtiene de archivo
				trim(vsestransfer),
				'',  --IDCOMERCIO
				'',  --NOMCOMERCIO
				TRIM(SUBSTRING (vsRegistro FROM 103 FOR 15 )), --TIPOTRANSACCION
				'',  --REFTRANSACCION
				'',  --RFC
				'',  --DIVISA
				'',  --MONTODIVISA
				TRIM(SUBSTRING (vsRegistro FROM 128 FOR 2 )), --ISO325 
				TRIM(SUBSTRING (vsRegistro FROM 82 FOR 19 )), --MOVREV325 
				psCve_Usuario,
				vsSecuencia_extendida
			);
			
		ELIF (piTipoLayOut = 6 AND psArchivoOrigen = 'VID')  THEN -- POS Internacional de VISA DEBI
		    -- Para Modificar monto real en compras por CASHBACK
			
			LET vsfechalocaldia = TRIM(SUBSTRING (vsRegistro FROM 71 FOR 2 )); --FECHA_dia
			LET vsfechalocalmes = TRIM(SUBSTRING (vsRegistro FROM 69 FOR 2 )); --FECHA_mes
			LET vshoralocalhr 	= TRIM(SUBSTRING (vsRegistro FROM 227 FOR 2 )); --hora y minutos
			LET vshoralocalmin 	= TRIM(SUBSTRING (vsRegistro FROM 229 FOR 2 )); -- minutos
			LET vsSecuencia	 	= TRIM(SUBSTRING (vsRegistro FROM 91 FOR 6 )); -- autorizacion
			
			LET vsSecuencia_extendida = vsfechalocalmes||vsfechalocaldia||vshoralocalhr||vshoralocalmin||vsIDSecuencia||vsSecuencia;
			
			
			LET vsRegistroMontoCashBack = TRIM(SUBSTR(vsRegistro, 312,13)); -- MONTO CASH BACK;
			if vsRegistroMontoCashBack <> '0000000000000' then --IF vmRegistroMontoCashBack > 0.0 THEN
				LET vsRegistroMontototal = TRIM(SUBSTRING (vsRegistro FROM 26 FOR 13 ));
				LET	vmRegistroMontototal = (( REPLACE( vsRegistroMontototal,'.',''))::MONEY/100 );
				LET vmRegistroMontoCashBack = (( REPLACE( vsRegistroMontoCashBack,'.',''))::MONEY/100 );
				LET vmRegistroComprareal = vmRegistroMontototal - vmRegistroMontoCashBack;
				LET vsRegistroComprareal = CAST(vmRegistroComprareal as CHAR(13));
				LET vsRegistroComprareal = REPLACE(REPLACE(vsRegistroComprareal,'$',''),'.',''); 
				LET viconcaracteres = Length(vsRegistroComprareal);
				FOR  a = viconcaracteres  TO 12 STEP 1
						LET vsRegistroComprareal = '0'||vsRegistroComprareal;
				END FOR;
			END IF;
			
			INSERT INTO BdiTarjeta:"informix".Td_Movimientos_Conciliacion 
				(
					NombreArchivo,
					Archivo_Origen,
					NumTarjeta,
					ban_bin,
					Secuencia325,
					Monto325,
					montocashback325,
					--MontoSurcharge325,
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
					txn_code,
					indicador_fastfounds,
					ref_num_fastfounds,
					secuencia_ext_archivo
				)
				VALUES
				(
					psNomArchivo,
					psArchivoOrigen,
					TRIM(SUBSTRING (vsRegistro FROM 5 FOR 16 )), --NUMTARJETA
					vsbbin,
					TRIM(SUBSTRING (vsRegistro FROM 91 FOR 6 )), --SECUENCIAAUTH
					CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 312,13))) <> '0000000000000' THEN 
								vsRegistroComprareal --monto compra real menos cashback
							ELSE 
								(TRIM(SUBSTR(vsRegistro, 26,13))) --monto compra
							END, 
					TRIM(SUBSTR(vsRegistro, 312,13)), -- MONTO CASH BACK
					--TRIM(SUBSTRING (vsRegistro FROM 78 FOR 1 )), --MONTOSURCHARGE325 / FORMADEPAGO [PNC]
					CASE 	WHEN psArchivoOrigen not in ('CCP', 'CCD', 'TPD') then -- Para poner valor original 
								trim(vscuenta) --NUMCUENTA
							else
								' '
							end,
					trim(vsestransfer),
					TRIM(SUBSTRING (vsRegistro FROM 122 FOR 15 )),  --IDCOMERCIO
					TRIM(SUBSTRING (vsRegistro FROM 137 FOR 25 )),  --NOMCOMERCIO
					CASE 	WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '05' then  -- Para Compras
								'01'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '01' then  -- Disposiciones de ATMs
								'01'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '07' then  -- Disposiciones Extranjero ventanilla
								'01'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '20' then  -- Abonos Money Gram  
							    '20'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '08' then  -- Pagos
							    '20'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '06' then  -- Devoluciones 
								'21'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '25' then  -- Reversos BACH o Cancelaciones de Venta 
							    '21'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '26' then  -- Reversos BACH o CancelaciÃÂÃÂ³n de Nota de LiquidaciÃÂÃÂ³n
							    '01'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '27' then  -- Reversos BACH o CancelaciÃÂÃÂ³n de DisposiciÃÂÃÂ³n en Efectivo
							    '21'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '31' then  -- Venta GenÃÂÃÂ©rica 
							    '01'
							else
								'  '
							end,  --TIPOTRANSACCION
					TRIM(SUBSTRING (vsRegistro FROM 99 FOR 23 )),  --REFTRANSACCION
					TRIM(SUBSTRING (vsRegistro FROM 205 FOR 16 )),  --RFC
					TRIM(SUBSTRING (vsRegistro FROM 86 FOR 3 )),  --DIVISA
					TRIM(SUBSTRING (vsRegistro FROM 73 FOR 13 )),  --MONTODIVISA
					'', --ISO325 
					'', --MOVREV325 
					psCve_Usuario,
					TRIM(SUBSTRING (vsRegistro FROM 336 FOR 1 )),  -- Transaction Code Qualifier
					TRIM(SUBSTRING (vsRegistro FROM 443 FOR 1 )),  -- Fast Funds Indicator
					TRIM(SUBSTRING (vsRegistro FROM 451 FOR 16 )),  --Referencia FastFunds
					vsSecuencia_extendida
					
				);
				
ELIF (piTipoLayOut = 6) THEN -- POS Internacionales de MasterCard Debito y Credito VISA Credito y Ventas Nacionales Debito y credito
		    -- Para Modificar monto real en compras por CASHBACK
			
			LET vsfechalocaldia = TRIM(SUBSTRING (vsRegistro FROM 71 FOR 2 )); --FECHA_dia
			LET vsfechalocalmes = TRIM(SUBSTRING (vsRegistro FROM 69 FOR 2 )); --FECHA_mes
			LET vshoralocalhr 	= TRIM(SUBSTRING (vsRegistro FROM 227 FOR 2 )); --hora y minutos
			LET vshoralocalmin 	= TRIM(SUBSTRING (vsRegistro FROM 229 FOR 2 )); -- minutos
			LET vsSecuencia	 	= TRIM(SUBSTRING (vsRegistro FROM 91 FOR 6 )); -- autorizacion
			
			LET vsSecuencia_extendida = vsfechalocalmes||vsfechalocaldia||vshoralocalhr||vshoralocalmin||vsIDSecuencia||vsSecuencia;
			
			
			LET vsRegistroMontoCashBack = TRIM(SUBSTR(vsRegistro, 312,13)); -- MONTO CASH BACK;
			if vsRegistroMontoCashBack <> '0000000000000' then --IF vmRegistroMontoCashBack > 0.0 THEN
				LET vsRegistroMontototal = TRIM(SUBSTRING (vsRegistro FROM 26 FOR 13 ));
				LET	vmRegistroMontototal = (( REPLACE( vsRegistroMontototal,'.',''))::MONEY/100 );
				LET vmRegistroMontoCashBack = (( REPLACE( vsRegistroMontoCashBack,'.',''))::MONEY/100 );
				LET vmRegistroComprareal = vmRegistroMontototal - vmRegistroMontoCashBack;
				LET vsRegistroComprareal = CAST(vmRegistroComprareal as CHAR(13));
				LET vsRegistroComprareal = REPLACE(REPLACE(vsRegistroComprareal,'$',''),'.',''); 
				LET viconcaracteres = Length(vsRegistroComprareal);
				FOR  a = viconcaracteres  TO 12 STEP 1
						LET vsRegistroComprareal = '0'||vsRegistroComprareal;
				END FOR;
			END IF;
			
			IF iTotRegistrosAux = iTotRegEglobal AND iTotRegEglobal <> 0 THEN
			
				
				INSERT INTO BdiTarjeta:"informix".Td_Movimientos_Conciliacion 
				(
					NombreArchivo,
					Archivo_Origen,
					NumTarjeta,
					ban_bin,
					Secuencia325,
					Monto325,
					montocashback325,
					--MontoSurcharge325,
					NumCuenta,
					estransfer,
					IdComercio325,
					NomComercio325,
					TipoTransaccion325,
					Referencia23_325,
					RFC325,
					Divisa325,
					Monto_Divisa325,
					diferimiento_promo,
					parcialiacion_promo,
					tipo_plan_promo,
					ISO323,
					MovRev325,
					Cve_Usuario,
					secuencia_ext_archivo
				)
				VALUES
				(
					psNomArchivo,
					psArchivoOrigen,
					TRIM(SUBSTRING (vsRegistro FROM 5 FOR 16 )), --NUMTARJETA
					vsbbin,
					TRIM(SUBSTRING (vsRegistro FROM 91 FOR 6 )), --SECUENCIAAUTH
					CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 312,13))) <> '0000000000000' THEN 
								vsRegistroComprareal --monto compra real menos cashback
							ELSE 
								(TRIM(SUBSTR(vsRegistro, 26,13))) --monto compra
							END, 
					TRIM(SUBSTR(vsRegistro, 312,13)), -- MONTO CASH BACK
					--TRIM(SUBSTRING (vsRegistro FROM 78 FOR 1 )), --MONTOSURCHARGE325 / FORMADEPAGO [PNC]
					CASE 	WHEN psArchivoOrigen not in ('CCP', 'CCD', 'TPD') then -- Para poner valor original 
								trim(vscuenta) --NUMCUENTA
							else
								' '
							end,
					trim(vsestransfer),
					TRIM(SUBSTRING (vsRegistro FROM 122 FOR 15 )),  --IDCOMERCIO
					TRIM(SUBSTRING (vsRegistro FROM 137 FOR 25 )),  --NOMCOMERCIO
					CASE 	WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '05' then  -- Para Compras
								'01'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '01' then  -- Disposiciones de ATMs
								'01'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '07' then  -- Disposiciones Extranjero ventanilla
								'01'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '20' then  -- Abonos Money Gram  
								'20'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '08' then  -- Pagos
								'20'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '06' then  -- Devoluciones 
								'21'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '25' then  -- Reversos BACH o Cancelaciones de Venta 
								'21'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '26' then  -- Reversos BACH o CancelaciÃÂÃÂ³n de Nota de LiquidaciÃÂÃÂ³n
								'01'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '27' then  -- Reversos BACH o CancelaciÃÂÃÂ³n de DisposiciÃÂÃÂ³n en Efectivo
								'21'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '31' then  -- Venta GenÃÂÃÂ©rica 
								'01'
							else
								'  '
							end,  --TIPOTRANSACCION
					TRIM(SUBSTRING (vsRegistro FROM 99 FOR 23 )),  --REFTRANSACCION
					TRIM(SUBSTRING (vsRegistro FROM 205 FOR 16 )),  --RFC
					TRIM(SUBSTRING (vsRegistro FROM 86 FOR 3 )),  --DIVISA
					TRIM(SUBSTRING (vsRegistro FROM 73 FOR 13 )),  --MONTODIVISA
					TRIM(SUBSTRING (vsRegistro FROM 443 FOR 2 )),  -- DIFERIMEINTO DE PROMOCIONES
					TRIM(SUBSTRING (vsRegistro FROM 445 FOR 2 )),  -- PARCIALIZACIÃÂN DE PROMOCIONES
					TRIM(SUBSTRING (vsRegistro FROM 447 FOR 2 )),  -- TIPO PLAN DE PROMOCIONES
					'', --ISO325 
					'', --MOVREV325 
					psCve_Usuario,
					vsSecuencia_extendida
				);

				-- llenado de tabla td_movimientos_cnc_coppel_pay separando campos nuevos 
				--Filtrando por nommbre de archivo origen y por bin.
				IF ((psArchivoOrigen = 'VNC' OR psArchivoOrigen = 'MCC') AND TRIM(SUBSTRING (vsRegistro FROM 5 FOR 6 )) = '514014') THEN
					INSERT INTO BdiTarjeta:"informix".td_movimientos_cnc_coppel_pay 
					(
						NombreArchivo,
						Archivo_Origen,
						referencia23_325,
						importe_origen,
						pos_entrymode,
						fecha_consumo,
						afi_comercio,
						giro_comercio,
						zcode_comercio,
						porcentaje_com_inter,
						importe_comision,
						secuencia_extendida,
						fecha_proceso,
						fecha_reproceso,
						conciliacionCoppel
					)
					VALUES
					(
						psNomArchivo,
						psArchivoOrigen,
						TRIM(SUBSTRING (vsRegistro FROM 99 FOR 23 )),--referencia23_325
						TRIM(SUBSTRING (vsRegistro FROM 73 FOR 13 )), --importe_origen,  
						TRIM(SUBSTRING (vsRegistro FROM 97 FOR 2 )),--pos_entrymode,
						TRIM(SUBSTRING (vsRegistro FROM 65 FOR 8 )),--fecha_consumo,
						TRIM(SUBSTRING (vsRegistro FROM 122 FOR 15 )),--afi_comercio, 
						TRIM(SUBSTRING (vsRegistro FROM 180 FOR 4 )),--giro_comercio,
						TRIM(SUBSTRING (vsRegistro FROM 288 FOR 5 )),--zcode_comercio,
						TRIM(SUBSTRING (vsRegistro FROM 162 FOR 5 )),--porcentaje_com_inter,			
						TRIM(SUBSTRING (vsRegistro FROM 167 FOR 13 )),--importe_comision,
						vsSecuencia_extendida,
						dFechaProcesoAux,
						dFechaReproceso,
						'P'
					);
				END IF				
			
			ELSE

				INSERT INTO BdiTarjeta:"informix".Td_Movimientos_Conciliacion 
				(
					NombreArchivo,
					Archivo_Origen,
					NumTarjeta,
					ban_bin,
					Secuencia325,
					Monto325,
					montocashback325,
					--MontoSurcharge325,
					NumCuenta,
					estransfer,
					IdComercio325,
					NomComercio325,
					TipoTransaccion325,
					Referencia23_325,
					RFC325,
					Divisa325,
					Monto_Divisa325,
					diferimiento_promo,
					parcialiacion_promo,
					tipo_plan_promo,
					ISO323,
					MovRev325,
					Cve_Usuario,
					secuencia_ext_archivo
				)
				VALUES
				(
					psNomArchivo,
					psArchivoOrigen,
					TRIM(SUBSTRING (vsRegistro FROM 5 FOR 16 )), --NUMTARJETA
					vsbbin,
					TRIM(SUBSTRING (vsRegistro FROM 91 FOR 6 )), --SECUENCIAAUTH
					CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 312,13))) <> '0000000000000' THEN 
								vsRegistroComprareal --monto compra real menos cashback
							ELSE 
								(TRIM(SUBSTR(vsRegistro, 26,13))) --monto compra
							END, 
					TRIM(SUBSTR(vsRegistro, 312,13)), -- MONTO CASH BACK
					--TRIM(SUBSTRING (vsRegistro FROM 78 FOR 1 )), --MONTOSURCHARGE325 / FORMADEPAGO [PNC]
					CASE 	WHEN psArchivoOrigen not in ('CCP', 'CCD', 'TPD') then -- Para poner valor original 
								trim(vscuenta) --NUMCUENTA
							else
								' '
							end,
					trim(vsestransfer),
					TRIM(SUBSTRING (vsRegistro FROM 122 FOR 15 )),  --IDCOMERCIO
					TRIM(SUBSTRING (vsRegistro FROM 137 FOR 25 )),  --NOMCOMERCIO
					CASE 	WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '05' then  -- Para Compras
								'01'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '01' then  -- Disposiciones de ATMs
								'01'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '07' then  -- Disposiciones Extranjero ventanilla
								'01'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '20' then  -- Abonos Money Gram  
								'20'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '08' then  -- Pagos
								'20'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '06' then  -- Devoluciones 
								'21'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '25' then  -- Reversos BACH o Cancelaciones de Venta 
								'21'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '26' then  -- Reversos BACH o CancelaciÃÂÃÂ³n de Nota de LiquidaciÃÂÃÂ³n
								'01'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '27' then  -- Reversos BACH o CancelaciÃÂÃÂ³n de DisposiciÃÂÃÂ³n en Efectivo
								'21'
							WHEN  	TRIM(SUBSTRING (vsRegistro FROM 24 FOR 2 )) = '31' then  -- Venta GenÃÂÃÂ©rica 
								'01'
							else
								'  '
							end,  --TIPOTRANSACCION
					TRIM(SUBSTRING (vsRegistro FROM 99 FOR 23 )),  --REFTRANSACCION
					TRIM(SUBSTRING (vsRegistro FROM 205 FOR 16 )),  --RFC
					TRIM(SUBSTRING (vsRegistro FROM 86 FOR 3 )),  --DIVISA
					TRIM(SUBSTRING (vsRegistro FROM 73 FOR 13 )),  --MONTODIVISA
					TRIM(SUBSTRING (vsRegistro FROM 443 FOR 2 )),  -- DIFERIMEINTO DE PROMOCIONES
					TRIM(SUBSTRING (vsRegistro FROM 445 FOR 2 )),  -- PARCIALIZACIÃÂN DE PROMOCIONES
					TRIM(SUBSTRING (vsRegistro FROM 447 FOR 2 )),  -- TIPO PLAN DE PROMOCIONES
					'', --ISO325 
					'', --MOVREV325 
					psCve_Usuario,
					vsSecuencia_extendida
				);

				-- llenado de tabla td_movimientos_cnc_coppel_pay separando campos nuevos 
				--Filtrando por nommbre de archivo origen y por bin.
				IF ((psArchivoOrigen = 'VNC' OR psArchivoOrigen = 'MCC') AND TRIM(SUBSTRING (vsRegistro FROM 5 FOR 6 )) = '514014') THEN
					INSERT INTO BdiTarjeta:"informix".td_movimientos_cnc_coppel_pay 
					(
						NombreArchivo,
						Archivo_Origen,
						referencia23_325,
						importe_origen,
						pos_entrymode,
						fecha_consumo,
						afi_comercio,
						giro_comercio,
						zcode_comercio,
						porcentaje_com_inter,
						importe_comision,
						secuencia_extendida,
						fecha_proceso,
						conciliacionCoppel
					)
					VALUES
					(
						psNomArchivo,
						psArchivoOrigen,
						TRIM(SUBSTRING (vsRegistro FROM 99 FOR 23 )),--referencia23_325
						TRIM(SUBSTRING (vsRegistro FROM 73 FOR 13 )), --importe_origen,  
						TRIM(SUBSTRING (vsRegistro FROM 97 FOR 2 )),--pos_entrymode,
						TRIM(SUBSTRING (vsRegistro FROM 65 FOR 8 )),--fecha_consumo,
						TRIM(SUBSTRING (vsRegistro FROM 122 FOR 15 )),--afi_comercio, 
						TRIM(SUBSTRING (vsRegistro FROM 180 FOR 4 )),--giro_comercio,
						TRIM(SUBSTRING (vsRegistro FROM 288 FOR 5 )),--zcode_comercio,
						TRIM(SUBSTRING (vsRegistro FROM 162 FOR 5 )),--porcentaje_com_inter,			
						TRIM(SUBSTRING (vsRegistro FROM 167 FOR 13 )),--importe_comision,
						vsSecuencia_extendida,
						dFechaproceso,
						'P'
					);
				END IF

			END IF
		END IF
		
		IF (piTipoLayOut = 7) THEN
			LET viContadorRegistros = viContadorRegistros + 2;
		ELSE 
			LET viContadorRegistros = viContadorRegistros + 1;		
		END IF
			LET vsMensaje_Respuesta = 'TERMINAR TRANSACCION';
		--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (viContadorRegistros >= 1000) THEN                
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
			CONTINUE FOREACH;
		END IF
			
		END FOREACH;


		LET vsMensaje_Respuesta = 'TERMINAR TRANSACCION';
	
		-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
	
	IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
		COMMIT WORK;
		LET vsFlagEnTransaccion = 'F';
            LET viContadorRegistros = 0;
	END IF;
	
	
	LET vsMensaje_Respuesta = 'BORRAR CONTENIDO DE TD_CARGA_ARCHIVO.';
	BEGIN WORK;	
	LET vsFlagEnTransaccion = 'V';

	
	
	--BORRA LOS REGISTROS DEL ARCHIVO ALMACENADOS EN LA TABLA DE CARGA
            TRUNCATE TABLE BdiTarjeta:"informix".Td_Carga_Archivo DROP STORAGE;
	
	
	COMMIT WORK;
	
	LET vsFlagEnTransaccion = 'F';
	LET vsMensaje_Respuesta = '';
	
	
	RETURN vsCodRet, vsMensaje_Respuesta, 2;
	
	END

END PROCEDURE                                                                                                                                                                                             
;